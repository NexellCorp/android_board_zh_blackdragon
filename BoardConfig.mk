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

TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a9

ENABLE_CPUSETS := true
ENABLE_SCHEDBOOST := true

# TODO: afterwards fixup below setting
TARGET_NO_BOOTLOADER := false
TARGET_NO_KERNEL := false
TARGET_NO_RADIOIMAGE := true
TARGET_NO_RECOVERY := false

TARGET_BOARD_PLATFORM := s5p4418
TARGET_BOOTLOADER_BOARD_NAME := zh_blackdragon
TARGET_BOARD_INFO_FILE := device/nexell/zh_blackdragon/board-info.txt

# recovery
TARGET_RELEASETOOLS_EXTENSIONS := device/nexell/zh_blackdragon
TARGET_RECOVERY_UPDATER_LIBS := librecovery_updater_nexell
TARGET_RECOVERY_FSTAB := device/nexell/zh_blackdragon/recovery.fstab

BOARD_USES_GENERIC_AUDIO := false
BOARD_USES_ALSA_AUDIO := false

BOARD_EGL_CFG := device/nexell/zh_blackdragon/egl.cfg
USE_OPENGL_RENDERER := true
TARGET_USES_ION := true
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3
TARGET_RUNNING_WITHOUT_SYNC_FRAMEWORK := true
# see surfaceflinger
MAX_VIRTUAL_DISPLAY_DIMENSION := 2048

# hwcomposer
BOARD_USES_NX_HWCOMPOSER := true

# Enable dex-preoptimization to speed up first boot sequence
ifeq ($(HOST_OS),linux)
  ifneq ($(TARGET_BUILD_VARIANT),eng)
    ifeq ($(WITH_DEXPREOPT),)
      WITH_DEXPREOPT := true
      WITH_DEXPREOPT_PIC := true
    endif
  endif
endif

# bluetooth
BOARD_HAVE_BLUETOOTH := false

#wifi
BOARD_WIFI_VENDOR := realtek
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_rtl
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_rtl
BOARD_WLAN_DEVICE := rtl8189fs
WIFI_DRIVER_MODULE_NAME := "wlan"
WIFI_DRIVER_MODULE_PATH := "/system/vendor/realtek/wlan.ko"
WIFI_DRIVER_MODULE_ARG := "ifname=wlan0 if2name=p2p0"
WIFI_FIRMWARE_LOADER := "rtw_fwloader"
WIFI_DRIVER_FW_PATH_STA := "STA"
WIFI_DRIVER_FW_PATH_AP := "AP"
WIFI_DRIVER_FW_PATH_P2P := "P2P"
WIFI_DRIVER_FW_PATH_PARAM := "/dev/null"

BOARD_CHARGER_ENABLE_SUSPEND := false

# ffmpeg libraries
EN_FFMPEG_EXTRACTOR := true
EN_FFMPEG_AUDIO_DEC := true

# sepolicy
BOARD_SEPOLICY_DIRS += \
	device/nexell/zh_blackdragon/sepolicy

# filesystems
TARGET_USERIMAGES_USE_EXT4 := true
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2147483648
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_CACHEIMAGE_PARTITION_SIZE := 536870912
BOARD_USERDATAIMAGE_PARTITION_SIZE := 3374645248
BOARD_FLASH_BLOCK_SIZE := 131072

# boot image layout
BOARD_KERNEL_PAGESIZE := 2048
TARGET_BOOTLOADER_IS_2ND := true

TARGET_USES_AOSP := true

USE_CLANG_PLATFORM_BUILD := true

TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
