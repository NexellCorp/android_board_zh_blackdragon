#!/bin/bash

TOP=`pwd`

project_app_out_name=${TOP}/apk_install

local_tools_path=${TOP}/out/host/linux-x86

function get_apk_lib()
{
	target_path=$1

	if [ ! -d "./${target_path}/system-lib" ]; then
		mkdir ${target_path}/system-lib
	fi

	for f in `ls ${target_path}/system-app/*.apk`
	do
		unzip -jo $f lib/armeabi/*.so -d ${target_path}/system-lib/
	done

	#for f in `ls ${target_path}/system-priv-app/*.apk`
	#do
	#	unzip -jo $f lib/armeabi/*.so -d ${target_path}/system-lib/
	#done

	# find ${target_path}/third-lib/ -name *.so | xargs -i cp {} ${target_path}/system-lib/
}


function copy_apk()
{
	src_dir=$1
	dest_dir=$2

	echo "===========copy_apk============="
	echo "src_dir=${src_dir}"
	echo "dest_dir=${dest_dir}"

	for f in `ls ${src_dir}/*.apk`
	do
		apk_name=${f##*/}
		apk_folder_name=${apk_name%%.apk}
		apk_dir=${dest_dir}/${apk_folder_name}
		
		mkdir $apk_dir
		chmod 755 $apk_dir
		cp -v $f $apk_dir
		chmod 644 $apk_dir/$apk_name
	done
}


function copy_bin()
{
	src_dir=$1
	dest_dir=$2
	echo "===========copy_bin============="
	echo "src_dir=${src_dir}"
	echo "dest_dir=${dest_dir}"

	for f in `ls ${src_dir}/*`
	do
		bin_name=${f##*/}
		cp $f $dest_dir
		chmod 755 $dest_dir/$bin_name
	done
}


echo "*****simg2img system.img*****"

pushd `pwd`
cd ${project_app_out_name}
	${local_tools_path}/bin/simg2img system.img raw_system.img

	echo ""
	echo ""
	echo "*****mount raw_system.img*****"
	mkdir raw_system
	mount -t ext4 -o loop raw_system.img raw_system/

	echo ""
	echo ""
	echo "****cp project app ****"
	get_apk_lib ${project_app_out_name}

	echo "ls -al ${project_app_out_name}/system-app/"
	ls -al ${project_app_out_name}/system-app/
	copy_apk ${project_app_out_name}/system-app ./raw_system/app

	#copy_apk ${project_app_out_name}/system-priv-app ./raw_system/priv-app

	echo "ls -al ${project_app_out_name}/system-lib/"
	ls -al ${project_app_out_name}/system-lib/
	cp -v ${project_app_out_name}/system-lib/* ./raw_system/lib/

	sync

	#echo ""
	#echo ""
	#echo "****cp project bin ****"
	#copy_bin ${project_app_out_name}/system-bin ./raw_system/bin

	#echo ""
	#echo ""
	#echo "cp others"
	#cp ${project_app_out_name}/other/config.ini  ./raw_system/
	#cp ${project_app_out_name}/other/ring.mp3  ./raw_system/

	echo ""
	echo "****remove apk"
	rm -rf ./raw_system/app/Camera2
	rm -rf ./raw_system/lib/libjni_jpegutil.so
	rm -rf ./raw_system/lib/libjni_tinyplanet.so
	rm -rf ./raw_system/app/Gallery2
	rm -rf ./raw_system/lib/libjni_eglfence.so
	rm -rf ./raw_system/lib/libjni_filtershow_filters.so
	rm -rf ./raw_system/lib/libjni_jpegstream.so

	echo ""
	echo "****change chmod for lib"
	chmod 644 ./raw_system/lib/*.so
	chmod 644 ./raw_system/config.ini
	chmod 644 ./raw_system/ring.mp3
	chmod 755 ./raw_system/bin/gocsdk

	echo ""
	echo "*****make_ext4fs system.img*****"
	export LD_LIBRARY_PATH=${local_tools_path}/lib:$LD_LIBRARY_PATH
	export LD_LIBRARY_PATH=${local_tools_path}/lib64:$LD_LIBRARY_PATH

	sync
	${local_tools_path}/bin/make_ext4fs -s -T -1 -S ${project_app_out_name}/../out/target/product/zh_dragon/root/file_contexts.bin -L system -l 2147483648 -a system new_system.img raw_system/

	umount raw_system/
	rm -rf raw_system/
	rm -rf system-lib/

	#Dir=`date +%Y%m%d`
	#mkdir $Dir

	rm raw_system.img
	#mv ./os/* ./$Dir
	#mv new_system.img ./$Dir/system.img

	echo "*****Successfully*****"
	echo ""
popd

