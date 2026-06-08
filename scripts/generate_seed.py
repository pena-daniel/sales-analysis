import random
import csv
from faker import Faker
from pathlib import Path


fake = Faker()


def generate_customers(n=500):
    rows = []
    for i in range(1, n+1):
        # erreurs volontaires
        email = fake.email()
        if random.random() < 0.05:
            email = "invalid_email"  # erreur

        if random.random() < 0.03:
            email = ""  # NULL simulé

        country = random.choice(["FR","US","UK","DE","ES",None])
        if random.random() < 0.05:
            country = None

        name = fake.name()

        rows.append([i, name, email, country, fake.date_this_year()])

    return rows

def generate_products(n=300):
    rows = []
    categories = ["Electronics","Fashion","Home","Sports","Luxury",None]

    for i in range(1, n+1):
        price = round(random.uniform(5, 2000), 2)

        # erreurs
        if random.random() < 0.05:
            price = -price  # negative price

        if random.random() < 0.03:
            category = None
        else:
            category = random.choice(categories)

        name = fake.word().capitalize()

        rows.append([i, name, category, price])

    return rows


def generate_orders(n=1000):
    rows = []

    for i in range(1, n+1):
        customer_id = random.randint(1, 500)

        # erreurs FK
        if random.random() < 0.05:
            customer_id = None

        # dates futures (error)
        date = fake.date_between(start_date="-1y", end_date="+30d")

        status = random.choice(["completed","pending","cancelled","processing"])

        if random.random() < 0.02:
            status = "INVALID_STATUS"

        rows.append([i, customer_id, date, status])

    return rows



def generate_order_items(n=3000):
    rows = []

    for i in range(1, n+1):
        order_id = random.randint(1, 1000)
        product_id = random.randint(1, 300)

        quantity = random.randint(1, 5)

        # errors
        if random.random() < 0.05:
            quantity = 0

        if random.random() < 0.02:
            quantity = -1

        unit_price = round(random.uniform(5, 2000), 2)

        if random.random() < 0.03:
            unit_price = None

        # FK broken
        if random.random() < 0.02:
            product_id = 9999

        rows.append([i, order_id, product_id, quantity, unit_price])

    return rows



BASE_DIR = Path(__file__).resolve().parent.parent
SEEDS_DIR = BASE_DIR /"seeds"
SEEDS_DIR = SEEDS_DIR.resolve()

with open(f"{SEEDS_DIR}/customers.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["id","name","email","country","created_at"])
    writer.writerows(generate_customers())
    
with open(f"{SEEDS_DIR}/products.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["id","name","category","price"])
    writer.writerows(generate_products())
    
with open(f"{SEEDS_DIR}/orders.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["id","customer_id","date","status"])
    writer.writerows(generate_orders())
    
with open(f"{SEEDS_DIR}/order_items.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["id","order_id","product_id","quantity", "unit_price"])
    writer.writerows(generate_order_items())