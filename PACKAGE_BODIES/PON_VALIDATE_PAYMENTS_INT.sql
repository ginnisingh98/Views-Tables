--------------------------------------------------------
--  DDL for Package Body PON_VALIDATE_PAYMENTS_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_VALIDATE_PAYMENTS_INT" as
-- $Header: PONVAPIB.pls 120.24 2007/09/10 23:59:33 sssahai ship $

-- These will be used for debugging the code
g_fnd_debug             CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name              CONSTANT VARCHAR2(30) := 'PON_VALIDATE_PAYMENTS_INT';
g_module_prefix         CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';


/** =============Start declaration of private functions and procedures =========*/
PROCEDURE print_debug_log(p_module   IN    VARCHAR2,
                          p_message  IN    VARCHAR2);

PROCEDURE print_error_log(p_module   IN    VARCHAR2,
                          p_message  IN    VARCHAR2);

PROCEDURE validate_response (p_spreadsheet_type VARCHAR2, p_batch_Id NUMBER, p_bid_number NUMBER, p_auction_header_id NUMBER, p_request_id NUMBER) IS
l_userid NUMBER;
l_loginid NUMBER;
l_exp_date DATE;
l_interface_type VARCHAR2(15);
l_module CONSTANT VARCHAR2(32) := 'VALIDATE_RESPONSE';
l_progress              varchar2(200);
l_entity_name PON_INTERFACE_ERRORS.entity_message_code%TYPE;

BEGIN

l_userid := fnd_global.user_id;
l_loginid := fnd_global.login_id;
l_exp_date := SYSDATE + 7;
l_interface_type := 'BIDPYMTUPLOAD'; --Radhika-- do i need to change this for Xml upload?
l_entity_name := 'PON_AUC_PAYMENTS';

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'VALIDATE_RESPONSE  START p_batch_id = '||p_batch_id
		||' p_bid_number = ' ||p_bid_number || ' p_auction_header_id = '|| p_auction_header_id);
    END IF;

    --Validate and remove duplicate records for payments for Xml Upload case
    --For text based spreadsheet duplicate records are not inserted in the interface table

    IF p_spreadsheet_type = PON_BID_VALIDATIONS_PKG.g_xml_upload_mode THEN
      BEGIN

        INSERT INTO PON_INTERFACE_ERRORS
        (
          column_name,
          error_message_name,
          error_value_datatype,
          error_value_number,
          token1_name,
          token1_value,
          token2_name,
          token2_value,
          interface_type,
          table_name,
          batch_id,
          interface_line_id,
          auction_header_id,
          expiration_date,
          REQUEST_ID,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
          worksheet_name,
          worksheet_sequence_number,
          entity_message_code
        )
        SELECT   fnd_message.get_string('PON','PON_PAY_ITEM'),
                 'PON_PYMT_NUM_NOT_UNQ',
                 'NUM',
         		 pbp.payment_display_number,
                 'LINENUM',
        		 pbp.document_disp_line_number,
        		 'PAYITEMNUM',
                 pbp.payment_display_number,
         		 l_interface_type,
          		 'PON_BID_PAYMENTS_SHIPMENTS',
                 p_batch_id,
         		 pbp.interface_line_id,
                 pbp.auction_header_id,
                 l_exp_date,
    			 p_request_id,
         		 l_userid,
         		 SYSDATE,
                 l_userid,
         		 SYSDATE,
        		 l_loginid,
                 pbp.worksheet_name,
                 pbp.worksheet_sequence_number,
                 l_entity_name
           FROM  PON_BID_PAYMENTS_INTERFACE pbp
           WHERE pbp.batch_id = p_batch_id
             AND pbp.interface_line_id >
               ( SELECT min(interface_line_id)
                   FROM PON_BID_PAYMENTS_INTERFACE pbpi2
                  WHERE pbp.document_disp_line_number = pbpi2.document_disp_line_number
                    AND pbp.payment_display_number = pbpi2.payment_display_number
                    AND pbp.batch_id = pbpi2.batch_id
                    AND pbp.interface_line_id <> pbpi2.interface_line_id);

        IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            print_debug_log(l_module,'After valiating for duplicate payitems for p_batch_id = '||p_batch_id);
        END IF;

    -- If we don't delete duplicate records Merge statement won't work
    -- We could have validated the rest of the records and delete them before merge
    -- but as discussed with PM Alan Ng, we will retain the behaviour of R12 for now

        DELETE FROM PON_BID_PAYMENTS_INTERFACE pbpi
        WHERE pbpi.batch_id = p_batch_id
        AND pbpi.interface_line_id >
             ( SELECT min(interface_line_id)
               FROM PON_BID_PAYMENTS_INTERFACE pbpi2
               WHERE pbpi.document_disp_line_number = pbpi2.document_disp_line_number
               AND pbpi.payment_display_number = pbpi2.payment_display_number
               AND pbpi.batch_id = pbpi2.batch_id
               AND pbpi.interface_line_id <> pbpi2.interface_line_id);
      EXCEPTION
        WHEN OTHERS THEN
        IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            print_error_log(l_module, 'EXCEPTION -  l_progress='||l_progress||' Error Code=' || SQLCODE || ' SQLERRM=' || SQLERRM);
        END if;
      END;

    END IF; --End of if xml

INSERT ALL
WHEN supplier_can_modify_payments = 'Y' AND
     unit_of_measure IS NOT NULL AND uom_code IS NULL THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                  error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login,              -- 8
  worksheet_name,
  worksheet_sequence_number,
  entity_message_code,
  REQUEST_ID

 )
VALUES
 (
  fnd_message.get_string('PON','PON_AUCTS_UOM'),              NULL,                        'PON_UOM_INVALID',              -- 1
  'TXT',                        unit_of_measure,              NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_BID_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                  interface_line_id,                   NULL,                          -- 5
  auction_header_id,            auction_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid,                      -- 8
  s_worksheet_name,
  s_worksheet_sequence_number,
  s_entity_name ,
  p_request_id
 )
WHEN p_spreadsheet_type = PON_BID_VALIDATIONS_PKG.g_txt_upload_mode AND bid_line_number IS NOT NULL and group_type IN ('GROUP','LOT_LINE') THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                  error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login,              -- 8
  REQUEST_ID

 )
VALUES
 (
  fnd_message.get_string('PON','PON_AUCTS_LINENUMBER'),       NULL,                         'PON_PYMT_NOTALLOWED',         -- 1
  'TXT',                        document_disp_line_number,              NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    NULL,                          -- 3
   NULL,                        l_interface_type,             'PON_BID_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                  interface_line_id,                   NULL,                 -- 5
  auction_header_id,            auction_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid,
  p_request_id
 )
WHEN p_spreadsheet_type = PON_BID_VALIDATIONS_PKG.g_txt_upload_mode AND bid_line_number IS NULL THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                  error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login,
  REQUEST_ID
 )
VALUES
 (
  fnd_message.get_string('PON','PON_AUCTS_LINENUMBER'),       NULL,                         'PON_INVALID_LINE_NUM',        -- 1
  'TXT',                        document_disp_line_number,              NULL,                          -- 2
  NULL,                         NULL,    NULL,                          -- 3
   NULL,                        l_interface_type,             'PON_BID_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                  interface_line_id,                   NULL,                          -- 5
  auction_header_id,            auction_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid,
  p_request_id
 )
-- For GOODS based line only MILESTONE payments should be allowed. Otherwise throw an error
-- If the payment type entered in the spreadsheet is not from a fnd lookup then throw an error
-- If pay item entered is not supported by the purchasing style then throw an error.

WHEN supplier_can_modify_payments = 'Y' AND
  ((line_type = 'GOODS' AND  lookup_payment_type_code <> 'MILESTONE') OR
      (payment_type IS NOT NULL AND lookup_payment_type_code IS NULL) OR
      (lookup_payment_type_code IS NOT NULL AND lookup_payment_type_code NOT IN
        (SELECT pay_item_type FROM PO_STYLE_ENABLED_PAY_ITEMS WHERE style_id = po_style_id))) THEN
 INTO pon_interface_errors
 (
  column_name,
  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                  error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login,              -- 8
  worksheet_name,
  worksheet_sequence_number,
  entity_message_code,
  REQUEST_ID
 )
VALUES
 (
  decode(p_spreadsheet_type, PON_BID_VALIDATIONS_PKG.g_txt_upload_mode, fnd_message.get_string('PON','PON_AUCTS_PAYITEM_TYPE'), fnd_message.get_string('PON','PON_AUCTS_TYPE')),
  NULL,                        'PON_PYMT_TYPE_INVALID',        -- 1
  'TXT',                        payment_type,                 NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_BID_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                  interface_line_id,                   NULL,                          -- 5
  auction_header_id,            auction_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid,                      -- 8
  s_worksheet_name,
  s_worksheet_sequence_number,
  s_entity_name,
  p_request_id
 )
WHEN payment_display_number < 1 OR payment_display_number<> ROUND(payment_display_number) THEN
 INTO pon_interface_errors
 (
  column_name,
  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                  error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login,              -- 8
  worksheet_name,
  worksheet_sequence_number,
  entity_message_code,
  REQUEST_ID
 )
VALUES
 (
  decode(p_spreadsheet_type, PON_BID_VALIDATIONS_PKG.g_txt_upload_mode, fnd_message.get_string('PON','PON_AUCTS_PAYITEM_NUMBER'), fnd_message.get_string('PON','PON_PAY_ITEM')),
  NULL,                         'PON_PYMT_NUM_WRONG',          -- 1
  'TXT',                        payment_display_number,       NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_BID_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                  interface_line_id,                   NULL,                          -- 5
  auction_header_id,            auction_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid,                      -- 8
  s_worksheet_name,
  s_worksheet_sequence_number,
  s_entity_name,
  p_request_id
 )
WHEN supplier_can_modify_payments = 'Y' AND
     lookup_payment_type_code = 'RATE' AND quantity < 0 THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login,              -- 8
  worksheet_name,
  worksheet_sequence_number,
  entity_message_code,
  REQUEST_ID
 )
VALUES
 (
  fnd_message.get_string('PON','PON_AUCTS_BID_QTY_R'),     NULL,                         'PON_PYMT_QTY_WRONG',          -- 1
  'NUM',                        quantity,                         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_BID_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                  interface_line_id,                   NULL,                          -- 5
  auction_header_id,            auction_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid,                      -- 8
  s_worksheet_name,
  s_worksheet_sequence_number,
  s_entity_name,
  p_request_id
 )
WHEN supplier_can_modify_payments = 'Y' AND
     lookup_payment_type_code = 'RATE' AND unit_of_measure IS NULL THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                 error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login,              -- 8
  worksheet_name,
  worksheet_sequence_number,
  entity_message_code,
  REQUEST_ID
 )
VALUES
 (
  fnd_message.get_string('PON','PON_AUCTS_UOM'),     NULL,                         'PON_PYMT_UOM_NULL',          -- 1
  'TXT',                        NULL,                         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_BID_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                  interface_line_id,                   NULL,                          -- 5
  auction_header_id,            auction_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid,                      -- 8
  s_worksheet_name,
  s_worksheet_sequence_number,
  s_entity_name,
  p_request_id
 )
WHEN bid_currency_price IS NOT NULL AND bid_currency_price < 0 THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login,              -- 8
  worksheet_name,
  worksheet_sequence_number,
  entity_message_code,
  REQUEST_ID
 )
VALUES
 (
  fnd_message.get_string('PON','PON_AUCTS_BID_PRICE_R'),        NULL,                         'PON_PYMT_PRICE_WRONG',          -- 1
  'NUM',                        bid_currency_price,            NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_BID_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                  interface_line_id,                   NULL,                          -- 5
  auction_header_id,            auction_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid,                      -- 8
  s_worksheet_name,
  s_worksheet_sequence_number,
  s_entity_name,
  p_request_id
 )
WHEN supplier_can_modify_payments = 'Y' AND
     lookup_payment_type_code = 'RATE' AND quantity IS NULL THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                  error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login,              -- 8
  worksheet_name,
  worksheet_sequence_number,
  entity_message_code,
  REQUEST_ID
 )
VALUES
 (
  fnd_message.get_string('PON','PON_AUCTS_BID_QTY_R'),     NULL,                         'PON_PYMT_QTY_NULL',          -- 1
  'TXT',                        NULL,                         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_BID_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                  interface_line_id,                   NULL,                          -- 5
  auction_header_id,            auction_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid,                      -- 8
  s_worksheet_name,
  s_worksheet_sequence_number,
  s_entity_name,
  p_request_id
 )
WHEN bid_currency_price IS NULL THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                  error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login,              -- 8
  worksheet_name,
  worksheet_sequence_number,
  entity_message_code,
  REQUEST_ID
 )
VALUES
 (
  fnd_message.get_string('PON','PON_AUCTS_BID_PRICE_R'),        NULL,                         'PON_PYMT_BID_PRICE_NULL',          -- 1
  'TXT',                        NULL,                         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_BID_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                  interface_line_id,                   NULL,                          -- 5
  auction_header_id,            auction_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid,                      -- 8
  s_worksheet_name,
  s_worksheet_sequence_number,
  s_entity_name,
  p_request_id
 )
WHEN bid_currency_price IS NOT NULL
AND PON_BID_VALIDATIONS_PKG.validate_price_precision(
			bid_currency_price, pbh_price_precision) = 'F' THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login,              -- 8
  worksheet_name,
  worksheet_sequence_number,
  entity_message_code,
  REQUEST_ID
 )
VALUES
 (
  fnd_message.get_string('PON','PON_AUCTS_BID_PRICE_R'),        NULL,                         'PON_QUOTEPRICE_INVALID_PREC_L', -- 1
  'NUM',                        bid_currency_price,                         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_BID_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                  interface_line_id,                   NULL,                          -- 5
  auction_header_id,            auction_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid,                      -- 8
  s_worksheet_name,
  s_worksheet_sequence_number,
  s_entity_name,
  p_request_id
 )
WHEN promised_date IS NOT NULL AND promised_date <= close_bidding_date THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login,              -- 8
  worksheet_name,
  worksheet_sequence_number,
  entity_message_code,
  REQUEST_ID
 )
VALUES
 (
  fnd_message.get_string('PON','PON_AUCTS_PROMISED_DATE'),      NULL,                         'PON_PYMT_PDATE_LESS_CDATE',          -- 1
  'TIM',                        NULL,                         promised_date,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_BID_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                  interface_line_id,                   NULL,                          -- 5
  auction_header_id,            auction_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid,                      -- 8
  s_worksheet_name,
  s_worksheet_sequence_number,
  s_entity_name,
  p_request_id
 )
 SELECT
  pah.po_style_id,
  nvl(pah.supplier_enterable_pymt_flag,'N') supplier_can_modify_payments,
  pbp.payment_display_number,
  pbp.payment_type,
  pbp.unit_of_measure,
  pbp.interface_line_id interface_line_id,
  pbp.auction_header_id auction_header_id,
  pbp.document_disp_line_number,
  pbp.bid_currency_price,
  pbp.quantity,
  pbp.promised_date,
  DECODE(p_spreadsheet_type, PON_BID_VALIDATIONS_PKG.g_xml_upload_mode, pbp.worksheet_name, NULL) s_worksheet_name,
  DECODE(p_spreadsheet_type, PON_BID_VALIDATIONS_PKG.g_xml_upload_mode, pbp.worksheet_sequence_number, NULL) s_worksheet_sequence_number,
  DECODE(p_spreadsheet_type, PON_BID_VALIDATIONS_PKG.g_xml_upload_mode, l_entity_name, NULL) s_entity_name,
  pai.line_number auction_line_number,
  pai.group_type,
  pai.purchase_basis line_type,
  pai.close_bidding_date,
  uom.uom_code,
  fl.lookup_code lookup_payment_type_code,
  null bid_payment_id,
  pbi.line_number bid_line_number,
  fc.precision fc_precision,
  pbh.number_price_decimals pbh_price_precision
FROM PON_BID_PAYMENTS_INTERFACE pbp,
      PON_AUCTION_ITEM_PRICES_ALL pai,
      PON_BID_ITEM_PRICES pbi,
      PON_AUCTION_HEADERS_ALL pah,
	  MTL_UNITS_OF_MEASURE uom,
      PO_LOOKUP_CODES fl,
	  FND_CURRENCIES fc,
      PON_BID_HEADERS pbh
 WHERE pbp.auction_header_id = pai.auction_header_id (+)
 AND   pbp.document_disp_line_number = pai.document_disp_line_number (+)
 AND   pbp.batch_id = p_batch_id
 AND   pbp.auction_header_id = p_auction_header_id
 AND   pbp.bid_number = p_bid_number
 AND   pah.auction_header_id(+) = pbp.auction_header_id
 AND   pbp.unit_of_measure = uom.unit_of_measure_tl(+)
 AND   uom.language (+) = userenv('LANG')
 AND   pbp.payment_type = fl.displayed_field (+)
 AND   fl.lookup_type(+) = 'PAYMENT TYPE'
 AND   pbi.auction_header_id(+) = pai.auction_header_id
 AND   pbi.line_number(+) = pai.line_number
 AND   fc.currency_code = pah.currency_code
 AND   pbh.bid_number(+) = p_bid_number
 AND   pbi.bid_number(+) = p_bid_number
 ;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'After Insert all for validate_response p_batch_id = '||p_batch_id);
    END IF;


-- This validation is done in a separate sql as this one needs join to
-- pon_auc_payments_shipments and all the other validations don't need them.
INSERT INTO PON_INTERFACE_ERRORS
(
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login,              -- 8
  worksheet_name,
  worksheet_sequence_number,
  entity_message_code,
  REQUEST_ID

 )
SELECT   decode(p_spreadsheet_type, PON_BID_VALIDATIONS_PKG.g_txt_upload_mode, fnd_message.get_string('PON','PON_AUCTS_PAYITEM_NUMBER'), fnd_message.get_string('PON','PON_PAY_ITEM')),
        NULL,                         'PON_LINE_PYMT_INVALID',      -- 1
        'NUM',                       pbp.payment_display_number,    NULL,                         -- 2
        'LINENUM',                   pbp.document_disp_line_number, 'PAYITEMNUM',                 -- 3
         pbp.payment_display_number, l_interface_type,              'PON_BID_PAYMENTS_SHIPMENTS', -- 4
         p_batch_id,                 pbp.interface_line_id,         NULL,                         -- 5
         pbp.auction_header_id,      pai.line_number,               NULL,                         -- 6
         l_exp_date,                 l_userid,                      SYSDATE,                      -- 7
         l_userid,                   SYSDATE,                       l_loginid,                     -- 8
  DECODE(p_spreadsheet_type, PON_BID_VALIDATIONS_PKG.g_xml_upload_mode, pbp.worksheet_name, NULL),
  DECODE(p_spreadsheet_type, PON_BID_VALIDATIONS_PKG.g_xml_upload_mode, pbp.worksheet_sequence_number, NULL),
  DECODE(p_spreadsheet_type, PON_BID_VALIDATIONS_PKG.g_xml_upload_mode, l_entity_name, NULL)         ,
  p_request_id
FROM  PON_BID_PAYMENTS_INTERFACE pbp,
      PON_AUCTION_ITEM_PRICES_ALL pai,
      PON_AUCTION_HEADERS_ALL pah
WHERE pbp.document_disp_line_number = pai.document_disp_line_number
AND   pbp.auction_header_id = pai.auction_header_id
AND   pbp.payment_display_number NOT IN(SELECT pap.payment_display_number
                                        FROM PON_AUC_PAYMENTS_SHIPMENTS pap
                                        WHERE pap.auction_header_id=pbp.auction_header_id
                                        AND pap.line_number=pai.line_number)
AND   pah.auction_header_id = pbp.auction_header_id
AND   pah.supplier_enterable_pymt_flag = 'N'
AND   pbp.batch_id = p_batch_id;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'After valiating for supplier enterable flag for p_batch_id = '||p_batch_id);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            print_error_log(l_module, 'EXCEPTION -  l_progress='||l_progress||' Error Code=' || SQLCODE || ' SQLERRM=' || SQLERRM);
        END if;
END validate_response;

--
PROCEDURE validate_creation (p_source VARCHAR2, p_batch_Id NUMBER) IS
l_userid NUMBER;
l_loginid NUMBER;
l_exp_date DATE;
l_interface_type VARCHAR2(15);
l_module CONSTANT VARCHAR2(32) := 'VALIDATE_CREATION';
l_progress              VARCHAR2(200);
CURSOR l_proj_cursor IS
SELECT papi.interface_line_id, papi.document_disp_line_number,
       pro.project_id, task.task_id, porg.organization_id,
       papi.project_expenditure_type,papi.project_expenditure_item_date,
       papi.auction_header_id, papi.payment_display_number
   FROM   PA_PROJECTS_ALL pro,
          PA_TASKS task,
          HR_ALL_ORGANIZATION_UNITS porg,
          PON_AUC_PAYMENTS_INTERFACE papi
   WHERE  papi.project_number = pro.segment1
   AND    papi.project_task_number = task.task_number
   AND    pro.project_id = task.project_id
   AND    papi.project_exp_organization_name = porg.name
   AND    papi.batch_id = p_batch_id
   AND    papi.project_number IS NOT NULL
   AND    papi.project_task_number IS NOT NULL
   AND    papi.project_expenditure_type IS NOT NULL
   AND    papi.project_exp_organization_name IS NOT NULL
   AND    papi.project_expenditure_item_date IS NOT NULL;

BEGIN

l_userid := fnd_global.user_id;
l_loginid := fnd_global.login_id;
l_exp_date := SYSDATE + 7;
l_interface_type := 'NEGPYMTUPLOAD';

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'Before insert all valiations of validate_creation for p_batch_id = '||p_batch_id);
    END IF;

INSERT ALL
WHEN line_origination_code <> 'REQUISITION' AND project_number IS NOT NULL AND pro_project_id IS NULL THEN
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
  fnd_message.get_string('PON','PON_AUCTS_PROJECT'),          NULL,                         'PON_PROJ_NUM_INVALID',        -- 1
  'TXT',                        Project_number,               NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    NULL,                          -- 3
  NULL,                         l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )

WHEN line_origination_code <> 'REQUISITION'
AND pro_project_id IS NOT NULL
AND project_task_number IS NOT NULL
AND NOT EXISTS (SELECT 1
                  FROM PA_TASKS_EXPEND_V task
                 WHERE task.project_id = pro_project_id AND task.task_number = project_task_number) THEN
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
  fnd_message.get_string('PON','PON_AUCTS_TASK'),             NULL,                         'PON_PROJ_TASK_INVALID',       -- 1
  'TXT',                        project_task_number,           NULL,                         -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN line_origination_code <> 'REQUISITION'
AND pro_project_id IS NOT NULL
AND project_task_number IS NOT NULL
AND project_award_number IS NOT NULL
AND NOT EXISTS (SELECT 1
                  FROM GMS_AWARDS_BASIC_V award,
                       PA_TASKS_EXPEND_V task
                 WHERE award.project_id = pro_project_id
                   AND task.task_number = project_task_number
                   AND award.task_id = task.task_id
                   AND task.project_id = pro_project_id) THEN
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
  fnd_message.get_string('PON','PON_AUCTS_PROJECT_AWARD'),    NULL,                        'PON_PROJ_AWARD_INVALID',      -- 1
  'TXT',                        project_award_number,         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
  WHEN pro_project_id IS NOT NULL
  AND project_award_number IS NULL
  AND PON_NEGOTIATION_PUBLISH_PVT.IS_PROJECT_SPONSORED(pro_project_id) = 'Y' THEN INTO pon_interface_errors
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
  fnd_message.get_string('PON','PON_AUCTS_PROJECT_AWARD'),    NULL,                        'PON_PROJ_AWARD_NULL',      -- 1
  'TXT',                        project_award_number,         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN line_origination_code <> 'REQUISITION' AND project_exp_organization_name IS NOT NULL
AND porg_proj_exp_organization_id IS NULL THEN
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
  fnd_message.get_string('PON','PON_AUCTS_EXPENDITUE_ORG'),   NULL,                         'PON_PROJ_EXPORG_INVALID',     -- 1
  'TXT',                        project_exp_organization_name,NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN line_origination_code <> 'REQUISITION'
AND project_expenditure_type IS NOT NULL
AND NOT EXISTS (SELECT 1
                FROM pa_expenditure_types_expend_v exptype
                WHERE system_linkage_function = 'VI'
                AND exptype.expenditure_type = project_expenditure_type
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
  fnd_message.get_string('PON','PON_AUCTS_EXPENDITUE_TYPE'),   NULL,                         'PON_PROJ_EXPTYPE_INVALID',     -- 1
  'TXT',                        project_expenditure_type,NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN line_origination_code <> 'REQUISITION' AND
 (project_number IS NOT NULL OR project_task_number IS NOT NULL OR project_exp_organization_name IS NOT NULL
    OR project_expenditure_item_date IS NOT NULL OR project_expenditure_type IS NOT NULL)
 AND (project_number IS NULL OR project_task_number IS NULL OR project_exp_organization_name IS NULL
    OR project_expenditure_item_date IS NULL OR project_expenditure_type IS NULL) THEN
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
  fnd_message.get_string('PON','PON_AUCTS_PROJECT'),          NULL,                         'PON_PROJ_INFO_INCOMPLETE_P',       -- 1
  'TXT',                        NULL,                         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN ship_to_location_code IS NOT NULL AND ship_to_location_id IS NULL THEN
 INTO pon_interface_errors
 (
  column_name,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  payment_id,                    -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  fnd_message.get_string('PON','PON_AUCTS_SHIPTO'),           NULL,                         'PONPYMT_SHIPTO_INVALID',      -- 1
  'TXT',                        ship_to_location_code,        NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN unit_of_measure IS NOT NULL AND uom_uom_code IS NULL THEN
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
  fnd_message.get_string('PON','PON_AUCTS_UOM'),              NULL,                         'PON_UOM_INVALID',             -- 1
  'TXT',                        unit_of_measure,              NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN work_approver_user_name IS NOT NULL
AND NOT EXISTS (SELECT 1
                  FROM PER_WORKFORCE_CURRENT_X peo,
                       FND_USER fu
                 WHERE fu.user_name = work_approver_user_name
                   AND fu.employee_id = peo.person_id
				   AND SYSDATE >= nvl(fu.start_date, SYSDATE)
				   AND SYSDATE <= nvl(fu.end_date, SYSDATE) ) THEN
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
  fnd_message.get_string('PON','PON_AUCTS_OWNER'),            NULL,                         'PON_PYMT_OWNER_INVALID',      -- 1
  'TXT',                        work_approver_user_name,      NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
-- For GOODS based line only MILESTONE payments should be allowed. Otherwise throw an error
-- If the payment type entered in the spreadsheet is not from a fnd lookup then throw an error
-- If pay item entered is not supported by the purchasing style then throw an error.

WHEN ((line_type = 'GOODS' AND  lookup_payment_type_code <> 'MILESTONE') OR
      (payment_type IS NOT NULL AND lookup_payment_type_code IS NULL) OR
      (lookup_payment_type_code IS NOT NULL AND lookup_payment_type_code NOT IN
        (SELECT pay_item_type FROM PO_STYLE_ENABLED_PAY_ITEMS WHERE style_id = po_style_id))) THEN
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
  fnd_message.get_string('PON','PON_AUCTS_PAYITEM_TYPE'),     NULL,                        'PON_PYMT_TYPE_INVALID',       -- 1
  'TXT',                        payment_type,                 NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN auction_line_number IS NULL THEN
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
  fnd_message.get_string('PON','PON_AUCTS_LINENUMBER'),       NULL,                         'PON_INVALID_LINE_NUM',        -- 1
  'TXT',                        document_disp_line_number,    NULL,                          -- 2
  null,                         null,    NULL,                          -- 3
   NULL,                        l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN auction_line_number IS NOT NULL and group_type IN ('GROUP','LOT_LINE') THEN
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
  fnd_message.get_string('PON','PON_AUCTS_LINENUMBER'),       NULL,                         'PON_PYMT_NOTALLOWED',         -- 1
  'TXT',                        document_disp_line_number,    NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    NULL,                          -- 3
   NULL,                        l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN lookup_payment_type_code = 'RATE' AND unit_of_measure IS NULL THEN
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
  fnd_message.get_string('PON','PON_AUCTS_UOM'),              NULL,                         'PON_PYMT_UOM_NULL',           -- 1
  'TXT',                        NULL,                         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN payment_display_number < 1 OR payment_display_number<> ROUND(payment_display_number) THEN
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
  fnd_message.get_string('PON','PON_AUCTS_PAYITEM_NUMBER'),   NULL,                        'PON_PYMT_NUM_WRONG',           -- 1
  'TXT',                        payment_display_number,       NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN lookup_payment_type_code = 'RATE' AND quantity < 0 THEN
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
  fnd_message.get_string('PON','PON_AUCTS_QUANTITY'),         NULL,                        'PON_PYMT_QTY_WRONG',           -- 1
  'NUM',                        quantity,                     NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
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
  fnd_message.get_string('PON','PON_AUCTS_TARGET_PRICE'),     NULL,                        'PON_PYMT_TPRICE_WRONG',        -- 1
  'NUM',                        target_price,                 NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN payment_display_number IS NULL THEN
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
  fnd_message.get_string('PON','PON_AUCTS_PAYITEM_NUMBER'),   NULL,                        'PON_PYMT_NUM_MISSING',         -- 1
  'TXT',                        payment_display_number,       NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    null,                  -- 3
   NULL,                        l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN payment_type IS NULL THEN
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
  fnd_message.get_string('PON','PON_AUCTS_PAYITEM_TYPE'),     NULL,                        'PON_PYMT_TYPE_NULL',           -- 1
  'TXT',                        payment_type,            NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
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
  fnd_message.get_string('PON','PON_AUCTS_PAYMENT_DESC'),     NULL,                        'PON_PYMT_DESC_NULL',           -- 1
  'TXT',                        payment_description,          NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN lookup_payment_type_code = 'RATE' AND quantity IS NULL THEN
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
  fnd_message.get_string('PON','PON_AUCTS_QUANTITY'),         NULL,                        'PON_PYMT_QTY_NULL',            -- 1
  'TXT',                        NULL,                         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN need_by_date IS NOT NULL AND need_by_date < pah_close_bidding_date THEN
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
  fnd_message.get_string('PON','PON_AUCTS_NEEDBY'),           NULL,                        'PON_PYMT_NDATE_LESS_CDATE',    -- 1
  'TIM',                        NULL,                        need_by_date,                   -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
   payment_display_number,      l_interface_type,             'PON_AUC_PAYMENTS_INTERFACE',  -- 4
  p_batch_id,                   interface_line_id,            NULL,                          -- 5
  auction_header_id,            auction_line_number,    NULL,                          -- 6
  l_exp_date,                   l_userid,                     SYSDATE,                       -- 7
  l_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
SELECT
  ppi.project_number project_number,
  ppi.project_task_number ,
  ppi.project_expenditure_type,
  ppi.project_exp_organization_name,
  ppi.project_expenditure_item_date,
  ppi.project_award_number ,
  ppi.payment_display_number,
  ppi.payment_type,
  ppi.unit_of_measure,
  ppi.interface_line_id interface_line_id,
  ppi.auction_header_id auction_header_id,
  ppi.document_disp_line_number,
  ppi.work_approver_user_name,
  ppi.ship_to_location_code,
  ppi.target_price,
  ppi.quantity,
  ppi.payment_description,
  ppi.need_by_date,
  pah.close_bidding_date pah_close_bidding_date,
  pah.po_style_id,
  pai.line_number auction_line_number,
  pai.group_type,
  pai.purchase_basis line_type,
  NVL(pai.line_origination_code,'-9997') line_origination_code,
  uom.uom_code uom_uom_code,
  pro.project_id pro_project_id,
  porg.organization_id porg_proj_exp_organization_id,
  ship.location_id ship_to_location_id,
  fl.lookup_code lookup_payment_type_code
 FROM PON_AUC_PAYMENTS_INTERFACE ppi,
      PON_AUCTION_ITEM_PRICES_ALL pai,
      PON_AUCTION_HEADERS_ALL pah,
      PO_SHIP_TO_LOC_ORG_V ship,
      FINANCIALS_SYSTEM_PARAMS_ALL fsp,
	  MTL_UNITS_OF_MEASURE uom,
      PO_LOOKUP_CODES fl,
	  PA_PROJECTS_EXPEND_V pro,
	  PA_ORGANIZATIONS_EXPEND_V porg
 WHERE ppi.auction_header_id = pai.auction_header_id (+)
 AND   ppi.document_disp_line_number = pai.document_disp_line_number (+)
 AND   ppi.batch_id = p_batch_id
 AND   pah.auction_header_id = ppi.auction_header_id
 AND   ppi.project_number = pro.project_number(+)
 AND   ppi.project_exp_organization_name = porg.name(+)
 AND   ppi.unit_of_measure = uom.unit_of_measure_tl(+)
 AND   uom.language (+) = userenv('LANG')
 AND   ppi.payment_type = fl.displayed_field (+)
 AND   fl.lookup_type(+) = 'PAYMENT TYPE'
 AND   pah.org_id = fsp.org_id (+)
 AND   (ship.set_of_books_id IS NULL OR ship.set_of_books_id = fsp.set_of_books_id)
 AND   ppi.ship_to_location_code = ship.location_code(+)
 AND ((nvl(pai.line_origination_code,'N') <> 'REQUISITION')
       OR
      (nvl(pai.line_origination_code,'N') = 'REQUISITION' AND
       (ship.inventory_organization_id is null
        or nvl(ship.inventory_organization_id,-1) = ( SELECT nvl(pr.destination_organization_id,-1)
                                                     FROM  po_requisition_lines_all pr,PON_BACKING_REQUISITIONS pbr
                                                     WHERE pbr.auction_header_id= pai.auction_header_id
                                                     AND   pbr.line_number = pai.line_number
                                                     AND pbr.requisition_line_id = pr.requisition_line_id))));

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'After insert all valiations of validate_creation for p_batch_id = '||p_batch_id);
    END IF;

  --Validate project fields with PATC
    FOR l_proj_record IN l_proj_cursor LOOP
      IF l_proj_record.project_id IS NOT NULL AND
         l_proj_record.task_id IS NOT NULL AND
         l_proj_record.organization_id IS NOT NULL THEN

          PON_NEGOTIATION_PUBLISH_PVT.VALIDATE_PROJECTS_DETAILS (
              p_project_id                => l_proj_record.project_id,
              p_task_id                   => l_proj_record.task_id,
              p_expenditure_date          => l_proj_record.project_expenditure_item_date,
              p_expenditure_type          => l_proj_record.project_expenditure_type,
              p_expenditure_org           => l_proj_record.organization_id,
              p_person_id                 => null,
              p_auction_header_id         => l_proj_record.auction_header_id,
              p_line_number               => null,
              p_document_disp_line_number => l_proj_record.document_disp_line_number,
              p_payment_id                => null,
              p_interface_line_id         => l_proj_record.interface_line_id,
              p_payment_display_number    => l_proj_record.payment_display_number,
              p_batch_id                  => p_batch_id,
              p_table_name                => 'PON_AUC_PAYMENTS_INTERFACE',
              p_interface_type            => l_interface_type,
              p_entity_type               => null,
              p_called_from               => 'PAYMENTS_SP');
        END IF;
    END LOOP;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'After calling projects validations for p_batch_id = '||p_batch_id);
    END IF;
EXCEPTION

    WHEN OTHERS THEN
        IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            print_error_log(l_module, 'EXCEPTION -  l_progress='||l_progress||' Error Code=' || SQLCODE || ' SQLERRM=' || SQLERRM);
        END if;
END validate_creation;
--

PROCEDURE copy_payments_from_int_to_txn(
          p_batch_id	IN pon_bid_item_prices_interface.batch_id%TYPE,
          p_spreadsheet_type  IN VARCHAR2,
          p_bid_number         IN NUMBER,
          p_auction_header_id  IN NUMBER,
          x_result                OUT NOCOPY VARCHAR2, -- S: Success, E: failure
          x_error_code            OUT NOCOPY VARCHAR2,
          x_error_message         OUT NOCOPY VARCHAR2)
IS
l_rate  pon_bid_headers.rate%TYPE;
l_sequence              NUMBER :=0;
l_previous_line_number  NUMBER := -99;
l_module CONSTANT VARCHAR2(32) := 'COPY_PAYMENTS_FROM_INT_TO_TXN';
l_progress              varchar2(200);
l_supplier_enterable_pymt_flag pon_auction_headers_all.supplier_enterable_pymt_flag%TYPE;

CURSOR delete_pymt_attachments_cursor IS
        SELECT fnd.pk3_value bid_payment_id, -- bid payment id
               fnd.pk1_value bid_number, -- bid number
               fnd.pk2_value bid_line_number -- bid line number
    FROM   FND_ATTACHED_DOCUMENTS fnd
    WHERE  fnd.pk1_value = p_bid_number
    AND    fnd.pk3_value NOT IN (SELECT bid_payment_id
                                 FROM PON_BID_PAYMENTS_SHIPMENTS pbps
                                 WHERE pbps.bid_number = p_bid_number)
    AND    fnd.entity_name = 'PON_BID_PAYMENTS_SHIPMENTS';


CURSOR l_attachment_cursor
IS
  SELECT pbpi.attachment_desc,
         pbpi.attachment_url,
         pbps.bid_payment_id,
         pbps.bid_number,
         pbps.bid_line_number,
         pbpi.document_disp_line_number
  FROM   pon_bid_payments_interface pbpi,
         pon_auction_item_prices_all pai,
         pon_bid_payments_shipments pbps
  WHERE  pbpi.auction_header_id = pai.auction_header_id
  AND    pbpi.document_disp_line_number = pai.document_disp_line_number
  AND    pbps.auction_header_id = pai.auction_header_id
  AND    pbps.bid_line_number = pai.line_number
  AND    pbps.payment_display_number = pbpi.payment_display_number
  AND    pbpi.batch_id = p_batch_id
  AND    pbpi.attachment_desc IS NOT NULL;
BEGIN

    x_result := 'S';

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'COPY_PAYMENTS_FROM_INT_TO_TXN  START p_batch_id = '||p_batch_id);
    END IF;

    -- select some variables that we need for currency conversion
    SELECT  distinct pbh.rate
    INTO    l_rate
    FROM    pon_bid_headers pbh,
            pon_bid_payments_interface pbpi
    WHERE   pbpi.bid_number = pbh.bid_number
    AND     pbpi.batch_id = p_batch_id;

	-- Update lines table with values in the interface table
	MERGE INTO pon_bid_payments_shipments bl
	USING
		(SELECT
		    pbpi.auction_header_id,
			pbpi.bid_number,
			pbpi.document_disp_line_number,
			pbpi.batch_id,
			pbpi.interface_line_id,
            DECODE(fl.lookup_code, 'RATE', pbpi.QUANTITY, NULL) QUANTITY,
            DECODE(fl.lookup_code, 'RATE', uom.uom_code, NULL) UOM_CODE,
			pbpi.bid_currency_price,
			pbpi.payment_display_number,
			pbpi.payment_description,
			fl.lookup_code payment_type_code,
			pbpi.promised_date,
			pbip.line_number line_number,
			nvl(pah.supplier_enterable_pymt_flag,'N') supplier_can_modify_pymts
		FROM pon_bid_payments_interface pbpi,
		     pon_auction_item_prices_all paip,
		     pon_auction_headers_all pah,
		     pon_bid_item_prices pbip,
             MTL_UNITS_OF_MEASURE uom,
             PO_LOOKUP_CODES fl
		WHERE pbpi.batch_id = p_batch_id
        AND   pbpi.auction_header_id = p_auction_header_id
        AND   pbpi.bid_number = p_bid_number
        AND   pbpi.auction_header_id = paip.auction_header_id
        AND   pbpi.document_disp_line_number = paip.document_disp_line_number
        AND   pah.auction_header_id = pbpi.auction_header_id
        AND   pbip.bid_number = pbpi.bid_number
        AND   pbip.auction_header_id = paip.auction_header_id
        AND   pbip.line_number = paip.line_number
        AND   pbpi.unit_of_measure = uom.unit_of_measure_tl(+)
        AND   uom.language (+) = userenv('LANG')
        AND   pbpi.payment_type = fl.displayed_field (+)
        AND   fl.lookup_type(+) = 'PAYMENT TYPE'
        ) bli
	ON (bl.bid_number = bli.bid_number
		AND bl.bid_line_number = bli.line_number
		AND bl.auction_header_id = bli.auction_header_id
        AND bl.payment_display_number = bli.payment_display_number)
	WHEN MATCHED THEN
		UPDATE SET
			bl.payment_description 		    = decode(bli.supplier_can_modify_pymts, 'Y',bli.payment_description,'N',bl.payment_description),
			bl.payment_type_code 		    = decode(bli.supplier_can_modify_pymts, 'Y',bli.payment_type_code,'N',bl.payment_type_code),
			bl.quantity 					= decode(bli.supplier_can_modify_pymts, 'Y',bli.quantity,'N',bl.quantity),
			bl.uom_code 					= decode(bli.supplier_can_modify_pymts, 'Y',bli.uom_code,'N',bl.uom_code),
			bl.bid_currency_price 		    = bli.bid_currency_price,
			bl.price 		                = bli.bid_currency_price/nvl(l_rate,1),	--auction currency price
			bl.promised_date 				= bli.promised_date,
			bl.last_update_date				= sysdate,
			bl.last_updated_by				= fnd_global.user_id,
			bl.last_update_login			= fnd_global.login_id
	WHEN NOT MATCHED THEN
	     INSERT (
	            BID_PAYMENT_ID                    ,
	            AUCTION_HEADER_ID                 ,
	            BID_LINE_NUMBER                   ,
	            AUCTION_LINE_NUMBER               ,
	            BID_NUMBER                        ,
	            PAYMENT_DISPLAY_NUMBER            ,
	            PAYMENT_DESCRIPTION               ,
	            PAYMENT_TYPE_CODE                 ,
	            QUANTITY                          ,
	            UOM_CODE                          ,
	            BID_CURRENCY_PRICE                ,
	            PRICE                             , -- Auction Currency price
	            PROMISED_DATE                     ,
	            CREATION_DATE                     ,
	            CREATED_BY                        ,
	            LAST_UPDATE_DATE                  ,
	            LAST_UPDATED_BY                   ,
	            LAST_UPDATE_LOGIN
	            )
	     VALUES (
	            PON_BID_PAYMENTS_SHIPMENTS_S1.nextval   ,
	            bli.AUCTION_HEADER_ID                 ,
	            bli.LINE_NUMBER                       ,
	            bli.LINE_NUMBER                       ,
	            bli.BID_NUMBER                        ,
	            bli.PAYMENT_DISPLAY_NUMBER            ,
	            bli.PAYMENT_DESCRIPTION               ,
	            bli.PAYMENT_TYPE_CODE                 ,
	            bli.QUANTITY                          ,
	            bli.UOM_CODE                          ,
	            bli.BID_CURRENCY_PRICE                ,
	            bli.BID_CURRENCY_PRICE/nvl(l_rate,1)  ,  --Auction currency price
	            bli.PROMISED_DATE                     ,
	            SYSDATE                               ,
	            fnd_global.user_id                    ,
	            SYSDATE                               ,
	            fnd_global.user_id                    ,
	            fnd_global.login_id
	            ) ;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        l_progress := 'Merge into pon_bid_payments_shipments is successful for batch_id = '||p_batch_id;
    END if;

    IF (p_spreadsheet_type = PON_BID_VALIDATIONS_PKG.g_txt_upload_mode) THEN
      --create URL Attachments
      FOR l_attachment_record IN l_attachment_cursor LOOP

         IF l_attachment_record.document_disp_line_number <> l_previous_line_number THEN
            l_sequence := 1;
            l_previous_line_number := l_attachment_record.document_disp_line_number;
         ELSE
            l_sequence := l_sequence+1;

         END IF;

         PON_OA_UTIL_PKG.create_url_attachment(
          p_seq_num                 => l_sequence,
          p_category_name           => 'FromSupplier',
          p_document_description    => l_attachment_record.attachment_desc,
          p_datatype_id             => 5,
          p_url                     => l_attachment_record.attachment_url,
          p_entity_name             => 'PON_BID_PAYMENTS_SHIPMENTS',
          p_pk1_value               => l_attachment_record.bid_number,
          p_pk2_value               => l_attachment_record.bid_line_number,
          p_pk3_value               => l_attachment_record.bid_payment_id,
          p_pk4_value               => NULL,
          p_pk5_value               => NULL);
      END LOOP;
    ELSE --i.e (p_spreadsheet_type = 'XML')

      SELECT supplier_enterable_pymt_flag
      INTO l_supplier_enterable_pymt_flag
      FROM PON_AUCTION_HEADERS_ALL
      WHERE auction_header_id = p_auction_header_id;

      IF l_supplier_enterable_pymt_flag = 'Y' THEN
        DELETE FROM PON_BID_PAYMENTS_SHIPMENTS pbp
        WHERE pbp.payment_display_number NOT IN (SELECT pbpi.payment_display_number
	                                               FROM PON_BID_PAYMENTS_INTERFACE pbpi,
	                                                    PON_AUCTION_ITEM_PRICES_ALL pai
        										  WHERE pbpi.batch_id = p_batch_id
													AND pbpi.bid_number = p_bid_number
													AND pai.auction_header_id = pbpi.auction_header_id
													AND pai.document_disp_line_number = pbpi.document_disp_line_number
                                                    AND pbp.bid_line_number = pai.line_number)
        AND pbp.bid_number = p_bid_number
		AND pbp.bid_line_number IN (SELECT pbi.line_number FROM PON_BID_ITEM_PRICES_INTERFACE pbi WHERE pbi.batch_id = p_batch_id);

      -- To delete attachments of pon_bid_payments_shipments
      FOR delete_pymt_attachments_record IN delete_pymt_attachments_cursor
      LOOP
          FND_ATTACHED_DOCUMENTS2_PKG.DELETE_ATTACHMENTS
          (x_entity_name  => 'PON_BID_PAYMENTS_SHIPMENTS',
           x_pk1_value => delete_pymt_attachments_record.bid_number,
           x_pk2_value => delete_pymt_attachments_record.bid_line_number,
           x_pk3_value => delete_pymt_attachments_record.bid_payment_id);
      END LOOP;
     END IF; -- End of suppliers can modify flag

    END IF;


    IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        l_progress := 'creting URL Attachments is complete for p_batch_id = '||p_batch_id;
    END if;


    --before deleting, set the is_changed_line_flag column for the lines for which
    --payments are uploaded in this batch
    UPDATE pon_bid_item_prices pbip SET pbip.IS_CHANGED_LINE_FLAG = 'Y',
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = FND_GLOBAL.user_id
    WHERE pbip.line_number IN (
      SELECT paip.line_number FROM pon_auction_item_prices_all paip, pon_bid_payments_interface pbpi, pon_bid_payments_shipments pbps WHERE
      pbpi.batch_id = p_batch_id AND
      paip.auction_header_id = pbpi.auction_header_id AND
      pbpi.document_disp_line_number = paip.document_disp_line_number AND
      pbps.AUCTION_LINE_NUMBER = paip.line_number AND
      pbps.AUCTION_HEADER_ID = paip.auction_header_id AND
      pbps.BID_NUMBER = pbpi.bid_number AND
      (
        pbps.Old_Payment_Display_Number<> pbps.Payment_Display_Number OR
        pbps.Old_Payment_Type_Code<> pbps.Payment_Type_Code OR
        pbps.Old_Payment_Description<> pbps.Payment_Description OR
        pbps.Old_Quantity<> pbps.Quantity OR
        pbps.Old_Uom_Code<> pbps.Uom_Code OR
        pbps.Old_Bid_Currency_Price<> pbps.Bid_Currency_Price OR
        pbps.Old_Promised_Date<> pbps.Promised_Date
      )
    );


    -- Clear the interface tables
    delete from pon_bid_payments_interface where batch_id = p_batch_id;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        l_progress := 'delete from pon_bid_payments_interface completed for p_batch_id = '||p_batch_id;
    END if;

EXCEPTION
    WHEN OTHERS THEN
        x_result := 'E';
        x_error_code := SQLCODE;
        x_error_message := SUBSTR(SQLERRM, 1, 100);
        IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            print_error_log(l_module, 'EXCEPTION -  l_progress='||l_progress||' x_result=' || x_result || ' x_error_code=' || x_error_code || ' x_error_message=' || x_error_message || ' SQLERRM=' || SQLERRM);
        END if;
END copy_payments_from_int_to_txn;


/*======================================================================
 PROCEDURE:  PRINT_ERROR_LOG    PRIVATE
   PARAMETERS:
   COMMENT   :  This procedure is used to print unexpected exceptions or
                error  messages into FND logs
======================================================================*/

PROCEDURE print_error_log(p_module   IN    VARCHAR2,
                          p_message  IN    VARCHAR2)
IS
BEGIN

IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
     FND_LOG.string(log_level => FND_LOG.level_procedure,
                     module    =>  g_module_prefix || p_module,
                     message   => p_message);
END if;

END;

/*======================================================================
 PROCEDURE:  PRINT_DEBUG_LOG    PRIVATE
   PARAMETERS:
   COMMENT   :  This procedure is used to print debug messages into
                FND logs
======================================================================*/
PROCEDURE print_debug_log(p_module   IN    VARCHAR2,
                          p_message  IN    VARCHAR2)
IS

BEGIN

IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string(log_level => FND_LOG.level_statement,
                        module  =>  g_module_prefix || p_module,
                        message  => p_message);
END if;

END;
END pon_validate_payments_int;

/
