SELECT 
    id, name, email, country, created_at
from {{ source('raw', 'customers') }}