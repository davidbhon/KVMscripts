#!/bin/bash
systemctl status libvirtd
systemctl restart libvirtd

bridge=virbr0
virsh net-destroy $bridge >& /dev/null
virsh net-undefine $bridge >& /dev/null
virsh net-create ${bridge}.xml
virsh net-list
virsh net-info $bridge

vcpu=8
vram=16000
vdisk=`pwd`/vmdisk64g.img

vm=CentOS-8-ec2-8.3.2011-20201204.2.x86_64
qcow=`pwd`/$vm.qcow2

virsh destroy $vm 
virsh undefine $vm

virt-install --import --noautoconsole --cpu host --connect qemu:///system --ram=${vram} --vcpus=${vcpu} --name=${vm} \
             --os-type=linux --os-variant=centos8 --network=network:${bridge} --network=network:${bridge} \
             --disk path=${qcow},device=disk,bus=virtio,format=qcow2 # --disk path=${vdisk},device=disk,bus=virtio,format=qcow2

echo 3 && sleep 1 && echo 2 && sleep 1 && echo 1 && sleep 1 && echo 0 && sleep 1
echo booted $vm
virsh list
virsh attach-disk $vm `pwd`/vmdisk64g.img vdb
echo attached 64G /dev/vdb to $vm
virsh domifaddr $vm

