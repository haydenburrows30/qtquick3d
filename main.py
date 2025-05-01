import sys
from PySide6.QtCore import QUrl
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine

def main():
    app = QApplication(sys.argv)
    
    # Register the QML types
    engine = QQmlApplicationEngine()

    # Load the QML file
    engine.load(QUrl.fromLocalFile("main.qml"))
    
    if not engine.rootObjects():
        return -1
    
    return app.exec()

if __name__ == "__main__":
    sys.exit(main())
