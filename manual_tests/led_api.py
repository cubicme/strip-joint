import requests

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

