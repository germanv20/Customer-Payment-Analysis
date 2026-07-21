USE moni_clean;

-- Creación de la vista 'vw_star_model_pbi_transactions'
CREATE VIEW vw_star_model_pbi_transactions AS
SELECT 
	t.id_transaction, 
	t.client_id, 
    t.card_id, 
    t.amount_usd, 
    -- Los valores de los montos en dólares de las transacciones fueron tomados de los cuartiles que se obtuvieron en el EDA de Python (archivo '3_ETL_transactions')
    CASE
		WHEN t.amount_usd <= 9 THEN '<= 9'
        WHEN t.amount_usd > 9 AND t.amount_usd <= 29 THEN '10 - 29'
        WHEN t.amount_usd > 29 AND t.amount_usd <= 63 THEN '30 - 63'
        ELSE '>63'
	END AS amount_usd_group,
    t.code_mcc, 
    t.calendar_id, 
    t.time_id,
    tp.transaction_type,
    c.city,
    co.country,
    su.name_state_usa,
    t.status_transaction
FROM transactions t
LEFT JOIN transaction_type tp ON t.transaction_type_id = tp.id_transaction_type
LEFT JOIN city c ON t.city_id = c.id_city
LEFT JOIN country co ON t.country_id = co.id_country
LEFT JOIN state_usa su ON t.state_usa_id = su.id_state_usa;

-- Llamamos la vista creada
SELECT *
FROM vw_star_model_pbi_transactions;