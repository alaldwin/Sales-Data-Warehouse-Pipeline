from numpy import empty
import pandas as pd
import os
import logging
from sqlalchemy import create_engine, inspect
from dotenv import load_dotenv

load_dotenv()

os.makedirs("data", exist_ok=True)
os.makedirs("logs", exist_ok=True)

logging.basicConfig(
    filename="logs/ingestion.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

logging.info("Reading CSV file...")

def ignestion_data():

    df = pd.read_csv("data/Amazon.csv")

    logging.info("CSV file read successfully.")

    df.info()

    summary = df.describe(include="all")
    Unique_Values = df.nunique()

    head = df.head(10)

    missing_values = df.isna().sum()

    data_types = df.dtypes

    shape = df.shape

    print(df.columns.tolist())

    logging.info("Data ingestion info completed successfully.")

    return {
        "Data": df,
        "Summary": summary,
        "Unique Values": Unique_Values,
        "Head": head,
        "Missing Values": missing_values,
        "Data Types": data_types,
        "Shape": shape
    }


def Transform_data(df):

    logging.info("Transforming data...")

    df = df.copy()

    df["OrderID"] = df["OrderID"].str.replace(r"^ORD", "", regex=True).astype("int64")

    df["OrderDate"] = pd.to_datetime(df["OrderDate"], format="%Y-%m-%d")

    df["CustomerID"] = df["CustomerID"].str.replace(r"^CUST", "", regex=True).astype("int64")

    df["ProductID"] = df["ProductID"].str.replace(r"^P", "", regex=True).astype("int64")

    df["SellerID"] = df["SellerID"].str.replace(r"^SELL", "", regex=True).astype("int64")

    logging.info("Data transformation completed successfully.")

    return df


def load_data(df_transformed):

    logging.info("Loading data to Databases...")

    db_host = os.getenv("DB_HOST")
    db_port = os.getenv("DB_PORT")
    db_name = os.getenv("DB_NAME")
    db_user = os.getenv("DB_USER")
    db_password = os.getenv("DB_PASSWORD")

    database_url = (
        f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
    )

    engine = create_engine(database_url)

    logging.info("Database connection established successfully.")

    inspector = inspect(engine)

    if inspector.has_table("amazon"):

        logging.info("Table already exists in the database. Data will not be loaded.")

        return "Table already exists in the database. Data will not be loaded."


    df_transformed.to_sql(
        "amazon", 
        engine, 
        if_exists="replace", 
        index=False
    )


    logging.info("Data loaded to Databases successfully.")



def main():

    data_info = ignestion_data()

    df = data_info["Data"]

    df_transformed = Transform_data(df)

    load_data(df_transformed)


if __name__ == "__main__":
    main()
