#!/bin/bash
brctl addbr virbr0
brctl show && virsh net-list --all
virsh net-create virbr0.xml
brctl show && virsh net-list --all
virsh net-start virbr0
brctl show && virsh net-list --all
virsh net-destroy virbr0
virsh net-undefine virbr0
brctl delbr virbr0
brctl show && virsh net-list --all

