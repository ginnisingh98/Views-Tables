--------------------------------------------------------
--  DDL for Package Body PO_COPY_DOCUMENTS_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COPY_DOCUMENTS_S" AS
/* $Header: POXDOCPB.pls 120.10 2007/12/18 07:29:01 grohit ship $ */
/* Type declaration for WHO information structure */
                TYPE who_record_type IS RECORD
                (user_id number:= 0,
                     login_id number:= 0,
                     resp_id number:= 0);

/* Type declaration for  System Parameters structure */
TYPE system_parameters_type IS RECORD
                (currency_code gl_sets_of_books.currency_code % type,
                     coa_id number,
                     po_encumbrance_flag varchar2(1),
                     req_encumbrance_flag varchar2(1),
                     sob_id number,
                     ship_to_location_id number,
                     bill_to_location_id number,
                     fob_lookup_code financials_system_parameters.fob_lookup_code % type,
                     freight_terms_lookup_code
                     financials_system_parameters.freight_terms_lookup_code % type,
                     terms_id number,
                     default_rate_type po_system_parameters.default_rate_type % type,
                     taxable_flag varchar2(1),
                     receiving_flag varchar2(1),
                     enforce_buyer_name_flag varchar2(1),
                     enforce_buyer_auth_flag varchar2(1),
                     line_type_id number:= null,
                     manual_po_num_type po_system_parameters.manual_po_num_type % type,
                     po_num_code po_system_parameters.user_defined_po_num_code % type,
                     price_type_lookup_code po_system_parameters.price_type_lookup_code % type,
                     invoice_close_tolerance number,
                     receive_close_tolerance number,
                     security_structure_id number,
                     expense_accrual_code po_system_parameters.price_type_lookup_code % type,
                     inventory_organization_id number,
                     rev_sort_ordering number,
                     min_rel_amount number,
                     notify_blanket_flag varchar2(1),
                     budgetary_control_flag varchar2(1),
                     user_defined_req_num_code po_system_parameters.user_defined_req_num_code % type,
                     rfq_required_flag varchar2(1),
                     manual_req_num_type po_system_parameters.manual_req_num_type % type,
                     enforce_full_lot_qty po_system_parameters.enforce_full_lot_quantities % type,
                     disposition_warning_flag varchar2(1),
                     reserve_at_completion_flag varchar2(1),
                     user_defined_rcpt_num_code
                  po_system_parameters.user_defined_receipt_num_code % type,
                     manual_rcpt_num_type po_system_parameters.manual_receipt_num_type % type,
                     use_positions_flag varchar2(1),
                     default_quote_warning_delay number,
                     inspection_required_flag varchar2(1),
                     user_defined_quote_num_code
                    po_system_parameters.user_defined_quote_num_code % type,
                     manual_quote_num_type po_system_parameters.manual_quote_num_type % type,
                     user_defined_rfq_num_code
                      po_system_parameters.user_defined_rfq_num_code % type,
                     manual_rfq_num_type po_system_parameters.manual_rfq_num_type % type,
                     ship_via_lookup_code financials_system_parameters.ship_via_lookup_code % type,
                     qty_rcv_tolerance number,
                   period_name gl_period_statuses.period_name % type);

/* Global variable declarations */

who             who_record_type;
params          system_parameters_type;
x_progress
varchar2(4):= null;



/* Private Procedure prototypes */
/* replace this with a simple version in future */
  PROCEDURE       get_copy_defaults;

/* publish copy header, lines, shipments, distributions in the future */

  PROCEDURE       copy_header(
                            x_po_header_id IN number,
                          x_new_document_type IN varchar2,
                       x_new_document_subtype IN varchar2,
                        x_new_supplier_id IN number,
                         x_new_supplier_site_id IN number,
                      x_new_supplier_contact_id IN number,
                            x_copy_mode IN varchar2,
                           x_copy_attachments IN varchar2,
                           x_new_document_num IN varchar2,
                            x_new_po_header_id OUT NOCOPY number,
                         x_actual_document_num IN OUT NOCOPY varchar2);

  procedure       copy_lines(x_from_po_header_id number,
                           x_to_po_header_id number,
                           x_copy_mode varchar2,
                        x_copy_attachments varchar2,
                            x_new_document_type varchar2,
                        x_new_supplier_id IN number,
                         x_new_supplier_site_id IN number);

  procedure       copy_shipments(x_from_po_line_id number,
                             x_to_po_line_id number,
                               x_copy_mode varchar2,
                        x_copy_attachments varchar2,
                            x_new_document_type varchar2,
                            x_new_tax_flag varchar2,
                                  x_tax_id ap_tax_codes.tax_id%type);


/*
 * =========================================================================
 *
 * PROCEDURE NAME:  copy_header
 *
 * ==========================================================================
 */

  PROCEDURE       copy_header(
                            x_po_header_id IN number,
                          x_new_document_type IN varchar2,
                       x_new_document_subtype IN varchar2,
                        x_new_supplier_id IN number,
                         x_new_supplier_site_id IN number,
                      x_new_supplier_contact_id IN number,
                            x_copy_mode IN varchar2,
                           x_copy_attachments IN varchar2,
                           x_new_document_num IN varchar2,
                            x_new_po_header_id OUT NOCOPY number,
                          x_actual_document_num IN OUT NOCOPY varchar2)
                IS

                x_local_po_header_id number;
  x_default_quote_warning_delay number;

  -- bug5176308
  l_unique_id_tbl_name PO_UNIQUE_IDENTIFIER_CONT_ALL.table_name%TYPE;

BEGIN
x_progress:= '001';
IF(x_new_document_Num is NULL) THEN
/*
 * new document number not specified specified, get the new number from the
 * PO UNIQUE ID control tables, even if you are using MANUAL numbering
 */

x_progress:= '002';

  -- bug5176308 START
  -- Use API to get the new document number

  IF (x_new_document_type IN ('STANDARD', 'BLANKET', 'CONTRACT')) THEN
    l_unique_id_tbl_name := 'PO_HEADERS';
  ELSIF (x_new_document_type = 'QUOTATION') THEN
    l_unique_id_tbl_name := 'PO_HEADERS_QUOTE';
  ELSIF (x_new_document_type = 'RFQ') THEN
    l_unique_id_tbl_name := 'PO_HEADERS_RFQ';
  END IF;

  x_actual_document_num :=
    PO_CORE_SV1.default_po_unique_identifier
    ( x_table_name => l_unique_id_tbl_name
    );

  -- bug5176308 END


ELSE
/* otherwise, use the document number passed to proc */
x_actual_document_num:= x_new_document_num;

  END             IF;

IF(x_new_document_type = 'QUOTATION') THEN
/* get the default quote warning delay since it is mandatory for quotes  */

x_progress:= '004';
  SELECT          nvl(default_quote_warning_delay, 0)
  INTO            x_default_quote_warning_delay
                  FROM po_system_parameters;
ELSE
x_default_quote_warning_delay:= null;
  END             IF;

x_progress:= '005';

  select          po_headers_s.nextval
                  into x_local_po_header_id
                  from dual;

x_new_po_header_id:= x_local_po_header_id;

x_progress:= '006';

  insert into     po_headers(
                           PO_HEADER_ID
                          ,AGENT_ID
                          ,TYPE_LOOKUP_CODE
                          ,LAST_UPDATE_DATE
                          ,LAST_UPDATED_BY
                          ,SEGMENT1
                          ,SUMMARY_FLAG
                          ,ENABLED_FLAG
                          ,SEGMENT2
                          ,SEGMENT3
                          ,SEGMENT4
                          ,SEGMENT5
                          ,START_DATE_ACTIVE
                          ,END_DATE_ACTIVE
                          ,LAST_UPDATE_LOGIN
                          ,CREATION_DATE
                          ,CREATED_BY
                          ,VENDOR_ID
                          ,VENDOR_SITE_ID
                          ,VENDOR_CONTACT_ID
                          ,SHIP_TO_LOCATION_ID
                          ,BILL_TO_LOCATION_ID
                          ,TERMS_ID
                          ,SHIP_VIA_LOOKUP_CODE
                          ,FOB_LOOKUP_CODE
                          ,FREIGHT_TERMS_LOOKUP_CODE
                          ,STATUS_LOOKUP_CODE
                          ,CURRENCY_CODE
                          ,RATE_TYPE
                          ,RATE_DATE
                          ,RATE
                          ,FROM_HEADER_ID
                          ,FROM_TYPE_LOOKUP_CODE
                          ,START_DATE
                          ,END_DATE
                          ,BLANKET_TOTAL_AMOUNT
                          ,AUTHORIZATION_STATUS
                          ,REVISION_NUM
                          ,REVISED_DATE
                          ,APPROVED_FLAG
                          ,APPROVED_DATE
                          ,NOTE_TO_AUTHORIZER
                          ,NOTE_TO_VENDOR
                          ,NOTE_TO_RECEIVER
                          ,PRINT_COUNT
                          ,PRINTED_DATE
                          ,VENDOR_ORDER_NUM
                          ,CONFIRMING_ORDER_FLAG
                          ,COMMENTS
                          ,REPLY_DATE
                          ,REPLY_METHOD_LOOKUP_CODE
                          ,RFQ_CLOSE_DATE
                          ,QUOTE_TYPE_LOOKUP_CODE
                          ,QUOTE_WARNING_DELAY_UNIT
                          ,QUOTE_WARNING_DELAY
                          ,QUOTE_VENDOR_QUOTE_NUMBER
                          ,ACCEPTANCE_REQUIRED_FLAG
                          ,ACCEPTANCE_DUE_DATE
                          ,USER_HOLD_FLAG
                          ,CANCEL_FLAG
                          ,FIRM_STATUS_LOOKUP_CODE
                          ,FIRM_DATE
                          ,FROZEN_FLAG
                          ,ATTRIBUTE_CATEGORY
                          ,ATTRIBUTE1
                          ,ATTRIBUTE2
                          ,ATTRIBUTE3
                          ,ATTRIBUTE4
                          ,ATTRIBUTE5
                          ,ATTRIBUTE6
                          ,ATTRIBUTE7
                          ,ATTRIBUTE8
                          ,ATTRIBUTE9
                          ,ATTRIBUTE10
                          ,ATTRIBUTE11
                          ,ATTRIBUTE12
                          ,ATTRIBUTE13
                          ,ATTRIBUTE14
                          ,ATTRIBUTE15
                          ,AMOUNT_LIMIT
                          ,APPROVAL_REQUIRED_FLAG
                          ,MIN_RELEASE_AMOUNT
                          ,QUOTATION_CLASS_CODE
                          ,CLOSED_CODE
                          ,GOVERNMENT_CONTEXT
                          ,PROGRAM_APPLICATION_ID
                          ,PROGRAM_ID
                          ,PROGRAM_UPDATE_DATE
                          ,REQUEST_ID
                          ,CLOSED_DATE
                          ,ORG_ID
                  ,DOCUMENT_CREATION_METHOD  -- <DBI FPJ>
                  ,STYLE_ID      --<R12 STYLES PHASE II >
                  ,CREATED_LANGUAGE      --Bug#5401155
            )
                SELECT
                x_local_po_header_id
               ,AGENT_ID
               ,x_new_document_type
               ,sysdate
               ,who.user_id
               ,x_actual_document_num
               ,'N'
               ,'Y'
               ,SEGMENT2
               ,SEGMENT3
               ,SEGMENT4
               ,SEGMENT5
               ,START_DATE_ACTIVE
               ,END_DATE_ACTIVE
               ,who.login_id
               ,sysdate
               ,who.user_id
--              keep original supplier if new supplier is null
               ,
nvl(x_new_supplier_id, VENDOR_ID)
  --keep original supplier site if new supplier site is null
  ,nvl(x_new_supplier_site_id, VENDOR_SITE_ID)
    --only keep original supplier contact if copying to the same supplier site
    ,nvl(x_new_supplier_contact_id, VENDOR_CONTACT_ID)
      ,SHIP_TO_LOCATION_ID
      ,BILL_TO_LOCATION_ID
      ,TERMS_ID
      ,SHIP_VIA_LOOKUP_CODE
      ,FOB_LOOKUP_CODE
      ,FREIGHT_TERMS_LOOKUP_CODE
      -- set status lookup to incomplete
      ,'I'
      ,CURRENCY_CODE
      ,RATE_TYPE
      ,RATE_DATE
      ,RATE
      -- set from header id and type to original doc type
      ,po_header_id
      ,TYPE_LOOKUP_CODE
      ,START_DATE
      ,END_DATE
      ,BLANKET_TOTAL_AMOUNT
      ,AUTHORIZATION_STATUS
      -- reset revision num, revised date, approved flag, approved date
      ,null
      ,null
      ,null
      ,null
      ,NOTE_TO_AUTHORIZER
      ,NOTE_TO_VENDOR
      ,NOTE_TO_RECEIVER
      -- reset print count and date
      ,null
      ,null
      ,VENDOR_ORDER_NUM
      ,CONFIRMING_ORDER_FLAG
      ,COMMENTS
      ,REPLY_DATE
      ,REPLY_METHOD_LOOKUP_CODE
      ,RFQ_CLOSE_DATE
      ,x_new_document_subtype
      ,QUOTE_WARNING_DELAY_UNIT
      ,x_default_quote_warning_delay
      ,QUOTE_VENDOR_QUOTE_NUMBER
      ,ACCEPTANCE_REQUIRED_FLAG
      ,ACCEPTANCE_DUE_DATE
      ,USER_HOLD_FLAG
      -- reset cancel flag
      ,NULL
      ,FIRM_STATUS_LOOKUP_CODE
      ,FIRM_DATE
      -- reset frozen flag
      ,Null
      ,ATTRIBUTE_CATEGORY
      ,ATTRIBUTE1
      ,ATTRIBUTE2
      ,ATTRIBUTE3
      ,ATTRIBUTE4
      ,ATTRIBUTE5
      ,ATTRIBUTE6
      ,ATTRIBUTE7
      ,ATTRIBUTE8
      ,ATTRIBUTE9
      ,ATTRIBUTE10
      ,ATTRIBUTE11
      ,ATTRIBUTE12
      ,ATTRIBUTE13
      ,ATTRIBUTE14
      ,ATTRIBUTE15
      ,AMOUNT_LIMIT
      ,APPROVAL_REQUIRED_FLAG
      ,MIN_RELEASE_AMOUNT
      ,QUOTATION_CLASS_CODE
      -- reset closed code
      ,null
      ,GOVERNMENT_CONTEXT
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_ID
      ,PROGRAM_UPDATE_DATE
      ,REQUEST_ID
      ,CLOSED_DATE
      ,ORG_ID
                        -- Bug 3648268. Using lookup code instead of hardcoded value
      ,'COPY_DOCUMENT'  -- <DBI FPJ>
      ,STYLE_ID         --<R12 STYLES PHASE II >
      ,decode(x_new_document_type, 'QUOTATION', nvl(created_language, PO_ATTRIBUTE_VALUES_PVT.get_base_lang), created_language) --Bug#5401155
      from po_headers
      where po_header_id = x_po_header_id;

IF(x_copy_attachments = 'Y') THEN

x_progress:= '007';

--API to copy attachments from requisition line to po line
fnd_attached_documents2_pkg.
copy_attachments('PO_HEADERS',
     x_po_header_id,
     '',
     '',
     '',
     '',
     'PO_HEADERS',
     x_local_po_header_id,
     '',
     '',
     '',
     '',
     who.user_id,
     who.login_id,
     '',
     '',
     '');
END             IF;

EXCEPTION
WHEN OTHERS THEN
po_message_s.sql_error('COPY header', x_progress, sqlcode);
raise;

END             copy_header;



/*
 * ===========================================================================
 * = NAME: get copy defaults DESC: replace this with Kim's call in future
 *
 * ==========================================================================
 */

PROCEDURE get_copy_defaults IS
                BEGIN

                x_progress:= '000';

/* Get WHO column values */
who.user_id:= nvl(fnd_global.user_id, 0);
who.login_id:= nvl(fnd_global.login_id, 0);
who.resp_id:= nvl(fnd_global.resp_id, 0);

x_progress:= '001';

/* Get system defaults */
po_core_s.get_po_parameters(params.currency_code,
          params.coa_id,
          params.po_encumbrance_flag,
          params.req_encumbrance_flag,
          params.sob_id,
          params.ship_to_location_id,
          params.bill_to_location_id,
          params.fob_lookup_code,
          params.freight_terms_lookup_code,
          params.terms_id,
          params.default_rate_type,
          params.taxable_flag,
          params.receiving_flag,
          params.enforce_buyer_name_flag,
          params.enforce_buyer_auth_flag,
          params.line_type_id,
          params.manual_po_num_type,
          params.po_num_code,
          params.price_type_lookup_code,
          params.invoice_close_tolerance,
          params.receive_close_tolerance,
          params.security_structure_id,
          params.expense_accrual_code,
          params.inventory_organization_id,
          params.rev_sort_ordering,
          params.min_rel_amount,
          params.notify_blanket_flag,
          params.budgetary_control_flag,
          params.user_defined_req_num_code,
          params.rfq_required_flag,
          params.manual_req_num_type,
          params.enforce_full_lot_qty,
          params.disposition_warning_flag,
          params.reserve_at_completion_flag,
          params.user_defined_rcpt_num_code,
          params.manual_rcpt_num_type,
          params.use_positions_flag,
          params.default_quote_warning_delay,
          params.inspection_required_flag,
          params.user_defined_quote_num_code,
          params.manual_quote_num_type,
          params.user_defined_rfq_num_code,
          params.manual_rfq_num_type,
          params.ship_via_lookup_code,
          params.qty_rcv_tolerance);

EXCEPTION
WHEN OTHERS THEN
po_message_s.sql_error('GET COPY DEFAULTS', x_progress, sqlcode);
raise;

END             get_copy_defaults;



/*
 * ===========================================================================
 *
 * PROCEDURE NAME:  copy_lines
 *
 * ===========================================================================
 */

procedure
copy_lines(x_from_po_header_id IN number,
     x_to_po_header_id IN number,
     x_copy_mode IN varchar2,
     x_copy_attachments IN varchar2,
     x_new_document_type IN varchar2,
     x_new_supplier_id IN number,
     x_new_supplier_site_id IN number) IS

  x_from_po_line_id number;
  x_to_po_line_id number;

        /* Additional tax variables for R11 tax defaulting functionality */
        x_tax_id                        ap_tax_codes.tax_id%type;
        x_allow_tax_code_override_flag  gl_tax_option_accounts.allow_tax_code_override_flag%type;
  x_ship_to_location_id   po_headers.ship_to_location_id%type;
  x_ship_to_loc_org_id    hr_locations.inventory_organization_id%type;
  x_item_id     mtl_system_items.inventory_item_id%type;
  x_new_tax_flag      varchar2(1):=null;

  -- Bug#5401155
  l_po_category_id    po_lines.category_id%TYPE;
  l_ip_category_id    po_lines.ip_category_id%TYPE;
  l_item_description  po_lines.item_description%TYPE;
  l_item_id           po_lines.item_id%TYPE;
  l_org_id            po_lines.org_id%TYPE;

  -- Bug#5401155: fetch category_id, description, item_id, org_id - needed to create default attributes
  CURSOR  lines_cursor(x_get_po_header_id number) IS
                SELECT po_line_id, category_id, item_description, item_id, org_id
                FROM po_lines pl
                WHERE pl.po_header_id = x_get_po_header_id
                ORDER BY pl.po_line_id;

BEGIN

x_progress:= '001';
--dbms_output.put_line('progress 001');

  OPEN            lines_cursor(x_from_po_header_id);
--dbms_output.put_line('progress 002' || x_from_po_header_id);
x_progress:= '002';

LOOP
--dbms_output.put_line('progress 003');

  FETCH lines_cursor INTO x_from_po_line_id, l_po_category_id, l_item_description, l_item_id, l_org_id;
  EXIT WHEN       lines_cursor % notfound;

--dbms_output.put_line('progress 005');
x_progress:= '004';

/* get the new line id */
  select          po_lines_s.nextval
                  into x_to_po_line_id
                  from dual;

-- R11:  User-defined tax defaulting enhancements.  When copying a document where
--       new information is available which may affect the tax on the document,
--       re-default the tax here.  For example when copying RFQs to Quotations,
--       new supplier and supplier site information becomes available.  Tax should
--       be re-defaulted to take this new information into account.
--       If a new tax name is needed this is also passed into the copy_shipments
--       procedure and used on the new document shipment.


   IF (x_new_supplier_id is not NULL) OR (x_new_supplier_site_id is not NULL) THEN

/* Bug 1484350 draising
   Description:  x_new_tax_flag is commented coz. this flag is no more in use.
   the logic is changed so that if there is no tax_code defined for new supplier
   in the quotation tax code from RFQ will be copied.
   otherwise if  tax code is defined for the new supplier it will consider the
   default tax_code of new supplier.
*/


--  x_new_tax_flag := 'Y';

-- bug: 1534559 Handle the exception when ship_to_loc is not found

        BEGIN
  SELECT  poh.ship_to_location_id
  INTO  x_ship_to_location_id
  FROM  po_headers poh
  WHERE   poh.po_header_id = x_from_po_header_id;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                x_ship_to_location_id := NULL;
        END;

-- bug: 1534559 Handle the exception when ship_to_org is not found

        BEGIN
  SELECT  hrl.inventory_organization_id
  INTO  x_ship_to_loc_org_id
  FROM  hr_locations hrl
  WHERE   hrl.location_id = x_ship_to_location_id;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
                x_ship_to_loc_org_id  := NULL;
        END;

  SELECT  pol.item_id
  INTO  x_item_id
  FROM  po_lines pol
  WHERE pol.po_line_id = x_from_po_line_id;

  END IF;

x_progress:= '005';
--dbms_output.put_line('progress 005');

  -- Bug#5401155
  -- Get the ip category id: From RFQ you can create only a quote.
  IF(x_new_document_type = 'QUOTATION') THEN
    PO_ATTRIBUTE_VALUES_PVT.get_ip_category_id(p_po_category_id => l_po_category_id,
                                               x_ip_category_id => l_ip_category_id);
  END IF;

  /* create the new line */
        -- <SERVICES FPJ>
        -- Added order_type_lookup_code, purchase_basis and
        -- matching_basis as part of denormalization
  insert into     po_lines(
                         PO_LINE_ID
                        ,LAST_UPDATE_DATE
                        ,LAST_UPDATED_BY
                        ,PO_HEADER_ID
                        ,LINE_TYPE_ID
                        ,LINE_NUM
                        ,LAST_UPDATE_LOGIN
                        ,creation_date
                        ,created_by
                        ,ITEM_ID
                        ,ITEM_REVISION
                        ,CATEGORY_ID
                        ,ITEM_DESCRIPTION
                        ,UNIT_MEAS_LOOKUP_CODE
                        ,QUANTITY_COMMITTED
                        ,COMMITTED_AMOUNT
                        ,ALLOW_PRICE_OVERRIDE_FLAG
                        ,NOT_TO_EXCEED_PRICE
                        ,LIST_PRICE_PER_UNIT
                        ,UNIT_PRICE
                        ,QUANTITY
                        ,UN_NUMBER_ID
                        ,HAZARD_CLASS_ID
                        ,NOTE_TO_VENDOR
                        ,FROM_HEADER_ID
                        ,FROM_LINE_ID
                        ,MIN_ORDER_QUANTITY
                        ,MAX_ORDER_QUANTITY
                        ,QTY_RCV_TOLERANCE
                        ,OVER_TOLERANCE_ERROR_FLAG
                        ,MARKET_PRICE
                        ,UNORDERED_FLAG
                        ,CLOSED_FLAG
                        ,USER_HOLD_FLAG
                        ,CANCEL_FLAG
                        ,CANCELLED_BY
                        ,CANCEL_DATE
                        ,CANCEL_REASON
                        ,FIRM_STATUS_LOOKUP_CODE
                        ,FIRM_DATE
                        ,VENDOR_PRODUCT_NUM
                        ,CONTRACT_NUM
                        ,TAXABLE_FLAG
                        ,TAX_CODE_ID
                        ,TYPE_1099
                        ,CAPITAL_EXPENSE_FLAG
                        ,NEGOTIATED_BY_PREPARER_FLAG
                        ,ATTRIBUTE_CATEGORY
                        ,ATTRIBUTE1
                        ,ATTRIBUTE2
                        ,ATTRIBUTE3
                        ,ATTRIBUTE4
                        ,ATTRIBUTE5
                        ,ATTRIBUTE6
                        ,ATTRIBUTE7
                        ,ATTRIBUTE8
                        ,ATTRIBUTE9
                        ,ATTRIBUTE10
                        ,REFERENCE_NUM
                        ,ATTRIBUTE11
                        ,ATTRIBUTE12
                        ,ATTRIBUTE13
                        ,ATTRIBUTE14
                        ,ATTRIBUTE15
                        ,MIN_RELEASE_AMOUNT
                        ,PRICE_TYPE_LOOKUP_CODE
                        ,CLOSED_CODE
                        ,PRICE_BREAK_LOOKUP_CODE
                        ,GOVERNMENT_CONTEXT
                        ,REQUEST_ID
                        ,PROGRAM_APPLICATION_ID
                        ,PROGRAM_ID
                        ,PROGRAM_UPDATE_DATE
                        ,CLOSED_DATE
                        ,CLOSED_REASON
                        ,CLOSED_BY
                        ,TRANSACTION_REASON_CODE
/*
 * project_id and task_id fields are added to the the insert statement which
 * will enable the Copy Document option in RFQ's form to copy both these
 * fields
 */
                        ,project_id
                        ,task_id
                        ,ORG_ID
                        --togeorge 10/05/2000
                        --added oke columns
                        ,oke_contract_header_id
                        ,oke_contract_version_id
                        ,order_type_lookup_code
                        ,purchase_basis
                        ,matching_basis
                        ,ip_category_id --Bug#5401155
                          )
                select
                x_to_po_line_id
               ,sysdate
               ,who.user_id
               ,x_to_po_header_id
               ,LINE_TYPE_ID
               ,LINE_NUM
               ,LAST_UPDATE_LOGIN
               ,sysdate
               ,who.user_id
               ,ITEM_ID
               ,ITEM_REVISION
               ,CATEGORY_ID
               ,ITEM_DESCRIPTION
               ,UNIT_MEAS_LOOKUP_CODE
               ,QUANTITY_COMMITTED
               ,COMMITTED_AMOUNT
               ,ALLOW_PRICE_OVERRIDE_FLAG
               ,NOT_TO_EXCEED_PRICE
               ,LIST_PRICE_PER_UNIT
               ,nvl(UNIT_PRICE,0)
               ,QUANTITY
               ,UN_NUMBER_ID
               ,HAZARD_CLASS_ID
               ,NOTE_TO_VENDOR
               ,x_from_po_header_id
               ,x_from_po_line_id
               ,MIN_ORDER_QUANTITY
               ,MAX_ORDER_QUANTITY
               ,QTY_RCV_TOLERANCE
               ,OVER_TOLERANCE_ERROR_FLAG
               ,MARKET_PRICE
               ,UNORDERED_FLAG
               ,'N'
               ,'N'
               ,'N'
               ,null
               ,null
               ,null
               ,FIRM_STATUS_LOOKUP_CODE
               ,FIRM_DATE
               ,VENDOR_PRODUCT_NUM
               ,CONTRACT_NUM
               ,TAXABLE_FLAG
               ,decode(x_tax_id,null,TAX_CODE_ID,x_tax_id) /* Bug 1484350 draising */
              -- ,decode (x_new_tax_flag, 'Y', x_tax_id, TAX_CODE_ID)
               ,TYPE_1099
               ,CAPITAL_EXPENSE_FLAG
               ,NEGOTIATED_BY_PREPARER_FLAG
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,ATTRIBUTE10
               ,REFERENCE_NUM
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,MIN_RELEASE_AMOUNT
               ,PRICE_TYPE_LOOKUP_CODE
               ,null
               ,PRICE_BREAK_LOOKUP_CODE
               ,GOVERNMENT_CONTEXT
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,null
               ,TRANSACTION_REASON_CODE
               ,project_id
               ,task_id
               ,ORG_ID
         --togeorge 10/05/2000
         --added oke columns
               ,oke_contract_header_id
               ,oke_contract_version_id
               ,order_type_lookup_code
               ,purchase_basis
               ,matching_basis
               ,l_ip_category_id --Bug#5401155
                from po_lines
                where po_line_id = x_from_po_line_id;

--dbms_output.put_line('progress 006');
IF(x_copy_attachments = 'Y') THEN

x_progress:= '006';

--API to copy attachments from requisition line to po line
fnd_attached_documents2_pkg.
copy_attachments('PO_LINES',
     x_from_po_line_id,
     '',
     '',
     '',
     '',
     'PO_LINES',
     x_to_po_line_id,
     '',
     '',
     '',
     '',
     who.user_id,
     who.login_id,
     '',
     '',
     '');

END             IF;


  -- Bug#5401155
  -- Create the default attributes and translations for the new quotation that is created
  IF(x_new_document_type = 'QUOTATION') THEN
     PO_ATTRIBUTE_VALUES_PVT.create_default_attributes (
       p_doc_type              => x_new_document_type,
       p_po_line_id            => x_to_po_line_id,
       p_req_template_name     => NULL,
       p_req_template_line_num => NULL,
       p_ip_category_id        => l_ip_category_id,
       p_inventory_item_id     => l_item_id,
       p_org_id                => l_org_id,
       p_description           => l_item_description
     );
  END IF;

/* shipments, distributions if necessary */
IF(x_copy_mode IN('SHIPMENT', 'DISTRIBUTION')) THEN

x_progress:= '007';
--dbms_output.put_line('progress 007');

copy_shipments(x_from_po_line_id,
         x_to_po_line_id,
         x_copy_mode,
         x_copy_attachments,
         x_new_document_type,
         x_new_tax_flag,
         x_tax_id);

END             IF;

END             LOOP;

EXCEPTION
WHEN OTHERS THEN
po_message_s.sql_error('COPY LINES', x_progress, sqlcode);
raise;

END             copy_lines;


/*
 * ===========================================================================
 *
 * PROCEDURE NAME:  copy_shipments
 *
 * ===========================================================================
 */

procedure
copy_shipments(x_from_po_line_id IN number,
         x_to_po_line_id IN number,
         x_copy_mode IN varchar2,
         x_copy_attachments IN varchar2,
         x_new_document_type IN varchar2,
         x_new_tax_flag IN varchar2,
         x_tax_id IN ap_tax_codes.tax_id%type) IS

  x_from_po_line_location_id number;
  x_to_po_line_location_id number;
  x_to_po_header_id number;

  CURSOR          shipments_cursor(x_get_po_line_id number) IS
                SELECT line_location_id
                FROM po_line_locations pl
                WHERE pl.po_line_id = x_get_po_line_id
                ORDER BY pl.line_location_id;

BEGIN

x_progress:= '001';
--dbms_output.put_line('progress cs 1');

  OPEN            shipments_cursor(x_from_po_line_id);
--dbms_output.put_line('progress cs 2 ' || x_from_po_line_id);

x_progress:= '002';
LOOP
--dbms_output.put_line('progress cs 2');
  FETCH shipments_cursor INTO x_from_po_line_location_id;
  EXIT WHEN       shipments_cursor % notfound;

--dbms_output.put_line('progress cs 4');
x_progress:= '004';

/* get the new line loc id, and the original po_header_id */
  select          po_line_locations_s.nextval, pol.po_header_id
                  into x_to_po_line_location_id, x_to_po_header_id
                  from po_lines pol
                  where pol.po_line_id = x_to_po_line_id;

x_progress:= '005';
--dbms_output.put_line('progress cs 5' || x_to_po_header_id);

/* Bug 1484350 draising
   Description:  decode statement is changed for tax_code_id.
   the logic is changed so that if there is no tax_code defined for new supplier
   in the quotation tax code from RFQ will be copied.
   otherwise if  tax code is defined for the new supplier it will consider the
   default tax_code of new supplier.
*/

  insert into     po_line_locations(
                            LINE_LOCATION_ID
                           ,LAST_UPDATE_DATE
                           ,LAST_UPDATED_BY
                           ,PO_HEADER_ID
                           ,PO_LINE_ID
                           ,LAST_UPDATE_LOGIN
                           ,CREATION_DATE
                           ,CREATED_BY
                           ,QUANTITY
                           ,QUANTITY_RECEIVED
                           ,QUANTITY_ACCEPTED
                           ,QUANTITY_REJECTED
                           ,QUANTITY_BILLED
                           ,QUANTITY_CANCELLED
                              ,UNIT_MEAS_LOOKUP_CODE
                           ,PO_RELEASE_ID
                           ,SHIP_TO_LOCATION_ID
                         ,SHIP_VIA_LOOKUP_CODE
                           ,NEED_BY_DATE
                           ,PROMISED_DATE
                           ,LAST_ACCEPT_DATE
                           ,PRICE_OVERRIDE
                           ,ENCUMBERED_FLAG
                           ,ENCUMBERED_DATE
                              ,UNENCUMBERED_QUANTITY
                           ,FOB_LOOKUP_CODE
                          ,FREIGHT_TERMS_LOOKUP_CODE
                           ,TAXABLE_FLAG
                           ,TAX_CODE_ID
                         ,ESTIMATED_TAX_AMOUNT
                           ,FROM_HEADER_ID
                           ,FROM_LINE_ID
                              ,FROM_LINE_LOCATION_ID
                           ,START_DATE
                           ,END_DATE
                           ,LEAD_TIME
                           ,LEAD_TIME_UNIT
                           ,PRICE_DISCOUNT
                           ,TERMS_ID
                           ,APPROVED_FLAG
                           ,APPROVED_DATE
                           ,CLOSED_FLAG
                           ,CANCEL_FLAG
                           ,CANCELLED_BY
                           ,CANCEL_DATE
                           ,CANCEL_REASON
                            ,FIRM_STATUS_LOOKUP_CODE
                           ,FIRM_DATE
                           ,ATTRIBUTE_CATEGORY
                           ,ATTRIBUTE1
                           ,ATTRIBUTE2
                           ,ATTRIBUTE3
                           ,ATTRIBUTE4
                           ,ATTRIBUTE5
                           ,ATTRIBUTE6
                           ,ATTRIBUTE7
                           ,ATTRIBUTE8
                           ,ATTRIBUTE9
                           ,ATTRIBUTE10
                              ,UNIT_OF_MEASURE_CLASS
                           ,ENCUMBER_NOW
                           ,ATTRIBUTE11
                           ,ATTRIBUTE12
                           ,ATTRIBUTE13
                           ,ATTRIBUTE14
                           ,ATTRIBUTE15
                           ,INSPECTION_REQUIRED_FLAG
                              ,RECEIPT_REQUIRED_FLAG
                           ,QTY_RCV_TOLERANCE
                             ,QTY_RCV_EXCEPTION_CODE
                            ,ENFORCE_SHIP_TO_LOCATION_CODE
                           ,ALLOW_SUBSTITUTE_RECEIPTS_FLAG
                         ,DAYS_EARLY_RECEIPT_ALLOWED
                          ,DAYS_LATE_RECEIPT_ALLOWED
                        ,RECEIPT_DAYS_EXCEPTION_CODE
                            ,INVOICE_CLOSE_TOLERANCE
                            ,RECEIVE_CLOSE_TOLERANCE
                            ,SHIP_TO_ORGANIZATION_ID
                           ,SHIPMENT_NUM
                           ,SOURCE_SHIPMENT_ID
                           ,SHIPMENT_TYPE
                           ,CLOSED_CODE
                           ,REQUEST_ID
                             ,PROGRAM_APPLICATION_ID
                           ,PROGRAM_ID
                           ,PROGRAM_UPDATE_DATE
                           ,GOVERNMENT_CONTEXT
                         ,RECEIVING_ROUTING_ID
                             ,ACCRUE_ON_RECEIPT_FLAG
                           ,CLOSED_REASON
                           ,CLOSED_DATE
                           ,CLOSED_BY
                           ,ORG_ID,
                     --togeorge 10/05/2000
                     --added note to receiver
                           note_to_receiver
                          ,outsourced_assembly            /*  Bug 6675806. Missing in R12 SHIKYU Transition.*/
                         )
                select
                x_to_po_line_location_id
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,x_to_po_header_id
               ,x_to_po_line_id
               ,who.login_id
               ,sysdate
               ,who.user_id
               ,QUANTITY
               ,0
               ,0
               ,0
               ,0
               ,0
               ,UNIT_MEAS_LOOKUP_CODE
               ,null
               ,SHIP_TO_LOCATION_ID
               ,SHIP_VIA_LOOKUP_CODE
               ,NEED_BY_DATE
               ,PROMISED_DATE
               ,LAST_ACCEPT_DATE
               ,PRICE_OVERRIDE
               ,'N'
               ,null
               ,0
               ,FOB_LOOKUP_CODE
               ,FREIGHT_TERMS_LOOKUP_CODE
               ,TAXABLE_FLAG
             --  ,decode(x_new_tax_flag,'Y',x_tax_id,TAX_CODE_ID)  /* Bug# 1484350 */
               ,decode(x_tax_id,null,TAX_CODE_ID,x_tax_id)
               ,ESTIMATED_TAX_AMOUNT
               ,PO_HEADER_ID
               ,PO_LINE_ID
               ,LINE_LOCATION_ID
               ,START_DATE
               ,END_DATE
               ,LEAD_TIME
               ,LEAD_TIME_UNIT
               ,PRICE_DISCOUNT
               ,TERMS_ID
               ,'N'
               ,null
               ,null
               ,'N'
               ,null
               ,null
               ,null
               ,FIRM_STATUS_LOOKUP_CODE
               ,FIRM_DATE
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,ATTRIBUTE10
               ,UNIT_OF_MEASURE_CLASS
               ,ENCUMBER_NOW
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,INSPECTION_REQUIRED_FLAG
               ,RECEIPT_REQUIRED_FLAG
               ,QTY_RCV_TOLERANCE
               ,QTY_RCV_EXCEPTION_CODE
               ,ENFORCE_SHIP_TO_LOCATION_CODE
               ,ALLOW_SUBSTITUTE_RECEIPTS_FLAG
               ,DAYS_EARLY_RECEIPT_ALLOWED
               ,DAYS_LATE_RECEIPT_ALLOWED
               ,RECEIPT_DAYS_EXCEPTION_CODE
               ,INVOICE_CLOSE_TOLERANCE
               ,RECEIVE_CLOSE_TOLERANCE
               ,SHIP_TO_ORGANIZATION_ID
               ,SHIPMENT_NUM
               ,SOURCE_SHIPMENT_ID
               ,x_new_document_type
               ,'OPEN'
               ,null
               ,null
               ,null
               ,null
               ,GOVERNMENT_CONTEXT
               ,RECEIVING_ROUTING_ID
               ,ACCRUE_ON_RECEIPT_FLAG
               ,null
               ,null
               ,null
               ,ORG_ID,
         --togeorge 10/05/2000
         --added note to receiver
                note_to_receiver
                ,outsourced_assembly            /*  Bug 6675806. Missing in R12 SHIKYU Transition.*/

                from po_line_locations
                where line_location_id = x_from_po_line_location_id;

--dbms_output.put_line('progress cs 006');
IF(x_copy_attachments = 'Y') THEN

x_progress:= '006';

--API to copy attachments from requisition line to po line
fnd_attached_documents2_pkg.
copy_attachments('PO_SHIPMENTS',
     x_from_po_line_location_id,
     '',
     '',
     '',
     '',
     'PO_SHIPMENTS',
     x_to_po_line_location_id,
     '',
     '',
     '',
     '',
     who.user_id,
     who.login_id,
     '',
     '',
     '');

END             IF;

--Distribution copy not yet enabled
--        /* copy distributions if necessary */
-- IF(x_copy_mode IN('SHIPMENT', 'DISTRIBUTION')) THEN
--
-- x_progress:= '007';
--copy_distributions(x_from_po_line_location_id,
         --x_to_po_line_location_id)
--
-- END IF;

  END             LOOP;

EXCEPTION
WHEN OTHERS THEN
po_message_s.sql_error('COPY SHIPMENTS', x_progress, sqlcode);
raise;

  END             copy_shipments;



/*
 * ===========================================================================
 * = Name: copy documents DESC: ARGS: ALGR:
 *
 * ==========================================================================
 */
  PROCEDURE       copy_document(x_po_header_id IN number,
                          x_new_document_type IN varchar2,
                       x_new_document_subtype IN varchar2,
                        x_new_supplier_id IN number,
                         x_new_supplier_site_id IN number,
                      x_new_supplier_contact_id IN number,
                            x_copy_mode IN varchar2,
                           x_copy_attachments IN varchar2,
                           x_new_document_num in varchar2,
                            x_new_po_header_id OUT NOCOPY number,
                       x_actual_document_num IN OUT NOCOPY varchar2) IS

                x_to_po_header_id number;
  x_to_actual_document_num varchar2(25);

BEGIN


x_progress:= '001';
/* copy the header, with the new supplier site) */

who.user_id:= nvl(fnd_global.user_id, 0);
who.login_id:= nvl(fnd_global.login_id, 0);
who.resp_id:= nvl(fnd_global.resp_id, 0);


copy_header(x_po_header_id,
      x_new_document_type,
      x_new_document_subtype,
      x_new_supplier_id,
      x_new_supplier_site_id,
      x_new_supplier_contact_id,
      x_copy_mode,
      x_copy_attachments,
      x_new_document_num,
      x_to_po_header_id,
      x_to_actual_document_num);

/* set the return values for copy_documents */
x_new_po_header_id:= x_to_po_header_id;
x_actual_document_num:= x_to_actual_document_num;

x_progress:= '002';

/* copy lines, shipments, distributions if necessary */
IF(x_copy_mode IN('LINE', 'SHIPMENT', 'DISTRIBUTION')) THEN
x_progress:= '003';
copy_lines(x_po_header_id,
     x_to_po_header_id,
     x_copy_mode,
     x_copy_attachments,
     x_new_document_type,
     x_new_supplier_id,
     x_new_supplier_site_id);
END             IF;

/* commit;    */

EXCEPTION
WHEN OTHERS THEN
po_message_s.sql_error('COPY_DOCUMENTS', x_progress, sqlcode);
raise;
END             copy_document;

END             po_copy_documents_s;

/
