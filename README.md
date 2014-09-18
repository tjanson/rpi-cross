rpi-cross
=========

There are plenty of good things to say about the [Raspberry Pi][rpi-intro], but there’s one thing I could do without: Waiting for compilation! The venerable Pi’s ARM11 is showing its age …

This project is meant to help: Using [VirtualBox][], [Vagrant][], [crosstool-NG][], and [Ansible][], `rpi-cross` will automatically set up an Ubuntu VM with a cross compilation toolchain optimized for Raspberry Pi and a [distcc][] daemon, ready to cross compile both locally and over the network.

Sound good? Let’s make it happen. Contributions very welcome.

[rpi-intro]:    http://www.raspberrypi.org/help/what-is-a-raspberry-pi/
[VirtualBox]:   https://www.virtualbox.org/
[Vagrant]:      https://github.com/mitchellh/vagrant
[crosstool-NG]: http://crosstool-ng.org/
[Ansible]:      https://github.com/ansible/ansible
[distcc]:       https://code.google.com/p/distcc/

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

- dependencies: [Vagrant][vagrant-dl] with VirtualBox, [Ansible][ansible-dl]
- choose between building your own toolchain with crosstool-NG, or using a prebuilt one:
  - option A (*default*): [the prebuilt toolchain][prebuilt-dl] will be downloaded automatically  
    If you substitute your own tarball, make sure to match the folder structure.
  - option B: choose a crosstool-NG [configuration file][ctng-confs] or create your own  
- modify `ctng_*` or `xt_prebuilt[_url]` in Ansible’s [`playbook.yml`][playbook] according to your choices of the previous step
- `vagrant up` to set up and start the VM

(Note: The custom build takes quite a long time (~40 min on my machine) and unfortunately offers little feedback: Ansible doesn’t show the client’s `stdout`. You could monitor the CPU usage, but that’s not very satisfying. You’ll just have to wait it out.)

Now, `vagrant ssh` into the machine and inspect the results: If all went well, you’ll find the toolchain in `~/x-tools6h`, and the distcc daemon is running and open for connections from `192.168../16`.

[vagrant-dl]:  http://www.vagrantup.com/downloads
[ansible-dl]:  http://docs.ansible.com/intro_installation.html
[prebuilt-dl]: https://github.com/tjanson/rpi-cross/releases/download/v0.1/linaro-arm-linux-gnueabihf-raspbian.201408.modified.tar.xz
[ctng-confs]:  https://github.com/tjanson/rpi-cross/tree/master/ctng-configs
[playbook]:    https://github.com/tjanson/rpi-cross/blob/master/provisioning/playbook.yml


Usage Guide
-----------

[The guide has been moved to this Wiki page](https://github.com/tjanson/rpi-cross/wiki/Usage-Guide).


Project Goal
------------

My intention is to provide a beginner-friendly tool, useable without deep knowledge of the involved tools. 
Using a provisioning tool like Ansible has several advantages:

- fully automated setup and configuration,
- maintainability and adaptability,
- transparent, precise documentation of all steps involved.

You can simply treat the resulting setup as a black box, but if curiosity (or necessity) strikes, you can look at its blueprints — and change them.
