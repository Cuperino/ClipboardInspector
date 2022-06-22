# SPDX-License-Identifier: GPL-2.0-or-later
# SPDX-FileCopyrightText: 2022 Javier O. Cordero Pérez <javiercorderoperez@gmail.com>

cmake_minimum_required(VERSION 3.16)

set(RELEASE_SERVICE_VERSION_MAJOR "1")
set(RELEASE_SERVICE_VERSION_MINOR "0")
set(RELEASE_SERVICE_VERSION_MICRO "0")
set(RELEASE_SERVICE_VERSION "${RELEASE_SERVICE_VERSION_MAJOR}.${RELEASE_SERVICE_VERSION_MINOR}.${RELEASE_SERVICE_VERSION_MICRO}")

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)
# Instruct CMake to create code from Qt designer ui files
set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(QT5_MIN_VERSION 5.15)
set(KF5_MIN_VERSION 5.65)

project(clipboardinspector VERSION ${RELEASE_SERVICE_VERSION})

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})

if (WIN32 OR UNIX) # AND NOT ANDROID
    include(KDEInstallDirs)
    include(KDECMakeSettings)
    include(ECMInstallIcons)
    include(ECMAddAppIcon)
endif()
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(ECMQtDeclareLoggingCategory)
include(ECMSetupVersion)
include(ECMSourceVersionControl)
include(ECMGenerateHeaders)
include(ECMPoQmTools)
include(FeatureSummary)

find_package(Qt5 ${QT5_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS Core Gui Qml QuickControls2 Svg)
find_package(Qt5 ${QT5_MIN_VERSION} NO_MODULE COMPONENTS QmlImportScanner QuickCompiler)
find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS KCoreAddons I18n SyntaxHighlighting Kirigami2)

add_subdirectory(src)

install(PROGRAMS com.cuperino.clipboardinspector.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES com.cuperino.clipboardinspector.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
