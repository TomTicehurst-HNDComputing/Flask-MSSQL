from flask import Flask, render_template
from dotenv import load_dotenv
from sys import path

load_dotenv()
path.append("lib")

from dbConnection import queryAllCars, queryCarModel

app = Flask(__name__, static_folder="render/static", template_folder="render/templates")


@app.route("/")
def home():
    return render_template("home.jinja")


@app.route("/stock/")
def stock():
    return render_template("stock.jinja", functions={"all": queryAllCars, "model": queryCarModel})
