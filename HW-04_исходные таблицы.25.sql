-- 25_HW-04_исходные таблицы

-- ТЕЛЕФОН -------- 
SELECT
ph.id,	        -- id пользователя
ph.phone	    -- телефон пользователя
FROM gd2.users_phones ph


-- ПОКУПКИ -------- 
SELECT
pu.id,	        -- id покупки
pu.user_id,	    -- id пользователя
pu.created_at,	-- datetime покупки
pu.state,	    -- статус: successful — удачная покупка / canceled — отменённая
pu.amount       -- сумма покупки в рублях
FROM gd2.purchases pu
--WHERE state = 'successful'

-- АДРЕС ----------  
SELECT
ad.id,	           -- id адреса
ad.user_id,	       -- id пользователя
ad.city,	       -- город
ad.region_name,    -- название региона
ad.country	       -- название страны 
FROM gd2.addresses ad
