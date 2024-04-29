--------------------------------------------------------
--  DDL for Package Body JTY_TRANS_USG_PGM_SQL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_TRANS_USG_PGM_SQL_PKG" as
/* $Header: jtftupsb.pls 120.2 2005/11/21 13:34:02 achanda noship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TRANS_USG_PGM_SQL_PKG
--    ---------------------------------------------------
--    PURPOSE
--      This package is used to create the transaction type SQLs
--      and the corresponding TRANS tables.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      09/08/05    ACHANDA         Created
--
--    End of Comments
--

PROCEDURE Insert_Row(
   p_source_id IN NUMBER
  ,p_trans_type_id IN NUMBER
  ,p_program_name IN VARCHAR2
  ,p_version_name IN VARCHAR2
  ,p_real_time_sql IN VARCHAR2
  ,p_batch_total_sql IN VARCHAR2
  ,p_batch_incr_sql IN VARCHAR2
  ,p_batch_dea_sql IN VARCHAR2
  ,p_incr_reassign_sql IN VARCHAR2
  ,p_use_total_for_dea_flag IN VARCHAR2
  ,p_enabled_flag IN VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,errbuf OUT NOCOPY VARCHAR2) IS

  l_enabled_flag           VARCHAR2(1);
  l_use_total_for_dea_flag VARCHAR2(1);

  l_param_passing_mechanism     VARCHAR2(3);
  l_real_time_enable_flag       VARCHAR2(1);
  l_batch_enable_flag           VARCHAR2(1);
  l_real_time_trans_table_name  VARCHAR2(30);
  l_batch_trans_table_name      VARCHAR2(30);
  l_batch_nm_trans_table_name   VARCHAR2(30);
  l_batch_dea_trans_table_name  VARCHAR2(30);

  l_user_id              NUMBER;
  l_login_id             NUMBER;
  l_sysdate              DATE;
  first_time             BOOLEAN;
  l_trans_usg_pgm_sql_id NUMBER;
  l_new_line             VARCHAR2(02) := fnd_global.local_chr(10);
  l_indent               VARCHAR2(30);

  l_real_time_insert VARCHAR2(32767);
  l_real_time_select VARCHAR2(32000);
  l_create_gt_stmt   VARCHAR2(32767);
  l_drop_gt_stmt     VARCHAR2(1000);
  l_create_tbl_stmt  VARCHAR2(32767);
  l_drop_tbl_stmt    VARCHAR2(1000);
  l_alter_tbl_stmt   VARCHAR2(32767);

  l_real_time_sql_clob	    CLOB;
  l_real_time_insert_clob	CLOB;
  l_batch_total_sql_clob	CLOB;
  l_batch_incr_sql_clob	    CLOB;
  l_batch_dea_sql_clob	    CLOB;
  l_incr_reassign_sql_clob	CLOB;

  l_status         VARCHAR2(30);
  l_industry       VARCHAR2(30);
  l_jtf_schema     VARCHAR2(30);

  CURSOR c_column_names(p_table_name IN VARCHAR2) is
  SELECT column_name
  FROM  user_tab_columns
  WHERE table_name = p_table_name
  ORDER BY column_id;

  CURSOR CUR_REAL_TIME(cl_trans_usg_pgm_sql_id IN NUMBER) IS
  SELECT REAL_TIME_SQL
  FROM   JTY_TRANS_USG_PGM_SQL
  WHERE  TRANS_USG_PGM_SQL_ID = cl_trans_usg_pgm_sql_id
  FOR UPDATE OF REAL_TIME_SQL NOWAIT;

  CURSOR CUR_REAL_TIME_INSERT(cl_trans_usg_pgm_sql_id IN NUMBER) IS
  SELECT REAL_TIME_INSERT
  FROM   JTY_TRANS_USG_PGM_SQL
  WHERE  TRANS_USG_PGM_SQL_ID = cl_trans_usg_pgm_sql_id
  FOR UPDATE OF REAL_TIME_INSERT NOWAIT;

  CURSOR CUR_BATCH_TOTAL(cl_trans_usg_pgm_sql_id IN NUMBER) IS
  SELECT BATCH_TOTAL_SQL
  FROM   JTY_TRANS_USG_PGM_SQL
  WHERE  TRANS_USG_PGM_SQL_ID = cl_trans_usg_pgm_sql_id
  FOR UPDATE OF BATCH_TOTAL_SQL NOWAIT;

  CURSOR CUR_BATCH_INCR(cl_trans_usg_pgm_sql_id IN NUMBER) IS
  SELECT BATCH_INCR_SQL
  FROM   JTY_TRANS_USG_PGM_SQL
  WHERE  TRANS_USG_PGM_SQL_ID = cl_trans_usg_pgm_sql_id
  FOR UPDATE OF BATCH_INCR_SQL NOWAIT;

  CURSOR CUR_BATCH_DEA(cl_trans_usg_pgm_sql_id IN NUMBER) IS
  SELECT BATCH_DEA_SQL
  FROM   JTY_TRANS_USG_PGM_SQL
  WHERE  TRANS_USG_PGM_SQL_ID = cl_trans_usg_pgm_sql_id
  FOR UPDATE OF BATCH_DEA_SQL NOWAIT;

  CURSOR CUR_INCR_REASSIGN(cl_trans_usg_pgm_sql_id IN NUMBER) IS
  SELECT INCR_REASSIGN_SQL
  FROM   JTY_TRANS_USG_PGM_SQL
  WHERE  TRANS_USG_PGM_SQL_ID = cl_trans_usg_pgm_sql_id
  FOR UPDATE OF INCR_REASSIGN_SQL NOWAIT;

BEGIN

  retcode := 0;
  errbuf  := null;

  /* Version cannot be null or ORACLE (reserved for seeded SQLs) */
  IF ((p_version_name IS NULL) OR (p_version_name = 'ORACLE')) THEN
    retcode := 2;
    errbuf  := 'Version Name cannot be null or oracle';
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_enabled_flag := NVL(p_enabled_flag, 'Y');
  l_use_total_for_dea_flag := NVL(p_use_total_for_dea_flag, 'N');

  l_user_id  := FND_GLOBAL.USER_ID;
  l_login_id := FND_GLOBAL.CONC_LOGIN_ID;
  l_sysdate  := sysdate;

  BEGIN
    SELECT
       param_passing_mechanism
      ,real_time_enable_flag
      ,batch_enable_flag
      ,real_time_trans_table_name
      ,batch_trans_table_name
      ,batch_nm_trans_table_name
      ,batch_dea_trans_table_name
    INTO
       l_param_passing_mechanism
      ,l_real_time_enable_flag
      ,l_batch_enable_flag
      ,l_real_time_trans_table_name
      ,l_batch_trans_table_name
      ,l_batch_nm_trans_table_name
      ,l_batch_dea_trans_table_name
    FROM jty_trans_usg_pgm_details
    WHERE source_id = p_source_id
    AND   trans_type_id = p_trans_type_id
    AND   program_name = p_program_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      retcode := 2;
      errbuf  := 'No row in the table jty_trans_usg_pgm_details corr to the source, transaction type and program name passed';
      RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
      RAISE;
  END;

  /* Custom Qualifier supported for pass by reference only */
  IF (l_param_passing_mechanism = 'PBV') THEN
    retcode := 2;
    errbuf  := 'Custom Qualifier is not supported for transactions having pass by value parameter passing mechanism';
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* If this version needs to be enabled, then all other versions need to be disabled */
  IF (l_enabled_flag = 'Y') THEN
    UPDATE jty_trans_usg_pgm_sql
    SET    enabled_flag = 'N'
    WHERE  SOURCE_ID     = p_source_id
    AND    TRANS_TYPE_ID = p_trans_type_id
    AND    PROGRAM_NAME  = p_program_name;
  END IF;

  /* If present, delete the old entries from jty_trnas_usg_pgm_sql */
  BEGIN
    DELETE FROM JTY_TRANS_USG_PGM_SQL
    WHERE SOURCE_ID     = p_source_id
    AND   TRANS_TYPE_ID = p_trans_type_id
    AND   PROGRAM_NAME  = p_program_name
    AND   VERSION_NAME  = p_version_name;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  /* Get the unique id from sequence */
  SELECT JTY_TRANS_USG_PGM_SQL_S.nextval
  INTO   l_trans_usg_pgm_sql_id
  FROM   DUAL;

  /* Insert a record with all the SQLs as NULL */
  INSERT INTO JTY_TRANS_USG_PGM_SQL (
     TRANS_USG_PGM_SQL_ID
    ,SOURCE_ID
    ,TRANS_TYPE_ID
    ,PROGRAM_NAME
    ,VERSION_NAME
    ,USE_TOTAL_FOR_DEA_FLAG
    ,ENABLED_FLAG
    ,REAL_TIME_SQL
    ,REAL_TIME_INSERT
    ,BATCH_TOTAL_SQL
    ,BATCH_INCR_SQL
    ,BATCH_DEA_SQL
    ,INCR_REASSIGN_SQL
    ,CREATED_BY
    ,CREATION_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATE_LOGIN
    ,OBJECT_VERSION_NUMBER)
  VALUES(
     l_trans_usg_pgm_sql_id
    ,p_source_id
    ,p_trans_type_id
    ,p_program_name
    ,p_version_name
    ,l_use_total_for_dea_flag
    ,l_enabled_flag
    ,EMPTY_CLOB()
    ,EMPTY_CLOB()
    ,EMPTY_CLOB()
    ,EMPTY_CLOB()
    ,EMPTY_CLOB()
    ,EMPTY_CLOB()
    ,l_user_id
    ,l_sysdate
    ,l_user_id
    ,l_sysdate
    ,l_login_id
    ,1);

  /* Create the real time trans table and real time transaction type SQL */
  IF ((l_real_time_enable_flag = 'Y') AND (p_real_time_sql IS NOT NULL) AND (l_real_time_trans_table_name IS NOT NULL)) THEN
    l_real_time_select := p_real_time_sql;
    l_real_time_select := replace(l_real_time_select, 'l_txn_date', 'sysdate');
    l_real_time_select := replace(l_real_time_select, 'l_trans_object_id1', '-999');
    l_real_time_select := replace(l_real_time_select, 'l_trans_object_id2', '-999');
    l_real_time_select := replace(l_real_time_select, 'l_trans_object_id3', '-999');
    l_real_time_select := replace(l_real_time_select, 'l_trans_object_id4', '-999');
    l_real_time_select := replace(l_real_time_select, 'l_trans_object_id5', '-999');

    BEGIN
      l_drop_gt_stmt := 'DROP TABLE ' || l_real_time_trans_table_name;

      EXECUTE IMMEDIATE l_drop_gt_stmt;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    l_create_gt_stmt :=
      'CREATE GLOBAL TEMPORARY TABLE ' || l_real_time_trans_table_name || ' ON COMMIT PRESERVE ROWS AS ' ||
      l_real_time_select;

    BEGIN
      EXECUTE IMMEDIATE l_create_gt_stmt;
    EXCEPTION
      when others then
        retcode := 2;
        errbuf  := 'Error while trying to create ' || l_real_time_trans_table_name || ' : SQLCODE : ' || SQLCODE ||
                   ' : SQLERRM : ' || SQLERRM;
        RAISE;
    END;

    first_time := TRUE;
    l_indent   := '  ';

    l_real_time_insert := 'INSERT INTO ' || l_real_time_trans_table_name || ' ( ';

    FOR column_names in c_column_names(l_real_time_trans_table_name) LOOP
      IF (first_time) THEN
        l_real_time_insert := l_real_time_insert || l_new_line || l_indent || column_names.column_name;
        first_time := FALSE;
      ELSE
        l_real_time_insert := l_real_time_insert || l_new_line || l_indent || ',' || column_names.column_name;
      END IF;
    END LOOP;
    l_real_time_insert := l_real_time_insert || ')' || l_new_line || p_real_time_sql || ';';

    BEGIN
      OPEN CUR_REAL_TIME_INSERT(l_trans_usg_pgm_sql_id);
      LOOP
        FETCH CUR_REAL_TIME_INSERT INTO l_real_time_insert_clob;
        EXIT WHEN CUR_REAL_TIME_INSERT%NOTFOUND;
        DBMS_LOB.OPEN(l_real_time_insert_clob, DBMS_LOB.LOB_READWRITE);
        DBMS_LOB.WRITEAPPEND(l_real_time_insert_clob,LENGTH(l_real_time_insert),l_real_time_insert);
        DBMS_LOB.CLOSE(l_real_time_insert_clob);
      END LOOP;
      CLOSE CUR_REAL_TIME_INSERT;

      OPEN CUR_REAL_TIME(l_trans_usg_pgm_sql_id);
      LOOP
        FETCH CUR_REAL_TIME INTO l_real_time_sql_clob;
        EXIT WHEN CUR_REAL_TIME%NOTFOUND;
        DBMS_LOB.OPEN(l_real_time_sql_clob, DBMS_LOB.LOB_READWRITE);
        DBMS_LOB.WRITEAPPEND(l_real_time_sql_clob,LENGTH(p_real_time_sql),p_real_time_sql);
        DBMS_LOB.CLOSE(l_real_time_sql_clob);
      END LOOP;
      CLOSE CUR_REAL_TIME;
    EXCEPTION
      when others then
        retcode := 2;
        errbuf  := 'Error while trying to update real_time_sql or real_time_insert' || ' : SQLCODE : ' || SQLCODE ||
                   ' : SQLERRM : ' || SQLERRM;
        RAISE;
    END;
  END IF;

  IF (FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_jtf_schema)) THEN
    NULL;
  END IF;

  /* Create the batch trans table and batch transaction type SQL */
  IF ((l_batch_enable_flag = 'Y') AND (l_batch_trans_table_name IS NOT NULL) AND (p_batch_total_sql IS NOT NULL)) THEN
    l_drop_tbl_stmt := 'DROP TABLE ' || l_jtf_schema || '.' || l_batch_trans_table_name;
    BEGIN
      execute immediate l_drop_tbl_stmt;
    EXCEPTION
      when others then
        null;
    END;

    l_create_tbl_stmt := 'CREATE TABLE ' || l_jtf_schema || '.' || l_batch_trans_table_name ||
                           ' PARTITION BY RANGE (worker_id) ' ||
                             '(PARTITION WORKER1 VALUES LESS THAN (1), ' ||
                              'PARTITION WORKER2 VALUES LESS THAN (2), ' ||
                              'PARTITION WORKER3 VALUES LESS THAN (3), ' ||
                              'PARTITION WORKER4 VALUES LESS THAN (4), ' ||
                              'PARTITION WORKER5 VALUES LESS THAN (5), ' ||
                              'PARTITION WORKER6 VALUES LESS THAN (6), ' ||
                              'PARTITION WORKER7 VALUES LESS THAN (7), ' ||
                              'PARTITION WORKER8 VALUES LESS THAN (8), ' ||
                              'PARTITION WORKER9 VALUES LESS THAN (9), ' ||
                              'PARTITION WORKER10 VALUES LESS THAN (10), ' ||
                              'PARTITION WORKER11 VALUES LESS THAN (11) ' ||
                             ') ' ||
                         ' AS (SELECT A.*, 1 WORKER_ID FROM ( ' || p_batch_total_sql || ' ) A WHERE 1 = 2 )';

    BEGIN
      EXECUTE IMMEDIATE l_create_tbl_stmt;
    EXCEPTION
      when others then
        retcode := 2;
        errbuf  := 'Error while trying to create ' || l_batch_trans_table_name || ' : SQLCODE : ' || SQLCODE ||
                   ' : SQLERRM : ' || SQLERRM;
        RAISE;
    END;

    l_alter_tbl_stmt := 'ALTER TABLE ' || l_jtf_schema || '.' || l_batch_trans_table_name || ' ADD ( ' ||
                        'LAST_UPDATE_DATE DATE, ' ||
                        'LAST_UPDATED_BY NUMBER, ' ||
                        'CREATION_DATE DATE, ' ||
                        'CREATED_BY NUMBER, ' ||
                        'LAST_UPDATE_LOGIN NUMBER, ' ||
                        'REQUEST_ID NUMBER, ' ||
                        'PROGRAM_APPLICATION_ID NUMBER, ' ||
                        'PROGRAM_ID NUMBER, ' ||
                        'PROGRAM_UPDATE_DATE DATE, ' ||
                        'TXN_DATE DATE, ' ||
                        'SECURITY_GROUP_ID NUMBER, ' ||
                        'OBJECT_VERSION_NUMBER NUMBER) ';
    BEGIN
      EXECUTE IMMEDIATE l_alter_tbl_stmt;
    EXCEPTION
      when others then
        retcode := 2;
        errbuf  := 'Error while trying to alter ' || l_batch_trans_table_name || ' : SQLCODE : ' || SQLCODE ||
                   ' : SQLERRM : ' || SQLERRM;
      RAISE;
    END;

    BEGIN
      OPEN CUR_BATCH_TOTAL(l_trans_usg_pgm_sql_id);
      LOOP
        FETCH CUR_BATCH_TOTAL INTO l_batch_total_sql_clob;
        EXIT WHEN CUR_BATCH_TOTAL%NOTFOUND;
        DBMS_LOB.OPEN(l_batch_total_sql_clob, DBMS_LOB.LOB_READWRITE);
        DBMS_LOB.WRITEAPPEND(l_batch_total_sql_clob,LENGTH(p_batch_total_sql),p_batch_total_sql);
        DBMS_LOB.CLOSE(l_batch_total_sql_clob);
      END LOOP;
      CLOSE CUR_BATCH_TOTAL;
    EXCEPTION
      when others then
        retcode := 2;
        errbuf  := 'Error while trying to update batch_total_sql' || ' : SQLCODE : ' || SQLCODE ||
                   ' : SQLERRM : ' || SQLERRM;
        RAISE;
    END;
  END IF; /* end IF ((l_batch_enable_flag = 'Y') AND ... */

  /* Create the batch new mode trans table and batch new mode transaction type SQL */
  IF ((l_batch_enable_flag = 'Y') AND (l_batch_nm_trans_table_name IS NOT NULL) AND (p_batch_incr_sql IS NOT NULL)) THEN
    l_drop_tbl_stmt := 'DROP TABLE ' || l_jtf_schema || '.' || l_batch_nm_trans_table_name;
    BEGIN
      execute immediate l_drop_tbl_stmt;
    EXCEPTION
      when others then
        null;
    END;


    l_create_tbl_stmt := 'CREATE TABLE ' || l_jtf_schema || '.' || l_batch_nm_trans_table_name || ' AS (SELECT * FROM ( ' ||
                    p_batch_total_sql || ' ) WHERE 1 = 2 ) ';
    BEGIN
      EXECUTE IMMEDIATE l_create_tbl_stmt;
    EXCEPTION
      when others then
        retcode := 2;
        errbuf  := 'Error while trying to create ' || l_batch_nm_trans_table_name || ' : SQLCODE : ' || SQLCODE ||
                   ' : SQLERRM : ' || SQLERRM;
        RAISE;
    END;


    l_alter_tbl_stmt := 'ALTER TABLE ' || l_jtf_schema || '.' || l_batch_nm_trans_table_name || ' ADD ( ' ||
                        'LAST_UPDATE_DATE DATE, ' ||
                        'LAST_UPDATED_BY NUMBER, ' ||
                        'CREATION_DATE DATE, ' ||
                        'CREATED_BY NUMBER, ' ||
                        'LAST_UPDATE_LOGIN NUMBER, ' ||
                        'REQUEST_ID NUMBER, ' ||
                        'PROGRAM_APPLICATION_ID NUMBER, ' ||
                        'PROGRAM_ID NUMBER, ' ||
                        'PROGRAM_UPDATE_DATE DATE, ' ||
                        'TXN_DATE DATE, ' ||
                        'SECURITY_GROUP_ID NUMBER, ' ||
                        'OBJECT_VERSION_NUMBER NUMBER, ' ||
                        'WORKER_ID NUMBER) ';
    BEGIN
      EXECUTE IMMEDIATE l_alter_tbl_stmt;
    EXCEPTION
      when others then
        retcode := 2;
        errbuf  := 'Error while trying to alter ' || l_batch_nm_trans_table_name || ' : SQLCODE : ' || SQLCODE ||
                   ' : SQLERRM : ' || SQLERRM;
        RAISE;
    END;

    BEGIN
      OPEN CUR_BATCH_INCR(l_trans_usg_pgm_sql_id);
      LOOP
        FETCH CUR_BATCH_INCR INTO l_batch_incr_sql_clob;
        EXIT WHEN CUR_BATCH_INCR%NOTFOUND;
        DBMS_LOB.OPEN(l_batch_incr_sql_clob, DBMS_LOB.LOB_READWRITE);
        DBMS_LOB.WRITEAPPEND(l_batch_incr_sql_clob,LENGTH(p_batch_incr_sql),p_batch_incr_sql);
        DBMS_LOB.CLOSE(l_batch_incr_sql_clob);
      END LOOP;
      CLOSE CUR_BATCH_INCR;
    EXCEPTION
      when others then
        retcode := 2;
        errbuf  := 'Error while trying to update batch_incr_sql' || ' : SQLCODE : ' || SQLCODE ||
                   ' : SQLERRM : ' || SQLERRM;
        RAISE;
    END;
  END IF; /* end IF ((l_batch_enable_flag = 'Y') AND ... */

  /* Create the batch dea trans table and batch dea transaction type SQL */
  IF ((l_batch_enable_flag = 'Y') AND (l_batch_dea_trans_table_name IS NOT NULL) AND (p_batch_dea_sql IS NOT NULL)) THEN
    l_drop_tbl_stmt := 'DROP TABLE ' || l_jtf_schema || '.' || l_batch_dea_trans_table_name;
    BEGIN
      execute immediate l_drop_tbl_stmt;
    EXCEPTION
      when others then
        null;
    END;


    l_create_tbl_stmt := 'CREATE TABLE ' || l_jtf_schema || '.' || l_batch_dea_trans_table_name ||
                           ' PARTITION BY RANGE (worker_id) ' ||
                             '(PARTITION WORKER1 VALUES LESS THAN (1), ' ||
                              'PARTITION WORKER2 VALUES LESS THAN (2), ' ||
                              'PARTITION WORKER3 VALUES LESS THAN (3), ' ||
                              'PARTITION WORKER4 VALUES LESS THAN (4), ' ||
                              'PARTITION WORKER5 VALUES LESS THAN (5), ' ||
                              'PARTITION WORKER6 VALUES LESS THAN (6), ' ||
                              'PARTITION WORKER7 VALUES LESS THAN (7), ' ||
                              'PARTITION WORKER8 VALUES LESS THAN (8), ' ||
                              'PARTITION WORKER9 VALUES LESS THAN (9), ' ||
                              'PARTITION WORKER10 VALUES LESS THAN (10), ' ||
                              'PARTITION WORKER11 VALUES LESS THAN (11) ' ||
                             ') ' ||
                         ' AS (SELECT A.*, 1 WORKER_ID FROM ( ' || p_batch_dea_sql || ' ) A WHERE 1 = 2 )';
    BEGIN
      EXECUTE IMMEDIATE l_create_tbl_stmt;
    EXCEPTION
      when others then
        retcode := 2;
        errbuf  := 'Error while trying to create ' || l_batch_dea_trans_table_name || ' : SQLCODE : ' || SQLCODE ||
                   ' : SQLERRM : ' || SQLERRM;
        RAISE;
    END;

    l_alter_tbl_stmt := 'ALTER TABLE ' || l_jtf_schema || '.' || l_batch_dea_trans_table_name || ' ADD ( ' ||
                        'LAST_UPDATE_DATE DATE, ' ||
                        'LAST_UPDATED_BY NUMBER, ' ||
                        'CREATION_DATE DATE, ' ||
                        'CREATED_BY NUMBER, ' ||
                        'LAST_UPDATE_LOGIN NUMBER, ' ||
                        'REQUEST_ID NUMBER, ' ||
                        'PROGRAM_APPLICATION_ID NUMBER, ' ||
                        'PROGRAM_ID NUMBER, ' ||
                        'PROGRAM_UPDATE_DATE DATE, ' ||
                        'SECURITY_GROUP_ID NUMBER, ' ||
                        'OBJECT_VERSION_NUMBER NUMBER) ';
    BEGIN
      EXECUTE IMMEDIATE l_alter_tbl_stmt;
    EXCEPTION
      when others then
        retcode := 2;
        errbuf  := 'Error while trying to alter ' || l_batch_dea_trans_table_name || ' : SQLCODE : ' || SQLCODE ||
                   ' : SQLERRM : ' || SQLERRM;
        RAISE;
    END;

    BEGIN
      OPEN CUR_BATCH_DEA(l_trans_usg_pgm_sql_id);
      LOOP
        FETCH CUR_BATCH_DEA INTO l_batch_dea_sql_clob;
        EXIT WHEN CUR_BATCH_DEA%NOTFOUND;
        DBMS_LOB.OPEN(l_batch_dea_sql_clob, DBMS_LOB.LOB_READWRITE);
        DBMS_LOB.WRITEAPPEND(l_batch_dea_sql_clob,LENGTH(p_batch_dea_sql),p_batch_dea_sql);
        DBMS_LOB.CLOSE(l_batch_dea_sql_clob);
      END LOOP;
      CLOSE CUR_BATCH_DEA;
    EXCEPTION
      when others then
        retcode := 2;
        errbuf  := 'Error while trying to update batch_dea_sql' || ' : SQLCODE : ' || SQLCODE ||
                   ' : SQLERRM : ' || SQLERRM;
        RAISE;
    END;
  END IF; /* end IF ((l_batch_enable_flag = 'Y') AND ... */

  IF ((l_batch_enable_flag = 'Y') AND (p_incr_reassign_sql IS NOT NULL)) THEN
    BEGIN
      OPEN CUR_INCR_REASSIGN(l_trans_usg_pgm_sql_id);
      LOOP
        FETCH CUR_INCR_REASSIGN INTO l_incr_reassign_sql_clob;
        EXIT WHEN CUR_INCR_REASSIGN%NOTFOUND;
        DBMS_LOB.OPEN(l_incr_reassign_sql_clob, DBMS_LOB.LOB_READWRITE);
        DBMS_LOB.WRITEAPPEND(l_incr_reassign_sql_clob,LENGTH(p_incr_reassign_sql),p_incr_reassign_sql);
        DBMS_LOB.CLOSE(l_incr_reassign_sql_clob);
      END LOOP;
      CLOSE CUR_INCR_REASSIGN;
    EXCEPTION
      when others then
        retcode := 2;
        errbuf  := 'Error while trying to update incr_reassign_sql' || ' : SQLCODE : ' || SQLCODE ||
                   ' : SQLERRM : ' || SQLERRM;
        RAISE;
    END;
  END IF; /* end IF ((l_batch_enable_flag = 'Y') AND ... */

  retcode := 0;
  errbuf  := null;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    NULL;

  WHEN OTHERS THEN
    if (retcode = 0) then
      retcode := 2;
    end if;
    if (errbuf is null) then
      errbuf := 'SQLCODE : ' || SQLCODE || ' : SQLERRM : ' || SQLERRM;
    end if;
End Insert_Row;

END JTY_TRANS_USG_PGM_SQL_PKG;

/
