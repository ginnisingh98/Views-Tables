--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_BULKLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_BULKLOAD_PKG" AS
/* $Header: EGOIBLKB.pls 120.90.12010000.8 2011/06/27 08:58:41 nendrapu ship $ */


                   ------------------------------
                   -- Private Global Variables --
                   ------------------------------

   --------------------------------------------
   -- This is Database Session Language.     --
   --------------------------------------------
   G_SESSION_LANG           CONSTANT VARCHAR2(99) := USERENV('LANG');

   --------------------------------------------
   -- This is the UI language.               --
   --------------------------------------------
   G_LANGUAGE_CODE           VARCHAR2(3);

   --------------------------------------------------------------------------
   --  Debug Profile option used to write Error_Handler.Write_Debug        --
   --  Profile option name = INV_DEBUG_TRACE ;                             --
   --  User Profile Option Name = INV: Debug Trace                         --
   --  Values: 1 (True) ; 0 (False)                                        --
   --  NOTE: This better than MRP_DEBUG which is used at many places.      --
   --------------------------------------------------------------------------
   G_DEBUG CONSTANT VARCHAR2(10) := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

   -----------------------------------------------------------------------
   -- These are the Constants to generate a New Line Character.         --
   -----------------------------------------------------------------------
   G_CARRIAGE_RETURN VARCHAR2(1) :=  FND_GLOBAL.LOCAL_CHR(13);
   G_LINE_FEED       VARCHAR2(1) :=  FND_GLOBAL.LOCAL_CHR(10);
   -- Following prints ^M characters in the log file.
   -- G_NEWLINE         VARCHAR2(2) :=  G_CARRIAGE_RETURN || G_LINE_FEED; --(carriage-return/line-feed)
   G_NEWLINE         VARCHAR2(2) :=  G_LINE_FEED;

   -----------------------------------------------------------------------
   -- This is the Result Format Usage ID for the Current Upload.        --
   -----------------------------------------------------------------------
   G_RESULTFMT_USAGE_ID      NUMBER;

   -------------------------------------------------------
   -- The following two variables are for Error_Handler --
   -------------------------------------------------------
   G_ENTITY_ID               NUMBER := NULL;
   G_ENTITY_CODE    CONSTANT VARCHAR2(30) := 'ITEM_OPER_ATTRS_ENTITY_CODE';


   -------------------------------------------------------
   -- Used for Item Operational Attribute bulkload SQLs --
   -------------------------------------------------------
   G_APPLICATION_ID          NUMBER(3)    := 431;
   G_EGO_ITEM_OBJ_NAME       VARCHAR2(30) := 'EGO_ITEM';

   ---------------------------------------------------------------------------
   -- User-Defined Attr Group Types currently handled by this Bulkload code --
   ---------------------------------------------------------------------------
   G_IUD_ATTR_GROUP_TYPE     VARCHAR2(30) := 'EGO_ITEMMGMT_GROUP';  -- Item User-Defined Attrs
   G_GTN_SNG_ATTR_GROUP_TYPE VARCHAR2(30) := 'EGO_ITEM_GTIN_ATTRS'; -- GTIN Single Row Attrs
   G_GTN_MUL_ATTR_GROUP_TYPE VARCHAR2(30) := 'EGO_ITEM_GTIN_MULTI_ATTRS'; -- GTIN Multi Row Attrs
   G_ERP_ATTR_GROUP_TYPE     VARCHAR2(30) := 'EGO_MASTER_ITEMS';   -- Item Master Operational Attrs

   ----------------------------------------------------------------------------
   -- The Date Format is chosen to be as close as possible to Timestamp format,
   -- except that we support dates before zero A.D. (the "S" in the year part).
   ----------------------------------------------------------------------------
   G_DATE_FORMAT    CONSTANT VARCHAR2(30) := 'SYYYY-MM-DD HH24:MI:SS';
   G_EXCEL_NULL_DATE         DATE  := TO_DATE('9999-12-31','YYYY-MM-DD');

   G_CONCREQ_VALID_FLAG      BOOLEAN;

   ---------------------------------------------------------------
   -- Same dimension as classification1 in EGO_RESULTS_FORMAT_V --
   ---------------------------------------------------------------
   G_CATALOG_GROUP_ID        VARCHAR2(50);

   ---------------------------------------------------------------
   -- To be used by Item and Item Rev interfaces.               --
   ---------------------------------------------------------------
   G_MSII_SET_PROCESS_ID     NUMBER;


   ---------------------------------------------------------------
   -- This flag will be set to TRUE for pdh batch and           --
   -- FALSE for all non PDH batches                             --
   ---------------------------------------------------------------
   G_PDH_BATCH               BOOLEAN;

   ---------------------------------------------------------------
   -- The process status to be set to the interface table is    --
   -- 1 by default. But for non PDH batch, set status to 0      --
   ---------------------------------------------------------------

   G_PROCESS_STATUS          NUMBER := 1;

   ---------------------------------------------------------------
   -- Used for Error Reporting.                                 --
   ---------------------------------------------------------------
   G_ERROR_TABLE_NAME        VARCHAR2(99) := 'EGO_BULKLOAD_INTF';
   G_ERROR_ENTITY_CODE       VARCHAR2(99) := 'EGO_ITEM';
   G_ERROR_FILE_NAME         VARCHAR2(99);
   G_BO_IDENTIFIER           VARCHAR2(99) := 'EGO_ITEM';
   G_INV_STATUS_CODE_NAME    VARCHAR2(99) := 'INVENTORY_ITEM_STATUS_CODE';

   ---------------------------------------------------------------
   -- Introduced for 11.5.10, so that Java Conc Program can     --
   -- continue writing to the same Error Log File.              --
   ---------------------------------------------------------------
   G_ERRFILE_PATH_AND_NAME   VARCHAR2(10000);

   ---------------------------------------------------------------
   -- API Return statuses.                                      --
   ---------------------------------------------------------------
   G_STATUS_SUCCESS    CONSTANT VARCHAR2(1)    := 'S';
   G_STATUS_ERROR      CONSTANT VARCHAR2(1)    := 'E';

   ---------------------------------------------------------------
   -- Interface line processing statuses.                       --
   ---------------------------------------------------------------
   G_INTF_STATUS_TOBE_PROCESS   CONSTANT NUMBER := 1;
   G_INTF_STATUS_SUCCESS        CONSTANT NUMBER := 7;
   G_INTF_STATUS_ERROR          CONSTANT NUMBER := 3;

   ---------------------------------------------------------------
   -- Interface line Transaction Types.                         --
   ---------------------------------------------------------------
   G_CREATE             CONSTANT VARCHAR2(10) := 'CREATE';
   G_UPDATE             CONSTANT VARCHAR2(10) := 'UPDATE';
   G_SYNC               CONSTANT VARCHAR2(10) := 'SYNC';


   ------------------------------------------------------------------------------
   -- Generic Bulkload interface table: EGO_BULKLOAD_INTF segment number range --
   -- as per data type.                                                        --
   ------------------------------------------------------------------------------
   G_VARCHAR_SEQ_MIN        NUMBER := 1;
   G_VARCHAR_SEQ_MAX        NUMBER := 200;
   G_NUMBER_SEQ_MIN         NUMBER := 201;
   G_NUMBER_SEQ_MAX         NUMBER := 350;
   G_DATE_SEQ_MIN           NUMBER := 351;
   G_DATE_SEQ_MAX           NUMBER := 360;

   ---------------------------------------------------------------------------
   -- Define the Base Attribute Names that require Value-to-ID Conversion.  --
   ---------------------------------------------------------------------------
   G_ITEM_NUMBER            VARCHAR2(50) := 'ITEM_NUMBER';
   G_ITEM_TEMPLATE_NAME     VARCHAR2(50) := 'TEMPLATE_NAME';
   G_ORG_CODE               VARCHAR2(50) := 'ORGANIZATION_CODE';
   -- Following column values are Editable --
   G_ITEM_CATALOG_GROUP1    VARCHAR2(50) := 'CATALOG_GROUP';
   G_ITEM_CATALOG_GROUP     VARCHAR2(50) := 'ITEM_CATALOG_GROUP_NAME';
   G_PRIMARY_UOM            VARCHAR2(50) := 'PRIMARY_UOM_CODE';
   G_LIFECYCLE              VARCHAR2(50) := 'LIFECYCLE_ID'; --LIFECYCLE
   G_LIFECYCLE_PHASE        VARCHAR2(50) := 'CURRENT_PHASE_ID'; -- LIFECYCLE_PHASE
   G_USER_ITEM_TYPE         VARCHAR2(50) := 'ITEM_TYPE';
   G_BOM_ITEM_TYPE          VARCHAR2(50) := 'BOM_ITEM_TYPE';
   G_ENG_ITEM_FLAG          VARCHAR2(50) := 'ENG_ITEM_FLAG';
   G_DESCRIPTION            VARCHAR2(50) := 'DESCRIPTION';  -- Bug: 3778006
   G_CREATED_BY             VARCHAR2(50) := 'CREATED_BY'; -- Bug:  5439746
   G_CREATION_DATE          VARCHAR2(50) := 'CREATION_DATE';
   --Bug: 3969593 Adding new 11.5.10 Primary Attrs: Begin
   G_CONVERSIONS            VARCHAR2(50) := 'ALLOWED_UNITS_LOOKUP_CODE';
   G_SECONDARY_DEF_IND      VARCHAR2(50) := 'SECONDARY_DEFAULT_IND';
   G_DUAL_UOM_DEV_LOW       VARCHAR2(50) := 'DUAL_UOM_DEVIATION_LOW';
   G_DUAL_UOM_DEV_HIGH      VARCHAR2(50) := 'DUAL_UOM_DEVIATION_HIGH';
   G_ONT_PRICING_QTY_SRC    VARCHAR2(50) := 'ONT_PRICING_QTY_SOURCE';
   G_SECONDARY_UOM_CODE     VARCHAR2(50) := 'SECONDARY_UOM_CODE';
   G_TRACKING_QTY_IND       VARCHAR2(50) := 'TRACKING_QUANTITY_IND';
   --Bug: 3969593 End
   G_INVENTORY_ITEM_STATUS  VARCHAR2(50) := 'INVENTORY_ITEM_STATUS_CODE';--Rathna MLS STatus
   -- Trade Item Descriptor for Import Pack Hierarchies
   G_TRADE_ITEM_DESCRIPTOR  VARCHAR2(50) := 'TRADE_ITEM_DESCRIPTOR';
   ---------------------------------------------------------------
   -- Item Result Format Data Levels.                           --
   ---------------------------------------------------------------
   G_ITEM_DATA_LEVEL        VARCHAR2(50) := 'ITEM_LEVEL';
   G_ITEM_REV_DATA_LEVEL    VARCHAR2(50) := 'ITEM_REVISION_LEVEL';

   -----------------------------------------------------------------
   -- Item Revision Attribute Codes and Corresponding DB Columns. --
   -----------------------------------------------------------------

           ------------------------------------
           -- Item Revision Attribute Codes  --
           ------------------------------------
   G_REV_ID_ATTR_CODE          VARCHAR2(50) := 'REVISION_ID';
   G_REV_CODE_ATTR_CODE        VARCHAR2(50) := 'REVISION';
   G_REV_LABEL_ATTR_CODE       VARCHAR2(50) := 'REVISION_LABEL';
   G_REV_DESCRIPTION_ATTR_CODE VARCHAR2(50) := 'REVISION_DESCRIPTION';
   G_REV_REASON_ATTR_CODE      VARCHAR2(50) := 'REVISION_REASON';
   G_REV_LC_ID_ATTR_CODE       VARCHAR2(50) := 'REVISION_LIFECYCLE_ID';
   G_REV_LC_PHASE_ID_ATTR_CODE VARCHAR2(50) := 'REVISION_CURRENT_PHASE_ID';
   G_REV_IMPL_DATE_ATTR_CODE   VARCHAR2(50) := 'REVISION_IMPLEMENTATION_DATE';

   -- Revisions Import Format uses following Attribute Code. --
   G_REV_EFF_DATE_ATTR_CODE    VARCHAR2(50) := 'REVISION_EFFECTIVE_DATE';
   -- Item Result Format uses following Attribute Code. --
   G_REV_EFF_DATE_ATTR_CODE_2  VARCHAR2(50) := 'REVISION_EFFECTIVITY_DATE';

           -------------------------------------
           -- Item Revision Database Columns  --
           -------------------------------------
   G_REV_ID_DB_COL             VARCHAR2(50) := 'REVISION_ID';
   G_REV_CODE_DB_COL           VARCHAR2(50) := 'REVISION';
   G_REV_LABEL_DB_COL          VARCHAR2(50) := 'REVISION_LABEL';
   G_REV_DESCRIPTION_DB_COL    VARCHAR2(50) := 'DESCRIPTION';
   G_REV_REASON_DB_COL         VARCHAR2(50) := 'REVISION_REASON';
   G_REV_LC_ID_DB_COL          VARCHAR2(50) := 'LIFECYCLE_ID';
   G_REV_LC_PHASE_ID_DB_COL    VARCHAR2(50) := 'CURRENT_PHASE_ID';
   G_REV_IMPL_DATE_DB_COL      VARCHAR2(50) := 'IMPLEMENTATION_DATE';
   G_REV_EFF_DATE_DB_COL       VARCHAR2(50) := 'EFFECTIVITY_DATE';

   -----------------------------------------------------------------------
   -- Using following Columns in EGO_BULKLOAD_INTF as buffer columns to --
   -- store item attributes information, to be retrieved later :        --
   -- 1. While inserting in MTL_SYSTEM_ITEMS_INTERFACE.                 --
   -- 2. While querying the errors page.                                --
   -----------------------------------------------------------------------
   -- used for all value set conversions as the user enters the display
   -- value which will be converted into internal value.
   G_VAL_SET_CONV_ERR_COL           VARCHAR2(50) := 'C_INTF_ATTR231';
   --Bug: 3969593 Adding new 11.5.10 Primary Attrs: Begin
   G_CONVERSIONS_EBI_COL            VARCHAR2(50) := 'C_INTF_ATTR232';
   G_SECONDARY_DEF_IND_EBI_COL      VARCHAR2(50) := 'C_INTF_ATTR233';
   G_ONT_PRICING_QTY_SRC_EBI_COL    VARCHAR2(50) := 'C_INTF_ATTR236';
   G_SECONDARY_UOM_CODE_EBI_COL     VARCHAR2(50) := 'C_INTF_ATTR237';
   G_TRACKING_QTY_IND_EBI_COL       VARCHAR2(50) := 'C_INTF_ATTR238';
   --Bug: 3969593 End
   G_ITEM_NUMBER_EBI_COL            VARCHAR2(50) := 'C_INTF_ATTR240';
   G_ORG_CODE_EBI_COL               VARCHAR2(50) := 'C_INTF_ATTR241';
   G_REVISION_CODE_EBI_COL          VARCHAR2(50) := 'C_INTF_ATTR242';
   G_ITEM_CATALOG_EBI_COL           VARCHAR2(50) := 'C_INTF_ATTR243';
   G_ITEM_CATALOG_NAME_EBI_COL      VARCHAR2(50) := 'C_INTF_ATTR244';
   G_PRIMARY_UOM_EBI_COL            VARCHAR2(50) := 'C_INTF_ATTR245';
   G_LIFECYCLE_EBI_COL              VARCHAR2(50) := 'C_INTF_ATTR246';
   G_LIFECYCLE_PHASE_EBI_COL        VARCHAR2(50) := 'C_INTF_ATTR247';
   G_USER_ITEM_TYPE_EBI_COL         VARCHAR2(50) := 'C_INTF_ATTR248';
   G_BOM_ITEM_TYPE_EBI_COL          VARCHAR2(50) := 'C_INTF_ATTR249';
   G_ENG_ITEM_FLAG_EBI_COL          VARCHAR2(50) := 'C_INTF_ATTR250';
   G_DESCRIPTION_EBI_COL            VARCHAR2(50) := 'DESCRIPTION1';  -- Bug: 3778006
     ----------------------------
     -- Introduced for 11.5.10 --
     ----------------------------
   G_ERR_LOGFILE_COL                VARCHAR2(50) := 'C_INTF_ATTR239';
   l_inventory_item_status_col      VARCHAR2(50) := NULL;  --Rathna MLS Status
   l_trade_item_descriptor_col      VARCHAR2(50) := NULL;  --R12C Pack Changes

   -----------------------------------------
   -- R12 - GTIN needs to be populated
   -- in MTL_SYSTEM_ITEMS_INTERFACE table
   -----------------------------------------
   G_GTIN_NUM_ATTR_CODE             VARCHAR2(50) := 'GTIN_NUM';
   G_GTIN_DESC_ATTR_CODE            VARCHAR2(50) := 'GTIN_DESC';
   G_GTIN_NUM_DB_COL                VARCHAR2(50) := 'GLOBAL_TRADE_ITEM_NUMBER';
   G_GTIN_DESC_DB_COL               VARCHAR2(50) := 'GTIN_DESCRIPTION';

   --------------------------------------------------------------------------
   -- Choosing Err Status for MSII that dont conflict with other statuses. --
   -- These are intermediate error statuses, later on will be changed to   --
   -- status '3' (Error status in MSII)                                    --
   --------------------------------------------------------------------------
   G_ITEM_CATALOG_NAME_ERR_STS      NUMBER := 1000001;
   G_PRIMARY_UOM_ERR_STS            NUMBER := 1000002;
   G_LIFECYCLE_ERR_STS              NUMBER := 1000003;
   G_LIFECYCLE_PHASE_ERR_STS        NUMBER := 1000004;
   G_USER_ITEM_TYPE_ERR_STS         NUMBER := 1000005;
   G_BOM_ITEM_TYPE_ERR_STS          NUMBER := 1000006;
   G_ENG_ITEM_FLAG_ERR_STS          NUMBER := 1000007;
   G_DESCRIPTION_ERR_STS            NUMBER := 1000008;  -- Bug: 3778006
   --Bug: 3969593 Adding new 11.5.10 Primary Attrs: bEGIN
   G_CONVERSIONS_ERR_STS            NUMBER := 1000009;
   G_SECONDARY_DEF_IND_ERR_STS      NUMBER := 1000010;
   G_ONT_PRICING_QTY_SRC_ERR_STS    NUMBER := 1000011;
   G_SECONDARY_UOM_CODE_ERR_STS     NUMBER := 1000012;
   G_TRACKING_QTY_IND_ERR_STS       NUMBER := 1000013;
   G_INV_ITEM_STATUS_ERR_STS        NUMBER := 1000014;--Rathna MLS STatus
   --Bug: 3969593 End
   G_VS_INVALID_ERR_STS             NUMBER := 1000015;
   --R12C Packs changes for Trade Item Descriptor
   G_TRADE_ITEM_DESC_ERR_STS        NUMBER := 1000016;

   -----------------------------------------------------
   -- Global variables used in Concurrent Program.    --
   -----------------------------------------------------
   G_USER_ID         NUMBER  :=  -1;
   G_LOGIN_ID        NUMBER  :=  -1;
   G_PROG_APPID      NUMBER  :=  -1;
   G_PROG_ID         NUMBER  :=  -1;
   G_REQUEST_ID      NUMBER  :=  -1;

     ----------------------------------------------------------
   -- Define Exceptions.  Error numbers are in the range   --
   -- of negative integers  -20000 to -20999               --
   ----------------------------------------------------------
   G_SEGMENT_SEQ_INVALID    EXCEPTION;
   G_DATA_TYPE_INVALID      EXCEPTION;

   PRAGMA EXCEPTION_INIT(G_SEGMENT_SEQ_INVALID, -20000);
   PRAGMA EXCEPTION_INIT(G_DATA_TYPE_INVALID, -20001);
 -----------------------------------------------------------------
 -- Write Debug statements to Log using Error Handler procedure --
 -----------------------------------------------------------------
PROCEDURE Write_Debug (p_msg  IN  VARCHAR2) IS

BEGIN
  IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_FILE.put_line(which => FND_FILE.LOG
                     ,buff  => 'EGO_ITEM_BULKLOAD_PKG: '||p_msg);

  END IF;
  -- NOTE: No need to check for profile now, as Error_Handler checks
  --       for Error_Handler.Get_Debug = 'Y' before writing to Debug Log.
  -- If Profile set to TRUE --
  -- IF (G_DEBUG = 1) THEN
  -- Error_Handler.Write_Debug('['||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'] '|| p_msg);
  -- END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Write_Debug;

 ----------------------------------------------------------
 -- Write to Concurrent Log                              --
 ----------------------------------------------------------

PROCEDURE Developer_Debug (p_msg  IN  VARCHAR2) IS
 l_err_msg VARCHAR2(240);
BEGIN

  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_FILE.put_line(which => FND_FILE.LOG
                     ,buff  => 'EGO_ITEM_BULKLOAD_PKG: '||p_msg);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Developer_Debug;

PROCEDURE SetGobals IS
BEGIN
  -----------------------------------------------------------------------
  -- the values are chosen from the FND_GLOBALS
  -----------------------------------------------------------------------
  G_USER_ID    := NVL(FND_GLOBAL.user_id,-1);
  G_LOGIN_ID   := NVL(FND_GLOBAL.login_id,-1);
  G_PROG_APPID := NVL(FND_GLOBAL.prog_appl_id,-1);
  G_PROG_ID    := NVL(FND_GLOBAL.conc_program_id,-1);
  G_REQUEST_ID := NVL(FND_GLOBAL.conc_request_id,-1);
END;

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

    G_ERROR_FILE_NAME := G_ERROR_TABLE_NAME||'_'||to_char(SYSDATE, 'DDMONYYYY_HH24MISS')||'.err';
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

    IF (l_log_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       developer_debug('Unable to open error log file. Error => '||l_errbuff);
    END IF;

  END IF;--IF c_get_utl_file_dir%FOUND THEN
  -- Bug : 4099546
  CLOSE c_get_utl_file_dir;
END open_debug_session_internal;


 -----------------------------------------------------------
 -- Open the Debug Session, conditionally if the profile: --
 -- INV Debug Trace is set to TRUE                        --
 -----------------------------------------------------------
PROCEDURE Open_Debug_Session IS

BEGIN
  ----------------------------------------------------------------
  -- Open the Debug Log Session, only if Profile is set to TRUE --
  ----------------------------------------------------------------
  IF (G_DEBUG = 1) THEN

   ----------------------------------------------------------------------------------
   -- Opens Error_Handler debug session, only if Debug session is not already open.
   -- Suggested by RFAROOK, so that multiple debug sessions are not open PER
   -- Concurrent Request.
   ----------------------------------------------------------------------------------
   IF (Error_Handler.Get_Debug <> 'Y') THEN
     Open_Debug_Session_Internal;
   END IF;

  END IF;

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

PROCEDURE delete_records_from_MSII (p_set_process_id  IN NUMBER) IS

  TYPE char_tbl_type IS TABLE OF VARCHAR2(240);

  l_dyn_sql              VARCHAR2(32767) := '';
  l_column_name     char_tbl_type;
  l_rows_processed  NUMBER;
  l_column_list         VARCHAR2(32767) := '';

BEGIN
   -----------------------------------------------------------------------
   --Only in case of Import, and while importing Multi-Row attr group
   --values : Item, Org, Catalog are NOT NULL, and rest of the base
   --attributes are NULL. Hence can delete these rows off from MSII.
   -----------------------------------------------------------------------

   SELECT COLUMN_NAME
   BULK COLLECT INTO l_column_name
   FROM SYS.ALL_TAB_COLUMNS WHERE TABLE_NAME = 'MTL_SYSTEM_ITEMS_INTERFACE'
   AND COLUMN_NAME NOT IN ('SET_PROCESS_ID',
                           'TRANSACTION_ID',
                           'REQUEST_ID',
                           'PROGRAM_APPLICATION_ID',
                           'PROGRAM_ID',
                           'TRANSACTION_TYPE',
                           'ITEM_NUMBER',
                           'ORGANIZATION_CODE',
                           'PROCESS_FLAG',
                           'SOURCE_SYSTEM_ID',
                           'SOURCE_SYSTEM_REFERENCE',
                           'ITEM_CATALOG_GROUP_ID',
                           'INTERFACE_TABLE_UNIQUE_ID',
                           'INVENTORY_ITEM_ID',
                           'ORGANIZATION_ID',
                           'LAST_UPDATE_DATE',
                           'LAST_UPDATED_BY',
                           'CREATION_DATE',
                           'CREATED_BY',
                           'LAST_UPDATE_LOGIN')
   AND COLUMN_NAME NOT LIKE 'SEGMENT%'
   AND COLUMN_NAME NOT LIKE 'GLOBAL_ATTRIBUTE%'
   AND COLUMN_NAME NOT LIKE 'ATTRIBUTE%';

   l_rows_processed := SQL%ROWCOUNT;

   IF l_rows_processed > 0 THEN
     FOR l_row_index IN 1..l_rows_processed LOOP
       l_column_list := l_column_list || l_column_name(l_row_index) || ' IS NULL AND ';
     END LOOP;
     l_column_list := SUBSTR(l_column_list,1,length(l_column_list)-4);
   END IF;

   l_dyn_sql := '';
   l_dyn_sql := l_dyn_sql || ' DELETE MTL_SYSTEM_ITEMS_INTERFACE MSII ' ;
   l_dyn_sql := l_dyn_sql || ' WHERE ';
   l_dyn_sql := l_dyn_sql || ' ( ';
   l_dyn_sql := l_dyn_sql ||    ' (ITEM_NUMBER IS NOT NULL AND ORGANIZATION_CODE     IS NOT NULL ) ';
   l_dyn_sql := l_dyn_sql ||    ' OR ';
   l_dyn_sql := l_dyn_sql ||    ' ( SOURCE_SYSTEM_REFERENCE  IS NOT NULL AND SOURCE_SYSTEM_ID IS NOT NULL ) ';  --for non-PDH Batch
   l_dyn_sql := l_dyn_sql ||    ' OR ';
   l_dyn_sql := l_dyn_sql ||    ' (DESCRIPTION IS NULL AND SOURCE_SYSTEM_REFERENCE IS NULL AND SOURCE_SYSTEM_REFERENCE_DESC IS NULL ) ';
   l_dyn_sql := l_dyn_sql || ' ) ';
   l_dyn_sql := l_dyn_sql || ' AND ';
   l_dyn_sql := l_dyn_sql || ' ( ' ||  l_column_list  || ' ) ';
   l_dyn_sql := l_dyn_sql || ' AND SET_PROCESS_ID = :SET_PROCESS_ID_1 ';

   ------------------------------------------------------------------------------------------------
   -- Fix for 11.5.10: Including PROCESS_FLAG status during this DELETE operation.
   --
   -- When ERROR happens during PRIMARY_UOM_CODE processing (NOTE: This is the first
   -- significant Value-to-ID conversion) then MSII.PROCESS_FLAG is set to something
   -- other than 1. Because of this, the subsequent transfer of the Data from EBI to MSII
   -- doesnot happen (as all SQLs check for EBI, MSII Process St atus to be 1 for transfer).
   -- So, this DELETE will go through successfully, as all the columns are NULL (other than
   -- ITEM_NUMBER, ORGANIZATION_CODE.)
   -- Then EBI stays in PROCESS_STATUS = 1, which is later converted to 7 in Item_intf_completion.
   --
   -- Because of this User-Defined attrs for those rows are ERRONEOUSLY picked and processed.
   ------------------------------------------------------------------------------------------------
   l_dyn_sql := l_dyn_sql || ' AND PROCESS_FLAG = :PROCESS_STATUS_1 '; --Bug 3763665
   l_dyn_sql := l_dyn_sql || ' AND ( ';
   l_dyn_sql := l_dyn_sql || '  EXISTS ( ';   -- there exists a row where item is being Created or updated in the same request
   l_dyn_sql := l_dyn_sql ||    ' SELECT ''X'' ';
   l_dyn_sql := l_dyn_sql ||    ' FROM MTL_SYSTEM_ITEMS_INTERFACE MSI ';
   l_dyn_sql := l_dyn_sql ||    ' WHERE MSI.DESCRIPTION IS NOT NULL ';
   l_dyn_sql := l_dyn_sql ||    ' AND ((MSI.ITEM_NUMBER IS NULL AND MSII.ITEM_NUMBER IS NULL) OR (MSI.ITEM_NUMBER = MSII.ITEM_NUMBER))';
   l_dyn_sql := l_dyn_sql ||    ' AND SET_PROCESS_ID = :SET_PROCESS_ID_2 ';
   l_dyn_sql := l_dyn_sql ||    ' AND PROCESS_FLAG = :PROCESS_STATUS_2 ';
   l_dyn_sql := l_dyn_sql ||    ' ) ';
   l_dyn_sql := l_dyn_sql || ' OR EXISTS( ';
   l_dyn_sql := l_dyn_sql ||    ' SELECT ''X'' ';
   l_dyn_sql := l_dyn_sql ||    ' FROM MTL_SYSTEM_ITEMS_B MSI ';
   l_dyn_sql := l_dyn_sql ||    ' WHERE  MSII.INVENTORY_ITEM_ID  = MSI.INVENTORY_ITEM_ID ';
   l_dyn_sql := l_dyn_sql ||    ' AND MSII.ORGANIZATION_ID = MSI.ORGANIZATION_ID ';
   l_dyn_sql := l_dyn_sql ||    ' ) ';-- End Bug 3763665
   l_dyn_sql := l_dyn_sql || ' ) ';
   Write_Debug(' DELETE MSII sql: '||l_dyn_sql);
   IF (l_column_list IS NOT NULL) THEN
     EXECUTE IMMEDIATE l_dyn_sql USING p_set_process_id,G_PROCESS_STATUS,p_set_process_id,G_PROCESS_STATUS;
   END IF;
   Write_Debug('delete_records_from_MSII : NEW Deleted redundant / unnecessary rows from MSII');
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END delete_records_from_MSII;
 -----------------------------------------------------------------------
 -- Fix for Bug# 3970069.
 -- Insert into MTL_INTERFACE_ERRORS through autonomous transaction
 -- commit. Earlier for any exception during Java Conc Program's
 -- AM.commit(), the errors wouldnot get logged. By following Autonomous
 -- Transaction block, that issue gets resolved.
 -----------------------------------------------------------------------
 PROCEDURE Insert_Mtl_Intf_Err(  p_transaction_id       IN  VARCHAR2
                               , p_bo_identifier        IN  VARCHAR2
                               , p_error_entity_code    IN  VARCHAR2
                               , p_error_table_name     IN  VARCHAR2
                               , p_error_msg            IN  VARCHAR2
                               ) IS

 PRAGMA AUTONOMOUS_TRANSACTION;

 BEGIN
   SetGobals();

   INSERT INTO MTL_INTERFACE_ERRORS
   ( ORGANIZATION_ID
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
     , BO_IDENTIFIER)
   VALUES
   ( NULL
     , NULL
     , SYSDATE
     , G_USER_ID
     , SYSDATE
     , G_USER_ID
     , G_LOGIN_ID
     , p_error_table_name
     , NULL
     , NULL
     , G_REQUEST_ID
     , G_PROG_APPID
     , G_PROG_ID
     , SYSDATE
     , p_error_msg
     , p_transaction_id
     , p_error_entity_code
     , p_bo_identifier
   );

   COMMIT;

 END Insert_Mtl_Intf_Err;

 -----------------------------------------------------------------------
 -- Fix for Bug# 3945885.
 -- Generate Seq Item Numbers, for all Rows per ResultFmt_Usage_ID
 -- where Item Number column are NULL.
 -----------------------------------------------------------------------
 PROCEDURE Log_ItemNums_ToBe_Processed(p_resultfmt_usage_id  IN  NUMBER,
                                       p_item_num_colname    IN  VARCHAR2) IS

   l_item_num_sql    VARCHAR2(10000) :=
      ' SELECT '|| p_item_num_colname
   || ' FROM   EGO_BULKLOAD_INTF '
   || ' WHERE  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
   --|| '  AND   PROCESS_STATUS = 1';

   -----------------------------------------------------------------------
   -- Variables used to query Item Number Generation Method
   -----------------------------------------------------------------------
   l_item_num_table                 DBMS_SQL.VARCHAR2_TABLE;
   l_item_num_cursor                INTEGER;
   l_item_num_exec                  INTEGER;
   l_item_num_rows_cnt              NUMBER;

   l_msg                            fnd_new_messages.message_text%TYPE;
   -----------------------------------------------------------------------

 BEGIN

   l_item_num_cursor := DBMS_SQL.OPEN_CURSOR;
   --Developer_Debug('l_item_num_sql => '||l_item_num_sql);

   DBMS_SQL.PARSE(l_item_num_cursor, l_item_num_sql, DBMS_SQL.NATIVE);

   DBMS_SQL.DEFINE_ARRAY(
                        c           => l_item_num_cursor  -- cursor --
                      , position    => 1                  -- select position --
                      , c_tab       => l_item_num_table   -- table of chars --
                      , cnt         => 10000              -- rows requested --
                      , lower_bound => 1                  -- start at --
                       );

   DBMS_SQL.BIND_VARIABLE(l_item_num_cursor, ':RESULTFMT_USAGE_ID', p_resultfmt_usage_id);

   l_item_num_exec := DBMS_SQL.EXECUTE(l_item_num_cursor);
   l_item_num_rows_cnt := DBMS_SQL.FETCH_ROWS(l_item_num_cursor);

   DBMS_SQL.COLUMN_VALUE(l_item_num_cursor, 1, l_item_num_table);
   -- Bug : 4099546
   DBMS_SQL.CLOSE_CURSOR(l_item_num_cursor);
   FND_MESSAGE.SET_NAME('EGO','EGO_NUM_OF_ITEMS_PROCD');
   l_msg := FND_MESSAGE.GET;

   Developer_Debug(l_msg||' '||To_char(l_item_num_rows_cnt));

   FND_MESSAGE.SET_NAME('EGO','EGO_ROW');
   l_msg := FND_MESSAGE.GET;

   IF (l_item_num_rows_cnt > 0) THEN
     FOR i IN 1..l_item_num_rows_cnt LOOP
       Developer_Debug(l_msg||' ['||i||'] = '||l_item_num_table(i));
     END LOOP; --end: FOR i IN 1..l_item_num_rows_cnt LOOP
   END IF; --end: IF (l_item_num_rows_cnt > 0) THEN

 END Log_ItemNums_ToBe_Processed;

-- 5653266 commenting out the code
-- this procedure must be shifted to fag end of item_open_interface_process
-- in the package EGO_ITEM_OPEN_INTERFACE_PVT and the logging to be changed
-- to concurrent log and message must have tokens for item number and org
-- discuss with PM before implenenting the above change
/***
 -----------------------------------------------------------------------
 -- API FOR BUG 4101754                                               --
 -- THIS API WOULD LOG A MESSAGE IN FOR EVERY SUCCESSFUL ITEM         --
 -- CREATED                                                           --
 -----------------------------------------------------------------------
 PROCEDURE Log_created_Items (REQUEST_ID IN NUMBER)
 IS
   l_item_num_sql                   VARCHAR2(10000);
   l_item_num_table                 DBMS_SQL.VARCHAR2_TABLE;
   l_transaction_id_table           DBMS_SQL.NUMBER_TABLE;
   l_item_num_cursor                INTEGER;
   l_item_num_exec                  INTEGER;
   l_item_num_rows_cnt              NUMBER;
   l_msg                            fnd_new_messages.message_text%TYPE;
   l_token_tbl                      Error_Handler.Token_Tbl_Type;

 BEGIN

   l_item_num_sql :=
      ' SELECT SEGMENT1 , TRANSACTION_ID '
   || '   FROM MTL_SYSTEM_ITEMS_INTERFACE '
   || '  WHERE REQUEST_ID = '||REQUEST_ID
   || '    AND PROCESS_FLAG = '||G_INTF_STATUS_SUCCESS
   || '    AND TRANSACTION_TYPE = '''||G_CREATE||'''';

   l_item_num_cursor := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(l_item_num_cursor, l_item_num_sql, DBMS_SQL.NATIVE);
   DBMS_SQL.DEFINE_ARRAY(
                        c           => l_item_num_cursor
                      , position    => 1
                      , c_tab       => l_item_num_table
                      , cnt         => 10000
                      , lower_bound => 1
                       );

   DBMS_SQL.DEFINE_ARRAY(
                        c           => l_item_num_cursor
                      , position    => 2
                      , n_tab       => l_transaction_id_table
                      , cnt         => 10000
                      , lower_bound => 1
                       );

   l_item_num_exec := DBMS_SQL.EXECUTE(l_item_num_cursor);
   l_item_num_rows_cnt := DBMS_SQL.FETCH_ROWS(l_item_num_cursor);
   DBMS_SQL.COLUMN_VALUE(l_item_num_cursor, 1, l_item_num_table);
   DBMS_SQL.COLUMN_VALUE(l_item_num_cursor, 2, l_transaction_id_table);
   DBMS_SQL.CLOSE_CURSOR(l_item_num_cursor);
   IF (l_item_num_rows_cnt > 0) THEN
     FOR i IN 1..l_item_num_rows_cnt LOOP
       Developer_Debug(l_msg||' ['||i||'] = '||l_item_num_table(i));
       Error_Handler.Add_Error_Message
            ( p_message_name   => 'EGO_ITEM_CREATION_SUCC'
            , p_application_id => 'EGO'
            , p_message_text   => NULL
            , p_token_tbl      => l_token_tbl
            , p_message_type   => 'E'
            , p_row_identifier => l_transaction_id_table(i)
            , p_table_name     => 'MTL_SYSTEM_ITEMS_INTERFACE'
            , p_entity_id      => NULL
            , p_entity_index   => NULL
            , p_entity_code    => G_ERROR_ENTITY_CODE
            );
     END LOOP;
   END IF;

 END Log_created_Items;
***/

------------------------------------------------------------------------------
--  Fix for Bug# 3945885.
--
--  API Name:       Get_Seq_Gen_Item_Nums
--
--  Description:
--    API to return a Sequence of Item Numbers, given the ResultFmt_Usage_ID
--    and Item Catalog Group ID. Row count returned will be number of Rows per
--    ResultFmt_Usage_ID where Item Number column are NULL.
------------------------------------------------------------------------------
 PROCEDURE Get_Seq_Gen_Item_Nums(p_resultfmt_usage_id       IN  NUMBER,
                                 p_item_catalog_group_id    IN  NUMBER,
                                 p_item_num_colname         IN  VARCHAR2,
                                 x_item_num_tbl             IN OUT NOCOPY EGO_VARCHAR_TBL_TYPE) IS


   --------------------------------------------------------------------
   --Fetch the Org IDs in EBI, for which Item Number column is NULL
   --------------------------------------------------------------------
   l_org_id_sql    VARCHAR2(10000) :=
      ' SELECT '
   || ' INSTANCE_PK2_VALUE     '
   || ' FROM   EGO_BULKLOAD_INTF '
   || ' WHERE  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID'
   || '  AND   '|| p_item_num_colname ||' IS NULL '
   || '  AND   PROCESS_STATUS = 1';


   -----------------------------------------------------------------------
   -- Variables used to query Item Number Generation Method
   -----------------------------------------------------------------------
   l_org_id_table                 DBMS_SQL.VARCHAR2_TABLE;
   l_org_id_cursor                INTEGER;
   l_org_id_exec                  INTEGER;
   l_org_id_rows_cnt              NUMBER;

   l_item_num_tbl                 EGO_VARCHAR_TBL_TYPE;
   l_exists                       VARCHAR2(1);
   l_can_itemnum_gen              BOOLEAN;
   l_itemgen_rownum               NUMBER;
   l_new_itemgen_sql              VARCHAR2(1000);
   -----------------------------------------------------------------------

 BEGIN

   l_org_id_cursor := DBMS_SQL.OPEN_CURSOR;
   --Write_Debug('l_org_id_sql => '||l_org_id_sql);

   DBMS_SQL.PARSE(l_org_id_cursor, l_org_id_sql, DBMS_SQL.NATIVE);

   DBMS_SQL.DEFINE_ARRAY(
                        c           => l_org_id_cursor  -- cursor --
                      , position    => 1                -- select position --
                      , c_tab       => l_org_id_table   -- table of chars --
                      , cnt         => 10000            -- rows requested --
                      , lower_bound => 1                -- start at --
                       );

   DBMS_SQL.BIND_VARIABLE(l_org_id_cursor, ':RESULTFMT_USAGE_ID', p_resultfmt_usage_id);

   l_org_id_exec := DBMS_SQL.EXECUTE(l_org_id_cursor);
   l_org_id_rows_cnt := DBMS_SQL.FETCH_ROWS(l_org_id_cursor);

   DBMS_SQL.COLUMN_VALUE(l_org_id_cursor, 1, l_org_id_table);

   Write_Debug('Number of rows where ITEM_NUMBER is NULL => '||To_char(l_org_id_rows_cnt));

   IF (l_org_id_rows_cnt > 0) THEN

     EGO_ITEM_PVT.Get_Seq_Gen_Item_Nums
                         (
                           p_item_catalog_group_id  => p_item_catalog_group_id
                          ,p_org_id_tbl             => l_org_id_table
                          ,x_item_num_tbl           => x_item_num_tbl
                          );
   ELSE
     x_item_num_tbl := NULL;
   END IF; --end: IF (l_org_id_rows_cnt > 0) THEN
   --  Bug : 4099546
   DBMS_SQL.CLOSE_CURSOR(l_org_id_cursor);
 END Get_Seq_Gen_Item_Nums;


 ---------------------------------------------------------------------------
 -- To return the Display value of Attribute, given the Attribute Code.   --
 ---------------------------------------------------------------------------
FUNCTION  get_attr_display_name
          (
             p_attribute_code    IN  EGO_RESULTS_FORMAT_COLUMNS_V.ATTRIBUTE_CODE%TYPE
          )
          RETURN VARCHAR2 IS

  l_attr_group_id   NUMBER;
  l_attr_id         NUMBER;
  l_temp_str        VARCHAR2(30); --R12C UOM Changes
  l_attr_group_disp_name   EGO_ATTR_GROUPS_V.ATTR_GROUP_DISP_NAME%TYPE;
  l_attr_disp_name         EGO_ATTRS_V.ATTR_DISPLAY_NAME%TYPE;

   CURSOR c_attr_group_disp_name(p_attr_group_id  IN NUMBER) IS
     SELECT  attr_group_disp_name
     FROM    ego_attr_groups_v
     WHERE   attr_group_id = p_attr_group_id;

   CURSOR c_attr_disp_name(p_attr_id  IN NUMBER) IS
     SELECT  attr_display_name
     FROM    ego_attrs_v
     WHERE   attr_id = p_attr_id;

BEGIN

   l_attr_group_id := To_Number(SUBSTR(p_attribute_code, 1, INSTR(p_attribute_code, '$$') - 1));
      l_temp_str := SUBSTR(p_attribute_code, INSTR(p_attribute_code, '$$')+2);

   IF (INSTR(l_temp_str, '$$UOM') > 0) THEN
        l_temp_str:= SUBSTR(l_temp_str, 1, INSTR(l_temp_str, '$$')-1); --R12C UOM Changes
   END IF;

   l_attr_id := To_Number(l_temp_str);

    OPEN c_attr_group_disp_name(l_attr_group_id);
    FETCH c_attr_group_disp_name INTO l_attr_group_disp_name;
    IF c_attr_group_disp_name%NOTFOUND THEN
      l_attr_group_disp_name := NULL;
    END IF;
    CLOSE c_attr_group_disp_name;

    OPEN c_attr_disp_name(l_attr_id);
    FETCH c_attr_disp_name INTO l_attr_disp_name;
    IF c_attr_disp_name%NOTFOUND THEN
      l_attr_disp_name := NULL;
    END IF;
    CLOSE c_attr_disp_name;

    IF (l_attr_group_disp_name IS NULL OR
        l_attr_disp_name IS NULL) THEN
       RETURN NULL;
     ELSE
       RETURN l_attr_group_disp_name||'.'||l_attr_disp_name;
    END IF;

END;


 -------------------------------------------------------------
 -- Delete all the earlier loads from the same spreadsheet. --
 -------------------------------------------------------------

PROCEDURE setup_buffer_intf_table(
          p_resultfmt_usage_id IN NUMBER
          ) IS

  --------------------------------------------
  -- Long Dynamic SQL String
  --------------------------------------------
  l_dyn_sql                VARCHAR2(10000);

BEGIN

   --Delete all the earlier loads from the same spreadsheet.
   DELETE EGO_BULKLOAD_INTF
     WHERE RESULTFMT_USAGE_ID = p_resultfmt_usage_id
     AND   PROCESS_STATUS <> 1;


   Write_Debug('Setting up the Error Debug File, so that Java Conc Program can use it.');
   ---------------------------------------------------------------
   -- Introduced for 11.5.10, so that Java Conc Program can     --
   -- continue writing to the same Error Log File.              --
   ---------------------------------------------------------------
   l_dyn_sql :=              ' UPDATE EGO_BULKLOAD_INTF EBI';
   l_dyn_sql := l_dyn_sql || '  SET '||G_ERR_LOGFILE_COL ||' = ''' || G_ERRFILE_PATH_AND_NAME ||'''';
   l_dyn_sql := l_dyn_sql || ' WHERE  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
   l_dyn_sql := l_dyn_sql || ' AND   PROCESS_STATUS = 1                     ';
     --------------------------------------------------------------
     -- Updates only 1 row that matches the criterion, for       --
     -- performance reasons.                                     --
     --------------------------------------------------------------
   l_dyn_sql := l_dyn_sql || ' AND    ROWNUM < 2                            ';


   Write_Debug(l_dyn_sql);

   EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;

END setup_buffer_intf_table;


 -------------------------------------------------------------
 -- Sets if the Batch that is being processed in PDH or Not --
 -------------------------------------------------------------

PROCEDURE setup_batch_info  IS
  l_source_system_id          NUMBER;
BEGIN

   Write_Debug('Setting up the batch info for : ' || G_MSII_SET_PROCESS_ID);

   ---------------------------------------------------------------
   -- Introduced for R12, so that the rest of the api call can  --
   -- set the process status/flag accordingly.                  --
   ---------------------------------------------------------------
    SELECT source_system_id into l_source_system_id
    FROM EGO_IMPORT_BATCHES_B
    WHERE batch_id = G_MSII_SET_PROCESS_ID;

   IF l_source_system_id = EGO_IMPORT_PVT.Get_PDH_Source_System_Id  THEN
     G_PDH_BATCH := TRUE;
     G_PROCESS_STATUS := 1;
   ELSE
     G_PDH_BATCH := FALSE;
     G_PROCESS_STATUS := 0;
   END IF;

   Write_Debug('Setting process status to ' || G_PROCESS_STATUS);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     G_PDH_BATCH := TRUE;
     G_PROCESS_STATUS := 1;

END setup_batch_info;


-- Bug: 3778006
-------------------------------------------------------------------------
-- Function to get description generation method  for catalog category --
-------------------------------------------------------------------------
FUNCTION get_desc_gen_method(p_catalog_group_id NUMBER) RETURN VARCHAR2
IS
  CURSOR c_cat_grp(c_catalog_group_id NUMBER) IS
    SELECT ITEM_DESC_GEN_METHOD, ITEM_CATALOG_GROUP_ID, LEVEL
    FROM MTL_ITEM_CATALOG_GROUPS_B
    WHERE LEVEL > 1
    CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID
    START WITH ITEM_CATALOG_GROUP_ID = c_catalog_group_id
    ORDER BY LEVEL;

  l_desc_gen_method  VARCHAR2(10) := 'U';
BEGIN
  IF p_catalog_group_id IS NOT NULL THEN
    -----------------------------------------------------------------------
    -- Get the description generation method for catalog category itself --
    -----------------------------------------------------------------------
    SELECT ITEM_DESC_GEN_METHOD into l_desc_gen_method
    FROM MTL_ITEM_CATALOG_GROUPS_B
    WHERE ITEM_CATALOG_GROUP_ID = p_catalog_group_id;

    ------------------------------------------------------------------------
    -- If the generation method is I i.e. inherit from parent, then check --
    -- parents till we get something other than I                         --
    ------------------------------------------------------------------------
    IF NVL(l_desc_gen_method, 'U') = 'I' THEN
      FOR i IN c_cat_grp(p_catalog_group_id) LOOP
        l_desc_gen_method := i.ITEM_DESC_GEN_METHOD;
        IF NVL(l_desc_gen_method, 'U') <> 'I' THEN
          EXIT;
        END IF;
      END LOOP;
    END IF;

    ------------------------------------------------------------------------
    -- If the generation method is I even for the topmost parent, then    --
    -- treat it as U (user entered)                                       --
    ------------------------------------------------------------------------
    IF  NVL(l_desc_gen_method, 'U') = 'I' THEN
      l_desc_gen_method := 'U';
    END IF;

  END IF; -- end if p_catalog_group_id is not null

  RETURN l_desc_gen_method;

EXCEPTION WHEN OTHERS THEN
  RETURN 'U';
END get_desc_gen_method;

 ----------------------------------------------------------
 --  Populate Item Interface Lines                       --
 ----------------------------------------------------------

PROCEDURE load_item_interface
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_caller_identifier     IN         VARCHAR2 DEFAULT EGO_ITEM_BULKLOAD_PKG.G_ITEM,
                 p_set_process_id        IN         NUMBER,
                 x_set_process_id        OUT NOCOPY NUMBER,
                 x_errbuff               OUT NOCOPY VARCHAR2,
                 x_retcode               OUT NOCOPY VARCHAR2
                ) IS

    -- Start OF comments
    -- API name  : Populate MSII Item Interface Lines
    -- TYPE      : Public (called by Concurrent Program Wrapper API)
    -- Pre-reqs  : None
    -- FUNCTION  : Populate and Load Item interfance lines in MSII
    --


  ---------------------------------------------------------------
  -- To get the Item Base attr columns in the Result Format.
  ---------------------------------------------------------------
  CURSOR c_item_base_attr_intf_cols (c_resultfmt_usage_id  IN  NUMBER) IS
    SELECT attribute_code, intf_column_name
    FROM   ego_results_fmt_usages
    WHERE  resultfmt_usage_id = c_resultfmt_usage_id
     AND attribute_code NOT LIKE '%$$%'
     AND attribute_code <> 'APPROVAL_STATUS' -- bug: 3433942
     AND attribute_code <> 'MASTER_ORGANIZATION_ID' -- bug: 8347241
     AND attribute_code NOT IN ('SUPPLIER_NAME','SUPPLIER_SITE','SUPPLIER_PRIMARY','SUPPLIER_STATUS','SUPPLIERSITE_STATUS'
                                ,'SUPPLIERSITE_PRIMARY','SUPPLIERSITE_STORE_STATUS','SUPPLIER_NUMBER')
     AND attribute_code NOT IN --Segregating Item Base Attributes using this clause
     (
        select LOOKUP_CODE CODE
        from   FND_LOOKUP_VALUES
        where  LOOKUP_TYPE = 'EGO_ITEM_REV_HDR_ATTR_GRP'
        AND    LANGUAGE = USERENV('LANG')
        AND    ENABLED_FLAG = 'Y'
     )
     AND attribute_code <> G_REV_EFF_DATE_ATTR_CODE --Bug 6139409
     ORDER BY intf_column_name;-- Bug: 3340808

  --------------------------------------------------------------------------
  -- To check if the given attribute code is a valid BOM Component Column.
  --------------------------------------------------------------------------
   CURSOR c_bom_comp_col_exists(c_attribute_code  IN  VARCHAR2) IS
     SELECT 'x'
     FROM   bom_component_columns
     WHERE  attribute_code = c_attribute_code
      AND   parent_entity = 'ITEM';
      --  AND   whereclause IS NOT NULL;

  --------------------------------------------------------------------------
  -- To check if the given Set Process ID already exists in MSII.
  --------------------------------------------------------------------------
  CURSOR c_msii_set_id_exists(c_set_process_id IN NUMBER) IS
    SELECT 'x'
    FROM mtl_system_items_interface
    WHERE set_process_id = c_set_process_id;


  ---------------------------------------------------------------------
  -- Type Declarations
  ---------------------------------------------------------------------
  TYPE VARCHAR_TBL_TYPE IS TABLE OF VARCHAR2(256)
   INDEX BY BINARY_INTEGER;

               -------------------------
               --   local variables   --
               -------------------------
  l_prod_col_name_tbl         VARCHAR_TBL_TYPE;
  l_intf_col_name_tbl         VARCHAR_TBL_TYPE;

  l_prod_col_name             VARCHAR2(256);
  l_intf_col_name             VARCHAR2(256);

  ---------------------------------------------------------------------
  -- Assuming that the column name will not be more than 30 chars.
  ---------------------------------------------------------------------
  l_item_number_col        VARCHAR2(50);
  l_org_code_col           VARCHAR2(50);
  l_item_catalog_name_col  VARCHAR2(50);
  l_primary_uom_col        VARCHAR2(50);
  l_lifecycle_col          VARCHAR2(50);
  l_lifecycle_phase_col    VARCHAR2(50);
  l_user_item_type_col     VARCHAR2(50);
  l_bom_item_type_col      VARCHAR2(50);
  l_eng_item_flag_col      VARCHAR2(50);
  l_lifecycle_col_val        VARCHAR2(50);
  l_lifecycle_phase_col_val  VARCHAR2(50);
  --Bug: 3969593 Adding new 11.5.10 Primary Attrs: Begin
  l_conversions_col          VARCHAR2(50);
  l_secondary_def_col        VARCHAR2(50);
  l_dual_uom_dev_low_col     VARCHAR2(50);
  l_dual_uom_dev_high_col    VARCHAR2(50);
  l_ont_pricing_qty_src_col  VARCHAR2(50);
  l_secondary_uom_code_col   VARCHAR2(50);
  l_tracking_qty_ind_col     VARCHAR2(50);
  --Bug: 3969593 End

  l_catalog_group_id       VARCHAR2(50);
  l_inventory_item_id      MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE;

  l_msii_set_process_id    NUMBER;
  i                        NUMBER;
  l_cursor_select     INTEGER;
  l_cursor_execute    INTEGER;

  l_item_number_table   DBMS_SQL.VARCHAR2_TABLE;
  l_org_id_table        DBMS_SQL.NUMBER_TABLE;
  l_trans_type_table    DBMS_SQL.VARCHAR2_TABLE;
  l_trans_id_table      DBMS_SQL.NUMBER_TABLE;

  ---------------------------------------------------------------------
  -- This is to store the Sequence Generated Item Numbers.
  ---------------------------------------------------------------------
--  l_gen_item_num_tbl    EGO_VARCHAR_TBL_TYPE;
--  l_gen_itemnum_indx    NUMBER;

  l_temp                NUMBER(10) := 1;
  l_count               NUMBER := 0;
  l_exists              VARCHAR2(2);
  l_itemgen_count       NUMBER;

  l_value_to_id_col_exists BOOLEAN := FALSE;
  l_bom_col_exists      BOOLEAN := FALSE;
  l_bom_prod_col_name   VARCHAR2(50);

  --------------------------------------------
  -- Long Dynamic SQL String
  --------------------------------------------
  l_dyn_sql             VARCHAR2(10000);
  l_desc_gen_method     VARCHAR2(10) := 'U'; -- Bug: 3778006
  --Bug 4713312
  l_col_name            VARCHAR2(40);

BEGIN

   Write_Debug('About to populate the EBI with Trans IDs');
   --------------------------------------------------------------------
   --Populate the Transaction IDs for current Result fmt usage ID
   --------------------------------------------------------------------
   UPDATE ego_bulkload_intf
     --The Transaction ID sequence that is used in INVPOPIF package to
     --auto-populate Transaction ID in MSII.
     SET  transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
   WHERE  resultfmt_usage_id = p_resultfmt_usage_id;

   Write_Debug('Retrieving the Display and INTF cols');
   i := 0;
   --------------------------------------------------------------------
   -- Saving the column names in local table for easy retrieval later.
   -- Also save important columns such as Item ID, Org ID etc.,
   --------------------------------------------------------------------
   FOR c_item_base_attr_intf_rec IN c_item_base_attr_intf_cols
     (
       p_resultfmt_usage_id
      )
   LOOP

     l_prod_col_name := c_item_base_attr_intf_rec.attribute_code;
     l_intf_col_name := c_item_base_attr_intf_rec.intf_column_name;

     IF (p_caller_identifier = EGO_ITEM_BULKLOAD_PKG.G_BOM) THEN
      OPEN c_bom_comp_col_exists(l_prod_col_name);
      FETCH c_bom_comp_col_exists INTO l_exists;
       IF c_bom_comp_col_exists%FOUND THEN
          l_bom_col_exists := TRUE;
       ELSE
          l_bom_col_exists := FALSE;
       END IF;
       CLOSE c_bom_comp_col_exists;
     END IF;


     IF (l_bom_col_exists = TRUE) THEN
      Write_Debug('The column: ' || l_prod_col_name || ' and BOM_COL_EXISTS value IS TRUE');
     ELSE
      Write_Debug('The column: ' || l_prod_col_name || ' and BOM_COL_EXISTS value IS FALSE');
     END IF;

     Write_Debug('The caller identity is : '|| p_caller_identifier);

      --------------------------------------------------------------------
      -- If the Caller Identifer is G_BOM and the column exists in
      -- BOM_COMPONENT_COLUMNS then fetch the Correct prod column
      -- name from BOM_COMPONENT_COLUMNS.
      --------------------------------------------------------------------
     IF (p_caller_identifier = EGO_ITEM_BULKLOAD_PKG.G_BOM AND
         l_bom_col_exists = TRUE AND l_prod_col_name <> G_ITEM_NUMBER)
     THEN
       SELECT BOM_INTF_COLUMN_NAME INTO l_bom_prod_col_name
        FROM BOM_COMPONENT_COLUMNS
       WHERE Attribute_Code = l_prod_col_name AND Parent_Entity = 'ITEM';
       Write_Debug('The column value from BCC: ' || l_bom_prod_col_name);
       IF l_bom_prod_col_name IS NOT NULL THEN
         l_prod_col_name := l_bom_prod_col_name;
       END IF;
       Write_Debug('The column value after getting from BCC: ' || l_prod_col_name);
     END IF;

      --------------------------------------------------------------------
      -- If the Caller Identifer is G_ITEM, then save the column info.
      -- If the Caller Identifer is G_BOM, and the column exists in
      -- BOM_COMPONENT_COLUMNS, then save the column info.
      --------------------------------------------------------------------
     IF (
         (p_caller_identifier = EGO_ITEM_BULKLOAD_PKG.G_ITEM) OR
         (p_caller_identifier = EGO_ITEM_BULKLOAD_PKG.G_BOM AND
         l_bom_col_exists = TRUE
         )
        ) THEN
      --------------------------------------------------------------------
      --Store the Item Number column name in the Generic Interface
      --------------------------------------------------------------------
      IF (l_prod_col_name = G_ITEM_NUMBER) THEN
        l_item_number_col := l_intf_col_name;
        Write_Debug('Item Number : '||l_item_number_col);
      --------------------------------------------------------------------
      --Store the Organization Code column name in the Generic Interface
      --------------------------------------------------------------------
      ELSIF (l_prod_col_name = G_ORG_CODE) THEN
        l_org_code_col := l_intf_col_name;
        Write_Debug('Organization Code : '||l_org_code_col);
      ELSE
      --------------------------------------------------------------------
      --Saving the Rest of column names.
      --------------------------------------------------------------------
        IF (l_prod_col_name = G_ITEM_CATALOG_GROUP) THEN
          l_item_catalog_name_col := l_intf_col_name;
        ELSIF (l_prod_col_name = G_PRIMARY_UOM) THEN
          l_primary_uom_col := l_intf_col_name;
        ELSIF (l_prod_col_name = G_LIFECYCLE) THEN
          l_lifecycle_col := l_intf_col_name;
        ELSIF (l_prod_col_name = G_LIFECYCLE_PHASE) THEN
          l_lifecycle_phase_col := l_intf_col_name;
        ELSIF (l_prod_col_name = G_USER_ITEM_TYPE) THEN
          l_user_item_type_col := l_intf_col_name;
        ELSIF (l_prod_col_name = G_BOM_ITEM_TYPE) THEN
          l_bom_item_type_col := l_intf_col_name;
        ELSIF (l_prod_col_name = G_ENG_ITEM_FLAG) THEN
          l_eng_item_flag_col := l_intf_col_name;
        --Bug: 3969593 Adding new 11.5.10 Primary Attrs: Begin
        ELSIF (l_prod_col_name = G_CONVERSIONS) THEN
          l_conversions_col := l_intf_col_name;
        ELSIF (l_prod_col_name = G_SECONDARY_DEF_IND) THEN
          l_secondary_def_col := l_intf_col_name;
        ELSIF (l_prod_col_name = G_DUAL_UOM_DEV_LOW) THEN
          l_dual_uom_dev_low_col := l_intf_col_name;
        ELSIF (l_prod_col_name = G_DUAL_UOM_DEV_HIGH) THEN
          l_dual_uom_dev_high_col := l_intf_col_name;
        ELSIF (l_prod_col_name = G_ONT_PRICING_QTY_SRC) THEN
          l_ont_pricing_qty_src_col := l_intf_col_name;
        ELSIF (l_prod_col_name = G_SECONDARY_UOM_CODE) THEN
          l_secondary_uom_code_col := l_intf_col_name;
        ELSIF (l_prod_col_name = G_TRACKING_QTY_IND) THEN
          l_tracking_qty_ind_col := l_intf_col_name;
        --Bug: 3969593 End
        ELSIF (l_prod_col_name = G_INVENTORY_ITEM_STATUS) THEN-- required in error handler
          l_inventory_item_status_col := l_intf_col_name;
        ELSIF (l_prod_col_name = G_TRADE_ITEM_DESCRIPTOR) THEN
        -- R12C Pack Hierarchy Changes for Trade Item Descriptor --
          l_trade_item_descriptor_col := l_intf_col_name;
        END IF;

        -- R12 - to update GTIN and GTIN description in MTL_SYSTEM_ITEMS_INTERFACE table
        IF (l_prod_col_name = G_GTIN_NUM_ATTR_CODE) THEN
          l_prod_col_name_tbl(i) := G_GTIN_NUM_DB_COL;
        ELSIF (l_prod_col_name = G_GTIN_DESC_ATTR_CODE) THEN
          l_prod_col_name_tbl(i) := G_GTIN_DESC_DB_COL;
        ELSE
          l_prod_col_name_tbl(i) := l_prod_col_name;
        END IF;

        l_intf_col_name_tbl(i) := l_intf_col_name;

        Write_Debug('l_prod_col_name_tbl('||i||') : '||l_prod_col_name_tbl(i));
        Write_Debug('l_intf_col_name_tbl('||i||') : '||l_intf_col_name_tbl(i));
        i := i+1;
      END IF; --end: IF (l_prod_col_name = G_ITEM_NUMBER) THEN
    END IF; --end: IF (p_caller_identifier = EGO_ITEM_BULKLOAD_PKG.G_ITEM)...
   END LOOP;--end: FOR c_item_base_attr_intf_rec..


   l_value_to_id_col_exists := FALSE;

   -----------------------------------------------------------------------
   -- Save all Value-to-ID conversion columns in designated places in EBI.
   -----------------------------------------------------------------------
   l_dyn_sql :=              ' UPDATE EGO_BULKLOAD_INTF ';
   l_dyn_sql := l_dyn_sql || ' SET  ';
   IF l_item_catalog_name_col IS NOT NULL THEN
     l_dyn_sql := l_dyn_sql || G_ITEM_CATALOG_NAME_EBI_COL||' = '||l_item_catalog_name_col|| ' ,';
     l_value_to_id_col_exists := TRUE;
   END IF;
   IF l_primary_uom_col IS NOT NULL THEN
     l_dyn_sql := l_dyn_sql || G_PRIMARY_UOM_EBI_COL||' = '||l_primary_uom_col|| ' ,';
     l_value_to_id_col_exists := TRUE;
   END IF;
   IF l_lifecycle_col IS NOT NULL THEN
     l_dyn_sql := l_dyn_sql ||G_LIFECYCLE_EBI_COL||' = '||l_lifecycle_col|| ' ,';
     l_value_to_id_col_exists := TRUE;
   END IF;
   IF l_lifecycle_phase_col IS NOT NULL THEN
     l_dyn_sql := l_dyn_sql ||G_LIFECYCLE_PHASE_EBI_COL||' = '||l_lifecycle_phase_col|| ' ,';
     l_value_to_id_col_exists := TRUE;
   END IF;
   IF l_user_item_type_col IS NOT NULL THEN
     l_dyn_sql := l_dyn_sql ||G_USER_ITEM_TYPE_EBI_COL||' = '||l_user_item_type_col|| ' ,';
     l_value_to_id_col_exists := TRUE;
   END IF;
   IF l_bom_item_type_col IS NOT NULL THEN
     l_dyn_sql := l_dyn_sql ||G_BOM_ITEM_TYPE_EBI_COL||' = '||l_bom_item_type_col|| ' ,';
     l_value_to_id_col_exists := TRUE;
   END IF;
   IF l_eng_item_flag_col IS NOT NULL THEN
     l_dyn_sql := l_dyn_sql ||G_ENG_ITEM_FLAG_EBI_COL||' = '||l_eng_item_flag_col|| ' ,';
     l_value_to_id_col_exists := TRUE;
   END IF;
   --Bug: 3969593 Adding new 11.5.10 Primary Attrs: Begin
   IF l_conversions_col IS NOT NULL THEN
     l_dyn_sql := l_dyn_sql ||G_CONVERSIONS_EBI_COL||' = '||l_conversions_col|| ' ,';
     l_value_to_id_col_exists := TRUE;
   END IF;
   IF l_secondary_def_col IS NOT NULL THEN
     l_dyn_sql := l_dyn_sql ||G_SECONDARY_DEF_IND_EBI_COL||' = '||l_secondary_def_col|| ' ,';
     l_value_to_id_col_exists := TRUE;
   END IF;
   IF l_ont_pricing_qty_src_col IS NOT NULL THEN
     l_dyn_sql := l_dyn_sql ||G_ONT_PRICING_QTY_SRC_EBI_COL||' = '||l_ont_pricing_qty_src_col|| ' ,';
     l_value_to_id_col_exists := TRUE;
   END IF;
   IF l_secondary_uom_code_col IS NOT NULL THEN
     l_dyn_sql := l_dyn_sql ||G_SECONDARY_UOM_CODE_EBI_COL||' = '||l_secondary_uom_code_col|| ' ,';
     l_value_to_id_col_exists := TRUE;
   END IF;
   IF l_tracking_qty_ind_col IS NOT NULL THEN
     l_dyn_sql := l_dyn_sql ||G_TRACKING_QTY_IND_EBI_COL||' = '||l_tracking_qty_ind_col|| ' ,';
     l_value_to_id_col_exists := TRUE;
   END IF;
   --Bug: 3969593 End
   --------------------------------
   --Remove the comma at the end.
   --------------------------------
   l_dyn_sql := Substr(l_dyn_sql, 1, Length(l_dyn_sql)-1);
   l_dyn_sql := l_dyn_sql || ' WHERE RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
   l_dyn_sql := l_dyn_sql || ' AND   PROCESS_STATUS = 1  ';
   Write_Debug(l_dyn_sql);

   IF l_value_to_id_col_exists = TRUE THEN
     EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
     Write_Debug('Updated EBI with Value-to-ID Conversion Cols');
   END IF;

   Write_Debug('Updating EBI with Org IDs');
   -----------------------------------------------------
   -- Update Instance PK2 Value with ORG ID.
   -----------------------------------------------------
   l_dyn_sql :=              'UPDATE EGO_BULKLOAD_INTF EBI';
   l_dyn_sql := l_dyn_sql || '  SET INSTANCE_PK2_VALUE = ';
   l_dyn_sql := l_dyn_sql || '  (                                           ';
   l_dyn_sql := l_dyn_sql || '    SELECT ORGANIZATION_ID                    ';
   l_dyn_sql := l_dyn_sql || '    FROM   MTL_PARAMETERS                     ';
   l_dyn_sql := l_dyn_sql || '    WHERE  ORGANIZATION_CODE =EBI.'||l_org_code_col;
   l_dyn_sql := l_dyn_sql || '  )                                           ';
   l_dyn_sql := l_dyn_sql || 'WHERE  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
   l_dyn_sql := l_dyn_sql || ' AND   PROCESS_STATUS = 1                     ';

   Write_Debug(l_dyn_sql);

   EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
   --------------------------------------------------------------------
   -- Fix for Bug# 3945885.
   -- Fetch Item Numbers for rows where Item Number is NULL
   --------------------------------------------------------------------
-- commenting as a part of 6118945
--
--   IF(G_PDH_BATCH) THEN
--   Get_Seq_Gen_Item_Nums(
--          p_resultfmt_usage_id     => p_resultfmt_usage_id
--         ,p_item_catalog_group_id  => G_CATALOG_GROUP_ID
--         ,p_item_num_colname       => l_item_number_col
--         ,x_item_num_tbl           => l_gen_item_num_tbl
--         );
--   END IF;
--
--   IF (l_gen_item_num_tbl IS NULL) THEN
--     Write_Debug('Item Number *could not* be Generated !!!');
--   ELSE
----     Write_Debug('Item Numbers *were* be Generated !!! Count => '||l_gen_item_num_tbl.LAST);
--     Write_Debug('Item Numbers *were* be Generated !!! Count => '||l_gen_item_num_tbl.COUNT);
--     --FOR i IN 1..l_gen_item_num_tbl.LAST LOOP
--     --  Write_Debug('Item Number ['||i||'] => '||l_gen_item_num_tbl(i));
--     --END LOOP;
--   END IF;
--
--   Write_Debug('Selecting Org IDs, Item Numbers');
--
   -------------------------------------------------------------
   --Fetch Organization ID, Item Number in Temp PLSQL tables.
   -------------------------------------------------------------
    l_dyn_sql :=              'SELECT ';
    l_dyn_sql := l_dyn_sql || ' INSTANCE_PK2_VALUE       , ';
    l_dyn_sql := l_dyn_sql || l_item_number_col ||'      , ';
      ----------------------------------------------------------------------
      -- Upcasing the Transaction Type, for fixing Trans Type related bugs
      ----------------------------------------------------------------------
    l_dyn_sql := l_dyn_sql || ' UPPER(TRANSACTION_TYPE)  , ';
    l_dyn_sql := l_dyn_sql || ' TRANSACTION_ID           ';
    l_dyn_sql := l_dyn_sql || ' FROM EGO_BULKLOAD_INTF ';
    l_dyn_sql := l_dyn_sql || ' WHERE RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
    l_dyn_sql := l_dyn_sql || ' AND PROCESS_STATUS = 1';
--    l_dyn_sql := l_dyn_sql || '  AND '|| l_item_number_col ||' IS NOT NULL';

    Write_Debug(l_dyn_sql);

    l_cursor_select := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_cursor_select, l_dyn_sql, DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 1,l_org_id_table,2500, l_temp);
    DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 2,l_item_number_table,2500, l_temp);
    DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 3,l_trans_type_table,2500, l_temp);
    DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 4,l_trans_id_table,2500, l_temp);

    DBMS_SQL.BIND_VARIABLE(l_cursor_select,':RESULTFMT_USAGE_ID', p_resultfmt_usage_id);
    l_cursor_execute := DBMS_SQL.EXECUTE(l_cursor_select);
    Write_Debug('About to start the Loop to fetch Rows');

    -------------------------------------------------------------
    -- Separate Index to keep track of Generated Item Numbers.
    -------------------------------------------------------------
-- commenting as a part of 6118945
--    IF (l_gen_item_num_tbl IS NOT NULL AND
--        l_gen_item_num_tbl.LAST > 0
--        ) THEN
--      l_gen_itemnum_indx := l_gen_item_num_tbl.FIRST;
--    END IF;

    LOOP
      l_count := DBMS_SQL.FETCH_ROWS(l_cursor_select);
      DBMS_SQL.COLUMN_VALUE(l_cursor_select, 1, l_org_id_table);
      DBMS_SQL.COLUMN_VALUE(l_cursor_select, 2, l_item_number_table);
      DBMS_SQL.COLUMN_VALUE(l_cursor_select, 3, l_trans_type_table);
      DBMS_SQL.COLUMN_VALUE(l_cursor_select, 4, l_trans_id_table);

      Write_Debug('Retrieved rows => '||To_char(l_count));

      -------------------------------------------------------------
      -- Loop to Update the Inventory Item IDs.
      -------------------------------------------------------------
      FOR i IN l_temp..l_org_id_table.COUNT LOOP --Bug: 4211498 Modified initialize cnter

        Write_Debug('Org ID : '||To_char(l_org_id_table(i)));
        Write_Debug('Inv Item Num : '||l_item_number_table(i));
        Write_Debug('Transaction Type : '||l_trans_type_table(i));
        l_temp := l_org_id_table.COUNT; --Bug:4211498
        -------------------------------------------------------------
        -- If Inventory Item ID found, then update in EBI.
        -------------------------------------------------------------
        IF FND_FLEX_KEYVAL.Validate_Segs
        (  operation         =>  'FIND_COMBINATION'
        ,  appl_short_name   =>  'INV'
        ,  key_flex_code     =>  'MSTK'
        ,  structure_number  =>  101
        ,  concat_segments   =>  l_item_number_table(i)
        ,  data_set          =>  l_org_id_table(i)
        )
        THEN
          l_inventory_item_id := FND_FLEX_KEYVAL.combination_id;

          Write_Debug('Inv Item ID : '||To_char(l_inventory_item_id));

          l_dyn_sql :=              ' UPDATE EGO_BULKLOAD_INTF ';
          l_dyn_sql := l_dyn_sql || ' SET INSTANCE_PK1_VALUE  = '||l_inventory_item_id;
          l_dyn_sql := l_dyn_sql || ' WHERE INSTANCE_PK2_VALUE = '||l_org_id_table(i);
          l_dyn_sql := l_dyn_sql || ' AND '|| l_item_number_col|| ' = :ITEM_NUMBER';
          l_dyn_sql := l_dyn_sql || ' AND RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
          l_dyn_sql := l_dyn_sql || ' AND PROCESS_STATUS = 1  ';

          Write_Debug(l_dyn_sql);
          EXECUTE IMMEDIATE l_dyn_sql USING l_item_number_table(i), p_resultfmt_usage_id;
        END IF;


          --l_inventory_item_id := FND_FLEX_KEYVAL.combination_id;

          -------------------------------------------------------------
          --Determining if Item Creation.
          -------------------------------------------------------------
          /**IF (
             (l_trans_type_table(i) = G_CREATE) OR
             (l_trans_type_table(i) = G_SYNC)
             ) THEN**/

            Write_Debug('G_CATALOG_GROUP_ID => '||G_CATALOG_GROUP_ID);
            -----------------------------------------------------------------
            -- Setting Category ID in case where User enters the Catalog Name
            -- from Excel
            -- Bug #4652582(RSOUNDAR)
            -----------------------------------------------------------------
            IF G_CATALOG_GROUP_ID IS NULL THEN
              IF l_item_catalog_name_col IS NOT NULL THEN
                l_dyn_sql :=              ' UPDATE EGO_BULKLOAD_INTF EBI';
                l_dyn_sql := l_dyn_sql || ' SET '||G_ITEM_CATALOG_EBI_COL||' = ';
                l_dyn_sql := l_dyn_sql || '( ';
                l_dyn_sql := l_dyn_sql || '    SELECT TO_CHAR(MICG.ITEM_CATALOG_GROUP_ID) ';
                l_dyn_sql := l_dyn_sql || '    FROM   MTL_ITEM_CATALOG_GROUPS_B_KFV MICG  ';
                l_dyn_sql := l_dyn_sql || '    WHERE  MICG.CONCATENATED_SEGMENTS = EBI.'||l_item_catalog_name_col;
                l_dyn_sql := l_dyn_sql || ') ';
                l_dyn_sql := l_dyn_sql || ' WHERE EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
                l_dyn_sql := l_dyn_sql || ' AND EBI.'||l_item_catalog_name_col||' IS NOT NULL';
                l_dyn_sql := l_dyn_sql || ' AND EBI.PROCESS_STATUS = 1  ';
                Write_Debug(l_dyn_sql);
                EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
              ELSE -- l_item_catalog_name_col IS NULL
                -- no need to do anything here
                NULL;
              END IF; -- l_item_catalog_name_col IS NOT NULL
            ELSE  -- G_CATALOG_GROUP_ID IS NOT NULL
/*            Since Item Number can be NULL, removing its reference from the WHERE Clause.

              l_dyn_sql := '';
              l_dyn_sql :=              ' UPDATE EGO_BULKLOAD_INTF ';
              -------------------------------------------------------------
              --Storing Catalog Group ID and other imp data in buffer cols
              -------------------------------------------------------------
              l_dyn_sql := l_dyn_sql || ' SET  '||G_ITEM_CATALOG_EBI_COL||' = '||G_CATALOG_GROUP_ID;
              l_dyn_sql := l_dyn_sql || ' WHERE INSTANCE_PK2_VALUE = '||l_org_id_table(i);
              l_dyn_sql := l_dyn_sql || ' AND '|| l_item_number_col|| ' = :ITEM_NUMBER';
              l_dyn_sql := l_dyn_sql || ' AND  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
              l_dyn_sql := l_dyn_sql || ' AND   PROCESS_STATUS = 1  ';

              EXECUTE IMMEDIATE l_dyn_sql USING l_item_number_table(i), p_resultfmt_usage_id;
*/
              l_dyn_sql :=              ' UPDATE EGO_BULKLOAD_INTF ';
              -------------------------------------------------------------
              --Storing Catalog Group ID and other imp data in buffer cols
              -------------------------------------------------------------
              l_dyn_sql := l_dyn_sql || ' SET  '||G_ITEM_CATALOG_EBI_COL||' = '||G_CATALOG_GROUP_ID;
              -----------------------------------------------------------------
              -- Fix for Bug# 3945885.
              -- When Item Number in EXCEL is NULL, populate with the Sequence
              -- generated Item Number.
              -----------------------------------------------------------------
-- commenting as a part of 6118945
--              IF (l_item_number_table(i) IS NULL AND
--                  (l_gen_item_num_tbl IS NOT NULL AND
--                   l_gen_item_num_tbl(l_gen_itemnum_indx) IS NOT NULL)
--                  ) THEN
--
--                l_dyn_sql := l_dyn_sql || ' ,  '||l_item_number_col||' = '''||Escape_Single_Quote(l_gen_item_num_tbl(l_gen_itemnum_indx))||'''';
--                ---------------------------------------------------------------------------
--                -- Increment only if Item Number is used.
--                -- NOTE: If l_gen_itemnum_indx = l_gen_item_num_tbl.LAST and still the loop
--                --       is continuing, then need to fetch few more Seq Gen Item Numbers.
--                ---------------------------------------------------------------------------
--                l_gen_itemnum_indx := l_gen_itemnum_indx + 1;
--
--              END IF;
              l_dyn_sql := l_dyn_sql || ' WHERE INSTANCE_PK2_VALUE = :ORGANIZATION_ID ';
              l_dyn_sql := l_dyn_sql || ' AND  TRANSACTION_ID = :TRANSACTION_ID ';
              l_dyn_sql := l_dyn_sql || ' AND  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
              l_dyn_sql := l_dyn_sql || ' AND   PROCESS_STATUS = 1  ';

              Write_Debug(l_dyn_sql);
              EXECUTE IMMEDIATE l_dyn_sql USING l_org_id_table(i), l_trans_id_table(i), p_resultfmt_usage_id;

            END IF;--end: IF (l_catalog_group_id IS NOT NULL)

          --END IF; --end: IF (l_trans_type_table(i) = G_CREATE) ..

         --end: IF FND_FLEX_KEVAL..

      END LOOP; --FOR i IN 1..l_org_id_table.COUNT LOOP

      -----------------------------------------------------------------
      -- Clear all the tables after use.
      -----------------------------------------------------------------
 /*Bug:4211498
      l_org_id_table.DELETE;
      l_item_number_table.DELETE;
      l_trans_type_table.DELETE;
      l_trans_id_table.DELETE;
*/
      -----------------------------------------------------------------
      -- For the final batch of records, either it will be 0 or < 2500
      -----------------------------------------------------------------
      EXIT WHEN l_count <> 2500;

    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_select);

    Write_Debug('Done with Item IDs population.');

    Write_Debug('Populating item number into ego_bulkload_intf for function generated items');
    IF G_PDH_BATCH THEN
/***
      l_dyn_sql := ' UPDATE ego_bulkload_intf ebi' ||
                   ' SET '||l_item_number_col||' = ''$$FG-''||TO_CHAR(transaction_id)'||
                   ' ,c_fix_column12 = TO_CHAR(transaction_id)'||
                   ' WHERE resultfmt_usage_id = :RESULTFMT_USAGE_ID'||
                   ' AND '||G_ITEM_CATALOG_EBI_COL||' IS NOT NULL'||
                   ' AND process_status = 1'||
                   ' AND 10 < '||
                   ' ( SELECT LENGTH ( MIN ('||
                         ' CASE WHEN ITEM_NUM_GEN_METHOD = ''F'' '||
                                   ' AND (PRIOR ITEM_NUM_GEN_METHOD IS NULL OR PRIOR ITEM_NUM_GEN_METHOD = ''I'') ' ||
                              ' THEN LPAD(LEVEL, 8, ''0'')||''XX''||TO_CHAR(item_num_action_id) '||
                              ' WHEN item_num_gen_method IN (''U'', ''S'') '||
                              ' THEN LPAD(LEVEL, 8, ''0'')||''XX'' '||
                              ' ELSE NULL ' ||
                              ' END        )'||
                                   ' )'||
                      ' FROM MTL_ITEM_CATALOG_GROUPS_B '||
                      ' CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID ';
***/
      --
      -- R12C changes Tag_Function_Gen_Item_Nums with item_num as $$FG-transaction_id
      -- populate item number col if null but always set the source system reference
      --
      l_dyn_sql := ' UPDATE ego_bulkload_intf ebi' ||
                   ' SET '||l_item_number_col||' = NVL( '||l_item_number_col||', ''$$FG-''||TO_CHAR(transaction_id) )'||
                   ' ,c_fix_column12 = TO_CHAR(transaction_id)'||
                   ' WHERE resultfmt_usage_id = :RESULTFMT_USAGE_ID'||
                   ' AND '||G_ITEM_CATALOG_EBI_COL||' IS NOT NULL'||
                   ' AND UPPER(ebi.transaction_type) IN (''CREATE'',''SYNC'') '||
                   ' AND process_status = 1'||
                   ' AND ''F'' = '||
                   ' ( SELECT item_num_gen_method'||
                      ' FROM mtl_item_catalog_groups_b '||
                      ' WHERE NVL(item_num_gen_method,''I'') IN (''U'',''S'', ''F'') '||
                      ' AND ROWNUM = 1 '||
                      ' CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID';
      IF G_CATALOG_GROUP_ID IS NULL THEN
        l_dyn_sql := l_dyn_sql || ' START WITH ITEM_CATALOG_GROUP_ID = ebi.'||G_ITEM_CATALOG_EBI_COL;
      ELSE
        l_dyn_sql := l_dyn_sql || ' START WITH ITEM_CATALOG_GROUP_ID = :CATALOG_GROUP_ID';
      END IF;
      l_dyn_sql := l_dyn_sql ||' )';
      Write_Debug(' SQL to generate function generated item numbers: '||l_dyn_sql);
      IF G_CATALOG_GROUP_ID IS NULL THEN
        EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
      ELSE
        EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, G_CATALOG_GROUP_ID;
      END IF;
      Write_Debug(' SQL to generate function generated item numbers DONE ');

      --
      -- R12C changes Tag_Sequence_Gen_Item_Nums with item_num as $$SG-transaction_id
      -- populate item number col if null but always set the source system reference
      --
      l_dyn_sql := ' UPDATE ego_bulkload_intf ebi' ||
                   ' SET '||l_item_number_col||' = NVL( '||l_item_number_col||', ''$$SG-''||TO_CHAR(transaction_id) )'||
                   ' ,c_fix_column12 = TO_CHAR(transaction_id)'||
                   ' WHERE resultfmt_usage_id = :RESULTFMT_USAGE_ID'||
                   ' AND '||G_ITEM_CATALOG_EBI_COL||' IS NOT NULL'||
                   ' AND UPPER(ebi.transaction_type) IN (''CREATE'',''SYNC'') '||
                   ' AND process_status = 1'||
                   ' AND ''S'' = '||
                   ' ( SELECT item_num_gen_method'||
                      ' FROM mtl_item_catalog_groups_b '||
                      ' WHERE NVL(item_num_gen_method,''I'') IN (''U'',''S'', ''F'') '||
                      ' AND ROWNUM = 1 '||
                      ' CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID';
      IF G_CATALOG_GROUP_ID IS NULL THEN
        l_dyn_sql := l_dyn_sql || ' START WITH ITEM_CATALOG_GROUP_ID = ebi.'||G_ITEM_CATALOG_EBI_COL;
      ELSE
        l_dyn_sql := l_dyn_sql || ' START WITH ITEM_CATALOG_GROUP_ID = :CATALOG_GROUP_ID';
      END IF;
      l_dyn_sql := l_dyn_sql ||' )';
      Write_Debug(' SQL to generate  sequence generated item numbers: '||l_dyn_sql);
      IF G_CATALOG_GROUP_ID IS NULL THEN
        EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
      ELSE
        EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, G_CATALOG_GROUP_ID;
      END IF;
      Write_Debug(' SQL to generate sequence generated item numbers DONE ');
    END IF;

    -----------------------------------------------------------------
    -- Determine the Set Process ID, that is unique for MSII
    -----------------------------------------------------------------
    IF p_set_process_id IS NULL THEN
      SELECT mtl_system_items_intf_sets_s.NEXTVAL
        INTO l_msii_set_process_id
      FROM dual;
    ELSE
      l_msii_set_process_id := p_set_process_id;
    END IF;

    Write_Debug('l_msii_set_process_id : '||To_char(l_msii_set_process_id));
    Write_Debug('PROCESS_FLAG : '||To_char(G_PROCESS_STATUS));

     -----------------------------------------------------------------
     -- Insert rows from EBI into MSII
     -----------------------------------------------------------------
    l_dyn_sql :=              'INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE MSII';
    l_dyn_sql := l_dyn_sql || ' ( ';
    l_dyn_sql := l_dyn_sql || ' SET_PROCESS_ID       ,   ';
    l_dyn_sql := l_dyn_sql || ' TRANSACTION_ID       ,   ';
    l_dyn_sql := l_dyn_sql || ' REQUEST_ID           ,   ';
    l_dyn_sql := l_dyn_sql || ' PROGRAM_APPLICATION_ID,  ';
    l_dyn_sql := l_dyn_sql || ' PROGRAM_ID           ,   ';
    l_dyn_sql := l_dyn_sql || ' TRANSACTION_TYPE     ,   ';
    l_dyn_sql := l_dyn_sql || ' INVENTORY_ITEM_ID    ,   ';
    l_dyn_sql := l_dyn_sql || ' ORGANIZATION_ID      ,   ';
    l_dyn_sql := l_dyn_sql || ' ITEM_NUMBER          ,   ';
    l_dyn_sql := l_dyn_sql || ' ORGANIZATION_CODE    ,   ';
    l_dyn_sql := l_dyn_sql || ' ITEM_CATALOG_GROUP_ID,   ';
    l_dyn_sql := l_dyn_sql || ' ITEM_CATALOG_GROUP_NAME, ';
    l_dyn_sql := l_dyn_sql || ' PROCESS_FLAG,            ';
    l_dyn_sql := l_dyn_sql || ' SOURCE_SYSTEM_ID,        ';
    l_dyn_sql := l_dyn_sql || ' SOURCE_SYSTEM_REFERENCE, ';
    l_dyn_sql := l_dyn_sql || ' SOURCE_SYSTEM_REFERENCE_DESC ';
    l_dyn_sql := l_dyn_sql || ') ';
    l_dyn_sql := l_dyn_sql || ' SELECT ';
    l_dyn_sql := l_dyn_sql ||  To_char(l_msii_set_process_id)||' , ';
    l_dyn_sql := l_dyn_sql || ' EBI.TRANSACTION_ID       , ';
    l_dyn_sql := l_dyn_sql || G_REQUEST_ID||' , ';
    l_dyn_sql := l_dyn_sql || G_PROG_APPID||' , ';
    l_dyn_sql := l_dyn_sql || G_PROG_ID||' , ';
    l_dyn_sql := l_dyn_sql || ' UPPER(EBI.TRANSACTION_TYPE) , ';
    l_dyn_sql := l_dyn_sql || ' EBI.INSTANCE_PK1_VALUE   , ';
    l_dyn_sql := l_dyn_sql || ' EBI.INSTANCE_PK2_VALUE   , ';
    /*  FP base bug 7047035: Replace user entered single '\' to '\\', as in excel we don't use escape character '\' to do escape, this can cause validation problem later in import flow */
    l_dyn_sql := l_dyn_sql || ' REPLACE( EBI.'||l_item_number_col ||', ''\'', ''\\'') , ';
    -- l_dyn_sql := l_dyn_sql || ' EBI.'||l_item_number_col ||' , ';
    l_dyn_sql := l_dyn_sql || ' EBI.'||l_org_code_col ||' , ';
    l_dyn_sql := l_dyn_sql || ' EBI.'||G_ITEM_CATALOG_EBI_COL||' , ';
    --------------------------------------------------------------------
    --Bug 4652582 (RSOUNDAR) Catalog Group Name is also required in MSII
    --------------------------------------------------------------------
    l_dyn_sql := l_dyn_sql || ' EBI.'||G_ITEM_CATALOG_NAME_EBI_COL||' , ';
    l_dyn_sql := l_dyn_sql || G_PROCESS_STATUS||' , ';
    l_dyn_sql := l_dyn_sql || ' TO_NUMBER(EBI.C_FIX_COLUMN11) , ';
    l_dyn_sql := l_dyn_sql || ' EBI.C_FIX_COLUMN12 , ';
    l_dyn_sql := l_dyn_sql || ' EBI.C_FIX_COLUMN13 ';
    l_dyn_sql := l_dyn_sql || ' FROM EGO_BULKLOAD_INTF EBI ';
    l_dyn_sql := l_dyn_sql || ' WHERE EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
    l_dyn_sql := l_dyn_sql || '  AND EBI.PROCESS_STATUS = 1';

    Write_Debug(l_dyn_sql);
    EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
    Write_Debug('MSII: Populated the Inv Item IDs, Org IDs.');

     ----------------------------------------------------------------------------------
     --Save Item Num, Org Code in designated columns in EBI for Error Reporting later
     ----------------------------------------------------------------------------------
    l_dyn_sql :=              ' UPDATE EGO_BULKLOAD_INTF ';
    l_dyn_sql := l_dyn_sql || ' SET '||G_ITEM_NUMBER_EBI_COL||' = '||l_item_number_col||' , ';
    l_dyn_sql := l_dyn_sql || G_ORG_CODE_EBI_COL||' = '||l_org_code_col ;
    l_dyn_sql := l_dyn_sql || ' WHERE RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
    l_dyn_sql := l_dyn_sql || ' AND PROCESS_STATUS = 1                     ';

    Write_Debug(l_dyn_sql);
    EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
    Write_Debug('Items Interface: Done saving Item Num, Org Code in EBI for error retrieval later.');

     ---------------------------------------
     -- Reset i back to 0, for re-use.
     ---------------------------------------
    i := 0;
    IF ( l_prod_col_name_tbl.count > 0) THEN
      FOR i IN l_prod_col_name_tbl.first .. l_prod_col_name_tbl.last LOOP
         Write_Debug('$l_prod_col_name_tbl(i)'||l_prod_col_name_tbl(i));
         Write_Debug('$l_intf_col_name_tbl(i)'||l_intf_col_name_tbl(i));

         ----------------------------------------------------------------------------------
         --  Transfer the Item Catalog Group information from EBI to MSII
         --  by doing Value-to-ID Conversion.
         ----------------------------------------------------------------------------------
         ---------------------------------------------------------------------
         --Bug#4652582 (RSOUNDAR)
         --(Catalog Name validation will be done by IOI)
         ---------------------------------------------------------------------
--         IF (l_prod_col_name_tbl(i) = G_ITEM_CATALOG_GROUP) THEN
--           l_dyn_sql := '';
--           l_dyn_sql := l_dyn_sql || 'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
--           l_dyn_sql := l_dyn_sql || ' SET  (MSII.ITEM_CATALOG_GROUP_ID,  MSII.PROCESS_FLAG)=';
--           l_dyn_sql := l_dyn_sql || '( ';
--           l_dyn_sql := l_dyn_sql || '    SELECT MICG.ITEM_CATALOG_GROUP_ID ';
--           l_dyn_sql := l_dyn_sql || '        ,  DECODE(NVL(MICG.ITEM_CATALOG_GROUP_ID, -1), -1,'||G_ITEM_CATALOG_NAME_ERR_STS||', ' || G_PROCESS_STATUS || ' ) ';
--           l_dyn_sql := l_dyn_sql || '    FROM   MTL_ITEM_CATALOG_GROUPS_B_KFV MICG, EGO_BULKLOAD_INTF EBI  ';
--           l_dyn_sql := l_dyn_sql || '    WHERE  MICG.CONCATENATED_SEGMENTS(+) = EBI.'||l_intf_col_name_tbl(i);
--           l_dyn_sql := l_dyn_sql || '    AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
--           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
--           ----------------------------------------------------------------------------------
--           --  WHERE EXISTS takes care of filtering lines. Hence this join not needed.
--           --  l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
--           ----------------------------------------------------------------------------------
--           l_dyn_sql := l_dyn_sql || ') ';
--           l_dyn_sql := l_dyn_sql || ' WHERE EXISTS ';
--           l_dyn_sql := l_dyn_sql || '( ';
--           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
--           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
--           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
--           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
--           ----------------------------------------------------------------------------------
--           -- Validate only for the NOT NULL values, and update MSII.
--           -- NULL values dont need to go in.
--           ----------------------------------------------------------------------------------
--           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' IS NOT NULL';
--           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
--           l_dyn_sql := l_dyn_sql || '    AND    MSII.PROCESS_FLAG = ' || G_PROCESS_STATUS ;
--           l_dyn_sql := l_dyn_sql || ') ';
--
--           Write_Debug(l_dyn_sql);
--           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;
--           Write_Debug('MSII: Updated the Catalog Group IDs.');

         ----------------------------------------------------------------------------------
         --  Transfer the Primary Unit of Measure information from EBI to MSII
         --  by doing Value-to-ID Conversion.
         ----------------------------------------------------------------------------------

         IF (l_prod_col_name_tbl(i) = G_PRIMARY_UOM) THEN

           -- populating MSII with PRIMARY_UOM_CODE if exists
           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  (MSII.PRIMARY_UOM_CODE   ';
           l_dyn_sql := l_dyn_sql || '    ,  MSII.PROCESS_FLAG )= ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT MUOM.UOM_CODE   ';
           l_dyn_sql := l_dyn_sql || '         , DECODE(NVL(MUOM.UOM_CODE, ''NULL''),''NULL'','||G_PRIMARY_UOM_ERR_STS||', ' || G_PROCESS_STATUS || ' )  ';
           l_dyn_sql := l_dyn_sql || '    FROM MTL_UNITS_OF_MEASURE_TL MUOM, EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE MUOM.UNIT_OF_MEASURE_TL (+) = EBI.'||l_intf_col_name_tbl(i);
           l_dyn_sql := l_dyn_sql || '    AND MUOM.LANGUAGE (+) = Userenv(''LANG'') ';
           l_dyn_sql := l_dyn_sql || '    AND EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '    AND EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND EBI.'||l_intf_col_name_tbl(i)||' IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND EBI.'||l_intf_col_name_tbl(i)||' <> '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;

           -- populating MSII with PRIMARY_UOM_CODE if special char for null out exists
           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  MSII.PRIMARY_UOM_CODE = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND EBI.'||l_intf_col_name_tbl(i)||' = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
           Write_Debug('MSII: Updated the Primary UOMs.');

         ----------------------------------------------------------------------------------
         --  Bug# 3421497 fix.
         --  If Lifecycle ID or Lifecycle Phase ID, save column information, and process
         --  later in the sequence, as Lifecycle Phase ID Value-to-ID conversion is
         --  dependant upon the Lifecycle ID value.
         ----------------------------------------------------------------------------------
         ELSIF (l_prod_col_name_tbl(i) = G_LIFECYCLE) THEN

           l_lifecycle_col_val := l_intf_col_name_tbl(i);

         ----------------------------------------------------------------------------------
         --  Bug# 3421497 fix.
         --  If Lifecycle ID or Lifecycle Phase ID, save column information, and process
         --  later in the sequence, as Lifecycle Phase ID Value-to-ID conversion is
         --  dependant upon the Lifecycle ID value.
         ----------------------------------------------------------------------------------
         ELSIF (l_prod_col_name_tbl(i) = G_LIFECYCLE_PHASE) THEN

           l_lifecycle_phase_col_val := l_intf_col_name_tbl(i);

         ----------------------------------------------------------------------------------
         --  Transfer the User Item Type information from EBI to MSII
         --  by doing Value-to-ID Conversion.
         ----------------------------------------------------------------------------------
         ELSIF (l_prod_col_name_tbl(i) = G_USER_ITEM_TYPE) THEN

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  (MSII.ITEM_TYPE   ';
           l_dyn_sql := l_dyn_sql || '    ,  MSII.PROCESS_FLAG         )= ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT IT.LOOKUP_CODE ';
           l_dyn_sql := l_dyn_sql || '         , DECODE(NVL(IT.LOOKUP_CODE, ''NULL''),''NULL'','||G_USER_ITEM_TYPE_ERR_STS||', ' || G_PROCESS_STATUS || ') ';
           l_dyn_sql := l_dyn_sql || '    FROM   FND_LOOKUP_VALUES IT, EGO_BULKLOAD_INTF EBI ';
           l_dyn_sql := l_dyn_sql || '    WHERE  IT.LOOKUP_TYPE (+) = ''ITEM_TYPE'' ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.LANGUAGE (+) = Userenv(''LANG'') ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.MEANING (+) = EBI.'||l_intf_col_name_tbl(i);
           l_dyn_sql := l_dyn_sql || '     AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '     AND   EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' <> '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  MSII.ITEM_TYPE = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
           Write_Debug('MSII: Updated the User Item Types.');

         ----------------------------------------------------------------------------------
         --  Transfer the BOM Item Type information from EBI to MSII
         --  by doing Value-to-ID Conversion.
         ----------------------------------------------------------------------------------
         ELSIF (l_prod_col_name_tbl(i) = G_BOM_ITEM_TYPE) THEN

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  (MSII.BOM_ITEM_TYPE   ';
           l_dyn_sql := l_dyn_sql || '    ,  MSII.PROCESS_FLAG         )= ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT IT.LOOKUP_CODE ';
           l_dyn_sql := l_dyn_sql || '         , DECODE(NVL(IT.LOOKUP_CODE, ''NULL''),''NULL'','||G_BOM_ITEM_TYPE_ERR_STS||', ' || G_PROCESS_STATUS || ') ';
           l_dyn_sql := l_dyn_sql || '    FROM   FND_LOOKUP_VALUES IT, EGO_BULKLOAD_INTF EBI ';
           l_dyn_sql := l_dyn_sql || '    WHERE  IT.LOOKUP_TYPE (+) = ''BOM_ITEM_TYPE'' ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.LANGUAGE (+) = Userenv(''LANG'') ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.MEANING (+) = EBI.'||l_intf_col_name_tbl(i);
           l_dyn_sql := l_dyn_sql || '     AND   EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '     AND   EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' <> '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  MSII.BOM_ITEM_TYPE = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
           Write_Debug('MSII: Updated the BOM Item Types.');

          ELSIF (l_prod_col_name_tbl(i) = G_TRADE_ITEM_DESCRIPTOR) THEN
            l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  (MSII.TRADE_ITEM_DESCRIPTOR   ';
           l_dyn_sql := l_dyn_sql || '    ,  MSII.PROCESS_FLAG         )= ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT IT.INTERNAL_NAME ';
           l_dyn_sql := l_dyn_sql || '         , DECODE(NVL(IT.INTERNAL_NAME, ''NULL''),''NULL'','||G_TRADE_ITEM_DESC_ERR_STS||', ' || G_PROCESS_STATUS || ') ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_VALUE_SET_VALUES_V IT, EGO_BULKLOAD_INTF EBI ';
           l_dyn_sql := l_dyn_sql || '    WHERE  IT.VALUE_SET_NAME = ''TradeItemDescVS'' ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.DISPLAY_NAME = EBI.'||l_intf_col_name_tbl(i);
           l_dyn_sql := l_dyn_sql || '     AND   EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '     AND   EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' <> '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  MSII.TRADE_ITEM_DESCRIPTOR = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
           Write_Debug('MSII: Updated the Trade Item Descriptor.');

         ----------------------------------------------------------------------------------
         --  Transfer the Engineering Item Flag information from EBI to MSII
         --  by doing Value-to-ID Conversion.
         ----------------------------------------------------------------------------------
         ELSIF (l_prod_col_name_tbl(i) = G_ENG_ITEM_FLAG) THEN

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  (MSII.ENG_ITEM_FLAG   ';
           l_dyn_sql := l_dyn_sql || '    ,  MSII.PROCESS_FLAG         )= ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT IT.LOOKUP_CODE ';
           l_dyn_sql := l_dyn_sql || '         , DECODE(NVL(IT.LOOKUP_CODE, ''NULL''),''NULL'','||G_ENG_ITEM_FLAG_ERR_STS||', ' || G_PROCESS_STATUS || ') ';
           l_dyn_sql := l_dyn_sql || '    FROM   FND_LOOKUP_VALUES IT, EGO_BULKLOAD_INTF EBI ';
           l_dyn_sql := l_dyn_sql || '    WHERE  IT.LOOKUP_TYPE (+) = ''EGO_YES_NO'' ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.LANGUAGE (+) = Userenv(''LANG'') ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.MEANING (+) = EBI.'||l_intf_col_name_tbl(i);
           l_dyn_sql := l_dyn_sql || '     AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '     AND   EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' <> '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  MSII.ENG_ITEM_FLAG = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
           Write_Debug('MSII: Updated the Eng Item Flags.');

         --Bug: 3969593 Adding new 11.5.10 Primary Attrs: Begin
         ----------------------------------------------------------------------------------
         --  Transfer the Conversions attribute information from EBI to MSII
         --  by doing Value-to-ID Conversion.
         ----------------------------------------------------------------------------------
         ELSIF (l_prod_col_name_tbl(i) = G_CONVERSIONS) THEN

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  (MSII.ALLOWED_UNITS_LOOKUP_CODE   ';
           l_dyn_sql := l_dyn_sql || '    ,  MSII.PROCESS_FLAG         )= ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT IT.LOOKUP_CODE ';
           l_dyn_sql := l_dyn_sql || '         , DECODE(NVL(IT.LOOKUP_CODE, ''NULL''),''NULL'','||G_CONVERSIONS_ERR_STS||', ' || G_PROCESS_STATUS || ') ';
           l_dyn_sql := l_dyn_sql || '    FROM   FND_LOOKUP_VALUES IT, EGO_BULKLOAD_INTF EBI ';
           l_dyn_sql := l_dyn_sql || '    WHERE  IT.LOOKUP_TYPE (+) = ''MTL_CONVERSION_TYPE'' ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.LANGUAGE (+) = Userenv(''LANG'') ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.MEANING (+) = EBI.'||l_intf_col_name_tbl(i);
           l_dyn_sql := l_dyn_sql || '     AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '     AND   EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' <> '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  MSII.ALLOWED_UNITS_LOOKUP_CODE = :NULL_NUM ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           EXECUTE IMMEDIATE l_dyn_sql USING EGO_ITEM_PUB.G_INTF_NULL_NUM, p_resultfmt_usage_id;
           Write_Debug('MSII: Updated the Conversions.');

         ----------------------------------------------------------------------------------
         --  Transfer the Conversions attribute information from EBI to MSII
         --  by doing Value-to-ID Conversion.
         ----------------------------------------------------------------------------------
         ELSIF (l_prod_col_name_tbl(i) = G_SECONDARY_DEF_IND) THEN

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  (MSII.SECONDARY_DEFAULT_IND   ';
           l_dyn_sql := l_dyn_sql || '    ,  MSII.PROCESS_FLAG         )= ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT IT.LOOKUP_CODE ';
           l_dyn_sql := l_dyn_sql || '         , DECODE(NVL(IT.LOOKUP_CODE, ''NULL''),''NULL'','||G_SECONDARY_DEF_IND_ERR_STS||', ' || G_PROCESS_STATUS || ') ';
           l_dyn_sql := l_dyn_sql || '    FROM   FND_LOOKUP_VALUES IT, EGO_BULKLOAD_INTF EBI ';
           l_dyn_sql := l_dyn_sql || '    WHERE  IT.LOOKUP_TYPE (+) = ''INV_DEFAULTING_UOM_TYPE'' ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.LANGUAGE (+) = Userenv(''LANG'') ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.MEANING (+) = EBI.'||l_intf_col_name_tbl(i);
           l_dyn_sql := l_dyn_sql || '     AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '     AND   EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' <> '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  MSII.SECONDARY_DEFAULT_IND = :NULL_NUM';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           EXECUTE IMMEDIATE l_dyn_sql USING EGO_ITEM_PUB.G_INTF_NULL_NUM, p_resultfmt_usage_id;
           Write_Debug('MSII: Updated the Conversions.');

         ----------------------------------------------------------------------------------
         --  Transfer the Conversions attribute information from EBI to MSII
         --  by doing Value-to-ID Conversion.
         ----------------------------------------------------------------------------------
         ELSIF (l_prod_col_name_tbl(i) = G_ONT_PRICING_QTY_SRC) THEN

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  (MSII.ONT_PRICING_QTY_SOURCE   ';
           l_dyn_sql := l_dyn_sql || '    ,  MSII.PROCESS_FLAG         )= ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT IT.LOOKUP_CODE ';
           l_dyn_sql := l_dyn_sql || '         , DECODE(NVL(IT.LOOKUP_CODE, ''NULL''),''NULL'','||G_ONT_PRICING_QTY_SRC_ERR_STS||', ' || G_PROCESS_STATUS || ') ';
           l_dyn_sql := l_dyn_sql || '    FROM   FND_LOOKUP_VALUES IT, EGO_BULKLOAD_INTF EBI ';
           l_dyn_sql := l_dyn_sql || '    WHERE  IT.LOOKUP_TYPE (+) = ''INV_PRICING_UOM_TYPE'' ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.LANGUAGE (+) = Userenv(''LANG'') ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.MEANING (+) = EBI.'||l_intf_col_name_tbl(i);
           l_dyn_sql := l_dyn_sql || '     AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '     AND   EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' <> '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  MSII.ONT_PRICING_QTY_SOURCE = :NULL_NUM';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           EXECUTE IMMEDIATE l_dyn_sql USING EGO_ITEM_PUB.G_INTF_NULL_NUM, p_resultfmt_usage_id;
           Write_Debug('MSII: Updated the Conversions.');

         ----------------------------------------------------------------------------------
         --  Transfer the Conversions attribute information from EBI to MSII
         --  by doing Value-to-ID Conversion.
         ----------------------------------------------------------------------------------
         ELSIF (l_prod_col_name_tbl(i) = G_SECONDARY_UOM_CODE) THEN

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  (MSII.SECONDARY_UOM_CODE   ';
           l_dyn_sql := l_dyn_sql || '    ,  MSII.PROCESS_FLAG         )= ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT MUOM.UOM_CODE   ';
           l_dyn_sql := l_dyn_sql || '         , DECODE(NVL(MUOM.UOM_CODE, ''NULL''),''NULL'','||G_SECONDARY_UOM_CODE_ERR_STS||', ' || G_PROCESS_STATUS || ')  ';
           l_dyn_sql := l_dyn_sql || '    FROM   MTL_UNITS_OF_MEASURE_TL MUOM, EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  MUOM.UNIT_OF_MEASURE_TL (+) = EBI.'||l_intf_col_name_tbl(i);
           l_dyn_sql := l_dyn_sql || '    AND    MUOM.LANGUAGE (+) = Userenv(''LANG'') ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' <> '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  MSII.SECONDARY_UOM_CODE = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
           Write_Debug('MSII: Updated the Conversions.');

         ----------------------------------------------------------------------------------
         --  Transfer the Conversions attribute information from EBI to MSII
         --  by doing Value-to-ID Conversion.
         ----------------------------------------------------------------------------------
         ELSIF (l_prod_col_name_tbl(i) = G_TRACKING_QTY_IND) THEN

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  (MSII.TRACKING_QUANTITY_IND   ';
           l_dyn_sql := l_dyn_sql || '    ,  MSII.PROCESS_FLAG         )= ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT IT.LOOKUP_CODE ';
           l_dyn_sql := l_dyn_sql || '         , DECODE(NVL(IT.LOOKUP_CODE, ''NULL''),''NULL'','||G_TRACKING_QTY_IND_ERR_STS||', ' || G_PROCESS_STATUS || ') ';
           l_dyn_sql := l_dyn_sql || '    FROM   FND_LOOKUP_VALUES IT, EGO_BULKLOAD_INTF EBI ';
           l_dyn_sql := l_dyn_sql || '    WHERE  IT.LOOKUP_TYPE (+) = ''INV_TRACKING_UOM_TYPE'' ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.LANGUAGE (+) = Userenv(''LANG'') ';
           l_dyn_sql := l_dyn_sql || '     AND   IT.MEANING (+) = EBI.'||l_intf_col_name_tbl(i);
           l_dyn_sql := l_dyn_sql || '     AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '     AND   EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' <> '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  MSII.TRACKING_QUANTITY_IND = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
           Write_Debug('MSII: Updated the Conversions.');
           --Bug: 3969593 End

         ----------------------------------------------------------------------------------
         --  Transfer the Item Status Code attribute information from EBI to MSII
         --  by doing Value-to-ID Conversion. Rathna
         ----------------------------------------------------------------------------------
         ELSIF (l_prod_col_name_tbl(i) = G_INVENTORY_ITEM_STATUS) THEN

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  (MSII.INVENTORY_ITEM_STATUS_CODE ';
           l_dyn_sql := l_dyn_sql || '    ,  MSII.PROCESS_FLAG         )= ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT IT.INVENTORY_ITEM_STATUS_CODE ';
           l_dyn_sql := l_dyn_sql || '         , DECODE(NVL(IT.INVENTORY_ITEM_STATUS_CODE, ''NULL''),''NULL'','||G_INV_ITEM_STATUS_ERR_STS||', ' || G_PROCESS_STATUS || ') ';
           l_dyn_sql := l_dyn_sql || '    FROM   MTL_ITEM_STATUS IT, EGO_BULKLOAD_INTF EBI ';
           l_dyn_sql := l_dyn_sql || '    WHERE  IT.INVENTORY_ITEM_STATUS_CODE_TL (+) = EBI.'||l_intf_col_name_tbl(i);
           l_dyn_sql := l_dyn_sql || '     AND   EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '     AND   EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' <> '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  MSII.TRACKING_QUANTITY_IND = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
           Write_Debug('MSII: Updated the Item Status.*');

         ----------------------------------------------------------------------------------
         --  Transfer the Column information from EBI to MSII
         --  which *DONOT NEED* Value-to-ID Conversion.
         ----------------------------------------------------------------------------------
         ELSIF (l_prod_col_name_tbl(i) <> G_CREATION_DATE AND l_prod_col_name_tbl(i) <>  G_CREATED_BY) THEN
           --Bug Fix 4713312:START
           IF (l_prod_col_name_tbl(i) = G_ITEM_CATALOG_GROUP1) THEN
             l_col_name := G_ITEM_CATALOG_GROUP;
           ELSE
             l_col_name := l_prod_col_name_tbl(i);
           END IF;
          Write_Debug('Updating MSII: l_col_name = ' || l_col_name);
           --Bug Fix 4713312:END
           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET   MSII.'||l_col_name||' =  ';
           l_dyn_sql := l_dyn_sql || '( ';
--  MLS Status
--           IF (l_prod_col_name_tbl(i) = G_INV_STATUS_CODE_NAME) THEN
--             ----------------------------------------------------------------------------------
--             -- MSII INVENTORY_ITEM_STATUS_CODE is only 10 char long
--             ----------------------------------------------------------------------------------
--             l_dyn_sql := l_dyn_sql || ' SELECT SUBSTRB(EBI.'||l_intf_col_name_tbl(i) || ', 1, 10)';
--
--           ELSE
           IF (l_prod_col_name_tbl(i) = G_ITEM_TEMPLATE_NAME) THEN
             ----------------------------------------------------------------------------------
             -- MSII TEMPLATE_NAME is only 30 chars long
             ----------------------------------------------------------------------------------
             l_dyn_sql := l_dyn_sql || ' SELECT SUBSTR(EBI.'||l_intf_col_name_tbl(i)|| ',1,30)';

           ELSIF  (l_prod_col_name_tbl(i) IN ('STYLE_ITEM_FLAG', 'GDSN_OUTBOUND_ENABLED_FLAG' )) THEN
              l_dyn_sql := l_dyn_sql || ' SELECT LOOKUP_CODE ';
           ELSE
             ----------------------------------------------------------------------------------
             -- All other columns, which *DONOT NEED* any special treatment.
             ----------------------------------------------------------------------------------
              l_dyn_sql := l_dyn_sql || ' SELECT EBI.'||l_intf_col_name_tbl(i);
           END IF; --end: IF (l_prod_col_name_tbl(i) = G_ITEM_TEMPLATE_NAME)

           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI ';

           IF  (l_prod_col_name_tbl(i) IN ('STYLE_ITEM_FLAG', 'GDSN_OUTBOUND_ENABLED_FLAG' )) THEN
             l_dyn_sql := l_dyn_sql || '    ,   FND_LOOKUP_VALUES_VL LKUP ';
           END IF;

           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '     AND   EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';

           IF  (l_prod_col_name_tbl(i) IN ('STYLE_ITEM_FLAG', 'GDSN_OUTBOUND_ENABLED_FLAG' )) THEN
             l_dyn_sql := l_dyn_sql || ' AND  LOOKUP_TYPE = ''EGO_YES_NO'' ';
             l_dyn_sql := l_dyn_sql || ' AND  LKUP.MEANING = EBI.'||l_intf_col_name_tbl(i)||' ';
           END IF;

           l_dyn_sql := l_dyn_sql || ') ';

            /* Fix for bug 8530157- if column name is icc_name then set the icc_id too */
           IF ( l_col_name = G_ITEM_CATALOG_GROUP ) THEN

           /* option 1 -set the icc_id to null and check if IOI will populate it based on icc_name */
           		l_dyn_sql := l_dyn_sql || ' , MSII.ITEM_CATALOG_GROUP_ID = NULL  ';

           /*  option 2 (commented for now) : use if option 1 does not work. fetch the icc_id and set it
           		l_dyn_sql := l_dyn_sql || ' , MSII.ITEM_CATALOG_GROUP_ID =   ';
          		l_dyn_sql := l_dyn_sql || ' ( ';
           		l_dyn_sql := l_dyn_sql || '    SELECT MICG.ITEM_CATALOG_GROUP_ID ';
  			    l_dyn_sql := l_dyn_sql || '    FROM   MTL_ITEM_CATALOG_GROUPS_B_KFV MICG, EGO_BULKLOAD_INTF EBI  ';
          		l_dyn_sql := l_dyn_sql || '    WHERE  MICG.CONCATENATED_SEGMENTS(+) = EBI.'||l_intf_col_name_tbl(i);
          		l_dyn_sql := l_dyn_sql || ' ) ';
           */
           END IF;

           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND MSII.TRANSACTION_ID IN ';
           l_dyn_sql := l_dyn_sql || ' ( ';
           l_dyn_sql := l_dyn_sql || '    SELECT EBI.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
--           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '     AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ' ) ';

           Write_Debug(l_dyn_sql);
           Write_Debug('Updating : RSOUNDAR: MSII: l_dyn_sql = ' || l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;
           Write_Debug('MSII: Updated the '||l_prod_col_name_tbl(i)||' column values.');

         END IF;--end: IF (l_prod_col_name_tbl(i) = G_ITEM_CATALOG_GROUP) THEN

         -- Bug: 3778006
         ----------------------------------------------------------------------------------
         --  Checking if transaction_type is update and Description generation method is
         --  Function Generated, then Description updation should not be allowed.
         ----------------------------------------------------------------------------------
         IF (l_prod_col_name_tbl(i) = G_DESCRIPTION) THEN
--DPHILIP: we need to check what is the impact of this check
           Write_Debug('DPHILIP :updating description setting the error status to:  ' || G_DESCRIPTION_ERR_STS);

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  MSII.PROCESS_FLAG = '||G_DESCRIPTION_ERR_STS||' ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT NULL ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI, MTL_SYSTEM_ITEMS_VL MSIV ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.INSTANCE_PK1_VALUE = MSIV.INVENTORY_ITEM_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.INSTANCE_PK2_VALUE = MSIV.ORGANIZATION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EGO_ITEM_BULKLOAD_PKG.get_desc_gen_method(MSIV.ITEM_CATALOG_GROUP_ID) = :FUNCTION_GEN ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_intf_col_name_tbl(i)||' <> MSIV.DESCRIPTION';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.INSTANCE_PK1_VALUE IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND    UPPER(EBI.TRANSACTION_TYPE) IN (:UPD, :SYNC)';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, 'F', 'UPDATE', 'SYNC';
           Write_Debug('MSII: Logged Error (if any) in updating description');

         END IF;

       END LOOP;--end: FOR i IN l_prod_col_name_tbl.first .. l_prod_col_name_tbl.last LOOP

       ----------------------------------------------------------------------------------
       --  Bug# 3421497 fix.
       --  If Lifecycle ID or Lifecycle Phase ID, save column information, and process
       --  later in the sequence, as Lifecycle Phase ID Value-to-ID conversion is
       --  dependant upon the Lifecycle ID value.
       --  Hence the are processed outside the above LOOP.
       ----------------------------------------------------------------------------------

       IF (l_lifecycle_col_val IS NOT NULL) THEN

         ----------------------------------------------------------------------------------
         --  First Transfer the Lifecycle information from EBI to MSII
         --  by doing Value-to-ID Conversion.
         ----------------------------------------------------------------------------------
           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  (MSII.LIFECYCLE_ID   ';
           l_dyn_sql := l_dyn_sql || '    ,  MSII.PROCESS_FLAG         )= ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT LC.PROJ_ELEMENT_ID ';
           l_dyn_sql := l_dyn_sql || '         , DECODE(NVL(LC.PROJ_ELEMENT_ID, -1), -1,'||G_LIFECYCLE_ERR_STS||', ' || G_PROCESS_STATUS || ') ';
           l_dyn_sql := l_dyn_sql || '    FROM   PA_EGO_LIFECYCLES_V LC, EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  LC.NAME (+) = EBI.'||l_lifecycle_col_val;
           l_dyn_sql := l_dyn_sql || '    AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_lifecycle_col_val||' IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_lifecycle_col_val||' <> '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  MSII.LIFECYCLE_ID = :NULL_NUM';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_lifecycle_col_val||' = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING EGO_ITEM_PUB.G_INTF_NULL_NUM, p_resultfmt_usage_id;

           Write_Debug('MSII: Updated the Lifecycle IDs.');

       END IF; --end: IF (l_lifecycle_col_val IS NOT NULL ...

       IF (l_lifecycle_phase_col_val IS NOT NULL) THEN
         ----------------------------------------------------------------------------------
         --  Next Transfer the Lifecycle Phase information from EBI to MSII
         --  by doing Value-to-ID Conversion, and by joining Lifecycle ID information.
         ----------------------------------------------------------------------------------
           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  (MSII.CURRENT_PHASE_ID   ';
           l_dyn_sql := l_dyn_sql || '    ,  MSII.PROCESS_FLAG         )= ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT LCP.PROJ_ELEMENT_ID ';
           l_dyn_sql := l_dyn_sql || '         , DECODE(NVL(LCP.PROJ_ELEMENT_ID, -1), -1,'||G_LIFECYCLE_PHASE_ERR_STS||', ' || G_PROCESS_STATUS || ') ';
           l_dyn_sql := l_dyn_sql || '    FROM   PA_EGO_PHASES_V LCP, EGO_BULKLOAD_INTF EBI ';
           l_dyn_sql := l_dyn_sql || '    WHERE  LCP.PARENT_STRUCTURE_ID (+) = MSII.LIFECYCLE_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    LCP.NAME (+) = EBI.'||l_lifecycle_phase_col_val;
           l_dyn_sql := l_dyn_sql || '    AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '     AND   EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_lifecycle_phase_col_val||' IS NOT NULL';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_lifecycle_phase_col_val||' <> '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;

           l_dyn_sql :=              'UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII ';
           l_dyn_sql := l_dyn_sql || ' SET  MSII.CURRENT_PHASE_ID = :NULL_NUM';
           l_dyn_sql := l_dyn_sql || ' WHERE MSII.SET_PROCESS_ID  = ' || l_msii_set_process_id;
           l_dyn_sql := l_dyn_sql || '   AND MSII.PROCESS_FLAG  = ' || G_PROCESS_STATUS;
           l_dyn_sql := l_dyn_sql || '   AND EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_lifecycle_phase_col_val||' = '''||EGO_ITEM_PUB.G_INTF_NULL_CHAR||'''';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           EXECUTE IMMEDIATE l_dyn_sql USING EGO_ITEM_PUB.G_INTF_NULL_NUM, p_resultfmt_usage_id;
           Write_Debug('MSII: Updated the Lifecycle Phase IDs.');

       END IF; --end: IF (l_lifecycle_phase_col_val IS NOT NULL ...

    END IF; --IF ( l_prod_col_name_tbl.count > 0) THEN
    --
    -- convert all date fields values from Excel Null to INTF Null
    --
    UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
    SET  start_date_active = DECODE(start_date_active,G_EXCEL_NULL_DATE,EGO_ITEM_PUB.G_INTF_NULL_DATE,start_date_active),
         end_date_active = DECODE(end_date_active,G_EXCEL_NULL_DATE,EGO_ITEM_PUB.G_INTF_NULL_DATE,end_date_active),
         engineering_date = DECODE(engineering_date,G_EXCEL_NULL_DATE,EGO_ITEM_PUB.G_INTF_NULL_DATE,engineering_date)
    WHERE MSII.SET_PROCESS_ID  = l_msii_set_process_id
      AND MSII.PROCESS_FLAG  = G_PROCESS_STATUS
      AND (MSII.start_date_active IS NOT NULL
           OR
           MSII.end_date_active IS NOT NULL
           OR
           MSII.engineering_date IS NOT NULL
          )
      AND EXISTS
       ( SELECT 'X'
         FROM   EGO_BULKLOAD_INTF EBI
         WHERE  EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id
         AND    EBI.TRANSACTION_ID = MSII.TRANSACTION_ID
         AND    EBI.PROCESS_STATUS = 1
       );
    ----------------------------------------------------------------------------------
    -- To print all the Item Numbers.
    -- 1) That were passed in Excel
    -- 2) That were Sequence generated
    -- etc., (i.e. in future, Function generated etc.,)
    ----------------------------------------------------------------------------------
    Log_ItemNums_ToBe_Processed(p_resultfmt_usage_id,
                                l_item_number_col);
    x_retcode := G_STATUS_SUCCESS;
    x_set_process_id := l_msii_set_process_id;

    ----------------------------------------------------------------------------------
    -- Now that Revision Update is supported through Item Search Results,
    -- need to use the same set_process_id for Revisions Interface also.
    -- Hence storing in a Global variable.
    ----------------------------------------------------------------------------------
    G_MSII_SET_PROCESS_ID := l_msii_set_process_id;

END load_item_interface;


 ----------------------------------------------------------
 --  Preprocess Item Interface Lines                     --
 ----------------------------------------------------------

PROCEDURE preprocess_item_interface
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_caller_identifier     IN         VARCHAR2 DEFAULT EGO_ITEM_BULKLOAD_PKG.G_ITEM,
                 p_set_process_id        IN         NUMBER,
                 x_errbuff               IN OUT NOCOPY     VARCHAR2,
                 x_retcode               IN OUT NOCOPY    VARCHAR2
                ) IS

    -- Start OF comments
    -- API name  : Setup MSII Item Interface Lines for processing
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  : Populate and Prepare Item interfance lines.
    --             Eliminates any redundancy / errors in MSII

  -----------------------------------------------
  -- Long Dynamic SQL String
  -----------------------------------------------
  l_dyn_sql                VARCHAR2(20000);

  -----------------------------------------------
  -- Error message variables
  -----------------------------------------------
  l_item_catalog_err_msg      VARCHAR2(2000);
  l_uom_err_msg               VARCHAR2(2000);
  l_lifecycle_err_msg         VARCHAR2(2000);
  l_lifecycle_ph_err_msg      VARCHAR2(2000);
  l_useritemtype_err_msg      VARCHAR2(2000);
  l_bomitemtype_err_msg       VARCHAR2(2000);
  l_engitemflag_err_msg       VARCHAR2(2000);
  l_description_err_msg       VARCHAR2(2000); -- Bug: 3778006
  --Bug: 3969593 Adding new 11.5.10 Primary Attrs: Begin
  l_conversions_err_msg       VARCHAR2(2000);
  l_secondary_def_err_msg     VARCHAR2(2000);
  l_ont_pricing_qty_src_err_msg VARCHAR2(2000);
  l_secondary_uom_code_err_msg  VARCHAR2(2000);
  l_tracking_qty_ind_err_msg    VARCHAR2(2000);
  l_inv_item_status_err_msg     VARCHAR2(2000);
  --Bug: 3969593 End
  --R12C changes for Pack Hierarchy
  l_tradeitemdesc_err_msg    VARCHAR2(2000);
BEGIN

   Write_Debug('EBI : Getting the messages.');

   -----------------------------------------------------------------------
   -- Preparation for Inserting error messages for all pre-processing   --
   -- Validation errors.                                                --
   -----------------------------------------------------------------------
   FND_MESSAGE.SET_NAME('EGO','EGO_ITEMCATALOG_INVALID');

   -----------------------------------------------------------------------
   -- Fixing MLS Bug# 3421756                                           --
   -- Replacing 1 quote with 2 quotes to be used in Dynamic SQL         --
   -- None of the messages have ampersands or other suspicious chars    --
   -- that could cause harm in the Dynamic SQL run below.               --
   -----------------------------------------------------------------------
   l_item_catalog_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');

   FND_MESSAGE.SET_NAME('EGO','EGO_PRIMARYUOM_INVALID');
   l_uom_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');

   FND_MESSAGE.SET_NAME('EGO','EGO_LIFECYCLE_INVALID');
   l_lifecycle_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');

   FND_MESSAGE.SET_NAME('EGO','EGO_LIFECYCLE_PHASE_INVALID');
   l_lifecycle_ph_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');

   FND_MESSAGE.SET_NAME('EGO','EGO_USERITEMTYPE_INVALID');
   l_useritemtype_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');

   FND_MESSAGE.SET_NAME('EGO','EGO_BOMITEMTYPE_INVALID');
   l_bomitemtype_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');

   FND_MESSAGE.SET_NAME('EGO','EGO_ENGITEMFLAG_INVALID');
   l_engitemflag_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');

   -- Bug: 3778006
   FND_MESSAGE.SET_NAME('EGO','EGO_ITEMDESC_IS_FG');
   l_description_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');

   --Bug: 3969593 Adding new 11.5.10 Primary Attrs: Begin
   FND_MESSAGE.SET_NAME('EGO','EGO_CONVERSIONS_INVALID');
   l_conversions_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');

   FND_MESSAGE.SET_NAME('EGO','EGO_DEFAULTING_INVALID');
   l_secondary_def_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');

   FND_MESSAGE.SET_NAME('EGO','EGO_PRICING_INVALID');
   l_ont_pricing_qty_src_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');

   FND_MESSAGE.SET_NAME('EGO','EGO_SECONDARYUOM_INVALID');
   l_secondary_uom_code_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');

   FND_MESSAGE.SET_NAME('EGO','EGO_TRACKING_INVALID');
   l_tracking_qty_ind_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');
   --Bug: 3969593 End

   FND_MESSAGE.SET_NAME('EGO','EGO_STATUS_INVALID');--MLS STatus
   l_inv_item_status_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');
   -- R12C changes for Pack Hierarchy
   FND_MESSAGE.SET_NAME('EGO','EGO_TRADEITEMDESC_INVALID');
   l_tradeitemdesc_err_msg := REPLACE(FND_MESSAGE.GET,'''','''''');

   -----------------------------------------------------------------------
   --Insert the Pre-processed error messages.
   -----------------------------------------------------------------------
   l_dyn_sql := '';
   l_dyn_sql := l_dyn_sql || 'INSERT INTO MTL_INTERFACE_ERRORS ';
   l_dyn_sql := l_dyn_sql || '( ';
   l_dyn_sql := l_dyn_sql || ' ORGANIZATION_ID   ';
   l_dyn_sql := l_dyn_sql || ', UNIQUE_ID    ';
   l_dyn_sql := l_dyn_sql || ', LAST_UPDATE_DATE   ';
   l_dyn_sql := l_dyn_sql || ', LAST_UPDATED_BY  ';
   l_dyn_sql := l_dyn_sql || ', CREATION_DATE    ';
   l_dyn_sql := l_dyn_sql || ', CREATED_BY     ';
   l_dyn_sql := l_dyn_sql || ', LAST_UPDATE_LOGIN  ';
   l_dyn_sql := l_dyn_sql || ', TABLE_NAME     ';
   l_dyn_sql := l_dyn_sql || ', MESSAGE_NAME     ';
   l_dyn_sql := l_dyn_sql || ', COLUMN_NAME    ';
   l_dyn_sql := l_dyn_sql || ', REQUEST_ID     ';
   l_dyn_sql := l_dyn_sql || ', PROGRAM_APPLICATION_ID  ';
   l_dyn_sql := l_dyn_sql || ', PROGRAM_ID     ';
   l_dyn_sql := l_dyn_sql || ', PROGRAM_UPDATE_DATE  ';
   l_dyn_sql := l_dyn_sql || ', ERROR_MESSAGE    ';
   l_dyn_sql := l_dyn_sql || ', TRANSACTION_ID   ';
   l_dyn_sql := l_dyn_sql || ', ENTITY_IDENTIFIER  ';
   l_dyn_sql := l_dyn_sql || ', BO_IDENTIFIER    ';
   l_dyn_sql := l_dyn_sql || ') ';
   l_dyn_sql := l_dyn_sql || 'SELECT ';
   l_dyn_sql := l_dyn_sql || ' -1 ';
   l_dyn_sql := l_dyn_sql || ', MSII.TRANSACTION_ID ';
   l_dyn_sql := l_dyn_sql || ', SYSDATE ';
   l_dyn_sql := l_dyn_sql || ', '||G_USER_ID ;
   l_dyn_sql := l_dyn_sql || ', SYSDATE ';
   l_dyn_sql := l_dyn_sql || ', '||G_USER_ID;
   l_dyn_sql := l_dyn_sql || ', '||G_LOGIN_ID;
   l_dyn_sql := l_dyn_sql || ', ''MTL_SYSTEM_ITEMS_INTERFACE'' ';
   l_dyn_sql := l_dyn_sql || ', DECODE(MSII.PROCESS_FLAG, ';
   l_dyn_sql := l_dyn_sql ||    G_ITEM_CATALOG_NAME_ERR_STS||', ''EGO_ITEMCATALOG_INVALID'', ';
   l_dyn_sql := l_dyn_sql ||    G_PRIMARY_UOM_ERR_STS||', ''EGO_PRIMARYUOM_INVALID'', ';
   l_dyn_sql := l_dyn_sql ||    G_LIFECYCLE_ERR_STS||', ''EGO_LIFECYCLE_INVALID'', ';
   l_dyn_sql := l_dyn_sql ||    G_LIFECYCLE_PHASE_ERR_STS||', ''EGO_LIFECYCLE_PHASE_INVALID'', ';
   l_dyn_sql := l_dyn_sql ||    G_USER_ITEM_TYPE_ERR_STS||', ''EGO_USERITEMTYPE_INVALID'', ';
   l_dyn_sql := l_dyn_sql ||    G_BOM_ITEM_TYPE_ERR_STS||', ''EGO_BOMITEMTYPE_INVALID'', ';
   l_dyn_sql := l_dyn_sql ||    G_TRADE_ITEM_DESC_ERR_STS||', ''EGO_TRADEITEMDESC_INVALID'', ';
   l_dyn_sql := l_dyn_sql ||    G_ENG_ITEM_FLAG_ERR_STS||', ''EGO_ENGITEMFLAG_INVALID'', ';
   l_dyn_sql := l_dyn_sql ||    G_DESCRIPTION_ERR_STS||', ''EGO_ITEMDESC_IS_FG'', '; -- Bug: 3778006
   l_dyn_sql := l_dyn_sql ||    G_CONVERSIONS_ERR_STS||',''EGO_CONVERSIONS_INVALID'', '; --Bug: 3969593 Begin
   l_dyn_sql := l_dyn_sql ||    G_SECONDARY_DEF_IND_ERR_STS||',''EGO_DEFAULTING_INVALID'', ';
   l_dyn_sql := l_dyn_sql ||    G_ONT_PRICING_QTY_SRC_ERR_STS||',''EGO_PRICING_INVALID'', ';
   l_dyn_sql := l_dyn_sql ||    G_SECONDARY_UOM_CODE_ERR_STS||',''EGO_SECONDARYUOM_INVALID'', ';
   l_dyn_sql := l_dyn_sql ||    G_TRACKING_QTY_IND_ERR_STS||',''EGO_TRACKING_INVALID'', '; --Bug: 3969593 End
   l_dyn_sql := l_dyn_sql ||    G_INV_ITEM_STATUS_ERR_STS||',''EGO_STATUS_INVALID'' ';--MLS Status
   l_dyn_sql := l_dyn_sql || '    ) ';
   l_dyn_sql := l_dyn_sql || ', NULL ';
   l_dyn_sql := l_dyn_sql || ', '||G_REQUEST_ID ;
   l_dyn_sql := l_dyn_sql || ', '||G_PROG_APPID ;
   l_dyn_sql := l_dyn_sql || ', '||G_PROG_ID ;
   l_dyn_sql := l_dyn_sql || ', SYSDATE ';
   l_dyn_sql := l_dyn_sql || ', DECODE(MSII.PROCESS_FLAG,  ';
   l_dyn_sql := l_dyn_sql ||      G_ITEM_CATALOG_NAME_ERR_STS ||', EBI.'||G_ITEM_CATALOG_NAME_EBI_COL || ' || '' : '||l_item_catalog_err_msg||''', ';
   l_dyn_sql := l_dyn_sql ||      G_PRIMARY_UOM_ERR_STS||', EBI.'||G_PRIMARY_UOM_EBI_COL || ' || '' : '||l_uom_err_msg||''', ';
   l_dyn_sql := l_dyn_sql ||      G_LIFECYCLE_ERR_STS||',  EBI.'||G_LIFECYCLE_EBI_COL || ' || '' : '||l_lifecycle_err_msg||''', ';
   l_dyn_sql := l_dyn_sql ||      G_LIFECYCLE_PHASE_ERR_STS||',  EBI.'||G_LIFECYCLE_PHASE_EBI_COL || ' || '' : '||l_lifecycle_ph_err_msg||''', ';
   l_dyn_sql := l_dyn_sql ||      G_USER_ITEM_TYPE_ERR_STS||',  EBI.'||G_USER_ITEM_TYPE_EBI_COL || ' || '' : '||l_useritemtype_err_msg||''', ';
   l_dyn_sql := l_dyn_sql ||      G_BOM_ITEM_TYPE_ERR_STS||',  EBI.'||G_BOM_ITEM_TYPE_EBI_COL || ' || '' : '||l_bomitemtype_err_msg||''', ';
   IF l_trade_item_descriptor_col IS NULL THEN
     l_dyn_sql := l_dyn_sql ||    G_TRADE_ITEM_DESC_ERR_STS||',  '''||l_tradeitemdesc_err_msg||''' , ';
   ELSE
     l_dyn_sql := l_dyn_sql ||    G_TRADE_ITEM_DESC_ERR_STS||',  EBI.'||l_trade_item_descriptor_col || ' || '' : '||l_tradeitemdesc_err_msg||''' , ';
   END IF;
   l_dyn_sql := l_dyn_sql ||      G_ENG_ITEM_FLAG_ERR_STS||',  EBI.'||G_ENG_ITEM_FLAG_EBI_COL || ' || '' : '||l_engitemflag_err_msg||''', ';
   l_dyn_sql := l_dyn_sql ||      G_DESCRIPTION_ERR_STS||',  EBI.'||G_DESCRIPTION_EBI_COL || ' || '' : '||l_description_err_msg||''','; -- Bug: 3778006
   l_dyn_sql := l_dyn_sql ||      G_CONVERSIONS_ERR_STS||',  EBI.'||G_CONVERSIONS_EBI_COL || ' || '' : '||l_conversions_err_msg||''','; --Bug: 3969593 Begin
   l_dyn_sql := l_dyn_sql ||      G_SECONDARY_DEF_IND_ERR_STS||',  EBI.'||G_SECONDARY_DEF_IND_EBI_COL || ' || '' : '||l_secondary_def_err_msg||''',';
   l_dyn_sql := l_dyn_sql ||      G_ONT_PRICING_QTY_SRC_ERR_STS||',  EBI.'||G_ONT_PRICING_QTY_SRC_EBI_COL || ' || '' : '||l_ont_pricing_qty_src_err_msg||''',';
   l_dyn_sql := l_dyn_sql ||      G_SECONDARY_UOM_CODE_ERR_STS||',  EBI.'||G_SECONDARY_UOM_CODE_EBI_COL || ' || '' : '||l_secondary_uom_code_err_msg||''',';
   l_dyn_sql := l_dyn_sql ||      G_TRACKING_QTY_IND_ERR_STS||',  EBI.'||G_TRACKING_QTY_IND_EBI_COL || ' || '' : '||l_tracking_qty_ind_err_msg||''','; --Bug: 3969593 End
   --Rathna MLS Status
   IF l_inventory_item_status_col IS NULL THEN
     l_dyn_sql := l_dyn_sql ||    G_INV_ITEM_STATUS_ERR_STS||',  '''||l_inv_item_status_err_msg||'''';
   ELSE
     l_dyn_sql := l_dyn_sql ||    G_INV_ITEM_STATUS_ERR_STS||',  EBI.'||l_inventory_item_status_col || ' || '' : '||l_inv_item_status_err_msg||'''';
   END IF;
   l_dyn_sql := l_dyn_sql || '        )     ';
   l_dyn_sql := l_dyn_sql || ', MSII.TRANSACTION_ID ';
   l_dyn_sql := l_dyn_sql || ', NULL ';
   l_dyn_sql := l_dyn_sql || ', NULL ';
   l_dyn_sql := l_dyn_sql || 'FROM  MTL_SYSTEM_ITEMS_INTERFACE MSII, EGO_BULKLOAD_INTF EBI ';
   l_dyn_sql := l_dyn_sql || 'WHERE MSII.TRANSACTION_ID = EBI.TRANSACTION_ID ';
   l_dyn_sql := l_dyn_sql || ' AND  MSII.SET_PROCESS_ID = '||p_set_process_id;
   l_dyn_sql := l_dyn_sql || ' AND  MSII.PROCESS_FLAG IN  ';
   l_dyn_sql := l_dyn_sql ||  ' ( ';
   l_dyn_sql := l_dyn_sql ||    G_ITEM_CATALOG_NAME_ERR_STS||', ';
   l_dyn_sql := l_dyn_sql ||    G_PRIMARY_UOM_ERR_STS||', ';
   l_dyn_sql := l_dyn_sql ||    G_LIFECYCLE_ERR_STS||', ';
   l_dyn_sql := l_dyn_sql ||    G_LIFECYCLE_PHASE_ERR_STS||', ';
   l_dyn_sql := l_dyn_sql ||    G_USER_ITEM_TYPE_ERR_STS||', ';
   l_dyn_sql := l_dyn_sql ||    G_BOM_ITEM_TYPE_ERR_STS||', ';
   l_dyn_sql := l_dyn_sql ||    G_TRADE_ITEM_DESC_ERR_STS||', ';
   l_dyn_sql := l_dyn_sql ||    G_ENG_ITEM_FLAG_ERR_STS||', ';
   l_dyn_sql := l_dyn_sql ||    G_DESCRIPTION_ERR_STS||', ';
   l_dyn_sql := l_dyn_sql ||    G_CONVERSIONS_ERR_STS||', '; --Bug: 3969593 Begin
   l_dyn_sql := l_dyn_sql ||    G_SECONDARY_DEF_IND_ERR_STS||', ';
   l_dyn_sql := l_dyn_sql ||    G_ONT_PRICING_QTY_SRC_ERR_STS||', ';
   l_dyn_sql := l_dyn_sql ||    G_SECONDARY_UOM_CODE_ERR_STS||', ';
   l_dyn_sql := l_dyn_sql ||    G_TRACKING_QTY_IND_ERR_STS||', '; --Bug: 3969593 End
   l_dyn_sql := l_dyn_sql ||    G_INV_ITEM_STATUS_ERR_STS; --need to store error status as well
   l_dyn_sql := l_dyn_sql ||  ' ) ';
   l_dyn_sql := l_dyn_sql || ' AND  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID ';
   l_dyn_sql := l_dyn_sql || ' AND  EBI.PROCESS_STATUS = 1 ';

   Write_Debug('l_dyn_sql');
   --There is a limit of 1024 BYTES through Write_Debug (it uses
   --UTL_FILE)
     -------------------------------------------------------------------------
     --Fix for Bug# 3624649. (JCGEORGE, PPEDDAMA)
     --Since Typically NLS_LENGTH_SEMANTICS parameter value is BYTE
     -- (in NLS_DATABASE_PARAMETERS table), use SUBSTRB instead of SUBSTR
     -- when fetching possibly MLS strings.
     -------------------------------------------------------------------------
   Write_Debug(SUBSTRB(l_dyn_sql, 1, 1000));
   Write_Debug(SUBSTRB(l_dyn_sql, 1001, 2000));
   EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;

   Write_Debug('MIERR: Inserted Pre-processed error messages in MTL_INTERFACE_ERRORS');

   -----------------------------------------------------------------------
   --Now that the error messages are inserted, update MSII lines to
   --Process status ERROR.
   -----------------------------------------------------------------------

   UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
    SET   MSII.PROCESS_FLAG = G_INTF_STATUS_ERROR
   WHERE  MSII.SET_PROCESS_ID = p_set_process_id
     AND  MSII.PROCESS_FLAG IN
    (
       G_ITEM_CATALOG_NAME_ERR_STS
     , G_PRIMARY_UOM_ERR_STS
     , G_LIFECYCLE_ERR_STS
     , G_LIFECYCLE_PHASE_ERR_STS
     , G_USER_ITEM_TYPE_ERR_STS
     , G_BOM_ITEM_TYPE_ERR_STS
     , G_ENG_ITEM_FLAG_ERR_STS
     , G_DESCRIPTION_ERR_STS -- Bug: 3804572
     , G_CONVERSIONS_ERR_STS --Bug: 3969593 Begin
     , G_SECONDARY_DEF_IND_ERR_STS
     , G_ONT_PRICING_QTY_SRC_ERR_STS
     , G_SECONDARY_UOM_CODE_ERR_STS
     , G_TRACKING_QTY_IND_ERR_STS --Bug: 3969593 End
     , G_INV_ITEM_STATUS_ERR_STS--Rathna MLS Status
     )
     AND  MSII.TRANSACTION_ID IN
     (
      SELECT TRANSACTION_ID
      FROM   EGO_BULKLOAD_INTF
      WHERE  RESULTFMT_USAGE_ID = p_resultfmt_usage_id
      );

   Write_Debug('MSII: Updated all the line statuses to Error for Pre-processing validation errors');

--   DELETE MTL_SYSTEM_ITEMS_INTERFACE MSII
--     WHERE
--     (
--       (
--        ITEM_NUMBER                 IS NOT NULL AND
--        ORGANIZATION_CODE           IS NOT NULL
--       )
--       OR
--       (
--        SOURCE_SYSTEM_REFERENCE           IS NOT NULL AND --for non-PDH Batch
--        SOURCE_SYSTEM_ID           IS NOT NULL       --for non-PDH Batch
--       )
       --In case of CREATE : Item Catalog Group ID will be NOT NULL in MSII
       --In case of SYNC/UPDATE, where Item ID exists, Item Catalog Group ID
       --will be NULL. Hence commenting out, this NOT NULL condn.
       --ITEM_CATALOG_GROUP_ID IS NOT NULL
--       OR
--       (
--        DESCRIPTION IS NULL AND
--        SOURCE_SYSTEM_REFERENCE IS NULL AND
--        SOURCE_SYSTEM_REFERENCE_DESC IS NULL
--       )
--      )
--     AND
--      (
--         DESCRIPTION               IS NULL AND
--         LONG_DESCRIPTION          IS NULL AND
--         PRIMARY_UOM_CODE              IS NULL AND
--         LIFECYCLE_ID                  IS NULL AND
--         CURRENT_PHASE_ID              IS NULL AND
--         INVENTORY_ITEM_STATUS_CODE    IS NULL AND
--         ITEM_TYPE                     IS NULL AND
--         BOM_ITEM_TYPE                 IS NULL AND
--         ENG_ITEM_FLAG                 IS NULL AND
         --Joseph : Bug Fix : 3621826
--         TEMPLATE_ID                   IS NULL AND  --**NEW
--         TEMPLATE_NAME                 IS NULL AND  --**NEW
--         SOURCE_SYSTEM_REFERENCE_DESC  IS NULL AND  -- Bug: 5207217
--         GLOBAL_TRADE_ITEM_NUMBER      IS NULL      -- Bug: 5207217
--        )
--      AND SET_PROCESS_ID = p_set_process_id
       ------------------------------------------------------------------------------------------------
       -- Fix for 11.5.10: Including PROCESS_FLAG status during this DELETE operation.
       --
       -- When ERROR happens during PRIMARY_UOM_CODE processing (NOTE: This is the first
       -- significant Value-to-ID conversion) then MSII.PROCESS_FLAG is set to something
       -- other than 1. Because of this, the subsequent transfer of the Data from EBI to MSII
       -- doesnot happen (as all SQLs check for EBI, MSII Process Status to be 1 for transfer).
       -- So, this DELETE will go through successfully, as all the columns are NULL (other than
       -- ITEM_NUMBER, ORGANIZATION_CODE.)
       -- Then EBI stays in PROCESS_STATUS = 1, which is later converted to 7 in Item_intf_completion.
       --
       -- Because of this User-Defined attrs for those rows are ERRONEOUSLY picked and processed.
       ------------------------------------------------------------------------------------------------
--      AND PROCESS_FLAG = G_PROCESS_STATUS  --Bug 3763665
--      AND (EXISTS(   -- there exists a row where item is being Created or updated in the same request
--                  SELECT 'X'
--                  FROM MTL_SYSTEM_ITEMS_INTERFACE MSI
--                  WHERE MSI.DESCRIPTION IS NOT NULL
--                  AND NVL(MSI.ITEM_NUMBER,FND_API.G_MISS_CHAR) = NVL(MSII.ITEM_NUMBER,FND_API.G_MISS_CHAR)
--                  AND SET_PROCESS_ID = p_set_process_id
--                  AND PROCESS_FLAG = G_PROCESS_STATUS
--                  )
--           OR EXISTS(
--                  SELECT 'X'
--                  FROM MTL_SYSTEM_ITEMS_B MSI
--                  WHERE  MSII.INVENTORY_ITEM_ID  = MSI.INVENTORY_ITEM_ID
--                  AND MSII.ORGANIZATION_ID = MSI.ORGANIZATION_ID
--                  )-- End Bug 3763665
--            );

--   Write_Debug('Preprocess_Item_Interface : NEW Deleted redundant / unnecessary rows from MSII');

   -- Bug: 5519768
   -- ENG_ITEM_FLAG will be defaulted from IOI, so commented the below code
--   IF G_PDH_BATCH THEN
--     -----------------------------------------------------------------------
--     -- Set the ENG_ITEM_FLAG to Y for all the New Items TO-BE Created.
--     -- So, all new Items (if ENG_ITEM_FLAG is unspecified) are created as
--     -- Engineering Items.
--     -----------------------------------------------------------------------
--
--      UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
--        SET   MSII.ENG_ITEM_FLAG = 'Y'
--        WHERE MSII.SET_PROCESS_ID = p_set_process_id
--         AND  MSII.INVENTORY_ITEM_ID IS NULL
--         AND  MSII.TRANSACTION_TYPE IN ('SYNC', 'CREATE')
--         AND  MSII.PROCESS_FLAG = G_PROCESS_STATUS
--         AND  MSII.ENG_ITEM_FLAG IS NULL
--         AND  MSII.ORGANIZATION_ID  = (SELECT ORGANIZATION_ID
--                                       FROM MTL_PARAMETERS MP
--                                       WHERE ORGANIZATION_ID = MSII.ORGANIZATION_ID
--                                       AND ORGANIZATION_ID = MASTER_ORGANIZATION_ID
--                                      );
--Bug 4721682 : not to set the ENG_ITEM_FLAG if the ORGANIZATION IS NOT MASTER ORG
--
--     Write_Debug('Preprocess_Item_Interface : Set Eng Item Flag = Y in case of NULL for New to-be created items.');
--   END IF;

END preprocess_item_interface;


 ----------------------------------------------------------
 --  Setup Item Interface Lines                          --
 ----------------------------------------------------------
PROCEDURE Setup_item_interface
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_caller_identifier     IN         VARCHAR2 DEFAULT EGO_ITEM_BULKLOAD_PKG.G_ITEM,
                 p_set_process_id        IN         NUMBER,
                 x_set_process_id        OUT NOCOPY NUMBER,
                 x_errbuff               OUT NOCOPY VARCHAR2,
                 x_retcode               OUT NOCOPY VARCHAR2
                ) IS

    -- Start OF comments
    -- API name  : Setup MSII Item Interface Lines for processing
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  : Populate and Prepare Item interfance lines.
    --             Eliminates any redundancy / errors in MSII

  l_set_process_id   NUMBER(15);

BEGIN

   ----------------------------------------------
   --  Populates rows in MSII
   ----------------------------------------------
   Developer_Debug('calling load_item_interface');
   load_item_interface(
        p_resultfmt_usage_id  => p_resultfmt_usage_id
       ,p_set_process_id      => p_set_process_id
       ,x_set_process_id      => l_set_process_id
       ,p_caller_identifier   => p_caller_identifier
       ,x_errbuff             => x_errbuff
       ,x_retcode             => x_retcode
            );
   Developer_Debug('returning with retcode'||x_retcode);

   -----------------------------------------------------
   -- Deletes redundant / unnecessary rows from MSII.
   -----------------------------------------------------
   preprocess_item_interface(
        p_resultfmt_usage_id  => p_resultfmt_usage_id
       ,p_set_process_id      => l_set_process_id
       ,p_caller_identifier   => p_caller_identifier
       ,x_errbuff             => x_errbuff
       ,x_retcode             => x_retcode
            );

   x_set_process_id := l_set_process_id;
   Write_Debug('Setup_Item_Interface : Set Process Id => '||x_set_process_id);

 EXCEPTION
   WHEN OTHERS THEN
      x_retcode := G_STATUS_ERROR;
      x_errbuff := SUBSTRB(SQLERRM, 1,240);
      Write_Debug('Setup_Item_Interface : EXCEPTION HAPPENED => '||x_errbuff);
      RAISE;

END setup_item_interface;


 -------------------------------------------------------------------
 --  Change Item Interface Lines process statuses as completed.   --
 --  Statuses represent: Warning, Error, Success etc.,            --
 -------------------------------------------------------------------
PROCEDURE Item_intf_completion
  (
    p_resultfmt_usage_id     IN    NUMBER
  , x_errbuff                OUT NOCOPY  VARCHAR2
  , x_retcode                OUT NOCOPY  VARCHAR2
    ) IS

  -----------------------------------------------
  -- Long Dynamic SQL String
  -----------------------------------------------
  l_dyn_sql                VARCHAR2(10000);

BEGIN

   -----------------------------------------------------------------
   -- Update EBI, with the process status of rows in MSII after
   -- the completion of IOI processing.
   -----------------------------------------------------------------
   UPDATE EGO_BULKLOAD_INTF EBI
     SET  EBI.PROCESS_STATUS =
     (
      SELECT MSII.PROCESS_FLAG
      FROM   MTL_SYSTEM_ITEMS_INTERFACE MSII
      WHERE  MSII.TRANSACTION_ID = EBI.TRANSACTION_ID
      )
     WHERE EXISTS
     (
      SELECT 'X'
      FROM   MTL_SYSTEM_ITEMS_INTERFACE MSII
      WHERE  MSII.TRANSACTION_ID = EBI.TRANSACTION_ID
      )
     AND EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id;

   ----------------------------------------------------------------------------
   --Update all the lines in EGO_BULKLOAD_INTF as failure, for which
   --The Inventory Item IDs were not available.
   --1. For Transaction Type : CREATE, Item ID should be populated
   --   at the end of Processing
   --2. For Transaction Type : SYNC / UPDATE, Item ID should be
   --   retrieved during processing.
   ----------------------------------------------------------------------------
-- R12: this is not required
--   UPDATE EGO_BULKLOAD_INTF EBI
--     SET  EBI.PROCESS_STATUS = G_INTF_STATUS_ERROR
--     WHERE EXISTS
--     (
--      SELECT 'X'
--      FROM   MTL_SYSTEM_ITEMS_INTERFACE MSII
--      WHERE  MSII.TRANSACTION_ID = EBI.TRANSACTION_ID
--       AND   MSII.PROCESS_FLAG   = G_INTF_STATUS_SUCCESS
--       AND   MSII.INVENTORY_ITEM_ID IS NULL
--      )
--     AND EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id;

   ----------------------------------------------------------------------------
   -- Update all the lines in EGO_BULKLOAD_INTF as SUCCESS
   -- for these rows were used to populate Multi-Row
   -- Appropriate errors will be displayed by the User-Defined Attrs Import
   -- processing later.
   ----------------------------------------------------------------------------
   UPDATE EGO_BULKLOAD_INTF EBI
     SET  EBI.PROCESS_STATUS = G_INTF_STATUS_SUCCESS
     WHERE EBI.PROCESS_STATUS = G_INTF_STATUS_TOBE_PROCESS
     AND EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id;

   ----------------------------------------------------------------------------
   -- Update the Item IDs (Doesnt matter Create or Update, because
   -- Item IDs will be populated either way in MSII) in
   -- Generic Bulkload Intf table (EGO_BULKLOAD_INTF)
   -- These Item IDs are required for Item User-Defined Attrs bulkload
   ----------------------------------------------------------------------------
   UPDATE EGO_BULKLOAD_INTF EBI
     SET  EBI.INSTANCE_PK1_VALUE =
     (
      SELECT MSII.INVENTORY_ITEM_ID
      FROM   MTL_SYSTEM_ITEMS_INTERFACE MSII
      WHERE  MSII.TRANSACTION_ID = EBI.TRANSACTION_ID
      )
     WHERE EXISTS
     (
      SELECT 'X'
      FROM   MTL_SYSTEM_ITEMS_INTERFACE MSII
      WHERE  MSII.TRANSACTION_ID = EBI.TRANSACTION_ID
      )
     AND EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id
     AND EBI.PROCESS_STATUS = G_INTF_STATUS_SUCCESS;

   Write_Debug('EBI: Updated the Process_Status to Indicate Succssful/Unsucessful completion.');

   x_retcode := G_STATUS_SUCCESS;

 EXCEPTION
   WHEN OTHERS THEN
      x_retcode := G_STATUS_ERROR;
      x_errbuff := SUBSTRB(SQLERRM, 1,240);
      Write_Debug('Item_Intf_Completion : EXCEPTION HAPPENED => '||x_errbuff);
      RAISE;

END Item_Intf_Completion;

 ----------------------------------------------------------
 -- Populate Item Revision Interface Lines               --
 ----------------------------------------------------------

PROCEDURE load_item_revs_interface
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_caller_identifier     IN         VARCHAR2 DEFAULT EGO_ITEM_BULKLOAD_PKG.G_ITEM,
                 p_data_level            IN         VARCHAR2,
                 p_set_process_id        IN         NUMBER,
                 x_set_process_id        OUT NOCOPY NUMBER,
                 x_errbuff               OUT NOCOPY VARCHAR2,
                 x_retcode               OUT NOCOPY VARCHAR2
                ) IS

    -- Start OF comments
    -- API name  : Populate MTL_ITEM_REVISIONS_INTERFACE table
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  : Populate and Load Item Revisions interfance lines.
    --             Loads Item Revision Attr Values
    --             Errors are populated in MTL_INTERFACE_ERRORS
       --

  ------------------------------------------------------------------------------------------
  -- To get the Item Revision Base attr columns in the Result Format.
  -- NOTE: Only one of the SELECTs below will be active at a time, based on the Data Level.
  ------------------------------------------------------------------------------------------
  CURSOR c_item_rev_attr_intf_cols (c_resultfmt_usage_id  IN  NUMBER) IS
    --Item Revision Data Level
    SELECT attribute_code, intf_column_name
    FROM   ego_results_fmt_usages
    WHERE  resultfmt_usage_id = c_resultfmt_usage_id
     AND   attribute_code NOT LIKE '%$$%'
     ---------------------------------------------------------------------------
     -- Added NOT LIKE 'GTIN_%' to filter out Dummy Attrs for Attr Group: "GTIN"
     ---------------------------------------------------------------------------
     AND   attribute_code NOT LIKE 'GTIN_%'
     AND   p_data_level = G_ITEM_REV_DATA_LEVEL
   UNION
    -------------------
    --Item Data Level
    -------------------
    SELECT attribute_code, intf_column_name
    FROM   ego_results_fmt_usages
    WHERE  resultfmt_usage_id = c_resultfmt_usage_id
     AND   attribute_code NOT LIKE '%$$%'
     ---------------------------------------------------------------------------
     -- Added NOT LIKE 'GTIN_%' to filter out Dummy Attrs for Attr Group: "GTIN"
     ---------------------------------------------------------------------------
     AND   attribute_code NOT LIKE 'GTIN_%'
     AND   p_data_level = G_ITEM_DATA_LEVEL
     AND (
     attribute_code IN -- Segregating Item Revision Base Attributes using this clause
      (
        select LOOKUP_CODE CODE
        from   FND_LOOKUP_VALUES
        where  LOOKUP_TYPE = 'EGO_ITEM_REV_HDR_ATTR_GRP'
        AND    LANGUAGE = USERENV('LANG')
        AND    ENABLED_FLAG = 'Y'
        and LOOKUP_CODE not in ('REVISION_CREATION_DATE', 'REVISION_CREATED_BY')
     )
     OR
     attribute_code = G_REV_EFF_DATE_ATTR_CODE
     -- Bug 6186037
     --accomodate for revision effective date which doest exist in EGO_ITEM_REV_HDR_ATTR_GRP and cannot be included

     );

  --------------------------------------------------------------------------
  -- To check if the given Set Process ID already exists in MSII.
  --------------------------------------------------------------------------
  CURSOR c_msii_set_id_exists(c_set_process_id IN NUMBER) IS
    SELECT 'x'
    FROM mtl_system_items_interface
    WHERE set_process_id = c_set_process_id;

  ---------------------------------------------------------------------
  -- Type Declarations
  ---------------------------------------------------------------------
  TYPE VARCHAR_TBL_TYPE IS TABLE OF VARCHAR2(256)
   INDEX BY BINARY_INTEGER;

               -------------------------
               --   local variables   --
               -------------------------
  l_prod_col_name_tbl               VARCHAR_TBL_TYPE;
  l_intf_col_name_tbl               VARCHAR_TBL_TYPE;

  l_prod_col_name       VARCHAR2(256);
  l_intf_col_name       VARCHAR2(256);

  ---------------------------------------------------------------------
  -- Assuming that the column name will not be more than 30 chars.
  ---------------------------------------------------------------------
  l_item_number_col        VARCHAR2(30);
  l_org_code_col           VARCHAR2(30);
  l_rev_code_col           VARCHAR2(30);
  l_lifecycle_col_val        VARCHAR2(50);
  l_lifecycle_phase_col_val  VARCHAR2(50);
  l_inventory_item_id      MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE;
  l_item_catalog_name_col   VARCHAR2(50);

  l_msii_set_process_id    NUMBER;
  i                        NUMBER;
  l_cursor_select     INTEGER;
  l_cursor_execute    INTEGER;

  l_item_number_table   DBMS_SQL.VARCHAR2_TABLE;
  l_org_id_table        DBMS_SQL.NUMBER_TABLE;
  l_temp                  NUMBER(10) := 1;
  l_count               NUMBER := 0;
  l_exists              VARCHAR2(2);

  l_trans_id_table      DBMS_SQL.NUMBER_TABLE;

  --------------------------------------------
  -- Long Dynamic SQL String
  --------------------------------------------
  l_dyn_sql                VARCHAR2(10000);

BEGIN
   Write_Debug('*Item Revisions Interface*');

   Write_Debug('About to populate the EBI with Trans IDs');

   --------------------------------------------------------------------
   --Populate the Transaction IDs for current Result fmt usage ID
   --------------------------------------------------------------------
   -- Bug: 3804572 - Error messages are not shown, if import format contains revision attrs.
   -- this was happening because the error was logged with a previous transaction id and
   -- here a new transaction id was updated to Bulkload interface table.
   IF p_data_level <> G_ITEM_DATA_LEVEL THEN
     UPDATE ego_bulkload_intf
       SET  transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
     WHERE  resultfmt_usage_id = p_resultfmt_usage_id;
   END IF;

   Write_Debug('Retrieving the Display and INTF cols');
   i := 0;
   --------------------------------------------------------------------
   -- Saving the column names in local table for easy retrieval later.
   -- Also save important columns such as Item ID, Org ID etc.,
   --------------------------------------------------------------------
   FOR c_item_rev_attr_intf_rec IN c_item_rev_attr_intf_cols
     (
       p_resultfmt_usage_id
      )
   LOOP

     l_prod_col_name := c_item_rev_attr_intf_rec.attribute_code;
     l_intf_col_name := c_item_rev_attr_intf_rec.intf_column_name;

     Write_Debug('The caller identity is : '|| p_caller_identifier);
     Write_Debug('p_data_level =>: '|| p_data_level);

      --------------------------------------------------------------------
      -- If the Caller Identifer is G_ITEM, then save the column info.
      --------------------------------------------------------------------
     IF (p_caller_identifier = EGO_ITEM_BULKLOAD_PKG.G_ITEM) THEN

      --------------------------------------------------------------------
      -- Store the Item Number column name in the Generic Interface
      --------------------------------------------------------------------
      IF (l_prod_col_name = G_ITEM_NUMBER) THEN
        l_item_number_col := l_intf_col_name;
        Write_Debug('Item Number : '||l_item_number_col);

      --------------------------------------------------------------------
      -- Store the Organization Code column name in the Generic Interface
      --------------------------------------------------------------------
      ELSIF (l_prod_col_name = G_ORG_CODE) THEN
        l_org_code_col := l_intf_col_name;
        Write_Debug('Organization Code : '||l_org_code_col);

      --------------------------------------------------------------------
      --Saving the Rest of column names.
      --------------------------------------------------------------------
      ELSIF (l_prod_col_name IN (G_ITEM_CATALOG_GROUP,G_ITEM_CATALOG_GROUP1)) THEN
          l_item_catalog_name_col := l_intf_col_name;

      ELSE
        ---------------------------------------------------------------------
        -- Mapping the Revision Attribute Code to the Database Column.
        ---------------------------------------------------------------------
      IF (l_prod_col_name =  G_REV_CODE_ATTR_CODE) THEN
          l_prod_col_name_tbl(i) := G_REV_CODE_DB_COL;
          ------------------------------------------
          -- Saving the intf col name for Rev Code.
          ------------------------------------------
          l_rev_code_col :=  l_intf_col_name;
        ELSIF (l_prod_col_name =  G_REV_LABEL_ATTR_CODE) THEN
          l_prod_col_name_tbl(i) := G_REV_LABEL_DB_COL;
        ELSIF (l_prod_col_name =  G_REV_DESCRIPTION_ATTR_CODE) THEN
          l_prod_col_name_tbl(i) := G_REV_DESCRIPTION_DB_COL;
        ELSIF (l_prod_col_name =  G_REV_REASON_ATTR_CODE) THEN
          l_prod_col_name_tbl(i) := G_REV_REASON_DB_COL;
        ELSIF (l_prod_col_name =  G_REV_LC_ID_ATTR_CODE) THEN
          l_prod_col_name_tbl(i) := G_REV_LC_ID_DB_COL;
        ELSIF (l_prod_col_name =  G_REV_LC_PHASE_ID_ATTR_CODE) THEN
          l_prod_col_name_tbl(i) := G_REV_LC_PHASE_ID_DB_COL;
        ELSIF (l_prod_col_name =  G_REV_IMPL_DATE_ATTR_CODE) THEN
          l_prod_col_name_tbl(i) := G_REV_IMPL_DATE_DB_COL;
        ELSIF (l_prod_col_name =  G_REV_EFF_DATE_ATTR_CODE OR
               l_prod_col_name =  G_REV_EFF_DATE_ATTR_CODE_2 ) THEN
          l_prod_col_name_tbl(i) := G_REV_EFF_DATE_DB_COL;
        ELSIF (l_prod_col_name =  G_REV_ID_ATTR_CODE) THEN
          NULL; --do nothing
        ELSE
          ---------------------------------------------------------
          -- The Attribute Code and DB Column name are the same.
          ---------------------------------------------------------
          l_prod_col_name_tbl(i) := l_prod_col_name;
        END IF;

        l_intf_col_name_tbl(i) := l_intf_col_name;

      END IF; --IF (l_prod_col_name = G_ITEM_NUMBER) THEN

    END IF; --IF (p_caller_identifier = EGO_ITEM_BULKLOAD_PKG.G_ITEM)
     Write_Debug('^^l_prod_col_name_tbl('||i||') : '||l_prod_col_name_tbl(i));
     Write_Debug('^^l_intf_col_name_tbl('||i||') : '||l_intf_col_name_tbl(i));
     i := i+1;

   END LOOP; --FOR c_item_rev_attr_intf_rec

   ---------------------------------------------------------------------
   -- All the following need not be executed if Revision Update       --
   -- is done through Item Search Results.                            --
   ---------------------------------------------------------------------
   IF p_data_level = G_ITEM_REV_DATA_LEVEL THEN

     Write_Debug('Updating EBI with Org IDs');

     ---------------------------------------------
     -- Update Instance PK2 Value with ORG ID.  --
     ---------------------------------------------
     l_dyn_sql :=              ' UPDATE EGO_BULKLOAD_INTF EBI ';
     l_dyn_sql := l_dyn_sql || ' SET INSTANCE_PK2_VALUE = ';
     l_dyn_sql := l_dyn_sql || '  ( ';
     l_dyn_sql := l_dyn_sql || '      SELECT ORGANIZATION_ID      ';
     l_dyn_sql := l_dyn_sql || '      FROM     MTL_PARAMETERS     ';
     l_dyn_sql := l_dyn_sql || '      WHERE  ORGANIZATION_CODE = EBI.'||l_org_code_col;
     l_dyn_sql := l_dyn_sql || '   ) ';
     l_dyn_sql := l_dyn_sql || 'WHERE  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
     l_dyn_sql := l_dyn_sql || ' AND     PROCESS_STATUS = 1                                   ';

     Write_Debug(l_dyn_sql);
     EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
     Write_Debug('Selecting Org IDs, Item Numbers');

     ---------------------------------------------------------------------
     -- Update EBI with Catalog Group Name if present in the Result Format
     ---------------------------------------------------------------------
     IF l_item_catalog_name_col IS NOT NULL THEN
       l_dyn_sql :=              ' UPDATE EGO_BULKLOAD_INTF ';
       l_dyn_sql := l_dyn_sql || ' SET  ';
       l_dyn_sql := l_dyn_sql || G_ITEM_CATALOG_NAME_EBI_COL||' = '||l_item_catalog_name_col ;
       l_dyn_sql := l_dyn_sql || ' WHERE RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
       l_dyn_sql := l_dyn_sql || ' AND   PROCESS_STATUS = 1  ';
       Write_Debug(l_dyn_sql);

       EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
       Write_Debug('Updated EBI with Catalog Group Name for Item Revisions');
     END IF;

     --------------------------------------------------------------
     -- Fetch Organization ID, Item Number in Temp PLSQL tables.
     --------------------------------------------------------------
     l_dyn_sql :=              ' SELECT INSTANCE_PK2_VALUE, '||l_item_number_col || ', ';
     l_dyn_sql := l_dyn_sql || ' TRANSACTION_ID           ';
     l_dyn_sql := l_dyn_sql || ' FROM  EGO_BULKLOAD_INTF ';
     l_dyn_sql := l_dyn_sql || ' WHERE RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
     l_dyn_sql := l_dyn_sql || ' AND   PROCESS_STATUS = 1                                   ';
     Write_Debug(l_dyn_sql);

     l_cursor_select := DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.PARSE(l_cursor_select, l_dyn_sql, DBMS_SQL.NATIVE);
     DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 1,l_org_id_table,2500, l_temp);
     DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 2,l_item_number_table,2500, l_temp);
     DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 3,l_trans_id_table,2500, l_temp);
     DBMS_SQL.BIND_VARIABLE(l_cursor_select,':RESULTFMT_USAGE_ID', p_resultfmt_usage_id);
     l_cursor_execute := DBMS_SQL.EXECUTE(l_cursor_select);
     Write_Debug('About to start the Loop to fetch Rows');

     LOOP
       l_count := DBMS_SQL.FETCH_ROWS(l_cursor_select);
       DBMS_SQL.COLUMN_VALUE(l_cursor_select, 1, l_org_id_table);
       DBMS_SQL.COLUMN_VALUE(l_cursor_select, 2, l_item_number_table);
       DBMS_SQL.COLUMN_VALUE(l_cursor_select, 3, l_trans_id_table);

       Write_Debug('Retrieved rows => '||To_char(l_count));

       -------------------------------------------------------------
       -- Loop to Update the Inventory Item IDs.
       -------------------------------------------------------------
       FOR i IN 1..l_org_id_table.COUNT LOOP

         Write_Debug('Org ID : '||To_char(l_org_id_table(i)));
         Write_Debug('Inv Item Num : '||l_item_number_table(i));

         -------------------------------------------------------------
         -- Invoke FND Key Flex API to fetch the Inventory Item ID.
         -- If Inventory Item ID found, then update in EBI.
         -------------------------------------------------------------
         IF FND_FLEX_KEYVAL.Validate_Segs
         (  operation         =>  'FIND_COMBINATION'
         ,  appl_short_name   =>  'INV'
         ,  key_flex_code     =>  'MSTK'
         ,  structure_number  =>  101
         ,  concat_segments   =>  l_item_number_table(i)
         ,  data_set          =>  l_org_id_table(i)
         )
         THEN
           l_inventory_item_id := FND_FLEX_KEYVAL.combination_id;

           Write_Debug('Inv Item ID : '||To_char(l_inventory_item_id));

           l_dyn_sql :=              ' UPDATE EGO_BULKLOAD_INTF ';
           l_dyn_sql := l_dyn_sql || ' SET  INSTANCE_PK1_VALUE  = '||l_inventory_item_id;
           l_dyn_sql := l_dyn_sql || ' WHERE INSTANCE_PK2_VALUE = '||l_org_id_table(i);
           l_dyn_sql := l_dyn_sql || ' AND '|| l_item_number_col|| ' = :ITEM_NUMBER';
           l_dyn_sql := l_dyn_sql || ' AND  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || ' AND  PROCESS_STATUS = 1 ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING l_item_number_table(i), p_resultfmt_usage_id;

         END IF; --IF FND_FLEX_KEYVAL..

         Write_Debug('G_CATALOG_GROUP_ID => '||G_CATALOG_GROUP_ID);
         -----------------------------------------------------------------
         -- Setting Category ID for Item Revision Flow.
         -- Bug #5179741(RSOUNDAR)
         -----------------------------------------------------------------
         IF G_CATALOG_GROUP_ID IS NULL THEN
           IF l_item_catalog_name_col IS NOT NULL THEN
             l_dyn_sql :=              ' UPDATE EGO_BULKLOAD_INTF EBI';
             l_dyn_sql := l_dyn_sql || ' SET '||G_ITEM_CATALOG_EBI_COL||' = ';
             l_dyn_sql := l_dyn_sql || '( ';
             l_dyn_sql := l_dyn_sql || '    SELECT TO_CHAR(MICG.ITEM_CATALOG_GROUP_ID) ';
             l_dyn_sql := l_dyn_sql || '    FROM   MTL_ITEM_CATALOG_GROUPS_B_KFV MICG  ';
             l_dyn_sql := l_dyn_sql || '    WHERE  MICG.CONCATENATED_SEGMENTS = EBI.'||l_item_catalog_name_col;
             l_dyn_sql := l_dyn_sql || ') ';
             l_dyn_sql := l_dyn_sql || ' WHERE EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
             l_dyn_sql := l_dyn_sql || ' AND EBI.'||l_item_catalog_name_col||' IS NOT NULL';
             l_dyn_sql := l_dyn_sql || ' AND EBI.PROCESS_STATUS = 1  ';
             Write_Debug(l_dyn_sql);
             EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
           ELSE -- l_item_catalog_name_col IS NULL
             -- no need to do anything here
             NULL;
           END IF; -- l_item_catalog_name_col IS NOT NULL
         ELSE  -- G_CATALOG_GROUP_ID IS NOT NULL

           l_dyn_sql := ' UPDATE EGO_BULKLOAD_INTF ';
           -------------------------------------------------------------
           --Storing Catalog Group ID and other imp data in buffer cols
           -------------------------------------------------------------
           l_dyn_sql := l_dyn_sql || ' SET  '||G_ITEM_CATALOG_EBI_COL||' = '||G_CATALOG_GROUP_ID;
           l_dyn_sql := l_dyn_sql || ' WHERE INSTANCE_PK2_VALUE = :ORGANIZATION_ID ';
           l_dyn_sql := l_dyn_sql || ' AND  TRANSACTION_ID = :TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || ' AND  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || ' AND   PROCESS_STATUS = 1  ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING l_org_id_table(i), l_trans_id_table(i), p_resultfmt_usage_id;

         END IF;--end: IF (G_CATALOG_GROUP_ID IS NULL)

       END LOOP; --FOR i IN 1..l_org_id_table.COUNT LOOP

       l_org_id_table.DELETE;
       l_item_number_table.DELETE;

       -----------------------------------------------------------------
       -- For the final batch of records, either it will be 0 or < 2500
       -----------------------------------------------------------------
       EXIT WHEN l_count <> 2500;

     END LOOP; --l_count := DBMS_SQL.FETCH_ROWS(l_cursor_select);

     DBMS_SQL.CLOSE_CURSOR(l_cursor_select);

     Write_Debug('Done with Item IDs population.');

     -----------------------------------------------------------------
     -- Determine the Set Process ID, that is unique for MSII
     -----------------------------------------------------------------
     IF p_set_process_id IS NULL THEN
       SELECT mtl_system_items_intf_sets_s.NEXTVAL
         INTO l_msii_set_process_id
       FROM dual;
     ELSE
       l_msii_set_process_id := p_set_process_id;
     END IF;

     ---------------------------------------------------------------------
     -- END: All the above need not be executed if Revision Update      --
     -- is done through Item Search Results.                            --
     ---------------------------------------------------------------------

   ELSE --p_data_level = G_ITEM_DATA_LEVEL

     Write_Debug('Item Rev Intf using the Set Process ID used by Item Interface');

     ----------------------------------------------------------------------------
     -- Using the Set Process ID used by Item Interface, as Revs are updated
     -- as part of Item Search Results.
     ----------------------------------------------------------------------------
     l_msii_set_process_id := G_MSII_SET_PROCESS_ID;

     ----------------------------------------------------------------------------
     -- During Item processing itself, ITEM_NUMBER and ORG_CODE are loaded
     -- in following columns.
     ----------------------------------------------------------------------------
     l_item_number_col := G_ITEM_NUMBER_EBI_COL;
     l_org_code_col := G_ORG_CODE_EBI_COL;

   END IF; --end: IF p_data_level = G_ITEM_REV_DATA_LEVEL

   Write_Debug('l_msii_set_process_id : '||To_char(l_msii_set_process_id));

   -----------------------------------------------------------------
   -- Insert rows from EBI into MSII
   -----------------------------------------------------------------
   l_dyn_sql :=              'INSERT INTO MTL_ITEM_REVISIONS_INTERFACE ';
   l_dyn_sql := l_dyn_sql || '( ';
   l_dyn_sql := l_dyn_sql || ' SET_PROCESS_ID        ,   ';
   l_dyn_sql := l_dyn_sql || ' TRANSACTION_ID        ,   ';
   l_dyn_sql := l_dyn_sql || ' REQUEST_ID            ,   ';
   l_dyn_sql := l_dyn_sql || ' PROGRAM_APPLICATION_ID,   ';
   l_dyn_sql := l_dyn_sql || ' PROGRAM_ID            ,   ';
   l_dyn_sql := l_dyn_sql || ' TRANSACTION_TYPE      ,   ';
   l_dyn_sql := l_dyn_sql || ' INVENTORY_ITEM_ID     ,   ';
   l_dyn_sql := l_dyn_sql || ' ORGANIZATION_ID       ,   ';
   l_dyn_sql := l_dyn_sql || ' ITEM_NUMBER           ,   ';
   l_dyn_sql := l_dyn_sql || ' ORGANIZATION_CODE     ,   ';
   l_dyn_sql := l_dyn_sql || ' PROCESS_FLAG          ,   ';
   l_dyn_sql := l_dyn_sql || ' SOURCE_SYSTEM_ID      ,   ';
   l_dyn_sql := l_dyn_sql || ' SOURCE_SYSTEM_REFERENCE   ';
   l_dyn_sql := l_dyn_sql || ') ';
   l_dyn_sql := l_dyn_sql || 'SELECT ';
   l_dyn_sql := l_dyn_sql ||  To_char(l_msii_set_process_id)||' , ';
   l_dyn_sql := l_dyn_sql || ' EBI.TRANSACTION_ID       , ';
   l_dyn_sql := l_dyn_sql || G_REQUEST_ID||' , ';
   l_dyn_sql := l_dyn_sql || G_PROG_APPID||' , ';
   l_dyn_sql := l_dyn_sql || G_PROG_ID||' , ';
   l_dyn_sql := l_dyn_sql || ' UPPER(EBI.TRANSACTION_TYPE)  , ';
   l_dyn_sql := l_dyn_sql || ' EBI.INSTANCE_PK1_VALUE   , ';
   l_dyn_sql := l_dyn_sql || ' EBI.INSTANCE_PK2_VALUE   , ';
   l_dyn_sql := l_dyn_sql || ' EBI.'||l_item_number_col ||' , ';
   l_dyn_sql := l_dyn_sql || ' EBI.'||l_org_code_col ||' , ';
   l_dyn_sql := l_dyn_sql || G_PROCESS_STATUS    ||' , ';
   l_dyn_sql := l_dyn_sql || ' TO_NUMBER(EBI.C_FIX_COLUMN11) , ';
   l_dyn_sql := l_dyn_sql || ' EBI.C_FIX_COLUMN12       ';
   l_dyn_sql := l_dyn_sql || 'FROM EGO_BULKLOAD_INTF EBI ';
   l_dyn_sql := l_dyn_sql || ' WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
   l_dyn_sql := l_dyn_sql || ' AND   EBI.PROCESS_STATUS = 1  ';

   Write_Debug(l_dyn_sql);
   EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
   Write_Debug('Item Revs Interface: Populated the Inv Item IDs, Org IDs.');

   ----------------------------------------------------------------------------------
   --Save Item Num, Org Code in designated columns in EBI for Error Reporting later
   ----------------------------------------------------------------------------------
   l_dyn_sql :=              ' UPDATE EGO_BULKLOAD_INTF ';
   l_dyn_sql := l_dyn_sql || ' SET  ';
   -----------------------------------------------------------------------------------------
   -- In case of ITEM_LEVEL the following is already populated in load_item_interface_lines
   -- procedure.
   -----------------------------------------------------------------------------------------
   IF p_data_level = G_ITEM_REV_DATA_LEVEL THEN
     l_dyn_sql := l_dyn_sql || G_ITEM_NUMBER_EBI_COL||' = '||l_item_number_col||' , ';
     l_dyn_sql := l_dyn_sql || G_ORG_CODE_EBI_COL||' = '||l_org_code_col ||' , ';
   END IF;

   l_dyn_sql := l_dyn_sql || G_REVISION_CODE_EBI_COL||' = '||l_rev_code_col;
   l_dyn_sql := l_dyn_sql || ' WHERE RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
   l_dyn_sql := l_dyn_sql ||   ' AND PROCESS_STATUS = 1 ';

   Write_Debug(l_dyn_sql);
   EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
   Write_Debug('Item Revs Interface: Done saving Item Num, Org Code, Rev Code in EBI for error retrieval later.');

   ---------------------------------------
   -- Reset i back to 0, for re-use.
   ---------------------------------------
   i := 0;
   IF ( l_prod_col_name_tbl.count > 0) THEN
      FOR i IN l_prod_col_name_tbl.first .. l_prod_col_name_tbl.last LOOP
        Write_Debug('*l_prod_col_name_tbl(i)'||l_prod_col_name_tbl(i));
        Write_Debug('*l_intf_col_name_tbl(i)'||l_intf_col_name_tbl(i));

        IF (l_prod_col_name_tbl(i) = G_REV_REASON_DB_COL) THEN

          ----------------------------------------------------------------------------------
          --  Transfer the Revision Reason information from EBI to MIRI
          --  by doing Value-to-ID Conversion.
          ----------------------------------------------------------------------------------
          l_dyn_sql := '';
          l_dyn_sql := l_dyn_sql || 'UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI ';
          l_dyn_sql := l_dyn_sql || ' SET   MIRI.'||G_REV_REASON_DB_COL||' =  ';
          l_dyn_sql := l_dyn_sql || '( ';
          l_dyn_sql := l_dyn_sql || '    SELECT IT.LOOKUP_CODE ';
          l_dyn_sql := l_dyn_sql || '    FROM   FND_LOOKUP_VALUES IT, EGO_BULKLOAD_INTF EBI ';
          l_dyn_sql := l_dyn_sql || '    WHERE  IT.LOOKUP_TYPE = ''EGO_ITEM_REVISION_REASON'' ';
          l_dyn_sql := l_dyn_sql || '     AND   IT.LANGUAGE = Userenv(''LANG'') ';
          l_dyn_sql := l_dyn_sql || '     AND   IT.MEANING = EBI.'||l_intf_col_name_tbl(i);
          l_dyn_sql := l_dyn_sql || '     AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
          l_dyn_sql := l_dyn_sql || '     AND   EBI.TRANSACTION_ID = MIRI.TRANSACTION_ID ';
          ----------------------------------------------------------------------------------
          --  WHERE EXISTS takes care of filtering lines. Hence this join not needed.
          --  l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
          ----------------------------------------------------------------------------------
          l_dyn_sql := l_dyn_sql || ') ';
          l_dyn_sql := l_dyn_sql || ' WHERE EXISTS ';
          l_dyn_sql := l_dyn_sql || '( ';
          l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
          l_dyn_sql := l_dyn_sql || '    FROM   FND_LOOKUP_VALUES IT, EGO_BULKLOAD_INTF EBI ';
          l_dyn_sql := l_dyn_sql || '    WHERE  IT.LOOKUP_TYPE = ''EGO_ITEM_REVISION_REASON'' ';
          l_dyn_sql := l_dyn_sql || '     AND   IT.LANGUAGE = Userenv(''LANG'') ';
          l_dyn_sql := l_dyn_sql || '     AND   IT.MEANING = EBI.'||l_intf_col_name_tbl(i);
          l_dyn_sql := l_dyn_sql || '     AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
          l_dyn_sql := l_dyn_sql || '     AND    EBI.TRANSACTION_ID = MIRI.TRANSACTION_ID ';
          l_dyn_sql := l_dyn_sql || '     AND    EBI.PROCESS_STATUS = 1  ';
          l_dyn_sql := l_dyn_sql || ') ';

          Write_Debug(l_dyn_sql);
          EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;
          Write_Debug('MIRI: Updated the Revision Reason Codes.');

        ----------------------------------------------------------------------------------
        --  Bug# 3421497 fix.
        --  If Lifecycle ID or Lifecycle Phase ID, save column information, and process
        --  later in the sequence, as Lifecycle Phase ID Value-to-ID conversion is
        --  dependant upon the Lifecycle ID value.
        ----------------------------------------------------------------------------------
        ELSIF (l_prod_col_name_tbl(i) = G_LIFECYCLE) THEN

          l_lifecycle_col_val := l_intf_col_name_tbl(i);

        ----------------------------------------------------------------------------------
        --  Bug# 3421497 fix.
        --  If Lifecycle ID or Lifecycle Phase ID, save column information, and process
        --  later in the sequence, as Lifecycle Phase ID Value-to-ID conversion is
        --  dependant upon the Lifecycle ID value.
        ----------------------------------------------------------------------------------
        ELSIF (l_prod_col_name_tbl(i) = G_LIFECYCLE_PHASE) THEN

          l_lifecycle_phase_col_val := l_intf_col_name_tbl(i);

        ----------------------------------------------------------------------------------
        --  Transfer the Column information from EBI to MSII
        --  which *DONOT NEED* Value-to-ID Conversion.
        ----------------------------------------------------------------------------------
        ELSE

          l_dyn_sql := '';
          l_dyn_sql := l_dyn_sql || 'UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI ';
          l_dyn_sql := l_dyn_sql || ' SET   MIRI.'||l_prod_col_name_tbl(i) ||' =  ';
          l_dyn_sql := l_dyn_sql || '( ';
          l_dyn_sql := l_dyn_sql || '    SELECT EBI.'||l_intf_col_name_tbl(i);
          l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI ';
          l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
          l_dyn_sql := l_dyn_sql || '     AND   EBI.TRANSACTION_ID = MIRI.TRANSACTION_ID ';
          l_dyn_sql := l_dyn_sql || '     AND    EBI.PROCESS_STATUS = 1  ';
          l_dyn_sql := l_dyn_sql || ') ';
          l_dyn_sql := l_dyn_sql || ' WHERE EXISTS ';
          l_dyn_sql := l_dyn_sql || '( ';
          l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
          l_dyn_sql := l_dyn_sql || '    FROM   EGO_BULKLOAD_INTF EBI ';
          l_dyn_sql := l_dyn_sql || '    WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
          l_dyn_sql := l_dyn_sql || '     AND    EBI.TRANSACTION_ID = MIRI.TRANSACTION_ID ';
          l_dyn_sql := l_dyn_sql || '     AND    EBI.PROCESS_STATUS = 1  ';
          l_dyn_sql := l_dyn_sql || ') ';

          Write_Debug(l_dyn_sql);

    EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;
          Write_Debug('MIRI: Updated the '||l_prod_col_name_tbl(i)||' column values.');

        END IF;--end: IF (l_prod_col_name_tbl(i) = G_REV_REASON_DB_COL) THEN

      END LOOP;--end: FOR i IN l_prod_col_name_tbl.first .. l_prod_col_name_tbl.last LOOP

      ----------------------------------------------------------------------------------
      --  Bug# 3421497 fix.
      --  If Lifecycle ID or Lifecycle Phase ID, save column information, and process
      --  later in the sequence, as Lifecycle Phase ID Value-to-ID conversion is
      --  dependant upon the Lifecycle ID value.
      --  Hence the are processed outside the above LOOP.
      ----------------------------------------------------------------------------------

      IF (l_lifecycle_col_val IS NOT NULL OR l_lifecycle_phase_col_val IS NOT NULL ) THEN

         ----------------------------------------------------------------------------------
         -- Fix for Bug:3624686
         -- LIFECYCLE_ID cannot be updated anymore through Spreadsheet (Excel) Item
         -- Revision Import. Only Lifecycle Phase (CURRENT_PHASE_ID) can be updated.
         -- ***Hence, Commenting out following which sets the LIFECYCLE_ID.
         ----------------------------------------------------------------------------------
/*

         ----------------------------------------------------------------------------------
         --  First Transfer the Lifecycle information from EBI to MSII
         --  by doing Value-to-ID Conversion.
         ----------------------------------------------------------------------------------
           l_dyn_sql := '';
           l_dyn_sql := l_dyn_sql || ' ';
           l_dyn_sql := l_dyn_sql || 'UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI ';
           l_dyn_sql := l_dyn_sql || ' SET   MIRI.LIFECYCLE_ID = ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT LC.PROJ_ELEMENT_ID ';
           l_dyn_sql := l_dyn_sql || '    FROM   PA_EGO_LIFECYCLES_PHASES_V LC, EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  LC.OBJECT_TYPE = ''PA_STRUCTURES'' ';
           l_dyn_sql := l_dyn_sql || '    AND    LC.NAME = EBI.'||l_lifecycle_col_val;
           l_dyn_sql := l_dyn_sql || '    AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MIRI.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   PA_EGO_LIFECYCLES_PHASES_V LC, EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  LC.OBJECT_TYPE = ''PA_STRUCTURES'' ';
           l_dyn_sql := l_dyn_sql || '    AND    LC.NAME = EBI.'||l_lifecycle_col_val;
           l_dyn_sql := l_dyn_sql || '    AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MIRI.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;
           Write_Debug('MIRI: Updated the Lifecycle IDs.');
*/

           ----------------------------------------------------------------------------------
           -- Fix for Bug:3624686
           -- As a part of 11.5.10, Setting the Lifecycle for Revision is not available.
           -- But setting Lifecycle Phase is still possible.
           -- Hence pick up the Lifecycle from Item (MTL_SYSTEM_ITEMS_B) and set in
           -- MTL_ITEM_REVISIONS_INTERFACE.
           ----------------------------------------------------------------------------------

         ----------------------------------------------------------------------------------
         --  First Transfer the Lifecycle ID information from MSI to MSII
         --  as the Revision inherits Lifecycle ID from Item.
         ----------------------------------------------------------------------------------
           l_dyn_sql := '';
           l_dyn_sql := l_dyn_sql || 'UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI ';
           l_dyn_sql := l_dyn_sql || ' SET   MIRI.LIFECYCLE_ID = ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT MSI.LIFECYCLE_ID ';
           l_dyn_sql := l_dyn_sql || '    FROM   MTL_SYSTEM_ITEMS_B MSI, EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  MSI.INVENTORY_ITEM_ID = EBI.INSTANCE_PK1_VALUE ';
           l_dyn_sql := l_dyn_sql || '    AND    MSI.ORGANIZATION_ID = EBI.INSTANCE_PK2_VALUE ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MIRI.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   MTL_SYSTEM_ITEMS_B MSI, EGO_BULKLOAD_INTF EBI  ';
           l_dyn_sql := l_dyn_sql || '    WHERE  MSI.INVENTORY_ITEM_ID = EBI.INSTANCE_PK1_VALUE ';
           l_dyn_sql := l_dyn_sql || '    AND    MSI.ORGANIZATION_ID = EBI.INSTANCE_PK2_VALUE ';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MIRI.TRANSACTION_ID ';
           -- Bug: 3762986 - If LC Phase is not null, then only update the lifecycle_id
           l_dyn_sql := l_dyn_sql || '    AND    EBI.'||l_lifecycle_phase_col_val||' IS NOT NULL';
           -- Bug: 3762986 - end
           l_dyn_sql := l_dyn_sql || '    AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;
           Write_Debug('MIRI: Updated the Lifecycle IDs from MTL_SYSTEM_ITEMS_B.');

         ----------------------------------------------------------------------------------
         --  Next Transfer the Lifecycle Phase information from EBI to MSII
         --  by doing Value-to-ID Conversion, and by joining Lifecycle ID information.
         ----------------------------------------------------------------------------------
           l_dyn_sql := '';
           l_dyn_sql := l_dyn_sql || 'UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI ';
           l_dyn_sql := l_dyn_sql || ' SET   MIRI.CURRENT_PHASE_ID = ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT LCP.PROJ_ELEMENT_ID ';
           l_dyn_sql := l_dyn_sql || '    FROM   PA_EGO_PHASES_V LCP, EGO_BULKLOAD_INTF EBI ';
           l_dyn_sql := l_dyn_sql || '    WHERE  LCP.PARENT_STRUCTURE_ID = MIRI.LIFECYCLE_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    LCP.NAME = EBI.'||l_lifecycle_phase_col_val;
           l_dyn_sql := l_dyn_sql || '    AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
           l_dyn_sql := l_dyn_sql || '     AND   EBI.TRANSACTION_ID = MIRI.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '     AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';
           l_dyn_sql := l_dyn_sql || ' WHERE EXISTS ';
           l_dyn_sql := l_dyn_sql || '( ';
           l_dyn_sql := l_dyn_sql || '    SELECT ''X'' ';
           l_dyn_sql := l_dyn_sql || '    FROM   PA_EGO_PHASES_V LCP, EGO_BULKLOAD_INTF EBI ';
           l_dyn_sql := l_dyn_sql || '    WHERE  LCP.PARENT_STRUCTURE_ID = MIRI.LIFECYCLE_ID ';
           l_dyn_sql := l_dyn_sql || '    AND    LCP.NAME = EBI.'||l_lifecycle_phase_col_val;
           l_dyn_sql := l_dyn_sql || '    AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_EXISTS';
           l_dyn_sql := l_dyn_sql || '    AND    EBI.TRANSACTION_ID = MIRI.TRANSACTION_ID ';
           l_dyn_sql := l_dyn_sql || '     AND    EBI.PROCESS_STATUS = 1  ';
           l_dyn_sql := l_dyn_sql || ') ';

           Write_Debug(l_dyn_sql);
           EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;
           Write_Debug('MIRI: Updated the Lifecycle Phase IDs.');

       END IF; --end: IF (l_lifecycle_col_val IS NOT NULL ...

   END IF; --IF ( l_prod_col_name_tbl.count > 0) THEN

   --
   -- delete unnecessary records from MIRI
   -- Bug: 5476972 "Rows not to be deleted if Revision is null"
   -- bug: 5557250 delete only if all the fields are populated as NULL
   --
   /* Bug 7578350. Moving this DELETE statement to the function process_item_interface_lines(), after the function call
      load_itm_or_rev_usrattr_intf() that updates UDAs, so that we delete the rows from MTL_ITEM_REVISIONS_INTERFACE
      only if there are no Revision Level Attributes provided.

    DELETE MTL_ITEM_REVISIONS_INTERFACE MIRI
    WHERE revision IS NULL
      AND revision_id IS NULL
      AND implementation_date IS NULL
      AND effectivity_date IS NULL
      AND description IS NULL
      AND revision_label IS NULL
      AND revision_reason IS NULL
      AND current_phase_id IS NULL
      AND EXISTS (SELECT 'X'
                    FROM  EGO_BULKLOAD_INTF EBI
                   WHERE  EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id
                     AND  EBI.TRANSACTION_ID = MIRI.TRANSACTION_ID
                     AND  EBI.PROCESS_STATUS = 1
                 ); */

   --
   -- convert all date fields values from Excel Null to INTF Null
   --
   UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI
   SET  ecn_initiation_date = DECODE(ecn_initiation_date,G_EXCEL_NULL_DATE,EGO_ITEM_PUB.G_INTF_NULL_DATE,ecn_initiation_date),
        implementation_date = DECODE(implementation_date,G_EXCEL_NULL_DATE,EGO_ITEM_PUB.G_INTF_NULL_DATE,implementation_date),
        effectivity_date = DECODE(effectivity_date,G_EXCEL_NULL_DATE,EGO_ITEM_PUB.G_INTF_NULL_DATE,effectivity_date)
   WHERE MIRI.TRANSACTION_ID IN
      ( SELECT EBI.TRANSACTION_ID
        FROM   EGO_BULKLOAD_INTF EBI
        WHERE  EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id
        AND    EBI.PROCESS_STATUS = 1
      )
   AND    (MIRI.ecn_initiation_date IS NOT NULL
                OR
                MIRI.implementation_date IS NOT NULL
                OR
                MIRI.effectivity_date IS NOT NULL
               );

   x_retcode := G_STATUS_SUCCESS;
   x_set_process_id := l_msii_set_process_id;

END load_item_revs_interface;

 ----------------------------------------------------------
 -- Preprocess Item Revision Interface Lines             --
 ----------------------------------------------------------
PROCEDURE preprocess_itemrev_interface
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_caller_identifier     IN         VARCHAR2 DEFAULT EGO_ITEM_BULKLOAD_PKG.G_ITEM,
                 p_set_process_id        IN         NUMBER,
                 x_errbuff               IN OUT NOCOPY    VARCHAR2,
                 x_retcode               IN OUT NOCOPY    VARCHAR2
                ) IS

    -- Start OF comments
    -- API name  : Setup MSII Item Interface Lines for processing
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  : Populate and Prepare Item interfance lines.
    --             Eliminates any redundancy / errors in MSII

  -----------------------------------------------
  -- Long Dynamic SQL String
  -----------------------------------------------
  l_dyn_sql                VARCHAR2(20000);

BEGIN

   -----------------------------------------------------------------------
   -- Only in case of Import, and while importing Multi-Row attr group
   -- values : Item, Org, Revision are NOT NULL, and rest of the base
   -- attributes are NULL. Hence can delete these rows off from MIRI.
   -----------------------------------------------------------------------
   DELETE MTL_ITEM_REVISIONS_INTERFACE
     WHERE
     (
      (
       ITEM_NUMBER                   IS NOT NULL    OR
       INVENTORY_ITEM_ID             IS NOT NULL
       )
       AND
      (
       ORGANIZATION_CODE             IS NOT NULL    OR
       ORGANIZATION_ID               IS NOT NULL
       )
       AND
      (
       REVISION                      IS NOT NULL    OR
       REVISION_ID                   IS NOT NULL
       )
      )
     AND
     (
       DESCRIPTION                   IS NULL AND
       LIFECYCLE_ID                  IS NULL AND
       CURRENT_PHASE_ID              IS NULL AND
       REVISION_LABEL                IS NULL AND
       REVISION_REASON               IS NULL AND
       LIFECYCLE_ID                  IS NULL AND
       CURRENT_PHASE_ID              IS NULL AND
       EFFECTIVITY_DATE              IS NULL
      )
       AND SET_PROCESS_ID = p_set_process_id;

   Write_Debug('Preprocess_ItemRev_Interface : Deleted redundant / unnecessary rows from MIRI');

END preprocess_itemrev_interface;


 ----------------------------------------------------------
 -- Setup Item Revision Interface Lines                  --
 ----------------------------------------------------------
PROCEDURE Setup_itemrev_interface
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_caller_identifier     IN         VARCHAR2 DEFAULT EGO_ITEM_BULKLOAD_PKG.G_ITEM,
                 p_data_level            IN         VARCHAR2,
                 p_set_process_id        IN         NUMBER,
                 x_set_process_id        OUT NOCOPY NUMBER,
                 x_errbuff               OUT NOCOPY VARCHAR2,
                 x_retcode               OUT NOCOPY VARCHAR2
                ) IS

    -- Start OF comments
    -- API name  : Setup MIRI Item Rev Interface Lines for processing
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  : Populate and Prepare Item Rev interfance lines.
    --             Eliminates any redundancy / errors in MIRI

  l_set_process_id   NUMBER(15);

BEGIN

   -----------------------------------
   -- Populates rows in MIRI
   -----------------------------------
   load_item_revs_interface(
        p_resultfmt_usage_id  => p_resultfmt_usage_id
       ,p_data_level          => p_data_level
       ,p_set_process_id      => p_set_process_id
       ,x_set_process_id      => l_set_process_id
       ,x_errbuff             => x_errbuff
       ,x_retcode             => x_retcode
            );

   -------------------------------------------------------
   -- Deletes redundant / unnecessary rows from MIRI.
   -------------------------------------------------------
   preprocess_itemrev_interface(
        p_resultfmt_usage_id  => p_resultfmt_usage_id
       ,p_set_process_id      => l_set_process_id
       ,x_errbuff             => x_errbuff
       ,x_retcode             => x_retcode
            );

   x_set_process_id := l_set_process_id;

   Write_Debug('Setup_ItemRev_Interface : Set Process Id => '||x_set_process_id);

 EXCEPTION
   WHEN OTHERS THEN
      x_retcode := G_STATUS_ERROR;
      x_errbuff := SUBSTRB(SQLERRM, 1,240);
      Write_Debug('Setup_Itemrev_Interface : EXCEPTION HAPPENED => '||x_errbuff);
      RAISE;

END setup_itemrev_interface;


 ----------------------------------------------------------------------------
 --  Change Item Revision Interface Lines process statuses as completed.   --
 --  Statuses represent: Warning, Error, Success etc.,                     --
 ----------------------------------------------------------------------------
PROCEDURE Item_Revs_Intf_Completion
  (
    p_resultfmt_usage_id     IN    NUMBER
  , x_errbuff                OUT NOCOPY  VARCHAR2
  , x_retcode                OUT NOCOPY  VARCHAR2
    ) IS

  -----------------------------------------------
  -- Long Dynamic SQL String
  -----------------------------------------------
  l_dyn_sql                VARCHAR2(10000);

BEGIN

   -----------------------------------------------------------------
   -- Update EBI, with the process status of rows in MIRI after
   -- the completion of IOI Revision processing.
   -----------------------------------------------------------------
   UPDATE EGO_BULKLOAD_INTF EBI
     SET  EBI.PROCESS_STATUS =
     (
      SELECT MIRI.PROCESS_FLAG
      FROM   MTL_ITEM_REVISIONS_INTERFACE MIRI
      WHERE  MIRI.TRANSACTION_ID = EBI.TRANSACTION_ID
      )
     WHERE EXISTS
     (
      SELECT 'X'
      FROM   MTL_ITEM_REVISIONS_INTERFACE MIRI
      WHERE  MIRI.TRANSACTION_ID = EBI.TRANSACTION_ID
      )
     AND EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id;

   ----------------------------------------------------------------------------
   -- Update all the lines in EGO_BULKLOAD_INTF as failure, for which
   -- The Revision IDS were not available.
   -- 1. For Transaction Type : CREATE, Revision ID should be populated
   --    at the end of Processing
   -- 2. For Transaction Type : SYNC / UPDATE, Revision ID should be
   --    retrieved during processing.
   ----------------------------------------------------------------------------
   UPDATE EGO_BULKLOAD_INTF EBI
     SET  EBI.PROCESS_STATUS = G_INTF_STATUS_ERROR
     WHERE EXISTS
     (
      SELECT 'X'
      FROM   MTL_ITEM_REVISIONS_INTERFACE MIRI
      WHERE  MIRI.TRANSACTION_ID = EBI.TRANSACTION_ID
       AND   MIRI.PROCESS_FLAG   = G_INTF_STATUS_SUCCESS
       AND   MIRI.REVISION_ID IS NULL
      )
     AND EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id;

   ----------------------------------------------------------------------------
   -- Update all the lines in EGO_BULKLOAD_INTF as SUCCESS
   -- for these rows were used to populate Multi-Row
   -- Appropriate errors will be displayed by the User-Defined Attrs Bulkldr.
   ----------------------------------------------------------------------------
   UPDATE EGO_BULKLOAD_INTF EBI
     SET  EBI.PROCESS_STATUS = G_INTF_STATUS_SUCCESS
     WHERE EBI.PROCESS_STATUS = G_INTF_STATUS_TOBE_PROCESS
     AND EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id;

   ----------------------------------------------------------------------------
   -- Update the Item IDs (Doesnt matter Create or Update, because
   -- Item IDs will be populated either way in MSII) in
   -- Generic Bulkload Intf table (EGO_BULKLOAD_INTF)
   -- These Item IDs are required for Item User-Defined Attrs bulkload
   ----------------------------------------------------------------------------
   UPDATE EGO_BULKLOAD_INTF EBI
     SET  EBI.INSTANCE_PK1_VALUE =
     (
      SELECT MSII.INVENTORY_ITEM_ID
      FROM   MTL_SYSTEM_ITEMS_INTERFACE MSII
      WHERE  MSII.TRANSACTION_ID = EBI.TRANSACTION_ID
      )
     WHERE EXISTS
     (
      SELECT 'X'
      FROM   MTL_SYSTEM_ITEMS_INTERFACE MSII
      WHERE  MSII.TRANSACTION_ID = EBI.TRANSACTION_ID
      )
     AND EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id
     AND EBI.PROCESS_STATUS = G_INTF_STATUS_SUCCESS;

   ----------------------------------------------------------------------------
   -- Update the Item Revision IDs (Doesnt matter Create or Update, because
   -- Item Revision IDs will be populated either way in MIRI) in
   -- Generic Bulkload Intf table (EGO_BULKLOAD_INTF)
   -- These Revision IDs are required for Revision User-Defined Attrs bulkload
   ----------------------------------------------------------------------------
   UPDATE EGO_BULKLOAD_INTF EBI
     SET  EBI.INSTANCE_PK3_VALUE =
     (
      SELECT MIRI.REVISION_ID
      FROM   MTL_ITEM_REVISIONS_INTERFACE MIRI
      WHERE  MIRI.TRANSACTION_ID = EBI.TRANSACTION_ID
      )
     WHERE EXISTS
     (
      SELECT 'X'
      FROM   MTL_ITEM_REVISIONS_INTERFACE MIRI
      WHERE  MIRI.TRANSACTION_ID = EBI.transaction_id
      )
     AND EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id
     AND EBI.PROCESS_STATUS = G_INTF_STATUS_SUCCESS;

   Write_Debug('EBI: Updated the Process_Status to Indicate Succssful/Unsucessful completion.');

   x_retcode := G_STATUS_SUCCESS;

 EXCEPTION
   WHEN OTHERS THEN
      x_retcode := G_STATUS_ERROR;
      x_errbuff := SUBSTRB(SQLERRM, 1,240);
      Write_Debug('Item_Revs_Intf_Completion : EXCEPTION HAPPENED => '||x_errbuff);
      RAISE;

END Item_Revs_Intf_Completion;


 ----------------------------------------------------------
 -- Load Item or Item Revision User Defined Attributes   --
 -- in User-Defined Attributes Interface Table           --
 ----------------------------------------------------------

PROCEDURE load_itm_or_rev_usrattr_intf
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_data_set_id           IN         NUMBER,
                 x_errbuff               OUT NOCOPY VARCHAR2,
                 x_retcode               OUT NOCOPY VARCHAR2
                ) IS
    -- Start OF comments
    -- API name  : Populate Item User-Defined Attr Interfance Lines
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Load Item User-Defined Attributes interfance lines.
    --             Loads Item User-Defined Attribute Values
    --             Errors are populated in MTL_INTERFACE_ERRORS

  ------------------------------------------------------------------------------
  -- To retrieve Attribute group codes, for given Result Format Usage ID.
  ------------------------------------------------------------------------------
  CURSOR c_user_attr_group_codes (c_resultfmt_usage_id  IN  NUMBER) IS
    SELECT DISTINCT To_Number(SUBSTR(attribute_code, 1, INSTR(attribute_code, '$$') - 1)) attr_group_id
    FROM   ego_results_fmt_usages
    WHERE  resultfmt_usage_id = c_resultfmt_usage_id
     AND   attribute_code LIKE '%$$%'
     AND   To_Number(SUBSTR(attribute_code, 1, INSTR(attribute_code, '$$') - 1)) IN --attr_group_id
      ------------------------------------------------------------------------------
      -- Fixed in 11.5.10. Ensuring only the Item User-Defined Attrs are processed.
      ------------------------------------------------------------------------------
      (
        SELECT attr_group_id
        FROM   ego_attr_groups_v
        WHERE  attr_group_type in (G_IUD_ATTR_GROUP_TYPE, G_GTN_SNG_ATTR_GROUP_TYPE, G_GTN_MUL_ATTR_GROUP_TYPE)
        AND    application_id = G_APPLICATION_ID
      )
      ;

  ------------------------------------------------------------------------------
  -- To get the Attribute Group and Attribute Internal Names.
  -- NOTE: Joined extra attributes ATTR_GROUP_TYPE and APPLICATION_ID
  -- To hit the index.
  ------------------------------------------------------------------------------
   CURSOR c_attr_grp_details(p_attr_id  IN NUMBER) IS
     SELECT  attr_group_name, attr_name, attr_group_type,
             DECODE(data_type_code,'A','C'
                                  ,'X','D'
                                  ,'Y','D'
                   ,data_type_code) data_type_code,
                   uom_class -- R12C UOM Change
     FROM    ego_attrs_v
     WHERE   attr_id = p_attr_id
      AND    attr_group_type in (G_IUD_ATTR_GROUP_TYPE, G_GTN_SNG_ATTR_GROUP_TYPE, G_GTN_MUL_ATTR_GROUP_TYPE)
      AND    application_id = G_APPLICATION_ID;

  --------------------------------------------------------------------------------
  -- Defn includes a subset of  EGO_USER_ATTRS_DATA_PVT.LOCAL_USER_ATTR_DATA_REC
  -- plus few User-Defined Attr Table related fields.
  --------------------------------------------------------------------------------
  TYPE L_USER_ATTR_REC_TYPE IS RECORD
  (
      DATA_SET_ID                          NUMBER(15)
     ,TRANSACTION_ID                       NUMBER(15)
     ,TRANSACTION_TYPE                     VARCHAR2(10)--Bug:5088831
     ,INVENTORY_ITEM_ID                    NUMBER(15)
     ,ORGANIZATION_ID                      NUMBER(15)
     ,REVISION_ID                          NUMBER(15)
     ,ITEM_NUMBER                          VARCHAR2(1000)
     ,ORGANIZATION_CODE                    VARCHAR2(10)
     ,REVISION                             VARCHAR2(10)
     ,ROW_IDENTIFIER                       NUMBER(15)
     ,ATTR_GROUP_NAME                      VARCHAR2(30)
     ,ATTR_NAME                            VARCHAR2(30)
     ,ATTR_DATATYPE_CODE                   VARCHAR2(1) --Valid Vals: C / N / D
     ,ATTR_VALUE_STR                       VARCHAR2(1000)
     ,ATTR_VALUE_NUM                       NUMBER --BugFix 4256503
     ,ATTR_VALUE_DATE                      DATE
     ,ATTR_DISP_VALUE                      VARCHAR2(1000)
     ,INTF_COLUMN_NAME                     VARCHAR2(30)
     ,SOURCE_SYSTEM_ID                     NUMBER
     ,SOURCE_SYSTEM_REFERENCE              VARCHAR2(255)
     ,ATTR_GROUP_TYPE                      VARCHAR2(40)--Bug Fix 4630163(ISSUE2)
     ,DATA_LEVEL_ID                        NUMBER
     ,PK1_VALUE                            NUMBER
     ,PK2_VALUE                            NUMBER
     ,ATTR_UOM_DISP_VALUE                  VARCHAR2(25) -- R12C UOM Changes
     ,ATTR_VALUE_UOM                       VARCHAR2(3)  -- R12C UOM Changes
  );

  ---------------------------------------------------------------------
  -- Type Declarations
  ---------------------------------------------------------------------
  TYPE L_USER_ATTR_TBL_TYPE IS TABLE OF L_USER_ATTR_REC_TYPE
    INDEX BY BINARY_INTEGER;

  TYPE VARCHAR_TBL_TYPE IS TABLE OF VARCHAR2(256)
   INDEX BY BINARY_INTEGER;

               -------------------------
               --   local variables   --
               -------------------------
  l_api_name                        VARCHAR2(32) := 'load_itm_or_rev_usrattr_intf()';
  l_prod_col_name_tbl               VARCHAR_TBL_TYPE;
  l_intf_col_name_tbl               VARCHAR_TBL_TYPE;

  l_attr_id_table                   DBMS_SQL.VARCHAR2_TABLE; -- R12C UOM Change
  --DBMS_SQL.NUMBER_TABLE;
  l_intf_col_name_table             DBMS_SQL.VARCHAR2_TABLE;
  l_data_level_id_table             DBMS_SQL.NUMBER_TABLE;

  l_usr_attr_data_tbl               L_USER_ATTR_TBL_TYPE;

  l_item_id_char                    VARCHAR(15);
  l_org_id_char                     VARCHAR(15);
  l_item_rev_id_char                VARCHAR(15);
  l_item_num_char                   VARCHAR(1000);
  l_org_code_char                   VARCHAR(10);
  l_item_rev_code_char              VARCHAR(10);
  l_source_system_id                NUMBER;
  l_source_system_ref               VARCHAR2(255);

  l_count                           NUMBER(5);
  l_data_type_code                  VARCHAR2(2);
  l_transaction_id                  NUMBER(15);
  l_transaction_type                VARCHAR2(10);
  l_uom_class                       VARCHAR2(10); -- R12C UOM Change
  l_uom_meaning                     VARCHAR2(150); -- R12C UOM Change

  l_attr_group_int_name    EGO_ATTRS_V.ATTR_GROUP_NAME%TYPE;
  l_attr_int_name          EGO_ATTRS_V.ATTR_NAME%TYPE;
  l_attr_data_type         EGO_ATTRS_V.DATA_TYPE_CODE%TYPE;
  l_attr_group_type        EGO_ATTRS_V.ATTR_GROUP_TYPE%TYPE;--Bug Fix 4630163(ISSUE2)

  ---------------------------------------------------------
  -- Example Data Types to be used in Bind Variable.
  ---------------------------------------------------------
  l_varchar_example        VARCHAR2(10000);
  l_number_example         NUMBER;
  l_date_example           DATE;

  --------------------------------------------------------------------
  -- Actual Data to store corresponding data type value.
  -- NOTE: for fixing Bug# 3808455, changed the size of l_varchar_data
  --       to 10,000 chars. This is because, if there are 1000 Single
  --       Quotes in the String Attr Value, then the Escaped value
  --       becomes of Size 2000. So, for all better reasons, changing
  --       to a huge size.
  --------------------------------------------------------------------
  l_varchar_data           VARCHAR2(10000);
  l_number_data            NUMBER;
  l_date_data              DATE;

  ---------------------------------------------------------
  -- DBMS_SQL Open Cursor integers.
  ---------------------------------------------------------
  l_cursor_select          INTEGER;
  l_cursor_execute         INTEGER;
  l_cursor_attr_id_val     INTEGER;

  ---------------------------------------------------------
  -- Used for indexes.
  ---------------------------------------------------------
  l_temp                   NUMBER(10) := 1;
  l_actual_userattr_indx   NUMBER(15);
  l_indx                   NUMBER(15);
  l_rows_per_attr_grp_indx NUMBER(15);
  l_save_indx              NUMBER(15);
  l_attr_grp_has_data      BOOLEAN;

  l_attr_group_data_level  VARCHAR2(30);

  ---------------------------------------------------------
  -- Long Dynamic SQL Strings
  ---------------------------------------------------------
  l_dyn_sql                VARCHAR2(10000);
  l_dyn_attr_id_val_sql    VARCHAR2(10000);

  ---------------------------------------------------------
  -- To Number the Attribute Group Data Rows Uniquely.
  ---------------------------------------------------------

  -- Bug fix 6219349: 5 digits was prone to overflow,
  -- causing defaulting to a value that had already been
  -- used.
  L_ATTR_GRP_ROW_IDENT     NUMBER(18);

  ---------------------------------------------------------
  -- Token tables to log errors, through Error_Handler
  ---------------------------------------------------------
  l_token_tbl_two         Error_Handler.Token_Tbl_Type;
  l_token_tbl_one         Error_Handler.Token_Tbl_Type;

  l_gdsn_attrs_exist       VARCHAR2(1);
  l_dummy_char             VARCHAR2(1000);
  l_dummy                  NUMBER;
  l_supplier_name_col        VARCHAR2(30);
  l_supplier_number_col      VARCHAR2(20);
  l_supplier_site_name_col   VARCHAR2(30);
--  l_supplier_name            VARCHAR2(30); --abedajna Bug 611802
  l_supplier_name            VARCHAR2(320);
  l_supplier_number          VARCHAR2(20);
--  l_supplier_site_name       VARCHAR2(30); --abedajna Bug 611802
  l_supplier_site_name       VARCHAR2(320);
  l_supplier_id              NUMBER;
  l_supplier_site_id         NUMBER;
  l_site_org_id                  NUMBER;
  l_row_id_incr              NUMBER;

  BEGIN


  Write_Debug(l_api_name || 'BEGIN ');
---------------------------------------------------------
  -- Initializing the Row Identifier.
  ---------------------------------------------------------
  BEGIN
    SELECT NVL(MAX(ROW_IDENTIFIER),0)
      INTO L_ATTR_GRP_ROW_IDENT
      FROM EGO_ITM_USR_ATTR_INTRFC
     WHERE DATA_SET_ID = p_data_set_id;
  EXCEPTION
    WHEN OTHERS THEN

      Write_Debug(l_api_name || 'ERROR: Couldn''t generate next row identifier');

      -- SSARNOBA: What if we come here a second time?
      -- We're going to get a unique constraint violation.
      L_ATTR_GRP_ROW_IDENT := 0;
  END;

  BEGIN
    SELECT INTF_COLUMN_NAME
      INTO l_supplier_name_col
      FROM EGO_RESULTS_FMT_USAGES
     WHERE RESULTFMT_USAGE_ID = p_resultfmt_usage_id
       AND ATTRIBUTE_CODE NOT LIKE '%$$%'
       AND CUSTOMIZATION_APPLICATION_ID = 431
       AND REGION_APPLICATION_ID = 431
       AND ATTRIBUTE_CODE = 'SUPPLIER_NAME';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_supplier_name_col := NULL;
  END;

  BEGIN
    SELECT INTF_COLUMN_NAME
      INTO l_supplier_number_col
      FROM EGO_RESULTS_FMT_USAGES
     WHERE RESULTFMT_USAGE_ID = p_resultfmt_usage_id
       AND ATTRIBUTE_CODE NOT LIKE '%$$%'
       AND CUSTOMIZATION_APPLICATION_ID = 431
       AND REGION_APPLICATION_ID = 431
       AND ATTRIBUTE_CODE = 'SUPPLIER_NUMBER';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_supplier_number_col := NULL;
  END;

  BEGIN
    SELECT INTF_COLUMN_NAME
      INTO l_supplier_site_name_col
      FROM EGO_RESULTS_FMT_USAGES
     WHERE RESULTFMT_USAGE_ID = p_resultfmt_usage_id
       AND ATTRIBUTE_CODE NOT LIKE '%$$%'
       AND CUSTOMIZATION_APPLICATION_ID = 431
       AND REGION_APPLICATION_ID = 431
       AND ATTRIBUTE_CODE = 'SUPPLIER_SITE';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_supplier_site_name_col := NULL;
  END;

  --------------------------------------------------------------------
  -- Loop to process per Attribute Group of User-Defined Attributes.
  --------------------------------------------------------------------
  <<LIORUI_attr_groups_loop>>
  FOR c_attr_grp_rec IN c_user_attr_group_codes(p_resultfmt_usage_id) LOOP

    Write_Debug(l_api_name || 'LIORUI_attr_groups_loop - Attribute Group'
                || c_attr_grp_rec.attr_group_id);

    --------------------------------------------------------------------
    -- Added for BugFix 4114928 : We need to check for the data level --
    -- of the atr group and populate the REVISION_ID only if the AG   --
    -- revision level.                                                --
    --------------------------------------------------------------------
    SELECT DATA_LEVEL_INT_NAME INTO l_attr_group_data_level
      FROM EGO_OBJ_ATTR_GRP_ASSOCS_V
     WHERE ATTR_GROUP_TYPE in (G_IUD_ATTR_GROUP_TYPE, G_GTN_SNG_ATTR_GROUP_TYPE, G_GTN_MUL_ATTR_GROUP_TYPE)
       AND ATTR_GROUP_ID = c_attr_grp_rec.attr_group_id
       AND OBJECT_NAME = G_EGO_ITEM_OBJ_NAME
       AND ROWNUM = 1;-- The AG cannot have associations at Item level and Revision Level for different Catalogs.

    --------------------------------------------------------------------
    -- Fetch Organization ID, Item Number in Temp PLSQL tables.
    --------------------------------------------------------------------
    --- R12C UOM Change. Removing to_Num conversion . Now attrId$$UOM will also go into l_attr_id_table
    -- old code  l_dyn_sql := ' SELECT To_Number(SUBSTR(attribute_code, INSTR(attribute_code, ''$$'')+2)) attr_id, intf_column_name, DATA_LEVEL_ID ';

    l_dyn_sql := ' SELECT SUBSTR(attribute_code, INSTR(attribute_code, ''$$'')+2) attr_id, intf_column_name, DATA_LEVEL_ID ';
    l_dyn_sql := l_dyn_sql || ' FROM   ego_results_fmt_usages ';
    l_dyn_sql := l_dyn_sql || ' WHERE  resultfmt_usage_id = :RESULTFMT_USAGE_ID';
    l_dyn_sql := l_dyn_sql || '  AND attribute_code LIKE :ATTRIBUTE_CODE ';
    l_dyn_sql := l_dyn_sql || '  ORDER BY DISPLAY_SEQUENCE '; --- R12C UOM Change.so that UOM col comes next to corresponding number col

    Write_Debug(l_api_name || l_dyn_sql);

    l_cursor_select := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_cursor_select, l_dyn_sql, DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 1,l_attr_id_table,2500, l_temp);
    DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 2,l_intf_col_name_table,2500, l_temp);
    DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 3,l_data_level_id_table,2500, l_temp);

    DBMS_SQL.BIND_VARIABLE(l_cursor_select,':RESULTFMT_USAGE_ID', p_resultfmt_usage_id);
    DBMS_SQL.BIND_VARIABLE(l_cursor_select,':ATTRIBUTE_CODE', c_attr_grp_rec.attr_group_id||'$$%');
    l_cursor_execute := DBMS_SQL.EXECUTE(l_cursor_select);
    Write_Debug(l_api_name || 'About to start the Loop to fetch Rows');
    l_count := DBMS_SQL.FETCH_ROWS(l_cursor_select);
    DBMS_SQL.COLUMN_VALUE(l_cursor_select, 1, l_attr_id_table);
    DBMS_SQL.COLUMN_VALUE(l_cursor_select, 2, l_intf_col_name_table);
    DBMS_SQL.COLUMN_VALUE(l_cursor_select, 3, l_data_level_id_table);

    Write_Debug(l_api_name || 'Retrieved rows => '||To_char(l_count));
    DBMS_SQL.CLOSE_CURSOR(l_cursor_select);

    --------------------------------------------------------------------
    -- New DBMS_SQL Cursor for Select Attr Values.
    --------------------------------------------------------------------
    l_cursor_attr_id_val := DBMS_SQL.OPEN_CURSOR;
    l_dyn_attr_id_val_sql := ' SELECT ';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' TRANSACTION_ID , ';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' UPPER(TRANSACTION_TYPE) , ';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' INSTANCE_PK1_VALUE , ';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' INSTANCE_PK2_VALUE , ';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' INSTANCE_PK3_VALUE , ';
    --------------------------------------------------------------------
    -- Added the fix to fetch these cols also, as in case of New Item
    -- Instance PK1 Value might not have been retrieved.
    --------------------------------------------------------------------
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql ||G_ITEM_NUMBER_EBI_COL ||'  , ';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql ||G_ORG_CODE_EBI_COL ||'  , ';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql ||G_REVISION_CODE_EBI_COL ||'  , ';
    --------------------------------------------------------------------
    -- R12
    -- Adding the source system id and source system reference columns
    --------------------------------------------------------------------
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' TO_NUMBER(C_FIX_COLUMN11) , ';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' C_FIX_COLUMN12 , ';

    ----------------------------------------------------
    --R12C adding the suppplier/supplier site columns
    ----------------------------------------------------
    IF(l_supplier_name_col IS NOT NULL) THEN
      l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql ||l_supplier_name_col ||'  , ';
    END IF;
    IF(l_supplier_number_col IS NOT NULL) THEN
      l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql ||l_supplier_number_col ||'  , ';
    END IF;
    IF(l_supplier_site_name_col IS NOT NULL) THEN
      l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql ||l_supplier_site_name_col ||'  , ';
    END IF;

    --------------------------------------------------------------------
    -- Loop to Update the Inventory Item IDs.
    --------------------------------------------------------------------
    <<LIORUI_update_item_ids_loop>>
    FOR i IN 1..l_attr_id_table.COUNT LOOP
      Write_Debug(l_api_name || 'LIORUI_update_item_ids_loop - '||i);
      Write_Debug(l_api_name || 'Attr ID : '||To_char(l_attr_id_table(i)));
      Write_Debug(l_api_name || 'Intf Col Name : '||l_intf_col_name_table(i));
      IF (i <> l_attr_id_table.COUNT) THEN
        l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || l_intf_col_name_table(i) || ', ';
      ELSE
        l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || l_intf_col_name_table(i) ;
      END IF;
    END LOOP LIORUI_update_item_ids_loop; --end: FOR i IN 1..l_attr_id_table.COUNT LOOP

    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' FROM EGO_BULKLOAD_INTF ' ;
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' WHERE RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' AND PROCESS_STATUS = :PROCESS_STATUS ';
    Write_Debug(l_api_name || l_dyn_attr_id_val_sql);

    DBMS_SQL.PARSE(l_cursor_attr_id_val, l_dyn_attr_id_val_sql, DBMS_SQL.NATIVE);
    --------------------------------------------------------------------
    --Setting Data Type for Trasaction ID
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 1, l_number_example);

    --------------------------------------------------------------------
    --Setting Data Type for Trasaction Type
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 2, l_varchar_example,10);

    --------------------------------------------------------------------
    --Setting Data Type for INSTANCE_PK1_VALUE (Item ID)
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 3, l_varchar_example, 1000);

    --------------------------------------------------------------------
    --Setting Data Type for INSTANCE_PK2_VALUE (Org ID)
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 4, l_varchar_example, 1000);

    --------------------------------------------------------------------
    --Setting Data Type for INSTANCE_PK3_VALUE (Revision ID)
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 5, l_varchar_example, 1000);

    --------------------------------------------------------------------
    --Setting Data Type for Item Num
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 6, l_varchar_example, 1000);

    --------------------------------------------------------------------
    --Setting Data Type for Org Code
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 7, l_varchar_example, 1000);

    --------------------------------------------------------------------
    --Setting Data Type for Revision Code
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 8, l_varchar_example, 1000);

    --------------------------------------------------------------------
    --Setting Data Type for Source System Id
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 9, l_number_example);

    --------------------------------------------------------------------
    --Setting Data Type for Source System Reference
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 10, l_varchar_example, 1000);

    ---------------------------------------------------------------
    --R12C setting data type for suppplier/supplier site columns
    ---------------------------------------------------------------
    l_dummy := 0;
    IF(l_supplier_name_col IS NOT NULL) THEN
      DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 11 + l_dummy, l_varchar_example, 1000);
      l_dummy := l_dummy +1;
    END IF;
    IF(l_supplier_number_col IS NOT NULL) THEN
      DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 11 + l_dummy, l_varchar_example, 1000);
      l_dummy := l_dummy +1;
    END IF;
    IF(l_supplier_site_name_col IS NOT NULL) THEN
      DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 11 + l_dummy, l_varchar_example, 1000);
      l_dummy := l_dummy +1;
    END IF;

    --------------------------------------------------------------------
    -- Loop to Bind the Data Types for the SELECT Columns.
    --------------------------------------------------------------------
    <<LIORUI_data_types_loop_1>>
    FOR i IN 1..l_attr_id_table.COUNT LOOP

      Write_Debug(l_api_name || 'LIORUI_data_types_loop_1 - '||i);

      ------------------------------------------------------------------------
      -- Since TRANSACTION_ID, INSTANCE_PK1_VALUE, INSTANCE_PK2_VALUE,
      -- INSTANCE_PK3_VALUE are added to the SELECT before the User-Defined
      -- Attrs, we need to adjust the index as follows.
      ------------------------------------------------------------------------
      l_actual_userattr_indx := i + 10 + l_dummy;

      l_data_type_code := SUBSTR (l_intf_col_name_table(i), 1, 1);
      ------------------------------------------------------------------------
      -- Based on the Data Type of the attribute, define the column
      ------------------------------------------------------------------------

      IF (l_data_type_code = 'C') THEN
        DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, l_actual_userattr_indx, l_varchar_example, 1000);
      ELSIF (l_data_type_code = 'U') THEN  -- R12C UOM Changes
        DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, l_actual_userattr_indx, l_varchar_example, 150);
      ELSIF (l_data_type_code = 'N') THEN
        DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, l_actual_userattr_indx, l_number_example);
      ELSE --IF (l_data_type_code = 'D') THEN
        DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, l_actual_userattr_indx, l_date_example);
      END IF; --IF (l_data_type_code = 'C') THEN

    END LOOP LIORUI_data_types_loop_1; --FOR i IN 1..l_attr_id_table.COUNT LOOP


    DBMS_SQL.BIND_VARIABLE(l_cursor_attr_id_val,':RESULTFMT_USAGE_ID',p_resultfmt_usage_id);

    write_debug(l_api_name || 'Binding the PROCESS_STATUS = '||G_INTF_STATUS_TOBE_PROCESS);
    DBMS_SQL.BIND_VARIABLE(l_cursor_attr_id_val,':PROCESS_STATUS',G_INTF_STATUS_TOBE_PROCESS);
    ------------------------------------------------------------------------
    --  Execute to get the Item User-Defined Attr values.
    ------------------------------------------------------------------------
    l_cursor_execute := DBMS_SQL.EXECUTE(l_cursor_attr_id_val);

    l_rows_per_attr_grp_indx := 0;
    ------------------------------------------------------------------------
    --  Loop for each row found in EBI
    ------------------------------------------------------------------------
    <<LIORUI_ebi_rows_loop>>
    LOOP --LOOP FOR CURSOR_ATTR_ID_VAL

      Write_Debug(l_api_name || 'LIORUI_ebi_rows_loop - begin');


      IF DBMS_SQL.FETCH_ROWS(l_cursor_attr_id_val)>0 THEN

        ------------------------------------------------------------------------
        --Increment Row Identifier per (Attribute Group + Row) Combination.
        ------------------------------------------------------------------------
        L_ATTR_GRP_ROW_IDENT  := L_ATTR_GRP_ROW_IDENT + 20;

        Write_Debug(l_api_name || 'ROW_FOUND : '||L_ATTR_GRP_ROW_IDENT);

        ------------------------------------------------------------------------
        -- First column is Transaction ID.
        ------------------------------------------------------------------------
        DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 1, l_transaction_id);
        DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 2, l_transaction_type);
        DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 3, l_item_id_char);
        DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 4, l_org_id_char);
        DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 5, l_item_rev_id_char);
        DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 6, l_item_num_char);
        DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 7, l_org_code_char);
        DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 8, l_item_rev_code_char);
        DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 9, l_source_system_id);
        DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 10, l_source_system_ref);

        l_dummy := 0;
        l_supplier_site_id := NULL;
        l_supplier_id := NULL;
        l_supplier_name := NULL;
        l_supplier_number := NULL;
        l_supplier_site_name := NULL;

        IF(l_supplier_name_col IS NOT NULL) THEN
          DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 11 + l_dummy, l_supplier_name);
          l_dummy := l_dummy +1;

          IF(l_supplier_name IS NOT NULL) THEN
            BEGIN
              SELECT VENDOR_ID
                INTO l_supplier_id
                FROM AP_SUPPLIERS
               WHERE VENDOR_NAME = l_supplier_name;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_supplier_id:= NULL;
            END;
          END IF;
        END IF;

        IF(l_supplier_number_col IS NOT NULL) THEN
          DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 11 + l_dummy, l_supplier_number);
          l_dummy := l_dummy +1;
          IF(l_supplier_number IS NOT NULL) THEN
            BEGIN
               SELECT VENDOR_ID
                 INTO l_supplier_id
                 FROM AP_SUPPLIERS
                WHERE SEGMENT1 = l_supplier_number;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_supplier_id:= NULL;
            END;
          END IF;
        END IF;

        IF(l_supplier_site_name_col IS NOT NULL) THEN
           l_dummy := l_dummy +1;
        END IF;
        ------------------------------------------------------------------------
        -- Loop to Bind the Data Types for the SELECT Columns.
        ------------------------------------------------------------------------
        <<LIORUI_data_types_loop_2>>
        FOR i IN 1..l_attr_id_table.COUNT LOOP

          Write_Debug(l_api_name || 'LIORUI_data_types_loop_2 - '||i);

          IF (  INSTR(l_attr_id_table(i),'$$UOM') = 0 ) THEN -- R12C UOM change: avoiding UOM entry here

          OPEN c_attr_grp_details(To_Number(l_attr_id_table(i)));
          FETCH c_attr_grp_details INTO
          l_attr_group_int_name, l_attr_int_name,l_attr_group_type,l_attr_data_type,l_uom_class;--Bug Fix 4630163(ISSUE2)

          Write_Debug(l_api_name || i||'=>'||l_attr_group_int_name||':'||l_attr_int_name||':'||l_attr_group_type);--Bug Fix 4630163(ISSUE2)

          l_attr_grp_has_data := FALSE;

          ------------------------------------------------------------------------
          -- If one more Attribute found for the Attribute Group.
          ------------------------------------------------------------------------
          IF c_attr_grp_details%FOUND THEN

            IF(l_supplier_site_name_col IS NOT NULL) THEN
              DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 11 + l_dummy -1, l_supplier_site_name);
              IF(l_supplier_site_name IS NOT NULL AND l_supplier_id IS NOT NULL) THEN
                BEGIN

      l_site_org_id := FND_PROFILE.VALUE('ORG_ID');
                  SELECT VENDOR_SITE_ID
                    INTO l_supplier_site_id
                    FROM AP_SUPPLIER_SITES_ALL
                   WHERE VENDOR_SITE_CODE = l_supplier_site_name
                     AND ORG_ID = l_site_org_id
                     AND VENDOR_ID = l_supplier_id;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_supplier_site_id:= NULL;
                END;
              END IF;
            END IF;

            l_row_id_incr := 0;
            IF (l_data_level_id_table(i) IS NOT NULL AND l_data_level_id_table(i) <> 0) THEN
              l_row_id_incr := l_data_level_id_table(i)-43100;
            END IF;
            l_rows_per_attr_grp_indx := l_rows_per_attr_grp_indx + 1;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).DATA_SET_ID := p_data_set_id;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).TRANSACTION_ID := l_transaction_id;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).TRANSACTION_TYPE := l_transaction_type;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).INVENTORY_ITEM_ID := FND_NUMBER.CANONICAL_TO_NUMBER(l_item_id_char);
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ORGANIZATION_ID := FND_NUMBER.CANONICAL_TO_NUMBER(l_org_id_char);
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ITEM_NUMBER := l_item_num_char;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ORGANIZATION_CODE := l_org_code_char;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ROW_IDENTIFIER := L_ATTR_GRP_ROW_IDENT + l_row_id_incr;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DATATYPE_CODE := l_attr_data_type;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_GROUP_NAME := l_attr_group_int_name;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_NAME := l_attr_int_name;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_GROUP_TYPE := l_attr_group_type;--Bug Fix 4630163(ISSUE2)

            -- Populate the REVISION Columns only if the Data Level of the AG is Revision
            IF ( l_data_level_id_table(i) = 43106 ) THEN
              l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).REVISION := l_item_rev_code_char;
              l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).REVISION_ID := FND_NUMBER.CANONICAL_TO_NUMBER(l_item_rev_id_char);
            ELSE
              l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).REVISION := null;
              l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).REVISION_ID := null;
            END IF;

            IF ( l_data_level_id_table(i) = 43103 OR l_data_level_id_table(i) = 43104 OR l_data_level_id_table(i) = 43105) THEN
              l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK1_VALUE := l_supplier_id;
            ELSE
              l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK1_VALUE := null;
            END IF;
            IF (l_data_level_id_table(i) = 43104 OR l_data_level_id_table(i) = 43105) THEN
              l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK2_VALUE := l_supplier_site_id;
            ELSE
        l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK2_VALUE := null;
            END IF;

            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).SOURCE_SYSTEM_ID := l_source_system_id;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).SOURCE_SYSTEM_REFERENCE := l_source_system_ref;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).DATA_LEVEL_ID := l_data_level_id_table(i);
            ------------------------------------------------------------------------
            -- Since TRANSACTION_ID, INSTANCE_PK1_VALUE, INSTANCE_PK2_VALUE,
            -- INSTANCE_PK3_VALUE are added to the SELECT before User-Defined
            -- Attrs, we need to adjust the index as follows.
            ------------------------------------------------------------------------
            l_actual_userattr_indx := i + 10 + l_dummy;

            Write_Debug(l_api_name || 'BEGIN: To Retrieve Attr Value at Position :'||l_actual_userattr_indx);

            ------------------------------------------------------------------------
            -- Depending upon the Data Type, populate corresponding field in the
            -- User-Defined Attribute Data record.
            ------------------------------------------------------------------------
            ------------------------------------------------------------------------
            -- Depending upon the Data Type, populate corresponding field in the
            -- User-Defined Attribute Data record.
            ------------------------------------------------------------------------
            -- bug: 5001315 Explicitly Nulling out the data columns. (this incorporates the fix for 4673865)
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_STR := NULL;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_NUM := NULL;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_DATE := NULL;
            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DISP_VALUE := NULL;--bugfix:6346771
            l_varchar_data := NULL;
            l_number_data := NULL;
            l_date_data := NULL;
            l_dummy_char := SUBSTR (l_intf_col_name_table(i), 1, 1);

            IF l_dummy_char = 'C' THEN
              DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, l_actual_userattr_indx, l_varchar_data);
              IF l_dummy_char = l_attr_data_type THEN
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_STR := l_varchar_data;
              ELSE
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DISP_VALUE := l_varchar_data;
              END IF;
              Write_Debug(l_api_name || 'String Value =>'||l_varchar_data);
            ELSIF l_dummy_char = 'N' THEN
              DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, l_actual_userattr_indx, l_number_data);
              IF l_dummy_char = l_attr_data_type THEN
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_NUM := l_number_data;
              ELSE
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DISP_VALUE := l_number_data;
              END IF;
              Write_Debug(l_api_name || 'Number Value =>'||l_number_data);
            ELSE --IF (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DATATYPE_CODE = 'D') THEN
              DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, l_actual_userattr_indx, l_date_data);
              IF l_dummy_char = l_attr_data_type THEN
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_DATE := l_date_data;
              ELSE
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DISP_VALUE := l_date_data;
              END IF;
              Write_Debug(l_api_name || 'Date Value =>'||l_date_data);
            END IF; --end: IF (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DATATYPE_CODE = 'C') THEN

      Write_Debug(l_api_name || 'END: Retrieved Attr Value');

            l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).INTF_COLUMN_NAME := l_intf_col_name_table(i);

            ------------------------------------------------------------------------
            -- Bug: 3025778 Modified If statment.
            -- Donot populate NULL Attribute value in the User-Defined Attrs
            -- Interface table.
            ------------------------------------------------------------------------
            IF ((l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_STR IS NULL) AND
                (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_NUM IS NULL) AND
                (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_DATE IS NULL) AND
                (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DISP_VALUE IS NULL)
               ) THEN
              ------------------------------------------------------------------------
              -- If all attribute values are NULL value, then delete
              -- the row from PLSQL table.
              ------------------------------------------------------------------------
              l_usr_attr_data_tbl.DELETE(l_rows_per_attr_grp_indx);
              l_rows_per_attr_grp_indx := l_rows_per_attr_grp_indx - 1;
              Write_Debug(l_api_name || 'Due to NULL Att data, resetting back the PLSQL table index to : '||l_rows_per_attr_grp_indx);

            END IF; --end: IF ((l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_STR...

          END IF; --end: IF c_attr_grp_details%FOUND THEN

          CLOSE c_attr_grp_details;
        ELSE -- R12C UOM Changes:if uom column comes, previous row was the number col. so not increasing index

           l_varchar_data := null;
           l_actual_userattr_indx := l_actual_userattr_indx +1 ;
           DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, l_actual_userattr_indx, l_uom_meaning);

           IF (l_uom_class IS NOT NULL AND l_uom_meaning IS NOT NULL) THEN --BugFix:6271824
             SELECT UOM_CODE
               INTO l_varchar_data
               FROM MTL_UNITS_OF_MEASURE_VL
              WHERE UOM_CLASS = l_uom_class
                AND UNIT_OF_MEASURE_TL = l_uom_meaning; -- Bug	6397849
           END IF;
           -- fix for bug 9044423 added IF condition
           IF (l_uom_meaning IS NOT NULL) THEN
              l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_UOM := l_varchar_data;
           END IF;
         Write_Debug(l_api_name || 'UOM CODE set  ' || l_varchar_data || ' at index ' || l_rows_per_attr_grp_indx);

        END IF ; --  end IF (  INSTR(l_attr_id_table(i),'$$UOM') = 0 ) -- R12C UOM Changes:

        END LOOP LIORUI_data_types_loop_2; --end: FOR i IN 1..l_attr_id_table.COUNT LOOP

      ELSE --end: IF DBMS_SQL.FETCH_ROWS(l_cursor_attr_id_val)>0 THEN

        Write_Debug(l_api_name || 'Nothing Found (or) Done.');
        EXIT;

      END IF; --IF DBMS_SQL.FETCH_ROWS(l_cursor_attr_id_val)>0 THEN

    END LOOP LIORUI_ebi_rows_loop; --END: LOOP FOR CURSOR_ATTR_ID_VAL

    l_attr_id_table.DELETE;
    l_intf_col_name_table.DELETE;
    l_data_level_id_table.DELETE;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_attr_id_val);

    -------------------------------------------------------------------
    -- Loop for all the rows to be inserted per Attribute Group.
    -------------------------------------------------------------------
    <<LIORUI_attrs_loop>>
    FOR i IN 1..l_rows_per_attr_grp_indx LOOP

      Write_Debug(l_api_name || 'LIORUI_attrs_loop - ' || i);

      -------------------------------------------------------------------------
      -- Fix for Bug# 3808455. To avoid the following error:
      -- ORA-01401: inserted value too large for column
      -- [This is done because ATTR_DISP_VALUE size is 1000 Chars]
      -------------------------------------------------------------------------
      IF ( LENGTH(l_usr_attr_data_tbl(i).ATTR_VALUE_STR) > 1000 ) THEN
          l_token_tbl_one(1).token_name  := 'VALUE';
          l_token_tbl_one(1).token_value := l_usr_attr_data_tbl(i).ATTR_VALUE_STR;

          Error_Handler.Add_Error_Message
            ( p_message_name   => 'EGO_STR_ATTR_LEN_GT1000_ERR'
            , p_application_id => 'EGO'
            , p_message_text   => NULL
            , p_token_tbl      => l_token_tbl_one
            , p_message_type   => 'E'
            , p_row_identifier => l_usr_attr_data_tbl(i).TRANSACTION_ID
            , p_table_name     => G_ERROR_TABLE_NAME
            , p_entity_id      => NULL
            , p_entity_index   => NULL
            , p_entity_code    => G_ERROR_ENTITY_CODE
            );

      ---------------------------------------------------------------------------
      -- Put multiple ELSIF <<condition>> here, to report Errors with the Data.
      -- Finally, ELSE condition below means that Data is ~Error Free~ and ready
      -- to be Inserted.
      ---------------------------------------------------------------------------

      ELSE --IF ( LENGTH(l_usr_attr_data_tbl(i)..

        ------------------------------------------------------------------------
        -- Populate l_varchar_data, to later populate in ATTR_DISP_VALUE
        ------------------------------------------------------------------------
--        IF (NVL(l_usr_attr_data_tbl(i).ATTR_VALUE_STR,EGO_ITEM_PUB.G_INTF_NULL_CHAR) <> EGO_ITEM_PUB.G_INTF_NULL_CHAR) THEN
--           l_varchar_data := l_usr_attr_data_tbl(i).ATTR_VALUE_STR;
--        ELSE
--          l_varchar_data := NULL;
--        END IF;
        IF (l_usr_attr_data_tbl(i).ATTR_DATATYPE_CODE = 'C') THEN
--           IF (NVL(l_usr_attr_data_tbl(i).ATTR_VALUE_STR,EGO_ITEM_PUB.G_INTF_NULL_CHAR) <> EGO_ITEM_PUB.G_INTF_NULL_CHAR ) THEN
              l_varchar_data := NVL(l_usr_attr_data_tbl(i).ATTR_VALUE_STR,l_usr_attr_data_tbl(i).ATTR_DISP_VALUE);
--           END IF;
        ELSIF (l_usr_attr_data_tbl(i).ATTR_DATATYPE_CODE = 'N') THEN
--           IF (NVL(l_usr_attr_data_tbl(i).ATTR_VALUE_NUM,EGO_ITEM_PUB.G_INTF_NULL_NUM) <> EGO_ITEM_PUB.G_INTF_NULL_NUM) THEN
              l_varchar_data := NVL(To_char(l_usr_attr_data_tbl(i).ATTR_VALUE_NUM),l_usr_attr_data_tbl(i).ATTR_DISP_VALUE);
              BEGIN
                IF (TO_NUMBER(l_varchar_data) = EGO_ITEM_PUB.G_INTF_NULL_NUM) THEN
                  l_varchar_data := EGO_USER_ATTRS_BULK_PVT.G_NULL_NUM_VAL_STR;
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  -- the value needs to be checked against value set
                  NULL;
              END;
              Write_Debug(l_api_name || 'l_varchar_data => ' || l_varchar_data);
--           END IF;
        ELSIF (l_usr_attr_data_tbl(i).ATTR_DATATYPE_CODE = 'D') THEN
           IF (l_usr_attr_data_tbl(i).ATTR_VALUE_DATE  = G_EXCEL_NULL_DATE) THEN
              l_varchar_data := To_Char(EGO_ITEM_PUB.G_INTF_NULL_DATE,G_DATE_FORMAT);
            ELSE
              l_varchar_data := NVL(To_Char(l_usr_attr_data_tbl(i).ATTR_VALUE_DATE , G_DATE_FORMAT),l_usr_attr_data_tbl(i).ATTR_DISP_VALUE);
           END IF;
        END IF; --end: IF (l_usr_attr_data_tbl(i).ATTR_DATATYPE_CODE = 'C') THEN

        -----------------------------------------------------------------------------------
        -- Checking for the transaction_type, if CREATE/UPDATE populate
        -- EGO_ITM_USR_ATTR_INTRFC with SYNC else the user-given Transaction_type is passed
        -----------------------------------------------------------------------------------
        l_transaction_type := l_usr_attr_data_tbl(i).TRANSACTION_TYPE;
        /* Bug 12656687 - Start. Will change the transaction type to SYNC only if user has given UPDATE. */
        -- IF (l_transaction_type = G_CREATE OR l_transaction_type = G_UPDATE) THEN
        IF (l_transaction_type = G_UPDATE) THEN
        -- Bug 12656687 : End
           l_transaction_type := G_SYNC;
        END IF; --transaction_type check (Bug5201097)

        ----------------------------------------------------------------------
        -- 1)
        -- The User-Defined Attrs BO has some validation changes, which
        -- mandates users to pass in the display value, so that BO does the
        -- conversion to internal value. To support that change, I need to
        -- populate ATTR_DISP_VALUE instead of internal columns :
        -- ATTR_VALUE_STR, ATTR_VALUE_DATE, ATTR_VALUE_NUM.
        -- Above change to populate ATTR_DISP_VALUE was advised by DAARENA
        -- (Dylan Arena)
        --
        -- 2)
        -- TRANSACTION_TYPE, PROCESS_STATUS need *not* be populated as they
        -- are defaulted by the User Attrs PLSQL Program
        ----------------------------------------------------------------------

        INSERT INTO EGO_ITM_USR_ATTR_INTRFC
        (
         DATA_SET_ID          ,
         TRANSACTION_ID       ,
         TRANSACTION_TYPE     ,
         INVENTORY_ITEM_ID    ,
         ORGANIZATION_ID      ,
         REVISION_ID          ,
         ITEM_NUMBER          ,
         ORGANIZATION_CODE    ,
         REVISION             ,
         ROW_IDENTIFIER       ,
         ATTR_GROUP_INT_NAME  ,
         ATTR_INT_NAME        ,
         ATTR_DISP_VALUE      ,
         PROCESS_STATUS       ,
         SOURCE_SYSTEM_ID     ,
         SOURCE_SYSTEM_REFERENCE,
         ATTR_GROUP_TYPE,         --Bug Fix 4630163(ISSUE2)
         ITEM_CATALOG_GROUP_ID,    --Bug Fix 5179741
         DATA_LEVEL_ID       ,
         PK1_VALUE           ,
         PK2_VALUE           ,
         ATTR_VALUE_UOM          --R12C UOM Changes
        )
        VALUES
        (
         l_usr_attr_data_tbl(i).DATA_SET_ID,
         l_usr_attr_data_tbl(i).TRANSACTION_ID,
         l_transaction_type,                  --l_usr_attr_data_tbl(i).TRANSACTION_TYPE,
         l_usr_attr_data_tbl(i).INVENTORY_ITEM_ID,
         l_usr_attr_data_tbl(i).ORGANIZATION_ID,
         l_usr_attr_data_tbl(i).REVISION_ID,
         l_usr_attr_data_tbl(i).ITEM_NUMBER,
         l_usr_attr_data_tbl(i).ORGANIZATION_CODE,
         l_usr_attr_data_tbl(i).REVISION,
         l_usr_attr_data_tbl(i).ROW_IDENTIFIER,
         l_usr_attr_data_tbl(i).ATTR_GROUP_NAME,
         l_usr_attr_data_tbl(i).ATTR_NAME,
         l_varchar_data,                                     -- ATTR_DISP_VALUE
         G_PROCESS_STATUS,
         l_usr_attr_data_tbl(i).SOURCE_SYSTEM_ID,
         l_usr_attr_data_tbl(i).SOURCE_SYSTEM_REFERENCE,
         l_usr_attr_data_tbl(i).ATTR_GROUP_TYPE,        --Bug Fix 4630163(ISSUE2)
         G_CATALOG_GROUP_ID,                             --Bug Fix 5179741
         l_usr_attr_data_tbl(i).DATA_LEVEL_ID,
         l_usr_attr_data_tbl(i).PK1_VALUE,
         l_usr_attr_data_tbl(i).PK2_VALUE,
         l_usr_attr_data_tbl(i).ATTR_VALUE_UOM  --R12C UOM Changes
        );

        Write_Debug(l_api_name || 'DataSetID       ['||l_usr_attr_data_tbl(i).DATA_SET_ID||'] '||G_NEWLINE||
                    l_api_name || 'TransactionID   ['||l_usr_attr_data_tbl(i).TRANSACTION_ID||'] '||G_NEWLINE||
                    l_api_name || 'TransactionType   ['||l_usr_attr_data_tbl(i).TRANSACTION_TYPE||'] '||G_NEWLINE||
                    l_api_name || 'InventoryItemID ['||l_usr_attr_data_tbl(i).INVENTORY_ITEM_ID||'] '||G_NEWLINE||
                    l_api_name || 'OrganizationID  ['||l_usr_attr_data_tbl(i).ORGANIZATION_ID||'] '||G_NEWLINE||
                    l_api_name || 'RevisionID      ['||l_usr_attr_data_tbl(i).REVISION_ID||'] '||G_NEWLINE||
                    l_api_name || 'ItemNumber      ['||l_usr_attr_data_tbl(i).ITEM_NUMBER||'] '||G_NEWLINE||
                    l_api_name || 'OrganizationCode['||l_usr_attr_data_tbl(i).ORGANIZATION_CODE||'] '||G_NEWLINE||
                    l_api_name || 'Revision        ['||l_usr_attr_data_tbl(i).REVISION||'] '||G_NEWLINE||
                    l_api_name || 'RowIdentifier   ['||l_usr_attr_data_tbl(i).ROW_IDENTIFIER||'] '||G_NEWLINE||
                    l_api_name || 'AttrGroupType   ['||l_usr_attr_data_tbl(i).ATTR_GROUP_TYPE||'] '||G_NEWLINE||--Bug Fix 4630163(ISSUE2)
                    l_api_name || 'AttrGroupName   ['||l_usr_attr_data_tbl(i).ATTR_GROUP_NAME||'] '||G_NEWLINE||
                    l_api_name || 'AttrName        ['||l_usr_attr_data_tbl(i).ATTR_NAME||'] '||G_NEWLINE||
                    l_api_name || ': Populated ATTR_DISP_VALUE of DataType['||l_usr_attr_data_tbl(i).ATTR_DATATYPE_CODE||'] => '||l_varchar_data||G_NEWLINE||
                    l_api_name || ' Catalog Group ID ['||G_CATALOG_GROUP_ID||']');

      END IF; --end: IF ( LENGTH(l_usr_attr_data_tbl(i)..

    END LOOP LIORUI_attrs_loop; --FOR i IN 1..l_usr_attr_data_tbl.COUNT LOOP

    Write_Debug(l_api_name || 'EIAI: Populated the Item / Item-Revision User-Defined Attr Values for Attribute Group : '||l_attr_group_int_name);

  END LOOP LIORUI_attr_groups_loop; --FOR c_attr_grp_rec IN c_user_attr_group_codes

  Write_Debug(l_api_name || 'EIAI: DONE Populating the Item / Item-Revision User-Defined Attr Values');

  Write_Debug(l_api_name || 'END load_itm_or_rev_usrattr_intf()');


 EXCEPTION
   WHEN OTHERS THEN
      x_retcode := G_STATUS_ERROR;
      x_errbuff := SUBSTRB(SQLERRM, 1,240);
      Write_Debug(l_api_name || 'Load_itm_or_rev_usrattr_intf : EXCEPTION HAPPENED => '||x_errbuff);
      RAISE;

END load_itm_or_rev_usrattr_intf;

--================================================================================--
-- 11.5.10 New Functionality: Item Operational Attributes Bulkload (bug# 3293098) --
-- PPEDDAMA (1/31/2004)                                                           --
--================================================================================--

  ---------------------------------------------------------------
  --This method populates Item Operational attributes in MSII.
  ---------------------------------------------------------------

PROCEDURE load_item_oper_attr_values
               (
                 p_resultfmt_usage_id    IN         NUMBER
                ) IS

    -- Start OF comments
    -- API name  : Populate MSII Item Interface Lines
    -- Pre-reqs  : None
    -- FUNCTION  : Populate and Loads Item operational attribute values in MSII.
    --             These operational attributes made available in Item Search Results
    --             through User-Defined Attributes framework.
    --
    --             Errors are populated in MTL_INTERFACE_ERRORS
    --

  ------------------------------------------------------------------------
  -- To get the count of Item Operational Attr Groups Result Format.    --
  ------------------------------------------------------------------------
  CURSOR c_item_oper_attr_grp_count (c_resultfmt_usage_id  IN  NUMBER) IS
    SELECT count(distinct(To_Number(SUBSTR(attribute_code, 1, INSTR(attribute_code, '$$') - 1))))
    FROM   ego_results_fmt_usages
    WHERE  resultfmt_usage_id = c_resultfmt_usage_id
     AND attribute_code LIKE '%$$%'
     -- Following statement fetches the Attribute Group Id --
     AND To_Number(SUBSTR(attribute_code, 1, INSTR(attribute_code, '$$') - 1)) IN
     (
        SELECT ATTR_GROUP_ID
        FROM   EGO_ATTR_GROUPS_V
        WHERE  ATTR_GROUP_TYPE = G_ERP_ATTR_GROUP_TYPE
         AND   APPLICATION_ID = G_APPLICATION_ID
     );

  ------------------------------------------------------------------------
  -- To get the Item Operational Attr Groups in the Result Format.      --
  ------------------------------------------------------------------------
  CURSOR c_item_oper_attr_grp_ids (c_resultfmt_usage_id  IN  NUMBER) IS
    SELECT distinct(To_Number(SUBSTR(attribute_code, 1, INSTR(attribute_code, '$$') - 1))) OPER_ATTR_GRP_ID
    FROM   ego_results_fmt_usages
    WHERE  resultfmt_usage_id = c_resultfmt_usage_id
     AND attribute_code LIKE '%$$%'
     -- Following statement fetches the Attribute Group Id --
     AND To_Number(SUBSTR(attribute_code, 1, INSTR(attribute_code, '$$') - 1)) IN
     (
        SELECT ATTR_GROUP_ID
        FROM   EGO_ATTR_GROUPS_V
        WHERE  ATTR_GROUP_TYPE = G_ERP_ATTR_GROUP_TYPE
         AND   APPLICATION_ID = G_APPLICATION_ID
     );

  ---------------------------------------------------------------
  -- To get the Item Operational attr columns in the Result Format.
  ---------------------------------------------------------------
  CURSOR c_item_oper_attr_intf_cols ( c_resultfmt_usage_id  IN  NUMBER
                                     ,c_attr_group_id       IN  NUMBER
                                    ) IS
    -- First column is the Attibute Id --
    SELECT   To_Number(SUBSTR(attribute_code, INSTR(attribute_code, '$$')+2))
           , intf_column_name
    FROM   ego_results_fmt_usages
    WHERE  resultfmt_usage_id = c_resultfmt_usage_id
     AND   INSTR(attribute_code, '$$UOM') = 0  -- R12C UOM Change : ignoring uom columns in this case:
     AND   To_Number(SUBSTR(attribute_code, 1, INSTR(attribute_code, '$$') - 1)) = c_attr_group_id;

  l_item_oper_attr_sql     VARCHAR2(1000) :=
       ' SELECT   To_Number(SUBSTR(attribute_code, INSTR(attribute_code, ''$$'')+2))   '
    || '        , intf_column_name '
    || ' FROM   ego_results_fmt_usages '
    || ' WHERE  resultfmt_usage_id = :RESULTFMT_USAGE_ID '
    || ' AND   INSTR(attribute_code, ''$$UOM'') = 0 '  -- R12C UOM Change : ignoring uom columns in this case:
    || ' AND    To_Number(SUBSTR(attribute_code, 1, INSTR(attribute_code, ''$$'') - 1)) = :ATTR_GROUP_ID ';

  -------------------------------------------------------------------------
  -- To get the Attribute Name (Table performs better than EGO_ATTRS_V)  --
  -------------------------------------------------------------------------
  CURSOR c_attr_name ( c_attr_id  IN  NUMBER) IS
    SELECT ext.application_column_name , TL.FORM_LEFT_PROMPT
    FROM   ego_fnd_df_col_usgs_ext ext, FND_DESCR_FLEX_COL_USAGE_TL TL
    WHERE  ext.attr_id = c_attr_id
    AND    TL.LANGUAGE = USERENV('LANG')
    AND    EXT.DESCRIPTIVE_FLEXFIELD_NAME  = TL.DESCRIPTIVE_FLEXFIELD_NAME
    AND    EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE  = TL.DESCRIPTIVE_FLEX_CONTEXT_CODE
    AND    EXT.APPLICATION_COLUMN_NAME  = TL.APPLICATION_COLUMN_NAME
    AND    EXT.APPLICATION_ID = TL.APPLICATION_ID; -- Bug 6531938

     -----------------------------------------------------------
     --      local objects and object variables               --
     -----------------------------------------------------------

     l_attr_metadata_table           EGO_ATTR_METADATA_TABLE;
     l_attr_metadata_obj             EGO_ATTR_METADATA_OBJ;
     l_user_attr_data_obj            EGO_USER_ATTR_DATA_OBJ;
     l_user_attr_data_table          EGO_USER_ATTR_DATA_TABLE;
     l_attr_group_metadata_obj       EGO_ATTR_GROUP_METADATA_OBJ;
     l_ext_table_metadata_obj        EGO_EXT_TABLE_METADATA_OBJ;
     l_pk_column_name_value_pairs    EGO_COL_NAME_VALUE_PAIR_ARRAY;

     ----------------------------------------
     --      local variables               --
     ----------------------------------------

     l_item_oper_attr_grp_count            NUMBER;
     l_item_oper_attr_grp_id               NUMBER;
     l_count                               NUMBER(5);
     l_indx                                NUMBER(15);
     l_transaction_id                      NUMBER(15);
     l_object_id                           NUMBER(5);

     l_dyn_sql                             VARCHAR2(10000);
     l_item_id_char                        VARCHAR2(15);
     l_org_id_char                         VARCHAR2(15);
     l_trans_type_char                     VARCHAR2(15);
     l_attr_name                           VARCHAR2(100);

     l_attr_id_table                   DBMS_SQL.NUMBER_TABLE;
     l_attr_disp_name_table            DBMS_SQL.VARCHAR2_TABLE;
     l_intf_col_table                  DBMS_SQL.VARCHAR2_TABLE;
     l_attr_disp_val_table             DBMS_SQL.VARCHAR2_TABLE;
     l_attr_int_val_table              DBMS_SQL.VARCHAR2_TABLE;
     l_msii_col_table                  DBMS_SQL.VARCHAR2_TABLE;

     -- Example Data Types to be used in Bind Variable. --
     l_varchar_example        VARCHAR2(1000);
     l_number_example         NUMBER;
     l_date_example           DATE;

     -- Actual Data to store corresponding data type value. --
     l_varchar_data           VARCHAR2(1000);
     l_number_data            NUMBER;

     -- DBMS_SQL Open Cursor integers. --
     l_cursor_oper_attr       INTEGER;
     l_execute                INTEGER;

     --API return parameters
     l_retcode               VARCHAR2(10);
     l_errbuff               VARCHAR2(2000);
     l_ebi_err_msg           VARCHAR2(2000);
     l_dyn_sql_ebi           VARCHAR2(2000);

BEGIN

   --------------------------------------------------------------------------------
   -- Fetch the Object Id. If not found, SQL exception gets thrown.              --
   --------------------------------------------------------------------------------
   SELECT OBJECT_ID
     INTO l_object_id
   FROM   FND_OBJECTS
   WHERE  OBJ_NAME = G_EGO_ITEM_OBJ_NAME;

  l_ext_table_metadata_obj :=  EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata (l_object_id);

   --------------------------------------------------------------------------------
   -- Fetch the count of Operational Attribute Groups in the Result Format  --
   --------------------------------------------------------------------------------
   OPEN c_item_oper_attr_grp_count(p_resultfmt_usage_id);
   FETCH c_item_oper_attr_grp_count INTO l_item_oper_attr_grp_count;
   IF c_item_oper_attr_grp_count%NOTFOUND THEN
     ----------------------------------------------------------------------------
     -- There are *no* operational attribute groups to load. Hence return. --
     ----------------------------------------------------------------------------
     Write_Debug('load_item_oper_attr_values: There are *NO* Operational Attribute Groups to load! Hence RETURNing!!');
     RETURN;

   END IF;
   CLOSE c_item_oper_attr_grp_count;

   IF (l_item_oper_attr_grp_count > 0) THEN

     FOR attr_grp_id_rec IN c_item_oper_attr_grp_ids(p_resultfmt_usage_id)
     LOOP
      IF (attr_grp_id_rec.OPER_ATTR_GRP_ID IS NOT NULL) THEN

        ------------------------------------------------------------------------------
        -- Deleting all the earlier retrieved rows from these temp PLSQL tables,
        -- and Starting afresh.
        -- NOTE: l_attr_id_table.COUNT will be >0, only from second exec of the loop.
        ------------------------------------------------------------------------------
        IF (l_attr_id_table.COUNT > 0) THEN
          l_attr_id_table.DELETE;
          l_intf_col_table.DELETE;
        END IF; --end: IF (l_attr_id_table.COUNT > 0)

        ----------------------------------------------------------------------------
        -- Fetch the Attr Group Meta Data object.                                 --
        -- Object will be retained until per Attr Group operational attribute     --
        -- values for all rows are processed.                                    --
        ----------------------------------------------------------------------------
        l_attr_group_metadata_obj :=
        EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata (
              p_attr_group_id       => attr_grp_id_rec.OPER_ATTR_GRP_ID
             ,p_application_id      => G_APPLICATION_ID
             ,p_attr_group_type     => G_ERP_ATTR_GROUP_TYPE
             );

        ----------------------------------------------------------------------------
        -- Fetch the Attr Group Meta Data table.                                  --
        -- Table will be retained until per Attr Group operational attribute     --
        -- values for all rows are processed.                                    --
        ----------------------------------------------------------------------------
        l_attr_metadata_table := l_attr_group_metadata_obj.attr_metadata_table;

        ----------------------------------------------------------------------------
        -- Fetch the Oper Attrs IDs, Intf Column names.                           --
        ----------------------------------------------------------------------------
        Write_Debug(l_item_oper_attr_sql);

        l_cursor_oper_attr := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(l_cursor_oper_attr, l_item_oper_attr_sql, DBMS_SQL.NATIVE);
        DBMS_SQL.DEFINE_ARRAY(
                           c           => l_cursor_oper_attr -- cursor --
                         , position    => 1                  -- select position --
                         , n_tab       => l_attr_id_table    -- table of numbers --
                         , cnt         => 2500               -- rows requested --
                         , lower_bound => 1                  -- start at --
                             );
        DBMS_SQL.DEFINE_ARRAY(
                           c           => l_cursor_oper_attr -- cursor --
                         , position    => 2                  -- select position --
                         , c_tab       => l_intf_col_table   -- table of varchar --
                         , cnt         => 2500               -- rows requested --
                         , lower_bound => 1                  -- start at --
                             );

        DBMS_SQL.BIND_VARIABLE(l_cursor_oper_attr,':RESULTFMT_USAGE_ID', p_resultfmt_usage_id);
        DBMS_SQL.BIND_VARIABLE(l_cursor_oper_attr,':ATTR_GROUP_ID', attr_grp_id_rec.OPER_ATTR_GRP_ID);
        Write_Debug('Binding :RESULTFMT_USAGE_ID to => '||p_resultfmt_usage_id);
        Write_Debug('Binding :ATTR_GROUP_ID to => '||attr_grp_id_rec.OPER_ATTR_GRP_ID);

        l_execute := DBMS_SQL.EXECUTE(l_cursor_oper_attr);
        l_count := DBMS_SQL.FETCH_ROWS(l_cursor_oper_attr);
        DBMS_SQL.COLUMN_VALUE(l_cursor_oper_attr, 1, l_attr_id_table);
        DBMS_SQL.COLUMN_VALUE(l_cursor_oper_attr, 2, l_intf_col_table);

        Write_Debug('load_item_oper_attr_values: Retrieved rows => '||To_char(l_count));
        DBMS_SQL.CLOSE_CURSOR(l_cursor_oper_attr);

        ----------------------------------------------------------------------------
        -- Fetch the Oper Attrs values from EGO_BULKLOAD_INTF.                    --
        ----------------------------------------------------------------------------

        l_cursor_oper_attr := DBMS_SQL.OPEN_CURSOR;
        l_dyn_sql := ' SELECT ';
        l_dyn_sql := l_dyn_sql || ' TRANSACTION_ID , ';
        l_dyn_sql := l_dyn_sql || ' UPPER(TRANSACTION_TYPE) , ';
        l_dyn_sql := l_dyn_sql || ' INSTANCE_PK1_VALUE , ';
        l_dyn_sql := l_dyn_sql || ' INSTANCE_PK2_VALUE , ';
        FOR i in 1..l_attr_id_table.COUNT LOOP
          IF (i <> l_attr_id_table.COUNT) THEN
            l_dyn_sql := l_dyn_sql || l_intf_col_table(i) || ' , ';
        ELSE
            l_dyn_sql := l_dyn_sql || l_intf_col_table(i) || '  ';
          END IF;
        END LOOP; --FOR (i in 1..l_attr_id_table.COUNT) LOOP
        l_dyn_sql := l_dyn_sql || ' FROM   EGO_BULKLOAD_INTF ';
        l_dyn_sql := l_dyn_sql || ' WHERE  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID ';
        l_dyn_sql := l_dyn_sql || '  AND   PROCESS_STATUS = 1 ';

        Write_Debug(l_dyn_sql);
        DBMS_SQL.PARSE(l_cursor_oper_attr, l_dyn_sql, DBMS_SQL.NATIVE);

        ----------------------------------------------------------------------------
        -- Setting the Data type for Oper Attrs values before Select.             --
        ----------------------------------------------------------------------------
        -- Setting Data Type for Trasaction ID --
        DBMS_SQL.DEFINE_COLUMN(l_cursor_oper_attr, 1, l_number_example);
        -- Setting Data Type for Transaction Type --
        DBMS_SQL.DEFINE_COLUMN(l_cursor_oper_attr, 2, l_varchar_example, 1000);
        --Setting Data Type for INSTANCE_PK1_VALUE (Item ID)
        DBMS_SQL.DEFINE_COLUMN(l_cursor_oper_attr, 3, l_varchar_example, 1000);
        --Setting Data Type for INSTANCE_PK2_VALUE (Org ID)
        DBMS_SQL.DEFINE_COLUMN(l_cursor_oper_attr, 4, l_varchar_example, 1000);
        FOR i in 1..l_attr_id_table.COUNT LOOP
          ------------------------------------------------------------------------------------
          -- Since TRANSACTION_ID, TRANSACTION_TYPE, INSTANCE_PK1_VALUE, INSTANCE_PK2_VALUE --
          -- are added to the SELECT before we need to adjust the index as follows.         --
          ------------------------------------------------------------------------------------
          l_indx := i + 4;
          DBMS_SQL.DEFINE_COLUMN(l_cursor_oper_attr, l_indx, l_varchar_example, 1000);
        END LOOP; --2nd: FOR (i in 1..l_attr_id_table.COUNT) LOOP

        ----------------------------------------------------------------------------
        -- Binding the ResultFmtUsageId and Executing the Query.                  --
        ----------------------------------------------------------------------------
        DBMS_SQL.BIND_VARIABLE(l_cursor_oper_attr,':RESULTFMT_USAGE_ID',p_resultfmt_usage_id);
        l_execute := DBMS_SQL.EXECUTE(l_cursor_oper_attr);

        LOOP --Loop for l_cursor_oper_attr

          IF DBMS_SQL.FETCH_ROWS(l_cursor_oper_attr)>0 THEN

            DBMS_SQL.COLUMN_VALUE(l_cursor_oper_attr, 1, l_transaction_id);
            DBMS_SQL.COLUMN_VALUE(l_cursor_oper_attr, 2, l_trans_type_char);
            DBMS_SQL.COLUMN_VALUE(l_cursor_oper_attr, 3, l_item_id_char);
            DBMS_SQL.COLUMN_VALUE(l_cursor_oper_attr, 4, l_org_id_char);

            Write_Debug('load_item_oper_attr_values: l_trans_type_char => '||l_trans_type_char);
            ------------------------------------------------------------------------------------
            -- Prepare Primary Key Name Value pair object.                                    --
            -- In case of CREATE, pass in a blank object.                                     --
            ------------------------------------------------------------------------------------
              l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
                                              (
                                               EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', l_item_id_char)
                                              ,EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', l_org_id_char)
                                              );

            --------------------------------------------------------------------------------
            -- Create a table of Usr Attr Data objects that will be used for              --
            -- Display to Internal value conversions.                                     --
            --------------------------------------------------------------------------------
            l_user_attr_data_table := EGO_USER_ATTR_DATA_TABLE();

            -- bug 4699499 deleting the msii column table
            IF (l_msii_col_table.COUNT > 0) THEN
              Write_Debug('load_item_oper_attr_values: Deleting msii col table ');
              l_msii_col_table.DELETE;
            END IF; --end: IF (l_msii_col_table.COUNT > 0)

            FOR i in 1..l_attr_id_table.COUNT LOOP
              ------------------------------------------------------------------------------------
              -- Since TRANSACTION_ID, TRANSACTION_TYPE, INSTANCE_PK1_VALUE, INSTANCE_PK2_VALUE --
              -- are added to the SELECT before we need to adjust the index as follows.         --
              ------------------------------------------------------------------------------------
              l_indx := i + 4;
              DBMS_SQL.COLUMN_VALUE(l_cursor_oper_attr, l_indx, l_varchar_data);
              Write_Debug('load_item_oper_attr_values: String Value =>'||l_varchar_data);

              -- store the Display values in a plsql table --
              l_attr_disp_val_table(i) := l_varchar_data;

              --------------------------------------------------------------------------------
              -- Fetch the Attribute name based on the attribute id.                        --
              --------------------------------------------------------------------------------
              OPEN c_attr_name(l_attr_id_table(i));
              FETCH c_attr_name INTO l_attr_name, l_attr_disp_name_table(i);
              IF c_attr_name%NOTFOUND THEN

                ----------------------------------------------------------------------------
                -- This shouldnot happen. All Oper Attr Ids should map to Attr names.     --
                -- Print the following debug statement and RETURN.                        --
                ----------------------------------------------------------------------------
                Write_Debug('load_item_oper_attr_values: Houston we have a problem! No Attr Name found!!!');
                RETURN;
              END IF; -- IF c_attr_name%NOTFOUND THEN
              CLOSE c_attr_name;
              Write_Debug('load_item_oper_attr_values: l_attr_name => '||l_attr_name);

              --------------------------------------------------------------------------------
              -- The Attribute name is the MSII DB Column name.                             --
              --------------------------------------------------------------------------------
              l_msii_col_table(i) := l_attr_name;

              ------------------------------------------------------------------------------------
              -- Prepare a table of l_user_attr_data_objects.                                   --
              -- Dylan's mail below on, why we need to get all the objects into the table       --
              -- l_user_attr_data_objects, before we start any disp-to-int value processing:    --                                --
              --                                                                                --
              -- Dylan's mail (Dated: 1/30/2004)                                                --
              -- It occurred to me that adding Attrs one by one as we go might not prove to be  --
              -- sufficient, because there's no guarantee we'll be processing the Attrs in      --
              -- their correct order: for e.g. If Attr2 required Attr1 for its ValueSet query, --
              -- what if we ended up processing Attr2 before Attr1?  In such a case, even if   --
              -- the user passed Attr1's value, our one by one method of adding elements to our --
              -- data table wouldn't work.                                                      --
              -- So it will probably be better to                                               --
              -- 1. Pull all Attrs for an AG                                                    --
              -- 2. Fetch their AG metadata (with call to EGO_USER_ATTRS_COMMON_PVT)                             --
              -- 3. Create Attr data elems for all passed values and add them to table          --
              -- 4. Then process Attrs in the AG                                                --
              ------------------------------------------------------------------------------------
              l_user_attr_data_obj := EGO_USER_ATTR_DATA_OBJ(
                                                  1                          --ROW_IDENTIFIER
                                                 ,l_attr_name                --ATTR_INT_NAME
                                                 ,null                       --ATTR_VALUE_STR
                                                 ,null                       --ATTR_VALUE_NUM
                                                 ,null                       --ATTR_VALUE_DATE
                                                 ,l_attr_disp_val_table(i)   --ATTR_DISP_VALUE
                                                 ,null                       --ATTR_UNIT_OF_MEASURE
                                                 ,l_transaction_id           --TRANSACTION_ID
                                                 );

              l_user_attr_data_table.EXTEND();
              l_user_attr_data_table(l_user_attr_data_table.LAST) := l_user_attr_data_obj;

             END LOOP; --FOR (i in 1..l_attr_id_table.COUNT) LOOP

            --------------------------------------------------------------------------------
            -- Create a table of internal values for attributes that will be used to     --
            -- uploading into the MSII.                                                   --
            --------------------------------------------------------------------------------
            FOR i in 1..l_attr_id_table.COUNT LOOP

              ------------------------------------------------------------------------------------
              -- Get the Attribute Metadata Object, that will be used to check if the           --
              -- attribute needs Display to Internal value conversion.                          --
              ------------------------------------------------------------------------------------
              l_attr_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Find_Metadata_For_Attr
                                     (
                                      p_attr_metadata_table => l_attr_metadata_table
                                     ,p_attr_id             => l_attr_id_table(i)
                                     );

              ------------------------------------------------------------------------------------
              -- Derive the internal value by passing all the objects created above.            --
              -- Following is to check if there is a need for conversion.                       --
              ------------------------------------------------------------------------------------
              IF (l_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE OR
                  l_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_TRANS_IND_VALIDATION_CODE OR
                  l_attr_metadata_obj.VALIDATION_CODE = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE) THEN

                l_attr_int_val_table(i) :=
                    EGO_USER_ATTRS_DATA_PVT.Get_Int_Val_For_Disp_Val
                          (
                           l_attr_metadata_obj              --EGO_ATTR_METADATA_OBJ
                          ,l_user_attr_data_table(i)        --EGO_USER_ATTR_DATA_OBJ
                          ,l_attr_group_metadata_obj        --EGO_ATTR_GROUP_METADATA_OBJ
                          ,l_ext_table_metadata_obj         --EGO_EXT_TABLE_METADATA_OBJ
                          ,l_pk_column_name_value_pairs     --EGO_COL_NAME_VALUE_PAIR_ARRAY
                          -- following is used in case of Revisions. --
                          ,NULL                             --EGO_COL_NAME_VALUE_PAIR_ARRAY (p_data_level_name_value_pairs)
                          ,G_ENTITY_ID                      --p_entity_id
                          ,NULL                             --p_entity_index
                          ,G_ENTITY_CODE                    --p_entity_code
                          ,l_user_attr_data_table           --EGO_USER_ATTR_DATA_TABLE
                          );

                IF l_attr_disp_val_table(i) IS NOT NULL AND l_attr_int_val_table(i) IS NULL THEN
                  IF    l_attr_metadata_obj.data_type_code = 'C' AND
                        l_attr_disp_val_table(i) = EGO_ITEM_PUB.G_INTF_NULL_CHAR THEN
                     l_attr_int_val_table(i) :=  EGO_ITEM_PUB.G_INTF_NULL_CHAR;
                  ELSIF l_attr_metadata_obj.data_type_code = 'N' THEN
                    BEGIN
                      IF (l_attr_disp_val_table(i) = EGO_ITEM_PUB.G_INTF_NULL_CHAR OR
                          TO_NUMBER(l_attr_disp_val_table(i)) = EGO_ITEM_PUB.G_INTF_NULL_NUM
                         ) THEN
                        l_attr_int_val_table(i) :=  EGO_ITEM_PUB.G_INTF_NULL_NUM;
                      END IF;
                    EXCEPTION
                      WHEN OTHERS THEN
                        -- the value needs to be checked against value set
                        NULL;
                    END;
                  ELSIF l_attr_metadata_obj.data_type_code IN ('X','Y') THEN
                    BEGIN
                      IF (l_attr_disp_val_table(i) = EGO_ITEM_PUB.G_INTF_NULL_CHAR OR
                          TO_DATE(l_attr_disp_val_table(i),G_DATE_FORMAT) = EGO_ITEM_PUB.G_INTF_NULL_DATE
                         ) THEN
                        l_attr_int_val_table(i) :=  EGO_ITEM_PUB.G_INTF_NULL_DATE;
                      END IF;
                    EXCEPTION
                      WHEN OTHERS THEN
                        -- the value needs to be checked against value set
                        NULL;
                    END;
                  END IF;
                END IF;
              ELSE
                 -- Value passed by user is Internal value --
                 l_attr_int_val_table(i) := l_attr_disp_val_table(i);
              END IF; --IF (l_attr_metadata_obj.VALIDATION_CODE ...
              Write_Debug('load_item_oper_attr_values: Internal Value for '||l_attr_metadata_obj.attr_disp_name ||' => '||l_attr_disp_val_table(i)||' is: '||l_attr_int_val_table(i));
            END LOOP; --FOR (i in 1..l_attr_id_table.COUNT) LOOP

            --------------------------------------------------------------------------------
            -- Update MSII with the internal values derived above for the row.           --
            -- Update that particular row using Transaction ID.                           --
            --------------------------------------------------------------------------------

            l_dyn_sql := 'UPDATE MTL_SYSTEM_ITEMS_INTERFACE ';
            l_dyn_sql := l_dyn_sql || ' SET  ';

            FOR i in 1..l_msii_col_table.COUNT LOOP
              -- flash errors where int val is not correct
              IF l_attr_disp_val_table(i) IS NOT NULL AND l_attr_int_val_table(i) IS NULL THEN
                l_dyn_sql := l_dyn_sql || ' process_flag = '||G_VS_INVALID_ERR_STS;
                l_dyn_sql := l_dyn_sql || ' , request_id  = '||G_REQUEST_ID;
                FND_MESSAGE.set_name('EGO', 'EGO_IPI_INVALID_VALUE');
                FND_MESSAGE.set_token('NAME', l_attr_disp_name_table(i));
                FND_MESSAGE.set_token('VALUE',NVL(l_attr_disp_val_table(i),l_attr_int_val_table(i)));
                l_ebi_err_msg := fnd_message.get();
                l_dyn_sql_ebi := ' UPDATE ego_bulkload_intf ' ||
                                 ' SET '|| G_VAL_SET_CONV_ERR_COL ||' = '''||l_ebi_err_msg||''''||
                                 ' WHERE TRANSACTION_ID = ' || l_transaction_id;
                EXECUTE IMMEDIATE l_dyn_sql_ebi;
                EXIT;
              ELSE
                IF (i <> l_msii_col_table.COUNT) THEN
                  l_dyn_sql := l_dyn_sql || l_msii_col_table(i) ||' =  ''' || l_attr_int_val_table(i) || ''' , ';
                ELSE
                  l_dyn_sql := l_dyn_sql || l_msii_col_table(i) ||' =  ''' || l_attr_int_val_table(i) || '''';
                END IF;
              END IF;
            END LOOP; --FOR (i in 1..l_attr_id_table.COUNT) LOOP
            l_dyn_sql := l_dyn_sql || '  WHERE TRANSACTION_ID = ' || l_transaction_id;

            Write_Debug(l_dyn_sql);

            EXECUTE IMMEDIATE l_dyn_sql;

          ELSE --IF DBMS_SQL.FETCH_ROWS(l_cursor_oper_attr)>0 THEN
            -------------------------------------------------------------------
            -- Exit loop as there are no more rows available for processing. --
            -------------------------------------------------------------------
            Write_Debug('load_item_oper_attr_values: No more rows found !');
            EXIT;
          END IF; --IF DBMS_SQL.FETCH_ROWS(l_cursor_oper_attr)>0 THEN

        END LOOP; --END: Loop for l_cursor_oper_attr
        -- Bug : 4099546
        DBMS_SQL.CLOSE_CURSOR(l_cursor_oper_attr);
      END IF; --IF (attr_grp_id_rec.OPER_ATTR_GRP_ID IS NOT NULL) THEN

      -------------------------------------------------------------------
      -- Before proceeding to process the next Attribute Group rows,   --
      -- delete the attrs table.                                       --
      -------------------------------------------------------------------
      l_user_attr_data_table.DELETE;

     END LOOP; -- FOR attr_grp_id_rec IN c_item_oper_attr_grp_ids

   END IF; --IF (l_item_oper_attr_grp_count > 0) THEN

   -----------------------------------------------------------------------
   --Insert the Value Set error messages.
   -----------------------------------------------------------------------
   l_dyn_sql := '';
   l_dyn_sql := l_dyn_sql || 'INSERT INTO MTL_INTERFACE_ERRORS ';
   l_dyn_sql := l_dyn_sql || '( ';
   l_dyn_sql := l_dyn_sql || ' ORGANIZATION_ID   ';
   l_dyn_sql := l_dyn_sql || ', UNIQUE_ID    ';
   l_dyn_sql := l_dyn_sql || ', LAST_UPDATE_DATE   ';
   l_dyn_sql := l_dyn_sql || ', LAST_UPDATED_BY  ';
   l_dyn_sql := l_dyn_sql || ', CREATION_DATE    ';
   l_dyn_sql := l_dyn_sql || ', CREATED_BY     ';
   l_dyn_sql := l_dyn_sql || ', LAST_UPDATE_LOGIN  ';
   l_dyn_sql := l_dyn_sql || ', TABLE_NAME     ';
   l_dyn_sql := l_dyn_sql || ', MESSAGE_NAME     ';
   l_dyn_sql := l_dyn_sql || ', COLUMN_NAME    ';
   l_dyn_sql := l_dyn_sql || ', REQUEST_ID     ';
   l_dyn_sql := l_dyn_sql || ', PROGRAM_APPLICATION_ID  ';
   l_dyn_sql := l_dyn_sql || ', PROGRAM_ID     ';
   l_dyn_sql := l_dyn_sql || ', PROGRAM_UPDATE_DATE  ';
   l_dyn_sql := l_dyn_sql || ', ERROR_MESSAGE    ';
   l_dyn_sql := l_dyn_sql || ', TRANSACTION_ID   ';
   l_dyn_sql := l_dyn_sql || ', ENTITY_IDENTIFIER  ';
   l_dyn_sql := l_dyn_sql || ', BO_IDENTIFIER    ';
   l_dyn_sql := l_dyn_sql || ') ';
   l_dyn_sql := l_dyn_sql || 'SELECT ';
   l_dyn_sql := l_dyn_sql || ' -1 ';
   l_dyn_sql := l_dyn_sql || ', MSII.TRANSACTION_ID ';
   l_dyn_sql := l_dyn_sql || ', SYSDATE ';
   l_dyn_sql := l_dyn_sql || ', '||G_USER_ID ;
   l_dyn_sql := l_dyn_sql || ', SYSDATE ';
   l_dyn_sql := l_dyn_sql || ', '||G_USER_ID;
   l_dyn_sql := l_dyn_sql || ', '||G_LOGIN_ID;
   l_dyn_sql := l_dyn_sql || ', ''MTL_SYSTEM_ITEMS_INTERFACE'' ';
   l_dyn_sql := l_dyn_sql || ', DECODE(MSII.PROCESS_FLAG, ';
   l_dyn_sql := l_dyn_sql ||    G_VS_INVALID_ERR_STS||', ''EGO_IPI_INVALID_VALUE''';
   l_dyn_sql := l_dyn_sql || '    ) ';
   l_dyn_sql := l_dyn_sql || ', NULL ';
   l_dyn_sql := l_dyn_sql || ', '||G_REQUEST_ID ;
   l_dyn_sql := l_dyn_sql || ', '||G_PROG_APPID ;
   l_dyn_sql := l_dyn_sql || ', '||G_PROG_ID ;
   l_dyn_sql := l_dyn_sql || ', SYSDATE ';
   l_dyn_sql := l_dyn_sql || ', DECODE(MSII.PROCESS_FLAG,  ';
   l_dyn_sql := l_dyn_sql ||  G_VS_INVALID_ERR_STS||',  EBI.'||G_VAL_SET_CONV_ERR_COL;
   l_dyn_sql := l_dyn_sql || '        )     ';
   l_dyn_sql := l_dyn_sql || ', MSII.TRANSACTION_ID ';
   l_dyn_sql := l_dyn_sql || ', NULL ';
   l_dyn_sql := l_dyn_sql || ', NULL ';
   l_dyn_sql := l_dyn_sql || 'FROM  MTL_SYSTEM_ITEMS_INTERFACE MSII, EGO_BULKLOAD_INTF EBI ';
   l_dyn_sql := l_dyn_sql || 'WHERE MSII.TRANSACTION_ID = EBI.TRANSACTION_ID ';
   l_dyn_sql := l_dyn_sql || ' AND  MSII.PROCESS_FLAG IN  ';
   l_dyn_sql := l_dyn_sql ||  ' ( ';
   l_dyn_sql := l_dyn_sql ||    G_VS_INVALID_ERR_STS; --take care of invalid value set
   l_dyn_sql := l_dyn_sql ||  ' ) ';
   l_dyn_sql := l_dyn_sql || ' AND  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID ';
   l_dyn_sql := l_dyn_sql || ' AND  EBI.PROCESS_STATUS = 1 ';

   Write_Debug(l_dyn_sql);
   EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;

   Write_Debug(' All Value Set value errors populated.');
   UPDATE MTL_SYSTEM_ITEMS_INTERFACE
      SET PROCESS_FLAG = G_INTF_STATUS_ERROR
    WHERE PROCESS_FLAG IN
            (
      G_VS_INVALID_ERR_STS
            )
      AND TRANSACTION_ID IN
            (
              SELECT TRANSACTION_ID
              FROM   EGO_BULKLOAD_INTF
              WHERE  RESULTFMT_USAGE_ID = p_resultfmt_usage_id
            );

 EXCEPTION
   WHEN OTHERS THEN
      l_retcode := G_STATUS_ERROR;
      l_errbuff := SUBSTRB(SQLERRM, 1,240);
      Write_Debug('Load_item_oper_attr_values : EXCEPTION HAPPENED => '||l_errbuff);
      RAISE;

END load_item_oper_attr_values;

--===================================================================================
--END: 11.5.10 New Functionality: Item Operational Attributes Bulkload (bug# 3293098)
--===================================================================================


 --------------------------------------------------------------------
 -- Fix for Bug# 3864813
 -- Process Net Weight (i.e. Unit Weights) for the Items based on the
 -- Trade Item Descriptor value.
 --
 -- NOTE: Net Weight can only have a value if Trade Item Descriptor
 -- is "Base Unit Or Each", else it will be NULL (i.e. it will be
 -- derived value).
 --------------------------------------------------------------------
PROCEDURE process_netweights
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_commit                IN         VARCHAR2 DEFAULT FND_API.G_TRUE ,
                 x_errbuff               OUT NOCOPY VARCHAR2,
                 x_retcode               OUT NOCOPY VARCHAR2
                ) IS

    -- Start OF comments
    -- API name  : Process Net Weight values for the Items
    -- TYPE      : Public (called by oracle.apps.ego.item.cp.EgoItemConcurrentProgram)
    -- Pre-reqs  : None
    -- FUNCTION  : Process and update the Net Weight (i.e. Unit Weight).
    --             values for the Item.
    --

------------------------------------------------------
-- Local Variables
------------------------------------------------------

CURSOR c_err_logfile (c_resultfmt_usage_id IN NUMBER) IS
 SELECT C_INTF_ATTR239
 FROM   EGO_BULKLOAD_INTF
 WHERE  RESULTFMT_USAGE_ID = c_resultfmt_usage_id
   AND  C_INTF_ATTR239 IS NOT NULL;

-- Long Dynamic SQL String
l_dyn_sql                VARCHAR2(10000);
l_err_logfile_fullpath   VARCHAR2(1000);
l_is_debug               BOOLEAN := FALSE;

l_log_dir                VARCHAR2(1000);
l_log_file               VARCHAR2(1000);

--API return parameters
l_retcode               VARCHAR2(10);
l_errbuff               VARCHAR2(2000);

BEGIN

  OPEN c_err_logfile(p_resultfmt_usage_id);
  FETCH c_err_logfile INTO l_err_logfile_fullpath;
  IF c_err_logfile%FOUND THEN
    l_is_debug := TRUE;
  END IF;
  -- Bug : 4099546
  CLOSE c_err_logfile;
  ------------------------------------------------------------
  -- If the Debug is TRUE, then log these statements in the
  -- Debug file, that has been opened before.
  ------------------------------------------------------------
  IF (l_is_debug) THEN

    l_log_dir := SUBSTR(l_err_logfile_fullpath, 0, INSTR(l_err_logfile_fullpath, 'EGO_BULKLOAD_INTF') - 1);
    l_log_file := SUBSTR(l_err_logfile_fullpath, INSTR(l_err_logfile_fullpath, 'EGO_BULKLOAD_INTF'));

    -----------------------------------------------------------------------
    -- To open the Debug Session to write the Debug Log.                 --
    -- This sets Debug value so that Error_Handler.Get_Debug returns 'Y' --
    -----------------------------------------------------------------------
    Error_Handler.Open_Debug_Session(
      p_debug_filename   => l_log_file
     ,p_output_dir       => l_log_dir
     ,x_return_status    => l_retcode
     ,x_error_mesg       => l_errbuff
     );

  END IF;

  Write_Debug('-----------------------------------------------------------------');
  Write_Debug('POST-PROCESSING After IOI + User-Def + UCCnet Attts processing');
  Write_Debug('-----------------------------------------------------------------');

  l_dyn_sql :=
  ' UPDATE MTL_SYSTEM_ITEMS_B MSIB ' ||
  '  SET   (MSIB.UNIT_WEIGHT, MSIB.WEIGHT_UOM_CODE) = ' ||
  '  ( ' ||
  '        DECODE(MSIB.TRADE_ITEM_DESCRIPTOR, ''BASE_UNIT_OR_EACH'', MSIB.UNIT_WEIGHT, NULL), ' ||
  '        DECODE(MSIB.TRADE_ITEM_DESCRIPTOR, ''BASE_UNIT_OR_EACH'', MSIB.WEIGHT_UOM_CODE, NULL) ' ||
  '  )  ' ||
  '  WHERE EXISTS  ' ||
  ' (  ' ||
  '     SELECT ''X''  ' ||
  '     FROM   EGO_BULKLOAD_INTF EBI   ' ||
  '     WHERE  FND_NUMBER.CANONICAL_TO_NUMBER(EBI.INSTANCE_PK1_VALUE) = MSIB.INVENTORY_ITEM_ID  ' ||
  '     AND    FND_NUMBER.CANONICAL_TO_NUMBER(EBI.INSTANCE_PK2_VALUE) = MSIB.ORGANIZATION_ID  ' ||
  '     AND    EBI.PROCESS_STATUS = 7 ' || -- Successful Rows Only
  '     AND    EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID_2 ' ||
  ' ) ';

  Write_Debug(l_dyn_sql);
  EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;
  Write_Debug('MSIB: Updated the Net Weights.');

  -------------------------------------------------------------
  -- Commit at the end.
  -------------------------------------------------------------
  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  ------------------------------------------------------------
  -- Close the Debug session.
  ------------------------------------------------------------
  IF (l_is_debug) THEN
    Close_Debug_Session;
  END IF;

  x_retcode := G_STATUS_SUCCESS;

  EXCEPTION
  WHEN OTHERS THEN
    x_retcode := G_STATUS_ERROR;
    x_errbuff := SUBSTRB(SQLERRM, 1,240);
    Write_Debug('process_netweights : EXCEPTION HAPPENED => '||x_errbuff);
    -- RAISE; --Donot raise, just return back the values.
    ------------------------------------------------------------
    -- Close the Debug session.
    ------------------------------------------------------------
    IF (l_is_debug) THEN
      Close_Debug_Session;
    END IF;

END process_netweights;


 ----------------------------------------------------------
 -- Process Item and Item Revision Interface Lines
 --
 -- Main API called by the Concurrent Program.
 ----------------------------------------------------------
PROCEDURE process_item_interface_lines
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_user_id               IN         NUMBER,
                 p_conc_request_id       IN         NUMBER,
                 p_language_code         IN         VARCHAR2,
                 p_caller_identifier     IN         VARCHAR2 DEFAULT EGO_ITEM_BULKLOAD_PKG.G_ITEM,
                 p_commit                IN         VARCHAR2 DEFAULT FND_API.G_TRUE ,
                 x_errbuff               OUT NOCOPY VARCHAR2,
                 x_retcode               OUT NOCOPY VARCHAR2,
                 p_start_upload          IN         VARCHAR2 DEFAULT FND_API.G_TRUE ,
                 p_data_set_id           IN         NUMBER   DEFAULT NULL
                ) IS

    -- Start OF comments
    -- API name  : Process Item Interface Lines
    -- TYPE      : Public (called by Concurrent Program Wrapper API)
    -- Pre-reqs  : None
    -- FUNCTION  : Process and Load Item interfance lines.
    --             Loads Item Attr Values + Item User-Defined Attr Values
    --             Errors are populated in MTL_INTERFACE_ERRORS
    --

  CURSOR c_resultfmt_info (c_resultfmt_usage_id  IN  NUMBER) IS
    SELECT   Nvl(fmt.data_level, G_ITEM_DATA_LEVEL)
        ---------------------------------------------------------------------------------
        --Fix for Bug# 3681711. (JCGEORGE)
        -- CLASSIFICATION_CODE in EGO_RESULTS_FMT_USAGES, now stores the **current**
        -- Item Catalog Group ID for the selected Import Format.
        ---------------------------------------------------------------------------------
        --, Decode(fmt.classification1, -1, NULL, fmt.classification1)
        , Decode(fmt_usg.classification_code, -1, NULL, fmt_usg.classification_code)
    FROM   ego_results_fmt_usages fmt_usg, ego_results_format_v fmt
    WHERE  fmt_usg.resultfmt_usage_id = c_resultfmt_usage_id
     AND   fmt.customization_application_id = fmt_usg.customization_application_id
     AND   fmt.customization_code = fmt_usg.customization_code
     AND   fmt.region_application_id  = fmt_usg.region_application_id
     AND   fmt.region_code = fmt_usg.region_code;

  CURSOR c_revision_code_exists (c_resultfmt_usage_id  IN  NUMBER) IS
    SELECT 'x'
    FROM   ego_results_fmt_usages
    WHERE  resultfmt_usage_id = c_resultfmt_usage_id
     AND   attribute_code = G_REV_CODE_ATTR_CODE;

  CURSOR c_mtl_intf_err_row_exists IS
    SELECT 'x'
    FROM   mtl_interface_errors
    WHERE  request_id = FND_GLOBAL.conc_request_id;


  --Long Dynamic SQL String
  l_dyn_sql                VARCHAR2(10000);
  l_msii_set_process_id    NUMBER;
  l_usrattr_data_set_id    NUMBER;

  l_item_ioi_commit        NUMBER;

  l_return_code            VARCHAR2(10);
  l_err_text               VARCHAR2(2000);
  l_temp_txt               VARCHAR2(2000);
  l_data_level             VARCHAR2(50);
  l_catalog_group_id       VARCHAR2(50);
  l_rev_base_attrs_count   NUMBER;
  l_revision_code_exists   VARCHAR2(5);
  ----------------------------------------------------------------
  -- Introduced in 11.5.10, to set appropriate Debug Level to
  -- call the User-Defined Attrs API.
  ----------------------------------------------------------------
  l_debug_level            NUMBER;

  --API return parameters
  l_retcode               VARCHAR2(10);
  l_errbuff               VARCHAR2(2000);

  --Concurrent Request Status Boolean flag
  l_conc_status           BOOLEAN;

BEGIN

   IF (NVL(fnd_profile.value('CONC_REQUEST_ID'), 0) <> 0) THEN
     g_concReq_valid_flag  := TRUE;
   END IF;

   -----------------------------------------------------------------------
   --IF (g_concReq_valid_flag ) THEN
   --  FND_FILE.put_line(FND_FILE.LOG, ' ******** New Log ******** ');
   --END IF;
   -----------------------------------------------------------------------

   -----------------------------------------------------
   -- Open Error Handler Debug Session.
   -----------------------------------------------------
   Open_Debug_Session;

   Developer_Debug('Completely Reformatted EGO_ITEM_BULKLOAD_PKG with Error Handler Changes');

   Developer_Debug('After Open_Debug_Session');
   SetGobals();
   G_LANGUAGE_CODE := p_language_code;

   -----------------------------------------------------------------------
   -- Providing the Errors Link in the Concurrent Log file.
   -----------------------------------------------------------------------
   FND_MESSAGE.SET_NAME('EGO','EGO_ITEM_BULK_ERRS_LINKTXT1');
   FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

   FND_MESSAGE.SET_NAME('EGO','EGO_ITEMBULK_HOSTANDPORT');
   l_temp_txt := rtrim(FND_PROFILE.VALUE('APPS_FRAMEWORK_AGENT'), '/');--FND_MESSAGE.GET;

   FND_MESSAGE.SET_NAME('EGO','EGO_ITEM_BULK_ERRS_LINK');
   FND_MESSAGE.SET_TOKEN('HOST_AND_PORT', l_temp_txt);
   FND_MESSAGE.SET_TOKEN('CONC_REQ_ID', G_REQUEST_ID);
   FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

   Developer_Debug('G_USER_ID : '||To_char(G_USER_ID));
   Developer_Debug('G_PROG_ID : '||To_char(G_PROG_ID));
   Developer_Debug('G_REQUEST_ID : '||To_char(G_REQUEST_ID));
   Developer_Debug('P_RESULT_FMT_USAGE_ID : '||To_char(p_resultfmt_usage_id));

   -----------------------------------------------------------------------
   -- This is the Result Format Usage ID for the Current Upload.        --
   -----------------------------------------------------------------------
   G_RESULTFMT_USAGE_ID    := p_resultfmt_usage_id;

   -----------------------------------------------------------------------
   -- Delete all the earlier loads from the same spreadsheet.
   -- And also setup the Error Log file in the EBI, to be picked up by
   -- Java portion of the Conc Program later.
   -----------------------------------------------------------------------
   setup_buffer_intf_table(p_resultfmt_usage_id);

   -----------------------------------------------------------------------
   -- If the process id is passed, we will be using this throughout the program
   -- So setting this to the global variable here itself.
   -----------------------------------------------------------------------
   IF (p_data_set_id IS NOT NULL) THEN
     G_MSII_SET_PROCESS_ID := p_data_set_id;
   END IF;

   -----------------------------------------------------------------------
   -- If the process id is passed, we need to store the information is a
   -- PDH batch or not
   -----------------------------------------------------------------------

   IF (p_data_set_id IS NOT NULL) THEN
     setup_batch_info();
   END IF;

   -------------------------------------------------------------------------------
   --                                                                           --
   --If the caller is G_ITEM, then the import format can have 2 levels :        --
   -- 1. Item   2. Item Revision.                                               --
   -- Hence need to call appropriate populate interface table procedure.        --
   --                                                                           --
   -------------------------------------------------------------------------------
   IF (p_caller_identifier = EGO_ITEM_BULKLOAD_PKG.G_ITEM) THEN

       OPEN c_resultfmt_info(p_resultfmt_usage_id);
       FETCH c_resultfmt_info INTO l_data_level, l_catalog_group_id;
       Developer_Debug('Result Format Data Level =>'||l_data_level);

       -------------------------------------------------------------------
       --This Global Catalog Group variable is useful during imports.   --
       -------------------------------------------------------------------
       IF (l_catalog_group_id IS NOT NULL) THEN
         G_CATALOG_GROUP_ID  := l_catalog_group_id;
         Developer_Debug('G_CATALOG_GROUP_ID : '||G_CATALOG_GROUP_ID);
       END IF;
       IF c_resultfmt_info%FOUND THEN
        --IF (l_data_level = G_ITEM_DATA_LEVEL) THEN
          --------------------------------------------------------------------
          -- Since the Data Level is ITEM, need to setup the Item Interface --
          -- table.                                                         --
          --------------------------------------------------------------------
          Developer_Debug(' Calling Internal Setup_Item_interface ');
          Setup_Item_interface(
            p_resultfmt_usage_id  => p_resultfmt_usage_id
           ,p_set_process_id      => p_data_set_id
           ,x_set_process_id      => l_msii_set_process_id
           ,p_caller_identifier   => p_caller_identifier
           ,x_errbuff             => l_errbuff
           ,x_retcode             => l_retcode
            );
          Developer_Debug(' Returning Internal Setup_Item_interface '|| l_retcode);

          FND_FILE.put_line(FND_FILE.LOG, '*Importing Items*. SET_PROCESS_ID : '||l_msii_set_process_id);

          -------------------------------------------------------------------
          -- New procedure introduced in 11.5.10 to load the operational   --
          -- attributes using User-Def attrs framework. (PPEDDAMA)         --
          -------------------------------------------------------------------
          load_item_oper_attr_values(p_resultfmt_usage_id);

          Developer_Debug('process_item_interface_lines: Done loading the Item operational attributes');

          delete_records_from_MSII(p_data_set_id);

          Write_Debug('Deleting unwanted records from MSII');

          -------------------------------------------------------------------
          -- Fix for Bug# 3403455. (PPEDDAMA)                             --
          -- Setup Item Rev Interface only if Revision Base attrs exist.  --
          -------------------------------------------------------------------

          SELECT count(*)
            INTO l_rev_base_attrs_count
          FROM  ego_results_fmt_usages
          WHERE  resultfmt_usage_id = p_resultfmt_usage_id
          AND attribute_code NOT LIKE '%$$%'
          ---------------------------------------------------------------------------
          -- Added NOT LIKE 'GTIN_%' to filter out Dummy Attrs for Attr Group: "GTIN"
          ---------------------------------------------------------------------------
          AND attribute_code NOT LIKE 'GTIN_%'
          AND attribute_code IN --Segregating Item Revision Base Attrs using this clause
          (
              select LOOKUP_CODE CODE
              from  FND_LOOKUP_VALUES
              where  LOOKUP_TYPE = 'EGO_ITEM_REV_HDR_ATTR_GRP'
              AND    LANGUAGE = USERENV('LANG')
              AND    ENABLED_FLAG = 'Y'
          );

          Developer_Debug('process_item_interface_lines.l_rev_base_attrs_count : '||l_rev_base_attrs_count);
            --------------------------------------------------------------------
            -- Changed from >0 to >1 because, only if other attributes apart  --
            -- from REVISION exist, then setup Item Revision interface.       --
            --------------------------------------------------------------------

          IF (l_rev_base_attrs_count > 1) THEN

            OPEN c_revision_code_exists(p_resultfmt_usage_id);
            FETCH c_revision_code_exists INTO l_revision_code_exists;
            IF c_revision_code_exists%FOUND THEN
              Developer_Debug('process_item_interface_lines.l_revision_code_exists : '||l_revision_code_exists ||'. Calling Setup_ItemRev_interface');

              --------------------------------------------------------------------
              -- Now that Revisions show up as a part of Item Search Results,   --
              -- calling Setup Revisions Interface as a part of Item Bulkload   --
              --------------------------------------------------------------------
              Setup_ItemRev_interface(
                p_resultfmt_usage_id  => p_resultfmt_usage_id
               ,p_caller_identifier   => p_caller_identifier
               ,p_data_level          => G_ITEM_DATA_LEVEL
               ,p_set_process_id      => p_data_set_id
               ,x_set_process_id      => l_msii_set_process_id
               ,x_errbuff             => l_errbuff
               ,x_retcode             => l_retcode
               );

            END IF; --IF c_revision_code_exists%FOUND THEN
            -- Bug : 4099546
            CLOSE c_revision_code_exists;
          END IF; --IF (l_rev_base_attrs_count > 0) THEN
          -------------------------------------------------------------------
          -- End: Fix for Bug# 3403455. (PPEDDAMA)                        --
          -- Setup Item Rev Interface only if Revision Base attrs exist.  --
          -------------------------------------------------------------------
          EGO_ITEM_BULKLOAD_PKG.load_intersections_interface
                           (
                             p_resultfmt_usage_id    =>p_resultfmt_usage_id,
                             p_set_process_id        =>p_data_set_id,
                             x_set_process_id        =>l_msii_set_process_id,
                             x_errbuff               =>x_errbuff,
                             x_retcode               =>x_retcode
                            );
         write_debug('Done with EGO_ITEM_BULKLOAD_PKG.load_intersections_interface ---x_retcode-'||x_retcode);
        --ELSE --G_ITEM_REV_DATA_LEVEL
 /*
          ---------------------------------------------------------------------------------
          -- Now that Revisions show up as a part of Item Search Results,
          -- adding new parameter p_data_level, to distinguish that this Setup Revisions
          -- Interface is called from 'Import Revisions' (through Revision Import Format)
          ---------------------------------------------------------------------------------
          Setup_ItemRev_interface(
            p_resultfmt_usage_id  => p_resultfmt_usage_id
           ,p_caller_identifier   => p_caller_identifier
           ,p_data_level          => G_ITEM_REV_DATA_LEVEL
           ,p_set_process_id      => p_data_set_id
           ,x_set_process_id      => l_msii_set_process_id
           ,x_errbuff             => l_errbuff
           ,x_retcode             => l_retcode
                 );
          FND_FILE.put_line(FND_FILE.LOG, '*Importing Item Revisions*. SET_PROCESS_ID : '||l_msii_set_process_id);

        END IF; --end: IF (l_data_level = G_ITEM_DATA_LEVEL) THEN
        */
     END IF; --end: IF c_resultfmt_info%FOUND THEN

     CLOSE c_resultfmt_info;

    ELSIF (p_caller_identifier = EGO_ITEM_BULKLOAD_PKG.G_BOM) THEN

      --------------------------------------------------------------
      -- BOM called the Bulkload code, hence setup Item and Item
      -- Revision Interface tables appropriately.
      --------------------------------------------------------------

      Developer_Debug('CALLER IDENTIFIER : '|| p_caller_identifier);

      Setup_item_interface(
            p_resultfmt_usage_id  => p_resultfmt_usage_id
           ,p_set_process_id      => p_data_set_id
           ,x_set_process_id      => l_msii_set_process_id
           ,p_caller_identifier   => p_caller_identifier
           ,x_errbuff             => l_errbuff
           ,x_retcode             => l_retcode
                 );

      -------------------------------------------------------------------
      -- New procedure introduced in 11.5.10 to load the operational   --
      -- attributes using User-Def attrs framework. (HGELLI)           --
      -------------------------------------------------------------------
      load_item_oper_attr_values(p_resultfmt_usage_id);

      Developer_Debug('process_item_interface_lines: Done loading the Item operational attributes');

       --------------------------------------------------------------
       -- Check to see if Revision Code exists, before calling to
       -- to set up the Revisions Interface table.
       --------------------------------------------------------------
       OPEN c_revision_code_exists(p_resultfmt_usage_id);
       FETCH c_revision_code_exists INTO l_revision_code_exists;
       IF c_revision_code_exists%FOUND THEN
         Developer_Debug('process_item_interface_lines.l_revision_code_exists : '||l_revision_code_exists ||'. Calling Setup_ItemRev_interface');

         --Now that Revisions show up as a part of Item Search Results,
         --calling Setup Revisions Interface as a part of Item Bulkload
         Setup_ItemRev_interface(
            p_resultfmt_usage_id  => p_resultfmt_usage_id
           ,p_caller_identifier   => p_caller_identifier
           ,p_data_level          => G_ITEM_DATA_LEVEL
           ,p_set_process_id      => p_data_set_id
           ,x_set_process_id      => l_msii_set_process_id
           ,x_errbuff             => l_errbuff
           ,x_retcode             => l_retcode
         );

        END IF; --IF c_revision_code_exists%FOUND THEN
        -- Bug : 4099546
        CLOSE c_revision_code_exists;
        FND_FILE.put_line(FND_FILE.LOG, '*Importing Items*. SET_PROCESS_ID : '||l_msii_set_process_id);

    ELSE
      --------------------------------------------------------------
      -- This ELSE condition should never be reached.
      --------------------------------------------------------------
      Developer_Debug('INVALID CALLER IDENTIFIER : '|| p_caller_identifier);

   END IF;--IF (p_caller_identifier = EGO_ITEM_BULKLOAD_PKG.G_ITEM)

   --R12
   ----------------------------------------------------------------
   -- Call for User Attributes Bulk Processing, to load the
   -- Interface table: EGO_ITM_USR_ATTR_INTRFC
   ----------------------------------------------------------------
   Developer_Debug('Before calling load_itm_or_rev_usrattr_intf ');
   load_itm_or_rev_usrattr_intf
               (
                 p_resultfmt_usage_id    => p_resultfmt_usage_id
                ,p_data_set_id           => l_msii_set_process_id
                ,x_errbuff               => l_errbuff
                ,x_retcode               => l_retcode
                );

   Developer_Debug('UsrAttr_Populate_Process: done. l_retcode = ' || l_retcode);
   Developer_Debug('UsrAttr_Populate_Process: l_errbuff = ' || l_errbuff);

   /* Bug 7578350. Moved this DELETE statement from load_item_revs_interface() function,
      by addubg NOT EXITS condition in WHERE caluse, so that we delete the rows from MTL_ITEM_REVISIONS_INTERFACE
      only if there are no Revision Level Attributes provided. */

   DELETE MTL_ITEM_REVISIONS_INTERFACE MIRI
    WHERE revision IS NULL
      AND revision_id IS NULL
      AND implementation_date IS NULL
      AND effectivity_date IS NULL
      AND description IS NULL
      AND revision_label IS NULL
      AND revision_reason IS NULL
      AND current_phase_id IS NULL
      AND EXISTS (SELECT 'X'
                    FROM  EGO_BULKLOAD_INTF EBI
                   WHERE  EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id
                     AND  EBI.TRANSACTION_ID = MIRI.TRANSACTION_ID
                     AND  EBI.PROCESS_STATUS = 1
                 )
      AND NOT EXISTS (SELECT 'X'
                        FROM EGO_ITM_USR_ATTR_INTRFC EIUAT
                      WHERE EIUAT.TRANSACTION_ID = MIRI.TRANSACTION_ID
                        AND EIUAT.PROCESS_STATUS = 1
                        AND EIUAT.DATA_LEVEL_ID=43106);

   -------------------------------------------------------------
   -- Log Errors only to MTL_INTERFACE_ERRORS table.
   -------------------------------------------------------------
   Error_Handler.Log_Error(
         p_write_err_to_inttable  => 'Y',
         p_write_err_to_debugfile => 'Y'
         );
   ------------------------------------------------------------------------
   -- In case the Error Reporting Page has problems, following
   -- SQL helps debugging.
   -- NOTE: This is only for *Printing* purposes, hence adding NEWLINE
   --       character at the end.
   ------------------------------------------------------------------------
   l_dyn_sql :=              'SELECT MIERR.REQUEST_ID REQUEST_ID, '||G_NEWLINE;
   l_dyn_sql := l_dyn_sql || 'EBI.C_INTF_ATTR240 ITEM_NUMBER, '||G_NEWLINE;
   l_dyn_sql := l_dyn_sql || 'EBI.C_INTF_ATTR241 ORGANIZATION_CODE, '||G_NEWLINE;
   l_dyn_sql := l_dyn_sql || 'EBI.C_INTF_ATTR242 REVISION_CODE, '||G_NEWLINE;
   l_dyn_sql := l_dyn_sql || 'MIERR.ERROR_MESSAGE '||G_NEWLINE;
   l_dyn_sql := l_dyn_sql || 'FROM   MTL_INTERFACE_ERRORS MIERR, '||G_NEWLINE;
   l_dyn_sql := l_dyn_sql || 'EGO_BULKLOAD_INTF EBI '||G_NEWLINE;
   l_dyn_sql := l_dyn_sql || 'WHERE  MIERR.TRANSACTION_ID = EBI.TRANSACTION_ID '||G_NEWLINE;
   l_dyn_sql := l_dyn_sql || 'AND    MIERR.request_id = '||G_REQUEST_ID||G_NEWLINE;
   Developer_Debug('In Case Error Reporting page has problems, Execute the following SQL to fetch the Concurrent Program CUMULATIVE Errors: ');
   Developer_Debug(l_dyn_sql);

   -------------------------------------------------------------
   -- Commit at the end.
   -------------------------------------------------------------
   IF (p_commit = FND_API.G_TRUE) THEN
     COMMIT;
     Developer_Debug('COMMITing at the end.');
   END IF;

   ------------------------------------------------------------
   -- Check to See if Errors exist in MTL_INTERFACE_ERRORS.
   -- If Exists, then set the Status as Completed w/ Warnings.
   ------------------------------------------------------------
   OPEN c_mtl_intf_err_row_exists;
   FETCH c_mtl_intf_err_row_exists INTO l_temp_txt;
   IF c_mtl_intf_err_row_exists%FOUND THEN
     Developer_Debug('Errors exist in MTL_INTERFACE_ERRORS.');
     l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',              --Status
                                                           'Completed with Warnings' --Message
                                                           );
     x_retcode := Error_Handler.G_STATUS_WARNING;
   ELSE
     Developer_Debug('*NO* Errors exist in MTL_INTERFACE_ERRORS.');
     x_retcode := G_STATUS_SUCCESS;
   END IF;
   CLOSE c_mtl_intf_err_row_exists;

   -----------------------------------------------------------
   -- Add log messages for all successfully created items
   -----------------------------------------------------------
-- 5653266 commenting out the call to Log_Created_items
--   IF (G_REQUEST_ID <> -1 ) THEN
--     Log_created_Items(G_REQUEST_ID);
--   END IF;

   -----------------------------------------------------
   -- Close Error Handler Debug Session.
   -----------------------------------------------------

   Close_Debug_Session;

   -----------------------------------------------------------------
   -- Main EXCEPTION Block, that handles all underlying Procedures'
   -- Exceptions. This also sets the PROCESS_STATUS value of the
   -- EBI Rows, to indicate Error.
   -----------------------------------------------------------------
   EXCEPTION

    WHEN OTHERS THEN
      Developer_Debug('Exception encountered processing one of the procedures in Process_Item_Interface_lines.');
      Developer_Debug('error code : '|| to_char(SQLCODE));
      Developer_Debug('error text : '|| SQLERRM);
      x_errbuff := 'Error : '||to_char(SQLCODE)||'---'||SQLERRM;
      x_retcode := Error_Handler.G_STATUS_ERROR;
      Developer_Debug('Returning x_retcode : '|| x_retcode);
      l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',         --Status
                                                            to_char(SQLCODE) --Message
                                                            );
      Developer_Debug('Setting all the *Unprocessed* rows (PROCESS_STATUS = 1) in EGO_BULKLOAD_INTF to PROCESS_STATUS = 3.');

      -----------------------------------------------------------------------------------------------
      -- Update all the lines in EGO_BULKLOAD_INTF as ERROR.
      -- This will ensure that the next submission of the Same excel doesnt throw
      -- IOI error:
      -- Item <Item#> already exists in the organization V1. Please use a different item name/number.
      -----------------------------------------------------------------------------------------------
      UPDATE EGO_BULKLOAD_INTF EBI
        SET  EBI.PROCESS_STATUS = G_INTF_STATUS_ERROR
        WHERE EBI.PROCESS_STATUS = G_INTF_STATUS_TOBE_PROCESS
        AND EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id;

      COMMIT;
      Developer_Debug('COMMITing the error statuses for EBI Rows.');

      -----------------------------------------------------
      -- Close Error Handler Debug Session.
      -----------------------------------------------------
      Close_Debug_Session;

   --Exception block ends.
   ------------------------------------------------------------------

END Process_item_interface_lines;

/*
 ** Added by Ssingal - This procedure gets the Trade ItemDescriptor for a given
 **                    Inventory_item_id and organization Id.
 **         Bug Fix  4001661
 */


PROCEDURE get_Trade_Item_Descriptor (
          p_inventory_item_id        IN          VARCHAR2,
          p_organization_id          IN          VARCHAR2,
          x_tradeItemDescriptor      OUT NOCOPY  VARCHAR2
) IS
  l_tradeItemDescriptor    VARCHAR2(100);
  BEGIN

  SELECT TRADE_ITEM_DESCRIPTOR INTO x_tradeItemDescriptor
  FROM MTL_SYSTEM_ITEMS_B
  WHERE INVENTORY_ITEM_ID = to_number(p_inventory_item_id)
    AND ORGANIZATION_ID  = to_number(p_organization_id);


EXCEPTION
  WHEN OTHERS THEN
    Write_Debug('EGO BULK LOAD Gtin Attributes get_Trade_Item_Descriptor  :GTID is  null for an Item EXCEPTION HAPPENED => '|| SUBSTR ( SQLERRM , 0 ,240 ));
    Write_Debug('EGO BULK LOAD Gtin Attributes get_Trade_Item_Descriptor  GTID Is null for  => '|| p_inventory_item_id || ' , org Id ' || p_organization_id);
END get_Trade_Item_Descriptor;


/*
 ** Added by Ssingal - For clearing the attribute values for an Item
 **                    taking into consideration the Trade Item Descriptor
 **         Bug Fix  4001661
 */


PROCEDURE Clear_Gtin_Attrs
    (
     p_resultfmt_usage_id       IN             NUMBER ,
     p_commit                   IN             VARCHAR2 DEFAULT FND_API.G_TRUE,
     x_errbuff                  OUT NOCOPY     VARCHAR2 ,
     x_ret_code                 OUT NOCOPY     VARCHAR2
    )
    IS
 CURSOR c_errLogFile ( c_resultfmt_usage_id  IN  NUMBER) IS
   SELECT C_INTF_ATTR239
 FROM   EGO_BULKLOAD_INTF
 WHERE C_INTF_ATTR239 IS NOT NULL
   AND RESULTFMT_USAGE_ID = c_resultfmt_usage_id
   AND ROWNUM < 2;

  CURSOR c_itemId_OrgId (c_resultfmt_usage_id  IN  NUMBER) IS
    SELECT INSTANCE_PK1_VALUE , INSTANCE_PK2_VALUE
      FROM EGO_BULKLOAD_INTF
      WHERE RESULTFMT_USAGE_ID  = c_resultfmt_usage_id
        AND PROCESS_STATUS = 7;

   CURSOR c_gtid (c_inventory_itemId  IN NUMBER , c_organization_Id IN NUMBER) IS
     SELECT TRADE_ITEM_DESCRIPTOR
       FROM MTL_SYSTEM_ITEMS_B
      WHERE INVENTORY_ITEM_ID = c_inventory_itemId
        AND ORGANIZATION_ID = c_organization_Id ;

 /* Editable at root
    Attribute Values to be cleared for Leaf
    these attributes are _B table attributes
    We need to to pass Single/Multi attribute group type */
    CURSOR  c_leafAttrs_bTable  ( c_attr_group_type IN VARCHAR2 , c_edit_in_hcR IN VARCHAR2 , c_data_type_codeA IN VARCHAR2) IS
     SELECT DATABASE_COLUMN ,
            EDIT_IN_HIERARCHY_CODE ,
            DATA_TYPE_CODE
       FROM EGO_ATTRS_V
      WHERE ATTR_GROUP_TYPE = c_attr_group_type  -- 'EGO_ITEM_GTIN_ATTRS'
        AND EDIT_IN_HIERARCHY_CODE IN  ( c_edit_in_hcR  )  -- ( 'L' , 'LP', 'A' , 'AP')
        AND DATA_TYPE_CODE not in ( c_data_type_codeA  );

 /* Editable at leaf
    Attribute Values to be cleared for Root
    these attributes are _B table attributes
    We need to to pass Single/Multi attribute group type */
    CURSOR  c_rootAttrs_bTable  ( c_attr_group_type IN VARCHAR2 , c_edit_in_hcL IN VARCHAR2 , c_edit_in_hcLP IN VARCHAR2 , c_data_type_codeA IN VARCHAR2 ) is
     SELECT DATABASE_COLUMN ,
            EDIT_IN_HIERARCHY_CODE ,
            DATA_TYPE_CODE
       FROM EGO_ATTRS_V
      WHERE ATTR_GROUP_TYPE = c_attr_group_type  -- 'EGO_ITEM_GTIN_ATTRS'
        AND EDIT_IN_HIERARCHY_CODE IN  ( c_edit_in_hcL , c_edit_in_hcLP )  -- ( 'L' , 'LP', 'A' , 'AP')
        AND DATA_TYPE_CODE not in ( c_data_type_codeA ) ;

 /* Editable at root
    Attribute Values to be cleared for Leaf
    these attributes are _TL table attributes
    We need to to pass Single/Multi attribute group type */
   CURSOR  c_leafAttrs_tlTable  ( c_attr_group_type IN VARCHAR2 , c_edit_in_hcR IN VARCHAR2 , c_data_type_codeA IN VARCHAR2) is
     SELECT DATABASE_COLUMN ,
            EDIT_IN_HIERARCHY_CODE ,
            DATA_TYPE_CODE
       FROM EGO_ATTRS_V
      WHERE ATTR_GROUP_TYPE = c_attr_group_type  -- 'EGO_ITEM_GTIN_ATTRS'
        AND EDIT_IN_HIERARCHY_CODE IN  ( c_edit_in_hcR  )  -- ( 'L' , 'LP', 'A' , 'AP')
        AND DATA_TYPE_CODE in ( c_data_type_codeA ) ;

 /* Editable at leaf
    Attribute Values to be cleared for Root
    these attributes are _TL table attributes
    We need to to pass Single/Multi attribute group type */
    CURSOR  c_rootAttrs_tlTable  ( c_attr_group_type IN VARCHAR2 , c_edit_in_hcL IN VARCHAR2 , c_edit_in_hcLP IN VARCHAR2 , c_data_type_codeA IN VARCHAR2 ) is
     SELECT DATABASE_COLUMN ,
            EDIT_IN_HIERARCHY_CODE ,
            DATA_TYPE_CODE
       FROM EGO_ATTRS_V
      WHERE ATTR_GROUP_TYPE = c_attr_group_type  -- 'EGO_ITEM_GTIN_ATTRS'
        AND EDIT_IN_HIERARCHY_CODE IN  ( c_edit_in_hcL , c_edit_in_hcLP  )  -- ( 'L' , 'LP', 'A' , 'AP')
        AND DATA_TYPE_CODE in ( c_data_type_codeA ) ;

  TYPE ATTR_METADATA_REC IS RECORD ( DATABASE_COLUMN           VARCHAR2(30),
                                     EDIT_IN_HIERARCHY_CODE    VARCHAR2(30),
                                     DATA_TYPE_CODE            VARCHAR2(30)
                                   );
  /*TYPE ATTR_METADATA_TABLE IS TABLE OF ATTR_METADATA_REC INDEX BY BINARY_INTEGER;*/

  l_is_Debug                  BOOLEAN := FALSE ;
  l_err_log_file              VARCHAR2(1000);
  l_err_log_file_name         VARCHAR2(1000);
  l_err_log_file_dir          VARCHAR2(1000);
  l_dyn_sql                   VARCHAR2(20000);
  l_inventory_item_id         NUMBER ;
  l_organization_id           NUMBER ;
  l_hierarchyExists           VARCHAR2(20);
  l_gtid                      VARCHAR2(100);
  l_return_status             VARCHAR2(100);
  l_msg_count                 NUMBER ;
  l_msg_data                  fnd_new_messages.message_text%TYPE;
  l_retCode                   VARCHAR2(10);
  l_errbuff                   VARCHAR2(20000);
  l_err_code                  NUMBER;
--  l_attr_table              ATTR_METADATA_TABLE ;
  l_attr_rec                  ATTR_METADATA_REC ;
  l_used_in_structure         VARCHAR2(100) ;

  l_leafAttrs_bTable_dbCol        VARCHAR2(5000);
  l_leafAttrs_MulBTable_dbCol     VARCHAR2(5000);
  l_rootAttrs_bTable_dbCol        VARCHAR2(5000);
  l_rootAttrs_MulBTable_dbCol     VARCHAR2(5000);
  l_leafAttrs_tlTable_dbCol       VARCHAR2(5000);
  l_leafAttrs_MulTlTable_dbCol    VARCHAR2(5000);
  l_rootAttrs_TlTable_dbCol       VARCHAR2(5000);
  l_rootAttrs_MulTlTable_dbCol    VARCHAR2(5000);

  l_leafAttrs_bTable_value        VARCHAR2(5000);
  l_leafAttrs_MulBTable_value     VARCHAR2(5000);
  l_rootAttrs_bTable_value        VARCHAR2(5000);
  l_rootAttrs_MulBTable_value     VARCHAR2(5000);
  l_leafAttrs_tlTable_value       VARCHAR2(5000);
  l_leafAttrs_MulTlTable_value    VARCHAR2(5000);
  l_rootAttrs_TlTable_value       VARCHAR2(5000);
  l_rootAttrs_MulTlTable_value    VARCHAR2(5000);


  --API return parameters

BEGIN

  OPEN c_errLogFile ( p_resultfmt_usage_id );
  FETCH c_errLogFile  INTO l_err_log_file;
  IF c_errLogFile%FOUND THEN
    l_is_Debug := TRUE ;
  END IF;
  -- Bug : 4099546
  CLOSE c_errLogFile;
  Write_Debug('-----------------------------------------------------------------');
  Write_Debug('Clear_Gtin_Attrs  :                                            ');
  Write_Debug('-----------------------------------------------------------------');

  IF (l_is_Debug ) THEN
    l_err_log_file_dir := SUBSTR (l_err_log_file , 0 , INSTR (l_err_log_file , 'EGO_BULKLOAD_INTF' ) - 1 );
    l_err_log_file_name := SUBSTR (l_err_log_file , INSTR ( l_err_log_file , 'EGO_BULKLOAD_INTF'  )-1 );
    -----------------------------------------------------------------------
    -- To open the Debug Session to write the Debug Log.                 --
    -- This sets Debug value so that Error_Handler.Get_Debug returns 'Y' --
    -----------------------------------------------------------------------
    Error_Handler.Open_Debug_Session(
      p_debug_filename   => l_err_log_file_name
     ,p_output_dir       => l_err_log_file_dir
     ,x_return_status    => l_retCode
     ,x_error_mesg       => l_errbuff
     );

  END IF;

    --  Fetch the metadata now for Uccnet attributes
     Write_Debug('Clear_Gtin_Attrs  : Getting metadata');

    OPEN  c_leafAttrs_bTable  ('EGO_ITEM_GTIN_ATTRS', 'R' , 'A') ;
    LOOP
     FETCH c_leafAttrs_bTable INTO l_attr_rec ;
      EXIT WHEN c_leafAttrs_bTable%NOTFOUND;
       l_leafAttrs_bTable_dbCol := l_leafAttrs_bTable_dbCol || ' , ' || l_attr_rec.DATABASE_COLUMN ;
       l_leafAttrs_bTable_value := l_leafAttrs_bTable_value || ' , NULL ' ;
    END LOOP;
    CLOSE c_leafAttrs_bTable;
    l_leafAttrs_bTable_dbCol  := SUBSTR ( l_leafAttrs_bTable_dbCol  , INSTR( l_leafAttrs_bTable_dbCol , ',')+1 ) ;
    l_leafAttrs_bTable_value  := SUBSTR ( l_leafAttrs_bTable_value  , INSTR( l_leafAttrs_bTable_value , ',')+1 ) ;

   OPEN  c_leafAttrs_bTable  ('EGO_ITEM_GTIN_MULTI_ATTRS', 'R' , 'A') ;
    LOOP
     FETCH c_leafAttrs_bTable INTO l_attr_rec ;
     EXIT WHEN c_leafAttrs_bTable%NOTFOUND ;
       l_leafAttrs_MulBTable_dbCol := l_leafAttrs_MulBTable_dbCol || ' , '|| l_attr_rec.DATABASE_COLUMN ;
       l_leafAttrs_MulBTable_value := l_leafAttrs_MulBTable_value || ' , NULL ' ;
    END LOOP;
    CLOSE c_leafAttrs_bTable;
    l_leafAttrs_MulBTable_dbCol  := SUBSTR ( l_leafAttrs_MulBTable_dbCol  , INSTR( l_leafAttrs_MulBTable_dbCol , ',')+1 ) ;
    l_leafAttrs_MulBTable_value  := SUBSTR ( l_leafAttrs_MulBTable_value  , INSTR( l_leafAttrs_MulBTable_value , ',')+1 ) ;

   OPEN  c_rootAttrs_bTable  ('EGO_ITEM_GTIN_ATTRS', 'L' ,'LP' ,  'A') ;
    LOOP
     FETCH c_rootAttrs_bTable INTO l_attr_rec ;
     EXIT WHEN  c_rootAttrs_bTable%NOTFOUND ;
       l_rootAttrs_bTable_dbCol := l_rootAttrs_bTable_dbCol || ' , '|| l_attr_rec.DATABASE_COLUMN ;
       l_rootAttrs_bTable_value := l_rootAttrs_bTable_value || ' , NULL ' ;
    END LOOP;
    CLOSE c_rootAttrs_bTable;
    l_rootAttrs_bTable_dbCol  := SUBSTR ( l_rootAttrs_bTable_dbCol  , INSTR( l_rootAttrs_bTable_dbCol , ',')+1 ) ;
    l_rootAttrs_bTable_value  := SUBSTR ( l_rootAttrs_bTable_value  , INSTR( l_rootAttrs_bTable_value , ',')+1 ) ;

   OPEN  c_rootAttrs_bTable  ('EGO_ITEM_GTIN_MULTI_ATTRS', 'L' ,'LP'  ,  'A') ;
    LOOP
     FETCH c_rootAttrs_bTable INTO l_attr_rec ;
     EXIT WHEN  c_rootAttrs_bTable%NOTFOUND ;
       l_rootAttrs_MulBTable_dbCol := l_rootAttrs_MulBTable_dbCol || ' , '|| l_attr_rec.DATABASE_COLUMN ;
       l_rootAttrs_MulBTable_value := l_rootAttrs_MulBTable_value || ' , NULL ' ;
    END LOOP;
    CLOSE c_rootAttrs_bTable;
    l_rootAttrs_MulBTable_dbCol  := SUBSTR ( l_rootAttrs_MulBTable_dbCol  , INSTR( l_rootAttrs_MulBTable_dbCol , ',')+1 ) ;
    l_rootAttrs_MulBTable_value  := SUBSTR ( l_rootAttrs_MulBTable_value  , INSTR( l_rootAttrs_MulBTable_value , ',')+1 ) ;

   OPEN  c_leafAttrs_tlTable  ('EGO_ITEM_GTIN_ATTRS', 'R' ,  'A') ;
    LOOP
     FETCH c_leafAttrs_tlTable INTO l_attr_rec ;
     EXIT WHEN c_leafAttrs_tlTable%NOTFOUND ;
       l_leafAttrs_tlTable_dbCol := l_leafAttrs_tlTable_dbCol || ' , '|| l_attr_rec.DATABASE_COLUMN ;
       l_leafAttrs_tlTable_value := l_leafAttrs_tlTable_value || ' , NULL ' ;
    END LOOP;
    CLOSE c_leafAttrs_tlTable;
    l_leafAttrs_tlTable_dbCol  := SUBSTR ( l_leafAttrs_tlTable_dbCol  , INSTR( l_leafAttrs_tlTable_dbCol , ',')+1 ) ;
    l_leafAttrs_tlTable_value  := SUBSTR ( l_leafAttrs_tlTable_value  , INSTR( l_leafAttrs_tlTable_value , ',')+1 ) ;

   OPEN  c_leafAttrs_tlTable  ('EGO_ITEM_GTIN_MULTI_ATTRS', 'R' ,  'A') ;
    LOOP
     FETCH c_leafAttrs_tlTable INTO l_attr_rec ;
     EXIT WHEN c_leafAttrs_tlTable%NOTFOUND ;
       l_leafAttrs_MultlTable_dbCol := l_leafAttrs_MulTlTable_dbCol || ' , '|| l_attr_rec.DATABASE_COLUMN ;
       l_leafAttrs_MultlTable_value := l_leafAttrs_MultlTable_value || ' , NULL ';
    END LOOP;
    CLOSE c_leafAttrs_tlTable;
    l_leafAttrs_MultlTable_dbCol  := SUBSTR ( l_leafAttrs_MultlTable_dbCol  , INSTR( l_leafAttrs_MultlTable_dbCol , ',')+1 ) ;
    l_leafAttrs_MultlTable_value  := SUBSTR ( l_leafAttrs_MultlTable_value  , INSTR( l_leafAttrs_MultlTable_value , ',')+1 ) ;

   OPEN  c_rootAttrs_tlTable  ('EGO_ITEM_GTIN_ATTRS', 'L' ,'LP' ,  'A') ;
    LOOP
     FETCH c_rootAttrs_tlTable INTO l_attr_rec ;
     EXIT WHEN c_rootAttrs_tlTable%NOTFOUND ;
       l_rootAttrs_TlTable_dbCol := l_rootAttrs_TlTable_dbCol || ' , '|| l_attr_rec.DATABASE_COLUMN ;
       l_rootAttrs_TlTable_value := l_rootAttrs_TlTable_value || ' , NULL ' ;
    END LOOP;
    CLOSE c_rootAttrs_tlTable;
    l_rootAttrs_TlTable_dbCol  := SUBSTR ( l_rootAttrs_TlTable_dbCol  , INSTR( l_rootAttrs_TlTable_dbCol , ',')+1 ) ;
    l_rootAttrs_TlTable_value  := SUBSTR ( l_rootAttrs_TlTable_value  , INSTR( l_rootAttrs_TlTable_value , ',')+1 ) ;

   OPEN  c_rootAttrs_tlTable  ('EGO_ITEM_GTIN_MULTI_ATTRS', 'L' ,'LP' ,  'A') ;
    LOOP
     FETCH c_rootAttrs_tlTable INTO l_attr_rec ;
     EXIT WHEN c_rootAttrs_tlTable%NOTFOUND ;
       l_rootAttrs_MulTlTable_dbCol := l_rootAttrs_MulTlTable_dbCol || ' , '|| l_attr_rec.DATABASE_COLUMN ;
       l_rootAttrs_MulTlTable_value := l_rootAttrs_MulTlTable_value || ' , NULL ' ;
    END LOOP;
    CLOSE c_rootAttrs_tlTable;
    l_rootAttrs_MulTlTable_dbCol  := SUBSTR ( l_rootAttrs_MulTlTable_dbCol  , INSTR( l_rootAttrs_MulTlTable_dbCol , ',')+1 ) ;
    l_rootAttrs_MulTlTable_value  := SUBSTR ( l_rootAttrs_MulTlTable_value  , INSTR( l_rootAttrs_MulTlTable_value , ',')+1 ) ;

    Write_Debug('Clear_Gtin_Attrs  : Fetched the metadata');

    OPEN c_itemId_OrgId (p_resultfmt_usage_id) ;
      LOOP
        FETCH c_itemId_OrgId into l_inventory_item_id , l_organization_id ;
        EXIT WHEN c_itemId_OrgId%NOTFOUND ;
           /*
            * GTID can be changed only if the Item is not having a
            * packaging hierarchy.So we will clear the attributes
            * only if the packaging hierarcy does not exist.
            */

           EXECUTE IMMEDIATE ' BEGIN BOM_IMPLODER_PUB.IMPLODER_USEREXIT (
                                   SEQUENCE_ID                => NULL ,
                                   ENG_MFG_FLAG               => :1 ,
                                   ORG_ID                     => :2 ,
                                   IMPL_FLAG                  => :3 ,
                                   DISPLAY_OPTION             => :4 ,
                                   LEVELS_TO_IMPLODE          => :5 ,
                                   OBJ_NAME                   => :6 ,
                                   PK1_VALUE                  => :7 ,
                                   PK2_VALUE                  => :8 ,
                                   PK3_VALUE                  => NULL ,
                                   PK4_VALUE                  => NULL ,
                                   PK5_VALUE                  => NULL ,
                                   IMPL_DATE                  => :9,
                                   UNIT_NUMBER_FROM           => :10 ,
                                   UNIT_NUMBER_TO             => :11 ,
                                   ERR_MSG                    => :12 ,
                                   ERR_CODE                   => :13 ,
                                   ORGANIZATION_OPTION        => :14 ,
                                   ORGANIZATION_HIERARCHY     => NULL ,
                                   SERIAL_NUMBER_FROM         => NULL ,
                                   SERIAL_NUMBER_TO           => NULL ,
                                   STRUCT_TYPE                => :15 ,
                                   PREFERRED_ONLY             => :16 ,
                                   USED_IN_STRUCTURE          => :17
                                 ); END ; '
             USING  IN 2,  IN l_organization_id,  IN 2,  IN 1,  IN 60,  IN 'EGO_ITEM',
                    IN  l_inventory_item_id,  IN l_organization_id, IN  to_char(SYSDATE,'YYYY/MM/DD HH24:MI:SS') ,
                    IN 'N', IN 'Y', OUT l_errbuff, OUT l_err_code,  IN 1,
                    IN 'Packaging Hierarchy', IN  2, OUT l_used_in_structure ;


        IF (l_used_in_structure <> 'T') THEN
            OPEN c_gtid ( l_inventory_item_id  , l_organization_id  );
            FETCH c_gtid INTO l_gtid;
            -- Bug : 4099546
            CLOSE c_gtid;
              IF (l_gtid = 'BASE_UNIT_OR_EACH' )THEN

                IF ( length(l_leafAttrs_bTable_dbCol) > 0 ) THEN

                  EXECUTE IMMEDIATE ' UPDATE  EGO_ITEM_GTN_ATTRS_B SET  ( '|| l_leafAttrs_bTable_dbCol ||
                                   ' ) = ( SELECT '|| l_leafAttrs_bTable_value ||
                                   ' FROM DUAL ) WHERE INVENTORY_ITEM_ID  = :inventory_item_id '||
                                   ' AND ORGANIZATION_ID = :organization_id '  USING l_inventory_item_id , l_organization_id;

                END IF;

                IF ( length(l_leafAttrs_tlTable_dbCol) > 0 )  THEN

                  EXECUTE IMMEDIATE ' UPDATE  EGO_ITEM_GTN_ATTRS_TL SET ( '|| l_leafAttrs_tlTable_dbCol ||
                                  ' ) = ( SELECT '|| l_leafAttrs_tlTable_value ||
                                  ' FROM DUAL ) WHERE INVENTORY_ITEM_ID  = :inventory_item_id ' ||
                                  ' AND ORGANIZATION_ID = :organization_id '  USING l_inventory_item_id , l_organization_id;
                 END IF;

                IF ( length(l_leafAttrs_MulBTable_dbCol) > 0 )  THEN

                  EXECUTE IMMEDIATE ' UPDATE  EGO_ITM_GTN_MUL_ATTRS_B SET ( ' || l_leafAttrs_MulBTable_dbCol||
                                  ' ) = ( SELECT ' || l_leafAttrs_MulBTable_value ||
                                  ' FROM DUAL ) WHERE INVENTORY_ITEM_ID  = :inventory_item_id ' ||
                                  ' AND ORGANIZATION_ID = :organization_id '  USING l_inventory_item_id , l_organization_id;
                END IF;
                IF ( length(l_leafAttrs_MultlTable_dbCol) > 0 ) THEN
                  EXECUTE IMMEDIATE ' UPDATE  EGO_ITM_GTN_MUL_ATTRS_TL SET ( ' || l_leafAttrs_MultlTable_dbCol||
                                  ' ) = ( SELECT ' || l_leafAttrs_MultlTable_value ||
                                  ' FROM DUAL ) WHERE INVENTORY_ITEM_ID  = :inventory_item_id' ||
                                  ' AND ORGANIZATION_ID = :organization_id '  USING l_inventory_item_id , l_organization_id;
                END IF;

                EGO_GTIN_PVT.UPDATE_REG_PUB_UPDATE_DATES (p_inventory_item_id  => l_inventory_item_id ,
                                                          p_organization_id    => l_organization_id ,
                                                          p_update_reg         => 'Y' ,
                                                          x_return_status      => l_return_status ,
                                                          x_msg_count          => l_msg_count,
                                                          x_msg_data           => l_msg_data );
               IF l_return_status <>  'S'  THEN
                   Write_Debug('GTIN : Clear_Gtin_Attrs. :: Exception from EGO_GTIN_PVT.UPDATE_REG_PUB_UPDATE_DATES ');
                   Write_Debug('GTIN : Clear_Gtin_Attrs. ::message ' || l_msg_data );
               END IF;

              ELSE

                IF ( length(l_rootAttrs_bTable_dbCol) > 0 )  THEN

                  EXECUTE IMMEDIATE ' UPDATE EGO_ITEM_GTN_ATTRS_B SET ( '|| l_rootAttrs_bTable_dbCol ||
                                  ' ) = ( SELECT'|| l_rootAttrs_bTable_value ||
                                  ' FROM DUAL ) WHERE INVENTORY_ITEM_ID  =  :inventory_item_id '||
                                  ' AND ORGANIZATION_ID = :organization_id  ' USING l_inventory_item_id , l_organization_id;
                END IF;
                IF ( length(l_rootAttrs_tlTable_dbCol) > 0 ) THEN

                  EXECUTE IMMEDIATE ' UPDATE EGO_ITEM_GTN_ATTRS_TL SET ( '|| l_rootAttrs_tlTable_dbCol ||
                                  ' ) = ( SELECT'|| l_rootAttrs_tlTable_value ||
                                  ' FROM DUAL ) WHERE INVENTORY_ITEM_ID  = :inventory_item_id ' ||
                                  ' AND ORGANIZATION_ID =  :organization_id ' USING l_inventory_item_id , l_organization_id;
                END IF;
                IF ( length(l_rootAttrs_MulBTable_dbCol) > 0 ) THEN

                  EXECUTE IMMEDIATE ' UPDATE EGO_ITM_GTN_MUL_ATTRS_B SET ( '|| l_rootAttrs_MulBTable_dbCol ||
                                  ' ) = ( SELECT '|| l_rootAttrs_MulBTable_value ||
                                  ' FROM DUAL ) WHERE INVENTORY_ITEM_ID  = :inventory_item_id ' ||
                                  ' AND ORGANIZATION_ID = :organization_id '  USING l_inventory_item_id , l_organization_id;
                END IF;
                IF ( length(l_rootAttrs_MultlTable_dbCol) > 0 ) THEN

                  EXECUTE IMMEDIATE ' UPDATE EGO_ITM_GTN_MUL_ATTRS_TL SET ( '||l_rootAttrs_MultlTable_dbCol ||
                                  ' ) = ( SELECT '|| l_rootAttrs_MultlTable_value ||
                                  ' FROM DUAL ) WHERE INVENTORY_ITEM_ID  = :inventory_item_id ' ||
                                  ' AND ORGANIZATION_ID = :organization_id '  USING l_inventory_item_id , l_organization_id;
                END IF;

                EGO_GTIN_PVT.UPDATE_REG_PUB_UPDATE_DATES (p_inventory_item_id  => l_inventory_item_id ,
                                                          p_organization_id    => l_organization_id ,
                                                          p_update_reg         => 'N' ,
                                                          x_return_status      => l_return_status,
                                                          x_msg_count          => l_msg_count,
                                                          x_msg_data           => l_msg_data );
               IF l_return_status <> 'S' THEN
                   Write_Debug('GTIN : Clear_Gtin_Attrs. :: Exception from EGO_GTIN_PVT.UPDATE_REG_PUB_UPDATE_DATES ');
                   Write_Debug('GTIN : Clear_Gtin_Attrs. ::message ' || l_msg_data );
               END IF;

              END IF; --GTID is Each / non-Each

        END IF; -- If the Item is not having a Packaging Hierarchy

      END LOOP;
      close c_itemId_OrgId;

  Write_Debug('GTIN : Clear_Gtin_Attrs.');

  -------------------------------------------------------------
  -- Commit at the end.
  -------------------------------------------------------------
  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF (l_is_debug) THEN
    Close_Debug_Session;
  END IF;

  x_ret_code := G_STATUS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      x_ret_code := G_STATUS_ERROR;
      x_errbuff := SUBSTRB(SQLERRM, 1,240);
      Write_Debug('Clear_Gtin_Attrs  : EXCEPTION HAPPENED => '||x_errbuff);

      IF c_errLogFile%ISOPEN THEN
        close c_errLogFile;
      END IF;

      IF c_itemId_OrgId%ISOPEN THEN
       close c_itemId_OrgId ;
      END IF;

      IF c_gtid%ISOPEN THEN
        close c_gtid ;
      END IF;

      IF c_leafAttrs_bTable%ISOPEN THEN
        close c_leafAttrs_bTable ;
      END IF;

      IF c_rootAttrs_bTable%ISOPEN THEN
        close c_rootAttrs_bTable   ;
      END IF;

      IF c_leafAttrs_tlTable%ISOPEN THEN
        close c_leafAttrs_tlTable  ;
      END IF;

      IF c_rootAttrs_tlTable%ISOPEN THEN
        close c_rootAttrs_tlTable ;
      END IF;

      IF (l_is_debug) THEN
        Close_Debug_Session;
      END IF;

END Clear_Gtin_Attrs ;

--  ============================================================================
--  API Name    : Populate_Seq_Gen_Item_Nums
--  Description : This procedure will be called from IOI
--                (after org and catalog category details are resolved)
--                to populate the item numbers for all the sequence generated items.
--  ============================================================================
PROCEDURE Populate_Seq_Gen_Item_Nums
          (p_set_id           IN         NUMBER
          ,p_org_id           IN         NUMBER
          ,p_all_org          IN         NUMBER
          ,p_rec_status       IN         NUMBER
          ,x_return_status    OUT NOCOPY VARCHAR2
          ,x_msg_count        OUT NOCOPY NUMBER
          ,x_msg_data         OUT NOCOPY VARCHAR2) IS

  TYPE num_tbl_type   IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;

  l_cc_id_table                  num_tbl_type;
  l_trans_id_table               num_tbl_type;
  l_org_id_table                 DBMS_SQL.VARCHAR2_TABLE;
  l_ss_id_table                  num_tbl_type;
  l_ss_ref_table                 EGO_VARCHAR_TBL_TYPE;
  l_item_num_table               EGO_VARCHAR_TBL_TYPE;
  l_old_item_num_table           EGO_VARCHAR_TBL_TYPE; --Added R12C
  l_sql                          VARCHAR2(10000);
  l_cc_rows_processed            NUMBER;
  l_item_rows_processed          NUMBER;
  l_xset_id                      NUMBER;

BEGIN
  Write_Debug (' started with params p_set_id: '||p_set_id||' p_org_id: '||p_org_id||' p_all_org: '||p_all_org);
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;

  --Only Item Row has p_set_id, setting batch id for the rest
  l_xset_id := p_set_id-5000000000000;

  --Removing Item Num NULL clause - R12C
  SELECT DISTINCT item_catalog_group_id
  BULK COLLECT INTO l_cc_id_table
  FROM  MTL_SYSTEM_ITEMS_INTERFACE
  WHERE set_process_id = p_set_id
    AND (organization_id = p_org_id OR p_all_org = 1)
    AND process_flag = p_rec_status
    AND transaction_type = 'CREATE';

  l_cc_rows_processed := SQL%ROWCOUNT;
  IF l_cc_rows_processed = 0 THEN
    RETURN;
  END IF;

  FOR cc_row_index in 1..l_cc_rows_processed LOOP
    Write_Debug (' CC being processed '||cc_row_index);

    --Removing Item Num NULL clause - R12C
    SELECT TO_CHAR(organization_id), item_number,
           transaction_id, source_system_id,
           source_system_reference
    BULK COLLECT INTO l_org_id_table, l_old_item_num_table,
                      l_trans_id_table, l_ss_id_table,
                      l_ss_ref_table
    FROM  MTL_SYSTEM_ITEMS_INTERFACE
    WHERE set_process_id = p_set_id
      AND (organization_id = p_org_id OR p_all_org = 1)
      AND item_catalog_group_id = l_cc_id_table(cc_row_index)
      AND process_flag = p_rec_status
      AND transaction_type = 'CREATE';

    l_item_rows_processed := SQL%ROWCOUNT;
    IF (l_item_rows_processed > 0) THEN
     EGO_ITEM_PVT.Get_Seq_Gen_Item_Nums
                         (
                           p_item_catalog_group_id  => l_cc_id_table(cc_row_index)
                          ,p_org_id_tbl             => l_org_id_table
                          ,x_item_num_tbl           => l_item_num_table
                          );

      -- for item interface table
      FORALL item_num_row_index IN 1..l_item_rows_processed
        UPDATE mtl_system_items_interface
           SET item_number = l_item_num_table(item_num_row_index),
               SEGMENT1 = NULL,
               SEGMENT2 = NULL,
               SEGMENT3 = NULL,
               SEGMENT4 = NULL,
               SEGMENT5 = NULL,
               SEGMENT6 = NULL,
               SEGMENT7 = NULL,
               SEGMENT8 = NULL,
               SEGMENT9 = NULL,
               SEGMENT10 = NULL,
               SEGMENT11 = NULL,
               SEGMENT12 = NULL,
               SEGMENT13 = NULL,
               SEGMENT14 = NULL,
               SEGMENT15 = NULL,
               SEGMENT16 = NULL,
               SEGMENT17 = NULL,
               SEGMENT18 = NULL,
               SEGMENT19 = NULL,
               SEGMENT20 = NULL
         WHERE set_process_id IN (p_set_id, l_xset_id) /*bug 6158936 child records are in l_xset_id*/
           AND process_flag IN (p_rec_status, 60001)   /*bug 6158936 child records are in process_flag + 60000*/
           AND source_system_id = l_ss_id_table(item_num_row_index)
           AND ( item_number = l_old_item_num_table(item_num_row_index) OR
                 source_system_reference = l_ss_ref_table(item_num_row_index));

      -- for item revisions interface table
      FORALL rev_row_index IN 1..l_item_rows_processed
        UPDATE mtl_item_revisions_interface
           SET item_number = l_item_num_table(rev_row_index)
         WHERE set_process_id = l_xset_id
           AND source_system_id = l_ss_id_table(rev_row_index)
           AND process_flag = p_rec_status
           AND ( item_number = l_old_item_num_table(rev_row_index) OR
                 source_system_reference = l_ss_ref_table(rev_row_index));

      -- for category assignments interface table
      FORALL item_cat_row_index IN 1..l_item_rows_processed
        UPDATE mtl_item_categories_interface
           SET item_number = l_item_num_table(item_cat_row_index)
         WHERE set_process_id = l_xset_id
           AND source_system_id = l_ss_id_table(item_cat_row_index)
           AND process_flag = p_rec_status
           AND ( item_number = l_old_item_num_table(item_cat_row_index) OR
                 source_system_reference = l_ss_ref_table(item_cat_row_index));

      -- for user attrs interface table
      FORALL usr_attr_row_index IN 1..l_item_rows_processed
        UPDATE ego_itm_usr_attr_intrfc
           SET item_number = l_item_num_table(usr_attr_row_index)
         WHERE data_set_id = l_xset_id
           AND source_system_id = l_ss_id_table(usr_attr_row_index)
           AND process_status = p_rec_status
           AND ( item_number = l_old_item_num_table(usr_attr_row_index) OR
                 source_system_reference = l_ss_ref_table(usr_attr_row_index));

      -- item people interface table
      FORALL ss_id_row_index IN 1..l_item_rows_processed
        UPDATE ego_item_people_intf
           SET item_number = l_item_num_table(ss_id_row_index)
         WHERE data_set_id = l_xset_id
           AND source_system_id = l_ss_id_table(ss_id_row_index)
           AND process_status = p_rec_status
           AND ( item_number = l_old_item_num_table(ss_id_row_index) OR
                 source_system_reference = l_ss_ref_table(ss_id_row_index));

      -- aml interface table
      FORALL ss_id_row_index IN 1..l_item_rows_processed
        UPDATE ego_aml_intf
           SET item_number = l_item_num_table(ss_id_row_index)
         WHERE data_set_id = l_xset_id
           AND source_system_id = l_ss_id_table(ss_id_row_index)
           AND process_flag = p_rec_status
           AND ( item_number = l_old_item_num_table(ss_id_row_index) OR
                 source_system_reference = l_ss_ref_table(ss_id_row_index));

      --BOM interface tables R12C
      FORALL bill_id_row_index IN 1..l_item_rows_processed
        UPDATE bom_bill_of_mtls_interface
           SET item_number = l_item_num_table(bill_id_row_index)
         WHERE process_flag = p_rec_status
           AND batch_id = l_xset_id
           AND ( item_number = l_old_item_num_table(bill_id_row_index) OR
                 source_system_reference = l_ss_ref_table(bill_id_row_index));

      FORALL bom_inv_id_row_index IN 1..l_item_rows_processed
        UPDATE BOM_INVENTORY_COMPS_INTERFACE
           SET component_item_number = l_item_num_table(bom_inv_id_row_index)
         WHERE process_flag = p_rec_status
           AND batch_id = l_xset_id
           AND ( component_item_number = l_old_item_num_table(bom_inv_id_row_index) OR
                 comp_source_system_reference = l_ss_ref_table(bom_inv_id_row_index));

      FORALL bom_par_id_row_index IN 1..l_item_rows_processed
        UPDATE BOM_INVENTORY_COMPS_INTERFACE
           SET assembly_item_number = l_item_num_table(bom_par_id_row_index)
         WHERE process_flag = p_rec_status
           AND batch_id = l_xset_id
           AND ( assembly_item_number = l_old_item_num_table(bom_par_id_row_index) OR
                 parent_source_system_reference = l_ss_ref_table(bom_par_id_row_index));

      FORALL bom_sub_id_row_index IN 1..l_item_rows_processed
        UPDATE BOM_SUB_COMPS_INTERFACE
           SET assembly_item_number = l_item_num_table(bom_sub_id_row_index)
         WHERE process_flag = p_rec_status
           AND batch_id = l_xset_id
           AND ( assembly_item_number = l_old_item_num_table(bom_sub_id_row_index) OR
                 parent_source_system_reference = l_ss_ref_table(bom_sub_id_row_index));

      FORALL bom_sub_id_row_index IN 1..l_item_rows_processed
        UPDATE BOM_SUB_COMPS_INTERFACE
           SET component_item_number = l_item_num_table(bom_sub_id_row_index)
         WHERE process_flag = p_rec_status
           AND batch_id = l_xset_id
           AND ( component_item_number = l_old_item_num_table(bom_sub_id_row_index) OR
                 comp_source_system_reference = l_ss_ref_table(bom_sub_id_row_index));

      FORALL bom_sub_id_row_index IN 1..l_item_rows_processed
        UPDATE BOM_SUB_COMPS_INTERFACE
           SET substitute_comp_number = l_item_num_table(bom_sub_id_row_index)
         WHERE process_flag = p_rec_status
           AND batch_id = l_xset_id
           AND ( substitute_comp_number = l_old_item_num_table(bom_sub_id_row_index) OR
                 subcom_source_system_reference = l_ss_ref_table(bom_sub_id_row_index));

      FORALL bom_ref_id_row_index IN 1..l_item_rows_processed
        UPDATE BOM_REF_DESGS_INTERFACE
           SET assembly_item_number = l_item_num_table(bom_ref_id_row_index)
         WHERE process_flag = p_rec_status
           AND batch_id = l_xset_id
           AND ( assembly_item_number = l_old_item_num_table(bom_ref_id_row_index) OR
                 parent_source_system_reference = l_ss_ref_table(bom_ref_id_row_index));

      FORALL bom_ref_id_row_index IN 1..l_item_rows_processed
        UPDATE BOM_REF_DESGS_INTERFACE
           SET component_item_number = l_item_num_table(bom_ref_id_row_index)
         WHERE process_flag = p_rec_status
           AND batch_id = l_xset_id
           AND ( component_item_number = l_old_item_num_table(bom_ref_id_row_index) OR
                 comp_source_system_reference = l_ss_ref_table(bom_ref_id_row_index));

      FORALL bom_comp_id_row_index IN 1..l_item_rows_processed
        UPDATE BOM_COMPONENT_OPS_INTERFACE
           SET assembly_item_number = l_item_num_table(bom_comp_id_row_index)
         WHERE process_flag = p_rec_status
           AND batch_id = l_xset_id
           AND ( assembly_item_number = l_old_item_num_table(bom_comp_id_row_index) OR
                 parent_source_system_reference = l_ss_ref_table(bom_comp_id_row_index));

      FORALL bom_comp_id_row_index IN 1..l_item_rows_processed
        UPDATE BOM_COMPONENT_OPS_INTERFACE
           SET component_item_number = l_item_num_table(bom_comp_id_row_index)
         WHERE process_flag = p_rec_status
           AND batch_id = l_xset_id
           AND ( component_item_number = l_old_item_num_table(bom_comp_id_row_index) OR
                 comp_source_system_reference = l_ss_ref_table(bom_comp_id_row_index));

    END IF; --end: IF (l_org_id_rows_cnt > 0) THEN

  END LOOP; -- for cc_row_identifier in 1..l_rows_processed

EXCEPTION
  WHEN OTHERS THEN
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', 'EGO_ITEM_BULKLOAD_PKG');
      FND_MESSAGE.Set_Token('API_NAME', 'Populate_Seq_Gen_Item_Nums');
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
END Populate_Seq_Gen_Item_Nums;



--  ============================================================================
--  API Name    : load_intersections_interface
--  Description : This procedure will be called to load the intersection
--                interface table ego_item_associations_intf with the required data
--  ============================================================================
PROCEDURE load_intersections_interface
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_set_process_id        IN         NUMBER,
                 x_set_process_id        OUT NOCOPY NUMBER,
                 x_errbuff               OUT NOCOPY VARCHAR2,
                 x_retcode               OUT NOCOPY VARCHAR2
                ) IS


  ------------------------------------------------------------------------------------------
  -- To get the Item intersection attr columns in the Result Format.
  ------------------------------------------------------------------------------------------
  CURSOR c_item_intersection_intf_cols (c_resultfmt_usage_id  IN  NUMBER) IS
    SELECT attribute_code, intf_column_name, data_level_id
    FROM   ego_results_fmt_usages
    WHERE  resultfmt_usage_id = c_resultfmt_usage_id
     /* AND DATA_LEVEL_ID in (SELECT DATA_LEVEL_ID
                              FROM EGO_DATA_LEVEL_B
                             WHERE DATA_LEVEL_NAME IN ('ITEM_SUP','ITEM_ORG','ITEM_SUP_SITE')
                               AND APPLICATION_ID = 431
                               AND ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
                            )*/;

  ---------------------------------------------------------------------
  -- Type Declarations
  ---------------------------------------------------------------------
  TYPE VARCHAR_TBL_TYPE IS TABLE OF VARCHAR2(256)
   INDEX BY BINARY_INTEGER;

               -------------------------
               --   local variables   --
               -------------------------
  l_prod_col_name       VARCHAR2(256);
  l_intf_col_name       VARCHAR2(256);

  ---------------------------------------------------------------------
  -- Assuming that the column name will not be more than 30 chars.
  ---------------------------------------------------------------------
  l_supplier_name_col           VARCHAR2(30);
  l_org_code_col                VARCHAR2(30);
  l_supplier_site_col           VARCHAR2(30);
  l_supplier_site_name_col      VARCHAR2(30);
  l_supplier_site_prim_flag_col VARCHAR2(30);
  l_supplier_site_status_col    VARCHAR2(30);
  l_sup_site_store_status_col   VARCHAR2(30);
  l_supplier_number_col         VARCHAR2(30);

  l_msii_set_process_id    NUMBER;
  i                        NUMBER;
  l_data_level_id          NUMBER;
  l_item_number_col        VARCHAR2(30);
  l_supplier_prim_flag_col VARCHAR2(30);
  l_supplier_status_col    VARCHAR2(30);
  l_data_level_id_1        VARCHAR2(30);

  l_yes_meaning            VARCHAR2(20);
  l_no_meaning             VARCHAR2(20);
  l_active_meaning         VARCHAR2(20);
  l_inactive_meaning       VARCHAR2(20);
  l_has_sup_sit_org_col    VARCHAR2(1);

  --------------------------------------------
  -- Long Dynamic SQL String
  --------------------------------------------
  l_dyn_sql                VARCHAR2(10000);

BEGIN
   Write_Debug('*Item Intersections Interface*');

   Write_Debug('Retrieving the Display and INTF cols');
   i := 0;

   IF p_set_process_id IS NULL THEN
     SELECT mtl_system_items_intf_sets_s.NEXTVAL
       INTO l_msii_set_process_id
     FROM dual;
   ELSE
     l_msii_set_process_id := p_set_process_id;
   END IF;

   l_has_sup_sit_org_col := 'N';
   --------------------------------------------------------------------
   -- Saving the column names in local table for easy retrieval later.
   -- Also save important columns such as Item ID, Org ID etc.,
   --------------------------------------------------------------------
   FOR c_item_rev_attr_intf_rec IN c_item_intersection_intf_cols
     (
       p_resultfmt_usage_id
      )
   LOOP

     l_prod_col_name := c_item_rev_attr_intf_rec.attribute_code;
     l_intf_col_name := c_item_rev_attr_intf_rec.intf_column_name;
     l_data_level_id := c_item_rev_attr_intf_rec.data_level_id;

-- bedajna bug 6491762
--     IF(l_data_level_id = 43105) THEN
     IF((l_data_level_id = 43105) OR (l_prod_col_name = 'SUPPLIERSITE_STORE_STATUS')) THEN
       l_has_sup_sit_org_col := 'Y';
     END IF;
      --------------------------------------------------------------------
      -- Store the Item Number column name in the Generic Interface
      --------------------------------------------------------------------
      IF (l_prod_col_name = G_ITEM_NUMBER) THEN
        l_item_number_col := l_intf_col_name;
        Write_Debug('Item Number : '||l_item_number_col);

      --------------------------------------------------------------------
      -- Store the Organization Code column name in the Generic Interface
      --------------------------------------------------------------------
      ELSIF (l_prod_col_name = G_ORG_CODE) THEN
        l_org_code_col := l_intf_col_name;
        Write_Debug('Organization Code : '||l_org_code_col);

      --------------------------------------------------------------------
      -- Store the Supplier Name column name in the Generic Interface
      --------------------------------------------------------------------
      ELSIF (l_prod_col_name = 'SUPPLIER_NAME') THEN
        l_supplier_name_col := l_intf_col_name;
        Write_Debug('Supplier Name : '||l_supplier_name_col);

      --------------------------------------------------------------------
      -- Store the Supplier Number column name in the Generic Interface
      --------------------------------------------------------------------
      ELSIF (l_prod_col_name = 'SUPPLIER_NUMBER') THEN
        l_supplier_number_col := l_intf_col_name;
        Write_Debug('Supplier Number : '||l_supplier_name_col);


      --------------------------------------------------------------------
      -- Store the Supplier Name column name in the Generic Interface
      --------------------------------------------------------------------
      ELSIF (l_prod_col_name = 'SUPPLIER_PRIMARY') THEN
        l_supplier_prim_flag_col := l_intf_col_name;
        Write_Debug('Supplier Primary flag : '||l_supplier_name_col);

      --------------------------------------------------------------------
      -- Store the Supplier Status column name in the Generic Interface
      --------------------------------------------------------------------
      ELSIF (l_prod_col_name = 'SUPPLIER_STATUS') THEN
        l_supplier_status_col := l_intf_col_name;
        Write_Debug('Supplier Status : '||l_supplier_status_col);

      --------------------------------------------------------------------
      -- Store the Supplier Site Name column name in the Generic Interface
      --------------------------------------------------------------------
      ELSIF (l_prod_col_name = 'SUPPLIER_SITE') THEN
        l_supplier_site_name_col := l_intf_col_name;
        Write_Debug('Supplier Site Name : '||l_supplier_site_name_col);

      --------------------------------------------------------------------
      -- Store the Supplier Name column name in the Generic Interface
      --------------------------------------------------------------------
      ELSIF (l_prod_col_name = 'SUPPLIERSITE_PRIMARY') THEN
        l_supplier_site_prim_flag_col := l_intf_col_name;
        Write_Debug('Supplier Primary flag : '||l_supplier_site_prim_flag_col);

      --------------------------------------------------------------------
      -- Store the Supplier Status column name in the Generic Interface
      --------------------------------------------------------------------
      ELSIF (l_prod_col_name = 'SUPPLIERSITE_STATUS') THEN
        l_supplier_site_status_col := l_intf_col_name;
        Write_Debug('Supplier site Status : '||l_supplier_site_status_col);

      ELSIF (l_prod_col_name = 'SUPPLIERSITE_STORE_STATUS') THEN
        l_sup_site_store_status_col := l_intf_col_name;
        Write_Debug('Supplier site store Status : '||l_sup_site_store_status_col);

      END IF; --IF (l_prod_col_name = G_ITEM_NUMBER) THEN

   END LOOP; --FOR c_item_rev_attr_intf_rec

   SELECT MEANING
     INTO l_yes_meaning
    FROM  FND_LOOKUP_VALUES_VL
    WHERE  LOOKUP_TYPE = 'EGO_YES_NO'
      AND  LOOKUP_CODE = 'Y';

   SELECT MEANING
     INTO l_no_meaning
    FROM  FND_LOOKUP_VALUES_VL
    WHERE  LOOKUP_TYPE = 'EGO_YES_NO'
      AND  LOOKUP_CODE = 'N';

   SELECT MEANING
     INTO l_active_meaning
    FROM  FND_LOOKUP_VALUES_VL
    WHERE  LOOKUP_TYPE = 'EGO_ASSOCIATION_STATUS'
      AND  LOOKUP_CODE = '1';

   SELECT MEANING
     INTO l_inactive_meaning
    FROM  FND_LOOKUP_VALUES_VL
    WHERE  LOOKUP_TYPE = 'EGO_ASSOCIATION_STATUS'
      AND  LOOKUP_CODE = '2';

   ----------------------------------------------------------------------
   -- Inserting rows in the intersection interface table for supplier
   -- intersection ...
   ----------------------------------------------------------------------
   IF(l_supplier_name_col IS NOT NULL OR
      l_supplier_number_col IS NOT NULL) THEN

     SELECT DATA_LEVEL_ID
       INTO l_data_level_id
       FROM EGO_DATA_LEVEL_B
      WHERE DATA_LEVEL_NAME = 'ITEM_SUP'
        AND APPLICATION_ID = 431
        AND ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP';

     l_dyn_sql :=              'INSERT INTO EGO_ITEM_ASSOCIATIONS_INTF ';
     l_dyn_sql := l_dyn_sql || '( ';
     l_dyn_sql := l_dyn_sql || ' BATCH_ID                 ,   ';
     l_dyn_sql := l_dyn_sql || ' ITEM_NUMBER              ,   ';
     l_dyn_sql := l_dyn_sql || ' INVENTORY_ITEM_ID        ,   ';
     l_dyn_sql := l_dyn_sql || ' ORGANIZATION_ID          ,   ';
     l_dyn_sql := l_dyn_sql || ' DATA_LEVEL_ID            ,   ';
     l_dyn_sql := l_dyn_sql || ' PRIMARY_FLAG             ,   ';
     l_dyn_sql := l_dyn_sql || ' STATUS_CODE              ,   ';
     l_dyn_sql := l_dyn_sql || ' SUPPLIER_NAME            ,   ';
     l_dyn_sql := l_dyn_sql || ' SUPPLIER_NUMBER          ,   ';
     l_dyn_sql := l_dyn_sql || ' ORGANIZATION_CODE        ,   ';
     l_dyn_sql := l_dyn_sql || ' TRANSACTION_TYPE         ,   ';
     l_dyn_sql := l_dyn_sql || ' PROCESS_FLAG             ,   ';
     l_dyn_sql := l_dyn_sql || ' TRANSACTION_ID           ,   ';
     l_dyn_sql := l_dyn_sql || ' CREATED_BY               ,   ';
     l_dyn_sql := l_dyn_sql || ' CREATION_DATE            ,   ';
     l_dyn_sql := l_dyn_sql || ' LAST_UPDATED_BY          ,   ';
     l_dyn_sql := l_dyn_sql || ' LAST_UPDATE_DATE         ,   ';
     l_dyn_sql := l_dyn_sql || ' LAST_UPDATE_LOGIN        ,   ';
     l_dyn_sql := l_dyn_sql || ' REQUEST_ID               ,   ';
     l_dyn_sql := l_dyn_sql || ' PROGRAM_APPLICATION_ID   ,   ';
     l_dyn_sql := l_dyn_sql || ' PROGRAM_ID               ,   ';
     l_dyn_sql := l_dyn_sql || ' PROGRAM_UPDATE_DATE      ,   ';
     l_dyn_sql := l_dyn_sql || ' BUNDLE_ID                ,   ';
     l_dyn_sql := l_dyn_sql || ' SOURCE_SYSTEM_ID         ,   ';
     l_dyn_sql := l_dyn_sql || ' SOURCE_SYSTEM_REFERENCE  ,   ';
     l_dyn_sql := l_dyn_sql || ' ASSOCIATION_ID               ';
     l_dyn_sql := l_dyn_sql || ' )                            ';
     l_dyn_sql := l_dyn_sql || 'SELECT ';
     l_dyn_sql := l_dyn_sql ||  To_char(l_msii_set_process_id)||' , ';
     l_dyn_sql := l_dyn_sql || ' EBI.'||l_item_number_col ||' , ';
     l_dyn_sql := l_dyn_sql || ' EBI.INSTANCE_PK1_VALUE   , ';
     l_dyn_sql := l_dyn_sql || ' EBI.INSTANCE_PK2_VALUE   , ';
     --l_dyn_sql := l_dyn_sql || ' ''EGO_ITEM''             , ';
     l_dyn_sql := l_dyn_sql || l_data_level_id||'         , ';
     IF(l_supplier_prim_flag_col IS NOT NULL) THEN
  --     bedajna bug 6429874
  --     l_dyn_sql := l_dyn_sql || 'DECODE (EBI.'||l_supplier_prim_flag_col||', '''||l_yes_meaning||''', ''Y'', '''||l_no_meaning||''', ''N'', NULL ) , ';
       l_dyn_sql := l_dyn_sql || 'DECODE (EBI.'||l_supplier_prim_flag_col||', '||':yes_meaning'||', ''Y'', '||':no_meaning'||', ''N'', NULL ) , ';
     ELSE
       l_dyn_sql := l_dyn_sql || ' NULL,  ';
     END IF;
     IF(l_supplier_status_col IS NOT NULL) THEN
  --     bedajna bug 6429874
  --     l_dyn_sql := l_dyn_sql || 'DECODE(EBI.'||l_supplier_status_col||' , '''||l_active_meaning||''', ''1'', '''||l_inactive_meaning||''', ''2'', NULL) STATUS_CODE ,';
       l_dyn_sql := l_dyn_sql || 'DECODE(EBI.'||l_supplier_status_col||' , '||':active_meaning'||', ''1'', '||':inactive_meaning'||', ''2'', NULL) STATUS_CODE ,';
     ELSE
       l_dyn_sql := l_dyn_sql || ' NULL,  ';
     END IF;
     IF(l_supplier_name_col IS NOT NULL)THEN
       l_dyn_sql := l_dyn_sql || 'EBI.'||l_supplier_name_col ||' , ';
     ELSE
       l_dyn_sql := l_dyn_sql || ' NULL,  ';
     END IF;
     IF(l_supplier_number_col IS NOT NULL)THEN
       l_dyn_sql := l_dyn_sql || 'EBI.'||l_supplier_number_col ||' , ';
     ELSE
       l_dyn_sql := l_dyn_sql || ' NULL,  ';
     END IF;
     l_dyn_sql := l_dyn_sql || 'EBI.'||l_org_code_col ||'       , ';
     l_dyn_sql := l_dyn_sql || '''SYNC''                        , ';
     l_dyn_sql := l_dyn_sql || G_PROCESS_STATUS||'              , ';
     l_dyn_sql := l_dyn_sql || 'MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL , ';
     l_dyn_sql := l_dyn_sql || 'EBI.'||'CREATED_BY              , ';
     l_dyn_sql := l_dyn_sql || 'EBI.'||'CREATION_DATE           , ';
     l_dyn_sql := l_dyn_sql || 'EBI.'||'LAST_UPDATED_BY         , ';
     l_dyn_sql := l_dyn_sql || 'EBI.'||'LAST_UPDATE_DATE        , ';
     l_dyn_sql := l_dyn_sql || 'EBI.'||'LAST_UPDATE_LOGIN       , ';
     l_dyn_sql := l_dyn_sql || 'EBI.'||'REQUEST_ID              , ';
     l_dyn_sql := l_dyn_sql || 'EBI.'||'PROGRAM_APPLICATION_ID  , ';
     l_dyn_sql := l_dyn_sql || 'EBI.'||'PROGRAM_ID              , ';
     l_dyn_sql := l_dyn_sql || 'EBI.'||'PROGRAM_UPDATE_DATE     , ';
     l_dyn_sql := l_dyn_sql || ' NULL                           , ';
     l_dyn_sql := l_dyn_sql || ' TO_NUMBER(EBI.C_FIX_COLUMN11)  , ';
     l_dyn_sql := l_dyn_sql || ' EBI.C_FIX_COLUMN12             , ';
     l_dyn_sql := l_dyn_sql || ' NULL                            ';
     l_dyn_sql := l_dyn_sql || 'FROM EGO_BULKLOAD_INTF EBI ';
     l_dyn_sql := l_dyn_sql || ' WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
     l_dyn_sql := l_dyn_sql || ' AND   EBI.PROCESS_STATUS = 1  ';
     IF(l_supplier_name_col IS NOT NULL AND l_supplier_number_col IS NOT NULL)THEN
       l_dyn_sql := l_dyn_sql || ' AND  ( EBI.'||l_supplier_name_col||' IS NOT NULL  ';
       l_dyn_sql := l_dyn_sql || '       OR EBI.'||l_supplier_number_col||' IS NOT NULL ) ';
     ELSIF(l_supplier_name_col IS NOT NULL AND l_supplier_number_col IS NULL) THEN
       l_dyn_sql := l_dyn_sql || ' AND   EBI.'||l_supplier_name_col||' IS NOT NULL  ';
     ELSIF(l_supplier_name_col IS NULL AND l_supplier_number_col IS NOT NULL) THEN
       l_dyn_sql := l_dyn_sql || ' AND   EBI.'||l_supplier_number_col||' IS NOT NULL  ';
     END IF;

     Write_Debug(l_dyn_sql);
--     bedajna bug 6429874
--     EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
    IF ( (l_supplier_prim_flag_col IS NOT NULL) AND (l_supplier_status_col IS NOT NULL) ) then
     EXECUTE IMMEDIATE l_dyn_sql USING l_yes_meaning, l_no_meaning, l_active_meaning, l_inactive_meaning, p_resultfmt_usage_id;
    ELSIF ( (l_supplier_prim_flag_col IS NOT NULL) AND (l_supplier_status_col IS NULL) ) then
     EXECUTE IMMEDIATE l_dyn_sql USING l_yes_meaning, l_no_meaning, p_resultfmt_usage_id;
    ELSIF ( (l_supplier_prim_flag_col IS NULL) AND (l_supplier_status_col IS NOT NULL) ) then
     EXECUTE IMMEDIATE l_dyn_sql USING l_active_meaning, l_inactive_meaning, p_resultfmt_usage_id;
    ELSIF ( (l_supplier_prim_flag_col IS NULL) AND (l_supplier_status_col IS NULL) ) then
     EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
    end if;

     Write_Debug('Item Revs Interface: Populated the Inv Item IDs, Org IDs.');

   END IF;
   --------------------------------------------------------------------------
   -- Inserting rows in the intersection interface table for supplier Site --
   -- and supplier site store intersection ...
   --------------------------------------------------------------------------
   IF((l_supplier_name_col IS NOT NULL OR l_supplier_number_col IS NOT NULL)
      AND l_supplier_site_name_col IS NOT NULL) THEN

      SELECT DATA_LEVEL_ID
        INTO l_data_level_id
        FROM EGO_DATA_LEVEL_B
       WHERE DATA_LEVEL_NAME = 'ITEM_SUP_SITE'
         AND APPLICATION_ID = 431
         AND ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP';

      SELECT DATA_LEVEL_ID
        INTO l_data_level_id_1
        FROM EGO_DATA_LEVEL_B
       WHERE DATA_LEVEL_NAME = 'ITEM_SUP_SITE_ORG'
         AND APPLICATION_ID = 431
         AND ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP';

      l_dyn_sql :=              'INSERT INTO EGO_ITEM_ASSOCIATIONS_INTF ';
      l_dyn_sql := l_dyn_sql || '( ';
      l_dyn_sql := l_dyn_sql || ' TRANSACTION_ID           ,   ';
      l_dyn_sql := l_dyn_sql || ' BATCH_ID                 ,   ';
      l_dyn_sql := l_dyn_sql || ' ITEM_NUMBER              ,   ';
      l_dyn_sql := l_dyn_sql || ' INVENTORY_ITEM_ID        ,   ';
      l_dyn_sql := l_dyn_sql || ' ORGANIZATION_ID          ,   ';
      --l_dyn_sql := l_dyn_sql || ' OBJ_NAME                 ,   ';
      l_dyn_sql := l_dyn_sql || ' DATA_LEVEL_ID            ,   ';
      l_dyn_sql := l_dyn_sql || ' PRIMARY_FLAG             ,   ';
      l_dyn_sql := l_dyn_sql || ' STATUS_CODE              ,   ';
      l_dyn_sql := l_dyn_sql || ' SUPPLIER_NAME            ,   ';
      l_dyn_sql := l_dyn_sql || ' SUPPLIER_NUMBER          ,   ';
      l_dyn_sql := l_dyn_sql || ' SUPPLIER_SITE_NAME       ,   ';
      l_dyn_sql := l_dyn_sql || ' ORGANIZATION_CODE        ,   ';
      l_dyn_sql := l_dyn_sql || ' TRANSACTION_TYPE         ,   ';
      l_dyn_sql := l_dyn_sql || ' PROCESS_FLAG             ,   ';
      l_dyn_sql := l_dyn_sql || ' CREATED_BY               ,   ';
      l_dyn_sql := l_dyn_sql || ' CREATION_DATE            ,   ';
      l_dyn_sql := l_dyn_sql || ' LAST_UPDATED_BY          ,   ';
      l_dyn_sql := l_dyn_sql || ' LAST_UPDATE_DATE         ,   ';
      l_dyn_sql := l_dyn_sql || ' LAST_UPDATE_LOGIN        ,   ';
      l_dyn_sql := l_dyn_sql || ' REQUEST_ID               ,   ';
      l_dyn_sql := l_dyn_sql || ' PROGRAM_APPLICATION_ID   ,   ';
      l_dyn_sql := l_dyn_sql || ' PROGRAM_ID               ,   ';
      l_dyn_sql := l_dyn_sql || ' PROGRAM_UPDATE_DATE      ,   ';
      l_dyn_sql := l_dyn_sql || ' BUNDLE_ID                ,   ';
      l_dyn_sql := l_dyn_sql || ' SOURCE_SYSTEM_ID         ,   ';
      l_dyn_sql := l_dyn_sql || ' SOURCE_SYSTEM_REFERENCE  ,   ';
      l_dyn_sql := l_dyn_sql || ' ASSOCIATION_ID               ';
      l_dyn_sql := l_dyn_sql || ' )                            ';
      l_dyn_sql := l_dyn_sql || 'SELECT ';
      l_dyn_sql := l_dyn_sql || 'MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL , ';
      l_dyn_sql := l_dyn_sql || ' INTERSECTIONS.*  ';
      l_dyn_sql := l_dyn_sql || ' FROM (  ';

      l_dyn_sql := l_dyn_sql || 'SELECT ';
      l_dyn_sql := l_dyn_sql ||  To_char(l_msii_set_process_id)||' , ';
      l_dyn_sql := l_dyn_sql || ' EBI.'||l_item_number_col ||' , ';
      l_dyn_sql := l_dyn_sql || ' EBI.INSTANCE_PK1_VALUE   , ';
      l_dyn_sql := l_dyn_sql || ' EBI.INSTANCE_PK2_VALUE   , ';
      --l_dyn_sql := l_dyn_sql || ' ''EGO_ITEM''             , ';
      l_dyn_sql := l_dyn_sql || l_data_level_id||'         , ';
      IF(l_supplier_site_prim_flag_col IS NOT NULL) THEN
--     bedajna bug 6429874
--     l_dyn_sql := l_dyn_sql || ' DECODE(EBI.'||l_supplier_site_prim_flag_col||', '''||l_yes_meaning||''', ''Y'', '''||l_no_meaning||''',''N'' ) PRIMARY_FLAG , ';
       l_dyn_sql := l_dyn_sql || ' DECODE(EBI.'||l_supplier_site_prim_flag_col||', '||':yes_meaning'||', ''Y'', '||':no_meaning'||',''N'' ) PRIMARY_FLAG , ';
      ELSE
        l_dyn_sql := l_dyn_sql || ' NULL PRIMARY_FLAG ,  ';
      END IF;
      IF(l_supplier_site_status_col IS NOT NULL) THEN
--     bedajna bug 6429874
--     l_dyn_sql := l_dyn_sql || 'DECODE(EBI.'||l_supplier_site_status_col||' , '''||l_active_meaning||''', ''1'', '''||l_inactive_meaning||''', ''2'', NULL) STATUS_CODE,';
       l_dyn_sql := l_dyn_sql || 'DECODE(EBI.'||l_supplier_site_status_col||' , '||':active_meaning1'||', ''1'', '||':inactive_meaning1'||', ''2'', NULL) STATUS_CODE,';
      ELSE
        l_dyn_sql := l_dyn_sql || ' NULL STATUS_CODE ,  ';
      END IF;
      IF(l_supplier_name_col IS NOT NULL)THEN
        l_dyn_sql := l_dyn_sql || 'EBI.'||l_supplier_name_col ||' SUPPLIER_NAME, ';
      ELSE
        l_dyn_sql := l_dyn_sql || ' NULL SUPPLIER_NAME,  ';
      END IF;
      IF(l_supplier_number_col IS NOT NULL)THEN
        l_dyn_sql := l_dyn_sql || 'EBI.'||l_supplier_number_col ||' SUPPLIER_NUMBER , ';
      ELSE
        l_dyn_sql := l_dyn_sql || ' NULL SUPPLIER_NUMBER ,  ';
      END IF;
      l_dyn_sql := l_dyn_sql || 'EBI.'||l_supplier_site_name_col ||' , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||l_org_code_col ||'       , ';
      l_dyn_sql := l_dyn_sql || '''SYNC''                        , ';
      l_dyn_sql := l_dyn_sql || G_PROCESS_STATUS||'              , ';
      --l_dyn_sql := l_dyn_sql || 'MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL, ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'CREATED_BY              , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'CREATION_DATE           , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'LAST_UPDATED_BY         , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'LAST_UPDATE_DATE        , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'LAST_UPDATE_LOGIN       , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'REQUEST_ID              , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'PROGRAM_APPLICATION_ID  , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'PROGRAM_ID              , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'PROGRAM_UPDATE_DATE     , ';
      l_dyn_sql := l_dyn_sql || ' NULL BUNDLE_ID                 , ';
      l_dyn_sql := l_dyn_sql || ' TO_NUMBER(EBI.C_FIX_COLUMN11)  , ';
      l_dyn_sql := l_dyn_sql || ' EBI.C_FIX_COLUMN12             , ';
      l_dyn_sql := l_dyn_sql || ' NULL ASSOCIATION_ID              ';
      l_dyn_sql := l_dyn_sql || 'FROM EGO_BULKLOAD_INTF EBI ';
      l_dyn_sql := l_dyn_sql || ' WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
      l_dyn_sql := l_dyn_sql || ' AND   EBI.PROCESS_STATUS = 1  ';
      IF(l_supplier_name_col IS NOT NULL AND l_supplier_number_col IS NOT NULL)THEN
        l_dyn_sql := l_dyn_sql || ' AND  ( EBI.'||l_supplier_name_col||' IS NOT NULL  ';
        l_dyn_sql := l_dyn_sql || '       OR EBI.'||l_supplier_number_col||' IS NOT NULL ) ';
      ELSIF(l_supplier_name_col IS NOT NULL AND l_supplier_number_col IS NULL) THEN
        l_dyn_sql := l_dyn_sql || ' AND   EBI.'||l_supplier_name_col||' IS NOT NULL  ';
      ELSIF(l_supplier_name_col IS NULL AND l_supplier_number_col IS NOT NULL) THEN
        l_dyn_sql := l_dyn_sql || ' AND   EBI.'||l_supplier_number_col||' IS NOT NULL  ';
      END IF;
      l_dyn_sql := l_dyn_sql || ' AND   EBI.'||l_supplier_site_name_col||' IS NOT NULL  ';
      l_dyn_sql := l_dyn_sql || ' UNION ';
      l_dyn_sql := l_dyn_sql || ' SELECT ';
      l_dyn_sql := l_dyn_sql ||  To_char(l_msii_set_process_id)||' , ';
      l_dyn_sql := l_dyn_sql || ' EBI.'||l_item_number_col ||' , ';
      l_dyn_sql := l_dyn_sql || ' EBI.INSTANCE_PK1_VALUE   , ';
      l_dyn_sql := l_dyn_sql || ' EBI.INSTANCE_PK2_VALUE   , ';
      --l_dyn_sql := l_dyn_sql || ' ''EGO_ITEM''             , ';
      l_dyn_sql := l_dyn_sql || l_data_level_id_1||'         , ';
      --IF(l_supplier_site_prim_flag_col IS NOT NULL) THEN
      --  l_dyn_sql := l_dyn_sql || 'EBI.'||l_supplier_site_prim_flag_col||' , ';
      --ELSE
        l_dyn_sql := l_dyn_sql || ' NULL PRIMARY_FLAG ,  ';
      --END IF;

      IF(l_sup_site_store_status_col IS NOT NULL) THEN
--     bedajna bug 6429874
--     l_dyn_sql := l_dyn_sql || 'DECODE(EBI.'||l_sup_site_store_status_col||' , '''||l_active_meaning||''', ''1'', '''||l_inactive_meaning||''', ''2'', NULL) STATUS_CODE,';
       l_dyn_sql := l_dyn_sql || 'DECODE(EBI.'||l_sup_site_store_status_col||' , '||':active_meaning2'||', ''1'', '||':inactive_meaning2'||', ''2'', NULL) STATUS_CODE,';
      ELSE
        l_dyn_sql := l_dyn_sql || ' NULL STATUS_CODE ,  ';
      END IF;
      IF(l_supplier_name_col IS NOT NULL)THEN
        l_dyn_sql := l_dyn_sql || 'EBI.'||l_supplier_name_col ||' SUPPLIER_NAME , ';
      ELSE
        l_dyn_sql := l_dyn_sql || ' NULL SUPPLIER_NAME,  ';
      END IF;
      IF(l_supplier_number_col IS NOT NULL)THEN
        l_dyn_sql := l_dyn_sql || 'EBI.'||l_supplier_number_col ||' SUPPLIER_NUMBER , ';
      ELSE
        l_dyn_sql := l_dyn_sql || ' NULL SUPPLIER_NUMBER ,  ';
      END IF;
      l_dyn_sql := l_dyn_sql || 'EBI.'||l_supplier_site_name_col ||' , ';

      l_dyn_sql := l_dyn_sql || 'EBI.'||l_org_code_col ||'       , ';
      l_dyn_sql := l_dyn_sql || '''SYNC''                        , ';
      l_dyn_sql := l_dyn_sql || G_PROCESS_STATUS||'              , ';
      --l_dyn_sql := l_dyn_sql || 'MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL, ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'CREATED_BY              , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'CREATION_DATE           , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'LAST_UPDATED_BY         , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'LAST_UPDATE_DATE        , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'LAST_UPDATE_LOGIN       , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'REQUEST_ID              , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'PROGRAM_APPLICATION_ID  , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'PROGRAM_ID              , ';
      l_dyn_sql := l_dyn_sql || 'EBI.'||'PROGRAM_UPDATE_DATE     , ';
      l_dyn_sql := l_dyn_sql || ' NULL  BUNDLE_ID                , ';
      l_dyn_sql := l_dyn_sql || ' TO_NUMBER(EBI.C_FIX_COLUMN11)  , ';
      l_dyn_sql := l_dyn_sql || ' EBI.C_FIX_COLUMN12             , ';
      l_dyn_sql := l_dyn_sql || ' NULL ASSOCIATION_ID              ';
      l_dyn_sql := l_dyn_sql || 'FROM EGO_BULKLOAD_INTF EBI ';
      l_dyn_sql := l_dyn_sql || ' WHERE  EBI.RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
      l_dyn_sql := l_dyn_sql || ' AND   EBI.PROCESS_STATUS = 1  ';
      l_dyn_sql := l_dyn_sql || ' AND   EBI.'||l_supplier_name_col||' IS NOT NULL  ';
      l_dyn_sql := l_dyn_sql || ' AND   ''Y'' =  '''||l_has_sup_sit_org_col||''' ';

      l_dyn_sql := l_dyn_sql || ' AND   EBI.'||l_supplier_site_name_col||' IS NOT NULL  ) INTERSECTIONS ';

      Write_Debug(l_dyn_sql);

--     bedajna bug 6429874
--     EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;
    IF ( (l_supplier_site_prim_flag_col IS NOT NULL) AND (l_supplier_site_status_col IS NOT NULL) AND (l_sup_site_store_status_col IS NOT NULL) ) then
     EXECUTE IMMEDIATE l_dyn_sql USING l_yes_meaning, l_no_meaning, l_active_meaning, l_inactive_meaning, p_resultfmt_usage_id, l_active_meaning, l_inactive_meaning, p_resultfmt_usage_id;
    ELSIF ( (l_supplier_site_prim_flag_col IS NOT NULL) AND (l_supplier_site_status_col IS NOT NULL) AND (l_sup_site_store_status_col IS NULL) ) then
     EXECUTE IMMEDIATE l_dyn_sql USING l_yes_meaning, l_no_meaning, l_active_meaning, l_inactive_meaning, p_resultfmt_usage_id, p_resultfmt_usage_id;
    ELSIF ( (l_supplier_site_prim_flag_col IS NOT NULL) AND (l_supplier_site_status_col IS NULL) AND (l_sup_site_store_status_col IS NOT NULL) ) then
     EXECUTE IMMEDIATE l_dyn_sql USING l_yes_meaning, l_no_meaning, p_resultfmt_usage_id, l_active_meaning, l_inactive_meaning, p_resultfmt_usage_id;
    ELSIF ( (l_supplier_site_prim_flag_col IS NULL) AND (l_supplier_site_status_col IS NOT NULL) AND (l_sup_site_store_status_col IS NOT NULL) ) then
     EXECUTE IMMEDIATE l_dyn_sql USING l_active_meaning, l_inactive_meaning, p_resultfmt_usage_id, l_active_meaning, l_inactive_meaning, p_resultfmt_usage_id;
    ELSIF ( (l_supplier_site_prim_flag_col IS NOT NULL) AND (l_supplier_site_status_col IS NULL) AND (l_sup_site_store_status_col IS NULL) ) then
     EXECUTE IMMEDIATE l_dyn_sql USING l_yes_meaning, l_no_meaning, p_resultfmt_usage_id, p_resultfmt_usage_id;
    ELSIF ( (l_supplier_site_prim_flag_col IS NULL) AND (l_supplier_site_status_col IS NOT NULL) AND (l_sup_site_store_status_col IS NULL) ) then
     EXECUTE IMMEDIATE l_dyn_sql USING l_active_meaning, l_inactive_meaning, p_resultfmt_usage_id, p_resultfmt_usage_id;
    ELSIF ( (l_supplier_site_prim_flag_col IS NULL) AND (l_supplier_site_status_col IS NULL) AND (l_sup_site_store_status_col IS NOT NULL) ) then
     EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, l_active_meaning, l_inactive_meaning, p_resultfmt_usage_id;
    ELSIF ( (l_supplier_site_prim_flag_col IS NULL) AND (l_supplier_site_status_col IS NULL) AND (l_sup_site_store_status_col IS NULL) ) then
     EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id, p_resultfmt_usage_id;
    end if;

      Write_Debug('Item Revs Interface: Populated the Inv Item IDs, Org IDs.');

   END IF;

   x_retcode := G_STATUS_SUCCESS;
   x_set_process_id := l_msii_set_process_id;

END load_intersections_interface;





END EGO_ITEM_BULKLOAD_PKG;

/
