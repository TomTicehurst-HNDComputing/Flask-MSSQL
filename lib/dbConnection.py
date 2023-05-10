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
    return __query__("SELECT username,password FROM Users WHERE username=%s", (username,))


def createUser(username: str, password: str):
    try:
        return __query__("INSERT INTO Users (username,password) VALUES (%s,%s)", (username, password), True)
    except Exception as e:
        return "User already exists!"


def queryAllCars():
    return __query__("SELECT * FROM Cars")


def queryCarModel(makeID: int):
    return __query__("SELECT name,logo_link FROM Makes WHERE make_id=%s", (makeID,))[0]
