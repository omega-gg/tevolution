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

#ifndef CONTROLLERCORE_H
#define CONTROLLERCORE_H

// Sk includes
#include <WController>

// Application includes
#include <DataLocal>

// Defines
#define core ControllerCore::instance()

// Forward declarations
class DataOnline;
class WAbstractBackend;
class WAbstractHook;
class WCache;
class WDeclarativePlayer;

class ControllerCore : public WController
{
    Q_OBJECT

private:
    ControllerCore();

public: // Interface
#ifdef SK_DESKTOP
    Q_INVOKABLE void applyArguments(int & argc, char ** argv);
#endif

    Q_INVOKABLE void load();

    Q_INVOKABLE bool updateVersion();

    Q_INVOKABLE void generateSource();

    Q_INVOKABLE void generateTag(const QString & text);

    Q_INVOKABLE void clearCache();

public: // Static functions
    Q_INVOKABLE static void applyTorrentOptions(int connections,
                                                int upload, int download, int cache);

    Q_INVOKABLE static void applyHooks(WDeclarativePlayer * player);

private slots:
    void onSource(const QString & source);

signals:
    void tagUpdated(const QImage & image);

private: // Variables
#ifdef SK_DESKTOP
    QString _argument;
#endif

    DataLocal    _local;
    DataOnline * _online;

    WCache * _cache;

    QString _path;

private:
    Q_DISABLE_COPY      (ControllerCore)
    W_DECLARE_CONTROLLER(ControllerCore)
};

#endif // CONTROLLERCORE_H
