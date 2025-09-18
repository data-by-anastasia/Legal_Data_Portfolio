-- ==========================
-- TABLE: documents
-- ==========================

--Заміна значень, де лише лапка (або лапка з пробілами) на NULL
UPDATE documents
SET cause_num = NULL
WHERE TRIM(cause_num) IN ('''', '"');

-- Заміна cause_num, що складається лише з символів
UPDATE documents
SET cause_num = NULL
WHERE TRIM(cause_num) IN ('-', '+', '–', '—', '!', ',', '№', '0');

-- Очищення дужок у judge
UPDATE documents
SET judge = REGEXP_REPLACE(judge, '\s*\(.*?\)\s*', ' ', 'g')
WHERE judge LIKE '%(%' OR judge LIKE '%)%';

-- Очищення cause_num від небажаних початкових символів
UPDATE documents
SET cause_num = REGEXP_REPLACE(cause_num, '^[\s''"!\-\,\.\:\+]+', '')
WHERE cause_num ~ '^[\s''"!\-\,\.\:\+]+';

UPDATE documents
SET cause_num = NULL
WHERE LENGTH(TRIM(cause_num)) IN (1, 2);

UPDATE documents
SET cause_num = REGEXP_REPLACE(cause_num, '\.$', '')
WHERE cause_num ~ '\.$';

-- Видалити пробіли на початку/кінці і замінити подвійні пробіли на один
UPDATE documents
SET 
    cause_num = REGEXP_REPLACE(TRIM(cause_num), ' {2,}', ' ', 'g'),
    judge = REGEXP_REPLACE(TRIM(judge), ' {2,}', ' ', 'g')
WHERE 
    cause_num ~ '(^\s|\s$| {2,})'
    OR judge ~ '(^\s|\s$| {2,})';

-- Заміна "0" на NULL
UPDATE documents
SET cause_num = NULL
WHERE cause_num = '0';

-- ==========================
-- TABLE: cause_categories
-- ==========================

UPDATE cause_categories
SET name = TRIM(REGEXP_REPLACE(REPLACE(name, '  ', ' '), 
               '[\t\n\r\u00A0]', '', 'g'))
WHERE name ~ '[\t\n\r\u00A0]' OR name LIKE ' %' OR name LIKE '% ' OR name LIKE '%  %';

-- ==========================
-- TABLE: courts
-- ==========================
-- Оновлення: trim + видалення лапок + заміни м. -> міста + Луганська -> Луганськ
UPDATE courts
SET name = TRIM(
              REPLACE(
                REPLACE(
                  REPLACE(
                    REPLACE(name, '''', ''),          -- видаляємо одинарні лапки
                    'м. ', 'міста '                   -- заміна скорочення з пробілом
                  ),
                  'м.', 'міста '                      -- заміна скорочення без пробілу
                ),
                'міста Луганська', 'міста Луганськ'   -- виправлення Луганська
              )
            )
WHERE name != TRIM(name)
   OR name LIKE '%''%'
   OR name LIKE '%м.%'
   OR name LIKE '%міста Луганська%';

-- ==========================
-- TABLE: instances
-- ==========================

-- Оновлення не проводилося, оскільки помилок не виявлено.

-- ==========================
-- TABLE: judgment_forms
-- ==========================

-- Оновлення не проводилося, оскільки помилок не виявлено.

-- ==========================
-- TABLE: justice_kinds
-- ==========================

-- Оновлення не проводилося, оскільки помилок не виявлено.

-- ==========================
-- TABLE: regions
-- ==========================

-- Оновлення не проводилося, оскільки помилок не виявлено.
