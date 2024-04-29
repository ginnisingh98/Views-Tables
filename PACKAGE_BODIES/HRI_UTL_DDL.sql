--------------------------------------------------------
--  DDL for Package Body HRI_UTL_DDL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_UTL_DDL" AS
/* $Header: hriutddl.pkb 120.2 2006/01/20 02:04:45 jtitmas noship $ */
--
-- -----------------------------------------------------------------------------
-- PROCEDURE recreate_indexes
-- -----------------------------------------------------------------------------
--
-- This procedure recreates the indexes for the specified table using the
-- definitions stored in the temporary table
--
-- Parameter                 Type  Description
-- ------------------------  ----  ---------------------------------------------
-- p_application_short_name  IN    Short name of the application product
--                                 calling this routine
-- p_table_name              IN    Table for which the indexes are to be dropped
-- p_table_owner             IN    Name of the Schema owning the table
-- -----------------------------------------------------------------------------
--
PROCEDURE recreate_indexes(p_application_short_name IN VARCHAR2,
                           p_table_name    IN VARCHAR2,
                           p_table_owner   IN VARCHAR2)
IS
  --
  -- Gets create index statements from the temporary ddl table
  --
  CURSOR index_csr IS
  SELECT ddl_object
        ,ddl_stmt
        ,ddl_type
  FROM   hri_utl_dynmc_ddl_infrmtn
  WHERE  table_name  = p_table_name
  AND    table_owner = p_table_owner
  AND    ddl_type IN ('INDEX', 'INDEX LOGGING')
  ORDER BY DECODE(ddl_type, 'INDEX', 1, 2);
  --
  -- Variables for getting the APPLSYS schema name
  --
  l_fnd_schema              VARCHAR2(300);
  l_dummy1                  VARCHAR2(2000);
  l_dummy2                  VARCHAR2(2000);
  --
BEGIN
  --
  -- Get APPLSYS schema name
  --
  IF (fnd_installation.get_app_info('FND',l_dummy1, l_dummy2, l_fnd_schema)) THEN
    --
    -- Loop through indexes to recreate / alter
    --
    FOR index_rec IN index_csr LOOP
      --
      IF (index_rec.ddl_type = 'INDEX') THEN
        --
        -- use AD API to recreate index
        --
        ad_ddl.do_ddl(applsys_schema         => l_fnd_schema,
                      application_short_name => p_application_short_name,
                      statement_type         => ad_ddl.create_index,
                      statement              => index_rec.ddl_stmt,
                      object_name            => index_rec.ddl_object);
        --
      ELSIF (index_rec.ddl_type = 'INDEX LOGGING') THEN
        --
        -- alter index
        --
        EXECUTE IMMEDIATE index_rec.ddl_stmt;
        --
      END IF;
      --
      -- Remove temporary ddl
      --
      DELETE FROM hri_utl_dynmc_ddl_infrmtn
      WHERE table_name = p_table_name
      AND table_owner = p_table_owner
      AND ddl_object = index_rec.ddl_object
      AND ddl_type = index_rec.ddl_type;
      --
    END LOOP;
    --
    -- for bug 3738009, commiting the transaction so that the transaction is not open after
    -- completion of this process
    --
    COMMIT;
    --
  END IF;
  --
END recreate_indexes;
--
-- -----------------------------------------------------------------------------
-- PROCEDURE log_and_drop_indexes
-- -----------------------------------------------------------------------------
--
-- This procedure drops all the indexes for a table and inserts definition
-- of the indexes in a temporary table. Using this definition the procedure
-- recreate_indexes can recreate the indexes. If some of the indexes are not
-- to be dropped, a comma separated list can be passed in parameter
-- p_index_excptn_lst.
--
-- NOTE: The procedure will not drop the primary key index.
--
-- Parameter                 Type  Description
-- ------------------------  ----  ---------------------------------------------
-- p_application_short_name  IN    Short name of the application product
--                                 calling this routine
-- p_table_name              IN    Table for which the indexes are to be dropped
-- p_table_owner             IN    Name of the Schema owning the table
-- p_index_excptn_lst        IN    Pass a comma separated list of indexes which
--                                 are not to be dropped
-- -----------------------------------------------------------------------------
--
PROCEDURE log_and_drop_indexes(p_application_short_name IN VARCHAR2,
                               p_table_name       IN VARCHAR2,
                               p_table_owner      IN VARCHAR2,
                               p_index_excptn_lst IN VARCHAR2 DEFAULT NULL )
IS
  --
  -- Cursor to get the index properties
  --
  -- Create index with NOLOGGING
  -- Alter index after creation if LOGGING is set
  --
  CURSOR  storage_csr IS
  SELECT  index_name                                        index_name
          ,DECODE(uniqueness, 'UNIQUE', 'UNIQUE ', null)    uniqueness
          ,DECODE(INDEX_TYPE,'NORMAL',null,INDEX_TYPE)      index_type
          ,NVL(LOGGING, 'NO')                               logging
          ,DECODE(PARTITIONED,'YES','LOCAL ',' ')           ||
          DECODE(NVL(TABLESPACE_NAME,'###'),'###',null,'TABLESPACE ' ||TABLESPACE_NAME) ||
          ' NOLOGGING'         ||
          ' STORAGE (INITIAL ' || NVL(to_char(initial_extent), '4K') ||
          ' NEXT '             || NVL(to_char(next_extent), '40K') ||
          ' MINEXTENTS '       || NVL(to_char(min_extents), '1') ||
          ' MAXEXTENTS '       || NVL(to_char(max_extents), 'UNLIMITED') ||
          ' PCTINCREASE '      || NVL(to_char(pct_increase), '0') ||
          ' FREELIST GROUPS '  || NVL(to_char(freelist_groups), '4') ||
          ' FREELISTS '        || NVL(to_char(freelists), '4') || ')' ||
          ' PCTFREE '          || NVL(to_char(pct_free), '10') ||
          ' INITRANS '         || NVL(to_char(ini_trans), '11') ||
          ' MAXTRANS '         || NVL(to_char(max_trans), '255') ||
          ' PARALLEL ' storage_clause
  FROM    dba_indexes
  WHERE   table_name  = p_table_name
  AND     table_owner = p_table_owner
  AND     owner       = p_table_owner
  --
  -- for bug 3738009, filter out the system created indexes on the materialized
  -- views since these are not to be dropped and recreated
  --
  AND     index_name NOT LIKE 'I_SNAP$%';
  --
  -- Cursor to get the table columns referenced by the index
  --
  CURSOR   index_columns_csr(v_index_name  VARCHAR2) IS
  SELECT   column_name
  FROM     dba_ind_columns
  WHERE    index_owner = p_table_owner
  AND      table_owner = p_table_owner
  AND      table_name  = p_table_name
  AND      index_name  = v_index_name
  ORDER BY column_position;
  --
  -- Variables for getting the APPLSYS schema name
  --
  l_fnd_schema              VARCHAR2(300);
  l_dummy1                  VARCHAR2(2000);
  l_dummy2                  VARCHAR2(2000);
  --
  -- Other local variable
  --
  l_index_columns           VARCHAR2(2000);
  l_create_index_stmt       VARCHAR2(4000);
  l_alter_index_stmt        VARCHAR2(4000);
  l_drop_index_stmt         VARCHAR2(4000);
  --
  -- Exception
  --
  PRIMARY_KEY_INDEX         EXCEPTION;
  --
  pragma exception_init(PRIMARY_KEY_INDEX,-02429);
  --
BEGIN
  --
  -- Get APPLSYS schema name
  --
  IF (fnd_installation.get_app_info('FND',l_dummy1, l_dummy2, l_fnd_schema)) THEN
    --
    -- Loop through indexes defined on the table
    --
    FOR index_rec IN storage_csr LOOP
      --
      -- Do not drop the index if it is included in the list of exceptional
      -- index which are not to be dropped.
      --
      IF nvl(instr(p_index_excptn_lst, index_rec.index_name),0) = 0 then
        --
        -- Initialize index column list
        --
        l_index_columns := NULL;
        --
        -- Loop through columns the index references
        --
        FOR index_column IN index_columns_csr(index_rec.index_name) LOOP
          --
          -- Build up the index column list
          --
          l_index_columns := l_index_columns || index_column.column_name || ',';
          --
        END LOOP;
        --
        -- Add the bracketing, remove the last comma to format the columnn string
        --
        IF (l_index_columns IS NOT NULL) THEN
          --
          l_index_columns := '(' || RTRIM(l_index_columns,',') || ')';
          --
        END IF;
        --
        -- Build up the index creation statement
        --
        l_create_index_stmt := 'CREATE ' || index_rec.uniqueness  || ' '
                                         || index_rec.index_type  || ' INDEX '
                                         || p_table_owner         || '.'
                                         || index_rec.index_name  || ' ON '
                                         || p_table_owner         || '.'
                                         || p_table_name          || ' '
                                         || l_index_columns       || ' '
                                         || index_rec.storage_clause;
        --
        -- Build alter index statement
        --
        IF index_rec.logging = 'YES' THEN
          l_alter_index_stmt := 'ALTER INDEX ' || p_table_owner         || '.'
                                               || index_rec.index_name  ||
                                ' LOGGING NOPARALLEL';
        END IF;
        --
        -- Build drop index statement
        --
        l_drop_index_stmt := 'DROP INDEX ' || p_table_owner || '.' || index_rec.index_name;
        --
        -- use AD API to drop the index
        --
	BEGIN
	  --
          ad_ddl.do_ddl(applsys_schema       => l_fnd_schema,
                      application_short_name => p_application_short_name,
                      statement_type         => ad_ddl.drop_index,
                      statement              => l_drop_index_stmt,
                      object_name            => index_rec.index_name);
          --
          BEGIN
            --
            -- Store the index creation statement in the temporary ddl table
            --
            INSERT INTO hri_utl_dynmc_ddl_infrmtn
                   (table_name
                   ,table_owner
                   ,ddl_object
                   ,ddl_type
                   ,ddl_stmt)
            VALUES
                   (p_table_name
                   ,p_table_owner
                   ,index_rec.index_name
                   ,'INDEX'
                   ,l_create_index_stmt);
             --
          EXCEPTION WHEN OTHERS THEN
             --
             -- Unique index on table violated, so an entry already exist in
             -- the table for the index. Update the existing record.
             --
             UPDATE hri_utl_dynmc_ddl_infrmtn
             SET    ddl_stmt    = l_create_index_stmt
             WHERE  table_name  = p_table_name
             AND    table_owner = p_table_owner
             AND    ddl_object  = index_rec.index_name
             AND    ddl_type    = 'INDEX';
             --
          END;
          --
          IF (index_rec.logging = 'YES') THEN
            --
            BEGIN
              --
              -- Store the alter index statement
              --
              INSERT INTO hri_utl_dynmc_ddl_infrmtn
                   (table_name
                   ,table_owner
                   ,ddl_object
                   ,ddl_type
                   ,ddl_stmt)
                VALUES
                   (p_table_name
                   ,p_table_owner
                   ,index_rec.index_name
                   ,'INDEX LOGGING'
                   ,l_alter_index_stmt);
              --
            EXCEPTION WHEN OTHERS THEN
              --
              -- Unique index on table violated, so an entry already exist in
              -- the table for the index. Update the existing record.
              --
              UPDATE hri_utl_dynmc_ddl_infrmtn
              SET    ddl_stmt    = l_alter_index_stmt
              WHERE  table_name  = p_table_name
              AND    table_owner = p_table_owner
              AND    ddl_object  = index_rec.index_name
              AND    ddl_type    = 'INDEX LOGGING';
              --
            END;
            --
          END IF;

        EXCEPTION
          --
          -- ad_ddl.do_ddl raises an exception when it tries to drop a primary
          -- key index on a table. ignore the error and continue
          --
          WHEN PRIMARY_KEY_INDEX THEN
            --
            null;
            --
        END;
        --
      END IF; -- End of exception index list handling
      --
    END LOOP; -- End of storage_csr loop
    --
    -- for bug 3738009, commiting the transaction so that the transaction is not open after
    -- completion of this process
    --
    COMMIT;
    --
  END IF;     -- End of FND product installation check
  --
END log_and_drop_indexes;
--
PROCEDURE maintain_mthd_partitions(p_table_name          IN VARCHAR2,
                                   p_table_owner         IN VARCHAR2) IS

  CURSOR no_tab_parts_csr IS
  SELECT partition_count
  FROM all_part_tables
  WHERE table_name = p_table_name
  AND owner = p_table_owner;

  l_no_threads        PLS_INTEGER;
  l_no_parts          PLS_INTEGER;
  l_sql_stmt          VARCHAR2(32000);

BEGIN

  -- Get number of child threads and add one for master process
  l_no_threads := NVL(fnd_profile.value('HRI_NO_THRDS_LAUNCH'),8) + 1;

  -- Get number of existing partitions
  OPEN no_tab_parts_csr;
  FETCH no_tab_parts_csr INTO l_no_parts;
  CLOSE no_tab_parts_csr;

  -- Add any extra partitions as required
  IF (l_no_parts < l_no_threads) THEN

    FOR i IN (l_no_parts + 1)..(l_no_threads) LOOP

      l_sql_stmt :=
'ALTER TABLE ' || p_table_owner || '.' || p_table_name ||
' ADD PARTITION p' || to_char(i) || ' VALUES(' || to_char(i) || ')';

      EXECUTE IMMEDIATE l_sql_stmt;

    END LOOP;

  END IF;

END maintain_mthd_partitions;

END HRI_UTL_DDL;

/
