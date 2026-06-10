SELECT
    id,

    -- name cleaning
    CASE
        WHEN name IS NULL OR TRIM(name) = '' THEN 'unknown'
        ELSE TRIM(LOWER(name))
    END AS customer_name,

    -- email cleaning
    TRIM(LOWER(COALESCE(email, 'unknown'))) AS customer_email,

    -- country cleaning
    CASE
        WHEN country IS NULL OR TRIM(country) = '' THEN 'unknown'
        ELSE TRIM(LOWER(country))
    END AS customer_country,

    created_at::DATE AS created_at,

    -- data quality classification
    CASE
        WHEN email IS NULL OR email NOT LIKE '%@%' THEN 'bad_email'
        WHEN name IS NULL OR TRIM(name) = '' THEN 'bad_name'
        WHEN country IS NULL OR TRIM(country) = '' THEN 'bad_country'
        ELSE 'valid'
    END AS data_quality_status

FROM {{ ref('br_customers') }}