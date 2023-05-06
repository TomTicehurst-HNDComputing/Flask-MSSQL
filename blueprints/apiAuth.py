from flask import Blueprint, session, url_for, request, redirect
from werkzeug.security import generate_password_hash, check_password_hash

from dbConnection import queryUserByUsername, createUser

apiAuth = Blueprint("apiAuth", __name__, url_prefix="/api/auth")


@apiAuth.route("/login/", methods=["POST"])
def login():
    user = queryUserByUsername(request.form["username"])

    if user:
        if check_password_hash(user[0].get("password"), request.form["password"]):
            session["loggedIn"] = True
            session["username"] = request.form["username"]
            session["message"] = "Logged in successfully!"

        else:
            session["message"] = "Incorrect password!"

        return redirect(url_for("home"))
    else:
        session["message"] = "User does not exist!"
        return redirect(url_for("login"))


@apiAuth.route("/logout/", methods=["POST"])
def logout():
    if session["loggedIn"] and session["username"]:
        session.pop("loggedIn", default=None)
        session.pop("username", default=None)

        session["message"] = "Logged out successfully!"

        return redirect(url_for("home"))


@apiAuth.route("/create/", methods=["POST"])
def create():
    passwordHash = generate_password_hash(request.form["password"])

    response = createUser(request.form["username"], passwordHash)

    if response:
        session["message"] = response
    else:
        session["message"] = "Account created successfully!"

    return redirect(url_for("home"))
