--------------------------------------------------------
--  DDL for Package Body PO_INVOICES_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_INVOICES_SV2" AS
/* $Header: POXIVRPB.pls 120.26.12010000.23 2014/08/13 14:49:03 gke ship $*/

-- Read the profile option that enables/disables the debug log
-- g_asn_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_RVCTP_ENABLE_TRACE'),'N');
g_asn_debug VARCHAR2(1) := asn_debug.is_debug_on;  -- Bug 9152790: rcv debug enhancement

create_invoice_error          EXCEPTION; --SBI


/* <PAY ON USE FPI START> */
    g_fetch_size CONSTANT NUMBER := 1000;
    g_pkg_name   CONSTANT VARCHAR2(20) := 'PO_INVOICES_SV2';

    /* For caching values */
    g_old_tax_code_id AP_TAX_CODES.tax_id%TYPE := NULL;
/* <PAY ON USE FPI END> */


/* =================================================================
   FUNCTION NAME:    get_ship_to_location_id(p_trx_id,p_entity_code)
   p_po_line_location_id = po line location id for which we require the ship to
                           location.
   Bug: 5125624
==================================================================*/

FUNCTION get_ship_to_location_id (p_po_line_location_id IN NUMBER)
        RETURN PO_LINE_LOCATIONS.SHIP_TO_LOCATION_ID%TYPE IS
     l_ship_to_location_id PO_LINE_LOCATIONS.SHIP_TO_LOCATION_ID%TYPE;
BEGIN

    SELECT
    	ship_to_location_id INTO l_ship_to_location_id
    FROM
    	po_line_locations_all
    WHERE
    	line_location_id = p_po_line_location_id;
     IF (g_asn_debug = 'Y') THEN
       asn_debug.put_line('po_line_location_id = ' || p_po_line_location_id || ' has ship to location id  = ' || l_ship_to_location_id);
     END IF;
     RETURN l_ship_to_location_id;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('po_line_location_id = ' || p_po_line_location_id || ' has no ship to location id');
     END IF;
        RETURN NULL;
     WHEN OTHERS THEN
     IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('po_line_location_id = ' || p_po_line_location_id || ' has some problem. This is not acceptable.');
     END IF;
     RETURN NULL;

END  get_ship_to_location_id;

/* =================================================================

   FUNCTION NAME:    get_tax_classification_code(p_trx_id,p_entity_code)
   p_trx_id   = Is the id that is present in the zx tables. In case of
                PO it is the po_header_id
   p_trx_line_id = is the line location id of the PO.
   entity_code= zx tables stores the trx_id and the entity code to avoid
                multiple records with same trx_id. In case we are passing
                po_header_id then the entity_code would be 'PURCHASE ORDER'

   Bug: 5125624
==================================================================*/

FUNCTION get_tax_classification_code (p_trx_id IN NUMBER,
                                      p_trx_line_id IN NUMBER,
                                      p_entity_code IN VARCHAR)
        RETURN VARCHAR2 IS
     l_tax_classification_code zx_lines_det_factors.input_tax_classification_code%TYPE;
BEGIN

    SELECT
    	input_tax_classification_code INTO l_tax_classification_code
    FROM
    	zx_lines_det_factors
    WHERE
          trx_id      = p_trx_id
    	AND trx_line_id = p_trx_line_id
    	AND entity_code = p_entity_code;
     IF (g_asn_debug = 'Y') THEN
       asn_debug.put_line(p_entity_code || '=' || p_trx_id || ' has a tax classification code = ' || l_tax_classification_code);
     END IF;
     RETURN l_tax_classification_code;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line(p_entity_code || '=' || p_trx_id || ' has no tax classification code');
     END IF;
     RETURN NULL;
     WHEN OTHERS THEN
     IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line(p_entity_code || '=' || p_trx_id || ' has some problem. This is not acceptable.');
     END IF;
     RETURN NULL;
END  get_tax_classification_code;


/* =================================================================

   FUNCTION NAME:    create_receipt_invoices()

==================================================================*/
FUNCTION  create_receipt_invoices(X_commit_interval       IN NUMBER,
              X_rcv_shipment_header_id  IN NUMBER,
              X_receipt_event     IN VARCHAR2,
                 X_aging_period      IN NUMBER DEFAULT NULL,
              X_include_timecard_correct  IN  VARCHAR2 DEFAULT NULL)--Bug 17972946
                     RETURN BOOLEAN

 IS

X_progress      VARCHAR2(3)  := NULL;


/* Cursor bind var for aging period */

X_profile       VARCHAR2(20) := NULL;

l_aging_period  NUMBER := NULL;

/* Actual quauntity for the invoice */

X_received_quantity NUMBER := 0;
X_received_amount NUMBER := 0;

/*Bug# 1539257 */
X_tmp_batch_id  NUMBER;
X_batch_name    ap_batches.batch_name%TYPE;


/* Bug:396027. gtummala. 10/17/96
 * Now the cursor picks up previously REJECTED transactions as well
 * as PENDING ones
 */

/* Bug:551612. gtummala. 11/02/97
 * Now we will only pick up those trnxs where rts.invoice_status_code is
 * 'PENDING' or 'REJECTED'. We won't pick up where it is null.
 * The enter receipts form will only set this to 'PENDING' if the
 * supplier site is set up for pay on receipt.
 */

/* Bug 1930776. We need to pick up pay_on_receipt_summary_code from the
 * purchasing site even if it is defined in the alternate pay site.
*/

/***** Cursor declaration ****/
/* R12 Complex Work.
 * Added plls.shipment_type so that we create separate invoices
 * for Prepayment shipments. For other valid shipments like
 * Standard and Blanket continue as is and can be grouped
 * in one invoice.
*/

 /* Bug 5388926 : Changed order by clause in both cursors.
 **    Ordering by shipment_header_id first to prevent multiple invoices
 **    being generated.
 */

/* Bug#6649580
 *  As part of bug#5443196 fix to improve the performance of 'Pay on Receipt'
 *  concurrent request, index RCV_TRANSACTIONS_N16 was changed to function based
 *  index (SOURCE_DOCUMENT_CODE, NVL(INVOICE_STATUS_CODE,'NA'),TRANSACTION_TYPE).
 *  But in the following cursor C_receipt_txns, there is no nvl on
 *  rts.invoice_status_code and this index is not effectively used and results in
 *  performance issue.
 *  So, added nvl on rts.invoice_status_code. This nvl condition is available
 *  in 1159 bug#4732594 fix.
 */

CURSOR C_receipt_txns IS
SELECT   /*+ INDEX (rts RCV_TRANSACTIONS_N16) */
   rts.rowid                      rcv_txn_rowid,
   rts.transaction_id,
   rts.po_header_id,
   rts.po_release_id,
   rts.po_line_id,
   rts.po_line_location_id,
   rts.po_distribution_id,
   rsh.vendor_id,
   pvds.segment1                  vendor_num,
   NVL(pvss.default_pay_site_id,pvss.vendor_site_id) default_pay_site_id,
   pvss2.vendor_site_code         pay_site_code,
   pvss.pay_on_receipt_summary_code,  -- default pay site's summary code
   rts.shipment_header_id,
/* Bug 3065403 - Taking rsl.packing slip if rsh.packing slip is null.
   Also changed the alias packing_slip to pack_slip to avoid ambiguous
  column error in the order by clause.*/
   NVL(rsh.packing_slip, nvl(rsl.packing_slip,rsh.receipt_num)) pack_slip,
   rsh.receipt_num,
   rts.shipment_line_id,
   trunc(rts.transaction_date) txn_date,  --Bug 10168386
   rts.transaction_date,
   rts.amount,
   rts.quantity,
   /* PoR with LCM project Begin */
   -- rts.lcm_shipment_line_id, -- 19409660
   --nvl(plls.price_override, pls.unit_price) po_unit_price, /* Bug: 4409887 */
   decode(rts.lcm_shipment_line_id,null,nvl(plls.price_override, pls.unit_price),isl.txn_unit_price) po_unit_price, /* Bug: 4409887 */
   /* PoR with LCM project End */
   rts.currency_code,
   /* PoR with LCM project Begin */
   --rts.currency_conversion_type,
   decode(rts.lcm_shipment_line_id,null,rts.currency_conversion_type,isl.currency_conversion_type) currency_conversion_type,
/* Note that we must decode currency type because the receiving programs put in
   a 1 for the currency rate if base currency is same as PO.  Purchasing and
   Payables expects that the rate be null if base currency=PO/Invoice currency. */
   --decode (rts.currency_conversion_type,null,null,rts.currency_conversion_rate) currency_conversion_rate,
   --rts.currency_conversion_date,
   decode(rts.lcm_shipment_line_id,null, decode(rts.currency_conversion_type,null,null,rts.currency_conversion_rate), decode(isl.currency_conversion_type,null,null,isl.currency_conversion_rate)) currency_conversion_rate,
   decode(rts.lcm_shipment_line_id,null,rts.currency_conversion_date,isl.currency_conversion_date) currency_conversion_date,
   /* PoR with LCM project End */
   NVL(NVL(plls.terms_id, phs.terms_id) , pvss2.terms_id) payment_terms_id,
   DECODE(plls.taxable_flag, 'Y', plls.tax_code_id, NULL) tax_code_id,
   nvl(plls.description, pls.item_description) item_description,--bug7658186
   plls.matching_basis,
   decode(sign(rts.amount),-1, 'DEBIT',decode(plls.shipment_type,'PREPAYMENT','PREPAYMENT','STANDARD')) shipment_type, --bug 17972946
   NVL(rsl.osa_flag,'N') osa_flag, --Shikyu project
   plls.match_option, -- 5100177
   rts.unit_of_measure, -- 5100177
   plls.unit_meas_lookup_code, -- 5100177
   rts.lcm_shipment_line_id, -- 19409660
   rts.timecard_id  --bug 17972946
FROM  po_vendor_sites   pvss,
   po_vendor_sites      pvss2,
   po_vendors     pvds,
   --Bugfix 5407632 - Using _all tables instead of views.
   po_headers_all     phs,
-- po_releases_all             prs, /*Bug 5443196*/
   po_lines_all    pls,
   po_line_locations_all plls,
   rcv_shipment_headers    rsh,
   rcv_shipment_lines      rsl,
   inl_ship_lines_all  isl, -- PoR with LCM project
   rcv_transactions  rts
WHERE rts.shipment_header_id = rsh.shipment_header_id
AND   rts.po_header_id = phs.po_header_id
--AND   rts.po_release_id = prs.po_release_id(+) /*Bug 5443196*/
AND   rts.po_line_location_id = plls.line_location_id
AND   rts.po_line_id = pls.po_line_id
AND   rts.shipment_header_id = rsl.shipment_header_id
AND   rts.shipment_line_id = rsl.shipment_line_id
/* PoR with LCM project Begin */
AND   rts.lcm_shipment_line_id = isl.ship_line_id (+)
AND   rts.lcm_adjustment_num = isl.adjustment_num (+)
/* PoR with LCM project End */
AND   phs.vendor_id =  pvds.vendor_id
AND   phs.vendor_site_id = pvss.vendor_site_id
AND   phs.pcard_id is null
AND   rsh.receipt_source_code = 'VENDOR'
AND   rts.source_document_code = 'PO'
AND   nvl(rts.invoice_status_code,'NA')  IN ('PENDING','REJECTED') /*Bug:551612 */ --Bug#6649580
--bug 17972946 begin
--AND   rts.transaction_type =  X_receipt_event
AND   ((rts.transaction_type = X_receipt_event)
         OR (X_include_timecard_correct = 'Y'
              AND rts.transaction_type = 'CORRECT'
              AND rts.timecard_id is not null
              AND exists(select 1
                           from rcv_transactions prt
                          where prt.transaction_type = 'RECEIVE'
                            and prt.SOURCE_DOCUMENT_CODE = 'PO'
                            and prt.transaction_id = rts.parent_transaction_id
                            and prt.invoice_status_code ='INVOICED'
                            and prt.last_update_date <= rts.creation_date)))
--bug 17972946 end
/* <PAY ON USE FPI START> */
AND   pvss.pay_on_code IN ('RECEIPT', 'RECEIPT_AND_USE')
AND   PHS.PAY_ON_CODE  IN ('RECEIPT', 'RECEIPT_AND_USE') /*Bug 5443196*/
/*AND     decode(nvl(rts.po_release_id, -999), -999, phs.pay_on_code,
               prs.pay_on_code) IN ('RECEIPT', 'RECEIPT_AND_USE')*/
AND     NVL(plls.consigned_flag,'N') <> 'Y'
/* <PAY ON USE FPI END> */
AND   pvss2.vendor_site_id = NVL(pvss.default_pay_site_id,pvss.vendor_site_id)
AND     nvl(rsh.asn_type, ' ') <> 'ASBN'
AND   rts.transaction_date <= sysdate - l_aging_period
AND   rts.po_release_id IS null -- Bug 5443196
/* PoR with LCM project
AND   nvl(plls.lcm_flag, 'N') = 'N' -- Bug 7758359: Added this condition so that LCM Receipts are not picked up.
*/
UNION
SELECT   /*+ INDEX (rts RCV_TRANSACTIONS_N16) */
   rts.rowid                      rcv_txn_rowid,
   rts.transaction_id,
   rts.po_header_id,
   rts.po_release_id,
   rts.po_line_id,
   rts.po_line_location_id,
   rts.po_distribution_id,
   rsh.vendor_id,
   pvds.segment1                  vendor_num,
   NVL(pvss.default_pay_site_id,pvss.vendor_site_id) default_pay_site_id,
   pvss2.vendor_site_code         pay_site_code,
   pvss.pay_on_receipt_summary_code,  -- default pay site's summary code
   rts.shipment_header_id,
/* Bug 3065403 - Taking rsl.packing slip if rsh.packing slip is null.
   Also changed the alias packing_slip to pack_slip to avoid ambiguous
  column error in the order by clause.*/
   NVL(rsh.packing_slip, nvl(rsl.packing_slip,rsh.receipt_num)) pack_slip,
   rsh.receipt_num,
   rts.shipment_line_id,
   trunc(rts.transaction_date) txn_date,  --Bug 10168386
   rts.transaction_date,
   rts.amount,
   rts.quantity,
   /* PoR with LCM project Begin */
   -- rts.lcm_shipment_line_id, -- 19409660
   --nvl(plls.price_override, pls.unit_price) po_unit_price, /* Bug: 4409887 */
   decode(rts.lcm_shipment_line_id,null,nvl(plls.price_override, pls.unit_price),isl.txn_unit_price) po_unit_price, /* Bug: 4409887 */
   /* PoR with LCM project End */
   rts.currency_code,
   /* PoR with LCM project Begin */
   --rts.currency_conversion_type,
   decode(rts.lcm_shipment_line_id,null,rts.currency_conversion_type,isl.currency_conversion_type) currency_conversion_type,
/* Note that we must decode currency type because the receiving programs put in
   a 1 for the currency rate if base currency is same as PO.  Purchasing and
   Payables expects that the rate be null if base currency=PO/Invoice currency. */
   --decode (rts.currency_conversion_type,null,null,rts.currency_conversion_rate) currency_conversion_rate,
   --rts.currency_conversion_date,
   decode(rts.lcm_shipment_line_id,null, decode(rts.currency_conversion_type,null,null,rts.currency_conversion_rate), decode(isl.currency_conversion_type,null,null,isl.currency_conversion_rate)) currency_conversion_rate,
   decode(rts.lcm_shipment_line_id,null,rts.currency_conversion_date,isl.currency_conversion_date) currency_conversion_date,
   /* PoR with LCM project End */
   NVL(NVL(plls.terms_id, phs.terms_id) , pvss2.terms_id) payment_terms_id,
   DECODE(plls.taxable_flag, 'Y', plls.tax_code_id, NULL) tax_code_id,
   nvl(plls.description, pls.item_description) item_description,--bug7658186
   plls.matching_basis,
   decode(sign(rts.amount),-1, 'DEBIT',decode(plls.shipment_type,'PREPAYMENT','PREPAYMENT','STANDARD')) shipment_type, --bug 17972946
   NVL(rsl.osa_flag,'N') osa_flag, --Shikyu project
   plls.match_option, -- 5100177
   rts.unit_of_measure, -- 5100177
   plls.unit_meas_lookup_code, -- 5100177
   rts.lcm_shipment_line_id, -- 19409660
   rts.timecard_id  --bug 17972946
FROM  po_vendor_sites   pvss,
   po_vendor_sites      pvss2,
   po_vendors     pvds,
   --Bugfix 5407632 - Using _all tables instead of views.
   po_headers_all     phs,
   po_releases_all             prs,
   po_lines_all    pls,
   po_line_locations_all plls,
   rcv_shipment_headers    rsh,
   rcv_shipment_lines      rsl,
   inl_ship_lines_all isl, -- PoR with LCM project
   rcv_transactions  rts
WHERE rts.shipment_header_id = rsh.shipment_header_id
AND   rts.po_header_id = phs.po_header_id
AND   rts.po_release_id = prs.po_release_id
AND   rts.po_line_location_id = plls.line_location_id
AND   rts.po_line_id = pls.po_line_id
AND   rts.shipment_header_id = rsl.shipment_header_id
AND   rts.shipment_line_id = rsl.shipment_line_id
/* PoR with LCM project Begin */
AND   rts.lcm_shipment_line_id = isl.ship_line_id (+)
AND   rts.lcm_adjustment_num = isl.adjustment_num (+)
/* PoR with LCM project End */
AND   phs.vendor_id =  pvds.vendor_id
AND   phs.vendor_site_id = pvss.vendor_site_id
AND   phs.pcard_id is null
AND   rsh.receipt_source_code = 'VENDOR'
AND   rts.source_document_code = 'PO'
AND   nvl(rts.invoice_status_code,'NA')  IN ('PENDING','REJECTED') /*Bug:551612 */ --Bug#6649580
--bug 17972946 begin
--AND   rts.transaction_type =  X_receipt_event
AND   ((rts.transaction_type = X_receipt_event)
         OR (X_include_timecard_correct = 'Y'
              AND rts.transaction_type = 'CORRECT'
              AND rts.timecard_id is not null
              AND exists(select 1
                           from rcv_transactions prt
                          where prt.transaction_type = 'RECEIVE'
                            and prt.SOURCE_DOCUMENT_CODE = 'PO'
                            and prt.transaction_id = rts.parent_transaction_id
                            and prt.invoice_status_code ='INVOICED'
                            and prt.last_update_date <= rts.creation_date)))
--bug 17972946 end
/* <PAY ON USE FPI START> */
AND   pvss.pay_on_code IN ('RECEIPT', 'RECEIPT_AND_USE')
AND   PRS.PAY_ON_CODE  IN ('RECEIPT', 'RECEIPT_AND_USE') /*Bug 5443196*/
/*AND     decode(nvl(rts.po_release_id, -999), -999, phs.pay_on_code,
               prs.pay_on_code) IN ('RECEIPT', 'RECEIPT_AND_USE')*/
AND     NVL(plls.consigned_flag,'N') <> 'Y'
/* <PAY ON USE FPI END> */
AND   pvss2.vendor_site_id = NVL(pvss.default_pay_site_id,pvss.vendor_site_id)
AND     nvl(rsh.asn_type, ' ') <> 'ASBN'
AND   rts.transaction_date <= sysdate - l_aging_period
/* PoR with LCM project
AND   nvl(plls.lcm_flag, 'N') = 'N' -- Bug 7758359: Added this condition so that LCM Receipts are not picked up.
*/
ORDER BY 8,10,22,26,17,14,30,13,31; --Bug 5443196*/--Bug 10168386

/* Bug 6822389 Changed the sorting order, brought back rsh.shipment_header_id to its earlier place */

--Bug 5443196: Commented the following as order by is replaced by the column numbers
/*ORDER BY phs.vendor_id,
      NVL(pvss.default_pay_site_id,pvss.vendor_site_id),
      rts.currency_code,
      payment_terms_id,
      trunc(rts.transaction_date), --Bug 10168386
      pack_slip,
      decode(plls.shipment_type,'PREPAYMENT','PREPAYMENT','STANDARD'),
      rsh.shipment_header_id,
      rsl.osa_flag; --Shikyu project*/

/* R12 Complex Work.
 * Added plls.shipment_type so that we create separate invoices
 * for Prepayment shipments. For other valid shipments like
 * Standard and Blanket continue as is and can be grouped
 * in one invoice.
*/
/***** Cursor declaration ****/
CURSOR C_receipt_txns2 IS
SELECT   rts.rowid                      rcv_txn_rowid,
   rts.transaction_id,
   rts.po_header_id,
        rts.po_release_id,
   rts.po_line_id,
   rts.po_line_location_id,
   rts.po_distribution_id,
   rsh.vendor_id,
   pvds.segment1                  vendor_num,
   NVL(pvss.default_pay_site_id,pvss.vendor_site_id) default_pay_site_id,
   pvss2.vendor_site_code         pay_site_code,
   pvss.pay_on_receipt_summary_code,  -- default pay site's summary code
   rts.shipment_header_id,
/* Bug 3065403 - Taking rsl.packing slip if rsh.packing slip is null.
   Also changed the alias packing_slip to pack_slip to avoid ambiguous
   column error in the order by clause*/
   NVL(rsh.packing_slip,nvl(rsl.packing_slip, rsh.receipt_num)) pack_slip,
   rsh.receipt_num,
   rts.shipment_line_id,
   trunc(rts.transaction_date) txn_date,  --Bug 10168386
   rts.transaction_date,
   rts.amount,
   rts.quantity,
   /* PoR with LCM project Begin */
   -- rts.lcm_shipment_line_id, -- 19409660
   -- nvl(plls.price_override, pls.unit_price) po_unit_price, /* Bug4409887 */
   decode(rts.lcm_shipment_line_id,null,nvl(plls.price_override, pls.unit_price),isl.txn_unit_price) po_unit_price, /* Bug: 4409887 */
   /* PoR with LCM project End */
   rts.currency_code,
   /* PoR with LCM project Begin */
   --rts.currency_conversion_type,
   decode(rts.lcm_shipment_line_id,null,rts.currency_conversion_type,isl.currency_conversion_type) currency_conversion_type,
/* Note that we must decode currency type because the receiving programs put in
   a 1 for the currency rate if base currency is same as PO.  Purchasing and
   Payables expects that the rate be null if base currency=PO/Invoice currency. */
   --decode (rts.currency_conversion_type,null,null,rts.currency_conversion_rate) currency_conversion_rate,
   --rts.currency_conversion_date,
   decode(rts.lcm_shipment_line_id,null, decode(rts.currency_conversion_type,null,null,rts.currency_conversion_rate), decode(isl.currency_conversion_type,null,null,isl.currency_conversion_rate)) currency_conversion_rate,
   decode(rts.lcm_shipment_line_id,null,rts.currency_conversion_date,isl.currency_conversion_date) currency_conversion_date,
   /* PoR with LCM project End */
   NVL(NVL(plls.terms_id, phs.terms_id) , pvss2.terms_id) payment_terms_id,
   DECODE(plls.taxable_flag, 'Y', plls.tax_code_id, NULL) tax_code_id,
   nvl(plls.description, pls.item_description) item_description,--bug7658186
   plls.matching_basis,
   decode(sign(rts.amount),-1, 'DEBIT',decode(plls.shipment_type,'PREPAYMENT','PREPAYMENT','STANDARD')) shipment_type, --bug 17972946
   rsl.osa_flag, --Shikyu project
   plls.match_option, -- 5100177
   rts.unit_of_measure, -- 5100177
   plls.unit_meas_lookup_code, -- 5100177
   rts.lcm_shipment_line_id, -- 19409660
   rts.timecard_id  --bug 17972946
FROM  po_vendor_sites   pvss,
   po_vendor_sites      pvss2,
   po_vendors     pvds,
   po_headers     phs,
        po_releases             prs,
   po_lines    pls,
   po_line_locations plls,
   rcv_shipment_headers    rsh,
        rcv_shipment_lines      rsl,
   inl_ship_lines_all isl, -- PoR with LCM project
   rcv_transactions  rts
WHERE rts.shipment_header_id = rsh.shipment_header_id
AND   rts.po_header_id = phs.po_header_id
AND     rts.po_release_id = prs.po_release_id(+)
AND   rts.po_line_location_id = plls.line_location_id
AND   rts.po_line_id = pls.po_line_id
AND     rts.shipment_header_id = rsl.shipment_header_id
AND     rts.shipment_line_id = rsl.shipment_line_id
/* PoR with LCM project Begin */
AND   rts.lcm_shipment_line_id = isl.ship_line_id (+)
AND   rts.lcm_adjustment_num = isl.adjustment_num (+)
/* PoR with LCM project End */
AND   phs.vendor_id =  pvds.vendor_id
AND   phs.vendor_site_id = pvss.vendor_site_id
AND     phs.pcard_id is null
AND   rsh.receipt_source_code = 'VENDOR'
AND   rts.source_document_code = 'PO'
AND     rts.invoice_status_code  IN ('PENDING','REJECTED') /*Bug:551612 */
--bug 17972946 begin
--AND   rts.transaction_type =  X_receipt_event
AND   ((rts.transaction_type = X_receipt_event)
         OR (X_include_timecard_correct = 'Y'
              AND rts.transaction_type = 'CORRECT'
              AND rts.timecard_id is not null
              AND exists(select 1
                           from rcv_transactions prt
                          where prt.transaction_type = 'RECEIVE'
                            and prt.SOURCE_DOCUMENT_CODE = 'PO'
                            and prt.transaction_id = rts.parent_transaction_id
                            and prt.invoice_status_code ='INVOICED'
                            and prt.last_update_date <= rts.creation_date)))
--bug 17972946 end
/* <PAY ON USE FPI START> */
AND   pvss.pay_on_code IN ('RECEIPT', 'RECEIPT_AND_USE')
AND     decode(nvl(rts.po_release_id, -999), -999, phs.pay_on_code,
               prs.pay_on_code) IN ('RECEIPT', 'RECEIPT_AND_USE')
AND     NVL(plls.consigned_flag, 'N') <> 'Y'
/* <PAY ON USE FPI END> */
AND   pvss2.vendor_site_id = NVL(pvss.default_pay_site_id,pvss.vendor_site_id)
AND   rsh.shipment_header_id = X_rcv_shipment_header_id
AND     nvl(rsh.asn_type, ' ') <> 'ASBN'
AND     rts.transaction_date <= sysdate - l_aging_period
/* PoR with LCM project
AND   nvl(plls.lcm_flag, 'N') = 'N' -- Bug 7758359: Added this condition so that LCM Receipts are not picked up.
*/
ORDER BY
      phs.vendor_id,
      NVL(pvss.default_pay_site_id,pvss.vendor_site_id),
      rts.currency_code,
      payment_terms_id,
      txn_date,  --Bug 10168386
      pack_slip,
      decode(sign(rts.amount),-1, 'DEBIT',decode(plls.shipment_type,'PREPAYMENT','PREPAYMENT','STANDARD')), --bug 17972946
      rsh.shipment_header_id,  --Bug 6822389
      rsl.osa_flag; --Shikyu project


X_rcv_txns     c_receipt_txns%ROWTYPE;
X_terms_date      DATE;
X_invoice_count      NUMBER;   /** num of invoices created in this run ***/
X_invoice_running_total NUMBER;  /** running total of invoice amount for
               invoices created */
X_first_rcv_txn_flag VARCHAR2(1);

X_curr_inv_process_flag VARCHAR2(1) := 'Y';
   /*** flag used to indicate whether the current invoice is processable,
   i.e. indicate whether any application error has occurred during the
   process of the invoice. If error occurs, this flag will be 'N'.
   ***/
X_completion_status     BOOLEAN := TRUE;
   /*** This flag will be set to FALSE if at least one error occurred
   during the run of this API. ***/

/*** The following set of curr_ variables are used to keep track of the
     current values used to determine if a new invoice has to be created ***/
X_curr_invoice_amount      NUMBER := 0;
X_curr_invoice_id    NUMBER := NULL;
X_curr_invoice_num      ap_invoices.invoice_num%TYPE;

X_curr_vendor_id     NUMBER := NULL;
X_curr_pay_site_id      NUMBER := NULL;
X_curr_currency_code    rcv_transactions.currency_code%TYPE := NULL;
X_curr_payment_terms_id         NUMBER := NULL;
X_curr_transaction_date    DATE := NULL;
X_curr_le_transaction_date DATE := NULL; --LE time zone date (Bug: 5205516)
X_curr_packing_slip     rcv_shipment_headers.receipt_num%TYPE := NULL;
X_curr_shipment_header_id  NUMBER := NULL;
X_curr_osa_flag                 VARCHAR2(1) := NULL; --Shikyu project

X_curr_conversion_rate_type   rcv_transactions.currency_conversion_type%TYPE;
X_curr_conversion_rate_date   DATE;
X_curr_conversion_rate     NUMBER;

/** Bug# 1176326 **/
X_curr_conversion_rate_date1  DATE;
X_curr_conversion_rate1    NUMBER;
X_def_base_currency_code        ap_system_parameters.base_currency_code%TYPE;

X_curr_accounting_date     DATE;
X_curr_period_name      gl_periods.period_name%TYPE;
/**   Bug 586895      **/
X_curr_method_code         IBY_PAYMENT_METHODS_VL.PAYMENT_METHOD_CODE%TYPE;

/*    Bug 612979      **/
X_curr_pay_curr_code       po_vendor_sites.payment_currency_code%TYPE;
X_ap_pay_curr              po_vendor_sites.payment_currency_code%TYPE;

   /*** vendor, vendor-pay-site related varibles ***/

X_pay_group_lookup_code         po_vendors.pay_group_lookup_code%TYPE;
X_payment_method_lookup_code  IBY_PAYMENT_METHODS_VL.PAYMENT_METHOD_CODE%TYPE;
X_payment_priority      po_vendors.payment_priority%TYPE;
X_terms_date_basis      po_vendors.terms_date_basis%TYPE;
X_vendor_income_tax_region po_vendor_sites.state%TYPE;
X_type_1099       po_vendors.type_1099%TYPE;
X_awt_flag        po_Vendor_sites.allow_awt_flag%TYPE;
X_awt_group_id       po_vendor_sites.awt_group_id%TYPE;
X_exclude_freight_from_disc   po_vendor_sites.exclude_freight_from_discount%TYPE;
X_unit_meas_lookup_code varchar2(25);

/*  BUG 612979 */

X_payment_currency_code         po_vendor_sites.payment_currency_code%TYPE := NULL;
X_pay_cross_rate                NUMBER;

X_batch_id        NUMBER;
X_discountable_amount      NUMBER;
X_inv_event                     VARCHAR2(26);
X_invoice_description   ap_invoices.description%TYPE;
l_user_id         NUMBER;
v_req_id       NUMBER;

/** this is the group id we insert into the
    AP interface table to identify out batch **/

X_group_id        VARCHAR2(80);
x_dist_count         NUMBER;

/* Fix for bug 2943056.
   Commenting the fix done in 2379414 at all places of the code.
*/

x_org_id                        NUMBER;        --Bug# 2492041

/* <PAY ON USE FPI START> */
l_error_msg       VARCHAR2(2000);
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
/* <PAY ON USE FPI END> */

/* R12 Complex Work.*/
x_curr_shipment_type po_line_locations_all.shipment_type%type;

/*Bug: 5125624*/
l_ship_to_location_id PO_LINE_LOCATIONS.SHIP_TO_LOCATION_ID%TYPE;
l_tax_classification_code VARCHAR2(30);

X_curr_receipt_num    rcv_shipment_headers.receipt_num%TYPE := NULL;  /* bug 7512542 */
X_curr_por_summary_code po_vendor_sites.pay_on_receipt_summary_code%TYPE := NULL;  /* bug 7512542 */
X_curr_org_id                   NUMBER   :=NULL;  /* bug 7512542 */


BEGIN
   /**** BEGIN create_receipt_invoices ***/
   IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('Begin Create Receipt Invoices ... ');
   END IF;

   X_invoice_count := 0;
   X_invoice_running_total := 0;
   X_first_rcv_txn_flag := 'Y';

   X_progress  := '010';


   /** bug 885111, allow user to supply aging period from the report **/

   IF (x_aging_period IS NULL) THEN

       /* Get Aging period */
            FND_PROFILE.GET('AGING_PERIOD', X_profile);
            l_aging_period := floor(to_number(X_profile));

            IF l_aging_period < 0 THEN
              l_aging_period := 0;
            END IF;

   ELSE
       l_aging_period := x_aging_period;
   END IF;


   X_progress := '020';
   IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('Begin processing rcv txns ... [' || to_char(x_aging_period) || ']');
   END IF;


   IF (X_rcv_shipment_header_id IS NULL) THEN

       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('opening c_receipt_txns');
       END IF;
       OPEN c_receipt_txns;
        ELSE
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('opening c_receipt_txns2');
       END IF;
       OPEN c_receipt_txns2;

        END IF;

   LOOP

   X_progress := '030';

   IF (X_rcv_shipment_header_id IS NULL) THEN

       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('fetching c_receipt_txns');
       END IF;
       FETCH c_receipt_txns INTO X_rcv_txns;

       IF (c_receipt_txns%NOTFOUND) THEN
           IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('closing c_receipt_txns');
           END IF;
           CLOSE C_receipt_txns;
      EXIT;
       END IF;

        ELSE
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('fetching c_receipt_txns2');
       END IF;
       FETCH c_receipt_txns2 INTO X_rcv_txns;

       IF (c_receipt_txns2%NOTFOUND) THEN
           IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('closing c_receipt_txns2');
           END IF;
      CLOSE C_receipt_txns2;
      EXIT;
       END IF;

        END IF;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('IN processing rcv txns ... ');
            END IF;

      X_progress := '040';

      po_invoices_sv1.get_vendor_related_info(X_rcv_txns.vendor_id,
                                 X_rcv_txns.default_pay_site_id,
            X_pay_group_lookup_code,
                                --X_accts_pay_combination_id,
                                X_payment_method_lookup_code,
                 X_payment_priority,
                 X_terms_date_basis,
                 X_vendor_income_tax_region,
                 X_type_1099,
            X_awt_flag,
            X_awt_group_id,
            X_exclude_freight_from_disc,
                                X_payment_currency_code           -- BUG 612979 add payment_currency_code of default pay site
            );

      X_progress := '045';

               /*Bug#2492041 Get the Operating Unit for the PO */
                select org_id
                into   x_org_id
                from   po_headers_all
                where  po_header_id = X_rcv_txns.po_header_id;

      IF (x_payment_currency_code is NULL) THEN
            x_payment_currency_code := X_rcv_txns.currency_code;
      END IF;

      /*Check to see if it is the first invoice to be created: */

      IF (X_first_rcv_txn_flag = 'Y') THEN

         /**** Logic for the first invoice created ***/
         X_progress := '050';

         X_first_rcv_txn_flag := 'N';

         /*** if any application error occurs the creation
         of an invoice, the program will rollback to this
         savepoint. ***/

         SAVEPOINT header_record_savepoint;
         X_curr_inv_process_flag := 'Y';

         /*The following variables will be used to determine if
         a new invoice should be created: */
                        /**   Bug 586895      **/
                        X_curr_method_code :=
                                        X_payment_method_lookup_code;

                        /**   Bug 612979      **/


                   X_curr_pay_curr_code := X_payment_currency_code;

         X_curr_invoice_amount        := 0;
         X_curr_vendor_id       := X_rcv_txns.vendor_id;
         X_curr_pay_site_id        :=
               X_rcv_txns.default_pay_site_id;
         X_curr_currency_code     := X_rcv_txns.currency_code;
         X_curr_conversion_rate_type :=
               X_rcv_txns.currency_conversion_type;
         /* R12 Complex Work.
          * Get the shipment type.
         */
         X_curr_shipment_type         := X_rcv_txns.shipment_type;

                        /*  Bug# 1176326
         ** We now take the rate corresponding to the date
         ** on which the invoice was created rather than taking
         ** the rate on the receipt date
         */
                         select base_currency_code
                         into X_def_base_currency_code
                         from ap_system_parameters;

         X_curr_conversion_rate_date  :=
               Nvl(X_rcv_txns.currency_conversion_date, X_rcv_txns.transaction_date); -- Bug 8579970

         X_curr_conversion_rate :=
            ap_utilities_pkg.get_exchange_rate(
               X_curr_currency_code,
                                        X_def_base_currency_code,
               X_curr_conversion_rate_type,
               X_curr_conversion_rate_date,
               'create_receipt_invoices');

         if X_curr_conversion_rate is null then
             X_curr_conversion_rate         :=
               X_rcv_txns.currency_conversion_rate;
             X_curr_conversion_rate_date  :=
               X_rcv_txns.currency_conversion_date;
         end if;
      /* 3065403 - Changed packing slip to pack slip as the alias name is
         changed in the cursor. */

         X_curr_payment_terms_id      :=
               X_rcv_txns.payment_terms_id;
         X_curr_packing_slip       := X_rcv_txns.pack_slip;
         X_curr_shipment_header_id    :=
               X_rcv_txns.shipment_header_id;
         X_curr_osa_flag              := X_rcv_txns.osa_flag; --Shikyu project
         X_curr_transaction_date      :=
               X_rcv_txns.transaction_date;


      /* Bug 7512542 Initialising the variables with current cursor values */

			X_curr_org_id := x_org_id;
			X_curr_por_summary_code :=
					X_rcv_txns.pay_on_receipt_summary_code;
			X_curr_receipt_num := X_rcv_txns.receipt_num;

      /* End Bug 7512542 */

         /*
           AP requires the invoice_date, goods_received_date and
           invoice_received_date converted in to the LE time zone.
           Bug: 5205516
         */
         X_curr_le_transaction_date   :=
               INV_LE_TIMEZONE_PUB.GET_LE_DAY_TIME_FOR_OU(x_curr_transaction_date,x_org_id);
         X_progress := '060';



         /* Bug510160. gtummala. 8/4/97
                   * Need to set the approval status to NULL not
          * UNAPPROVED.
                   */

         /* added by nwang  */

/* Bug 7512542 Commenting call to create_invoice_num */
                /* IF (X_curr_inv_process_flag = 'Y') THEN
                    BEGIN
                       X_curr_invoice_num :=
                  po_invoices_sv2.create_invoice_num(
                        x_org_id, -- SBI ENH
                        X_rcv_txns.default_pay_site_id, -- SBI ENH
                               X_rcv_txns.pay_on_receipt_summary_code,
                               X_curr_le_transaction_date, --Bug: 5344040
                               X_rcv_txns.pack_slip,
                               X_rcv_txns.receipt_num);
                 EXCEPTION
                   WHEN others THEN
                     asn_debug.put_line('create_invoice_num raised error');
                     X_curr_inv_process_flag := 'N';
                     X_first_rcv_txn_flag := 'Y';
                 END;
              END IF;*/
/* End bug 7512542 */

            select ap_invoices_interface_s.nextval
            into   x_curr_invoice_id
            from   sys.dual;

            x_group_id :=  substr('ERS-'||TO_CHAR(X_rcv_txns.transaction_id),1,80);


/* bug 612979 */       IF (gl_currency_api.is_fixed_rate(X_curr_pay_curr_code,
               X_curr_currency_code, X_curr_transaction_date) = 'Y'
                           and X_curr_pay_curr_code <> X_curr_currency_code) THEN
                            X_ap_pay_curr := X_curr_pay_curr_code;
                       ELSE
                            X_ap_pay_curr := X_curr_currency_code;
                       END IF;

      End IF; -- X_first_rcv_txn_flag

   -- parameters to this API are NOT all the columns in AP_INVOICES, the
   -- other columns are not used by create_receipt_invoices or create_notice_invoices.

   /**** Check to see if there is a change in   vendor,
                  pay_site,
                  currency  or
                  txn_date
   If so, we would first update the current invoice -- invoice amount, etc.
   create payment schedule for the invoice and then
        get ready to create a new invoice.    ***/

        /* Bug 586895 */

        /* Bug 2536170 - We consider the transaction date also for
          creating new invoice as it determines the conversion rate
          between the purchasing currency and invoice currency.But when
          the transaction date remaining the same except for the timestamp
          we were creating a new invoice. This should not be the case.
          So added a trunc on the date comparisons so that all the transactions
          that have the same transaction date except for the timestamp will
          have a single invoice provided these transactions can be grouped by
          the invoice summary level(pay_on_summary_code). Also removed the
          AND condition added in fix 1703833 as there will conversion issues
          if we don't consider transaction dates for pay sites also.
       */

   /* Bug 1703833. If the receipt_date is different, then we create
    * multiple invoices even if the pay_on_receipt_summary_code is
    * PAY_SITE. Changed the code below to include the condition
    * that if transaction_date is not the same and the summary code
    * is not PAY_SITE, then go inside the if clause.
   */

       /* Bug 2531542 - The logic followed for creating invoices is to
          insert records into ap_lines_interface first (distributions)
          and then insert the records in ap_invoices_interface(Headers)
          so the amount will be the total distribution amount.
          For bug fix 1762305 , if the net received quantity is 0 then
          distribuitions lines were not inserted. But the records were
          inserted for the headers even for the received qty of 0.
          Because of this Payables import program was erroring out with
          'Atleast one invoice line is needed'  error message. So
          checking for the distribiution count before inserting the headers
          and inserting only if the distribution count is >0. */

   /* 3065403 - Changed packing slip to pack slip as the alias name is
         changed in the cursor. */

   /* R12 Complex Work.
    * Compare shipment_types and if they are different then create
    * a new invoice. Here we will have Standard for all the other
    * shipment_types other than prepayment as we want to group
    * them together.
   */

   IF   (X_curr_vendor_id <> X_rcv_txns.vendor_id)       OR
         (X_curr_pay_site_id <> X_rcv_txns.default_pay_site_id) OR
        (X_curr_currency_code <> X_rcv_txns.currency_code)  OR
        (X_curr_payment_terms_id <> X_rcv_txns.payment_terms_id) OR
           (trunc(X_curr_transaction_date) <> trunc(X_rcv_txns.transaction_date)) OR
             (X_curr_packing_slip <> X_rcv_txns.pack_slip AND
                X_rcv_txns.pay_on_receipt_summary_code = 'PACKING_SLIP') OR
             (X_curr_shipment_header_id <> X_rcv_txns.shipment_header_id AND
                X_rcv_txns.pay_on_receipt_summary_code = 'RECEIPT')  OR
             (X_curr_method_code <> X_payment_method_lookup_code) OR
        (X_curr_shipment_type <> x_rcv_txns.shipment_type) OR--Complex Work
             (X_curr_osa_flag <> X_rcv_txns.osa_flag) --Shikyu project
                                                                       THEN
            /*  2531542 */
             select count(*) into x_dist_count
             from ap_invoice_lines_interface
             where invoice_id = x_curr_invoice_id;



            /* Bug# 1176326
            ** We now take the rate corresponding to the date
            ** on which the invoice was created rather than taking
            ** the rate on the receipt date
            */
            select base_currency_code
            into X_def_base_currency_code
            from ap_system_parameters;

            X_curr_conversion_rate_date1  :=
                    Nvl(X_rcv_txns.currency_conversion_date, X_rcv_txns.transaction_date); -- Bug 8579970

            X_curr_conversion_rate1 :=
                ap_utilities_pkg.get_exchange_rate(
                    X_rcv_txns.currency_code,
                    X_def_base_currency_code,
                    X_rcv_txns.currency_conversion_type,
                    X_curr_conversion_rate_date1,
                    'create_receipt_invoices');

            if X_curr_conversion_rate1 is null then
                X_curr_conversion_rate1       :=
                    X_rcv_txns.currency_conversion_rate;
                X_curr_conversion_rate_date1  :=
                    X_rcv_txns.currency_conversion_date;
            end if;

           /*** a new invoice needs to be created ... and we need to
      update the current one before the new one can be created.  ***/

      X_progress := '090';

         /** update invoice amounts and also running totals.
         Also create payment schedules ***/
         /*Bug 5382916: Date in the description should be in LE Time zone*/

           fnd_message.set_name('PO', 'PO_INV_CR_ERS_INVOICE_DESC');

      X_progress := '100';
      fnd_message.set_token('RUN_DATE', x_curr_le_transaction_date);
      X_progress := '110';
      X_invoice_description := fnd_message.get;

      /* Bug 8741094 Setting the values of X_curr_conversion_rate1 and X_curr_conversion_rate_date1 to NULL if the
         functional currency is the same as the foreign currency, and the currency conversion rate type is not 'User'. */
      IF (NVL(UPPER(x_curr_conversion_rate_type),'$#%@^$$') <> 'USER'
          AND X_rcv_txns.currency_code = X_def_base_currency_code) THEN
          asn_debug.put_line('Setting the values of X_curr_conversion_rate1 and X_curr_conversion_rate_date1 to NULL');
          X_curr_conversion_rate1      := NULL;
          X_curr_conversion_rate_date1 := NULL;
      END IF;
      /* End of fix for Bug 8741094 */

   IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('creating invoice headers');
   END IF;
            /* bug 1832024 : we need to insert terms id into the interface table
               so that ap get the value */


              if (x_curr_inv_process_flag = 'Y') THEN
                 if (x_dist_count > 0 ) then   -- 2531542
                    asn_debug.put_line('x_curr_pay_site_id='||x_curr_pay_site_id||' and X_rcv_txns.default_pay_site_id='||X_rcv_txns.default_pay_site_id);

		    /* Bug 7512542 Calling create_invoice_num here to ensure
		    gapless invoice numbering and passing the parameters which
		    correspond to the RT record being invoiced */

                    BEGIN
   		      X_curr_invoice_num :=
	                po_invoices_sv2.create_invoice_num(
				X_curr_org_id,
	        		X_curr_pay_site_id,
		                X_curr_por_summary_code,
		                X_curr_le_transaction_date,
		                X_curr_packing_slip,
		                X_curr_receipt_num);

		      asn_debug.put_line('Invoice Number = ' ||X_curr_invoice_num);

		    EXCEPTION
		    WHEN others THEN
		    asn_debug.put_line('create_invoice_num raised error');
		    X_curr_inv_process_flag := 'N';
		    X_first_rcv_txn_flag := 'Y';
		    END;
                      /* End bug 7512542 */

          insert into AP_INVOICES_INTERFACE
          (INVOICE_ID,
           INVOICE_NUM,
           VENDOR_ID,
           VENDOR_SITE_ID,
           INVOICE_AMOUNT,
           INVOICE_CURRENCY_CODE,
           INVOICE_DATE,
           SOURCE,
           DESCRIPTION,
           GOODS_RECEIVED_DATE,
           INVOICE_RECEIVED_DATE,
           CREATION_DATE,
           EXCHANGE_RATE,
           EXCHANGE_RATE_TYPE,
           EXCHANGE_DATE,
                     TERMS_ID,
           GROUP_ID,
                     ORG_ID,            -- Bug#2492041
                    -- GL_DATE,            -- Bug#: 3418406
                    /* Bug 4735452. Commenting gl_date so that AP determines the same based on GL date basis */
                     INVOICE_TYPE_LOOKUP_CODE, -- Complex Work
                     CALC_TAX_DURING_IMPORT_FLAG, -- TCA
                     ADD_TAX_TO_INV_AMT_FLAG   -- bug 5499478
           ) VALUES
          (x_curr_invoice_id,
           x_curr_invoice_num,
           x_curr_vendor_id,
           x_curr_pay_site_id,
           x_curr_invoice_amount,
           x_curr_currency_code,
           x_curr_le_transaction_date, --Bug 5205516: INVOICE_DATE in LE Time zone
           'ERS',  -- debug, needs to change,
           x_invoice_description,
           x_curr_le_transaction_date, --Bug 5205516: GOODS_RECEIVIED_DATE in LE Time zone
           x_curr_le_transaction_date, --Bug 5205516: INVOICE_RECEIVIED_DATE in LE Time zone
           sysdate,
           x_curr_conversion_rate,
           x_curr_conversion_rate_type,
           x_curr_conversion_rate_date,
                     X_curr_payment_terms_id,
           x_group_id,
                     x_org_id,
                     --inv_le_timezone_pub.get_le_day_for_ou(x_curr_transaction_date, x_org_id),
                     /* Bug 4735452. Commenting gl_date so that AP determines the same based on GL date basis */
                     x_curr_shipment_type,
                     'Y',
                     'Y'
           );
                end if ; -- x_dist_count >0
             end if;

/* Bug#3277331 The correct values for Exchange Rate and Exchange Rate Date
** should be passed to the following procedure so that the Invoices will get
** created with the correct values.
*/

      /* R12 Complex work.
       * Send the x_rcv_txns.shipment_type and
       * x_curr_shipment_type to wrap_up_current_invoice
       * procedure.
      */
      po_invoices_sv2.wrap_up_current_invoice(
            X_rcv_txns.vendor_id,
            X_rcv_txns.default_pay_site_id,
                 X_rcv_txns.currency_code,
                 X_rcv_txns.currency_conversion_type,
/* Bug#3277331
            X_rcv_txns.currency_conversion_date,
            X_rcv_txns.currency_conversion_rate,
*/
            X_curr_conversion_rate_date1,    /* Bug#3277331 */
            X_curr_conversion_rate1,   /* Bug#3277331 */
            X_rcv_txns.payment_terms_id,
            X_rcv_txns.transaction_date,
            X_rcv_txns.pack_slip,
            X_rcv_txns.shipment_header_id,
            x_rcv_txns.osa_flag, --Shikyu project
            X_terms_date,
            X_payment_priority,
/**   Bug 586895      **/  X_payment_method_lookup_code,
                                X_curr_method_code,
/*    Bug 612979 */     X_payment_currency_code,
                                X_curr_pay_curr_code,
            X_batch_id,
            X_curr_invoice_amount,
            X_curr_invoice_id,
            X_curr_vendor_id,
            X_curr_pay_site_id,
            X_curr_currency_code,
            X_curr_conversion_rate_type,
            X_curr_conversion_rate_date,
            X_curr_conversion_rate,
            X_curr_payment_terms_id,
            X_curr_transaction_date,
            X_curr_packing_slip,
            X_curr_shipment_header_id,
            X_curr_osa_flag, --Shikyu project
            X_curr_inv_process_flag,
            X_invoice_count,
            X_invoice_running_total,
            X_rcv_txns.shipment_type,--Complex Work
            X_curr_shipment_type, --Complex Work
            X_org_id,
            X_curr_le_transaction_date
            );

      /*** Ready to create the next invoice ***/

/* Bug 7512542 */
X_curr_receipt_num := X_rcv_txns.receipt_num;
x_curr_org_id      := x_org_id;
X_curr_por_summary_code := X_rcv_txns.pay_on_receipt_summary_code;
/* Bug 7512542 end */

      X_progress := '110';

      IF (X_curr_inv_process_flag <> 'Y') THEN
         /** at least one error occurred **/
         X_completion_status := FALSE;
         ROLLBACK TO header_record_savepoint;
      END IF;

      IF MOD(X_invoice_count , X_commit_interval) = 0
                                    AND x_invoice_count  > 0   THEN
         X_progress := '100';

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Committing changes ... ');
         END IF;
                     COMMIT;
      END IF;

      SAVEPOINT header_record_savepoint;
      X_curr_inv_process_flag := 'Y';

/* Bug 7512542 Commenting call to create_invoice_num */

          /* IF (X_curr_inv_process_flag = 'Y') THEN
              BEGIN
                 X_curr_invoice_num :=
          po_invoices_sv2.create_invoice_num(
                     x_org_id, -- SBI ENH
                     X_rcv_txns.default_pay_site_id, -- SBI ENH
                            X_rcv_txns.pay_on_receipt_summary_code,
                            X_curr_le_transaction_date,--BUG 5344040: LE TIME ZONE
                            X_rcv_txns.pack_slip,
                            X_rcv_txns.receipt_num);
              EXCEPTION
                WHEN others THEN
                  asn_debug.put_line('create_invoice_num raised error');
                  X_curr_inv_process_flag := 'N';
              END;
           END IF;*/
/* End bug 7512542 */

      X_progress := '130';

               /* Bug510160. gtummala. 8/4/97
                * Need to set the approval status to NULL not UNAPPROVED.
                */
               /* bug 612979 */

               IF (gl_currency_api.is_fixed_rate(X_curr_pay_curr_code,
         X_curr_currency_code, X_curr_transaction_date) = 'Y'
                   and X_curr_pay_curr_code <> X_curr_currency_code) THEN
                     X_ap_pay_curr := X_curr_pay_curr_code;
               ELSE
                     X_ap_pay_curr := X_curr_currency_code;
               END IF;

         -- parameters to this API are NOT all the columns in
         -- AP_INVOICES, the other columns are not used by
         -- create_receipt_invoices or create_notice_invoices.

   END IF; /** change in one of the curr_ variables **/

   /**** Create invoice distribution(s) , tax distribution(s) and
   update rcv_txns, po_line_locations and po_distributions accordingly *****/


   X_progress := '140'; -- receipt_invoices

   IF (X_curr_inv_process_flag = 'Y') THEN
      /** only create invoice and/or tax distr if the invoice is still
      processable.  **/


                /* bug 660397 if there is a corresponding 'DELIVER' transaction for
                   a 'RECEIVE' transaction, we want to pass in 'DELIVER' into
                   create_invoice_distribution, so that only one invoice distribution is created.
                   Otherwise, if there would be pro-ration done on every distribution,
         creating a total of n square invoice distributions */


        --bug 17972946 begin
        IF(X_rcv_txns.timecard_id IS NOT NULL) THEN
        	 X_inv_event:= 'DELIVER';
        ELSE
                SELECT MIN(NVL(transaction_type, X_receipt_event))
                INTO   X_inv_event
                FROM   rcv_transactions
                WHERE  shipment_line_id = X_rcv_txns.shipment_line_id
                AND    po_distribution_id = NVL(X_rcv_txns.po_distribution_id,-1)
                AND    parent_transaction_id = X_rcv_txns.transaction_id
                AND    transaction_type = 'DELIVER';
        END IF;
        --bug 17972946 end

                /* Get the adjusted quantity for invoice creation */

                IF X_rcv_txns.matching_basis = 'AMOUNT' THEN
                   X_received_quantity := 0;
                   po_invoices_sv2.get_received_amount(X_rcv_txns.transaction_id,
                                                       X_rcv_txns.shipment_line_id,
                                                       X_received_amount);
                ELSE
                   X_received_amount := 0;
asn_debug.put_line('pparthasmatch_option '||x_rcv_txns.match_option);
                   po_invoices_sv2.get_received_quantity(X_rcv_txns.transaction_id,
                                                         X_rcv_txns.shipment_line_id,
                                                         X_received_quantity,
							 X_rcv_txns.match_option ); --5100177
                END IF;


      /* Bug 1762305. Need not create an invoice line if
       * net quantity received is 0.
      */

                /* Removed the fix of 2379414 as it is already commented */


	/* Bug 5100177.
	 * According to AP, we need to populte unit_meas_lookup_code in
	 * AP lines interface table with rt.unit_of_measure if match
	 * option in PO shipment is Receipt and with unit_of_measure
	 * from PO shipment if the match option is PO.
	*/
	if X_rcv_txns.match_option = 'P' then
		X_unit_meas_lookup_code := X_rcv_txns.unit_meas_lookup_code;
asn_debug.put_line('pparthas from shipment '||X_unit_meas_lookup_code);
	elsif  X_rcv_txns.match_option = 'R' then
		X_unit_meas_lookup_code := X_rcv_txns.unit_of_measure;
asn_debug.put_line('pparthas from rt '||X_unit_meas_lookup_code);
	end if;


                if (x_received_quantity <> 0 or x_received_amount <> 0) then
         po_invoices_sv2.create_invoice_distributions(
                     X_curr_invoice_id,
                     X_curr_currency_code,
                     x_curr_currency_code,
                     X_batch_id,
                     X_curr_pay_site_id,
                     X_rcv_txns.po_header_id,
                     X_rcv_txns.po_line_id,
                     X_rcv_txns.po_line_location_id,
                     X_rcv_txns.po_release_id, -- bug 901039
                     X_inv_event, -- bug 660397
                     X_rcv_txns.po_distribution_id,
                     X_rcv_txns.item_description,
                     X_type_1099,
                     X_rcv_txns.tax_code_id,
                     X_received_quantity,
                     X_rcv_txns.po_unit_price,
                     X_curr_conversion_rate_type,
                     X_curr_conversion_rate_date,
                     X_curr_conversion_rate,
                     X_curr_transaction_date,
                     X_curr_transaction_date,
                          X_vendor_income_tax_region,
                     'ERS',   -- reference_1
                           TO_CHAR(X_rcv_txns.transaction_id),
                          -- reference_2
                     X_awt_flag,
                     X_awt_group_id,
                     X_curr_accounting_date,
                     X_curr_period_name,
                     'ERS',   -- transaction_type
                     X_rcv_txns.transaction_id,
                        -- unique_id
                          X_curr_invoice_amount,
                     X_curr_inv_process_flag,
                     X_rcv_txns.receipt_num,
                     X_rcv_txns.transaction_id,
/* Bug3493515 (2) - START */
		    X_rcv_txns.match_option, -- NULL, -- Bug 6822594 Passing the match option
                     X_received_amount,
                     X_rcv_txns.matching_basis,
		     X_unit_meas_lookup_code, --5100177
                     X_rcv_txns.lcm_shipment_line_id); -- PoR with LCM project
/* Bug3493515 (2) - END */

      end if; -- end of if x_received_quantity <> 0
   END IF;    -- X_curr_inv_process_flag

   X_progress := '150';

   /*** make sure to indicate this receipt transaction has been invoiced ***/

   -- need to provide an API for AP instead

        -- update invoice_status_code of 'RECEIVE', 'CORRECT' and
        --   'RETURN TO VENDOR' transactions

           UPDATE  rcv_transactions
           SET invoice_status_code = DECODE(X_curr_inv_process_flag,'Y','INVOICED','REJECTED'), -- bug 3640106
         last_updated_by     = FND_GLOBAL.user_id,
         last_update_date    = sysdate,
         last_update_login   = FND_GLOBAL.login_id
           WHERE   transaction_id IN (
                 SELECT
                   transaction_id
                 FROM
                   rcv_transactions
                 WHERE
                   invoice_status_code <> 'INVOICED' AND
                   transaction_type IN ('RECEIVE','CORRECT','RETURN TO VENDOR')
                 START WITH transaction_id = X_rcv_txns.transaction_id
                 CONNECT BY parent_transaction_id = PRIOR transaction_id
                );

   END LOOP;

   /*** Logic for the last invoice ***/
   X_progress := '160';

   IF (X_first_rcv_txn_flag = 'N') AND
      (X_curr_inv_process_flag = 'Y')
   THEN
      /*Bug 5382916: Date in the description should be in LE Time zone*/
      fnd_message.set_name('PO', 'PO_INV_CR_ERS_INVOICE_DESC');
      X_progress := '100';
      fnd_message.set_token('RUN_DATE', x_curr_le_transaction_date);
      X_progress := '110';
      X_invoice_description := fnd_message.get;

      /* Bug 8741094 Setting the values of X_curr_conversion_rate and X_curr_conversion_rate_date to NULL if the
         functional currency is the same as the foreign currency, and the currency conversion rate type is not 'User'. */
      IF (NVL(UPPER(x_curr_conversion_rate_type),'$#%@^$$') <> 'USER'
          AND X_rcv_txns.currency_code = X_def_base_currency_code) THEN
          asn_debug.put_line('Setting the values of X_curr_conversion_rate and X_curr_conversion_rate_date to NULL');
          X_curr_conversion_rate      := NULL;
          X_curr_conversion_rate_date := NULL;
      END IF;
      /* End of fix for Bug 8741094 */

       /* Removed the fix of 2379414 from here as it is already commented */

   IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('creating invoice distributions');
   END IF;

	/* Bug 7512542 Calling create_invoice_num here to ensure gapless invoicing */

	IF (X_curr_inv_process_flag = 'Y') THEN

         select count(*) into x_dist_count
         from ap_invoice_lines_interface
         where invoice_id = x_curr_invoice_id;

         if (x_dist_count > 0 ) then
		BEGIN

   		X_curr_invoice_num :=
	           po_invoices_sv2.create_invoice_num(
	        	X_curr_org_id,
			X_curr_pay_site_id,
		        X_curr_por_summary_code,
		        X_curr_le_transaction_date,
			X_curr_packing_slip,
		        X_curr_receipt_num);

                   asn_debug.put_line('Invoice Number = ' ||X_curr_invoice_num);

		EXCEPTION
		WHEN others THEN
		asn_debug.put_line('create_invoice_num raised error');
		X_curr_inv_process_flag := 'N';
		X_first_rcv_txn_flag := 'Y';

		END;
           END IF;

          END IF;

	  /* End Bug 7512542 */


          insert into AP_INVOICES_INTERFACE
          (INVOICE_ID,
           INVOICE_NUM,
           VENDOR_ID,
           VENDOR_SITE_ID,
           INVOICE_AMOUNT,
           INVOICE_CURRENCY_CODE,
           INVOICE_DATE,
           SOURCE,
           DESCRIPTION,
           GOODS_RECEIVED_DATE,
           INVOICE_RECEIVED_DATE,
           CREATION_DATE,
           EXCHANGE_RATE,
           EXCHANGE_RATE_TYPE,
           EXCHANGE_DATE,
                     TERMS_ID,
           GROUP_ID,
                     ORG_ID,            -- Bug#2492041
                     -- GL_DATE   ,/* Bug 4735452. Commenting gl_date so that AP determines the same based on GL date basis */
           INVOICE_TYPE_LOOKUP_CODE, --COMPLEX WORK
                     CALC_TAX_DURING_IMPORT_FLAG,
                     ADD_TAX_TO_INV_AMT_FLAG   -- bug 5499478
           ) VALUES
          (x_curr_invoice_id,
           x_curr_invoice_num,
           x_curr_vendor_id,
           x_curr_pay_site_id,
           x_curr_invoice_amount,
           x_curr_currency_code,
           x_curr_le_transaction_date, --Bug 5205516: INVOICE_DATE in LE Time zone
           'ERS',  -- debug, needs to change,
           x_invoice_description,
           x_curr_le_transaction_date,--Bug 5205516: GOODS_RECEIVIED_DATE in LE Time zone
           x_curr_le_transaction_date,--Bug 5205516: INVOICE_RECEIVIED_DATE in LE Time zone
           sysdate,
           x_curr_conversion_rate,
           x_curr_conversion_rate_type,
           x_curr_conversion_rate_date,
                     X_curr_payment_terms_id,
           x_group_id,
                     x_org_id,
           --  inv_le_timezone_pub.get_le_day_for_ou(x_curr_transaction_date, x_org_id),
           /* Bug 4735452. Commenting gl_date so that AP determines the same based on GL date basis */
           x_curr_shipment_type,
                     'Y',
                     'Y'
           );

      /*** We do not need to round our amounts here because
      the invoice amount and tax amount are calculated within
      the create_invoice_distributions and roundings are done
      there. ***/

      /*** Update running totals ***/
      X_progress := '170';

      X_invoice_count := X_invoice_count + 1;
      X_invoice_running_total := X_invoice_running_total + X_curr_invoice_amount;


      X_progress := '180';


   END IF;    -- if X_rcv_first_flag

   IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('Completed create receipt invoices program... ');
   END IF;

   select count(*) into x_dist_count
   from ap_invoice_lines_interface
   where invoice_id = x_curr_invoice_id;

   if (x_dist_count = 0 ) then
      x_invoice_count := x_invoice_count - 1;
      delete from ap_invoices_interface
      where invoice_id=x_curr_invoice_id;
   end if;


   /*
   ** if x_group_id is not null, then at least one record has been inserted.
   ** Then we need to run the AP import program
   */

   IF (x_group_id is NOT NULL) THEN
           FND_PROFILE.GET('USER_ID', l_user_id);

         /*Bug# 1539257 Building the batch name which was earlier NA */
                fnd_message.set_name('PO', 'PO_INV_CR_ERS_BATCH_DESC');
                X_batch_name := fnd_message.get;

             SELECT  ap_batches_s.nextval
             INTO    X_tmp_batch_id
             FROM    dual;

      /* need to commit before we submit another conc request, since
         the request in another session */

      COMMIT;


/* <PAY ON USE FPI START> */
/* fnd_request.submit_request has been replaced by
   PO_INVOICES_SV1.submit_invoice_import as a result of refactoring
   performed during FPI Consigned Inv project */

      PO_INVOICES_SV1.submit_invoice_import(
                l_return_status,
                'ERS',
                x_group_id,
                x_batch_name || '/' || TO_CHAR(sysdate)
                    || '/' || TO_CHAR(X_tmp_batch_id),
                l_user_id,
                0,
                v_req_id);

           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

/* <PAY ON USE FPI END> */

            fnd_message.set_name('PO', 'PO_ERS_CONC_REQUEST_CHECK');
       fnd_message.set_token('REQUEST', TO_CHAR(v_req_id));
       fnd_message.set_token('BATCH', x_group_id);

       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line(fnd_message.get);
       END IF;
         END IF;

   RETURN (X_completion_status);

EXCEPTION

/* <PAY ON USE FPI START> */
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        l_error_msg := FND_MSG_PUB.get(p_encoded => 'F');
        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line(l_error_msg);
        END IF;
        RAISE;
/* <PAY ON USE FPI END> */
WHEN others THEN
   IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('Error in Create Receipt Invoices ...');
   END IF;
         po_message_s.sql_error('create_receipt_invoices', X_progress, sqlcode);
   RAISE;
END create_receipt_invoices;


/*================================================================

  PROCEDURE NAME: wrap_up_current_invoice()

==================================================================*/


      /* R12 Complex work.
       * Add the x_new_shipment_type and
       * x_curr_shipment_type to wrap_up_current_invoice
       * procedure.
      */
PROCEDURE WRAP_UP_CURRENT_INVOICE(X_new_vendor_id  IN NUMBER,
      X_new_pay_site_id    IN NUMBER,
      X_new_currency_code     IN VARCHAR2,
      X_new_conversion_rate_type IN VARCHAR2,
      X_new_conversion_rate_date IN DATE,
      X_new_conversion_rate      IN NUMBER,
      X_new_payment_terms_id     IN NUMBER,
      X_new_transaction_date     IN DATE,
           X_new_packing_slip    IN VARCHAR2,
      X_new_shipment_header_id   IN NUMBER,
      X_new_osa_flag                  IN VARCHAR2, --Shikyu project
      X_terms_date         IN DATE,
      X_payment_priority      IN VARCHAR2,
/*Bug 586895*/  X_new_payment_code              IN VARCHAR2,
      X_curr_method_code              IN OUT NOCOPY VARCHAR2,
/*Bug 612979*/  X_new_pay_curr_code             IN VARCHAR2,
      X_curr_pay_curr_code            IN OUT NOCOPY VARCHAR2,
      X_batch_id        IN OUT NOCOPY NUMBER,
      X_curr_invoice_amount      IN OUT   NOCOPY NUMBER,
      X_curr_invoice_id    IN OUT NOCOPY NUMBER,
      X_curr_vendor_id     IN OUT NOCOPY NUMBER,
      X_curr_pay_site_id      IN OUT NOCOPY NUMBER,
           X_curr_currency_code     IN OUT NOCOPY VARCHAR2,
      X_curr_conversion_rate_type   IN OUT   NOCOPY VARCHAR2,
      X_curr_conversion_rate_date   IN OUT NOCOPY DATE,
      X_curr_conversion_rate     IN OUT NOCOPY NUMBER,
      X_curr_payment_terms_id    IN OUT NOCOPY NUMBER,
      X_curr_transaction_date    IN OUT   NOCOPY DATE,
      X_curr_packing_slip     IN OUT   NOCOPY VARCHAR2,
           X_curr_shipment_header_id   IN OUT NOCOPY NUMBER,
           X_curr_osa_flag                 IN OUT NOCOPY VARCHAR2, --Shikyu project
      X_curr_inv_process_flag    IN OUT NOCOPY VARCHAR2,
      X_invoice_count         IN OUT NOCOPY NUMBER,
      X_invoice_running_total    IN OUT NOCOPY NUMBER ,
      X_new_shipment_type     IN       VARCHAR2,--Complex Work
      X_curr_shipment_type    IN OUT NOCOPY VARCHAR2,--Complex Work
      X_org_id IN NUMBER, --Bug 5531203
			X_curr_le_transaction_date IN OUT NOCOPY DATE
			)

IS

   X_progress        VARCHAR2(3) := NULL;
   X_discountable_amount   NUMBER;
   X_pay_cross_rate  NUMBER;
        X_ap_pay_curr            po_vendor_sites.payment_currency_code%TYPE;

BEGIN
   IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('Wrapping up the current invoice ... ');
   END IF;

   IF (X_curr_inv_process_flag = 'Y') THEN
      X_progress := '010';
      /*** a new invoice needs to be created ... and we need to
      update the current one before the new one can be created.  ***/

                -- BUG 612979

                IF (gl_currency_api.is_fixed_rate(X_curr_pay_curr_code, X_curr_currency_code, X_curr_transaction_date) = 'Y'
                    and X_curr_pay_curr_code <> X_curr_currency_code) THEN

                       X_pay_cross_rate := gl_currency_api.get_rate(X_curr_currency_code,
                            X_curr_pay_curr_code,
                                                                    X_curr_transaction_date,
                            'EMU FIXED');
                ELSE
                       X_pay_cross_rate := 1;
                END IF;

                IF (X_pay_cross_rate = 1) THEN
                    X_ap_pay_curr := X_curr_currency_code;
                ELSE
                    X_ap_pay_curr := X_curr_pay_curr_code;
                END IF;

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line ('x_pay_cross_rate ='|| x_pay_cross_rate);
                    asn_debug.put_line ('X_pay_curr_invoice_amount ='|| ap_utilities_pkg.ap_round_currency(X_curr_invoice_amount * X_pay_cross_rate, X_ap_pay_curr));
               END IF;

      -- create invoice header here

      /*** update the running totals ***/
      X_invoice_count := X_invoice_count + 1;
      X_invoice_running_total := X_invoice_running_total +
               X_curr_invoice_amount;

      X_progress := '020';

   END IF;   -- curr_inv_process_flag

   /*** assign the correct exchange rate info if currency changes ***/
   /*** remember the first occurrence of the exchange rate info will be
   used ***/


   /*** make sure the "current" variables are correct ***/
   X_progress := '080';

        select ap_invoices_interface_s.nextval
        into   x_curr_invoice_id
        from   sys.dual;

   X_curr_invoice_amount   := 0;
   X_curr_vendor_id  := X_new_vendor_id;
   X_curr_pay_site_id   := X_new_pay_site_id;
   X_curr_currency_code := X_new_currency_code;
   X_curr_conversion_rate_type := X_new_conversion_rate_type;
   X_curr_conversion_rate  := X_new_conversion_rate;
   X_curr_conversion_rate_date := X_new_conversion_rate_date;
   X_curr_payment_terms_id := X_new_payment_terms_id;
   X_curr_transaction_date := X_new_transaction_date;
   X_curr_packing_slip  := X_new_packing_slip;
   X_curr_shipment_header_id := X_new_shipment_header_id;
   X_curr_osa_flag         := X_new_osa_flag; --Shikyu project
        /**   Bug 586895      **/
        X_curr_method_code       := X_new_payment_code;
        X_curr_pay_curr_code     := X_new_pay_curr_code;
   /* R12 Complex Work.
    * Populate the new shipment type to x_curr shipment_type.
   */
   X_curr_shipment_type    := X_new_shipment_type;

   --Bug 5531203
   X_curr_le_transaction_date   :=
               INV_LE_TIMEZONE_PUB.GET_LE_DAY_TIME_FOR_OU(x_curr_transaction_date,x_org_id);


EXCEPTION
WHEN others THEN
      po_message_s.sql_error('wrap_up_current_invoice', x_progress,sqlcode);
   RAISE;
END wrap_up_current_invoice;

/* =================================================================

   FUNCTION NAME:    create_invoice_num()

==================================================================*/

FUNCTION create_invoice_num (
   x_org_id                        IN   NUMBER, -- SBI ENH
   x_vendor_site_id                IN   NUMBER, -- SBI ENH
   x_pay_on_receipt_summary_code   IN   VARCHAR2,
   x_invoice_date                  IN   DATE,
   x_packing_slip                  IN   VARCHAR2,
   x_receipt_num                   IN   VARCHAR2,
   p_source                        IN   VARCHAR2 := NULL /* <PAY ON USE FPI> */
)
   RETURN VARCHAR2
IS
   x_progress                    VARCHAR2 (3)                   := NULL;
   x_tmp_sequence_id             NUMBER;
   x_tmp_invoice_num             ap_invoices.invoice_num%TYPE;
   x_prefix                      VARCHAR2 (20);

   -- SBI ENH
   x_return_status               VARCHAR2 (1);
   x_msg_data                    VARCHAR2 (2000);
   x_msg_count                   NUMBER;
   x_buying_company_identifier   VARCHAR2 (10);
   x_selling_company_identifier  VARCHAR2 (10);
   x_gapless_inv_num_flag_org    VARCHAR2 (1);
   x_gapless_inv_num_flag_sup    VARCHAR2 (1);
   x_invoice_num                 VARCHAR2 (45);
   -- SBI ENH

BEGIN
   IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line ('Constructing Invoice Num for the invoice ... ');
   END IF;

   x_progress := '001';

  -- BugFix 5197828
  -- Above if condition is commented since we need to keep all the code realted to gapless number
  -- under one procedure. Let rcv_gapless_numbering.generate_invoice_number decide whether to
  -- create gapless numbers or not.

/*
   po_ap_integration_grp.get_invoice_numbering_options (1,
                                                        x_org_id,
                                                        x_return_status,
                                                        x_msg_data,
                                                        x_buying_company_identifier,
                                                        x_gapless_inv_num_flag_org
                                                       );

   x_progress := '002';

   AP_PO_GAPLESS_SBI_PKG.site_uses_gapless_num (x_vendor_site_id,
                                                x_gapless_inv_num_flag_sup,
                                                x_selling_company_identifier
                                               );
   x_progress := '003';

   IF (x_gapless_inv_num_flag_org = 'Y' or x_gapless_inv_num_flag_sup = 'Y') THEN -- SBI ENH
      rcv_gapless_numbering.generate_invoice_number (1,
                                                     x_buying_company_identifier,
                                                     x_selling_company_identifier,
                                                     'ERS',
                                                     x_invoice_num,
                                                     x_return_status,
                                                     x_msg_count,
                                                     x_msg_data
                                                    );

      x_progress := '004';

      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
         RETURN x_invoice_num;
      ELSE
         RAISE create_invoice_error;
      END IF;
   END IF;
*/

   rcv_gapless_numbering.generate_invoice_number (   1               ,
                                                     x_org_id        ,
                                                     x_vendor_site_id,
                                                     'ERS'           ,
                                                     x_invoice_num   ,
                                                     x_return_status ,
                                                     x_msg_count     ,
                                                     x_msg_data
                                                   );
   IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line ('rcv_gapless_numbering.generate_invoice_number returned with status = ' || x_return_status );
      asn_debug.put_line ('x_invoice_num = ' || x_invoice_num );
   END IF;

   IF (x_return_status = fnd_api.g_ret_sts_success and x_invoice_num is NOT NULL)
   THEN
       RETURN x_invoice_num;
   ELSIF (x_return_status <> fnd_api.g_ret_sts_success)
   THEN
       RAISE create_invoice_error;
   ELSE
       NULL;
   END IF;

  -- End of code for BugFix 5197828


   x_progress := '010';

   SELECT po_invoice_num_segment_s.NEXTVAL
   INTO   x_tmp_sequence_id
   FROM   SYS.DUAL;

   x_progress := '020';

/* <PAY ON USE FPI START> */
   IF (p_source = 'USE') THEN
      x_progress := '025';
      x_tmp_invoice_num :=
             'USE-'
          || TO_CHAR (x_invoice_date)
          || '-'
          || TO_CHAR (x_tmp_sequence_id);
   ELSE
/* <PAY ON USE FPI END> */

      -- Use Profile option to determine prefix
      fnd_profile.get ('ERS_PREFIX', x_prefix);
      x_progress := '030';

      IF (x_pay_on_receipt_summary_code = 'PAY_SITE') THEN
         x_progress := '040';
         x_tmp_invoice_num :=
                x_prefix
             || '-'
             || TO_CHAR (x_invoice_date)
             || '-'
             || TO_CHAR (x_tmp_sequence_id);
      ELSIF (x_pay_on_receipt_summary_code = 'PACKING_SLIP') THEN
         x_progress := '050';
         x_tmp_invoice_num :=
                x_prefix
             || '-'
             || x_packing_slip
             || '-'
             || TO_CHAR (x_tmp_sequence_id);
      ELSIF (x_pay_on_receipt_summary_code = 'RECEIPT') THEN
         x_progress := '060';
         x_tmp_invoice_num :=
                x_prefix
             || '-'
             || x_receipt_num
             || '-'
             || TO_CHAR (x_tmp_sequence_id);
      END IF; -- x_pay_on_receipt_summary_code
   END IF; -- p_source

   RETURN (x_tmp_invoice_num);
EXCEPTION
   WHEN create_invoice_error THEN
      FND_MESSAGE.SET_NAME('PO','RCV_CREATE_INVOICE_NUM_ERROR');
      FND_MESSAGE.SET_TOKEN('RECEIPT_NUM',x_receipt_num);
      FND_MESSAGE.SET_TOKEN('REASON',x_msg_data);
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      RAISE create_invoice_error;
   WHEN OTHERS THEN
      po_message_s.sql_error ('create_invoice_num', x_progress, SQLCODE);
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      RAISE;
END create_invoice_num;

/* =====================================================================

   PROCEDURE   get_received_quantity

======================================================================== */

PROCEDURE get_received_quantity( X_transaction_id     IN     NUMBER,
                                 X_shipment_line_id   IN     NUMBER,
                                 X_received_quantity  IN OUT NOCOPY NUMBER,
				 X_match_option       IN     VARCHAR2 DEFAULT NULL ) IS --5100177

   X_current_quantity    NUMBER := 0;
   X_primary_uom         VARCHAR2(25) := '';
   X_po_uom              VARCHAR2(25) := '';
   X_item_id             NUMBER := 0;

   v_primary_uom         VARCHAR2(25) := '';
   v_po_uom              VARCHAR2(25) := '';
   v_txn_id              NUMBER := 0;
   v_primary_quantity    NUMBER := 0;
   v_transaction_type    VARCHAR2(25) := '';
   v_parent_id           NUMBER := 0;
   v_parent_type         VARCHAR2(25) := '';
   v_transaction_uom     VARCHAR2(25) := ''; -- Added for bug 6822594
   v_to_uom              VARCHAR2(25) := ''; -- Added for bug 6822594
   X_receipt_uom         VARCHAR2(25) := ''; -- Added for bug 6822594

   CURSOR c_txn_history (c_transaction_id NUMBER) IS
     select
       transaction_id,
       primary_quantity,
       primary_unit_of_measure,
       source_doc_unit_of_measure,
       transaction_type,
       parent_transaction_id,
       unit_of_measure    -- Added for bug 6822594 : To get the transaction uom
     from
       rcv_transactions
     where
       invoice_status_code <> 'INVOICED'
     start with transaction_id = c_transaction_id
     connect by parent_transaction_id = prior transaction_id;

BEGIN

     OPEN c_txn_history(X_transaction_id);

     LOOP
       FETCH c_txn_history INTO v_txn_id,
                                v_primary_quantity,
                                v_primary_uom,
                                v_po_uom,
                                v_transaction_type,
                                v_parent_id,
				v_transaction_uom;  -- Added for bug 6822594

       EXIT WHEN c_txn_history%NOTFOUND;

       IF v_transaction_type = 'RECEIVE' THEN

         select
           item_id
         into
           X_item_id
         from
           rcv_shipment_lines
         where
           shipment_line_id = X_shipment_line_id;

         X_current_quantity := v_primary_quantity;
         X_primary_uom := v_primary_uom;
         X_po_uom := v_po_uom;
         X_receipt_uom := v_transaction_uom; -- Added for bug 6822594

       ELSIF v_transaction_type = 'CORRECT' THEN

         select
           transaction_type
         into
           v_parent_type
         from
           rcv_transactions
         where
           transaction_id = v_parent_id;

         IF v_parent_type = 'RECEIVE' THEN
           X_current_quantity := X_current_quantity + v_primary_quantity;
         ELSIF v_parent_type = 'RETURN TO VENDOR' THEN
           X_current_quantity := X_current_quantity - v_primary_quantity;
         END IF;

       ELSIF v_transaction_type = 'RETURN TO VENDOR' THEN

         X_current_quantity := X_current_quantity - v_primary_quantity;

       END IF;

     END LOOP;

     CLOSE c_txn_history;

     /* Added debug messages to identify the uoms for which the uom convert function failed.
        For this enclosed the uom_convert function in a begin,exception and end block.
        Bug 2923345. */

    /* Bug 5100177.
     * Convert the receipt quantity to PO quantity only when the
     * match option for the PO shipment is PO.
    */

   /* Bug 6822594
    * Handling the conversion of received quantity from primary uom to
    * po uom or transaction uom depending upon the match option at PO shipment.
    * i.e If Match Option = 'PO' then into PO UOM else in TRANSACTION UOM
    */

     IF (X_match_option = 'P') then
         v_to_uom := X_po_uom;
     ELSIF (X_match_option = 'R') then
         v_to_uom := X_receipt_uom;
     END IF;

     IF (X_primary_uom <> v_to_uom) then
      BEGIN

        po_uom_s.uom_convert(X_current_quantity,
                             X_primary_uom,
                             X_item_id,
                             v_to_uom, --Changed from X_po_uom to v_to_uom
                             X_received_quantity);
      exception
        WHEN NO_DATA_FOUND THEN

       IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('conversion not defined between uoms '||x_primary_uom||' and  '||X_po_uom);

       END IF;
       RAISE;

       WHEN OTHERS THEN

        IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exception occured while converting from uom '||x_primary_uom||' to uom  '||X_po_uom);
         asn_debug.put_line('Check if conversion exists between uoms '||x_primary_uom||' and  '||X_po_uom);
       END IF;
       RAISE;
      END;
     ELSE
        X_received_quantity := X_current_quantity;
     END IF;


END get_received_quantity;

/* =====================================================================

   PROCEDURE   get_received_amount

======================================================================== */

PROCEDURE get_received_amount( X_transaction_id     IN     NUMBER,
                               X_shipment_line_id   IN     NUMBER,
                               X_received_amount    IN OUT NOCOPY NUMBER) IS

   l_current_amount      NUMBER := 0;
   v_txn_id              NUMBER := 0;
   v_amount              NUMBER := 0;
   v_transaction_type    VARCHAR2(25) := '';
   v_parent_id           NUMBER := 0;
   v_parent_type         VARCHAR2(25) := '';

   CURSOR c_txn_history (c_transaction_id NUMBER) IS
     select
       transaction_id,
       amount,
       transaction_type,
       parent_transaction_id
     from
       rcv_transactions
     where
       invoice_status_code <> 'INVOICED'
     start with transaction_id = c_transaction_id
     connect by parent_transaction_id = prior transaction_id;

BEGIN

     OPEN c_txn_history(X_transaction_id);

     LOOP
       FETCH c_txn_history INTO v_txn_id,
                                v_amount,
                                v_transaction_type,
                                v_parent_id;

       EXIT WHEN c_txn_history%NOTFOUND;

       IF v_transaction_type = 'RECEIVE' THEN

         l_current_amount := v_amount;

       ELSIF v_transaction_type = 'CORRECT' THEN

         select
           transaction_type
         into
           v_parent_type
         from
           rcv_transactions
         where
           transaction_id = v_parent_id;

         IF v_parent_type = 'RECEIVE' THEN
           l_current_amount := l_current_amount + v_amount;
         ELSIF v_parent_type = 'RETURN TO VENDOR' THEN
           l_current_amount := l_current_amount - v_amount;
         END IF;

       ELSIF v_transaction_type = 'RETURN TO VENDOR' THEN

         l_current_amount := l_current_amount - v_amount;

       END IF;

     END LOOP;

     CLOSE c_txn_history;

     X_received_amount := l_current_amount; /* Bug3493515 (1) */

END get_received_amount;

/********************************************************************/
/*                                                                  */
/* PROCEDURE  create_invoice_distributions                  */
/*                                                                  */
/********************************************************************/


PROCEDURE create_invoice_distributions(X_invoice_id      IN NUMBER,
              X_invoice_currency_code  IN VARCHAR2,
              X_base_currency_code     IN VARCHAR2,
              X_batch_id         IN NUMBER,
              X_pay_site_id      IN NUMBER,
              X_po_header_id     IN NUMBER,
              X_po_line_id          IN NUMBER,
              X_po_line_location_id    IN NUMBER,
              X_po_release_id       IN NUMBER,  -- bug 901039
              X_receipt_event       IN VARCHAR2,
              X_po_distribution_id     IN NUMBER,

             /*X_receipt_event and X_po_distribution_id
             used only for DELIVER transactions*******/

              X_item_description       IN VARCHAR2,
              X_type_1099        IN VARCHAR2,
              X_tax_code_id      IN NUMBER,

              X_quantity         IN NUMBER,
              X_unit_price          IN NUMBER,
              X_exchange_rate_type     IN VARCHAR2,
              X_exchange_date       IN DATE,
              X_exchange_rate       IN NUMBER,
              X_invoice_date     IN DATE,
              X_receipt_date     IN DATE,
              X_vendor_income_tax_region  IN VARCHAR2,
              X_reference_1         IN VARCHAR2,
              X_reference_2         IN VARCHAR2,
              X_awt_flag         IN VARCHAR2,
              X_awt_group_id     IN NUMBER,
              X_accounting_date     IN DATE,
              X_period_name         IN VARCHAR2,
              X_transaction_type    IN VARCHAR2,
              X_unique_id        IN NUMBER,
              X_curr_invoice_amount    IN OUT NOCOPY   NUMBER,
                                  X_curr_inv_process_flag   IN OUT NOCOPY VARCHAR2,
              X_receipt_num              IN VARCHAR2 DEFAULT NULL,
              X_rcv_transaction_id       IN NUMBER   DEFAULT NULL,
              X_match_option             IN VARCHAR2 DEFAULT NULL,
	      X_amount                   IN NUMBER   DEFAULT NULL,
	      X_matching_basis           IN VARCHAR2 DEFAULT 'QUANTITY',
	      X_unit_meas_lookup_code    IN  VARCHAR2 DEFAULT NULL, --5100177
              X_lcm_shipment_line_id     IN NUMBER   DEFAULT NULL) -- PoR with LCM project
               IS


/*** Cursor Declaration ***/
/* Bug 3338268 - removed X_receipt_event */
CURSOR c_po_distributions(X_po_header_id        NUMBER,
               X_po_line_id           NUMBER,
               X_po_line_location_id  NUMBER,
               X_po_distribution_id   NUMBER
         )
IS
  SELECT   pod.po_distribution_id,
      pod.set_of_books_id,
      pod.code_combination_id,
      DECODE(gcc.account_type, 'A','Y','N') assets_tracking_flag,
      NVL(pod.quantity_ordered,0) quantity_remaining,
      NVL(pod.amount_ordered,0) amount_remaining,
      pod.rate,
      pod.rate_date,
      pod.variance_account_id,
      pod.attribute_category,
      pod.attribute1,
      pod.attribute2,
      pod.attribute3,
      pod.attribute4,
      pod.attribute5,
      pod.attribute6,
      pod.attribute7,
      pod.attribute8,
      pod.attribute9,
      pod.attribute10,
      pod.attribute11,
      pod.attribute12,
      pod.attribute13,
      pod.attribute14,
      pod.attribute15,
      pod.project_id,   -- the following are PA related columns
      pod.task_id,
      pod.expenditure_item_date,
      pod.expenditure_type,
      pod.expenditure_organization_id,
      pod.project_accounting_context,
           pod.recovery_rate
  FROM     gl_code_combinations    gcc,
    --  po_distributions_ap_v   pod   bug 17933077 change it to po_distributions_all
        po_distributions_all   pod
  WHERE    pod.po_header_id        = X_po_header_id
  AND      pod.po_line_id          = X_po_line_id
  AND      pod.line_location_id    = X_po_line_location_id
  AND    pod.code_combination_id = gcc.code_combination_id
  AND      pod.po_distribution_id  = X_po_distribution_id
  ORDER BY pod.distribution_num;


/**** Variable declarations ****/

/*  Bug 3338268 */
x_pod_distribution_id                po_distributions.po_distribution_id%TYPE    := NULL;
x_pod_set_of_books_id                po_distributions.set_of_books_id%TYPE    := NULL;
x_pod_code_combinations_id           po_distributions.code_combination_id%TYPE      := NULL;
x_pod_assets_tracking_flag           VARCHAR2(1)               := NULL;
x_pod_quantity_remaining             po_distributions.quantity_ordered%TYPE      := NULL;
x_pod_amount_remaining               po_distributions.amount_ordered%TYPE     := NULL;
x_pod_rate                           po_distributions.rate%TYPE            := NULL;
x_pod_rate_date                      po_distributions.rate_date%TYPE       := NULL;
x_pod_variance_account_id            po_distributions.variance_account_id%TYPE      := NULL;
x_pod_attribute_category             po_distributions.attribute_category%TYPE    := NULL;
x_pod_attribute1                     po_distributions.attribute1%TYPE         := NULL;
x_pod_attribute2                     po_distributions.attribute2%TYPE         := NULL;
x_pod_attribute3                     po_distributions.attribute3%TYPE         := NULL;
x_pod_attribute4                     po_distributions.attribute4%TYPE         := NULL;
x_pod_attribute5                     po_distributions.attribute5%TYPE         := NULL;
x_pod_attribute6                     po_distributions.attribute6%TYPE         := NULL;
x_pod_attribute7                     po_distributions.attribute7%TYPE         := NULL;
x_pod_attribute8                     po_distributions.attribute8%TYPE         := NULL;
x_pod_attribute9                     po_distributions.attribute9%TYPE         := NULL;
x_pod_attribute10                    po_distributions.attribute10%TYPE        := NULL;
x_pod_attribute11                    po_distributions.attribute11%TYPE        := NULL;
x_pod_attribute12                    po_distributions.attribute12%TYPE        := NULL;
x_pod_attribute13                    po_distributions.attribute13%TYPE        := NULL;
x_pod_attribute14                    po_distributions.attribute14%TYPE        := NULL;
x_pod_attribute15                    po_distributions.attribute15%TYPE        := NULL;
x_pod_project_id                     po_distributions.project_id%TYPE         := NULL;
x_pod_task_id                        po_distributions.task_id%TYPE         := NULL;
x_pod_expenditure_item_date          po_distributions.expenditure_item_date%TYPE := NULL;
x_pod_expenditure_type               po_distributions.expenditure_type%TYPE      := NULL;
x_pod_expenditure_org_id             po_distributions.expenditure_organization_id%TYPE := NULL;
x_pod_proj_accounting_context        po_distributions.project_accounting_context%TYPE  := NULL;
/* End Bug 3338268 */
/* Bug3875677 */
x_pod_recovery_rate                  po_distributions.recovery_rate%TYPE           := NULL;

X_rowid                VARCHAR2(50);
X_po_distributions     c_po_distributions%ROWTYPE;

X_invoice_distribution_id NUMBER;

X_curr_qty             NUMBER;      /*Qty billed to a particular dist*/
X_curr_amount         NUMBER;
X_sum_order_qty        NUMBER;      /*Used when proration is used*/
X_sum_order_amt        NUMBER;

/* nwang 5/13/1999 */

X_count                NUMBER:=0;   /*Num of distrs for that receive txn*/
X_tmp_count            NUMBER;
X_total_amount        NUMBER;
X_amount_running_total    NUMBER;
X_assets_addition_flag VARCHAR2(1);

X_new_dist_line_number ap_invoice_distributions.distribution_line_number%TYPE;
X_base_amount     NUMBER;

X_conversion_rate NUMBER;        -- This is the rate based of match option.
X_conversion_rate_date  DATE;

X_progress     VARCHAR2(3) := '';
x_invoice_line_id NUMBER;
X_line_count      NUMBER;
x_org_id                NUMBER;        --Bug# 2492041

/*Bug: 5125624*/
l_ship_to_location_id PO_LINE_LOCATIONS.SHIP_TO_LOCATION_ID%TYPE;
l_tax_classification_code VARCHAR2(30);
x_invoiced_quantity NUMBER :=0; -- Added for bug 6822594
x_invoiced_unit_price NUMBER :=0; -- Added for bug 6822594
X_invoiced_amount NUMBER :=0;  -- Added for bug 6822594
x_item_id  po_lines_all.item_id%type ;   -- Added for bug 6822594
x_po_uom po_lines_all.unit_meas_lookup_code%type;   -- Added for bug 6822594
X_conversion_factor NUMBER :=0; -- Added for bug 6822594
l_rcv_transaction_id NUMBER := X_rcv_transaction_id;--bug 17972946

BEGIN
 IF (g_asn_debug = 'Y') THEN
    asn_debug.put_line('Begin Create Invoice Distributions ');

    /* PoR with LCM project Begin */
    asn_debug.put_line('X_quantity: '||X_quantity);
    asn_debug.put_line('X_unit_price: '||X_unit_price);
    asn_debug.put_line('X_exchange_rate_type: '||X_exchange_rate_type);
    asn_debug.put_line('X_exchange_date: '||X_exchange_date);
    asn_debug.put_line('X_exchange_rate: '||X_exchange_rate);
    asn_debug.put_line('X_invoice_date: '||X_invoice_date);
    asn_debug.put_line('X_receipt_date: '||X_receipt_date);
    asn_debug.put_line('X_vendor_income_tax_region: '||X_vendor_income_tax_region);
    asn_debug.put_line('X_reference_1: '||X_reference_1);
    asn_debug.put_line('X_reference_2: '||X_reference_2);
    asn_debug.put_line('X_awt_flag: '||X_awt_flag);
    asn_debug.put_line('X_awt_group_id: '||X_awt_group_id);
    asn_debug.put_line('X_accounting_date: '||X_accounting_date);
    asn_debug.put_line('X_period_name: '||X_period_name);
    asn_debug.put_line('X_transaction_type: '||X_transaction_type);
    asn_debug.put_line('X_unique_id: '||X_unique_id);
    asn_debug.put_line('X_curr_invoice_amount: '||X_curr_invoice_amount);
    asn_debug.put_line('X_curr_inv_process_flag: '||X_curr_inv_process_flag);
    asn_debug.put_line('X_receipt_num: '||X_receipt_num);
    asn_debug.put_line('X_rcv_transaction_id: '||X_rcv_transaction_id);
    asn_debug.put_line('X_match_option: '||X_match_option);
    asn_debug.put_line('X_amount: '||X_amount);
    asn_debug.put_line('X_matching_basis: '||X_matching_basis);
    asn_debug.put_line('X_unit_meas_lookup_code: '||X_unit_meas_lookup_code);
    asn_debug.put_line('X_invoice_currency_code: '||X_invoice_currency_code);
    asn_debug.put_line('X_base_currency_code: '||X_base_currency_code);
    asn_debug.put_line('X_transaction_type: '||X_transaction_type);
    asn_debug.put_line('X_receipt_event: '||X_receipt_event);
    asn_debug.put_line('X_lcm_shipment_line_id: '||X_lcm_shipment_line_id);
    /* PoR with LCM project End */
 END IF;

 /********************
     The algorithm for proration is as follows:
     Suppose there are 1..N distributions that need to be prorated.
     Sum of all the N distributions need to be prorated.
     Sum of all the N distribution qtys = X_total_qty
     Qty to be prorated = X_qty

     Then   for i = 1..N-1 prorated_qty(i) = X_qty*distribution_qty(i)/
                         X_total_qty
       for i = N (the last distribution)prorated_qty(i) = X_qty-
                     SUM(prorated_qty from q to N-1)

     In this way, the last distribution will handle any rounding errors
     which might occur.
 *********************/

 /***Find out how many distribution records and total ordered qty that
     need to be prorated.***/

 X_progress := '010';

 /* Fix for bug 3050752.
    Getting tax rounding rule from po_vendor_sites for the
    associated PO vendor site.
 */


 SELECT     COUNT(*),
       SUM(NVL(quantity_ordered,0)),
       SUM(NVL(amount_ordered,0))
          /***Amount remaining for each po distribution***/
 INTO       X_count,
       X_sum_order_qty,
       X_sum_order_amt
 FROM       po_distributions
 WHERE      po_header_id        = X_po_header_id
 AND        po_line_id          = X_po_line_id
 AND        line_location_id = X_po_line_location_id
 AND        DECODE(X_receipt_event, 'DELIVER', po_distribution_id,1)=
       DECODE(X_receipt_event, 'DELIVER', X_po_distribution_id,1);

 /* Removed the fix of 2379414 as it is already commented */

/* PoR with LCM project Begin */
IF (g_asn_debug = 'Y') THEN
   asn_debug.put_line('X_sum_order_qty: '||X_sum_order_qty);
   asn_debug.put_line('X_sum_order_amt: '||X_sum_order_amt);
END IF;
/* PoR with LCM project End */

IF (X_count > 0) THEN

   X_progress := '020';

   IF X_matching_basis = 'AMOUNT' THEN
      X_total_amount := X_amount;
   ELSE
      X_total_amount := ap_utilities_pkg.ap_round_currency(
            X_quantity * X_unit_price,
            X_invoice_currency_code);
   END IF;

   X_tmp_count             := 0;
   X_amount_running_total  := 0;

   X_progress := '030';


   --Bug 3338268 call only if x_receipt_event='DELIVER', remove x_receipt_event, fetch only one record
   IF (x_receipt_event = 'DELIVER') THEN
     OPEN  c_po_distributions(X_po_header_id,
                              X_po_line_id,
                              X_po_line_location_id,
                              X_po_distribution_id
                             );
     FETCH c_po_distributions INTO
       x_pod_distribution_id,
       x_pod_set_of_books_id,
       x_pod_code_combinations_id,
       x_pod_assets_tracking_flag,
       x_pod_quantity_remaining,
       x_pod_amount_remaining,
       x_pod_rate,
       x_pod_rate_date,
       x_pod_variance_account_id,
       x_pod_attribute_category,
       x_pod_attribute1,
       x_pod_attribute2,
       x_pod_attribute3,
       x_pod_attribute4,
       x_pod_attribute5,
       x_pod_attribute6,
       x_pod_attribute7,
       x_pod_attribute8,
       x_pod_attribute9,
       x_pod_attribute10,
       x_pod_attribute11,
       x_pod_attribute12,
       x_pod_attribute13,
       x_pod_attribute14,
       x_pod_attribute15,
       x_pod_project_id,
       x_pod_task_id,
       x_pod_expenditure_item_date,
       x_pod_expenditure_type,
       x_pod_expenditure_org_id,
       x_pod_proj_accounting_context,
       x_pod_recovery_rate;
     CLOSE c_po_distributions;

     /* Bug3493515 (3) - Start */
     IF X_matching_basis = 'AMOUNT' THEN
        X_curr_amount:= (X_amount   * X_pod_amount_remaining  )/X_sum_order_amt;
     ELSE
        X_curr_qty   := (X_quantity * X_pod_quantity_remaining)/X_sum_order_qty;
     END IF;
     /* Bug3493515 (3) - End */

   ELSE
     x_curr_amount := x_amount;
     x_curr_qty := x_quantity;
   END IF;

   /* PoR with LCM project Begin */
   IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('x_curr_amount: '||x_curr_amount);
      asn_debug.put_line('x_curr_qty: '||x_curr_qty);
   END IF;
   /* PoR with LCM project End */

      X_progress := '085';
   /*Bug#2492041 Get the Operating Unit for the PO */
   select org_id
   into   x_org_id
   from   po_headers_all
   where  po_header_id = X_po_header_id;

   --Bug 3338268 - remove line item amt and qty calculations
      X_progress := '100';

      IF X_matching_basis <> 'AMOUNT' THEN
        X_curr_amount := ap_utilities_pkg.ap_round_currency(
             X_curr_qty * X_unit_price,
             X_invoice_currency_code);
	  /*begin of bug 17372832,to round the amount*/
	  ELSIF X_matching_basis='AMOUNT' THEN
	    X_curr_amount := ap_utilities_pkg.ap_round_currency(X_curr_amount,X_invoice_currency_code);
	  /*end of bug 17372832*/
      END IF;

      /* PoR with LCM project Begin */
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('x_curr_amount: '||x_curr_amount);
         asn_debug.put_line('x_curr_qty: '||x_curr_qty);
         asn_debug.put_line('X_conversion_rate: '||X_conversion_rate);
      END IF;
      /* PoR with LCM project End */

      X_progress := '140';

      IF (X_curr_inv_process_flag = 'Y') THEN
   /** continue only if invoice is still processable **/

      X_progress := '160';

   IF (X_invoice_currency_code = X_base_currency_code) THEN
      X_base_amount := NULL;
   ELSE
      X_base_amount := ap_utilities_pkg.ap_round_currency(
                  X_curr_amount * X_conversion_rate,
                  X_base_currency_code);
   END IF;

   /* PoR with LCM project Begin*/
   IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('X_base_amount: '||X_base_amount);
   END IF;
   /* PoR with LCM project End */

         /*** call object handler to create the item distributions ***/
         X_progress := '140';

   IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('Creating Item Distribution...');
   END IF;


     SELECT NVL(MAX(line_number), 0) + 1
     INTO    X_line_count
     FROM    ap_invoice_lines_interface
     WHERE   invoice_id = x_invoice_id;

    select ap_invoice_lines_interface_s.nextval
    into   x_invoice_line_id
    from   sys.dual;

   /* Bug 1374789: We should not pass project_id and task_id
   ** to AP bas for some reason the AP import program fails
   ** with inconsistent distribution info error.
   ** This is being removed based on APs suggestion.
   ** PROJECT_ID, TASK_ID,
   ** x_po_distributions.project_id, x_po_distributions.task_id,
   */

   /* Bug 2664078 - Since the accounting date is passed as the invoice date
      the Payables Open Interface import program is no considering the
      gl date basis. */

    -- Bug 3338268 - Use variables instead of record
    /*Bug: 5125624*/
    l_ship_to_location_id     := get_ship_to_location_id(x_po_line_location_id);
    l_tax_classification_code := get_tax_classification_code(x_po_header_id,x_po_line_location_id,'PURCHASE_ORDER');

    /* Bug 6822594
    * Description: Passing the Received qty,unit price,amount in Receipt UOM
      ncase if match option = 'Receipt' on PO shipment and in PO UOM incase of
      match option = 'PO'.
    */

  		--Move it out of the following If condition to get item_id for bug 7658186
       SELECT item_id,UNIT_MEAS_LOOKUP_CODE
       INTO x_item_id , x_po_uom
       FROM po_lines_all
       WHERE PO_LINE_ID = X_po_line_id;

     -- Bug 9558069  - adding condition to exclude amount basised
     IF X_match_option = 'R' AND X_matching_basis <> 'AMOUNT'
     THEN
       /*Move it out of If condition to get item_id for bug 7658186
       SELECT item_id,UNIT_MEAS_LOOKUP_CODE
       INTO x_item_id , x_po_uom
       FROM po_lines_all
       WHERE PO_LINE_ID = X_po_line_id;*/

     X_invoiced_quantity := X_quantity;


     IF (X_lcm_shipment_line_id is null) THEN -- PoR with LCM project
     -- Quantity in Receipt uom
        X_conversion_factor := po_uom_s.po_uom_convert(X_unit_meas_lookup_code,
                                                       X_po_uom,
                                                       X_item_id);
     /* PoR with LCM project Begin */
     ELSE
        X_conversion_factor := 1;
     END IF;
     /* PoR with LCM project End */

     -- UOM conversion factor
     X_invoiced_unit_price := X_conversion_factor * X_unit_price;
     -- PO unit price in receipt uom
     x_invoiced_amount := ap_utilities_pkg.ap_round_currency(
                                                      X_invoiced_quantity * X_invoiced_unit_price,
                                                      X_invoice_currency_code);
     -- Amount in Receipt uom.
     -- Bug 9558069  - adding condition to include amount basised
     ELSIF X_match_option = 'P' OR X_matching_basis = 'AMOUNT'
     THEN
     X_invoiced_quantity := X_curr_qty;
     X_invoiced_amount := X_curr_amount;
     X_invoiced_unit_price := X_unit_price ;
     END IF;

     /* PoR with LCM project Begin */
     IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('X_invoiced_quantity: '||X_invoiced_quantity);
        asn_debug.put_line('X_conversion_factor: '||X_conversion_factor);
        asn_debug.put_line('X_invoiced_unit_price: '||X_invoiced_unit_price);
        asn_debug.put_line('x_invoiced_amount: '||x_invoiced_amount);
     END IF;
     /* PoR with LCM project End */
     --bug 17972946 begin
     if(X_matching_basis = 'AMOUNT') then
     	 select decode(transaction_type, 'CORRECT', parent_transaction_id, transaction_id)
     	 into   l_rcv_transaction_id
     	 from   rcv_transactions
     	 where  transaction_id = x_rcv_transaction_id;
     end if;
     --bug 17972946 end

   insert into ap_invoice_lines_interface
      (INVOICE_ID,
       INVOICE_LINE_ID,
       LINE_NUMBER,
       LINE_TYPE_LOOKUP_CODE,
       AMOUNT,
      -- ACCOUNTING_DATE,  Bug 2664078
       DESCRIPTION,
       TAX_CODE_ID,
       AMOUNT_INCLUDES_TAX_FLAG,
       -- DIST_CODE_COMBINATION_ID,
       PO_HEADER_ID,
       PO_LINE_ID,
       PO_LINE_LOCATION_ID,
       PO_DISTRIBUTION_ID,
       PO_RELEASE_ID,
       QUANTITY_INVOICED,
       --EXPENDITURE_ITEM_DATE, --bug 12976830
       --EXPENDITURE_TYPE, --bug 12976830
       --EXPENDITURE_ORGANIZATION_ID, --bug 12976830
       --PROJECT_ACCOUNTING_CONTEXT, --bug 12976830
       PA_QUANTITY,
       --PA_ADDITION_FLAG, --bug 12976830
       UNIT_PRICE,
       ASSETS_TRACKING_FLAG,
       ATTRIBUTE_CATEGORY,
       ATTRIBUTE1,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       MATCH_OPTION,
       RCV_TRANSACTION_ID,
       RECEIPT_NUMBER,
       TAX_CODE_OVERRIDE_FLAG, -- Bug 921579, PO needs to pass 'Y' for this
       ORG_ID,                 -- Bug#2492041
       TAX_RECOVERY_RATE, -- Bug 3875677
       UNIT_OF_MEAS_LOOKUP_CODE, -- 5100177
       SHIP_TO_LOCATION_ID, --Bug: 5125624
       TAX_CLASSIFICATION_CODE,   --Bug: 5125624
       INVENTORY_ITEM_ID,   --Bug: 7614092
       ITEM_DESCRIPTION   --Bug: 7614092
       ) VALUES
          (x_invoice_id,
           x_invoice_line_id,
           x_line_count,
           'ITEM',
           X_invoiced_amount, --X_curr_amount, for bug 6822594
           --x_invoice_date,  Bug  2664078
           x_item_description,
           x_tax_code_id,
           NULL,
           -- x_po_distributions.code_combination_id,
       x_po_header_id,
       x_po_line_id,
       x_po_line_location_id,
       x_pod_distribution_id,
       x_po_release_id,
       X_invoiced_quantity, -- x_curr_qty,--X_curr_amount, for bug 6822594
       --x_pod_expenditure_item_date, --bug 12976830
       --x_pod_expenditure_type, --bug 12976830
       --x_pod_expenditure_org_id, --bug 12976830
       --x_pod_proj_accounting_context, --bug 12976830
       X_invoiced_quantity, -- x_curr_qty, for bug 6822594
       --'N', --bug 12976830
       X_invoiced_unit_price, --x_unit_price,bug 6822594
       x_pod_assets_tracking_flag,
       x_pod_attribute_CATEGORY,
       x_pod_attribute1,
       x_pod_attribute2,
       x_pod_attribute3,
       x_pod_attribute4,
       x_pod_attribute5,
       x_pod_attribute6,
       x_pod_attribute7,
       x_pod_attribute8,
       x_pod_attribute9,
       x_pod_attribute10,
       x_pod_attribute11,
       x_pod_attribute12,
       x_pod_attribute13,
       x_pod_attribute14,
       x_pod_attribute15,
       x_match_option,
       l_rcv_transaction_id, --x_rcv_transaction_id, bug 17972946
       x_receipt_num,
       'Y',    -- bug 921579, PO needs to pass 'Y' for this
       x_org_id,
       x_pod_recovery_rate,
       X_unit_meas_lookup_code, -- 5100177
       l_ship_to_location_id,
       l_tax_classification_code,
       x_item_id,
       x_item_description
       );


         /**UPDATE CURRENT INVOICE AMOUNT**/
         X_progress := '150';
         X_curr_invoice_amount:= X_curr_invoice_amount +
                     X_invoiced_amount ;   -- 6822594

   END IF; -- X_curr_inv_process_flag

   X_progress := '180';

ELSE /** X_count = 0, this should be an error we should have atleast one
            distribution for our rcv. txn.**/

       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('->Error: No distr available.');
       END IF;
         po_interface_errors_sv1.handle_interface_errors(
            X_transaction_type,
                                'FATAL',
             X_batch_id,
             X_unique_id,   -- header_id
             NULL,      -- line_id
             'PO_INV_CR_NO_DISTR',
             'PO_DISTRIBUTIONS',
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
             X_curr_inv_process_flag);
END IF;

EXCEPTION
WHEN others THEN
       po_message_s.sql_error('create_invoice_distributions', X_progress,
            sqlcode);
       RAISE;
END create_invoice_distributions;


/* <PAY ON USE FPI START> */

/*******************************************************
 * PROCEDURE create_use_invoices
 *******************************************************/
PROCEDURE create_use_invoices(
    p_api_version       IN  NUMBER,
    x_return_status     OUT NOCOPY  VARCHAR2,
    p_commit_interval   IN  NUMBER,
    p_aging_period      IN  NUMBER)
IS
    l_api_version CONSTANT NUMBER := 1.0;
    l_api_name CONSTANT VARCHAR2(50) := 'create_use_invoices';

    l_consumption   PO_INVOICES_SV2.consump_rec_type;
    l_ap_inv_header PO_INVOICES_SV2.invoice_header_rec_type;
    l_curr PO_INVOICES_SV2.curr_condition_rec_type;

    l_commit_lower NUMBER;
    l_commit_upper NUMBER;
    l_header_idx NUMBER := 0;
    l_invoice_count NUMBER := 0;
    l_distr_count NUMBER := 0;
    l_first_flag VARCHAR2(1) := FND_API.G_TRUE;

    l_aging_period NUMBER;
    l_cutoff_date DATE;
    l_def_base_currency_code ap_system_parameters.base_currency_code%TYPE;
    l_org_id                po_headers.org_id%TYPE;
    l_invoice_desc          ap_invoices_interface.description%TYPE;

    l_group_id ap_invoices_interface.group_id%TYPE;
    l_user_id NUMBER;
    l_login_id NUMBER;
    l_tmp_batch_id NUMBER;
    l_batch_name ap_batches.batch_name%TYPE;
    l_request_id ap_invoices_interface.request_id%TYPE;

    l_error_msg VARCHAR2(2000);
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_progress VARCHAR2(3);
BEGIN
    l_progress := '000';

    IF (g_asn_debug = 'Y') THEN
       ASN_DEBUG.put_line('Enter create use invoices');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF NOT FND_API.Compatible_API_Call (
                    l_api_version,
               p_api_version,
               l_api_name,
               g_pkg_name)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF; -- check api version compatibility

    IF (g_asn_debug = 'Y') THEN
       ASN_DEBUG.put_line('API Version Check is passed');
    END IF;

    l_progress := '010';

    IF (g_asn_debug = 'Y') THEN
       ASN_DEBUG.put_line('Aging period passing in = ' || p_aging_period);
    END IF;

    IF (p_aging_period IS NULL) THEN

        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line('Getting aging period from profile');
        END IF;

        l_aging_period :=
            NVL(FLOOR(TO_NUMBER(FND_PROFILE.VALUE('AGING_PERIOD'))), 0);

        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line('After getting aging period from profile,
                               aging period = ' || l_aging_period);
        END IF;

        IF (l_aging_period < 0) THEN
            l_aging_period := 0;
        END IF;
    ELSE
        l_aging_period := p_aging_period;
    END IF; -- p_aging_period IS NULL

    l_cutoff_date := TRUNC(SYSDATE) + 1 - l_aging_period;

    IF (g_asn_debug = 'Y') THEN
       ASN_DEBUG.put_line('Aging Period = ' || l_aging_period ||
                           ' Cutoff Date = ' || l_cutoff_date);
    END IF;

    l_progress := '020';

    -- get base currency
    SELECT base_currency_code
    INTO   l_def_base_currency_code
    FROM   ap_system_parameters;

    IF (g_asn_debug = 'Y') THEN
       ASN_DEBUG.put_line('Base Currency Code = ' || l_def_base_currency_code);
    END IF;

    OPEN PO_INVOICES_SV2.c_consumption(l_cutoff_date);

    IF (g_asn_debug = 'Y') THEN
       ASN_DEBUG.put_line('Using Bulk Collect. Limit = ' || g_fetch_size);
    END IF;

    LOOP
        l_progress := '030';

        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line('In Outer Loop');
        END IF;

        l_commit_lower := 1;
        l_commit_upper := 0;

        FETCH c_consumption
        BULK COLLECT INTO   l_consumption.po_header_id,
                            l_consumption.po_release_id,
                            l_consumption.po_line_id,
                            l_consumption.line_location_id,
                            l_consumption.po_distribution_id,
                            l_consumption.vendor_id,
                            l_consumption.pay_on_receipt_summary_code,
                            l_consumption.vendor_site_id,
                            l_consumption.default_pay_site_id,
                            l_consumption.item_id,--bug7658186
                            l_consumption.item_description,
                            l_consumption.unit_price,
                            l_consumption.quantity_ordered,
                            l_consumption.quantity_billed,
                            l_consumption.currency_code,
                            l_consumption.currency_conversion_type,
                            l_consumption.currency_conversion_rate,
                            l_consumption.currency_conversion_date,
                            l_consumption.payment_currency_code,
                            l_consumption.creation_date,
                            l_consumption.payment_terms_id,
                            l_consumption.tax_code_id,
                            l_consumption.org_id,
			    l_consumption.unit_meas_lookup_code
        LIMIT g_fetch_size;

        l_progress := '040';
        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line('After Bulk Collect. Fetched ' ||
                               l_consumption.po_header_id.COUNT || ' records');
        END IF;

        FOR i IN 1..l_consumption.po_header_id.COUNT LOOP

            IF (g_asn_debug = 'Y') THEN
               ASN_DEBUG.put_line('In Inner Loop. i = ' || i);
            END IF;

            IF (l_first_flag = FND_API.G_TRUE) THEN
                l_progress := '050';

                l_first_flag := FND_API.G_FALSE;

                IF (g_asn_debug = 'Y') THEN
                   ASN_DEBUG.put_line('First Record.');
                END IF;

                l_org_id := l_consumption.org_id(i);

                -- get group id
                SELECT 'USE-' || ap_interface_groups_s.nextval
                INTO   l_group_id
                FROM   sys.dual;

                IF (g_asn_debug = 'Y') THEN
                   ASN_DEBUG.put_line('group_id = ' || l_group_id);
                END IF;

                -- get invoice description
                FND_MESSAGE.set_name('PO', 'PO_INV_CR_USE_INVOICE_DESC');
                FND_MESSAGE.set_token('RUN_DATE', sysdate);
                l_invoice_desc := FND_MESSAGE.get;

                IF (g_asn_debug = 'Y') THEN
                   ASN_DEBUG.put_line('invoice_desc = ' || l_invoice_desc);
                END IF;
                PO_INVOICES_SV2.reset_header_values(
                    l_return_status,
                    l_consumption,
                    i,
                    l_curr);

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                IF (g_asn_debug = 'Y') THEN
                   ASN_DEBUG.put_line('Done Initializing Header variables.');
                END IF;

            END IF; -- l_first_flag = FND_API.G_TRUE

            IF (PO_INVOICES_SV2.need_new_invoice(
                    l_return_status,
                    l_consumption,
                    i,
                    l_curr,
                    l_def_base_currency_code) = FND_API.G_TRUE)
            THEN
                l_progress := '060';

                l_header_idx := l_header_idx + 1;

                IF (g_asn_debug = 'Y') THEN
                   ASN_DEBUG.put_line('Invoice header needs to be created for ' ||
                                       'previous records.');
                END IF;

                IF (g_asn_debug = 'Y') THEN
                   ASN_DEBUG.put_line('# of lines for this invoice = ' ||
                                       l_distr_count);
                END IF;

                l_progress := '065';

                PO_INVOICES_SV2.store_header_info(
                    l_return_status,
                    l_curr,
                    l_invoice_desc,
                    l_group_id,
                    l_org_id,
                    l_ap_inv_header,
                    l_header_idx);

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                IF (g_asn_debug = 'Y') THEN
                   ASN_DEBUG.put_line('Stored Header Information into table');
                END IF;

                l_distr_count := 0;
                l_invoice_count := l_invoice_count + 1;

                PO_INVOICES_SV2.reset_header_values(
                    l_return_status,
                    l_consumption,
                    i,
                    l_curr);

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                IF (g_asn_debug = 'Y') THEN
                   ASN_DEBUG.put_line('Done Resetting Header Variables');
                   ASN_DEBUG.put_line('# of headers created after last commit= ' ||
                                       l_header_idx || ' Commit interval= ' ||
                                       p_commit_interval);
                END IF;

                IF (l_header_idx = p_commit_interval) THEN
                    -- As we have reached the commit interval, all records
                    -- created so far needs to be inserted and committed.

                    l_progress := '070';

                    IF (g_asn_debug = 'Y') THEN
                       ASN_DEBUG.put_line('Bulk Insert into header interface');
                    END IF;

                    PO_INVOICES_SV2.create_invoice_hdr(
                        l_return_status,
                        l_ap_inv_header,
                        1,
                        l_header_idx);

                    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                    l_progress := '073';

                    IF (g_asn_debug = 'Y') THEN
                       ASN_DEBUG.put_line('Bulk Insert into line interface');
                    END IF;

                    PO_INVOICES_SV2.create_invoice_distr(
                        l_return_status,
                        l_consumption,
                        l_commit_lower,
                        l_commit_upper);

                    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                    l_progress := '076';

                    l_commit_lower := l_commit_upper + 1;
                    l_header_idx := 0;
                    COMMIT;

                    l_progress := '080';
                    IF (g_asn_debug = 'Y') THEN
                       ASN_DEBUG.put_line('After commit');
                    END IF;

                END IF; -- l_header_idx = p_commit_interval

            END IF; -- PO_INVOICES_SV2.need_new_invoice

            -- This if is to check the return value of need_new_invoice
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            l_progress := '090';
            IF (g_asn_debug = 'Y') THEN
               ASN_DEBUG.put_line('Deriving more line information');
            END IF;

            l_distr_count := l_distr_count + 1;

            l_consumption.invoice_line_number(i) := l_distr_count;
            l_consumption.invoice_id(i) := l_curr.invoice_id;

            l_consumption.quantity_invoiced(i) :=
                                l_consumption.quantity_ordered(i) -
                                l_consumption.quantity_billed(i);

            IF (g_asn_debug = 'Y') THEN
               ASN_DEBUG.put_line('po_distribution_id = ' ||
                               l_consumption.po_distribution_id(i) ||
                               'Quantity to invoice = ' ||
                               l_consumption.quantity_invoiced(i));
            END IF;

            PO_INVOICES_SV2.calc_consumption_cost(
                l_return_status,
                l_consumption.quantity_invoiced(i),
                l_consumption.unit_price(i),
                l_consumption.tax_code_id(i),
                l_consumption.currency_code(i),
                l_consumption.invoice_line_amount(i),
                l_curr.invoice_amount);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (g_asn_debug = 'Y') THEN
               ASN_DEBUG.put_line('line_amount = ' ||
                                   l_consumption.invoice_line_amount(i));
               ASN_DEBUG.put_line('Cumu. Invoive amt = '||l_curr.invoice_amount);
            END IF;

            l_commit_upper := l_commit_upper + 1;

-- bug2786193
-- We now use sysdate as the invoice date so no need to update
-- it everytime

            -- l_curr.invoice_date := l_consumption.creation_date(i);


            IF (g_asn_debug = 'Y') THEN
               ASN_DEBUG.put_line('-*-*-*-*-*- Done with one line -*-*-*-*-*-');
            END IF;
        END LOOP; -- for i in 1.. po_header_id.count

        l_progress := '100';

        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line('Exit inner loop');
        END IF;

        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line('Insert remaining distributions from pl/sql table'
                               || ' to lines interface table');
        END IF;

        PO_INVOICES_SV2.create_invoice_distr(
            l_return_status,
            l_consumption,
            l_commit_lower,
            l_commit_upper);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        EXIT WHEN c_consumption%NOTFOUND;

    END LOOP; -- loop for bulk fetching consumption advice

    l_progress := '110';
    IF (g_asn_debug = 'Y') THEN
       ASN_DEBUG.put_line('Exit outer loop');
    END IF;

    IF c_consumption%ISOPEN THEN
        CLOSE c_consumption;
    END IF;

    IF (l_distr_count > 0) THEN
        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line('l_distr_count = ' || l_distr_count || '. Need to' ||
                               ' perform some clean up work.');
        END IF;

        l_header_idx := l_header_idx + 1;

        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line('# of headers created after last commit= ' ||
                                       l_header_idx);
        END IF;

        PO_INVOICES_SV2.store_header_info(
            l_return_status,
            l_curr,
            l_invoice_desc,
            l_group_id,
            l_org_id,
            l_ap_inv_header,
            l_header_idx);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_progress := '120';
        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line('Insert remaining invoice headers');
        END IF;

        PO_INVOICES_SV2.create_invoice_hdr(
            l_return_status,
            l_ap_inv_header,
            1,
            l_header_idx);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        COMMIT;

        l_progress := '130';
        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line('Call invoice import program');
        END IF;

        SELECT ap_batches_s.nextval
        INTO   l_tmp_batch_id
        FROM   sys.dual;

        FND_MESSAGE.set_name('PO', 'PO_INV_CR_USE_BATCH_DESC');
        l_batch_name := FND_MESSAGE.get || '/' || TO_CHAR(sysdate) ||
                        '/' || TO_CHAR(l_tmp_batch_id);

        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line('Batch name = ' || l_batch_name);
        END IF;

        l_user_id := NULL;
        l_login_id := NULL;

        PO_INVOICES_SV1.submit_invoice_import(
            l_return_status,
            'USE',
            l_group_id,
            l_batch_name,
            l_user_id,
            l_login_id,
            l_request_id);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_progress := '140';

        FND_MESSAGE.set_name('PO', 'PO_ERS_CONC_REQUEST_CHECK');
   FND_MESSAGE.set_token('REQUEST', TO_CHAR(l_request_id));
   FND_MESSAGE.set_token('BATCH', l_batch_name);
   IF (g_asn_debug = 'Y') THEN
      ASN_DEBUG.put_line(FND_MESSAGE.get);
   END IF;

    END IF; -- l_distr_count > 0

    IF (g_asn_debug = 'Y') THEN
       ASN_DEBUG.put_line('Exit create_use_invoices');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
        l_error_msg := FND_MSG_PUB.get(p_encoded => 'F');
        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line(l_api_name || '-' || l_progress);
           ASN_DEBUG.put_line(l_error_msg);
        END IF;

        IF c_consumption%ISOPEN THEN
            CLOSE c_consumption;
        END IF;

        ROLLBACK;

        PO_INVOICES_SV1.delete_interface_records(
            l_return_status,
            l_group_id);
        COMMIT;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        l_error_msg := FND_MSG_PUB.get(p_encoded => 'F');
        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line(l_api_name || '-' || l_progress);
           ASN_DEBUG.put_line(l_error_msg);
        END IF;

        IF c_consumption%ISOPEN THEN
            CLOSE c_consumption;
        END IF;

        ROLLBACK;

        PO_INVOICES_SV1.delete_interface_records(
            l_return_status,
            l_group_id);
        COMMIT;
END create_use_invoices;

/*******************************************************
 * FUNCTION need_new_invoice
 *******************************************************/
FUNCTION need_new_invoice (
    x_return_status         OUT NOCOPY VARCHAR2,
    p_consumption           IN PO_INVOICES_SV2.consump_rec_type,
    p_index                 IN NUMBER,
    p_curr                  IN PO_INVOICES_SV2.curr_condition_rec_type,
    p_base_currency_code    IN VARCHAR2) RETURN VARCHAR2
IS
    l_api_name VARCHAR2(50) := 'need_new_invoice';
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- bug2786193
-- Use p_curr structure to reduce number of parameters passed

    IF (p_curr.vendor_id <> p_consumption.vendor_id(p_index)
       OR
        p_curr.pay_site_id <> p_consumption.default_pay_site_id(p_index)
       OR
        p_curr.inv_summary_code <>
            p_consumption.pay_on_receipt_summary_code(p_index)
       OR
        p_curr.currency_code <> p_consumption.currency_code(p_index)
       OR
-- bug2786193
-- to group two lines under same invoice header, rate date and rate type
-- has to match if we are talking about foreign currencies
        (p_consumption.currency_code(p_index) <> p_base_currency_code AND
         (TRUNC(p_curr.conversion_date) <>
             TRUNC(p_consumption.currency_conversion_date(p_index)) OR
          p_curr.conversion_type <>
             p_consumption.currency_conversion_type(p_index)))
       OR
-- bug2786193
-- if currency type is user, make sure that we do not group invoice lines
-- together if they are using different conversion rate
        (p_consumption.currency_conversion_type(p_index) = 'User' AND
         NVL(p_curr.conversion_rate, -1) <>
            p_consumption.currency_conversion_rate(p_index))
       OR
        p_curr.payment_terms_id <> p_consumption.payment_terms_id(p_index)
       OR
        ((p_curr.po_header_id <> p_consumption.po_header_id(p_index) OR
          NVL(p_curr.po_release_id, -1) <>
            NVL(p_consumption.po_release_id(p_index), -1)) AND
          p_consumption.pay_on_receipt_summary_code(p_index) =
            'CONSUMPTION_ADVICE')
       ) THEN

        RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        RETURN FND_API.G_FALSE;
END need_new_invoice;

/*******************************************************
 * PROCEDURE store_header_info
 *******************************************************/
PROCEDURE store_header_info(
    x_return_status     OUT NOCOPY VARCHAR2,
    p_curr              IN  PO_INVOICES_SV2.curr_condition_rec_type,
    p_invoice_desc      IN  VARCHAR2,
    p_group_id          IN  VARCHAR2,
    p_org_id            IN  VARCHAR2,
    x_ap_inv_header     IN OUT NOCOPY PO_INVOICES_SV2.invoice_header_rec_type,
    p_index             IN  NUMBER)
IS
    l_api_name VARCHAR2(50) := 'store_header_info';
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (g_asn_debug = 'Y') THEN
       ASN_DEBUG.put_line('Storing header data into PL/SQL tables');
    END IF;

    x_ap_inv_header.invoice_num(p_index) :=
                                PO_INVOICES_SV2.create_invoice_num(
                                    p_org_id, -- SBI ENH
                                    p_curr.pay_site_id, -- SBI ENH
                                    p_curr.inv_summary_code,
                                    p_curr.invoice_date,
                                    NULL,
                                    NULL,
                                    'USE');

    x_ap_inv_header.invoice_id(p_index) := p_curr.invoice_id;
    x_ap_inv_header.vendor_id(p_index) := p_curr.vendor_id;
    x_ap_inv_header.vendor_site_id(p_index) := p_curr.pay_site_id;
    x_ap_inv_header.invoice_amount(p_index) := p_curr.invoice_amount;
    x_ap_inv_header.invoice_currency_code(p_index) := p_curr.currency_code;
    x_ap_inv_header.invoice_date(p_index) := p_curr.invoice_date;
    x_ap_inv_header.source(p_index) := 'USE';
    x_ap_inv_header.description(p_index) := p_invoice_desc;
    x_ap_inv_header.creation_date(p_index) := sysdate;
    x_ap_inv_header.exchange_rate(p_index) := p_curr.conversion_rate;
    x_ap_inv_header.exchange_rate_type(p_index) := p_curr.conversion_type;
    x_ap_inv_header.exchange_date(p_index) := p_curr.conversion_date;
    x_ap_inv_header.payment_currency_code(p_index) := p_curr.pay_curr_code;
    x_ap_inv_header.terms_id(p_index) := p_curr.payment_terms_id;
    x_ap_inv_header.group_id(p_index) := p_group_id;
    x_ap_inv_header.org_id(p_index) := p_org_id;

    IF (g_asn_debug = 'Y') THEN
       ASN_DEBUG.put_line('Invoice id = ' || x_ap_inv_header.invoice_id(p_index));
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
END store_header_info;

/*******************************************************
 * PROCEDURE reset_header_values
 *******************************************************/
PROCEDURE reset_header_values (
    x_return_status         OUT NOCOPY VARCHAR2,
    p_next_consump          IN PO_INVOICES_SV2.consump_rec_type,
    p_index                 IN NUMBER,
    x_curr                  OUT NOCOPY PO_INVOICES_SV2.curr_condition_rec_type)
IS
    l_api_name VARCHAR2(50) := 'reset_header_values';
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- bug2786193
-- pass in currency_conversion_date instead of creation_date

    IF (GL_CURRENCY_API.is_fixed_rate(
                p_next_consump.payment_currency_code(p_index),
                p_next_consump.currency_code(p_index),
                p_next_consump.currency_conversion_date(p_index)) = 'Y') THEN
        x_curr.pay_curr_code := p_next_consump.payment_currency_code(p_index);
    ELSE
        x_curr.pay_curr_code := p_next_consump.currency_code(p_index);
    END IF; -- GL_CURRENCY_API.is_fixed_rate(...)

    x_curr.invoice_amount := 0;

    SELECT AP_INVOICES_INTERFACE_S.NEXTVAL
    INTO   x_curr.invoice_id
    FROM   SYS.DUAL;

    x_curr.vendor_id := p_next_consump.vendor_id(p_index);
    x_curr.pay_site_id := p_next_consump.default_pay_site_id(p_index);
    x_curr.inv_summary_code :=
                        p_next_consump.pay_on_receipt_summary_code(p_index);
    x_curr.po_header_id := p_next_consump.po_header_id(p_index);
    x_curr.po_release_id := p_next_consump.po_release_id(p_index);
    x_curr.currency_code := p_next_consump.currency_code(p_index);
    x_curr.conversion_type := p_next_consump.currency_conversion_type(p_index);
    x_curr.conversion_date := p_next_consump.currency_conversion_date(p_index);
    x_curr.payment_terms_id := p_next_consump.payment_terms_id(p_index);
    x_curr.creation_date := p_next_consump.creation_date(p_index);

-- bug2786193
-- use sysdate as invoice_date

    x_curr.invoice_date := sysdate;

    IF (p_next_consump.currency_conversion_type(p_index) <> 'User') THEN
        x_curr.conversion_rate := NULL;

-- bug2786193
--        x_curr.conversion_date := x_curr.creation_date;
    ELSE
        x_curr.conversion_rate :=
                p_next_consump.currency_conversion_rate(p_index);

-- bug2786193
--        x_curr.conversion_date :=
--                p_next_consump.currency_conversion_date(p_index);

    END IF;  -- p_next_consump.currency_conversion_type(p_index) <> 'User'
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
END reset_header_values;

/*******************************************************
 * PROCEDURE calc_consumption_cost
 *******************************************************/
PROCEDURE calc_consumption_cost (
    x_return_status         OUT NOCOPY VARCHAR2,
    p_quantity              IN  NUMBER,
    p_unit_price            IN  NUMBER,
    p_tax_code_id           IN  NUMBER,
    p_invoice_currency_code IN  VARCHAR2,
    x_invoice_line_amount   OUT NOCOPY NUMBER,
    x_curr_invoice_amount   IN OUT NOCOPY NUMBER)
IS
    l_api_name VARCHAR2(50) := 'calc_consumption_cost';
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    x_invoice_line_amount := AP_UTILITIES_PKG.ap_round_currency(
                                p_quantity * p_unit_price,
                                p_invoice_currency_code);

    IF (g_asn_debug = 'Y') THEN
       ASN_DEBUG.put_line('line amount = ' || x_invoice_line_amount);
    END IF;

    x_curr_invoice_amount := x_curr_invoice_amount + x_invoice_line_amount;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
END calc_consumption_cost;

/*******************************************************
 * PROCEDURE create_invoice_hdr
 *******************************************************/
PROCEDURE create_invoice_hdr(
    x_return_status OUT NOCOPY VARCHAR2,
    p_ap_inv_header IN PO_INVOICES_SV2.invoice_header_rec_type,
    p_from          IN NUMBER,
    p_to            IN NUMBER)
IS
    l_api_name VARCHAR2(50) := 'create_invoice_hdr';
BEGIN
    SAVEPOINT create_invoice_hdr_sp;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FORALL i IN p_from..p_to
        INSERT INTO ap_invoices_interface(
            invoice_id,
            invoice_num,
            vendor_id,
            vendor_site_id,
            invoice_amount,
            invoice_currency_code,
            invoice_date,
            source,
            description,
            creation_date,
            exchange_rate,
            exchange_rate_type,
            exchange_date,
            payment_currency_code,
            terms_id,
            group_id,
            org_id,
	    calc_tax_during_import_flag, --bug 13555007
            add_tax_to_inv_amt_flag) --bug 13555007
        SELECT
            p_ap_inv_header.invoice_id(i),
            p_ap_inv_header.invoice_num(i),
            p_ap_inv_header.vendor_id(i),
            p_ap_inv_header.vendor_site_id(i),
            p_ap_inv_header.invoice_amount(i),
            p_ap_inv_header.invoice_currency_code(i),
            p_ap_inv_header.invoice_date(i),
            p_ap_inv_header.source(i),
            p_ap_inv_header.description(i),
            p_ap_inv_header.creation_date(i),
            p_ap_inv_header.exchange_rate(i),
            p_ap_inv_header.exchange_rate_type(i),
            p_ap_inv_header.exchange_date(i),
            p_ap_inv_header.payment_currency_code(i),
            p_ap_inv_header.terms_id(i),
            p_ap_inv_header.group_id(i),
            p_ap_inv_header.org_id(i),
	    'Y', --bug 13555007
	    'Y' --bug 13555007
        FROM
            sys.dual;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO create_invoice_hdr_sp;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
END create_invoice_hdr;

/*******************************************************
 * PROCEDURE create_invoice_distr
 *******************************************************/
PROCEDURE create_invoice_distr(
    x_return_status OUT NOCOPY VARCHAR2,
    p_consumption   IN PO_INVOICES_SV2.consump_rec_type,
    p_from          IN NUMBER,
    p_to            IN NUMBER)
IS
    l_api_name VARCHAR2(50) := 'create_invoice_distr';
    i NUMBER;

    /*Bug: 5125624*/
    l_ship_to_location_id PO_LINE_LOCATIONS.SHIP_TO_LOCATION_ID%TYPE;
    l_tax_classification_code VARCHAR2(30);

BEGIN
    SAVEPOINT create_invoice_distr_sp;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Bug 5100177.
     * Match option is hard coded to P. So populate
     * unit_of_meas_lookup_code to poll.unit_meas_lookup_code.
    */
    FOR i IN p_from..p_to LOOP

        /*Bug: 5125624*/
        l_ship_to_location_id     := get_ship_to_location_id(p_consumption.line_location_id(i));
        l_tax_classification_code := get_tax_classification_code(p_consumption.po_header_id(i),
                                                                 p_consumption.line_location_id(i),
                                                                 'PURCHASE_ORDER');
        INSERT INTO ap_invoice_lines_interface(
            invoice_id,
            invoice_line_id,
            line_number,
            line_type_lookup_code,
            amount,
            accounting_date,
            description,
            tax_code_Id,
            amount_includes_tax_flag,
            --dist_code_combination_id,
            po_header_id,
            po_line_id,
            po_line_location_id,
            po_distribution_id,
            po_release_id,
            INVENTORY_ITEM_ID,   --Bug: 7658186
            ITEM_DESCRIPTION,   --Bug: 7658186
            quantity_invoiced,
            --expenditure_item_date, --bug 12976830
            --expenditure_type, --bug 12976830
            --expenditure_organization_id, --bug 12976830
            --project_accounting_context, --bug 12976830
            pa_quantity,
            --pa_addition_flag, --bug 12976830
            unit_price,
            assets_tracking_flag,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            match_option,
            tax_code_override_flag,
            org_id,
	          unit_of_meas_lookup_code,
	          SHIP_TO_LOCATION_ID, --Bug: 5125624
            TAX_CLASSIFICATION_CODE   --Bug: 5125624
        )
        SELECT
            p_consumption.invoice_id(i),
            ap_invoice_lines_interface_s.nextval,
            p_consumption.invoice_line_number(i),
            'ITEM',
            p_consumption.invoice_line_amount(i),
            -- p_consumption.creation_date(i),  -- bug2786193: use sysdate
            sysdate,
            p_consumption.item_description(i),
            p_consumption.tax_code_id(i),
            NULL,
            --pod.code_combination_id,
            p_consumption.po_header_id(i),
            p_consumption.po_line_id(i),
            p_consumption.line_location_id(i),
            p_consumption.po_distribution_id(i),
            p_consumption.po_release_id(i),
            p_consumption.item_id(i),   --Bug: 7658186
            p_consumption.item_description(i),   --Bug: 7658186
            p_consumption.quantity_invoiced(i),
            --pod.expenditure_item_date, --bug 12976830
            --pod.expenditure_type, --bug 12976830
            --pod.expenditure_organization_id, --bug 12976830
            --pod.project_accounting_context, --bug 12976830
            p_consumption.quantity_invoiced(i),
            --'N', --bug 12976830
            p_consumption.unit_price(i),
            DECODE(gcc.account_type, 'A','Y','N'),
            pod.attribute_category,
            pod.attribute1,
            pod.attribute2,
            pod.attribute3,
            pod.attribute4,
            pod.attribute5,
            pod.attribute6,
            pod.attribute7,
            pod.attribute8,
            pod.attribute9,
            pod.attribute10,
            pod.attribute11,
            pod.attribute12,
            pod.attribute13,
            pod.attribute14,
            pod.attribute15,
            'P',    -- match option
            'Y',
            p_consumption.org_id(i),
	          p_consumption.unit_meas_lookup_code(i), --5100177
	          l_ship_to_location_id,
            l_tax_classification_code
        FROM
              po_distributions pod,
              gl_code_combinations gcc
        WHERE
              pod.po_distribution_id = p_consumption.po_distribution_id(i)
        AND   pod.code_combination_id = gcc.code_combination_id;

  END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO create_invoice_distr_sp;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
END create_invoice_distr;

/* <PAY ON USE FPI END> */

END PO_INVOICES_SV2;

/
