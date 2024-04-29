--------------------------------------------------------
--  DDL for Package Body POA_WH_SUPPLIER_CONS_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_WH_SUPPLIER_CONS_PK" AS
/* $Header: poaspc1b.pls 115.5 2004/02/26 13:56:50 apalorka ship $ */

  ALL_SUPPLIER			CONSTANT INTEGER := -1;
  NO_PREF_SUPPLIER		CONSTANT INTEGER := -1;
  PRICE_TYPE			CONSTANT INTEGER := 1;
  QUALITY_TYPE			CONSTANT INTEGER := 2;
  DELIVERY_TYPE			CONSTANT INTEGER := 3;
  TOTAL_TYPE			CONSTANT INTEGER := 4;

  NULL_VALUE                    CONSTANT INTEGER := -23453;
  MAGIC_STRING                  CONSTANT VARCHAR2(10) := '734jkhJK24';
  BUFFER_SIZE_LEN		CONSTANT INTEGER := 1000000;


-- ========================================================================
--
--  Calculate the potential savings from consolidating supplier(s) to a
--  preferred supplier.
--  This procedure is called from Supplier Performance workbook.
--
-- ========================================================================

FUNCTION calc_savings(
		 p_item_name		IN  VARCHAR2,
		 p_pref_supplier_name	IN  VARCHAR2,
		 p_cons_supplier_name	IN  VARCHAR2,
		 p_defect_cost		IN  NUMBER,
		 p_del_excp_cost	IN  NUMBER,
		 p_start_date		IN  DATE,
		 p_end_date		IN  DATE,
		 p_return_type		IN  NUMBER)
  RETURN NUMBER
IS

  VERSION                       CONSTANT CHAR(80) :=
        '$Header: poaspc1b.pls 115.5 2004/02/26 13:56:50 apalorka ship $';

  -- Consolidated Supplier(s) info
  v_cons_shipment_id            NUMBER;		-- Shipment id
  v_cons_purch_price		NUMBER;		-- Purchase price
  v_cons_qty_purchased		NUMBER;		-- Qty purchased
  v_cons_qty_received		NUMBER;		-- Qty received
  v_cons_qty_rejected		NUMBER;		-- Qty rejected
  v_cons_qty_del_excp		NUMBER;		-- Qty of delivery exception
  v_cons_date_fk		NUMBER;		-- Date dimension

  -- Preferred Supplier info
  v_pref_purch_price		NUMBER;		-- Avg price
/*
  v_pref_blanket_price		NUMBER;		-- Blanket agreement price
  v_pref_blanket_price2		NUMBER;		-- Blanket agreement price
*/
  v_pref_pct_defect		NUMBER;		-- Avg % of defect
  v_pref_pct_del_excp		NUMBER;		-- Avg % of delivery exception

  -- General
  v_price_savings		NUMBER 		:= 0;
  v_quality_savings		NUMBER 		:= 0;
  v_delivery_savings		NUMBER 		:= 0;
  v_total_savings		NUMBER		:= 0;
  v_ret_value			VARCHAR2(200) 	:= NULL;
  x_progress			VARCHAR2(3) 	:= NULL;

  --
  -- Select the information for the CONSOLIDATED supplier(s).
  -- It can either be from a single supplier (specified in the parameter)
  -- or from all available suppliers within the period window.
  --
  CURSOR c_cons_supplier IS
    SELECT psp.sup_perf_pk_key,
           NVL(psp.price_g, 0),
           NVL(psp.qty_ordered_b - psp.qty_cancelled_b, 0),
	   NVL(psp.qty_received_b, 0),
	   NVL(psp.qty_rejected_b, 0),
           NVL((psp.qty_late_receipt_b + psp.qty_early_receipt_b +
	        psp.qty_past_due_b), 0),
	   psp.date_dim_fk_key
    FROM   edw_time_m		cal,
	   edw_items_m		item,
	   edw_trd_partner_m 	tp,
	   poa_edw_sup_perf_f	psp
    WHERE  psp.item_fk_key 		= item.irev_item_revision_pk_key
    AND    item.item_item_name		= p_item_name
    AND    psp.date_dim_fk_key 		= cal.cday_cal_day_pk_key
    AND    psp.supplier_site_fk_key 	= tp.tplo_tpartner_loc_pk_key
    AND    (tp.tprt_name		= p_cons_supplier_name
    OR      'ALL'                       = UPPER(p_cons_supplier_name))
    AND    cal.cday_cal_day_pk <> 'NA_EDW'
    AND    cal.day_julian_day IS NOT NULL
    AND    cal.day_julian_day <> 0
    AND    to_date(cal.day_julian_day,'J') BETWEEN p_start_date AND p_end_date;

/* ==================================================================

  FS: 	Comment out the code for blankets since blanket price breaks
	are not available in the WH yet.

  --
  -- Get the blanket price for the preferred supplier
  --
  CURSOR c_blanket_break IS
        SELECT psc2.price_override *
               DECODE(gl_currency_api.rate_exists(phc2.currency_code,
                         	p_currency_code,
			 	NVL(phc2.rate_date, phc2.creation_date),
                         	NVL(phc2.rate_type, 'Corporate')),
                      'Y',
        	      gl_currency_api.get_rate(phc2.currency_code,
                         	p_currency_code,
			 	NVL(phc2.rate_date, phc2.creation_date),
                         	NVL(phc2.rate_type, 'Corporate')),
                      1) blanket_price
        FROM   po_headers_all		phc2,
	       po_headers_all		phc1,
	       po_lines_all 		plc2,
	       po_lines_all 		plc1,
	       po_line_locations_all	psc2,
	       po_line_locations_all	psc1
        WHERE  psc1.line_location_id     = v_cons_shipment_id
        AND    plc1.po_line_id           = psc1.po_line_id
        AND    plc1.po_header_id         = psc1.po_header_id
        AND    phc1.po_header_id         = psc1.po_header_id
        AND    plc2.item_id              = plc1.item_id
        AND    NVL(plc2.item_revision, NULL_VALUE) =
				NVL(plc1.item_revision, NULL_VALUE)
        AND    NVL(plc2.unit_meas_lookup_code, MAGIC_STRING) =
				NVL(plc1.unit_meas_lookup_code, MAGIC_STRING)
        AND    phc2.po_header_id         = plc2.po_header_id
        AND    phc2.vendor_id            = p_pref_supplier_id
        AND    v_cons_date BETWEEN NVL(phc2.start_date, v_cons_date)
                               AND NVL(phc2.end_date, v_cons_date)
        AND    NVL(phc2.currency_code, MAGIC_STRING) =
				NVL(phc1.currency_code, MAGIC_STRING)
        AND    psc2.po_line_id           = plc2.po_line_id
        AND    psc2.po_header_id         = plc2.po_header_id
        AND    psc2.shipment_type        = 'PRICE BREAK'
        AND    psc2.po_release_id        IS NULL
        AND    psc2.quantity             <= psc1.quantity
        AND    (psc2.ship_to_location_id = psc1.ship_to_location_id
        OR      psc2.ship_to_location_id IS NULL)
        ORDER BY psc2.quantity desc, blanket_price asc;


  CURSOR c_blanket_nobreak IS
        SELECT plc2.unit_price *
               DECODE(gl_currency_api.rate_exists(phc2.currency_code,
                         	p_currency_code,
			 	NVL(phc2.rate_date, phc2.creation_date),
                         	NVL(phc2.rate_type, 'Corporate')),
                      'Y',
        	      gl_currency_api.get_rate(phc2.currency_code,
                         	p_currency_code,
			 	NVL(phc2.rate_date, phc2.creation_date),
                         	NVL(phc2.rate_type, 'Corporate')),
                      1) blanket_price
        FROM   po_headers_all		phc2,
	       po_headers_all		phc1,
	       po_lines_all 		plc2,
	       po_lines_all 		plc1,
	       po_line_locations_all	psc1
        WHERE  psc1.line_location_id     = v_cons_shipment_id
        AND    plc1.po_line_id           = psc1.po_line_id
        AND    plc1.po_header_id         = psc1.po_header_id
        AND    phc1.po_header_id         = psc1.po_header_id
        AND    plc2.item_id              = plc1.item_id
        AND    NVL(plc2.item_revision, NULL_VALUE) =
				NVL(plc1.item_revision, NULL_VALUE)
        AND    NVL(plc2.unit_meas_lookup_code, MAGIC_STRING) =
				NVL(plc1.unit_meas_lookup_code, MAGIC_STRING)
        AND    phc2.po_header_id         = plc2.po_header_id
        AND    phc2.type_lookup_code     = 'BLANKET'
        AND    phc2.vendor_id            = p_pref_supplier_id
        AND    v_cons_date BETWEEN NVL(phc2.start_date, v_cons_date)
                               AND NVL(phc2.end_date, v_cons_date)
        AND    NVL(phc2.currency_code, MAGIC_STRING) =
				NVL(phc1.currency_code, MAGIC_STRING)
        ORDER BY blanket_price;

================================================================== */

BEGIN

  -- ------------------------------------------------------------------------
  -- Get PREFERRED supplier info.
  -- The average is calculated for the whole period window.
  -- These will be compared to the ones from the consolidated supplier to
  -- calculate the savings.
  -- ------------------------------------------------------------------------

  BEGIN
    x_progress := '001';

    -- Select the average price and
    -- the average percentage of delivery exception

    SELECT SUM(psp.price_g * (psp.qty_ordered_b - psp.qty_cancelled_b)) /
	       SUM(psp.qty_ordered_b - psp.qty_cancelled_b),
	   SUM(psp.qty_early_receipt_b + psp.qty_late_receipt_b +
	       psp.qty_past_due_b) / SUM(psp.qty_ordered_b - psp.qty_cancelled_b)
    INTO   v_pref_purch_price,
	   v_pref_pct_del_excp
    FROM   edw_time_m		cal,
	   edw_items_m		item,
	   edw_trd_partner_m 	tp,
	   poa_edw_sup_perf_f	psp
    WHERE  psp.item_fk_key 		= item.irev_item_revision_pk_key
    AND    item.item_item_name		= p_item_name
    AND    psp.date_dim_fk_key 		= cal.cday_cal_day_pk_key
    AND    psp.supplier_site_fk_key 	= tp.tplo_tpartner_loc_pk_key
    AND    tp.tprt_name			= p_pref_supplier_name
    AND    NVL(psp.qty_ordered_b - psp.qty_cancelled_b, 0) <> 0
    AND    cal.cday_cal_day_pk <> 'NA_EDW'
    AND    cal.day_julian_day IS NOT NULL
    AND    cal.day_julian_day <> 0
    AND    to_date(cal.day_julian_day,'J') BETWEEN p_start_date AND p_end_date;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_pref_purch_price  := NO_PREF_SUPPLIER;
 	v_pref_pct_del_excp := NO_PREF_SUPPLIER;

      WHEN OTHERS THEN
        RAISE;
        RETURN(v_ret_value);
  END;

  BEGIN
    x_progress := '002';

    -- Select the average percentage of defect

    SELECT SUM(psp.qty_rejected_b)/SUM(psp.qty_received_b)
    INTO   v_pref_pct_defect
    FROM   edw_time_m		cal,
	   edw_items_m		item,
	   edw_trd_partner_m 	tp,
	   poa_edw_sup_perf_f	psp
    WHERE  psp.item_fk_key 		= item.irev_item_revision_pk_key
    AND    item.item_item_name		= p_item_name
    AND    psp.date_dim_fk_key 		= cal.cday_cal_day_pk_key
    AND    psp.supplier_site_fk_key 	= tp.tplo_tpartner_loc_pk_key
    AND    tp.tprt_name			= p_pref_supplier_name
    AND    NVL(psp.qty_received_b, 0)     <> 0
    AND    cal.cday_cal_day_pk <> 'NA_EDW'
    AND    cal.day_julian_day IS NOT NULL
    AND    cal.day_julian_day <> 0
    AND    to_date(cal.day_julian_day,'J') BETWEEN p_start_date AND p_end_date;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	v_pref_pct_defect   := NO_PREF_SUPPLIER;

      WHEN OTHERS THEN
        RAISE;
        RETURN(v_ret_value);
  END;

  --
  -- No records for the preferred supplier in the period window?
  --
  -- Since the previous SQL statements is a SUM, a record w/ NULL values will
  -- still be returned even if there is no record in the base table that
  -- satisfies the conditions.
  -- So, check again here.
  --
  IF (v_pref_purch_price IS NULL) THEN
    v_pref_purch_price  := NO_PREF_SUPPLIER;
  END IF;

  IF (v_pref_pct_defect IS NULL) THEN
    v_pref_pct_defect  := NO_PREF_SUPPLIER;
  END IF;

  IF (v_pref_pct_del_excp IS NULL) THEN
    v_pref_pct_del_excp  := NO_PREF_SUPPLIER;
  END IF;

  -- ------------------------------------------------------------------------
  -- Get consolidated supplier(s) info and calculate savings
  -- ------------------------------------------------------------------------
  x_progress := '004';

  OPEN c_cons_supplier;

  LOOP
    x_progress := '005';
    FETCH c_cons_supplier INTO v_cons_shipment_id,
			       v_cons_purch_price,
			       v_cons_qty_purchased,
			       v_cons_qty_received,
  			       v_cons_qty_rejected,
			       v_cons_qty_del_excp,
			       v_cons_date_fk;

    EXIT WHEN c_cons_supplier%NOTFOUND;

/* ==================================================================

  FS: 	Comment out the code for blankets since blanket price breaks
	are not available in the WH yet.

    --
    -- If there's no average price for the preferred supplier, get
    -- blanket price.
    --
    -- First look at those blankets w/ price breaks,
    -- then look at those blankets w/out price breaks
    -- Because of the ORDER BY clause in the SELECT statements we only need
    -- to fetch the first record returned.
    --
    IF (v_pref_purch_price = NO_PREF_SUPPLIER) THEN
      v_pref_blanket_price  := NO_PREF_SUPPLIER;

      -- Get blankets w/ price breaks

      x_progress := '006';

      OPEN c_blanket_break;
      FETCH c_blanket_break INTO v_pref_blanket_price;

      IF c_blanket_break%NOTFOUND THEN
        v_pref_blanket_price  := NO_PREF_SUPPLIER;
      END IF;

      CLOSE c_blanket_break;

      -- Get blankets w/out price breaks

      x_progress := '007';

      OPEN c_blanket_nobreak;
      FETCH c_blanket_nobreak INTO v_pref_blanket_price2;

      IF c_blanket_nobreak%NOTFOUND THEN
        v_pref_blanket_price2  := NO_PREF_SUPPLIER;
      END IF;

      CLOSE c_blanket_nobreak;

      -- Pick the lower blanket price

      IF (v_pref_blanket_price2 <> NO_PREF_SUPPLIER) THEN

        IF (v_pref_blanket_price = NO_PREF_SUPPLIER) THEN
          v_pref_blanket_price := v_pref_blanket_price2;
        ELSIF (v_pref_blanket_price > v_pref_blanket_price2) THEN
	  v_pref_blanket_price := v_pref_blanket_price2;
        END IF;

      END IF;

      -- Comment out the following dbms_output calls to prevent
      -- buffer overflow. Keep for debugging purposes.

      -- dbms_output.put_line('-- Preferred supplier blanket info --');
      -- dbms_output.put_line('Date dimension : ' || v_cons_date_fk);
      -- dbms_output.put_line('Blanket price  : ' || v_pref_blanket_price);

    END IF;

================================================================== */

    --
    -- Price Savings = (purch price [consolidated] - avg price [preferred]) *
    --		       qty purchased [consolidated]
    --
    IF (v_pref_purch_price <> NO_PREF_SUPPLIER) THEN
      v_price_savings 	 := v_price_savings +
		            ((v_cons_purch_price - v_pref_purch_price) *
			     v_cons_qty_purchased);
/*
    ELSIF (v_pref_blanket_price <> NO_PREF_SUPPLIER) THEN
      v_price_savings 	 := v_price_savings +
		            ((v_cons_purch_price - v_pref_blanket_price) *
			     v_cons_qty_purchased);
*/
    END IF;

    --
    -- Quality Savings = (% of defect [consolidated] -
    --			  avg % of defect [preferred]) *
    -- 		         qty received [consolidated] * cost per defect
    --
    IF (v_pref_pct_defect <> NO_PREF_SUPPLIER) AND
       (v_cons_qty_received <> 0) THEN
      v_quality_savings	 := v_quality_savings +
		            (((v_cons_qty_rejected / v_cons_qty_received) -
			      v_pref_pct_defect) * v_cons_qty_received *
			     p_defect_cost);
    END IF;

    --
    -- Delivery Savings = (% of delivery exception [consolidated] -
    --			   avg % of delivery exception [preferred]) *
    -- 		          qty purchased [consolidated] *
    --			  cost per delivery exception
    --
    IF (v_pref_pct_del_excp <> NO_PREF_SUPPLIER) AND
       (v_cons_qty_purchased <> 0) THEN
      v_delivery_savings := v_delivery_savings +
		            (((v_cons_qty_del_excp / v_cons_qty_purchased) -
			      v_pref_pct_del_excp) * v_cons_qty_purchased *
			     p_del_excp_cost);
    END IF;

  END LOOP;

  CLOSE c_cons_supplier;

  v_total_savings	:= v_price_savings + v_quality_savings +
			   v_delivery_savings;

--  dbms_output.put_line('-- Savings --');
--  dbms_output.put_line('Price	       : ' || v_price_savings);
--  dbms_output.put_line('Quality	       : ' || v_quality_savings);
--  dbms_output.put_line('Delivery       : ' || v_delivery_savings);
--  dbms_output.put_line('Total	       : ' || v_total_savings);

  IF (p_return_type = PRICE_TYPE) THEN
    RETURN(v_price_savings);
  ELSIF (p_return_type = QUALITY_TYPE) THEN
    RETURN(v_quality_savings);
  ELSIF (p_return_type = DELIVERY_TYPE) THEN
    RETURN(v_delivery_savings);
  ELSE
    RETURN(v_total_savings);
  END IF;


EXCEPTION
  WHEN OTHERS THEN

    IF c_cons_supplier%ISOPEN THEN
      CLOSE c_cons_supplier;
    END IF;

/*
    IF c_blanket_break%ISOPEN THEN
      CLOSE c_blanket_break;
    END IF;

    IF c_blanket_nobreak%ISOPEN THEN
      CLOSE c_blanket_nobreak;
    END IF;
*/

    RAISE;
    RETURN(v_total_savings);

END calc_savings;


END poa_wh_supplier_cons_pk;

/
