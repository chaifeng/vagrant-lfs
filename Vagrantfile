# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"

  lfs_disk_size = 12 # 12G Hard disk for LFS

  lfs_disk_size = 12 if lfs_disk_size < 12
  lfs_disk = "lfs-disk-#{lfs_disk_size}G.vmdk"
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false

    vb.memory = "8192"
    vb.cpus = 2


    unless File.exist?(lfs_disk)
      vb.customize [ "createmedium", "disk", "--filename", lfs_disk,
                     "--format", "vmdk", "--size", 1024 * lfs_disk_size ]
    end

    vb.customize [ "storageattach", :id , "--storagectl",
                   "SATA Controller", "--port", "1", "--device", "0", "--type",
                   "hdd", "--medium", lfs_disk]
  end

  config.vm.provision "shell", inline: <<-SHELL
    set -eux

    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin

    function mk() {
        for d; do
            [[ -d "$d" ]] || mkdir -pv "$d"
        done
    }

    disk_size=$((#{lfs_disk_size}*1024))
    sdb1_size=500
    swap_size=1045

		cat >/sdb.txt <<-SFDISK
		label: dos
		device: /dev/sdb
		unit: sectors

		/dev/sdb1 : start=        2048, size=     $((sdb1_size*2048)), type=83
		/dev/sdb2 : start=     $(((sdb1_size + 1)*2048)), size=    $(( (disk_size - sdb1_size - 1)*2048 )), type=5
		/dev/sdb5 : start=     $(( (sdb1_size + 1 + 1)*2048)), size=    $(( (disk_size - swap_size -1 - sdb1_size - 1 - 1)*2048)), type=83
		/dev/sdb6 : start=    $(((disk_size - 1045)*2048)), size=     $((swap_size*2048)), type=83
		SFDISK

    if [[ -b /dev/sdb && ! -b /dev/sdb5 ]]; then
        {
            echo o
            echo I
            echo /sdb.txt
            echo w
        } | fdisk /dev/sdb
        mkfs -v -t ext4 /dev/sdb1
        mkfs -v -t ext4 /dev/sdb5
        mkswap /dev/sdb6
    fi

    lfs_download_url=http://www.linuxfromscratch.org/lfs/downloads/10.0-systemd/
    lfs_folder="lfs-$(basename "${lfs_download_url}")"
    cd /vagrant
    mk "${lfs_folder}"
    cd "${lfs_folder}"
    curl --silent -LSs "${lfs_download_url}" |
        sed -n -e "/Parent Directory/,\\$p" |
        grep -o 'href="[^"]\\+"' |
        cut -d'"' -f2 |
        while read -r filename; do
            [[ "${filename}" = */* || "${filename}" = *.pdf ]] && continue
            echo Fetching ${filename}
            [[ -f "${filename}" ]] || curl --remote-name --silent -LSs "${lfs_download_url%/}/${filename}"
        done

    mk files
    pushd files
    until md5sum --check ../md5sums; do
       md5sum --check ../md5sums | sed "/OK\$/d" | cut -d: -f1 | while read file; do
            [[ -f "$file" ]] && rm -v "$file"
            grep -F "/${file}" ../wget-list | xargs wget
       done
       sleep 5
    done
    popd

    [[ -d 10.0 ]] || tar xf LFS-BOOK-10.0*.tar.xz
    lfs_source=/vagrant/${lfs_folder}/10.0
    lfs_files=/vagrant/${lfs_folder}/files

    echo "export LFS=/mnt/lfs" > /etc/profile.d/lfs.sh
    source /etc/profile.d/lfs.sh

    mk "${LFS}"

    if [[ -b /dev/sdb5 ]]; then
        mount | grep -F /dev/sdb5 || mount -v -t ext4 /dev/sdb5 "${LFS}"
    fi

    mk "${LFS}/boot"
    if [[ -b /dev/sdb1 ]]; then
        mount | grep -F /dev/sdb1 || mount -v -t ext4 /dev/sdb1 "${LFS}/boot"
    fi

    if [[ -b /dev/sdb6 ]]; then
        /sbin/swapon | grep -F /dev/sdb6 || /sbin/swapon /dev/sdb6
    fi

    mk "$LFS/sources"

    if [[ ! -f "${LFS}/sources/.done" ]]; then
       cp -rv /vagrant/${lfs_folder}/md5sums "${lfs_source}" "${lfs_files}"/* "${LFS}/sources"
       chmod -v a+wt "$LFS/sources"
       touch "${LFS}/sources/.done"
    fi

    if [[ ! -e /bin/sh-dash ]]; then
        mv -v /bin/sh /bin/sh-orig
        ln -srv /bin/bash /bin/sh
        mv -v /bin/sh-orig /bin/sh-dash
    fi

    [ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE

    declare -a packages=()
    for app in bison gcc-6 g++-6 m4; do
        hash "$app" || packages+=("$app")
    done
    hash makeinfo || packages+=(texinfo)

    if [[ -n "${packages:-}" ]]; then
        apt update
        DEBIAN_FRONTEND=noninteractive apt install -y "${packages[@]}"
    fi

    if ! update-alternatives --query gcc | grep -F /usr/bin/gcc-6; then
        update-alternatives --remove-all gcc || true
        update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 50
    fi
    if ! update-alternatives --query g++ | grep -F /usr/bin/g++-6; then
        update-alternatives --remove-all g++ || true
        update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 50
    fi

  SHELL

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    [[ -f ~/.bash_profile ]] && rm -v ~/.bash_profile
    echo '
    set +h
    umask 022
    LFS=/mnt/lfs
    LC_ALL=POSIX
    LFS_TGT=$(uname -m)-lfs-linux-gnu
    PATH=/usr/bin
    if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
    PATH=$LFS/tools/bin:$PATH
    export LFS LC_ALL LFS_TGT PATH
		' > ~/.bashrc

    source ~/.bashrc
    pushd "${LFS}/sources"
    md5sum --check md5sums

    /vagrant/gen-lfs-script.sh 10.0 > $LFS/sources/lfs.sh
    ls -l "$LFS/sources/lfs.sh"
  SHELL
end
