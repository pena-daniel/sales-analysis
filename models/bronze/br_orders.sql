SELECT
    id, customer_id, date, status
FROM {{ source('raw', 'orders') }}