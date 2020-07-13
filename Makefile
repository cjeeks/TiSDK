-include Rules.make

MAKE_JOBS ?= 1

all: linux arm-benchmarks am-sysinfo oprofile-example u-boot-spl linux-dtbs cryptodev sysfw-image ti-ipc jailhouse ti-img-rogue-driver oob-demo 
clean: linux_clean arm-benchmarks_clean am-sysinfo_clean oprofile-example_clean u-boot-spl_clean linux-dtbs_clean cryptodev_clean sysfw-image_clean ti-ipc_clean jailhouse_clean ti-img-rogue-driver_clean oob-demo_clean 
install: linux_install arm-benchmarks_install am-sysinfo_install oprofile-example_install u-boot-spl_install linux-dtbs_install cryptodev_install sysfw-image_install ti-ipc_install jailhouse_install ti-img-rogue-driver_install oob-demo_install 
# Kernel build targets
linux: linux-dtbs
	@echo =================================
	@echo     Building the Linux Kernel
	@echo =================================
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) $(DEFCONFIG)
	$(MAKE) -j $(MAKE_JOBS) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE)  Image
	$(MAKE) -j $(MAKE_JOBS) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) modules

linux_install: linux-dtbs_install
	@echo ===================================
	@echo     Installing the Linux Kernel
	@echo ===================================
	@if [ ! -d $(DESTDIR) ] ; then \
		echo "The extracted target filesystem directory doesn't exist."; \
		echo "Please run setup.sh in the SDK's root directory and then try again."; \
		exit 1; \
	fi
	install -d $(DESTDIR)/boot
	install $(LINUXKERNEL_INSTALL_DIR)/arch/arm64/boot/Image $(DESTDIR)/boot
	install $(LINUXKERNEL_INSTALL_DIR)/vmlinux $(DESTDIR)/boot
	install $(LINUXKERNEL_INSTALL_DIR)/System.map $(DESTDIR)/boot
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) INSTALL_MOD_PATH=$(DESTDIR) INSTALL_MOD_STRIP=$(INSTALL_MOD_STRIP) modules_install

linux_clean:
	@echo =================================
	@echo     Cleaning the Linux Kernel
	@echo =================================
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) mrproper
# arm-benchmarks build targets
arm-benchmarks:
	@echo =============================
	@echo    Building ARM Benchmarks
	@echo =============================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*arm-benchmarks*"`; make CC="$(CC)"

arm-benchmarks_clean:
	@echo =============================
	@echo    Cleaning ARM Benchmarks
	@echo =============================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*arm-benchmarks*"`; make clean

arm-benchmarks_install:
	@echo ==============================================
	@echo   Installing ARM Benchmarks - Release version
	@echo ==============================================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*arm-benchmarks*"`; make install

arm-benchmarks_install_debug:
	@echo ============================================
	@echo   Installing ARM Benchmarks - Debug Version
	@echo ============================================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*arm-benchmarks*"`; make install_debug
# am-sysinfo build targets
am-sysinfo:
	@echo =============================
	@echo    Building AM Sysinfo
	@echo =============================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*am-sysinfo*"`; make CC="$(CC)"

am-sysinfo_clean:
	@echo =============================
	@echo    Cleaning AM Sysinfo
	@echo =============================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*am-sysinfo*"`; make clean

am-sysinfo_install:
	@echo ===============================================
	@echo     Installing AM Sysinfo - Release version
	@echo ===============================================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*am-sysinfo*"`; make install

am-sysinfo_install_debug:
	@echo =============================================
	@echo     Installing AM Sysinfo - Debug version
	@echo =============================================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*am-sysinfo*"`; make install_debug
# oprofile-example build targets
oprofile-example:
	@echo =============================
	@echo    Building OProfile Example
	@echo =============================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*oprofile-example*"`; make CC="$(CC)"

oprofile-example_clean:
	@echo =============================
	@echo    Cleaning OProfile Example
	@echo =============================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*oprofile-example*"`; make clean

oprofile-example_install:
	@echo =============================================
	@echo     Installing OProfile Example - Debug version
	@echo =============================================
	@cd example-applications; cd `find . -maxdepth 1 -type d -name "*oprofile-example*"`; make install

# u-boot build targets
u-boot-spl: u-boot
u-boot-spl_clean: u-boot_clean
u-boot-spl_install: u-boot_install

UBOOT_A53_BUILD_DIR=$(TI_SDK_PATH)/board-support/u-boot_build/a53
UBOOT_R5_BUILD_DIR=$(TI_SDK_PATH)/board-support/u-boot_build/r5

UBOOT_ATF=$(TI_SDK_PATH)/board-support/prebuilt-images/bl31.bin
UBOOT_TEE=$(TI_SDK_PATH)/board-support/prebuilt-images/bl32.bin
UBOOT_SYSFW=$(TI_SDK_PATH)/board-support/prebuilt-images/sysfw.bin

u-boot: u-boot-a53 u-boot-r5
u-boot_clean: u-boot-a53_clean u-boot-r5_clean

u-boot-a53:
	@echo ===================================
	@echo    Building U-boot for A53
	@echo ===================================
	$(MAKE) -j $(MAKE_JOBS) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE) \
		 $(UBOOT_MACHINE) O=$(UBOOT_A53_BUILD_DIR)
	$(MAKE) -j $(MAKE_JOBS) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE) \
		CONFIG_MKIMAGE_DTC_PATH=$(UBOOT_A53_BUILD_DIR)/scripts/dtc/dtc \
		ATF=$(UBOOT_ATF) TEE=$(UBOOT_TEE) \
		O=$(UBOOT_A53_BUILD_DIR)

u-boot-a53_clean:
	@echo ===================================
	@echo    Cleaining U-boot for A53
	@echo ===================================
	$(MAKE) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE) \
		O=$(UBOOT_A53_BUILD_DIR) distclean
	@rm -rf $(UBOOT_A53_BUILD_DIR)


u-boot-r5:
	@echo ===================================
	@echo    Building U-boot for R5
	@echo ===================================
	$(MAKE) -j $(MAKE_JOBS) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE_ARMV7) \
		 $(UBOOT_MACHINE_R5) O=$(UBOOT_R5_BUILD_DIR)
	$(MAKE) -j $(MAKE_JOBS) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE_ARMV7) \
		O=$(UBOOT_R5_BUILD_DIR)

u-boot-r5_clean:
	@echo ===================================
	@echo    Cleaining U-boot for R5
	@echo ===================================
	$(MAKE) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE_ARMV7) \
		O=$(UBOOT_R5_BUILD_DIR) distclean
	@rm -rf $(UBOOT_R5_BUILD_DIR)

u-boot_install:
	@echo ===================================
	@echo    Installing U-boot
	@echo ===================================
	@echo "Nothing to do"

# Kernel DTB build targets
linux-dtbs:
	@echo =====================================
	@echo     Building the Linux Kernel DTBs
	@echo =====================================
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) $(DEFCONFIG)
	@for DTB in      ti/k3-j721e-common-proc-board.dtb     ti/k3-j721e-proc-board-tps65917.dtb     ti/k3-j721e-common-proc-board-infotainment.dtbo     ti/k3-j721e-pcie-backplane.dtbo     ti/k3-j721e-common-proc-board-jailhouse.dtbo  	ti/k3-j721e-vision-apps.dtbo 	ti/k3-j721e-pcie-backplane.dtbo ; do \
		$(MAKE) -j $(MAKE_JOBS) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE) $$DTB; \
	done

linux-dtbs_install:
	@echo =======================================
	@echo     Installing the Linux Kernel DTBs
	@echo =======================================
	@if [ ! -d $(DESTDIR) ] ; then \
		echo "The extracted target filesystem directory doesn't exist."; \
		echo "Please run setup.sh in the SDK's root directory and then try again."; \
		exit 1; \
	fi
	install -d $(DESTDIR)/boot
	@for DTB in      ti/k3-j721e-common-proc-board.dtb     ti/k3-j721e-proc-board-tps65917.dtb     ti/k3-j721e-common-proc-board-infotainment.dtbo     ti/k3-j721e-pcie-backplane.dtbo     ti/k3-j721e-common-proc-board-jailhouse.dtbo  	ti/k3-j721e-vision-apps.dtbo 	ti/k3-j721e-pcie-backplane.dtbo ; do \
		install -m 0644 $(LINUXKERNEL_INSTALL_DIR)/arch/arm64/boot/dts/$$DTB $(DESTDIR)/boot/; \
	done

linux-dtbs_clean:
	@echo =======================================
	@echo     Cleaning the Linux Kernel DTBs
	@echo =======================================
	@echo "Nothing to do"

cryptodev: linux
	@echo ================================
	@echo      Building cryptodev-linux
	@echo ================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -type d -name "cryptodev*"`; \
	make ARCH=arm64 KERNEL_DIR=$(LINUXKERNEL_INSTALL_DIR)

cryptodev_clean:
	@echo ================================
	@echo      Cleaning cryptodev-linux
	@echo ================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -type d -name "cryptodev*"`; \
	make ARCH=arm64 KERNEL_DIR=$(LINUXKERNEL_INSTALL_DIR) clean

cryptodev_install:
	@echo ================================
	@echo      Installing cryptodev-linux
	@echo ================================
	@if [ ! -d $(DESTDIR) ] ; then \
		echo "The extracted target filesystem directory doesn't exist."; \
		echo "Please run setup.sh in the SDK's root directory and then try again."; \
		exit 1; \
	fi
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -type d -name "cryptodev*"`; \
	make ARCH=arm64  KERNEL_DIR=$(LINUXKERNEL_INSTALL_DIR)  INSTALL_MOD_PATH=$(DESTDIR) PREFIX=$(SDK_PATH_TARGET) INSTALL_MOD_STRIP=$(INSTALL_MOD_STRIP) install
# Define the following to support multple platforms
PLATFORM_TYPE_$(PLATFORM) = gp
PLATFORM_TYPE_am65xx-hs-evm = hs
PLATFORM_TYPE_j7-hs-evm = hs
PLATFORM_TYPE = $(PLATFORM_TYPE_$(PLATFORM))

SYSFW_CONFIG = evm

SYSFW_SOC_$(PLATFORM) = NULL
SYSFW_SOC_am65xx-evm = am65x
SYSFW_SOC_am65xx-hs-evm = am65x
SYSFW_SOC_j7-evm = j721e
SYSFW_SOC_j7-hs-evm = j721e
SYSFW_SOC = $(SYSFW_SOC_$(PLATFORM))

SYSFW_PREFIX = ti-sci-firmware

SYSFW_BASE = $(SYSFW_PREFIX)-$(SYSFW_SOC)-$(PLATFORM_TYPE)

SYSFW_MAKEARGS_common = SYSFW_DL_URL="" SYSFW_HS_DL_URL="" SYSFW_HS_INNER_CERT_DL_URL="" \
                        SYSFW_PATH=$(TI_SDK_PATH)/board-support/prebuilt-images/$(SYSFW_BASE).bin \
                        SOC=$(SYSFW_SOC) CONFIG=$(SYSFW_CONFIG)

SYSFW_MAKEARGS_gp = 
SYSFW_MAKEARGS_hs = HS=1 SYSFW_HS_PATH=$(TI_SDK_PATH)/board-support/prebuilt-images/$(SYSFW_BASE)-enc.bin \
                    SYSFW_HS_INNER_CERT_PATH=$(TI_SDK_PATH)/board-support/prebuilt-images/$(SYSFW_BASE)-cert.bin

SYSFW_MAKEARGS = $(SYSFW_MAKEARGS_common) $(SYSFW_MAKEARGS_$(PLATFORM_TYPE))

# Depend on linux-dtbs for the dtc utility
sysfw-image: linux-dtbs
	@echo =============================
	@echo    Building SYSFW Image
	@echo =============================
	@cd board-support; cd `find . -maxdepth 1 -type d -name "*system-firmware-image*"`; \
		make $(SYSFW_MAKEARGS) CROSS_COMPILE=$(CROSS_COMPILE_ARMV7) PATH=$(PATH):$(LINUXKERNEL_INSTALL_DIR)/scripts/dtc

sysfw-image_clean:
	@echo =============================
	@echo    Cleaning SYSFW Image
	@echo =============================
	@cd board-support; cd `find . -maxdepth 1 -type d -name "*system-firmware-image*"`; make clean

sysfw-image_install:
	@echo =============================
	@echo   Installing SYSFW Image
	@echo =============================
	@echo "Nothing to do"
TISDK_VERSION=live

PRSDK_VERSION=$(shell echo $(TISDK_VERSION) | sed -e 's|^0||' -e 's|\.|_|g')
PRSDK_PLATFORM=$(shell echo $(PLATFORM) | sed -e 's|-evm$$||' | sed -e 's|-lcdk$$||')

ifneq ($(TI_RTOS_PATH),)
  TI_IPC_TARGETS = ti-ipc-linux

  TI_RTOS_PATH_ABS := $(realpath $(TI_RTOS_PATH))

  TI_PRSDK_PATH=$(TI_RTOS_PATH_ABS)/processor_sdk_rtos_$(PRSDK_PLATFORM)_$(PRSDK_VERSION)
  SDK_INSTALL_PATH=$(TI_RTOS_PATH_ABS)
  include $(TI_PRSDK_PATH)/Rules.make

  IPC_TOOLS_PATHS=ti.targets.arm.elf.R5F=$(TOOLCHAIN_PATH_R5)

else
  TI_IPC_TARGETS = ti-ipc-rtos-missing
endif

TI_IPC_CLEAN = $(addsuffix _clean, $(TI_IPC_TARGETS))
TI_IPC_INSTALL = $(addsuffix _install, $(TI_IPC_TARGETS))

ti-ipc-rtos-missing ti-ipc-rtos-missing_clean ti-ipc-rtos-missing_install:
	@echo
	@echo ===========================================================
	@echo     If you wish to build IPC, please install
	@echo     Processor SDK RTOS $(TISDK_VERSION) for $(PLATFORM)
	@echo     and set TI_RTOS_PATH in Rules.make
	@echo ===========================================================

ti-ipc-rtos-path-check:
	@if [ ! -d "$(TI_PRSDK_PATH)" ]; \
	then \
		echo; \
		echo "Error: TI_RTOS_PATH ($(TI_RTOS_PATH_ABS)) does not contain"; \
		echo "       the corresponding Processor SDK RTOS release!"; \
		echo; \
		echo "Please install Processor SDK RTOS $(TISDK_VERSION) for $(PLATFORM)."; \
		exit 1; \
	fi

ti-ipc: $(TI_IPC_TARGETS)

ti-ipc_clean: $(TI_IPC_CLEAN)

ti-ipc_install: $(TI_IPC_INSTALL)

ti-ipc-linux-config: ti-ipc-rtos-path-check
	@echo =================================
	@echo     Configuring IPC
	@echo =================================
	. $(ENV_SETUP); \
	cd $(IPC_INSTALL_PATH); \
	./configure $${CONFIGURE_FLAGS} \
		CC=$${TOOLCHAIN_PREFIX}gcc \
		--prefix=/usr \
		PLATFORM=$(IPC_PLATFORM) \
		KERNEL_INSTALL_DIR=$(LINUXKERNEL_INSTALL_DIR)


ti-ipc-linux: ti-ipc-rtos-path-check linux ti-ipc-linux-config
	@echo =================================
	@echo     Building IPC
	@echo =================================
	. $(ENV_SETUP); \
	$(MAKE) -j $(MAKE_JOBS) -C $(IPC_INSTALL_PATH)

ti-ipc-linux_clean: ti-ipc-rtos-path-check ti-ipc-linux-config
	@echo =================================
	@echo     Cleaning IPC
	@echo =================================
	. $(ENV_SETUP); \
	$(MAKE) -j $(MAKE_JOBS) -C $(IPC_INSTALL_PATH) clean

ti-ipc-linux_install: ti-ipc-rtos-path-check ti-ipc-linux
	@echo =================================
	@echo     Installing IPC
	@echo =================================
	@if [ ! -d $(DESTDIR) ] ; then \
		echo "The extracted target filesystem directory doesn't exist."; \
		echo "Please run setup.sh in the SDK's root directory and then try again."; \
		exit 1; \
	fi
	. $(ENV_SETUP); \
	$(MAKE) -j $(MAKE_JOBS) -C $(IPC_INSTALL_PATH) install DESTDIR=$(DESTDIR)

ti-ipc-linux-examples: ti-ipc-rtos-path-check
	@echo =================================
	@echo     Building the IPC Examples
	@echo =================================
	$(MAKE) -j $(MAKE_JOBS) -C $${IPC_INSTALL_PATH}/examples \
		HOSTOS="linux" \
		PLATFORM="$(IPC_PLATFORM)" \
		KERNEL_INSTALL_DIR="$(LINUXKERNEL_INSTALL_DIR)" \
		XDC_INSTALL_DIR="$(XDC_INSTALL_PATH)" \
		PDK_INSTALL_DIR="$(PDK_INSTALL_PATH)/.." \
		BIOS_INSTALL_DIR="$(BIOS_INSTALL_PATH)" \
		IPC_INSTALL_DIR="$(IPC_INSTALL_PATH)" \
		TOOLCHAIN_LONGNAME=$${TOOLCHAIN_SYS} \
		TOOLCHAIN_INSTALL_DIR=$${SDK_PATH_NATIVE}/usr \
		TOOLCHAIN_PREFIX=$(CROSS_COMPILE) \
		LINUX_SYSROOT_DIR=$(SDK_PATH_TARGET) \
		$(IPC_TOOLS_PATHS)

ti-ipc-linux-examples_install: ti-ipc-rtos-path-check ti-ipc-linux-examples
	@echo =================================
	@echo     Installing the IPC Examples
	@echo =================================
	@if [ ! -d $(DESTDIR) ] ; then \
		echo "The extracted target filesystem directory doesn't exist."; \
		echo "Please run setup.sh in the SDK's root directory and then try again."; \
		exit 1; \
	fi
	$(MAKE) -j $(MAKE_JOBS) -C $${IPC_INSTALL_PATH}/examples install \
		HOSTOS="linux" \
		PLATFORM="$(IPC_PLATFORM)" \
		EXEC_DIR="$(EXEC_DIR)"

ti-ipc-linux-examples_clean: ti-ipc-rtos-path-check
	@echo =================================
	@echo     Cleaning the IPC Examples
	@echo =================================
	. $(ENV_SETUP); \
	$(MAKE) -j $(MAKE_JOBS) -C $${IPC_INSTALL_PATH}/examples clean \
		HOSTOS="linux" \
		PLATFORM="$(IPC_PLATFORM)" \
		KERNEL_INSTALL_DIR="$(LINUXKERNEL_INSTALL_DIR)" \
		XDC_INSTALL_DIR="$(XDC_INSTALL_PATH)" \
		BIOS_INSTALL_DIR="$(BIOS_INSTALL_PATH)" \
		IPC_INSTALL_DIR="$(IPC_INSTALL_PATH)" \
		TOOLCHAIN_LONGNAME=$${TOOLCHAIN_SYS} \
		TOOLCHAIN_INSTALL_DIR=$${SDK_PATH_NATIVE}/usr \
		TOOLCHAIN_PREFIX=$(CROSS_COMPILE) \
		LINUX_SYSROOT_DIR=$(SDK_PATH_TARGET) \
		$(IPC_TOOLS_PATHS)

# jailhouse module
JH_ARCH = "arm64"
JH_PLATFORM = "k3"

jailhouse_config:
	@echo =====================================
	@echo      Configuring jailhouse
	@echo =====================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -name "jailhouse*" -type d`; \
	cp -v ./ci/jailhouse-config-$(JH_PLATFORM).h ./include/jailhouse/config.h

jailhouse: linux jailhouse_config
	@echo =====================================
	@echo      Building jailhouse
	@echo =====================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -name "jailhouse*" -type d`; \
	make ARCH=$(JH_ARCH) KDIR=${LINUXKERNEL_INSTALL_DIR}

jailhouse_clean:
	@echo =====================================
	@echo      Cleaning jailhouse
	@echo =====================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -name "jailhouse*" -type d`; \
	make ARCH=$(JH_ARCH) KDIR=${LINUXKERNEL_INSTALL_DIR} clean

jailhouse_distclean: jailhouse_clean
	@echo =====================================
	@echo      Distclean jailhouse
	@echo =====================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -name "jailhouse*" -type d`; \
	rm -vf ./hypervisor/include/jailhouse/config.h

jailhouse_install:
	@echo ================================
	@echo      Installing jailhouse
	@echo ================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -name "jailhouse*" -type d`; \
	make ARCH=$(JH_ARCH) KDIR=${LINUXKERNEL_INSTALL_DIR} DESTDIR=$(DESTDIR) INSTALL_MOD_STRIP=$(INSTALL_MOD_STRIP) prefix=/usr install


# ti-img-rogue-driver
ti-img-rogue-driver: linux
	@echo =====================================
	@echo     Building ti-img-rogue-driver
	@echo =====================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -type d -name "ti-img-rogue-driver*" -type d`; \
	make ARCH=arm64 KERNELDIR=${LINUXKERNEL_INSTALL_DIR} RGX_BVNC="22.104.208.318" BUILD=release PVR_BUILD_DIR=j721e_linux WINDOW_SYSTEM=wayland

ti-img-rogue-driver_clean:
	@echo ====================================
	@echo     Cleaning ti-img-rogue-driver
	@echo ====================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -type d -name "ti-img-rogue-driver*" -type d`; \
	make ARCH=arm64 KERNELDIR=${LINUXKERNEL_INSTALL_DIR} RGX_BVNC="22.104.208.318" BUILD=release PVR_BUILD_DIR=j721e_linux WINDOW_SYSTEM=wayland clean

ti-img-rogue-driver_install:
	@echo ====================================
	@echo     Installing ti-img-rogue-driver
	@echo ====================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -type d -name "ti-img-rogue-driver*" -type d`; \
	cd binary_j721e_linux_wayland_release/target_aarch64/kbuild; \
	make -C ${LINUXKERNEL_INSTALL_DIR} INSTALL_MOD_PATH=${DESTDIR} INSTALL_MOD_STRIP=${INSTALL_MOD_STRIP} M=`pwd` modules_install

linux_install: oob-demo_install

oob-demo:


oob-demo_clean:


oob-demo_install:
	@echo =============================
	@echo Updating oob-demo wallpaper
	@echo =============================
	sed -i 's%background-image.*%background-image=/usr/share/demo/j7-evm-p0-wallpaper.jpg%' $(DESTDIR)/etc/weston.ini

