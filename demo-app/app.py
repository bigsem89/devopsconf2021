import platform
import requests
import socket

from flask import Flask, request

app = Flask(__name__)

@app.route('/info/')
def info():
    result = dict()
    
    result['hostname'] = socket.gethostname()
    result['platform'] = platform.platform()
    
    try:
        req = requests.get('http://169.254.169.254/latest/meta-data/hostname', timeout=0.3)
        if req.status_code == 200:
            result['instance-hostname'] = req.text
        else:
            result['instance-hostname'] = 'undefined'
    except:
        result['instance-hostname'] = 'undefined'
        
    try:
        req = requests.get('http://169.254.169.254/latest/meta-data/instance-id', timeout=0.3)
        if req.status_code == 200:
            result['instance-id'] = req.text
        else:
            result['instance-id'] = 'undefined'
    except:
        result['instance-id'] = 'undefined'

    try:
        req = requests.get('http://169.254.169.254/latest/meta-data/instance-life-cycle', timeout=0.3)
        if req.status_code == 200:
            result['lifecycle'] = req.text
        else:
            result['lifecycle'] = 'undefined'
    except:
        result['lifecycle'] = 'undefined'
    
    return result
    
app.run(debug=True, host='0.0.0.0')