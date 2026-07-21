SELECT 
    c.id_card,
    c.client_id,
    YEAR(c.acct_open_date) AS activation_year,
    YEAR(c.expires) AS expiration_year,
    c.has_chip,
    c.credit_limit_usd,
    cb.card_brand,
    ct.card_type,
    -- Los valores para definir la segmentación del límite de credito se tomaron de los cuartiles arrojados en el EDA hecho en Python (archivo 2_ETL_card)
    CASE 
        WHEN c.credit_limit_usd <= 7043 THEN 'low'
        WHEN c.credit_limit_usd > 7043  AND c.credit_limit_usd <= 12593 THEN 'medium'
        WHEN c.credit_limit_usd > 12593 AND c.credit_limit_usd <= 19157 THEN 'high'
        ELSE 'premium'
    END AS credit_limit_segment
FROM card c
LEFT JOIN card_brand cb ON c.card_brand_id = cb.id_card_brand
LEFT JOIN card_type ct ON c.card_type_id = ct.id_card_type;