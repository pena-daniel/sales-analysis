WITH cleaned AS (
    SELECT
        id,

        CASE
            WHEN name IS NULL OR TRIM(name) = ''
            THEN 'unknown'
            ELSE TRIM(LOWER(name))
        END AS product_name,

        CASE
            WHEN category IS NULL OR TRIM(category) = ''
            THEN 'unknown'
            ELSE TRIM(LOWER(category))
        END AS category,

        CASE
            WHEN price < 0
            THEN 0
            ELSE price
        END AS clean_price,

        price

    FROM {{ ref('br_products') }}
)

SELECT
    *,

    (product_name = 'unknown') AS is_missing_product_name,
    (category = 'unknown') AS is_missing_category,
    (price < 0) AS is_invalid_price,

    CASE
        WHEN price < 0 THEN 'invalid_price'
        WHEN category = 'unknown' THEN 'invalid_category'
        WHEN product_name = 'unknown' THEN 'invalid_name'
        ELSE 'valid'
    END AS data_quality_status

FROM cleaned