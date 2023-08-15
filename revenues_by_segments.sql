-- revenues_by_segments 

/* ROW: пользователи, которые совершили хотя бы одну покупку 2020-06 года
        сумма их покупок 
        CORE-игроки / NOT_CORE-игроки */

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

-- CORE-игроки
total AS( 
SELECT
distinct pu.user_id as user_group
FROM gd2.purchases pu JOIN amount_success am ON pu.user_id=am.user_id
JOIN dif_success dif ON pu.user_id=dif.user_id
WHERE state = 'successful'
AND sum_amount >= '1200'
AND pu.created_at between '2020-05-01' and '2020-06-30'
GROUP BY 1
HAVING AVG(dif_days) <= 28
)

SELECT
distinct pu.user_id,
sum(amount) as revenue,
CASE 
WHEN t.user_group is not null THEN 'core' 
ELSE 'not_core' 
END mark
FROM gd2.purchases pu LEFT JOIN total t ON pu.user_id=t.user_group
WHERE state = 'successful'
AND pu.created_at between '2020-05-01' and '2020-06-30'
GROUP BY pu.user_id, t.user_group
ORDER BY 1

/*
-- CTE с подсчетом разницы дней между покупками
With dif_success AS( 
SELECT user_id,
lead(created_at) OVER(PARTITION BY user_id  ORDER BY created_at) - created_at as dif_days
FROM gd2.purchases
WHERE state='successful'
), 
-- СТЕ с подсчетом покупок по user_id
amount_success AS( 
SELECT user_id, 
sum(amount) sum_amount
FROM gd2.purchases
WHERE state = 'successful'
GROUP BY 1
)
--total AS( 
SELECT
pu.user_id,
amount as core_amount
FROM gd2.purchases pu JOIN amount_success am ON pu.user_id=am.user_id
JOIN dif_success dif ON pu.user_id=dif.user_id
WHERE state = 'successful'
AND sum_amount >= '1200'
AND pu.created_at between '2020-05-01' and '2020-06-30'
group by 1,2
HAVING AVG(dif_days) <= 28
ORDER BY 2 ASC

*/
