import pdb
from random import randrange 
from led_api import *
import numpy as np
import argparse
import cv2
import time
import phxsocket
from queue import Queue

def capture():
    cam = cv2.VideoCapture(0)
    ret, image = cam.read()
    x = 650
    y = 330
    w = 500
    h = 650
    image = image[y:y+h, x:x+w]
    cam.release()
    return image

def get_brightest_point():
    image = capture() #from camera
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY) # make the image grayscale
    gray = cv2.GaussianBlur(gray, (21, 21), 0)
    (minVal, maxVal, minLoc, maxLoc) = cv2.minMaxLoc(gray) # find the brightest point
    return (image,maxLoc)

def debug(image, point):
    cam = cv2.VideoCapture(0)
    ret, image = cam.read()
    cam.release()
    return image

    cv2.circle(image, point, 20, (255, 0, 0), 5) # draw a circle around that point for debugging
    print("SHOWING for")
    print(point)
    cv2.imshow("preview", image) # show captured image for debugging
    #cv2.waitKey(0)


class CalibrationClient:
    def __init__(self, host):
        self.__q__ = Queue()
        self.__running__ = True
        set_mode()
        socket = phxsocket.Client("ws://" + host + "/socket/websocket")
        socket.on_open = self.join_channel
        self.__socket__ = socket
        socket.connect(blocking=False) # blocking, raises exception on failure

    def close(self, socket):
        socket.close()
        self.__running__ = False

    def capture_coors(self, socket):
        print("I should be doing something right now")
        (image, point) = get_brightest_point()
        self.__q__.put((image, point))
        self.__channel__.push("submit", {"x": point[0], "y": point[1]})
        print("PUSHED")
        print(self.__channel__ )

    def join_channel(self, socket):
        channel = socket.channel("calibration:lobby", {"method": "opencv"})
        channel.join() # also blocking, raises exception on failure
        channel.push("start", {"set": "high_camera"})
        channel.on("request_coors", self.capture_coors)
        channel.on("finish", self.close)
        self.__channel__ = channel

    def run(self):
        while self.running():
            if not(self.__q__.empty()):
                (image, point) = self.__q__.get()
                debug(image, point)

    def running(self):
        return self.__running__

CalibrationClient(HOST).run()
# cv2.namedWindow("preview", cv2.WINDOW_NORMAL)

# cam = cv2.VideoCapture(0)
# while True:
#     ret, image = cam.read()
#     x = 650
#     y = 330
#     w = 500
#     h = 650
#     image = image[y:y+h, x:x+w]
#     gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY) # make the image grayscale
#     gray = cv2.GaussianBlur(gray, (21, 21), 0)
#     # merged = np.array([np.array( list( map(lambda pixel: sum(pixel), row) )) for row in image])
#     (minVal, maxVal, minLoc, maxLoc) = cv2.minMaxLoc(gray) # find the brightest point
#     cv2.circle(image, maxLoc, 20, (255, 0, 0), 5) # draw a circle around that point for debugging
#     cv2.circle(gray, maxLoc, 20, (255, 0, 0), 5) # draw a circle around that point for debugging
#     print(maxVal)
#     cv2.imshow("preview", image) # show captured image for debugging
#     cv2.waitKey(0)

# cam.release()
