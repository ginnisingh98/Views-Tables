--------------------------------------------------------
--  DDL for Package Body CHV_INQ_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_INQ_SV2" as
/* $Header: CHVSIN2B.pls 120.0.12010000.6 2014/05/28 12:52:03 shikapoo noship $*/

/*=============================  CHV_INQ_SV2  ===============================*/

FUNCTION get_last_receipt_num(p_org_id IN NUMBER,
			      p_item_id in NUMBER,
			      p_vendor_id in NUMBER,
			      p_vendor_site_id in NUMBER,
			      p_cum_period_start_date in DATE,
			      p_cum_period_end_date in DATE)
			RETURN varchar2 is

x_last_receipt_id number  := null ;
x_last_receipt_num varchar2(30) := null;

begin

 select max(rct.transaction_id)
        into x_last_receipt_id
        from   rcv_transactions rct,
	       rcv_shipment_lines rsl,
	       po_headers poh,
		   po_line_locations pll
	where  rct.shipment_line_id = rsl.shipment_line_id
	and    rct.transaction_type = 'RECEIVE'
	and    rct.transaction_date between
		to_date(p_cum_period_start_date) and
		to_date(p_cum_period_end_date)
        and     rsl.to_organization_id = p_org_id
        and     rsl.item_id            = p_item_id
        and     rsl.po_header_id       = poh.po_header_id
		and     rsl.po_line_location_id = pll.line_location_id
        and     poh.vendor_id          = p_vendor_id
        and     poh.vendor_site_id     = p_vendor_site_id
        -- Bug#18822988: Cummins GBPA Support : Start
		and    ( ( poh.type_lookup_code = 'BLANKET'
		            AND poh.supply_agreement_flag = 'Y')
				 OR ( poh.type_lookup_code = 'STANDARD'
                   AND EXISTS (
                         SELECT 1 FROM po_headers ph1
                         WHERE   pll.from_header_id IS NOT NULL
                         AND     pll.from_header_id = ph1.po_header_id
                         AND     ph1.type_lookup_code = 'BLANKET'
                         AND     ph1.global_agreement_flag = 'Y'
                         AND     ph1.supply_agreement_flag = 'Y'
                         )
                 )	)
        -- Bug#18822988: Cummins GBPA Support : End
        and    rct.transaction_date in
        (select max(rct2.transaction_date)
        from   rcv_transactions rct2,
	       rcv_shipment_lines rsl2,
               po_headers poh2,
			   po_line_locations pll2
        where  rct2.shipment_line_id   = rsl2.shipment_line_id
        and    rct2.transaction_type   = 'RECEIVE'
        and    rct2.transaction_date between
                to_date(p_cum_period_start_date) and
                to_date(p_cum_period_end_date)
        and    rsl2.to_organization_id = p_org_id
        and    rsl2.item_id            = p_item_id
        and    rsl2.po_header_id       = poh2.po_header_id
		and    rsl2.po_line_location_id = pll2.line_location_id
        and    poh2.vendor_id          = p_vendor_id
        and    poh2.vendor_site_id     = p_vendor_site_id
        -- Bug#18822988: Cummins GBPA Support : Start
        AND (( poh2.type_lookup_code = 'BLANKET'
		         AND poh2.supply_agreement_flag = 'Y')
 	          OR ( poh2.type_lookup_code = 'STANDARD'
                   AND EXISTS (
                         SELECT 1 FROM po_headers ph1
                         WHERE   pll2.from_header_id IS NOT NULL
                         AND     pll2.from_header_id = ph1.po_header_id
                         AND     ph1.type_lookup_code = 'BLANKET'
                         AND     ph1.global_agreement_flag = 'Y'
                         AND     ph1.supply_agreement_flag = 'Y'
                         )
                 )	));
        -- Bug#18822988: Cummins GBPA Support : End

  select receipt_num
  into   x_last_receipt_num
  from   rcv_transactions rct,
	 rcv_shipment_headers rsh
  where  rct.transaction_id = x_last_receipt_id
  and    rct.shipment_header_id = rsh.shipment_header_id;

  return(x_last_receipt_num) ;

exception when others then
     return('') ;

end get_last_receipt_num;

FUNCTION get_last_receipt_date(p_org_id IN NUMBER,
			      p_item_id in NUMBER,
			      p_vendor_id in NUMBER,
			      p_vendor_site_id in NUMBER,
			      p_cum_period_start_date in DATE,
			      p_cum_period_end_date in DATE)
			RETURN date is

x_last_receipt_id number  := null ;
x_last_receipt_date date  := null;

begin

 select max(rct.transaction_id)
        into x_last_receipt_id
        from   rcv_transactions rct,
	       rcv_shipment_lines rsl,
	       po_headers poh,
		   po_line_locations pll
	where  rct.shipment_line_id = rsl.shipment_line_id
	and    rct.transaction_type = 'RECEIVE'
	and    rct.transaction_date between
		to_date(p_cum_period_start_date) and
		to_date(p_cum_period_end_date)
        and     rsl.to_organization_id = p_org_id
        and     rsl.item_id            = p_item_id
        and     rsl.po_header_id       = poh.po_header_id
        and     rsl.po_line_location_id = pll.line_location_id
		and     poh.vendor_id          = p_vendor_id
        and     poh.vendor_site_id     = p_vendor_site_id
        -- Bug#18822988: Cummins GBPA Support : Start
        AND (( poh.type_lookup_code = 'BLANKET'
		         AND poh.supply_agreement_flag = 'Y')
 	          OR ( poh.type_lookup_code = 'STANDARD'
                   AND EXISTS (
                         SELECT 1 FROM po_headers ph1
                         WHERE   pll.from_header_id IS NOT NULL
                         AND     pll.from_header_id = ph1.po_header_id
                         AND     ph1.type_lookup_code = 'BLANKET'
                         AND     ph1.global_agreement_flag = 'Y'
                         AND     ph1.supply_agreement_flag = 'Y'
                         )
                 ))
        -- Bug#18822988: Cummins GBPA Support : End
        and     rct.transaction_date in
        (select max(rct2.transaction_date)
        from   rcv_transactions rct2,
	        rcv_shipment_lines rsl2,
               po_headers poh2,
			   po_line_locations pll2
        where  rct2.shipment_line_id   = rsl2.shipment_line_id
        and    rct2.transaction_type   = 'RECEIVE'
        and    rct2.transaction_date between
                to_date(p_cum_period_start_date) and
                to_date(p_cum_period_end_date)
        and    rsl2.to_organization_id = p_org_id
        and    rsl2.item_id            = p_item_id
        and    rsl2.po_header_id       = poh.po_header_id
		and    rsl2.po_line_location_id = pll2.line_location_id
        and    poh2.vendor_id          = p_vendor_id
        and    poh2.vendor_site_id     = p_vendor_site_id
                -- Bug#18822988: Cummins GBPA Support : Start
        AND (( poh2.type_lookup_code = 'BLANKET'
		         AND poh2.supply_agreement_flag = 'Y')
 	          OR ( poh2.type_lookup_code = 'STANDARD'
                   AND EXISTS (
                         SELECT 1 FROM po_headers ph1
                         WHERE   pll2.from_header_id IS NOT NULL
                         AND     pll2.from_header_id = ph1.po_header_id
                         AND     ph1.type_lookup_code = 'BLANKET'
                         AND     ph1.global_agreement_flag = 'Y'
                         AND     ph1.supply_agreement_flag = 'Y'
                         )
                 )	));
        -- Bug#18822988: Cummins GBPA Support : End

  select transaction_date
  into   x_last_receipt_date
  from   rcv_transactions rct
  where  rct.transaction_id = x_last_receipt_id;

  return(x_last_receipt_date) ;

exception when others then
     return('') ;

end get_last_receipt_date;

FUNCTION get_last_receipt_quantity(p_org_id IN NUMBER,
			      p_item_id in NUMBER,
			      p_vendor_id in NUMBER,
			      p_vendor_site_id in NUMBER,
			      p_cum_period_start_date in DATE,
			      p_cum_period_end_date in DATE,
			      p_purchasing_uom VARCHAR2)
			RETURN number is

x_last_receipt_id number  := null ;
x_last_receipt_quantity number := null;
x_primary_quantity number := null;
x_primary_unit_of_measure varchar2(25) := null;
x_primary_uom_code varchar2(3);
x_purchasing_uom_code varchar2(3);
x_conversion number;

begin

 select max(rct.transaction_id)
        into x_last_receipt_id
        from   rcv_transactions rct,
	       rcv_shipment_lines rsl,
	       po_headers poh,
		   po_line_locations pll
	where  rct.shipment_line_id = rsl.shipment_line_id
	and    rct.transaction_type = 'RECEIVE'
	and    rct.transaction_date between
		to_date(p_cum_period_start_date) and
		to_date(p_cum_period_end_date)
        and     rsl.to_organization_id = p_org_id
        and     rsl.item_id            = p_item_id
        and     rsl.po_header_id       = poh.po_header_id
		and     rsl.po_line_location_id = pll.line_location_id
        and     poh.vendor_id          = p_vendor_id
        and     poh.vendor_site_id     = p_vendor_site_id
        -- Bug#18822988: Cummins GBPA Support : Start
        AND (( poh.type_lookup_code = 'BLANKET'
		         AND poh.supply_agreement_flag = 'Y')
 	          OR ( poh.type_lookup_code = 'STANDARD'
                   AND EXISTS (
                         SELECT 1 FROM po_headers ph1
                         WHERE   pll.from_header_id IS NOT NULL
                         AND     pll.from_header_id = ph1.po_header_id
                         AND     ph1.type_lookup_code = 'BLANKET'
                         AND     ph1.global_agreement_flag = 'Y'
                         AND     ph1.supply_agreement_flag = 'Y'
                         )
                 )	)
        -- Bug#18822988: Cummins GBPA Support : End
        and     rct.transaction_date in
        (select max(rct2.transaction_date)
        from   rcv_transactions rct2,
	        rcv_shipment_lines rsl2,
               po_headers poh2,
			   po_line_locations pll2
        where  rct2.shipment_line_id   = rsl2.shipment_line_id
        and    rct2.transaction_type   = 'RECEIVE'
        and    rct2.transaction_date between
                to_date(p_cum_period_start_date) and
                to_date(p_cum_period_end_date)
        and    rsl2.to_organization_id = p_org_id
        and    rsl2.item_id            = p_item_id
        and    rsl2.po_header_id       = poh2.po_header_id
		and    rsl2.po_line_location_id = pll2.line_location_id
        and    poh2.vendor_id          = p_vendor_id
        and    poh2.vendor_site_id     = p_vendor_site_id
        -- Bug#18822988: Cummins GBPA Support : Start
        AND (( poh2.type_lookup_code = 'BLANKET'
		         AND poh2.supply_agreement_flag = 'Y')
 	          OR ( poh2.type_lookup_code = 'STANDARD'
                   AND EXISTS (
                         SELECT 1 FROM po_headers ph1
                         WHERE   pll2.from_header_id IS NOT NULL
                         AND     pll2.from_header_id = ph1.po_header_id
                         AND     ph1.type_lookup_code = 'BLANKET'
                         AND     ph1.global_agreement_flag = 'Y'
                         AND     ph1.supply_agreement_flag = 'Y'
                         )
                 )	));
        -- Bug#18822988: Cummins GBPA Support : End

  select primary_quantity,
	 primary_unit_of_measure
  into   x_primary_quantity,
	 x_primary_unit_of_measure
  from   rcv_transactions rct
  where  rct.transaction_id = x_last_receipt_id;

  BEGIN

        SELECT uom_code
        INTO   x_primary_uom_code
        FROM   mtl_units_of_measure
        WHERE  unit_of_measure = x_primary_unit_of_measure;

  EXCEPTION
        WHEN NO_DATA_FOUND THEN null;
        WHEN OTHERS THEN raise;
  END;

  -- Get the uom code (3 characters) for the purch unit of measure

  BEGIN

        SELECT uom_code
        INTO   x_purchasing_uom_code
        FROM   mtl_units_of_measure
        WHERE  unit_of_measure = p_purchasing_uom;

  EXCEPTION
        WHEN NO_DATA_FOUND THEN null;
        WHEN OTHERS THEN raise;
  END;

   inv_convert.inv_um_conversion(x_primary_uom_code,
                                  x_purchasing_uom_code,
                                  p_item_id, x_conversion);


  x_last_receipt_quantity := x_conversion * x_primary_quantity;

  return(x_last_receipt_quantity) ;

exception when others then
     return('') ;

end get_last_receipt_quantity;

FUNCTION get_cum_received_purch (X_vendor_id IN NUMBER,
				X_vendor_site_id IN NUMBER,
                                X_item_id IN NUMBER,
			        X_organization_id IN NUMBER,
			        X_rtv_transactions_included IN VARCHAR2,
				X_cum_period_start IN DATE,
				X_cum_period_end IN DATE,
			        X_purchasing_unit_of_measure IN VARCHAR2)
					return NUMBER is


X_transaction_uom_code varchar2(3);
X_purchasing_uom_code  varchar2(3);
X_primary_uom_code     varchar2(3);
X_uom_rate number;
X_primary_unit_of_measure varchar2(25);
X_unit_of_measure varchar2(25);
X_conversion_rate number;
X_quantity_received number;
X_transaction_id number;
X_rtv_primary_quantity number;
X_rtv_transaction_id number;
X_corrtv_primary_quantity number;
X_total_qty_received_primary number;
X_progress varchar2(3) := '000';
X_adjustment_quantity number;
X_tot_received_purch number;
X_tot_received_primary number;
X_qty_received_purchasing varchar2(25);
X_qty_received_primary varchar2(25);

-- Define the cursor that gets the receipt transaction plus all
-- of the corrections against the receipt
-- Note: We must use the item_id on the po_line instead of
-- on the receipt to account for substitute receipts.
CURSOR C IS
      SELECT rsl.quantity_received,
	     rsl.unit_of_measure,
	     rsl.primary_unit_of_measure,
	     rct.transaction_id
      FROM   rcv_shipment_lines rsl,
	     po_headers poh,
	     po_lines pol,
	     rcv_transactions rct
      WHERE  rct.shipment_line_id = rsl.shipment_line_id
      AND    rct.transaction_type = 'RECEIVE'
      AND    rsl.po_header_id = poh.po_header_id
      AND    rsl.po_line_id = pol.po_line_id
      AND    poh.vendor_id = X_vendor_id
      AND    poh.vendor_site_id = X_vendor_site_id
      AND    rsl.to_organization_id = X_organization_id
      -- Bug#18822988: Cummins GBPA Support : Start
        AND (( poh.type_lookup_code = 'BLANKET'
		         AND poh.supply_agreement_flag = 'Y')
 	          OR ( poh.type_lookup_code = 'STANDARD'
                   AND EXISTS (
                         SELECT 1 FROM po_headers ph1
                         WHERE   pol.from_header_id IS NOT NULL
                         AND     pol.from_header_id = ph1.po_header_id
                         AND     ph1.type_lookup_code = 'BLANKET'
                         AND     ph1.global_agreement_flag = 'Y'
                         AND     ph1.supply_agreement_flag = 'Y'
                         )
                 ))
        -- Bug#18822988: Cummins GBPA Support : End
      AND    pol.item_id = X_item_id
      AND    rct.transaction_date between X_cum_period_start
			          and     X_cum_period_end;


-- Define the cursor to the the rtv transactions against
-- the receipt transaction
CURSOR C2 IS
         SELECT rct.primary_quantity,
	        rct.transaction_id
	 FROM   rcv_transactions rct
         WHERE  rct.transaction_type = 'RETURN TO VENDOR'
         AND    rct.parent_transaction_id = X_transaction_id;

CURSOR C3 IS
      SELECT rsl.quantity_received,
	     rsl.unit_of_measure,
	     rsl.primary_unit_of_measure
      FROM   rcv_shipment_lines rsl,
	     po_headers poh,
	     po_lines pol
      WHERE  pol.item_id = X_item_id
      AND    rsl.po_line_id = pol.po_line_id
      AND    pol.po_header_id = poh.po_header_id
      AND    poh.vendor_id = X_vendor_id
      AND    poh.vendor_site_id = X_vendor_site_id
      AND    rsl.to_organization_id = X_organization_id
      -- Bug#18822988: Cummins GBPA Support : Start
        AND (( poh.type_lookup_code = 'BLANKET'
		         AND poh.supply_agreement_flag = 'Y')
 	          OR ( poh.type_lookup_code = 'STANDARD'
                   AND EXISTS (
                         SELECT 1 FROM po_headers ph1
                         WHERE   pol.from_header_id IS NOT NULL
                         AND     pol.from_header_id = ph1.po_header_id
                         AND     ph1.type_lookup_code = 'BLANKET'
                         AND     ph1.global_agreement_flag = 'Y'
                         AND     ph1.supply_agreement_flag = 'Y'
                         )
                 )	)
        -- Bug#18822988: Cummins GBPA Support : End
      AND    exists
		(select 1
	         from   rcv_transactions rct
	         where  rct.transaction_date between x_cum_period_start
				             and     x_cum_period_end
                 and    rct.shipment_line_id = rsl.shipment_line_id
	         and    rct.transaction_type = 'RECEIVE');


BEGIN

   -- RTV transactions are included in the CUM period that the
   -- receipt transactions are done in.  This means if the CUM period
   -- is closed that we performed the receipt transaction in,
   -- the RTV will be included in the closed CUM period.


   IF (x_rtv_transactions_included = 'N') THEN


      -- Open the cursor that gets all of the shipment lines that
      -- match the vendor, vendor site, org, item, in the cum period
      OPEN C3;

      -- For each of these shipment lines, get each of the rtvs
      -- against the shipment line.
      LOOP

      X_progress := '010';

      FETCH C3 INTO X_quantity_received,
		      X_unit_of_measure,
		      X_primary_unit_of_measure;

      EXIT WHEN C3%notfound;


      -- We need to convert the shipment line uom to the primary uom
      -- and the purchasing uom.


      X_progress := '020';

      SELECT uom_code
      INTO   X_transaction_uom_code
      FROM   mtl_units_of_measure
      WHERE  unit_of_measure = X_unit_of_measure;

      X_progress := '030';


      SELECT uom_code
      INTO   X_purchasing_uom_code
      FROM   mtl_units_of_measure
      WHERE  unit_of_measure = X_purchasing_unit_of_measure;


      X_progress := '040';

      SELECT uom_code
      INTO   X_primary_uom_code
      FROM   mtl_units_of_measure
      WHERE  unit_of_measure = X_primary_unit_of_measure;

      X_progress := '050';

      inv_convert.inv_um_conversion(X_transaction_uom_code,
				    X_primary_uom_code,
				    X_item_id, X_conversion_rate);

      X_qty_received_primary := X_conversion_rate * X_quantity_received;

      X_progress := '060';

      inv_convert.inv_um_conversion(X_primary_uom_code,
				    X_purchasing_uom_code,
				    X_item_id, X_uom_rate);

      X_qty_received_purchasing := X_uom_rate * X_qty_received_primary;


      X_tot_received_primary := nvl(X_tot_received_primary,0) +
				nvl(X_qty_received_primary,0);

      X_tot_received_purch := nvl(X_tot_received_purch,0) +
			      nvl(X_qty_received_purchasing,0);

      END LOOP;

      CLOSE C3;

      select sum(adjustment_quantity)
      into   x_adjustment_quantity
      from   chv_cum_adjustments cha,
             chv_cum_periods ccp
      where  cha.organization_id = X_organization_id
      and    cha.vendor_id = X_vendor_id
      and    cha.vendor_site_id = X_vendor_site_id
      and    cha.item_id = X_item_id
      and    cha.cum_period_id = ccp.cum_period_id
      and    ccp.cum_period_start_date = X_cum_period_start
      and    ccp.cum_period_end_date   = X_cum_period_end
      and    ccp.organization_id       = cha.organization_id;

      X_tot_received_purch := nvl(X_tot_received_purch,0) +
			           nvl(X_adjustment_quantity,0);

      -- This will happen if there are no rcv txn's, but an adjustment
      IF (X_primary_uom_code is null) THEN

        SELECT primary_uom_code
	INTO   X_primary_uom_code
        FROM   mtl_system_items
        WHERE  inventory_item_id = X_item_id
        AND    organization_id = X_organization_id;

        SELECT uom_code
        INTO   X_purchasing_uom_code
        FROM   mtl_units_of_measure
        WHERE  unit_of_measure = X_purchasing_unit_of_measure;

      END IF;

      inv_convert.inv_um_conversion(X_purchasing_uom_code,
				    X_primary_uom_code,
				    X_item_id, X_uom_rate);

      X_tot_received_primary := X_tot_received_purch * X_uom_rate;

      X_qty_received_purchasing := X_tot_received_purch;
      X_qty_received_primary := X_tot_received_primary;

      return(X_qty_received_purchasing);

   ELSE

      X_progress := '070';

      -- Open the cursor that gets all of the shipment lines that
      -- match the vendor, vendor site, org, item, in the cum period
      OPEN C;

      -- For each of these shipment lines, get each of the rtvs
      -- against the shipment line.
      LOOP

         X_progress := '080';

         FETCH C INTO X_quantity_received,
		      X_unit_of_measure,
		      X_primary_unit_of_measure,
		      X_transaction_id;

         EXIT WHEN C%notfound;

         -- Get the uom code since we only have the unit of measure.
	 -- We need to the uom code to execute uom_convert.
	 -- We CANNOT just get the primary quantity from rcv_transactions
         -- since it will not have the corrections to that quantity.
         -- The rcv_shipment line includes the quantity received +
         -- all corrects to that quantity.
         X_progress := '090';
         SELECT uom_code
         INTO   X_transaction_uom_code
         FROM   mtl_units_of_measure
         WHERE  unit_of_measure = X_unit_of_measure;

         X_progress := '100';
         SELECT uom_code
         INTO   X_primary_uom_code
         FROM   mtl_units_of_measure
         WHERE  unit_of_measure = X_primary_unit_of_measure;

         X_progress := '110';
         SELECT uom_code
         INTO   X_purchasing_uom_code
         FROM   mtl_units_of_measure
         WHERE  unit_of_measure = X_purchasing_unit_of_measure;


         X_progress := '120';
         inv_convert.inv_um_conversion(X_transaction_uom_code,
				    X_primary_uom_code,
				    X_item_id, X_conversion_rate);

         -- Calculate the qty received in the primary unit of measure.
         X_qty_received_primary := X_conversion_rate * X_quantity_received;

	 X_total_qty_received_primary := nvl(X_total_qty_received_primary,0) +
			nvl(X_qty_received_primary,0);

         X_progress := '130';

         -- Open the cursor to get the rtv's against the shipment line/
	 -- transaction we are working with.
	 OPEN C2;

	 -- For each rtv transaction get the corrections against it.
         LOOP

            X_progress := '140';

            FETCH C2 INTO X_rtv_primary_quantity,
			  X_rtv_transaction_id;

	    EXIT WHEN C2%notfound;

	    X_total_qty_received_primary := nvl(X_total_qty_received_primary,0)
			 - nvl(X_rtv_primary_quantity,0);

	    BEGIN

               X_progress := '150';

               SELECT sum(rct.primary_quantity)
               INTO   X_corrtv_primary_quantity
	       FROM   rcv_transactions rct
	       WHERE  rct.transaction_type = 'CORRECT'
	       AND    rct.parent_transaction_id = X_rtv_transaction_id;

	    EXCEPTION
	      WHEN NO_DATA_FOUND then null;
	      WHEN OTHERS then raise;

            END;

	    X_total_qty_received_primary := nvl(X_total_qty_received_primary,0)
		+ nvl(X_corrtv_primary_quantity,0);

         END LOOP;

         CLOSE C2;

      END LOOP;

      CLOSE C;


      X_qty_received_primary  := x_total_qty_received_primary;

      X_progress := '160';
      inv_convert.inv_um_conversion(X_primary_uom_code,
				    X_purchasing_uom_code,
				    X_item_id, X_conversion_rate);

      X_qty_received_purchasing :=
		round((x_qty_received_primary * X_conversion_rate), 5);


      select sum(adjustment_quantity)
      into   x_adjustment_quantity
      from   chv_cum_adjustments cha,
             chv_cum_periods ccp
      where  cha.organization_id = X_organization_id
      and    cha.vendor_id = X_vendor_id
      and    cha.vendor_site_id = X_vendor_site_id
      and    cha.item_id = X_item_id
      and    cha.cum_period_id = ccp.cum_period_id
      and    ccp.cum_period_start_date = X_cum_period_start
      and    ccp.cum_period_end_date   = X_cum_period_end
      and    ccp.organization_id       = cha.organization_id;

      X_qty_received_purchasing := nvl(X_qty_received_purchasing,0) +
			           nvl(X_adjustment_quantity,0);

      return(X_qty_received_purchasing);

   END IF;

   EXCEPTION
     WHEN OTHERS THEN
	return('');

END get_cum_received_purch;

function get_purchasing_uom_qty(x_primary_quantity in number,
				x_primary_unit_of_measure in varchar2,
				x_vendor_id in number,
				x_vendor_site_id in number,
				x_organization_id in number,
				x_item_id in number)
		 return number is

x_primary_uom_code varchar2(3);
x_purchasing_uom_code varchar2(3);
x_purchasing_unit_of_measure varchar2(25);
x_conversion_rate number;
x_purchasing_qty number;

begin

	SELECT paa.purchasing_unit_of_measure
	INTO   x_purchasing_unit_of_measure
        FROM    po_asl_attributes_val_v paa
        WHERE  paa.vendor_id = x_vendor_id
        AND    paa.vendor_site_id = x_vendor_site_id
        AND    paa.item_id = x_item_id
        AND    paa.using_organization_id =
			(SELECT max(paa2.using_organization_id)
			 FROM   po_asl_attributes_val_v paa2
			 WHERE  decode(paa2.using_organization_id, -1,
					x_organization_id,
				       paa2.using_organization_id) =
					x_organization_id
			 AND    paa2.vendor_id = x_vendor_id
			 AND    paa2.vendor_site_id = x_vendor_site_id
			 AND    paa2.item_id = x_item_id) ;

        SELECT uom_code
        INTO   x_primary_uom_code
        FROM   mtl_units_of_measure
        WHERE  unit_of_measure = X_primary_unit_of_measure;

	SELECT uom_code
        INTO   x_purchasing_uom_code
        FROM   mtl_units_of_measure
        WHERE  unit_of_measure = X_purchasing_unit_of_measure;

        inv_convert.inv_um_conversion(x_primary_uom_code,
				      x_purchasing_uom_code,
				      x_item_id, x_conversion_rate);

        x_purchasing_qty := x_primary_quantity * x_conversion_rate;

        return(x_purchasing_qty) ;

exception when others then

    return('') ;

end ;


END CHV_INQ_SV2;

/
