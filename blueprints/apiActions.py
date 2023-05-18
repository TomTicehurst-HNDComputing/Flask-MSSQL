from flask import Blueprint, url_for, request, redirect, session
from dbConnection import createWatched, queryWatched, deleteWatched

apiActions = Blueprint("apiActions", __name__, url_prefix="/api/action")


@apiActions.route("/watch/<car_id>/", methods=["POST"])
def watchCarID(car_id: int):
    user_id = session.get("user_id")
    if queryWatched(user_id, car_id):
        if len(queryWatched(user_id, car_id)) == 1:
            deleteWatched(user_id, car_id)

            session["message"] = "Successfully unwatched car!"
            return redirect(request.referrer)
    else:
        createWatched(user_id, car_id)

        session["message"] = "Successfully watched car!"
        return redirect(request.referrer)
    return
