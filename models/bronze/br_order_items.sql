SELECT
    id, order_id, product_id, quantity, unit_price
FROM {{ source('raw', 'order_items') }}