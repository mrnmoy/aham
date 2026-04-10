#ifndef TCPSERVER_H
#define TCPSERVER_H

#include <QDataStream>
#include <QObject>
#include <QString>
#include <QTcpServer>
#include <QTcpSocket>
#include <QTimer>

class TCPServer : public QObject {
  Q_OBJECT

  Q_PROPERTY(bool isListening READ serverStatus NOTIFY serverStatusChanged);
  Q_PROPERTY(bool isConnected READ clientStatus NOTIFY clientStatusChanged);

public:
  TCPServer();

signals:
  void serverStatusChanged(bool);
  void clientStatusChanged(bool);

  void received(QString msg);
  void error(QString err);
  // void error(QAbstractSocket::SocketError err);

public slots:
  bool start(QString host, int port);
  void stop();
  void connect(QString host, int port);
  void disconnect();
  QString getServerAddress();
  qint64 send(QString msg);

private slots:
  void timeout();
  void connected();
  void disconnected();
  void readyRead();

private:
  QTcpServer *tcpServer;
  QTcpSocket *tcpSocket;

  bool _serverStatus;
  bool _clientStatus;
  quint16 m_nNextBlockSize;
  QTimer *timeoutTimer;

  bool serverStatus();
  bool clientStatus();
};

#endif
