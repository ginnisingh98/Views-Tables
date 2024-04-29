--------------------------------------------------------
--  DDL for Package Body HR_ID_FLEX_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ID_FLEX_INFO" 
/* $Header: hrkflinf.pkb 120.0 2005/05/31 01:05:51 appldev noship $ */
AS
  --
  -- Global variables
  --
  g_application_short_name1      fnd_application.application_short_name%TYPE;
  g_id_flex_code1                fnd_id_flexs.id_flex_code%TYPE;
  g_set_defining_column_name     fnd_id_flexs.set_defining_column_name%TYPE;
  g_application_id2              fnd_id_flexs.application_id%TYPE;
  g_id_flex_code2                fnd_id_flexs.id_flex_code%TYPE;
  g_segments                     t_segments := t_segments();
--
-- -----------------------------------------------------------------------------
-- |--------------------------< defining_column_name >-------------------------|
-- -----------------------------------------------------------------------------
FUNCTION defining_column_name
  (p_application_short_name       IN     fnd_application.application_short_name%TYPE
  ,p_id_flex_code                 IN     fnd_id_flexs.id_flex_code%TYPE
  )
RETURN fnd_id_flexs.set_defining_column_name%TYPE
IS
  --
  -- Local cursors
  --
  CURSOR csr_id_flexs
    (p_application_short_name       IN     fnd_application.application_short_name%TYPE
    ,p_id_flex_code                 IN     fnd_id_flexs.id_flex_code%TYPE
    )
  IS
    SELECT kfl.set_defining_column_name
      FROM fnd_id_flexs kfl
          ,fnd_application app
     WHERE kfl.application_id = app.application_id
       AND app.application_short_name = p_application_short_name
       AND kfl.id_flex_code = p_id_flex_code;
--
BEGIN
  --
  IF    (p_application_short_name = g_application_short_name1)
    AND (p_id_flex_code = g_id_flex_code1)
  THEN
    --
    -- The last defining column name cached was for this key flexfield, so no
    -- need to get it from the database again
    --
    NULL;
  --
  ELSE
    --
    -- The last defining column name cached was NOT for this key flexfield, so
    -- need to get it from the database and cache it
    --
    OPEN csr_id_flexs
      (p_application_short_name       => p_application_short_name
      ,p_id_flex_code                 => p_id_flex_code
      );
    FETCH csr_id_flexs INTO g_set_defining_column_name;
    CLOSE csr_id_flexs;
    --
    g_application_short_name1 := p_application_short_name;
    g_id_flex_code1 := p_id_flex_code;
  --
  END IF;
  --
  RETURN(g_set_defining_column_name);
--
END defining_column_name;
--
-- -----------------------------------------------------------------------------
-- |--------------------------------< segments >-------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION segments
  (p_application_id               IN     fnd_id_flexs.application_id%TYPE
  ,p_id_flex_code                 IN     fnd_id_flexs.id_flex_code%TYPE
  )
RETURN t_segments
IS
  --
  -- Local cursors
  --
  CURSOR csr_columns
    (p_application_id               IN     fnd_id_flexs.application_id%TYPE
    ,p_id_flex_code                 IN     fnd_id_flexs.id_flex_code%TYPE
    )
  IS
    SELECT col.column_name
      FROM fnd_columns col
          ,fnd_tables tbl
          ,fnd_id_flexs flx
     WHERE col.flexfield_usage_code = 'K'
       AND col.table_id = tbl.table_id
       AND col.application_id = tbl.application_id
       AND tbl.application_id = flx.table_application_id
       AND tbl.table_name = flx.application_table_name
       AND flx.application_id = p_application_id
       AND flx.id_flex_code = p_id_flex_code;
  --
  -- Local variables
  --
  l_segments                     t_segments := t_segments();
--
BEGIN
  --
  IF    (p_application_id = g_application_id2)
    AND (p_id_flex_code = g_id_flex_code2)
  THEN
    --
    l_segments := g_segments;
  --
  ELSE
    --
    FOR l_column in csr_columns
      (p_application_id               => p_application_id
      ,p_id_flex_code                 => p_id_flex_code
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
    g_id_flex_code2 := p_id_flex_code;
    g_segments := l_segments;
  --
  END IF;
  --
  RETURN(l_segments);
--
END segments;
--
END hr_id_flex_info;

/
