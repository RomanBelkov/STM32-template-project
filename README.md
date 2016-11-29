# STM32-template-project

Original Makefile taken from https://github.com/stv0g/stm32cube-gcc


Great link: http://andybrown.me.uk/2015/03/22/stm32dev-windows/

## Setup Cygwin

Hope you'll figure it out by yourself. 
Andy Brown says it's good to have these packages:

- Devel/git
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

## Install the compilers

Just grab the latest from https://launchpad.net/gcc-arm-embedded in .exe and install compilers.

## Drivers

Check if any driver installation is needed
- http://www.st.com/content/st_com/en/products/embedded-software/development-tool-software/stsw-link004.html
- http://www.st.com/content/st_com/en/products/embedded-software/development-tool-software/stsw-link009.html


## Install OpenOCD

Grab the precompiled binaries from http://www.freddiechopin.info/en/download/category/4-openocd. I used version 0.9.0 (latest for Nov. 2016)

Install openOCD to preferred location. Let's do it for ~/install folder inside cygwin env.

`cd ~/install`

`7z x /cygdrive/c/Users/YourUserName/Downloads/openocd-0.9.0.7z`

If executable bit on exe's and dll's messes up in cygwin, do

`cd ~/install/openocd-0.9.0`

`find . -name '*.exe' -o -name '*.dll' -exec chmod 755 {} \;`

## Notes

Everything should now be fine. Try running 

```
make openocd
make
make program
```