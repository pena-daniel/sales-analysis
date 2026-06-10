WITH orders AS (

    SELECT
        id,
        customer_id,
        date::DATE AS order_date,

        CASE
            WHEN status IS NULL OR TRIM(status) = ''
                THEN 'unknown'
            ELSE LOWER(TRIM(status))
        END AS status

    FROM {{ ref('br_orders') }}

),

enriched AS (

    SELECT
        o.*,

        c.id AS customer_exists,
        c.customer_name,
        c.customer_email,
        c.customer_country

    FROM orders o

    LEFT JOIN {{ ref('sl_customers') }} c
        ON o.customer_id = c.id

)

SELECT
    id,
    customer_id,

    customer_name,
    customer_email,
    customer_country,

    order_date,
    status,

    -- Flags qualité

    (customer_id IS NULL) AS is_missing_customer_id,

    (customer_exists IS NULL AND customer_id IS NOT NULL)
        AS is_invalid_customer_fk,

    (order_date > CURRENT_DATE)
        AS is_future_order_date,

    (status = 'unknown')
        AS is_missing_status,

    (
        status <> 'unknown'
        AND status NOT IN (
            'completed',
            'pending',
            'cancelled',
            'processing'
        )
    ) AS is_invalid_status,

    -- Score qualité

    (
        CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END +
        CASE WHEN customer_exists IS NULL AND customer_id IS NOT NULL THEN 1 ELSE 0 END +
        CASE WHEN order_date > CURRENT_DATE THEN 1 ELSE 0 END +
        CASE WHEN status = 'unknown' THEN 1 ELSE 0 END +
        CASE
            WHEN status <> 'unknown'
             AND status NOT IN (
                'completed',
                'pending',
                'cancelled',
                'processing'
             )
            THEN 1
            ELSE 0
        END
    ) AS quality_issue_count,

    -- Statut global

    CASE

        WHEN customer_id IS NULL
            THEN 'missing_customer_id'

        WHEN customer_exists IS NULL
            THEN 'invalid_customer_fk'

        WHEN order_date > CURRENT_DATE
            THEN 'future_order_date'

        WHEN status = 'unknown'
            THEN 'missing_status'

        WHEN status NOT IN (
            'unknown',
            'completed',
            'pending',
            'cancelled',
            'processing'
        )
            THEN 'invalid_status'

        ELSE 'valid'

    END AS data_quality_status

FROM enriched