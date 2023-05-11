from flask import Flask, render_template

from dotenv import load_dotenv
from sys import path
from os import getenv

load_dotenv()
path.append("lib")
path.append("blueprints")

from dbConnection import queryCarsWithModels
from apiAuth import apiAuth
from preload import getRandomCarImages

app = Flask(__name__, static_folder="render/static", template_folder="render/templates")
app.secret_key = getenv("FLASK_SECRET_KEY")
app.register_blueprint(apiAuth)

images = getRandomCarImages()


@app.route("/")
def home():
    return render_template("home.jinja", images=images)


@app.route("/login/")
def login():
    return render_template("login.jinja")


@app.route("/stock/")
def stock():
    return render_template("stock.jinja", cars=queryCarsWithModels())


@app.route("/view_car/<car_id>/")
def view_car_id(car_id):
    return render_template("view_car.jinja", getCar=queryCarsWithModels, car_id=car_id)
