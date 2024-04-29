--------------------------------------------------------
--  DDL for Package Body DT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DT_API" AS
/* $Header: dtapiapi.pkb 120.0 2005/05/27 23:09:43 appldev noship $ */
g_package     VARCHAR2(33) := ' dt_api.'; -- Global package name
g_debug       BOOLEAN; -- debug var. no need to initialise here because
                       -- it is set on every entry point into dt_api
                       -- (i.e. every public proc/fct)
g_oracle_db_version     CONSTANT NUMBER := hr_general2.get_oracle_db_version;
                        -- holds the current ORACLE DB Major
                        -- release number (e.g. 8.1, 9.0, 9.1)
g_dynamic_sql_comment   CONSTANT VARCHAR2(500) :=
  ' /* dynamic SQL from dt_api.{proc} for'||
  ' ORACLE '||TO_CHAR(g_oracle_db_version)||' */'; -- dynamic SQL comment str
g_dynamic_sql           VARCHAR2(2000); -- dynamic SQL text string
-- set private package vars once to avoid cross package calls to hr_api
-- even though it might be redundant because they are defined as
-- constants in hr_api.
g_sot                   CONSTANT DATE         := hr_api.g_sot;
g_eot                   CONSTANT DATE         := hr_api.g_eot;
g_insert                CONSTANT VARCHAR2(30) := hr_api.g_insert;
g_correction            CONSTANT VARCHAR2(30) := hr_api.g_correction;
g_update                CONSTANT VARCHAR2(30) := hr_api.g_update;
g_update_override       CONSTANT VARCHAR2(30) := hr_api.g_update_override;
g_update_change_insert  CONSTANT VARCHAR2(30) := hr_api.g_update_change_insert;
g_zap                   CONSTANT VARCHAR2(30) := hr_api.g_zap;
g_delete                CONSTANT VARCHAR2(30) := hr_api.g_delete;
g_future_change         CONSTANT VARCHAR2(30) := hr_api.g_future_change;
g_delete_next_change    CONSTANT VARCHAR2(30) := hr_api.g_delete_next_change;
g_varchar2              CONSTANT VARCHAR2(9)  := hr_api.g_varchar2;
g_number                CONSTANT NUMBER       := hr_api.g_number;
g_date                  CONSTANT DATE         := hr_api.g_date;
-- define the effective rows record type
TYPE g_dt_effective_rows_rec IS RECORD
      (effective_start_date DATE,
       effective_end_date   DATE);
-- define the effective rows table
TYPE g_dt_effective_rows_tab IS TABLE OF
     g_dt_effective_rows_rec INDEX BY BINARY_INTEGER;
-- define weak REF CURSOR type
TYPE g_csr_type IS REF CURSOR;
-- define a table of date's type
TYPE g_date_tab_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
-- define an empty table which is NEVER set and only used to support
-- NOCOPY reset behaviour. This var is only referenced in get_effective_rows
-- procedure and is defined as a global to minimise the number or
-- instanations to 1.
g_empty_effective_rows g_dt_effective_rows_tab; -- only referenced on an
                                                -- error and always empty
-- ----------------------------------------------------------------------------
-- |--------------------------< get_effective_rows >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: this procedure is used to select (and lock if required) a set
--              of effective rows for the base table/column/key combo. all rows
--              are returned as a table of records (p_effective_rows), together
--              with the index position indicated which element contains the
--              current effective row as of the passed in p_date_from
--              parameter. to ensure that a current row exist the
--              p_date_from_valid parameter can be set to TRUE. if the check
--              fails (e.g. no current row) then an error is raised. the rows
--              can be locked by setting p_lock_rows to TRUE.
-- ----------------------------------------------------------------------------
PROCEDURE get_effective_rows
            (p_date_from        IN     DATE,
             p_base_table_name  IN     VARCHAR2,
             p_base_key_column  IN     VARCHAR2,
             p_base_key_value   IN     NUMBER,
             p_lock_rows        IN     BOOLEAN,
             p_date_from_valid  IN     BOOLEAN,
             p_effective_rows      OUT NOCOPY g_dt_effective_rows_tab,
             p_date_from_row_idx   OUT NOCOPY BINARY_INTEGER) IS
  --
  l_csr                  g_csr_type;
  l_idx                  PLS_INTEGER;
  l_cnt                  BINARY_INTEGER;
  l_effective_start_date g_date_tab_type;
  l_effective_end_date   g_date_tab_type;
  l_proc VARCHAR2(72);
  --
BEGIN
  IF g_debug THEN
    l_proc := g_package||'get_effective_rows';
    hr_utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- If the p_key_value is null and we are locking then we must not
  -- process the sql as it could be a nullable column.
  IF (p_base_key_value IS NULL AND p_lock_rows) THEN
    IF g_debug THEN
      hr_utility.Set_Location('Leaving :'||l_proc, 10);
      -- the resulting p_effective_rows and p_date_from_row_idx will be NULL
    END IF;
    RETURN;
  END IF;
  -- note: for ORACLE 8.1.6 and beyond you don't need to specify an
  --       ORDER BY clause but has just been placed in for backwards compat.
  --       for 8.1.6+ no performance impact will be incurred because the CBO
  --       will realise that the rows being returned are in a sorted format.
  --       just being ultra defensive...
  g_dynamic_sql :=
    'SELECT t1.effective_start_date, t1.effective_end_date '||
    'FROM '||LOWER(p_base_table_name)||' t1 '||
    'WHERE t1.'||LOWER(p_base_key_column)||' = :p_key_value '||
    'AND t1.effective_end_date >= :p_date_from '||
    'ORDER BY t1.effective_start_date';
  -- check to see if the rows needs to be locked
  IF p_lock_rows THEN
    -- add locking condition
    g_dynamic_sql := g_dynamic_sql || ' FOR UPDATE NOWAIT';
  END IF;
  -- set the dynamic SQL comment for identification
  dt_api.g_dynamic_sql :=
    dt_api.g_dynamic_sql||
    REPLACE(dt_api.g_dynamic_sql_comment,'{proc}','get_effective_rows');
  -- open cursor, bulk fetch all the rows and close
  OPEN l_csr FOR g_dynamic_sql USING p_base_key_value, p_date_from;
  -- NOTE: ORACLE VERSION CODE SWITCH
  -- ================================
  -- Oracle 8/8i does not support BULK COLLECT of a dynamic PL/SQL
  -- statement.
  IF g_oracle_db_version >= 9 THEN
    -- Oracle 9+ being used so perform a BULK COLLECT
    FETCH l_csr BULK COLLECT INTO l_effective_start_date,
                                  l_effective_end_date;
  ELSE
    -- Pre Oracle 9 so fetch each row individually
    l_cnt := 1;
    LOOP
      -- A Pre Oracle 9 DB is being used so LOOP through fetching each row
      FETCH l_csr INTO l_effective_start_date(l_cnt), l_effective_end_date(l_cnt);
      EXIT WHEN l_csr%NOTFOUND;
      l_cnt := l_cnt + 1;
    END LOOP;
  END IF;
  CLOSE l_csr;
  -- set the current effective row indicator to 0
  l_idx := 0;
  -- loop through each returned date and place in p_effective_rows OUT structure
  FOR l_counter IN 1..l_effective_start_date.COUNT LOOP
    p_effective_rows(l_counter).effective_start_date :=
      l_effective_start_date(l_counter);
    p_effective_rows(l_counter).effective_end_date :=
      l_effective_end_date(l_counter);
    -- check to see if this is a current row
    IF l_effective_start_date(l_counter) <= p_date_from AND
       l_effective_end_date(l_counter) >= p_date_from THEN
      -- set the current row as of the date index var
      p_date_from_row_idx := l_counter;
      l_idx := l_counter;
    END IF;
  END LOOP;
  -- do we need to check that the current row exists and raise an error?
  IF p_date_from_valid AND l_idx = 0 THEN
    -- clear the returning OUTs
    p_effective_rows := dt_api.g_empty_effective_rows;
    p_date_from_row_idx := NULL;
    -- As no rows were returned we must error
    hr_utility.set_message(801, 'HR_7180_DT_NO_ROW_EXIST');
    hr_utility.set_message_token('TABLE_NAME', p_base_table_name);
    hr_utility.set_message_token('SESSION_DATE',
                                 fnd_date.date_to_chardate(p_date_from));
    hr_utility.raise_error;
  END IF;
  IF g_debug THEN
    hr_utility.Set_Location('Leaving :'||l_proc, 15);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- close the cursor if open
    IF l_csr%ISOPEN THEN
      CLOSE l_csr;
    END IF;
    -- clear the returning OUTs
    p_effective_rows := dt_api.g_empty_effective_rows;
    p_date_from_row_idx := NULL;
    -- no rows exist as of the date passed in
    -- therefore a serious integrity problem has ocurred
    hr_utility.set_message(801, 'HR_7423_DT_INVALID_ID');
    hr_utility.set_message_token('ARGUMENT', UPPER(p_base_key_column));
    hr_utility.raise_error;
  WHEN hr_api.object_locked THEN
    -- close the cursor if open
    IF l_csr%ISOPEN THEN
      CLOSE l_csr;
    END IF;
    -- clear the returning OUTs
    p_effective_rows := dt_api.g_empty_effective_rows;
    p_date_from_row_idx := NULL;
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', p_base_table_name);
    hr_utility.raise_error;
  WHEN OTHERS THEN
    -- close the cursor if open
    IF l_csr%ISOPEN THEN
      CLOSE l_csr;
    END IF;
    -- clear the returning OUTs
    p_effective_rows := dt_api.g_empty_effective_rows;
    p_date_from_row_idx := NULL;
    -- unexpected system error, so raise
    RAISE;
END get_effective_rows;
-- ----------------------------------------------------------------------------
-- |----------------------< return_parent_min_date >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: returns the parent min end date.
--
-- ----------------------------------------------------------------------------
FUNCTION return_parent_min_date
          (p_effective_date IN DATE,
           p_lock_rows      IN BOOLEAN,
           p_table_name1    IN VARCHAR2,
           p_key_column1    IN VARCHAR2,
           p_key_value1     IN NUMBER,
           p_table_name2    IN VARCHAR2,
           p_key_column2    IN VARCHAR2,
           p_key_value2     IN NUMBER,
           p_table_name3    IN VARCHAR2,
           p_key_column3    IN VARCHAR2,
           p_key_value3     IN NUMBER,
           p_table_name4    IN VARCHAR2,
           p_key_column4    IN VARCHAR2,
           p_key_value4     IN NUMBER,
           p_table_name5    IN VARCHAR2,
           p_key_column5    IN VARCHAR2,
           p_key_value5     IN NUMBER,
           p_table_name6    IN VARCHAR2,
           p_key_column6    IN VARCHAR2,
           p_key_value6     IN NUMBER,
           p_table_name7    IN VARCHAR2,
           p_key_column7    IN VARCHAR2,
           p_key_value7     IN NUMBER,
           p_table_name8    IN VARCHAR2,
           p_key_column8    IN VARCHAR2,
           p_key_value8     IN NUMBER,
           p_table_name9    IN VARCHAR2,
           p_key_column9    IN VARCHAR2,
           p_key_value9     IN NUMBER,
           p_table_name10   IN VARCHAR2,
           p_key_column10   IN VARCHAR2,
           p_key_value10    IN NUMBER)
         RETURN DATE IS
  --
  l_table_name  VARCHAR2(30);
  l_key_column  VARCHAR2(30);
  l_key_value   NUMBER(15);
  l_proc        VARCHAR2(72);
  l_return_date DATE := dt_api.g_eot;  -- default the returning date to eot
  l_max_date    DATE;
  l_csr         g_csr_type;
  --
BEGIN
  IF g_debug THEN
    l_proc := g_package||'return_parent_min_date';
    hr_utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- setup the table with info
  FOR l_counter IN 1..10 LOOP
    IF    (l_counter = 1) THEN
      l_table_name := p_table_name1;
      l_key_column := p_key_column1;
      l_key_value  := p_key_value1;
    ELSIF (l_counter = 2) THEN
      l_table_name := p_table_name2;
      l_key_column := p_key_column2;
      l_key_value  := p_key_value2;
    ELSIF (l_counter = 3) THEN
      l_table_name := p_table_name3;
      l_key_column := p_key_column3;
      l_key_value  := p_key_value3;
    ELSIF (l_counter = 4) THEN
      l_table_name := p_table_name4;
      l_key_column := p_key_column4;
      l_key_value  := p_key_value4;
    ELSIF (l_counter = 5) THEN
      l_table_name := p_table_name5;
      l_key_column := p_key_column5;
      l_key_value  := p_key_value5;
    ELSIF (l_counter = 6) THEN
      l_table_name := p_table_name6;
      l_key_column := p_key_column6;
      l_key_value  := p_key_value6;
    ELSIF (l_counter = 7) THEN
      l_table_name := p_table_name7;
      l_key_column := p_key_column7;
      l_key_value  := p_key_value7;
    ELSIF (l_counter = 8) THEN
      l_table_name := p_table_name8;
      l_key_column := p_key_column8;
      l_key_value  := p_key_value8;
    ELSIF (l_counter = 9) THEN
      l_table_name := p_table_name9;
      l_key_column := p_key_column9;
      l_key_value  := p_key_value9;
    ELSE
      l_table_name := p_table_name10;
      l_key_column := p_key_column10;
      l_key_value  := p_key_value10;
    END IF;
    -- Ensure that all the working details have been specified
    -- note: it is ignored if not set correctly
    IF NOT ((NVL(l_table_name, dt_api.g_varchar2) =
             dt_api.g_varchar2) OR
            (NVL(l_key_column, dt_api.g_varchar2) =
             dt_api.g_varchar2) OR
            (NVL(l_key_value, dt_api.g_number)    =
             dt_api.g_number)) THEN
      -- we lower the table and column name to always ensure that the
      -- SQL will be exactly the same because callers may have passed
      -- the table/column name in any case format
      l_table_name := LOWER(l_table_name);
      l_key_column := LOWER(l_key_column);
      -- define the the max end date SQL
      -- we only need to return the max row
      -- the MAX function couldn't be used because
      -- you cannot perform a FOR UPDATE.
      -- error if no rows exist.
      -- note: if locking is required, then all rows identified by the query
      --       (not just the 1 row returned) will be locked.
      -- the subquery is used to ensure that at least one row exists before
      -- the proposed effective date
      dt_api.g_dynamic_sql :=
        'SELECT oq.effective_end_date '||
        'FROM '||l_table_name||' oq '||
        'WHERE oq.'||l_key_column||' = :l_key_value '||
        'AND oq.effective_end_date >= :p_effective_date '||
        'AND EXISTS (SELECT NULL FROM '||l_table_name||
        ' sq WHERE sq.'||l_key_column||' = oq.'||l_key_column||
        ' AND sq.effective_start_date <= :p_effective_date) '||
        'ORDER BY oq.effective_end_date DESC';
      -- do we need to lock?
      IF p_lock_rows THEN
        dt_api.g_dynamic_sql := dt_api.g_dynamic_sql||' FOR UPDATE NOWAIT';
      END IF;
      -- set the dynamic SQL comment for identification
      dt_api.g_dynamic_sql :=
        dt_api.g_dynamic_sql||
        REPLACE(dt_api.g_dynamic_sql_comment,'{proc}','return_parent_min_date');
      -- OPEN the cursor
      OPEN  l_csr
      FOR   g_dynamic_sql
      USING l_key_value, p_effective_date, p_effective_date;
      -- although the query can return more than one row we are only interested
      -- in FETCHing the 1st row
      FETCH l_csr INTO l_max_date;
      IF l_csr%NOTFOUND THEN
        -- no rows returned, raise an error
        RAISE NO_DATA_FOUND;
      END IF;
      -- CLOSE the cursor
      CLOSE l_csr;
      -- if the returned l_max_date is less than the
      -- effective_date then error because a parental row does NOT exist.
      IF (l_max_date < p_effective_date) THEN
        -- the parental rows specified do not exist as of the effective date
        -- therefore a serious integrity problem has ocurred
        RAISE NO_DATA_FOUND;
      ELSE
        -- the LEAST function will then compare the working l_return_date with
        -- the returned maximum effective end date (l_max_date) and set the
        -- l_return_date to the minimum of these dates
        l_return_date := LEAST(l_return_date, l_max_date);
      END IF;
    END IF;
  END LOOP;
  IF g_debug THEN
    hr_utility.Set_Location('Leaving:'||l_proc, 10);
  END IF;
  RETURN(l_return_date);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- CLOSE the cursor if its open
    IF l_csr%ISOPEN THEN
      CLOSE l_csr;
    END IF;
    -- The parental row specified does not exist as of the effective date
    -- therefore a serious integrity problem has ocurred
    -- bug 3788667
    hr_utility.set_message(801, 'HR_7423_DT_INVALID_ID');
    hr_utility.set_message_token('ARGUMENT', UPPER(l_key_column));
    hr_utility.raise_error;
  WHEN hr_api.object_locked THEN
    -- CLOSE the cursor if its open
    IF l_csr%ISOPEN THEN
      CLOSE l_csr;
    END IF;
    -- bug 3788667
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', UPPER(l_table_name));
    hr_utility.raise_error;
  WHEN OTHERS THEN
    -- CLOSE the cursor if its open
    IF l_csr%ISOPEN THEN
      CLOSE l_csr;
    END IF;
    -- bug 3788667
    -- raise system error
    RAISE;
END return_parent_min_date;
-- ----------------------------------------------------------------------------
-- |-------------------------< Effective_Date_Valid >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Procedure ensures that the effective date is not null and
--              exists on or after the start of time.
--
-- ----------------------------------------------------------------------------
PROCEDURE Effective_Date_Valid(p_effective_date IN DATE) IS
  l_proc VARCHAR2(72);
BEGIN
  IF g_debug THEN
    l_proc := g_package||'Effective_Date_Valid';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- Ensure that all the mandatory arguments are not null
  -- [ start of change 30.14 ]
  IF p_effective_date IS NULL THEN
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_effective_date',
                               p_argument_value => p_effective_date);
  END IF;
  -- [ end of change 30.14 ]
  IF (p_effective_date < dt_api.g_sot) THEN
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  END IF;
  -- Ensure p_effective_date is not later than dt_api.g_eot end of time
  IF (p_effective_date > dt_api.g_eot) THEN
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  END IF;
  -- Check that effective_date does not include a time component. If set
  -- then raise an error because it should have been truncated to just a day,
  -- month year value before the DT logic is called.
  IF p_effective_date <> TRUNC(p_effective_date) THEN
    hr_utility.set_message(801, 'HR_51322_DT_TIME_SET');
    hr_utility.raise_error;
  END IF;
  IF g_debug THEN
    Hr_Utility.Set_Location('Leaving :'||l_proc, 10);
  END IF;
END Effective_Date_Valid;
-- ----------------------------------------------------------------------------
-- |------------------------< Return_Max_End_Date >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Function returns the maximum effective_end_date for the
--              specified table and primary key.
--              NOTE: if the maximum end date doesn't exist (i.e. no rows
--                    exist for the specified table, key values) then we
--                    return the null value.
-- ----------------------------------------------------------------------------
FUNCTION return_max_end_date
         (p_base_table_name IN VARCHAR2,
          p_base_key_column IN VARCHAR2,
          p_base_key_value  IN NUMBER)
         RETURN DATE IS
  --
  l_proc     VARCHAR2(72);
  l_max_date DATE;
  --
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := g_package||'return_max_end_date';
    hr_utility.set_location('Entering:'||l_proc, 5);
  END IF;
  -- Ensure that all the mandatory arguments are not null
  -- [ start of change 30.14 ]
  IF p_base_table_name IS NULL OR p_base_key_column IS NULL OR
     p_base_key_value IS NULL THEN
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_base_table_name',
                               p_argument_value => p_base_table_name);
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_base_key_column',
                               p_argument_value => p_base_key_column);
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_base_key_value',
                               p_argument_value => p_base_key_value);
  END IF;
  -- [ end of change 30.14 ]
  -- Define dynamic sql text with substitution tokens
  g_dynamic_sql:=
    'SELECT MAX(t.effective_end_date) '||
    'FROM '||LOWER(p_base_table_name)||' t '||
    'WHERE t.'||LOWER(p_base_key_column)||' = :p_base_key_value';
  -- set the dynamic SQL comment for identification
  dt_api.g_dynamic_sql :=
    dt_api.g_dynamic_sql||
    REPLACE(dt_api.g_dynamic_sql_comment,'{proc}','return_max_end_date');
  --
  EXECUTE IMMEDIATE g_dynamic_sql
  INTO  l_max_date
  USING p_base_key_value;
  --
  IF g_debug THEN
    hr_utility.set_location('Leaving :'||l_proc, 10);
  END IF;
  RETURN(l_max_date);
END return_max_end_date;
-- ----------------------------------------------------------------------------
-- |----------------------------< Lck_Child >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Locks the specified child entity maximum row for the specified
--              parent key value:
--
--              E.g. ('X' denotes locked rows)
--
--              |---------------------------------------| Parent Entity
--              |---------|XXXXXXXXXX|                    Child DT Rows 1
--              |-------------|XXXXXXXXXXXXXXX|           Child DT Rows 2
--              |---|-----|XXXXXXXXXXXXX|                 Child DT Rows 3
--
--              After locking the maximum row, we must ensure that the
--              effective end date of the locked row cannot exceed
--              the validation start date.
--
--              No processing will be completed if the p_parent_key_value is
--              null because the column could be defined as nullable.
--
-- ----------------------------------------------------------------------------
PROCEDURE lck_child
         (p_child_table_name      IN VARCHAR2,
          p_child_key_column      IN VARCHAR2,
          p_parent_key_column     IN VARCHAR2,
          p_parent_key_value      IN NUMBER,
          p_validation_start_date IN DATE) IS
--
  l_proc        VARCHAR2(72);
  l_cursor      g_csr_type;
  l_date_tab    g_date_tab_type;
  l_cnt         BINARY_INTEGER;
--
BEGIN
  IF g_debug THEN
    l_proc := g_package||'lck_child';
    hr_utility.set_location('Entering:'||l_proc, 5);
  END IF;
  --
  -- Ensure that all the required parameters exist
  -- Note: we don't check the p_parent_key_value argument
  --
  -- [ start of change 30.14 ]
  --
  -- hr_api.mandatory_arg_error(p_api_name       => l_proc,
  --                           p_argument       => 'p_child_table_name',
  --                           p_argument_value => p_child_table_name);
  -- hr_api.mandatory_arg_error(p_api_name       => l_proc,
  --                            p_argument       => 'p_child_key_column',
  --                            p_argument_value => p_child_key_column);
  IF p_parent_key_column IS NULL THEN
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_parent_key_column',
                               p_argument_value => p_parent_key_column);
  END IF;
  -- Define dynamic sql text with substitution tokens
  -- old SQL before optimisations (see next SQL text below)
  -- g_dynamic_sql :=
  --  'select t1.effective_end_date effective_end_date '||
  --  'from '||p_child_table_name||' t1 '||
  --  'where (t1.'||p_child_key_column||',t1.effective_start_date,'||
  --  't1.effective_end_date) in '||
  --  '(select t2.'||p_child_key_column||',max(t2.effective_start_date),'||
  --  'max(t2.effective_end_date) from '||p_child_table_name||' t2 '||
  --  'where t2.'||p_parent_key_column||' = :p_parent_key_value '||
  --  'group by t2.'||p_child_key_column||')'||
  --  'order by t1.'||p_child_key_column||
  --  ' for update nowait';
  g_dynamic_sql :=
    'SELECT t1.effective_end_date effective_end_date '||
    'FROM '||p_child_table_name||' t1 '||
    'WHERE t1.'||p_parent_key_column||' = :p_parent_key_value '||
    'AND (t1.'||p_child_key_column||',t1.effective_start_date,'||
    't1.effective_end_date) IN '||
    '(SELECT t2.'||p_child_key_column||',MAX(t2.effective_start_date),'||
    'MAX(t2.effective_end_date) FROM '||p_child_table_name||' t2 '||
    'WHERE t2.'||p_child_key_column||' = t1.'||p_child_key_column||
    ' GROUP BY t2.'||p_child_key_column||')'||
    ' FOR UPDATE NOWAIT';
  -- set the dynamic SQL comment for identification
  dt_api.g_dynamic_sql :=
    dt_api.g_dynamic_sql||
    REPLACE(dt_api.g_dynamic_sql_comment,'{proc}','lck_child');
  -- open a cursor
  OPEN l_cursor FOR g_dynamic_sql USING p_parent_key_value;
  -- NOTE: ORACLE VERSION CODE SWITCH
  -- ================================
  -- Oracle 8/8i does not support BULK COLLECT of a dynamic PL/SQL
  -- statement.
  IF g_oracle_db_version >= 9 THEN
    -- Oracle 9+ being used so perform a BULK COLLECT
    FETCH l_cursor BULK COLLECT INTO l_date_tab;
  ELSE
    -- Pre Oracle 9 so fetch each row individually
    l_cnt := 1;
    LOOP
      -- A Pre Oracle 9 DB is being used so LOOP through fetching each row
      FETCH l_cursor INTO l_date_tab(l_cnt);
      EXIT WHEN l_cursor%NOTFOUND;
      l_cnt := l_cnt + 1;
    END LOOP;
  END IF;
  CLOSE l_cursor;
  --
  FOR l_counter IN 1..l_date_tab.COUNT LOOP
    -- For each locked row we must ensure that the maximum end date is NOT
    -- greater than the validation start date
    IF (l_date_tab(l_counter) >= p_validation_start_date) THEN
      -- The maximum end date is greater than or equal to the
      -- validation start date therefore we must error
      hr_utility.set_message(801, 'HR_7201_DT_NO_DELETE_CHILD');
      hr_utility.raise_error;
    END IF;
  END LOOP;
  IF g_debug THEN
    hr_utility.set_location(' Leaving:'||l_proc, 35);
  END IF;
EXCEPTION
  WHEN hr_api.object_locked THEN
    IF l_cursor%ISOPEN THEN
      CLOSE l_cursor;
    END IF;
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', p_child_table_name);
    hr_utility.raise_error;
  WHEN OTHERS THEN
    IF l_cursor%ISOPEN THEN
      CLOSE l_cursor;
    END IF;
    RAISE;
END lck_child;
-- ----------------------------------------------------------------------------
-- |-------------------------< Find_DT_Upd_Modes >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Returns corresponding boolean values for the respective DT
--              update modes.
--
-- ----------------------------------------------------------------------------
PROCEDURE Find_DT_Upd_Modes
          (p_effective_date       IN            DATE,
           p_base_table_name      IN            VARCHAR2,
           p_base_key_column      IN            VARCHAR2,
           p_base_key_value       IN            NUMBER,
           p_correction              OUT NOCOPY BOOLEAN,
           p_update                  OUT NOCOPY BOOLEAN,
           p_update_override         OUT NOCOPY BOOLEAN,
           p_update_change_insert    OUT NOCOPY BOOLEAN) IS
  --
  l_proc                    varchar2(72);
  l_correction_start_date   DATE;
  l_correction_end_date     DATE;
  l_update_start_date       DATE;
  l_update_end_date         DATE;
  l_upd_chg_start_date      DATE;
  l_upd_chg_end_date        DATE;
  l_override_start_date     DATE;
  l_override_end_date       DATE;
  --
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := g_package||'Find_DT_Upd_Modes';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  find_dt_upd_modes_and_dates
   (p_effective_date      => p_effective_date
   ,p_base_table_name     => p_base_table_name
   ,p_base_key_column     => p_base_key_column
   ,p_base_key_value      => p_base_key_value
   ,p_correction          => p_correction
   ,p_update              => p_update
   ,p_update_override     => p_update_override
   ,p_update_change_insert    => p_update_change_insert
   ,p_correction_start_date   => l_correction_start_date
   ,p_correction_end_date     => l_correction_end_date
   ,p_update_start_date       => l_update_start_date
   ,p_update_end_date         => l_update_end_date
   ,p_upd_chg_start_date      => l_upd_chg_start_date
   ,p_upd_chg_end_date        => l_upd_chg_end_date
   ,p_override_start_date     => l_override_start_date
   ,p_override_end_date       => l_override_end_date
  );

  IF g_debug THEN
    Hr_Utility.Set_Location('Leaving :'||l_proc, 20);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- set all OUTs to NULL and RAISE
    p_correction           := NULL;
    p_update               := NULL;
    p_update_override      := NULL;
    p_update_change_insert := NULL;
    RAISE;
END Find_DT_Upd_Modes;
-- ----------------------------------------------------------------------------
-- |-------------------------< Find_DT_Del_Modes >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Returns corresponding boolean values for the respective DT
--              delete modes.
--
-- ----------------------------------------------------------------------------
PROCEDURE Find_DT_Del_Modes
          (p_effective_date      IN         DATE,
           p_base_table_name     IN         VARCHAR2,
           p_base_key_column     IN         VARCHAR2,
           p_base_key_value      IN         NUMBER,
           p_parent_table_name1  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_column1  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_value1   IN         NUMBER   DEFAULT hr_api.g_number,
           p_parent_table_name2  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_column2  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_value2   IN         NUMBER   DEFAULT hr_api.g_number,
           p_parent_table_name3  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_column3  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_value3   IN         NUMBER   DEFAULT hr_api.g_number,
           p_parent_table_name4  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_column4  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_value4   IN         NUMBER   DEFAULT hr_api.g_number,
           p_parent_table_name5  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_column5  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_value5   IN         NUMBER   DEFAULT hr_api.g_number,
           p_parent_table_name6  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_column6  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_value6   IN         NUMBER   DEFAULT hr_api.g_number,
           p_parent_table_name7  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_column7  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_value7   IN         NUMBER   DEFAULT hr_api.g_number,
           p_parent_table_name8  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_column8  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_value8   IN         NUMBER   DEFAULT hr_api.g_number,
           p_parent_table_name9  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_column9  IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_value9   IN         NUMBER   DEFAULT hr_api.g_number,
           p_parent_table_name10 IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_column10 IN         VARCHAR2 DEFAULT hr_api.g_varchar2,
           p_parent_key_value10  IN         NUMBER   DEFAULT hr_api.g_number,
           p_zap                 OUT NOCOPY BOOLEAN,
           p_delete              OUT NOCOPY BOOLEAN,
           p_future_change       OUT NOCOPY BOOLEAN,
           p_delete_next_change  OUT NOCOPY BOOLEAN) IS
  --
  l_proc                        varchar2(72);
  l_zap_start_date              DATE;
  l_zap_end_date                DATE;
  l_delete_start_date           DATE;
  l_delete_end_date             DATE;
  l_del_future_start_date       DATE;
  l_del_future_end_date         DATE;
  l_del_next_start_date         DATE;
  l_del_next_end_date           DATE;
  --
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := g_package||'Find_DT_Del_Modes';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  find_dt_del_modes_and_dates
  (p_effective_date     =>   p_effective_date
  ,p_base_table_name    =>   p_base_table_name
  ,p_base_key_column    =>   p_base_key_column
  ,p_base_key_value     =>   p_base_key_value
  ,p_parent_table_name1 =>   p_parent_table_name1
  ,p_parent_key_column1 =>   p_parent_key_column1
  ,p_parent_key_value1  =>   p_parent_key_value1
  ,p_parent_table_name2 =>   p_parent_table_name2
  ,p_parent_key_column2 =>   p_parent_key_column2
  ,p_parent_key_value2  =>   p_parent_key_value2
  ,p_parent_table_name3 =>   p_parent_table_name3
  ,p_parent_key_column3 =>   p_parent_key_column3
  ,p_parent_key_value3  =>   p_parent_key_value3
  ,p_parent_table_name4 =>   p_parent_table_name4
  ,p_parent_key_column4 =>   p_parent_key_column4
  ,p_parent_key_value4  =>   p_parent_key_value4
  ,p_parent_table_name5 =>   p_parent_table_name5
  ,p_parent_key_column5 =>   p_parent_key_column5
  ,p_parent_key_value5  =>   p_parent_key_value5
  ,p_parent_table_name6 =>   p_parent_table_name6
  ,p_parent_key_column6 =>   p_parent_key_column6
  ,p_parent_key_value6  =>   p_parent_key_value6
  ,p_parent_table_name7 =>   p_parent_table_name7
  ,p_parent_key_column7 =>   p_parent_key_column7
  ,p_parent_key_value7  =>   p_parent_key_value7
  ,p_parent_table_name8 =>   p_parent_table_name8
  ,p_parent_key_column8 =>   p_parent_key_column8
  ,p_parent_key_value8  =>   p_parent_key_value8
  ,p_parent_table_name9 =>   p_parent_table_name9
  ,p_parent_key_column9 =>   p_parent_key_column9
  ,p_parent_key_value9  =>   p_parent_key_value9
  ,p_parent_table_name10 =>  p_parent_table_name10
  ,p_parent_key_column10 =>  p_parent_key_column10
  ,p_parent_key_value10  =>  p_parent_key_value10
  ,p_zap                 =>  p_zap
  ,p_delete              =>  p_delete
  ,p_future_change       =>  p_future_change
  ,p_delete_next_change  =>  p_delete_next_change
  ,p_zap_start_date      =>  l_zap_start_date
  ,p_zap_end_date        =>  l_zap_end_date
  ,p_delete_start_date   =>  l_delete_start_date
  ,p_delete_end_date     =>  l_delete_end_date
  ,p_del_future_start_date   =>  l_del_future_start_date
  ,p_del_future_end_date     =>  l_del_future_end_date
  ,p_del_next_start_date  =>  l_del_next_start_date
  ,p_del_next_end_date    =>  l_del_next_end_date
  );

  IF g_debug THEN
    Hr_Utility.Set_Location('Leaving :'||l_proc, 25);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    p_zap                := NULL;
    p_delete             := NULL;
    p_future_change      := NULL;
    p_delete_next_change := NULL;
    RAISE;
END Find_Dt_Del_Modes;
-- ----------------------------------------------------------------------------
-- |-------------------------< Get_Insert_Dates >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Locks and parental entity rows (if supplied) and Returns
--              the validation start and end dates for the DateTrack
--              INSERT mode
--
-- ----------------------------------------------------------------------------
PROCEDURE Get_Insert_Dates
          (p_effective_date          IN   DATE,
           p_base_table_name         IN   VARCHAR2,
           p_base_key_column         IN   VARCHAR2,
           p_base_key_value          IN   NUMBER,
           p_parent_table_name1      IN   VARCHAR2,
           p_parent_key_column1      IN   VARCHAR2,
           p_parent_key_value1       IN   NUMBER,
           p_parent_table_name2      IN   VARCHAR2,
           p_parent_key_column2      IN   VARCHAR2,
           p_parent_key_value2       IN   NUMBER,
           p_parent_table_name3      IN   VARCHAR2,
           p_parent_key_column3      IN   VARCHAR2,
           p_parent_key_value3       IN   NUMBER,
           p_parent_table_name4      IN   VARCHAR2,
           p_parent_key_column4      IN   VARCHAR2,
           p_parent_key_value4       IN   NUMBER,
           p_parent_table_name5      IN   VARCHAR2,
           p_parent_key_column5      IN   VARCHAR2,
           p_parent_key_value5       IN   NUMBER,
           p_parent_table_name6      IN   VARCHAR2,
           p_parent_key_column6      IN   VARCHAR2,
           p_parent_key_value6       IN   NUMBER,
           p_parent_table_name7      IN   VARCHAR2,
           p_parent_key_column7      IN   VARCHAR2,
           p_parent_key_value7       IN   NUMBER,
           p_parent_table_name8      IN   VARCHAR2,
           p_parent_key_column8      IN   VARCHAR2,
           p_parent_key_value8       IN   NUMBER,
           p_parent_table_name9      IN   VARCHAR2,
           p_parent_key_column9      IN   VARCHAR2,
           p_parent_key_value9       IN   NUMBER,
           p_parent_table_name10     IN   VARCHAR2,
           p_parent_key_column10     IN   VARCHAR2,
           p_parent_key_value10      IN   NUMBER,
           p_enforce_foreign_locking IN   BOOLEAN,
           p_validation_start_date   OUT  NOCOPY DATE,
           p_validation_end_date     OUT  NOCOPY DATE) IS
--
  l_proc VARCHAR2(72);
--
BEGIN
  IF g_debug THEN
    l_proc := g_package||'Get_Insert_Dates';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- set the returning validation start and end dates
  p_validation_start_date := p_effective_date;
  p_validation_end_date   :=
    return_parent_min_date
      (p_effective_date => p_effective_date,
       p_lock_rows    => p_enforce_foreign_locking,
       p_table_name1  => p_parent_table_name1,
       p_key_column1  => p_parent_key_column1,
       p_key_value1   => p_parent_key_value1,
       p_table_name2  => p_parent_table_name2,
       p_key_column2  => p_parent_key_column2,
       p_key_value2   => p_parent_key_value2,
       p_table_name3  => p_parent_table_name3,
       p_key_column3  => p_parent_key_column3,
       p_key_value3   => p_parent_key_value3,
       p_table_name4  => p_parent_table_name4,
       p_key_column4  => p_parent_key_column4,
       p_key_value4   => p_parent_key_value4,
       p_table_name5  => p_parent_table_name5,
       p_key_column5  => p_parent_key_column5,
       p_key_value5   => p_parent_key_value5,
       p_table_name6  => p_parent_table_name6,
       p_key_column6  => p_parent_key_column6,
       p_key_value6   => p_parent_key_value6,
       p_table_name7  => p_parent_table_name7,
       p_key_column7  => p_parent_key_column7,
       p_key_value7   => p_parent_key_value7,
       p_table_name8  => p_parent_table_name8,
       p_key_column8  => p_parent_key_column8,
       p_key_value8   => p_parent_key_value8,
       p_table_name9  => p_parent_table_name9,
       p_key_column9  => p_parent_key_column9,
       p_key_value9   => p_parent_key_value9,
       p_table_name10 => p_parent_table_name10,
       p_key_column10 => p_parent_key_column10,
       p_key_value10  => p_parent_key_value10);
  IF g_debug THEN
    Hr_Utility.Set_Location('Leaving :'||l_proc, 20);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- reset the OUT params to NULL to cater for NOCOPY
    p_validation_start_date := NULL;
    p_validation_end_date := NULL;
    RAISE;
END Get_Insert_Dates;
-- ----------------------------------------------------------------------------
-- |-----------------------< Get_Correction_Dates >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack CORRECTION mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE Get_Correction_Dates
         (p_effective_date        IN     DATE,
          p_base_table_name       IN     VARCHAR2,
          p_base_key_column       IN     VARCHAR2,
          p_base_key_value        IN     NUMBER,
          p_validation_start_date    OUT NOCOPY DATE,
          p_validation_end_date      OUT NOCOPY DATE) IS
  --
  l_proc VARCHAR2(72);
  --
BEGIN
  IF g_debug THEN
    l_proc := g_package||'Get_Correction_Dates';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- Define dynamic sql text with substitution tokens
  g_dynamic_sql :=
    'SELECT t.effective_start_date,t.effective_end_date '||
    'FROM '||LOWER(p_base_table_name)||' t '||
    'WHERE t.'||LOWER(p_base_key_column)||' = :p_base_key_value '||
    'AND :p_effective_date '||
    'BETWEEN t.effective_start_date AND t.effective_end_date';
  -- set the dynamic SQL comment for identification
  dt_api.g_dynamic_sql :=
    dt_api.g_dynamic_sql||
    REPLACE(dt_api.g_dynamic_sql_comment,'{proc}','get_correction_dates');
  -- native dynamic PL/SQL call placing result directly into
  -- OUT params
  EXECUTE IMMEDIATE g_dynamic_sql
  INTO    p_validation_start_date
         ,p_validation_end_date
  USING   p_base_key_value
         ,p_effective_date;
  IF g_debug THEN
    hr_utility.set_location('Leaving :'||l_proc, 10);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- reset the OUT params to NULL to cater for NOCOPY
    p_validation_start_date := NULL;
    p_validation_end_date := NULL;
    -- As no rows were returned we must error
    hr_utility.set_message(801, 'HR_7180_DT_NO_ROW_EXIST');
    hr_utility.set_message_token('TABLE_NAME', p_base_table_name);
    hr_utility.set_message_token
      ('SESSION_DATE'
      ,fnd_date.date_to_chardate(p_effective_date)
      );
    hr_utility.raise_error;
  WHEN TOO_MANY_ROWS THEN
    -- reset the OUT params to NULL to cater for NOCOPY
    p_validation_start_date := NULL;
    p_validation_end_date := NULL;
    hr_utility.set_message(801, 'HR_7181_DT_OVERLAP_ROWS');
    hr_utility.set_message_token('TABLE_NAME', p_base_table_name);
    hr_utility.set_message_token
      ('SESSION_DATE'
      ,fnd_date.date_to_chardate(p_effective_date)
      );
    hr_utility.set_message_token('PRIMARY_VALUE', to_char(p_base_key_value));
    hr_utility.raise_error;
  WHEN OTHERS THEN
    -- reset the OUT params to NULL to cater for NOCOPY
    p_validation_start_date := NULL;
    p_validation_end_date := NULL;
    RAISE;
END Get_Correction_Dates;
-- ----------------------------------------------------------------------------
-- |--------------------------< Get_Update_Dates >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack UPDATE mode if allowed.
--
-- ----------------------------------------------------------------------------
PROCEDURE Get_Update_Dates
         (p_effective_date         IN  DATE,
          p_base_table_name        IN  VARCHAR2,
          p_base_key_column        IN  VARCHAR2,
          p_base_key_value         IN  NUMBER,
          p_validation_start_date  OUT NOCOPY DATE,
          p_validation_end_date    OUT NOCOPY DATE) IS
  --
  l_proc                  VARCHAR2(72);
  l_effective_rows        g_dt_effective_rows_tab;
  l_date_from_row_idx     BINARY_INTEGER;
  --
BEGIN
  IF g_debug THEN
    l_proc := g_package||'Get_Update_Dates';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- get the effective rows
  get_effective_rows
    (p_date_from         => p_effective_date,
     p_base_table_name   => p_base_table_name,
     p_base_key_column   => p_base_key_column,
     p_base_key_value    => p_base_key_value,
     p_lock_rows         => FALSE,
     p_date_from_valid   => TRUE,
     p_effective_rows    => l_effective_rows,
     p_date_from_row_idx => l_date_from_row_idx);
  -- check to ensure that no future rows exist
  IF l_effective_rows.COUNT > l_date_from_row_idx THEN
    -- future rows exist so error
    hr_utility.set_message(801, 'HR_7211_DT_UPD_ROWS_IN_FUTURE');
    hr_utility.raise_error;
  ELSE
    -- future rows do no exist
    -- providing the current effective start date is not equal to the effective
    -- date we must return the the validation start and end dates
    IF (l_effective_rows(l_date_from_row_idx).effective_start_date <>
        p_effective_date) THEN
      p_validation_start_date := p_effective_date;
      p_validation_end_date   :=
        l_effective_rows(l_date_from_row_idx).effective_end_date;
    ELSE
      -- we cannot perform a DateTrack update operation where the effective
      -- date is the same as the current effective end date
      hr_utility.set_message(801, 'HR_7179_DT_UPD_NOT_ALLOWED');
      hr_utility.raise_error;
    END IF;
  END IF;
  IF g_debug THEN
    Hr_Utility.Set_Location('Leaving :'||l_proc, 10);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- reset the OUT params to NULL to cater for NOCOPY
    p_validation_start_date := NULL;
    p_validation_end_date := NULL;
    RAISE;
END Get_Update_Dates;
-- ----------------------------------------------------------------------------
-- |-------------------< Get_Update_Override_Dates >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack UPDATE_OVERRIDE mode if allowed.
--
-- ----------------------------------------------------------------------------
PROCEDURE Get_Update_Override_Dates
         (p_effective_date         IN  DATE,
          p_base_table_name        IN  VARCHAR2,
          p_base_key_column        IN  VARCHAR2,
          p_base_key_value         IN  NUMBER,
          p_validation_start_date  OUT NOCOPY DATE,
          p_validation_end_date    OUT NOCOPY DATE) IS
  --
  l_proc               VARCHAR2(72);
  l_effective_rows     g_dt_effective_rows_tab;
  l_date_from_row_idx  BINARY_INTEGER;
  --
Begin
  IF g_debug THEN
    l_proc := g_package||'Get_Update_Override_Dates';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- get and lock the effective rows
  get_effective_rows
    (p_date_from         => p_effective_date,
     p_base_table_name   => p_base_table_name,
     p_base_key_column   => p_base_key_column,
     p_base_key_value    => p_base_key_value,
     p_lock_rows         => TRUE,
     p_date_from_valid   => TRUE,
     p_effective_rows    => l_effective_rows,
     p_date_from_row_idx => l_date_from_row_idx);
  -- if the current effective start date is not the same as the effective date
  -- and at least one future row exists then we must return the validation
  -- start and end dates
  IF (l_effective_rows(l_date_from_row_idx).effective_start_date <>
      p_effective_date) THEN
    -- as the current row does not start on the effective date we determine if
    -- any future rows exist
    IF l_effective_rows.COUNT > l_date_from_row_idx THEN
      p_validation_start_date := p_effective_date;
      p_validation_end_date   :=
        l_effective_rows(l_effective_rows.LAST).effective_end_date;
    ELSE
      hr_utility.set_message(801, 'HR_7183_DT_NO_FUTURE_ROWS');
      hr_utility.set_message_token('DT_MODE', 'update override');
      hr_utility.raise_error;
    END IF;
  ELSE
    hr_utility.set_message(801, 'HR_7179_DT_UPD_NOT_ALLOWED');
    hr_utility.raise_error;
  END IF;
  IF g_debug THEN
    Hr_Utility.Set_Location('Leaving :'||l_proc, 20);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- reset the OUT params to NULL to cater for NOCOPY
    p_validation_start_date := NULL;
    p_validation_end_date := NULL;
    RAISE;
END Get_Update_Override_Dates;
-- ----------------------------------------------------------------------------
-- |-----------------< Get_Update_Change_Insert_Dates >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack UPDATE_CHANGE_INSERT mode if allowed.
--
-- ----------------------------------------------------------------------------
PROCEDURE Get_Update_Change_Insert_Dates
         (p_effective_date         IN  DATE,
          p_base_table_name        IN  VARCHAR2,
          p_base_key_column        IN  VARCHAR2,
          p_base_key_value         IN  NUMBER,
          p_validation_start_date  OUT NOCOPY DATE,
          p_validation_end_date    OUT NOCOPY DATE) IS
  --
  l_proc                  VARCHAR2(72);
  l_effective_rows        g_dt_effective_rows_tab;
  l_date_from_row_idx     BINARY_INTEGER;
  --
BEGIN
  IF g_debug THEN
    l_proc := g_package||'Get_Update_Change_Insert_Dates';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- get the effective rows
  get_effective_rows
    (p_date_from         => p_effective_date,
     p_base_table_name   => p_base_table_name,
     p_base_key_column   => p_base_key_column,
     p_base_key_value    => p_base_key_value,
     p_lock_rows         => FALSE,
     p_date_from_valid   => TRUE,
     p_effective_rows    => l_effective_rows,
     p_date_from_row_idx => l_date_from_row_idx);
  -- if the current effective start date is not the same as the effective date
  -- and at least one future row exists then we must return the validation
  -- start and end dates
  IF (l_effective_rows(l_date_from_row_idx).effective_start_date <>
      p_effective_date) THEN
    -- as the current row does not start on the effective date we determine if
    -- any future rows exist
    IF l_effective_rows.COUNT > l_date_from_row_idx THEN
      p_validation_start_date := p_effective_date;
      p_validation_end_date   :=
        l_effective_rows(l_date_from_row_idx).effective_end_date;
    ELSE
      hr_utility.set_message(801, 'HR_7183_DT_NO_FUTURE_ROWS');
      hr_utility.set_message_token('DT_MODE', 'update change insert');
      hr_utility.raise_error;
    END IF;
  ELSE
    hr_utility.set_message(801, 'HR_7179_DT_UPD_NOT_ALLOWED');
    hr_utility.raise_error;
  END IF;
  IF g_debug THEN
    Hr_Utility.Set_Location('Leaving :'||l_proc, 20);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- reset the OUT params to NULL to cater for NOCOPY
    p_validation_start_date := NULL;
    p_validation_end_date := NULL;
    RAISE;
END Get_Update_Change_Insert_Dates;
-- ----------------------------------------------------------------------------
-- |----------------------------< Get_Zap_Dates >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack ZAP mode.
--
-- ----------------------------------------------------------------------------
Procedure Get_Zap_Dates
         (p_effective_date        IN  DATE,
          p_base_table_name       IN  VARCHAR2,
          p_base_key_column       IN  VARCHAR2,
          p_base_key_value        IN  NUMBER,
          p_validation_start_date OUT NOCOPY DATE,
          p_validation_end_date   OUT NOCOPY DATE) IS
--
  l_proc                  VARCHAR2(72);
  l_effective_rows        g_dt_effective_rows_tab;
  l_date_from_row_idx     BINARY_INTEGER;
--
BEGIN
  IF g_debug THEN
    l_proc := g_package||'Get_Zap_Dates';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- get and lock the effective rows from the start of time
  get_effective_rows
    (p_date_from         => dt_api.g_sot,
     p_base_table_name   => p_base_table_name,
     p_base_key_column   => p_base_key_column,
     p_base_key_value    => p_base_key_value,
     p_lock_rows         => TRUE,
     p_date_from_valid   => FALSE,
     p_effective_rows    => l_effective_rows,
     p_date_from_row_idx => l_date_from_row_idx);
  -- at least one row will exist otherwise the get_effective_rows would of
  -- raised an error therefore just set the p_validation_start_date and
  -- p_validation_end_date OUT parameters
  p_validation_start_date :=
    l_effective_rows(l_effective_rows.FIRST).effective_start_date;
  p_validation_end_date :=
    l_effective_rows(l_effective_rows.LAST).effective_end_date;
  IF g_debug THEN
    Hr_Utility.Set_Location('Leaving :'||l_proc, 20);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- reset the OUT params to NULL to cater for NOCOPY
    p_validation_start_date := NULL;
    p_validation_end_date := NULL;
    RAISE;
END Get_Zap_Dates;
-- ----------------------------------------------------------------------------
-- |--------------------------< Get_Delete_Dates >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack DELETE mode if allowed.
--
-- ----------------------------------------------------------------------------
PROCEDURE Get_Delete_Dates
         (p_effective_date              IN  DATE,
          p_base_table_name             IN  VARCHAR2,
          p_base_key_column             IN  VARCHAR2,
          p_base_key_value              IN  NUMBER,
          p_child_table_name1           IN  VARCHAR2,
          p_child_key_column1           IN  VARCHAR2,
          p_child_table_name2           IN  VARCHAR2,
          p_child_key_column2           IN  VARCHAR2,
          p_child_table_name3           IN  VARCHAR2,
          p_child_key_column3           IN  VARCHAR2,
          p_child_table_name4           IN  VARCHAR2,
          p_child_key_column4           IN  VARCHAR2,
          p_child_table_name5           IN  VARCHAR2,
          p_child_key_column5           IN  VARCHAR2,
          p_child_table_name6           IN  VARCHAR2,
          p_child_key_column6           IN  VARCHAR2,
          p_child_table_name7           IN  VARCHAR2,
          p_child_key_column7           IN  VARCHAR2,
          p_child_table_name8           IN  VARCHAR2,
          p_child_key_column8           IN  VARCHAR2,
          p_child_table_name9           IN  VARCHAR2,
          p_child_key_column9           IN  VARCHAR2,
          p_child_table_name10          IN  VARCHAR2,
          p_child_key_column10          IN  VARCHAR2,
          p_child_alt_base_key_column1  IN  VARCHAR2,
          p_child_alt_base_key_column2  IN  VARCHAR2,
          p_child_alt_base_key_column3  IN  VARCHAR2,
          p_child_alt_base_key_column4  IN  VARCHAR2,
          p_child_alt_base_key_column5  IN  VARCHAR2,
          p_child_alt_base_key_column6  IN  VARCHAR2,
          p_child_alt_base_key_column7  IN  VARCHAR2,
          p_child_alt_base_key_column8  IN  VARCHAR2,
          p_child_alt_base_key_column9  IN  VARCHAR2,
          p_child_alt_base_key_column10 IN  VARCHAR2,
          p_enforce_foreign_locking     IN  BOOLEAN,
          p_validation_start_date       OUT NOCOPY DATE,
          p_validation_end_date         OUT NOCOPY DATE) IS
  --
  l_proc                      VARCHAR2(72);
  l_effective_date_plus_one   CONSTANT DATE := p_effective_date + 1;
  l_child_table_name          VARCHAR2(30);
  l_child_key_column          VARCHAR2(30);
  l_child_alt_base_key_column VARCHAR2(30);
  l_effective_rows            g_dt_effective_rows_tab;
  l_date_from_row_idx         BINARY_INTEGER;
  --
BEGIN
  IF g_debug THEN
    l_proc := g_package||'Get_Delete_Dates';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- get and lock the effective rows
  get_effective_rows
    (p_date_from         => p_effective_date,
     p_base_table_name   => p_base_table_name,
     p_base_key_column   => p_base_key_column,
     p_base_key_value    => p_base_key_value,
     p_lock_rows         => TRUE,
     p_date_from_valid   => TRUE,
     p_effective_rows    => l_effective_rows,
     p_date_from_row_idx => l_date_from_row_idx);
  -- lock child records if p_enforce_foreign_locking is specified
  IF p_enforce_foreign_locking THEN
    FOR l_counter IN 1..10 LOOP
      -- Set the current working arguments to the corresponding functional
      -- argument values
      If    (l_counter = 1) THEN
        l_child_table_name := p_child_table_name1;
        l_child_key_column := p_child_key_column1;
        l_child_alt_base_key_column := p_child_alt_base_key_column1;
      ELSIF (l_counter = 2) THEN
        l_child_table_name := p_child_table_name2;
        l_child_key_column := p_child_key_column2;
        l_child_alt_base_key_column := p_child_alt_base_key_column2;
      ELSIF (l_counter = 3) THEN
        l_child_table_name := p_child_table_name3;
        l_child_key_column := p_child_key_column3;
        l_child_alt_base_key_column := p_child_alt_base_key_column3;
      ELSIF (l_counter = 4) THEN
        l_child_table_name := p_child_table_name4;
        l_child_key_column := p_child_key_column4;
        l_child_alt_base_key_column := p_child_alt_base_key_column4;
      ELSIF (l_counter = 5) THEN
        l_child_table_name := p_child_table_name5;
        l_child_key_column := p_child_key_column5;
        l_child_alt_base_key_column := p_child_alt_base_key_column5;
      ELSIF (l_counter = 6) THEN
        l_child_table_name := p_child_table_name6;
        l_child_key_column := p_child_key_column6;
        l_child_alt_base_key_column := p_child_alt_base_key_column6;
      ELSIF (l_counter = 7) THEN
        l_child_table_name := p_child_table_name7;
        l_child_key_column := p_child_key_column7;
        l_child_alt_base_key_column := p_child_alt_base_key_column7;
      ELSIF (l_counter = 8) THEN
        l_child_table_name := p_child_table_name8;
        l_child_key_column := p_child_key_column8;
        l_child_alt_base_key_column := p_child_alt_base_key_column8;
      ELSIF (l_counter = 9) THEN
        l_child_table_name := p_child_table_name9;
        l_child_key_column := p_child_key_column9;
        l_child_alt_base_key_column := p_child_alt_base_key_column9;
      ELSE
        l_child_table_name := p_child_table_name10;
        l_child_key_column := p_child_key_column10;
        l_child_alt_base_key_column := p_child_alt_base_key_column10;
      END IF;
      -- ensure that all the working child details have been specified
      IF ((p_base_key_value IS NOT NULL) AND NOT
         ((NVL(l_child_table_name, dt_api.g_varchar2) =
               dt_api.g_varchar2) OR
              (NVL(l_child_key_column, dt_api.g_varchar2) =
               dt_api.g_varchar2))) THEN
        -- all the child arguments have been specified therefore we must lock
        -- the child rows (if they exist).
        Lck_Child
          (p_child_table_name      => LOWER(l_child_table_name),
           p_child_key_column      => LOWER(l_child_key_column),
           p_parent_key_column     => NVL(LOWER(l_child_alt_base_key_column),
                                          LOWER(p_base_key_column)),
           p_parent_key_value      => p_base_key_value,
           p_validation_start_date => l_effective_date_plus_one);
      END IF;
    END LOOP;
  END IF;
  -- Providing the maximum effective end date is not the same as the current
  -- effective date then we must return the validation start and end dates.
  -- However, if you attempt to do a datetrack delete where the session date is
  -- the same as your maximum date then we must error.
  IF (p_effective_date <>
      l_effective_rows(l_effective_rows.LAST).effective_end_date) THEN
    p_validation_start_date := l_effective_date_plus_one;
    p_validation_end_date   :=
      l_effective_rows(l_effective_rows.LAST).effective_end_date;
  ELSE
    -- We cannot perform a DateTrack delete operation where the effective date
    -- is the same as the maximum effective end date.
    hr_utility.set_message(801, 'HR_7185_DT_DEL_NOT_ALLOWED');
    hr_utility.raise_error;
  END IF;
  IF g_debug THEN
    Hr_Utility.Set_Location('Leaving :'||l_proc, 10);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- reset the OUT params to NULL to cater for NOCOPY
    p_validation_start_date := NULL;
    p_validation_end_date := NULL;
    RAISE;
END Get_Delete_Dates;
-- ----------------------------------------------------------------------------
-- |-----------------------< Get_Future_Change_Dates >------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack FUTURE_CHANGE mode if allowed.
--
-- ----------------------------------------------------------------------------
PROCEDURE Get_Future_Change_Dates
         (p_effective_date        IN  DATE,
          p_base_table_name       IN  VARCHAR2,
          p_base_key_column       IN  VARCHAR2,
          p_base_key_value        IN  NUMBER,
          p_parent_table_name1    IN  VARCHAR2,
          p_parent_key_column1    IN  VARCHAR2,
          p_parent_key_value1     IN  NUMBER,
          p_parent_table_name2    IN  VARCHAR2,
          p_parent_key_column2    IN  VARCHAR2,
          p_parent_key_value2     IN  NUMBER,
          p_parent_table_name3    IN  VARCHAR2,
          p_parent_key_column3    IN  VARCHAR2,
          p_parent_key_value3     IN  NUMBER,
          p_parent_table_name4    IN  VARCHAR2,
          p_parent_key_column4    IN  VARCHAR2,
          p_parent_key_value4     IN  NUMBER,
          p_parent_table_name5    IN  VARCHAR2,
          p_parent_key_column5    IN  VARCHAR2,
          p_parent_key_value5     IN  NUMBER,
          p_parent_table_name6    IN  VARCHAR2,
          p_parent_key_column6    IN  VARCHAR2,
          p_parent_key_value6     IN  NUMBER,
          p_parent_table_name7    IN  VARCHAR2,
          p_parent_key_column7    IN  VARCHAR2,
          p_parent_key_value7     IN  NUMBER,
          p_parent_table_name8    IN  VARCHAR2,
          p_parent_key_column8    IN  VARCHAR2,
          p_parent_key_value8     IN  NUMBER,
          p_parent_table_name9    IN  VARCHAR2,
          p_parent_key_column9    IN  VARCHAR2,
          p_parent_key_value9     IN  NUMBER,
          p_parent_table_name10   IN  VARCHAR2,
          p_parent_key_column10   IN  VARCHAR2,
          p_parent_key_value10    IN  NUMBER,
          p_validation_start_date OUT NOCOPY DATE,
          p_validation_end_date   OUT NOCOPY DATE) IS
  --
  l_proc                  VARCHAR2(72);
  l_validation_end_date   DATE;
  l_effective_rows        g_dt_effective_rows_tab;
  l_date_from_row_idx     BINARY_INTEGER;
  --
BEGIN
  IF g_debug THEN
    l_proc := g_package||'Get_Future_Change_Dates';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- get and lock the effective rows
  get_effective_rows
    (p_date_from         => p_effective_date,
     p_base_table_name   => p_base_table_name,
     p_base_key_column   => p_base_key_column,
     p_base_key_value    => p_base_key_value,
     p_lock_rows         => TRUE,
     p_date_from_valid   => TRUE,
     p_effective_rows    => l_effective_rows,
     p_date_from_row_idx => l_date_from_row_idx);
  -- Providing the current effective end date is not the end of time
  -- then we must set the validation dates
  IF (l_effective_rows(l_date_from_row_idx).effective_end_date <>
      dt_api.g_eot) THEN
    -- get the parent min end date
    l_validation_end_date :=
      return_parent_min_date
        (p_effective_date => p_effective_date,
         p_lock_rows    => FALSE,
         p_table_name1  => p_parent_table_name1,
         p_key_column1  => p_parent_key_column1,
         p_key_value1   => p_parent_key_value1,
         p_table_name2  => p_parent_table_name2,
         p_key_column2  => p_parent_key_column2,
         p_key_value2   => p_parent_key_value2,
         p_table_name3  => p_parent_table_name3,
         p_key_column3  => p_parent_key_column3,
         p_key_value3   => p_parent_key_value3,
         p_table_name4  => p_parent_table_name4,
         p_key_column4  => p_parent_key_column4,
         p_key_value4   => p_parent_key_value4,
         p_table_name5  => p_parent_table_name5,
         p_key_column5  => p_parent_key_column5,
         p_key_value5   => p_parent_key_value5,
         p_table_name6  => p_parent_table_name6,
         p_key_column6  => p_parent_key_column6,
         p_key_value6   => p_parent_key_value6,
         p_table_name7  => p_parent_table_name7,
         p_key_column7  => p_parent_key_column7,
         p_key_value7   => p_parent_key_value7,
         p_table_name8  => p_parent_table_name8,
         p_key_column8  => p_parent_key_column8,
         p_key_value8   => p_parent_key_value8,
         p_table_name9  => p_parent_table_name9,
         p_key_column9  => p_parent_key_column9,
         p_key_value9   => p_parent_key_value9,
         p_table_name10 => p_parent_table_name10,
         p_key_column10 => p_parent_key_column10,
         p_key_value10  => p_parent_key_value10);
    -- If the validation end date is set to the current effective end date
    -- then we must error as we cannot extend the end date of the current
    -- row
    IF (l_validation_end_date <=
        l_effective_rows(l_date_from_row_idx).effective_end_date) THEN
      hr_utility.set_message(801, 'HR_7187_DT_CANNOT_EXTEND_END');
      hr_utility.set_message_token('DT_MODE', ' future changes');
      hr_utility.raise_error;
    ELSE
      -- set the validation_start/end_date OUT params
      p_validation_start_date :=
        l_effective_rows(l_date_from_row_idx).effective_end_date + 1;
      p_validation_end_date := l_validation_end_date;
    END IF;
  ELSE
    -- The current effective end date is alreay the end of time therefore
    -- we cannot extend the end date
    hr_utility.set_message(801, 'HR_7188_DT_DATE_IS_EOT');
    hr_utility.raise_error;
  END IF;
  IF g_debug THEN
    Hr_Utility.Set_Location(' Leaving:'||l_proc, 15);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- reset the OUT params to NULL to cater for NOCOPY
    p_validation_start_date := NULL;
    p_validation_end_date := NULL;
    RAISE;
END Get_Future_Change_Dates;
-- ----------------------------------------------------------------------------
-- |--------------------< Get_Delete_Next_Change_Dates >----------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack FUTURE_CHANGE mode if allowed.
--
-- ----------------------------------------------------------------------------
PROCEDURE Get_Delete_Next_Change_Dates
         (p_effective_date        IN  DATE,
          p_base_table_name       IN  VARCHAR2,
          p_base_key_column       IN  VARCHAR2,
          p_base_key_value        IN  NUMBER,
          p_parent_table_name1    IN  VARCHAR2,
          p_parent_key_column1    IN  VARCHAR2,
          p_parent_key_value1     IN  NUMBER,
          p_parent_table_name2    IN  VARCHAR2,
          p_parent_key_column2    IN  VARCHAR2,
          p_parent_key_value2     IN  NUMBER,
          p_parent_table_name3    IN  VARCHAR2,
          p_parent_key_column3    IN  VARCHAR2,
          p_parent_key_value3     IN  NUMBER,
          p_parent_table_name4    IN  VARCHAR2,
          p_parent_key_column4    IN  VARCHAR2,
          p_parent_key_value4     IN  NUMBER,
          p_parent_table_name5    IN  VARCHAR2,
          p_parent_key_column5    IN  VARCHAR2,
          p_parent_key_value5     IN  NUMBER,
          p_parent_table_name6    IN  VARCHAR2,
          p_parent_key_column6    IN  VARCHAR2,
          p_parent_key_value6     IN  NUMBER,
          p_parent_table_name7    IN  VARCHAR2,
          p_parent_key_column7    IN  VARCHAR2,
          p_parent_key_value7     IN  NUMBER,
          p_parent_table_name8    IN  VARCHAR2,
          p_parent_key_column8    IN  VARCHAR2,
          p_parent_key_value8     IN  NUMBER,
          p_parent_table_name9    IN  VARCHAR2,
          p_parent_key_column9    IN  VARCHAR2,
          p_parent_key_value9     IN  NUMBER,
          p_parent_table_name10   IN  VARCHAR2,
          p_parent_key_column10   IN  VARCHAR2,
          p_parent_key_value10    IN  NUMBER,
          p_validation_start_date OUT NOCOPY DATE,
          p_validation_end_date   OUT NOCOPY DATE) IS
--
  l_proc                        VARCHAR2(72);
  l_validation_end_date         DATE;
  l_future_effective_end_date   DATE;   -- Holds the end date of next row
  l_effective_rows              g_dt_effective_rows_tab;
  l_date_from_row_idx           BINARY_INTEGER;
  --
Begin
  IF g_debug THEN
    l_proc := g_package||'Get_Delete_Next_Change_Dates';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- get and lock the effective rows
  get_effective_rows
    (p_date_from         => p_effective_date,
     p_base_table_name   => p_base_table_name,
     p_base_key_column   => p_base_key_column,
     p_base_key_value    => p_base_key_value,
     p_lock_rows         => TRUE,
     p_date_from_valid   => TRUE,
     p_effective_rows    => l_effective_rows,
     p_date_from_row_idx => l_date_from_row_idx);
  -- Providing the current effective end date is not the end of time
  -- then we must set the validation dates
  IF (l_effective_rows(l_date_from_row_idx).effective_end_date <>
      dt_api.g_eot) THEN
    -- check to see if future rows exist
    IF l_effective_rows.COUNT > l_date_from_row_idx THEN
      -- future rows exist so set the future effective end date
      -- to the end date of the next datetrack row after the row for the
      -- effective date
      l_future_effective_end_date :=
        l_effective_rows(l_date_from_row_idx + 1).effective_end_date;
    ELSE
      -- although the date should be NULL because it has not been set we'll set
      -- it anyway for readability and defensive style coding
      l_future_effective_end_date := NULL;
    END IF;
    -- To determine the validation end date we must take the minimum date
    -- from the following three possible dates:
    -- 1: Minimum parent entity entity end date
    -- 2: If future rows exist then the effective end date of the next row
    -- 3: If no future rows exist then the end of time
    l_validation_end_date :=
      LEAST
      (return_parent_min_date
        (p_effective_date => p_effective_date,
         p_lock_rows    => FALSE,
         p_table_name1  => p_parent_table_name1,
         p_key_column1  => p_parent_key_column1,
         p_key_value1   => p_parent_key_value1,
         p_table_name2  => p_parent_table_name2,
         p_key_column2  => p_parent_key_column2,
         p_key_value2   => p_parent_key_value2,
         p_table_name3  => p_parent_table_name3,
         p_key_column3  => p_parent_key_column3,
         p_key_value3   => p_parent_key_value3,
         p_table_name4  => p_parent_table_name4,
         p_key_column4  => p_parent_key_column4,
         p_key_value4   => p_parent_key_value4,
         p_table_name5  => p_parent_table_name5,
         p_key_column5  => p_parent_key_column5,
         p_key_value5   => p_parent_key_value5,
         p_table_name6  => p_parent_table_name6,
         p_key_column6  => p_parent_key_column6,
         p_key_value6   => p_parent_key_value6,
         p_table_name7  => p_parent_table_name7,
         p_key_column7  => p_parent_key_column7,
         p_key_value7   => p_parent_key_value7,
         p_table_name8  => p_parent_table_name8,
         p_key_column8  => p_parent_key_column8,
         p_key_value8   => p_parent_key_value8,
         p_table_name9  => p_parent_table_name9,
         p_key_column9  => p_parent_key_column9,
         p_key_value9   => p_parent_key_value9,
         p_table_name10 => p_parent_table_name10,
         p_key_column10 => p_parent_key_column10,
         p_key_value10  => p_parent_key_value10),
      NVL(l_future_effective_end_date,dt_api.g_eot));
    -- if the validation end date is set to the current effective end date
    -- then we must error as we cannot extend the end date of the current
    -- row
    IF (l_validation_end_date <=
        l_effective_rows(l_date_from_row_idx).effective_end_date) THEN
      hr_utility.set_message(801, 'HR_7187_DT_CANNOT_EXTEND_END');
      hr_utility.set_message_token('DT_MODE', ' delete next change');
      hr_utility.raise_error;
    ELSE
      -- set the OUT validation params
      -- set the validation start date to the current effective end date + 1
      p_validation_start_date :=
        l_effective_rows(l_date_from_row_idx).effective_end_date + 1;
      p_validation_end_date := l_validation_end_date;
    END IF;
  ELSE
    -- the current effective end date is alreay the end of time therefore
    -- we cannot extend the end date
    hr_utility.set_message(801, 'HR_7188_DT_DATE_IS_EOT');
    hr_utility.raise_error;
  END IF;
  IF g_debug THEN
    Hr_Utility.Set_Location(' Leaving:'||l_proc, 25);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- reset the OUT params to NULL to cater for NOCOPY
    p_validation_start_date := NULL;
    p_validation_end_date := NULL;
    RAISE;
END Get_Delete_Next_Change_Dates;
-- ----------------------------------------------------------------------------
-- |----------------------------< Validate_DT_Mode >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Validates and returns the validation start and end dates for
--              the DateTrack mode provided.
--              Locking is also enforced within this procedure.
--              The argument p_enforce_foreign_locking determines if for the
--              correct DT mode (INSERT or DELETE) parental or child
--              foreign key entities should be locked. If this value if set to
--              false this procedure will not perform any foreign lockng
--              and it is expected to be handled by the calling process
--              (this is useful if a different method of locking is required
--              where the row  exclusive locking mechanisms is too
--              restrictive).
--
--              Locking Processing:
--
--              1. Entity range row locking:
--                 Mode                  Lock Comments
--                 --------------        ---- ---------------------------------
--                 INSERT                  N  No rows exists at this point
--                 UPDATE                  N  Current row already locked
--                 CORRECTION              N  Current row already locked
--                 UPDATE_OVERRIDE         Y  Have to lock future rows
--                 UPDATE_CHANGE_INSERT    N  Current row already locked
--                 DELETE                  Y  Have to lock future rows
--                 FUTURE_CHANGE           Y  Have to lock future rows
--                 DELETE_NEXT_CHANGE      Y  Have to lock future rows
--                                            We always lock all future rows
--                                            too ensure consistency. This
--                                            means that we may over-lock some
--                                            future rows unnessarily.
--                 ZAP                     Y  Have to lock all rows
--
--              2. Insert
--                 Parental rows are locked provided the argument
--                 p_enforce_foreign_locking has been set to TRUE.
--
--              3. Delete
--                 Child rows are locked provided the argument
--                 p_enforce_foreign_locking has been set to TRUE.
--
-- ----------------------------------------------------------------------------
PROCEDURE Validate_DT_Mode
         (p_datetrack_mode              IN VARCHAR2,
          p_effective_date              IN DATE,
          p_base_table_name             IN VARCHAR2,
          p_base_key_column             IN VARCHAR2,
          p_base_key_value              IN NUMBER,
          p_parent_table_name1          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_column1          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_value1           IN NUMBER   DEFAULT HR_API.G_NUMBER,
          p_parent_table_name2          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_column2          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_value2           IN NUMBER   DEFAULT HR_API.G_NUMBER,
          p_parent_table_name3          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_column3          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_value3           IN NUMBER   DEFAULT HR_API.G_NUMBER,
          p_parent_table_name4          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_column4          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_value4           IN NUMBER   DEFAULT HR_API.G_NUMBER,
          p_parent_table_name5          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_column5          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_value5           IN NUMBER   DEFAULT HR_API.G_NUMBER,
          p_parent_table_name6          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_column6          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_value6           IN NUMBER   DEFAULT HR_API.G_NUMBER,
          p_parent_table_name7          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_column7          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_value7           IN NUMBER   DEFAULT HR_API.G_NUMBER,
          p_parent_table_name8          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_column8          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_value8           IN NUMBER   DEFAULT HR_API.G_NUMBER,
          p_parent_table_name9          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_column9          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_value9           IN NUMBER   DEFAULT HR_API.G_NUMBER,
          p_parent_table_name10         IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_column10         IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_parent_key_value10          IN NUMBER   DEFAULT HR_API.G_NUMBER,
          p_child_table_name1           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_key_column1           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_table_name2           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_key_column2           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_table_name3           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_key_column3           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_table_name4           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_key_column4           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_table_name5           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_key_column5           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_table_name6           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_key_column6           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_table_name7           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_key_column7           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_table_name8           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_key_column8           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_table_name9           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_key_column9           IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_table_name10          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_key_column10          IN VARCHAR2 DEFAULT HR_API.G_VARCHAR2,
          p_child_alt_base_key_column1  IN VARCHAR2 DEFAULT NULL,
          p_child_alt_base_key_column2  IN VARCHAR2 DEFAULT NULL,
          p_child_alt_base_key_column3  IN VARCHAR2 DEFAULT NULL,
          p_child_alt_base_key_column4  IN VARCHAR2 DEFAULT NULL,
          p_child_alt_base_key_column5  IN VARCHAR2 DEFAULT NULL,
          p_child_alt_base_key_column6  IN VARCHAR2 DEFAULT NULL,
          p_child_alt_base_key_column7  IN VARCHAR2 DEFAULT NULL,
          p_child_alt_base_key_column8  IN VARCHAR2 DEFAULT NULL,
          p_child_alt_base_key_column9  IN VARCHAR2 DEFAULT NULL,
          p_child_alt_base_key_column10 IN VARCHAR2 DEFAULT NULL,
          p_enforce_foreign_locking     IN BOOLEAN  DEFAULT TRUE,
          p_validation_start_date       OUT NOCOPY  DATE,
          p_validation_end_date         OUT NOCOPY  DATE) IS
--
  l_proc            VARCHAR2(72);
  l_datetrack_mode  VARCHAR2(30);
--
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := g_package||'Validate_DT_Mode';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- upper the datetrack mode
  l_datetrack_mode := upper(p_datetrack_mode);
  -- check the effective date
  Effective_Date_Valid(p_effective_date => p_effective_date);
  --
  -- Ensure that all the mandatory arguments are not null
  -- [ start of change 30.14 ]
  --
  IF p_datetrack_mode IS NULL OR p_base_table_name IS NULL OR
     p_base_key_column IS NULL THEN
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_datetrack_mode',
                               p_argument_value => p_datetrack_mode);
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_base_table_name',
                               p_argument_value => p_base_table_name);
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_base_key_column',
                               p_argument_value => p_base_key_column);
  END IF;
  -- [ start of change 30.15 ]
  -- removed the hr_api.mandatory_arg_error for p_base_key_value
  -- [ end of change 30.15 ]
  -- [ end of change 30.14 ]
  --
  IF    (l_datetrack_mode = dt_api.g_insert) THEN
    --
    Get_Insert_Dates
      (p_effective_date          => p_effective_date,
       p_base_table_name         => p_base_table_name,
       p_base_key_column         => p_base_key_column,
       p_base_key_value          => p_base_key_value,
       p_parent_table_name1      => p_parent_table_name1,
       p_parent_key_column1      => p_parent_key_column1,
       p_parent_key_value1       => p_parent_key_value1,
       p_parent_table_name2      => p_parent_table_name2,
       p_parent_key_column2      => p_parent_key_column2,
       p_parent_key_value2       => p_parent_key_value2,
       p_parent_table_name3      => p_parent_table_name3,
       p_parent_key_column3      => p_parent_key_column3,
       p_parent_key_value3       => p_parent_key_value3,
       p_parent_table_name4      => p_parent_table_name4,
       p_parent_key_column4      => p_parent_key_column4,
       p_parent_key_value4       => p_parent_key_value4,
       p_parent_table_name5      => p_parent_table_name5,
       p_parent_key_column5      => p_parent_key_column5,
       p_parent_key_value5       => p_parent_key_value5,
       p_parent_table_name6      => p_parent_table_name6,
       p_parent_key_column6      => p_parent_key_column6,
       p_parent_key_value6       => p_parent_key_value6,
       p_parent_table_name7      => p_parent_table_name7,
       p_parent_key_column7      => p_parent_key_column7,
       p_parent_key_value7       => p_parent_key_value7,
       p_parent_table_name8      => p_parent_table_name8,
       p_parent_key_column8      => p_parent_key_column8,
       p_parent_key_value8       => p_parent_key_value8,
       p_parent_table_name9      => p_parent_table_name9,
       p_parent_key_column9      => p_parent_key_column9,
       p_parent_key_value9       => p_parent_key_value9,
       p_parent_table_name10     => p_parent_table_name10,
       p_parent_key_column10     => p_parent_key_column10,
       p_parent_key_value10      => p_parent_key_value10,
       p_enforce_foreign_locking => p_enforce_foreign_locking,
       p_validation_start_date   => p_validation_start_date,
       p_validation_end_date     => p_validation_end_date);
    --
  ELSIF (l_datetrack_mode = dt_api.g_correction) THEN
    --
    Get_Correction_Dates
      (p_effective_date        => p_effective_date,
       p_base_table_name       => p_base_table_name,
       p_base_key_column       => p_base_key_column,
       p_base_key_value        => p_base_key_value,
       p_validation_start_date => p_validation_start_date,
       p_validation_end_date   => p_validation_end_date);
    --
  ELSIF (l_datetrack_mode = dt_api.g_update) THEN
    --
    Get_Update_Dates
      (p_effective_date        => p_effective_date,
       p_base_table_name       => p_base_table_name,
       p_base_key_column       => p_base_key_column,
       p_base_key_value        => p_base_key_value,
       p_validation_start_date => p_validation_start_date,
       p_validation_end_date   => p_validation_end_date);
    --
  ELSIF (l_datetrack_mode = dt_api.g_zap) THEN
    --
    Get_Zap_Dates
      (p_effective_date        => p_effective_date,
       p_base_table_name       => p_base_table_name,
       p_base_key_column       => p_base_key_column,
       p_base_key_value        => p_base_key_value,
       p_validation_start_date => p_validation_start_date,
       p_validation_end_date   => p_validation_end_date);
    --
  ELSIF (l_datetrack_mode = dt_api.g_delete) THEN
    --
    Get_Delete_Dates
      (p_effective_date              => p_effective_date,
       p_base_table_name             => p_base_table_name,
       p_base_key_column             => p_base_key_column,
       p_base_key_value              => p_base_key_value,
       p_child_table_name1           => p_child_table_name1,
       p_child_key_column1           => p_child_key_column1,
       p_child_table_name2           => p_child_table_name2,
       p_child_key_column2           => p_child_key_column2,
       p_child_table_name3           => p_child_table_name3,
       p_child_key_column3           => p_child_key_column3,
       p_child_table_name4           => p_child_table_name4,
       p_child_key_column4           => p_child_key_column4,
       p_child_table_name5           => p_child_table_name5,
       p_child_key_column5           => p_child_key_column5,
       p_child_table_name6           => p_child_table_name6,
       p_child_key_column6           => p_child_key_column6,
       p_child_table_name7           => p_child_table_name7,
       p_child_key_column7           => p_child_key_column7,
       p_child_table_name8           => p_child_table_name8,
       p_child_key_column8           => p_child_key_column8,
       p_child_table_name9           => p_child_table_name9,
       p_child_key_column9           => p_child_key_column9,
       p_child_table_name10          => p_child_table_name10,
       p_child_key_column10          => p_child_key_column10,
       p_child_alt_base_key_column1  => p_child_alt_base_key_column1,
       p_child_alt_base_key_column2  => p_child_alt_base_key_column2,
       p_child_alt_base_key_column3  => p_child_alt_base_key_column3,
       p_child_alt_base_key_column4  => p_child_alt_base_key_column4,
       p_child_alt_base_key_column5  => p_child_alt_base_key_column5,
       p_child_alt_base_key_column6  => p_child_alt_base_key_column6,
       p_child_alt_base_key_column7  => p_child_alt_base_key_column7,
       p_child_alt_base_key_column8  => p_child_alt_base_key_column8,
       p_child_alt_base_key_column9  => p_child_alt_base_key_column9,
       p_child_alt_base_key_column10 => p_child_alt_base_key_column10,
       p_enforce_foreign_locking     => p_enforce_foreign_locking,
       p_validation_start_date       => p_validation_start_date,
       p_validation_end_date         => p_validation_end_date);
    --
  ELSIF (l_datetrack_mode = dt_api.g_update_override) THEN
    --
    Get_Update_Override_Dates
      (p_effective_date        => p_effective_date,
       p_base_table_name       => p_base_table_name,
       p_base_key_column       => p_base_key_column,
       p_base_key_value        => p_base_key_value,
       p_validation_start_date => p_validation_start_date,
       p_validation_end_date   => p_validation_end_date);
    --
  ELSIF (l_datetrack_mode = dt_api.g_update_change_insert) THEN
    --
    Get_Update_Change_Insert_Dates
      (p_effective_date        => p_effective_date,
       p_base_table_name       => p_base_table_name,
       p_base_key_column       => p_base_key_column,
       p_base_key_value        => p_base_key_value,
       p_validation_start_date => p_validation_start_date,
       p_validation_end_date   => p_validation_end_date);
    --
  ELSIF (l_datetrack_mode = dt_api.g_future_change) THEN
    --
    Get_Future_Change_Dates
      (p_effective_date        => p_effective_date,
       p_base_table_name       => p_base_table_name,
       p_base_key_column       => p_base_key_column,
       p_base_key_value        => p_base_key_value,
       p_parent_table_name1    => p_parent_table_name1,
       p_parent_key_column1    => p_parent_key_column1,
       p_parent_key_value1     => p_parent_key_value1,
       p_parent_table_name2    => p_parent_table_name2,
       p_parent_key_column2    => p_parent_key_column2,
       p_parent_key_value2     => p_parent_key_value2,
       p_parent_table_name3    => p_parent_table_name3,
       p_parent_key_column3    => p_parent_key_column3,
       p_parent_key_value3     => p_parent_key_value3,
       p_parent_table_name4    => p_parent_table_name4,
       p_parent_key_column4    => p_parent_key_column4,
       p_parent_key_value4     => p_parent_key_value4,
       p_parent_table_name5    => p_parent_table_name5,
       p_parent_key_column5    => p_parent_key_column5,
       p_parent_key_value5     => p_parent_key_value5,
       p_parent_table_name6    => p_parent_table_name6,
       p_parent_key_column6    => p_parent_key_column6,
       p_parent_key_value6     => p_parent_key_value6,
       p_parent_table_name7    => p_parent_table_name7,
       p_parent_key_column7    => p_parent_key_column7,
       p_parent_key_value7     => p_parent_key_value7,
       p_parent_table_name8    => p_parent_table_name8,
       p_parent_key_column8    => p_parent_key_column8,
       p_parent_key_value8     => p_parent_key_value8,
       p_parent_table_name9    => p_parent_table_name9,
       p_parent_key_column9    => p_parent_key_column9,
       p_parent_key_value9     => p_parent_key_value9,
       p_parent_table_name10   => p_parent_table_name10,
       p_parent_key_column10   => p_parent_key_column10,
       p_parent_key_value10    => p_parent_key_value10,
       p_validation_start_date => p_validation_start_date,
       p_validation_end_date   => p_validation_end_date);
    --
  ELSIF (l_datetrack_mode = dt_api.g_delete_next_change) THEN
    --
    Get_Delete_Next_Change_Dates
      (p_effective_date        => p_effective_date,
       p_base_table_name       => p_base_table_name,
       p_base_key_column       => p_base_key_column,
       p_base_key_value        => p_base_key_value,
       p_parent_table_name1    => p_parent_table_name1,
       p_parent_key_column1    => p_parent_key_column1,
       p_parent_key_value1     => p_parent_key_value1,
       p_parent_table_name2    => p_parent_table_name2,
       p_parent_key_column2    => p_parent_key_column2,
       p_parent_key_value2     => p_parent_key_value2,
       p_parent_table_name3    => p_parent_table_name3,
       p_parent_key_column3    => p_parent_key_column3,
       p_parent_key_value3     => p_parent_key_value3,
       p_parent_table_name4    => p_parent_table_name4,
       p_parent_key_column4    => p_parent_key_column4,
       p_parent_key_value4     => p_parent_key_value4,
       p_parent_table_name5    => p_parent_table_name5,
       p_parent_key_column5    => p_parent_key_column5,
       p_parent_key_value5     => p_parent_key_value5,
       p_parent_table_name6    => p_parent_table_name6,
       p_parent_key_column6    => p_parent_key_column6,
       p_parent_key_value6     => p_parent_key_value6,
       p_parent_table_name7    => p_parent_table_name7,
       p_parent_key_column7    => p_parent_key_column7,
       p_parent_key_value7     => p_parent_key_value7,
       p_parent_table_name8    => p_parent_table_name8,
       p_parent_key_column8    => p_parent_key_column8,
       p_parent_key_value8     => p_parent_key_value8,
       p_parent_table_name9    => p_parent_table_name9,
       p_parent_key_column9    => p_parent_key_column9,
       p_parent_key_value9     => p_parent_key_value9,
       p_parent_table_name10   => p_parent_table_name10,
       p_parent_key_column10   => p_parent_key_column10,
       p_parent_key_value10    => p_parent_key_value10,
       p_validation_start_date => p_validation_start_date,
       p_validation_end_date   => p_validation_end_date);
  ELSE
    hr_utility.set_message(801, 'HR_7184_DT_MODE_UNKNOWN');
    hr_utility.set_message_token('DT_MODE', l_datetrack_mode);
    hr_utility.raise_error;
  END IF;
  IF g_debug THEN
    Hr_Utility.Set_Location(' Leaving:'||l_proc, 55);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- reset the OUT params to NULL to cater for NOCOPY
    p_validation_start_date := NULL;
    p_validation_end_date := NULL;
    RAISE;
END Validate_DT_Mode;
-- ----------------------------------------------------------------------------
-- |------------------------< Validate_DT_Upd_Mode >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Functions returns TRUE if the datetrack update mode is valid.
--
-- ----------------------------------------------------------------------------
FUNCTION Validate_DT_Upd_Mode(p_datetrack_mode IN VARCHAR2) RETURN BOOLEAN IS
  --
  l_proc VARCHAR2(72);
  --
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := g_package||'Validate_DT_Upd_Mode';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  IF p_datetrack_mode IS NULL THEN
    -- Ensure that the mode is not null
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'datetrack_mode',
                               p_argument_value => p_datetrack_mode);
  END IF;
  -- Check the mode is valid
  IF (p_datetrack_mode = dt_api.g_correction      OR
      p_datetrack_mode = dt_api.g_update          OR
      p_datetrack_mode = dt_api.g_update_override OR
      p_datetrack_mode = dt_api.g_update_change_insert) THEN
    IF g_debug THEN
      Hr_Utility.Set_Location(' Leaving:'||l_proc, 10);
    END IF;
    RETURN(TRUE);
  ELSE
    IF g_debug THEN
      Hr_Utility.Set_Location(' Leaving:'||l_proc, 15);
    END IF;
    RETURN(FALSE);
  END If;
END Validate_DT_Upd_Mode;
-- ----------------------------------------------------------------------------
-- |------------------------< Validate_DT_Del_Mode >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Functions returns TRUE if the datetrack delete mode is valid.
--
-- ----------------------------------------------------------------------------
FUNCTION Validate_DT_Del_Mode(p_datetrack_mode IN VARCHAR2) RETURN BOOLEAN IS
  --
  l_proc VARCHAR2(72);
  --
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := g_package||'Validate_DT_Del_Mode';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  IF p_datetrack_mode IS NULL THEN
    -- Ensure that the mode is not null
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'datetrack_mode',
                               p_argument_value => p_datetrack_mode);
  END IF;
  -- Check the mode is valid
  IF (p_datetrack_mode = dt_api.g_zap                  OR
      p_datetrack_mode = dt_api.g_delete               OR
      p_datetrack_mode = dt_api.g_future_change        OR
      p_datetrack_mode = dt_api.g_delete_next_change)  THEN
    IF g_debug THEN
      Hr_Utility.Set_Location(' Leaving:'||l_proc, 10);
    END IF;
    RETURN(TRUE);
  ELSE
    IF g_debug THEN
      Hr_Utility.Set_Location(' Leaving:'||l_proc, 10);
    END IF;
    RETURN(FALSE);
  END IF;
END Validate_DT_Del_Mode;
-- ----------------------------------------------------------------------------
-- |------------------------< Validate_DT_Upd_Mode >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Validates the datetrack update mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE Validate_DT_Upd_Mode(p_datetrack_mode IN VARCHAR2) IS
--
  l_proc VARCHAR2(72);
--
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := g_package||'Validate_DT_Upd_Mode';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- Check the mode is valid
  IF (NOT Validate_DT_Upd_Mode(p_datetrack_mode => p_datetrack_mode)) THEN
    -- The datetrack mode is invalid therefore we must error
    hr_utility.set_message(801, 'HR_7203_DT_UPD_MODE_INVALID');
    hr_utility.raise_error;
  END IF;
  IF g_debug THEN
    Hr_Utility.Set_Location(' Leaving:'||l_proc, 10);
  END IF;
END Validate_DT_Upd_Mode;
-- ----------------------------------------------------------------------------
-- |------------------------< Validate_DT_Del_Mode >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Validates the datetrack delete mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE Validate_DT_Del_Mode(p_datetrack_mode IN VARCHAR2) IS
  --
  l_proc VARCHAR2(72);
  --
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := g_package||'Validate_DT_Del_Mode';
    Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  END IF;
  -- Check the mode is valid
  IF (NOT Validate_DT_Del_Mode(p_datetrack_mode => p_datetrack_mode)) THEN
    -- The datetrack mode is invalid therefore we must error
    hr_utility.set_message(801, 'HR_7204_DT_DEL_MODE_INVALID');
    hr_utility.raise_error;
  END IF;
  IF g_debug THEN
    Hr_Utility.Set_Location(' Leaving:'||l_proc, 10);
  END IF;
End Validate_DT_Del_Mode;
-- ----------------------------------------------------------------------------
-- |-----------------------< Get_Object_Version_Number >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Function will return the next object version number to be used
--              within datetrack for an insert or update dml operation. The
--              returned object version number will be determined by taking
--              the maximum object version number for the datetracked rows
--              and then incrementing by 1. All datetrack modes will call
--              this function except ZAP.
--
-- ----------------------------------------------------------------------------
FUNCTION get_object_version_number
        (p_base_table_name  IN VARCHAR2,
         p_base_key_column  IN VARCHAR2,
         p_base_key_value   IN NUMBER)
        RETURN NUMBER IS
--
  l_proc        VARCHAR2(72);
  l_object_num  NUMBER;      -- Holds new object version number
--
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := g_package||'get_object_version_number';
    hr_utility.set_location('Entering:'||l_proc, 5);
  END IF;
  -- Ensure that all the mandatory arguments are not null
  -- [ start of change 30.14 ]
  IF p_base_table_name IS NULL OR
     p_base_key_column IS NULL OR
     p_base_key_value IS NULL THEN
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_base_table_name',
                               p_argument_value => p_base_table_name);
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_base_key_column',
                               p_argument_value => p_base_key_column);
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_base_key_value',
                               p_argument_value => p_base_key_value);
  END IF;
  -- [ end of change 30.14 ]
  --
  -- Define dynamic sql text with substitution tokens
  --
  g_dynamic_sql :=
    'SELECT NVL(MAX(t.object_version_number),0) + 1 '||
    'FROM '||LOWER(p_base_table_name)||' t '||
    'WHERE t.'||LOWER(p_base_key_column)||' = :p_base_key_value';
  -- set the dynamic SQL comment for identification
  dt_api.g_dynamic_sql :=
    dt_api.g_dynamic_sql||
    REPLACE(dt_api.g_dynamic_sql_comment,'{proc}','get_object_version_number');
  --
  EXECUTE IMMEDIATE g_dynamic_sql
  INTO  l_object_num
  USING p_base_key_value;
  IF g_debug THEN
    hr_utility.set_location('Leaving :'||l_proc, 10);
  END IF;
  RETURN(l_object_num);
END get_object_version_number;
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Function returns a boolean value. TRUE will be set if
--              row exists for the specified table between the from and to
--              dates else FALSE will be returned.
--              If the p_base_key_value is NULL then this function will
--              always return FALSE. The reason for this is that, the
--              calling process might have an option foreign key column which
--              is null.
--
-- ----------------------------------------------------------------------------
FUNCTION rows_exist
         (p_base_table_name IN VARCHAR2,
          p_base_key_column IN VARCHAR2,
          p_base_key_value  IN NUMBER,
          p_from_date       IN DATE,
          p_to_date         IN DATE DEFAULT hr_api.g_eot)
         RETURN BOOLEAN IS
--
  l_proc        VARCHAR2(72);
  l_ret_column  number(1);      -- Returning Sql Column
--
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := g_package||'rows_exist';
    hr_utility.set_location('Entering:'||l_proc, 5);
  END IF;
  IF (p_base_key_value IS NOT NULL) THEN
    IF p_base_table_name IS NULL OR
       p_base_key_column IS NULL OR
       p_from_date IS NULL OR
       p_to_date IS NULL THEN
      -- Mandatory arg checking
      hr_api.mandatory_arg_error
        (p_api_name       => l_proc,
         p_argument       => 'p_base_table_name',
         p_argument_value => p_base_table_name);
      --
      hr_api.mandatory_arg_error
        (p_api_name       => l_proc,
         p_argument       => 'p_base_key_column',
         p_argument_value => p_base_key_column);
      --
      hr_api.mandatory_arg_error
        (p_api_name       => l_proc,
         p_argument       => 'p_from_date',
         p_argument_value => p_from_date);
      --
      hr_api.mandatory_arg_error
        (p_api_name       => l_proc,
         p_argument       => 'p_to_date',
         p_argument_value => p_to_date);
    END IF;
    -- Define dynamic sql text with substitution tokens
    g_dynamic_sql :=
      'SELECT NULL '||
      'FROM '||LOWER(p_base_table_name)||' t '||
      'WHERE t.'||LOWER(p_base_key_column)||' = :p_base_key_value '||
      'AND t.effective_start_date <= :p_to_date '||
      'AND t.effective_end_date >= :p_from_date';
    -- set the dynamic SQL comment for identification
    dt_api.g_dynamic_sql :=
      dt_api.g_dynamic_sql||
      REPLACE(dt_api.g_dynamic_sql_comment,'{proc}','rows_exist');
    --
    EXECUTE IMMEDIATE g_dynamic_sql
    INTO  l_ret_column
    USING p_base_key_value, p_to_date, p_from_date;
    -- one row exists so return true
    IF g_debug THEN
      hr_utility.set_location('Leaving:'||l_proc, 10);
    END IF;
    RETURN(TRUE);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF g_debug THEN
      hr_utility.set_location('Leaving:'||l_proc, 15);
    END IF;
    -- return false as no rows exist
    RETURN(FALSE);
  WHEN TOO_MANY_ROWS THEN
    IF g_debug THEN
      hr_utility.set_location('Leaving:'||l_proc, 20);
    END IF;
    -- return TRUE because more than one row exists
    RETURN(TRUE);
  WHEN OTHERS THEN
    RAISE;
END rows_exist;
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: This function is used to determine if datetrack rows exist
--              between the from and to date specified.
--              If the datetrack rows do exist for the duration then a TRUE
--              value will be returned else FALSE will be returned.
--              If the p_base_key_value is null then this function will assume
--              that an optional relationship is in force and will return TRUE
--
-- ----------------------------------------------------------------------------
FUNCTION check_min_max_dates
         (p_base_table_name IN  VARCHAR2,
          p_base_key_column IN  VARCHAR2,
          p_base_key_value  IN  NUMBER,
          p_from_date       IN  DATE,
          p_to_date         IN  DATE)
         RETURN BOOLEAN IS
--
  l_proc        VARCHAR2(72);
  l_min_date    DATE;
  l_max_date    DATE;
--
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := g_package||'check_min_max_dates';
    hr_utility.set_location('Entering:'||l_proc, 5);
  END IF;
  IF (p_base_key_value IS NOT NULL) THEN
    IF p_base_table_name IS NULL OR
       p_base_key_column IS NULL OR
       p_from_date IS NULL OR
       p_to_date IS NULL THEN
      -- Mandatory arg checking
      hr_api.mandatory_arg_error
        (p_api_name       => l_proc,
         p_argument       => 'p_base_table_name',
         p_argument_value => p_base_table_name);
      --
      hr_api.mandatory_arg_error
        (p_api_name       => l_proc,
         p_argument       => 'p_base_key_column',
         p_argument_value => p_base_key_column);
      --
      hr_api.mandatory_arg_error
        (p_api_name       => l_proc,
         p_argument       => 'p_from_date',
         p_argument_value => p_from_date);
      --
      hr_api.mandatory_arg_error
        (p_api_name       => l_proc,
         p_argument       => 'p_to_date',
         p_argument_value => p_to_date);
    END IF;
    -- Define dynamic sql text with substitution tokens
    g_dynamic_sql :=
      'SELECT MIN(t.effective_start_date),MAX(t.effective_end_date) '||
      'FROM '||LOWER(p_base_table_name)||' t '                   ||
      'WHERE t.'||LOWER(p_base_key_column)||' = :p_base_key_value';
    -- set the dynamic SQL comment for identification
    dt_api.g_dynamic_sql :=
      dt_api.g_dynamic_sql||
      REPLACE(dt_api.g_dynamic_sql_comment,'{proc}','check_min_max_dates');
    --
    EXECUTE IMMEDIATE g_dynamic_sql
    INTO  l_min_date, l_max_date
    USING p_base_key_value;
    -- Determine if the aggregate functions returned null.
    -- If they are null then no rows were found therefore we must error
    -- as either the table name, base key column name or base key value
    -- was incorrectly specified.
    IF (l_min_date IS NULL AND l_max_date IS NULL) THEN
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','40');
      hr_utility.raise_error;
    ELSE
      -- Ensure that the min and max dates fall within the from and to
      -- dates
      IF (p_from_date >= l_min_date AND p_to_date <= l_max_date) THEN
        IF g_debug THEN
          hr_utility.set_location(' Leaving:'||l_proc, 10);
        END IF;
        RETURN(TRUE);
      ELSE
        IF g_debug THEN
          Hr_utility.set_location(' Leaving:'||l_proc, 15);
        END IF;
        RETURN(FALSE);
      END IF;
    END IF;
  ELSE
    IF g_debug THEN
      hr_utility.set_location(' Leaving:'||l_proc, 20);
    END IF;
  -- The key value has not been specified
    RETURN(TRUE);
  END IF;
END check_min_max_dates;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< find_dt_upd_modes_and_dates >----------------------|
-- ----------------------------------------------------------------------------
--
--
procedure find_dt_upd_modes_and_dates
  (p_effective_date                in     date
  ,p_base_table_name               in     varchar2
  ,p_base_key_column               in     varchar2
  ,p_base_key_value                in     number
  ,p_correction                       out nocopy boolean
  ,p_update                           out nocopy boolean
  ,p_update_override                  out nocopy boolean
  ,p_update_change_insert             out nocopy boolean
  ,p_correction_start_date            out nocopy date
  ,p_correction_end_date              out nocopy date
  ,p_update_start_date                out nocopy date
  ,p_update_end_date                  out nocopy date
  ,p_override_start_date              out nocopy date
  ,p_override_end_date                out nocopy date
  ,p_upd_chg_start_date                out nocopy date
  ,p_upd_chg_end_date                  out nocopy date
  ) IS
  --
  -- Local variables
  --

  l_effective_rows          g_dt_effective_rows_tab;
  l_date_from_row_idx       BINARY_INTEGER;
  l_proc   varchar2(80) ;

begin
   g_debug := hr_utility.debug_enabled;
   IF g_debug THEN
     l_proc :=  g_package||'find_dt_upd_modes_and_dates';
     hr_utility.set_location('Entering: '||l_proc,10);
   END IF;
  Effective_Date_Valid(p_effective_date => p_effective_date);
  -- Ensure that all the mandatory arguments are not null
  -- [ start of change 30.14 ]
  IF p_base_table_name IS NULL OR
     p_base_key_column IS NULL OR
     p_base_key_value IS NULL THEN
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_base_table_name',
                               p_argument_value => p_base_table_name);
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_base_key_column',
                               p_argument_value => p_base_key_column);
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_base_key_value',
                               p_argument_value => p_base_key_value);
  END IF;
  -- [ end of change 30.14 ]
  --
  -- CORRECTION: always set to TRUE
  p_correction := TRUE;
  -- get the effective rows
  get_effective_rows
    (p_date_from         => p_effective_date,
     p_base_table_name   => p_base_table_name,
     p_base_key_column   => p_base_key_column,
     p_base_key_value    => p_base_key_value,
     p_lock_rows         => FALSE,
     p_date_from_valid   => TRUE,
     p_effective_rows    => l_effective_rows,
     p_date_from_row_idx => l_date_from_row_idx);
  -- If the current effective start date is not the same as the effective
  -- date then we must check to see if update operations are allowed, else
  -- no update operations are allowed
  IF (l_effective_rows(l_date_from_row_idx).effective_start_date <>
      p_effective_date) THEN
    -- As the current row does not start on the effective date we
    -- determine if any future rows exist.
    IF (l_effective_rows.COUNT > l_date_from_row_idx) THEN
      -- As future rows exist we must set:
      -- 1) UPDATE must be set to FALSE
      -- 2) UPDATE_OVERRIDE and UPDATE_CHANGE_INSERT must be set TRUE
      IF g_debug THEN
        hr_utility.set_location(l_proc,20);
      END IF;
      p_update               := FALSE;
      p_update_start_date    := NULL;
      p_update_end_date      := NULL;
      p_update_override      := TRUE;
      p_override_start_date := p_effective_date;
      p_override_end_date   :=
              l_effective_rows(l_effective_rows.LAST).effective_end_date;
      p_update_change_insert := TRUE;
      p_upd_chg_start_date := p_effective_date;
      p_upd_chg_end_date   :=
             l_effective_rows(l_date_from_row_idx).effective_end_date;
    ELSE
      -- As future rows don't exist we must set:
      -- 1) UPDATE must be set to TRUE
      -- 2) UPDATE_OVERRIDE and UPDATE_CHANGE_INSERT must be set FALSE
      IF g_debug THEN
        hr_utility.set_location(l_proc,30);
      END IF;
      p_update               := TRUE;
      p_update_start_date    := p_effective_date;
      p_update_end_date      :=
             l_effective_rows(l_date_from_row_idx).effective_end_date;
      p_update_override      := FALSE;
      p_override_start_date  := NULL;
      p_override_end_date    := NULL;
      p_update_change_insert := FALSE;
      p_upd_chg_start_date   := NULL;
      p_upd_chg_end_date     := NULL;
    END IF;
  ELSE
    -- As the current effective start date is the same as the effective date
    -- we must set:
    -- 1) UPDATE must be set to FALSE
    -- 2) UPDATE_OVERRIDE and UPDATE_CHANGE_INSERT must be set FALSE
    IF g_debug THEN
      hr_utility.set_location(l_proc,40);
    END IF;
    p_update               := FALSE;
    p_update_start_date    := NULL;
    p_update_end_date      := NULL;
    p_update_override      := FALSE;
    p_override_start_date  := NULL;
    p_override_end_date    := NULL;
    p_update_change_insert := FALSE;
    p_upd_chg_start_date   := NULL;
    p_upd_chg_end_date     := NULL;
  END IF;

--Set validation start date and end date for each of the modes
  IF p_correction = TRUE THEN
     IF g_debug THEN
       hr_utility.set_location(l_proc,50);
     END IF;

     p_correction_start_date :=
     l_effective_rows(l_date_from_row_idx).effective_start_date;
     p_correction_end_date :=
     l_effective_rows(l_date_from_row_idx).effective_end_date;
  END IF;
  IF g_debug THEN
    hr_utility.set_location('Leaving :'||l_proc, 60);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- set all OUTs to NULL and RAISE
    p_correction           := NULL;
    p_update               := NULL;
    p_update_override      := NULL;
    p_update_change_insert := NULL;
    p_correction_start_date  := NULL;
    p_correction_end_date    := NULL;
    p_update_start_date   := NULL;
    p_update_end_date     := NULL;
    p_upd_chg_start_date   := NULL;
    p_upd_chg_end_date     := NULL;
    p_override_start_date := NULL;
    p_override_end_date    := NULL;
    RAISE;
end find_dt_upd_modes_and_dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------< find_dt_del_modes_and_dates >----------------------|
-- ----------------------------------------------------------------------------
--
procedure find_dt_del_modes_and_dates
  (p_effective_date                in     date
  ,p_base_table_name               in     varchar2
  ,p_base_key_column               in     varchar2
  ,p_base_key_value                in     number
  ,p_parent_table_name1            in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column1  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value1   	   in     number   default hr_api.g_number
  ,p_parent_table_name2  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column2  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value2   	   in     number   default hr_api.g_number
  ,p_parent_table_name3  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column3  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value3   	   in     number   default hr_api.g_number
  ,p_parent_table_name4  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column4  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value4   	   in     number   default hr_api.g_number
  ,p_parent_table_name5  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column5  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value5   	   in     number   default hr_api.g_number
  ,p_parent_table_name6  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column6  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value6   	   in     number   default hr_api.g_number
  ,p_parent_table_name7  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column7  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value7   	   in     number   default hr_api.g_number
  ,p_parent_table_name8  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column8  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value8   	   in     number   default hr_api.g_number
  ,p_parent_table_name9  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column9  	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value9   	   in     number   default hr_api.g_number
  ,p_parent_table_name10 	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_column10 	   in     varchar2 default hr_api.g_varchar2
  ,p_parent_key_value10  	   in     number   default hr_api.g_number
  ,p_zap                              out nocopy boolean
  ,p_delete                           out nocopy boolean
  ,p_future_change                    out nocopy boolean
  ,p_delete_next_change               out nocopy boolean
  ,p_zap_start_date                   out nocopy date
  ,p_zap_end_date                     out nocopy date
  ,p_delete_start_date                out nocopy date
  ,p_delete_end_date                  out nocopy date
  ,p_del_future_start_date                out nocopy date
  ,p_del_future_end_date                  out nocopy date
  ,p_del_next_start_date               out nocopy date
  ,p_del_next_end_date                 out nocopy date
 ) is


  l_effective_rows          g_dt_effective_rows_tab;
  l_date_from_row_idx       BINARY_INTEGER;
  l_future_effective_end_date DATE;
  l_validation_end_date       DATE;
  l_parent_min_date           DATE;
  l_proc   varchar2(80) ;
begin
   g_debug := hr_utility.debug_enabled;
   if g_debug then
     l_proc :=  g_package||'get_update_modes_for_oaf';
     hr_utility.set_location('Entering: '||l_proc,10);
   end if;

  Effective_Date_Valid(p_effective_date => p_effective_date);
  -- Ensure that all the mandatory arguments are not null
  -- [ start of change 30.14 ]
  IF p_base_table_name IS NULL OR
     p_base_key_column IS NULL OR
     p_base_key_value IS NULL THEN
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_base_table_name',
                               p_argument_value => p_base_table_name);
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_base_key_column',
                               p_argument_value => p_base_key_column);
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                               p_argument       => 'p_base_key_value',
                               p_argument_value => p_base_key_value);
  END IF;
  -- [ end of change 30.14 ]
  -- ZAP: always set to TRUE
  p_zap := TRUE;
  -- get the effective rows
  l_date_from_row_idx := 0;
  get_effective_rows
    (p_date_from         => dt_api.g_sot,
     p_base_table_name   => p_base_table_name,
     p_base_key_column   => p_base_key_column,
     p_base_key_value    => p_base_key_value,
     p_lock_rows         => FALSE,
     p_date_from_valid   => FALSE,
     p_effective_rows    => l_effective_rows,
     p_date_from_row_idx => l_date_from_row_idx);
  IF p_zap = TRUE THEN
  -- at least one row will exist otherwise the get_effective_rows would of
  -- raised an error therefore just set the p_validation_start_date and
  -- p_validation_end_date OUT parameters
     p_zap_start_date :=
       l_effective_rows(l_effective_rows.FIRST).effective_start_date;
     p_zap_end_date :=
       l_effective_rows(l_effective_rows.LAST).effective_end_date;
  END IF;
  -- Now that the ZAP dates are set, set the l_date_from_row_idx to point
  -- to the current row as of p_effective_date
  <<get_row_idx>>
  FOR i IN l_effective_rows.FIRST..l_effective_rows.LAST
  LOOP
  -- Check if we are on the current row as of p_effective_date
  IF l_effective_rows(i).EFFECTIVE_START_DATE <= p_effective_date AND
   l_effective_rows(i).EFFECTIVE_END_DATE >= p_effective_date THEN
   --ok found the row, so set the index
   l_date_from_row_idx := i;
   -- exit loop
   EXIT get_row_idx;
  END IF;
  END LOOP;
  IF l_date_from_row_idx = 0 THEN
  -- a serious internal error has occured. Thisis defensive as this
  -- error should not be raised here
    hr_utility.set_message(801, 'HR_7180_DT_NO_ROW_EXIST');
    hr_utility.set_message_token('TABLE_NAME', p_base_table_name);
    hr_utility.set_message_token('SESSION_DATE',
                                 fnd_date.date_to_chardate(p_effective_date));
    hr_utility.raise_error;
  END IF;
  -- DELETE: always set to TRUE if the maximum effective end date is not the
  --         same as the effective date and the effective date if not the
  --         end of time
  IF ((p_effective_date <>
       l_effective_rows(l_effective_rows.LAST).effective_end_date) AND
      (p_effective_date <> dt_api.g_eot)) THEN
    p_delete := TRUE;
  ELSE
    p_delete := FALSE;
    p_delete_start_date := NULL;
    p_delete_end_date   := NULL;
  END IF;
  -- FUTURE_CHANGE
  -- DELETE_NEXT_CHANGE: always set to FALSE if the current effective end date
  --                     is the end of time or the minimum parental effective
  --                     end date is less than or equal to the effective end
  --                     date
  IF (l_effective_rows(l_date_from_row_idx).effective_end_date <>
      dt_api.g_eot) THEN
    l_parent_min_date := return_parent_min_date
        (p_effective_date => p_effective_date,
         p_lock_rows      => FALSE,
         p_table_name1    => p_parent_table_name1,
         p_key_column1    => p_parent_key_column1,
         p_key_value1     => p_parent_key_value1,
         p_table_name2    => p_parent_table_name2,
         p_key_column2    => p_parent_key_column2,
         p_key_value2     => p_parent_key_value2,
         p_table_name3    => p_parent_table_name3,
         p_key_column3    => p_parent_key_column3,
         p_key_value3     => p_parent_key_value3,
         p_table_name4    => p_parent_table_name4,
         p_key_column4    => p_parent_key_column4,
         p_key_value4     => p_parent_key_value4,
         p_table_name5    => p_parent_table_name5,
         p_key_column5    => p_parent_key_column5,
         p_key_value5     => p_parent_key_value5,
         p_table_name6    => p_parent_table_name6,
         p_key_column6    => p_parent_key_column6,
         p_key_value6     => p_parent_key_value6,
         p_table_name7    => p_parent_table_name7,
         p_key_column7    => p_parent_key_column7,
         p_key_value7     => p_parent_key_value7,
         p_table_name8    => p_parent_table_name8,
         p_key_column8    => p_parent_key_column8,
         p_key_value8     => p_parent_key_value8,
         p_table_name9    => p_parent_table_name9,
         p_key_column9    => p_parent_key_column9,
         p_key_value9     => p_parent_key_value9,
         p_table_name10   => p_parent_table_name10,
         p_key_column10   => p_parent_key_column10,
         p_key_value10    => p_parent_key_value10);
    -- get the min parent end date
    IF l_parent_min_date  <=
       l_effective_rows(l_date_from_row_idx).effective_end_date THEN
      p_future_change      := FALSE;
      p_delete_next_change := FALSE;
      p_del_future_start_date := NULL;
      p_del_future_end_date   := NULL;
      p_del_next_start_date := NULL;
      p_del_next_end_date   := NULL;
    ELSE
      p_future_change      := TRUE;
      p_delete_next_change := TRUE;
    END IF;
  ELSE
    p_future_change      := FALSE;
    p_delete_next_change := FALSE;
    p_del_future_start_date := NULL;
    p_del_future_end_date   := NULL;
    p_del_next_start_date := NULL;
    p_del_next_end_date   := NULL;
  END IF;

  IF p_delete = TRUE THEN
  -- Providing the maximum effective end date is not the same as the current
  -- effective date then we must return the validation start and end dates.
  -- However, if you attempt to do a datetrack delete where the session date is
  -- the same as your maximum date then we must error.
      IF (p_effective_date <>
          l_effective_rows(l_effective_rows.LAST).effective_end_date) THEN
        p_delete_start_date :=  p_effective_date + 1;
        p_delete_end_date   :=
          l_effective_rows(l_effective_rows.LAST).effective_end_date;
      ELSE
        -- We cannot perform a DateTrack delete operation where the effective date
        -- is the same as the maximum effective end date.
        hr_utility.set_message(801, 'HR_7185_DT_DEL_NOT_ALLOWED');
        hr_utility.raise_error;
      END IF;
  END IF;

  IF p_future_change = TRUE THEN
  -- Providing the current effective end date is not the end of time
  -- then we must set the validation dates
      IF (l_effective_rows(l_date_from_row_idx).effective_end_date <>
          dt_api.g_eot) THEN

        -- If the validation end date is set to the current effective end date
        -- then we must error as we cannot extend the end date of the current
        -- row
        l_validation_end_date := l_parent_min_date;
        IF (l_validation_end_date <=
            l_effective_rows(l_date_from_row_idx).effective_end_date) THEN
          hr_utility.set_message(801, 'HR_7187_DT_CANNOT_EXTEND_END');
          hr_utility.set_message_token('DT_MODE', ' future changes');
          hr_utility.raise_error;
        ELSE
          -- set the validation_start/end_date OUT params
          p_del_future_start_date :=
            l_effective_rows(l_date_from_row_idx).effective_end_date + 1;
          p_del_future_end_date := l_validation_end_date;
        END IF;
      ELSE
        -- The current effective end date is alreay the end of time therefore
        -- we cannot extend the end date
        hr_utility.set_message(801, 'HR_7188_DT_DATE_IS_EOT');
        hr_utility.raise_error;
      END IF;
  END IF;

  IF p_delete_next_change = TRUE THEN
   -- Providing the current effective end date is not the end of time
   -- then we must set the validation dates
    IF (l_effective_rows(l_date_from_row_idx).effective_end_date <>
        dt_api.g_eot) THEN
      -- check to see if future rows exist
      IF l_effective_rows.COUNT > l_date_from_row_idx THEN
        -- future rows exist so set the future effective end date
        -- to the end date of the next datetrack row after the row for the
        -- effective date
        l_future_effective_end_date :=
          l_effective_rows(l_date_from_row_idx + 1).effective_end_date;
      ELSE
        -- although the date should be NULL because it has not been set we'll set
        -- it anyway for readability and defensive style coding
        l_future_effective_end_date := NULL;
      END IF;
      -- To determine the validation end date we must take the minimum date
      -- from the following three possible dates:
      -- 1: Minimum parent entity entity end date
      -- 2: If future rows exist then the effective end date of the next row
      -- 3: If no future rows exist then the end of time
      l_validation_end_date :=
        LEAST
        (l_parent_min_date,NVL(l_future_effective_end_date,dt_api.g_eot));
      -- if the validation end date is set to the current effective end date
      -- then we must error as we cannot extend the end date of the current
      -- row
      IF (l_validation_end_date <=
          l_effective_rows(l_date_from_row_idx).effective_end_date) THEN
        hr_utility.set_message(801, 'HR_7187_DT_CANNOT_EXTEND_END');
        hr_utility.set_message_token('DT_MODE', ' delete next change');
        hr_utility.raise_error;
      ELSE
        -- set the OUT validation params
        -- set the validation start date to the current effective end date + 1
        p_del_next_start_date :=
          l_effective_rows(l_date_from_row_idx).effective_end_date + 1;
        p_del_next_end_date := l_validation_end_date;
      END IF;
    ELSE
      -- the current effective end date is alreay the end of time therefore
      -- we cannot extend the end date
      hr_utility.set_message(801, 'HR_7188_DT_DATE_IS_EOT');
      hr_utility.raise_error;
    END IF;
  END IF;


  IF g_debug THEN
    Hr_Utility.Set_Location('Leaving :'||l_proc, 30);
  END IF;

exception
   when others then
   -- set all OUTs to NULL and RAISE
     p_zap := null;
     p_delete := null;
     p_future_change := null;
     p_delete_next_change := null;
     p_zap_start_date := null;
     p_zap_end_date   := null;
     p_delete_start_date := null;
     p_delete_end_date   := null;
     p_del_future_start_date := null;
     p_del_future_end_date   := null;
     p_del_next_start_date := null;
     p_del_next_end_date   := null;
     RAISE;
end find_dt_del_modes_and_dates;
END dt_api;

/
