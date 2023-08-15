/*
ТЕЛЕФОН -------- gd2.users_phones ph
ph.id	        / id пользователя
ph.phone	    / телефон пользователя

ПОКУПКИ -------- gd2.purchases pu
pu.id	        / id покупки
pu.user_id	    / id пользователя
pu.created_at	/ datetime покупки
pu.state	    / статус: successful — удачная покупка / canceled — отменённая
pu.amount	    / сумма покупки в рублях

АДРЕС ---------- gd2.addresses ad 
ad.id	        / id адреса
ad.user_id	    / id пользователя
ad.city	        / город
ad.region_name  / название региона
ad.country	    / название страны 
*/


-- Объединяем данные и выгружаем 
/* SELECT *
FROM gd2.users_phones ph 
LEFT JOIN gd2.addresses ad ON ph.id=ad.user_id
LEFT JOIN gd2.purchases pu ON ph.id=pu.user_id
ORDER BY 1 ASC */


--------------------------------------------------------------------------- 

-- 25.4.1 
-- У "7" пользователей в gd2.users_phones номера телефонов=null
/* SELECT
count(id) -- 50 000
FROM gd2.users_phones
WHERE phone is NULL -- 7 */


--  25.4.2 
-- Пользователи из "47" стран представлены в gd2.addresses
/* SELECT
count(distinct country)
FROM gd2.addresses */


--  25.4.3 
-- Типы данных, хранящиеся в gd2.purchases
-- text / date / bigint / double precision
/* SELECT * FROM gd2.purchases */


-- 25.4.4 
-- В таблице purchases "124" покупоки со статусом canceled
/* SELECT count(id)
FROM gd2.purchases
WHERE state = 'canceled' */


-- 25.4.5 
-- "26" успешных покупок у пользователя с самым большим количеством покупок
/* SELECT
user_id,
count(id) purchases,
count(id) FILTER(WHERE state = 'successful') successful
FROM gd2.purchases
GROUP BY 1
ORDER BY 2 DESC */


-- 25.4.6 
-- "3" различных города Бразилии представлено в gd2.addresses
/* SELECT
country,
count(distinct city)
FROM gd2.addresses
GROUP BY 1
ORDER BY 1 ASC */
------------------------------------------------------------------------------------------

-- 25.4.9_DONE
-- Oтобрать всех, у кого в качестве страны указана Russia в gd2.addresses
-- 4 445 << RUSSIA
-- 555 << OTHER
-- 0 << is NULL
--  47 << уникальных стран
-- 5 000 << уникальных user_id
/*
WITH users_with_geo AS(  
SELECT 
user_id,
CASE
WHEN country = 'Russia' THEN 'yes' -- юзер из России
WHEN country != 'Russia' THEN 'no' -- юзер не из России
ELSE 'null'                        -- местоположение неизвестно
END is_russia
FROM gd2.addresses
)
SELECT
user_id, 
is_russia
--count(user_id),
--count(is_russia) FILTER(WHERE is_russia = 'yes') count_yes,
--count(is_russia) FILTER(WHERE is_russia = 'null') count_null,
--count(is_russia) FILTER(WHERE is_russia = 'no') count_no
FROM users_with_geo
ORDER BY 1 */
------------------------------------------------------------------------------------------

-- 25.4.10_DONE
-- Отобрать пользователей из gd2.users_phones по номеру телефона
-- 5 000 << count(id)
-- 46 541 << RUSSIA
-- 3 452 << OTHER 
-- 7 << is NULL 
/* 
WITH users_with_phone AS(  
SELECT 
id,
CASE
WHEN left(phone, 1)='7' and LENGTH(phone)='11' THEN 'yes'
WHEN phone is null THEN null
ELSE 'no'
END is_russia
FROM gd2.users_phones
ORDER BY 1
)
SELECT
id,
is_russia
FROM users_with_phone
ORDER BY 1 */
--count(user_id), 
--count(is_russia) FILTER(WHERE is_russia = 'yes') count_yes, -- 46 541
--count(is_russia) FILTER(WHERE is_russia = 'null') count_null, -- 7
--count(is_russia) FILTER(WHERE is_russia = 'no') count_no -- 3 452

------------------------------------------------------------------------------------------

-- 25.4.12_DONE!
/*
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
)
SELECT 
id,
CASE
WHEN geo.is_russia is null THEN pho.is_russia
ELSE geo.is_russia
END is_russia_x
FROM users_with_phone pho LEFT JOIN users_with_geo geo ON pho.id=geo.user_id
ORDER BY 1 */
------------------> проверка
/* SELECT
count(x.id),
count(is_russia_x) FILTER(WHERE is_russia_x = 'yes') count_yes,
count(is_russia_x) FILTER(WHERE is_russia_x = 'no') count_no,
count(is_russia_x) FILTER(WHERE is_russia_x = null) count_null
FROM x */

------------------> % Russia = 92 %
/* SELECT
ROUND(COUNT(CASE WHEN is_russia_x = 'yes' THEN id END):: numeric / COUNT(id) * 100) as perc
FROM x
WHERE is_russia_x IS NOT NULL */



------------------------------------------------------------------------------------------

-- 25.4.14_DONE
-- Доля пользователей из России = 92%
/* SELECT
ROUND(COUNT(CASE WHEN is_russia = 'yes' THEN id END):: numeric / COUNT(id) * 100
	       ) as percentage_russia
FROM users_with_geo
WHERE is_russia IS NOT NULL */
------------------------------------------------------------------------------------------

-- 25.5.1.2_DONE
-- 211 успешных покупок было в России в марте 2020 года
/* 
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
-- успешные продажи в России:
count(pu.id) FILTER(WHERE pu.state = 'successful' and is_russia_x = 'yes'),
-- успешные продажи в других странах :
count(pu.id) FILTER(WHERE pu.state = 'successful' and is_russia_x = 'no') 
FROM gd2.purchases pu JOIN x ON pu.user_id=x.id
GROUP by 1
ORDER BY 1 */
--------------------------------------------------

-- Выгрузить: purchases_per_countries.csv
/* 
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
*
FROM x LEFT JOIN gd2.purchases pu ON x.id=pu.user_id */
------------------------------------------------------------------------------------------