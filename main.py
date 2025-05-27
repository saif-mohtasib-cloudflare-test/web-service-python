import datetime
from flask import Flask

app = Flask(__name__)



@app.route("/")
def main():
    return "Alive and Kicking"

@app.route('/status')
def hello():
    time_now = datetime.datetime.now()
    return "Reporting at {}".format(time_now)

@app.route("/secure")
def secure():
    time_now = datetime.datetime.now()
    return "This is the Secure Tunnel, No Sunshine, No Moonlight, Only Tungsten light. {}".format(time_now)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)