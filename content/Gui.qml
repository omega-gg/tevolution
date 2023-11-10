//=================================================================================================
/*
    Copyright (C) 2020 tevolution authors. <http://omega.gg/tevolution>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of tevolution.

    - Private License Usage:
    tevolution licensees holding valid private licenses may use this file in accordance with the
    private license agreement provided with the Software or, alternatively, in accordance with the
    terms contained in written agreement between you and tevolution authors. For further
    information contact us at contact@omega.gg.
*/
//=================================================================================================

import QtQuick 1.0
import Sky     1.0

Item
{
    id: gui

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property int step: pGetStep()

    property bool asynchronous: true

    /* read */ property variant server: core.server

    /* read */ property variant currentTab: core.tabs.currentTab

    property int size: (st.isTight) ? height / 3
                                    : Math.min(width, height) / 2

    // NOTE: Margins are 56 pixels on a 512 tag.
    property int sizeTag: size * 0.890625

    property variant tagImage: null

    // NOTE: This is useful to keep the tag visible during the opacity animation.
    property bool tagVisible: false

    //---------------------------------------------------------------------------------------------
    // Style

    /* read */ property int durationAnimation: st.ms1000

    //---------------------------------------------------------------------------------------------
    // Private

//#!MOBILE
    // NOTE: The update button is only visible on the landing page.
    property bool pVersion: (step == 0 && online.version && online.version != sk.version)
//#END

    property int pSizeLoader: height / 128

    property bool pAudio: (player.outputActive == AbstractBackend.OutputAudio || player.isAudio
                           ||
                           player.hasOutput)

    property bool pCoverActive: (step > 1 && (player.isStopped || player.isStarting
                                              ||
                                              player.isResuming || pAudio))

    property string pCover: ""

    property int pStep: -1

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    opacity: 0

    //---------------------------------------------------------------------------------------------
    // Animations
    //---------------------------------------------------------------------------------------------

    Behavior on opacity
    {
        PropertyAnimation
        {
            duration: st.duration_normal

            easing.type: st.easing
        }
    }

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
        core.applyBackend(player);

        opacity = 1.0;

        core.generateSource();

        // NOTE: Updating screen savers right away.
        onActiveChanged();
    }

    onPCoverActiveChanged:
    {
        if (pStep < 2 || (pStep == 2 && step == 1))
        {
            behaviorOpacity.enabled = true;

            if (pCoverActive) cover.opacity = 1.0;
            else              cover.opacity = 0.0;

            behaviorOpacity.enabled = false;
        }
        else if (pCoverActive) cover.opacity = 1.0;
        else                   cover.opacity = 0.0;

        pStep = step;
    }

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: sk

        /* QML_CONNECTION */ function onPlaybackUpdated(status)
        {
            if      (status == Sk.Play)  player.play ();
            else if (status == Sk.Pause) player.pause();
            else                         player.stop ();
        }
    }

//#DESKTOP
    Connections
    {
        target: server

        /* QML_CONNECTION */ function onConnectedChanged()
        {
            if (server.isConnected) pActivate();
        }
    }
//#END

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function toggleFullScreen()
    {
        if (window.fullScreen == false)
        {
            window.fullScreen = true;

            if (player.isPlaying == false) return;

            window.idle = true;
        }
        else pRestoreFullScreen();
    }

    //---------------------------------------------------------------------------------------------
    // Events

    function onMessageReceived(message) {}

    function onBeforeClose() {}

    function onActiveChanged()
    {
        // NOTE: When active we want to avoid screen savers at all time.
        if (window.isActive)
        {
            sk.screenDimEnabled   = false;
            sk.screenSaverEnabled = false;
        }
        else
        {
//#ANDROID
            player.pause();
//#END

            sk.screenDimEnabled   = true;
            sk.screenSaverEnabled = true;
        }
    }

    function onIdleChanged()
    {
        if (window.idle) sk.cursorVisible = false;
        else             sk.cursorVisible = true;
    }

    //---------------------------------------------------------------------------------------------
    // Keys

    function onKeyPressed(event)
    {
        if (event.key == Qt.Key_Escape)
        {
            event.accepted = true;

            pClose();
        }
        else if (event.key == Qt.Key_Q && event.modifiers == Qt.ControlModifier)
        {
            event.accepted = true;

            window.close();
        }
        else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
        {
            event.accepted = true;

            toggleFullScreen()
        }
//#!DEPLOY
        else if (event.key == Qt.Key_F10)
        {
            event.accepted = true;

            pTakeShotC();
        }
        else if (event.key == Qt.Key_F11)
        {
            event.accepted = true;

            pTakeShotB();
        }
        else if (event.key == Qt.Key_F12)
        {
            event.accepted = true;

            pTakeShotA();
        }
//#END
    }

    function onKeyReleased(event) {}

    //---------------------------------------------------------------------------------------------

    function keyPressed(event) {}

    function keyReleased(event) {}

    //---------------------------------------------------------------------------------------------
    // Private

//#DESKTOP
    function pActivate()
    {
        if (window.isActive) return;

        window.activate();
    }
//#END

    function pClose()
    {
        window.close();
    }

    function pRestoreFullScreen()
    {
        window.fullScreen = false;
//#!MAC+!MOBILE
        // FIXME macOS: We can't go from full screen to normal window right away.
        //              This could be related to the animation.
        window.maximized = false;
//#END
    }

    function pGetStep()
    {
        if (player.hasStarted)
        {
            return 3;
        }
        else if (server.isConnected)
        {
            if (player.source) return 2;
            else               return 1;
        }
        else return 0;
    }

    function pGetCover()
    {
        var cover = currentTab.cover;

        // NOTE: We want to avoid a blank cover when the track is loading.
        if (currentTab.isLoading && cover == "")
        {
            return pCover;
        }
        else return cover;
    }

//#!DEPLOY
    //---------------------------------------------------------------------------------------------
    // Dev

    function pTakeShotA() // Desktop
    {
        window.clearHover();

        window.hoverEnabled = false;

        var width = 1920;

        window.width  = width;
        window.height = width * 0.5625; // 16:9 ratio

        st.ratio = 2.0;

        // NOTE desktop: We want to avoid the black bars on the cover.
        cover.fillMode = AbstractBackend.PreserveAspectCrop;

        var path = "../dist/screens";

        pLoadShotA();

        pSaveShotA(path + "/tevolutionA.png");

        pLoadShotB();

        pSaveShotA(path + "/tevolutionB.png");

        pLoadShotC();

        pSaveShotA(path + "/tevolutionC.png");

        pLoadShotD();

        pSaveShotA(path + "/tevolutionD.png");

        window.compressShots(path);

        window.close();
    }

    function pTakeShotB() // iOS
    {
        window.clearHover();

        window.hoverEnabled = false;

        window.borderSize = 0;

        var path = "../dist/pictures/iOS";

        pLoadShotA();

        pSaveShotC(path + "/A");

        pLoadShotB();

        pSaveShotC(path + "/B");

        pLoadShotC();

        pSaveShotC(path + "/C");

        pLoadShotD();

        pSaveShotC(path + "/D");

        window.compressShots(path);

        window.close();
    }

    function pTakeShotC() // Android
    {
        window.clearHover();

        window.hoverEnabled = false;

        window.borderSize = 0;

        st.ratio = 1.0;

        window.width  = 1024;
        window.height = 500;

        var path = "../dist/pictures/android";

        pLoadShotA();

        pSaveShotB(path + "/tevolution.jpg", 90);

        st.ratio = 3.497;

        window.width  = 2560;
        window.height = 1440;

        pSaveShotB(path + "/tevolutionMobileA.jpg", -1);

        pLoadShotB();

        pSaveShotB(path + "/tevolutionMobileB.jpg", -1);

        pLoadShotC();

        pSaveShotB(path + "/tevolutionMobileC.jpg", -1);

        pLoadShotD();

        pSaveShotB(path + "/tevolutionMobileD.jpg", -1);

        window.compressShots(path);

        window.close();
    }

    //---------------------------------------------------------------------------------------------

    function pLoadShotA()
    {
        core.generateSourceTag("https://omega.gg/tevolution");

        loaderConnect.item.codeNumber.text = "123 123 123 123";

        // NOTE: Wait for the VideoTag to load.
        sk.wait(2000);
    }

    function pLoadShotB()
    {
        step = 1;

        flag.running = false;
    }

    function pLoadShotC()
    {
        step = 2;

        core.sendMessage("https://www.youtube.com/watch?v=n5vjV4hwRxo");

        // NOTE: Wait for the source to load.
        sk.wait(2000);

        itemLoading.running = false;

        itemLoading.opacity = 1.0;
    }

    function pLoadShotD()
    {
        itemLoading.visible = false;

        player.videoTag = true;
    }

    //---------------------------------------------------------------------------------------------

    function pSaveShotA(path)
    {
        sk.wait(1000);

        window.saveShot(path);
    }

    function pSaveShotB(path, quality)
    {
        sk.wait(1000);

        window.saveShot(path, 0, 0, -1, -1, "jpg", quality);
    }

    function pSaveShotC(path)
    {
        st.ratio = 3.0;

        window.width  = 2688;
        window.height = 1242;

        pSaveShotB(path + "A.jpg", -1);

        window.width  = 2208;
        window.height = 1242;

        pSaveShotB(path + "B.jpg", -1);

        st.ratio = 2.0;

        window.width  = 2732;
        window.height = 2048;

        pSaveShotB(path + "C.jpg", -1);
    }
//#END

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

//#DESKTOP
    ViewDrag
    {
        anchors.fill: parent

        dragEnabled: (window.fullScreen == false)

        cursor: Qt.PointingHandCursor

        onDoubleClicked: toggleFullScreen()
    }
//#END

    Rectangle
    {
        anchors.fill: parent

        visible: (opacity != 0.0)

        opacity: (step > 1) ? 1.0 : 0.0

        color: "black"

        Behavior on opacity
        {
            PropertyAnimation
            {
                duration: durationAnimation

                easing.type: st.easing
            }
        }
    }

    Player
    {
        id: player

        anchors.fill: parent

        visible: (hasStarted && pAudio == false)

        server: gui.server

        tabs: core.tabs

        onClearCache: core.clearCache()

//#DESKTOP
        onIsPlayingChanged: if (isPlaying) pActivate()
//#END

        onHasStartedChanged:
        {
            if (hasStarted) sk.showPlayback(currentTab.title, currentTab.author);
            else            sk.hidePlayback();
        }

//#DESKTOP
        onSourceChanged:
        {
            pActivate();

            if (hasStarted == false) return;

            sk.showPlayback(currentTab.title, currentTab.author);
        }
//#ELSE
        onSourceChanged:
        {
            if (hasStarted == false) return;

            sk.showPlayback(currentTab.title, currentTab.author);
        }
//#END
    }

    // FIXME: When resuming the player gets black right before starting.
    //        So we make sure we have the cover in the foreground.
    ImageScale
    {
        id: cover

        anchors.fill: player

        visible: (opacity != 0.0)
        opacity: 0.0

        source: pGetCover()

        sourceDefault: st.picture_flag

        fillMode: player.fillMode

        cache: false

        onLoaded: sourceDefault = st.picture_flag

        // NOTE: When we switch from playback to the cover we want to avoid blinking on the
        //       previous cover.
        onVisibleChanged:
        {
            if (visible)
            {
                if (pCover)
                {
                    loadSource(pCover);
                }
                else sourceDefault = st.picture_flag;

                asynchronous = gui.asynchronous;
            }
            else
            {
                // NOTE: Backuping the old cover to avoid setting it to 'pixmap' in clearPixmap.
                var cover = pCover;

                clearPixmap();

                pCover = cover;

                // NOTE: Clearing sourceDefault to avoid blinking on it when switching to visible.
                sourceDefault = "";

                // NOTE: Disabling asynchronous so we can load the cover as fast as possible before
                //       it gets visible.
                asynchronous = false;
            }
        }

        onSourceChanged: pCover = source

        Behavior on opacity
        {
            id: behaviorOpacity

            enabled: false

            PropertyAnimation
            {
                duration: durationAnimation

                easing.type: st.easing
            }
        }
    }

    Noise
    {
        id: noise

        anchors.fill: parent

        visible: (opacity != 0.0)

        opacity: (step == 0) ? 1.0 : 0.0

        interval: st.noise_interval

//#QT_NEW
        fillMode: Noise.PreserveAspectCrop
//#END

        color: st.noise_color

        Behavior on opacity
        {
            PropertyAnimation
            {
                duration: durationAnimation

                easing.type: st.easing
            }
        }
    }

    AnimatedLoader
    {
        id: flag

        anchors.fill: parent

        opacity: (step == 1) ? 1.0 : 0.0

        durationAnimation: gui.durationAnimation
    }

    Loader
    {
//#!DEPLOY
        id: loaderConnect
//#END

        anchors.fill: parent

        source: (step < 2 || tagVisible) ? "PageConnect.qml" : ""

//#QT_NEW
        asynchronous: true
//#END
    }

    Loader
    {
        anchors.fill: parent

        source: (step > 1 && player.videoTag) ? "PageTag.qml" : ""

//#QT_NEW
        asynchronous: true
//#END
    }

    Subtitle
    {
        player: player

        function onUpdateMargin()
        {
            margin = applySize(player, cover);
        }
    }

    AnimatedLoader
    {
//#!DEPLOY
        id: itemLoading
//#END

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: parent.bottom

        height: pSizeLoader

        opacity: (player.isPlaying && player.isLoading) ? 0.8 : 0.0
    }

    ButtonTouchIcon
    {
        margins: st.dp8

//#MOBILE
            // NOTE mobile: Updates are handled by the stores.
            visible: false
//#ELIF WINDOWS
            // NOTE windows/uwp: Updates are handled by the store.
            visible: (sk.isUwp == false && pVersion)
//#ELSE
            visible: pVersion
//#END

        highlighted: isFocused

        icon: st.icon_download

        onClicked:
        {
            // NOTE: We add a two step click to avoid updating by mistake.
            if (isFocused == false)
            {
                setFocus();

                return;
            }

            if (core.updateVersion())
            {
                window.close();

                return;
            }

            Qt.openUrlExternally("https://omega.gg/tevolution/get");
        }
    }

//#DESKTOP
    ButtonsWindow
    {
        anchors.top  : parent.top
        anchors.right: parent.right

        visible: (window.isEntered && window.idle == false)

//#QT_NEW
        buttonMinimize.margins: st.dp10
        buttonMaximize.margins: st.dp10
        buttonClose   .margins: st.dp6
//#END

        buttonMinimize.visible: (st.isTight == false)
        buttonMaximize.visible: buttonMinimize.visible
    }
//#END
}
