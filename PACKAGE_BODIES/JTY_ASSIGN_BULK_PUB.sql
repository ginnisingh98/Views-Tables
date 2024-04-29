--------------------------------------------------------
--  DDL for Package Body JTY_ASSIGN_BULK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_ASSIGN_BULK_PUB" AS
/* $Header: jtfyaeab.pls 120.16.12010000.20 2010/01/15 06:12:24 ppillai ship $ */
---------------------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_ASSIGN_BULK_PUB
--    ---------------------------------------------------
--    PURPOSE
--      This package is a public API for getting winning territories
--      or territory resourcesi in bulk mode.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      06/13/2005  ACHANDA     CREATED
--

--    End of Comments

-- ***************************************************
--    GLOBAL VARIABLES and RECORD TYPE DEFINITIONS
-- ***************************************************

   G_PKG_NAME      CONSTANT VARCHAR2(30):='JTY_ASSIGN_BULK_PUB';

   G_NEW_LINE        VARCHAR2(02) := fnd_global.local_chr(10);
   G_APPL_ID         NUMBER       := FND_GLOBAL.Prog_Appl_Id;
   G_LOGIN_ID        NUMBER       := FND_GLOBAL.Conc_Login_Id;
   G_PROGRAM_ID      NUMBER       := FND_GLOBAL.Conc_Program_Id;
   G_USER_ID         NUMBER       := FND_GLOBAL.User_Id;
   G_REQUEST_ID      NUMBER       := FND_GLOBAL.Conc_Request_Id;
   G_APP_SHORT_NAME  VARCHAR2(15) := FND_GLOBAL.Application_Short_Name;

   NO_TAE_DATA_FOUND		EXCEPTION;

PROCEDURE jty_log(p_log_level IN NUMBER
			 ,p_module    IN VARCHAR2
			 ,p_message   IN VARCHAR2)
IS
pragma autonomous_transaction;
BEGIN
IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FND_LOG.string(p_log_level, p_module, p_message);
 commit;
 END IF;
END;

--    ***************************************************
--    API Body Definitions
--    ***************************************************

-- ***************************************************
--    API Specifications
-- ***************************************************
--    api name       : insert_nm_trans_data
--    type           : private.
--    function       : inserts the transaction objects into NM_TRANS table
--    pre-reqs       :
--    notes:
--
PROCEDURE Insert_NM_Trans_Data
(   p_source_id             IN          NUMBER,
    p_trans_id              IN          NUMBER,
    p_program_name          IN          VARCHAR2,
    p_request_id            IN          NUMBER,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  VARCHAR2
)
AS
  l_trans_target      VARCHAR2(30);
  l_insert_stmt       VARCHAR2(3000);
  l_select_stmt       VARCHAR2(3000);
  first_time          BOOLEAN;
  l_owner             VARCHAR2(30);
  l_indent            VARCHAR2(30);
  l_status            VARCHAR2(30);
  l_industry          VARCHAR2(30);
  l_seeded_sql        VARCHAR2(32767);
  l_final_sql         VARCHAR2(32767);
  l_sysdate           DATE;


  CURSOR c1(p_table_name IN VARCHAR2, p_owner IN VARCHAR2) is
  SELECT column_name
  FROM  all_tab_columns
  WHERE table_name = p_table_name
  AND   owner      = p_owner
  AND   column_name not in ('SECURITY_GROUP_ID', 'OBJECT_VERSION_NUMBER', 'WORKER_ID', 'LAST_UPDATE_DATE',
                            'LAST_UPDATED_BY', 'CREATION_DATE', 'CREATED_BY', 'LAST_UPDATE_LOGIN', 'REQUEST_ID',
                            'PROGRAM_APPLICATION_ID', 'PROGRAM_ID', 'PROGRAM_UPDATE_DATE', 'TXN_DATE');

  L_SCHEMA_NOTFOUND     EXCEPTION;
  L_SEED_DATA_NOTFOUND  EXCEPTION;

BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_nm_trans_data.begin',
                   'Start of the procedure JTY_ASSIGN_BULK_PUB.insert_nm_trans_data ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_sysdate       := SYSDATE;

  /* Get the NM_TRANS table name */
  BEGIN
    SELECT  tup.batch_nm_trans_table_name
    INTO    l_trans_target
    FROM    jty_trans_usg_pgm_details tup
    WHERE   tup.source_id     = p_source_id
    AND     tup.trans_type_id = p_trans_id
    AND     tup.program_name  = p_program_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_msg_data := 'No row in jty_trans_usg_pgm_details corresponding to usage : ' || p_source_id || ' transaction : ' || p_trans_id ||
                    ' program name : ' || p_program_name;
      RAISE;
  END;

  BEGIN
    SELECT  incr_reassign_sql
    INTO    l_seeded_sql
    FROM    jty_trans_usg_pgm_sql tus
    WHERE   tus.source_id     = p_source_id
    AND     tus.trans_type_id = p_trans_id
    AND     tus.program_name  = p_program_name
    AND     tus.enabled_flag = 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_msg_data := 'No active row in jty_trans_usg_pgm_sql corresponding to usage : ' || p_source_id || ' transaction : ' || p_trans_id ||
                    ' program name : ' || p_program_name;
      RAISE;
  END;

  IF (l_trans_target IS NULL) THEN
    x_msg_data := 'No trans table name in jty_trans_usg_pgm_details corresponding to usage : ' || p_source_id || ' transaction : ' ||
                   p_trans_id || ' program name : ' || p_program_name;
    RAISE L_SEED_DATA_NOTFOUND;
  END IF;

  IF (l_seeded_sql IS NULL) THEN
    x_msg_data := 'No active transaction sql in jty_trans_usg_pgm_sql corresponding to usage : ' || p_source_id || ' transaction : ' ||
                   p_trans_id || ' program name : ' || p_program_name;
    RAISE L_SEED_DATA_NOTFOUND;
  END IF;

  /* Initialize local variables */
  first_time := TRUE;
  l_indent   := '  ';

  /* Get the schema name corresponding to JTF application */
  IF (FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_owner)) THEN
    NULL;
  END IF;

  IF (l_owner IS NULL) THEN
    RAISE L_SCHEMA_NOTFOUND;
  END IF;

  /* Form the insert statement to insert transaction objects into TRANS table */
  l_insert_stmt := 'INSERT /*+ APPEND PARALLEL(' || l_trans_target || ') */ INTO ' || l_trans_target || '(';
  l_select_stmt := '(SELECT ';

  FOR column_names in c1(l_trans_target, l_owner) LOOP
    IF (first_time) THEN
      l_insert_stmt := l_insert_stmt || g_new_line || l_indent || column_names.column_name;
      l_select_stmt := l_select_stmt || g_new_line || l_indent || column_names.column_name;
      first_time := FALSE;
    ELSE
      l_insert_stmt := l_insert_stmt || g_new_line || l_indent || ',' || column_names.column_name;
      l_select_stmt := l_select_stmt || g_new_line || l_indent || ',' || column_names.column_name;
    END IF;
  END LOOP;

  /* Standard WHO columns */
  l_insert_stmt := l_insert_stmt || g_new_line || l_indent || ',LAST_UPDATE_DATE ' ||
                     g_new_line || l_indent || ',LAST_UPDATED_BY ' ||
                     g_new_line || l_indent || ',CREATION_DATE ' ||
                     g_new_line || l_indent || ',CREATED_BY ' ||
                     g_new_line || l_indent || ',LAST_UPDATE_LOGIN ' ||
                     g_new_line || l_indent || ',REQUEST_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_APPLICATION_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_UPDATE_DATE ' ||
                     g_new_line || l_indent || ',WORKER_ID ' ||
                     g_new_line || l_indent || ',TXN_DATE ' ||
                     g_new_line || ')';

  l_select_stmt := l_select_stmt || g_new_line || l_indent || ',''' || l_sysdate || '''' ||
                     g_new_line || l_indent || ',''' || g_user_id || '''' ||
                     g_new_line || l_indent || ',''' || l_sysdate || '''' ||
                     g_new_line || l_indent || ',''' || g_user_id || '''' ||
                     g_new_line || l_indent || ',''' || g_login_id || '''' ||
                     g_new_line || l_indent || ',''' || p_request_id || '''' ||
                     g_new_line || l_indent || ',''' || g_appl_id || '''' ||
                     g_new_line || l_indent || ',''' || g_program_id || '''' ||
                     g_new_line || l_indent || ',''' || l_sysdate || '''' ||
                     g_new_line || l_indent || ',1' ||
                     g_new_line || l_indent || ',''' || l_sysdate || '''';

  l_final_sql := l_insert_stmt || l_select_stmt ||
                     g_new_line || 'FROM ( ' ||
                     g_new_line || l_seeded_sql ||
                     g_new_line || ' ) ) ';

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_nm_trans_data.final_sql',
                   substr('Insert satement : ' || l_final_sql, 1, 4000));

  /* commit is executed to execute parallel dml in single transaction */
  commit;
  EXECUTE IMMEDIATE 'alter session enable parallel dml';
  EXECUTE IMMEDIATE l_final_sql;
  commit;
  EXECUTE IMMEDIATE 'alter session disable parallel dml';

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_nm_trans_data.num_rows',
                   'Number of rows inserted : ' || SQL%ROWCOUNT);

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_nm_trans_data.end',
                   'End of the procedure JTY_ASSIGN_BULK_PUB.insert_nm_trans_data ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN L_SEED_DATA_NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RETCODE := 2;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_nm_trans_data.l_seed_data_notfound',
                     x_msg_data);

  WHEN L_SCHEMA_NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RETCODE := 2;
    x_msg_data  := 'JTY_ASSIGN_BULK_PUB.insert_nm_trans_data: SCHEMA NAME NOT FOUND CORRESPONDING TO JTF APPLICATION. ';
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_nm_trans_data.l_schema_notfound',
                     x_msg_data);

  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RETCODE := 2;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_nm_trans_data.no_data_found',
                     x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_nm_trans_data.other',
                     substr(x_msg_data, 1, 4000));

END Insert_NM_Trans_Data;


-- ***************************************************
--    API Specifications
-- ***************************************************
--    api name       : insert_trans_data
--    type           : private.
--    function       : inserts the transaction objects into TRANS table
--    pre-reqs       :
--    notes:
--
PROCEDURE Insert_Trans_Data
(   p_source_id             IN          NUMBER,
    p_trans_id              IN          NUMBER,
    p_program_name          IN          VARCHAR2,
    p_mode                  IN          VARCHAR2,
    p_where                 IN          VARCHAR2,
    p_no_of_workers         IN          NUMBER,
    p_request_id            IN          NUMBER,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  VARCHAR2,
    p_oic_mode              IN VARCHAR2 DEFAULT 'NOOIC'
)
AS
  l_trans_target      VARCHAR2(30);
  l_insert_stmt       VARCHAR2(3000);
  l_select_stmt       VARCHAR2(3000);
  first_time          BOOLEAN;
  l_owner             VARCHAR2(30);
  l_indent            VARCHAR2(30);
  l_status            VARCHAR2(30);
  l_industry          VARCHAR2(30);
  l_seeded_sql        VARCHAR2(32767);
  l_final_sql         VARCHAR2(32767);
  l_plsql_block       VARCHAR2(32767);
  l_sysdate           DATE;


  CURSOR c1(p_table_name IN VARCHAR2, p_owner IN VARCHAR2) is
  SELECT column_name
  FROM  all_tab_columns
  WHERE table_name = p_table_name
  AND   owner      = p_owner
  AND   column_name not in ('SECURITY_GROUP_ID', 'OBJECT_VERSION_NUMBER', 'WORKER_ID', 'LAST_UPDATE_DATE',
                            'LAST_UPDATED_BY', 'CREATION_DATE', 'CREATED_BY', 'LAST_UPDATE_LOGIN', 'REQUEST_ID',
                            'PROGRAM_APPLICATION_ID', 'PROGRAM_ID', 'PROGRAM_UPDATE_DATE', 'TXN_DATE');

  L_SCHEMA_NOTFOUND     EXCEPTION;
  L_SEED_DATA_NOTFOUND  EXCEPTION;
  L_INVALID_WORKERS     EXCEPTION;

BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_trans_data.begin',
                   'Start of the procedure JTY_ASSIGN_BULK_PUB.insert_trans_data ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_sysdate       := SYSDATE;

  /* Number of workers is restricted from 1 to 10 */
  IF (p_oic_mode =  'NOOIC') THEN
    IF ( (p_no_of_workers > 10 or p_no_of_workers < 1)) THEN
      RAISE L_INVALID_WORKERS;
    END IF;
  ELSIF (p_oic_mode =  'INSERT')  THEN
    IF ( (p_no_of_workers < 1)) THEN
      RAISE L_INVALID_WORKERS;
    END IF;
  END IF;

  /* Get the TRANS table name and active transaction type batch SQL */
  BEGIN
    SELECT  decode(p_mode, 'TOTAL', tup.batch_trans_table_name
                         , 'INCREMENTAL', tup.batch_nm_trans_table_name
                         , 'DATE EFFECTIVE', tup.batch_dea_trans_table_name)
    INTO    l_trans_target
    FROM    jty_trans_usg_pgm_details tup
    WHERE   tup.source_id     = p_source_id
    AND     tup.trans_type_id = p_trans_id
    AND     tup.program_name  = p_program_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_msg_data := 'No row in jty_trans_usg_pgm_details corresponding to usage : ' || p_source_id || ' transaction : ' || p_trans_id ||
                    ' program name : ' || p_program_name;
      RAISE;
  END;

  BEGIN
    SELECT  decode(p_mode, 'TOTAL', tus.batch_total_sql
                         , 'INCREMENTAL', tus.batch_incr_sql
                         , 'DATE EFFECTIVE',  decode(tus.use_total_for_dea_flag, 'Y', tus.batch_total_sql, tus.batch_dea_sql))
    INTO    l_seeded_sql
    FROM    jty_trans_usg_pgm_sql tus
    WHERE   tus.source_id     = p_source_id
    AND     tus.trans_type_id = p_trans_id
    AND     tus.program_name  = p_program_name
    AND     tus.enabled_flag = 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_msg_data := 'No active row in jty_trans_usg_pgm_sql corresponding to usage : ' || p_source_id || ' transaction : ' || p_trans_id ||
                    ' program name : ' || p_program_name;
      RAISE;
  END;

  IF (l_trans_target IS NULL) THEN
    x_msg_data := 'No trans table name in jty_trans_usg_pgm_details corresponding to usage : ' || p_source_id || ' transaction : ' ||
                   p_trans_id || ' program name : ' || p_program_name;
    RAISE L_SEED_DATA_NOTFOUND;
  END IF;

  IF (l_seeded_sql IS NULL) THEN
    x_msg_data := 'No active transaction sql in jty_trans_usg_pgm_sql corresponding to usage : ' || p_source_id || ' transaction : ' ||
                   p_trans_id || ' program name : ' || p_program_name;
    RAISE L_SEED_DATA_NOTFOUND;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_trans_data.trans_table_name',
                   'TRANS table name : ' || l_trans_target);
/*
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_trans_data.trans_table_name',
                   ' Seeded SQL : ' || substr(l_seeded_sql, 1, 4000));
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_trans_data.trans_table_name',
                   ' Where clause : ' || substr(p_where, 1, 4000));
*/

  /* Initialize local variables */
  first_time := TRUE;
  l_indent   := '  ';

  /* Get the schema name corresponding to JTF application */
  IF (FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_owner)) THEN
    NULL;
  END IF;

  IF (l_owner IS NULL) THEN
    RAISE L_SCHEMA_NOTFOUND;
  END IF;

  /* Form the insert statement to insert transaction objects into TRANS table */
  IF p_oic_mode = 'INSERT'
  THEN
    l_insert_stmt := 'INSERT INTO ' || l_trans_target || '(';
    l_select_stmt := '(SELECT  ';
  ELSE
    l_insert_stmt := 'INSERT /*+ APPEND PARALLEL(' || l_trans_target || ') */ INTO ' || l_trans_target || '(';
    l_select_stmt := '(SELECT  /*+ PARALLEL */';
  END IF;


  FOR column_names in c1(l_trans_target, l_owner) LOOP
    IF (first_time) THEN
      l_insert_stmt := l_insert_stmt || g_new_line || l_indent || column_names.column_name;
      l_select_stmt := l_select_stmt || g_new_line || l_indent || column_names.column_name;
      first_time := FALSE;
    ELSE
      l_insert_stmt := l_insert_stmt || g_new_line || l_indent || ',' || column_names.column_name;
      l_select_stmt := l_select_stmt || g_new_line || l_indent || ',' || column_names.column_name;
    END IF;
  END LOOP;

  /* Standard WHO columns */
  l_insert_stmt := l_insert_stmt || g_new_line || l_indent || ',LAST_UPDATE_DATE ' ||
                     g_new_line || l_indent || ',LAST_UPDATED_BY ' ||
                     g_new_line || l_indent || ',CREATION_DATE ' ||
                     g_new_line || l_indent || ',CREATED_BY ' ||
                     g_new_line || l_indent || ',LAST_UPDATE_LOGIN ' ||
                     g_new_line || l_indent || ',REQUEST_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_APPLICATION_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_UPDATE_DATE ' ||
                     g_new_line || l_indent || ',WORKER_ID ' ||
                     g_new_line || l_indent || ',TXN_DATE ' ||
                     g_new_line || ')';

  l_select_stmt := l_select_stmt || g_new_line || l_indent || ',''' || l_sysdate || '''' ||
                     g_new_line || l_indent || ',''' || g_user_id || '''' ||
                     g_new_line || l_indent || ',''' || l_sysdate || '''' ||
                     g_new_line || l_indent || ',''' || g_user_id || '''' ||
                     g_new_line || l_indent || ',''' || g_login_id || '''' ||
                     g_new_line || l_indent || ',''' || p_request_id || '''' ||
                     g_new_line || l_indent || ',''' || g_appl_id || '''' ||
                     g_new_line || l_indent || ',''' || g_program_id || '''' ||
                     g_new_line || l_indent || ',''' || l_sysdate || '''';

  IF (p_mode = 'INCREMENTAL') THEN
    l_select_stmt := l_select_stmt || g_new_line || l_indent || ',1';
  ELSE
    IF p_oic_mode = 'NOOIC'
    THEN
       l_select_stmt := l_select_stmt || g_new_line || l_indent || ',mod(trans_object_id ,' || p_no_of_workers || ') + 1';
    ELSIF p_oic_mode = 'INSERT'
    THEN
       l_select_stmt := l_select_stmt || g_new_line || l_indent || ',mod(floor(trans_object_id/1000) ,' || p_no_of_workers || ') + 1';
    END IF;
  END IF;

  IF (p_mode = 'DATE EFFECTIVE') THEN
    l_select_stmt := l_select_stmt || g_new_line || l_indent || ',txn_date';
  ELSE
    l_select_stmt := l_select_stmt || g_new_line || l_indent || ',''' || l_sysdate || '''';
  END IF;

  l_final_sql := l_insert_stmt || l_select_stmt ||
                     g_new_line || 'FROM ( ' ||
                     g_new_line || l_seeded_sql ||
                     g_new_line || ' ) ';

  /* Append the where clause , passed by the customer, to the seeded SQL */
  IF (p_where IS NOT NULL) THEN
    l_final_sql  := l_final_sql || ' ' || p_where;
  END IF;
  l_final_sql  := l_final_sql || ' ) ';

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_trans_data.final_sql',
                   substr('Insert satement : ' || l_final_sql, 1, 4000));

  /* commit is executed to execute parallel dml in single transaction */
  commit;
  EXECUTE IMMEDIATE 'alter session enable parallel dml';
  /* Insert all the transaction objects into the TRANS table */
  EXECUTE IMMEDIATE l_final_sql;
  commit;
  EXECUTE IMMEDIATE 'alter session disable parallel dml';

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_trans_data.num_rows',
                   'Number of rows inserted : ' || SQL%ROWCOUNT);

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_trans_data.end',
                   'End of the procedure JTY_ASSIGN_BULK_PUB.insert_trans_data ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN L_INVALID_WORKERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RETCODE := 2;
    x_msg_data  := 'JTY_ASSIGN_BULK_PUB.insert_trans_data: Invalid number of workers : Valid range from 1 - 10';
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_trans_data.l_invalid_workers',
                     x_msg_data);

  WHEN L_SEED_DATA_NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RETCODE := 2;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_trans_data.l_seed_data_notfound',
                     x_msg_data);

  WHEN L_SCHEMA_NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RETCODE := 2;
    x_msg_data  := 'JTY_ASSIGN_BULK_PUB.insert_trans_data: SCHEMA NAME NOT FOUND CORRESPONDING TO JTF APPLICATION. ';
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_trans_data.l_schema_notfound',
                     x_msg_data);

  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RETCODE := 2;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_trans_data.no_data_found',
                     x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.insert_trans_data.other',
                     substr(x_msg_data, 1, 4000));

END Insert_Trans_Data;


-- ***************************************************
--    API Specifications
-- ***************************************************
--    api name       : Clear_trans_data
--    type           : public.
--    function       : Truncate Trans Table, and Drop_TAE_TRANS_Indexes
--    pre-reqs       :
--    notes:
--
PROCEDURE Clear_Trans_Data
(   p_source_id             IN          NUMBER,
    p_trans_id              IN          NUMBER,
    p_program_name          IN          VARCHAR2,
    p_mode                  IN          VARCHAR2,
    p_request_id            IN          NUMBER,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    ERRBUF                  OUT NOCOPY  VARCHAR2,
    RETCODE                 OUT NOCOPY  VARCHAR2
)
AS
  l_trans_target               VARCHAR2(30);
  l_match_target               VARCHAR2(30);
  l_umatch_target              VARCHAR2(30);
  l_winner_target              VARCHAR2(30);
  l_uwinner_target             VARCHAR2(30);
  l_L1_target                  VARCHAR2(30);
  l_L2_target                  VARCHAR2(30);
  l_L3_target                  VARCHAR2(30);
  l_L4_target                  VARCHAR2(30);
  l_L5_target                  VARCHAR2(30);
  l_WT_target                  VARCHAR2(30);

  l_dummy  NUMBER;
BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.begin',
                   'Start of the procedure JTY_ASSIGN_BULK_PUB.clear_trans_data ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  /* Get the temp tables names corresponding to the usage, transaction type and program name */
  SELECT
     decode(p_mode, 'TOTAL', tup.batch_trans_table_name
                  , 'INCREMENTAL', tup.batch_nm_trans_table_name
                  , 'DATE EFFECTIVE', tup.batch_dea_trans_table_name)
    ,tup.batch_match_table_name
    ,tup.batch_unique_match_table_name
    ,tup.batch_winner_table_name
    ,tup.batch_unique_winner_table_name
    ,tup.batch_l1_winner_table_name
    ,tup.batch_l2_winner_table_name
    ,tup.batch_l3_winner_table_name
    ,tup.batch_l4_winner_table_name
    ,tup.batch_l5_winner_table_name
    ,tup.batch_wt_winner_table_name
  INTO
     l_trans_target
    ,l_match_target
    ,l_umatch_target
    ,l_winner_target
    ,l_uwinner_target
    ,l_L1_target
    ,l_L2_target
    ,l_L3_target
    ,l_L4_target
    ,l_L5_target
    ,l_WT_target
  FROM
    jty_trans_usg_pgm_details tup
  WHERE tup.source_id     = p_source_id
  AND   tup.trans_type_id = p_trans_id
  AND   tup.program_name  = p_program_name;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.temp_table_names',
                   'TRANS table name : ' || l_trans_target || ' MATCH table name : ' || l_match_target ||
                   ' WINNER table name : ' || l_winner_target || ' L1 table name : ' || l_L1_target ||
                   ' L2 table name : ' || l_L2_target || ' L3 table name : ' || l_L3_target ||
                   ' L4 table name : ' || l_L4_target || ' L5 table name : ' || l_L5_target ||
                   ' WT table name : ' || l_WT_target);

  /* Truncate and drop indexes on the TRANS table */
  IF (l_trans_target IS NOT NULL) THEN

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.trans_clear',
                     'Deleting data and dropping indexes from ' || l_trans_target);

    /* Drop the indexes on the TRANS table */
    JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
             p_table_name    => l_trans_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' || l_trans_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.trans_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    /* Truncate the TRANS table */
    JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
             p_table_name    => l_trans_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' || l_trans_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.trans_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

  END IF; /* end  IF (l_trans_target IS NOT NULL) */

  /* Truncate and drop indexes on the MATCH table */
  IF (l_match_target IS NOT NULL) THEN

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.match_clear',
                     'Deleting data and dropping indexes from ' || l_match_target);

    /* Drop the indexes on the MATCH table */
    JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
             p_table_name    => l_match_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' || l_match_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.match_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    /* Truncate the MATCH table */
    JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
             p_table_name    => l_match_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' || l_match_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.match_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

  END IF; /* end (l_match_target IS NOT NULL) */

  /* Truncate and drop indexes on the UMATCH table */
  IF (l_umatch_target IS NOT NULL) THEN

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.umatch_clear',
                     'Deleting data and dropping indexes from ' || l_umatch_target);

    /* Drop the indexes on the UMATCH table */
    JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
             p_table_name    => l_umatch_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' || l_umatch_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.umatch_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    /* Truncate the UMATCH table */
    JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
             p_table_name    => l_umatch_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' || l_umatch_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.umatch_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

  END IF; /* end (l_umatch_target IS NOT NULL) */

  /* Truncate and drop indexes on the WINNER table */
  IF (l_winner_target IS NOT NULL) THEN

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.winner_clear',
                     'Deleting data and dropping indexes from ' || l_winner_target);

    /* Drop the indexes on the WINNER table */
    JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
             p_table_name    => l_winner_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' || l_winner_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.winner_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    /* Truncate the WINNER table */
    JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
             p_table_name    => l_winner_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' || l_winner_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.winner_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

  END IF; /* end (l_winner_target IS NOT NULL) */

  /* Truncate and drop indexes on the UWINNER table */
  IF (l_uwinner_target IS NOT NULL) THEN

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.uwinner_clear',
                     'Deleting data and dropping indexes from ' || l_uwinner_target);

    /* Drop the indexes on the UWINNER table */
    JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
             p_table_name    => l_uwinner_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' || l_uwinner_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.uwinner_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    /* Truncate the UWINNER table */
    JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
             p_table_name    => l_uwinner_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' || l_uwinner_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.uwinner_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

  END IF; /* end (l_uwinner_target IS NOT NULL) */

  /* Truncate and drop indexes on the L1 table */
  IF (l_l1_target IS NOT NULL) THEN

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l1_clear',
                     'Deleting data and dropping indexes from ' || l_l1_target);

    /* Drop the indexes on the L1 table */
    JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
             p_table_name    => l_l1_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' || l_l1_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l1_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    /* Truncate the L1 table */
    JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
             p_table_name    => l_l1_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' || l_l1_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l1_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

  END IF; /* end (l_l1_target IS NOT NULL) */

  /* Truncate and drop indexes on the L2 table */
  IF (l_l2_target IS NOT NULL) THEN

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l2_clear',
                     'Deleting data and dropping indexes from ' || l_l2_target);

    /* Drop the indexes on the L2 table */
    JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
             p_table_name    => l_l2_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' || l_l2_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l2_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    /* Truncate the L2 table */
    JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
             p_table_name    => l_l2_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' || l_l2_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l2_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

  END IF; /* end (l_l2_target IS NOT NULL) */

  /* Truncate and drop indexes on the L3 table */
  IF (l_l3_target IS NOT NULL) THEN

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l3_clear',
                     'Deleting data and dropping indexes from ' || l_l3_target);

    /* Drop the indexes on the L3 table */
    JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
             p_table_name    => l_l3_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' || l_l3_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l3_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    /* Truncate the L3 table */
    JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
             p_table_name    => l_l3_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' || l_l3_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l3_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

  END IF; /* end (l_l3_target IS NOT NULL) */

  /* Truncate and drop indexes on the L4 table */
  IF (l_l4_target IS NOT NULL) THEN

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l4_clear',
                     'Deleting data and dropping indexes from ' || l_l4_target);

    /* Drop the indexes on the L4 table */
    JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
             p_table_name    => l_l4_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' || l_l4_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l4_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    /* Truncate the L4 table */
    JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
             p_table_name    => l_l4_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' || l_l4_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l4_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

  END IF; /* end (l_l4_target IS NOT NULL) */

  /* Truncate and drop indexes on the L5 table */
  IF (l_l5_target IS NOT NULL) THEN

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l5_clear',
                     'Deleting data and dropping indexes from ' || l_l5_target);

    /* Drop the indexes on the L5 table */
    JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
             p_table_name    => l_l5_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' || l_l5_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l5_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    /* Truncate the L5 table */
    JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
             p_table_name    => l_l5_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' || l_l5_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.l5_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

  END IF; /* end (l_l5_target IS NOT NULL) */

  /* Truncate and drop indexes on the WT table */
  IF (l_wt_target IS NOT NULL) THEN

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.wt_clear',
                     'Deleting data and dropping indexes from ' || l_wt_target);

    /* Drop the indexes on the WT table */
    JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES(
             p_table_name    => l_wt_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.DROP_TABLE_INDEXES API has failed for ' || l_wt_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.wt_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    /* Truncate the WT table */
    JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE(
             p_table_name    => l_wt_target
            ,x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
      x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.TRUNCATE_TABLE API has failed for ' || l_wt_target;
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.wt_clear',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

  END IF; /* end (l_wt_target IS NOT NULL) */

  IF (p_mode = 'TOTAL') THEN
    DELETE jty_changed_terrs
    WHERE  source_id = p_source_id
    AND    star_request_id IS NOT NULL;
  ELSIF (p_mode = 'INCREMENTAL') THEN
    DELETE jty_changed_terrs
    WHERE  source_id = p_source_id
    AND    tap_request_id IS NOT NULL
    AND    tap_request_id <> p_request_id;

    BEGIN
      SELECT 1
      INTO   l_dummy
      FROM   jty_changed_terrs
      WHERE  source_id = p_source_id
      AND    tap_request_id = p_request_id
      AND    rownum <= 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        UPDATE jty_changed_terrs
        SET    tap_request_id = p_request_id
        WHERE  source_id = p_source_id
        AND    star_request_id IS NOT NULL;
    END;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.end',
                   'End of the procedure JTY_ASSIGN_BULK_PUB.clear_trans_data ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RETCODE := 2;
    x_msg_count := 1;
    x_msg_data := 'No row in jty_trans_usg_pgm_details corresponding to usage : ' || p_source_id || ' transaction : ' || p_trans_id ||
                  ' program name : ' || p_program_name;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.Clear_Trans_Data.no_data_found',
                     x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
    RETCODE := 2;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.Clear_Trans_Data.g_exc_error',
                     x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.clear_trans_data.other',
                     substr(x_msg_data, 1, 4000));

END Clear_Trans_Data;


-- ***************************************************
--    API Specifications
-- ***************************************************
--    api name       : GET_WINNERS_PARALLEL_SETUP
--    type           : public.
--    function       :
--    pre-reqs       :
--    notes:
--
PROCEDURE get_winners_parallel_setup
( p_source_id             IN          NUMBER,
  p_trans_id              IN          NUMBER,
  p_program_name          IN          VARCHAR2,
  p_mode                  IN          VARCHAR2,
  p_no_of_workers         IN          NUMBER,
  p_percent_analyzed      IN          NUMBER,
  p_request_id            IN          NUMBER,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2,
  ERRBUF                  OUT NOCOPY  VARCHAR2,
  RETCODE                 OUT NOCOPY  VARCHAR2
)
AS

  l_sysdate                    DATE;
  num_of_terr                  NUMBER;
  num_of_trans                 NUMBER;
  d_statement                  VARCHAR2(2000);

  l_trans_target               VARCHAR2(30);
  l_match_target               VARCHAR2(30);
  l_umatch_target              VARCHAR2(30);
  l_winner_target              VARCHAR2(30);
  l_uwinner_target             VARCHAR2(30);
  l_L1_target                  VARCHAR2(30);
  l_L2_target                  VARCHAR2(30);
  l_L3_target                  VARCHAR2(30);
  l_L4_target                  VARCHAR2(30);
  l_L5_target                  VARCHAR2(30);
  l_WT_target                  VARCHAR2(30);

BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.begin',
                   'Start of the procedure JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_sysdate := SYSDATE;

  /* Corresponding to the usage, transaction type and program name */
  /* get all the interface table names                             */
  SELECT
     decode(p_mode, 'TOTAL', tup.batch_trans_table_name,
                    'INCREMENTAL', tup.batch_nm_trans_table_name,
                    'DATE EFFECTIVE', tup.batch_dea_trans_table_name)
    ,tup.batch_match_table_name
    ,tup.batch_unique_match_table_name
    ,tup.batch_winner_table_name
    ,tup.batch_unique_winner_table_name
    ,tup.batch_l1_winner_table_name
    ,tup.batch_l2_winner_table_name
    ,tup.batch_l3_winner_table_name
    ,tup.batch_l4_winner_table_name
    ,tup.batch_l5_winner_table_name
    ,tup.batch_wt_winner_table_name
  INTO
     l_trans_target
    ,l_umatch_target
    ,l_match_target
    ,l_winner_target
    ,l_uwinner_target
    ,l_L1_target
    ,l_L2_target
    ,l_L3_target
    ,l_L4_target
    ,l_L5_target
    ,l_WT_target
  FROM
    jty_trans_usg_pgm_details tup
  WHERE tup.source_id     = p_source_id
  AND   tup.trans_type_id = p_trans_id
  AND   tup.program_name  = p_program_name;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.temp_table_names',
                   'TRANS table name : ' || l_trans_target || ' MATCH table name : ' || l_match_target ||
                   ' WINNER table name : ' || l_winner_target || ' L1 table name : ' || l_L1_target ||
                   ' L2 table name : ' || l_L2_target || ' L3 table name : ' || l_L3_target ||
                   ' L4 table name : ' || l_L4_target || ' L5 table name : ' || l_L5_target ||
                   ' WT table name : ' || l_WT_target);

  /* set NOLOGGING on JTF_TAE_..._MATCHES and JTF_TAE_..._WINNERS tables */
  JTY_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_trans_target);
  JTY_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_match_target);
  JTY_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_umatch_target);
  JTY_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_winner_target);
  JTY_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_uwinner_target);
  JTY_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_L1_target);
  JTY_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_L2_target);
  JTY_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_L3_target);
  JTY_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_L4_target);
  JTY_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_L5_target);
  JTY_TAE_CONTROL_PVT.set_table_nologging(p_table_name => l_WT_target);

  /* Check for territories for this Usage/Transaction Type */
  /* This check is not done in date effective mode as inactive territories */
  /* can also win depending on the date of the transaction object          */
  IF ((p_mode = 'TOTAL') OR (p_mode = 'INCREMENTAL')) THEN
    SELECT COUNT(*)
    INTO   num_of_terr
    FROM   jtf_terr_qtype_usgs_all jtqu
         , jtf_terr_all jt1
         , jtf_qual_type_usgs jqtu
    WHERE jtqu.terr_id = jt1.terr_id
    AND   jqtu.qual_type_usg_id = jtqu.qual_type_usg_id
    AND   jqtu.qual_type_id = p_trans_id
    AND   jqtu.source_id = p_source_id
    AND   jt1.end_date_active >= l_sysdate
    AND   jt1.start_date_active <= l_sysdate
    AND EXISTS (
          SELECT 1
          FROM   jtf_terr_rsc_all jtr,
                 jtf_terr_rsc_access_all jtra,
                 jtf_qual_types_all jqta
          WHERE  jtr.terr_id = jt1.terr_id
          AND    jtr.end_date_active >= l_sysdate
          AND    jtr.start_date_active <= l_sysdate
          AND    jtr.resource_type <> 'RS_ROLE'
          AND    jtr.terr_rsc_id = jtra.terr_rsc_id
          AND    jtra.access_type = jqta.name
          AND    jqta.qual_type_id = p_trans_id
          AND    jtra.trans_access_code <> 'NONE')
    AND NOT EXISTS (
          SELECT jt.terr_id
          FROM   jtf_terr_all jt
          WHERE  jt.end_date_active < l_sysdate
          CONNECT BY PRIOR jt.parent_territory_id = jt.terr_id AND jt.terr_id <> 1
          START WITH jt.terr_id = jt1.terr_id)
    AND jqtu.qual_type_id <> -1001;

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.num_of_terr',
                     'Number of valid territories with resources for this transaction : ' || num_of_terr);

    IF (num_of_terr = 0) THEN
      x_msg_data := 'JTY_ASSIGN_BULK_PUB.GET_WINNERS_PARALLEL_SETUP: There are NO Active Territories with Active ' ||
    							            'Resources existing for this Usage/Transaction combination, so no assignments ' ||
    									    'can take place.';

      RAISE	NO_TAE_DATA_FOUND;
    END IF;
  END IF; /* END IF ((p_mode = 'TOTAL') OR (p_mode = 'INCREMENTAL')) */

  d_statement := ' SELECT COUNT(*) FROM ' || l_trans_target || ' WHERE rownum < 2 ';
  EXECUTE IMMEDIATE d_statement INTO num_of_trans;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.num_of_trans',
                   'Number of valid transaction objects : ' || num_of_trans);

  IF (num_of_trans = 0) THEN
    x_msg_data := 'JTY_ASSIGN_BULK_PUB.GET_WINNERS_PARALLEL_SETUP : There are NO valid Transaction Objects to assign.';
    RAISE	NO_TAE_DATA_FOUND;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.analyze_trans',
                   'Call to JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API begins for : ' || l_trans_target);

  JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
                               p_table_name    => l_trans_target
                             , p_percent       => p_percent_analyzed
                             , x_return_status => x_return_status );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_msg_data := 'JTY_ASSIGN_BULK_PUB.GET_WINNERS_PARALLEL_SETUP: Call to ' ||
                  'JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API has failed for ' || l_trans_target;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.decompose_terr_defns',
                   'Call to JTY_TAE_CONTROL_PVT.Decompose_Terr_Defns API begins for : ' || l_trans_target);

  JTY_TAE_CONTROL_PVT.Decompose_Terr_Defns
            (p_Api_Version_Number     => 1.0,
             p_Init_Msg_List          => FND_API.G_FALSE,
             p_trans_target           => l_trans_target,
             p_classify_terr_comb     => 'N',
             p_process_tx_oin_sel     => 'Y',
             p_generate_indexes       => 'Y',
             p_source_id              => p_source_id,
             p_trans_id               => p_trans_id,
             p_program_name           => p_program_name,
             p_mode                   => p_mode,
             x_Return_Status          => x_return_status,
             x_Msg_Count              => x_msg_count,
             x_Msg_Data               => x_msg_data,
             errbuf                   => ERRBUF,
             retcode                  => RETCODE );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_msg_data := 'JTY_ASSIGN_BULK_PUB.GET_WINNERS_PARALLEL_SETUP: Call to ' ||
                  'JTY_TAE_CONTROL_PVT.Decompose_Terr_Defns API has failed for ' || l_trans_target;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.analyze_matches',
                   'Call to JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API begins for : ' || l_match_target);

  /* Build Index on Matches table */
  JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX
           ( p_table_name    => l_match_target,
             p_trans_id      => p_trans_id,
             p_source_id     => p_source_id,
             p_program_name  => p_program_name,
             p_mode          => p_mode,
             x_Return_Status => x_return_status,
             p_run_mode      => 'MATCH');

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' || l_match_target;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.analyze_winners',
                   'Call to JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API begins for : ' || l_winner_target);

  /* Build Index on Winners table */
  JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX
           ( p_table_name    => l_winner_target,
             p_trans_id      => p_trans_id,
             p_source_id     => p_source_id,
             p_program_name  => p_program_name,
             p_mode          => p_mode,
             x_Return_Status => x_return_status,
             p_run_mode      => 'WINNER');

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' || l_winner_target;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.analyze_l1',
                   'Call to JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API begins for : ' || l_l1_target);

  /* Build Index on L1 table */
  JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX
           ( p_table_name    => l_l1_target,
             p_trans_id      => p_trans_id,
             p_source_id     => p_source_id,
             p_program_name  => p_program_name,
             p_mode          => p_mode,
             x_Return_Status => x_return_status,
             p_run_mode      => 'TEMP_WINNER');

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' || l_l1_target;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.analyze_l2',
                   'Call to JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API begins for : ' || l_l2_target);

  /* Build Index on L2 table */
  JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX
           ( p_table_name    => l_l2_target,
             p_trans_id      => p_trans_id,
             p_source_id     => p_source_id,
             p_program_name  => p_program_name,
             p_mode          => p_mode,
             x_Return_Status => x_return_status,
             p_run_mode      => 'TEMP_WINNER');

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' || l_l2_target;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.analyze_l3',
                   'Call to JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API begins for : ' || l_l3_target);

  /* Build Index on L3 table */
  JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX
           ( p_table_name    => l_l3_target,
             p_trans_id      => p_trans_id,
             p_source_id     => p_source_id,
             p_program_name  => p_program_name,
             p_mode          => p_mode,
             x_Return_Status => x_return_status,
             p_run_mode      => 'TEMP_WINNER');

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' || l_l3_target;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.analyze_l4',
                   'Call to JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API begins for : ' || l_l4_target);

  /* Build Index on L4 table */
  JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX
           ( p_table_name    => l_l4_target,
             p_trans_id      => p_trans_id,
             p_source_id     => p_source_id,
             p_program_name  => p_program_name,
             p_mode          => p_mode,
             x_Return_Status => x_return_status,
             p_run_mode      => 'TEMP_WINNER');

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' || l_l4_target;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.analyze_l5',
                   'Call to JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API begins for : ' || l_l5_target);

  /* Build Index on L5 table */
  JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX
           ( p_table_name    => l_l5_target,
             p_trans_id      => p_trans_id,
             p_source_id     => p_source_id,
             p_program_name  => p_program_name,
             p_mode          => p_mode,
             x_Return_Status => x_return_status,
             p_run_mode      => 'TEMP_WINNER');

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' || l_l5_target;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.analyze_wt',
                   'Call to JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API begins for : ' || l_wt_target);

  /* Build Index on WT table */
  JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX
           ( p_table_name    => l_wt_target,
             p_trans_id      => p_trans_id,
             p_source_id     => p_source_id,
             p_program_name  => p_program_name,
             p_mode          => p_mode,
             x_Return_Status => x_return_status,
             p_run_mode      => 'TEMP_WINNER');

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.CREATE_INDEX API has failed for ' || l_wt_target;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* if mode is incremental, update the worker_id column for the TRANS table */
  IF (p_mode = 'INCREMENTAL') THEN
    d_statement := 'UPDATE ' || l_trans_target ||
                  ' SET worker_id = mod(trans_object_id, :no_of_workers) + 1';
    EXECUTE IMMEDIATE d_statement USING p_no_of_workers;
  END IF;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.end',
                   'End of the procedure JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN NO_TAE_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 1;
    RETCODE := 0;
    ERRBUF  := null;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.no_tae_data_found',
                     x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF  := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.g_exc_error',
                     x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF  := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.g_exc_unexpected_error',
                     x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup.other',
                     substr(x_msg_data, 1, 4000));

END get_winners_parallel_setup;

-- ***************************************************
--    API Specifications
-- ***************************************************
PROCEDURE Process_Level_Winners (
      p_terr_LEVEL_target_tbl  IN          VARCHAR2,
      p_terr_PARENT_LEVEL_tbl  IN          VARCHAR2,
      p_UPPER_LEVEL_FROM_ROOT  IN          NUMBER,
      p_LOWER_LEVEL_FROM_ROOT  IN          NUMBER,
      p_matches_target         IN          VARCHAR2,
      p_source_id              IN          NUMBER,
      p_run_mode               IN          VARCHAR2,
      p_date_effective         IN          BOOLEAN,
      x_return_status          OUT NOCOPY  VARCHAR2,
      p_worker_id              IN          NUMBER
)
AS

  l_denorm_table_name          VARCHAR2(60);
  l_dyn_str                    VARCHAR2(32767);

BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.Process_Level_Winners.start',
                   'Start of the procedure JTY_ASSIGN_BULK_PUB.Process_Level_Winners ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_date_effective) THEN
    l_denorm_table_name := 'JTY_DENORM_DEA_RULES_ALL';
  ELSE
    l_denorm_table_name := 'JTF_TERR_DENORM_RULES_ALL';
  END IF;

  IF ( p_UPPER_LEVEL_FROM_ROOT = 1 AND p_LOWER_LEVEL_FROM_ROOT = 1) THEN

    l_dyn_str := ' ' ||
      'INSERT INTO ' || p_terr_LEVEL_target_tbl ||
      ' ( ' ||
      '    trans_object_id ' ||
      '  , trans_detail_object_id ' ||
      '  , txn_date ' ||
      '  , WIN_TERR_ID ' ||
      '  , UL_TERR_ID ' ||
      '  , LL_TERR_ID ' ||
      '  , LL_NUM_WINNERS ' ||
      '  , WORKER_ID ' ||
      ' ) ' ||
      ' (SELECT ' ||
      '        TL.trans_object_id  ' ||
      '      , TL.trans_detail_object_id  ' ||
      '      , TL.txn_date  ' ||
      '      , TL.CL_WIN_TERR_ID ' ||
      '      , TL.UL_terr_id  ' ||
      '      , TL.LL_terr_id  ' ||
      '      , TL.LL_num_winners  ' ||
      '      , :B_WORKER_ID ' ||
      '  FROM (  ' ||
      '         SELECT ';

    IF (p_run_mode = 'BATCH') THEN
      /* Batch TAE */
      l_dyn_str := l_dyn_str || ' /*+ FULL(M) */ ';
    ELSE
      /* Real-time TAE */
      l_dyn_str := l_dyn_str || ' /*+ LEADING(M) */ ';
    END IF;

    l_dyn_str := l_dyn_str ||
	  '             DISTINCT ' ||
      '             m.trans_object_id  ' ||
      '           , m.trans_detail_object_id  ' ||
      '           , m.txn_date  ' ||
      '           , LL.RELATED_TERR_ID     CL_WIN_TERR_ID ' ||
      '           , UL.related_terr_id     UL_TERR_ID  ' ||
      '           , NVL(UL.num_winners, 1) UL_NUM_WINNERS  ' ||
      '           , LL.related_terr_id     LL_TERR_ID  ' ||
      '           , NVL(LL.num_winners, 1) LL_NUM_WINNERS  ' ||
      '           , DENSE_RANK() OVER ( PARTITION BY  ' ||
      '                                     m.trans_object_id  ' ||
      '                                   , m.trans_detail_object_id  ' ||
      '                                   , UL.related_terr_id  ' ||
      '                                 ORDER BY LL.absolute_rank DESC ' ||
      '                                        , LL.related_terr_id ) AS LL_TERR_RANK ' ||
      '         FROM ' || p_matches_target || ' M  ' ||
      '             , ' || l_denorm_table_name || ' UL  ' ||
      '             , ' || l_denorm_table_name || ' LL  ' ||
      '         WHERE UL.level_from_root = :b1_UPPER_LEVEL +1 ' || /* UPPER level territory */
      '         AND UL.source_id = :b1_source_id ' ||
      '         AND UL.terr_id = M.TERR_ID    ' ||
      '         AND LL.level_from_root = :b1_LOWER_LEVEL +1 ' || /* LOWER level territory */
      '         AND LL.source_id = :b2_source_id ' ||
      '         AND LL.terr_id = M.TERR_ID    ' ||
      '         AND M.worker_id = :B_WORKER_ID ' ||
      '       ) TL  ' ||
      '  WHERE TL.LL_TERR_RANK <= TL.UL_num_winners  ' ||
      ' ) ';

    BEGIN
      EXECUTE IMMEDIATE l_dyn_str USING
                 p_worker_id
               , p_UPPER_LEVEL_FROM_ROOT
               , p_source_id
               , p_LOWER_LEVEL_FROM_ROOT
               , p_source_id
               , p_worker_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

  ELSE

    l_dyn_str := ' ' ||
      'INSERT INTO ' || p_terr_LEVEL_target_tbl ||
      ' ( ' ||
      '    trans_object_id ' ||
      '  , trans_detail_object_id ' ||
      '  , txn_date ' ||
      '  , WIN_TERR_ID ' ||
      '  , UL_TERR_ID ' ||
      '  , LL_TERR_ID ' ||
      '  , LL_NUM_WINNERS ' ||
      '  , WORKER_ID ' ||
      ' ) ' ||
      ' (SELECT  ' ||
      '      TL.trans_object_id  ' ||
      '    , TL.trans_detail_object_id  ' ||
      '    , TL.txn_date  ' ||
      '    , TL.CL_WIN_TERR_ID ' ||
      '    , TL.UL_terr_id  ' ||
      '    , TL.LL_terr_id  ' ||
      '    , TL.LL_num_winners  ' ||
      '    , :B_WORKER_ID ' ||
      '  FROM (                 ' || /* NL */
      '        SELECT  ' ||
      '            CL.trans_object_id  ' ||
      '          , CL.trans_detail_object_id  ' ||
      '          , CL.txn_date  ' ||
      '          , CL.CL_WIN_TERR_ID ' ||
      '          , CL.UL_terr_id  ';

    IF ( p_UPPER_LEVEL_FROM_ROOT = 1 AND p_LOWER_LEVEL_FROM_ROOT = 2) THEN
      l_dyn_str := l_dyn_str || '           , NVL(CL.UL_NUM_WINNERS, 1) UL_NUM_WINNERS ';
    ELSE
      l_dyn_str := l_dyn_str || '           , CL.UL_NUM_WINNERS UL_NUM_WINNERS ';
    END IF;

    l_dyn_str := l_dyn_str ||
      '          , CL.LL_TERR_ID  ' ||
      '          , CL.LL_NUM_WINNERS ' ||
      '          , DENSE_RANK() OVER ( PARTITION BY ' ||
      '                                    CL.trans_object_id ' ||
      '                                  , CL.trans_detail_object_id ' ||
      '                                  , CL.UL_TERR_ID ' ||
      '                               ORDER BY ' ||
      '                                    CL.M_ABS_RANK DESC ' ||
      '                                  , CL.CL_WIN_TERR_ID ) AS LL_TERR_RANK ' ||
      '        FROM (  ' ||
      '              SELECT ';

    IF (p_run_mode = 'BATCH') THEN
      /* Batch TAE */
      l_dyn_str := l_dyn_str || ' /*+ USE_HASH(ML) USE_HASH(LL) USE_HASH(UL) USE_HASH(M) ORDERED */ ';
    ELSE
      /* Real-time TAE */
      l_dyn_str := l_dyn_str || ' /*+ LEADING(M) */ ';
    END IF;

    l_dyn_str := l_dyn_str ||
      '                  m.trans_object_id  ' ||
      '                , m.trans_detail_object_id  ' ||
      '                , m.txn_date  ' ||
      '                , LL.related_terr_id     CL_WIN_TERR_ID ' ||
      '                , UL.related_terr_id     UL_TERR_ID  ' ||
      '                , UL.num_winners         UL_NUM_WINNERS  ' ||
      '                , LL.related_terr_id     LL_TERR_ID  ' ||
      '                , LL.num_winners         LL_NUM_WINNERS  ' ||
      '                , max(m.absolute_rank)     M_ABS_RANK ' ||
      '              FROM  ';

    IF (p_run_mode = 'BATCH') THEN
      l_dyn_str := l_dyn_str ||
            '                    ' || l_denorm_table_name || ' UL  ' ||
            '                  , ' || p_matches_target || ' M  ' ||
            '                  , ' || l_denorm_table_name || ' LL  ' ||
            '                  , ' || p_terr_PARENT_LEVEL_tbl || ' ML ';
    ELSE
      l_dyn_str := l_dyn_str ||
            '                    ' || l_denorm_table_name || ' LL  ' ||
            '                  , ' || p_matches_target || ' M  ' ||
            '                  , ' || p_terr_PARENT_LEVEL_tbl || ' ML  ' ||
            '                  , ' || l_denorm_table_name || ' UL  ';
    END IF;

    l_dyn_str := l_dyn_str ||
      '              WHERE UL.level_from_root = :b1_UPPER_LEVEL +1 ' || /* UPPER level territory */
      '              AND UL.source_id = :b2_source_id ' ||
      '              AND UL.terr_id = M.TERR_ID    ' ||
      '              AND UL.related_terr_id = ML.LL_terr_id  ' ||
      '              AND ( M.trans_detail_object_id = ML.trans_detail_object_id OR ' ||
      '                       M.trans_detail_object_id IS NULL ) ' ||
      '              AND M.trans_object_id = ML.trans_object_id  ' ||
      '              AND M.worker_id = ML.WORKER_ID' ||
      '              AND M.worker_id = :B_WORKER_ID ' ||
      '              AND ML.worker_id = :B_WORKER_ID ' ||
      '              AND LL.level_from_root = :b4_LOWER_LEVEL +1 ' || /* LOWER level territory */
      '              AND LL.source_id = :b5_source_id ' ||
      '              AND ML.LL_NUM_WINNERS IS NOT NULL ' ||
      '              AND LL.NUM_WINNERS IS NOT NULL ' ||
      '              AND LL.terr_id = M.TERR_ID    ' ||
      '              GROUP BY  ' ||
      '                  m.trans_object_id  ' ||
      '                , m.trans_detail_object_id  ' ||
      '                , m.txn_date  ' ||
      '                , LL.related_terr_id     ' ||
      '                , UL.related_terr_id     ' ||
      '                , UL.num_winners         ' ||
      '                , LL.related_terr_id     ' ||
      '                , LL.num_winners         ' ||

      '              UNION ALL ' ||

      '              SELECT ';

    IF (p_run_mode = 'BATCH') THEN
      /* Batch TAE */
      l_dyn_str := l_dyn_str || ' /*+ ORDERED USE_HASH(ML) USE_HASH(M) USE_HASH(UL) USE_HASH(LL) */ ';
    ELSE
      /* Real-time TAE */
      l_dyn_str := l_dyn_str || ' /*+ LEADING(M) */ ';
    END IF;

    l_dyn_str := l_dyn_str ||
	  '                  DISTINCT ' ||
      '                  m.trans_object_id  ' ||
      '                , m.trans_detail_object_id  ' ||
      '                , m.txn_date  ' ||
      '                , m.terr_id              CL_WIN_TERR_ID ' ||
      '                , UL.related_terr_id     UL_TERR_ID  ' ||
      '                , UL.num_winners         UL_NUM_WINNERS  ' ||
      '                , LL.related_terr_id     LL_TERR_ID  ' ||
      '                , LL.num_winners         LL_NUM_WINNERS  ' ||
      '                , m.absolute_rank        M_ABS_RANK ' ||
      '              FROM ';

    IF (p_run_mode = 'BATCH') THEN
      l_dyn_str := l_dyn_str ||
            '                    ' || l_denorm_table_name || ' UL  ' ||
            '                  , ' || p_matches_target || ' M  ' ||
            '                  , ' || l_denorm_table_name || ' LL  ' ||
            '                  , ' || p_terr_PARENT_LEVEL_tbl || ' ML ';
    ELSE
      l_dyn_str := l_dyn_str ||
            '                    ' || l_denorm_table_name || ' LL  ' ||
            '                  , ' || p_matches_target || ' M  ' ||
            '                  , ' || p_terr_PARENT_LEVEL_tbl || ' ML  ' ||
            '                  , ' || l_denorm_table_name || ' UL  ';
    END IF;

    l_dyn_str := l_dyn_str ||
      '              WHERE UL.level_from_root = :b9_UPPER_LEVEL +1 ' || /* UPPER level territory */
      '              AND UL.source_id = :b10_source_id ' ||
      '              AND UL.terr_id = M.TERR_ID    ' ||
      '              AND UL.related_terr_id = ML.LL_terr_id  ' ||
      '              AND ( M.trans_detail_object_id = ML.trans_detail_object_id OR ' ||
      '                    M.trans_detail_object_id IS NULL ) ' ||
      '              AND M.trans_object_id = ML.trans_object_id  ' ||
      '              AND M.worker_id = ML.WORKER_ID' ||
      '              AND M.worker_id = :B_WORKER_ID ' ||
      '              AND ML.worker_id = :B_WORKER_ID ' ||
      '              AND LL.level_from_root = :b12_LOWER_LEVEL +1 ' || /* LOWER level territory */
      '              AND LL.source_id = :b13_source_id ' ||
      '              AND ML.LL_NUM_WINNERS IS NOT NULL ' ||
      '              AND LL.NUM_WINNERS IS NULL     ' ||
      '              AND LL.terr_id = M.TERR_ID    ' ||
      '             ) CL ' ||
      '       ) TL  ' ||
      '  WHERE TL.LL_TERR_RANK <= TL.UL_num_winners  ' ||
      ' ) ';

    BEGIN
      EXECUTE IMMEDIATE l_dyn_str USING
                 p_worker_id
               , p_UPPER_LEVEL_FROM_ROOT
               , p_source_id
               , p_worker_id
               , p_worker_id
               , p_LOWER_LEVEL_FROM_ROOT
               , p_source_id
               , p_UPPER_LEVEL_FROM_ROOT
               , p_source_id
               , p_worker_id
               , p_worker_id
               , p_LOWER_LEVEL_FROM_ROOT
               , p_source_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

  END IF; /* end IF ( p_UPPER_LEVEL_FROM_ROOT = 1 AND p_LOWER_LEVEL_FROM_ROOT = 1) */

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.Process_Level_Winners.num_rows',
                   'Number of rows inserted into ' || p_terr_LEVEL_target_tbl || ' : ' || SQL%ROWCOUNT);

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.Process_Level_Winners.end',
                   'End of the procedure JTY_ASSIGN_BULK_PUB.Process_Level_Winners ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status     := FND_API.G_RET_STS_ERROR;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.Process_Level_Winners.other',
                     'JTY_ASSIGN_BULK_PUB.Process_Level_Winners has failed with FND_API.G_EXC_ERROR exception for ' ||
                        'UPPER LEVEL : ' || p_UPPER_LEVEL_FROM_ROOT || ' LOWER LEVEL : ' || p_LOWER_LEVEL_FROM_ROOT);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.Process_Level_Winners.other',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

END Process_Level_Winners;


-- ***************************************************
--    API Specifications
-- ***************************************************
PROCEDURE Process_Final_Level_Winners (
    p_terr_LEVEL_target_tbl  IN         VARCHAR2,
    p_terr_L5_target_tbl     IN         VARCHAR2,
    p_matches_target         IN         VARCHAR2,
    p_source_id              IN         NUMBER,
    p_run_mode               IN         VARCHAR2,
    p_date_effective         IN         BOOLEAN,
    x_return_status          OUT NOCOPY VARCHAR2,
    p_worker_id              IN         NUMBER
)
AS

  l_dyn_str            VARCHAR2(32767);
  l_denorm_table_name  VARCHAR2(30);

BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.Process_Final_Level_Winners.start',
                   'Start of the procedure JTY_ASSIGN_BULK_PUB.Process_Final_Level_Winners ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_date_effective) THEN
    l_denorm_table_name := 'JTY_DENORM_DEA_RULES_ALL';
  ELSE
    l_denorm_table_name := 'JTF_TERR_DENORM_RULES_ALL';
  END IF;

  l_dyn_str := ' ' ||
    'INSERT INTO ' || p_terr_LEVEL_target_tbl ||
    ' ( ' ||
    '    trans_object_id ' ||
    '  , trans_detail_object_id ' ||
    '  , txn_date ' ||
    '  , WIN_TERR_ID ' ||
    '  , UL_TERR_ID ' ||
    '  , LL_TERR_ID ' ||
    '  , worker_id ' ||
    ' ) ' ||
    ' (SELECT ' ||
    '      TL.trans_object_id ' ||
    '    , TL.trans_detail_object_id ' ||
    '    , TL.txn_date  ' ||
    '    , TL.WIN_TERR_ID ' ||
    '    , TL.UL_terr_id ' ||
    '    , TL.terr_id ' ||
    '    , :B_WORKER_ID ' || --p_worker_id ||
    '  FROM (  ' ||
    '        SELECT ';

  IF (p_run_mode = 'BATCH') THEN
    /* Batch TAE */
    NULL;
  ELSE
    /* Real-time TAE */
    l_dyn_str := l_dyn_str || ' /*+ LEADING(M) */ ';
  END IF;

  l_dyn_str := l_dyn_str ||
    '         DISTINCT ' ||
    '            m.trans_object_id  ' ||
    '          , m.trans_detail_object_id  ' ||
    '          , m.txn_date  ' ||
    '          , M.TERR_ID            WIN_TERR_ID ' ||
    '          , UL.related_terr_id   UL_TERR_ID ' ||
    '          , UL.num_winners       UL_NUM_WINNERS ' ||
    '          , M.terr_id            TERR_ID ' ||
    '          , DENSE_RANK() OVER ( PARTITION BY ' ||
    '                                   m.trans_object_id ' ||
    '                                 , m.trans_detail_object_id ' ||
    '                                 , UL.related_terr_id ' ||
    '                                ORDER BY M.absolute_rank DESC, M.TERR_ID ) AS LL_TERR_RANK ' ||
    '        FROM ' || p_matches_target || ' M  ' ||
    '                , ' || l_denorm_table_name || ' UL  ' ||
    '                , ' || p_terr_L5_target_tbl || ' ML ' || /* FINAL LEVEL TABLE */
    '                , jtf_terr_all jt ' ||
    '                , ' || l_denorm_table_name || ' LL  ' ||
    '        WHERE UL.level_from_root = 6  ' || /* UPPER level */
    '        AND UL.source_id = :b1_source_id ' ||
    '        AND UL.terr_id = M.TERR_ID ' ||
    '        AND UL.related_terr_id = ML.LL_terr_id ' ||
    '        AND ( M.trans_detail_object_id = ML.trans_detail_object_id OR ' ||
    '              M.trans_detail_object_id IS NULL ) ' ||
    '        AND M.trans_object_id = ML.trans_object_id ' ||
    '        AND M.worker_id = ML.WORKER_ID' ||
    '        AND M.worker_id = :B_WORKER_ID ' ||
    '        AND ML.worker_id = :B_WORKER_ID ' ||
    '        AND jt.terr_id = LL.related_terr_id ' ||
    '        AND LL.level_from_root >= 6 ' || /* FINAL LEVEL(S) */
    '        AND LL.source_id = :b2_source_id ' ||
    '        AND LL.terr_id = M.TERR_ID ' ||
    '       ) TL ' ||
    '  WHERE TL.LL_TERR_RANK <= TL.UL_num_winners  ' ||
    ' ) ';

  BEGIN
    EXECUTE IMMEDIATE l_dyn_str USING
              p_worker_id
            , p_source_id
            , p_worker_id
            , p_worker_id
            , p_source_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.Process_Final_Level_Winners.num_rows',
                   'Number of rows inserted into ' || p_terr_LEVEL_target_tbl || ' : ' || SQL%ROWCOUNT);

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.Process_Final_Level_Winners.end',
                   'End of the procedure JTY_ASSIGN_BULK_PUB.Process_Final_Level_Winners ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.Process_Final_Level_Winners.other',
                     substr(SQLCODE || ' : ' || SQLERRM, 1, 4000));

END Process_Final_Level_Winners;


-- ***************************************************
--    API Specifications
-- ***************************************************
--    api name       : process_nmc_match
--    type           : private.
--    function       :
--    pre-reqs       :
--    notes:  API designed to get the transaction objs that satisfy changed terr defn.
--
PROCEDURE process_nmc_match
    ( p_source_id             IN          NUMBER,
      p_trans_id              IN          NUMBER,
      p_program_name          IN          VARCHAR2,
      p_request_id            IN          NUMBER,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      ERRBUF                  OUT NOCOPY  VARCHAR2,
      RETCODE                 OUT NOCOPY  VARCHAR2
    ) AS

  l_match_sql       VARCHAR2(32767);
  l_status          VARCHAR2(30);
  l_industry        VARCHAR2(30);
  l_owner           VARCHAR2(30);
  l_trans_target    VARCHAR2(30);
  l_nm_trans_target VARCHAR2(30);
  l_insert_stmt     VARCHAR2(3000);
  l_select_stmt     VARCHAR2(3000);
  first_time        BOOLEAN;
  l_indent          VARCHAR2(30);
  l_final_sql       VARCHAR2(32767);
  l_sysdate         DATE;
  l_delete_sql      VARCHAR2(3000);


  CURSOR c_get_qualrel_prod(cl_source_id number, cl_trans_id number) IS
  SELECT jtqp.relation_product
  FROM   jtf_tae_qual_products  jtqp
  WHERE  jtqp.source_id = cl_source_id
  AND    jtqp.trans_object_type_id = cl_trans_id
  ORDER BY jtqp.relation_product DESC;

  CURSOR c1(p_table_name IN VARCHAR2, p_owner IN VARCHAR2) is
  SELECT column_name
  FROM  all_tab_columns
  WHERE table_name = p_table_name
  AND   owner      = p_owner
  AND   column_name not in ('SECURITY_GROUP_ID', 'OBJECT_VERSION_NUMBER', 'WORKER_ID', 'LAST_UPDATE_DATE',
                            'LAST_UPDATED_BY', 'CREATION_DATE', 'CREATED_BY', 'LAST_UPDATE_LOGIN', 'REQUEST_ID',
                            'PROGRAM_APPLICATION_ID', 'PROGRAM_ID', 'PROGRAM_UPDATE_DATE', 'TXN_DATE');

  L_SCHEMA_NOTFOUND     EXCEPTION;
BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_nmc_match.start',
                   'Start of the procedure JTY_ASSIGN_BULK_PUB.process_nmc_match ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Get the schema name corresponding to JTF application */
  IF (FND_INSTALLATION.GET_APP_INFO('JTF', l_status, l_industry, l_owner)) THEN
    NULL;
  END IF;

  IF (l_owner IS NULL) THEN
    RAISE L_SCHEMA_NOTFOUND;
  END IF;

  /* Get the TRANS and NM_TRANS table names and active transaction type batch SQL */
  BEGIN
    SELECT  tup.batch_trans_table_name
           ,tup.batch_nm_trans_table_name
    INTO    l_trans_target
           ,l_nm_trans_target
    FROM    jty_trans_usg_pgm_details tup
    WHERE   tup.source_id     = p_source_id
    AND     tup.trans_type_id = p_trans_id
    AND     tup.program_name  = p_program_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_msg_data := 'No row in jty_trans_usg_pgm_details corresponding to usage : ' || p_source_id || ' transaction : ' || p_trans_id ||
                    ' program name : ' || p_program_name;
      RAISE;
  END;

  /* Delete from TRANS the txn objs present in NM_TRANS table */
  commit;
  EXECUTE IMMEDIATE 'alter session enable parallel dml';

  l_delete_sql :=
    'DELETE FROM ' || l_trans_target || ' A' || g_new_LINE ||
    'WHERE EXISTS ( ' || g_new_line ||
    '  SELECT 1 ' || g_new_line ||
    '  FROM ' || l_nm_trans_target || ' B' || g_new_line ||
    '  WHERE A.trans_object_id = B.trans_object_id )';
  EXECUTE IMMEDIATE l_delete_sql;

  commit;
  EXECUTE IMMEDIATE 'alter session disable parallel dml';

  /* Initialize local variables */
  first_time := TRUE;
  l_indent   := '  ';
  l_sysdate  := SYSDATE;

  /* Form the insert statement to insert transaction objects into TRANS table */
  l_insert_stmt := 'INSERT INTO ' || l_trans_target || '(';
  l_select_stmt := '(SELECT ';

  FOR column_names in c1(l_trans_target, l_owner) LOOP
    IF (first_time) THEN
      l_insert_stmt := l_insert_stmt || g_new_line || l_indent || column_names.column_name;
      l_select_stmt := l_select_stmt || g_new_line || l_indent || column_names.column_name;
      first_time := FALSE;
    ELSE
      l_insert_stmt := l_insert_stmt || g_new_line || l_indent || ',' || column_names.column_name;
      l_select_stmt := l_select_stmt || g_new_line || l_indent || ',' || column_names.column_name;
    END IF;
  END LOOP;

  /* Standard WHO columns */
  l_insert_stmt := l_insert_stmt || g_new_line || l_indent || ',LAST_UPDATE_DATE ' ||
                     g_new_line || l_indent || ',LAST_UPDATED_BY ' ||
                     g_new_line || l_indent || ',CREATION_DATE ' ||
                     g_new_line || l_indent || ',CREATED_BY ' ||
                     g_new_line || l_indent || ',LAST_UPDATE_LOGIN ' ||
                     g_new_line || l_indent || ',REQUEST_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_APPLICATION_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_ID ' ||
                     g_new_line || l_indent || ',PROGRAM_UPDATE_DATE ' ||
                     g_new_line || l_indent || ',TXN_DATE ' ||
                     g_new_line || l_indent || ',WORKER_ID ' ||
                     g_new_line || ')';

  l_select_stmt := l_select_stmt || g_new_line || l_indent || ',''' || l_sysdate || '''' ||
                     g_new_line || l_indent || ',''' || g_user_id || '''' ||
                     g_new_line || l_indent || ',''' || l_sysdate || '''' ||
                     g_new_line || l_indent || ',''' || g_user_id || '''' ||
                     g_new_line || l_indent || ',''' || g_login_id || '''' ||
                     g_new_line || l_indent || ',''' || p_request_id || '''' ||
                     g_new_line || l_indent || ',''' || g_appl_id || '''' ||
                     g_new_line || l_indent || ',''' || g_program_id || '''' ||
                     g_new_line || l_indent || ',''' || l_sysdate || '''' ||
                     g_new_line || l_indent || ',''' || l_sysdate || '''' ||
                     g_new_line || l_indent || ', 1 ';

  l_final_sql := l_insert_stmt || g_new_line ||
                     l_select_stmt || g_new_line || 'FROM ' || l_nm_trans_target || g_new_line || ' ) ';

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_nmc_match.final_sql',
                   substr('Insert satement : ' || l_final_sql, 1, 4000));

  /* Insert all the transaction objects into the TRANS table */
  EXECUTE IMMEDIATE l_final_sql;

  FOR jtf_csr IN c_get_qualrel_prod(p_source_id, p_trans_id) LOOP
    BEGIN
      SELECT batch_nmc_match_sql
      INTO   l_match_sql
      FROM   jty_tae_attr_products_sql
      WHERE  source_id = p_source_id
      AND    trans_type_id = p_trans_id
      AND    program_name = p_program_name
      AND    attr_relation_product = jtf_csr.relation_product;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_msg_data := 'No matching SQL found corresponding to source : ' || p_source_id || ' trans : ' || p_trans_id ||
                      ' Program name : ' || p_program_name || ' relation product : ' || jtf_csr.relation_product;
      RAISE;
    END;

   -- EXECUTE IMMEDIATE l_match_sql USING l_sysdate, g_user_id, l_sysdate, g_user_id, g_user_id, g_request_id,
   --                                       g_appl_id, g_program_id, l_sysdate, p_request_id, l_sysdate;

   -- Adding IF condition to add more  bind variables for the following variables. Fix for bug 9118732.
    IF ((mod(jtf_csr.relation_product,79) = 0 and jtf_csr.relation_product/79 <> 1) or       -- account classification
       (mod(jtf_csr.relation_product,137) = 0 and jtf_csr.relation_product/137 <> 1) or     -- lead expected purchase
       (mod(jtf_csr.relation_product,113) = 0 and jtf_csr.relation_product/113 <> 1) or     -- purchase amount
       (mod(jtf_csr.relation_product,131) = 0 and jtf_csr.relation_product/131 <> 1) or     -- lead inventory item
       (mod(jtf_csr.relation_product,163) = 0 and jtf_csr.relation_product/163 <> 1) or     -- opportunity inventory item
       (mod(jtf_csr.relation_product,167) = 0 and jtf_csr.relation_product/167 <> 1) or     -- opportunity classification
       (mod(jtf_csr.relation_product,139) = 0 and jtf_csr.relation_product/139 <> 1)) THEN  -- opportunity expected purchase

        EXECUTE IMMEDIATE l_match_sql USING l_sysdate, g_user_id, l_sysdate, g_user_id, g_user_id, g_request_id,
                                          g_appl_id, g_program_id, l_sysdate, p_request_id, l_sysdate, p_request_id, l_sysdate;
    ELSE

        EXECUTE IMMEDIATE l_match_sql USING l_sysdate, g_user_id, l_sysdate, g_user_id, g_user_id, g_request_id,
                                          g_appl_id, g_program_id, l_sysdate, p_request_id, l_sysdate;

    END IF;

    -- debug message
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_nmc_match.match',
                     'Number of records inserted for qualifier combination ' || jtf_csr.relation_product || ' : ' || SQL%ROWCOUNT);
  END LOOP;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_nmc_match.end',
                   'End of the procedure JTY_ASSIGN_BULK_PUB.process_nmc_match ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN L_SCHEMA_NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := 'Schema name corresponding to JTF application not found';
    RETCODE := 2;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_nmc_match.l_schema_notfound',
                     'Schema name corresponding to the JTF application not found');

  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RETCODE := 2;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_nmc_match.no_data_found',
                     x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_nmc_match.other',
                     substr(x_msg_data, 1, 4000));

END process_nmc_match;


-- ***************************************************
--    API Specifications
-- ***************************************************
--    api name       : collect_trans_data
--    type           : public.
--    function       :
--    pre-reqs       :
--    notes:  API designed to insert transaction objects into TRANS table
--            for "TOTAL", "INCREMENTAL" and "DATE EFFECTIVE" mode.
--
--    Parameter p_oic_mode added only for OIC.
--
PROCEDURE collect_trans_data
    ( p_api_version_number    IN          NUMBER,
      p_init_msg_list         IN          VARCHAR2,
      p_source_id             IN          NUMBER,
      p_trans_id              IN          NUMBER,
      p_program_name          IN          VARCHAR2,
      p_mode                  IN          VARCHAR2,
      p_where                 IN          VARCHAR2,
      p_no_of_workers         IN          NUMBER,
      p_percent_analyzed      IN          NUMBER,
      p_request_id            IN          NUMBER,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      ERRBUF                  OUT NOCOPY  VARCHAR2,
      RETCODE                 OUT NOCOPY  VARCHAR2,
      p_oic_mode              IN          VARCHAR2 DEFAULT 'NOOIC'
    ) AS

  l_api_name                   CONSTANT VARCHAR2(30) := 'collect_trans_data';
  l_api_version_number         CONSTANT NUMBER       := 1.0;

BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.start',
                   'Start of the procedure JTY_ASSIGN_BULK_PUB.collect_trans_data ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  /* Standard call to check for call compatibility. */
  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME)  THEN

    x_msg_data := 'API FND_API.Compatible_API_Call has failed';
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Initialize message list if p_init_msg_list is set to TRUE. */
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_oic_mode = 'NOOIC' or p_oic_mode = 'CLEAR' THEN

      -- debug message
          jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.param_value',
                   'Source : ' || p_source_id || ' Trans : ' || p_trans_id || ' Program Name : ' || p_program_name ||
                   ' Mode : ' || p_mode || ' Where clause : ' || p_where || ' Number of workers : ' || p_no_of_workers ||
                   ' Percent Analyzed : ' || p_percent_analyzed);

        /* Clear the interface tables */
        clear_trans_data (
          p_source_id        => p_source_id,
          p_trans_id         => p_trans_id,
          p_program_name     => p_program_name,
          p_mode             => p_mode,
          p_request_id       => p_request_id,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data,
          errbuf             => errbuf,
          retcode            => retcode);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          -- debug message
          x_msg_data := 'API JTY_ASSIGN_BULK_PUB.clear_trans_data has failed';
            jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.clear_trans_data',
                     x_msg_data);

          RAISE	FND_API.G_EXC_ERROR;
        END IF;

        -- debug message
          jty_log(FND_LOG.LEVEL_EVENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.end_clear_trans_data',
                   'API clear_trans_data completed successfully');
  END IF; -- p_oic_mode = 'NOOIC' or p_oic_mode = 'CLEAR'

  IF p_oic_mode = 'NOOIC' or p_oic_mode = 'INSERT' THEN

       /* Insert the txn objects into TRANS table */
        insert_trans_data (
          p_source_id        => p_source_id,
          p_trans_id         => p_trans_id,
          p_program_name     => p_program_name,
          p_mode             => p_mode,
          p_where            => p_where,
          p_no_of_workers    => p_no_of_workers,
          p_request_id       => p_request_id,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data,
          errbuf             => errbuf,
          retcode            => retcode,
          p_oic_mode         => p_oic_mode
          );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          -- debug message
          x_msg_data := 'API JTY_ASSIGN_BULK_PUB.insert_trans_data has failed';
            jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.insert_trans_data',
                     x_msg_data);

          RAISE	FND_API.G_EXC_ERROR;
        END IF;

        -- debug message
          jty_log(FND_LOG.LEVEL_EVENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.end_insert_trans_data',
                   'API insert_trans_data completed successfully');
  END IF; -- p_oic_mode = 'NOOIC' or p_oic_mode = 'INSERT'


  IF (p_mode = 'INCREMENTAL') THEN

    /* Synchronize trans and nm_trans table and insert objects */
    /* that satisfy the modified territory definition          */
    process_nmc_match (
      p_source_id        => p_source_id,
      p_trans_id         => p_trans_id,
      p_program_name     => p_program_name,
      p_request_id       => p_request_id,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      errbuf             => errbuf,
      retcode            => retcode);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
      x_msg_data := 'API JTY_ASSIGN_BULK_PUB.process_nmc_match has failed';
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.process_nmc_match',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    -- debug message
      jty_log(FND_LOG.LEVEL_EVENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.end_process_nmc_match',
                     'API process_nmc_match completed successfully');

    /* insert into NM_TRANS txn objs that are assigned to changed territories */
    insert_nm_trans_data (
      p_source_id        => p_source_id,
      p_trans_id         => p_trans_id,
      p_program_name     => p_program_name,
      p_request_id       => p_request_id,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      errbuf             => errbuf,
      retcode            => retcode);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- debug message
      x_msg_data := 'API JTY_ASSIGN_BULK_PUB.insert_nm_trans_data has failed';
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.insert_nm_trans_data',
                       x_msg_data);

      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    -- debug message
      jty_log(FND_LOG.LEVEL_EVENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.end_insert_nm_trans_data',
                     'API insert_nm_trans_data completed successfully');

  END IF; /* end IF (p_mode = 'INCREMENTAL') */

  IF p_oic_mode = 'NOOIC' or p_oic_mode = 'POST' THEN

      get_winners_parallel_setup (
          p_source_id             => p_source_id,
          p_trans_id              => p_trans_id,
          p_program_name          => p_program_name,
          p_mode                  => p_mode,
          p_no_of_workers         => p_no_of_workers,
          p_percent_analyzed      => p_percent_analyzed,
          p_request_id            => p_request_id,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
          ERRBUF                  => ERRBUF,
          RETCODE                 => RETCODE
        );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          -- debug message
          x_msg_data := 'API JTY_ASSIGN_BULK_PUB.get_winners_parallel_setup has failed';
            jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.get_winners_parallel_setup',
                     x_msg_data);

          RAISE FND_API.G_EXC_ERROR;
        END IF;
  END IF; -- p_oic_mode = 'NOOIC' or p_oic_mode = 'POST'

  retcode := 0;
  errbuf  := null;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.end',
                   'End of the procedure JTY_ASSIGN_BULK_PUB.collect_trans_data ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF  := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.g_exc_unexpected_error',
                     x_msg_data);

  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RETCODE := 2;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.no_data_found',
                     x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
    RETCODE := 2;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.g_exc_error',
                     x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.collect_trans_data.other',
                     substr(x_msg_data, 1, 4000));

END collect_trans_data;


-- ***************************************************
--    API Specifications
-- ***************************************************
--    api name       : process_winners
--    type           : private.
--    function       :
--    pre-reqs       :
--    notes:  API designed to get the winning territories for the
--            transaction objs, it supports multiple worker architecture
--
PROCEDURE process_winners
    ( p_source_id             IN          NUMBER,
      p_trans_id              IN          NUMBER,
      p_program_name          IN          VARCHAR2,
      p_mode                  IN          VARCHAR2,
      p_percent_analyzed      IN          NUMBER,
      p_worker_id             IN          NUMBER,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      ERRBUF                  OUT NOCOPY  VARCHAR2,
      RETCODE                 OUT NOCOPY  VARCHAR2,
      p_oic_mode              IN VARCHAR2
    ) AS

  l_match_target             VARCHAR2(40);
  l_umatch_target            VARCHAR2(40);
  l_l1_target                VARCHAR2(40);
  l_l2_target                VARCHAR2(40);
  l_l3_target                VARCHAR2(40);
  l_l4_target                VARCHAR2(40);
  l_l5_target                VARCHAR2(40);
  l_wt_target                VARCHAR2(40);
  l_winner_target            VARCHAR2(40);
  l_uwinner_target           VARCHAR2(40);
  l_mp_winner_target         VARCHAR2(40);
  l_dmc_winner_target        VARCHAR2(40);
  lp_sysdate                 DATE;
  l_multi_level_winning_flag VARCHAR2(1);
  l_date_effective           BOOLEAN;
  l_status                   VARCHAR2(30);
  l_industry                 VARCHAR2(30);
  l_fnd_schema               VARCHAR2(30);
  l_max_terr                 NUMBER;
  l_no_ind_cols              NUMBER;


  l_dyn_str                  LONG;

  L_SCHEMA_NOTFOUND          EXCEPTION;
  L_NO_MATCH_TERR            EXCEPTION;
BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winner.start',
                   'Start of the procedure JTY_ASSIGN_BULK_PUB.process_winner ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  lp_sysdate := SYSDATE;

  IF (p_mode = 'DATE EFFECTIVE') THEN
    l_date_effective := true;
  ELSE
    l_date_effective := false;
  END IF;

  BEGIN
    SELECT batch_match_table_name
          ,batch_unique_match_table_name
          ,batch_l1_winner_table_name
          ,batch_l2_winner_table_name
          ,batch_l3_winner_table_name
          ,batch_l4_winner_table_name
          ,batch_l5_winner_table_name
          ,batch_wt_winner_table_name
          ,batch_winner_table_name
          ,batch_unique_winner_table_name
          ,batch_mp_winner_table_name || p_worker_id
          ,batch_dmc_winner_table_name || p_worker_id
          ,multi_level_winning_flag
    INTO   l_match_target
          ,l_umatch_target
          ,l_l1_target
          ,l_l2_target
          ,l_l3_target
          ,l_l4_target
          ,l_l5_target
          ,l_wt_target
          ,l_winner_target
          ,l_uwinner_target
          ,l_mp_winner_target
          ,l_dmc_winner_target
          ,l_multi_level_winning_flag
    FROM    jty_trans_usg_pgm_details tup
    WHERE   tup.source_id     = p_source_id
    AND     tup.trans_type_id = p_trans_id
    AND     tup.program_name  = p_program_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_msg_data := 'No row in jty_trans_usg_pgm_details corresponding to usage : ' || p_source_id || ' transaction : ' || p_trans_id ||
                    ' program name : ' || p_program_name;
      RAISE;
  END;

  COMMIT;

IF p_oic_mode = 'NOOIC' OR p_oic_mode = 'WINNER/POPULATE'
THEN

  IF (l_multi_level_winning_flag <> 'Y') THEN
    l_dyn_str :=
      ' INSERT INTO ' || l_winner_target || ' i ' ||
      ' ( ' ||
      ' 	 TRANS_OBJECT_ID        ' ||
      ' 	,TRANS_DETAIL_OBJECT_ID ' ||
      ' 	,WORKER_ID ' ||
      ' 	,SOURCE_ID              ' ||
      ' 	,TRANS_OBJECT_TYPE_ID   ' ||
      ' 	,LAST_UPDATE_DATE       ' ||
      ' 	,LAST_UPDATED_BY        ' ||
      ' 	,CREATION_DATE          ' ||
      ' 	,CREATED_BY             ' ||
      '	    ,LAST_UPDATE_LOGIN      ' ||
      '	    ,REQUEST_ID             ' ||
      '	    ,PROGRAM_APPLICATION_ID ' ||
      '	    ,PROGRAM_ID             ' ||
      '	    ,PROGRAM_UPDATE_DATE    ' ||
      '	    ,TERR_ID                ' ||
      '	    ,ABSOLUTE_RANK          ' ||
      '	    ,TOP_LEVEL_TERR_ID      ' ||
      '	    ,RESOURCE_ID            ' ||
      '	    ,RESOURCE_TYPE          ' ||
      '	    ,GROUP_ID               ' ||
      '	    ,ROLE_ID                ' ||
      '	    ,ROLE                   ' ||
      '	    ,PRIMARY_CONTACT_FLAG   ' ||
      '	    ,PERSON_ID              ' ||
      '	    ,ORG_ID                 ' ||
      '	    ,TERR_RSC_ID            ' ||
      '	    ,FULL_ACCESS_FLAG       ' ||
      ' ) ' ||
      ' ( ' ||

      '  SELECT ' ||  -- DISTINCT ' ||
      '      WT.trans_object_id             ' ||
      '    , WT.trans_detail_object_id      ' ||
      '    , :bv_worker_id ' || --p_worker_id ||
      '    , :BV1_SOURCE_ID                 ' ||
      '    , :BV1_TRANS_OBJECT_TYPE_ID      ' ||
      '    , :BV1_LAST_UPDATE_DATE          ' ||
      '    , :BV1_LAST_UPDATED_BY           ' ||
      '    , :BV1_CREATION_DATE             ' ||
      '    , :BV1_CREATED_BY                ' ||
      '    , :BV1_LAST_UPDATE_LOGIN         ' ||
      '    , :BV1_REQUEST_ID                ' ||
      '    , :BV1_PROGRAM_APPLICATION_ID    ' ||
      '    , :BV1_PROGRAM_ID                ' ||
      '    , :BV1_PROGRAM_UPDATE_DATE       ' ||
      '    , WT.terr_id                     ' ||
      '    , null absolute_rank             ' ||  /*  o_dttm.absolute_rank     ' || */
      '    , null top_level_terr_id         ' ||  /*  o_dttm.top_level_terr_id ' || */
      '    , jtr.resource_id                ' ||
      '    , jtr.resource_type              ' ||
      '    , jtr.group_id                   ' ||
      '    , inv.role_id                    ' ||
      '    , jtr.role                       ' ||
      '    , jtr.primary_contact_flag       ' ||
      '    , jtr.PERSON_ID                  ' ||
      '    , jtr.org_id                     ' ||
      '    , jtr.terr_rsc_id                ' ||
      '    , decode(jtra.trans_access_code, ''FULL_ACCESS'', ''Y'', ''N'') ' ||
      '  FROM ( /* WINNERS ILV */ ' ||

      '         SELECT                                                                                                        ' ||
      '            o.trans_object_id                                                                                          ' ||
      '           ,o.trans_detail_object_id                                                                                   ' ||
      '           ,o.terr_id                                                                                                  ' ||
      '           ,o.txn_date                                                                                                 ' ||
      '         FROM                                                                                                          ' ||
      '           ( SELECT                                                                                                    ' ||
      '                i.trans_id                                                                                             ' ||
      '               ,i.trans_object_id                                                                                      ' ||
      '               ,i.trans_detail_object_id                                                                               ' ||
      '               ,i.terr_id                                                                                              ' ||
      '               ,i.top_level_terr_id                                                                                    ' ||
      '               ,i.txn_date                                                                                             ' ||
      '               ,RANK() OVER ( PARTITION BY                                                                             ' ||
      '                                 i.trans_id                                                                            ' ||
      '                               , i.trans_object_id                                                                     ' ||
      '                               , i.trans_detail_object_id                                                              ' ||
      '                               , i.top_level_terr_id                                                                   ' ||
      '                              ORDER BY i.absolute_rank DESC, i.terr_id) AS TERR_RANK                                   ' ||
      '             FROM ' || l_match_target || ' i                                                                           ' ||
      '             WHERE i.worker_id = :bv_worker_id ) o                                                                     ' ||
      '         WHERE o.TERR_RANK <= (SELECT NVL(t.num_winners, 1) FROM jtf_terr_all t WHERE t.terr_id = o.top_level_terr_id) ' ||
      '       ) WT                                                                                                            ' ||
      '     , jtf_terr_rsc_all jtr                                                                                            ' ||
      '     , jtf_terr_rsc_access_all jtra                                                                                    ' ||
      '     , jtf_qual_types_all jqta                                                                                         ' ||
      '     , (SELECT                                                                                                         ' ||
      '          max(role_id) role_id                                                                                         ' ||
      '         ,role_code    role_code                                                                                       ' ||
      '        FROM jtf_rs_roles_b                                                                                             ' ||
      '        GROUP BY role_code ) inv                                                                                       ' ||
      '  WHERE  WT.terr_id = jtr.terr_id                                                                                      ' ||
      '  AND jtr.end_date_active >= WT.txn_date                                                                               ' ||
      '  AND jtr.start_date_active <= WT.txn_date                                                                             ' ||
      '  AND jtr.resource_type <> ''RS_ROLE''                                                                                 ' ||
      '  AND jtr.terr_rsc_id = jtra.terr_rsc_id                                                                               ' ||
      '  AND jtr.role = inv.role_code(+)                                                                                      ' ||
      '  AND jtra.access_type = jqta.name                                                                                     ' ||
      '  AND jtra.trans_access_code <> ''NONE''                                                                               ' ||
      '  AND jqta.qual_type_id = :bv_trans_id ';

    BEGIN

      EXECUTE IMMEDIATE l_dyn_str USING
                    p_worker_id               /* :bv_worker_id */
                  , p_source_id              /* :BV1_SOURCE_ID */
                  , p_trans_id                /* :BV1_TRANS_OBJECT_TYPE_ID */
                  , lp_sysdate               /* :BV1_LAST_UPDATE_DATE */
                  , G_USER_ID                /* :BV1_LAST_UPDATED_BY */
                  , lp_sysdate               /* :BV1_CREATION_DATE */
                  , G_USER_ID                /* :BV1_CREATED_BY */
                  , G_LOGIN_ID               /* :BV1_LAST_UPDATE_LOGIN */
                  , G_REQUEST_ID              /* :BV1_REQUEST_ID */
                  , G_APPL_ID                 /* :BV1_PROGRAM_APPLICATION_ID */
                  , G_PROGRAM_ID              /* :BV1_PROGRAM_ID */
                  , lp_sysdate                /* :BV1_PROGRAM_UPDATE_DATE */
                  , p_worker_id               /* :bv_worker_id */
                  , p_trans_id;

      COMMIT;  -- after modifying table in parallel

        jty_log(FND_LOG.LEVEL_STATEMENT,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.winner_num_row',
                       'Number of records inserted into ' || l_winner_target || ' for worker_id : ' || p_worker_id || ' : ' || SQL%ROWCOUNT);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

  ELSE
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.winning_process',
                     'Star of winning process');

    IF (FND_INSTALLATION.GET_APP_INFO('FND', l_status, l_industry, l_fnd_schema)) THEN
      NULL;
    END IF;

    IF (l_fnd_schema IS NULL) THEN
      RAISE L_SCHEMA_NOTFOUND;
    END IF;

    /* Get the maximun number of territories in the matching combinations */
    l_dyn_str :=
      'SELECT max(count(terr_id)) ' ||
      'FROM   ' || l_match_target || ' ' ||
	  'WHERE  worker_id = :worker_id ' ||
      'GROUP BY trans_object_id, trans_detail_object_id';

    EXECUTE IMMEDIATE l_dyn_str INTO l_max_terr USING p_worker_id;

      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.l_max_terr',
                     'Number of maximum territories for a matching combination for the worker_id : ' || p_worker_id || ' : ' || l_max_terr);

    IF ((l_max_terr IS NULL) OR (l_max_terr = 0)) THEN
      x_msg_data := 'No row in ' || l_match_target || ' for worker_id = ' || p_worker_id;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETCODE := 0;
      x_msg_count := 1;
      ERRBUF := null;
      RAISE L_NO_MATCH_TERR;
    END IF;

    /* create a temp table that will contain all the transaction objects */
    /* and their matching territories in a single row                    */
    /* drop the table if it alreday exists */
    BEGIN
      ad_ddl.do_ddl(l_fnd_schema, 'JTF', ad_ddl.drop_table, 'drop table ' || l_mp_winner_target, l_mp_winner_target);
    EXCEPTION
      when others then
         jty_log(FND_LOG.LEVEL_STATEMENT,
          'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.l_mp_winner_target',
                     'Table ' || l_mp_winner_target || ' drop FAILED ');
       --  RAISE ;
    END;

      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.l_mp_winner_target',
                     'Table ' || l_mp_winner_target || ' successfully dropped');

    /* create a temp table that will contain all the transaction objects */
    /* add the columns trans_object_id, trans_details_object_id, txn_date */
    l_dyn_str :=
      'create table ' || l_mp_winner_target || ' as ( ' ||
	  ' select trans_object_id, trans_detail_object_id, txn_date, max(rownum) link ';

    /* create column for each of the matching territories */
    for i IN 1..l_max_terr loop
      l_dyn_str := l_dyn_str || ' ,nvl(max(decode(trank, ' || i || ', terr_id, null)), 0) terr_id' || i;
    end loop;

    /* get the data from match table */
    l_dyn_str := l_dyn_str ||
      ' from ' ||
	  '   (select trans_object_id, trans_detail_object_id, terr_id, txn_date, ' ||
	  '           dense_rank() over(partition by trans_object_id, trans_detail_object_id order by terr_id) trank ' ||
	  '    from ' || l_match_target ||
	  '    where worker_id = ' || p_worker_id || ' ) ' ||
	  ' group by trans_object_id, trans_detail_object_id, txn_date )';

      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.l_mp_winner_target',
                     substr(l_dyn_str, 1, 4000));

    /* create the table in jtf schema */
    ad_ddl.do_ddl(l_fnd_schema, 'JTF', ad_ddl.create_table, l_dyn_str, l_mp_winner_target);

      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.l_mp_winner_target',
                     'Table ' || l_mp_winner_target || ' successfully created');

    /* create a temp table that will contain only the distinct */
    /* combination of matching territories in a single row     */
    /* drop the table if it alreday exists */
    BEGIN
      ad_ddl.do_ddl(l_fnd_schema, 'JTF', ad_ddl.drop_table, 'drop table ' || l_dmc_winner_target, l_dmc_winner_target);
    EXCEPTION
      when others then
         jty_log(FND_LOG.LEVEL_STATEMENT,
         'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.l_dmc_winner_target',
          'Table ' || l_dmc_winner_target || ' drop FAILED');
         -- RAISE;
    END;

      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.l_dmc_winner_target',
                     'Table ' || l_dmc_winner_target || ' successfully dropped');

    /* Form the create table statement */
    l_dyn_str :=
      'create table ' || l_dmc_winner_target || ' as ( ' ||
	  ' select max(rownum) link ';
    for i in 1..l_max_terr loop
	    l_dyn_str := l_dyn_str ||
	      ' ,terr_id' || i;
	end loop;
	l_dyn_str := l_dyn_str || ' from ' || l_mp_winner_target || ' group by terr_id1 ';
	for i in 2..l_max_terr loop
	  l_dyn_str := l_dyn_str ||
	    ' ,terr_id' || i;
	end loop;
    l_dyn_str := l_dyn_str || ' )';

      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.l_dmc_winner_target',
                     substr(l_dyn_str, 1, 4000));

    /* Create the table in JTF schema */
    ad_ddl.do_ddl(l_fnd_schema, 'JTF', ad_ddl.create_table, l_dyn_str, l_dmc_winner_target);

      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.l_dmc_winner_target',
                     'Table ' || l_dmc_winner_target || ' successfully created');

    /* Insert into umatch table the unique combination of matching territories */
    l_dyn_str :=
      'insert into ' || l_umatch_target ||
      ' (trans_object_id, ' ||
      '  trans_detail_object_id, ' ||
      '  terr_id, ' ||
      '  absolute_rank, ' ||
      '  txn_date, ' ||
--      '  LAST_UPDATE_DATE, ' ||
--      '  LAST_UPDATED_BY, ' ||
--      '  CREATION_DATE, ' ||
--      '  CREATED_BY, ' ||
--      '	 LAST_UPDATE_LOGIN, ' ||
--      '	 REQUEST_ID, ' ||
--      '	 PROGRAM_APPLICATION_ID, ' ||
--      '	 PROGRAM_ID, ' ||
--      '	 PROGRAM_UPDATE_DATE, ' ||
      '  worker_id) ( ';

        -- SOLIN, bug 5633062
        -- move jtf_terr_all out of inline view to avoid
        -- database bug
        l_dyn_str := l_dyn_str ||
            'select ' ||
            ' ilv.trans_object_id, ' ||
            ' -1, ' ||   --trans_detail_object_id
            ' ilv.terr_id, ' ||
            ' jt.absolute_rank, ' ||
            ' null, ' ||
            p_worker_id ||
            ' from (' ;

    for i IN 1..l_max_terr loop
      l_dyn_str := l_dyn_str ||
        'select ' ||
        '  a.link trans_object_id, ' ||
--        '  -1 trans_detail_object_id, ' ||
        '  a.terr_id' || i || ' terr_id ' ||
--        '  b.absolute_rank, ' ||
        'from ' || l_dmc_winner_target || ' a ';
      if (i < l_max_terr) then
          l_dyn_str := l_dyn_str || ' union ';
      end if;
    end loop;
    l_dyn_str := l_dyn_str || ' ) ilv, ' ||
            ' jtf_terr_all jt ' ||
            'where ilv.terr_id = jt.terr_id) ';

/* SOLIN, the oritinal code follows: 5633062
    for i IN 1..l_max_terr loop
      l_dyn_str := l_dyn_str ||
	    'select ' ||
        '  a.link trans_object_id, ' ||
        '  -1 trans_detail_object_id, ' ||
        '  a.terr_id' || i || ' terr_id, ' ||
        '  b.absolute_rank, ' ||
        '  null, ' ||
--        '  ''' || lp_sysdate || ''', ' ||
--        '  ' || g_user_id || ', ' ||
--        '  ''' || lp_sysdate || ''', ' ||
--        '  ' || g_user_id || ', ' ||
--        '  ' || g_login_id || ', ' ||
--        '  ' || g_request_id || ', ' ||
--        '  ' || g_appl_id || ', ' ||
--        '  ' || g_program_id || ', ' ||
--        '  ''' || lp_sysdate || ''', ' ||
        '  ' || p_worker_id || ' ' ||
	    'from ' || l_dmc_winner_target || ' a, jtf_terr_all b ' ||
	    'where a.terr_id' || i || ' = b.terr_id ';
	  if (i < l_max_terr) then
	    l_dyn_str := l_dyn_str || ' union ';
	  end if;
    end loop;
    l_dyn_str := l_dyn_str || ' )';
*/
      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.l_umatch',
                     substr(l_dyn_str, 1, 4000));

    execute immediate l_dyn_str;

      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.l_umatch',
                     'Data successfully inserted in umatch table');

    /* Create in index on l_dmc_winner_target */
    IF (l_max_terr > 32) THEN
      l_no_ind_cols := 32;
    ELSE
      l_no_ind_cols := l_max_terr;
    END IF;
    l_dyn_str :=
      'create index ' || l_dmc_winner_target || '_N1 on ' || l_dmc_winner_target || ' (terr_id1 ';
    for i in 2..l_no_ind_cols loop
      l_dyn_str := l_dyn_str ||
        ' , terr_id' || i;
    end loop;
    l_dyn_str := l_dyn_str || ' )';

      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.l_dmc_winner_target_index',
                     substr(l_dyn_str, 1, 4000));

    /* Create the index in JTF schema */
    ad_ddl.do_ddl(l_fnd_schema, 'JTF', ad_ddl.create_index, l_dyn_str, l_dmc_winner_target || 'N');

    /* update the temporary table to maintain the link           */
    /* between txn objects and unique terr matching combinations */
    l_dyn_str :=
      'update ' || l_mp_winner_target || ' a ' ||
      ' set link = ( ' ||
	  '    select /*+ use_index(' || l_dmc_winner_target || '_N1) */ link from ' || l_dmc_winner_target || ' b ' ||
	  '    where a.terr_id1 = b.terr_id1 ';
    for i in 2..l_max_terr loop
      l_dyn_str := l_dyn_str ||
	    ' and a.terr_id' || i || ' = b.terr_id' || i || ' ';
    end loop;
    l_dyn_str := l_dyn_str || ' )';

      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.l_mp_winner_update',
                     substr(l_dyn_str, 1, 4000));

    execute immediate l_dyn_str;

      jty_log(FND_LOG.LEVEL_STATEMENT,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winners.l_mp_winner_update',
                     'Link successfully updated in ' || l_dmc_winner_target || ' table');

    /* Process first level */
    Process_Level_Winners (
          p_terr_LEVEL_target_tbl  => l_L1_target,
          p_terr_PARENT_LEVEL_tbl  => l_L1_target,
          p_UPPER_LEVEL_FROM_ROOT  => 1,
          p_LOWER_LEVEL_FROM_ROOT  => 1,
          p_matches_target         => l_umatch_target,
          p_source_id              => p_source_id,
          p_run_mode               => 'BATCH',
          p_date_effective         => l_date_effective,
          x_return_status          => x_return_status,
          p_worker_id              => p_worker_id
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.l1',
                       x_msg_data);
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    COMMIT;

/*
    JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
          p_table_name    => l_L1_target
        , p_percent       => p_percent_analyzed
        , x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_data := 'API JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX has failed for ' || l_L1_target;
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.l1_analyze',
                       x_msg_data);
      END IF;
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
*/

    /* Process second level */
    Process_Level_Winners (
          p_terr_LEVEL_target_tbl  => l_L2_target,
          p_terr_PARENT_LEVEL_tbl  => l_L1_target,
          p_UPPER_LEVEL_FROM_ROOT  => 1,
          p_LOWER_LEVEL_FROM_ROOT  => 2,
          p_matches_target         => l_umatch_target,
          p_source_id              => p_source_id,
          p_run_mode               => 'BATCH',
          p_date_effective         => l_date_effective,
          x_return_status          => x_return_status,
          p_worker_id              => p_worker_id
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.l2',
                       x_msg_data);
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    COMMIT;

/*
    JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
          p_table_name    => l_L2_target
        , p_percent       => p_percent_analyzed
        , x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_data := 'API JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX has failed for ' || l_L2_target;
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.l2_analyze',
                       x_msg_data);
      END IF;
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
*/

    /* Process third level */
    Process_Level_Winners (
          p_terr_LEVEL_target_tbl  => l_L3_target,
          p_terr_PARENT_LEVEL_tbl  => l_L2_target,
          p_UPPER_LEVEL_FROM_ROOT  => 2,
          p_LOWER_LEVEL_FROM_ROOT  => 3,
          p_matches_target         => l_umatch_target,
          p_source_id              => p_source_id,
          p_run_mode               => 'BATCH',
          p_date_effective         => l_date_effective,
          x_return_status          => x_return_status,
          p_worker_id              => p_worker_id
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.l3',
                       x_msg_data);
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    COMMIT;

/*
    JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
          p_table_name    => l_L3_target
        , p_percent       => p_percent_analyzed
        , x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_data := 'API JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX has failed for ' || l_L3_target;
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.l3_analyze',
                       x_msg_data);
      END IF;
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
*/

    /* Process fourth level */
    Process_Level_Winners (
          p_terr_LEVEL_target_tbl  => l_L4_target,
          p_terr_PARENT_LEVEL_tbl  => l_L3_target,
          p_UPPER_LEVEL_FROM_ROOT  => 3,
          p_LOWER_LEVEL_FROM_ROOT  => 4,
          p_matches_target         => l_umatch_target,
          p_source_id              => p_source_id,
          p_run_mode               => 'BATCH',
          p_date_effective         => l_date_effective,
          x_return_status          => x_return_status,
          p_worker_id              => p_worker_id
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.l4',
                       x_msg_data);
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    COMMIT;

/*
    JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
          p_table_name    => l_L4_target
        , p_percent       => p_percent_analyzed
        , x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_data := 'API JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX has failed for ' || l_L4_target;
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.l4_analyze',
                       x_msg_data);
      END IF;
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
*/

    /* Process fifth level */
    Process_Level_Winners (
          p_terr_LEVEL_target_tbl  => l_L5_target,
          p_terr_PARENT_LEVEL_tbl  => l_L4_target,
          p_UPPER_LEVEL_FROM_ROOT  => 4,
          p_LOWER_LEVEL_FROM_ROOT  => 5,
          p_matches_target         => l_umatch_target,
          p_source_id              => p_source_id,
          p_run_mode               => 'BATCH',
          p_date_effective         => l_date_effective,
          x_return_status          => x_return_status,
          p_worker_id              => p_worker_id
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.l5',
                       x_msg_data);
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    COMMIT;

/*
    JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
          p_table_name    => l_L5_target
        , p_percent       => p_percent_analyzed
        , x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_data := 'API JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX has failed for ' || l_L5_target;
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.l5_analyze',
                       x_msg_data);
      END IF;
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
*/

    /* Process final level */
    Process_Final_Level_Winners (
          p_terr_LEVEL_target_tbl  => l_wt_target,
          p_terr_L5_target_tbl     => l_L5_target,
          p_matches_target         => l_umatch_target,
          p_source_id              => p_source_id,
          p_run_mode               => 'BATCH',
          p_date_effective         => l_date_effective,
          x_return_status          => x_return_status,
          p_worker_id              => p_worker_id
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.wt',
                       x_msg_data);
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    COMMIT;

/*
    JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
          p_table_name    => l_wt_target
        , p_percent       => p_percent_analyzed
        , x_return_status => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_data := 'API JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX has failed for ' || l_wt_target;
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        jty_log(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.wt_analyze',
                       x_msg_data);
      END IF;
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
*/

      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.begin_populate_winners',
                     'Start of populating the winner table');

    l_dyn_str :=
      ' INSERT INTO ' || l_uwinner_target || ' i ' ||
      ' ( ' ||
      ' 	 TRANS_OBJECT_ID        ' ||
      ' 	,TRANS_DETAIL_OBJECT_ID ' ||
      ' 	,WORKER_ID ' ||
      ' 	,LAST_UPDATE_DATE       ' ||
      ' 	,LAST_UPDATED_BY        ' ||
      ' 	,CREATION_DATE          ' ||
      ' 	,CREATED_BY             ' ||
      '	    ,LAST_UPDATE_LOGIN      ' ||
      '	    ,REQUEST_ID             ' ||
      '	    ,PROGRAM_APPLICATION_ID ' ||
      '	    ,PROGRAM_ID             ' ||
      '	    ,PROGRAM_UPDATE_DATE    ' ||
      '	    ,TERR_ID                ' ||
      '	    ,ABSOLUTE_RANK          ' ||
      '	    ,TOP_LEVEL_TERR_ID      ' ||
      ' ) ' ||
      ' ( ' ||
      '  SELECT ' ||  -- DISTINCT ' ||
      '      WINNERS.trans_object_id         ' ||
      '    , WINNERS.trans_detail_object_id  ' ||
      '    , :bv_worker_id ' || --p_worker_id ||
      '    , :BV1_LAST_UPDATE_DATE          ' ||
      '    , :BV1_LAST_UPDATED_BY           ' ||
      '    , :BV1_CREATION_DATE             ' ||
      '    , :BV1_CREATED_BY                ' ||
      '    , :BV1_LAST_UPDATE_LOGIN         ' ||
      '    , :BV1_REQUEST_ID                ' ||
      '    , :BV1_PROGRAM_APPLICATION_ID    ' ||
      '    , :BV1_PROGRAM_ID                ' ||
      '    , :BV1_PROGRAM_UPDATE_DATE       ' ||
      '    , WINNERS.WIN_terr_id            ' ||
      '    , null absolute_rank             ' ||  /*  o_dttm.absolute_rank     ' || */
      '    , null top_level_terr_id         ' ||  /*  o_dttm.top_level_terr_id ' || */
      '  FROM ( /* WINNERS ILV */ ' ||
      '           SELECT ILV.trans_object_id ' ||
      '                , ILV.trans_detail_object_id ' ||
      '                , ILV.WIN_TERR_ID ' ||
      '           FROM  ( SELECT  trans_object_id ' ||
      '                         , trans_detail_object_id ' ||
      '                         , WIN_TERR_ID WIN_TERR_ID ' ||
      '                  FROM ' || l_L1_target ||
      '                  WHERE WORKER_ID = :bv_worker_id ' ||
      '                  MINUS ' ||
      '                  SELECT trans_object_id ' ||
      '                       , trans_detail_object_id ' ||
      '                       , ul_terr_id WIN_TERR_ID ' ||
      '                  FROM ' || l_L2_target ||
      '                  WHERE WORKER_ID = :bv_worker_id ' ||
      '               ) ILV ' ||

      '           UNION ALL ' ||

      '           SELECT ILV.trans_object_id ' ||
      '                , ILV.trans_detail_object_id ' ||
      '                , ILV.WIN_TERR_ID ' ||
      '           FROM ( SELECT trans_object_id ' ||
      '                       , trans_detail_object_id ' ||
      '                       , WIN_TERR_ID WIN_TERR_ID ' ||
      '                  FROM ' || l_L2_target ||
      '                  WHERE WORKER_ID = :bv_worker_id ' ||
      '                  MINUS ' ||
      '                  SELECT trans_object_id ' ||
      '                       , trans_detail_object_id ' ||
      '                       , ul_terr_id WIN_TERR_ID ' ||
      '                  FROM ' || l_L3_target ||
      '                  WHERE WORKER_ID = :bv_worker_id ' ||
      '               ) ILV ' ||

      '           UNION ALL ' ||

      '           SELECT ILV.trans_object_id ' ||
      '                , ILV.trans_detail_object_id ' ||
      '                , ILV.WIN_TERR_ID ' ||
      '           FROM ( SELECT trans_object_id ' ||
      '                       , trans_detail_object_id ' ||
      '                       , WIN_TERR_ID WIN_TERR_ID ' ||
      '                  FROM ' || l_L3_target ||
      '                  WHERE WORKER_ID = :bv_worker_id ' ||
      '                  MINUS ' ||
      '                  SELECT trans_object_id ' ||
      '                       , trans_detail_object_id ' ||
      '                       , ul_terr_id WIN_TERR_ID ' ||
      '                  FROM ' || l_L4_target ||
      '                  WHERE WORKER_ID = :bv_worker_id ' ||
      '               ) ILV ' ||

      '           UNION ALL ' ||

      '           SELECT ILV.trans_object_id ' ||
      '                , ILV.trans_detail_object_id ' ||
      '                , ILV.WIN_TERR_ID ' ||
      '           FROM  ( SELECT trans_object_id ' ||
      '                       , trans_detail_object_id ' ||
      '                       , WIN_TERR_ID WIN_TERR_ID ' ||
      '                  FROM ' || l_L4_target ||
      '                  WHERE WORKER_ID = :bv_worker_id ' ||
      '                  MINUS ' ||
      '                  SELECT trans_object_id ' ||
      '                       , trans_detail_object_id ' ||
      '                       , ul_terr_id WIN_TERR_ID ' ||
      '                  FROM ' || l_L5_target ||
      '                  WHERE WORKER_ID = :bv_worker_id ' ||
      '               ) ILV ' ||

      '           UNION ALL ' ||

      '           SELECT ILV.trans_object_id ' ||
      '                , ILV.trans_detail_object_id ' ||
      '                , ILV.WIN_TERR_ID ' ||
      '           FROM ( SELECT trans_object_id ' ||
      '                       , trans_detail_object_id ' ||
      '                       , WIN_TERR_ID WIN_TERR_ID ' ||
      '                  FROM ' || l_L5_target ||
      '                  WHERE WORKER_ID = :bv_worker_id ' ||
      '                  MINUS ' ||
      '                  SELECT trans_object_id ' ||
      '                       , trans_detail_object_id ' ||
      '                       , ul_terr_id WIN_TERR_ID ' ||
      '                  FROM ' || l_WT_target ||
      '                  WHERE WORKER_ID = :bv_worker_id ' ||
      '               ) ILV ' ||

      '           UNION ALL ' ||

      '           SELECT trans_object_id ' ||
      '                , trans_detail_object_id ' ||
      '                , WIN_TERR_ID ' ||
      '           FROM ' || l_WT_target ||
      '           WHERE WORKER_ID = :bv_worker_id ' ||

      '       ) WINNERS ' ||
      ' ) ';

    BEGIN

      EXECUTE IMMEDIATE l_dyn_str USING
                    p_worker_id               /* :bv_worker_id */
                  , lp_sysdate               /* :BV1_LAST_UPDATE_DATE */
                  , G_USER_ID                /* :BV1_LAST_UPDATED_BY */
                  , lp_sysdate               /* :BV1_CREATION_DATE */
                  , G_USER_ID                /* :BV1_CREATED_BY */
                  , G_LOGIN_ID               /* :BV1_LAST_UPDATE_LOGIN */
                  , G_REQUEST_ID              /* :BV1_REQUEST_ID */
                  , G_APPL_ID                 /* :BV1_PROGRAM_APPLICATION_ID */
                  , G_PROGRAM_ID              /* :BV1_PROGRAM_ID */
                  , lp_sysdate                /* :BV1_PROGRAM_UPDATE_DATE */
                  , p_worker_id               /* :bv_worker_id */ --1
                  , p_worker_id               /* :bv_worker_id */
                  , p_worker_id               /* :bv_worker_id */
                  , p_worker_id               /* :bv_worker_id */
                  , p_worker_id               /* :bv_worker_id */ --5
                  , p_worker_id               /* :bv_worker_id */
                  , p_worker_id               /* :bv_worker_id */
                  , p_worker_id               /* :bv_worker_id */
                  , p_worker_id               /* :bv_worker_id */
                  , p_worker_id               /* :bv_worker_id */ --10
                  , p_worker_id;              /* :bv_worker_id */

        jty_log(FND_LOG.LEVEL_STATEMENT,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.winner_num_row',
                       'Number of records inserted into ' || l_winner_target || ' for worker_id : ' || p_worker_id || ' : ' || SQL%ROWCOUNT);

      COMMIT;  -- after modifying table in parallel

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    l_dyn_str :=
      ' INSERT INTO ' || l_winner_target || ' i ' ||
      ' ( ' ||
      ' 	 TRANS_OBJECT_ID        ' ||
      ' 	,TRANS_DETAIL_OBJECT_ID ' ||
      ' 	,WORKER_ID ' ||
      ' 	,SOURCE_ID              ' ||
      ' 	,TRANS_OBJECT_TYPE_ID   ' ||
      ' 	,LAST_UPDATE_DATE       ' ||
      ' 	,LAST_UPDATED_BY        ' ||
      ' 	,CREATION_DATE          ' ||
      ' 	,CREATED_BY             ' ||
      '	    ,LAST_UPDATE_LOGIN      ' ||
      '	    ,REQUEST_ID             ' ||
      '	    ,PROGRAM_APPLICATION_ID ' ||
      '	    ,PROGRAM_ID             ' ||
      '	    ,PROGRAM_UPDATE_DATE    ' ||
      '	    ,TERR_ID                ' ||
      '	    ,ABSOLUTE_RANK          ' ||
      '	    ,TOP_LEVEL_TERR_ID      ' ||
      '	    ,RESOURCE_ID            ' ||
      '	    ,RESOURCE_TYPE          ' ||
      '	    ,GROUP_ID               ' ||
      '	    ,ROLE_ID                ' ||
      '	    ,ROLE                   ' ||
      '	    ,PRIMARY_CONTACT_FLAG   ' ||
      '	    ,PERSON_ID              ' ||
      '	    ,ORG_ID                 ' ||
      '	    ,TERR_RSC_ID            ' ||
      '	    ,FULL_ACCESS_FLAG       ' ||
      ' ) ' ||
      ' ( ' ||
      '  SELECT ' ||  -- DISTINCT ' ||
      '      WINNERS.trans_object_id         ' ||
      '    , WINNERS.trans_detail_object_id  ' ||
      '    , :bv_worker_id ' || --p_worker_id ||
      '    , :BV1_SOURCE_ID                 ' ||
      '    , :BV1_TRANS_OBJECT_TYPE_ID      ' ||
      '    , :BV1_LAST_UPDATE_DATE          ' ||
      '    , :BV1_LAST_UPDATED_BY           ' ||
      '    , :BV1_CREATION_DATE             ' ||
      '    , :BV1_CREATED_BY                ' ||
      '    , :BV1_LAST_UPDATE_LOGIN         ' ||
      '    , :BV1_REQUEST_ID                ' ||
      '    , :BV1_PROGRAM_APPLICATION_ID    ' ||
      '    , :BV1_PROGRAM_ID                ' ||
      '    , :BV1_PROGRAM_UPDATE_DATE       ' ||
      '    , WINNERS.terr_id                ' ||
      '    , null absolute_rank             ' ||  /*  o_dttm.absolute_rank     ' || */
      '    , null top_level_terr_id         ' ||  /*  o_dttm.top_level_terr_id ' || */
      '    , jtr.resource_id                ' ||
      '    , jtr.resource_type              ' ||
      '    , jtr.group_id                   ' ||
      '    , inv.role_id                    ' ||
      '    , jtr.role                       ' ||
      '    , jtr.primary_contact_flag       ' ||
      '    , jtr.PERSON_ID                  ' ||
      '    , jtr.org_id                     ' ||
      '    , jtr.terr_rsc_id                ' ||
      '    , decode(jtra.trans_access_code, ''FULL_ACCESS'', ''Y'', ''N'') ' ||
      '  FROM ( /* WINNERS ILV */ ' ||
      '           SELECT a.trans_object_id ' ||
      '                , a.trans_detail_object_id ' ||
      '                , b.TERR_ID ' ||
      '                , a.txn_date ' ||
      '           FROM ' || l_mp_winner_target || ' a, ' || l_uwinner_target || ' b ' ||
      '           WHERE b.WORKER_ID = :bv_worker_id ' ||
      '           AND   a.link = b.trans_object_id ' ||
      '       ) WINNERS ' ||
      '     , jtf_terr_rsc_all jtr ' ||
      '     , jtf_terr_rsc_access_all jtra ' ||
      '     , jtf_qual_types_all jqta ' ||
      '     , (SELECT ' ||
      '          max(role_id) role_id  ' ||
      '         ,role_code    role_code ' ||
      '        FROM jtf_rs_roles_b ' ||
      '        GROUP BY role_code ) inv  ' ||
      '  WHERE  WINNERS.terr_id = jtr.terr_id ' ||
      '  AND jtr.end_date_active >= WINNERS.txn_date ' ||
      '  AND jtr.start_date_active <= WINNERS.txn_date ' ||
      '  AND jtr.resource_type <> ''RS_ROLE'' ' ||
      '  AND jtr.terr_rsc_id = jtra.terr_rsc_id ' ||
      '  AND jtr.role = inv.role_code(+) ' ||
      '  AND jtra.access_type =  jqta.name ' ||
      '  AND jtra.trans_access_code <> ''NONE'' ' ||
      '  AND jqta.qual_type_id = :bv_trans_id ' ||
      ' ) ';

    BEGIN

      EXECUTE IMMEDIATE l_dyn_str USING
                    p_worker_id               /* :bv_worker_id */
                  , p_source_id              /* :BV1_SOURCE_ID */
                  , p_trans_id                /* :BV1_TRANS_OBJECT_TYPE_ID */
                  , lp_sysdate               /* :BV1_LAST_UPDATE_DATE */
                  , G_USER_ID                /* :BV1_LAST_UPDATED_BY */
                  , lp_sysdate               /* :BV1_CREATION_DATE */
                  , G_USER_ID                /* :BV1_CREATED_BY */
                  , G_LOGIN_ID               /* :BV1_LAST_UPDATE_LOGIN */
                  , G_REQUEST_ID              /* :BV1_REQUEST_ID */
                  , G_APPL_ID                 /* :BV1_PROGRAM_APPLICATION_ID */
                  , G_PROGRAM_ID              /* :BV1_PROGRAM_ID */
                  , lp_sysdate                /* :BV1_PROGRAM_UPDATE_DATE */
                  , p_worker_id               /* :bv_worker_id */ --1
                  , p_trans_id;

        jty_log(FND_LOG.LEVEL_STATEMENT,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.winner_num_row',
                       'Number of records inserted into ' || l_winner_target || ' for worker_id : ' || p_worker_id || ' : ' || SQL%ROWCOUNT);

      COMMIT;  -- after modifying table in parallel

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  END IF; /* end IF (l_multi_level_winning_flag <> 'Y') */

END IF; -- End of loop for p_OIC_mode check

IF p_oic_mode = 'WINNER/POST' OR p_oic_mode = 'NOOIC'
THEN
  /* Analyze Winners table */
  JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
       p_table_name    => l_winner_target
     , p_percent       => p_percent_analyzed
     , x_return_status => x_return_status );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_msg_data := 'API JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX has failed for ' || l_winner_target;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.winner_analyze',
                     x_msg_data);
    RAISE  FND_API.G_EXC_ERROR;
  END IF;
END IF;

  /* Program completed successfully */
  ERRBUF := null;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  RETCODE := 0;

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winner.end',
                   'End of the procedure JTY_ASSIGN_BULK_PUB.process_winner ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN L_SCHEMA_NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := 'Schema name corresponding to the FND application not found';
    RETCODE := 2;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winner.l_schema_notfound',
                     x_msg_data);

  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RETCODE := 2;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winner.no_data_found',
                     x_msg_data);

  WHEN L_NO_MATCH_TERR THEN
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winner.l_no_match_terr',
                     x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RETCODE := 2;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winner.g_exc_error',
                     x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_winner.other',
                     substr(x_msg_data, 1, 4000));

END process_winners;


-- ***************************************************
--    API Specifications
-- ***************************************************
--    api name       : process_match
--    type           : private.
--    function       :
--    pre-reqs       :
--    notes:  API designed to get the matching territories for the
--            transaction objs, it supports multiple worker architecture
--
PROCEDURE process_match
    ( p_source_id             IN          NUMBER,
      p_trans_id              IN          NUMBER,
      p_program_name          IN          VARCHAR2,
      p_mode                  IN          VARCHAR2,
      p_percent_analyzed      IN          NUMBER,
      p_worker_id             IN          NUMBER,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      ERRBUF                  OUT NOCOPY  VARCHAR2,
      RETCODE                 OUT NOCOPY  VARCHAR2,
      p_oic_mode              IN VARCHAR2,
	  p_terr_id               IN          NUMBER
    ) AS

  l_trans_target   VARCHAR2(40);
  l_match_target   VARCHAR2(40);
  l_sql_stmt       VARCHAR2(200);
  l_no_of_records  NUMBER;
  l_match_sql      VARCHAR2(32767);
  l_sysdate        DATE;

  CURSOR c_get_qualrel_prod(cl_source_id number, cl_trans_id number) IS
  SELECT jtqp.relation_product
  FROM   jtf_tae_qual_products  jtqp
  WHERE  jtqp.source_id = cl_source_id
  AND    jtqp.trans_object_type_id = cl_trans_id
  ORDER BY jtqp.relation_product DESC;

  CURSOR c_dea_get_qualrel_prod(cl_source_id number, cl_trans_id number) IS
  SELECT jtqp.attr_relation_product
  FROM   jty_dea_attr_products  jtqp
  WHERE  jtqp.source_id = cl_source_id
  AND    jtqp.trans_type_id = cl_trans_id
  ORDER BY jtqp.attr_relation_product DESC;

BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_match.start',
                   'Start of the procedure JTY_ASSIGN_BULK_PUB.process_match ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_sysdate := SYSDATE;

  BEGIN
    SELECT  decode(p_mode, 'TOTAL', tup.batch_trans_table_name
                         , 'INCREMENTAL', tup.batch_nm_trans_table_name
                         , 'DATE EFFECTIVE', tup.batch_dea_trans_table_name)
           ,batch_match_table_name
    INTO    l_trans_target
           ,l_match_target
    FROM    jty_trans_usg_pgm_details tup
    WHERE   tup.source_id     = p_source_id
    AND     tup.trans_type_id = p_trans_id
    AND     tup.program_name  = p_program_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_msg_data := 'No row in jty_trans_usg_pgm_details corresponding to usage : ' || p_source_id || ' transaction : ' || p_trans_id ||
                    ' program name : ' || p_program_name;
      RAISE;
  END;

IF p_oic_mode = 'NOOIC' OR p_oic_mode = 'MATCH/POPULATE'
THEN

  l_sql_stmt := 'SELECT COUNT(*) FROM ' || l_trans_target || ' WHERE worker_id = :bv_worker_id';
  EXECUTE IMMEDIATE l_sql_stmt INTO l_no_of_records USING p_worker_id;

  IF (l_no_of_records <= 0) THEN
    x_msg_data := 'No row in ' || l_trans_target || ' for worker_id = ' || p_worker_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETCODE := 0;
    x_msg_count := 1;
    ERRBUF := null;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_mode = 'DATE EFFECTIVE') THEN
  IF p_terr_id is NULL THEN
      FOR jtf_csr IN c_dea_get_qualrel_prod(p_source_id, p_trans_id) LOOP
        BEGIN
          SELECT batch_dea_match_sql
          INTO   l_match_sql
          FROM   jty_dea_attr_products_sql
          WHERE  source_id = p_source_id
          AND    trans_type_id = p_trans_id
          AND    program_name = p_program_name
          AND    attr_relation_product = jtf_csr.attr_relation_product;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_msg_data := 'No matching SQL found corresponding to source : ' || p_source_id || ' trans : ' || p_trans_id ||
                          ' Program name : ' || p_program_name || ' relation product : ' || jtf_csr.attr_relation_product;
          RAISE;
        END;

        EXECUTE IMMEDIATE l_match_sql USING l_sysdate, g_user_id, l_sysdate, g_user_id, g_user_id, g_request_id,
                                            g_appl_id, g_program_id, l_sysdate, p_worker_id;
         jty_log(FND_LOG.LEVEL_STATEMENT,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_match.dea_match',
                       'Number of records inserted for qualifier combination ' || jtf_csr.attr_relation_product || ' : ' || SQL%ROWCOUNT);

      END LOOP;
    ELSIF p_terr_id IS NOT NULL THEN
         FOR jtf_csr IN c_dea_get_qualrel_prod(p_source_id, p_trans_id) LOOP
              BEGIN
                SELECT batch_dea_match_sql_with_terr
                INTO   l_match_sql
                FROM   jty_dea_attr_products_sql
                WHERE  source_id = p_source_id
                AND    trans_type_id = p_trans_id
                AND    program_name = p_program_name
                AND    attr_relation_product = jtf_csr.attr_relation_product;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  x_msg_data := 'No matching SQL found corresponding to source : ' || p_source_id || ' trans : ' || p_trans_id ||
                                ' Program name : ' || p_program_name || ' relation product : ' || jtf_csr.attr_relation_product;
                RAISE;
              END;

              EXECUTE IMMEDIATE l_match_sql USING l_sysdate, g_user_id, l_sysdate, g_user_id, g_user_id, g_request_id,
                                                  g_appl_id, g_program_id, l_sysdate, p_worker_id, p_terr_id;
            jty_log(FND_LOG.LEVEL_STATEMENT,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_match.dea_match',
                       'Number of records inserted for qualifier combination ' || jtf_csr.attr_relation_product || ' : ' || SQL%ROWCOUNT);

        END LOOP;
    END IF;
  ELSIF ((p_mode = 'TOTAL') OR (p_mode = 'INCREMENTAL')) THEN

    FOR jtf_csr IN c_get_qualrel_prod(p_source_id, p_trans_id) LOOP
      BEGIN
        SELECT decode(p_mode, 'TOTAL', batch_match_sql, 'INCREMENTAL', batch_nm_match_sql)
        INTO   l_match_sql
        FROM   jty_tae_attr_products_sql
        WHERE  source_id = p_source_id
        AND    trans_type_id = p_trans_id
        AND    program_name = p_program_name
        AND    attr_relation_product = jtf_csr.relation_product;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_msg_data := 'No matching SQL found corresponding to source : ' || p_source_id || ' trans : ' || p_trans_id ||
                        ' Program name : ' || p_program_name || ' relation product : ' || jtf_csr.relation_product;
        RAISE;
      END;

      EXECUTE IMMEDIATE l_match_sql USING l_sysdate, g_user_id, l_sysdate, g_user_id, g_user_id, g_request_id,
                                          g_appl_id, g_program_id, l_sysdate, p_worker_id;
      -- debug message
        jty_log(FND_LOG.LEVEL_STATEMENT,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_match.match',
                       'Number of records inserted for qualifier combination ' || jtf_csr.relation_product || ' : ' || SQL%ROWCOUNT);
    END LOOP;

  END IF;
END IF; -- End of addition for p_oic_mode check

IF p_oic_mode = 'MATCH/POST' or p_oic_mode ='NOOIC'
THEN
  JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX(
      p_table_name    => l_match_target
    , p_percent       => p_percent_analyzed
    , x_return_status => x_return_status );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_match.analyze_match',
                     'JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API has failed for table : ' || l_match_target);

    RAISE	FND_API.G_EXC_ERROR;
    RETCODE := 2;
    x_msg_count := 1;
    x_msg_data := 'JTY_TAE_INDEX_CREATION_PVT.ANALYZE_TABLE_INDEX API has failed for table : ' || l_match_target;
    errbuf := x_msg_data;
  END IF;
END IF;
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_match.end',
                   'End of the procedure JTY_ASSIGN_BULK_PUB.process_match ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RETCODE := 2;
    x_msg_count := 1;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_match.no_data_found',
                     x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_match.g_exc_error',
                     x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.process_match.other',
                     substr(x_msg_data, 1, 4000));

END process_match;

-- ***************************************************
--    API Specifications
-- ***************************************************
--    api name       : get_winners
--    type           : public.
--    function       :
--    pre-reqs       :
--    notes:  API designed to get the winning territories for the
--            transaction objs, it supports multiple worker architecture
--
PROCEDURE get_winners
    ( p_api_version_number    IN          NUMBER,
      p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
      p_source_id             IN          NUMBER,
      p_trans_id              IN          NUMBER,
      p_program_name          IN          VARCHAR2,
      p_mode                  IN          VARCHAR2,
      p_percent_analyzed      IN          NUMBER,
      p_worker_id             IN          NUMBER,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2,
      ERRBUF                  OUT NOCOPY  VARCHAR2,
      RETCODE                 OUT NOCOPY  VARCHAR2,
      p_oic_mode              IN          VARCHAR2 DEFAULT 'NOOIC',
	  p_terr_id               IN          NUMBER DEFAULT NULL
    ) AS

  l_api_name                   CONSTANT VARCHAR2(30) := 'get_winners';
  l_api_version_number         CONSTANT NUMBER       := 1.0;

BEGIN

  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.start',
                   'Start of the procedure JTY_ASSIGN_BULK_PUB.get_winners ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

  /* Standard call to check for call compatibility. */
  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME)  THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Initialize message list if p_init_msg_list is set to TRUE. */
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- debug message
    jty_log(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.param_value',
                   'Source : ' || p_source_id || ' Trans : ' || p_trans_id || ' Program Name : ' || p_program_name ||
                   ' Mode : ' || p_mode || ' Worker : ' || p_worker_id);

  IF p_oic_mode = 'NOOIC' OR p_oic_mode = 'MATCH/POPULATE' OR p_oic_mode = 'MATCH/POST'
  THEN
      /* Find out the matching territories corresponding to the txn objects */
      process_match (
        p_source_id        => p_source_id,
        p_trans_id         => p_trans_id,
        p_program_name     => p_program_name,
        p_mode             => p_mode,
        p_percent_analyzed => p_percent_analyzed,
        p_worker_id        => p_worker_id,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        errbuf             => errbuf,
        retcode            => retcode,
        p_oic_mode         => p_oic_mode,
		p_terr_id          => p_terr_id);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        -- debug message
          jty_log(FND_LOG.LEVEL_EXCEPTION,
                         'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.match',
                         'process_match API has failed for source : ' || p_source_id || ' trans : ' || p_trans_id ||
                         ' program name : ' || p_program_name);

        RAISE	FND_API.G_EXC_ERROR;
      END IF;
  -- debug message
    jty_log(FND_LOG.LEVEL_EVENT,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.end_match',
                   'Matching process completed successfully');
  END IF;

  IF p_oic_mode = 'NOOIC' OR p_oic_mode = 'WINNER/POPULATE' OR p_oic_mode = 'WINNER/POST'
  THEN
      /* Find out the winning territories corresponding to the txn objects */
      process_winners (
        p_source_id        => p_source_id,
        p_trans_id         => p_trans_id,
        p_program_name     => p_program_name,
        p_mode             => p_mode,
        p_percent_analyzed => p_percent_analyzed,
        p_worker_id        => p_worker_id,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        errbuf             => errbuf,
        retcode            => retcode,
        p_oic_mode         => p_oic_mode);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        -- debug message
          jty_log(FND_LOG.LEVEL_EXCEPTION,
                         'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.winner',
                         'process_winners API has failed for source : ' || p_source_id || ' trans : ' || p_trans_id ||
                         ' program name : ' || p_program_name);

        RAISE	FND_API.G_EXC_ERROR;
      END IF;

      -- debug message
        jty_log(FND_LOG.LEVEL_EVENT,
                       'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.end_winner',
                       'Winner process completed successfully');
  END IF;
  -- debug message
    jty_log(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.end',
                   'End of the procedure JTY_ASSIGN_BULK_PUB.get_winners ' || to_char(sysdate,'dd-mm-rrrr HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RETCODE := 2;
    x_msg_count := 1;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.g_exc_error',
                     x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    RETCODE := 2;
    ERRBUF := x_msg_data;
      jty_log(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_ASSIGN_BULK_PUB.get_winners.other',
                     substr(x_msg_data, 1, 4000));

END get_winners;

END JTY_ASSIGN_BULK_PUB;

/
