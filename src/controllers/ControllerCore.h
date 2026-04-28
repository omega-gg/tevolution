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

#ifndef CONTROLLERCORE_H
#define CONTROLLERCORE_H

#ifdef QT_4
// Qt includes
#include <QImage>
#endif

// Sk includes
#include <WController>
#ifndef SK_DEPLOY
#include <WFileWatcher>
#endif

// Application includes
#include <DataLocal>

// Defines
#define core ControllerCore::instance()

// Forward declarations
class WControllerFileReply;
class DataOnline;
class WAbstractBackend;
class WAbstractHook;
class WCache;
class WBroadcastServer;
class WBackendIndex;
class WTabsTrack;
class WDeclarativePlayer;

#ifdef QT_6
Q_MOC_INCLUDE("WBroadcastServer")
Q_MOC_INCLUDE("WTabsTrack")
#endif

class ControllerCore : public WController
{
    Q_OBJECT

#ifdef SK_DESKTOP
    Q_PROPERTY(bool isFullScreen READ isFullScreen CONSTANT)
#endif

    Q_PROPERTY(WBroadcastServer * server READ server NOTIFY serverChanged)

    Q_PROPERTY(WTabsTrack * tabs READ tabs NOTIFY tabsChanged)

    Q_PROPERTY(QString number READ number NOTIFY numberChanged)

private:
    ControllerCore();

public: // Interface
#ifdef SK_DESKTOP
    Q_INVOKABLE void applyArguments(int & argc, char ** argv);
#endif

    Q_INVOKABLE void load();

    Q_INVOKABLE bool updateVersion();

    Q_INVOKABLE void resetBackends() const;

    Q_INVOKABLE void generateTag(const QString & vbml, const QString & prefix);

    Q_INVOKABLE void generateSource();

    Q_INVOKABLE void generateSourceTag(const QString & text);

    Q_INVOKABLE void clearCache();

#ifndef SK_DEPLOY
    Q_INVOKABLE void sendMessage(const QString & source);
#endif

public: // Static functions
#ifndef SK_NO_TORRENT
    Q_INVOKABLE static void applyTorrentOptions(int connections,
                                                int upload, int download, int cache);
#endif

    Q_INVOKABLE static void applyBackend(WDeclarativePlayer * player);

private: // Functions
    void createIndex();

    WControllerFileReply * copyBackends(const QString & path) const;

private slots:
    void onLoaded     ();
    void onIndexLoaded();

    void onReload();

    void onSource(const QString & source);

signals:
    void tagUpdated      (const QImage & image, const QString & text);
    void tagSourceUpdated(const QImage & image, const QString & text);

    void serverChanged();

    void tabsChanged();

    void indexChanged();

    void numberChanged();

public: // Properties
#ifdef SK_DESKTOP
    bool isFullScreen() const;
#endif

    WBroadcastServer * server();

    WTabsTrack * tabs() const;

    QString number() const;

private: // Variables
#ifdef SK_DESKTOP
    bool _fullScreen;

    QString _argument;
#endif

    DataLocal    _local;
    DataOnline * _online;

    WCache * _cache;

    WBroadcastServer * _server;

    QString _path;

    WTabsTrack * _tabs;

    WBackendIndex * _index;

    QString _number;

#ifndef SK_DEPLOY
    WFileWatcher _watcher;
#endif

private:
    Q_DISABLE_COPY      (ControllerCore)
    W_DECLARE_CONTROLLER(ControllerCore)
};

#endif // CONTROLLERCORE_H
