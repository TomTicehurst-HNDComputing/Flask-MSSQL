from flask import Flask, render_template, session

from dotenv import load_dotenv
from sys import path
from os import getenv

load_dotenv()
path.append("lib")
path.append("blueprints")

from dbConnection import queryCarsWithModels, queryWatched, queryUserByUsername
from preload import getRandomCarImages

from apiAuth import apiAuth
from apiActions import apiActions

app = Flask(__name__, static_folder="render/static", template_folder="render/templates")
app.secret_key = getenv("FLASK_SECRET_KEY")
app.register_blueprint(apiAuth)
app.register_blueprint(apiActions)

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
    return render_template("view_car.jinja", getCar=queryCarsWithModels, car_id=car_id, getWatched=queryWatched)


@app.route("/account/")
def account():
    return render_template("account.jinja", getWatched=queryWatched)
