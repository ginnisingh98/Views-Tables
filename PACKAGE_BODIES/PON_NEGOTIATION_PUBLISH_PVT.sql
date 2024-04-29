--------------------------------------------------------
--  DDL for Package Body PON_NEGOTIATION_PUBLISH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_NEGOTIATION_PUBLISH_PVT" AS
/* $Header: PONNEGPB.pls 120.46.12010000.2 2012/08/06 13:03:43 svalampa ship $ */

g_module_prefix        CONSTANT VARCHAR2(50) := 'pon.plsql.PON_NEGOTIATION_PUBLISH_PVT.';

TYPE DOCUMENT_TYPE_NAME IS TABLE OF PON_AUC_DOCTYPES.DOCTYPE_GROUP_NAME%TYPE INDEX BY BINARY_INTEGER;
TYPE DOCUMENT_TYPE_REQUIRED_RULE IS TABLE OF PON_AUC_DOCTYPE_RULES.REQUIRED_FLAG%TYPE INDEX BY PON_AUC_BIZRULES.NAME%TYPE;
TYPE DOCUMENT_TYPE_VALIDITY_RULE IS TABLE OF PON_AUC_DOCTYPE_RULES.VALIDITY_FLAG%TYPE INDEX BY PON_AUC_BIZRULES.NAME%TYPE;

g_document_type_required_rule DOCUMENT_TYPE_REQUIRED_RULE;
g_document_type_validity_rule DOCUMENT_TYPE_VALIDITY_RULE;
g_document_type_names DOCUMENT_TYPE_NAME;

g_null_int CONSTANT NUMBER := -9999;
g_unlimited_int CONSTANT NUMBER := 10000;
g_invalid_string CONSTANT VARCHAR2(10) := ')(*%^';
g_item_price_type_id CONSTANT NUMBER := -10;
g_precision_any CONSTANT NUMBER := 10000;
g_temp_labor CONSTANT VARCHAR2(20) := 'TEMP LABOR';
g_fixed_price CONSTANT VARCHAR2(20) :='FIXED PRICE';
g_fixed_amount CONSTANT VARCHAR2(20) := 'FIXED_AMOUNT';
g_per_unit CONSTANT VARCHAR2(10) := 'PER_UNIT';
g_empty_price_type CONSTANT VARCHAR2(20) := 'EMPTY PRICE TYPE';
g_none CONSTANT VARCHAR2(20) := 'NONE';
g_amount CONSTANT VARCHAR2(20) := 'AMOUNT';
g_interface_type CONSTANT VARCHAR2(20) := 'PUBLISHNEG';
g_auction_item_type CONSTANT VARCHAR2(20) := 'AUCTION_ITEM';
g_auction_attrs_type CONSTANT VARCHAR2(20) := 'AUCTION_ATTRS';
g_auction_pfs_type CONSTANT VARCHAR2(20) := 'AUCTION_PFS';
g_auction_pbs_type CONSTANT VARCHAR2(20) := 'AUCTION_PBS';
g_auction_pds_type CONSTANT VARCHAR2(20) := 'AUCTION_PDS';
g_rfq_pymts_type CONSTANT VARCHAR2(20) := 'AUCTION_PYMTS';
g_program_type_neg_approve CONSTANT VARCHAR2(20) := 'NEG_APPROVAL';
g_program_type_neg_publish CONSTANT VARCHAR2(20) := 'NEG_PUBLISH';
g_auction_pts_type CONSTANT VARCHAR2(20) := 'AUCTION_PTS';


FUNCTION boolean_to_string (
  p_boolean IN BOOLEAN
) RETURN STRING IS
BEGIN

  IF (p_boolean) THEN
    RETURN 'TRUE';
  ELSE
    RETURN 'FALSE';
  END IF;
END boolean_to_string;

FUNCTION IS_PROJECT_SPONSORED (
  p_project_id IN NUMBER
) RETURN VARCHAR2 IS
BEGIN

  IF p_project_id IS NOT NULL AND
     GMS_TRANSACTIONS_PUB.IS_SPONSORED_PROJECT(p_project_id) THEN
    RETURN 'Y';
  ELSE
     RETURN 'N';
  END IF;
END IS_PROJECT_SPONSORED;


--Start Validation procedures

/*
 * Line validations: The following validations involve only the item_prices_all table and not the
 * po line types table
 * 1. The group type for a line should be 'GROUP_LINE' or 'LOT_LINE' if the parent_line_number is populated.
 *    The group type for a line should be 'GROUP' or 'LOT' if the parent_line_number is not populated
 * 2. The item description should not be an empty string if the doc type rules do not allow
 * 3. The line_type_id should not be null
 * 4. The category should not be empty
 * 5. Target price should be positive
 * 6. Bid start price should be positive
 * 7. Current_price should be positive
 * 8. Target price should be less than bid start price
 * 9. If display target price is set then target prices should be entered
 * 10. Po minimum release amount should be positive
 * 11. When display unit target prices is set then unit target price should be entered
 * 12. Target price  precision should be less than the auction currencyprecision
 * 13. Bid start price precision should be less than the auction currency precision
 * 14. Current price precision should be less than the auction currency precision
 * 15. The precision of po minimum release amount should be less than the fnd currency precision
 * 16. Need_by date should be after start date
 * 17. Need by date should be after close bidding date. If no close bidding date then after sysdate
 * 18. Need by start date should be after close bidding date. If no close bidding date then after sysdate
 * 19. For lines with "planned" inventory items in a SPO negotiation either need-by from or need-by to date must be entered
 * 20. If this is a global agreement then cummulative price breaks are not allowed.
 * 21. If the user has selected to enter price breaks then there should be atleast one price break
 *     If the price breaks are non negotiable (which also means the price break type is 'REQUIRED')
 *     and the size is zero, the user must enter a price break.
 * 22. If the user has selected to enter price differentials then there should be atleast one price differential.
 * 23. if there are no price differentials and price differentails type is not NONE just give an error.
 * 24. Every LOT or GROUP should have atleast one line inside it.
 * 25. Unit Price should be greater than zero
 * 26. There should be atleast one supplier price factor if the unit price is entered
 * 27. The total weight of all attributes in an MAS auction should be 100
 * 28. If quantity is entered then it should be positive
 * 29. The precision of po agreed amount should be less than the auction currency PRECISION
 * 30. Ship to location should not be NULL in case of RFI
 * 31. In a private auction there should be no line without any invitees
 */

PROCEDURE VALIDATE_PROJECTS_DETAILS (
  p_project_id         IN NUMBER,
  p_task_id            IN NUMBER,
  p_expenditure_date   IN DATE,
  p_expenditure_type   IN VARCHAR2,
  p_expenditure_org    IN NUMBER,
  p_person_id          IN NUMBER,
  p_auction_header_id  IN NUMBER,
  p_line_number        IN NUMBER,
  p_document_disp_line_number    IN VARCHAR2,
  p_payment_id         IN NUMBER,
  p_interface_line_id  IN NUMBER,
  p_payment_display_number     IN NUMBER,
  p_batch_id           IN NUMBER,
  p_table_name         IN VARCHAR2,
  p_interface_type     IN VARCHAR2,
  p_entity_type        IN VARCHAR2,
  p_called_from        IN VARCHAR2
) IS
l_module  CONSTANT VARCHAR2(32) := 'VALIDATE_PROJECTS_DETAILS';
l_progress         VARCHAR2(200);
l_msg_application  VARCHAR2(50);
l_msg_type         VARCHAR2(1);
l_msg_token1       VARCHAR2(1000);
l_msg_token2       VARCHAR2(1000);
l_msg_token3       VARCHAR2(1000);
l_msg_data         VARCHAR2(1000);
l_msg_count        NUMBER;
l_billable_flag    VARCHAR2(1);
l_error_message_name      VARCHAR2(30);
l_token1_name      VARCHAR2(10);
l_token1_value      VARCHAR2(22);
l_token2_name      VARCHAR2(10);
l_token2_value      VARCHAR2(22);
l_token3_name      VARCHAR2(10);
l_token3_value      VARCHAR2(22);

BEGIN

  IF p_called_from = 'LINES' THEN

    l_error_message_name := 'PON_PATC_VALIDATION_L';
    l_token2_name := 'LINENUM';
    l_token2_value := p_document_disp_line_number;
    l_token3_name := null;
    l_token3_value := null;
  ELSIF p_called_from = 'PAYMENTS' THEN

    l_error_message_name := 'PON_PATC_VALIDATION_P';
    l_token2_name := 'LINENUM';
    l_token2_value := p_document_disp_line_number;
    l_token3_name := 'PAYITEMNUM';
    l_token3_value := p_payment_display_number;
  ELSE --p_called_from = PAYMENTS_SP, LINES_SP
    l_error_message_name := 'PON_PATC_VALIDATION_G';
    l_token2_name := null;
    l_token2_value := null;
    l_token3_name := null;
    l_token3_value := null;
  END IF;

    PA_TRANSACTIONS_PUB.validate_transaction(
      X_PROJECT_ID         => p_project_id,
      X_TASK_ID            => p_task_id,
      X_EI_DATE            => p_expenditure_date,
      X_EXPENDITURE_TYPE   => p_expenditure_type,
      X_NON_LABOR_RESOURCE => null,
      X_PERSON_ID          => null,
      x_incurred_by_org_id => p_expenditure_org,
      X_CALLING_MODULE     => 'PO',
      X_MSG_APPLICATION    => l_msg_application,
      X_MSG_TYPE           => l_msg_type,
      X_MSG_TOKEN1         => l_msg_token1,
      x_msg_data           => l_msg_data,
      X_MSG_TOKEN2         => l_msg_token2,
      X_MSG_TOKEN3         => l_msg_token3,
      X_MSG_COUNT          => l_msg_count,
      X_BILLABLE_FLAG      => l_billable_flag);

    IF l_msg_data IS NOT NULL AND l_msg_type = 'E' THEN
      INSERT INTO pon_interface_errors
      (
         error_message_name,
         token1_name,
         token1_value,
         token2_name,
         token2_value,
         token3_name,
         token3_value,
         error_value_datatype,
         interface_type,
         table_name,
         batch_id,
         entity_type,
         auction_header_id,
         line_number,
         payment_id,
         interface_line_id,
         expiration_date,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login
      )
       VALUES
      (
         l_error_message_name,
         'PROJMSG',
         fnd_message.get_string(l_msg_application, l_msg_data),
         l_token2_name,
         l_token2_value,
         l_token3_name,
         l_token3_value,
         'TXT',
         p_interface_type,
         p_table_name,
         p_batch_id,
         p_entity_type, --DECODE(p_called_from,'LINES',g_auction_item_type,'PAYMENTS',g_rfq_pymts_type),
         p_auction_header_id,
         p_line_number,
         p_payment_id,
         p_interface_line_id,
         SYSDATE+7,
         FND_GLOBAL.user_id,
         SYSDATE,
         FND_GLOBAL.user_id,
         SYSDATE,
         FND_GLOBAL.login_id
      );
	END IF;
EXCEPTION
    WHEN OTHERS THEN

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module  => g_module_prefix || 'VALIDATE_PROJECTS_DETAILS',
        message => 'Exception occured validate_projects_details'
            || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200));
    END IF;
END VALIDATE_PROJECTS_DETAILS;

PROCEDURE val_item_prices_all (
  p_auction_header_id IN NUMBER,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER,
  p_precision IN NUMBER,
  p_fnd_precision IN NUMBER,
  p_close_bidding_date IN DATE,
  p_contract_type IN VARCHAR2,
  p_global_agreement_flag IN VARCHAR2,
  p_bid_ranking IN VARCHAR2,
  p_doctype_id IN NUMBER,
  p_invitees_count IN NUMBER,
  p_bid_list_type IN VARCHAR2
) IS

l_temp NUMBER;
l_temp_fnd NUMBER;
l_price_tiers_indicator PON_AUCTION_HEADERS_ALL.PRICE_TIERS_INDICATOR%TYPE;

BEGIN

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'val_item_prices_all',
      message  => 'Entering PON_NEGOTIATION_HELPER_PVT.val_item_prices_all'
                  || ', p_auction_header_id = ' || p_auction_header_id
                  || ', p_expiration_date = ' || p_expiration_date
                  || ', p_request_id = ' || p_request_id
                  || ', p_user_id = ' || p_user_id
                  || ', p_login_id = ' || p_login_id
                  || ', p_batch_id = ' || p_batch_id);
  END IF; --}

  IF (p_precision <> g_precision_any) THEN
    l_temp := power (10, p_precision);
  ELSE
    l_temp := 0;
  END IF;

  Select price_tiers_indicator
  into l_price_tiers_indicator
  from pon_auction_headers_all
  where auction_header_id = p_auction_header_id ;

  l_temp_fnd := power (10, p_fnd_precision);
  	--Splited 1 -  fix bug 4908493
  INSERT ALL  --bugfix

  -- The group type for a line should be 'GROUP_LINE' or 'LOT_LINE' if the parent_line_number is populated
  -- The group type for a line should be 'GROUP' or 'LOT' if the parent_line_number is not populated

  WHEN
  (
    sel_group_type IS NULL OR
    (sel_group_type IN ('GROUP_LINE', 'LOT_LINE') AND sel_parent_line_number IS NULL) OR
    (sel_group_type IN ('GROUP', 'LOT') AND sel_parent_line_number IS NOT NULL)
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_INVALID_GROUP_TYPE', --ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id
  )

  -- The item description should not be an empty string if the doc type rules do not allow
  WHEN
  (
    g_document_type_required_rule('ITEM_DESCRIPTION') = 'Y' AND
    g_document_type_validity_rule ('ITEM_DESCRIPTION') = 'Y' AND
    (sel_item_description IS NULL OR trim (sel_item_description) = '')
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_ITEMDESC_REQUIRED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate,
    p_login_id
  )
  -- THE LINE_TYPE_ID SHOULD NOT BE NULL

  WHEN
  (
    g_document_type_required_rule ('LINE_TYPE') = 'Y' AND
    g_document_type_validity_rule ('LINE_TYPE') = 'Y' AND
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_line_type_id IS NULL
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_LINETYPE_REQUIRED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id
  )

  -- The category should not be empty

  WHEN
  (
    (sel_category_name IS NULL OR TRIM (sel_category_name) = '' OR sel_category_id IS NULL) AND
    NVL (sel_group_type, g_invalid_string) <> 'GROUP'
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_CAT_REQUIRED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id
  )

  -- Adding this check for the bug 14460183
  -- If The category is not null check whether the category is valid or not

  WHEN
  (
    sel_category_name IS NOT NULL
    AND sel_category_id IS NOT NULL
    AND NOT EXISTS (SELECT  'X'
                FROM MTL_CATEGORIES_KFV MCK,
                MTL_CATEGORY_SETS MCS,
                MTL_DEFAULT_CATEGORY_SETS MDCS,
                MTL_CATEGORIES MC
                WHERE MCK.ENABLED_FLAG = 'Y'
                AND SYSDATE BETWEEN NVL(MCK.START_DATE_ACTIVE, SYSDATE) AND
                NVL(MCK.END_DATE_ACTIVE, SYSDATE) AND
                MCS.CATEGORY_SET_ID=MDCS.CATEGORY_SET_ID AND
                MDCS.FUNCTIONAL_AREA_ID=2 AND
                MCK.STRUCTURE_ID=MCS.STRUCTURE_ID AND
                NVL(MCK.DISABLE_DATE, SYSDATE + 1) > SYSDATE AND
                (MCS.VALIDATE_FLAG='Y' AND MCK.CATEGORY_ID IN
                    (SELECT MCSV.CATEGORY_ID
                      FROM MTL_CATEGORY_SET_VALID_CATS MCSV
                      WHERE  MCSV.CATEGORY_SET_ID=MCS.CATEGORY_SET_ID)
                  OR MCS.VALIDATE_FLAG <> 'Y')
                AND MCK.CATEGORY_ID = MC.CATEGORY_ID
              AND MCK.CATEGORY_ID = sel_category_id )
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_CAT_INACTIVE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id
  )

  -- Target price should be positive

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_target_price IS NOT NULL AND
    sel_target_price <= 0
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )

  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_TARGETPRICE_BE_POSIT', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id
  )

  -- BID START PRICE SHOULD BE POSITIVE

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_bid_start_price IS NOT NULL AND
    sel_bid_start_price <= 0
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )

  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_STARTPRICE_BE_POSIT', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id
  )

  -- CURRENT_PRICE SHOULD BE POSITIVE

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_current_price IS NOT NULL AND
    sel_current_price  <= 0
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )

  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_CURRENTPRICE_BE_POS', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id
  )

  -- TARGET PRICE SHOULD BE LESS THAN BID START PRICE

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_target_price >= sel_bid_start_price
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )

  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_TARGET_LOWER_START', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id
  )

  -- IF DISPLAY TARGET PRICE IS SET THEN TARGET PRICES SHOULD BE ENTERED

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_target_price IS NULL AND
    sel_display_target_price_flag = 'Y'
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_NUM_TARGETPRICE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- PO MINIMUM RELEASE AMOUNT SHOULD BE POSITIVE

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_po_min_rel_amount IS NOT NULL AND
    sel_po_min_rel_amount <> g_null_int AND
    sel_po_min_rel_amount < 0
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_MINRELAMT_BE_POSITIV', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- WHEN DISPLAY UNIT TARGET PRICES IS SET THEN UNIT TARGET PRICE SHOULD BE ENTERED

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_unit_target_price IS NULL AND
    sel_unit_display_target_flag = 'Y'
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )

  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_UNIT_SHOW_TARGET', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- TARGET PRICE  PRECISION SHOULD BE LESS THAN THE AUCTION CURRENCYPRECISION

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_target_price IS NOT NULL AND
    ABS (sel_target_price * l_temp - TRUNC (sel_target_price * l_temp)) > 0
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_TARGETPRICE_PRECIS', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- BID START PRICE PRECISION SHOULD BE LESS THAN THE AUCTION CURRENCY PRECISION

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_bid_start_price IS NOT NULL AND
    ABS (sel_bid_start_price * l_temp - TRUNC (sel_bid_start_price * l_temp)) > 0
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_STARTPRICE_PRECISION', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- CURRENT PRICE PRECISION SHOULD BE LESS THAN THE AUCTION CURRENCY PRECISION

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_current_price IS NOT NULL AND
    ABS (sel_current_price * l_temp - TRUNC (sel_current_price * l_temp)) > 0
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_CURRENTPRICE_PRECIS', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- THE PRECISION OF PO MINIMUM RELEASE AMOUNT SHOULD BE LESS THAN THE FND CURRENCY
  -- PRECISION

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_po_min_rel_amount IS NOT NULL AND
    sel_po_min_rel_amount <> g_null_int AND
    ABS (sel_po_min_rel_amount * l_temp_fnd - TRUNC (sel_po_min_rel_amount * l_temp_fnd)) > 0
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE,
    ERROR_MESSAGE_NAME,
    REQUEST_ID,
    BATCH_ID,
    ENTITY_TYPE,
    AUCTION_HEADER_ID,
    LINE_NUMBER,
    EXPIRATION_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  )

  VALUES
  (
     g_interface_type, --INTERFACE_TYPE
     'PON_AUCTS_TOO_MANY_DIGITS_A', -- ERROR_MESSAGE_NAME
     p_request_id, -- REQUEST_ID
     p_batch_id, -- BATCH_ID
     g_auction_item_type, -- ENTITY_TYPE
     p_auction_header_id, -- AUCTION_HEADER_ID
     sel_line_number, -- LINE_NUMBER
     p_expiration_date, -- EXPIRATION_DATE
     p_user_id, -- CREATED_BY
     sysdate, -- CREATION_DATE
     p_user_id, -- LAST_UPDATED_BY
     sysdate, -- LAST_UPDATE_DATE
     p_login_id -- LAST_UPDATE_LOGIN
  )

  --  need_by date should be after start date

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_need_by_date < sel_need_by_start_date
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )

  VALUES
   (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_NEEDBY_BEFORE_FROM', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
   )

  -- NEED BY DATE SHOULD BE AFTER CLOSE BIDDING DATE
  -- IF NO CLOSE BIDDING DATE THEN AFTER SYSDATE

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_need_by_date IS NOT NULL AND
    sel_need_by_date < nvl (p_close_bidding_date, SYSDATE)
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )

  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    NVL2 (p_close_bidding_date, 'PON_AUC_NEEDBY_TO_BEFORE_CLOSE',
       'PON_AUC_NEEDBY_TO_BEFORE_TODAY'), -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

   SELECT
    LINE_NUMBER sel_line_number,
    DOCUMENT_DISP_LINE_NUMBER sel_document_disp_line_number,
    GROUP_TYPE sel_group_type,
    PARENT_LINE_NUMBER sel_parent_line_number,
    ITEM_DESCRIPTION sel_item_description,
    LINE_TYPE_ID sel_line_type_id,
    CATEGORY_NAME sel_category_name,
    CATEGORY_ID sel_category_id,
    TARGET_PRICE sel_target_price,
    PO_MIN_REL_AMOUNT sel_po_min_rel_amount,
    CURRENT_PRICE sel_current_price,
    BID_START_PRICE sel_bid_start_price,
    UNIT_DISPLAY_TARGET_FLAG sel_unit_display_target_flag,
    UNIT_TARGET_PRICE sel_unit_target_price,
    DISPLAY_TARGET_PRICE_FLAG sel_display_target_price_flag,
    NEED_BY_START_DATE sel_need_by_start_date,
    NEED_BY_DATE sel_need_by_date
  FROM
    PON_AUCTION_ITEM_PRICES_ALL
  WHERE
    AUCTION_HEADER_ID = p_auction_header_id;



	--Split2 - fix bug 4908493
	INSERT ALL --bugfix


  -- NEED BY START DATE SHOULD BE AFTER CLOSE BIDDING DATE
  -- IF NO CLOSE BIDDING DATE THEN AFTER SYSDATE

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_need_by_start_date IS NOT NULL AND
    sel_need_by_start_date < nvl (p_close_bidding_date, SYSDATE) AND
    p_contract_type = 'STANDARD'
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )

  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    NVL2 (p_close_bidding_date, 'PON_AUC_NEEDBY_FROM_BEF_CLOSE', 'PON_AUC_NEEDBY_FROM_BEF_TODAY'), -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- for lines with "planned" inventory items in a SPO negotiation
  -- either need-by from or need-by to date must be entered

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_need_by_date IS NULL AND
    sel_need_by_start_date IS NULL AND
    p_contract_type = 'STANDARD' AND
    EXISTS (
      SELECT
      'X'
      FROM
      MTL_SYSTEM_ITEMS_KFV MSI,
      FINANCIALS_SYSTEM_PARAMS_ALL FSP
      WHERE
      NVL(FSP.ORG_ID, -9999) = NVL(sel_org_id,-9999) AND
      MSI.ORGANIZATION_ID = FSP.INVENTORY_ORGANIZATION_ID AND
      MSI.INVENTORY_ITEM_ID =  sel_item_id AND
      (MSI.INVENTORY_PLANNING_CODE IN (1, 2) OR MSI.MRP_PLANNING_CODE IN
       (3, 4, 7, 8, 9))
     )
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_NEED_BY_DATE_REQUIRED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- if this is a global agreement then cummulative price breaks are not
  -- allowed

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_price_break_type = 'CUMULATIVE' AND
    p_global_agreement_flag = 'Y' AND
    l_price_tiers_indicator = 'PRICE_BREAKS'
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_BAD_PBTYPE_GLOBAL', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- If the user has selected to enter price breaks
  -- then there should be atleast one price break
  -- If the price breaks are non negotiable (which also means the price
  -- break type is 'REQUIRED') and the size is zero, the user must
  -- enter a price break.
  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_price_break_neg_flag = 'N' AND
    NVL (sel_price_break_type, g_invalid_string) <> g_none AND
    NOT EXISTS (
      SELECT 1
      FROM
        PON_AUCTION_SHIPMENTS_ALL PASA
      WHERE
        PASA.AUCTION_HEADER_ID = p_auction_header_id AND
        PASA.LINE_NUMBER = sel_line_number
      )
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )

  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_PRICEBREAK_MUST_BE_ENTERED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- If the user has selected to enter price differentials then
  -- there should be atleast one price differential

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_differential_response_type IS NOT NULL AND
    NOT EXISTS (
      SELECT 1
      FROM
      PON_PRICE_DIFFERENTIALS PPD
      WHERE
      PPD.AUCTION_HEADER_ID = p_auction_header_id AND
      PPD.LINE_NUMBER = sel_line_number AND
      PPD.SHIPMENT_NUMBER = -1
    )
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE,TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_PRICEDIFF_MUST_BE_ENTERED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id-- LAST_UPDATE_LOGIN
  )

  -- if there are no price differentials and price differentails type
  -- is not NONE just give an error
  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_differential_response_type IS NULL AND
    EXISTS (
      SELECT 1
      FROM
      PON_PRICE_DIFFERENTIALS PPD
      WHERE
      PPD.AUCTION_HEADER_ID = p_auction_header_id AND
      PPD.LINE_NUMBER = sel_line_number AND
      PPD.SHIPMENT_NUMBER = -1
    )
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE,TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
   (
    g_interface_type, --INTERFACE_TYPE
    'PON_SET_DIFF_RESPONSE_TYPE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id-- LAST_UPDATE_LOGIN
   )

  -- Every LOT or GROUP should have atleast one line inside it

  WHEN
  (
    sel_group_type IN ('LOT', 'GROUP') AND
    NOT EXISTS (
      SELECT LINE_NUMBER
      FROM PON_AUCTION_ITEM_PRICES_ALL
      WHERE
      AUCTION_HEADER_ID = p_auction_header_id AND
      PARENT_LINE_NUMBER = sel_line_number
    )
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    decode (sel_group_type, 'LOT', 'PON_LOT_NEEDS_SUBLINES', 'PON_GROUP_NEEDS_SUBLINES'), -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- Unit Price should be greater than zero

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_unit_target_price IS NOT NULL AND
    sel_unit_target_price < 0
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_UNIT_TARGET_BE_POS', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- There should be atleast one supplier price factor if the unit price is entered

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_unit_target_price IS NOT NULL AND
    NOT EXISTS (
        SELECT 1
        FROM
        PON_PRICE_ELEMENTS
        WHERE
        AUCTION_HEADER_ID = p_auction_header_id AND
        LINE_NUMBER = sel_line_number AND
        PF_TYPE='SUPPLIER'
       )
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_UNITPRICE_SUPPLIER', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- The total weight of all attributes in an MAS auction should be 100

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    p_bid_ranking = 'MULTI_ATTRIBUTE_SCORING' AND
    EXISTS(
      SELECT 1
      FROM
        PON_AUCTION_ATTRIBUTES
      WHERE
        AUCTION_HEADER_ID = p_auction_header_id
        AND LINE_NUMBER = sel_line_number
        AND (NVL (SCORING_TYPE,g_invalid_string)='RANGE' OR NVL (SCORING_TYPE,g_invalid_string)='LOV')
    ) AND
    (
      SELECT
        SUM(weight)
      FROM
        PON_AUCTION_ATTRIBUTES
      WHERE
        AUCTION_HEADER_ID = p_auction_header_id
        AND LINE_NUMBER = sel_line_number) <> 100
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_INVALID_WEIGHTS_LINE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_attrs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINE', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- If quantity is entered then it should be positive
  --bug 6193585 - check whether the quantity is less or equal to zero
  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_quantity IS NOT NULL AND
    sel_quantity <= 0
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_QUANTITY_BE_POSITIVE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- The precision of po agreed amount should be less than the auction currency PRECISION

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_po_agreed_amount IS NOT NULL AND
    ABS (sel_po_agreed_amount * l_temp - TRUNC (sel_po_agreed_amount * l_temp)) > 0
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )

  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_POAGREEDAMT_PRECIS', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- Ship to location should not be NULL for an SPO not coming from a req except in case of RFI

  WHEN
  (
    g_document_type_required_rule('SHIP_TO_LOCATION') = 'Y' AND
    g_document_type_names (p_doctype_id) <> PON_CONTERMS_UTL_PVT.SRC_REQUEST_FOR_INFORMATION AND
    p_contract_type = 'STANDARD' AND
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    nvl (sel_line_origination_code,g_invalid_string) <> 'REQUISITION' AND
    sel_ship_to_location_id IS NULL
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_SHIPTOLOC_MUST_ENTERED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- In a private auction there should be no line without any invitees

  WHEN
  (
    p_bid_list_type = 'PRIVATE_BID_LIST' AND
    (SELECT COUNT(1)
    FROM PON_PARTY_LINE_EXCLUSIONS
    WHERE
    AUCTION_HEADER_ID = p_auction_header_id AND
    sel_group_type IN ('LOT', 'GROUP', 'LINE') AND
    LINE_NUMBER = sel_line_number) = p_invitees_count
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_LINE_SANS_INVITEE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )
  SELECT
    LINE_NUMBER sel_line_number,
    DOCUMENT_DISP_LINE_NUMBER sel_document_disp_line_number,
    GROUP_TYPE sel_group_type,
    UNIT_TARGET_PRICE sel_unit_target_price,
    NEED_BY_START_DATE sel_need_by_start_date,
    NEED_BY_DATE sel_need_by_date,
    ITEM_ID sel_item_id,
    ORG_ID sel_org_id,
    PRICE_BREAK_TYPE sel_price_break_type,
    DIFFERENTIAL_RESPONSE_TYPE sel_differential_response_type,
    PRICE_BREAK_NEG_FLAG sel_price_break_neg_flag,
    QUANTITY sel_quantity,
    PO_AGREED_AMOUNT sel_po_agreed_amount,
    LINE_ORIGINATION_CODE sel_line_origination_code,
    SHIP_TO_LOCATION_ID sel_ship_to_location_id
  FROM
    PON_AUCTION_ITEM_PRICES_ALL
  WHERE
    AUCTION_HEADER_ID = p_auction_header_id;

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'val_item_prices_all',
      message  => 'Leaving PON_NEGOTIATION_HELPER_PVT.val_item_prices_all'
                  || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}

END val_item_prices_all;

/*
 * Line validations: The following validations involve the item_prices_all table and the
 * po line types table.
 * 1. Uom code should not be empty for non fixed price items
 * 2. Ship to location should not be NULL for an SPO not coming from a req except in case of RFI
 * 3. Job id should not be NULL for temp labor lines
 * 4. For temp labor based lines the po agreed amount should be a positive number
 * 5. Only global agreements and RFIs can have temp labor lines
 * 6. Unit target price precision should be less than currency precision for fixed price lines
 * 7. For non fixed price items the unit price should have precision less than the auction currency precision
 * 8. Quantity should be entered for blanket/contract for lines with fixed amount price elements and non fixed price items
 * 9. Quantity is required if the document is RFI and the line is not temp labor based
 */
PROCEDURE val_item_prices_po_lines (
  p_auction_header_id IN NUMBER,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER,
  p_doctype_id IN NUMBER,
  p_contract_type IN VARCHAR2,
  p_global_agreement_flag IN VARCHAR2,
  p_precision IN NUMBER,
  p_fnd_precision IN NUMBER
) IS

l_temp NUMBER;
l_temp_fnd NUMBER;
BEGIN

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'val_item_prices_po_lines',
      message  => 'Entering PON_NEGOTIATION_HELPER_PV.val_item_prices_po_lines'
                  || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --

  IF (p_precision <> g_precision_any) THEN
    l_temp := power (10, p_precision);
  ELSE
    l_temp := 0;
  END IF;

  l_temp_fnd := power (10, p_fnd_precision);

  INSERT ALL

  -- Uom code should not be empty for non fixed price items

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    NVL (sel_order_type_lookup_code, g_invalid_string) <> g_fixed_price AND
    NVL (sel_quantity_disabled_flag, g_invalid_string) <> 'Y' AND
    (
      sel_uom_code IS NULL OR TRIM (sel_uom_code) = ''
    )
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_UOM_REQUIRED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- Ship to location should not be NULL in case of RFI and non temp labor lines

  WHEN
  (
    sel_ship_to_location_id IS NULL AND
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    nvl (sel_line_origination_code,g_invalid_string) <> 'REQUISITION' AND
    g_document_type_required_rule('SHIP_TO_LOCATION') = 'Y' AND
    ((nvl (sel_purchase_basis,g_invalid_string) <> g_temp_labor AND
    g_document_type_names (p_doctype_id) = PON_CONTERMS_UTL_PVT.SRC_REQUEST_FOR_INFORMATION) OR
    p_contract_type = 'STANDARD')
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_SHIPTOLOC_MUST_ENTERED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id-- LAST_UPDATE_LOGIN
  )

  -- Job id should not be NULL for temp labor lines

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_job_id IS NULL AND
    sel_purchase_basis = g_temp_labor
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_JOB_REQUIRED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- For temp labor based lines the po agreed amount should be a positive number

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_po_agreed_amount IS NOT NULL AND
    sel_purchase_basis = g_temp_labor AND
    sel_po_agreed_amount <= 0
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_POAGREEDAMT_BE_POSIT', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id-- LAST_UPDATE_LOGIN
  )

  -- Only global agreements and RFIs can have temp labor lines

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_purchase_basis = g_temp_labor AND
    g_document_type_names (p_doctype_id) <> PON_CONTERMS_UTL_PVT.SRC_REQUEST_FOR_INFORMATION AND
    NVL (p_global_agreement_flag, g_invalid_string) <> 'Y'
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_NOT_GLOBAL_TEMP', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- Unit target price precision should be less than currency precision for fixed price lines

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_unit_target_price IS NOT NULL AND
    sel_order_type_lookup_code = g_fixed_price AND
    ABS (sel_unit_target_price * l_temp_fnd - TRUNC (sel_unit_target_price * l_temp_fnd)) > 0
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )

  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_UNITPRICE_CUR_PREC', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- For non fixed price items the unit price should have precision less than
  -- then auction currency precision

  WHEN
  (
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    sel_unit_target_price IS NOT NULL AND
    NVL (sel_order_type_lookup_code, g_invalid_string) <> g_fixed_price AND
    ABS (sel_unit_target_price  * l_temp - TRUNC (sel_unit_target_price * l_temp)) > 0
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )

  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_UNITPRICE_PREC', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- Quantity should be entered for blanket/contract for lines with fixed amount
  -- price elements

  WHEN
  (
    (p_contract_type = 'BLANKET' OR p_contract_type = 'CONTRACT') AND
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    NVL (sel_quantity_disabled_flag, g_invalid_string) <> 'Y' AND
    NVL (sel_order_type_lookup_code, g_invalid_string) <> g_fixed_price AND
    sel_quantity IS NULL AND
      EXISTS (
        SELECT 1
        FROM
        PON_PRICE_ELEMENTS
        WHERE
        AUCTION_HEADER_ID = p_auction_header_id AND
        LINE_NUMBER = sel_line_number AND
        PRICING_BASIS = g_fixed_amount)
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY,
    CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
    BATCH_ID
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_QUAN_FIXED_AMT', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id, -- LAST_UPDATE_LOGIN
    p_batch_id -- BATCH_ID
  )

  -- Quantity is required if the document is RFI and the line is not
  -- temp labor based

  WHEN
  (
    sel_quantity IS NULL AND
    NVL (sel_group_type, g_invalid_string) <> 'GROUP' AND
    NVL (sel_quantity_disabled_flag, g_invalid_string) <> 'Y' AND
    NVL (sel_order_type_lookup_code, g_invalid_string) <> g_fixed_price AND
    NVL (sel_purchase_basis, g_invalid_string) <> g_temp_labor AND
    g_document_type_names (p_doctype_id) = PON_CONTERMS_UTL_PVT.SRC_REQUEST_FOR_INFORMATION
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY,
    CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
    BATCH_ID
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_QUANTITY_REQUIRED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id, -- LAST_UPDATE_LOGIN
    p_batch_id -- BATCH_ID
  )

  SELECT
    PAIP.LINE_NUMBER sel_line_number,
    PAIP.DOCUMENT_DISP_LINE_NUMBER sel_document_disp_line_number,
    PAIP.GROUP_TYPE sel_group_type,
    PLTB.ORDER_TYPE_LOOKUP_CODE sel_order_type_lookup_code,
    PAIP.QUANTITY_DISABLED_FLAG sel_quantity_disabled_flag,
    PAIP.UOM_CODE sel_uom_code,
    PAIP.SHIP_TO_LOCATION_ID sel_ship_to_location_id,
    PAIP.LINE_ORIGINATION_CODE sel_line_origination_code,
    PLTB.PURCHASE_BASIS sel_purchase_basis,
    PAIP.JOB_ID sel_job_id,
    PAIP.PO_AGREED_AMOUNT sel_po_agreed_amount,
    PAIP.UNIT_TARGET_PRICE sel_unit_target_price,
    PAIP.QUANTITY sel_quantity
  FROM
    PON_AUCTION_ITEM_PRICES_ALL PAIP,
    PO_LINE_TYPES_B PLTB
  WHERE
    PAIP.AUCTION_HEADER_ID = p_auction_header_id AND
    PLTB.LINE_TYPE_ID = PAIP.LINE_TYPE_ID;

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'val_item_prices_po_lines',
      message  => 'Returning PON_NEGOTIATION_HELPER_PVT.val_item_prices_po_lines'
                  || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}
END val_item_prices_po_lines;

/*
 * In case of a multi currency auction there cannot be an amount
 * based line.
 * Need to show only one error (so ROWNUM=1) and hence cannot be merged
 * into the other validations.
 */
PROCEDURE VAL_LINE_AMOUNT_MULTI_CURR(
  p_auction_header_id IN NUMBER,
  l_allow_other_bid_currency IN VARCHAR2,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER
) IS

l_doctype_suffix VARCHAR2(10);
BEGIN
  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_LINE_AMOUNT_MULTI_CURR',
      message  => 'Entering PON_NEGOTIATION_HELPER_PVT.VAL_LINE_AMOUNT_MULTI_CURR'
                  || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}

  IF (l_allow_other_bid_currency = 'Y') THEN --{

    l_doctype_suffix := PON_LARGE_AUCTION_UTIL_PKG.GET_DOCTYPE_SUFFIX (p_auction_header_id);

    INSERT INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
      AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, CREATED_BY,
      CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
    )
    SELECT
      g_interface_type, --INTERFACE_TYPE
      'PON_AUC_AMOUNT_CURR' || l_doctype_suffix, -- ERROR_MESSAGE_NAME
      p_request_id, -- REQUEST_ID
      p_batch_id, --BATCH_ID
      g_auction_item_type, -- ENTITY_TYPE
      p_auction_header_id, -- AUCTION_HEADER_ID
      LINE_NUMBER, -- LINE_NUMBER
      p_expiration_date, -- EXPIRATION_DATE
      p_user_id, -- CREATED_BY
      sysdate, -- CREATION_DATE
      p_user_id, -- LAST_UPDATED_BY
      sysdate, -- LAST_UPDATE_DATE
      p_login_id -- LAST_UPDATE_LOGIN
    FROM
      PON_AUCTION_ITEM_PRICES_ALL PAIP,
      PO_LINE_TYPES_B PLTB
    WHERE
      AUCTION_HEADER_ID = p_auction_header_id AND
      PAIP.LINE_TYPE_ID = PLTB.LINE_TYPE_ID AND
      NVL (PAIP.GROUP_TYPE, g_invalid_string) <> 'GROUP' AND
      PLTB.ORDER_TYPE_LOOKUP_CODE = g_amount AND
      ROWNUM =1;
  END IF; --}

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_LINE_AMOUNT_MULTI_CURR',
      message  => 'Returning PON_NEGOTIATION_HELPER_PVT.VAL_LINE_AMOUNT_MULTI_CURR'
                  || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}
END VAL_LINE_AMOUNT_MULTI_CURR;

-- START_ATTRIBUTE_VALIDATIONS
/*
 * The following attribute validations are performed
 * 1. Attribute name should not be empty
 * 2. If the display target flag is set to y then the value should not be null
 * 3. ==REMOVED ER 4689885, BUG 5633348== If the attribute is only a display attribute then the display target flag should be set
 * 4. Weight should be an integer
 * 5. The weight value should be between 0 and 100 if entered
 * 6. Attribute max score should an integer
 * 7. The attrribute maximum score should be a positive number
 * 8. If full quantity bids are required then quantity (-20) cannot be scored
 * 9. For MAS auctions, if weight is greater than zero then the scoring type should not be null or NONE
 */
PROCEDURE VAL_ATTRIBUTES (
  p_auction_header_id IN NUMBER,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER,
  p_full_quantity_bid_code IN VARCHAR2,
  p_bid_ranking IN VARCHAR2
  ) IS
BEGIN
  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_ATTRIBUTES',
      message  => 'Entering procedure'
                  || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}

  INSERT ALL

  -- ATTRIBUTE NAME SHOULD NOT BE EMPTY

  WHEN
  (
    sel_attribute_name IS NULL OR
    TRIM (sel_attribute_name) = ''
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, ATTRIBUTE_NAME, EXPIRATION_DATE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_ATTRIB_NAME_M', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_attrs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_attribute_name, -- ATTRIBUTE_NAME
    p_expiration_date, -- EXPIRATION_DATE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- IF THE DISPLAY TARGET FLAG IS SET TO Y THEN THE VALUE SHOULD NOT BE NULL

  WHEN
  (
    sel_sequence_number is not null and
    sel_sequence_number > 0 and
    sel_value IS NULL AND
    sel_display_target_flag = 'Y'
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, ATTRIBUTE_NAME, EXPIRATION_DATE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_ATTR_SHOW_TARGET', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_attrs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_attribute_name, -- ATTRIBUTE_NAME
    p_expiration_date, -- EXPIRATION_DATE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  --WEIGHT SHOULD BE An integer

  WHEN
  (
    sel_weight IS NOT NULL AND
    (sel_weight - sel_trunc_weight <> 0)
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, ATTRIBUTE_NAME, EXPIRATION_DATE,
    TOKEN1_NAME, TOKEN1_VALUE, TOKEN2_NAME, TOKEN2_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_LINE_WEIGHT_INT', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_attrs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_attribute_name, -- ATTRIBUTE_NAME
    p_expiration_date, -- EXPIRATION_DATE
    'LINE', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    'ATTRIBUTE', -- TOKEN2_NAME
    sel_attribute_name, -- TOKEN2_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- THE WEIGHT VALUE SHOULD BE BETWEEN 0 AND 100 IF ENTERED

  WHEN
  (
    sel_weight is not null AND
    sel_trunc_weight NOT BETWEEN 0 AND 100
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, ATTRIBUTE_NAME, EXPIRATION_DATE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_LINE_WEIGHT_RANGE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_attrs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_attribute_name, -- ATTRIBUTE_NAME
    p_expiration_date, -- EXPIRATION_DATE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- attribute max score should an integer

  WHEN
  (
    sel_attr_max_score is not null AND
    (sel_attr_max_score - sel_trunc_attr_max_score <> 0)
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, ATTRIBUTE_NAME, EXPIRATION_DATE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_MUST_BE_A_INT_M', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_attrs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_attribute_name, -- ATTRIBUTE_NAME
    p_expiration_date, -- EXPIRATION_DATE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- THE ATTRRIBUTE MAXIMUM SCORE SHOULD BE A POSITIVE NUMBER

  WHEN
  (
    sel_attr_max_score is not null AND
    (sel_trunc_attr_max_score < 0)
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, ATTRIBUTE_NAME, EXPIRATION_DATE, CREATED_BY,
    CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_INVALID_MAXSCORE_RANGE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_attrs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_attribute_name, -- ATTRIBUTE_NAME
    p_expiration_date, -- EXPIRATION_DATE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- If full quantity bids are required then quantity (-20) cannot be scored

  WHEN
  (
    sel_sequence_number = -20 AND
    p_bid_ranking = 'MULTI_ATTRIBUTE_SCORING' AND
    p_full_quantity_bid_code = 'FULL_QTY_BIDS_REQD'
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, ATTRIBUTE_NAME, EXPIRATION_DATE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_QUANTITY_SCORE_ERR', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_attrs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_attribute_name, -- ATTRIBUTE_NAME
    p_expiration_date, -- EXPIRATION_DATE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- For MAS auctions, if weight is greater than zero then the scoring type
  -- should not be null or NONE

  WHEN
  (
    sel_weight IS NOT NULL AND
    sel_weight > 0 AND
    p_bid_ranking = 'MULTI_ATTRIBUTE_SCORING' AND
    NVL (sel_scoring_type, 'NONE') = 'NONE'
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, ATTRIBUTE_NAME, EXPIRATION_DATE, TOKEN1_NAME,
    TOKEN1_VALUE, TOKEN2_NAME, TOKEN2_VALUE, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_SCORE_WLINE_REQUIRED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_attrs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_attribute_name, -- ATTRIBUTE_NAME
    p_expiration_date, -- EXPIRATION_DATE
    'LINE', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    'ATTRIBUTE', -- TOKEN2_NAME
    sel_attribute_name, -- TOKEN2_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- For MAS auctions, if weight is zero or null and the scoring type
  -- is not null and not none then error

  WHEN
  (
    p_bid_ranking = 'MULTI_ATTRIBUTE_SCORING' AND
    (sel_weight IS NULL OR sel_weight <= 0) AND
    NVL (sel_scoring_type, 'NONE') <> 'NONE'
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, ATTRIBUTE_NAME, EXPIRATION_DATE, TOKEN1_NAME,
    TOKEN1_VALUE, TOKEN2_NAME, TOKEN2_VALUE, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_WEIGHT_LINE_REQUIRED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_attrs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_attribute_name, -- ATTRIBUTE_NAME
    p_expiration_date, -- EXPIRATION_DATE
    'LINE', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    'ATTRIBUTE', -- TOKEN2_NAME
    sel_attribute_name, -- TOKEN2_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  SELECT
    PAA.LINE_NUMBER sel_line_number,
    PAA.ATTRIBUTE_NAME sel_attribute_name,
    PAA.SEQUENCE_NUMBER sel_sequence_number,
    PAA.VALUE sel_value,
    PAA.DISPLAY_TARGET_FLAG sel_display_target_flag,
    PAA.DISPLAY_ONLY_FLAG sel_display_only_flag,
    PAA.WEIGHT sel_weight,
    TRUNC (PAA.WEIGHT) sel_trunc_weight,
    PAA.ATTR_MAX_SCORE sel_attr_max_score,
    TRUNC (PAA.ATTR_MAX_SCORE) sel_trunc_attr_max_score,
    PAIP.DOCUMENT_DISP_LINE_NUMBER sel_document_disp_line_number,
    PAA.SCORING_TYPE sel_scoring_type
  FROM
    PON_AUCTION_ATTRIBUTES PAA,
    PON_AUCTION_ITEM_PRICES_ALL PAIP
  WHERE
    PAIP.AUCTION_HEADER_ID = p_auction_header_id AND
    PAA.AUCTION_HEADER_ID = p_auction_header_id AND
    PAIP.LINE_NUMBER = PAA.LINE_NUMBER AND
    PAA.ATTR_LEVEL = 'LINE';

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_ATTRIBUTES',
      message  => 'Leaving procedure'
                  || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}
END VAL_ATTRIBUTES;

/*
 * Two attributes within a single line cannot have the same name
 * Since we have used GroupBy to determine duplicates this cannot
 * be merged with the VAL_ATTRIBUTES
 */

PROCEDURE VAL_ATTR_NAME_UNIQUE(
  p_auction_header_id IN NUMBER,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER
  ) IS
BEGIN
  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_ATTR_NAME_UNIQUE',
      message  => 'Entering PON_NEGOTIATION_HELPER_PVT.VAL_ATTR_NAME_UNIQUE'
                  || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}

  INSERT INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, ATTRIBUTE_NAME, EXPIRATION_DATE,
    TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  SELECT
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_DUPLICATE_LINE_ATTRS', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_attrs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    LINE_NUMBER, -- LINE_NUMBER
    ATTRIBUTE_NAME, -- ATTRIBUTE_NAME
    p_expiration_date, -- EXPIRATION_DATE
    'ATTRIBUTE_NAME', -- TOKEN1_NAME
    ATTRIBUTE_NAME, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  FROM
    PON_AUCTION_ATTRIBUTES
  WHERE
    ATTR_LEVEL='LINE' AND
    AUCTION_HEADER_ID=p_auction_header_id
  GROUP by AUCTION_HEADER_ID, LINE_NUMBER, attribute_name
  HAVING count(LINE_NUMBER) > 1;

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_ATTR_NAME_UNIQUE',
      message  => 'Returning PON_NEGOTIATION_HELPER_PVT.VAL_ATTR_NAME_UNIQUE'
                  || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}
END VAL_ATTR_NAME_UNIQUE;

/*
 * The following validations are performed:
 * 1. Entered score value should be between 0 and 100
 * 2. Score must be a positive number
 */
PROCEDURE VAL_ATTR_SCORES(
  p_auction_header_id IN NUMBER,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER
  ) IS
BEGIN
  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_ATTR_SCORES',
      message  => 'Entering PON_NEGOTIATION_HELPER_PVT.VAL_ATTR_SCORES'
                  || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}

  INSERT ALL

  -- Entered score value should be between 0 and 100

  WHEN
  (
    SCORE is not null AND
    sel_trunc_score NOT BETWEEN 0 and 100
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID,
    ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_INVALID_SCORE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_attrs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    LINE_NUMBER, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- SCORE MUST BE A POSITIVE NUMBER

  WHEN
  (
    SCORE is not null AND
    (SCORE - sel_trunc_score <>0)
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, CREATED_BY,
    CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_MUST_BE_A_INT_M', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_attrs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    LINE_NUMBER, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  SELECT
    SCORE,
    LINE_NUMBER,
    TRUNC (SCORE) sel_trunc_score
  FROM
    PON_ATTRIBUTE_SCORES
  WHERE
    AUCTION_HEADER_ID = p_auction_header_id AND
    LINE_NUMBER > 0;

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_ATTR_SCORES',
      message  => 'Returning PON_NEGOTIATION_HELPER_PVT.VAL_ATTR_SCORES'
                  || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}
END VAL_ATTR_SCORES;

/*
 * The following validations are performed
 * 1. Price break effective start date should be before effective end date
 * 2. Ship to locaton and ship to org should be proper. The ship_to_location and ship_to_org if both are entered then either
     a.The Ship_to_location should belong to the Ship_to_organization
     b.The Ship_to_location should be a global location (inventory_organization_id is null)
 * 3. Price break should not be empty. Only price should not be entered
 * 4. Quantity should not be empty or negative
 * 5. The price break price should be positive
 * 6. Effective start date after sysdate or close date
 * 7. Effective end date after sysdate or close date
 * 8. Response type if entered should have price differentials
 * 9. If the response type is null then there should be no price differentials
 * 10. Precision of the price entered should be less than the auction currency precision
 * 11. Effective start date should be after po start date
 * 12. Effective end date should be after po start date
 * 13. The effective start date should be before po end date if both are entered
 * 14. Effective end date should be before the po end date
 */
PROCEDURE VAL_PRICE_BREAKS (
  p_auction_header_id IN NUMBER,
  p_close_bidding_date IN DATE,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER,
  p_precision IN NUMBER,
  p_po_start_date IN DATE,
  p_po_end_date IN DATE
) IS

l_temp NUMBER;
BEGIN

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_PRICE_BREAKS',
      message  => 'Entering Procedure' || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}

  IF (p_precision <> g_precision_any) THEN
    l_temp := power (10, p_precision);
  ELSE
    l_temp := 0;
  END IF;

  INSERT ALL

  -- PRICE BREAK EFFECTIVE START DATE SHOULD BE BEFORE EFFECTIVE END DATE

  WHEN
  (
    sel_effective_start_date IS NOT NULL AND
    sel_effective_end_date IS NOT NULL AND
    sel_effective_end_date < sel_effective_start_date
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME,
    TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_EFFC_END_BEF_START', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- SHIP TO LOCATON AND SHIP TO ORG SHOULD BE PROPER
  -- THE SHIP_TO_LOCATION AND SHIP_TO_ORG IF BOTH ARE ENTERED THEN EITHER
  -- 1. The Ship_to_location should belong to the Ship_to_organization
  -- 2. The Ship_to_location should be a global location (inventory_organization_id is null)

  WHEN
  (
    sel_ship_to_organization_id IS NOT NULL AND
    sel_ship_to_location_id IS NOT NULL AND
    NOT EXISTS (SELECT l.INVENTORY_ORGANIZATION_ID
        FROM HR_LOCATIONS_ALL L
        WHERE SYSDATE < NVL(L.INACTIVE_DATE, SYSDATE + 1) AND
        NVL(L.SHIP_TO_SITE_FLAG,'N') = 'Y' AND
        L.LOCATION_ID = sel_ship_to_location_id AND
        nvl (L.INVENTORY_ORGANIZATION_ID, sel_ship_to_organization_id) = sel_ship_to_organization_id)
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_SHIP_TO_MATCHING_ERR', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- PRICE BREAK SHOULD NOT BE EMPTY
  -- ONLY PRICE SHOULD NOT BE ENTERED

  WHEN
  (
    sel_ship_to_organization_id IS NULL AND
    sel_ship_to_location_id IS NULL AND
    sel_effective_start_date IS NULL AND
    sel_effective_end_date IS NULL AND
    sel_quantity IS NULL
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    NVL2 (sel_price, 'PON_AUCTS_PB_PRICE_ONLY', 'PON_AUCTS_SHIPMENT_EMPTY'), -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- quantity should not be empty or negative

  WHEN
  (
    sel_quantity IS NOT NULL AND
    sel_quantity < 0 AND
    sel_quantity <> g_null_int
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_PB_QUANTITY_POSITIVE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- the price break price should be positive

  WHEN
  (
    sel_price < 0
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_PB_RPICE_POSITIVE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  --  EFFECTIVE START DATE AFTER SYSDATE OR CLOSE DATE

  WHEN
  (
    sel_effective_start_date IS NOT NULL AND
    sel_effective_start_date <= NVL (p_close_bidding_date, SYSDATE)
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    NVL2 (p_close_bidding_date, 'PON_AUC_EFFC_FROM_BEF_CLOSE', 'PON_AUC_EFFC_FROM_BEF_TODAY'), -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  --  EFFECTIVE END DATE AFTER SYSDATE OR CLOSE DATE

  WHEN
  (
    sel_effective_end_date IS NOT NULL AND
    sel_effective_end_date <= NVL (p_close_bidding_date, SYSDATE)
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    NVL2 (p_close_bidding_date, 'PON_AUC_EFFC_TO_BEFORE_CLOSE',
      'PON_AUC_EFFC_TO_BEFORE_TODAY'), -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- RESPONSE TYPE if entered should have price differentials

  WHEN
  (
    sel_differential_response_type IS NOT NULL AND
    NOT EXISTS (
      SELECT 1
      FROM PON_PRICE_DIFFERENTIALS PPD
      WHERE
      PPD.AUCTION_HEADER_ID = p_auction_header_id AND
      PPD.LINE_NUMBER = sel_line_number AND
      PPD.SHIPMENT_NUMBER = sel_shipment_number
    )
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_PRICEDIFF_REQD_FOR_SHIP', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- RESPONSE TYPE: If the response type is null then there should be no price differentials

  WHEN
  (
    sel_differential_response_type IS NULL AND
    EXISTS (
      SELECT 1
      FROM PON_PRICE_DIFFERENTIALS PPD
      WHERE
      PPD.AUCTION_HEADER_ID = p_auction_header_id AND
      PPD.LINE_NUMBER = sel_line_number AND
      PPD.SHIPMENT_NUMBER = sel_shipment_number
    )
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_SET_DIFFER_RESPONSE_TYPE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- Precision of the price entered should be less than the auction currency precision

  WHEN
  (
    sel_price >= 0 AND
    ABS (sel_price  * l_temp - TRUNC (sel_price * l_temp)) > 0
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME,
    TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_PB_PRICE_PRECISION', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- EFFECTIVE START DATE SHOULD BE AFTER PO START DATE

  WHEN
  (
    p_po_start_date IS NOT NULL AND
    sel_effective_start_date IS NOT NULL AND
    sel_effective_start_date < p_po_start_date
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, batch_id, ENTITY_TYPE,AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY,CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_EFFC_FROM_BEF_NEG', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- EFFECTIVE END DATE SHOULD BE AFTER PO START DATE

  WHEN
  (
    p_po_start_date IS NOT NULL AND
    sel_effective_end_date IS NOT NULL AND
    sel_effective_end_date < p_po_start_date
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, batch_id, ENTITY_TYPE,AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY,CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_EFFC_TO_BEFORE_NEG', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- the effective start date should be before po end date if both are entered

  WHEN
  (
    p_po_end_date IS NOT NULL AND
    sel_effective_start_date IS NOT NULL AND
    sel_effective_start_date > p_po_end_date
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, batch_id, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_EFFC_FROM_AFT_NEG', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- effective end date should be before the po end date

  WHEN
  (
    p_po_end_date IS NOT NULL AND
    sel_effective_end_date IS NOT NULL AND
    sel_effective_end_date > p_po_end_date
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, batch_id, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_EFFC_TO_AFT_NEG', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  SELECT
    PAIP.LINE_NUMBER sel_line_number,
    PAIP.DOCUMENT_DISP_LINE_NUMBER sel_document_disp_line_number,
    PASA.SHIPMENT_NUMBER sel_shipment_number,
    PASA.PRICE sel_price,
    PASA.QUANTITY sel_quantity,
    PASA.EFFECTIVE_END_DATE sel_effective_end_date,
    PASA.EFFECTIVE_START_DATE sel_effective_start_date,
    PASA.SHIP_TO_LOCATION_ID sel_ship_to_location_id,
    PASA.SHIP_TO_ORGANIZATION_ID sel_ship_to_organization_id,
    PASA.DIFFERENTIAL_RESPONSE_TYPE sel_differential_response_type
  FROM
    PON_AUCTION_ITEM_PRICES_ALL PAIP,
    PON_AUCTION_SHIPMENTS_ALL PASA
  WHERE
    PAIP.AUCTION_HEADER_ID = p_auction_header_id AND
    PASA.AUCTION_HEADER_ID = p_auction_header_id AND
    PAIP.LINE_NUMBER = PASA.LINE_NUMBER;

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_PRICE_BREAKS',
      message  => 'Leaving procedure');
  END IF; --}

END VAL_PRICE_BREAKS;

/*
 * The following validations are performed
 * 1. Min Quantity should not be null or negative
 * 2. Max Quantity should not be null or negative
 * 3. Max quantity should be greater or equal to the min quantity
 * 4. The ranges of min-max quantities should not overlap across tiers for a given line
 * 5. The price tier price should be positive if not null
 * 6. Precision of the price entered should be less than the auction currency precision
 */
PROCEDURE VAL_QTY_BASED_PRICE_TIERS (
  p_auction_header_id IN NUMBER,
  p_close_bidding_date IN DATE,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER,
  p_precision IN NUMBER
) IS

l_temp NUMBER;
BEGIN

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_QTY_BASED_PRICE_TIERS',
      message  => 'Entering Procedure' || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}

  IF (p_precision <> g_precision_any) THEN
    l_temp := power (10, p_precision);
  ELSE
    l_temp := 0;
  END IF;

  INSERT ALL

  -- The min quantity is a required field. If the min quantity is null,
  -- we insert rows into the interface errors table.

  WHEN
  (
    sel_min_quantity IS NULL
    OR
    sel_min_quantity = g_null_int
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME,
    TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_PT_MIN_QUANTITY_REQ', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pts_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- The max quantity is a required field. If the min quantity is null,
  -- we insert rows into the interface errors table.

  WHEN
  (
    sel_max_quantity IS NULL
    OR
    sel_max_quantity = g_null_int
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_PT_MAX_QUANTITY_REQ', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pts_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- The min quantity should be a positive number. i.e. strictly greater than zero.

  WHEN
  (
    (sel_min_quantity IS NOT NULL AND
    sel_min_quantity <= 0 AND
    sel_min_quantity <> g_null_int)
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_PT_QUANTITY_POSITIVE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pts_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- The max quantity should be a positive number. i.e. strictly greater than zero.

  WHEN
  (
    (sel_max_quantity IS NOT NULL AND
    sel_max_quantity <= 0 AND
    sel_max_quantity <> g_null_int)
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_PT_QUANTITY_POSITIVE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pts_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )
  -- max quantity should be greater or equal to the min quantity. i.e if min quantity should not
  -- be greater than max quantity

  WHEN
  (
    sel_min_quantity > sel_max_quantity
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_QT_MAX_MIN_QTY_ERR', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pts_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- the price tier price should be positive( i.e. if it is not null then it should be positive)

  WHEN
  (
    sel_price <> g_null_int
    AND
    sel_price <= 0
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_QT_PRICE_POSITIVE', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pts_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- Precision of the price entered should be less than the auction currency precision

  WHEN
  (
    sel_price > 0 AND
    ABS (sel_price  * l_temp - TRUNC (sel_price * l_temp)) > 0
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME,
    TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_QT_PRICE_PRECISION', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_pts_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  SELECT
    PAIP.LINE_NUMBER sel_line_number,
    PAIP.DOCUMENT_DISP_LINE_NUMBER sel_document_disp_line_number,
    PASA.SHIPMENT_NUMBER sel_shipment_number,
    PASA.PRICE sel_price,
    PASA.QUANTITY sel_min_quantity,
    PASA.MAX_QUANTITY sel_max_quantity
  FROM
    PON_AUCTION_ITEM_PRICES_ALL PAIP,
    PON_AUCTION_SHIPMENTS_ALL PASA
  WHERE
    PAIP.AUCTION_HEADER_ID = p_auction_header_id AND
    PASA.AUCTION_HEADER_ID = p_auction_header_id AND
    PAIP.LINE_NUMBER = PASA.LINE_NUMBER;

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_PRICE_BREAKS',
      message  => 'Leaving procedure');
  END IF; --}

  -- The ranges of min-max quantities should not overlap across tiers for a given line in a negotiation
  -- When this validation is performed at shipments level multiple error message were thrown for one particular line
  -- To avoid the multiple error messages this validation has to be performed at line level rather than shipments level.

  INSERT INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID, LINE_NUMBER,
    EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
 Select
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_OVERLAP_RANGES_QT', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pts_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    paip.line_number, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINENUM', -- TOKEN1_NAME
    paip.line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id    -- LAST_UPDATE_LOGIN
FROM pon_auction_item_prices_all paip
WHERE paip.auction_header_id = p_auction_header_id
 AND paip.line_number IN
  (SELECT DISTINCT pasa.line_number
   FROM pon_auction_shipments_all pasa1,
   pon_auction_shipments_all pasa
   WHERE pasa1.auction_header_id = p_auction_header_id
   and pasa.auction_header_id = p_auction_header_id
   AND pasa.line_number = pasa1.line_number
   AND pasa1.shipment_number <> pasa.shipment_number
   AND pasa1.quantity <= pasa.quantity
   AND pasa.quantity <= pasa1.max_quantity) ;

END VAL_QTY_BASED_PRICE_TIERS;

/*
 * Check to ensure that there are no duplicate price differentials.
 * Keeping this outside all other validations as we need a group by here
 */
PROCEDURE VAL_PD_UNIQUE(
  p_auction_header_id IN NUMBER,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER
 ) IS
BEGIN
  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_PD_UNIQUE',
      message  => 'Entering procedure' || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}

  -- For price differentials directly under the lines

  INSERT INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  SELECT
    g_interface_type, --INTERFACE_TYPE
    'PON_DUPLICATE_PRICE_TYPES_ERR', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pds_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    PAIP.LINE_NUMBER, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    PAIP.DOCUMENT_DISP_LINE_NUMBER, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  FROM
    PON_PRICE_DIFFERENTIALS PPD,
    PON_AUCTION_ITEM_PRICES_ALL PAIP
  WHERE
    PPD.AUCTION_HEADER_ID = p_auction_header_id AND
    PAIP.AUCTION_HEADER_ID = p_auction_header_id AND
    PPD.LINE_NUMBER = PAIP.LINE_NUMBER AND
    PPD.SHIPMENT_NUMBER = -1
  GROUP BY
    PPD.AUCTION_HEADER_ID,
    PAIP.LINE_NUMBER,
    PAIP.DOCUMENT_DISP_LINE_NUMBER,
    PPD.PRICE_TYPE
  HAVING
    COUNT(PPD.LINE_NUMBER) > 1;

  -- For price differentials under shipments

  INSERT INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  SELECT
    g_interface_type, --INTERFACE_TYPE
    'PON_DUPLICATE_PRICE_TYPES', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pds_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    PAIP.LINE_NUMBER, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    PAIP.DOCUMENT_DISP_LINE_NUMBER, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  FROM
    PON_PRICE_DIFFERENTIALS PPD,
    PON_AUCTION_ITEM_PRICES_ALL PAIP,
    PON_AUCTION_SHIPMENTS_ALL PAS
  WHERE
    PPD.AUCTION_HEADER_ID = p_auction_header_id AND
    PAIP.AUCTION_HEADER_ID = p_auction_header_id AND
    PAS.AUCTION_HEADER_ID = p_auction_header_id AND
    PPD.LINE_NUMBER = PAIP.LINE_NUMBER AND
    PPD.LINE_NUMBER = PAS.LINE_NUMBER AND
    PAS.SHIPMENT_NUMBER = PPD.SHIPMENT_NUMBER
  GROUP BY
    PPD.AUCTION_HEADER_ID,
    PAIP.LINE_NUMBER,
    PAIP.DOCUMENT_DISP_LINE_NUMBER,
    PPD.PRICE_TYPE,
    PAS.SHIPMENT_NUMBER
  HAVING
    COUNT(PPD.LINE_NUMBER) > 1;

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_PD_UNIQUE',
      message  => 'Leaving procedure');
  END IF; --}
END VAL_PD_UNIQUE;

/*
 * The following validations are performed:
 * 1. Multiplier should be a positive number
 * 2. Price differential should not be empty
 *
 * Validations are performed for price differentials directly under the lines
 * and also for those that are under the shipments
 */
PROCEDURE VAL_PRICE_DIFFERENTIALS (
  p_auction_header_id IN NUMBER,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER
) IS
BEGIN
  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_PRICE_DIFFERENTIALS',
      message  => 'Entering procedure' || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}

  -- FOR PRICE DIFFERENTIALS DIRECTLY UNDER LINES

  INSERT ALL

  -- MULTIPLIER SHOULD BE A POSITIVE NUMBER

  WHEN
  (
    sel_multiplier IS NULL OR
    sel_multiplier <= 0
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, PRICE_DIFFERENTIAL_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    TOKEN2_NAME, TOKEN2_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    NVL2 (sel_multiplier, 'PON_AUCTS_TAR_MULT_POSITIVE', 'PON_AUCTS_TAR_MULT_REQD'),         -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pds_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_price_differential_number, -- PRICE_DIFFERENTIAL_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    'PRICE_TYPE', -- TOKEN2_NAME
    sel_price_differential_desc, -- TOKEN2_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- PRICE DIFFERENTIAL SHOULD NOT BE EMPTY

  WHEN
  (
    sel_price_type = g_empty_price_type AND
    sel_multiplier IS NULL
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, PRICE_DIFFERENTIAL_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, TOKEN2_NAME,
    TOKEN2_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_PRICE_DIFF_EMPTY', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pds_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_price_differential_number, -- PRICE_DIFFERENTIAL_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    'PRICE_TYPE', -- TOKEN1_NAME
    sel_price_differential_desc, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  SELECT
    PPD.MULTIPLIER sel_multiplier,
    PAIP.LINE_NUMBER sel_line_number,
    PAIP.DOCUMENT_DISP_LINE_NUMBER sel_document_disp_line_number,
    PPD.PRICE_DIFFERENTIAL_NUMBER sel_price_differential_number,
    PPDL.PRICE_DIFFERENTIAL_DESC sel_price_differential_desc,
    PPD.PRICE_TYPE sel_price_type
  FROM
    PON_PRICE_DIFFERENTIALS PPD,
    PON_AUCTION_ITEM_PRICES_ALL PAIP,
    PO_PRICE_DIFF_LOOKUPS_V PPDL
  WHERE
    PAIP.AUCTION_HEADER_ID = p_auction_header_id AND
    PPD.AUCTION_HEADER_ID = p_auction_header_id AND
    PAIP.LINE_NUMBER = PPD.LINE_NUMBER AND
    PPDL.PRICE_DIFFERENTIAL_TYPE = PPD.PRICE_TYPE AND
    PPD.SHIPMENT_NUMBER = -1;

  -- FOR PRICE DIFFERENTIALS UNDER PRICE BREAKS

  INSERT ALL

  -- MULTIPLIER SHOULD BE A POSITIVE NUMBER

  WHEN
  (
    sel_multiplier IS NULL OR
    sel_multiplier <= 0
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, SHIPMENT_NUMBER, PRICE_DIFFERENTIAL_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    TOKEN2_NAME, TOKEN2_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    DECODE (sel_multiplier, 'PON_AUCTS_TAR_MULT_POS_SHIP', 'PON_AUCTS_TAR_MULT_REQD_SHIP'),         -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pds_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    sel_price_differential_number, -- PRICE_DIFFERENTIAL_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    'PRICE_TYPE', -- TOKEN2_NAME
    sel_price_differential_desc, -- TOKEN2_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- PRICE DIFFERENTIAL SHOULD NOT BE EMPTY

  WHEN
  (
    sel_price_type = g_empty_price_type AND
    sel_multiplier IS NULL
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, SHIPMENT_NUMBER, PRICE_DIFFERENTIAL_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, TOKEN2_NAME,
    TOKEN2_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUCTS_PRICE_DIFF_EMPTY', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pds_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_shipment_number, -- SHIPMENT_NUMBER
    sel_price_differential_number, -- PRICE_DIFFERENTIAL_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    'PRICE_TYPE', -- TOKEN1_NAME
    sel_price_differential_desc, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  SELECT
    PPD.MULTIPLIER sel_multiplier,
    PAIP.LINE_NUMBER sel_line_number,
    PAIP.DOCUMENT_DISP_LINE_NUMBER sel_document_disp_line_number,
    PPD.PRICE_DIFFERENTIAL_NUMBER sel_price_differential_number,
    PPD.PRICE_TYPE sel_price_type,
    PPD.SHIPMENT_NUMBER sel_shipment_number,
    PPDL.PRICE_DIFFERENTIAL_DESC sel_price_differential_desc
  FROM
    PON_AUCTION_ITEM_PRICES_ALL PAIP,
    PON_AUCTION_SHIPMENTS_ALL PASA,
    PON_PRICE_DIFFERENTIALS PPD,
    PO_PRICE_DIFF_LOOKUPS_V PPDL
  WHERE
    PAIP.AUCTION_HEADER_ID = p_auction_header_id AND
    PPD.AUCTION_HEADER_ID = p_auction_header_id AND
    PASA.AUCTION_HEADER_ID = p_auction_header_id AND
    PAIP.LINE_NUMBER = PASA.LINE_NUMBER AND
    PASA.LINE_NUMBER = PPD.LINE_NUMBER AND
    PPDL.PRICE_DIFFERENTIAL_TYPE = PPD.PRICE_TYPE AND
    PASA.SHIPMENT_NUMBER = PPD.SHIPMENT_NUMBER;

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_PRICE_DIFFERENTIALS',
      message  => 'Leaving procedure');
  END IF; --}
END VAL_PRICE_DIFFERENTIALS;

/*
 * The following validations are performed:
 * 1. For line type price elements the value should be > 0
 * 2. For non line type price elements the value should be < 0
 * 3. If the display target flag is set then target value should be entered
 * 4. If the pricing basis is per unit then the value enteres should have a precision less
 *    than the auction currency precision
 * 5. If the pricing basis is fixed amount then the value precision should be less than the
 *    fnd currency precision
 * 6. There should not be any inactive price elements
 * 7. Pricing Basis should not be NULL - added this for back button support
 * 8. Cost Factor name cannot be null - added this for back button support
 */
PROCEDURE VAL_PRICE_ELEMENTS (
  p_auction_header_id IN NUMBER,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER,
  p_precision IN NUMBER,
  p_fnd_precision IN NUMBER,
  p_trading_partner_id IN NUMBER
) IS

l_temp NUMBER;
l_temp_fnd NUMBER;
l_doctype_suffix VARCHAR2(10);
BEGIN

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_PRICE_ELEMENTS',
      message  => 'Entering procedure with:' || ' p_auction_header_id = ' || p_auction_header_id ||
                  ', p_trading_partner_id = ' || p_trading_partner_id);
  END IF; --}

  IF (p_precision <> g_precision_any) THEN
    l_temp := power (10, p_precision);
  ELSE
    l_temp := 0;
  END IF;

  l_doctype_suffix := PON_LARGE_AUCTION_UTIL_PKG.GET_DOCTYPE_SUFFIX (p_auction_header_id);

  INSERT ALL

  -- FOR LINE TYPE PRICE ELEMENTS THE VALUE SHOULD BE > 0

  WHEN
  (
    sel_value IS NOT NULL AND
    sel_price_element_type_id = g_item_price_type_id AND
    sel_value <= 0
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, PRICE_ELEMENT_TYPE_ID, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, TOKEN2_NAME,
    TOKEN2_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_PE_VALUE_MUST_BE_POS', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pfs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_price_element_type_id, -- PRICE_ELEMENT_TYPE_ID
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    'PE_NAME', -- TOKEN1_NAME
    sel_name, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- FOR NON LINE TYPE PRICE ELEMENTS THE VALUE SHOULD BE < 0

  WHEN
  (
    sel_VALUE IS NOT NULL AND
    sel_PRICE_ELEMENT_TYPE_ID <> g_item_price_type_id AND
    sel_VALUE < 0
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, PRICE_ELEMENT_TYPE_ID, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    TOKEN2_NAME, TOKEN2_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_PE_VALUE_BE_POS_OR_ZERO', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_pfs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_price_element_type_id, -- PRICE_ELEMENT_TYPE_ID
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    'PE_NAME', -- TOKEN1_NAME
    sel_name, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- IF THE DISPLAY TARGET FLAG IS SET THEN TARGET VALUE SHOULD BE ENTERED

  WHEN
  (
    sel_value IS NULL AND
    sel_display_target_flag = 'Y'
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, PRICE_ELEMENT_TYPE_ID, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    TOKEN2_NAME, TOKEN2_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_PE_SHOW_TARGET', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pfs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_price_element_type_id, -- PRICE_ELEMENT_TYPE_ID
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    'PE_NAME', -- TOKEN1_NAME
    sel_name, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- If the pricing basis is per unit then the value enteres should have
  -- a precision less than the auction currency precision

  WHEN
  (
    sel_value IS NOT NULL AND
    sel_pricing_basis = g_per_unit AND
    ABS (sel_value  * l_temp - TRUNC (sel_value * l_temp))> 0
  )

  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, PRICE_ELEMENT_TYPE_ID, EXPIRATION_DATE,
    TOKEN1_NAME, TOKEN1_VALUE, TOKEN2_NAME, TOKEN2_VALUE, CREATED_BY,
    CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_PE_TOO_MANY_DIGITS_M' || l_doctype_suffix, -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pfs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_price_element_type_id, -- PRICE_ELEMENT_TYPE_ID
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    'PE_NAME', -- TOKEN1_NAME
    sel_name, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- If the pricing basis is fixed amount then the value precision should
  -- be less than the fnd currency precision

  WHEN
  (
    sel_value IS NOT NULL AND
    sel_pricing_basis = g_fixed_amount AND
    ABS (sel_value * l_temp_fnd - TRUNC (sel_value * l_temp_fnd)) >0
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, PRICE_ELEMENT_TYPE_ID, EXPIRATION_DATE,
    TOKEN1_NAME, TOKEN1_VALUE, TOKEN2_NAME, TOKEN2_VALUE, CREATED_BY,
    CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_PE_TOO_MANY_DIGITS_A', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, -- BATCH_ID
    g_auction_pfs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_price_element_type_id, -- PRICE_ELEMENT_TYPE_ID
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    'PE_NAME', -- TOKEN1_NAME
    sel_name, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- There should not be any inactive price elements

  WHEN
  (
    sel_enabled_flag = 'N'
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, PRICE_ELEMENT_TYPE_ID, EXPIRATION_DATE,
    TOKEN1_NAME, TOKEN1_VALUE, TOKEN2_NAME, TOKEN2_VALUE, CREATED_BY,
    CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_AUCTION_INA_PES', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pfs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_price_element_type_id, -- PRICE_ELEMENT_TYPE_ID
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    'PE_NAME', -- TOKEN1_NAME
    sel_name, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- Pricing Basis should not be NULL - added this for back button support
  -- Pricing basis column is made nullable on the database

  WHEN
  (
    sel_pricing_basis IS NULL
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, PRICE_ELEMENT_TYPE_ID, EXPIRATION_DATE,
    TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY,CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_PRICING_BASIS_M', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pfs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_price_element_type_id, -- PRICE_ELEMENT_TYPE_ID
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- Cost factor name should not be null (added for back button support)

  WHEN
  (
    sel_name IS NULL
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, PRICE_ELEMENT_TYPE_ID, EXPIRATION_DATE,
    TOKEN1_NAME, TOKEN1_VALUE,
    CREATED_BY,CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_PE_REQUIRED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pfs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    sel_line_number, -- LINE_NUMBER
    sel_price_element_type_id, -- PRICE_ELEMENT_TYPE_ID
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    sel_document_disp_line_number, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  SELECT
    PAIP.LINE_NUMBER sel_line_number,
    PAIP.DOCUMENT_DISP_LINE_NUMBER sel_document_disp_line_number,
    PPE.PRICE_ELEMENT_TYPE_ID sel_price_element_type_id,
    PPETL.NAME sel_name,
    PPE.VALUE sel_value,
    PPE.DISPLAY_TARGET_FLAG sel_display_target_flag,
    PPE.PRICING_BASIS sel_pricing_basis,
    PPET.ENABLED_FLAG sel_enabled_flag,
    PPET.SYSTEM_FLAG sel_system_flag
  FROM
    PON_AUCTION_ITEM_PRICES_ALL PAIP,
    PON_PRICE_ELEMENTS PPE,
    PON_PRICE_ELEMENT_TYPES_TL PPETL,
    PON_PRICE_ELEMENT_TYPES PPET
  WHERE
    PAIP.AUCTION_HEADER_ID = p_auction_header_id AND
    PPE.AUCTION_HEADER_ID = p_auction_header_id AND
    PAIP.LINE_NUMBER = PPE.LINE_NUMBER AND
    PPE.PRICE_ELEMENT_TYPE_ID = PPETL.PRICE_ELEMENT_TYPE_ID(+) AND
    PPE.PRICE_ELEMENT_TYPE_ID = PPET.PRICE_ELEMENT_TYPE_ID(+) AND
    PPETL.LANGUAGE(+) = USERENV ('LANG');

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_PRICE_ELEMENTS',
      message  => 'Leaving procedure');
  END IF; --}
END VAL_PRICE_ELEMENTS;

/*
 * Check to see that there are no duplicate price elements.
 * This is being kept outside the other validations as this
 * involves a group by
 */
PROCEDURE VAL_PE_UNIQUE (
  p_auction_header_id IN NUMBER,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER
 ) IS
BEGIN
  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_PE_UNIQUE',
      message  => 'Entering PON_NEGOTIATION_HELPER_PVT.VAL_PE_UNIQUE'
                  || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}

  INSERT INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, LINE_NUMBER, PRICE_ELEMENT_TYPE_ID, EXPIRATION_DATE,
    TOKEN1_NAME, TOKEN1_VALUE, TOKEN2_NAME, TOKEN2_VALUE, CREATED_BY,
    CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  SELECT
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_DUPLICATE_PES', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pfs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    PPE.LINE_NUMBER, -- LINE_NUMBER
    PPE.PRICE_ELEMENT_TYPE_ID, -- PRICE_ELEMENT_TYPE_ID
    p_expiration_date, -- EXPIRATION_DATE
    'LINE_NUMBER', -- TOKEN1_NAME
    PAIP.DOCUMENT_DISP_LINE_NUMBER, -- TOKEN1_VALUE
    'PE_NAME', -- TOKEN1_NAME
    PPETL.NAME, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  FROM
    PON_AUCTION_ITEM_PRICES_ALL PAIP,
    PON_PRICE_ELEMENTS PPE,
    PON_PRICE_ELEMENT_TYPES_TL PPETL
  WHERE
    PAIP.AUCTION_HEADER_ID = p_auction_header_id AND
    PPE.AUCTION_HEADER_ID = p_auction_header_id AND
    PAIP.LINE_NUMBER = PPE.LINE_NUMBER AND
    PPE.PRICE_ELEMENT_TYPE_ID  = PPETL.PRICE_ELEMENT_TYPE_ID AND
    PPETL.LANGUAGE = USERENV ('LANG')
  GROUP BY
    PPE.AUCTION_HEADER_ID,
    PPE.LINE_NUMBER,
    PPE.PRICE_ELEMENT_TYPE_ID,
    PAIP.DOCUMENT_DISP_LINE_NUMBER,
    PPETL.NAME
  HAVING
    COUNT (PPE.LINE_NUMBER) > 1;

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_PE_UNIQUE',
      message  => 'Leaving procedure');
  END IF; --}
END VAL_PE_UNIQUE;

-- Validating if there is any supplier who has been restricted on all the
-- negotiation lines
PROCEDURE VAL_PARTY_EXCLUSIONS (
  p_auction_header_id IN NUMBER,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER
) IS

l_major_line_count NUMBER;
BEGIN
  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_PARTY_EXCLUSIONS',
      message  => 'Entering Procedure' || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}

  -- LOGIC: count the number of exclusions for this supplier from
  -- pon_party_line_exclusions table and if that number is equal
  -- to the number of major lines in the negotiation then it is
  -- and error
  SELECT
    COUNT(LINE_NUMBER)
  INTO
    l_major_line_count
  FROM
    pon_auction_item_prices_all
  WHERE
    auction_header_id = p_auction_header_id AND
    group_type IN ('LOT', 'GROUP', 'LINE');

  INSERT INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
    AUCTION_HEADER_ID, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY,
    CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  SELECT
    g_interface_type, --INTERFACE_TYPE
    'PON_PARTY_TOTALLY_EXCLUDED', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_attrs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    p_expiration_date, -- EXPIRATION_DATE
    'SUPPLIER_NAME', -- TOKEN1_NAME
    pbp.trading_partner_name, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  FROM
    pon_bidding_parties pbp
  WHERE
    pbp.auction_header_id = p_auction_header_id AND
    (SELECT
       COUNT(trading_partner_id)
     FROM
       pon_party_line_exclusions pple
     WHERE
       pple.trading_partner_id = pbp.trading_partner_id AND
       pple.vendor_site_id = pbp.vendor_site_id AND
       pple.auction_header_id = p_auction_header_id) = l_major_line_count;

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_PARTY_EXCLUSIONS',
      message  => 'Leaving Procedure');
  END IF; --}

END VAL_PARTY_EXCLUSIONS;

PROCEDURE VAL_LINE_REF_DATA (
  p_auction_header_id IN NUMBER,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER
) IS
BEGIN
  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_LINE_REF_DATA',
      message  => 'Entering Procedure p_auction_header_id = ' || p_auction_header_id);
  END IF; --}
  INSERT ALL

  -- VALIDATE JOB ID

  WHEN
  (
     SELECTED_PURCHASE_BASIS = g_temp_labor AND
     NOT EXISTS (SELECT 'X'
                 FROM PO_JOB_ASSOCIATIONS
                 WHERE JOB_ID = SELECTED_JOB_ID)
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_DATA_INVALID_REF_JOB', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    LINE_NUMBER, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'NUM', -- TOKEN1_NAME
    DOCUMENT_DISP_LINE_NUMBER, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- VALIDATE LINE TYPE ERROR

  WHEN
  (
    SELECTED_LINE_ORIGINATION_CODE = 'BLANKET' AND
    NOT EXISTS (SELECT  'X'
                FROM  PO_LINE_TYPES_B
                WHERE  LINE_TYPE_ID = SELECTED_LINE_TYPE_ID)
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_DATA_INVALID_REF_LTYP', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    LINE_NUMBER, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'NUM', -- TOKEN1_NAME
    DOCUMENT_DISP_LINE_NUMBER, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- VALIDATE CATEGORY

  WHEN
  (
    SELECTED_LINE_ORIGINATION_CODE = 'BLANKET' AND
    SELECTED_ITEM_ID IS NOT NULL AND
    NOT EXISTS (SELECT  'X'
                        FROM  MTL_ITEM_CATEGORIES MIC,
                              MTL_DEFAULT_SETS_VIEW MDSV,
                              FINANCIALS_SYSTEM_PARAMS_ALL FSP
                       WHERE  MIC.INVENTORY_ITEM_ID = SELECTED_ITEM_ID
                         AND  MIC.ORGANIZATION_ID =
                              FSP.INVENTORY_ORGANIZATION_ID
                         AND  NVL(FSP.ORG_ID, -9999) = NVL(SELECTED_ORG_ID, -9999)
                         AND  MIC.CATEGORY_SET_ID =  MDSV.CATEGORY_SET_ID
                         AND  MDSV.FUNCTIONAL_AREA_ID = 2)
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
      g_interface_type, --INTERFACE_TYPE
      'PON_AUC_DATA_INVALID_REF_CAT', -- ERROR_MESSAGE_NAME
      p_request_id, -- REQUEST_ID
      p_batch_id, --BATCH_ID
      g_auction_item_type, -- ENTITY_TYPE
      p_auction_header_id, -- AUCTION_HEADER_ID
      LINE_NUMBER, -- LINE_NUMBER
      p_expiration_date, -- EXPIRATION_DATE
      'NUM', -- TOKEN1_NAME
      DOCUMENT_DISP_LINE_NUMBER, -- TOKEN1_VALUE
      p_user_id, -- CREATED_BY
      sysdate, -- CREATION_DATE
      p_user_id, -- LAST_UPDATED_BY
      sysdate, -- LAST_UPDATE_DATE
      p_login_id -- LAST_UPDATE_LOGIN
  )

  -- VALIDATE ITEM REVISION

  WHEN
  (
     SELECTED_LINE_ORIGINATION_CODE = 'BLANKET' AND
     SELECTED_ITEM_ID IS NOT NULL AND
     SELECTED_ITEM_REVISION IS NOT NULL AND
     NOT EXISTS (SELECT  'X'
                 FROM  MTL_ITEM_REVISIONS
                 WHERE  REVISION = SELECTED_ITEM_REVISION AND
               INVENTORY_ITEM_ID = SELECTED_ITEM_ID)
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_DATA_INVALID_REF_REV', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    LINE_NUMBER, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'NUM', -- TOKEN1_NAME
    DOCUMENT_DISP_LINE_NUMBER, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- VALIDATE OUTSIDE PROCESSING

  WHEN
  (
    SELECTED_LINE_ORIGINATION_CODE = 'BLANKET' AND
    SELECTED_ITEM_ID IS NOT NULL AND
    NOT EXISTS (SELECT  'X'
                FROM
                MTL_SYSTEM_ITEMS MSI,
                  FINANCIALS_SYSTEM_PARAMS_ALL FSP
                WHERE
                MSI.INVENTORY_ITEM_ID = SELECTED_ITEM_ID AND
                MSI.ORGANIZATION_ID = FSP.INVENTORY_ORGANIZATION_ID AND
                NVL(FSP.ORG_ID, -9999) = NVL(SELECTED_ORG_ID, -9999) AND
                (MSI.OUTSIDE_OPERATION_FLAG <> 'Y'
                              OR (MSI.OUTSIDE_OPERATION_FLAG = 'Y'
                                 AND EXISTS (SELECT  'OP LINE TYPE'
                                               FROM  PO_LINE_TYPES_B PLT
                                              WHERE  PLT.LINE_TYPE_ID = SELECTED_LINE_TYPE_ID
                                                AND  PLT.OUTSIDE_OPERATION_FLAG ='Y') ) ) )
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_INVALID_OP_LINE_REF', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    LINE_NUMBER, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'NUM', -- TOKEN1_NAME
    DOCUMENT_DISP_LINE_NUMBER, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- VALIDATE ITEM PURCHASEABLE

  WHEN
  (
    SELECTED_LINE_ORIGINATION_CODE = 'BLANKET' AND
    SELECTED_ITEM_ID IS NOT NULL AND
    NOT EXISTS (SELECT  'X'
                FROM
                MTL_SYSTEM_ITEMS MSI,
                  FINANCIALS_SYSTEM_PARAMS_ALL FSP
                WHERE
                MSI.INVENTORY_ITEM_ID = SELECTED_ITEM_ID AND
                MSI.PURCHASING_ENABLED_FLAG = 'Y' AND
                MSI.ORGANIZATION_ID = FSP.INVENTORY_ORGANIZATION_ID AND
                NVL(FSP.ORG_ID, -9999) = NVL(SELECTED_ORG_ID, -9999))
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_ITEM_NOT_PURCHASE_REF', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_item_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    LINE_NUMBER, -- LINE_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'NUM', -- TOKEN1_NAME
    DOCUMENT_DISP_LINE_NUMBER, -- TOKEN1_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  SELECT
    PAIP.JOB_ID SELECTED_JOB_ID,
    PAIP.PURCHASE_BASIS SELECTED_PURCHASE_BASIS,
    PAIP.LINE_ORIGINATION_CODE SELECTED_LINE_ORIGINATION_CODE,
    PAIP.LINE_TYPE_ID SELECTED_LINE_TYPE_ID,
    PAIP.ITEM_ID SELECTED_ITEM_ID,
    PAIP.ORG_ID SELECTED_ORG_ID,
    PAIP.ITEM_REVISION SELECTED_ITEM_REVISION,
    PAIP.DOCUMENT_DISP_LINE_NUMBER,
    PAIP.LINE_NUMBER
  FROM
    PON_AUCTION_ITEM_PRICES_ALL PAIP
  WHERE
    PAIP.AUCTION_HEADER_ID = p_auction_header_id;

  INSERT ALL

  -- VALIDATE SHIP TO ORG 1

  WHEN
  (
    SELECTED_SHIP_TO_ORG_ID IS NOT NULL AND
    SELECTED_ITEM_ID IS NOT NULL AND
    SELECTED_ITEM_REVISION IS NOT NULL AND
    SELECTED_SHIP_TO_ORG_ID NOT IN
      (SELECT  OOD.ORGANIZATION_ID
         FROM  ORG_ORGANIZATION_DEFINITIONS OOD,
               MTL_SYSTEM_ITEMS MSI,
               MTL_ITEM_REVISIONS MIR,
               FINANCIALS_SYSTEM_PARAMS_ALL FSP,
               PO_LINE_TYPES_B PLTB
        WHERE  OOD.SET_OF_BOOKS_ID = FSP.SET_OF_BOOKS_ID AND
               FSP.ORG_ID = SELECTED_ORG_ID AND
               PLTB.LINE_TYPE_ID = SELECTED_LINE_TYPE_ID AND
               SYSDATE < NVL(OOD.DISABLE_DATE,SYSDATE+1) AND
               OOD.ORGANIZATION_ID = MIR.ORGANIZATION_ID AND
               MSI.ORGANIZATION_ID = OOD.ORGANIZATION_ID AND
               MSI.PURCHASING_ENABLED_FLAG = 'Y' AND
               MIR.INVENTORY_ITEM_ID = SELECTED_ITEM_ID AND
               MIR.REVISION = SELECTED_ITEM_REVISION AND
               MSI.INVENTORY_ITEM_ID = MIR.INVENTORY_ITEM_ID AND
               ((PLTB.OUTSIDE_OPERATION_FLAG = 'Y' AND
                 MSI.OUTSIDE_OPERATION_FLAG = 'Y') OR PLTB.OUTSIDE_OPERATION_FLAG = 'N'))
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    TOKEN2_NAME, TOKEN2_VALUE, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_DATA_INVALID_SHIPO_REF', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    LINE_NUMBER, -- LINE_NUMBER
    SHIPMENT_NUMBER, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'ITEMNUM', -- TOKEN1_NAME
    DOCUMENT_DISP_LINE_NUMBER, -- TOKEN1_VALUE
    'SHIPNUM', -- TOKEN2_NAME
    SHIPMENT_NUMBER, -- TOKEN2_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- VALIDATE SHIP TO LOC

  WHEN
  (
    SELECTED_SHIP_TO_LOCATION_ID IS NOT NULL AND
    SELECTED_SHIP_TO_LOCATION_ID NOT IN
      (SELECT  LOC.LOCATION_ID
         FROM  HR_LOCATIONS_ALL LOC,
               HR_ALL_ORGANIZATION_UNITS HAOU
        WHERE  HAOU.ORGANIZATION_ID = SELECTED_ORG_ID AND
               NVL (LOC.BUSINESS_GROUP_ID, NVL(HAOU.BUSINESS_GROUP_ID, -99)) = NVL (HAOU.BUSINESS_GROUP_ID, -99) AND
          LOC.SHIP_TO_SITE_FLAG = 'Y' AND
          (SELECTED_SHIP_TO_ORG_ID IS NULL OR
           NVL(LOC.INVENTORY_ORGANIZATION_ID, NVL(SELECTED_SHIP_TO_ORG_ID,-1)) = NVL(SELECTED_SHIP_TO_ORG_ID,-1)) AND SYSDATE < NVL(LOC.INACTIVE_DATE, SYSDATE + 1))
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE, TOKEN2_NAME,
    TOKEN2_VALUE, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_DATA_INVALID_SHIPL_REF', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    LINE_NUMBER, -- LINE_NUMBER
    SHIPMENT_NUMBER, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'ITEMNUM', -- TOKEN1_NAME
    DOCUMENT_DISP_LINE_NUMBER, -- TOKEN1_VALUE
    'SHIPNUM', -- TOKEN2_NAME
    SHIPMENT_NUMBER, -- TOKEN2_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  SELECT
    PAIP.LINE_NUMBER,
    PAIP.DOCUMENT_DISP_LINE_NUMBER,
    PSA.SHIPMENT_NUMBER,
    PSA.SHIP_TO_LOCATION_ID SELECTED_SHIP_TO_LOCATION_ID,
    PSA.SHIP_TO_ORGANIZATION_ID SELECTED_SHIP_TO_ORG_ID,
    PAIP.ORG_ID SELECTED_ORG_ID,
    PAIP.ITEM_ID SELECTED_ITEM_ID,
    PAIP.ITEM_REVISION SELECTED_ITEM_REVISION,
    PAIP.LINE_TYPE_ID SELECTED_LINE_TYPE_ID
  FROM
    PON_AUCTION_SHIPMENTS_ALL PSA,
    PON_AUCTION_ITEM_PRICES_ALL PAIP
  WHERE
    PSA.AUCTION_HEADER_ID = P_AUCTION_HEADER_ID AND
    PAIP.AUCTION_HEADER_ID = P_AUCTION_HEADER_ID AND
    PSA.LINE_NUMBER = PAIP.LINE_NUMBER;

  INSERT ALL

  -- VALIDATE SHIP TO ORG 2

  WHEN
  (
    SELECTED_SHIP_TO_ORG_ID IS NOT NULL AND
    SELECTED_ITEM_ID IS NOT NULL AND
    SELECTED_ITEM_REVISION IS NULL AND
    SELECTED_SHIP_TO_ORG_ID NOT IN
      (SELECT  OOD.ORGANIZATION_ID
         FROM  ORG_ORGANIZATION_DEFINITIONS OOD,
               MTL_SYSTEM_ITEMS_KFV MSI,
               FINANCIALS_SYSTEM_PARAMS_ALL FSP,
               PO_LINE_TYPES_B PLTB
        WHERE  OOD.SET_OF_BOOKS_ID = FSP.SET_OF_BOOKS_ID AND
               FSP.ORG_ID = SELECTED_ORG_ID AND
               PLTB.LINE_TYPE_ID = SELECTED_LINE_TYPE_ID AND
               SYSDATE < NVL(OOD.DISABLE_DATE,SYSDATE+1) AND
               OOD.ORGANIZATION_ID = MSI.ORGANIZATION_ID AND
               MSI.INVENTORY_ITEM_ID = SELECTED_ITEM_ID AND
               MSI.PURCHASING_ENABLED_FLAG = 'Y' AND
               NVL(MSI.OUTSIDE_OPERATION_FLAG, 'N') =
  NVL(PLTB.OUTSIDE_OPERATION_FLAG, 'N'))
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    TOKEN2_NAME, TOKEN2_VALUE, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_DATA_INVALID_SHIPO_REF', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    LINE_NUMBER, -- LINE_NUMBER
    SHIPMENT_NUMBER, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'ITEMNUM', -- TOKEN1_NAME
    DOCUMENT_DISP_LINE_NUMBER, -- TOKEN1_VALUE
    'SHIPNUM', -- TOKEN2_NAME
    SHIPMENT_NUMBER, -- TOKEN2_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  -- VALIDATE SHIP TO ORG 3

  WHEN
  (
    SELECTED_SHIP_TO_ORG_ID IS NOT NULL AND
    SELECTED_ITEM_ID IS NULL AND
    SELECTED_SHIP_TO_ORG_ID NOT IN
      (SELECT  OOD.ORGANIZATION_ID
         FROM  ORG_ORGANIZATION_DEFINITIONS OOD,
               FINANCIALS_SYSTEM_PARAMS_ALL FSP
        WHERE  OOD.SET_OF_BOOKS_ID = FSP.SET_OF_BOOKS_ID AND
               FSP.ORG_ID = SELECTED_ORG_ID AND
               SYSDATE < NVL(OOD.DISABLE_DATE,SYSDATE+1) )
  )
  THEN INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE, AUCTION_HEADER_ID,
    LINE_NUMBER, SHIPMENT_NUMBER, EXPIRATION_DATE, TOKEN1_NAME, TOKEN1_VALUE,
    TOKEN2_NAME, TOKEN2_VALUE, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
  )
  VALUES
  (
    g_interface_type, --INTERFACE_TYPE
    'PON_AUC_DATA_INVALID_SHIPO_REF', -- ERROR_MESSAGE_NAME
    p_request_id, -- REQUEST_ID
    p_batch_id, --BATCH_ID
    g_auction_pbs_type, -- ENTITY_TYPE
    p_auction_header_id, -- AUCTION_HEADER_ID
    LINE_NUMBER, -- LINE_NUMBER
    SHIPMENT_NUMBER, -- SHIPMENT_NUMBER
    p_expiration_date, -- EXPIRATION_DATE
    'ITEMNUM', -- TOKEN1_NAME
    DOCUMENT_DISP_LINE_NUMBER, -- TOKEN1_VALUE
    'SHIPNUM', -- TOKEN2_NAME
    SHIPMENT_NUMBER, -- TOKEN2_VALUE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    p_login_id -- LAST_UPDATE_LOGIN
  )

  SELECT
    PAIP.LINE_NUMBER,
    PAIP.DOCUMENT_DISP_LINE_NUMBER,
    PSA.SHIPMENT_NUMBER,
    PSA.SHIP_TO_ORGANIZATION_ID SELECTED_SHIP_TO_ORG_ID,
    PAIP.ORG_ID SELECTED_ORG_ID,
    PAIP.ITEM_ID SELECTED_ITEM_ID,
    PAIP.ITEM_REVISION SELECTED_ITEM_REVISION,
    PAIP.LINE_TYPE_ID SELECTED_LINE_TYPE_ID
  FROM
    PON_AUCTION_SHIPMENTS_ALL PSA,
    PON_AUCTION_ITEM_PRICES_ALL PAIP
  WHERE
    PSA.AUCTION_HEADER_ID = P_AUCTION_HEADER_ID AND
    PAIP.AUCTION_HEADER_ID = P_AUCTION_HEADER_ID AND
    PSA.LINE_NUMBER = PAIP.LINE_NUMBER;

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_LINE_REF_DATA',
      message  => 'Leaving Procedure');
  END IF; --}

END VAL_LINE_REF_DATA;

PROCEDURE VAL_OUTSIDE_FLAG_EXISTS (
  p_auction_header_id IN NUMBER,
  p_is_global_agreement IN BOOLEAN,
  p_request_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_batch_id IN NUMBER
) IS

l_outside_flag NUMBER;
BEGIN

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_OUTSIDE_FLAG_EXISTS',
      message  => 'Entering Procedure p_auction_header_id = ' || p_auction_header_id);
  END IF; --}

  --VALIDATION FOR OUTSIDE FLAG ONLY
  --IN CASE OF GLOBAL AGREEMENTS

  --ONLY ONE ERROR WILL BE SHOWN SO ROWNUM = 1
  IF (p_is_global_agreement) THEN

    IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'VAL_OUTSIDE_FLAG_EXISTS',
        message  => 'This is a global agreement so validation for outside ops');
    END IF; --}

    INSERT INTO PON_INTERFACE_ERRORS
    (
      INTERFACE_TYPE, ERROR_MESSAGE_NAME, REQUEST_ID, BATCH_ID, ENTITY_TYPE,
      AUCTION_HEADER_ID, EXPIRATION_DATE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
      LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
    )
    SELECT
      g_interface_type, -- INTERFACE_TYPE
      'PON_AUC_GLOBAL_OP_LINE', -- ERROR_MESSAGE_NAME
      p_request_id, -- REQUEST_ID
      p_batch_id, -- BATCH_ID
      g_auction_item_type, -- ENTITY_TYPE
      p_auction_header_id, -- AUCTION_HEADER_ID
      p_expiration_date, -- EXPIRATION_DATE
      p_user_id, -- CREATED_BY
      sysdate, -- CREATION_DATE
      p_user_id, -- LAST_UPDATED_BY
      sysdate, -- LAST_UPDATE_DATE
      p_login_id -- LAST_UPDATE_LOGIN
    FROM
      PO_LINE_TYPES_B PLTB,
      PON_AUCTION_ITEM_PRICES_ALL PAIP
    WHERE
      PAIP.AUCTION_HEADER_ID=p_auction_header_id AND
      PLTB.LINE_TYPE_ID= PAIP.LINE_TYPE_ID AND
      PLTB.OUTSIDE_OPERATION_FLAG='Y' AND
      ROWNUM=1;
  END IF;

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VAL_OUTSIDE_FLAG_EXISTS',
      message  => 'Leaving Procedure');
  END IF; --}
END VAL_OUTSIDE_FLAG_EXISTS;

PROCEDURE validate_complexwork_lines(
  p_auction_header_id     IN NUMBER,
  p_request_id            IN NUMBER,
  p_expiration_date       IN DATE,
  p_user_id               IN NUMBER,
  p_login_id              IN NUMBER,
  p_batch_id              IN NUMBER,
  p_fnd_currency_precision IN NUMBER
                        )
IS
l_contract_type              PON_AUCTION_HEADERS_ALL.contract_type%TYPE;
l_progress_payment_type      PON_AUCTION_HEADERS_ALL.progress_payment_type%TYPE;
l_recoupment_negotiable_flag PON_AUCTION_HEADERS_ALL.recoupment_negotiable_flag%TYPE;
l_advance_negotiable_flag    PON_AUCTION_HEADERS_ALL.advance_negotiable_flag%TYPE;

CURSOR l_proj_cursor IS
  SELECT line_number, document_disp_line_number,
         project_id, project_task_id, project_expenditure_type,
		 project_exp_organization_id, project_expenditure_item_date
  FROM PON_AUCTION_ITEM_PRICES_ALL
  WHERE auction_header_id=p_auction_header_id
  AND project_id IS NOT NULL
  AND project_task_id IS NOT NULL
  AND project_expenditure_type IS NOT NULL
  AND project_exp_organization_id IS NOT NULL
  AND project_expenditure_item_date IS NOT NULL;

BEGIN

SELECT pah.contract_type,
       pah.progress_payment_type,
	   pah.recoupment_negotiable_flag,
	   pah.advance_negotiable_flag
INTO   l_contract_type,
       l_progress_payment_type,
       l_recoupment_negotiable_flag,
       l_advance_negotiable_flag
FROM  pon_auction_headers_all pah
WHERE auction_header_id = p_auction_header_id;

IF l_progress_payment_type <> 'NONE' AND l_contract_type = 'CONTRACT' THEN
  INSERT ALL
  WHEN NOT ((order_type_lookup_code = 'FIXED PRICE' AND purchase_basis = 'SERVICES') OR
   (order_type_lookup_code = 'QUANTITY' AND purchase_basis = 'GOODS'))
   OR po_outside_operation_flag = 'Y' THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 1
    entity_type,                  auction_header_id,                                          line_number,            -- 2
    token1_name,                  token1_value,                                               expiration_date,        -- 3
    created_by,                   creation_date,                                              last_updated_by,        -- 4
    last_update_date,             last_update_login,                                           request_id              -- 5
   )
  VALUES
   (
    g_interface_type,             'PON_LINE_TYPE_INVALID_L',                                  p_batch_id,                      -- 2
    g_auction_item_type,          auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,             -- 4
    p_user_id,                    SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                 p_request_id                    -- 6
   )
  SELECT
       paip.AUCTION_HEADER_ID,
       paip.DOCUMENT_DISP_LINE_NUMBER,
       paip.PURCHASE_BASIS,
       paip.ORDER_TYPE_LOOKUP_CODE,
       paip.line_number s_line_number,
       plt.outside_operation_flag po_outside_operation_flag
  FROM PON_AUCTION_ITEM_PRICES_ALL paip,
       PO_LINE_TYPES plt
  WHERE paip.auction_header_id = p_auction_header_id
  AND   paip.line_type_id = plt.line_type_id (+)
  AND   paip.group_type NOT IN ('GROUP','LOT_LINE');

ELSIF l_contract_type = 'STANDARD' THEN

  INSERT ALL
  WHEN retainage_rate_percent IS NOT NULL AND (retainage_rate_percent < 0 OR retainage_rate_percent > 100) THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_RTNG_RATE_WRONG_L',                                      p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                           s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                    p_expiration_date,             -- 4
    p_user_id,                     SYSDATE,                                                     p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN max_retainage_amount IS NOT NULL AND max_retainage_amount < 0 THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
    )
  VALUES
   (
    g_interface_type,             'PON_MAX_RTNG_WRONG_L',                                       p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                    p_expiration_date,             -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN advance_amount IS NOT NULL AND advance_amount < 0 THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_ADV_AMT_WRONG_L',                                        p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                    p_expiration_date,             -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN progress_pymt_rate_percent IS NOT NULL AND (progress_pymt_rate_percent < 0 OR progress_pymt_rate_percent > 100) then
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_PROG_PYMT_RATE_WRONG_L',                                 p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                    p_expiration_date,             -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )
  WHEN recoupment_rate_percent IS NOT NULL AND (recoupment_rate_percent < 0 OR recoupment_rate_percent > 100) THEN
   INTO pon_interface_errors
   (
    interface_type,             error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,               'PON_RECOUP_RATE_WRONG_L',                                    p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                    p_expiration_date,             -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN progress_pymt_rate_percent IS NOT NULL AND
       PON_BID_VALIDATIONS_PKG.validate_currency_precision(progress_pymt_rate_percent, 2) = 'F' THEN
   INTO pon_interface_errors
   (
    interface_type,             error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id,            -- 6
    token2_name,                  token2_value
   )
  VALUES
   (
    g_interface_type,               'PON_INVALID_RATE_PRECISION_L',                                    p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'ATTRIBUTENAME',              fnd_message.get_string('PON','PON_PROGRESS_PYMT_RATE'),     p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id,                  -- 6
    'LINENUM',                    document_disp_line_number
   )

  WHEN recoupment_rate_percent IS NOT NULL AND
       PON_BID_VALIDATIONS_PKG.validate_currency_precision(recoupment_rate_percent, 2) = 'F' THEN
   INTO pon_interface_errors
   (
    interface_type,             error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id,            -- 6
    token2_name,                  token2_value
   )
  VALUES
   (
    g_interface_type,               'PON_INVALID_RATE_PRECISION_L',                                    p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'ATTRIBUTENAME',              fnd_message.get_string('PON','PON_RECOUPMENT_RATE'),     p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id,                  -- 6
    'LINENUM',                    document_disp_line_number
   )

  WHEN retainage_rate_percent IS NOT NULL AND
       PON_BID_VALIDATIONS_PKG.validate_currency_precision(retainage_rate_percent, 2) = 'F' THEN
   INTO pon_interface_errors
   (
    interface_type,             error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id,            -- 6
    token2_name,                  token2_value
   )
  VALUES
   (
    g_interface_type,               'PON_INVALID_RATE_PRECISION_L',                                    p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'ATTRIBUTENAME',              fnd_message.get_string('PON','PON_RETAINAGE_RATE'),     p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id,                  -- 6
    'LINENUM',                    document_disp_line_number
   )

  WHEN advance_amount IS NOT NULL AND
       PON_BID_VALIDATIONS_PKG.validate_currency_precision(advance_amount, p_fnd_currency_precision) = 'F' THEN
   INTO pon_interface_errors
   (
    interface_type,             error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id,            -- 6
    token2_name,                  token2_value
   )
  VALUES
   (
    g_interface_type,               'PON_LINEAMT_INVALID_PRECISION',                                    p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'ATTRIBUTENAME',              fnd_message.get_string('PON','PON_ADVANCE_AMOUNT_FLAG'),     p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id,                  -- 6
    'LINENUM',                    document_disp_line_number
   )

  WHEN max_retainage_amount IS NOT NULL AND
       PON_BID_VALIDATIONS_PKG.validate_currency_precision(max_retainage_amount, p_fnd_currency_precision) = 'F' THEN
   INTO pon_interface_errors
   (
    interface_type,             error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id,            -- 6
    token2_name,                  token2_value
   )
  VALUES
   (
    g_interface_type,               'PON_LINEAMT_INVALID_PRECISION',                                    p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'ATTRIBUTENAME',              fnd_message.get_string('PON','PON_MAX_RETAINAGE_AMOUNT'),     p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id,                  -- 6
    'LINENUM',                    document_disp_line_number
   )

  WHEN l_progress_payment_type = 'FINANCE' AND progress_pymt_rate_percent IS NULL THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_PROG_PYMT_NEEDED_L',                                 p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                 document_disp_line_number,                                p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN (l_progress_payment_type <> 'NONE' AND
      (po_outside_operation_flag = 'Y' OR
        NOT ((order_type_lookup_code = 'FIXED PRICE' AND purchase_basis = 'SERVICES') OR
             (order_type_lookup_code = 'QUANTITY' AND purchase_basis = 'GOODS'))
      )) THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_LINE_TYPE_INVALID_L',                                    p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,             -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN progress_pymt_rate_percent IS NOT NULL AND
       recoupment_rate_percent IS NULL AND
       l_recoupment_negotiable_flag = 'N' THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,                  auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_RECUP_NEEDED_WITH_PPRATE_L',                             p_batch_id,                      -- 2
    g_auction_item_type,          auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN ((advance_amount IS NOT NULL or l_advance_negotiable_flag = 'Y') AND
        (recoupment_rate_percent IS NULL AND l_recoupment_negotiable_flag = 'N')) THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,                  auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_RECUP_NEEDED_WITH_ADVAMT_L',                             p_batch_id,                      -- 2
    g_auction_item_type,          auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN target_price IS NOT NULL AND advance_amount IS NOT NULL
     AND (advance_amount > nvl(s_quantity,1) * target_price) THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,                  auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_ADV_AMT_MORE_L',                             p_batch_id,                      -- 2
    g_auction_item_type,          auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN l_progress_payment_type = 'ACTUAL' AND recoupment_rate_percent IS NOT NULL
     AND target_price IS NOT NULL
     AND advance_amount IS NOT NULL
     AND (recoupment_rate_percent < (advance_amount * 100)/(nvl(s_quantity,1) * target_price)) THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,                  auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_RECOUP_LESS_THAN_ADV_L',                             p_batch_id,                      -- 2
    g_auction_item_type,          auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN l_progress_payment_type = 'FINANCE' AND recoupment_rate_percent IS NOT NULL
     AND target_price IS NOT NULL AND progress_pymt_rate_percent IS NOT NULL
     AND recoupment_rate_percent < (((((progress_pymt_rate_percent/100) * (SELECT nvl(sum(nvl(p_aps.target_price,0)*nvl(p_aps.quantity,nvl(s_quantity,1))),0)
			                                                                   FROM PON_AUC_PAYMENTS_SHIPMENTS p_aps
																			   WHERE p_aps.auction_header_id=p_auction_header_id
																			   AND p_aps.line_number=s_line_number ))
			                          + NVL(advance_amount,0)) * 100)/((nvl(s_quantity, 1) * target_price)))  THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,                  auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_RECOUP_LESS_THAN_PYMT_L',                             p_batch_id,                      -- 2
    g_auction_item_type,          auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN (pai_project_id IS NOT NULL OR pai_project_task_id IS NOT NULL OR pai_project_exp_org_id IS NOT NULL
        OR pai_project_exp_item_date IS NOT NULL OR pai_project_exp_type IS NOT NULL)
  AND (pai_project_id IS NULL OR pai_project_task_id IS NULL OR pai_project_exp_org_id IS NULL
        OR pai_project_exp_item_date IS NULL OR pai_project_exp_type IS NULL) THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_PROJ_INFO_INCOMPLETE_L',                                    p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )
  SELECT
       paip.AUCTION_HEADER_ID,
       paip.LINE_NUMBER s_line_number,
       paip.DOCUMENT_DISP_LINE_NUMBER,
       paip.ADVANCE_AMOUNT,
       paip.RECOUPMENT_RATE_PERCENT,
       paip.PROGRESS_PYMT_RATE_PERCENT,
       paip.RETAINAGE_RATE_PERCENT,
       paip.MAX_RETAINAGE_AMOUNT,
       paip.TARGET_PRICE,
       paip.QUANTITY s_quantity,
       paip.PROJECT_ID pai_project_id,
       paip.PROJECT_TASK_ID pai_project_task_id,
       paip.PROJECT_AWARD_ID pai_project_award_id,
       paip.PROJECT_EXPENDITURE_TYPE pai_project_exp_type,
       paip.PROJECT_EXP_ORGANIZATION_ID pai_project_exp_org_id,
       paip.PROJECT_EXPENDITURE_ITEM_DATE pai_project_exp_item_date,
       paip.PURCHASE_BASIS,
       paip.ORDER_TYPE_LOOKUP_CODE,
       paip.LINE_ORIGINATION_CODE,
       paip.has_payments_flag,
	   plt.outside_operation_flag po_outside_operation_flag
  FROM PON_AUCTION_ITEM_PRICES_ALL paip,
       PO_LINE_TYPES plt
  WHERE paip.auction_header_id = p_auction_header_id
  AND   paip.line_type_id = plt.line_type_id (+)
  AND   paip.group_type NOT IN ('GROUP','LOT_LINE');


--bug 4933437- split the above sql into 3 because of shared mem high bug
-- the query below will be execute only if work owner populated

INSERT ALL
  WHEN work_approver_user_id IS NOT NULL
  AND NOT EXISTS (SELECT 1
                    FROM PER_WORKFORCE_CURRENT_X  peo,
                         FND_USER fu
                   WHERE fu.user_id = work_approver_user_id
                     AND fu.employee_id = peo.person_id
    			     AND SYSDATE >= nvl(fu.start_date, SYSDATE)
				     AND SYSDATE <= nvl(fu.end_date, SYSDATE) ) THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,                  auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_LIN_OWNER_INVALID_L',                             p_batch_id,                      -- 2
    g_auction_item_type,          auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )
  SELECT
       paip.AUCTION_HEADER_ID,
       paip.LINE_NUMBER s_line_number,
       paip.DOCUMENT_DISP_LINE_NUMBER,
       paip.WORK_APPROVER_USER_ID
  FROM PON_AUCTION_ITEM_PRICES_ALL paip
  WHERE paip.auction_header_id = p_auction_header_id
  AND   paip.WORK_APPROVER_USER_ID IS NOT NULL;


-- the queries below will be excuted only if all the project info has been supplied by user
-- hence even if it takes more memory because of project views, this query will be rarely executed
 INSERT ALL
  WHEN pai_project_id IS NOT NULL
  AND NOT EXISTS(SELECT 1
                 FROM pa_projects_expend_v pro
                 WHERE pro.project_id = pai_project_id) THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_PROJ_NUM_INVALID_L',                                     p_batch_id,                      -- 2
    g_auction_item_type,          auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN pai_project_id IS NOT NULL AND pai_project_task_id IS NOT NULL
  AND NOT EXISTS(SELECT 1
                 FROM pa_tasks_expend_v tas
                 WHERE tas.project_id = pai_project_id
                 AND tas.task_id = pai_project_task_id) THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_PROJ_TASK_INVALID_L',                                    p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN pai_project_id IS NOT NULL
  AND pai_project_task_id IS NOT NULL
  AND pai_project_award_id IS NOT NULL
  AND NOT EXISTS (SELECT 1
                    FROM GMS_AWARDS_BASIC_V award
                   WHERE award.project_id = pai_project_id
                     AND award.task_id = pai_project_task_id
                     AND award.award_id  = pai_project_award_id) THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_PROJ_AWARD_INVALID_L',                                   p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN pai_project_exp_org_id IS NOT NULL
  AND NOT EXISTS (SELECT 1
                    FROM PA_ORGANIZATIONS_EXPEND_V porg
                   WHERE porg.organization_id = pai_project_exp_org_id) THEN

   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_PROJ_EXPORG_INVALID_L',                                  p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

WHEN pai_project_exp_type IS NOT NULL
AND NOT EXISTS (SELECT 1
                FROM pa_expenditure_types_expend_v exptype
                WHERE system_linkage_function = 'VI'
                AND exptype.expenditure_type = pai_project_exp_type
                AND  trunc(sysdate) BETWEEN nvl(exptype.expnd_typ_start_date_active, trunc(sysdate))
                                    AND  nvl(exptype.expnd_typ_end_date_Active, trunc(sysdate))
                AND trunc(sysdate) BETWEEN nvl(exptype.sys_link_start_date_active, trunc(sysdate))
                                    AND  nvl(exptype.sys_link_end_date_Active, trunc(sysdate))) THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_PROJ_EXPTYPE_INVALID_L',                                  p_batch_id,                      -- 2
    g_auction_item_type,            auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  WHEN pai_project_id IS NOT NULL
  AND pai_project_award_id IS NULL
  AND IS_PROJECT_SPONSORED(pai_project_id) = 'Y' THEN
   INTO pon_interface_errors
   (
    interface_type,               error_message_name,                                         batch_id,               -- 2
    entity_type,                  auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login,                                           request_id              -- 6
   )
  VALUES
   (
    g_interface_type,             'PON_PROJ_AWARD_NULL_L',                                     p_batch_id,                      -- 2
    g_auction_item_type,          auction_header_id,                                          s_line_number,     -- 3
    'LINENUM',                    document_disp_line_number,                                  p_expiration_date,                    -- 4
    p_user_id,                     SYSDATE,                                                    p_user_id,                      -- 5
    SYSDATE,                      p_login_id,                                                   p_request_id                     -- 6
   )

  SELECT
       paip.AUCTION_HEADER_ID,
       paip.LINE_NUMBER s_line_number,
       paip.DOCUMENT_DISP_LINE_NUMBER,
       paip.PROJECT_ID pai_project_id,
       paip.PROJECT_TASK_ID pai_project_task_id,
       paip.PROJECT_AWARD_ID pai_project_award_id,
       paip.PROJECT_EXPENDITURE_TYPE pai_project_exp_type,
       paip.PROJECT_EXP_ORGANIZATION_ID pai_project_exp_org_id,
       paip.PROJECT_EXPENDITURE_ITEM_DATE pai_project_exp_item_date
  FROM PON_AUCTION_ITEM_PRICES_ALL paip
  WHERE paip.auction_header_id = p_auction_header_id
  AND   paip.PROJECT_ID IS NOT NULL
  AND   paip.PROJECT_TASK_ID IS NOT NULL
  AND   paip.PROJECT_EXPENDITURE_TYPE IS NOT NULL
  AND   paip.PROJECT_EXP_ORGANIZATION_ID IS NOT NULL
  AND   paip.PROJECT_EXPENDITURE_ITEM_DATE IS NOT NULL;


  --Validate project fields with PATC
    FOR l_proj_record IN l_proj_cursor LOOP
        VALIDATE_PROJECTS_DETAILS (
            p_project_id                => l_proj_record.project_id,
            p_task_id                   => l_proj_record.project_task_id,
            p_expenditure_date          => l_proj_record.project_expenditure_item_date,
            p_expenditure_type          => l_proj_record.project_expenditure_type,
            p_expenditure_org           => l_proj_record.project_exp_organization_id,
            p_person_id                 => null,
            p_auction_header_id         => p_auction_header_id,
            p_line_number               => l_proj_record.line_number,
            p_document_disp_line_number => l_proj_record.document_disp_line_number,
            p_payment_id                => null,
            p_interface_line_id         => null,
            p_payment_display_number    => null,
            p_batch_id                  => p_batch_id,
            p_table_name                => null,
            p_interface_type            => g_interface_type,
            p_entity_type               => g_auction_item_type,
            p_called_from               => 'LINES');
    END LOOP;

   BEGIN

     INSERT INTO PON_INTERFACE_ERRORS
     (
      interface_type,
      error_message_name,
      batch_id,
      entity_type,
      auction_header_id,
      line_number,
      token1_name,
      token1_value,
      token2_name,
      token2_value,
      expiration_date,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      request_id
     )
      SELECT
        g_interface_type, --INTERFACE_TYPE
        'PON_PYMT_NUM_NOT_UNQ', -- ERROR_MESSAGE_NAME
        p_batch_id, --BATCH_ID
        g_auction_item_type, -- ENTITY_TYPE
        paps.auction_header_id, -- AUCTION_HEADER_ID
        paps.line_number, -- LINE_NUMBER
        'PAYITEMNUM', --Token1
        paps.payment_display_number, --token 1 value
        'LINENUM', --Token2
        pai.document_disp_line_number, --token 2 value
        p_expiration_date, -- EXPIRATION_DATE
        p_user_id, -- CREATED_BY
        sysdate, -- CREATION_DATE
        p_user_id, -- LAST_UPDATED_BY
        sysdate, -- LAST_UPDATE_DATE
        p_login_id, -- LAST_UPDATE_LOGIN
        p_request_id --REQUEST_ID
      FROM
        PON_AUC_PAYMENTS_SHIPMENTS paps, PON_AUCTION_ITEM_PRICES_ALL pai
      WHERE paps.auction_header_id=pai.auction_header_id
 	  AND paps.line_number = pai.line_number
	  AND paps.auction_header_id = p_auction_header_id
	  GROUP BY paps.auction_header_id, paps.line_number,
               paps.payment_display_number, pai.document_disp_line_number
	  HAVING count(*) > 1;

  EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module  => g_module_prefix || 'VALIDATE_COMPLEXWORK_LINES',
        message => 'Exception occured in duplicate payitem check of validate_complexwork_lines'
            || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200));
    END IF;
    Raise;
  END;

END IF; -- End of if l_contract_type = 'STANDARD'
END validate_complexwork_lines;

PROCEDURE validate_payments (
  p_auction_header_id     IN NUMBER,
  p_request_id            IN NUMBER,
  p_expiration_date       IN DATE,
  p_user_id               IN NUMBER,
  p_login_id              IN NUMBER,
  p_batch_id              IN NUMBER,
  p_price_precision       IN NUMBER
) IS
l_module CONSTANT VARCHAR2(32) := 'VALIDATE_PAYMENTS';
l_progress              VARCHAR2(200);

CURSOR l_proj_cursor IS
  SELECT paps.payment_display_number, paps.payment_id,
         paps.project_id, paps.project_task_id, paps.project_expenditure_type,
		 paps.project_exp_organization_id, paps.project_expenditure_item_date,
		 paip.line_number, paip.document_disp_line_number
  FROM   PON_AUC_PAYMENTS_SHIPMENTS paps,
         PON_AUCTION_ITEM_PRICES_ALL paip
  WHERE paps.auction_header_id=p_auction_header_id
  AND paps.project_id IS NOT NULL
  AND paps.project_task_id IS NOT NULL
  AND paps.project_expenditure_type IS NOT NULL
  AND paps.project_exp_organization_id IS NOT NULL
  AND paps.project_expenditure_item_date IS NOT NULL
  AND paip.auction_header_id = paps.auction_header_id
  AND paip.line_number = paps.line_number;

BEGIN



  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VALIDATE_PAYMENTS',
      message  => 'Entering PON_NEGOTIATION_PUBLISH_PVT.VALIDATE_PAYMENTS'
                  || ', p_auction_header_id = ' || p_auction_header_id
                  || ', p_request_id = ' || p_request_id
                  || ', p_expiration_date = ' || p_expiration_date
                  || ', p_user_id = ' || p_user_id
                  || ', p_login_id = ' || p_login_id
                  || ', p_batch_id = ' || p_batch_id
                  || ', p_price_precision = ' || p_price_precision);
  END IF; --}

INSERT ALL
WHEN payment_display_number < 1 OR payment_display_number<> ROUND(payment_display_number) THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  'PON_AUCTS_PAYITEM_NUMBER',   NULL,                        'PON_PYMT_NUM_WRONG',           -- 1
  'NUM',                        payment_display_number,       NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
WHEN payment_type_code = 'RATE' AND quantity < 0 THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  'PON_AUCTS_QUANTITY',         NULL,                        'PON_PYMT_QTY_WRONG',           -- 1
  'NUM',                        quantity,                     NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
WHEN target_price IS NOT NULL AND target_price < 0 THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  'PON_AUCTS_TARGET_PRICE',     NULL,                        'PON_PYMT_TPRICE_WRONG',        -- 1
  'NUM',                        target_price,                 NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
WHEN target_price IS NOT NULL
AND PON_BID_VALIDATIONS_PKG.validate_price_precision(target_price, p_price_precision) = 'F' THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  'PON_AUCTS_TARGET_PRICE',     NULL,                        'PON_TARGETPRICE_INVALID_PREC_P',        -- 1
  'NUM',                        target_price,                 NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
WHEN payment_display_number IS NULL THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  'PON_AUCTS_PAYITEM_NUMBER',   NULL,                        'PON_PYMT_NUM_MISSING',         -- 1
  'NUM',                        payment_display_number,       NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
WHEN payment_type_code IS NULL THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                  error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  'PON_AUCTS_PAYITEM_TYPE',     NULL,                        'PON_PYMT_TYPE_NULL',           -- 1
  'TXT',                        payment_type_code,            NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
WHEN payment_description IS NULL THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                  error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  'PON_AUCTS_PAYMENT_DESC',     NULL,                        'PON_PYMT_DESC_NULL',           -- 1
  'TXT',                        payment_description,          NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
WHEN payment_type_code = 'RATE' AND quantity IS NULL THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  'PON_AUCTS_QUANTITY',         NULL,                        'PON_PYMT_QTY_NULL',            -- 1
  'NUM',                        NULL,                         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
WHEN payment_type_code = 'RATE' AND uom_code IS NULL THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                  error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  NULL,                         NULL,                        'PON_PYMT_UOM_NULL',            -- 1
  'TXT',                        NULL,                         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
WHEN nvl(supplier_enterable_pymt_flag,'N') = 'N' AND ship_to_location_id IS NULL THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                  error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  NULL,                         NULL,                        'PON_PYMT_SHIPTO_NULL',            -- 1
  'TXT',                        NULL,                         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
WHEN need_by_date IS NOT NULL AND need_by_date <= pah_close_bidding_date THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  'PON_AUCTS_NEEDBY',           NULL,                        'PON_PYMT_NDATE_LESS_CDATE',    -- 1
  'TIM',                        NULL,                        need_by_date,                   -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
  WHEN work_approver_user_id IS NOT NULL
  AND NOT EXISTS (SELECT 1
                    FROM  PER_WORKFORCE_CURRENT_X peo,
                         FND_USER fu
                   WHERE fu.user_id = work_approver_user_id
                     AND fu.employee_id = peo.person_id
    			     AND SYSDATE >= nvl(fu.start_date, SYSDATE)
				     AND SYSDATE <= nvl(fu.end_date, SYSDATE) ) THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  NULL,                         NULL,                        'PON_PYMT_OWNER_INVALID',    -- 1
  'TIM',                        work_approver_user_id,        NULL,                   -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
  WHEN (s_project_id IS NOT NULL OR s_project_task_id IS NOT NULL OR s_project_exp_org_id IS NOT NULL
        OR s_project_exp_item_date IS NOT NULL OR s_project_exp_type IS NOT NULL)
  AND (s_project_id IS NULL OR s_project_task_id IS NULL OR s_project_exp_org_id IS NULL
        OR s_project_exp_item_date IS NULL OR s_project_exp_type IS NULL) THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                  error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  NULL,                         NULL,                        'PON_PROJ_INFO_INCOMPLETE_P',    -- 1
  'TXT',                        s_project_exp_type,          NULL,                   -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
SELECT
  ppi.project_id s_project_id,
  ppi.project_task_id s_project_task_id,
  ppi.project_expenditure_type s_project_exp_type,
  ppi.project_exp_organization_id s_project_exp_org_id,
  ppi.project_expenditure_item_date s_project_exp_item_date,
  ppi.project_award_id s_project_award_id,
  ppi.payment_display_number,
  ppi.payment_type_code,
  ppi.uom_code,
  ppi.auction_header_id auction_header_id,
  pai.document_disp_line_number,
  ppi.work_approver_user_id,
  ppi.ship_to_location_id,
  ppi.target_price,
  ppi.quantity,
  ppi.payment_description,
  ppi.need_by_date,
  pah.close_bidding_date pah_close_bidding_date,
  pah.supplier_enterable_pymt_flag,
  pai.line_number s_line_number
 FROM PON_AUC_PAYMENTS_SHIPMENTS ppi,
      PON_AUCTION_ITEM_PRICES_ALL pai,
      PON_AUCTION_HEADERS_ALL pah
 WHERE ppi.auction_header_id = pai.auction_header_id
 AND   ppi.line_number = pai.line_number
 AND   pah.auction_header_id = ppi.auction_header_id
 AND   ppi.auction_header_id = p_auction_header_id;


-- Validate projects fields separately because of bug 4933437
INSERT ALL
  WHEN s_project_id IS NOT NULL
  AND NOT EXISTS(SELECT 1
                 FROM pa_projects_expend_v pro
                 WHERE pro.project_id = s_project_id) THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  NULL,                         NULL,                        'PON_PROJ_NUM_INVALID_P',    -- 1
  'TIM',                        NULL,                         NULL,                   -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
  WHEN s_project_id IS NOT NULL AND s_project_task_id IS NOT NULL
  AND NOT EXISTS(SELECT 1
                 FROM pa_tasks_expend_v tas
                 WHERE tas.project_id = s_project_id
                 AND tas.task_id = s_project_task_id) THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  NULL,                         NULL,                        'PON_PROJ_TASK_INVALID_P',    -- 1
  'TIM',                        NULL,                         NULL,                   -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
  WHEN s_project_id IS NOT NULL
  AND s_project_task_id IS NOT NULL
  AND s_project_award_id IS NOT NULL
  AND NOT EXISTS (SELECT 1
                    FROM GMS_AWARDS_BASIC_V award
                   WHERE award.project_id = s_project_id
                     AND award.task_id = s_project_task_id
                     AND award.award_id  = s_project_award_id) THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  NULL,                         NULL,                        'PON_PROJ_AWARD_INVALID_P',    -- 1
  'TIM',                        NULL,                         NULL,                   -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
  WHEN s_project_id IS NOT NULL
  AND s_project_award_id IS NULL
  AND IS_PROJECT_SPONSORED(s_project_id) = 'Y' THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  NULL,                         NULL,                        'PON_PROJ_AWARD_NULL_P',    -- 1
  'TIM',                        NULL,                         NULL,                   -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
  WHEN s_project_exp_org_id IS NOT NULL
  AND NOT EXISTS (SELECT 1
                    FROM PA_ORGANIZATIONS_EXPEND_V porg
                   WHERE porg.organization_id = s_project_exp_org_id) THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  NULL,                         NULL,                        'PON_PROJ_EXPORG_INVALID_P',    -- 1
  'TIM',                        NULL,                         NULL,                   -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
WHEN s_project_exp_type IS NOT NULL
AND NOT EXISTS (SELECT 1
                FROM pa_expenditure_types_expend_v exptype
                WHERE system_linkage_function = 'VI'
                AND exptype.expenditure_type = s_project_exp_type
                AND  trunc(sysdate) BETWEEN nvl(exptype.expnd_typ_start_date_active, trunc(sysdate))
                                    AND  nvl(exptype.expnd_typ_end_date_Active, trunc(sysdate))
                AND trunc(sysdate) BETWEEN nvl(exptype.sys_link_start_date_active, trunc(sysdate))
                                    AND  nvl(exptype.sys_link_end_date_Active, trunc(sysdate))) THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                  error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  NULL,                         NULL,                        'PON_PROJ_EXPTYPE_INVALID_P',    -- 1
  'TXT',                        s_project_exp_type,          NULL,                   -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      g_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   NULL,            g_rfq_pymts_type,              -- 5
  auction_header_id,            s_line_number,    NULL,                          -- 6
  p_expiration_date,                   p_user_id,                     SYSDATE,                       -- 7
  p_user_id,                     SYSDATE,                      p_login_id                      -- 8
 )
SELECT
  ppi.project_id s_project_id,
  ppi.project_task_id s_project_task_id,
  ppi.project_expenditure_type s_project_exp_type,
  ppi.project_exp_organization_id s_project_exp_org_id,
  ppi.project_expenditure_item_date s_project_exp_item_date,
  ppi.project_award_id s_project_award_id,
  ppi.payment_display_number,
  ppi.auction_header_id auction_header_id,
  pai.document_disp_line_number,
  ppi.work_approver_user_id,
  pai.line_number s_line_number
 FROM PON_AUC_PAYMENTS_SHIPMENTS ppi,
      PON_AUCTION_ITEM_PRICES_ALL pai,
      PON_AUCTION_HEADERS_ALL pah
 WHERE ppi.auction_header_id = pai.auction_header_id
 AND   ppi.line_number = pai.line_number
 AND   ppi.auction_header_id = p_auction_header_id
 AND   pah.auction_header_id = pai.auction_header_id
 AND   ppi.project_id  IS NOT NULL
 AND   ppi.project_task_id  IS NOT NULL
 AND   ppi.project_expenditure_type IS NOT NULL
 AND   ppi.project_exp_organization_id IS NOT NULL
 AND   ppi.project_expenditure_item_date IS NOT NULL;

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VALIDATE_PAYMENTS',
      message  => 'Leaving PON_NEGOTIATION_PUBLISH_PVT.VALIDATE_PAYMENTS'
                  || ', p_auction_header_id = ' || p_auction_header_id);
  END IF; --}
  --Validate project fields with PATC
    FOR l_proj_record IN l_proj_cursor LOOP
        VALIDATE_PROJECTS_DETAILS (
            p_project_id                => l_proj_record.project_id,
            p_task_id                   => l_proj_record.project_task_id,
            p_expenditure_date          => l_proj_record.project_expenditure_item_date,
            p_expenditure_type          => l_proj_record.project_expenditure_type,
            p_expenditure_org           => l_proj_record.project_exp_organization_id,
            p_person_id                 => null,
            p_auction_header_id         => p_auction_header_id,
            p_line_number               => l_proj_record.line_number,
            p_document_disp_line_number => l_proj_record.document_disp_line_number,
            p_payment_id                => l_proj_record.payment_id,
            p_interface_line_id         => null,
            p_payment_display_number    => l_proj_record.payment_display_number,
            p_batch_id                  => p_batch_id,
            p_table_name                => null,
            p_interface_type            => g_interface_type,
            p_entity_type               => g_rfq_pymts_type,
            p_called_from               => 'PAYMENTS');
    END LOOP;


EXCEPTION
    WHEN OTHERS THEN

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module  => g_module_prefix || 'VALIDATE_PAYMENTS',
        message => 'Exception occured validate_payments'
            || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200));
    END IF;

END validate_payments;


-- End Validation procedures

PROCEDURE LOAD_DOCTYPE_NAME_DATA
IS

l_doctype_id PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_doctype_group_name PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
BEGIN

  SELECT
    doctype_id,
    doctype_group_name
  BULK COLLECT INTO
    l_doctype_id,
    l_doctype_group_name
  FROM
    pon_auc_doctypes;

  IF (l_doctype_id.COUNT > 0) THEN --{

    FOR x in 1..l_doctype_id.COUNT LOOP

      g_document_type_names (l_doctype_id (x)) := l_doctype_group_name (x);
    END LOOP;
  END IF; --}
END LOAD_DOCTYPE_NAME_DATA;

/*======================================================================
 *  PROCEDURE : LOAD_BIZRULE_DATA
 *  PARAMETERS:
 *              p_doctype_id - The doctype id of the negotiation
 *
 *  COMMENT   : This procedure will load the document rules corresponding
 *              to this doctype_id
 *  EXCEPTION : None
 *======================================================================*/
PROCEDURE LOAD_BIZRULE_DATA (
  p_doctype_id  NUMBER
) IS

l_bizrule_name PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_doctype_rule_required PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
l_doctype_rule_validity PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
BEGIN

  SELECT
    BIZRULE.NAME,
    DOCTYPE_RULE.REQUIRED_FLAG,
    DOCTYPE_RULE.VALIDITY_FLAG
  BULK COLLECT INTO
    l_bizrule_name,
    l_doctype_rule_required,
    l_doctype_rule_validity
  FROM
    PON_AUC_BIZRULES BIZRULE,
    PON_AUC_DOCTYPE_RULES DOCTYPE_RULE
  WHERE
    BIZRULE.BIZRULE_ID = DOCTYPE_RULE.BIZRULE_ID AND
    DOCTYPE_RULE.DOCTYPE_ID = p_doctype_id;

  IF (l_bizrule_name.COUNT <> 0) THEN --{

    FOR x IN 1..l_bizrule_name.COUNT LOOP

       g_document_type_required_rule (l_bizrule_name(x)) := l_doctype_rule_required (x);
       g_document_type_validity_rule (l_bizrule_name(x)) := l_doctype_rule_validity (x);
    END LOOP;
  END IF; --}
END LOAD_BIZRULE_DATA;

--Start Helper Methods

FUNCTION IS_GLOBAL_AGREEMENT (
  p_global_agreement_flag IN VARCHAR2
) RETURN BOOLEAN IS
BEGIN

  IF (p_global_agreement_flag = 'Y') THEN --{

    RETURN TRUE;
  END IF; --}

  RETURN FALSE;
END IS_GLOBAL_AGREEMENT;

--These methods belong to PONNEGHS.pls, keeping them here
--temporarily
PROCEDURE HAS_TEMP_LABOR_LINES (
  p_auction_header_id IN NUMBER,
  x_return_value OUT NOCOPY VARCHAR2
) IS

l_line_number NUMBER;
BEGIN

  SELECT
    LINE_NUMBER
  INTO
    l_line_number
  FROM
    PON_AUCTION_ITEM_PRICES_ALL
  WHERE
    AUCTION_HEADER_ID = p_auction_header_id AND
    PURCHASE_BASIS = 'TEMP LABOR' AND
    ROWNUM = 1;

  x_return_value := 'Y';
EXCEPTION WHEN NO_DATA_FOUND THEN --{
x_return_value := 'N';

END HAS_TEMP_LABOR_LINES;

PROCEDURE SET_ITEM_HAS_CHILDREN_FLAGS (
  p_auction_header_id IN NUMBER,
  p_close_bidding_date IN DATE
) IS
BEGIN
  --HAS_ATTRIBUTES_FLAG, HAS_SHIPMENTS_FLAG, HAS_PRICE_ELEMENTS_FLAG,
  --HAS_BUYER_PFS_FLAG, HAS_PRICE_DIFFERENTIALS_FLAG,HAS_QUANTITY_TIERS
  UPDATE
    PON_AUCTION_ITEM_PRICES_ALL PAIP
  SET
    HAS_ATTRIBUTES_FLAG = NVL(
                 (SELECT 'Y'
                 FROM PON_AUCTION_ATTRIBUTES
                 WHERE AUCTION_HEADER_ID = p_auction_header_id
                 AND LINE_NUMBER = PAIP.LINE_NUMBER
                  AND ROWNUM = 1), 'N'),
    HAS_SHIPMENTS_FLAG = NVL (
                 (SELECT 'Y'
                 FROM PON_AUCTION_SHIPMENTS_ALL
                 WHERE AUCTION_HEADER_ID = p_auction_header_id
                  AND shipment_type = 'PRICE BREAK'
                  AND LINE_NUMBER = PAIP.LINE_NUMBER
                  AND ROWNUM = 1),'N'),
    HAS_PRICE_ELEMENTS_FLAG = NVL (
                 (SELECT 'Y'
                 FROM PON_PRICE_ELEMENTS
                 WHERE AUCTION_HEADER_ID = p_auction_header_id
                  AND LINE_NUMBER = PAIP.LINE_NUMBER
                  AND PF_TYPE = 'SUPPLIER'
                  AND ROWNUM = 1), 'N'),
    HAS_BUYER_PFS_FLAG = NVL (
                 (SELECT 'Y'
                 FROM PON_PRICE_ELEMENTS
                 WHERE AUCTION_HEADER_ID = p_auction_header_id
                  AND LINE_NUMBER = PAIP.LINE_NUMBER
                  AND ROWNUM = 1
                  AND PF_TYPE = 'BUYER'),'N'),
    HAS_PRICE_DIFFERENTIALS_FLAG = NVL (
                 (SELECT 'Y'
                 FROM PON_PRICE_DIFFERENTIALS
                 WHERE AUCTION_HEADER_ID = p_auction_header_id
                  AND LINE_NUMBER = PAIP.LINE_NUMBER
                  AND SHIPMENT_NUMBER = -1
                  AND ROWNUM = 1),'N'),
    HAS_QUANTITY_TIERS = NVL (
                 (SELECT 'Y'
                 FROM PON_AUCTION_SHIPMENTS_ALL
                 WHERE AUCTION_HEADER_ID = p_auction_header_id
                  AND shipment_type = 'QUANTITY BASED'
                  AND LINE_NUMBER = PAIP.LINE_NUMBER
                  AND ROWNUM = 1),'N'),
    CLOSE_BIDDING_DATE = p_close_bidding_date,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID(),
    LAST_UPDATED_BY = FND_GLOBAL.USER_ID()
  WHERE
    AUCTION_HEADER_ID = p_auction_header_id;
END SET_ITEM_HAS_CHILDREN_FLAGS;

--These methods belong to PONNEGHS.pls, keeping them here
--temporarily

PROCEDURE GET_LOT_GRP_MAX_DISP_LINE_NUM (
  p_auction_header_id IN NUMBER,
  p_parent_line_number IN NUMBER,
  x_max_disp_line_number OUT NOCOPY NUMBER
) IS
BEGIN

  SELECT MAX (DISP_LINE_NUMBER)
  INTO x_max_disp_line_number
  FROM PON_AUCTION_ITEM_PRICES_ALL
  WHERE AUCTION_HEADER_ID = p_auction_header_id
  AND PARENT_LINE_NUMBER = p_parent_line_number;

  IF (x_max_disp_line_number IS NULL) THEN
    SELECT DISP_LINE_NUMBER
    INTO x_max_disp_line_number
    FROM PON_AUCTION_ITEM_PRICES_ALL
    WHERE AUCTION_HEADER_ID = p_auction_header_id
    AND LINE_NUMBER = p_parent_line_number;
  END IF;

END GET_LOT_GRP_MAX_DISP_LINE_NUM;

-- End Validation procedures

PROCEDURE VALIDATE_LINES (
  x_result OUT NOCOPY VARCHAR2, --1
  x_error_code OUT NOCOPY VARCHAR2, --2
  x_error_message OUT NOCOPY VARCHAR2, --3
  p_auction_header_id IN NUMBER, --4
  p_doctype_id IN NUMBER, --5
  p_auction_currency_precision IN NUMBER, --6
  p_fnd_currency_precision IN NUMBER, --7
  p_close_bidding_date IN DATE, --8
  p_contract_type IN VARCHAR2, --9
  p_global_agreement_flag IN VARCHAR2, --10
  p_allow_other_bid_currency IN VARCHAR2, --11
  p_bid_ranking IN VARCHAR2,  --12
  p_po_start_date IN DATE, --13
  p_po_end_date IN DATE, --14
  p_trading_partner_id IN NUMBER, --15
  p_full_quantity_bid_code IN VARCHAR2, --16
  p_invitees_count IN NUMBER, --17
  p_bid_list_type IN VARCHAR2, --18
  p_request_id IN NUMBER, -- 19
  p_for_approval IN VARCHAR2, -- 20
  p_user_id IN NUMBER, --21
  p_line_attribute_enabled_flag IN VARCHAR2, --22
  p_pf_type_allowed IN VARCHAR2, --23
  p_progress_payment_type IN VARCHAR2, --24
  p_large_neg_enabled_flag IN VARCHAR2, --25
  p_price_tiers_indicator IN VARCHAR2, --26
  x_batch_id OUT NOCOPY NUMBER --27
)IS

l_is_global_agreement BOOLEAN;

l_expiration_date DATE;
l_user_id NUMBER;
l_login_id NUMBER;
l_batch_id NUMBER;

l_module_name VARCHAR2(30);

BEGIN

  l_module_name := 'validate_lines';

  x_result := FND_API.G_RET_STS_SUCCESS;

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Entering procedure:'
                  || 'p_auction_header_id = ' || p_auction_header_id
                  || ', p_doctype_id = ' || p_doctype_id
                  || ', p_auction_currency_precision = ' || p_auction_currency_precision
                  || ', p_fnd_currency_precision = ' || p_fnd_currency_precision
                  || ', p_close_bidding_date = ' || p_close_bidding_date
                  || ', p_contract_type = ' || p_contract_type
                  || ', p_global_agreement_flag = ' || p_global_agreement_flag
                  || ', p_allow_other_bid_currency = ' || p_allow_other_bid_currency
                  || ', p_bid_ranking = ' || p_bid_ranking
                  || ', p_po_end_date = ' || p_po_end_date
                  || ', p_po_start_date = ' || p_po_start_date
                  || ', p_trading_partner_id = ' || p_trading_partner_id
                  || ', p_full_quantity_bid_code = ' || p_full_quantity_bid_code
                  || ', p_invitees_count = ' || p_invitees_count
                  || ', p_bid_list_type = ' || p_bid_list_type
                  || ', p_request_id = ' || p_request_id
                  || ', p_for_approval = ' || p_for_approval
                  || ', p_user_id = ' || p_user_id
                  || ', p_line_attribute_enabled_flag = ' || p_line_attribute_enabled_flag
                  || ', p_pf_type_allowed = ' || p_pf_type_allowed
                  || ', p_price_tiers_indicator = ' || p_price_tiers_indicator);
  END IF; --}

  -- Load the document related data.
  LOAD_DOCTYPE_NAME_DATA ();
  LOAD_BIZRULE_DATA (p_doctype_id);

  -- Errors will expire after seven days of creation
  l_expiration_date := SYSDATE + 7;

  l_user_id := p_user_id;
  l_login_id := FND_GLOBAL.LOGIN_ID;

  l_is_global_agreement := IS_GLOBAL_AGREEMENT (p_global_agreement_flag);

  SELECT PON_ITEM_PRICES_INTERFACE_S.NEXTVAL
  INTO l_batch_id
  FROM DUAL;

  x_batch_id := l_batch_id;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Validating Lines: Validations that do not require join with po line types');
  END IF; --}

  -- Validations that are done in this procedure do not require a join with
  -- po_line_types_b
  val_item_prices_all (
    p_auction_header_id, p_request_id, l_expiration_date, l_user_id,
    l_login_id, l_batch_id, p_auction_currency_precision,
    p_fnd_currency_precision, p_close_bidding_date, p_contract_type,
    p_global_agreement_flag, p_bid_ranking, p_doctype_id,
    p_invitees_count, p_bid_list_type);

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Validating Lines: Validations that require join with po line types');
  END IF; --}

  -- Validations that are done in this procedure require a join with
  -- po_line_types_b
  val_item_prices_po_lines (
    p_auction_header_id, p_request_id, l_expiration_date, l_user_id,
    l_login_id, l_batch_id, p_doctype_id, p_contract_type, p_global_agreement_flag,
    p_auction_currency_precision, p_fnd_currency_precision);

  /*
   * ATTRIBUTE VALIDATIONS
   */
  -- Attribute validations only if the p_line_attribute_enabled_flag is set to Y
  IF (NVL (p_line_attribute_enabled_flag, 'Y') = 'Y') THEN

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Validation attributes');
    END IF; --}
    val_attributes (
      p_auction_header_id, p_request_id, l_expiration_date, l_user_id,
      l_login_id, l_batch_id, p_full_quantity_bid_code, p_bid_ranking);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Validation attributes for uniqueness withing a line');
    END IF; --}
    val_attr_name_unique(
      p_auction_header_id, p_request_id, l_expiration_date, l_user_id, l_login_id,
      l_batch_id);

    -- Score validations only if the p_line_mas_enabled_flag is set to Y and if it is multi attribute scoring
    -- We are not checking for NVL (p_line_mas_enabled_flag, 'Y') = 'Y' because bid ranking can be set to
    -- MAS only if the condition is true
    IF (p_bid_ranking = 'MULTI_ATTRIBUTE_SCORING') THEN

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || l_module_name,
          message  => 'Validation attribute scores');
      END IF; --}
      val_attr_scores(
        p_auction_header_id, p_request_id, l_expiration_date, l_user_id, l_login_id,
        l_batch_id);

    END IF;
  END IF;

  /*
   * SHIPMENTS VALIDATIONS
   */
  -- Shipment validation only if it is not an RFI and it is a BLANKET OR A CONTRACT
  -- and if price tiers indicator is price breaks, if price tiers indicator is price breaks then
  -- we can assume that negotiation is not an RFI and is either a BLANKET or a CONTRACT
  IF (p_price_tiers_indicator = 'PRICE_BREAKS') THEN

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Validating price breaks');
    END IF; --}
    val_price_breaks (
      p_auction_header_id, p_close_bidding_date, p_request_id, l_expiration_date, l_user_id,
      l_login_id, l_batch_id, p_auction_currency_precision, p_po_start_date, p_po_end_date);

  END IF;

  /*
   * QUANTITY BASED PRICE TIERS VALIDATIONS
   */
  -- Shipment validation only if it is not an RFI
  -- and if price tiers indicator is Quantity based price tiers
  IF (p_price_tiers_indicator = 'QUANTITY_BASED') THEN

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Validating quantity based price tiers');
    END IF; --}
    val_qty_based_price_tiers  (
      p_auction_header_id, p_close_bidding_date, p_request_id, l_expiration_date, l_user_id,
      l_login_id, l_batch_id,p_auction_currency_precision);

  END IF;

  /*
   * PRICE DIFFERENTIALS VALIDATIONS
   */
  -- Price differential validation only if this is an RFI or this is a global agreement
  IF (g_document_type_names (p_doctype_id) = PON_CONTERMS_UTL_PVT.SRC_REQUEST_FOR_INFORMATION OR
      l_is_global_agreement) THEN

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Validating for unique price differentials');
    END IF; --}
    val_pd_unique(
      p_auction_header_id, p_request_id, l_expiration_date, l_user_id, l_login_id,
      l_batch_id);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Validating price differentials');
    END IF; --}
    val_price_differentials(
      p_auction_header_id, p_request_id, l_expiration_date, l_user_id, l_login_id,
      l_batch_id);

  END IF;

  /*
   * COST FACTOR VALIDATIONS
   */
  IF (p_pf_type_allowed <> 'NONE') THEN

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Validating price elements');
    END IF; --}
    val_price_elements (p_auction_header_id, p_request_id, l_expiration_date, l_user_id,
      l_login_id, l_batch_id, p_auction_currency_precision, p_fnd_currency_precision,
      p_trading_partner_id);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Validation for unique price elements');
    END IF; --}
    val_pe_unique (
      p_auction_header_id, p_request_id, l_expiration_date, l_user_id, l_login_id,
      l_batch_id);

  END IF;

  -- Validate party exclusions only if this is not a large negotiation
  IF (nvl (p_large_neg_enabled_flag, 'N') <> 'Y') THEN

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Validating party exclusions:');
    END IF; --}
    val_party_exclusions (
      p_auction_header_id, p_request_id, l_expiration_date, l_user_id, l_login_id, l_batch_id);

  END IF;

  -- The reference data validation should happen only in case of publication
  -- and concurrent flow
  IF ('N' = p_for_approval AND p_request_id IS NOT NULL) THEN
    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Validating reference data');
    END IF; --}
    val_line_ref_data (
      p_auction_header_id, p_request_id, l_expiration_date, l_user_id, l_login_id,
      l_batch_id);
  END IF;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Validation for multi currency aution with amount based lines');
  END IF; --}
  val_line_amount_multi_curr (
    p_auction_header_id, p_allow_other_bid_currency, p_request_id, l_expiration_date,
    l_user_id, l_login_id, l_batch_id);

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Validating if outside operation lines are included in a global agreement');
  END IF; --}
  val_outside_flag_exists (
    p_auction_header_id, l_is_global_agreement, p_request_id, l_expiration_date, l_user_id,
    l_login_id, l_batch_id);

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Validating Complex work fields');
  END IF; --}
  validate_complexwork_lines (
    p_auction_header_id, p_request_id, l_expiration_date, l_user_id, l_login_id,
    l_batch_id, p_fnd_currency_precision);

  IF p_progress_payment_type <> 'NONE' AND p_contract_type = 'STANDARD' THEN
    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'VALIDATE_LINES',
        message  => 'Validating payments:');
    END IF; --}
    VALIDATE_PAYMENTS (p_auction_header_id, p_request_id, l_expiration_date, l_user_id, l_login_id, l_batch_id, p_auction_currency_precision);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module  => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' || x_error_code ||
          ', error_message = ' || x_error_message);
    END IF;

END VALIDATE_LINES;

PROCEDURE LOG_INTERFACE_ERROR (
  p_interface_type IN VARCHAR2,
  p_error_message_name IN VARCHAR2,
  p_token1_name IN VARCHAR2,
  p_token1_value IN VARCHAR2,
  p_token2_name IN VARCHAR2,
  p_token2_value IN VARCHAR2,
  p_request_id IN NUMBER,
  p_auction_header_id IN NUMBER,
  p_expiration_date IN DATE,
  p_user_id IN NUMBER
) IS
BEGIN

  INSERT INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE,
    ERROR_MESSAGE_NAME,
    TOKEN1_NAME,
    TOKEN1_VALUE,
    TOKEN2_NAME,
    TOKEN2_VALUE,
    REQUEST_ID,
    AUCTION_HEADER_ID,
    EXPIRATION_DATE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  )
  VALUES
  (
    p_interface_type, --INTERFACE_TYPE
    p_error_message_name, --ERROR_MESSAGE_NAME
    p_token1_name, -- TOKEN1_NAME
    p_token1_value, --TOKEN1_VALUE
    p_token2_name, --TOKEN2_NAME
    p_token2_value, -- TOKEN2_VALUE
    p_request_id, -- REQUEST_ID
    p_auction_header_id, -- AUCTION_HEADER_ID
    p_expiration_date, -- EXPIRATION_DATE
    p_user_id, -- CREATED_BY
    sysdate, -- CREATION_DATE
    p_user_id, -- LAST_UPDATED_BY
    sysdate, -- LAST_UPDATE_DATE
    FND_GLOBAL.LOGIN_ID -- LAST_UPDATE_LOGIN
  );
END LOG_INTERFACE_ERROR;

FUNCTION CHECK_ACTION_ERRORS_PRESENT (
  p_batch_id IN NUMBER
) RETURN BOOLEAN IS

l_batch_id NUMBER;
BEGIN

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'CHECK_ACTION_ERRORS_PRESENT',
      message  => 'Checking if any errors are present for batch id = ' || p_batch_id);
  END IF; --}

  SELECT
    BATCH_ID
  INTO
    l_batch_id
  FROM
    PON_INTERFACE_ERRORS
  WHERE
    BATCH_ID = p_batch_id AND
    ROWNUM =1;

  RETURN TRUE;

EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN FALSE;

END CHECK_ACTION_ERRORS_PRESENT;

PROCEDURE RETRIEVE_ERRORS_AND_ROLLBACK (
  p_batch_id IN NUMBER
) IS
l_interface_type                           PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_column_name                              PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_table_name                               PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_interface_line_id                        PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_error_message_name                       PON_NEG_COPY_DATATYPES_GRP.VARCHAR2000_TYPE;
l_error_value                              PON_NEG_COPY_DATATYPES_GRP.VARCHAR100_TYPE;
l_created_by                               PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_creation_date                            PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
l_last_updated_by                          PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_last_update_date                         PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
l_last_update_login                        PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_request_id                               PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_entity_type                              PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_entity_attr_name                         PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_error_value_date                         PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
l_error_value_number                       PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_error_value_datatype                     PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
l_auction_header_id                        PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_bid_number                               PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_line_number                              PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_attribute_name                           PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
l_price_element_type_id                    PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_shipment_number                          PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_price_differential_number                PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_expiration_date                          PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
l_token1_name                              PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_token1_value                             PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
l_token2_name                              PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_token2_value                             PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
l_token3_name                              PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_token3_value                             PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
l_token4_name                              PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_token4_value                             PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
l_token5_name                              PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_token5_value                             PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
l_payment_id                               PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_bid_payment_id                           PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
BEGIN

  SELECT
    INTERFACE_TYPE,
    COLUMN_NAME,
    TABLE_NAME,
    INTERFACE_LINE_ID,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    ENTITY_TYPE,
    ENTITY_ATTR_NAME,
    ERROR_VALUE_DATE,
    ERROR_VALUE_NUMBER,
    ERROR_VALUE_DATATYPE,
    AUCTION_HEADER_ID,
    BID_NUMBER,
    LINE_NUMBER,
    ATTRIBUTE_NAME,
    PRICE_ELEMENT_TYPE_ID,
    SHIPMENT_NUMBER,
    PRICE_DIFFERENTIAL_NUMBER,
    EXPIRATION_DATE,
    TOKEN1_NAME,
    TOKEN1_VALUE,
    TOKEN2_NAME,
    TOKEN2_VALUE,
    TOKEN3_NAME,
    TOKEN3_VALUE,
    TOKEN4_NAME,
    TOKEN4_VALUE,
    TOKEN5_NAME,
    TOKEN5_VALUE,
    PAYMENT_ID,
    BID_PAYMENT_ID
  BULK COLLECT INTO
    l_interface_type,
    l_column_name,
    l_table_name,
    l_interface_line_id,
    l_error_message_name,
    l_error_value,
    l_created_by,
    l_creation_date,
    l_last_updated_by,
    l_last_update_date,
    l_last_update_login,
    l_request_id,
    l_entity_type,
    l_entity_attr_name,
    l_error_value_date,
    l_error_value_number,
    l_error_value_datatype,
    l_auction_header_id,
    l_bid_number,
    l_line_number,
    l_attribute_name,
    l_price_element_type_id,
    l_shipment_number,
    l_price_differential_number,
    l_expiration_date,
    l_token1_name,
    l_token1_value,
    l_token2_name,
    l_token2_value,
    l_token3_name,
    l_token3_value,
    l_token4_name,
    l_token4_value,
    l_token5_name,
    l_token5_value,
    l_payment_id,
    l_bid_payment_id
  FROM
    PON_INTERFACE_ERRORS
  WHERE
    BATCH_ID = p_batch_id;

  ROLLBACK;

  FORALL x IN 1..l_interface_type.COUNT
  INSERT INTO PON_INTERFACE_ERRORS
  (
    INTERFACE_TYPE,
    COLUMN_NAME,
    TABLE_NAME,
    BATCH_ID,
    INTERFACE_LINE_ID,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    ENTITY_TYPE,
    ENTITY_ATTR_NAME,
    ERROR_VALUE_DATE,
    ERROR_VALUE_NUMBER,
    ERROR_VALUE_DATATYPE,
    AUCTION_HEADER_ID,
    BID_NUMBER,
    LINE_NUMBER,
    ATTRIBUTE_NAME,
    PRICE_ELEMENT_TYPE_ID,
    SHIPMENT_NUMBER,
    PRICE_DIFFERENTIAL_NUMBER,
    EXPIRATION_DATE,
    TOKEN1_NAME,
    TOKEN1_VALUE,
    TOKEN2_NAME,
    TOKEN2_VALUE,
    TOKEN3_NAME,
    TOKEN3_VALUE,
    TOKEN4_NAME,
    TOKEN4_VALUE,
    TOKEN5_NAME,
    TOKEN5_VALUE,
    PAYMENT_ID,
    BID_PAYMENT_ID
  )
  VALUES
  (
    l_interface_type (x),
    l_column_name (x),
    l_table_name (x),
    p_batch_id,
    l_interface_line_id (x),
    l_error_message_name (x),
    l_error_value (x),
    l_created_by (x),
    l_creation_date (x),
    l_last_updated_by (x),
    l_last_update_date (x),
    l_last_update_login (x),
    l_request_id (x),
    l_entity_type (x),
    l_entity_attr_name (x),
    l_error_value_date (x),
    l_error_value_number (x),
    l_error_value_datatype (x),
    l_auction_header_id (x),
    l_bid_number (x),
    l_line_number (x),
    l_attribute_name (x),
    l_price_element_type_id (x),
    l_shipment_number (x),
    l_price_differential_number (x),
    l_expiration_date (x),
    l_token1_name (x),
    l_token1_value (x),
    l_token2_name (x),
    l_token2_value (x),
    l_token3_name (x),
    l_token3_value (x),
    l_token4_name (x),
    l_token4_value (x),
    l_token5_name (x),
    l_token5_value (x),
    l_payment_id (x),
    l_bid_payment_id (x)
  );

END RETRIEVE_ERRORS_AND_ROLLBACK;

PROCEDURE update_line_flag_seq_closedate (
  x_result OUT NOCOPY VARCHAR,
  x_error_code OUT NOCOPY VARCHAR,
  x_error_message OUT NOCOPY VARCHAR,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_auction_header_id IN NUMBER,
  p_close_bidding_date IN DATE,
  p_stag_closing_enabled_flag IN VARCHAR,
  p_curr_from_line_number IN NUMBER,
  p_curr_to_line_number IN NUMBER
) IS

l_module_name VARCHAR2 (30);
BEGIN

  l_module_name := 'update_line_flag_seq_closedate';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name);
  END IF;

  UPDATE pon_auction_item_prices_all paip
  SET
  -- the max sub line sequence number is set to the greatest
    -- max_sub_line_sequence_number between this round and the
    -- previous round
    max_sub_line_sequence_number = GREATEST (
      (
       SELECT
         NVL (MAX (sub_line_sequence_number),0)
       FROM
         pon_auction_item_prices_all
       WHERE
         auction_header_id=p_auction_header_id AND
         parent_line_number = paip.line_number AND
         group_type IN ('LOT_LINE', 'GROUP_LINE')
      ), NVL(max_sub_line_sequence_number,0))
  WHERE
    auction_header_id = p_auction_header_id AND
    line_number >= p_curr_from_line_number AND
    line_number <= p_curr_to_line_number AND
    group_type IN ('LOT', 'GROUP');

  UPDATE pon_auction_item_prices_all paip
  SET
    close_bidding_date = decode(p_stag_closing_enabled_flag, 'Y', close_bidding_date, p_close_bidding_date),

    -- If the line has any attributes this flag will be Y else N
    has_attributes_flag = NVL(
                 (SELECT 'Y'
                 FROM PON_AUCTION_ATTRIBUTES
                 WHERE AUCTION_HEADER_ID = p_auction_header_id
                 AND LINE_NUMBER = PAIP.LINE_NUMBER
                  AND ROWNUM = 1), 'N'),

    -- If the line has any shipments this flag will be Y else N
    has_shipments_flag = NVL (
                 (SELECT 'Y'
                  FROM pon_auction_shipments_all
                  WHERE auction_header_id = p_auction_header_id
                  AND line_number = paip.line_number
                  AND shipment_type = 'PRICE BREAK'
                  AND rownum = 1),'N'),

    -- If the line has any supplier price factors this flag will be Y else N
    has_price_elements_flag = NVL (
                 (SELECT 'Y'
                 FROM pon_price_elements
                 WHERE auction_header_id = p_auction_header_id
                  AND line_number = paip.line_number
                  AND pf_type = 'SUPPLIER'
                  AND rownum = 1), 'N'),

    -- If the line has any buyer price factors this flag will be Y else N
    has_buyer_pfs_flag = NVL (
                 (SELECT 'Y'
                 FROM pon_price_elements
                 WHERE auction_header_id = p_auction_header_id
                  AND line_number = paip.line_number
                  AND pf_type = 'BUYER'
                  AND rownum = 1),'N'),

    -- If the line has any price differentials this flag will be Y else N
    has_price_differentials_flag = NVL (
                 (SELECT 'Y'
                  FROM pon_price_differentials
                  WHERE auction_header_id = p_auction_header_id
                  AND line_number = paip.line_number
                  AND shipment_number = -1
                  AND rownum = 1),'N'),

     --complex work - If the line has any payments this flag will be Y else N
    has_Payments_flag = NVL(
                 (SELECT 'Y'
                 FROM PON_AUC_PAYMENTS_SHIPMENTS
                 WHERE AUCTION_HEADER_ID = p_auction_header_id
                 AND LINE_NUMBER = PAIP.LINE_NUMBER
                  AND ROWNUM = 1), 'N'),

     --Quantity tiers project - If the line has any quantity based price tiers this flag will be Y else N
    has_quantity_tiers = NVL (
                 (SELECT 'Y'
                 FROM PON_AUCTION_SHIPMENTS_ALL
                 WHERE AUCTION_HEADER_ID = p_auction_header_id
                  AND shipment_type = 'QUANTITY BASED'
                  AND LINE_NUMBER = PAIP.LINE_NUMBER
                  AND ROWNUM = 1),'N'),
     -- Is quantity scored flag is set to Y in case quantity there is a line
     -- attribute for quantity (sequence_number = QUANTITY_SEQ_NUMBER
    is_quantity_scored = NVL (
                 (SELECT 'Y'
                 FROM PON_AUCTION_ATTRIBUTES
                 WHERE AUCTION_HEADER_ID = p_auction_header_id
                 AND LINE_NUMBER = PAIP.LINE_NUMBER
                 AND SEQUENCE_NUMBER = -20
                 AND ROWNUM = 1), 'N'),

     -- Is quantity need by date scored flag is set to Y in case there is a line
     -- attribute for need by date (sequence_number = NEED_BY_DATE_SEQ_NUMBER
    is_need_by_date_scored = NVL (
                 (SELECT 'Y'
                 FROM PON_AUCTION_ATTRIBUTES
                 WHERE AUCTION_HEADER_ID = p_auction_header_id
                 AND LINE_NUMBER = PAIP.LINE_NUMBER
                 AND SEQUENCE_NUMBER = -10
                 AND ROWNUM = 1), 'N'),
    -- standard who columns
    last_update_date = sysdate,
    last_update_login = p_login_id,
    last_updated_by = p_user_id
  WHERE
    auction_header_id = p_auction_header_id AND
    line_number >= p_curr_from_line_number AND
    line_number <= p_curr_to_line_number;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' || x_error_code || ', error_message = ' || x_error_message);
    END IF;

END update_line_flag_seq_closedate;

PROCEDURE process_price_factors (p_auction_header_id IN NUMBER,
                                p_user_id           IN NUMBER,
                                p_login_id          IN NUMBER,
                                p_from_line_number IN NUMBER,
                                p_to_line_number IN NUMBER) IS

l_module_name VARCHAR2(30);
BEGIN

  l_module_name := 'process_price_factors';
  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entering procedure = ' || l_module_name);
  END IF;

  MERGE INTO pon_price_elements ppe
  USING
  (
    SELECT
      auction_header_id,
      line_number,
      order_type_lookup_code,
      unit_target_price,
      unit_display_target_flag
    FROM
      pon_auction_item_prices_all
    WHERE
      auction_header_id = p_auction_header_id AND
      (has_price_elements_flag = 'Y' OR has_buyer_pfs_flag = 'Y') AND
      line_number >= p_from_line_number AND
      line_number <= p_to_line_number
  )paip

  ON
  (
    paip.auction_header_id = ppe.auction_header_id AND
    paip.line_number = ppe.line_number AND
    ppe.price_element_type_id = -10
  )

  WHEN MATCHED THEN UPDATE
  SET
    pricing_basis = decode(paip.order_type_lookup_code, 'FIXED PRICE', 'FIXED_AMOUNT', 'PER_UNIT'),
    value = paip.unit_target_price,
    display_target_flag = unit_display_target_flag,
    last_update_date = sysdate,
    last_updated_by = p_user_id

  WHEN NOT MATCHED THEN INSERT
  (
    auction_header_id,
    line_number,
    list_id,
    price_element_type_id,
    pricing_basis,
    value,
    display_target_flag,
    sequence_number,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    pf_type,
    display_to_suppliers_flag
  )
  VALUES
  (
    paip.auction_header_id,
    paip.line_number,
    -1,
    -10,
    decode(paip.order_type_lookup_code, 'FIXED PRICE', 'FIXED_AMOUNT', 'PER_UNIT'),
    paip.unit_target_price,
    paip.unit_display_target_flag,
    -10,
    sysdate,
    p_user_id,
    sysdate,
    p_user_id,
    'SUPPLIER',
    'Y'
  );

  -- Populate the pon_pf_supplier_formula table

  MERGE INTO pon_pf_supplier_formula ppsf
  USING
  (
    SELECT
      paip.auction_header_id,
      paip.line_number,
      pbp.trading_partner_id,
      pbp.vendor_site_id,
      pbp.requested_supplier_id,
      sum(decode(ppe.pricing_basis, 'PER_UNIT', ppsv.value, 0)) unit_price,
      sum(decode(ppe.pricing_basis, 'FIXED_AMOUNT', ppsv.value, 0)) fixed_amount,
      1 + sum(decode(ppe.pricing_basis, 'PERCENTAGE', ppsv.value/100, 0)) percentage
    from
      pon_auction_item_prices_all paip,
      pon_bidding_parties pbp,
      pon_pf_supplier_values ppsv,
      pon_price_elements ppe
    where
      paip.auction_header_id = p_auction_header_id and
      pbp.auction_header_id = paip.auction_header_id and
      pbp.auction_header_id = ppsv.auction_header_id and
      paip.line_number >= p_from_line_number and
      paip.line_number <= p_to_line_number and
      pbp.sequence = ppsv.supplier_seq_number and
      paip.line_number = ppsv.line_number and
      ppsv.auction_header_id = ppe.auction_header_id and
      ppsv.line_number = ppe.line_number and
      ppsv.pf_seq_number = ppe.sequence_number
    group by
      paip.auction_header_id,
      paip.line_number,
      pbp.trading_partner_id,
      pbp.vendor_site_id,
      pbp.requested_supplier_id
  ) pfsdata
  ON
  (
    pfsdata.auction_header_id = ppsf.auction_header_id and
    pfsdata.line_number = ppsf.line_number and
    (pfsdata.trading_partner_id = ppsf.trading_partner_id
      OR pfsdata.requested_supplier_id = ppsf.requested_supplier_id) and
    pfsdata.vendor_site_id = ppsf.vendor_site_id
  )
  WHEN MATCHED THEN UPDATE
  SET
    unit_price = pfsdata.unit_price,
    fixed_amount = pfsdata.fixed_amount,
    percentage = pfsdata.percentage,
    last_update_date = sysdate,
    last_updated_by = p_user_id,
    last_update_login = p_login_id
  WHEN NOT MATCHED THEN INSERT
  (
    auction_header_id,
    line_number,
    trading_partner_id,
    vendor_site_id,
    requested_supplier_id,
    unit_price,
    fixed_amount,
    percentage,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  )
  VALUES
  (
    pfsdata.auction_header_id,
    pfsdata.line_number,
    pfsdata.trading_partner_id,
    pfsdata.vendor_site_id,
    pfsdata.requested_supplier_id,
    pfsdata.unit_price,
    pfsdata.fixed_amount,
    pfsdata.percentage,
    sysdate,
    p_user_id,
    sysdate,
    p_user_id,
    p_login_id
  );

END PROCESS_PRICE_FACTORS;

--Complex work
-- This procedure processes a batch of payments
PROCEDURE Process_Payments_batch (
  x_result OUT NOCOPY VARCHAR,
  x_error_code OUT NOCOPY VARCHAR,
  x_error_message OUT NOCOPY VARCHAR,
  p_auction_header_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_curr_from_line_number IN NUMBER,
  p_curr_to_line_number IN NUMBER
) IS

l_module_name VARCHAR2 (30);

BEGIN

  l_module_name := 'process_payments_batch';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name);
  END IF;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Update Payments Fields = ' || l_module_name);
  END IF;

  UPDATE pon_auc_payments_shipments pay
  SET
    SHIP_TO_LOCATION_ID = null,
    WORK_APPROVER_USER_ID = null,
    NOTE_TO_BIDDERS = null,
    PROJECT_ID = null,
    PROJECT_TASK_ID = null,
    PROJECT_AWARD_ID = null,
    PROJECT_EXPENDITURE_TYPE = null,
    PROJECT_EXP_ORGANIZATION_ID = null,
    PROJECT_EXPENDITURE_ITEM_DATE = null,
    -- standard who columns
    last_update_date = sysdate,
    last_update_login = p_login_id,
    last_updated_by = p_user_id
  WHERE
    auction_header_id = p_auction_header_id  AND
    line_number >= p_curr_from_line_number AND
    line_number <= p_curr_to_line_number;

   IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Before call Delete_Payment_Attachments = ' || l_module_name);
   END IF;


   PON_NEGOTIATION_HELPER_PVT.Delete_Payment_Attachments(
      p_auction_header_id => p_auction_header_id,
      p_curr_from_line_number => p_curr_from_line_number,
      p_curr_to_line_number => p_curr_to_line_number);

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'After Call Delete_Payment_Attachments = ' || l_module_name);
   END IF;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' || x_error_code || ', error_message = ' || x_error_message);
    END IF;

END Process_Payments_batch;

--Complex work
-- This procedure processes a batch of payments
PROCEDURE Process_Payments_auto (
  x_result OUT NOCOPY VARCHAR,
  x_error_code OUT NOCOPY VARCHAR,
  x_error_message OUT NOCOPY VARCHAR,
  p_auction_header_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER,
  p_curr_from_line_number IN NUMBER,
  p_curr_to_line_number IN NUMBER
) IS
  PRAGMA AUTONOMOUS_TRANSACTION;

l_module_name VARCHAR2 (30);

BEGIN

  l_module_name := 'process_payments_auto';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name);
  END IF;

    Process_Payments_batch (
     x_result => x_result ,
     x_error_code => x_error_code ,
     x_error_message => x_error_message ,
     p_auction_header_id => p_auction_header_id ,
     p_user_id => p_user_id ,
     p_login_id => p_login_id ,
     p_curr_from_line_number => p_curr_from_line_number ,
     p_curr_to_line_number => p_curr_to_line_number);

     IF (x_result <> FND_API.g_ret_sts_success) THEN
      ROLLBACK;
      return;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Commiting data for lines between ' || p_curr_from_line_number || ' and ' || p_curr_to_line_number);
    END IF; --}

    COMMIT;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);
    Rollback;

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' || x_error_code || ', error_message = ' || x_error_message);
    END IF;

END Process_Payments_auto;

--Complex work
-- This procedure nullifies the attributes that should not be populated
--if a supplier is allowed to enter payments and also deletes the attachments to
-- those payments for a batch of lines
PROCEDURE Process_Payments (
  x_result OUT NOCOPY VARCHAR,
  x_error_code OUT NOCOPY VARCHAR,
  x_error_message OUT NOCOPY VARCHAR,
  p_auction_header_id IN NUMBER,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER
) IS


l_module_name VARCHAR2 (30);
l_max_line_number NUMBER;
l_batch_start NUMBER;
l_batch_end NUMBER;
l_batch_size NUMBER;

BEGIN

  l_module_name := 'process_payments';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name);
  END IF;

  l_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;

   SELECT NVL (MAX (line_number), 0)
   INTO l_max_line_number
   FROM pon_auction_item_prices_all
   WHERE auction_header_id = p_auction_header_id;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Update Payments Fields = ' || l_module_name);
  END IF;

  -- Define the initial batch range (line numbers are indexed from 1)
  l_batch_start := 1;

  --determine the max line number for this batch
  IF (l_max_line_number <= l_batch_size) THEN
    l_batch_end := l_max_line_number;
       IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'before call to  Process_Payments_batch  l_curr_to_line_number = ' || l_batch_end ||
                    ' p_auction_header_id = ' || p_auction_header_id ||
                    ', p_user_id = ' || p_user_id ||
                    ', p_login_id = ' || p_login_id ||
                    ', p_curr_from_line_number = ' || l_batch_start ||
                    ', p_curr_to_line_number = ' || l_batch_end);
    END IF; --}

   Process_Payments_batch (
     x_result => x_result ,
     x_error_code => x_error_code ,
     x_error_message => x_error_message ,
     p_auction_header_id => p_auction_header_id ,
     p_user_id => p_user_id ,
     p_login_id => p_login_id ,
     p_curr_from_line_number => l_batch_start ,
     p_curr_to_line_number => l_batch_end);


   IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'After Call Process_Payments_batch = ' || l_module_name);
    END IF;


  ELSE
    l_batch_end := l_batch_size;

  -- loop for each batch
  WHILE (l_batch_start <= l_max_line_number) LOOP --{

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'before call to  Process_Payments_auto  l_curr_to_line_number = ' || l_batch_end ||
                    ' p_auction_header_id = ' || p_auction_header_id ||
                    ', p_user_id = ' || p_user_id ||
                    ', p_login_id = ' || p_login_id ||
                    ', p_curr_from_line_number = ' || l_batch_start ||
                    ', p_curr_to_line_number = ' || l_batch_end);
    END IF; --}

   Process_Payments_auto (
     x_result => x_result ,
     x_error_code => x_error_code ,
     x_error_message => x_error_message ,
     p_auction_header_id => p_auction_header_id ,
     p_user_id => p_user_id ,
     p_login_id => p_login_id ,
     p_curr_from_line_number => l_batch_start ,
     p_curr_to_line_number => l_batch_end);


   IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'After Call Process_Payments_auto = ' || l_module_name);
    END IF;

   IF (x_result <> FND_API.g_ret_sts_success) THEN
      return;
    END IF;

    -- Find the new batch range
    l_batch_start := l_batch_end + 1;
    IF (l_batch_end + l_batch_size > l_max_line_number) THEN
      l_batch_end := l_max_line_number;
    ELSE
      l_batch_end := l_batch_end + l_batch_size;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Calculated new l_curr_from_line_number = ' || l_batch_start);
    END IF; --}

  END LOOP; --}

 END IF;--}
  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' || x_error_code || ', error_message = ' || x_error_message);
    END IF;

END Process_Payments;

PROCEDURE update_header_before_publish (
  x_result OUT NOCOPY VARCHAR,
  x_error_code OUT NOCOPY VARCHAR,
  x_error_message OUT NOCOPY VARCHAR,
  p_auction_header_id IN NUMBER
) IS

l_line_number NUMBER;
l_attributes_exist VARCHAR2(30);
l_has_price_elements VARCHAR2(30);
l_has_pe_for_all_items VARCHAR2(30);
l_module_name VARCHAR2(30);

BEGIN
  l_module_name := 'update_header_before_publish';
  x_result := FND_API.G_RET_STS_SUCCESS;

--MAX_DOCUMENT_LINE_NUMBER and MAX_INTERNAL_LINE_NUMBER on the header
--HAS_ATTRIBUTES_FLAG, HAS_PRICE_ELEMENTS_FLAG, HAS_PE_FOR_ALL_ITEMS
  BEGIN
    SELECT 'YES'
    INTO l_attributes_exist
    FROM PON_AUCTION_ATTRIBUTES
    WHERE AUCTION_HEADER_ID = p_auction_header_id
    AND ROWNUM = 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN --{
      l_attributes_exist := 'NONE';
  END;

  IF (l_attributes_exist = 'YES') THEN --{
    BEGIN
      SELECT 'BOTH'
      INTO l_attributes_exist
      FROM PON_AUCTION_ATTRIBUTES
      WHERE AUCTION_HEADER_ID = p_auction_header_id
      AND MANDATORY_FLAG = 'Y'
      AND ROWNUM = 1;

      EXCEPTION WHEN NO_DATA_FOUND THEN --{
        l_attributes_exist := 'OPTIONAL';
    END;
  END IF; --}

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Done getting the flag l_attributes_exist = ' || l_attributes_exist);
  END IF; --}

  BEGIN

    SELECT 'Y'
    INTO l_has_price_elements
    FROM PON_PRICE_ELEMENTS
    WHERE AUCTION_HEADER_ID = p_auction_header_id
    AND ROWNUM = 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN --{
      l_has_price_elements := 'N';
  END;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Done getting the flag l_has_price_elements = ' || l_has_price_elements);
  END IF; --}

  IF (l_has_price_elements = 'Y') THEN --{

    BEGIN
      SELECT 'N'
      INTO l_has_pe_for_all_items
      FROM PON_AUCTION_ITEM_PRICES_ALL PAIP
      WHERE PAIP.AUCTION_HEADER_ID = P_AUCTION_HEADER_ID AND
      HAS_PRICE_ELEMENTS_FLAG = 'N' AND
      HAS_BUYER_PFS_FLAG = 'N' AND
      ROWNUM = 1;

      EXCEPTION WHEN NO_DATA_FOUND THEN --{
        l_has_pe_for_all_items := 'Y';
    END;
  ELSE

    l_has_pe_for_all_items := 'N';
  END IF; --}

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Done getting the flag l_has_pe_for_all_items = ' || l_has_pe_for_all_items);
  END IF; --}


  UPDATE
    PON_AUCTION_HEADERS_ALL PAHA
  SET
    ATTRIBUTES_EXIST = l_attributes_exist,
    HAS_PRICE_ELEMENTS = l_has_price_elements,
    HAS_PE_FOR_ALL_ITEMS = l_has_pe_for_all_items,
    MAX_INTERNAL_LINE_NUM = GREATEST (NVL (PAHA.MAX_INTERNAL_LINE_NUM,0),
                                         (SELECT
                                            MAX(PAIP.LINE_NUMBER)
                                          FROM
                                            PON_AUCTION_ITEM_PRICES_ALL PAIP
                                          WHERE
                                            PAIP.AUCTION_HEADER_ID = p_auction_header_id)),
    MAX_DOCUMENT_LINE_NUM = GREATEST (NVL (PAHA.MAX_DOCUMENT_LINE_NUM,0),
                                         (SELECT
                                            MAX(PAIP.SUB_LINE_SEQUENCE_NUMBER)
                                          FROM
                                            PON_AUCTION_ITEM_PRICES_ALL PAIP
                                          WHERE
                                            PAIP.GROUP_TYPE IN ('LOT', 'GROUP', 'LINE')
                                            AND PAIP.AUCTION_HEADER_ID = p_auction_header_id))
  WHERE
    PAHA.AUCTION_HEADER_ID = p_auction_header_id;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' ||
              x_error_code || ', error_message = ' || x_error_message);
    END IF;

END update_header_before_publish;

PROCEDURE update_lines_before_publish (
  x_result OUT NOCOPY VARCHAR,
  x_error_code OUT NOCOPY VARCHAR,
  x_error_message OUT NOCOPY VARCHAR,
  p_auction_header_id IN NUMBER,
  p_close_bidding_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER
) IS

l_large_neg_enabled_flag VARCHAR2(2);
l_complete_flag VARCHAR2(2);
l_stag_closing_enabled_flag VARCHAR2(1);

l_max_line_number NUMBER;
l_batch_start NUMBER;
l_batch_end NUMBER;
l_supplier_payments PON_AUCTION_HEADERS_ALL.SUPPLIER_ENTERABLE_PYMT_FLAG%TYPE;

l_batch_size NUMBER;
l_module_name VARCHAR2(30);
BEGIN

  l_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
  l_module_name := 'update_lines_before_publish';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Batch size is = ' || l_batch_size);
  END IF; --}

  SELECT large_neg_enabled_flag, complete_flag, supplier_enterable_pymt_flag,
       nvl2(staggered_closing_interval,'Y','N')
  INTO l_large_neg_enabled_flag, l_complete_flag, l_supplier_payments,
       l_stag_closing_enabled_flag
  FROM pon_auction_headers_all
  WHERE auction_header_id = p_auction_header_id;

  SELECT NVL (MAX (line_number), 0)
  INTO l_max_line_number
  FROM pon_auction_item_prices_all
  WHERE auction_header_id = p_auction_header_id;

  -- clean up from any previous failures

  -- delete data from pon_pf_supplier_values before
  -- calling the pon_lrg_draft_to_ord_pf_copy procedure to populate it again
  -- Only for large auctions

  IF (l_large_neg_enabled_flag = 'Y') THEN
    DELETE FROM
      pon_pf_supplier_values
    WHERE
      auction_header_id = p_auction_header_id;
  END IF;

  -- clean up the pon_price_elements table of any line type price elements:
  -- why we need a clean up?
  -- a. After a failure the user might have deleted all price elements from a line, in which case this row should not be present
  -- b. After a failure the user might have deleted the line (the price element row will not have a parent ...) and created another
  --    (we reuse the line numbers)

  DELETE FROM
    pon_price_elements
  WHERE
    auction_header_id = p_auction_header_id and
    price_element_type_id = -10;

  -- clean up the pon_pf_supplier_formula table of any rows for this auction:
  -- why we need a clean up?
  -- a. After a failure the user might have deleted all price elements from a line

  DELETE FROM
    pon_pf_supplier_formula
  WHERE
    auction_header_id = p_auction_header_id;

  COMMIT;

  -- calling update_line_flag_seq_closedate process_price_factors, pon_lrg_draft_to_ord_pf_copy
  -- in batches

  -- Define the initial batch range (line numbers are indexed from 1)
  l_batch_start := 1;

  --determine the max line number for this batch
  IF (l_max_line_number <= l_batch_size) THEN
    l_batch_end := l_max_line_number;
  ELSE
    l_batch_end := l_batch_size;
  END IF;

  -- loop for each batch
  WHILE (l_batch_start <= l_max_line_number) LOOP --{

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Calculated new l_curr_to_line_number = ' || l_batch_end ||
                    ' Calling process_price_factors, pon_lrg_draft_to_ord_pf_copy '||
                    ' and update_line_flag_seq_closedate with' ||
                    ' p_auction_header_id = ' || p_auction_header_id ||
                    ', p_user_id = ' || p_user_id ||
                    ', p_login_id = ' || p_login_id ||
                    ', p_curr_from_line_number = ' || l_batch_start ||
                    ', p_curr_to_line_number = ' || l_batch_end);
    END IF; --}

    -- set the flags, sequences and close data on the lines

    update_line_flag_seq_closedate (
      x_result => x_result,
      x_error_code => x_error_code,
      x_error_message => x_error_message,
      p_user_id => p_user_id,
      p_login_id => p_login_id,
      p_auction_header_id => p_auction_header_id,
      p_close_bidding_date => p_close_bidding_date,
      p_stag_closing_enabled_flag => l_stag_closing_enabled_flag,
      p_curr_from_line_number => l_batch_start,
      p_curr_to_line_number => l_batch_end);

    IF (x_result <> FND_API.g_ret_sts_success) THEN
      return;
    END IF;

    -- in case of a large auction call this procedure

    IF ('Y' = l_large_neg_enabled_flag) THEN
      PON_NEGOTIATION_COPY_GRP.pon_lrg_draft_to_ord_pf_copy (
        p_source_auction_hdr_id => p_auction_header_id,
        p_destination_auction_hdr_id => p_auction_header_id,
        p_user_id => p_user_id,
        p_from_line_number => l_batch_start,
        p_to_line_number => l_batch_end);
    END IF;

    -- populate the pon_price_elements table and the pon_pf_supplier_formula table (MERGE)

    process_price_factors (
      p_auction_header_id => p_auction_header_id,
      p_user_id => p_user_id,
      p_login_id => p_login_id,
      p_from_line_number => l_batch_start,
      p_to_line_number => l_batch_end);

    IF (x_result <> FND_API.g_ret_sts_success) THEN
      return;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Commiting data for lines between ' || l_batch_start || ' and ' || l_batch_end);
    END IF; --}

    COMMIT;

    -- Find the new batch range
    l_batch_start := l_batch_end + 1;
    IF (l_batch_end + l_batch_size > l_max_line_number) THEN
      l_batch_end := l_max_line_number;
    ELSE
      l_batch_end := l_batch_end + l_batch_size;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Calculated new l_curr_from_line_number = ' || l_batch_start);
    END IF; --}

  END LOOP; --}

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' || x_error_code || ', error_message = ' || x_error_message);
    END IF;
END update_lines_before_publish;

PROCEDURE update_before_publish (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER,
  p_close_bidding_date IN DATE,
  p_user_id IN NUMBER,
  p_login_id IN NUMBER
) IS

l_module_name VARCHAR2 (30);
BEGIN

  l_module_name := 'update_before_publish';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name);
  END IF;

  -- set the auction_status to draft and the complete flag to Y

  UPDATE
    pon_auction_headers_all
  SET
    auction_status = 'DRAFT',
    last_updated_by = p_user_id,
    last_update_date = sysdate
  WHERE
    auction_header_id = p_auction_header_id;

  -- update the lines
  update_lines_before_publish (
    x_result,
    x_error_code,
    x_error_message,
    p_auction_header_id,
    p_close_bidding_date,
    p_user_id,
    p_login_id);

  IF (x_result <> FND_API.g_ret_sts_success) THEN
    return;
  END IF;

  -- update the header
  update_header_before_publish (
    x_result,
    x_error_code,
    x_error_message,
    p_auction_header_id);

  IF (x_result <> FND_API.g_ret_sts_success) THEN
    return;
  END IF;

  -- set the auction_status to active and the complete flag to Y

  UPDATE
    pon_auction_headers_all
  SET
    auction_status = 'ACTIVE',
    last_updated_by = p_user_id,
    last_update_date = sysdate
  WHERE
    auction_header_id = p_auction_header_id;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' || x_error_code || ', error_message = ' || x_error_message);
    END IF;
END update_before_publish;

PROCEDURE report_concurrent_failure (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_request_id IN NUMBER,
  p_user_name IN VARCHAR2,
  p_auction_header_id IN NUMBER,
  p_program_type_code IN VARCHAR2
) IS

l_module_name VARCHAR2 (30);
BEGIN

  l_module_name := 'report_concurrent_failure';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name);
  END IF;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'report_concurrent_failure',
      message  => 'Calling the notification genration procedure to inform failure'
                  || ', p_request_id = ' || p_request_id
                  || ', p_messagetype = ' || 'E'
                  || ', p_RecepientUsername = ' || p_user_name
                  || ', p_recepientType = ' || 'BUYER'
                  || ', p_auction_header_id = ' || p_auction_header_id
                  || ', p_ProgramTypeCode = ' || p_program_type_code
                  || ', p_DestinationPageCode = ' || 'PON_CONCURRENT_ERRORS'
                  || ', p_bid_number = NULL');
  END IF; --}

  PON_WF_UTL_PKG.ReportConcProgramStatus (
    p_request_id => p_request_id,
    p_messagetype => 'E',
    p_RecepientUsername => p_user_name,
    p_recepientType =>'BUYER',
    p_auction_header_id => p_auction_header_id,
    p_ProgramTypeCode => p_program_type_code,
    p_DestinationPageCode => 'PON_CONCURRENT_ERRORS',
    p_bid_number => NULL);

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' ||
                  x_error_code || ', error_message = ' || x_error_message);
    END IF;

END report_concurrent_failure;

PROCEDURE report_concurrent_success (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_request_id IN NUMBER,
  p_user_name IN VARCHAR2,
  p_auction_header_id IN NUMBER,
  p_program_type_code IN VARCHAR2
) IS

l_module_name VARCHAR2 (30);
l_destination_page_code VARCHAR2(30);
BEGIN

  l_module_name := 'report_concurrent_success';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name);
  END IF;

  -- The destination code in case of succesful approval submission
  -- will be the manage drafts page.
  IF (p_program_type_code = g_program_type_neg_approve) THEN
    l_destination_page_code := 'PON_MANAGE_DRAFT_NEG';
  ELSE
    l_destination_page_code := 'PON_NEG_SUMMARY';
  END IF;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Calling the notification genration procedure to inform success'
                  || ', p_request_id = ' || p_request_id
                  || ', p_messagetype = ' || 'S'
                  || ', p_RecepientUsername = ' || p_user_name
                  || ', p_recepientType = ' || 'BUYER'
                  || ', p_auction_header_id = ' || p_auction_header_id
                  || ', p_ProgramTypeCode = ' || p_program_type_code
                  || ', p_DestinationPageCode = ' || l_destination_page_code
                  || ', p_bid_number = NULL');
  END IF; --}

  PON_WF_UTL_PKG.ReportConcProgramStatus (
    p_request_id => p_request_id,
    p_messagetype => 'S',
    p_RecepientUsername => p_user_name,
    p_recepientType =>'BUYER',
    p_auction_header_id => p_auction_header_id,
    p_ProgramTypeCode => p_program_type_code,
    p_DestinationPageCode => l_destination_page_code,
    p_bid_number => NULL);

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' ||
                  x_error_code || ', error_message = ' || x_error_message);
    END IF;

END report_concurrent_success;

PROCEDURE handle_fatal_exception (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_request_id IN NUMBER,
  p_user_name IN VARCHAR2,
  p_user_id IN NUMBER,
  p_auction_header_id IN NUMBER,
  p_program_type_code IN VARCHAR2,
  p_log_message IN VARCHAR2,
  p_document_number IN VARCHAR2
) IS

l_module_name VARCHAR2 (30);
l_error_message_name VARCHAR2(30);
BEGIN

  l_module_name := 'handle_fatal_exception';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name);
  END IF;

  -- Rollback any changes
  ROLLBACK;

  -- Log the error message
  IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_exception,
      module => g_module_prefix || l_module_name,
      message => 'Fatal Error Message = ' || p_log_message);
  END IF;

  -- send a failure notification
  report_concurrent_failure (
    x_result => x_result,
    x_error_code => x_error_code,
    x_error_message => x_error_message,
    p_request_id => p_request_id,
    p_user_name => p_user_name,
    p_auction_header_id => p_auction_header_id,
    p_program_type_code => p_program_type_code);

  if (p_program_type_code = g_program_type_neg_publish) THEN
    l_error_message_name := 'PON_NEG_PUBLISH_FATAL_ERROR';

  ELSE
    l_error_message_name := 'PON_NEG_APPROVE_FATAL_ERROR';
  END IF;

  -- insert an error row into the pon_interface_errors table
  LOG_INTERFACE_ERROR (
    p_interface_type => g_interface_type,
    p_error_message_name => l_error_message_name,
    p_token1_name => 'DOC_NUM',
    p_token1_value => p_document_number,
    p_token2_name => 'REQUEST_ID',
    p_token2_value => p_request_id,
    p_request_id => p_request_id,
    p_auction_header_id => p_auction_header_id,
    p_expiration_date => SYSDATE + 7,
    p_user_id => p_user_id);

  -- commit
  COMMIT;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' ||
                  x_error_code || ', error_message = ' || x_error_message);
    END IF;

END handle_fatal_exception;
PROCEDURE pon_publish_super_large_neg (
  ERRBUF OUT NOCOPY VARCHAR2,
  RETCODE OUT NOCOPY VARCHAR2,
  ARGUMENT1 IN NUMBER,   -- P_AUCTION_HEADER_ID
  ARGUMENT2 IN VARCHAR2, -- P_FOR_APPROVAL
  ARGUMENT3 IN VARCHAR2, -- P_NOTE_TO_APPROVERS
  ARGUMENT4 IN VARCHAR2, -- P_ENCRYPTED_AUCTION_HEADER_ID
  ARGUMENT5 IN VARCHAR2, -- P_USER_NAME
  ARGUMENT6 IN NUMBER,    -- P_USER_ID
  ARGUMENT7 IN VARCHAR2, --P_CLIENT_TIMEZONE
  ARGUMENT8 IN VARCHAR2, --P_SERVER_TIMEZONE
  ARGUMENT9 IN VARCHAR2, --P_DATE_FORMAT_MASk
  ARGUMENT10 IN VARCHAR2, --P_USER_PARTY_ID
  ARGUMENT11 IN VARCHAR2, --P_COMPANY_PARTY_ID
  ARGUMENT12 IN VARCHAR2 --P_CURR_LANGUAGE
) IS

l_is_amendment BOOLEAN;
l_is_new_round BOOLEAN;
l_login_id NUMBER;

l_draft_locked PON_AUCTION_HEADERS_ALL.DRAFT_LOCKED%TYPE;
l_draft_locked_by_contact_id PON_AUCTION_HEADERS_ALL.DRAFT_LOCKED_BY_CONTACT_ID%TYPE;
l_doctype_id PON_AUCTION_HEADERS_ALL.DOCTYPE_ID%TYPE;
l_auction_currency_precision PON_AUCTION_HEADERS_ALL.NUMBER_PRICE_DECIMALS%TYPE;
l_close_bidding_date PON_AUCTION_HEADERS_ALL.cLOSE_BIDDING_DATE%TYPE;
l_contract_type PON_AUCTION_HEADERS_ALL.CONTRACT_TYPE%TYPE;
l_global_agreement_flag PON_AUCTION_HEADERS_ALL.GLOBAL_AGREEMENT_FLAG%TYPE;
l_allow_other_bid_currency PON_AUCTION_HEADERS_ALL.ALLOW_OTHER_BID_CURRENCY_FLAG%TYPE;
l_bid_ranking PON_AUCTION_HEADERS_ALL.BID_RANKING%TYPE;
l_po_start_date PON_AUCTION_HEADERS_ALL.PO_START_DATE%TYPE;
l_po_end_date PON_AUCTION_HEADERS_ALL.PO_END_DATE%TYPE;
l_trading_partner_id PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_ID%TYPE;
l_full_quantity_bid_code PON_AUCTION_HEADERS_ALL.FULL_QUANTITY_BID_CODE%TYPE;
l_bid_list_type PON_AUCTION_HEADERS_ALL.BID_LIST_TYPE%TYPE;
l_document_number PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
l_amendment_number PON_AUCTION_HEADERS_ALL.AMENDMENT_NUMBER%TYPE;
l_auction_round_number PON_AUCTION_HEADERS_ALL.AUCTION_ROUND_NUMBER%TYPE;
l_auction_header_id_prev_round PON_AUCTION_HEADERS_ALL.AUCTION_HEADER_ID_PREV_ROUND%TYPE;
l_auction_header_id_prev_amend PON_AUCTION_HEADERS_ALL.AUCTION_HEADER_ID_PREV_AMEND%TYPE;
l_auction_origination_code PON_AUCTION_HEADERS_ALL.AUCTION_ORIGINATION_CODE%TYPE;
l_auction_title PON_AUCTION_HEADERS_ALL.AUCTION_TITLE%TYPE;
l_trading_partner_contact_id PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_ID%TYPE;
l_large_neg_enabled_flag PON_AUCTION_HEADERS_ALL.LARGE_NEG_ENABLED_FLAG%TYPE;
l_auction_header_id_orig_amend PON_AUCTION_HEADERS_ALL.AUCTION_HEADER_ID_ORIG_AMEND%TYPE;
l_open_auction_now_flag PON_AUCTION_HEADERS_ALL.OPEN_AUCTION_NOW_FLAG%TYPE;
l_publish_auction_now_flag PON_AUCTION_HEADERS_ALL.PUBLISH_AUCTION_NOW_FLAG%TYPE;
l_open_bidding_date PON_AUCTION_HEADERS_ALL.OPEN_BIDDING_DATE%TYPE;
l_view_by_date PON_AUCTION_HEADERS_ALL.VIEW_BY_DATE%TYPE;
l_auto_extend_flag PON_AUCTION_HEADERS_ALL.AUTO_EXTEND_FLAG%TYPE;
l_auto_extend_number PON_AUCTION_HEADERS_ALL.AUTO_EXTEND_NUMBER%TYPE;
l_bid_visibility_code PON_AUCTION_HEADERS_ALL.BID_VISIBILITY_CODE%TYPE;
l_price_driven_auction_flag PON_AUCTION_HEADERS_ALL.PRICE_DRIVEN_AUCTION_FLAG%TYPE;
l_min_bid_decrement PON_AUCTION_HEADERS_ALL.MIN_BID_DECREMENT%TYPE;
l_line_attribute_enabled_flag PON_AUCTION_HEADERS_ALL.LINE_ATTRIBUTE_ENABLED_FLAG%TYPE;
l_pf_type_allowed PON_AUCTION_HEADERS_ALL.PF_TYPE_ALLOWED%TYPE;
l_progress_payment_type PON_AUCTION_HEADERS_ALL.PROGRESS_PAYMENT_TYPE%TYPE;
l_trading_partner_contact_name PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_NAME%TYPE;
l_award_by_date PON_AUCTION_HEADERS_ALL.AWARD_BY_DATE%TYPE;
l_reminder_date PON_AUCTION_HEADERS_ALL.REMINDER_DATE%TYPE;
l_number_of_lines PON_AUCTION_HEADERS_ALL.NUMBER_OF_LINES%TYPE;
l_event_id PON_AUCTION_HEADERS_ALL.EVENT_ID%TYPE;
l_trading_partner_name PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_NAME%TYPE;
l_note_to_bidders PON_AUCTION_HEADERS_ALL.NOTE_TO_BIDDERS%TYPE;
l_price_tiers_indicator PON_AUCTION_HEADERS_ALL.PRICE_TIERS_INDICATOR%TYPE;

p_auction_header_id NUMBER;
p_for_approval BOOLEAN;
p_note_to_approvers VARCHAR2(2000);
p_encrypted_auction_header_id VARCHAR2(2000);
p_user_name VARCHAR2(2000);
p_user_id NUMBER;
p_client_timezone VARCHAR2(2000);
p_server_timezone VARCHAR2(2000);
p_date_format_mask VARCHAR2(2000);
p_user_party_id NUMBER;
p_company_party_id NUMBER;
p_curr_language VARCHAR2(200);

l_batch_id NUMBER;
l_fnd_currency_precision NUMBER;
l_invitees_count NUMBER;
l_errors_present BOOLEAN;
l_request_id NUMBER;
l_redirect_func VARCHAR2(30);
l_prev_document_number NUMBER;
l_error_code VARCHAR2(100);
l_error_msg VARCHAR2(100);
l_return_msg VARCHAR2(200);
l_return_value NUMBER;
l_return_status VARCHAR2(200);
l_msg_count NUMBER;
l_result VARCHAR2(2);
l_programTypeCode VARCHAR2(30);
l_transaction_type VARCHAR2(30);

l_module_name VARCHAR2 (30);
BEGIN

  -- STORE THE ARGUMENTS INTO LOCAL VARIABLES
  l_module_name := 'pon_publish_super_large_neg';

  p_auction_header_id := ARGUMENT1;
  IF ('Y' = ARGUMENT2) THEN --{
    p_for_approval := TRUE;
    l_programTypeCode := g_program_type_neg_approve;
  ELSE
    p_for_approval := FALSE;
    l_programTypeCode := g_program_type_neg_publish;
  END IF; --}

  p_note_to_approvers := ARGUMENT3;
  p_encrypted_auction_header_id := ARGUMENT4;
  p_user_name := ARGUMENT5;
  p_user_id := ARGUMENT6;
  p_client_timezone := ARGUMENT7;
  p_server_timezone := ARGUMENT8;
  p_date_format_mask := ARGUMENT9;
  p_user_party_id := ARGUMENT10;
  p_company_party_id := ARGUMENT11;
  p_curr_language := ARGUMENT12;

  l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
  l_login_id := FND_GLOBAL.LOGIN_ID;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message  => 'Entered procedure: p_auction_header_id = ' || p_auction_header_id
                  || ', p_for_approval = ' || BOOLEAN_TO_STRING (p_for_approval)
                  || ', p_note_to_approvers = ' || p_note_to_approvers
                  || ', p_encrypted_auction_header_id = ' || p_encrypted_auction_header_id
                  || ', p_user_name = ' || p_user_name
                  || ', p_user_id = ' || p_user_id
                  || ', p_client_timezone = ' || p_client_timezone
                  || ', p_server_timezone = ' || p_server_timezone
                  || ', p_date_format_mask = ' || p_date_format_mask
                  || ', p_user_party_id = ' || p_user_party_id
                  || ', p_company_party_id = ' || p_company_party_id
                  || ', p_curr_language = ' || p_curr_language);
  END IF; --}

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module => g_module_prefix || l_module_name,
      message  => 'Collection auction information');
  END IF; --}

  BEGIN -- { Start of try block

    --COLLECT THE NEGOTIATION INFO
    SELECT
      DRAFT_LOCKED,
      DRAFT_LOCKED_BY_CONTACT_ID,
      DOCTYPE_ID,
      NUMBER_PRICE_DECIMALS,
      CLOSE_BIDDING_DATE,
      CONTRACT_TYPE,
      GLOBAL_AGREEMENT_FLAG,
      ALLOW_OTHER_BID_CURRENCY_FLAG,
      BID_RANKING,
      PO_START_DATE,
      PO_END_DATE,
      TRADING_PARTNER_ID,
      FULL_QUANTITY_BID_CODE,
      BID_LIST_TYPE,
      AMENDMENT_NUMBER,
      AUCTION_ROUND_NUMBER,
      DOCUMENT_NUMBER,
      AUCTION_HEADER_ID_PREV_ROUND,
      AUCTION_HEADER_ID_PREV_AMEND,
      AUCTION_ORIGINATION_CODE,
      AUCTION_TITLE,
      TRADING_PARTNER_CONTACT_ID,
      LARGE_NEG_ENABLED_FLAG,
      AUCTION_HEADER_ID_ORIG_AMEND,
      OPEN_AUCTION_NOW_FLAG,
      PUBLISH_AUCTION_NOW_FLAG,
      OPEN_BIDDING_DATE,
      VIEW_BY_DATE,
      AUTO_EXTEND_FLAG,
      AUTO_EXTEND_NUMBER,
      BID_VISIBILITY_CODE,
      PRICE_DRIVEN_AUCTION_FLAG,
      MIN_BID_DECREMENT,
      LINE_ATTRIBUTE_ENABLED_FLAG, --19
      PF_TYPE_ALLOWED,
      PROGRESS_PAYMENT_TYPE,
      TRADING_PARTNER_CONTACT_NAME,
      AWARD_BY_DATE,
      REMINDER_DATE,
      NUMBER_OF_LINES,
      EVENT_ID,
      TRADING_PARTNER_NAME,
      NOTE_TO_BIDDERS,
      PRICE_TIERS_INDICATOR
    INTO
      l_draft_locked,
      l_draft_locked_by_contact_id,
      l_doctype_id,
      l_auction_currency_precision,
      l_close_bidding_date,
      l_contract_type,
      l_global_agreement_flag,
      l_allow_other_bid_currency,
      l_bid_ranking,
      l_po_start_date,
      l_po_end_date,
      l_trading_partner_id,
      l_full_quantity_bid_code,
      l_bid_list_type,
      l_amendment_number,
      l_auction_round_number,
      l_document_number,
      l_auction_header_id_prev_round,
      l_auction_header_id_prev_amend,
      l_auction_origination_code,
      l_auction_title,
      l_trading_partner_contact_id,
      l_large_neg_enabled_flag,
      l_auction_header_id_orig_amend,
      l_open_auction_now_flag,
      l_publish_auction_now_flag,
      l_open_bidding_date,
      l_view_by_date,
      l_auto_extend_flag,
      l_auto_extend_number,
      l_bid_visibility_code,
      l_price_driven_auction_flag,
      l_min_bid_decrement,
      l_line_attribute_enabled_flag,
      l_pf_type_allowed,
      l_progress_payment_type,
      l_trading_partner_contact_name,
      l_award_by_date,
      l_reminder_date,
      l_number_of_lines,
      l_event_id,
      l_trading_partner_name,
      l_note_to_bidders,
      l_price_tiers_indicator
    FROM
      pon_auction_headers_all
    WHERE
      auction_header_id = p_auction_header_id;

    SELECT COUNT(auction_header_id)
    INTO l_invitees_count
    FROM pon_bidding_parties
    WHERE auction_header_id = p_auction_header_id;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message  => 'Auction information collected: ' ||
                    'l_draft_locked = ' || l_draft_locked ||
                    ', l_draft_locked_by_contact_id = ' || l_draft_locked_by_contact_id ||
                    ', l_doctype_id = ' || l_doctype_id ||
                    ', l_auction_currency_precision = ' || l_auction_currency_precision ||
                    ', l_close_bidding_date = ' || l_close_bidding_date ||
                    ', l_contract_type = ' || l_contract_type ||
                    ', l_global_agreement_flag = ' || l_global_agreement_flag ||
                    ', l_allow_other_bid_currency = ' || l_allow_other_bid_currency ||
                    ', l_bid_ranking = ' || l_bid_ranking ||
                    ', l_po_start_date = ' || l_po_start_date ||
                    ', l_po_end_date = ' || l_po_end_date ||
                    ', l_trading_partner_id, = ' || l_trading_partner_id ||
                    ', l_full_quantity_bid_code, = ' || l_full_quantity_bid_code ||
                    ', l_bid_list_type, = ' || l_bid_list_type ||
                    ', l_amendment_number, = ' || l_amendment_number ||
                    ', l_auction_round_number, = ' || l_auction_round_number ||
                    ', l_document_number, = ' || l_document_number ||
                    ', l_auction_header_id_prev_round, = ' || l_auction_header_id_prev_round ||
                    ', l_auction_header_id_prev_amend, = ' || l_auction_header_id_prev_amend ||
                    ', l_auction_origination_code, = ' || l_auction_origination_code ||
                    ', l_auction_title, = ' || l_auction_title ||
                    ', l_trading_partner_contact_id, = ' || l_trading_partner_contact_id ||
                    ', l_large_neg_enabled_flag, = ' || l_large_neg_enabled_flag ||
                    ', l_auction_header_id_orig_amend, = ' || l_auction_header_id_orig_amend ||
                    ', l_open_auction_now_flag, = ' || l_open_auction_now_flag ||
                    ', l_publish_auction_now_flag, = ' || l_publish_auction_now_flag ||
                    ', l_open_bidding_date, = ' || l_open_bidding_date ||
                    ', l_view_by_date = ' || l_view_by_date ||
                    ', l_auto_extend_flag = ' || l_auto_extend_flag ||
                    ', l_auto_extend_number = ' || l_auto_extend_number ||
                    ', l_progress_payment_type, = ' || l_progress_payment_type ||
                    ', l_bid_visibility_code = ' || l_bid_visibility_code ||
                    ', l_price_tiers_indicator = ' || l_price_tiers_indicator);
    END IF; --}

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message  => 'Checking for lock on the negotiation');
    END IF; --}

    --CHECK FOR DRAFT LOCK ON THE NEGOTIATION

    IF (NOT ('Y' = l_draft_locked AND l_draft_locked_by_contact_id = p_user_party_id)) THEN --{

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
          message  => 'The person who initiated the concurrent program no longer has the lock on the negotiation');
      END IF; --}

      RETCODE := 2;
      ERRBUF := 'PON_NO_DRAFT_LOCK';

      --Log this error in the PON_INTERFACE_ERRORS TABLE

      LOG_INTERFACE_ERROR (
        p_interface_type => g_interface_type,
        p_error_message_name => 'PON_NO_DRAFT_LOCK',
        p_token1_name => null,
        p_token1_value => null,
        p_token2_name => null,
        p_token2_value => null,
        p_request_id => l_request_id,
        p_auction_header_id => p_auction_header_id,
        p_expiration_date => SYSDATE + 7,
        p_user_id => p_user_id);

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message  => 'Setting return code to 2 and returning after logging PON_NO_DRAFT_LOCK error');
      END IF; --}

      report_concurrent_failure (
        x_result => l_result,
        x_error_code => l_error_code,
        x_error_message => l_error_msg,
        p_request_id => l_request_id,
        p_user_name => p_user_name,
        p_auction_header_id => p_auction_header_id,
        p_program_type_code => l_programTypeCode);

      --Issue a commit so that the error is pushed to the database and return

      COMMIT;
      RETURN;
    END IF; --}

    --INITIALIZE THE l_is_new_round and l_is_amendment variables
    l_is_new_round := false;
    l_is_amendment := false;

    -- Amendment always takes the first preference.
    -- During new round creation we clear out the previous amendment details
    -- But during amendment creation we retain the previous round details
    IF (l_amendment_number > 0) THEN --{

      l_is_amendment := true;
      l_prev_document_number := l_auction_header_id_prev_amend;
    ELSIF (l_auction_round_number > 1) THEN --{

      l_is_new_round := true;
      l_prev_document_number := l_auction_header_id_prev_round;
    END IF; --}

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message  => 'New round/amendment variables initialized' ||
                    ', l_is_new_round = ' || BOOLEAN_TO_STRING (l_is_new_round)||
                    ', l_is_amendment = ' || BOOLEAN_TO_STRING (l_is_amendment)||
                    ', l_prev_document_number = ' || l_prev_document_number);
    END IF; --}

    --Call to PON_NEG_UPDATE_PKG.CAN_EDIT_DRAFT_AMEND
    --If the negotiation that the buyer is amending becomes closed or cancelled,

    IF (l_is_amendment) THEN

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message  => 'This is an amendment, checking if the amendment can be published or not');
      END IF; --}

      PON_NEG_UPDATE_PKG.CAN_EDIT_DRAFT_AMEND (
        p_auction_header_id_prev_doc => l_auction_header_id_prev_amend,
        x_error_code => l_error_code);

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message  => 'The return code from call to PON_NEG_UPDATE_PKG.CAN_EDIT_DRAFT_AMEND = ' || l_error_code);
      END IF; --}

      IF (l_error_code <> 'SUCCESS') THEN

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message  => 'The return code is not success so logging error and exiting');
        END IF; --}

        RETCODE := 2;
        ERRBUF := 'PON_EDIT_DRAFT_AMEND_ERROR';

        LOG_INTERFACE_ERROR (
          p_interface_type => g_interface_type,
          p_error_message_name => 'PON_EDIT_DRAFT_AMEND_ERROR',
          p_token1_name => null,
          p_token1_value => null,
          p_token2_name => null,
          p_token2_value => null,
          p_request_id => l_request_id,
          p_auction_header_id => p_auction_header_id,
          p_expiration_date => SYSDATE + 7,
          p_user_id => p_user_id);

        report_concurrent_failure (
          x_result => l_result,
          x_error_code => l_error_code,
          x_error_message => l_error_msg,
          p_request_id => l_request_id,
          p_user_name => p_user_name,
          p_auction_header_id => p_auction_header_id,
          p_program_type_code => l_programTypeCode);

        COMMIT;
        RETURN;
      END IF;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message  => 'Calling validate lines procedure');
    END IF; --}

    -- The validate lines procedure is the same as the one that is
    -- called during the online publish flow

    VALIDATE_LINES (
      l_result, --1
      l_error_code, --2
      l_error_msg, --3
      p_auction_header_id, --4
      l_doctype_id, --5
      l_auction_currency_precision , --6
      l_fnd_currency_precision , --7
      l_close_bidding_date , --8
      l_contract_type , --9
      l_global_agreement_flag , --10
      l_allow_other_bid_currency , --11
      l_bid_ranking , --12
      l_po_start_date , --13
      l_po_end_date , --14
      l_trading_partner_id , --15
      l_full_quantity_bid_code , --16
      l_invitees_count , --17
      l_bid_list_type , --18
      l_request_id, --19
      ARGUMENT2, --20
      p_user_id, --21
      l_line_attribute_enabled_flag, --22
      l_pf_type_allowed, --23
      l_progress_payment_type, --24
      l_large_neg_enabled_flag, --25
      l_price_tiers_indicator, --26
      l_batch_id  --27
    );

    IF (l_result <> FND_API.G_RET_STS_SUCCESS) THEN -- {

      handle_fatal_exception (
        x_result => l_result,
        x_error_code => l_error_code,
        x_error_message => l_error_msg,
        p_request_id => l_request_id,
        p_user_name => p_user_name,
        p_user_id => p_user_id,
        p_auction_header_id => p_auction_header_id,
        p_program_type_code => l_programTypeCode,
        p_log_message => l_error_msg,
        p_document_number => l_document_number);
      RETCODE := 2;
      RETURN;
    END IF; --}

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message  => 'Calling CHECK_ACTION_ERRORS_PRESENT with l_batch_id = ' || l_batch_id);
    END IF; --}

    -- Check if there are any errors logged by the VALIDATE_LINES procedure
    l_errors_present := CHECK_ACTION_ERRORS_PRESENT (l_batch_id);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message  => 'Return value from CHECK_ACTION_ERRORS_PRESENT = ' || BOOLEAN_TO_STRING (l_errors_present));
    END IF; --}

    IF (l_errors_present) THEN --{

      -- If errors are present then the concurrent program status should be set to ERROR
      RETCODE := 2;

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message  => 'Errors were found while validating, exiting with return code = ' || RETCODE);
      END IF; --}

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message  => 'Rolling back the transaction and saving the errors');
      END IF; --}

      --Pull errors to table of records, perform rollback and then push them back
      RETRIEVE_ERRORS_AND_ROLLBACK (l_batch_id);

      -- Send notification about failure
      report_concurrent_failure (
        x_result => l_result,
        x_error_code => l_error_code,
        x_error_message => l_error_msg,
        p_request_id => l_request_id,
        p_user_name => p_user_name,
        p_auction_header_id => p_auction_header_id,
        p_program_type_code => l_programTypeCode);

    --No errors go ahead
    ELSE

      --Initialize the redirect function used for initiating the approval workflow
      IF (l_is_new_round OR l_is_amendment) THEN --{

        l_redirect_func := 'PONCRT_VWCHNG_SUBMIT';
      ELSE

        l_redirect_func := 'PON_NEG_CRT_REVIEW';
      END IF; --}

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message  => 'l_redirect_func = ' || l_redirect_func);
      END IF; --}

      -- No errors but this is for approval flow, so simply release the lock
      -- on the draft and initiate the approval workflow

      IF (p_for_approval) THEN --{

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message  => 'This is for approval');
        END IF; --}

        UPDATE PON_AUCTION_HEADERS_ALL
        SET
          DRAFT_LOCKED = 'N',
          DRAFT_LOCKED_BY = NULL,
          DRAFT_LOCKED_BY_CONTACT_ID = NULL,
          DRAFT_LOCKED_DATE = NULL,
          DRAFT_UNLOCKED_BY = p_company_party_id,
          DRAFT_UNLOCKED_BY_CONTACT_ID = p_user_party_id,
          DRAFT_UNLOCKED_DATE = SYSDATE,
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = p_user_id
        WHERE
          AUCTION_HEADER_ID = p_auction_header_id;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message  => 'Initiating the approval workflow'
                        || ', p_encrypted_auction_header_id = ' || p_encrypted_auction_header_id
                        || ', P_AUCTION_HEADER_ID = ' || p_auction_header_id
                        || ', P_NOTE_TO_APPROVERS = ' || p_note_to_approvers
                        || ', P_SUBMIT_USER_NAME = ' || p_user_name
                        || ', P_REDIRECT_FUNC = ' || l_redirect_func);
        END IF; --}

        -- Call the submit_for_approval api to initiate the
        -- workflow
        PON_AUCTION_APPROVAL_PKG.submit_for_approval (
          p_auction_header_id_encrypted => p_encrypted_auction_header_id,
          p_auction_header_id => p_auction_header_id,
          p_note_to_approvers => p_note_to_approvers,
          p_submit_user_name => p_user_name,
          p_redirect_func => l_redirect_func);

        -- Send a success notification to the user that auction
        -- is successfully submitted for approval
        report_concurrent_success (
          x_result => l_result,
          x_error_code => l_error_code,
          x_error_message => l_error_msg,
          p_request_id => l_request_id,
          p_user_name => p_user_name,
          p_auction_header_id => p_auction_header_id,
          p_program_type_code => l_programTypeCode);

      -- OK this is the publish flow, need to call all before publish method
      -- contracts methods, etc and make the auction active

      ELSE

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message  => 'This is for publish');
        END IF; --}

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message  => 'Calling update lines before publish');
        END IF; --}

        -- The close bidding date and other flags on the lines.
        -- The updates on lines happens in batches with commit
        -- being issued after every batch
        update_lines_before_publish (
          x_result => l_result,
          x_error_code => l_error_code,
          x_error_message => l_error_msg,
          p_auction_header_id => p_auction_header_id,
          p_close_bidding_date => l_close_bidding_date,
          p_user_id => p_user_id,
          p_login_id => l_login_id);

        IF (l_result <> FND_API.G_RET_STS_SUCCESS) THEN -- {

          handle_fatal_exception (
            x_result => l_result,
            x_error_code => l_error_code,
            x_error_message => l_error_msg,
            p_request_id => l_request_id,
            p_user_name => p_user_name,
            p_user_id => p_user_id,
            p_auction_header_id => p_auction_header_id,
            p_program_type_code => l_programTypeCode,
            p_log_message => l_error_msg,
            p_document_number => l_document_number);
          RETCODE := 2;
          RETURN;
        END IF; --}

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message  => 'Calling update header before publish');
        END IF; --}

        -- The max sequence number fields and other flags on the
        -- header
        update_header_before_publish (
          x_result => l_result,
          x_error_code => l_error_code,
          x_error_message => l_error_msg,
          p_auction_header_id => p_auction_header_id);

        IF (l_result <> FND_API.G_RET_STS_SUCCESS) THEN -- {

          handle_fatal_exception (
            x_result => l_result,
            x_error_code => l_error_code,
            x_error_message => l_error_msg,
            p_request_id => l_request_id,
            p_user_name => p_user_name,
            p_user_id => p_user_id,
            p_auction_header_id => p_auction_header_id,
            p_program_type_code => l_programTypeCode,
            p_log_message => l_error_msg,
            p_document_number => l_document_number);
          RETCODE := 2;
          RETURN;
        END IF; --}

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message  => 'Checking if this is a new round or amendment');
        END IF; --}

        -- In case of an amendment or a multi round need to call the
        -- PON_NEG_UPDATE_PKG.UPDATE_TO_NEW_DOCUMENT method.
        IF (l_is_amendment OR l_is_new_round) THEN --{

          IF (l_is_amendment) THEN
            l_transaction_type := 'CREATE_AMENDMENT';
          ELSE
            l_transaction_type := 'CREATE_NEW_ROUND';
          END IF;

          IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module => g_module_prefix || l_module_name,
              message  => 'Calling update_to_new_document');
          END IF; --}

          PON_NEG_UPDATE_PKG.update_to_new_document (
            p_auction_header_id_curr_doc => p_auction_header_id,
            p_doc_number_curr_doc => l_document_number,
            p_auction_header_id_prev_doc => l_prev_document_number,
            p_auction_origination_code => l_auction_origination_code,
            p_is_new => 'N',
            p_is_publish => 'Y',
            p_transaction_type => l_transaction_type,
            p_user_id => p_user_id,
            x_error_code => l_error_code,
            x_error_msg => l_error_msg);

          IF (nvl (l_error_code, g_invalid_string) <> 'SUCCESS') THEN

            --EXCEPTION: EXIT FROM CONCURRENT PROGRAM
            IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN --{
              FND_LOG.string(log_level => FND_LOG.level_exception,
                module => g_module_prefix || l_module_name,
                message  => 'Exception in update_to_new_document call = ' || l_error_msg);
            END IF; --}

            -- Rollback till the previous commit
            ROLLBACK;

            -- log an error into the interface_error table
            LOG_INTERFACE_ERROR (
              p_interface_type => g_interface_type,
              p_error_message_name => 'PON_UNEXPECTED_ERROR',
              p_token1_name => null,
              p_token1_value => null,
              p_token2_name => null,
              p_token2_value => null,
              p_request_id => l_request_id,
              p_auction_header_id => p_auction_header_id,
              p_expiration_date => SYSDATE + 7,
              p_user_id => p_user_id);

            -- send out a failure notification
            report_concurrent_failure (
              x_result => l_result,
              x_error_code => l_error_code,
              x_error_message => l_error_msg,
              p_request_id => l_request_id,
              p_user_name => p_user_name,
              p_auction_header_id => p_auction_header_id,
              p_program_type_code => l_programTypeCode);

            -- commit, so the notification and error are inserted.
            COMMIT;

            -- set the concurrent program status to error and simply return.
            RETCODE := 2;

            RETURN;
          END IF;
        END IF; --}

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message  => 'Inserting row into pon discussions');
        END IF; --}

        -- Contracts related methods
        --PON_CONTERMS_UTL_PVT.resolveDeliverables
        --PON_CONTERMS_UTL_PVT.cancelDeliverables
        --PON_CONTERMS_UTL_PVT.updateDelivOnAmendment

        IF (NVL(FND_PROFILE.VALUE ('POC_ENABLED'),'N') = 'Y') THEN --{

          PON_CONTERMS_UTL_PVT.resolvedeliverables (
            p_auction_header_id => p_auction_header_id,
            x_msg_data => l_return_msg,
            x_msg_count => l_msg_count,
            x_return_status => l_return_status);

          IF (l_is_new_round) THEN --{

            PON_CONTERMS_UTL_PVT.canceldeliverables (
             p_auction_header_id => l_auction_header_id_prev_round,
             p_doc_type_id => l_doctype_id,
             x_msg_data => l_return_msg,
             x_msg_count => l_msg_count,
             x_return_status => l_return_status);
          END IF; --}

          IF (l_is_amendment) THEN --{

            PON_CONTERMS_UTL_PVT.updatedelivonamendment (
              p_auction_header_id_orig => l_auction_header_id_orig_amend,
              p_auction_header_id_prev => l_auction_header_id_prev_amend,
              p_doc_type_id => l_doctype_id,
              p_close_bidding_date => l_close_bidding_date,
              x_result => l_return_status,
              x_error_code => l_error_code,
              x_error_message => l_error_msg);
          END IF; --}
        END IF; --}

        -- AuctionHeadersALLEOImpl.setAutoExtendFields
        IF (l_auto_extend_flag = null OR l_auto_extend_flag = 'N' OR l_bid_visibility_code = 'SEALED_AUCTION') THEN
          UPDATE PON_AUCTION_HEADERS_ALL
          SET
            AUTO_EXTEND_TYPE_FLAG = 'FROM_AUCTION_CLOSE_DATE',
            AUTO_EXTEND_DURATION = NULL,
            AUTO_EXTEND_NUMBER = NULL,
            AUTO_EXTEND_ALL_LINES_FLAG = 'Y',
            AUTO_EXTEND_FLAG = 'N',
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = p_user_id
          WHERE
            AUCTION_HEADER_ID = p_auction_header_id;

        ELSIF (l_auto_extend_flag = 'Y' AND l_auto_extend_number = NULL) THEN
          UPDATE PON_AUCTION_HEADERS_ALL
          SET
            AUTO_EXTEND_NUMBER = g_unlimited_int,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = p_user_id
          WHERE
            AUCTION_HEADER_ID = p_auction_header_id;

        END IF;

        -- AuctionHeadersALLEOImpl.setDecrementFields
        IF ('MULTI_ATTRIBUTE_SCORING' = l_bid_ranking) THEN
          UPDATE pon_auction_headers_all
          SET
            min_bid_change_type = null,
            price_driven_auction_flag = 'N',
            min_bid_decrement = NULL,
            last_update_date = sysdate,
            last_updated_by = p_user_id
          WHERE
            auction_header_id = p_auction_header_id;

        ELSIF ( NVL (l_price_driven_auction_flag, g_invalid_string) <> 'Y') THEN

          UPDATE PON_AUCTION_HEADERS_ALL
          SET
            MIN_BID_CHANGE_TYPE = NULL,
            MIN_BID_DECREMENT = NULL,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = p_user_id
          WHERE
            AUCTION_HEADER_ID = p_auction_header_id;
        ELSIF (l_min_bid_decrement = null OR l_min_bid_decrement = '') THEN

          UPDATE PON_AUCTION_HEADERS_ALL
          SET
            MIN_BID_CHANGE_TYPE = NULL,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = p_user_id
          WHERE
            AUCTION_HEADER_ID = p_auction_header_id;
        END IF;

        --UPDATE THE OPEN_BIDDING_DATE AND VIEW_BY_DATE COLUMNS
        IF (l_open_auction_now_flag = 'Y') THEN
          l_open_bidding_date := SYSDATE;
        END IF;

        IF (l_publish_auction_now_flag = 'Y') THEN
          l_view_by_date := SYSDATE;
        END IF;

        PON_AUCTION_PKG.start_auction (
          p_auction_header_id_encrypted => p_encrypted_auction_header_id, --1
          p_auction_header_id => p_auction_header_id, --2
          p_trading_partner_contact_name => l_trading_partner_contact_name, --3
          p_trading_partner_contact_id => l_trading_partner_contact_id, --4
          p_trading_partner_name => l_trading_partner_name, --5
          p_trading_partner_id => l_trading_partner_id, --6
          p_open_bidding_date => l_open_bidding_date, --7
          p_close_bidding_date => l_close_bidding_date, --8
          p_award_by_date => l_award_by_date, --9
          p_reminder_date => l_reminder_date, --10
          p_bid_list_type => l_bid_list_type, --11
          p_note_to_bidders => l_note_to_bidders, --12
          p_number_of_items => l_number_of_lines, --13
          p_auction_title => l_auction_title, --14
          p_event_id => l_event_id); --15

        -- Make the auction active
        UPDATE PON_AUCTION_HEADERS_ALL
        SET
          AUCTION_STATUS = 'ACTIVE',
          REQUEST_ID = NULL,
          REQUESTED_BY = NULL,
          REQUEST_DATE = NULL,
          OPEN_BIDDING_DATE = l_open_bidding_date,
          VIEW_BY_DATE = l_view_by_date,
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = p_user_id
        WHERE
          AUCTION_HEADER_ID = p_auction_header_id;

        -- Submit the concurrent program to generate the pdf
        l_return_value := FND_REQUEST.SUBMIT_REQUEST (
          APPLICATION => 'PON',
          PROGRAM => 'PON_GENERATE_PDF',
          DESCRIPTION => null,
          START_TIME => null,
          SUB_REQUEST => false,
          ARGUMENT1 => p_auction_header_id,
          ARGUMENT2 => p_client_timezone,
          ARGUMENT3 => p_server_timezone,
          ARGUMENT4 => p_date_format_mask);

        -- Send notification to user about success of the concurrent
        -- program.
        report_concurrent_success (
          x_result => l_result,
          x_error_code => l_error_code,
          x_error_message => l_error_msg,
          p_request_id => l_request_id,
          p_user_name => p_user_name,
          p_auction_header_id => p_auction_header_id,
          p_program_type_code => l_programTypeCode);

      END IF; --}

      RETCODE := 0;
    END IF; --}

  EXCEPTION WHEN OTHERS THEN --} End of Try block and start of catch block{

      -- In case of an exception then
      -- rollback any changes done and send out a failure notification
      ROLLBACK;

      IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_exception,
          module  =>  g_module_prefix || l_module_name,
          message  => substrb(SQLERRM, 1, 500));
      END IF; --}

      -- Set the concurrent program status to error
      RETCODE := 2;

      -- Insert a row into the interface error table
      LOG_INTERFACE_ERROR (
        p_interface_type => g_interface_type,
        p_error_message_name => 'PON_UNEXPECTED_ERROR',
        p_token1_name => null,
        p_token1_value => null,
        p_token2_name => null,
        p_token2_value => null,
        p_request_id => l_request_id,
        p_auction_header_id => p_auction_header_id,
        p_expiration_date => SYSDATE + 7,
        p_user_id => p_user_id);

      --Send the failure notification
      report_concurrent_failure (
        x_result => l_result,
        x_error_code => l_error_code,
        x_error_message => l_error_msg,
        p_request_id => l_request_id,
        p_user_name => p_user_name,
        p_auction_header_id => p_auction_header_id,
        p_program_type_code => l_programTypeCode);
  END; --}

  COMMIT;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Leaving concurrent program');
  END IF; --}

END PON_PUBLISH_SUPER_LARGE_NEG;


END PON_NEGOTIATION_PUBLISH_PVT;

/
