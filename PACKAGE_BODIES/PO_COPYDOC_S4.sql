--------------------------------------------------------
--  DDL for Package Body PO_COPYDOC_S4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COPYDOC_S4" AS
/* $Header: POXCPO4B.pls 120.5.12010000.3 2010/03/18 08:25:30 ppadilam ship $*/

--< Shared Proc FPJ Start >
-- Debugging booleans used to bypass logging when turned off
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

g_pkg_name CONSTANT VARCHAR2(20) := 'PO_COPYDOC_S4';
g_module_prefix CONSTANT VARCHAR2(30) := 'po.plsql.' || g_pkg_name || '.';


PROCEDURE validate_shipment
(
    p_action_code           IN     VARCHAR2,
    p_to_doc_subtype        IN     VARCHAR2,
    p_orig_line_location_id IN     NUMBER,
    p_po_header_id          IN     NUMBER,
    p_po_line_id            IN     NUMBER,
    p_item_category_id      IN     NUMBER,      --< Shared Proc FPJ >
    p_inv_org_id            IN     NUMBER,      -- Bug 2761415
    p_copy_price            IN     BOOLEAN,
    p_online_report_id      IN     NUMBER,
    p_line_num              IN     NUMBER,
    p_item_id               IN     NUMBER, -- Bug 3433867
    x_po_shipment_record    IN OUT NOCOPY PO_LINE_LOCATIONS%ROWTYPE,
    x_sequence              IN OUT NOCOPY NUMBER,
    x_return_code           OUT    NOCOPY NUMBER,
    p_is_complex_work_po    IN     BOOLEAN     -- <Complex Work R12>
) IS

  COPYDOC_SHIPMENT_FAILURE    EXCEPTION;
  l_progress                  VARCHAR2(4) := NULL;
  l_internal_return_code      NUMBER := NULL;
  l_quotation_class_code      VARCHAR2(10) := NULL;
  l_orig_po_header_id         po_line_locations.po_header_id%TYPE := NULL;
  l_orig_po_line_id           po_line_locations.po_line_id%TYPE := NULL;
  l_vendor_id                 NUMBER := NULL;
  l_vendor_site_id            NUMBER := NULL;
  l_invoice_match_option      VARCHAR2(25) := NULL;
  l_price_from_line           po_lines.unit_price%TYPE := NULL;
  l_terms_id                  NUMBER := NULL;
  l_ship_via_lookup_code      VARCHAR2(25) := NULL;
  l_fob                       VARCHAR2(25) := NULL;
  l_freight_terms             VARCHAR2(25) := NULL;
  l_qty_tolerance             NUMBER := NULL;
  l_qty_exception_code        VARCHAR2(25) := NULL;
  l_rcv_flag                  VARCHAR2(1) := NULL;
  l_insp_flag                 VARCHAR2(1) := NULL;
  -- start of 1548597
  l_secondary_qty             po_lines.secondary_quantity%type := NULL;
  l_item_number               VARCHAR2(240);
  l_process_org               VARCHAR2(1);
  l_ic_item_mst_rec           IC_ITEM_MST%ROWTYPE;
  l_ic_item_cpg_rec           IC_ITEM_CPG%ROWTYPE;
  l_order_opm_um              ic_item_mst.item_um%type := NULL;
-- end of 1548597

-- Bug: 2473335
  l_line_type_id                 number:= null;
  l_invoice_close_tolerance      number:= null;
  l_receive_close_tolerance      number:= null;
  l_item_id po_lines.item_id%TYPE := null;

  --< Shared Proc FPJ Start >
  l_transaction_flow_header_id
    PO_LINE_LOCATIONS_ALL.transaction_flow_header_id%TYPE;
  l_is_valid BOOLEAN;
  l_in_current_sob BOOLEAN;
  l_check_txn_flow BOOLEAN;
  l_return_status  VARCHAR2(1);
  --< Shared Proc FPJ End >

BEGIN

  /*****  Unchanged attributes
  government_context
  receiving_routing_id
  org_id
  attribute{1-15, _category}
  unit_of_measure_class
  enforce_ship_to_location_code (set to 'NONE' for quote and po, but where can this field be set)
  allow_substitute_receipts_flag (where is this set)
  days_{early, late}_receipt_allowed (where is this set)
  {invoice, receive}_close_tolerance
  ship_to_organization_id
  shipment_num
  source_shipment_id
  last_accept_date
  price_override (this is the price indicated in the price breaks)
  estimated_tax_amount
  price_discount
  firm_status_lookup_code
  firm_date
  quantity
  unit_meas_lookup_code
  ship_to_location_id
  global_attribute{_category, 1-20}
  enforce_ship_to_location_code
  ********************/
   l_progress := '001';

  IF g_debug_stmt THEN               --< Shared Proc FPJ > Add correct debugging
      PO_DEBUG.debug_stmt
          (p_log_head => g_module_prefix||'validate_shipment',
           p_token    => 'invoked',
           p_message  => 'action_code: '||p_action_code||' to_doc_subtype: '||
                   p_to_doc_subtype||' header ID: '||p_po_header_id||
                   ' line ID: '||p_po_line_id||' ship ID: '||
                   x_po_shipment_record.line_location_id||
                   ' online_report ID: '||p_online_report_id);
  END IF;

  /* store original document info into the "FROM" fields of current doc */
  -- bug877084: don't need to override in po_line_locations

  SELECT po_header_id, po_line_id
  INTO   l_orig_po_header_id, l_orig_po_line_id
  FROM   po_line_locations
  WHERE  line_location_id = p_orig_line_location_id;

  -- Bug 2761415 START
  -- Moved bug fix 2473335 here, since invoice/receipt close tolerance
  -- defaulting should only happen when copying from quotations and RFQ's.
  IF (x_po_shipment_record.shipment_type IN ('QUOTATION', 'RFQ')) THEN

    -- Bug 2473335 start: Get the invoice close tolerance and
    -- receive close tolerance
    select line_type_id, item_id
           into l_line_type_id, l_item_id
    from   po_lines
    where  po_line_id=p_po_line_id; -- Bug 2761415

    begin
          SELECT msi.invoice_close_tolerance,
                 msi.receive_close_tolerance
            INTO l_invoice_close_tolerance,
                 l_receive_close_tolerance
            FROM mtl_system_items msi
           WHERE msi.inventory_item_id = l_item_id
             AND msi.organization_id   = x_po_shipment_record.ship_to_organization_id;
    exception
          when others then null;
    end;
    begin
          SELECT nvl(l_invoice_close_tolerance,msi.invoice_close_tolerance),
                 nvl(l_receive_close_tolerance,msi.receive_close_tolerance)
            INTO l_invoice_close_tolerance,
                 l_receive_close_tolerance
            FROM mtl_system_items msi
           WHERE msi.inventory_item_id = l_item_id
             AND msi.organization_id = p_inv_org_id;
    exception
          when others then null;
    end;

    begin
          SELECT nvl(l_receive_close_tolerance,receipt_close)
            INTO l_receive_close_tolerance
            FROM po_line_types_v
           WHERE line_type_id = l_line_type_id;
    exception
          when others then null;
    end;

    begin
          SELECT nvl(l_invoice_close_tolerance, posp.INVOICE_CLOSE_TOLERANCE),
                 nvl(l_receive_close_tolerance, posp.RECEIVE_CLOSE_TOLERANCE)
            INTO l_invoice_close_tolerance,
                 l_receive_close_tolerance
            FROM po_system_parameters posp;
    exception
        when others then null;
    end;

    IF (l_invoice_close_tolerance is NULL) THEN
            l_invoice_close_tolerance := 0;
    END IF;

    IF (l_receive_close_tolerance is NULL) THEN
            l_receive_close_tolerance := 0;
    END IF;

    -- Bug 2473335 End

    x_po_shipment_record.invoice_close_tolerance := l_invoice_close_tolerance;
    x_po_shipment_record.receive_close_tolerance := l_receive_close_tolerance;
  END IF; -- from shipment type is quotation or RFQ
  -- Bug 2761415 END

   l_progress := '002';
  IF (p_action_code = 'QUOTATION') THEN
    SELECT quotation_class_code,
           vendor_site_id,
           vendor_id
    INTO   l_quotation_class_code,
           l_vendor_site_id,
           l_vendor_id
    FROM   po_headers
    WHERE  po_header_id = l_orig_po_header_id;

    /* a copied PO needs to have a defaulted value for the invoice match
     * option.  we look at the vendor site, vendor, and the financials
     * system parameters.
     */

    /*Bug 9336785: Get the match_option value from the supplier site if its null
    then get the value from the supplier set up if it is null then get the value
    from the payables set up*/

    IF (l_vendor_site_id is NOT NULL) THEN
       l_progress := '003';
      SELECT match_option
      INTO   l_invoice_match_option
      FROM   po_vendor_sites
      WHERE  vendor_site_id = l_vendor_site_id;
    END IF;

    IF (l_invoice_match_option is NULL) THEN
     IF (l_vendor_id is NOT NULL) THEN
        l_progress := '004';
        SELECT match_option
        INTO   l_invoice_match_option
        FROM   po_vendors
        WHERE  vendor_id = l_vendor_id;
     END IF;
    END IF;

    IF (l_invoice_match_option is NULL) THEN
       l_progress := '005';
      SELECT match_option
      INTO   l_invoice_match_option
      FROM   financials_system_parameters;
    END IF;


    IF (l_quotation_class_code = 'CATALOG') THEN
      x_po_shipment_record.inspection_required_flag := NULL;
      x_po_shipment_record.receipt_required_flag := NULL;
      x_po_shipment_record.qty_rcv_tolerance := NULL;
      x_po_shipment_record.qty_rcv_exception_code := NULL;
      x_po_shipment_record.shipment_type := 'PRICE BREAK';
    ELSIF (l_quotation_class_code = 'BID') THEN
      -- Bug 2761415 The following is now defaulted in the logic above.
      --x_po_shipment_record.invoice_close_tolerance := NULL;
      --x_po_shipment_record.receive_close_tolerance := NULL;

      /* depend on the type of PO, sets to the same */
      x_po_shipment_record.shipment_type := p_to_doc_subtype;
      -- bug896729:  bid quotation has only last_accept_date. convert
      -- this to promised_date
      x_po_shipment_record.promised_date := x_po_shipment_record.last_accept_date;
      x_po_shipment_record.last_accept_date := NULL;
      x_po_shipment_record.match_option := l_invoice_match_option;
--bug#2754766: only NULL out pb effective dates for Bid Quotations
      x_po_shipment_record.start_date := NULL;
      x_po_shipment_record.end_date := NULL;

      -- Bug 2750604. Copy these over at shipment level for bid quotations to
      -- be consistent with GA FPI changes
      IF (p_to_doc_subtype IN ('STANDARD', 'PLANNED')) THEN
        x_po_shipment_record.from_header_id := l_orig_po_header_id;
        x_po_shipment_record.from_line_id   := l_orig_po_line_id;
      END IF;

    END IF;

    l_progress := '006';
    x_po_shipment_record.accrue_on_receipt_flag := 'N';
    x_po_shipment_record.encumber_now  := NULL;
    x_po_shipment_record.fob_lookup_code := NULL;
    x_po_shipment_record.freight_terms_lookup_code := NULL;
--bug#2754766: removed statement nulling out pb start/end dates.
--moved this up into the if block for Bid Quotations only.
    x_po_shipment_record.lead_time := NULL;
    x_po_shipment_record.lead_time_unit := NULL;
    x_po_shipment_record.terms_id := NULL;
    x_po_shipment_record.ship_via_lookup_code := NULL;

  END IF;

   /*  Functionality for PA->RFQ Copy : dreddy 1388111
    shipment related fields are processed */
   IF (p_action_code = 'RFQ') THEN
    -- payment terms are defaulted from the header
    begin

      SELECT terms_id,
             ship_via_lookup_code,
             fob_lookup_code,
             freight_terms_lookup_code
      INTO   l_terms_id,
             l_ship_via_lookup_code,
             l_fob,
             l_freight_terms
      FROM   po_headers
      WHERE  po_header_id = l_orig_po_header_id ;

    exception
      when others then
       null;
    end;

    -- quantity tolerence and exception code are defaulted from the system level.
     begin

      SELECT rcv.qty_rcv_tolerance,
             rcv.qty_rcv_exception_code
      INTO   l_qty_tolerance,
             l_qty_exception_code
      FROM   rcv_parameters rcv,
             financials_system_parameters fsp
      WHERE  rcv.organization_id  = fsp.inventory_organization_id;

    exception
      when others then
       null;
    end;

     -- match option is defaulted from the system level based on the receiving
     -- and inspection flags
     begin

      SELECT receiving_flag,
             inspection_required_flag
      INTO   l_rcv_flag,
             l_insp_flag
      FROM   po_system_parameters;

    exception
      when others then
       null;
    end;


    x_po_shipment_record.inspection_required_flag := NULL;
    x_po_shipment_record.receipt_required_flag := NULL;
    x_po_shipment_record.qty_rcv_tolerance := l_qty_tolerance;
    x_po_shipment_record.qty_rcv_exception_code := l_qty_exception_code;
    x_po_shipment_record.shipment_type := 'RFQ';
    x_po_shipment_record.accrue_on_receipt_flag := 'N';
    x_po_shipment_record.encumber_now  := NULL;
    x_po_shipment_record.fob_lookup_code := l_fob;
    x_po_shipment_record.freight_terms_lookup_code := l_freight_terms;
    /* Bug 2695110.
     * Comment out the following code which makes start_date and
     * end_date to be null since we need to copy them over to RFQ.
    x_po_shipment_record.start_date := NULL;
    x_po_shipment_record.end_date := NULL;
    */
    x_po_shipment_record.lead_time := NULL;
    x_po_shipment_record.lead_time_unit := NULL;
    x_po_shipment_record.terms_id := l_terms_id;
    x_po_shipment_record.ship_via_lookup_code := l_ship_via_lookup_code;
    x_po_shipment_record.receipt_required_flag := l_rcv_flag;
    x_po_shipment_record.inspection_required_flag := l_insp_flag;

    if not (p_copy_price) then
      x_po_shipment_record.price_override := NULL;
      x_po_shipment_record.price_discount := NULL;
    end if;

  END IF;

  x_po_shipment_record.last_updated_by   := fnd_global.user_id;
  x_po_shipment_record.last_update_date  := SYSDATE;
  x_po_shipment_record.last_update_login := fnd_global.login_id;
  x_po_shipment_record.created_by        := fnd_global.user_id;
  x_po_shipment_record.creation_date     := SYSDATE;

  l_progress := '007';
  -- if promised_date or need_by_date has already passed, set to sysdate
  if (x_po_shipment_record.promised_date is not null) and
     (x_po_shipment_record.promised_date < SYSDATE) then
    --< NBD TZ/Timestamp FPJ Start >
    --x_po_shipment_record.promised_date := trunc(SYSDATE);
    x_po_shipment_record.promised_date := SYSDATE;
    --< NBD TZ/Timestamp FPJ End >
  end if;

  l_progress := '008';
  if (x_po_shipment_record.need_by_date is not null) and
     (x_po_shipment_record.need_by_date < SYSDATE) then
    --< NBD TZ/Timestamp FPJ Start >
    --x_po_shipment_record.need_by_date := trunc(SYSDATE);
    x_po_shipment_record.need_by_date := SYSDATE;
    --< NBD TZ/Timestamp FPJ End >
  end if;

  -- in bid quotation, last_accept_date and need_by_date are not mandatory
  -- fields.  However in PO, they are. so default trunc(sysdate) if both
  -- fields are null.
  l_progress := '009';

  /*Bug6851594 - Commented the following lines as this was setting the NEED-BY-DATE
    to SYSDATE even when the there was no DATE populated for NEED-BY-DATE in original document*/

/* Bug: 2825147 Populate need_by_date only for STANDARD and
   PLANNED Purchase Orders */

 /* if (x_po_shipment_record.need_by_date is null) and
	(x_po_shipment_record.promised_date is null) and
          (x_po_shipment_record.shipment_type in ('STANDARD','PLANNED'))then
    --< NBD TZ/Timestamp FPJ Start >
    --x_po_shipment_record.need_by_date := trunc(SYSDATE);
    x_po_shipment_record.need_by_date := SYSDATE;
    --< NBD TZ/Timestamp FPJ End >
  end if; */

  --
  -- <R12 eTax Integration>
  -- Removed reference to ap ta(x) code table
  --
  x_po_shipment_record.tax_code_id := NULL;

  /* bug 1346241 : for standard and planned PO's the shipment price
     should be same as the line price
     this should not be done for a copy to RFQ  */
     -- <Complex Work R12>: For complex work POs also, do not get
     -- the price from the line.  It is on the payitem itself.
   IF ((NOT p_is_complex_work_po) AND (p_action_code <> 'RFQ')) THEN
    IF x_po_shipment_record.price_override is null
      OR (p_to_doc_subtype in ('STANDARD','PLANNED')) THEN

       l_progress := '011';
     begin
       select unit_price
       into l_price_from_line
       from po_lines
       where po_header_id = p_po_header_id
       and po_line_id = p_po_line_id;
     exception
      when others then
       null;
     end;

     x_po_shipment_record.price_override := l_price_from_line;

    END IF;
   END IF;


    l_progress := '012';
  -- Standard WHO columns, not inserted
  x_po_shipment_record.program_application_id := NULL;
  x_po_shipment_record.program_id             := NULL;
  x_po_shipment_record.program_update_date    := NULL;
  x_po_shipment_record.request_id             := NULL;

  x_po_shipment_record.cancelled_by  := NULL;
  x_po_shipment_record.cancel_date   := NULL;
  x_po_shipment_record.cancel_flag   := 'N';
  x_po_shipment_record.cancel_reason := NULL;
  x_po_shipment_record.closed_by     := NULL;
  x_po_shipment_record.closed_code   := 'OPEN';
  x_po_shipment_record.closed_date   := NULL;
  x_po_shipment_record.closed_flag   := NULL;
  x_po_shipment_record.closed_reason := NULL;

  x_po_shipment_record.approved_date := NULL;
  x_po_shipment_record.approved_flag := 'N';

  x_po_shipment_record.po_release_id := NULL;

  x_po_shipment_record.po_header_id := p_po_header_id;
  x_po_shipment_record.po_line_id   := p_po_line_id;

  x_po_shipment_record.unencumbered_quantity := NULL;
  x_po_shipment_record.encumbered_date       := NULL;
  x_po_shipment_record.encumbered_flag       := 'N';
  x_po_shipment_record.quantity_accepted  := 0;
  x_po_shipment_record.quantity_billed    := 0;
  x_po_shipment_record.quantity_cancelled := 0;
  x_po_shipment_record.quantity_received  := 0;
  x_po_shipment_record.quantity_rejected  := 0;
  x_po_shipment_record.quantity_shipped   := NULL;

  l_progress := '013';

  --< Shared Proc FPJ Start >
  IF (p_to_doc_subtype = 'STANDARD') AND
     (NVL(x_po_shipment_record.consigned_flag,'N') = 'N') AND
     (NVL(x_po_shipment_record.accrue_on_receipt_flag, 'N') = 'Y') --<Shared Proc FPJ>
  THEN

      l_progress := '014';

      -- Validate the ship-to org, and derive a transaction flow
      PO_SHARED_PROC_PVT.validate_ship_to_org
          (p_init_msg_list    => FND_API.g_false,
           x_return_status    => l_return_status,
           p_ship_to_org_id   => x_po_shipment_record.ship_to_organization_id,
           p_item_category_id => p_item_category_id,
           p_item_id          => p_item_id, -- Bug 3433867
           x_is_valid         => l_is_valid,
           x_in_current_sob   => l_in_current_sob,
           x_check_txn_flow   => l_check_txn_flow,
           x_transaction_flow_header_id => l_transaction_flow_header_id);

      IF (l_return_status <> FND_API.g_ret_sts_success) THEN
          l_progress := '015';
          FND_MESSAGE.set_encoded(encoded_message => FND_MSG_PUB.get);
          RAISE FND_API.g_exc_error;
      ELSIF (NOT l_is_valid) AND (NOT l_check_txn_flow) THEN
          l_progress := '016';
          -- This is an error because it is not allowable to use transaction
          -- flows in this scenario, and validation failed.
          FND_MESSAGE.set_name(application => 'PO',
                               name => 'PO_INVALID_SHIP_TO_ORG');
          RAISE FND_API.g_exc_error;
      END IF;

      l_progress := '017';

      IF (l_transaction_flow_header_id IS NOT NULL) THEN

          -- A valid transaction flow was found, so set it here. If the new
          -- flow is different than the original, new accounts will be
          -- generated at the distributions level
          x_po_shipment_record.transaction_flow_header_id :=
              l_transaction_flow_header_id;

      ELSIF (x_po_shipment_record.transaction_flow_header_id IS NOT NULL)
      THEN
          l_progress := '018';

          -- Original PO had a txn flow, but no valid txn flow found now.
          -- Only clear orig txn flow reference if the ship-to org is in the
          -- current OU's SOB. Otherwise, just let it go so that it gets
          -- caught downstream in the copydoc submission check.

          IF l_in_current_sob THEN
              -- Remove txn flow reference, which will force new accounts
              -- to be generated at the distribution level
              x_po_shipment_record.transaction_flow_header_id := NULL;
          END IF;

      END IF;  --< if txn flow header not null >

  END IF;  --< if STANDARD >
  --< Shared Proc FPJ End >

  l_progress := '019';
  BEGIN
    SELECT po_line_locations_s.nextval
    INTO   x_po_shipment_record.line_location_id
    FROM   SYS.DUAL;
  EXCEPTION
    WHEN OTHERS THEN
      x_po_shipment_record.line_location_id := NULL;
      po_copydoc_s1.copydoc_sql_error('validate_shipment', l_progress, sqlcode,
                                      p_online_report_id,
                                      x_sequence,
                                      p_line_num, x_po_shipment_record.shipment_num, 0);
      RAISE COPYDOC_SHIPMENT_FAILURE;
  END;

  x_return_code := 0;
  IF g_debug_stmt THEN               --< Shared Proc FPJ > Add correct debugging
      PO_DEBUG.debug_end
          (p_log_head => g_module_prefix||'validate_shipment');
  END IF;

EXCEPTION
  WHEN COPYDOC_SHIPMENT_FAILURE THEN
    x_return_code := -1;
    IF g_debug_stmt THEN             --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'validate_shipment',
             p_token    => l_progress,
             p_message  => 'COPYDOC_SHIPMENT_FAILURE exception caught.');
    END IF;
  --< Shared Proc FPJ Start >
  WHEN FND_API.g_exc_error THEN
    PO_COPYDOC_S1.online_report
        (x_online_report_id => p_online_report_id,
         x_sequence         => x_sequence,
         x_message          => FND_MESSAGE.get,
         x_line_num         => p_line_num,
         x_shipment_num     => x_po_shipment_record.shipment_num,
         x_distribution_num => 0);
    x_return_code := -1;
    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
            (p_log_head => g_module_prefix||'validate_shipment',
             p_token    => l_progress,
             p_message  => 'FND_API.g_exc_error caught.');
    END IF;
  --< Shared Proc FPJ End >
  WHEN OTHERS THEN
    po_copydoc_s1.copydoc_sql_error('validate_shipment', l_progress, sqlcode,
                                    p_online_report_id,
                                    x_sequence,
                                    p_line_num, x_po_shipment_record.shipment_num, 0);
    x_return_code := -1;
    IF g_debug_unexp THEN            --< Shared Proc FPJ > Add correct debugging
        PO_DEBUG.debug_exc
            (p_log_head => g_module_prefix||'validate_shipment',
             p_progress => l_progress);
    END IF;
END validate_shipment;
--< Shared Proc FPJ End >

END po_copydoc_s4;

/
