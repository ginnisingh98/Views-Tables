--------------------------------------------------------
--  DDL for Package Body GL_MC_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_MC_INFO" AS
/* $Header: glmcinfb.pls 120.29.12010000.3 2009/01/05 12:02:14 paragond ship $ */

-- Procedure
--   get_ledger_currency
-- Purpose
--   Get ledger currency code of the passed ledger ID
-- History
--   25-FEB-03 LPOON       Created (New R11i.X procedure)
PROCEDURE get_ledger_currency (n_ledger_id       IN  NUMBER,
                               n_ledger_currency OUT NOCOPY VARCHAR2) IS
BEGIN
   IF pg_ledger_currency_rec.EXISTS(n_ledger_id) THEN
      n_ledger_currency := pg_ledger_currency_rec(n_ledger_id);
   ELSE
      SELECT currency_code
        INTO n_ledger_currency
        FROM gl_ledgers
       WHERE ledger_id = n_ledger_id;

      pg_ledger_currency_rec(n_ledger_id) := n_ledger_currency;
   END IF;
EXCEPTION
   WHEN others THEN
     n_ledger_currency := NULL;
END;


-- Procedure
--   get_alc_ledger_type
-- Purpose
--   Gets ALC ledger type code of the passed ledger ID
-- History
--   25-FEB-03 LPOON       Created (New R11i.X procedure)
PROCEDURE get_alc_ledger_type ( n_ledger_id       IN  NUMBER,
                                n_alc_ledger_type OUT NOCOPY VARCHAR2) IS
BEGIN
   IF pg_alc_ledger_type_rec.EXISTS(n_ledger_id) THEN
      n_alc_ledger_type := pg_alc_ledger_type_rec(n_ledger_id);
   ELSE
      SELECT alc_ledger_type_code
        INTO n_alc_ledger_type
        FROM gl_ledgers
       WHERE ledger_id = n_ledger_id;

      pg_alc_ledger_type_rec(n_ledger_id) := n_alc_ledger_type;
   END IF;
EXCEPTION
   WHEN others THEN
     n_alc_ledger_type := NULL;
END;

-- Function
--   get_alc_ledger_type
-- Purpose
--   Returns ALC ledger type code of the passed ledger ID
-- History
--   25-FEB-03 LPOON       Created (New R11i.X procedure)
FUNCTION get_alc_ledger_type ( n_ledger_id IN  NUMBER) RETURN VARCHAR2 IS
  l_alc_ledger_type VARCHAR2(30);
BEGIN
   IF pg_alc_ledger_type_rec.EXISTS(n_ledger_id) THEN
      RETURN pg_alc_ledger_type_rec(n_ledger_id);
   ELSE
      SELECT alc_ledger_type_code
        INTO l_alc_ledger_type
        FROM gl_ledgers
       WHERE ledger_id = n_ledger_id;

      pg_alc_ledger_type_rec(n_ledger_id) := l_alc_ledger_type;
      RETURN l_alc_ledger_type;
   END IF;
EXCEPTION
   WHEN others THEN
     RETURN NULL;
END;

-- Procedure
--   get_sob_type
--   *Should call get_alc_ledger_type() instead and this is for backward
--    compatible
-- Purpose
--   Gets the type of set of books
-- History
--   21-JAN-99       Ramana Yella          Created.
--   12-AUG-02       MRAMANAT		   Fixed bug 2498090.
--   25-FEB-03       LPOON                 R11i.X changes
PROCEDURE get_sob_type ( n_sob_id   IN  NUMBER,
                         n_sob_type OUT NOCOPY VARCHAR2) IS
  l_alc_ledger_type VARCHAR2(30);
BEGIN

  gl_mc_info.get_alc_ledger_type(n_sob_id, l_alc_ledger_type);

  IF l_alc_ledger_type = 'SOURCE'
  THEN
    n_sob_type := 'P';
  ELSIF l_alc_ledger_type = 'TARGET'
  THEN
    n_sob_type := 'R';
  ELSIF l_alc_ledger_type = 'NONE'
  THEN
    n_sob_type := 'N';
  ELSE
    n_sob_type := NULL;
  END IF;
END;

-- Procedure
--   get_ledger_category
-- Purpose
--   Gets ledger category of the passed ledger ID
-- History
--   25-FEB-03 LPOON       Created (New R11i.X procedure)
PROCEDURE get_ledger_category ( n_ledger_id       IN  NUMBER,
                                n_ledger_category OUT NOCOPY VARCHAR2) IS
BEGIN
   IF pg_ledger_category_rec.EXISTS(n_ledger_id) THEN
      n_ledger_category := pg_ledger_category_rec(n_ledger_id);
   ELSE
      SELECT ledger_category_code
        INTO n_ledger_category
        FROM gl_ledgers
       WHERE ledger_id = n_ledger_id;

      pg_ledger_category_rec(n_ledger_id) := n_ledger_category;
   END IF;
EXCEPTION
   WHEN others THEN
     n_ledger_category := NULL;
END;

-- Function
--   get_ledger_category
-- Purpose
--   return ledger category of the passed ledger ID
-- History
--   25-FEB-03 LPOON       Created (New R11i.X procedure)
FUNCTION get_ledger_category ( n_ledger_id IN NUMBER) RETURN VARCHAR2 IS
  l_ledger_category VARCHAR2(30);
BEGIN
   IF pg_ledger_category_rec.EXISTS(n_ledger_id) THEN
      RETURN pg_ledger_category_rec(n_ledger_id);
   ELSE
      SELECT ledger_category_code
        INTO l_ledger_category
        FROM gl_ledgers
       WHERE ledger_id = n_ledger_id;

      pg_ledger_category_rec(n_ledger_id) := l_ledger_category;
      RETURN l_ledger_category;
   END IF;
EXCEPTION
   WHEN others THEN
     RETURN NULL;
END;

-- Function
--   get_source_ledger_id
-- Purpose
--   Return the ALC source ledger ID of the particular ALC target ledger
--   per application/OU
-- History
--   25-FEB-03   LPOON      Created (New R11i.X function)
FUNCTION get_source_ledger_id (n_ledger_id    IN NUMBER,
                               n_appl_id      IN NUMBER,
                               n_org_id       IN NUMBER,
                               n_fa_book_code IN VARCHAR2) RETURN NUMBER IS
  l_src_ledger_id   gl_ledgers.ledger_id%TYPE;
  l_ledger_category gl_ledgers.ledger_category_code%TYPE;
BEGIN
  l_ledger_category := gl_mc_info.get_ledger_category(n_ledger_id);

  IF (l_ledger_category = 'PRIMARY')
  THEN
    l_src_ledger_id := n_ledger_id;

  ELSIF (l_ledger_category = 'ALC')
  THEN
    -- In case if one ALC target ledger is attached to multiple ALC source
    -- ledgers (which is generally not the case), we will return the first row
    -- found.
    SELECT source_ledger_id
    INTO l_src_ledger_id
    FROM GL_LEDGER_RELATIONSHIPS GLR
    WHERE GLR.target_ledger_id = n_ledger_id
    AND GLR.target_ledger_category_code = 'ALC'
    AND GLR.relationship_type_code IN ('SUBLEDGER', 'JOURNAL')
    AND GLR.application_id = n_appl_id
    AND GLR.relationship_enabled_flag = 'Y'
    AND (n_org_id IS NULL
         OR GLR.org_id = -99
         OR GLR.org_id = NVL(n_org_id,-99))
    AND (NVL(n_fa_book_code, '-99') = '-99'
         OR EXISTS
            (SELECT 'FA book type is enabled'
               FROM FA_MC_BOOK_CONTROLS MC
              WHERE MC.set_of_books_id = GLR.target_ledger_id
                AND MC.book_type_code = n_fa_book_code
                AND MC.primary_set_of_books_id = GLR.source_ledger_id
                AND MC.enabled_flag = 'Y'))
    AND rownum = 1;

  ELSIF (l_ledger_category = 'SECONDARY')
  THEN
    -- In case if one Secondary ledger is attached to multiple Primary
    -- ledgers (which is generally not the case), we will return the first row
    -- found.
    SELECT source_ledger_id
    INTO l_src_ledger_id
    FROM GL_LEDGER_RELATIONSHIPS GLR,
         gl_ledgers lgr_c
    WHERE GLR.target_ledger_id = n_ledger_id
    AND GLR.target_ledger_category_code = 'SECONDARY'
    AND GLR.relationship_type_code <> 'NONE'
    AND GLR.application_id = n_appl_id
    AND glr.target_ledger_id = lgr_c.ledger_id
    AND nvl(lgr_c.complete_flag,'Y') = 'Y'
    AND GLR.relationship_enabled_flag = 'Y'
    AND (n_org_id IS NULL
         OR GLR.org_id = -99
         OR GLR.org_id = NVL(n_org_id,-99))
    AND rownum = 1;
  ELSE
    RETURN NULL;

  END IF;

  RETURN(l_src_ledger_id);
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

-- Function
--   get_source_ledger_id
-- Purpose
--   Return the ALC source ledger ID of the particular ALC target ledger
-- History
--   25-FEB-03   LPOON      Created (New R11i.X function)
FUNCTION get_source_ledger_id (n_ledger_id IN NUMBER) RETURN NUMBER IS
  l_src_ledger_id gl_ledgers.ledger_id%TYPE;
  l_ledger_category gl_ledgers.ledger_category_code%TYPE;
BEGIN
  l_ledger_category := gl_mc_info.get_ledger_category(n_ledger_id);

  IF (l_ledger_category = 'PRIMARY')
  THEN
    l_src_ledger_id := n_ledger_id;

  ELSIF (l_ledger_category = 'ALC')
  THEN
    -- In case if one ALC target ledger is attached to multiple ALC source
    -- ledgers (which is generally not the case), we will return the first row
    -- found.
    SELECT source_ledger_id
    INTO l_src_ledger_id
    FROM GL_LEDGER_RELATIONSHIPS GLR
    WHERE GLR.target_ledger_id = n_ledger_id
    AND GLR.target_ledger_category_code = 'ALC'
    AND GLR.relationship_type_code IN ('SUBLEDGER', 'JOURNAL')
    AND GLR.relationship_enabled_flag = 'Y'
    AND rownum = 1;

  ELSIF (l_ledger_category = 'SECONDARY')
  THEN
    -- In case if one Secondary ledger is attached to multiple Primary
    -- ledgers (which is generally not the case), we will return the first row
    -- found.
    SELECT source_ledger_id
    INTO l_src_ledger_id
    FROM GL_LEDGER_RELATIONSHIPS GLR,
         GL_LEDGERS LGR_C
    WHERE GLR.target_ledger_id = n_ledger_id
    AND GLR.target_ledger_category_code = 'SECONDARY'
    AND GLR.relationship_type_code <> 'NONE'
    AND GLR.relationship_enabled_flag = 'Y'
    AND glr.target_ledger_id = lgr_c.ledger_id
    AND nvl(lgr_c.complete_flag,'Y') = 'Y'
    AND rownum = 1;
  ELSE
    RETURN NULL;

  END IF;

  RETURN(l_src_ledger_id);
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

-- Function
--   get_primary_set_of_books_id
--   *Should call get_source_ledger_id() instead and this is for backward
--    compatible
-- Purpose
--   Fetches the primary set of books ID for the reporting set of books ID
--   passed to the function
-- History
--   31-JAN-01   MGOWDA     Created
--   25-FEB-03   LPOON      R11i.X changes
FUNCTION get_primary_set_of_books_id (n_rsob_id IN NUMBER) RETURN NUMBER IS
BEGIN
  RETURN gl_mc_info.get_source_ledger_id (n_rsob_id);
END;

-- Function
--   get_primary_ledger_id
-- Purpose
--   Return the Primary ledger ID of the particular Secondary ledger ID
--   per application/OU
-- History
--   25-FEB-03   LPOON      Created (New R11i.X function)
FUNCTION get_primary_ledger_id (n_ledger_id IN NUMBER,
                                n_appl_id   IN NUMBER,
                                n_org_id    IN NUMBER) RETURN NUMBER IS
  l_pri_ledger_id   gl_ledgers.ledger_id%TYPE;
  l_ledger_category gl_ledgers.ledger_category_code%TYPE;
BEGIN
  l_ledger_category := gl_mc_info.get_ledger_category(n_ledger_id);

  IF (l_ledger_category = 'PRIMARY')
  THEN
    l_pri_ledger_id := n_ledger_id;

  ELSIF (l_ledger_category = 'ALC')
  THEN
    -- In case if one ALC ledger is attached to multiple primary ledgers
    -- (which is generally not the case), we will return the first row found.
    SELECT primary_ledger_id
    INTO l_pri_ledger_id
    FROM GL_LEDGER_RELATIONSHIPS
    WHERE target_ledger_id = n_ledger_id
    AND target_ledger_category_code = 'ALC'
    AND relationship_type_code IN ('SUBLEDGER', 'JOURNAL')
    AND application_id = n_appl_id
    AND (n_org_id IS NULL OR org_id = -99 OR org_id = NVL(n_org_id, -99))
    AND relationship_enabled_flag = 'Y' -- Should we check if it is enabled???
    AND rownum = 1;

  ELSIF (l_ledger_category = 'SECONDARY')
  THEN
    -- In case if one secondary ledger is attached to multiple primary ledgers
    -- (which is generally not the case), we will return the first row found.
    SELECT primary_ledger_id
    INTO l_pri_ledger_id
    FROM GL_LEDGER_RELATIONSHIPS GLR,
         GL_LEDGERS lgr_c
    WHERE target_ledger_id = n_ledger_id
    AND target_ledger_category_code = 'SECONDARY'
    AND relationship_type_code <> 'NONE'
    AND application_id = n_appl_id
    AND (n_org_id IS NULL OR org_id = -99 OR org_id = NVL(n_org_id, -99))
    AND relationship_enabled_flag = 'Y' -- Should we check if it is enabled???
    AND glr.target_ledger_id = lgr_c.ledger_id
    AND nvl(lgr_c.complete_flag,'Y') = 'Y'
    AND rownum = 1;

  ELSE
    RETURN NULL;

  END IF;

  RETURN(l_pri_ledger_id);
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

-- Function
--   get_primary_ledger_id
-- Purpose
--   Return the Primary ledger ID of the particular Secondary ledger ID
-- History
--   25-FEB-03   LPOON      Created (New R11i.X function)
FUNCTION get_primary_ledger_id (n_ledger_id IN NUMBER) RETURN NUMBER IS
  l_pri_ledger_id   gl_ledgers.ledger_id%TYPE;
  l_ledger_category gl_ledgers.ledger_category_code%TYPE;
BEGIN
  l_ledger_category := gl_mc_info.get_ledger_category(n_ledger_id);

  IF (l_ledger_category = 'PRIMARY')
  THEN
    l_pri_ledger_id := n_ledger_id;

  ELSIF (l_ledger_category = 'ALC')
  THEN
    -- In case if one ALC ledger is attached to multiple primary ledgers
    -- (which is generally not the case), we will return the first row found.
    SELECT primary_ledger_id
    INTO l_pri_ledger_id
    FROM GL_LEDGER_RELATIONSHIPS
    WHERE target_ledger_id = n_ledger_id
    AND target_ledger_category_code = 'ALC'
    AND relationship_type_code IN ('SUBLEDGER', 'JOURNAL')
    AND relationship_enabled_flag = 'Y' -- Should we check if it is enabled???
    AND rownum = 1;

  ELSIF (l_ledger_category = 'SECONDARY')
  THEN
    -- In case if one secondary ledger is attached to multiple primary ledgers
    -- (which is generally not the case), we will return the first row found.
    SELECT primary_ledger_id
    INTO l_pri_ledger_id
    FROM GL_LEDGER_RELATIONSHIPS GLR,
         GL_LEDGERS lgr_c
    WHERE target_ledger_id = n_ledger_id
    AND target_ledger_category_code = 'SECONDARY'
    AND relationship_type_code <> 'NONE'
    AND relationship_enabled_flag = 'Y' -- Should we check if it is enabled???
    AND glr.target_ledger_id = lgr_c.ledger_id
    AND nvl(lgr_c.complete_flag,'Y') = 'Y'
    AND rownum = 1;

  ELSE
    RETURN NULL;

  END IF;

  RETURN(l_pri_ledger_id);
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

-- Function
--   init_ledger_le_bsv_gt
-- Purpose
--   Initialize the global temporary table, GL_LEDGER_LE_BSV_GT for a specific
--   ledger and its associated ALC ledgers, if any
-- History
--   05-JUN-03   LPOON      Created (New R11i.X function)
--   19-FEB-04   LPOON      Modified the SQL to insert rows for specific BSV opt
FUNCTION init_ledger_le_bsv_gt (p_ledger_id IN NUMBER) RETURN VARCHAR2 IS
  l_ledger_category VARCHAr2(30);
  l_bsv_option      VARCHAR2(1);
  l_bsv_vset_id     NUMBER;

  l_fv_table FND_FLEX_VALIDATION_TABLES.application_table_name%TYPE;
  l_fv_col   FND_FLEX_VALIDATION_TABLES.value_column_name%TYPE;
  l_fv_type  FND_FLEX_VALUE_SETS.validation_type%TYPE;

  l_insertSQL DBMS_SQL.VARCHAR2S;
  l_line_no   NUMBER := 0;
  l_cursorID  INTEGER;
  l_return_no NUMBER;

BEGIN
  IF (p_ledger_id IS NULL)
  THEN
    -- Ledger ID is not passed, so return F (i.e. FAIL)
    RETURN 'F';

  END IF;

  --
  -- Initialization and verificiation variables
  --

  -- First, get its ledger category code and BSV option code
  SELECT ledger_category_code,
         NVL(bal_seg_value_option_code, 'A'),
         bal_seg_value_set_id
    INTO l_ledger_category,
         l_bsv_option,
         l_bsv_vset_id
    FROM GL_LEDGERS
   WHERE ledger_id = p_ledger_id;

  IF (l_ledger_category <> 'PRIMARY'
       AND l_ledger_category <> 'SECONDARY'
       AND l_ledger_category <> 'ALC')
  THEN
    -- We don't handle NONE ledgers, which haven't been set up properly yet.
    -- Or, invalid ledger cateogry codes of the passed ledger.
    RETURN 'F';

  END IF; -- IF (l_ledger_category <> 'PRIMARY' ...

  --
  -- Delete rows from GL_LEDGER_LE_BSV_GT for the passed ledger
  --

  -- Delete the rows for the passed ledger and its associated ALC Ledgers
/*  DELETE FROM GL_LEDGER_LE_BSV_GT
        WHERE ledger_id = p_ledger_id
           OR ledger_id IN (
               SELECT ledger_id FROM GL_ALC_LEDGER_RSHIPS_V
               WHERE application_id = 101
               AND source_ledger_id = p_ledger_id); */

-- Delete the all the rows from Previous Ledger contexts
  DELETE FROM GL_LEDGER_LE_BSV_GT;

  --
  -- Insert segment values from GL_LEDGER_NORM_SEG_VALS if the BSV option is
  -- Specific (i.e. I)
  --
  IF (l_bsv_option = 'I')
  THEN
    -- Insert rows for the passed ledger and its associated ALC Ledgers
    INSERT INTO GL_LEDGER_LE_BSV_GT
    (LEDGER_ID, LEDGER_NAME, LEDGER_SHORT_NAME, LEDGER_CATEGORY_CODE,
     CHART_OF_ACCOUNTS_ID, BAL_SEG_VALUE_OPTION_CODE, BAL_SEG_VALUE_SET_ID,
     BAL_SEG_COLUMN_NAME, BAL_SEG_VALUE, LEGAL_ENTITY_ID, LEGAL_ENTITY_NAME,
     START_DATE, END_DATE, RELATIONSHIP_ENABLED_FLAG
--     , SLA_SEQUENCING_FLAG
    )
    -- XLE uptake: Changed to get the LE name from the new XLE tables
    SELECT lg.LEDGER_ID, lg.NAME, lg.SHORT_NAME, lg.LEDGER_CATEGORY_CODE,
           lg.CHART_OF_ACCOUNTS_ID, lg.BAL_SEG_VALUE_OPTION_CODE,
           lg.BAL_SEG_VALUE_SET_ID, lg.BAL_SEG_COLUMN_NAME, bsv.SEGMENT_VALUE,
           bsv.LEGAL_ENTITY_ID, le.NAME, bsv.START_DATE,
		   bsv.END_DATE, DECODE(lg.LEDGER_CATEGORY_CODE, 'PRIMARY', 'Y', 'N')
--           , bsv.SLA_SEQUENCING_FLAG
      FROM   GL_LEDGERS              lg
           , GL_LEDGER_RELATIONSHIPS rs
           , GL_LEDGER_NORM_SEG_VALS bsv
           , XLE_ENTITY_PROFILES     le
           , GL_LEDGERS              lgr_c
     WHERE ((rs.relationship_type_code = 'NONE'
             AND rs.target_ledger_id = p_ledger_id)
            OR
            (rs.target_ledger_category_code = 'ALC'
             AND rs.relationship_type_code IN ('SUBLEDGER', 'JOURNAL')
             AND rs.source_ledger_id = p_ledger_id))
       AND rs.application_id = 101
       AND lg.ledger_id = rs.target_ledger_id
       --Bug 4887990 Avoided the merge join
       AND bsv.ledger_id = Decode(rs.relationship_type_code,
                                             'NONE',rs.target_ledger_id,
					            rs.source_ledger_id)--p_ledger_id
       AND rs.target_ledger_id = lgr_c.ledger_id
       AND nvl(lgr_c.complete_flag,'Y') = 'Y'
       AND bsv.segment_type_code = 'B'
       -- We should exclude segment values with status code = 'D' since they
       -- will be deleted by the flatten program when config is confirmed
--       AND bsv.status_code IS NULL
       AND NVL(bsv.status_code, 'I') <> 'D'
       AND le.legal_entity_id(+) = bsv.legal_entity_id;

  ELSIF (l_bsv_option = 'A')
  THEN
    --
    -- Insert segment values from the balancing flex value set if the BSV option is
    -- All (i.e. A)
    --

    -- Build INSERT statement of the dynamic INSERT SQL
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        'INSERT INTO GL_LEDGER_LE_BSV_GT';
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        '(LEDGER_ID, LEDGER_NAME, LEDGER_SHORT_NAME, LEDGER_CATEGORY_CODE, ';
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        ' CHART_OF_ACCOUNTS_ID, BAL_SEG_VALUE_OPTION_CODE, BAL_SEG_VALUE_SET_ID, ';
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        ' BAL_SEG_COLUMN_NAME, BAL_SEG_VALUE, LEGAL_ENTITY_ID, LEGAL_ENTITY_NAME, ';
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        ' START_DATE, END_DATE, RELATIONSHIP_ENABLED_FLAG) ';

    -- Call the get_fv_tagble to get the flex value table name and its
    -- flex value column name for the processed segment
    SELECT   nvl(fvt.application_table_name, 'FND_FLEX_VALUES')
           , nvl(fvt.value_column_name, 'FLEX_VALUE')
           , fvs.validation_type
      INTO   l_fv_table
           , l_fv_col
           , l_fv_type
      FROM   fnd_flex_value_sets fvs
           , fnd_flex_validation_tables fvt
     WHERE fvs.flex_value_set_id = l_bsv_vset_id
       AND fvt.flex_value_set_id(+) = fvs.flex_value_set_id;

    -- Build SELECT statement of the dynamic INSERT SQL

    -- Columns: LEDGER_ID, LEDGER_NAME, LEDGER_SHORT_NAME, LEDGER_CATEGORY_CODE
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        'SELECT lg.LEDGER_ID, lg.NAME, lg.SHORT_NAME, lg.LEDGER_CATEGORY_CODE, ';

    -- Columns: CHART_OF_ACCOUNTS_ID, BAL_SEG_VALUE_OPTION_CODE
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        '       lg.CHART_OF_ACCOUNTS_ID, lg.BAL_SEG_VALUE_OPTION_CODE, ';

    -- Columns: BAL_SEG_VALUE_SET_ID, BAL_SEG_COLUMNE_NAME, BAL_SEG_VALUE
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        '       lg.BAL_SEG_VALUE_SET_ID, lg.BAL_SEG_COLUMN_NAME, bsv.'
        || l_fv_col || ', ';

    -- Columns: LEGAL_ENTITY_ID, LEGAL_ENTITY_NAME, START_DATE, END_DATE
    -- Note: LE ID and Name are always NULL for ALL BSV option.
    l_line_no := l_line_no + 1;
    IF (l_fv_type <> 'F')
    THEN
      l_insertSQL(l_line_no) :=
        '       NULL, NULL, bsv.START_DATE_ACTIVE, bsv.END_DATE_ACTIVE, ';
    ELSE
      l_insertSQL(l_line_no) :=
        '       NULL, NULL, NULL, NULL, ';
    END IF;

    -- Column: RELATIONSHIP_ENABLED_FLAG
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        '       DECODE(lg.LEDGER_CATEGORY_CODE, ''PRIMARY'', ''Y'', ''N'') ';

    -- Build FROM statement of the dynamic INSERT SQL
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        'FROM GL_LEDGERS lg, '|| l_fv_table || ' bsv ';

    -- Build WHERE statement of the dynamic INSERT SQL
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        'WHERE (lg.ledger_id = :lg_id1 ';
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        '       OR lg.ledger_id IN ( ';
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        '           SELECT ledger_id FROM GL_ALC_LEDGER_RSHIPS_V ';
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        '           WHERE application_id = 101 ';
    l_line_no := l_line_no + 1;
    l_insertSQL(l_line_no) :=
        '           AND source_ledger_id = :lg_id2)) ';

    IF (l_fv_type <> 'F')
    THEN
      l_line_no := l_line_no + 1;
      l_insertSQL(l_line_no) :=
        'AND bsv.flex_value_set_id = lg.bal_seg_value_set_id ';
      l_line_no := l_line_no + 1;
      l_insertSQL(l_line_no) := 'AND bsv.summary_flag = ''N'' ';
    END IF;

    -- Open cursor
    l_cursorID := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_cursorID, l_insertSQL, 1, l_line_no, TRUE, dbms_sql.native);

    -- Bind variables
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':lg_id1', p_ledger_id);
    DBMS_SQL.BIND_VARIABLE(l_cursorID, ':lg_id2', p_ledger_id);

    -- Execute INSERT SQL
    l_return_no := DBMS_SQL.EXECUTE(l_cursorID);

    -- Close cursor
    DBMS_SQL.CLOSE_CURSOR(l_cursorID);

  ELSE
    -- Invalid BSV option code for the passed ledger
    RETURN 'F';

  END IF; -- IF (l_bsv_option = 'I')

  -- Update RELATIONSHIP_ENABLED_FLAG to 'Y' for ALC/secondary ledgers
  -- if they have at least one enabled ALC/secondary relationship
  UPDATE GL_LEDGER_LE_BSV_GT gt
     SET gt.RELATIONSHIP_ENABLED_FLAG = 'Y'
   WHERE (gt.LEDGER_CATEGORY_CODE = 'SECONDARY'
          AND EXISTS (
               SELECT 'Enabled RS exists' FROM GL_SECONDARY_LEDGER_RSHIPS_V rs
               WHERE rs.ledger_id = gt.ledger_id
               AND rs.relationship_enabled_flag = 'Y'))
      OR (gt.LEDGER_CATEGORY_CODE = 'ALC'
          AND EXISTS (
               SELECT 'Enabled RS exists' FROM GL_ALC_LEDGER_RSHIPS_V rs
               WHERE rs.ledger_id = gt.ledger_id
               AND rs.application_id = 101
               AND rs.relationship_enabled_flag = 'Y'));

  RETURN 'S';
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'F';
END;

-- Function
--   get_le_ledgers
-- Purpose
--   Return the ledgers associatd with a specific legal entity
-- History
--   21-MAY-03   LPOON      Created (New R11i.X function)
FUNCTION get_le_ledgers (
          p_legal_entity_id    IN            NUMBER,
          p_get_primary_flag   IN            VARCHAR2,
          p_get_secondary_flag IN            VARCHAR2,
          p_get_alc_flag       IN            VARCHAR2,
          x_ledger_list        IN OUT NOCOPY ledger_tbl_type) RETURN BOOLEAN IS
  l_rec_col ledger_rec_col; -- To store the values retrieved by BULK COLLECT
  l_num_rec NUMBER;
  i         NUMBER;
BEGIN
  IF (p_legal_entity_id IS NULL)
  THEN
    -- Legal entity ID is not passed, so return FALSE
    RETURN FALSE;

  END IF;

  SELECT   LEDGER_ID
         , LEDGER_NAME
         , LEDGER_SHORT_NAME
         , CURRENCY_CODE
         , LEDGER_CATEGORY_CODE
  BULK COLLECT INTO
           l_rec_col.ledger_id,
           l_rec_col.ledger_name,
           l_rec_col.ledger_short_name,
           l_rec_col.ledger_currency,
           l_rec_col.ledger_category
  FROM GL_LEDGER_LE_V
  WHERE ledger_category_code IN (
         DECODE(UPPER(NVL(p_get_primary_flag, 'Y')), 'Y', 'PRIMARY', 'NOT_INCLUDED'),
         DECODE(UPPER(NVL(p_get_secondary_flag, 'N')), 'Y', 'SECONDARY', 'NOT_INCLUDED'),
         DECODE(UPPER(NVL(p_get_alc_flag, 'N')), 'Y', 'ALC', 'NOT_INCLUDED'))
  AND legal_entity_id = p_legal_entity_id
  AND relationship_enabled_flag = 'Y'
  ORDER BY DECODE(ledger_category_code, 'PRIMARY', 1, 2), ledger_id;

  -- Get the number of ledgers retrieved and extend x_ledger_list (table)
  l_num_rec := l_rec_col.ledger_id.count;
  x_ledger_list.extend(l_num_rec);

  -- Try to store all records from l_rec_col to x_ledger_list
  FOR i IN 1..l_num_rec LOOP
    SELECT l_rec_col.ledger_id(i),
           l_rec_col.ledger_name(i),
           l_rec_col.ledger_short_name(i),
           l_rec_col.ledger_currency(i),
           l_rec_col.ledger_category(i)
      INTO x_ledger_list(i).ledger_id,
           x_ledger_list(i).ledger_name,
           x_ledger_list(i).ledger_short_name,
           x_ledger_list(i).ledger_currency,
           x_ledger_list(i).ledger_category
      FROM dual;
  END LOOP; -- FOR LOOP

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END;

-- Function
--   get_legal_entities
-- Purpose
--   Return the legal entities assigned to a specific ledger
-- History
--   21-MAY-03   LPOON      Created (New R11i.X function)
FUNCTION get_legal_entities (
          p_ledger_id     IN            NUMBER,
          x_le_list       IN OUT NOCOPY le_bsv_tbl_type) RETURN BOOLEAN IS
  l_rec_col le_bsv_rec_col; -- To store the values retrieved by BULK COLLECT
  l_num_rec NUMBER;
  i         NUMBER;
BEGIN
  IF (p_ledger_id IS NULL)
  THEN
    -- Ledger ID is not passed, so return FALSE
    RETURN FALSE;

  END IF;

  SELECT   legal_entity_id
         , legal_entity_name
  BULK COLLECT INTO
           l_rec_col.legal_entity_id,
           l_rec_col.legal_entity_name
  FROM GL_LEDGER_LE_V
  WHERE ledger_id = p_ledger_id
  AND legal_entity_id IS NOT NULL
  AND relationship_enabled_flag = 'Y'
  ORDER BY legal_entity_id;

  -- Get the number of legal entities retrieved and extend x_le_list (table)
  l_num_rec := l_rec_col.legal_entity_id.count;
  x_le_list.extend(l_num_rec);

  -- Try to store all records from l_rec_col to x_le_list
  FOR i IN 1..l_num_rec LOOP
    SELECT l_rec_col.legal_entity_id(i),
           l_rec_col.legal_entity_name(i)
      INTO x_le_list(i).legal_entity_id,
           x_le_list(i).legal_entity_name
      FROM dual;
  END LOOP; -- FOR LOOP

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END;

-- Function
--   get_legal_entities
-- Purpose
--   Return the legal entities assigned to a specific ledger/BSV
-- History
--   21-MAY-03   LPOON      Created (New R11i.X function)
FUNCTION get_legal_entities (
          p_ledger_id     IN            NUMBER,
          p_bal_seg_value IN            VARCHAR2,
          p_bsv_eff_date  IN            DATE,
          x_le_list       IN OUT NOCOPY le_bsv_tbl_type) RETURN BOOLEAN IS
  l_ret_value    VARCHAR2(1);
  l_rec_col      le_bsv_rec_col; -- To store the values retrieved by BULK COLLECT
  l_bal_seg_opt  VARCHAR2(1);
  l_bsv_assigned VARCHAR2(1);
  l_num_rec      NUMBER;
  i              NUMBER;
BEGIN
  -- Bug fix 3975695: Moved the codes to assign default values from
  --                  declaration to here
  l_bsv_assigned := 'N';

  IF (p_ledger_id IS NULL)
  THEN
    -- Ledger ID is not passed, so return FALSE
    RETURN FALSE;

  END IF;

  SELECT NVL(bal_seg_value_option_code,'A')
  INTO l_bal_seg_opt
  FROM GL_LEDGERS
  WHERE ledger_id = p_ledger_id;

  /*
   * Bug 6810738
   * No need to populate temporary table if BSV option is All
   * values
   */
  IF l_bal_seg_opt = 'A'
  THEN
    l_ret_value := 'S'; --  Just assigning success status
  ELSE
    l_ret_value := GL_MC_INFO.init_ledger_le_bsv_gt(p_ledger_id);
  END IF;

  IF (l_ret_value = 'S')
  THEN
    -- Sucessful initialization, so select BSV from the global table
    IF (l_bal_seg_opt = 'I')
    THEN
      IF (p_bal_seg_value IS NOT NULL)
      THEN
        -- CASE 1: Specific BSV option and BSV is passed
        -- We can get LEs assigned to this ledger/BSV from GL_LEDGER_LE_BSV_GT.
        SELECT   legal_entity_id
               , legal_entity_name
        BULK COLLECT INTO
                 l_rec_col.legal_entity_id,
                 l_rec_col.legal_entity_name
        FROM GL_LEDGER_LE_BSV_GT
        WHERE ledger_id = p_ledger_id
        AND bal_seg_value = p_bal_seg_value
        AND ((p_bsv_eff_date IS NULL)
             OR (p_bsv_eff_date >= NVL(start_date, p_bsv_eff_date)
                 AND p_bsv_eff_date <= NVL(end_date, p_bsv_eff_date)))
        AND legal_entity_id IS NOT NULL
        ORDER BY legal_entity_id;

      ELSE
        -- CASE 2: Specific BSV option and BSV is NOT passed
        -- We can get LEs assigned to this ledger from GL_LEDGER_LE_BSV_GT.
        SELECT DISTINCT   legal_entity_id
                        , legal_entity_name
        BULK COLLECT INTO
                          l_rec_col.legal_entity_id,
                          l_rec_col.legal_entity_name
        FROM GL_LEDGER_LE_BSV_GT
        WHERE ledger_id = p_ledger_id
        AND ((p_bsv_eff_date IS NULL)
             OR (p_bsv_eff_date >= NVL(start_date, p_bsv_eff_date)
                 AND p_bsv_eff_date <= NVL(end_date, p_bsv_eff_date)))
        AND legal_entity_id IS NOT NULL
        ORDER BY legal_entity_id;

      END IF; -- IF (p_bal_seg_value IS NOT NULL)

      -- Get the number of legal entities retrieved and extend x_le_list (table)
      l_num_rec := l_rec_col.legal_entity_id.count;
      x_le_list.extend(l_num_rec);

      -- Try to store all records from l_rec_col to x_le_list
      FOR i IN 1..l_num_rec LOOP
        SELECT l_rec_col.legal_entity_id(i),
               l_rec_col.legal_entity_name(i)
          INTO x_le_list(i).legal_entity_id,
               x_le_list(i).legal_entity_name
          FROM dual;
      END LOOP; -- FOR LOOP

      RETURN TRUE;

    ELSIF (l_bal_seg_opt = 'A')
    THEN
     /*
      * Commenting this code per bug 6810738
      * when the BSV option is All values ignore if BSV is passed
      * we assume that BSV is validated (to be a proper value in valueset)
      * prior to calling this API
      */
      /******************************************************
      **      IF (p_bal_seg_value IS NOT NULL)
      **      THEN
      **        -- CASE 3: All BSV option and BSV is passed
      **        -- First, we need to check whether the passed BSV is assigned to
      **        -- this edger.
      **        --  => If yes, it can proceed to get LEs assigned to this ledger
      **        --     from GL_LEDGER_LE_V
      **        --  => If no, it will return TRUE and null LE list.
      **        BEGIN
      **          SELECT 'Y'
      **            INTO l_bsv_assigned
      **            FROM GL_LEDGER_LE_BSV_GT
      **           WHERE ledger_id = p_ledger_id
      **             AND bal_seg_value = p_bal_seg_value
      **            AND ((p_bsv_eff_date IS NULL)
      **                  OR (p_bsv_eff_date >= NVL(start_date, p_bsv_eff_date)
      **                   AND p_bsv_eff_date <= NVL(end_date, p_bsv_eff_date)));
      **        EXCEPTION
      **          WHEN NO_DATA_FOUND THEN
      **            RETURN TRUE;
      **        END;
      **
      **      END IF; -- IF (p_bal_seg_value IS NOT NULL)
      *********************************************************/

      -- CASE 4: All BSV option and BSV is not passed (*Also for CASE 3)
      -- We can call another API to get LEs assigned this ledger from
      -- GL_LEDGER_LE_V
      RETURN GL_MC_INFO.get_legal_entities(p_ledger_id, x_le_list);

    ELSE
      -- Invalid BSV option code
      RETURN FALSE;

    END IF; -- IF (l_bal_seg_opt = 'I')
  END IF; -- IF (l_ret_value = 'S')

  -- Fail to retrieve LE so return FALSE
  RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END;

-- Function
--   get_bal_seg_values
-- Purpose
--   Return the balancing segment values (BSV) assigned to a specific ledger/LE
-- History
--   21-MAY-03   LPOON      Created (New R11i.X function)
FUNCTION get_bal_seg_values (
          p_ledger_id          IN            NUMBER,
          p_legal_entity_id    IN            NUMBER,
          p_bsv_eff_date       IN            DATE,
          x_allow_all_bsv_flag OUT NOCOPY    VARCHAR2,
          x_bsv_list           IN OUT NOCOPY le_bsv_tbl_type) RETURN BOOLEAN IS
  l_ledger_id   NUMBER;
  l_le_name     VARCHAR2(60);
  l_ret_value   VARCHAR2(1);
  l_le_assigned VARCHAR2(1);
  l_rec_col     le_bsv_rec_col; -- To store the values retrieved by BULK COLLECT
  l_num_rec     NUMBER;
  i             NUMBER;
BEGIN

  -- Bug fix 3975695: Moved the codes to assign default values from
  --                  declaration to here
  l_le_assigned := 'N';

  IF (p_ledger_id IS NULL)
  THEN
    IF (p_legal_entity_id IS NOT NULL)
    THEN
      -- Bug 4006758: If the ledger ID is not passed, default to use the primary
   	  --              ledger ID
      SELECT lg.LEDGER_ID
      INTO l_ledger_id
      FROM GL_LEDGER_CONFIG_DETAILS cfDet,
           GL_LEDGERS lg
      WHERE cfDet.OBJECT_ID = p_legal_entity_id
      AND cfDet.OBJECT_TYPE_CODE = 'LEGAL_ENTITY'
      AND lg.CONFIGURATION_ID = cfDet.CONFIGURATION_ID
      AND lg.LEDGER_CATEGORY_CODE = 'PRIMARY';
    ELSE
      -- Both p_ledger_id and p_legal_entity_id are NULL
      RETURN FALSE;
    END IF;
  ELSE
    l_ledger_id := p_ledger_id;
  END IF;

  -- Check if it allows all BSV or specific BSV
  SELECT DECODE(bal_seg_value_option_code, 'I', 'N', 'Y')
  INTO x_allow_all_bsv_flag
  FROM GL_LEDGERS
  WHERE ledger_id = l_ledger_id;

  -- Initialize GL_LEGDER_LE_BSV_GT before getting its assigned BSV
  l_ret_value := GL_MC_INFO.init_ledger_le_bsv_gt(l_ledger_id);

  IF (l_ret_value = 'S')
  THEN
    -- Sucessful initialization, so select BSV from the global table

    IF (x_allow_all_bsv_flag = 'N' AND p_legal_entity_id IS NOT NULL)
    THEN
      -- CASE 1: Specific BSV option and LE ID is passed
      -- We can just get BSV assigned to this ledger/LE from GL_LEDGER_LE_BSV_GT
      SELECT   bal_seg_value
             , legal_entity_id
             , legal_entity_name
      BULK COLLECT INTO
               l_rec_col.bal_seg_value,
               l_rec_col.legal_entity_id,
               l_rec_col.legal_entity_name
      FROM GL_LEDGER_LE_BSV_GT
      WHERE ledger_id = l_ledger_id
      AND legal_entity_id = p_legal_entity_id
      AND ((p_bsv_eff_date IS NULL)
            OR (p_bsv_eff_date >= NVL(start_date, p_bsv_eff_date)
                AND p_bsv_eff_date <= NVL(end_date, p_bsv_eff_date)))
      ORDER BY bal_seg_value, legal_entity_id;

    ELSE
      IF (x_allow_all_bsv_flag = 'Y' AND p_legal_entity_id IS NOT NULL)
      THEN
        -- CASE 2: All BSV option and LE ID is passed
        -- First, we need to check if the LE is assigned to this ledger.
        --  => If yes, it can proceed to get all BSV assigned to this ledger from
        --     GL_LEDGER_LE_BSV_GT.
        --  => If no, it will return TRUE and null BSV list
        BEGIN
          SELECT legal_entity_name
            INTO l_le_name
            FROM GL_LEDGER_LE_V
           WHERE ledger_id = l_ledger_id
             AND legal_entity_id = p_legal_entity_id
             AND relationship_enabled_flag = 'Y';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RETURN TRUE;
        END;

      END IF; -- IF (x_allow_all_bsv_flag = 'Y' AND ...

      -- CASE 3: LE ID is NOT passed (*Also for CASE 2)
      -- We can get BSV assigned to this ledger from GL_LEDGER_LE_BSV_GT
      SELECT   bal_seg_value
             , NVL(legal_entity_id, p_legal_entity_id)
             , NVL(legal_entity_name, l_le_name)
      BULK COLLECT INTO
               l_rec_col.bal_seg_value,
               l_rec_col.legal_entity_id,
               l_rec_col.legal_entity_name
      FROM GL_LEDGER_LE_BSV_GT
      WHERE ledger_id = l_ledger_id
      AND ((p_bsv_eff_date IS NULL)
            OR (p_bsv_eff_date >= NVL(start_date, p_bsv_eff_date)
                AND p_bsv_eff_date <= NVL(end_date, p_bsv_eff_date)))
      ORDER BY bal_seg_value, legal_entity_id;

    END IF; -- IF (x_allow_all_bsv_flag = 'N' AND ...

    -- Get the number of BSV retrieved and extend x_bsv_list (table)
    l_num_rec := l_rec_col.bal_seg_value.count;
    x_bsv_list.extend(l_num_rec);

    -- Try to store all records from l_rec_col to x_bsv_list
    FOR i IN 1..l_num_rec LOOP
      SELECT l_rec_col.bal_seg_value(i),
             l_rec_col.legal_entity_id(i),
             l_rec_col.legal_entity_name(i)
        INTO x_bsv_list(i).bal_seg_value,
             x_bsv_list(i).legal_entity_id,
             x_bsv_list(i).legal_entity_name
        FROM dual;
    END LOOP; -- FOR LOOP

    RETURN TRUE;

  END IF; -- IF (l_ret_value = 'S')

  -- Fail to retrieve BSV so return FALSE
  RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END;

-- Function
--   get_bal_seg_values
-- Purpose
--   Return the balancing segment values (BSV) assigned to a specific ledger
-- History
--   21-MAY-03   LPOON      Created (New R11i.X function)
FUNCTION get_bal_seg_values (
          p_ledger_id          IN            NUMBER,
          p_bsv_eff_date       IN            DATE,
          x_allow_all_bsv_flag OUT NOCOPY    VARCHAR2,
          x_bsv_list           IN OUT NOCOPY le_bsv_tbl_type) RETURN BOOLEAN IS
BEGIN
  RETURN GL_MC_INFO.get_bal_seg_values (p_ledger_id,
                                        NULL,
                                        p_bsv_eff_date,
                                        x_allow_all_bsv_flag,
                                        x_bsv_list);
END;

-- Procedure
--   set_ledger
-- Purpose
--   Sets the client info for the passed ledger ID
-- History
--   25-FEB-03 LPOON      Created (New R11i.X procedure)
PROCEDURE set_ledger (n_ledger_id IN NUMBER) IS
 l_char_ledger_id  VARCHAR2(10);
 l_old_client_info VARCHAR2(64);
 l_new_client_info VARCHAR2(64);
BEGIN
   l_char_ledger_id := RPAD(to_char(n_ledger_id),10);

   dbms_application_info.read_client_info(l_old_client_info);
   l_old_client_info := RPAD(NVL(l_old_client_info,' '),64);
   l_new_client_info := substr(l_old_client_info,1,44)||l_char_ledger_id
                         ||substr(l_old_client_info,55);
   dbms_application_info.set_client_info(l_new_client_info);
END;

-- Procedure
--   set_org_id
-- Purpose
--   Sets the client info for the passed org ID
-- History
--   25-FEB-03 LPOON      Created (New R11i.X procedure)
PROCEDURE set_org_id (n_org_id IN NUMBER) IS
 l_char_org_id  VARCHAR2(10);
 l_old_client_info VARCHAR2(64);
 l_new_client_info VARCHAR2(64);
BEGIN
   l_char_org_id := RPAD(to_char(n_org_id),10);

   dbms_application_info.read_client_info(l_old_client_info);
   l_old_client_info := RPAD(NVL(l_old_client_info,' '),64);
   l_new_client_info := l_char_org_id || substr(l_old_client_info, 11);
   dbms_application_info.set_client_info(l_new_client_info);
END;

-- Procedure
--   set_rsob
-- Purpose
--   Sets the client info if the type of set of books is Reporting
-- History
--   26-JAN-99       Ramana Yella          Created
--   25-FEB-03       Li Wing Poon          R11i.X changes
PROCEDURE set_rsob (n_sob_id IN NUMBER) IS
 l_alc_ledger_type VARCHAR2(30);
BEGIN
   /* Get the ALC ledger type */
   gl_mc_info.get_alc_ledger_type(n_sob_id, l_alc_ledger_type);

   IF l_alc_ledger_type = 'TARGET' THEN
     /* Set client info if it is a ALC Target ledger */
     gl_mc_info.set_ledger(n_sob_id);
   END IF;
END;

-- Procedure
--   mrc_installed
-- Purpose
--   Determines if MRC is installed or not
-- History
--   02-FEB-99       Ramana Yella          Created
PROCEDURE mrc_installed ( mrc_install OUT NOCOPY VARCHAR2) IS

BEGIN
  SELECT multi_currency_flag
    INTO mrc_install
    FROM fnd_product_groups
   WHERE product_group_id = 1;
END;

-- Procedure
--   alc_enabled
-- Purpose
--   Determines whether ALC is enabled
-- History
--   25-FEB-03  Li Wing Poon    Created (New R11i.X procedure)
PROCEDURE alc_enabled ( n_ledger_id    IN  NUMBER,
                        n_appl_id      IN  NUMBER,
                        n_org_id       IN  NUMBER,
                        n_fa_book_code IN  VARCHAR2,
                        n_alc_enabled  OUT NOCOPY VARCHAR2) IS
/* This procedure determines whether MRC is enabled for the
   particular Application,Organization and Set of books */
 l_alc_ledger_type VARCHAR2(30);
 l_count           NUMBER;

BEGIN
   /* Get the type of set of books for the particular SOB_ID */
   gl_mc_info.get_alc_ledger_type(n_ledger_id, l_alc_ledger_type);

   IF l_alc_ledger_type = 'SOURCE' THEN
      BEGIN
        /* It is ALC Source (i.e. ALC_LEDGER_TYPE_CODE = SOURCE) */

        /* If the application is FA (140), check based on FA_MC_BOOK_CONTROLS;
           else, based on ORG_ID */
        SELECT count(*)
        INTO l_count
        FROM GL_LEDGER_RELATIONSHIPS GLR
        WHERE GLR.source_ledger_id = n_ledger_id
        AND GLR.target_ledger_category_code = 'ALC'
        AND GLR.relationship_type_code IN ('SUBLEDGER', 'JOURNAL')
        AND GLR.application_id = n_appl_id
        AND GLR.relationship_enabled_flag = 'Y'
        AND (n_org_id IS NULL
             OR GLR.org_id = -99
             OR GLR.org_id = NVL(n_org_id,-99))
        AND (NVL(n_fa_book_code, '-99') = '-99'
             OR EXISTS
                (SELECT 'FA book type is enabled'
                 FROM FA_MC_BOOK_CONTROLS MC
                 WHERE MC.set_of_books_id = GLR.target_ledger_id
                 AND MC.book_type_code = n_fa_book_code
                 AND MC.primary_set_of_books_id = GLR.source_ledger_id
                 AND MC.enabled_flag = 'Y'));

        IF l_count >= 1 THEN
           n_alc_enabled := 'Y';
        ELSE
           n_alc_enabled := 'N';
        END IF;
      END;
   ELSIF l_alc_ledger_type = 'TARGET' THEN
      BEGIN
        /* It is ALC Target (i.e. ALC_LEDGER_TYPE_CODE = TARGET) */

        /* If the application is FA (140), check based on FA_MC_BOOK_CONTROLS;
           else, based on ORG_ID */
        SELECT count(*)
        INTO l_count
        FROM GL_LEDGER_RELATIONSHIPS GLR
        WHERE GLR.target_ledger_id = n_ledger_id
        AND GLR.target_ledger_category_code = 'ALC'
        AND GLR.relationship_type_code IN ('SUBLEDGER', 'JOURNAL')
        AND GLR.application_id = n_appl_id
        AND GLR.relationship_enabled_flag = 'Y'
        AND (n_org_id IS NULL
             OR GLR.org_id = -99
             OR GLR.org_id = NVL(n_org_id,-99))
        AND (NVL(n_fa_book_code, '-99') = '-99'
             OR EXISTS
                (SELECT 'FA book type is enabled'
                 FROM FA_MC_BOOK_CONTROLS MC
                 WHERE MC.set_of_books_id = GLR.target_ledger_id
                 AND MC.book_type_code = n_fa_book_code
                 AND MC.primary_set_of_books_id = GLR.source_ledger_id
                 AND MC.enabled_flag = 'Y'));

        IF l_count >= 1 THEN
           n_alc_enabled := 'Y';
        ELSE
           n_alc_enabled := 'N';
        END IF;
      END;
   ELSIF l_alc_ledger_type = 'NONE' THEN
      /* It is neither ALC Source nor Target (i.e. ALC_LEDGER_TYPE_CODE = NONE) */
      n_alc_enabled := 'N';
   END IF;
EXCEPTION
   WHEN others THEN
     n_alc_enabled := NULL;
END;

-- Function
--   alc_enabled
-- Purpose
--   Return TRUE if ALC is enabled; else FALSE
-- History
--   25-FEB-03  Li Wing Poon    Created (New R11i.X procedure)
FUNCTION alc_enabled (n_ledger_id    IN  NUMBER,
                      n_appl_id      IN  NUMBER,
                      n_org_id       IN  NUMBER,
                      n_fa_book_code IN  VARCHAR2) RETURN BOOLEAN IS
  l_alc_enabled VARCHAR2(1);
BEGIN
   gl_mc_info.alc_enabled(  n_ledger_id
                          , n_appl_id
                          , n_org_id
                          , n_fa_book_code
                          , l_alc_enabled);
   IF l_alc_enabled = 'Y' THEN
     RETURN TRUE;
   ELSIF l_alc_enabled = 'N' THEN
     RETURN FALSE;
   ELSE
     RETURN NULL;
   END IF;
END;

-- Function
--   alc_enabled
-- Purpose
--   Return TRUE if ALC is enabled; else FALSE
-- History
--   02-JUN-05  Li Wing Poon    Created (New R11i.X procedure)
FUNCTION alc_enabled (n_appl_id      IN  NUMBER) RETURN BOOLEAN IS
  l_count NUMBER;
BEGIN
  SELECT count(*)
  INTO l_count
  FROM GL_LEDGER_RELATIONSHIPS GLR
  WHERE GLR.target_ledger_category_code = 'ALC'
  AND GLR.relationship_type_code IN ('SUBLEDGER', 'JOURNAL')
  AND GLR.application_id = n_appl_id
  AND GLR.relationship_enabled_flag = 'Y';

  IF l_count >= 1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;

-- Procedure
--   mrc_enabled
--   *Should call alc_enabled() instead and this is for backward compatible
-- Purpose
--   Determines whether MRC is enabled for the particular
--   appplication/OU/SOB
-- History
--   21-JAN-99  Ramana Yella    Created
--   01-FEB-99  Ramana Yella    Modified the procedure
--   25-FEB-03  Li Wing Poon    R11i.X changes
PROCEDURE mrc_enabled ( n_sob_id       IN  NUMBER,
                        n_appl_id      IN  NUMBER,
                        n_org_id       IN  NUMBER,
                        n_fa_book_code IN  VARCHAR2,
                        n_mrc_enabled  OUT NOCOPY VARCHAR2) IS
BEGIN
   gl_mc_info.alc_enabled(  n_sob_id
                          , n_appl_id
                          , n_org_id
                          , n_fa_book_code
                          , n_mrc_enabled);
END;

-- Procedure
--   get_alc_ledger_id
-- Purpose
--   Fetches all ALC ledger IDs in a list of IDs
-- History
--   25-FEB-03   LPOON      Created (New R11i.X procedure)
PROCEDURE get_alc_ledger_id
   (n_src_ledger_id IN            NUMBER,
    n_alc_id_list   IN OUT NOCOPY id_arr) IS
BEGIN

  SELECT distinct g.target_ledger_id
  BULK COLLECT INTO n_alc_id_list
  FROM gl_ledger_relationships g
  WHERE g.source_ledger_id = n_src_ledger_id
  AND g.target_ledger_category_code = 'ALC'
  AND g.relationship_type_code IN ('SUBLEDGER', 'JOURNAL')
  AND g.relationship_enabled_flag = 'Y';

EXCEPTION
 WHEN others THEN
   NULL;
END;

-- Procedure
--   get_reporting_set_of_books_id
--   *Should call get_alc_ledger_id() and this is for backward compatible
-- Purpose
--   Fetches all the reporting sets of books ids into eight different
--   variables
-- History
--   01-APR-99   MGOWDA     Created (Copied from AP/AR utilities PKG)
--   25-FEB-03   LPOON      R11i.X changes
PROCEDURE get_reporting_set_of_books_id
   (n_psob_id  IN         NUMBER,
    n_rsob_id1 OUT NOCOPY NUMBER,
    n_rsob_id2 OUT NOCOPY NUMBER,
    n_rsob_id3 OUT NOCOPY NUMBER,
    n_rsob_id4 OUT NOCOPY NUMBER,
    n_rsob_id5 OUT NOCOPY NUMBER,
    n_rsob_id6 OUT NOCOPY NUMBER,
    n_rsob_id7 OUT NOCOPY NUMBER,
    n_rsob_id8 OUT NOCOPY NUMBER) IS

  l_rsob_id_list id_arr;
  i              number := 1;
BEGIN
  gl_mc_info.get_alc_ledger_id(n_psob_id, l_rsob_id_list);

  n_rsob_id1 := -1;
  n_rsob_id2 := -1;
  n_rsob_id3 := -1;
  n_rsob_id4 := -1;
  n_rsob_id5 := -1;
  n_rsob_id6 := -1;
  n_rsob_id7 := -1;
  n_rsob_id8 := -1;

  IF (l_rsob_id_list.count >= 1) THEN
    n_rsob_id1 := l_rsob_id_list(1);
  END IF;

  IF (l_rsob_id_list.count >= 2) THEN
    n_rsob_id2 := l_rsob_id_list(2);
  END IF;

  IF (l_rsob_id_list.count >= 3) THEN
    n_rsob_id3 := l_rsob_id_list(3);
  END IF;

  IF (l_rsob_id_list.count >= 4) THEN
    n_rsob_id4 := l_rsob_id_list(4);
  END IF;

  IF (l_rsob_id_list.count >= 5) THEN
    n_rsob_id5 := l_rsob_id_list(5);
  END IF;

  IF (l_rsob_id_list.count >= 6) THEN
    n_rsob_id6 := l_rsob_id_list(6);
  END IF;

  IF (l_rsob_id_list.count >= 7) THEN
    n_rsob_id7 := l_rsob_id_list(7);
  END IF;

  IF (l_rsob_id_list.count >= 8) THEN
    n_rsob_id8 := l_rsob_id_list(8);
  END IF;
END;

-- Procedure
--   get_alc_associated_ledgers
-- Purpose
--   Gets the ALC Source and Target ledgers info
-- History
--   25-FEB-03  Li Wing Poon    Created (New R11i.X procedure)
PROCEDURE get_alc_associated_ledgers
              (n_ledger_id             IN            NUMBER,
               n_appl_id               IN            NUMBER,
               n_org_id                IN            NUMBER,
               n_fa_book_code          IN            VARCHAR2,
               n_include_source_ledger IN            VARCHAR2,
               n_ledger_list           IN OUT NOCOPY r_sob_list) IS
 l_ledger_rec_col  r_sob_rec_col; /* To store the values retrieved by BULK COLLECT */
 l_alc_ledger_type VARCHAR2(30);
 l_alc_enabled     VARCHAR2(1);
 l_src_ledger_id   NUMBER;        /* Variable to store source ledger ID */
 l_num_rec         NUMBER;
 i                 NUMBER;
BEGIN

   /* Get the ALC ledger type of the passed ledger ID */
   gl_mc_info.get_alc_ledger_type(n_ledger_id, l_alc_ledger_type);

   IF l_alc_ledger_type = 'NONE' THEN
     /* If its ALC ledger type is 'NONE', return the ledger list as NULL */
     n_ledger_list.extend;
   ELSE
     /* Otherwise, check if ALC is enabled for the passed application/OU/Ledger */
     gl_mc_info.alc_enabled(  n_ledger_id
                            , n_appl_id
                            , n_org_id
                            , n_fa_book_code
                            , l_alc_enabled);

     IF l_alc_enabled = 'N' THEN
       /* If ALC is not enabled, return the ledger list as NULL */
       n_ledger_list.extend;
     ELSE
       /* If ALC is enabled, get the ledger info based on its ALC ledger type:
           - If its ALC ledger type is 'SOURCE', get the ledger info for the passed
           source ledger and its associated enabled ALC target ledgers, if any.
           - If its ALC ledger type is 'TARGET', get its source ledger ID which is
           enabled for the passed target ledger and get all its associated enabled
           ALC target ledgers */
       IF l_alc_ledger_type = 'SOURCE' THEN
         l_src_ledger_id   := n_ledger_id;
       ELSIF l_alc_ledger_type = 'TARGET' THEN
         /* Get source ledger ID of the passed ALC target ledger/application/OU */
         l_src_ledger_id := gl_mc_info.get_source_ledger_id(  n_ledger_id
                                                            , n_appl_id
                                                            , n_org_id
                                                            , n_fa_book_code);
       END IF; -- IF l_alc_ledger_type = 'SOURCE' THEN

       /* Get the source and target ledgers info, if any and store them into
          l_ledger_rec_col by using BULK COLLECT. We cannot store them directly
          into n_ledger_list since it is table of records (composite) while BULK
          COLLECT can just apply to table of scalar type. */
       SELECT  g.ledger_id,
               g.name,
               g.short_name,
               g.currency_code,
               g.alc_ledger_type_code,
               g.ledger_category_code,
               g.sla_accounting_method_code,
               f.precision,
               f.minimum_accountable_unit,
               DECODE(g.alc_ledger_type_code, 'SOURCE', 'P'
                                            , 'TARGET', 'R'
                                                      , 'N'),
               DECODE(g.alc_ledger_type_code, 'SOURCE', 'Primary'
                                            , 'TARGET', 'Reporting'
                                                      , 'Notassigned')
       BULK COLLECT INTO
               l_ledger_rec_col.r_sob_id,
               l_ledger_rec_col.r_sob_name,
               l_ledger_rec_col.r_sob_short_name,
               l_ledger_rec_col.r_sob_curr,
               l_ledger_rec_col.r_alc_type,
               l_ledger_rec_col.r_category,
               l_ledger_rec_col.r_acct_method_code,
               l_ledger_rec_col.r_precision,
               l_ledger_rec_col.r_mau,
               l_ledger_rec_col.r_sob_type,
               l_ledger_rec_col.r_sob_user_type
       FROM gl_ledgers g,
            fnd_currencies f
       -- Include ALC source ledger if n_include_source_ledger = 'Y' or NULL
       WHERE ((upper(NVL(n_include_source_ledger, 'Y')) = 'Y'
              AND g.ledger_id = l_src_ledger_id)
       OR g.ledger_id IN (
           SELECT glr.target_ledger_id           -- ALC target ledgers
           FROM gl_ledger_relationships glr
           WHERE glr.source_ledger_id = l_src_ledger_id
           AND glr.target_ledger_category_code = 'ALC'
           AND glr.relationship_type_code IN ('SUBLEDGER', 'JOURNAL')
           AND glr.application_id = n_appl_id
           AND (n_org_id IS NULL
                OR glr.org_id = -99
                OR glr.org_id = NVL(n_org_id,-99))
           AND (NVL(n_fa_book_code, '-99') = '-99'
                OR EXISTS
                   (SELECT 'FA book type is enabled'
                    FROM FA_MC_BOOK_CONTROLS MC
                    WHERE MC.set_of_books_id = glr.target_ledger_id
                    AND MC.book_type_code = n_fa_book_code
                    AND MC.primary_set_of_books_id = glr.source_ledger_id
                    AND MC.enabled_flag = 'Y'))
           AND glr.relationship_enabled_flag = 'Y'))
       AND g.currency_code = f.currency_code
       ORDER BY   DECODE(g.ledger_category_code
                          , 'Primary'  , 1
                          , 'Secondary', 2
                                       , 3)
                , g.ledger_id;

       /* Get the number of records retrieved and extend the
          n_ledger_list (table) - allocate spaces */
       l_num_rec := l_ledger_rec_col.r_sob_id.count;
       n_ledger_list.extend(l_num_rec);

       /* Try to store all records from l_ledger_rec_col to n_ledger_list */
       FOR i IN 1..l_num_rec LOOP
         SELECT l_ledger_rec_col.r_sob_id(i),
                l_ledger_rec_col.r_sob_name(i),
                l_ledger_rec_col.r_sob_short_name(i),
                l_ledger_rec_col.r_sob_curr(i),
                l_ledger_rec_col.r_alc_type(i),
                l_ledger_rec_col.r_category(i),
                l_ledger_rec_col.r_acct_method_code(i),
                l_ledger_rec_col.r_precision(i),
                l_ledger_rec_col.r_mau(i),
                l_ledger_rec_col.r_sob_type(i),
                l_ledger_rec_col.r_sob_user_type(i)
         INTO n_ledger_list(i).r_sob_id,
              n_ledger_list(i).r_sob_name,
              n_ledger_list(i).r_sob_short_name,
              n_ledger_list(i).r_sob_curr,
              n_ledger_list(i).r_alc_type,
              n_ledger_list(i).r_category,
              n_ledger_list(i).r_acct_method_code,
              n_ledger_list(i).r_precision,
              n_ledger_list(i).r_mau,
              n_ledger_list(i).r_sob_type,
              n_ledger_list(i).r_sob_user_type
         FROM dual;

       END LOOP; /* FOR LOOP */
     END IF; -- IF l_alc_enabled = 'N' THEN
   END IF; -- IF l_alc_ledger_type = 'NONE'
END;

-- Procedure
--   get_associated_sobs
--   *Should call get_alc_associated_ledgers() instead and this is for backward
--    compatible
-- Purpose
--   Gets the Primary and Reporting set of books info
-- History
--   21-JAN-99   Ramana Yella     Created
--   01-FEB-99   Ramana Yella     Modified the procedure
--   25-JUN-99   Li Wing Poon     Modified to use BULK COLLECT
--   07-MAR-00   Li Wing Poon     Fixed bug 1229907
--   25-FEB-03   Li Wing Poon     R11i.X Changes
PROCEDURE get_associated_sobs ( n_sob_id       IN         NUMBER,
                                n_appl_id      IN         NUMBER,
                                n_org_id       IN         NUMBER,
                                n_fa_book_code IN         VARCHAR2,
                                n_sob_list     IN OUT NOCOPY r_sob_list) IS
BEGIN
  -- This procedure used to include primary SOB, so we put 'Y' to include
  -- ALC source ledger
  gl_mc_info.get_alc_associated_ledgers(  n_sob_id
                                        , n_appl_id
                                        , n_org_id
                                        , n_fa_book_code
                                        , 'Y'
                                        , n_sob_list);
END;

-- Procedure
--   get_alc_associated_ledgers_scalar
-- Purpose
--   Gets the ALC source and target ledgers info
-- History
--   25-FEB-03 LPOON      Created (New R11i.X procedure)
PROCEDURE get_alc_ledgers_scalar
                             (n_ledger_id           IN         NUMBER,
                              n_appl_id             IN         NUMBER,
                              n_org_id              IN         NUMBER,
                              n_fa_book_code        IN         VARCHAR2,
                              n_ledger_id_1         OUT NOCOPY NUMBER,
                              n_ledger_name_1       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_1   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_1   OUT NOCOPY VARCHAR2,
                              n_ledger_category_1   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_1 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_1  OUT NOCOPY VARCHAR2,
                              n_ledger_id_2         OUT NOCOPY NUMBER,
                              n_ledger_name_2       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_2   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_2   OUT NOCOPY VARCHAR2,
                              n_ledger_category_2   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_2 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_2  OUT NOCOPY VARCHAR2,
                              n_ledger_id_3         OUT NOCOPY NUMBER,
                              n_ledger_name_3       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_3   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_3   OUT NOCOPY VARCHAR2,
                              n_ledger_category_3   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_3 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_3  OUT NOCOPY VARCHAR2,
                              n_ledger_id_4         OUT NOCOPY NUMBER,
                              n_ledger_name_4       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_4   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_4   OUT NOCOPY VARCHAR2,
                              n_ledger_category_4   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_4 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_4  OUT NOCOPY VARCHAR2,
                              n_ledger_id_5         OUT NOCOPY NUMBER,
                              n_ledger_name_5       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_5   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_5   OUT NOCOPY VARCHAR2,
                              n_ledger_category_5   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_5 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_5  OUT NOCOPY VARCHAR2,
                              n_ledger_id_6         OUT NOCOPY NUMBER,
                              n_ledger_name_6       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_6   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_6   OUT NOCOPY VARCHAR2,
                              n_ledger_category_6   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_6 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_6  OUT NOCOPY VARCHAR2,
                              n_ledger_id_7         OUT NOCOPY NUMBER,
                              n_ledger_name_7       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_7   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_7   OUT NOCOPY VARCHAR2,
                              n_ledger_category_7   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_7 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_7  OUT NOCOPY VARCHAR2,
                              n_ledger_id_8         OUT NOCOPY NUMBER,
                              n_ledger_name_8       OUT NOCOPY VARCHAR2,
                              n_alc_ledger_type_8   OUT NOCOPY VARCHAR2,
                              n_ledger_currency_8   OUT NOCOPY VARCHAR2,
                              n_ledger_category_8   OUT NOCOPY VARCHAR2,
                              n_ledger_short_name_8 OUT NOCOPY VARCHAR2,
                              n_acct_method_code_8  OUT NOCOPY VARCHAR2) IS
 l_ledger_list       gl_mc_info.r_sob_list := gl_mc_info.r_sob_list();
 l_ledger_list_count NUMBER;
BEGIN
  gl_mc_info.get_alc_associated_ledgers(  n_ledger_id
                                        , n_appl_id
                                        , n_org_id
                                        , n_fa_book_code
                                        , 'Y' -- Include ALC source ledger
                                        , l_ledger_list);

  l_ledger_list_count := l_ledger_list.COUNT;

  IF (l_ledger_list_count >= 1) THEN
    n_ledger_id_1          := l_ledger_list(1).r_sob_id;
    n_ledger_name_1        := l_ledger_list(1).r_sob_name;
    n_ledger_short_name_1  := l_ledger_list(1).r_sob_short_name;
    n_ledger_currency_1    := l_ledger_list(1).r_sob_curr;
    n_alc_ledger_type_1    := l_ledger_list(1).r_alc_type;
    n_ledger_category_1    := l_ledger_list(1).r_category;
    n_acct_method_code_1   := l_ledger_list(1).r_acct_method_code;
  END IF;

  IF (l_ledger_list_count >= 2) THEN
    n_ledger_id_2          := l_ledger_list(2).r_sob_id;
    n_ledger_name_2        := l_ledger_list(2).r_sob_name;
    n_ledger_short_name_2  := l_ledger_list(2).r_sob_short_name;
    n_ledger_currency_2    := l_ledger_list(2).r_sob_curr;
    n_alc_ledger_type_2    := l_ledger_list(2).r_alc_type;
    n_ledger_category_2    := l_ledger_list(2).r_category;
    n_acct_method_code_2   := l_ledger_list(1).r_acct_method_code;
  END IF;

  IF (l_ledger_list_count >= 3) THEN
    n_ledger_id_3          := l_ledger_list(3).r_sob_id;
    n_ledger_name_3        := l_ledger_list(3).r_sob_name;
    n_ledger_short_name_3  := l_ledger_list(3).r_sob_short_name;
    n_ledger_currency_3    := l_ledger_list(3).r_sob_curr;
    n_alc_ledger_type_3    := l_ledger_list(3).r_alc_type;
    n_ledger_category_3    := l_ledger_list(3).r_category;
    n_acct_method_code_3   := l_ledger_list(1).r_acct_method_code;
  END IF;

  IF (l_ledger_list_count >= 4) THEN
    n_ledger_id_4          := l_ledger_list(4).r_sob_id;
    n_ledger_name_4        := l_ledger_list(4).r_sob_name;
    n_ledger_short_name_4  := l_ledger_list(4).r_sob_short_name;
    n_ledger_currency_4    := l_ledger_list(4).r_sob_curr;
    n_alc_ledger_type_4    := l_ledger_list(4).r_alc_type;
    n_ledger_category_4    := l_ledger_list(4).r_category;
    n_acct_method_code_4   := l_ledger_list(1).r_acct_method_code;
  END IF;

  IF (l_ledger_list_count >= 5) THEN
    n_ledger_id_5          := l_ledger_list(5).r_sob_id;
    n_ledger_name_5        := l_ledger_list(5).r_sob_name;
    n_ledger_short_name_5  := l_ledger_list(5).r_sob_short_name;
    n_ledger_currency_5    := l_ledger_list(5).r_sob_curr;
    n_alc_ledger_type_5    := l_ledger_list(5).r_alc_type;
    n_ledger_category_5    := l_ledger_list(5).r_category;
    n_acct_method_code_5   := l_ledger_list(1).r_acct_method_code;
  END IF;

  IF (l_ledger_list_count >= 6) THEN
    n_ledger_id_6          := l_ledger_list(6).r_sob_id;
    n_ledger_name_6        := l_ledger_list(6).r_sob_name;
    n_ledger_short_name_6  := l_ledger_list(6).r_sob_short_name;
    n_ledger_currency_6    := l_ledger_list(6).r_sob_curr;
    n_alc_ledger_type_6    := l_ledger_list(6).r_alc_type;
    n_ledger_category_6    := l_ledger_list(6).r_category;
    n_acct_method_code_6   := l_ledger_list(1).r_acct_method_code;
  END IF;

  IF (l_ledger_list_count >= 7) THEN
    n_ledger_id_7          := l_ledger_list(7).r_sob_id;
    n_ledger_name_7        := l_ledger_list(7).r_sob_name;
    n_ledger_short_name_7  := l_ledger_list(7).r_sob_short_name;
    n_ledger_currency_7    := l_ledger_list(7).r_sob_curr;
    n_alc_ledger_type_7    := l_ledger_list(7).r_alc_type;
    n_ledger_category_7    := l_ledger_list(7).r_category;
    n_acct_method_code_7   := l_ledger_list(1).r_acct_method_code;
  END IF;

  IF (l_ledger_list_count >= 8) THEN
    n_ledger_id_8          := l_ledger_list(8).r_sob_id;
    n_ledger_name_8        := l_ledger_list(8).r_sob_name;
    n_ledger_short_name_8  := l_ledger_list(8).r_sob_short_name;
    n_ledger_currency_8    := l_ledger_list(8).r_sob_curr;
    n_alc_ledger_type_8    := l_ledger_list(8).r_alc_type;
    n_ledger_category_8    := l_ledger_list(8).r_category;
    n_acct_method_code_8   := l_ledger_list(1).r_acct_method_code;
  END IF;
END;

-- Procedure
--   get_associated_sobs_scalar
--   *Should call get_alc_associated_ledgers_scalar() instead and this is for
--    backward compatible
-- Purpose
--   Gets the Primary and Reporting set of books info
-- History
--   02-AUG-99   SSIVASUB     Created
--   25-FEB-03   LPOON        R11i.X changes
PROCEDURE get_associated_sobs_scalar
              (p_sob_id           IN         NUMBER,
               p_appl_id          IN         NUMBER,
               p_org_id           IN         NUMBER,
               p_fa_book_code     IN         VARCHAR2,
               p_sob_id_1         OUT NOCOPY NUMBER,
               p_sob_name_1       OUT NOCOPY VARCHAR2,
               p_sob_type_1       OUT NOCOPY VARCHAR2,
               p_sob_curr_1       OUT NOCOPY VARCHAR2,
               p_sob_user_type_1  OUT NOCOPY VARCHAR2,
               p_sob_short_name_1 OUT NOCOPY VARCHAR2,
               p_sob_id_2         OUT NOCOPY NUMBER,
               p_sob_name_2       OUT NOCOPY VARCHAR2,
               p_sob_type_2       OUT NOCOPY VARCHAR2,
               p_sob_curr_2       OUT NOCOPY VARCHAR2,
               p_sob_user_type_2  OUT NOCOPY VARCHAR2,
               p_sob_short_name_2 OUT NOCOPY VARCHAR2,
               p_sob_id_3         OUT NOCOPY NUMBER,
               p_sob_name_3       OUT NOCOPY VARCHAR2,
               p_sob_type_3       OUT NOCOPY VARCHAR2,
               p_sob_curr_3       OUT NOCOPY VARCHAR2,
               p_sob_user_type_3  OUT NOCOPY VARCHAR2,
               p_sob_short_name_3 OUT NOCOPY VARCHAR2,
               p_sob_id_4         OUT NOCOPY NUMBER,
               p_sob_name_4       OUT NOCOPY VARCHAR2,
               p_sob_type_4       OUT NOCOPY VARCHAR2,
               p_sob_curr_4       OUT NOCOPY VARCHAR2,
               p_sob_user_type_4  OUT NOCOPY VARCHAR2,
               p_sob_short_name_4 OUT NOCOPY VARCHAR2,
               p_sob_id_5         OUT NOCOPY NUMBER,
               p_sob_name_5       OUT NOCOPY VARCHAR2,
               p_sob_type_5       OUT NOCOPY VARCHAR2,
               p_sob_curr_5       OUT NOCOPY VARCHAR2,
               p_sob_user_type_5  OUT NOCOPY VARCHAR2,
               p_sob_short_name_5 OUT NOCOPY VARCHAR2,
               p_sob_id_6         OUT NOCOPY NUMBER,
               p_sob_name_6       OUT NOCOPY VARCHAR2,
               p_sob_type_6       OUT NOCOPY VARCHAR2,
               p_sob_curr_6       OUT NOCOPY VARCHAR2,
               p_sob_user_type_6  OUT NOCOPY VARCHAR2,
               p_sob_short_name_6 OUT NOCOPY VARCHAR2,
               p_sob_id_7         OUT NOCOPY NUMBER,
               p_sob_name_7       OUT NOCOPY VARCHAR2,
               p_sob_type_7       OUT NOCOPY VARCHAR2,
               p_sob_curr_7       OUT NOCOPY VARCHAR2,
               p_sob_user_type_7  OUT NOCOPY VARCHAR2,
               p_sob_short_name_7 OUT NOCOPY VARCHAR2,
               p_sob_id_8         OUT NOCOPY NUMBER,
               p_sob_name_8       OUT NOCOPY VARCHAR2,
               p_sob_type_8       OUT NOCOPY VARCHAR2,
               p_sob_curr_8       OUT NOCOPY VARCHAR2,
               p_sob_user_type_8  OUT NOCOPY VARCHAR2,
               p_sob_short_name_8 OUT NOCOPY VARCHAR2) IS
 l_sob_list       gl_mc_info.r_sob_list := gl_mc_info.r_sob_list();
 l_sob_list_count NUMBER;
BEGIN
  -- This procedure used to include primary SOB, so we put 'Y' to include
  -- ALC source ledger
  gl_mc_info.get_alc_associated_ledgers(  p_sob_id
                                        , p_appl_id
                                        , p_org_id
                                        , p_fa_book_code
                                        , 'Y'
                                        , l_sob_list);

  l_sob_list_count := l_sob_list.COUNT;

  IF (l_sob_list_count >= 1) THEN
    p_sob_id_1             := l_sob_list(1).r_sob_id;
    p_sob_name_1           := l_sob_list(1).r_sob_name;
    p_sob_type_1           := l_sob_list(1).r_sob_type;
    p_sob_curr_1           := l_sob_list(1).r_sob_curr;
    p_sob_user_type_1      := l_sob_list(1).r_sob_user_type;
    p_sob_short_name_1     := l_sob_list(1).r_sob_short_name;
  END IF;

  IF (l_sob_list_count >= 2) THEN
    p_sob_id_2             := l_sob_list(2).r_sob_id;
    p_sob_name_2           := l_sob_list(2).r_sob_name;
    p_sob_type_2           := l_sob_list(2).r_sob_type;
    p_sob_curr_2           := l_sob_list(2).r_sob_curr;
    p_sob_user_type_2      := l_sob_list(2).r_sob_user_type;
    p_sob_short_name_2     := l_sob_list(2).r_sob_short_name;
  END IF;

  IF (l_sob_list_count >= 3) THEN
    p_sob_id_3             := l_sob_list(3).r_sob_id;
    p_sob_name_3           := l_sob_list(3).r_sob_name;
    p_sob_type_3           := l_sob_list(3).r_sob_type;
    p_sob_curr_3           := l_sob_list(3).r_sob_curr;
    p_sob_user_type_3      := l_sob_list(3).r_sob_user_type;
    p_sob_short_name_3     := l_sob_list(3).r_sob_short_name;
  END IF;

  IF (l_sob_list_count >= 4) THEN
    p_sob_id_4             := l_sob_list(4).r_sob_id;
    p_sob_name_4           := l_sob_list(4).r_sob_name;
    p_sob_type_4           := l_sob_list(4).r_sob_type;
    p_sob_curr_4           := l_sob_list(4).r_sob_curr;
    p_sob_user_type_4      := l_sob_list(4).r_sob_user_type;
    p_sob_short_name_4     := l_sob_list(4).r_sob_short_name;
  END IF;

  IF (l_sob_list_count >= 5) THEN
    p_sob_id_5             := l_sob_list(5).r_sob_id;
    p_sob_name_5           := l_sob_list(5).r_sob_name;
    p_sob_type_5           := l_sob_list(5).r_sob_type;
    p_sob_curr_5           := l_sob_list(5).r_sob_curr;
    p_sob_user_type_5      := l_sob_list(5).r_sob_user_type;
    p_sob_short_name_5     := l_sob_list(5).r_sob_short_name;
  END IF;

  IF (l_sob_list_count >= 6) THEN
    p_sob_id_6             := l_sob_list(6).r_sob_id;
    p_sob_name_6           := l_sob_list(6).r_sob_name;
    p_sob_type_6           := l_sob_list(6).r_sob_type;
    p_sob_curr_6           := l_sob_list(6).r_sob_curr;
    p_sob_user_type_6      := l_sob_list(6).r_sob_user_type;
    p_sob_short_name_6     := l_sob_list(6).r_sob_short_name;
  END IF;

  IF (l_sob_list_count >= 7) THEN
    p_sob_id_7             := l_sob_list(7).r_sob_id;
    p_sob_name_7           := l_sob_list(7).r_sob_name;
    p_sob_type_7           := l_sob_list(7).r_sob_type;
    p_sob_curr_7           := l_sob_list(7).r_sob_curr;
    p_sob_user_type_7      := l_sob_list(7).r_sob_user_type;
    p_sob_short_name_7     := l_sob_list(7).r_sob_short_name;
  END IF;

  IF (l_sob_list_count >= 8) THEN
    p_sob_id_8             := l_sob_list(8).r_sob_id;
    p_sob_name_8           := l_sob_list(8).r_sob_name;
    p_sob_type_8           := l_sob_list(8).r_sob_type;
    p_sob_curr_8           := l_sob_list(8).r_sob_curr;
    p_sob_user_type_8      := l_sob_list(8).r_sob_user_type;
    p_sob_short_name_8     := l_sob_list(8).r_sob_short_name;
  END IF;

END;

-- Procedure
--   get_sec_associated_ledgers
-- Purpose
--   Gets the primary and all its secondary ledgers
-- History
--   25-FEB-03  Li Wing Poon    Created (New R11i.X procedure)
PROCEDURE get_sec_associated_ledgers
              (n_ledger_id              IN            NUMBER,
               n_appl_id                IN            NUMBER,
               n_org_id                 IN            NUMBER,
               n_include_primary_ledger IN            VARCHAR2,
               n_ledger_list            IN OUT NOCOPY r_sob_list) IS
 l_ledger_rec_col  r_sob_rec_col; -- To store the values retrieved by BULK COLLECT
 l_ledger_category VARCHAR2(30);
 l_pri_ledger_id   NUMBER;        -- Variable to store source ledger ID
 l_num_rec         NUMBER;
 i                 NUMBER;
BEGIN

   -- Get the ledger category of the passed ledger ID
   gl_mc_info.get_ledger_category(n_ledger_id, l_ledger_category);

   IF l_ledger_category = 'ALC' OR l_ledger_category = 'NONE' THEN
     -- If it is ALC or NONE ledger, return the ledger list as NULL
     n_ledger_list.extend;
   ELSE
     IF l_ledger_category = 'PRIMARY' THEN
       l_pri_ledger_id := n_ledger_id;
     ELSIF l_ledger_category = 'SECONDARY' THEN
       -- Get primary ledger ID of the passed secondary ledger/applciation/OU
       l_pri_ledger_id := gl_mc_info.get_primary_ledger_id(  n_ledger_id
                                                           , n_appl_id
                                                           , n_org_id);
     END IF; -- IF l_ledger_category = 'PRIMARY' THEN

     -- Get the source and target ledgers info, if any and store them into
     -- l_ledger_rec_col by using BULK COLLECT. We cannot store them directly
     -- into n_ledger_list since it is table of records (composite) while BULK
     -- COLLECT can just apply to table of scalar type.
     SELECT g.ledger_id,
            g.name,
            g.short_name,
            g.currency_code,
            g.alc_ledger_type_code,
            g.ledger_category_code,
            g.sla_accounting_method_code,
            f.precision,
            f.minimum_accountable_unit,
            DECODE(g.alc_ledger_type_code, 'SOURCE', 'P'
                                         , 'TARGET', 'R'
                                                   , 'N'),
            DECODE(g.alc_ledger_type_code, 'SOURCE', 'Primary'
                                         , 'TARGET', 'Reporting'
                                                   , 'Notassigned')
     BULK COLLECT INTO
            l_ledger_rec_col.r_sob_id,
            l_ledger_rec_col.r_sob_name,
            l_ledger_rec_col.r_sob_short_name,
            l_ledger_rec_col.r_sob_curr,
            l_ledger_rec_col.r_alc_type,
            l_ledger_rec_col.r_category,
            l_ledger_rec_col.r_acct_method_code,
            l_ledger_rec_col.r_precision,
            l_ledger_rec_col.r_mau,
            l_ledger_rec_col.r_sob_type,
            l_ledger_rec_col.r_sob_user_type
     FROM gl_ledgers g,
          fnd_currencies f
     -- Include primary ledger only if n_include_primary_ledger is Y or NULL
     WHERE ((upper(NVL(n_include_primary_ledger, 'Y')) = 'Y'
             AND g.ledger_id = l_pri_ledger_id)
            OR g.ledger_id IN (
                SELECT glr.target_ledger_id      -- Secondary Ledgers
                FROM gl_ledger_relationships glr, gl_ledgers lgr_c
                WHERE glr.primary_ledger_id = l_pri_ledger_id
                AND glr.target_ledger_category_code = 'SECONDARY'
                AND glr.relationship_type_code <> 'NONE'
                AND glr.target_ledger_id = lgr_c.ledger_id
                AND NVL(lgr_c.complete_flag,'Y') = 'Y'
                AND glr.application_id = n_appl_id
                AND (n_org_id IS NULL
                     OR glr.org_id = -99
                     OR glr.org_id = NVL(n_org_id,-99))
                AND glr.relationship_enabled_flag = 'Y'))
     AND g.currency_code = f.currency_code
     ORDER BY   DECODE(g.ledger_category_code
                        , 'Primary'  , 1
                        , 'Secondary', 2
                                     , 3)
              , g.ledger_id;

     -- Get the number of records retrieved and extend the
     -- n_ledger_list (table) - allocate spaces
     l_num_rec := l_ledger_rec_col.r_sob_id.count;
     n_ledger_list.extend(l_num_rec);

     -- If no records are fetched, return the ledger list as NULL
     IF (l_num_rec = 0) THEN
       n_ledger_list.extend;
     ELSE
       -- Try to store all records from l_ledger_rec_col to n_ledger_list
       FOR i IN 1..l_num_rec LOOP
         SELECT l_ledger_rec_col.r_sob_id(i),
                l_ledger_rec_col.r_sob_name(i),
                l_ledger_rec_col.r_sob_short_name(i),
                l_ledger_rec_col.r_sob_curr(i),
                l_ledger_rec_col.r_alc_type(i),
                l_ledger_rec_col.r_category(i),
                l_ledger_rec_col.r_acct_method_code(i),
                l_ledger_rec_col.r_precision(i),
                l_ledger_rec_col.r_mau(i),
                l_ledger_rec_col.r_sob_type(i),
                l_ledger_rec_col.r_sob_user_type(i)
           INTO n_ledger_list(i).r_sob_id,
                n_ledger_list(i).r_sob_name,
                n_ledger_list(i).r_sob_short_name,
                n_ledger_list(i).r_sob_curr,
                n_ledger_list(i).r_alc_type,
                n_ledger_list(i).r_category,
                n_ledger_list(i).r_acct_method_code,
                n_ledger_list(i).r_precision,
                n_ledger_list(i).r_mau,
                n_ledger_list(i).r_sob_type,
                n_ledger_list(i).r_sob_user_type
          FROM dual;
       END LOOP; -- FOR LOOP
     END IF; -- IF (l_num_rec = 0) THEN
   END IF; -- IF l_ledger_category = 'ALC' OR l_ledger_category = 'NONE' THEN
END;

-- Procedure
--   ap_ael_sobs
--   *Should call get_alc_associated_ledgers() or get_sec_associated_ledgers()
--    instead and this is for backward compatible
--   **After AP uptake SLA, this API could be deleted.
-- Purpose
--   This api takes the PL/SQL table with AP primary book info and returns the
--   PL/SQL table with additional rows containing any associated reporting SOBS
-- History
--   03-MAR-99       Ramana Yella   Created
--   16-MAR-00       MGOWDA         Fixed bug 1238127
--   22-MAY-00       LPOON          Set encumb_flag = 'N' for RSOBs only
--   25-FEB-03       LPOON          R11i.X Changes
PROCEDURE ap_ael_sobs (ael_sob_info IN OUT NOCOPY t_ael_sob_info) IS

 l_aa          gl_mc_info.t_ael_sob_info;
 l_sob_list    gl_mc_info.r_sob_list := gl_mc_info.r_sob_list();
 l_cnt         NUMBER := 0;
 i             NUMBER := 0;
 j             NUMBER := 0;
 l_client_info VARCHAR2(64);
 l_org_id      NUMBER(15);
 l_pri_curr    VARCHAR(15);
BEGIN
  l_aa := ael_sob_info;
  ael_sob_info.delete;

  dbms_application_info.read_client_info(l_client_info);
  --
  -- Bug 1238127, not able to convert to number when customer is not multiorg.
  -- replaced spaces with null.
  --
  l_client_info := REPLACE(SUBSTR(l_client_info,1,10),' ',null);
  l_org_id := to_number(l_client_info);

  FOR rec in 1..l_aa.count LOOP
      l_cnt := l_cnt + 1;
      IF l_aa(l_cnt).sob_id IS NOT NULL THEN
        -- Insert itself into the result list
        j := j + 1;
        BEGIN
          SELECT currency_code, name
            INTO ael_sob_info(j).currency_code,
                 ael_sob_info(j).sob_name
            FROM gl_ledgers
           WHERE ledger_id = l_aa(l_cnt).sob_id;
        EXCEPTION
          WHEN OTHERS THEN
            fnd_message.set_name('SQLGL','MRC_TABLE_ERROR');
            fnd_message.set_token('MODULE','GLMCINFB');
            fnd_message.set_token('TABLE','GL_LEDGERS');
            RAISE_APPLICATION_ERROR(-20010, fnd_message.get);
        END;

        ael_sob_info(j).sob_id := l_aa(l_cnt).sob_id;
        ael_sob_info(j).accounting_method := l_aa(l_cnt).accounting_method;
        ael_sob_info(j).encumb_flag := l_aa(l_cnt).encumb_flag;
        ael_sob_info(j).sob_type := l_aa(l_cnt).sob_type;

        IF (l_aa(l_cnt).sob_type = 'P') THEN
          -- Primary SOB => Get its associated reporting SOBs and reporting
          --                secondary SOBs
          l_pri_curr := ael_sob_info(j).currency_code;

          -- Get all the associated reporting secondary SOBs which are
		  -- converted to secondary ledgers with currency different with
		  -- primary currency (*exclude primary and will get it later)
          gl_mc_info.get_sec_associated_ledgers(  l_aa(l_cnt).sob_id
                                                , 200 -- AP
                                                , l_org_id
                                                , 'N' -- Exclude primary ledger
                                                , l_sob_list);

          IF (l_sob_list.count > 0 AND l_sob_list(1).r_sob_id IS NOT NULL) THEN
            FOR rec1 in 1..l_sob_list.count LOOP
              -- Only process if its currency is different with the primary
              -- currency as other secondary SOBs with same currency are
              -- passed in already
   	      IF (l_sob_list(i).r_sob_curr <> l_pri_curr) THEN
                i := i + 1;
                j := j + 1;

                ael_sob_info(j).sob_id := l_sob_list(i).r_sob_id;
                ael_sob_info(j).currency_code := l_sob_list(i).r_sob_curr;
                ael_sob_info(j).sob_name := l_sob_list(i).r_sob_name;

                IF (l_sob_list(i).r_acct_method_code = 'STANDARD_CASH') THEN
                  ael_sob_info(j).accounting_method := 'Cash';
                ELSE
                  ael_sob_info(j).accounting_method := 'Accrual';
                END IF;

                IF l_sob_list(i).r_sob_type = 'R' THEN
                  ael_sob_info(j).sob_type  := 'R';
                  -- Set encumb_flag to 'N' for RSOBs
                  ael_sob_info(j).encumb_flag := 'N';
                ELSE
                  ael_sob_info(j).sob_type  := NULL;
                  -- Set encumb_flag as original value for others
                  ael_sob_info(j).encumb_flag := l_aa(l_cnt).encumb_flag;
                END IF;
              END IF; -- IF (l_sob_list(i).r_sob_curr <> l_pri_curr) THEN
            END LOOP; -- FOR LOOP rec1
          END IF; -- IF (l_sob_list.count > 0 AND l_sob_list(1).r_sob_id ...

          -- Reset counter, i and clean up l_sob_list before getting associated
          -- ALC ledgers
          i := 0;
          l_sob_list.delete;

          -- Get all the associated ALC target ledgers (i.e. reporting SOBs)
          gl_mc_info.get_alc_associated_ledgers(  l_aa(l_cnt).sob_id
                                                , 200 -- AP
                                                , l_org_id
                                                , NULL
                                                , 'N' -- Exclude ALC source ledger
                                                , l_sob_list);

          IF (l_sob_list.count > 0 AND l_sob_list(1).r_sob_id IS NOT NULL) THEN
            FOR rec1 in 1..l_sob_list.count LOOP
              i := i + 1;
              j := j + 1;

              ael_sob_info(j).sob_id := l_sob_list(i).r_sob_id;
              ael_sob_info(j).currency_code := l_sob_list(i).r_sob_curr;
              ael_sob_info(j).accounting_method := l_aa(l_cnt).accounting_method;
              ael_sob_info(j).sob_name := l_sob_list(i).r_sob_name;
              ael_sob_info(j).sob_type  := 'R';
              -- Set encumb_flag to 'N' for RSOBs
              ael_sob_info(j).encumb_flag := 'N';
            END LOOP; -- FOR LOOP rec1
          END IF; -- IF (l_sob_list.count > 0 AND l_sob_list(1).r_sob_id ...

          -- Reset counter, i and cleanup l_sob_list before handling next sob
          i := 0;
          l_sob_list.delete;
        END IF; -- IF (l_aa(l_cnt).sob_type = 'P') THEN
      END IF; -- IF l_aa(l_cnt).sob_id IS NOT NULL THEN
  END LOOP; -- FOR LOOP rec
END;

-- Function
--   get_conversion_type
-- History
--   01-MAR-99       Ramana Yella          Created
--   25-FEB-03       Li Wing Poon          R11i.X changes
--   18-Apr-05       Li Wing Poon          SLA uptake - we don't need this
--                                         function anymore
FUNCTION get_conversion_type (pk_id  IN NUMBER,
                              sob_id IN NUMBER,
                              source IN VARCHAR2,
                              ptype  IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
--  RETURN ap_mc_info.get_conversion_type(pk_id, sob_id, source, ptype);
  RETURN NULL;
END;

-- Function
--   get_conversion_date
-- History
--   02-MAR-99       Ramana Yella          Created
--   25-FEB-03       Li Wing Poon          R11i.X Changes
--   18-Apr-05       Li Wing Poon          SLA uptake - we don't need this
--                                         function anymore
FUNCTION get_conversion_date (pk_id  IN NUMBER,
                              sob_id IN NUMBER,
                              source IN VARCHAR2,
                              ptype  IN VARCHAR2) RETURN DATE IS
BEGIN
--  RETURN ap_mc_info.get_conversion_date(pk_id, sob_id, source, ptype);
  RETURN NULL;
END;

-- Function
--   get_conversion_rate
-- History
--   02-MAR-99       Ramana Yella          Created
--   25-FEB-03       Li Wing Poon          R11i.X changes
--   18-Apr-05       Li Wing Poon          SLA uptake - we don't need this
--                                         function anymore
FUNCTION get_conversion_rate (pk_id  IN NUMBER,
                              sob_id IN NUMBER,
                              source IN VARCHAR2,
                              ptype  IN VARCHAR2) RETURN NUMBER IS
BEGIN
--  RETURN ap_mc_info.get_conversion_rate(pk_id, sob_id, source, ptype);
  RETURN NULL;
END;

-- Function
--   get_acctd_amount
-- History
--   28-APR-98  MGOWDA       Created
--   25-FEB-03  LPOON        R11i.X changes
--   18-Apr-05  LPOON        SLA uptake - we don't need this function anymore
FUNCTION get_acctd_amount( pk_id       IN NUMBER,
                           sob_id      IN NUMBER,
                           source      IN VARCHAR2,
                           amount_type IN VARCHAR2) RETURN NUMBER IS
BEGIN
--  RETURN ap_mc_info.get_acctd_amount(pk_id, sob_id, source, amount_type);
  RETURN NULL;
END;

-- Function
--   get_ccid
-- History
--   21-MAY-01  LPOON       Created
--   25-FEB-03  LPOON        R11i.X changes
--   18-Apr-05  LPOON        SLA uptake - we don't need this function anymore
FUNCTION get_ccid ( pk_id     IN NUMBER,
                    sob_id    IN NUMBER,
                    source    IN VARCHAR2,
                    ccid_type IN VARCHAR2) RETURN NUMBER IS
BEGIN
--  RETURN ap_mc_info.get_ccid(pk_id, sob_id, source, ccid_type);
  RETURN NULL;
END;

-- Procedure
--   populate_ledger_bsv_gt
-- Purpose
--   This api populates the table with flex values which will be used during
--   Accounting setup flow BSV assignments.  The table is populated with flex
--   values from the standard FND tables or custom tables depending on the
--   flex value set id.
-- History
--   16-JUL-03       MGOWDA     Created

PROCEDURE populate_ledger_bsv_gt (n_ledger_id IN NUMBER)
IS
  l_insert_statement DBMS_SQL.VARCHAR2S;
  l_line_num   NUMBER := 1;
  l_cursor integer;
  l_fv_table varchar2(30);
  l_fv_col varchar2(30);
  l_fv_type fnd_flex_value_sets.validation_type%TYPE;
  l_fv_description fnd_flex_validation_tables.meaning_column_name%TYPE;
  rows_processed number;
  l_status varchar2(30);
BEGIN

  -- Bug fix 3975695: Moved the codes to assign default values from
  --                  declaration to here
  l_status := 'Initialize';

  --
  -- It is possible that during working on the same configuration BSV
  -- assignment page could be accessed multiple times so check to see if
  -- the BSV values already exists in temporary table

  BEGIN
    SELECT 'Already Populated'
    INTO   l_status
    FROM dual
    WHERE EXISTS
       (SELECT 'x'
        FROM gl_ledger_bsv_gt
        WHERE ledger_id = n_ledger_id);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_status := 'Initialize';
  END;

  IF l_status = 'Initialize'
  THEN
    BEGIN
      SELECT   nvl(fvt.application_table_name, 'FND_FLEX_VALUES')
             , nvl(fvt.value_column_name, 'FLEX_VALUE')
             , fvs.validation_type
             , nvl(fvt.meaning_column_name, 'DESCRIPTION')
      INTO       l_fv_table
             , l_fv_col
             , l_fv_type
             , l_fv_description
      FROM     fnd_flex_value_sets fvs
             , fnd_flex_validation_tables fvt
             , gl_ledgers gl
      WHERE    fvs.flex_value_set_id = gl.bal_seg_value_set_id
        AND    gl.ledger_id = n_ledger_id
        AND    fvt.flex_value_set_id = fvs.flex_value_set_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_fv_table := 'FND_FLEX_VALUES';
        l_fv_col := 'FLEX_VALUE';
        l_fv_type := NULL;
        l_fv_description := 'DESCRIPTION';
    END;

    IF (nvl(l_fv_type,'X') <> 'F')
    THEN

      INSERT INTO GL_LEDGER_BSV_GT
      ( FLEX_VALUE
       ,DESCRIPTION
       ,LEDGER_ID
      )
      SELECT FlexValues.FLEX_VALUE,
             FlexValues.DESCRIPTION,
             n_ledger_id
      FROM   GL_LEDGERS           Ledgers,
             FND_FLEX_VALUES_VL   FlexValues
      WHERE FlexValues.FLEX_VALUE_SET_ID  = Ledgers.bal_seg_value_set_id
        AND Ledgers.ledger_id = n_ledger_id
        AND FlexValues.SUMMARY_FLAG           = 'N';
    ELSE
      l_insert_statement(l_line_num) := 'INSERT INTO gl_ledger_bsv_gt ';
      l_line_num := l_line_num + 1;
      l_insert_statement(l_line_num) := '(FLEX_VALUE,DESCRIPTION,LEDGER_ID)';
      l_line_num := l_line_num + 1;
      l_insert_statement(l_line_num) := 'SELECT '||l_fv_col||',';
      l_line_num := l_line_num + 1;
      l_insert_statement(l_line_num) := l_fv_description||','||n_ledger_id;
      l_line_num := l_line_num + 1;
      l_insert_statement(l_line_num) := 'FROM '||l_fv_table;
      l_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(l_cursor, l_insert_statement,1,
                    l_line_Num, true, dbms_sql.native);
      rows_processed := dbms_sql.execute(l_cursor);
      dbms_sql.close_cursor(l_cursor);
    END IF;
  END IF;
END;


END gl_mc_info;

/
