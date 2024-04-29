--------------------------------------------------------
--  DDL for Package Body EGO_BOM_BULKLOAD_PVT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_BOM_BULKLOAD_PVT_PKG" AS
/* $Header: BOMBBLPB.pls 115.12 2004/04/30 10:43:22 hgelli noship $ */

-- =================================================================
-- Global variables used in the package.
-- =================================================================

  G_USER_ID         NUMBER  :=  -1;
  G_LOGIN_ID        NUMBER  :=  -1;
  G_PROG_APPID      NUMBER  :=  -1;
  G_PROG_ID         NUMBER  :=  -1;
  G_REQUEST_ID      NUMBER  :=  -1;
  G_DEBUG           NUMBER  :=   1;

  G_STATUS_SUCCESS    CONSTANT VARCHAR2(1)    := 'S';
  G_STATUS_ERROR      CONSTANT VARCHAR2(1)    := 'E';

  --This is the UI language.
  G_LANGUAGE_CODE          VARCHAR2(3);
  G_CONCREQ_VALID_FLAG     BOOLEAN := FALSE;

  G_ERROR_TABLE_NAME      VARCHAR2(99) := 'BOM_BULKLOAD_INTF';
  G_ERROR_ENTITY_CODE     VARCHAR2(99) := 'EGO_ITEM';
  G_ERROR_FILE_NAME       VARCHAR2(99);
  G_BO_IDENTIFIER         VARCHAR2(99) := 'EGO_ITEM';


PROCEDURE open_debug_session IS

  CURSOR c_get_utl_file_dir IS
     SELECT VALUE
      FROM V$PARAMETER
     WHERE NAME = 'utl_file_dir';

  --local variables
  l_log_output_dir       VARCHAR2(200);
  l_log_return_status    VARCHAR2(99);
  l_errbuff              VARCHAR2(999);
BEGIN

  OPEN c_get_utl_file_dir;
  FETCH c_get_utl_file_dir INTO l_log_output_dir;
  --developer_debug('UTL_FILE_DIR : '||l_log_output_dir);
  IF c_get_utl_file_dir%FOUND THEN
    ------------------------------------------------------
    -- Trim to get only the first directory in the list --
    ------------------------------------------------------
    IF INSTR(l_log_output_dir,',') <> 0 THEN
      l_log_output_dir := SUBSTR(l_log_output_dir, 1, INSTR(l_log_output_dir, ',') - 1);
    END IF;

    G_ERROR_FILE_NAME := G_ERROR_TABLE_NAME||'_'||TO_CHAR(SYSDATE, 'DDMONYYYY_HH24MISS')||'.err';

    Error_Handler.Open_Debug_Session(
      p_debug_filename   => G_ERROR_FILE_NAME
     ,p_output_dir       => l_log_output_dir
     ,x_return_status    => l_log_return_status
     ,x_error_mesg       => l_errbuff
     );

    FND_FILE.put_line(FND_FILE.LOG, ' Log file location --> '||l_log_output_dir||'/'||G_ERROR_FILE_NAME ||' created with status '|| l_log_return_status);

    IF (l_log_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       FND_FILE.put_line(FND_FILE.LOG, 'Unable to open error log file. Error => '||l_errbuff);
    END IF;

  END IF;--IF c_get_utl_file_dir%FOUND THEN

END open_debug_session;

FUNCTION Bill_Sequence( p_assembly_item_id IN NUMBER
           , p_alternate_bom_designator IN VARCHAR2
           , p_organization_id  IN NUMBER
      )
  RETURN NUMBER  IS
  l_id       NUMBER;
BEGIN

  SELECT Bill_Sequence_Id
    INTO l_id
   FROM Bom_Bill_Of_Materials
  WHERE Assembly_Item_Id = p_assembly_item_id
    AND NVL(Alternate_Bom_Designator, 'NONE') =
             DECODE(p_alternate_bom_designator,NULL,'NONE',p_alternate_bom_designator)
      AND Organization_Id = p_organization_id;

  RETURN l_id;

  EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Bill_Sequence;

/********************************************************************
* Function      : Organization
* Returns       : NUMBER
* Purpose       : Will convert the value of organization_code to
*     organization_id using MTL_PARAMETERS.
*                 If the conversion fails then the function will return
*     a NULL otherwise will return the org_id.
*     For an unexpected error function will return a
*     missing value.
*********************************************************************/
FUNCTION ORGANIZATION
   ( p_organization IN VARCHAR2) RETURN NUMBER
IS
  l_id                          NUMBER;
BEGIN
  SELECT  Organization_Id
  INTO    l_id
  FROM    Mtl_Parameters
  WHERE   Organization_Code = p_organization;

  RETURN l_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;
END ORGANIZATION;


/*******************************************************************
* Function  : Component_Item
* Parameters IN : Component Item Name
*     Organization ID
* Parameters OUT: Error Message
* Returns : Component_Item_Id
* Purpose : Function will convert the component item name to its
*     corresponsind ID and return the value.
*     If the component is invalid, then a NULL is returned.
*********************************************************************/
FUNCTION Component_Item( p_organization_id   IN NUMBER
      , p_component_item_num IN VARCHAR2)
RETURN NUMBER
IS
  l_id        NUMBER;
  ret_code    NUMBER;
  l_err_text  VARCHAR2(2000);
BEGIN
  ret_code := INVPUOPI.Mtl_Pr_Parse_Flex_Name(
                Org_Id => p_organization_id,
                Flex_Code => 'MSTK',
                Flex_Name => p_component_item_num,
                Flex_Id => l_id,
                Set_Id => -1,
                Err_Text => l_err_text);

  IF (ret_code <> 0) THEN
    RETURN NULL;
  END IF;

  RETURN l_id;

END Component_Item;


------------------------------------------------------------------------------------
PROCEDURE Structure_Intf_Proc_Complete
  (
    p_resultfmt_usage_id     IN    NUMBER
  , x_errbuff                OUT   NOCOPY VARCHAR2
  , x_retcode                OUT   NOCOPY VARCHAR2
    ) IS

BEGIN

-- Update process flag in Ego Bulkload interface table
  UPDATE EGO_BULKLOAD_INTF EBI
   SET  EBI.PROCESS_STATUS =
    (
      SELECT BMI.PROCESS_FLAG
      FROM   BOM_BILL_OF_MTLS_INTERFACE BMI
      WHERE  BMI.TRANSACTION_ID = EBI.TRANSACTION_ID
    )
  WHERE EXISTS
    (
      SELECT 'X'
      FROM   BOM_BILL_OF_MTLS_INTERFACE BMI
      WHERE  BMI.TRANSACTION_ID = EBI.TRANSACTION_ID
    )
    AND EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id;


  UPDATE EGO_BULKLOAD_INTF EBI
   SET  EBI.PROCESS_STATUS =
    (
      SELECT BICI.PROCESS_FLAG
      FROM   BOM_INVENTORY_COMPS_INTERFACE BICI
      WHERE  BICI.TRANSACTION_ID = EBI.TRANSACTION_ID
    )
  WHERE EXISTS
    (
      SELECT 'X'
      FROM   BOM_INVENTORY_COMPS_INTERFACE BICI
      WHERE  BICI.TRANSACTION_ID = EBI.TRANSACTION_ID
    )
    AND EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id;


-- Commiting after the process flag is updated.
   COMMIT;

  --Error_Handler.Write_Debug('EBI: Updated the Process_Status to Indicate Succssful/Unsucessful completion.');
  x_retcode := G_STATUS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    x_retcode := G_STATUS_ERROR;
    x_errbuff := SUBSTRB(SQLERRM, 1,240);
    RAISE;
END Structure_Intf_Proc_Complete;

PROCEDURE PROCESS_BOM_INTERFACE_LINES
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_user_id               IN         NUMBER,
                 p_conc_request_id       IN         NUMBER,
                 p_language_code         IN         VARCHAR2,
                 x_errbuff               IN OUT NOCOPY VARCHAR2,
                 x_retcode               IN OUT NOCOPY VARCHAR2
                )
IS

--Type Declarations
  TYPE VARCHAR_TBL_TYPE IS TABLE OF VARCHAR2(256)
   INDEX BY BINARY_INTEGER;


--BOM RECORDS....
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER := 0;
  l_unexp_error         VARCHAR2(1000);
  tempVar               NUMBER;
  m                     NUMBER := 0; --counter for revised components
  l_commonitem          VARCHAR2(81);
  error_message         VARCHAR2(2000) := '';


  l_return_code         NUMBER;
  l_err_text            VARCHAR2(2000);
  l_err_return_code     INTEGER;

  --API return parameters
  l_retcode             VARCHAR2(10);
  l_errbuff             VARCHAR2(2000);

--Dynamic Cursor Parameters
  l_dyn_sql             VARCHAR2(10000);
  l_dyn_sql_select      VARCHAR2(10000);
  l_dyn_sql_insert      VARCHAR2(10000);
  l_dyn_sql_cursor      VARCHAR2(10000);
  l_msii_set_process_id NUMBER;
  l_cursor_select       INTEGER;
  l_cursor_execute      INTEGER;
  l_temp                NUMBER(10) := 1;

--Column Mapping Tables;
  l_prod_col_name_tbl   VARCHAR_TBL_TYPE;
  l_intf_col_name_tbl   VARCHAR_TBL_TYPE;
  i                     NUMBER := 0;
  j                     NUMBER := 0;
  k                     NUMBER := 0;

--BOM Interface Table Mappings
  l_bom_col_name        VARCHAR_TBL_TYPE;
  l_bom_tbl_name        VARCHAR_TBL_TYPE;
  l_bom_col_type        VARCHAR_TBL_TYPE;

--Column Mappings
  l_prod_col_name       VARCHAR2(256);
  l_intf_col_name       VARCHAR2(256);
  l_parent_column       VARCHAR2(256);
  l_item_col_name       VARCHAR2(256);
  l_org_id_column       VARCHAR2(256);
  l_altbom_column       VARCHAR2(256);
  l_comp_seq_col_name   VARCHAR2(256);

--Txn Types

  G_TXN_CREATE          VARCHAR2(10) := 'CREATE';
  G_TXN_ADD             VARCHAR2(10) := 'ADD';
  G_TXN_UPDATE          VARCHAR2(10) := 'UPDATE';
  G_TXN_DELETE          VARCHAR2(10) := 'DELETE';
  G_TXN_SYNC            VARCHAR2(10) := 'SYNC';

-- COLUMN NAMES
  G_ITEM_NAME           VARCHAR2(30) := 'ITEM_NUMBER';
  G_ORG_CODE            VARCHAR2(30) := 'ORGANIZATION_CODE';
  G_ALT_BOM             VARCHAR2(30) := 'ALTERNATE_BOM_DESIGNATOR';
  G_PARENT_NAME         VARCHAR2(30) := 'PARENT_NAME';
  G_QUANTITY            VARCHAR2(30) := 'QUANTITY';
  G_COMPONENT_SEQ_ID    VARCHAR2(30) := 'COMPONENT_SEQUENCE_ID';


-- Bom Interface column names
  G_EFFECTIVITY_DATE    VARCHAR2(30) := 'EFFECTIVITY_DATE';
  G_OPERATION_SEQ_NUM   VARCHAR2(30) := 'OPERATION_SEQ_NUM';
  G_FROM_END_ITEM_UNIT_NUMBER   VARCHAR2(30) := 'FROM_END_ITEM_UNIT_NUMBER';

--Column Values
  L_ITEM_NAME           VARCHAR2(240) ;
  L_ORGANIZATION_CODE   VARCHAR2(3) ;
  L_STRUCTURE_NAME      VARCHAR2(10) ;
  L_PARENT_NAME         VARCHAR2(240) ;
  L_QUANTITY            NUMBER := 2;
  L_TRANSACTION_ID      NUMBER;

-- Interface COLUMN NAMES
  G_INTF_STRUCT_NAME    VARCHAR2(30) := 'C_FIX_COLUMN3';
  G_INTF_ORG_CODE       VARCHAR2(30) := 'C_INTF_ATTR1';
  G_INTF_COMP_SEQ_ID    VARCHAR2(30) := 'N_INTF_ATTR1';

-- Temparory Variables
  l_Org_Id              NUMBER;
  l_Inv_Item_Id         NUMBER;
  l_Bill_Seq_Id         NUMBER;
  l_str                 VARCHAR2(1000);

-- Constant Values
  G_DEL_GROUP_NAME    VARCHAR2(10)  := 'B_BLK_INTF';
  G_DEL_GROUP_DESC    VARCHAR2(240) := 'Delete Group for EGO BOM Bulkload Structures';

  l_bom_header_columns_tbl   DBMS_SQL.VARCHAR2_TABLE;


--DEBUG FLAG
  l_debug       VARCHAR2(10);
  --
  --  Get the Header Data from the Parents.
  --


  --
  -- To get the BOM Attribute columns in the Result Format.
  --

  CURSOR C_BOM_ATTRIBUTE_COLUMNS (c_Resultfmt_Usage_Id  IN  NUMBER) IS
    SELECT
      erf.Attribute_Code,
      erf.Intf_Column_Name,
      bcc.Bom_Intf_Column_Name ,
      bcc.Bom_Intf_Table_Name,
      bcc.Operation_Type
    FROM
      Ego_Results_Fmt_Usages erf,
      Bom_Component_Columns bcc
    WHERE
      Region_Code = 'BOM_RESULT_DUMMY_REGION'
    AND
      Region_Application_Id = 702
    AND
      Customization_Application_Id = 431
    AND
      Resultfmt_Usage_Id = c_Resultfmt_Usage_Id
    AND
      bcc.Attribute_Code = erf.Attribute_Code
    AND
      (   bcc.Parent_Entity IS NULL
      OR  BCC.Attribute_Code = 'ITEM_NUMBER'
      OR  BCC.Attribute_Code = 'PARENT_NAME')
    AND
      erf.Attribute_Code NOT LIKE '%$$%';

  -- Cursor to create a row with 'Primary' (Null) alternate for structure headers
  -- This is to automate the creation of primary boms for PLM purpose
  CURSOR C_BOM_BILL_PRIMARY(C_REQUEST_ID IN NUMBER) IS
    SELECT
      ASSEMBLY_ITEM_ID,
      ORGANIZATION_ID,
      ASSEMBLY_TYPE,
      PROCESS_FLAG,
      ORGANIZATION_CODE,
      COMMON_ORG_CODE,
      ITEM_NUMBER,
      IMPLEMENTATION_DATE
    FROM
      BOM_BILL_OF_MTLS_INTERFACE
    WHERE
      PROCESS_FLAG = 1
    AND
      REQUEST_ID = C_REQUEST_ID;


BEGIN
    l_debug := fnd_profile.value('MRP_DEBUG');

    IF (NVL(fnd_profile.value('CONC_REQUEST_ID'), 0) <> 0) THEN
      G_CONCREQ_VALID_FLAG  := TRUE;
    END IF;

    IF (G_CONCREQ_VALID_FLAG ) THEN
      FND_FILE.put_line(FND_FILE.LOG, ' ******** New Log ******** ');
    END IF;

   -- the values are chosen from the FND_GLOBALS
    G_USER_ID    := FND_GLOBAL.user_id         ;
    G_LOGIN_ID   := FND_GLOBAL.login_id        ;
    G_PROG_APPID := FND_GLOBAL.prog_appl_id    ;
    G_PROG_ID    := FND_GLOBAL.conc_program_id ;
    G_REQUEST_ID := FND_GLOBAL.conc_request_id ;
    G_LANGUAGE_CODE := p_Language_Code;



    Error_Handler.initialize();
    Error_Handler.set_bo_identifier(G_BO_IDENTIFIER);
    --Log errors into file
    --Error_Handler.Set_Debug('Y');
    --Opens Error_Handler debug session
    --Open_Debug_Session;

    --After Open_Debug_Session, can log using Error_Handler.Write_Debug()
    --Replace this with FND_FILE.put_line() if needed.
    --Error_Handler.Write_Debug('G_USER_ID : '||TO_CHAR(G_USER_ID));
    --Error_Handler.Write_Debug('G_PROG_ID : '||TO_CHAR(G_PROG_ID));
    --Error_Handler.Write_Debug('G_REQUEST_ID : '||TO_CHAR(G_REQUEST_ID));
    --Error_Handler.Write_Debug('P_RESULT_FMT_USAGE_ID : '||TO_CHAR(p_Resultfmt_Usage_Id));


--  Delete all the earlier uploads from the same spreadsheet.
   /*
    DELETE FROM  EGO_BULKLOAD_INTF
    WHERE RESULTFMT_USAGE_ID = p_resultfmt_usage_id
    AND PROCESS_STATUS <> 1;
*/

    --Error_Handler.Write_Debug('About to populate the EBI with Trans IDs');
    --Populate the Transaction IDs for current result fmt usage ID
     --New Transaction ID. It will be replaced by old Transaction ID Seq.
     --SET  transaction_id = MSII_TRANSACTION_ID_S.NEXTVAL
    UPDATE EGO_BULKLOAD_INTF
     SET  Transaction_Id = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
    WHERE  Resultfmt_Usage_Id = p_Resultfmt_Usage_Id AND PROCESS_STATUS = 1 ;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering First Loop ');
    END IF;


--  Get the Mapped Columns to a Table
    i := 1;
    FOR C_BOM_ATTRIBUTE_COLUMNS_REC IN C_BOM_ATTRIBUTE_COLUMNS
     (
       p_resultfmt_usage_id
      )
    LOOP
      l_prod_col_name_tbl(i) := C_BOM_ATTRIBUTE_COLUMNS_REC.ATTRIBUTE_CODE;
      l_intf_col_name_tbl(i) := C_BOM_ATTRIBUTE_COLUMNS_REC.INTF_COLUMN_NAME;
      l_bom_col_name(i)      := C_BOM_ATTRIBUTE_COLUMNS_REC.BOM_INTF_COLUMN_NAME;
      l_bom_tbl_name(i)      := C_BOM_ATTRIBUTE_COLUMNS_REC.BOM_INTF_TABLE_NAME;
      l_bom_col_type(i)      := C_BOM_ATTRIBUTE_COLUMNS_REC.OPERATION_TYPE;

      IF (C_BOM_ATTRIBUTE_COLUMNS_REC.ATTRIBUTE_CODE = G_PARENT_NAME) THEN
        l_parent_column := C_BOM_ATTRIBUTE_COLUMNS_REC.INTF_COLUMN_NAME;
      END IF;
      IF (C_BOM_ATTRIBUTE_COLUMNS_REC.ATTRIBUTE_CODE = G_ITEM_NAME) THEN
        l_item_col_name := C_BOM_ATTRIBUTE_COLUMNS_REC.INTF_COLUMN_NAME;
      END IF;
      i := i+1;
    END LOOP;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Exiting First Loop ');
    END IF;


-- Process The Rows for BOM BO Header For Create and Update.
    l_dyn_sql_insert := '';
    l_dyn_sql_insert := l_dyn_sql_insert || 'INSERT INTO BOM_BILL_OF_MTLS_INTERFACE (REQUEST_ID, Transaction_Type ';
    l_dyn_sql_insert := l_dyn_sql_insert || ', Transaction_Id, Process_Flag, Item_Number ';
    l_dyn_sql_insert := l_dyn_sql_insert || ', Organization_Code, Alternate_Bom_Designator) ';

    l_dyn_sql_select := '';
    l_dyn_sql_select := l_dyn_sql_select || ' SELECT REQUEST_ID, Transaction_Type, Transaction_Id, 1, ' || l_item_col_name;
    l_dyn_sql_select := l_dyn_sql_select || ', ' || G_INTF_ORG_CODE;
    l_dyn_sql_select := l_dyn_sql_select || ', DECODE(' || G_INTF_STRUCT_NAME || ',Bom_Globals.Retrieve_Message(''BOM'', ''BOM_PRIMARY''),NULL,' || G_INTF_STRUCT_NAME || ')';
    l_dyn_sql_select := l_dyn_sql_select || ' FROM EGO_BULKLOAD_INTF WHERE RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID ';
    l_dyn_sql_select := l_dyn_sql_select || ' AND  PROCESS_STATUS = 1 AND ' || l_parent_column || ' IS NULL ';

    l_dyn_sql := l_dyn_sql_insert || ' ' || l_dyn_sql_select;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering First SQL 1' || l_dyn_sql);
    END IF;


    EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
-- Header Data Ready

-- Process Components for UPDATE
    l_dyn_sql_insert := '';
    l_dyn_sql_insert := l_dyn_sql_insert || 'INSERT INTO BOM_INVENTORY_COMPS_INTERFACE ( REQUEST_ID, Transaction_Type, Transaction_Id, Process_Flag, ';
    l_dyn_sql_insert := l_dyn_sql_insert || 'ORGANIZATION_CODE, ALTERNATE_BOM_DESIGNATOR, COMPONENT_SEQUENCE_ID, ';
    l_dyn_sql_select := '';
    l_dyn_sql_select := l_dyn_sql_select || 'SELECT REQUEST_ID, TRANSACTION_TYPE, Transaction_Id, 1, ' || G_INTF_ORG_CODE || ', ';
    l_dyn_sql_select := l_dyn_sql_select || 'DECODE(' || G_INTF_STRUCT_NAME || ',Bom_Globals.Retrieve_Message(''BOM'', ''BOM_PRIMARY''),NULL,' || G_INTF_STRUCT_NAME || '), ';
    l_dyn_sql_select := l_dyn_sql_select || G_INTF_COMP_SEQ_ID || ', ';

    FOR i IN 1..l_prod_col_name_tbl.COUNT LOOP
      IF (l_bom_col_name(i) IS NOT NULL) THEN
      -- For Effectivity_Date, Operation_Seq_Num, and From_End_Unit_Number changes
      -- we need to update the New_Effectivity_Date, New_Operation_Seq_Num,
      -- and New_From_End_Unit_Number


        IF (l_bom_col_name(i) = G_EFFECTIVITY_DATE) THEN
          l_dyn_sql_insert := l_dyn_sql_insert || 'NEW_EFFECTIVITY_DATE,';
          -- If the new effectivity date is same as the effectivity date in the database
          -- then insert null other wise insert new value into the interface table.
          l_str := 'DECODE(( SELECT To_Char(Effectivity_Date,''DD-MON-YYYY HH24:MI:SS'') FROM Bom_inventory_Components WHERE Component_Sequence_Id = ' || G_INTF_COMP_SEQ_ID || ')';
          l_str := l_str || ',' || l_intf_col_name_tbl(i) ||',TO_DATE(NULL, ''DD-MON-YYYY HH24:MI:SS'')';
          l_str := l_str || ',TO_DATE(' || l_intf_col_name_tbl(i) || ',''DD-MON-YYYY HH24:MI:SS'')),';
          l_dyn_sql_select := l_dyn_sql_select || l_str;
        ELSE
            IF (l_bom_col_name(i) = G_OPERATION_SEQ_NUM) THEN
              l_dyn_sql_insert := l_dyn_sql_insert || 'NEW_OPERATION_SEQ_NUM,';
            ELSIF (l_bom_col_name(i) = G_FROM_END_ITEM_UNIT_NUMBER) THEN
              l_dyn_sql_insert := l_dyn_sql_insert || 'NEW_FROM_END_ITEM_UNIT_NUMBER,';
            ELSE
              l_dyn_sql_insert := l_dyn_sql_insert || l_bom_col_name(i) || ',';
            END IF;
         -- As date values are coming as character values convert them as dates.
            IF ((l_bom_col_type(i) IS NOT NULL) AND (l_bom_col_type(i) = 'DATETIME')) THEN
              l_dyn_sql_select := l_dyn_sql_select || 'TO_DATE(' || l_intf_col_name_tbl(i) || ',''DD-MON-YYYY HH24:MI:SS''),';
            ELSE
              l_dyn_sql_select := l_dyn_sql_select || l_intf_col_name_tbl(i) || ',';
            END IF;
        END IF;

      END IF;
    END LOOP;

    l_dyn_sql_insert := SUBSTR(l_dyn_sql_insert,0,LENGTH(l_dyn_sql_insert) - 1);
    l_dyn_sql_select := SUBSTR(l_dyn_sql_select,0,LENGTH(l_dyn_sql_select) - 1);
    l_dyn_sql_insert := l_dyn_sql_insert || ' ) ';
    l_dyn_sql_select := l_dyn_sql_select || ' FROM EGO_BULKLOAD_INTF ';
    l_dyn_sql_select := l_dyn_sql_select || ' WHERE RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID ';
    l_dyn_sql_select := l_dyn_sql_select || ' AND PROCESS_STATUS = 1 AND ' || l_parent_column || ' IS NOT NULL ';
    l_dyn_sql_select := l_dyn_sql_select || ' AND Transaction_Type = ''' || G_TXN_UPDATE || ''' ';

    l_dyn_sql := l_dyn_sql_insert || ' ' || l_dyn_sql_select;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering SQL 2' || l_dyn_sql);
    END IF;

    EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
-- End of Process Components for UPDATE
      IF l_debug = 'Y' THEN
        FND_FILE.PUT_LINE( FND_FILE.LOG,'Executed Succesfully 2');
      END IF;


-- Process Components for CREATE/ADD
  -- Create Structure Header record if that is not available.
  -- Comment this block if it is not required.
    l_dyn_sql_cursor := '';
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' SELECT Distinct Transaction_Id, ' || l_parent_column ;
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' , ' || G_INTF_ORG_CODE;
    l_dyn_sql_cursor := l_dyn_sql_cursor || ', DECODE(' || G_INTF_STRUCT_NAME || ', Bom_Globals.Retrieve_Message(''BOM'', ''BOM_PRIMARY''),NULL,' || G_INTF_STRUCT_NAME || ')';
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' FROM EGO_BULKLOAD_INTF WHERE Process_Status = 1';
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' AND Resultfmt_Usage_Id = :RESULTFMT_USAGE_ID ';
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' AND ' || l_parent_column || ' IS NOT NULL ';
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' AND (Transaction_Type = ''' || G_TXN_CREATE || ''' OR  Transaction_Type = ''' || G_TXN_ADD || ''' ';
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' OR Transaction_Type = ''' || G_TXN_SYNC || ''' )';

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering SQL 2.1' || l_dyn_sql_cursor);
    END IF;

    l_cursor_select := Dbms_Sql.Open_Cursor;
    Dbms_Sql.Parse(l_cursor_select, l_dyn_sql_cursor, Dbms_Sql.NATIVE);
    Dbms_Sql.Define_Column(l_cursor_select, 1, L_TRANSACTION_ID);
    Dbms_Sql.Define_Column(l_cursor_select, 2, L_PARENT_NAME, 5000);
    Dbms_Sql.Define_Column(l_cursor_select, 3, L_ORGANIZATION_CODE, 5000);
    Dbms_Sql.Define_Column(l_cursor_select, 4, L_STRUCTURE_NAME, 5000);

    Dbms_Sql.Bind_Variable(l_cursor_select,':RESULTFMT_USAGE_ID', p_resultfmt_usage_id);

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering SQL 2.2' || p_resultfmt_usage_id);
    END IF;


    l_cursor_execute := Dbms_Sql.EXECUTE(l_cursor_select);

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'SUCCESS');
    END IF;
    i := 1;
    LOOP
      IF (Dbms_Sql.Fetch_Rows(l_cursor_select) > 0) THEN
        Dbms_Sql.Column_Value(l_cursor_select,1,L_TRANSACTION_ID);
        Dbms_Sql.Column_Value(l_cursor_select,2,L_PARENT_NAME);
        Dbms_Sql.Column_Value(l_cursor_select,3,L_ORGANIZATION_CODE);
        Dbms_Sql.Column_Value(l_cursor_select,4,L_STRUCTURE_NAME);

        l_Org_Id := ORGANIZATION(L_ORGANIZATION_CODE);
        l_Inv_Item_Id := Component_Item(l_Org_Id,L_PARENT_NAME);
        l_Bill_Seq_Id := Bill_Sequence(l_Inv_Item_Id,L_STRUCTURE_NAME,l_Org_Id);
        IF(l_Bill_Seq_Id IS NULL) THEN
        INSERT INTO BOM_BILL_OF_MTLS_INTERFACE (
            REQUEST_ID,
            TRANSACTION_TYPE,
            TRANSACTION_ID,
            PROCESS_FLAG,
            ITEM_NUMBER,
            ORGANIZATION_CODE,
            ALTERNATE_BOM_DESIGNATOR           )
        VALUES                                 (
            G_REQUEST_ID,
            G_TXN_CREATE,
            L_TRANSACTION_ID,
            1,
            L_PARENT_NAME,
            L_ORGANIZATION_CODE,
            L_STRUCTURE_NAME                   );
        END IF;
        i := i+ 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering SQL 3' || l_dyn_sql);
    END IF;


    Dbms_Sql.Close_Cursor(l_cursor_select);
  -- End of Creating Structure Header record if that is not available.

    l_dyn_sql_insert := '';
    l_dyn_sql_insert := l_dyn_sql_insert || 'INSERT INTO BOM_INVENTORY_COMPS_INTERFACE ( REQUEST_ID, Transaction_Type, Transaction_Id, Process_Flag, ';
    l_dyn_sql_insert := l_dyn_sql_insert || 'ORGANIZATION_CODE, ALTERNATE_BOM_DESIGNATOR, COMPONENT_SEQUENCE_ID, ';
    l_dyn_sql_select := '';
    l_dyn_sql_select := l_dyn_sql_select || 'SELECT REQUEST_ID, ''' || G_TXN_CREATE || ''', Transaction_Id, 1, ' || G_INTF_ORG_CODE || ', ';
    l_dyn_sql_select := l_dyn_sql_select || 'DECODE(' || G_INTF_STRUCT_NAME || ',Bom_Globals.Retrieve_Message(''BOM'', ''BOM_PRIMARY''),NULL,' || G_INTF_STRUCT_NAME || '), ';
    l_dyn_sql_select := l_dyn_sql_select || G_INTF_COMP_SEQ_ID || ', ';

    FOR i IN 1..l_prod_col_name_tbl.COUNT LOOP
      IF (l_bom_col_name(i) IS NOT NULL) THEN
        l_dyn_sql_insert := l_dyn_sql_insert || l_bom_col_name(i) || ',';

     -- As date values are coming as character values convert them as dates.
        IF ((l_bom_col_type(i) IS NOT NULL) AND (l_bom_col_type(i) = 'DATETIME')) THEN
          l_dyn_sql_select := l_dyn_sql_select || 'TO_DATE(' || l_intf_col_name_tbl(i) || ',''DD-MON-YYYY HH24:MI:SS''),';
        ELSE
          l_dyn_sql_select := l_dyn_sql_select || l_intf_col_name_tbl(i) || ',';
        END IF;

      END IF;
    END LOOP;

    l_dyn_sql_insert := SUBSTR(l_dyn_sql_insert,0,LENGTH(l_dyn_sql_insert) - 1);
    l_dyn_sql_select := SUBSTR(l_dyn_sql_select,0,LENGTH(l_dyn_sql_select) - 1);
    l_dyn_sql_insert := l_dyn_sql_insert || ' ) ';
    l_dyn_sql_select := l_dyn_sql_select || ' FROM EGO_BULKLOAD_INTF ';
    l_dyn_sql_select := l_dyn_sql_select || ' WHERE RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID ';
    l_dyn_sql_select := l_dyn_sql_select || ' AND PROCESS_STATUS = 1 AND ' || l_parent_column || ' IS NOT NULL ';
--    l_dyn_sql_select := l_dyn_sql_select || ' AND (Transaction_Type = ''' || G_TXN_CREATE || ''' OR  Transaction_Type = ''' || G_TXN_ADD || ''') ';

    l_dyn_sql_select := l_dyn_sql_select || ' AND (Transaction_Type = ''' || G_TXN_CREATE || ''' OR  Transaction_Type = ''' || G_TXN_ADD || ''' ';
    l_dyn_sql_select := l_dyn_sql_select || ' OR Transaction_Type = ''' || G_TXN_SYNC || ''' )';


    l_dyn_sql := l_dyn_sql_insert || ' ' || l_dyn_sql_select;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering SQL 4' || l_dyn_sql);
    END IF;

    EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
-- End of Process Components for CREATE/ADD

      IF l_debug = 'Y' THEN
        FND_FILE.PUT_LINE( FND_FILE.LOG,'Executed Succesfully 4');
      END IF;

-- Start of process components for Delete
    l_dyn_sql_insert := '';
    l_dyn_sql_insert := l_dyn_sql_insert || 'INSERT INTO BOM_INVENTORY_COMPS_INTERFACE ( REQUEST_ID, Transaction_Type, Transaction_Id, Process_Flag, ';
    l_dyn_sql_insert := l_dyn_sql_insert || 'ORGANIZATION_CODE, ALTERNATE_BOM_DESIGNATOR, COMPONENT_SEQUENCE_ID, ';
    l_dyn_sql_insert := l_dyn_sql_insert || 'DELETE_GROUP_NAME, DG_DESCRIPTION, ';
    l_dyn_sql_select := '';
    l_dyn_sql_select := l_dyn_sql_select || 'SELECT REQUEST_ID, Transaction_Type, Transaction_Id, 1, ' || G_INTF_ORG_CODE || ', ';
    l_dyn_sql_select := l_dyn_sql_select || 'DECODE(' || G_INTF_STRUCT_NAME || ',Bom_Globals.Retrieve_Message(''BOM'', ''BOM_PRIMARY''),NULL,' || G_INTF_STRUCT_NAME || '), ';
    l_dyn_sql_select := l_dyn_sql_select || G_INTF_COMP_SEQ_ID || ', ';
    l_dyn_sql_select := l_dyn_sql_select || '''' || G_DEL_GROUP_NAME || ''', ''' || G_DEL_GROUP_DESC || ''', ' ;

    FOR i IN 1..l_prod_col_name_tbl.COUNT LOOP
      IF (l_bom_col_name(i) IS NOT NULL) THEN
        l_dyn_sql_insert := l_dyn_sql_insert || l_bom_col_name(i) || ',';

     -- As date values are coming as character values convert them as dates.
        IF ((l_bom_col_type(i) IS NOT NULL) AND (l_bom_col_type(i) = 'DATETIME')) THEN
          l_dyn_sql_select := l_dyn_sql_select || 'TO_DATE(' || l_intf_col_name_tbl(i) || ',''DD-MON-YYYY HH24:MI:SS''),';
        ELSE
          l_dyn_sql_select := l_dyn_sql_select || l_intf_col_name_tbl(i) || ',';
        END IF;

      END IF;
    END LOOP;

    l_dyn_sql_insert := SUBSTR(l_dyn_sql_insert,0,LENGTH(l_dyn_sql_insert) - 1);
    l_dyn_sql_select := SUBSTR(l_dyn_sql_select,0,LENGTH(l_dyn_sql_select) - 1);
    l_dyn_sql_insert := l_dyn_sql_insert || ' ) ';
    l_dyn_sql_select := l_dyn_sql_select || ' FROM EGO_BULKLOAD_INTF ';
    l_dyn_sql_select := l_dyn_sql_select || ' WHERE RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID ';
    l_dyn_sql_select := l_dyn_sql_select || ' AND PROCESS_STATUS = 1 AND ' || l_parent_column || ' IS NOT NULL ';
    l_dyn_sql_select := l_dyn_sql_select || ' AND Transaction_Type = ''' || G_TXN_DELETE || ''' ';

    l_dyn_sql := l_dyn_sql_insert || ' ' || l_dyn_sql_select;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering SQL 5' || l_dyn_sql);
    END IF;

    EXECUTE IMMEDIATE l_dyn_sql USING p_resultfmt_usage_id;
-- End of process components for Delete

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Before UPdate of AssemblyType');
    END IF;

-- Updateing the assembly_type to 2 for BOM_header
    UPDATE BOM_BILL_OF_MTLS_INTERFACE set assembly_type = 2
    where assembly_type is null;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'After UPdate of AssemblyType');
    END IF;

-- iNSERT ROWS FOR PRIMARY ALTERNATE FOR creating primary bom if it doesn't exist
-- Also set the txn id for all those rows
    FOR C_BOM_BILL_PRIMARY_REC IN C_BOM_BILL_PRIMARY
     (
       G_REQUEST_ID
      )
    LOOP
      INSERT INTO BOM_BILL_OF_MTLS_INTERFACE
      (
        ASSEMBLY_ITEM_ID,
        ORGANIZATION_ID,
        ASSEMBLY_TYPE,
        PROCESS_FLAG,
        ORGANIZATION_CODE,
        COMMON_ORG_CODE,
        ITEM_NUMBER,
        IMPLEMENTATION_DATE,
        ALTERNATE_BOM_DESIGNATOR,
        TRANSACTION_TYPE,
        REQUEST_ID)
      VALUES
      (
        C_BOM_BILL_PRIMARY_REC.ASSEMBLY_ITEM_ID,
        C_BOM_BILL_PRIMARY_REC.ORGANIZATION_ID,
        C_BOM_BILL_PRIMARY_REC.ASSEMBLY_TYPE,
        C_BOM_BILL_PRIMARY_REC.PROCESS_FLAG,
        C_BOM_BILL_PRIMARY_REC.ORGANIZATION_CODE,
        C_BOM_BILL_PRIMARY_REC.COMMON_ORG_CODE,
        C_BOM_BILL_PRIMARY_REC.ITEM_NUMBER,
        C_BOM_BILL_PRIMARY_REC.IMPLEMENTATION_DATE,
        NULL,
        G_TXN_SYNC,
        G_REQUEST_ID);
    END LOOP;


    UPDATE BOM_BILL_OF_MTLS_INTERFACE
     SET  Transaction_Id = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
    WHERE  REQUEST_ID = G_REQUEST_ID AND PROCESS_FLAG = 1
    and Transaction_Id is null;


-- Call the BOM API TO PROCESS INTERFACE TABLES
   l_err_return_code := bom_open_interface_api.import_bom
      ( org_id    => 207 --Dummy value, all_org below carries precedence
      , all_org   => 1
      , err_text  => l_err_text
      );


    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Done Processing');
    END IF;

    --Error_Handler.Write_Debug('Structure Import : UPDATE : l_err_text = ' || l_err_text);

-- Call completion procedure
    Structure_Intf_Proc_Complete
    (
      p_resultfmt_usage_id  => p_resultfmt_usage_id
      ,x_errbuff             => l_errbuff
      ,x_retcode             => l_retcode
    );

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Completed Processing');
    END IF;

    --Error_Handler.Write_Debug('Updated the Process Status to Indicate Successful/Unsucessful component/structure Import Completion');

  EXCEPTION
    WHEN OTHERS THEN
    l_err_text := SQLERRM;
      --Error_Handler.Write_Debug('WHEN OTHERS Exception.');
      --Error_Handler.Write_Debug('error code : '|| TO_CHAR(SQLCODE));
      --Error_Handler.Write_Debug('error text : '|| SQLERRM);
      x_errbuff := 'Error : '||TO_CHAR(SQLCODE)||'---'||SQLERRM;
      x_retcode := Error_Handler.G_STATUS_ERROR;
      IF l_debug = 'Y' THEN
        FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering Exception Message ' || x_errbuff);
        FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering Exception Code' || x_retcode);
      END IF;
      Error_Handler.Close_Debug_Session;

END PROCESS_BOM_INTERFACE_LINES;

END EGO_BOM_BULKLOAD_PVT_PKG;

/
