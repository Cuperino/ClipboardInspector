# SPDX-License-Identifier: GPL-2.0-or-later
# SPDX-FileCopyrightText: 2022 Javier O. Cordero Pérez <javiercorderoperez@gmail.com>

add_executable(clipboardinspector main.cpp
    document/documenthandler.cpp
    resources.qrc)
target_link_libraries(clipboardinspector
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    KF5::I18n
    KF5::SyntaxHighlighting)
install(TARGETS clipboardinspector ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
