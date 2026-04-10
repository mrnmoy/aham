#include "tcpServer.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[]) {
  QGuiApplication app(argc, argv);

  app.setApplicationName("Aham");
  app.setOrganizationName("com.github.mrnmoy");
  app.setOrganizationDomain("com.github.mrnmoy");

  qmlRegisterType<TCPServer>("TCPServer", 1, 0, "TCPServer");

  QQmlApplicationEngine engine;
  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
      []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
  engine.loadFromModule("Aham", "Main");

  return QCoreApplication::exec();
}
