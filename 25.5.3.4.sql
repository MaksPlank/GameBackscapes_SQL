
-- 25.5.3.4
-- сколько дней проходит между успешными покупками 80% пользователей
 
-- 1. разница между текущей и последующей датой в днях:
With amount_success AS( 
SELECT
lead(created_at) OVER(PARTITION BY user_id  ORDER BY created_at) - created_at as dif_days
FROM gd2.purchases
WHERE state='successful'
--GROUP BY 1
)
-- 2. Процентиль 80% для разницы:
SELECT
PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY dif_days)
FROM amount_success 






