from os import getenv
import pymssql


def __close__(connection, cursor):
    connection.close()
    cursor.close()


def __query__(query: str, data=[], insert=False):
    connection = pymssql.connect("localhost", "UserInterface", getenv("MSSQL_PASSWORD"), "TomCarSales")
    cursor = connection.cursor(as_dict=True)
    cursor.execute(query, data)

    if not insert:
        data = cursor.fetchall()

        __close__(connection, cursor)
        return data
    else:
        connection.commit()
        __close__(connection, cursor)
        return


def queryUserByUsername(username: str):
    return __query__("SELECT user_id,username,password FROM Users WHERE username=%s", (username,))


def createUser(username: str, password: str):
    try:
        return __query__("INSERT INTO Users (username,password) VALUES (%s,%s)", (username, password), True)
    except Exception as e:
        return "User already exists!"


def createWatched(user_id: int, car_id: int):
    return __query__("INSERT INTO Watching(fk_user_id,fk_car_id) VALUES (%s,%s)", (user_id, car_id), True)


def deleteWatched(user_id: int, car_id: int):
    return __query__("DELETE FROM Watching WHERE fk_user_id=%s AND fk_car_id=%s", (user_id, car_id), True)


def queryCarsWithModels(specific: int = None):
    if specific == None:
        return __query__("SELECT * FROM cars_and_makes ORDER BY [!car_id] DESC")
    else:
        return __query__("SELECT * FROM cars_and_makes WHERE [!car_id]=%s", (specific,))


def queryWatched(user_id: int = None, car_id=None):
    if user_id == None:
        return __query__("SELECT * FROM cars_being_watched ORDER BY [!user_id] DESC")
    if car_id != None:
        return __query__("SELECT * FROM cars_being_watched WHERE [!car_id]=%s", (car_id,))
    if user_id != None:
        return __query__("SELECT * FROM cars_being_watched WHERE [!user_id]=%s", (user_id,))
    else:
        return __query__("SELECT * FROM cars_being_watched WHERE [!user_id]=%s AND [!car_id]=%s", (user_id, car_id))
