-- purchases_per_countries


WITH users_with_geo AS(  
SELECT 
user_id,
CASE
WHEN country = 'Russia' THEN 'yes'
WHEN country != 'Russia' THEN 'no'
ELSE null
END is_russia
FROM gd2.addresses
ORDER BY 1
), 
users_with_phone AS(  
SELECT 
id,
CASE
WHEN left(phone, 1)='7' and LENGTH(phone)='11' THEN 'yes'
WHEN phone is null THEN null
ELSE 'no'
END is_russia
FROM gd2.users_phones
ORDER BY 1
),
x AS( 
SELECT 
id,
CASE
WHEN geo.is_russia is null THEN pho.is_russia
ELSE geo.is_russia
END is_russia_x
FROM users_with_phone pho LEFT JOIN users_with_geo geo ON pho.id=geo.user_id
ORDER BY 1 
)

SELECT
to_char(pu.created_at, 'YYYY-MM') mnth,
pu.id,
is_russia_x
FROM gd2.purchases pu JOIN x ON pu.user_id=x.id
WHERE pu.state = 'successful'
ORDER BY 1 

