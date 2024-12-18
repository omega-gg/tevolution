SK = $$_PRO_FILE_PWD_/../Sky

SK_CORE    = $$SK/src/SkCore/src
SK_GUI     = $$SK/src/SkGui/src
SK_BARCODE = $$SK/src/SkBarcode/src
SK_BACKEND = $$SK/src/SkBackend/src
SK_MEDIA   = $$SK/src/SkMedia/src
SK_TORRENT = $$SK/src/SkTorrent/src

TARGET = tevolution

!android:DESTDIR = $$_PRO_FILE_PWD_/bin

contains(QT_MAJOR_VERSION, 4) {
    QT += opengl declarative network script xml xmlpatterns svg

} else:contains(QT_MAJOR_VERSION, 5) {

    QT += opengl quick network xml xmlpatterns svg

    win32:QT += winextras

    unix:!macx:!ios:!android:QT += x11extras

    android:QT += androidextras
} else {
    QT += opengl quick network xml svg core5compat

    #----------------------------------------------------------------------------------------------
    # NOTE Qt6.3: We need the widgets for QApplication and QFileDialog(s).

    win32:QT += widgets

    macx:QT += widgets

    unix:!android:QT += widgets
}

greaterThan(QT_MAJOR_VERSION, 4) {
    unix:!macx:!ios:!android:QT += dbus
}

# C++17
contains(QT_MAJOR_VERSION, 4) {
    QMAKE_CXXFLAGS += -std=c++1z
} else {
    CONFIG += c++1z
}

DEFINES += QUAZIP_BUILD \
           SK_CORE_LIBRARY SK_GUI_LIBRARY SK_BARCODE_LIBRARY SK_BACKEND_LIBRARY SK_MEDIA_LIBRARY \
           SK_TORRENT_LIBRARY \
           SK_CHARSET SK_BACKEND_LOCAL

ios:DEFINES += SK_NO_TORRENT

win32-msvc* {
    # libtorrent: This fixes the winsock2 and std::min errors.
    DEFINES += WIN32_LEAN_AND_MEAN NOMINMAX

    # Boost: This prevents an issue with linking.
    DEFINES += BOOST_ALL_NO_LIB
}

!win32-msvc*:!ios:!android:DEFINES += CAN_COMPILE_SSE2

#DEFINES += SK_SOFTWARE

contains(QT_MAJOR_VERSION, 4) {
    CONFIG(release, debug|release) {

        win32:DEFINES += SK_WIN_NATIVE
    }
} else {
    win32:DEFINES += SK_WIN_NATIVE
}

deploy|ios|android {
    DEFINES += SK_DEPLOY

    RESOURCES = dist/qrc/tevolution.qrc
}

!win32-msvc*:!ios:!android:QMAKE_CXXFLAGS += -msse

# NOTE: This is required to load frameworks in the lib folder.
ios:QMAKE_LFLAGS += -F$$SK/lib

unix:QMAKE_LFLAGS += "-Wl,-rpath,'\$$ORIGIN'"

include($$SK/src/Sk.pri)
include(src/global/global.pri)
include(src/controllers/controllers.pri)
include(src/kernel/kernel.pri)
include(src/io/io.pri)
include(src/thread/thread.pri)
include(src/network/network.pri)
include(src/image/image.pri)
include(src/graphicsview/graphicsview.pri)
include(src/declarative/declarative.pri)
include(src/models/models.pri)
include(src/media/media.pri)
include(src/vlc/vlc.pri)
include(src/torrent/torrent.pri)

include(src/3rdparty/qtsingleapplication/qtsingleapplication.pri)
include(src/3rdparty/zlib/zlib.pri)
include(src/3rdparty/quazip/quazip.pri)
include(src/3rdparty/libcharsetdetect/libcharsetdetect.pri)
include(src/3rdparty/zxing-cpp/zxing-cpp.pri)

INCLUDEPATH += $$SK/include/SkCore \
               $$SK/include/SkGui \
               $$SK/include/SkBarcode \
               $$SK/include/SkBackend \
               $$SK/include/SkMedia \
               $$SK/include/SkTorrent \
               $$SK/include \
               $$_PRO_FILE_PWD_/include/tevolution

unix:contains(QT_MAJOR_VERSION, 4) {
    INCLUDEPATH += $$SK/include/$$QTX \
                   $$SK/include/$$QTX/QtCore \
                   $$SK/include/$$QTX/QtGui \
                   $$SK/include/$$QTX/QtDeclarative
}

greaterThan(QT_MAJOR_VERSION, 4) {
    INCLUDEPATH += $$SK/include/$$QTX \
                   $$SK/include/$$QTX/QtCore \
                   $$SK/include/$$QTX/QtGui \
                   $$SK/include/$$QTX/QtQml \
                   $$SK/include/$$QTX/QtQuick
}

unix:!macx:!ios:!android:greaterThan(QT_MAJOR_VERSION, 4) {
    INCLUDEPATH += $$SK/include/$$QTX/QtDBus
}

win32:LIBS += -L$$SK/lib -llibvlc \
              -lws2_32

win32:LIBS += -L$$SK/lib -ltorrent \
              -L$$SK/lib -lboost_system

# Windows dependency for ShellExecuteA and PostMessage
win32-msvc*:LIBS += shell32.lib User32.lib

unix:!ios:!android:LIBS += -L$$SK/lib -lvlc \
                           -L$$SK/lib -ltorrent-rasterbar \
                           -L$$SK/lib -lboost_system

# NOTE iOS: MediaPlayer is required for MP* classes.
ios:LIBS += -framework MobileVLCKit \
            -framework MediaPlayer

android:LIBS += -L$$ANDROID_LIB -lvlc \
                -L$$ANDROID_LIB -ltorrent-rasterbar \
                -L$$ANDROID_LIB -ltry_signal

unix:!macx:!ios:!android:contains(QT_MAJOR_VERSION, 4) {
    LIBS += -lX11
}

macx {
    PATH=$${DESTDIR}/$${TARGET}.app/Contents/MacOS

    QMAKE_POST_LINK = install_name_tool -change @rpath/libvlccore.dylib \
                      @loader_path/libvlccore.dylib $${DESTDIR}/libvlc.dylib;

    QMAKE_POST_LINK += install_name_tool -change @rpath/libvlc.dylib \
                       @loader_path/libvlc.dylib $$PATH/$${TARGET};

    QMAKE_POST_LINK += install_name_tool -change libtorrent-rasterbar.dylib.2.0.10 \
                       @loader_path/libtorrent-rasterbar.dylib $$PATH/$${TARGET};

    QMAKE_POST_LINK += install_name_tool -change libboost_system.dylib \
                       @loader_path/libboost_system.dylib $$PATH/$${TARGET};

    QMAKE_POST_LINK += $${QMAKE_COPY} -r $${DESTDIR}/plugins $$PATH;

    QMAKE_POST_LINK += $${QMAKE_COPY} $${DESTDIR}/libvlc.dylib     $$PATH;
    QMAKE_POST_LINK += $${QMAKE_COPY} $${DESTDIR}/libvlccore.dylib $$PATH;
}

macx:ICON = dist/icon.icns

RC_FILE = dist/tevolution.rc

OTHER_FILES += 3rdparty.sh \
               configure.sh \
               build.sh \
               deploy.sh \
               upload.sh \
               environment.sh \
               README.md \
               AUTHORS.md \
               .azure-pipelines.yml \
               content/generate.sh \
               content/icons.sh \
               content/Main.qml \
               content/StyleApplication.qml \
               content/Gui.qml \
               content/PageConnect.qml \
               content/PageTag.qml \
               include/generate.sh \
               dist/tevolution.rc \
               dist/script/start.sh \
               dist/doc/readme.md \
               dist/doc/shortcuts.md \
               dist/doc/about.md \
               dist/doc/license.md \
               dist/doc/fr/readme.md \
               dist/doc/fr/shortcuts.md \
               dist/doc/fr/about.md \
               dist/changes/1.0.0.md \
               dist/changes/1.1.0.md \
               dist/iOS/Info.plist \
               dist/iOS/LaunchScreen.storyboard \
               dist/iOS/Images.xcassets/Contents.json \
               dist/iOS/Images.xcassets/AppIcon.appiconset/Contents.json \
               dist/android/res/values/theme.xml \
               dist/android/res/drawable/splash.xml \
               dist/android/res/xml/paths.xml \
               dist/android/qt5/AndroidManifest.xml \
               dist/android/qt5/build.gradle \
               dist/android/qt5/gradle/wrapper/gradle-wrapper.properties \
               dist/android/qt6/AndroidManifest.xml \
               dist/android/qt6/build.gradle \
               dist/android/qt6/gradle/wrapper/gradle-wrapper.properties \

ios {
    # NOTE iOS: This is required for MobileVLCKit.
    Q_ENABLE_BITCODE.name  = ENABLE_BITCODE
    Q_ENABLE_BITCODE.value = NO

    QMAKE_MAC_XCODE_SETTINGS += Q_ENABLE_BITCODE

    QMAKE_INFO_PLIST = $$_PRO_FILE_PWD_/dist/iOS/Info.plist

    icons.files=$$_PRO_FILE_PWD_/dist/iOS/Images.xcassets

    # NOTE iOS: We need to specify this in Info.plist.
    launch.files=$$_PRO_FILE_PWD_/dist/iOS/Launch.storyboard

    framework.files = $$SK/lib/MobileVLCKit.framework
    framework.path  = Frameworks

    backend.files = $$_PRO_FILE_PWD_/dist/iOS/backend

    QMAKE_BUNDLE_DATA += icons launch framework backend

} android {
    ANDROID_PACKAGE_SOURCE_DIR = $$ANDROID_PACKAGE

    DISTFILES += $$ANDROID_PACKAGE/AndroidManifest.xml \
                 $$ANDROID_PACKAGE/build.gradle \
                 $$ANDROID_PACKAGE/gradle/wrapper/gradle-wrapper.properties
}
