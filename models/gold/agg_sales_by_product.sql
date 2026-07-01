/*
product_id, 
total_orders, 
total_quantity_sold, 
total_revenue,
rank_by_revenue, 
rank_by_quantity
*/

with product_agg as (
    select 
        op.product_id,
        count(distinct op.order_id) as total_orders,
        sum(op.quantity) as total_quantity_sold,
        sum(op.quantity * op.unit_price) as total_revenue

    from {{ ref('sl_order_products') }} as op
    where op.data_quality_status = 'valid'
    GROUP BY product_id
),

product_ranked as (
    select
        *,
        rank() over (order by total_revenue desc)       as rank_by_revenue,
        rank() over (order by total_quantity_sold desc) as rank_by_quantity

    from product_agg
),

final as (
    select
        ranked.product_id,
        p.product_name,
        ranked.total_orders,
        ranked.total_quantity_sold,
        ranked.total_revenue,
        ranked.rank_by_revenue,
        ranked.rank_by_quantity

    from {{ ref('sl_products') }} p
    left join product_ranked ranked on p.id = ranked.product_id
    where p.data_quality_status = 'valid'
)


select * from final