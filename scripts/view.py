import base64
import json
import sys

from PySide2 import QtCore, QtGui, QtWidgets
from PySide2.QtWebEngineWidgets import QWebEngineView

from brownie import *


class DisplaySVG(QtWidgets.QWidget):
    def __init__(self, parent=None, svg=""):
        super().__init__(parent)
        self.resize(450, 450)
        self.verticalLayout = QtWidgets.QVBoxLayout(self)
        self.webview = QWebEngineView(self)
        self.verticalLayout.addWidget(self.webview)

        self.setWindowTitle("Display SVG")
        act = QtWidgets.QAction("Close", self)
        act.setShortcuts([QtGui.QKeySequence(QtCore.Qt.Key_Escape)])
        act.triggered.connect(self.close)
        self.addAction(act)

        self.webview.setHtml(svg)


def data2svg(data):
    data = data.split(",")[1]
    b64_str = data.encode('ascii')
    url_bytes_b64 = base64.urlsafe_b64decode(b64_str)
    str_64 = str(url_bytes_b64, "utf-8")
    j = json.loads(str_64)
    r = j["image"]
    r = r.split(",")[1]
    b64_str = r.encode('ascii')
    url_bytes_b64 = base64.urlsafe_b64decode(b64_str)
    str_64 = str(url_bytes_b64, "utf-8")
    return str_64


def main():
    me = accounts[0]

    c = SVG.deploy({'from': me})
    c.mint()

    # Render image, toggle color, then render image again
    html = data2svg(c.tokenURI(1))
    c.toggle()
    html += data2svg(c.tokenURI(1))

    # Print the SVGs
    print(html)

    # Display the SVGs
    if not QtWidgets.QApplication.instance():
        app = QtWidgets.QApplication(sys.argv)
    else:
        app = QtWidgets.QApplication.instance()

    disp = DisplaySVG(svg=html)
    disp.show()
    app.exec_()
