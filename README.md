中文使用说明

这里是《测试驱动的嵌入式C语言开发》（Test-Driven Development for Embedded C）一书随书代码的修改版本。

书中的原始源代码可以从这里下载：https://pragprog.com/titles/jgade/source_code

因为年代有些久远，原始源代码使用较新版本的gcc/clang无法正常编译，会报很多错误。这给希望在阅读过程中练习TDD的读者带来了较大麻烦，也妨碍了这本经典著作的流传。导致这本书像深谷中的一朵幽兰，乏人问津。

我花了一些时间解决了这些问题，把修改过的源代码发在这里。大多数问题是因为新版编译器（gcc & clang）加强了检查导致的，需要在Makefile中添加编译器选项，放松一些检查。还有少量问题是源代码本身的输入错误导致的。

目前的源代码在以下三种开发环境中都可以正常运行：
1. Windows7/Windows10上使用MSYS2安装的gcc/g++ 7.4
MSYS2安装包下载地址：https://www.msys2.org/
安装好MSYS2之后，可以在其安装的bash命令行窗口（桌面上会添加bash命令行窗口的图标）中使用如下命令下载安装gcc：
pacman -S gcc
1. Linux上使用系统自带的gcc/g++ 7.5
1. macOS上使用系统自带的clang/clang++ 11.0.3

源代码使用步骤：
1. 使用git check源代码，或者下载zip包之后解压缩。

1. 打开命令行窗口（Windows上打开的是MSYS2的bash命令行窗口）

1. 下载编译CPPUTest

下载地址：https://cpputest.github.io

下载之后，解压缩，假设解压缩在 ~/tools/cpputest 目录下。

首先编译 CPPUTest：
```bash
cd ~/tools/cpputest
./configure
make check
make tdd
```
如果编译没有问题，再设置 CPPUTEST_HOME 环境变量：
修改bash的配置文件（MSYS2和Fedora Linux是~/.bash_profile，Ubuntu Linux和macOS是~/.profile），加入一行：
```bash
export CPPUTEST_HOME=~/tools/cpputest
```
保存之后，在命令行执行source ~/.profile让其生效。

1. 书中第4章之前的代码，既可以使用Unity也可以使用CppUTest来做单元测试。第5章之后的代码，仅支持使用CPPUTest做单元测试。

- 使用Unity做单元测试，在源代码根目录执行：
```bash
make -i -f MakefileUnity.mk
make -i -f MakefileUnity.mk clean
```

- 使用CppUTest做单元测试，在源代码根目录执行：
```bash
make -i -f MakefileCppUTest.mk
make -i -f MakefileCppUTest.mk clean
```

- t0、t1、t2、t3目录里对应着书中后半部分各章中的源代码，仅支持使用CppUTest做单元测试，Makefile在相应目录中。
```bash
make -i -C t0
make -i -C t0 clean
make -i -C t1
make -i -C t1 clean
make -i -C t2
make -i -C t2 clean
make -i -C t3
make -i -C t3 clean
```
这本书的作者James Grening是敏捷开发的老将，敏捷宣言的发起人之一。这本书很有意思，书中使用TDD的方式，其实讲的是可测试C代码的设计方法。后面几章用C语言的函数指针+结构体实现了OOP语言里的接口、继承、多态等概念，对于改善C代码的可维护性会非常有帮助。

源代码在读者的本地环境编译没问题了，读者可以保留一个备份。然后跟着这本书的进度，把C语言源文件和对应的单元测试文件中多余的源代码、单元测试代码都删除。按照TDD的要求，小步快跑，每次先加一个单元测试，然后再加足够的源代码让单元测试通过，接下来做代码重构。严格遵照这个三步走的节奏来开发系统，深入体会TDD是如何驱动设计和代码的发展。这会是一场很有趣的经历，TDD让编程充满了乐趣。

Happy coding!