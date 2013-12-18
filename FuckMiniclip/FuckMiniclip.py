#!/usr/bin/python

import os
import time

def sposta_mouse(x,y):
    os.system('xdotool mousemove ' + str(x) + ' ' + str(y))
def click_sinistro():
    os.system('xdotool click 1') 
    
posX=850
posY=440

#Tempo in secondi
t=10

while True:
  sposta_mouse(posX,posY)
  click_sinistro()
  time.sleep(t)
  