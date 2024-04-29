--------------------------------------------------------
--  DDL for Package Body HRI_OPL_JOBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_JOBH" AS
/* $Header: hripjobh.pkb 120.4 2006/10/11 15:38:06 jtitmas noship $ */

-- Value sets used to define job levels
g_job_fmly_vset_id     NUMBER;
g_job_fnctn_vset_id    NUMBER;

-- HRI schema name
g_hri_schema           VARCHAR2(30);

-- Full refresh mode
g_full_refresh         VARCHAR2(30);

-- Whether job levels are populated from KEY or DESCRIPTIVE flexs
g_job_fmly_flex_type   VARCHAR2(30);
g_job_fnctn_flex_type  VARCHAR2(30);

-- Record for caching job family and function flex columns
TYPE job_group_rec IS RECORD
 (job_fmly_column      VARCHAR2(30),
  job_fnctn_column     VARCHAR2(30));

-- Cache for flex columns
TYPE job_flex_tab_type IS TABLE OF job_group_rec INDEX BY VARCHAR2(300);
job_flex_cache         job_flex_tab_type;
job_flex_reset         job_flex_tab_type;

-- Return character
g_rtn                  VARCHAR2(5) := '
';

-- -------------------------------------------------------------------------
-- Inserts row into concurrent program log
-- -------------------------------------------------------------------------
PROCEDURE output(p_text  VARCHAR2) IS

BEGIN
  hri_bpl_conc_log.output(p_text);
END output;

-- -------------------------------------------------------------------------
-- Inserts row into concurrent program log if debugging is enabled
-- -------------------------------------------------------------------------
PROCEDURE dbg(p_text  VARCHAR2) IS

BEGIN
  hri_bpl_conc_log.dbg(p_text);
END dbg;

-- ----------------------------------------------------------------------------
-- 3601362 Runs given sql statement dynamically without raising an exception
-- ----------------------------------------------------------------------------
PROCEDURE run_sql_stmt_noerr(p_sql_stmt   VARCHAR2) IS

BEGIN
  EXECUTE IMMEDIATE p_sql_stmt;
EXCEPTION WHEN OTHERS THEN
  output('Could not run the following sql:');
  output(SUBSTR(p_sql_stmt,1,230));
  dbg(sqlerrm);
END run_sql_stmt_noerr;

-- --------------------------------------------------------------------
-- Returns whether a job family/function valueset is stored against
-- the KEY or DESCRIPTIVE flexfield or neither (NULL)
-- --------------------------------------------------------------------
FUNCTION get_flexfield_type(p_job_type      IN VARCHAR2,
                            p_value_set_id  IN NUMBER)
    RETURN VARCHAR2 IS

  CURSOR full_keyflex_csr IS
  SELECT 'KEY'
  FROM fnd_id_flex_segments_vl
  WHERE application_id = 800
  AND id_flex_code = 'JOB'
  AND flex_value_set_id = p_value_set_id
  AND rownum = 1;

  CURSOR full_descr_flex_csr IS
  SELECT 'DESCRIPTIVE'
  FROM
   fnd_descr_flex_col_usage_vl  dfcu
  WHERE dfcu.descriptive_flexfield_name = 'PER_JOBS'
  AND dfcu.application_id = 800
  AND dfcu.flex_value_set_id = p_value_set_id
  AND rownum = 1;

  CURSOR incr_jfm_flex_type_csr IS
  SELECT
   flexfield_type
  FROM
   hri_cnfg_jobh_flex_cols
  WHERE job_fmly_column IS NOT NULL
  AND rownum = 1;

  CURSOR incr_jfn_flex_type_csr IS
  SELECT
   flexfield_type
  FROM
   hri_cnfg_jobh_flex_cols
  WHERE job_fnctn_column IS NOT NULL
  AND rownum = 1;

  l_flexfield_type   VARCHAR2(30);

BEGIN

  -- In full refresh mode check the flexfield structure for
  -- the corresponding valueset associated with the job type
  IF (g_full_refresh = 'Y' OR
      g_full_refresh IS NULL) THEN

    -- Check if the valueset is linked to a keyflex
    OPEN full_keyflex_csr;
    FETCH full_keyflex_csr INTO l_flexfield_type;
    CLOSE full_keyflex_csr;

    -- If no keyflex link try descriptive
    IF (l_flexfield_type IS NULL) THEN
      OPEN full_descr_flex_csr;
      FETCH full_descr_flex_csr INTO l_flexfield_type;
      CLOSE full_descr_flex_csr;
    END IF;

  -- In incremental refresh check the stored structure information
  -- from the job hierarchy configuration table
  ELSE

    -- Set the return variable from the corresponding cursor
    IF (p_job_type = 'JOB_FUNCTION') THEN
      OPEN incr_jfn_flex_type_csr;
      FETCH incr_jfn_flex_type_csr INTO l_flexfield_type;
      CLOSE incr_jfn_flex_type_csr;
    ELSIF (p_job_type = 'JOB_FAMILY') THEN
      OPEN incr_jfm_flex_type_csr;
      FETCH incr_jfm_flex_type_csr INTO l_flexfield_type;
      CLOSE incr_jfm_flex_type_csr;
    END IF;

  END IF;

  -- If neither flexfield type is found return NA_EDW
  RETURN NVL(l_flexfield_type, 'NA_EDW');

END get_flexfield_type;

-- --------------------------------------------------------------------
-- Returns whether a job family/function valueset is stored against
-- the KEY or DESCRIPTIVE flexfield or neither (NA_EDW)
-- --------------------------------------------------------------------
FUNCTION get_flexfield_type(p_job_type      IN VARCHAR2)
    RETURN VARCHAR2 IS

BEGIN

  -- Populate the cache if it is empty
  IF (g_job_fmly_flex_type IS NULL) THEN

    -- Cache both job family and function flexfield types
    g_job_fnctn_flex_type := get_flexfield_type
                              (p_job_type => 'JOB_FUNCTION',
                               p_value_set_id => g_job_fnctn_vset_id);
    g_job_fmly_flex_type  := get_flexfield_type
                              (p_job_type => 'JOB_FAMILY',
                               p_value_set_id => g_job_fmly_vset_id);
  END IF;

  -- Return respective value from cache
  IF (p_job_type = 'JOB_FUNCTION') THEN
    RETURN g_job_fnctn_flex_type;
  ELSIF (p_job_type = 'JOB_FAMILY') THEN
    RETURN g_job_fmly_flex_type;
  END IF;

  RETURN 'NA_EDW';

END get_flexfield_type;

/******************************************************************************/
/* CONFIGURATION TABLE SECTION                                                */
/******************************************************************************/

-- ----------------------------------------------------------------------------
-- Refreshes the configuration table, which maps flexfield structure columns
-- to job hierarchy levels
-- ----------------------------------------------------------------------------
PROCEDURE refresh_config_table IS

  CURSOR keyflex_csr(v_valueset_id  NUMBER) IS
  SELECT
   to_char(fsg.id_flex_num)          job_flex_code
  ,MIN(fsg.application_column_name)  flex_column
  FROM
   fnd_id_flex_segments_vl  fsg
  WHERE fsg.application_id = 800
  AND fsg.id_flex_code = 'JOB'
  AND fsg.flex_value_set_id = v_valueset_id
  GROUP BY fsg.id_flex_num;

  CURSOR descr_flex_csr(v_valueset_id  NUMBER) IS
  SELECT
   DECODE(ctxt.global_flag,
            'Y',  'NA_EDW',
          dfcu.descriptive_flex_context_code)  job_flex_code
  ,dfcu.application_column_name                flex_column
  ,ctxt.global_flag                            global_flag
  FROM
   fnd_descr_flex_col_usage_vl  dfcu
  ,fnd_descr_flex_contexts_vl   ctxt
  WHERE dfcu.descriptive_flexfield_name = 'PER_JOBS'
  AND dfcu.application_id = 800
  AND dfcu.flex_value_set_id = v_valueset_id
  AND ctxt.application_id = dfcu.application_id
  AND ctxt.descriptive_flexfield_name = dfcu.descriptive_flexfield_name
  AND ctxt.descriptive_flex_context_code = dfcu.descriptive_flex_context_code;

  l_job_fmly_flex_type    VARCHAR2(30);
  l_job_fnctn_flex_type   VARCHAR2(30);
  l_job_fmly_global_col   VARCHAR2(30);
  l_job_fnctn_global_col  VARCHAR2(30);
  l_index                 VARCHAR2(300);
  l_index_type            VARCHAR2(30);
  l_index_code            VARCHAR2(240);

BEGIN

  -- Truncate table
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_hri_schema || '.hri_cnfg_jobh_flex_cols';

  -- Get flexfield types for full refresh of config table
  l_job_fnctn_flex_type := get_flexfield_type('JOB_FUNCTION');
  l_job_fmly_flex_type  := get_flexfield_type('JOB_FAMILY');

-- -------------------------------------------
-- Cache Job Function Flexfield Configuration
-- -------------------------------------------

  IF (l_job_fnctn_flex_type = 'KEY') THEN

    -- Populate job function flex columns in cache from key flex
    FOR keyflex_rec IN keyflex_csr(g_job_fnctn_vset_id) LOOP
      job_flex_cache('KEY|' || keyflex_rec.job_flex_code).job_fnctn_column
              := keyflex_rec.flex_column;
    END LOOP;

  ELSIF (l_job_fnctn_flex_type = 'DESCRIPTIVE') THEN

    -- Populate job function flex columns in cache from desc flex
    FOR descr_flex_rec IN descr_flex_csr(g_job_fnctn_vset_id) LOOP
      job_flex_cache('DESCRIPTIVE|' || descr_flex_rec.job_flex_code).job_fnctn_column
              := descr_flex_rec.flex_column;
      -- Note global column if available
      IF (descr_flex_rec.global_flag = 'Y') THEN
        l_job_fnctn_global_col := descr_flex_rec.flex_column;
      END IF;
    END LOOP;

  END IF;

-- -----------------------------------------
-- Cache Job Family Flexfield Configuration
-- -----------------------------------------

  IF (l_job_fmly_flex_type = 'KEY') THEN

    -- Populate job family flex columns in cache from key flex
    FOR keyflex_rec IN keyflex_csr(g_job_fmly_vset_id) LOOP
      job_flex_cache('KEY|' || keyflex_rec.job_flex_code).job_fmly_column
              := keyflex_rec.flex_column;
    END LOOP;

  ELSIF (l_job_fmly_flex_type = 'DESCRIPTIVE') THEN

    -- Populate job function flex columns in cache from desc flex
    FOR descr_flex_rec IN descr_flex_csr(g_job_fmly_vset_id) LOOP
      job_flex_cache('DESCRIPTIVE|' || descr_flex_rec.job_flex_code).job_fmly_column
              := descr_flex_rec.flex_column;
      -- Note global column if available
      IF (descr_flex_rec.global_flag = 'Y') THEN
        l_job_fmly_global_col := descr_flex_rec.flex_column;
      END IF;
    END LOOP;

  END IF;

-- -----------------------------------------
-- Insert from cache
-- -----------------------------------------

  l_index := job_flex_cache.FIRST;

  WHILE l_index IS NOT NULL LOOP

    l_index_type := SUBSTR(l_index, 1, INSTR(l_index, '|') - 1);
    l_index_code := SUBSTR(l_index, INSTR(l_index, '|') + 1);

    -- If a DF global is available use it for all DF contexts
    IF (l_index_type = 'DESCRIPTIVE') THEN

      -- Check the job function global
      IF (l_job_fnctn_global_col IS NOT NULL) THEN
        job_flex_cache(l_index).job_fnctn_column := l_job_fnctn_global_col;
      END IF;

      -- Check the job family global
      IF (l_job_fmly_global_col IS NOT NULL) THEN
        job_flex_cache(l_index).job_fmly_column := l_job_fmly_global_col;
      END IF;

    END IF;

    -- Insert the value into the configuration table
    INSERT INTO hri_cnfg_jobh_flex_cols
      (flexfield_type
      ,job_flex_code
      ,job_fnctn_column
      ,job_fmly_column)
      VALUES
       (l_index_type
       ,l_index_code
       ,job_flex_cache(l_index).job_fnctn_column
       ,job_flex_cache(l_index).job_fmly_column);

    l_index := job_flex_cache.NEXT(l_index);

  END LOOP;

  -- commit
  COMMIT;

END refresh_config_table;

/******************************************************************************/
/* GENERATE LOV VIEWS SECTION                                                 */
/******************************************************************************/

-- ----------------------------------------------------------------------------
-- Attaches comments to the LOV views created
-- ----------------------------------------------------------------------------
PROCEDURE attach_comments IS

  -- View and column descriptions for job family
  l_job_fmly_view      VARCHAR2(500);
  l_job_fmly_id        VARCHAR2(500);
  l_job_fmly_value     VARCHAR2(500);

  -- View and column descriptions for job family
  l_job_fnctn_view     VARCHAR2(500);
  l_job_fnctn_id       VARCHAR2(500);
  l_job_fnctn_value    VARCHAR2(500);

  -- Generic column descriptions
  l_start_date         VARCHAR2(500);
  l_end_date           VARCHAR2(500);

BEGIN

  -- View and column descriptions for job family
  l_job_fmly_view :=
'List of values for the job family level, dynamically generated from the ' ||
'value set defined in the profile option "BIS: HR Job Hierarchy Job Family Level"';
  l_job_fmly_id        := 'Unique identifier for job family';
  l_job_fmly_value     := 'Job family name';

  -- View and column descriptions for job function
  l_job_fnctn_view :=
'List of values for the job function level, dynamically generated from the ' ||
'value set defined in the profile option "BIS: HR Job Hierarchy Job Function Level"';
  l_job_fnctn_id       := 'Unique identifier for job function';
  l_job_fnctn_value    := 'Job function name';

  -- Generic column descriptions
  l_start_date         := 'Effective start date of value';
  l_end_date           := 'Effective end date of value';

  -- ----------------------------------------------------------------------------
  -- Comments on Job Family view
  -- ----------------------------------------------------------------------------
  EXECUTE IMMEDIATE 'COMMENT ON TABLE hri_cl_job_family_v'
                 || ' IS ''' || l_job_fmly_view || '''';
  EXECUTE IMMEDIATE 'COMMENT ON COLUMN hri_cl_job_family_v.id'
                 || ' IS ''' || l_job_fmly_id || '''';
  EXECUTE IMMEDIATE 'COMMENT ON COLUMN hri_cl_job_family_v.value'
                 || ' IS ''' || l_job_fmly_value || '''';
  EXECUTE IMMEDIATE 'COMMENT ON COLUMN hri_cl_job_family_v.start_date'
                 || ' IS ''' || l_start_date || '''';
  EXECUTE IMMEDIATE 'COMMENT ON COLUMN hri_cl_job_family_v.end_date'
                 || ' IS ''' || l_end_date || '''';

  -- ----------------------------------------------------------------------------
  -- Comments on Job Function view
  -- ----------------------------------------------------------------------------
  EXECUTE IMMEDIATE 'COMMENT ON TABLE hri_cl_job_function_v'
                 || ' IS ''' || l_job_fnctn_view || '''';
  EXECUTE IMMEDIATE 'COMMENT ON COLUMN hri_cl_job_function_v.id'
                 || ' IS ''' || l_job_fnctn_id || '''';
  EXECUTE IMMEDIATE 'COMMENT ON COLUMN hri_cl_job_function_v.value'
                 || ' IS ''' || l_job_fnctn_value || '''';
  EXECUTE IMMEDIATE 'COMMENT ON COLUMN hri_cl_job_function_v.start_date'
                 || ' IS ''' || l_start_date || '''';
  EXECUTE IMMEDIATE 'COMMENT ON COLUMN hri_cl_job_function_v.end_date'
                 || ' IS ''' || l_end_date || '''';

EXCEPTION WHEN OTHERS THEN
    null;
END attach_comments;

-- ----------------------------------------------------------------------------
-- Generates the LOV views for job fmly and job fnctn
-- The code to generate each view is done separately to make it easier to
-- make modifications to one in future
-- ----------------------------------------------------------------------------
PROCEDURE generate_lov_views IS

  l_vset_lov_sql       VARCHAR2(4000);
  l_view_sql           VARCHAR2(4000);
  l_dummy1             VARCHAR2(2000);
  l_dummy2             VARCHAR2(2000);
  l_fnd_schema         VARCHAR2(30);
  l_fmly_sql           VARCHAR2(4000);
  l_fnctn_sql          VARCHAR2(4000);

BEGIN

  -- Get FND schema name
  IF (fnd_installation.get_app_info('FND',l_dummy1, l_dummy2, l_fnd_schema)) THEN

    -- ----------------------------------------------------------------------------
    -- Generate Job Family view
    -- ----------------------------------------------------------------------------

    -- Bug 3387576 - Added distinct flag = 'Y' for job level 2
    hri_bpl_flex.get_value_set_lov_sql
      (p_flex_value_set_id => g_job_fmly_vset_id
      ,p_sql_stmt => l_vset_lov_sql
      ,p_distinct_flag => 'Y');

    -- If the valueset is defined add it as the first UNION
    IF (l_vset_lov_sql IS NOT NULL) THEN
      --
      l_fmly_sql := l_vset_lov_sql || g_rtn;
      l_vset_lov_sql := l_vset_lov_sql || g_rtn || 'UNION ALL' || g_rtn;
      --
    ELSE
      --
      l_fmly_sql := 'SELECT ' || g_rtn
                 ||  'id_char id' ||g_rtn
                 || ',hri_oltp_view_message.get_unassigned_msg value' || g_rtn
                 || ',hr_general.start_of_time start_date' || g_rtn
                 || ',hr_general.end_of_time end_date' || g_rtn
                 || ',''2'' order_by' || g_rtn
                 || 'FROM hri_unassigned';
    END IF;

    l_view_sql :=
'CREATE OR REPLACE FORCE VIEW hri_cl_job_family_v
 (id
 ,value
 ,start_date
 ,end_date
 ,order_by)
AS
' || l_vset_lov_sql ||
'SELECT
 id_char
,hri_oltp_view_message.get_unassigned_msg value
,hr_general.start_of_time
,hr_general.end_of_time
,''2''
FROM hri_unassigned';

    -- Log the statement in debug mode
    dbg('About to create job family view with:');
    dbg(' ');
    dbg(l_view_sql);
    dbg(' ');

    -- Execute view creation statement
    ad_ddl.do_ddl(applsys_schema         => l_fnd_schema,
                  application_short_name => 'APPS',
                  statement_type         => ad_ddl.create_view,
                  statement              => l_view_sql,
                  object_name            => 'HRI_CL_JOB_FAMILY_V');
    -- -------------------------------------------------------------------------
    -- Generate OBI Job Family View
    -- -------------------------------------------------------------------------

    l_view_sql :=
'CREATE OR REPLACE FORCE VIEW hri_obi_cl_job_family_v
 (fmly_family_pk
 ,fmly_family_name
 ,fmly_start_date
 ,fmly_end_date
 ,fmly_order_by)
AS
' || l_vset_lov_sql ||
'SELECT
 id_char
,hri_oltp_view_message.get_unassigned_msg value
,hr_general.start_of_time
,hr_general.end_of_time
,''2''
FROM hri_unassigned';

    -- Log the statement in debug mode
    dbg('About to create obi job family view with:');
    dbg(' ');
    dbg(l_view_sql);
    dbg(' ');

    -- Execute view creation statement
    ad_ddl.do_ddl(applsys_schema         => l_fnd_schema,
                  application_short_name => 'APPS',
                  statement_type         => ad_ddl.create_view,
                  statement              => l_view_sql,
                  object_name            => 'HRI_OBI_CL_JOB_FAMILY_V');


   -- Reset view sql
   l_vset_lov_sql := null;

   -- ----------------------------------------------------------------------------
   -- Generate Job Function view
   -- ----------------------------------------------------------------------------

   -- Bug 3387576 - Added distinct flag = 'N' for job level 1
   hri_bpl_flex.get_value_set_lov_sql
      (p_flex_value_set_id => g_job_fnctn_vset_id
      ,p_sql_stmt => l_vset_lov_sql
      ,p_distinct_flag => 'N');

    -- If the valueset is defined add it as the first UNION
   IF (l_vset_lov_sql IS NOT NULL) THEN
     --
     l_fnctn_sql := l_vset_lov_sql || g_rtn;
     l_vset_lov_sql := l_vset_lov_sql || g_rtn || 'UNION ALL' || g_rtn;
     --
   ELSE
     --
     l_fnctn_sql := 'SELECT ' || g_rtn
                ||  'id_char id' ||g_rtn
                ||  ',hri_oltp_view_message.get_unassigned_msg value' || g_rtn
                ||  ',hr_general.start_of_time start_date' || g_rtn
                ||  ',hr_general.end_of_time end_date' || g_rtn
                ||  ',''2'' order_by' || g_rtn
                ||  'FROM hri_unassigned';
   END IF;

   l_view_sql :=
'CREATE OR REPLACE FORCE VIEW hri_cl_job_function_v
 (id
 ,value
 ,start_date
 ,end_date
 ,order_by)
AS
' || l_vset_lov_sql ||
'SELECT
 id_char
,hri_oltp_view_message.get_unassigned_msg value
,hr_general.start_of_time
,hr_general.end_of_time
,''2''
FROM hri_unassigned';

    -- Log the statement in debug mode
    dbg('About to create job function view with:');
    dbg(' ');
    dbg(l_view_sql);
    dbg(' ');

    -- Execute view creation statement
    ad_ddl.do_ddl(applsys_schema         => l_fnd_schema,
                  application_short_name => 'APPS',
                  statement_type         => ad_ddl.create_view,
                  statement              => l_view_sql,
                  object_name            => 'HRI_CL_JOB_FUNCTION_V');

     -- ----------------------------------------------------------------------------
     -- Generate OBI Job Function View
     -- ----------------------------------------------------------------------------
   l_view_sql :=
'CREATE OR REPLACE FORCE VIEW hri_obi_cl_job_function_v
 (fnct_function_pk
 ,fnct_function_name
 ,fnct_start_date
 ,fnct_end_date
 ,fnct_order_by)
AS
' || l_vset_lov_sql ||
'SELECT
 id_char
,hri_oltp_view_message.get_unassigned_msg value
,hr_general.start_of_time
,hr_general.end_of_time
,''2''
FROM hri_unassigned';

    -- Log the statement in debug mode
    dbg('About to create obi job function view with:');
    dbg(' ');
    dbg(l_view_sql);
    dbg(' ');

    -- Execute view creation statement
    ad_ddl.do_ddl(applsys_schema         => l_fnd_schema,
                  application_short_name => 'APPS',
                  statement_type         => ad_ddl.create_view,
                  statement              => l_view_sql,
                  object_name            => 'HRI_OBI_CL_JOB_FUNCTION_V');

    -- Reset view sql
    l_vset_lov_sql := null;

    -- ------------------------------------------------------------------------
    -- Generate OBI Job Family Function View
    -- ------------------------------------------------------------------------

  l_vset_lov_sql :=
       'SELECT DISTINCT' || g_rtn
    ||   'job.job_fmly_code || '' ('' || job.job_fnctn_code || '')'' fmfn_fmlyfnct_pk' || g_rtn
    ||   ',NVL(jfm.value,hri_oltp_view_message.get_unassigned_msg)
    || '' ('' || NVL(jfn.value,hri_oltp_view_message.get_unassigned_msg) || '')'' fmfn_fmlyfnct_name' || g_rtn
    ||   ',NVL(jfm.value,hri_oltp_view_message.get_unassigned_msg)
    || '' ('' || NVL(jfn.value,hri_oltp_view_message.get_unassigned_msg) || '')'' fmfn_fmlyfnct_name_unq' || g_rtn
    ||   ',job.job_fmly_code  fmfn_family_fk' || g_rtn
    ||   ',NVL(jfm.value,hri_oltp_view_message.get_unassigned_msg) fmfn_family_name' || g_rtn
    ||   ',job.job_fnctn_code  fmfn_function_fk' || g_rtn
    ||   ',NVL(jfn.value,hri_oltp_view_message.get_unassigned_msg) fmfn_function_name' || g_rtn
    ||   ',(CASE' || g_rtn
    ||   '    WHEN jfm.value IS NULL THEN' || g_rtn
    ||   '      CASE WHEN jfn.value IS NULL THEN NULL' || g_rtn
    ||   '           WHEN jfn.value = hri_oltp_view_message.get_unassigned_msg THEN NULL' || g_rtn
    ||   '           ELSE jfn.value' || g_rtn
    ||   '      END'  || g_rtn
    ||   '    WHEN jfn.value IS NULL THEN' || g_rtn
    ||   '      CASE WHEN jfm.value = hri_oltp_view_message.get_unassigned_msg THEN NULL' || g_rtn
    ||   '           ELSE jfm.value' || g_rtn
    ||   '      END'  || g_rtn
    ||   '    WHEN  jfm.value  = hri_oltp_view_message.get_unassigned_msg THEN' || g_rtn
    ||   '      CASE WHEN jfn.value = hri_oltp_view_message.get_unassigned_msg THEN NULL' || g_rtn
    ||   '           ELSE jfn.value' || g_rtn
    ||   '      END' || g_rtn
    ||   '    WHEN jfn.value = hri_oltp_view_message.get_unassigned_msg THEN jfm.value' || g_rtn
    ||   '    ELSE jfm.value || '' ('' || jfn.value || '')''' || g_rtn
    ||   '  END) fmfn_order_by'  || g_rtn
    ||   'FROM hri_cs_jobh_ct job,' || g_rtn
    ||   '(' || l_fmly_sql || ') jfm,' || g_rtn
    ||    '(' || l_fnctn_sql || ') jfn' || g_rtn
    || 'WHERE job.job_fmly_code = jfm.id(+)' || g_rtn
    || 'AND job.job_fnctn_code = jfn.id(+)';
    --
    --
    l_view_sql :=
'CREATE OR REPLACE FORCE VIEW hri_obi_cl_job_fmlyfnct_v
 (fmfn_fmlyfnct_pk
 ,fmfn_fmlyfnct_name
 ,fmfn_fmlyfnct_name_unq
 ,fmfn_family_fk
 ,fmfn_family_name
 ,fmfn_function_fk
 ,fmfn_function_name
 ,fmfn_order_by)
 AS
' || l_vset_lov_sql;


    -- Log the statement in debug mode
    dbg('About to create obi job family function view with:');
    dbg(' ');
    dbg(l_view_sql);
    dbg(' ');

    -- Execute view creation statement
    ad_ddl.do_ddl(applsys_schema         => l_fnd_schema,
                  application_short_name => 'APPS',
                  statement_type         => ad_ddl.create_view,
                  statement              => l_view_sql,
                  object_name            => 'HRI_OBI_CL_JOB_FMLYFNCT_V');


    -- Add comments to objects for eTRM
    attach_comments;
    --
  END IF;
  --
END generate_lov_views;

/******************************************************************************/
/* LOAD JOB HIERARCHY TABLE SECTION                                           */
/******************************************************************************/

-- ---------------------------------------------------------------------------
-- Looks up the columns to use for a given flexfield structure and job type
-- ---------------------------------------------------------------------------
PROCEDURE get_job_flex_columns(p_flex_type         IN VARCHAR2,
                               p_flex_code         IN VARCHAR2,
                               p_job_fmly_column   OUT NOCOPY VARCHAR2,
                               p_job_fnctn_column  OUT NOCOPY VARCHAR2) IS

  CURSOR job_segment_csr IS
  SELECT
   job_fmly_column
  ,job_fnctn_column
  FROM
   hri_cnfg_jobh_flex_cols
  WHERE flexfield_type = p_flex_type
  AND job_flex_code = p_flex_code;

BEGIN

  -- PL/SQL block to trap cache misses
  BEGIN

    -- Return appropriate columns from cache
    p_job_fmly_column  := job_flex_cache
                           (p_flex_type || '|' || p_flex_code).job_fmly_column;
    p_job_fnctn_column := job_flex_cache
                           (p_flex_type || '|' || p_flex_code).job_fnctn_column;

  -- Cache miss
  EXCEPTION WHEN OTHERS THEN

    -- Populate cache
    OPEN job_segment_csr;
    FETCH job_segment_csr INTO p_job_fmly_column, p_job_fnctn_column;
    CLOSE job_segment_csr;

    -- If no record found in DESCRIPTIVE mode then check the global
    IF (p_flex_type = 'DESCRIPTIVE' AND
        p_flex_code <> 'NA_EDW' AND
        p_job_fmly_column IS NULL AND
        p_job_fnctn_column IS NULL) THEN

      -- Recursively call function to get the global values from cache
      get_job_flex_columns
       (p_flex_type        => 'DESCRIPTIVE',
        p_flex_code        => 'NA_EDW',
        p_job_fmly_column  => p_job_fmly_column,
        p_job_fnctn_column => p_job_fnctn_column);

    END IF;

    -- Populate cache with results
    job_flex_cache(p_flex_type || '|' || p_flex_code).job_fmly_column
          := p_job_fmly_column;
    job_flex_cache(p_flex_type || '|' || p_flex_code).job_fnctn_column
          := p_job_fnctn_column;

  END;

END get_job_flex_columns;

-- --------------------------------------------------------------------------
-- Returns the flexfield column to use for the given flexfield type and code
-- --------------------------------------------------------------------------
FUNCTION get_job_flex_column(p_flex_type    IN VARCHAR2,
                             p_flex_code    IN VARCHAR2,
                             p_job_type     IN VARCHAR2)
    RETURN VARCHAR2 IS

  l_job_fmly_column    VARCHAR2(30);
  l_job_fnctn_column   VARCHAR2(30);

BEGIN

  -- Call cache function to get flex columns
  get_job_flex_columns
   (p_flex_type        => p_flex_type,
    p_flex_code        => p_flex_code,
    p_job_fmly_column  => l_job_fmly_column,
    p_job_fnctn_column => l_job_fnctn_column);

  -- Return appropriate column
  IF (p_job_type = 'JOB_FAMILY') THEN
    RETURN l_job_fmly_column;
  ELSIF (p_job_type = 'JOB_FUNCTION') THEN
    RETURN l_job_fnctn_column;
  END IF;

  -- Return column to select for invalid job type
  RETURN '''NA_EDW''';

END get_job_flex_column;

-- ----------------------------------------------------------------------------
-- 3943809 This function determines the segment which stores the job family
-- or job function information for a ID_FLEX_NUM for the job kff.
-- ----------------------------------------------------------------------------
FUNCTION decode_keyflex_value
           (p_id_flex_num   NUMBER,
            p_job_type      VARCHAR2,
            p_segment1      VARCHAR2,
            p_segment2      VARCHAR2,
            p_segment3      VARCHAR2,
            p_segment4      VARCHAR2,
            p_segment5      VARCHAR2,
            p_segment6      VARCHAR2,
            p_segment7      VARCHAR2,
            p_segment8      VARCHAR2,
            p_segment9      VARCHAR2,
            p_segment10     VARCHAR2,
            p_segment11     VARCHAR2,
            p_segment12     VARCHAR2,
            p_segment13     VARCHAR2,
            p_segment14     VARCHAR2,
            p_segment15     VARCHAR2,
            p_segment16     VARCHAR2,
            p_segment17     VARCHAR2,
            p_segment18     VARCHAR2,
            p_segment19     VARCHAR2,
            p_segment20     VARCHAR2,
            p_segment21     VARCHAR2,
            p_segment22     VARCHAR2,
            p_segment23     VARCHAR2,
            p_segment24     VARCHAR2,
            p_segment25     VARCHAR2,
            p_segment26     VARCHAR2,
            p_segment27     VARCHAR2,
            p_segment28     VARCHAR2,
            p_segment29     VARCHAR2,
            p_segment30     VARCHAR2)
    RETURN VARCHAR2 IS

  l_output       VARCHAR2(240);
  l_job_segment  VARCHAR2(30);

BEGIN

  -- Get the segment column for the job family or function
  l_job_segment := get_job_flex_column
                    (p_flex_type => 'KEY',
                     p_flex_code => to_char(p_id_flex_num),
                     p_job_type    => p_job_type);

  -- Populate the ouptut variable with the value of the segment
  IF    l_job_segment = 'SEGMENT1'  THEN l_output :=  p_segment1;
  ELSIF l_job_segment = 'SEGMENT2'  THEN l_output :=  p_segment2;
  ELSIF l_job_segment = 'SEGMENT3'  THEN l_output :=  p_segment3;
  ELSIF l_job_segment = 'SEGMENT4'  THEN l_output :=  p_segment4;
  ELSIF l_job_segment = 'SEGMENT5'  THEN l_output :=  p_segment5;
  ELSIF l_job_segment = 'SEGMENT6'  THEN l_output :=  p_segment6;
  ELSIF l_job_segment = 'SEGMENT7'  THEN l_output :=  p_segment7;
  ELSIF l_job_segment = 'SEGMENT8'  THEN l_output :=  p_segment8;
  ELSIF l_job_segment = 'SEGMENT9'  THEN l_output :=  p_segment9;
  ELSIF l_job_segment = 'SEGMENT10' THEN l_output :=  p_segment10;
  ELSIF l_job_segment = 'SEGMENT11' THEN l_output :=  p_segment11;
  ELSIF l_job_segment = 'SEGMENT12' THEN l_output :=  p_segment12;
  ELSIF l_job_segment = 'SEGMENT13' THEN l_output :=  p_segment13;
  ELSIF l_job_segment = 'SEGMENT14' THEN l_output :=  p_segment14;
  ELSIF l_job_segment = 'SEGMENT15' THEN l_output :=  p_segment15;
  ELSIF l_job_segment = 'SEGMENT16' THEN l_output :=  p_segment16;
  ELSIF l_job_segment = 'SEGMENT17' THEN l_output :=  p_segment17;
  ELSIF l_job_segment = 'SEGMENT18' THEN l_output :=  p_segment18;
  ELSIF l_job_segment = 'SEGMENT19' THEN l_output :=  p_segment19;
  ELSIF l_job_segment = 'SEGMENT20' THEN l_output :=  p_segment20;
  ELSIF l_job_segment = 'SEGMENT21' THEN l_output :=  p_segment21;
  ELSIF l_job_segment = 'SEGMENT22' THEN l_output :=  p_segment22;
  ELSIF l_job_segment = 'SEGMENT23' THEN l_output :=  p_segment23;
  ELSIF l_job_segment = 'SEGMENT24' THEN l_output :=  p_segment24;
  ELSIF l_job_segment = 'SEGMENT25' THEN l_output :=  p_segment25;
  ELSIF l_job_segment = 'SEGMENT26' THEN l_output :=  p_segment26;
  ELSIF l_job_segment = 'SEGMENT27' THEN l_output :=  p_segment27;
  ELSIF l_job_segment = 'SEGMENT28' THEN l_output :=  p_segment28;
  ELSIF l_job_segment = 'SEGMENT29' THEN l_output :=  p_segment29;
  ELSIF l_job_segment = 'SEGMENT30' THEN l_output :=  p_segment30;
  ELSE  l_output := 'NA_EDW';
  END IF;

  RETURN NVL(l_output,'NA_EDW');

END decode_keyflex_value;

-- ----------------------------------------------------------------------------
-- This function determines the attribute which stores the job family
-- or job function information for a descriptive flexfield
-- ----------------------------------------------------------------------------
FUNCTION decode_descr_flex_value
           (p_attribute_category  VARCHAR2,
            p_job_type            VARCHAR2,
            p_attribute1          VARCHAR2,
            p_attribute2          VARCHAR2,
            p_attribute3          VARCHAR2,
            p_attribute4          VARCHAR2,
            p_attribute5          VARCHAR2,
            p_attribute6          VARCHAR2,
            p_attribute7          VARCHAR2,
            p_attribute8          VARCHAR2,
            p_attribute9          VARCHAR2,
            p_attribute10         VARCHAR2,
            p_attribute11         VARCHAR2,
            p_attribute12         VARCHAR2,
            p_attribute13         VARCHAR2,
            p_attribute14         VARCHAR2,
            p_attribute15         VARCHAR2,
            p_attribute16         VARCHAR2,
            p_attribute17         VARCHAR2,
            p_attribute18         VARCHAR2,
            p_attribute19         VARCHAR2,
            p_attribute20         VARCHAR2)
    RETURN VARCHAR2 IS

  l_output              VARCHAR2(240);
  l_job_attribute       VARCHAR2(30);
  l_attribute_category  VARCHAR2(30);

BEGIN

  -- If no attribute category is passed use the global
  l_attribute_category := NVL(p_attribute_category, 'NA_EDW');

  -- Get the attribute column for the job type
  l_job_attribute := get_job_flex_column
                      (p_flex_type => 'DESCRIPTIVE',
                       p_flex_code => l_attribute_category,
                       p_job_type  => p_job_type);

  -- Return the value of the attribute column
  IF    l_job_attribute = 'ATTRIBUTE1'  THEN l_output :=  p_attribute1;
  ELSIF l_job_attribute = 'ATTRIBUTE2'  THEN l_output :=  p_attribute2;
  ELSIF l_job_attribute = 'ATTRIBUTE3'  THEN l_output :=  p_attribute3;
  ELSIF l_job_attribute = 'ATTRIBUTE4'  THEN l_output :=  p_attribute4;
  ELSIF l_job_attribute = 'ATTRIBUTE5'  THEN l_output :=  p_attribute5;
  ELSIF l_job_attribute = 'ATTRIBUTE6'  THEN l_output :=  p_attribute6;
  ELSIF l_job_attribute = 'ATTRIBUTE7'  THEN l_output :=  p_attribute7;
  ELSIF l_job_attribute = 'ATTRIBUTE8'  THEN l_output :=  p_attribute8;
  ELSIF l_job_attribute = 'ATTRIBUTE9'  THEN l_output :=  p_attribute9;
  ELSIF l_job_attribute = 'ATTRIBUTE10' THEN l_output :=  p_attribute10;
  ELSIF l_job_attribute = 'ATTRIBUTE11' THEN l_output :=  p_attribute11;
  ELSIF l_job_attribute = 'ATTRIBUTE12' THEN l_output :=  p_attribute12;
  ELSIF l_job_attribute = 'ATTRIBUTE13' THEN l_output :=  p_attribute13;
  ELSIF l_job_attribute = 'ATTRIBUTE14' THEN l_output :=  p_attribute14;
  ELSIF l_job_attribute = 'ATTRIBUTE15' THEN l_output :=  p_attribute15;
  ELSIF l_job_attribute = 'ATTRIBUTE16' THEN l_output :=  p_attribute16;
  ELSIF l_job_attribute = 'ATTRIBUTE17' THEN l_output :=  p_attribute17;
  ELSIF l_job_attribute = 'ATTRIBUTE18' THEN l_output :=  p_attribute18;
  ELSIF l_job_attribute = 'ATTRIBUTE19' THEN l_output :=  p_attribute19;
  ELSIF l_job_attribute = 'ATTRIBUTE20' THEN l_output :=  p_attribute20;
  ELSE  l_output := 'NA_EDW';
  END IF;

  RETURN NVL(l_output, 'NA_EDW');

END decode_descr_flex_value;

-- Returns the column string for the function to get the values
-- from the appropriate flexfield columns
FUNCTION get_column_string(p_job_type   IN VARCHAR2,
                           p_flex_type  IN VARCHAR2)
       RETURN VARCHAR2 IS

  l_cnfg_column    VARCHAR2(30);
  l_column_string  VARCHAR2(1000);

BEGIN

  -- Formulate the return column string
  IF (p_flex_type = 'KEY') THEN

    l_column_string :=
'hri_opl_jobh.decode_keyflex_value
  (pjd.id_flex_num, ''' || p_job_type || ''',
   pjd.segment1,  pjd.segment2,  pjd.segment3,  pjd.segment4,  pjd.segment5,
   pjd.segment6,  pjd.segment7,  pjd.segment8,  pjd.segment9,  pjd.segment10,
   pjd.segment11, pjd.segment12, pjd.segment13, pjd.segment14, pjd.segment15,
   pjd.segment16, pjd.segment17, pjd.segment18, pjd.segment19, pjd.segment20,
   pjd.segment21, pjd.segment22, pjd.segment23, pjd.segment24, pjd.segment25,
   pjd.segment26, pjd.segment27, pjd.segment28, pjd.segment29, pjd.segment30)';

  ELSIF (p_flex_type = 'DESCRIPTIVE') THEN

    l_column_string :=
'hri_opl_jobh.decode_descr_flex_value
  (job.attribute_category, ''' || p_job_type || ''',
   job.attribute1,  job.attribute2,  job.attribute3,  job.attribute4,  job.attribute5,
   job.attribute6,  job.attribute7,  job.attribute8,  job.attribute9,  job.attribute10,
   job.attribute11, job.attribute12, job.attribute13, job.attribute14, job.attribute15,
   job.attribute16, job.attribute17, job.attribute18, job.attribute19, job.attribute20)';

  ELSE

    l_column_string := '''NA_EDW''';

  END IF;

  -- Return
  RETURN l_column_string;

END get_column_string;

-- ----------------------------------------------------------------------------
-- Truncates and repopulates the job hierarchy table (full refresh mode)
-- Assumes the refresh_config_table procedure has already been called
-- ----------------------------------------------------------------------------
--
PROCEDURE collect_hierarchy_table IS

  -- Values to populate WHO columns
  l_current_time       DATE    := SYSDATE;
  l_user_id            NUMBER  := fnd_global.user_id;
  l_job_fmly_column    VARCHAR2(1000);
  l_job_fnctn_column   VARCHAR2(1000);
  l_sql_stmt           VARCHAR2(32000);

BEGIN

  -- 3601362 Disable the WHO Trigger
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_JOBH_CT_WHO DISABLE');

  -- Truncate table
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_hri_schema || '.hri_cs_jobh_ct';

  -- Get the job family and function column strings
  l_job_fnctn_column := get_column_string
                         (p_job_type  => 'JOB_FUNCTION',
                          p_flex_type => get_flexfield_type('JOB_FUNCTION'));
  l_job_fmly_column :=  get_column_string
                         (p_job_type  => 'JOB_FAMILY',
                          p_flex_type => get_flexfield_type('JOB_FAMILY'));

  -- Formulate the insert SQL statement
  l_sql_stmt :=
'INSERT INTO hri_cs_jobh_ct
 (job_id
 ,job_fmly_code
 ,job_fnctn_code
 ,last_update_date
 ,last_update_login
 ,last_updated_by
 ,created_by
 ,creation_date )
SELECT
 job.job_id       job_id
,' || l_job_fmly_column  || '
,' || l_job_fnctn_column || '
,:l_current_time
,:l_user_id
,:l_user_id
,:l_user_id
,:l_current_time
FROM
 per_jobs                 job
,per_job_definitions      pjd
WHERE job.job_definition_id = pjd.job_definition_id
UNION ALL
SELECT
 -1          job_id
,''NA_EDW''  job_fmly_code
,''NA_EDW''  job_fnctn_code
,:l_current_time
,:l_user_id
,:l_user_id
,:l_user_id
,:l_current_time
FROM dual';

  -- Run insert statement
  EXECUTE IMMEDIATE l_sql_stmt USING
   l_current_time,
   l_user_id,
   l_user_id,
   l_user_id,
   l_current_time,
   l_current_time,
   l_user_id,
   l_user_id,
   l_user_id,
   l_current_time;

  -- Commit
  COMMIT;

  -- Gather Stats
  fnd_stats.gather_table_stats(g_hri_schema, 'HRI_CS_JOBH_CT');

  -- 3601362 Enable the WHO trigger
  run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_JOBH_CT_WHO ENABLE');

END collect_hierarchy_table;
--
-- ----------------------------------------------------------------------------
-- Incrementally refreshes the job hierarchy table (incremental refresh mode)
-- ----------------------------------------------------------------------------
--
PROCEDURE update_hierarchy_table IS

  -- Values to populate WHO columns
  l_current_time       DATE    := SYSDATE;
  l_user_id            NUMBER  := fnd_global.user_id;

  -- PL/SQL table of updated job records
  TYPE l_number_tab_type IS TABLE OF hri_cs_jobh_ct.job_id%TYPE;
  l_upd_job_ids        L_NUMBER_TAB_TYPE;

  -- Variables for Dynamic SQL
  l_job_fmly_column    VARCHAR2(1000);
  l_job_fnctn_column   VARCHAR2(1000);
  l_sql_stmt           VARCHAR2(32000);

BEGIN

  -- Get the job family and function column strings
  l_job_fnctn_column := get_column_string
                         (p_job_type  => 'JOB_FUNCTION',
                          p_flex_type => get_flexfield_type('JOB_FUNCTION'));
  l_job_fmly_column :=  get_column_string
                         (p_job_type  => 'JOB_FAMILY',
                          p_flex_type => get_flexfield_type('JOB_FAMILY'));

 -- Insert completely new rows
  l_sql_stmt :=
'INSERT INTO hri_cs_jobh_ct
  (job_id
  ,job_fmly_code
  ,job_fnctn_code
  ,last_update_date
  ,last_update_login
  ,last_updated_by
  ,created_by
  ,creation_date )
 SELECT
   job.job_id       job_id
  ,' || l_job_fmly_column  || '
  ,' || l_job_fnctn_column || '
  ,:l_current_time
  ,:l_user_id
  ,:l_user_id
  ,:l_user_id
  ,:l_current_time
  FROM
   per_jobs             job
  ,per_job_definitions  pjd
  WHERE  job.job_definition_id = pjd.job_definition_id
  AND NOT EXISTS
   (SELECT null
    FROM hri_cs_jobh_ct jobh
    WHERE jobh.job_id = job.job_id)';

  EXECUTE IMMEDIATE l_sql_stmt USING
    l_current_time
   ,l_user_id
   ,l_user_id
   ,l_user_id
   ,l_current_time;

  -- Commit changes
  COMMIT;

 -- Delete rows which no longer exist
 -- Bug 3347127 - don't delete unassigned row
 DELETE FROM hri_cs_jobh_ct  jobh
 WHERE NOT EXISTS
  (SELECT null
   FROM per_jobs job
   WHERE job.job_id = jobh.job_id)
 AND jobh.job_id <> -1;

 -- Update changed rows
 -- 3943809 The job family and function values is determined by the function
 -- get_family_function_code based on the setup
  l_sql_stmt :=
'UPDATE hri_cs_jobh_ct jobh
 SET (job_fmly_code
     ,job_fnctn_code) =
     (SELECT
       ' || l_job_fmly_column  || '
      ,' || l_job_fnctn_column || '
      FROM
       per_jobs             job
      ,per_job_definitions  pjd
      WHERE job.job_definition_id = pjd.job_definition_id
      AND job.job_id = jobh.job_id)
 WHERE EXISTS
  (SELECT null
   FROM
    per_jobs            job
   ,per_job_definitions pjd
   WHERE job.job_definition_id = pjd.job_definition_id
   AND job.job_id = jobh.job_id
   AND (jobh.job_fmly_code <> ' || l_job_fmly_column  || '
     OR jobh.job_fnctn_code <> ' || l_job_fnctn_column || ')
  )
 RETURNING jobh.job_id INTO :l_upd_job_ids';

  EXECUTE IMMEDIATE l_sql_stmt RETURNING BULK COLLECT INTO l_upd_job_ids;

  -- Commit changes
  COMMIT;

  -- If the job family and function of any of the existing records is changed then
  -- the corresponding changes should be refelected in the assingment delta table also
  -- So insert the JOB_ID of the updated records into the assingment delta table
  -- so that the changes can be made to the assignment delta table by the incr process

  IF (l_upd_job_ids.LAST > 0 AND
      fnd_profile.value('HRI_IMPL_DBI') = 'Y') THEN

    BEGIN

      FORALL i IN 1..l_upd_job_ids.LAST SAVE EXCEPTIONS
        INSERT INTO HRI_EQ_ASG_SUP_WRFC
         (SOURCE_TYPE,
          SOURCE_ID)
      VALUES
         ('JOB',
          l_upd_job_ids(i));

    EXCEPTION WHEN OTHERS THEN

      dbg(sql%bulk_exceptions.count|| ' job records already exists in the event queue ');

    END;

    -- Commit changes
    COMMIT;

  END IF;

END update_hierarchy_table;
--
--
-- ----------------------------------------------------------------------------
-- Full Refresh Entry Point
-- ----------------------------------------------------------------------------
--
PROCEDURE full_refresh IS

  l_dummy1             VARCHAR2(2000);
  l_dummy2             VARCHAR2(2000);

BEGIN

  -- Get HRI schema name
  IF (fnd_installation.get_app_info
       ('HRI',l_dummy1, l_dummy2, g_hri_schema)) THEN

    -- Initialize globals
    g_job_fmly_vset_id := fnd_profile.value('HR_BIS_JOB_FAMILY');
    g_job_fnctn_vset_id := fnd_profile.value('HR_BIS_JOB_FUNCTION');
    g_full_refresh := 'Y';

    -- Debug the parameters
    dbg('Full Refresh:  ' || g_full_refresh);
    dbg('Job Family:    ' || to_char(g_job_fmly_vset_id));
    dbg('Job Function:  ' || to_char(g_job_fnctn_vset_id));

    -- Reset global caches
    g_job_fmly_flex_type := NULL;
    g_job_fnctn_flex_type := NULL;
    job_flex_cache := job_flex_reset;

    refresh_config_table;

    generate_lov_views;

    collect_hierarchy_table;

  END IF;

END full_refresh;

-- ----------------------------------------------------------------------------
-- Full Refresh Entry Point from concurrent manager
-- ----------------------------------------------------------------------------
PROCEDURE full_refresh(errbuf     OUT NOCOPY VARCHAR2,
                       retcode    OUT NOCOPY VARCHAR2) IS

BEGIN
  full_refresh;
EXCEPTION WHEN OTHERS THEN
    errbuf  := SQLERRM;
    retcode := SQLCODE;
    RAISE;
END full_refresh;

-- ----------------------------------------------------------------------------
-- Incremental Refresh Entry Point
-- ----------------------------------------------------------------------------
PROCEDURE incr_refresh IS

BEGIN

  -- Initialize globals
  g_full_refresh := 'N';

  -- Reset global caches
  g_job_fmly_flex_type := NULL;
  g_job_fnctn_flex_type := NULL;
  job_flex_cache := job_flex_reset;

  -- Debug the parameters
  dbg('Full Refresh:  ' || g_full_refresh);

  -- Incrementally update job hierarchy table
  update_hierarchy_table;

END incr_refresh;

-- ----------------------------------------------------------------------------
-- Incremental Refresh Entry Point from concurrent manager
-- ----------------------------------------------------------------------------
PROCEDURE incr_refresh(errbuf     OUT NOCOPY VARCHAR2,
                       retcode    OUT NOCOPY VARCHAR2) IS

BEGIN
  incr_refresh;
EXCEPTION WHEN OTHERS THEN
    errbuf  := SQLERRM;
    retcode := SQLCODE;
    RAISE;
END incr_refresh;

-- ----------------------------------------------------------------------------
-- Obsolete Incremental Refresh Entry point
-- ----------------------------------------------------------------------------
PROCEDURE incr_refresh(p_refresh_flex  IN VARCHAR2) IS

BEGIN

  incr_refresh;

END incr_refresh;
END hri_opl_jobh;

/
