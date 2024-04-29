--------------------------------------------------------
--  DDL for Package Body PON_OPEN_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_OPEN_INTERFACE_PVT" AS
/* $Header: PON_OPEN_INTERFACE_PVT.plb 120.1.12010000.8 2015/07/08 09:42:45 vinnaray noship $ */

PROCEDURE validate_attribute_data(
    p_batch_id IN NUMBER);

PROCEDURE validate_costfactor_data(
    p_batch_id IN NUMBER);

  --TYPE allowed_values_table IS TABLE OF VARCHAR2(20);

  neg_header_record_data neg_header_record;
TYPE column_test_table
IS
  TABLE OF allowed_value_column_object;
  allowed_values_table_data allowed_values_table;
  yn_data allowed_values_table;
  object_data allowed_value_column_object;
  column_test_table_data column_test_table := column_test_table();

TYPE validate_header_col_table
IS
  TABLE OF VARCHAR2(50);
  header_cols validate_header_col_table := validate_header_col_table ('CONTRACT_TYPE',
                                                'SECURITY_LEVEL_CODE', 'GLOBAL_AGREEMENT_FLAG',
                                                'PUBLISH_RATES_TO_BIDDERS_FLAG', 'OPEN_AUCTION_NOW_FLAG',
                                                'PUBLISH_AUCTION_NOW_FLAG', 'BID_VISIBILITY_CODE',
                                                'BID_SCOPE_CODE', 'BID_LIST_TYPE', 'BID_FREQUENCY_CODE',
                                                'BID_RANKING', 'RANK_INDICATOR', 'FULL_QUANTITY_BID_CODE',
                                                'MULTIPLE_ROUNDS_FLAG', 'MANUAL_CLOSE_FLAG', 'MANUAL_EXTEND_FLAG',
                                                'AWARD_APPROVAL_FLAG', 'AUCTION_ORIGINATION_CODE',
                                                'ADVANCE_NEGOTIABLE_FLAG', 'RECOUPMENT_NEGOTIABLE_FLAG',
                                                'PROGRESS_PYMT_NEGOTIABLE_FLAG', 'RETAINAGE_NEGOTIABLE_FLAG',
                                                'MAX_RETAINAGE_NEGOTIABLE_FLAG', 'SUPPLIER_ENTERABLE_PYMT_FLAG',
                                                'TWO_PART_FLAG', 'PF_TYPE_ALLOWED', 'PRICE_BREAK_RESPONSE',
                                                'PRICE_TIERS_INDICATOR');
  /*
  Here a map of columns and their possible values is created
  The values in pon_auction_headers_interface will be checked against the
  possible values given in this map.
  */

PROCEDURE populate_column_test_table(
    p_contract_type IN VARCHAR2,
    p_auction_type  IN VARCHAR2,
    p_is_complex    IN VARCHAR2 )
AS
  l_module VARCHAR2(250) := g_module_prefix || '.populate_column_test_table';
BEGIN
  print_log(l_module, 'Begin');
  column_test_table_data.extend(31);
  yn_data                   := allowed_values_table('Y','N');
  allowed_values_table_data := allowed_values_table('CONTRACT','BLANKET','STANDARD');
  object_data               := allowed_value_column_object('CONTRACT_TYPE',allowed_values_table_data);
  column_test_table_data(1) := object_data;
  allowed_values_table_data := allowed_values_table('PUBLIC','PRIVATE','HIERARCHY');
  object_data               := allowed_value_column_object('SECURITY_LEVEL_CODE',allowed_values_table_data); --SELECT MEANING FROM FND_LOOKUP_VALUES WHERE LOOKUP_TYPE = 'PON_SECURITY_LEVEL_CODE' AND LANGUAGE=UserEnv('LANG'))
  column_test_table_data(2) := object_data;
  IF(p_contract_type IN ('BLANKET','CONTRACT')) THEN
    object_data               := allowed_value_column_object('GLOBAL_AGREEMENT_FLAG',yn_data);
    column_test_table_data(3) := object_data;
  END IF;
  object_data                := allowed_value_column_object('PUBLISH_RATES_TO_BIDDERS_FLAG',yn_data);
  column_test_table_data(4)  := object_data;
  object_data                := allowed_value_column_object('OPEN_AUCTION_NOW_FLAG',yn_data);
  column_test_table_data(5)  := object_data;
  object_data                := allowed_value_column_object('PUBLISH_AUCTION_NOW_FLAG',yn_data);
  column_test_table_data(6)  := object_data;
  allowed_values_table_data  := allowed_values_table('OPEN_BIDDING', 'SEALED_BIDDING', 'SEALED_AUCTION');
  object_data                := allowed_value_column_object('BID_VISIBILITY_CODE',allowed_values_table_data);
  column_test_table_data(7)  := object_data;
  allowed_values_table_data  := allowed_values_table('LINE_LEVEL_BIDDING', 'MUST_BID_ALL_ITEMS');
  object_data                := allowed_value_column_object('BID_SCOPE_CODE',allowed_values_table_data);
  column_test_table_data(8)  := object_data;
  allowed_values_table_data  := allowed_values_table('PUBLIC_BID_LIST', 'PRIVATE_BID_LIST');
  object_data                := allowed_value_column_object('BID_LIST_TYPE',allowed_values_table_data);
  column_test_table_data(9)  := object_data;
  allowed_values_table_data  := allowed_values_table('SINGLE_BID_ONLY', 'MULTIPLE_BIDS_ALLOWED');
  object_data                := allowed_value_column_object('BID_FREQUENCY_CODE',allowed_values_table_data);
  column_test_table_data(10) := object_data;
  allowed_values_table_data  := allowed_values_table('PRICE_ONLY','MULTI_ATTRIBUTE_SCORING');
  object_data                := allowed_value_column_object('BID_RANKING',allowed_values_table_data);
  column_test_table_data(11) := object_data;
  allowed_values_table_data  := allowed_values_table('NONE','WIN_LOSE','NUMBERING');
  object_data                := allowed_value_column_object('RANKING_INDICATOR',allowed_values_table_data);
  column_test_table_data(12) := object_data;
  allowed_values_table_data  := allowed_values_table('PARTIAL_QTY_BIDS_ALLOWED', 'FULL_QTY_BIDS_REQD');
  object_data                := allowed_value_column_object('FULL_QUANTITY_BID_CODE',allowed_values_table_data);
  column_test_table_data(13) := object_data;
  IF(p_auction_type NOT IN ('REQUEST_FOR_QUOTE','SOLICITATION')) THEN
    object_data                := allowed_value_column_object('MULTIPLE_ROUNDS_FLAG',yn_data);
    column_test_table_data(14) := object_data;
  END IF;
  object_data                  := allowed_value_column_object('MANUAL_CLOSE_FLAG',yn_data);
  column_test_table_data(15)   := object_data;
  IF(p_auction_type            <> 'SOLICITATION') THEN
    object_data                := allowed_value_column_object('MANUAL_EXTEND_FLAG',yn_data);
    column_test_table_data(16) := object_data;
  END IF;
  object_data                  := allowed_value_column_object('AWARD_APPROVAL_FLAG',yn_data);
  column_test_table_data(17)   := object_data;
  allowed_values_table_data    := allowed_values_table('REQUISITION', 'BLANKET');
  object_data                  := allowed_value_column_object('AUCTION_ORIGINATION_CODE',allowed_values_table_data);
  column_test_table_data(18)   := object_data;
  IF(p_is_complex               = 'Y') THEN
    object_data                := allowed_value_column_object('ADVANCE_NEGOTIABLE_FLAG',yn_data);
    column_test_table_data(19) := object_data;
    object_data                := allowed_value_column_object('RECOUPMENT_NEGOTIABLE_FLAG',yn_data);
    column_test_table_data(20) := object_data;
    object_data                := allowed_value_column_object('PROGRESS_PYMT_NEGOTIABLE_FLAG',yn_data);
    column_test_table_data(21) := object_data;
    object_data                := allowed_value_column_object('RETAINAGE_NEGOTIABLE_FLAG',yn_data);
    column_test_table_data(22) := object_data;
    object_data                := allowed_value_column_object('MAX_RETAINAGE_NEGOTIABLE_FLAG',yn_data);
    column_test_table_data(23) := object_data;
    object_data                := allowed_value_column_object('SUPPLIER_ENTERABLE_PYMT_FLAG',yn_data);
    column_test_table_data(24) := object_data;
  END IF;
  IF(p_auction_type IN ('REQUEST_FOR_QUOTE','SOLICITATION')) THEN
    object_data                := allowed_value_column_object('TWO_PART_FLAG',yn_data);
    column_test_table_data(25) := object_data;
  END IF;
  allowed_values_table_data    := allowed_values_table('BUYER','SUPPLIER','BOTH','NONE');
  object_data                  := allowed_value_column_object('PF_TYPE_ALLOWED',allowed_values_table_data);
  column_test_table_data(26)   := object_data;
  IF(p_contract_type            = 'BLANKET') THEN
    allowed_values_table_data  := allowed_values_table('REQUIRED','OPTIONAL','NONE');
    object_data                := allowed_value_column_object('PRICE_BREAK_RESPONSE',allowed_values_table_data);
    column_test_table_data(27) := object_data;
  END IF;
  allowed_values_table_data  := allowed_values_table('PRICE_BREAKS','QUANTITY_BASED','NONE');
  object_data                := allowed_value_column_object('PRICE_TIERS_INDICATOR',allowed_values_table_data);
  column_test_table_data(28) := object_data;
  print_log(l_module, 'End');
EXCEPTION
WHEN OTHERS THEN
  print_Log(l_module, 'Exception in populate_column_test_table: sqlcode ' || SQLCODE || ' errm ' || SQLERRM );
END populate_column_test_table;

PROCEDURE validate_value_column_pair(
    col     IN VARCHAR2,
    val     IN VARCHAR2,
    ret_val IN OUT NOCOPY VARCHAR2)
AS
  obj allowed_value_column_object;
  l_module     VARCHAR2(250) := g_module_prefix || '.validate_value_column_pair';
BEGIN
  print_log(l_module, 'Begin');
  print_log(l_module, 'Column = '||col||' value = '||val);
  FOR i IN 1..column_test_table_data.Count
  LOOP
    obj    := column_test_table_data(i);
    IF obj IS NULL THEN
      CONTINUE;
    END IF;
    IF(obj.col_name = col) THEN
      IF val member OF obj.allowed_values THEN
        ret_val := 'Y';
      ELSE
        ret_val := 'N';
      END IF;
      print_log(l_module, ' Valid value for '||col||' = '||ret_val);
    END IF;
  END LOOP;
  print_log(l_module, 'End');
END validate_value_column_pair;

/*
This procedure checks whether non-null values are given to mandatory
columns in pon_auction_headers_interface table
*/
PROCEDURE null_check(
    p_batch_id      IN NUMBER,
    x_return_status IN OUT NOCOPY VARCHAR2 )
AS
TYPE cols_table
IS
  TABLE OF VARCHAR2(30);
  -- This pl/sql table stores the name of all columns that should have non-null values
  cols cols_table := cols_table('AUCTION_TITLE', 'CLOSE_BIDDING_DATE');
TYPE curvar_type
IS
  REF
  CURSOR;
    curvar curvar_type;
    val      VARCHAR2(30);
    l_module VARCHAR2(250) := g_module_prefix || '.null_check';
  BEGIN
    print_Log(l_module, 'null_check called. Loop to fetch all mandatory columns');
    FOR i IN 1..cols.Count
    LOOP
      print_log(l_module, 'Checking '||cols(i)||' for null value');
      OPEN curvar FOR 'select ' || cols(i) || ' from pon_auction_headers_interface where batch_id =  ' || p_batch_id || ' and rownum < 2';
      FETCH curvar INTO val;
    CONTINUE
  WHEN curvar%NOTFOUND ;
    IF (val IS NULL ) THEN
      INSERT
      INTO PON_INTERFACE_ERRORS
        (
          INTERFACE_TYPE,
          ERROR_MESSAGE_NAME,
          column_name,
          table_name,
          batch_id
        )
        VALUES
        (
          g_interface_type,
          'PON_FIELD_MUST_BE_ENTERED',
          cols(i),
          'PON_AUCTION_HEADERS_INTERFACE',
          p_batch_id
        );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END LOOP;
END null_check;
-----------------------------------------------------------------------
--Start of Comments
--Name: create_header_attr_inter
--Description : Warpper on PON APIs to copy the data from PON_AUC_ATTRIBUTES_INTERFACE interface table to PON_AUCTION_SECTIONS and PON_AUCTION_ATTRIBUTES
--Parameters:
--IN:
--  p_api_version
--  p_init_msg_list
--  p_commit
--  batchId
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE create_header_attr_inter
  (
    p_commit        IN VARCHAR2,
    batchId         IN NUMBER,
    x_return_status IN OUT NOCOPY VARCHAR2
  )
AS
  -- cursor to get the distinct section values from interface tables
  CURSOR c_interface_section
  IS
    SELECT DISTINCT GROUP_NAME,
      BATCH_ID ,
      INTERFACE_LINE_ID ,
      AUCTION_HEADER_ID ,
      AUCTION_LINE_NUMBER ,
      ATTR_GROUP_SEQ_NUMBER ,
      ACTION
    FROM PON_AUC_ATTRIBUTES_INTERFACE
    WHERE BATCH_ID         =batchId
    AND AUCTION_HEADER_ID IN
      (SELECT DISTINCT AUCTION_HEADER_ID FROM PON_AUC_ATTRIBUTES_INTERFACE
      )
  AND AUCTION_LINE_NUMBER = -1
  ORDER BY AUCTION_HEADER_ID, ATTR_GROUP_SEQ_NUMBER;
  -- cursor to get the values from interface tables for requirements
  CURSOR c_interface_attr
  IS
    SELECT BATCH_ID ,
      INTERFACE_LINE_ID ,
      AUCTION_HEADER_ID ,
      AUCTION_LINE_NUMBER,
      SEQUENCE_NUMBER ,
      ATTRIBUTE_NAME ,
      DATATYPE ,
      RESPONSE_TYPE ,
      RESPONSE_TYPE_NAME ,
      MANDATORY_FLAG ,
      DISPLAY_ONLY_FLAG ,
      DISPLAY_TARGET_FLAG,
      VALUE ,
      GROUP_CODE ,
      GROUP_NAME ,
      SCORING_TYPE ,
      ATTR_MAX_SCORE ,
      WEIGHT ,
      INTERNAL_ATTR_FLAG ,
      SCORING_METHOD ,
      KNOCKOUT_SCORE ,
      ACTION,
      NVL(ATTRIBUTE,
        SubStr(replace(regexp_replace(attribute_name,'</?[^>]+/?>',' ', 1, 0, 'i'),
                                        fnd_global.local_chr(38)||'nbsp;', ''),1,100)) ATTRIBUTE
    FROM PON_AUC_ATTRIBUTES_INTERFACE
    WHERE BATCH_ID          =batchId
    AND AUCTION_LINE_NUMBER = -1
    ORDER BY AUCTION_HEADER_ID, GROUP_NAME, SEQUENCE_NUMBER;

  c_interface_section_rec c_interface_section%ROWTYPE;
  c_interface_attr_rec c_interface_attr%ROWTYPE;
  l_BATCH_ID PON_AUC_ATTRIBUTES_INTERFACE.BATCH_ID%TYPE;
  l_AUCTION_HEADER_ID PON_AUC_ATTRIBUTES_INTERFACE.AUCTION_HEADER_ID%TYPE;
  l_SEQUENCE_NUMBER PON_AUC_ATTRIBUTES_INTERFACE.SEQUENCE_NUMBER%TYPE;
  l_section_name_check PON_AUC_ATTRIBUTES_INTERFACE.GROUP_NAME%TYPE;
  l_SCORING_METHOD PON_AUCTION_ATTRIBUTES.SCORING_METHOD%TYPE;
  l_sequence_number_attr PON_AUCTION_ATTRIBUTES.SEQUENCE_NUMBER%TYPE;
  l_ATTR_GROUP_SEQ_NUMBER PON_AUCTION_ATTRIBUTES.ATTR_GROUP_SEQ_NUMBER%TYPE;
  l_ATTR_DISP_SEQ_NUMBER PON_AUCTION_ATTRIBUTES.ATTR_DISP_SEQ_NUMBER%TYPE;
  l_LAST_AMENDMENT_UPDATE PON_AUCTION_ATTRIBUTES.LAST_AMENDMENT_UPDATE%TYPE;
  l_TABLE_NAME pon_interface_errors.TABLE_NAME%TYPE :='PON_AUC_ATTRIBUTES_INTERFACE';
  l_sequence_number_scr pon_attribute_scores_interface.sequence_number%TYPE;
  l_status     VARCHAR2(1) :='Y';
  l_count_acc  NUMBER;
  l_sum_wt_err VARCHAR(10);
  l_module     VARCHAR2(250) := g_module_prefix || '.create_header_attr_inter';
BEGIN
  print_log(l_module, 'inside of create_header_attr_inter procedure');
  /* calling the pon_auc_interface_table_pkg.validate_header_attributes procedure to validate the section and requirements and also to set the default values  */
  print_log(l_module, 'BEGIN Validating the data in interface table');
  pon_auc_interface_table_pkg.validate_header_attributes_api(NULL,batchId,-1);
  BEGIN
    SELECT 'N' status
    INTO l_status
    FROM dual
    WHERE EXISTS
      (SELECT * FROM pon_interface_errors WHERE BATCH_ID=batchId
      );
  EXCEPTION
  WHEN No_Data_Found THEN
    l_status:=NULL;
  END;
  IF(l_status='N') THEN
    print_log(l_module, 'An error occured while validating the requirements. please check the pon_interface_errors table for error information');
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_HDR_REQ_ERR');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',batchId);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  print_log(l_module, 'END Validating the data in interface table');
  print_log(l_module, 'BEGIN of section insertion');
  /* Insertion of section values from PON_AUC_ATTRIBUTES_INTERFACE interface table to PON_AUCTION_SECTIONS table */
  OPEN c_interface_section;
  LOOP
    FETCH c_interface_section INTO c_interface_section_rec;
    EXIT
  WHEN c_interface_section%NOTFOUND;
    BEGIN
      IF(NVL(c_interface_section_rec.action,'INSERT')='INSERT') THEN
        -- Check whether the section name already exists are not
        BEGIN
          SELECT DISTINCT SECTION_NAME
          INTO l_section_name_check
          FROM PON_AUCTION_SECTIONS
          WHERE AUCTION_HEADER_ID = c_interface_section_rec.AUCTION_HEADER_ID
          AND SECTION_NAME        = c_interface_section_rec.GROUP_NAME;
        EXCEPTION
        WHEN No_Data_Found THEN
          l_section_name_check:=NULL;
        END;
        -- if it is a new section name
        IF (l_section_name_check IS NULL) THEN
          BEGIN
            -- get the sequence value
            SELECT MAX(ATTR_GROUP_SEQ_NUMBER)
            INTO l_sequence_number
            FROM PON_AUCTION_SECTIONS
            WHERE AUCTION_HEADER_ID = c_interface_section_rec.AUCTION_HEADER_ID;
          EXCEPTION
          WHEN No_Data_Found THEN
            l_sequence_number:= NULL;
          END;
          l_sequence_number:=NVL(l_sequence_number,0)+10;
          -- insert the record in the PON_AUCTION_SECTIONS table.
          INSERT
          INTO PON_AUCTION_SECTIONS
            (
              ATTRIBUTE_LIST_ID ,
              AUCTION_HEADER_ID ,
              LINE_NUMBER ,
              ATTR_GROUP_SEQ_NUMBER,
              SECTION_NAME ,
              section_id ,
              creation_date ,
              created_by ,
              last_update_date ,
              last_updated_by
            )
            VALUES
            (
              -1 ,
              c_interface_section_rec.AUCTION_HEADER_ID,
              -1 ,
              l_sequence_number ,
              c_interface_section_rec.GROUP_NAME ,
              PON_AUCTION_SECTIONS_S.NEXTVAL ,
              SYSDATE ,
              fnd_global.user_id ,
              SYSDATE ,
              fnd_global.user_id
            );
        END IF;
      END IF;
    END;
  END LOOP;
  print_log(l_module, 'END of section insertion');
  /* End of section insertion */
  print_log(l_module, 'BEGIN of requirement insertion');
  -- open the cursor
  OPEN c_interface_attr;
  LOOP
    -- fetch the data
    FETCH c_interface_attr INTO c_interface_attr_rec ;
    EXIT
  WHEN c_interface_attr%NOTFOUND;
    BEGIN
      l_AUCTION_HEADER_ID                        := c_interface_attr_rec.auction_Header_id;
      IF(NVL(c_interface_attr_rec.action,'INSERT')='INSERT') THEN
        -- For requirements
        /* Setting the mandatory flag, display only flag, internal attr flag depending on the response value*/
        IF(c_interface_attr_rec.RESPONSE_TYPE      ='REQUIRED')THEN
          c_interface_attr_rec.MANDATORY_FLAG     := 'Y';
          c_interface_attr_rec.DISPLAY_ONLY_FLAG  := 'N';
          c_interface_attr_rec.INTERNAL_ATTR_FLAG := 'N';
        ELSIF (c_interface_attr_rec.RESPONSE_TYPE  ='DISPLAY_ONLY') THEN
          c_interface_attr_rec.MANDATORY_FLAG     := 'N';
          c_interface_attr_rec.DISPLAY_ONLY_FLAG  := 'Y';
          c_interface_attr_rec.INTERNAL_ATTR_FLAG := 'N';
        ELSIF (c_interface_attr_rec.RESPONSE_TYPE  ='OPTIONAL') THEN
          c_interface_attr_rec.MANDATORY_FLAG     := 'N';
          c_interface_attr_rec.DISPLAY_ONLY_FLAG  := 'N';
          c_interface_attr_rec.INTERNAL_ATTR_FLAG := 'N';
        ELSIF (c_interface_attr_rec.RESPONSE_TYPE  ='INTERNAL') THEN
          c_interface_attr_rec.MANDATORY_FLAG     := 'N';
          c_interface_attr_rec.DISPLAY_ONLY_FLAG  := 'N';
          c_interface_attr_rec.INTERNAL_ATTR_FLAG := 'Y';
        END IF;
        /* getting the sequence number, attr group sequence number, attr display sequence number */
        BEGIN
          SELECT MAX(SEQUENCE_NUMBER)
          INTO l_sequence_number_attr
          FROM pon_auction_attributes
          WHERE AUCTION_HEADER_ID = c_interface_attr_rec.AUCTION_HEADER_ID;
        EXCEPTION
        WHEN No_Data_Found THEN
          l_sequence_number_attr:= NULL;
        END;
        l_sequence_number_attr:=NVL(l_sequence_number_attr,0)+10;
        BEGIN
          SELECT DISTINCT ATTR_GROUP_SEQ_NUMBER
          INTO l_ATTR_GROUP_SEQ_NUMBER
          FROM PON_AUCTION_SECTIONS
          WHERE auction_header_id= c_interface_attr_rec.AUCTION_HEADER_ID
          AND SECTION_NAME       = c_interface_attr_rec.GROUP_NAME;
        EXCEPTION
        WHEN No_Data_Found THEN
          l_ATTR_GROUP_SEQ_NUMBER:=NULL;
        END;
        BEGIN
          SELECT MAX(ATTR_DISP_SEQ_NUMBER)
          INTO l_ATTR_DISP_SEQ_NUMBER
          FROM PON_AUCTION_ATTRIBUTES
          WHERE auction_header_id= c_interface_attr_rec.AUCTION_HEADER_ID
          AND SECTION_NAME       = c_interface_attr_rec.GROUP_NAME;
        EXCEPTION
        WHEN No_Data_Found THEN
          l_ATTR_DISP_SEQ_NUMBER:=NULL;
        END;
        l_ATTR_DISP_SEQ_NUMBER:= NVL(l_ATTR_DISP_SEQ_NUMBER,0)+10;
        /* getting the amendment number */
        BEGIN
          SELECT MAX(amendment_number)
          INTO l_LAST_AMENDMENT_UPDATE
          FROM pon_auction_headers_all
          WHERE AUCTION_HEADER_ID = c_interface_attr_rec.AUCTION_HEADER_ID;
        EXCEPTION
        WHEN No_Data_Found THEN
          l_LAST_AMENDMENT_UPDATE:= NULL;
        END;
        l_LAST_AMENDMENT_UPDATE:= NVL(l_LAST_AMENDMENT_UPDATE,0);
        /*BEGIN
        SELECT COUNT(*)
        INTO l_count_acc
        FROM pon_attribute_scores_interface
        WHERE batch_id                      = c_interface_attr_rec.batch_id
        AND auction_header_id                 = c_interface_attr_rec.auction_header_id
        AND ATTRIBUTE_SEQUENCE_NUMBER         = l_sequence_number_attr;
        IF (l_count_acc                       > 0) THEN
        c_interface_attr_rec.SCORING_METHOD:= Nvl(c_interface_attr_rec.SCORING_METHOD,'AUTOMATIC');
        END IF;
        END;    */
        -- insertion of data into pon_auction_attributes
        IF (c_interface_attr_rec.SCORING_METHOD= 'AUTOMATIC') THEN
          print_log(l_module, ' Begin validating AND INSERTING acceptable VALUES');
          acceptance_values_insert(c_interface_attr_rec,l_sequence_number_attr ,l_status);
          print_log(l_module, 'l_status is '|| l_status);
          IF (l_status='N')THEN
            print_log(l_module, 'An error occured while validating the acceptable values. please check the pon_interface_errors table for error information');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('PON','PON_IMPORT_HDR_REQ_ERR');
            FND_MESSAGE.SET_TOKEN('BATCH_ID',batchId);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          print_log(l_module, 'End validating AND INSERTING acceptable VALUES');
          BEGIN
            SELECT MAX(score)
            INTO c_interface_attr_rec.attr_max_score
            FROM pon_attribute_scores
            WHERE ATTRIBUTE_SEQUENCE_NUMBER=l_sequence_number_attr
            AND auction_header_id          =c_interface_attr_rec.auction_header_id;
          EXCEPTION
          WHEN No_Data_Found THEN
            print_log(l_module, 'No Data found');
          END;
          IF(c_interface_attr_rec.DATATYPE    ='TXT') THEN
            c_interface_attr_rec.scoring_type:=NVL(c_interface_attr_rec.scoring_type,'LOV');
          ELSIF(c_interface_attr_rec.DATATYPE ='NUM' OR c_interface_attr_rec.DATATYPE='DAT') THEN
            c_interface_attr_rec.scoring_type:=NVL(c_interface_attr_rec.scoring_type,'RANGE');
          END IF;
        END IF;
        /* Validating the requirement before inserting */
        l_status                            :=NULL;
        c_interface_attr_rec.sequence_number:=l_sequence_number_attr;
        print_log(l_module, 'BEGIN Validating the requirement before inserting');
        pon_auc_interface_table_pkg.validate_requirement(NULL,batchId,-1,c_interface_attr_rec,l_status);
        IF (l_status='N')THEN
          print_log(l_module, 'An error occured while validating the requirements. please check the pon_interface_errors table for error information');
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('PON','PON_IMPORT_HDR_REQ_ERR');
          FND_MESSAGE.SET_TOKEN('BATCH_ID',batchId);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        print_log(l_module, 'END Validating the requirement before inserting');
        INSERT
        INTO pon_auction_attributes
          (
            ATTRIBUTE_LIST_ID ,
            AUCTION_HEADER_ID ,
            LINE_NUMBER ,
            ATTRIBUTE_NAME ,
            SECTION_NAME ,
            DATATYPE ,
            MANDATORY_FLAG ,
            INTERNAL_ATTR_FLAG ,
            DISPLAY_ONLY_FLAG ,
            DISPLAY_TARGET_FLAG ,
            VALUE ,
            SCORING_TYPE ,
            ATTR_MAX_SCORE ,
            WEIGHT ,
            SCORING_METHOD ,
            SEQUENCE_NUMBER ,
            ATTR_LEVEL ,
            ATTR_GROUP_SEQ_NUMBER,
            ATTR_DISP_SEQ_NUMBER ,
            creation_date ,
            created_by ,
            last_update_date ,
            last_updated_by ,
            MODIFIED_DATE ,
            LAST_AMENDMENT_UPDATE,
            KNOCKOUT_SCORE,
            ATTRIBUTE
          )
          VALUES
          (
            -1 ,
            c_interface_attr_rec.AUCTION_HEADER_ID ,
            -1 ,
            c_interface_attr_rec.ATTRIBUTE_NAME ,
            c_interface_attr_rec.GROUP_NAME ,
            c_interface_attr_rec.DATATYPE ,
            c_interface_attr_rec.MANDATORY_FLAG ,
            c_interface_attr_rec.INTERNAL_ATTR_FLAG ,
            c_interface_attr_rec.DISPLAY_ONLY_FLAG ,
            c_interface_attr_rec.DISPLAY_TARGET_FLAG ,
            c_interface_attr_rec.VALUE ,
            NVL(c_interface_attr_rec.SCORING_TYPE,'NONE') ,
            c_interface_attr_rec.ATTR_MAX_SCORE ,
            c_interface_attr_rec.WEIGHT ,
            NVL(c_interface_attr_rec.SCORING_METHOD,'NONE') ,
            l_sequence_number_attr ,
            'HEADER' ,
            l_ATTR_GROUP_SEQ_NUMBER ,
            l_ATTR_DISP_SEQ_NUMBER ,
            SYSDATE ,
            fnd_global.user_id ,
            SYSDATE ,
            fnd_global.user_id ,
            SYSDATE ,
            l_LAST_AMENDMENT_UPDATE ,
            c_interface_attr_rec.KNOCKOUT_SCORE,
            c_interface_attr_rec.ATTRIBUTE
          );
        print_log(l_module, 'END of requirement insertion');
      END IF;
      IF(c_interface_attr_rec.action='DELETE') THEN
        print_log(l_module, 'Begin of requirement deletion');
        BEGIN
          SELECT sequence_number
          INTO c_interface_attr_rec.sequence_number
          FROM pon_auction_attributes
          WHERE ATTRIBUTE_NAME= c_interface_attr_rec.attribute_name;
        EXCEPTION
        WHEN No_Data_Found THEN
          print_log(l_module, 'No record to delete');
        END;
        DELETE
        FROM pon_auction_attributes
        WHERE sequence_number = c_interface_attr_rec.sequence_number
        AND auction_header_id = c_interface_attr_rec.auction_header_id;
        DELETE
        FROM pon_attribute_scores
        WHERE attribute_sequence_number= c_interface_attr_rec.sequence_number
        AND auction_header_id          = c_interface_attr_rec.auction_header_id;
        print_log(l_module, 'END of requirement deletion');
      END IF;
    END;
  END LOOP;
  SELECT DECODE(SUM(NVL(weight,0)),100,'Y','N')
  INTO l_sum_wt_err
  FROM pon_auction_attributes paa
  WHERE paa.auction_Header_id         = l_auction_header_id
  AND NVL(paa.scoring_METHOD,'NONE') <>'NONE'
  AND EXISTS
    (SELECT 'Y'
    FROM PON_AUCtion_ATTRIBUTES paa,
      pon_auction_Headers_all pah
    WHERE paa.auction_Header_id              = l_auction_header_id
    AND paa.auction_Header_id                = pah.auction_Header_id
    AND NVL(pah.HDR_ATTR_ENABLE_WEIGHTS,'Y') = 'Y'
    AND NVL(paa.scoring_METHOD,'NONE')      <>'NONE'
    );
  IF (l_sum_wt_err='N') THEN
    print_log(l_module, 'The total weight of all the requirements should be equal to 100.');
    RETURN;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  print_log(l_module, 'Exception occured in create_header_attr_inter procedure.');
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.SET_NAME('PON','PON_IMPORT_HDR_REQ_ERR');
  FND_MESSAGE.SET_TOKEN('BATCH_ID',batchId);
  FND_MSG_PUB.ADD;
  RAISE FND_API.G_EXC_ERROR;
END create_header_attr_inter;
-----------------------------------------------------------------------
--Start of Comments
--Name: acceptance_values_insert
--Description : Warpper on PON APIs to copy the data from PON_AUC_ATTRIBUTES_INTERFACE interface table to PON_AUCTION_SECTIONS and PON_AUCTION_ATTRIBUTES
--Parameters:
--IN:
--  p_api_version
--  p_auction_header_id
--  p_batch_id
--  l_SCORING_METHOD
--  c_interface_attr_rec1
--OUT:
--  l_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE acceptance_values_insert(
    p_interface_attr_rec1  IN ATTRIBUTES_VALUES_VALIDATION,
    p_sequence_number_attr IN pon_attribute_scores_interface.ATTRIBUTE_SEQUENCE_NUMBER%TYPE,
    l_status               IN OUT NOCOPY VARCHAR2 )
AS
  CURSOR c_attr_score
  IS
    SELECT *
    FROM pon_attribute_scores_interface
    WHERE batch_id               = p_interface_attr_rec1.l_batch_id
    AND auction_header_id        = p_interface_attr_rec1.l_auction_header_id
    AND ATTRIBUTE_SEQUENCE_NUMBER= p_sequence_number_attr;
  c_attr_score_rec c_attr_score%ROWTYPE;
  l_sequence_number_scr pon_auc_attributes_interface.sequence_number%type;
  c_interface_attr_rec ATTRIBUTES_VALUES_VALIDATION;
  l_value pon_auc_attributes_interface.Value%type;
  l_from_range pon_attribute_scores_interface.from_range%type;
  l_to_range pon_attribute_scores_interface.to_range%type;
  l_module VARCHAR2(250) := g_module_prefix || '.acceptance_values_insert';
BEGIN
  /* get the sequence number for a acceptable value*/
  BEGIN
    SELECT MAX(SEQUENCE_NUMBER)
    INTO l_sequence_number_scr
    FROM pon_attribute_scores
    WHERE auction_header_id      =p_interface_attr_rec1.l_auction_header_id
    AND attribute_sequence_number=p_sequence_number_attr;
  EXCEPTION
  WHEN OTHERS THEN
    l_sequence_number_scr:=NULL;
  END;
  OPEN c_attr_score;
  LOOP
    -- fetch the data
    FETCH c_attr_score INTO c_attr_score_rec ;
    EXIT
  WHEN c_attr_score%NOTFOUND;
    BEGIN
      /* check if the value and score field is not null for text data type */
      IF(p_interface_attr_rec1.l_SCORING_METHOD ='AUTOMATIC' AND p_interface_attr_rec1.l_datatype='TXT')THEN
        IF(c_attr_score_rec.value              IS NULL OR c_attr_score_rec.score IS NULL) THEN
          print_log(l_module, 'score or value cannot be empty');
          pon_auc_interface_table_pkg.insert_error_interface ( c_attr_score_rec.BATCH_ID,NULL,'pon_attribute_scores_interface','PON','PON_REQUIREMENT_ERR_11',p_interface_attr_rec1.l_SCORING_METHOD );
          l_status:='N';
          RETURN;
        ELSE
          /* check for the duplicate value */
          BEGIN
            SELECT DISTINCT Value
            INTO l_value
            FROM pon_attribute_scores
            WHERE auction_header_id      =p_interface_attr_rec1.l_auction_header_id
            AND ATTRIBUTE_SEQUENCE_NUMBER= p_sequence_number_attr
            AND Upper(Value)             =upper(c_attr_score_rec.Value);
          EXCEPTION
          WHEN No_Data_Found THEN
            l_value:=NULL;
          END;
          IF(l_value IS NOT NULL) THEN
            pon_auc_interface_table_pkg.insert_error_interface ( c_attr_score_rec.BATCH_ID,NULL,'pon_attribute_scores_interface','PON','PON_AUC_DUP_ACC_BID_VALUES',c_attr_score_rec.value );
            l_status:='N';
            RETURN;
          END IF;
        END IF;
        --ELSE
        l_sequence_number_scr:=NVL(l_sequence_number_scr,0)+10;
        /* insert the score record for the text datatype*/
        INSERT
        INTO pon_attribute_scores
          (
            AUCTION_HEADER_ID ,
            LINE_NUMBER ,
            ATTRIBUTE_SEQUENCE_NUMBER,
            VALUE ,
            FROM_RANGE ,
            TO_RANGE ,
            SCORE ,
            ATTRIBUTE_LIST_ID ,
            SEQUENCE_NUMBER ,
            CREATION_DATE ,
            CREATED_BY ,
            LAST_UPDATE_DATE ,
            LAST_UPDATED_BY
          )
          VALUES
          (
            c_attr_score_rec.auction_header_id,
            -1 ,
            p_sequence_number_attr ,
            c_attr_score_rec.value ,
            NULL ,
            NULL ,
            c_attr_score_rec.score ,
            -1 ,
            l_sequence_number_scr ,
            SYSDATE ,
            -1 ,
            SYSDATE ,
            -1
          );
        l_status:='Y';
        --RETURN;
      END IF;
      /* checkin the range values and score for the num and date datatype*/
      IF(p_interface_attr_rec1.l_SCORING_METHOD='AUTOMATIC' AND (p_interface_attr_rec1.l_datatype='DAT' OR p_interface_attr_rec1.l_datatype='NUM')) THEN
        IF((c_attr_score_rec.from_range       IS NULL AND c_attr_score_rec.to_range IS NULL) OR c_attr_score_rec.score IS NULL) THEN
          print_log(l_module, 'score or value cannot be empty');
          pon_auc_interface_table_pkg.insert_error_interface(c_attr_score_rec.BATCH_ID,NULL,'pon_attribute_scores_interface','PON','PON_REQUIREMENT_ERR_11',p_interface_attr_rec1.l_SCORING_METHOD);
          l_status:='N';
          RETURN;
        END IF;
        l_sequence_number_scr:=NVL(l_sequence_number_scr,0)+10;
        /* check for the range overlap*/
        check_range_overlap(c_attr_score_rec,p_interface_attr_rec1.l_datatype,l_status);
        /* if there is an range overlap*/
        IF(l_status='N') THEN
          RETURN;
        END IF;
        /* insert score value for NUM or DAT datatype*/
        INSERT
        INTO pon_attribute_scores
          (
            AUCTION_HEADER_ID ,
            LINE_NUMBER ,
            ATTRIBUTE_SEQUENCE_NUMBER,
            VALUE ,
            FROM_RANGE ,
            TO_RANGE ,
            SCORE ,
            ATTRIBUTE_LIST_ID ,
            SEQUENCE_NUMBER ,
            CREATION_DATE ,
            CREATED_BY ,
            LAST_UPDATE_DATE ,
            LAST_UPDATED_BY
          )
          VALUES
          (
            c_attr_score_rec.auction_header_id,
            -1 ,
            p_sequence_number_attr ,
            NULL ,
            c_attr_score_rec.from_range ,
            c_attr_score_rec.to_range ,
            c_attr_score_rec.score ,
            -1 ,
            l_sequence_number_scr ,
            SYSDATE ,
            -1 ,
            SYSDATE ,
            -1
          );
        l_status:='Y';
      END IF;
    END;
  END LOOP;
END;
-----------------------------------------------------------------------
--Start of Comments
--Name: check_range_overlap
--Description : Warpper on PON APIs to copy the data from PON_AUC_ATTRIBUTES_INTERFACE interface table to PON_AUCTION_SECTIONS and PON_AUCTION_ATTRIBUTES
--Parameters:
--IN:
--  p_attr_score_rec
--  p_datatype
--OUT:
-- l_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE check_range_overlap
  (
    p_attr_score_rec IN ATTRIBUTE_SCORES,
    p_datatype       IN pon_auc_attributes_interface.datatype%type ,
    l_status OUT NOCOPY VARCHAR2
  )
IS
  CURSOR c_score_overlap
  IS
    SELECT from_range,
      to_range
    FROM pon_attribute_scores
    WHERE auction_header_id      =p_attr_score_rec.l_auction_header_id
    AND attribute_sequence_number=p_attr_score_rec.l_attribute_sequence_number;
  --l_status         VARCHAR2(10):='N';
  l_from_range pon_attribute_scores.from_range%type;
  l_to_range pon_attribute_scores.to_range%type;
  t_from_range_num NUMBER;
  t_to_range_num   NUMBER;
  l_from_range_num NUMBER;
  l_to_range_num   NUMBER;
  t_from_range_dat DATE;
  t_to_range_dat   DATE;
  l_from_range_dat DATE;
  l_to_range_dat   DATE;
  l_count          NUMBER;
  l_module         VARCHAR2(250) := g_module_prefix || '.check_range_overlap';
BEGIN
  /* if datatype is num*/
  IF(p_datatype='NUM')THEN
    BEGIN
      SELECT To_Number(NVL(p_attr_score_rec.l_from_range,0)),
        To_Number(NVL(p_attr_score_rec.l_to_range,0))
      INTO l_from_range_num,
        l_to_range_num
      FROM dual;
    EXCEPTION
    WHEN OTHERS THEN
      print_log(l_module, 'Invalid number value');
      l_status:='N';
      RETURN;
    END;
    l_from_range_num    :=To_Number(p_attr_score_rec.l_from_range);
    l_to_range_num      :=To_Number(p_attr_score_rec.l_to_range);
    IF(l_from_range_num IS NOT NULL AND l_to_range_num IS NOT NULL) THEN
      IF(l_from_range_num> l_to_range_num)THEN
        pon_auc_interface_table_pkg.insert_error_interface ( p_attr_score_rec.l_BATCH_ID,NULL,'pon_attribute_scores_interface','PON','PON_AUC_FROM_TO_ERR_NUM_R',l_from_range_num );
        l_status :='N';
        RETURN;
      END IF;
    END IF;
    /* if there are any score records already exists */
    SELECT COUNT(*)
    INTO l_count
    FROM pon_attribute_scores
    WHERE auction_header_id      =p_attr_score_rec.l_auction_header_id
    AND attribute_sequence_number=p_attr_score_rec.l_attribute_sequence_number;
    IF(l_count                   < 1)THEN
      l_status                  :='Y';
      RETURN;
    ELSE
      OPEN c_score_overlap;
      LOOP
        -- fetch the data
        FETCH c_score_overlap INTO l_from_range, l_to_range ;
        EXIT
      WHEN c_score_overlap%NOTFOUND;
        BEGIN
          t_from_range_num      :=To_Number(l_from_range);
          t_to_range_num        :=To_Number(l_to_range);
          IF(t_from_range_num   IS NULL OR l_to_range_num IS NULL ) THEN
            IF(l_from_range_num <=t_to_range_num) THEN
              pon_auc_interface_table_pkg.insert_error_interface ( p_attr_score_rec.l_BATCH_ID,NULL,'pon_attribute_scores_interface','PON','PON_AUC_FROM_TO_ERR_NUM_R',l_from_range_num );
              l_status :='N';
              RETURN;
            END IF;
          END IF;
          IF(t_to_range_num   IS NULL OR l_from_range_num IS NULL ) THEN
            IF(l_to_range_num >=t_from_range_num) THEN
              pon_auc_interface_table_pkg.insert_error_interface ( p_attr_score_rec.l_BATCH_ID,NULL,'pon_attribute_scores_interface','PON','PON_AUC_FROM_TO_ERR_NUM_R',l_from_range_num );
              l_status :='N';
              RETURN;
            END IF;
          END IF;
          IF(l_from_range_num IS NOT NULL AND l_to_range_num IS NOT NULL AND t_from_range_num IS NOT NULL AND t_to_range_num IS NOT NULL ) THEN
            BEGIN
              SELECT 'N'
              INTO l_status
              FROM dual
              WHERE (l_from_range_num BETWEEN t_from_range_num AND t_to_range_num)
              OR (l_to_range_num BETWEEN t_from_range_num AND t_to_range_num);
            EXCEPTION
            WHEN No_Data_Found THEN
              l_status:=NULL;
            END;
          END IF;
          l_status  :=NVL(l_status,'Y');
          IF(l_status='N') THEN
            pon_auc_interface_table_pkg.insert_error_interface ( p_attr_score_rec.l_BATCH_ID,NULL,'pon_attribute_scores_interface','PON','PON_AUC_OVERLAP_RANGES',p_attr_score_rec.l_from_range );
            RETURN;
          END IF;
        END;
      END LOOP;
    END IF;
  END IF;
  /* if datatype is date*/
  IF(p_datatype='DAT')THEN
    BEGIN
      SELECT To_date(NVL(p_attr_score_rec.l_from_range,sysdate),'dd-mm-yyyy'),
        To_date(NVL(p_attr_score_rec.l_to_range,sysdate),'dd-mm-yyyy')
      INTO l_from_range_dat,
        l_to_range_dat
      FROM dual;
    EXCEPTION
    WHEN OTHERS THEN
      print_log(l_module, 'Invalid date value');
      l_status:='N';
      RETURN;
    END;
    l_from_range_dat    :=To_date(p_attr_score_rec.l_from_range,'dd-mm-yyyy');
    l_to_range_dat      :=To_date(p_attr_score_rec.l_to_range,'dd-mm-yyyy');
    IF(l_from_range_dat IS NOT NULL AND l_to_range_dat IS NOT NULL) THEN
      IF(l_from_range_dat> l_to_range_dat)THEN
        pon_auc_interface_table_pkg.insert_error_interface ( p_attr_score_rec.l_BATCH_ID,NULL,'pon_attribute_scores_interface','PON','PON_AUC_FROM_TO_ERR_NUM_R',l_from_range_dat );
        l_status :='N';
        RETURN;
      END IF;
    END IF;
    SELECT COUNT(*)
    INTO l_count
    FROM pon_attribute_scores
    WHERE auction_header_id      =p_attr_score_rec.l_auction_header_id
    AND attribute_sequence_number=p_attr_score_rec.l_attribute_sequence_number;
    IF(l_count                   < 1)THEN
      l_status                  :='Y';
      RETURN;
    ELSE
      OPEN c_score_overlap;
      LOOP
        -- fetch the data
        FETCH c_score_overlap INTO l_from_range, l_to_range ;
        EXIT
      WHEN c_score_overlap%NOTFOUND;
        BEGIN
          t_from_range_dat      :=To_date(l_from_range,'dd-mm-yyyy');
          t_to_range_dat        :=To_date(l_to_range,'dd-mm-yyyy');
          IF(t_from_range_dat   IS NULL OR l_to_range_dat IS NULL ) THEN
            IF(l_from_range_dat <=t_to_range_dat) THEN
              pon_auc_interface_table_pkg.insert_error_interface ( p_attr_score_rec.l_BATCH_ID,NULL,'pon_attribute_scores_interface','PON','PON_AUC_FROM_TO_ERR_NUM_R',l_from_range_dat );
              l_status :='N';
              RETURN;
            END IF;
          END IF;
          IF(t_to_range_dat   IS NULL OR l_from_range_dat IS NULL ) THEN
            IF(l_to_range_dat >=t_from_range_dat) THEN
              pon_auc_interface_table_pkg.insert_error_interface ( p_attr_score_rec.l_BATCH_ID,NULL,'pon_attribute_scores_interface','PON','PON_AUC_FROM_TO_ERR_NUM_R',l_from_range_dat );
              l_status :='N';
              RETURN;
            END IF;
          END IF;
          IF(l_from_range_dat IS NOT NULL AND l_to_range_dat IS NOT NULL AND t_from_range_dat IS NOT NULL AND t_to_range_dat IS NOT NULL ) THEN
            BEGIN
              SELECT 'N'
              INTO l_status
              FROM dual
              WHERE (l_from_range_dat BETWEEN t_from_range_dat AND t_to_range_dat)
              OR (l_to_range_dat BETWEEN t_from_range_dat AND t_to_range_dat);
            EXCEPTION
            WHEN No_Data_Found THEN
              l_status:=NULL;
            END;
          END IF;
          l_status  :=NVL(l_status,'Y');
          IF(l_status='N') THEN
            pon_auc_interface_table_pkg.insert_error_interface ( p_attr_score_rec.l_BATCH_ID,NULL,'pon_attribute_scores_interface','PON','PON_AUC_OVERLAP_RANGES',p_attr_score_rec.l_from_range );
            RETURN;
          END IF;
        END;
      END LOOP;
    END IF;
  END IF;
END;
-----------------------------------------------------------------------
--Start of Comments
--Name: create_neg_team
--Description : Warpper on PON APIs to copy the data from PON_NEG_TEAM_INTERFACE interface table to PON_NEG_TEAM_MEMBERS
--Parameters:
--IN:
--  p_api_version
--  p_init_msg_list
--  p_commit
--  batchId
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE create_neg_team(
    p_commit        IN VARCHAR2,
    batchId         IN NUMBER,
    x_return_status IN OUT NOCOPY VARCHAR2 )
IS
  /* cursor to get the data from the PON_NEG_TEAM_INTERFACE table */
  CURSOR c_interface_neg_team
  IS
    SELECT *
    FROM PON_NEG_TEAM_INTERFACE
    WHERE BATCH_ID =batchId
    AND user_name <> neg_header_record_data.trading_partner_contact_name;
  c_interface_neg_team_rec c_interface_neg_team%ROWTYPE;
  l_LAST_AMENDMENT_UPDATE PON_AUCTION_ATTRIBUTES.LAST_AMENDMENT_UPDATE%TYPE;
  l_NEG_TEAM_ENABLED_FLAG PON_AUCTION_HEADERS_ALL.NEG_TEAM_ENABLED_FLAG%TYPE;
  l_user_id FND_USER.USER_ID%TYPE;
  l_check  VARCHAR2(20);
  l_module VARCHAR2(250) := g_module_prefix || '.create_neg_team';
BEGIN
  print_log(l_module, 'Entering procedure create_neg_team');
  OPEN c_interface_neg_team;
  LOOP
    FETCH c_interface_neg_team INTO c_interface_neg_team_rec;
    EXIT
  WHEN c_interface_neg_team%NOTFOUND;
    /* If the mode is insert */
    IF(NVL(c_interface_neg_team_rec.ACTION,'INSERT')='INSERT') THEN
      print_log(l_module, 'c_interface_neg_team_rec.user_id' || c_interface_neg_team_rec.user_id);
      create_members_in_collteam(batchid, c_interface_neg_team_rec.user_name,'N',
                            c_interface_neg_team_rec.access_value, c_interface_neg_team_rec.approver_flag,
                            c_interface_neg_team_rec.auction_header_id, c_interface_neg_team_rec.task_name,
                            c_interface_neg_team_rec.target_date,NULL,x_return_status);
    END IF;
    IF( x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.SET_NAME('PON','PON_IMPORT_COLLAB_TEAM_ERR');
      FND_MESSAGE.SET_TOKEN('BATCH_ID',batchId);
      FND_MSG_PUB.ADD;
      RETURN;
    END IF;
    IF(c_interface_neg_team_rec.ACTION='DELETE') THEN
      print_log(l_module, 'In delete condition');
      DELETE
      FROM PON_NEG_TEAM_MEMBERS
      WHERE AUCTION_HEADER_ID = c_interface_neg_team_rec.auction_header_id
      AND USER_ID             =
        (SELECT USER_ID
        FROM fnd_user
        WHERE user_name LIKE Upper(c_interface_neg_team_rec.user_name)
        )
      AND MEMBER_TYPE='N';
      print_log(l_module, 'Record has been deleted');
    END IF;
  END LOOP;
  print_log(l_module, 'Exiting procedure create_neg_team');
EXCEPTION
WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('PON','PON_IMPORT_COLLAB_TEAM_ERR');
  FND_MESSAGE.SET_TOKEN('BATCH_ID',batchId);
  FND_MSG_PUB.ADD;
  x_return_status := FND_API.G_RET_STS_ERROR;
END;
-----------------------------------------------------------------------
--Start of Comments
--Name: create_members_in_collteam
--Description : Warpper on PON APIs to insert the colloboration team members PON_NEG_TEAM_MEMBERS
--Parameters:
--IN:
--  p_api_version
--  p_init_msg_list
--  p_commit
--  batchId
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE create_members_in_collteam(
    batchid               IN NUMBER,
    username              IN VARCHAR2,
    ispreparer            IN VARCHAR2, -- 'Y'/'N'
    menu_name             IN VARCHAR2, -- 'PON_SOURCING_EDITNEG'/'PON_SOURCING_VIEWNEG'/'PON_SOURCING_SCORENEG'
    approver_flag         IN VARCHAR2, -- 'Y'/'N'
    auction_header_id     IN NUMBER,
    task_name             IN VARCHAR2,
    target_date           IN DATE,
    manager_approver_flag IN VARCHAR2,
    x_return_status       IN OUT NOCOPY VARCHAR2 )
IS
  l_full_name PER_ALL_PEOPLE_F.FULL_NAME%TYPE;
  l_employee_number PER_ALL_PEOPLE_F.employee_number%TYPE;
  l_person_id PER_ALL_PEOPLE_F.person_id%TYPE;
  l_business_group_id PER_ALL_PEOPLE_F.BUSINESS_GROUP_ID%TYPE;
  l_effective_start_date PER_ALL_PEOPLE_F.EFFECTIVE_START_DATE%TYPE;
  l_effective_end_date PER_ALL_PEOPLE_F.EFFECTIVE_END_DATE%TYPE;
  l_position PER_ALL_POSITIONS.name%TYPE;
  l_user_name fnd_user.USER_NAME%TYPE;
  l_user_id fnd_user.USER_ID%TYPE;
  l_employee_id fnd_user.EMPLOYEE_ID%TYPE;
  l_user_start_date fnd_user.START_DATE%TYPE;
  l_user_end_date fnd_user.END_DATE%TYPE;
  l_menu_name PON_NEG_TEAM_MEMBERS.menu_name%TYPE;
  l_member_type PON_NEG_TEAM_MEMBERS.member_type%TYPE;
  l_approver_flag PON_NEG_TEAM_MEMBERS.approver_flag%TYPE;
  lm_full_name PER_ALL_PEOPLE_F.FULL_NAME%TYPE;
  lm_employee_number PER_ALL_PEOPLE_F.employee_number%TYPE;
  lm_person_id PER_ALL_PEOPLE_F.person_id%TYPE;
  lm_business_group_id PER_ALL_PEOPLE_F.BUSINESS_GROUP_ID%TYPE;
  lm_effective_start_date PER_ALL_PEOPLE_F.EFFECTIVE_START_DATE%TYPE;
  lm_effective_end_date PER_ALL_PEOPLE_F.EFFECTIVE_END_DATE%TYPE;
  lm_position PER_ALL_POSITIONS.name%TYPE;
  lm_user_name fnd_user.USER_NAME%TYPE;
  lm_user_id fnd_user.USER_ID%TYPE;
  lm_employee_id fnd_user.EMPLOYEE_ID%TYPE;
  lm_user_start_date fnd_user.START_DATE%TYPE;
  lm_user_end_date fnd_user.END_DATE%TYPE;
  l_auction_header_id PON_NEG_TEAM_MEMBERS.auction_header_id%TYPE;
  l_neg_team_enabled_flag pon_auction_headers_all.NEG_TEAM_ENABLED_FLAG%TYPE;
  l_module VARCHAR2(250) := g_module_prefix || '.create_members_in_collteam';
BEGIN
  l_auction_header_id:=auction_header_id;
  print_log(l_module, 'create_members_in_collteam begin: auction_header_id ' || auction_header_id || ' username ' || username);
  IF (ispreparer     ='Y') THEN
    l_menu_name     := 'PON_SOURCING_EDITNEG';
    l_member_type   := 'C';
    l_approver_flag := 'N';
    --Getting the user information for creating creator in colloboration team
    IF (username IS NOT NULL) THEN
      BEGIN
        SELECT DISTINCT PER.FULL_NAME ,
          EMP.USER_NAME ,
          EMP.USER_ID ,
          EMP.EMPLOYEE_ID
        INTO l_full_name ,
          l_user_name ,
          l_user_id ,
          l_employee_id
        FROM PER_ALL_ASSIGNMENTS_F ASS,
          FND_USER EMP ,
          PER_ALL_PEOPLE_F PER ,
          PER_ALL_POSITIONS POS
        WHERE ASS.PERSON_ID           = EMP.EMPLOYEE_ID
        AND ASS.POSITION_ID           = POS.POSITION_ID(+)
        AND ASS.PRIMARY_FLAG          = 'Y'
        AND ((ASS.ASSIGNMENT_TYPE     = 'E'
        AND PER.CURRENT_EMPLOYEE_FLAG = 'Y')
        OR (ASS.ASSIGNMENT_TYPE       = 'C'
        AND PER.CURRENT_NPW_FLAG      = 'Y'))
        AND TRUNC(SYSDATE) BETWEEN ASS.EFFECTIVE_START_DATE AND ASS.EFFECTIVE_END_DATE
        AND PER.PERSON_ID = EMP.EMPLOYEE_ID
        AND EMP.USER_NAME = username
        AND TRUNC(SYSDATE) BETWEEN PER.EFFECTIVE_START_DATE AND PER.EFFECTIVE_END_DATE;
      EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END;
    END IF;
    IF NOT (check_uniqueness(l_user_id,auction_header_id,ispreparer)) THEN
      print_log(l_module, 'User Already exists');
      RETURN;
    ELSE
      insert_collabteam_member(auction_header_id, -- auction_header_id
      l_user_id,                                  -- user_id from fnd
      l_user_name,                                -- user_name from fnd
      l_menu_name,                                -- MenuName
      l_member_type,                              -- Member Type
      NVL(l_approver_flag,'N'),                   -- Approver_flag
      task_name,                                  -- Task Name
      target_date,                                -- Target_date
      SYSDATE,                                    -- Creation_date
      fnd_global.user_id,                         -- Created_by
      SYSDATE,                                    -- last_update_date
      fnd_global.user_id);                        -- last_updated_by
    END IF;
    -- Getting the manager and manager info of the creator of the solicitation
    BEGIN
      SELECT DISTINCT PER.FULL_NAME ,
        SUP.USER_NAME ,
        SUP.USER_ID ,
        SUP.EMPLOYEE_ID
      INTO lm_full_name ,
        lm_user_name ,
        lm_user_id ,
        lm_employee_id
      FROM PER_ALL_ASSIGNMENTS_F ASS,
        PER_ALL_ASSIGNMENTS_F SUPASS ,
        FND_USER SUP ,
        FND_USER EMP ,
        PER_ALL_PEOPLE_F PER ,
        PER_ALL_POSITIONS POS
      WHERE ASS.PERSON_ID      = EMP.EMPLOYEE_ID
      AND ASS.SUPERVISOR_ID    = SUP.EMPLOYEE_ID
      AND ASS.PRIMARY_FLAG     = 'Y'
      AND ASS.ASSIGNMENT_TYPE IN ('E', 'C')
      AND TRUNC(SYSDATE) BETWEEN ASS.EFFECTIVE_START_DATE AND ASS.EFFECTIVE_END_DATE
      AND SUPASS.PERSON_ID          = ASS.SUPERVISOR_ID
      AND SUPASS.POSITION_ID        = POS.POSITION_ID(+)
      AND SUPASS.PRIMARY_FLAG       = 'Y'
      AND ((SUPASS.ASSIGNMENT_TYPE  = 'E'
      AND PER.CURRENT_EMPLOYEE_FLAG = 'Y')
      OR (SUPASS.ASSIGNMENT_TYPE    = 'C'
      AND PER.CURRENT_NPW_FLAG      = 'Y'))
      AND TRUNC(SYSDATE) BETWEEN PER.EFFECTIVE_START_DATE AND PER.EFFECTIVE_END_DATE
      AND TRUNC(SYSDATE) BETWEEN SUPASS.EFFECTIVE_START_DATE AND SUPASS.EFFECTIVE_END_DATE
      AND SUP.START_DATE             <= SYSDATE
      AND NVL(SUP.END_DATE, SYSDATE) >= SYSDATE
      AND PER.PERSON_ID               = SUP.EMPLOYEE_ID
      AND EMP.USER_NAME               = username;
      insert_collabteam_member(auction_header_id, -- auction_header_id
      lm_user_id,                                 -- user_id from fnd
      lm_user_name,                               -- user_name from fnd
      'PON_SOURCING_EDITNEG',                     -- MenuName
      'M',                                        -- Member Type
      NVL(manager_approver_flag,'Y'),             -- Approver_flag
      task_name,                                  -- Task Name
      target_date,                                -- Target_date
      SYSDATE,                                    -- Creation_date
      fnd_global.user_id,                         -- Created_by
      SYSDATE,                                    -- last_update_date
      fnd_global.user_id);                        -- last_updated_by
    EXCEPTION
    WHEN OTHERS THEN
      -- need to raise the sql exception if any encountered
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END;
  ELSE
    l_member_type := 'N';
    BEGIN
      SELECT DISTINCT NEG_TEAM_ENABLED_FLAG
      INTO l_neg_team_enabled_flag
      FROM pon_auction_headers_all
      WHERE auction_header_id = l_auction_header_id;
    EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      print_Log(l_module, 'Error '|| SQLERRM );
    END;
    IF ((l_neg_team_enabled_flag = 'N') AND (ispreparer = 'N')) THEN
      RETURN;
    END IF;
    print_log(l_module, 'checking for the validity of the user name');
    BEGIN
      SELECT user_id
      INTO l_user_id
      FROM
        (SELECT users.user_id
        FROM pon_employees_current_v emp,
          fnd_user users ,
          hr_all_organization_units_tl orgs
        WHERE emp.person_id               = users.employee_id
        AND users.start_date             <= SYSDATE
        AND NVL(users.end_date, SYSDATE) >= SYSDATE
        AND emp.organization_id           = orgs.organization_id
        AND orgs.language                 = USERENV('LANG')
        AND users.user_name LIKE Upper(username)
        );
    EXCEPTION
    WHEN No_Data_Found THEN
      l_user_id:=NULL;
      print_log(l_module, 'Invalid username');
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END;
    IF NOT (check_uniqueness(l_user_id,auction_header_id,ispreparer)) THEN
      print_Log(l_module, 'User name already exists');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Error message must be thrown
      RETURN;
    ELSE
      print_log(l_module, 'Inserting the record');
      insert_collabteam_member(auction_header_id, -- auction_header_id
      l_user_id,                                  -- user_id from fnd
      username,                                   -- user_name from fnd
      NVL(menu_name,'PON_SOURCING_SCORENEG'),     -- MenuName
      'N',                                        -- Member Type
      NVL(approver_flag,'N'),                     -- Approver_flag
      task_name,                                  -- Task Name
      target_date,                                -- Target_date
      SYSDATE,                                    -- Creation_date
      fnd_global.user_id,                         -- Created_by
      SYSDATE,                                    -- last_update_date
      fnd_global.user_id);                        -- last_updated_by
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  print_Log(l_module, 'Exception encountered in  create_members_in_collteam');
  x_return_status := FND_API.G_RET_STS_ERROR;
END create_members_in_collteam;
FUNCTION check_uniqueness(
    p_user_id           IN NUMBER,
    p_auction_header_id IN NUMBER,
    ispreparer          IN VARCHAR2)
  RETURN BOOLEAN
IS
  l_count  NUMBER        := 0;
  l_count1 NUMBER        := 0;
  l_module VARCHAR2(250) := g_module_prefix || '.check_uniqueness';
BEGIN
  SELECT COUNT(*)
  INTO l_count
  FROM PON_NEG_TEAM_MEMBERS pnt
  WHERE pnt.auction_header_id = p_auction_header_id
  AND pnt.list_id             = -1
  AND pnt.user_id             = p_user_id;
  IF (l_count                 > 0 ) THEN
    RETURN(FALSE);
  ELSE
    RETURN(TRUE);
  END IF;
  IF (NVL(ispreparer,'N') = 'Y') THEN
    SELECT COUNT(*)
    INTO l_count1
    FROM PON_NEG_TEAM_MEMBERS pnt
    WHERE pnt.auction_header_id = p_auction_header_id
    AND PNT.LIST_ID             = -1
    AND member_type             = 'C';
    IF (l_count                 > 0 ) THEN
      -- set the error as already a preparer is existing in the colloboration team
      RETURN(FALSE);
    ELSE
      RETURN(TRUE);
    END IF;
  END IF;
END check_uniqueness;
PROCEDURE insert_collabteam_member(
    auction_header_id IN NUMBER,
    user_id           IN NUMBER,
    user_name         IN VARCHAR2,
    menu_name         IN VARCHAR2,
    member_type       IN VARCHAR2,
    approver_flag     IN VARCHAR2,
    task_name         IN VARCHAR2,
    target_date       IN DATE,
    creation_date     IN DATE,
    created_by        IN NUMBER,
    last_update_date  IN DATE,
    last_updated_by   IN NUMBER)
IS
  l_user_id NUMBER;
  l_module  VARCHAR2(250) := g_module_prefix || '.insert_collabteam_member';
BEGIN
  INSERT
  INTO PON_NEG_TEAM_MEMBERS
    (
      auction_header_id,
      list_id ,
      user_name ,
      menu_name ,
      member_type ,
      approver_flag ,
      task_name ,
      target_date ,
      creation_date ,
      created_by ,
      last_update_date ,
      last_updated_by ,
      user_id
    )
    VALUES
    (
      auction_header_id,
      -1 ,
      user_name ,
      menu_name ,
      member_type ,
      approver_flag ,
      task_name ,
      target_date ,
      creation_date ,
      created_by ,
      last_update_date ,
      last_updated_by ,
      user_id
    );
EXCEPTION
WHEN OTHERS THEN
  NULL;
  --RAISE SQL EXCEPTION
END insert_collabteam_member;
-----------------------------------------------------------------------
--Start of Comments
--Name: invite_supplier
--Description : Warpper on PON APIs to copy the data from PON_BID_PARTIES_INTERFACE interface table to PON_BIDDING_PARTIES table
--Parameters:
--IN:
--  p_api_version
--  p_init_msg_list
--  p_commit
--  batchId
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE invite_supplier
  (
    p_batch_id      IN NUMBER,
    x_return_status IN OUT NOCOPY VARCHAR2
  )
IS
  CURSOR c_invitee_supplier
  IS
    SELECT * FROM pon_bid_parties_interface WHERE batch_id=p_batch_id;
  c_invitee_supplier_rec c_invitee_supplier%ROWTYPE;
  l_BATCH_ID PON_BID_PARTIES_INTERFACE.BATCH_ID%TYPE;
  l_AUCTION_HEADER_ID PON_BID_PARTIES_INTERFACE.AUCTION_HEADER_ID%TYPE;
  l_SEQUENCE PON_BID_PARTIES_INTERFACE.SEQUENCE_NUMBER%TYPE;
  l_VENDOR_NAME PON_BID_PARTIES_INTERFACE.VENDOR_NAME%TYPE;
  l_VENDOR_ID PON_BID_PARTIES_INTERFACE.VENDOR_ID%TYPE;
  l_VENDOR_SITE_ID PON_BID_PARTIES_INTERFACE.VENDOR_SITE_ID%TYPE;
  l_VENDOR_SITE_CODE PON_BID_PARTIES_INTERFACE.VENDOR_SITE_CODE%TYPE;
  l_TRADING_PARTNER_CONTACT_NAME PON_BID_PARTIES_INTERFACE.TRADING_PARTNER_CONTACT_NAME%TYPE;
  l_TRADING_PARTNER_CONTACT_ID PON_BID_PARTIES_INTERFACE.TRADING_PARTNER_CONTACT_ID%TYPE;
  l_ADDITIONAL_CONTACT_EMAIL PON_BID_PARTIES_INTERFACE.ADDITIONAL_CONTACT_EMAIL%TYPE;
  l_ACTION PON_BID_PARTIES_INTERFACE.ACTION%TYPE;
  l_CREATION_DATE PON_BID_PARTIES_INTERFACE.CREATION_DATE%TYPE;
  l_CREATED_BY PON_BID_PARTIES_INTERFACE.CREATED_BY%TYPE;
  l_LAST_UPDATE_DATE PON_BID_PARTIES_INTERFACE.LAST_UPDATE_DATE%TYPE;
  l_LAST_UPDATED_BY PON_BID_PARTIES_INTERFACE.LAST_UPDATED_BY%TYPE;
  l_LAST_AMENDMENT_UPDATE PON_BIDDING_PARTIES.LAST_AMENDMENT_UPDATE%TYPE;
  L_ORG_ID PON_AUCTION_HEADERS_ALL.ORG_ID%TYPE;
  l_TRADING_PARTNER_ID PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_ID%TYPE;
  l_STATUS VARCHAR2(10);
  l_module VARCHAR2(250) := g_module_prefix || '.invite_supplier';
BEGIN
  print_Log(l_module, 'In the invite supplier procedure');
  validate_invited_suppliers(p_batch_id);
  BEGIN
    SELECT 'E' status
    INTO x_return_status
    FROM dual
    WHERE EXISTS
      (SELECT * FROM pon_interface_errors WHERE BATCH_ID= p_batch_Id
      );
  EXCEPTION
  WHEN No_Data_Found THEN
    x_return_status:=FND_API.G_RET_STS_SUCCESS;
  END;
  IF(x_return_status=FND_API.G_RET_STS_ERROR) THEN
    print_Log(l_module, 'Error in PON_BID_PARTIES_INTERFACE table. Please check pon_interface_errors for more details' );
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_SUPPLIER_VAL_ERR');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_Id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  print_log(l_module, 'PON_BID_PARTIES_INTERFACE validation completed');
  OPEN c_invitee_supplier;
  LOOP
    FETCH c_invitee_supplier INTO c_invitee_supplier_rec;
    EXIT
  WHEN c_invitee_supplier%NOTFOUND;
    BEGIN
      l_BATCH_ID                     := p_batch_id;
      l_AUCTION_HEADER_ID            := c_invitee_supplier_rec.AUCTION_HEADER_ID;
      l_SEQUENCE                     :=c_invitee_supplier_rec.SEQUENCE_NUMBER;
      l_VENDOR_NAME                  :=c_invitee_supplier_rec.VENDOR_NAME;
      l_VENDOR_ID                    :=c_invitee_supplier_rec.VENDOR_ID;
      l_VENDOR_SITE_ID               :=c_invitee_supplier_rec.VENDOR_SITE_ID;
      l_VENDOR_SITE_CODE             :=c_invitee_supplier_rec.VENDOR_SITE_CODE;
      l_TRADING_PARTNER_CONTACT_NAME :=c_invitee_supplier_rec.TRADING_PARTNER_CONTACT_NAME;
      l_TRADING_PARTNER_CONTACT_ID   :=c_invitee_supplier_rec.TRADING_PARTNER_CONTACT_ID;
      l_ADDITIONAL_CONTACT_EMAIL     :=c_invitee_supplier_rec.ADDITIONAL_CONTACT_EMAIL;
      l_ACTION                       :=c_invitee_supplier_rec.ACTION;
      l_CREATION_DATE                :=SYSDATE;
      l_CREATED_BY                   :=FND_GLOBAL.USER_ID;
      l_LAST_UPDATE_DATE             :=SYSDATE;
      l_LAST_UPDATED_BY              :=FND_GLOBAL.USER_ID;
      /*** If the action is insert ***/
      IF (NVL(L_ACTION,'INSERT')='INSERT') THEN
        -- If the vendor_name and vendor_id is not null
        IF (L_VENDOR_NAME IS NOT NULL) THEN
          SELECT VENDOR_ID,
            PARTY_ID
          INTO L_VENDOR_ID,
            l_TRADING_PARTNER_ID
          FROM AP_SUPPLIERS
          WHERE VENDOR_NAME=L_VENDOR_NAME;
          -- if vendor_name is null and vendor_id is not null
        ELSIF (L_VENDOR_ID IS NOT NULL) THEN
          SELECT VENDOR_NAME,
            PARTY_ID
          INTO L_VENDOR_NAME,
            l_TRADING_PARTNER_ID
          FROM AP_SUPPLIERS
          WHERE VENDOR_ID=L_VENDOR_ID;
        END IF;
        /****** Get Outcome Operating Unit Id ******/
        SELECT ORG_ID
        INTO L_ORG_ID
        FROM PON_AUCTION_HEADERS_ALL
        WHERE AUCTION_HEADER_ID = l_AUCTION_HEADER_ID;
        -- If vendor_site_id and vendor_site_code is not null
        IF (L_VENDOR_SITE_ID IS NOT NULL) THEN
          SELECT VENDOR_SITE_CODE
          INTO L_VENDOR_SITE_CODE
          FROM AP_SUPPLIER_SITES_ALL
          WHERE VENDOR_SITE_ID=L_VENDOR_SITE_ID
          AND ORG_ID          =L_ORG_ID;
          -- If vendor_site_id is null and vendor_site_code is not null
        ELSIF (L_VENDOR_SITE_CODE IS NOT NULL) THEN
          SELECT VENDOR_SITE_ID
          INTO L_VENDOR_SITE_ID
          FROM AP_SUPPLIER_SITES_ALL
          WHERE VENDOR_SITE_CODE=L_VENDOR_SITE_CODE
          AND ORG_ID            =L_ORG_ID;
        END IF;
        -- If the trading_partner_contact_id is not null
        IF (L_TRADING_PARTNER_CONTACT_ID IS NOT NULL) THEN
          SELECT PERSON_LAST_NAME
            ||','
            ||PERSON_FIRST_NAME
          INTO L_TRADING_PARTNER_CONTACT_NAME
          FROM HZ_PARTIES
          WHERE PARTY_ID=L_TRADING_PARTNER_CONTACT_ID;
        END IF;
        -- check if the Supplier has been invited multiple times for the same Supplier Site or without a Supplier Site selection
        BEGIN
          SELECT 'Y'
          INTO l_status
          FROM PON_BIDDING_PARTIES
          WHERE TRADING_PARTNER_NAME=L_VENDOR_NAME
          AND VENDOR_SITE_ID        =NVL(L_VENDOR_SITE_ID,VENDOR_SITE_ID)
          AND auction_header_id     =l_auction_header_id;
        EXCEPTION
        WHEN No_Data_Found THEN
          l_status:=NULL;
        END;
        IF(l_status='Y') THEN
          print_log(l_module, 'Supplier cannot be invited multiple times for the same Supplier Site or without a Supplier Site selection. Please select distinct Supplier Sites when inviting a supplier multiple times.');
          x_return_status := 'E';
          FND_MESSAGE.SET_NAME('PON','PON_IMPORT_SUPPLIER_MUL');
          FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
          FND_MESSAGE.SET_TOKEN('VENDOR_NAME',L_VENDOR_NAME);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        /* getting the amendment number */
        BEGIN
          SELECT MAX(amendment_number)
          INTO l_LAST_AMENDMENT_UPDATE
          FROM pon_auction_headers_all
          WHERE AUCTION_HEADER_ID = l_AUCTION_HEADER_ID;
        EXCEPTION
        WHEN No_Data_Found THEN
          l_LAST_AMENDMENT_UPDATE:= NULL;
        END;
        l_LAST_AMENDMENT_UPDATE:= NVL(l_LAST_AMENDMENT_UPDATE,0);
        /* Insert Into PON_BIDDING_PARTIES */
        INSERT
        INTO PON_BIDDING_PARTIES
          (
            AUCTION_HEADER_ID ,
            LIST_ID ,
            SEQUENCE ,
            TRADING_PARTNER_NAME ,
            TRADING_PARTNER_ID ,
            TRADING_PARTNER_CONTACT_NAME,
            TRADING_PARTNER_CONTACT_ID ,
            VENDOR_SITE_ID ,
            VENDOR_SITE_CODE ,
            ADDITIONAL_CONTACT_EMAIL ,
            ACCESS_TYPE ,
            ROUND_NUMBER ,
            LAST_AMENDMENT_UPDATE ,
            CREATION_DATE ,
            CREATED_BY ,
            LAST_UPDATE_DATE ,
            LAST_UPDATED_BY
          )
          VALUES
          (
            L_AUCTION_HEADER_ID ,
            -1 ,
            L_SEQUENCE ,
            L_VENDOR_NAME ,
            L_TRADING_PARTNER_ID ,
            L_TRADING_PARTNER_CONTACT_NAME,
            L_TRADING_PARTNER_CONTACT_ID ,
            NVL(L_VENDOR_SITE_ID,  -1) ,
            NVL(L_VENDOR_SITE_CODE,-1) ,
            L_ADDITIONAL_CONTACT_EMAIL ,
            'FULL' ,
            1 ,
            L_LAST_AMENDMENT_UPDATE ,
            L_CREATION_DATE ,
            L_CREATED_BY ,
            L_LAST_UPDATE_DATE ,
            L_LAST_UPDATED_BY
          );
      END IF;
      print_log(l_module, 'End of the procedure invitee_supplier');
    END;
  END LOOP;
END invite_supplier;
PROCEDURE validate_invited_suppliers
  (
    p_batch_id IN NUMBER
  )
AS
  l_cp_user_id  NUMBER;
  l_cp_login_id NUMBER;
  l_module      VARCHAR2(250) := g_module_prefix || '.validate_invited_suppliers';
BEGIN
  l_cp_user_id  := fnd_global.user_id;
  l_cp_login_id := fnd_global.login_id;
  INSERT ALL
    WHEN (sel_vendor_name IS NULL
    AND sel_vendor_id     IS NULL ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      COLUMN_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_FIELD_MUST_BE_ENTERED',
      'VENDOR_NAME',
      p_batch_id,
      'PON_BID_PARTIES_INTERFACE',
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN (sel_vendor_name IS NOT NULL
    AND sel_vendor_id     IS NOT NULL
    AND NOT EXISTS
      (SELECT 1
      FROM AP_SUPPLIERS
      WHERE VENDOR_NAME=sel_vendor_name
      AND VENDOR_ID    =sel_vendor_id
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      TOKEN1_NAME,
      TOKEN1_VALUE,
      BATCH_ID ,
      ENTITY_TYPE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_IMPORT_INV_VENDOR',
      'VENDOR_NAME',
      sel_vendor_name,
      p_batch_id,
      'PON_BID_PARTIES_INTERFACE',
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN (sel_vendor_id IS NOT NULL
    AND NOT EXISTS
      (SELECT 1 FROM AP_SUPPLIERS WHERE VENDOR_ID=sel_vendor_id
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      TOKEN1_NAME,
      TOKEN1_VALUE,
      BATCH_ID ,
      ENTITY_TYPE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_IMPORT_INV_VENDORID',
      'VENDOR_ID',
      sel_vendor_id,
      p_batch_id,
      'PON_BID_PARTIES_INTERFACE',
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN (sel_vendor_NAME IS NOT NULL
    AND NOT EXISTS
      (SELECT 1 FROM AP_SUPPLIERS WHERE VENDOR_NAME=sel_vendor_NAME
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      TOKEN1_NAME,
      TOKEN1_VALUE,
      BATCH_ID ,
      ENTITY_TYPE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_IMPORT_INV_VENDORNAME',
      'VENDOR_NAME',
      sel_vendor_NAME,
      p_batch_id,
      'PON_BID_PARTIES_INTERFACE',
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN (sel_vendor_site_code IS NOT NULL
    AND sel_vendor_site_id     IS NOT NULL
    AND NOT EXISTS
      (SELECT 1
      FROM AP_SUPPLIER_SITES_ALL
      WHERE vendor_site_code=sel_vendor_site_code
      AND vendor_site_id    =sel_vendor_site_id
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      TOKEN1_NAME,
      TOKEN1_VALUE,
      BATCH_ID ,
      ENTITY_TYPE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_IMPORT_INV_VENDORSITE',
      'VENDOR_SITE',
      sel_vendor_site_code,
      p_batch_id,
      'PON_BID_PARTIES_INTERFACE',
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN (sel_vendor_site_id IS NOT NULL
    AND NOT EXISTS
      (SELECT 1 FROM AP_SUPPLIER_SITES_ALL WHERE vendor_site_id=sel_vendor_site_id
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      TOKEN1_NAME,
      TOKEN1_VALUE,
      BATCH_ID ,
      ENTITY_TYPE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_IMPORT_INV_VENDORSITEID',
      'SITE_ID',
      sel_vendor_site_id,
      p_batch_id,
      'PON_BID_PARTIES_INTERFACE',
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN (sel_vendor_site_code IS NOT NULL
    AND NOT EXISTS
      (SELECT 1
      FROM AP_SUPPLIER_SITES_ALL
      WHERE vendor_site_code=sel_vendor_site_code
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      TOKEN1_NAME,
      TOKEN1_VALUE,
      BATCH_ID ,
      ENTITY_TYPE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_IMPORT_INV_VENDORSITECODE',
      'SITE_CODE',
      sel_vendor_site_code,
      p_batch_id,
      'PON_BID_PARTIES_INTERFACE',
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN (sel_tpc_id IS NOT NULL
    AND NOT EXISTS
      (SELECT 1 FROM hz_parties WHERE party_id=sel_tpc_id
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      TOKEN1_NAME,
      TOKEN1_VALUE,
      BATCH_ID ,
      ENTITY_TYPE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_IMPORT_INV_VENDORTPC',
      'TPC',
      sel_tpc_id,
      p_batch_id,
      'PON_BID_PARTIES_INTERFACE',
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN (sel_tpc_id IS NULL
    AND sel_add_mail IS NULL) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      COLUMN_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_FIELD_MUST_BE_ENTERED',
      'trading_partner_contact_name',
      p_batch_id,
      'PON_BID_PARTIES_INTERFACE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
  SELECT vendor_name sel_vendor_name,
    vendor_id sel_vendor_id,
    vendor_site_code sel_vendor_site_code,
    vendor_site_id sel_vendor_site_id,
    trading_partner_contact_id sel_tpc_id,
    trading_partner_contact_name sel_tpc_name,
    additional_contact_email sel_add_mail
  FROM pon_bid_parties_interface
  WHERE batch_id = p_batch_id
  AND action     ='INSERT';
END validate_invited_suppliers;
PROCEDURE line_level_validation(
    p_batch_id                   IN NUMBER,
    p_doctype_id                 IN NUMBER,
    p_trading_partner_id         IN NUMBER,
    p_trading_partner_contact_id IN NUMBER,
    p_curr_lang                  IN VARCHAR2,
    p_contract_type              IN VARCHAR2,
    p_global_flag                IN VARCHAR,
    p_org_id                     IN NUMBER,
    p_precision                  IN NUMBER,
    p_is_complex                 IN VARCHAR2,
    x_return_status              IN OUT NOCOPY VARCHAR2 )
AS
  --  PRAGMA AUTONOMOUS_TRANSACTION;
  dummy    NUMBER;
  l_module VARCHAR2(250) := g_module_prefix || '.line_level_validation';
BEGIN
  print_log(l_module, 'line_level_validation begin ');
  line_sanity_validation(p_batch_id);
  PON_VALIDATE_ITEM_PRICES_INT.VALIDATE('ITEMUPLOAD', p_batch_id, p_doctype_id, fnd_global.user_id, p_trading_partner_id, p_trading_partner_contact_id, p_curr_lang, p_contract_type, p_global_flag, p_org_id );
  print_log(l_module, 'line_level_validation:  PON_VALIDATE_ITEM_PRICES_INT.VALIDATE completed');
  validate_costfactor_data(p_batch_id); -- bug 16852025
  pon_auc_interface_table_pkg.validate_price_elements('ITEMUPLOAD', p_batch_id, p_precision, p_precision );
  print_log(l_module, 'line_level_validation:  pon_auc_interface_table_pkg.validate_price_elements completed');
  pon_auc_interface_table_pkg.validate_price_differentials('ITEMUPLOAD', p_batch_id );
  print_log(l_module, 'line_level_validation:  pon_auc_interface_table_pkg.validate_price_differentials completed');
  validate_attribute_data(p_batch_id); -- bug 16852037
  pon_auc_interface_table_pkg.validate_attributes('ITEMUPLOAD', p_batch_id, p_trading_partner_id );
  print_log(l_module, 'line_level_validation:  pon_auc_interface_table_pkg.validate_attributes completed');
  IF(NVL(p_is_complex,'N') = 'Y') THEN
    pon_validate_payments_int.validate_creation('NEGPYMTUPLOAD', p_batch_id);
  END IF;
  --  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  print_log(l_module, 'An error occured while validating the line. please check the pon_interface_errors table for error information');
  print_log(l_module, 'sqlcode ' || SQLCODE || 'sqlerror ' || SQLERRM);
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.SET_NAME('PON','PON_IMPORT_LINES_VAL_ERR');
  FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
  FND_MSG_PUB.ADD;
  RAISE FND_API.G_EXC_ERROR;
END line_level_validation;
/*
* Procedure to take data from lines interface tables and create records
* in main transaction tables
*/
PROCEDURE create_lines_with_children(
    p_batch_id          IN NUMBER,
    p_auction_Header_id IN NUMBER,
    x_return_status     IN OUT NOCOPY VARCHAR2)
AS
  x_number_of_lines      NUMBER;
  x_max_disp_line        NUMBER;
  x_last_line_close_date DATE;
  x_result               VARCHAR2(1);
  x_error_code           VARCHAR2(10);
  x_error_message        VARCHAR2(50);
  l_doctype_id pon_auction_headers_all.doctype_id%type;
  g_user_id fnd_user.user_id%type;
  l_trading_partner_id pon_auction_headers_all.trading_partner_id%type;
  l_trading_partner_contact_id pon_auction_headers_all.trading_partner_contact_id%type;
  l_contract_type pon_auction_headers_all.contract_type%type;
  l_global_flag pon_auction_headers_all.global_agreement_flag%type;
  l_org_id pon_auction_headers_all.org_id%type;
  l_currency_code pon_auction_headers_all.currency_code%type;
  l_price_precision NUMBER;
  l_auction_round_number pon_auction_headers_all.auction_round_number%type;
  l_amendment_number pon_auction_headers_all.amendment_number%TYPE;
  c_att_name pon_auc_attributes_interface.attribute_name%TYPE;
  c_line_num pon_auc_attributes_interface.auction_line_number%TYPE;
  c_seq_num pon_auc_attributes_interface.sequence_number%TYPE;
  c_seq_num2 pon_auc_attributes_interface.sequence_number%TYPE;
  l_scores_absent VARCHAR2(1) := 'N';
  l_precision     NUMBER;
  l_ext_precision NUMBER;
  l_minAcctUnit   NUMBER;
  l_status        VARCHAR2(1);
  l_is_complex    VARCHAR2(1);
  l_close_bidding_date pon_auction_headers_all.close_bidding_date%TYPE;
  l_po_start_date pon_auction_headers_all.po_start_date%TYPE;
  l_po_end_date pon_auction_headers_all.po_end_date%TYPE;
  l_price_break_response pon_auction_headers_all.price_break_response%TYPE;
  l_price_tiers_indicator pon_auction_headers_all.price_tiers_indicator%TYPE;
  --l_has_shipments VARCHAR2(1);
  l_module VARCHAR2(250) := g_module_prefix || '.create_lines_with_children';
  CURSOR c_attributes_with_scoring
  IS
    SELECT batch_id ,
      AUCTION_HEADER_ID ,
      auction_LINE_NUMBER,
      SEQUENCE_NUMBER ,
      SCORING_TYPE ,
      datatype ,
      ATTR_MAX_SCORE ,
      WEIGHT
    FROM PON_AUC_ATTRIBUTES_INTERFACE
    WHERE batch_id                = p_batch_id
    AND NVL(SCORING_TYPE,'NONE') <> 'NONE'
    AND auction_LINE_NUMBER      <> -1;
  CURSOR c_new_attributes
  IS
    SELECT paa_int.attribute_name att_name,
      paa_int.auction_line_number line_num ,
      paa_int.sequence_number
    FROM pon_auc_attributes_interface paa_int,
      pon_item_prices_interface p1
    WHERE paa_int.batch_id           = p_batch_id
    AND p1.batch_id                  = paa_int.batch_id
    AND p1.action                    = g_update_action
    AND paa_int.auction_line_number  = p1.auction_line_number
    AND paa_int.auction_LINE_NUMBER <> -1
    AND NOT EXISTS
      (SELECT 'x'
      FROM pon_auction_attributes auction_attributes
      WHERE paa_int.auction_header_id = auction_attributes.auction_header_id
      AND paa_int.auction_line_number = auction_attributes.line_number
      AND paa_int.attribute_name      = auction_attributes.attribute_name
      )
  ORDER BY paa_int.auction_line_number,
    paa_int.sequence_number FOR UPDATE OF sequence_number ;
  CURSOR line_cur
  IS
    SELECT interface_line_id,
      group_type
    FROM pon_item_prices_interface
    WHERE batch_id = p_batch_id FOR UPDATE OF disp_line_number,
      document_disp_line_number,
      sub_line_sequence_number,
      parent_line_number
    ORDER BY interface_line_id;
  parent_seq      NUMBER := 0;
  child_seq       NUMBER := 0;
  parent_line     NUMBER;
  is_child        VARCHAR2(1);
  l_last_line_num NUMBER;
BEGIN
  print_log(l_module, 'create_lines_with_children begin');
  SELECT doctype_id ,
    trading_partner_id ,
    trading_partner_contact_id ,
    contract_type ,
    NVL(GLOBAL_AGREEMENT_FLAG,'N') ,
    DECODE(NVL(progress_payment_type,'NONE'),'NONE','N','Y'),
    org_id ,
    currency_code ,
    NVL(auction_round_number,0) ,
    NVL(amendment_number,0),
    close_bidding_date,
    po_start_date,
    po_end_date,
    price_break_response,
    price_tiers_indicator
  INTO l_doctype_id ,
    l_trading_partner_id ,
    l_trading_partner_contact_id,
    l_contract_type ,
    l_global_flag ,
    L_is_complex ,
    l_org_id ,
    l_currency_code ,
    l_auction_round_number ,
    l_amendment_number ,
    l_close_bidding_date ,
    l_po_start_date ,
    l_po_end_date ,
    l_price_break_response ,
    l_price_tiers_indicator
  FROM pon_auction_headers_all
  WHERE auction_header_id = p_auction_header_id;
  --SELECT fnd_global.user_id INTO g_user_id FROM dual;
  SELECT fnd_global.login_id,
    fnd_global.CURRENT_LANGUAGE
  INTO g_login_id,
    g_curr_lang
  FROM dual;
  g_user_id := fnd_global.user_id;
  /*select fnd_currency.GET_INFO(l_currency_code,l_precision,l_ext_precision,l_minAcctUnit)
  INTO l_price_precision FROM dual;*/
  fnd_currency.GET_INFO(l_currency_code,l_precision,l_ext_precision,l_minAcctUnit);
  print_log(l_module, 'create_lines_with_children: before calling line_level_validation');
  /*
  bug 16855333
  Set null values in following columns with string. This will be used
  in validation procedure
  */
  UPDATE pon_item_prices_interface
  SET item_description         = NVL(item_description,'ITEM_NONE_ENTERED'),
    category_name              = NVL(category_name,'CAT_NONE_ENTERED'),
    unit_of_measure            = NVL(unit_of_measure,'UOM_NONE_ENTERED'),
    ship_to_location           = NVL(ship_to_location,'SHIP_NONE_ENTERED'),
    line_type                  = NVL(line_type,'LINE_TYPE_NONE_ENTERED'),
    item_number                = NVL(item_number,'ITEM_NUMBER_NONE_ENTERED'),
    differential_response_type = NVL(differential_response_type,'DIFF_NONE_ENTERED'),
    group_type                 = NVL(group_type,''),
    ip_category_name           = NVL(ip_category_name,'IP_CAT_NONE_ENTERED')
  WHERE batch_id               = p_batch_id;
  line_level_validation( p_batch_id, l_doctype_id , l_trading_partner_id , l_trading_partner_contact_id , g_curr_lang , l_contract_type , l_global_flag , l_org_id , l_precision , L_is_complex, x_return_status );
  print_log(l_module, 'create_lines_with_children validations complete ');
  BEGIN
    SELECT 'N' status
    INTO l_status
    FROM dual
    WHERE EXISTS
      (SELECT * FROM pon_interface_errors WHERE BATCH_ID= p_batch_Id
      );
  EXCEPTION
  WHEN No_Data_Found THEN
    l_status:=NULL;
  END;
  IF(l_status='N') THEN
    print_log(l_module, 'An error occured while validating the line. please check the pon_interface_errors table for error information');
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_LINES_VAL_ERR');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
    FND_MSG_PUB.ADD;
    --RAISE FND_API.G_EXC_ERROR;
    RETURN;
  END IF;
  print_log(l_module, 'Validations of lines interface tables completed');
  IF (l_auction_round_number > 0 OR l_amendment_number > 0) THEN
    print_log(l_module, 'create_lines_with_children this is an amendment');
    -- this has to be opened here because after SYNCH_FROM_INTERFACE is called,
    -- attributes will get inserted in txn table. Then we can't identify new attributes.
    OPEN c_new_attributes;
    FETCH c_new_attributes INTO c_att_name, c_line_num, c_seq_num;
  END IF;
  print_log(l_module, 'Updating internal line number ');
  FOR rec IN line_cur
  LOOP
    IF rec.group_type IN ('LINE','LOT','GROUP') THEN
      parent_line := rec.interface_line_id;
      parent_seq  := parent_seq + 1;
      child_seq   := 0;
      is_child    := 'N';
    ELSE
      is_child  := 'Y';
      child_seq := child_seq + 1;
    END IF;
    UPDATE pon_item_prices_interface t1
    SET disp_line_number        = rec.interface_line_id,
      sub_line_sequence_number  = DECODE (is_child,'N',parent_seq,child_seq),
      document_disp_line_number = NVL(document_disp_line_number, DECODE (is_child,'N',parent_seq,parent_seq
      || '.'
      || child_seq)),
      parent_line_number=DECODE(is_child,'Y',parent_line)
    WHERE CURRENT OF line_cur;
  END LOOP;
  --g_module_prefix := g_module_prefix || 'create_lines_with_children';
  --print_log('Entered create_lines_with_children procedure');
  print_log(l_module, 'create_lines_with_children before calling PON_CP_INTRFAC_TO_TRANSACTION.SYNCH_FROM_INTERFACE');
  /*
  This api will have code for both adding and updating(amendments/new rounds) lines and its children like
  attributes, cost factors etc. While updating any line, it is expected to insert all children data
  in respective interface tables. The children that are missing from previous amendments
  are assumed as to-be-deleted children and will be deleted from main txn tables.
  */
  PON_CP_INTRFAC_TO_TRANSACTION.SYNCH_FROM_INTERFACE(p_batch_id, p_auction_header_id, g_user_id, l_trading_partner_id, 'N', x_number_of_lines, x_max_disp_line, x_last_line_close_date, x_result, x_error_code, x_error_message );
  print_log(l_module, 'create_lines_with_children  returned from PON_CP_INTRFAC_TO_TRANSACTION.SYNCH_FROM_INTERFACE with x_error_message '|| x_error_message);
  IF (x_error_message <> 'S') THEN
    x_return_status   := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_CREATE_LINES_ERR');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  SELECT MAX(document_disp_line_number)
  INTO l_last_line_num
  FROM pon_auction_item_prices_all
  WHERE auction_header_id = p_auction_header_id
  AND parent_line_number IS NULL;
  UPDATE pon_auction_headers_all pah
  SET
    (
      MAX_INTERNAL_LINE_NUM,
      NUMBER_OF_LINES,
      last_line_number
    )
    =
    (SELECT MAX(line_number),
      COUNT(line_number),
      l_last_line_num
    FROM pon_auction_item_prices_all paip
    WHERE paip.auction_header_id = p_auction_header_id
    )
  WHERE auction_header_id = p_auction_header_id;
  print_log(l_module, 'CP 0001');
  /*
  this loop will be used for amendments. Because for amendments
  PON_CP_INTRFAC_TO_TRANSACTION.SYNCH_FROM_INTERFACE will calculate the attribute sequence number
  for new attributes instead of taking value from interface tables.
  so we will have to update interface tables with new sequence number
  */
  IF (l_auction_round_number > 0 OR l_amendment_number > 0) THEN
    LOOP
      EXIT
    WHEN c_new_attributes%NOTFOUND;
      BEGIN
        SELECT sequence_number
        INTO c_seq_num2
        FROM pon_auction_attributes
        WHERE auction_header_id = p_auction_HEAder_id
        AND line_number         = c_line_num
        AND attribute_name      = c_att_name;
        UPDATE pon_auc_attributes_interface
        SET sequence_number = c_seq_num2
        WHERE CURRENT OF c_new_attributes;
        UPDATE pon_attribute_scores_interface
        SET attribute_sequence_number = c_seq_num2
        WHERE batch_id                = p_batch_id
        AND auction_header_id         = p_auction_header_id
        AND line_number               = c_line_num
        AND attribute_sequence_number = c_seq_num;
      EXCEPTION
      WHEN No_Data_Found THEN
        NULL;
      END;
      FETCH c_new_attributes INTO c_att_name, c_line_num, c_seq_num;
    END LOOP;
    CLOSE c_new_attributes;
  END IF;
  print_log(l_module, 'create_lines_with_children  validation scores');
  -- Insert scores for attributes
  /* PON_CP_INTRFAC_TO_TRANSACTION.SYNCH_FROM_INTERFACE api would have already inserted attributes
  But scores are not yet inserted. Also the above api inserts zero for weight and scores
  in attributes table. This needs to be corrected
  */
  VAL_ATTR_SCORES( p_auction_header_id, NULL, NULL, g_user_id, g_login_id, p_batch_id );
  BEGIN
    SELECT 'N' status
    INTO l_status
    FROM dual
    WHERE EXISTS
      (SELECT * FROM pon_interface_errors WHERE BATCH_ID=p_batch_Id
      );
  EXCEPTION
  WHEN No_Data_Found THEN
    l_status:=NULL;
  END;
  IF(l_status='N') THEN
    print_log(l_module, 'Errors found in validation of scores for line level attributes.' || ' please check the pon_interface_errors table for error information');
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_ATTRSCORES_VAL_ERR');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  print_log(l_module, 'END Validating the data in scores interface table');
  FOR c_scored_atts_rec IN c_attributes_with_scoring
  LOOP
    UPDATE pon_auction_attributes paa
    SET paa.SCORING_TYPE        = c_scored_atts_rec.scoring_type,
      paa.WEIGHT                = c_scored_atts_rec.WEIGHT ,
      paa.ATTR_MAX_SCORE        = c_scored_atts_rec.ATTR_MAX_SCORE
    WHERE paa.auction_header_id = c_scored_atts_rec.auction_header_id
    AND paa.line_number         = c_scored_atts_rec.auction_line_number
    AND paa.sequence_number     = c_scored_atts_rec.sequence_number;
    INSERT
    INTO pon_attribute_scores
      (
        AUCTION_HEADER_ID ,
        LINE_NUMBER ,
        ATTRIBUTE_SEQUENCE_NUMBER,
        VALUE ,
        FROM_RANGE ,
        TO_RANGE ,
        SCORE ,
        ATTRIBUTE_LIST_ID ,
        SEQUENCE_NUMBER ,
        CREATION_DATE ,
        CREATED_BY ,
        LAST_UPDATE_DATE ,
        LAST_UPDATED_BY
      )
    SELECT p_auction_Header_id ,
      pasi.line_number ,
      pasi.attribute_sequence_number ,
      DECODE(c_scored_atts_rec.datatype,'TXT',pasi.Value,NULL) ,
      DECODE(c_scored_atts_rec.datatype,'DAT',pasi.FROM_RANGE,'NUM',pasi.FROM_range,NULL),
      DECODE(c_scored_atts_rec.datatype,'DAT',pasi.TO_RANGE,'NUM',pasi.TO_RANGE,NULL) ,
      pasi.score ,
      -1 ,
      pasi.sequence_number ,
      SYSDATE ,
      g_user_id ,
      SYSDATE ,
      g_user_id
    FROM pon_attribute_scores_interface pasi
    WHERE pasi.batch_id                = p_batch_id
    AND pasi.auction_header_id         = p_auction_Header_id
    AND NVL(pasi.line_number,-1)      <> -1
    AND pasi.line_number               = c_scored_atts_rec.auction_line_number
    AND pasi.attribute_sequence_number = c_scored_atts_rec.sequence_number;
  END LOOP;
  IF(NVL(L_is_complex,'N') = 'Y') THEN
    UPDATE pon_auc_payments_interface papi
    SET papi.auction_Header_id = p_auction_header_id
    WHERE papi.batcH_id        = p_batch_id;
    PON_CP_INTRFAC_TO_TRANSACTION.SYNCH_PAYMENTS_FROM_INTERFACE( p_batch_id, p_auction_header_id, x_result, x_error_code, x_error_message );
  END IF;
  IF ( l_price_tiers_indicator = 'QUANTITY_BASED' OR l_price_break_response <> 'NONE' ) THEN
    VAL_PRICE_BREAKS ( p_auction_header_id , l_close_bidding_date, --close date
    NULL,                                                          --p_request_id
    NULL,                                                          --p_expiration_date
    g_user_id, g_login_id, p_batch_id , NULL,                      --p_precision
    l_po_start_date,                                               --p_po_start_date
    l_po_end_date                                                  --p_po_end_date
    );
    BEGIN
      SELECT 'N' status
      INTO l_status
      FROM dual
      WHERE EXISTS
        (SELECT * FROM pon_interface_errors WHERE BATCH_ID=p_batch_Id
        );
    EXCEPTION
    WHEN No_Data_Found THEN
      l_status:=NULL;
    END;
    IF(l_status='N') THEN
      print_log(l_module, 'An error occured while validating the price breaks. please check the pon_interface_errors table for error information');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('PON','PON_IMPORT_PB_VAL_ERR');
      FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
      FND_MSG_PUB.ADD;
      RETURN;
    END IF;
    add_price_breaks( p_batch_id, p_auction_header_id, x_result, x_error_code, x_error_message );
    IF(x_result='E') THEN
      print_log(l_module, 'Error in add_price_breaks.' || SQLERRM );
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('PON','PON_IMPORT_PB_ERR');
      FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
      FND_MSG_PUB.ADD;
      RETURN;
    END IF;
  END IF; -- price_break_response <> 'NONE'
  PON_NEGOTIATION_PUBLISH_PVT.SET_ITEM_HAS_CHILDREN_FLAGS ( p_auction_header_id => p_auction_header_id, p_close_bidding_date => NULL );
EXCEPTION
WHEN OTHERS THEN
  print_log(l_module, 'exception increate_lines_with_children: sqlcode ' || SQLCODE || ' sqlerrm ' || SQLERRM );
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.SET_NAME('PON','PON_IMPORT_CREATE_LINES_ERR');
  FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
  FND_MSG_PUB.ADD;
END create_lines_with_children;
/*
This procedure will add price breaks from interface table to txn table.
For all lines marked with '+' action in lines interface table,
the price breaks for those lines will be picked and inserted into pon_auction_shipments_all table.
For amendments, all the existing price breaks will be deleted from pon_auction_shipments_all table
for those lines marked with '#' action in lines interface table.
Then only those price breaks given in interface tables will be added.
Also this procedure inserts data from price differentials interface table
to main txn table for price breaks with price differentials.
*/
PROCEDURE add_price_breaks(
    p_batch_id          IN NUMBER ,
    p_auction_header_id IN NUMBER,
    x_result            IN OUT NOCOPY VARCHAR2,
    x_error_code OUT NOCOPY           VARCHAR2,
    x_error_message OUT NOCOPY        VARCHAR2 )
AS
TYPE numbers
IS
  TABLE OF NUMBER;
  l_shipment_number numbers;
  l_line_number numbers;
  l_price_tiers_indicator pon_auction_headers_all.price_tiers_indicator%TYPE;
  l_module VARCHAR2(250) := g_module_prefix || '.add_price_breaks';
  /*CURSOR price_break_with_pd_cur IS
  SELECT auction_header_id, auction_line_number, shipment_number
  FROM pon_auc_price_breaks_interface ppbi
  WHERE ppbi.batch_id = p_batch_id
  AND Nvl(HAS_PRICE_DIFFERENTIALS_FLAG,'N') = 'Y'
  */
BEGIN
  -- for amendments
  /*
  we will delete price break information in txn tables for lines which are
  being updated in this amendment.
  later we will insert only price breaks given in interface tables.
  */
  print_log(l_module, ' Entering add_price_breaks ');
  SELECT price_tiers_indicator
  INTO l_price_tiers_indicator
  FROM pon_auction_headers_all
  WHERE auction_header_id = p_auction_header_id;
  BEGIN
    SELECT shipment_number,
      line_number bulk collect
    INTO l_shipment_number,
      l_line_number
    FROM pon_auction_shipments_all auction_shipments,
      pon_item_prices_interface line_interface
    WHERE line_interface.action             = g_update_action
    AND line_interface.batch_id             = p_batch_id
    AND line_interface.auction_header_id    = p_auction_header_id
    AND auction_shipments.auction_header_id = line_interface.auction_header_id
    AND auction_shipments.line_number       = line_interface.auction_line_number;
    FORALL x IN 1..l_line_number.COUNT
    DELETE
    FROM PON_PRICE_DIFFERENTIALS price_diffs
    WHERE price_diffs.auction_header_id = p_auction_header_id
    AND price_diffs.line_number         = l_line_number(x)
    AND price_diffs.shipment_number     = l_shipment_number(x);
    FORALL x IN 1..l_line_number.COUNT
    DELETE
    FROM pon_auction_shipments_all auction_shipments
    WHERE auction_shipments.auction_header_id = p_auction_header_id
    AND auction_shipments.line_number         = l_line_number(x)
    AND auction_shipments.shipment_number     = l_shipment_number(x);
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END; -- end of amendments specific code
  INSERT
  INTO pon_auction_shipments_all
    (
      auction_header_id ,
      line_number ,
      shipment_number ,
      shipment_type ,
      ship_to_organization_id ,
      ship_to_location_id ,
      quantity ,
      price ,
      effective_start_date ,
      effective_end_date ,
      org_id ,
      CREATION_DATE ,
      CREATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_LOGIN ,
      has_price_differentials_flag,
      DIFFERENTIAL_RESPONSE_TYPE ,
      MAX_QUANTITY
    )
  SELECT ppbi.auction_header_id ,
    ppbi.auction_line_number ,
    ppbi.shipment_number ,
    DECODE(l_price_tiers_indicator,'QUANTITY_BASED', 'QUANTITY BASED','PRICE_BREAK','PRICE BREAK'),
    DECODE(l_price_tiers_indicator,'QUANTITY_BASED',NULL,ppbi.ship_to_organization_id) ,
    DECODE(l_price_tiers_indicator,'QUANTITY_BASED',NULL,ppbi.ship_to_location_id) ,
    ppbi.quantity ,
    ppbi.price ,
    DECODE(l_price_tiers_indicator,'QUANTITY_BASED',NULL,ppbi.effective_start_date ) ,
    DECODE(l_price_tiers_indicator,'QUANTITY_BASED',NULL,ppbi.effective_end_date) ,
    ppbi.org_id ,
    sysdate ,
    fnd_global.USER_id ,
    sysdate ,
    fnd_global.USER_id ,
    fnd_global.login_id ,
    DECODE(l_price_tiers_indicator,'QUANTITY_BASED','N',NVL(ppbi.HAS_PRICE_DIFFERENTIALS_FLAG,'N')),
    DECODE(l_price_tiers_indicator,'QUANTITY_BASED',NULL,ppbi.DIFFERENTIAL_RESPONSE_TYPE ) ,
    DECODE(l_price_tiers_indicator,'QUANTITY_BASED',ppbi.MAX_QUANTITY,NULL)
  FROM pon_auc_price_breaks_interface ppbi,
    pon_item_prices_interface pipi
  WHERE ppbi.batch_id                = p_batch_id
  AND ppbi.batch_id                  = pipi.batch_id
  AND ppbi.auction_line_number       = pipi.auction_line_number
  AND NVL(pipi.action,g_add_action) IN (g_add_action,g_update_action);
  print_Log(l_module, ' inserted  price breaks ');
  INSERT
  INTO PON_PRICE_DIFFERENTIALS fields
    (
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      PRICE_DIFFERENTIAL_NUMBER,
      PRICE_TYPE ,
      MULTIPLIER ,
      CREATION_DATE ,
      CREATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_LOGIN
    )
  SELECT pdf_int.AUCTION_HEADER_ID,
    pdf_int.AUCTION_LINE_NUMBER ,
    pdf_int.auction_shipment_number,
    pdf_int.SEQUENCE_NUMBER ,
    pdf_int.PRICE_TYPE ,
    pdf_int.MULTIPLIER ,
    sysdate ,
    fnd_global.USER_id ,
    sysdate ,
    fnd_global.USER_id ,
    fnd_global.login_id
  FROM pon_auc_price_differ_int pdf_int,
    pon_auc_price_breaks_interface ppb_int
  WHERE pdf_int.batch_id                              = p_batch_id
  AND NVL(ppb_int.HAS_PRICE_DIFFERENTIALS_FLAG,'N')   = 'Y'
  AND NVL(ppb_int.DIFFERENTIAL_RESPONSE_TYPE,'NONE') <> 'NONE'
  AND pdf_int.batch_id                                = ppb_int.batch_id
  AND pdf_int.auction_line_number                     = ppb_int.auction_line_number
  AND pdf_int.auction_shipment_number                 = ppb_int.shipment_number
  AND pdf_int.auction_shipment_Number                <> -1
  AND pdf_int.auction_shipment_number                IS NOT NULL;
EXCEPTION
WHEN OTHERS THEN
  print_log(l_module, 'error in add_price_breaks' || SQLCODE || SQLERRM );
  FND_MESSAGE.SET_NAME('PON','PON_IMPORT_PB_ERR');
  FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
  FND_MSG_PUB.ADD;
  x_result := 'E';
END ADD_price_breaks;
PROCEDURE VAL_PRICE_BREAKS(
    p_auction_header_id  IN NUMBER,
    p_close_bidding_date IN DATE,
    p_request_id         IN NUMBER,
    p_expiration_date    IN DATE,
    p_user_id            IN NUMBER,
    p_login_id           IN NUMBER,
    p_batch_id           IN NUMBER,
    p_precision          IN NUMBER,
    p_po_start_date      IN DATE,
    p_po_end_date        IN DATE )
IS
  --  PRAGMA AUTONOMOUS_TRANSACTION;
  --l_temp NUMBER;
  l_price_tiers_indicator pon_auction_headers_all.price_tiers_indicator%TYPE;
  l_module VARCHAR2(250) := g_module_prefix || '.val_price_breaks';
BEGIN
  SELECT price_tiers_indicator
  INTO l_price_tiers_indicator
  FROM pon_auctioN_headers_all
  WHERE auctioN_header_id = p_auction_header_id;
  UPDATE pon_auc_price_breaks_interface pb_int
  SET org_id =
    (SELECT ORG_ID
    FROM pon_auction_headers_all
    WHERE auction_header_id = pb_int.auction_header_id
    )
  WHERE batch_id = p_batch_id;
  UPDATE pon_auc_price_breaks_interface pb_int
  SET SHIP_TO_ORGANIZATION_ID =
    (SELECT ORGANIZATION_ID
    FROM hr_all_organization_units
    WHERE name = pb_int.SHIP_TO_ORGANIZATION
    )
  WHERE batch_id            = p_batch_id
  AND SHIP_TO_ORGANIZATION IS NOT NULL;
  UPDATE pon_auc_price_breaks_interface pb_int
  SET ship_to_location_id =
    (SELECT MAX(location_id)
    FROM po_ship_to_loc_org_v po_v
    WHERE po_v.location_code = pb_int.ship_to_location
    )
  WHERE batch_id        = p_batch_id
  AND ship_to_location IS NOT NULL;
  INSERT ALL
    -- PRICE BREAK EFFECTIVE START DATE SHOULD BE BEFORE EFFECTIVE END DATE
    WHEN ( sel_effective_start_date IS NOT NULL
    AND sel_effective_end_date      IS NOT NULL
    AND sel_effective_end_date       < sel_effective_start_date ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,              --INTERFACE_TYPE
      'PON_AUCTS_EFFC_END_BEF_START', -- ERROR_MESSAGE_NAME
      p_request_id ,                  -- REQUEST_ID
      p_batch_id ,                    --BATCH_ID
      g_auction_pbs_type ,            -- ENTITY_TYPE
      p_auction_header_id ,           -- AUCTION_HEADER_ID
      sel_line_number ,               -- LINE_NUMBER
      sel_shipment_number ,           -- SHIPMENT_NUMBER
      p_expiration_date ,             -- EXPIRATION_DATE
      'LINENUM' ,                     -- TOKEN1_NAME
      sel_document_disp_line_number , -- TOKEN1_VALUE
      p_user_id ,                     -- CREATED_BY
      sysdate ,                       -- CREATION_DATE
      p_user_id ,                     -- LAST_UPDATED_BY
      sysdate ,                       -- LAST_UPDATE_DATE
      p_login_id                      -- LAST_UPDATE_LOGIN
    )
    -- SHIP TO LOCATON AND SHIP TO ORG SHOULD BE PROPER
    -- THE SHIP_TO_LOCATION AND SHIP_TO_ORG IF BOTH ARE ENTERED THEN EITHER
    -- 1. The Ship_to_location should belong to the Ship_to_organization
    -- 2. The Ship_to_location should be a global location (inventory_organization_id is null)
    WHEN ( sel_ship_to_organization_id IS NOT NULL
    AND sel_ship_to_location_id        IS NOT NULL
    AND NOT EXISTS
      (SELECT l.INVENTORY_ORGANIZATION_ID
      FROM HR_LOCATIONS_ALL L
      WHERE SYSDATE                                                      < NVL(L.INACTIVE_DATE, SYSDATE + 1)
      AND NVL(L.SHIP_TO_SITE_FLAG,'N')                                   = 'Y'
      AND L.LOCATION_ID                                                  = sel_ship_to_location_id
      AND NVL (L.INVENTORY_ORGANIZATION_ID, sel_ship_to_organization_id) = sel_ship_to_organization_id
      ) ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,              --INTERFACE_TYPE
      'PON_AUC_SHIP_TO_MATCHING_ERR', -- ERROR_MESSAGE_NAME
      p_request_id ,                  -- REQUEST_ID
      p_batch_id ,                    --BATCH_ID
      g_auction_pbs_type ,            -- ENTITY_TYPE
      p_auction_header_id ,           -- AUCTION_HEADER_ID
      sel_line_number ,               -- LINE_NUMBER
      sel_shipment_number ,           -- SHIPMENT_NUMBER
      p_expiration_date ,             -- EXPIRATION_DATE
      'LINENUM' ,                     -- TOKEN1_NAME
      sel_document_disp_line_number , -- TOKEN1_VALUE
      p_user_id ,                     -- CREATED_BY
      sysdate ,                       -- CREATION_DATE
      p_user_id ,                     -- LAST_UPDATED_BY
      sysdate ,                       -- LAST_UPDATE_DATE
      p_login_id                      -- LAST_UPDATE_LOGIN
    )
    -- PRICE BREAK SHOULD NOT BE EMPTY
    -- ONLY PRICE SHOULD NOT BE ENTERED
    WHEN ( sel_ship_to_organization_id IS NULL
    AND sel_ship_to_location_id        IS NULL
    AND sel_effective_start_date       IS NULL
    AND sel_effective_end_date         IS NULL
    AND sel_quantity                   IS NULL ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,                                                       --INTERFACE_TYPE
      NVL2 (sel_price, 'PON_AUCTS_PB_PRICE_ONLY', 'PON_AUCTS_SHIPMENT_EMPTY'), -- ERROR_MESSAGE_NAME
      p_request_id ,                                                           -- REQUEST_ID
      p_batch_id ,                                                             --BATCH_ID
      g_auction_pbs_type ,                                                     -- ENTITY_TYPE
      p_auction_header_id ,                                                    -- AUCTION_HEADER_ID
      sel_line_number ,                                                        -- LINE_NUMBER
      sel_shipment_number ,                                                    -- SHIPMENT_NUMBER
      p_expiration_date ,                                                      -- EXPIRATION_DATE
      'LINENUM' ,                                                              -- TOKEN1_NAME
      sel_document_disp_line_number ,                                          -- TOKEN1_VALUE
      p_user_id ,                                                              -- CREATED_BY
      sysdate ,                                                                -- CREATION_DATE
      p_user_id ,                                                              -- LAST_UPDATED_BY
      sysdate ,                                                                -- LAST_UPDATE_DATE
      p_login_id                                                               -- LAST_UPDATE_LOGIN
    )
    -- quantity should not be empty or negative
    WHEN ( sel_quantity IS NOT NULL
    AND sel_quantity    <= 0
    AND sel_quantity    <> g_null_int ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,                --INTERFACE_TYPE
      'PON_AUCTS_PB_QUANTITY_POSITIVE', -- ERROR_MESSAGE_NAME
      p_request_id ,                    -- REQUEST_ID
      p_batch_id ,                      --BATCH_ID
      g_auction_pbs_type ,              -- ENTITY_TYPE
      p_auction_header_id ,             -- AUCTION_HEADER_ID
      sel_line_number ,                 -- LINE_NUMBER
      sel_shipment_number ,             -- SHIPMENT_NUMBER
      p_expiration_date ,               -- EXPIRATION_DATE
      'LINENUM' ,                       -- TOKEN1_NAME
      sel_document_disp_line_number ,   -- TOKEN1_VALUE
      p_user_id ,                       -- CREATED_BY
      sysdate ,                         -- CREATION_DATE
      p_user_id ,                       -- LAST_UPDATED_BY
      sysdate ,                         -- LAST_UPDATE_DATE
      p_login_id                        -- LAST_UPDATE_LOGIN
    )
    -- the price break price should be positive
    WHEN ( sel_price < 0 ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,             --INTERFACE_TYPE
      'PON_AUCTS_PB_RPICE_POSITIVE', -- ERROR_MESSAGE_NAME
      p_request_id ,                 -- REQUEST_ID
      p_batch_id ,                   --BATCH_ID
      g_auction_pbs_type ,           -- ENTITY_TYPE
      p_auction_header_id ,          -- AUCTION_HEADER_ID
      sel_line_number ,              -- LINE_NUMBER
      sel_shipment_number ,          -- SHIPMENT_NUMBER
      p_expiration_date ,            -- EXPIRATION_DATE
      'LINENUM' ,                    -- TOKEN1_NAME
      sel_document_disp_line_number, -- TOKEN1_VALUE
      p_user_id ,                    -- CREATED_BY
      sysdate ,                      -- CREATION_DATE
      p_user_id ,                    -- LAST_UPDATED_BY
      sysdate ,                      -- LAST_UPDATE_DATE
      p_login_id                     -- LAST_UPDATE_LOGIN
    )
    --  EFFECTIVE START DATE AFTER SYSDATE OR CLOSE DATE
    WHEN ( sel_effective_start_date IS NOT NULL
    AND sel_effective_start_date    <= NVL (p_close_bidding_date, SYSDATE) ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,                                                                         --INTERFACE_TYPE
      NVL2 (p_close_bidding_date, 'PON_AUC_EFFC_FROM_BEF_CLOSE', 'PON_AUC_EFFC_FROM_BEF_TODAY'), -- ERROR_MESSAGE_NAME
      p_request_id ,                                                                             -- REQUEST_ID
      p_batch_id ,                                                                               -- BATCH_ID
      g_auction_pbs_type ,                                                                       -- ENTITY_TYPE
      p_auction_header_id ,                                                                      -- AUCTION_HEADER_ID
      sel_line_number ,                                                                          -- LINE_NUMBER
      sel_shipment_number ,                                                                      -- SHIPMENT_NUMBER
      p_expiration_date ,                                                                        -- EXPIRATION_DATE
      'LINENUM' ,                                                                                -- TOKEN1_NAME
      sel_document_disp_line_number ,                                                            -- TOKEN1_VALUE
      p_user_id ,                                                                                -- CREATED_BY
      sysdate ,                                                                                  -- CREATION_DATE
      p_user_id ,                                                                                -- LAST_UPDATED_BY
      sysdate ,                                                                                  -- LAST_UPDATE_DATE
      p_login_id                                                                                 -- LAST_UPDATE_LOGIN
    )
    --  EFFECTIVE END DATE AFTER SYSDATE OR CLOSE DATE
    WHEN ( sel_effective_end_date IS NOT NULL
    AND sel_effective_end_date    <= NVL (p_close_bidding_date, SYSDATE) ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,                                                                           --INTERFACE_TYPE
      NVL2 (p_close_bidding_date, 'PON_AUC_EFFC_TO_BEFORE_CLOSE', 'PON_AUC_EFFC_TO_BEFORE_TODAY'), -- ERROR_MESSAGE_NAME
      p_request_id ,                                                                               -- REQUEST_ID
      p_batch_id ,                                                                                 --BATCH_ID
      g_auction_pbs_type ,                                                                         -- ENTITY_TYPE
      p_auction_header_id ,                                                                        -- AUCTION_HEADER_ID
      sel_line_number ,                                                                            -- LINE_NUMBER
      sel_shipment_number ,                                                                        -- SHIPMENT_NUMBER
      p_expiration_date ,                                                                          -- EXPIRATION_DATE
      'LINENUM' ,                                                                                  -- TOKEN1_NAME
      sel_document_disp_line_number ,                                                              -- TOKEN1_VALUE
      p_user_id ,                                                                                  -- CREATED_BY
      sysdate ,                                                                                    -- CREATION_DATE
      p_user_id ,                                                                                  -- LAST_UPDATED_BY
      sysdate ,                                                                                    -- LAST_UPDATE_DATE
      p_login_id                                                                                   -- LAST_UPDATE_LOGIN
    )
    -- RESPONSE TYPE if entered should have price differentials
    WHEN ( sel_differential_response_type IS NOT NULL
    AND NOT EXISTS
      (SELECT 1
      FROM pon_auc_price_differ_int PPD
      WHERE ppd.batch_id              = p_batch_id
      AND PPD.AUCTION_HEADER_ID       = p_auction_header_id
      AND PPD.auction_LINE_NUMBER     = sel_line_number
      AND PPD.auction_SHIPMENT_NUMBER = sel_shipment_number
      ) ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,             --INTERFACE_TYPE
      'PON_PRICEDIFF_REQD_FOR_SHIP', -- ERROR_MESSAGE_NAME
      p_request_id ,                 -- REQUEST_ID
      p_batch_id ,                   --BATCH_ID
      g_auction_pbs_type ,           -- ENTITY_TYPE
      p_auction_header_id ,          -- AUCTION_HEADER_ID
      sel_line_number ,              -- LINE_NUMBER
      sel_shipment_number ,          -- SHIPMENT_NUMBER
      p_expiration_date ,            -- EXPIRATION_DATE
      'LINENUM' ,                    -- TOKEN1_NAME
      sel_document_disp_line_number, -- TOKEN1_VALUE
      p_user_id ,                    -- CREATED_BY
      sysdate ,                      -- CREATION_DATE
      p_user_id ,                    -- LAST_UPDATED_BY
      sysdate ,                      -- LAST_UPDATE_DATE
      p_login_id                     -- LAST_UPDATE_LOGIN
    )
    WHEN ( p_po_start_date       IS NOT NULL
    AND sel_effective_start_date IS NOT NULL
    AND sel_effective_start_date  < p_po_start_date ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      batch_id ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,             --INTERFACE_TYPE
      'PON_AUC_EFFC_FROM_BEF_NEG' ,  -- ERROR_MESSAGE_NAME
      p_request_id ,                 -- REQUEST_ID
      p_batch_id ,                   -- BATCH_ID
      g_auction_pbs_type ,           -- ENTITY_TYPE
      p_auction_header_id ,          -- AUCTION_HEADER_ID
      sel_line_number ,              -- LINE_NUMBER
      sel_shipment_number ,          -- SHIPMENT_NUMBER
      p_expiration_date ,            -- EXPIRATION_DATE
      'LINENUM' ,                    -- TOKEN1_NAME
      sel_document_disp_line_number, -- TOKEN1_VALUE
      p_user_id ,                    -- CREATED_BY
      sysdate ,                      -- CREATION_DATE
      p_user_id ,                    -- LAST_UPDATED_BY
      sysdate ,                      -- LAST_UPDATE_DATE
      p_login_id                     -- LAST_UPDATE_LOGIN
    )
    -- EFFECTIVE END DATE SHOULD BE AFTER PO START DATE
    WHEN ( p_po_start_date     IS NOT NULL
    AND sel_effective_end_date IS NOT NULL
    AND sel_effective_end_date  < p_po_start_date ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      batch_id ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,             --INTERFACE_TYPE
      'PON_AUC_EFFC_TO_BEFORE_NEG' , -- ERROR_MESSAGE_NAME
      p_request_id ,                 -- REQUEST_ID
      p_batch_id ,                   -- BATCH_ID
      g_auction_pbs_type ,           -- ENTITY_TYPE
      p_auction_header_id ,          -- AUCTION_HEADER_ID
      sel_line_number ,              -- LINE_NUMBER
      sel_shipment_number ,          -- SHIPMENT_NUMBER
      p_expiration_date ,            -- EXPIRATION_DATE
      'LINENUM' ,                    -- TOKEN1_NAME
      sel_document_disp_line_number, -- TOKEN1_VALUE
      p_user_id ,                    -- CREATED_BY
      sysdate ,                      -- CREATION_DATE
      p_user_id ,                    -- LAST_UPDATED_BY
      sysdate ,                      -- LAST_UPDATE_DATE
      p_login_id                     -- LAST_UPDATE_LOGIN
    )
    -- the effective start date should be before po end date if both are entered
    WHEN ( p_po_end_date         IS NOT NULL
    AND sel_effective_start_date IS NOT NULL
    AND sel_effective_start_date  > p_po_end_date ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      batch_id ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,             --INTERFACE_TYPE
      'PON_AUC_EFFC_FROM_AFT_NEG' ,  -- ERROR_MESSAGE_NAME
      p_request_id ,                 -- REQUEST_ID
      p_batch_id ,                   -- BATCH_ID
      g_auction_pbs_type ,           -- ENTITY_TYPE
      p_auction_header_id ,          -- AUCTION_HEADER_ID
      sel_line_number ,              -- LINE_NUMBER
      sel_shipment_number ,          -- SHIPMENT_NUMBER
      p_expiration_date ,            -- EXPIRATION_DATE
      'LINENUM' ,                    -- TOKEN1_NAME
      sel_document_disp_line_number, -- TOKEN1_VALUE
      p_user_id ,                    -- CREATED_BY
      sysdate ,                      -- CREATION_DATE
      p_user_id ,                    -- LAST_UPDATED_BY
      sysdate ,                      -- LAST_UPDATE_DATE
      p_login_id                     -- LAST_UPDATE_LOGIN
    )
    -- effective end date should be before the po end date
    WHEN ( p_po_end_date       IS NOT NULL
    AND sel_effective_end_date IS NOT NULL
    AND sel_effective_end_date  > p_po_end_date ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      batch_id ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,             --INTERFACE_TYPE
      'PON_AUC_EFFC_TO_AFT_NEG' ,    -- ERROR_MESSAGE_NAME
      p_request_id ,                 -- REQUEST_ID
      p_batch_id ,                   -- BATCH_ID
      g_auction_pbs_type ,           -- ENTITY_TYPE
      p_auction_header_id ,          -- AUCTION_HEADER_ID
      sel_line_number ,              -- LINE_NUMBER
      sel_shipment_number ,          -- SHIPMENT_NUMBER
      p_expiration_date ,            -- EXPIRATION_DATE
      'LINENUM' ,                    -- TOKEN1_NAME
      sel_document_disp_line_number, -- TOKEN1_VALUE
      p_user_id ,                    -- CREATED_BY
      sysdate ,                      -- CREATION_DATE
      p_user_id ,                    -- LAST_UPDATED_BY
      sysdate ,                      -- LAST_UPDATE_DATE
      p_login_id                     -- LAST_UPDATE_LOGIN
    )
    -- bug 16852000
    WHEN ( sel_quantity        IS NULL
    AND l_price_tiers_indicator = 'QUANTITY_BASED') THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,               --INTERFACE_TYPE
      'PON_AUCTS_PT_MIN_QUANTITY_REQ', -- ERROR_MESSAGE_NAME
      p_request_id ,                   -- REQUEST_ID
      p_batch_id ,                     --BATCH_ID
      g_auction_pbs_type ,             -- ENTITY_TYPE
      p_auction_header_id ,            -- AUCTION_HEADER_ID
      sel_line_number ,                -- LINE_NUMBER
      sel_shipment_number ,            -- SHIPMENT_NUMBER
      p_expiration_date ,              -- EXPIRATION_DATE
      'LINENUM' ,                      -- TOKEN1_NAME
      sel_document_disp_line_number ,  -- TOKEN1_VALUE
      p_user_id ,                      -- CREATED_BY
      sysdate ,                        -- CREATION_DATE
      p_user_id ,                      -- LAST_UPDATED_BY
      sysdate ,                        -- LAST_UPDATE_DATE
      p_login_id                       -- LAST_UPDATE_LOGIN
    )
    WHEN ( sel_max_quantity    IS NULL
    AND l_price_tiers_indicator = 'QUANTITY_BASED') THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,               --INTERFACE_TYPE
      'PON_AUCTS_PT_MAX_QUANTITY_REQ', -- ERROR_MESSAGE_NAME
      p_request_id ,                   -- REQUEST_ID
      p_batch_id ,                     --BATCH_ID
      g_auction_pbs_type ,             -- ENTITY_TYPE
      p_auction_header_id ,            -- AUCTION_HEADER_ID
      sel_line_number ,                -- LINE_NUMBER
      sel_shipment_number ,            -- SHIPMENT_NUMBER
      p_expiration_date ,              -- EXPIRATION_DATE
      'LINENUM' ,                      -- TOKEN1_NAME
      sel_document_disp_line_number ,  -- TOKEN1_VALUE
      p_user_id ,                      -- CREATED_BY
      sysdate ,                        -- CREATION_DATE
      p_user_id ,                      -- LAST_UPDATED_BY
      sysdate ,                        -- LAST_UPDATE_DATE
      p_login_id                       -- LAST_UPDATE_LOGIN
    )
    WHEN ( l_price_tiers_indicator = 'QUANTITY_BASED'
    AND sel_quantity               > sel_max_quantity ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,              --INTERFACE_TYPE
      'PON_QT_MAX_MIN_QTY_ERR',       -- ERROR_MESSAGE_NAME
      p_request_id ,                  -- REQUEST_ID
      p_batch_id ,                    --BATCH_ID
      g_auction_pbs_type ,            -- ENTITY_TYPE
      p_auction_header_id ,           -- AUCTION_HEADER_ID
      sel_line_number ,               -- LINE_NUMBER
      sel_shipment_number ,           -- SHIPMENT_NUMBER
      p_expiration_date ,             -- EXPIRATION_DATE
      'LINENUM' ,                     -- TOKEN1_NAME
      sel_document_disp_line_number , -- TOKEN1_VALUE
      p_user_id ,                     -- CREATED_BY
      sysdate ,                       -- CREATION_DATE
      p_user_id ,                     -- LAST_UPDATED_BY
      sysdate ,                       -- LAST_UPDATE_DATE
      p_login_id                      -- LAST_UPDATE_LOGIN
    )
    WHEN ( l_price_tiers_indicator = 'QUANTITY_BASED'
    AND sel_max_quantity          <= 0 ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      EXPIRATION_DATE ,
      TOKEN1_NAME ,
      TOKEN1_VALUE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,                --INTERFACE_TYPE
      'PON_AUCTS_PT_QUANTITY_POSITIVE', -- ERROR_MESSAGE_NAME
      p_request_id ,                    -- REQUEST_ID
      p_batch_id ,                      --BATCH_ID
      g_auction_pbs_type ,              -- ENTITY_TYPE
      p_auction_header_id ,             -- AUCTION_HEADER_ID
      sel_line_number ,                 -- LINE_NUMBER
      sel_shipment_number ,             -- SHIPMENT_NUMBER
      p_expiration_date ,               -- EXPIRATION_DATE
      'LINENUM' ,                       -- TOKEN1_NAME
      sel_document_disp_line_number ,   -- TOKEN1_VALUE
      p_user_id ,                       -- CREATED_BY
      sysdate ,                         -- CREATION_DATE
      p_user_id ,                       -- LAST_UPDATED_BY
      sysdate ,                         -- LAST_UPDATE_DATE
      p_login_id                        -- LAST_UPDATE_LOGIN
    )
    WHEN (sel_shipment_number IS NULL ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      COLUMN_NAME,
      REQUEST_ID ,
      batch_id ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,            --INTERFACE_TYPE
      'PON_FIELD_MUST_BE_ENTERED' , -- ERROR_MESSAGE_NAME
      'SHIPMENT_NUMBER',
      p_request_id ,        -- REQUEST_ID
      p_batch_id ,          -- BATCH_ID
      g_auction_pbs_type,   -- ENTITY_TYPE
      p_auction_header_id , -- AUCTION_HEADER_ID
      sel_line_number ,     -- LINE_NUMBER
      sel_shipment_number , -- SHIPMENT_NUMBER
      p_user_id ,           -- CREATED_BY
      sysdate ,             -- CREATION_DATE
      p_user_id ,           -- LAST_UPDATED_BY
      sysdate ,             -- LAST_UPDATE_DATE
      p_login_id            -- LAST_UPDATE_LOGIN
    )
    WHEN (sel_ordertype = 'FIXED PRICE' ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      batch_id ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,          --INTERFACE_TYPE
      'PON_PRICE_BREAK_LINE_NA' , -- ERROR_MESSAGE_NAME
      p_request_id ,              -- REQUEST_ID
      p_batch_id ,                -- BATCH_ID
      g_auction_pbs_type,         -- ENTITY_TYPE
      p_auction_header_id ,       -- AUCTION_HEADER_ID
      sel_line_number ,           -- LINE_NUMBER
      sel_shipment_number ,       -- SHIPMENT_NUMBER
      p_user_id ,                 -- CREATED_BY
      sysdate ,                   -- CREATION_DATE
      p_user_id ,                 -- LAST_UPDATED_BY
      sysdate ,                   -- LAST_UPDATE_DATE
      p_login_id                  -- LAST_UPDATE_LOGIN
    )
  SELECT PAIP.LINE_NUMBER sel_line_number ,
    PAIP.DOCUMENT_DISP_LINE_NUMBER sel_document_disp_line_number,
    papbi.SHIPMENT_NUMBER sel_shipment_number ,
    papbi.PRICE sel_price ,
    papbi.QUANTITY sel_quantity ,
    papbi.EFFECTIVE_END_DATE sel_effective_end_date ,
    papbi.EFFECTIVE_START_DATE sel_effective_start_date ,
    papbi.SHIP_TO_LOCATION_ID sel_ship_to_location_id ,
    papbi.SHIP_TO_ORGANIZATION_ID sel_ship_to_organization_id ,
    papbi.DIFFERENTIAL_RESPONSE_TYPE sel_differential_response_type,
    papbi.max_quantity sel_max_quantity,
    paip.order_type_lookup_code sel_ordertype
  FROM PON_AUCTION_ITEM_PRICES_ALL PAIP,
    pon_auc_price_breaks_interface papbi
  WHERE PAIP.AUCTION_HEADER_ID = p_auction_header_id
  AND papbi.AUCTION_HEADER_ID  = p_auction_header_id
  AND PAIP.LINE_NUMBER         = papbi.auction_LINE_NUMBER;
  UPDATE pon_auc_price_differ_int diff
  SET price_type =
    (SELECT price_type
    FROM po_price_diff_lookups_v
    WHERE price_type_name = diff.price_type
    )
  WHERE diff.auction_header_id = p_auction_header_id
  AND diff.price_type_name    IS NOT NULL;
  INSERT ALL
    WHEN (sel_seq_num IS NULL ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      COLUMN_NAME,
      REQUEST_ID ,
      batch_id ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,            --INTERFACE_TYPE
      'PON_FIELD_MUST_BE_ENTERED' , -- ERROR_MESSAGE_NAME
      'SEQUENCE_NUMBER',
      p_request_id ,              -- REQUEST_ID
      p_batch_id ,                -- BATCH_ID
      'PON_AUC_PRICE_DIFFER_INT', -- ENTITY_TYPE
      p_auction_header_id ,       -- AUCTION_HEADER_ID
      sel_line_num ,              -- LINE_NUMBER
      sel_ship_num ,              -- SHIPMENT_NUMBER
      p_user_id ,                 -- CREATED_BY
      sysdate ,                   -- CREATION_DATE
      p_user_id ,                 -- LAST_UPDATED_BY
      sysdate ,                   -- LAST_UPDATE_DATE
      p_login_id                  -- LAST_UPDATE_LOGIN
    )
    WHEN (sel_price_type IS NULL
    OR NOT EXISTS
      (SELECT 1
      FROM po_price_diff_lookups_v
      WHERE price_differential_type = sel_price_type
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      batch_id ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,            --INTERFACE_TYPE
      'PON_IMPORT_PRICEDIFF_TYPE' , -- ERROR_MESSAGE_NAME
      p_request_id ,                -- REQUEST_ID
      p_batch_id ,                  -- BATCH_ID
      'PON_AUC_PRICE_DIFFER_INT' ,  -- ENTITY_TYPE
      p_auction_header_id ,         -- AUCTION_HEADER_ID
      sel_line_num ,                -- LINE_NUMBER
      sel_ship_num ,                -- SHIPMENT_NUMBER
      p_user_id ,                   -- CREATED_BY
      sysdate ,                     -- CREATION_DATE
      p_user_id ,                   -- LAST_UPDATED_BY
      sysdate ,                     -- LAST_UPDATE_DATE
      p_login_id                    -- LAST_UPDATE_LOGIN
    )
    WHEN (sel_multiplier IS NULL ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      COLUMN_NAME,
      REQUEST_ID ,
      batch_id ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,            --INTERFACE_TYPE
      'PON_FIELD_MUST_BE_ENTERED' , -- ERROR_MESSAGE_NAME
      'MULTIPLIER',
      p_request_id ,               -- REQUEST_ID
      p_batch_id ,                 -- BATCH_ID
      'PON_AUC_PRICE_DIFFER_INT' , -- ENTITY_TYPE
      p_auction_header_id ,        -- AUCTION_HEADER_ID
      sel_line_num ,               -- LINE_NUMBER
      sel_ship_num ,               -- SHIPMENT_NUMBER
      p_user_id ,                  -- CREATED_BY
      sysdate ,                    -- CREATION_DATE
      p_user_id ,                  -- LAST_UPDATED_BY
      sysdate ,                    -- LAST_UPDATE_DATE
      p_login_id                   -- LAST_UPDATE_LOGIN
    )
    WHEN (sel_line_num IS NULL
    OR NOT EXISTS
      (SELECT 1
      FROM pon_auction_item_prices_all paip
      WHERE paip.auction_header_id = p_auction_header_id
      AND paip.line_number         = sel_line_num
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      batch_id ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,            --INTERFACE_TYPE
      'PON_IMPORT_PRICEDIFF_LINE' , -- ERROR_MESSAGE_NAME
      p_request_id ,                -- REQUEST_ID
      p_batch_id ,                  -- BATCH_ID
      'PON_AUC_PRICE_DIFFER_INT' ,  -- ENTITY_TYPE
      p_auction_header_id ,         -- AUCTION_HEADER_ID
      sel_line_num ,                -- LINE_NUMBER
      sel_ship_num ,                -- SHIPMENT_NUMBER
      p_user_id ,                   -- CREATED_BY
      sysdate ,                     -- CREATION_DATE
      p_user_id ,                   -- LAST_UPDATED_BY
      sysdate ,                     -- LAST_UPDATE_DATE
      p_login_id                    -- LAST_UPDATE_LOGIN
    )
    WHEN (sel_ship_num IS NOT NULL
    AND sel_ship_num   <> -1
    AND NOT EXISTS
      (SELECT 1
      FROM pon_auc_price_breaks_interface pas
      WHERE pas.auction_header_id = p_auction_header_id
      AND pas.auction_line_number = sel_line_num
      AND pas.shipment_number     = sel_ship_num
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      batch_id ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,            --INTERFACE_TYPE
      'PON_IMPORT_PRICEDIFF_SHIP' , -- ERROR_MESSAGE_NAME
      p_request_id ,                -- REQUEST_ID
      p_batch_id ,                  -- BATCH_ID
      'PON_AUC_PRICE_DIFFER_INT' ,  -- ENTITY_TYPE
      p_auction_header_id ,         -- AUCTION_HEADER_ID
      sel_line_num ,                -- LINE_NUMBER
      sel_ship_num ,                -- SHIPMENT_NUMBER
      p_user_id ,                   -- CREATED_BY
      sysdate ,                     -- CREATION_DATE
      p_user_id ,                   -- LAST_UPDATED_BY
      sysdate ,                     -- LAST_UPDATE_DATE
      p_login_id                    -- LAST_UPDATE_LOGIN
    )
    -- bug 16852000
    WHEN (sel_purchase_basis <> 'TEMP_LABOR'
    OR sel_ordertype         <> 'RATE') THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      batch_id ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      SHIPMENT_NUMBER ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,            --INTERFACE_TYPE
      'PON_IMPORT_PRICEDIFF_SHIP' , -- ERROR_MESSAGE_NAME
      p_request_id ,                -- REQUEST_ID
      p_batch_id ,                  -- BATCH_ID
      'PON_PRICEDIFF_LINE_NA' ,     -- ENTITY_TYPE
      p_auction_header_id ,         -- AUCTION_HEADER_ID
      sel_line_num ,                -- LINE_NUMBER
      sel_ship_num ,                -- SHIPMENT_NUMBER
      p_user_id ,                   -- CREATED_BY
      sysdate ,                     -- CREATION_DATE
      p_user_id ,                   -- LAST_UPDATED_BY
      sysdate ,                     -- LAST_UPDATE_DATE
      p_login_id                    -- LAST_UPDATE_LOGIN
    )
  SELECT ppd.price_type sel_price_type,
    ppd.sequence_number sel_seq_num,
    ppd.auction_line_number sel_line_num,
    ppd.multiplier sel_multiplier,
    ppd.auction_shipment_number sel_ship_num,
    paip.purchase_basis sel_purchase_basis,
    paip.order_type_lookup_code sel_ordertype
  FROM PON_AUC_PRICE_DIFFER_INT ppd,
    pon_auction_item_prices_all paip
  WHERE ppd.auction_header_id = p_auction_header_id
  AND paip.auction_header_id  = p_auction_header_id
  AND paip.line_number        = ppd.auction_line_number;
END VAL_PRICE_BREAKS;
/*
* The following validations are performed:
* 1. Entered score value should be between 0 and 100
* 2. Score must be a positive number
*/
PROCEDURE VAL_ATTR_SCORES(
    p_auction_header_id IN NUMBER,
    p_request_id        IN NUMBER,
    p_expiration_date   IN DATE,
    p_user_id           IN NUMBER,
    p_login_id          IN NUMBER,
    p_batch_id          IN NUMBER )
IS
  --  PRAGMA AUTONOMOUS_TRANSACTION;
  l_module VARCHAR2(250) := g_module_prefix || '.val_attr_scores';
BEGIN
  print_log(l_module, ' p_auction_header_id = ' || p_auction_header_id);
  INSERT ALL
    WHEN(NOT EXISTS
      (SELECT 'Y'
      FROM pon_attribute_scores_interface pasi
      WHERE pasi.batch_id                = p_batch_id
      AND pasi.line_number               = line_num
      AND pasi.attribute_sequence_number = seq_num
      )
      -- it is possible that scores can exist from previous round/amendment
      -- we need not expect attribute scores in such cases.
    AND NOT EXISTS
      (SELECT 'Y'
      FROM pon_attribute_scores pas
      WHERE pas.auction_header_id       = p_auction_header_id
      AND pas.line_number               = line_num
      AND pas.attribute_sequence_number = seq_num
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      EXPIRATION_DATE ,
      CREATED_BY ,
      cREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,
      'PON_IMPORT_ATTR_SCORES_NO',
      P_request_id ,
      p_batch_id ,
      g_auction_attrs_type ,
      p_auction_header_id ,
      line_num ,
      NULL ,
      p_user_id ,
      SYSDATE ,
      p_user_id ,
      SYSDATE ,
      p_user_id
    )
  SELECT g_interface_type ,
    'PON_ATTR_SCORES_MISSING' ,
    P_request_id ,
    p_batch_id ,
    g_auction_attrs_type ,
    p_auction_header_id ,
    paai.auction_line_number line_num,
    paai.sequence_number seq_num ,
    NULL ,
    p_user_id
  FROM PON_AUC_ATTRIBUTES_INTERFACE PAAI
  WHERE paai.batch_id                = p_batch_id
  AND paai.auction_header_id         = p_auction_header_id
  AND NVL(paai.SCORING_TYPE,'NONE') <> 'NONE' ;
  INSERT ALL
    -- Entered score value should be between 0 and 100
    WHEN ( SCORE IS NOT NULL
    AND sel_trunc_score NOT BETWEEN 0 AND 100 ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      EXPIRATION_DATE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,          --INTERFACE_TYPE
      'PON_IMPORT_INVALID_SCORE', -- ERROR_MESSAGE_NAME
      p_request_id ,              -- REQUEST_ID
      p_batch_id ,                --BATCH_ID
      g_auction_attrs_type ,      -- ENTITY_TYPE
      p_auction_header_id ,       -- AUCTION_HEADER_ID
      LINE_NUMBER ,               -- LINE_NUMBER
      p_expiration_date ,         -- EXPIRATION_DATE
      p_user_id ,                 -- CREATED_BY
      sysdate ,                   -- CREATION_DATE
      p_user_id ,                 -- LAST_UPDATED_BY
      sysdate ,                   -- LAST_UPDATE_DATE
      p_login_id                  -- LAST_UPDATE_LOGIN
    )
    -- SCORE MUST BE A POSITIVE NUMBER
    WHEN ( SCORE                 IS NOT NULL
    AND (SCORE - sel_trunc_score <>0) ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      REQUEST_ID ,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      LINE_NUMBER ,
      EXPIRATION_DATE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type ,           --INTERFACE_TYPE
      'PON_AUCTS_MUST_BE_A_INT_M', -- ERROR_MESSAGE_NAME
      p_request_id ,               -- REQUEST_ID
      p_batch_id ,                 --BATCH_ID
      g_auction_attrs_type ,       -- ENTITY_TYPE
      p_auction_header_id ,        -- AUCTION_HEADER_ID
      LINE_NUMBER ,                -- LINE_NUMBER
      p_expiration_date ,          -- EXPIRATION_DATE
      p_user_id ,                  -- CREATED_BY
      sysdate ,                    -- CREATION_DATE
      p_user_id ,                  -- LAST_UPDATED_BY
      sysdate ,                    -- LAST_UPDATE_DATE
      p_login_id                   -- LAST_UPDATE_LOGIN
    )
  SELECT pasi.SCORE,
    pasi.LINE_NUMBER,
    TRUNC (pasi.SCORE) sel_trunc_score
  FROM pon_attribute_scores_interface pasi,
    PON_AUC_ATTRIBUTES_INTERFACE paai
  WHERE pasi.batch_id                = p_batch_id
  AND pasi.auction_header_id         = p_auction_Header_id
  AND NVL(pasi.line_number,-1)      <> -1
  AND pasi.batch_id                  = paai.batch_id
  AND NVL(paai.SCORING_TYPE,'NONE') <> 'NONE'
  AND pasi.line_number               = paai.auction_line_number
  AND pasi.attribute_sequence_number = paai.sequence_number;
  print_log(l_module, 'Returning PON_NEGOTIATION_HELPER_PVT.VAL_ATTR_SCORES' || ', p_auction_header_id = ' || p_auction_header_id);
END VAL_ATTR_SCORES;
-----------------------------------------------------------------------
--Start of Comments
--Name:  print_log
--Description  : Helper procedure for logging
--Pre-reqs:
--Parameters:
--IN:  p_message
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE print_log(
    p_module  IN VARCHAR2,
    p_message IN VARCHAR2 )
IS
BEGIN
  IF(g_fnd_debug                = 'Y') THEN
    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level => FND_LOG.level_statement, module => p_module, MESSAGE => p_message);
    END IF;
  END IF;
END print_log;


-----------------------------------------------------------------------
--Start of Comments
--Name:  create_negotiations
--Description  : Main procedure for creating Negotiation
--Pre-reqs:
--Parameters:
--IN:  p_message
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE create_negotiations(
    p_group_batch_id IN NUMBER,
    x_return_status  IN OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY         NUMBER,
    x_msg_data OUT NOCOPY          VARCHAR2 )
AS
  dummy1            NUMBER;
  neg_return_status VARCHAR2(1);
  p_error_code      VARCHAR2(1);
  p_error_message   VARCHAR2(1000);
  l_auctioN_header_id pon_auction_headers_all.auctioN_header_id%TYPE;
  l_trading_partner_id pon_auction_headers_all.trading_partner_id%TYPE;
  l_trading_partner_name pon_auction_headers_all.trading_partner_name%TYPE;
  l_batch_id pon_auctioN_headers_interface.batch_id%TYPE;
  l_module VARCHAR2(250) := g_module_prefix || '.create_negotiations';
  CURSOR group_negotiations_cur
  IS
    SELECT interface_header_id
    FROM pon_auction_Headers_interface
    WHERE interface_group_id   = p_group_batch_id
    AND interface_header_id   IS NOT NULL
    AND PROCESSING_STATUS_CODE = 'PENDING';
  --AND Nvl(amendment_flag,'N') = 'N';
BEGIN
  print_log(l_module, 'Entered create_negotiations procedure');
  print_log(l_module, 'Getting the Enterprice party information for the buyer org ');
  pos_enterprise_util_pkg.get_enterprise_partyId(g_trading_partner_id, p_error_code, p_error_message);
  print_log(l_module, ' Trading partner Id = '||g_trading_partner_id);
  pos_enterprise_util_pkg.get_enterprise_party_name(l_trading_partner_name, p_error_code, p_error_message);
  print_log(l_module, ' Trading partner Name = '||l_trading_partner_name);
  IF(p_error_code    = 'E' ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    print_Log(l_module, 'Trading partner set up is not done.' );
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_TPSETUP_ERR');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  print_log(l_module, 'Looping Interface records for Interface Group Id = '||p_group_batch_id);
  FOR rec IN group_negotiations_cur
  LOOP
    SAVEPOINT NEG_CREATION;
    l_batch_id := rec.interface_header_id;

    print_log(l_module, 'Processing the record with Interface header ID = '||l_batch_id);
    UPDATE pon_auction_Headers_interface
    SET PROCESSING_STATUS_CODE = 'PROCESSING'
    WHERE interface_header_id  = l_batch_id;

    print_log(l_module, 'Delete ERROR table for batch_id = '||l_batch_id);
    DELETE FROM pon_interface_errors WHERE batch_id = l_batch_id;

    BEGIN
      create_negotiation(l_batch_id, l_auction_header_id, neg_return_status );
    EXCEPTION
    WHEN OTHERS THEN
      print_log(l_module, 'Exception in create_negotiation for batch_id ' || l_batch_id);
      FND_MESSAGE.SET_NAME('PON','PON_IMPORT_NEG_CREATION_FAIL');
      FND_MESSAGE.SET_TOKEN('BATCH_ID',l_batch_id);
      FND_MSG_PUB.ADD;
      x_return_status   := FND_API.G_RET_STS_ERROR;
      neg_return_status := FND_API.G_RET_STS_ERROR;
    END;
    IF ( neg_return_status = 'S') THEN
      print_log(l_module, 'Negotiation with auction_header_id ' || l_auction_header_id || ' has been created for  batch id  ' || l_batch_id);
      UPDATE pon_auction_headers_interface
      SET PROCESSING_STATUS_CODE = 'PROCESSED'
      WHERE batch_id             = l_batch_id;
      COMMIT;
    ELSE
      print_log(l_module, 'Negotiation creation has failed for  batch id  ' || l_batch_id);
      x_return_status := FND_API.G_RET_STS_ERROR;
      --ROLLBACK TO NEG_CREATION;
      IF ( l_auction_header_id IS NOT NULL ) THEN
        DELETE
        FROM pon_auction_headers_all
        WHERE auction_header_id = l_auction_header_id;
        DELETE
        FROM pon_auction_item_prices_all
        WHERE auction_header_id = l_auction_header_id;
        DELETE FROM pon_price_elements WHERE auction_header_id = l_auction_header_id;
        DELETE
        FROM pon_auction_shipments_all
        WHERE auction_header_id = l_auction_header_id;
        DELETE
        FROM pon_auc_payments_shipments
        WHERE auction_header_id = l_auction_header_id;
        DELETE
        FROM pon_neg_team_members
        WHERE auction_header_id = l_auction_header_id;
        DELETE
        FROM pon_auction_attributes
        WHERE auction_header_id = l_auction_header_id;
        DELETE FROM pon_bidding_parties WHERE auction_header_id = l_auction_header_id;
        DELETE
        FROM pon_attribute_scores
        WHERE auction_header_id = l_auction_header_id;
        DELETE
        FROM pon_auction_sections
        WHERE auction_header_id = l_auction_header_id;
      END IF;
      UPDATE pon_auction_headers_interface
      SET PROCESSING_STATUS_CODE = 'FAILED'
      WHERE batch_id             = l_batch_id;
      COMMIT;
    END IF;
  END LOOP;
  print_log(l_module, 'End Looping Interface records for Interface Group Id = '||p_group_batch_id);
  IF x_return_status <> FND_API.G_RET_STS_ERROR THEN
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
  END IF;
  FND_MSG_PUB.COUNT_AND_GET( p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
WHEN OTHERS THEN
  print_log(l_module, 'Exception in create_negotiations procedure: '||SQLERRM);
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.COUNT_AND_GET( p_count => x_msg_count, p_data => x_msg_data);
END create_negotiations;

PROCEDURE create_negotiation(
    p_batch_id IN NUMBER,
    x_auction_header_id OUT NOCOPY NUMBER,
    x_return_status IN OUT NOCOPY  VARCHAR2 )
AS
  l_empty_header_rec neg_header_record;
  l_api_version   CONSTANT NUMBER       := 1.0;
  l_api_name      CONSTANT VARCHAR2(30) := 'Create_negotiation';
  p_error_code    VARCHAR2(1);
  p_error_message VARCHAR2(100);
  --l_uda_template_id NUMBER;
  l_attr_group_id NUMBER;
  dummy1          NUMBER;
  dummy2          NUMBER;
  l_module        VARCHAR2(250) := g_module_prefix || l_api_name;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  print_log(l_module, 'pon_open_interface_pvt.create_negotiation begin');
  --x_return_status := FND_API.G_RET_STS_SUCCESS;
  neg_header_record_data := l_empty_header_rec;

  print_log(l_module, 'Updating pon_auction_headers_interface records with batch_id');
  UPDATE pon_auction_headers_interface
  SET batch_id              = p_batch_id
  WHERE interface_header_id = p_batch_id;
  print_log(l_module, 'Number of rows updated = '||SQL%ROWCOUNT);

  print_log(l_module, 'Updating pon_item_prices_interface records with batch_id');
  UPDATE pon_item_prices_interface
  SET batch_id              = p_batch_id,
    auction_line_number     = interface_line_id
  WHERE interface_header_id = p_batch_id;
  print_log(l_module, 'Number of rows updated = '||SQL%ROWCOUNT);

  print_log(l_module, 'Updating pon_auc_attributes_interface records with batch_id');
  UPDATE PON_AUC_ATTRIBUTES_INTERFACE
  SET batch_id              = p_batch_id,
    auction_line_number     = interface_line_id
  WHERE interface_header_id = p_batch_id;
  print_log(l_module, 'Number of rows updated = '||SQL%ROWCOUNT);

  print_log(l_module, 'Updating pon_attribute_scores_interface records with batch_id');
  UPDATE pon_attribute_scores_interface
  SET batch_id              = p_batch_id,
    LINE_NUMBER             = interface_line_id
  WHERE interface_header_id = p_batch_id;
  print_log(l_module, 'Number of rows updated = '||SQL%ROWCOUNT);

  print_log(l_module, 'Updating pon_bid_parties_interface records with batch_id');
  UPDATE pon_bid_parties_interface
  SET batch_id              = p_batch_id
  WHERE interface_header_id = p_batch_id;
  print_log(l_module, 'Number of rows updated = '||SQL%ROWCOUNT);

  print_log(l_module, 'Updating pon_neg_team_interface records with batch_id');
  UPDATE PON_NEG_TEAM_INTERFACE
  SET batch_id              = p_batch_id
  WHERE interface_header_id = p_batch_id;
  print_log(l_module, 'Number of rows updated = '||SQL%ROWCOUNT);

  print_log(l_module, 'Updating pon_auc_price_elements_interface records with batch_id');
  UPDATE PON_AUC_PRICE_ELEMENTS_INT
  SET batch_id              = p_batch_id,
    auction_line_number     = interface_line_id
  WHERE interface_header_id = p_batch_id;
  print_log(l_module, 'Number of rows updated = '||SQL%ROWCOUNT);

  print_log(l_module, 'Updating pon_auc_payments_interface records with batch_id');
  BEGIN
    UPDATE pon_auc_payments_interface
    SET batch_id                = p_batch_id,
      document_disp_line_number = interface_line_id
    WHERE interface_header_id   = p_batch_id;
  EXCEPTION
  WHEN OTHERS THEN
    print_log(l_module, 'sqlerrm ' || SQLERRM || ' ' || SQLCODE );
  END;
  print_log(l_module, 'Number of rows updated = '||SQL%ROWCOUNT);

  print_log(l_module, 'Updating pon_auc_price_breaks_interface records with batch_id');
  UPDATE pon_auc_price_breaks_interface
  SET batch_id              = p_batch_id,
    auction_line_number     = interface_line_id
  WHERE interface_header_id = p_batch_id;
  print_log(l_module, 'Number of rows updated = '||SQL%ROWCOUNT);

  print_log(l_module, 'Updating pon_auc_price_differ_interface records with batch_id');
  UPDATE pon_auc_price_differ_int
  SET batch_id              = p_batch_id,
    auction_line_number     = interface_line_id
  WHERE interface_header_id = p_batch_id;
  print_log(l_module, 'Number of rows updated = '||SQL%ROWCOUNT);

  BEGIN
    SELECT 1
    INTO dummy1
    FROM pon_auction_headers_Interface
    WHERE batch_id = p_batch_id;
  EXCEPTION
  WHEN Too_Many_Rows THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    print_Log(l_module, 'Multiple rows found in pon_auction_headers_Interface table for the batch_id' || p_batch_id);
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_MUL_BATCHID');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END;

  print_log(l_module, 'pon_open_interface_pvt.create_negotiation: before calling process_negotiation_header');
  process_negotiation_header( p_batch_id, g_trading_partner_id, x_auction_header_id, x_return_status );

  IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
    print_log(l_module, 'failure from create_negotiation_header');
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_HEADER_PROC_FAIL');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  print_log(l_module, 'Header record created for batch_id ' || p_batch_id || ' auction_header_id ' || x_auction_header_id || ' x_return_status ' || x_return_status);

  BEGIN
    SELECT auction_header_id
    INTO dummy2
    FROM pon_item_prices_interface
    WHERE batch_id = p_batch_id
    AND ROWNUM     =1;
  EXCEPTION
  WHEN No_Data_Found THEN
    print_log(l_module, 'No lines present for the given batch_id');
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_NO_LINES');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
    FND_MSG_PUB.ADD;
    RETURN;
  END;
  print_log(l_module, 'Before calling create_lines_with_children with auction_Header_id ' || x_auction_header_id);
  create_lines_with_children( p_batch_id, x_auction_header_id, x_return_status );
  print_log(l_module, 'Lines information inserted for batch_id ' || p_batch_id || ' auction_header_id ' || x_auction_header_id || ' x_return_status ' || x_return_status);
  IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
    print_log(l_module, 'failure from create_lines_with_children');
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_LINE_FAIL');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  invite_supplier( p_batch_id, x_return_status );
  print_Log(l_module, 'Supplier information inserted for batch_id ' || p_batch_id || ' auction_header_id ' || x_auction_header_id || ' x_return_status ' || x_return_status);
  IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
    print_log(l_module, 'failure from create_lines_with_children');
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_SUPPLIER_FAIL');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_Id);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
    print_log(l_module, 'Failure in document number procedure');
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_DOCNUM_FAIL');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_Id);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  print_log(l_module, 'Exception in create_negotiation');
  x_return_status := FND_API.G_RET_STS_ERROR;
END create_negotiation;
PROCEDURE create_negotiation_header(
    p_batch_id                    NUMBER,
    x_return_status IN OUT NOCOPY VARCHAR2 )
AS
  l_document_type pon_auc_doctypes.internal_name%TYPE;
  l_module VARCHAR2(250) := g_module_prefix || 'create_negotiation_header';
BEGIN
  SELECT internal_name
  INTO l_document_type
  FROM pon_auc_doctypes
  WHERE doctype_id = neg_header_record_data.doctype_id;
  INSERT
  INTO PON_AUCTION_HEADERS_ALL
    (
      AUCTION_HEADER_ID,
      DOCUMENT_NUMBER,
      AUCTION_HEADER_ID_ORIG_AMEND,
      AUCTION_HEADER_ID_ORIG_ROUND,
      AMENDMENT_NUMBER,
      AUCTION_TITLE,
      description,
      AUCTION_STATUS,
      AWARD_STATUS,
      AUCTION_TYPE,
      CONTRACT_TYPE,
      TRADING_PARTNER_NAME,
      TRADING_PARTNER_NAME_UPPER,
      TRADING_PARTNER_ID,
      trading_partner_contact_id,
      LANGUAGE_CODE,
      BID_VISIBILITY_CODE,
      ATTACHMENT_FLAG,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      DOCTYPE_ID,
      ORG_ID,
      BUYER_ID,
      MANUAL_EDIT_FLAG,
      SHARE_AWARD_DECISION,
      APPROVAL_STATUS,
      GLOBAL_AGREEMENT_FLAG,
      ATTRIBUTE_LINE_NUMBER,
      HAS_HDR_ATTR_FLAG,
      HAS_ITEMS_FLAG,
      STYLE_ID,
      PO_STYLE_ID,
      PRICE_BREAK_RESPONSE,
      NUMBER_OF_LINES,
      ADVANCE_NEGOTIABLE_FLAG,
      RECOUPMENT_NEGOTIABLE_FLAG,
      PROGRESS_PYMT_NEGOTIABLE_FLAG,
      RETAINAGE_NEGOTIABLE_FLAG,
      MAX_RETAINAGE_NEGOTIABLE_FLAG,
      SUPPLIER_ENTERABLE_PYMT_FLAG,
      PROGRESS_PAYMENT_TYPE,
      LINE_ATTRIBUTE_ENABLED_FLAG,
      LINE_MAS_ENABLED_FLAG,
      PRICE_ELEMENT_ENABLED_FLAG,
      RFI_LINE_ENABLED_FLAG,
      LOT_ENABLED_FLAG,
      GROUP_ENABLED_FLAG,
      LARGE_NEG_ENABLED_FLAG,
      HDR_ATTRIBUTE_ENABLED_FLAG,
      NEG_TEAM_ENABLED_FLAG,
      PROXY_BIDDING_ENABLED_FLAG,
      POWER_BIDDING_ENABLED_FLAG,
      AUTO_EXTEND_ENABLED_FLAG,
      TEAM_SCORING_ENABLED_FLAG,
      PRICE_TIERS_INDICATOR,
      QTY_PRICE_TIERS_ENABLED_FLAG,
      ship_to_location_id,
      bill_to_location_id,
      payment_terms_id,
      fob_code,
      freight_terms_code,
      rate_type,
      currency_code,
      security_level_code,
      PO_START_DATE,
      PO_END_DATE,
      open_auction_now_flag,
      open_bidding_date,
      CLOSE_bidding_date,
      publish_auction_now_flag,
      view_by_date,
      note_to_bidders,
      SHOW_BIDDER_NOTES,
      BID_SCOPE_CODE,
      BID_LIST_TYPE,
      BID_FREQUENCY_CODE,
      bid_ranking,
      rank_indicator,
      full_quantity_bid_code,
      multiple_rounds_flag,
      manual_close_flag,
      manual_extend_flag,
      award_approval_flag,
      auction_origination_code,
      pf_type_allowed,
      HDR_ATTR_ENABLE_WEIGHTS,
      AUCTION_STATUS_NAME,
      AWARD_STATUS_NAME,
      TRADING_PARTNER_CONTACT_NAME,
      ORIGINAL_CLOSE_BIDDING_DATE,
      AWARD_BY_DATE,
      PUBLISH_DATE,
      CLOSE_DATE,
      CANCEL_DATE,
      TIME_ZONE,
      AUTO_EXTEND_FLAG,
      AUTO_EXTEND_NUMBER,
      NUMBER_OF_EXTENSIONS,
      NUMBER_OF_BIDS,
      MIN_BID_DECREMENT,
      PRICE_DRIVEN_AUCTION_FLAG,
      CARRIER_CODE,
      RATE_DATE,
      RATE,
      WF_ITEM_KEY,
      WF_ROLE_NAME,
      AUTO_EXTEND_ALL_LINES_FLAG,
      ALLOW_OTHER_BID_CURRENCY_FLAG,
      SHIPPING_TERMS_CODE,
      SHIPPING_TERMS,
      AUTO_EXTEND_DURATION,
      PROXY_BID_ALLOWED_FLAG,
      PUBLISH_RATES_TO_BIDDERS_FLAG,
      ATTRIBUTES_EXIST,
      ORDER_NUMBER,
      DOCUMENT_TRACKING_ID,
      PO_TXN_FLAG,
      EVENT_ID,
      EVENT_TITLE,
      SEALED_AUCTION_STATUS,
      SEALED_ACTUAL_UNLOCK_DATE,
      SEALED_ACTUAL_UNSEAL_DATE,
      SEALED_UNLOCK_TP_CONTACT_ID,
      SEALED_UNSEAL_TP_CONTACT_ID,
      MODE_OF_TRANSPORT,
      MODE_OF_TRANSPORT_CODE,
      PO_AGREED_AMOUNT ,
      PO_MIN_REL_AMOUNT,
      MIN_BID_CHANGE_TYPE,
      NUMBER_PRICE_DECIMALS,
      AUTO_EXTEND_TYPE_FLAG,
      AUCTION_HEADER_ID_PREV_ROUND,
      AUCTION_ROUND_NUMBER,
      AUTOEXTEND_CHANGED_FLAG,
      OFFER_TYPE,
      APPROVAL_REQUIRED_FLAG,
      MAX_RESPONSES,
      RESPONSE_ALLOWED_FLAG,
      FOB_NEG_FLAG,
      CARRIER_NEG_FLAG,
      FREIGHT_TERMS_NEG_FLAG,
      MAX_RESPONSE_ITERATIONS,
      PAYMENT_TERMS_NEG_FLAG,
      MODE_OF_TRANSPORT_NEG_FLAG,
      CONTRACT_ID,
      CONTRACT_VERSION_NUM,
      SHIPPING_TERMS_NEG_FLAG,
      SHIPPING_METHOD_NEG_FLAG,
      USE_REGIONAL_PRICING_FLAG,
      DERIVE_TYPE,
      PRE_DELETE_AUCTION_STATUS,
      DRAFT_LOCKED,
      DRAFT_LOCKED_BY,
      DRAFT_LOCKED_BY_CONTACT_ID ,
      DRAFT_LOCKED_DATE,
      DRAFT_UNLOCKED_BY,
      DRAFT_UNLOCKED_BY_CONTACT_ID,
      DRAFT_UNLOCKED_DATE,
      MAX_LINE_NUMBER,
      SHOW_BIDDER_SCORES,
      TEMPLATE_ID,
      REMINDER_DATE,
      WF_PONCOMPL_ITEM_KEY,
      HAS_PE_FOR_ALL_ITEMS,
      HAS_PRICE_ELEMENTS ,
      OUTCOME_STATUS,
      SOURCE_REQS_FLAG,
      AWARD_COMPLETE_DATE,
      WF_PONCOMPL_CURRENT_ROUND,
      WF_APPROVAL_ITEM_KEY,
      SOURCE_DOC_ID,
      SOURCE_DOC_NUMBER,
      SOURCE_DOC_MSG,
      SOURCE_DOC_LINE_MSG,
      SOURCE_DOC_MSG_APP,
      TEMPLATE_SCOPE,
      TEMPLATE_STATUS,
      IS_TEMPLATE_FLAG,
      AWARD_APPROVAL_STATUS,
      AWARD_APPR_AME_TRANS_ID ,
      AWARD_APPR_AME_TRANS_PREV_ID,
      WF_AWARD_APPROVAL_ITEM_KEY,
      --AMENDMENT_DESCRIPTION,
      AUCTION_HEADER_ID_PREV_AMEND,
      AWARD_APPR_AME_TXN_DATE,
      HDR_ATTR_DISPLAY_SCORE,
      HDR_ATTR_MAXIMUM_SCORE,
      CONTERMS_EXIST_FLAG,
      CONTERMS_ARTICLES_UPD_DATE,
      CONTERMS_DELIV_UPD_DATE,
      AWARD_MODE,
      AWARD_DATE,
      MAX_INTERNAL_LINE_NUM,
      MAX_BID_COLOR_SEQUENCE_ID,
      INT_ATTRIBUTE_CATEGORY,
      INT_ATTRIBUTE1,
      INT_ATTRIBUTE2,
      INT_ATTRIBUTE3,
      INT_ATTRIBUTE4,
      INT_ATTRIBUTE5,
      INT_ATTRIBUTE6,
      INT_ATTRIBUTE7,
      INT_ATTRIBUTE8,
      INT_ATTRIBUTE9,
      INT_ATTRIBUTE10,
      INT_ATTRIBUTE11,
      INT_ATTRIBUTE12 ,
      INT_ATTRIBUTE13 ,
      INT_ATTRIBUTE14 ,
      INT_ATTRIBUTE15,
      EXT_ATTRIBUTE_CATEGORY,
      EXT_ATTRIBUTE1,
      EXT_ATTRIBUTE2,
      EXT_ATTRIBUTE3,
      EXT_ATTRIBUTE4,
      EXT_ATTRIBUTE5 ,
      EXT_ATTRIBUTE6 ,
      EXT_ATTRIBUTE7 ,
      EXT_ATTRIBUTE8,
      EXT_ATTRIBUTE9,
      EXT_ATTRIBUTE10,
      EXT_ATTRIBUTE11,
      EXT_ATTRIBUTE12,
      EXT_ATTRIBUTE13,
      EXT_ATTRIBUTE14 ,
      EXT_ATTRIBUTE15,
      INCLUDE_PDF_IN_EXTERNAL_PAGE,
      ABSTRACT_DETAILS,
      ABSTRACT_STATUS,
      SUPPLIER_VIEW_TYPE,
      IS_PAUSED ,
      PAUSE_REMARKS,
      LAST_PAUSE_DATE,
      MAX_DOCUMENT_LINE_NUM,
      PROJECT_ID ,
      HAS_SCORING_TEAMS_FLAG ,
      SCORING_LOCK_DATE,
      SCORING_LOCK_TP_CONTACT_ID ,
      REQUEST_ID ,
      REQUEST_DATE ,
      REQUESTED_BY ,
      IMPORT_FILE_NAME ,
      LAST_LINE_NUMBER ,
      GLOBAL_TEMPLATE_FLAG,
      CONTRACT_TEMPLATE_ID,
      COMPLETE_FLAG ,
      BID_DECREMENT_METHOD,
      DISPLAY_BEST_PRICE_BLIND_FLAG,
      FIRST_LINE_CLOSE_DATE ,
      STAGGERED_CLOSING_INTERVAL ,
      ENFORCE_PREVRND_BID_PRICE_FLAG,
      AUTO_EXTEND_MIN_TRIGGER_RANK ,
      TWO_PART_FLAG ,
      TECHNICAL_LOCK_STATUS,
      TECHNICAL_EVALUATION_STATUS,
      TECHNICAL_ACTUAL_UNLOCK_DATE,
      TECHNICAL_ACTUAL_UNSEAL_DATE ,
      TECHNICAL_UNLOCK_TP_CONTACT_ID,
      TECHNICAL_UNSEAL_TP_CONTACT_ID,
      EMD_ENABLE_FLAG,
      EMD_AMOUNT,
      EMD_DUE_DATE,
      EMD_TYPE,
      EMD_GUARANTEE_EXPIRY_DATE,
      EMD_ADDITIONAL_INFORMATION,
      POST_EMD_TO_FINANCE,
      NO_OF_NOTIFICATIONS_SENT,
      NEGOTIATION_REQUESTER_ID,
      SUPP_REG_QUAL_FLAG,
      SUPP_EVAL_FLAG,
      HIDE_TERMS_FLAG,
      HIDE_ABSTRACT_FORMS_FLAG,
      HIDE_ATTACHMENTS_FLAG,
      INTERNAL_EVAL_FLAG,
      HDR_SUPP_ATTR_ENABLED_FLAG,
      INTGR_HDR_ATTR_FLAG,
      INTGR_HDR_ATTACH_FLAG,
      LINE_SUPP_ATTR_ENABLED_FLAG,
      ITEM_SUPP_ATTR_ENABLED_FLAG,
      INTGR_CAT_LINE_ATTR_FLAG,
      INTGR_ITEM_LINE_ATTR_FLAG,
      INTGR_CAT_LINE_ASL_FLAG,
      INTERNAL_ONLY_FLAG
    )
    VALUES
    (
      neg_header_record_data.auction_header_id, -- AUCTION_HEADER_ID
      neg_header_record_data.auction_header_id, -- DOCUMENT_NUMBER
      neg_header_record_data.auction_header_id, -- AUCTION_HEADER_ID_ORIG_AMEND,
      neg_header_record_data.auction_header_id, -- AUCTION_HEADER_ID_ORIG_ROUND,
      0,                                        -- AMENDMENT_NUMBER
      neg_header_record_data.auction_title,     -- AUCTION_TITLE
      neg_header_record_data.description,
      'DRAFT',                                            -- AUCTION_STATUS
      'NO',                                               -- AWARD_STATUS
      neg_header_record_data.auction_type,                -- AUCTION_TYPE
      neg_header_record_data.CONTRACT_TYPE,               -- CONTRACT_TYPE
      neg_header_record_data.trading_partner_name,        -- TRADING_PARTNER_NAME
      upper(neg_header_record_data.trading_partner_name), -- TRADING_PARTNER_NAME_UPPER
      neg_header_record_data.trading_partner_id,          -- TRADING_PARTNER_ID
      neg_header_record_data.trading_partner_contact_id,
      userenv('LANG'),                                                -- LANGUAGE_CODE
      neg_header_record_data.bid_visibility_code,                     -- BID_VISIBILITY_CODE
      'N',                                                            -- ATTACHMENT_FLAG
      NVL(neg_header_record_data.creation_date, SYSDATE),             -- CREATION_DATE
      NVL(neg_header_record_data.created_by,fnd_global.user_id),      -- CREATED_BY
      NVL(neg_header_record_data.last_update_date,SYSDATE),           -- LAST_UPDATE_DATE
      NVL(neg_header_record_data.last_updated_by,fnd_global.user_id), -- LAST_UPDATED_BY
      neg_header_record_data.doctype_id,                              -- DOCTYPE_ID
      neg_header_record_data.ORG_ID,                                  -- ORG_ID
      NULL,                                                           -- BUYER_ID
      'N',                                                            -- MANUAL_EDIT_FLAG
      'N',                                                            -- SHARE_AWARD_DECISION
      neg_header_record_data.approval_status,                         -- APPROVAL_STATUS
      NVL(neg_header_record_data.GLOBAL_AGREEMENT_FLAG,'Y'),          -- GLOBAL_AGREEMENT_FLAG
      -1,                                                             -- ATTRIBUTE_LINE_NUMBER
      NULL,                                                           -- HAS_HDR_ATTR_FLAG
      NULL,                                                           -- HAS_ITEMS_FLAG
      neg_header_record_data.STYLE_ID,                                -- STYLE_ID
      neg_header_record_data.PO_STYLE_ID,                             -- PO_STYLE_ID
      neg_header_record_data.price_break_response,                    -- PRICE_BREAK_RESPONSE,
      0,                                                              -- NUMBER_OF_LINES
      NVL(neg_header_record_data.ADVANCE_NEGOTIABLE_FLAG,'N'),        --ADVANCE_NEGOTIABLE_FLAG
      NVL(neg_header_record_data.RECOUPMENT_NEGOTIABLE_FLAG,'N'),     --RECOUPMENT_NEGOTIABLE_FLAG
      NVL(neg_header_record_data.PROGRESS_PYMT_NEGOTIABLE_FLAG,'N'),  --PROGRESS_PYMT_NEGOTIABLE_FLAG
      NVL(neg_header_record_data.RETAINAGE_NEGOTIABLE_FLAG,'N'),      --RETAINAGE_NEGOTIABLE_FLAG
      NVL(neg_header_record_data.MAX_RETAINAGE_NEGOTIABLE_FLAG,'N'),  --MAX_RETAINAGE_NEGOTIABLE_FLAG
      neg_header_record_data.SUPPLIER_ENTERABLE_PYMT_FLAG,            --SUPPLIER_ENTERABLE_PYMT_FLAG
      neg_header_record_data.progress_payment_type,                   --PROGRESS_PAYMENT_TYPE
      neg_header_record_data.line_attribute_enabled_flag,
      neg_header_record_data.line_mas_enabled_flag,
      neg_header_record_data.price_element_enabled_flag,
      neg_header_record_data.rfi_line_enabled_flag,
      neg_header_record_data.lot_enabled_flag,
      neg_header_record_data.group_enabled_flag,
      neg_header_record_data.large_neg_enabled_flag,
      neg_header_record_data.hdr_attribute_enabled_flag,
      neg_header_record_data.neg_team_enabled_flag,
      neg_header_record_data.proxy_bidding_enabled_flag,
      neg_header_record_data.power_bidding_enabled_flag,
      neg_header_record_data.auto_extend_enabled_flag,
      neg_header_record_data.team_scoring_enabled_flag,
      neg_header_record_data.price_tiers_indicator,
      neg_header_record_data.qty_price_tiers_enabled_flag,
      neg_header_record_data.ship_to_location_id,
      neg_header_record_data.bill_to_location_id,
      neg_header_record_data.payment_terms_id,
      neg_header_record_data.fob_code,
      neg_header_record_data.freight_terms_code,
      neg_header_record_data.rate_type,
      neg_header_record_data.currency_code,
      neg_header_record_data.security_level_code,
      neg_header_record_data.PO_START_DATE,
      neg_header_record_data.PO_END_DATE,
      NVL(neg_header_record_data.open_auction_now_flag,'N'),
      DECODE(NVL(neg_header_record_data.open_auction_now_flag,'N'),'Y',NULL,neg_header_record_data.open_bidding_date),
      neg_header_record_data.close_bidding_date,
      NVL(neg_header_record_data.publish_auction_now_flag,'N'),
      DECODE(NVL(neg_header_record_data.publish_auction_now_flag,'N'),'Y',NULL,neg_header_record_data.view_by_date),
      neg_header_record_data.note_to_bidders,
      NVL(neg_header_record_data.SHOW_BIDDER_NOTES,'N'),
      NVL(neg_header_record_data.BID_SCOPE_CODE,'MUST_BID_ALL_ITEMS'),
      NVL(neg_header_record_data.BID_LIST_TYPE,'PUBLIC_BID_LIST'),
      NVL(neg_header_record_data.BID_FREQUENCY_CODE,'SINGLE_BID_ONLY'),
      NVL(neg_header_record_data.bid_ranking,'PRICE_ONLY'),
      NVL(neg_header_record_data.rank_indicator,'NONE'),
      NVL(neg_header_record_data.full_quantity_bid_code,'FULL_QTY_BIDS_REQD'),
      DECODE(l_document_type,'REQUEST_FOR_QUOTE','Y','SOLICITATION','Y',NVL(neg_header_record_data.multiple_rounds_flag,'N')),
      NVL(neg_header_record_data.manual_close_flag,'N'),
      DECODE(l_document_type,'SOLICITATION','N',NVL(neg_header_record_data.manual_extend_flag,'N')),
      NVL(neg_header_record_data.award_approval_flag,'N'),
      neg_header_record_data.auction_origination_code,
      DECODE(l_document_type,'REQUEST_FOR_INFORMATION','NONE', NVL(neg_header_record_data.pf_type_allowed,'NONE')),
      NVL(neg_header_record_data.HDR_ATTR_ENABLE_WEIGHTS,'Y'),
      NULL,
      NULL,
      neg_header_record_data.trading_partner_contact_name,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      neg_header_record_data.AUTO_EXTEND_FLAG,
      neg_header_record_data.AUTO_EXTEND_NUMBER,
      NULL,--neg_header_record_data.NUMBER_OF_EXTENSIONS,
      0,
      neg_header_record_data.MIN_BID_DECREMENT,
      neg_header_record_data.PRICE_DRIVEN_AUCTION_FLAG,
      neg_header_record_data.CARRIER_CODE,
      neg_header_record_data.RATE_DATE,
      NULL,--neg_header_record_data.RATE,
      NULL,
      NULL,
      neg_header_record_data.AUTO_EXTEND_ALL_LINES_FLAG,
      neg_header_record_data.ALLOW_OTHER_BID_CURRENCY_FLAG,
      NULL,
      NULL,
      neg_header_record_data.AUTO_EXTEND_DURATION,
      neg_header_record_data.PROXY_BID_ALLOWED_FLAG,
      neg_header_record_data.PUBLISH_RATES_TO_BIDDERS_FLAG,
      NULL,
      NULL,
      NULL,
      NULL,
      neg_header_record_data.EVENT_ID,
      neg_header_record_data.EVENT_TITLE,
      neg_header_record_data.SEALED_AUCTION_STATUS,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      neg_header_record_data.po_agreed_amount,
      neg_header_record_data.PO_MIN_REL_AMOUNT,
      neg_header_record_data.MIN_BID_CHANGE_TYPE,
      neg_header_record_data.NUMBER_PRICE_DECIMALS,
      neg_header_record_data.AUTO_EXTEND_TYPE_FLAG,
      NULL, --neg_header_record_data.auction_header_id,
      NULL,
      NULL,
      NULL,
      'N',
      NULL,
      'Y',
      'N',
      'N',
      'N',
      NULL,
      'N',
      'N',
      NULL,
      NULL,
      'N',
      'N',
      NULL,
      NULL,
      NULL,
      'Y',
      neg_header_record_data.trading_partner_id,
      neg_header_record_data.trading_partner_contact_id,
      sysdate,
      NULL,
      NULL,
      NULL,
      NULL,
      neg_header_record_data.SHOW_BIDDER_SCORES,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL ,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      'NOT_REQUIRED',
      NULL ,
      NULL,
      NULL,
      --neg_header_record_data.amendment_description,
      NULL,--neg_header_record_data.auction_header_id,
      NULL,
      'N',
      5,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      neg_header_record_data.INT_ATTRIBUTE_CATEGORY,
      neg_header_record_data.INT_ATTRIBUTE1,
      neg_header_record_data.INT_ATTRIBUTE2,
      neg_header_record_data.INT_ATTRIBUTE3,
      neg_header_record_data.INT_ATTRIBUTE4,
      neg_header_record_data.INT_ATTRIBUTE5,
      neg_header_record_data.INT_ATTRIBUTE6,
      neg_header_record_data.INT_ATTRIBUTE7,
      neg_header_record_data.INT_ATTRIBUTE8,
      neg_header_record_data.INT_ATTRIBUTE9,
      neg_header_record_data.INT_ATTRIBUTE10,
      neg_header_record_data.INT_ATTRIBUTE11,
      neg_header_record_data.INT_ATTRIBUTE12 ,
      neg_header_record_data.INT_ATTRIBUTE13 ,
      neg_header_record_data.INT_ATTRIBUTE14 ,
      neg_header_record_data.INT_ATTRIBUTE15,
      neg_header_record_data.EXT_ATTRIBUTE_CATEGORY,
      neg_header_record_data.EXT_ATTRIBUTE1,
      neg_header_record_data.EXT_ATTRIBUTE2,
      neg_header_record_data.EXT_ATTRIBUTE3,
      neg_header_record_data.EXT_ATTRIBUTE4,
      neg_header_record_data.EXT_ATTRIBUTE5 ,
      neg_header_record_data.EXT_ATTRIBUTE6 ,
      neg_header_record_data.EXT_ATTRIBUTE7 ,
      neg_header_record_data.EXT_ATTRIBUTE8,
      neg_header_record_data.EXT_ATTRIBUTE9,
      neg_header_record_data.EXT_ATTRIBUTE10,
      neg_header_record_data.EXT_ATTRIBUTE11,
      neg_header_record_data.EXT_ATTRIBUTE12,
      neg_header_record_data.EXT_ATTRIBUTE13,
      neg_header_record_data.EXT_ATTRIBUTE14 ,
      neg_header_record_data.EXT_ATTRIBUTE15,
      NULL,
      neg_header_record_data.abstract_details,
      NULL,
      neg_header_record_data.SUPPLIER_VIEW_TYPE,
      NULL ,
      NULL,
      NULL,
      0,
      neg_header_record_data.PROJECT_ID,
      NULL,
      NULL,
      NULL ,
      NULL ,
      NULL ,
      NULL ,
      NULL ,
      NULL ,
      NULL,
      NULL,
      NULL ,
      NULL,
      neg_header_record_data.DISPLAY_BEST_PRICE_BLIND_FLAG,
      neg_header_record_data.FIRST_LINE_CLOSE_DATE ,
      neg_header_record_data.STAGGERED_CLOSING_INTERVAL ,
      neg_header_record_data.ENFORCE_PREVRND_BID_PRICE_FLAG,
      neg_header_record_data.AUTO_EXTEND_MIN_TRIGGER_RANK ,
      neg_header_record_data.TWO_PART_FLAG ,
      NULL,
      NULL,
      NULL,
      NULL ,
      NULL,
      NULL,
      'N',
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      neg_header_record_data.trading_partner_contact_id,
      neg_header_record_data.SUPP_REG_QUAL_FLAG,
      neg_header_record_data.SUPP_EVAL_FLAG,
      neg_header_record_data.HIDE_TERMS_FLAG,
      neg_header_record_data.HIDE_ABSTRACT_FORMS_FLAG,
      neg_header_record_data.HIDE_ATTACHMENTS_FLAG,
      neg_header_record_data.INTERNAL_EVAL_FLAG,
      neg_header_record_data.HDR_SUPP_ATTR_ENABLED_FLAG,
      neg_header_record_data.INTGR_HDR_ATTR_FLAG,
      neg_header_record_data.INTGR_HDR_ATTACH_FLAG,
      neg_header_record_data.LINE_SUPP_ATTR_ENABLED_FLAG,
      neg_header_record_data.ITEM_SUPP_ATTR_ENABLED_FLAG,
      neg_header_record_data.INTGR_CAT_LINE_ATTR_FLAG,
      neg_header_record_data.INTGR_ITEM_LINE_ATTR_FLAG,
      neg_header_record_data.INTGR_CAT_LINE_ASL_FLAG,
      'N'
    );
  UPDATE pon_item_prices_interface
  SET auction_header_id = neg_header_record_data.auction_header_id
  WHERE batch_id        = p_batch_id;
  UPDATE PON_AUC_ATTRIBUTES_INTERFACE
  SET auction_header_id = neg_header_record_data.auction_header_id
  WHERE batch_id        = p_batch_id;
  UPDATE pon_attribute_scores_interface
  SET auction_header_id = neg_header_record_data.auction_header_id
  WHERE batch_id        = p_batch_id;
  UPDATE pon_bid_parties_interface
  SET auction_header_id = neg_header_record_data.auction_header_id
  WHERE batch_id        = p_batch_id;
  UPDATE PON_NEG_TEAM_INTERFACE
  SET auction_header_id = neg_header_record_data.auction_header_id
  WHERE batch_id        = p_batch_id;
  UPDATE PON_AUC_PRICE_ELEMENTS_INT
  SET auction_header_id = neg_header_record_data.auction_header_id
  WHERE batch_id        = p_batch_id;
  UPDATE pon_auc_price_breaks_interface
  SET auction_header_id = neg_header_record_data.auction_header_id
  WHERE batch_id        = p_batch_id;
  UPDATE pon_auc_price_differ_int
  SET auction_header_id = neg_header_record_data.auction_header_id
  WHERE batch_id        = p_batch_id;
  --x_auction_header_id := neg_header_record_data.auction_header_id;
  print_log(l_module, 'Header information created for batch id ' || p_batch_id || ' auction_header_id ' || neg_header_record_data.auction_header_id);
EXCEPTION
WHEN OTHERS THEN
  print_log(l_module, 'Sqlcode ' || SQLCODE || 'sqlerrm ' || SQLERRM );
  x_return_status := FND_API.G_RET_STS_ERROR;
END create_negotiation_header;
PROCEDURE header_initial_validation(
    p_batch_id      IN NUMBER,
    x_return_status IN OUT NOCOPY VARCHAR2 )
IS
  --  PRAGMA AUTONOMOUS_TRANSACTION;
  dummy1    VARCHAR2(100);
  l_val_err VARCHAR2(1);
  l_doctype_Id pon_auction_Headers_all.doctype_id%TYPE;
  rfi_doctype_id pon_auction_Headers_all.doctype_id%TYPE;
  l_org_Id pon_auction_Headers_all.org_id%TYPE;
  l_style_Id pon_auction_Headers_all.style_id%TYPE;
  l_po_style_Id pon_auction_Headers_all.po_style_id%TYPE;
  l_po_style_name pon_auction_Headers_interface.po_style_name%TYPE;
  l_contract_type pon_auction_headers_all.contract_type%TYPE;
  l_tpc_id fnd_user.user_id%TYPE;
  l_tpc_name fnd_user.user_Name%TYPE;
  l_dummy_data              VARCHAR2(100);
  l_extra_info              VARCHAR2(100);
  l_row_in_hr               VARCHAR2(100);
  l_vendor_relationship     VARCHAR2(100);
  l_enterprise_relationship VARCHAR2(100);
  l_status                  VARCHAR2(100);
  l_exception_msg           VARCHAR2(100);
  l_cp_user_id              NUMBER;
  l_cp_login_id             NUMBER;
  l_module                  VARCHAR2(250) := g_module_prefix || '.header_initial_validation';
BEGIN
  print_Log(l_module, 'header_initial_validation begin:  p_batch_id ' || p_batch_id);

  l_cp_user_id  := fnd_global.user_id;
  l_cp_login_id := fnd_global.login_id;
  print_log(l_module, 'User Id = '||l_cp_user_id ||' Login id = '||l_cp_login_id);

  SELECT doctype_id,
    org_id,
    style_id,
    po_style_id,
    po_style_name,
    trading_partner_contact_name
  INTO l_doctype_id,
    l_org_id,
    l_style_id,
    l_po_style_id,
    l_po_style_name,
    l_tpc_name
  FROM pon_auction_headers_Interface
  WHERE batch_id = p_batch_id;
  print_log(l_module, 'Doctype Id = '||l_doctype_id||' Org_id = '||l_org_id||' Style Id = '||l_style_id||
                ' PO Style = '||l_po_style_name||
                ' PO Style ID = '||l_po_style_id||
                ' Trading Partner Contact = '||l_tpc_name);

  SELECT DOCTYPE_ID
  INTO rfi_doctype_id
  FROM pon_auc_doctypes
  WHERE INTERNAL_NAME='REQUEST_FOR_INFORMATION';
  print_log(l_module, 'Doc Type ID of RFI in the syetem is : '||rfi_doctype_id);

  print_log(l_module, 'Getting user details of FND user name '||l_tpc_name);
  BEGIN
    SELECT user_id
    INTO l_tpc_id
    FROM fnd_user
    WHERE user_Name                = l_tpc_name
    AND start_date                <= sysdate
    AND NVL(end_date,SYSDATE + 1) >= sysdate;
    print_log(l_module, 'User ID is '||l_tpc_id);

    print_log(l_module, 'Validating user data');
    pon_sourcing_user_manager_pkg.validate_user_data(l_tpc_name, l_dummy_data, l_extra_info, l_row_in_hr,
                    l_vendor_relationship, l_enterprise_relationship, l_status, l_exception_msg);
    print_log(l_module, 'Validation results '||' HR Data = '||l_row_in_hr||' Extra Info = '||l_extra_info||
                    ' Enterprise Relationship = '||l_enterprise_relationship);
    IF ( l_row_in_hr <> 'Y' OR l_extra_info = 'Y' OR l_enterprise_relationship <> 'Y' ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    INSERT
    INTO PON_INTERFACE_ERRORS
      (
        INTERFACE_TYPE ,
        ERROR_MESSAGE_NAME,
        BATCH_ID ,
        ENTITY_TYPE ,
        AUCTION_HEADER_ID ,
        CREATED_BY ,
        CREATION_DATE ,
        LAST_UPDATED_BY ,
        LAST_UPDATE_DATE ,
        LAST_UPDATE_LOGIN
      )
      VALUES
      (
        g_interface_type,
        'PON_IMPORT_INVALID_TPC',
        p_batch_id,
        'HEADER',
        NULL,
        l_cp_user_id,
        SYSDATE,
        l_cp_user_id,
        SYSDATE,
        l_cp_login_id
      );
  END;
  BEGIN
    --Bug 16801033
    IF(l_doctype_id<>rfi_doctype_id) THEN
      print_log(l_module, 'Get PO Style details');

      SELECT pdl.DOCUMENT_SUBTYPE,
        pdh.style_id
      INTO l_contract_type,
        l_po_style_id
      FROM po_doc_style_headers pdh,
        po_all_doc_style_Lines pdl
      WHERE pdh.style_id   = pdl.style_id
      AND pdh.status       = 'ACTIVE'
      AND pdl.enabled_flag = 'Y'
      AND pdl.LANGUAGE     =UserEnv('LANG')
      AND (pdh.style_id = l_po_style_id or
                (pdl.display_name = l_po_style_name and
                    (l_po_style_id is NULL or l_po_style_id = 0)));
      print_log(l_module, 'For PO Style name '||l_po_style_name|| ' style id = '||l_po_style_id||' Document subtype = '||l_contract_type);
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    INSERT
    INTO PON_INTERFACE_ERRORS
      (
        INTERFACE_TYPE ,
        ERROR_MESSAGE_NAME,
        BATCH_ID ,
        ENTITY_TYPE ,
        AUCTION_HEADER_ID ,
        CREATED_BY ,
        CREATION_DATE ,
        LAST_UPDATED_BY ,
        LAST_UPDATE_DATE ,
        LAST_UPDATE_LOGIN
      )
      VALUES
      (
        g_interface_type,
        'PON_IMPORT_INVALID_POSTYLE',
        p_batch_id,
        'HEADER',
        NULL,
        l_cp_user_id,
        SYSDATE,
        l_cp_user_id,
        SYSDATE,
        l_cp_login_id
      );
  END;
  print_Log(l_module, 'Validating Doc type id: '||l_doctype_id);
  BEGIN
    SELECT doctype_group_name
    INTO dummy1
    FROM pon_auc_doctypes
    WHERE doctype_id = l_doctype_id;
    print_Log(l_module, 'Validated Doc type iD');
  EXCEPTION
  WHEN OTHERS THEN
    INSERT
    INTO PON_INTERFACE_ERRORS
      (
        INTERFACE_TYPE ,
        ERROR_MESSAGE_NAME,
        BATCH_ID ,
        ENTITY_TYPE ,
        AUCTION_HEADER_ID ,
        CREATED_BY ,
        CREATION_DATE ,
        LAST_UPDATED_BY ,
        LAST_UPDATE_DATE ,
        LAST_UPDATE_LOGIN
      )
      VALUES
      (
        g_interface_type,
        'PON_IMPORT_INVALID_DOCTYPE',
        p_batch_id,
        'HEADER',
        NULL,
        l_cp_user_id,
        SYSDATE,
        l_cp_user_id,
        SYSDATE,
        l_cp_login_id
      );
  END;
  print_log(l_module, 'Validating Org_id '||l_org_id);
  INSERT ALL
    WHEN (l_org_id IS NULL
    OR NOT EXISTS
      (SELECT 'Y' FROM hr_operating_units WHERE organization_id = l_org_id
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_IMPORT_INVALID_ORG',
      p_batch_id,
      'HEADER',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN (l_style_id IS NULL
    OR NOT EXISTS
      (SELECT 1
      FROM pon_negotiation_styles_vl ds,
        pon_doctype_styles ts
      WHERE ds.style_id   = l_style_id
      AND ds.style_id     = ts.style_id
      AND ds.status       = 'ACTIVE'
      AND ts.doctype_id   = l_doctype_id
      AND ts.enabled_flag = 'Y'
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_IMPORT_INVALID_NEGSTYLE',
      p_batch_id,
      'HEADER',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    --Bug 16801033
    WHEN ((l_doctype_id<>rfi_doctype_id
    AND (l_po_style_id IS NULL
    OR NOT EXISTS
      (SELECT 'Y' FROM po_doc_style_headers WHERE STYLE_ID = l_po_style_id
      )))
    OR (l_doctype_id    =rfi_doctype_id
    AND (l_po_style_id IS NOT NULL
    OR l_po_style_name IS NOT NULL)) ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_IMPORT_INVALID_POSTYLE',
      p_batch_id,
      'HEADER',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
  SELECT 1 FROM dual;
  --l_val_err := 'Y';
  --END IF;
  BEGIN
    SELECT 'E' status
    INTO x_return_status
    FROM dual
    WHERE EXISTS
      (SELECT * FROM pon_interface_errors WHERE BATCH_ID= p_batch_Id
      );
  EXCEPTION
  WHEN No_Data_Found THEN
    x_return_status:=FND_API.G_RET_STS_SUCCESS;
  END;
  print_Log(l_module, 'header_initial_validation : batch_id validated; Return value : '||FND_API.G_RET_STS_SUCCESS);
EXCEPTION
WHEN OTHERS THEN
  print_Log(l_module, 'header_initial_validation : batch_id validated; Return value : '||FND_API.G_RET_STS_ERROR|| 'SQL ERROR : '||SQLERRM);
  x_return_status := FND_API.G_RET_STS_ERROR;
END header_initial_validation;

PROCEDURE process_negotiation_header(
    p_batch_id IN NUMBER,
    p_tp_id    IN NUMBER,
    x_auction_header_id OUT NOCOPY NUMBER,
    x_return_status IN OUT NOCOPY  VARCHAR2 )
AS
  dummy1                 VARCHAR2(100);
  approval_required_flag VARCHAR2(1);
  l_module               VARCHAR2(250) := g_module_prefix || '.process_negotiation_header';
BEGIN
  print_log(l_module, 'process_negotiation_header begin ');
  header_initial_validation( p_batch_id, x_return_status );
  IF( x_return_status = 'E') THEN
    print_Log(l_module, 'process_negotiation_header: Error in pon_auction_headers_interface table. Please check pon_interface_errors for more details' );
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_HEADER_VAL_ERR');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  print_log(l_module, ' Initial set of validations done ');
  -- Call to populate neg_header_record_data record
  -- This record will be used to insert data in pon_auction_headers_all table
  populate_neg_header_rec( p_batch_id, 'N', -- is_amendment
  NULL                                      -- src_auction_header_id
  );
  -- Below call will populate org based, neg style based and po style based data in neg_header_record_data record
  init_rule_based_header_data('N',NULL);
  validate_header( p_batch_id, p_tp_id, 'N', NULL );
  BEGIN
    SELECT 'E' status
    INTO x_return_status
    FROM dual
    WHERE EXISTS
      (SELECT * FROM pon_interface_errors WHERE BATCH_ID= p_batch_Id
      );
  EXCEPTION
  WHEN No_Data_Found THEN
    x_return_status:=FND_API.G_RET_STS_SUCCESS;
  END;
  IF(x_return_status=FND_API.G_RET_STS_ERROR) THEN
    print_Log(l_module, 'Error in pon_auction_headers_interface table. Please check pon_interface_errors for more details' );
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_HEADER_VAL_ERR');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  print_log(l_module, ' Header validations are completed ');
  -- Insert data into pon_auction_headers_all table
  create_negotiation_header(p_batch_id, x_return_status);
  x_auction_header_id := neg_header_record_data.auction_header_id;
  -- add the preparer and his manager in collab team
  create_members_in_collteam(p_batch_id, neg_header_record_data.trading_partner_contact_name, 'Y', 'PON_SOURCING_EDITNEG', 'N', neg_header_record_data.auction_header_id, NULL, NULL, 'N', x_return_status);
  IF( x_return_status = FND_API.G_RET_STS_ERROR) THEN
    print_Log(l_module, 'member addition in collab team failed' );
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_NEGTEAM_ERR');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  -- add any additional member to collab team
  create_neg_team('N', p_batch_id, x_return_status);
  print_log(l_module, 'Collobaration team created for batch id ' || p_batch_id);
  IF( x_return_status = FND_API.G_RET_STS_ERROR) THEN
    print_Log(l_module, 'Adding negotiation team member has failed for batch id ' || p_batch_id);
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_NEGTEAM_ERR');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  BEGIN
    SELECT 'Y'
    INTO approval_required_flag
    FROM dual
    WHERE EXISTS
      (SELECT 1
      FROM pon_neg_team_members
      WHERE auctioN_header_id = neg_header_record_data.auction_header_id
      AND approver_flag       = 'Y'
      );
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  IF(approval_required_flag='Y') THEN
    UPDATE pon_auction_headers_all
    SET approval_status     = 'REQUIRED'
    WHERE auction_header_id = neg_header_record_data.auction_header_id;
  ELSE
    UPDATE pon_auction_headers_all
    SET approval_status     = 'NOT_REQUIRED'
    WHERE auction_header_id = neg_header_record_data.auction_header_id;
  END IF;
  IF( x_return_status = FND_API.G_RET_STS_ERROR) THEN
    print_Log(l_module, 'member addition in collab team failed for batch id ' || p_batch_id);
  END IF;
  -- insert header requirements
  create_header_attr_inter('N', p_batch_id, x_return_status);
  print_log(l_module, 'Header requirements inserted for for batch id ' || p_batch_id);
  IF( x_return_status = FND_API.G_RET_STS_ERROR) THEN
    print_Log(l_module, 'Header requirement creation has failed for for batch id ' || p_batch_id);
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_NEGTEAM_ERR');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  print_log(l_module, 'process_negotiation_header exception : ' || SQLCODE || SQLERRM );
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
END process_negotiation_header;

PROCEDURE validate_header(
    p_batch_id              IN NUMBER,
    p_tp_id                 IN NUMBER,
    p_is_amendment          IN VARCHAR2,
    p_src_auction_header_id IN NUMBER )
AS
  --  PRAGMA AUTONOMOUS_TRANSACTION;
  validate_col           VARCHAR2(30);
  validate_val           VARCHAR2(50);
  validate_sql           VARCHAR2(1000);
  l_batch_id             NUMBER;
  validate_res           VARCHAR2(1);
  l_is_complex           VARCHAR2(1);
  null_check_status      VARCHAR2(1);
  invalid_val_exist_flag VARCHAR2(1);
  doctype_name pon_auc_doctypes.doctype_group_name%TYPE;
  l_cp_user_id  NUMBER;
  l_cp_login_id NUMBER;
  l_module      VARCHAR2(250) := g_module_prefix || '.validate_header';
BEGIN
  print_Log(l_module, 'validate_header begin: p_batch_id ' || p_batch_id || ' p_is_amendment ' || p_is_amendment);
  l_cp_user_id       := fnd_global.user_id;
  l_cp_login_id      := fnd_global.login_id;
  IF( p_is_amendment <> 'Y' ) THEN
    -- Call to check if all mandatory columns in pon_auction_headers_interface table are given non-null values
    null_check( p_batch_id, null_check_status );
    IF( null_check_status = FND_API.G_RET_STS_ERROR) THEN
      print_log(l_module, 'Some mandatory fields in pon_auction_headers_interface table are having null values. Please check ' || ' pon_interface_errors table for more details');
      FND_MESSAGE.SET_NAME('PON','PON_IMPORT_HEADER_NULL_VALUES');
      FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    print_Log(l_module, 'validate_header: columns are successfully validated for null values' );
  END IF;
  SELECT DECODE(NVL(neg_header_record_data.progress_payment_type,'NONE'),'NONE','N','Y')
  INTO l_is_complex
  FROM dual;
  --  Below call populates columns and the possible values
  populate_column_test_table( neg_header_record_data.contract_type, neg_header_record_data.auction_type, l_is_complex );
  print_Log(l_module, 'validate_header: populate_column_test_table completed' );
  -- Loop to check if the values given in pon_auction_headers_interface table are valid values
  print_log(l_module, ' validating header columns');
  FOR i IN 1..header_cols.Count
  LOOP
    BEGIN
      validate_col := header_cols(i);
      print_log(l_module, 'Validate column '||validate_col);
      validate_sql := 'select ' || validate_col || ' from pon_auction_headers_interface ' || ' where batch_id = ' || p_batch_id;
      EXECUTE IMMEDIATE validate_sql INTO validate_val;
      /*
      Based on the column name and column value, below
      procedure will check if value given in interface table
      is a valid one
      */
      CONTINUE WHEN validate_val IS NULL;
      validate_value_column_pair(validate_col,validate_val,validate_res);
      IF(validate_res = 'N') THEN
        print_log(l_module, 'Invalid value in pon_auction_headers_interface ' || validate_col || ' ' || validate_val);
        invalid_val_exist_flag := 'Y';
        INSERT
        INTO PON_INTERFACE_ERRORS
          (
            INTERFACE_TYPE ,
            ERROR_MESSAGE_NAME,
            BATCH_ID ,
            ENTITY_TYPE ,
            AUCTION_HEADER_ID ,
            CREATED_BY ,
            CREATION_DATE ,
            LAST_UPDATED_BY ,
            LAST_UPDATE_DATE ,
            LAST_UPDATE_LOGIN
          )
          VALUES
          (
            g_interface_type,
            'test_col',
            p_batch_id,
            'test_col',
            NULL,
            l_cp_user_id,
            SYSDATE,
            l_cp_user_id,
            SYSDATE,
            l_cp_login_id
          );
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      print_Log(l_module, 'exception ' || SQLCODE || ' errm ' || SQLERRM );
    END;
  END LOOP;
  IF (invalid_val_exist_flag = 'Y' ) THEN
    print_log(l_module, 'Some fields in pon_auction_headers_interface table are having invalid values. ' ||
                        'Please check pon_interface_errors table for more details');
    FND_MESSAGE.SET_NAME('PON','PON_IMPORT_HDR_INV_VALUES');
    FND_MESSAGE.SET_TOKEN('BATCH_ID',p_batch_id);
    FND_MSG_PUB.ADD;
    RETURN;
  END IF;
  print_Log(l_module, 'validate_header: columns are successfully validated for allowed values' );

  SELECT doctype_group_name
  INTO doctype_name
  FROM pon_auc_doctypes
  WHERE doctype_id = neg_header_record_data.doctype_id;

  INSERT ALL
    WHEN ( neg_header_record_data.auction_title IS NULL ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_FIELD_MUST_BE_ENTERED',
      p_batch_id,
      'AUCTION_TITLE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN ( neg_header_record_data.ship_to_location_id IS NOT NULL
    AND neg_header_record_data.ship_to_location_id    <> -1
    AND NOT EXISTS
      (SELECT 1
      FROM po_ship_to_loc_org_v st,
        financials_system_params_all fsp
      WHERE st.location_id     = neg_header_record_data.ship_to_location_id
      AND (st.set_of_books_id IS NULL
      OR st.set_of_books_id    = fsp.set_of_books_id) -- bug 16872313
      AND fsp.org_id           = neg_header_record_data.org_id
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_INV_SHIP_TO',
      p_batch_id,
      'SHIP_TO_LOCATION_ID',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN ((neg_header_record_data.bill_to_location_id IS NOT NULL
    AND neg_header_record_data.bill_to_location_id    <> -1
    AND NOT EXISTS
      (SELECT 'Y'
      FROM HR_LOCATIONS_ALL L
      WHERE L.LOCATION_ID                                                       = neg_header_record_data.bill_to_location_id
      AND NVL(L.BUSINESS_GROUP_ID, NVL(HR_GENERAL.GET_BUSINESS_GROUP_ID,-99) ) = NVL(HR_GENERAL.GET_BUSINESS_GROUP_ID, -99)
      AND SYSDATE                                                               < NVL(L.INACTIVE_DATE, SYSDATE + 1)
      AND NVL(L.BILL_TO_SITE_FLAG,'N')                                          = 'Y'
      ))
    OR (p_is_amendment                             <>'Y'
    AND neg_header_record_data.bill_to_location_id IS NULL)) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_INV_BILL_TO',
      p_batch_id,
      'BILL_TO_LOCATION_ID',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    -- in case of amendment, event information wont be updated
    -- so no need to validate for amendments
    WHEN ( p_is_amendment               <> 'Y'
    AND neg_header_record_data.event_id IS NOT NULL
    AND neg_header_record_data.event_id <> -1
    AND NOT EXISTS
      (SELECT 'Y'
      FROM pon_auction_events
      WHERE event_id                     = neg_header_record_data.event_id
      AND trading_partner_id             = p_tp_id
      AND event_status                  <> 'CANCELLED'
      AND NVL(open_date, SYSDATE - 100) >= SYSDATE
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_INV_EVENTID',
      p_batch_id,
      'EVENT_ID',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN (neg_header_record_data.bid_ranking     ='PRICE_ONLY'
    AND neg_header_record_data.show_bidder_scores='SCORE_WEIGHT') THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_INV_RANKING',
      p_batch_id,
      'SHOW_BIDDER_SCORES',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
  SELECT 1 FROM dual;
  INSERT ALL
    WHEN(neg_header_record_data.progress_payment_flag = 'Y'
    AND (doctype_name NOT                            IN ('REQUEST_FOR_QUOTE','SOLICITATION')
    OR neg_header_record_data.contract_type          <> 'STANDARD')) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_INV_PROGRESS_PYMT',
      p_batch_id,
      'PROGRESS_PAYMENT_FLAG',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.bid_visibility_code = 'OPEN_BIDDING'
    AND doctype_name                               IN ('REQUEST_FOR_QUOTE','SOLICITATION')) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_INV_BID_VISIBILITY',
      p_batch_id,
      'BID_VISIBILITY_CODE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.project_id IS NOT NULL
    AND NOT EXISTS
      (SELECT 'Y'
      FROM pa_projects_expend_v
      WHERE project_Id = neg_header_record_data.project_Id
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_PROJID_INV',
      p_batch_id,
      'PROJECT_ID',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.fob_code    IS NOT NULL
    AND neg_header_record_data.fob_code NOT IN
      (SELECT MEANING
      FROM FND_LOOKUP_VALUES
      WHERE LOOKUP_TYPE = 'FOB'
      AND LANGUAGE      =UserEnv('LANG')
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_NEG_FOB_INV',
      p_batch_id,
      'AUCTION_OUTCOME',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.freight_terms_code    IS NOT NULL
    AND neg_header_record_data.freight_terms_code NOT IN
      (SELECT MEANING
      FROM FND_LOOKUP_VALUES
      WHERE LOOKUP_TYPE = 'FREIGHT TERMS'
      AND LANGUAGE      =UserEnv('LANG')
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_NEG_FREIGHT_INV',
      p_batch_id,
      'AUCTION_OUTCOME',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.payment_terms_id IS NOT NULL
    AND NOT EXISTS
      (SELECT 'Y'
      FROM ap_terms
      WHERE term_id = neg_header_record_data.payment_terms_id
      AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE,SYSDATE-1) AND NVL(END_DATE_ACTIVE,SYSDATE+1)
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_NEG_PYMTTERMS_INV',
      p_batch_id,
      'PAYMENT_TERMS_ID',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN( (p_is_amendment                    <> 'Y'
    AND neg_header_record_data.currency_code IS NULL)
    OR (neg_header_record_data.currency_code IS NOT NULL
    AND NOT EXISTS
      (SELECT 'Y'
      FROM hr_operating_units org,
        gl_sets_of_books sob
      WHERE org.organization_id                 = neg_header_record_data.org_id
      AND org.SET_OF_BOOKS_ID                   = sob.SET_OF_BOOKS_ID
      AND sob.currency_code                     = neg_header_record_data.currency_code
      AND neg_header_record_data.currency_code IS NOT NULL
      ))) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_NEG_CURR_INV',
      p_batch_id,
      'AUCTION_OUTCOME',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    -- for amendment open_bidding_date is not updatable.
    -- so no need to validate
    WHEN( p_is_amendment                                     <> 'Y'
    AND ((neg_header_record_data.open_bidding_date           IS NULL
    AND NVL(neg_header_record_data.open_auction_now_flag,'N') = 'N')
    OR neg_header_record_data.open_bidding_date               < sysdate)) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_NEG_OPENDT_INV',
      p_batch_id,
      'AUCTION_OPEN_DATE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN( p_is_amendment                           <> 'Y'
    AND (neg_header_record_data.close_bidding_date IS NULL
    OR neg_header_record_data.open_bidding_date     > neg_header_record_data.close_bidding_date )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_NEG_CLOSEDT_INV',
      p_batch_id,
      'AUCTION_OPEN_DATE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.CONTRACT_TYPE IN ('BLANKET','CONTRACT')
    AND neg_header_record_data.po_start_date   > neg_header_record_data.po_end_date) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_NEG_AGREEMENTDT_INV',
      p_batch_id,
      'AUCTION_OPEN_DATE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.CONTRACT_TYPE    = 'BLANKET'
    AND neg_header_record_data.po_min_rel_amount < 0 ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_NEG_MINREL_INV',
      p_batch_id,
      'PO_MIN_REL_AMOUNT',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    --  bug 16855333
    WHEN(neg_header_record_data.CONTRACT_TYPE  IN ('BLANKET','CONTRACT')
    AND neg_header_record_data.po_agreed_amount < 0 ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_AGMT_AMT_INV',
      p_batch_id,
      'PON_HEADERS_INTERFACE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.number_price_decimals IS NOT NULL
    AND (neg_header_record_data.number_price_decimals  < 0
    OR neg_header_record_data.number_price_decimals    > 10)) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_PRECISION_INV',
      p_batch_id,
      'PON_HEADERS_INTERFACE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.CONTRACT_TYPE                          = 'BLANKET'
    AND neg_header_record_data.po_min_rel_amount                      IS NOT NULL
    AND neg_header_record_data.number_price_decimals                  IS NOT NULL
    AND (LENGTH (Mod(neg_header_record_data.po_min_rel_amount,1) ) -1) > neg_header_record_data.number_price_decimals ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_NEG_MINREL_PREC',
      p_batch_id,
      'PON_HEADERS_INTERFACE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.CONTRACT_TYPE                        IN ('BLANKET','CONTRACT')
    AND neg_header_record_data.po_agreed_amount                      IS NOT NULL
    AND neg_header_record_data.number_price_decimals                 IS NOT NULL
    AND (LENGTH (Mod(neg_header_record_data.po_agreed_amount,1) ) -1) > neg_header_record_data.number_price_decimals ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_AGMT_AMT_PREC',
      p_batch_id,
      'PON_HEADERS_INTERFACE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.AUTO_EXTEND_FLAG     ='Y'
    AND neg_header_record_data.AUTO_EXTEND_DURATION IS NULL ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_EXT_DUR_NULL',
      p_batch_id,
      'PON_HEADERS_INTERFACE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.AUTO_EXTEND_DURATION IS NOT NULL
    AND neg_header_record_data.AUTO_EXTEND_DURATION   < 0 ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_EXT_DUR_INV',
      p_batch_id,
      'PON_HEADERS_INTERFACE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.AUTO_EXTEND_MIN_TRIGGER_RANK IS NOT NULL
    AND neg_header_record_data.AUTO_EXTEND_MIN_TRIGGER_RANK   < 0 ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_EXT_TRIG_INV',
      p_batch_id,
      'PON_HEADERS_INTERFACE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.AUTO_EXTEND_NUMBER IS NOT NULL
    AND neg_header_record_data.AUTO_EXTEND_NUMBER   < 0 ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_EXT_NUM_INV',
      p_batch_id,
      'PON_HEADERS_INTERFACE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.MIN_BID_DECREMENT IS NOT NULL
    AND neg_header_record_data.MIN_BID_DECREMENT   < 0 ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_EXT_DEC_INV',
      p_batch_id,
      'PON_HEADERS_INTERFACE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
    WHEN(neg_header_record_data.price_driven_auction_flag = 'Y'
    AND neg_header_record_data.bid_frequency_code         = 'SINGLE_BID_ONLY'
    AND NVL(neg_header_record_data.MIN_BID_DECREMENT,0)   > 0 ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_AUC_NO_DECREMENT',
      p_batch_id,
      'PON_HEADERS_INTERFACE',
      NULL,
      l_cp_user_id,
      SYSDATE,
      l_cp_user_id,
      SYSDATE,
      l_cp_login_id
    )
  SELECT neg_header_record_data.org_id FROM dual ;
  print_Log(l_module, 'validate_header  completed ');
EXCEPTION
WHEN OTHERS THEN
  print_log(l_module, 'Exception in validate_Header procedure for batch_id ' || l_batch_id);
  FND_MESSAGE.SET_NAME('PON','PON_IMPORT_VAL_HEADER_ERR');
  FND_MESSAGE.SET_TOKEN('BATCH_ID',l_batch_id);
  FND_MSG_PUB.ADD;
END validate_header;

PROCEDURE populate_neg_header_rec(
    p_batch_id              IN NUMBER,
    p_is_amendment          IN VARCHAR2,
    p_src_auction_header_id IN NUMBER)
AS
  l_org_default_data org_default_data;
  l_document_type pon_auc_doctypes.internal_name%TYPE;
  -- po doc style related fields
  l_advances_flag po_doc_style_headers.advances_flag%TYPE;
  l_retainage_flag po_doc_style_headers.retainage_flag%TYPE;
  l_price_breaks_flag po_doc_style_headers.price_breaks_flag%TYPE;
  l_price_differentials_flag po_doc_style_headers.price_differentials_flag%TYPE;
  l_progress_payment_flag po_doc_style_headers.progress_payment_flag%TYPE;
  l_contract_financing_flag po_doc_style_headers.contract_financing_flag%TYPE;
  l_template_return_status VARCHAR2(1);
  l_template_err_msg       VARCHAR2(200);
  dummy1                   VARCHAR2(100);
  dummy2                   VARCHAR2(100);
  dummy3                   VARCHAR2(100);
  dummy4                   VARCHAR2(100);
  dummy5                   VARCHAR2(100);
  p_error_code             VARCHAR2(1);
  p_error_message          VARCHAR2(100);
  l_module                 VARCHAR2(250) := g_module_prefix || '.populate_neg_header_rec';
BEGIN
  print_log(l_module, 'populate_neg_header_rec begin ');
  print_log(l_module, 'Parameters: '||
    'p_batch_id = '|| p_batch_id ||
    'p_is_amendment = '|| p_is_amendment ||
    'p_src_auction_header_id = '|| p_src_auction_header_id);

  -- For amendment neg_header_record_data.auction_header_id will not be used
  IF ( p_is_amendment <> 'Y' ) THEN
    SELECT pon_auction_headers_all_s.NEXTVAL
    INTO neg_header_record_data.auction_header_id
    FROM dual;
    print_log(l_module, 'New auction_header_id = '||neg_header_record_data.auction_header_id);
  END IF;
  SELECT person_party_id,
    user_name
  INTO neg_header_record_data.trading_partner_contact_id,
    neg_header_record_data.trading_partner_contact_name
  FROM fnd_user usr,
    pon_auction_headers_interface pahi
  WHERE batch_id                             = p_batch_id
  AND usr.user_name                          = pahi.trading_partner_contact_name
  AND usr.start_date                        <= SYSDATE
  AND NVL(usr.end_date,SYSDATE + 1)         >= SYSDATE ;
  neg_header_record_data.trading_partner_id := g_trading_partner_id ;
  print_log(l_module, ' User name = '||neg_header_record_data.trading_partner_contact_name||
            ' Party id = '||neg_header_record_data.trading_partner_contact_id||
            ' for user = '||neg_header_record_data.trading_partner_contact_name);
  print_log (l_module, 'Calling pos_enterprise_util_pkg.get_enterprise_party_name');
  pos_enterprise_util_pkg.get_enterprise_party_name(neg_header_record_data.trading_partner_name, P_ERROR_CODE, P_ERROR_MESSAGE);
  print_log(l_module, ' Trading partner name = '||neg_header_record_data.trading_partner_name);
  print_log(l_module, 'Error code: '||p_error_code||' error message ' ||p_error_message);

  print_log(l_module, 'Populating data from interface table to neg_header_record_data');
  SELECT auction_title,
    description,
    contract_type,
    bid_visibility_code,
    doctype_id,
    org_id,
    buyer_id,
    global_agreement_flag,
    style_id,
    po_style_id,
    po_style_name,
    price_break_response,
    advance_negotiable_flag,
    recoupment_negotiable_flag,
    progress_pymt_negotiable_flag,
    retainage_negotiable_flag,
    max_retainage_negotiable_flag,
    supplier_enterable_pymt_flag,
    progress_payment_type,
    line_mas_enabled_flag,
    price_tiers_indicator,
    ship_to_location_id,
    ship_to_location_code,
    bill_to_location_id,
    bill_to_location_code,
    payment_terms_id,
    fob_code,
    freight_terms_code,
    rate_type,
    --currency_code, -- bug 16872313
    rate_date,
    security_level_code,
    po_start_date,
    po_end_date,
    open_auction_now_flag,
    open_bidding_date,
    close_bidding_date,
    publish_auction_now_flag,
    --publish_date,
    --auction_published_flag,
    view_by_date,
    note_to_bidders,
    show_bidder_notes,
    bid_scope_code,
    bid_list_type,
    bid_frequency_code,
    bid_ranking,
    rank_indicator,
    full_quantity_bid_code,
    multiple_rounds_flag,
    manual_close_flag,
    manual_extend_flag,
    award_approval_flag,
    auction_origination_code,
    pf_type_allowed,
    hdr_attr_enable_weights,
    award_by_date,
    auto_extend_flag,
    auto_extend_number,
    min_bid_decrement,
    min_bid_change_type,
    price_driven_auction_flag,
    carrier_code,
    auto_extend_all_lines_flag,
    allow_other_bid_currency_flag,
    auto_extend_duration,
    publish_rates_to_bidders_flag,
    event_id,
    event_title,
    sealed_auction_status,
    auto_extend_type_flag,
    show_bidder_scores,
    po_agreed_amount,
    po_min_rel_amount,
    hdr_attr_display_score,
    int_attribute_category,
    int_attribute1,
    int_attribute2,
    int_attribute3,
    int_attribute4,
    int_attribute5,
    int_attribute6,
    int_attribute7,
    int_attribute8 ,
    int_attribute9,
    int_attribute10,
    int_attribute11,
    int_attribute12,
    int_attribute13,
    int_attribute14,
    int_attribute15,
    ext_attribute_category,
    ext_attribute1,
    ext_attribute2,
    ext_attribute3,
    ext_attribute4,
    ext_attribute5,
    ext_attribute6,
    ext_attribute7 ,
    ext_attribute8,
    ext_attribute9,
    ext_attribute10,
    ext_attribute11,
    ext_attribute12,
    ext_attribute13,
    ext_attribute14,
    ext_attribute15,
    abstract_details,
    supplier_view_type,
    project_id,
    bid_decrement_method ,
    display_best_price_blind_flag,
    first_line_close_date,
    staggered_closing_interval,
    enforce_prevrnd_bid_price_flag,
    auto_extend_min_trigger_rank,
    two_part_flag,
    --standard_form,
    --document_format,
    --amendment_description,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    number_price_decimals -- bug 16855333
  INTO neg_header_record_data.auction_title,
    neg_header_record_data.description,
    neg_header_record_data.contract_type,
    neg_header_record_data.bid_visibility_code,
    neg_header_record_data.doctype_id,
    neg_header_record_data.org_id,
    neg_header_record_data.buyer_id,
    neg_header_record_data.global_agreement_flag,
    neg_header_record_data.style_id,
    neg_header_record_data.po_style_id,
    neg_header_record_data.po_style_name,
    neg_header_record_data.price_break_response,
    neg_header_record_data.advance_negotiable_flag,
    neg_header_record_data.recoupment_negotiable_flag,
    neg_header_record_data.progress_pymt_negotiable_flag,
    neg_header_record_data.retainage_negotiable_flag,
    neg_header_record_data.max_retainage_negotiable_flag,
    neg_header_record_data.supplier_enterable_pymt_flag,
    neg_header_record_data.progress_payment_type,
    neg_header_record_data.line_mas_enabled_flag,
    neg_header_record_data.price_tiers_indicator,
    neg_header_record_data.ship_to_location_id,
    neg_header_record_data.ship_to_location_code,
    neg_header_record_data.bill_to_location_id,
    neg_header_record_data.bill_to_location_code,
    neg_header_record_data.payment_terms_id,
    neg_header_record_data.fob_code,
    neg_header_record_data.freight_terms_code,
    neg_header_record_data.rate_type,
    --neg_header_record_data.currency_code,
    neg_header_record_data.rate_date,
    neg_header_record_data.security_level_code,
    neg_header_record_data.po_start_date,
    neg_header_record_data.po_end_date,
    neg_header_record_data.open_auction_now_flag,
    neg_header_record_data.open_bidding_date,
    neg_header_record_data.close_bidding_date,
    neg_header_record_data.publish_auction_now_flag,
    --neg_header_record_data.publish_date,
    --neg_header_record_data.auction_published_flag,
    neg_header_record_data.view_by_date,
    neg_header_record_data.note_to_bidders,
    neg_header_record_data.show_bidder_notes,
    neg_header_record_data.bid_scope_code,
    neg_header_record_data.bid_list_type,
    neg_header_record_data.bid_frequency_code,
    neg_header_record_data.bid_ranking,
    neg_header_record_data.rank_indicator,
    neg_header_record_data.full_quantity_bid_code,
    neg_header_record_data.multiple_rounds_flag,
    neg_header_record_data.manual_close_flag,
    neg_header_record_data.manual_extend_flag,
    neg_header_record_data.award_approval_flag,
    neg_header_record_data.auction_origination_code,
    neg_header_record_data.pf_type_allowed,
    neg_header_record_data.hdr_attr_enable_weights,
    neg_header_record_data.award_by_date,
    neg_header_record_data.auto_extend_flag,
    neg_header_record_data.auto_extend_number,
    neg_header_record_data.min_bid_decrement,
    neg_header_record_data.min_bid_change_type,
    neg_header_record_data.price_driven_auction_flag,
    neg_header_record_data.carrier_code,
    neg_header_record_data.auto_extend_all_lines_flag,
    neg_header_record_data.allow_other_bid_currency_flag,
    neg_header_record_data.auto_extend_duration,
    neg_header_record_data.publish_rates_to_bidders_flag,
    neg_header_record_data.event_id,
    neg_header_record_data.event_title,
    neg_header_record_data.sealed_auction_status,
    neg_header_record_data.auto_extend_type_flag,
    neg_header_record_data.show_bidder_scores,
    neg_header_record_data.po_agreed_amount,
    neg_header_record_data.po_min_rel_amount,
    neg_header_record_data.hdr_attr_display_score,
    neg_header_record_data.int_attribute_category,
    neg_header_record_data.int_attribute1,
    neg_header_record_data.int_attribute2,
    neg_header_record_data.int_attribute3,
    neg_header_record_data.int_attribute4 ,
    neg_header_record_data.int_attribute5,
    neg_header_record_data.int_attribute6,
    neg_header_record_data.int_attribute7,
    neg_header_record_data.int_attribute8,
    neg_header_record_data.int_attribute9,
    neg_header_record_data.int_attribute10,
    neg_header_record_data.int_attribute11,
    neg_header_record_data.int_attribute12,
    neg_header_record_data.int_attribute13,
    neg_header_record_data.int_attribute14,
    neg_header_record_data.int_attribute15,
    neg_header_record_data.ext_attribute_category,
    neg_header_record_data.ext_attribute1,
    neg_header_record_data.ext_attribute2,
    neg_header_record_data.ext_attribute3,
    neg_header_record_data.ext_attribute4,
    neg_header_record_data.ext_attribute5,
    neg_header_record_data.ext_attribute6,
    neg_header_record_data.ext_attribute7,
    neg_header_record_data.ext_attribute8,
    neg_header_record_data.ext_attribute9,
    neg_header_record_data.ext_attribute10,
    neg_header_record_data.ext_attribute11,
    neg_header_record_data.ext_attribute12,
    neg_header_record_data.ext_attribute13,
    neg_header_record_data.ext_attribute14,
    neg_header_record_data.ext_attribute15,
    neg_header_record_data.abstract_details,
    neg_header_record_data.supplier_view_type,
    neg_header_record_data.project_id,
    neg_header_record_data.bid_decrement_method,
    neg_header_record_data.display_best_price_blind_flag,
    neg_header_record_data.first_line_close_date,
    neg_header_record_data.staggered_closing_interval,
    neg_header_record_data.enforce_prevrnd_bid_price_flag,
    neg_header_record_data.auto_extend_min_trigger_rank,
    neg_header_record_data.two_part_flag,
    --neg_header_record_data.standard_form,
    --neg_header_record_data.document_format,
    --neg_header_record_data.amendment_description,
    neg_header_record_data.creation_date,
    neg_header_record_data.created_by,
    neg_header_record_data.last_update_date,
    neg_header_record_data.last_updated_by,
    neg_header_record_data.number_price_decimals
  FROM pon_auction_headers_interface
  WHERE batch_id = p_batch_id;

  print_log(l_module, 'Populated data; row count = '||SQL%ROWCOUNT);

  SELECT internal_name,
    transaction_type
  INTO l_document_type,
    neg_header_record_data.auction_type
  FROM pon_auc_doctypes
  WHERE doctype_id    = neg_header_record_data.doctype_id;

  print_log(l_module, ' Document type = '||l_document_type||' Transaction type = '||
            neg_header_record_data.auction_type||' from doctype id = '||
            neg_header_record_data.doctype_id);

  IF ( p_is_amendment = 'Y' ) THEN
    print_log(l_module, ' For amendmentment reading the ogiginal values ');
    SELECT org_id,
      doctype_id,
      style_id,
      po_style_Id,
      contract_type
    INTO neg_header_record_data.org_id,
      neg_header_record_data.doctype_id,
      neg_header_record_data.style_id,
      neg_header_record_data.po_style_Id,
      neg_header_record_data.contract_type
    FROM pon_auction_headers_all
    WHERE auction_header_id = p_src_auction_header_id;
    print_log(l_module,
                'org_id '|| neg_header_record_data.org_id||
                  ' doctype_id '|| neg_header_record_data.doctype_id||
                  ' style_id '|| neg_header_record_data.style_id||
                  ' po_style_Id '|| neg_header_record_data.po_style_Id||
                  ' contract_type '|| neg_header_record_data.contract_type);

  END IF;
  print_log(l_module, 'populate_neg_header_rec END ');
EXCEPTION
WHEN OTHERS THEN
  print_Log(l_module, 'Error in populate_neg_header_rec procedure' );
  RAISE FND_API.G_EXC_ERROR;
END populate_neg_header_rec;

PROCEDURE init_rule_based_header_data(
    p_is_amendment          IN VARCHAR2,
    p_src_auction_Header_id IN NUMBER)
AS
  --organization based default data
  l_org_default_data org_default_data;
  l_document_type pon_auc_doctypes.internal_name%TYPE;
  rfi_doctype_id pon_auction_Headers_all.doctype_id%TYPE;
  -- po doc style related fields
  l_advances_flag po_doc_style_headers.advances_flag%TYPE;
  l_retainage_flag po_doc_style_headers.retainage_flag%TYPE;
  l_price_breaks_flag po_doc_style_headers.price_breaks_flag%TYPE;
  l_price_differentials_flag po_doc_style_headers.price_differentials_flag%TYPE;
  l_progress_payment_flag po_doc_style_headers.progress_payment_flag%TYPE;
  l_contract_financing_flag po_doc_style_headers.contract_financing_flag%TYPE;
  dummy1   VARCHAR2(100);
  dummy2   VARCHAR2(100);
  dummy3   VARCHAR2(100);
  dummy4   VARCHAR2(100);
  dummy5   VARCHAR2(100);
  l_module VARCHAR2(250) := g_module_prefix || '.init_rule_based_header_data';
BEGIN
  print_log(l_module, 'init_rule_based_header_data begin ');
  SELECT internal_name,
    transaction_type
  INTO l_document_type,
    neg_header_record_data.auction_type
  FROM pon_auc_doctypes
  WHERE doctype_id = neg_header_record_data.doctype_id;
  SELECT DOCTYPE_ID
  INTO rfi_doctype_id
  FROM pon_auc_doctypes
  WHERE INTERNAL_NAME='REQUEST_FOR_INFORMATION';
  BEGIN
    IF (p_is_amendment <> 'Y' AND rfi_doctype_id<>neg_header_record_data.doctype_id) THEN
      print_log(l_module, 'init_rule_based_header_data: Document not RFI ');
      SELECT pdl.DOCUMENT_SUBTYPE,
        pdh.style_id
      INTO neg_header_record_data.contract_type,
        neg_header_record_data.po_style_id
      FROM po_doc_style_headers pdh,
        po_all_doc_style_Lines pdl
      WHERE pdh.style_id   = pdl.style_id
      AND pdh.status       = 'ACTIVE'
      AND pdl.enabled_flag = 'Y'
      AND pdl.LANGUAGE     =UserEnv('LANG')
      AND pdl.display_name = neg_header_record_data.po_style_name;
      print_log(l_module, ' Document subtype = '||
                    neg_header_record_data.contract_type||
                ' PO Style ID = '||
                    neg_header_record_data.po_style_id);
    END IF;
  EXCEPTION
  WHEN No_Data_Found THEN
    neg_header_record_data.contract_type:=NULL;
    neg_header_record_data.po_style_id  := NULL;
  END;

  BEGIN
    print_log(l_module, 'Get ship to location ');
    SELECT location_id
    INTO neg_header_record_data.ship_to_location_id
    FROM po_ship_to_loc_org_v po_v
    WHERE po_v.location_code = neg_header_record_data.ship_to_location_code
    AND neg_header_record_data.ship_to_location_code IS NOT NULL;
    print_log(l_module, ' Location code: '||neg_header_record_data.ship_to_location_code||
                        ' Location Id: '||neg_header_record_data.ship_to_location_id);
  EXCEPTION
  WHEN No_Data_Found THEN
    NULL;
  END;

  BEGIN
    print_log(l_module, 'Get bill to location ');
    SELECT location_id
    INTO neg_header_record_data.bill_to_location_id
    FROM HR_LOCATIONS_ALL L
    WHERE L.LOCATION_CODE  = neg_header_record_data.bill_to_location_code
    AND neg_header_record_data.bill_to_location_code IS NOT NULL
    AND NVL(L.BUSINESS_GROUP_ID, NVL(HR_GENERAL.GET_BUSINESS_GROUP_ID, -99) ) = NVL(HR_GENERAL.GET_BUSINESS_GROUP_ID, -99)
    AND SYSDATE < NVL(L.INACTIVE_DATE, SYSDATE + 1)
    AND NVL(L.BILL_TO_SITE_FLAG,'N') = 'Y';
    print_log(l_module, ' Location code: '||neg_header_record_data.bill_to_location_code||
                        ' Location Id: '||neg_header_record_data.bill_to_location_id);
  EXCEPTION
  WHEN No_Data_Found THEN
    NULL;
  END;

  print_log(l_module, 'Getting Organizaton defaults for Org Id = '||neg_header_record_data.org_id ||
                ' doctype Id = '||neg_header_record_data.doctype_id );
  SELECT DISTINCT psp.org_id ,
    fsp.bill_to_location_id ,
    fsp.ship_to_location_id ,
    fsp.terms_id ,
    fsp.fob_lookup_code ,
    fsp.freight_terms_lookup_code ,
    psp.default_rate_type ,
    sob.currency_code ,
    posl.security_level_code
  INTO l_org_default_data
  FROM po_system_parameters_all psp ,
    hr_all_organization_units_tl haou ,
    financials_system_params_all fsp ,
    gl_sets_of_books sob ,
    hr_locations_all_tl bill_to ,
    hr_locations_all_tl ship_to ,
    (SELECT po.org_id,
      po.security_level_code,
      pon.doctype_id
    FROM po_document_types_all po,
      pon_auc_doctypes pon
    WHERE po.document_type_code = pon.document_type_code
    AND po.document_subtype     = pon.document_subtype
    AND po.security_level_code IS NOT NULL
    ) posl
  WHERE psp.org_id                              = haou.organization_id
  AND haou.language                             = USERENV('LANG')
  AND psp.org_id                                = fsp.org_id (+)
  AND fsp.set_of_books_id                       = sob.set_of_books_id (+)
  AND fsp.bill_to_location_id                   = bill_to.location_id (+)
  AND fsp.ship_to_location_id                   = ship_to.location_id (+)
  AND psp.org_id                                = posl.org_id(+)
  AND neg_header_record_data.doctype_id         = posl.doctype_id (+)
  AND neg_header_record_data.org_id             = psp.org_id
  AND bill_to.LANGUAGE(+)                       = USERENV('LANG')
  AND ship_to.LANGUAGE(+)                       = USERENV('LANG');

  print_log(l_module,
    ' org_id = '|| l_org_default_data.org_id ||
    ' bill_to_location_id = '|| l_org_default_data.bill_to_location_id ||
    ' ship_to_location_id = '|| l_org_default_data.ship_to_location_id ||
    ' terms_id = '|| l_org_default_data.payment_terms_id ||
    ' fob_lookup_code = '|| l_org_default_data.fob_code ||
    ' freight_terms_lookup_code = '|| l_org_default_data.freight_terms_code ||
    ' default_rate_type = '|| l_org_default_data.rate_type ||
    ' currency_code = '|| l_org_default_data.currency_code ||
    ' security_level_code = '|| l_org_default_data.security_level_code);

  IF ( p_is_amendment                          <> 'Y' ) THEN
    neg_header_record_data.bill_to_location_id := NVL(neg_header_record_data.bill_to_location_id,l_org_default_data.bill_to_location_id);
    neg_header_record_data.ship_to_location_id := NVL(neg_header_record_data.ship_to_location_id,l_org_default_data.ship_to_location_id);
    neg_header_record_data.payment_terms_id    := NVL(neg_header_record_data.payment_terms_id,l_org_default_data.payment_terms_id);
    neg_header_record_data.fob_code            := NVL(neg_header_record_data.fob_code,l_org_default_data.fob_code);
    neg_header_record_data.freight_terms_code  := NVL(neg_header_record_data.freight_terms_code,l_org_default_data.freight_terms_code);
    neg_header_record_data.rate_type           := NVL(neg_header_record_data.rate_type,l_org_default_data.rate_type);
    neg_header_record_data.currency_code       := NVL(neg_header_record_data.currency_code,l_org_default_data.currency_code);
    neg_header_record_data.security_level_code := NVL(neg_header_record_data.security_level_code,l_org_default_data.security_level_code);
  END IF;

  print_log(l_module, 'Reading data from Negotiation Styles for STYLE_ID = '||neg_header_record_data.style_id);

  SELECT LINE_ATTRIBUTE_ENABLED_FLAG,
    LINE_MAS_ENABLED_FLAG,
    PRICE_ELEMENT_ENABLED_FLAG,
    RFI_LINE_ENABLED_FLAG,
    LOT_ENABLED_FLAG,
    GROUP_ENABLED_FLAG,
    LARGE_NEG_ENABLED_FLAG,
    HDR_ATTRIBUTE_ENABLED_FLAG,
    NEG_TEAM_ENABLED_FLAG,
    PROXY_BIDDING_ENABLED_FLAG,
    POWER_BIDDING_ENABLED_FLAG,
    AUTO_EXTEND_ENABLED_FLAG,
    TEAM_SCORING_ENABLED_FLAG ,
    QTY_PRICE_TIERS_ENABLED_FLAG,
    SUPP_REG_QUAL_FLAG,
    SUPP_EVAL_FLAG,
    HIDE_TERMS_FLAG,
    HIDE_ABSTRACT_FORMS_FLAG,
    HIDE_ATTACHMENTS_FLAG,
    INTERNAL_EVAL_FLAG,
    HDR_SUPP_ATTR_ENABLED_FLAG,
    INTGR_HDR_ATTR_FLAG,
    INTGR_HDR_ATTACH_FLAG,
    LINE_SUPP_ATTR_ENABLED_FLAG,
    ITEM_SUPP_ATTR_ENABLED_FLAG,
    INTGR_CAT_LINE_ATTR_FLAG,
    INTGR_ITEM_LINE_ATTR_FLAG,
    INTGR_CAT_LINE_ASL_FLAG
  INTO neg_header_record_data.LINE_ATTRIBUTE_ENABLED_FLAG,
    neg_header_record_data.LINE_MAS_ENABLED_FLAG,
    neg_header_record_data.PRICE_ELEMENT_ENABLED_FLAG,
    neg_header_record_data.RFI_LINE_ENABLED_FLAG,
    neg_header_record_data.LOT_ENABLED_FLAG,
    neg_header_record_data.GROUP_ENABLED_FLAG,
    neg_header_record_data.LARGE_NEG_ENABLED_FLAG,
    neg_header_record_data.HDR_ATTRIBUTE_ENABLED_FLAG,
    neg_header_record_data.NEG_TEAM_ENABLED_FLAG,
    neg_header_record_data.PROXY_BIDDING_ENABLED_FLAG,
    neg_header_record_data.POWER_BIDDING_ENABLED_FLAG,
    neg_header_record_data.AUTO_EXTEND_ENABLED_FLAG,
    neg_header_record_data.TEAM_SCORING_ENABLED_FLAG ,
    neg_header_record_data.QTY_PRICE_TIERS_ENABLED_FLAG,
    neg_header_record_data.SUPP_REG_QUAL_FLAG,
    neg_header_record_data.SUPP_EVAL_FLAG,
    neg_header_record_data.HIDE_TERMS_FLAG,
    neg_header_record_data.HIDE_ABSTRACT_FORMS_FLAG,
    neg_header_record_data.HIDE_ATTACHMENTS_FLAG,
    neg_header_record_data.INTERNAL_EVAL_FLAG,
    neg_header_record_data.HDR_SUPP_ATTR_ENABLED_FLAG,
    neg_header_record_data.INTGR_HDR_ATTR_FLAG,
    neg_header_record_data.INTGR_HDR_ATTACH_FLAG,
    neg_header_record_data.LINE_SUPP_ATTR_ENABLED_FLAG,
    neg_header_record_data.ITEM_SUPP_ATTR_ENABLED_FLAG,
    neg_header_record_data.INTGR_CAT_LINE_ATTR_FLAG,
    neg_header_record_data.INTGR_ITEM_LINE_ATTR_FLAG,
    neg_header_record_data.INTGR_CAT_LINE_ASL_FLAG
  FROM PON_NEGOTIATION_STYLES
  WHERE STYLE_ID  = neg_header_record_data.style_id;

  print_log(l_module, 'Read data from Negotiation Styles ');

  IF ( neg_header_record_data.QTY_PRICE_TIERS_ENABLED_FLAG = 'N' ) THEN
    neg_header_record_data.price_tiers_indicator          := NULL;
  END IF;

  IF(rfi_doctype_id<>neg_header_record_data.doctype_id) THEN
    print_log(l_module, 'Reading PO Style data');
    PO_DOC_STYLE_GRP.GET_DOCUMENT_STYLE_SETTINGS( p_api_version => 1.0 ,
                    p_style_id => neg_header_record_data.po_style_id ,
                    x_style_name => dummy1 , x_style_description => dummy2 ,
                    x_style_type => dummy3 , x_status => dummy4 ,
                    x_advances_flag => l_advances_flag ,
                    x_retainage_flag => l_retainage_flag ,
                    x_price_breaks_flag => l_price_breaks_flag ,
                    x_price_differentials_flag => l_price_differentials_flag ,
                    x_progress_payment_flag => l_progress_payment_flag ,
                    x_contract_financing_flag => l_contract_financing_flag ,
                    x_line_type_allowed => dummy5);
    print_log(l_module,
                    ' advances_flag => '|| l_advances_flag ||
                    ' retainage_flag =>  '||l_retainage_flag ||
                    ' price_breaks_flag =>  '||l_price_breaks_flag ||
                    ' price_differentials_flag =>  '||l_price_differentials_flag ||
                    ' progress_payment_flag =>  '||l_progress_payment_flag ||
                    ' contract_financing_flag =>  '||l_contract_financing_flag );
  END IF;
  neg_header_record_data.progress_payment_flag       := l_progress_payment_flag;
  IF(NVL(l_advances_flag,'N')                         ='N') THEN
    neg_header_record_data.advance_negotiable_flag   :='N';
    neg_header_record_data.recoupment_negotiable_flag:='N';
  END IF;
  IF(NVL(l_retainage_flag,'N')                           ='N') THEN
    neg_header_record_data.retainage_negotiable_flag    :='N';
    neg_header_record_data.max_retainage_negotiable_flag:='N';
  END IF;
  IF(NVL(l_progress_payment_flag,'N')                    ='N') THEN
    neg_header_record_data.progress_pymt_negotiable_flag:='N';
  END IF;
  IF (l_contract_financing_flag                   = 'Y') THEN
    neg_header_record_data.progress_payment_type := 'FINANCE';
  ELSE
    neg_header_record_data.progress_payment_type := 'ACTUAL';
  END IF;
  IF ( NVL(l_progress_payment_flag,'N')                 <> 'Y' ) THEN
    neg_header_record_data.advance_negotiable_flag      :=NULL;
    neg_header_record_data.recoupment_negotiable_flag   :=NULL;
    neg_header_record_data.retainage_negotiable_flag    :=NULL;
    neg_header_record_data.max_retainage_negotiable_flag:=NULL;
    neg_header_record_data.progress_pymt_negotiable_flag:=NULL;
    neg_header_record_data.progress_payment_type        := 'NONE';
  END IF;
  IF (NVL(l_price_breaks_flag,'N')              ='N') THEN
    neg_header_record_data.price_break_response:=NULL;
  ELSE
    IF(neg_header_record_data.price_break_response IS NULL) THEN
      neg_header_record_data.price_break_response  := 'NONE';
    END IF;
  END IF;
  IF ( neg_header_record_data.contract_type       = 'STANDARD' OR rfi_doctype_id = neg_header_record_data.doctype_id) THEN
    neg_header_record_data.GLOBAL_AGREEMENT_FLAG := 'N';
    neg_header_record_data.po_agreed_amount      := NULL; -- bug 16855333
    neg_header_record_data.po_min_rel_amount     := NULL;
    neg_header_record_data.po_start_date         := NULL;
    neg_header_record_data.po_end_date           := NULL;
  END IF;
  IF ( neg_header_record_data.contract_type   = 'CONTRACT' ) THEN
    neg_header_record_data.po_min_rel_amount := NULL;
  END IF;
  IF( (neg_header_record_data.contract_type      = 'BLANKET' AND l_document_type='SOLICITATION') OR neg_header_record_data.contract_type = 'CONTRACT' ) THEN -- bug 16855333
    neg_header_record_data.GLOBAL_AGREEMENT_FLAG:='Y';
  END IF;
  IF( neg_header_record_data.contract_type    = 'BLANKET' AND neg_header_record_data.GLOBAL_AGREEMENT_FLAG='Y') THEN
    neg_header_record_data.PO_MIN_REL_AMOUNT := NULL;
  END IF;
  IF ( neg_header_record_data.bid_visibility_code IS NULL) THEN
    neg_header_record_data.bid_visibility_code    := 'SEALED_BIDDING';
  END IF;
  BEGIN
    SELECT event_id
    INTO neg_header_record_data.event_id
    FROM pon_auction_events
    WHERE event_title                       = neg_header_record_data.event_title
    AND neg_header_record_data.event_title IS NOT NULL
    AND trading_partner_id                  = neg_header_record_data.trading_partner_id
    AND event_status                       <> 'CANCELLED'
    AND NVL(open_date, SYSDATE - 100)      >= SYSDATE;
  EXCEPTION
  WHEN No_Data_Found THEN
    NULL;
  END;
  -- bug 16898220
  IF (rfi_doctype_id                              = neg_header_record_data.doctype_id) THEN
    neg_header_record_data.pf_type_allowed       := 'NONE';
    neg_header_record_data.bid_ranking           := 'PRICE_ONLY';
    neg_header_record_data.rank_indicator        := 'NONE';
    neg_header_record_data.global_agreement_flag := NULL;
    neg_header_record_data.price_break_response  := 'NONE';
    neg_header_record_data.price_tiers_indicator := NULL;
    neg_header_record_data.supplier_view_type    := 'TRANSFORMED';
  END IF;
  print_Log(l_module, 'Completing init_rule_based_header_data procedure ');
EXCEPTION
WHEN OTHERS THEN
  print_Log(l_module, 'Error in pon_auction_headers_interface table. Please check pon_interface_errors for more details' );
  FND_MESSAGE.SET_NAME('PON','PON_IMPORT_HEADER_INIT_ERR');
  FND_MSG_PUB.ADD;
  RAISE FND_API.G_EXC_ERROR;
END init_rule_based_header_data;

PROCEDURE insert_error(
    p_error_msg         IN VARCHAR2 ,
    p_batch_id          IN NUMBER,
    p_entity_type       IN VARCHAR2,
    p_auction_header_id IN NUMBER,
    p_user_id           IN NUMBER,
    p_user_login        IN NUMBER)
AS
  l_module VARCHAR2(250) := g_module_prefix || '.insert_error';
BEGIN
  INSERT
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      p_error_msg,
      p_batch_id,
      p_entity_type,
      p_auction_header_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      p_user_login
    );
END insert_error;
PROCEDURE line_sanity_validation
  (
    p_batch_id IN NUMBER
  )
IS
  dummy          NUMBER;
  rfi_doctype_id NUMBER;
  l_module       VARCHAR2(250) := g_module_prefix || '.line_sanity_validation';
BEGIN
  INSERT ALL
    WHEN (sel_line_id > 1
    AND NOT EXISTS
      (SELECT interface_line_id
      FROM pon_item_prices_interface t2
      WHERE t2.batch_id        = p_batch_id
      AND t2.interface_line_id = (sel_line_id - 1)
      ) ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      line_number,
      ENTITY_TYPE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      'LINES',
      'PON_IMPORT_LINE_NUM_ERR',
      p_batch_id,
      sel_line_id,
      'PON_ITEM_PRICES_INTERFACE',
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN (sel_line_id   < 1
    OR ( sel_line_id    = 1
    AND sel_group_type IN ('LOT_LINE','GROUP_LINE'))) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      line_number,
      ENTITY_TYPE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      'LINES',
      'PON_IMPORT_LINE_NUM_ERR',
      p_batch_id,
      sel_line_id,
      'PON_ITEM_PRICES_INTERFACE',
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN (sel_line_id > 1
    AND EXISTS
      (SELECT interface_line_id
      FROM pon_item_prices_interface t2
      WHERE t2.batch_id        = p_batch_id
      AND t2.interface_line_id = (sel_line_id - 1)
      AND ( (sel_group_type    = 'LOT_LINE'
      AND t2.group_type NOT   IN ('LOT','LOT_LINE'))
      OR (sel_group_type       = 'GROUP_LINE'
      AND t2.group_type NOT   IN ('GROUP','GROUP_LINE')) )
      ) ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      line_number,
      ENTITY_TYPE ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      'LINES',
      'PON_IMPORT_LINE_ORDER_ERR',
      p_batch_id,
      sel_line_id,
      'PON_ITEM_PRICES_INTERFACE',
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
  SELECT interface_line_id sel_line_id,
    group_type sel_group_type
  FROM pon_item_prices_interface
  WHERE batch_id = p_batch_id;
  BEGIN
    SELECT 1
    INTO dummy
    FROM dual
    WHERE NOT EXISTS
      (SELECT interface_line_id
      FROM pon_item_prices_interface
      WHERE batch_id        = p_batch_id
      AND interface_line_id = 1
      );
    INSERT
    INTO PON_INTERFACE_ERRORS
      (
        INTERFACE_TYPE ,
        ERROR_MESSAGE_NAME,
        BATCH_ID ,
        ENTITY_TYPE ,
        CREATED_BY ,
        CREATION_DATE ,
        LAST_UPDATED_BY ,
        LAST_UPDATE_DATE ,
        LAST_UPDATE_LOGIN
      )
      VALUES
      (
        'LINES',
        'PON_IMPORT_LINE_NUM_ERR',
        p_batch_id,
        'PON_ITEM_PRICES_INTERFACE',
        fnd_global.user_id,
        SYSDATE,
        fnd_global.user_id,
        SYSDATE,
        fnd_global.login_id
      );
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  INSERT ALL
    WHEN(sel_target_price                            IS NOT NULL
    AND neg_header_record_data.number_price_decimals IS NOT NULL
    AND (LENGTH (Mod(sel_target_price,1) ) -1)        > neg_header_record_data.number_price_decimals ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_TARGET_PRICE_PREC',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN(sel_bid_start_price                         IS NOT NULL
    AND neg_header_record_data.number_price_decimals IS NOT NULL
    AND (LENGTH (Mod(sel_bid_start_price,1) ) -1)     > neg_header_record_data.number_price_decimals ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_START_PRICE_PREC',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN(sel_current_price                           IS NOT NULL
    AND neg_header_record_data.number_price_decimals IS NOT NULL
    AND (LENGTH (Mod(sel_current_price,1) ) -1)       > neg_header_record_data.number_price_decimals ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_CURR_PRICE_PREC',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN(sel_po_min_amt                              IS NOT NULL
    AND neg_header_record_data.number_price_decimals IS NOT NULL
    AND (LENGTH (Mod(sel_po_min_amt,1) ) -1)          > neg_header_record_data.number_price_decimals ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_MIN_REL_PREC',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN(sel_po_agmt_amt                             IS NOT NULL
    AND neg_header_record_data.number_price_decimals IS NOT NULL
    AND (LENGTH (Mod(sel_po_agmt_amt,1) ) -1)         > neg_header_record_data.number_price_decimals ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_AGMT_AMT_PREC',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN(sel_adv_amt                                 IS NOT NULL
    AND neg_header_record_data.number_price_decimals IS NOT NULL
    AND (LENGTH (Mod(sel_adv_amt,1) ) -1)             > neg_header_record_data.number_price_decimals ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_ADV_AMT_PREC',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN(sel_recoup_per                              IS NOT NULL
    AND neg_header_record_data.number_price_decimals IS NOT NULL
    AND (LENGTH (Mod(sel_recoup_per,1) ) -1)          > neg_header_record_data.number_price_decimals ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_RECOUP_PREC',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN(sel_progpmt_per                             IS NOT NULL
    AND neg_header_record_data.number_price_decimals IS NOT NULL
    AND (LENGTH (Mod(sel_progpmt_per,1) ) -1)         > neg_header_record_data.number_price_decimals ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_PROG_PYMT_PREC',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN(sel_ret_per                                 IS NOT NULL
    AND neg_header_record_data.number_price_decimals IS NOT NULL
    AND (LENGTH (Mod(sel_ret_per,1) ) -1)             > neg_header_record_data.number_price_decimals ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_RET_RATE_PREC',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN(sel_max_ret                                 IS NOT NULL
    AND neg_header_record_data.number_price_decimals IS NOT NULL
    AND (LENGTH (Mod(sel_max_ret,1) ) -1)             > neg_header_record_data.number_price_decimals ) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_MAX_RET_PREC',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
  SELECT target_price sel_target_price,
    bid_start_price sel_bid_start_price,
    current_price sel_current_price,
    po_min_rel_amount sel_po_min_amt,
    po_agreed_amount sel_po_agmt_amt,
    advance_amount sel_adv_amt,
    recoupment_rate_percent sel_recoup_per,
    progress_pymt_rate_percent sel_progpmt_per,
    retainage_rate_percent sel_ret_per,
    max_retainage_amount sel_max_ret
  FROM pon_item_prices_interface
  WHERE batch_id = p_batch_id;
  SELECT DOCTYPE_ID
  INTO rfi_doctype_id
  FROM pon_auc_doctypes
  WHERE INTERNAL_NAME='REQUEST_FOR_INFORMATION';
  -- bug 16898220
  INSERT ALL
    WHEN (NVL(neg_header_record_data.LINE_ATTRIBUTE_ENABLED_FLAG,'N') = 'N'
    AND EXISTS
      (SELECT 1
      FROM pon_auc_attributes_interface
      WHERE batch_id         = p_batch_id
      AND interface_line_id <> -1
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_ATTRIBUTE_NA',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN (NVL(neg_header_record_data.LINE_ATTRIBUTE_ENABLED_FLAG,'N') = 'N'
    OR NVL(neg_header_record_data.bid_ranking,'PRICE_ONLY')          <> 'MULTI_ATTRIBUTE_SCORING'
    AND EXISTS
      (SELECT 1
      FROM pon_attribute_scores_interface
      WHERE batch_id         = p_batch_id
      AND interface_line_id <> -1
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_ATTRIBUTE_SCORE_NA',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN ((NVL(neg_header_record_data.global_agreement_flag,'N') = 'N'
    AND rfi_doctype_id                                          <>neg_header_record_data.doctype_id)
    AND EXISTS
      (SELECT 1 FROM pon_auc_price_differ_int WHERE batch_id = p_batch_id
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_PRICE_DIFF_NA',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN ((NVL(neg_header_record_data.pf_type_allowed,'NONE')     = 'NONE'
    OR NVL(neg_header_record_data.price_element_enabled_flag,'N') = 'N')
    AND EXISTS
      (SELECT 1 FROM pon_auc_price_elements_int WHERE batch_id = p_batch_id
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_COST_FACTOR_NA',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
    WHEN ((NVL(neg_header_record_data.price_tiers_indicator,'NONE') = 'NONE'
    OR rfi_doctype_id                                               =neg_header_record_data.doctype_id)
    AND EXISTS
      (SELECT 1 FROM pon_auc_price_breaks_interface WHERE batch_id = p_batch_id
      )) THEN
  INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE ,
      ERROR_MESSAGE_NAME,
      BATCH_ID ,
      ENTITY_TYPE ,
      AUCTION_HEADER_ID ,
      CREATED_BY ,
      CREATION_DATE ,
      LAST_UPDATED_BY ,
      LAST_UPDATE_DATE ,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      g_interface_type,
      'PON_PRICE_BREAK_NA',
      p_batch_id,
      'PON_ITEM_PRICES_INTERFACE',
      NULL,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.login_id
    )
  SELECT 1 FROM dual;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END line_sanity_validation;
PROCEDURE validate_attribute_data(
    p_batch_id IN NUMBER)
AS
  l_nls_date_format VARCHAR2(20);
  l_date            DATE;
  l_num             NUMBER;
  l_module          VARCHAR2(250) := g_module_prefix || '.validate_attribute_data';
BEGIN
  SELECT VALUE
  INTO l_nls_date_format
  FROM V$NLS_PARAMETERS
  WHERE PARAMETER = 'NLS_DATE_FORMAT';
  FOR att_rec IN
  (SELECT datatype,
    Value,
    interface_line_id,
    sequence_number
  FROM pon_auc_attributes_interface
  WHERE batch_id        = p_batch_id
  AND interface_line_id > 0
  )
  LOOP
    -- Check whether datatype and value match
    IF (att_rec.datatype = 'DAT') THEN
      BEGIN
        l_date := To_Date(att_rec.Value,l_nls_date_format);
      EXCEPTION
      WHEN OTHERS THEN
        INSERT
        INTO pon_interface_errors
          (
            BATCH_ID,
            INTERFACE_LINE_ID,
            TABLE_NAME,
            COLUMN_NAME,
            ERROR_MESSAGE_NAME,
            ERROR_VALUE
          )
          VALUES
          (
            p_batch_id,
            att_rec.interface_line_id,
            'PON_AUC_ATTRIBUTES_INTERFACE',
            'VALUE',
            'PON_IMPORT_DATE_INV',
            att_rec.sequence_number
          );
      END;
    ELSIF ( att_rec.datatype = 'NUM' ) THEN
      BEGIN
        l_num := To_Number(att_rec.Value);
      EXCEPTION
      WHEN OTHERS THEN
        INSERT
        INTO pon_interface_errors
          (
            BATCH_ID,
            INTERFACE_LINE_ID,
            TABLE_NAME,
            COLUMN_NAME,
            ERROR_MESSAGE_NAME,
            ERROR_VALUE
          )
          VALUES
          (
            p_batch_id,
            att_rec.interface_line_id,
            'PON_AUC_ATTRIBUTES_INTERFACE',
            'VALUE',
            'PON_AUCTS_ATTR_INVALID_TARGET',
            att_rec.sequence_number
          );
      END;
    END IF;
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END validate_attribute_data;
-- bug 16852025
PROCEDURE validate_costfactor_data
  (
    p_batch_id IN NUMBER
  )
AS
  l_module VARCHAR2
  (
    250
  )
  := g_module_prefix || '.validate_costfactor_data';
BEGIN
  INSERT ALL
    WHEN ( EXISTS
      (SELECT 1
      FROM PON_AUC_PRICE_ELEMENTS_INT
      WHERE batch_id        = p_batch_id
      AND interface_line_id = sel_interface_line_id
      AND sequence_number   = sel_sequence_number
      GROUP BY sequence_number
      HAVING(COUNT(sequence_number) > 1 )
      ) ) THEN
  INTO pon_interface_errors
    (
      BATCH_ID,
      INTERFACE_LINE_ID,
      TABLE_NAME,
      COLUMN_NAME,
      ERROR_MESSAGE_NAME,
      ERROR_VALUE
    )
    VALUES
    (
      sel_batch_id,
      sel_interface_line_id,
      'PON_AUC_PRICE_ELEMENTS_INT',
      'SEQUENCE_NUMBER',
      'PON_PF_SEQ_NUM_DUP',
      sel_sequence_number
    )
    WHEN (neg_header_record_data.pf_type_allowed='BUYER'
    AND sel_pf_type                             ='SUPPLIER') THEN
  INTO pon_interface_errors
    (
      BATCH_ID,
      INTERFACE_LINE_ID,
      TABLE_NAME,
      COLUMN_NAME,
      ERROR_MESSAGE_NAME,
      ERROR_VALUE
    )
    VALUES
    (
      sel_batch_id,
      sel_interface_line_id,
      'PON_AUC_PRICE_ELEMENTS_INT',
      'PF_TYPE',
      'PON_SUPPLIER_PF_INV',
      sel_pf_type
    )
    WHEN (neg_header_record_data.pf_type_allowed='SUPPLIER'
    AND sel_pf_type                             ='BUYER') THEN
  INTO pon_interface_errors
    (
      BATCH_ID,
      INTERFACE_LINE_ID,
      TABLE_NAME,
      COLUMN_NAME,
      ERROR_MESSAGE_NAME,
      ERROR_VALUE
    )
    VALUES
    (
      sel_batch_id,
      sel_interface_line_id,
      'PON_AUC_PRICE_ELEMENTS_INT',
      'PF_TYPE',
      'PON_BUYER_PF_INV',
      sel_pf_type
    )
    WHEN (sel_pf_type='BUYER'
    AND sel_value   IS NOT NULL ) THEN
  INTO pon_interface_errors
    (
      BATCH_ID,
      INTERFACE_LINE_ID,
      TABLE_NAME,
      COLUMN_NAME,
      ERROR_MESSAGE_NAME,
      ERROR_VALUE
    )
    VALUES
    (
      sel_batch_id,
      sel_interface_line_id,
      'PON_AUC_PRICE_ELEMENTS_INT',
      'VALUE',
      'PON_PF_BUYER_VALUE_INV',
      sel_value
    )
    WHEN (sel_pf_type                    ='BUYER'
    AND NVL(sel_display_target_flag,'N') = 'Y' ) THEN
  INTO pon_interface_errors
    (
      BATCH_ID,
      INTERFACE_LINE_ID,
      TABLE_NAME,
      COLUMN_NAME,
      ERROR_MESSAGE_NAME,
      ERROR_VALUE
    )
    VALUES
    (
      sel_batch_id,
      sel_interface_line_id,
      'PON_AUC_PRICE_ELEMENTS_INT',
      'DISPLAY_TARGET_FLAG',
      'PON_PF_DISPTARGET_INV',
      sel_pf_type
    )
    WHEN (sel_pf_type                    ='SUPPLIER'
    AND NVL(sel_disptosupplier_flag,'Y') = 'N' ) THEN
  INTO pon_interface_errors
    (
      BATCH_ID,
      INTERFACE_LINE_ID,
      TABLE_NAME,
      COLUMN_NAME,
      ERROR_MESSAGE_NAME,
      ERROR_VALUE
    )
    VALUES
    (
      sel_batch_id,
      sel_interface_line_id,
      'PON_AUC_PRICE_ELEMENTS_INT',
      'DISPLAY_TO_SUPPLIERS_FLAG',
      'PON_PF_DISPTOSUPP_INV',
      sel_pf_type
    )
  SELECT batch_id sel_batch_id,
    interface_line_id sel_interface_line_id,
    pf_type sel_pf_type,
    Value sel_value,
    display_target_flag sel_display_target_flag,
    display_to_suppliers_flag sel_disptosupplier_flag,
    sequence_number sel_sequence_number
  FROM PON_AUC_PRICE_ELEMENTS_INT
  WHERE batch_id = p_batch_Id;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END validate_costfactor_data;
END PON_OPEN_INTERFACE_PVT;

/
