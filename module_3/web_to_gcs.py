import os
import requests
import pandas as pd
from google.cloud import storage

"""
Pre-reqs: 
1. `pip install pandas pyarrow google-cloud-storage`
2. Set GOOGLE_APPLICATION_CREDENTIALS to your project/service-account key
3. Set GCP_GCS_BUCKET as your bucket or change default value of BUCKET
"""

# services = ['fhv','green','yellow']
init_url = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/'
# switch out the bucketname
BUCKET = os.environ.get("GCP_GCS_BUCKET", "dtc-data-lake-bucketname")


def upload_to_gcs(bucket, object_name, local_file):
    """
    Ref: https://cloud.google.com/storage/docs/uploading-objects#storage-upload-object-python
    """
    # # WORKAROUND to prevent timeout for files > 6 MB on 800 kbps upload speed.
    # # (Ref: https://github.com/googleapis/python-storage/issues/74)
    # storage.blob._MAX_MULTIPART_SIZE = 5 * 1024 * 1024  # 5 MB
    # storage.blob._DEFAULT_CHUNKSIZE = 5 * 1024 * 1024  # 5 MB

    client = storage.Client()
    bucket = client.bucket(bucket)
    blob = bucket.blob(object_name)
    blob.upload_from_filename(local_file)


def web_to_gcs(year, service):
    for i in range(12):
        
        # sets the month part of the file_name string
        month = '0'+str(i+1)
        month = month[-2:]

        # csv file_name
        csv_file_name = f"{service}_tripdata_{year}-{month}.csv.gz"

        # download it using requests via a pandas df
        request_url = f"{init_url}{service}/{csv_file_name}"
        r = requests.get(request_url)
        open(csv_file_name, 'wb').write(r.content)
        print(f"Local: {csv_file_name}")

        # read it back into a parquet file
        # df = pd.read_csv(
        #     csv_file_name,
        #     dtype={'passenger_count':'Int64'},
        #     compression='gzip'
        # )
        # pq_file_name = csv_file_name.replace('.csv.gz', '.parquet')
        # df.to_parquet(pq_file_name, engine='pyarrow')
        # print(f"Parquet: {pq_file_name}")


        # upload it to gcs 
        upload_to_gcs(BUCKET, f"{service}/{csv_file_name}", csv_file_name)

        os.remove(csv_file_name)
        print(f"Deleted local file: {csv_file_name}")
        # print(f"GCS: {service}/{pq_file_name}")

        # os.remove(pq_file_name)
        # print(f"Deleted local file: {pq_file_name}")

    print("Finished upload")

web_to_gcs('2019', 'green')
web_to_gcs('2020', 'green')
web_to_gcs('2019', 'yellow')
web_to_gcs('2020', 'yellow')
web_to_gcs('2019', 'fhv')
