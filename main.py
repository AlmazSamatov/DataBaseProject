import psycopg2
import config


# class for working with our database
class DBHelper:
    # constructor that initialize connection and cursor
    def __init__(self):
        try:
            self.connection = psycopg2.connect("dbname='" + config.dbname + "' user='" + config.user + "' host='" +
                                               config.host + "' password='" + config.password + "'")
            self.cursor = self.connection.cursor()
        except:
            print("I am unable to connect to the database")

    # 1st query
    def makeFirstQuery(self):
        with self.connection:  # this allows automatically close connection after fetching information
            self.cursor.execute("""SELECT uid, car_number, color 
                                FROM "CarSharingComp".vehicle
                                JOIN "CarSharingComp".model on id = model_id
                                WHERE color='red' AND substring(car_number,1,2)='AN'""")
            rows = self.cursor.fetchall()
            print("Possible cars: ")
            for row in rows:
                print("Car number: ", row[1], ", Color: ", row[2], sep='')

    # 3rd query
    def makeThirdQuery(self):
        with self.connection:
            current_timestamp = "2017-11-23 20:22:18"
            self.cursor.execute("""SELECT COUNT(*) FROM "CarSharingComp".vehicle""")
            rows = self.cursor.fetchall()
            amount_of_vehicles = rows[0][0]  # amount of all vehicles
            self.cursor.execute("""SELECT count(distinct vehicle_id)
                                FROM "CarSharingComp"."order"
                                WHERE created_on >= timestamp '""" + current_timestamp + """' - INTERVAL '7 days' AND
                                EXTRACT(HOUR FROM created_on)>=7 AND 
                                EXTRACT(HOUR FROM created_on)<=10""")
            rows = self.cursor.fetchall()
            morning = int(float(rows[0][0] / amount_of_vehicles) * 100)  # % of vehicles which take orders at morning
            self.cursor.execute("""SELECT count(distinct vehicle_id)
                                FROM "CarSharingComp"."order"
                                WHERE created_on >= timestamp '""" + current_timestamp + """' - INTERVAL '7 days' AND
                                EXTRACT(HOUR FROM created_on)>=12 AND 
                                EXTRACT(HOUR FROM created_on)<=14""")
            rows = self.cursor.fetchall()
            afternoon = int(float(rows[0][0] / amount_of_vehicles) * 100)  # % of vehicles which take orders at afternoon
            self.cursor.execute("""SELECT count(distinct vehicle_id) 
                                FROM "CarSharingComp"."order"
                                WHERE created_on >= timestamp '""" + current_timestamp + """' - INTERVAL '7 days' AND
                                EXTRACT(HOUR FROM created_on)>=17 AND 
                                EXTRACT(HOUR FROM created_on)<=19""")
            rows = self.cursor.fetchall()
            evening = int(float(rows[0][0] / amount_of_vehicles) * 100)  # % of vehicles which take orders at evening
            print("Morning: ", morning, "%", ", Afternoon: ", afternoon, "%", ", Evening: ", evening, "%", sep='')

    # 5th query
    def makeFifthQuery(self, date):
        with self.connection:
            self.cursor.execute("""SELECT AVG(distance), AVG(EXTRACT(MINUTE FROM (departure_time - created_on)) + 
                                EXTRACT(HOUR FROM (departure_time - created_on)) * 60)
                                FROM "CarSharingComp"."order"
                                WHERE DATE (created_on) = date '""" + date + "'")
            rows = self.cursor.fetchall()
            print("Average ​distance: ", int(rows[0][0]), " km ", ", Average ​trip duration: ", int(rows[0][1]), " mins", sep='')

    # 6th query
    def makeSixthQuery(self):
        with self.connection:
            self.cursor.execute("""SELECT source_latitude, source_longitude
                                FROM "CarSharingComp"."order"
                                WHERE EXTRACT(HOUR FROM created_on)>=7 AND EXTRACT(HOUR FROM created_on)<=10
                                GROUP BY source_latitude, source_longitude
                                ORDER BY COUNT(*) DESC
                                LIMIT 3""")
            rows = self.cursor.fetchall()

            print("3 most popular pick-up locations at morning:")
            for index, row in enumerate(rows):
                print(index + 1, ". ", ' latitude: ', row[0], ', longitude: ', row[1], sep='')

            self.cursor.execute("""SELECT dest_latitude, dest_longitude
                                FROM "CarSharingComp"."order"
                                WHERE EXTRACT(HOUR FROM created_on)>=7 AND EXTRACT(HOUR FROM created_on)<=10
                                GROUP BY dest_latitude, dest_longitude
                                ORDER BY COUNT(*) DESC
                                LIMIT 3""")
            rows = self.cursor.fetchall()

            print("\n3 most popular destination locations at morning:")
            for index, row in enumerate(rows):
                print(index + 1, ". ", ' latitude: ', row[0], ', longitude: ', row[1], sep='')

            self.cursor.execute("""SELECT source_latitude, source_longitude
                                FROM "CarSharingComp"."order"
                                WHERE EXTRACT(HOUR FROM created_on)>=12 AND EXTRACT(HOUR FROM created_on)<=14
                                GROUP BY source_latitude, source_longitude
                                ORDER BY COUNT(*) DESC
                                LIMIT 3""")
            rows = self.cursor.fetchall()

            print("\n3 most popular pick-up locations at afternoon:")
            for index, row in enumerate(rows):
                print(index + 1, ". ", ' latitude: ', row[0], ', longitude: ', row[1], sep='')

            self.cursor.execute("""SELECT dest_latitude, dest_longitude
                                FROM "CarSharingComp"."order"
                                WHERE EXTRACT(HOUR FROM created_on)>=12 AND EXTRACT(HOUR FROM created_on)<=14
                                GROUP BY dest_latitude, dest_longitude
                                ORDER BY COUNT(*) DESC
                                LIMIT 3""")
            rows = self.cursor.fetchall()

            print("\n3 most popular destination locations at afternoon:")
            for index, row in enumerate(rows):
                print(index + 1, ". ", ' latitude: ', row[0], ', longitude: ', row[1], sep='')

            self.cursor.execute("""SELECT source_latitude, source_longitude
                                FROM "CarSharingComp"."order"
                                WHERE EXTRACT(HOUR FROM created_on)>=17 AND EXTRACT(HOUR FROM created_on)<=19
                                GROUP BY source_latitude, source_longitude
                                ORDER BY COUNT(*) DESC
                                LIMIT 3""")
            rows = self.cursor.fetchall()

            print("\n3 most popular pick-up locations at evening:")
            for index, row in enumerate(rows):
                print(index + 1, ". ", ' latitude: ', row[0], ', longitude: ', row[1], sep='')

            self.cursor.execute("""SELECT dest_latitude, dest_longitude
                                FROM "CarSharingComp"."order"
                                WHERE EXTRACT(HOUR FROM created_on)>=17 AND EXTRACT(HOUR FROM created_on)<=19
                                GROUP BY dest_latitude, dest_longitude
                                ORDER BY COUNT(*) DESC
                                LIMIT 3""")
            rows = self.cursor.fetchall()

            print("\n3 most popular destination locations at evening:")
            for index, row in enumerate(rows):
                print(index + 1, ". ", ' latitude: ', row[0], ', longitude: ', row[1], sep='')

    # 7th query
    def makeSeventhQuery(self):
        with self.connection:
            self.cursor.execute("""SELECT COUNT(*) FROM "CarSharingComp".vehicle""")
            rows = self.cursor.fetchall()
            amount_of_vehicles = rows[0][0]
            amount_of_vehicles_to_delete = int(amount_of_vehicles * 0.1)  # take 10% of vehicles

            self.cursor.execute("""SELECT company, model, car_number, color
                                FROM "CarSharingComp".vehicle
                                JOIN "CarSharingComp".model on "CarSharingComp".model.id = uid
                                WHERE uid = (SELECT vehicle_id
                                FROM "CarSharingComp"."order" 
                                WHERE created_on >= CURRENT_TIMESTAMP - INTERVAL '3 months' 
                                GROUP BY vehicle_id
                                ORDER BY COUNT(*)
                                LIMIT """ + str(amount_of_vehicles_to_delete) + ")")
            rows = self.cursor.fetchall()
            print("10% ​of ​all ​self-driving ​cars, ​which ​take ​least ​amount ​of ​orders ​for the ​last ​3 ​months: ")
            for row in rows:
                print('Company: ', row[0], ', Model: ', row[1], ', Car_number: ', row[2], ', Color: ',
                      row[3], sep='')


print('______________________________________________________')
dbHelper = DBHelper()  # initialize dbHelper object
print("1st query: ")
dbHelper.makeFirstQuery()
print('______________________________________________________\n')

print("3rd query: ")
dbHelper.makeThirdQuery()
print('______________________________________________________\n')

print("5th query: ")
dbHelper.makeFifthQuery("2017-11-23")
print('______________________________________________________\n')

print("6th query: ")
dbHelper.makeSixthQuery()
print('______________________________________________________\n')

print("7th query: ")
dbHelper.makeSeventhQuery()
print('______________________________________________________\n')
