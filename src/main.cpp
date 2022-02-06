/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: 2022 Javier O. Cordero Pérez <javiercorderoperez@gmail.com>
*/

#include <KLocalizedContext>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QIcon>
#include <QtQml>
#include "document/documenthandler.h"

#define PROGRAM_URI "com.cuperino.clipboardinspector"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/contents/images/icon.svg"));
    QCoreApplication::setOrganizationName("Cuperino");
    QCoreApplication::setOrganizationDomain(PROGRAM_URI);
    QCoreApplication::setApplicationName("Clipboard Inspector");

    qmlRegisterType<DocumentHandler>("com.cuperino.clipboardinspector.document", 1, 0, "DocumentHandler");

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
