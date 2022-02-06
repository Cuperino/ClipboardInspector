/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: 2022 Javier O. Cordero Pérez <javiercorderoperez@gmail.com>
*/

#ifndef DOCUMENTHANDLER_H
#define DOCUMENTHANDLER_H

#include <QFont>
#include <QObject>
#include <QTextCursor>
#include <QUrl>

QT_BEGIN_NAMESPACE
class QTextDocument;
class QQuickTextDocument;
QT_END_NAMESPACE

class DocumentHandler : public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(QQuickTextDocument *mimeText READ mimeText WRITE setMimeText NOTIFY mimeTextChanged)
    Q_PROPERTY(QQuickTextDocument *code READ code WRITE setCode NOTIFY codeChanged)
    Q_PROPERTY(QQuickTextDocument *output READ output WRITE setOutput NOTIFY outputChanged)
    Q_PROPERTY(int cursorPosition READ cursorPosition WRITE setCursorPosition NOTIFY cursorPositionChanged)
    Q_PROPERTY(int selectionStart READ selectionStart WRITE setSelectionStart NOTIFY selectionStartChanged)
    Q_PROPERTY(int selectionEnd READ selectionEnd WRITE setSelectionEnd NOTIFY selectionEndChanged)
//     Q_PROPERTY(QString mimeType READ mimeType NOTIFY mimeDataUpdated)

    Q_PROPERTY(QString fileName READ fileName NOTIFY fileUrlChanged)
    Q_PROPERTY(QString fileType READ fileType NOTIFY fileUrlChanged)
    Q_PROPERTY(QUrl fileUrl READ fileUrl NOTIFY fileUrlChanged)
    
    Q_PROPERTY(bool modified READ modified WRITE setModified NOTIFY modifiedChanged)
    
public:
    explicit DocumentHandler(QObject *parent = nullptr);
    
    QQuickTextDocument *code() const;
    QQuickTextDocument *output() const;
    QQuickTextDocument *mimeText() const;
    void setCode(QQuickTextDocument *document);
    void setOutput(QQuickTextDocument *document);
    void setMimeText(QQuickTextDocument *document);
    
    int cursorPosition() const;
    void setCursorPosition(int position);
    
    int selectionStart() const;
    void setSelectionStart(int position);
    
    int selectionEnd() const;
    void setSelectionEnd(int position);
    
    QString fontFamily() const;
    void setFontFamily(const QString &family);
    
    QColor textColor() const;
    void setTextColor(const QColor &color);
    
    Qt::Alignment alignment() const;
    void setAlignment(Qt::Alignment alignment);

    QString mimeType() const;
    QString fileName() const;
    QString fileType() const;
    QUrl fileUrl() const;
    
    bool modified() const;
    void setModified(bool m);

    Q_INVOKABLE void paste();
    Q_INVOKABLE void copy();

public Q_SLOTS:
    void saveAs(const QUrl &fileUrl);
    void save();
    
Q_SIGNALS:
    void codeChanged();
    void outputChanged();
    void mimeTextChanged();
    void cursorPositionChanged();
    void selectionStartChanged();
    void selectionEndChanged();

    void mimeDataUpdated();
    void fileUrlChanged();

    void error(const QString &message);
    
    void modifiedChanged();
    
private:
    void reset();
    QTextCursor codeCursor() const;
    QTextCursor outputCursor() const;
    QTextCursor mimeCursor() const;
    QTextDocument *codeDocument() const;
    QTextDocument *outputDocument() const;
    QTextDocument *mimeDocument() const;
    
    QQuickTextDocument *m_code;
    QQuickTextDocument *m_output;
    QQuickTextDocument *m_mimeText;
    
    int m_cursorPosition;
    int m_selectionStart;
    int m_selectionEnd;
    
    QFont m_font;
    QUrl m_fileUrl;
};

#endif // DOCUMENTHANDLER_H
