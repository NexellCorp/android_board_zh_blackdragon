#!/bin/bash

#set java environment
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH

project_os_svn_path=svn://192.168.0.194/repos1/os/customer/nxp4330_YiZhan
public_app_svn_path=svn://192.168.0.194/repos1/app/customer/nxp4330_YiZhan
platform_tool_svn_path=svn://192.168.0.194/repos1/public/nxp4330/sign_tool
project_os_out_name=os
project_app_out_name=project_app
project_out_name=nxp4330_YiZhan

#local_tools_path=/work/customer1/nxp4330/tools
platform_tool_out_name=signtools
svn_username=zh


echo "删除原项目产品目录"
cd /work/out1/
rm -rf ${project_out_name}

echo "创建项目产品目录"
mkdir -p ${project_out_name}

echo "切换到项目产品目录"
cd ${project_out_name}


chmod -R 777 ./
chown -R zhonghong:zhonghong ./


echo "更新tools"
svn export --force ${platform_tool_svn_path} ${platform_tool_out_name}/ --username ${svn_username}

echo "下载os 镜像"
svn export --force ${project_os_svn_path} ${project_os_out_name} --username ${svn_username}

echo "更新app数据"
svn export --force ${public_app_svn_path} ${project_app_out_name} --username ${svn_username}


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

	for f in `ls ${target_path}/system-priv-app/*.apk`
	do
		unzip -jo $f lib/armeabi/*.so -d ${target_path}/system-lib/
	done

	find ${target_path}/third-lib/ -name *.so | xargs -i cp {} ${target_path}/system-lib/
}


function copy_apk()
{
	src_dir=$1
	dest_dir=$2

	for f in `ls ${src_dir}/*.apk`
	do
		apk_name=${f##*/}
		apk_folder_name=${apk_name%%.apk}
		apk_dir=${dest_dir}/${apk_folder_name}
		
		mkdir $apk_dir
		chmod 755 $apk_dir
		cp $f $apk_dir
		chmod 644 $apk_dir/$apk_name

	done
}


function copy_bin()
{
	src_dir=$1
	dest_dir=$2
				
	for f in `ls ${src_dir}/*`
	do
		bin_name=${f##*/}
		cp $f $dest_dir
		chmod 755 $dest_dir/$bin_name
	done
}

echo "*****开始解压update.zip*******"
if [ ! -d "./update" ]; then
mkdir update
fi

if [ -f "os/update.zip" ]; then
unzip os/update.zip -d ./update
#sudo rm ./os/update.zip
fi
echo "*******update.zip解压完成********"


echo "将相关文件拷贝到指定路径"
echo "****cp project app ****"
get_apk_lib ${project_app_out_name}

copy_apk ./${project_app_out_name}/system-app ./update/system/app
copy_apk ./${project_app_out_name}/system-priv-app ./update/system/priv-app

cp ./${project_app_out_name}/system-lib/* ./update/system/lib/

echo "****cp project bin ****"
copy_bin ./${project_app_out_name}/system-bin ./update/system/bin

echo "cp others"
cp ./${project_app_out_name}/other/config.ini  ./update/system/
cp ./${project_app_out_name}/other/ring.mp3  ./update/system/


echo "删除原生应用及其相关lib"
rm -rf ./update/system/app/Camera2
rm -rf ./update/system/lib/libjni_jpegutil.so
rm -rf ./update/system/lib/libjni_tinyplanet.so
rm -rf ./update/system/app/Gallery2
rm -rf ./update/system/lib/libjni_eglfence.so
rm -rf ./update/system/lib/libjni_filtershow_filters.so
rm -rf ./update/system/lib/libjni_jpegstream.so


echo "已设置文件操作权限"
chmod 644 ./update/system/lib/*.so
chmod 644 ./update/system/config.ini
chmod 644 ./update/system/ring.mp3
chmod 755 ./update/system/bin/gocsdk


#echo "增加版本信息"
#sed -i "5a ro.build.zhonghongpackage=${versionName}" ./update/system/build.prop


echo "*******正在压缩update.zip******"
sync
cd ./update
zip -rm -q update.zip ./*
cd ../
echo "******生成update.zip完成*********"


echo "正在打包签名update.zip"
echo "****copy update.zip to sign****"
mv ./update/update.zip ./${platform_tool_out_name}/update.zip
chmod 777 -R ./${platform_tool_out_name}/
cd ./${platform_tool_out_name}/
./make-sign.sh update.zip update-signed.zip
rm -rf ./update.zip
mv ./update-signed.zip ./update.zip
cd ..


echo "已经成功创建产品输出文件夹"
Dir=`date +%Y%m%d`
mkdir $Dir

mv ./${platform_tool_out_name}/update.zip ./$Dir

echo "*****Successfully*****"
