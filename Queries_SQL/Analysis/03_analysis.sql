-- 1. Всі документи
SELECT * 
FROM documents;

-- 2. Унікальні категорії
SELECT DISTINCT category_code
	,name 
FROM cause_categories
order by 1;

-- 3. Загальна кількість документів
SELECT COUNT(*) AS total_docs 
FROM documents;

-- 4. Кількість документів по категоріях
SELECT category_code
        , COUNT(*) AS total_docs
FROM documents
GROUP BY category_code
ORDER BY total_docs DESC;

-- 5. Кількість документів по судах
SELECT court_code
       , COUNT(*) AS total_docs
FROM documents
GROUP BY court_code
ORDER BY total_docs DESC;

-- 6. Кількість документів по роках
SELECT EXTRACT(YEAR FROM adjudication_date) AS YEAR
      , COUNT(*) AS total_docs
FROM documents
GROUP BY year
ORDER BY year DESC;

-- 7. Кількість документів по місяцях
SELECT EXTRACT(MONTH FROM adjudication_date) AS MONTH
    , COUNT(*) AS total_docs
FROM documents
GROUP BY month
ORDER BY month;

-- 8. Топ-5 категорій за кількістю документів
SELECT category_code
      , COUNT(*) AS total_docs
FROM documents
GROUP BY category_code
ORDER BY total_docs DESC
LIMIT 5;

-- 9. Топ-5 судів за кількістю документів
SELECT court_code
	   , COUNT(*) AS total_docs
FROM documents
GROUP BY court_code
ORDER BY total_docs DESC
LIMIT 5;

-- 10. Середня кількість документів на суд
SELECT ROUND(AVG(doc_count), 2) AS avg_docs
FROM (
    SELECT court_code
    , COUNT(*) AS doc_count
    FROM documents
    GROUP BY court_code
) t;

-- 11. Відсоток документів кожного суду
SELECT court_code
	, ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM documents),2) AS percent_docs
FROM documents
GROUP BY court_code
ORDER BY percent_docs DESC;

-- 12. Відсоток документів кожної категорії
SELECT category_code
	, ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM documents),2) AS percent_docs
FROM documents
GROUP BY category_code
ORDER BY percent_docs DESC;

-- 13. Кумулятивна кількість документів по категоріях
SELECT category_code
      , COUNT(*) AS total_docs
      , SUM(COUNT(*)) OVER (ORDER BY COUNT(*) DESC) AS cum_sum
FROM documents
GROUP BY category_code
ORDER BY total_docs DESC;

-- 14. Кумулятивний відсоток документів по категоріях
SELECT category_code
		, COUNT(*) AS total_docs
		, ROUND (SUM(COUNT(*)) OVER (ORDER BY COUNT(*) DESC) *100.0/(SELECT COUNT(*) FROM documents),2) AS cum_percent
FROM documents
GROUP BY category_code
ORDER BY total_docs DESC;

-- 15. Топ категорій, що дають 80% документів (Pareto) (запит показує всі категорії, які разом накопичують 80% документів).
WITH docs_per_category AS (
    -- Підрахунок кількості документів по кожній категорії
    SELECT 
        category_code,
        COUNT(*) AS total_docs
    FROM documents
    GROUP BY category_code
),
docs_cum AS (
    -- Кумулятивний відсоток від загальної кількості документів
    SELECT
        category_code,
        total_docs,
        SUM(total_docs) OVER (ORDER BY total_docs DESC) * 1.0 / SUM(total_docs) OVER () AS cum_percent
    FROM docs_per_category
)
-- Вибір категорій, які дають 80% документів
SELECT *
FROM docs_cum
WHERE cum_percent <= 0.8
ORDER BY cum_percent DESC;

-- 16. Мінімум та максимум документів по судах
SELECT MIN(doc_count), MAX(doc_count)
FROM (
    SELECT court_code, COUNT(*) AS doc_count
    FROM documents
    GROUP BY court_code
) t;

-- 17. Середнє, мінімум, максимум по категоріях
SELECT 
    ROUND(AVG(doc_count),2) AS avg_docs,
    MIN(doc_count) AS min_docs,
    MAX(doc_count) AS max_docs
FROM (
    SELECT category_code, COUNT(*) AS doc_count
    FROM documents
    GROUP BY category_code
) t;

-- 18. Медіана документів на суд
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY doc_count) AS median_docs
FROM (
    SELECT court_code, COUNT(*) AS doc_count
    FROM documents
    GROUP BY court_code
) t;

-- 19. Коефіцієнт варіації по документах на суд
SELECT ROUND(STDDEV(doc_count)/NULLIF(AVG(doc_count),0)*100,2) AS cv_percent
FROM (
    SELECT court_code, COUNT(*) AS doc_count
    FROM documents
    GROUP BY court_code
) t;

-- 20. Стандартне відхилення документів по судах
SELECT ROUND(STDDEV(doc_count),2) AS std_dev
FROM (
    SELECT court_code, COUNT(*) AS doc_count
    FROM documents
    GROUP BY court_code
) t;

-- 21. Документи конкретної категорії
SELECT * 
FROM documents 
WHERE category_code = 40346;

-- 22. Документи конкретного суду
SELECT * 
FROM documents 
WHERE court_code = '5011';

-- 23. Документи по статусу
SELECT status
		, COUNT(*) AS total_docs
FROM documents
GROUP BY status
ORDER BY total_docs DESC;

-- 24. Документи по виду справи 
SELECT jk.name AS justice_kind
		, COUNT(*) AS total_docs
FROM documents d
JOIN justice_kinds jk USING (justice_kind)
GROUP BY jk.name
ORDER BY total_docs DESC;

-- 25. Топ-3 категорії документів на кожен суд
WITH counts AS (
    SELECT court_code, category_code, COUNT(*) AS total_docs
    FROM documents
    GROUP BY court_code, category_code
), ranked AS (
    SELECT court_code, category_code, total_docs,
           RANK() OVER (PARTITION BY court_code ORDER BY total_docs DESC) AS rank
    FROM counts
)
SELECT *
FROM ranked
WHERE rank <= 3
ORDER BY court_code, rank;

-- 26. Судді з найбільшою кількістю документів
SELECT judge
		, COUNT(*) AS total_docs
FROM documents
GROUP BY judge
ORDER BY total_docs DESC
LIMIT 10;

-- 27. Судді, які працюють у кількох судах
SELECT judge
		, COUNT(DISTINCT court_code) AS courts_count
FROM documents
WHERE judge IS NOT NULL
GROUP BY judge
HAVING COUNT(DISTINCT court_code) > 1
ORDER BY courts_count DESC;

-- 28. Категорії без документів
SELECT c.category_code
	, c.name
FROM cause_categories c
LEFT JOIN documents d ON c.category_code = d.category_code
WHERE d.doc_id IS NULL;

-- 29. Документи, де дата надходження рішення до реєстру < дата ухвалення
SELECT doc_id
		, receipt_date
		, adjudication_date
FROM documents
WHERE receipt_date < adjudication_date;

-- 30. Частка документів конкретного суду
SELECT c.name
		, ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM documents),2) AS percent_docs
FROM documents d
left join courts c using (court_code)
GROUP BY c.name
ORDER BY percent_docs DESC;

-- 31. Кількість документів по роках для кожного суду
SELECT c.name
	, EXTRACT(YEAR From d.adjudication_date) AS year
	, COUNT(*) AS total_docs
From documents d
left join courts c using (court_code)
group by c.name, year
order by total_docs DESC;

-- 32. Кількість документів по місяцях для кожної категорії
SELECT category_code
	, EXTRACT(MONTH FROM adjudication_date) AS month
	, COUNT(*) AS total_docs
FROM documents
GROUP BY category_code, month
ORDER BY category_code, month;

-- 33. Кумулятивна кількість документів по роках
SELECT EXTRACT(YEAR FROM adjudication_date) AS year
		, COUNT(*) AS total_docs
		, SUM(COUNT(*)) OVER (ORDER BY EXTRACT(YEAR FROM adjudication_date)) AS cum_docs
FROM documents
GROUP BY year
ORDER BY year;

-- 34. Частка документів по роках (% від загальної кількості)
SELECT EXTRACT(YEAR FROM adjudication_date) AS year
		, COUNT(*) AS total_docs
		, ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM documents),2) AS percent_docs
FROM documents
GROUP BY year
ORDER BY year;

-- 35. Розподіл документів по днях тижня
SELECT TO_CHAR(adjudication_date, 'Day') AS day_of_week
	, COUNT(*) AS total_docs
FROM documents
GROUP BY day_of_week
ORDER BY total_docs DESC;

-- 36. Топ-10 суддів за кількістю документів у конкретному році
SELECT EXTRACT(YEAR FROM adjudication_date) AS year
		, judge
		, COUNT(*) AS total_docs
FROM documents
GROUP BY year, judge
ORDER BY total_docs DESC
LIMIT 10;

-- 37. Частка документів суддів по роках
SELECT EXTRACT(YEAR FROM adjudication_date) AS year
		, judge
		, ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM documents WHERE EXTRACT(YEAR FROM adjudication_date) = EXTRACT(YEAR FROM adjudication_date)),2) AS percent_docs
FROM documents
GROUP BY year, judge
ORDER BY percent_docs DESC;

-- 38. Документи конкретного виду рішень по інстанціях
SELECT jf.name AS judgment_type
		, i.name AS instance_name
		, COUNT(*) AS total_docs
FROM documents d
JOIN courts c ON d.court_code = c.court_code
JOIN instances i ON c.instance_code = i.instance_code
JOIN judgment_forms jf ON d.judgment_code = jf.judgment_code
GROUP BY jf.name, i.name
ORDER BY total_docs DESC;

-- 39. Частка виду рішень у кожній інстанції
SELECT i.name AS instance_name
	 , jf.name AS judgment_type
	 , ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(PARTITION BY i.name),2) AS percent_docs
FROM documents d
JOIN courts c ON d.court_code = c.court_code
JOIN instances i ON c.instance_code = i.instance_code
JOIN judgment_forms jf ON d.judgment_code = jf.judgment_code
GROUP BY i.name, jf.name
ORDER BY i.name, percent_docs DESC;

-- 40. Документи по регіонах і інстанціях
SELECT r.name AS region
	, i.name AS instance_name
	, COUNT(*) AS total_docs
FROM documents d
JOIN courts c ON d.court_code = c.court_code
JOIN regions r ON c.region_code = r.region_code
JOIN instances i ON c.instance_code = i.instance_code
GROUP BY r.name, i.name
ORDER BY r.name, total_docs DESC;

-- 41. Топ-5 категорій по кожному виду судочинства
WITH top AS (
SELECT jk.name
	, d.category_code
	, Count (*)
	, row_number() OVER (PARTITION BY jk.name ORDER BY count(*) DESC) AS RANK
	FROM documents d 
	LEFT JOIN justice_kinds jk USING (justice_kind)
	GROUP BY jk.name, d.category_code
)
SELECT *
FROM top 
WHERE RANK <=5;

-- 42. Судді без активних документів (status=1)
SELECT DISTINCT d1.judge
FROM documents d1
WHERE NOT EXISTS (
    SELECT 1
    FROM documents d2
    WHERE d2.judge = d1.judge AND d2.status = 1
);

-- 43. Частка категорій у конкретному суді
SELECT court_code
		, category_code
		, ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(PARTITION BY court_code),2) AS percent_docs
FROM documents
GROUP BY court_code, category_code
ORDER BY court_code, percent_docs DESC;

-- 44. Топ-3 категорії документів на кожен регіон
WITH counts AS (
    SELECT r.name AS region
    	, category_code
    	, COUNT(*) AS total_docs
    FROM documents d
    JOIN courts c ON d.court_code = c.court_code
    JOIN regions r ON c.region_code = r.region_code
    GROUP BY r.name, category_code
), ranked AS (
    SELECT region, category_code, total_docs,
           RANK() OVER(PARTITION BY region ORDER BY total_docs DESC) AS rank
    FROM counts
)
SELECT *
FROM ranked
WHERE rank <= 3
ORDER BY region, rank;

-- 45. Частка рішень по типу судочинства в регіонах
SELECT r.name AS region
	, jk.name AS justice_kind
	, ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(PARTITION BY r.name),2) AS percent_docs
FROM documents d
JOIN courts c ON d.court_code = c.court_code
JOIN regions r ON c.region_code = r.region_code
JOIN justice_kinds jk ON d.justice_kind = jk.justice_kind
GROUP BY r.name, jk.name
ORDER BY region, percent_docs DESC;

-- 46. Кумулятивна сума документів по суддях
SELECT judge
	, COUNT(*) AS total_docs
	, SUM(COUNT(*)) OVER (ORDER BY COUNT(*) DESC) AS cum_docs
FROM documents
GROUP BY judge
ORDER BY total_docs DESC;

-- 47. Топ-10 суддів по середній кількості документів на рік
SELECT judge
      ,ROUND(AVG(yearly_docs),2) AS avg_docs_per_year
FROM (
    SELECT judge, EXTRACT(YEAR FROM adjudication_date) AS year, COUNT(*) AS yearly_docs
    FROM documents
    GROUP BY judge, year
) t
GROUP BY judge
ORDER BY avg_docs_per_year DESC
LIMIT 10;
