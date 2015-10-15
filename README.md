AGL Demo Platform - Modello HomeScreen
======================================

<strong>An automotive HTML5 Homescreen running on top of AGL Demo Platform & Qt5

contact : Manuel BACHMANN (http://iot.bzh/en/author)</strong>


## Description

 <strong>Modello Homescreen</strong> provides a HTML5 interface for vehicles, using both W3C and platform-specific APIs.
 It is here running on top of Qt5 browser engine within Weston IVI-Shell.

 This repository provides a customized image of AGL Demo Platform, most notably featuring :
 * Weston IVI-Shell (enabled by default) ;
 * Wayland IVI Extension (enabled by default) ;
 * Qt 5.5 with examples ;
 * Modello Homescreen ;
 * Modello Dashboard.

![Modello screenshot 1](http://iot.bzh/images/images/agl_dp-qt-modello_2-small.jpg)
![Modello screenshot 2](http://iot.bzh/images/images/agl_dp-qt-modello_4-small.jpg)

 Limitations :
 * Platform-specific APIs have been disabled (hence why the "Apps" menu does not work e.g.) ;
 * Only 2 sample applications are provided.

## Installation

On a [Yocto-ready system](http://www.yoctoproject.org/docs/1.8/yocto-project-qs/yocto-project-qs.html), do the following :

<strong>$ git clone https://github.com/iotbzh/AGL  
$ cd AGL  
$ git checkout modello-homescreen-demo</strong>

   To create a Renesas R-Car Porter/Koelsch image :  
<strong>./build_porter.sh</strong>

   To create a QEMU image :  
<strong>./build_qemu.sh</strong>
