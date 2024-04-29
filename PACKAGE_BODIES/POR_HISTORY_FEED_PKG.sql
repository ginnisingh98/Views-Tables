--------------------------------------------------------
--  DDL for Package Body POR_HISTORY_FEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_HISTORY_FEED_PKG" AS
/* $Header: PORHSFDB.pls 120.6 2006/08/25 23:08:57 tolick noship $ */

  --global variables
  -- Logging Static Variables
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(30) := 'PO.PLSQL.POR_HISTORY_FEED_PKG';

  -- Concurrent Program Input Parameters
  g_card_brand           VARCHAR2(25) := NULL;    -- Card brand Name
  g_card_issuer_id       NUMBER := 0;             -- Card Issuer
  g_card_issuer_site_id  NUMBER := 0;             -- Card Isuer Site
  g_from_date_time       DATE := NULL;            -- From Date
  g_to_date_time         DATE := NULL;            -- To Date
  g_output_filename      VARCHAR2(80) := NULL;

  g_inv_org_id           NUMBER := 0;             -- Inventory Organization
  g_delimiter            VARCHAR2(1) := NULL;     -- Account structure delimiter character
                                                  -- that needs to be replaced by
                                                  -- ; (AMEX character)
  g_outfile              UTL_FILE.FILE_TYPE;

  --***NOTE:  Format_id is a defaulted for this release to identify different...
  g_format_id           NUMBER := 1;
  --...file formats. When other card issuers are supported in the future, a format
  --table should be created where the primary key should be format_id.  This is
  --the hook for future use.  Format_id replaces need for card issuer ID and
  --card issuer site ID to identify the field formats.

  g_created_by	    NUMBER := TO_NUMBER(fnd_profile.value ('USER_ID'));
  g_last_updated_by NUMBER := TO_NUMBER (fnd_profile.value ('USER_ID'));
  g_last_update_login NUMBER := TO_NUMBER (fnd_profile.value ('LOGIN_ID'));
  g_conc_req_id       NUMBER := TO_NUMBER (FND_PROFILE.value('CONC_REQUEST_ID'));
  g_org_id       NUMBER := TO_NUMBER (FND_PROFILE.value('ORG_ID'));

  g_po_num_err VARCHAR2(2000) :=  NULL;
  g_card_num_err VARCHAR2(2000) := NULL;
  g_max_card_num_size NUMBER := 0;           -- maximum card size that is acceptable by AMEX :16
  g_max_po_num_size   NUMBER := 0;           -- maximum po number size that is acceptable by AMEX : 15

  --global cursor for use by write_control_record and write_header_records;
  CURSOR g_cur_po_headers IS
    SELECT po_header_id,
           po_release_id,
           concurrent_request_id
      FROM por_feed_records
     WHERE concurrent_request_id = g_conc_req_id
  GROUP BY po_header_id,
           po_release_id,
           concurrent_request_id;

------------------------------------------------------------------------------
--This function returns the predefined length of a column to be written.  The
--length definition must be seeded in the por_feed_field_formats table.
-------------------------------------------------------------------------------

FUNCTION Get_Field_Size (
  i_column IN VARCHAR2,
  i_record_type IN VARCHAR2) RETURN NUMBER IS

  l_size NUMBER := 0;

BEGIN

  SELECT field_length
    INTO l_size
    FROM por_feed_field_formats
   WHERE column_name = i_column
     AND record_type = i_record_type
     AND format_id = g_format_id
     AND effective_date <= SYSDATE
     AND expiration_date IS NULL;

  RETURN l_size;

EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
      RAISE;

END Get_Field_Size;

-------------------------------------------------------------------------------
--This procedure writes detail records for valid PO distributions to the output file.
-------------------------------------------------------------------------------

PROCEDURE Write_Detail_Record (
  i_po_id IN NUMBER,
  i_rel_id IN NUMBER) IS

  CURSOR cur_po_lines (i_po_header_id IN NUMBER,
                       i_release_id IN NUMBER) IS

  SELECT
    po_number,
    release_number,
    quantity,
    unit_of_measure,
    unit_price,
    amount,
    item_description,
    chart_of_accounts_id,
    accounting_code,
    item_number,
    line_cancel_flag,
    shipment_cancel_flag
  FROM
    por_feed_records
  WHERE
        po_header_id = i_po_header_id
    AND po_release_id = i_release_id
    AND concurrent_request_id = g_conc_req_id;

  l_distr_line_number    NUMBER := 0;
  l_cr_dr_indicator      VARCHAR2(1) := NULL;
  l_po_number            por_feed_records.po_number%TYPE := NULL;
  l_line_num             NUMBER := 0;
  l_detail_record        VARCHAR2(2000) := NULL;


  CURSOR cur_field_order IS

  SELECT column_name,
         field_length,
         default_value,
         pad_character
    FROM por_feed_field_formats
   WHERE format_id = g_format_id
     AND record_type = 'D'
     AND effective_date <= SYSDATE
     AND expiration_date IS NULL
   ORDER BY start_position;

  l_column_name VARCHAR2(100) := NULL;
  l_default_value VARCHAR2(50) := NULL;
  l_field_length NUMBER := 0;
  l_pad_char VARCHAR2(1) := NULL;

  e_do_not_send_distr EXCEPTION;
  l_log_msg              FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_progress            VARCHAR2(4) := '000';

BEGIN

  l_progress := '000';

  IF cur_PO_lines%ISOPEN THEN
    CLOSE cur_PO_lines;
  END IF;

  FOR rec_line IN cur_po_lines (i_po_id,i_rel_id) LOOP
  BEGIN

    l_progress := '010';

    IF rec_line.line_cancel_flag = 'Y' OR rec_line.shipment_cancel_flag = 'Y' THEN
      RAISE e_do_not_send_distr;
    END IF;

    IF rec_line.release_number = 0 THEN
      l_po_number := LTRIM(RTRIM(rec_line.po_number));
    ELSE
      l_po_number := LTRIM(RTRIM(rec_line.po_number)) || '-' || rec_line.release_number;
    END IF;

    l_line_num := l_line_num + 1;

--fnd_file.put_line(fnd_file.log, 'line # : ' || to_char(l_line_num));

    IF rec_line.amount >= 0 THEN
      l_cr_dr_indicator := 'D';
    ELSE
      l_cr_dr_indicator := 'C';
    END IF;

    --build record to write fields in start position order

    l_detail_record := NULL; --initialize for writing

    l_progress := '020';

    FOR rec_field in cur_field_order
    LOOP

      l_column_name := rec_field.column_name;
      l_default_value := rec_field.default_value;
      l_field_length := rec_field.field_length;
      l_pad_char := rec_field.pad_character;

      IF l_column_name = 'RECORD_TYPE_INDICATOR' THEN
        l_detail_record := l_detail_record ||
        RPAD(NVL(l_default_value,' '),l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'CM_REF_INDICATOR' THEN
        l_detail_record := l_detail_record ||
        RPAD(NVL(l_default_value,' '),l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'PO_NUMBER' THEN
        l_detail_record := l_detail_record ||
        RPAD(l_po_number,l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'PO_LINE_NUMBER' THEN
        l_detail_record := l_detail_record ||
        LPAD(l_line_num,l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'QUANTITY' THEN
        l_detail_record := l_detail_record ||
        ltrim(to_char(rec_line.quantity,'0999999.90'));
      ELSIF l_column_name = 'UOM' THEN
        l_detail_record := l_detail_record ||
        RPAD(rec_line.unit_of_measure,l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'UNIT_PRICE' THEN
        l_detail_record := l_detail_record ||
        ltrim(to_char(rec_line.unit_price,'0999999.90'));
      ELSIF l_column_name = 'ITEM_DESCRIPTION' THEN
        l_detail_record := l_detail_record ||
        RPAD(NVL(SUBSTR(rec_line.item_description,1,l_field_length),' '),
             l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'ACCOUNTING_CODE' THEN
        l_detail_record := l_detail_record ||
        RPAD(SUBSTR(REPLACE(SUBSTR(rec_line.accounting_code,1,l_field_length),g_delimiter,';'),1,l_field_length),
             l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'CLIENT_INV_NUMBER' THEN
        l_detail_record := l_detail_record ||
        RPAD(NVL(SUBSTR(rec_line.item_number,1,l_field_length),' '),l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'UN_SPSC_CODE' THEN
        l_detail_record := l_detail_record ||
        RPAD(NVL(l_default_value,' '),l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'RECEIPT_INDICATOR' THEN
        l_detail_record := l_detail_record ||
        RPAD(NVL(l_default_value,' '),l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'LINE_DETAIL_MISC' THEN
        l_detail_record := l_detail_record ||
        RPAD(NVL(l_default_value,' '),l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'CR_DR_INDICATOR' THEN
        l_detail_record := l_detail_record ||
        RPAD(l_cr_dr_indicator,l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'VENDOR_PART_NUMBER' THEN
        l_detail_record := l_detail_record ||
        RPAD(NVL(l_default_value,' '),l_field_length,NVL(l_pad_char,' '));
      END IF;

    END LOOP;

    l_progress := '030';

    IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||'Main', 'Detail Record = ' || l_detail_record);
    END IF;

    UTL_FILE.PUT_LINE(g_outfile,l_detail_record);

    l_progress := '040';

  EXCEPTION

    WHEN e_do_not_send_distr THEN
      NULL;   --do not write a canceled line or shipment to the file

    WHEN NO_DATA_FOUND THEN
      NULL;

    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error writing detail for PO #: ' || l_po_number || '. ' ||
        SUBSTR(SQLERRM,1,300));

  END;

  END LOOP;

  l_progress := '050';

EXCEPTION
  WHEN OTHERS THEN
    IF (G_LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Error in Write_Detail_Record : SQLERRM= ' ||
                         SQLERRM || ' : Progress= ' || l_progress;
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||'Write_Detail_Record', l_log_msg);
    END IF;

    RAISE;

END Write_Detail_Record;


-------------------------------------------------------------------------------
--This procedure writes header records for valid PO distributions to the output file.
-------------------------------------------------------------------------------

PROCEDURE Write_Header_Record IS

  l_po_number por_feed_records.po_number%TYPE := NULL;
  l_card_member_name por_feed_records.card_member_name%TYPE := NULL;
  l_requester_name HR_EMPLOYEES.FULL_NAME%TYPE := NULL;
  l_requester_id por_feed_records.requester_id%TYPE := NULL;
  l_payment_type_indicator VARCHAR2(1) := NULL;
  l_order_status VARCHAR2(2):= NULL;
  l_cr_dr_indicator VARCHAR2(1) := NULL;
  l_card_number VARCHAR2(80) := NULL;
  l_release_number por_feed_records.release_number%TYPE := 0;
  l_card_type_lookup_code por_feed_records.card_type_lookup_code%TYPE := NULL;
  l_vendor_name por_feed_records.vendor_name%TYPE := NULL;
  l_vendor_id por_feed_records.vendor_id%TYPE := 0;
  l_vendor_site_id por_feed_records.vendor_site_id%TYPE := 0;
  l_vendor_site_code por_feed_records.vendor_site_code%TYPE := NULL;
  l_order_date por_feed_records.order_date%TYPE := NULL;
  l_base_currency_code por_feed_records.base_currency_code%TYPE := NULL;
  l_local_currency_code por_feed_records.local_currency_code%TYPE := NULL;
  l_po_header_amount por_feed_records.po_header_amount%TYPE := NULL;
  l_approval_status por_feed_records.approval_status%TYPE := NULL;
  l_control_status por_feed_records.control_status%TYPE := NULL;
  l_approved_date por_feed_records.approved_date%TYPE := NULL;
  l_cancel_flag por_feed_records.cancel_flag%TYPE := NULL;
  l_hold_flag por_feed_records.hold_flag%TYPE := NULL;
  l_line_cancel_flag por_feed_records.line_cancel_flag%TYPE := NULL;
  l_shipment_cancel_flag por_feed_records.shipment_cancel_flag%TYPE := NULL;

  l_object_type VARCHAR2(1) := NULL;
  l_object_id NUMBER := 0;
  l_char VARCHAR2(1) := NULL;

  l_total_distr_records  NUMBER := 0;
  l_total_local_amount   NUMBER := 0;

  l_header_record VARCHAR2(2000) := NULL;

  e_do_not_send_po EXCEPTION;

  CURSOR cur_field_order IS

  SELECT column_name,
         field_length,
         default_value,
         pad_character
    FROM por_feed_field_formats
   WHERE format_id = g_format_id
     AND record_type = 'H'
     AND effective_date <= SYSDATE
     AND expiration_date IS NULL
   ORDER BY start_position;

  l_column_name VARCHAR2(100) := NULL;
  l_default_value VARCHAR2(50) := NULL;
  l_field_length NUMBER := 0;
  l_pad_char VARCHAR2(1) := NULL;

  l_log_msg              FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_progress            VARCHAR2(4) := '000';

BEGIN

  l_progress := '000';

  IF g_cur_po_headers%ISOPEN THEN
    CLOSE g_cur_po_headers;
  END IF;

  FOR rec_header IN g_cur_po_headers LOOP

  BEGIN

    l_progress := '010';

    SELECT po_number,
           release_number,
           card_number,
           card_member_name,
           card_type_lookup_code,
           vendor_name,
           vendor_id,
           vendor_site_id,
           vendor_site_code,
           requester_id,
           order_date,
           base_currency_code,
           local_currency_code,
           po_header_amount,
           approval_status,
           control_status,
           approved_date,
           cancel_flag,
           hold_flag
      INTO l_po_number,
           l_release_number,
           l_card_number,
           l_card_member_name,
           l_card_type_lookup_code,
           l_vendor_name,
           l_vendor_id,
           l_vendor_site_id,
           l_vendor_site_code,
           l_requester_id,
           l_order_date,
           l_base_currency_code,
           l_local_currency_code,
           l_po_header_amount,
           l_approval_status,
           l_control_status,
           l_approved_date,
           l_cancel_flag,
           l_hold_flag
      FROM por_feed_records
     WHERE po_header_id = rec_header.po_header_id
       AND po_release_id = rec_header.po_release_id
       AND concurrent_request_id = g_conc_req_id
       AND nvl(error_flag, 'N') = 'N'
       AND rownum = 1;  --to avoid multiple records for multiple distr
                        --for which header info is the same

      l_progress := '020';

      IF l_release_number <> 0 THEN
        l_po_number := RTRIM(l_po_number) || '-' || l_release_number;
      END IF;

      IF l_card_type_lookup_code = 'PROCUREMENT' THEN

          l_payment_type_indicator := 'P';

        IF l_requester_id IS NOT NULL THEN

             SELECT first_name || ' ' || middle_name ||
                decode(middle_name, null, '', ' ') || last_name
             INTO l_requester_name
             FROM HR_EMPLOYEES
             WHERE EMPLOYEE_ID = l_requester_id;

        END IF;

      ELSIF l_card_type_lookup_code = 'SUPPLIER' THEN

          l_requester_id := 0;
          l_requester_name := NULL;
          l_card_member_name := l_vendor_name;
          l_payment_type_indicator := 'O';

      END IF;

      l_progress := '030';

        --Determine the Order Status for the PO:  ON, HL, CN
        IF l_cancel_flag = 'Y' AND l_control_status = 'CLOSED' AND
          l_approval_status in ('APPROVED','REQUIRES REAPPROVAL') THEN
          l_order_status := 'CN';
        ELSIF (l_cancel_flag = 'Y' OR l_control_status = 'FINALLY CLOSED') AND
          l_approval_status IN ('APPROVED','REQUIRES REAPPROVAL') THEN
          l_order_status := 'CN';
        ELSIF l_hold_flag = 'Y' THEN
          l_order_status := 'HL';
        ELSIF l_approval_status = 'APPROVED' AND
          l_approved_date IS NOT NULL THEN
          l_order_status := 'ON';
        ELSIF l_approval_status = 'REQUIRES REAPPROVAL' AND
          l_approved_date IS NOT NULL THEN
          l_order_status := 'HL';
        ELSIF l_approval_status = 'REQUIRES REAPPROVAL' AND
          l_approved_date IS NULL THEN
          raise e_do_not_send_po;
        END IF;

--fnd_file.put_line(fnd_file.log,'status: ' || l_order_status);

      --Determine the total number of distribution lines for the PO
      SELECT count(*)
      INTO l_total_distr_records
      FROM por_feed_records
      WHERE po_header_id = rec_header.po_header_id
        AND po_release_id = rec_header.po_release_id
        AND (line_cancel_flag IS NULL OR line_cancel_flag = 'N')
        AND (shipment_cancel_flag IS NULL OR shipment_cancel_flag = 'N')
        AND concurrent_request_id = g_conc_req_id;

      --following will return amount totals given the PO identifier and type.
      --result will be in functional/base currency.
      IF l_base_currency_code = l_local_currency_code THEN

        l_total_local_amount := l_po_header_amount;

      ELSE  --must explicitly pass boolean when currencies are different

        --following will return amount in local currency

        IF rec_header.po_release_id = 0 THEN
          l_object_type := 'H';
          l_object_id := rec_header.po_header_id;
        ELSE
          l_object_type := 'R';
          l_object_id := rec_header.po_release_id;
        END IF;

        l_total_local_amount := PO_CORE_S.Get_Total (
                                  l_object_type,  --H/eader or R/elease
                                  l_object_id,  --based on object type
                                  FALSE);
      END IF;

      IF l_po_header_amount >= 0 THEN
        l_cr_dr_indicator := 'D';
      ELSE
        l_cr_dr_indicator := 'C';
      END IF;


    --build record to write fields in start position order

    l_header_record := NULL; --initialize for writing

    l_progress := '040';

    FOR rec_field in cur_field_order
    LOOP

      l_column_name := rec_field.column_name;
      l_default_value := rec_field.default_value;
      l_field_length := rec_field.field_length;
      l_pad_char := rec_field.pad_character;

      IF l_column_name = 'RECORD_TYPE_INDICATOR' THEN
        l_header_record := l_header_record ||
        RPAD(NVL(l_default_value,' '),l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'CM_REF_NUMBER' THEN
        l_header_record := l_header_record ||
        RPAD(l_default_value,l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'PO_NUMBER' THEN
        l_header_record := l_header_record ||
        RPAD(l_po_number,l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'CARD_NUMBER' THEN
        l_header_record := l_header_record ||
        RPAD(l_card_number,l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'CARD_MEMBER_NAME' THEN
        l_header_record := l_header_record ||
        RPAD(NVL(SUBSTR(l_card_member_name,1,l_field_length),' '),
             l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'REQUESTER_NAME' THEN
        l_header_record := l_header_record ||
        RPAD(NVL(SUBSTR(l_requester_name,1,l_field_length),' '),
             l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'REQUESTER_ID' THEN
        l_header_record := l_header_record ||
        LPAD(NVL(SUBSTR(TO_CHAR(l_requester_id),1,l_field_length),0),l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'PAYMENT_TYPE_INDICATOR' THEN
        l_header_record := l_header_record ||
        RPAD(l_payment_type_indicator,l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'SUPPLIER_NAME' THEN
        l_header_record := l_header_record ||
        RPAD(SUBSTR(l_vendor_name || '-' || l_vendor_site_code,1,l_field_length),
               l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'CLIENT_SUPPLIER_NUM1' THEN
        l_header_record := l_header_record ||
        LPAD(SUBSTR(to_char(l_vendor_id),1,l_field_length),l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'CLIENT_SUPPLIER_NUM2' THEN
        l_header_record := l_header_record ||
        LPAD(SUBSTR(to_char(l_vendor_site_id),1,l_field_length),l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'ORDER_DATE' THEN
        l_header_record := l_header_record ||
        RPAD(to_char(l_order_date,'YYYYMMDD'),l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'ORDER_STATUS' THEN
        l_header_record := l_header_record ||
        RPAD(l_order_status,l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'TOTAL_LINES_PO' THEN
        IF (l_order_status = 'CN') THEN
          l_header_record := l_header_record ||
          LPAD(0,l_field_length,NVL(l_pad_char,' '));
        ELSE
          l_header_record := l_header_record ||
          LPAD(l_total_distr_records,l_field_length,NVL(l_pad_char,' '));
        END IF;
      ELSIF l_column_name = 'PO_AMOUNT' THEN
        IF (l_order_status = 'CN') THEN
          l_header_record := l_header_record ||
          ltrim(to_char(0,'099999999999.90'));
        ELSE
          l_header_record := l_header_record ||
          ltrim(to_char(l_po_header_amount,'099999999999.90'));
        END IF;
      ELSIF l_column_name = 'CR_DR_INDICATOR' THEN
        l_header_record := l_header_record ||
        RPAD(l_cr_dr_indicator,l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'PO_CURRENCY' THEN
        l_header_record := l_header_record ||
        RPAD(l_base_currency_code,l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'LOCAL_CURRENCY_AMOUNT' THEN
        IF (l_order_status = 'CN') THEN
          l_header_record := l_header_record ||
          ltrim(to_char(0,'099999999999.90'));
        ELSE
          l_header_record := l_header_record ||
          ltrim(to_char(l_total_local_amount,'099999999999.90'));
        END IF;
      ELSIF l_column_name = 'LOCAL_CURRENCY_CODE' THEN
        l_header_record := l_header_record ||
        RPAD(l_local_currency_code,l_field_length,NVL(l_pad_char,' '));
      ELSIF l_column_name = 'HEADER_MISC' THEN
        l_header_record := l_header_record ||
        RPAD(NVL(l_default_value,' '),l_field_length,NVL(l_pad_char,' '));
      END IF;

    END LOOP;

    l_progress := '050';

    IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||'Main', 'Header Record = ' || l_header_record);
    END IF;

    UTL_FILE.PUT_LINE(g_outfile,l_header_record);

  IF RTRIM(l_order_status) <> 'CN' THEN   --if PO header is not canceled
    Write_Detail_Record (rec_header.po_header_id,rec_header.po_release_id);
  END IF;

  l_progress := '060';


  EXCEPTION

    WHEN e_do_not_send_po THEN
      NULL;  --PO already written to global error message

    WHEN NO_DATA_FOUND THEN
      NULL;

    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error writing header for PO #: ' || l_po_number || '. ' ||
           SUBSTR(SQLERRM,1,300));

  END;  --block

  END LOOP;  --rec_header

EXCEPTION
  WHEN OTHERS THEN
    IF (G_LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Error in Write_Header_Record : SQLERRM= ' ||
                         SQLERRM || ' : Progress= ' || l_progress;
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||'Write_Header_Record', l_log_msg);
    END IF;

    RAISE;

END Write_Header_Record;

-------------------------------------------------------------------------------
--This procedure writes a control record to the output file.
-------------------------------------------------------------------------------

PROCEDURE Write_Control_Record IS

  l_errbuf VARCHAR2(2000) := NULL;
  l_retcode NUMBER := 0;

  l_control_record VARCHAR2(2000) := NULL;

  l_total_header_records NUMBER := 0;
  l_total_detail_records NUMBER := 0;
  l_po_amount            NUMBER := 0;
  l_total_PO_Amount      NUMBER := 0;
  l_PO_header_amount     NUMBER := 0;
  l_card_number          VARCHAR2(80) := '';
  l_po_number            VARCHAR2(50) := '';
  l_release_number       NUMBER := 0;
  l_cancel_flag          VARCHAR2(1) := 'N';
  l_control_status       VARCHAR2(25) := '';

  l_cr_dr_indicator VARCHAR2(1) := NULL;
  l_trans_start_date DATE := NULL;
  l_trans_end_date DATE := NULL;

  l_po_header_id NUMBER := 0;
  l_po_release_id NUMBER := 0;
  l_po_count NUMBER := 0;
  l_card_count NUMBER := 0;


  CURSOR cur_field_order IS

  SELECT column_name,
         field_length,
         default_value,
         pad_character
    FROM por_feed_field_formats
   WHERE format_id = g_format_id
     AND record_type = 'C'
     AND effective_date <= SYSDATE
     AND expiration_date IS NULL
   ORDER BY start_position;

  l_column_name VARCHAR2(100) := NULL;
  l_default_value VARCHAR2(50) := NULL;
  l_field_length NUMBER := 0;
  l_pad_char VARCHAR2(1) := NULL;
  l_no_error BOOLEAN := TRUE;

  l_log_msg              FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_progress            VARCHAR2(4) := '000';

BEGIN

   l_progress := '000';

   FOR rec_header IN g_cur_po_headers
   LOOP
     SELECT po_header_amount, card_number, po_number, release_number, cancel_flag, control_status
       INTO l_po_header_amount, l_card_number, l_po_number, l_release_number, l_cancel_flag, l_control_status
       FROM por_feed_records
      WHERE po_header_id = rec_header.po_header_id
        AND po_release_id = rec_header.po_release_id
        AND concurrent_request_id = g_conc_req_id
        AND rownum = 1;

     l_progress := '010';

     IF l_release_number <> 0 THEN
        l_po_number := RTRIM(l_po_number) || '-' || l_release_number;
     END IF;

     IF LENGTH(RTRIM(l_po_number)) > g_max_po_num_size THEN

        l_po_count := l_po_count + 1;

        IF l_po_count < 5 THEN   --5 is just a preferred number of po #s on one line
          IF g_po_num_err IS NULL THEN
            g_po_num_err := l_po_number;
          ELSE
            g_po_num_err := g_po_num_err || ', ' || l_po_number;
          END IF;
        ELSE
          g_po_num_err := g_po_num_err || ', ' || l_po_number || fnd_global.local_chr(10);
          l_po_count := 0;   --restart string of 5 po #s
        END IF;

       l_progress := '020';

        UPDATE por_feed_records
        SET error_flag = 'Y'
        WHERE po_header_id = rec_header.po_header_id
        AND po_release_id = rec_header.po_release_id
        AND concurrent_request_id = g_conc_req_id;

        l_no_error := FALSE;

     END IF;

     IF LENGTH(RTRIM(l_card_number)) > g_max_card_num_size THEN

        l_card_count := l_card_count + 1;

        IF l_card_count < 5 THEN   --5 is just a preferred number of card #s on one line
          IF g_card_num_err IS NULL THEN
            g_card_num_err := l_po_number;
          ELSE
            g_card_num_err := g_card_num_err || ', ' || l_po_number;
          END IF;
        ELSE
          g_card_num_err := g_card_num_err || ', ' || l_po_number || fnd_global.local_chr(10);
          l_card_count := 0;
        END IF;

      l_progress := '030';

        UPDATE por_feed_records
        SET error_flag = 'Y'
        WHERE po_header_id = rec_header.po_header_id
        AND po_release_id = rec_header.po_release_id
        AND concurrent_request_id = g_conc_req_id;

        l_no_error := FALSE;

     END IF;

     IF (l_no_error) THEN
       IF (nvl(l_cancel_flag,'N') <> 'Y' AND
           nvl(l_control_status,'OPEN') <> 'FINALLY CLOSED') THEN
         l_total_po_amount := l_total_po_amount + l_po_header_amount;
       END IF;
       l_total_header_records := l_total_header_records + 1;
     END IF;

     l_no_error := TRUE;

   END LOOP;

   l_progress := '040';

   -- get count of distribution/detail records for POs; do not include canceled and
   -- finally closed PO header records
   SELECT COUNT(*)
    INTO l_total_detail_records
    FROM por_feed_records
   WHERE (line_cancel_fLag IS NULL OR line_cancel_flag = 'N')
     AND (shipment_cancel_flag IS NULL OR shipment_cancel_flag = 'N')
     AND (control_status <> 'FINALLY CLOSED' OR control_status IS NULL)  --'CLOSED' ok
     AND NVL(cancel_flag, 'N') = 'N'
     AND nvl(error_flag, 'N') = 'N'
     AND concurrent_request_id = g_conc_req_id;

--   fnd_file.put_line(fnd_file.log,'Sum of all_PO amounts: ' || to_char(l_total_po_amount));
--   fnd_file.put_line(fnd_file.log,'Total header lines retrieved: ' || to_char(l_total_header_records));
--   fnd_file.put_line(fnd_file.log,'Total detail lines retrieved: ' || to_char(l_total_detail_records));

   IF l_total_po_amount >= 0 THEN
     l_cr_dr_indicator := 'D';
   ELSE
     l_cr_dr_indicator := 'C';
   END IF;

   SELECT MIN(order_date), MAX(order_date)
     INTO l_trans_start_date, l_trans_end_date
     FROM por_feed_records
    WHERE NVL(error_flag, 'N') = 'N'
     AND concurrent_request_id = g_conc_req_id;

    l_progress := '050';

   --build record to write fields in start position order
   FOR rec_field in cur_field_order
   LOOP

     l_column_name := rec_field.column_name;
     l_default_value := rec_field.default_value;
     l_field_length := rec_field.field_length;
     l_pad_char := rec_field.pad_character;

     IF l_column_name = 'RECORD_TYPE_INDICATOR' THEN
       l_control_record := l_control_record ||
       RPAD(l_default_value,l_field_length,NVL(l_pad_char,' '));
     ELSIF l_column_name = 'CREATION_DATE_PREFIX' THEN
       l_control_record := l_control_record ||
       RPAD(l_default_value,l_field_length,NVL(l_pad_char,' '));
     ELSIF l_column_name = 'FILE_CREATION_DATE' THEN
       l_control_record := l_control_record ||
       RPAD(to_char(sysdate,'YYYYMMDD'),l_field_length,NVL(l_pad_char,' '));
     ELSIF l_column_name = 'TOTAL_FILE_AMT_PREFIX' THEN
       l_control_record := l_control_record ||
       RPAD(l_default_value,l_field_length,NVL(l_pad_char,' '));
     ELSIF l_column_name = 'PO_AMOUNTS_SUM' THEN
       l_control_record := l_control_record ||
       ltrim(to_char(l_total_po_amount,'099999999999.90'));
     ELSIF l_column_name = 'CR_DR_INDICATOR' THEN
       l_control_record := l_control_record ||
       RPAD(l_cr_dr_indicator,l_field_length,NVL(l_pad_char,' '));
     ELSIF l_column_name = 'HEADER_RECORD_PREFIX' THEN
       l_control_record := l_control_record ||
       RPAD(l_default_value,l_field_length,NVL(l_pad_char,' '));
     ELSIF l_column_name = 'TOTAL_HEADER_RECORDS' THEN
       l_control_record := l_control_record ||
       LPAD(l_total_header_records,l_field_length,NVL(l_pad_char,' '));
     ELSIF l_column_name = 'DETAIL_RECORD_PREFIX' THEN
       l_control_record := l_control_record ||
       RPAD(l_default_value,l_field_length,NVL(l_pad_char,' '));
     ELSIF l_column_name = 'TOTAL_DETAIL_RECORDS' THEN
       l_control_record := l_control_record ||
       LPAD(l_total_detail_records,l_field_length,NVL(l_pad_char,' '));
     ELSIF l_column_name = 'START_DATE_PREFIX' THEN
       l_control_record := l_control_record ||
       RPAD(l_default_value,l_field_length,NVL(l_pad_char,' '));
     ELSIF l_column_name = 'TRANS_START_DATE' THEN
       IF (l_trans_start_date IS NULL) THEN
         l_control_record := l_control_record || RPAD(' ', l_field_length,NVL(l_pad_char,' '));
       ELSE
         l_control_record := l_control_record ||
         RPAD(to_char(l_trans_start_date,'YYYYMMDD'),l_field_length,NVL(l_pad_char,' '));
       END IF;
     ELSIF l_column_name = 'END_DATE_PREFIX' THEN
       l_control_record := l_control_record ||
       RPAD(l_default_value,l_field_length,NVL(l_pad_char,' '));
     ELSIF l_column_name = 'TRANS_END_DATE' THEN
       IF (l_trans_end_date IS NULL) THEN
         l_control_record := l_control_record || RPAD(' ', l_field_length,NVL(l_pad_char,' '));
       ELSE
         l_control_record := l_control_record ||
         RPAD(to_char(l_trans_end_date,'YYYYMMDD'),l_field_length,NVL(l_pad_char,' '));
       END IF;
     END IF;

   END LOOP;

   l_progress := '060';

    IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||'Main', 'Control Record = ' || l_control_record);
    END IF;

   UTL_FILE.PUT_LINE(g_outfile,l_control_record);

   l_progress := '070';

EXCEPTION

  WHEN OTHERS THEN
    IF (G_LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Error in Write_Control_Record : SQLERRM= ' ||
                         SQLERRM || ' : Progress= ' || l_progress;
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||'Write_Control_Record', l_log_msg);
    END IF;

    RAISE;

END Write_Control_Record;

------------------------------------------------------------------------
--following will remove non-numeric characters from a card number.
------------------------------------------------------------------------

PROCEDURE Trim_Card_Numbers IS

  CURSOR cur_card_numbers IS
    SELECT card_number
      FROM por_feed_records
     WHERE concurrent_request_id = g_conc_req_id
  GROUP BY card_number;

  l_card_number por_feed_records.card_number%TYPE;
  l_trim_card_number por_feed_records.card_number%TYPE;

  l_char VARCHAR2(1) := NULL;

  l_log_msg              FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_progress            VARCHAR2(4) := '000';

BEGIN

  l_progress := '000';

  FOR rec_card IN cur_card_numbers
  LOOP

    l_trim_card_number := NULL;  -- initialize
    l_card_number := TRIM(rec_card.card_number);

    IF (l_card_number is not null) THEN
      --remove non-numeric chars from card number
      FOR i in 1..LENGTH(l_card_number)
      LOOP

        l_char := substr(l_card_number,i,1);
        -- ascii('0') = 48 and ascii('9') = 57
        IF  ASCII(l_char) >= ASCII('0') AND ASCII(l_char) <= ASCII('9') THEN
          l_trim_card_number := l_trim_card_number || l_char;
        END IF;

      END LOOP;

      l_progress := '010';

      UPDATE por_feed_records
         SET card_number = l_trim_card_number
       WHERE card_number = l_card_number
       AND concurrent_request_id = g_conc_req_id;
    END IF;
  END LOOP;
  COMMIT;

  l_progress := '020';

EXCEPTION

  WHEN OTHERS THEN
    IF (G_LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Error in Trim_Card_Numbers : SQLERRM= ' ||
                         SQLERRM || ' : Progress= ' || l_progress;
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||'Trim_Card_Numbers', l_log_msg);
    END IF;

    RAISE;

END Trim_Card_Numbers;


------------------------------------------------------------------------
--following will return header amount totals given the PO identifier and type.
--result will be in functional/base currency.
------------------------------------------------------------------------

PROCEDURE Get_Header_Amounts IS

  l_base_curr_code por_feed_records.base_currency_code%TYPE;
  l_local_curr_code por_feed_records.local_currency_code%TYPE;

  l_object_type VARCHAR2(1) := NULL;
  l_object_id NUMBER := 0;
  l_po_amount NUMBER := 0;

  l_log_msg              FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_progress            VARCHAR2(4) := '000';

BEGIN
  l_progress := '000';

  FOR rec_header IN g_cur_po_headers
  LOOP

    SELECT base_currency_code,
           local_currency_code
      INTO l_base_curr_code,
           l_local_curr_code
      FROM por_feed_records
     WHERE po_header_id = rec_header.po_header_id
       AND po_release_id = rec_header.po_release_id
       AND concurrent_request_id = g_conc_req_id
       AND rownum = 1;

    l_progress := '010';

    IF rec_header.po_release_id = 0 THEN
      l_object_type := 'H';
      l_object_id := rec_header.po_header_id;
    ELSE
      l_object_type := 'R';
      l_object_id := rec_header.po_release_id;
    END IF;

    IF l_base_curr_code = l_local_curr_code THEN

      --Note that the Get_Total API subtracts amounts for canceled lines/
      --shipments.
      l_po_amount := PO_CORE_S.Get_Total (
                                  l_object_type,  --H/eader or R/elease
                                  l_object_id);  --based on object type

    ELSE

      --Note that the Get_Total API subtracts amounts for canceled lines/
      --shipments.
      l_po_amount := PO_CORE_S.Get_Total (
                                  l_object_type,  --H/eader or R/elease
                                  l_object_id,  --based on object type
                                  TRUE);    --result in base/func currency
    END IF;

    l_progress := '020';

    UPDATE por_feed_records
       SET po_header_amount = l_po_amount
     WHERE po_header_id = rec_header.po_header_id
       AND po_release_id = rec_header.po_release_id
       AND concurrent_request_id = g_conc_req_id;

  END LOOP;
  COMMIT;

  l_progress := '030';

EXCEPTION
  WHEN OTHERS THEN
    IF (G_LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Error in Get_Header_Amounts : SQLERRM= ' ||
                         SQLERRM || ' : Progress= ' || l_progress;
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||'Get_Header_Amounts', l_log_msg);
    END IF;

    RAISE;
END Get_Header_Amounts;


-------------------------------------------------------------------------------
--This procedure populates the por_feed_records table with valid PO distributions
--using bulk binding.
-------------------------------------------------------------------------------

PROCEDURE Get_PO_Distributions IS

  TYPE tab_po_num IS TABLE OF po_headers.segment1%TYPE;
  TYPE tab_rel_num IS TABLE OF po_releases.release_num%TYPE;
  TYPE tab_po_header_id IS TABLE OF po_headers.po_header_id%TYPE;
  TYPE tab_po_release_id IS TABLE OF po_releases.po_release_id%TYPE;
  TYPE tab_cardno IS TABLE OF iby_creditcard.masked_cc_number%TYPE;
  TYPE tab_cardmember IS TABLE OF ap_cards.cardmember_name%TYPE;
  TYPE tab_card_type IS TABLE OF ap_card_programs.card_type_lookup_code%TYPE;
  TYPE tab_card_brand IS TABLE OF ap_card_programs.card_brand_lookup_code%TYPE;
  TYPE tab_requester_id IS TABLE OF ap_cards.employee_id%TYPE;
  TYPE tab_vendor_name IS TABLE OF po_vendors.vendor_name%TYPE;
  TYPE tab_vendor_site_code IS TABLE OF po_vendor_sites.vendor_site_code%TYPE;
  TYPE tab_vendor_id IS TABLE OF  po_vendors.vendor_id%TYPE;
  TYPE tab_vendor_site_id IS TABLE OF  po_vendor_sites.vendor_site_id%TYPE;
  TYPE tab_order_date IS TABLE OF po_headers.last_update_date%TYPE;
  TYPE tab_base_curr IS TABLE OF gl_sets_of_books.currency_code%TYPE;
  TYPE tab_local_curr IS TABLE OF po_headers.currency_code%TYPE;
  TYPE tab_uom IS TABLE OF po_lines.unit_meas_lookup_code%TYPE;
  TYPE tab_item_num IS TABLE OF mtl_system_items_kfv.concatenated_segments%TYPE;
  TYPE tab_item_desc IS TABLE OF po_lines.item_description%TYPE;
  TYPE tab_qty IS TABLE OF po_distributions.quantity_ordered%TYPE;
  TYPE tab_unit_price IS TABLE OF po_lines.unit_price%TYPE;
  TYPE tab_amount IS TABLE OF NUMBER;
  TYPE tab_acct_id IS TABLE OF gl_sets_of_books.chart_of_accounts_id%TYPE;
  TYPE tab_acct_code IS TABLE OF gl_code_combinations_kfv.concatenated_segments%TYPE;
  TYPE tab_appr_status IS TABLE OF po_headers.authorization_status%TYPE;
  TYPE tab_appr_date IS TABLE OF po_headers.approved_date%TYPE;
  TYPE tab_control_status IS TABLE OF po_headers.closed_code%TYPE;
  TYPE tab_cancel_flag IS TABLE OF po_headers.cancel_flag%TYPE;
  TYPE tab_hold_flag IS TABLE OF po_headers.user_hold_flag%TYPE;
  TYPE tab_line_cancel_flag IS TABLE OF po_lines.cancel_flag%TYPE;
  TYPE tab_shipment_cancel_flag IS TABLE OF po_line_locations.cancel_flag%TYPE;

  l_po_num tab_po_num;
  l_rel_num tab_rel_num;
  l_header_id tab_po_header_id;
  l_release_id tab_po_release_id;
  l_card_num tab_cardno;
  l_cardmember tab_cardmember;
  l_card_brand tab_card_brand;
  l_card_type tab_card_type;
  l_req_id tab_requester_id;
  l_vendor_name tab_vendor_name;
  l_vendor_id tab_vendor_id;
  l_vendor_site_code tab_vendor_site_code;
  l_vendor_site_id tab_vendor_site_id;
  l_order_date tab_order_date;
  l_base_curr tab_base_curr;
  l_local_curr tab_local_curr;
  l_uom tab_uom;
  l_item_num tab_item_num;
  l_item_desc tab_item_desc;
  l_qty tab_qty;
  l_unit_price tab_unit_price;
  l_amount tab_amount;
  l_acct_id tab_acct_id;
  l_acct_code tab_acct_code;
  l_appr_status tab_appr_status;
  l_appr_date tab_appr_date;
  l_contr_status tab_control_status;
  l_cancel_flag tab_cancel_flag;
  l_line_cancel_flag tab_line_cancel_flag;
  l_shipment_cancel_flag tab_shipment_cancel_flag;
  l_hold_flag tab_hold_flag;

  l_cur_count NUMBER := 0;

  --This cursor retrieves all transactions that are on hold or 'open'.
  --'Open' refers to three types of records:  Transactions with no
  --line/shipment cancellations, some line/shipment cancellations,
  --or all line/shipment cancellations.

  CURSOR cur_PO_records IS

    SELECT    --standard POs with catalog items

      PH.SEGMENT1             PO_NUM,          --header,detail
      0                       RELEASE_NUM,     --NA for std PO
      PH.PO_HEADER_ID         PO_HEADER_ID,    --for get_total API
      0                       PO_RELEASE_ID,   --NA for std PO
      ibycc.masked_cc_number  CARD_NUM,        --header
      AC.CARDMEMBER_NAME      CARD_MEMBER_NAME,  --header
      ACP.CARD_BRAND_LOOKUP_CODE CARD_BRAND,   --select key
      ACP.CARD_TYPE_LOOKUP_CODE CARD_TYPE,     --for decode
      AC.EMPLOYEE_ID         requester_ID,    --header
      PV.VENDOR_NAME          VENDOR_NAME,    --for header, select key
      PVS.VENDOR_SITE_CODE    VENDOR_SITE_CODE,  --header
      PV.VENDOR_ID            VENDOR_ID,       --header
      PVS.VENDOR_SITE_ID      VENDOR_SITE_ID,  --for header, select key
      PH.LAST_UPDATE_DATE     ORDER_DATE,      --header
      GSB.CURRENCY_CODE       BASE_CURR,      --header
      PH.CURRENCY_CODE        LOCAL_CURR,     --header
      PL.UNIT_MEAS_LOOKUP_CODE  UOM,          --detail
      SUBSTR(MSI.CONCATENATED_SEGMENTS,1,40) ITEM_NUM, --detail
      PL.ITEM_DESCRIPTION     ITEM_DESC,      --detail
      DECODE(PL.MATCHING_BASIS, 'AMOUNT', PD.AMOUNT_ORDERED, PD.QUANTITY_ORDERED) QTY,            --detail
      DECODE(PL.MATCHING_BASIS, 'AMOUNT', 1,NVL(PD.RATE,1) * NVL(PLL.PRICE_OVERRIDE,PL.UNIT_PRICE)) UNIT_PRICE, --detail
      DECODE(PL.MATCHING_BASIS, 'AMOUNT', PD.AMOUNT_ORDERED, NVL(PD.RATE,1) * (PD.QUANTITY_ORDERED * NVL(PLL.PRICE_OVERRIDE,PL.UNIT_PRICE)))   AMOUNT, --control, header
      GSB.CHART_OF_ACCOUNTS_ID CHART_ACCTS_ID,  -- ref
      fnd_flex_ext.get_segs('SQLGL','GL#', GSB.CHART_OF_ACCOUNTS_ID, PD.CODE_COMBINATION_ID) ACCTNG_CODE,
      PH.AUTHORIZATION_STATUS APPR_STATUS,    --for order status
      PH.APPROVED_DATE        APPR_DATE,      --for order status
      PH.CLOSED_CODE          CONTROL_STATUS, --for order status
      PH.CANCEL_FLAG          CANCEL_FLAG,    --for order status
      PH.USER_HOLD_FLAG       hold_flag,    --for order status
      PL.CANCEL_FLAG          line_cancel_flag,  --ref
      PLL.CANCEL_FLAG         shipment_cancel_flag  --ref

    FROM

      PO_HEADERS             PH,
      PO_LINES               PL,
      PO_LINE_LOCATIONS      PLL,
      PO_DISTRIBUTIONS       PD,
      PO_VENDORS             PV,
      PO_VENDOR_SITES        PVS,
      AP_CARDS               AC,
      AP_CARD_PROGRAMS       ACP,
      MTL_SYSTEM_ITEMS_KFV   MSI,
      GL_SETS_OF_BOOKS          GSB,
      FINANCIALS_SYSTEM_PARAMETERS FSP,
      iby_creditcard ibycc

    WHERE

          PH.PO_HEADER_ID = PL.PO_HEADER_ID
      AND PH.TYPE_LOOKUP_CODE = 'STANDARD'
      AND PH.PCARD_ID IS NOT NULL      --p-card used
      AND (PL.ITEM_ID = MSI.INVENTORY_ITEM_ID
          AND MSI.ORGANIZATION_ID = g_inv_org_id)   --only item for that inv org
      AND PL.PO_LINE_ID = PLL.PO_LINE_ID
      AND PLL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
      AND FSP.SET_OF_BOOKS_ID = GSB.SET_OF_BOOKS_ID
      AND PH.VENDOR_ID = PV.VENDOR_ID
      AND PV.VENDOR_ID = PVS.VENDOR_ID
      AND PH.VENDOR_SITE_ID = PVS.VENDOR_SITE_ID
      AND PH.AUTHORIZATION_STATUS IN ('APPROVED','REQUIRES REAPPROVAL')
      AND PH.APPROVED_DATE IS NOT NULL
      AND (PH.CANCEL_FLAG IS NULL OR PH.CANCEL_FLAG = 'N')  --PO not canceled but lines/shipments may be
      AND PVS.PCARD_SITE_FLAG = 'Y'	   --verifies supplier site uses p-card
      and PH.PCARD_ID = AC.CARD_ID
      AND AC.CARD_PROGRAM_ID = ACP.CARD_PROGRAM_ID   --card registered for program
      AND ACP.CARD_TYPE_LOOKUP_CODE IN ('PROCUREMENT','SUPPLIER')
      AND ACP.CARD_BRAND_LOOKUP_CODE = g_card_brand  --valid card type
      AND ACP.VENDOR_ID = g_card_issuer_id
      AND ACP.VENDOR_SITE_ID = g_card_issuer_site_id
      AND PH.LAST_UPDATE_DATE >= g_from_date_time
      AND PH.LAST_UPDATE_DATE < g_to_date_time
      AND ac.card_reference_id = ibycc.instrid

UNION ALL   -- Standard POs with non-catalog items

    SELECT
      PH.SEGMENT1             PO_NUM,          --header,detail
      0                       RELEASE_NUM,     --NA for std PO
      PH.PO_HEADER_ID         PO_HEADER_ID,    --for get_total API
      0                       PO_RELEASE_ID,   --NA for std PO
      ibycc.masked_cc_number  CARD_NUM,        --header
      AC.CARDMEMBER_NAME      CARD_MEMBER_NAME,  --header
      ACP.CARD_BRAND_LOOKUP_CODE CARD_BRAND,   --select key
      ACP.CARD_TYPE_LOOKUP_CODE CARD_TYPE,     --for decode
      AC.EMPLOYEE_ID         requester_ID,     --header
      PV.VENDOR_NAME          VENDOR_NAME,    --for header, select key
      PVS.VENDOR_SITE_CODE    VENDOR_SITE_CODE,  --header
      PV.VENDOR_ID            VENDOR_ID,       --header
      PVS.VENDOR_SITE_ID      VENDOR_SITE_ID,  --for header, select key
      PH.LAST_UPDATE_DATE     ORDER_DATE,      --header
      GSB.CURRENCY_CODE       BASE_CURR,      --header
      PH.CURRENCY_CODE        LOCAL_CURR,     --header
      PL.UNIT_MEAS_LOOKUP_CODE  UOM,          --detail
      NULL                    ITEM_NUM,       --NA for non-catalog
      PL.ITEM_DESCRIPTION     ITEM_DESC,      --NA for non-catalog
      DECODE(PL.MATCHING_BASIS, 'AMOUNT', PD.AMOUNT_ORDERED,PD.QUANTITY_ORDERED) QTY,            --detail
      DECODE(PL.MATCHING_BASIS, 'AMOUNT', 1,NVL(PD.RATE,1) * NVL(PLL.PRICE_OVERRIDE,PL.UNIT_PRICE)) UNIT_PRICE, --detail
      DECODE(PL.MATCHING_BASIS, 'AMOUNT', PD.AMOUNT_ORDERED,NVL(PD.RATE,1) * (PD.QUANTITY_ORDERED * NVL(PLL.PRICE_OVERRIDE,PL.UNIT_PRICE)))  AMOUNT, --control, header
      GSB.CHART_OF_ACCOUNTS_ID CHART_ACCTS_ID,  -- ref
      fnd_flex_ext.get_segs('SQLGL','GL#', GSB.CHART_OF_ACCOUNTS_ID, PD.CODE_COMBINATION_ID) ACCTNG_CODE,
      PH.AUTHORIZATION_STATUS APPR_STATUS,    --for order status
      PH.APPROVED_DATE        APPR_DATE,      --for order status
      PH.CLOSED_CODE          CONTROL_STATUS, --for order status
      PH.CANCEL_FLAG          CANCEL_FLAG,    --for order status
      PH.USER_HOLD_FLAG       hold_flag,     --for order status
      PL.CANCEL_FLAG          line_cancel_flag,  --ref
      PLL.CANCEL_FLAG         shipment_cancel_flag  --ref

    FROM
      PO_HEADERS             PH,
      PO_LINES               PL,
      PO_LINE_LOCATIONS      PLL,
      PO_DISTRIBUTIONS       PD,
      PO_VENDORS             PV,
      PO_VENDOR_SITES        PVS,
      AP_CARDS               AC,
      AP_CARD_PROGRAMS       ACP,
      GL_SETS_OF_BOOKS          GSB,
      FINANCIALS_SYSTEM_PARAMETERS FSP,
      iby_creditcard ibycc

    WHERE
          PH.PO_HEADER_ID = PL.PO_HEADER_ID
      AND PH.TYPE_LOOKUP_CODE = 'STANDARD'
      AND PH.PCARD_ID IS NOT NULL     --p-card is used
      AND PL.ITEM_ID IS NULL          --non-catalog item has no id
      AND PL.PO_LINE_ID = PLL.PO_LINE_ID
      AND PLL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
      AND FSP.SET_OF_BOOKS_ID = GSB.SET_OF_BOOKS_ID
      AND PH.VENDOR_ID = PV.VENDOR_ID
      AND PV.VENDOR_ID = PVS.VENDOR_ID
      AND PH.VENDOR_SITE_ID = PVS.VENDOR_SITE_ID
      AND PH.AUTHORIZATION_STATUS IN ('APPROVED','REQUIRES REAPPROVAL')
      AND PH.APPROVED_DATE IS NOT NULL
      AND (PH.CANCEL_FLAG IS NULL OR PH.CANCEL_FLAG = 'N')  --PO not canceled but lines/shipments may be
      AND PVS.PCARD_SITE_FLAG = 'Y'	 --verifies site uses p-card
      and PH.PCARD_ID = AC.CARD_ID         --valid p-card
      AND AC.CARD_PROGRAM_ID = ACP.CARD_PROGRAM_ID --card reg for program
      AND ACP.CARD_TYPE_LOOKUP_CODE IN ('PROCUREMENT','SUPPLIER')
      AND ACP.CARD_BRAND_LOOKUP_CODE = g_card_brand  --valid card type
      AND ACP.VENDOR_ID = g_card_issuer_id
      AND ACP.VENDOR_SITE_ID = g_card_issuer_site_id
      AND PH.LAST_UPDATE_DATE >= g_from_date_time
      AND PH.LAST_UPDATE_DATE < g_to_date_time
      AND ac.card_reference_id = ibycc.instrid

UNION ALL  -- Blanket releases with non-catalog items

    SELECT
      PH.SEGMENT1             PO_NUM,          --header, detail
      PR.RELEASE_NUM          RELEASE_NUM,     --header
      PH.PO_HEADER_ID         PO_HEADER_ID,    --for get_total API
      PR.PO_RELEASE_ID        PO_RELEASE_ID,   --for get_total API
      ibycc.masked_cc_number  CARD_NUM,        --header
      AC.CARDMEMBER_NAME      CARD_MEMBER_NAME,  --header
      ACP.CARD_BRAND_LOOKUP_CODE CARD_BRAND,   --select key
      ACP.CARD_TYPE_LOOKUP_CODE CARD_TYPE,     --decode key
      AC.EMPLOYEE_ID         requester_ID,     --header
      PV.VENDOR_NAME          VENDOR_NAME,    --for header, select key
      PVS.VENDOR_SITE_CODE    VENDOR_SITE_CODE,  --header
      PV.VENDOR_ID            VENDOR_ID,        --header
      PVS.VENDOR_SITE_ID      VENDOR_SITE_ID,  --for header, select key
      PR.LAST_UPDATE_DATE     ORDER_DATE,      --header
      GSB.CURRENCY_CODE       BASE_CURR,      --header
      PH.CURRENCY_CODE        LOCAL_CURR,     --header
      PL.UNIT_MEAS_LOOKUP_CODE  UOM,          --detail
      NULL                    ITEM_NUM,       --NA for non-catalog
      PL.ITEM_DESCRIPTION     ITEM_DESC,      --NA for non-catalog
      DECODE(PL.MATCHING_BASIS, 'AMOUNT', PD.AMOUNT_ORDERED, PD.QUANTITY_ORDERED) QTY,            --detail
      DECODE(PL.MATCHING_BASIS, 'AMOUNT', 1, NVL(PD.RATE,1) * NVL(PLL.PRICE_OVERRIDE,PL.UNIT_PRICE)) UNIT_PRICE, --detail
      DECODE(PL.MATCHING_BASIS, 'AMOUNT', PD.AMOUNT_ORDERED, NVL(PD.RATE,1) * (PD.QUANTITY_ORDERED * NVL(PLL.PRICE_OVERRIDE,PL.UNIT_PRICE)))  AMOUNT, --control, header
      GSB.CHART_OF_ACCOUNTS_ID CHART_ACCTS_ID,  --ref
      fnd_flex_ext.get_segs('SQLGL','GL#', GSB.CHART_OF_ACCOUNTS_ID, PD.CODE_COMBINATION_ID) ACCTNG_CODE,
      PR.AUTHORIZATION_STATUS APPR_STATUS,    --for order status
      PR.APPROVED_DATE        APPR_DATE,      --for order status
      PR.CLOSED_CODE          CONTROL_STATUS, --for order status
      PR.CANCEL_FLAG          CANCEL_FLAG,    --for order status
      PR.HOLD_FLAG            hold_flag,          --for order status
      PL.CANCEL_FLAG          line_cancel_flag,  --ref
      PLL.CANCEL_FLAG         shipment_cancel_flag  --ref

    FROM
      PO_HEADERS             PH,
      PO_RELEASES            PR,
      PO_LINES               PL,
      PO_LINE_LOCATIONS      PLL,
      PO_DISTRIBUTIONS       PD,
      PO_VENDORS             PV,
      PO_VENDOR_SITES        PVS,
      AP_CARDS               AC,
      AP_CARD_PROGRAMS       ACP,
      GL_SETS_OF_BOOKS          GSB,
      FINANCIALS_SYSTEM_PARAMETERS FSP,
      iby_creditcard ibycc

    WHERE
          PH.PO_HEADER_ID = PR.PO_HEADER_ID
      AND PH.PO_HEADER_ID = PL.PO_HEADER_ID
      AND PH.TYPE_LOOKUP_CODE = 'BLANKET'
      AND PR.PCARD_ID IS NOT NULL     --p-card is used
      AND PL.ITEM_ID IS NULL          --non-catalog item has no id
      AND PL.PO_LINE_ID = PLL.PO_LINE_ID
      AND PR.PO_RELEASE_ID = PLL.PO_RELEASE_ID
      AND PLL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
      AND FSP.SET_OF_BOOKS_ID = GSB.SET_OF_BOOKS_ID
      AND PH.VENDOR_ID = PV.VENDOR_ID
      AND PV.VENDOR_ID = PVS.VENDOR_ID
      AND PH.VENDOR_SITE_ID = PVS.VENDOR_SITE_ID
      AND PR.AUTHORIZATION_STATUS IN ('APPROVED','REQUIRES REAPPROVAL')
      AND PR.APPROVED_DATE IS NOT NULL
      AND (PR.CANCEL_FLAG IS NULL OR PR.CANCEL_FLAG = 'N')  --release not canceled but lines/shipments may be
      AND PVS.PCARD_SITE_FLAG = 'Y'	 --verifies site uses p-card
      and PR.PCARD_ID = AC.CARD_ID         --valid p-card
      AND AC.CARD_PROGRAM_ID = ACP.CARD_PROGRAM_ID --card reg for progr
      AND ACP.CARD_TYPE_LOOKUP_CODE IN ('PROCUREMENT','SUPPLIER')
      AND ACP.CARD_BRAND_LOOKUP_CODE = g_card_brand
      AND ACP.VENDOR_ID = g_card_issuer_id
      AND ACP.VENDOR_SITE_ID = g_card_issuer_site_id
      AND PR.LAST_UPDATE_DATE >= g_from_date_time
      AND PR.LAST_UPDATE_DATE < g_to_date_time
      AND ac.card_reference_id = ibycc.instrid

UNION ALL   -- Blanket releases with catalog items

    SELECT
      PH.SEGMENT1             PO_NUM,          --header
      PR.RELEASE_NUM          RELEASE_NUM,     --header
      PH.PO_HEADER_ID         PO_HEADER_ID,    --get_total API
      PR.PO_RELEASE_ID        PO_RELEASE_ID,   --get_total API
      ibycc.masked_cc_number  CARD_NUM,        --header
      AC.CARDMEMBER_NAME      CARD_MEMBER_NAME,  --header
      ACP.CARD_BRAND_LOOKUP_CODE CARD_BRAND,   --select key
      ACP.CARD_TYPE_LOOKUP_CODE CARD_TYPE,     --decode key
      AC.EMPLOYEE_ID         requester_ID,     --header
      PV.VENDOR_NAME          VENDOR_NAME,     --header
      PVS.VENDOR_SITE_CODE    VENDOR_SITE_CODE,  --header
      PV.VENDOR_ID            VENDOR_ID,       --header
      PVS.VENDOR_SITE_ID      VENDOR_SITE_ID,  --header
      PR.LAST_UPDATE_DATE     ORDER_DATE,      --header
      GSB.CURRENCY_CODE       FUNC_CURR,      --header
      PH.CURRENCY_CODE        LOCAL_CURR,     --header
      PL.UNIT_MEAS_LOOKUP_CODE  UOM,          --detail
      SUBSTR(MSI.CONCATENATED_SEGMENTS,1,40) ITEM_NUM, --detail
      PL.ITEM_DESCRIPTION     ITEM_DESC,      --detail
      DECODE(PL.MATCHING_BASIS, 'AMOUNT', PD.AMOUNT_ORDERED, PD.QUANTITY_ORDERED) QTY,            --detail
      DECODE(PL.MATCHING_BASIS, 'AMOUNT', 1, NVL(PD.RATE,1) * NVL(PLL.PRICE_OVERRIDE,PL.UNIT_PRICE)) UNIT_PRICE, --detail
      DECODE(PL.MATCHING_BASIS, 'AMOUNT', PD.AMOUNT_ORDERED, NVL(PD.RATE,1) * (PD.QUANTITY_ORDERED * NVL(PLL.PRICE_OVERRIDE,PL.UNIT_PRICE))) AMOUNT, --control, header
      GSB.CHART_OF_ACCOUNTS_ID CHART_ACCTS_ID,  -- ref
      fnd_flex_ext.get_segs('SQLGL','GL#', GSB.CHART_OF_ACCOUNTS_ID, PD.CODE_COMBINATION_ID) ACCTNG_CODE,
      PR.AUTHORIZATION_STATUS APPR_STATUS,    --for order status
      PR.APPROVED_DATE        APPR_DATE,      --for order status
      PR.CLOSED_CODE          CONTROL_STATUS, --for order status
      PR.CANCEL_FLAG          CANCEL_FLAG,    --for order status
      PR.HOLD_FLAG            hold_flag,     --for order status
      PL.CANCEL_FLAG          line_cancel_flag,  --ref
      PLL.CANCEL_FLAG         shipment_cancel_flag  --ref

    FROM
      PO_HEADERS             PH,
      PO_RELEASES            PR,
      PO_LINES               PL,
      PO_LINE_LOCATIONS      PLL,
      PO_DISTRIBUTIONS       PD,
      PO_VENDORS             PV,
      PO_VENDOR_SITES        PVS,
      AP_CARDS               AC,
      AP_CARD_PROGRAMS       ACP,
      MTL_SYSTEM_ITEMS_KFV   MSI,
      GL_SETS_OF_BOOKS          GSB,
      FINANCIALS_SYSTEM_PARAMETERS FSP,
      iby_creditcard ibycc

    WHERE
          PH.PO_HEADER_ID = PR.PO_HEADER_ID
      AND PH.PO_HEADER_ID = PL.PO_HEADER_ID
      AND PH.TYPE_LOOKUP_CODE = 'BLANKET'
      AND PR.PCARD_ID IS NOT NULL     --p-card is used
      AND (PL.ITEM_ID = MSI.INVENTORY_ITEM_ID
          AND MSI.ORGANIZATION_ID = g_inv_org_id)   --only item for that inv org
      AND PR.PO_RELEASE_ID = PLL.PO_RELEASE_ID
      AND PL.PO_LINE_ID = PLL.PO_LINE_ID
      AND PLL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
      AND FSP.SET_OF_BOOKS_ID = GSB.SET_OF_BOOKS_ID
      AND PH.VENDOR_ID = PV.VENDOR_ID
      AND PV.VENDOR_ID = PVS.VENDOR_ID
      AND PH.VENDOR_SITE_ID = PVS.VENDOR_SITE_ID
      AND PR.AUTHORIZATION_STATUS IN ('APPROVED','REQUIRES REAPPROVAL')
      AND PR.APPROVED_DATE IS NOT NULL
      AND (PR.CANCEL_FLAG IS NULL OR PR.CANCEL_FLAG = 'N')  --release not canceled but lines/shipments may be
      AND PVS.PCARD_SITE_FLAG = 'Y'	 --verifies site uses p-card
      and PR.PCARD_ID = AC.CARD_ID   --valid p-card
      AND AC.CARD_PROGRAM_ID = ACP.CARD_PROGRAM_ID --card reg for progr
      AND ACP.CARD_TYPE_LOOKUP_CODE IN ('PROCUREMENT','SUPPLIER')
      AND ACP.CARD_BRAND_LOOKUP_CODE = g_card_brand  --valid card type
      AND ACP.VENDOR_ID = g_card_issuer_id
      AND ACP.VENDOR_SITE_ID = g_card_issuer_site_id
      AND PR.LAST_UPDATE_DATE >= g_from_date_time
      AND PR.LAST_UPDATE_DATE < g_to_date_time
      AND ac.card_reference_id = ibycc.instrid;


  --This is a separate cursor to capture canceled POs canceled at the header level.
  --Distribution records for canceled POs are not written to the output file so this
  --cursor does not pick them up.

  CURSOR cur_canceled_POs IS

    SELECT   --standard POs

      PH.SEGMENT1             PO_NUM,          --header,detail
      0                       RELEASE_NUM,     --NA for std PO
      PH.PO_HEADER_ID         PO_HEADER_ID,    --for get_total API
      0                       PO_RELEASE_ID,   --NA for std PO
      ibycc.masked_cc_number  CARD_NUM,        --header
      AC.CARDMEMBER_NAME      CARD_MEMBER_NAME,  --header
      ACP.CARD_BRAND_LOOKUP_CODE CARD_BRAND,   --select key
      ACP.CARD_TYPE_LOOKUP_CODE CARD_TYPE,     --for decode
      AC.EMPLOYEE_ID         requester_ID,     --header
      PV.VENDOR_NAME          VENDOR_NAME,    --for header, select key
      PVS.VENDOR_SITE_CODE    VENDOR_SITE_CODE,  --header
      PV.VENDOR_ID            VENDOR_ID,       --header
      PVS.VENDOR_SITE_ID      VENDOR_SITE_ID,  --for header, select key
      PH.LAST_UPDATE_DATE     ORDER_DATE,      --header
      GSB.CURRENCY_CODE       BASE_CURR,      --header
      PH.CURRENCY_CODE        LOCAL_CURR,     --header
      PH.AUTHORIZATION_STATUS APPR_STATUS,    --for order status
      PH.APPROVED_DATE        APPR_DATE,      --for order status
      PH.CLOSED_CODE          CONTROL_STATUS, --for order status
      PH.CANCEL_FLAG          CANCEL_FLAG,    --for order status
      PH.USER_HOLD_FLAG       hold_flag     --for order status

    FROM

      PO_HEADERS             PH,
      PO_VENDORS             PV,
      PO_VENDOR_SITES        PVS,
      AP_CARDS               AC,
      AP_CARD_PROGRAMS       ACP,
      GL_SETS_OF_BOOKS          GSB,
      FINANCIALS_SYSTEM_PARAMETERS FSP,
      iby_creditcard ibycc

    WHERE
      PH.TYPE_LOOKUP_CODE = 'STANDARD'
      AND PH.PCARD_ID IS NOT NULL     --p-card is used
      AND FSP.SET_OF_BOOKS_ID = GSB.SET_OF_BOOKS_ID
      AND PH.VENDOR_ID = PV.VENDOR_ID
      AND PV.VENDOR_ID = PVS.VENDOR_ID
      AND PH.VENDOR_SITE_ID = PVS.VENDOR_SITE_ID
      AND PH.AUTHORIZATION_STATUS IN ('APPROVED','REQUIRES REAPPROVAL')
      AND PH.APPROVED_DATE IS NOT NULL
      AND PH.CANCEL_FLAG = 'Y'
      AND PVS.PCARD_SITE_FLAG = 'Y'	 --verifies site uses p-card
      and PH.PCARD_ID = AC.CARD_ID         --valid p-card
      AND AC.CARD_PROGRAM_ID = ACP.CARD_PROGRAM_ID --card reg for program
      AND ACP.CARD_TYPE_LOOKUP_CODE IN ('PROCUREMENT','SUPPLIER')
      AND ACP.CARD_BRAND_LOOKUP_CODE = g_card_brand  --valid card type
      AND ACP.VENDOR_ID = g_card_issuer_id
      AND ACP.VENDOR_SITE_ID = g_card_issuer_site_id
      AND PH.LAST_UPDATE_DATE >= g_from_date_time
      AND PH.LAST_UPDATE_DATE < g_to_date_time
      AND ac.card_reference_id = ibycc.instrid

  UNION ALL   --blanket releases

    SELECT
      PH.SEGMENT1             PO_NUM,          --header, detail
      PR.RELEASE_NUM          RELEASE_NUM,     --header
      PH.PO_HEADER_ID         PO_HEADER_ID,    --for get_total API
      PR.PO_RELEASE_ID        PO_RELEASE_ID,   --for get_total API
      ibycc.masked_cc_number  CARD_NUM,        --header
      AC.CARDMEMBER_NAME      CARD_MEMBER_NAME,  --header
      ACP.CARD_BRAND_LOOKUP_CODE CARD_BRAND,   --select key
      ACP.CARD_TYPE_LOOKUP_CODE CARD_TYPE,     --decode key
      AC.EMPLOYEE_ID         requester_ID,     --header
      PV.VENDOR_NAME          VENDOR_NAME,    --for header, select key
      PVS.VENDOR_SITE_CODE    VENDOR_SITE_CODE,  --header
      PV.VENDOR_ID            VENDOR_ID,        --header
      PVS.VENDOR_SITE_ID      VENDOR_SITE_ID,  --for header, select key
      PR.LAST_UPDATE_DATE     ORDER_DATE,      --header
      GSB.CURRENCY_CODE       BASE_CURR,      --header
      PH.CURRENCY_CODE        LOCAL_CURR,     --header
      PR.AUTHORIZATION_STATUS APPR_STATUS,    --for order status
      PR.APPROVED_DATE        APPR_DATE,      --for order status
      PR.CLOSED_CODE          CONTROL_STATUS, --for order status
      PR.CANCEL_FLAG          CANCEL_FLAG,    --for order status
      PR.HOLD_FLAG       hold_flag          --for order status

    FROM

      PO_HEADERS             PH,
      PO_RELEASES            PR,
      PO_VENDORS             PV,
      PO_VENDOR_SITES        PVS,
      AP_CARDS               AC,
      AP_CARD_PROGRAMS       ACP,
      GL_SETS_OF_BOOKS          GSB,
      FINANCIALS_SYSTEM_PARAMETERS FSP,
      iby_creditcard ibycc

    WHERE
          PH.PO_HEADER_ID = PR.PO_HEADER_ID
      AND PH.TYPE_LOOKUP_CODE = 'BLANKET'
      AND PR.PCARD_ID IS NOT NULL     --p-card is used
      AND FSP.SET_OF_BOOKS_ID = GSB.SET_OF_BOOKS_ID
      AND PH.VENDOR_ID = PV.VENDOR_ID
      AND PV.VENDOR_ID = PVS.VENDOR_ID
      AND PH.VENDOR_SITE_ID = PVS.VENDOR_SITE_ID
      AND PR.AUTHORIZATION_STATUS IN ('APPROVED','REQUIRES REAPPROVAL')
      AND PR.APPROVED_DATE IS NOT NULL
      AND PR.CANCEL_FLAG = 'Y'
      AND PVS.PCARD_SITE_FLAG = 'Y'	 --verifies site uses p-card
      and PR.PCARD_ID = AC.CARD_ID         --valid p-card
      AND AC.CARD_PROGRAM_ID = ACP.CARD_PROGRAM_ID --card reg for progr
      AND ACP.CARD_TYPE_LOOKUP_CODE IN ('PROCUREMENT','SUPPLIER')
      AND ACP.CARD_BRAND_LOOKUP_CODE = g_card_brand
      AND ACP.VENDOR_ID = g_card_issuer_id
      AND ACP.VENDOR_SITE_ID = g_card_issuer_site_id
      AND PR.LAST_UPDATE_DATE >= g_from_date_time
      AND PR.LAST_UPDATE_DATE < g_to_date_time
      AND ac.card_reference_id = ibycc.instrid;

  l_log_msg              FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_progress            VARCHAR2(4) := '000';

BEGIN

  l_progress := '000';

  --Insert standard POs and blanket releases with catalog or non-catalog items into por_feed_records
  IF cur_PO_records%ISOPEN THEN
    CLOSE cur_PO_records;
  END IF;

  OPEN cur_PO_records;

  FETCH cur_PO_records BULK COLLECT
   INTO l_po_num,
        l_rel_num,
        l_header_id,
        l_release_id,
        l_card_num,
        l_cardmember,
        l_card_brand,
        l_card_type,
        l_req_id,
        l_vendor_name,
        l_vendor_site_code,
        l_vendor_id,
        l_vendor_site_id,
        l_order_date,
        l_base_curr,
        l_local_curr,
        l_uom,
        l_item_num,
        l_item_desc,
        l_qty,
        l_unit_price,
        l_amount,
        l_acct_id,
        l_acct_code,
        l_appr_status,
        l_appr_date,
        l_contr_status,
        l_cancel_flag,
        l_hold_flag,
        l_line_cancel_flag,
        l_shipment_cancel_flag;

--  fnd_file.put_line(fnd_file.log, '# fetched : ' || to_char(cur_po_records%rowcount));

  l_progress := '010';

    IF (G_LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||'Get_PO_Distributions', '# of PO Records = ' || cur_PO_records%ROWCOUNT);
    END IF;

  FORALL i in 1 .. cur_PO_records%ROWCOUNT

    INSERT INTO por_feed_records (
      concurrent_request_id,
      po_number,
      release_number,
      po_header_id,
      po_release_id,
      card_number,
      card_member_name,
      card_brand_lookup_code,
      card_type_lookup_code,
      requester_id,
      vendor_name,
      vendor_site_code,
      vendor_id,
      vendor_site_id,
      order_date,
      base_currency_code,
      local_currency_code,
      unit_of_measure,
      item_number,
      item_description,
      quantity,
      unit_price,
      amount,
      chart_of_accounts_id,
      accounting_code,
      approval_status,
      approved_date,
      control_status,
      cancel_flag,
      hold_flag,
      line_cancel_flag,
      shipment_cancel_flag
      )
  VALUES (
      g_conc_req_id,
      l_po_num(i),
      l_rel_num(i),
      l_header_id(i),
      l_release_id(i),
      l_card_num(i),
      l_cardmember(i),
      l_card_brand(i),
      l_card_type(i),
      l_req_id(i),
      l_vendor_name(i),
      l_vendor_site_code(i),
      l_vendor_id(i),
      l_vendor_site_id(i),
      l_order_date(i),
      l_base_curr(i),
      l_local_curr(i),
      l_uom(i),
      l_item_num(i),
      l_item_desc(i),
      l_qty(i),
      l_unit_price(i),
      l_amount(i),
      l_acct_id(i),
      l_acct_code(i),
      l_appr_status(i),
      l_appr_date(i),
      l_contr_status(i),
      l_cancel_flag(i),
      l_hold_flag(i),
      l_line_cancel_flag(i),
      l_shipment_cancel_flag(i)
      );

  COMMIT;

  IF cur_PO_records%ISOPEN THEN
    CLOSE cur_PO_records;
  END IF;

  l_progress := '020';


  --Insert canceled standard POs and blanket releases into por_feed_records

  IF cur_canceled_POs%ISOPEN THEN
    CLOSE cur_canceled_POs;
  END IF;

  OPEN cur_canceled_POs;

  FETCH cur_canceled_POs BULK COLLECT
   INTO l_po_num,
        l_rel_num,
        l_header_id,
        l_release_id,
        l_card_num,
        l_cardmember,
        l_card_brand,
        l_card_type,
        l_req_id,
        l_vendor_name,
        l_vendor_site_code,
        l_vendor_id,
        l_vendor_site_id,
        l_order_date,
        l_base_curr,
        l_local_curr,
        l_appr_status,
        l_appr_date,
        l_contr_status,
        l_cancel_flag,
        l_hold_flag;

--  fnd_file.put_line(fnd_file.log, '# canceled fetched : ' || to_char(cur_canceled_POs%rowcount));

  l_progress := '030';

    IF (G_LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||'Get_PO_Distributions', '# of Cancelled POs = ' || cur_canceled_POs%ROWCOUNT);
    END IF;

  FORALL i in 1 .. cur_canceled_POs%ROWCOUNT

    INSERT INTO por_feed_records (
      concurrent_request_id,
      po_number,
      release_number,
      po_header_id,
      po_release_id,
      card_number,
      card_member_name,
      card_brand_lookup_code,
      card_type_lookup_code,
      requester_id,
      vendor_name,
      vendor_site_code,
      vendor_id,
      vendor_site_id,
      order_date,
      base_currency_code,
      local_currency_code,
      approval_status,
      approved_date,
      control_status,
      cancel_flag,
      hold_flag
      )
  VALUES (
      g_conc_req_id,
      l_po_num(i),
      l_rel_num(i),
      l_header_id(i),
      l_release_id(i),
      l_card_num(i),
      l_cardmember(i),
      l_card_brand(i),
      l_card_type(i),
      l_req_id(i),
      l_vendor_name(i),
      l_vendor_site_code(i),
      l_vendor_id(i),
      l_vendor_site_id(i),
      l_order_date(i),
      l_base_curr(i),
      l_local_curr(i),
      l_appr_status(i),
      l_appr_date(i),
      l_contr_status(i),
      l_cancel_flag(i),
      l_hold_flag(i)
      );

  COMMIT;

  IF cur_canceled_POs%ISOPEN THEN
    CLOSE cur_canceled_POs;
  END IF;

  l_progress := '040';

EXCEPTION

  WHEN OTHERS THEN
    IF (G_LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Error in Get_PO_Distributions : SQLERRM= ' ||
                         SQLERRM || ' : Progress= ' || l_progress;
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||'Get_PO_Distributions', l_log_msg);
    END IF;

    RAISE;

END Get_PO_Distributions;

---------------------------------------------------------------------------------------
-- Parameters are passed to the Main Program in order to specify the set of PO records
-- to retrieve.  All the visible parameters are mandatory and are defaulted or user-
-- entered. They are validated in the Concurrent Manager upon user-entry before being
-- passed to the program.  Inv_org_id (MFG_ORGANIZATION_ID profile value) is passed to
-- restrict item selection to the inventory organization associated with the
-- responsibility used.
---------------------------------------------------------------------------------------

PROCEDURE Main (
   ERRBUF            OUT NOCOPY VARCHAR2,
   RETCODE           OUT NOCOPY VARCHAR2,
   i_card_brand      IN VARCHAR2,
   i_card_issuer_id     IN NUMBER,
   i_card_issuer_site_id IN NUMBER,
   i_from_date_time   IN VARCHAR2,
   i_to_date_time      IN VARCHAR2,
   i_output_filename IN VARCHAR2
   ) IS

  l_outdir         VARCHAR2(100) := NULL;
  l_result         BOOLEAN := FALSE;
  l_phase VARCHAR2(25) := NULL;
  l_status VARCHAR2(25) := NULL;
  l_dev_status VARCHAR2(25) := NULL;
  l_dev_phase VARCHAR2(25) := NULL;
  l_message VARCHAR2(2000) := NULL;
  l_org_chart_of_accounts_id NUMBER := 0;
  l_func_curr_code VARCHAR2(15) := NULL;

  l_log_msg              FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_progress            VARCHAR2(4) := '000';

BEGIN
  l_progress := '000';

  -- Logging Procedure level
  IF (G_LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||'Main.begin', '<-------------------->');
  END IF;

  g_card_brand       := i_card_brand;
  g_card_issuer_id      := i_card_issuer_id;
  g_card_issuer_site_id := i_card_issuer_site_id;
  g_output_filename  := i_output_filename;

  g_from_date_time := to_date(rtrim (to_char (to_date (i_from_date_time,'YYYY/MM/DD HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS')),
                        'DD-MON-YYYY HH24:MI:SS');
  g_to_date_time := to_date(rtrim (to_char (to_date (i_to_date_time,'YYYY/MM/DD HH24:MI:SS'), 'DD-MON-YYYY HH24:MI:SS')),
                        'DD-MON-YYYY HH24:MI:SS');

  l_progress := '100';

  IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'Input Params :: i_card_brand = ' || i_card_brand ||
                 '  :: i_card_issuer_id = ' || to_char(i_card_issuer_id) ||
                 '  :: i_card_issuer_site_id = ' || to_char(i_card_issuer_site_id) ||
                 '  :: i_from_date_time = ' || i_from_date_time ||
                 '  :: i_to_date_time = ' || i_to_date_time ||
                 '  :: i_output_filename = ' || i_output_filename;
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||'Main', l_log_msg);
  END IF;

--  fnd_file.put_line(fnd_file.log, 'reformatted from date/time: ' || to_char(g_from_date_time,'DD-MON-YYYY HH24:MI:SS'));
--  fnd_file.put_line(fnd_file.log, 'reformatted to date/time: ' || to_char(g_to_date_time,'DD-MON-YYYY HH24:MI:SS'));

  mo_global.set_policy_context('S', g_org_id);

  l_progress := '200';

  SELECT fsp.inventory_organization_id, gsb.chart_of_accounts_id, gsb.currency_code
    INTO g_inv_org_id, l_org_chart_of_accounts_id, l_func_curr_code
    FROM financials_system_parameters fsp,
         gl_sets_of_books gsb
   WHERE fsp.set_of_books_id = gsb.set_of_books_id
     AND fsp.org_id = g_org_id;

  l_progress := '300';

  g_delimiter := fnd_flex_ext.get_delimiter('SQLGL', 'GL#', l_org_chart_of_accounts_id);

  g_max_card_num_size := Get_Field_Size ('CARD_NUMBER','H');
  g_max_po_num_size   := Get_Field_Size ('PO_NUMBER','H');

  l_progress := '400';

  IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := '  l_func_curr_code = ' || l_func_curr_code ||
                 '  :: l_org_chart_of_accounts_id = ' || to_char(l_org_chart_of_accounts_id) ||
                 '  :: g_inv_org_id = ' || to_char(g_inv_org_id);
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||'Main', l_log_msg);
  END IF;

  --log run in por_feed_history

  INSERT INTO por_feed_history (
    concurrent_request_id,
    card_brand_lookup_code,
    vendor_id,
    vendor_site_id,
    from_date_time,
    to_date_time,
    output_filename,
    last_update_login,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by
    )
  VALUES (
    g_conc_req_id,
    g_card_brand,
    g_card_issuer_id,
    g_card_issuer_site_id,
    g_from_date_time,
    g_to_date_time,
    g_output_filename,
    g_last_update_login,
    sysdate,
    g_last_updated_by,
    sysdate,
    g_created_by);

  l_progress := '500';

  COMMIT;

  Get_PO_Distributions;

  l_progress := '600';

  Get_Header_Amounts;

  l_progress := '700';

  -- We no longer need to trim thr card numbers in R12 since AP now stores
  -- card numbers encrypted (i.e. XXXXXXXXXXXX1234)
  --Trim_Card_Numbers;

  l_progress := '800';

  FND_PROFILE.GET('ECE_OUT_FILE_PATH',l_outdir);

  IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||'Main', 'Output Directory = ' || l_outdir);
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||'Main', 'Filename = ' || g_output_filename);
  END IF;

  -- Set the linesize to the maximum value of 32767 while opening the file
  g_outfile := UTL_FILE.FOPEN(
                              l_outdir,
                              g_output_filename,
                              'w',
                              32767);

  l_progress := '900';

  Write_Control_Record;

  l_progress := '1000';

  Write_Header_Record;

  l_progress := '1100';

  UTL_FILE.FCLOSE(g_outfile);

  DELETE FROM por_feed_records
  WHERE concurrent_request_id = g_conc_req_id;

  --get conc mgr status;
  l_result := FND_CONCURRENT.GET_REQUEST_STATUS(
                g_conc_req_id,  --request_id
                NULL,              --application default null
                NULL,              --program default null
                l_phase,           --phase out
                l_status,          --status out
                l_dev_status,      --dev_status out
                l_dev_phase,       --dev_phase out
                l_message          --message out
               );

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Output file has been created successfully.');

  IF (G_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := '  g_po_num_err = ' || g_po_num_err ||
                 '  :: g_card_num_err = ' || g_card_num_err ||
                 '  :: l_message = ' || l_message;
    FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||'Main', l_log_msg);
  END IF;

  l_progress := '1200';

  IF g_po_num_err IS NOT NULL THEN
    --Write to Conc Mgr log file
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET_STRING('ICX','ICX_POR_HIST_FEED_PO_NUM_LONG'));
    FND_FILE.PUT_LINE (FND_FILE.LOG, g_po_num_err);
    ERRBUF := NULL;  --appears to get truncated; might not be long enough for custom error to be assigned to it
    RETCODE := '1';  --forces warning status
    l_result :=FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', FND_MESSAGE.GET_STRING('ICX','ICX_POR_HIST_FEED_COMP_TEXT')); --overwrite conc mgr status
  END IF;

  IF g_card_num_err IS NOT NULL THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET_STRING('ICX','ICX_POR_HIST_FEED_CARDNO_LONG'));
    FND_FILE.PUT_LINE (FND_FILE.LOG, g_card_num_err);
    ERRBUF := NULL;  --appears to get truncated; might not be long enough...
    RETCODE := '1';  --forces warning status
    l_result := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', FND_MESSAGE.GET_STRING('ICX','ICX_POR_HIST_FEED_COMP_TEXT'));  --overwrite conc mgr status
  END IF;

 --update por_feed_history to log status

  UPDATE por_feed_history
     SET status = ltrim(l_status)
   WHERE concurrent_request_id = g_conc_req_id;

  COMMIT;

  l_progress := '1300';

  -- Logging Procedure level
  IF (G_LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||'Main.end', '<-------------------->');
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF (G_LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Error in Concurrent request : SQLERRM= ' ||
                         SQLERRM || ' : Progress= ' || l_progress;
      FND_LOG.STRING(G_LEVEL_EXCEPTION, G_MODULE_NAME||'Main', l_log_msg);
    END IF;

    UTL_FILE.FCLOSE(g_outfile);
    RAISE;
END Main;

END POR_History_Feed_Pkg;  --package

/
