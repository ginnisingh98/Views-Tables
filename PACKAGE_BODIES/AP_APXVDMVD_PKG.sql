--------------------------------------------------------
--  DDL for Package Body AP_APXVDMVD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXVDMVD_PKG" AS
/* $Header: apvdmvdb.pls 120.10.12000000.2 2007/08/01 10:03:45 gagrawal ship $ */
--
--
   PROCEDURE INITIALIZE (
	    x_user_defined_vendor_num_code	in out NOCOPY varchar2,
	    x_manual_vendor_num_type		in out NOCOPY varchar2,
	    x_rfq_only_site_flag		in out NOCOPY varchar2,
	    x_ship_to_location_id		in out NOCOPY number,
	    x_ship_to_location_code		in out NOCOPY varchar2,
	    x_bill_to_location_id		in out NOCOPY number,
	    x_bill_to_location_code		in out NOCOPY varchar2,
	    x_fob_lookup_code 			in out NOCOPY varchar2,
	    x_freight_terms_lookup_code		in out NOCOPY varchar2,
	    x_terms_id				in out NOCOPY number,
	    x_terms_disp			in out NOCOPY varchar2,
	    x_always_take_disc_flag		in out NOCOPY varchar2,
	    x_invoice_currency_code		in out NOCOPY varchar2,
            x_org_id				in out NOCOPY number,
	    x_set_of_books_id			in out NOCOPY number,
            x_short_name			in out NOCOPY varchar2,
	    x_payment_currency_code		in out NOCOPY varchar2,
	    x_accts_pay_ccid			in out NOCOPY number,
	    x_future_dated_payment_ccid		in out NOCOPY number,
	    x_prepay_code_combination_id	in out NOCOPY number,
	    x_vendor_pay_group_lookup_code	in out NOCOPY varchar2,
	    x_sys_auto_calc_int_flag		in out NOCOPY varchar2,
	    x_terms_date_basis			in out NOCOPY varchar2,
	    x_terms_date_basis_disp		in out NOCOPY varchar2,
	    x_chart_of_accounts_id		in out NOCOPY number,
	    x_fob_lookup_disp			in out NOCOPY varchar2,
	    x_freight_terms_lookup_disp		in out NOCOPY varchar2,
	    x_vendor_pay_group_disp		in out NOCOPY varchar2,
	    x_fin_require_matching		in out NOCOPY varchar2,
	    x_sys_require_matching		in out NOCOPY varchar2,
	    x_fin_match_option			in out NOCOPY varchar2,
	    x_po_create_dm_flag			in out NOCOPY varchar2,
	    x_exclusive_payment			in out NOCOPY varchar2,
	    x_vendor_auto_int_default		in out NOCOPY varchar2,
	    x_inventory_organization_id		in out NOCOPY number,
	    x_ship_via_lookup_code		in out NOCOPY varchar2,
	    x_ship_via_disp			in out NOCOPY varchar2,
	    x_sysdate				in out NOCOPY date,
	    x_enforce_ship_to_loc_code		in out NOCOPY varchar2,
	    x_receiving_routing_id		in out NOCOPY number,
	    x_qty_rcv_tolerance			in out NOCOPY number,
	    x_qty_rcv_exception_code		in out NOCOPY varchar2,
	    x_days_early_receipt_allowed	in out NOCOPY number,
	    x_days_late_receipt_allowed		in out NOCOPY number,
	    x_allow_sub_receipts_flag		in out NOCOPY varchar2,
	    x_allow_unord_receipts_flag		in out NOCOPY varchar2,
	    x_receipt_days_exception_code	in out NOCOPY varchar2,
	    x_enforce_ship_to_loc_disp		in out NOCOPY varchar2,
	    x_qty_rcv_exception_disp		in out NOCOPY varchar2,
	    x_receipt_days_exception_disp	in out NOCOPY varchar2,
	    x_receipt_required_flag		in out NOCOPY varchar2,
	    x_inspection_required_flag		in out NOCOPY varchar2,
	    x_payment_method_lookup_code	in out NOCOPY varchar2,
            x_payment_method_disp		in out NOCOPY varchar2,
	    x_pay_date_basis_lookup_code	in out NOCOPY varchar2,
	    x_pay_date_basis_disp		in out NOCOPY varchar2,
	    x_receiving_routing_name		in out NOCOPY varchar2,
	    x_AP_inst_flag			in out NOCOPY varchar2,
	    x_PO_inst_flag			in out NOCOPY varchar2,
   	    x_home_country_code 		in out NOCOPY varchar2,
	    x_default_country_code 		in out NOCOPY varchar2,
	    x_default_country_disp 		in out NOCOPY varchar2,
	    x_default_awt_group_id		in out NOCOPY number,
	    x_default_awt_group_name		in out NOCOPY varchar2,
	    x_allow_awt_flag			in out NOCOPY varchar2,
	    x_base_currency_code		in out NOCOPY varchar2,
	    x_address_style			in out NOCOPY varchar2,
	    /* eTax Uptake
	    x_auto_tax_calc_flag		in out NOCOPY varchar2,
	    x_auto_tax_calc_override		in out NOCOPY varchar2,
	    x_amount_includes_tax_flag		in out NOCOPY varchar2,
            x_amount_includes_tax_override	in out NOCOPY varchar2,
	    x_ap_tax_rounding_rule		in out NOCOPY varchar2,
            x_vat_code				in out NOCOPY varchar2, */
	    x_use_bank_charge_flag              in out NOCOPY varchar2,
            x_bank_charge_bearer                in out NOCOPY varchar2,
	    X_calling_sequence			in     varchar2 ) is

--
   l_appl_short_name varchar2(30);
   l_ap_status varchar2(30);
   l_po_status varchar2(30);
   l_industry varchar2(30);
   l_oracle_schema varchar2(30);
   dummy boolean;
   l_po_setup number;
   --
   -- inactive dates
   --
   l_ship_to_loc_inactive_date 	date;
   l_bill_to_loc_inactive_date 	date;
   l_fob_inactive_date			date;
   l_freight_terms_inactive_date	date;
   l_terms_inactive_date		date;
   l_payment_method_inactive_date	date;
   l_ship_via_inactive_date		date;
   --
   --
   current_calling_sequence		varchar2(2000);
   debug_info				varchar2(100);

   -- Bug 5087698
   --
   l_ap_options number;
   l_fin_options number;
--
-- Load initial defaults into WORLD block using several
-- select statements
--
  begin

--  Update the calling sequence
--
    current_calling_sequence := 'AP_APXVDMVD_PKG.INITIALIZE<-' ||
				 X_calling_sequence;
    --
    --
    dummy := fnd_installation.get_app_info('AP',l_ap_status,l_industry,l_oracle_schema);
    x_AP_inst_flag := l_ap_status;
    dummy := fnd_installation.get_app_info('PO',l_po_status,l_industry,l_oracle_schema);
    x_PO_inst_flag := l_po_status;
    --
    --
    debug_info := 'Select from ap_lookup_codes, po_lookup_codes, hr_locations, ....';
    --Bug :2809214 MOAC - Supplier Attribute Change Project
    --Changed the source table from financial_options and system_options to
    --ap_product_setup for some of columns. For list of columns please refer to bug.

  --
  -- Bug 5087698

    SELECT count(*)
    INTO   l_ap_options
    FROM   ap_system_parameters
    WHERE  nvl(org_id,-99) = nvl(x_org_id,-99);

    SELECT count(*)
    INTO   l_fin_options
    FROM   financials_system_parameters
    WHERE  nvl(org_id,-99) = nvl(x_org_id,-99);

    IF l_ap_options > 0 and l_fin_options > 0 THEN

    SELECT  aps.supplier_numbering_method,
	    aps.supplier_num_type,
	    fin.rfq_only_site_flag,
	    fin.ship_to_location_id,		-- ship_to_location_id
	    hl2.location_code,			-- ship_to_location_code
	    nvl(hl2.inactive_date,sysdate+1),	-- ship to inactive date
	    fin.bill_to_location_id,		-- bill_to_location_id
	    hl1.location_code,			-- bill_to_location_code
	    nvl(hl1.inactive_date,sysdate+1),	-- bill_to_location inatcive date
	    fin.fob_lookup_code,		-- fob_lookup_code
	    pc1.displayed_field,		-- fob_lookup_disp
            nvl(pc1.inactive_date,sysdate+1),	-- fob inactive_date
	    fin.freight_terms_lookup_code,	-- freight_terms_lookup_code
	    pc2.displayed_field,		-- freight_terms_lookup_disp
	    nvl(pc2.inactive_date,sysdate+1),	-- freight_terms inactive_date
	    aps.terms_id, 			-- terms_id
            tm.name,				-- terms_name
	    nvl(tm.end_date_active,sysdate+1),	-- terms_inactive_date
	    aps.payment_method_lookup_code,	-- payment_method_lookup_code
	    lc1.displayed_field,		-- payment_method_disp
            nvl(lc1.inactive_date,sysdate+1),	-- payment_method inactve date
	    aps.always_take_disc_flag,
	    aps.pay_date_basis_lookup_code,	-- pay_date_basis_lookup_code
	    lc2.displayed_field,		-- pay_date_basis_disp
            -- Invoice Currency
            -- In R12, with the MOAC project the invoice currency was moved
            -- product setup level. But payment currency was not thought
            -- about properly. So modified the code such that
            -- the defaulting to supplier will be the ledger currency
            -- otherwise it will be derived from the invoice currency in the
            -- product setup.
	    nvl(ap.base_currency_code,aps.invoice_currency_code),
            fin.org_id,
	    fin.set_of_books_id,
	    gl.short_name,
            -- Invoice Currency
            -- In R12, with the MOAC project the invoice currency was moved
            -- product setup level. But payment currency was not thought
            -- about properly. So modified the code such that
            -- the defaulting to supplier will be the ledger currency
            -- otherwise it will be derived from the invoice currency in the
            -- product setup.
	    nvl(ap.base_currency_code,aps.invoice_currency_code),
	    fin.accts_pay_code_combination_id,
	    fin.future_dated_payment_ccid,
	    fin.prepay_code_combination_id,
	    aps.supplier_pay_group_lookup_code,
	    pc3.lookup_code,	--2122951 changed to lookup_code
	    aps.auto_calculate_interest_flag,
	    -- Bug 1492237 Get terms_date_basis from ap insead of fin
	    aps.terms_date_basis,		-- terms_date_basis
	    lc3.displayed_field,		-- terms_date_basis_disp
	    gl.chart_of_accounts_id,
	    aps.hold_unmatched_invoices_flag,
	    ap.hold_unmatched_invoices_flag,
	    fin.match_option,
	    fin.exclusive_payment_flag,
	    ap.vendor_auto_int_default,
	    fin.inventory_organization_id,
	    fin.ship_via_lookup_code,		-- ship_via_lookup_code
	    ofr.description,			-- ship_via_disp
            nvl(ofr.disable_date,sysdate+1),	-- ship_via inactive date
	    sysdate,
	    ap.base_currency_code,
	    fin.vat_country_code,
	    ap.default_awt_group_id,
	    awt.name,
	    nvl(ap.allow_awt_flag, 'N'),
	    ap.use_bank_charge_flag, --5007989
            nvl(ap.bank_charge_bearer, 'I') --5007989
    INTO    x_user_defined_vendor_num_code,
	    x_manual_vendor_num_type,
	    x_rfq_only_site_flag,
	    x_ship_to_location_id,
	    x_ship_to_location_code,
            l_ship_to_loc_inactive_date,
	    x_bill_to_location_id,
	    x_bill_to_location_code,
      	    l_bill_to_loc_inactive_date,
	    x_fob_lookup_code,
	    x_fob_lookup_disp,
	    l_fob_inactive_date,
	    x_freight_terms_lookup_code,
	    x_freight_terms_lookup_disp,
	    l_freight_terms_inactive_date,
	    x_terms_id,
            x_terms_disp,
	    l_terms_inactive_date,
	    x_payment_method_lookup_code,
	    x_payment_method_disp,
	    l_payment_method_inactive_date,
	    x_always_take_disc_flag,
	    x_pay_date_basis_lookup_code,
	    x_pay_date_basis_disp,
	    x_invoice_currency_code,
            x_org_id,
	    x_set_of_books_id,
            x_short_name,
	    x_payment_currency_code,
	    x_accts_pay_ccid,
	    x_future_dated_payment_ccid,
	    x_prepay_code_combination_id,
	    x_vendor_pay_group_lookup_code,
	    x_vendor_pay_group_disp,
	    x_sys_auto_calc_int_flag,
	    x_terms_date_basis,
	    x_terms_date_basis_disp,
	    x_chart_of_accounts_id,
	    x_fin_require_matching,
	    x_sys_require_matching,
	    x_fin_match_option,
	    x_exclusive_payment,
	    x_vendor_auto_int_default,
	    x_inventory_organization_id,
	    x_ship_via_lookup_code,
	    x_ship_via_disp,
            l_ship_via_inactive_date,
	    x_sysdate,
	    x_base_currency_code,
	    x_home_country_code,
	    x_default_awt_group_id,
	    x_default_awt_group_name,
	    x_allow_awt_flag,
	    x_use_bank_charge_flag,
            x_bank_charge_bearer
    FROM    ap_lookup_codes lc1,
            ap_lookup_codes lc2,
            ap_lookup_codes lc3,
            po_lookup_codes pc1,
            po_lookup_codes pc2,
            po_lookup_codes pc3,
            hr_locations_all hl1,
            hr_locations_all hl2,
            ap_terms_tl tm,
            org_freight_tl ofr,
            gl_ledgers gl,
            financials_system_params_all fin,
            ap_system_parameters_all ap,
            ap_awt_groups awt,
            ap_product_setup aps
    WHERE   gl.ledger_id  = fin.set_of_books_id
    AND     lc1.lookup_type(+)   = 'PAYMENT METHOD'
    AND     lc1.lookup_code(+)   = aps.payment_method_lookup_code
    AND     lc2.lookup_type(+)   = 'PAY DATE BASIS'
    AND     lc2.lookup_code(+)   = aps.pay_date_basis_lookup_code
    AND     lc3.lookup_type(+)   = 'TERMS DATE BASIS'
    AND     lc3.lookup_code(+)   = aps.terms_date_basis
    AND     pc1.lookup_type(+)   = 'FOB'
    AND     pc1.lookup_code(+)   = fin.fob_lookup_code
    AND     pc2.lookup_type(+)   = 'FREIGHT TERMS'
    AND     pc2.lookup_code(+)   = fin.freight_terms_lookup_code
    AND     pc3.lookup_type(+)   = 'PAY GROUP'
    AND     pc3.lookup_code(+)   = aps.supplier_pay_group_lookup_code
    AND     hl1.location_id(+)   = fin.bill_to_location_id
    AND     hl1.bill_to_site_flag(+)  = 'Y'
    AND     hl2.location_id(+)   = fin.ship_to_location_id
    AND     hl2.ship_to_site_flag(+)  = 'Y'
    AND     ofr.freight_code(+)     = fin.ship_via_lookup_code
    AND     ofr.organization_id(+)      = fin.inventory_organization_id
    AND     ofr.language(+) = userenv('LANG')
    AND     awt.group_id(+)  = ap.default_awt_group_id
    AND     aps.terms_id  = tm.term_id(+)
    AND     tm.language(+) = userenv('LANG')
    AND     fin.org_id  = x_org_id
    AND     fin.set_of_books_id = ap.set_of_books_id
    AND     fin.org_id = ap.org_id;

  END IF;

--
--
    if (x_PO_inst_flag = 'I') then
--
--  Bug 457417 - Just checking if PO has been installed or not is no longer
--  sufficient in a multi-org environment, we need to know not only if PO has
--  been installed but if it has been setup.  We assume that if PO has been
--  installed the table po_system_parameters exists and if it has been setup
--  it contains a record. (mhtaylor 30/Jan/98)
--
        debug_info := 'Check to see if PO has been setup';
--
        l_po_setup := 0;
--
        SELECT  count(*)
        INTO    l_po_setup
        FROM    po_system_parameters
        WHERE   nvl(org_id,-99) = nvl(x_org_id,-99);
--
        IF l_po_setup > 0 THEN
--
      		debug_info := 'Select from rcv_parameters, po_lookup_codes, po_system_parameters';

	      SELECT  rp.enforce_ship_to_location_code,
	              rp.receiving_routing_id,
		      rp.qty_rcv_tolerance,
		      rp.qty_rcv_exception_code,
		      rp.days_early_receipt_allowed,
		      rp.days_late_receipt_allowed,
		      rp.allow_substitute_receipts_flag,
		      rp.allow_unordered_receipts_flag,
		      rp.receipt_days_exception_code,
		      pc1.displayed_field,	-- enforce_ship_to_loc_disp
		      pc2.displayed_field,	-- qty_rcv_exception_disp
		      pc3.displayed_field,	-- receipt_days_exception_disp
		      po.receiving_flag,
		      po.inspection_required_flag,
                      po.create_debit_memo_flag
	      INTO    x_enforce_ship_to_loc_code,
		      x_receiving_routing_id,
		      x_qty_rcv_tolerance,
		      x_qty_rcv_exception_code ,
		      x_days_early_receipt_allowed,
		      x_days_late_receipt_allowed,
		      x_allow_sub_receipts_flag,
		      x_allow_unord_receipts_flag,
		      x_receipt_days_exception_code,
		      x_enforce_ship_to_loc_disp,
		      x_qty_rcv_exception_disp,
		      x_receipt_days_exception_disp,
		      x_receipt_required_flag,
		      x_inspection_required_flag,
                      x_po_create_dm_flag
	      FROM    rcv_parameters rp,
		      po_lookup_codes pc1,
		      po_lookup_codes pc2,
		      po_lookup_codes pc3,
		      po_system_parameters po
	     WHERE    rp.organization_id = x_inventory_organization_id
	     AND     pc1.lookup_type(+) = 'RECEIVING CONTROL LEVEL'
	     AND     pc1.lookup_code(+) = rp.enforce_ship_to_location_code
	     AND     pc2.lookup_type(+) = 'RECEIVING CONTROL LEVEL'
	     AND     pc2.lookup_code(+) = rp.qty_rcv_exception_code
	     AND     pc3.lookup_type(+) = 'RECEIVING CONTROL LEVEL'
	     AND     pc3.lookup_code(+) = rp.receipt_days_exception_code
	     --MO Access Control
	     AND     nvl(po.org_id,-99)	= nvl(x_org_id,-99);
	     --
	     --
	     debug_info := 'Select routing_name';

	     SELECT  rh.routing_name
	     INTO    x_receiving_routing_name
	     FROM    rcv_Routing_Headers rh
	     WHERE   rh.routing_header_id = x_receiving_routing_id;
--
        ELSE
                x_PO_inst_flag := '';
        END IF;
--
   end if;
   --
   --
   fnd_profile.get('DEFAULT_COUNTRY',x_default_country_code);
   --
   --
   if  ( x_default_country_code is null ) then
	 x_default_country_code := x_home_country_code;
   end if;
   --
   --
   if ( x_default_country_code is not null ) then

	   select 	territory_short_name,
			address_style
	   into 	x_default_country_disp,
			x_address_style
	   from 	fnd_territories_vl
	   where 	territory_code = x_default_country_code
            OR        iso_territory_code = x_default_country_code; --Bug 5260178

   end if;
   --
   -- Clear defaults if inactive
   --
	if sysdate > l_ship_to_loc_inactive_date then
		x_ship_to_location_id 	:= null;
		x_ship_to_location_code := null;
	end if;
	--
	--
	if sysdate > l_bill_to_loc_inactive_date then
		x_bill_to_location_id 	:= null;
		x_bill_to_location_code := null;
	end if;
	--
	--
	if sysdate > l_fob_inactive_date then
		x_fob_lookup_code	:= null;
		x_fob_lookup_disp	:= null;
	end if;
	--
	--
	if sysdate > l_freight_terms_inactive_date then
		x_freight_terms_lookup_code	:= null;
		x_freight_terms_lookup_disp	:= null;
	end if;
	--
	--
	if sysdate > l_terms_inactive_date then
		x_terms_id 	:= null;
		x_terms_disp	:= null;
	end if;
	--
	--
	if sysdate > l_ship_via_inactive_date then
		x_ship_via_lookup_code	:= null;
	    	x_ship_via_disp		:= null;
	end if;
--
-- Supply defaults from ap_lookup_codes where null values resulted
-- from lookup in financials_system_parameters table
--
   if x_pay_date_basis_lookup_code is  NULL then
      debug_info := 'Select pay_date_basis displayed field';
      SELECT  lc.lookup_code,
              lc.displayed_field
      INTO    x_pay_date_basis_lookup_code,
	      x_pay_date_basis_disp
      FROM    ap_lookup_codes lc
      WHERE   lc.lookup_type = 'PAY DATE BASIS'
      AND     lc.lookup_code = 'DISCOUNT';
   end if;

   if x_payment_method_lookup_code is NULL then
	debug_info := 'Select payment_method display field';
      	SELECT  lc.lookup_code,
		lc.displayed_field
	INTO 	x_payment_method_lookup_code,
        	x_payment_method_disp

	FROM    ap_lookup_codes lc
	WHERE   lc.lookup_type = 'PAYMENT METHOD'
	AND     lc.lookup_code = 'CHECK';
   end if;
--
   EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','SHIP_TO_LOCATION_ID = ' ||
	       		x_ship_to_location_id ||
	       	'BILL_TO_LOCATION_ID = ' || x_bill_to_location_id ||
	       	'FOB_LOOKUP_CODE = ' || x_fob_lookup_code ||
	       	'FREIGHT_TERMS_LOOKUP_CODE = ' || x_freight_terms_lookup_code ||
	        'TERMS_ID = ' || x_terms_id ||
	        'PAYMENT_METHOD_LOOKUP_CODE = ' || x_payment_method_lookup_code ||
	        'PAY_DATE_BASIS_LOOKUP_CODE = ' || x_pay_date_basis_lookup_code ||
	        'SET_OF_BOOKS_ID = ' || x_set_of_books_id ||
	        'VENDOR_PAY_GROUP_LOOKUP_CODE = ' || x_vendor_pay_group_lookup_code ||
	        'TERMS_DATE_BASIS = ' || x_terms_date_basis ||
	        'SHIP_VIA_LOOKUP_CODE = ' || x_ship_via_lookup_code ||
            	'INVENTORY_ORGANIZATION_ID = ' || x_inventory_organization_id ||
            	'ENFORCE_SHIP_TO_LOC_CODE = ' || x_enforce_ship_to_loc_code ||
            	'QTY_RCV_EXCEPTION_CODE = ' || x_qty_rcv_exception_code ||
            	'RECEIPT_DAYS_EXCEPTION_CODE = ' || x_receipt_days_exception_code ||
                'RECEIVING_ROUTING_ID = ' || x_receiving_routing_id);

              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;


   END INITIALIZE;
--

--
--
   PROCEDURE Initialize_Supplier_Attr (
	    x_user_defined_vendor_num_code	in out NOCOPY varchar2,
	    x_manual_vendor_num_type		in out NOCOPY varchar2,
	    x_terms_id				in out NOCOPY number,
	    x_terms_disp			      in out NOCOPY varchar2,
	    x_always_take_disc_flag		in out NOCOPY varchar2,
	    x_invoice_currency_code		in out NOCOPY varchar2,
	    x_vendor_pay_group_lookup_code	in out NOCOPY varchar2,
	    x_sys_auto_calc_int_flag		in out NOCOPY varchar2,
	    x_terms_date_basis			in out NOCOPY varchar2,
	    x_terms_date_basis_disp		in out NOCOPY varchar2,
	    x_vendor_pay_group_disp		in out NOCOPY varchar2,
	    x_fin_require_matching		in out NOCOPY varchar2,
	    x_fin_match_option			in out NOCOPY varchar2,
	    x_sysdate				in out NOCOPY date,
	    x_pay_date_basis_lookup_code	in out NOCOPY varchar2,
	    x_pay_date_basis_disp		in out NOCOPY varchar2,
	    x_AP_inst_flag			in out NOCOPY varchar2,
	    x_use_bank_charge_flag              in out NOCOPY varchar2,
          x_bank_charge_bearer                in out NOCOPY varchar2,
	    X_calling_sequence			in     varchar2 ) is

--
   l_ap_status varchar2(30);
   l_industry varchar2(30);
   l_oracle_schema varchar2(30);
   dummy boolean;
   l_po_setup number;

   l_terms_inactive_date		date;
   --
   --
   current_calling_sequence		varchar2(2000);
   debug_info				varchar2(100);

  begin

    --  Update the calling sequence
    --
    current_calling_sequence := 'AP_APXVDMVD_PKG.Initialize_Supplier_Attr<-' ||
				 X_calling_sequence;
    --
    --

    dummy := fnd_installation.get_app_info
		('SQLAP',l_ap_status,l_industry,l_oracle_schema);
    x_AP_inst_flag := l_ap_status;

    --
    --
    debug_info
	:= 'Select from ap_lookup_codes, po_lookup_codes, hr_locations, ....';
    SELECT aps.supplier_numbering_method,
	    aps.supplier_num_type,
	    aps.terms_id, 			-- terms_id
            tm.name,				-- terms_name
	    nvl(tm.end_date_active,sysdate+1),	-- terms_inactive_date
	    aps.always_take_disc_flag,
	    aps.pay_date_basis_lookup_code,	-- pay_date_basis_lookup_code
	    lc2.displayed_field,		-- pay_date_basis_disp
	    aps.invoice_currency_code,
	    aps.supplier_pay_group_lookup_code,
	    pc3.lookup_code,
	    aps.auto_calculate_interest_flag,
	    aps.terms_date_basis,		-- terms_date_basis
	    lc3.displayed_field,		-- terms_date_basis_disp
	    aps.hold_unmatched_invoices_flag,
	    sysdate,
	--5007989    ap.use_bank_charge_flag,
        --5007989  nvl(ap.bank_charge_bearer, 'I')
            aps.match_option                   --bug6075649
    INTO  x_user_defined_vendor_num_code,
	    x_manual_vendor_num_type,
	    x_terms_id,
            x_terms_disp,
	    l_terms_inactive_date,
	    x_always_take_disc_flag,
	    x_pay_date_basis_lookup_code,
	    x_pay_date_basis_disp,
	    x_invoice_currency_code,
	    x_vendor_pay_group_lookup_code,
	    x_vendor_pay_group_disp,
	    x_sys_auto_calc_int_flag,
	    x_terms_date_basis,
	    x_terms_date_basis_disp,
	    x_fin_require_matching,
	    x_sysdate,
	   -- x_use_bank_charge_flag,
           -- x_bank_charge_bearer
            x_fin_match_option               --bug6075649
    FROM  ap_lookup_codes lc2,
	    ap_lookup_codes lc3,
	    po_lookup_codes pc3,
	    ap_terms tm,
	    ap_product_setup aps
    WHERE	    lc2.lookup_type(+) 		= 'PAY DATE BASIS'
    AND	    lc2.lookup_code(+) 		= aps.pay_date_basis_lookup_code
    AND	    lc3.lookup_type(+) 		= 'TERMS DATE BASIS'
    AND	    lc3.lookup_code(+) 		= aps.terms_date_basis
    AND	    pc3.lookup_type(+) 		= 'PAY GROUP'
    AND	    pc3.lookup_code(+) 		= aps.supplier_pay_group_lookup_code
    AND	    aps.terms_id		      = tm.term_id(+);

   --
   -- Clear defaults if inactive
   --
	--
	--
	if sysdate > l_terms_inactive_date then
		x_terms_id 	:= null;
		x_terms_disp	:= null;
	end if;

   if x_pay_date_basis_lookup_code is  NULL then
      debug_info := 'Select pay_date_basis displayed field';
      SELECT  lc.lookup_code,
              lc.displayed_field
      INTO    x_pay_date_basis_lookup_code,
	      x_pay_date_basis_disp
      FROM    ap_lookup_codes lc
      WHERE   lc.lookup_type = 'PAY DATE BASIS'
      AND     lc.lookup_code = 'DISCOUNT';
   end if;

   --
   EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN
		('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
	      'TERMS_ID = ' || x_terms_id ||
	      'PAY_DATE_BASIS_LOOKUP_CODE = ' || x_pay_date_basis_lookup_code ||
	      'VENDOR_PAY_GROUP_LOOKUP_CODE = ' ||
		x_vendor_pay_group_lookup_code ||
	        'TERMS_DATE_BASIS = ' || x_terms_date_basis);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;


   END Initialize_Supplier_Attr;
--

END AP_APXVDMVD_PKG;

/
