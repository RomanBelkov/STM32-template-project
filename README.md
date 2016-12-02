# STM32-template-project

Original Makefile taken from https://github.com/stv0g/stm32cube-gcc


Great link: http://andybrown.me.uk/2015/03/22/stm32dev-windows/

## Setup Cygwin

Hope you'll figure out how to setup cygwin by yourself. 

You **definitely** need to install these packages:

- Devel/make
- Devel/git


Andy Brown says it's good to have these packages:

- Devel/scons
- Net/openssh
- Net/inetutils
- Net/curl
- Archive/zip
- Archive/unzip
- Archive/pbzip2
- Archive/p7zip
- Archive/xz
- X11


Later I will revise the list for bare minimum of packages.

## Install the compilers

Just grab the latest from https://launchpad.net/gcc-arm-embedded in .exe and install compilers. I highly recommend to add environment variables to your path when promted at the last step of installation.

## Drivers

Download and install ST-LINK drivers from ST's site:

http://www.st.com/content/st_com/en/products/embedded-software/development-tool-software/stsw-link009.html


## Install OpenOCD

Grab the precompiled binaries from http://www.freddiechopin.info/en/download/category/4-openocd. I used version 0.9.0 (latest for Nov. 2016)

Install openOCD to preferred location. Let's do it for ~/install folder inside cygwin env.

`cd ~/install`

`7z x /cygdrive/c/Users/YourUserName/Downloads/openocd-0.9.0.7z`

If executable bit on exe's and dll's messes up in cygwin, do

`cd ~/install/openocd-0.9.0`

`find . -name '*.exe' -o -name '*.dll' -exec chmod 755 {} \;`

## Cube

Currently for build you'll need a version of cube.

Download it from http://www.st.com/en/embedded-software/stm32cubef4.html, unzip it, rename resulting folder to `cube`. Then place newly made `cube` folder in the same directory as your `src`, `inc` folders and Makefile.

## Notes

Everything should now be fine. Try running 

```
make openocd
make
make program
```