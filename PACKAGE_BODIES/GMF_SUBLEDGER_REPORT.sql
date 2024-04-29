--------------------------------------------------------
--  DDL for Package Body GMF_SUBLEDGER_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_SUBLEDGER_REPORT" AS
/* $Header: gmfsubrb.pls 115.45 2004/07/23 17:09:50 dvadivel ship $ */

/* variables for break processing in the report. */
last_voucher_id         gl_subr_led_vw.voucher_id%TYPE;
last_sevt_code          gl_subr_led_vw.sub_event_code%TYPE;
last_doc_no             gl_subr_led_vw.doc_no%TYPE;
/* BUG 2302794 */
doc_no_sav              gl_subr_led_vw.doc_no%TYPE;
last_orgn_code          gl_subr_led_vw.orgn_code%TYPE;
last_line_id            gl_subr_led_vw.line_id%TYPE; /* B2262087 changed type from line_no to line_id */
line_no                 number;
page_no                 number;
lines_per_page          NUMBER := 60; /* Bug 2048108 */

/* variables for storing amounts and totals. */
dr_base                 gl_subr_led_vw.amount_base%TYPE;
cr_base                 gl_subr_led_vw.amount_base%TYPE;
dr_trans                gl_subr_led_vw.amount_trans%TYPE;
cr_trans                gl_subr_led_vw.amount_trans%TYPE;
format_base             varchar2(34); --B1316233   umoogala 08/17/01: Increased from 24 to 34
format_trans            varchar2(34); --B1316233   umoogala 08/17/01: Increased from 24 to 34
local_format_base       varchar2(24); -- B1316233
local_format_trans      varchar2(24); -- B1316233
line_total_dr           gl_subr_led_vw.amount_base%TYPE;
line_total_cr           gl_subr_led_vw.amount_base%TYPE;
voucher_total_dr        gl_subr_led_vw.amount_base%TYPE;
voucher_total_cr        gl_subr_led_vw.amount_base%TYPE;
sevt_total_dr           gl_subr_led_vw.amount_base%TYPE;
sevt_total_cr           gl_subr_led_vw.amount_base%TYPE;
doc_total_dr            gl_subr_led_vw.amount_base%TYPE;
doc_total_cr            gl_subr_led_vw.amount_base%TYPE;
rep_total_dr            gl_subr_led_vw.amount_base%TYPE;
rep_total_cr            gl_subr_led_vw.amount_base%TYPE;
amount_constant         constant number := 1000000000;

/* Report Title */
rep_title               VARCHAR2(180);

/* Variable to translate canonical dates to apps dates */
vstart_date     DATE;
vend_date       DATE;

/* Begin Bug#2424449 Piyush K. Mishra
Incorporated B#2255269 */
min_date        DATE;
/* End Bug#2424449 */

/* Main procedure which runs the report */
PROCEDURE RUN(
	errbuf                  OUT NOCOPY      VARCHAR2,
	retcode                 OUT NOCOPY      VARCHAR2,
	preference_no           IN      VARCHAR2,
	pco_code                IN      VARCHAR2,
	pcurrency_code          IN      VARCHAR2,
	pfiscal_year            IN      VARCHAR2,
	pperiod                 IN      VARCHAR2,
	pstart_date             IN      VARCHAR2,
	pend_date               IN      VARCHAR2,
	pfrom_voucher_no        IN      VARCHAR2,
	pto_voucher_no          IN      VARCHAR2,
	pfrom_source_code       IN      VARCHAR2,
	pto_source_code         IN      VARCHAR2,
	pfrom_sub_event_code    IN      VARCHAR2,
	pto_sub_event_code      IN      VARCHAR2,
	report_on               IN      VARCHAR2,
	rep_mode                IN      VARCHAR2,
	plines_per_page         IN      VARCHAR2,
	ppage_size              IN      NUMBER  DEFAULT 132)  -- Bug 2804810
IS
	/* Dynamically order the report based upon the parameter selected.
	 Cursor for running report on actual subledger table */
	CURSOR c_gl_subr_led_vw IS
	SELECT
		co_code,
		fiscal_year,
		period,
		sub_event_code,
		voucher_id,
		doc_type,
		doc_id,
		line_id,
		acct_ttl_code,
		acctg_unit_no,
		acct_no,
		DECODE(SUM(amount_base*debit_credit_sign), 0, 1,
		(SUM(amount_base*debit_credit_sign)/ABS(SUM(amount_base*debit_credit_sign)))) debit_credit_sign,
		acctg_unit_desc,
		acct_desc,
		ABS(SUM(amount_base*debit_credit_sign)) amount_base,
		ABS(SUM(amount_trans*debit_credit_sign)) amount_trans,
		currency_base,
		currency_trans,
		SUM(jv_quantity) jv_quantity,
		jv_quantity_um,
		sub_event_desc,
		trans_source_code,
		trans_source_desc,
		-- gl_trans_date,
		orgn_code,
		doc_no,
		doc_date,
		line_no,
		resource_item_no,
		resource_item_no_desc,
		trans_date,
		whse_code,
		trans_qty_usage,
		trans_qty_usage_um,
		reference_no
	FROM gl_subr_led_vw
	WHERE
		reference_no = nvl(preference_no,reference_no) and      --bug# 1801491
		co_code = pco_code and
		fiscal_year = to_number(pfiscal_year) and
		period = to_number(pperiod) and
		gl_trans_date >= vstart_date and
		gl_trans_date <= vend_date and
		trans_source_code >= nvl(pfrom_source_code, trans_source_code) and
		trans_source_code <= nvl(pto_source_code, trans_source_code) and
		sub_event_code >= nvl(pfrom_sub_event_code, sub_event_code) and
		sub_event_code <= nvl(pto_sub_event_code, sub_event_code) and
		nvl(voucher_id,-99) >= nvl(to_number(pfrom_voucher_no), nvl(voucher_id,-99)) and
		nvl(voucher_id,-99) <= nvl(to_number(pto_voucher_no), nvl(voucher_id,-99))
	GROUP BY
		co_code,
		fiscal_year,
		period,
		decode(rep_mode, 'SDV',sub_event_code, 'SVD',sub_event_code,
				 'VSD',nvl(voucher_id,0), 'VDS',nvl(voucher_id,0),
				 'DSV',doc_type||doc_no, 'DVS',doc_type||doc_no),
		decode(rep_mode, 'SDV',doc_type||doc_no, 'SVD',nvl(voucher_id,0),
				 'VSD',sub_event_code, 'VDS', doc_type||doc_no,
				 'DSV',sub_event_code, 'DVS',nvl(voucher_id,0)),
		decode(rep_mode, 'SVD',doc_type||doc_no, 'SDV',nvl(voucher_id,0),
				 'VSD',doc_type||doc_no, 'VDS',sub_event_code,
				 'DSV',nvl(voucher_id,0), 'DVS',sub_event_code),
		line_id, /* Everything from this point onwards will have no effect on the ordering */
		sub_event_code,
		voucher_id,
		doc_type,
		doc_no,
		doc_id,
		acct_ttl_code,
		acctg_unit_no,
		acct_no,
		acctg_unit_desc,
		acct_desc,
		currency_base,
		currency_trans,
		jv_quantity_um,
		sub_event_desc,
		trans_source_code,
		trans_source_desc,
		-- gl_trans_date,
		orgn_code,
		doc_date,
		line_no,
		resource_item_no,
		resource_item_no_desc,
		trans_date,
		whse_code,
		trans_qty_usage,
		trans_qty_usage_um,
		reference_no;

	/* Cursor for running report on test subledger table */
	CURSOR c_gl_subr_tst_vw IS
	SELECT
		co_code,
		fiscal_year,
		period,
		sub_event_code,
		voucher_id,
		doc_type,
		doc_id,
		line_id,
		acct_ttl_code,
		acctg_unit_no,
		acct_no,
		DECODE(SUM(amount_base*debit_credit_sign), 0, 1,
		(SUM(amount_base*debit_credit_sign)/ABS(SUM(amount_base*debit_credit_sign)))) debit_credit_sign,
		acctg_unit_desc,
		acct_desc,
		ABS(SUM(amount_base*debit_credit_sign)) amount_base,
		ABS(SUM(amount_trans*debit_credit_sign)) amount_trans,
		currency_base,
		currency_trans,
		SUM(jv_quantity) jv_quantity,
		jv_quantity_um,
		sub_event_desc,
		trans_source_code,
		trans_source_desc,
		-- gl_trans_date,
		orgn_code,
		doc_no,
		doc_date,
		line_no,
		resource_item_no,
		resource_item_no_desc,
		trans_date,
		whse_code,
		trans_qty_usage,
		trans_qty_usage_um,
		reference_no
	FROM gl_subr_tst_vw
	WHERE
		reference_no = nvl(preference_no,reference_no) and      --bug# 1801491
		co_code = pco_code and
		fiscal_year = to_number(pfiscal_year) and
		period = to_number(pperiod) and
		gl_trans_date >= vstart_date and
		gl_trans_date <= vend_date and
		trans_source_code >= nvl(pfrom_source_code, trans_source_code) and
		trans_source_code <= nvl(pto_source_code, trans_source_code) and
		sub_event_code >= nvl(pfrom_sub_event_code, sub_event_code) and
		sub_event_code <= nvl(pto_sub_event_code, sub_event_code) and
		nvl(voucher_id,-99) >= nvl(to_number(pfrom_voucher_no), nvl(voucher_id,-99)) and
		nvl(voucher_id,-99) <= nvl(to_number(pto_voucher_no), nvl(voucher_id,-99))
	GROUP BY
		co_code,
		fiscal_year,
		period,
		decode(rep_mode, 'SDV',sub_event_code, 'SVD',sub_event_code,
				 'VSD',nvl(voucher_id,0), 'VDS',nvl(voucher_id,0),
				 'DSV',doc_type||doc_no, 'DVS',doc_type||doc_no),
		decode(rep_mode, 'SDV',doc_type||doc_no, 'SVD',nvl(voucher_id,0),
				 'VSD',sub_event_code, 'VDS', doc_type||doc_no,
				 'DSV',sub_event_code, 'DVS',nvl(voucher_id,0)),
		decode(rep_mode, 'SVD',doc_type||doc_no, 'SDV',nvl(voucher_id,0),
				 'VSD',doc_type||doc_no, 'VDS',sub_event_code,
				 'DSV',nvl(voucher_id,0), 'DVS',sub_event_code),
		line_id, /* Everything from this point onwards will have no effect on the ordering */
		sub_event_code,
		voucher_id,
		doc_type,
		doc_no,
		doc_id,
		acct_ttl_code,
		acctg_unit_no,
		acct_no,
		acctg_unit_desc,
		acct_desc,
		currency_base,
		currency_trans,
		jv_quantity_um,
		sub_event_desc,
		trans_source_code,
		trans_source_desc,
		-- gl_trans_date,
		orgn_code,
		doc_date,
		line_no,
		resource_item_no,
		resource_item_no_desc,
		trans_date,
		whse_code,
		trans_qty_usage,
		trans_qty_usage_um,
		reference_no;

	/* VC Bug 1924250 - Detail info on documents */
	/* Cursor for running report on test subledger table */
	CURSOR c_po_recv_dtl(v_doc_id NUMBER, v_line_id NUMBER) IS
	SELECT
		h.billing_currency billing_currency,
		h.receipt_exchange_rate receipt_exchange_rate,
		v.vendor_no vendor_no,
		v.vendor_name vendor_name,
		nvl(d.po_id,0) po_id,
		nvl(d.poline_id,0) poline_id
	FROM
		po_recv_dtl d,
		po_recv_hdr h,
		po_vend_mst v
	WHERE
		d.recv_id = v_doc_id
	AND     d.line_id = v_line_id
	AND     d.recv_id = h.recv_id
	AND     d.shipvend_id = v.vendor_id;
	c_po_recv       c_po_recv_dtl%ROWTYPE;

	CURSOR c_po_ordr_hdr(v_po_id NUMBER) IS
	SELECT
		h.orgn_code orgn_code,
		h.po_no po_no
	FROM
		po_ordr_hdr h
	WHERE
		h.po_id = v_po_id;
	c_po_ordr       c_po_ordr_hdr%ROWTYPE;

	CURSOR c_po_rtrn_dtl(v_doc_id NUMBER, v_line_id NUMBER) IS
	SELECT
		r.orgn_code orgn_code,
		r.recv_no recv_no,
		r.recv_date recv_date,
		r.billing_currency billing_currency,
		r.receipt_exchange_rate receipt_exchange_rate,
		v.vendor_no vendor_no,
		v.vendor_name vendor_name,
		nvl(rd.po_id, 0) po_id,
		nvl(rd.poline_id,0) poline_id
	FROM
		po_rtrn_dtl rd,
		po_rtrn_hdr rh,
		po_recv_hdr r,
		po_vend_mst v
	WHERE
		rd.line_id = v_line_id
	AND     rd.return_id = v_doc_id
	AND     rd.recv_id = r.recv_id
	AND     rh.return_vendor_id = v.vendor_id;
	c_po_rtrn       c_po_rtrn_dtl%ROWTYPE;

	CURSOR c_op_ordr_dtl(v_doc_id NUMBER, v_line_id NUMBER) IS
	SELECT
		h.orgn_code orgn_code,
		h.order_no order_no,
		h.order_date order_date,
		c.cust_no as cust_no,
		c.cust_name cust_name
	FROM
		op_ordr_dtl d,
		op_ordr_hdr h,
		op_cust_mst c
	WHERE
		d.line_id = v_line_id
	AND     d.bol_id = v_doc_id
	AND     d.order_id = h.order_id
	AND     d.shipcust_id = c.cust_id;
	c_op_ordr       c_op_ordr_dtl%ROWTYPE;

	CURSOR c_pm_btch_hdr(v_batch_id NUMBER) IS
	SELECT
		b.plant_code ,
		b.batch_no ,
		b.wip_whse_code,
		b.actual_start_date,
		b.actual_cmplt_date,
		nvl(b.routing_id,0) routing_id,
		f.formula_no,
		f.formula_vers,
		t.meaning
	FROM
		gme_batch_header b,
		fm_form_mst f,
		gem_lookups t
	WHERE
		b.batch_id = v_batch_id
	AND     b.formula_id = f.formula_id
	AND     to_char(b.batch_status) = t.lookup_code
	AND     t.lookup_type = upper('batch_status');
	c_pm_btch       c_pm_btch_hdr%ROWTYPE;

	CURSOR c_fm_rout_hdr(v_routing_id NUMBER) IS
	SELECT
		r.routing_no,
		r.routing_vers
	FROM
		fm_rout_hdr r
	WHERE
		r.routing_id = v_routing_id;
	c_fm_rout       c_fm_rout_hdr%ROWTYPE;

	/* Begin Bug#2088655 P.Raghu - Detail info on Document Type 'PROC' */
	CURSOR c_pur_ship_dtl(v_doc_id NUMBER, v_line_id NUMBER) IS
	SELECT
		nvl(t.currency_conversion_rate, 1.0) exchange_rate,
		t.currency_code billing_currency,
		NVL(poh.segment1,' ') po_no,
		NVL(v.vendor_no,' ') vendor_no,
		NVL(v.vendor_name,' ') vendor_name,
		nvl(t.po_unit_price, 0.0) po_unit_price,
		uom1.um_code price_um
	FROM
	        rcv_transactions t,
		sy_uoms_mst uom1,
		po_headers_all poh,
		po_vend_mst v
	WHERE
                t.shipment_header_id = v_doc_id
                AND t.transaction_id     = v_line_id
		AND t.source_doc_unit_of_measure = uom1.unit_of_measure
                AND t.po_header_id       = poh.po_header_id (+)
                 AND t.vendor_site_id     = v.of_vendor_site_id (+)
                 AND nvl(v.co_code, pco_code) = pco_code ;

   c_pur_ship       c_pur_ship_dtl%ROWTYPE;
   /* End Bug#2088655 */

	/* VC Bug 2048108 - Detail info on lines */
	CURSOR c_po_recv_hst(v_sub_event_code VARCHAR2,
			v_recv_id NUMBER, v_recv_line_id NUMBER) IS
	SELECT
		h.net_price,
		h.price_um
	FROM
		po_recv_hst h,
		gl_sevt_mst sb
	WHERE
		h.recv_id = v_recv_id
	AND     h.recv_line_id = v_recv_line_id
	AND     sb.sub_event_type = h.sub_event_type
	AND     sb.sub_event_code = v_sub_event_code;

	c_recv_hst      c_po_recv_hst%ROWTYPE;

	CURSOR c_ic_tran_pnd(v_doc_type VARCHAR2,
			v_doc_id NUMBER, v_line_id NUMBER) IS
	SELECT
		reason_code
	FROM
		ic_tran_pnd
	WHERE
		doc_type = v_doc_type
	AND     doc_id = v_doc_id
	AND     line_id = v_line_id
	UNION ALL
	SELECT
		reason_code
	FROM
		ic_tran_cmp
	WHERE
		doc_type = v_doc_type
	AND     doc_id = v_doc_id
	AND     line_id = v_line_id;
	c_ic_tran       c_ic_tran_pnd%ROWTYPE;

	--Begin Bug#3072197
	--To retrieve Reason code for Invetory Transfers (XFER).
	CURSOR c_ic_xfer_tran(v_trans_id NUMBER) IS
	SELECT
		reason_code
	FROM
		ic_tran_pnd
	WHERE
	   trans_id = v_trans_id;
	--End Bug#3072197

	CURSOR c_pm_matl_dtl(v_line_id NUMBER) IS
	SELECT
		d.wip_plan_qty,
                d.original_qty, --  Bug# 3772552 - Fwd port for 3544905
		t.whse_code,
		t.trans_um
	FROM
		ic_tran_pnd t,
		gme_material_details d
	WHERE
		t.doc_type = 'PROD'
	AND     t.line_id = v_line_id
	AND     d.material_detail_id = t.line_id;

	c_pm_matl       c_pm_matl_dtl%ROWTYPE;

	/* Begin Bug#2365391 - Nayini Vikranth */
	/* Get item_no, item_desc1, whse_code, trans_qty, trans_um */
	CURSOR c_ic_piph_picy_info(v_doc_type VARCHAR2,
			v_doc_id NUMBER, v_line_id NUMBER) IS
	SELECT
		t.doc_id,
		t.line_id,
		t.whse_code,
		i.item_no,
		i.item_desc1,
		sum(t.trans_qty) trans_qty,
		t.trans_um
	FROM
		ic_tran_cmp t,
		ic_item_mst i
	WHERE
		t.doc_type = v_doc_type
	AND     t.doc_id = v_doc_id
	AND     t.line_id = v_line_id
	AND     t.item_id = i.item_id
	GROUP BY
		t.doc_id,
		t.line_id,
		t.whse_code,
		i.item_no,
		i.item_desc1,
		t.trans_um;
	c_ic_piph_picy  c_ic_piph_picy_info%ROWTYPE;
	/* End Bug#2365391 */

       /* Begin Bug 2932095 */
       CURSOR c_ic_piph_picy_doc(v_doc_id NUMBER) IS
	 SELECT c.orgn_code, c.cycle_no
	   FROM ic_cycl_hdr c
	  WHERE c.cycle_id = v_doc_id;

 	/* Begin Bug# 3772552 : Fwd port for 3601833 Added the cursor c_ic_rval_quantity */
       CURSOR c_ic_rval_quantity(v_doc_id NUMBER,v_line_id NUMBER,
                                 v_reference_no NUMBER) IS
	  SELECT sum(ic.loct_onhand)
          FROM  ic_perd_bal ic
	    ,ic_whse_mst wh
	    ,gl_subr_sta st
          WHERE  ic.whse_code   = wh.whse_code
	  AND wh.mtl_organization_id = v_doc_id
	  AND ic.item_id             = v_line_id
	  AND st.reference_no        = v_reference_no
	  AND st.crev_inv_prev_cal   = ic.fiscal_year
	  AND st.crev_inv_prev_per   = ic.period
          GROUP BY ic.item_id,ic.whse_code
          HAVING SUM(ic.loct_onhand) <> 0;
        /*End Bug#3772552 */


	i       NUMBER;
	j       NUMBER;
	r       c_gl_subr_led_vw%ROWTYPE;
	l_fiscal_year VARCHAR2(4);
	l_quantity    NUMBER;
	l_period      NUMBER;
BEGIN
	/* Begin Bug#2424449 Piyush K. Mishra
	   Incorporated B#2255269 */

	min_date := GMA_GLOBAL_GRP.SY$MIN_DATE;
	/*
	* min_date := to_date(ggm_constant.get_constant('SY$MAX_DATE'),'DD-MON-YYYY HH24:MI:SS');
	* -- Bug #2662570 (JKB) Removed reference to GMA_GLOBAL_GRP.SY$MAX_DATE above.
	*/
	--END Bug#2424449

	/* Intialize the labels with translated values */
	INITIALIZE_LABELS;
	/* Convert canonical dates to app dates */
	vstart_date := fnd_date.canonical_to_date(pstart_date);
	vend_date := fnd_date.canonical_to_date(pend_date);

	lines_per_page := nvl(plines_per_page, 60); /* Bug 2048108 */

	rep_total_dr := 0;
	rep_total_cr := 0;

	/* Format the report title */
	rep_title := '|'||' '||RPAD(to_char(sysdate),36,' ');
	IF report_on = 2 THEN rep_title := substrb(rep_title || L_GMF_TEST || ' ',1,132); END IF; /* B1309946 */
	rep_title := substrb(rep_title || L_GMF_SUBLEDGER_REPORT||' ',1,132);    /* B1309946 */

	/* RS Bug 1878244 - truncate rep_title if lengthb greater than 132 */
	FOR i in 1..3 LOOP
	  IF (substr(rep_mode,i,1)='D') THEN rep_title := substrb(rep_title|| L_GMF_DOCUMENT||'/',1,132); END IF;
	  IF (substr(rep_mode,i,1)='S') THEN rep_title := substrb(rep_title|| L_GMF_SUB_EVENT||'/',1,132); END IF;
	  IF (substr(rep_mode,i,1)='V') THEN rep_title := substrb(rep_title|| L_GMF_VOUCHER||'/',1,132); END IF;
	END LOOP;

	/* get rid of the last slash */
	rep_title := substr (rep_title, 1, length(rep_title)-1);
	PRINT_LINE (substr(rep_title||' '||LPAD(L_GMF_PAGE_NO, 15,' ')||':'||
		RPAD(to_char(page_no), 6,' '),1,132)); /* Bug 2048108 */

	/* Print report header */
	PRINT_LINE ('|');
	/* Begin bug# 1801491 */
	IF preference_no IS NOT NULL THEN
	  PRINT_LINE ('|'||LPAD(L_GMF_REFERENCE_NO,16,' ')||': '||preference_no);
	END IF;
	/* End of bug# 1801491 */
	PRINT_LINE ('|'||LPAD(L_GMF_COMPANY,16,' ')||': '||pco_code);
	PRINT_LINE ('|'||LPAD(L_GMF_CURRENCY,16,' ')||': '||pcurrency_code);
	PRINT_LINE ('|'||LPAD(L_GMF_FISCAL_YEAR,16,' ')||': '||pfiscal_year);
	PRINT_LINE ('|'||LPAD(L_GMF_PERIOD,16,' ')||': '||pperiod);
	PRINT_LINE ('|'||LPAD(L_GMF_START_DATE,16,' ')||': '||to_char(vstart_date));
	PRINT_LINE ('|'||LPAD(L_GMF_END_DATE,16,' ')||': '||to_char(vend_date));
	PRINT_LINE ('|'||LPAD(L_GMF_FROM,34,' ')||' '||LPAD(L_GMF_TO,16,' '));
	PRINT_LINE ('|'||LPAD(L_GMF_VOUCHER,16,' ')||': '||LPAD(pfrom_voucher_no,16,' ')||
		' '||LPAD(pto_voucher_no,16,' '));
	PRINT_LINE ('|'||LPAD(L_GMF_SOURCE,16,' ')||': '||LPAD(pfrom_source_code,16,' ')||' '||
		LPAD(pto_source_code,16,' '));
	PRINT_LINE ('|'||LPAD(L_GMF_SUB_EVENT,16,' ')||': '||LPAD(pfrom_sub_event_code,16,' ')||
		' '||LPAD(pto_sub_event_code,16,' '));

	/* Open the right cursor based upon the user specified parameter */
	IF report_on = 1 THEN
		OPEN c_gl_subr_led_vw;
	ELSE
		OPEN c_gl_subr_tst_vw;
	END IF;

	/* Start the report processing */
	WHILE TRUE
	LOOP
		/* Fetch row form the right cursor based upon the user specified parameter */
		/* BUG 2302794 */
		doc_no_sav  := last_doc_no ;

		IF report_on = 1 THEN
			FETCH c_gl_subr_led_vw INTO r;
			EXIT WHEN c_gl_subr_led_vw%NOTFOUND;
		ELSE
			FETCH c_gl_subr_tst_vw INTO r;
			EXIT WHEN c_gl_subr_tst_vw%NOTFOUND;
		END IF;
		/* Begin Bug#2424449 Piyush K. Mishra
		Incorporated B#2255269 */
		if (r.doc_date <= min_date) then
		  r.doc_date := NULL ;
		END IF;
		if (r.trans_date <= min_date) then
		  r.trans_date := NULL ;
		END IF;
		--End Bug#2424449

		/* Print Totals. This needs to handled first because we can only know if a
		 break occured after getting a new row */

		/* Begin Bug#2365391 Nayini Vikranth */
		/* Get orgn_code and doc_no for piph and picy trans */
		/* Bug 2932095  Changed to cursor */
		IF (r.doc_type in ('PIPH','PICY')) THEN
		  OPEN c_ic_piph_picy_doc(r.doc_id);
		  FETCH c_ic_piph_picy_doc INTO r.orgn_code, r.doc_no;
		  CLOSE c_ic_piph_picy_doc;
		   /* line_no is null for piph, picy trans. set it to '1' */
			r.line_no := '1';
		/* Begin Bug 2230751 */
		ELSIF (r.doc_type = 'RVAL') THEN
		  IF r.doc_id <> -9	/* Bug 3196846: added if condition */
		  THEN
 		/************* Bug 3772552****************/
			/*SELECT sum(ic.loct_onhand)
			    INTO l_quantity
			    FROM  ic_perd_bal ic
				 ,ic_whse_mst wh
				 ,gl_subr_sta st
			  WHERE  ic.whse_code               = wh.whse_code
				 AND wh.mtl_organization_id = r.doc_id
				 AND ic.item_id             = r.line_id
				 AND st.reference_no        = r.reference_no
				 AND st.crev_inv_prev_cal   = ic.fiscal_year
				 AND st.crev_inv_prev_per   = ic.period
			  GROUP BY ic.item_id,ic.whse_code
			  HAVING SUM(ic.loct_onhand) <> 0;  */ -- Commented and added a cursor c_ic_rval_quantity

                          OPEN  c_ic_rval_quantity(r.doc_id, r.line_id, r.reference_no);
			  FETCH c_ic_rval_quantity INTO l_quantity;
               		  IF (c_ic_rval_quantity%NOTFOUND) THEN
		               l_quantity := 0;
	                  END IF;
			  CLOSE c_ic_rval_quantity;
		/************** Bug 3772552 ****************/

		  ELSIF r.doc_id = -9
		  THEN
		  	/* This is Lot Cost Adjustment */
		  	SELECT onhand_qty
			  INTO l_quantity
			  FROM gmf_lot_cost_adjustments
			 WHERE adjustment_id = r.line_id;
		  END IF;	/* End bug 3196846 */
		/* End bug 2230751 */
		END IF;
		/* End Bug#2365391 */

		PRINT_TOTALS (r.line_id, r.orgn_code||r.doc_no, r.sub_event_code, r.voucher_id, rep_mode, ppage_size);  -- Bug 2804810

		/* If a break occured for sub-event, voucher or document, display a new header */
		/* RS Bug 1878244 - lpad/rpad L_GMF_DOC_NO and L_GMF_DOC_DATE */

      /* Begin Bug#3437426 D.Sailaja */
      /* Transaction Date of rcv_transactions table instead of Shipped date from rcv_shipment_headers */
      IF (r.doc_type = 'PORC') THEN
         r.doc_date := r.trans_date;
      END IF;
      /* End Bug#3437426 */

		IF (last_sevt_code IS NULL OR last_sevt_code <> r.sub_event_code OR
		    last_voucher_id IS NULL OR last_voucher_id <> nvl(r.voucher_id, 0) OR
		    last_orgn_code||last_doc_no IS NULL OR last_orgn_code||last_doc_no <> r.orgn_code||r.doc_no) THEN

			IF ppage_size = 132 THEN PRINT_LINE ( RPAD('|',132,'-'));  -- Bug 2804810
			ELSIF ppage_size = 180 THEN PRINT_LINE ( RPAD('|',180,'-'));
			END IF;

			PRINT_LINE ( '|'||LPAD(L_GMF_SUB_EVENT,16,' ')||': '||RPAD(r.sub_event_desc,61,' ')||
				LPAD(L_GMF_VOUCHER,18,' ')||': '||RPAD(to_char(r.voucher_id),15,' '));
			PRINT_LINE ( '|'||LPAD(L_GMF_DOC_TYPE,16,' ')|| ': '||RPAD(r.doc_type,4,' ') || ' '||
				LPAD(L_GMF_DOC_NO,16,' ')||': '||RPAD((r.orgn_code || ' ' ||r.doc_no),37,' ')||
				' '||LPAD(L_GMF_DOC_DATE,18,' ')||': '||r.doc_date ); /* Bug 2641704 */

			/* VC Bug 1924250 - Detail info on documents */
			IF (r.doc_type = 'RECV') THEN
				OPEN c_po_recv_dtl(r.doc_id, r.line_id);
				FETCH c_po_recv_dtl INTO c_po_recv;
				CLOSE c_po_recv_dtl;
				PRINT_LINE ( '|'||LPAD(L_GMF_VENDOR,16,' ')||': '||RPAD(c_po_recv.vendor_no,32,' ')||
				RPAD(c_po_recv.vendor_name,40,' '));
				IF (c_po_recv.po_id > 0) THEN
					OPEN c_po_ordr_hdr(c_po_recv.po_id);
					FETCH c_po_ordr_hdr INTO c_po_ordr;
					CLOSE c_po_ordr_hdr;
					/* Bug 2641704 Replaced with next line PRINT_LINE ( '|'||LPAD(L_GMF_PO_NO,16,' ')||': '||RPAD(c_po_ordr.orgn_code,4,' ')||' '||RPAD(c_po_ordr.po_no,32,' ')|| */
					PRINT_LINE ( '|'||LPAD(L_GMF_PO_NO,16,' ')||': '||RPAD((c_po_ordr.orgn_code||' '||c_po_ordr.po_no),37,' ')||
					LPAD(L_GMF_BILL_CURR,16,' ')||': '||RPAD(c_po_recv.billing_currency,4,' ')||
					LPAD(L_GMF_XCHG_RATE,18,' ')||': '||RPAD(to_char(c_po_recv.receipt_exchange_rate),15,' '));
				ELSE
					PRINT_LINE ( '|'||LPAD(L_GMF_PO_NO,16,' ')||': '||RPAD(' ',4,' ')||' '||LPAD(' ',32,' ')||
					LPAD(L_GMF_BILL_CURR,16,' ')||': '||RPAD(c_po_recv.billing_currency,4,' ')||
					LPAD(L_GMF_XCHG_RATE,18,' ')||': '||RPAD(to_char(c_po_recv.receipt_exchange_rate),15,' '));
				END IF;
			ELSIF (r.doc_type = 'RTRN') THEN
				OPEN c_po_rtrn_dtl(r.doc_id, r.line_id);
				FETCH c_po_rtrn_dtl INTO c_po_rtrn;
				CLOSE c_po_rtrn_dtl;
				/* Bug 2641704 Replaced with next line PRINT_LINE ( '|'||LPAD(L_GMF_RECEIPT,16,' ')||': '||RPAD(c_po_rtrn.orgn_code,4,' ') || ' ' ||RPAD(c_po_rtrn.recv_no,16,' ')||' '|| */
				PRINT_LINE ( '|'||LPAD(L_GMF_RECEIPT,16,' ')||': '||RPAD((c_po_rtrn.orgn_code||' '||c_po_rtrn.recv_no),37,' ')||' '||
				LPAD(L_GMF_RECEIPT_DATE,14,' ')||': '||to_char(c_po_rtrn.recv_date)||' '||LPAD(L_GMF_VENDOR,12,' ')||': '||RPAD(c_po_rtrn.vendor_no,16,' ')|| RPAD(c_po_rtrn.vendor_name,16,' '));
				IF (c_po_rtrn.po_id > 0) THEN
					OPEN c_po_ordr_hdr(c_po_rtrn.po_id);
					FETCH c_po_ordr_hdr INTO c_po_ordr;
					CLOSE c_po_ordr_hdr;
					/* Bug 2641704 Replaced with next line PRINT_LINE ( '|'||LPAD(L_GMF_PO_NO,16,' ')||': '||RPAD(c_po_ordr.orgn_code,4,' ')||' '||RPAD(c_po_ordr.po_no,32,' ')|| */
					PRINT_LINE ( '|'||LPAD(L_GMF_PO_NO,16,' ')||': '||RPAD((c_po_ordr.orgn_code||' '||c_po_ordr.po_no),37,' ')||
					LPAD(L_GMF_BILL_CURR,16,' ')||': '||RPAD(c_po_rtrn.billing_currency,4,' ')||
					LPAD(L_GMF_XCHG_RATE,18,' ')||': '||RPAD(to_char(c_po_rtrn.receipt_exchange_rate),15,' '));
				ELSE
					PRINT_LINE ( '|'||LPAD(L_GMF_PO_NO,16,' ')||': '||RPAD(' ',4,' ')||' '||RPAD(' ',32,' ')||
					LPAD(L_GMF_BILL_CURR,16,' ')||': '||RPAD(c_po_rtrn.billing_currency,4,' ')||
					LPAD(L_GMF_XCHG_RATE,18,' ')||': '||RPAD(to_char(c_po_rtrn.receipt_exchange_rate),15,' '));
				END IF;
			ELSIF (r.doc_type = 'OPSP') THEN
				OPEN c_op_ordr_dtl(r.doc_id, r.line_id);
				FETCH c_op_ordr_dtl INTO c_op_ordr;
				CLOSE c_op_ordr_dtl;
				PRINT_LINE ( '|'||LPAD(L_GMF_CUSTOMER,16,' ')||': '||RPAD(c_op_ordr.cust_no,32,' ')|| RPAD(c_op_ordr.cust_name,40,' '));
				/* Bug 2641704 Replaced with next line PRINT_LINE ( '|'||LPAD(L_GMF_SO_NO,16,' ')||': '||RPAD(c_op_ordr.orgn_code,4,' ')||' '||RPAD(c_op_ordr.order_no,32,' ')|| */
				PRINT_LINE ( '|'||LPAD(L_GMF_SO_NO,16,' ')||': '||RPAD((c_op_ordr.orgn_code||' '||c_op_ordr.order_no),37,' ')||
					LPAD(L_GMF_SO_DATE,18,' ')||': '||to_char(c_op_ordr.order_date));
			/* Begin Bug#2088655 P.Raghu */
			ELSIF (r.doc_type = 'PORC') THEN
				OPEN c_pur_ship_dtl(r.doc_id, r.line_id);
				FETCH c_pur_ship_dtl INTO c_pur_ship;
				CLOSE c_pur_ship_dtl;
				PRINT_LINE ( '|'||LPAD(L_GMF_VENDOR,16,' ')||': '||RPAD(c_pur_ship.vendor_no,32,' ')||
				RPAD(c_pur_ship.vendor_name,40,' '));
				PRINT_LINE ( '|'||LPAD(L_GMF_PO_NO,16,' ')||': '||RPAD(c_pur_ship.po_no,20,' ')||
				LPAD(L_GMF_BILL_CURR,16,' ')||': '||RPAD(c_pur_ship.billing_currency,4,' ')||
				LPAD(L_GMF_XCHG_RATE,18,' ')||': '||RPAD(to_char(c_pur_ship.exchange_rate),15,' '));
			/* End Bug#2088655 */
			ELSIF (r.doc_type = 'PROD') THEN
				OPEN c_pm_btch_hdr(r.doc_id);
				FETCH c_pm_btch_hdr INTO c_pm_btch;
				CLOSE c_pm_btch_hdr;
				/* Begin Bug#2424449 Piyush K. Mishra
				Incorporated B#2255269 */
				if (c_pm_btch.actual_start_date <= min_date) then
				  c_pm_btch.actual_start_date := NULL ;
				END IF;
				if (c_pm_btch.actual_cmplt_date <= min_date) then
				  c_pm_btch.actual_cmplt_date := NULL ;
				END IF;
				--End Bug#2424449

				PRINT_LINE ( '|'||LPAD(L_GMF_FORMULA,16,' ')||': '||RPAD(c_pm_btch.formula_no,32,' ')||' '||LPAD(L_GMF_VERSION,16,' ')||': '||
				RPAD(c_pm_btch.formula_vers,5,' ')||' '||LPAD(L_GMF_ACTUAL_START_DATE,22,' ')||': '||RPAD(to_char(c_pm_btch.actual_start_date),18,' '));
				IF (c_pm_btch.routing_id > 0) THEN
					OPEN c_fm_rout_hdr(c_pm_btch.routing_id);
					FETCH c_fm_rout_hdr INTO c_fm_rout;
					CLOSE c_fm_rout_hdr;
					PRINT_LINE ( '|'||LPAD(L_GMF_ROUTING,16,' ')||': '||
					RPAD(c_fm_rout.routing_no,32,' ')||' '||LPAD(L_GMF_VERSION,16,' ')||': '||RPAD(c_fm_rout.routing_vers,5,' ')||' '||
					LPAD(L_GMF_ACTUAL_CMPLT_DATE,22,' ')||': '||RPAD(to_char(c_pm_btch.actual_cmplt_date),18,' '));
				ELSE
					PRINT_LINE ( '|'||LPAD(L_GMF_ROUTING,16,' ')||': '||
					RPAD(' ',32,' ')||' '||LPAD(L_GMF_VERSION,16,' ')||': '||RPAD(' ',5,' ')||' '||LPAD(L_GMF_ACTUAL_CMPLT_DATE,22,' ')||': '||
					RPAD(to_char(c_pm_btch.actual_cmplt_date),18,' '));
				END IF;
				PRINT_LINE ( '|'||LPAD(L_GMF_BATCH_STATUS,16,' ')||': '||RPAD(c_pm_btch.meaning,32,' ')||' '||LPAD(L_GMF_WIP_WHSE,16,' ')||': '||RPAD(c_pm_btch.wip_whse_code,4,' '));
			END IF;

			/* VC Bug 1924250 - End of Detail info on documents */

			IF ppage_size = 132 THEN PRINT_LINE ( RPAD('|',132,'-'));  -- Bug 2804810
			ELSIF ppage_size = 180 THEN PRINT_LINE ( RPAD('|',180,'-'));
			END IF;
		END IF;
		/* If break occured for sub-event, reset its totals */
		IF (last_sevt_code IS NULL OR last_sevt_code <> r.sub_event_code ) THEN
			last_sevt_code := r.sub_event_code;
			sevt_total_dr := 0;
			sevt_total_cr := 0;
			/* Also reset totals for breaks with break level lower then sub-event */
			IF (rep_mode = 'SVD' OR rep_mode = 'SDV' OR rep_mode = 'DSV') THEN
				voucher_total_dr := 0;
				voucher_total_cr := 0;
			END IF;
			IF (rep_mode = 'SVD' OR rep_mode = 'SDV' OR rep_mode = 'VSD') THEN
				doc_total_dr := 0;
				doc_total_cr := 0;
			END IF;
		END IF;

		/* If break occured for Voucher, reset its totals */
		IF (last_voucher_id IS NULL OR last_voucher_id <> nvl(r.voucher_id, 0)) THEN
			last_voucher_id := nvl(r.voucher_id,0);
			voucher_total_dr := 0;
			voucher_total_cr := 0;
			/* Also reset totals for breaks with break level lower then voucher */
			IF (rep_mode = 'VSD' OR rep_mode = 'VDS' OR rep_mode = 'DVS') THEN
				sevt_total_dr := 0;
				sevt_total_cr := 0;
			END IF;
			IF (rep_mode = 'VSD' OR rep_mode = 'VDS' OR rep_mode = 'SVD') THEN
				doc_total_dr := 0;
				doc_total_cr := 0;
			END IF;
		END IF;

		/* If break occured for Document, reset its totals */
		IF (last_orgn_code||last_doc_no IS NULL OR last_orgn_code||last_doc_no <> r.orgn_code||r.doc_no) THEN
			last_doc_no := r.doc_no;
			last_orgn_code := r.orgn_code;
			doc_total_dr := 0;
			doc_total_cr := 0;
			/* Also reset totals for breaks with break level lower then document */
			IF (rep_mode = 'DSV' OR rep_mode = 'DVS' OR rep_mode = 'SDV') THEN
				voucher_total_dr := 0;
				voucher_total_cr := 0;
			END IF;
			IF (rep_mode = 'DSV' OR rep_mode = 'DVS' OR rep_mode = 'VDS') THEN
				sevt_total_dr := 0;
				sevt_total_cr := 0;
			END IF;
		END IF;

		/* If this is a new line, display line level document information */
		/* BUG 2302794
		IF (last_line_id IS NULL OR (last_line_id <> r.line_id)) THEN
		*/
		IF (last_line_id IS NULL OR (last_line_id <> r.line_id) OR (doc_no_sav <> r.doc_no)) THEN
			last_line_id := r.line_id;
			line_total_dr := 0;
			line_total_cr := 0;
			IF ppage_size = 132 THEN  -- Bug 2804810
			   format_trans := fnd_currency.get_format_mask(r.currency_trans,20); -- B2048108
			ELSIF ppage_size = 180 THEN
			   format_trans := fnd_currency.get_format_mask(r.currency_trans,30); --  Bug 2804810
			END IF;

			IF (r.line_no IS NOT NULL) THEN
				/* Begin Bug#2088655 P.Raghu */
				/* Added 'PORC' Doc Type */
				IF (r.doc_type = 'RECV' OR r.doc_type = 'RTRN' OR r.doc_type = 'PORC') THEN
				   IF (r.doc_type = 'PORC') THEN
				     --BEGIN BUG#3359584
                 OPEN c_pur_ship_dtl(r.doc_id, r.line_id);
                 FETCH c_pur_ship_dtl INTO c_pur_ship;
                 CLOSE c_pur_ship_dtl;
				     --END BUG#3359584
					  c_recv_hst.net_price := c_pur_ship.po_unit_price;
					  c_recv_hst.price_um  := c_pur_ship.price_um;
				   ELSE
				-- Bug 2048108 Print Unit Price for po receipts and returns
					   OPEN c_po_recv_hst(r.sub_event_code, r.doc_id, r.line_id);
					   FETCH c_po_recv_hst INTO c_recv_hst;
					   IF ( c_po_recv_hst%NOTFOUND ) THEN
						   c_recv_hst.net_price := NULL;
						   c_recv_hst.price_um := NULL;
					   END IF;
					   CLOSE c_po_recv_hst;
				   END IF;
				   /* End Bug#2088655 */
					PRINT_LINE ('|'||LPAD(L_GMF_LINE, 8, ' ')||' '||RPAD(L_GMF_ITEM,32,' ')||' '||
						RPAD(L_GMF_TRANS_DATE,13,' ')||' '||RPAD(L_GMF_WHSE, 6, ' ')||' '||
						LPAD(L_GMF_QUANTITY,14,' ')||' '||RPAD(L_GMF_UOM, 6, ' ')||' '||LPAD(L_GMF_UNIT_PRICE,14,' ')||' '||RPAD(L_GMF_UOM, 6, ' '));
					PRINT_LINE ('|'||LPAD('------', 8, ' ')||' '||RPAD('----',32,' ')||' '||
						RPAD('----------',13,' ')||' '||RPAD('----', 6, ' ')||' '||LPAD('----------',14,' ')||
						' '||RPAD('--', 6, ' ')||' '||LPAD('----------',14,' ')||' '||RPAD('--', 6,' '));
					/* Bug 2262087. Modified to_char(r.line_no) to r.line_no */
					PRINT_LINE ( '|'||LPAD(r.line_no,8,' ')||' '||RPAD(r.resource_item_no, 32, ' ')||
						' '|| RPAD(nvl(to_char(r.trans_date),' '), 13, ' ')||' '||RPAD(r.whse_code, 6, ' ')||' '||
						LPAD(to_char(r.trans_qty_usage,'9999999999D999'),14,' ')||' '||RPAD(r.trans_qty_usage_um, 6, ' ')||
						' '|| LPAD(nvl(to_char(c_recv_hst.net_price,format_trans),' '),14,' ')||' '||
						RPAD(nvl(c_recv_hst.price_um,' '), 6, ' '));
					PRINT_LINE ( '|'||'        '||' '||r.resource_item_no_desc);
				ELSIF (r.trans_source_code = 'IC') THEN
				-- Bug 2048108 Print reason code
				   --Begin Bug#3072197
				   IF r.doc_type = 'XFER' THEN
                 OPEN c_ic_xfer_tran(r.line_id);
					  FETCH c_ic_xfer_tran INTO c_ic_tran;
					  IF ( c_ic_xfer_tran%NOTFOUND ) THEN
						  c_ic_tran.reason_code := NULL;
					  END IF;
					  CLOSE c_ic_xfer_tran;
				   ELSE
				   --End Bug#3072197
					  OPEN c_ic_tran_pnd(r.doc_type, r.doc_id, r.line_id);
					  FETCH c_ic_tran_pnd INTO c_ic_tran;
					  IF ( c_ic_tran_pnd%NOTFOUND ) THEN
						  c_ic_tran.reason_code := NULL;
					  END IF;
					  CLOSE c_ic_tran_pnd;
					--Begin Bug#3072197
				   END IF;
				   --End Bug#3072197
					/* Begin Bug#2365391 - Nayini Vikranth */
					/* Get item_no, item_desc1, whse_code, trans_qty, trans_um for piph and picy trans */
					IF (r.doc_type in ('PIPH','PICY')) THEN
						OPEN c_ic_piph_picy_info(r.doc_type, r.doc_id, r.line_id);
						FETCH c_ic_piph_picy_info INTO c_ic_piph_picy;
						IF ( c_ic_piph_picy_info%NOTFOUND ) THEN
							NULL;
						ELSE
							r.resource_item_no := c_ic_piph_picy.item_no;
							r.resource_item_no_desc := c_ic_piph_picy.item_desc1;
							r.whse_code := c_ic_piph_picy.whse_code;
							r.trans_qty_usage := c_ic_piph_picy.trans_qty;
							r.trans_qty_usage_um := c_ic_piph_picy.trans_um;
						END IF;
						CLOSE c_ic_piph_picy_info;
					END IF;
					/* End Bug#2365391 */
					PRINT_LINE ('|'||LPAD(L_GMF_LINE, 8, ' ')||' '||RPAD(L_GMF_ITEM,32,' ')||' '||
						RPAD(L_GMF_TRANS_DATE,13,' ')||' '||RPAD(L_GMF_WHSE, 6, ' ')||' '||
						LPAD(L_GMF_QUANTITY,14,' ')||' '||RPAD(L_GMF_UOM, 6, ' ')||' '||RPAD(L_GMF_REAS_CODE,6,' '));
					PRINT_LINE ('|'||LPAD('------', 8, ' ')||' '||RPAD('----',32,' ')||' '||
						RPAD('----------',13,' ')||' '||RPAD('----', 6, ' ')||' '||LPAD('----------',14,' ')||
						' '||RPAD('--',6, ' ')||' '||LPAD('----',6,' '));
					PRINT_LINE ( '|'||LPAD(r.line_no,8,' ')||' '||RPAD(r.resource_item_no, 32, ' ')||
						' '|| RPAD(nvl(to_char(r.trans_date),' '), 13, ' ')||' '||RPAD(r.whse_code, 6, ' ')||' '||
						LPAD(to_char(r.trans_qty_usage,'9999999999D999'),14,' ')||' '||RPAD(r.trans_qty_usage_um, 6, ' ')||
						' '|| LPAD(nvl(c_ic_tran.reason_code,' '),6,' '));
					PRINT_LINE ( '|'||'        '||' '||r.resource_item_no_desc);



				ELSIF (r.doc_type = 'PROD' AND (r.sub_event_code = 'RELE' OR r.sub_event_code = 'CERT')) THEN
				-- Bug 2048108 Print Plan Qty and Actual Qty for RELE and CERT sub-events
					-- B2275872 Moved IF stmt below to previous ELSIF
					-- IF (r.sub_event_code = 'RELE' OR r.sub_event_code = 'CERT') THEN
						OPEN c_pm_matl_dtl(r.line_id);
						FETCH c_pm_matl_dtl INTO c_pm_matl;
						IF ( c_pm_matl_dtl%NOTFOUND ) THEN
							c_pm_matl.wip_plan_qty := NULL;
							c_pm_matl.whse_code := NULL;
                                                        c_pm_matl.original_qty := NULL; --Bug# 3772552 - Fwd port for 3544905
						END IF;
						CLOSE c_pm_matl_dtl;
						PRINT_LINE ('|'||LPAD(L_GMF_LINE, 8, ' ')||' '||RPAD(L_GMF_ITEM,32,' ')||' '||
							RPAD(L_GMF_TRANS_DATE,13,' ')||' '||RPAD(L_GMF_WHSE, 6, ' ')||' '||
							LPAD(L_GMF_PLAN_QTY,14,' ')||' '||RPAD(L_GMF_UOM, 6, ' ')||' '||LPAD(L_GMF_ACTL_QTY,14,' ')||' '||RPAD(L_GMF_UOM, 6,' ')||' '||LPAD(L_GMF_ORIG_QTY,14,' ')||' '||RPAD(L_GMF_UOM, 6,' '));          -- Bug 3772552
						PRINT_LINE ('|'||LPAD('------', 8, ' ')||' '||RPAD('----',32,' ')||' '||
							RPAD('----------',13,' ')||' '||RPAD('----', 6, ' ')||' '||LPAD('----------',14,' ')||
							' '||RPAD('--', 6,' ')||' '||LPAD('----------',14,' ')||' '||RPAD('--', 6, ' ')||' '||LPAD('----------',14,' ')||' '||RPAD('--', 6, ' '));   -- Bug 3772552 - extra underscores for original quantity
						PRINT_LINE ( '|'||LPAD(r.line_no,8,' ')||' '||RPAD(r.resource_item_no, 32, ' ')||
							' '|| RPAD(nvl(to_char(r.trans_date),' '), 13, ' ')||' '||RPAD(nvl(c_pm_matl.whse_code,' '), 6, ' ')||' '||
							LPAD(nvl(to_char(c_pm_matl.wip_plan_qty,'9999999999D999'),' '),14,' ')||' '||RPAD(r.trans_qty_usage_um, 6,' ')||
							' '|| LPAD(to_char(r.trans_qty_usage,'9999999999D999'),14,' ')||' '||RPAD(r.trans_qty_usage_um, 6, ' ')||
							' '|| LPAD(nvl(to_char(c_pm_matl.original_qty,'9999999999D999'),' '),14,' ')||' '||RPAD(r.trans_qty_usage_um, 6,' '));   -- Bug 3772552

						/* Bug 3133895 ... print item description */
						PRINT_LINE ( '|'||'        '||' '||r.resource_item_no_desc);
					-- END IF;
		/* Begin Bug 2230751 */
				ELSIF(r.doc_type = 'RVAL') THEN
					  PRINT_LINE ( '|');
					  PRINT_LINE ('|'||LPAD(L_GMF_LINE, 8, ' ')||' '||RPAD(L_GMF_ITEM,32,' ')||' '||
						RPAD(L_GMF_TRANS_DATE,13,' ')||' '||RPAD(L_GMF_WHSE, 6, ' ')||' '||
						LPAD(L_GMF_QUANTITY,14,' ')||' '||RPAD(L_GMF_UOM, 6, ' '));
					  PRINT_LINE ('|'||LPAD('------', 8, ' ')||' '||RPAD('----',32,' ')||' '||
						RPAD('----------',13,' ')||' '||RPAD('----', 6, ' ')||' '||LPAD('----------',14,' ')||
						' '||RPAD('--',6, ' '));
					  PRINT_LINE ( '|'||LPAD(r.line_no,8,' ')||' '||RPAD(r.resource_item_no, 32, ' ')||
						' '|| RPAD(nvl(to_char(r.trans_date),' '), 13, ' ')||' '||RPAD(r.whse_code, 6, ' ')||' '||
						LPAD(to_char(l_quantity,'9999999999D999'),14,' ')||' '||RPAD(r.trans_qty_usage_um, 6, ' '));
					PRINT_LINE ( '|'||'        '||' '||r.resource_item_no_desc);
		/* End bug 2230751 */

				ELSE
					PRINT_LINE ('|'||LPAD(L_GMF_LINE, 8, ' ')||' '||RPAD(L_GMF_ITEM,32,' ')||' '||
						RPAD(L_GMF_TRANS_DATE,13,' ')||' '||RPAD(L_GMF_WHSE, 6, ' ')||' '||
						LPAD(L_GMF_QUANTITY,14,' ')||' '||L_GMF_UOM);
					PRINT_LINE ('|'||LPAD('------', 8, ' ')||' '||RPAD('----',32,' ')||' '||
						RPAD('----------',13,' ')||' '||RPAD('----', 6, ' ')||' '||LPAD('----------',14,' ')||
						' '||'--');
					PRINT_LINE ( '|'||LPAD(r.line_no,8,' ')||' '||RPAD(r.resource_item_no, 32, ' ')||
						' '|| RPAD(nvl(to_char(r.trans_date),' '), 13, ' ')||' '||RPAD(r.whse_code, 6, ' ')||' '||
						LPAD(to_char(r.trans_qty_usage,'9999999999D999'),14,' ')||' '||r.trans_qty_usage_um);
					PRINT_LINE ( '|'||'        '||' '||r.resource_item_no_desc);






				END IF;
			END IF;
			/* Also print the heading for the accounting information */
			PRINT_LINE ( '|');
			IF ppage_size = 132 THEN  -- Bug 2804810

			   PRINT_LINE ( RPAD('|',46,' ')||RPAD('----'||L_GMF_BASE_CURR,29,'-')||' '||
					RPAD('----'||L_GMF_BILL_CURR,29,'-'));
			   PRINT_LINE ( '|'||LPAD(L_GMF_TTL,7,' ')||' '||RPAD(L_GMF_AU_AND_ACCT,36,' ')||' '||
					LPAD(L_GMF_DEBIT,14,' ')||' '||LPAD(L_GMF_CREDIT,14,' ')||' '||
					LPAD(L_GMF_DEBIT,14,' ')||' '||LPAD(L_GMF_CREDIT,14,' ')||' '||
					RPAD(L_GMF_CURRENCY,4, ' ')||' '||LPAD(L_GMF_JV_QTY,14,' ')||' '||L_GMF_UOM);
			   PRINT_LINE ( '|'||LPAD('---',7,' ')||' '||RPAD('-------------------------',36,' ')||' '||
					'-------------- -------------- -------------- -------------- '||
					'---- -------------- ----');

			ELSIF ppage_size = 180 THEN  -- Bug 2804810

			   PRINT_LINE ( RPAD('|',46,' ')||RPAD('----'||L_GMF_BASE_CURR,53,'-')||' '||
					RPAD('----'||L_GMF_BILL_CURR,53,'-'));
			   PRINT_LINE ( '|'||LPAD(L_GMF_TTL,7,' ')||' '||RPAD(L_GMF_AU_AND_ACCT,36,' ')||' '||
					LPAD(L_GMF_DEBIT,26,' ')||' '||LPAD(L_GMF_CREDIT,26,' ')||' '||
					LPAD(L_GMF_DEBIT,26,' ')||' '||LPAD(L_GMF_CREDIT,26,' ')||' '||
					RPAD(L_GMF_CURRENCY,4, ' ')||' '||LPAD(L_GMF_JV_QTY,14,' ')||' '||L_GMF_UOM);
			   PRINT_LINE ( '|'||LPAD('---',7,' ')||' '||RPAD('-------------------------',36,' ')||' '||
					'-------------------------- -------------------------- ' ||
					'-------------------------- -------------------------- ' ||
					'---- -------------- ----');

			END IF;
		END IF;

		/* Display the subledger information for the document line and maintian totals */
		IF r.debit_credit_sign = 1 THEN
			dr_base := r.amount_base;
			cr_base := NULL;
			line_total_dr := line_total_dr + dr_base;
			doc_total_dr := doc_total_dr + dr_base;
			voucher_total_dr := voucher_total_dr + dr_base;
			sevt_total_dr := sevt_total_dr + dr_base;
			rep_total_dr := rep_total_dr + dr_base;
			dr_trans := r.amount_trans;
			cr_trans := NULL;

			IF ppage_size = 132 THEN  -- Bug 2804810
			  format_base := fnd_currency.get_format_mask(r.currency_base,20); -- B1316233
			  format_trans := fnd_currency.get_format_mask(r.currency_trans,20); -- B1316233
			ELSIF ppage_size = 180 THEN  -- Bug 2804810
			  format_base := fnd_currency.get_format_mask(r.currency_base,30); -- B1316233
			  format_trans := fnd_currency.get_format_mask(r.currency_trans,30); -- B1316233
			END IF;

		ELSE
			dr_base := NULL;
			cr_base := r.amount_base;
			line_total_cr := line_total_cr + cr_base;
			doc_total_cr := doc_total_cr + cr_base;
			voucher_total_cr := voucher_total_cr + cr_base;
			sevt_total_cr := sevt_total_cr + cr_base;
			rep_total_cr := rep_total_cr + cr_base;
			dr_trans := NULL;
			cr_trans := r.amount_trans;

			IF ppage_size = 132 THEN  -- Bug 2804810
			  format_base := fnd_currency.get_format_mask(r.currency_base,20); -- B1316233
			  format_trans := fnd_currency.get_format_mask(r.currency_trans,20); -- B1316233
			ELSIF ppage_size = 180 THEN
			  format_base := fnd_currency.get_format_mask(r.currency_base,30); -- B1316233
			  format_trans := fnd_currency.get_format_mask(r.currency_trans,30); -- B1316233
			END IF;

		END IF;

		/* Begin bug# 1316233 */
		IF (nvl(dr_base,0) < amount_constant AND
			nvl(cr_base,0) < amount_constant AND
			nvl(dr_trans,0) < amount_constant AND
			nvl(cr_trans,0) <amount_constant) THEN

		   IF ppage_size = 132 THEN  -- Bug 2804810
			PRINT_LINE ( '|    '||r.acct_ttl_code||' '||RPAD(r.acctg_unit_no||' '||r.acct_no,36,' ')||
			  ' '|| LPAD(nvl(to_char(dr_base,format_base),' '),14,' ')||' '||
			  LPAD(nvl(to_char(cr_base,format_base),' '),14,' ')||' '||
			  LPAD(nvl(to_char(dr_trans,format_trans),' '),14,' ')||' '||
			  LPAD(nvl(to_char(cr_trans,format_trans),' '),14,' ')||' '||RPAD(r.currency_trans,4,' ')||
			  ' '|| LPAD(nvl(to_char(r.jv_quantity,'9999999999D999'),' '),14,' ')||' '||r.jv_quantity_um);
		   ELSIF ppage_size = 180 THEN
			PRINT_LINE ( '|    '||r.acct_ttl_code||' '||RPAD(r.acctg_unit_no||' '||r.acct_no,36,' ')||
			  ' '|| LPAD(nvl(to_char(dr_base,format_base),' '),26,' ')||' '||
			  LPAD(nvl(to_char(cr_base,format_base),' '),26,' ')||' '||
			  LPAD(nvl(to_char(dr_trans,format_trans),' '),26,' ')||' '||
			  LPAD(nvl(to_char(cr_trans,format_trans),' '),26,' ')||' '||RPAD(r.currency_trans,4,' ')||
			  ' '|| LPAD(nvl(to_char(r.jv_quantity,'9999999999D999'),' '),14,' ')||' '||r.jv_quantity_um);
		   END IF;

		ELSE
		   IF ppage_size = 132 THEN  -- Bug 2804810
			PRINT_LINE ( '|    '||r.acct_ttl_code||' '||RPAD(r.acctg_unit_no||' '||r.acct_no,36,' ')||
			  ' '|| LPAD(nvl(to_char(dr_base,local_format_base),' '),14,' ')||' '||
			  LPAD(nvl(to_char(cr_base,local_format_base),' '),14,' ')||' '||
			  LPAD(nvl(to_char(dr_trans,local_format_trans),' '),14,' ')||' '||
			  LPAD(nvl(to_char(cr_trans,local_format_trans),' '),14,' ')||' '||RPAD(r.currency_trans,4,' ')||
			  ' '|| LPAD(nvl(to_char(r.jv_quantity,'9999999999D999'),' '),14,' ')||' '||r.jv_quantity_um);
		   ELSIF ppage_size = 180 THEN
			PRINT_LINE ( '|    '||r.acct_ttl_code||' '||RPAD(r.acctg_unit_no||' '||r.acct_no,36,' ')||
			  ' '|| LPAD(nvl(to_char(dr_base,format_base),' '),26,' ')||' '||
			  LPAD(nvl(to_char(cr_base,format_base),' '),26,' ')||' '||
			  LPAD(nvl(to_char(dr_trans,format_trans),' '),26,' ')||' '||
			  LPAD(nvl(to_char(cr_trans,format_trans),' '),26,' ')||' '||RPAD(r.currency_trans,4,' ')||
			  ' '|| LPAD(nvl(to_char(r.jv_quantity,'9999999999D999'),' '),14,' ')||' '||r.jv_quantity_um);
		   END IF;

		END IF;

		/*
		PRINT_LINE ( '|    '||r.acct_ttl_code||' '||RPAD(r.acctg_unit_no||' '||r.acct_no,36,' ')||
			' '|| LPAD(nvl(to_char(dr_base,format_base),' '),14,' ')||' '||
			LPAD(nvl(to_char(cr_base,format_base),' '),14,' ')||' '||
			LPAD(nvl(to_char(dr_trans,format_trans),' '),14,' ')||' '||
			LPAD(nvl(to_char(cr_trans,format_trans),' '),14,' ')||' '||RPAD(r.currency_trans,4,' ')||
			' '|| LPAD(nvl(to_char(r.jv_quantity,'9999999999D999'),' '),14,' ')||' '||r.jv_quantity_um);
		*/
		/* End of bug# 1316233 */
		/* B# 2302747
		j := 36;
		*/
		j := 37;
		/* Begin Bug#2424449 Piyush K. Mishra
		Incorporated B#2413793
		WHILE length(r.acctg_unit_no||' '||r.acct_no) > j AND j <= 240 LOOP
		*/
		WHILE length(r.acctg_unit_no||' '||r.acct_no) >= j AND j <= 240 LOOP
		--End Bug#2424449

			PRINT_LINE ( '|        '||substrb(r.acctg_unit_no||' '||r.acct_no, j, 36));
			j := j+36;
		END LOOP;
		j := 1;
		WHILE lengthb(r.acctg_unit_desc||' '||r.acct_desc) > j AND j <= 240 LOOP
			PRINT_LINE ( '|        '||substrb(r.acctg_unit_desc||' '||r.acct_desc, j, 36));
			j := j+36;
		END LOOP;
	END LOOP;

	/* Close the te right cursor base upon user specified parameter */
	IF report_on = 1 THEN
		CLOSE c_gl_subr_led_vw;
	ELSE
		CLOSE c_gl_subr_tst_vw;
	END IF;

	/* Print the totals for the very last line */
	PRINT_TOTALS (-888,'-888','-888',-888 , rep_mode, ppage_size);  -- Bug 2804810
   IF ppage_size = 132 THEN PRINT_LINE ( RPAD('|',132,'-'));  -- Bug 2804810
   ELSIF ppage_size = 180 THEN PRINT_LINE ( RPAD('|',180,'-'));
   END IF;
END;

/* procedure to print totals */
PROCEDURE PRINT_TOTALS(
	line_id         IN      VARCHAR2,
	doc_no          IN      VARCHAR2,
	sub_event_code  IN      VARCHAR2,
	voucher_id      IN      NUMBER,
	rep_mode        IN      VARCHAR2,
	ppage_size      IN      NUMBER DEFAULT 132) IS  -- Bug 2804810
BEGIN
	/* If the line has changed, print line level totals */
	IF (last_line_id IS NOT NULL AND (last_line_id <> line_id)) THEN
	   IF ppage_size = 132 THEN  -- Bug 2804810
		PRINT_LINE ( RPAD('|',45,' ')||' '||'============== ==============');
		PRINT_LINE ( RPAD('|',45,' ')||' '||LPAD(nvl(to_char(line_total_dr,format_base),' '),14,' ')||
			' '|| LPAD(nvl(to_char(line_total_cr,format_base),' '),14,' '));
	   ELSIF ppage_size = 180 THEN  -- Bug 2804810
		PRINT_LINE ( RPAD('|',45,' ')||' '||'========================== ==========================');
		PRINT_LINE ( RPAD('|',45,' ')||' '||LPAD(nvl(to_char(line_total_dr,format_base),' '),26,' ')||
			' '|| LPAD(nvl(to_char(line_total_cr,format_base),' '),26,' '));
	   END IF;
	END IF;

	/* Display other totals in the order report is being run */
	FOR i in 1..3 LOOP
		IF ( substr(rep_mode,i,1) = 'D' AND (last_orgn_code||last_doc_no IS NOT NULL AND (last_orgn_code||last_doc_no <> doc_no))) THEN
		   IF ppage_size = 132 THEN  -- Bug 2804810
			PRINT_LINE ( RPAD('|',45,' ')||' '||'============== ==============');
		   ELSIF ppage_size = 180 THEN
			PRINT_LINE ( RPAD('|',45,' ')||' '||'========================== ==========================');
		   END IF;

			/* Begin bug# 1316233 */
			IF (nvl(doc_total_dr,0) < amount_constant AND
				nvl(doc_total_cr,0) < amount_constant) THEN

			   IF ppage_size = 132 THEN  -- Bug 2804810
				PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_DOCUMENT||':',20,' ')||' '||
				LPAD(nvl(to_char(doc_total_dr,format_base),' '),14,' ')||' '||
				LPAD(nvl(to_char(doc_total_cr,format_base),' '),14,' '));
			   ELSIF ppage_size = 180 THEN
				PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_DOCUMENT||':',20,' ')||' '||
				LPAD(nvl(to_char(doc_total_dr,format_base),' '),26,' ')||' '||
				LPAD(nvl(to_char(doc_total_cr,format_base),' '),26,' '));
			   END IF;

			ELSE
			   IF ppage_size = 132 THEN  -- Bug 2804810
				PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_DOCUMENT||':',20,' ')||' '||
				LPAD(nvl(to_char(doc_total_dr,local_format_base),' '),14,' ')||' '||
				LPAD(nvl(to_char(doc_total_cr,local_format_base),' '),14,' '));
			   ELSIF ppage_size = 180 THEN
				PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_DOCUMENT||':',20,' ')||' '||
				LPAD(nvl(to_char(doc_total_dr,format_base),' '),26,' ')||' '||
				LPAD(nvl(to_char(doc_total_cr,format_base),' '),26,' '));
			   END IF;
			END IF;

			/*
			PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_DOCUMENT||':',20,' ')||' '||
				LPAD(nvl(to_char(doc_total_dr,format_base),' '),14,' ')||' '||
				LPAD(nvl(to_char(doc_total_cr,format_base),' '),14,' '));
			*/
			/* End of bug# 1316233 */

			/* If there are lower level breaks, force them to break also
			 Their totals will be displayed in subsequent iterations of the FOR loop */
			IF (i=1 OR (i=2 AND substr(rep_mode,i+1,1)='V')) THEN
				last_voucher_id := '-999';
			END IF;
			IF (i=1 OR (i=2 AND substr(rep_mode,i+1,1)='S')) THEN
				last_sevt_code := '-999';
			END IF;
		END IF;
		IF ( substr(rep_mode,i,1) = 'S' AND (last_sevt_code IS NOT NULL AND (last_sevt_code <> sub_event_code))) THEN
			IF ppage_size = 132 THEN  -- Bug 2804810
				PRINT_LINE ( RPAD('|',45,' ')||' '||'============== ==============');
			ELSIF ppage_size = 180 THEN
				PRINT_LINE ( RPAD('|',45,' ')||' '||'========================== ==========================');
			END IF;

			/* Begin bug# 1316233 */
			IF (nvl(sevt_total_dr,0) < amount_constant AND
				nvl(sevt_total_cr,0) < amount_constant) THEN
			   IF ppage_size = 132 THEN  -- Bug 2804810
				PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_SUB_EVENT||':',20,' ')||' '||
					LPAD(nvl(to_char(sevt_total_dr,format_base),' '),14,' ')||' '||
					LPAD(nvl(to_char(sevt_total_cr,format_base),' '),14,' '));
			   ELSIF ppage_size = 180 THEN
				PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_SUB_EVENT||':',20,' ')||' '||
					LPAD(nvl(to_char(sevt_total_dr,format_base),' '),26,' ')||' '||
					LPAD(nvl(to_char(sevt_total_cr,format_base),' '),26,' '));
			   END IF;
			ELSE
			   IF ppage_size = 132 THEN  -- Bug 2804810
				PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_SUB_EVENT||':',20,' ')||' '||
					LPAD(nvl(to_char(sevt_total_dr,local_format_base),' '),14,' ')||' '||
					LPAD(nvl(to_char(sevt_total_cr,local_format_base),' '),14,' '));
			   ELSIF ppage_size = 180 THEN
				PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_SUB_EVENT||':',20,' ')||' '||
					LPAD(nvl(to_char(sevt_total_dr,format_base),' '),26,' ')||' '||
					LPAD(nvl(to_char(sevt_total_cr,format_base),' '),26,' '));
			   END IF;
			END IF;
			/*
			PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_SUB_EVENT||':',20,' ')||' '||
				LPAD(nvl(to_char(sevt_total_dr,format_base),' '),14,' ')||' '||
				LPAD(nvl(to_char(sevt_total_cr,format_base),' '),14,' '));
			*/
			/* End of bug# 1316233 */

			/* If there are lower level breaks, force them to break also
			 Their totals will be displayed in subsequent iterations of the FOR loop */
			IF (i=1 OR (i=2 AND substr(rep_mode,i+1,1)='V')) THEN
				last_voucher_id := '-999';
			END IF;
			IF (i=1 OR (i=2 AND substr(rep_mode,i+1,1)='D')) THEN
				last_doc_no := '-999';
			END IF;
		END IF;
		IF (substr(rep_mode,i,1) = 'V' AND (last_voucher_id IS NOT NULL AND (last_voucher_id <> nvl(voucher_id,0)))) THEN
			IF ppage_size = 132 THEN  -- Bug 2804810
			     PRINT_LINE ( RPAD('|',45,' ')||' '||'============== ==============');
			ELSIF ppage_size = 180 THEN
			     PRINT_LINE ( RPAD('|',45,' ')||' '||'========================== ==========================');
			END IF;

			/* Begin bug# 1316233 */
			IF (nvl(voucher_total_dr,0) < amount_constant AND
				nvl(voucher_total_cr,0) < amount_constant) THEN
			   IF ppage_size = 132 THEN  -- Bug 2804810
				PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_VOUCHER||':',20,' ')||' '||
					LPAD(nvl(to_char(voucher_total_dr,format_base),' '),14,' ')||' '||
					LPAD(nvl(to_char(voucher_total_cr,format_base),' '),14,' '));
			   ELSIF ppage_size = 180 THEN
				PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_VOUCHER||':',20,' ')||' '||
					LPAD(nvl(to_char(voucher_total_dr,format_base),' '),26,' ')||' '||
					LPAD(nvl(to_char(voucher_total_cr,format_base),' '),26,' '));
			   END IF;
			ELSE
			   IF ppage_size = 132 THEN  -- Bug 2804810
				PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_VOUCHER||':',20,' ')||' '||
					LPAD(nvl(to_char(voucher_total_dr,local_format_base),' '),14,' ')||' '||
					LPAD(nvl(to_char(voucher_total_cr,local_format_base),' '),14,' '));
			   ELSIF ppage_size = 180 THEN
				PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_VOUCHER||':',20,' ')||' '||
					LPAD(nvl(to_char(voucher_total_dr,format_base),' '),26,' ')||' '||
					LPAD(nvl(to_char(voucher_total_cr,format_base),' '),26,' '));
			   END IF;
			END IF;
			/*
			PRINT_LINE ( RPAD('|',25,' ')||LPAD(L_GMF_VOUCHER||':',20,' ')||' '||
				LPAD(nvl(to_char(voucher_total_dr,format_base),' '),14,' ')||' '||
				LPAD(nvl(to_char(voucher_total_cr,format_base),' '),14,' '));
			*/
			/* End of bug# 1316233 */
			-- If there are lower level breaks, force them to break also
			-- Their totals will be displayed in subsequent iterations of the FOR loop
			IF (i=1 OR (i=2 AND substr(rep_mode,i+1,1)='S')) THEN
				last_sevt_code := '-999';
			END IF;
			IF (i=1 OR (i=2 AND substr(rep_mode,i+1,1)='D')) THEN
				last_doc_no := '-999';
			END IF;
		END IF;
	END LOOP;
END;

/* Wrapper for printing report line */
PROCEDURE PRINT_LINE
	(line_text      IN      VARCHAR2) IS
BEGIN
	FND_FILE.PUT_LINE ( FND_FILE.OUTPUT,line_text);
	/* DBMS_OUTPUT.PUT_LINE ( line_text);  */
	line_no := line_no + 1;
	IF (line_no = lines_per_page) THEN
		page_no := page_no + 1;
		FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, substr(rep_title||' '||LPAD(L_GMF_PAGE_NO, 15,' ')||':'||RPAD(to_char(page_no), 6,' '),1,132)); /* Bug 2048108 */
		FND_FILE.PUT_LINE ( FND_FILE.OUTPUT, '|');
		line_no := 2;
	END IF;
END;

/*  Procedure initialize labels and variables. */
PROCEDURE INITIALIZE_LABELS IS
BEGIN
	FND_MESSAGE.SET_NAME ('GMF','GMF_SUBLEDGER_REPORT'); L_GMF_SUBLEDGER_REPORT := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_SOURCE'); L_GMF_SOURCE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_SUB_EVENT'); L_GMF_SUB_EVENT := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_VOUCHER'); L_GMF_VOUCHER := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_DOCUMENT'); L_GMF_DOCUMENT := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_DOC_NO'); L_GMF_DOC_NO := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_DOC_TYPE'); L_GMF_DOC_TYPE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_DOC_DATE'); L_GMF_DOC_DATE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_LINE'); L_GMF_LINE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_ITEM'); L_GMF_ITEM := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_TRANS_DATE'); L_GMF_TRANS_DATE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_WHSE'); L_GMF_WHSE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_QUANTITY'); L_GMF_QUANTITY := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_UOM'); L_GMF_UOM := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_TTL'); L_GMF_TTL := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_BASE_CURR'); L_GMF_BASE_CURR := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_BILL_CURR'); L_GMF_BILL_CURR := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_DEBIT'); L_GMF_DEBIT := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_CREDIT'); L_GMF_CREDIT := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_JV_QTY'); L_GMF_JV_QTY := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_REFERENCE_NO'); L_GMF_REFERENCE_NO := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_COMPANY'); L_GMF_COMPANY := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_CURRENCY'); L_GMF_CURRENCY := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_FISCAL_YEAR'); L_GMF_FISCAL_YEAR := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_PERIOD'); L_GMF_PERIOD := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_START_DATE'); L_GMF_START_DATE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_END_DATE'); L_GMF_END_DATE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_FROM'); L_GMF_FROM := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_TO'); L_GMF_TO := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_AU_AND_ACCT'); L_GMF_AU_AND_ACCT := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_TEST'); L_GMF_TEST := FND_MESSAGE.GET;
	/* Bug 1924250 */
	FND_MESSAGE.SET_NAME ('GMF','GMF_VENDOR'); L_GMF_VENDOR := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_PO_NO'); L_GMF_PO_NO := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_XCHG_RATE'); L_GMF_XCHG_RATE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_RECEIPT'); L_GMF_RECEIPT := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_RECEIPT_DATE'); L_GMF_RECEIPT_DATE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_FORMULA'); L_GMF_FORMULA := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_VERSION'); L_GMF_VERSION := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_ACTUAL_START_DATE'); L_GMF_ACTUAL_START_DATE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_ACTUAL_CMPLT_DATE'); L_GMF_ACTUAL_CMPLT_DATE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_ROUTING'); L_GMF_ROUTING := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_CUSTOMER'); L_GMF_CUSTOMER := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_SO_NO'); L_GMF_SO_NO := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_SO_DATE'); L_GMF_SO_DATE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_WIP_WHSE'); L_GMF_WIP_WHSE := FND_MESSAGE.GET;
	/* End of code for Bug 1924250 */
	/* Bug 2048108 */
	FND_MESSAGE.SET_NAME ('GMF','GMF_UNIT_PRICE'); L_GMF_UNIT_PRICE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_REAS_CODE'); L_GMF_REAS_CODE := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_PLAN_QTY'); L_GMF_PLAN_QTY := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_ACTL_QTY'); L_GMF_ACTL_QTY := FND_MESSAGE.GET;
        FND_MESSAGE.SET_NAME ('GMF','GMF_ORIG_QTY'); L_GMF_ORIG_QTY := FND_MESSAGE.GET; -- Bug# 3772552
	FND_MESSAGE.SET_NAME ('GMF','GMF_BATCH_STATUS'); L_GMF_BATCH_STATUS := FND_MESSAGE.GET;
	FND_MESSAGE.SET_NAME ('GMF','GMF_PAGE_NO'); L_GMF_PAGE_NO := FND_MESSAGE.GET;
	/* End of code for Bug 2048108 */

	/* Initialize the variables */
	last_voucher_id := NULL;
	last_sevt_code := NULL;
	last_doc_no := NULL;
	last_orgn_code := NULL;
	last_line_id := NULL;
	line_no := 0;
	page_no := 1;

	-- Bug 1316233 Initialize local format for numbers
	local_format_base := 'FM99999999990D00PT';
	local_format_trans := 'FM99999999990D00PT';

	dr_base := NULL;
	cr_base := NULL;
	dr_trans := NULL;
	cr_trans := NULL;
	format_base := NULL;
	format_trans := NULL;
	line_total_dr := NULL;
	line_total_cr := NULL;
	voucher_total_dr := NULL;
	voucher_total_cr := NULL;
	sevt_total_dr := NULL;
	sevt_total_cr := NULL;
	doc_total_dr := NULL;
	doc_total_cr := NULL;
	rep_total_dr := NULL;
	rep_total_cr := NULL;

END;

END;

/
