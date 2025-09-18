-- ==========================
-- TABLE: documents
-- ==========================

-- Перегляд усіх даних
SELECT * FROM documents;

-- Кількість рядків
SELECT COUNT(*) FROM documents;

-- Перевірка на NULL значення
SELECT *
FROM documents
WHERE doc_id IS NULL OR court_code IS NULL OR judgment_code IS NULL
   OR justice_kind IS NULL OR category_code IS NULL OR cause_num IS NULL
   OR adjudication_date IS NULL OR receipt_date IS NULL OR judge IS NULL
   OR doc_url IS NULL OR status IS NULL OR date_publ IS NULL;

-- Унікальні значення по колонках
SELECT 
  COUNT(DISTINCT doc_id) AS unique_doc_id,
  COUNT(DISTINCT court_code) AS unique_court,
  COUNT(DISTINCT judgment_code) AS unique_j_code,
  COUNT(DISTINCT justice_kind) AS unique_jkind,
  COUNT(DISTINCT category_code) AS unique_category,
  COUNT(DISTINCT cause_num) AS unique_cause,
  COUNT(DISTINCT adjudication_date) AS unique_adjudication,
  COUNT(DISTINCT receipt_date) AS unique_receipt,
  COUNT(DISTINCT judge) AS unique_judge,
  COUNT(DISTINCT doc_url) AS unique_url,
  COUNT(DISTINCT status) AS unique_status,
  COUNT(DISTINCT date_publ) AS unique_date_publ
FROM documents;

-- Перевірка на дублікати doc_id
SELECT doc_id, COUNT(*) AS duplicate_count
FROM documents
GROUP BY doc_id
HAVING COUNT(*) > 1;

-- Перевірка на пробіли та подвійні пробіли в текстових колонках
SELECT cause_num FROM documents WHERE cause_num != TRIM(cause_num) OR cause_num LIKE '%  %';
SELECT judge FROM documents WHERE judge != TRIM(judge) OR judge LIKE '%  %';
SELECT doc_url FROM documents WHERE doc_url != TRIM(doc_url) OR doc_url LIKE '%  %';

-- Перевірка на недопустимі значення
SELECT * FROM documents WHERE cause_num IN ('unknown', 'n/a', 'none', 'other');

-- Перевірка дат
SELECT * FROM documents WHERE receipt_date < adjudication_date;
SELECT * FROM documents WHERE adjudication_date < '1900-01-01' OR adjudication_date > CURRENT_DATE;

-- ==========================
-- TABLE: cause_categories
-- ==========================
SELECT * 
FROM cause_categories;

SELECT COUNT(*) 
FROM cause_categories;

-- Перевірка на унікальність
SELECT COUNT(DISTINCT category_code) 
FROM cause_categories;

SELECT COUNT(DISTINCT name) 
FROM cause_categories;

 -- Перевірка пробілів, лапок та прихованих символів в одному запиті
SELECT *
FROM cause_categories cc
WHERE 
    -- пробіли на початку, в кінці або подвійні
    name LIKE ' %' OR name LIKE '% ' OR name LIKE '%  %'
    -- лапки на початку або в кінці
    OR name LIKE '''%' OR name LIKE '%''' 
    OR name LIKE '"%' OR name LIKE '%"'
    -- приховані символи: табуляція, переведення рядка, невидимі пробіли
    OR name ~ '\t' OR name ~ '\n' OR name ~ '\r'
    OR name ~ '\u00A0';  -- нерозривний пробіл

-- Перевірка дублікатів
SELECT *
FROM cause_categories
WHERE category_code IN (
    SELECT category_code
    FROM cause_categories
    GROUP BY category_code
    HAVING COUNT(*) > 1
)
ORDER BY category_code;

 --Перевірка NULL значень
select *
from cause_categories cc 
where category_code is null or name is null; 

--Довжина тексту
SELECT name, LENGTH(name) AS name_length
FROM cause_categories cc 
order by name_length;

-- Додаткова колонка (розмежування «категорії» та «підкатегорії») 
select
    category_code,
    name,
    case
        when left(name,1) = upper(left(name,1)) then 'Категорія'
        else 'Підкатегорія'
    end as category_type
from cause_categories
order by category_code;

-- ==========================
-- TABLE: courts
-- ==========================
SELECT * FROM courts;
SELECT COUNT(*) FROM courts;
SELECT COUNT(DISTINCT name) FROM courts;
SELECT * FROM courts  
WHERE 
    -- пробіли на початку, в кінці або подвійні
    name LIKE ' %' OR name LIKE '% ' OR name LIKE '%  %'
    -- лапки на початку або в кінці
    OR name LIKE '''%' OR name LIKE '%''' 
    OR name LIKE '"%' OR name LIKE '%"'
    -- приховані символи: табуляція, переведення рядка, невидимі пробіли
    OR name ~ '\t' OR name ~ '\n' OR name ~ '\r'
    OR name ~ '\u00A0';  -- нерозривний пробіл
-- Перевірка форматування 
SELECT DISTINCT name FROM courts WHERE name LIKE '%м. %' OR name LIKE '%міста %';
-- Перевірка довжини назв судів
SELECT name, LENGTH(name) AS name_length FROM courts ORDER BY name_length DESC;
-- Унікальні значення
SELECT COUNT(DISTINCT court_code) AS unique_court,
       COUNT(DISTINCT name) AS unique_name,
       COUNT(DISTINCT instance_code) AS unique_instance_code,
       COUNT(DISTINCT region_code) AS unique_region_code
FROM courts c;

-- Перевірка на дублікати по name
SELECT name, COUNT(*) AS count_duplicates
FROM courts c
GROUP BY name
HAVING COUNT(*) > 1;

-- Приклади знайдених дублікатів
SELECT * 
FROM courts c 
WHERE name = 'Апеляційний суд Дніпропетровської області';

SELECT * 
FROM courts c 
WHERE name = 'Апеляційний суд Донецької області';

SELECT *
FROM courts c 
WHERE name LIKE '%Верховний%';

-- Перевірка NULL значень
SELECT *
FROM courts c 
WHERE court_code IS NULL 
   OR name IS NULL 
   OR instance_code IS NULL 
   OR region_code IS NULL;

-- ==========================
-- TABLE: instances
-- ==========================
SELECT * FROM instances;
SELECT COUNT(*) FROM instances;
SELECT * FROM instances 
WHERE 
    -- пробіли на початку, в кінці або подвійні
    name LIKE ' %' OR name LIKE '% ' OR name LIKE '%  %'
    -- лапки на початку або в кінці
    OR name LIKE '''%' OR name LIKE '%''' 
    OR name LIKE '"%' OR name LIKE '%"'
    -- приховані символи: табуляція, переведення рядка, невидимі пробіли
    OR name ~ '\t' OR name ~ '\n' OR name ~ '\r'
    OR name ~ '\u00A0';  -- нерозривний пробіл

-- ==========================
-- TABLE: judgment_forms
-- ==========================
SELECT * FROM judgment_forms;
SELECT * FROM judgment_forms  
WHERE 
    -- пробіли на початку, в кінці або подвійні
    name LIKE ' %' OR name LIKE '% ' OR name LIKE '%  %'
    -- лапки на початку або в кінці
    OR name LIKE '''%' OR name LIKE '%''' 
    OR name LIKE '"%' OR name LIKE '%"'
    -- приховані символи: табуляція, переведення рядка, невидимі пробіли
    OR name ~ '\t' OR name ~ '\n' OR name ~ '\r'
    OR name ~ '\u00A0';  -- нерозривний пробіл

-- ==========================
-- TABLE: justice_kinds
-- ==========================
SELECT * FROM justice_kinds;
SELECT * FROM justice_kinds
WHERE 
    -- пробіли на початку, в кінці або подвійні
    name LIKE ' %' OR name LIKE '% ' OR name LIKE '%  %'
    -- лапки на початку або в кінці
    OR name LIKE '''%' OR name LIKE '%''' 
    OR name LIKE '"%' OR name LIKE '%"'
    -- приховані символи: табуляція, переведення рядка, невидимі пробіли
    OR name ~ '\t' OR name ~ '\n' OR name ~ '\r'
    OR name ~ '\u00A0';  -- нерозривний пробіл

-- ==========================
-- TABLE: regions
-- ==========================
SELECT * FROM regions;
SELECT COUNT(*) FROM regions;
SELECT COUNT(DISTINCT name) FROM regions;
SELECT * FROM regions  
WHERE 
    -- пробіли на початку, в кінці або подвійні
    name LIKE ' %' OR name LIKE '% ' OR name LIKE '%  %'
    -- лапки на початку або в кінці
    OR name LIKE '''%' OR name LIKE '%''' 
    OR name LIKE '"%' OR name LIKE '%"'
    -- приховані символи: табуляція, переведення рядка, невидимі пробіли
    OR name ~ '\t' OR name ~ '\n' OR name ~ '\r'
    OR name ~ '\u00A0';  -- нерозривний пробіл;
SELECT name, LENGTH(name) AS name_length FROM regions ORDER BY name_length DESC;
SELECT name, COUNT(*) AS count_duplicates FROM regions GROUP BY name HAVING COUNT(*) > 1;
