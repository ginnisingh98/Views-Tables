--------------------------------------------------------
--  DDL for Package Body OKI_DBI_SCM_RSG_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_SCM_RSG_API_PVT" AS
/*$Header: OKIMVIMB.pls 120.2 2005/06/14 19:13:02 appldev  $*/

PROCEDURE Oki_Custom_Api(p_param IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL) IS

  l_api_type			VARCHAR2(300);
  l_mode			VARCHAR2(300);
  l_obj_name 			VARCHAR2(300);
  l_retcode			NUMBER		:= 0;
  l_version			VARCHAR2(20);

BEGIN -- Oki_Custom_Api;

  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Inside OKI Custom API');

  /* Conform to Standard 2. Retrieving Parameters API_TYPE, MODE, OBJECT_NAM, OBJECT_TYPE */
  l_api_type := BIS_BIA_RSG_CUSTOM_API_MGMNT.Get_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Api_Type);
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Got value for '|| BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Api_Type||': '|| l_api_type);

  l_mode := BIS_BIA_RSG_CUSTOM_API_MGMNT.Get_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Mode);
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Got value for '|| BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Mode||': '|| l_mode);

  l_obj_name := BIS_BIA_RSG_CUSTOM_API_MGMNT.Get_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Object_Name);
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Got value for '|| BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Object_Name||': '|| l_obj_name);

--  g_mv_refresh_method
--     := BIS_BIA_RSG_CUSTOM_API_MGMNT.Get_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Mv_Refresh_Method);
--  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Got value for '|| BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Mv_Refresh_Method|| ': '|| g_mv_refresh_method);

  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('');
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('-------------------------');
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Start of Manage_Oki_Index');

  /** Performing Custom Actions based on the API type and calling mode**/
  IF (l_api_type = BIS_BIA_RSG_CUSTOM_API_MGMNT.Type_Mv_Log_Mgt) THEN
    NULL; --MANAGE_LOG(l_mode, l_obj_name);
  ELSIF (l_api_type = BIS_BIA_RSG_CUSTOM_API_MGMNT.Type_Mv_Index_Mgt) THEN
--only manage indexes if db version is older than 10G
    SELECT version
      INTO l_version
      FROM v$instance;

    IF substr(l_version,1,3) = '10.' THEN
      BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('The database version is '||l_version||' so no need for index management');
    ELSE
      BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('The database version is '||l_version||' so proceed with index management');
      Manage_Oki_Index(l_mode, l_obj_name, l_retcode);
    END IF;
  ELSIF (l_api_type = BIS_BIA_RSG_CUSTOM_API_MGMNT.Type_Mv_Threshold) THEN
    NULL; --MANAGE_MV_THRESHOLD(L_MODE, L_OBJ_NAME);
  END IF;

  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('End of Manage_Oki_Index at '|| FND_DATE.Date_To_DisplayDt(sysdate));
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('-------------------------');
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('');

  COMMIT;

  /* Conform to Standard 3. Setting Complete Status and Message */
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Set_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Complete_Status, BIS_BIA_RSG_CUSTOM_API_MGMNT.Status_Success);

  BIS_BIA_RSG_CUSTOM_API_MGMNT.Set_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Message, 'Succeeded');

EXCEPTION
  WHEN OTHERS THEN
  /* Conform to Standard 6. Error Handling */
    BIS_BIA_RSG_CUSTOM_API_MGMNT.Set_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Complete_Status,BIS_BIA_RSG_CUSTOM_API_MGMNT.Status_Failure);
    BIS_BIA_RSG_CUSTOM_API_MGMNT.Set_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Message, sqlerrm);
    RAISE;

END Oki_Custom_Api;



PROCEDURE Manage_Oki_Index(p_mode VARCHAR2, p_obj_name VARCHAR2 , p_retcode IN OUT NOCOPY NUMBER) IS
   l_owner VARCHAR2(100);
    l_status      VARCHAR2(30) ;
    l_industry    VARCHAR2(30) ;

BEGIN -- Manage_Oki_Index

   IF (FND_INSTALLATION.GET_APP_INFO(
              application_short_name => 'OKI'
            , status                 => l_status
            , industry               => l_industry
            , oracle_schema          => l_owner)) THEN

      IF (p_mode = 'BEFORE') THEN
          OKI_DBI_SCM_RSG_API_PVT.Drop_Index(p_obj_name,l_owner, p_retcode);
      ELSIF (p_mode = 'AFTER') THEN
          BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Creating the column indexes at '|| FND_DATE.Date_To_DisplayDt(sysdate));
          OKI_DBI_SCM_RSG_API_PVT.Create_Index(p_obj_name, l_owner, p_retcode);
          BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Finished creating the column indexes at '|| FND_DATE.Date_To_DisplayDt(sysdate));
      END IF;

      COMMIT;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    BIS_BIA_RSG_CUSTOM_API_MGMNT.Log(sqlerrm);
    RAISE;

END Manage_Oki_Index;



PROCEDURE Drop_Index (
        p_table_name			VARCHAR2,
        p_owner                         VARCHAR2,
        p_retcode	IN OUT NOCOPY	NUMBER) IS

  errbuf		VARCHAR2(200)		:= NULL;
  l_index_exists	NUMBER			:= 0;
  l_rows		NUMBER			:= 0;

  CURSOR c_oki_idx IS
  SELECT *
    FROM oki_dbi_indexes
   WHERE table_name = p_table_name;

  CURSOR c_idx  IS
  SELECT index_name
    FROM all_indexes
   WHERE table_name = p_table_name
   AND OWNER = p_owner;

BEGIN

 -- BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Check if index exists, if not then they have already been dropped');

  SELECT count(1)
    INTO l_index_exists
    FROM all_indexes
   WHERE table_name = p_table_name
   AND OWNER = p_owner;

  SELECT count(1)
    INTO l_rows
    FROM oki_dbi_indexes
   WHERE table_name = p_table_name;

  IF (l_index_exists = 0) THEN
     -- index do not exist , so no action
     -- if no information exists to recreate them, provide message
    IF (l_rows = 0) THEN
      BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Indexes do not exist and no information found to create them, so please create manually or re-apply the XDF for MV: '|| p_table_name);
    ELSE
      BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Indexes do not exist but found information to create them');
    END IF; -- (l_rows = 0) THEN
  ELSE

   -- If all_indexes has index details
   --   Update oki_dbi_indexes with latest index information
    BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Inserting Index definitions into oki_dbi_indexes - '
                                        || FND_DATE.Date_To_DisplayDt(sysdate));
     MERGE INTO OKI_DBI_INDEXES b
      USING ( select table_name, index_name from all_indexes
              where table_name = p_table_name AND OWNER = p_owner ) s
      ON (b.index_name = s.index_name AND b.table_name = s.table_name)
      WHEN MATCHED THEN
         UPDATE
           SET create_stmt = DBMS_METADATA.Get_Ddl('INDEX', s.index_name)
      WHEN NOT MATCHED THEN
         INSERT
            (table_name,
             index_name,
             create_stmt,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login)
          VALUES
          (p_table_name,
           s.index_name,
           DBMS_METADATA.Get_Ddl('INDEX', s.index_name),
           SYSDATE,
           -1,
           SYSDATE,
           -1,
           -1);

      COMMIT;
       BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('FINISHED: Inserting Index definitions into oki_dbi_indexes for - '|| p_table_name
                                        || ',  ' || FND_DATE.Date_To_DisplayDt(sysdate));

       -- Once all indexes are stored in oki_dbi_indexes
       -- drop all the existing indexes of MV from the DB
       FOR i IN c_idx LOOP
          EXECUTE IMMEDIATE 'DROP INDEX ' || i.index_name;
          BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Dropped index: '|| i.index_name);
       END LOOP;
   END IF;   -- End  l_index_exists=0

EXCEPTION
  WHEN OTHERS THEN
    errbuf := substr(sqlerrm,1,200);
    p_retcode := sqlcode;
    BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('ERROR in Drop_Index--> ' || p_retcode || ':' || errbuf);
    BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('-----------------------------');
    RAISE;

END Drop_Index;



PROCEDURE Create_index(
	p_table_name			VARCHAR2,
        p_owner                         VARCHAR2,
	p_retcode	IN OUT NOCOPY	NUMBER) IS

  l_create_stmt		VARCHAR2(32000)		:= NULL;
  l_mod_create_stmt	VARCHAR2(32000)		:= NULL;
  errbuf		VARCHAR2(200);

  CURSOR c_oki_idx IS
    SELECT index_name,
           create_stmt
      FROM oki_dbi_indexes
     WHERE table_name = p_table_name;

  CURSOR c_idx IS
    SELECT index_name
      FROM all_indexes
     WHERE table_name like p_table_name
     AND OWNER = p_owner   ;

BEGIN

  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('');
  FOR i IN c_oki_idx LOOP
    l_create_stmt := i.create_stmt;

    IF(INSTR(l_create_stmt,'NOLOGGING') > 0) THEN
      l_mod_create_stmt := l_create_stmt;
    ELSIF(INSTR(l_create_stmt,'LOGGING') > 0) THEN
      l_mod_create_stmt := REPLACE(l_create_stmt,'LOGGING','NOLOGGING');
    ELSE
      l_mod_create_stmt := l_create_stmt || ' NOLOGGING';
    END IF;

    IF(INSTR(l_mod_create_stmt,'NOPARALLEL') > 0) THEN
      l_mod_create_stmt := replace(l_mod_create_stmt,'NOPARALLEL','PARALLEL');
    ELSIF(INSTR(l_mod_create_stmt,'PARALLEL') <= 0) THEN
      l_mod_create_stmt := l_mod_create_stmt || ' PARALLEL';
    END IF;

    BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Starting to create index '||i.index_name||' from oki_dbi_indexes at: '|| FND_DATE.Date_To_DisplayDt(sysdate));
    EXECUTE IMMEDIATE l_mod_create_stmt;
    BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('  Created index '||i.index_name||' at: '|| FND_DATE.Date_To_DisplayDt(sysdate));
    BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('');

    EXECUTE IMMEDIATE 'ALTER INDEX '||i.index_name||' LOGGING NOPARALLEL';

  END LOOP;

  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Indexes created at '||FND_DATE.Date_To_DisplayDt(sysdate));
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Cleaning the table oki_dbi_indexes for indexes of '||p_table_name);

  DELETE FROM oki_dbi_indexes
   WHERE table_name = p_table_name;
  COMMIT;
 --  raise_application_error(-20101, 'After Create index - Check Fail after clean up');

EXCEPTION
  WHEN OTHERS THEN
    errbuf := substr(sqlerrm,1,200);
    p_retcode := sqlcode;
    BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('ERROR in Create_Index--> ' || p_retcode || ':' || errbuf);
    BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Failing Statement: ' || l_mod_create_stmt);
    BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('-----------------------------');
    RAISE;

END Create_Index;

PROCEDURE sleep(p_param IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL) IS

  l_api_type			VARCHAR2(300);
  l_mode			VARCHAR2(300);
  l_obj_name 			VARCHAR2(300);
  l_retcode			NUMBER		:= 0;
  l_version			VARCHAR2(20);
  l_mv_refresh_method VARCHAR2(50);

BEGIN -- Oki_Custom_Api;

  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Inside OKI Custom API - Sleep');

  /* Conform to Standard 2. Retrieving Parameters API_TYPE, MODE, OBJECT_NAM, OBJECT_TYPE */
  l_api_type := BIS_BIA_RSG_CUSTOM_API_MGMNT.Get_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Api_Type);
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Got value for '|| BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Api_Type||': '|| l_api_type);

  l_mode := BIS_BIA_RSG_CUSTOM_API_MGMNT.Get_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Mode);
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Got value for '|| BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Mode||': '|| l_mode);

  l_obj_name := BIS_BIA_RSG_CUSTOM_API_MGMNT.Get_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Object_Name);
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Got value for '|| BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Object_Name||': '|| l_obj_name);

  l_mv_refresh_method
     := BIS_BIA_RSG_CUSTOM_API_MGMNT.Get_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Mv_Refresh_Method);
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Got value for '|| BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Mv_Refresh_Method|| ': '|| l_mv_refresh_method);

  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('');
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('-------------------------');
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('Start of Sleep at '|| FND_DATE.Date_To_DisplayDt(sysdate));

  IF l_mode = 'BEFORE'
  THEN
     dbms_lock.sleep(10);
  END IF;

  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('End of Sleep at '|| FND_DATE.Date_To_DisplayDt(sysdate));
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('-------------------------');
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Log('');

  COMMIT;

  /* Conform to Standard 3. Setting Complete Status and Message */
  BIS_BIA_RSG_CUSTOM_API_MGMNT.Set_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Complete_Status, BIS_BIA_RSG_CUSTOM_API_MGMNT.Status_Success);

  BIS_BIA_RSG_CUSTOM_API_MGMNT.Set_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Message, 'Succeeded');

EXCEPTION
  WHEN OTHERS THEN
  /* Conform to Standard 6. Error Handling */
    BIS_BIA_RSG_CUSTOM_API_MGMNT.Set_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Complete_Status,BIS_BIA_RSG_CUSTOM_API_MGMNT.Status_Failure);
    BIS_BIA_RSG_CUSTOM_API_MGMNT.Set_Param(p_param, BIS_BIA_RSG_CUSTOM_API_MGMNT.Para_Message, sqlerrm);
    RAISE;

END sleep;
END; -- OKI_DBI_SCM_RSG_API_PVT

/
