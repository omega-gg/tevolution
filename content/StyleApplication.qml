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

StyleTouch
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------
    // Noise

    property int noise_interval: duration(16)

    property color noise_color: "#b4b4b4"

    //---------------------------------------------------------------------------------------------
    // Pictures

    property url picture_tag: "pictures/tag.svg"

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------
    // Global

    radius: 0

    //---------------------------------------------------------------------------------------------
    // Border

    border_color: "#161616"

    //---------------------------------------------------------------------------------------------
    // Window

    window_color: "#808080"

    //---------------------------------------------------------------------------------------------
    // ButtonsWindow

    buttonsWindow_height: buttonsWindow_width
}
