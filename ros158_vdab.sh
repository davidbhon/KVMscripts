#!/bin/bash
bridge=virbr0
vcpu=8
vram=16000
vdisk=`pwd`/vmdisk64g.img

vm=rancheros158-openstack
qcow=`pwd`/$vm.qcow2

virt-install --import --noautoconsole --cpu host --connect qemu:///system --ram=${vram} --vcpus=${vcpu} --name=${vm} \
             --os-type=linux --os-variant=rhel7 --network=network:${bridge} --network=network:${bridge} \
             --disk path=${qcow},device=disk,bus=virtio,format=qcow2 # --disk path=${vdisk},device=disk,bus=virtio,format=qcow2

virsh list
virsh attach-disk $vm `pwd`/vmdisk64g.img vdb
virsh domifaddr $vm

