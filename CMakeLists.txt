# SPDX-License-Identifier: GPL-2.0-or-later
# SPDX-FileCopyrightText: 2022, 2025 Javier O. Cordero Pérez <javiercorderoperez@gmail.com>

cmake_minimum_required(VERSION 3.22)

include(FetchContent)

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

set(QT_DEFAULT_MAJOR_VERSION 6)
set(QT_MIN_VERSION 6.5.0)
set(KF_MIN_VERSION 6.5.0)
set(KF_PREFFERED_VERSION 6.10.0)
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

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core)

find_package(Qt${QT_VERSION_MAJOR} ${QT6_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS Core Gui Qml Quick QuickControls2 Svg)
if(WIN32 OR APPLE OR WASM)
    set(BUILD_TESTING OFF)
    FetchContent_Declare(
      CoreAddons
      GIT_REPOSITORY "${CMAKE_SOURCE_DIR}/3rdparty/kcoreaddons"
      GIT_TAG        "v${KF_PREFFERED_VERSION}"
      SOURCE_DIR submodules/kcoreaddons
    )
    FetchContent_MakeAvailable(CoreAddons)
    FetchContent_Declare(
      Kirigami
      GIT_REPOSITORY "${CMAKE_SOURCE_DIR}/3rdparty/kirigami"
      GIT_TAG        "v${KF_PREFFERED_VERSION}"
      SOURCE_DIR submodules/kirigami
    )
    FetchContent_MakeAvailable(Kirigami)
    FetchContent_Declare(
      KF6SyntaxHighlighting
      GIT_REPOSITORY "${CMAKE_SOURCE_DIR}/3rdparty/syntax-highlighting"
      GIT_TAG        "v${KF_PREFFERED_VERSION}"
      SOURCE_DIR submodules/syntax-highlighting
    )
    FetchContent_MakeAvailable(KF6SyntaxHighlighting)
else()
    find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS
        Kirigami
        CoreAddons
        SyntaxHighlighting
    )
endif()
#find_package(KF6Crash ${KF6_MIN_VERSION} CONFIG QUIET)
#    set_package_properties(KF6Crash PROPERTIES
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

if (WIN32 OR UNIX) # AND NOT ANDROID
    install(FILES com.cuperino.clipboardinspector.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
    install(PROGRAMS com.cuperino.clipboardinspector.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    install(FILES ${DOCS} DESTINATION ${DOC_INSTALL_DIR})
endif()

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h *.hpp)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
