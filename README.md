# RHEL Vagrant Box Creator

This repository contains a script for creating [Red Hat Enterprise Linux (RHEL)](https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux) [Vagrant](https://www.vagrantup.com/) boxes for
the [Libvirt provider](https://github.com/vagrant-libvirt/vagrant-libvirt) based on the KVM guest images provided by Red Hat.  

## Requirements

* RHEL KVM guest image
* genisoimage
* tar
* gzip, bzip2 or xz

Tested with:
  * RHEL 7.3 and 7.4 KVM guest images
  * Vagrant 2.0.0
  * vagrant-libvirt 0.0.40

Note: Some older versions of Vagrant and/or vagrant-libvirt do not merge the settings in the box Vagrantfile correctly, causing
an error when Vagrant tries to log into a machine via ssh.

## Usage

**create-box.sh** *RHEL_CLOUD_IMAGE* *VAGRANT_BOX_TARBALL*

The tarball is compressed with **bzip2** if *VAGRANT_BOX_TARBALL* ends in `.bz2`, with **xz** if it ends in `.xz` and with **gzip** otherwise.

## Example

1. Download a RHEL KVM guest image from https://access.redhat.com/downloads/content/69
2. Create the Vagrant box with **create-box.sh**, e.g.:

        create-box.sh rhel-server-7.4-x86_64-kvm.qcow2 rhel74-box.tar.gz

The Vagrant box can then be loaded into Vagrant with `vagrant box add` as usual, e.g.:

    vagrant box add rhel74 rhel74-box.tar.gz

## Implementation

The script first creates a cloud-init ISO image and then packages the unmodified KVM guest image, the cloud-init image, a Vagrantfile and some metadata into a Vagrant box.  
The Vagrantfile in the box ensures that any machines created from the box have the cloud-init image attached. The cloud-init image is responsible for configuring machines for Vagrant on their first boot as documented [here](https://www.vagrantup.com/docs/boxes/base.html#default-user-settings). cloud-init also takes care of resizing the partition and filesystem to match the disk size of the created machines.
