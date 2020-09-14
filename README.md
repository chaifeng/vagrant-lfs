# Build Our Own GNU/Linux From Scratch

## Goal

The goal of this project is to automatically build our own basic GNU/Linux from scratch as easy as possible. 

The [Linux From Scratch](https://www.linuxfromscratch) project released version 10.0. It's easier to use than previous versions, such as some tasks that can be ignored were removed. But we still have to enter hundreds of commands in 1 or 2 days. It's boring. By using this project, we can get our own GNU/Linux with just one command, and everything is compiled from source code.

## Prerequisites

- Vagrant
- VirtualBox

## Usage

    git clone https://github.com/chaifeng/vagrant-lfs.git
    cd vagrant-lfs
    ./build.sh

It may take 7-15 hours to run. You will see a new VM up and run if everyting goes well. You will also find a disk file `lfs-disk-12G.vmdk` created in the project folder. This is the disk contains our own GNU/Linux.

Or manually

    git clone https://github.com/chaifeng/vagrant-lfs.git
    cd vagrant-lfs
    vagrant up
    vagrant ssh -c "/bin/bash /mnt/lfs/sources/lfs.sh"

If the command fails, just re-execute it. Then creating a virtual machine using the disk file `lfs-disk-12G.vmdk` in the project folder.

Good luck!

# 用源码自动编译出自己的 GNU/Linux

## 目标

本项目的目标是尽可能简单地使用源码自动化构建出一个基本的 GNU/Linux。

Linux From Scratch 刚刚发布了 10.0，与之前的版本相比，简化了一些不必要的过程。最典型的就是在现存系统上构建基本系统时，去掉了那些可以被忽略的测试验证。但我们仍然需要在1、2天内自己输入好几百条命令，真是太没劲了。使用这个项目，只需一个命令就能得到我们自己的 GNU/Linux，所有的东西都是从源码编译出来的。

## 需求

- Vagrant
- VirtualBox

## 使用方法

    git clone https://github.com/chaifeng/vagrant-lfs.git
    cd vagrant-lfs
    ./build.sh

可能需要7-15小时的执行，在我的机器上大约8个小时。如果一切顺利，你会看到一个名为 `lfs-10.0` 的虚拟机运行起来了。也会在项目目录中看到一个磁盘文件 `lfs-disk-12G.vmdk` 被创建出来了。这就是包含了我们自己的 GNU/Linux 的磁盘。

或者手动执行

    git clone https://github.com/chaifeng/vagrant-lfs.git
    cd vagrant-lfs
    vagrant up
    vagrant ssh -c "/bin/bash /mnt/lfs/sources/lfs.sh"

如果命令执行出错就直接重复执行。最后创建一个虚拟机，使用项目目录下的 `lfs-disk-12G.vmdk` 磁盘文件。

祝好运！
