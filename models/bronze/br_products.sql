select 
    id, name, category, price
from {{ source('raw', 'products') }}