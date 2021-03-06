#!/bin/bash
set -euo pipefail

lfs_version="10.0"
if [[ "${1:-}" = "-h" || "${1:-}" = "--help" ]]; then
    echo "Usage:"
    echo "  $0"
    echo "  $0 systemd"
    exit 0
elif [[ "${1:-}" = "systemd" ]]; then
    lfs_version="${lfs_version}-systemd"
fi

function msg() {
    printf "[Vagrant LFS]: \e[32m$*\e[0m\n" >&2
}

function vagrant() {
    if hash caffeinate &> /dev/null; then
        env LFS_VERSION="${lfs_version}" caffeinate -sm vagrant "$@"
    else
        env LFS_VERSION="${lfs_version}" command vagrant "$@"
    fi
}

set -x
vmname="lfs-${lfs_version}"

export LC_ALL=C LANG=C LANGUAGE=C

if vagrant status | grep -F "not created"; then
    msg Creating a vm to build our own LFS
    vagrant up
else
    msg Reload the vm to re-build our own LFS
    vagrant reload --provision
fi

msg Building LFS ...
until vagrant ssh -c "/bin/bash /mnt/lfs/sources/lfs.sh"; do
    msg Building failed, retrying ...
    vagrant ssh -c 'sleep 60' || exit 0
    vagrant reload --provision
done

msg Build LFS done
vagrant halt

declare vm_disk
vm_disk="$(ls -t1 lfs-disk-*G.vmdk | sed -n 1p)"

if [[ -z "$vm_disk" ]]; then
    echo "Could not find the LFS disk: ${vm_disk}"
    exit 1
fi

msg Testing the created disk "${vm_disk}"

if ! VBoxManage list -s vms | grep "^\"${vmname}\""; then
    msg Create a new VM "${vmname}"
    VBoxManage createvm --name "${vmname}" --ostype Linux26_64 --register
elif VBoxManage list -s runningvms | grep "^\"${vmname}\""; then
    echo VM "${vmname}" is running.
    exit 0
fi

vm_memory="$(VBoxManage showvminfo "${vmname}" | sed -n -e "/^Memory size/p" | sed -Ee "s/^Memory size[^0-9]+([0-9]+)MB\$/\\1/")"
if (( vm_memory < 512)); then
    msg Setting memory to 512MB
    VBoxManage modifyvm "${vmname}" --memory 512
fi

if ! VBoxManage showvminfo "${vmname}" | grep -F "SATA Controller"; then
    msg Add SATA Controller
    VBoxManage storagectl "${vmname}" --name "SATA Controller" --add sata --controller IntelAhci
fi

if ! VBoxManage showvminfo "${vmname}" | grep -F "${vm_disk}"; then
    msg Attach the disk ${vm_disk}
    VBoxManage storageattach "${vmname}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${vm_disk}"
fi

VBoxManage startvm "${vmname}"
