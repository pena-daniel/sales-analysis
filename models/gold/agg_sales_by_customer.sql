/*
    customer_id,
    total_orders,
    total_revenue,
    average_orders_value,
    first_order_date, 
    last_order_date, 
    days_since_last_order

*/

with  order_agg as (
    select 
        op.order_id,
        sum(op.quantity * op.unit_price) as total_price,
        count(distinct op.product_id) as total_products,
        sum(op.quantity) as total_quantity,
        mode() within group (order by op.product_category) as top_category

    from {{  ref('sl_order_products') }} op
    where op.data_quality_status = 'valid'
    group by op.order_id
),

order_agg_enriched as (
    SELECT
        o.customer_id,
        o.customer_country,
        count(distinct agg.order_id) as total_orders,
        sum(agg.total_price) as total_revenue,
        (sum(agg.total_price)/NULLIF(count(distinct agg.order_id),0)) as average_orders_revenue,
        min(o.order_date) as first_order_date,
        max(o.order_date) as last_order_date,
        current_date - max(o.order_date) as days_since_last_order


    from {{ ref('sl_orders') }} o
    left join order_agg agg on o.id = agg.order_id
    where o.data_quality_status = 'valid'
    group by o.customer_id,o.customer_country
)

select * from order_agg_enriched