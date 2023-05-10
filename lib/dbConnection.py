from os import getenv
import pymssql

carsAndModelsQuery = """
SELECT
car_id as '!car_id',
Cars.name as 'name',
fuel_type,
colour,
horsepower,
top_speed,
zero_sixty,
'£' + FORMAT(price,'N2') as "price",
model,
doors,
transmission,
registration,
logo_link as '!logo_link'
	FROM Cars
		INNER JOIN Makes ON Cars.fk_make_id=make_id
"""


def __close__(connection, cursor):
    connection.close()
    cursor.close()


def __query__(query: str, data=[], insert=False, orderBy={"field": None, "order": None}):
    connection = pymssql.connect("localhost", "UserInterface", getenv("MSSQL_PASSWORD"), "TomCarSales")
    cursor = connection.cursor(as_dict=True)

    if orderBy["field"] and orderBy["order"]:
        cursor.execute(f"{query} ORDER BY {orderBy['field']} {orderBy['order']} ", data)
    else:
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


def queryCarsWithModels(specific=None):
    if specific == None:
        return __query__(carsAndModelsQuery, orderBy={"field": "car_id", "order": "desc"})
    else:
        return __query__("carsAndModelsQuery WHERE car_id=%s", (specific,))
