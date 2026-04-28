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

#ifndef DATALOCAL_H
#define DATALOCAL_H

// Sk includes
#include <WLocalObject>

class DataLocal : public WLocalObject
{
    Q_OBJECT

#ifdef SK_DESKTOP
    Q_PROPERTY(int screen READ screen WRITE setScreen NOTIFY screenChanged)
#endif

    Q_PROPERTY(bool vsync READ vsync WRITE setVsync NOTIFY vsyncChanged)

public:
    explicit DataLocal(QObject * parent = NULL);

public: // WLocalObject reimplementation
    /* Q_INVOKABLE virtual */ bool load(bool instant = false);

    /* Q_INVOKABLE virtual */ QString getFilePath() const;

protected: // WLocalObject reimplementation
    /* virtual */ WAbstractThreadAction * onSave(const QString & path);

private: // Functions
    bool extract(const QByteArray & array);

signals:
#ifdef SK_DESKTOP
    void screenChanged();
#endif

    void vsyncChanged();

#ifndef SK_NO_TORRENT
    void torrentPortChanged();

    void torrentConnectionsChanged();

    void torrentUploadChanged  ();
    void torrentDownloadChanged();

    void torrentCacheChanged();
#endif

    void broadcastPortChanged();

public: // Properties
#ifdef SK_DESKTOP
    int  screen() const;
    void setScreen(int index);
#endif

    bool vsync() const;
    void setVsync(bool enabled);

#ifndef SK_NO_TORRENT
    int  torrentPort() const;
    void setTorrentPort(int port);

    int  torrentConnections() const;
    void setTorrentConnections(int connections);

    int  torrentUpload() const;
    void setTorrentUpload(int upload);

    int  torrentDownload() const;
    void setTorrentDownload(int download);

    int  torrentCache() const;
    void setTorrentCache(int cache);
#endif

    int  broadcastPort() const;
    void setBroadcastPort(int port);

private: // Variables
    QString _version;

#ifdef SK_DESKTOP
    int _screen;
#endif

    bool _vsync;

#ifndef SK_NO_TORRENT
    int _torrentPort;

    int _torrentConnections;

    int _torrentUpload;
    int _torrentDownload;

    int _torrentCache;
#endif

    int _broadcastPort;

private:
    Q_DISABLE_COPY(DataLocal)

    friend class ControllerCore;
};

#endif // DATALOCAL_H
