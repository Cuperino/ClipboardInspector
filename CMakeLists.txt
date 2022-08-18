# SPDX-License-Identifier: GPL-2.0-or-later
# SPDX-FileCopyrightText: 2022 Javier O. Cordero Pérez <javiercorderoperez@gmail.com>

cmake_minimum_required(VERSION 3.16)

set(RELEASE_SERVICE_VERSION_MAJOR "1")
set(RELEASE_SERVICE_VERSION_MINOR "0")
set(RELEASE_SERVICE_VERSION_MICRO "0")
set(RELEASE_SERVICE_VERSION "${RELEASE_SERVICE_VERSION_MAJOR}.${RELEASE_SERVICE_VERSION_MINOR}.${RELEASE_SERVICE_VERSION_MICRO}")

project(clipboardinspector
    VERSION ${RELEASE_SERVICE_VERSION}
    DESCRIPTION "Clipboard inspection tool"
    HOMEPAGE_URL "https://cuperino.com/"
    LANGUAGES CXX)

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)
# Instruct CMake to create code from Qt designer ui files
set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# Leave C++ standard at version 17 to build Ubuntu 18.04 compatible AppImage
set(CMAKE_CXX_STANDARD 17)
# Instruct CMake to run moc automatically when needed
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(QT_DEFAULT_MAJOR_VERSION 5)
set(QT_MIN_VERSION 5.15.2)
# KF5 and ECM 5.68 for Ubuntu 20.04 based Snap package.
# KF5 5.78 for Ubuntu 21.04 and Debian 11, which require no backporting
# Use 5.83 ECM on Windows to make use of ecm_add_app_icon syntax
if (WIN32)
    set(ECM_MIN_VERSION 5.83.0)
else()
    set(ECM_MIN_VERSION 5.68.0)
endif()
set(KF_MIN_VERSION 5.68.0)
if (APPLE)
    set(APPLE_SUPPRESS_X11_WARNING ON)
endif()
# ------------------------- BEGIN: lists to maintain manually -------------------------

# Directories where Qt Creator can find QML files of Kirigami etc. on your system.
#   (This setting is cached in variable QML_IMPORT_DIR, see below. Delete
#   ${BUIL_DIR}/CMakeCache.txt to make make changes here effective.)
if (UNIX AND NOT APPLE AND NOT ANDROID)
    list(APPEND QML_DIRS "/usr/lib/x86_64-linux-gnu/qt5/qml")
    list(APPEND KIRIGAMI_DIRS "/usr/lib/x86_64-linux-gnu/qt5/qml/org/kde/kirigami.2")
elseif (UNIX AND APPLE)
    list(APPEND QML_DIRS "/opt/homebrew/lib/qml")
    list(APPEND KIRIGAMI_DIRS "/opt/homebrew/lib/qml/org/kde/kirigami.2")
elseif (WIN32)
    list(APPEND QML_DIRS "C:/CraftRoot/qml")
    list(APPEND KIRIGAMI_DIRS "C:/CraftRoot/qml/org/kde/kirigami.2")
endif()

# ------------------------- END: lists to maintain manually -------------------------

# Prevent adding duplicate values at each run of CMake.
list(REMOVE_DUPLICATES QML_DIRS)

# Tell Qt Creator where to find QML files.
# (The build process will work without this, but no code completion etc..)
# The variable is cached in ${BUILD_DIR}/CMakeCache.txt. We need FORCE to change it there immediately.
set(
    QML_IMPORT_PATH ${KIRIGAMI_DIRS}
    QML_IMPORT_PATH ${QML_DIRS}
    CACHE STRING "Qt Creator 4.1 extra qml import paths"
    FORCE
)

if(ANDROID)
    set(ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android)
        if(NOT ANDROID_ABIS)
                set(ANDROID_ABIS "armeabi-v7a") # arm64-v8a
        endif()
else()
set(DBINARY_ICONS_RESOURCE ON)
endif()

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "MinSizeRel")
endif()

# Send compiled program and library binaries to "build/bin"
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core)

find_package(Qt${QT_VERSION_MAJOR} ${QT5_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS Core Gui Qml QuickControls2 Svg)
find_package(Qt${QT_VERSION_MAJOR} ${QT5_MIN_VERSION} NO_MODULE COMPONENTS QmlImportScanner QuickCompiler)
find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS Kirigami2 I18n CoreAddons SyntaxHighlighting)
#find_package(KF5Crash ${KF5_MIN_VERSION} CONFIG QUIET)
#    set_package_properties(KF5Crash PROPERTIES
#    DESCRIPTION "Graceful handling of application crashes."
#    TYPE OPTIONAL
#)

if (WIN32 OR UNIX) # AND NOT ANDROID
    include(KDEInstallDirs)
    include(KDECMakeSettings)
    include(ECMInstallIcons)
    include(ECMAddAppIcon)
    include(ECMGenerateHeaders)
endif()
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(ECMQtDeclareLoggingCategory)
include(ECMSetupVersion)
include(ECMSourceVersionControl)
include(ECMPoQmTools)
include(FeatureSummary)

add_subdirectory(src)
ki18n_install(po)

if (WIN32 OR UNIX) # AND NOT ANDROID
    install(FILES com.cuperino.clipboardinspector.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
    install(PROGRAMS com.cuperino.clipboardinspector.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    install(FILES ${DOCS} DESTINATION ${DOC_INSTALL_DIR})
endif()

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h *.hpp)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
