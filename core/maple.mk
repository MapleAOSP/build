ALL += camera* gps* gralloc* libF77blas libbluetooth_jni bluetooth.mapsapi bluetooth.default bluetooth.mapsapi libbt-brcm_stack
#DISABLE_ARM_MODE := libfs_mgr liblog libunwind libnetutils libziparchive libsync libusbhost libjnigraphics libstagefright_avc_common libmmcamera_interface pppd clatd libsoftkeymasterdevice sdcard logd mm-qcamera-app racoon libdiskconfig libmm-qcamera librmnetctl libjavacore camera.% libandroid_servers libmedia_jni librs_jni libhwui libandroidfw linker libgui $(ALL)
DISABLE_ANALYZER :=  libbluetooth_jni bluetooth.mapsapi bluetooth.default bluetooth.mapsapi libbt-brcm_stack audio.a2dp.default libbt-brcm_gki libbt-utils libbt-qcom_sbc_decoder libbt-brcm_bta libbt-brcm_stack libbt-vendor libbtprofile libbtdevice libbtcore bdt bdtest libbt-hci libosi ositests libbluetooth_jni net_test_osi net_test_device net_test_btcore net_bdtool net_hci bdAddrLoader libc_bionic $(ALL)
DISABLE_OPENMP := libc libc_tzcode libbluetooth_jni_32 *libblas libF77blas libdl libjni_latinime $(ALL)
DISABLE_O3 := libaudioflinger $(ALL)

# Clean local module flags
my_cflags :=  $(filter-out -Wall -Wextra -Weverything -Werror -Werror=% -g,$(my_cflags)) -g0 -Wno-error -w
my_cppflags :=  $(filter-out -Wall -Wextra -Weverything -Werror -Werror=% -g,$(my_cppflags)) -g0 -Wno-error -w

# Force ARM Instruction Set
ifndef LOCAL_IS_HOST_MODULE
  ifneq (1,$(words $(filter $(DISABLE_ARM_MODE),$(LOCAL_MODULE))))
    ifeq ($(TARGET_ARCH),arm)
      ifeq ($(LOCAL_ARM_MODE),)
#        LOCAL_ARM_MODE := arm
#        my_cflags += -marm
#        my_cflags :=  $(filter-out -mthumb,$(my_cflags))
      endif
    endif
    ifeq ($(TARGET_ARCH),arm64)
      ifeq ($(LOCAL_ARM_MODE),)
        ifneq ($(TARGET_2ND_ARCH),)
#          LOCAL_ARM_MODE := arm
#          my_cflags += -marm
#          my_cflags :=  $(filter-out -mthumb,$(my_cflags))
        else
#          LOCAL_ARM_MODE := arm64
#          my_cflags :=  $(filter-out -mthumb,$(my_cflags))
        endif
      endif
    endif
  else
    LOCAL_ARM_MODE := thumb
#    my_cflags += -mthumb
#    my_cflags :=  $(filter-out -marm,$(my_cflags))
  endif
endif

# IPA Optimizations
ifndef LOCAL_IS_HOST_MODULE
  ifeq (,$(filter true,$(my_clang)))
    ifneq (1,$(words $(filter $(DISABLE_ANALYZER),$(LOCAL_MODULE))))
      my_cflags += -fipa-sra -fipa-pta -fipa-cp -fipa-cp-clone
    endif
  else
    ifneq (1,$(words $(filter $(DISABLE_ANALYZER),$(LOCAL_MODULE))))
      my_cflags += -analyze -analyzer-purge
    endif
  endif
endif

# OpenMP
ifndef LOCAL_IS_HOST_MODULE
  ifneq (1,$(words $(filter $(DISABLE_OPENMP),$(LOCAL_MODULE))))
    my_cflags += -lgomp -lgcc -fopenmp
    my_ldflags += -fopenmp
  endif
endif

# Optimization Level 3
ifndef LOCAL_IS_HOST_MODULE
  ifeq (,$(filter true,$(my_clang)))
    ifeq ($(filter $(DISABLE_O3), $(LOCAL_MODULE)),)
      my_cflags += -O3
    endif
  endif
endif
