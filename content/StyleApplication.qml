//=================================================================================================
/*
    Copyright (C) 2020-2026 tevolution authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of tevolution.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.

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

    property int noise_interval: ms(20)

    property color noise_color: "#b4b4b4"

    //---------------------------------------------------------------------------------------------
    // Icons

    property url icon_download: "icons/download.svg"

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------
    // Global

    radius: 0

    color_highlight: "black"

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
