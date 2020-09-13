# Build Our Own GNU/Linux From Scratch

## Goal

The [Linux From Scratch](https://www.linuxfromscratch) project released version 10.0. It's easier to use than previous versions, such as some tasks that can be ignored were removed. The goal of this project is to automatically build our own GNU/Linux from scratch as easy as possible.

## Prerequisites

- Vagrant
- VirtualBox

## Usage

    git clone https://github.com/chaifeng/vagrant-lfs.git
    cd vagrant-lfs
    ./build.sh

It may take 5-15 hours to run. You will see a new VM up and run if everyting goes well. You will find a disk file `lfs-disk-12G.vmdk` created in the project folder. This is the disk contains our own GNU/Linux.

Good luck!

# 用源码自动编译出自己的 GNU/Linux

## 目标

Linux From Scratch 刚刚发布了 10.0，与之前的版本相比，简化了一些不必要的过程。最典型的就是在现存系统上构建基本系统时，去掉了那些可以被忽略的测试验证。本项目的目标是尽可能简单地使用源码自动化构建出一个基本的 GNU/Linux。

## 需求

- Vagrant
- VirtualBox

## 使用方法

    git clone https://github.com/chaifeng/vagrant-lfs.git
    cd vagrant-lfs
    ./build.sh

可能需要5-15小时的执行，在我的机器上大约5个小时。如果一切顺利，你会看到一个名为 `lfs-10.0` 的虚拟机运行起来了。你会在项目目录中看到一个磁盘文件 `lfs-disk-12G.vmdk` 被创建出来了。这就是包含了我们自己的 GNU/Linux 的磁盘。

祝好运！
