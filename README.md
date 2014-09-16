rpi-cross
=========

There are plenty of good things to say about the [Raspberry Pi](http://www.raspberrypi.org/help/what-is-a-raspberry-pi/), but there’s one thing I could do without: Waiting for compilation! The venerable Pi’s ARM11 is showing its age …

This project is meant to help: Using [VirtualBox](https://www.virtualbox.org/), [Vagrant](https://github.com/mitchellh/vagrant), [crosstool-NG](http://crosstool-ng.org/), and [Ansible](https://github.com/ansible/ansible), `rpi-cross` will automatically set up an Ubuntu VM with a cross compilation toolchain optimized for Raspberry Pi and a [distcc](https://code.google.com/p/distcc/) server, ready to cross compile both locally and over the network.

Sound good? Let’s make it happen. Contributions very welcome.


Status
------

`rpi-cross` is a work-in-progress. Right now, testers are needed to confirm the following features:

- [x] setup of a prebuilt toolchain
- [x] unattended toolchain compilation using crosstool-NG
- [x] distcc setup and configuration

All of these work for me, but I’m sure there are plenty of kinks to work out. Whatever your experience, please do provide feedback! :)


Quickstart
----------

If you know what you want, this will probably be enough get you going. If not, please follow the Guide below.

- dependencies: [Vagrant](http://www.vagrantup.com/downloads) with VirtualBox, [Ansible](http://docs.ansible.com/intro_installation.html)
- choose between building your own toolchain with crosstool-NG, or use a prebuilt one:
  - option A: download [the prebuilt toolchain](https://github.com/tjanson/rpi-cross/releases/download/v0.1/linaro-arm-linux-gnueabihf-raspbian.201408.modified.tar.xz)
  - option B: choose a crosstool-NG [configuration file](https://github.com/tjanson/rpi-cross/tree/master/ctng-configs) or create your own
- modify `ctng_*` or `xt_prebuilt` in Ansible’s [`playbook.yml`](https://github.com/tjanson/rpi-cross/blob/master/provisioning/playbook.yml) to point to the files of the previous step
- `vagrant up`

Note that the custom build takes quite a long time (~40 min on my machine) and unfortunately offers little feedback. Go have a coffee, and hopefully you’ll come back to find your toolchain in `~/x-tools6h` and distcc set up and running.


Usage Guide
-----------

### Preparation

First of all, install [VirtualBox](https://www.virtualbox.org/wiki/Downloads), [Vagrant](http://www.vagrantup.com/downloads), and [Ansible](http://docs.ansible.com/intro_installation.html). (On Mac OS, all three are available as homebrews/casks.)

Then clone the `rpi-cross` repo:

```sh
cd some/folder
git clone https://github.com/tjanson/rpi-cross.git
cd rpi-cross
```

Now, please follow along to get an overview of what’s about to happen.

### Vagrantfile and Ansible Playbook

First, take a look at the [Vagrantfile](https://github.com/tjanson/rpi-cross/blob/master/Vagrantfile) (e.g., `nano Vagrantfile`) and read the comments. Vagrant is a tool that’ll set up a headless VM (that is, a virtual machine without graphical interface) based on these settings.

Done? We’ll continue our tour with `provisioning/playbook.yml`. This is the meats: a list of state descriptions and commands that Ansible will execute automatically during “provisioning”.

These tasks, listed under [`tasks` (line 40)](https://github.com/tjanson/rpi-cross/blob/master/provisioning/playbook.yml#L40), perfom three functions (besides some basic system maintenance):

- installing crosstool-NG and building a toolchain based on a CTNG config file
- unpacking a prebuilt toolchain
- installing and configuring distcc

You’ll only want *either* build your own toolchain, *or* use a prebuilt one (and you’ll be prompted to choose during provisioning).
Variables starting with `ctng` relate to the former, `prebuilt_xt` to the latter — it’s safe to ignore whatever doesn’t apply to you.

If you don’t know what any of this means, the following should suffice:
A toolchain is a set of programs working together to compile software for a certain target architecture, in this case our Raspberry Pi. One of these tools is the `gcc` compiler, which you probably use on your Pi, but quite a few others are needed in the background.
The [crosstool-NG docs](http://crosstool-ng.org/hg/crosstool-ng/raw-file/069f43a215cc/docs/9%20-%20How%20is%20a%20toolchain%20constructed.txt) explain toolchains in detail.

Unpacking `linaro-arm-linux-gnueabihf-raspbian.201408.modified.tar.xz` is a convenient option, based on the official Raspbian Linaro toolchain, but updated with more recent (possibly unstable) tools. We’ll use it for this guide.

Back at the top of the file, the `vars` section defines various paths and source files. (Again: The `ctng` options are for custom building only.)

The desired toolchain is already selected:

```yml
  prebuilt_xt: "/vagrant/prebuilt-toolchains/linaro-arm-linux-gnueabihf-raspbian.201408.modified.tar.xz"
# prebuilt_xt: "/vagrant/prebuilt-toolchains/gcc-linaro-arm-linux-gnueabihf-4.9-2014.08_linux.tar.xz"
# prebuilt_xt: "/vagrant/prebuilt-toolchains/x-tools6h.archlinux.tar.xz"
```

### Download a prebuilt toolchain

Now download the toolchain tarball. You don’t need to unpack it.

```sh
cd prebuilt-toolchains
wget https://github.com/tjanson/rpi-cross/releases/download/v0.1/linaro-arm-linux-gnueabihf-raspbian.201408.modified.tar.xz
cd ..
```

### VM provisioning

Call Vagrant to set up the VM, in the root directory of the project (which contains the Vagrantfile):

```sh
vagrant up
```

This will take a while and prompt you occasionally. Ideally, this will finish successfully. If you encounter any errors, please file an issue.

Okay, that’s it! You can now ssh into your VM:

```sh
vagrant ssh
```

In the new shell, the output of `which arm-linux-gnueabihf-gcc` should be `/home/vagrant/x-tools6h/bin/arm-linux-gnueabihf-gcc`, and `ls x-tools6h` should yield this (or something similar – but definitely not empty):

```sh
arm-linux-gnueabihf  bin  bin-tupleless  build.log.bz2  include  lib  libexec  share
```

In particular, `bin-tupleless` should be present (and contain symlinks to various tools). Try `./x-tools6h/bin-tupleless/gcc --version`. Does it output the `gcc` version information (numbers will vary), e.g., `gcc [...] 4.9.2 [...]`?

Finally, check `/etc/init.d/distcc status`. It should already be running.

### Hello, World!

If all that went well, you have a working cross compiler! Let’s try it: Create the following in `hello.c`:

```c
#include <stdio.h>

int main() {
    printf("Hello World");
    return 0;
}
```

Cross-compile it with `arm-linux-gnueabihf-gcc -c hello.c -o hello`, and check `file hello`:
```
hello: ELF 32-bit LSB  relocatable, ARM, EABI5 version 1 (SYSV), not stripped
```

This program won’t run in the VM — it’s for the Pi! Note the “ARM”. You may copy it to your Pi (`scp` is cool), and try it.

### Using distcc to delegete compilation from our Pi

Finally, you can use distcc to off-load compilation from your Pi to the `rpi-cross` VM.
We’ll try a real world example: Compiling [Node.js](http://www.nodejs.org/).

On your Raspberry Pi (presumably running Raspbian), install distcc. And while we’re at it git and python2, if not already present, which we’ll need for Node:

```sh
sudo apt-get install distcc distcc-pump
sudo apt-get install git python2.7
```

Clone the Node repository. We’ll take a walk on the wild side and checkout the `v0.10` dev branch. (There’s actually a good reason: We need the as of yet unreleased fix for [#8062](https://github.com/joyent/node/issues/8062).)

```sh
git clone https://github.com/joyent/node.git
cd node
git checkout v0.10
```

Then set the following environment variables:

```sh
export DISTCC_HOSTS=vagrant-ubuntu-trusty-64,cpp,lzo
export DISTCC_SKIP_LOCAL_RETRY=1 ; export DISTCC_FALLBACK=0
export DISTCC_VERBOSE=1
export PATH=/usr/lib/distcc:${PATH}
```

From the top:

1. Add our VM as a distcc compilation slave capable of compression and [pump mode](https://distcc.googlecode.com/svn/trunk/doc/web/man/distcc_1.html#TOC_8) (substitute the IP if your network doesn’t resolve hostnames)
2. Disable local compilation if distributed compilation fails, or if no slave is available. If it *does* fail, we want to be aware of it.
3. Lots of debug output.
4. Alter the `PATH` (temporarily) to include the distcc masquerading directory, which contains “decoys” of gcc, which in fact point to distcc. Thus, if a Makescript or similar calls the compiler, the distcc wrapper will take over.

Even more env vars for building Node. I’ve taken them from [Nodejs-ARM-Builder](https://github.com/needforspeed/Nodejs-ARM-builder/blob/master/cross-compiler.sh#L110), which was actually the inspiration for `rpi-cross` (thanks!).

```sh
export CCFLAGS="-march=armv6j -mfpu=vfp -mfloat-abi=hard -DUSE_EABI_HARDFLOAT"
export CXXFLAGS="-march=armv6j -mfpu=vfp -mfloat-abi=hard -DUSE_EABI_HARDFLOAT"
export OPENSSL_armcap=6
export GYPFLAGS="-Darmeabi=hard -Dv8_use_arm_eabi_hardfloat=true -Dv8_can_use_vfp3_instructions=false -Dv8_can_use_vfp2_instructions=true -Darm7=0 -Darm_vfp=vfp"
export VFP3=off
export VFP2=on
PREFIX_DIR="/usr/local"
```

Finally, ready to go: Configure, and make!

```sh
./configure --without-snapshot --dest-cpu=arm --dest-os=linux --prefix="${PREFIX_DIR}"
make -j4
```

(You may experiment with the [`-j` value](https://distcc.googlecode.com/svn/trunk/doc/web/man/distcc_1.html#TOC_3).) The important point, though, is that a ton of distcc debug output should be scrolling across your screen.
On the `rpi-cross` VM, `sudo tail -f /var/log/distccd.log` should bear witness to successful compilations thusly:

```
distccd[32620] (dcc_job_summary) client: 192.168.1.176:59815 COMPILE_OK exit:0 sig:0 core:0 ret:0 time:12113ms g++ ../src/node_crypto.cc
```

Once finished (it’ll take a while, even with `rpi-cross`), `./out/Release/node -v` should respond with Node’s version. You can install it, if you wish:

```sh
sudo make -j4 install CC=distcc CXX=distcc
```

What’s that `CC=…` stuff you ask? I’m not sure why, actually, but masquerading fails here, and specifying distcc as the compiler works. (Let me know if you know.)

This concludes the guide — I hope you found it useful!


Project Goal
------------

My intention is to provide a beginner-friendly tool, useable without deep knowledge of the involved tools. 
Using a provisioning tool like Ansible has several advantages:

- fully automated setup and configuration,
- maintainability and adaptability,
- transparent, precise documentation of all steps involved.

You can simply treat the resulting setup as a black box, but if curiosity (or necessity) strikes, you can look at its blueprints — and change them.
