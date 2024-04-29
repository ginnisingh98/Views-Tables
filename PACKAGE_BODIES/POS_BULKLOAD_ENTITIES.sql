--------------------------------------------------------
--  DDL for Package Body POS_BULKLOAD_ENTITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_BULKLOAD_ENTITIES" 
/* $Header: POSSBLKB.pls 120.0.12010000.10 2013/03/14 02:25:44 liawei noship $ */
AS
  ----------------------------------------------------------------------------
  -- Global constants
  ----------------------------------------------------------------------------
  G_PKG_NAME                          CONSTANT VARCHAR2(30) := 'EGO_USER_ATTRS_BULK_PVT';
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
  G_ENTITY_CODE                       VARCHAR2(30) := 'HZ_PARTIES';
--    G_PK_COLS_TABLE                     PK_COL_TABLE;
--  G_SITE_NUMBER_EBI_COL               VARCHAR2(50) := 'C_INTF_ATTR240';
  G_DATE_FORMAT                       CONSTANT VARCHAR2(30) := 'SYYYY-MM-DD HH24:MI:SS';

  G_APPLICATION_ID                    NUMBER(3) := 177;
  G_DATA_ROWS_UPLOADED_NEW            CONSTANT NUMBER := 0;
  G_PS_TO_BE_PROCESSED                CONSTANT NUMBER := 1;
  G_PS_IN_PROCESS                     CONSTANT NUMBER := 2;
  G_PS_GENERIC_ERROR                  CONSTANT NUMBER := 3;
  G_PS_SUCCESS                        CONSTANT NUMBER := 4;
  G_RETCODE_SUCCESS_WITH_WARNING      CONSTANT VARCHAR(1) := 'W';

   G_ERROR_TABLE_NAME      VARCHAR2(99) := 'EGO_BULKLOAD_INTF';
   G_ERROR_ENTITY_CODE     VARCHAR2(99) := 'HZ_PARTIES';
   G_ERROR_FILE_NAME       VARCHAR2(99);
   G_BO_IDENTIFIER         VARCHAR2(99) := 'HZ_PARTIES';
   G_DEBUG CONSTANT VARCHAR2(10) := NVL(FND_PROFILE.VALUE('POS_DEBUG_TRACE'),0);

   ---------------------------------------------------------------
   -- Java Conc Program can continue writing to the same Error Log File.
   -- using the below variable
   ---------------------------------------------------------------
   G_ERRFILE_PATH_AND_NAME VARCHAR2(10000);

   ---------------------------------------------------------------
   -- API Return statuses.                                      --
   ---------------------------------------------------------------
   G_STATUS_SUCCESS    CONSTANT VARCHAR2(1)    := 'S';
   G_STATUS_ERROR      CONSTANT VARCHAR2(1)    := 'E';


   ---------------------------------------------------------------
   -- UDA EGO WEBADI uptake
   -- The following data level constants to be inserted into INTF tables
   ---------------------------------------------------------------
   G_POS_SUPP_LEVEL_ID NUMBER(5) := 17701;
   G_POS_SUPP_ADDR_LEVEL_ID NUMBER(5) := 17702;
   G_POS_SUPP_ADDR_SITE_LEVEL_ID NUMBER(5) := 17703;


   G_POS_SUPP_LEVEL VARCHAR2(100) := 'SUPP_LEVEL';
   G_POS_SUPP_ADDR_LEVEL VARCHAR2(100) := 'SUPP_ADDR_LEVEL';
   G_POS_SUPP_ADDR_SITE_LEVEL VARCHAR2(100) := 'SUPP_ADDR_SITE_LEVEL';




PROCEDURE SETUP_BULKLOAD_INTF(ERRBUF  OUT NOCOPY VARCHAR2,
            		      RETCODE OUT NOCOPY VARCHAR2,
			      ERROR_FILE OUT NOCOPY VARCHAR2,
			      p_result_format_usage_id IN Number) Is
l_process_status char(100);
BEGIN
   DELETE FROM EGO_BULKLOAD_INTF
   WHERE RESULTFMT_USAGE_ID = p_result_format_usage_id
   AND PROCESS_STATUS <> G_DATA_ROWS_UPLOADED_NEW;
   Open_Debug_Session;
   ERROR_FILE := G_ERRFILE_PATH_AND_NAME;
   Write_Conclog('Cleanup and Debug Session Setup Activities Completed');
   RETCODE := 'S';
EXCEPTION
    WHEN OTHERS THEN
       ERRBUF  := SUBSTRB(SQLERRM, 1,240);
       RETCODE := 'E';
       Write_Conclog(' Error in SETUP_BULKLOAD_INTF Error API'||ERRBUF);
End SETUP_BULKLOAD_INTF;


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

-- Bug 16384042 Helper Function to resolve PK values for data level supplier site and party site
-- since ego_bulkload_intf already got AddressName and VendorSiteCode populated use them to find Ids
-- PKs in EBI table,  PK1 -- PartyID   PK2 -- IS_PROSPECT  PK3 -- PARTY_SITE_ID  PK4 -- VENDOR_SITE_ID

PROCEDURE RESOLVE_PK_VALUES(
          RETCODE                 OUT  NOCOPY   VARCHAR2,
          p_result_format_usage_id  IN      NUMBER
      ) Is
CURSOR c_ebi_col_mapping_addr(c_fmt_usage_id in number) is
SELECT INTF_COLUMN_NAME
FROM   ego_results_fmt_usages
WHERE  attribute_code = 'PS_PARTY_SITE_NAME'
AND    resultfmt_usage_id = c_fmt_usage_id
AND    CUSTOMIZATION_APPLICATION_ID = G_APPLICATION_ID
AND    rownum < 2;

CURSOR c_ebi_col_mapping_site(c_fmt_usage_id in number) is
SELECT INTF_COLUMN_NAME
FROM   ego_results_fmt_usages
WHERE  attribute_code = 'SS_VENDOR_SITE_CODE'
AND    resultfmt_usage_id = c_fmt_usage_id
AND    CUSTOMIZATION_APPLICATION_ID = G_APPLICATION_ID
AND    rownum < 2;

CURSOR c_resolve_PKs(c_fmt_usage_id in number) is
SELECT *
FROM   ego_bulkload_intf
WHERE  resultfmt_usage_id = c_fmt_usage_id;
--AND    process_status = G_PS_TO_BE_PROCESSED;

CURSOR c_party_site (c_party_id IN NUMBER, c_address_name iN VARCHAR) IS
SELECT PS.Party_Site_ID
FROM   AP_Suppliers AP,
       HZ_PARTY_SITES PS
WHERE  AP.Party_ID = PS.Party_ID
AND    AP.Party_ID = c_Party_ID
AND    PS.STATUS = 'A'
AND    PS.PARTY_SITE_NAME = c_address_name
AND    rownum < 2;

CURSOR c_supplier_site (c_party_id IN NUMBER, c_party_site_id IN NUMBER, c_vendor_site_code IN VARCHAR) IS
SELECT  SS.Vendor_Site_ID
FROM    AP_Suppliers AP,
        AP_SUPPLIER_SITES_ALL SS,
        HZ_PARTY_SITES PS
WHERE   AP.Party_ID = PS.Party_ID
AND     AP.Party_ID = c_Party_ID
AND     PS.STATUS = 'A'
AND     PS.Party_Site_ID = c_party_site_id
AND     PS.Party_Site_ID = SS.Party_Site_ID
AND     SS.VENDOR_SITE_CODE = c_vendor_site_code
AND     SS.INACTIVE_DATE IS NULL
AND     rownum < 2;

l_addr_col_name  VARCHAR2(20);
l_site_col_name  VARCHAR2(20);
--l_has_site_col   BOOLEAN;
l_address_name   VARCHAR2(150);
l_vendor_site_code VARCHAR2(150);
l_pk3_value      NUMBER;
l_pk4_value      NUMBER;
l_dyn_sql        VARCHAR2(100);

Current_Error_Code      VARCHAR2(20) := NULL;
conc_status             BOOLEAN      ;
BEGIN
   Write_Conclog('Executing RESOLVE_PK_VALUES API ');
   --first get mapped column names from ego_result_fmt_usages
   OPEN c_ebi_col_mapping_addr(p_result_format_usage_id);
   FETCH c_ebi_col_mapping_addr INTO l_addr_col_name;
    IF c_ebi_col_mapping_addr%NOTFOUND OR l_addr_col_name = NULL THEN -- no need to do anything in this case
       CLOSE c_ebi_col_mapping_addr;
       RETURN;
    END IF;
   CLOSE c_ebi_col_mapping_addr;
   Write_Conclog('Executing RESOLVE_PK_VALUES -- get Address Column mapping colname =  '||l_addr_col_name );

   OPEN  c_ebi_col_mapping_site(p_result_format_usage_id);
   FETCH c_ebi_col_mapping_site INTO l_site_col_name;
     IF c_ebi_col_mapping_site %NOTFOUND THEN
       l_site_col_name := NULL;
     END IF;
   CLOSE c_ebi_col_mapping_site;
  Write_Conclog('Executing RESOLVE_PK_VALUES -- get Site Column mapping colname =  '||l_site_col_name );

   Write_Conclog('Executing RESOLVE_PK_VALUES -- before cursor c_ebi_rec');
   FOR c_ebi_rec IN c_resolve_PKs(p_result_format_usage_id)
   LOOP
      l_dyn_sql := 'SELECT '||l_addr_col_name
                  ||' FROM ego_bulkload_intf '
                  ||' WHERE resultfmt_usage_id = :1 '
                  ||' AND transaction_id = :2 ';
      execute immediate l_dyn_sql into l_address_name using c_ebi_rec.resultfmt_usage_id, c_ebi_rec.transaction_id;
         Write_Conclog('Executing RESOLVE_PK_VALUES --after 1st dyn sql l_address_name = '|| l_address_name);

      IF (l_site_col_name IS NOT NULL) THEN
            l_dyn_sql := 'SELECT '||l_site_col_name
                  ||' FROM ego_bulkload_intf '
                  ||' WHERE resultfmt_usage_id = :1 '
                  ||' AND transaction_id = :2 ';
            execute immediate l_dyn_sql into l_vendor_site_code using c_ebi_rec.resultfmt_usage_id, c_ebi_rec.transaction_id;
         Write_Conclog('Executing RESOLVE_PK_VALUES --after 2nd dyn sql l_vendor_site_code = '|| l_vendor_site_code);
      END IF;
   --setting PK3
   IF l_address_name IS NOT NULL THEN
      --getting PK3 value
      OPEN c_party_site( c_ebi_rec.INSTANCE_PK1_VALUE, l_address_name);
      FETCH c_party_site INTO l_pk3_value;
      CLOSE c_party_site;
      Write_Conclog('Executing RESOLVE_PK_VALUES 1st -- l_pk3_value = '||l_pk3_value);
   END IF;
   --setting PK4
   IF  l_vendor_site_code IS NOT NULL AND NVL(l_pk3_value, 0) <> 0 THEN
      OPEN c_supplier_site( c_ebi_rec.INSTANCE_PK1_VALUE, l_pk3_value, l_vendor_site_code);
      FETCH c_supplier_site INTO l_pk4_value;
      CLOSE c_supplier_site;
      Write_Conclog('Executing RESOLVE_PK_VALUES 2nd -- l_pk4_value = '||l_pk4_value);
   END IF;
     Write_Conclog('Executing RESOLVE_PK_VALUES --Before final update');
   --finally set PKs to EBI
     UPDATE EGO_BULKLOAD_INTF
     SET    INSTANCE_PK3_VALUE = l_pk3_value,
            INSTANCE_PK4_VALUE = l_pk4_value
     WHERE  resultfmt_usage_id = c_ebi_rec.resultfmt_usage_id
     AND    transaction_id     =  c_ebi_rec.transaction_id;

   END LOOP; --  FOR c_ebi_rec IN c_resolve_PKs(c_fmt_usage_id)
   Write_Conclog('Executing RESOLVE_PK_VALUES -- All done successfully');
 EXCEPTION
    WHEN OTHERS THEN
       Write_Conclog('Error while calling Resolve_PK_values API  '||SQLCODE || ':'||SQLERRM);
       RETCODE := 'E';
       Current_Error_Code := To_Char(SQLCODE);
       conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', Current_Error_Code);
END RESOLVE_PK_VALUES;

/*
PROCEDURE RESOLVE_PK_VALUES(
          p_Party_ID         IN          NUMBER,
          p_Data_Level_ID    IN          NUMBER,
          p_Attr_Group_ID    IN          NUMBER,
          x_PK1_Value        OUT NOCOPY  NUMBER,
          x_PK2_Value        OUT NOCOPY  NUMBER
      ) Is
--Only existing UDAs have rows in extb
CURSOR c_existing_rows_in_extb(c_party_id IN NUMBER, c_data_level_id IN NUMBER, c_attr_group_id IN NUMBER)  IS
SELECT PK1_Value, PK2_Value
FROM   pos_supp_prof_ext_b
WHERE  party_id = c_party_id
AND    data_level_id = c_data_level_id
AND    attr_group_id = c_attr_group_id
AND    rownum < 2;

CURSOR c_party_site (c_party_id IN NUMBER) IS
SELECT PS.Party_Site_ID
FROM   AP_Suppliers AP,
       HZ_PARTY_SITES PS
WHERE  AP.Party_ID = PS.Party_ID
AND    AP.Party_ID = p_Party_ID
AND    PS.STATUS = 'A'
AND    rownum < 2;

CURSOR c_supplier_site (c_party_id IN NUMBER) IS
SELECT  SS.Party_Site_ID,
        SS.Vendor_Site_ID
FROM    AP_Suppliers AP,
        AP_SUPPLIER_SITES_ALL SS,
        HZ_PARTY_SITES PS
WHERE   AP.Party_ID = PS.Party_ID
AND     AP.Party_ID = p_Party_ID
AND     PS.STATUS = 'A'
AND     PS.Party_Site_ID = SS.Party_Site_ID
AND     SS.INACTIVE_DATE IS NULL
AND     rownum < 2;

BEGIN
  Write_Conclog('Entering RESOLVE_PK_VALUES  p_Party_ID = '||p_Party_ID);
  Write_Conclog('                            p_Data_Level_ID = '||p_Data_Level_ID);
  Write_Conclog('                            p_Attr_Group_ID = '||p_Attr_Group_ID);

  --shouldn't call this API when data level is Supplier Party still check in case
  IF p_Data_Level_ID = G_POS_SUPP_LEVEL_ID THEN
     Return;

  ELSIF p_Data_Level_ID = G_POS_SUPP_ADDR_LEVEL_ID THEN
     OPEN c_existing_rows_in_extb(p_Party_ID, p_Data_Level_ID, p_Attr_Group_ID);
     FETCH  c_existing_rows_in_extb INTO x_PK1_Value, x_PK2_Value;

     IF c_existing_rows_in_extb%NOTFOUND THEN
     Write_Conclog('Cannot find rows in extb table use HZ_Party to resolve');
     OPEN c_party_site(p_Party_ID);
     FETCH c_party_site INTO  x_PK1_Value;
     CLOSE c_party_site;
     END IF;
     ClOSE c_existing_rows_in_extb;

  ELSIF p_Data_Level_ID = G_POS_SUPP_ADDR_SITE_LEVEL_ID THEN
     OPEN c_existing_rows_in_extb(p_Party_ID, p_Data_Level_ID, p_Attr_Group_ID);
     FETCH  c_existing_rows_in_extb INTO x_PK1_Value, x_PK2_Value;

     IF c_existing_rows_in_extb%NOTFOUND THEN
     Write_Conclog('Cannot find rows in extb table use HZ_Party to resolve');
     OPEN c_supplier_site(p_Party_ID);
     FETCH c_supplier_site INTO  x_PK1_Value, x_PK2_Value;
     CLOSE c_supplier_site;
     END IF;
     ClOSE c_existing_rows_in_extb;

  END IF;
END RESOLVE_PK_VALUES;
*/
---------------------------------------------------------------------------------
--LOAD SUPPLIER USER DEFINED ATTRIBUTES
--------------------------------------------------------------------------------
PROCEDURE LOAD_USERATTR_INTF(
	   	  		 p_resultfmt_usage_id    IN         NUMBER,
                 p_data_set_id           IN         NUMBER,
                 x_errbuff               OUT NOCOPY VARCHAR2,
                 x_retcode               OUT NOCOPY VARCHAR2,
                 p_entity_name           IN       VARCHAR2,
                 p_batch_id              IN       NUMBER
                ) Is
    --Bug 16384042 modified cursor to include data_level_id column
    CURSOR c_user_attr_group_codes (c_resultfmt_usage_id  IN  NUMBER,c_attr_group_type IN VARCHAR2) IS
    SELECT DISTINCT To_Number(SUBSTR(attribute_code, 1, INSTR(attribute_code, '$$') - 1)) attr_group_id,classification_code, data_level_id
    FROM   ego_results_fmt_usages
    WHERE  resultfmt_usage_id = c_resultfmt_usage_id
     AND   attribute_code LIKE '%$$%'
     AND   To_Number(SUBSTR(attribute_code, 1, INSTR(attribute_code, '$$') - 1)) IN
      (
        SELECT attr_group_id
        FROM   ego_attr_groups_v
        WHERE  attr_group_type = c_attr_group_type
        AND    application_id = G_APPLICATION_ID
      );

     CURSOR c_attr_grp_n_attr_int_names(p_attr_id  IN NUMBER,c_attr_group_type IN VARCHAR2) IS
     SELECT  attr_group_name, attr_name
     FROM    ego_attrs_v
     WHERE   attr_id = p_attr_id
      AND    attr_group_type = c_attr_group_type
      AND    application_id = G_APPLICATION_ID;
	    TYPE L_USER_ATTR_REC_TYPE IS RECORD
		(
      DATA_SET_ID                          NUMBER(15),
      TRANSACTION_ID                       NUMBER(15),
      PK1_ID                    		        VARCHAR2(256),
      PK2_ID                    		       VARCHAR2(256),
      PK3_ID                    		       VARCHAR2(256),
      PK4_ID                    		       VARCHAR2(256),
      PK5_ID                    		       VARCHAR2(256),
      CLASSIFICATION_CODE                  VARCHAR2(30),
      ROW_IDENTIFIER                       NUMBER(15),
      ATTR_GROUP_NAME                      VARCHAR2(30),
      ATTR_NAME                            VARCHAR2(30),
      ATTR_DATATYPE_CODE                   VARCHAR2(1), --Valid Vals: C / N / D
      ATTR_VALUE_STR                       VARCHAR2(10000),
      ATTR_VALUE_NUM                       NUMBER,
      ATTR_VALUE_DATE                      DATE,
      INTF_COLUMN_NAME                     VARCHAR2(30),
	  ATTR_GROUP_ID                        NUMBER(15),
    BATCH_ID                             NUMBER(15)
	  );
  TYPE L_USER_ATTR_TBL_TYPE IS TABLE OF L_USER_ATTR_REC_TYPE
  INDEX BY BINARY_INTEGER;
  TYPE VARCHAR_TBL_TYPE IS TABLE OF VARCHAR2(256)
  INDEX BY BINARY_INTEGER;
  l_prod_col_name_tbl               VARCHAR_TBL_TYPE;
  l_intf_col_name_tbl               VARCHAR_TBL_TYPE;
  l_attr_id_table                   DBMS_SQL.NUMBER_TABLE;
  l_intf_col_name_table             DBMS_SQL.VARCHAR2_TABLE;
  l_usr_attr_data_tbl               L_USER_ATTR_TBL_TYPE;
  l_pk_id_char                    VARCHAR(15);
  l_pk1_id_char                    VARCHAR(15);
  l_pk2_id_char                    VARCHAR(15);
  l_pk3_id_char                    VARCHAR(15);
  l_pk4_id_char                    VARCHAR(15);
  l_pk5_id_char                    VARCHAR(15);

  l_site_num_char                   VARCHAR(1000);
  l_trade_area_num_char             VARCHAR(10);
  l_count                           NUMBER(5);
  l_data_type_code                  VARCHAR2(2);
  l_transaction_id                  NUMBER(15);
  l_attr_group_int_name    EGO_ATTRS_V.ATTR_GROUP_NAME%TYPE;
  l_attr_int_name          EGO_ATTRS_V.ATTR_NAME%TYPE;

  l_attr_group_id NUMBER(15);
  l_party_id       NUMBER(15);
  l_attr_group_id_table DBMS_SQL.NUMBER_TABLE;
  ---------------------------------------------------------
  -- Example Data Types to be used in Bind Variable.
  ---------------------------------------------------------
  l_varchar_example        VARCHAR2(10000);
  l_number_example         NUMBER;
  l_date_example           DATE;
  --------------------------------------------------------------------
  -- Actual Data to store corresponding data type value.
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
  L_ATTR_GRP_ROW_IDENT     NUMBER(5) ;
  ---------------------------------------------------------
  -- Token tables to log errors, through Error_Handler
  ---------------------------------------------------------
  l_token_tbl_two         Error_Handler.Token_Tbl_Type;
  l_token_tbl_one         Error_Handler.Token_Tbl_Type;
  l_attr_group_type        VARCHAR2(30);

  l_userattr_indx_adj      NUMBER(15);  -- To adjust the index according to Data_levels
BEGIN
    Write_Conclog('Loading the User Defined Attributes for Entity '||p_entity_name);

	 IF (G_HZ_PARTY_ID IS NULL) THEN
      IF (G_USER_NAME IS NOT NULL) THEN
      SELECT 'HZ_PARTY:'||TO_CHAR(PERSON_ID)
        INTO G_HZ_PARTY_ID
        FROM EGO_PEOPLE_V
       WHERE USER_NAME = G_USER_NAME;
      ELSE
        RAISE G_NO_USER_NAME_TO_VALIDATE;
      END IF;
   END IF;


        l_attr_group_type := 'POS_SUPP_PROFMGMT_GROUP';
        --Bug 16384042 added data_level_id for outerloop cursor
	 FOR c_attr_grp_rec IN c_user_attr_group_codes
     (
        p_resultfmt_usage_id,l_attr_group_type
      )
   LOOP
	    l_dyn_sql := '';
	    l_dyn_sql := ' SELECT To_Number(SUBSTR(attribute_code, INSTR(attribute_code, ''$$'')+2)) attr_id, intf_column_name, To_Number(SUBSTR(attribute_code, 1, INSTR(attribute_code, ''$$'') - 1)) attr_group_id ';
	    l_dyn_sql := l_dyn_sql || ' FROM   ego_results_fmt_usages ';
	    l_dyn_sql := l_dyn_sql || ' WHERE  resultfmt_usage_id = :RESULTFMT_USAGE_ID';
	    l_dyn_sql := l_dyn_sql || '  AND attribute_code LIKE :ATTRIBUTE_CODE ';
	    l_cursor_select := DBMS_SQL.OPEN_CURSOR;
	    DBMS_SQL.PARSE(l_cursor_select, l_dyn_sql, DBMS_SQL.NATIVE);
	    DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 1,l_attr_id_table,2500, l_temp);
	    DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 2,l_intf_col_name_table,2500, l_temp);
            DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 3,l_attr_group_id_table,2500, l_temp);


	    DBMS_SQL.BIND_VARIABLE(l_cursor_select,':RESULTFMT_USAGE_ID', p_resultfmt_usage_id);
	    DBMS_SQL.BIND_VARIABLE(l_cursor_select,':ATTRIBUTE_CODE', c_attr_grp_rec.attr_group_id||'$$%');
            l_cursor_execute := DBMS_SQL.EXECUTE(l_cursor_select);

            l_count := DBMS_SQL.FETCH_ROWS(l_cursor_select);
	    DBMS_SQL.COLUMN_VALUE(l_cursor_select, 1, l_attr_id_table);
            DBMS_SQL.COLUMN_VALUE(l_cursor_select, 2, l_intf_col_name_table);
            DBMS_SQL.COLUMN_VALUE(l_cursor_select, 3, l_attr_group_id_table);



		DBMS_SQL.CLOSE_CURSOR(l_cursor_select);
		--------------------------------------------------------------------
    -- New DBMS_SQL Cursor for Select Attr Values.
    --------------------------------------------------------------------
    l_cursor_attr_id_val := DBMS_SQL.OPEN_CURSOR;
    l_dyn_attr_id_val_sql := '';
    l_dyn_attr_id_val_sql := ' SELECT ';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' TRANSACTION_ID , ';
     --Bug 16384042 since always pass SUPP_ADDR_SITE as p_entity_name parameter, always get the most number of PKs whether used or not determined by datalevel
      IF p_entity_name = 'SUPP' THEN
          l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' INSTANCE_PK1_VALUE, INSTANCE_PK2_VALUE,  ';
      ELSIF p_entity_name = 'SUPP_ADDR' THEN
          l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' INSTANCE_PK1_VALUE, INSTANCE_PK2_VALUE , INSTANCE_PK3_VALUE ,  ';
      ELSIF p_entity_name = 'SUPP_ADDR_SITE' THEN
          l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' INSTANCE_PK1_VALUE, INSTANCE_PK2_VALUE, INSTANCE_PK3_VALUE, INSTANCE_PK4_VALUE , ';
      END IF;
    --------------------------------------------------------------------
    -- To fetch these cols also, as in case of New Item
    -- Instance PK1 Value might not have been retrieved.
    --------------------------------------------------------------------

     Write_Conclog('*l_attr_id_table.COUNT*'||l_attr_id_table.COUNT);
    FOR i IN 1..l_attr_id_table.COUNT LOOP
      IF (i <> l_attr_id_table.COUNT) THEN
        l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || l_intf_col_name_table(i) || ', ';
      ELSE
        l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || l_intf_col_name_table(i) ;
      END IF;
    END LOOP; --end: FOR i IN 1..l_attr_id_table.COUNT LOOP
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' FROM EGO_BULKLOAD_INTF ' ;
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' WHERE RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' AND PROCESS_STATUS = :PROCESS_STATUS ';
    DBMS_SQL.PARSE(l_cursor_attr_id_val, l_dyn_attr_id_val_sql, DBMS_SQL.NATIVE);
    --------------------------------------------------------------------
    --Setting Data Type for Trasaction ID
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 1, l_number_example);
    --------------------------------------------------------------------
      --Setting Data Type for INSTANCE_PKx_VALUE
      -- Also since TRANSACTION_ID, INSTANCE_PK1_VALUE, INSTANCE_PK2_VALUE,
      -- INSTANCE_PK3_VALUE,INSTANCE_PK4_VALUE are added to the SELECT before the User-Defined
      -- Attrs, we need to adjust the index as follows.
      ------------------------------------------------------------------------

     IF p_entity_name = 'SUPP' THEN
          DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 2, l_varchar_example, 1000);
          DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 3, l_varchar_example, 1000);
          l_userattr_indx_adj := 3;
      ELSIF p_entity_name = 'SUPP_ADDR' THEN
          DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 2, l_varchar_example, 1000);
          DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 3, l_varchar_example, 1000);
          DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 4, l_varchar_example, 1000);
           l_userattr_indx_adj := 4;
      ELSIF p_entity_name = 'SUPP_ADDR_SITE' THEN
          DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 2, l_varchar_example, 1000);
          DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 3, l_varchar_example, 1000);
          DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 4, l_varchar_example, 1000);
          DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 5, l_varchar_example, 1000);
          l_userattr_indx_adj := 5;
      END IF;    -- p_entity_name


    --------------------------------------------------------------------
    Write_Conclog('Executing the l_attr_id table looping');
    --------------------------------------------------------------------
    -- Loop to Bind the Data Types for the SELECT Columns.
    --------------------------------------------------------------------
    FOR i IN 1..l_attr_id_table.COUNT LOOP

      l_actual_userattr_indx := i + l_userattr_indx_adj;

      l_data_type_code := SUBSTR (l_intf_col_name_table(i), 1, 1);
      ------------------------------------------------------------------------
      -- Based on the Data Type of the attribute, define the column
      ------------------------------------------------------------------------
      IF (l_data_type_code = 'C') THEN
        DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, l_actual_userattr_indx, l_varchar_example, 1000);
      ELSIF (l_data_type_code = 'N') THEN
        DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, l_actual_userattr_indx, l_number_example);
      ELSE --IF (l_data_type_code = 'D') THEN
        DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, l_actual_userattr_indx, l_date_example);
      END IF; --IF (l_data_type_code = 'C') THEN
    END LOOP; --FOR i IN 1..l_attr_id_table.COUNT LOOP
    DBMS_SQL.BIND_VARIABLE(l_cursor_attr_id_val,':RESULTFMT_USAGE_ID',p_resultfmt_usage_id);
    DBMS_SQL.BIND_VARIABLE(l_cursor_attr_id_val,':PROCESS_STATUS',G_PS_IN_PROCESS); -- 2

    ------------------------------------------------------------------------
    --  Execute to get the Item User-Defined Attr values.
    ------------------------------------------------------------------------
    l_cursor_execute := DBMS_SQL.EXECUTE(l_cursor_attr_id_val);
    l_rows_per_attr_grp_indx := 0;
    L_ATTR_GRP_ROW_IDENT := 0;
    ------------------------------------------------------------------------
    --  Loop for each row found in EBI
    ------------------------------------------------------------------------
    Write_Conclog('Executing LOOP FOR CURSOR_ATTR_ID_VAL ');
    LOOP --LOOP FOR CURSOR_ATTR_ID_VAL
      IF DBMS_SQL.FETCH_ROWS(l_cursor_attr_id_val)>0 THEN
        ------------------------------------------------------------------------
        --Increment Row Identifier per (Attribute Group + Row) Combination.
        ------------------------------------------------------------------------
        L_ATTR_GRP_ROW_IDENT  := L_ATTR_GRP_ROW_IDENT + 1;
        ------------------------------------------------------------------------
        -- First column is Transaction ID.
        ------------------------------------------------------------------------

      IF p_entity_name = 'SUPP' THEN
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 1, l_transaction_id);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 2, l_pk1_id_char);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 3, l_pk2_id_char);


      ELSIF p_entity_name = 'SUPP_ADDR' THEN
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 1, l_transaction_id);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 2, l_pk1_id_char);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 3, l_pk2_id_char);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 4, l_pk3_id_char);
     ELSIF p_entity_name = 'SUPP_ADDR_SITE' THEN
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 1, l_transaction_id);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 2, l_pk1_id_char);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 3, l_pk2_id_char);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 4, l_pk3_id_char);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 5, l_pk4_id_char);

      END IF;  -- p_entity_name


	   FOR i IN 1..l_attr_id_table.COUNT LOOP
         OPEN c_attr_grp_n_attr_int_names(l_attr_id_table(i),l_attr_group_type);
         FETCH c_attr_grp_n_attr_int_names INTO
           l_attr_group_int_name, l_attr_int_name;
		Write_Conclog('Attribute group Internal Name '||l_attr_group_int_name);
	        Write_Conclog('Attribute Internal Name '||l_attr_int_name);
         l_attr_grp_has_data := FALSE;
         ------------------------------------------------------------------------
         -- If one more Attribute found for the Attribute Group.
         ------------------------------------------------------------------------
         IF c_attr_grp_n_attr_int_names%FOUND THEN
           l_rows_per_attr_grp_indx := l_rows_per_attr_grp_indx + 1;
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).DATA_SET_ID := p_data_set_id;
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).BATCH_ID := p_batch_id;
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).TRANSACTION_ID := l_transaction_id;
            Write_Conclog('after TRANSACTION_ID ');
           --Bug 16384042 here we use actual data_level from outer cursor
            IF c_attr_grp_rec.data_level_id = G_POS_SUPP_LEVEL_ID THEN
            --IF p_entity_name = 'SUPP' THEN
             if (l_pk1_id_char is NULL) THEN

                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK1_ID := null;
                 Write_Conclog('after PK1_ID null');
             else
                Write_Conclog('Before PK1_ID, PK1 = '||l_pk1_id_char);
                --FND_NUMBER.CANONICAL_TO_NUMBER
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK1_ID := l_pk1_id_char;
                Write_Conclog('after PK1_ID');
             end if;
             if (l_pk2_id_char is NULL) THEN
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK2_ID := null;
                  Write_Conclog('after PK2_ID null');
             else
               Write_Conclog('Before PK2_ID, PK2 = '||l_pk2_id_char);
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK2_ID := l_pk2_id_char;
              Write_Conclog('after PK2_ID');
             end if;
            ELSIF c_attr_grp_rec.data_level_id = G_POS_SUPP_ADDR_LEVEL_ID THEN
            --ELSIF p_entity_name = 'SUPP_ADDR' THEN

         if (l_pk1_id_char is NULL) THEN
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK1_ID := null;
             else
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK1_ID := l_pk1_id_char;
             end if;
             if (l_pk2_id_char is NULL) THEN
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK2_ID := null;
             else
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK2_ID := l_pk2_id_char;
             end if;
              if (l_pk3_id_char is NULL) THEN
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK3_ID := null;
             else
             Write_Conclog('Before PK3_ID, PK3 = '||l_pk3_id_char);
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK3_ID := l_pk3_id_char;
              Write_Conclog('after PK3_ID');
             end if;
            ELSIF c_attr_grp_rec.data_level_id = G_POS_SUPP_ADDR_SITE_LEVEL_ID THEN
            --ELSIF p_entity_name = 'SUPP_ADDR_SITE' THEN
              if (l_pk1_id_char is NULL) THEN
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK1_ID := null;
             else
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK1_ID := l_pk1_id_char;
             end if;
             if (l_pk2_id_char is NULL) THEN
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK2_ID := null;
             else
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK2_ID := l_pk2_id_char;
             end if;
              if (l_pk3_id_char is NULL) THEN
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK3_ID := null;
             else
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK3_ID := l_pk3_id_char;
             end if;
              if (l_pk4_id_char is NULL) THEN
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK4_ID := null;
             else
                 Write_Conclog('Before PK4_ID, PK4 = '||l_pk4_id_char);
                l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PK4_ID := l_pk4_id_char;
                 Write_Conclog('After PK4_ID ');
             end if;
            END IF;
             Write_Conclog('before CLASSIFICATION_CODE ');
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).CLASSIFICATION_CODE := c_attr_grp_rec.classification_code;
            Write_Conclog('before ROW_IDENTIFIER ');
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ROW_IDENTIFIER := L_ATTR_GRP_ROW_IDENT;

           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DATATYPE_CODE := SUBSTR (l_intf_col_name_table(i), 1, 1);
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_GROUP_NAME := l_attr_group_int_name;
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_NAME := l_attr_int_name;
           Write_Conclog('before attr_group_id ');
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_GROUP_ID := l_attr_group_id_table(i);

           l_actual_userattr_indx := i + l_userattr_indx_adj;
           ------------------------------------------------------------------------
            -- Depending upon the Data Type, populate corresponding field in the
            -- User-Defined Attribute Data record.
            ------------------------------------------------------------------------
           IF (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DATATYPE_CODE = 'C') THEN
              DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, l_actual_userattr_indx, l_varchar_data);
              l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_STR := l_varchar_data;
           ELSIF (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DATATYPE_CODE = 'N') THEN
              DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, l_actual_userattr_indx, l_number_data);
              l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_NUM := l_number_data;
           ELSE --IF (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DATATYPE_CODE = 'D') THEN
              DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, l_actual_userattr_indx, l_date_data);
              l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_DATE := l_date_data;
           END IF; --end: IF (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DATATYPE_CODE = 'C') THEN
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).INTF_COLUMN_NAME := l_intf_col_name_table(i);
           ------------------------------------------------------------------------
           -- Donot populate NULL Attribute value in the User-Defined Attrs
           -- Interface table.
           ------------------------------------------------------------------------
           IF ((l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_STR IS NULL) AND
               (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_NUM IS NULL) AND
               (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_DATE IS NULL)
               ) THEN
              ------------------------------------------------------------------------
              -- If all attribute values are NULL value, then delete
              -- the row from PLSQL table.
              ------------------------------------------------------------------------
	       Write_Conclog('All the Attribute values are Null');
              l_usr_attr_data_tbl.DELETE(l_rows_per_attr_grp_indx);
              l_rows_per_attr_grp_indx := l_rows_per_attr_grp_indx - 1;
           END IF; --end: IF ((l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_STR...
         END IF; --end: IF c_attr_grp_n_attr_int_names%FOUND THEN
         CLOSE c_attr_grp_n_attr_int_names;
       END LOOP; --end: FOR i IN 1..l_attr_id_table.COUNT LOOP
    ELSE --end: IF DBMS_SQL.FETCH_ROWS(l_cursor_attr_id_val)>0 THEN
        Write_Conclog('No Rows Found (or) All rows are Done.');
        EXIT;
   END IF; --IF DBMS_SQL.FETCH_ROWS(l_cursor_attr_id_val)>0 THEN
  END LOOP; --END: LOOP FOR CURSOR_ATTR_ID_VAL
      l_attr_id_table.DELETE;
      l_intf_col_name_table.DELETE;
    ------------------------------------------------------------------------
      DBMS_SQL.CLOSE_CURSOR(l_cursor_attr_id_val);
	     -------------------------------------------------------------------
      -- Loop for all the rows to be inserted per Attribute Group.
      -------------------------------------------------------------------
      FOR i IN 1..l_rows_per_attr_grp_indx LOOP
        -------------------------------------------------------------------------
        -- Fix for Bug# 3808455. To avoid the following error:
        -- ORA-01401: inserted value too large for column
        -- [This is done because ATTR_DISP_VALUE size is 1000 Chars]
        -------------------------------------------------------------------------
        IF ( LENGTH(l_usr_attr_data_tbl(i).ATTR_VALUE_STR) > 1000 ) THEN
          l_token_tbl_one(1).token_name  := 'VALUE';
          l_token_tbl_one(1).token_value := l_usr_attr_data_tbl(i).ATTR_VALUE_STR;
           Write_Conclog('Inserted Attribute value too large....');
        ELSE
           l_varchar_data      := NULL;
          IF (l_usr_attr_data_tbl(i).ATTR_DATATYPE_CODE = 'C') THEN
             l_varchar_data := l_usr_attr_data_tbl(i).ATTR_VALUE_STR;
          ELSIF (l_usr_attr_data_tbl(i).ATTR_DATATYPE_CODE = 'N') THEN
             IF (l_usr_attr_data_tbl(i).ATTR_VALUE_NUM IS NOT NULL) THEN
               l_varchar_data := To_char(l_usr_attr_data_tbl(i).ATTR_VALUE_NUM);
             END IF;
          ELSE
            IF (l_usr_attr_data_tbl(i).ATTR_VALUE_DATE IS NOT NULL) THEN
              l_varchar_data := To_Char(l_usr_attr_data_tbl(i).ATTR_VALUE_DATE , G_DATE_FORMAT);
            END IF;
          END IF; --end: IF (l_usr_attr_data_tbl(i).ATTR_DATATYPE_CODE = 'C') THEN
    	  	Write_Conclog('DATA SET ID ' || l_usr_attr_data_tbl(i).DATA_SET_ID);
          Write_Conclog('BATCH ID ' || l_usr_attr_data_tbl(i).BATCH_ID);
		Write_Conclog('TRANSACTION_ID ' || l_usr_attr_data_tbl(i).TRANSACTION_ID);
		Write_Conclog('PK1_ID ' || l_usr_attr_data_tbl(i).PK1_ID);
                Write_Conclog('PK2_ID ' || l_usr_attr_data_tbl(i).PK2_ID);
                Write_Conclog('PK3_ID ' || l_usr_attr_data_tbl(i).PK3_ID);
                Write_Conclog('PK4_ID ' || l_usr_attr_data_tbl(i).PK4_ID);
                Write_Conclog('PK5_ID ' || l_usr_attr_data_tbl(i).PK5_ID);

		Write_Conclog('ROW_IDENT ' || l_usr_attr_data_tbl(i).ROW_IDENTIFIER);
		Write_Conclog('CLASS ' || l_usr_attr_data_tbl(i).CLASSIFICATION_CODE);
		Write_Conclog('ATTR_GROUP_INT_NAME ' || l_usr_attr_data_tbl(i).ATTR_GROUP_NAME);
		Write_Conclog('ATTR_INT_NAME ' || l_usr_attr_data_tbl(i).ATTR_NAME);
		Write_Conclog('ATTR_DISP_VALUE ' || l_varchar_data);

		 ---------------------------------------------------------------
		 -- UDA EGO WEBADI
		 ----------------------------------------------------------------
        --Bug 16384042 Here also need to use DataLevel from outer cursor
        -- Here we call Resolve_PK_VALUES to get PK for party site and Supplier Site level
        IF c_attr_grp_rec.data_level_id = G_POS_SUPP_LEVEL_ID THEN
        --IF p_entity_name  = 'SUPP' THEN
                INSERT INTO POS_SUPP_PROF_EXT_INTF
                 (
                  DATA_SET_ID         ,
                  TRANSACTION_ID      ,
                  PARTY_ID    	      ,
                  --PK1_VALUE           ,
                  ROW_IDENTIFIER      ,
                  PROCESS_STATUS      ,
                  CLASSIFICATION_CODE ,
                  ATTR_GROUP_INT_NAME ,
                  ATTR_INT_NAME       ,
                  ATTR_DISP_VALUE     ,
                  DATA_LEVEL_ID       ,
		              DATA_LEVEL_NAME,
                  BATCH_ID
                  )
                  VALUES
                 (
                 l_usr_attr_data_tbl(i).DATA_SET_ID,
                 l_usr_attr_data_tbl(i).TRANSACTION_ID,
                 to_number(l_usr_attr_data_tbl(i).PK1_ID),
                 --l_usr_attr_data_tbl(i).PK2_ID,
                 l_usr_attr_data_tbl(i).ROW_IDENTIFIER,
                 G_PS_TO_BE_PROCESSED,
                 l_usr_attr_data_tbl(i).CLASSIFICATION_CODE,
                 l_usr_attr_data_tbl(i).ATTR_GROUP_NAME,
                 l_usr_attr_data_tbl(i).ATTR_NAME,
                 l_varchar_data,
                 G_POS_SUPP_LEVEL_ID,
                 G_POS_SUPP_LEVEL,
                  l_usr_attr_data_tbl(i).BATCH_ID
                 );

		        Write_conclog('ATTR_ID: '||l_usr_attr_data_tbl(i).ATTR_GROUP_ID);
                        Write_conclog('PARTY_ID: '||l_usr_attr_data_tbl(i).PK1_ID);
                       -- Write_conclog('PK1_VALUE: '||l_usr_attr_data_tbl(i).PK2_ID);
        ELSIF c_attr_grp_rec.data_level_id = G_POS_SUPP_ADDR_LEVEL_ID THEN
         Write_Conclog('Before Inserting into Ext intf for Party Site level');

                INSERT INTO POS_SUPP_PROF_EXT_INTF
                 (
                  DATA_SET_ID         ,
                  TRANSACTION_ID      ,
                  PARTY_ID    	      ,
                  PK1_VALUE           , --Party_Site_ID
                  --PK2_VALUE           ,
                  ROW_IDENTIFIER      ,
                  PROCESS_STATUS      ,
                  CLASSIFICATION_CODE ,
                  ATTR_GROUP_INT_NAME ,
                  ATTR_INT_NAME       ,
                  ATTR_DISP_VALUE     ,
                  DATA_LEVEL_ID       ,
                  DATA_LEVEL_NAME,
                  BATCH_ID
                  )
                  VALUES
                 (
                 l_usr_attr_data_tbl(i).DATA_SET_ID,
                 l_usr_attr_data_tbl(i).TRANSACTION_ID,
                 to_number(l_usr_attr_data_tbl(i).PK1_ID),
                 --l_PK1_Value,        -- Party_Site_ID
                 l_usr_attr_data_tbl(i).PK3_ID, -- PK3 is Party_Site_ID
                 l_usr_attr_data_tbl(i).ROW_IDENTIFIER,
                 G_PS_TO_BE_PROCESSED,
                 l_usr_attr_data_tbl(i).CLASSIFICATION_CODE,
                 l_usr_attr_data_tbl(i).ATTR_GROUP_NAME,
                 l_usr_attr_data_tbl(i).ATTR_NAME,
                 l_varchar_data,
                 G_POS_SUPP_ADDR_LEVEL_ID,
		 G_POS_SUPP_ADDR_LEVEL,
        l_usr_attr_data_tbl(i).BATCH_ID
                 );
        ELSIF  c_attr_grp_rec.data_level_id = G_POS_SUPP_ADDR_SITE_LEVEL_ID THEN

         Write_Conclog('Before Insreting into Ext Intf for Supplier Site level' );

                INSERT INTO POS_SUPP_PROF_EXT_INTF
                 (
                  DATA_SET_ID         ,
                  TRANSACTION_ID      ,
                  PARTY_ID    	      ,
                  PK1_VALUE           , --Party_Site_ID
                  PK2_VALUE           , --Vendor_Site_ID
                  --PK3_VALUE           ,
                  ROW_IDENTIFIER      ,
                  PROCESS_STATUS      ,
                  CLASSIFICATION_CODE ,
                  ATTR_GROUP_INT_NAME ,
                  ATTR_INT_NAME       ,
                  ATTR_DISP_VALUE     ,
				  DATA_LEVEL_ID       ,
				  DATA_LEVEL_NAME,
          BATCH_ID
                  )
                  VALUES
                 (
                 l_usr_attr_data_tbl(i).DATA_SET_ID,
                 l_usr_attr_data_tbl(i).TRANSACTION_ID,
                 to_number(l_usr_attr_data_tbl(i).PK1_ID),
                 --l_PK1_Value,        -- Party_Site_ID
                 --l_PK2_Value,        -- _Site_ID
                 --l_usr_attr_data_tbl(i).PK2_ID,
                 l_usr_attr_data_tbl(i).PK3_ID, -- Party_Site_ID
                 l_usr_attr_data_tbl(i).PK4_ID,  -- Vendor_Site_ID
                 l_usr_attr_data_tbl(i).ROW_IDENTIFIER,
                 G_PS_TO_BE_PROCESSED,
                 l_usr_attr_data_tbl(i).CLASSIFICATION_CODE,
                 l_usr_attr_data_tbl(i).ATTR_GROUP_NAME,
                 l_usr_attr_data_tbl(i).ATTR_NAME,
                 l_varchar_data,
		 G_POS_SUPP_ADDR_SITE_LEVEL_ID,
		 G_POS_SUPP_ADDR_SITE_LEVEL,
        l_usr_attr_data_tbl(i).BATCH_ID
                 );
         END IF;
        END IF; --end: IF ( LENGTH(l_usr_attr_data_tbl(i)..
      END LOOP; --FOR i IN 1..l_usr_attr_data_tbl.COUNT LOOP
     Write_Conclog('Populated the User-Defined Attr Values for Attribute Group : '||l_attr_group_int_name);
   END LOOP; --FOR c_attr_grp_rec IN c_user_attr_group_codes

    x_retcode := G_STATUS_SUCCESS;
    x_errbuff := null;
 EXCEPTION
   WHEN OTHERS THEN
      x_retcode := G_STATUS_ERROR;
      x_errbuff := SUBSTRB(SQLERRM, 1,240);
       Write_Conclog('Error! While Loading User Defined Attributes into Interface tables' ) ;
      Write_Conclog('Error while processing Load User Attributes data API  '||SQLCODE || ':'||SQLERRM);
END LOAD_USERATTR_INTF;
-----------------------end of load_userattr_intf---------------------------
-------------------------------------------------------------------------------
--processing of Site Attributes from POS_SUPP_PROF_EXT_INTF
--------------------------------------------------------------------------------
PROCEDURE PROCESS_USER_ATTRS_DATA(
			   	ERRBUF                          OUT NOCOPY VARCHAR2
		       ,RETCODE                         OUT NOCOPY VARCHAR2
		       ,p_data_set_id                   IN   NUMBER
		       ,p_purge_successful_lines        IN   VARCHAR2 DEFAULT FND_API.G_FALSE) is
    l_entity_index_counter   NUMBER := 0;
    l_debug_level           NUMBER  := 0;
    l_user_attrs_return_status VARCHAR2(100);
    l_return_status          VARCHAR2(1);
    l_errorcode              NUMBER;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(1000);
    l_rel_sql 								 VARCHAR2(100);
    l_cnt                   NUMBER      := 0;
   CURSOR c_pos_supp_prof_ext_intf is
   select count(*) from POS_SUPP_PROF_EXT_INTF
   WHERE PROCESS_STATUS = G_PS_TO_BE_PROCESSED
   AND DATA_SET_ID      = p_data_set_id;
BEGIN

 Write_Conclog('Processing the User Defined Attributes ' );

   IF (Error_Handler.Get_Debug = 'Y') THEN
     l_debug_level := 3; --continue writing to the Debug Log opened.
   ELSE
     l_debug_level := 0; --Since Debug log is not opened, donot open Debug log for User-Attrs also.
   END IF;

     l_user_attrs_return_status :=  FND_API.G_RET_STS_SUCCESS;
     Open c_pos_supp_prof_ext_intf;
     fetch c_pos_supp_prof_ext_intf  into  l_cnt;
     Close c_pos_supp_prof_ext_intf;
    IF l_cnt > 0  THEN
          UPDATE POS_SUPP_PROF_EXT_INTF
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
	  ,IS_PROSPECT = 'N'
          -- Bug16384042 We cannot set PK1_value to null irrespective of what DataLevel AG is using
	  --,PK1_VALUE = null
          ,CLASSIFICATION_CODE = 'BS:BASE'
           WHERE DATA_SET_ID = p_data_set_id
           AND (PROCESS_STATUS IS NULL OR
            PROCESS_STATUS = G_PS_TO_BE_PROCESSED);
          l_rel_sql 		  := 'SELECT CODE FROM POS_SUPP_PROF_EXT_OCV';

           -- Bug 12747017 Adding gather stats to improve performance, only doing it when volume are large. Ref Implementation:RRSIMINB.pls
           IF l_cnt > 1000 THEN --hard-code threshold value 1000 here may need to use profile option in future
           Write_Conclog('Before Gathering Stats... l_cnt = '||l_cnt);
           fnd_stats.gather_table_stats('POS','POS_SUPP_PROF_EXT_INTF',cascade=>true,percent=>30);
           fnd_stats.gather_table_stats('POS','POS_SUPP_PROF_EXT_B',cascade=>true,percent=>30);
           fnd_stats.gather_table_stats('POS','POS_SUPP_PROF_EXT_TL',cascade=>true,percent=>30);
           Write_Conclog('Done Gathering Stats....');
           END IF;

	   Write_Conclog('Executing EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data -'||'HZ_PARTIES: Supplier Hub' );

            EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data (
            p_api_version                   =>  G_API_VERSION                    --IN   NUMBER
           ,p_application_id                =>  177                             --IN   NUMBER
           ,p_attr_group_type               =>  'POS_SUPP_PROFMGMT_GROUP'             --IN   VARCHAR2
           ,p_object_name                   =>  'HZ_PARTIES'                      --IN   VARCHAR2
   	   ,p_hz_party_id                   =>   G_HZ_PARTY_ID
           ,p_interface_table_name          =>  'POS_SUPP_PROF_EXT_INTF'               --IN   VARCHAR2
           ,p_data_set_id                   =>  p_data_set_id                    --IN   NUMBER
           ,p_entity_id                     =>  0 --G_ENTITY_ID                      --IN   NUMBER
           ,p_entity_index                  =>  0 --l_entity_index_counter           --IN   NUMBER
           ,p_entity_code                   =>  'HZ_PARTIES'                   --IN   VARCHAR2
           ,p_debug_level                   =>  l_debug_level                    --IN   NUMBER
           ,p_init_error_handler            =>  FND_API.G_FALSE                  --IN   VARCHAR2
           ,p_init_fnd_msg_list             =>  FND_API.G_FALSE                  --IN   VARCHAR2
           ,p_log_errors                    =>  FND_API.G_TRUE                   --IN   VARCHAR2
           ,p_add_errors_to_fnd_stack       =>  FND_API.G_TRUE                   --IN   VARCHAR2
           ,p_commit                        =>  FND_API.G_FALSE                   --IN   VARCHAR2
           ,p_default_view_privilege        =>  NULL                              --IN   VARCHAR2
           ,p_default_edit_privilege        =>  NULL
           ,p_privilege_predicate_api_name  =>  NULL
           ,p_related_class_codes_query     =>  l_rel_sql                              --IN   VARCHAR2
		   ,p_validate                      =>  TRUE
   	       ,p_do_dml                        =>  TRUE
           ,x_return_status                 =>  l_user_attrs_return_status       --OUT NOCOPY VARCHAR2
           ,x_errorcode                     =>  l_errorcode                      --OUT NOCOPY NUMBER
           ,x_msg_count                     =>  l_msg_count                      --OUT NOCOPY NUMBER
           ,x_msg_data                      =>  l_msg_data                       --OUT NOCOPY VARCHAR2
            );

			Write_Conclog('Executed User Defined Attributes Upload API');
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


               IF (FND_API.To_Boolean(p_purge_successful_lines)) THEN
                  -----------------------------------------------
                  -- Delete all successful rows from the table --
                  -- (they're the only rows still in process)  --
                   -----------------------------------------------
                  DELETE FROM POS_SUPP_PROF_EXT_INTF
                  WHERE DATA_SET_ID = p_data_set_id
                  AND PROCESS_STATUS = G_PS_IN_PROCESS;
            ELSE
                   ----------------------------------------------
                   -- Mark all rows we've processed as success --
                   -- if they weren't marked as failure above  --
                   ----------------------------------------------
                 UPDATE POS_SUPP_PROF_EXT_INTF
                 SET PROCESS_STATUS = G_PS_SUCCESS
                 WHERE DATA_SET_ID = p_data_set_id
                 AND PROCESS_STATUS = G_PS_IN_PROCESS;
            END IF;  -- p_purge_successful_lines
      END IF;  -- IF l_cnt > 0




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
    IF (  l_user_attrs_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RETCODE := G_RETCODE_SUCCESS_WITH_WARNING;
    ELSE
      RETCODE := FND_API.G_RET_STS_SUCCESS;
    END IF;
EXCEPTION
WHEN OTHERS THEN
      ----------------------------------------
      -- Mark all rows in process as errors --
      ----------------------------------------
     l_cnt := 0;
     Open c_pos_supp_prof_ext_intf;
     fetch c_pos_supp_prof_ext_intf  into  l_cnt;
     Close c_pos_supp_prof_ext_intf;
     IF l_cnt > 0  THEN
         UPDATE POS_SUPP_PROF_EXT_INTF
         SET PROCESS_STATUS = G_PS_GENERIC_ERROR
         WHERE DATA_SET_ID = p_data_set_id
         AND PROCESS_STATUS = G_PS_IN_PROCESS;
     END IF;

      Write_Conclog('Error! While Processing User Defined Attributes ' ) ;
      Write_Conclog('Error while processing Process User Attrs data API  '||SQLCODE || ':'||SQLERRM);
      RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
END Process_User_Attrs_Data;
  ---------------------------------------------------------------------
  -- Main API called by Java Concurrent program
  ---------------------------------------------------------------------
PROCEDURE BULKLOADENTITIES(
        ERRBUF                  OUT   NOCOPY  VARCHAR2,
        RETCODE                 OUT  NOCOPY   VARCHAR2,
        result_format_usage_id  IN      NUMBER,
        user_id                 IN      NUMBER,
        LANGAUGE                IN      VARCHAR2,
        resp_id                 IN      NUMBER,
        appl_id                 IN      NUMBER,
        batch_id                IN      NUMBER )
IS
  l_region_application_id NUMBER := 0  ;
  l_customization_application_id NUMBER := 0  ;
  l_region_code VARCHAR2(30);
  Current_Error_Code      VARCHAR2(20) := NULL;
  conc_status             BOOLEAN      ;
  l_target_api_call NUMBER :=0;
  l_debug       VARCHAR2(80);
  l_errbuf varchar2(2000);
  l_retcode varchar2(2000);
  --l_rrs_set_process_id     NUMBER;
  l_process_status  char(100);
BEGIN
   Write_Conclog('Executing the BulkLoadEntities API ');
   Write_Conclog('User Defined Attributes Import Program *STARTED*');
  UPDATE EGO_BULKLOAD_INTF
  SET
    PROCESS_STATUS = G_PS_IN_PROCESS,
    LAST_UPDATE_LOGIN = FND_GLOBAL.login_id,
    REQUEST_ID = FND_GLOBAL.conc_request_id,
    PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
    PROGRAM_ID = FND_GLOBAL.conc_program_id
  WHERE RESULTFMT_USAGE_ID = result_format_usage_id
    AND process_status = G_PS_TO_BE_PROCESSED;

   --Bug 16384042 Calling Resolve PK Values to set PK3 and PK4 in EBI table
   Write_Conclog('Before calling Resolve_PK_values');
   RESOLVE_PK_VALUES(
                     RETCODE                  => l_retcode,
                     p_result_format_usage_id => result_format_usage_id
   );

   LOAD_USERATTR_INTF(
	   	  		 p_resultfmt_usage_id    => result_format_usage_id,
                 p_data_set_id           => batch_id,
                 x_errbuff               => l_errbuf,
                 x_retcode               => l_retcode,
                 --Bug16384042 No need to call the same API three times,
                 --always pass SUPP_ADDR_SITE as this returns the most PKs, whether PK will be used is determined later
                 p_entity_name           => 'SUPP_ADDR_SITE',
                 p_batch_id              => batch_id
                );
    --LOAD_USERATTR_INTF(
	--   	  		 p_resultfmt_usage_id    => result_format_usage_id,
          --       p_data_set_id           => batch_id,
            --     x_errbuff               => l_errbuf,
              --   x_retcode               => l_retcode,
                -- p_entity_name           => 'SUPP_ADDR',
              --   p_batch_id              => batch_id
     --           );
    --LOAD_USERATTR_INTF(
	   	-- p_resultfmt_usage_id    => result_format_usage_id,
                -- p_data_set_id           => batch_id,
                -- x_errbuff               => l_errbuf,
                 --x_retcode               => l_retcode,
                 --p_entity_name           => 'SUPP_ADDR_SITE',
                 --p_batch_id              => batch_id
      --          );
   --PROCESS_USER_ATTRS_DATA(
	--		   	ERRBUF                    =>   l_errbuf,
	--	        RETCODE                   =>   l_retcode,
	--	        p_data_set_id             =>   batch_id,
	--	        p_purge_successful_lines  =>   FND_API.G_FALSE);

Write_Conclog('Return Code After Executing LOAD and PROCESS APIs '||l_retcode);
Write_Conclog('Error Code After Executing LOAD and PROCESS APIs '||l_errbuf);

  IF l_retcode = 'S' THEN
              UPDATE EGO_BULKLOAD_INTF
              SET PROCESS_STATUS = G_PS_SUCCESS,
              LAST_UPDATE_LOGIN = FND_GLOBAL.login_id,
              REQUEST_ID = FND_GLOBAL.conc_request_id,
              PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
              PROGRAM_ID = FND_GLOBAL.conc_program_id
              WHERE RESULTFMT_USAGE_ID = result_format_usage_id
              AND process_status = G_PS_IN_PROCESS;
  END IF ;
  ERRBUF := l_errbuf;
  RETCODE := l_retcode;
  Write_Conclog('User Defined Attributes Import Program *COMPLETED* ');
 EXCEPTION
    WHEN OTHERS THEN
       Write_Conclog('Error while processing BulkloadEntities API  '||SQLCODE || ':'||SQLERRM);
       Write_Conclog('Error! While Running User Defined Attributes Import Program ');
       RETCODE := 'E';
       Current_Error_Code := To_Char(SQLCODE);
       conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', Current_Error_Code);
END BULKLOADENTITIES;



PROCEDURE LOAD_PARTY_INTF(
        ERRBUF                  OUT  NOCOPY   VARCHAR2,
        RETCODE                 OUT  NOCOPY   VARCHAR2,
        p_batch_id              IN      NUMBER,
        P_PARTY_ORIG_SYSTEM     IN      VARCHAR2,
        P_PARTY_ORIG_SYSTEM_REFERENCE IN VARCHAR2,
        P_INSERT_UPDATE_FLAG IN VARCHAR2,
        P_PARTY_TYPE IN VARCHAR2,
        P_ORGANIZATION_NAME IN VARCHAR2,
        P_PERSON_FIRST_NAME IN VARCHAR2,
        P_PERSON_LAST_NAME IN VARCHAR2
        )

IS

 l_debug       VARCHAR2(80);
  l_errbuf varchar2(2000);
  l_retcode varchar2(2000);

BEGIN

DELETE FROM HZ_IMP_PARTIES_INT
   WHERE batch_id = p_batch_id;
   Write_Conclog('HZ_IMP_PARTIES_INT Completed');

   DELETE FROM Ap_Suppliers_Int
   WHERE sdh_BATCH_ID = P_BATCH_ID;
   Write_Conclog('Ap_Suppliers_Int Completed');

INSERT
  INTO HZ_IMP_PARTIES_INT
    (
      BATCH_ID,
      PARTY_ORIG_SYSTEM,
      PARTY_ORIG_SYSTEM_REFERENCE,
      INSERT_UPDATE_FLAG,
      PARTY_TYPE,
      ORGANIZATION_NAME,
      PERSON_FIRST_NAME,
      PERSON_LAST_NAME,
      creation_date
    )
    VALUES
    (p_batch_id,
      P_PARTY_ORIG_SYSTEM,
      P_PARTY_ORIG_SYSTEM_REFERENCE,
      P_INSERT_UPDATE_FLAG,
      P_PARTY_TYPE,
       P_ORGANIZATION_NAME,
      P_PERSON_FIRST_NAME,
      P_PERSON_LAST_NAME,
      sysdate
    );

    INSERT INTO AP_SUPPLIERS_INT
   (VENDOR_INTERFACE_ID,
   VENDOR_NAME,
   SDH_BATCH_ID ,
   PARTY_ORIG_SYSTEM  ,
   PARTY_ORIG_SYSTEM_REFERENCE
   )
   VALUES
   (P_BATCH_ID,
   P_ORGANIZATION_NAME,
   P_BATCH_ID,
   P_PARTY_ORIG_SYSTEM,
   P_PARTY_ORIG_SYSTEM_REFERENCE
   );

  DELETE FROM HZ_IMP_PARTIES_INT
   WHERE batch_id = p_batch_id;
   Write_Conclog('HZ_IMP_PARTIES_INT Completed');

   DELETE FROM Ap_Suppliers_Int
   WHERE SDH_BATCH_ID = P_BATCH_ID;
   WRITE_CONCLOG('Ap_Suppliers_Int Completed');

  ERRBUF := l_errbuf;
  RETCODE := 'S';
  Write_Conclog('INSERT PARTY CHANGES ');
 EXCEPTION
    WHEN OTHERS THEN
       Write_Conclog('Error while processing LOAD_PARTY_INTF API  '||SQLCODE || ':'||SQLERRM);
       Write_Conclog('Error! While Running LOAD_PARTY_INTF ');
       RETCODE := 'E';


END LOAD_PARTY_INTF;

END;

/
