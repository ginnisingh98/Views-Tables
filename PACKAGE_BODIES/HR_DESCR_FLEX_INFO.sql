--------------------------------------------------------
--  DDL for Package Body HR_DESCR_FLEX_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DESCR_FLEX_INFO" 
/* $Header: hrdflinf.pkb 120.0 2005/05/30 23:38:42 appldev noship $ */
AS
  --
  -- Global variables
  --
  g_application_short_name1      fnd_application.application_short_name%TYPE;
  g_descriptive_flexfield_name1  fnd_descriptive_flexs.descriptive_flexfield_name%TYPE;
  g_field_name_prefix            VARCHAR2(30);
  g_default_context_field_name   fnd_descriptive_flexs.default_context_field_name%TYPE;
  g_context_column_name          fnd_descriptive_flexs.context_column_name%TYPE;
  g_application_id2              fnd_descriptive_flexs.application_id%TYPE;
  g_descriptive_flexfield_name2  fnd_descriptive_flexs.descriptive_flexfield_name%TYPE;
  g_segments                     t_segments := t_segments();
--
-- -----------------------------------------------------------------------------
-- |-----------------------< default_context_field_name >----------------------|
-- -----------------------------------------------------------------------------
FUNCTION default_context_field_name
  (p_application_short_name       IN     fnd_application.application_short_name%TYPE
  ,p_descriptive_flexfield_name   IN     fnd_descriptive_flexs.descriptive_flexfield_name%TYPE
  ,p_field_name_prefix            IN     VARCHAR2 DEFAULT NULL
  )
RETURN fnd_descriptive_flexs.default_context_field_name%TYPE
IS
  --
  -- Local cursors
  --
  CURSOR csr_descriptive_flexs
    (p_application_short_name       IN     fnd_application.application_short_name%TYPE
    ,p_descriptive_flexfield_name   IN     fnd_descriptive_flexs.descriptive_flexfield_name%TYPE
    )
  IS
    SELECT dfl.default_context_field_name
          ,dfl.context_column_name
      FROM fnd_descriptive_flexs dfl
          ,fnd_application app
     WHERE dfl.application_id = app.application_id
       AND app.application_short_name = p_application_short_name
       AND dfl.descriptive_flexfield_name = p_descriptive_flexfield_name;
  l_descriptive_flex csr_descriptive_flexs%ROWTYPE;
--
BEGIN
  --
  IF    (p_application_short_name = g_application_short_name1)
    AND (p_descriptive_flexfield_name = g_descriptive_flexfield_name1)
    AND (NVL(p_field_name_prefix,hr_api.g_varchar2) = NVL(g_field_name_prefix,hr_api.g_varchar2))
  THEN
    --
    -- The last default context field name cached was for this descriptive
    -- flexfield, so no need to get it from the database again
    --
    NULL;
  --
  ELSE
    --
    -- The last default context field name cached was NOT for this descriptive
    -- flexfield, so need to get it from the database and cache it
    --
    OPEN csr_descriptive_flexs
      (p_application_short_name       => p_application_short_name
      ,p_descriptive_flexfield_name   => p_descriptive_flexfield_name
      );
    FETCH csr_descriptive_flexs INTO l_descriptive_flex;
    CLOSE csr_descriptive_flexs;
    --
    IF (l_descriptive_flex.default_context_field_name IS NOT NULL) THEN
      g_default_context_field_name := l_descriptive_flex.default_context_field_name;
    ELSIF (l_descriptive_flex.context_column_name IS NOT NULL) THEN
      g_default_context_field_name := p_field_name_prefix||l_descriptive_flex.context_column_name;
    ELSE
      g_default_context_field_name := NULL;
    END IF;
    g_context_column_name := p_field_name_prefix||l_descriptive_flex.context_column_name;
    --
    g_application_short_name1 := p_application_short_name;
    g_descriptive_flexfield_name1 := p_descriptive_flexfield_name;
    g_field_name_prefix := p_field_name_prefix;
  --
  END IF;
  --
  RETURN(g_default_context_field_name);
--
END default_context_field_name;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< context_column_name >--------------------------|
-- -----------------------------------------------------------------------------
FUNCTION context_column_name
  (p_application_short_name       IN     fnd_application.application_short_name%TYPE
  ,p_descriptive_flexfield_name   IN     fnd_descriptive_flexs.descriptive_flexfield_name%TYPE
  ,p_field_name_prefix            IN     VARCHAR2 DEFAULT NULL
  )
RETURN fnd_descriptive_flexs.context_column_name%TYPE
IS
  --
  -- Local cursors
  --
  CURSOR csr_descriptive_flexs
    (p_application_short_name       IN     fnd_application.application_short_name%TYPE
    ,p_descriptive_flexfield_name   IN     fnd_descriptive_flexs.descriptive_flexfield_name%TYPE
    )
  IS
    SELECT dfl.default_context_field_name
          ,dfl.context_column_name
      FROM fnd_descriptive_flexs dfl
          ,fnd_application app
     WHERE dfl.application_id = app.application_id
       AND app.application_short_name = p_application_short_name
       AND dfl.descriptive_flexfield_name = p_descriptive_flexfield_name;
  l_descriptive_flex csr_descriptive_flexs%ROWTYPE;
--
BEGIN
  IF    (p_application_short_name = g_application_short_name1)

    AND (p_descriptive_flexfield_name = g_descriptive_flexfield_name1)
    AND (NVL(p_field_name_prefix,hr_api.g_varchar2) = NVL(g_field_name_prefix,hr_api.g_varchar2))
  THEN
    --
    -- The last context column name cached was for this descriptive flexfield
    -- so no need to get it from the database again
    --
    NULL;
  --
  ELSE
    --
    -- The last default context field name cached was NOT for this descriptive
    -- flexfield, so need to get it from the database and cache it
    --
    OPEN csr_descriptive_flexs
      (p_application_short_name       => p_application_short_name
      ,p_descriptive_flexfield_name   => p_descriptive_flexfield_name
      );
    FETCH csr_descriptive_flexs INTO l_descriptive_flex;
    CLOSE csr_descriptive_flexs;
    --
    IF (l_descriptive_flex.default_context_field_name IS NOT NULL) THEN
      g_default_context_field_name := l_descriptive_flex.default_context_field_name;
    ELSIF (l_descriptive_flex.context_column_name IS NOT NULL) THEN
      g_default_context_field_name := p_field_name_prefix||l_descriptive_flex.context_column_name;
    ELSE
      g_default_context_field_name := NULL;
    END IF;
    g_context_column_name := p_field_name_prefix||l_descriptive_flex.context_column_name;
    --
    g_application_short_name1 := p_application_short_name;
    g_descriptive_flexfield_name1 := p_descriptive_flexfield_name;
    g_field_name_prefix := p_field_name_prefix;
  --
  END IF;
  --
  RETURN(g_context_column_name);
--
END context_column_name;
--
-- -----------------------------------------------------------------------------
-- |--------------------------------< segments >-------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION segments
  (p_application_id               IN     fnd_descriptive_flexs.application_id%TYPE
  ,p_descriptive_flexfield_name   IN     fnd_descriptive_flexs.descriptive_flexfield_name%TYPE
  )
RETURN t_segments
IS
  --
  -- Local cursors
  --
  CURSOR csr_columns
    (p_application_id               IN     fnd_descriptive_flexs.application_id%TYPE
    ,p_descriptive_flexfield_name   IN     fnd_descriptive_flexs.descriptive_flexfield_name%TYPE
    )
  IS
    SELECT col.column_name
      FROM fnd_columns col
          ,fnd_tables tbl
          ,fnd_descriptive_flexs flx
     WHERE col.flexfield_usage_code = 'D'
       AND col.flexfield_application_id = flx.application_id
       AND col.flexfield_name = flx.descriptive_flexfield_name
       AND col.table_id = tbl.table_id
       AND col.application_id = tbl.application_id
       AND tbl.application_id = flx.table_application_id
       AND tbl.table_name = flx.application_table_name
       AND flx.application_id = p_application_id
       AND flx.descriptive_flexfield_name = p_descriptive_flexfield_name;
  --
  -- Local variables
  --
  l_segments                     t_segments := t_segments();
--
BEGIN
  IF    (p_application_id = g_application_id2)
    AND (p_descriptive_flexfield_name = g_descriptive_flexfield_name2)
  THEN
    --
    l_segments := g_segments;
  --
  ELSE
    --
    FOR l_column in csr_columns
      (p_application_id               => p_application_id
      ,p_descriptive_flexfield_name   => p_descriptive_flexfield_name
      )
    LOOP
      --
      -- Add segment to table
      --
      l_segments.EXTEND;
      l_segments(l_segments.LAST).column_name := l_column.column_name;
    --
    END LOOP;
    --
    g_application_id2 := p_application_id;
    g_descriptive_flexfield_name2 := p_descriptive_flexfield_name;
    g_segments := l_segments;
  --
  END IF;
  --
  RETURN(l_segments);
--
END segments;
--
END hr_descr_flex_info;

/
