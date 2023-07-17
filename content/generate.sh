#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

version="1.0.0-3"

version_code="7"

#--------------------------------------------------------------------------------------------------

Sky="../../Sky"

SkyBase="$Sky/src/SkyBase"

SkyTouch="$Sky/src/SkyTouch"

backend="../../backend"

#--------------------------------------------------------------------------------------------------

content="../content"

bin="../bin"

#--------------------------------------------------------------------------------------------------
# iOS

backendiOS="iOS/backend"

#--------------------------------------------------------------------------------------------------
# Android

data="android/data"

backendAndroid="android/assets/backend"

#--------------------------------------------------------------------------------------------------
# environment

qt="qt5"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

copyAndroid()
{
    cp -r $1 $data/armeabi-v7a
    cp -r $1 $data/arm64-v8a
    cp -r $1 $data/x86
    cp -r $1 $data/x86_64
}

cleanAndroid()
{
    mv $data/$1/libs $data

    rm -rf $data/$1/*

    mv $data/libs $data/$1
}

applyManifest()
{
    manifest="$data/$1/AndroidManifest.xml"

    expression='s/android:versionName=\"/android:versionName=\"'"$version"'/'

    apply $expression $manifest

    expression='s/android:versionCode=\"/android:versionCode=\"'"$2$version_code"'/'

    apply $expression $manifest
}

apply()
{
    if [ $host = "macOS" ]; then

        sed -i "" $1 $2
    else
        sed -i $1 $2
    fi
}

#--------------------------------------------------------------------------------------------------

getOs()
{
    case `uname` in
    Darwin*) echo "macOS";;
    *)       echo "other";;
    esac
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 -a $# != 2 ] \
   || \
   [ $1 != "win32" -a $1 != "win64" -a $1 != "macOS" -a $1 != "iOS" -a $1 != "linux" -a \
     $1 != "android" ] \
   || \
   [ $# = 2 -a "$2" != "all" -a "$2" != "deploy" -a "$2" != "clean" ]; then

    echo "Usage: generate <win32 | win64 | macOS | iOS | linux | android> [all | deploy | clean]"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

host=$(getOs)

if [ $1 = "win32" -o $1 = "win64" ]; then

    os="windows"

elif [ $1 = "iOS" -o $1 = "android" ]; then

    os="mobile"
else
    os="default"
fi

if [ $os = "mobile" -o "$2" = "deploy" ]; then

    path="qrc"
else
    path="$bin"
fi

cd ../dist

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

if [ "$2" = "clean" ]; then

    echo "CLEANING"

    rm -f  $bin/*.qml
    rm -rf $bin/pictures
    rm -rf $bin/icons

    rm -rf qrc
    mkdir  qrc
    touch  qrc/.gitignore

    if [ $1 = "iOS" ]; then

        rm -rf $backendiOS/*
        touch  $backendiOS/.gitignore

    elif [ $1 = "android" ]; then

        cleanAndroid armeabi-v7a
        cleanAndroid arm64-v8a
        cleanAndroid x86
        cleanAndroid x86_64

        rm -rf $backendAndroid/*
        touch  $backendAndroid/.gitignore
    fi

    exit 0
fi

#--------------------------------------------------------------------------------------------------
# QML
#--------------------------------------------------------------------------------------------------

echo "COPYING QML"

cp $content/*.qml $path

#--------------------------------------------------------------------------------------------------
# Content
#--------------------------------------------------------------------------------------------------

if [ $os = "mobile" -o "$2" = "all" -o "$2" = "deploy" ]; then

    if [ $qt = "qt6" ]; then

        echo "COPYING shaders"

        cp -r "$Sky"/deploy/shaders $path
    fi

    echo "COPYING pictures"

    cp -r $content/pictures $path

    echo "COPYING icons"

    cp -r $content/icons $path

    if [ $1 = "iOS" ]; then

        echo "COPYING backend"

        cp -r "$backend"/cover $backendiOS

        cp "$backend"/*.vbml $backendiOS

        #------------------------------------------------------------------------------------------
        # NOTE iOS: Torrents are not available.

        rm $backendiOS/index.vbml

        rm $backendiOS/bittorrent.vbml

        rm $backendiOS/cover/bittorrent.png

    elif [ $1 = "android" ]; then

        echo "COPYING android"

        copyAndroid android/res

        if [ $qt = "qt5" ]; then

            qtX="android/qt5"
        else
            qtX="android/qt6"
        fi

        cp -r "$Sky"/dist/android/src/* $qtX/src

        if [ $qt = "qt5" ]; then

            expression='s/org.qtproject.qt./org.qtproject.qt5./g'

            apply $expression $qtX/src/gg/omega/WActivity.java

            expression='s/gg.omega.provider/gg.omega.tevolution.provider/g'

            apply $expression $qtX/src/gg/omega/WActivity.java
        fi

        copyAndroid $qtX/src
        copyAndroid $qtX/*.xml

        #------------------------------------------------------------------------------------------
        # NOTE: You can comment these if you want to let Qt generate the gradle files.

        copyAndroid $qtX/*.gradle
        copyAndroid $qtX/gradle

        #------------------------------------------------------------------------------------------

        applyManifest armeabi-v7a 032
        applyManifest arm64-v8a   064
        applyManifest x86         132
        applyManifest x86_64      164

        echo "COPYING backend"

        cp -r "$backend"/cover $backendAndroid

        cp "$backend"/*.vbml $backendAndroid

        copyAndroid android/assets
    fi
fi

#--------------------------------------------------------------------------------------------------
# Icon
#--------------------------------------------------------------------------------------------------

if [ $1 = "macOS" ]; then

    echo "GENERATING icon"

    mkdir icon.iconset

    cp pictures/icon/16.png  icon.iconset/icon_16x16.png
    cp pictures/icon/24.png  icon.iconset/icon_24x24.png
    cp pictures/icon/32.png  icon.iconset/icon_32x32.png
    cp pictures/icon/48.png  icon.iconset/icon_48x48.png
    cp pictures/icon/64.png  icon.iconset/icon_64x64.png
    cp pictures/icon/128.png icon.iconset/icon_128x128.png
    cp pictures/icon/256.png icon.iconset/icon_256x256.png
    cp pictures/icon/512.png icon.iconset/icon_512x512.png

    iconutil -c icns icon.iconset

    rm -rf icon.iconset
fi

echo ""

#--------------------------------------------------------------------------------------------------
# Deployer
#--------------------------------------------------------------------------------------------------

if [ $qt = "qt4" ]; then

    imports="QtQuick=1.1"

    defines="QT_4"
else
    if [ $qt = "qt5" ]; then

        defines="QT_5 QT_NEW"
    else
        defines="QT_6 QT_NEW"
    fi

    if [ $1 = "linux" ]; then

        imports="QtQuick=2.7"
    else
        imports="QtQuick=2.14"
    fi

    if [ $qt = "qt5" ]; then

        imports="$imports QtMultimedia=5.4"
    else
        imports="$imports QtMultimedia=6.0"
    fi
fi

if [ $os = "windows" ]; then

    defines="$defines DESKTOP WINDOWS"

elif [ $1 = "macOS" ]; then

    defines="$defines DESKTOP MAC"

elif [ $1 = "iOS" ]; then

    defines="$defines MOBILE IOS NO_TORRENT"

elif [ $1 = "linux" ]; then

    defines="$defines DESKTOP LINUX"
else
    defines="$defines MOBILE ANDROID"
fi

if [ "$2" = "deploy" ]; then

    defines="$defines DEPLOY"
fi

defines="$defines pictures_tag"

files="\
$SkyBase/Style.qml \
$SkyBase/WindowSky.qml \
$SkyBase/RectangleBorders.qml \
$SkyBase/TextBase.qml \
$SkyBase/TextSubtitle.qml \
$SkyBase/BaseButton.qml \
$SkyBase/Subtitle.qml \
$SkyBase/AnimatedSlide.qml \
$SkyBase/AnimatedSlideImage.qml \
$SkyBase/CodeNumber.qml \
$SkyTouch/StyleTouch.qml \
$SkyTouch/BaseButtonTouch.qml \
$SkyTouch/ButtonTouch.qml \
$SkyTouch/ButtonTouchIcon.qml \
$SkyTouch/ButtonsWindow.qml"

#--------------------------------------------------------------------------------------------------

"$Sky"/deploy/deployer $path "$imports" qrc/tevolution.qrc "$defines" $files
