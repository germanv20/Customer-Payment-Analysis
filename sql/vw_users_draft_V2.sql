USE moni_clean;

-- Creación de la vista 'vw_star_model_pbi_users' para conectar con Power BI (modelo estrella)
CREATE VIEW vw_star_model_pbi_users AS
SELECT
	u.id_client,
    u.sex,
    (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year  AS current_age,
    u.birth_year,
    u.birth_month,
    CASE
		WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <=20 THEN '<=20'
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 20 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 30 THEN '21-30'
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 30 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 40 THEN '31-40'
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 40 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 50 THEN '41-50'
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 50 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 60 THEN '51-60'
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 60 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 70 THEN '61-70'
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 70 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 80 THEN '71-80'
        ELSE '>80'
	END AS age_range,
    u.retirement_age,
    u.latitude,
    u.longitude,
    cy.city,
    ste.abbreviation_state_usa AS state,
    ctry.country,
    u.per_capita_income_usd,
    u.yearly_income_usd,
    u.total_debt_usd,
    u.credit_score,
    -- Los rangos del credit score se tomaron del estandar FICO
    CASE
		WHEN u.credit_score >= 300 AND u.credit_score <= 579 THEN 'bad'
        WHEN u.credit_score >= 580 AND u.credit_score <= 669 THEN 'fair'
        WHEN u.credit_score >= 670 AND u.credit_score <= 739 THEN 'good'
        WHEN u.credit_score >= 740 AND u.credit_score <= 799 THEN 'very good'
        ELSE 'exceptional'
	END AS fico_category,
    ROUND(((u.total_debt_usd)/(u.yearly_income_usd))*100,2) AS debt_to_income_ratio,
    -- Los valores de los niveles de la deuda fueron tomados de los cuartiles que se obtuvieron en el EDA hecho en Python (archivo 4_ETL_users)
    CASE
		WHEN u.total_debt_usd = 0 									THEN 'no debt'
        WHEN u.total_debt_usd > 0 	  AND u.total_debt_usd <= 23987 THEN 'low'
        WHEN u.total_debt_usd > 23987 AND u.total_debt_usd <= 89070 THEN 'medium'
        ELSE 'high'
	END AS debt_level,
    u.num_cards,
    -- Clasificación del dti rate en el rango de 1 a 5, donde 1 riesgo bajo y 5 riesgo muy alto
    CASE
		WHEN ROUND((u.total_debt_usd)/(u.yearly_income_usd),2) >= 0.2 AND ROUND((u.total_debt_usd)/(u.yearly_income_usd),2) < 0.3 THEN 2
        WHEN ROUND((u.total_debt_usd)/(u.yearly_income_usd),2) >= 0.3 AND ROUND((u.total_debt_usd)/(u.yearly_income_usd),2) < 0.45 THEN 3
        WHEN ROUND((u.total_debt_usd)/(u.yearly_income_usd),2) >= 0.45 AND ROUND((u.total_debt_usd)/(u.yearly_income_usd),2) < 0.6 THEN 4
        WHEN ROUND((u.total_debt_usd)/(u.yearly_income_usd),2) >= 0.6 THEN 5
        ELSE 1
	END AS debt_risk,
    -- Clasificación del riesgo crediticio en un rango de 1 a 5, donde 1 es un riesgo crediticio bajo y 5 un riesgo crediticio muy alto
    CASE
		WHEN u.credit_score < 580 THEN 5
        WHEN u.credit_score >= 580 AND u.credit_score < 670 THEN 4
        WHEN u.credit_score >= 670 AND u.credit_score < 740 THEN 3
        WHEN u.credit_score >= 740 AND u.credit_score < 800 THEN 2
        ELSE 1
	END AS credit_risk,
    -- Se agrega un orden a los diferentes rangos de edades
    CASE
		WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <=20 THEN 1
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 20 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 30 THEN 2
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 30 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 40 THEN 3
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 40 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 50 THEN 4
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 50 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 60 THEN 5
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 60 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 70 THEN 6
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 70 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 80 THEN 7
        ELSE 8
	END AS age_range_order
FROM users u
LEFT JOIN city cy ON u.city_id = cy.id_city
LEFT JOIN country ctry ON u.country_id = ctry.id_country
LEFT JOIN state_usa ste ON u.state_usa_id = ste.id_state_usa;