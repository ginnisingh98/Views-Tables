--------------------------------------------------------
--  DDL for Package Body RRS_SITE_UDA_BULKLOAD_INTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_SITE_UDA_BULKLOAD_INTF" AS
/* $Header: RRSIMPUB.pls 120.0.12010000.11 2010/01/25 23:02:21 sunarang noship $*/

  ----------------------------------------------------------------------------
  -- Global constants
  ----------------------------------------------------------------------------
  G_PKG_NAME                          CONSTANT VARCHAR2(30) := 'RRS_SITE_UDA_BULKLOAD_INTF';
  G_REQUEST_ID                        NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  G_PROGAM_APPLICATION_ID             NUMBER := FND_GLOBAL.PROG_APPL_ID;
  G_PROGAM_ID                         NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
  G_USER_NAME                         FND_USER.USER_NAME%TYPE := FND_GLOBAL.USER_NAME;
  G_USER_ID                           NUMBER := FND_GLOBAL.USER_ID;
  G_LOGIN_ID                          NUMBER := FND_GLOBAL.LOGIN_ID;
  G_CURRENT_USER_ID                   NUMBER;
  G_CURRENT_LOGIN_ID                  NUMBER;
  G_API_VERSION                       NUMBER := 1.0;
  G_HZ_PARTY_ID                       VARCHAR2(30);
  G_NO_USER_NAME_TO_VALIDATE          EXCEPTION;
    -- used for error handling.
  G_ADD_ERRORS_TO_FND_STACK           VARCHAR2(1);
  G_APPLICATION_CONTEXT               VARCHAR2(30);
  G_ENTITY_ID                         NUMBER ;
  G_ENTITY_CODE                       VARCHAR2(30) := 'RRS_SITE_UDA';
--    G_PK_COLS_TABLE                     PK_COL_TABLE;
--  G_SITE_NUMBER_EBI_COL               VARCHAR2(50) := 'C_INTF_ATTR240';
  G_DATE_FORMAT                       CONSTANT VARCHAR2(30) := 'SYYYY-MM-DD HH24:MI:SS';

  G_APPLICATION_ID                    NUMBER(3) := 718;
  G_DATA_ROWS_UPLOADED_NEW            CONSTANT NUMBER := 0;
  G_PS_TO_BE_PROCESSED                CONSTANT NUMBER := 1;
  G_PS_IN_PROCESS                     CONSTANT NUMBER := 2;
  G_PS_GENERIC_ERROR                  CONSTANT NUMBER := 3;
  G_PS_SUCCESS                        CONSTANT NUMBER := 4;
  G_RETCODE_SUCCESS_WITH_WARNING      CONSTANT VARCHAR(1) := 'W';

   G_ERROR_TABLE_NAME      VARCHAR2(99) := 'RRS_INTERFACE_ERRORS';
   G_ERROR_ENTITY_CODE     VARCHAR2(99) := 'RRS_SITE_UDA';
   G_ERROR_FILE_NAME       VARCHAR2(99);
   G_BO_IDENTIFIER         VARCHAR2(99) := 'RRS_SITE_UDA';
   G_DEBUG CONSTANT VARCHAR2(10) := NVL(FND_PROFILE.VALUE('RRS_DEBUG_TRACE'),0);

   G_ERRFILE_PATH_AND_NAME VARCHAR2(10000);

   ---------------------------------------------------------------
   -- API Return statuses.                                      --
   ---------------------------------------------------------------
   G_STATUS_SUCCESS    CONSTANT VARCHAR2(1)    := 'S';
   G_STATUS_ERROR      CONSTANT VARCHAR2(1)    := 'E';

   G_RRS_SITE_DATA_LEVEL_ID NUMBER(5) := 71802;
   G_RRS_LOCATION_DATA_LEVEL_ID NUMBER(5) := 71801;
   G_RRS_TRADE_AREA_DATA_LEVEL_ID NUMBER(5) := 71803;

   G_RRS_SITE_DATA_LEVEL VARCHAR2(100) := 'SITE_LEVEL';
   G_RRS_LOCATION_DATA_LEVEL VARCHAR2(100) := 'LOCATION_LEVEL';
   G_RRS_TRADE_AREA_DATA_LEVEL VARCHAR2(100) := 'TRADE_AREA_LEVEL';
   --End of Bug 6493113


/*
FUNCTION RETURN_PROCESS_STATUS RETURN VARCHAR2 IS
 l_status varchar2(10);
BEGIN
 BEGIN
  select distinct process_status
  into l_status
  from rrs_site_ua_intf
  where data_set_id = 10000;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN NULL;
  WHEN TOO_MANY_ROWS THEN NULL;
 END;
  return(l_status);
END;
*/

PROCEDURE Open_Debug_Session IS
BEGIN
  ----------------------------------------------------------------
  -- Open the Debug Log Session, only if Profile is set to TRUE --
  ----------------------------------------------------------------
  IF (G_DEBUG = 1) THEN

   ----------------------------------------------------------------------------------
   -- Opens Error_Handler debug session, only if Debug session is not already open.
   ----------------------------------------------------------------------------------
   IF (Error_Handler.Get_Debug <> 'Y') THEN
     Open_Debug_Session_Internal;
   END IF;
 END IF;
END Open_Debug_Session;

 ----------------------------------------------------------
 -- Internal procedure to open Debug Session.            --
 ----------------------------------------------------------
PROCEDURE open_debug_session_internal IS
  CURSOR c_get_utl_file_dir IS
     SELECT VALUE
      FROM V$PARAMETER
      WHERE NAME = 'utl_file_dir';

  l_log_output_dir       VARCHAR2(512);
  l_log_return_status    VARCHAR2(99);
  l_errbuff              VARCHAR2(999);
BEGIN
  Error_Handler.initialize();
  Error_Handler.set_bo_identifier(G_BO_IDENTIFIER);

  OPEN c_get_utl_file_dir;
  FETCH c_get_utl_file_dir INTO l_log_output_dir;
  IF c_get_utl_file_dir%FOUND THEN
    ------------------------------------------------------
    -- Trim to get only the first directory in the list --
    ------------------------------------------------------
    IF INSTR(l_log_output_dir,',') <> 0 THEN
      l_log_output_dir := SUBSTR(l_log_output_dir, 1, INSTR(l_log_output_dir, ',') - 1);
    END IF;

    G_ERROR_FILE_NAME := G_ERROR_TABLE_NAME||'_'||to_char(sysdate, 'DDMONYYYY_HH24MISS')||'.err';

    -----------------------------------------------------------------------
    -- To open the Debug Session to write the Debug Log.                 --
    -- This sets Debug value so that Error_Handler.Get_Debug returns 'Y' --
    -----------------------------------------------------------------------
    Error_Handler.Open_Debug_Session(
      p_debug_filename   => G_ERROR_FILE_NAME
     ,p_output_dir       => l_log_output_dir
     ,x_return_status    => l_log_return_status
     ,x_error_mesg       => l_errbuff
     );

    ---------------------------------------------------------------
    -- The Java Conc Program Should be writing to the same Error Log File.
    ---------------------------------------------------------------
    G_ERRFILE_PATH_AND_NAME := l_log_output_dir||'/'||G_ERROR_FILE_NAME;

     Write_Conclog('Debug File name is => ' ||	G_ERRFILE_PATH_AND_NAME);

    IF (l_log_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       Write_Conclog('Unable to open error log file. Error => '||l_errbuff);
    END IF;

  END IF; --IF c_get_utl_file_dir%FOUND THEN
  CLOSE c_get_utl_file_dir;
END open_debug_session_internal;

PROCEDURE Developer_Debug(p_msg  IN  VARCHAR2) IS
 l_err_msg VARCHAR2(240);
BEGIN
	Error_Handler.Write_debug(p_msg);
  EXCEPTION
   WHEN OTHERS THEN
    l_err_msg := SUBSTRB(SQLERRM, 1,240);
    FND_FILE.put_line(FND_FILE.LOG, 'LOGGING SQL ERROR => '||l_err_msg);
END;

-----------------------------------------------------------------
 -- Close the Debug Session, only if Debug is already Turned ON --
 -----------------------------------------------------------------
PROCEDURE Close_Debug_Session IS

BEGIN
   -----------------------------------------------------------------------------
   -- Close Error_Handler debug session, only if Debug session is already open.
   -----------------------------------------------------------------------------
   IF (Error_Handler.Get_Debug = 'Y') THEN
     Error_Handler.Close_Debug_Session;
   END IF;

END Close_Debug_Session;
 -----------------------------------------------
 -- Write Debug statements to Concurrent Log  --
 -----------------------------------------------
PROCEDURE Write_Conclog (p_msg  IN  VARCHAR2) IS
 l_err_msg VARCHAR2(240);
BEGIN
    FND_FILE.put_line(FND_FILE.LOG, p_msg);
END Write_Conclog;

PROCEDURE LOAD_USERATTR_DATA(
			   	ERRBUF                          OUT NOCOPY VARCHAR2
		       ,RETCODE                         OUT NOCOPY VARCHAR2
		       ,p_batch_id			IN	NUMBER
		       ,p_data_set_id                      IN   NUMBER
		       ,p_purge_successful_lines        IN   VARCHAR2 DEFAULT FND_API.G_FALSE) IS
    l_entity_index_counter   NUMBER := 0;
    l_debug_level           NUMBER  := 0;
    l_user_attrs_return_status VARCHAR2(100);
    l_return_status          VARCHAR2(1);
    l_errorcode              NUMBER;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(1000);
    l_rel_sql 		 	VARCHAR2(1000);
    l_cnt                   NUMBER      := 0;
   CURSOR c_rrs_site_ua_intf is
   select count(*) from RRS_SITE_UA_INTF
   WHERE PROCESS_STATUS = G_PS_TO_BE_PROCESSED
   AND data_set_id      = p_data_set_id;
   CURSOR c_rrs_loc_ua_intf is
   select count(*) from RRS_LOCATION_UA_INTF
   WHERE PROCESS_STATUS = G_PS_TO_BE_PROCESSED
   AND data_set_id      = p_data_set_id;
   CURSOR c_rrs_ta_ua_intf is
   SELECT count(*) FROM RRS_TRADEAREA_UA_INTF
   WHERE PROCESS_STATUS = G_PS_TO_BE_PROCESSED
   AND data_set_id      = p_data_set_id;
BEGIN

 Write_Conclog('Processing the User Defined Attributes ' );
--dbms_output.put_line('A1');
    IF (Error_Handler.Get_Debug = 'Y') THEN
     l_debug_level := 3; --continue writing to the Debug Log opened.
    ELSE
     l_debug_level := 0; --Since Debug log is not opened, donot open Debug log for User-Attrs also.
    END IF;
    Write_Conclog('Executing EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data -'||'RRS_SITES' );
    l_user_attrs_return_status :=  FND_API.G_RET_STS_SUCCESS;

     Open c_rrs_site_ua_intf;
     fetch c_rrs_site_ua_intf  into  l_cnt;
     Close c_rrs_site_ua_intf;

    IF l_cnt > 0  THEN
          UPDATE RRS_SITE_UA_INTF
          SET PROCESS_STATUS = G_PS_IN_PROCESS
          ,REQUEST_ID = G_REQUEST_ID
          ,PROGRAM_APPLICATION_ID = G_PROGAM_APPLICATION_ID
          ,PROGRAM_ID = G_PROGAM_ID
          ,PROGRAM_UPDATE_DATE = SYSDATE
          ,TRANSACTION_TYPE = UPPER(NVL(TRANSACTION_TYPE,EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE))
           WHERE DATA_SET_ID = p_data_set_id
           AND (PROCESS_STATUS IS NULL OR
            PROCESS_STATUS = G_PS_TO_BE_PROCESSED);

          l_rel_sql 		  := ' (SELECT RSU.SITE_USE_TYPE_CODE '||
					' FROM RRS_SITE_USES RSU' ||
					' WHERE RSU.SITE_ID =  UAI2.SITE_ID)'||
					' UNION ALL ' ||
					' (SELECT UAI2.SITE_USE_TYPE_CODE FROM DUAL)' ;



	   Write_Conclog('Executing EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data -'||'RRS_SITE' );
        EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data (
        p_api_version                   =>  G_API_VERSION                    --IN   NUMBER
       ,p_application_id                =>  718                              --IN   NUMBER
       ,p_attr_group_type               =>  'RRS_SITEMGMT_GROUP'           --IN   VARCHAR2
       ,p_object_name                   =>  'RRS_SITE'                 --IN   VARCHAR2
       ,p_hz_party_id                   =>   G_HZ_PARTY_ID
       ,p_interface_table_name          =>  'RRS_SITE_UA_INTF'         --IN   VARCHAR2
       ,p_data_set_id                   =>  p_data_set_id                    --IN   NUMBER
       ,p_entity_id                     =>  G_ENTITY_ID                      --IN   NUMBER
       ,p_entity_index                  =>  l_entity_index_counter           --IN   NUMBER
       ,p_entity_code                   =>  G_ENTITY_CODE                    --IN   VARCHAR2
       --,p_debug_level                   =>  p_debug_level                    --IN   NUMBER
       ,p_debug_level                   =>  l_debug_level                    --IN   NUMBER
       ,p_init_error_handler            =>  FND_API.G_TRUE                  --IN   VARCHAR2
       ,p_init_fnd_msg_list             =>  FND_API.G_TRUE                  --IN   VARCHAR2
       ,p_log_errors                    =>  FND_API.G_TRUE                   --IN   VARCHAR2
       ,p_add_errors_to_fnd_stack       =>  FND_API.G_TRUE                   --IN   VARCHAR2
       ,p_commit                        =>  FND_API.G_TRUE                   --IN   VARCHAR2
       ,p_default_view_privilege        =>  'RRS_SITE_VIEW'            --IN   VARCHAR2
       ,p_default_edit_privilege        =>  NULL
       ,p_privilege_predicate_api_name  =>  NULL
       ,p_related_class_codes_query     =>  l_rel_sql                              --IN   VARCHAR2
       ,p_validate                      =>  TRUE
       ,p_do_dml                        =>  TRUE
       ,p_do_req_def_valiadtion         =>  TRUE
       ,x_return_status                 =>  l_user_attrs_return_status       --OUT NOCOPY VARCHAR2
       ,x_errorcode                     =>  l_errorcode                      --OUT NOCOPY NUMBER
       ,x_msg_count                     =>  l_msg_count                      --OUT NOCOPY NUMBER
       ,x_msg_data                      =>  l_msg_data                       --OUT NOCOPY VARCHAR2
       );

			Write_Conclog('Executed Site User Defined Attributes Upload API');
            Write_Conclog('G_API_VERSION ' || G_API_VERSION);
			Write_Conclog('G_HZ_PARTY_ID ' ||  G_HZ_PARTY_ID);
			Write_Conclog('p_data_set_id ' || p_data_set_id);
			Write_Conclog('G_ENTITY_ID ' || G_ENTITY_ID);
			Write_Conclog('l_entity_index_counter ' || l_entity_index_counter);
			Write_Conclog(' G_ENTITY_CODE ' || G_ENTITY_CODE );
			Write_Conclog('l_debug_level ' || l_debug_level );
			Write_Conclog('l_rel_sql ' ||  l_rel_sql );
			Write_Conclog('Return Status '||l_user_attrs_return_status);
            Write_Conclog('Error Code '||l_errorcode);
            Write_Conclog('msg count '||l_msg_count);
            Write_Conclog('msg data '||l_msg_data);

	IF l_user_attrs_return_status = 'U' then

		rollback;
		 Write_Conclog('Returs Status is Unexpected. Transaction has been rollbacked. Please check the Database alert log file');

	ELSE


          IF ( p_purge_successful_lines = 'Y') THEN
                  -----------------------------------------------
                  -- Delete all successful rows from the table --
                  -- (they're the only rows still in process)  --
                   -----------------------------------------------
                  DELETE FROM RRS_SITE_UA_INTF
                  WHERE BATCH_ID = p_batch_id
                  AND PROCESS_STATUS = G_PS_IN_PROCESS;
           ELSE
                   ----------------------------------------------
                   -- Mark all rows we've processed as success --
                   -- if they weren't marked as failure above  --
                   ----------------------------------------------
                 UPDATE RRS_SITE_UA_INTF
                 SET PROCESS_STATUS = G_PS_SUCCESS
                 WHERE batch_id = p_batch_id
                 AND PROCESS_STATUS = G_PS_IN_PROCESS;
          END IF;

	END IF;


    END IF;
       l_cnt := 0;
       Open c_rrs_loc_ua_intf;
       Fetch c_rrs_loc_ua_intf  into  l_cnt;
       Close c_rrs_loc_ua_intf;
    IF l_cnt > 0  THEN
           UPDATE RRS_LOCATION_UA_INTF
           SET PROCESS_STATUS = G_PS_IN_PROCESS
          ,REQUEST_ID = G_REQUEST_ID
          ,PROGRAM_APPLICATION_ID = G_PROGAM_APPLICATION_ID
          ,PROGRAM_ID = G_PROGAM_ID
          ,PROGRAM_UPDATE_DATE = SYSDATE
          ,CREATED_BY = DECODE(CREATED_BY, NULL, G_USER_ID, CREATED_BY)
          ,CREATION_DATE = DECODE(CREATION_DATE, NULL, SYSDATE, CREATION_DATE)
          ,LAST_UPDATED_BY = G_USER_ID
          ,LAST_UPDATE_DATE = SYSDATE
          ,LAST_UPDATE_LOGIN = G_LOGIN_ID
          ,TRANSACTION_TYPE = UPPER(NVL(TRANSACTION_TYPE,EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE))
           WHERE DATA_SET_ID = p_data_set_id
           AND (PROCESS_STATUS IS NULL OR
           PROCESS_STATUS = G_PS_TO_BE_PROCESSED);
           -- l_rel_sql 		  := 'SELECT CODE FROM RRS_LOCATIONS_OCV'     ;

          l_rel_sql 		  := ' (SELECT HL.COUNTRY '||
					' FROM HZ_LOCATIONS HL' ||
					' WHERE HL.LOCATION_ID = UAI2.LOCATION_ID)'||
					' UNION ALL ' ||
					' (SELECT UAI2.COUNTRY FROM DUAL)' ;

		Write_Conclog('Executing EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data -'||'RRS_LOCATION' );

        EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data (
        p_api_version                   =>  G_API_VERSION                    --IN   NUMBER
       ,p_application_id                =>  718                              --IN   NUMBER
       ,p_attr_group_type               =>  'RRS_LOCATION_GROUP'             --IN   VARCHAR2
       ,p_object_name                   =>  'RRS_LOCATION'                   --IN   VARCHAR2
       ,p_hz_party_id                   =>   G_HZ_PARTY_ID
       ,p_interface_table_name          =>  'RRS_LOCATION_UA_INTF'         --IN   VARCHAR2
       ,p_data_set_id                   =>  p_data_set_id                    --IN   NUMBER
       ,p_entity_id                     =>  G_ENTITY_ID                      --IN   NUMBER
       ,p_entity_index                  =>  l_entity_index_counter           --IN   NUMBER
       ,p_entity_code                   =>  G_ENTITY_CODE                    --IN   VARCHAR2
       --,p_debug_level                   =>  p_debug_level                    --IN   NUMBER
       ,p_debug_level                   =>  l_debug_level                    --IN   NUMBER
       ,p_init_error_handler            =>  FND_API.G_TRUE                  --IN   VARCHAR2
       ,p_init_fnd_msg_list             =>  FND_API.G_TRUE                  --IN   VARCHAR2
       ,p_log_errors                    =>  FND_API.G_TRUE                   --IN   VARCHAR2
       ,p_add_errors_to_fnd_stack       =>  FND_API.G_TRUE                   --IN   VARCHAR2
       ,p_commit                        =>  FND_API.G_TRUE                   --IN   VARCHAR2
       ,p_default_view_privilege        =>  'RRS_LOCATION_VIEW'            --IN   VARCHAR2
       ,p_default_edit_privilege        =>  NULL
       ,p_privilege_predicate_api_name  =>  NULL
       ,p_related_class_codes_query     =>  l_rel_sql                              --IN   VARCHAR2
       ,p_validate                      =>  TRUE
       ,p_do_dml                        =>  TRUE
       ,p_do_req_def_valiadtion         =>  TRUE
       ,x_return_status                 =>  l_user_attrs_return_status       --OUT NOCOPY VARCHAR2
       ,x_errorcode                     =>  l_errorcode                      --OUT NOCOPY NUMBER
       ,x_msg_count                     =>  l_msg_count                      --OUT NOCOPY NUMBER
       ,x_msg_data                      =>  l_msg_data                       --OUT NOCOPY VARCHAR2
       );
            Write_Conclog('Executed Location User Defined Attributes Upload API');
            Write_Conclog('Return Status '||l_user_attrs_return_status);
            Write_Conclog('Error Code '||l_errorcode);
            Write_Conclog('msg count '||l_msg_count);
            Write_Conclog('msg data '||l_msg_data);

	IF l_user_attrs_return_status = 'U' then

		rollback;
		 Write_Conclog('Returs Status is Unexpected. Transaction has been rollbacked. Please check the Database alert log file');

	ELSE

          IF ( p_purge_successful_lines = 'Y' ) THEN
                  -----------------------------------------------
                  -- Delete all successful rows from the table --
                  -- (they're the only rows still in process)  --
                   -----------------------------------------------
                  DELETE FROM RRS_LOCATION_UA_INTF
                  WHERE BATCH_ID = p_batch_id
                  AND PROCESS_STATUS = G_PS_IN_PROCESS;
           ELSE
                   ----------------------------------------------
                   -- Mark all rows we've processed as success --
                   -- if they weren't marked as failure above  --
                   ----------------------------------------------
                 UPDATE RRS_LOCATION_UA_INTF
                 SET PROCESS_STATUS = G_PS_SUCCESS
                 WHERE batch_id = p_batch_id
                 AND PROCESS_STATUS = G_PS_IN_PROCESS;
          END IF;
	END IF;

    END IF;
       l_cnt := 0;
       Open c_rrs_ta_ua_intf;
       fetch c_rrs_ta_ua_intf  into  l_cnt;
       Close c_rrs_ta_ua_intf;
    IF l_cnt > 0  THEN
           UPDATE RRS_TRADEAREA_UA_INTF
           SET PROCESS_STATUS = G_PS_IN_PROCESS
          ,REQUEST_ID = G_REQUEST_ID
          ,PROGRAM_APPLICATION_ID = G_PROGAM_APPLICATION_ID
          ,PROGRAM_ID = G_PROGAM_ID
          ,PROGRAM_UPDATE_DATE = SYSDATE
          ,CREATED_BY = DECODE(CREATED_BY, NULL, G_USER_ID, CREATED_BY)
          ,CREATION_DATE = DECODE(CREATION_DATE, NULL, SYSDATE, CREATION_DATE)
          ,LAST_UPDATED_BY = G_USER_ID
          ,LAST_UPDATE_DATE = SYSDATE
          ,LAST_UPDATE_LOGIN = G_LOGIN_ID
          ,TRANSACTION_TYPE = UPPER(NVL(TRANSACTION_TYPE,EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE))
           WHERE DATA_SET_ID = p_data_set_id
           AND (PROCESS_STATUS IS NULL OR
           PROCESS_STATUS = G_PS_TO_BE_PROCESSED);
           -- l_rel_sql 		  := 'SELECT CODE FROM RRS_TRADE_AREAS_OCV'     ;


          l_rel_sql 		  := ' (SELECT to_char(RTA.GROUP_ID) '||
					' FROM RRS_TRADE_AREAS RTA' ||
					' WHERE RTA.TRADE_AREA_ID = UAI2.TRADE_AREA_ID)'||
					' UNION ALL ' ||
					' (SELECT UAI2.GROUP_ID FROM DUAL)' ;

	Write_Conclog('Executing EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data -'||'RRS_TRADE_AREA' );

        EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data (
        p_api_version                   =>  G_API_VERSION                    --IN   NUMBER
       ,p_application_id                =>  718                              --IN   NUMBER
       ,p_attr_group_type               =>  'RRS_TRADE_AREA_GROUP'           --IN   VARCHAR2
       ,p_object_name                   =>  'RRS_TRADE_AREA'                 --IN   VARCHAR2
       ,p_hz_party_id                   =>   G_HZ_PARTY_ID
       ,p_interface_table_name          =>  'RRS_TRADEAREA_UA_INTF'         --IN   VARCHAR2
       ,p_data_set_id                   =>  p_data_set_id                    --IN   NUMBER
       ,p_entity_id                     =>  G_ENTITY_ID                      --IN   NUMBER
       ,p_entity_index                  =>  l_entity_index_counter           --IN   NUMBER
       ,p_entity_code                   =>  G_ENTITY_CODE                    --IN   VARCHAR2
       --,p_debug_level                   =>  p_debug_level                    --IN   NUMBER
       ,p_debug_level                   =>  l_debug_level                    --IN   NUMBER
       ,p_init_error_handler            =>  FND_API.G_TRUE                  --IN   VARCHAR2
       ,p_init_fnd_msg_list             =>  FND_API.G_TRUE                  --IN   VARCHAR2
       ,p_log_errors                    =>  FND_API.G_TRUE                   --IN   VARCHAR2
       ,p_add_errors_to_fnd_stack       =>  FND_API.G_TRUE                   --IN   VARCHAR2
       ,p_commit                        =>  FND_API.G_TRUE                   --IN   VARCHAR2
       ,p_default_view_privilege        =>  'RRS_TRADE_AREA_VIEW'            --IN   VARCHAR2
       ,p_default_edit_privilege        =>  NULL
       ,p_privilege_predicate_api_name  =>  NULL
       ,p_related_class_codes_query     =>  l_rel_sql                              --IN   VARCHAR2
       ,p_validate                      =>  TRUE
       ,p_do_dml                        =>  TRUE
       ,p_do_req_def_valiadtion         =>  TRUE
       ,x_return_status                 =>  l_user_attrs_return_status       --OUT NOCOPY VARCHAR2
       ,x_errorcode                     =>  l_errorcode                      --OUT NOCOPY NUMBER
       ,x_msg_count                     =>  l_msg_count                      --OUT NOCOPY NUMBER
       ,x_msg_data                      =>  l_msg_data                       --OUT NOCOPY VARCHAR2
       );
	   Write_Conclog('Executed Trade Area User Defined Attributes Upload API');
           Write_Conclog('Return Status '||l_user_attrs_return_status);
           Write_Conclog('Error Code '||l_errorcode);
           Write_Conclog('msg count '||l_msg_count);
           Write_Conclog('msg data '||l_msg_data);

	IF l_user_attrs_return_status = 'U' then

		rollback;
		 Write_Conclog('Returs Status is Unexpected. Transaction has been rollbacked. Please check the Database alert log file');

	ELSE
 	IF ( p_purge_successful_lines = 'Y' ) THEN
                  -----------------------------------------------
                  -- Delete all successful rows from the table --
                  -- (they're the only rows still in process)  --
                   -----------------------------------------------
                  DELETE FROM RRS_TRADEAREA_UA_INTF
                  WHERE BATCH_ID = p_batch_id
                  AND PROCESS_STATUS = G_PS_IN_PROCESS;
           ELSE
                   ----------------------------------------------
                   -- Mark all rows we've processed as success --
                   -- if they weren't marked as failure above  --
                   ----------------------------------------------
                 UPDATE RRS_TRADEAREA_UA_INTF
                 SET PROCESS_STATUS = G_PS_SUCCESS
                 WHERE batch_id = p_batch_id
                 AND PROCESS_STATUS = G_PS_IN_PROCESS;
          END IF;
	END IF;
    END IF;

      -------------------------------------------------------------------
      -- Finally, we log any errors that we've accumulated throughout  --
      -- our conversions and looping (including all errors encountered --
      -- within our Business Object's processing)                      --
      -------------------------------------------------------------------
      Write_Conclog('****Dumping the List of Error messages into the Concurrent Log***');

      ERROR_HANDLER.Log_Error(
        p_write_err_to_inttable         => 'N'
       ,p_write_err_to_conclog          => 'Y'
       ,p_write_err_to_debugfile        => 'Y'
      );
     Write_Conclog('****End of All Error messages***');
    -----------------------------------------------------------
    -- Let caller know whether any rows failed in processing --
    -----------------------------------------------------------
    IF (  l_user_attrs_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
      RETCODE := FND_API.G_RET_STS_SUCCESS;
    ELSIF (  l_user_attrs_return_status = G_RETCODE_SUCCESS_WITH_WARNING ) THEN
      RETCODE := G_RETCODE_SUCCESS_WITH_WARNING;
    ELSIF (  l_user_attrs_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK;
    END IF;

    BEGIN
      INSERT INTO rrs_interface_errors
         	(SITE_ID
			,SITE_IDENTIFICATION_NUMBER
			,COLUMN_NAME
			,MESSAGE_NAME
			,MESSAGE_TYPE
			,MESSAGE_TEXT
			,SOURCE_TABLE_NAME
			,DESTINATION_TABLE_NAME
			,CREATED_BY
			,CREATION_DATE
			,LAST_UPDATED_BY
			,LAST_UPDATE_DATE
			,LAST_UPDATE_LOGIN
			,REQUEST_ID
			,PROGRAM_APPLICATION_ID
			,PROGRAM_ID
			,PROGRAM_UPDATE_DATE
			,PROCESS_STATUS
			,TRANSACTION_TYPE
			,BATCH_ID
			)
	  SELECT NULL
	        ,NULL
	        ,COLUMN_NAME
			,MESSAGE_NAME
			,MESSAGE_TYPE
			,ERROR_MESSAGE
			,'RRS_SITE_UA_INTF'
			,'RRS_INTERFACE_ERRORS'
			,CREATED_BY
			,CREATION_DATE
			,LAST_UPDATED_BY
			,LAST_UPDATE_DATE
			,LAST_UPDATE_LOGIN
			,REQUEST_ID
			,PROGRAM_APPLICATION_ID
			,PROGRAM_ID
			,PROGRAM_UPDATE_DATE
            ,'3'
            ,NULL
            ,p_batch_id
      FROM   mtl_interface_errors
      WHERE  request_id = fnd_global.conc_request_id
      AND    program_application_id = FND_GLOBAL.PROG_APPL_ID;

    END;


    COMMIT;
EXCEPTION
WHEN OTHERS THEN
      ----------------------------------------
      -- Mark all rows in process as errors --
      ----------------------------------------
      Write_Conclog('Error! While Processing User Defined Attributes ' ) ;
      Write_Conclog('Error while processing Process User Attrs data API  '||SQLCODE || ':'||SQLERRM);
      RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK;
END LOAD_USERATTR_DATA;
END;

/
