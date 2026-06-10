WITH order_products AS (

    SELECT
        id,
        order_id,
        product_id,
        CASE WHEN quantity < 0 
            THEN 0 ELSE quantity 
        END AS quantity,
        CASE WHEN unit_price is null OR unit_price < 0 
            THEN 0 ELSE unit_price 
        END AS unit_price

    FROM {{ ref('br_order_items') }}

),

enriched_product AS (

    SELECT
        o.*,

        p.id AS product_exists,
        p.product_name,
        p.category AS product_category,
        p.clean_price AS product_real_price

    FROM order_products o

    LEFT JOIN {{ ref('sl_products') }} p
        ON o.product_id = p.id

)

SELECT
    *,

    (product_id IS NULL) AS is_missing_product_id,

    (product_exists IS NULL AND product_id IS NOT NULL)
        AS is_invalid_product_fk,

    (quantity IS NULL) AS is_missing_quantity,

    (quantity <= 0) AS is_invalid_quantity,

    (unit_price < 0) AS is_invalid_price,

    CASE
        WHEN product_id IS NULL
            THEN 'missing_product_id'

        WHEN product_exists IS NULL
            THEN 'invalid_product_fk'

        WHEN quantity IS NULL
            THEN 'missing_quantity'

        WHEN quantity <= 0
            THEN 'invalid_quantity'

        WHEN unit_price < 0
            THEN 'invalid_price'

        ELSE 'valid'
    END AS data_quality_status

FROM enriched_product