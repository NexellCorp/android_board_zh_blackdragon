#
# Copyright (C) 2015 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

PRODUCT_SHIPPING_API_LEVEL := 25

PRODUCT_COPY_FILES += \
	device/nexell/zh_blackdragon/init.zh_blackdragon.rc:root/init.zh_blackdragon.rc \
	device/nexell/zh_blackdragon/init.zh_blackdragon.usb.rc:root/init.zh_blackdragon.usb.rc \
	device/nexell/zh_blackdragon/fstab.zh_blackdragon:root/fstab.zh_blackdragon \
	device/nexell/zh_blackdragon/ueventd.zh_blackdragon.rc:root/ueventd.zh_blackdragon.rc \
	device/nexell/zh_blackdragon/init.recovery.zh_blackdragon.rc:root/init.recovery.zh_blackdragon.rc

PRODUCT_COPY_FILES += \
	frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
	frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:system/etc/media_codecs_google_video.xml

# audio
PRODUCT_COPY_FILES += \
	frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:system/etc/a2dp_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:system/etc/r_submix_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:system/etc/usb_audio_policy_configuration.xml \
	frameworks/av/services/audiopolicy/config/default_volume_tables.xml:system/etc/default_volume_tables.xml

PRODUCT_COPY_FILES += \
	device/nexell/zh_blackdragon/audio/tiny_hw.zh_blackdragon.xml:system/etc/tiny_hw.zh_blackdragon.xml \
	device/nexell/zh_blackdragon/audio/audio_policy.conf:system/etc/audio_policy.conf

PRODUCT_COPY_FILES += \
	frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
	device/nexell/zh_blackdragon/media_codecs.xml:system/etc/media_codecs.xml \
	device/nexell/zh_blackdragon/media_profiles.xml:system/etc/media_profiles.xml

# ffmpeg libraries
EN_FFMPEG_EXTRACTOR := true
EN_FFMPEG_AUDIO_DEC := true

ifeq ($(EN_FFMPEG_EXTRACTOR),true)

PRODUCT_COPY_FILES += \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavcodec.so:system/lib/libavcodec.so    \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavcodec.so.55:system/lib/libavcodec.so.55    \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavcodec.so.55.39.101:system/lib/libavcodec.so.55.39.101    \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavdevice.so:system/lib/libavdevice.so  \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavdevice.so.55:system/lib/libavdevice.so.55  \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavdevice.so.55.5.100:system/lib/libavdevice.so.55.5.100  \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavfilter.so:system/lib/libavfilter.so  \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavfilter.so.3:system/lib/libavfilter.so.3  \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavfilter.so.3.90.100:system/lib/libavfilter.so.3.90.100  \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavformat.so:system/lib/libavformat.so  \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavformat.so.55:system/lib/libavformat.so.55  \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavformat.so.55.19.104:system/lib/libavformat.so.55.19.104  \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavresample.so:system/lib/libavresample.so      \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavresample.so.1:system/lib/libavresample.so.1      \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavresample.so.1.1.0:system/lib/libavresample.so.1.1.0      \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavutil.so:system/lib/libavutil.so      \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavutil.so.52:system/lib/libavutil.so.52      \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libavutil.so.52.48.101:system/lib/libavutil.so.52.48.101      \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libswresample.so:system/lib/libswresample.so \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libswresample.so.0:system/lib/libswresample.so.0 \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libswresample.so.0.17.104:system/lib/libswresample.so.0.17.104 \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libswscale.so:system/lib/libswscale.so \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libswscale.so.2:system/lib/libswscale.so.2 \
	hardware/nexell/s5pxx18/omx/codec/ffmpeg/32bit/libs/libswscale.so.2.5.101:system/lib/libswscale.so.2.5.101

endif	#EN_FFMPEG_EXTRACTOR


# hardware features
PRODUCT_COPY_FILES += \
	device/nexell/zh_blackdragon/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.audio.low_latency.xml:system/etc/permissions/android.hardware.audio.low_latency.xml \
	frameworks/native/data/etc/android.hardware.faketouch.xml:system/etc/permissions/android.hardware.faketouch.xml

# LC44X_bt
PRODUCT_COPY_FILES += \
	device/nexell/zh_blackdragon/LC44X_bt_wifi/gocsdk:system/bin/gocsdk \
	device/nexell/zh_blackdragon/LC44X_bt_wifi/config.ini:system/config.ini \
	device/nexell/zh_blackdragon/LC44X_bt_wifi/ring.mp3:system/ring.mp3

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
        ro.kernel.android.bt=goc_serial

# wallpaper
PRODUCT_COPY_FILES += \
	device/nexell/zh_blackdragon/wallpaper:/data/system/users/0/wallpaper \
	device/nexell/zh_blackdragon/wallpaper_orig:/data/system/users/0/wallpaper_orig \
	device/nexell/zh_blackdragon/wallpaper_info.xml:/data/system/users/0/wallpaper_info.xml

# memtester
PRODUCT_COPY_FILES += \
	device/nexell/zh_blackdragon/memtester:/system/bin/memtester

# Recovery
PRODUCT_PACKAGES += \
	librecovery_updater_nexell

PRODUCT_TAGS += dalvik.gc.type-precise

PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_CONFIG += mdpi xlarge large
PRODUCT_AAPT_PREF_CONFIG := mdpi
PRODUCT_AAPT_PREBUILT_DPI := hdpi mdpi ldpi
PRODUCT_CHARACTERISTICS := tablet

# OpenGL ES API version: 2.0
PRODUCT_PROPERTY_OVERRIDES += \
	ro.opengles.version=131072

# density
PRODUCT_PROPERTY_OVERRIDES += \
	ro.sf.lcd_density=160

PRODUCT_PACKAGES += \
	audio.a2dp.default \
	audio.usb.default \
	audio.r_submix.default \
	tinyplay

# libion needed by gralloc, ogl
PRODUCT_PACKAGES += libion iontest

PRODUCT_PACKAGES += libdrm

# HAL
PRODUCT_PACKAGES += \
	gralloc.zh_blackdragon \
	libGLES_mali \
	hwcomposer.zh_blackdragon \
	audio.primary.zh_blackdragon \
	memtrack.zh_blackdragon \
	lights.zh_blackdragon

# tinyalsa
PRODUCT_PACKAGES += \
	libtinyalsa \
	tinyplay \
	tinycap \
	tinymix \
	tinypcminfo

PRODUCT_PACKAGES += fs_config_files

# omx
PRODUCT_PACKAGES += \
	libstagefrighthw \
	libnx_video_api \
	libNX_OMX_VIDEO_DECODER \
	libNX_OMX_Base \
	libNX_OMX_Core \
	libNX_OMX_Common

# stagefright FFMPEG compnents
ifeq ($(EN_FFMPEG_AUDIO_DEC),true)
PRODUCT_PACKAGES += libNX_OMX_AUDIO_DECODER_FFMPEG
endif

ifeq ($(EN_FFMPEG_EXTRACTOR),true)
PRODUCT_PACKAGES += libNX_FFMpegExtractor
endif

# zhong car related feature
PRODUCT_COPY_FILES += \
	device/nexell/zh_blackdragon/zhong_lib/libzhmcu.so:system/lib/libzhmcu.so \
	device/nexell/zh_blackdragon/mcuserver:system/bin/mcuserver \
	device/nexell/zh_blackdragon/zhong_lib/libmcuserverclient_jni.so:system/lib/libmcuserverclient_jni.so \
	device/nexell/zh_blackdragon/zhong_lib/libjsoncpp.so:system/lib/libjsoncpp.so

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
	ro.mcu.baudRate=2 \
	ro.kernel.android.mcu=ttyAMA2

DEVICE_PACKAGE_OVERLAYS := device/nexell/zh_blackdragon/overlay

# limit dex2oat threads to improve thermals
PRODUCT_PROPERTY_OVERRIDES += \
	dalvik.vm.boot-dex2oat-threads=4 \
	dalvik.vm.dex2oat-threads=4 \
	dalvik.vm.image-dex2oat-threads=4

PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapstartsize=16m \
    dalvik.vm.heapgrowthlimit=256m \
    dalvik.vm.heapsize=512m \
    dalvik.vm.heaptargetutilization=0.75 \
    dalvik.vm.heapminfree=512k \
    dalvik.vm.heapmaxfree=8m

# HWUI common settings
PRODUCT_PROPERTY_OVERRIDES += \
    ro.hwui.gradient_cache_size=1 \
    ro.hwui.drop_shadow_cache_size=6 \
    ro.hwui.r_buffer_cache_size=8 \
    ro.hwui.texture_cache_flushrate=0.4 \
    ro.hwui.text_small_cache_width=1024 \
    ro.hwui.text_small_cache_height=1024 \
    ro.hwui.text_large_cache_width=2048 \
    ro.hwui.text_large_cache_height=1024

#skip boot jars check
SKIP_BOOT_JARS_CHECK := true

# wifi
PRODUCT_PACKAGES += \
	libwpa_client \
	hostapd \
	wpa_supplicant \
	wpa_supplicant.conf

PRODUCT_PACKAGES += \
	rtw_fwloader

PRODUCT_COPY_FILES += \
	hardware/realtek/wlan/driver/rtl8189fs/wlan.ko:system/vendor/realtek/wlan.ko

PRODUCT_PROPERTY_OVERRIDES += \
	wifi.interface=wlan0

$(call inherit-product-if-exists, hardware/realtek/wlan/config/p2p_supplicant.mk)


# libfuse
PRODUCT_PACKAGES += \
	libfuse

# exfat
PRODUCT_PACKAGES += \
	libexfat \
	mount.exfat \
	mkfs.exfat \
	fsck.exfat

# ntfs
PRODUCT_PACKAGES += \
	libntfs-3g \
	mount.ntfs \
	fsck.ntfs \
	mkfs.ntfs

# mcuserver debug attribute
PRODUCT_PROPERTY_OVERRIDES += \
	sys.mcuserver.debug=false
