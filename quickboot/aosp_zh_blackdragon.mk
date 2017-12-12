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

# Inherit the full_base and device configurations
$(call inherit-product, device/nexell/quickboot/component.mk)

PRODUCT_NAME := aosp_zh_blackdragon
PRODUCT_DEVICE := zh_blackdragon
PRODUCT_BRAND := Android
PRODUCT_MODEL := AOSP on zh_blackdragon
PRODUCT_MANUFACTURER := NEXELL

PRODUCT_COPY_FILES += \
	device/nexell/kernel/kernel-4.4.x/arch/arm/boot/zImage:kernel

PRODUCT_COPY_FILES += \
	device/nexell/kernel/kernel-4.4.x/arch/arm/boot/dts/s5p4418-zh_blackdragon-rev00.dtb:2ndbootloader

PRODUCT_COPY_FILES += \
	device/nexell/zh_blackdragon/fstab.zh_blackdragon:root/fstab.zh_blackdragon

PRODUCT_PROPERTY_OVERRIDES += \
	ro.product.first_api_level=21

# Disable bluetooth because zh_blackdragon does not use bluetooth source
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_bluetooth=true

# Disable other feature no needed in avn board
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_serial=true
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_samplingprof=true
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_consumerir=true
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_rtt=true
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_vrmanager=true

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_noncore=true
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_cameraservice=true
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_mediaproj=true
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_searchmanager=true
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_trustmanager=true
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_textservices=true
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_systemui=true

$(call inherit-product, device/nexell/zh_blackdragon/device.mk)
