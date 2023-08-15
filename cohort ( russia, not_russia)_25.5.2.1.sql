-- cohort_russia
-- cohort_not_russia

-- 1. пользователи из россии и других стран по локации : CTE users_with_address
WITH users_with_address AS(  
SELECT 
user_id,
CASE
WHEN country = 'Russia' THEN 'yes' -- << рф
WHEN country != 'Russia' THEN 'no' -- << другое
ELSE null -- << не известно
END is_russia
FROM gd2.addresses
ORDER BY 1
	
-- 2. пользователи из россии и других стран по телефону : CRE users_with_phone
), users_with_phone AS(  
SELECT 
id,
CASE
WHEN left(phone, 1)='7' and LENGTH(phone)='11' THEN 'yes'
WHEN phone is null THEN null
ELSE 'no'
END is_russia
FROM gd2.users_phones
ORDER BY 1
	
-- 3. итоговый список пользователей из россии и других стран : CTE users_with_geo
), users_with_geo AS( 
SELECT 
id,
CASE
WHEN adr.is_russia is null THEN pho.is_russia ELSE adr.is_russia END is_russia_x
FROM users_with_phone pho LEFT JOIN users_with_address adr ON pho.id=adr.user_id
ORDER BY 1 

-- 4. дата первой покупки каждого пользователя : CTE first_purchases
), first_purchases AS(
SELECT
user_id,
MIN(created_at) OVER(PARTITION BY user_id ORDER BY created_at, id) min_date
FROM gd2.purchases
WHERE state = 'successful'
	
-- 5. когорты для пользователей из россии по первой покупке : CTE cohort_russia
) -- cohort_russia AS( 
SELECT	
date_trunc('month',min_date) as cohort, -- месяц первой покупки
date_trunc('month',created_at) as purchase_month, -- месяц покупки
pu.user_id
FROM first_purchases fp
LEFT JOIN users_with_geo geo ON fp.user_id=geo.id
JOIN gd2.purchases pu ON pu.user_id=geo.id
-- WHERE is_russia_x = 'yes'
-- WHERE is_russia_x = 'no'
AND state = 'successful'
ORDER BY 1,2
	
	
	