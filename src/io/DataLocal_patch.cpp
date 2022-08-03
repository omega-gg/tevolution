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

#include "DataLocal.h"

// Sk includes
#include <WControllerApplication>
#include <WControllerFile>

//-------------------------------------------------------------------------------------------------
// Functions
//-------------------------------------------------------------------------------------------------

void DataLocal_patch(QString & data, const QString & api)
{
    qWarning("DataLocal_patch: Patching.");

    QString path = wControllerFile->pathStorage();

    WControllerFile::deleteFolder(path + "/backend");
    WControllerFile::deleteFolder(path + "/cache");
    WControllerFile::deleteFolder(path + "/torrents");

    path += "/playlists/";

    WControllerFile::deleteFolder(path + "3"); // backends

    WControllerFile::deleteFile(path + "3.xml"); // backends

    // NOTE: We replace the first occurence after the 'version' tag.
    Sk::replaceFirst(&data, api, sk->version(), data.indexOf("version"));
}
