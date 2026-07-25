#! /usr/bin/env bash
#
# Copyright (C) 2013-2014 Zhang Rui <bbcallen@gmail.com>
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

# This script is based on projects below
# https://github.com/yixia/FFmpeg-Android
# http://git.videolan.org/?p=vlc-ports/android.git;a=summary

#--------------------
echo "===================="
echo "[*] check env $1"
echo "===================="
set -e


#--------------------
# common defines
FF_ARCH=$1
FF_BUILD_OPT=$2
echo "FF_ARCH=$FF_ARCH"
echo "FF_BUILD_OPT=$FF_BUILD_OPT"
if [ -z "$FF_ARCH" ]; then
    echo "You must specific an architecture 'arm, armv7a, x86, ...'."
    echo ""
    exit 1
fi


FF_BUILD_ROOT=`pwd`
FF_ANDROID_PLATFORM=
FF_TOOLCHAIN_ARCH=

FF_BUILD_NAME=
FF_SOURCE=
FF_CROSS_PREFIX=
FF_DEP_OPENSSL_INC=
FF_DEP_OPENSSL_LIB=

FF_DEP_LIBSOXR_INC=
FF_DEP_LIBSOXR_LIB=

FF_DEP_LIBSRT_INC=
FF_DEP_LIBSRT_LIB=

FF_CFG_FLAGS=

FF_EXTRA_CFLAGS=
FF_EXTRA_LDFLAGS=
FF_DEP_LIBS=

# FF_MODULE_DIRS="compat libavcodec libavfilter libavformat libavutil libswresample libswscale"
FF_MODULE_DIRS="compat libavdevice libavcodec libavfilter libavformat libavutil libswresample libswscale libpostproc libavresample"
FF_ASSEMBLER_SUB_DIRS=


#--------------------
echo ""
echo "--------------------"
echo "[*] make NDK standalone toolchain"
echo "--------------------"
. ./tools/do-detect-env.sh
FF_MAKE_TOOLCHAIN_FLAGS=$IJK_MAKE_TOOLCHAIN_FLAGS
FF_MAKE_FLAGS=$IJK_MAKE_FLAG
FF_GCC_VER=$IJK_GCC_VER
FF_GCC_64_VER=$IJK_GCC_64_VER


#----- armv7a begin -----
if [ "$FF_ARCH" = "armv7a" ]; then
    FF_TOOLCHAIN_ARCH=arm
    FF_ANDROID_PLATFORM=21
    FF_BUILD_NAME=ffmpeg-armv7a
    FF_BUILD_NAME_OPENSSL=openssl-armv7a
    FF_BUILD_NAME_LIBSOXR=libsoxr-armv7a
    FF_BUILD_NAME_LIBSRT=libsrt-armv7a
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=arm-linux-androideabi
    FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_VER}

    FF_CFG_FLAGS="$FF_CFG_FLAGS --arch=arm --cpu=cortex-a8"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-neon"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-thumb"

    FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS -march=armv7-a -mcpu=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=softfp -mthumb -funwind-tables"
    FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS -Wl,--fix-cortex-a8"

    FF_ASSEMBLER_SUB_DIRS="arm"

elif [ "$FF_ARCH" = "armv5" ]; then
    FF_TOOLCHAIN_ARCH=arm
    FF_ANDROID_PLATFORM=21

    FF_BUILD_NAME=ffmpeg-armv5
    FF_BUILD_NAME_OPENSSL=openssl-armv5
    FF_BUILD_NAME_LIBSOXR=libsoxr-armv5
    FF_BUILD_NAME_LIBSRT=libsrt-armv5
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=arm-linux-androideabi
    FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_VER}

    FF_CFG_FLAGS="$FF_CFG_FLAGS --arch=arm"

    FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS -march=armv5te -mtune=arm9tdmi -msoft-float"
    FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS"

    FF_ASSEMBLER_SUB_DIRS="arm"

elif [ "$FF_ARCH" = "x86" ]; then
    FF_TOOLCHAIN_ARCH=x86
    FF_ANDROID_PLATFORM=21

    FF_BUILD_NAME=ffmpeg-x86
    FF_BUILD_NAME_OPENSSL=openssl-x86
    FF_BUILD_NAME_LIBSOXR=libsoxr-x86
    FF_BUILD_NAME_LIBSRT=libsrt-x86
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=i686-linux-android
    FF_TOOLCHAIN_NAME=x86-${FF_GCC_VER}

    FF_CFG_FLAGS="$FF_CFG_FLAGS --arch=x86 --cpu=i686 --enable-yasm"

    FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS -march=atom -msse3 -ffast-math -mfpmath=sse"
    FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS"

    FF_ASSEMBLER_SUB_DIRS="x86"

elif [ "$FF_ARCH" = "x86_64" ]; then
    FF_TOOLCHAIN_ARCH=x86_64
    FF_ANDROID_PLATFORM=21

    FF_BUILD_NAME=ffmpeg-x86_64
    FF_BUILD_NAME_OPENSSL=openssl-x86_64
    FF_BUILD_NAME_LIBSOXR=libsoxr-x86_64
    FF_BUILD_NAME_LIBSRT=libsrt-x86_64
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=x86_64-linux-android
    FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_64_VER}

    FF_CFG_FLAGS="$FF_CFG_FLAGS --arch=x86_64 --enable-yasm"

    FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS"
    FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS"

    FF_ASSEMBLER_SUB_DIRS="x86"

elif [ "$FF_ARCH" = "arm64" ]; then
    FF_TOOLCHAIN_ARCH=arm64
    FF_ANDROID_PLATFORM=21

    FF_BUILD_NAME=ffmpeg-arm64
    FF_BUILD_NAME_OPENSSL=openssl-arm64
    FF_BUILD_NAME_LIBSOXR=libsoxr-arm64
    FF_BUILD_NAME_LIBSRT=libsrt-arm64
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=aarch64-linux-android
    FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_64_VER}

    FF_CFG_FLAGS="$FF_CFG_FLAGS --arch=aarch64 --enable-yasm"

    FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS"
    FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS"
    FF_ASSEMBLER_SUB_DIRS="aarch64 neon"

else
    echo "unknown architecture $FF_ARCH";
    exit 1
fi

if [ ! -d $FF_SOURCE ]; then
    echo ""
    echo "!! ERROR"
    echo "!! Can not find FFmpeg directory for $FF_BUILD_NAME"
    echo "!! Run 'sh init-android.sh' first"
    echo ""
    exit 1
fi

FF_TOOLCHAIN_PATH=$FF_BUILD_ROOT/build/toolchain-$FF_ARCH
FF_MAKE_TOOLCHAIN_FLAGS="$FF_MAKE_TOOLCHAIN_FLAGS --install-dir=$FF_TOOLCHAIN_PATH"

FF_SYSROOT=$FF_TOOLCHAIN_PATH/sysroot
FF_PREFIX=$FF_BUILD_ROOT/build/output-$FF_ARCH

FF_DEP_OPENSSL_INC=$FF_PREFIX/include
FF_DEP_OPENSSL_LIB=$FF_PREFIX/lib

FF_DEP_LIBSOXR_INC=$FF_PREFIX/include
FF_DEP_LIBSOXR_LIB=$FF_PREFIX/lib

FF_DEP_LIBSRT_INC=$FF_PREFIX/include
FF_DEP_LIBSRT_LIB=$FF_PREFIX/lib

case "$UNAME_S" in
    CYGWIN_NT-*)
        FF_SYSROOT="$(cygpath -am $FF_SYSROOT)"
        FF_PREFIX="$(cygpath -am $FF_PREFIX)"
    ;;
esac


mkdir -p $FF_PREFIX


# Modernized: use the NDK *unified* clang toolchain (standalone toolchains were
# removed in NDK r19+). Instead of make_standalone_toolchain, create thin
# symlinks under the paths the rest of this script expects
# (${FF_CROSS_PREFIX}-clang / -clang++ / -ar / -nm / -ranlib / -strip / -ld and
# a sysroot). Works with NDK r25/r27 and gives 16 KB-aligned .so.
FF_TOOLCHAIN_TOUCH="$FF_TOOLCHAIN_PATH/touch"
if [ ! -f "$FF_TOOLCHAIN_TOUCH" ]; then
    case "$UNAME_S" in
        Darwin) FF_NDK_HOST=darwin-x86_64 ;;
        *)      FF_NDK_HOST=linux-x86_64 ;;
    esac
    FF_UNIFIED="$ANDROID_NDK/toolchains/llvm/prebuilt/$FF_NDK_HOST"
    case "$FF_ARCH" in
        armv7a) FF_CLANG_TRIPLE=armv7a-linux-androideabi ;;
        arm64)  FF_CLANG_TRIPLE=aarch64-linux-android ;;
        x86)    FF_CLANG_TRIPLE=i686-linux-android ;;
        x86_64) FF_CLANG_TRIPLE=x86_64-linux-android ;;
        *) echo "unsupported arch $FF_ARCH"; exit 1 ;;
    esac
    mkdir -p "$FF_TOOLCHAIN_PATH/bin"
    # clang infers target+API from argv[0]; a symlink keeps the (API-less) link
    # name so it can't find the sysroot. Use exec wrappers so argv[0] is the real
    # API-named binary (${triple}${api}-clang).
    cat > "$FF_TOOLCHAIN_PATH/bin/${FF_CROSS_PREFIX}-clang" <<EOF
#!/bin/sh
exec "$FF_UNIFIED/bin/${FF_CLANG_TRIPLE}${FF_ANDROID_PLATFORM}-clang" "\$@"
EOF
    cat > "$FF_TOOLCHAIN_PATH/bin/${FF_CROSS_PREFIX}-clang++" <<EOF
#!/bin/sh
exec "$FF_UNIFIED/bin/${FF_CLANG_TRIPLE}${FF_ANDROID_PLATFORM}-clang++" "\$@"
EOF
    chmod +x "$FF_TOOLCHAIN_PATH/bin/${FF_CROSS_PREFIX}-clang" "$FF_TOOLCHAIN_PATH/bin/${FF_CROSS_PREFIX}-clang++"
    ln -sf "$FF_UNIFIED/bin/llvm-ar"     "$FF_TOOLCHAIN_PATH/bin/${FF_CROSS_PREFIX}-ar"
    ln -sf "$FF_UNIFIED/bin/llvm-nm"     "$FF_TOOLCHAIN_PATH/bin/${FF_CROSS_PREFIX}-nm"
    ln -sf "$FF_UNIFIED/bin/llvm-ranlib" "$FF_TOOLCHAIN_PATH/bin/${FF_CROSS_PREFIX}-ranlib"
    ln -sf "$FF_UNIFIED/bin/llvm-strip"  "$FF_TOOLCHAIN_PATH/bin/${FF_CROSS_PREFIX}-strip"
    ln -sf "$FF_UNIFIED/bin/ld.lld"      "$FF_TOOLCHAIN_PATH/bin/${FF_CROSS_PREFIX}-ld"
    ln -sf "$FF_UNIFIED/sysroot"         "$FF_TOOLCHAIN_PATH/sysroot"
    touch "$FF_TOOLCHAIN_TOUCH";
fi
# 16 KB page-size alignment (Android 15). lld supports these on any modern NDK.
# Applied every run (not only first) so re-links pick it up.
FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS -Wl,-z,max-page-size=16384"
# This ijkplayer-era FFmpeg predates clang 17, which promoted several
# diagnostics to hard errors. Downgrade them back to warnings so it compiles.
FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS \
    -Wno-error=incompatible-function-pointer-types \
    -Wno-error=implicit-function-declaration \
    -Wno-error=int-conversion \
    -Wno-error=implicit-int"


#--------------------
echo ""
echo "--------------------"
echo "[*] check ffmpeg env"
echo "--------------------"
echo "--------------------${FF_TOOLCHAIN_PATH}/bin"
echo "--------------------${FF_CROSS_PREFIX}"
export PATH=$FF_TOOLCHAIN_PATH/bin/:$PATH
#export CC="ccache ${FF_CROSS_PREFIX}-gcc"
export AS=${FF_CROSS_PREFIX}-clang
export CC=${FF_CROSS_PREFIX}-clang
export CXX=${FF_CROSS_PREFIX}-clang++
export LD=${FF_CROSS_PREFIX}-ld
export AR=${FF_CROSS_PREFIX}-ar
export RANLIB=${FF_CROSS_PREFIX}-ranlib
export STRIP=${FF_CROSS_PREFIX}-strip
export SYSROOT=${FF_SYSROOT}
export CROSS_PREFIX=${FF_CROSS_PREFIX}

FF_CFLAGS="-O3 -Wall -pipe \
    -std=c99 \
    -fPIE -fPIC \
    -ffast-math \
    -fstrict-aliasing -Werror=strict-aliasing \
    -Wa,--noexecstack \
    -DANDROID -DNDEBUG"

FF_CFG_FLAGS="$FF_CFG_FLAGS --as=${FF_CROSS_PREFIX}-clang"
FF_CFG_FLAGS="$FF_CFG_FLAGS --cc=${FF_CROSS_PREFIX}-clang"
FF_CFG_FLAGS="$FF_CFG_FLAGS --cxx=${FF_CROSS_PREFIX}-clang++"
# FF_CFG_FLAGS="$FF_CFG_FLAGS --ld=${FF_CROSS_PREFIX}-ld"
# FF_CFG_FLAGS="$FF_CFG_FLAGS --ar=${FF_CROSS_PREFIX}-ar"
# FF_CFG_FLAGS="$FF_CFG_FLAGS --cxx=${FF_CROSS_PREFIX}-clang++"
# cause av_strlcpy crash with gcc4.7, gcc4.8
# -fmodulo-sched -fmodulo-sched-allow-regmoves

# --enable-thumb is OK
#FF_CFLAGS="$FF_CFLAGS -mthumb"

# not necessary
#FF_CFLAGS="$FF_CFLAGS -finline-limit=300"

export COMMON_FF_CFG_FLAGS=
. $FF_BUILD_ROOT/../../config/module.sh


#--------------------
# with openssl
if [ -f "${FF_DEP_OPENSSL_LIB}/libssl.a" ]; then
    echo "OpenSSL detected"
    # FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-nonfree"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-openssl"
    echo "${FF_DEP_OPENSSL_INC} ${FF_DEP_OPENSSL_LIB}"
    FF_CFLAGS="$FF_CFLAGS -I${FF_DEP_OPENSSL_INC}"
    FF_DEP_LIBS="$FF_DEP_LIBS -L${FF_DEP_OPENSSL_LIB} -lssl -lcrypto"
fi

if [ -f "${FF_DEP_LIBSOXR_LIB}/libsoxr.a" ]; then
    echo "libsoxr detected"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-libsoxr"

    FF_CFLAGS="$FF_CFLAGS -I${FF_DEP_LIBSOXR_INC}"
    FF_DEP_LIBS="$FF_DEP_LIBS -L${FF_DEP_LIBSOXR_LIB} -lsoxr"
fi

if [ -f "${FF_DEP_LIBSRT_LIB}/libsrt.a" ]; then
    echo "libsrt detected"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-libsrt"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-protocol=libsrt"

    FF_CFLAGS="$FF_CFLAGS -I${FF_DEP_LIBSRT_INC}"
    FF_DEP_LIBS="$FF_DEP_LIBS -L${FF_DEP_LIBSRT_LIB} -lsrt -lc -lm -ldl -lcrypto -lssl -lstdc++"
fi

export PKG_CONFIG_PATH="${FF_PREFIX}/lib/pkgconfig"

FF_CFG_FLAGS="$FF_CFG_FLAGS --pkgconfigdir=${FF_PREFIX}/lib/pkgconfig"

FF_CFG_FLAGS="$FF_CFG_FLAGS $COMMON_FF_CFG_FLAGS"

#--------------------
# Standard options:
FF_CFG_FLAGS="$FF_CFG_FLAGS --prefix=$FF_PREFIX"

# Advanced options (experts only):
FF_CFG_FLAGS="$FF_CFG_FLAGS --cross-prefix=${FF_CROSS_PREFIX}-"
FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-cross-compile"
FF_CFG_FLAGS="$FF_CFG_FLAGS --target-os=linux"
FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-pic"
FF_CFG_FLAGS="$FF_CFG_FLAGS --pkg-config=pkg-config"
# FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-symver"
FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-static"
FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-shared"

if [ "$FF_ARCH" = "x86" ]; then
    FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-asm"
else
    # Optimization options (experts only):
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-asm"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-inline-asm"
fi

case "$FF_BUILD_OPT" in
    debug)
        FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-optimizations"
        FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-debug"
        FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-small"
    ;;
    *)
        FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-optimizations"
        FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-debug"
        FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-small"
    ;;
esac

#--------------------
echo ""
echo "--------------------"
echo "[*] configurate ffmpeg"
echo "--------------------"
cd $FF_SOURCE
if [ -f "./config.h" ]; then
    echo 'reuse configure'
else
    which $CC
    ./configure $FF_CFG_FLAGS \
        --extra-cflags="$FF_CFLAGS $FF_EXTRA_CFLAGS" \
        --extra-ldflags="$FF_DEP_LIBS $FF_EXTRA_LDFLAGS"
    make clean
fi

#--------------------
echo ""
echo "--------------------"
echo "[*] compile ffmpeg"
echo "--------------------"
cp config.* $FF_PREFIX
make $FF_MAKE_FLAGS > /dev/null
make install
mkdir -p $FF_PREFIX/include/libffmpeg
cp -f config.h $FF_PREFIX/include/libffmpeg/config.h

#--------------------
echo ""
echo "--------------------"
echo "[*] link ffmpeg"
echo "--------------------"
echo $FF_EXTRA_LDFLAGS

FF_C_OBJ_FILES=
FF_ASM_OBJ_FILES=
for MODULE_DIR in $FF_MODULE_DIRS
do
    C_OBJ_FILES="$MODULE_DIR/*.o"
    if ls $C_OBJ_FILES 1> /dev/null 2>&1; then
        echo "link $MODULE_DIR/*.o"
        FF_C_OBJ_FILES="$FF_C_OBJ_FILES $C_OBJ_FILES"
    fi

    for ASM_SUB_DIR in $FF_ASSEMBLER_SUB_DIRS
    do
        ASM_OBJ_FILES="$MODULE_DIR/$ASM_SUB_DIR/*.o"
        if ls $ASM_OBJ_FILES 1> /dev/null 2>&1; then
            echo "link $MODULE_DIR/$ASM_SUB_DIR/*.o"
            FF_ASM_OBJ_FILES="$FF_ASM_OBJ_FILES $ASM_OBJ_FILES"
        fi
    done
done

echo "link FF_DEP_LIBS:$FF_DEP_LIBS"
echo "link FF_EXTRA_LDFLAGS:$FF_EXTRA_LDFLAGS"
$CC -lm -lz -shared -Wl,-Bsymbolic --sysroot=$FF_SYSROOT -Wl,--no-undefined -Wl,-z,noexecstack $FF_EXTRA_LDFLAGS \
    -Wl,-soname,libijkffmpeg.so \
    $FF_C_OBJ_FILES \
    $FF_ASM_OBJ_FILES \
    $FF_DEP_LIBS \
    -o $FF_PREFIX/libijkffmpeg.so

mysedi() {
    f=$1
    exp=$2
    n=`basename $f`
    cp $f /tmp/$n
    sed $exp /tmp/$n > $f
    rm /tmp/$n
}

echo ""
echo "--------------------"
echo "[*] create files for shared ffmpeg"
echo "--------------------"
rm -rf $FF_PREFIX/shared
mkdir -p $FF_PREFIX/shared/lib/pkgconfig
ln -s $FF_PREFIX/include $FF_PREFIX/shared/include
ln -s $FF_PREFIX/libijkffmpeg.so $FF_PREFIX/shared/lib/libijkffmpeg.so
cp $FF_PREFIX/lib/pkgconfig/*.pc $FF_PREFIX/shared/lib/pkgconfig
for f in $FF_PREFIX/lib/pkgconfig/*.pc; do
    # in case empty dir
    if [ ! -f $f ]; then
        continue
    fi
    cp $f $FF_PREFIX/shared/lib/pkgconfig
    f=$FF_PREFIX/shared/lib/pkgconfig/`basename $f`
    # OSX sed doesn't have in-place(-i)
    mysedi $f 's/\/output/\/output\/shared/g'
    mysedi $f 's/-lavcodec/-lijkffmpeg/g'
    mysedi $f 's/-lavfilter/-lijkffmpeg/g'
    mysedi $f 's/-lavformat/-lijkffmpeg/g'
    mysedi $f 's/-lavutil/-lijkffmpeg/g'
    mysedi $f 's/-lswresample/-lijkffmpeg/g'
    mysedi $f 's/-lswscale/-lijkffmpeg/g'
done
