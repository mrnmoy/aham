#include "tcpServer.h"

TCPServer::TCPServer() : QObject(), m_nNextBlockSize(0) {
  _serverStatus = false;
  _clientStatus = false;
  tcpServer = new QTcpServer();
}

bool TCPServer::start(QString host, int port) {
  tcpServer->setMaxPendingConnections(1);

  if (!tcpServer->listen(QHostAddress::Any, port)) {
    return false; // port is not available
  }

  QObject::connect(tcpServer, &QTcpServer::newConnection, this,
                   &TCPServer::connected);

  _serverStatus = true;
  emit serverStatusChanged(_serverStatus);
  return true;
}

void TCPServer::stop() {
  if (tcpServer->isListening()) {
    QObject::disconnect(tcpServer, &QTcpServer::newConnection, this,
                        &TCPServer::connected);

    // QList<QTcpSocket *> tcpClients = server->getClients();
    if (_clientStatus)
      disconnect();

    tcpServer->close();
    _serverStatus = false;
    emit serverStatusChanged(_serverStatus);
  }
}

void TCPServer::connect(QString host, int port) {
  tcpSocket = new QTcpSocket();
  timeoutTimer = new QTimer();

  timeoutTimer->setSingleShot(true);
  timeoutTimer->start(3000);

  tcpSocket->connectToHost(host, port);

  QObject::connect(timeoutTimer, &QTimer::timeout, this, &TCPServer::timeout);
  QObject::connect(tcpSocket, &QTcpSocket::connected, this,
                   &TCPServer::connected);
  QObject::connect(tcpSocket, &QTcpSocket::disconnected, this,
                   &TCPServer::disconnected);
  QObject::connect(tcpSocket, &QTcpSocket::readyRead, this,
                   &TCPServer::readyRead);
}

void TCPServer::disconnect() {
  QObject::disconnect(tcpSocket, &QTcpSocket::connected, 0, 0);
  QObject::disconnect(tcpSocket, &QTcpSocket::readyRead, 0, 0);

  if (tcpSocket->state())
    tcpSocket->disconnectFromHost();
  else
    tcpSocket->abort();
}

void TCPServer::timeout() {
  if (tcpSocket->state() == QAbstractSocket::ConnectingState) {
    tcpSocket->abort();
    // emit tcpSocket->error(QAbstractSocket::SocketTimeoutError); // Error not
    // found
  }
}

void TCPServer::connected() {
  if (serverStatus()) {
    tcpSocket = tcpServer->nextPendingConnection();
    tcpServer->pauseAccepting();

    QObject::connect(tcpSocket, &QTcpSocket::readyRead, this,
                     &TCPServer::readyRead);
    QObject::connect(tcpSocket, &QTcpSocket::disconnected, this,
                     &TCPServer::disconnected);
  }

  _clientStatus = true;
  emit clientStatusChanged(_clientStatus);
}

void TCPServer::disconnected() {
  // QObject::disconnect(tcpSocket, &QTcpSocket::disconnected, 0, 0);
  if (serverStatus())
    tcpServer->resumeAccepting();

  _clientStatus = false;
  emit clientStatusChanged(_clientStatus);
}

bool TCPServer::serverStatus() { return _serverStatus; }
bool TCPServer::clientStatus() { return _clientStatus; }

QString TCPServer::getServerAddress() {
  return tcpServer->serverAddress().toString();
};

void TCPServer::readyRead() {
  QDataStream in(tcpSocket);
  for (;;) {
    if (!m_nNextBlockSize) {
      if (tcpSocket->bytesAvailable() < sizeof(quint16)) {
        break;
      }
      in >> m_nNextBlockSize;
    }

    if (tcpSocket->bytesAvailable() < m_nNextBlockSize) {
      break;
    }

    QString str;
    in >> str;

    // if (str == "0") {
    //   str = "Connection closed";
    //   disconnect();
    // }

    emit received(str);
    m_nNextBlockSize = 0;
  }
}

qint64 TCPServer::send(QString msg) {
  QByteArray arrBlock;
  QDataStream out(&arrBlock, QIODevice::WriteOnly);
  out << quint16(0) << msg;

  out.device()->seek(0);
  out << quint16(arrBlock.size() - sizeof(quint16));

  return tcpSocket->write(arrBlock);
}
