--------------------------------------------------------
--  DDL for Package Body POA_SUPPLIER_CONSOLIDATION_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_SUPPLIER_CONSOLIDATION_PK" AS
 /* $Header: poaspcob.pls 115.8 2002/12/27 21:29:36 iali ship $ */

  ALL_SUPPLIER			CONSTANT INTEGER := -9999;
  NO_PREF_SUPPLIER		CONSTANT INTEGER := -1;

  NULL_VALUE                    CONSTANT INTEGER := -23453;
  MAGIC_STRING                  CONSTANT VARCHAR2(10) := '734jkhJK24';
  BUFFER_SIZE_LEN		CONSTANT INTEGER := 1000000;


-- ========================================================================
--
--  Calculate the potential savings from consolidating supplier(s) to a
--  preferred supplier.
--  This procedure is called from Supplier Consolidation.
--
-- ========================================================================

PROCEDURE calculate_savings(
		  p_item_id		IN NUMBER,
		  p_pref_supplier_id	IN NUMBER,
		  p_cons_supplier_id	IN NUMBER,
		  p_defect_cost		IN NUMBER,
		  p_del_excp_cost	IN NUMBER,
		  p_currency_code	IN VARCHAR2,
		  p_start_date		IN DATE,
		  p_end_date		IN DATE,
                 p_user_id              IN  NUMBER,
		  p_bucket_type		IN  NUMBER,
		 p_price_savings	OUT NOCOPY NUMBER,
		 p_quality_savings	OUT NOCOPY NUMBER,
		 p_delivery_savings	OUT NOCOPY NUMBER,
		 p_total_savings	OUT NOCOPY NUMBER) IS

  VERSION                       CONSTANT CHAR(80) :=
        '$Header: poaspcob.pls 115.8 2002/12/27 21:29:36 iali ship $';

  -- Consolidated Supplier(s) info
  v_cons_shipment_id            NUMBER;		-- Shipment id
  v_cons_purch_price		NUMBER;		-- Purchase price
  v_cons_qty_purchased		NUMBER;		-- Qty purchased
  v_cons_qty_ordered		NUMBER;		-- Qty ordered
  v_cons_qty_received		NUMBER;		-- Qty received
  v_cons_qty_rejected		NUMBER;		-- Qty rejected
  v_cons_qty_del_excp		NUMBER;		-- Qty of delivery exception
  v_cons_date			DATE;		-- Date dimension

  -- Preferred Supplier info
  v_pref_purch_price		NUMBER;		-- Avg price
  v_pref_blanket_price		NUMBER;		-- Blanket agreement price
  v_pref_blanket_price2		NUMBER;		-- Blanket agreement price
  v_pref_pct_defect		NUMBER;		-- Avg % of defect
  v_pref_pct_del_excp		NUMBER;		-- Avg % of delivery exception

  -- General
  v_price_savings		NUMBER := 0;
  v_quality_savings		NUMBER := 0;
  v_delivery_savings		NUMBER := 0;
  x_progress			VARCHAR2(3) := NULL;

  --
  -- Select the information for the CONSOLIDATED supplier(s).
  -- It can either be from a single supplier (specified in the parameter)
  -- or from all available suppliers within the period window.
  --
  CURSOR c_cons_supplier IS
    SELECT psp.po_shipment_id,
	   NVL(psp.purchase_price, 0) *
           DECODE(gl_currency_api.rate_exists(psp.currency_code,
                                              p_currency_code, psp.rate_date,
                                              psp.rate_type),
                  'Y',
        	  gl_currency_api.get_rate(psp.currency_code, p_currency_code,
				           psp.rate_date, psp.rate_type),
                  1),
           NVL(psp.quantity_purchased, 0), NVL(psp.quantity_ordered, 0),
	   NVL(psp.quantity_received, 0), NVL(psp.quantity_rejected, 0),
           NVL((psp.quantity_received_late + psp.quantity_received_early +
	        psp.quantity_past_due), 0),
	   psp.date_dimension
    FROM   poa_bis_supplier_performance psp
    WHERE  psp.item_id			= p_item_id
    AND    psp.date_dimension BETWEEN p_start_date AND p_end_date
    AND    (psp.supplier_id		= p_cons_supplier_id
    OR      ALL_SUPPLIER                = p_cons_supplier_id)
    ORDER BY psp.currency_code;

  CURSOR c_cons_supplier_glb_sec IS
    SELECT psp.po_shipment_id,
           NVL(psp.purchase_price, 0) *
           DECODE(gl_currency_api.rate_exists(psp.currency_code,
                                              p_currency_code, psp.rate_date,
                                              psp.rate_type),
                  'Y',
                  gl_currency_api.get_rate(psp.currency_code, p_currency_code,
                                           psp.rate_date, psp.rate_type),
                  1),
           NVL(psp.quantity_purchased, 0), NVL(psp.quantity_ordered, 0),
           NVL(psp.quantity_received, 0), NVL(psp.quantity_rejected, 0),
           NVL((psp.quantity_received_late + psp.quantity_received_early +
                psp.quantity_past_due), 0),
           psp.date_dimension
    FROM   poa_bis_supplier_performance psp
    WHERE  psp.item_id                  = p_item_id
    AND    psp.date_dimension BETWEEN p_start_date AND p_end_date
    AND    (psp.supplier_id             = p_cons_supplier_id
     OR      ALL_SUPPLIER                = p_cons_supplier_id)
    AND    (psp.org_id in (SELECT id FROM bis_operating_units_v
                           WHERE responsibility_id in
                                 (SELECT responsibility_id
                                  FROM fnd_user_resp_groups
                                  WHERE user_id = p_user_id
                                    AND sysdate BETWEEN start_date
                                    AND NVL(end_date, sysdate+1)))
     OR     psp.org_id IS NULL)
  ORDER BY psp.currency_code;

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
        AND    phc2.vendor_id            = p_pref_supplier_id
        ORDER BY psc2.quantity desc, blanket_price asc;

  CURSOR c_blanket_break_glb_sec IS
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
        FROM   po_headers_all           phc2,
               po_headers_all           phc1,
               po_lines_all             plc2,
               po_lines_all             plc1,
               po_line_locations_all    psc2,
               po_line_locations_all    psc1
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
        AND    phc2.vendor_id            = p_pref_supplier_id
        AND    (phc2.org_id in (SELECT id FROM bis_operating_units_v
                           WHERE responsibility_id in
                                 (SELECT responsibility_id
                                  FROM fnd_user_resp_groups
                                  WHERE user_id = p_user_id
                                    AND sysdate BETWEEN start_date
                                    AND NVL(end_date, sysdate+1)))
         OR    phc2.org_id  IS NULL)
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

  CURSOR c_blanket_nobreak_glb_sec IS
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
        FROM   po_headers_all           phc2,
               po_headers_all           phc1,
               po_lines_all             plc2,
               po_lines_all             plc1,
               po_line_locations_all    psc1
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
        AND    v_cons_date BETWEEN NVL(phc2.start_date, v_cons_date)
                               AND NVL(phc2.end_date, v_cons_date)
        AND    NVL(phc2.currency_code, MAGIC_STRING) =
                                NVL(phc1.currency_code, MAGIC_STRING)
        AND    phc2.vendor_id            = p_pref_supplier_id
        AND    (phc2.org_id in (SELECT id FROM bis_operating_units_v
                           WHERE responsibility_id in
                                 (SELECT responsibility_id
                                  FROM fnd_user_resp_groups
                                  WHERE user_id = p_user_id
                                    AND sysdate BETWEEN start_date
                                    AND NVL(end_date, sysdate+1)))
        OR     phc2.org_id IS NULL)
        ORDER BY blanket_price;


BEGIN
--  dbms_output.enable(BUFFER_SIZE_LEN);

  p_price_savings 	:= 0;
  p_quality_savings	:= 0;
  p_delivery_savings	:= 0;
  p_total_savings	:= 0;

  -- ------------------------------------------------------------------------
  -- Get PREFERRED supplier info.
  -- The average is calculated for the whole period window.
  -- These will be compared to the ones from the consolidated supplier to
  -- calculate the savings.
  -- ------------------------------------------------------------------------

  BEGIN
    x_progress := '001';

    -- Select the average price

    IF (fnd_profile.value('POA_GLOBAL_SECURITY') = 'Y') THEN
      SELECT SUM(psp.purchase_price *
                 DECODE(gl_currency_api.rate_exists(psp.currency_code,
                                                    p_currency_code,
                                                    psp.rate_date,
                                                    psp.rate_type),
                        'Y',
        	        gl_currency_api.get_rate(psp.currency_code,
                                                 p_currency_code,
				                 psp.rate_date, psp.rate_type),
                        1) *
                 psp.quantity_purchased) /
             SUM(psp.quantity_purchased)
      INTO   v_pref_purch_price
      FROM   poa_bis_supplier_performance	psp
      WHERE  psp.item_id			= p_item_id
      AND    psp.supplier_id		= p_pref_supplier_id
      AND    NVL(psp.quantity_purchased, 0) <> 0
      AND    psp.date_dimension BETWEEN p_start_date AND p_end_date;
    ELSE
      SELECT SUM(psp.purchase_price *
                 DECODE(gl_currency_api.rate_exists(psp.currency_code,
                                                    p_currency_code,
                                                    psp.rate_date,
                                                    psp.rate_type),
                        'Y',
                        gl_currency_api.get_rate(psp.currency_code,
                                                 p_currency_code,
                                                 psp.rate_date, psp.rate_type),
                        1) *
                 psp.quantity_purchased) /
             SUM(psp.quantity_purchased)
      INTO   v_pref_purch_price
      FROM   poa_bis_supplier_performance       psp
      WHERE  psp.item_id                        = p_item_id
      AND    NVL(psp.quantity_purchased, 0) <> 0
      AND    psp.date_dimension BETWEEN p_start_date AND p_end_date
      AND    psp.supplier_id            = p_pref_supplier_id
      AND    (psp.org_id in (SELECT id FROM bis_operating_units_v
                             WHERE responsibility_id in
                                   (SELECT responsibility_id
                                      FROM fnd_user_resp_groups
                                     WHERE user_id = p_user_id
                                       AND sysdate BETWEEN start_date
                                       AND NVL(end_date, sysdate+1)))
       OR     psp.org_id IS NULL);
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_pref_purch_price  := NO_PREF_SUPPLIER;

      WHEN OTHERS THEN
--    	dbms_output.put_line('calculate_savings - ' || x_progress
--                             || ': ' || sqlerrm);
        po_message_s.sql_error('calculate_savings', x_progress, sqlerrm);
        RAISE;
        RETURN;
  END calculate_savings;

  BEGIN
    x_progress := '002';

    -- Select the average percentage of defect

    IF (fnd_profile.value('POA_GLOBAL_SECURITY') = 'Y') THEN
      SELECT SUM(psp.quantity_rejected)/SUM(psp.quantity_received)
      INTO   v_pref_pct_defect
      FROM   poa_bis_supplier_performance	psp
      WHERE  psp.item_id			= p_item_id
      AND    NVL(psp.quantity_received, 0) <> 0
      AND    psp.date_dimension BETWEEN p_start_date AND p_end_date
      AND    psp.supplier_id              = p_pref_supplier_id;
   ELSE
      SELECT SUM(psp.quantity_rejected)/SUM(psp.quantity_received)
      INTO   v_pref_pct_defect
      FROM   poa_bis_supplier_performance       psp
      WHERE  psp.item_id                        = p_item_id
      AND    NVL(psp.quantity_received, 0) <> 0
      AND    psp.date_dimension BETWEEN p_start_date AND p_end_date
      AND    psp.supplier_id              = p_pref_supplier_id
      AND    (psp.org_id in (SELECT id FROM bis_operating_units_v
                             WHERE responsibility_id in
                                   (SELECT responsibility_id
                                      FROM fnd_user_resp_groups
                                     WHERE user_id = p_user_id
                                       AND sysdate BETWEEN start_date
                                       AND NVL(end_date, sysdate+1)))
       OR     psp.org_id IS NULL);
    END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	v_pref_pct_defect   := NO_PREF_SUPPLIER;

      WHEN OTHERS THEN
--    	dbms_output.put_line('calculate_savings - ' || x_progress
--                             || ': ' || sqlerrm);
        po_message_s.sql_error('calculate_savings', x_progress, sqlerrm);
        RAISE;
        RETURN;
  END calculate_savings;

  BEGIN
    x_progress := '003';

    -- Select the average percentage of delivery exception

    IF (fnd_profile.value('POA_GLOBAL_SECURITY') = 'Y') THEN
      SELECT SUM(psp.quantity_received_late + psp.quantity_received_early +
	         psp.quantity_past_due)/SUM(psp.quantity_purchased)
      INTO   v_pref_pct_del_excp
      FROM   poa_bis_supplier_performance	psp
      WHERE  psp.item_id			= p_item_id
      AND    NVL(psp.quantity_purchased, 0) <> 0
      AND    psp.date_dimension BETWEEN p_start_date AND p_end_date
      AND    psp.supplier_id		= p_pref_supplier_id;
   ELSE
      SELECT SUM(psp.quantity_received_late + psp.quantity_received_early +
                 psp.quantity_past_due)/SUM(psp.quantity_purchased)
      INTO   v_pref_pct_del_excp
      FROM   poa_bis_supplier_performance       psp
      WHERE  psp.item_id                        = p_item_id
      AND    NVL(psp.quantity_purchased, 0) <> 0
      AND    psp.date_dimension BETWEEN p_start_date AND p_end_date
      AND    psp.supplier_id            = p_pref_supplier_id
      AND    (psp.org_id in (SELECT id FROM bis_operating_units_v
                             WHERE responsibility_id in
                                   (SELECT responsibility_id
                                      FROM fnd_user_resp_groups
                                     WHERE user_id = p_user_id
                                       AND sysdate BETWEEN start_date
                                       AND NVL(end_date, sysdate+1)))
       OR     psp.org_id IS NULL);
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	v_pref_pct_del_excp := NO_PREF_SUPPLIER;

      WHEN OTHERS THEN
--        dbms_output.put_line('calculate_savings - ' || x_progress
--                             || ': ' || sqlerrm);
        po_message_s.sql_error('calculate_savings', x_progress, sqlerrm);
        RAISE;
        RETURN;
  END calculate_savings;

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


--  dbms_output.put_line('-- Preferred supplier info --');
--  dbms_output.put_line('Avg purch price: ' || v_pref_purch_price);
--  dbms_output.put_line('Pct of defect  : ' || v_pref_pct_defect);
--  dbms_output.put_line('Pct of del excp: ' || v_pref_pct_del_excp);

  -- ------------------------------------------------------------------------
  -- Get consolidated supplier(s) info and calculate savings
  -- ------------------------------------------------------------------------
  x_progress := '004';

  IF (fnd_profile.value('POA_GLOBAL_SECURITY') = 'Y') THEN
    OPEN c_cons_supplier;
  ELSE
      OPEN c_cons_supplier_glb_sec;
  END IF;

  LOOP
    x_progress := '005';

    IF (fnd_profile.value('POA_GLOBAL_SECURITY') = 'Y') THEN
      FETCH c_cons_supplier INTO v_cons_shipment_id,
			         v_cons_purch_price,
			         v_cons_qty_purchased,
			         v_cons_qty_ordered,
			         v_cons_qty_received,
  			         v_cons_qty_rejected,
			         v_cons_qty_del_excp,
			         v_cons_date;
      EXIT WHEN c_cons_supplier%NOTFOUND;
    ELSE
      FETCH c_cons_supplier_glb_sec INTO v_cons_shipment_id,
                                 v_cons_purch_price,
                                 v_cons_qty_purchased,
                                 v_cons_qty_ordered,
                                 v_cons_qty_received,
                                 v_cons_qty_rejected,
                                 v_cons_qty_del_excp,
                                 v_cons_date;
      EXIT WHEN c_cons_supplier_glb_sec%NOTFOUND;
    END IF;


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

      IF (fnd_profile.value('POA_GLOBAL_SECURITY') = 'Y') THEN
        OPEN c_blanket_break;
        FETCH c_blanket_break INTO v_pref_blanket_price;

        IF c_blanket_break%NOTFOUND THEN
          v_pref_blanket_price  := NO_PREF_SUPPLIER;
        END IF;

        CLOSE c_blanket_break;
      ELSE
        OPEN c_blanket_break_glb_sec;
        FETCH c_blanket_break_glb_sec INTO v_pref_blanket_price;

        IF c_blanket_break_glb_sec%NOTFOUND THEN
          v_pref_blanket_price  := NO_PREF_SUPPLIER;
        END IF;

       CLOSE c_blanket_break_glb_sec;
      END IF;

      -- Get blankets w/out price breaks

      x_progress := '007';

      IF (fnd_profile.value('POA_GLOBAL_SECURITY') = 'Y') THEN
        OPEN c_blanket_nobreak;
        FETCH c_blanket_nobreak INTO v_pref_blanket_price2;

        IF c_blanket_nobreak%NOTFOUND THEN
          v_pref_blanket_price2  := NO_PREF_SUPPLIER;
        END IF;

        CLOSE c_blanket_nobreak;
      ELSE
        OPEN c_blanket_nobreak_glb_sec;
        FETCH c_blanket_nobreak_glb_sec INTO v_pref_blanket_price2;

        IF c_blanket_nobreak_glb_sec%NOTFOUND THEN
          v_pref_blanket_price2  := NO_PREF_SUPPLIER;
        END IF;

        CLOSE c_blanket_nobreak_glb_sec;
      END IF;

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
      -- dbms_output.put_line('Date dimension : ' || v_cons_date);
      -- dbms_output.put_line('Blanket price  : ' || v_pref_blanket_price);

    END IF;

    --
    -- Price Savings = (purch price [consolidated] - avg price [preferred]) *
    --		       qty purchased [consolidated]
    --
    IF (v_pref_purch_price <> NO_PREF_SUPPLIER) THEN
      v_price_savings 	 := v_price_savings +
		            ((v_cons_purch_price - v_pref_purch_price) *
			     v_cons_qty_purchased);
    ELSIF (v_pref_blanket_price <> NO_PREF_SUPPLIER) THEN
      v_price_savings 	 := v_price_savings +
		            ((v_cons_purch_price - v_pref_blanket_price) *
			     v_cons_qty_purchased);
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

  IF (fnd_profile.value('POA_GLOBAL_SECURITY') = 'Y') THEN
    CLOSE c_cons_supplier;
  ELSE
    CLOSE c_cons_supplier_glb_sec;
  END IF;

  p_price_savings 	:= v_price_savings;
  p_quality_savings	:= v_quality_savings;
  p_delivery_savings	:= v_delivery_savings;

  p_total_savings	:= p_price_savings + p_quality_savings +
			   p_delivery_savings;

--  dbms_output.put_line('-- Savings --');
--  dbms_output.put_line('Price	       : ' || p_price_savings);
--  dbms_output.put_line('Quality	       : ' || p_quality_savings);
--  dbms_output.put_line('Delivery       : ' || p_delivery_savings);
--  dbms_output.put_line('Total	       : ' || p_total_savings);

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
--    dbms_output.put_line('calculate_savings - ' || x_progress
--                         || ': ' || sqlerrm);
    po_message_s.sql_error('calculate_savings', x_progress, sqlerrm);

    IF c_cons_supplier%ISOPEN THEN
      CLOSE c_cons_supplier;
    END IF;

    IF c_cons_supplier_glb_sec%ISOPEN THEN
      CLOSE c_cons_supplier_glb_sec;
    END IF;

    IF c_blanket_break%ISOPEN THEN
      CLOSE c_blanket_break;
    END IF;

    IF c_blanket_break_glb_sec%ISOPEN THEN
      CLOSE c_blanket_break_glb_sec;
    END IF;

    IF c_blanket_nobreak%ISOPEN THEN
      CLOSE c_blanket_nobreak;
    END IF;

    IF c_blanket_nobreak_glb_sec%ISOPEN THEN
      CLOSE c_blanket_nobreak_glb_sec;
    END IF;

    RAISE;
    RETURN;
END calculate_savings;


END poa_supplier_consolidation_pk;

/
