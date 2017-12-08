#!/bin/bash

set -e

TOP=`pwd`
export TOP

source ${TOP}/device/nexell/tools/common.sh
source ${TOP}/device/nexell/tools/dir.sh
source ${TOP}/device/nexell/tools/make_build_info.sh
source ${TOP}/device/nexell/tools/revert_patches.sh

parse_args -s s5p4418 $@
print_args
setup_toolchain
export_work_dir

revert_common ${TOP}/device/nexell/zh_blackdragon/patch
revert_common ${TOP}/device/nexell/patch
revert_common ${TOP}/device/nexell/quickboot/patch

patch_common ${TOP}/device/nexell/patch
if [ "${QUICKBOOT}" == "true" ]; then
	patch_common ${TOP}/device/nexell/quickboot/patch
fi
patch_common ${TOP}/device/nexell/zh_blackdragon/patch

DEV_PORTNUM=0
MEMSIZE="2GB"

DEVICE_DIR=${TOP}/device/nexell/${BOARD_NAME}
OUT_DIR=${TOP}/out/target/product/${BOARD_NAME}

cp ${DEVICE_DIR}/domain.te ${TOP}/system/sepolicy

KERNEL_IMG=${KERNEL_DIR}/arch/arm/boot/zImage
DTB_IMG=${KERNEL_DIR}/arch/arm/boot/dts/s5p4418-zh_blackdragon-rev00.dtb

UBOOT_LOAD_ADDR=0x40007800

CROSS_COMPILE="arm-eabi-"

if [ "${BUILD_ALL}" == "true" ] || [ "${BUILD_BL1}" == "true" ]; then
	build_bl1_s5p4418 ${BL1_DIR}/bl1-${TARGET_SOC} nxp4330 zh_blackdragon 0
fi

if [ "${BUILD_ALL}" == "true" ] || [ "${BUILD_UBOOT}" == "true" ]; then
	build_uboot ${UBOOT_DIR} ${TARGET_SOC} ${BOARD_NAME} ${CROSS_COMPILE}
	gen_third ${TARGET_SOC} ${UBOOT_DIR}/u-boot.bin \
		0x43c00000 0x43c00000 ${TOP}/device/nexell/secure/bootloader.img
fi

if [ "${BUILD_ALL}" == "true" ] || [ "${BUILD_SECURE}" == "true" ]; then
	pos=0
	file_size=0

	build_bl2_s5p4418 ${TOP}/device/nexell/secure/bl2-s5p4418
	build_armv7_dispatcher ${TOP}/device/nexell/secure/armv7-dispatcher

	gen_third ${TARGET_SOC} ${TOP}/device/nexell/secure/bl2-s5p4418/out/pyrope-bl2.bin \
		0xb0fe0000 0xb0fe0400 ${TOP}/device/nexell/secure/loader-emmc.img \
		"-m 0x40200 -b 3 -p ${DEV_PORTNUM} -m 0x1E0200 -b 3 -p ${DEV_PORTNUM} -m 0x60200 -b 3 -p ${DEV_PORTNUM}"
	gen_third ${TARGET_SOC} ${TOP}/device/nexell/secure/armv7-dispatcher/out/armv7_dispatcher.bin \
		0xffff0200 0xffff0200 ${TOP}/device/nexell/secure/bl_mon.img \
		"-m 0x40200 -b 3 -p ${DEV_PORTNUM} -m 0x1E0200 -b 3 -p ${DEV_PORTNUM} -m 0x60200 -b 3 -p ${DEV_PORTNUM}"

	file_size=35840
	dd if=${TOP}/device/nexell/secure/loader-emmc.img of=${TOP}/device/nexell/secure/fip-loader-usb.img seek=0 bs=1
	let pos=pos+file_size
	file_size=28672
	dd if=${TOP}/device/nexell/secure/bl_mon.img of=${TOP}/device/nexell/secure/fip-loader-usb.img seek=${pos} bs=1
	let pos=pos+file_size
	dd if=${TOP}/device/nexell/secure/bootloader.img of=${TOP}/device/nexell/secure/fip-loader-usb.img seek=${pos} bs=1
fi

if [ "${BUILD_ALL}" == "true" ] || [ "${BUILD_KERNEL}" == "true" ]; then
	build_kernel ${KERNEL_DIR} ${TARGET_SOC} ${BOARD_NAME} s5p4418_zh_blackdragon_nougat_defconfig ${CROSS_COMPILE}
	test -d ${OUT_DIR} && \
		cp ${KERNEL_IMG} ${OUT_DIR}/kernel && \
		cp ${DTB_IMG} ${OUT_DIR}/2ndbootloader
fi

if [ "${BUILD_ALL}" == "true" ] || [ "${BUILD_MODULE}" == "true" ]; then
	build_module ${KERNEL_DIR} ${TARGET_SOC} ${CROSS_COMPILE}
fi

test -d ${OUT_DIR} && test -f ${DEVICE_DIR}/bootloader && cp ${DEVICE_DIR}/bootloader ${OUT_DIR}

# handling ZH Patch
function get_apk_lib()
{
	local target_path=${1}

	mkdir -p ${target_path}/system-lib

	for f in `ls ${target_path}/system-app/*.apk`
	do
		echo "unzip ${f}"
		unzip -jo $f lib/armeabi/*.so -d ${target_path}/system-lib/ || echo "no *.so"
	done

	for f in `ls ${target_path}/system-priv-app/*.apk`
	do
		echo "unzip ${f}"
		unzip -jo $f lib/armeabi/*.so -d ${target_path}/system-lib/ || echo "no *.so"
	done

	find ${target_path}/third-lib/ -name *.so | xargs -i cp {} ${target_path}/system-lib/
}

function copy_apk_sudo()
{
	local src_dir=${1}
	local dest_dir=${2}

	for f in `ls ${src_dir}/*.apk`
	do
		apk_name=${f##*/}
		apk_folder_name=${apk_name%%.apk}
		apk_dir=${dest_dir}/${apk_folder_name}

		sudo mkdir -p ${apk_dir}
		sudo chmod 755 ${apk_dir}
		sudo cp ${f} ${apk_dir}
		sudo chmod 644 ${apk_dir}/${apk_name}

	done
}

function copy_bin_sudo()
{
	local src_dir=${1}
	local dest_dir=${2}

	for f in `ls ${src_dir}/*`
	do
		bin_name=${f##*/}
		sudo cp $f ${dest_dir}
		sudo chmod 755 ${dest_dir}/${bin_name}
	done
}

function install_zh_apk_sudo()
{
	project_app_out_name=${DEVICE_DIR}/apk_install
	local_tools_path=${TOP}/out/host/linux-x86

	pushd `pwd`
	cd ${project_app_out_name}
	${local_tools_path}/bin/simg2img ${TOP}/${RESULT_DIR}/system.img raw_system.img

	echo "*****mount raw_system.img*****"
	mkdir -p raw_system
	sudo mount -t ext4 -o loop raw_system.img raw_system/

	echo "****cp project app ****"
	get_apk_lib ${project_app_out_name}

	copy_apk_sudo ${project_app_out_name}/system-app ./raw_system/app
	copy_apk_sudo ${project_app_out_name}/system-priv-app ./raw_system/priv-app

	sudo cp ${project_app_out_name}/system-lib/* ./raw_system/lib/

	echo "****cp project bin ****"
	copy_bin_sudo ${project_app_out_name}/system-bin ./raw_system/bin


	echo "cp others"
	#sudo cp ${project_app_out_name}/other/config.ini  ./raw_system/
	#sudo cp ${project_app_out_name}/other/ring.mp3  ./raw_system/


	echo "删除原生应用及其相关lib"
	sudo rm -rf ./raw_system/app/Camera2
	sudo rm -rf ./raw_system/lib/libjni_jpegutil.so
	sudo rm -rf ./raw_system/lib/libjni_tinyplanet.so
	sudo rm -rf ./raw_system/app/Gallery2
	sudo rm -rf ./raw_system/lib/libjni_eglfence.so
	sudo rm -rf ./raw_system/lib/libjni_filtershow_filters.so
	sudo rm -rf ./raw_system/lib/libjni_jpegstream.so


	echo "已设置文件操作权限"
	sudo chmod 644 ./raw_system/lib/*.so || echo "fail ..."
	sudo chmod 644 ./raw_system/config.ini || echo "fail ..."
	sudo chmod 644 ./raw_system/ring.mp3 || echo "fail ..."
	sudo chmod 755 ./raw_system/bin/gocsdk || echo "fail ..."

	echo "*****make_ext4fs system.img*****"
	export LD_LIBRARY_PATH=${local_tools_path}/lib:$LD_LIBRARY_PATH
	export LD_LIBRARY_PATH=${local_tools_path}/lib64:$LD_LIBRARY_PATH
	sudo ${local_tools_path}/bin/make_ext4fs -s -T -1 -S ${OUT_DIR}/root/file_contexts.bin -L system -l 2147483648 -a system new_system.img raw_system/

	sudo umount raw_system/
	rm -rf raw_system/
	rm -rf system-lib/

	rm raw_system.img

	sudo mv new_system.img ${TOP}/${RESULT_DIR}/system.img

	echo "*****Successfully*****"
	popd
}

function copy_apk()
{
	local src_dir=${1}
	local dest_dir=${2}

	for f in `ls ${src_dir}/*.apk`
	do
		apk_name=${f##*/}
		apk_folder_name=${apk_name%%.apk}
		apk_dir=${dest_dir}/${apk_folder_name}

		mkdir -p ${apk_dir}
		chmod 755 ${apk_dir}
		cp ${f} ${apk_dir}
		chmod 644 ${apk_dir}/${apk_name}

	done
}

function copy_bin()
{
	local src_dir=${1}
	local dest_dir=${2}

	for f in `ls ${src_dir}/*`
	do
		bin_name=${f##*/}
		cp $f ${dest_dir}
		chmod 755 ${dest_dir}/${bin_name}
	done
}

function install_zh_apk()
{
	local project_app_out_name=${DEVICE_DIR}/apk_install
	local local_tools_path=${TOP}/out/host/linux-x86
	local dest_dir=${OUT_DIR}/system

	pushd `pwd`
	cd ${project_app_out_name}

	echo "****cp project app ****"
	get_apk_lib ${project_app_out_name}

	copy_apk ${project_app_out_name}/system-app ${dest_dir}/app
	copy_apk ${project_app_out_name}/system-priv-app ${dest_dir}/priv-app

	cp ${project_app_out_name}/system-lib/* ${dest_dir}/lib/

	echo "****cp project bin ****"
	copy_bin ${project_app_out_name}/system-bin ${dest_dir}/bin


	echo "cp others"
	#cp ${project_app_out_name}/other/config.ini ${dest_dir}
	#cp ${project_app_out_name}/other/ring.mp3 ${dest_dir}


	echo "删除原生应用及其相关lib"
	rm -rf ${dest_dir}/app/Camera2
	rm -rf ${dest_dir}/lib/libjni_jpegutil.so
	rm -rf ${dest_dir}/lib/libjni_tinyplanet.so
	rm -rf ${dest_dir}/app/Gallery2
	rm -rf ${dest_dir}/lib/libjni_eglfence.so
	rm -rf ${dest_dir}/lib/libjni_filtershow_filters.so
	rm -rf ${dest_dir}/lib/libjni_jpegstream.so


	echo "已设置文件操作权限"
	chmod 644 ${dest_dir}/lib/*.so || echo "fail ..."
	chmod 644 ${dest_dir}/config.ini || echo "fail ..."
	chmod 644 ${dest_dir}/ring.mp3 || echo "fail ..."
	chmod 755 ${dest_dir}/bin/gocsdk || echo "fail ..."

	echo "*****make_ext4fs system.img*****"
	export LD_LIBRARY_PATH=${local_tools_path}/lib:$LD_LIBRARY_PATH
	export LD_LIBRARY_PATH=${local_tools_path}/lib64:$LD_LIBRARY_PATH
	${local_tools_path}/bin/make_ext4fs -s -T -1 -S ${OUT_DIR}/root/file_contexts.bin \
		-L system -l 2147483648 -a system \
		${OUT_DIR}/system.img \
		${OUT_DIR}/system

	rm -rf system-lib/

	echo "*****Successfully*****"
	popd
}

if [ "${BUILD_ALL}" == "true" ] || [ "${BUILD_ANDROID}" == "true" ] || [ "${BUILD_DIST}" == "true" ]; then
	if [ "${QUICKBOOT}" == "true" ]; then
		cp ${DEVICE_DIR}/quickboot/* ${DEVICE_DIR}

		rm -rf ${OUT_DIR}/system
		rm -rf ${OUT_DIR}/root
		rm -rf ${OUT_DIR}/data
	fi

	build_android ${TARGET_SOC} ${BOARD_NAME} ${BUILD_TAG}

	test -d ${DEVICE_DIR}/apk_install && install_zh_apk
fi

# u-boot envs
if [ -f ${UBOOT_DIR}/u-boot.bin ]; then
	UBOOT_BOOTCMD=$(make_uboot_bootcmd \
		${DEVICE_DIR}/partmap.txt \
		${UBOOT_LOAD_ADDR} \
		2048 \
		${KERNEL_IMG} \
		${DTB_IMG} \
		${OUT_DIR}/ramdisk.img \
		"boot:emmc")

	UBOOT_RECOVERYCMD="ext4load mmc 0:6 0x49000000 recovery.dtb; ext4load mmc 0:6 0x40008000 recovery.kernel; ext4load mmc 0:6 0x48000000 ramdisk-recovery.img; bootz 40008000 0x48000000:27f000 0x49000000"

	UBOOT_BOOTARGS="console=ttyAMA3,115200n8 loglevel=7 printk.time=1 androidboot.hardware=zh_blackdragon androidboot.console=ttyAMA3 androidboot.serialno=s5p4418_zh_blackdragon quiet androidboot.selinux=permissive"

	SPLASH_SOURCE="mmc"
	SPLASH_OFFSET="0x2e4200"

	echo "UBOOT_BOOTCMD ==> ${UBOOT_BOOTCMD}"
	echo "UBOOT_RECOVERYCMD ==> ${UBOOT_RECOVERYCMD}"

	pushd `pwd`
	cd ${UBOOT_DIR}
	build_uboot_env_param ${CROSS_COMPILE} "${UBOOT_BOOTCMD}" "${UBOOT_BOOTARGS}" "${SPLASH_SOURCE}" "${SPLASH_OFFSET}" "${UBOOT_RECOVERYCMD}"
	popd

fi

# make bootloader
echo "make bootloader"
bl1=${BL1_DIR}/bl1-${TARGET_SOC}/out/bl1-emmcboot.bin
loader=${TOP}/device/nexell/secure/loader-emmc.img
secure=${TOP}/device/nexell/secure/bl_mon.img
nonsecure=${TOP}/device/nexell/secure/bootloader.img
param=${UBOOT_DIR}/params.bin
boot_logo=${DEVICE_DIR}/logo.bmp
out_file=${DEVICE_DIR}/bootloader

if [ -f ${bl1} ] && [ -f ${loader} ] && [ -f ${secure} ] && [ -f ${nonsecure} ] && [ -f ${param} ] && [ -f ${boot_logo} ]; then
	BOOTLOADER_PARTITION_SIZE=$(get_partition_size ${DEVICE_DIR}/partmap.txt bootloader)
	make_bootloader \
		${BOOTLOADER_PARTITION_SIZE} \
		${bl1} \
		65536 \
		${loader} \
		262144 \
		${secure} \
		1966080 \
		${nonsecure} \
		3014656 \
		${param} \
		3031040 \
		${boot_logo} \
		${out_file}

	test -d ${OUT_DIR} && cp ${DEVICE_DIR}/bootloader ${OUT_DIR}
fi

if [ "${BUILD_DIST}" == "true" ]; then
	build_dist ${TARGET_SOC} ${BOARD_NAME} ${BUILD_TAG}
fi

if [ "${BUILD_KERNEL}" == "true" ]; then
	test -f ${OUT_DIR}/ramdisk.img && \
		make_android_bootimg \
			${KERNEL_IMG} \
			${DTB_IMG} \
			${OUT_DIR}/ramdisk.img \
			${OUT_DIR}/boot.img \
			2048 \
			"buildvariant=${BUILD_TAG}"
fi

post_process ${TARGET_SOC} \
	device/nexell/${BOARD_NAME}/partmap.txt \
	${RESULT_DIR} \
	${BL1_DIR}/bl1-${TARGET_SOC}/out \
	${TOP}/device/nexell/secure \
	${UBOOT_DIR} \
	${KERNEL_DIR}/arch/arm/boot \
	${KERNEL_DIR}/arch/arm/boot/dts \
	67108864 \
	${OUT_DIR} \
	zh_blackdragon \
	${DEVICE_DIR}/logo.bmp

make_ext4_recovery_image \
	${KERNEL_DIR}/arch/arm/boot/zImage \
	${KERNEL_DIR}/arch/arm/boot/dts/s5p4418-zh_blackdragon-rev00.dtb \
	${OUT_DIR}/ramdisk-recovery.img \
	67108864 \
	${RESULT_DIR}

ADDRESS=0x93c00000
if [ "${MEMSIZE}" == "2GB" ]; then
	ADDRESS=0x63c00000
elif [ "${MEMSIZE}" == "1GB" ]; then
	ADDRESS=0x83c00000
fi
gen_boot_usb_script_4418 nxp4330 ${ADDRESS} ${RESULT_DIR}

make_build_info ${RESULT_DIR}

# test -d ${DEVICE_DIR}/apk_install && install_zh_apk_sudo

cd ${DEVICE_DIR}
git checkout aosp_zh_blackdragon.mk
cd ${TOP}
