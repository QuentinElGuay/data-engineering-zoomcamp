import dlt
from dlt.sources.helpers.rest_client import RESTClient
from dlt.sources.helpers.rest_client.paginators import PageNumberPaginator
import duckdb

BASE_API_URL = 'https://us-central1-dlthub-analytics.cloudfunctions.net'

@dlt.resource(name='rides')
def ny_taxi(base_page: int):

    client = RESTClient(
        base_url=BASE_API_URL,
        headers={'Content-Type': 'application/json'},
        paginator=PageNumberPaginator(
            base_page=base_page,
            total_path=None
        )
    )

    for page in client.paginate('data_engineering_zoomcamp_api'):
        yield page

pipeline = dlt.pipeline(
    pipeline_name='ny_taxi_pipeline',
    destination='duckdb',
    dataset_name='ny_taxi_data'
)

load_info = pipeline.run(ny_taxi(1))
print(load_info)

# Connect to the DuckDB database
conn = duckdb.connect(f'{pipeline.pipeline_name}.duckdb')

# Set search path to the dataset
conn.sql(f'SET search_path = "{pipeline.dataset_name}"')

# Describe the dataset
print('DuckDB tables description:')
print(conn.sql('DESCRIBE').df())

# Get Number of lines
df = pipeline.dataset(dataset_type='default').rides.df()
print(f'Number of lines: {len(df)}')

# Get average trip duration
with pipeline.sql_client() as client:
    res = client.execute_sql(
            '''
            SELECT
            AVG(date_diff('minute', trip_pickup_date_time, trip_dropoff_date_time))
            FROM rides;
            '''
        )
    # Prints column values of the first row
    print(res)
