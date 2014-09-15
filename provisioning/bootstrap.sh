#!/usr/bin/env bash

export CTVERSION=linaro-1.13.1-4.9-2014.08
export CTNAME=crosstool-ng-${CTVERSION}
export CTURL=https://releases.linaro.org/latest/components/toolchain/binaries/${CTNAME}.tar.bz2

# choose at will
export CTPATH=${HOME}/crosstool-ng
export CTSTAGINGDIR=${HOME}/staging

# this should work well for a Raspberry Pi
export CTCONFIG=/vagrant/ct-ng-configs/linaro-raspbian-201409-modified.config
# export CTCONFIG=/vagrant/ct-ng-configs/xtools-dotconfig-v6.archlinux.config

# if you change this, be sure to adjust the ct-ng config
export XTPATH=${HOME}/x-tools6h

# path to prebuilt x-tools, rather than building
export XTARCHIVE=/vagrant/prebuilt-toolchains/linaro-raspbian-201409-modified.tar.gz
# export XTARCHIVE=/vagrant/prebuilt-toolchains/gcc-linaro-arm-linux-gnueabihf-raspbian.tar.gz
# export XTARCHIVE=/vagrant/prebuilt-toolchains/x-tools6h.archlinux.tar.xz

testMkdirCd() {
    [ ! -d "$1" ] && mkdir -p "$1"
    cd "$1"
}

prependToPath() {
    [[ ! -s "${HOME}/.bashrc" ]] && touch "${HOME}/.bashrc"
    if ! grep -q "export PATH=$1:\$PATH" "${HOME}/.bashrc" ; then
        echo "export PATH=$1:\$PATH" >> "${HOME}/.bashrc"
    fi
}

# it's quite possible that not all of these are required,
# and some are simply useful
updateInstallDeps() {
  echo ">>> Updating system and installing dependencies"
  sudo apt-get -qq update
  sudo apt-get -qq upgrade -y
  sudo apt-get -qq install -y tmux vim htop # comfort
  sudo apt-get -qq install -y curl wget build-essential git cvs subversion # essential
  sudo apt-get -qq install -y libncurses5-dev automake libtool bison flex texinfo gawk gcj-jdk libexpat1-dev python-dev gperf # texlive # ct-ng deps (texlive only for manuals)
  echo ">>> Updating system and installing dependencies: done!"
}

downloadCtng() {
  echo ">>> Downloading crosstool-NG"
  testMkdirCd "${CTPATH}"
  wget -nv "${CTURL}"
  tar xjf "${CTNAME}.tar.bz2"
  echo ">>> Downloading crosstool-NG: done!"
}

installCtng() {
  echo ">>> Installing crosstool-NG"
  cd "${CTPATH}/${CTNAME}"
  ./configure --prefix="${CTPATH}"
  make
  # install as root
  sudo make install
  sudo cp ct-ng.comp /etc/bash_completion.d/
  prependToPath "${CTPATH}/bin"
  echo ">>> Installing crosstool-NG: done!"
}

buildToolchain() {
  echo ">>> Building toolchain"
  export PATH=${PATH}:${CTPATH}/bin
  [[ ! $(which ct-ng) ]] && return 2

  testMkdirCd "${XTPATH}/arm-linux-gnueabihf"
  testMkdirCd "${CTSTAGINGDIR}/tarballs"
  cd ..

  cp "${CTCONFIG}" .config
  ct-ng build

  prependToPath "${XTPATH}/bin"
  echo ">>> Building toolchain: done!"
}

extractPrebuiltToolchain() {
  echo ">>> Extracting prebuilt toolchain"
  if [[ -d ${XTPATH} ]] ; then
    echo ">>> Toolchain folder exists, aborting!"
    return 3
  else
    testMkdirCd ${XTPATH}
    tar xf ${XTARCHIVE} --strip 1
  fi
  prependToPath "${XTPATH}/bin"
  echo ">>> Extracting prebuilt toolchain: done!"
}

linkTupleless() {
  # See http://archlinuxarm.org/developers/distcc-cross-compiling
  echo ">>> Creating tupleless bin links"
  cd ${XTPATH}
  [[ -d bin-tupleless ]] && rm -r bin-tupleless
  mkdir bin-tupleless
  for file in $(ls bin); do
    ln -s ../bin/$file bin-tupleless/${file#arm-linux-gnueabihf-}
    ln -s ../bin/$file bin-tupleless/armv6l-unknown-${file#arm-}
  done
  echo ">>> Creating tupleless bin links: done!"
  # intentionally not added to PATH; intended for distccd's path
}

distccdSetup() {
  echo ">>> Installing and configuring distcc(d)"
  echo ">>> WARNING: we're opening up distcc to the entire /16"
  echo "    this is a potential security risk!"
  echo "    change before using on a public/untrustworthy network"
  [[ ! $(which distccd) ]] && sudo apt-get install -y distcc

  sudo sed -i -e 's:^\(STARTDISTCC\)="false"$:\1="true":' \
            -e 's:^\(ALLOWEDNETS\)="127.0.0.1"$:\1="192.168.0.0/16":' \
            -e 's:^\(LISTENER\)="127.0.0.1"$:\1="":' \
            /etc/default/distcc

  # use bin-tupleless as first PATH dir to override compilers etc.
  if ! grep -q "PATH=${XTPATH}/bin" /etc/init.d/distcc ; then
    sudo sed -i "s|PATH=|PATH=${XTPATH}/bin-tupleless:${XTPATH}/bin:|" /etc/init.d/distcc
  fi

  sudo /etc/init.d/distcc start
  echo ">>> Installing and configuring distcc(d): done!"
}

###
# UNCOMMENT AS NEEDED
# then run `vagrant provision`
###

#updateInstallDeps

# build x-tools yourself:
#downloadCtng
#installCtng
#buildToolchain

# or use prebuilt x-tools:
#extractPrebuiltToolchain

# optional, but awesome: distcc
linkTupleless
distccdSetup
