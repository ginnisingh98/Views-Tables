--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_IMPORT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_IMPORT_UTIL" as
/*$Header: ENGUCMIB.pls 120.41.12010000.5 2010/06/11 22:04:34 ksuleman ship $ */

   --------------------------------------------
   -- This is Database Session Language.     --
   --------------------------------------------
   G_SESSION_LANG           CONSTANT VARCHAR2(99) := USERENV('LANG');

   --------------------------------------------
   -- This is the UI language.               --
   --------------------------------------------
   G_LANGUAGE_CODE          VARCHAR2(3);

   ----------------------------------------------------------------------------
   --  Debug Profile option used to write Error_Handler.Write_Debug          --
   --  Profile option name = INV_DEBUG_TRACE ;                               --
   --  User Profile Option Name = INV: Debug Trace                           --
   --  Values: 1 (True) ; 0 (False)                                          --
   --  NOTE: This better than MRP_DEBUG which is used at many places.        --
   ----------------------------------------------------------------------------
   G_DEBUG CONSTANT VARCHAR2(10) := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

   -----------------------------------------------------------------------
   -- These are the Constants to generate a New Line Character.         --
   -----------------------------------------------------------------------
   G_CARRIAGE_RETURN VARCHAR2(1) :=  FND_GLOBAL.LOCAL_CHR(13);
   G_LINE_FEED       VARCHAR2(1) :=  FND_GLOBAL.LOCAL_CHR(10);
   -- Following prints ^M characters in the log file.
   G_NEWLINE         VARCHAR2(2) :=  G_LINE_FEED;


   ---------------------------------------------------------------
   -- API Return Status       .                                 --
   ---------------------------------------------------------------
   G_RET_STS_SUCCESS       CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_SUCCESS;
   G_RET_STS_WARNING       CONSTANT    VARCHAR2(1) :=  'W';
   G_RET_STS_ERROR         CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_ERROR;
   G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_UNEXP_ERROR;

   ---------------------------------------------------------------
   -- Used for Error Reporting.                                 --
   ---------------------------------------------------------------
   G_ERROR_TABLE_NAME      VARCHAR2(30) ;
   G_ERROR_ENTITY_CODE     VARCHAR2(30) := 'EGO_ITEM';
   G_OUTPUT_DIR            VARCHAR2(512) ;
   G_ERROR_FILE_NAME       VARCHAR2(400) ;
   G_BO_IDENTIFIER         VARCHAR2(30) := 'ENG_CHANGE';


   ---------------------------------------------------------------
   -- Introduced for 11.5.10, so that Java Conc Program can     --
   -- continue writing to the same Error Log File.              --
   ---------------------------------------------------------------
   G_ERRFILE_PATH_AND_NAME VARCHAR2(10000);


   ---------------------------------------------------------------
   -- Message Type Text       .                                 --
   ---------------------------------------------------------------
   G_FND_MSG_TYPE_CONFIRMATION       VARCHAR2(100) ;
   G_FND_MSG_TYPE_ERROR              VARCHAR2(100) ;
   G_FND_MSG_TYPE_WARNING            VARCHAR2(100) ;
   G_FND_MSG_TYPE_INFORMATION        VARCHAR2(100) ;

   ---------------------------------------------------------------
   -- Message Type Text       .                                 --
   ---------------------------------------------------------------
   G_ENG_MSG_TYPE_ERROR              CONSTANT VARCHAR2(1)     :=  Error_Handler.G_STATUS_ERROR ;
   G_ENG_MSG_TYPE_WARNING            CONSTANT VARCHAR2(1)     :=  Error_Handler.G_STATUS_WARNING ;
   G_ENG_MSG_TYPE_UNEXPECTED         CONSTANT VARCHAR2(1)     :=  Error_Handler.G_STATUS_UNEXPECTED ;
   G_ENG_MSG_TYPE_FATAL              CONSTANT VARCHAR2(1)     :=  Error_Handler.G_STATUS_FATAL  ;
   G_ENG_MSG_TYPE_CONFIRMATION       CONSTANT VARCHAR2(1)     :=  'C';
   G_ENG_MSG_TYPE_INFORMATION        CONSTANT VARCHAR2(1)     :=  'I' ;


   ---------------------------------------------------------------
   -- Special Miss Values    .                                 --
   ---------------------------------------------------------------
   G_MISS_NUM        NUMBER       :=  EGO_ITEM_PUB.G_INTF_NULL_NUM;
   G_MISS_CHAR       VARCHAR2(1)  :=  EGO_ITEM_PUB.G_INTF_NULL_CHAR;
   G_MISS_DATE       DATE         :=  EGO_ITEM_PUB.G_INTF_NULL_DATE;

 G_ENTITY_CODE                 VARCHAR2(30);
 G_ENTITY_ID                   NUMBER;
 G_APPLICATION_CONTEXT         VARCHAR2(30);

-----------------------------------------------------------------
 -- Write Debug statements to Log using Error Handler procedure --
 -----------------------------------------------------------------
PROCEDURE Write_Debug (p_msg  IN  VARCHAR2) IS

BEGIN

  -- NOTE: No need to check for profile now, as Error_Handler checks
  --       for Error_Handler.Get_Debug = 'Y' before writing to Debug Log.
  -- If Profile set to TRUE --
  -- IF (G_DEBUG = 1) THEN
  -- Error_Handler.Write_Debug('['||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'] '|| p_msg);
  -- END IF;

  Error_Handler.Write_Debug('['||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'] '|| p_msg);


  /*------------------------------------------------------------------
  -- Comment Out
  -- BEGIN
    -- FND Standard Log
    -- FND_LOG.LEVEL_UNEXPECTED;
    -- FND_LOG.LEVEL_ERROR;
    -- FND_LOG.LEVEL_EXCEPTION;
    -- FND_LOG.LEVEL_EVENT;
    -- FND_LOG.LEVEL_PROCEDURE;
    -- FND_LOG.LEVEL_STATEMENT;
    -- G_DEBUG_LOG_HEAD         := 'fnd.plsql.'||G_PKG_NAME||'.';

  --  IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  --    fnd_log.string(log_level => p_log_level
  --                 ,module    => G_DEBUG_LOG_HEAD||p_module
  --                 ,message   => p_message
  --                 );
  --  END IF;
  -- NULL;
  -- EXCEPTION
  -- WHEN OTHERS THEN
  --   RAISE;
  -- END log_now;
  ------------------------------------------------------------------*/


EXCEPTION
   WHEN OTHERS THEN
       FND_FILE.put_line(FND_FILE.LOG, 'Write_Debug LOGGING ERROR => '|| SUBSTRB(SQLERRM, 1,240) );

END Write_Debug ;

 ----------------------------------------------------------
 -- Write to Concurrent Log                              --
 ----------------------------------------------------------

PROCEDURE Developer_Debug (p_msg  IN  VARCHAR2) IS
BEGIN

  FND_FILE.put_line(FND_FILE.LOG, p_msg);


EXCEPTION
   WHEN OTHERS THEN
       FND_FILE.put_line(FND_FILE.LOG, 'Developer_Debug LOGGING SQL ERROR => '|| SUBSTRB(SQLERRM, 1,240));

END Developer_Debug ;

 ----------------------------------------------------------
 -- Internal procedure to open Debug Session.            --
 ----------------------------------------------------------
PROCEDURE open_debug_session_internal IS

  CURSOR c_get_utl_file_dir IS
     SELECT VALUE
      FROM V$PARAMETER
      WHERE NAME = 'utl_file_dir';

  --local variables
  l_log_output_dir       VARCHAR2(512);
  l_log_return_status    VARCHAR2(99);
  l_errbuff              VARCHAR2(999);
BEGIN

  Error_Handler.initialize();
  Error_Handler.set_bo_identifier(G_BO_IDENTIFIER);

  ---------------------------------------------------------------------------------
  -- Commented on 12/17/2003 (PPEDDAMA). Open_Debug_Session should set the value
  -- appropriately, so that when the Debug Session is successfully opened :
  -- will return Error_Handler.Get_Debug = 'Y', else Error_Handler.Get_Debug = 'N'
  ---------------------------------------------------------------------------------
  -- Error_Handler.Set_Debug('Y');

  OPEN c_get_utl_file_dir;
  FETCH c_get_utl_file_dir INTO l_log_output_dir;
  --developer_debug('UTL_FILE_DIR : '||l_log_output_dir);
  IF c_get_utl_file_dir%FOUND THEN
    ------------------------------------------------------
    -- Trim to get only the first directory in the list --
    ------------------------------------------------------
    IF INSTR(l_log_output_dir,',') <> 0 THEN
      l_log_output_dir := SUBSTR(l_log_output_dir, 1, INSTR(l_log_output_dir, ',') - 1);
      --developer_debug('Log Output Dir : '||l_log_output_dir);
    END IF;


    IF G_OUTPUT_DIR IS NOT NULL
    THEN
       l_log_output_dir := G_OUTPUT_DIR ;
    END IF ;



    IF G_ERROR_FILE_NAME IS NULL
    THEN
        G_ERROR_FILE_NAME := G_BO_IDENTIFIER ||'_'
                             -- || G_ERROR_TABLE_NAME||'_'
                             || to_char(sysdate, 'DDMONYYYY_HH24MISS')||'.err';
    END IF ;

    --developer_debug('Trying to open the Error File => '||G_ERROR_FILE_NAME);

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
    -- Introduced for 11.5.10, so that Java Conc Program can     --
    -- continue writing to the same Error Log File.              --
    ---------------------------------------------------------------
    G_ERRFILE_PATH_AND_NAME := l_log_output_dir||'/'||G_ERROR_FILE_NAME;

    developer_debug(' Log file location --> '||l_log_output_dir||'/'||G_ERROR_FILE_NAME ||' created with status '|| l_log_return_status);

    IF (l_log_return_status <> G_RET_STS_SUCCESS) THEN
       developer_debug('Unable to open error log file. Error => '||l_errbuff);
    END IF;

  END IF;--IF c_get_utl_file_dir%FOUND THEN
  -- Bug : 4099546
  CLOSE c_get_utl_file_dir;


EXCEPTION
   WHEN OTHERS THEN
       FND_FILE.put_line(FND_FILE.LOG, 'open_debug_session_internal LOGGING SQL ERROR => ' || SUBSTRB(SQLERRM, 1,240));

END open_debug_session_internal;


 -----------------------------------------------------------
 -- Open the Debug Session, conditionally if the profile: --
 -- INV Debug Trace is set to TRUE                        --
 -----------------------------------------------------------
PROCEDURE Open_Debug_Session
(  p_debug_flag IN VARCHAR2 := NULL
,  p_output_dir IN VARCHAR2 := NULL
,  p_file_name  IN VARCHAR2 := NULL
)
IS

BEGIN
  ----------------------------------------------------------------
  -- Open the Debug Log Session, only if Profile is set to TRUE --
  ----------------------------------------------------------------
  IF (G_DEBUG = 1 OR FND_API.to_Boolean(p_debug_flag)) THEN


     G_OUTPUT_DIR := p_output_dir ;
     G_ERROR_FILE_NAME := p_file_name ;
     ----------------------------------------------------------------------------------
     -- Opens Error_Handler debug session, only if Debug session is not already open.
     -- Suggested by RFAROOK, so that multiple debug sessions are not open PER
     -- Concurrent Request.
     ----------------------------------------------------------------------------------
     IF (Error_Handler.Get_Debug <> 'Y') THEN
       Open_Debug_Session_Internal;
     END IF;

  END IF;

EXCEPTION
   WHEN OTHERS THEN
       FND_FILE.put_line(FND_FILE.LOG, 'Open_Debug_Session LOGGING SQL ERROR => ' || SUBSTRB(SQLERRM, 1,240) );

END Open_Debug_Session;

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

EXCEPTION
   WHEN OTHERS THEN
       FND_FILE.put_line(FND_FILE.LOG, 'Close_Debug_Session LOGGING SQL ERROR => ' || SUBSTRB(SQLERRM, 1,240) );

END Close_Debug_Session;

 -----------------------------------------------------------------
 -- Replace all Single Quote to TWO Single Quotes, for Escaping --
 -- NOTE: Used while inserting Strings using Dynamic SQL.       --
 -----------------------------------------------------------------
FUNCTION Escape_Single_Quote (p_String IN  VARCHAR2)
  RETURN VARCHAR2 IS

BEGIN

   IF (p_String IS NOT NULL) THEN
     ---------------------------------------------------
     -- Replace all Single Quotes to 2 Single Quotes  --
     ---------------------------------------------------
     RETURN REPLACE(p_String, '''', '''''');

   ELSE
     ----------------------------------------------
     -- Return NULL, if the String is NULL or '' --
     ----------------------------------------------
     RETURN NULL;
   END IF;

END Escape_Single_Quote;


-----------------------------------------------------------------
-- Get Message Type Meaning Text from Message Type             --
-----------------------------------------------------------------
FUNCTION Get_Msg_Type_Text(p_msg_type   IN  VARCHAR2 )
RETURN VARCHAR2
IS
    l_msg_type_text VARCHAR2(100) ;
BEGIN

     IF p_msg_type = ERROR
     THEN
         l_msg_type_text := G_ENG_MSG_TYPE_ERROR ;

     ELSIF p_msg_type = SEVERE
     THEN

         l_msg_type_text := G_ENG_MSG_TYPE_UNEXPECTED ;

     ELSIF p_msg_type = WARNING
     THEN

         l_msg_type_text := G_ENG_MSG_TYPE_WARNING ;

     ELSIF p_msg_type = INFORMATION
     THEN

         l_msg_type_text := G_ENG_MSG_TYPE_INFORMATION ;

     ELSIF p_msg_type = CONFIRMATION
     THEN

         l_msg_type_text := G_ENG_MSG_TYPE_CONFIRMATION ;

     ELSE
         l_msg_type_text := p_msg_type ;

     END IF ;


     /***************************************************
     -- In R12, MESSAGE_TYPE in MTL_INTERFACE_ERRORS Table
     -- is VARCHAR2(1), so following does not work
     IF p_msg_type = ERROR OR p_msg_type = SEVERE
     THEN

         IF G_FND_MSG_TYPE_ERROR IS NULL
         THEN
           FND_MESSAGE.SET_NAME('FND','FND_MESSAGE_TYPE_ERROR');
           G_FND_MSG_TYPE_ERROR := FND_MESSAGE.GET;
         END IF ;

         l_msg_type_text := G_FND_MSG_TYPE_ERROR ;

     ELSIF p_msg_type = WARNING
     THEN
         IF G_FND_MSG_TYPE_WARNING IS NULL
         THEN
           FND_MESSAGE.SET_NAME('FND','FND_MESSAGE_TYPE_WARNING');
           G_FND_MSG_TYPE_WARNING := FND_MESSAGE.GET;
         END IF ;

         l_msg_type_text := G_FND_MSG_TYPE_WARNING ;


     ELSIF p_msg_type = INFORMATION
     THEN
         IF G_FND_MSG_TYPE_INFORMATION IS NULL
         THEN
           FND_MESSAGE.SET_NAME('FND','FND_MESSAGE_TYPE_INFORMATION');
           G_FND_MSG_TYPE_INFORMATION := FND_MESSAGE.GET;
         END IF ;

         l_msg_type_text := G_FND_MSG_TYPE_INFORMATION ;

     ELSIF p_msg_type = CONFIRMATION
     THEN
         IF G_FND_MSG_TYPE_CONFIRMATION IS NULL
         THEN
           FND_MESSAGE.SET_NAME('FND','FND_MESSAGE_TYPE_CONFIRMATION');
           G_FND_MSG_TYPE_CONFIRMATION := FND_MESSAGE.GET;
         END IF ;

         l_msg_type_text := G_FND_MSG_TYPE_CONFIRMATION ;

     ELSE
         l_msg_type_text := p_msg_type ;

     END IF ;
     ****************************************************/

     RETURN l_msg_type_text ;

END Get_Msg_Type_Text;


 -----------------------------------------------------------------
 -- Conver Interface Table Transaction Type to ACD Type         --
 -----------------------------------------------------------------
FUNCTION Convert_TxType_To_AcdType(p_tx_type IN  VARCHAR2 )
RETURN VARCHAR2
IS
    l_acd_type VARCHAR2(30) ;

BEGIN
     IF p_tx_type = G_CREATE
     THEN
         l_acd_type := G_ADD_ACD_TYPE;

     ELSIF p_tx_type = G_UPDATE
     THEN
         l_acd_type := G_CHANGE_ACD_TYPE;

     ELSIF p_tx_type = G_DELETE
     THEN
         l_acd_type := G_DELETE_ACD_TYPE;

     ELSE
         l_acd_type := 'INVALID' ;

     END IF ;

     RETURN l_acd_type ;

END Convert_TxType_To_AcdType ;


 -----------------------------------------------------------------
 -- Check the entity is processed or not                        --
 -----------------------------------------------------------------
FUNCTION Is_Processed (p_check_entity   IN  VARCHAR2
                     , p_process_entity IN VARCHAR2 := NULL
                     )
RETURN BOOLEAN
IS


BEGIN


   IF (p_process_entity IS NULL OR p_process_entity = G_IMPORT_ALL)
   THEN
     RETURN TRUE ;

   ELSIF (p_check_entity = G_ALL_ITEM_ENTITY)
   THEN
     RETURN  (p_process_entity = G_ALL_ITEM_ENTITY OR
         p_check_entity = p_process_entity) ;

   ELSIF (p_check_entity = G_ITEM_ENTITY)
   THEN

     RETURN  (p_process_entity = G_ALL_ITEM_ENTITY OR
         p_check_entity = p_process_entity) ;


   ELSIF (p_check_entity = G_ITEM_REV_ENTITY)
   THEN

     RETURN  (p_process_entity = G_ALL_ITEM_ENTITY OR
         p_check_entity = p_process_entity) ;


   ELSIF (p_check_entity = G_GDSN_ATTR_ENTITY)
   THEN
     RETURN  (p_process_entity = G_ALL_ITEM_ENTITY OR
         p_check_entity = p_process_entity) ;


   ELSIF (p_check_entity = G_USER_ATTR_ENTITY)
   THEN
     RETURN  (p_process_entity = G_ALL_ITEM_ENTITY OR
         p_check_entity = p_process_entity) ;


   ELSIF (p_check_entity = G_MFG_PARTT_NUM_ENTITY)
   THEN
     RETURN  (p_process_entity = G_ALL_ITEM_ENTITY OR
         p_check_entity = p_process_entity) ;


   ELSIF (p_check_entity = G_BOM_ENTITY)
   THEN
     RETURN  (p_process_entity = G_ALL_BOM_ENTITY OR
         p_check_entity = p_process_entity) ;


   ELSIF (p_check_entity = G_COMP_ENTITY)
   THEN
     RETURN  (p_process_entity = G_ALL_BOM_ENTITY OR
         p_check_entity = p_process_entity) ;


   ELSIF (p_check_entity = G_REF_DESG_ENTITY)
   THEN
     RETURN  (p_process_entity = G_ALL_BOM_ENTITY OR
         p_check_entity = p_process_entity) ;


   ELSIF (p_check_entity = G_SUB_COMP_ENTITY)
   THEN
     RETURN  (p_process_entity = G_ALL_BOM_ENTITY OR
         p_check_entity = p_process_entity) ;

   ELSE
       RETURN FALSE ;
   END IF;

END Is_Processed ;


 -----------------------------------------------------------------
 -- Check the entity is processed or not                        --
 -----------------------------------------------------------------
FUNCTION Get_Attr_Group_Type_Condition (p_table_alias     IN  VARCHAR2
                                      , p_attr_group_type IN VARCHAR2
                                        )
RETURN VARCHAR2
IS

   l_clause VARCHAR2(150);

BEGIN

     IF p_attr_group_type = G_EGO_ITEM_GTIN_ATTRS
     THEN
         l_clause :=  ' (' || p_table_alias || 'ATTR_GROUP_TYPE = ''' || G_EGO_ITEM_GTIN_ATTRS || '''';
         l_clause :=  l_clause || ' OR ' || p_table_alias || 'ATTR_GROUP_TYPE = ''' || G_EGO_ITEM_GTIN_MULTI_ATTRS || '''';
         l_clause :=  l_clause || ') ' ;

     ELSIF p_attr_group_type IS NOT NULL
     THEN
         -- p_table_alias is like 'INTF.'
         l_clause :=  p_table_alias || 'ATTR_GROUP_TYPE = ''' || p_attr_group_type || '''';

     ELSE
         -- p_table_alias is like 'INTF.'
         l_clause :=  p_table_alias || 'ATTR_GROUP_TYPE IS NULL ';

     END IF ;

     RETURN  l_clause ;


END Get_Attr_Group_Type_Condition ;



 -----------------------------------------------------------------
 -- Get Process Entity Table Definitions                        --
 -----------------------------------------------------------------
PROCEDURE Get_Process_IntfTable_Def ( p_process_entity       IN VARCHAR2 := NULL
                                    , x_intf_table           IN OUT NOCOPY  DBMS_SQL.VARCHAR2_TABLE
                                    , x_intf_batch_id_col    IN OUT NOCOPY  DBMS_SQL.VARCHAR2_TABLE
                                    , x_intf_proc_flag_col   IN OUT NOCOPY  DBMS_SQL.VARCHAR2_TABLE
                                    , x_intf_ri_seq_id_col   IN OUT NOCOPY  DBMS_SQL.VARCHAR2_TABLE
                                    , x_intf_attr_grp_type   IN OUT NOCOPY  DBMS_SQL.VARCHAR2_TABLE
                                    , x_intf_chg_notice_col  IN OUT NOCOPY  DBMS_SQL.VARCHAR2_TABLE
                                   )
IS
    I                     PLS_INTEGER ;

BEGIN
    -- Init Index Text Item Attributes
    I := 0 ;

    -- Set Interface Table
    IF (Is_Processed(G_ITEM_ENTITY, p_process_entity))
    THEN
      I := I + 1  ;
      x_intf_table(I)         :=  G_ITEM_INTF ;
      x_intf_batch_id_col(I)  :=  G_ITEM_INTF_BACTH_ID ;
      x_intf_proc_flag_col(I) :=  G_ITEM_INTF_PROC_FLAG ;
      x_intf_ri_seq_id_col(I) :=  G_ITEM_INTF_RI_SEQ_ID ;
      x_intf_attr_grp_type(I) :=  NULL ;
      x_intf_chg_notice_col(I) :=  NULL ;
    END IF ;

    IF (Is_Processed(G_ITEM_REV_ENTITY, p_process_entity))
    THEN
      I := I + 1  ;
      x_intf_table(I)         :=  G_ITEM_REV_INTF ;
      x_intf_batch_id_col(I)  :=  G_ITEM_REV_INTF_BACTH_ID ;
      x_intf_proc_flag_col(I) :=  G_ITEM_REV_INTF_PROC_FLAG ;
      x_intf_ri_seq_id_col(I) :=  G_ITEM_REV_INTF_RI_SEQ_ID ;
      x_intf_attr_grp_type(I) :=  NULL ;
      x_intf_chg_notice_col(I) :=  NULL ;
    END IF ;

    IF (Is_Processed(G_GDSN_ATTR_ENTITY, p_process_entity))
    THEN
      I := I + 1  ;
      x_intf_table(I)         :=  G_ITEM_USR_ATTR_INTF ;
      x_intf_batch_id_col(I)  :=  G_ITEM_USR_ATTR_INTF_BACTH_ID ;
      x_intf_proc_flag_col(I) :=  G_ITEM_USR_ATTR_INTF_PROC_FLAG ;
      x_intf_ri_seq_id_col(I) :=  G_ITEM_USR_ATTR_INTF_RI_SEQ_ID ;
      x_intf_attr_grp_type(I) :=  G_EGO_ITEM_GTIN_ATTRS ;
      x_intf_chg_notice_col(I) :=  NULL ;
    END IF ;


    IF (Is_Processed(G_USER_ATTR_ENTITY, p_process_entity))
    THEN
      I := I + 1  ;
      x_intf_table(I)         :=  G_ITEM_USR_ATTR_INTF ;
      x_intf_batch_id_col(I)  :=  G_ITEM_USR_ATTR_INTF_BACTH_ID ;
      x_intf_proc_flag_col(I) :=  G_ITEM_USR_ATTR_INTF_PROC_FLAG ;
      x_intf_ri_seq_id_col(I) :=  G_ITEM_USR_ATTR_INTF_RI_SEQ_ID ;
      x_intf_attr_grp_type(I) :=  G_EGO_ITEMMGMT_GROUP ;
      x_intf_chg_notice_col(I) :=  NULL ;
    END IF ;

    IF (Is_Processed(G_MFG_PARTT_NUM_ENTITY, p_process_entity))
    THEN
      I := I + 1  ;
      x_intf_table(I)         :=  G_ITEM_AML_INTF ;
      x_intf_batch_id_col(I)  :=  G_ITEM_AML_INTF_BACTH_ID ;
      x_intf_proc_flag_col(I) :=  G_ITEM_AML_INTF_PROC_FLAG ;
      x_intf_ri_seq_id_col(I) :=  G_ITEM_AML_INTF_RI_SEQ_ID ;
      x_intf_attr_grp_type(I) :=  NULL ;
      x_intf_chg_notice_col(I) :=  NULL ;
    END IF ;


    IF (Is_Processed(G_BOM_ENTITY, p_process_entity))
    THEN
      I := I + 1  ;
      x_intf_table(I)         :=  G_BOM_INTF ;
      x_intf_batch_id_col(I)  :=  G_BOM_INTF_BACTH_ID ;
      x_intf_proc_flag_col(I) :=  G_BOM_INTF_PROC_FLAG ;
      x_intf_ri_seq_id_col(I) :=  NULL ;
      x_intf_attr_grp_type(I) :=  NULL ;
      x_intf_chg_notice_col(I) :=  G_BOM_INTF_CHG_NOTICE ;
    END IF ;

    IF (Is_Processed(G_COMP_ENTITY, p_process_entity))
    THEN
      I := I + 1  ;
      x_intf_table(I)         :=  G_COMP_INTF ;
      x_intf_batch_id_col(I)  :=  G_COMP_INTF_BACTH_ID ;
      x_intf_proc_flag_col(I) :=  G_COMP_INTF_PROC_FLAG ;
      x_intf_ri_seq_id_col(I) :=  G_COMP_INTF_RI_SEQ_ID ;
      x_intf_attr_grp_type(I) :=  NULL ;
      x_intf_chg_notice_col(I) :=  G_COMP_INTF_CHG_NOTICE ;
    END IF ;

    IF (Is_Processed(G_REF_DESG_ENTITY, p_process_entity))
    THEN
      I := I + 1  ;
      x_intf_table(I)         :=  G_REF_DESG_INTF ;
      x_intf_batch_id_col(I)  :=  G_REF_DESG_INTF_BACTH_ID ;
      x_intf_proc_flag_col(I) :=  G_REF_DESG_INTF_PROC_FLAG ;
      x_intf_ri_seq_id_col(I) :=  NULL ;
      x_intf_attr_grp_type(I) :=  NULL ;
      x_intf_chg_notice_col(I) :=  G_REF_DESG_INTF_CHG_NOTICE ;
    END IF ;

    IF (Is_Processed(G_SUB_COMP_ENTITY, p_process_entity))
    THEN
      I := I + 1  ;
      x_intf_table(I)         :=  G_SUB_COMP_INTF ;
      x_intf_batch_id_col(I)  :=  G_SUB_COMP_INTF_BACTH_ID ;
      x_intf_proc_flag_col(I) :=  G_SUB_COMP_INTF_PROC_FLAG ;
      x_intf_ri_seq_id_col(I) :=  NULL ;
      x_intf_attr_grp_type(I) :=  NULL ;
      x_intf_chg_notice_col(I) :=  G_SUB_COMP_INTF_CHG_NOTICE ;
    END IF ;



END Get_Process_IntfTable_Def ;

-----------------------------------------------------------------
 -- Get Revision Import Policy for Batch                       --
-----------------------------------------------------------------
FUNCTION GET_REVISION_IMPORT_POLICY ( p_batch_id IN NUMBER )
RETURN VARCHAR2
IS
    l_revision_import_policy VARCHAR2(1) ;

    CURSOR c_batch_option ( c_batch_id IN NUMBER)
    IS
        SELECT REVISION_IMPORT_POLICY
        FROM EGO_IMPORT_OPTION_SETS
        WHERE BATCH_ID = c_batch_id ;

BEGIN

Write_Debug(G_PKG_NAME || 'ENG_CHANGE_IMPORT_UTIL.GET_REVISION_IMPORT_POLICY. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_batch_id: '  || to_char(p_batch_id));
Write_Debug('-----------------------------------------' );

    OPEN c_batch_option(p_batch_id);
    FETCH c_batch_option INTO l_revision_import_policy ;
    IF (c_batch_option%NOTFOUND)
    THEN
      CLOSE c_batch_option ;
    END IF;

    IF (c_batch_option%ISOPEN)
    THEN
        CLOSE c_batch_option;
    END IF ;


Write_Debug('Revision Import Policy: '  || l_revision_import_policy );

    RETURN l_revision_import_policy ;

END GET_REVISION_IMPORT_POLICY ;



-----------------------------------------------------------------
 -- Get Revision Import Policy for Batch                       --
-----------------------------------------------------------------
FUNCTION GET_CM_IMPORT_OPTION ( p_batch_id IN NUMBER )
RETURN VARCHAR2
IS
    l_cm_import_option VARCHAR2(30) ;

    CURSOR c_batch_option ( c_batch_id IN NUMBER)
    IS
        SELECT CHANGE_ORDER_CREATION
        FROM EGO_IMPORT_OPTION_SETS
        WHERE BATCH_ID = c_batch_id ;

BEGIN

Write_Debug(G_PKG_NAME || 'ENG_CHANGE_IMPORT_UTIL.GET_CM_IMPORT_OPTION. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_batch_id: '  || to_char(p_batch_id));
Write_Debug('-----------------------------------------' );

    OPEN c_batch_option(p_batch_id);
    FETCH c_batch_option INTO l_cm_import_option ;

    IF (c_batch_option%NOTFOUND)
    THEN
      l_cm_import_option := G_NO_BATCH ;
      CLOSE c_batch_option ;
    END IF;

    IF (c_batch_option%ISOPEN)
    THEN
        CLOSE c_batch_option;
    END IF ;

Write_Debug('CM Import Import: '  || l_cm_import_option );

    IF l_cm_import_option IS NULL
    THEN

        l_cm_import_option := G_NO_CHANGE ;

    END IF ;

    RETURN l_cm_import_option ;

END GET_CM_IMPORT_OPTION ;





/********************************************************************
* API Type      : Error and Message Handling APIs
* Purpose       : Error and Message Handling for Change Import
*********************************************************************/
PROCEDURE Insert_Mtl_Intf_Err
(   p_transaction_id    IN  NUMBER
 ,  p_bo_identifier     IN  VARCHAR2  := NULL
 ,  p_error_entity_code IN  VARCHAR2  := NULL
 ,  p_error_table_name  IN  VARCHAR2  := NULL
 ,  p_error_column_name IN  VARCHAR2  := NULL
 ,  p_error_msg         IN  VARCHAR2  := NULL
 ,  p_error_msg_type    IN  VARCHAR2  := NULL
 ,  p_error_msg_name    IN  VARCHAR2  := NULL
)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

    INSERT INTO MTL_INTERFACE_ERRORS
    (  ORGANIZATION_ID
     , UNIQUE_ID
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_LOGIN
     , TABLE_NAME
     , MESSAGE_NAME
     , COLUMN_NAME
     , REQUEST_ID
     , PROGRAM_APPLICATION_ID
     , PROGRAM_ID
     , PROGRAM_UPDATE_DATE
     , ERROR_MESSAGE
     , TRANSACTION_ID
     , ENTITY_IDENTIFIER
     , BO_IDENTIFIER
     , MESSAGE_TYPE
     )
    VALUES
    (  NULL
     , NULL
     , SYSDATE
     , FND_GLOBAL.user_id
     , SYSDATE
     , FND_GLOBAL.user_id
     , FND_GLOBAL.login_id
     , p_error_table_name
     , p_error_msg_name
     , p_error_table_name
     , FND_GLOBAL.conc_request_id
     , FND_GLOBAL.prog_appl_id
     , FND_GLOBAL.conc_program_id
     , SYSDATE
     , SUBSTR(p_error_msg ,1, 2000)
     , p_transaction_id
     , p_error_entity_code
     , p_bo_identifier
     , p_error_msg_type
    );


    COMMIT ;

END Insert_Mtl_Intf_Err ;



PROCEDURE WRITE_MSG_TO_INTF_TBL
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
 ,  p_transaction_id    IN  NUMBER
 ,  p_bo_identifier     IN  VARCHAR2  := NULL
 ,  p_error_entity_code IN  VARCHAR2  := NULL
 ,  p_error_table_name  IN  VARCHAR2  := NULL
 ,  p_error_column_name IN  VARCHAR2  := NULL
 ,  p_error_msg         IN  VARCHAR2  := NULL
 ,  p_error_msg_type    IN  VARCHAR2  := NULL
 ,  p_error_msg_name    IN  VARCHAR2  := NULL
 )
 IS
    l_api_name      CONSTANT VARCHAR2(30) := 'WRITE_MSG_TO_INTF_TBL';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list    VARCHAR2(1) ;
    l_validation_level NUMBER ;
    l_commit           VARCHAR2(1) ;


BEGIN


    -- Standard Start of API savepoint
    SAVEPOINT WRITE_MSG_TO_INTF_TBL;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;



    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_api_caller:'  || p_api_caller);
Write_Debug('p_batch_id: '  || to_char(p_batch_id));
Write_Debug('p_transaction_id: '  || to_char(p_transaction_id));
Write_Debug('p_bo_identifier:'  || p_bo_identifier);
Write_Debug('p_error_entity_code:'  || p_bo_identifier);
Write_Debug('p_error_table_name:'  || p_error_table_name);
Write_Debug('p_error_column_name:'  || p_error_column_name);
Write_Debug('p_error_msg:'  || p_error_msg);
Write_Debug('p_error_msg_type:'  || p_error_msg_type);
Write_Debug('p_error_msg_name:'  || p_error_msg_name);
Write_Debug('-----------------------------------------' );


     --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    -- API body
    -- Logic Here
    -- Enahanced EGO_ITEM_BULKLOAD_PKG.Insert_Mtl_Intf_Err
    --
    Insert_Mtl_Intf_Err
    (   p_transaction_id    => p_transaction_id
     ,  p_bo_identifier     => p_bo_identifier
     ,  p_error_entity_code => p_error_entity_code
     ,  p_error_table_name  => p_error_table_name
     ,  p_error_column_name => p_error_column_name
     ,  p_error_msg         => SUBSTR(p_error_msg ,1, 2000)
     ,  p_error_msg_type    => Get_Msg_Type_Text(p_error_msg_type)
     ,  p_error_msg_name    => p_error_msg_name
     ) ;

    -- End of API body.


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );



    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO WRITE_MSG_TO_INTF_TBL;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    Close_Debug_Session;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO WRITE_MSG_TO_INTF_TBL;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    Close_Debug_Session;

  WHEN OTHERS THEN
    ROLLBACK TO WRITE_MSG_TO_INTF_TBL;
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    Close_Debug_Session;


 END WRITE_MSG_TO_INTF_TBL ;




/********************************************************************
* API Type      : Validation APIs
* Purpose       : Perform Validation for Change Import
*********************************************************************/
PROCEDURE VALIDATE_RECORDS
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_write_msg_to_intftbl IN  VARCHAR2 := NULL --  FND_API.G_FALSE
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
 ,  p_batch_type        IN  VARCHAR2  := NULL
 ,  p_process_entity    IN  VARCHAR2  := NULL
 ,  p_cm_process_type   IN  VARCHAR2  := NULL
)
IS
    l_api_name             CONSTANT VARCHAR2(30) := 'VALIDATE_RECORDS';
    l_api_version          CONSTANT NUMBER     := 1.0;

    l_init_msg_list        VARCHAR2(1) ;
    l_validation_level     NUMBER ;
    l_commit               VARCHAR2(1) ;
    l_write_msg_to_intftbl VARCHAR2(1) ;


    l_cm_import_option     VARCHAR2(30)  ;
    l_msg_process_flag     BOOLEAN ;

    --------------------------------------------
    -- Long Dynamic SQL String
    --------------------------------------------
    l_dyn_sql             VARCHAR2(10000);

    I                     PLS_INTEGER ;
    l_intf_table          DBMS_SQL.VARCHAR2_TABLE;
    l_intf_batch_id_col   DBMS_SQL.VARCHAR2_TABLE;
    l_intf_proc_flag_col  DBMS_SQL.VARCHAR2_TABLE;
    l_intf_ri_seq_id_col  DBMS_SQL.VARCHAR2_TABLE;
    l_intf_attr_grp_type  DBMS_SQL.VARCHAR2_TABLE;
    l_intf_change_number_col  DBMS_SQL.VARCHAR2_TABLE;

    l_error_msg_text      VARCHAR2(2000) ;
    l_error_msg_name      VARCHAR2(30) ;

BEGIN


    -- Standard Start of API savepoint
    SAVEPOINT VALIDATE_RECORDS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;
    l_write_msg_to_intftbl :=  NVL(p_write_msg_to_intftbl,FND_API.G_FALSE) ;
    l_msg_process_flag := FALSE ;


    -- Initialize message list if l_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_write_msg_to_intftbl:'  || p_write_msg_to_intftbl);
Write_Debug('p_api_caller:'  || p_api_caller);
Write_Debug('p_batch_id: '  || to_char(p_batch_id));
Write_Debug('p_batch_type: '  || p_batch_type);

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    -- API body
    -- Logic Here

    -- Perform following validations
    -- Get Process Interface Table  Definitions
    Get_Process_IntfTable_Def(p_process_entity          => p_process_entity
                            , x_intf_table              => l_intf_table
                            , x_intf_batch_id_col       => l_intf_batch_id_col
                            , x_intf_proc_flag_col      => l_intf_proc_flag_col
                            , x_intf_ri_seq_id_col      => l_intf_ri_seq_id_col
                            , x_intf_attr_grp_type      => l_intf_attr_grp_type
                            , x_intf_chg_notice_col     => l_intf_change_number_col
                            ) ;



    -- Get Change Mgmt Import Option
    l_cm_import_option := GET_CM_IMPORT_OPTION(p_batch_id => p_batch_id) ;


    FOR i IN 1..l_intf_table.COUNT LOOP

        -- 1. If CM Batch Type is NONE (Batch does not exist),
        --    OR CM Option is None
        --    OR CM Option is NULL
        -- , we will make the records with process_flag 5
        -- to ERROR
        IF G_NO_BATCH  = p_batch_type  OR
           G_NO_BATCH  = l_cm_import_option OR
           G_NO_CHANGE = l_cm_import_option OR
           l_cm_import_option IS NULL
        THEN
            l_dyn_sql := '' ;
            l_dyn_sql :=              ' UPDATE ' || l_intf_table(i)  || ' INTF ';
            l_dyn_sql := l_dyn_sql || ' SET INTF.change_id =  -100 ' ;
            l_dyn_sql := l_dyn_sql || ' WHERE INTF.' || l_intf_batch_id_col(i) || ' = :BATCH_ID ' ;
            l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_proc_flag_col(i) || ' = ' || G_CM_TO_BE_PROCESSED  ;

            IF l_intf_attr_grp_type(i) IS NOT NULL
            THEN
                l_dyn_sql := l_dyn_sql || ' AND  ' || Get_Attr_Group_Type_Condition('INTF.', l_intf_attr_grp_type(I));
            END IF ;


Write_Debug(l_dyn_sql);

            EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id ;


            -- Set the msg process Flag to TRUE to process the error msg later
            l_msg_process_flag := TRUE ;



        END IF ;


        IF l_validation_level > FND_API.G_VALID_LEVEL_NONE AND
           FND_API.to_Boolean(l_write_msg_to_intftbl) AND
           l_msg_process_flag
        THEN

Write_Debug('Insert Error Message for the records which is set to CM Process per Change ID value set above validation. . .' );

            --
            -- CHANGE_ID = -100 is ENG_IMPT_INVALID_BATCH_ID
            --
            -- In R12, it's only one validate
            -- We did not implementing decode in SQL statement
            --
            IF ( G_NO_BATCH  = p_batch_type  OR
                 G_NO_BATCH  = l_cm_import_option )
            THEN

               l_error_msg_name  := 'ENG_IMPT_INVALID_BATCH_ID' ;
               FND_MESSAGE.SET_NAME('ENG',l_error_msg_name);
               l_error_msg_text := FND_MESSAGE.GET;

            ELSIF (  G_NO_CHANGE = l_cm_import_option OR
                     l_cm_import_option IS NULL )
            THEN

               l_error_msg_name  := 'ENG_IMPT_NO_CM_OPTION' ;
               FND_MESSAGE.SET_NAME('ENG',l_error_msg_name);
               l_error_msg_text := FND_MESSAGE.GET;

            END IF ;


            l_dyn_sql := '';
            l_dyn_sql :=              'INSERT INTO MTL_INTERFACE_ERRORS ';
            l_dyn_sql := l_dyn_sql || '( ';
            l_dyn_sql := l_dyn_sql || ' ORGANIZATION_ID ,   ';
            l_dyn_sql := l_dyn_sql || ' UNIQUE_ID ,   ';
            l_dyn_sql := l_dyn_sql || ' TRANSACTION_ID ,   ';
            l_dyn_sql := l_dyn_sql || ' LAST_UPDATE_DATE ,   ';
            l_dyn_sql := l_dyn_sql || ' LAST_UPDATED_BY ,   ';
            l_dyn_sql := l_dyn_sql || ' CREATION_DATE,    ';
            l_dyn_sql := l_dyn_sql || ' CREATED_BY ,   ';
            l_dyn_sql := l_dyn_sql || ' LAST_UPDATE_LOGIN ,   ';
            l_dyn_sql := l_dyn_sql || ' TABLE_NAME ,   ';
            l_dyn_sql := l_dyn_sql || ' MESSAGE_NAME ,   ';
            l_dyn_sql := l_dyn_sql || ' COLUMN_NAME ,   ';
            l_dyn_sql := l_dyn_sql || ' REQUEST_ID  ,   ';
            l_dyn_sql := l_dyn_sql || ' PROGRAM_APPLICATION_ID ,   ';
            l_dyn_sql := l_dyn_sql || ' PROGRAM_ID ,   ';
            l_dyn_sql := l_dyn_sql || ' PROGRAM_UPDATE_DATE ,   ';
            l_dyn_sql := l_dyn_sql || ' ERROR_MESSAGE ,   ';
            l_dyn_sql := l_dyn_sql || ' ENTITY_IDENTIFIER ,   ';
            l_dyn_sql := l_dyn_sql || ' BO_IDENTIFIER , ';
            l_dyn_sql := l_dyn_sql || ' MESSAGE_TYPE ';
            l_dyn_sql := l_dyn_sql || ') ';
            l_dyn_sql := l_dyn_sql || 'SELECT ';
            l_dyn_sql := l_dyn_sql || ' INTF.ORGANIZATION_ID ,   ';
            l_dyn_sql := l_dyn_sql || ' NULL ,   ';
            l_dyn_sql := l_dyn_sql || ' INTF.TRANSACTION_ID ,   ';
            l_dyn_sql := l_dyn_sql || ' SYSDATE ,   ';
            l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.user_id ,   ';
            l_dyn_sql := l_dyn_sql || ' SYSDATE ,    ';
            l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.user_id ,   ';
            l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.login_id ,   ';
            l_dyn_sql := l_dyn_sql || '''' ||l_intf_table(i) ||''', ' ;
            l_dyn_sql := l_dyn_sql || ''''||l_error_msg_name|| ''', ';
            l_dyn_sql := l_dyn_sql || ' NULL ,   ';
            l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.conc_request_id ,   ';
            l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.prog_appl_id,   ';
            l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.conc_program_id ,   ';
            l_dyn_sql := l_dyn_sql || ' SYSDATE ,   ';
            l_dyn_sql := l_dyn_sql || ''''||Escape_Single_Quote(l_error_msg_text)||''' , ' ;
            l_dyn_sql := l_dyn_sql || ''''||G_ERROR_ENTITY_CODE||''' , ' ;
            l_dyn_sql := l_dyn_sql || ''''||G_BO_IDENTIFIER||''', ' ;
            l_dyn_sql := l_dyn_sql || ''''||G_ENG_MSG_TYPE_ERROR||'''' ;

            l_dyn_sql := l_dyn_sql || ' FROM ' || l_intf_table(i)  || ' INTF ';
            l_dyn_sql := l_dyn_sql || ' WHERE INTF.' || l_intf_batch_id_col(i) || ' = :BATCH_ID ' ;
            l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_proc_flag_col(i) || ' = ' || G_CM_TO_BE_PROCESSED;
            l_dyn_sql := l_dyn_sql || ' AND   INTF.change_id = -100 ';

            IF l_intf_attr_grp_type(i) IS NOT NULL
            THEN
                l_dyn_sql := l_dyn_sql || ' AND  ' || Get_Attr_Group_Type_Condition('INTF.', l_intf_attr_grp_type(I));
            END IF ;


Write_Debug(l_dyn_sql);

            EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id ;


        END IF;

Write_Debug('Update Process Flag to Error for records which can not find CO for the Org. . .' );

        l_dyn_sql := '' ;
        l_dyn_sql :=              ' UPDATE ' || l_intf_table(i)  || ' INTF ';
        l_dyn_sql := l_dyn_sql || ' SET INTF.change_id = null ' ;

        -- If validation level is more than None
        -- set the process flag to ERROR:3
        IF l_validation_level > FND_API.G_VALID_LEVEL_NONE
        THEN
            l_dyn_sql := l_dyn_sql || '   , INTF.' || l_intf_proc_flag_col(i) || ' = ' || G_PS_ERROR  ;
        END IF ;

        l_dyn_sql := l_dyn_sql || ' WHERE INTF.' || l_intf_batch_id_col(i) || ' = :BATCH_ID ' ;
        l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_proc_flag_col(i) || ' = ' || G_CM_TO_BE_PROCESSED;
        l_dyn_sql := l_dyn_sql || ' AND   INTF.change_id = -100 ';

        IF l_intf_attr_grp_type(i) IS NOT NULL
        THEN
            l_dyn_sql := l_dyn_sql || ' AND  ' || Get_Attr_Group_Type_Condition('INTF.', l_intf_attr_grp_type(I));
        END IF ;

Write_Debug(l_dyn_sql);

        EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id ;
        IF SQL%FOUND THEN
          x_return_status := G_RET_STS_WARNING ;
        END IF ;

    END LOOP ;

    -- End of API body.


    -- Standard check of l_commit.
    IF FND_API.To_Boolean( l_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO VALIDATE_RECORDS;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    Close_Debug_Session;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO VALIDATE_RECORDS;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    Close_Debug_Session;

  WHEN OTHERS THEN
    ROLLBACK TO VALIDATE_RECORDS;
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    Close_Debug_Session;

END VALIDATE_RECORDS ;




PROCEDURE  MERGE_GDSN_PENDING_CHG_ROWS
( p_inventory_item_id    IN  NUMBER
 ,p_organization_id      IN  NUMBER
 ,p_change_id            IN  NUMBER
 ,p_change_line_id       IN  NUMBER
 ,p_acd_type             IN  VARCHAR2 := NULL
 ,x_single_row_attrs_rec IN OUT NOCOPY  EGO_ITEM_PUB.UCCNET_ATTRS_SINGL_ROW_REC_TYP
 ,x_multi_row_attrs_tbl  IN OUT NOCOPY  EGO_ITEM_PUB.UCCNET_ATTRS_MULTI_ROW_TBL_TYP
 ,x_extra_attrs_rec      IN OUT NOCOPY  EGO_ITEM_PUB.UCCNET_EXTRA_ATTRS_REC_TYP
)
IS
    CURSOR c_pending_single_row_attrs(c_inventory_item_id    IN  NUMBER
                                     ,c_organization_id      IN  NUMBER
                                     ,c_change_id            IN  NUMBER
                                     ,c_change_line_id       IN  NUMBER
                                     ,c_acd_type             IN  VARCHAR2
                                    ) IS
      SELECT
          --  EXTENSION_ID,
          --  INVENTORY_ITEM_ID,
          --  ORGANIZATION_ID,
          --  CREATED_BY,
          --  CREATION_DATE,
          --  LAST_UPDATED_BY,
          --  LAST_UPDATE_DATE,
          --  LAST_UPDATE_LOGIN,
          --  ITEM_CATALOG_GROUP_ID,
          --  REVISION_ID,
            IS_TRADE_ITEM_A_CONSUMER_UNIT,
            IS_TRADE_ITEM_INFO_PRIVATE,
            GROSS_WEIGHT,
            UOM_GROSS_WEIGHT,
            EFFECTIVE_DATE,
            CANCELED_DATE,
            DISCONTINUED_DATE,
            END_AVAILABILITY_DATE_TIME,
            START_AVAILABILITY_DATE_TIME,
            BRAND_NAME,
            IS_TRADE_ITEM_A_BASE_UNIT,
            IS_TRADE_ITEM_A_VARIABLE_UNIT,
            IS_PACK_MARKED_WITH_EXP_DATE,
            IS_PACK_MARKED_WITH_GREEN_DOT,
            IS_PACK_MARKED_WITH_INGRED,
            IS_PACKAGE_MARKED_AS_REC,
            IS_PACKAGE_MARKED_RET,
            STACKING_FACTOR,
            STACKING_WEIGHT_MAXIMUM,
            UOM_STACKING_WEIGHT_MAXIMUM,
            ORDERING_LEAD_TIME,
            UOM_ORDERING_LEAD_TIME,
            ORDER_QUANTITY_MAX,
            ORDER_QUANTITY_MIN,
            ORDER_QUANTITY_MULTIPLE,
            ORDER_SIZING_FACTOR,
            EFFECTIVE_START_DATE,
            CATALOG_PRICE,
            EFFECTIVE_END_DATE,
            SUGGESTED_RETAIL_PRICE,
            MATERIAL_SAFETY_DATA_SHEET_NO,
            HAS_BATCH_NUMBER,
            IS_NON_SOLD_TRADE_RET_FLAG,
            IS_TRADE_ITEM_MAR_REC_FLAG,
            DIAMETER,
            UOM_DIAMETER,
            DRAINED_WEIGHT,
            UOM_DRAINED_WEIGHT,
            GENERIC_INGREDIENT,
            GENERIC_INGREDIENT_STRGTH,
            UOM_GENERIC_INGREDIENT_STRGTH,
            INGREDIENT_STRENGTH,
            IS_NET_CONTENT_DEC_FLAG,
            NET_CONTENT,
            UOM_NET_CONTENT,
            PEG_HORIZONTAL,
            UOM_PEG_HORIZONTAL,
            PEG_VERTICAL,
            UOM_PEG_VERTICAL,
            CONSUMER_AVAIL_DATE_TIME,
            DEL_TO_DIST_CNTR_TEMP_MAX,
            UOM_DEL_TO_DIST_CNTR_TEMP_MAX,
            DEL_TO_DIST_CNTR_TEMP_MIN,
            UOM_DEL_TO_DIST_CNTR_TEMP_MIN,
            DELIVERY_TO_MRKT_TEMP_MAX,
            UOM_DELIVERY_TO_MRKT_TEMP_MAX,
            DELIVERY_TO_MRKT_TEMP_MIN,
            UOM_DELIVERY_TO_MRKT_TEMP_MIN,
            SUB_BRAND,
--            TRADE_ITEM_DESCRIPTOR,
            EANUCC_CODE,
            EANUCC_TYPE,
            RETAIL_PRICE_ON_TRADE_ITEM,
            QUANTITY_OF_COMP_LAY_ITEM,
            QUANITY_OF_ITEM_IN_LAYER,
            QUANTITY_OF_ITEM_INNER_PACK,
            TARGET_MARKET_DESC,
            QUANTITY_OF_INNER_PACK,
            BRAND_OWNER_GLN,
            BRAND_OWNER_NAME,
            STORAGE_HANDLING_TEMP_MAX,
            UOM_STORAGE_HANDLING_TEMP_MAX,
            STORAGE_HANDLING_TEMP_MIN,
            UOM_STORAGE_HANDLING_TEMP_MIN,
            TRADE_ITEM_COUPON,
            DEGREE_OF_ORIGINAL_WORT,
            FAT_PERCENT_IN_DRY_MATTER,
            PERCENT_OF_ALCOHOL_BY_VOL,
            ISBN_NUMBER,
            ISSN_NUMBER,
            IS_INGREDIENT_IRRADIATED,
            IS_RAW_MATERIAL_IRRADIATED,
            IS_TRADE_ITEM_GENETICALLY_MOD,
            IS_TRADE_ITEM_IRRADIATED,
            PUBLICATION_STATUS,
            TOP_GTIN,
            SECURITY_TAG_LOCATION,
            URL_FOR_WARRANTY,
            NESTING_INCREMENT,
            UOM_NESTING_INCREMENT,
            IS_TRADE_ITEM_RECALLED,
            MODEL_NUMBER,
            PIECES_PER_TRADE_ITEM,
            UOM_PIECES_PER_TRADE_ITEM,
            DEPT_OF_TRNSPRT_DANG_GOODS_NUM,
            RETURN_GOODS_POLICY,
            IS_OUT_OF_BOX_PROVIDED,
            REGISTRATION_UPDATE_DATE,
            TP_NEUTRAL_UPDATE_DATE,
            MASTER_ORG_EXTENSION_ID,
            IS_BARCODE_SYMBOLOGY_DERIVABLE,
            INVOICE_NAME,
            DESCRIPTIVE_SIZE,
            FUNCTIONAL_NAME,
            TRADE_ITEM_FORM_DESCRIPTION,
            WARRANTY_DESCRIPTION,
            TRADE_ITEM_FINISH_DESCRIPTION ,
            DESCRIPTION_SHORT -- ,
            -- CHANGE_ID,
            -- CHANGE_LINE_ID,
            -- ACD_TYPE,
            -- IMPLEMENTATION_DATE
      FROM EGO_GTN_ATTR_CHG_VL
      WHERE INVENTORY_ITEM_ID = c_inventory_item_id
        AND ORGANIZATION_ID = c_organization_id
        AND CHANGE_ID = c_change_id
        AND CHANGE_LINE_ID = c_change_line_Id
        AND ( ACD_TYPE = c_acd_type OR c_acd_type IS NULL)
        AND ACD_TYPE <>'HISTORY';

    CURSOR c_pending_multi_row_attrs(c_inventory_item_id     IN  NUMBER
                                     ,c_organization_id      IN  NUMBER
                                     ,c_change_id            IN  NUMBER
                                     ,c_change_line_id       IN  NUMBER
                                     ,c_acd_type             IN  VARCHAR2
                                     ) IS
      SELECT
           DECODE(ACD_TYPE,'ADD',null,pend.EXTENSION_ID) AS EXTENSION_ID,
          --  INVENTORY_ITEM_ID,
          --  ORGANIZATION_ID,
          --  CREATED_BY,
          --  CREATION_DATE,
          --  LAST_UPDATED_BY,
          --  LAST_UPDATE_DATE,
          --  LAST_UPDATE_LOGIN,
          --  ITEM_CATALOG_GROUP_ID,
          --  REVISION_ID,
            pend.ATTR_GROUP_ID,
            NVL(pend.MANUFACTURER_GLN,              prod.MANUFACTURER_GLN)              MANUFACTURER_GLN,
            NVL(pend.MANUFACTURER_ID,               prod.MANUFACTURER_ID)              MANUFACTURER_ID,
            NVL(pend.PARTY_RECEIVING_PRIVATE_DATA,  prod.PARTY_RECEIVING_PRIVATE_DATA) PARTY_RECEIVING_PRIVATE_DATA,
            NVL(pend.BAR_CODE_TYPE,                 prod.BAR_CODE_TYPE)                BAR_CODE_TYPE,
            NVL(pend.COLOR_CODE_LIST_AGENCY,        prod.COLOR_CODE_LIST_AGENCY)       COLOR_CODE_LIST_AGENCY,
            NVL(pend.COLOR_CODE_VALUE,              prod.COLOR_CODE_VALUE)             COLOR_CODE_VALUE,
            NVL(pend.CLASS_OF_DANGEROUS_CODE,       prod.CLASS_OF_DANGEROUS_CODE)      CLASS_OF_DANGEROUS_CODE,
            NVL(pend.DANGEROUS_GOODS_MARGIN_NUMBER, prod.DANGEROUS_GOODS_MARGIN_NUMBER)DANGEROUS_GOODS_MARGIN_NUMBER,
            NVL(pend.DANGEROUS_GOODS_HAZARDOUS_CODE,prod.DANGEROUS_GOODS_HAZARDOUS_CODE)DANGEROUS_GOODS_HAZARDOUS_CODE,
            NVL(pend.DANGEROUS_GOODS_PACK_GROUP,    prod.DANGEROUS_GOODS_PACK_GROUP)   DANGEROUS_GOODS_PACK_GROUP,
            NVL(pend.DANGEROUS_GOODS_REG_CODE,      prod.DANGEROUS_GOODS_REG_CODE)     DANGEROUS_GOODS_REG_CODE,
            NVL(pend.DANGEROUS_GOODS_SHIPPING_NAME, prod.DANGEROUS_GOODS_SHIPPING_NAME)DANGEROUS_GOODS_SHIPPING_NAME,
            NVL(pend.UNITED_NATIONS_DANG_GOODS_NO,  prod.UNITED_NATIONS_DANG_GOODS_NO) UNITED_NATIONS_DANG_GOODS_NO,
            NVL(pend.FLASH_POINT_TEMP,              prod.FLASH_POINT_TEMP)             FLASH_POINT_TEMP,
            NVL(pend.UOM_FLASH_POINT_TEMP,          prod.UOM_FLASH_POINT_TEMP)         UOM_FLASH_POINT_TEMP,
            NVL(pend.COUNTRY_OF_ORIGIN,             prod.COUNTRY_OF_ORIGIN)            COUNTRY_OF_ORIGIN,
            NVL(pend.HARMONIZED_TARIFF_SYS_ID_CODE, prod.HARMONIZED_TARIFF_SYS_ID_CODE)HARMONIZED_TARIFF_SYS_ID_CODE,
            NVL(pend.SIZE_CODE_LIST_AGENCY,         prod.SIZE_CODE_LIST_AGENCY)        SIZE_CODE_LIST_AGENCY,
            NVL(pend.SIZE_CODE_VALUE,               prod.SIZE_CODE_VALUE)              SIZE_CODE_VALUE,
            pend.MASTER_ORG_EXTENSION_ID,
            NVL(pend.HANDLING_INSTRUCTIONS_CODE,    prod.HANDLING_INSTRUCTIONS_CODE)   HANDLING_INSTRUCTIONS_CODE,
            NVL(pend.DANGEROUS_GOODS_TECHNICAL_NAME,prod.DANGEROUS_GOODS_TECHNICAL_NAME)DANGEROUS_GOODS_TECHNICAL_NAME,
            NVL(pend.DELIVERY_METHOD_INDICATOR  ,   prod.DELIVERY_METHOD_INDICATOR  )    DELIVERY_METHOD_INDICATOR,
            -- CHANGE_ID,
            -- CHANGE_LINE_ID,
            DECODE(ACD_TYPE,'DELETE',ACD_TYPE,null) TRANSACTION_TYPE
            -- IMPLEMENTATION_DATE
      FROM EGO_GTN_MUL_ATTR_CHG_VL pend,
           EGO_ITM_GTN_MUL_ATTRS_VL prod
      WHERE pend.EXTENSION_ID = prod.EXTENSION_ID (+)
        AND pend.INVENTORY_ITEM_ID = c_inventory_item_id
        AND pend.ORGANIZATION_ID = c_organization_id
        AND pend.CHANGE_ID = c_change_id
        AND pend.CHANGE_LINE_ID = c_change_line_Id
        AND ( pend.ACD_TYPE = c_acd_type OR c_acd_type IS NULL)
        AND ACD_TYPE <>'HISTORY'
        ORDER BY ATTR_GROUP_ID;


    CURSOR c_pending_gdsn_extra_row_attrs(c_inventory_item_id     IN  NUMBER
                                         ,c_organization_id      IN  NUMBER
                                         ,c_change_id            IN  NUMBER
                                         ,c_change_line_id       IN  NUMBER
                                         ,c_acd_type             IN  VARCHAR2
                                         ) IS
      SELECT
            UNIT_WEIGHT
      FROM EGO_MTL_SY_ITEMS_CHG_B
      WHERE INVENTORY_ITEM_ID = c_inventory_item_id
        AND ORGANIZATION_ID = c_organization_id
        AND CHANGE_ID = c_change_id
        AND CHANGE_LINE_ID = c_change_line_Id
        AND ACD_TYPE = G_CHANGE_ACD_TYPE  ;


    k                    BINARY_INTEGER;
    l_found              BOOLEAN ;
    l_merge_target_tbl_empty BOOLEAN ;


  BEGIN

    -- MK. NEED TO WORK ON THIS PROCEDURE
    -- Need to modify following logic using meta data
    -- Need to modify UOM logic, if base value is miss value, we may need to set UOM value as null
    -- Don't do hard-coding for column name etc not to have any dependency

Write_Debug('Begin MERGE_GDSN_PENDING_CHG_ROWS') ;

    FOR j IN c_pending_single_row_attrs(p_inventory_item_id, p_organization_id, p_change_id, p_change_line_id, p_acd_type)
    LOOP
Write_Debug('Merging Single row . . .') ;

        -- x_single_row_attrs.LANGUAGE_CODE := USERENV('LANG');
        x_single_row_attrs_rec.IS_TRADE_ITEM_A_CONSUMER_UNIT := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_TRADE_ITEM_A_CONSUMER_UNIT, j.IS_TRADE_ITEM_A_CONSUMER_UNIT));
        x_single_row_attrs_rec.IS_TRADE_ITEM_INFO_PRIVATE := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_TRADE_ITEM_INFO_PRIVATE, j.IS_TRADE_ITEM_INFO_PRIVATE));
        x_single_row_attrs_rec.GROSS_WEIGHT := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.GROSS_WEIGHT, j.GROSS_WEIGHT));

        -- UOM:
        x_single_row_attrs_rec.UOM_GROSS_WEIGHT := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_GROSS_WEIGHT, j.UOM_GROSS_WEIGHT));


        x_single_row_attrs_rec.EFFECTIVE_DATE := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.EFFECTIVE_DATE, j.EFFECTIVE_DATE));
        x_single_row_attrs_rec.END_AVAILABILITY_DATE_TIME := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.END_AVAILABILITY_DATE_TIME, j.END_AVAILABILITY_DATE_TIME));
        x_single_row_attrs_rec.START_AVAILABILITY_DATE_TIME := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.START_AVAILABILITY_DATE_TIME, j.START_AVAILABILITY_DATE_TIME));
        x_single_row_attrs_rec.BRAND_NAME := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.BRAND_NAME, j.BRAND_NAME));
        x_single_row_attrs_rec.IS_TRADE_ITEM_A_BASE_UNIT := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_TRADE_ITEM_A_BASE_UNIT, j.IS_TRADE_ITEM_A_BASE_UNIT));
        x_single_row_attrs_rec.IS_TRADE_ITEM_A_VARIABLE_UNIT := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_TRADE_ITEM_A_VARIABLE_UNIT, j.IS_TRADE_ITEM_A_VARIABLE_UNIT));
        x_single_row_attrs_rec.IS_PACK_MARKED_WITH_EXP_DATE := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_PACK_MARKED_WITH_EXP_DATE, j.IS_PACK_MARKED_WITH_EXP_DATE));
        x_single_row_attrs_rec.IS_PACK_MARKED_WITH_GREEN_DOT := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_PACK_MARKED_WITH_GREEN_DOT, j.IS_PACK_MARKED_WITH_GREEN_DOT));
        x_single_row_attrs_rec.IS_PACK_MARKED_WITH_INGRED := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_PACK_MARKED_WITH_INGRED, j.IS_PACK_MARKED_WITH_INGRED));
        x_single_row_attrs_rec.IS_PACKAGE_MARKED_AS_REC := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_PACKAGE_MARKED_AS_REC, j.IS_PACKAGE_MARKED_AS_REC));
        x_single_row_attrs_rec.IS_PACKAGE_MARKED_RET := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_PACKAGE_MARKED_RET, j.IS_PACKAGE_MARKED_RET));
        x_single_row_attrs_rec.STACKING_FACTOR := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.STACKING_FACTOR, j.STACKING_FACTOR));
        x_single_row_attrs_rec.STACKING_WEIGHT_MAXIMUM := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.STACKING_WEIGHT_MAXIMUM, j.STACKING_WEIGHT_MAXIMUM));

        -- UOM:
        x_single_row_attrs_rec.UOM_STACKING_WEIGHT_MAXIMUM := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_STACKING_WEIGHT_MAXIMUM, j.UOM_STACKING_WEIGHT_MAXIMUM));

        x_single_row_attrs_rec.ORDERING_LEAD_TIME := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.ORDERING_LEAD_TIME, j.ORDERING_LEAD_TIME));
        -- UOM:
        x_single_row_attrs_rec.UOM_ORDERING_LEAD_TIME := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_ORDERING_LEAD_TIME, j.UOM_ORDERING_LEAD_TIME));

        x_single_row_attrs_rec.ORDER_QUANTITY_MAX := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.ORDER_QUANTITY_MAX, j.ORDER_QUANTITY_MAX));
        x_single_row_attrs_rec.ORDER_QUANTITY_MIN := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.ORDER_QUANTITY_MIN, j.ORDER_QUANTITY_MIN));
        x_single_row_attrs_rec.ORDER_QUANTITY_MULTIPLE := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.ORDER_QUANTITY_MULTIPLE, j.ORDER_QUANTITY_MULTIPLE));
        x_single_row_attrs_rec.ORDER_SIZING_FACTOR := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.ORDER_SIZING_FACTOR, j.ORDER_SIZING_FACTOR));
        x_single_row_attrs_rec.EFFECTIVE_START_DATE := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.EFFECTIVE_START_DATE, j.EFFECTIVE_START_DATE));
        x_single_row_attrs_rec.CATALOG_PRICE := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.CATALOG_PRICE, j.CATALOG_PRICE));
        x_single_row_attrs_rec.EFFECTIVE_END_DATE := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.EFFECTIVE_END_DATE, j.EFFECTIVE_END_DATE));
        x_single_row_attrs_rec.SUGGESTED_RETAIL_PRICE := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.SUGGESTED_RETAIL_PRICE, j.SUGGESTED_RETAIL_PRICE));
        x_single_row_attrs_rec.MATERIAL_SAFETY_DATA_SHEET_NO := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.MATERIAL_SAFETY_DATA_SHEET_NO, j.MATERIAL_SAFETY_DATA_SHEET_NO));
        x_single_row_attrs_rec.HAS_BATCH_NUMBER := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.HAS_BATCH_NUMBER, j.HAS_BATCH_NUMBER));
        x_single_row_attrs_rec.IS_NON_SOLD_TRADE_RET_FLAG := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_NON_SOLD_TRADE_RET_FLAG, j.IS_NON_SOLD_TRADE_RET_FLAG));
        x_single_row_attrs_rec.IS_TRADE_ITEM_MAR_REC_FLAG := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_TRADE_ITEM_MAR_REC_FLAG, j.IS_TRADE_ITEM_MAR_REC_FLAG));
        x_single_row_attrs_rec.DIAMETER := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.DIAMETER, j.DIAMETER));
        -- UOM:
        x_single_row_attrs_rec.UOM_DIAMETER := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_DIAMETER, j.UOM_DIAMETER));

        x_single_row_attrs_rec.DRAINED_WEIGHT := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.DRAINED_WEIGHT, j.DRAINED_WEIGHT));
        -- UOM:
        x_single_row_attrs_rec.UOM_DRAINED_WEIGHT :=  Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_DRAINED_WEIGHT, j.UOM_DRAINED_WEIGHT));

        x_single_row_attrs_rec.GENERIC_INGREDIENT := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.GENERIC_INGREDIENT, j.GENERIC_INGREDIENT));

        x_single_row_attrs_rec.GENERIC_INGREDIENT_STRGTH := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.GENERIC_INGREDIENT_STRGTH, j.GENERIC_INGREDIENT_STRGTH));
        -- UOM:
        x_single_row_attrs_rec.UOM_GENERIC_INGREDIENT_STRGTH := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_GENERIC_INGREDIENT_STRGTH, j.UOM_GENERIC_INGREDIENT_STRGTH));

        x_single_row_attrs_rec.INGREDIENT_STRENGTH := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.INGREDIENT_STRENGTH, j.INGREDIENT_STRENGTH));
        x_single_row_attrs_rec.IS_NET_CONTENT_DEC_FLAG := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_NET_CONTENT_DEC_FLAG, j.IS_NET_CONTENT_DEC_FLAG));
        x_single_row_attrs_rec.NET_CONTENT := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.NET_CONTENT, j.NET_CONTENT));
        -- UOM:
        x_single_row_attrs_rec.UOM_NET_CONTENT := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_NET_CONTENT, j.UOM_NET_CONTENT));

        x_single_row_attrs_rec.PEG_HORIZONTAL := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.PEG_HORIZONTAL, j.PEG_HORIZONTAL));
        -- UOM:
        x_single_row_attrs_rec.UOM_PEG_HORIZONTAL := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_PEG_HORIZONTAL, j.UOM_PEG_HORIZONTAL));

        x_single_row_attrs_rec.PEG_VERTICAL := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.PEG_VERTICAL, j.PEG_VERTICAL));
        -- UOM:
        x_single_row_attrs_rec.UOM_PEG_VERTICAL := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_PEG_VERTICAL, j.UOM_PEG_VERTICAL));

        x_single_row_attrs_rec.CONSUMER_AVAIL_DATE_TIME := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.CONSUMER_AVAIL_DATE_TIME, j.CONSUMER_AVAIL_DATE_TIME));

        x_single_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MAX := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MAX, j.DEL_TO_DIST_CNTR_TEMP_MAX));
        -- UOM:
        x_single_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MAX := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MAX, j.UOM_DEL_TO_DIST_CNTR_TEMP_MAX));

        x_single_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MIN := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.DEL_TO_DIST_CNTR_TEMP_MIN, j.DEL_TO_DIST_CNTR_TEMP_MIN));
        -- UOM:
        x_single_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MIN :=  Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_DEL_TO_DIST_CNTR_TEMP_MIN, j.UOM_DEL_TO_DIST_CNTR_TEMP_MIN));
        x_single_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MAX := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MAX, j.DELIVERY_TO_MRKT_TEMP_MAX));
        -- UOM:
        x_single_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MAX := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MAX, j.UOM_DELIVERY_TO_MRKT_TEMP_MAX));

        x_single_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MIN := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.DELIVERY_TO_MRKT_TEMP_MIN, j.DELIVERY_TO_MRKT_TEMP_MIN));
        -- UOM:
        x_single_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MIN := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_DELIVERY_TO_MRKT_TEMP_MIN, j.UOM_DELIVERY_TO_MRKT_TEMP_MIN));


        x_single_row_attrs_rec.SUB_BRAND := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.SUB_BRAND, j.SUB_BRAND));
--        x_single_row_attrs_rec.TRADE_ITEM_DESCRIPTOR := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.TRADE_ITEM_DESCRIPTOR, j.TRADE_ITEM_DESCRIPTOR));
        x_single_row_attrs_rec.EANUCC_CODE := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.EANUCC_CODE, j.EANUCC_CODE));
        x_single_row_attrs_rec.EANUCC_TYPE := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.EANUCC_TYPE, j.EANUCC_TYPE));
        x_single_row_attrs_rec.RETAIL_PRICE_ON_TRADE_ITEM := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.RETAIL_PRICE_ON_TRADE_ITEM, j.RETAIL_PRICE_ON_TRADE_ITEM));
        x_single_row_attrs_rec.QUANTITY_OF_COMP_LAY_ITEM := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.QUANTITY_OF_COMP_LAY_ITEM, j.QUANTITY_OF_COMP_LAY_ITEM));
        x_single_row_attrs_rec.QUANITY_OF_ITEM_IN_LAYER := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.QUANITY_OF_ITEM_IN_LAYER, j.QUANITY_OF_ITEM_IN_LAYER));
        x_single_row_attrs_rec.QUANTITY_OF_ITEM_INNER_PACK := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.QUANTITY_OF_ITEM_INNER_PACK, j.QUANTITY_OF_ITEM_INNER_PACK));
        x_single_row_attrs_rec.QUANTITY_OF_INNER_PACK := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.QUANTITY_OF_INNER_PACK, j.QUANTITY_OF_INNER_PACK));
        x_single_row_attrs_rec.BRAND_OWNER_GLN := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.BRAND_OWNER_GLN, j.BRAND_OWNER_GLN));
        x_single_row_attrs_rec.BRAND_OWNER_NAME := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.BRAND_OWNER_NAME, j.BRAND_OWNER_NAME));
        x_single_row_attrs_rec.STORAGE_HANDLING_TEMP_MAX := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.STORAGE_HANDLING_TEMP_MAX, j.STORAGE_HANDLING_TEMP_MAX));

        -- UOM:
        x_single_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MAX := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MAX, j.UOM_STORAGE_HANDLING_TEMP_MAX));

        x_single_row_attrs_rec.STORAGE_HANDLING_TEMP_MIN := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.STORAGE_HANDLING_TEMP_MIN, j.STORAGE_HANDLING_TEMP_MIN));
        -- UOM:
        x_single_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MIN :=  Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_STORAGE_HANDLING_TEMP_MIN, j.UOM_STORAGE_HANDLING_TEMP_MIN ));

        x_single_row_attrs_rec.TRADE_ITEM_COUPON := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.TRADE_ITEM_COUPON, j.TRADE_ITEM_COUPON));
        x_single_row_attrs_rec.DEGREE_OF_ORIGINAL_WORT := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.DEGREE_OF_ORIGINAL_WORT, j.DEGREE_OF_ORIGINAL_WORT));
        x_single_row_attrs_rec.FAT_PERCENT_IN_DRY_MATTER := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.FAT_PERCENT_IN_DRY_MATTER, j.FAT_PERCENT_IN_DRY_MATTER));
        x_single_row_attrs_rec.PERCENT_OF_ALCOHOL_BY_VOL := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.PERCENT_OF_ALCOHOL_BY_VOL, j.PERCENT_OF_ALCOHOL_BY_VOL));
        x_single_row_attrs_rec.ISBN_NUMBER := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.ISBN_NUMBER, j.ISBN_NUMBER));
        x_single_row_attrs_rec.ISSN_NUMBER := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.ISSN_NUMBER, j.ISSN_NUMBER));
        x_single_row_attrs_rec.IS_INGREDIENT_IRRADIATED := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_INGREDIENT_IRRADIATED, j.IS_INGREDIENT_IRRADIATED));
        x_single_row_attrs_rec.IS_RAW_MATERIAL_IRRADIATED := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_RAW_MATERIAL_IRRADIATED, j.IS_RAW_MATERIAL_IRRADIATED));
        x_single_row_attrs_rec.IS_TRADE_ITEM_GENETICALLY_MOD := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_TRADE_ITEM_GENETICALLY_MOD, j.IS_TRADE_ITEM_GENETICALLY_MOD));
        x_single_row_attrs_rec.IS_TRADE_ITEM_IRRADIATED := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_TRADE_ITEM_IRRADIATED, j.IS_TRADE_ITEM_IRRADIATED));
        x_single_row_attrs_rec.SECURITY_TAG_LOCATION := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.SECURITY_TAG_LOCATION, j.SECURITY_TAG_LOCATION));
        x_single_row_attrs_rec.URL_FOR_WARRANTY := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.URL_FOR_WARRANTY, j.URL_FOR_WARRANTY));
        x_single_row_attrs_rec.NESTING_INCREMENT := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.NESTING_INCREMENT, j.NESTING_INCREMENT));
        -- UOM:
        x_single_row_attrs_rec.UOM_NESTING_INCREMENT := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_NESTING_INCREMENT, j.UOM_NESTING_INCREMENT));

        x_single_row_attrs_rec.IS_TRADE_ITEM_RECALLED := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_TRADE_ITEM_RECALLED, j.IS_TRADE_ITEM_RECALLED));
        x_single_row_attrs_rec.MODEL_NUMBER := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.MODEL_NUMBER, j.MODEL_NUMBER));
        x_single_row_attrs_rec.PIECES_PER_TRADE_ITEM := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.PIECES_PER_TRADE_ITEM, j.PIECES_PER_TRADE_ITEM));
        -- UOM:
        x_single_row_attrs_rec.UOM_PIECES_PER_TRADE_ITEM := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.UOM_PIECES_PER_TRADE_ITEM, j.UOM_PIECES_PER_TRADE_ITEM));

        x_single_row_attrs_rec.DEPT_OF_TRNSPRT_DANG_GOODS_NUM := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.DEPT_OF_TRNSPRT_DANG_GOODS_NUM, j.DEPT_OF_TRNSPRT_DANG_GOODS_NUM));
        x_single_row_attrs_rec.RETURN_GOODS_POLICY := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.RETURN_GOODS_POLICY, j.RETURN_GOODS_POLICY));
        x_single_row_attrs_rec.IS_OUT_OF_BOX_PROVIDED := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_OUT_OF_BOX_PROVIDED, j.IS_OUT_OF_BOX_PROVIDED));
        x_single_row_attrs_rec.INVOICE_NAME := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.INVOICE_NAME, j.INVOICE_NAME));
        x_single_row_attrs_rec.DESCRIPTIVE_SIZE := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.DESCRIPTIVE_SIZE, j.DESCRIPTIVE_SIZE));
        x_single_row_attrs_rec.FUNCTIONAL_NAME := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.FUNCTIONAL_NAME, j.FUNCTIONAL_NAME));
        x_single_row_attrs_rec.TRADE_ITEM_FORM_DESCRIPTION := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.TRADE_ITEM_FORM_DESCRIPTION, j.TRADE_ITEM_FORM_DESCRIPTION));
        x_single_row_attrs_rec.WARRANTY_DESCRIPTION := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.WARRANTY_DESCRIPTION, j.WARRANTY_DESCRIPTION));
        x_single_row_attrs_rec.TRADE_ITEM_FINISH_DESCRIPTION := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.TRADE_ITEM_FINISH_DESCRIPTION, j.TRADE_ITEM_FINISH_DESCRIPTION));
        x_single_row_attrs_rec.DESCRIPTION_SHORT := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.DESCRIPTION_SHORT, j.DESCRIPTION_SHORT));
        x_single_row_attrs_rec.IS_BARCODE_SYMBOLOGY_DERIVABLE := Get_Nulled_out_Value(NVL(x_single_row_attrs_rec.IS_BARCODE_SYMBOLOGY_DERIVABLE, j.IS_BARCODE_SYMBOLOGY_DERIVABLE));

Write_Debug('After Merging Single row . . .');


      END LOOP ; -- end loop single row attributes



Write_Debug('Merging Multi-Row Attrs row. . . ');



      IF ( x_multi_row_attrs_tbl IS NULL OR x_multi_row_attrs_tbl.COUNT = 0 )
      THEN
Write_Debug('Merging target row tbl is empty . . . ');
         l_merge_target_tbl_empty := TRUE ;
      END IF ;

      k := 0;
      FOR j IN c_pending_multi_row_attrs(p_inventory_item_id
                                        , p_organization_id, p_change_id, p_change_line_id, p_acd_type)
      LOOP

        IF l_merge_target_tbl_empty
        THEN
           k := k+1 ;
        ELSE

        -- MK. NEED TO WORK ON THIS PROCEDURE
        -- Need to modify following logic using meta data
        -- Need to modify UOM logic, if base value is miss value, we may need to set UOM value as null
        -- Need to identify the record using pk values derived from meta data
        -- Don't do hard-coding for column name etc not to have any dependency
        -- Find exsting pending change records for this attribute group rec
           l_found := FALSE ;

        END IF ;


        x_multi_row_attrs_tbl(k).LANGUAGE_CODE := USERENV('LANG') ;
        x_multi_row_attrs_tbl(k).MANUFACTURER_GLN :=  Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).MANUFACTURER_GLN, j.MANUFACTURER_GLN)) ;
        x_multi_row_attrs_tbl(k).MANUFACTURER_ID := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).MANUFACTURER_ID, j.MANUFACTURER_ID)) ;
        x_multi_row_attrs_tbl(k).BAR_CODE_TYPE := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).BAR_CODE_TYPE, j.BAR_CODE_TYPE)) ;
        x_multi_row_attrs_tbl(k).COLOR_CODE_LIST_AGENCY := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).COLOR_CODE_LIST_AGENCY, j.COLOR_CODE_LIST_AGENCY)) ;
        x_multi_row_attrs_tbl(k).COLOR_CODE_VALUE := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).COLOR_CODE_VALUE, j.COLOR_CODE_VALUE)) ;
        x_multi_row_attrs_tbl(k).CLASS_OF_DANGEROUS_CODE := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).CLASS_OF_DANGEROUS_CODE, j.CLASS_OF_DANGEROUS_CODE)) ;
        x_multi_row_attrs_tbl(k).DANGEROUS_GOODS_MARGIN_NUMBER := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).DANGEROUS_GOODS_MARGIN_NUMBER, j.DANGEROUS_GOODS_MARGIN_NUMBER)) ;
        x_multi_row_attrs_tbl(k).DANGEROUS_GOODS_HAZARDOUS_CODE := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).DANGEROUS_GOODS_HAZARDOUS_CODE, j.DANGEROUS_GOODS_HAZARDOUS_CODE)) ;
        x_multi_row_attrs_tbl(k).DANGEROUS_GOODS_PACK_GROUP := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).DANGEROUS_GOODS_PACK_GROUP, j.DANGEROUS_GOODS_PACK_GROUP)) ;
        x_multi_row_attrs_tbl(k).DANGEROUS_GOODS_REG_CODE := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).DANGEROUS_GOODS_REG_CODE, j.DANGEROUS_GOODS_REG_CODE)) ;
        x_multi_row_attrs_tbl(k).DANGEROUS_GOODS_SHIPPING_NAME := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).DANGEROUS_GOODS_SHIPPING_NAME, j.DANGEROUS_GOODS_SHIPPING_NAME)) ;
        x_multi_row_attrs_tbl(k).UNITED_NATIONS_DANG_GOODS_NO := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).UNITED_NATIONS_DANG_GOODS_NO, j.UNITED_NATIONS_DANG_GOODS_NO)) ;
        x_multi_row_attrs_tbl(k).FLASH_POINT_TEMP := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).FLASH_POINT_TEMP, j.FLASH_POINT_TEMP)) ;

        IF x_multi_row_attrs_tbl(k).FLASH_POINT_TEMP IS NOT NULL THEN
          x_multi_row_attrs_tbl(k).UOM_FLASH_POINT_TEMP := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).UOM_FLASH_POINT_TEMP, j.UOM_FLASH_POINT_TEMP)) ;
        ELSE
          x_multi_row_attrs_tbl(k).UOM_FLASH_POINT_TEMP := NULL;
        END IF ;

        x_multi_row_attrs_tbl(k).COUNTRY_OF_ORIGIN := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).COUNTRY_OF_ORIGIN, j.COUNTRY_OF_ORIGIN)) ;
        x_multi_row_attrs_tbl(k).HARMONIZED_TARIFF_SYS_ID_CODE := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).HARMONIZED_TARIFF_SYS_ID_CODE, j.HARMONIZED_TARIFF_SYS_ID_CODE)) ;
        x_multi_row_attrs_tbl(k).SIZE_CODE_LIST_AGENCY := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).SIZE_CODE_LIST_AGENCY, j.SIZE_CODE_LIST_AGENCY)) ;
        x_multi_row_attrs_tbl(k).SIZE_CODE_VALUE := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).SIZE_CODE_VALUE, j.SIZE_CODE_VALUE)) ;
        x_multi_row_attrs_tbl(k).HANDLING_INSTRUCTIONS_CODE := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).HANDLING_INSTRUCTIONS_CODE, j.HANDLING_INSTRUCTIONS_CODE)) ;
        x_multi_row_attrs_tbl(k).DANGEROUS_GOODS_TECHNICAL_NAME := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).DANGEROUS_GOODS_TECHNICAL_NAME, j.DANGEROUS_GOODS_TECHNICAL_NAME)) ;
        x_multi_row_attrs_tbl(k).DELIVERY_METHOD_INDICATOR := Get_Nulled_out_Value(NVL(x_multi_row_attrs_tbl(k).DELIVERY_METHOD_INDICATOR, j.DELIVERY_METHOD_INDICATOR)) ;

        x_multi_row_attrs_tbl(k).EXTENSION_ID := NVL(x_multi_row_attrs_tbl(k).EXTENSION_ID, j.EXTENSION_ID);
        x_multi_row_attrs_tbl(k).TRANSACTION_TYPE := NVL(x_multi_row_attrs_tbl(k).TRANSACTION_TYPE, j.TRANSACTION_TYPE);


      END LOOP; -- end loop multi row attributes

      --Setting the value for x_extra_attrs_rec
      --Logic needs to be added to work as following:
      --(a) unit_weight is present in pending table with value Null-Out Value  -> EGO_ITEM_PUB.G_INTF_NULL_NUM
      --(b) unit_weight is not present in pending table -> NULL
      --(c) unit_weight is present in pending table with non-null value -> pass the value present in the table.

      x_extra_attrs_rec.UNIT_WEIGHT := NULL ;
      FOR k IN c_pending_gdsn_extra_row_attrs(p_inventory_item_id, p_organization_id, p_change_id, p_change_line_id, p_acd_type)
      LOOP
Write_Debug('Merging Extra Row . . .') ;

          IF k.UNIT_WEIGHT  = ENG_CHANGE_ATTR_UTIL.G_ATTR_NULL_NUM
          THEN
              x_extra_attrs_rec.UNIT_WEIGHT := EGO_ITEM_PUB.G_INTF_NULL_NUM ;
          ELSE
              x_extra_attrs_rec.UNIT_WEIGHT := k.UNIT_WEIGHT ;
          END IF ;

Write_Debug('Extra Attr UNIT_WEIGHT: ' || k.UNIT_WEIGHT ) ;

      END LOOP ;



END MERGE_GDSN_PENDING_CHG_ROWS;



PROCEDURE VALIDATE_GDSN_ATTR_CHGS
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_write_msg_to_intftbl IN  VARCHAR2 := NULL --  FND_API.G_FALSE
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
 ,  p_cm_process_type   IN  VARCHAR2  := NULL
)
IS

    l_api_name      CONSTANT VARCHAR2(30) := 'VALIDATE_GDSN_ATTR_CHGS';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list    VARCHAR2(1) ;
    l_validation_level NUMBER ;
    l_commit           VARCHAR2(1) ;
    l_write_msg_to_intftbl VARCHAR2(1) ;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(4000);
    l_msg_text           VARCHAR2(4000);
    l_acd_type           VARCHAR2(30) ;

    l_single_row_attrs   EGO_ITEM_PUB.UCCNET_ATTRS_SINGL_ROW_REC_TYP ;
    l_multi_row_attrs    EGO_ITEM_PUB.UCCNET_ATTRS_MULTI_ROW_TBL_TYP ;
    l_extra_attrs_rec    EGO_ITEM_PUB.UCCNET_EXTRA_ATTRS_REC_TYP;

    CURSOR c_intf_rows IS
      SELECT
        INVENTORY_ITEM_ID
       ,ORGANIZATION_ID
       ,CHANGE_ID
       ,CHANGE_LINE_ID
       ,TRANSACTION_TYPE
       ,MAX(TRANSACTION_ID) AS TRANSACTION_ID
      FROM EGO_ITM_USR_ATTR_INTRFC
      WHERE ATTR_GROUP_TYPE IN ('EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS')
        AND DATA_SET_ID = p_batch_id
        AND PROCESS_STATUS = G_CM_TO_BE_PROCESSED
        AND CHANGE_ID  IS NOT NULL
        AND CHANGE_LINE_ID IS NOT NULL
      GROUP BY INVENTORY_ITEM_ID, ORGANIZATION_ID,CHANGE_ID, CHANGE_LINE_ID, TRANSACTION_TYPE ;


BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT VALIDATE_GDSN_ATTR_CHGS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;
    l_write_msg_to_intftbl :=  NVL(p_write_msg_to_intftbl,FND_API.G_FALSE) ;


    -- Initialize message list if l_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_write_msg_to_intftbl:'  || p_write_msg_to_intftbl);
Write_Debug('p_api_caller:'  || p_api_caller);
Write_Debug('p_batch_id: '  || to_char(p_batch_id));
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    -- API body
    -- Logic Here
    FOR i IN c_intf_rows LOOP

Write_Debug('Populating local array for Item, Org='||i.INVENTORY_ITEM_ID||','||i.ORGANIZATION_ID);
Write_Debug('EGO_GTIN_ATTRS_PVT.Get_Gdsn_Intf_Rows. . . : '  || to_char(p_batch_id));


        l_return_status      := NULL;
        l_msg_count          := NULL;
        l_msg_data           := NULL;
        l_single_row_attrs   := NULL ;
        l_multi_row_attrs.DELETE ;
        l_extra_attrs_rec    := NULL;


        BEGIN

          EGO_GTIN_ATTRS_PVT.Get_Gdsn_Intf_Rows
          ( p_data_set_id          => p_batch_id
          , p_target_proc_status   => G_CM_TO_BE_PROCESSED
          , p_inventory_item_id    => i.INVENTORY_ITEM_ID
          , p_organization_id      => i.ORGANIZATION_ID
          , x_singe_row_attrs_rec  => l_single_row_attrs
          , x_multi_row_attrs_tbl  => l_multi_row_attrs
          , x_return_status        => l_return_status
          , x_msg_count            => l_msg_count
          , x_msg_data             => l_msg_data
          ) ;

        EXCEPTION

          WHEN OTHERS THEN
Write_Debug('While calling Validation API EGO_GTIN_ATTRS_PVT.Validate_Attributes: '  || to_char(p_batch_id));
Write_Debug('Error:' || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)) ;

              FND_MSG_PUB.Add_Exc_Msg
              ( 'EGO_GTIN_ATTRS_PVT',
                'Get_Gdsn_Intf_Rows' ,
                 SQLERRM ) ;

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR  ;


        END ;


Write_Debug('After EGO_GTIN_ATTRS_PVT.Get_Gdsn_Intf_Rows: ' || l_return_status);

        IF l_return_status <> G_RET_STS_SUCCESS THEN

          x_return_status := G_RET_STS_WARNING ;
          UPDATE EGO_ITM_USR_ATTR_INTRFC
          SET PROCESS_STATUS = G_PS_ERROR
          WHERE DATA_SET_ID = p_batch_id
            AND ATTR_GROUP_TYPE IN (G_EGO_ITEM_GTIN_ATTRS , G_EGO_ITEM_GTIN_MULTI_ATTRS)
            AND INVENTORY_ITEM_ID = i.INVENTORY_ITEM_ID
            AND ORGANIZATION_ID = i.ORGANIZATION_ID
            AND CHANGE_ID = i.CHANGE_ID
            AND CHANGE_LINE_ID = i.CHANGE_LINE_ID;

Write_Debug('Marked Item as error in Interface table');

            IF l_msg_count > 0 AND l_return_status <> G_RET_STS_UNEXP_ERROR THEN
              FOR cnt IN 1..l_msg_count LOOP
Write_Debug('Error msg - '||cnt ||': '|| FND_MSG_PUB.Get(p_msg_index => cnt, p_encoded => 'F'));

                l_msg_text := FND_MSG_PUB.Get(p_msg_index => cnt, p_encoded => 'F');
                IF FND_API.to_Boolean(l_write_msg_to_intftbl)
                THEN

                    Insert_Mtl_Intf_Err
                    (   p_transaction_id    => i.TRANSACTION_ID
                     ,  p_bo_identifier     => G_BO_IDENTIFIER
                     ,  p_error_entity_code => G_GDSN_ATTR_ENTITY
                     ,  p_error_table_name  => G_ITEM_USR_ATTR_INTF
                     ,  p_error_column_name => NULL
                     ,  p_error_msg         => l_msg_text
                     ,  p_error_msg_type    => G_ENG_MSG_TYPE_ERROR
                     ,  p_error_msg_name    => null
                    ) ;

                END IF ;

              END LOOP;

            ELSIF l_msg_count > 0 AND l_return_status = G_RET_STS_UNEXP_ERROR THEN

Write_Debug('Unexpected Error msg - '|| l_msg_data);

                l_msg_text := l_msg_data;
                IF FND_API.to_Boolean(l_write_msg_to_intftbl)
                THEN

                    Insert_Mtl_Intf_Err
                    (   p_transaction_id    => i.TRANSACTION_ID
                     ,  p_bo_identifier     => G_BO_IDENTIFIER
                     ,  p_error_entity_code => G_GDSN_ATTR_ENTITY
                     ,  p_error_table_name  => G_ITEM_USR_ATTR_INTF
                     ,  p_error_column_name => NULL
                     ,  p_error_msg         => l_msg_text
                     ,  p_error_msg_type    => G_ENG_MSG_TYPE_ERROR
                     ,  p_error_msg_name    => null
                    ) ;

                END IF ;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;


            END IF; -- IF l_msg_count

        END IF; -- IF l_return_status <> 'S

        l_acd_type := Convert_TxType_To_AcdType(p_tx_type => i.TRANSACTION_TYPE) ;

Write_Debug('Merging existing pending change data for ' || 'CO:' || to_char(i.CHANGE_ID)
                                                       || '-Line:' || to_char(i.CHANGE_LINE_ID)
                                                       || '-AcdType:' || l_acd_type
                                                       );

        MERGE_GDSN_PENDING_CHG_ROWS(  p_inventory_item_id   => i.INVENTORY_ITEM_ID
                                    , p_organization_id     => i.ORGANIZATION_ID
                                    , p_change_id           => i.CHANGE_ID
                                    , p_change_line_id      => i.CHANGE_LINE_ID
                                    , p_acd_type            => l_acd_type
                                    , x_single_row_attrs_rec => l_single_row_attrs
                                    , x_multi_row_attrs_tbl => l_multi_row_attrs
                                    , x_extra_attrs_rec     => l_extra_attrs_rec
                                   ) ;

Write_Debug('After Merging existing pending change data') ;

        BEGIN

Write_Debug('Calling Validation API EGO_GTIN_ATTRS_PVT.Validate_Attributes: '  || to_char(p_batch_id));
            EGO_GTIN_ATTRS_PVT.Validate_Attributes(
               p_inventory_item_id    => i.INVENTORY_ITEM_ID
              ,p_organization_id      => i.ORGANIZATION_ID
              ,p_singe_row_attrs_rec  => l_single_row_attrs
              ,p_multi_row_attrs_tbl  => l_multi_row_attrs
              ,p_extra_attrs_rec      => l_extra_attrs_rec
              ,x_return_status        => l_return_status
              ,x_msg_count            => l_msg_count
              ,x_msg_data             => l_msg_data
              );

        EXCEPTION

          WHEN OTHERS THEN
Write_Debug('While calling Validation API EGO_GTIN_ATTRS_PVT.Validate_Attributes: '  || to_char(p_batch_id));
Write_Debug('Error:' || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240)) ;

               FND_MSG_PUB.Add_Exc_Msg
              ( 'EGO_GTIN_ATTRS_PVT',
                'Validate_Attributes' ,
                 SQLERRM ) ;

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR  ;


        END ;

Write_Debug('After calling Validation API EGO_GTIN_ATTRS_PVT.Validate_Attributes l_return_status, l_msg_count='||l_return_status||','||l_msg_count);

        IF l_return_status <> G_RET_STS_SUCCESS THEN

          x_return_status := G_RET_STS_WARNING ;
          UPDATE EGO_ITM_USR_ATTR_INTRFC
          SET PROCESS_STATUS = G_PS_ERROR
          WHERE DATA_SET_ID = p_batch_id
            AND ATTR_GROUP_TYPE IN (G_EGO_ITEM_GTIN_ATTRS , G_EGO_ITEM_GTIN_MULTI_ATTRS)
            AND INVENTORY_ITEM_ID = i.INVENTORY_ITEM_ID
            AND ORGANIZATION_ID = i.ORGANIZATION_ID
            AND CHANGE_ID = i.CHANGE_ID
            AND CHANGE_LINE_ID = i.CHANGE_LINE_ID;

Write_Debug('Marked Item as error in Interface table');


            IF l_msg_count > 0 AND l_return_status <> G_RET_STS_UNEXP_ERROR THEN
              FOR cnt IN 1..l_msg_count LOOP
Write_Debug('Error msg - '||cnt ||': '|| FND_MSG_PUB.Get(p_msg_index => cnt, p_encoded => 'F'));

                l_msg_text := FND_MSG_PUB.Get(p_msg_index => cnt, p_encoded => 'F');

                IF FND_API.to_Boolean(l_write_msg_to_intftbl)
                THEN

                    Insert_Mtl_Intf_Err
                    (   p_transaction_id    => i.TRANSACTION_ID
                     ,  p_bo_identifier     => G_BO_IDENTIFIER
                     ,  p_error_entity_code => G_GDSN_ATTR_ENTITY
                     ,  p_error_table_name  => G_ITEM_USR_ATTR_INTF
                     ,  p_error_column_name => NULL
                     ,  p_error_msg         => l_msg_text
                     ,  p_error_msg_type    => G_ENG_MSG_TYPE_ERROR
                     ,  p_error_msg_name    => null
                    ) ;

                END IF ;

              END LOOP;

            ELSIF l_msg_count > 0 AND l_return_status = G_RET_STS_UNEXP_ERROR THEN

Write_Debug('Unexpected Error msg - '|| l_msg_data);

                l_msg_text := l_msg_data;
                IF FND_API.to_Boolean(l_write_msg_to_intftbl)
                THEN

                    Insert_Mtl_Intf_Err
                    (   p_transaction_id    => i.TRANSACTION_ID
                     ,  p_bo_identifier     => G_BO_IDENTIFIER
                     ,  p_error_entity_code => G_GDSN_ATTR_ENTITY
                     ,  p_error_table_name  => G_ITEM_USR_ATTR_INTF
                     ,  p_error_column_name => NULL
                     ,  p_error_msg         => l_msg_text
                     ,  p_error_msg_type    => G_ENG_MSG_TYPE_ERROR
                     ,  p_error_msg_name    => null
                    ) ;

                END IF ;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;


            END IF; -- IF l_msg_count

        END IF; -- IF l_return_status <> 'S
    END LOOP; -- end loop intf_rows


    -- End of API body.


    -- Standard check of l_commit.
    IF FND_API.To_Boolean( l_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );



    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO VALIDATE_GDSN_ATTR_CHGS;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    Close_Debug_Session;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO VALIDATE_GDSN_ATTR_CHGS;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    Close_Debug_Session;

  WHEN OTHERS THEN
    ROLLBACK TO VALIDATE_GDSN_ATTR_CHGS;
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    Close_Debug_Session;

END VALIDATE_GDSN_ATTR_CHGS ;



/********************************************************************
* API Type      : Derive and Populate Values APIs
* Purpose       : Perform Deriving and Populating values to Interface table
*********************************************************************/

--  API name   : POPULATE_MFGPARTNUM_INTF
--  Type       : Public
--  Pre-reqs   : None.
--  Function   : Create and Start Workflow Process
--  Parameters :
--          IN : p_api_version       IN  NUMBER       Required
--               p_init_msg_list     IN  VARCHAR2     Optional
--                                       Default = NULL
--                                       FND_API.G_FALSE
--                                       FND_API.G_TRUE
--               p_commit            IN  VARCHAR2     Optional
--                                       Default = NULL
--                                       FND_API.G_FALSE
--                                       FND_API.G_TRUE
--               p_validation_level  IN  NUMBER       Optional
--                                       Default = NULL
--                                       Values:
--                                       FND_API.G_VALID_LEVEL_NONE 0
--                                       FND_API.G_VALID_LEVEL_FULL 100
--               p_write_msg_to_intftbl  IN  VARCHAR2     Optional
--                                       Default = NULL
--                                       FND_API.G_FALSE
--                                       FND_API.G_TRUE
--               p_api_caller         IN  VARCHAR2     Optional
--
--         OUT : x_return_status     OUT NOCOPY VARCHAR2(1)
--               x_msg_count         OUT NOCOPY NUMBER
--               x_msg_data          OUT NOCOPY VARCHAR2(2000)
--      Version : Current version         1.0 Initial Creation
--                        Initial version 1.0
--
--      Notes           : Note text--  API name   : POPULATE_MFGPARTNUM_INTF
PROCEDURE POPULATE_MFGPARTNUM_INTF
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_write_msg_to_intftbl IN  VARCHAR2 := NULL --  FND_API.G_FALSE
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
)
IS


    l_api_name      CONSTANT VARCHAR2(30) := 'POPULATE_MFGPARTNUM_INTF';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list    VARCHAR2(1) ;
    l_validation_level NUMBER ;
    l_commit           VARCHAR2(1) ;
    l_write_msg_to_intftbl VARCHAR2(1) ;

    NO_ROWS_IN_INTF_TABLE     EXCEPTION;

    l_msg_data       VARCHAR2(4000);
    l_msg_count      NUMBER;
    l_return_status  VARCHAR2(1);


BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT POPULATE_MFGPARTNUM_INTF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;
    l_write_msg_to_intftbl :=  NVL(p_write_msg_to_intftbl,FND_API.G_FALSE) ;


    -- Initialize message list if l_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_write_msg_to_intftbl:'  || p_write_msg_to_intftbl);
Write_Debug('p_api_caller:'  || p_api_caller);
Write_Debug('p_batch_id: '  || to_char(p_batch_id));
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    -- API body
    -- Logic Here
    -- Init Local Vars
    -- Init Index Text Item Attributes
    IF (p_batch_id IS NULL) THEN
      fnd_message.set_name('EGO', 'EGO_DATA_SET_ID');
      l_msg_data := fnd_msg_pub.get();
      fnd_message.set_name('EGO','EGO_PKG_MAND_VALUES_MISS1');
      fnd_message.set_token('PACKAGE', G_PKG_NAME ||'.'|| l_api_name);
      fnd_message.set_token('VALUE', l_msg_data);
      x_msg_data  := fnd_message.get();
      x_msg_count := 1;
      x_return_status := G_RET_STS_ERROR;
      RETURN;
    END IF;


    BEGIN
      SELECT 'S' INTO l_return_status
      FROM EGO_AML_INTF
      WHERE DATA_SET_ID = p_batch_id
      AND PROCESS_FLAG = G_CM_TO_BE_PROCESSED
      AND ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('EGO','EGO_IPI_NO_LINES');
        x_msg_count := 1;
        x_msg_data :=  fnd_message.get();
        x_return_status := G_RET_STS_SUCCESS;
        RAISE NO_ROWS_IN_INTF_TABLE;
    END;


    -- Pre-Processing for Pending Change Data Poplulation
    UPDATE ego_aml_intf intf
    SET    intf.process_flag = G_CM_DATA_POPULATION
    WHERE  intf.data_set_id = p_batch_id
    AND    intf.process_flag = G_CM_TO_BE_PROCESSED
    AND    EXISTS ( SELECT 'x'
                    FROM EGO_MFG_PART_NUM_CHGS pending_change2
                    WHERE intf.inventory_item_id = pending_change2.inventory_item_id
                    AND intf.organization_id = pending_change2.organization_id
                    AND intf.manufacturer_id = pending_change2.manufacturer_id
                    AND intf.mfg_part_num    = pending_change2.mfg_part_num
                    AND intf.change_line_id  = pending_change2.change_line_id
                    AND intf.transaction_type = DECODE(pending_change2.ACD_TYPE
                                                      , 'ADD', 'CREATE'
                                                      , 'CHANGE', 'UPDATE'
                                                      , 'DELETE', 'DELETE', 'INVALID')
                   ) ;





Write_Debug('Before calling EGO_ITEM_AML_GRP.Populate_Intf_With_Proddata');


      EGO_ITEM_AML_GRP.Populate_Intf_With_Proddata (
      p_api_version            => 1.0
     ,p_commit                 => FND_API.G_FALSE
     ,p_data_set_id            => p_batch_id
     ,p_pf_to_process          => G_CM_TO_BE_PROCESSED -- p_pf_to_process
     ,p_pf_after_population    => G_CM_TO_BE_PROCESSED -- p_pf_after_population
     ,x_return_status          => l_return_status
     ,x_msg_count              => l_msg_count
     ,x_msg_data               => l_msg_data
     ) ;

Write_Debug('After calling EGO_ITEM_AML_GRP.Populate_Intf_With_Proddata: Return Status: ' || l_return_status );


      IF l_return_status <> G_RET_STS_SUCCESS
      THEN

          x_return_status  :=   l_return_status ;
          x_msg_count      :=   l_msg_count ;
          x_msg_data       :=   l_msg_data ;

          RAISE FND_API.G_EXC_ERROR ;
      END IF ;



Write_Debug('Populate intf table with prod data for UPDATE done ' );


      UPDATE ego_aml_intf intf
      SET     (intf.mrp_planning_code
              ,intf.description
              ,intf.first_article_status
              ,intf.approval_status
              ,intf.start_date
              ,intf.end_date
              ,intf.process_flag
              -- ,attribute_category
              -- ,attribute1
              -- ,attribute2
              -- ,attribute3
              -- ,attribute4
              -- ,attribute5
              -- ,attribute6
              -- ,attribute7
              -- ,attribute8
              -- ,attribute9
              -- ,attribute10
              -- ,attribute11
              -- ,attribute12
              -- ,attribute13
              -- ,attribute14
              -- ,attribute15
              )
         = (SELECT
               DECODE(intf.mrp_planning_code,EGO_ITEM_PUB.G_INTF_NULL_NUM,NULL,
                                             NULL,pending_change.mrp_planning_code,
                                             intf.mrp_planning_code),
               DECODE(intf.description,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                             NULL,pending_change.description,
                                             intf.description),
               DECODE(intf.first_article_status,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                             NULL,pending_change.first_article_status,
                                             intf.first_article_status),
               DECODE(intf.approval_status,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
                                             NULL,pending_change.approval_status,
                                             intf.approval_status),
               DECODE(intf.start_date,EGO_ITEM_PUB.G_INTF_NULL_DATE,NULL,
                                             NULL,pending_change.start_date,
                                             intf.start_date),
               DECODE(intf.end_date,EGO_ITEM_PUB.G_INTF_NULL_DATE,NULL,
                                             NULL,pending_change.end_date,
                                             intf.end_date),
               G_CM_TO_BE_PROCESSED
               -- NO Needt copy for DFF in R12
               -- , DECODE(intf.attribute_category,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute_category,
               --                               intf.attribute_category),
               -- DECODE(intf.attribute1,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute1,
               --                               intf.attribute1),
               -- DECODE(intf.attribute2,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute2,
               --                               intf.attribute2),
               -- DECODE(intf.attribute3,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute3,
               --                               intf.attribute3),
               -- DECODE(intf.attribute4,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute4,
               --                               intf.attribute4),
               -- DECODE(intf.attribute5,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute5,
               --                               intf.attribute5),
               -- DECODE(intf.attribute6,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute6,
               --                               intf.attribute6),
               -- DECODE(intf.attribute7,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute7,
               --                               intf.attribute7),
               -- DECODE(intf.attribute8,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute8,
               --                               intf.attribute8),
               -- DECODE(intf.attribute9,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute9,
               --                               intf.attribute9),
               -- DECODE(intf.attribute10,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute10,
               --                               intf.attribute10),
               -- DECODE(intf.attribute11,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute11,
               --                               intf.attribute11),
               -- DECODE(intf.attribute12,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute12,
               --                               intf.attribute12),
               -- DECODE(intf.attribute13,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute13,
               --                               intf.attribute13),
               -- DECODE(intf.attribute14,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute14,
               --                               intf.attribute14),
               -- DECODE(intf.attribute15,EGO_ITEM_PUB.G_INTF_NULL_CHAR,NULL,
               --                               NULL,pending_change.attribute15,
               --                               intf.attribute15)
            FROM EGO_MFG_PART_NUM_CHGS pending_change
            WHERE intf.inventory_item_id = pending_change.inventory_item_id
            AND intf.organization_id = pending_change.organization_id
            AND intf.manufacturer_id = pending_change.manufacturer_id
            AND intf.mfg_part_num    = pending_change.mfg_part_num
            AND intf.change_line_id  = pending_change.change_line_id
            AND intf.transaction_type = DECODE(pending_change.ACD_TYPE, 'ADD', 'CREATE'
                                                , 'CHANGE', 'UPDATE'
                                                , 'DELETE', 'DELETE', 'INVALID')
          )
      WHERE data_set_id = p_batch_id
      AND process_flag = G_CM_DATA_POPULATION
      -- AND transaction_type = EGO_ITEM_PUB.G_TTYPE_UPDATE
      AND (   NVL(mrp_planning_code,EGO_ITEM_PUB.G_INTF_NULL_NUM)
                  <> EGO_ITEM_PUB.G_INTF_NULL_NUM
              OR
              NVL(description,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
                  <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              OR
              NVL(first_article_status,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
                  <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              OR
              NVL(approval_status,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
                  <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              OR
              NVL(start_date,EGO_ITEM_PUB.G_INTF_NULL_DATE)
                  <> EGO_ITEM_PUB.G_INTF_NULL_DATE
              OR
              NVL(end_date,EGO_ITEM_PUB.G_INTF_NULL_DATE)
                  <> EGO_ITEM_PUB.G_INTF_NULL_DATE
              -- OR
              -- NVL(attribute_category,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute1,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute2,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute3,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute4,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute5,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute6,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute7,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute8,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute9,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute10,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute11,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute12,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute13,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute14,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
              -- OR
              -- NVL(attribute15,EGO_ITEM_PUB.G_INTF_NULL_CHAR)
              --     <> EGO_ITEM_PUB.G_INTF_NULL_CHAR
           ) ;
       --  I don't think we need this
       -- AND EXISTS WHEN ( SELECT 'x'
       --                   FROM EGO_MFG_PART_NUM_CHGS pending_change2
       --                   WHERE intf.inventory_item_id = pending_change2.inventory_item_id
       --                   AND intf.organization_id = pending_change2.organization_id
       --                   AND intf.manufacturer_id = pending_change2.manufacturer_id
       --                   AND intf.mfg_part_num    = pending_change2.mfg_part_num
       --                   AND intf.change_line_id  = pending_change2.change_line_id
       --                   AND intf.transaction_type = DECODE(pending_change2.ACD_TYPE, 'ADD', 'CREATE'
       --                                                    , 'CHANGE', 'UPDATE'
       --                                                    , 'DELETE', 'DELETE', 'INVALID')
       --     ;


Write_Debug('After Populating intf table with prod data for UPDATE done ' );

    -- End of API body.


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


EXCEPTION
  WHEN NO_ROWS_IN_INTF_TABLE THEN
      NULL;

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO POPULATE_MFGPARTNUM_INTF;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO POPULATE_MFGPARTNUM_INTF;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN OTHERS THEN
    ROLLBACK TO POPULATE_MFGPARTNUM_INTF;
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;



END POPULATE_MFGPARTNUM_INTF ;




--  API name   : POPULATE_EXISTING_CHANGE
--  Type       : Public
--  Pre-reqs   : None.
--  Function   : Create and Start Workflow Process
--  Parameters :
--          IN : p_api_version       IN  NUMBER       Required
--               p_init_msg_list     IN  VARCHAR2     Optional
--                                       Default = NULL
--                                       FND_API.G_FALSE
--                                       FND_API.G_TRUE
--               p_commit            IN  VARCHAR2     Optional
--                                       Default = NULL
--                                       FND_API.G_FALSE
--                                       FND_API.G_TRUE
--               p_validation_level  IN  NUMBER       Optional
--                                       Default = NULL
--                                       Values:
--                                       FND_API.G_VALID_LEVEL_NONE 0
--                                       FND_API.G_VALID_LEVEL_FULL 100
--               p_write_msg_to_intftbl  IN  VARCHAR2     Optional
--                                       Default = NULL
--                                       FND_API.G_FALSE
--                                       FND_API.G_TRUE
--               p_api_caller         IN  VARCHAR2     Optional
--
--         OUT : x_return_status     OUT NOCOPY VARCHAR2(1)
--               x_msg_count         OUT NOCOPY NUMBER
--               x_msg_data          OUT NOCOPY VARCHAR2(2000)
--      IN OUT :
--               x_item_key          IN OUT NOCOPY  VARCHAR2
--                                       Identifies workflow item key
--      Version : Current version         1.0 Initial Creation
--                        Initial version 1.0
--
PROCEDURE POPULATE_EXISTING_CHANGE
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_write_msg_to_intftbl IN  VARCHAR2 := NULL --  FND_API.G_FALSE
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
 ,  p_change_number     IN  VARCHAR2  := NULL
 ,  p_process_entity    IN  VARCHAR2  := NULL
 ,  p_cm_process_type   IN  VARCHAR2  := NULL
 ,  p_item_id           IN  NUMBER    := NULL
 ,  p_org_id            IN  NUMBER    := NULL
 ,  p_create_new_flag   IN  VARCHAR2  := NULL -- N: New, E: Add to Existing
)
IS

    l_api_name      CONSTANT VARCHAR2(30) := 'POPULATE_EXISTING_CHANGE';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list    VARCHAR2(1) ;
    l_validation_level NUMBER ;
    l_commit           VARCHAR2(1) ;
    l_write_msg_to_intftbl VARCHAR2(1) ;

    --------------------------------------------
    -- Long Dynamic SQL String
    --------------------------------------------
    l_dyn_sql             VARCHAR2(10000);

    l_intf_table              DBMS_SQL.VARCHAR2_TABLE;
    l_intf_batch_id_col       DBMS_SQL.VARCHAR2_TABLE;
    l_intf_proc_flag_col      DBMS_SQL.VARCHAR2_TABLE;
    l_intf_ri_seq_id_col      DBMS_SQL.VARCHAR2_TABLE;
    l_intf_attr_grp_type      DBMS_SQL.VARCHAR2_TABLE;
    l_intf_change_number_col  DBMS_SQL.VARCHAR2_TABLE;

    l_error_msg            VARCHAR2(2000) ;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT POPULATE_EXISTING_CHANGE;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;
    l_write_msg_to_intftbl :=  NVL(p_write_msg_to_intftbl,FND_API.G_FALSE) ;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;
Write_Debug('After Open_Debug_Session');


Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_batch_id: '  || to_char(p_batch_id));
Write_Debug('p_change_number: '  || p_change_number );
Write_Debug('p_process_entity:'  || p_process_entity);
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    -- API body
    -- Logic Here

    -- Get Process Interface Table  Definitions
    Get_Process_IntfTable_Def(p_process_entity          => p_process_entity
                            , x_intf_table              => l_intf_table
                            , x_intf_batch_id_col       => l_intf_batch_id_col
                            , x_intf_proc_flag_col      => l_intf_proc_flag_col
                            , x_intf_ri_seq_id_col      => l_intf_ri_seq_id_col
                            , x_intf_attr_grp_type      => l_intf_attr_grp_type
                            , x_intf_chg_notice_col     => l_intf_change_number_col
                            ) ;


    FOR i IN 1..l_intf_table.COUNT LOOP

Write_Debug('Check Existing CO and populate CO Id to INTF Table. . .' );


        -- If it's BOM, we need to first derive Change Id based on Change Notice populated
        -- in Bom's Interface Tables
        IF  l_intf_table(i) LIKE 'BOM%' THEN

Write_Debug('Check Existing CO and populate CO Id for BOM INTF Table using Change Notice Info populated to Intf Table. . .' );

            l_dyn_sql := '' ;
            l_dyn_sql :=              ' UPDATE ' || l_intf_table(i)  || ' INTF ';
            l_dyn_sql := l_dyn_sql || ' SET change_id = NVL(( SELECT eec.change_id ' ;
            l_dyn_sql := l_dyn_sql ||                      ' FROM  eng_engineering_changes eec ' ;
            l_dyn_sql := l_dyn_sql ||                      ' WHERE eec.organization_id = INTF.organization_id ' ;
            l_dyn_sql := l_dyn_sql ||                      ' AND eec.change_notice = INTF.' || l_intf_change_number_col(i) ;
            l_dyn_sql := l_dyn_sql ||                      ' ) , -100)  ' ;
            l_dyn_sql := l_dyn_sql || ' WHERE INTF.' || l_intf_batch_id_col(i) || ' = :BATCH_ID ' ;
            l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_proc_flag_col(i) || ' = ' || G_CM_TO_BE_PROCESSED  ;
            l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_change_number_col(i) || ' IS NOT NULL ' ;
            l_dyn_sql := l_dyn_sql || ' AND   INTF.change_id IS NULL ';
Write_Debug(l_dyn_sql);
            EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id ;
        END IF ;


Write_Debug('Populate CO Id from the batch details. . .' );
        l_dyn_sql := '' ;
        l_dyn_sql :=              ' UPDATE ' || l_intf_table(i)  || ' INTF ';
        l_dyn_sql := l_dyn_sql || ' SET change_id = NVL(( SELECT eec.change_id ' ;
        l_dyn_sql := l_dyn_sql ||                      ' FROM  eng_engineering_changes eec ' ;
        l_dyn_sql := l_dyn_sql ||                      ' WHERE eec.organization_id = INTF.organization_id ' ;
        l_dyn_sql := l_dyn_sql ||                      ' AND eec.change_notice = ''' || p_change_number ||'''';
        l_dyn_sql := l_dyn_sql ||                      ' ) , -100)  ' ;
        l_dyn_sql := l_dyn_sql || ' WHERE INTF.' || l_intf_batch_id_col(i) || ' = :BATCH_ID ' ;
        l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_proc_flag_col(i) || ' = ' || G_CM_TO_BE_PROCESSED  ;
        l_dyn_sql := l_dyn_sql || ' AND   INTF.change_id IS NULL ';
        IF l_intf_attr_grp_type(i) IS NOT NULL
        THEN
            l_dyn_sql := l_dyn_sql || ' AND  ' || Get_Attr_Group_Type_Condition('INTF.', l_intf_attr_grp_type(I));
        END IF ;


Write_Debug(l_dyn_sql);

        EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id ;

        IF l_validation_level > FND_API.G_VALID_LEVEL_NONE AND
           FND_API.to_Boolean(l_write_msg_to_intftbl)
        THEN

Write_Debug('Insert Error Message for the records which can not find CO for the Org. . .' );

            FND_MESSAGE.SET_NAME('ENG','ENG_IMPT_CO_NOT_FOUND');
            FND_MESSAGE.SET_TOKEN('CHANGE_NUMBER', p_change_number);
            FND_MESSAGE.SET_TOKEN('BATCH_ID', to_char(p_batch_id));
            l_error_msg := FND_MESSAGE.GET;

            l_dyn_sql := '';
            l_dyn_sql :=              'INSERT INTO MTL_INTERFACE_ERRORS ';
            l_dyn_sql := l_dyn_sql || '( ';
            l_dyn_sql := l_dyn_sql || ' ORGANIZATION_ID ,   ';
            l_dyn_sql := l_dyn_sql || ' UNIQUE_ID ,   ';
            l_dyn_sql := l_dyn_sql || ' TRANSACTION_ID ,   ';
            l_dyn_sql := l_dyn_sql || ' LAST_UPDATE_DATE ,   ';
            l_dyn_sql := l_dyn_sql || ' LAST_UPDATED_BY ,   ';
            l_dyn_sql := l_dyn_sql || ' CREATION_DATE,    ';
            l_dyn_sql := l_dyn_sql || ' CREATED_BY ,   ';
            l_dyn_sql := l_dyn_sql || ' LAST_UPDATE_LOGIN ,   ';
            l_dyn_sql := l_dyn_sql || ' TABLE_NAME ,   ';
            l_dyn_sql := l_dyn_sql || ' MESSAGE_NAME ,   ';
            l_dyn_sql := l_dyn_sql || ' COLUMN_NAME ,   ';
            l_dyn_sql := l_dyn_sql || ' REQUEST_ID  ,   ';
            l_dyn_sql := l_dyn_sql || ' PROGRAM_APPLICATION_ID ,   ';
            l_dyn_sql := l_dyn_sql || ' PROGRAM_ID ,   ';
            l_dyn_sql := l_dyn_sql || ' PROGRAM_UPDATE_DATE ,   ';
            l_dyn_sql := l_dyn_sql || ' ERROR_MESSAGE ,   ';
            l_dyn_sql := l_dyn_sql || ' ENTITY_IDENTIFIER ,   ';
            l_dyn_sql := l_dyn_sql || ' BO_IDENTIFIER , ';
            l_dyn_sql := l_dyn_sql || ' MESSAGE_TYPE ';
            l_dyn_sql := l_dyn_sql || ') ';
            l_dyn_sql := l_dyn_sql || 'SELECT ';
            l_dyn_sql := l_dyn_sql || ' INTF.ORGANIZATION_ID ,   ';
            l_dyn_sql := l_dyn_sql || ' NULL ,   ';
            l_dyn_sql := l_dyn_sql || ' INTF.TRANSACTION_ID ,   ';
            l_dyn_sql := l_dyn_sql || ' SYSDATE ,   ';
            l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.user_id ,   ';
            l_dyn_sql := l_dyn_sql || ' SYSDATE ,    ';
            l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.user_id ,   ';
            l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.login_id ,   ';
            l_dyn_sql := l_dyn_sql || '''' ||l_intf_table(i) ||''', ' ;
            l_dyn_sql := l_dyn_sql || ' ''ENG_IMPT_CO_NOT_FOUND'',   ';
            l_dyn_sql := l_dyn_sql || ' NULL ,   ';
            l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.conc_request_id ,   ';
            l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.prog_appl_id,   ';
            l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.conc_program_id ,   ';
            l_dyn_sql := l_dyn_sql || ' SYSDATE ,   ';
            l_dyn_sql := l_dyn_sql || ''''||Escape_Single_Quote(l_error_msg)||''' , ' ;
            l_dyn_sql := l_dyn_sql || ''''||G_ERROR_ENTITY_CODE||''' , ' ;
            l_dyn_sql := l_dyn_sql || ''''||G_BO_IDENTIFIER||''' , ' ;
            l_dyn_sql := l_dyn_sql || ''''||G_ENG_MSG_TYPE_ERROR||'''' ;
            l_dyn_sql := l_dyn_sql || ' FROM ' || l_intf_table(i)  || ' INTF ';
            l_dyn_sql := l_dyn_sql || ' WHERE INTF.' || l_intf_batch_id_col(i) || ' = :BATCH_ID ' ;
            l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_proc_flag_col(i) || ' = ' || G_CM_TO_BE_PROCESSED;
            l_dyn_sql := l_dyn_sql || ' AND   INTF.change_id = -100 ';

            IF l_intf_attr_grp_type(i) IS NOT NULL
            THEN
                l_dyn_sql := l_dyn_sql || ' AND  ' || Get_Attr_Group_Type_Condition('INTF.', l_intf_attr_grp_type(I));
            END IF ;


Write_Debug(l_dyn_sql);

            EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id ;


        END IF;

Write_Debug('Update Process Flag to Error for records which can not find CO for the Org. . .' );

        l_dyn_sql := '' ;
        l_dyn_sql :=              ' UPDATE ' || l_intf_table(i)  || ' INTF ';
        l_dyn_sql := l_dyn_sql || ' SET INTF.change_id = null ' ;

        -- If validation level is more than None
        -- set the process flag to ERROR:3
        IF l_validation_level > FND_API.G_VALID_LEVEL_NONE
        THEN
            l_dyn_sql := l_dyn_sql || '   , INTF.' || l_intf_proc_flag_col(i) || ' = ' || G_PS_ERROR  ;
        END IF ;

        l_dyn_sql := l_dyn_sql || ' WHERE INTF.' || l_intf_batch_id_col(i) || ' = :BATCH_ID ' ;
        l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_proc_flag_col(i) || ' = ' || G_CM_TO_BE_PROCESSED;
        l_dyn_sql := l_dyn_sql || ' AND   INTF.change_id = -100 ';

        IF l_intf_attr_grp_type(i) IS NOT NULL
        THEN
            l_dyn_sql := l_dyn_sql || ' AND  ' || Get_Attr_Group_Type_Condition('INTF.', l_intf_attr_grp_type(I));
        END IF ;

Write_Debug(l_dyn_sql);

        EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id ;
        IF SQL%FOUND AND NVL(p_create_new_flag, 'E') = 'E' THEN -- Changed for bug 9398720
          x_return_status := G_RET_STS_WARNING ;
        END IF ;

    END LOOP ;


Write_Debug('set change number to batch option temporarily. . .' );
    -- Need to temporarily set change number to batch
    -- to derive the change order in subsequence CM Import API call
    -- like Item Import
    -- First Item Import would call CM Import API to process Item/Item Rev Entity,
    -- Second it would then call CM Import API to process other entity (all entity)
    UPDATE EGO_IMPORT_OPTION_SETS
    SET   CHANGE_NOTICE = p_change_number
        , LAST_UPDATE_DATE = SYSDATE
        , LAST_UPDATED_BY = FND_GLOBAL.user_id
        , LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
    WHERE BATCH_ID = p_batch_id  ;


    -- End of API body.


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO POPULATE_EXISTING_CHANGE;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO POPULATE_EXISTING_CHANGE;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN OTHERS THEN
    ROLLBACK TO POPULATE_EXISTING_CHANGE;
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


END POPULATE_EXISTING_CHANGE ;



--  API name   : POPULATE_EXISTING_REV_ITEMS
--  Type       : Public
--  Pre-reqs   : None.
--  Function   :
--  Parameters :
--          IN : p_api_version       IN  NUMBER       Required
--               p_init_msg_list     IN  VARCHAR2     Optional
--                                       Default = NULL
--                                       FND_API.G_FALSE
--                                       FND_API.G_TRUE
--               p_commit            IN  VARCHAR2     Optional
--                                       Default = NULL
--                                       FND_API.G_FALSE
--                                       FND_API.G_TRUE
--               p_validation_level  IN  NUMBER       Optional
--                                       Default = NULL
--                                       Values:
--                                       FND_API.G_VALID_LEVEL_NONE 0
--                                       FND_API.G_VALID_LEVEL_FULL 100
--               p_write_msg_to_intftbl  IN  VARCHAR2     Optional
--                                       Default = NULL
--                                       FND_API.G_FALSE
--                                       FND_API.G_TRUE
--               p_api_caller         IN  VARCHAR2     Optional
--
--         OUT : x_return_status     OUT NOCOPY VARCHAR2(1)
--               x_msg_count         OUT NOCOPY NUMBER
--               x_msg_data          OUT NOCOPY VARCHAR2(2000)
--      IN OUT :
--               x_item_key          IN OUT NOCOPY  VARCHAR2
--                                       Identifies workflow item key
--      Version : Current version         1.0 Initial Creation
--                        Initial version 1.0
--
PROCEDURE POPULATE_EXISTING_REV_ITEMS
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_write_msg_to_intftbl IN  VARCHAR2 := NULL --  FND_API.G_FALSE
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
 ,  p_process_entity    IN  VARCHAR2  := NULL
 ,  p_cm_process_type   IN  VARCHAR2  := NULL
 ,  p_item_id           IN  NUMBER    := NULL
 ,  p_org_id            IN  NUMBER    := NULL
)
IS

    l_api_name      CONSTANT VARCHAR2(30) := 'POPULATE_EXISTING_REV_ITEMS';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list          VARCHAR2(1) ;
    l_validation_level       NUMBER ;
    l_commit                 VARCHAR2(1) ;
    l_write_msg_to_intftbl   VARCHAR2(1) ;
    l_revision_import_policy VARCHAR2(1) ;

    --------------------------------------------
    -- Long Dynamic SQL String
    --------------------------------------------
    l_dyn_sql             VARCHAR2(32000);

    I                     PLS_INTEGER ;
    l_intf_table          DBMS_SQL.VARCHAR2_TABLE;
    l_intf_batch_id_col   DBMS_SQL.VARCHAR2_TABLE;
    l_intf_proc_flag_col  DBMS_SQL.VARCHAR2_TABLE;
    l_intf_ri_seq_id_col  DBMS_SQL.VARCHAR2_TABLE;
    l_intf_attr_grp_type  DBMS_SQL.VARCHAR2_TABLE;
    l_intf_change_number_col  DBMS_SQL.VARCHAR2_TABLE;

    l_msg_data       VARCHAR2(4000);
    l_msg_count      NUMBER;
    l_return_status  VARCHAR2(1);

    l_error_msg            VARCHAR2(2000) ;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT POPULATE_EXISTING_REV_ITEMS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;
    l_write_msg_to_intftbl :=  NVL(p_write_msg_to_intftbl,FND_API.G_FALSE) ;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_write_msg_to_intftbl:'  || p_write_msg_to_intftbl);
Write_Debug('p_api_caller:'  || p_api_caller);
Write_Debug('p_batch_id: '  || to_char(p_batch_id));
Write_Debug('p_process_entity:'  || p_process_entity);
Write_Debug('p_item_id: '  || to_char(p_item_id));
Write_Debug('p_org_id: '  || to_char(p_org_id));
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    -- API body
    -- Logic Here
    -- Init Local Vars

    -- Get Process Interface Table  Definitions
    -- Get Process Interface Table  Definitions
    Get_Process_IntfTable_Def(p_process_entity      => p_process_entity
                            , x_intf_table          => l_intf_table
                            , x_intf_batch_id_col   => l_intf_batch_id_col
                            , x_intf_proc_flag_col  => l_intf_proc_flag_col
                            , x_intf_ri_seq_id_col  => l_intf_ri_seq_id_col
                            , x_intf_attr_grp_type  => l_intf_attr_grp_type
                            , x_intf_chg_notice_col => l_intf_change_number_col
                            ) ;


    -- Get Revision Import Policy
    l_revision_import_policy := GET_REVISION_IMPORT_POLICY(p_batch_id => p_batch_id) ;

Write_Debug('Get Batch Import Option: Revision Import Policy: ' || l_revision_import_policy  );



    FOR i IN 1..l_intf_table.COUNT LOOP

Write_Debug('Check Existing Revised Item and populate REVISED_ITEM_SEQUENCE_ID to INTF Table. . .' );

        l_dyn_sql := '' ;
        l_dyn_sql :=              ' UPDATE ' || l_intf_table(i)  || ' INTF ';
        l_dyn_sql := l_dyn_sql || ' SET INTF.' || l_intf_ri_seq_id_col(i) ;
        -- Bug 5193662 : Populate the rev item id to the child recs and change id to the parent record.
        if l_intf_table(i) = G_ITEM_INTF then
          l_dyn_sql := l_dyn_sql ||                   '  = ENG_CHANGE_IMPORT_UTIL.FIND_REV_ITEM_REC( INTF.change_id ';
        else
          l_dyn_sql := l_dyn_sql ||                   '  = ENG_CHANGE_IMPORT_UTIL.get_Rev_item_update_parent( INTF.change_id ';
        END IF;

        l_dyn_sql := l_dyn_sql ||                   ', INTF.organization_id ';
        l_dyn_sql := l_dyn_sql ||                   ', INTF.inventory_item_id';


        -- p_revision or p_revision_id
        IF l_intf_table(i) = G_ITEM_REV_INTF
        THEN
          l_dyn_sql := l_dyn_sql ||                   ', INTF.revision ';
        ELSIF l_intf_table(i) =  G_ITEM_USR_ATTR_INTF
        THEN
          l_dyn_sql := l_dyn_sql ||                   ', INTF.revision ';
        ELSE
          l_dyn_sql := l_dyn_sql ||                   ', TO_NUMBER(null)';
        END IF ;


        -- param: p_default_seq_id
        IF l_validation_level > FND_API.G_VALID_LEVEL_NONE
        THEN
          l_dyn_sql := l_dyn_sql ||                   ', -100';
        ELSE
          l_dyn_sql := l_dyn_sql ||                   ', TO_NUMBER(null)';
        END IF ;

        -- param: p_revision_import_policy
        l_dyn_sql := l_dyn_sql ||                   ', ''' || l_revision_import_policy || '''';

        l_dyn_sql := l_dyn_sql ||                   ' ) ' ;
        l_dyn_sql := l_dyn_sql || ' WHERE INTF.' || l_intf_batch_id_col(i) || ' = :BATCH_ID ' ;
        l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_proc_flag_col(i) || ' = ' || G_CM_TO_BE_PROCESSED  ;
        l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_ri_seq_id_col(i) || ' IS NULL ';
        l_dyn_sql := l_dyn_sql || ' AND   INTF.change_id IS NOT NULL ';
        IF l_intf_attr_grp_type(i) IS NOT NULL
        THEN
            l_dyn_sql := l_dyn_sql || ' AND  ' || Get_Attr_Group_Type_Condition('INTF.', l_intf_attr_grp_type(I));
        END IF ;


Write_Debug(l_dyn_sql);

        EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id ;


        IF l_validation_level > FND_API.G_VALID_LEVEL_NONE
        THEN
            -- Initialize message list if p_init_msg_list is set to TRUE.
            IF FND_API.to_Boolean(l_write_msg_to_intftbl) THEN

Write_Debug('Insert Error Message for the records which can not find CO for the Org. . .' );

                FND_MESSAGE.SET_NAME('ENG','ENG_IMPT_RI_NOT_FOUND');
                FND_MESSAGE.SET_TOKEN('BATCH_ID', to_char(p_batch_id));
                l_error_msg := FND_MESSAGE.GET;

                l_dyn_sql := '';
                l_dyn_sql :=              'INSERT INTO MTL_INTERFACE_ERRORS ';
                l_dyn_sql := l_dyn_sql || '( ';
                l_dyn_sql := l_dyn_sql || ' ORGANIZATION_ID ,   ';
                l_dyn_sql := l_dyn_sql || ' UNIQUE_ID ,   ';
                l_dyn_sql := l_dyn_sql || ' TRANSACTION_ID ,   ';
                l_dyn_sql := l_dyn_sql || ' LAST_UPDATE_DATE ,   ';
                l_dyn_sql := l_dyn_sql || ' LAST_UPDATED_BY ,   ';
                l_dyn_sql := l_dyn_sql || ' CREATION_DATE,    ';
                l_dyn_sql := l_dyn_sql || ' CREATED_BY ,   ';
                l_dyn_sql := l_dyn_sql || ' LAST_UPDATE_LOGIN ,   ';
                l_dyn_sql := l_dyn_sql || ' TABLE_NAME ,   ';
                l_dyn_sql := l_dyn_sql || ' MESSAGE_NAME ,   ';
                l_dyn_sql := l_dyn_sql || ' COLUMN_NAME ,   ';
                l_dyn_sql := l_dyn_sql || ' REQUEST_ID  ,   ';
                l_dyn_sql := l_dyn_sql || ' PROGRAM_APPLICATION_ID ,   ';
                l_dyn_sql := l_dyn_sql || ' PROGRAM_ID ,   ';
                l_dyn_sql := l_dyn_sql || ' PROGRAM_UPDATE_DATE ,   ';
                l_dyn_sql := l_dyn_sql || ' ERROR_MESSAGE ,   ';
                l_dyn_sql := l_dyn_sql || ' ENTITY_IDENTIFIER ,   ';
                l_dyn_sql := l_dyn_sql || ' BO_IDENTIFIER , ';
                l_dyn_sql := l_dyn_sql || ' MESSAGE_TYPE ';
                l_dyn_sql := l_dyn_sql || ') ';
                l_dyn_sql := l_dyn_sql || 'SELECT ';
                l_dyn_sql := l_dyn_sql || ' INTF.ORGANIZATION_ID ,   ';
                l_dyn_sql := l_dyn_sql || ' NULL ,   ';
                l_dyn_sql := l_dyn_sql || ' INTF.TRANSACTION_ID ,   ';
                l_dyn_sql := l_dyn_sql || ' SYSDATE ,   ';
                l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.user_id ,   ';
                l_dyn_sql := l_dyn_sql || ' SYSDATE ,    ';
                l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.user_id ,   ';
                l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.login_id ,   ';
                l_dyn_sql := l_dyn_sql || '''' ||l_intf_table(i) ||''', ' ;
                l_dyn_sql := l_dyn_sql || ' ''ENG_IMPT_RI_NOT_FOUND'',   ';
                l_dyn_sql := l_dyn_sql || ' NULL ,   ';
                l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.conc_request_id ,   ';
                l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.prog_appl_id,   ';
                l_dyn_sql := l_dyn_sql || ' FND_GLOBAL.conc_program_id ,   ';
                l_dyn_sql := l_dyn_sql || ' SYSDATE ,   ';
                l_dyn_sql := l_dyn_sql || ''''||Escape_Single_Quote(l_error_msg)||''' , ' ;
                l_dyn_sql := l_dyn_sql || ''''||G_ERROR_ENTITY_CODE||''' , ' ;
                l_dyn_sql := l_dyn_sql || ''''||G_BO_IDENTIFIER||''' , ' ;
                l_dyn_sql := l_dyn_sql || ''''||G_ENG_MSG_TYPE_ERROR||'''' ;
                l_dyn_sql := l_dyn_sql || ' FROM ' || l_intf_table(i)  || ' INTF ';
                l_dyn_sql := l_dyn_sql || ' WHERE INTF.' || l_intf_batch_id_col(i) || ' = :BATCH_ID ' ;
                l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_proc_flag_col(i) || ' = ' || G_CM_TO_BE_PROCESSED;
                l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_ri_seq_id_col(i) || ' = -100' ;
                IF l_intf_attr_grp_type(i) IS NOT NULL
                THEN
                    l_dyn_sql := l_dyn_sql || ' AND  ' || Get_Attr_Group_Type_Condition('INTF.', l_intf_attr_grp_type(I));
                END IF ;

Write_Debug(l_dyn_sql);

                EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id ;

            END IF;

Write_Debug('Update Process Flag to Error for records which can not find CO for the Org. . .' );

            l_dyn_sql := '' ;
            l_dyn_sql :=              ' UPDATE ' || l_intf_table(i)  || ' INTF ';
            l_dyn_sql := l_dyn_sql || ' SET INTF.' || l_intf_ri_seq_id_col(i) || '  = null ' ;
            l_dyn_sql := l_dyn_sql || '   , INTF.' || l_intf_proc_flag_col(i) || ' = ' || G_PS_ERROR  ;
            l_dyn_sql := l_dyn_sql || ' WHERE INTF.' || l_intf_batch_id_col(i) || ' = :BATCH_ID ' ;
            l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_proc_flag_col(i) || ' = ' || G_CM_TO_BE_PROCESSED;
            l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_ri_seq_id_col(i) || ' = -100' ;
            IF l_intf_attr_grp_type(i) IS NOT NULL
            THEN
                l_dyn_sql := l_dyn_sql || ' AND  ' || Get_Attr_Group_Type_Condition('INTF.', l_intf_attr_grp_type(I));
            END IF ;

Write_Debug(l_dyn_sql);

            EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id ;

            IF SQL%FOUND THEN
              x_return_status := G_RET_STS_WARNING ;
            END IF ;


        END IF ; -- Validation Mode is not NONE



        IF l_intf_table(i) = G_ITEM_AML_INTF
        THEN

Write_Debug('Calling POPULATE_MFGPARTNUM_INTF. . . ' );

            POPULATE_MFGPARTNUM_INTF
            (   p_api_version       => 1.0
             ,  p_init_msg_list     => FND_API.G_FALSE
             ,  p_commit            => FND_API.G_FALSE
             ,  p_validation_level  => FND_API.G_VALID_LEVEL_FULL
             ,  x_return_status        => l_return_status
             ,  x_msg_count            => l_msg_count
             ,  x_msg_data             => l_msg_data
             ,  p_write_msg_to_intftbl =>  FND_API.G_TRUE
             ,  p_api_caller        =>  NULL
             ,  p_debug             => p_debug
             ,  p_output_dir        => p_output_dir
             ,  p_debug_filename    => p_debug_filename
             ,  p_batch_id          => p_batch_id
            ) ;


Write_Debug('After  POPULATE_MFGPARTNUM_INTF: Return Staus ' || l_return_status );


            IF l_return_status <> G_RET_STS_SUCCESS
            THEN

                x_return_status  :=   l_return_status ;
                x_msg_count      :=   l_msg_count ;
                x_msg_data       :=   l_msg_data ;

                RAISE FND_API.G_EXC_ERROR ;
            END IF ;

        END IF ;



    END LOOP ;


    -- End of API body.


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO POPULATE_EXISTING_REV_ITEMS;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO POPULATE_EXISTING_REV_ITEMS;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN OTHERS THEN

    ROLLBACK TO POPULATE_EXISTING_REV_ITEMS;
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


END POPULATE_EXISTING_REV_ITEMS;



--  API name   : UPDATE_PROCESS_STATUS
--  Type       : Public
--  Pre-reqs   : None.
--  Function   :
--  Parameters :
--          IN : p_api_version       IN  NUMBER       Required
--               p_init_msg_list     IN  VARCHAR2     Optional
--                                       Default = NULL
--                                       FND_API.G_FALSE
--                                       FND_API.G_TRUE
--               p_commit            IN  VARCHAR2     Optional
--                                       Default = NULL
--                                       FND_API.G_FALSE
--                                       FND_API.G_TRUE
--               p_validation_level  IN  NUMBER       Optional
--                                       Default = NULL
--                                       Values:
--                                       FND_API.G_VALID_LEVEL_NONE 0
--                                       FND_API.G_VALID_LEVEL_FULL 100
--               p_write_msg_to_intftbl  IN  VARCHAR2     Optional
--                                       Default = NULL
--                                       FND_API.G_FALSE
--                                       FND_API.G_TRUE
--               p_api_caller         IN  VARCHAR2     Optional
--
--         OUT : x_return_status     OUT NOCOPY VARCHAR2(1)
--               x_msg_count         OUT NOCOPY NUMBER
--               x_msg_data          OUT NOCOPY VARCHAR2(2000)
--      IN OUT :
--               x_item_key          IN OUT NOCOPY  VARCHAR2
--                                       Identifies workflow item key
--      Version : Current version         1.0 Initial Creation
--                        Initial version 1.0
--
PROCEDURE UPDATE_PROCESS_STATUS
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_write_msg_to_intftbl IN  VARCHAR2 := NULL --  FND_API.G_FALSE
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
 ,  p_from_status       IN  NUMBER
 ,  p_to_status         IN  NUMBER
 ,  p_process_entity    IN  VARCHAR2  := NULL
 ,  p_item_id           IN  NUMBER    := NULL
 ,  p_org_id            IN  NUMBER    := NULL
 ,  p_transaction_id    IN  NUMBER    := NULL
)
IS

    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_PROCESS_STATUS';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list    VARCHAR2(1) ;
    l_validation_level NUMBER ;
    l_commit           VARCHAR2(1) ;
    l_write_msg_to_intftbl VARCHAR2(1) ;

    --------------------------------------------
    -- Long Dynamic SQL String
    --------------------------------------------
    l_dyn_sql             VARCHAR2(10000);

    I                     PLS_INTEGER ;
    l_intf_table          DBMS_SQL.VARCHAR2_TABLE;
    l_intf_batch_id_col   DBMS_SQL.VARCHAR2_TABLE;
    l_intf_proc_flag_col  DBMS_SQL.VARCHAR2_TABLE;
    l_intf_ri_seq_id_col  DBMS_SQL.VARCHAR2_TABLE;
    l_intf_attr_grp_type  DBMS_SQL.VARCHAR2_TABLE;
    l_intf_change_number_col  DBMS_SQL.VARCHAR2_TABLE;

    l_msg_data       VARCHAR2(4000);
    l_msg_count      NUMBER;
    l_return_status  VARCHAR2(1);

    l_error_msg            VARCHAR2(2000) ;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT UPDATE_PROCESS_STATUS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;
    l_write_msg_to_intftbl :=  NVL(p_write_msg_to_intftbl,FND_API.G_FALSE) ;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_write_msg_to_intftbl:'  || p_write_msg_to_intftbl);
Write_Debug('p_api_caller:'  || p_api_caller);
Write_Debug('p_batch_id: '  || to_char(p_batch_id));
Write_Debug('p_from_status: '  || to_char(p_from_status));
Write_Debug('p_to_status: '  || to_char(p_to_status));
Write_Debug('p_process_entity:'  || p_process_entity);
Write_Debug('p_item_id: '  || to_char(p_item_id));
Write_Debug('p_org_id: '  || to_char(p_org_id));
Write_Debug('p_transaction_id: '  || to_char(p_transaction_id));
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    -- API body
    -- Logic Here
    -- Init Local Vars

    -- Get Process Interface Table  Definitions
    Get_Process_IntfTable_Def(p_process_entity      => p_process_entity
                            , x_intf_table          => l_intf_table
                            , x_intf_batch_id_col   => l_intf_batch_id_col
                            , x_intf_proc_flag_col  => l_intf_proc_flag_col
                            , x_intf_ri_seq_id_col  => l_intf_ri_seq_id_col
                            , x_intf_attr_grp_type  => l_intf_attr_grp_type
                            , x_intf_chg_notice_col => l_intf_change_number_col
                            ) ;


    FOR i IN 1..l_intf_table.COUNT LOOP

Write_Debug('Update process status to INTF Table. . .' );

        l_dyn_sql := '' ;
        l_dyn_sql :=              ' UPDATE ' || l_intf_table(i)  || ' INTF ';
        l_dyn_sql := l_dyn_sql || ' SET INTF.' || l_intf_proc_flag_col(i) || '  = ' || p_to_status  ;


        IF l_intf_table(i) = G_ITEM_USR_ATTR_INTF AND p_transaction_id IS NOT NULL
        THEN

            l_dyn_sql := l_dyn_sql || ' WHERE  INTF.' || l_intf_proc_flag_col(i) || ' = ' || p_from_status  ;
            l_dyn_sql := l_dyn_sql || ' AND (INTF.DATA_SET_ID, INTF.ROW_IDENTIFIER, INTF.ATTR_GROUP_ID ) ' ;
            l_dyn_sql := l_dyn_sql || '  IN (SELECT rec_grp.DATA_SET_ID, rec_grp.ROW_IDENTIFIER, rec_grp.ATTR_GROUP_ID ' ;
            l_dyn_sql := l_dyn_sql ||      ' FROM ' || l_intf_table(i) || ' rec_grp ' ;
            l_dyn_sql := l_dyn_sql ||      ' WHERE rec_grp.transaction_id =  :TRANSACTION_ID ) ' ;

            EXECUTE IMMEDIATE l_dyn_sql USING p_transaction_id ;

        ELSIF l_intf_table(i) <> G_ITEM_USR_ATTR_INTF AND  p_transaction_id IS NOT NULL
        THEN
            l_dyn_sql := l_dyn_sql || ' WHERE INTF.transaction_id   =  :TRANSACTION_ID ' ;
            l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_proc_flag_col(i) || ' = ' || p_from_status  ;

            EXECUTE IMMEDIATE l_dyn_sql USING p_transaction_id ;

        ELSE
            l_dyn_sql := l_dyn_sql || ' WHERE INTF.' || l_intf_batch_id_col(i) || ' = :BATCH_ID ' ;
            l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_proc_flag_col(i) || ' = ' || p_from_status  ;
            l_dyn_sql := l_dyn_sql || ' AND   INTF.' || l_intf_ri_seq_id_col(i) || ' IS NOT NULL ';
            l_dyn_sql := l_dyn_sql || ' AND   INTF.change_id IS NOT NULL ';

            IF l_intf_attr_grp_type(i) IS NOT NULL
            THEN
                l_dyn_sql := l_dyn_sql || ' AND  ' || Get_Attr_Group_Type_Condition('INTF.', l_intf_attr_grp_type(I));
            END IF ;

            EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id ;

        END IF ;


Write_Debug(l_dyn_sql);


    END LOOP ;
    -- End of API body.


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_PROCESS_STATUS;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_PROCESS_STATUS;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN OTHERS THEN
    ROLLBACK TO UPDATE_PROCESS_STATUS;
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


END UPDATE_PROCESS_STATUS;

/* Bug 5193662 : This function calls FIND_REV_ITEM_REC to populate revision id in the Intf recs with process'
                 flag as 5. But same time the parent row is marked with the change id as its sure that the
                 Item has been added to the change as rev item if the rev item record is found.
*/
FUNCTION get_Rev_item_update_parent ( p_change_id              IN NUMBER
                           , p_organization_id        IN NUMBER
                           , p_revised_item_id        IN NUMBER
                           , p_revision               IN VARCHAR2
                           , p_default_seq_id         IN NUMBER := NULL
                           , p_revision_import_policy IN VARCHAR2 := NULL
                            )
RETURN NUMBER
IS

    l_rev_item_seq_id NUMBER ;
    l_request_id NUMBER;
BEGIN

l_rev_item_seq_id := FIND_REV_ITEM_REC ( p_change_id              => p_change_id
                             , p_organization_id        => p_organization_id
                             , p_revised_item_id        => p_revised_item_id
                             , p_revision           => p_revision
                             , p_default_seq_id         => p_default_seq_id
                             , p_revision_import_policy => p_revision_import_policy
                             ) ;

select FND_GLOBAL.CONC_REQUEST_ID INTO l_request_id from dual;
if l_rev_item_seq_id is not NULL
then

    UPDATE mtl_system_items_interface
    SET change_id = p_change_id
    where inventory_item_id = p_revised_item_id
      AND organization_id = p_organization_id
      AND request_id = l_request_id
      AND change_id is NULL;
END IF;

return l_rev_item_seq_id;

END get_Rev_item_update_parent;


-----------------------------------------------------------------
 -- Find Revised Item Record                                   --
-----------------------------------------------------------------
FUNCTION FIND_REV_ITEM_REC ( p_change_notice          IN VARCHAR2
                           , p_organization_id        IN NUMBER
                           , p_revised_item_id        IN NUMBER
                           , p_revision_id            IN NUMBER := NULL
                           , p_default_seq_id         IN NUMBER := NULL
                           , p_revision_import_policy IN VARCHAR2 := NULL
                            )
RETURN NUMBER
IS
     l_change_id ENG_ENGINEERING_CHANGES.CHANGE_ID%TYPE;
BEGIN
     SELECT change_id INTO l_change_id FROM eng_engineering_changes WHERE change_notice = p_change_notice AND organization_id = p_organization_id;

     RETURN FIND_REV_ITEM_REC ( p_change_id             => l_change_id
                             , p_organization_id        => p_organization_id
                             , p_revised_item_id        => p_revised_item_id
                             , p_revision_id            => p_revision_id
                             , p_default_seq_id         => p_default_seq_id
                             , p_revision_import_policy => p_revision_import_policy
                             ) ;

END FIND_REV_ITEM_REC;

FUNCTION FIND_REV_ITEM_REC ( p_change_id              IN NUMBER
                           , p_organization_id        IN NUMBER
                           , p_revised_item_id        IN NUMBER
                           , p_revision               IN VARCHAR2
                           , p_default_seq_id         IN NUMBER := NULL
                           , p_revision_import_policy IN VARCHAR2 := NULL
                            )
RETURN NUMBER
IS

    l_revision_id NUMBER ;

    CURSOR c_rev_id ( p_item_id IN NUMBER
                    , p_org_id  IN NUMBER
                    , p_rev     IN VARCHAR2
                     )
    IS
        SELECT REVISION_ID
        FROM MTL_ITEM_REVISIONS_B
        WHERE INVENTORY_ITEM_ID = p_item_id
        AND ORGANIZATION_ID = p_org_id
        AND REVISION = p_rev ;


BEGIN

Write_Debug(G_PKG_NAME || '.Find_Rev_Item_Rec for Item Revision Code. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_change_id: '  || to_char(p_change_id));
Write_Debug('p_organization_id: '  || to_char(p_organization_id));
Write_Debug('p_revised_item_id: '  || to_char(p_revised_item_id));
Write_Debug('p_revision: '  || p_revision);
Write_Debug('p_default_seq_id: '  || to_char(p_default_seq_id));
Write_Debug('-----------------------------------------' );

    IF p_revision IS NOT NULL
    THEN

        OPEN c_rev_id (p_revised_item_id, p_organization_id , p_revision);
        FETCH c_rev_id INTO l_revision_id ;
        IF (c_rev_id%NOTFOUND)
        THEN
          CLOSE c_rev_id;
Write_Debug('Revision Id is not found. . .' );
        END IF;

        IF (c_rev_id%ISOPEN)
        THEN
            CLOSE c_rev_id;
        END IF ;

    END IF ;

    RETURN FIND_REV_ITEM_REC ( p_change_id              => p_change_id
                             , p_organization_id        => p_organization_id
                             , p_revised_item_id        => p_revised_item_id
                             , p_revision_id            => l_revision_id
                             , p_default_seq_id         => p_default_seq_id
                             , p_revision_import_policy => p_revision_import_policy
                             ) ;

END FIND_REV_ITEM_REC ;


FUNCTION FIND_REV_ITEM_REC ( p_change_id              IN NUMBER
                           , p_organization_id        IN NUMBER
                           , p_revised_item_id        IN NUMBER
                           , p_revision_id            IN NUMBER := NULL
                           , p_default_seq_id         IN NUMBER := NULL
                           , p_revision_import_policy IN VARCHAR2 := NULL
                            )
RETURN NUMBER
IS

   l_rev_item_seq_id NUMBER ;
   l_msg_data       VARCHAR2(4000) ;
   l_msg_count      NUMBER ;
   l_return_status  VARCHAR2(1) ;
   l_revision_id    NUMBER ;

    CURSOR c_max_rev_id ( c_item_id IN NUMBER
                        , c_org_id  IN NUMBER
                        )
    IS
        SELECT rev_b.REVISION_ID
        FROM MTL_ITEM_REVISIONS_B rev_b
        WHERE rev_b.INVENTORY_ITEM_ID = c_item_id
        AND rev_b.ORGANIZATION_ID = c_org_id
        AND rev_b.REVISION = ( SELECT max(max_rev.revision)
                               FROM MTL_ITEM_REVISIONS_B max_rev
                               WHERE max_rev.INVENTORY_ITEM_ID = rev_b.INVENTORY_ITEM_ID
                               AND   max_rev.ORGANIZATION_ID = rev_b.ORGANIZATION_ID
                              ) ;


BEGIN

Write_Debug(G_PKG_NAME || '.Find_Rev_Item_Rec. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_change_id: '  || to_char(p_change_id));
Write_Debug('p_organization_id: '  || to_char(p_organization_id));
Write_Debug('p_revised_item_id: '  || to_char(p_revised_item_id));
Write_Debug('p_revision_id: '  || to_char(p_revision_id));
Write_Debug('p_default_seq_id: '  || to_char(p_default_seq_id));
Write_Debug('-----------------------------------------' );


    l_revision_id := p_revision_id ;

    IF  p_revision_import_policy IS NOT NULL
    AND G_REV_IMPT_POLICY_LATEST = p_revision_import_policy
    AND l_revision_id IS NULL
    THEN
Write_Debug('Batch Import Revision Import Policy is Latest and revision id is null. So get the latest revision for this item ') ;

        OPEN c_max_rev_id(p_revised_item_id, p_organization_id);
        FETCH c_max_rev_id INTO l_revision_id ;
        IF (c_max_rev_id%NOTFOUND)
        THEN
          CLOSE c_max_rev_id ;
Write_Debug('Latest Revision Id is not found. . .' );
        END IF;

        IF (c_max_rev_id%ISOPEN)
        THEN
            CLOSE c_max_rev_id ;
        END IF ;

Write_Debug('Latest Revision Id: ' || to_char(l_revision_id)) ;

    END IF ;

Write_Debug('Before calling Eng_Revised_Item_Pkg.Query_Target_Revised_Item') ;

    Eng_Revised_Items_Pkg.Query_Target_Revised_Item (
       p_api_version          => 1.0
     , p_init_msg_list        => FND_API.G_FALSE
     , x_return_status        => l_return_status
     , x_msg_count            => l_msg_count
     , x_msg_data             => l_msg_data
     , p_change_id            => p_change_id
     , p_organization_id      => p_organization_id
     , p_revised_item_id      => p_revised_item_id
     , p_revision_id          => p_revision_id
     , x_revised_item_seq_id  => l_rev_item_seq_id
     );


Write_Debug('After calling Eng_Revised_Item_Pkg.Query_Target_Revised_Item') ;
Write_Debug('Return Rev Item Seq Id: ' || TO_CHAR(l_rev_item_seq_id) );
Write_Debug('Return Status: ' || l_return_status );

    IF l_return_status <> G_RET_STS_SUCCESS
    THEN
Write_Debug('After calling Eng_Revised_Item_Pkg.Query_Target_Revised_Item: Return Msg: ' || l_msg_data );
        RAISE FND_API.G_EXC_ERROR ;
    END IF ;

    IF l_rev_item_seq_id IS NULL OR l_rev_item_seq_id  <= 0
    THEN
        l_rev_item_seq_id := p_default_seq_id ;
    END IF ;

    RETURN l_rev_item_seq_id ;

EXCEPTION
    WHEN OTHERS THEN
Write_Debug('Exception in FIND_REV_ITEM_REC: '|| Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
        RETURN  p_default_seq_id ;

END FIND_REV_ITEM_REC ;

--
-- Procedure to create component interface rows given the component details
--
PROCEDURE CREATE_ORPHAN_COMPONENT_INTF
(   p_api_version               IN  NUMBER
 ,  p_init_msg_list             IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit                    IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level          IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status             OUT NOCOPY VARCHAR2
 ,  x_msg_count                 OUT NOCOPY NUMBER
 ,  x_msg_data                  OUT NOCOPY VARCHAR2
 ,  p_debug                     IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir                IN  VARCHAR2  := NULL
 ,  p_debug_filename            IN  VARCHAR2  := NULL
 ,  p_organization_id           IN NUMBER
 ,  p_assembly_item_id          IN NUMBER
 ,  p_alternate_bom_designator  IN VARCHAR2
 ,  p_bill_sequence_id          IN NUMBER
 ,  p_component_item_id         IN NUMBER
 ,  p_op_seq_number             IN NUMBER
 ,  p_effectivity_date          IN DATE     := NULL
 ,  p_component_seq_id          IN NUMBER
 ,  p_from_end_item_unit_number IN VARCHAR2 := NULL
 ,  p_from_end_item_rev_id      IN NUMBER   := NULL
 ,  p_batch_id                  IN NUMBER
)
IS

    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_ORPHAN_COMPONENT_INTF';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list    VARCHAR2(1) ;
    l_validation_level NUMBER ;
    l_commit           VARCHAR2(1) ;

    l_bill_sequence_id        NUMBER;
    l_effectivity_control     NUMBER;
    l_component_seq_id        NUMBER;

    l_component_item_id         NUMBER;
    l_op_seq_number             NUMBER;
    l_effectivity_date          DATE;
    l_from_end_item_unit_number VARCHAR2(30);
    l_from_end_item_rev_id      NUMBER;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT CREATE_ORPHAN_COMPONENT_INTF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;



    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_organization_id: '  || to_char(p_organization_id));
Write_Debug('p_assembly_item_id: '  || to_char(p_assembly_item_id));
Write_Debug('p_alternate_bom_designator:'  || p_alternate_bom_designator);
Write_Debug('p_bill_sequence_id: '  || to_char(p_bill_sequence_id));
Write_Debug('p_effectivity_date: '  || to_char(p_effectivity_date, 'YYYY-MM-DD HH24:MI:SS'));
Write_Debug('p_from_end_item_unit_number:'  || p_from_end_item_unit_number);
Write_Debug('p_from_end_item_rev_id: '  || to_char(p_from_end_item_rev_id));
Write_Debug('p_component_item_id: '  || to_char(p_component_item_id));
Write_Debug('p_op_seq_number: '  || to_char(p_op_seq_number));
Write_Debug('p_component_seq_id: '  || to_char(p_component_seq_id));
Write_Debug('p_batch_id: '  || to_char(p_batch_id));
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    -- API body
    -- Logic Here
    -- Init Local Vars

    -- Get the bill sequence id
Write_Debug('Getting Bill Sequence Id: ');
    l_bill_sequence_id := NULL;
    l_effectivity_control := 1;
    BEGIN
      IF p_bill_sequence_id IS NOT NULL
      THEN
        l_bill_sequence_id := p_bill_sequence_id;
        SELECT effectivity_control
        INTO l_effectivity_control
        FROM BOM_STRUCTURES_B
        WHERE bill_sequence_id = p_bill_sequence_id;
      ELSE
        SELECT bill_sequence_id, effectivity_control
        INTO l_bill_sequence_id, l_effectivity_control
        FROM BOM_STRUCTURES_B
        WHERE assembly_item_id = p_assembly_item_id
        AND organization_id = p_organization_id
        AND ((alternate_bom_designator IS NULL AND
              p_alternate_bom_designator IS NULL) OR
             alternate_bom_designator = p_alternate_bom_designator);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        l_bill_sequence_id := NULL;
    END;

Write_Debug('l_bill_sequence_id: '  || to_char(l_bill_sequence_id));

    -- Get the component sequence id
Write_Debug('Getting Component Sequence Id: ');
    l_component_seq_id := NULL;
    l_component_item_id := p_component_item_id;
    l_op_seq_number := p_op_seq_number;
    l_effectivity_date := p_effectivity_date;
    l_from_end_item_unit_number := p_from_end_item_unit_number;
    l_from_end_item_rev_id := p_from_end_item_rev_id;

    BEGIN
      IF p_component_seq_id IS NOT NULL
      THEN
        l_component_seq_id := p_component_seq_id;
        SELECT component_item_id, operation_seq_num, effectivity_date, from_end_item_unit_number, from_end_item_rev_id
        INTO l_component_item_id, l_op_seq_number, l_effectivity_date, l_from_end_item_unit_number, l_from_end_item_rev_id
        FROM bom_components_b
        WHERE component_sequence_id = p_component_seq_id;
      ELSE
        IF l_effectivity_control = 2 -- Unit Effective
        THEN
          SELECT component_sequence_id
          INTO l_component_seq_id
          FROM bom_components_b bcb
          WHERE bcb.bill_sequence_id = l_bill_sequence_id
          AND bcb.operation_seq_num = p_op_seq_number
          AND bcb.component_item_id = p_component_item_id
          AND bcb.from_end_item_unit_number = p_from_end_item_unit_number
          AND bcb.implementation_date IS NOT NULL;

        ELSIF l_effectivity_control = 4 -- Rev Effective
        THEN
          SELECT component_sequence_id
          INTO l_component_seq_id
          FROM bom_components_b bcb
          WHERE bcb.bill_sequence_id = l_bill_sequence_id
          AND bcb.operation_seq_num = p_op_seq_number
          AND bcb.component_item_id = p_component_item_id
          AND bcb.from_end_item_rev_id = p_from_end_item_rev_id
          AND bcb.implementation_date IS NOT NULL;

        ELSE
          SELECT component_sequence_id
          INTO l_component_seq_id
          FROM bom_components_b bcb
          WHERE bcb.bill_sequence_id = l_bill_sequence_id
          AND bcb.operation_seq_num = p_op_seq_number
          AND bcb.component_item_id = p_component_item_id
          AND bcb.effectivity_date = p_effectivity_date
          AND bcb.implementation_date IS NOT NULL;

        END IF;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        l_component_seq_id := NULL;
    END;
Write_Debug('l_component_seq_id: '  || to_char(l_component_seq_id));

Write_Debug('Inserting data into interface tables:');
    INSERT INTO bom_inventory_comps_interface
    (OPERATION_SEQ_NUM,
     COMPONENT_ITEM_ID,
     EFFECTIVITY_DATE,
     OLD_COMPONENT_SEQUENCE_ID,
     COMPONENT_SEQUENCE_ID,
     BILL_SEQUENCE_ID,
     ASSEMBLY_ITEM_ID,
     ALTERNATE_BOM_DESIGNATOR,
     ORGANIZATION_ID,
     PROCESS_FLAG,
     TRANSACTION_TYPE,
     FROM_END_ITEM_UNIT_NUMBER,
     FROM_END_ITEM_ID,
     FROM_END_ITEM_REV_ID,
     BATCH_ID
    ) VALUES
    (l_op_seq_number,
     l_component_item_id,
     l_effectivity_date,
     l_component_seq_id,
     l_component_seq_id,
     l_bill_sequence_id,
     p_assembly_item_id,
     p_alternate_bom_designator,
     p_organization_id,
     G_CM_TO_BE_PROCESSED,
     'UPDATE',
     l_from_end_item_unit_number,
     p_assembly_item_id,
     l_from_end_item_rev_id,
     p_batch_id
    );
Write_Debug('Done Inserting data into interface tables:');
    -- End of API body.

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO CREATE_ORPHAN_COMPONENT_INTF;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_ORPHAN_COMPONENT_INTF;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN OTHERS THEN

    ROLLBACK TO CREATE_ORPHAN_COMPONENT_INTF;
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


Write_Debug('Exception in CREATE_ORPHAN_COMPONENT_INTF: '|| Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


END CREATE_ORPHAN_COMPONENT_INTF;


--
-- Procedure to create structure header interface rows given the component details
--
PROCEDURE CREATE_ORPHAN_HEADER_INTF
(   p_api_version               IN  NUMBER
 ,  p_init_msg_list             IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit                    IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level          IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status             OUT NOCOPY VARCHAR2
 ,  x_msg_count                 OUT NOCOPY NUMBER
 ,  x_msg_data                  OUT NOCOPY VARCHAR2
 ,  p_debug                     IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir                IN  VARCHAR2  := NULL
 ,  p_debug_filename            IN  VARCHAR2  := NULL
 ,  p_organization_id           IN NUMBER
 ,  p_assembly_item_id          IN NUMBER
 ,  p_alternate_bom_designator  IN VARCHAR2
 ,  p_bill_sequence_id          IN NUMBER
 ,  p_batch_id                  IN NUMBER
)
IS

    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_ORPHAN_HEADER_INTF';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list    VARCHAR2(1) ;
    l_validation_level NUMBER ;
    l_commit           VARCHAR2(1) ;

    l_bill_sequence_id        NUMBER;
    l_effectivity_control     NUMBER;
    l_alt_bom_designator      VARCHAR2(30);
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT CREATE_ORPHAN_HEADER_INTF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;



    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_organization_id: '  || to_char(p_organization_id));
Write_Debug('p_assembly_item_id: '  || to_char(p_assembly_item_id));
Write_Debug('p_alternate_bom_designator:'  || p_alternate_bom_designator);
Write_Debug('p_bill_sequence_id: '  || to_char(p_bill_sequence_id));
Write_Debug('p_batch_id: '  || to_char(p_batch_id));
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    -- API body
    -- Logic Here
    -- Init Local Vars

    -- Get the bill sequence id
Write_Debug('Getting Bill Sequence Id: ');
    l_bill_sequence_id := NULL;
    l_effectivity_control := 1;
    l_alt_bom_designator := p_alternate_bom_designator;
    BEGIN
      IF p_bill_sequence_id IS NOT NULL
      THEN
        l_bill_sequence_id := p_bill_sequence_id;
        SELECT effectivity_control, alternate_bom_Designator
        INTO l_effectivity_control, l_alt_bom_designator
        FROM BOM_STRUCTURES_B
        WHERE bill_sequence_id = p_bill_sequence_id;
      ELSE
        SELECT bill_sequence_id, effectivity_control
        INTO l_bill_sequence_id, l_effectivity_control
        FROM BOM_STRUCTURES_B
        WHERE assembly_item_id = p_assembly_item_id
        AND organization_id = p_organization_id
        AND ((alternate_bom_designator IS NULL AND
              p_alternate_bom_designator IS NULL) OR
             alternate_bom_designator = p_alternate_bom_designator);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        l_bill_sequence_id := NULL;
    END;

Write_Debug('l_bill_sequence_id: '  || to_char(l_bill_sequence_id));

Write_Debug('Inserting data into interface tables:');
    INSERT INTO bom_bill_of_mtls_interface
    (ASSEMBLY_ITEM_ID,
     ORGANIZATION_ID,
     ALTERNATE_BOM_DESIGNATOR,
     BILL_SEQUENCE_ID,
     EFFECTIVITY_CONTROL,
     PROCESS_FLAG,
     TRANSACTION_TYPE,
     BATCH_ID
    ) VALUES
    (p_assembly_item_id,
     p_organization_id,
     l_alt_bom_designator,
     l_bill_sequence_id,
     l_effectivity_control,
     G_CM_TO_BE_PROCESSED,
     'NO_OP',
     p_batch_id
    );
Write_Debug('Done Inserting data into interface tables:');
    -- End of API body.

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO CREATE_ORPHAN_HEADER_INTF;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_ORPHAN_HEADER_INTF;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN OTHERS THEN

    ROLLBACK TO CREATE_ORPHAN_HEADER_INTF;
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


Write_Debug('Exception in CREATE_ORPHAN_HEADER_INTF: '|| Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


END CREATE_ORPHAN_HEADER_INTF;


--
-- Procedure to create structure header interface rows given the component details
--
PROCEDURE PREPROCESS_COMP_CHILD_ROWS
(   p_api_version               IN  NUMBER
 ,  p_init_msg_list             IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit                    IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level          IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status             OUT NOCOPY VARCHAR2
 ,  x_msg_count                 OUT NOCOPY NUMBER
 ,  x_msg_data                  OUT NOCOPY VARCHAR2
 ,  p_debug                     IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir                IN  VARCHAR2  := NULL
 ,  p_debug_filename            IN  VARCHAR2  := NULL
 ,  p_organization_id           IN NUMBER
 ,  p_assembly_item_id          IN NUMBER
 ,  p_alternate_bom_designator  IN VARCHAR2
 ,  p_bill_sequence_id          IN NUMBER
 ,  p_change_id                 IN NUMBER
 ,  p_change_notice             IN VARCHAR2
 ,  p_batch_id                  IN NUMBER
)
IS

    l_api_name      CONSTANT VARCHAR2(30) := 'PREPROCESS_COMP_CHILD_ROWS';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list    VARCHAR2(1) ;
    l_validation_level NUMBER ;
    l_commit           VARCHAR2(1) ;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT PREPROCESS_COMP_CHILD_ROWS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;



    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_organization_id: '  || to_char(p_organization_id));
Write_Debug('p_assembly_item_id: '  || to_char(p_assembly_item_id));
Write_Debug('p_alternate_bom_designator:'  || p_alternate_bom_designator);
Write_Debug('p_bill_sequence_id: '  || to_char(p_bill_sequence_id));
Write_Debug('p_change_id: '  || to_char(p_change_id));
Write_Debug('p_change_notice: '  || to_char(p_change_notice));
Write_Debug('p_batch_id: '  || to_char(p_batch_id));
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    -- API body
    -- Logic Here
    -- Init Local Vars

    -----------------------------------------------------------------------------------------
    -- Transaction Type is CREATE/DELETE/UPDATE
    -----------------------------------------------------------------------------------------
Write_Debug('Updating Reference Designator Interface records for Create...  ' );
    -- (a) Reference Designators: CREATE/DELETE/UPDATE
    -----------------------------------------------------------------------------------------
    UPDATE bom_ref_desgs_interface brdi
    SET
      acd_type = decode(transaction_type, 'DELETE', G_BOM_DISABLE_ACD_TYPE,
                                          'UPDATE', G_BOM_CHANGE_ACD_TYPE
                                          ,G_BOM_ADD_ACD_TYPE),
      change_transaction_type = 'CREATE',
      change_notice = p_change_notice,
      bill_sequence_id = p_bill_sequence_id
    WHERE (bill_sequence_id = p_bill_sequence_id OR
       ( bill_sequence_id IS NULL
         AND assembly_item_id = p_assembly_item_id
         AND organization_id = p_organization_id
         AND (alternate_bom_designator = p_alternate_bom_designator
          OR (alternate_bom_designator IS NULL AND p_alternate_bom_designator IS NULL))))
      AND change_id = p_change_id
      AND batch_id = p_batch_id
      AND process_flag = G_CM_TO_BE_PROCESSED
      AND transaction_type in ('CREATE', 'UPDATE', 'DELETE');


Write_Debug('Updating Substitute Components Interface records for Create...  ' );
    -- (b) Substitute Components: CREATE/DELETE/UPDATE
    -----------------------------------------------------------------------------------------
    UPDATE bom_sub_comps_interface
    SET
      acd_type = decode(transaction_type, 'DELETE', G_BOM_DISABLE_ACD_TYPE,
                                          'UPDATE', G_BOM_CHANGE_ACD_TYPE
                                          ,G_BOM_ADD_ACD_TYPE),
      change_transaction_type = 'CREATE',
      change_notice = p_change_notice,
      bill_sequence_id = p_bill_sequence_id
    WHERE (bill_sequence_id = p_bill_sequence_id OR
       ( bill_sequence_id IS NULL
         AND assembly_item_id = p_assembly_item_id
         AND organization_id = p_organization_id
         AND (alternate_bom_designator = p_alternate_bom_designator
          OR (alternate_bom_designator IS NULL AND p_alternate_bom_designator IS NULL))))
      AND change_id = p_change_id
      AND batch_id = p_batch_id
      AND process_flag = G_CM_TO_BE_PROCESSED
      AND transaction_type in ('CREATE', 'UPDATE', 'DELETE');

    -- End of API body.

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PREPROCESS_COMP_CHILD_ROWS;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO PREPROCESS_COMP_CHILD_ROWS;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN OTHERS THEN

    ROLLBACK TO PREPROCESS_COMP_CHILD_ROWS;
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


Write_Debug('Exception in PREPROCESS_COMP_CHILD_ROWS: '|| Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


END PREPROCESS_COMP_CHILD_ROWS;


--
-- Procedure to preprocess the bom interface rows:
-- The following entries are to be populated:
--  1. Revised Item sequence id - same as the rev item seq id passed
--  2. ACD TYPE - consult following matrix
--  3. Change Trasnaction Type - consult following matrix
--  ================================================================
--  | Txn Type   | Present in ECO | ACD Type    | Change Txn Type  |
--  =============+================+=============+==================|
--  | CREATE     | N              | ADD         | CREATE           |
--  |            | Y/ERROR        | *N/A*       | *N/A*            |
--  +------------+----------------+-------------+------------------|
--  | UPDATE     | N              | CHANGE      | CREATE           |
--  |            | Y              | existing    | UPDATE           |
--  +------------+----------------+-------------+------------------|
--  | DELETE     | N              | DISABLE     | CREATE           |
--  |            | Y              | existing    | DELETE           |
--  +============+================+=============+==================|
--
--
PROCEDURE PREPROCESS_BOM_INTERFACE_ROWS
(   p_api_version               IN  NUMBER
 ,  p_init_msg_list             IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit                    IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level          IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status             OUT NOCOPY VARCHAR2
 ,  x_msg_count                 OUT NOCOPY NUMBER
 ,  x_msg_data                  OUT NOCOPY VARCHAR2
 ,  p_debug                     IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir                IN  VARCHAR2  := NULL
 ,  p_debug_filename            IN  VARCHAR2  := NULL
 ,  p_change_id                 IN NUMBER
 ,  p_change_notice             IN VARCHAR2
 ,  p_organization_id           IN NUMBER
 ,  p_revised_item_id           IN NUMBER
 ,  p_alternate_bom_designator  IN VARCHAR2
 ,  p_bill_sequence_id          IN NUMBER
 ,  p_effectivity_date          IN DATE     := NULL
 ,  p_from_end_item_unit_number IN VARCHAR2 := NULL
 ,  p_from_end_item_rev_id      IN NUMBER   := NULL
 ,  p_current_date              IN DATE     := NULL
 ,  p_revised_item_sequence_id  IN NUMBER
 ,  p_parent_rev_eff_date       IN DATE     := NULL
 ,  p_parent_revision_id        IN NUMBER   := NULL
 ,  p_batch_id                  IN NUMBER
 ,  p_request_id                IN NUMBER
)
IS

    l_api_name      CONSTANT VARCHAR2(30) := 'PREPROCESS_BOM_INTERFACE_ROWS';
    l_api_version   CONSTANT NUMBER     := 1.0;

    l_init_msg_list    VARCHAR2(1) ;
    l_validation_level NUMBER ;
    l_commit           VARCHAR2(1) ;


    l_acd_type                    NUMBER;
    l_comp_seq_id                 NUMBER;
    l_change_transaction_type     VARCHAR2(10);

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT PREPROCESS_BOM_INTERFACE_ROWS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;



    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_change_id: '  || to_char(p_change_id));
Write_Debug('p_change_notice:'  || p_change_notice);
Write_Debug('p_organization_id: '  || to_char(p_organization_id));
Write_Debug('p_revised_item_id: '  || to_char(p_revised_item_id));
Write_Debug('p_alternate_bom_designator:'  || p_alternate_bom_designator);
Write_Debug('p_bill_sequence_id: '  || to_char(p_bill_sequence_id));
Write_Debug('p_effectivity_date: '  || to_char(p_effectivity_date, 'YYYY-MM-DD HH24:MI:SS'));
Write_Debug('p_from_end_item_unit_number:'  || p_from_end_item_unit_number);
Write_Debug('p_from_end_item_rev_id: '  || to_char(p_from_end_item_rev_id));
Write_Debug('p_current_date: '  || to_char(p_current_date, 'YYYY-MM-DD HH24:MI:SS'));
Write_Debug('p_revised_item_sequence_id: '  || to_char(p_revised_item_sequence_id));
Write_Debug('p_batch_id: '  || to_char(p_batch_id));
Write_Debug('p_request_id: '  || to_char(p_request_id));
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    -- API body
    -- Logic Here
    -- Init Local Vars


    -----------------------------------------------------------------------------------------
    -- Transaction Type is CREATE
    -----------------------------------------------------------------------------------------
Write_Debug('Updating Bom Components Interface records for Create...  ' );
    -- (a) Components: CREATE
    -----------------------------------------------------------------------------------------
    UPDATE bom_inventory_comps_interface
    SET
      acd_type = G_BOM_ADD_ACD_TYPE,
      change_transaction_type = 'CREATE',
      change_notice = p_change_notice,
      revised_item_sequence_id = p_revised_item_sequence_id,
      bill_sequence_id = p_bill_sequence_id,
      new_effectivity_date = p_effectivity_date
    WHERE  (bill_sequence_id = p_bill_sequence_id OR
           ( bill_sequence_id IS NULL
             AND assembly_item_id = p_revised_item_id
             AND organization_id = p_organization_id
             AND (alternate_bom_designator = p_alternate_bom_designator
              OR (alternate_bom_designator IS NULL AND p_alternate_bom_designator IS NULL))))
      AND ((p_effectivity_date IS NULL AND effectivity_date IS NULL)
           OR (decode (new_effectivity_date,
                        null,
                        decode(parent_revision_id,
                                 null,
                                 nvl(p_parent_rev_eff_date, nvl(effectivity_date, p_current_date)),
                                 (SELECT effectivity_date + 1/(24*3600)
                                  FROM mtl_item_revisions
                                  WHERE revision_id = parent_revision_id )),
                        new_effectivity_date) = p_effectivity_date)
           OR (decode (new_effectivity_date,
                        null,
                        decode(parent_revision_id,
                                 null,
                                 nvl(p_parent_rev_eff_date, nvl(effectivity_date, p_current_date)),
                                 (SELECT effectivity_date + 1/(24*3600)
                                  FROM mtl_item_revisions
                                  WHERE revision_id = parent_revision_id )),
                        new_effectivity_date) <= p_current_date AND
                   p_current_date = p_effectivity_date))
      AND NVL(new_from_end_item_unit_number, NVL(from_end_item_unit_number, FND_API.G_MISS_CHAR))
            = NVL(p_from_end_item_unit_number, FND_API.G_MISS_CHAR)
      AND NVL(from_end_item_rev_id, '-1') = NVL(p_from_end_item_rev_id, '-1')
      AND change_id = p_change_id
      AND batch_id = p_batch_id
      AND process_flag = G_CM_TO_BE_PROCESSED
      AND transaction_type = 'CREATE';

    -----------------------------------------------------------------------------------------
    -- Transaction Type is DELETE/UPDATE
    -----------------------------------------------------------------------------------------
Write_Debug('Deleting/Updating Component Interface records for Create(Not present in ECO)...  ' );
    -- (a) Components: DELETE/UPDATE: NOT already present in ECO
    -----------------------------------------------------------------------------------------
    UPDATE bom_inventory_comps_interface bici
    SET
      acd_type = decode(transaction_type, 'DELETE', G_BOM_DISABLE_ACD_TYPE, G_BOM_CHANGE_ACD_TYPE),
      change_transaction_type = 'CREATE',
      revised_item_sequence_id = p_revised_item_sequence_id,
      bill_sequence_id = p_bill_sequence_id,
      change_notice = p_change_notice,
      new_effectivity_date = p_effectivity_date
    WHERE  (bill_sequence_id = p_bill_sequence_id OR
           ( bill_sequence_id IS NULL
             AND assembly_item_id = p_revised_item_id
             AND organization_id = p_organization_id
             AND (alternate_bom_designator = p_alternate_bom_designator
              OR (alternate_bom_designator IS NULL AND p_alternate_bom_designator IS NULL))))
      AND NVL(new_from_end_item_unit_number, NVL(from_end_item_unit_number, FND_API.G_MISS_CHAR))
              = NVL(p_from_end_item_unit_number, FND_API.G_MISS_CHAR)
      AND NVL(from_end_item_rev_id, '-1')
              = NVL(p_from_end_item_rev_id, '-1')
      AND ((p_effectivity_date IS NULL AND effectivity_date IS NULL)
           OR (decode (new_effectivity_date,
                        null,
                        decode(parent_revision_id,
                                 null,
                                 nvl(p_parent_rev_eff_date, nvl(effectivity_date, p_current_date)),
                                 (SELECT effectivity_date + 1/(24*3600)
                                  FROM mtl_item_revisions
                                  WHERE revision_id = parent_revision_id )),
                        new_effectivity_date) = p_effectivity_date)
           OR (decode (new_effectivity_date,
                        null,
                        decode(parent_revision_id,
                                 null,
                                 nvl(p_parent_rev_eff_date, nvl(effectivity_date, p_current_date)),
                                 (SELECT effectivity_date + 1/(24*3600)
                                  FROM mtl_item_revisions
                                  WHERE revision_id = parent_revision_id )),
                        new_effectivity_date) <= p_current_date AND
                   p_current_date = p_effectivity_date))
      AND change_id = p_change_id
      AND batch_id = p_batch_id
      AND process_flag = G_CM_TO_BE_PROCESSED
      AND transaction_type in ('DELETE', 'UPDATE')
      AND not exists (SELECT 1
                  FROM bom_inventory_components bic
                  WHERE
                  bic.component_sequence_id = bici.component_sequence_id
                  AND bic.revised_item_sequence_id = p_revised_item_sequence_id);


Write_Debug('Deleting/Updating Component Interface records for Create(Present in ECO)...  ' );
    -- (b) Components: DELETE/UPDATE: already present in ECO
    -----------------------------------------------------------------------------------------

    UPDATE bom_inventory_comps_interface bici
    SET
      acd_type = decode(transaction_type, 'DELETE', G_BOM_DISABLE_ACD_TYPE,
                           (SELECT bic.acd_type
                            FROM bom_inventory_components bic
                            WHERE
                            bic.component_sequence_id = bici.component_sequence_id
                            AND bic.revised_item_sequence_id = p_revised_item_sequence_id)),
      change_transaction_type = decode(transaction_type, 'DELETE', 'DELETE', 'UPDATE'),
      revised_item_sequence_id = p_revised_item_sequence_id,
      bill_sequence_id = p_bill_sequence_id,
      change_notice = p_change_notice,
      new_effectivity_date = p_effectivity_date
    WHERE  (bill_sequence_id = p_bill_sequence_id OR
           ( bill_sequence_id IS NULL
             AND assembly_item_id = p_revised_item_id
             AND organization_id = p_organization_id
             AND (alternate_bom_designator = p_alternate_bom_designator
              OR (alternate_bom_designator IS NULL AND p_alternate_bom_designator IS NULL))))
      AND NVL(new_from_end_item_unit_number, NVL(from_end_item_unit_number, FND_API.G_MISS_CHAR))
              = NVL(p_from_end_item_unit_number, FND_API.G_MISS_CHAR)
      AND NVL(from_end_item_rev_id, '-1')
              = NVL(p_from_end_item_rev_id, '-1')
      AND ((p_effectivity_date IS NULL AND effectivity_date IS NULL)
           OR (decode (new_effectivity_date,
                        null,
                        decode(parent_revision_id,
                                 null,
                                 nvl(p_parent_rev_eff_date, nvl(effectivity_date, p_current_date)),
                                 (SELECT effectivity_date + 1/(24*3600)
                                  FROM mtl_item_revisions
                                  WHERE revision_id = parent_revision_id )),
                        new_effectivity_date) = p_effectivity_date)
           OR (decode (new_effectivity_date,
                        null,
                        decode(parent_revision_id,
                                 null,
                                 nvl(p_parent_rev_eff_date, nvl(effectivity_date, p_current_date)),
                                 (SELECT effectivity_date + 1/(24*3600)
                                  FROM mtl_item_revisions
                                  WHERE revision_id = parent_revision_id )),
                        new_effectivity_date) <= p_current_date AND
                   p_current_date = p_effectivity_date))
      AND change_id = p_change_id
      AND batch_id = p_batch_id
      AND process_flag = G_CM_TO_BE_PROCESSED
      AND transaction_type in ('DELETE', 'UPDATE')
      AND exists (SELECT 1
                  FROM bom_inventory_components bic
                  WHERE
                  bic.component_sequence_id = bici.component_sequence_id
                  AND bic.revised_item_sequence_id = p_revised_item_sequence_id);

    -----------------------------------------------------------------------------------------
    -- Transaction Type is DELETE/UPDATE
    -----------------------------------------------------------------------------------------
Write_Debug('Deleting/Updating Reference Designator records for Create(Present in ECO)...  ' );
    -- (d) Reference Designators:: DELETE/UPDATE: already present in ECO
    -----------------------------------------------------------------------------------------
    UPDATE bom_ref_desgs_interface brdi
    SET
      acd_type = (SELECT brd.acd_type
                  FROM bom_reference_designators brd,
                       bom_inventory_components bic
                  WHERE brd.component_sequence_id = bic.component_sequence_id
                  AND brd.component_reference_designator = brdi.component_reference_designator
                  AND bic.revised_item_sequence_id = p_revised_item_sequence_id
                  AND bic.component_item_id = brdi.component_item_id),
      change_transaction_type = decode(transaction_type, 'DELETE', 'DELETE', 'UPDATE'),
      change_notice = p_change_notice
    WHERE (brdi.bill_sequence_id = p_bill_sequence_id OR
           ( brdi.bill_sequence_id IS NULL
             AND brdi.assembly_item_id = p_revised_item_id
             AND brdi.organization_id = p_organization_id
             AND (brdi.alternate_bom_designator = p_alternate_bom_designator
              OR (brdi.alternate_bom_designator IS NULL AND p_alternate_bom_designator IS NULL))))
        AND brdi.change_id = p_change_id
        AND brdi.batch_id = p_batch_id
        AND brdi.process_flag = G_CM_TO_BE_PROCESSED
        AND brdi.transaction_type in ('DELETE', 'UPDATE')
        AND exists (SELECT 1
                    FROM bom_reference_designators brd,
                         bom_inventory_components bic
                    WHERE brd.component_sequence_id = bic.component_sequence_id
                    AND brd.component_reference_designator = brdi.component_reference_designator
                    AND bic.revised_item_sequence_id = p_revised_item_sequence_id
                    AND bic.component_item_id = brdi.component_item_id);


Write_Debug('Deleting/Updating Substitute Components records for Create(Present in ECO)...  ' );
    -- (f) Substitute Components:: DELETE/UPDATE: already present in ECO
    -----------------------------------------------------------------------------------------
    UPDATE bom_sub_comps_interface bsci
    SET
      acd_type = (SELECT bsc.acd_type
                 FROM bom_substitute_components bsc,
                      bom_inventory_components bic
                 WHERE bsc.component_sequence_id = bic.component_sequence_id
                 AND bsc.substitute_component_id = bsci.substitute_component_id
                 AND bic.revised_item_sequence_id = p_revised_item_sequence_id
                 AND bic.component_item_id = bsci.component_item_id),
      change_transaction_type = decode(transaction_type, 'DELETE', 'DELETE', 'UPDATE'),
      change_notice = p_change_notice
    WHERE (bsci.bill_sequence_id = p_bill_sequence_id OR
           ( bsci.bill_sequence_id IS NULL
             AND bsci.assembly_item_id = p_revised_item_id
             AND bsci.organization_id = p_organization_id
             AND (bsci.alternate_bom_designator = p_alternate_bom_designator
              OR (bsci.alternate_bom_designator IS NULL AND p_alternate_bom_designator IS NULL))))
        AND bsci.change_id = p_change_id
        AND bsci.batch_id = p_batch_id
        AND bsci.process_flag = G_CM_TO_BE_PROCESSED
        AND bsci.transaction_type in ('DELETE', 'UPDATE')
        AND exists (SELECT 1
                    FROM bom_substitute_components bsc,
                         bom_inventory_components bic
                    WHERE bsc.component_sequence_id = bic.component_sequence_id
                    AND bsc.substitute_component_id = bsci.substitute_component_id
                    AND bic.revised_item_sequence_id = p_revised_item_sequence_id
                    AND bic.component_item_id = bsci.component_item_id);



Write_Debug('After Updating All Interface records . . ..  ' );

    -- End of API body.

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PREPROCESS_BOM_INTERFACE_ROWS;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO PREPROCESS_BOM_INTERFACE_ROWS;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;

  WHEN OTHERS THEN

    ROLLBACK TO PREPROCESS_BOM_INTERFACE_ROWS;
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );


Write_Debug('Exception in PREPROCESS_BOM_INTERFACE_ROWS: '|| Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));

    -----------------------------------------------------
    -- Close Error Handler Debug Session.
    -----------------------------------------------------
    Close_Debug_Session;


END PREPROCESS_BOM_INTERFACE_ROWS;




/********************************************************************
* API Type      : Import Change Handler APIs
* Purpose       : Perform Import Change Table Handler
*********************************************************************/
PROCEDURE INSERT_IMPORTED_CHANGE_HISTORY
(   p_api_version       IN  NUMBER
 ,  p_init_msg_list     IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_commit            IN  VARCHAR2 := NULL -- FND_API.G_FALSE
 ,  p_validation_level  IN  NUMBER   := NULL -- FND_API.G_VALID_LEVEL_FULL
 ,  x_return_status     OUT NOCOPY VARCHAR2
 ,  x_msg_count         OUT NOCOPY NUMBER
 ,  x_msg_data          OUT NOCOPY VARCHAR2
 ,  p_write_msg_to_intftbl IN  VARCHAR2 := NULL --  FND_API.G_FALSE
 ,  p_api_caller        IN  VARCHAR2  := NULL
 ,  p_debug             IN  VARCHAR2  := NULL -- FND_API.G_FALSE
 ,  p_output_dir        IN  VARCHAR2  := NULL
 ,  p_debug_filename    IN  VARCHAR2  := NULL
 ,  p_batch_id          IN  NUMBER
 ,  p_change_ids        IN  FND_ARRAY_OF_NUMBER_25
)
IS
    l_api_name      CONSTANT VARCHAR2(30) := 'INSERT_IMPORTED_CHANGE_HISTORY';
    l_api_version   CONSTANT NUMBER     := 1.0;


    l_init_msg_list    VARCHAR2(1) ;
    l_validation_level NUMBER ;
    l_commit           VARCHAR2(1) ;
    l_write_msg_to_intftbl VARCHAR2(1) ;


    l_change_id    NUMBER ;
    l_dummy_rowid  VARCHAR2(100) ;
    l_msg_text     VARCHAR2(2000) ;

    l_hist_insert_flag  VARCHAR2(1) ;

    CURSOR check_existence_c (c_batch_id NUMBER, c_change_id NUMBER)
    IS
      select 'N'
      from EGO_IMPORT_BATCH_CHANGES
      where BATCH_ID = c_batch_id
      and CHANGE_ID = c_change_id
      ;

    --Begin code change for bug 9398720
    l_change_number ENG_ENGINEERING_CHANGES.CHANGE_NOTICE%TYPE;

    CURSOR get_change_number(c_change_id NUMBER)
    IS
      SELECT CHANGE_NOTICE
      FROM ENG_ENGINEERING_CHANGES
      WHERE CHANGE_ID = c_change_id;
    --End code change for bug 9398720

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT INSERT_IMPORTED_CHANGE_HISTORY;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                         p_api_version ,
                                         l_api_name ,
                                         G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_init_msg_list    :=  NVL(p_init_msg_list,FND_API.G_FALSE) ;
    l_validation_level :=  NVL(p_validation_level,FND_API.G_VALID_LEVEL_FULL) ;
    l_commit           :=  NVL(p_commit,FND_API.G_FALSE) ;
    l_write_msg_to_intftbl :=  NVL(p_write_msg_to_intftbl,FND_API.G_FALSE) ;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Open Debug Session by a give param or profile option.
    Open_Debug_Session(p_debug, p_output_dir,  p_debug_filename) ;

Write_Debug('After Open_Debug_Session');
Write_Debug(G_PKG_NAME || '.' || l_api_name || '. . .  ');
Write_Debug('-----------------------------------------' );
Write_Debug('p_api_version: '  || to_char(p_api_version));
Write_Debug('p_init_msg_list:'  || p_init_msg_list);
Write_Debug('p_commit:'  || p_commit);
Write_Debug('p_validation_level: '  || to_char(p_validation_level));
Write_Debug('p_write_msg_to_intftbl:'  || p_write_msg_to_intftbl);
Write_Debug('p_api_caller:'  || p_api_caller);
Write_Debug('p_batch_id: '  || to_char(p_batch_id));
Write_Debug('-----------------------------------------' );

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    -- API body
    -- Logic Here
    FOR i IN p_change_ids.FIRST..p_change_ids.LAST
    LOOP

        l_change_id := p_change_ids(i) ;

        open check_existence_c(c_batch_id => p_batch_id, c_change_id => l_change_id) ;
        fetch check_existence_c into l_hist_insert_flag ;
        if (check_existence_c%notfound) then
          close check_existence_c ;
          l_hist_insert_flag := 'Y' ;
        else

Write_Debug('Import Hsotry exists for  ChangeId: '|| to_char(l_change_id) ) ;
          l_hist_insert_flag := 'N' ;

        end if;

        if (check_existence_c%ISOPEN)
        then
          close check_existence_c ;
        end if ;


        IF l_hist_insert_flag = 'Y' THEN

Write_Debug('Inserting Import Hsotry: ChangeId: '|| to_char(l_change_id) ) ;

            INSERT_IMPORT_CHANGE_ROW
            ( X_ROWID             => l_dummy_rowid ,
              X_BATCH_ID          => p_batch_id,
              X_CHANGE_ID         => l_change_id ,
              X_CREATION_DATE     => SYSDATE,
              X_CREATED_BY        => FND_GLOBAL.user_id,
              X_LAST_UPDATE_DATE  => SYSDATE,
              X_LAST_UPDATED_BY   => FND_GLOBAL.user_id ,
              X_LAST_UPDATE_LOGIN => FND_GLOBAL.login_id
            )  ;


            IF FND_API.to_Boolean(l_write_msg_to_intftbl)
            THEN

  Write_Debug('Insert Info Message for the record inserted as history. . .' );
                --Begin code change for bug 9398720
                OPEN get_change_number(l_change_id);
		FETCH get_change_number INTO l_change_number;
		IF (get_change_number%NOTFOUND) THEN
                  CLOSE get_change_number;
                  l_change_number := NULL;
                END IF;

                IF (get_change_number%ISOPEN) THEN
                  CLOSE get_change_number;
                END IF;
		--End code change for bug 9398720

                FND_MESSAGE.SET_NAME('ENG','ENG_IMPT_INS_HIST');
		--Begin code change for bug 9398720, use change number to replace change id in this message.
                --FND_MESSAGE.SET_TOKEN('CHANGE_NUMBER', to_char(l_change_id));
		FND_MESSAGE.SET_TOKEN('CHANGE_NUMBER', NVL(l_change_number, to_char(l_change_id)));
		--End code change for bug 9398720
                FND_MESSAGE.SET_TOKEN('BATCH_ID', to_char(p_batch_id));
                l_msg_text := FND_MESSAGE.GET;

                Insert_Mtl_Intf_Err
                (   p_transaction_id    => null
                 ,  p_bo_identifier     => G_BO_IDENTIFIER
                 ,  p_error_entity_code => null
                 ,  p_error_table_name  => null
                 ,  p_error_column_name => NULL
                 ,  p_error_msg         => l_msg_text
                 ,  p_error_msg_type    => G_ENG_MSG_TYPE_INFORMATION
                 ,  p_error_msg_name    => null
                ) ;
            END IF ;
        END IF ; -- l_hist_insert_flag is 'Y'

    END LOOP ;
    -- End of API body.


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO INSERT_IMPORTED_CHANGE_HISTORY;
    x_return_status := G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO INSERT_IMPORTED_CHANGE_HISTORY;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO INSERT_IMPORTED_CHANGE_HISTORY;
    x_return_status := G_RET_STS_UNEXP_ERROR ;

    IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME ,
          l_api_name
        );
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count ,
      p_data  => x_msg_data
    );

END INSERT_IMPORTED_CHANGE_HISTORY ;



procedure INSERT_IMPORT_CHANGE_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_BATCH_ID in NUMBER,
  X_CHANGE_ID in NUMBER ,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

  cursor C is select ROWID from EGO_IMPORT_BATCH_CHANGES
    where BATCH_ID = X_BATCH_ID
    and CHANGE_ID = X_CHANGE_ID
    ;

begin

  insert into EGO_IMPORT_BATCH_CHANGES (
    BATCH_ID,
    CHANGE_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_BATCH_ID,
    X_CHANGE_ID,
    1.0,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;


end INSERT_IMPORT_CHANGE_ROW;

/***************************
procedure LOCK_IMPORT_CHANGE_ROW (
  X_BATCH_ID in NUMBER,
  X_CHANGE_ID in NUMBER,
) is

  cursor c is select
       -- OBJECT_VERSION_NUMBER
    from EGO_IMPORT_BATCH_CHANGES
    where OBJECT_ID = X_BATCH_ID
    and CHANGE_ID = X_CHANGE_ID
    for update of OBJECT_ID nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_IMPORT_CHANGE_ROW;
***************************/

/***************************
procedure UPDATE_IMPORT_CHANGE_ROW (
  X_BATCH_ID in NUMBER,
  X_CHANGE_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

begin
  update EGO_IMPORT_BATCH_CHANGES
  set  -- XXXX
  where OBJECT_ID = X_BATCH_ID
  and CHANGE_ID = X_CHANGE_ID ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_IMPORT_CHANGE_ROW;
*******************************/


procedure DELETE_IMPORT_CHANGE_ROW (
  X_BATCH_ID in NUMBER,
  X_CHANGE_ID in NUMBER
) is
begin

  delete from EGO_IMPORT_BATCH_CHANGES
  where BATCH_ID = X_BATCH_ID
  and CHANGE_ID = X_CHANGE_ID ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_IMPORT_CHANGE_ROW ;


/********************************************************************
* API Type      : Nulling out values for GDSN records
* Purpose       : Nulling out values for GDSN records
*********************************************************************/
FUNCTION Get_Nulled_out_Value(value IN VARCHAR2)
  RETURN VARCHAR2 IS
  l_null_out_value VARCHAR2(1000) ;
  BEGIN
    l_null_out_value := value;
    if ( value = ENG_CHANGE_ATTR_UTIL.G_ATTR_NULL_CHAR)
    THEN
      l_null_out_value := EGO_ITEM_PUB.G_INTF_NULL_CHAR;
      END IF;
  return l_null_out_value;
  END Get_Nulled_out_Value;


FUNCTION Get_Nulled_out_Value(value IN DATE)
  RETURN DATE IS
  l_null_out_value DATE ;
  BEGIN
    l_null_out_value := value;
    if ( value = ENG_CHANGE_ATTR_UTIL.G_ATTR_NULL_DATE)
    THEN
          l_null_out_value := EGO_ITEM_PUB.G_INTF_NULL_DATE;
    END IF;
  return l_null_out_value;
  END Get_Nulled_out_Value;


FUNCTION Get_Nulled_out_Value(value IN NUMBER)
  RETURN NUMBER IS
  l_null_out_value NUMBER ;
  BEGIN
    l_null_out_value := value;
    if ( value = ENG_CHANGE_ATTR_UTIL.G_ATTR_NULL_NUM)
    THEN
          l_null_out_value := EGO_ITEM_PUB.G_INTF_NULL_NUM;
    END IF;
  return l_null_out_value;

  END Get_Nulled_out_Value;

procedure code_debug (msg   IN  VARCHAR2
                     ,debug_level  IN  NUMBER  default 3
                     ) IS
BEGIN
null;

IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  IF NVL(FND_GLOBAL.conc_request_id, -1) <> -1 THEN

    FND_FILE.put_line(which => FND_FILE.LOG
                     ,buff  => '[ENG_CHANGE_IMPORT_UTIL] '||msg);
  END IF;
END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END code_debug;

--ER 9489112, called in ChangeImportManager/ChangeImportUtil before UDA changes created
--Used to update SYNC transaction type of rev level Change order controlled UDA from SYNC to CREATE OR UPDATE
PROCEDURE Update_Rev_Level_Trans_Type(
     p_api_version                   IN   NUMBER
    ,p_application_id                IN   NUMBER
    ,p_attr_group_type               IN   VARCHAR2
    ,p_object_name                   IN   VARCHAR2
    ,p_data_set_id                   IN   NUMBER
    ,p_entity_id                     IN   NUMBER     DEFAULT NULL
    ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
    ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
		TYPE DYNAMIC_CUR IS REF CURSOR;
		 TYPE DIST_MR_ATTR_GR_REC IS RECORD
    (
     ATTR_GROUP_INT_NAME      VARCHAR2(30)
    );

    l_api_name               CONSTANT VARCHAR2(30) := 'Update_Rev_Level_Trans_Type';
		wierd_constant                      VARCHAR2(100);
		wierd_constant_2                    VARCHAR2(100);
		l_dynamic_sql                       VARCHAR2(32767);
		l_ext_table_select                  VARCHAR2(32767);
		l_dummy                             NUMBER;

		l_pk1_column_name                   VARCHAR2(30);
		l_pk2_column_name                   VARCHAR2(30);
		l_pk3_column_name                   VARCHAR2(30);
		l_pk4_column_name                   VARCHAR2(30);
		l_pk5_column_name                   VARCHAR2(30);
		l_pk1_column_type                   VARCHAR2(8);
		l_pk2_column_type                   VARCHAR2(8);
		l_pk3_column_type                   VARCHAR2(8);
		l_pk4_column_type                   VARCHAR2(8);
		l_pk5_column_type                   VARCHAR2(8);
		l_item_rev_dl_id                    NUMBER;
		l_sync_count	                      NUMBER;
    l_intf_column_name                  VARCHAR2(50);
    l_intf_tbl_select                   VARCHAR2(32767);


		l_attr_group_metadata_obj           EGO_ATTR_GROUP_METADATA_OBJ;
		l_attr_metadata_table               EGO_ATTR_METADATA_TABLE;
		l_attr_metadata_table_sr            EGO_ATTR_METADATA_TABLE;
		l_attr_metadata_table_1             EGO_ATTR_METADATA_TABLE;


		l_data_level_metadata_obj           EGO_DATA_LEVEL_METADATA_OBJ;


		l_dynamic_cursor                    DYNAMIC_CUR;
		l_dynamic_dist_ag_cursor            DYNAMIC_CUR;
		l_mr_dynamic_cursor                 DYNAMIC_CUR;
		l_attr_group_intf_rec               DIST_MR_ATTR_GR_REC;
begin

	SELECT DATA_LEVEL_ID
    INTO  l_item_rev_dl_id
    FROM EGO_DATA_LEVEL_B
    WHERE ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
      AND APPLICATION_ID = p_application_id
      AND DATA_LEVEL_NAME = 'ITEM_REVISION_LEVEL';


	--quit the procedure if no SYNC transtype found for rev level UDA with process_status 5
	select count(1) into l_sync_count
  from ego_itm_usr_attr_intrfc
  where transaction_type = 'SYNC'
        and data_level_id = l_item_rev_dl_id
        and process_status = 5;
	IF l_sync_count = 0 THEN
    code_debug (l_api_name ||' returning as there are no records to process ');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;


	  IF FND_API.To_Boolean(p_commit) THEN
      SAVEPOINT Update_Rev_Level_User_Attrs;
    END IF;

	  G_ENTITY_ID        := p_entity_id;

		BEGIN
      SELECT application_short_name
      INTO  G_APPLICATION_CONTEXT
      FROM  fnd_application
      WHERE application_id = p_application_id;
    EXCEPTION
      WHEN OTHERS THEN
        G_APPLICATION_CONTEXT := p_application_id;
    END;

    SELECT NVL(p_entity_code, DECODE(G_ENTITY_ID, NULL, G_APPLICATION_CONTEXT||'_EXTFWK_USER_ATTRS',NULL))
    INTO G_ENTITY_CODE
    FROM DUAL;


--Update SYNC/CREATE transaction type for Single Row AG to UPDATE/CREATE
--

  UPDATE EGO_ITM_USR_ATTR_INTRFC uai2
   SET uai2.transaction_type =
          DECODE ((SELECT COUNT (1)
                     FROM ego_mtl_sy_items_ext_vl
                    WHERE attr_group_id = uai2.attr_group_id
                      AND ROWNUM < 2
                      AND inventory_item_id = uai2.inventory_item_id
                      AND organization_id = uai2.organization_id
                      AND NVL (data_level_id, 9.97e125) =
                                            NVL (uai2.data_level_id, 9.97e125)
                      AND NVL (pk1_value, 9.97e125) =
                                                NVL (uai2.pk1_value, 9.97e125)
                      AND NVL (pk2_value, 9.97e125) =
                                                NVL (uai2.pk2_value, 9.97e125)
                      AND NVL (revision_id, 9.97e125) =
                                              NVL (uai2.revision_id, 9.97e125)),
                  0, EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE,
                 EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE
                 )
 WHERE uai2.data_set_id = p_data_set_id
   AND transaction_id IS NOT NULL
   AND uai2.attr_group_type =p_attr_group_type
   AND uai2.process_status = 5
   AND uai2.transaction_type in (EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE,EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE)
   AND NVL (uai2.data_level_id,9.97e125) = l_item_rev_dl_id
   AND (SELECT multi_row
          FROM ego_fnd_dsc_flx_ctx_ext flx_ext
         WHERE descriptive_flex_context_code = uai2.attr_group_int_name
           AND application_id = p_application_id
           AND descriptive_flexfield_name =p_attr_group_type) <>'Y' ;
--Step3, update SYNC transaction type for Single Row AG to UPDATE/CREATE
-- Need check unique key
  -----------------------------------------
  -- Fetch the PK column names and data  --
  -- types for the passed-in object name --
  -----------------------------------------
		SELECT PK1_COLUMN_NAME, PK1_COLUMN_TYPE,
		     PK2_COLUMN_NAME, PK2_COLUMN_TYPE,
		     PK3_COLUMN_NAME, PK3_COLUMN_TYPE,
		     PK4_COLUMN_NAME, PK4_COLUMN_TYPE,
		     PK5_COLUMN_NAME, PK5_COLUMN_TYPE
		INTO l_pk1_column_name, l_pk1_column_type,
		     l_pk2_column_name, l_pk2_column_type,
		     l_pk3_column_name, l_pk3_column_type,
		     l_pk4_column_name, l_pk4_column_type,
		     l_pk5_column_name, l_pk5_column_type
		FROM FND_OBJECTS
		WHERE OBJ_NAME = p_object_name;

		l_data_level_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Data_Level_Metadata( p_data_level_id   => l_item_rev_dl_id);

		OPEN l_dynamic_dist_ag_cursor FOR
			'SELECT DISTINCT ATTR_GROUP_INT_NAME
			FROM EGO_ITM_USR_ATTR_INTRFC UAI1
			WHERE DATA_SET_ID = :data_set_id AND data_level_id = '||l_item_rev_dl_id||'
			AND transaction_id IS NOT NULL
			AND UAI1.PROCESS_STATUS = 5 AND UAI1.TRANSACTION_TYPE = '''||
			EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE||''''
		USING p_data_set_id;
    LOOP
			FETCH l_dynamic_dist_ag_cursor INTO l_attr_group_intf_rec;
			EXIT WHEN l_dynamic_dist_ag_cursor%NOTFOUND;

				   l_attr_group_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata(
				                                 p_attr_group_id   => NULL
				                                ,p_application_id  => p_application_id
				                                ,p_attr_group_type => p_attr_group_type
				                                ,p_attr_group_name => l_attr_group_intf_rec.ATTR_GROUP_INT_NAME
				                               );
				   l_attr_metadata_table := l_attr_group_metadata_obj.ATTR_METADATA_TABLE;
				   l_attr_metadata_table_sr := l_attr_group_metadata_obj.ATTR_METADATA_TABLE;
				   l_attr_metadata_table_1 := l_attr_group_metadata_obj.ATTR_METADATA_TABLE;

				  IF (l_attr_group_metadata_obj.MULTI_ROW_CODE = 'Y') THEN
				    l_ext_table_select := ' EGO_MTL_SY_ITEMS_EXT_VL EXTVL1 WHERE EXTVL1.ATTR_GROUP_ID='||l_attr_group_metadata_obj.ATTR_GROUP_ID||' ';

				    --LOOP THROUGH ALL THE ATTRS METADATA FOR THIS MR AG
				    FOR i IN l_attr_metadata_table.FIRST .. l_attr_metadata_table.LAST
				    LOOP
				      IF (l_attr_metadata_table(i).UNIQUE_KEY_FLAG = 'Y' ) THEN

				          IF (l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE ) THEN
				            l_intf_column_name := ' ATTR_VALUE_NUM ';
				            wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_NUM;
				          ELSIF (l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR l_attr_metadata_table(i).DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE ) THEN
				            l_intf_column_name := ' ATTR_VALUE_DATE ';
				            wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_DATE;
				          ELSE
				            l_intf_column_name := ' ATTR_VALUE_STR ';
				            wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_STR;
				          END IF;

				          l_intf_tbl_select :=
				          ' (SELECT '||l_intf_column_name||' FROM EGO_ITM_USR_ATTR_INTRFC WHERE DATA_SET_ID = '||p_data_set_id||
				              ' AND ATTR_GROUP_INT_NAME = '''||
				                    l_attr_group_metadata_obj.ATTR_GROUP_NAME||
				            ''' AND ATTR_INT_NAME = '''||
				                    l_attr_metadata_table(i).ATTR_NAME||
				            ''' AND ROW_IDENTIFIER = UAI1.ROW_IDENTIFIER';

				          l_intf_tbl_select := l_intf_tbl_select || ')';

				          l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_attr_metadata_table(i).DATABASE_COLUMN||','||wierd_constant||') = NVL('||l_intf_tbl_select||','||wierd_constant||')';
				      END IF;
				   	 END LOOP; -- to fetch Unique key for MR Row


				   	  IF (l_pk1_column_name IS NOT NULL) THEN
			          l_ext_table_select := l_ext_table_select || ' AND EXTVL1.'||l_pk1_column_name||' = UAI1.'||l_pk1_column_name;
			        END IF;
			        IF (l_pk2_column_name IS NOT NULL) THEN
			          l_ext_table_select := l_ext_table_select || ' AND EXTVL1.'||l_pk2_column_name||' = UAI1.'||l_pk2_column_name;
			        END IF;
			        IF (l_pk3_column_name IS NOT NULL) THEN
			          l_ext_table_select := l_ext_table_select || ' AND EXTVL1.'||l_pk3_column_name||' = UAI1.'||l_pk3_column_name;
			        END IF;
			        IF (l_pk4_column_name IS NOT NULL) THEN
			          l_ext_table_select := l_ext_table_select || ' AND EXTVL1.'||l_pk4_column_name||' = UAI1.'||l_pk4_column_name;
			        END IF;
			        IF (l_pk5_column_name IS NOT NULL) THEN
			          l_ext_table_select := l_ext_table_select || ' AND EXTVL1.'||l_pk5_column_name||' = UAI1.'||l_pk5_column_name;
			        END IF;

				   	  l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.DATA_LEVEL_ID,'||EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_NUM||') '||
                                                            '   = NVL(UAI1.DATA_LEVEL_ID,'||EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_NUM||')';

				   	  /* Append data level PK condition for Rev Item level - 43106*/
				   	  IF (l_data_level_metadata_obj.PK_COLUMN_NAME1 IS NOT NULL AND l_data_level_metadata_obj.PK_COLUMN_NAME1 <> 'NONE'
	                AND INSTR(l_ext_table_select,l_data_level_metadata_obj.PK_COLUMN_NAME1) = 0) THEN

	                     IF(l_data_level_metadata_obj.PK_COLUMN_TYPE1 = 'NUMBER') THEN
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_NUM;
	                     ELSIF (l_data_level_metadata_obj.PK_COLUMN_TYPE1 = 'DATE' OR l_data_level_metadata_obj.PK_COLUMN_TYPE1 = 'DATETIME') THEN
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_DATE;
	                     ELSE
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_STR;
	                     END IF;
	                     l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_data_level_metadata_obj.PK_COLUMN_NAME1||','||wierd_constant||') '||
	                                                                       '   = NVL(UAI1.'||l_data_level_metadata_obj.PK_COLUMN_NAME1||','||wierd_constant||')';
	             END IF;
	             IF (l_data_level_metadata_obj.PK_COLUMN_NAME2 IS NOT NULL AND l_data_level_metadata_obj.PK_COLUMN_NAME2 <> 'NONE'
	                AND INSTR(l_ext_table_select,l_data_level_metadata_obj.PK_COLUMN_NAME2) = 0) THEN
	                     IF(l_data_level_metadata_obj.PK_COLUMN_TYPE2 = 'NUMBER') THEN
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_NUM;
	                     ELSIF (l_data_level_metadata_obj.PK_COLUMN_TYPE2 = 'DATE' OR l_data_level_metadata_obj.PK_COLUMN_TYPE2 = 'DATETIME') THEN
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_DATE;
	                     ELSE
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_STR;
	                     END IF;
	                     l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_data_level_metadata_obj.PK_COLUMN_NAME2||','||wierd_constant||') '||
	                                                                       '   = NVL(UAI1.'||l_data_level_metadata_obj.PK_COLUMN_NAME2||','||wierd_constant||')';
	             END IF;
	             IF (l_data_level_metadata_obj.PK_COLUMN_NAME3 IS NOT NULL AND l_data_level_metadata_obj.PK_COLUMN_NAME3 <> 'NONE'
	                AND INSTR(l_ext_table_select,l_data_level_metadata_obj.PK_COLUMN_NAME3) = 0) THEN
	                     IF(l_data_level_metadata_obj.PK_COLUMN_TYPE3 = 'NUMBER') THEN
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_NUM;
	                     ELSIF (l_data_level_metadata_obj.PK_COLUMN_TYPE3 = 'DATE' OR l_data_level_metadata_obj.PK_COLUMN_TYPE3 = 'DATETIME') THEN
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_DATE;
	                     ELSE
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_STR;
	                     END IF;
	                     l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_data_level_metadata_obj.PK_COLUMN_NAME3||','||wierd_constant||') '||
	                                                                       '   = NVL(UAI1.'||l_data_level_metadata_obj.PK_COLUMN_NAME3||','||wierd_constant||')';
	             END IF;
	             IF (l_data_level_metadata_obj.PK_COLUMN_NAME4 IS NOT NULL AND l_data_level_metadata_obj.PK_COLUMN_NAME4 <> 'NONE'
	                AND INSTR(l_ext_table_select,l_data_level_metadata_obj.PK_COLUMN_NAME4) = 0) THEN
	                     IF(l_data_level_metadata_obj.PK_COLUMN_TYPE4 = 'NUMBER') THEN
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_NUM;
	                     ELSIF (l_data_level_metadata_obj.PK_COLUMN_TYPE4 = 'DATE' OR l_data_level_metadata_obj.PK_COLUMN_TYPE4 = 'DATETIME') THEN
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_DATE;
	                     ELSE
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_STR;
	                     END IF;
	                     l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_data_level_metadata_obj.PK_COLUMN_NAME4||','||wierd_constant||') '||
	                                                                       '   = NVL(UAI1.'||l_data_level_metadata_obj.PK_COLUMN_NAME4||','||wierd_constant||')';
	             END IF;
	             IF (l_data_level_metadata_obj.PK_COLUMN_NAME5 IS NOT NULL AND l_data_level_metadata_obj.PK_COLUMN_NAME5 <> 'NONE'
	                AND INSTR(l_ext_table_select,l_data_level_metadata_obj.PK_COLUMN_NAME5) = 0) THEN
	                     IF(l_data_level_metadata_obj.PK_COLUMN_TYPE5 = 'NUMBER') THEN
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_NUM;
	                     ELSIF (l_data_level_metadata_obj.PK_COLUMN_TYPE5 = 'DATE' OR l_data_level_metadata_obj.PK_COLUMN_TYPE5 = 'DATETIME') THEN
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_DATE;
	                     ELSE
	                       wierd_constant := EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_STR;
	                     END IF;
	                     l_ext_table_select := l_ext_table_select || ' AND NVL(EXTVL1.'||l_data_level_metadata_obj.PK_COLUMN_NAME5||','||wierd_constant||') '||
	                                                                       '   = NVL(UAI1.'||l_data_level_metadata_obj.PK_COLUMN_NAME5||','||wierd_constant||')';
	             END IF;

				        --------------------------------------------------
				        -- Here we update the INTF table transaction_type
				        -- from SYNC to CREATE or UPDATE
				        --------------------------------------------------
				        l_dynamic_sql :=
				        ' UPDATE ego_itm_usr_attr_intrfc UAI1
				            SET UAI1.TRANSACTION_TYPE = DECODE((SELECT COUNT(*) FROM '||l_ext_table_select||'),0,'''||
				                                               EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE||''','''||
				                                               EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE||''')
				          WHERE UAI1.transaction_id IS NOT NULL AND UAI1.DATA_SET_ID = '||p_data_set_id||
				          ' AND NVL(UAI1.DATA_LEVEL_ID,'||EGO_USER_ATTRS_BULK_PVT.G_NULL_TOKEN_NUM ||') = '||l_item_rev_dl_id ||
				          ' AND UAI1.ATTR_GROUP_INT_NAME = '''||l_attr_group_metadata_obj.ATTR_GROUP_NAME||
				          '''  AND UAI1.PROCESS_STATUS = 5 AND UAI1.TRANSACTION_TYPE IN ('''||EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE||''', '''||EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE ||''')';
				          code_debug('l_dynamic_sql FOR MR '||l_attr_group_intf_rec.ATTR_GROUP_INT_NAME || ' IS:' ||l_dynamic_sql ,2);
               EXECUTE IMMEDIATE l_dynamic_sql;
        END IF;
     END LOOP;
        --NVL (uai2.data_level_id,9.97e125) = l_item_rev_dl_id
EXCEPTION
    WHEN OTHERS THEN
      code_debug('######## Oops ... came into the when others block-'||SQLERRM ,2);
      IF FND_API.To_Boolean(p_commit) THEN
        ROLLBACK TO Update_Rev_Level_User_Attrs;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

      -----------------------------------------------------------------
      -- Get a default row identifier to use in logging this message --
      -----------------------------------------------------------------
      l_dynamic_sql :=
      'SELECT TRANSACTION_ID
         FROM EGO_ITM_USR_ATTR_INTRFC UAI1
        WHERE UAI1.DATA_SET_ID = :data_set_id
          AND ROWNUM = 1';
      EXECUTE IMMEDIATE l_dynamic_sql
      INTO l_dummy
      USING p_data_set_id;
      ERROR_HANDLER.Add_Error_Message(
        p_message_text                  => x_msg_data
       ,p_row_identifier                => l_dummy
       ,p_application_id                => 'EGO'
       ,p_message_type                  => FND_API.G_RET_STS_ERROR
       ,p_entity_id                     => G_ENTITY_ID
       ,p_table_name                    => 'ego_itm_usr_attr_intrfc'
       ,p_entity_code                   => G_ENTITY_CODE
      );

END Update_Rev_Level_Trans_Type;


PROCEDURE IS_CHANGE_REC_EXIST_FOR_BAT (
  p_batch_id          IN  NUMBER,
  p_batch_type        IN  VARCHAR2  := NULL,
  p_process_entity    IN  VARCHAR2  := NULL,
  p_cm_process_type   IN  VARCHAR2  := NULL,
  x_change_rec_exist  OUT NOCOPY NUMBER  --1=YES, 2=NO
)
IS


    l_cm_import_option     VARCHAR2(30)  ;
    l_dyn_sql             VARCHAR2(10000);

    I                     PLS_INTEGER ;
    l_intf_table          DBMS_SQL.VARCHAR2_TABLE;
    l_intf_batch_id_col   DBMS_SQL.VARCHAR2_TABLE;
    l_intf_proc_flag_col  DBMS_SQL.VARCHAR2_TABLE;
    l_intf_ri_seq_id_col  DBMS_SQL.VARCHAR2_TABLE;
    l_intf_attr_grp_type  DBMS_SQL.VARCHAR2_TABLE;
    l_intf_change_number_col  DBMS_SQL.VARCHAR2_TABLE;
    l_dummy NUMBER := 0;
    l_exist NUMBER := 2;

BEGIN

    -- Get Process Interface Table  Definitions
    Get_Process_IntfTable_Def(p_process_entity          => p_process_entity
                            , x_intf_table              => l_intf_table
                            , x_intf_batch_id_col       => l_intf_batch_id_col
                            , x_intf_proc_flag_col      => l_intf_proc_flag_col
                            , x_intf_ri_seq_id_col      => l_intf_ri_seq_id_col
                            , x_intf_attr_grp_type      => l_intf_attr_grp_type
                            , x_intf_chg_notice_col     => l_intf_change_number_col
                            ) ;

    -- Get Change Mgmt Import Option
    l_cm_import_option := GET_CM_IMPORT_OPTION(p_batch_id => p_batch_id) ;

    FOR i IN 1..l_intf_table.COUNT LOOP
      l_dyn_sql := '';
      l_dyn_sql :=               ' SELECT count(*) ';
      l_dyn_sql := l_dyn_sql || '    FROM ' || l_intf_table(i) || ' INTF ';
      l_dyn_sql := l_dyn_sql || '   WHERE INTF.' || l_intf_batch_id_col(i) || ' = :BATCH_ID ' ;
      l_dyn_sql := l_dyn_sql || '     AND INTF.' || l_intf_proc_flag_col(i) || ' = ' || G_CM_TO_BE_PROCESSED  ;
      l_dyn_sql := l_dyn_sql || '     AND ROWNUM = 1 ' ;

      EXECUTE IMMEDIATE l_dyn_sql
      INTO l_dummy
      USING p_batch_id ;

      --IF one table is found to have change records, it satisifies the condition. Exit loop
      IF l_dummy > 0 THEN
        EXIT;
      END IF;

    END LOOP;

    IF nvl(l_dummy,0) > 0 THEN
      x_change_rec_exist := 1;
    ELSE
      x_change_rec_exist := 2;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
      x_change_rec_exist := 1; --non-fatal issue - continue the normal validation even if any error happens here


END IS_CHANGE_REC_EXIST_FOR_BAT ;




END ENG_CHANGE_IMPORT_UTIL ;

/
