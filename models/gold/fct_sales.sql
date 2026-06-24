/*
    order_id
    customer_id
    total_price (sum product quantity*price)
    total_products (sum distict product quantity)
    total_quantity (sum product quantity)
    average_basket_price (total_price / total_products)
    average_unit_price  (total_price / total_quantity)
    order_rank (numéro de commande du client (1ère, 2ème...))
    order_status
    order_date
*/

with order_agg as (
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

final as (
    select
        agg.order_id,
        o.customer_id,
        o.status as order_status,
        o.order_date,

        agg.total_price,
        agg.total_products,
        agg.total_quantity,
        agg.total_price / nullif(agg.total_products, 0)  as average_basket_price,
        agg.total_price / nullif(agg.total_quantity, 0)  as average_unit_price,
        agg.top_category,

        rank() over (
            partition by o.customer_id
            order by o.order_date asc
        ) as order_rank

    from {{ ref('sl_orders') }} o
    left join order_agg agg on o.id = agg.order_id
)


select * from final