# import the necessary packages
import pdb
import requests
from random import randrange 
import numpy as np
import argparse
import cv2
import time

# HOST = 'localhost:4000'
HOST = '192.168.2.132:4000'
COUNT = 300

def on(index, color="#FFFFFFFF"):
    requests.post('http://' + HOST + '/modes/set/' + str(index), {'color': color})

def off(index):
    requests.delete('http://' + HOST + '/modes/set/' + str(index))

def set_mode():
    requests.delete('http://' + HOST + '/modes/')
    requests.post('http://' + HOST + '/modes/', {'mode': 'calibration'})

def capture():
    cam = cv2.VideoCapture(0)
    ret, image = cam.read()
    cam.release()
    return image

def get_brightest_point():
    image = capture() #from camera
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY) # make the image grayscale
    #gray = cv2.GaussianBlur(gray, (25, 20), 0)
    (minVal, maxVal, minLoc, maxLoc) = cv2.minMaxLoc(gray) # find the brightest point
    # cv2.circle(image, maxLoc, 20, (255, 0, 0), 5) # draw a circle around that point for debugging
    #cv2.imshow("Robust", image) # show captured image for debugging
    #cv2.waitKey(0)
    return maxLoc

def read_coors():
    off('') # turn off all LEDs
    data = []
    for i in range(0, COUNT):
        on(i) # turn on LED #i
        maxLoc = get_brightest_point()
        off(i) # turn off LED #i
        data.append((i,maxLoc))
    return data

#read_coors()
set_mode()

import phxsocket

channel = None
running = True

def close(socket):
    global running
    print("FINISHED")
    socket.close()
    running = False

def capture_coors(socket):
    global channel
    print("I should be doing something right now")
    point = get_brightest_point()
    print(point)
    print(channel)
    channel.push("submit", {"x": point[0], "y": point[1]})
    print("PUSHED")

def join_channel(socket):
    global channel
    channel = socket.channel("calibration:lobby", {"method": "opencv"})
    channel.join() # also blocking, raises exception on failure
    channel.push("start", {})
    channel.on("request_coors", capture_coors)
    channel.on("finish", close)

socket = phxsocket.Client("ws://" + HOST + "/socket/websocket")
socket.on_open = join_channel

conn = socket.connect(blocking=False) # blocking, raises exception on failure

while running:
    time.sleep(0.01)
