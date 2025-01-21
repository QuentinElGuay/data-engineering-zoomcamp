# Week 1

## Prerequisites
This project uses `python 3.12.8` (I recommend creating a virtual environment).

> [!WARNING]
> To install `psycopg2` on Ubuntu, it might be required to install `libpq-dev` first:
```
sudo apt install libpq-dev
```

> [!NOTE]
> All the following commands are executed from this folder.
```
cd week_1/
```

Install the required libs:
```
pip install -r requirements
```

Create a `.env` file to store the `environment variables` (instead of passing them using arguments):
```
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=ny_taxi
POSTGRES_HOST=localhost
POSTGRES_PORT=5433
```

## Week 1 Homework

### Question 1
Run docker with the `python:3.12.8` image in an interactive mode, use the entrypoint bash.
What's the version of pip in the image?
```
docker run -it python:3.12.8 /bin/bash
root@b6e6ddc7c31f:/# pip -V
```

### Question 2
Given the following [docker-compose.yaml](week_1/docker-compose.yaml), what is the hostname and port that pgadmin should use to connect to the postgres database?
```
You can use either the name of the service (`db`) or the name of the container (`postgres`).
Since **pgadmin** tries to connect to the **postgres database** using the network created by `docker compose`, it must use the port **in** the container (`5432`)
```

### Prepare postgres
Start `docker compose` then execute the script `locally` to insert the 2 datasets:
```
docker compose up -d
python src/import.py --table taxi_trips --url https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz
python src/import.py --table taxi_zones --url https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
```

### Question 3
During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, respectively, happened:
1. Up to 1 mile
2. In between 1 (exclusive) and 3 miles (inclusive),
3. In between 3 (exclusive) and 7 miles (inclusive),
4. In between 7 (exclusive) and 10 miles (inclusive),
5. Over 10 miles

Execute the following query to segment and count the trip by distance:
```
SELECT
 CASE
 	WHEN trip_distance <= 1 THEN '1. <= 1'
 	WHEN trip_distance > 1 AND trip_distance <= 3 THEN '2. > 1 AND <= 3'
 	WHEN trip_distance > 3 AND trip_distance <= 7 THEN '3. > 3 AND <= 7'
 	WHEN trip_distance > 7 AND trip_distance <= 10 THEN '4. > 7 AND <= 10'
 	WHEN trip_distance > 10 THEN '5. > 10'
END AS category,
COUNT(*) AS trip_quantity
FROM taxi_trips
WHERE DATE(lpep_pickup_datetime) >= DATE '2019-10-01'
AND DATE(lpep_dropoff_datetime) < DATE '2019-11-01'
GROUP BY 1
ORDER BY 1 ASC;
```

### Question 4
Which was the pick up day with the longest trip distance? Use the pick up time for your calculations.
Execute the following query to get the day with the longest distance:
```
SELECT DATE(lpep_pickup_datetime) AS day, MAX(trip_distance) AS max_trip_distance
FROM taxi_trips
GROUP BY lpep_pickup_datetime
ORDER BY MAX(trip_distance) DESC
LIMIT 1;
```

### Question 5
Which were the top pickup locations with over 13,000 in total_amount (across all trips) for 2019-10-18?
Consider only `lpep_pickup_datetime` when filtering by date.

Execute the following query to get the name of the locations having a sum of the `total_amount` column over `13000`.
```
SELECT "Zone", SUM(total_amount) AS total_amount
FROM taxi_trips tt

LEFT JOIN taxi_zones tz
ON tt."PULocationID" = tz."LocationID"

WHERE DATE(lpep_pickup_datetime) = DATE '2019-10-18'
GROUP BY "Zone"

HAVING SUM(total_amount) > 13000;
```

### Question 6
For the passengers picked up in October 2019 in the zone named "East Harlem North" which was the drop off zone that had the largest tip?

Execute the following query to get the name of zone with the highest tip for the passengers picked up in `East Harlem North`:
```
SELECT
	doz."Zone" AS dropoff_zone,
	tip_amount
FROM taxi_trips tt

LEFT JOIN taxi_zones puz
ON tt."PULocationID" = puz."LocationID"

LEFT JOIN taxi_zones doz
ON tt."DOLocationID" = doz."LocationID"

WHERE DATE(lpep_pickup_datetime)
BETWEEN DATE '2019-10-01'
AND DATE '2019-10-31'
AND puz."Zone" = 'East Harlem North'

ORDER BY tip_amount DESC
LIMIT 1;
```
