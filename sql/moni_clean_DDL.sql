-- Script DDL


-- 1) Creamos la BBDD
CREATE DATABASE IF NOT EXISTS moni_clean;


-- 2) Seleccionamos la BBDD
USE moni_clean;


-- 3) Creamos las estructuras de las tablas de la BBDD

-- Tablas provenientes del ETL 'mcc'

-- Tabla 'mcc_category'
DROP TABLE IF EXISTS mcc_category;
CREATE TABLE mcc_category (
  id_mcc_category INT,
  mcc_category VARCHAR(255),
  PRIMARY KEY (id_mcc_category)
);

-- Tabla 'mcc'
DROP TABLE IF EXISTS mcc;
CREATE TABLE mcc (
  mcc_code INT,
  name_mcc VARCHAR(255),
  mcc_category_id INT,
  PRIMARY KEY (mcc_code)
);

-- Tablas provenientes del ETL 'card'

-- Tabla 'card_brand'
DROP TABLE IF EXISTS card_brand;
CREATE TABLE card_brand (
  id_card_brand INT,
  card_brand VARCHAR(255),
  PRIMARY KEY (id_card_brand)
);

-- Tabla 'card_type'
DROP TABLE IF EXISTS card_type;
CREATE TABLE card_type (
  id_card_type INT,
  card_type VARCHAR(255),
  PRIMARY KEY (id_card_type)
);

-- Tabla 'card'
DROP TABLE IF EXISTS card;
CREATE TABLE card (
  id_card INT,
  client_id INT,
  card_number BIGINT,
  expires DATE,
  cvv INT,
  has_chip VARCHAR(255),
  num_cards_issued INT,
  credit_limit_usd DECIMAL(10,2),
  acct_open_date DATE,
  year_pin_last_changed INT,
  card_on_dark_web VARCHAR(255),
  card_brand_id INT,
  card_type_id INT,
  PRIMARY KEY (id_card)
);

-- Tablas provenientes del ETL 'users'

-- Tabla 'city'
DROP TABLE IF EXISTS city;
CREATE TABLE city (
  id_city INT,
  city VARCHAR(255),
  PRIMARY KEY (id_city)
);

-- Tabla 'country'
DROP TABLE IF EXISTS country;
CREATE TABLE country (
  id_country INT,
  country VARCHAR(255),
  PRIMARY KEY (id_country)
);

-- Tabla 'state_usa'
DROP TABLE IF EXISTS state_usa;
CREATE TABLE state_usa (
  id_state_usa INT,
  abbreviation_state_usa VARCHAR(255),
  name_state_usa VARCHAR(255),
  PRIMARY KEY (id_state_usa)
);

-- Tabla 'users'
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id_client INT,
  retirement_age INT,
  birth_year INT,
  birth_month INT,
  sex VARCHAR(255),
  latitude DECIMAL(10,2),
  longitude	DECIMAL(10,2),
  address VARCHAR(255),
  city_id INT,  
  country_id INT,
  state_usa_id INT,  
  per_capita_income_usd DECIMAL(10,2),
  yearly_income_usd DECIMAL(10,2),
  total_debt_usd DECIMAL(10,2),
  credit_score INT,
  num_cards INT,
  PRIMARY KEY (id_client)
);

-- Tablas provenientes del ETL 'transactions'

-- Tabla 'transaction_type'
DROP TABLE IF EXISTS transaction_type;
CREATE TABLE transaction_type (
  id_transaction_type INT,
  transaction_type VARCHAR(255),
  PRIMARY KEY (id_transaction_type)
);

-- Tabla 'error_type'
DROP TABLE IF EXISTS error_type;
CREATE TABLE error_type (
  id_error_type INT,
  error_type VARCHAR(255),
  PRIMARY KEY (id_error_type)
);

-- Tabla 'transactions'
DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
  id_transaction INT,
  date_tx DATE,
  client_id INT,
  card_id INT,
  amount_usd DECIMAL(10,2),
  merchant_id INT,
  zip_code INT,
  code_mcc INT,
  time_tx TIME,
  calendar_id INT,
  time_id VARCHAR(4),
  transaction_type_id INT,
  city_id INT,
  country_id INT,
  state_usa_id INT,
  status_transaction INT,
  PRIMARY KEY (id_transaction)
);

-- Tabla 'transactions_error_type'
DROP TABLE IF EXISTS transactions_error_type;
CREATE TABLE transactions_error_type (
  transaction_id INT,
  error_type_id INT
);


-- 4) Creamos las relaciones entre tablas (Creación de FK)

-- Tabla 'mcc' con tabla 'mcc_category'
ALTER TABLE mcc
ADD FOREIGN KEY(mcc_category_id) REFERENCES mcc_category(id_mcc_category);

-- Tabla 'card' con tabla 'users'
ALTER TABLE card
ADD FOREIGN KEY(client_id) REFERENCES users(id_client);

-- Tabla 'card' con tabla 'card_brand'
ALTER TABLE card
ADD FOREIGN KEY(card_brand_id) REFERENCES card_brand(id_card_brand);

-- Tabla 'card' con tabla 'card_type'
ALTER TABLE card
ADD FOREIGN KEY(card_type_id) REFERENCES card_type(id_card_type);

-- Tabla 'users' con tabla 'city'
ALTER TABLE users
ADD FOREIGN KEY(city_id) REFERENCES city(id_city);
  
-- Tabla 'users' con tabla 'country'
ALTER TABLE users
ADD FOREIGN KEY(country_id) REFERENCES country(id_country);
  
-- Tabla 'users' con tabla 'state_usa'
ALTER TABLE users
ADD FOREIGN KEY(state_usa_id) REFERENCES state_usa(id_state_usa);

-- Tabla 'transactions' con tabla 'users'
ALTER TABLE transactions
ADD FOREIGN KEY(client_id) REFERENCES users(id_client);

-- Tabla 'transactions' con tabla 'card'
ALTER TABLE transactions
ADD FOREIGN KEY(card_id) REFERENCES card(id_card);

-- Tabla 'transactions' con tabla 'mcc'
ALTER TABLE transactions
ADD FOREIGN KEY(code_mcc) REFERENCES mcc(mcc_code);

-- Tabla 'transactions' con tabla 'transaction_type'
ALTER TABLE transactions
ADD FOREIGN KEY(transaction_type_id) REFERENCES transaction_type(id_transaction_type);

-- Tabla 'transactions' con tabla 'city'
ALTER TABLE transactions
ADD FOREIGN KEY(city_id) REFERENCES city(id_city);

-- Tabla 'transactions' con tabla 'country'
ALTER TABLE transactions
ADD FOREIGN KEY(country_id) REFERENCES country(id_country);

-- Tabla 'transactions' con tabla 'state_usa'
ALTER TABLE transactions
ADD FOREIGN KEY(state_usa_id) REFERENCES state_usa(id_state_usa);
  
-- Tabla 'transactions_error_type' con tabla 'transactions'
ALTER TABLE transactions_error_type
ADD FOREIGN KEY(transaction_id) REFERENCES transactions(id_transaction);

-- Tabla 'transactions_error_type' con tabla 'error_type'
ALTER TABLE transactions_error_type
ADD FOREIGN KEY(error_type_id) REFERENCES error_type(id_error_type);


-- 5) Creamos las vistas para conectar MySQL Workbench con Power BI siguiendo el modelo estrella

-- Creación de la vista 'vw_star_model_pbi_mcc'
CREATE VIEW vw_star_model_pbi_mcc AS
SELECT 
    m.mcc_code,
    m.name_mcc AS mcc,
    mc.mcc_category AS category
FROM mcc m
LEFT JOIN mcc_category mc ON m.mcc_category_id = mc.id_mcc_category;

-- Creación de la vista 'vw_star_model_pbi_card'
CREATE VIEW vw_star_model_pbi_card AS
SELECT 
    c.id_card,
    c.client_id,
    YEAR(c.acct_open_date) AS activation_year,
    YEAR(c.expires) AS expiration_year,
    c.has_chip,
	cb.card_brand,
    ct.card_type,
    c.credit_limit_usd,
   -- Los valores para definir la segmentación del límite de credito se tomaron de los cuartiles arrojados 
   -- en el EDA hecho en Python (archivo '2_ETL_card')
    CASE 
        WHEN c.credit_limit_usd <= 7043 THEN 'low'
        WHEN c.credit_limit_usd > 7043 AND c.credit_limit_usd <= 12593 THEN 'medium'
        WHEN c.credit_limit_usd > 12593 AND c.credit_limit_usd <= 19157 THEN 'high'
        ELSE 'premium'
    END AS credit_limit_segment
FROM card c
LEFT JOIN card_brand cb ON c.card_brand_id = cb.id_card_brand
LEFT JOIN card_type ct ON c.card_type_id = ct.id_card_type;

-- Creación de la vista 'vw_star_model_pbi_users'
CREATE VIEW vw_star_model_pbi_users AS
SELECT
	u.id_client,
    u.sex,
	(SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year  AS current_age, -- Los datos van hasta el año 2019
    u.birth_year,
    u.birth_month,
    CASE
		WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <=20 THEN '<= 20'
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 20 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 30 THEN '21-30'
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 30 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 40 THEN '31-40'
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 40 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 50 THEN '41-50'
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 50 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 60 THEN '51-60'
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 60 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 70 THEN '61-70'
        WHEN (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year > 70 AND (SELECT MAX(YEAR(date_tx)) FROM transactions) - birth_year <= 80 THEN '71-80'
        ELSE '> 80'
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
    -- Los rangos del credit score se tomaron del estándar FICO
    CASE
		WHEN u.credit_score >= 300 AND u.credit_score <= 579 THEN 'bad'
        WHEN u.credit_score >= 580 AND u.credit_score <= 669 THEN 'fair'
        WHEN u.credit_score >= 670 AND u.credit_score <= 739 THEN 'good'
        WHEN u.credit_score >= 740 AND u.credit_score <= 799 THEN 'very good'
        ELSE 'exceptional'
	END AS fico_category,
    ROUND(((u.total_debt_usd)/(u.yearly_income_usd))*100,2) AS debt_to_income_ratio,
    -- Los valores de los niveles de la deuda fueron tomados de los cuartiles que se obtuvieron en el EDA de Python 
    -- (archivo '4_ETL_users')
    CASE
		WHEN u.total_debt_usd = 0 									THEN 'no debt'
        WHEN u.total_debt_usd > 0 	  AND u.total_debt_usd <= 23987 THEN 'low'
        WHEN u.total_debt_usd > 23987 AND u.total_debt_usd <= 89070 THEN 'medium'
        ELSE 'high'
	END AS debt_level,
    u.num_cards,
    -- Clasificación del dti rate en el rango de 1 a 5, donde 1 es riesgo bajo y 5 es riesgo muy alto
    CASE
		WHEN ROUND((u.total_debt_usd)/(u.yearly_income_usd),2) >= 0.2 AND ROUND((u.total_debt_usd)/(u.yearly_income_usd),2) < 0.3 THEN 2
        WHEN ROUND((u.total_debt_usd)/(u.yearly_income_usd),2) >= 0.3 AND ROUND((u.total_debt_usd)/(u.yearly_income_usd),2) < 0.45 THEN 3
        WHEN ROUND((u.total_debt_usd)/(u.yearly_income_usd),2) >= 0.45 AND ROUND((u.total_debt_usd)/(u.yearly_income_usd),2) < 0.6 THEN 4
        WHEN ROUND((u.total_debt_usd)/(u.yearly_income_usd),2) >= 0.6 THEN 5
        ELSE 1
	END AS debt_risk,
     -- Clasificación del riesgo crediticio en el rango de 1 a 5, donde 1 es riesgo bajo y 5 es riesgo muy alto
    CASE
		WHEN u.credit_score < 580 THEN 5
        WHEN u.credit_score >= 580 AND u.credit_score < 670 THEN 4
        WHEN u.credit_score >= 670 AND u.credit_score < 740 THEN 3
        WHEN u.credit_score >= 740 AND u.credit_score < 800 THEN 2
        ELSE 1
	END AS credit_risk,
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
LEFT JOIN country ctry ON u.country_id = id_country
LEFT JOIN state_usa ste ON u.state_usa_id = id_state_usa;

-- Creación de la vista 'vw_star_model_pbi_transactions'
CREATE VIEW vw_star_model_pbi_transactions AS
SELECT 
	t.id_transaction,
    t.date_tx,
	t.client_id, 
    t.card_id, 
    t.amount_usd, 
    -- Los valores de los montos en dólares de las transacciones fueron tomados de los cuartiles que se obtuvieron 
    -- en el EDA de Python (archivo '3_ETL_transactions')
    CASE
		WHEN t.amount_usd <= 9 THEN '<= 9'
        WHEN t.amount_usd > 9 AND t.amount_usd <= 29 THEN '10 - 29'
        WHEN t.amount_usd > 29 AND t.amount_usd <= 63 THEN '30 - 63'
		ELSE '> 63'
	END AS amount_usd_group,
    t.code_mcc, 
    t.calendar_id, 
    CAST(t.time_id AS SIGNED) AS time_id,
    tp.transaction_type,
    c.city,
    co.country,
    su.name_state_usa AS state,
    t.status_transaction
FROM transactions t
LEFT JOIN transaction_type tp ON t.transaction_type_id = tp.id_transaction_type
LEFT JOIN city c ON t.city_id = c.id_city
LEFT JOIN country co ON t.country_id = co.id_country
LEFT JOIN state_usa su ON t.state_usa_id = su.id_state_usa;

-- Creación de la vista 'vw_star_model_pbi_segment_rfm'
CREATE VIEW vw_star_model_pbi_segment_rfm AS
-- a) Cálculo de las métricas RFM: Recencia, Frecuencia y Monetario de los últimos 12 meses
WITH metrics_rfm AS (
	SELECT 
		client_id,
        MAX(date_tx) AS last_date_tx,
		DATEDIFF((
		SELECT DATE_ADD(MAX(date_tx), INTERVAL 1 DAY) -- Nos posicionamos en la fecha posterior a la última fecha del dataset
        FROM transactions
		), MAX(date_tx)
        ) AS recency,
		COUNT(DISTINCT id_transaction) AS frequency,
		SUM(amount_usd) AS monetary
	FROM transactions
    WHERE date_tx >= DATE_SUB((SELECT DATE_ADD(MAX(date_tx), INTERVAL 1 DAY) FROM transactions), INTERVAL 1 YEAR)
	GROUP BY client_id
),
-- b) Asignación de las puntuaciones RFM en función de 3 tramos
scores_rfm AS (
	SELECT 
		client_id,
		CASE
			WHEN recency <=1 THEN '3'
            WHEN recency > 1 AND recency <=30 THEN '2'
            ELSE '1'
		END AS score_r,
        NTILE(3) OVER (ORDER BY frequency) AS score_f,
        NTILE(3) OVER (ORDER BY monetary) AS score_m
    FROM metrics_rfm       
)
-- c) Segmentación RFM de los clientes
SELECT
	client_id,
    CONCAT(score_r, score_f, score_m) AS score_rfm,
    CASE
		WHEN CONCAT(score_r, score_f, score_m) IN ('333', '332', '331') THEN 'champion'
		WHEN CONCAT(score_r, score_f, score_m) IN ('233', '232', '231') THEN 'loyal'
		WHEN CONCAT(score_r, score_f, score_m) IN ('133', '132', '131') THEN 'you can´t miss it'
		WHEN CONCAT(score_r, score_f, score_m) IN ('323', '322', '321') THEN 'potential'
		WHEN CONCAT(score_r, score_f, score_m) IN ('223', '222', '221') THEN 'needs attention'
		WHEN CONCAT(score_r, score_f, score_m) IN ('123', '122', '121') THEN 'at risk'
		WHEN CONCAT(score_r, score_f, score_m) IN ('313', '312', '311') THEN 'new customer'
		WHEN CONCAT(score_r, score_f, score_m) IN ('213', '212', '211') THEN 'asleep'
		ELSE 'hibernating'
	END AS segment_rfm
FROM scores_rfm;

/*
Significado de los segmentos RFM:
- 'champion': Han hecho transacciones recientemente, hacen transacciones habitualmente y son de los que más gastan.
- 'loyal': Gastan dinero y hacen transacciones habitualmente.
- 'you can´t miss it': Buenos niveles de gasto y frecuencia pero hace tiempo que hacen transacciones. 
- 'potential': Estos clientes han hecho transacciones recientemente, han gastado una buena cantidad de dinero y 
han hecho transacciones más de una vez. 
- 'needs attention': Clientes con frecuencia y volumen de gasto promedio, y hace tiempo que no hacen transacciones.
- 'at risk': Clientes que están en la media de gasto y frecuencia pero están tardando en volver a hacer transacciones.
- 'new customer': Han hecho transacciones recientemente, pero aún tienen muy poca frecuencia o volumen de gasto.
- 'asleep': Se encuentran por debajo del promedio de la cartera de clientes en frecuencia y volumen de gasto. Y hace algo de 
tiempo que no hacen transacciones.
- 'hibernating': Son los que más tiempo llevan sin hacer transacciones, además tienen los niveles más bajos de transacciones y volumen 
de gasto. 
*/