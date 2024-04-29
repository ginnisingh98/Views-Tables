--------------------------------------------------------
--  DDL for Package Body PO_CREATE_ASBN_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CREATE_ASBN_INVOICE" AS
/* $Header: POXBNIVB.pls 120.4.12010000.6 2012/02/06 20:33:58 vthevark ship $*/

-- Read the profile option that enables/disables the debug log
g_asn_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_RVCTP_ENABLE_TRACE'),'N');

/** Local Procedure Definition **/

PROCEDURE create_invoice_header (
	p_invoice_id		IN 	NUMBER,
	p_invoice_num		IN	VARCHAR2,
	p_invoice_date		IN	DATE,
	p_vendor_id		IN	NUMBER,
	p_vendor_site_id	IN	NUMBER,
	p_invoice_amount	IN	NUMBER,
	p_invoice_currency_code	IN	VARCHAR2,
	p_payment_terms_id	IN	NUMBER,
	p_exchange_rate		IN	NUMBER,
	p_exchange_rate_type	IN	VARCHAR2,
	p_exchange_date		IN	DATE,
	p_org_id		IN	NUMBER );

/* Bug 7004065
 *  Invoice creation fails due to rounding amount difference between Invoice headers
 *  and Invoice lines. Invoice Header amount is user entered amount in iSupplier portal/
 *  the value provided in the rcv_headers_interface. This value can be provided either in
 *  rounded value or unrounded value. But, Invoice lines amount is a derived value by
 *  the code and it is posted as unrounded value.
 *  Issue occurs, when user is populating the rounded value for Invoice header and the
 *  the value in Invoice lines is going as unrounded and results in AP rejection due to
 *  mismatch in Header invoice amount and Lines invoice amount.
 *  We have to post the rounded values(using AP api) to Invoice Headers and
 *  Invoice Lines.
 */

PROCEDURE create_invoice_line (
	p_invoice_id		IN 	NUMBER,
	p_line_type		IN	VARCHAR2,
	p_amount		IN	NUMBER,
	p_invoice_currency_code	IN	VARCHAR2, --Bug 7004065
	p_invoice_date		IN	DATE,
	p_po_header_id		IN	NUMBER,
	p_po_line_id		IN	NUMBER,
	p_po_line_location_id	IN	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_uom			IN	VARCHAR2,
	p_item_id		IN	NUMBER,
	p_item_description	IN	VARCHAR2,
	p_qty_invoiced		IN	NUMBER,
	p_ship_to_location_id	IN	NUMBER,
	p_unit_price		IN	NUMBER,
	p_org_id		IN	NUMBER,
	p_taxable_flag		IN	VARCHAR2,
	p_tax_code		IN	VARCHAR2,
	p_tax_classification_code		IN	VARCHAR2 );




FUNCTION create_asbn_invoice (
	p_commit_interval	IN	NUMBER,
	p_shipment_header_id	IN	NUMBER )
RETURN BOOLEAN IS

   CURSOR c_asbn_header IS
     select
	rsh.invoice_num,
	rsh.invoice_date,
	rsh.vendor_id,
	NVL(rsh.remit_to_site_id, NVL(pvss.default_pay_site_id, pvss.vendor_site_id)) default_pay_site_id,
	rsh.invoice_amount,
	rsh.tax_name,
	rsh.tax_amount,
	rsh.freight_amount,
	NVL(rsh.currency_code, poh.currency_code) currency_code,
	NVL(rsh.payment_terms_id, poh.terms_id) payment_terms_id,
	NVL(rsh.conversion_rate_type, poh.rate_type) exchange_rate_type,
	NVL(rsh.conversion_date, poh.rate_date) exchange_rate_date,
	NVL(rsh.conversion_rate, poh.rate) exchange_rate,
	poh.org_id
     from
	po_vendor_sites pvss,
	po_headers poh,
	rcv_shipment_headers rsh
    where
	poh.vendor_site_id = pvss.vendor_site_id and
	poh.pcard_id is null and
	rsh.receipt_source_code = 'VENDOR' and
	rsh.asn_type = 'ASBN' and
	NVL(rsh.invoice_status_code,  'PENDING') IN ('PENDING', 'REJECTED') and
	rsh.shipment_header_id = p_shipment_header_id and
	poh.po_header_id = (
		select	rsl.po_header_id
		  from	rcv_shipment_lines rsl
		 where	rsl.shipment_header_id = rsh.shipment_header_id
		   and	rownum = 1 );


   CURSOR c_asbn_line IS
     select
	rsl.po_header_id,
	rsl.po_line_id,
	rsl.po_line_location_id,
	rsl.po_release_id,
	rsl.shipment_line_id,
	pol.item_id,
	pol.item_description,
	pol.unit_meas_lookup_code, --1890025
	rsl.unit_of_measure,
	rsl.quantity_shipped,
	rsl.notice_unit_price,
	NVL(rsl.notice_unit_price, pll.price_override) unit_price,
        pll.taxable_flag,
	rsl.tax_name tax_name,
	DECODE(pll.taxable_flag, 'Y', pll.tax_code_id, NULL) tax_code_id,
	rsl.tax_amount,
	pll.match_option
     from
	po_line_locations pll,
	po_lines pol,
	rcv_shipment_lines rsl
     where
	rsl.shipment_header_id = p_shipment_header_id and
	pll.line_location_id = rsl.po_line_location_id and
	pol.po_line_id = rsl.po_line_id and
	NVL(rsl.invoice_status_code, 'PENDING') IN ('PENDING','REJECTED');

   X_asbn_header	c_asbn_header%ROWTYPE;
   X_asbn_line		c_asbn_line%ROWTYPE;
   l_invoice_id		NUMBER;
   l_converted_qty	NUMBER;
   l_po_amount		NUMBER;
   l_taxable		BOOLEAN := false;
   l_temp_result 	BOOLEAN := true;

   x_group_id		VARCHAR2(80);
   x_batch_id		NUMBER;
   x_req_id		NUMBER;

   X_curr_inv_process_flag		VARCHAR2(1);

/* <PAY ON USE FPI START> */
   l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_error_msg     VARCHAR2(2000);
/* <PAY ON USE FPI END> */

    l_ship_to_location_id PO_LINE_LOCATIONS.SHIP_TO_LOCATION_ID%TYPE;
    l_tax_classification_code VARCHAR2(30);
BEGIN

   OPEN c_asbn_header;
   LOOP
        FETCH c_asbn_header INTO X_asbn_header;
	EXIT WHEN c_asbn_header%NOTFOUND;

	if ((X_asbn_header.invoice_num is not null) and
	    (X_asbn_header.invoice_date is not null)) then

     	   select ap_invoices_interface_s.nextval
     	     into l_invoice_id
     	     from sys.dual;

	   -- Bug 4723269 : Pass org_id to create_ap_batches

	   po_invoices_sv1.create_ap_batches(	'ASBN',
						X_asbn_header.currency_code,
						X_asbn_header.org_id,
						X_batch_id);

	   create_invoice_header (
		l_invoice_id,
		X_asbn_header.invoice_num,
		X_asbn_header.invoice_date,
		X_asbn_header.vendor_id,
		X_asbn_header.default_pay_site_id,
		X_asbn_header.invoice_amount,
		X_asbn_header.currency_code,
		X_asbn_header.payment_terms_id,
 		X_asbn_header.exchange_rate,
		X_asbn_header.exchange_rate_type,
		X_asbn_header.exchange_rate_date,
		X_asbn_header.org_id );

           x_group_id := substr('ASBN-'||TO_CHAR(l_invoice_id),1,80);

	   OPEN c_asbn_line;
	   LOOP
		FETCH c_asbn_line INTO X_asbn_line;
		EXIT WHEN c_asbn_line%NOTFOUND;

		If (X_asbn_line.match_option = 'R') then
		   po_interface_errors_sv1.handle_interface_errors(
                                       'ASBN',
                                       'FATAL',
                                       X_batch_id,   -- batch_id
                                       p_shipment_header_id,
                                       NULL,         -- line_id
                                       'PO_INV_CR_INVALID_MATCH_OPTION',
                                       'PO_LINE_LOCATIONS',  -- table_name
                                       'MATCH_OPTION',   -- column_name
                                       null,
                                       null, null, null, null, null,
                                       null,
                                       null, null, null, null, null,
                                       X_curr_inv_process_flag);

                   l_temp_result := false;
                end if;

                -- Calculate converted PO amount
		if (X_asbn_line.notice_unit_price is not null) then
		   l_po_amount := X_asbn_line.quantity_shipped *
				  X_asbn_line.notice_unit_price;
		else
		   if (X_asbn_line.unit_meas_lookup_code <>
		       X_asbn_line.unit_of_measure) then
                      po_uom_s.uom_convert (
				X_asbn_line.quantity_shipped,
                             	X_asbn_line.unit_of_measure,
                             	X_asbn_line.item_id,
                             	X_asbn_line.unit_meas_lookup_code,
                             	l_converted_qty );
		   else
		      l_converted_qty := X_asbn_line.quantity_shipped;
		   end if;

		   l_po_amount := l_converted_qty * X_asbn_line.unit_price;
		end if;


		if (l_temp_result) then
				l_ship_to_location_id     := PO_INVOICES_SV2.get_ship_to_location_id(
				                             X_asbn_line.po_line_location_id);

				l_tax_classification_code := PO_INVOICES_SV2.get_tax_classification_code(
				                             X_asbn_line.po_header_id,
				                             X_asbn_line.po_line_location_id,
				                             'PURCHASE_ORDER');
		   create_invoice_line (
			l_invoice_id,
			'ITEM',
			l_po_amount,
			X_asbn_header.currency_code, --Bug 7004065
			X_asbn_header.invoice_date,
			X_asbn_line.po_header_id,
			X_asbn_line.po_line_id,
			X_asbn_line.po_line_location_id,
			X_asbn_line.po_release_id,
			X_asbn_line.unit_meas_lookup_code,
			X_asbn_line.item_id,
			X_asbn_line.item_description,
			l_converted_qty,
			l_ship_to_location_id,
			X_asbn_line.unit_price,
			X_asbn_header.org_id,
			X_asbn_line.taxable_flag,
			null,  --tax_code
			l_tax_classification_code );

		   if ((not l_taxable) and X_asbn_line.taxable_flag = 'Y') then
		      l_taxable := true;
		   end if;

                    -- After creating line interface, change result to true
		   l_temp_result := true;
                end if;

	   END LOOP;
	   CLOSE c_asbn_line;

	   if (l_taxable and nvl(X_asbn_header.tax_amount, 0) > 0) then

/* Bug 5107497: As per eTax project, no need to populate Tax lines in
                ap_invoice_lines_table. We have to populate control_amount
                with tax amount specified in ASBN and set calc_tax_during_import_flag
                to 'Y' in ap_invoices_interface table. */
              UPDATE ap_invoices_interface
                  SET calc_tax_during_import_flag = 'Y',
                      control_amount  = X_asbn_header.tax_amount
              WHERE invoice_id = l_invoice_id;

           end if;

           if (nvl(X_asbn_header.freight_amount, 0) > 0) then
	      create_invoice_line (
		l_invoice_id,
		'FREIGHT',
		X_asbn_header.freight_amount,
		X_asbn_header.currency_code, --Bug 7004065
		X_asbn_header.invoice_date,
		null,
		null,
		null,
		null,
		null,	-- uom
		null,	-- item_id
		null,	-- item_description,
		null,	-- qty_to_invoice,
		null,	-- ship_to_location_code,
		null,	-- unit_price,
		X_asbn_header.org_id,
		null,   -- taxable_flag
		null,
		null --tax classification code
     );
	   end if;

       /* Bug 12631722:  Upon ASBN creation, RSH and RSL have to be set as
        * INVOICED */

       update rcv_shipment_headers
       set invoice_status_code = 'INVOICED'
       where shipment_header_id = p_shipment_header_id;

       update rcv_shipment_lines
       set invoice_status_code = 'INVOICED'
       where shipment_header_id = p_shipment_header_id;

	end if;
   END LOOP;
   CLOSE c_asbn_header;

   if (l_temp_result and p_commit_interval <> -1) then
      COMMIT;
   end if;

   IF (l_temp_result and x_group_id is NOT NULL) THEN

/* <PAY ON USE FPI START> */
/* fnd request submit request has been replaced by
   PO_INVOICES_SV1.submit_invoice_import as a result of refactoring
   performed during FPI Consigned Inv project */

        PO_INVOICES_SV1.submit_invoice_import(
             l_return_status,
             'ASBN',
             x_group_id,
             x_batch_id,
             0,
             0,
             x_req_id);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
/* <PAY ON USE FPI END> */

   END IF;

   return l_temp_result;

EXCEPTION
/* <PAY ON USE FPI START> */
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        l_error_msg := FND_MSG_PUB.get(p_encoded => 'F');
        IF (g_asn_debug = 'Y') THEN
           ASN_DEBUG.put_line(l_error_msg);
        END IF;
        IF c_asbn_line%ISOPEN THEN
            CLOSE c_asbn_line;
        END IF;
        IF c_asbn_header%ISOPEN THEN
            CLOSE c_asbn_header;
        END IF;
        RETURN FALSE;
/* <PAY ON USE FPI END> */

  WHEN OTHERS THEN
    if c_asbn_line%isopen then
       close c_asbn_line;
    end if;
    if c_asbn_header%isopen then
       close c_asbn_header;
    end if;
    return false;
END create_asbn_invoice;


PROCEDURE create_invoice_header (
	p_invoice_id		IN 	NUMBER,
	p_invoice_num		IN	VARCHAR2,
	p_invoice_date		IN	DATE,
	p_vendor_id		IN	NUMBER,
	p_vendor_site_id	IN	NUMBER,
	p_invoice_amount	IN	NUMBER,
	p_invoice_currency_code	IN	VARCHAR2,
	p_payment_terms_id	IN	NUMBER,
	p_exchange_rate		IN	NUMBER,
	p_exchange_rate_type	IN	VARCHAR2,
	p_exchange_date		IN	DATE,
	p_org_id		IN	NUMBER )
IS

   x_group_id		VARCHAR2(80);
   l_invoice_amount     NUMBER; --Bug 7004065

BEGIN

   x_group_id := substr('ASBN-'||TO_CHAR(p_invoice_id),1,80);

   l_invoice_amount := ap_utilities_pkg.ap_round_currency(p_invoice_amount,p_invoice_currency_code); --Bug 7004065

   insert into AP_INVOICES_INTERFACE (
	INVOICE_ID,
     	INVOICE_NUM,
	INVOICE_DATE,
     	VENDOR_ID,
     	VENDOR_SITE_ID,
     	INVOICE_AMOUNT,
     	INVOICE_CURRENCY_CODE,
	--EXCHANGE_RATE,
	--EXCHANGE_RATE_TYPE,
	--EXCHANGE_DATE,
	TERMS_ID,
	GROUP_ID,
     	SOURCE,
     	INVOICE_RECEIVED_DATE,
	CREATION_DATE,
	ORG_ID )
   VALUES (
	p_invoice_id,
	p_invoice_num,
	p_invoice_date,
     	p_vendor_id,
     	p_vendor_site_id,
    	l_invoice_amount, --Bug 7004065
     	p_invoice_currency_code,
	--p_exchange_rate,
	--p_exchange_rate_type,
	--p_exchange_date,
	p_payment_terms_id,
	x_group_id,
	'ASBN',
     	sysdate,
	sysdate,
	p_org_id );

EXCEPTION
  WHEN others THEN
    raise;
END create_invoice_header;


PROCEDURE create_invoice_line (
	p_invoice_id		IN 	NUMBER,
	p_line_type		IN	VARCHAR2,
	p_amount		IN	NUMBER,
	p_invoice_currency_code	IN	VARCHAR2, --Bug 7004065
	p_invoice_date		IN	DATE,
	p_po_header_id		IN	NUMBER,
	p_po_line_id		IN	NUMBER,
	p_po_line_location_id	IN	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_uom			IN	VARCHAR2,
	p_item_id		IN	NUMBER,
	p_item_description	IN	VARCHAR2,
	p_qty_invoiced		IN	NUMBER,
	p_ship_to_location_id	IN	NUMBER,
	p_unit_price		IN	NUMBER,
	p_org_id		IN	NUMBER,
	p_taxable_flag		IN	VARCHAR2,
	p_tax_code		IN	VARCHAR2,
	p_tax_classification_code		IN	VARCHAR2 )
IS

   x_invoice_line_id		NUMBER;
   l_prorate_across_flag	VARCHAR2(1) := null;
   l_freight_ccid		NUMBER	:= 0;
   sqlstmt_old			VARCHAR2(1000);
   sqlstmt_new			VARCHAR2(4000);
   X_use_interface		VARCHAR2(1) := null;
   l_amount                     NUMBER; --Bug 7004065

BEGIN

   select ap_invoice_lines_interface_s.nextval
     into x_invoice_line_id
     from sys.dual;

   if (p_line_type = 'ITEM' or p_line_type = 'TAX') then
      l_prorate_across_flag := 'N';

   elsif (p_line_type = 'FREIGHT') then
      select freight_code_combination_id
        into l_freight_ccid
        from ap_system_parameters_all
       where org_id = p_org_id;

      if (l_freight_ccid <> 0) then
         l_prorate_across_flag := 'N';
      else
         l_prorate_across_flag := 'Y';
      end if;

   end if;

   l_amount := ap_utilities_pkg.ap_round_currency(p_amount,p_invoice_currency_code); --Bug 7004065

   insert into ap_invoice_lines_interface (
			 INVOICE_ID,
			 INVOICE_LINE_ID,
			 LINE_NUMBER,
			 LINE_TYPE_LOOKUP_CODE,
			 AMOUNT,
			 AMOUNT_INCLUDES_TAX_FLAG,
			 PRORATE_ACROSS_FLAG,
			 PO_HEADER_ID,
			 PO_LINE_ID,
			 PO_LINE_LOCATION_ID,
			 PO_RELEASE_ID,
			 UNIT_OF_MEAS_LOOKUP_CODE, --PO_UNIT_OF_MEASURE, bug 12370070, as ap team has obsoleted PO_UNIT_OF_MEASURE
			 INVENTORY_ITEM_ID,
			 ITEM_DESCRIPTION,
			 QUANTITY_INVOICED,
			 SHIP_TO_LOCATION_ID,
			 UNIT_PRICE,
			 LAST_UPDATE_DATE,
			 CREATION_DATE,
			 ORG_ID,
			 TAXABLE_FLAG,
			 TAX_CODE_OVERRIDE_FLAG,
			 TAX_CODE,
			 TAX_CLASSIFICATION_CODE
       )
   		 VALUES (
			 p_invoice_id,
			 x_invoice_line_id,
			 null,
			 p_line_type,
			 l_amount, -- Bug 7004065
			 null,
			 l_prorate_across_flag,
			 p_po_header_id,
			 p_po_line_id,
			 p_po_line_location_id,
			 p_po_release_id,
			 p_uom,
			 p_item_id,
			 p_item_description,
			 p_qty_invoiced,
			 p_ship_to_location_id,
			 p_unit_price,
			 sysdate,
			 sysdate,
			 p_org_id,
			 p_taxable_flag,
			 'N',
			 p_tax_code,
			 p_tax_classification_code
       );

EXCEPTION
  WHEN OTHERS THEN
    raise;
END create_invoice_line;


END PO_CREATE_ASBN_INVOICE;

/
