--------------------------------------------------------
--  DDL for Package Body BOM_BULKLOAD_PVT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BULKLOAD_PVT_PKG" AS
/* $Header: BOMBBLPB.pls 120.30.12010000.3 2009/04/10 10:49:25 vggarg ship $ */

-- =================================================================
-- Global variables used in the package.
-- =================================================================

  G_USER_ID         NUMBER  :=  -1;
  G_LOGIN_ID        NUMBER  :=  -1;
  G_PROG_APPID      NUMBER  :=  -1;
  G_PROG_ID         NUMBER  :=  -1;
  G_REQUEST_ID      NUMBER  :=  -1;
  G_DEBUG           NUMBER  :=   1;

  --sREEJITH
  G_INTF_SRCSYS_COMPONENT   VARCHAR2(15) := 'C_FIX_COLUMN12';
  G_INTF_SRCSYS_DESCRIPTION VARCHAR2(15) := 'C_FIX_COLUMN13';
  G_INTF_SRCSYS_PARENT      VARCHAR2(15) := 'C_FIX_COLUMN14';

  G_STATUS_SUCCESS    CONSTANT VARCHAR2(1)    := 'S';
  G_STATUS_ERROR      CONSTANT VARCHAR2(1)    := 'E';

  --This is the UI language.
  G_LANGUAGE_CODE          VARCHAR2(3);
  G_CONCREQ_VALID_FLAG     BOOLEAN := FALSE;

  G_ERROR_TABLE_NAME      VARCHAR2(99) := 'BOM_BULKLOAD_INTF';
  G_ERROR_ENTITY_CODE     VARCHAR2(99) := 'EGO_ITEM';
  G_ERROR_FILE_NAME       VARCHAR2(99);
  G_BO_IDENTIFIER         VARCHAR2(99) := 'EGO_ITEM';
  G_BOM_APPLICATION_ID    NUMBER(3)    := 702;
  G_COMP_ATTR_GROUP_TYPE  VARCHAR2(30) := 'BOM_COMPONENTMGMT_GROUP';

   ---------------------------------------------------------------
   -- Interface line processing statuses.                       --
   ---------------------------------------------------------------
   G_INTF_STATUS_TOBE_PROCESS   CONSTANT NUMBER := 1;
   G_INTF_STATUS_SUCCESS        CONSTANT NUMBER := 7;
   G_INTF_STATUS_ERROR          CONSTANT NUMBER := 3;

   ---------------------------------------------------------------
   -- The process status to be set to the interface table is    --
   -- 1 by default. But for non PDH batch, set status to 0      --
   ---------------------------------------------------------------

   G_PROCESS_STATUS     NUMBER := 1;

   ----------------------------------------------------------------------------
   -- The Date Format is chosen to be as close as possible to Timestamp format,
   -- except that we support dates before zero A.D. (the "S" in the year part).
   ----------------------------------------------------------------------------
   G_DATE_FORMAT                            CONSTANT VARCHAR2(30) := 'SYYYY-MM-DD HH24:MI:SS';

   -----------------------------------------------------------------------
   -- These are the Constants to generate a New Line Character.         --
   -----------------------------------------------------------------------
   G_CARRIAGE_RETURN VARCHAR2(1) :=  FND_GLOBAL.LOCAL_CHR(13);
   G_LINE_FEED       VARCHAR2(1) :=  FND_GLOBAL.LOCAL_CHR(10);
   G_NEWLINE         VARCHAR2(2) :=  G_LINE_FEED;

  -----------------------------------------------------------------------
  -- TYPE Defenitions for RDs
  -----------------------------------------------------------------------
  TYPE RD_VARCHAR_TBL_TYPE IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  G_MISS_RD_VARCHAR_TBL RD_VARCHAR_TBL_TYPE;

/* Function that checks if there are any rows to be processed in the
 * EGO_BULKLOAD_INTF prior to running all the heavy dbms_sqls.
 * This will give a performance boost if the users are loading data
 * through the same batch_id
*/
FUNCTION Interface_Rows_Exist
  (p_resultfmt_usage_id IN NUMBER)
  return BOOLEAN
IS
l_unprocessed_rowcount number := 0;
l_rows_exists BOOLEAN := FALSE;
begin
  SELECT
    COUNT(RESULTFMT_USAGE_ID) into l_unprocessed_rowcount
  FROM
    EGO_BULKLOAD_INTF E
  where
    E.RESULTFMT_USAGE_ID = p_resultfmt_usage_id
    and E.PROCESS_STATUS = 1;
  IF (l_unprocessed_rowcount > 0) then
    l_rows_exists := TRUE;
  END IF;
  RETURN l_rows_exists;
end;

 -----------------------------------------------------------------
 -- Write Debug statements to Log using Error Handler procedure --
 -----------------------------------------------------------------
PROCEDURE Write_Debug (p_msg  IN  VARCHAR2) IS
    l_debug       VARCHAR2(10);
BEGIN
    l_debug := fnd_profile.value('MRP_DEBUG');

  -- NOTE: No need to check for profile now, as Error_Handler checks
  --       for Error_Handler.Get_Debug = 'Y' before writing to Debug Log.
    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG, '['||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'] '|| p_msg);
    END IF;
END;

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
FUNCTION GET_ORGANIZATION_ID
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
END GET_ORGANIZATION_ID;


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

  -------------------------------------------------------------------
  -- Checks whether the given string is number or not  --
  -------------------------------------------------------------------
  FUNCTION RD_isNumber(p_str_num varchar2) RETURN BOOLEAN IS
    l_num NUMBER;
    l_ret_code  BOOLEAN;
  BEGIN
    l_ret_code := TRUE;
    BEGIN
      l_num := To_Number(p_str_num);
    EXCEPTION
      WHEN Invalid_Number THEN
        l_ret_code := FALSE;
      WHEN Value_Error THEN
        l_ret_code := FALSE;
      WHEN OTHERS THEN
        l_ret_code := FALSE;
    END;
    RETURN l_ret_code;
  END;

  -------------------------------------------------------------------
  -- Split the string and return as ARRAY of Reference Designators --
  -------------------------------------------------------------------
  PROCEDURE splitIntoArray (p_comp_ref_desig IN VARCHAR2,
                x_rd_tbl IN OUT NOCOPY RD_VARCHAR_TBL_TYPE)
  IS
    l_rds_tbl      RD_VARCHAR_TBL_TYPE;
    l_next_sep     NUMBER;
    l_prev_sep     NUMBER;
    l_sep_count    NUMBER;
  BEGIN
    Write_Debug('Inside splitIntoArray');
    l_sep_count := 1;
    l_prev_sep  := 1;
    Write_debug('p_comp_ref_desig:---->' || p_comp_ref_desig || '<---');
    IF (p_comp_ref_desig IS NOT NULL) THEN
      l_next_sep := INSTR(p_comp_ref_desig,',', 1, l_sep_count);
      IF l_next_sep = 0 THEN
        l_rds_tbl (l_sep_count) := Trim(p_comp_ref_desig);
        Write_debug(' RD No:' || l_sep_count ||':-->' || p_comp_ref_desig);
      ELSE
        WHILE l_next_sep > 0 LOOP
          l_rds_tbl (l_sep_count) := Trim(SUBSTR(p_comp_ref_desig,l_prev_sep,(l_next_Sep - l_prev_sep)));
          Write_debug(' RD No:' || l_sep_count ||':-->' || SUBSTR(p_comp_ref_desig,l_prev_sep,(l_next_Sep - l_prev_sep)));
          l_sep_count := l_sep_count + 1;
          l_prev_sep := l_next_sep + 1;
          l_next_sep := INSTR(p_comp_ref_desig,',', 1, l_sep_count);
        END LOOP;
        IF (l_sep_count > 1 )THEN
          l_rds_tbl (l_sep_count) := Trim(SUBSTR(p_comp_ref_desig,l_prev_sep));
          Write_debug(' RD No:' || l_sep_count ||':-->' || SUBSTR(p_comp_ref_desig,l_prev_sep));
        END IF;
      END IF;
    END IF;
    x_rd_tbl := l_rds_tbl;
  END splitIntoArray;

  -------------------------------------------------------------------
  -- Process Reference Designators --
  -------------------------------------------------------------------
  PROCEDURE getListOfRefDesigs (p_comp_ref_desig IN VARCHAR2,
                x_comp_ref_desig_tbl IN OUT NOCOPY RD_VARCHAR_TBL_TYPE)
  IS
    l_rd_tbl        RD_VARCHAR_TBL_TYPE;
    l_ref_desig_tbl RD_VARCHAR_TBL_TYPE;
    l_all_rd_count NUMBER;
    I NUMBER;
    -- Variables to support processing RDs with '-'
    l_rd_str VARCHAR2(30);
    l_rd_str_from VARCHAR2(30);
    l_rd_str_to VARCHAR2(30);
    l_prefix1 VARCHAR2(30);
    l_suffix1 VARCHAR2(30);
    l_prefix2 VARCHAR2(30);
    l_suffix2 VARCHAR2(30);
    l_ref_desig VARCHAR2(30);

    l_rd_sep_pos NUMBER;
    l_pre_num_start1 NUMBER;
    l_pre_num_end1 NUMBER;
    l_pre_num_start2 NUMBER;
    l_pre_num_end2 NUMBER;
    l_rd_num_from NUMBER;
    l_rd_num_to NUMBER;
    l_temp_num NUMBER;
    l_num_len NUMBER;

  BEGIN
    Write_Debug('Inside getListOfRefDesigs');
    --l_ref_desig_tbl := x_comp_ref_desig_tbl;
    l_all_rd_count := 0;
    splitIntoArray(p_comp_ref_desig => p_comp_ref_desig, x_rd_tbl => l_rd_tbl);

    FOR I IN 1..l_rd_tbl.COUNT LOOP
      --l_all_rd_count := l_all_rd_count + 1;
      --l_ref_desig_tbl(l_all_rd_count) := l_rd_tbl(I);
      -----------------
      l_rd_str := l_rd_tbl(I);
      l_rd_sep_pos := InStr(l_rd_str,'-');
      Write_Debug('Position:--->' || l_rd_sep_pos || ': Length:--->' ||  Length(l_rd_str));
      IF( l_rd_sep_pos > 0 AND Length(l_rd_str) > l_rd_sep_pos) THEN
        l_rd_str_from := SubStr(l_rd_str,0,(l_rd_sep_pos-1));
        l_rd_str_to   := SubStr(l_rd_str,(l_rd_sep_pos+1));
        Write_Debug('From:-->' || l_rd_str_from);
        Write_Debug('TO  :-->' || l_rd_str_to);
        l_temp_num := Length(l_rd_str_from);
        -- Get the prefix from the first part
        FOR I IN 1..l_temp_num LOOP
          IF(RD_isNumber(SubStr(l_rd_str_from,I,1))) THEN
            Write_Debug('Number start position:' || I);
            l_pre_num_start1 := I;
            EXIT;
          END IF;
        END LOOP;
        l_prefix1 := SubStr(l_rd_str_from,0,(l_pre_num_start1-1));
        l_pre_num_end1 := 0;
        Write_Debug('Prefix1:-->' || l_prefix1);
        -- Get the suffix from the first part
        FOR I IN l_pre_num_start1..l_temp_num LOOP
          IF(NOT RD_isNumber(SubStr(l_rd_str_from,I,1))) THEN
            Write_Debug('Suffix1 start position:' || I);
            l_pre_num_end1 := I;
            EXIT;
          END IF;
        END LOOP;
        IF(l_pre_num_end1 <> 0) THEN
          l_suffix1 := SubStr(l_rd_str_from,l_pre_num_end1);
          Write_Debug('Suffix1:-->' || l_suffix1);
          l_rd_num_from := To_Number(SubStr(l_rd_str_from,l_pre_num_start1,(l_pre_num_end1-l_pre_num_start1)));
        ELSE
          Write_Debug('Suffix1 IS NULL');
          l_rd_num_from := To_Number(SubStr(l_rd_str_from,l_pre_num_start1));
        END IF;
        Write_Debug('Ref Desigs From:-->' || l_rd_num_from);
        -- Get the prefix from the second part
        l_temp_num := Length(l_rd_str_to);
        FOR I IN 1..l_temp_num LOOP
          IF(RD_isNumber(SubStr(l_rd_str_to,I,1))) THEN
            Write_Debug('Number start position:' || I);
            l_pre_num_start2 := I;
            EXIT;
          END IF;
        END LOOP;
        l_prefix2 := SubStr(l_rd_str_to,0,(l_pre_num_start2-1));
        l_pre_num_end2 := 0;
        Write_Debug('Prefix2:-->' || l_prefix2);
        -- Get the suffix from the second part
        FOR I IN l_pre_num_start2..l_temp_num LOOP
          IF(NOT RD_isNumber(SubStr(l_rd_str_to,I,1))) THEN
            Write_Debug('Suffix2 start position:' || I);
            l_pre_num_end2 := I;
            EXIT;
          END IF;
        END LOOP;
        IF(l_pre_num_end2 <> 0) THEN
          l_suffix2 := SubStr(l_rd_str_to,l_pre_num_end2);
          Write_Debug('Suffix2:-->' || l_suffix2);
          l_rd_num_to := To_Number(SubStr(l_rd_str_to,l_pre_num_start2,(l_pre_num_end2-l_pre_num_start2)));
        ELSE
          Write_Debug('Suffix2 IS NULL');
          l_rd_num_to := To_Number(SubStr(l_rd_str_to,l_pre_num_start2));
        END IF;
        Write_Debug('Ref Desigs to:-->' || l_rd_num_to);
        -- Get the from and to values to generate the list RDs
        IF l_rd_num_from > l_rd_num_to THEN
          l_rd_num_from := l_rd_num_from + l_rd_num_to;
          l_rd_num_to := l_rd_num_from - l_rd_num_to;
          l_rd_num_from := l_rd_num_from - l_rd_num_to;
        END IF;
        Write_Debug('Ref Desigs From:-->' || l_rd_num_from);
        Write_Debug('Ref Desigs to:-->' || l_rd_num_to);
        l_num_len := l_pre_num_end1 - l_pre_num_start1;
        IF l_suffix1 IS NULL THEN
          l_num_len := Length(l_rd_str_from) - l_pre_num_start1 + 1;
        END IF;
        Write_Debug('Ref Desigs Num Char Length:-->' || l_num_len);
        IF(NOT (l_prefix1 <> l_prefix2 OR (l_suffix1 IS NOT NULL AND l_suffix1 <> l_suffix2) OR Length(l_rd_str_from) <> Length(l_rd_str_to))) THEN
          -- Generate the list
          FOR I IN l_rd_num_from..l_rd_num_to LOOP
            l_ref_desig := l_prefix1 || LPad(I,l_num_len,'0') || l_suffix1;
            l_all_rd_count := l_all_rd_count + 1;
            l_ref_desig_tbl(l_all_rd_count) := l_ref_desig;
            Write_Debug(' Reference Designator:' || I || '--->' || l_ref_desig);
          END LOOP;
        END IF;
      ELSE
        l_all_rd_count := l_all_rd_count + 1;
        l_ref_desig_tbl(l_all_rd_count) := l_rd_str;
      END IF;
    END LOOP;
    x_comp_ref_desig_tbl := l_ref_desig_tbl;
  END getListOfRefDesigs;


PROCEDURE PROCESS_BOM_INTERFACE_LINES
   (
     p_batch_id              IN         NUMBER,
     p_resultfmt_usage_id    IN         NUMBER,
     p_user_id               IN         NUMBER,
     p_conc_request_id       IN         NUMBER,
     p_language_code         IN         VARCHAR2,
     p_is_pdh_batch          IN         VARCHAR2,
     x_errbuff               IN OUT NOCOPY VARCHAR2,
     x_retcode               IN OUT NOCOPY VARCHAR2
    )
IS

--Type Declarations
  TYPE VARCHAR_TBL_TYPE IS TABLE OF VARCHAR2(256)
   INDEX BY BINARY_INTEGER;

--Sreejith


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
  l_lookup_type         VARCHAR_TBL_TYPE;

--Column Mappings
  l_prod_col_name       VARCHAR2(256);
  l_intf_col_name       VARCHAR2(256);
  l_parent_column       VARCHAR2(256);
  l_item_col_name       VARCHAR2(256);
  l_org_id_column       VARCHAR2(256);
  l_altbom_column       VARCHAR2(256);
  l_comp_seq_col_name   VARCHAR2(256);
  l_eff_date_col_name   VARCHAR2(256);
  l_dis_date_col_name   VARCHAR2(256);
  l_oper_seq_col_name   VARCHAR2(256);
  l_from_unit_col_name  VARCHAR2(256);
  l_item_seq_col_name   VARCHAR2(256);

--Txn Types

  G_TXN_CREATE          VARCHAR2(10) := 'CREATE';
  G_TXN_ADD             VARCHAR2(10) := 'ADD';
  G_TXN_UPDATE          VARCHAR2(10) := 'UPDATE';
  G_TXN_DELETE          VARCHAR2(10) := 'DELETE';
  G_TXN_SYNC            VARCHAR2(10) := 'SYNC';
  G_TXN_NO_OP          VARCHAR2(10) := 'NO_OP';

-- COLUMN NAMES
  G_ITEM_NAME           VARCHAR2(30) := 'ITEM_NUMBER';
  G_ORG_CODE            VARCHAR2(30) := 'ORGANIZATION_CODE';
  G_ALT_BOM             VARCHAR2(30) := 'ALTERNATE_BOM_DESIGNATOR';
  G_PARENT_NAME         VARCHAR2(30) := 'PARENT_NAME';
  G_QUANTITY            VARCHAR2(30) := 'QUANTITY';
  G_COMPONENT_SEQ_ID    VARCHAR2(30) := 'COMPONENT_SEQUENCE_ID';
  --Added by Hari to support import format
  G_OP_SEQ_NUMBER       VARCHAR2(30) := 'OperationSeqNum';
  G_EFFECTIVY_DATE      VARCHAR2(30) := 'EffectivityDate';
  G_DISABLE_DATE        VARCHAR2(30) := 'DisableDate';
  G_FROM_UNIT_EFFECTIVE VARCHAR2(30) := 'FromEndItemUnitNumber';
  G_ITEM_SEQUENCE       VARCHAR2(30) := 'ItemNum';


-- Bom Interface column names
  G_EFFECTIVITY_DATE    VARCHAR2(30) := 'EFFECTIVITY_DATE';
  G_OPERATION_SEQ_NUM   VARCHAR2(30) := 'OPERATION_SEQ_NUM';
  G_FROM_END_ITEM_UNIT_NUMBER   VARCHAR2(30) := 'FROM_END_ITEM_UNIT_NUMBER';

--Sreejith
  L_SRCSYS_PARENT VARCHAR2(240);

--Column Values
  L_ITEM_NAME           VARCHAR2(240) ;
  L_ORGANIZATION_CODE   VARCHAR2(3) ;
  L_STRUCTURE_NAME      VARCHAR2(10) ;
  L_PARENT_NAME         VARCHAR2(240) ;
  L_QUANTITY            NUMBER := 2;
  L_TRANSACTION_ID      NUMBER;
  L_STR_TYPE_NAME       VARCHAR2(80) ;
  L_EFFEC_CONTROL       VARCHAR2(80) ;
  L_IS_PREF_MEANING     VARCHAR2(80) ;
  L_ASSTYPE_MEANING     VARCHAR2(80) ;
  L_PARENT_REVISION     VARCHAR2(80) ; -- Bug No:5182523

-- Interface COLUMN NAMES
  G_INTF_STRUCT_NAME    VARCHAR2(30) := 'C_FIX_COLUMN3';
  G_INTF_STR_TYPE_NAME  VARCHAR2(30) := 'C_FIX_COLUMN5';
  G_INTF_EFFEC_CONTROL  VARCHAR2(30) := 'C_FIX_COLUMN7';
  G_INTF_IS_PREFERRED   VARCHAR2(30) := 'C_FIX_COLUMN8';
  G_INTF_ORG_CODE       VARCHAR2(30) := 'C_INTF_ATTR1';
  G_INTF_COMP_SEQ_ID    VARCHAR2(30) := 'N_INTF_ATTR1';
  G_INTF_ASSEMBLY_TYPE  VARCHAR2(30) := NULL;
  G_INTF_PARENT_REVISION VARCHAR2(30) := NULL; -- Bug No:5182523
  G_INTF_REVISION       VARCHAR2(30) := NULL; -- Bug No:5182523
  --Added by Hari to support import format
  G_BILL_SEQUENCE_ID    VARCHAR2(30) := 'INSTANCE_PK4_VALUE';
  G_COMP_SEQUENCE_ID    VARCHAR2(30) := 'INSTANCE_PK5_VALUE';
  G_ASSEMBLY_ITEM_ID    VARCHAR2(30) := 'C_INTF_ATTR226'; -- Ego people already used the cloumns from C_INTF_ATTR230
  G_INTF_REF_DESIG      VARCHAR2(30);

-- Temparory Variables
  l_Org_Id              NUMBER;
  l_Inv_Item_Id         NUMBER;
  l_Bill_Seq_Id         NUMBER;
  l_str                 VARCHAR2(3000);
  l_JCP_Id              NUMBER;
  l_eff_ctrl            VARCHAR2(240);
  l_is_preferred        VARCHAR2(240);
  l_assemblytype        NUMBER;
  l_str_type_id         NUMBER;

-- Error Handler variables
  l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
  l_Token_Tbl             Error_Handler.Token_Tbl_Type;

-- Constant Values
  G_DEL_GROUP_NAME    VARCHAR2(10)  := 'B_BLK_INTF';
  G_DEL_GROUP_DESC    VARCHAR2(240) := 'Delete Group for EGO BOM Bulkload Structures';

  l_bom_header_columns_tbl   DBMS_SQL.VARCHAR2_TABLE;

-- Variables for RDs
  L_SRCSYS_ITEM VARCHAR2(240);
  L_COMP_REF_DESIG   VARCHAR2(3000); --Changed size from 240 to 3000 support larger size of reference designators
  L_TRNSACTION_TYPE VARCHAR2(30);
  --
  l_comp_ref_desig_tbl   RD_VARCHAR_TBL_TYPE;

  -- Update sql variable for Multi Row
  l_upd_sql VARCHAR2(3000);


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
      bcc.Operation_Type,
      bcc.Lookup_Type
    FROM
      Ego_Results_Fmt_Usages erf,
      Bom_Component_Columns bcc
    WHERE
      (Region_Code = 'BOM_RESULT_DUMMY_REGION'
      OR -- Fix for import Region
      Region_Code = 'BOM_IMPORT_DUMMY_REGION' )
    AND
      Region_Application_Id = 702
    AND
      Customization_Application_Id = 431
    AND
      Resultfmt_Usage_Id = c_Resultfmt_Usage_Id
    AND
      bcc.Attribute_Code = erf.Attribute_Code
    AND
      bcc.OBJECT_TYPE = 'BOM_COMPONENTS'
    AND
      bcc.BOM_INTF_TABLE_NAME =  'BOM_INVENTORY_COMPS_INTERFACE'
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
      BOM_BILL_OF_MTLS_INTERFACE BMI
    WHERE
      PROCESS_FLAG = 1
    AND
      REQUEST_ID = C_REQUEST_ID
    AND
      BMI.Alternate_Bom_Designator IS NOT NULL
    AND NOT EXISTS
        (SELECT NULL FROM Bom_structures_b bsb
            WHERE bsb.Assembly_Item_id IN (SELECT Inventory_item_id FROM mtl_system_items_vl WHERE concatenated_segments = bmi.Item_number)
           AND bsb.Organization_id = (SELECT ORGANIZATION_ID FROM mtl_parameters WHERE ORGANIZATION_code = bmi.ORGANIZATION_code)
             AND  bsb.Alternate_Bom_Designator IS NULL
        );


BEGIN
    --Initializations
    l_debug := fnd_profile.value('MRP_DEBUG');
    IF (NVL(fnd_profile.value('CONC_REQUEST_ID'), 0) <> 0) THEN
      G_CONCREQ_VALID_FLAG  := TRUE;
    END IF;
    G_CONCREQ_VALID_FLAG  := TRUE;

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

    l_oper_seq_col_name := null;
    l_eff_date_col_name := null;
    l_dis_date_col_name := null;
    l_item_seq_col_name := null;


    Error_Handler.initialize();
    Error_Handler.set_bo_identifier(G_BO_IDENTIFIER);
--  Delete all the earlier uploads from the same spreadsheet.
   /*
    DELETE FROM  EGO_BULKLOAD_INTF
    WHERE RESULTFMT_USAGE_ID = p_resultfmt_usage_id
    AND PROCESS_STATUS <> 1;
*/


    /* Return if no rows to process
     *  Should we be updating the requestIds?? Test
     */
    if (NOT Interface_Rows_Exist(p_resultfmt_usage_id)) then
      FND_FILE.PUT_LINE( FND_FILE.LOG,'No Rows to Process for Data Separation' );
      return;
    end if;

    -- Getting the Intf_column names from the ego_results_fmt_usages for the attributes
    -- of OrgCode and CompSeqId. Previously we hard-coding them
    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'G_INTF_ORG_CODE before :--->' || G_INTF_ORG_CODE);
      FND_FILE.PUT_LINE( FND_FILE.LOG,'G_INTF_COMP_SEQ_ID before :--->' || G_INTF_COMP_SEQ_ID);
      FND_FILE.PUT_LINE( FND_FILE.LOG,'G_INTF_ASSEMBLY_TYPE before :--->' || G_INTF_ASSEMBLY_TYPE);
      FND_FILE.PUT_LINE( FND_FILE.LOG,'G_INTF_PARENT_REVISION before :--->' || G_INTF_PARENT_REVISION);
      FND_FILE.PUT_LINE( FND_FILE.LOG,'G_INTF_REVISION before :--->' || G_INTF_REVISION);
    END IF;

    Select INTF_COLUMN_NAME into G_INTF_ORG_CODE FROM Ego_Results_Fmt_Usages erf
    WHERE  Resultfmt_Usage_Id = p_Resultfmt_Usage_Id  AND ATTRIBUTE_CODE = 'ORGANIZATION_CODE';

    BEGIN -- In imort formats may not be having the attribute ComponentSequenceId
        Select INTF_COLUMN_NAME into G_INTF_COMP_SEQ_ID FROM Ego_Results_Fmt_Usages erf
        WHERE  Resultfmt_Usage_Id = p_Resultfmt_Usage_Id  AND ATTRIBUTE_CODE = 'COMPONENT_SEQUENCE_ID';
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        G_INTF_COMP_SEQ_ID := 'NULL';
    END;

    BEGIN
      Select INTF_COLUMN_NAME into G_INTF_ASSEMBLY_TYPE FROM Ego_Results_Fmt_Usages erf
      WHERE  Resultfmt_Usage_Id = p_Resultfmt_Usage_Id  AND ATTRIBUTE_CODE = 'SUB_ASSEMBLY_TYPE';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        G_INTF_ASSEMBLY_TYPE := 'NULL';
    END;

    BEGIN
      Select INTF_COLUMN_NAME into G_INTF_PARENT_REVISION FROM Ego_Results_Fmt_Usages erf
      WHERE  Resultfmt_Usage_Id = p_Resultfmt_Usage_Id  AND ATTRIBUTE_CODE = 'PARENT_REVISION_CODE';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        G_INTF_PARENT_REVISION := 'NULL';
    END;

    BEGIN
      Select INTF_COLUMN_NAME into G_INTF_REVISION FROM Ego_Results_Fmt_Usages erf
      WHERE  Resultfmt_Usage_Id = p_Resultfmt_Usage_Id  AND ATTRIBUTE_CODE = 'REVISION';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        G_INTF_REVISION := 'NULL';
    END;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'G_INTF_ORG_CODE after :--->' || G_INTF_ORG_CODE);
      FND_FILE.PUT_LINE( FND_FILE.LOG,'G_INTF_COMP_SEQ_ID after :--->' || G_INTF_COMP_SEQ_ID);
      FND_FILE.PUT_LINE( FND_FILE.LOG,'G_INTF_ASSEMBLY_TYPE after :--->' || G_INTF_ASSEMBLY_TYPE);
      FND_FILE.PUT_LINE( FND_FILE.LOG,'G_INTF_PARENT_REVISION after :--->' || G_INTF_PARENT_REVISION);
      FND_FILE.PUT_LINE( FND_FILE.LOG,'G_INTF_REVISION after :--->' || G_INTF_REVISION);
    END IF;

    BEGIN -- In imort formats may not be having the attribute COMPONENT_REFERENCE_DESIGNATOR
        Select INTF_COLUMN_NAME into G_INTF_REF_DESIG FROM Ego_Results_Fmt_Usages erf
        WHERE  Resultfmt_Usage_Id = p_Resultfmt_Usage_Id  AND ATTRIBUTE_CODE = 'COMPONENT_REFERENCE_DESIGNATOR';
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        G_INTF_REF_DESIG := 'NULL';
    END;
    Write_Debug('G_INTF_REF_DESIG after :--->' || G_INTF_REF_DESIG);
    --Populate the Transaction IDs for current result fmt usage ID
     --New Transaction ID. It will be replaced by old Transaction ID Seq.
     --SET  transaction_id = MSII_TRANSACTION_ID_S.NEXTVAL
    UPDATE EGO_BULKLOAD_INTF
     SET  Transaction_Id = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
    WHERE  Resultfmt_Usage_Id = p_Resultfmt_Usage_Id AND PROCESS_STATUS = 1 ;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering First Loop ');
    END IF;

--Sreejith

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
      l_lookup_type(i)       := C_BOM_ATTRIBUTE_COLUMNS_REC.LOOKUP_TYPE;

      IF (C_BOM_ATTRIBUTE_COLUMNS_REC.ATTRIBUTE_CODE = G_PARENT_NAME) THEN
        l_parent_column := C_BOM_ATTRIBUTE_COLUMNS_REC.INTF_COLUMN_NAME;
      END IF;
      IF (C_BOM_ATTRIBUTE_COLUMNS_REC.ATTRIBUTE_CODE = G_ITEM_NAME) THEN
        l_item_col_name := C_BOM_ATTRIBUTE_COLUMNS_REC.INTF_COLUMN_NAME;
      END IF;
      IF (C_BOM_ATTRIBUTE_COLUMNS_REC.ATTRIBUTE_CODE = G_EFFECTIVY_DATE) THEN
        l_eff_date_col_name := C_BOM_ATTRIBUTE_COLUMNS_REC.INTF_COLUMN_NAME;
      END IF;
      IF (C_BOM_ATTRIBUTE_COLUMNS_REC.ATTRIBUTE_CODE = G_DISABLE_DATE) THEN
        l_dis_date_col_name := C_BOM_ATTRIBUTE_COLUMNS_REC.INTF_COLUMN_NAME;
      END IF;
      IF (C_BOM_ATTRIBUTE_COLUMNS_REC.ATTRIBUTE_CODE = G_OP_SEQ_NUMBER) THEN
        l_oper_seq_col_name := C_BOM_ATTRIBUTE_COLUMNS_REC.INTF_COLUMN_NAME;
      END IF;
      IF (C_BOM_ATTRIBUTE_COLUMNS_REC.ATTRIBUTE_CODE = G_FROM_UNIT_EFFECTIVE) THEN
        l_from_unit_col_name := C_BOM_ATTRIBUTE_COLUMNS_REC.INTF_COLUMN_NAME;
      END IF;
      IF (C_BOM_ATTRIBUTE_COLUMNS_REC.ATTRIBUTE_CODE = G_ITEM_SEQUENCE) THEN
        l_item_seq_col_name := C_BOM_ATTRIBUTE_COLUMNS_REC.INTF_COLUMN_NAME;
      END IF;
      i := i+1;
    END LOOP;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Exiting First Loop ');
    END IF;

   -- Added by hgelli for supporting import formats
   -----------------------------------------------------
   -- Update Instance PK2 Value with ORG ID.
   -----------------------------------------------------
   l_dyn_sql := '';
   l_dyn_sql :=              'UPDATE EGO_BULKLOAD_INTF EBI';
   l_dyn_sql := l_dyn_sql || '  SET INSTANCE_PK2_VALUE = ';
   l_dyn_sql := l_dyn_sql || '  (                                           ';
   l_dyn_sql := l_dyn_sql || '    SELECT ORGANIZATION_ID                    ';
   l_dyn_sql := l_dyn_sql || '    FROM   MTL_PARAMETERS                     ';
   l_dyn_sql := l_dyn_sql || '    WHERE  ORGANIZATION_CODE =EBI.'|| G_INTF_ORG_CODE;
   l_dyn_sql := l_dyn_sql || '  )                                           ';
   l_dyn_sql := l_dyn_sql || 'WHERE  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
   l_dyn_sql := l_dyn_sql || ' AND   PROCESS_STATUS = 1                     ';

   Write_Debug('Org Id Conversion-->' || l_dyn_sql);

   EXECUTE IMMEDIATE l_dyn_sql USING p_Resultfmt_Usage_Id;

   -----------------------------------------------------
   -- Update Instance PK1 Value with Component Item ID
   -----------------------------------------------------
   l_dyn_sql := '';
   l_dyn_sql :=              'UPDATE EGO_BULKLOAD_INTF EBI';
   l_dyn_sql := l_dyn_sql || '  SET INSTANCE_PK1_VALUE = ';
   l_dyn_sql := l_dyn_sql || '  (                                           ';
   l_dyn_sql := l_dyn_sql || '    SELECT inventory_item_id                  ';
   l_dyn_sql := l_dyn_sql || '    FROM  mtl_system_items_vl mvll            ';
   l_dyn_sql := l_dyn_sql || '    WHERE  mvll.concatenated_segments = EBI.'|| l_item_col_name;
   l_dyn_sql := l_dyn_sql || '      AND  mvll.organization_id = EBI.INSTANCE_PK2_VALUE';
   l_dyn_sql := l_dyn_sql || '  )                                           ';
   l_dyn_sql := l_dyn_sql || 'WHERE  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
   l_dyn_sql := l_dyn_sql || ' AND   PROCESS_STATUS = 1                     ';

   Write_Debug('Component Item Id Conversion-->' || l_dyn_sql);

   EXECUTE IMMEDIATE l_dyn_sql USING p_Resultfmt_Usage_Id;

   -----------------------------------------------------
   -- Populate Assembly Item ID
   -----------------------------------------------------
   l_dyn_sql := '';
   l_dyn_sql :=              'UPDATE EGO_BULKLOAD_INTF EBI';
   l_dyn_sql := l_dyn_sql || '  SET ' || G_ASSEMBLY_ITEM_ID || ' = ';
   l_dyn_sql := l_dyn_sql || '  (                                           ';
   l_dyn_sql := l_dyn_sql || '    SELECT inventory_item_id                  ';
   l_dyn_sql := l_dyn_sql || '    FROM  mtl_system_items_vl mvll            ';
   l_dyn_sql := l_dyn_sql || '    WHERE  mvll.concatenated_segments = EBI.'|| l_parent_column;
   l_dyn_sql := l_dyn_sql || '      AND  mvll.organization_id = EBI.INSTANCE_PK2_VALUE';
   l_dyn_sql := l_dyn_sql || '  )                                           ';
   l_dyn_sql := l_dyn_sql || 'WHERE  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
   l_dyn_sql := l_dyn_sql || ' AND   PROCESS_STATUS = 1                     ';

   Write_Debug('Assembly Item Id Conversion-->' || l_dyn_sql);

   EXECUTE IMMEDIATE l_dyn_sql USING p_Resultfmt_Usage_Id;

   -----------------------------------------------------
   -- Populate BillSequenceId to Instance PK4
   -----------------------------------------------------
   l_dyn_sql := '';
   l_dyn_sql :=              'UPDATE EGO_BULKLOAD_INTF EBI';
   l_dyn_sql := l_dyn_sql || '  SET INSTANCE_PK4_VALUE = ';
   l_dyn_sql := l_dyn_sql || '  (                                           ';
   l_dyn_sql := l_dyn_sql || '    SELECT bill_sequence_id                  ';
   l_dyn_sql := l_dyn_sql || '    FROM  bom_structures_b bsb, mtl_system_items_vl mvll            ';
   l_dyn_sql := l_dyn_sql || '    WHERE  mvll.concatenated_segments = EBI.'|| l_parent_column;
   l_dyn_sql := l_dyn_sql || '      AND  mvll.organization_id = EBI.INSTANCE_PK2_VALUE';
   l_dyn_sql := l_dyn_sql || '      AND  bsb.assembly_item_id = mvll.inventory_item_id';
   l_dyn_sql := l_dyn_sql || '      AND  bsb.organization_id = mvll.organization_id';
   l_dyn_sql := l_dyn_sql || '      AND  NVL(bsb.alternate_bom_designator,Bom_Globals.Retrieve_Message(''BOM'', ''BOM_PRIMARY'')) = EBI.' || G_INTF_STRUCT_NAME ;
   l_dyn_sql := l_dyn_sql || '  )                                           ';
   l_dyn_sql := l_dyn_sql || 'WHERE  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
   l_dyn_sql := l_dyn_sql || ' AND   PROCESS_STATUS = 1                     ';

   Write_Debug('Bill Sequence Id Conversion-->' || l_dyn_sql);

   EXECUTE IMMEDIATE l_dyn_sql USING p_Resultfmt_Usage_Id;

--------------------------------------------------------------
-- Resolve user time zone conversions
  fnd_date_tz.init_timezones_for_fnd_date;
  IF (l_eff_date_col_name IS NOT NULL OR l_dis_date_col_name IS NOT NULL ) THEN
     l_dyn_sql := '';
     l_dyn_sql :=              'UPDATE EGO_BULKLOAD_INTF EBI SET';
  IF l_eff_date_col_name IS NOT NULL THEN
     l_dyn_sql := l_dyn_sql || '  EBI.'|| l_eff_date_col_name;
     l_dyn_sql := l_dyn_sql || '  = decode(EBI.'|| l_eff_date_col_name || ', NULL, NULL,';
     l_dyn_sql := l_dyn_sql || ' to_char(fnd_date.displayDT_to_date(EBI.' || l_eff_date_col_name;
     l_dyn_sql := l_dyn_sql || ' ),''DD-MON-YYYY HH24:MI:SS'')) ' ;
  END IF;
  IF l_dis_date_col_name IS NOT NULL THEN
     IF l_eff_date_col_name IS NOT NULL THEN
       l_dyn_sql := l_dyn_sql || ' , ' ;
     END IF;
     l_dyn_sql := l_dyn_sql || '  EBI.'|| l_dis_date_col_name;
     l_dyn_sql := l_dyn_sql || '  = decode(EBI.'|| l_dis_date_col_name || ', NULL, NULL,';
     l_dyn_sql := l_dyn_sql || ' to_char(fnd_date.displayDT_to_date(EBI.' || l_dis_date_col_name;
     l_dyn_sql := l_dyn_sql || ' ),''DD-MON-YYYY HH24:MI:SS'')) ' ;
  END IF;
     l_dyn_sql := l_dyn_sql || ' WHERE  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
     l_dyn_sql := l_dyn_sql || ' AND   PROCESS_STATUS = 1                     ';
   Write_Debug(' TIMEZONE conversion stuff ' || l_dyn_sql);

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,' TIMEZONE conversion stuff ' || l_dyn_sql);
    END IF;

   EXECUTE IMMEDIATE l_dyn_sql USING p_Resultfmt_Usage_Id;
  END IF;
--------------------------------------------------------------

   -----------------------------------------------------
   -- Populate ComponentSequenceId to Instance PK5
   -----------------------------------------------------
   IF l_eff_date_col_name IS NOT NULL AND l_oper_seq_col_name IS NOT NULL AND l_oper_seq_col_name <> '' AND l_eff_date_col_name <> '' THEN
     l_dyn_sql := '';
     l_dyn_sql :=              'UPDATE EGO_BULKLOAD_INTF EBI';
     l_dyn_sql := l_dyn_sql || '  SET INSTANCE_PK5_VALUE = ';
     l_dyn_sql := l_dyn_sql || '  (                                           ';
     l_dyn_sql := l_dyn_sql || '    SELECT COMPONENT_SEQUENCE_ID                  ';
     l_dyn_sql := l_dyn_sql || '    FROM  bom_components_b BCB            ';
     l_dyn_sql := l_dyn_sql || '    WHERE  BCB.bill_sequence_id = EBI.INSTANCE_PK4_VALUE';
     l_dyn_sql := l_dyn_sql || '      AND  BCB.component_item_id = EBI.INSTANCE_PK1_VALUE';
     l_dyn_sql := l_dyn_sql || '      AND  BCB.operation_seq_num = EBI.'|| l_oper_seq_col_name;
     l_dyn_sql := l_dyn_sql || '      AND  BCB.effectivity_date = EBI.'|| l_eff_date_col_name;
     l_dyn_sql := l_dyn_sql || '  )                                           ';
     l_dyn_sql := l_dyn_sql || 'WHERE  RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
     l_dyn_sql := l_dyn_sql || ' AND   PROCESS_STATUS = 1                     ';

   Write_Debug('Component Sequence Id Conversion-->' || l_dyn_sql);

   EXECUTE IMMEDIATE l_dyn_sql USING p_Resultfmt_Usage_Id;
   END IF;
   -- end Added by hgelli for supporting import formats

-- Process The Rows for BOM BO Header For Create and Update.
    l_dyn_sql_insert := '';
    l_dyn_sql_insert := l_dyn_sql_insert || 'INSERT INTO BOM_BILL_OF_MTLS_INTERFACE (BATCH_ID';
    l_dyn_sql_insert := l_dyn_sql_insert || ' , SOURCE_SYSTEM_REFERENCE ';
    l_dyn_sql_insert := l_dyn_sql_insert || ' , SOURCE_SYSTEM_REFERENCE_DESC ';
    l_dyn_sql_insert := l_dyn_sql_insert || ' , REQUEST_ID, Transaction_Type ';
    l_dyn_sql_insert := l_dyn_sql_insert || ' , Transaction_Id, Process_Flag, Item_Number ';
    l_dyn_sql_insert := l_dyn_sql_insert || ' , Organization_Code, Alternate_Bom_Designator, Structure_Type_Name, Effectivity_Control, Is_Preferred, assembly_type, Revision) ';

    l_dyn_sql_select := '';
    l_dyn_sql_select := l_dyn_sql_select || ' SELECT ' || P_BATCH_ID || ', C_FIX_COLUMN12,  C_FIX_COLUMN13 ';
    l_dyn_sql_select := l_dyn_sql_select || ' , REQUEST_ID, Transaction_Type, Transaction_Id, 1, ' || l_item_col_name;
    l_dyn_sql_select := l_dyn_sql_select || ' , ' || G_INTF_ORG_CODE;
    l_dyn_sql_select := l_dyn_sql_select || ' , DECODE(' || 'DECODE(' || G_INTF_STRUCT_NAME
                                         || ',null,(select decode(structure_name,BOM_GLOBALS.GET_PRIMARY_UI,null,structure_name) from ego_import_option_sets where batch_id = '
                                         ||' :1 ),'|| G_INTF_STRUCT_NAME|| ')'
                                         || ',Bom_Globals.Retrieve_Message(''BOM'', ''BOM_PRIMARY''),NULL,'
                                         || 'DECODE(' || G_INTF_STRUCT_NAME || ',null,(select decode(structure_name,BOM_GLOBALS.GET_PRIMARY_UI,null,structure_name) from ego_import_option_sets where batch_id = '
                                         ||' :2 ),'|| G_INTF_STRUCT_NAME|| ')' || ')';
    l_dyn_sql_select := l_dyn_sql_select || ' , ' || 'DECODE(' || G_INTF_STR_TYPE_NAME
                                         ||',null,(SELECT BSTV.structure_type_name from bom_structure_types_vl BSTV,ego_import_option_sets EIOS WHERE EIOS.batch_id =  '
                                         || ' :3 AND BSTV.structure_type_id = EIOS.structure_type_id ),' || G_INTF_STR_TYPE_NAME || ' )';
    l_dyn_sql_select := l_dyn_sql_select || ' , (SELECT Lookup_Code FROM Fnd_Lookup_Values  WHERE Lookup_Type = ''BOM_EFFECTIVITY_CONTROL'' AND LANGUAGE=USERENV(''LANG'') AND Meaning=' || G_INTF_EFFEC_CONTROL || ')';
    l_dyn_sql_select := l_dyn_sql_select || ' , (SELECT Lookup_Code FROM Fnd_Lookup_Values  WHERE Lookup_Type = ''EGO_YES_NO'' AND LANGUAGE=USERENV(''LANG'') AND Meaning = ' || G_INTF_IS_PREFERRED ||  ')';
    l_dyn_sql_select := l_dyn_sql_select || ' , (SELECT Lookup_Code FROM Mfg_Lookups  WHERE Lookup_Type = ''BOM_ASSEMBLY_TYPE'' AND Meaning=' || G_INTF_ASSEMBLY_TYPE || ')';
    l_dyn_sql_select := l_dyn_sql_select || ' , ' || G_INTF_REVISION || ' ';
    l_dyn_sql_select := l_dyn_sql_select || ' FROM EGO_BULKLOAD_INTF WHERE RESULTFMT_USAGE_ID = :4 ';
--Sreejith
    if (p_is_pdh_batch = 'Y') then
      l_dyn_sql_select := l_dyn_sql_select || ' AND  PROCESS_STATUS = 1 AND ' || l_parent_column || ' IS NULL ';
    else
       l_dyn_sql_select := l_dyn_sql_select || ' AND  PROCESS_STATUS = 1 AND ' ||   G_INTF_SRCSYS_PARENT || ' IS NULL ';
    end if;

    l_dyn_sql := l_dyn_sql_insert || ' ' || l_dyn_sql_select;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering First SQL 1-->' || l_dyn_sql);
    END IF;

    EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id,p_batch_id,p_batch_id,p_resultfmt_usage_id;

-- Header Data Ready

-- Process Components for CREATE/ADD
  -- Create Structure Header record if that is not available.
  -- Comment this block if it is not required.
    l_dyn_sql_cursor := '';
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' SELECT Distinct ' ;
    l_dyn_sql_cursor := l_dyn_sql_cursor || G_INTF_SRCSYS_PARENT || ' , ' || l_parent_column ;
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' , ' || G_INTF_ORG_CODE;
    l_dyn_sql_cursor := l_dyn_sql_cursor || ', DECODE(' || 'DECODE(' || G_INTF_STRUCT_NAME
                                         || ',null,(select decode(structure_name,BOM_GLOBALS.GET_PRIMARY_UI,null,structure_name) from ego_import_option_sets where batch_id =  '
                                         || ' :1 ),'|| G_INTF_STRUCT_NAME|| ')'  || ', Bom_Globals.Retrieve_Message(''BOM'', ''BOM_PRIMARY''),NULL,'
                                         || 'DECODE(' || G_INTF_STRUCT_NAME || ',null,(select decode(structure_name,BOM_GLOBALS.GET_PRIMARY_UI,null,structure_name) from ego_import_option_sets where batch_id = '
                                         ||' :2 ),'|| G_INTF_STRUCT_NAME|| ')'
                                         || ')';
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' , ' || 'DECODE(' || G_INTF_STR_TYPE_NAME
                                         ||',null,(SELECT BSTV.structure_type_name from bom_structure_types_vl BSTV,ego_import_option_sets EIOS WHERE EIOS.batch_id = '
                                         || ' :3  AND BSTV.structure_type_id = EIOS.structure_type_id ),' || G_INTF_STR_TYPE_NAME || ' )';
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' , ' || G_INTF_EFFEC_CONTROL;
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' , ' || G_INTF_IS_PREFERRED;
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' , ' || G_INTF_ASSEMBLY_TYPE;
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' , ' || G_INTF_PARENT_REVISION;
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' , Transaction_Id ';
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' FROM EGO_BULKLOAD_INTF WHERE Process_Status = 1';
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' AND Resultfmt_Usage_Id = :4 ';
    if (p_is_pdh_batch = 'Y') then
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' AND ' || l_parent_column || ' IS NOT NULL ';
    else
     l_dyn_sql_cursor := l_dyn_sql_cursor || ' AND ' || G_INTF_SRCSYS_PARENT || ' IS NOT NULL ';
    end if;
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' AND ( UPPER(Transaction_Type) = ''' || G_TXN_CREATE || ''' OR  UPPER(Transaction_Type) = ''' || G_TXN_ADD || ''' ';
    l_dyn_sql_cursor := l_dyn_sql_cursor || ' OR UPPER(Transaction_Type) = ''' || G_TXN_SYNC || ''' )';

    IF G_INTF_ASSEMBLY_TYPE IS NOT NULL THEN
      l_dyn_sql_cursor := l_dyn_sql_cursor || ' ORDER BY ' || G_INTF_ASSEMBLY_TYPE || ' ';
    END IF;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering SQL 2.1-->' || l_dyn_sql_cursor);
    END IF;


    l_cursor_select := Dbms_Sql.Open_Cursor;
    Dbms_Sql.Parse(l_cursor_select, l_dyn_sql_cursor, Dbms_Sql.NATIVE);
    Dbms_Sql.Define_Column(l_cursor_select, 1, L_SRCSYS_PARENT,3000);
    Dbms_Sql.Define_Column(l_cursor_select, 2, L_PARENT_NAME, 3000);
    Dbms_Sql.Define_Column(l_cursor_select, 3, L_ORGANIZATION_CODE, 10);
    Dbms_Sql.Define_Column(l_cursor_select, 4, L_STRUCTURE_NAME, 240);
    Dbms_Sql.Define_Column(l_cursor_select, 5, L_STR_TYPE_NAME, 240);
    Dbms_Sql.Define_Column(l_cursor_select, 6, L_EFFEC_CONTROL, 240);
    Dbms_Sql.Define_Column(l_cursor_select, 7, L_IS_PREF_MEANING, 80);
    Dbms_Sql.Define_Column(l_cursor_select, 8, L_ASSTYPE_MEANING, 80);
    Dbms_Sql.Define_Column(l_cursor_select, 9, L_PARENT_REVISION, 80);
    Dbms_Sql.Define_Column(l_cursor_select, 10, L_TRANSACTION_ID);

    Dbms_Sql.Bind_Variable(l_cursor_select,':1', p_batch_id);
    Dbms_Sql.Bind_Variable(l_cursor_select,':2', p_batch_id);
    Dbms_Sql.Bind_Variable(l_cursor_select,':3', p_batch_id);
    Dbms_Sql.Bind_Variable(l_cursor_select,':4', p_resultfmt_usage_id);

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering SQL 2.2-->' || p_resultfmt_usage_id);
    END IF;

    l_cursor_execute := Dbms_Sql.EXECUTE(l_cursor_select);

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'SUCCESS');
    END IF;
    i := 1;
    LOOP
      IF (Dbms_Sql.Fetch_Rows(l_cursor_select) > 0) THEN
        Dbms_Sql.Column_Value(l_cursor_select,1,L_SRCSYS_PARENT);
        Dbms_Sql.Column_Value(l_cursor_select,2,L_PARENT_NAME);
        Dbms_Sql.Column_Value(l_cursor_select,3,L_ORGANIZATION_CODE);
        Dbms_Sql.Column_Value(l_cursor_select,4,L_STRUCTURE_NAME);
        Dbms_Sql.Column_Value(l_cursor_select,5,L_STR_TYPE_NAME);
        Dbms_Sql.Column_Value(l_cursor_select,6,L_EFFEC_CONTROL);
        Dbms_Sql.Column_Value(l_cursor_select,7,L_IS_PREF_MEANING);
        Dbms_Sql.Column_Value(l_cursor_select,8,L_ASSTYPE_MEANING);
        Dbms_Sql.Column_Value(l_cursor_select,9,L_PARENT_REVISION);
        Dbms_Sql.Column_Value(l_cursor_select,10,L_TRANSACTION_ID);

        IF L_EFFEC_CONTROL IS NOT NULL
        THEN
          SELECT
            Lookup_Code
          INTO
            l_eff_ctrl
          FROM
            Fnd_Lookup_Values
          WHERE
            Lookup_Type = 'BOM_EFFECTIVITY_CONTROL' AND LANGUAGE=USERENV('LANG') AND Meaning=L_EFFEC_CONTROL;
        ELSE
          l_eff_ctrl := null;
        END IF;
      IF L_IS_PREF_MEANING IS NOT NULL
      THEN
        SELECT
          Lookup_Code
        INTO
          l_is_preferred
        FROM
          Fnd_Lookup_Values
        WHERE
          Lookup_Type = 'EGO_YES_NO' AND LANGUAGE=USERENV('LANG') AND Meaning=L_IS_PREF_MEANING;
      ELSE
        l_is_preferred := null;
      END IF;

      IF L_ASSTYPE_MEANING IS NOT NULL
      THEN
        SELECT
          Lookup_Code
        INTO
          l_assemblytype
        FROM
          Mfg_Lookups
        WHERE
          Lookup_Type = 'BOM_ASSEMBLY_TYPE' AND Meaning=L_ASSTYPE_MEANING;
      ELSE
        l_assemblytype := 2;
      END IF;

  --bug 4777796 adding the structure type id also in the Get_Bill_Sequence; removed logic

        l_Org_Id := Get_Organization_Id(L_ORGANIZATION_CODE);
        l_Inv_Item_Id := Component_Item(l_Org_Id,L_PARENT_NAME);
        l_Bill_Seq_Id := Bill_Sequence(l_Inv_Item_Id,L_STRUCTURE_NAME,l_Org_Id);

        IF(l_Bill_Seq_Id IS NULL) THEN
          INSERT INTO BOM_BILL_OF_MTLS_INTERFACE (
            BATCH_ID,
            REQUEST_ID,
            TRANSACTION_TYPE,
            TRANSACTION_ID,
            PROCESS_FLAG,
            ITEM_NUMBER,
            ORGANIZATION_CODE,
            ALTERNATE_BOM_DESIGNATOR,
            STRUCTURE_TYPE_NAME,
            EFFECTIVITY_CONTROL,
            IS_PREFERRED ,
            assembly_type,
            REVISION,
            SOURCE_SYSTEM_REFERENCE )
        select
            p_batch_id,
            G_REQUEST_ID,
            G_TXN_SYNC,
            L_TRANSACTION_ID,
            1,
            L_PARENT_NAME,
            L_ORGANIZATION_CODE,
            L_STRUCTURE_NAME,
            L_STR_TYPE_NAME,
            l_eff_ctrl,
            l_is_preferred,
            l_assemblytype,
            L_PARENT_REVISION,
            L_SRCSYS_PARENT from dual
         where not exists
         (select 'X' from bom_bill_of_mtls_interface
          where
              batch_id    = p_batch_id
          and request_id  = g_request_id
          and process_flag = 1
          and ( (ITEM_NUMBER IS NOT NULL AND ITEM_NUMBER = L_PARENT_NAME) OR  (SOURCE_SYSTEM_REFERENCE IS NOT NULL AND SOURCE_SYSTEM_REFERENCE=L_SRCSYS_PARENT))
          and ORGANIZATION_CODE = L_ORGANIZATION_CODE
          and nvl(ALTERNATE_BOM_DESIGNATOR,'000') = nvl(L_STRUCTURE_NAME,'000')
          and nvl(STRUCTURE_TYPE_NAME,'000') = nvl(L_STR_TYPE_NAME,'000')
          and nvl(EFFECTIVITY_CONTROL,'000') = nvl(l_eff_ctrl,'000') );

        ELSE
          INSERT INTO BOM_BILL_OF_MTLS_INTERFACE (
                    BATCH_ID,
                    REQUEST_ID,
                    TRANSACTION_TYPE,
                    TRANSACTION_ID,
                    PROCESS_FLAG,
                    ITEM_NUMBER,
                    ORGANIZATION_CODE,
                    ALTERNATE_BOM_DESIGNATOR,
                    STRUCTURE_TYPE_NAME,
                    EFFECTIVITY_CONTROL,
                    IS_PREFERRED ,
                    assembly_type,
                    REVISION,
                    SOURCE_SYSTEM_REFERENCE )
                select
                    p_batch_id,
                    G_REQUEST_ID,
                    G_TXN_NO_OP,
                    L_TRANSACTION_ID,
                    1,
                    L_PARENT_NAME,
                    L_ORGANIZATION_CODE,
                    L_STRUCTURE_NAME,
                    L_STR_TYPE_NAME,
                    l_eff_ctrl,
                    l_is_preferred,
                    l_assemblytype,
                    L_PARENT_REVISION,
                    L_SRCSYS_PARENT from dual
         where not exists
         (select 'X' from bom_bill_of_mtls_interface
          where
              batch_id    = p_batch_id
          and request_id  = g_request_id
          and process_flag = 1
          and ( (ITEM_NUMBER IS NOT NULL AND ITEM_NUMBER = L_PARENT_NAME) OR  (SOURCE_SYSTEM_REFERENCE IS NOT NULL AND SOURCE_SYSTEM_REFERENCE=L_SRCSYS_PARENT))
          and ORGANIZATION_CODE = L_ORGANIZATION_CODE
          and nvl(ALTERNATE_BOM_DESIGNATOR,'000') = nvl(L_STRUCTURE_NAME,'000')
          and nvl(STRUCTURE_TYPE_NAME,'000') = nvl(L_STR_TYPE_NAME,'000')
          and nvl(EFFECTIVITY_CONTROL,'000') = nvl(l_eff_ctrl,'000') );
        END IF;
        i := i+ 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;

/* Header complete */
    --poplulating to see see errors
-- Process Components for UPDATE
    l_dyn_sql_insert := '';
    l_dyn_sql_insert := l_dyn_sql_insert || 'INSERT INTO BOM_INVENTORY_COMPS_INTERFACE ( BATCH_ID, ';
    l_dyn_sql_insert := l_dyn_sql_insert || ' COMP_SOURCE_SYSTEM_REFERENCE, COMP_SOURCE_SYSTEM_REFER_DESC,';
    l_dyn_sql_insert := l_dyn_sql_insert || ' PARENT_SOURCE_SYSTEM_REFERENCE, REQUEST_ID, Transaction_Type,';
    l_dyn_sql_insert := l_dyn_sql_insert || ' Transaction_Id, Process_Flag, ';
    l_dyn_sql_insert := l_dyn_sql_insert || 'ORGANIZATION_CODE, ALTERNATE_BOM_DESIGNATOR, COMPONENT_SEQUENCE_ID, PARENT_REVISION_CODE, ';
    l_dyn_sql_select := '';
    l_dyn_sql_select := l_dyn_sql_select || 'SELECT ' || P_BATCH_ID || ' , ' || G_INTF_SRCSYS_COMPONENT ;
    l_dyn_sql_select := l_dyn_sql_select || ', ' || G_INTF_SRCSYS_DESCRIPTION || ' , ' || G_INTF_SRCSYS_PARENT ;
    l_dyn_sql_select := l_dyn_sql_select || ' , REQUEST_ID, TRANSACTION_TYPE, Transaction_Id, 1, ' || G_INTF_ORG_CODE || ', ';
    l_dyn_sql_select := l_dyn_sql_select || ' DECODE(' || 'DECODE(' || G_INTF_STRUCT_NAME
                                         || ',null,(select decode(structure_name,BOM_GLOBALS.GET_PRIMARY_UI,null,structure_name) from ego_import_option_sets where batch_id = '
                                         || ' :1 ),'|| G_INTF_STRUCT_NAME|| ')'  || ', Bom_Globals.Retrieve_Message(''BOM'', ''BOM_PRIMARY''),NULL,'
                                         || 'DECODE(' || G_INTF_STRUCT_NAME || ',null,(select decode(structure_name,BOM_GLOBALS.GET_PRIMARY_UI,null,structure_name) from ego_import_option_sets where batch_id = '
                                         ||' :2 ),'|| G_INTF_STRUCT_NAME|| ')) ,';
    l_dyn_sql_select := l_dyn_sql_select || G_INTF_COMP_SEQ_ID || ', ' || G_INTF_PARENT_REVISION || ', ';

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
            ELSIF (l_lookup_type(i) IS NOT NULL) THEN
              l_str := '(SELECT LOOKUP_CODE FROM FND_LOOKUP_VALUES WHERE ';
              l_str := l_str || ' LOOKUP_TYPE = ''' || l_lookup_type(i) ||''' AND LANGUAGE = USERENV(''LANG'') AND MEANING=' || l_intf_col_name_tbl(i) ||' ),';
              l_dyn_sql_select := l_dyn_sql_select || l_str;
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
    l_dyn_sql_select := l_dyn_sql_select || ' WHERE RESULTFMT_USAGE_ID = :3 ';
    l_dyn_sql_select := l_dyn_sql_select || ' AND PROCESS_STATUS = 1 AND ';

    if (p_is_pdh_batch = 'Y') then
     l_dyn_sql_select := l_dyn_sql_select || l_parent_column || ' IS NOT NULL ';
    else
       l_dyn_sql_select := l_dyn_sql_select || G_INTF_SRCSYS_PARENT || ' IS NOT NULL ';
    end if;
--  Sreejith

    l_dyn_sql_select := l_dyn_sql_select || ' AND ( UPPER(Transaction_Type) = ''' || G_TXN_UPDATE || ''' OR UPPER(Transaction_Type) = ''' || G_TXN_SYNC || ''') ';
--    l_dyn_sql_select := l_dyn_sql_select || ' AND Transaction_Type = ''' || G_TXN_UPDATE || ''' ';

    l_dyn_sql := l_dyn_sql_insert || ' ' || l_dyn_sql_select;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering SQL 2 -->' || l_dyn_sql);
    END IF;


    EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id,p_batch_id,p_resultfmt_usage_id;
-- End of Process Components for UPDATE
      IF l_debug = 'Y' THEN
        FND_FILE.PUT_LINE( FND_FILE.LOG,'Executed Succesfully 2');
      END IF;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering SQL 3-->' || l_dyn_sql);
    END IF;


    Dbms_Sql.Close_Cursor(l_cursor_select);
  -- End of Creating Structure Header record if that is not available.

    l_dyn_sql_insert := '';
    l_dyn_sql_insert := l_dyn_sql_insert || 'INSERT INTO BOM_INVENTORY_COMPS_INTERFACE ( BATCH_ID, ';
    l_dyn_sql_insert := l_dyn_sql_insert || ' COMP_SOURCE_SYSTEM_REFERENCE, COMP_SOURCE_SYSTEM_REFER_DESC,';
    l_dyn_sql_insert := l_dyn_sql_insert || ' PARENT_SOURCE_SYSTEM_REFERENCE, REQUEST_ID, Transaction_Type,';
    l_dyn_sql_insert := l_dyn_sql_insert || ' Transaction_Id, Process_Flag, ';
    l_dyn_sql_insert := l_dyn_sql_insert || 'ORGANIZATION_CODE, ALTERNATE_BOM_DESIGNATOR, COMPONENT_SEQUENCE_ID, PARENT_REVISION_CODE, ';
    l_dyn_sql_select := '';
    l_dyn_sql_select := l_dyn_sql_select || 'SELECT ' || P_BATCH_ID || ' , ' || G_INTF_SRCSYS_COMPONENT ;
    l_dyn_sql_select := l_dyn_sql_select || ', ' || G_INTF_SRCSYS_DESCRIPTION || ' , ' || G_INTF_SRCSYS_PARENT ;
    l_dyn_sql_select := l_dyn_sql_select || ' , REQUEST_ID, ''' || G_TXN_CREATE || ''' , Transaction_Id, 1, ' || G_INTF_ORG_CODE || ', ';
    l_dyn_sql_select := l_dyn_sql_select || ' DECODE(' || 'DECODE(' || G_INTF_STRUCT_NAME
                                         || ',null,(select decode(structure_name,BOM_GLOBALS.GET_PRIMARY_UI,null,structure_name) from ego_import_option_sets where batch_id = '
                                         || ' :1 ),'|| G_INTF_STRUCT_NAME|| ')'  || ', Bom_Globals.Retrieve_Message(''BOM'', ''BOM_PRIMARY''),NULL,'
                                         || 'DECODE(' || G_INTF_STRUCT_NAME || ',null,(select decode(structure_name,BOM_GLOBALS.GET_PRIMARY_UI,null,structure_name) from ego_import_option_sets where batch_id = '
                                         ||' :2 ),'|| G_INTF_STRUCT_NAME|| ')) ,';
    l_dyn_sql_select := l_dyn_sql_select || G_INTF_COMP_SEQ_ID || ', ' || G_INTF_PARENT_REVISION || ', ';

    FOR i IN 1..l_prod_col_name_tbl.COUNT LOOP
      IF (l_bom_col_name(i) IS NOT NULL) THEN
        l_dyn_sql_insert := l_dyn_sql_insert || l_bom_col_name(i) || ',';

     -- As date values are coming as character values convert them as dates.
        IF ((l_bom_col_type(i) IS NOT NULL) AND (l_bom_col_type(i) = 'DATETIME')) THEN
          l_dyn_sql_select := l_dyn_sql_select || 'TO_DATE(' || l_intf_col_name_tbl(i) || ',''DD-MON-YYYY HH24:MI:SS''),';
        ELSIF (l_lookup_type(i) IS NOT NULL) THEN
          l_str := '(SELECT LOOKUP_CODE FROM FND_LOOKUP_VALUES WHERE ';
          l_str := l_str || ' LOOKUP_TYPE = ''' || l_lookup_type(i) ||''' AND LANGUAGE = USERENV(''LANG'') AND MEANING=' || l_intf_col_name_tbl(i) ||' ),';
          l_dyn_sql_select := l_dyn_sql_select || l_str;
        ELSE
          l_dyn_sql_select := l_dyn_sql_select || l_intf_col_name_tbl(i) || ',';
        END IF;

      END IF;
    END LOOP;

    l_dyn_sql_insert := SUBSTR(l_dyn_sql_insert,0,LENGTH(l_dyn_sql_insert) - 1);
    l_dyn_sql_select := SUBSTR(l_dyn_sql_select,0,LENGTH(l_dyn_sql_select) - 1);
    l_dyn_sql_insert := l_dyn_sql_insert || ' ) ';
    l_dyn_sql_select := l_dyn_sql_select || ' FROM EGO_BULKLOAD_INTF ';
    l_dyn_sql_select := l_dyn_sql_select || ' WHERE RESULTFMT_USAGE_ID = :3 ';
    l_dyn_sql_select := l_dyn_sql_select || ' AND PROCESS_STATUS = 1 AND ';
--  Sreejith
    if (p_is_pdh_batch = 'Y') then
     l_dyn_sql_select := l_dyn_sql_select || l_parent_column || ' IS NOT NULL ';
    else
       l_dyn_sql_select := l_dyn_sql_select || G_INTF_SRCSYS_PARENT || ' IS NOT NULL ';
    end if;
--  Sreejith

    l_dyn_sql_select := l_dyn_sql_select || ' AND ( UPPER(Transaction_Type) = ''' || G_TXN_CREATE || ''' OR  UPPER(Transaction_Type) = ''' || G_TXN_ADD || ''') ';

--    l_dyn_sql_select := l_dyn_sql_select || ' AND (Transaction_Type = ''' || G_TXN_CREATE || ''' OR  Transaction_Type = ''' || G_TXN_ADD || ''' ';
--    l_dyn_sql_select := l_dyn_sql_select || ' OR Transaction_Type = ''' || G_TXN_SYNC || ''' )';


    l_dyn_sql := l_dyn_sql_insert || ' ' || l_dyn_sql_select;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering SQL 4-->' || l_dyn_sql);
    END IF;

    EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id,p_batch_id,p_resultfmt_usage_id;
-- End of Process Components for CREATE/ADD

      IF l_debug = 'Y' THEN
        FND_FILE.PUT_LINE( FND_FILE.LOG,'Executed Succesfully 4');
      END IF;

-- Start of process components for Delete
    l_dyn_sql_insert := '';
    l_dyn_sql_insert := l_dyn_sql_insert || 'INSERT INTO BOM_INVENTORY_COMPS_INTERFACE ( BATCH_ID, ';
    l_dyn_sql_insert := l_dyn_sql_insert || ' COMP_SOURCE_SYSTEM_REFERENCE, COMP_SOURCE_SYSTEM_REFER_DESC,';
    l_dyn_sql_insert := l_dyn_sql_insert || ' PARENT_SOURCE_SYSTEM_REFERENCE, REQUEST_ID, Transaction_Type,';
    l_dyn_sql_insert := l_dyn_sql_insert || ' Transaction_Id, Process_Flag, ';
    l_dyn_sql_insert := l_dyn_sql_insert || 'ORGANIZATION_CODE, ALTERNATE_BOM_DESIGNATOR, COMPONENT_SEQUENCE_ID, ';
    l_dyn_sql_insert := l_dyn_sql_insert || 'DELETE_GROUP_NAME, DG_DESCRIPTION, ';
    l_dyn_sql_select := '';
    l_dyn_sql_select := l_dyn_sql_select || 'SELECT ' || P_BATCH_ID || ' , ' || G_INTF_SRCSYS_COMPONENT ;
    l_dyn_sql_select := l_dyn_sql_select || ', ' || G_INTF_SRCSYS_DESCRIPTION || ' , ' || G_INTF_SRCSYS_PARENT ;
    l_dyn_sql_select := l_dyn_sql_select || ' , REQUEST_ID, TRANSACTION_TYPE, Transaction_Id, 1, ' || G_INTF_ORG_CODE || ', ';
    l_dyn_sql_select := l_dyn_sql_select || ' DECODE(' || 'DECODE(' || G_INTF_STRUCT_NAME
                                         || ',null,(select decode(structure_name,BOM_GLOBALS.GET_PRIMARY_UI,null,structure_name) from ego_import_option_sets where batch_id = '
                                         || ' :1 ),'|| G_INTF_STRUCT_NAME|| ')'  || ', Bom_Globals.Retrieve_Message(''BOM'', ''BOM_PRIMARY''),NULL,'
                                         || 'DECODE(' || G_INTF_STRUCT_NAME || ',null,(select decode(structure_name,BOM_GLOBALS.GET_PRIMARY_UI,null,structure_name) from ego_import_option_sets where batch_id = '
                                         ||' :2 ),'|| G_INTF_STRUCT_NAME|| ')) ,';
    l_dyn_sql_select := l_dyn_sql_select || G_INTF_COMP_SEQ_ID || ', ';
    l_dyn_sql_select := l_dyn_sql_select || '''' || G_DEL_GROUP_NAME || ''', ''' || G_DEL_GROUP_DESC || ''', ' ;

    FOR i IN 1..l_prod_col_name_tbl.COUNT LOOP
      IF (l_bom_col_name(i) IS NOT NULL) THEN
        l_dyn_sql_insert := l_dyn_sql_insert || l_bom_col_name(i) || ',';

     -- As date values are coming as character values convert them as dates.
        IF ((l_bom_col_type(i) IS NOT NULL) AND (l_bom_col_type(i) = 'DATETIME')) THEN
          l_dyn_sql_select := l_dyn_sql_select || 'TO_DATE(' || l_intf_col_name_tbl(i) || ',''DD-MON-YYYY HH24:MI:SS''),';
        ELSIF (l_lookup_type(i) IS NOT NULL) THEN
          l_str := '(SELECT LOOKUP_CODE FROM FND_LOOKUP_VALUES WHERE ';
          l_str := l_str || ' LOOKUP_TYPE = ''' || l_lookup_type(i) ||''' AND LANGUAGE = USERENV(''LANG'') AND MEANING=' || l_intf_col_name_tbl(i) ||' ),';
          l_dyn_sql_select := l_dyn_sql_select || l_str;
        ELSE
          l_dyn_sql_select := l_dyn_sql_select || l_intf_col_name_tbl(i) || ',';
        END IF;

      END IF;
    END LOOP;

    l_dyn_sql_insert := SUBSTR(l_dyn_sql_insert,0,LENGTH(l_dyn_sql_insert) - 1);
    l_dyn_sql_select := SUBSTR(l_dyn_sql_select,0,LENGTH(l_dyn_sql_select) - 1);
    l_dyn_sql_insert := l_dyn_sql_insert || ' ) ';
    l_dyn_sql_select := l_dyn_sql_select || ' FROM EGO_BULKLOAD_INTF ';
    l_dyn_sql_select := l_dyn_sql_select || ' WHERE RESULTFMT_USAGE_ID = :3 ';
    l_dyn_sql_select := l_dyn_sql_select || ' AND PROCESS_STATUS = 1 AND ';
--  Sreejith
    if (p_is_pdh_batch = 'Y') then
     l_dyn_sql_select := l_dyn_sql_select || l_parent_column || ' IS NOT NULL ';
    else
       l_dyn_sql_select := l_dyn_sql_select || G_INTF_SRCSYS_PARENT || ' IS NOT NULL ';
    end if;
--  Sreejith

    l_dyn_sql_select := l_dyn_sql_select || ' AND UPPER(Transaction_Type) = ''' || G_TXN_DELETE || ''' ';

    l_dyn_sql := l_dyn_sql_insert || ' ' || l_dyn_sql_select;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering SQL 5-->' || l_dyn_sql);
    END IF;

    EXECUTE IMMEDIATE l_dyn_sql USING p_batch_id,p_batch_id,p_resultfmt_usage_id;
-- End of process components for Delete

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Before UPdate of AssemblyType');
    END IF;

-- Updateing the assembly_type to 2 for BOM_header
    UPDATE BOM_BILL_OF_MTLS_INTERFACE SET assembly_type = 2
    WHERE assembly_type IS NULL
    AND batch_id = p_batch_id;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'After UPdate of AssemblyType');
    END IF;

   /* Commenting the primary creation, as now we can create eng alternates with out primary.
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
        G_TXN_CREATE,
        G_REQUEST_ID);
    END LOOP;
    */

    UPDATE BOM_BILL_OF_MTLS_INTERFACE
     SET  Transaction_Id = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
    WHERE  REQUEST_ID = G_REQUEST_ID AND PROCESS_FLAG = 1
    AND Transaction_Id IS NULL;


 --Setting the transaction_id in the ego_bulkload_intf to be the same for multi row comp attr

  IF l_eff_date_col_name IS NOT NULL AND l_oper_seq_col_name IS NOT NULL AND l_item_seq_col_name IS NOT NULL THEN

  l_upd_sql := ' UPDATE EGO_BULKLOAD_INTF EBI1 ' ||
               ' SET EBI1.transaction_id = ( SELECT EBI2.transaction_id ' ||
                                           ' FROM EGO_BULKLOAD_INTF EBI2 ' ||
                                           ' WHERE EBI2.resultfmt_usage_id =  EBI1.resultfmt_usage_id AND EBI2.process_status = 1 ' ||
                                           ' AND EBI2.' || l_item_seq_col_name || ' IS NOT NULL' ;
   IF p_is_pdh_batch = 'Y' THEN
      l_upd_sql := l_upd_sql || ' AND EBI2.' || l_parent_column || ' = EBI1.' || l_parent_column ||
                                ' AND EBI2.' || l_parent_column || ' IS NOT NULL ' ||
                                ' AND EBI2.' || l_item_col_name || ' IS NOT NULL ' ||
                                ' AND EBI2.' || l_item_col_name || ' = EBI1.' || l_item_col_name ;
  ELSE
   l_upd_sql := l_upd_sql || ' AND EBI2.' || G_INTF_SRCSYS_PARENT || ' = EBI1.' || G_INTF_SRCSYS_PARENT ||
                             ' AND EBI2.' || G_INTF_SRCSYS_PARENT || ' IS NOT NULL ' ||
                             ' AND EBI2.' || G_INTF_SRCSYS_COMPONENT || ' IS NOT NULL ' ||
                             ' AND EBI2.' || G_INTF_SRCSYS_COMPONENT || ' = EBI1.' || G_INTF_SRCSYS_COMPONENT ;
  END IF;

  l_upd_sql := l_upd_sql || ')  WHERE EBI1.resultfmt_usage_id = :RESULTFMT_USAGE_ID  AND EBI1.process_status = 1 ' ||
               ' AND EBI1.' || l_item_seq_col_name || ' IS NULL ' ;
  IF p_is_pdh_batch = 'Y' THEN
    l_upd_sql := l_upd_sql || ' AND EBI1.' || l_parent_column || ' IS NOT NULL ' ||
               ' AND EBI1.' || l_parent_column || ' = (SELECT EBI3.' || l_parent_column ||
                                                  ' FROM EGO_BULKLOAD_INTF EBI3 ' ||
                                                  ' WHERE EBI3.resultfmt_usage_id =  EBI1.resultfmt_usage_id AND EBI3.process_status = 1 ' ||
                                                  ' AND EBI3.' || l_item_seq_col_name || ' IS NOT NULL' ||
                                                  ' AND EBI3.' || l_parent_column || ' = EBI1.' || l_parent_column ||
                                                  ' AND EBI3.' || l_item_col_name || ' = EBI1.' || l_item_col_name ||
                                                  ' ) ' ||
               ' AND EBI1.' || l_item_col_name || ' IS NOT NULL ' ||
               ' AND EBI1.' || l_item_col_name || ' = (SELECT EBI4.' || l_item_col_name ||
                                                    ' FROM EGO_BULKLOAD_INTF EBI4 ' ||
                                                    ' WHERE EBI4.resultfmt_usage_id =  EBI1.resultfmt_usage_id AND EBI4.process_status = 1 ' ||
                                                    ' AND EBI4.' || l_item_seq_col_name || ' IS NOT NULL' ||
                                                    ' AND EBI4.' || l_item_col_name || ' = EBI1.' || l_item_col_name ||
                                                    ' AND EBI4.' || l_parent_column || ' = EBI1.' || l_parent_column ||
                                                    ' ) ';
  ELSE
  l_upd_sql := l_upd_sql || ' AND EBI1.' || G_INTF_SRCSYS_PARENT || ' IS NOT NULL ' ||
             ' AND EBI1.' || G_INTF_SRCSYS_PARENT || ' = (SELECT EBI3.' || G_INTF_SRCSYS_PARENT ||
                                                  ' FROM EGO_BULKLOAD_INTF EBI3 ' ||
                                                  ' WHERE EBI3.resultfmt_usage_id =  EBI1.resultfmt_usage_id AND EBI3.process_status = 1 ' ||
                                                  ' AND EBI3.' || l_item_seq_col_name || ' IS NOT NULL' ||
                                                  ' AND EBI3.' || G_INTF_SRCSYS_PARENT || ' = EBI1.' || G_INTF_SRCSYS_PARENT ||
                                                  ' AND EBI3.' || G_INTF_SRCSYS_COMPONENT || ' = EBI1.' || G_INTF_SRCSYS_COMPONENT ||
                                                  ' ) ' ||
             ' AND EBI1.' || G_INTF_SRCSYS_COMPONENT || ' IS NOT NULL ' ||
             ' AND EBI1.' || G_INTF_SRCSYS_COMPONENT || ' = (SELECT EBI4.' || G_INTF_SRCSYS_COMPONENT ||
                                                    ' FROM EGO_BULKLOAD_INTF EBI4 ' ||
                                                    ' WHERE EBI4.resultfmt_usage_id =  EBI1.resultfmt_usage_id  AND EBI4.process_status = 1 ' ||
                                                    ' AND EBI4.' || l_item_seq_col_name || ' IS NOT NULL' ||
                                                    ' AND EBI4.' || G_INTF_SRCSYS_COMPONENT || ' = EBI1.' || G_INTF_SRCSYS_COMPONENT ||
                                                    ' AND EBI4.' || G_INTF_SRCSYS_PARENT || ' = EBI1.' ||  G_INTF_SRCSYS_PARENT ||
                                                    ' ) ';
  END IF;


    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'item_cole_name--' || l_item_col_name);
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Update Sql for ego bulkload for Multi Row-->' || l_upd_sql);
    END IF;

  EXECUTE IMMEDIATE l_upd_sql USING p_resultfmt_usage_id;

  END IF;


-- Call the load_comp_usr_attr_interface to load component user attributes
    load_comp_usr_attr_interface(
                                 p_resultfmt_usage_id => p_resultfmt_usage_id,
                                 p_data_set_id => p_batch_id,
                                 x_errbuff => l_errbuff,
                                 x_retcode => l_retcode
                                );

-- Delete the duplicate component rows, which are populated bcos of component user attributes (multi row)
-- This will be done by checking the value of EffectivityDate, OperationSequence, Item Sequence.
   IF l_eff_date_col_name IS NOT NULL AND l_oper_seq_col_name IS NOT NULL AND l_item_seq_col_name IS NOT NULL THEN
      DELETE BOM_INVENTORY_COMPS_INTERFACE
      WHERE PROCESS_FLAG = 1
      AND batch_id = p_batch_id
      AND (OPERATION_SEQ_NUM IS NOT NULL OR NEW_OPERATION_SEQ_NUM IS NOT NULL)
      AND (EFFECTIVITY_DATE IS NOT NULL OR NEW_EFFECTIVITY_DATE IS NOT NULL)
      AND ITEM_NUM IS NULL;
   END IF;

  -- Process Reference Designators
    IF (G_INTF_REF_DESIG IS NOT NULL AND G_INTF_REF_DESIG <>'NULL') THEN
      l_dyn_sql_cursor := '';
      l_dyn_sql_cursor := l_dyn_sql_cursor || ' SELECT ' || l_item_col_name  || ',' || G_INTF_SRCSYS_COMPONENT ;
      l_dyn_sql_cursor := l_dyn_sql_cursor || ' , ' || l_parent_column || ',' || G_INTF_SRCSYS_PARENT ;
      l_dyn_sql_cursor := l_dyn_sql_cursor || ' , ' || G_INTF_ORG_CODE;
      l_dyn_sql_cursor := l_dyn_sql_cursor || ' , DECODE(' || G_INTF_STRUCT_NAME || ', Bom_Globals.Retrieve_Message(''BOM'', ''BOM_PRIMARY''),NULL,' || G_INTF_STRUCT_NAME || ')';
      l_dyn_sql_cursor := l_dyn_sql_cursor || ' , ' || G_INTF_REF_DESIG || ' , Transaction_Id , Transaction_Type ' ;
      l_dyn_sql_cursor := l_dyn_sql_cursor || ' FROM EGO_BULKLOAD_INTF WHERE Process_Status = 1';
      l_dyn_sql_cursor := l_dyn_sql_cursor || ' AND Resultfmt_Usage_Id = :RESULTFMT_USAGE_ID ';
      l_dyn_sql_cursor := l_dyn_sql_cursor || ' AND ' || l_parent_column || ' IS NOT NULL ';
      l_dyn_sql_cursor := l_dyn_sql_cursor || ' AND ( UPPER(Transaction_Type) = ''' || G_TXN_CREATE || ''' OR  UPPER(Transaction_Type) = ''' || G_TXN_ADD || ''' ';
      l_dyn_sql_cursor := l_dyn_sql_cursor || ' OR UPPER(Transaction_Type) = ''' || G_TXN_UPDATE || ''' OR UPPER(Transaction_Type) = ''' || G_TXN_SYNC || ''' )';

      Write_Debug('Entering SQL R.1' || l_dyn_sql_cursor);

      l_cursor_select := Dbms_Sql.Open_Cursor;
      Dbms_Sql.Parse(l_cursor_select, l_dyn_sql_cursor, Dbms_Sql.NATIVE);
      Dbms_Sql.Define_Column(l_cursor_select, 1, L_ITEM_NAME, 3000);
      Dbms_Sql.Define_Column(l_cursor_select, 2, L_SRCSYS_ITEM, 3000);
      Dbms_Sql.Define_Column(l_cursor_select, 3, L_PARENT_NAME, 3000);
      Dbms_Sql.Define_Column(l_cursor_select, 4, L_SRCSYS_PARENT,3000);
      Dbms_Sql.Define_Column(l_cursor_select, 5, L_ORGANIZATION_CODE, 10);
      Dbms_Sql.Define_Column(l_cursor_select, 6, L_STRUCTURE_NAME, 240);
      Dbms_Sql.Define_Column(l_cursor_select, 7, L_COMP_REF_DESIG, 3000);
      Dbms_Sql.Define_Column(l_cursor_select, 8, L_TRANSACTION_ID);
      Dbms_Sql.Define_Column(l_cursor_select, 9, L_TRNSACTION_TYPE, 30);

      Dbms_Sql.Bind_Variable(l_cursor_select,':RESULTFMT_USAGE_ID', p_resultfmt_usage_id);

      Write_Debug('Entering SQL R.2' || p_resultfmt_usage_id);

      l_cursor_execute := Dbms_Sql.EXECUTE(l_cursor_select);

      Write_Debug('Success -- RegDesig Cursor execution');

      LOOP
        IF (Dbms_Sql.Fetch_Rows(l_cursor_select) > 0) THEN
          Dbms_Sql.Column_Value(l_cursor_select,1,L_ITEM_NAME);
          Dbms_Sql.Column_Value(l_cursor_select,2,L_SRCSYS_ITEM);
          Dbms_Sql.Column_Value(l_cursor_select,3,L_PARENT_NAME);
          Dbms_Sql.Column_Value(l_cursor_select,4,L_SRCSYS_PARENT);
          Dbms_Sql.Column_Value(l_cursor_select,5,L_ORGANIZATION_CODE);
          Dbms_Sql.Column_Value(l_cursor_select,6,L_STRUCTURE_NAME);
          Dbms_Sql.Column_Value(l_cursor_select,7,L_COMP_REF_DESIG);
          Dbms_Sql.Column_Value(l_cursor_select,8,L_TRANSACTION_ID);
          Dbms_Sql.Column_Value(l_cursor_select,9,L_TRNSACTION_TYPE);


          getListOfRefDesigs(L_COMP_REF_DESIG, l_comp_ref_desig_tbl);
          FOR I IN 1..l_comp_ref_desig_tbl.COUNT LOOP
            INSERT INTO BOM_REF_DESGS_INTERFACE (
              BATCH_ID,
              REQUEST_ID,
              TRANSACTION_TYPE,
              TRANSACTION_ID,
              PROCESS_FLAG,
              ASSEMBLY_ITEM_NUMBER,
              ORGANIZATION_CODE,
              ALTERNATE_BOM_DESIGNATOR,
              COMPONENT_ITEM_NUMBER,
              COMP_SOURCE_SYSTEM_REFERENCE,
              PARENT_SOURCE_SYSTEM_REFERENCE,
              COMPONENT_REFERENCE_DESIGNATOR)
          VALUES (
              p_batch_id,
              G_REQUEST_ID,
              Decode(L_TRNSACTION_TYPE,G_TXN_SYNC,G_TXN_SYNC,G_TXN_UPDATE,G_TXN_SYNC,G_TXN_CREATE,G_TXN_CREATE,G_TXN_ADD,G_TXN_CREATE,L_TRNSACTION_TYPE),
              L_TRANSACTION_ID,
              1,
              L_PARENT_NAME,
              L_ORGANIZATION_CODE,
              L_STRUCTURE_NAME,
              L_ITEM_NAME,
              L_SRCSYS_ITEM,
              L_SRCSYS_PARENT,
              l_comp_ref_desig_tbl(I));
          END LOOP;
        ELSE
          EXIT;
        END IF;
      END LOOP;

      Dbms_Sql.Close_Cursor(l_cursor_select);
    END IF;

    UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET(effectivity_date, operation_seq_num,  from_end_item_unit_number, component_sequence_id, assembly_item_revision_code)
       = (SELECT Decode(effectivity_date,NULL,new_effectivity_date,effectivity_date),
                 Decode(operation_seq_num,NULL,new_operation_seq_num,operation_seq_num),
                 Decode(from_end_item_unit_number,NULL,new_from_end_item_unit_number,from_end_item_unit_number),
                 component_sequence_id, parent_revision_code
           FROM BOM_INVENTORY_COMPS_INTERFACE BIC1
           WHERE BIC1.TRANSACTION_ID = BRDI.TRANSACTION_ID )
       WHERE
        BRDI.batch_id = p_batch_id
        AND EXISTS( Select 'X' FROM BOM_INVENTORY_COMPS_INTERFACE BIC12
           WHERE BIC12.TRANSACTION_ID = BRDI.TRANSACTION_ID);
  -- Process Reference Designators Complete


-- Call the BOM API TO PROCESS INTERFACE TABLES
/*   l_err_return_code := bom_open_interface_api.import_bom
      ( org_id    => 207 --Dummy value, all_org below carries precedence
      , all_org   => 1
      , err_text  => l_err_text
      );
*/

    -- Updating the Bulkload interface rows with success.
    UPDATE EGO_BULKLOAD_INTF EBI
      SET  EBI.PROCESS_STATUS = 7
    WHERE EBI.RESULTFMT_USAGE_ID = p_resultfmt_usage_id AND EBI.PROCESS_STATUS = 1;

    -- Call to launch the Java Concurrent Program
/*    l_JCP_Id := Fnd_Request.Submit_Request(
                    application => 'BOM',
                    program     => 'BOMJCP',
                    sub_request => FALSE,
                    argument1   => G_REQUEST_ID);


    -- committing the changes to interface rows to reflect the changes in BOMJCP.
    COMMIT;         */
    x_retcode := G_STATUS_SUCCESS;

    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Done Processing');
    END IF;

    --Error_Handler.Write_Debug('Structure Import : UPDATE : l_err_text = ' || l_err_text);

-- Call completion procedure
/*    Structure_Intf_Proc_Complete
    (
      p_resultfmt_usage_id  => p_resultfmt_usage_id
      ,x_errbuff             => l_errbuff
      ,x_retcode             => l_retcode
    );
*/
    IF l_debug = 'Y' THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Completed Processing');
    END IF;

    --Error_Handler.Write_Debug('Updated the Process Status to Indicate Successful/Unsucessful component/structure Import Completion');

  EXCEPTION
    WHEN OTHERS THEN
    l_err_text := SQLERRM;
      x_errbuff := 'Error : '||TO_CHAR(SQLCODE)||'---'||SQLERRM;
      x_retcode := Error_Handler.G_STATUS_ERROR;
      IF l_debug = 'Y' THEN
        FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering Exception Message ' || x_errbuff);
        FND_FILE.PUT_LINE( FND_FILE.LOG,'Entering Exception Code' || x_retcode);
      END IF;
      Error_Handler.Close_Debug_Session;

END PROCESS_BOM_INTERFACE_LINES;


PROCEDURE Check_DeReference_Structure
  (
    p_request_id                IN NUMBER
  , p_batch_id                  IN NUMBER
  , p_assembly_item_id          IN NUMBER
  , p_organization_id           IN NUMBER
  , p_alternate_bom_designator  IN VARCHAR2
  , x_errbuff        OUT   NOCOPY VARCHAR2
  , x_retcode        OUT   NOCOPY VARCHAR2
    ) IS

    l_Component_Count          NUMBER;
    l_Bill_Sequence_id         NUMBER;
    l_Common_Bill_Sequence_Id  NUMBER;
    l_Source_Bill_Sequence_Id  NUMBER;

--Txn Types

  G_TXN_CREATE          VARCHAR2(10) := 'CREATE';
  G_TXN_ADD             VARCHAR2(10) := 'ADD';
  G_TXN_UPDATE          VARCHAR2(10) := 'UPDATE';
  G_TXN_DELETE          VARCHAR2(10) := 'DELETE';
  G_TXN_SYNC            VARCHAR2(10) := 'SYNC';

BEGIN

    SELECT Bill_Sequence_id, Common_Bill_Sequence_id, Source_Bill_Sequence_id
    INTO l_Bill_Sequence_id, l_Common_Bill_Sequence_Id, l_Source_Bill_Sequence_Id
    FROM BOM_STRUCTURES_B
    WHERE assembly_item_id = p_assembly_item_id
    AND organization_id = p_organization_id
    AND NVL(alternate_bom_designator , Fnd_Api.G_MISS_CHAR) = NVL(p_alternate_bom_designator, Fnd_Api.G_MISS_CHAR);

    IF (l_Bill_Sequence_id <> l_Common_Bill_Sequence_Id) THEN

      l_Component_Count := 0;

      SELECT COUNT(COMPONENT_ITEM_ID) INTO l_Component_Count
      FROM BOM_INVENTORY_COMPS_INTERFACE
      WHERE process_flag = 1
      AND UPPER(transaction_type) = G_TXN_UPDATE
      AND Request_Id = p_request_id
      AND (p_batch_id IS NULL OR batch_id = p_batch_id)
      AND assembly_item_id = p_assembly_item_id
      AND organization_id = p_organization_id
      AND NVL(alternate_bom_designator , Fnd_Api.G_MISS_CHAR) = NVL(p_alternate_bom_designator, Fnd_Api.G_MISS_CHAR);

      IF (l_Component_Count > 0) THEN
        -- Dereference the Bill Header
        BOMPCMBM.Dereference_Header( p_bill_sequence_id => l_Bill_Sequence_id);
        -- Dereference the components and others
        BOMPCMBM.Replicate_Components( p_src_bill_sequence_id => l_Common_Bill_Sequence_Id, p_dest_bill_sequence_id => l_Bill_Sequence_id);
        -- Update the components with new component sequence id
        UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
          SET COMPONENT_SEQUENCE_ID
                               = (SELECT COMPONENT_SEQUENCE_ID
                                 FROM BOM_INVENTORY_COMPONENTS BIC, bom_structures_b bsb
                                 WHERE BIC.bill_sequence_id = bsb.bill_Sequence_id
                                 AND bsb.assembly_item_id = p_assembly_item_id
                                 AND bsb.organization_id = p_organization_id
                                 AND NVL(bsb.alternate_bom_designator , Fnd_Api.G_MISS_CHAR) = NVL(p_alternate_bom_designator, Fnd_Api.G_MISS_CHAR)
                                 AND BIC.common_component_sequence_id = BICI.component_sequence_id)
          WHERE process_flag = 1
          AND UPPER(transaction_type) = G_TXN_UPDATE
          AND Request_Id = p_request_id
          AND (p_batch_id IS NULL OR batch_id = p_batch_id)
          AND assembly_item_id = p_assembly_item_id
          AND organization_id = p_organization_id
          AND NVL(alternate_bom_designator , Fnd_Api.G_MISS_CHAR) = NVL(p_alternate_bom_designator, Fnd_Api.G_MISS_CHAR);
      END IF;
    END IF;

  --Error_Handler.Write_Debug('EBI: Updated the Process_Status to Indicate Succssful/Unsucessful completion.');
  x_retcode := G_STATUS_SUCCESS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_retcode := G_STATUS_SUCCESS;
  WHEN OTHERS THEN
    x_retcode := G_STATUS_ERROR;
    x_errbuff := SUBSTRB(SQLERRM, 1,240);
    RAISE;
END Check_DeReference_Structure;

-- Data seperation logic for component user attributes.
PROCEDURE load_comp_usr_attr_interface
               (
                 p_resultfmt_usage_id    IN         NUMBER,
                 p_data_set_id           IN         NUMBER,
                 x_errbuff               OUT NOCOPY VARCHAR2,
                 x_retcode               OUT NOCOPY VARCHAR2
                ) IS


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
        WHERE  attr_group_type = G_COMP_ATTR_GROUP_TYPE
        AND    application_id = G_BOM_APPLICATION_ID
      );


  ------------------------------------------------------------------------------
  -- To get the Attribute Group and Attribute Internal Names.
  -- NOTE: Joined extra attributes ATTR_GROUP_TYPE and APPLICATION_ID
  -- To hit the index.
  ------------------------------------------------------------------------------
   CURSOR c_attr_grp_n_attr_int_names(p_attr_id  IN NUMBER) IS
     SELECT  attr_group_name, attr_name
     FROM    ego_attrs_v
     WHERE   attr_id = p_attr_id
      AND    attr_group_type = G_COMP_ATTR_GROUP_TYPE
      AND    application_id = G_BOM_APPLICATION_ID;


  --------------------------------------------------------------------------------
  -- Defn includes a subset of  EGO_USER_ATTRS_DATA_PVT.LOCAL_USER_ATTR_DATA_REC
  -- plus few User-Defined Attr Table related fields.
  --------------------------------------------------------------------------------
  TYPE L_USER_ATTR_REC_TYPE IS RECORD
  (
      DATA_SET_ID                          NUMBER(15)
     ,TRANSACTION_ID                       NUMBER(15)
     ,COMPONENT_SEQUENCE_ID                NUMBER(15)
     ,BILL_SEQUENCE_ID                     NUMBER(15)
     ,ORGANIZATION_ID                      NUMBER(15)
     ,COMPONENT_ITEM_NUMBER                VARCHAR2(1000)
     ,ORGANIZATION_CODE                    VARCHAR2(10)
     ,ROW_IDENTIFIER                       NUMBER(15)
     ,ATTR_GROUP_NAME                      VARCHAR2(30)
     ,ATTR_NAME                            VARCHAR2(30)
     ,ATTR_DATATYPE_CODE                   VARCHAR2(1) --Valid Vals: C / N / D
     ,ATTR_VALUE_STR                       VARCHAR2(1000)
     ,ATTR_VALUE_NUM                       NUMBER
     ,ATTR_VALUE_DATE                      DATE
     ,INTF_COLUMN_NAME                     VARCHAR2(30)
     ,SOURCE_SYSTEM_ID                     NUMBER
     ,SOURCE_SYSTEM_REFERENCE         VARCHAR2(255)
     ,PARENT_SOURCE_SYSTEM_REFERENCE       VARCHAR2(255)
     ,ASSEMBLY_ITEM_NUMBER                 VARCHAR2(255)
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
  l_str_type_id 		    NUMBER;
  l_prod_col_name_tbl               VARCHAR_TBL_TYPE;
  l_intf_col_name_tbl               VARCHAR_TBL_TYPE;

  l_attr_id_table                   DBMS_SQL.NUMBER_TABLE;
  l_intf_col_name_table             DBMS_SQL.VARCHAR2_TABLE;

  l_usr_attr_data_tbl               L_USER_ATTR_TBL_TYPE;

  l_bill_sequence_id_char           VARCHAR(30);
  l_component_sequence_id_char      VARCHAR(30);
  l_source_system_id                NUMBER;
  l_source_system_ref               VARCHAR2(255);
  l_comp_item_num                   VARCHAR2(255);
  l_org_code                        VARCHAR2(25);
  l_par_reference                   VARCHAR2(25);
  l_assembly_item_num               VARCHAR2(25);

  l_count                           NUMBER(5);
  l_data_type_code                  VARCHAR2(2);
  l_transaction_id                  NUMBER(15);
  l_msii_set_process_id             NUMBER;

  l_attr_group_int_name    EGO_ATTRS_V.ATTR_GROUP_NAME%TYPE;
  l_attr_int_name          EGO_ATTRS_V.ATTR_NAME%TYPE;

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
  L_ATTR_GRP_ROW_IDENT     NUMBER(5);

  ---------------------------------------------------------
  -- Token tables to log errors, through Error_Handler
  ---------------------------------------------------------
  l_token_tbl_two         Error_Handler.Token_Tbl_Type;
  l_token_tbl_one         Error_Handler.Token_Tbl_Type;

BEGIN
   write_debug(' SRIDHAR');
   ---------------------------------------------------------
   -- Initializing the Row Identifier.
   ---------------------------------------------------------
   L_ATTR_GRP_ROW_IDENT  := 0;

   IF p_data_set_id IS NULL THEN
     SELECT mtl_system_items_intf_sets_s.NEXTVAL
       INTO l_msii_set_process_id
     FROM dual;
   ELSE
     l_msii_set_process_id := p_data_set_id;
   END IF;

   --------------------------------------------------------------------
   -- Loop to process per Attribute Group of User-Defined Attributes.
   --------------------------------------------------------------------
   FOR c_attr_grp_rec IN c_user_attr_group_codes
     (
        p_resultfmt_usage_id
      )
   LOOP

    --------------------------------------------------------------------
    -- Fetch Organization ID, Item Number in Temp PLSQL tables.
    --------------------------------------------------------------------
    l_dyn_sql := '';
    l_dyn_sql := ' SELECT To_Number(SUBSTR(attribute_code, INSTR(attribute_code, ''$$'')+2)) attr_id, intf_column_name ';
    l_dyn_sql := l_dyn_sql || ' FROM   ego_results_fmt_usages ';
    l_dyn_sql := l_dyn_sql || ' WHERE  resultfmt_usage_id = :RESULTFMT_USAGE_ID';
    l_dyn_sql := l_dyn_sql || '  AND attribute_code LIKE :ATTRIBUTE_CODE ';
-- P4T Bug 8371175 start
    l_dyn_sql := l_dyn_sql || '  AND attribute_code NOT LIKE :ATTRIBUTE_CODE_O ';
-- P4T Bug 8371175 end

    Write_Debug(l_dyn_sql);

    l_cursor_select := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_cursor_select, l_dyn_sql, DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 1,l_attr_id_table,2500, l_temp);
    DBMS_SQL.DEFINE_ARRAY(l_cursor_select, 2,l_intf_col_name_table,2500, l_temp);
    DBMS_SQL.BIND_VARIABLE(l_cursor_select,':RESULTFMT_USAGE_ID', p_resultfmt_usage_id);
    DBMS_SQL.BIND_VARIABLE(l_cursor_select,':ATTRIBUTE_CODE', c_attr_grp_rec.attr_group_id||'$$%');
-- P4T Bug 8371175 start
    DBMS_SQL.BIND_VARIABLE(l_cursor_select,':ATTRIBUTE_CODE_O', c_attr_grp_rec.attr_group_id||'$$%_O');
-- P4T Bug 8371175 end

    l_cursor_execute := DBMS_SQL.EXECUTE(l_cursor_select);


    /*
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
     */


    Write_Debug('About to start the Loop to fetch Rows');
    l_count := DBMS_SQL.FETCH_ROWS(l_cursor_select);
    DBMS_SQL.COLUMN_VALUE(l_cursor_select, 1, l_attr_id_table);
    DBMS_SQL.COLUMN_VALUE(l_cursor_select, 2, l_intf_col_name_table);
    Write_Debug('Retrieved rows => '||To_char(l_count));
    DBMS_SQL.CLOSE_CURSOR(l_cursor_select);

    --------------------------------------------------------------------
    -- New DBMS_SQL Cursor for Select Attr Values.
    --------------------------------------------------------------------
    l_cursor_attr_id_val := DBMS_SQL.OPEN_CURSOR;
    l_dyn_attr_id_val_sql := '';
    l_dyn_attr_id_val_sql := ' SELECT ';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' TRANSACTION_ID , ';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' INSTANCE_PK4_VALUE , ';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' INSTANCE_PK5_VALUE , ';
    --------------------------------------------------------------------
    -- R12
    -- Adding the source system id and source system reference columns
    --------------------------------------------------------------------
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' TO_NUMBER(C_FIX_COLUMN11) , ';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' C_FIX_COLUMN12 , C_INTF_ATTR4, C_INTF_ATTR2 ,C_FIX_COLUMN14 , C_INTF_ATTR5 ,';

    --------------------------------------------------------------------
    -- Loop to Update the Inventory Item IDs.
    --------------------------------------------------------------------
    FOR i IN 1..l_attr_id_table.COUNT LOOP
      Write_Debug('Attr ID : '||To_char(l_attr_id_table(i)));
      Write_Debug('Intf Col Name : '||l_intf_col_name_table(i));
      IF (i <> l_attr_id_table.COUNT) THEN
        l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || l_intf_col_name_table(i) || ', ';
      ELSE
        l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || l_intf_col_name_table(i) ;
      END IF;
    END LOOP; --end: FOR i IN 1..l_attr_id_table.COUNT LOOP

    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' FROM EGO_BULKLOAD_INTF ' ;
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' WHERE RESULTFMT_USAGE_ID = :RESULTFMT_USAGE_ID';
    l_dyn_attr_id_val_sql := l_dyn_attr_id_val_sql || ' AND PROCESS_STATUS = :PROCESS_STATUS ';

    Write_Debug(l_dyn_attr_id_val_sql);

    DBMS_SQL.PARSE(l_cursor_attr_id_val, l_dyn_attr_id_val_sql, DBMS_SQL.NATIVE);
    --------------------------------------------------------------------
    --Setting Data Type for Trasaction ID
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 1, l_number_example);

    --------------------------------------------------------------------
    --Setting Data Type for INSTANCE_PK4_VALUE (Bill Sequence Id)
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 2, l_varchar_example, 1000);

    --------------------------------------------------------------------
    --Setting Data Type for INSTANCE_PK2_VALUE (Component Sequence Id)
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 3, l_varchar_example, 1000);

    --Setting Data Type for Source System Id
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 4, l_number_example);

    --------------------------------------------------------------------
    --Setting Data Type for Source System Reference
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 5, l_varchar_example, 1000);

    --------------------------------------------------------------------
    --Setting Data Type for Component Item Number
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 6, l_varchar_example, 1000);

    --------------------------------------------------------------------
    --Setting Data Type for Organziation Code
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 7, l_varchar_example, 1000);

    --------------------------------------------------------------------
    --Setting Data Type for Parent Source System Reference
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 8, l_varchar_example, 1000);

    --------------------------------------------------------------------
    --Setting Data Type for Assembly Item Number
    --------------------------------------------------------------------
    DBMS_SQL.DEFINE_COLUMN(l_cursor_attr_id_val, 9, l_varchar_example, 1000);

    --------------------------------------------------------------------
    -- Loop to Bind the Data Types for the SELECT Columns.
    --------------------------------------------------------------------
    FOR i IN 1..l_attr_id_table.COUNT LOOP

      ------------------------------------------------------------------------
      -- Since TRANSACTION_ID, INSTANCE_PK1_VALUE, INSTANCE_PK2_VALUE,
      -- INSTANCE_PK3_VALUE are added to the SELECT before the User-Defined
      -- Attrs, we need to adjust the index as follows.
      ------------------------------------------------------------------------
      l_actual_userattr_indx := i + 9;

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

    write_debug('Binding the PROCESS_STATUS = '||G_INTF_STATUS_TOBE_PROCESS);
    DBMS_SQL.BIND_VARIABLE(l_cursor_attr_id_val,':PROCESS_STATUS',G_INTF_STATUS_TOBE_PROCESS);

    ------------------------------------------------------------------------
    --  Execute to get the Item User-Defined Attr values.
    ------------------------------------------------------------------------
    l_cursor_execute := DBMS_SQL.EXECUTE(l_cursor_attr_id_val);

    l_rows_per_attr_grp_indx := 0;

    ------------------------------------------------------------------------
    --  Loop for each row found in EBI
    ------------------------------------------------------------------------
    LOOP --LOOP FOR CURSOR_ATTR_ID_VAL

      IF DBMS_SQL.FETCH_ROWS(l_cursor_attr_id_val)>0 THEN

        ------------------------------------------------------------------------
        --Increment Row Identifier per (Attribute Group + Row) Combination.
        ------------------------------------------------------------------------
        L_ATTR_GRP_ROW_IDENT  := L_ATTR_GRP_ROW_IDENT + 1;

        Write_Debug('ROW_FOUND : '||L_ATTR_GRP_ROW_IDENT);

        ------------------------------------------------------------------------
        -- First column is Transaction ID.
        ------------------------------------------------------------------------
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 1, l_transaction_id);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 2, l_bill_sequence_id_char);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 3, l_component_sequence_id_char);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 4, l_source_system_id);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 5, l_source_system_ref);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 6, l_comp_item_num);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 7, l_org_code);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 8, l_par_reference);
       DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, 9, l_assembly_item_num);

       ------------------------------------------------------------------------
       -- Loop to Bind the Data Types for the SELECT Columns.
       ------------------------------------------------------------------------
       FOR i IN 1..l_attr_id_table.COUNT LOOP

         OPEN c_attr_grp_n_attr_int_names(l_attr_id_table(i));
         FETCH c_attr_grp_n_attr_int_names INTO
           l_attr_group_int_name, l_attr_int_name;

         Write_Debug(i||'=>'||l_attr_group_int_name||':'||l_attr_int_name);

         l_attr_grp_has_data := FALSE;

         ------------------------------------------------------------------------
         -- If one more Attribute found for the Attribute Group.
         ------------------------------------------------------------------------
         IF c_attr_grp_n_attr_int_names%FOUND THEN
           l_rows_per_attr_grp_indx := l_rows_per_attr_grp_indx + 1;
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).DATA_SET_ID := l_msii_set_process_id;
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).TRANSACTION_ID := l_transaction_id;
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).BILL_SEQUENCE_ID := FND_NUMBER.CANONICAL_TO_NUMBER(l_bill_sequence_id_char);
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).COMPONENT_SEQUENCE_ID := FND_NUMBER.CANONICAL_TO_NUMBER(l_component_sequence_id_char);
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ROW_IDENTIFIER := L_ATTR_GRP_ROW_IDENT;
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DATATYPE_CODE := SUBSTR (l_intf_col_name_table(i), 1, 1);
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_GROUP_NAME := l_attr_group_int_name;
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_NAME := l_attr_int_name;

           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).SOURCE_SYSTEM_ID := l_source_system_id;
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).SOURCE_SYSTEM_REFERENCE := l_source_system_ref;
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).COMPONENT_ITEM_NUMBER := l_comp_item_num;
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ORGANIZATION_CODE := l_org_code;
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).PARENT_SOURCE_SYSTEM_REFERENCE := l_par_reference;
           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ASSEMBLY_ITEM_NUMBER := l_assembly_item_num;



            ------------------------------------------------------------------------
            -- Since TRANSACTION_ID, INSTANCE_PK4_VALUE, INSTANCE_PK5_VALUE,
            -- are added to the SELECT before User-Defined
            -- Attrs, we need to adjust the index as follows.
            ------------------------------------------------------------------------
           l_actual_userattr_indx := i + 9;

           Write_Debug('BEGIN: To Retrieve Attr Value at Position :'||l_actual_userattr_indx);

            ------------------------------------------------------------------------
            -- Depending upon the Data Type, populate corresponding field in the
            -- User-Defined Attribute Data record.
            ------------------------------------------------------------------------
           IF (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DATATYPE_CODE = 'C') THEN
              DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, l_actual_userattr_indx, l_varchar_data);
              l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_STR := l_varchar_data;
              Write_Debug('String Value =>'||l_varchar_data);
           ELSIF (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DATATYPE_CODE = 'N') THEN
              DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, l_actual_userattr_indx, l_number_data);
              l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_NUM := l_number_data;
              Write_Debug('Number Value =>'||l_number_data);
           ELSE --IF (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DATATYPE_CODE = 'D') THEN
              DBMS_SQL.COLUMN_VALUE(l_cursor_attr_id_val, l_actual_userattr_indx, l_date_data);
              l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_DATE := l_date_data;
              Write_Debug('Date Value =>'||l_date_data);
           END IF; --end: IF (l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_DATATYPE_CODE = 'C') THEN

           Write_Debug('END: Retrieved Attr Value');

           l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).INTF_COLUMN_NAME := l_intf_col_name_table(i);


           ------------------------------------------------------------------------
           -- Bug: 3025778 Modified If statment.
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
              l_usr_attr_data_tbl.DELETE(l_rows_per_attr_grp_indx);
              l_rows_per_attr_grp_indx := l_rows_per_attr_grp_indx - 1;

              Write_Debug('Due to NULL Att data, resetting back the PLSQL table index to : '||l_rows_per_attr_grp_indx);

           END IF; --end: IF ((l_usr_attr_data_tbl(l_rows_per_attr_grp_indx).ATTR_VALUE_STR...

         END IF; --end: IF c_attr_grp_n_attr_int_names%FOUND THEN

         CLOSE c_attr_grp_n_attr_int_names;

       END LOOP; --end: FOR i IN 1..l_attr_id_table.COUNT LOOP

      ELSE --end: IF DBMS_SQL.FETCH_ROWS(l_cursor_attr_id_val)>0 THEN

        Write_Debug('Nothing Found (or) Done.');
        EXIT;

      END IF; --IF DBMS_SQL.FETCH_ROWS(l_cursor_attr_id_val)>0 THEN

      END LOOP; --END: LOOP FOR CURSOR_ATTR_ID_VAL

      l_attr_id_table.DELETE;
      l_intf_col_name_table.DELETE;


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
          l_varchar_data      := NULL;
          IF (l_usr_attr_data_tbl(i).ATTR_DATATYPE_CODE = 'C') THEN

             l_varchar_data := l_usr_attr_data_tbl(i).ATTR_VALUE_STR;

          ELSIF (l_usr_attr_data_tbl(i).ATTR_DATATYPE_CODE = 'N') THEN

             IF (l_usr_attr_data_tbl(i).ATTR_VALUE_NUM IS NOT NULL) THEN
               l_varchar_data := To_char(l_usr_attr_data_tbl(i).ATTR_VALUE_NUM);
             END IF;

          ELSE --IF (l_usr_attr_data_tbl(i).ATTR_DATATYPE_CODE = 'D') THEN

            IF (l_usr_attr_data_tbl(i).ATTR_VALUE_DATE IS NOT NULL) THEN
              l_varchar_data := To_Char(l_usr_attr_data_tbl(i).ATTR_VALUE_DATE , G_DATE_FORMAT);
            END IF;

          END IF; --end: IF (l_usr_attr_data_tbl(i).ATTR_DATATYPE_CODE = 'C') THEN
      --dikrishn Dont we need the structure type id to be inserted into
      -- bom_cmp_usr_attr_interface ?Bom JCP required batch_id so inserting that
     -- also
        SELECT structure_type_id
        INTO l_str_type_id
        FROM ego_import_option_sets
        where batch_id = p_data_set_id;

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
--R12
--DPHILIP: we will need to populate the process_status to 1 or 0 here.. we cant let the user attrs pl/sql handle this

          INSERT INTO BOM_CMP_USR_ATTR_INTERFACE
          (
           DATA_SET_ID          ,
           TRANSACTION_ID       ,
           BILL_SEQUENCE_ID    ,
           COMPONENT_SEQUENCE_ID,
           ROW_IDENTIFIER       ,
           ATTR_GROUP_INT_NAME  ,
           ATTR_INT_NAME        ,
           ATTR_DISP_VALUE      ,
           PROCESS_STATUS       ,
           SOURCE_SYSTEM_ID     ,
           COMP_SOURCE_SYSTEM_REFERENCE,
           BATCH_ID,
           STRUCTURE_TYPE_ID,
           TRANSACTION_TYPE,
           ITEM_NUMBER,
           ORGANIZATION_CODE,
           ORGANIZATION_ID,
           ASSEMBLY_ITEM_NUMBER,
           PARENT_SOURCE_SYSTEM_REFERENCE,
	   DATA_LEVEL_ID   -- Added for PIMTELCO Bug-7645265
          )
          VALUES
          (
           l_usr_attr_data_tbl(i).DATA_SET_ID,
           l_usr_attr_data_tbl(i).TRANSACTION_ID,
           l_usr_attr_data_tbl(i).BILL_SEQUENCE_ID,
           l_usr_attr_data_tbl(i).COMPONENT_SEQUENCE_ID,
           l_usr_attr_data_tbl(i).ROW_IDENTIFIER,
           l_usr_attr_data_tbl(i).ATTR_GROUP_NAME,
           l_usr_attr_data_tbl(i).ATTR_NAME,
           l_varchar_data,
           0,-- G_PROCESS_STATUS,
           l_usr_attr_data_tbl(i).SOURCE_SYSTEM_ID,
           l_usr_attr_data_tbl(i).SOURCE_SYSTEM_REFERENCE,
           p_data_set_id,
           l_str_type_id,
           'SYNC',
           l_usr_attr_data_tbl(i).COMPONENT_ITEM_NUMBER,
           l_usr_attr_data_tbl(i).ORGANIZATION_CODE,
           (SELECT ORGANIZATION_ID FROM mtl_parameters where organization_code = l_usr_attr_data_tbl(i).ORGANIZATION_CODE),
           l_usr_attr_data_tbl(i).ASSEMBLY_ITEM_NUMBER,
           l_usr_attr_data_tbl(i).PARENT_SOURCE_SYSTEM_REFERENCE,
           70201    -- Added for PIMTELCO Bug-7645265 Hardcoded Value for COMPONENTS_LEVEL data level
          );

          Write_Debug('DataSetID       ['||l_usr_attr_data_tbl(i).DATA_SET_ID||'] '||G_NEWLINE||
                      'TransactionID   ['||l_usr_attr_data_tbl(i).TRANSACTION_ID||'] '||G_NEWLINE||
                      'BillSequenceId  ['||l_usr_attr_data_tbl(i).BILL_SEQUENCE_ID||'] '||G_NEWLINE||
                      'CompSequenceId  ['||l_usr_attr_data_tbl(i).COMPONENT_SEQUENCE_ID||'] '||G_NEWLINE||
                      'RowIdentifier   ['||l_usr_attr_data_tbl(i).ROW_IDENTIFIER||'] '||G_NEWLINE||
                      'AttrGroupName   ['||l_usr_attr_data_tbl(i).ATTR_GROUP_NAME||'] '||G_NEWLINE||
                      'AttrName        ['||l_usr_attr_data_tbl(i).ATTR_NAME||'] '||G_NEWLINE||
                      ': Populated ATTR_DISP_VALUE of DataType['||l_usr_attr_data_tbl(i).ATTR_DATATYPE_CODE||'] => '||l_varchar_data);

        END IF; --end: IF ( LENGTH(l_usr_attr_data_tbl(i)..

      END LOOP; --FOR i IN 1..l_usr_attr_data_tbl.COUNT LOOP

      Write_Debug('EIAI: Populated the Component User-Defined Attr Values for Attribute Group : '||l_attr_group_int_name);

   END LOOP; --FOR c_attr_grp_rec IN c_user_attr_group_codes

   Write_Debug('EIAI: DONE Populating the Component User-Defined Attr Values');

 EXCEPTION
   WHEN OTHERS THEN
      x_retcode := G_STATUS_ERROR;
      x_errbuff := SUBSTRB(SQLERRM, 1,240);
      Write_Debug('load_comp_usr_attr_interface : EXCEPTION HAPPENED => '||x_errbuff);
      RAISE;

END load_comp_usr_attr_interface;

END BOM_BULKLOAD_PVT_PKG;

/
