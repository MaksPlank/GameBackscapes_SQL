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
WHEN geo.is_russia is null THEN pho.is_russia ELSE geo.is_russia END is_russia_x
FROM users_with_phone pho LEFT JOIN users_with_geo geo ON pho.id=geo.user_id
ORDER BY 1 
*/

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
to_char(pu.created_at, 'YYYY-MM') first_purchases,
-- успешные продажи в России:
count(pu.id) FILTER(WHERE pu.state = 'successful' and is_russia_x = 'yes') users_russia,
-- успешные продажи в других странах :
count(pu.id) FILTER(WHERE pu.state = 'successful' and is_russia_x = 'no') users_not_russia 
FROM x LEFT JOIN gd2.purchases pu ON x.id=pu.user_id
--GROUP by 1
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
FROM x LEFT JOIN gd2.purchases pu ON x.id=pu.user_id  */
------------------------------------------------------------------------------------------


-- 25.5.2.1 -- CTE: first_purchases
/*
--  1. месяц первой покупки каждого пользователя
With first_purchases AS(
SELECT
user_id,
MIN(created_at) OVER(PARTITION BY user_id ORDER BY created_at, id) min_date
FROM gd2.purchases
WHERE state = 'successful'
)
--  2. вовзращаемость от нулевого месяца (месяца регистрации когорты)
SELECT	
user_id,
date_trunc('month',min_date) as min_date
FROM first_purchases
GROUP BY 2 */
------------------------------------------------------------------------------------------	
	
-- 25.5.2.1_CTE: cohort_russia_Возвращаемость в 1й месяц когорты апрель 2020 в сегменте Россия
/*
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
WHERE is_russia_x = 'no'
AND state = 'successful'
ORDER BY 1,2 */
------------------------------------------------------------------------------------------	


-- 25.5.3.3_СTE с подсчетом покупок по user_id
-- 80 процентиль sum(amount) по всем успешным покупкам пользователей = 1266
/*
-- 1. Cумма успешных покупок пользователей :
With amount_success AS( 
SELECT
user_id, 
sum(amount) FILTER(WHERE state = 'successful') sum_amount 
FROM gd2.purchases
GROUP BY 1
)
-- 2. Процентиль 80% от суммы успешных покупок :
SELECT
PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY sum_amount)
FROM amount_success */
------------------------------------------------------------------------------------------	


-- 25.5.3.4_CTE с подсчетом разницы дней между покупками
-- 28 дней проходит между успешными покупками 80% пользователей
/*
-- 1. разница между текущей и последующей датой в днях:
With dif_success AS( 
SELECT
lead(created_at) OVER(PARTITION BY user_id  ORDER BY created_at) - created_at as dif_days
FROM gd2.purchases
WHERE state='successful'
)
-- 2. Процентиль 80% для разницы:
SELECT
PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY dif_days)
FROM dif_success  */
------------------------------------------------------------------------------------------


-- 25.5.3.7 -- 179 игроков принадлежит к core-сегменту на конец июня 
-- те, кто совершал покупки в мае-июне и соответствует остальным критериям
/*
-- CTE с подсчетом разницы дней между покупками
With dif_success AS( 
SELECT
user_id,
lead(created_at) OVER(PARTITION BY user_id  ORDER BY created_at) - created_at as dif_days
FROM gd2.purchases
WHERE state='successful'
), 
-- СТЕ с подсчетом покупок по user_id
amount_success AS( 
SELECT
user_id, 
sum(amount) sum_amount
FROM gd2.purchases
WHERE state = 'successful'
GROUP BY 1
),
-- Объединение результатов двух CTE
total AS( 
SELECT
distinct pu.user_id as user_group
--to_char(pu.created_at, 'YYYY-MM') created_at
FROM gd2.purchases pu JOIN amount_success am ON pu.user_id=am.user_id
JOIN dif_success dif ON pu.user_id=dif.user_id
WHERE state = 'successful'
AND sum_amount >= '1200'
AND pu.created_at between '2020-05-01' and '2020-06-30'
GROUP BY 1
HAVING AVG(dif_days) <= 28
)
SELECT
count(t.user_group)
FROM total t */
------------------------------------------------------------------------------------------

-- 25.5.3.5 -- 1337 игроков совершали успешные покупки в мае и июне 2020 года
/*
select
count(distinct user_id), -- 1 337
sum(amount) -- 1 024 701
from gd2.purchases
where (date_trunc('month', created_at)='2020-06-01'
	or date_trunc('month', created_at)='2020-05-01')
and state='successful' */
------------------------------------------------------------------------------------------

-- revenues_by_segments
-- 25.5.3.8 -- 13% составляют core-игроки от всех игроков, совершавших покупки в мае и июне
-- 25.5.3.9 -- 32% от всех успешных продаж за май и июнь составляют продажи core-игрокам (322 908)
/*
With dif_success AS( 
SELECT
user_id,
lead(created_at) OVER(PARTITION BY user_id  ORDER BY created_at) - created_at as dif_days
FROM gd2.purchases
WHERE state='successful'
), 
amount_success AS( 
SELECT
user_id, 
sum(amount) sum_amount
FROM gd2.purchases
WHERE state = 'successful'
GROUP BY 1
),
total AS( 
SELECT
amount as core_amount
FROM gd2.purchases pu JOIN amount_success am ON pu.user_id=am.user_id
JOIN dif_success dif ON pu.user_id=dif.user_id
WHERE state = 'successful'
AND sum_amount >= '1200'
AND pu.created_at between '2020-05-01' and '2020-06-30'
group by 1
HAVING AVG(dif_days) <= 28
)
SELECT
sum(core amount)
FROM total 
*/