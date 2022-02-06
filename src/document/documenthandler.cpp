/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: 2022 Javier O. Cordero Pérez <javiercorderoperez@gmail.com>
*/

#include "documenthandler.h"

#include <vector>

#include <QFile>
#include <QFileInfo>
#include <QFileSelector>
#include <QMimeDatabase>
#include <QQmlFile>
#include <QQmlFileSelector>
#include <QQuickTextDocument>
#include <QTextCharFormat>
#include <QTextCodec>
#include <QTextDocument>
#include <QTextBlock>
#include <QApplication>
#include <QClipboard>
#include <QMimeData>
#include <QDebug>

#include <KI18n/KLocalizedString>

DocumentHandler::DocumentHandler(QObject *parent)
: QObject(parent)
, m_code(nullptr)
, m_output(nullptr)
, m_cursorPosition(-1)
, m_selectionStart(0)
, m_selectionEnd(0)
{
}

QQuickTextDocument *DocumentHandler::code() const
{
    return m_code;
}

QQuickTextDocument *DocumentHandler::output() const
{
    return m_output;
}

QQuickTextDocument *DocumentHandler::mimeText() const
{
    return m_mimeText;
}

void DocumentHandler::setCode(QQuickTextDocument *document)
{
    if (document == m_code)
        return;

    if (m_code)
        m_code->textDocument()->disconnect(this);
    m_code = document;
    if (m_code) {
        connect(m_code->textDocument(), &QTextDocument::modificationChanged, this, &DocumentHandler::modifiedChanged);
    }
    emit codeChanged();
}

void DocumentHandler::setOutput(QQuickTextDocument *document)
{
    if (document == m_output)
        return;

    if (m_output)
        m_output->textDocument()->disconnect(this);
    m_output = document;
    if (m_output) {
        connect(m_output->textDocument(), &QTextDocument::modificationChanged, this, &DocumentHandler::modifiedChanged);
    }
    emit codeChanged();
}

void DocumentHandler::setMimeText(QQuickTextDocument *document)
{
    if (document == m_mimeText)
        return;

    if (m_mimeText)
        m_mimeText->textDocument()->disconnect(this);
    m_mimeText = document;
    if (m_mimeText) {
        connect(m_mimeText->textDocument(), &QTextDocument::modificationChanged, this, &DocumentHandler::modifiedChanged);
    }
    emit codeChanged();
}

int DocumentHandler::cursorPosition() const
{
    return m_cursorPosition;
}

void DocumentHandler::setCursorPosition(int position)
{
    if (position == m_cursorPosition)
        return;

    m_cursorPosition = position;
    reset();
    emit cursorPositionChanged();
}

int DocumentHandler::selectionStart() const
{
    return m_selectionStart;
}

void DocumentHandler::setSelectionStart(int position)
{
    if (position == m_selectionStart)
        return;

    m_selectionStart = position;
    emit selectionStartChanged();
}

int DocumentHandler::selectionEnd() const
{
    return m_selectionEnd;
}

void DocumentHandler::setSelectionEnd(int position)
{
    if (position == m_selectionEnd)
        return;

    m_selectionEnd = position;
    emit selectionEndChanged();
}

QString DocumentHandler::fileName() const
{
    const QString filePath = QQmlFile::urlToLocalFileOrQrc(m_fileUrl);
    const QString fileName = QFileInfo(filePath).fileName();
    if (fileName.isEmpty())
        return QStringLiteral("untitled.txt");
    return fileName;
}

QString DocumentHandler::fileType() const
{
    return QFileInfo(fileName()).suffix();
}

QUrl DocumentHandler::fileUrl() const
{
    return m_fileUrl;
}

void DocumentHandler::saveAs(const QUrl &fileUrl)
{
    QTextDocument *doc = codeDocument();
    if (!doc)
        return;

    const QString filePath = fileUrl.toLocalFile();
    const bool isHtml = QFileInfo(filePath).suffix().contains(QLatin1String("html"));
    QFile file(filePath);
    if (!file.open(QFile::WriteOnly | QFile::Truncate | (isHtml ? QFile::NotOpen : QFile::Text))) {
        emit error(tr("Cannot save: ") + file.errorString());
        return;
    }
    file.write((isHtml ? doc->toHtml() : doc->toPlainText()).toUtf8());
    file.close();

    doc->setModified(false);

    if (fileUrl == m_fileUrl)
        return;

    m_fileUrl = fileUrl;
    emit fileUrlChanged();
}

void DocumentHandler::save()
{
    const QString fileName = QQmlFile::urlToLocalFileOrQrc(m_fileUrl);
    saveAs(fileName);
}

void DocumentHandler::reset()
{
}

QTextCursor DocumentHandler::codeCursor() const
{
    QTextDocument *doc = codeDocument();
    if (!doc)
        return QTextCursor();

    QTextCursor cursor = QTextCursor(doc);
    cursor.setPosition(QTextCursor::Start);
    cursor.setPosition(QTextCursor::End, QTextCursor::KeepAnchor);
    return cursor;
}

QTextCursor DocumentHandler::outputCursor() const
{
    QTextDocument *doc = outputDocument();
    if (!doc)
        return QTextCursor();

    QTextCursor cursor = QTextCursor(doc);
    cursor.setPosition(QTextCursor::Start);
    cursor.setPosition(QTextCursor::End, QTextCursor::KeepAnchor);
    return cursor;
}

QTextCursor DocumentHandler::mimeCursor() const
{
    QTextDocument *doc = mimeDocument();
    if (!doc)
        return QTextCursor();

    QTextCursor cursor = QTextCursor(doc);
    cursor.setPosition(QTextCursor::Start);
    cursor.setPosition(QTextCursor::End, QTextCursor::KeepAnchor);
    return cursor;
}

QTextDocument *DocumentHandler::codeDocument() const
{
    if (!m_code)
        return nullptr;

    return m_code->textDocument();
}

QTextDocument *DocumentHandler::outputDocument() const
{
    if (!m_output)
        return nullptr;

    return m_output->textDocument();
}

QTextDocument *DocumentHandler::mimeDocument() const
{
    if (!m_mimeText)
        return nullptr;

    return m_mimeText->textDocument();
}

bool DocumentHandler::modified() const
{
    return m_code && m_code->textDocument()->isModified();
}

void DocumentHandler::setModified(bool m)
{
    if (m_code)
        m_code->textDocument()->setModified(m);
}

QString DocumentHandler::mimeType() const
{
    const QClipboard *clipboard = QApplication::clipboard();
    const QMimeData *mimeData = clipboard->mimeData();
    return mimeData->formats().join(", ");
}

void DocumentHandler::paste()
{
    QTextCursor codeCursor = this->codeCursor();
    codeCursor.beginEditBlock();
    codeCursor.movePosition(QTextCursor::Start);
    codeCursor.movePosition(QTextCursor::End, QTextCursor::KeepAnchor);

    QTextCursor outputCursor = this->outputCursor();
    outputCursor.beginEditBlock();
    outputCursor.movePosition(QTextCursor::Start);
    outputCursor.movePosition(QTextCursor::End, QTextCursor::KeepAnchor);

    QTextCursor mimeCursor = this->mimeCursor();
    mimeCursor.beginEditBlock();
    mimeCursor.movePosition(QTextCursor::Start);
    mimeCursor.movePosition(QTextCursor::End, QTextCursor::KeepAnchor);

    const QClipboard *clipboard = QApplication::clipboard();
    const QMimeData *mimeData = clipboard->mimeData();
//     emit mimeDataUpdated();

    mimeCursor.insertText(mimeData->formats().join("; "));
    if (mimeData->hasImage()) {
        codeCursor.insertText(mimeData->text());
        outputCursor.insertText(i18n("Image preview not implemented"));
    }
    else if (mimeData->hasHtml()) {
        codeCursor.insertText(mimeData->html());
        outputCursor.insertHtml(mimeData->html());
    }
    else if (mimeData->hasText()) {
        codeCursor.insertText(mimeData->text());
        outputCursor.insertText(mimeData->text());
    } else {
        codeCursor.insertText(i18n("Unknown MIME"));
        outputCursor.insertText(i18n("Cannot display data"));
    }
    codeCursor.endEditBlock();
    outputCursor.endEditBlock();
    mimeCursor.endEditBlock();
}

void DocumentHandler::copy()
{
    QClipboard *clipboard = QApplication::clipboard();

    QTextCursor cursor = this->codeCursor();
    cursor.movePosition(QTextCursor::Start);
    cursor.movePosition(QTextCursor::End, QTextCursor::KeepAnchor);

    QString codeCopy = cursor.selectedText();
    clipboard->setText(codeCopy);
}
