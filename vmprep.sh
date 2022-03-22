#!/bin/bash
echo apt install qemu qemu-kvm libvirt-clients libvirt-daemon-system virtinst bridge-utils

# http://libguestfs.org/virt-sysprep.1.html
# http://libguestfs.org/virt-builder.1.html#users-and-passwords
 
#qcow=`pwd`/VMs/Fedora-Cloud-Base-26-1.5.x86_64.qcow2
qcow=`pwd`/CentOS-8-ec2-8.3.2011-20201204.2.x86_64.qcow2

echo virt-sysprep -a $qcow --root-password password:cloudcloud 
echo virt-sysprep -a $qcow --password fedora:password:cloudcloud 

# virt-sysprep -a $qcow --firstboot-command 'useradd -m -p "" hon ; chage -d 0 hon'
echo virt-sysprep -a $qcow --firstboot-command 'useradd -m -p "" hon'

vdisk_sz=64G
qemu-img create -f raw ./vmdisk$vdisk_sz.img $vdisk_sz
echo qemu-img resize vmdisk.img +16G
echo qemu-img resize vmdisk.img -16G
vminst=`virsh list|grep -i running|tail -1|awk '{print $2}'`
echo vminst=$vminst
echo virsh attach-disk $vminst /opt/iso/disk2.img sdb

# default openastack kvm qcow imahe has 8G root / == /dev/vda1
# need lots more space
qemu-img create -f raw CentOS-8-ec2-8.3.2011-20201204.2.x86_64.qcow2 128G
virt-resize --expand /dev/vda1 8gCentOS-8-ec2-8.3.2011-20201204.2.x86_64.qcow2 CentOS-8-ec2-8.3.2011-20201204.2.x86_64.qcow2

