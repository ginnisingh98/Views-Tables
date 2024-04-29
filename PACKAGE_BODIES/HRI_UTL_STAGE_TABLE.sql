--------------------------------------------------------
--  DDL for Package Body HRI_UTL_STAGE_TABLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_UTL_STAGE_TABLE" AS
/* $Header: hriutstg.pkb 120.0 2006/01/20 02:05 jtitmas noship $ */

  g_rtn                           VARCHAR2(30) := '
';

-- -----------------------------------------------------------------------------
-- Returns name for the staging table generated from the master table name
-- -----------------------------------------------------------------------------
FUNCTION get_staging_table_name(p_master_table_name  IN VARCHAR2)
    RETURN VARCHAR2 IS

  l_staging_table_name   VARCHAR2(30);

BEGIN

  -- Make a unique prefix
  l_staging_table_name := SUBSTR(p_master_table_name, 1, 26) || '_STT';

  -- Return staging table name
  RETURN l_staging_table_name;

END get_staging_table_name;


-- -----------------------------------------------------------------------------
-- Creates staging table
-- -----------------------------------------------------------------------------
PROCEDURE create_staging_table(p_owner      IN VARCHAR2,
                               p_master_table_name IN VARCHAR2) IS

  -- Storage definition of master table
  CURSOR storage_csr IS
  SELECT
   tablespace_name
  ,initial_extent
  ,next_extent
  ,ini_trans
  ,max_trans
  ,min_extent
  ,max_extent
  ,pct_increase
  ,'1' || partition_name  order_by
  FROM all_tab_partitions
  WHERE table_owner = p_owner
  AND table_name = p_master_table_name
  UNION ALL
  SELECT
   tablespace_name
  ,initial_extent
  ,next_extent
  ,ini_trans
  ,max_trans
  ,min_extents
  ,max_extents
  ,pct_increase
  ,'2'
  FROM all_tables
  WHERE owner = p_owner
  AND table_name = p_master_table_name
  ORDER BY 9;

  l_sql_stmt  VARCHAR2(3000);
  l_fnd_schema                    VARCHAR2(40);
  l_dummy1                        VARCHAR2(2000);
  l_dummy2                        VARCHAR2(2000);
  l_tablespace_name               VARCHAR2(100);
  l_initial_extent                VARCHAR2(100);
  l_next_extent                   VARCHAR2(100);
  l_ini_trans                     VARCHAR2(100);
  l_max_trans                     VARCHAR2(100);
  l_min_extents                   VARCHAR2(100);
  l_max_extents                   VARCHAR2(100);
  l_pct_increase                  VARCHAR2(100);
  l_order_by                      VARCHAR2(100);
  l_staging_table_name            VARCHAR2(30);

BEGIN

  -- Get staging table name
  l_staging_table_name := get_staging_table_name
                           (p_master_table_name);

  -- Get storage parameters of master table
  OPEN storage_csr;
  FETCH storage_csr INTO
    l_tablespace_name,
    l_initial_extent,
    l_next_extent,
    l_ini_trans,
    l_max_trans,
    l_min_extents,
    l_max_extents,
    l_pct_increase,
    l_order_by;
  CLOSE storage_csr;

  -- Create staging table with a single worker column
  -- and a single partition (more will be added in next step)
  -- using the storage parameters of the master table
  l_sql_stmt := 'CREATE TABLE ' || l_staging_table_name ||
                ' (WORKER_ID  NUMBER) ' ||
                'PARTITION BY LIST(WORKER_ID)' ||
                ' (PARTITION p1 VALUES(1)) ' ||
                'TABLESPACE ' || l_tablespace_name || ' ' ||
                'INITRANS '   || l_ini_trans       || ' ' ||
                'MAXTRANS '   || l_max_trans       || ' ' ||
                'STORAGE (INITIAL '     || l_initial_extent || ' ' ||
                         'NEXT '        || l_next_extent    || ' ' ||
                         'MINEXTENTS '  || l_min_extents    || ' ' ||
                         'MAXEXTENTS '  || l_max_extents    || ' ' ||
                         'PCTINCREASE ' || l_pct_increase   || ')';

  -- Use AD API to create table
  IF (fnd_installation.get_app_info('FND',l_dummy1, l_dummy2, l_fnd_schema)) THEN
    ad_ddl.do_ddl(applsys_schema         => l_fnd_schema,
                  application_short_name => 'HRI',
                  statement_type         => ad_ddl.create_table,
                  statement              => l_sql_stmt,
                  object_name            => l_staging_table_name);
  END IF;

END create_staging_table;


-- -----------------------------------------------------------------------------
-- Truncates staging table
-- -----------------------------------------------------------------------------
PROCEDURE empty_staging_table(p_owner      IN VARCHAR2,
                              p_master_table_name IN VARCHAR2) IS

  l_sql_stmt  VARCHAR2(3000);

BEGIN

  l_sql_stmt := 'TRUNCATE TABLE ' || p_owner || '.' || get_staging_table_name
                                                        (p_master_table_name);

  EXECUTE IMMEDIATE l_sql_stmt;

END empty_staging_table;


-- -----------------------------------------------------------------------------
-- Adds in any new columns
-- Modifies any updated columns
-- Adds any required partitions
-- -----------------------------------------------------------------------------
PROCEDURE maintain_staging_table(p_owner      IN VARCHAR2,
                                 p_master_table_name IN VARCHAR2) IS

  CURSOR add_column_csr(v_table_name  VARCHAR2) IS
  SELECT
   column_name
  ,DECODE(data_type,
            'VARCHAR2', data_type || '(' || data_length || ')',
          data_type)            data_type
  FROM all_tab_cols a
  WHERE table_name = p_master_table_name
  AND owner = p_owner
  AND NOT EXISTS
   (SELECT
      null
    FROM all_tab_cols b
    WHERE b.table_name = v_table_name
    AND b.owner = p_owner
    AND b.column_name = a.column_name);

  CURSOR modify_column_csr(v_table_name  VARCHAR2) IS
  SELECT
   column_name
  ,DECODE(data_type,
            'VARCHAR2', data_type || '(' || data_length || ')',
          data_type)            data_type
  FROM all_tab_cols a
  WHERE table_name = p_master_table_name
  AND owner = p_owner
  AND data_type = 'VARCHAR2'
  AND EXISTS
   (SELECT
      null
    FROM all_tab_cols b
    WHERE b.table_name = v_table_name
    AND b.owner = p_owner
    AND b.column_name = a.column_name
    AND b.data_length < a.data_length);

  l_count                         PLS_INTEGER;
  l_staging_table_name            VARCHAR2(30);
  l_sql_stmt                      VARCHAR2(32000);
  l_fnd_schema                    VARCHAR2(40);
  l_dummy1                        VARCHAR2(2000);
  l_dummy2                        VARCHAR2(2000);

BEGIN

  -- Get staging table name
  l_staging_table_name := get_staging_table_name
                           (p_master_table_name);

  -- Add the required number of partitions
  hri_utl_ddl.maintain_mthd_partitions
   (p_table_name  => l_staging_table_name,
    p_table_owner => p_owner);

  -- Add in any missing columns
  l_sql_stmt := 'ALTER TABLE ' || p_owner || '.' || l_staging_table_name ||
                ' ADD' || g_rtn ||
                ' (' || g_rtn;

  -- Loop through any columns that are to be added
  l_count := 0;
  FOR col_rec IN add_column_csr(l_staging_table_name) LOOP
    l_sql_stmt := l_sql_stmt || '  ' || col_rec.column_name || '  ' ||
                                        col_rec.data_type || ',' || g_rtn;
    l_count := l_count + 1;
  END LOOP;

  -- Replace trailing comma with a close bracket
  l_sql_stmt := RTRIM(l_sql_stmt, g_rtn);
  l_sql_stmt := RTRIM(l_sql_stmt, ',') || ' )';

  -- Execute if any columns need adding
  IF (l_count > 0) THEN
    EXECUTE IMMEDIATE l_sql_stmt;
  END IF;

  -- Modify any changed columns
  l_sql_stmt := 'ALTER TABLE ' || p_owner || '.' || l_staging_table_name ||
                ' MODIFY' || g_rtn ||
                ' (' || g_rtn;

  -- Loop through any changed columns
  l_count := 0;
  FOR col_rec IN modify_column_csr(l_staging_table_name) LOOP
    l_sql_stmt := l_sql_stmt || '  ' || col_rec.column_name || '  ' ||
                                        col_rec.data_type || ',' || g_rtn;
    l_count := l_count + 1;
  END LOOP;

  -- Replace trailing comma with a close bracket
  l_sql_stmt := RTRIM(l_sql_stmt, g_rtn);
  l_sql_stmt := RTRIM(l_sql_stmt, ' ,') || ')';

  -- Execute if any columns need adding
  IF (l_count > 0) THEN
    EXECUTE IMMEDIATE l_sql_stmt;
  END IF;

END maintain_staging_table;

-- -----------------------------------------------------------------------------
-- Setup staging table
-- -----------------------------------------------------------------------------
PROCEDURE set_up(p_owner      IN VARCHAR2,
                 p_master_table_name IN VARCHAR2) IS

  CURSOR object_csr(v_table_name  VARCHAR2) IS
  SELECT count(*)
  FROM all_tables
  WHERE owner = p_owner
  AND table_name = v_table_name;

  l_staging_table_name            VARCHAR2(30);
  staging_table_exists_ind        PLS_INTEGER;

BEGIN

  -- Get staging table name
  l_staging_table_name := get_staging_table_name
                           (p_master_table_name);

  -- Open cursor to check if table exists
  OPEN object_csr(l_staging_table_name);
  FETCH object_csr INTO staging_table_exists_ind;
  CLOSE object_csr;

  IF (staging_table_exists_ind = 0 OR staging_table_exists_ind IS NULL) THEN

    -- Create staging table if it doesn't exist
    create_staging_table
     (p_owner => p_owner,
      p_master_table_name => p_master_table_name);

  ELSE

    -- Otherwise truncate staging table
    empty_staging_table
     (p_owner => p_owner,
      p_master_table_name => p_master_table_name);

  END IF;

  -- Check for columns to add/modify and check partitions
  maintain_staging_table
   (p_owner => p_owner,
    p_master_table_name => p_master_table_name);

END set_up;

-- -----------------------------------------------------------------------------
-- Moves data from the staging table to the master table
-- -----------------------------------------------------------------------------
PROCEDURE load_master_table(p_owner      IN VARCHAR2,
                            p_master_table_name IN VARCHAR2) IS

  l_sql_stmt  VARCHAR2(32000);
  l_col_list  VARCHAR2(32000);

  CURSOR column_csr IS
  SELECT column_name
  FROM all_tab_cols
  WHERE table_name = p_master_table_name
  AND owner = p_owner;

BEGIN

  -- Enable parallel insert
  EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
  EXECUTE IMMEDIATE 'ALTER SESSION FORCE PARALLEL QUERY';
  EXECUTE IMMEDIATE 'ALTER TABLE ' || p_owner || '.' || p_master_table_name ||
                    ' PARALLEL';

  -- Build up list of columns
  FOR col_rec IN column_csr LOOP
    l_col_list := l_col_list || '  ' || col_rec.column_name || ',' || g_rtn;
  END LOOP;

  -- Remove trailing comma
  l_col_list := RTRIM(l_col_list, g_rtn);
  l_col_list := RTRIM(l_col_list, ',');

  -- Build insert statement
  l_sql_stmt := 'INSERT /*+ APPEND */ INTO ' || p_master_table_name || g_rtn ||
                ' (' || l_col_list || ' ) ' || g_rtn ||
                'SELECT' || g_rtn ||
                  l_col_list || g_rtn ||
                'FROM ' || get_staging_table_name
                            (p_master_table_name);

  -- Load the table
  EXECUTE IMMEDIATE l_sql_stmt;

END load_master_table;


-- -----------------------------------------------------------------------------
-- Clean up staging table
-- -----------------------------------------------------------------------------
PROCEDURE clean_up(p_owner      IN VARCHAR2,
                   p_master_table_name IN VARCHAR2) IS

BEGIN

  -- Move data to master table
  load_master_table
   (p_owner => p_owner,
    p_master_table_name => p_master_table_name);

  -- Truncate table
  empty_staging_table
   (p_owner => p_owner,
    p_master_table_name => p_master_table_name);

END clean_up;


END HRI_UTL_STAGE_TABLE;

/
