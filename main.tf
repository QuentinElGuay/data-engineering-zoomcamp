provider "google" {
  project     = var.project_id
  region      = var.location
  credentials = file(var.credentials)
}

resource "google_storage_bucket" "nyc-taxi-bucket" {
  name          = var.nyc_taxi_bucket_name
  location      = var.location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 10
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_bigquery_dataset" "nyc-taxi" {
  dataset_id  = "nyc_taxi"
  description = "Dataset for the data-engineering zoomcamp from DataTalksClub"
  location    = var.location
}

resource "google_bigquery_table" "green-tripdata" {
  dataset_id          = google_bigquery_dataset.nyc-taxi.dataset_id
  table_id            = "green_tripdata"
  deletion_protection = false
  schema              = <<EOF
[
{
    "name": "vendor_id",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "A code indicating the LPEP provider that provided the record. 1= Creative Mobile Technologies, LLC; 2= VeriFone Inc."
},
{
    "name": "pickup_datetime",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "The date and time when the meter was engaged"
},
{
    "name": "dropoff_datetime",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "The date and time when the meter was disengaged"
},
{
    "name": "store_and_fwd_flag",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "This flag indicates whether the trip record was held in vehicle memory before sending to the vendor, aka 'store and forward,' because the vehicle did not have a connection to the server. Y= store and forward trip N= not a store and forward trip"
},
{
    "name": "rate_code",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The final rate code in effect at the end of the trip. 1= Standard rate 2=JFK 3=Newark 4=Nassau or Westchester 5=Negotiated fare 6=Group ride"
},
{
    "name": "passenger_count",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "The number of passengers in the vehicle. This is a driver-entered value."
},
{
    "name": "trip_distance",
    "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "The elapsed trip distance in miles reported by the taximeter."
},
{
    "name": "fare_amount",
    "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "The time-and-distance fare calculated by the meter"
},
{
    "name": "extra",
    "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "Miscellaneous extras and surcharges. Currently, this only includes the $0.50 and $1 rush hour and overnight charges"
},
{
    "name": "mta_tax",
    "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "$0.50 MTA tax that is automatically triggered based on the metered rate in use"
},
{
    "name": "tip_amount",
    "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "Tip amount. This field is automatically populated for credit card tips. Cash tips are not included."
},
{
    "name": "tolls_amount",
    "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "Total amount of all tolls paid in trip."
},
{
    "name": "ehail_fee",
    "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": ""
},
{
    "name": "airport_fee",
    "type": "NUMERIC",
    "mode": "NULLABLE"
},
{
    "name": "total_amount",
    "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "The total amount charged to passengers. Does not include cash tips."
},
{
    "name": "payment_type",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "A numeric code signifying how the passenger paid for the trip. 1= Credit card 2= Cash 3= No charge 4= Dispute 5= Unknown 6= Voided trip"
},
{
    "name": "distance_between_service",
    "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": ""
},
{
    "name": "time_between_service ",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": ""
},
{
    "name": "trip_type",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "A code indicating whether the trip was a street-hail or a dispatch that is automatically assigned based on the metered rate in use but can be altered by the driver. 1= Street-hail 2= Dispatch"
},
{
    "name": "imp_surcharge",
    "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "$0.30 improvement surcharge assessed on hailed trips at the flag drop. The improvement surcharge began being levied in 2015."
},
{
    "name": "pickup_location_id",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "TLC Taxi Zone in which the taximeter was engaged"
},
{
    "name": "dropoff_location_id",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "TLC Taxi Zone in which the taximeter was disengaged"
},
{
    "name": "data_file_year",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "Datafile timestamp year value"
},
{
    "name": "data_file_month",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "Datafile timestamp month value"
}
]
EOF
}

resource "google_bigquery_table" "yellow-tripdata" {
  dataset_id          = google_bigquery_dataset.nyc-taxi.dataset_id
  table_id            = "yellow_tripdata"
  deletion_protection = false
  schema = <<EOF
[
{
    "name": "vendor_id",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "A code indicating the LPEP provider that provided the record. 1= Creative Mobile Technologies, LLC; 2= VeriFone Inc."
},
{
    "name": "pickup_datetime",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "The date and time when the meter was engaged"
},
{
    "name": "dropoff_datetime",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "The date and time when the meter was disengaged"
},
{
    "name": "passenger_count",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "The number of passengers in the vehicle. This is a driver-entered value."
},
{
    "name": "trip_distance",
    "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "The elapsed trip distance in miles reported by the taximeter."
},
{
    "name": "rate_code",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The final rate code in effect at the end of the trip. 1= Standard rate 2=JFK 3=Newark 4=Nassau or Westchester 5=Negotiated fare 6=Group ride"
},
{
    "name": "store_and_fwd_flag",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "This flag indicates whether the trip record was held in vehicle memory before sending to the vendor, aka 'store and forward,' because the vehicle did not have a connection to the server. Y= store and forward trip N= not a store and forward trip"
},
{
    "name": "payment_type",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "A numeric code signifying how the passenger paid for the trip. 1= Credit card 2= Cash 3= No charge 4= Dispute 5= Unknown 6= Voided trip"
},
{
    "name": "fare_amount",
   "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "The time-and-distance fare calculated by the meter"
},
{
    "name": "extra",
   "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "Miscellaneous extras and surcharges. Currently, this only includes the $0.50 and $1 rush hour and overnight charges"
},
{
    "name": "mta_tax",
   "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "$0.50 MTA tax that is automatically triggered based on the metered rate in use"
},
{
    "name": "tip_amount",
   "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "Tip amount. This field is automatically populated for credit card tips. Cash tips are not included."
},
{
    "name": "tolls_amount",
   "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "Total amount of all tolls paid in trip."
},
{
    "name": "imp_surcharge",
   "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "$0.30 improvement surcharge assessed on hailed trips at the flag drop. The improvement surcharge began being levied in 2015."
},
{
    "name": "airport_fee",
   "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": ""
},
{
    "name": "total_amount",
   "type": "NUMERIC",
    "mode": "NULLABLE",
    "description": "The total amount charged to passengers. Does not include cash tips."
},
{
    "name": "pickup_location_id",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "TLC Taxi Zone in which the taximeter was engaged"
},
{
    "name": "dropoff_location_id",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "TLC Taxi Zone in which the taximeter was disengaged"
},
{
    "name": "data_file_year",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "Datafile timestamp year value"
},
{
    "name": "data_file_month",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "Datafile timestamp month value"
}
]
EOF
}
