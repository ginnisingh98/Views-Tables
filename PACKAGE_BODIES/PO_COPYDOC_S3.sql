--------------------------------------------------------
--  DDL for Package Body PO_COPYDOC_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COPYDOC_S3" AS
/* $Header: POXCPO3B.pls 120.8.12010000.2 2012/05/17 11:28:53 ssindhe ship $*/

-- <INVCONV R12>
g_chktype_TRACKING_QTY_IND CONSTANT
   MTL_SYSTEM_ITEMS_B.TRACKING_QUANTITY_IND%TYPE := 'PS';

-- Private function prototypes

PROCEDURE validate_line_type_id(
  x_line_type_id        IN OUT NOCOPY  po_lines.line_type_id%TYPE,
  x_wip_install_status  IN      VARCHAR2,
  x_online_report_id    IN      po_online_report_text.online_report_id%TYPE,
  x_sequence            IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num            IN      po_online_report_text.line_num%TYPE,
  x_return_code         OUT NOCOPY     NUMBER
);

PROCEDURE validate_trx_reason_code(
  x_transaction_reason_code  IN OUT NOCOPY  po_lines.transaction_reason_code%TYPE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_return_code              OUT NOCOPY     NUMBER
);
-- End of Private function prototypes

PROCEDURE validate_line_type_id(
  x_line_type_id        IN OUT NOCOPY  po_lines.line_type_id%TYPE,
  x_wip_install_status  IN      VARCHAR2,
  x_online_report_id    IN      po_online_report_text.online_report_id%TYPE,
  x_sequence            IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num            IN      po_online_report_text.line_num%TYPE,
  x_return_code         OUT NOCOPY     NUMBER
) IS

  x_progress    VARCHAR2(4);
  x_valid_flag  VARCHAR2(2);

BEGIN

  x_progress := '001';
  SELECT distinct 'Y'
  INTO   x_valid_flag
  FROM   PO_LINE_TYPES
  WHERE  line_type_id = x_line_type_id
  AND    SYSDATE < nvl(inactive_date, SYSDATE+1)
  AND    ((nvl(outside_operation_flag,'N') = 'Y' AND x_wip_install_status = 'I')
          OR (nvl(outside_operation_flag, 'N') <> 'Y'));

  x_return_code := 0;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_line_type_id := NULL;
    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                'Invalid Line type',
                                x_line_num, 0, 0);
    x_return_code := -1;
  WHEN OTHERS THEN
    x_line_type_id := NULL;
    po_copydoc_s1.copydoc_sql_error('validate_line_type_id', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, 0, 0);
    x_return_code := -1;
END validate_line_type_id;



PROCEDURE validate_trx_reason_code(
  x_transaction_reason_code  IN OUT NOCOPY  po_lines.transaction_reason_code%TYPE,
  x_online_report_id         IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                 IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num                 IN      po_online_report_text.line_num%TYPE,
  x_return_code              OUT NOCOPY     NUMBER
) IS

  x_progress    VARCHAR2(4);
  x_valid_flag  VARCHAR2(2);

BEGIN

  IF (x_transaction_reason_code IS NULL) THEN
    x_return_code := 0;
    RETURN;
  END IF;


  SELECT distinct 'Y'
  INTO   x_valid_flag
  FROM   PO_LOOKUP_CODES
  WHERE  lookup_type = 'TRANSACTION REASON'
  AND    lookup_code = x_transaction_reason_code
  AND    SYSDATE < nvl(inactive_date, SYSDATE+1);

  x_return_code := 0;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_transaction_reason_code := NULL;
    po_copydoc_s1.online_report(x_online_report_id,
                                x_sequence,
                                'Invalid Transaction reason code',
                                x_line_num, 0, 0);
    x_return_code := 0;
  WHEN OTHERS THEN
    x_transaction_reason_code := NULL;
    po_copydoc_s1.copydoc_sql_error('validate_trx_reason_code', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_line_num, 0, 0);
    x_return_code := -1;
END validate_trx_reason_code;

/*************************************************************
 ** Initialize date info
 ** Nullify some attributes which will be inserted from other places
 ** Validate for correct line_type_id (may not need it ?)
 ** Validate individual item on line
 ** Validate transaction reason code
 ** Get next po_line_id
*************************************************************/
PROCEDURE validate_line(
  x_action_code         IN      VARCHAR2,
  x_to_doc_subtype      IN      po_headers.type_lookup_code%TYPE,
  x_po_line_record      IN OUT NOCOPY  po_lines%ROWTYPE,
  x_orig_po_line_id     IN      po_lines.po_line_id%TYPE,
  x_wip_install_status  IN      VARCHAR2,
  x_sob_id              IN      financials_system_parameters.set_of_books_id%TYPE,
  x_inv_org_id          IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_po_header_id        IN      po_lines.po_header_id%TYPE,
  x_online_report_id    IN      po_online_report_text.online_report_id%TYPE,
  x_sequence            IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_copy_price          IN      BOOLEAN,
  x_return_code         OUT NOCOPY     NUMBER,
  p_is_complex_work_po  IN      BOOLEAN    -- <Complex Work R12>
) IS

  COPYDOC_LINE_FAILURE    EXCEPTION;
  x_progress              VARCHAR2(4) := NULL;
  x_internal_return_code  NUMBER := NULL;
  x_quotation_class_code  VARCHAR2(10) := NULL;
  x_orig_po_header_id     po_lines.po_header_id%TYPE := NULL;
  x_qty                   po_lines.quantity%type := NULL;
  x_blanket_price         po_lines.unit_price%type := NULL;
  x_order_type_lookup_code po_line_types.order_type_lookup_code%type;
-- start of 1548597
  x_secondary_qty         po_lines.secondary_quantity%type := NULL;
  x_item_number           VARCHAR2(240);
  x_process_org           VARCHAR2(1);
  x_dummy     VARCHAR2(240);
  x_product   VARCHAR2(3) := 'GMI';
  x_opm_installed    VARCHAR2(1);
  x_retvar    BOOLEAN;
  ic_item_mst_rec IC_ITEM_MST%ROWTYPE;
  ic_item_cpg_rec IC_ITEM_CPG%ROWTYPE;
  x_order_opm_um          ic_item_mst.item_um%type := NULL;
 -- end of 1548597

  x_quote_type  po_headers.type_lookup_code%type;
  x_quote_sub_type  po_headers.quote_type_lookup_code%type;
  --<INVCONV R12 START>
  x_secondary_unit_fsp		MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE;
  x_secondary_uom_fsp		MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
  x_secondary_quantity_fsp	po_lines.quantity%type;
  --<INVCONV R12 END>

BEGIN

  po_copydoc_s1.copydoc_debug('validate_line()');

  /******  Unchanged Attributes
  note_to_vendor
  qty_rcv_tolerance
  hazard_class_id
  note_to_vendor
  over_tolerance_error_flag
  unordered_flag
  vendor_product_num
  taxable_flag
  tax_code_id
  type_1099 (what is this?)
  attribute{1-15}
  qc_grade (what is this?)
  base_{uom, qty}
  secondary_{uom, qty}
  line_type_id
  line_num
  item_{id, revision, description}
  category_id
  unit_meas_lookup_code
  unit_price
  un_number_id
  global_attribute{category, _1-20}
  line_reference_num
  project_id (?)
  task_id (?)
  ******/

  /* store original info */
  -- bug877084: don't need to override in po_lines

  SELECT po_header_id
  INTO   x_orig_po_header_id
  FROM   po_lines
  WHERE  po_line_id = x_orig_po_line_id;

 /* 1780903 : When a bid quotation is copied to a standard or planned PO
    we need to copy the quote reference to the PO . For this we copy the
    from header and from line from the quote to the PO */

   select quote_type_lookup_code,
          type_lookup_code
   into x_quote_sub_type,
        x_quote_type
   from po_headers
   where po_header_id = x_orig_po_header_id;

  --For Bug 13580685
  --Allowing copy doc feature to copy the the quotation
  --to the document created.
 if x_quote_type = 'QUOTATION' and x_quote_sub_type IN ('BID','CATALOG','STANDARD')
    and x_to_doc_subtype in ('STANDARD','PLANNED','BLANKET') then
   x_po_line_record.from_header_id := x_orig_po_header_id;
   x_po_line_record.from_line_id := x_orig_po_line_id;
 end if;


  IF (x_action_code in ('QUOTATION','RFQ')) THEN
/* It's the same for Blanket, Planned, or Standard PO */
      SELECT quotation_class_code
      INTO   x_quotation_class_code
      FROM   po_headers
      WHERE  po_header_id = x_orig_po_header_id;

      IF (x_quotation_class_code = 'CATALOG') THEN

         x_po_line_record.min_order_quantity := NULL;
         x_po_line_record.max_order_quantity := NULL;
         x_po_line_record.min_release_amount := NULL;
         x_po_line_record.price_type_lookup_code := NULL;
         x_po_line_record.market_price := NULL;
         x_po_line_record.firm_status_lookup_code := 'N';
         x_po_line_record.firm_date           := NULL;
         x_po_line_record.contract_num        := NULL;
         x_po_line_record.capital_expense_flag := 'N';

         -- bug3610606
         -- We no longer set negotiated_by_preparer_flag to 'N' when
         -- copying from catalog quotation
         -- x_po_line_record.negotiated_by_preparer_flag := 'N';

         x_po_line_record.quantity_committed := NULL;
         x_po_line_record.committed_amount   := NULL;
         x_po_line_record.allow_price_override_flag := 'N';
         x_po_line_record.quantity           := NULL;
      END IF;
  END IF;

/*  Functionality for PA->RFQ Copy : dreddy
    line related fields are processed */
  IF (x_action_code = 'RFQ') THEN
     -- based on the value of copy_price ,the price from
     -- the blanket is either copied or left blank.
     begin
      SELECT unit_price
      INTO   x_blanket_price
      FROM   po_lines
      WHERE  po_header_id = x_orig_po_header_id
      AND    po_line_id = x_orig_po_line_id;
     exception
      when others then
       x_blanket_price := null;
     end;

     --Bug# 1567872
     --togeorge 01/19/2001
     --Select the order type and if it is 'AMOUNT' copy the price even
     --if x_copy_price is 'FALSE'. Amount based line should always have a price 1.
     x_progress := '001';
     begin
      SELECT order_type_lookup_code
      INTO   x_order_type_lookup_code
      FROM   po_line_types
      WHERE  line_type_id = x_po_line_record.line_type_id;
     exception
      when others then
       po_copydoc_s1.copydoc_sql_error('validate_line', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_po_line_record.line_num, 0, 0);
       x_return_code := -1;
     end;
     --
       if(x_copy_price) then
           x_po_line_record.unit_price := x_blanket_price;
       else
       --Bug# 1567872
       --togeorge 01/19/2001
       --Select the order type and if it is 'AMOUNT' copy the price even
       --if x_copy_price is 'FALSE'. Amount based line should always have a price 1.
        if x_order_type_lookup_code = 'AMOUNT' then
	   x_po_line_record.unit_price := x_blanket_price; --which would be 1.
        else
          x_po_line_record.unit_price := NULL;
	end if;
        --x_po_line_record.unit_price := NULL;
       --
       end if;
  END IF;

  -- Bug 2694883. Copy the po line expiration date over from the original.

  -- We now use the expiration date as the assignment end date for std PO's for
  -- service lines
  -- so if the to document is std PO we null out the value otherwise copy over.

    IF (x_to_doc_subtype = 'STANDARD') THEN             -- SERVICES FPJ
       x_po_line_record.expiration_date   := NULL;
    END IF;

  -- SERVICES FPJ Start
  -- Also for service lines we need to null out other contractor specific fields
  x_po_line_record.contractor_first_name := NULL;
  x_po_line_record.contractor_last_name  := NULL;

  -- As start date is mandatory we need to default it with some value.
  -- We will be defaulting sysdate.
  IF (x_to_doc_subtype = 'STANDARD') AND
     x_po_line_record.start_date is not null THEN

     x_po_line_record.start_date     := trunc(sysdate); -- Bug 3266584

  END IF;

  -- SERVICES FPJ End

  x_po_line_record.last_updated_by   := fnd_global.user_id;
  x_po_line_record.last_update_date  := SYSDATE;
  x_po_line_record.last_update_login := fnd_global.login_id;
  x_po_line_record.created_by        := fnd_global.user_id;
  x_po_line_record.creation_date     := SYSDATE;

  -- Standard WHO columns, not inserted
  x_po_line_record.program_application_id := NULL;
  x_po_line_record.program_id             := NULL;
  x_po_line_record.program_update_date    := NULL;
  x_po_line_record.request_id             := NULL;

  validate_trx_reason_code(x_po_line_record.transaction_reason_code,
                           x_online_report_id,
                           x_sequence,
                           x_po_line_record.line_num,
                           x_internal_return_code);
  IF (x_internal_return_code < 0) THEN
    RAISE COPYDOC_LINE_FAILURE;
  END IF;

  x_po_line_record.closed_by     := NULL;
  x_po_line_record.closed_code   := NULL;
  x_po_line_record.closed_date   := NULL;
  x_po_line_record.closed_flag   := 'N';
  x_po_line_record.closed_reason := NULL;

  x_po_line_record.cancelled_by  := NULL;
  x_po_line_record.cancel_date   := NULL;
  x_po_line_record.cancel_flag   := 'N';
  x_po_line_record.cancel_reason := NULL;

  -- PO DBI FPJ ** Start
  -- For Blanket, Standard and Planned the negotiated_by_preparer_flag should be
  -- 'Y' at the time of copying quotation document.

  -- Bug 3602147: x_quote_sub_type should be either STANDARD or CATALOG
  -- bug3610606: x_quote_sub_type can be 'BID' as well.

  IF x_to_doc_subtype IN ('BLANKET', 'STANDARD', 'PLANNED')
    AND x_quote_sub_type IN ('STANDARD', 'CATALOG', 'BID') THEN
	--AND x_quote_sub_type NOT IN ('BLANKET', 'STANDARD', 'PLANNED') THEN

    x_po_line_record.negotiated_by_preparer_flag := 'Y';

  END IF;
  -- PO DBI FPJ ** End


  -- Should be obselete
  x_po_line_record.user_hold_flag := NULL;

  /* bug 969442: when a po is cancelled the quantity on a line is modified.
     so when copying from it the original quantity is not copied onto the po_line.
     To fix this, the sum of the quantities from the shipment lines is copied
     to the new po instead.and also the note to vendor field is nulled because
     it is specific to a PO and also for a cancelled po case it contains the
     reason for cancel. */
  /* bug 1056086 : but when adding the shipment lines,we should not add the
     release shipments . also if its a blanket PO copy null into the qty field
     as quantity does not make sense for a blanket */

    IF (x_to_doc_subtype = 'BLANKET') THEN

      x_qty := NULL;
      x_secondary_qty := NULL;  --Bug 1548597

    ELSIF (x_po_line_record.order_type_lookup_code in ('QUANTITY','AMOUNT'))
    THEN

      --<Complex Work R12 START>
      IF (p_is_complex_work_po) THEN
        --For the Quantity Milestone case, do not sum the line location
        --quantities.
        x_qty := x_po_line_record.quantity;
        x_secondary_qty := NULL;
      ELSE
        -- Bug# 3842550 START
        -- If line has no shipments resulting in null values for the sum of
        -- quantities and secondary quantities of shipments, set them back to
        -- their original values.
        -- Note: The following issue has been resolved by this bug fix.
        /* If Common Receiving is not installed the above sum of
           secondary_Quantity will return a null. so we need to override it */

        select nvl(sum(poll.quantity), x_po_line_record.quantity)
        into   x_qty
        from   po_line_locations poll
        where  poll.po_line_id = x_po_line_record.po_line_id
        and    poll.po_release_id is null
        and    poll.payment_type <> 'PREPAYMENT';  -- <Complex Work R12>

      END IF; --If Complex Work PO
      --<Complex Work R12 END>

    END IF; --If Blanket or if Qty-based PO line

  --<INVCONV R12 START>
  IF x_po_line_record.quantity <> x_qty THEN
      X_po_line_record.secondary_quantity := NULL ;
      X_po_line_record.secondary_unit_of_measure := NULL ;
  END IF;
  x_po_line_record.quantity := x_qty;

   -- calculate secondary quantity and UOM based on FSP org
   -- <Complex Work R12>: Null out secondary qty/uom for complex work POs
   IF ((NOT p_is_complex_work_po) AND
          (x_to_doc_subtype in ('STANDARD','PLANNED','BLANKET'))) THEN
       IF x_po_line_record.item_id is not null THEN
           PO_UOM_S.get_secondary_uom( x_po_line_record.item_id,
                                       x_inv_org_id,
                                       X_secondary_uom_fsp,
                                       X_secondary_unit_fsp);

     	   IF X_secondary_unit_fsp IS NOT NULL AND x_to_doc_subtype <> 'BLANKET' THEN
              PO_UOM_S.uom_convert (x_po_line_record.quantity,x_po_line_record.unit_meas_lookup_code,
                  x_po_line_record.item_id, x_secondary_unit_fsp, x_secondary_quantity_fsp) ;
           END IF;
           X_po_line_record.secondary_quantity := x_secondary_quantity_fsp ;
           X_po_line_record.secondary_unit_of_measure := x_secondary_unit_fsp ;
    	ELSE
	   X_po_line_record.secondary_quantity := NULL ;
           X_po_line_record.secondary_unit_of_measure := NULL ;
        END IF;
   ELSE
          X_po_line_record.secondary_quantity := NULL ;
          X_po_line_record.secondary_unit_of_measure := NULL ;
   END IF;

  --<INVCONV R12 END>

/* Bug# 1523449  draising
  While using 'Copy Document' functionality from
  Quotation to PO  below line was nullifying the note_to_vendor field
  in copied PO form. It shouldn't happen while copying from Quotation
  to PO.Addded if condition that when x_action_code is 'QUOTATION' then
  it will not nullify the note_to_vendor field  */

IF (x_action_code <> 'QUOTATION') THEN
  x_po_line_record.note_to_vendor := NULL;
END IF;

  x_po_line_record.po_header_id := x_po_header_id;

  x_progress := '001';
  BEGIN
    SELECT po_lines_s.nextval
    INTO   x_po_line_record.po_line_id
    FROM   SYS.DUAL;
  EXCEPTION
    WHEN OTHERS THEN
      x_po_line_record.po_line_id := NULL;
      po_copydoc_s1.copydoc_sql_error('validate_line', x_progress, sqlcode,
                                      x_online_report_id,
                                      x_sequence,
                                      x_po_line_record.line_num, 0, 0);
      RAISE COPYDOC_LINE_FAILURE;
  END;

    -- Global Agreements (FP-I): Do not copy over Cumulative Price field.
    --
    IF ( PO_GA_PVT.is_global_agreement( x_po_line_record.po_header_id ) ) THEN
	x_po_line_record.price_break_lookup_code := NULL;
    END IF;

    x_return_code := 0;
    po_copydoc_s1.copydoc_debug('End: validate_line()');

EXCEPTION
  WHEN COPYDOC_LINE_FAILURE THEN
    x_return_code := -1;
  WHEN OTHERS THEN
    po_copydoc_s1.copydoc_sql_error('validate_line', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    x_po_line_record.line_num, 0, 0);
    x_return_code := -1;
END validate_line;


END po_copydoc_s3;


/
