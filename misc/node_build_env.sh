export PATH="${HOME}/x-tools6h/bin-tupleless:${HOME}/x-tools6h/bin:$PATH"
export TOOL_PREFIX="arm-linux-gnueabihf"
export CC="${TOOL_PREFIX}-gcc"
export CXX="${TOOL_PREFIX}-g++"
export AR="${TOOL_PREFIX}-ar"
export RANLIB="${TOOL_PREFIX}-ranlib"
export LINK="${CXX}"
export CCFLAGS="-march=armv6j -mfpu=vfp -mfloat-abi=hard -DUSE_EABI_HARDFLOAT"
export CXXFLAGS="-march=armv6j -mfpu=vfp -mfloat-abi=hard -DUSE_EABI_HARDFLOAT"
export OPENSSL_armcap=6
export GYPFLAGS="-Darmeabi=hard -Dv8_use_arm_eabi_hardfloat=true -Dv8_can_use_vfp3_instructions=false -Dv8_can_use_vfp2_instructions=true -Darm7=0 -Darm_vfp=vfp"
export VFP3=off
export VFP2=on
PREFIX_DIR="/usr/local"

# ./configure --without-snapshot --dest-cpu=arm --dest-os=linux --prefix="${PREFIX_DIR}"
