--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_ORG_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_ORG_BULKLOAD_PVT" AS
/* $Header: EGOIOBKB.pls 120.2 2006/09/20 23:21:17 dphilip noship $ */

-- =================================================================
-- Global constants that need to be used.
-- =================================================================

  --
  -- Package Name
  --
  G_PACKAGE_NAME               CONSTANT VARCHAR2(30) := 'EGO_ITEM_ORG_BULKLOAD_PVT';
  --
  --  Return values for RETCODE parameter (standard for concurrent programs)
  --
  RETCODE_SUCCESS              NUMBER    := 0;
  RETCODE_WARNING              NUMBER    := 1;
  RETCODE_ERROR                NUMBER    := 2;

  -- The user language (to display the error messages in appropriate language)
  -- This is Database Session Language.
  G_SESSION_LANG           CONSTANT VARCHAR2(99) := USERENV('LANG');

  --This is the UI language.
  G_LANGUAGE_CODE          VARCHAR2(3);

  G_ERROR_TABLE_NAME      VARCHAR2(99) := 'EGO_BULKLOAD_INTF';
  G_ERROR_ENTITY_CODE     VARCHAR2(99) := 'EGO_ITEM';
  G_ERROR_FILE_NAME       VARCHAR2(99);
  G_BO_IDENTIFIER         VARCHAR2(99) := 'EGO_ITEM';

   ----------------------------------------------------------------------------
   -- The Date Format is chosen to be as close as possible to Timestamp format,
   -- except that we support dates before zero A.D. (the "S" in the year part).
   ----------------------------------------------------------------------------
  G_DATE_FORMAT                            CONSTANT VARCHAR2(30) := 'SYYYY-MM-DD HH24:MI:SS';


  G_CONCREQ_VALID_FLAG     BOOLEAN;

  G_STATUS_SUCCESS    CONSTANT VARCHAR2(1)    := 'S';
  G_STATUS_ERROR      CONSTANT VARCHAR2(1)    := 'E';

  G_INTF_STATUS_TOBE_PROCESS   CONSTANT NUMBER := 1;
  G_INTF_STATUS_SUCCESS        CONSTANT NUMBER := 7;
  G_INTF_STATUS_ERROR          CONSTANT NUMBER := 3;

  G_CREATE             CONSTANT VARCHAR2(10) := 'CREATE';
  G_UPDATE             CONSTANT VARCHAR2(10) := 'UPDATE';
  G_SYNC               CONSTANT VARCHAR2(10) := 'SYNC';


  --Define the Base Attribute Names that require Value-to-ID Conversion.
  G_ITEM_NUMBER        VARCHAR2(50) := 'ITEM_NUMBER';
  G_ORG_CODE               VARCHAR2(50) := 'ORGANIZATION_CODE';

  --Chosing Err Status for MSII that dont conflict with other status.
  G_PRIMARY_UOM_ERR_STS            NUMBER := 1000002;

-- =================================================================
-- Global variables used in Concurrent Program.
-- =================================================================

  G_USER_ID         NUMBER  :=  -1;
  G_LOGIN_ID        NUMBER  :=  -1;
  G_PROG_APPID      NUMBER  :=  -1;
  G_PROG_ID         NUMBER  :=  -1;
  G_REQUEST_ID      NUMBER  :=  -1;

  --Define Exceptions
  G_SEGMENT_SEQ_INVALID    EXCEPTION;
  G_DATA_TYPE_INVALID      EXCEPTION;

  --error_number is a negative integer in the range -20000 .. -20999
  PRAGMA EXCEPTION_INIT(G_SEGMENT_SEQ_INVALID, -20000);
  PRAGMA EXCEPTION_INIT(G_DATA_TYPE_INVALID, -20001);

  -- Used for Developer debugging
  G_MSG_LINE_NUM            NUMBER := 1;

  --Debug Profile option used to write Error_Handler.Write_Debug
  --Profile option name = INV_DEBUG_TRACE ; User Profile Option Name = INV: Debug Trace
  --Value: 1 (True) ; 0 (False)
  G_DEBUG CONSTANT VARCHAR2(10) := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

PROCEDURE Write_Debug (p_msg  IN  VARCHAR2) IS
BEGIN

  --If Profile set to TRUE
  IF (G_DEBUG = 1) THEN
     Error_Handler.Write_Debug(p_msg);
  END IF;

END;

PROCEDURE Write_Conc_Log_Debug (p_msg  IN  VARCHAR2) IS
 l_err_msg VARCHAR2(240);
BEGIN

  --If Profile set to TRUE
  IF (G_DEBUG = 1) THEN
    FND_FILE.put_line(FND_FILE.LOG, p_msg);
  END IF;

END;

PROCEDURE open_debug_session IS

  CURSOR c_get_utl_file_dir IS
     SELECT VALUE
      FROM V$PARAMETER
      WHERE NAME = 'utl_file_dir';

  --local variables
  l_log_output_dir       VARCHAR2(512);
  l_log_return_status    VARCHAR2(99);
  l_errbuff              VARCHAR2(999);
BEGIN

   -------------------------------------------------------------------------
   -- Obtaining the Debug file output Directory                           --
   -------------------------------------------------------------------------
    OPEN c_get_utl_file_dir;
    FETCH c_get_utl_file_dir INTO l_log_output_dir;
    --Write_Conc_Log_Debug('UTL_FILE_DIR : '||l_log_output_dir);
    IF c_get_utl_file_dir%FOUND THEN

    ------------------------------------------------------
    -- Trim to get only the first directory in the list --
    ------------------------------------------------------
    IF INSTR(l_log_output_dir,',') <> 0 THEN
      l_log_output_dir := SUBSTR(l_log_output_dir, 1, INSTR(l_log_output_dir, ',') - 1);
      --Write_Conc_Log_Debug('Log Output Dir : '||l_log_output_dir);
    END IF;

   -------------------------------------------------------------------------
   -- Prepare the Debug file name based on the current timestamp          --
   -------------------------------------------------------------------------
    G_ERROR_FILE_NAME := G_ERROR_TABLE_NAME||'_'||to_char(sysdate, 'DDMONYYYY_HH24MISS')||'.err';
    --Write_Conc_Log_Debug('Trying to open the Error File => '||G_ERROR_FILE_NAME);

   -------------------------------------------------------------------------
   -- Opening the Debug file, to write log information                    --
   -------------------------------------------------------------------------
    Error_Handler.Open_Debug_Session(
      p_debug_filename   => G_ERROR_FILE_NAME
     ,p_output_dir       => l_log_output_dir
     ,x_return_status    => l_log_return_status
     ,x_error_mesg       => l_errbuff
     );

    Write_Conc_Log_Debug(' Log file location --> '||l_log_output_dir||'/'||G_ERROR_FILE_NAME ||' created with status '|| l_log_return_status);

    IF (l_log_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       Write_Conc_Log_Debug('Unable to open error log file. Error => '||l_errbuff);
    END IF;

  END IF;--IF c_get_utl_file_dir%FOUND THEN

END open_debug_session;


--Setup Item Interface Lines
PROCEDURE Preprocess_Item_Orgs
               (
                 p_set_process_id        IN         NUMBER
                ) IS

    -- Start OF comments
    -- API name  : Setup MSII Item Interface Lines for processing
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  : Populate and Prepare Item interfance lines.
    --             Eliminates any redundancy / errors in MSII


  --Long Dynamic SQL String
  l_dyn_sql                VARCHAR2(20000);

  --Error messages.
  l_item_catalog_err_msg      VARCHAR2(1000);
  l_uom_err_msg               VARCHAR2(1000);
  l_lifecycle_err_msg         VARCHAR2(1000);
  l_lifecycle_ph_err_msg      VARCHAR2(1000);
  l_useritemtype_err_msg      VARCHAR2(1000);
  l_bomitemtype_err_msg       VARCHAR2(1000);
  l_engitemflag_err_msg       VARCHAR2(1000);

BEGIN

   Write_Debug('Getting the Error messages.');

   --Preparation for Inserting error messages for all pre-processing
   --Validation errors.
   FND_MESSAGE.SET_NAME('EGO','EGO_PRIMARYUOM_INVALID');
   l_uom_err_msg := FND_MESSAGE.GET;

   --Insert the Pre-processed error messages.
   l_dyn_sql := '';
   l_dyn_sql := l_dyn_sql || 'INSERT INTO MTL_INTERFACE_ERRORS ';
   l_dyn_sql := l_dyn_sql || '( ';
   l_dyn_sql := l_dyn_sql || ' ORGANIZATION_ID	 ';
   l_dyn_sql := l_dyn_sql || ', UNIQUE_ID		 ';
   l_dyn_sql := l_dyn_sql || ', LAST_UPDATE_DATE	 ';
   l_dyn_sql := l_dyn_sql || ', LAST_UPDATED_BY	 ';
   l_dyn_sql := l_dyn_sql || ', CREATION_DATE		 ';
   l_dyn_sql := l_dyn_sql || ', CREATED_BY		 ';
   l_dyn_sql := l_dyn_sql || ', LAST_UPDATE_LOGIN	 ';
   l_dyn_sql := l_dyn_sql || ', TABLE_NAME		 ';
   l_dyn_sql := l_dyn_sql || ', MESSAGE_NAME		 ';
   l_dyn_sql := l_dyn_sql || ', COLUMN_NAME		 ';
   l_dyn_sql := l_dyn_sql || ', REQUEST_ID		 ';
   l_dyn_sql := l_dyn_sql || ', PROGRAM_APPLICATION_ID  ';
   l_dyn_sql := l_dyn_sql || ', PROGRAM_ID		 ';
   l_dyn_sql := l_dyn_sql || ', PROGRAM_UPDATE_DATE	 ';
   l_dyn_sql := l_dyn_sql || ', ERROR_MESSAGE		 ';
   l_dyn_sql := l_dyn_sql || ', TRANSACTION_ID 	 ';
   l_dyn_sql := l_dyn_sql || ', ENTITY_IDENTIFIER	 ';
   l_dyn_sql := l_dyn_sql || ', BO_IDENTIFIER		 ';
   l_dyn_sql := l_dyn_sql || ') ';
   l_dyn_sql := l_dyn_sql || 'SELECT ';
   l_dyn_sql := l_dyn_sql || ' -1 ';
   l_dyn_sql := l_dyn_sql || ', MSII.TRANSACTION_ID '; --Change to -1 if prob
   l_dyn_sql := l_dyn_sql || ', SYSDATE ';
   l_dyn_sql := l_dyn_sql || ', '||G_USER_ID ;
   l_dyn_sql := l_dyn_sql || ', SYSDATE ';
   l_dyn_sql := l_dyn_sql || ', '||G_USER_ID;
   l_dyn_sql := l_dyn_sql || ', '||G_LOGIN_ID;
   l_dyn_sql := l_dyn_sql || ', ''MTL_SYSTEM_ITEMS_INTERFACE'' ';
   l_dyn_sql := l_dyn_sql || ', DECODE(MSII.PROCESS_FLAG, ';
   l_dyn_sql := l_dyn_sql || 	  G_PRIMARY_UOM_ERR_STS||', ''EGO_PRIMARYUOM_INVALID'' ';
   l_dyn_sql := l_dyn_sql || '	  ) ';
   l_dyn_sql := l_dyn_sql || ', NULL ';
   l_dyn_sql := l_dyn_sql || ', '||G_REQUEST_ID ;
   l_dyn_sql := l_dyn_sql || ', '||G_PROG_APPID ;
   l_dyn_sql := l_dyn_sql || ', '||G_PROG_ID ;
   l_dyn_sql := l_dyn_sql || ', SYSDATE ';
   l_dyn_sql := l_dyn_sql || ', DECODE(MSII.PROCESS_FLAG,  ';
   l_dyn_sql := l_dyn_sql ||      G_PRIMARY_UOM_ERR_STS||', MSII.PRIMARY_UNIT_OF_MEASURE '||' || '' : '||l_uom_err_msg||'''';
   l_dyn_sql := l_dyn_sql || '         )     ';
   l_dyn_sql := l_dyn_sql || ', MSII.TRANSACTION_ID ';
   l_dyn_sql := l_dyn_sql || ', NULL ';
   l_dyn_sql := l_dyn_sql || ', NULL ';
   l_dyn_sql := l_dyn_sql || 'FROM  MTL_SYSTEM_ITEMS_INTERFACE MSII ';
   l_dyn_sql := l_dyn_sql || ' AND  MSII.PROCESS_FLAG IN  ';
   l_dyn_sql := l_dyn_sql ||  ' ( ';
   l_dyn_sql := l_dyn_sql || 	  G_PRIMARY_UOM_ERR_STS;
   l_dyn_sql := l_dyn_sql ||  ' ) ';
   l_dyn_sql := l_dyn_sql || ' AND  MSII.PROCESS_FLAG = 1 ';
   l_dyn_sql := l_dyn_sql || ' AND  MSII.SET_PROCESS_ID = :SET_PROCESS_ID ';

   Write_Debug('l_dyn_sql');
   --There is a limit of 1024 characters through Write_Debug (it uses
   --UTL_FILE)
   Write_Debug(SUBSTR(l_dyn_sql, 1, 1000));
   Write_Debug(SUBSTR(l_dyn_sql, 1001, 2000));
   EXECUTE IMMEDIATE l_dyn_sql USING p_set_process_id;
   Write_Debug('MIERR: Inserted Pre-processed error messages in MTL_INTERFACE_ERRORS');

   --Now that the error messages are inserted, update MSII lines to
   --Process status ERROR.
   UPDATE MTL_SYSTEM_ITEMS_INTERFACE
    SET   PROCESS_FLAG = G_INTF_STATUS_ERROR
   WHERE  PROCESS_FLAG IN
	  (
	     G_PRIMARY_UOM_ERR_STS
	   )
     AND  SET_PROCESS_ID = p_set_process_id;

   Write_Debug('MSII: Updated all the line statuses to Error for Pre-processing validation errors');

   Write_Debug('Preprocess_Item_Interface : Done.');
END Preprocess_Item_Orgs;


PROCEDURE Process_item_org_assignments  (
  ERRBUF                OUT     NOCOPY VARCHAR2
 ,RETCODE               OUT     NOCOPY NUMBER
 ,p_Set_Process_ID      IN             NUMBER
 ,p_commit              IN             VARCHAR2 DEFAULT FND_API.G_TRUE
					 ) IS
-- Start OF comments
-- API name  : Process Item Org Assignments
-- TYPE      : Concurrent Program
-- Pre-reqs  : None
-- FUNCTION  : Process and Load Item Org Assignments
--
-- Parameters:
--     IN    :
--             p_resultfmt_usage_id        IN      NUMBER
--               Similar to job number. Maps one-to-one with Data_Set_Id,
--               i.e. job number.
--

  --API return parameters
  l_retcode               VARCHAR2(10);
  l_errbuff               VARCHAR2(2000);
  l_msii_set_process_id    NUMBER;
  l_item_ioi_commit        NUMBER;
  l_return_code            VARCHAR2(10);
  l_err_text               VARCHAR2(2000);

BEGIN

    Write_Conc_Log_Debug('Begin: Process_item_org_assignments');

    IF (NVL(fnd_profile.value('CONC_REQUEST_ID'), 0) <> 0) THEN
      g_concReq_valid_flag  := TRUE;
    END IF;

   -------------------------------------------------------------------------
   -- Set Global variables for future usage                               --
   -- The values are chosen from the FND_GLOBALS                          --
   -------------------------------------------------------------------------
   G_USER_ID    := FND_GLOBAL.user_id         ;
   G_LOGIN_ID   := FND_GLOBAL.login_id        ;
   G_PROG_APPID := FND_GLOBAL.prog_appl_id    ;
   G_PROG_ID    := FND_GLOBAL.conc_program_id ;
   G_REQUEST_ID := FND_GLOBAL.conc_request_id ;
   --G_LANGUAGE_CODE := G_SESSION_LANG;

   --Write to Concurrent Log
   Write_Conc_Log_Debug('G_USER_ID : '||To_char(G_USER_ID));
   Write_Conc_Log_Debug('G_PROG_ID : '||To_char(G_PROG_ID));
   Write_Conc_Log_Debug('G_REQUEST_ID : '||To_char(G_REQUEST_ID));

   -------------------------------------------------------------------------
   -- Opening the Debug file, to write log information                    --
   -------------------------------------------------------------------------
   Write_Conc_Log_Debug('Before Error_Handler.initialize');
   Error_Handler.initialize();
   Error_Handler.set_bo_identifier(G_BO_IDENTIFIER);
   --Commented on 12/17/2003 (PPEDDAMA). Open_Debug_Session should set the value
   --appropriately, so that when the Debug Session is successfully opened :
   --will return Error_Handler.Get_Debug = 'Y', else Error_Handler.Get_Debug = 'N'
   --Error_Handler.Set_Debug('Y');

   --Opens Error_Handler debug session
   Open_Debug_Session;
   Write_Conc_Log_Debug('After Open_Debug_Session');

   --After Open_Debug_Session, can log using Write_Debug()
   Write_Debug('G_USER_ID : '||To_char(G_USER_ID));
   Write_Debug('G_PROG_ID : '||To_char(G_PROG_ID));
   Write_Debug('G_REQUEST_ID : '||To_char(G_REQUEST_ID));

   -------------------------------------------------------------------------
   -- Set the commit flag required to call to the IOI API                 --
   -------------------------------------------------------------------------
   IF (p_commit = FND_API.G_TRUE) THEN
      l_item_ioi_commit := 1;
    ELSE
      l_item_ioi_commit := 2;
   END IF;

   -------------------------------------------------------------------------
   -- Preoprocessing to filter out error rows                             --
   -------------------------------------------------------------------------
   --Preprocess_Item_Orgs(p_Set_Process_ID);

   -------------------------------------------------------------------------
   -- Calling IOI API to perform Item Org Assignments                     --
   -------------------------------------------------------------------------

   FND_FILE.put_line(FND_FILE.LOG, '*Importing Item Org Assignments*. SET_PROCESS_ID : '||p_Set_Process_ID);

   --5259908
   INV_EGO_REVISION_VALIDATE.set_Process_Control('EGO_ITEM_BULKLOAD');

   -- Using Wrapper API for INV IOI to support data security.
   EGO_ITEM_OPEN_INTERFACE_PVT.item_open_interface_process
   (
      ERRBUF           =>  l_err_text
   ,  RETCODE          =>  l_return_code
   ,  p_org_id         =>  204 --Dummy value, all_org below carries precedence
   ,  p_all_org        =>  1   --All Orgs
   ,  p_val_item_flag  =>  1   -- validate item
   ,  p_pro_item_flag  =>  1   -- process validated items
   ,  p_del_rec_flag   =>  2   -- do not delete processed records
   ,  p_prog_appid     =>  G_PROG_APPID
   ,  p_prog_id        =>  G_PROG_ID
   ,  p_request_id     =>  G_REQUEST_ID
   ,  p_user_id        =>  G_USER_ID
   ,  p_login_id       =>  G_LOGIN_ID
   ,  p_xset_id        =>  p_Set_Process_ID  -- run for all the IOI  records
   ,  p_commit_flag    =>  l_item_ioi_commit -- NOTE: 1 = Commit 2 = Donot Commit
   ,  p_run_mode       =>  3 --NOTE: 1 = CREATE; 2 = UPDATE; 3 = SYNC
   );

    Write_Debug('IOI_Process : SYNC : done INVPOPIF.inopinp_open_interface_process: l_return_code = ' || l_return_code);
    Write_Debug('IOI_Process : SYNC : l_err_text = ' || l_err_text);

    FND_FILE.put_line(FND_FILE.LOG, '*Import Item Org Assignments Completed* ');

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

   -------------------------------------------------------------------------
   -- Calling Error Handler API to report errors encountered              --
   -------------------------------------------------------------------------

    --Log Errors to MTL_INTERFACE_ERRORS table and Debug file.
    Error_Handler.Log_Error(
			    p_write_err_to_inttable  => 'Y',
			    p_write_err_to_debugfile => 'Y'
			    );

    Error_Handler.Close_Debug_Session;

    --5259908
    INV_EGO_REVISION_VALIDATE.set_Process_Control(NULL);

   -------------------------------------------------------------------------
   -- Catch exception and report to the Debug file                        --
   -------------------------------------------------------------------------
   EXCEPTION
    WHEN OTHERS THEN
      --5259908
      INV_EGO_REVISION_VALIDATE.set_Process_Control(NULL);
      Write_Debug('WHEN OTHERS Exception.');
      Write_Debug('error code : '|| to_char(SQLCODE));
      Write_Debug('error text : '|| SQLERRM);
      ERRBUF := 'Error : '||to_char(SQLCODE)||'---'||SQLERRM;
      RETCODE := Error_Handler.G_STATUS_ERROR;
      Error_Handler.Close_Debug_Session;
      ----------------Exception block ends.

END process_item_org_assignments;


END EGO_ITEM_ORG_BULKLOAD_PVT;

/
