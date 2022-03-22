#!/bin/sh

#ovsbridge=ovsbr0
#bridge=docker0
#bridge=linuxbr172.17.xml
bridge=virbr0
rootpath=`pwd`

#mother=mothershipCentos8
mother=CentOS-8-ec2-8.3.2011-20201204.2.x86_64
vdisk=vmdisk64G.img
vcpu=8
vram=16384 # 8192 # 1024 # 2048

function vreset {
  if [ $1 ] ; then bridge="$1" ; fi
  if [ $2 ] ; then vcpu="$2" ; fi
  if [ $3 ] ; then vram="$3" ; fi

  virsh destroy ${mother} ; virsh undefine ${mother}
# virsh destroy ${mother}-ram${vram}-cpu${vcpu} ; virsh undefine ${mother}-ram${vram}-cpu${vcpu}
# docker rm -f fitness gitlab registry portainer
# systemctl stop docker
# podman rm -f fitness gitlab registry portainer

# systemctl stop NetworkManager
  virsh net-destroy $bridge >& /dev/null
  virsh net-undefine $bridge >& /dev/null
  systemctl stop libvirtd

# ip addr add dev $bridge 172.17.0.1/12
# ip addr add dev $bridge 63.141.239.91/29

  systemctl restart iptables
# iptables-restore < iptables.save

  systemctl start libvirtd
  virsh net-create ${bridge}.xml
  virsh net-list
  virsh net-info $bridge

  systemctl start docker

  ip a
  iptables-save
}

function vkill {
  virsh undefine $mother ; virsh destroy $mother
  systemctl restart libvirtd
}

######################################################

#vreset -v
#vkill -v

vm=${mother}
if [ $1 ] ; then vm="$1" ; fi
if [ $2 ] ; then vcpu="$2" ; fi
if [ $3 ] ; then vram="$3" ; fi

brctl show | grep $bridge
if [ $? != 0 ] ; then
  echo bridge not configured ... $bridge
  return
fi
echo using linux bridge $bridge 
#virsh net-create ${bridge}.xml
virsh net-list
virsh net-info $bridge
 
vname=${vm}-ram${vram}-cpu${vcpu}
qcow=${rootpath}/${vm}.qcow2

echo "CPUs: $vcpu" "RAM: $vram" $qcow
virt-install --import --noautoconsole --cpu host --connect qemu:///system --ram=${vram} --name=${mother} --vcpus=${vcpu} \
             --os-type=linux --os-variant=rhel7 --network=network:${bridge} --network=network:${bridge} \
             --disk path=${qcow},device=disk,bus=virtio,format=qcow2 # --disk path=${vdisk},device=disk,bus=virtio,format=qcow2

virsh list
#virsh domiflist $mother
echo virsh attach-interface --domain ${mother} --type network --model virtio --config --live # --source $qcow 
# virsh attach-interface --domain ${mother} --type network --model virtio --config --live # --source $qcow 
virsh domiflist $mother

scmId=$Id$

