-- =====================================
-- Data Exploration SQL
-- "Паспорт даних"
-- =====================================

-- 1. Кількість рядків у кожній таблиці
SELECT 'Documents' AS table_name, COUNT(*) AS total_rows FROM documents
UNION ALL
SELECT 'Courts', COUNT(*) FROM courts
UNION ALL
SELECT 'Instances', COUNT(*) FROM instances 
UNION ALL
SELECT 'Cause_categories', COUNT(*) FROM cause_categories
UNION ALL
SELECT 'Justice_kinds', COUNT(*) FROM justice_kinds
UNION ALL
SELECT 'Regions', COUNT(*) FROM regions
UNION ALL
select 'Judgment_forms', COUNT (*) from judgment_forms;

-- 2. Дата: мінімальна та максимальна (перевірка діапазону)
SELECT 
    MIN(adjudication_date) AS min_adjudication_date,
    MAX(adjudication_date) AS max_adjudication_date,
    MIN(receipt_date) AS min_receipt_date,
    MAX(receipt_date) AS max_receipt_date,
    MIN(date_publ) AS min_date_published,
    MAX(date_publ) AS max_date_published
FROM documents;

-- 3. Унікальні суди (кількість)
SELECT COUNT(DISTINCT court_code) AS unique_courts
FROM documents;

-- 4. Унікальні судді (кількість)
SELECT COUNT(DISTINCT judge) AS unique_judges
FROM documents;

-- 5. Розподіл документів по категоріях
SELECT cc.category_code, cc.name, COUNT(*) AS total_docs
FROM documents d
LEFT JOIN cause_categories cc ON d.category_code = cc.category_code
GROUP BY cc.category_code, cc.name
ORDER BY cc.category_code;

-- 6. Топ-10 найактивніших судів
SELECT ct.name, COUNT(*) AS total_docs
FROM documents d
LEFT JOIN courts ct ON d.court_code = ct.court_code
GROUP BY ct.name
ORDER BY total_docs DESC
LIMIT 10;

-- 7. Топ-10 найактивніших суддів
SELECT judge, COUNT(*) AS total_docs
FROM documents d
GROUP BY judge
ORDER BY total_docs DESC
LIMIT 10;

-- 8. Кількість документів по роках
select EXTRACT(YEAR FROM adjudication_date) AS year, COUNT(*) AS total_docs
FROM documents
GROUP BY year
ORDER BY year DESC;

-- 9. Кількість документів по місяцях (за весь період)
SELECT 
    EXTRACT(MONTH FROM adjudication_date) AS month_num,
    TO_CHAR(adjudication_date, 'Month') AS month_name,
    COUNT(*) AS total_docs
FROM documents
GROUP BY month_num, month_name
ORDER BY month_num;

-- 10. Скільки справ кожного типу
SELECT jf.name, COUNT(*) AS total_docs
FROM documents d
LEFT JOIN judgment_forms jf ON d.judgment_code = jf.judgment_code
GROUP BY jf.name
ORDER BY total_docs DESC;

-- 11. Перевірка дублювання документів по document_id
SELECT doc_id, COUNT(*) AS cnt
FROM documents
GROUP BY doc_id
HAVING COUNT(*) > 1;

-- 13.Перевірка NULL значень
SELECT 
  COUNT(*) - COUNT(doc_id) AS docid_null,
  COUNT(*) - COUNT(court_code) AS court_code_null,
  COUNT(*) - COUNT(judgment_code) AS judgment_code_null,
  COUNT(*) - COUNT(justice_kind) AS justice_kind_null,
  COUNT(*) - COUNT(category_code) AS category_code_null,
  COUNT(*) - COUNT(cause_num) AS cause_number_null,
  COUNT(*) - COUNT(adjudication_date) AS adjudication_date_null,
  COUNT(*) - COUNT(receipt_date) AS receipt_date_null,
  COUNT(*) - COUNT(judge) AS judge_null,
  COUNT(*) - COUNT(doc_url) AS doc_url_null,
  COUNT(*) - COUNT(status) AS status_null,
  COUNT(*) - COUNT(date_publ) AS date_publish_null
FROM documents;

-- 14. Кількість NULL значень у відсотках
SELECT 
  ROUND(100.0 * (COUNT(*) - COUNT(doc_id)) / COUNT(*), 2) AS docid_null_pct,
  ROUND(100.0 * (COUNT(*) - COUNT(court_code)) / COUNT(*), 2) AS court_code_null_pct,
  ROUND(100.0 * (COUNT(*) - COUNT(judgment_code)) / COUNT(*), 2) AS judgment_code_null_pct,
  ROUND(100.0 * (COUNT(*) - COUNT(justice_kind)) / COUNT(*), 2) AS justice_kind_null_pct,
  ROUND(100.0 * (COUNT(*) - COUNT(category_code)) / COUNT(*), 2) AS category_code_null_pct,
  ROUND(100.0 * (COUNT(*) - COUNT(cause_num)) / COUNT(*), 2) AS cause_number_null_pct,
  ROUND(100.0 * (COUNT(*) - COUNT(adjudication_date)) / COUNT(*), 2) AS adjudication_date_null_pct,
  ROUND(100.0 * (COUNT(*) - COUNT(receipt_date)) / COUNT(*), 2) AS receipt_date_null_pct,
  ROUND(100.0 * (COUNT(*) - COUNT(judge)) / COUNT(*), 2) AS judge_null_pct,
  ROUND(100.0 * (COUNT(*) - COUNT(doc_url)) / COUNT(*), 2) AS doc_url_null_pct,
  ROUND(100.0 * (COUNT(*) - COUNT(status)) / COUNT(*), 2) AS status_null_pct,
  ROUND(100.0 * (COUNT(*) - COUNT(date_publ)) / COUNT(*), 2) AS date_publish_null_pct
FROM documents;

-- 15. Метадані (Documents)
SELECT 
    column_name, 
    data_type, 
    character_maximum_length, 
    numeric_precision, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'documents';

-- ================================
-- Перевірки для довідників
-- ================================

-- 1. Courts (суди)

-- Кількість рядків
SELECT COUNT(*) AS total_rows 
FROM courts;

-- Унікальні значення
SELECT COUNT(DISTINCT court_code) AS unique_court,
       COUNT(DISTINCT name) AS unique_name,
       COUNT(DISTINCT instance_code) AS unique_instance_code,
       COUNT(DISTINCT region_code) AS unique_region_code
FROM courts c;

-- Перевірка NULL значень
SELECT *
FROM courts c 
WHERE court_code IS NULL 
   OR name IS NULL 
   OR instance_code IS NULL 
   OR region_code IS NULL;

-- 2. Cause_categories (категорії справ)

-- Кількість рядків
SELECT COUNT(*) AS total_rows 
FROM cause_categories;

 -- Перевірка на унікальність
select COUNT (distinct name) as distinct_name
       ,COUNT (distinct category_code) as distinct_codes
from cause_categories cc 

 --Перевірка NULL значень
select *
from cause_categories cc 
where category_code is null or name is null; 
