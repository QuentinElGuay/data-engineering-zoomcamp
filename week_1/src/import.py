import argparse
from dataclasses import dataclass
import logging
from os import getenv
from pathlib import Path
from typing import Dict, Tuple
from urllib.request import urlretrieve

from dotenv import load_dotenv
import pandas as pd
from sqlalchemy import create_engine

@dataclass
class postgresql_connection:
    host:str
    port:str
    user:str
    password:str
    database:str

    def __str__(self):
        return 'postgresql://{}:{}@{}:{}/{}'.format(
            self.user, self.password, self.host, self.port, self.database)

@dataclass
class FileConfiguration:
    dtype:Dict[str, str]
    date_fields: Dict[str, str]

def get_file_configuration(table_name:str)->FileConfiguration:

    if table_name == 'taxi_trips':
        return FileConfiguration(
            dtype={
                'VendorID': 'Int64',
                'store_and_fwd_flag': 'string',
                'RatecodeID': 'Float64',
                'PULocationID': 'Int32',
                'DOLocationID': 'Int32',
                'passenger_count': 'Float64',
                'trip_distance': 'Float64',
                'fare_amount': 'Float64',
                'extra': 'Float64',
                'mta_tax': 'Float64',
                'tip_amount': 'Float64',
                'tolls_amount': 'Float64',
                'ehail_fee': 'Float64',
                'improvement_surcharge': 'Float64',
                'total_amount': 'Float64',
                'payment_type': 'Float64',
                'trip_type': 'Float64',
                'congestion_surcharge': 'Float64',
            },
            date_fields={
                'lpep_pickup_datetime':'%Y-%m-%d %H:%M:%S',
                'lpep_dropoff_datetime':'%Y-%m-%d %H:%M:%S',
            },
        )

    elif table_name == 'taxi_zones':
        return FileConfiguration(
            dtype={
                'LocationID': 'Int64',
                'Borough': 'string',
                'Zone': 'string',
                'service_zone': 'string',
            },
            date_fields={
            },
        )


def download_file(
        url:str,
        configuration: FileConfiguration
    )->pd.io.parsers.readers.TextFileReader:

    logging.info('Downloading file from %s', url)
    return pd.read_csv(
        url,
        dtype=configuration.dtype,
        parse_dates=list(configuration.date_fields.keys()),
        date_format=configuration.date_fields,
        iterator=True,
        chunksize=100000
    )

def main(table, url):

    postgres_connection = postgresql_connection(
        host=getenv('POSTGRES_HOST'),
        port=getenv('POSTGRES_PORT'),
        database=getenv('POSTGRES_DB'),
        user=getenv('POSTGRES_USER'),
        password=getenv('POSTGRES_PASSWORD')
    )

    file_configuration = get_file_configuration(table)
    df_iter = download_file(url, file_configuration)

    logging.info('Opening connection to %s', str(postgres_connection))
    engine = create_engine(str(postgres_connection))

    # First chunk
    logging.info('First chunk')
    df = next(df_iter)
    df.to_sql(name=table, con=engine, if_exists='replace')

    # Other chunks
    for df in df_iter:
        logging.info('Next chunk')
        df.to_sql(name=table, con=engine, if_exists='append')


if __name__ == '__main__':

    logging.basicConfig(level=logging.INFO)

    load_dotenv()  # take environment variables from .env.

    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')

    parser.add_argument(
        '--table',
        required=True,
        help='Name of the table where we will write the results to'
    )

    parser.add_argument(
        '--url',
        required=True,
        help='URL of the csv file'
    )

    args = parser.parse_args()

    main(args.table, args.url)
