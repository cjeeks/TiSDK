#platform
PLATFORM=j7-evm

#defconfig
DEFCONFIG=tisdk_j7-evm_defconfig

#Architecture
ARCH=aarch64

#u-boot machine
UBOOT_MACHINE=j721e_evm_a72_config

#Points to the root of the TI SDK
export TI_SDK_PATH=__SDK__INSTALL_DIR__

#root of the target file system for installing applications
DESTDIR ?=__DESTDIR__

#Points to the root of the Linux libraries and headers matching the
#demo file system.
export LINUX_DEVKIT_PATH=$(TI_SDK_PATH)/linux-devkit

#Cross compiler prefix
export CROSS_COMPILE=$(LINUX_DEVKIT_PATH)/sysroots/x86_64-arago-linux/usr/bin/aarch64-none-linux-gnu-

#Default CC value to be used when cross compiling.  This is so that the
#GNU Make default of "cc" is not used to point to the host compiler
export CC=$(CROSS_COMPILE)gcc --sysroot=$(SDK_PATH_TARGET)

#Location of environment-setup file
export ENV_SETUP=$(LINUX_DEVKIT_PATH)/environment-setup

#The directory that points to the SDK kernel source tree
LINUXKERNEL_INSTALL_DIR=$(TI_SDK_PATH)/board-support/__KERNEL_NAME__

CFLAGS=

#Strip modules when installing to conserve disk space
INSTALL_MOD_STRIP=1

SDK_PATH_TARGET=$(TI_SDK_PATH)/__SDK_PATH_TARGET__

# Set EXEC_DIR to install example binaries.
# This will be configured with the setup.sh script.
EXEC_DIR ?=__EXEC_DIR__

# Add CROSS_COMPILE and UBOOT_MACHINE for the R5
export CROSS_COMPILE_ARMV7=$(LINUX_DEVKIT_PATH)/sysroots/x86_64-arago-linux/usr/bin/arm-linux-gnueabihf-
UBOOT_MACHINE_R5=j721e_evm_r5_config
