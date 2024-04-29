--------------------------------------------------------
--  DDL for Package Body HR_FLEX_VALUE_SET_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FLEX_VALUE_SET_INFO" 
/* $Header: hrfvsinf.pkb 120.2 2005/09/08 22:49:06 ghshanka noship $ */
AS
-- -----------------------------------------------------------------------------
-- |-------------------------< parent_value_set_name >-------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns the name of the parent flexfield value set for the
--   specified flexfield value set.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_flex_value_set_id            Y    number   Flexfield value set identifier
--
-- Post Success
--   The name of the parent flexfield value set is returned.
--
-- Post Failure
--   An error is raised.
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION parent_value_set_name
  (p_flex_value_set_id            IN     fnd_flex_value_sets.flex_value_set_id%TYPE
  )
RETURN fnd_flex_value_sets.flex_value_set_name%TYPE
IS
  --
  -- Local cursors
  --
  CURSOR csr_value_sets
    (p_flex_value_set_id            IN     fnd_flex_value_sets.flex_value_set_id%TYPE
    )
  IS
    SELECT ind.flex_value_set_name parent_value_set_name
      FROM fnd_flex_value_sets ind
          ,fnd_flex_value_sets dep
     WHERE ind.flex_value_set_id = dep.parent_flex_value_set_id
       AND dep.flex_value_set_id = p_flex_value_set_id;
  --
  -- Local variables
  --
  l_value_set                    csr_value_sets%ROWTYPE;
--
BEGIN
  --
  -- Retrive parent flexfield value set name
  --
  OPEN csr_value_sets
    (p_flex_value_set_id            => p_flex_value_set_id
    );
  FETCH csr_value_sets INTO l_value_set;
  CLOSE csr_value_sets;
  --
  RETURN(l_value_set.parent_value_set_name);
--
END parent_value_set_name;
--
-- -----------------------------------------------------------------------------
-- |------------------------< additional_column_title >------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns the additional column title. If the column title is
--   in a format which suggests it is to be derived from a message:
--   APPL=<application_short_name>;NAME=<message_name>
--   the message text is returned; otherwise the value passed in is returned.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_additional_column_title      Y    varchar2 Additional column title
--
-- Post Success
--   The additional column title is returned.
--
-- Post Failure
--   The value passed in is returned. No error is raised.
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION additional_column_title
  (p_additional_column_title      IN     VARCHAR2
  )
RETURN VARCHAR2
IS
  --
  -- Local variables
  --
  l_additional_column_title      VARCHAR2(2000)                              := p_additional_column_title;
  l_application_short_name       fnd_application.application_short_name%TYPE;
  l_message_name                 fnd_new_messages.message_name%TYPE;
  l_application_indicator        VARCHAR2(30)                                := 'APPL=';
  l_message_indicator            VARCHAR2(30)                                := 'NAME=';
  l_separator                    VARCHAR2(30)                                := ';';
  l_application_indicator_len    NUMBER                                      := LENGTH(l_application_indicator);
  l_message_indicator_len        NUMBER                                      := LENGTH(l_message_indicator);
  l_separator_len                NUMBER                                      := LENGTH(l_separator);
  l_application_indicator_pos    NUMBER;
  l_message_indicator_pos        NUMBER;
  l_separator_pos                NUMBER;
  l_application_short_name_pos   NUMBER;
  l_message_name_pos             NUMBER;
--
BEGIN
  --
  -- Determine position of indicators
  --
  l_application_indicator_pos := INSTRB(l_additional_column_title,l_application_indicator,1,1);
  l_message_indicator_pos     := INSTRB(l_additional_column_title,l_message_indicator,1,1);
  l_separator_pos             := INSTRB(l_additional_column_title,l_separator,1,1);
  --
  -- If indicators are present, suggests additional column title is to be
  -- derived from a message
  --
  IF    (l_application_indicator_pos <> 0)
    AND (l_message_indicator_pos <> 0)
    AND (l_separator_pos <> 0)
  THEN
    l_application_short_name_pos := l_application_indicator_pos + l_application_indicator_len;
    l_message_name_pos := l_message_indicator_pos + l_message_indicator_len;
    l_application_short_name := SUBSTRB(l_additional_column_title,l_application_short_name_pos,l_separator_pos-l_application_short_name_pos-1);
    l_message_name := SUBSTRB(l_additional_column_title,l_message_name_pos);
    fnd_message.set_name(l_application_short_name,l_message_name);
    l_additional_column_title := fnd_message.get;
  END IF;
  --
  RETURN(l_additional_column_title);
--
EXCEPTION
  --
  -- Return value passed in on any failure
  --
  WHEN OTHERS
  THEN
    RETURN(p_additional_column_title);
--
END additional_column_title;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< get_additional_column  >------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This procedure returns the details of the nth additional column specified
--   in the additional quickpick columns. The additional columns should be
--   specified in the form:
--   <additional_column> "<additional_column_title>" (<additional_column_width>) , ...
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_additional_quickpick_columns Y    varchar2 Additional column title
--   p_column_number                Y    number   Number of additional column
--                                                for which details should be
--                                                determined.
--
-- Post Success
--   The following out parameters are set:
--   Name                           Type     Description
--   p_additional_column            varchar2 Additional column
--   p_additional_column_title      varchar2 Additional column title
--   p_additional_column_width      varchar2 Additional column width
--
-- Post Failure
--   An error is raised.
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
PROCEDURE get_additional_column
  (p_additional_quickpick_columns IN     fnd_flex_validation_tables.additional_quickpick_columns%TYPE
  ,p_column_number                IN     NUMBER
  ,p_additional_column               OUT NOCOPY VARCHAR2
  ,p_additional_column_title         OUT NOCOPY VARCHAR2
  ,p_additional_column_width         OUT NOCOPY VARCHAR2
  )
IS
  --
  -- Local variables
  --
  l_additional_quickpick_columns fnd_flex_validation_tables.additional_quickpick_columns%TYPE := p_additional_quickpick_columns;
  l_additional_column            VARCHAR2(2000) := NULL;
  l_additional_column_title      VARCHAR2(2000) := NULL;
  l_additional_column_width      VARCHAR2(2000) := NULL;
  l_column_number                NUMBER         := 0;
  l_first_quote_pos              NUMBER;
  l_second_quote_pos             NUMBER;
  l_first_bracket_pos            NUMBER;
  l_second_bracket_pos           NUMBER;
  l_separator_pos                NUMBER;
--
BEGIN
  --
  -- Assume each additional column must have a title in quotes. Cannot use the
  -- separator character as this may be used in the additional column if it
  -- is a function eg DECODE(attribute,'N',0,1)
  --
  l_first_quote_pos := INSTRB(l_additional_quickpick_columns,'"',1,1);
  WHILE (l_first_quote_pos <> 0)
    AND (l_column_number <> p_column_number)
  LOOP
    l_column_number := l_column_number + 1;
    l_second_quote_pos := INSTRB(l_additional_quickpick_columns,'"',l_first_quote_pos+1,1);
    l_first_bracket_pos := INSTRB(l_additional_quickpick_columns,'(',l_second_quote_pos,1);
    l_second_bracket_pos := INSTRB(l_additional_quickpick_columns,')',l_second_quote_pos,1);
    l_separator_pos := INSTRB(l_additional_quickpick_columns,',',l_second_quote_pos,1);
    --
    -- Only determine details if this is the column number interested in
    --
    IF (l_column_number = p_column_number)
    THEN
      l_additional_column := SUBSTRB(l_additional_quickpick_columns,1,l_first_quote_pos-1);
      l_additionaL_column_title := SUBSTRB(l_additional_quickpick_columns,l_first_quote_pos+1,l_second_quote_pos-l_first_quote_pos-1);
      l_additional_column_title := additional_column_title(l_additional_column_title);
      l_additional_column_width := NULL;
      --
      -- Additional column width is optional; so only retrieve if it is
      -- specified ie brackets exist
      --
      IF    (l_first_bracket_pos <> 0)
        AND (  (l_first_bracket_pos < l_separator_pos)
            OR (l_separator_pos = 0))
      THEN
        l_additional_column_width := SUBSTRB(l_additional_quickpick_columns,l_first_bracket_pos+1,l_second_bracket_pos-l_first_bracket_pos-1);
      END IF;
    END IF;
    --
    -- If no separator found must be last additional column specified; so set
    -- internal variable to NULL
    --
    IF (l_separator_pos <> 0)
    THEN
      l_additional_quickpick_columns := SUBSTRB(l_additional_quickpick_columns,l_separator_pos+1);
    ELSE
      l_additional_quickpick_columns := NULL;
    END IF;
    --
    l_first_quote_pos := INSTRB(l_additional_quickpick_columns,'"',1,1);
  --
  END LOOP;
  --
  -- Populate out parameters
  --
  p_additional_column := l_additional_column;
  p_additional_column_title := l_additional_column_title;
  p_additional_column_width := l_additional_column_width;
--
END get_additional_column;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< get_table_sql >-----------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This procedure returns the details of the SQL to be used for a value set
--   based on a validation table.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_flex_value_set_id            Y    number   Flexfield value set identifier
--   p_flex_value_set_name          Y    varchar2 Flexfield value set name
--   p_effective_date               Y    date     Effective date
--
-- Post Success
--   The following out parameters are set:
--   Name                           Type     Description
--   p_validation_sql               varchar2 SQL statement to be used in
--                                           validation. The flexfield should
--                                           have one of the values returned
--                                           by the statement.
--   p_identification_sql           varchar2 SQL statement to be used in
--                                           identification. It should return
--                                           one and only one record.
--   p_id_column_type               varchar2 Datatype of the id column
--   p_has_meaning                  boolean  Does the SQL contain a meaning
--                                           column?
--   p_additional_column1_title     varchar2 Additional column title (1)
--   p_additional_column1_width     varchar2 Additional column width (1)
--   p_additional_column2_title     varchar2 Additional column title (2)
--   p_additional_column2_width     varchar2 Additional column width (2)
--   p_additional_column3_title     varchar2 Additional column title (3)
--   p_additional_column3_width     varchar2 Additional column width (3)
--
-- Post Failure
--   An error is raised.
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
PROCEDURE get_table_sql
  (p_flex_value_set_id            IN     fnd_flex_value_sets.flex_value_set_id%TYPE
  ,p_flex_value_set_name          IN     fnd_flex_value_sets.flex_value_set_name%TYPE
  ,p_effective_date               IN     DATE
  ,p_validation_sql                  OUT NOCOPY VARCHAR2
  ,p_identification_sql              OUT NOCOPY VARCHAR2
  ,p_id_column_type                  OUT NOCOPY VARCHAR2
  ,p_has_meaning                     OUT NOCOPY BOOLEAN
  ,p_additional_column1_title        OUT NOCOPY VARCHAR2
  ,p_additional_column1_width        OUT NOCOPY VARCHAR2
  ,p_additional_column2_title        OUT NOCOPY VARCHAR2
  ,p_additional_column2_width        OUT NOCOPY VARCHAR2
  ,p_additional_column3_title        OUT NOCOPY VARCHAR2
  ,p_additional_column3_width        OUT NOCOPY VARCHAR2
  )
IS
  --
  --Bug# 3011981 Start Here
  --Description : Changed the value_column_type to value_column_name to create the dynamic query.
  --
  -- Local cursors
  --
  CURSOR csr_validation_tables
    (p_flex_value_set_id            IN     fnd_flex_value_sets.flex_value_set_id%TYPE
    ,p_flex_value_set_name          IN     fnd_flex_value_sets.flex_value_set_name%TYPE
    )
  IS
    SELECT DECODE(fvt.value_column_type
                 ,'D','fnd_date.date_to_displaydate('||fvt.value_column_name||')'
                 ,'N',fvt.value_column_name
                 ,fvt.value_column_name
                 ) AS value_column_name
          ,NVL(fvt.meaning_column_name,'NULL') AS meaning_column_name
          ,DECODE(NVL(fvt.id_column_type,fvt.value_column_type)
                 ,'D','fnd_date.date_to_canonical('||NVL(fvt.id_column_name,fvt.value_column_name)||')'
                 ,'N','fnd_number.number_to_canonical('||NVL(fvt.id_column_name,fvt.value_column_name)||')'
                 ,NVL(fvt.id_column_name,fvt.value_column_name)
                 ) AS id_column_name
          ,NVL(fvt.id_column_type,fvt.value_column_type) AS id_column_type
          ,'AND '||NVL(fvt.id_column_name,fvt.value_column_name)||' = :$FLEX$.$$'||p_flex_value_set_name AS identification_clause
          ,fvt.application_table_name AS from_clause
          ,fvt.additional_where_clause AS where_and_order_clause
          ,fvt.additional_where_clause AS where_clause
          ,fvt.additional_where_clause AS order_clause
          ,fvt.start_date_column_name
          ,fvt.end_date_column_name
          ,fvt.additional_quickpick_columns
      FROM fnd_flex_validation_tables fvt
     WHERE fvt.flex_value_set_id = p_flex_value_set_id;
     --
     --Bug# 3011981 End Here
     --
  --
  -- Local variables
  --
  l_effective_date               VARCHAR2(32767);
  l_order_clause_position        NUMBER;
  l_additional_column1           VARCHAR2(2000);
  l_additional_column2           VARCHAR2(2000);
  l_additional_column3           VARCHAR2(2000);
--
BEGIN
  --
  -- Creating a character string for the SQL, so date should be converted to
  -- character consistently
  --
  l_effective_date := 'fnd_date.canonical_to_date('''||fnd_date.date_to_canonical(p_effective_date)||''')';
  --
  FOR l_validation_table IN csr_validation_tables
    (p_flex_value_set_id            => p_flex_value_set_id
    ,p_flex_value_set_name          => p_flex_value_set_name
    )
  LOOP
    --
    l_order_clause_position := INSTRB(UPPER(l_validation_table.where_and_order_clause),'ORDER BY');
    IF (l_order_clause_position > 0)
    THEN
      --
      -- ORDER BY clause already specified, split into the constituent WHERE and
      -- ORDER BY statements
      --
      l_validation_table.where_clause := SUBSTRB(l_validation_table.where_and_order_clause,1,l_order_clause_position - 1);
      l_validation_table.order_clause := SUBSTRB(l_validation_table.where_and_order_clause,l_order_clause_position);
    --
    ELSE
      --
      -- ORDER BY clause NOT specified, so add the default clause
      --
      l_validation_table.where_clause := l_validation_table.where_and_order_clause;
      l_validation_table.order_clause := 'ORDER BY 1';
    --
    END IF;
    --
    -- Add effective date validation to WHERE clause
    --
    IF (l_validation_table.where_clause IS NULL)
    THEN
      l_validation_table.where_clause := 'WHERE '||l_effective_date||' BETWEEN NVL('||l_validation_table.start_date_column_name||','||l_effective_date||')'
                                                                       ||' AND NVL('||l_validation_table.end_date_column_name||','||l_effective_date||')';
    ELSE
      l_validation_table.where_clause := l_validation_table.where_clause
                                        ||' AND '||l_effective_date||' BETWEEN NVL('||l_validation_table.start_date_column_name||','||l_effective_date||')'
                                                                       ||' AND NVL('||l_validation_table.end_date_column_name||','||l_effective_date||')';
    END IF;
    --
    -- Determine the first 3 additional columns, if any
    --
    get_additional_column(l_validation_table.additional_quickpick_columns,1,l_additional_column1,p_additional_column1_title,p_additional_column1_width);
    get_additional_column(l_validation_table.additional_quickpick_columns,2,l_additional_column2,p_additional_column2_title,p_additional_column2_width);
    get_additional_column(l_validation_table.additional_quickpick_columns,3,l_additional_column3,p_additional_column3_title,p_additional_column3_width);
    --
    -- Build up SQL SELECT statements
    --
    p_validation_sql := 'SELECT '||l_validation_table.value_column_name
                           ||' ,'||l_validation_table.meaning_column_name
                           ||' ,'||l_validation_table.id_column_name||' AS id'
                           ||' ,'||NVL(l_additional_column1,'NULL')
                           ||' ,'||NVL(l_additional_column2,'NULL')
                           ||' ,'||NVL(l_additional_column3,'NULL')
                       ||' FROM '||l_validation_table.from_clause
                            ||' '||l_validation_table.where_clause
                            ||' '||l_validation_table.order_clause;
    p_identification_sql := 'SELECT '||l_validation_table.value_column_name
                               ||' ,'||l_validation_table.meaning_column_name
                               ||' ,'||l_validation_table.id_column_name
                               ||' ,NULL'
                               ||' ,NULL'
                               ||' ,NULL'
                           ||' FROM '||l_validation_table.from_clause
                                ||' '||l_validation_table.where_clause
                                ||' '||l_validation_table.identification_clause;
    --
    -- Determine if a meaning column has been specified
    --
    p_has_meaning := FALSE;
    IF (l_validation_table.meaning_column_name <> 'NULL')
    THEN
      p_has_meaning := TRUE;
    END IF;
    --
    -- Populate other out parameters
    --
    p_id_column_type := l_validation_table.id_column_type;
  --
  END LOOP;
--
END get_table_sql;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< get_independent_sql >--------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This procedure returns the details of the SQL to be used for an independent
--   value set.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_flex_value_set_id            Y    number   Flexfield value set identifier
--   p_flex_value_set_name          Y    varchar2 Flexfield value set name
--   p_effective_date               Y    date     Effective date
--
-- Post Success
--   The following out parameters are set:
--   Name                           Type     Description
--   p_validation_sql               varchar2 SQL statement to be used in
--                                           validation. The flexfield should
--                                           have one of the values returned
--                                           by the statement.
--   p_identification_sql           varchar2 SQL statement to be used in
--                                           identification. It should return
--                                           one and only one record.
--   p_has_meaning                  boolean  Does the SQL contain a meaning
--                                           column?
--
-- Post Failure
--   An error is raised.
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
PROCEDURE get_independent_sql
  (p_flex_value_set_id            IN     fnd_flex_value_sets.flex_value_set_id%TYPE
  ,p_flex_value_set_name          IN     fnd_flex_value_sets.flex_value_set_name%TYPE
  ,p_effective_date               IN     DATE
  ,p_validation_sql                  OUT NOCOPY VARCHAR2
  ,p_identification_sql              OUT NOCOPY VARCHAR2
  ,p_has_meaning                     OUT NOCOPY BOOLEAN
  )
IS
  --
  -- Local variables
  --
  l_effective_date               VARCHAR2(32767);
  l_validation_sql               VARCHAR2(32767);
  l_identification_sql           VARCHAR2(32767);
--
BEGIN
  --
  -- Creating a character string for the SQL, so date should be converted to
  -- character consistently
  --
  l_effective_date := 'fnd_date.canonical_to_date('''||fnd_date.date_to_canonical(p_effective_date)||''')';
  --
  -- Build up SQL SELECT statements
  --
  p_validation_sql := 'SELECT ffv.flex_value_meaning'
                         ||' ,ffv.description'
                         ||' ,ffv.flex_value'
                         ||' ,NULL'
                         ||' ,NULL'
                         ||' ,NULL'
                     ||' FROM fnd_flex_values_vl ffv'
                    ||' WHERE ffv.flex_value_set_id = fnd_number.canonical_to_number('||fnd_number.number_to_canonical(p_flex_value_set_id)||')'
                      ||' AND '||l_effective_date||' BETWEEN NVL(ffv.start_date_active,'||l_effective_date||')'
                                                     ||' AND NVL(ffv.end_date_active,'||l_effective_date||')'
                      ||' AND ffv.enabled_flag = ''Y'''
                 ||' ORDER BY ffv.flex_value';
  p_identification_sql := 'SELECT ffv.flex_value_meaning'
                             ||' ,ffv.description'
                             ||' ,ffv.flex_value'
                             ||' ,NULL'
                             ||' ,NULL'
                             ||' ,NULL'
                         ||' FROM fnd_flex_values_vl ffv'
                        ||' WHERE ffv.flex_value_set_id = fnd_number.canonical_to_number('||fnd_number.number_to_canonical(p_flex_value_set_id)||')'
                          -- ||' AND '||l_effective_date||' BETWEEN NVL(ffv.start_date_active,'||l_effective_date||')'
                                                        -- ||' AND NVL(ffv.end_date_active,'||l_effective_date||')'
                         -- ||' AND ffv.enabled_flag = ''Y'''
                          ||' AND ffv.flex_value = :$FLEX$.'||p_flex_value_set_name;
  --
  -- bug 4565427 commented out the conditions that validate the date and enabled flag
  -- in the above sql so  that it retrives the already saved value for a person against an information type.

  -- Independent value sets always have a meaning
  --
  p_has_meaning := TRUE;
--
END get_independent_sql;
--
-- -----------------------------------------------------------------------------
-- |---------------------------< get_dependent_sql >---------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This procedure returns the details of the SQL to be used for a dependent
--   value set.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_flex_value_set_id            Y    number   Flexfield value set identifier
--   p_flex_value_set_name          Y    varchar2 Flexfield value set name
--   p_effective_date               Y    date     Effective date
--
-- Post Success
--   The following out parameters are set:
--   Name                           Type     Description
--   p_validation_sql               varchar2 SQL statement to be used in
--                                           validation. The flexfield should
--                                           have one of the values returned
--                                           by the statement.
--   p_identification_sql           varchar2 SQL statement to be used in
--                                           identification. It should return
--                                           one and only one record.
--   p_has_meaning                  boolean  Does the SQL contain a meaning
--                                           column?
--
-- Post Failure
--   An error is raised.
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
PROCEDURE get_dependent_sql
  (p_flex_value_set_id            IN     fnd_flex_value_sets.flex_value_set_id%TYPE
  ,p_flex_value_set_name          IN     fnd_flex_value_sets.flex_value_set_name%TYPE
  ,p_effective_date               IN     DATE
  ,p_validation_sql                  OUT NOCOPY VARCHAR2
  ,p_identification_sql              OUT NOCOPY VARCHAR2
  ,p_has_meaning                     OUT NOCOPY BOOLEAN
  )
IS
  --
  -- Local variables
  --
  l_effective_date               VARCHAR2(32767);
  l_validation_sql               VARCHAR2(32767);
  l_identification_sql           VARCHAR2(32767);
  l_parent_value_set_name        VARCHAR2(32767);
--
BEGIN
  --
  -- Creating a character string for the SQL, so date should be converted to
  -- character consistently
  --
  l_effective_date := 'fnd_date.canonical_to_date('''||fnd_date.date_to_canonical(p_effective_date)||''')';
  --
  -- Determine parent value set name
  --
  l_parent_value_set_name := ':$FLEX$.'||parent_value_set_name(p_flex_value_set_id);
  --
  -- Build up SQL SELECT statements
  --
  p_validation_sql := 'SELECT ffv.flex_value_meaning'
                         ||' ,ffv.description'
                         ||' ,ffv.flex_value'
                         ||' ,NULL'
                         ||' ,NULL'
                         ||' ,NULL'
                     ||' FROM fnd_flex_values_vl ffv'
                    ||' WHERE ffv.flex_value_set_id = fnd_number.canonical_to_number('||fnd_number.number_to_canonical(p_flex_value_set_id)||')'
                      ||' AND '||l_effective_date||' BETWEEN NVL(ffv.start_date_active,'||l_effective_date||')'
                                                     ||' AND NVL(ffv.end_date_active,'||l_effective_date||')'
                      ||' AND ffv.enabled_flag = ''Y'''
                      ||' AND ffv.parent_flex_value_low = '||l_parent_value_set_name
                 ||' ORDER BY ffv.flex_value';
  p_identification_sql := 'SELECT ffv.flex_value_meaning'
                             ||' ,ffv.description'
                             ||' ,ffv.flex_value'
                             ||' ,NULL'
                             ||' ,NULL'
                             ||' ,NULL'
                         ||' FROM fnd_flex_values_vl ffv'
                        ||' WHERE ffv.flex_value_set_id = fnd_number.canonical_to_number('||fnd_number.number_to_canonical(p_flex_value_set_id)||')'
                          ||' AND '||l_effective_date||' BETWEEN NVL(ffv.start_date_active,'||l_effective_date||')'
                                                         ||' AND NVL(ffv.end_date_active,'||l_effective_date||')'
                          ||' AND ffv.enabled_flag = ''Y'''
                          ||' AND ffv.parent_flex_value_low = '||l_parent_value_set_name
                          ||' AND ffv.flex_value = :$FLEX$.'||p_flex_value_set_name;
  --
  -- Dependent value sets always have a meaning
  --
  p_has_meaning := TRUE;
--
END get_dependent_sql;
--
-- -----------------------------------------------------------------------------
-- |--------------------------------< get_sql >--------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This procedure returns the details of the SQL to be used for a value set.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_flex_value_set_id            Y    number   Flexfield value set identifier
--   p_flex_value_set_name          Y    varchar2 Flexfield value set name
--   p_effective_date               Y    date     Effective date
--
-- Post Success
--   The following out parameters are set:
--   Name                           Type     Description
--   p_validation_sql               varchar2 SQL statement to be used in
--                                           validation. The flexfield should
--                                           have one of the values returned
--                                           by the statement.
--   p_identification_sql           varchar2 SQL statement to be used in
--                                           identification. It should return
--                                           one and only one record.
--   p_id_column_type               varchar2 Datatype of the id column
--   p_has_meaning                  boolean  Does the SQL contain a meaning
--                                           column?
--   p_additional_column1_title     varchar2 Additional column title (1)
--   p_additional_column1_width     varchar2 Additional column width (1)
--   p_additional_column2_title     varchar2 Additional column title (2)
--   p_additional_column2_width     varchar2 Additional column width (2)
--   p_additional_column3_title     varchar2 Additional column title (3)
--   p_additional_column3_width     varchar2 Additional column width (3)
--
-- Post Failure
--   An error is raised.
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
PROCEDURE get_sql
  (p_flex_value_set_id            IN     fnd_flex_value_sets.flex_value_set_id%TYPE
  ,p_flex_value_set_name          IN     fnd_flex_value_sets.flex_value_set_name%TYPE
  ,p_validation_type              IN     fnd_flex_value_sets.validation_type%TYPE
  ,p_effective_date               IN     DATE
  ,p_validation_sql                  OUT NOCOPY VARCHAR2
  ,p_identification_sql              OUT NOCOPY VARCHAR2
  ,p_id_column_type                  OUT NOCOPY VARCHAR2
  ,p_has_meaning                     OUT NOCOPY BOOLEAN
  ,p_additional_column1_title        OUT NOCOPY VARCHAR2
  ,p_additional_column1_width        OUT NOCOPY VARCHAR2
  ,p_additional_column2_title        OUT NOCOPY VARCHAR2
  ,p_additional_column2_width        OUT NOCOPY VARCHAR2
  ,p_additional_column3_title        OUT NOCOPY VARCHAR2
  ,p_additional_column3_width        OUT NOCOPY VARCHAR2
  )
IS
  --
  -- Local variables
  --
  l_table                    CONSTANT fnd_flex_value_sets.validation_type%TYPE := 'F';
  l_dependent                CONSTANT fnd_flex_value_sets.validation_type%TYPE := 'D';
  l_independent              CONSTANT fnd_flex_value_sets.validation_type%TYPE := 'I';
  l_translatable_independent CONSTANT fnd_flex_value_sets.validation_type%TYPE := 'X';
  l_translatable_dependent   CONSTANT fnd_flex_value_sets.validation_type%TYPE := 'Y';
--
BEGIN
  --
  -- Get details based on validation type
  --
  IF    (p_validation_type = l_table)
  THEN
    get_table_sql
      (p_flex_value_set_id            => p_flex_value_set_id
      ,p_flex_value_set_name          => p_flex_value_set_name
      ,p_effective_date               => p_effective_date
      ,p_validation_sql               => p_validation_sql
      ,p_identification_sql           => p_identification_sql
      ,p_id_column_type               => p_id_column_type
      ,p_has_meaning                  => p_has_meaning
      ,p_additional_column1_title     => p_additional_column1_title
      ,p_additional_column1_width     => p_additional_column1_width
      ,p_additional_column2_title     => p_additional_column2_title
      ,p_additional_column2_width     => p_additional_column2_width  -- Bug 3904996
      ,p_additional_column3_title     => p_additional_column3_title
      ,p_additional_column3_width     => p_additional_column3_width
      );
  ELSIF (p_validation_type IN (l_independent,l_translatable_independent))
  THEN
    get_independent_sql
      (p_flex_value_set_id            => p_flex_value_set_id
      ,p_flex_value_set_name          => p_flex_value_set_name
      ,p_effective_date               => p_effective_date
      ,p_validation_sql               => p_validation_sql
      ,p_identification_sql           => p_identification_sql
      ,p_has_meaning                  => p_has_meaning
      );
  ELSIF (p_validation_type IN (l_dependent,l_translatable_dependent))
  THEN
    get_dependent_sql
      (p_flex_value_set_id            => p_flex_value_set_id
      ,p_flex_value_set_name          => p_flex_value_set_name
      ,p_effective_date               => p_effective_date
      ,p_validation_sql               => p_validation_sql
      ,p_identification_sql           => p_identification_sql
      ,p_has_meaning                  => p_has_meaning
      );
  ELSE
    p_validation_sql     := NULL;
    p_identification_sql := NULL;
    p_has_meaning        := FALSE;
  END IF;
--
END get_sql;
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< value_set >-------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION value_set
  (p_flex_value_set_id            IN     fnd_flex_value_sets.flex_value_set_id%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN t_value_set
IS
  --
  -- Local cursors
  --
  CURSOR csr_value_sets
    (p_flex_value_set_id            IN     fnd_flex_value_sets.flex_value_set_id%TYPE
    )
  IS
    SELECT fvs.flex_value_set_id
          ,fvs.alphanumeric_allowed_flag
          ,fvs.flex_value_set_name
          ,fvs.format_type
          ,fvs.longlist_flag
          ,fvs.maximum_size
          ,fvs.maximum_value
          ,fvs.minimum_value
          ,fvs.number_precision
          ,fvs.numeric_mode_enabled_flag
          ,fvs.uppercase_only_flag
          ,fvs.validation_type
      FROM fnd_flex_value_sets fvs
     WHERE fvs.flex_value_set_id = p_flex_value_set_id;
  --
  -- Local variables
  --
  l_value_set                    t_value_set;
--
BEGIN
  --
  FOR l_flex_value_set IN csr_value_sets
    (p_flex_value_set_id            => p_flex_value_set_id
    )
  LOOP
    l_value_set.flex_value_set_id         := l_flex_value_set.flex_value_set_id;
    l_value_set.alphanumeric_allowed_flag := l_flex_value_set.alphanumeric_allowed_flag;
    l_value_set.flex_value_set_name       := l_flex_value_set.flex_value_set_name;
    l_value_set.format_type               := l_flex_value_set.format_type;
    l_value_set.longlist_flag             := l_flex_value_set.longlist_flag;
    l_value_set.maximum_size              := l_flex_value_set.maximum_size;
    l_value_set.maximum_value             := l_flex_value_set.maximum_value;
    l_value_set.minimum_value             := l_flex_value_set.minimum_value;
    l_value_set.number_precision          := l_flex_value_set.number_precision;
    l_value_set.numeric_mode_enabled_flag := l_flex_value_set.numeric_mode_enabled_flag;
    l_value_set.uppercase_only_flag       := l_flex_value_set.uppercase_only_flag;
    l_value_set.validation_type           := l_flex_value_set.validation_type;
    get_sql
      (p_flex_value_set_id            => l_flex_value_set.flex_value_set_id
      ,p_flex_value_set_name          => l_flex_value_set.flex_value_set_name
      ,p_validation_type              => l_flex_value_set.validation_type
      ,p_effective_date               => p_effective_date
      ,p_validation_sql               => l_value_set.validation_sql
      ,p_identification_sql           => l_value_set.identification_sql
      ,p_id_column_type               => l_value_set.id_column_type
      ,p_has_meaning                  => l_value_set.has_meaning
      ,p_additional_column1_title     => l_value_set.additional_column1_title
      ,p_additional_column1_width     => l_value_set.additional_column1_width
      ,p_additional_column2_title     => l_value_set.additional_column2_title
      ,p_additional_column2_width     => l_value_set.additional_column2_width
      ,p_additional_column3_title     => l_value_set.additional_column3_title
      ,p_additional_column3_width     => l_value_set.additional_column3_width
      );
  END LOOP;
  --
  RETURN(l_value_set);
--
END value_set;
--
END hr_flex_value_set_info;

/
