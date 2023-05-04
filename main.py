from flask import Flask, render_template, request, redirect, url_for, session
from werkzeug.security import generate_password_hash, check_password_hash

from dotenv import load_dotenv
from sys import path
from os import getenv

load_dotenv()
path.append("lib")

from dbConnection import queryAllCars, queryCarModel, getUserByUsername

app = Flask(__name__, static_folder="render/static", template_folder="render/templates")
app.secret_key = getenv("FLASK_SECRET_KEY")


@app.route("/")
def home():
    return render_template("home.jinja")


@app.route("/login/")
def login():
    return render_template("login.jinja")


@app.route("/api/login", methods=["POST"])
def apiLogin():
    user = getUserByUsername(request.form["username"])

    if user:
        if user[0].get("username") == request.form["username"] and user[0].get("password") == request.form["password"]:
            session["loggedIn"] = True
            session["username"] = request.form["username"]

            return redirect(url_for("home"))
    else:
        return "invalid user"


@app.route("/stock/")
def stock():
    return render_template("stock.jinja", functions={"all": queryAllCars, "model": queryCarModel})
