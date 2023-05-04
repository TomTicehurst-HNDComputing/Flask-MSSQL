from os import getenv
import pymssql


def __close__(connection, cursor):
    connection.close()
    cursor.close()


def __query__(query: str, data=[]):
    connection = pymssql.connect(getenv("MSSQL_HOST"), getenv("MSSQL_USERNAME"), getenv("MSSQL_PASSWORD"), getenv("MSSQL_DATABASE"))
    cursor = connection.cursor(as_dict=True)

    cursor.execute(query, data)
    data = cursor.fetchall()

    __close__(connection, cursor)
    return data


def queryAllCars():
    return __query__("SELECT fk_make_id,name,fuel_type,colour,horsepower,top_speed,zero_sixty,price,model,registration FROM Cars")


def queryCarModel(makeID: int):
    return __query__("SELECT name,logo_link FROM Makes WHERE make_id=%s", (makeID,))[0]
