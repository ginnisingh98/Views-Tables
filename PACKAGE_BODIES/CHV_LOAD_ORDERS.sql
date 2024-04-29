--------------------------------------------------------
--  DDL for Package Body CHV_LOAD_ORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_LOAD_ORDERS" as
/* $Header: CHVPRLOB.pls 120.3.12010000.4 2014/02/12 04:55:23 adevadul ship $ */

/*=========================== CHV_LOAD_ORDERS ===============================*/
/*=============================================================================

  PROCEDURE NAME:     load_item_orders()

=============================================================================*/

PROCEDURE load_item_orders(x_organization_id             IN      NUMBER,
			   x_schedule_id                 IN      NUMBER,
                           x_schedule_item_id            IN      NUMBER,
			   x_vendor_id		         IN      NUMBER,
                           x_vendor_site_id	         IN      NUMBER,
			   x_item_id			 IN	 NUMBER,
			   x_purchasing_unit_of_measure  IN      VARCHAR2,
			   x_primary_unit_of_measure     IN      VARCHAR2,
			   x_conversion_rate             IN      NUMBER,
			   x_horizon_start_date          IN      DATE,
			   x_horizon_end_date	         IN      DATE,
			   x_include_future_rel_flag     IN      VARCHAR2,
			   x_schedule_type	         IN      VARCHAR2,
			   x_schedule_subtype            IN      VARCHAR2,
		           x_plan_designator	         IN      VARCHAR2) IS

X_progress VARCHAR2(3) := '';
X_only_past_due_flag VARCHAR2(1) := 'N' ;

BEGIN

    --dbms_output.put_line('Entering Load Item Orders');

    -- Evaluate schedule type PLANNING or SHIPPING
    IF x_schedule_type = 'PLAN_SCHEDULE' THEN

      --dbms_output.put_line('Load Item Orders: Planning Schedule'||x_schedule_subtype);

      -- If the Schedule type is PLANNING evaluate the schedule
      -- subtype.
      IF x_schedule_subtype = 'FORECAST_ONLY' THEN
         x_only_past_due_flag := 'Y' ;

-- DEBUG.
-- If releases are not being included for the schedule subtype,
-- we still need to get them for past due.
-- For load_approved_releases we need to add a only_past_due_flag.

  --dbms_output.put_line('Load Item Orders: Planning Schedule Forecast Only');

         -- If the schedule subtype is FORECAST ONLY then
         -- execute procedure to load all MRP/MPS/DRP planned orders
         chv_load_orders.load_planned_orders(x_organization_id,
				       x_schedule_id,
				       x_schedule_item_id,
				       x_vendor_id,
				       x_vendor_site_id,
				       x_item_id,
				       x_purchasing_unit_of_measure,
				       x_primary_unit_of_measure,
				       x_conversion_rate,
				       x_horizon_start_date,
				       x_horizon_end_date,
				       x_schedule_type,
				       x_schedule_subtype,
				       x_plan_designator) ;

 --dbms_output.put_line('Load App Reqs: Planning Schedule Forecast Only');
         chv_load_orders.load_approved_requisitions(x_organization_id,
					      x_schedule_id,
					      x_schedule_item_id,
					      x_vendor_id,
					      x_vendor_site_id,
					      x_item_id,
					      x_purchasing_unit_of_measure,
					      x_primary_unit_of_measure,
					      x_conversion_rate,
					      x_horizon_start_date,
					      x_horizon_end_date,
					      x_schedule_type,
					      x_schedule_subtype);

-- DEBUG. call load_approved_releases with only_past_due = 'Y'
 --dbms_output.put_line('Load App Reqs: Planning Schedule Forecast Only');
         chv_load_orders.load_approved_releases(x_organization_id,
					  x_schedule_id,
					  x_schedule_item_id,
					  x_vendor_id,
					  x_vendor_site_id,
					  x_item_id,
					  x_purchasing_unit_of_measure,
					  x_primary_unit_of_measure,
					  x_conversion_rate,
					  x_horizon_start_date,
					  x_horizon_end_date,
                                          x_only_past_due_flag,
					  x_include_future_rel_flag) ;
      ELSIF x_schedule_subtype = 'FORECAST_ALL_DOCUMENTS' THEN
            x_only_past_due_flag := 'N' ;

         --dbms_output.put_line('Load item Orders: Planning Sched - Forecast All Documents');

         -- If the schedule subtype is FORECAST ALL DOCUMENTS then
         -- execute procedure to load all MRP/MPS/DRP planned orders
         -- approved requisitions and approved releases as forecast.
                 chv_load_orders.load_planned_orders(x_organization_id,
				       x_schedule_id,
				       x_schedule_item_id,
				       x_vendor_id,
				       x_vendor_site_id,
				       x_item_id,
				       x_purchasing_unit_of_measure,
				       x_primary_unit_of_measure,
				       x_conversion_rate,
				       x_horizon_start_date,
				       x_horizon_end_date,
				       x_schedule_type,
				       x_schedule_subtype,
				       x_plan_designator) ;

         chv_load_orders.load_approved_requisitions(x_organization_id,
					      x_schedule_id,
					      x_schedule_item_id,
					      x_vendor_id,
					      x_vendor_site_id,
					      x_item_id,
					      x_purchasing_unit_of_measure,
					      x_primary_unit_of_measure,
					      x_conversion_rate,
					      x_horizon_start_date,
					      x_horizon_end_date,
					      x_schedule_type,
					      x_schedule_subtype);

         chv_load_orders.load_approved_releases(x_organization_id,
					  x_schedule_id,
					  x_schedule_item_id,
					  x_vendor_id,
					  x_vendor_site_id,
					  x_item_id,
					  x_purchasing_unit_of_measure,
					  x_primary_unit_of_measure,
					  x_conversion_rate,
					  x_horizon_start_date,
					  x_horizon_end_date,
                                          x_only_past_due_flag,
					  x_include_future_rel_flag) ;

      ELSIF x_schedule_subtype = 'MATERIAL_RELEASE' THEN
            x_only_past_due_flag := 'N' ;

         --dbms_output.put_line('Planning Schedule Material Release');

         -- If the schedule subtype is MATERIAL RELEASE   then
         -- execute procedure to load all MRP/MPS/DRP as planned orders
         -- approved requisitions as approved releases planned orders
         -- approved requisitions as approved releases
         chv_load_orders.load_planned_orders(x_organization_id,
				               x_schedule_id,
				               x_schedule_item_id,
				               x_vendor_id,
				               x_vendor_site_id,
				               x_item_id,
				               x_purchasing_unit_of_measure,
					       x_primary_unit_of_measure,
					       x_conversion_rate,
				               x_horizon_start_date,
				               x_horizon_end_date,
					       x_schedule_type,
					       x_schedule_subtype,
					       x_plan_designator) ;

         chv_load_orders.load_approved_requisitions(x_organization_id,
					      x_schedule_id,
					      x_schedule_item_id,
					      x_vendor_id,
					      x_vendor_site_id,
					      x_item_id,
					      x_purchasing_unit_of_measure,
					      x_primary_unit_of_measure,
					      x_conversion_rate,
					      x_horizon_start_date,
					      x_horizon_end_date,
					      x_schedule_type,
					      x_schedule_subtype) ;

         chv_load_orders.load_approved_releases(x_organization_id,
					  x_schedule_id,
					  x_schedule_item_id,
					  x_vendor_id,
					  x_vendor_site_id,
					  x_item_id,
					  x_purchasing_unit_of_measure,
					  x_primary_unit_of_measure,
					  x_conversion_rate,
					  x_horizon_start_date,
					  x_horizon_end_date,
                                          x_only_past_due_flag,
					  x_include_future_rel_flag) ;
       END IF ;

     ELSIF x_schedule_type = 'SHIP_SCHEDULE' THEN

       -- IF schedule type is SHIP SCHEDULE evaluate the
       -- schedule subtype.
       IF x_schedule_subtype = 'RELEASE_ONLY' THEN
          x_only_past_due_flag := 'N' ;

         --dbms_output.put_line('Ship Sched - Release Only');

         -- If schedule subtype is RELEASE ONLY then
         -- execute procedure to load all approved releases.
         chv_load_orders.load_approved_releases(x_organization_id,
					  x_schedule_id,
					  x_schedule_item_id,
					  x_vendor_id,
					  x_vendor_site_id,
					  x_item_id,
					  x_purchasing_unit_of_measure,
					  x_primary_unit_of_measure,
				          x_conversion_rate,
					  x_horizon_start_date,
					  x_horizon_end_date,
					  x_only_past_due_flag,
					  x_include_future_rel_flag) ;

       ELSIF x_schedule_subtype = 'RELEASE_WITH_FORECAST' THEN
             x_only_past_due_flag := 'N' ;

	 --dbms_output.put_line('Ship Sched - Release where/ Frecast');
         -- If schedule subtype is RELEASE WITH FORECAST then
         -- execute procedure to load all MRP/MPS/DRP as planned orders
         -- approved requisitions as approved releases planned orders
         -- and approved requisitions as approved releases

         chv_load_orders.load_planned_orders(x_organization_id,
				       x_schedule_id,
				       x_schedule_item_id,
				       x_vendor_id,
				       x_vendor_site_id,
				       x_item_id,
				       x_purchasing_unit_of_measure,
				       x_primary_unit_of_measure,
				       x_conversion_rate,
				       x_horizon_start_date,
			               x_horizon_end_date,
				       x_schedule_type,
				       x_schedule_subtype,
				       x_plan_designator) ;

         chv_load_orders.load_approved_requisitions(x_organization_id,
					      x_schedule_id,
					      x_schedule_item_id,
					      x_vendor_id,
					      x_vendor_site_id,
					      x_item_id,
					      x_purchasing_unit_of_measure,
					      x_primary_unit_of_measure,
					      x_conversion_rate,
					      x_horizon_start_date,
					      x_horizon_end_date,
					      x_schedule_type,
					      x_schedule_subtype) ;

         chv_load_orders.load_approved_releases(x_organization_id,
					  x_schedule_id,
					  x_schedule_item_id,
					  x_vendor_id,
					  x_vendor_site_id,
					  x_item_id,
					  x_purchasing_unit_of_measure,
					  x_primary_unit_of_measure,
					  x_conversion_rate,
					  x_horizon_start_date,
					  x_horizon_end_date,
					  x_only_past_due_flag,
					  x_include_future_rel_flag) ;

       END IF ;

     END IF ;

EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('load_item_orders', X_progress, sqlcode);
      raise;

END load_item_orders ;

/*=============================================================================

  PROCEDURE NAME:     load_planned_orders()

=============================================================================*/
PROCEDURE load_planned_orders(x_organization_id             IN      NUMBER,
		              x_schedule_id                 IN      NUMBER,
                              x_schedule_item_id            IN      NUMBER,
			      x_vendor_id		    IN      NUMBER,
                              x_vendor_site_id	            IN      NUMBER,
			      x_item_id			    IN	    NUMBER,
			      x_purchasing_unit_of_measure  IN      VARCHAR2,
			      x_primary_unit_of_measure     IN      VARCHAR2,
			      x_conversion_rate             IN      NUMBER,
			      x_horizon_start_date          IN      DATE,
			      x_horizon_end_date	    IN      DATE,
			      x_schedule_type	            IN      VARCHAR2,
			      x_schedule_subtype            IN      VARCHAR2,
		              x_plan_designator	            IN      VARCHAR2) IS

 /* Declaring Program Variables */
  X_need_by_date            DATE;
  X_login_id                NUMBER;
  X_last_updated_by         NUMBER;
  X_progress VARCHAR2(3) := '';
  X_ord_qty NUMBER;
  X_new_dock_date DATE;
  X_transaction_id NUMBER;

 -- The new quantity represents the planned orders.  The Quantity in Process
 -- represents planned orders that have been implemented from the workbench.
 -- Quantity in mrp_recommendations is always represented in primary uom.
 -- This coresponds to recrods in the requisition interface table waiting
 -- for req import to process them.  From the email I sent earlier this
 -- week: In order to get the unimplemented quantity of planned orders you
 -- should use:  NVL(firm_quantity, new_order_quantity) -
 -- 			quantity_in_process - implemented_quantity.

/* Bug 1140926 fixed . Forward port of the bug 1133892.
                       Due date for the planned order should first look at
                       the firm_date and then at the new_dock_date. So changing
                       the select to nvl(firm_date, new_dock_date) and also
                       the where cond. to nvl(firm_date, new_dock_date)
                       between x_horizon_start_date  and x_horizon_end_date
*/

 CURSOR C1 is select transaction_id,
		     nvl(firm_date,new_dock_date),
		     NVL(firm_quantity, new_order_quantity) -
                      (NVL(quantity_in_process,0) + nvl(implemented_quantity,0) )
              from   mrp_recommendations mrp
	      where  mrp.organization_id       =   x_organization_id
	      and    mrp.source_vendor_id      =   x_vendor_id
              and    x_vendor_site_id =
                                    (select distinct pvs.vendor_site_id
                                     from   po_vendor_sites_all pvsa,
                                            po_vendor_sites pvs
                                     where  pvsa.vendor_site_id   = mrp.source_vendor_site_id and
                                            pvsa.vendor_id        = x_vendor_id and
                                            pvs.vendor_site_code  = pvsa.vendor_site_code and
                                            pvs.vendor_id         = x_vendor_id)
	      and    mrp.inventory_item_id     =   x_item_id
	      and    mrp.transaction_id        =   mrp.disposition_id
              and    mrp.order_type            =   5
              and    mrp.compile_designator    =   x_plan_designator
              and    mrp.disposition_id       =   mrp.transaction_id
	      and    nvl(mrp.firm_date,mrp.new_dock_date) between
			                  x_horizon_start_date  and
		 	                  x_horizon_end_date  ;
BEGIN

   X_login_id        := fnd_global.login_id;
   X_last_updated_by := fnd_global.user_id;

   X_progress := '030';

   OPEN C1;

   LOOP
        --dbms_output.put_line('SCH ID:'||TO_CHAR(X_SCHEDULE_ID)) ;
        --dbms_output.put_line('ITEM:'||TO_CHAR(x_schedule_item_id)) ;
        --dbms_output.put_line('VENDOR ID:'||TO_CHAR(X_VENDOR_ID)) ;
        --dbms_output.put_line('VENDOR SITE:'||TO_CHAR(X_VENDOR_SITE_ID)) ;
        --dbms_output.put_line('ITEM:'||TO_CHAR(X_ITEM_ID)) ;
        --dbms_output.put_line('PUOM:'||x_purchasing_unit_of_measure) ;
        --dbms_output.put_line('PRI UOM:'||x_primary_unit_of_measure) ;
        --dbms_output.put_line('CONV RATE:'||x_conversion_rate) ;
        --dbms_output.put_line('PURCH QTY:'||TO_CHAR(nvl(x_ord_qty * x_conversion_rate,0))) ;
        --dbms_output.put_line('PRI QTY:'||TO_CHAR(nvl(x_ord_qty,0))) ;
        --dbms_output.put_line('DOCK DATE:'||TO_CHAR(x_new_dock_date,'DD-MON-YYYY')) ;
        --dbms_output.put_line('START DATE:'||TO_CHAR(X_HORIZON_START_DATE,'DD-MON-YYYY')) ;
        --dbms_output.put_line('END DATE:'||TO_CHAR(X_HORIZON_END_DATE,'DD-MON-YYYY')) ;
        --dbms_output.put_line('PLAN NAME:'||x_plan_designator) ;


        --dbms_output.put_line('before fetch');

        X_progress := '040';

        FETCH C1 INTO X_transaction_id,
		      X_new_dock_date,
		      X_ord_qty;

        EXIT WHEN C1%notfound ;

	X_progress := '050';
        insert into chv_item_orders(schedule_id,
			            schedule_item_id,
				    schedule_order_id,
				    supply_document_type,
                                    order_quantity,
				    order_quantity_primary,
				    purchasing_unit_of_measure,
				    primary_unit_of_measure,
				    due_date,
				    last_update_date,
				    last_updated_by,
				    creation_date,
				    created_by,
				    last_update_login)
                             values(x_schedule_id,
			            x_schedule_item_id,
			            CHV_ITEM_ORDERS_S.nextval,
			            'PLANNED_ORDER',
				    nvl(x_ord_qty * x_conversion_rate,0),
 				    nvl(x_ord_qty,0),
			            x_purchasing_unit_of_measure,
				    x_primary_unit_of_measure,
			            x_new_dock_date,
			            sysdate,
			            X_last_updated_by,
			            sysdate,
			            X_last_updated_by,
				    X_login_id) ;

     end loop ;

EXCEPTION
  WHEN NO_DATA_FOUND THEN null;
  WHEN OTHERS THEN
    CLOSE C1;
    po_message_s.sql_error('load_planned_orders', X_progress, sqlcode);
    RAISE;


END load_planned_orders  ;

/*=============================================================================

  PROCEDURE NAME:     load_approved_requisitions()

=============================================================================*/

PROCEDURE load_approved_requisitions(x_organization_id      IN     NUMBER,
			      x_schedule_id                 IN     NUMBER,
                              x_schedule_item_id            IN     NUMBER,
			      x_vendor_id		    IN     NUMBER,
                              x_vendor_site_id	            IN     NUMBER,
			      x_item_id			    IN	   NUMBER,
			      x_purchasing_unit_of_measure  IN     VARCHAR2,
			      x_primary_unit_of_measure     IN     VARCHAR2,
			      x_conversion_rate             IN     NUMBER,
			      x_horizon_start_date          IN     DATE,
			      x_horizon_end_date	    IN     DATE,
			      x_schedule_type	            IN     VARCHAR2,
			      x_schedule_subtype            IN     VARCHAR2) IS

  X_requisition_header_id   NUMBER;
  X_requisition_line_id	    NUMBER;
  X_to_org_primary_quantity NUMBER;
  X_to_org_purch_quantity   NUMBER;
  X_need_by_date            DATE;
  X_login_id                NUMBER;
  X_last_updated_by         NUMBER;
  X_progress                VARCHAR2(3) := '';

  cursor C1 is select prh.requisition_header_id,
		      prl.requisition_line_id,
		      ms.to_org_primary_quantity,
		      prl.need_by_date
	       from   po_requisition_headers prh,
		      po_requisition_lines prl,
		      mtl_supply ms,
		      po_vendors pov,
		      po_vendor_sites pvs
               where  ms.to_organization_id    = x_organization_id
	       and    ms.supply_type_code       = 'REQ'
	       and    ms.req_header_id          = prh.requisition_header_id
	       and    ms.req_line_id            = prl.requisition_line_id
               and    ms.quantity              <> 0
	       and    prl.suggested_vendor_name
						= pov.vendor_name
               and    pov.vendor_id             = x_vendor_id
               and    prl.suggested_vendor_location
						= pvs.vendor_site_code
	       and    pvs.vendor_site_id        = x_vendor_site_id
               and    prl.item_id	        = x_item_id
               and    prl.source_type_code      = 'VENDOR'
	       and    prl.need_by_date
				       between x_horizon_start_date and
		 		               x_horizon_end_date ;

BEGIN

   --dbms_output.put_line('Get Approved Reqs: Calling');
   --dbms_output.put_line('Get Approved Reqs: Vendor Id'||x_vendor_id);
   --dbms_output.put_line('Get Approved Reqs: Vendor Site'||x_vendor_site_id);
   --dbms_output.put_line('Get Approved Reqs: Item'||x_item_id);
   --dbms_output.put_line('Get Approved Reqs: Start date'||x_horizon_start_date);
   --dbms_output.put_line('Get Approved Reqs: End date'||x_horizon_end_date);

   X_login_id        := fnd_global.login_id;
   X_last_updated_by := fnd_global.user_id;

   X_progress := '030';

   OPEN C1;

   LOOP

      --dbms_output.put_line('Get Approved Reqs: Before fetch');

      X_progress := '040';

      FETCH C1 INTO
		      X_requisition_header_id,
                      X_requisition_line_id,
                      X_to_org_primary_quantity,
                      X_need_by_date;

      EXIT WHEN C1%notfound;

      -- Calculate the purchasing quantity based on conversion rate
      -- from primary to purchasing that was passed in.

      -- DEBUG.  Pri A. verify that mtl_supply stores primary unit of measure
      -- rather than primary unit of measure code.  The table has
      -- length of 25.

      -- DEBUG.  Pri C. Why do we need a cursor her.  He should be able to do
      -- insert as a select from.  Need to test using sequences.

      X_to_org_purch_quantity := X_conversion_rate * X_to_org_primary_quantity;

      X_progress := '050';

      --dbms_output.put_line('Get Approved Reqs: Before insert');

      insert into chv_item_orders(schedule_id,
			            schedule_item_id,
			            schedule_order_id,
			            supply_document_type,
			            order_quantity,
				    order_quantity_primary,
			            purchasing_unit_of_measure,
				    primary_unit_of_measure,
			            due_date,
			            document_header_id,
			            last_update_date,
			            last_updated_by,
			            creation_date,
			            created_by,
				    last_update_login,
			            document_line_id,
			            document_shipment_id)
                             values(x_schedule_id,
			            x_schedule_item_id,
			            CHV_ITEM_ORDERS_S.nextval,
			            'REQUISITION',
			            nvl(X_to_org_purch_quantity,
					X_to_org_primary_quantity),
                                    X_to_org_primary_quantity,
			            X_purchasing_unit_of_measure,
				    X_primary_unit_of_measure,
		                    X_need_by_date,
			            X_requisition_header_id,
			            sysdate,
			            X_last_updated_by,
			            sysdate,
			            X_last_updated_by,
				    X_login_id,
			            X_requisition_line_id,
			            null);

   END LOOP ;

   CLOSE C1;

EXCEPTION
  WHEN NO_DATA_FOUND THEN null;
  WHEN OTHERS THEN
    CLOSE C1;
    po_message_s.sql_error('load_approved_reqs', X_progress, sqlcode);
    RAISE;

END load_approved_requisitions  ;

/*=============================================================================

  PROCEDURE NAME:     load_approved_releases()

=============================================================================*/

-- DEBUG. add only_past_due_flag

PROCEDURE load_approved_releases(x_organization_id          IN      NUMBER,
			      x_schedule_id                 IN      NUMBER,
                              x_schedule_item_id            IN      NUMBER,
			      x_vendor_id		    IN      NUMBER,
                              x_vendor_site_id	            IN      NUMBER,
			      x_item_id			    IN	    NUMBER,
			      x_purchasing_unit_of_measure  IN      VARCHAR2,
			      x_primary_unit_of_measure     IN      VARCHAR2,
			      x_conversion_rate             IN      NUMBER,
			      x_horizon_start_date          IN      DATE,
			      x_horizon_end_date	    IN      DATE,
			      x_only_past_due_flag          IN      VARCHAR2,
			      x_include_future_rel_flag     IN      VARCHAR2) IS

  /* Declaring Program Variables */
  X_po_header_id   NUMBER;
  X_po_line_id     NUMBER;
  X_line_location_id NUMBER;
  X_to_org_primary_quantity NUMBER;
  X_to_org_primary_uom      VARCHAR2(25);
  X_need_by_date            DATE;
  X_login_id                NUMBER;
  X_last_updated_by         NUMBER;
  X_progress VARCHAR2(3) := '';

-- DEBUG.  logic
-- FORECAST_ALL_DOCUMENTS will always have include future releases = 'N'
--   If only_past_due_flag = 'Y' and include future releases = 'N'
--	need_by_date < horizon_end_date + 1.
--
-- MATERIAL_RELEASE,RELEASE_ONLY,RELEASE_WITH_FORECAST WITHOUT FUTURE RELEASES
--   If only_past_due_flag = 'N' and include future releases = 'N'
--      need_by_date > horizon_end_date
--
-- MATERIAL_RELEASE,RELEASE_ONLY,RELEASE_WITH_FORECAST WITH FUTURE RELEASES
-- If only_past_due_flag = 'N' and include future releases = 'Y'
--   Ignore needby date we need to load all open releases.

  -- Document due date is determined by the promised date on the release.
  -- If the promised date is not available for this document type, it
  -- is determined by the the need by date.

  /* Bug - 993145 - Added the need_by_date is NOT NULL condition in the
 ** WHERE clause to avoid loading the NON Planned items. */

/* Bug 1769274 Added +0 to the poh.vendor_id to diable the index on vendor and
   vendor site. This will use better indexes on the PO_HEADERS and MTL_SUPPLY
   tables and hence will improve the performance.
*/
/* Bug 4618577 fixed. Added format mask to to_date function */
/* Bug 5075549 fixed. Removed the to_date function to date columns */

/* bug5065917 : included supply_type_code of SHIPMENT to account for ASN's */
/* Bug 18222204 : Adding SPOs backed by GBPA with Supply Agreement Flag as Y */
CURSOR C1 IS SELECT ms.po_header_id,
  ms.po_line_id,
  ms.po_line_location_id,
  ms.to_org_primary_quantity,
  ms.to_org_primary_uom,
  ms.need_by_date
FROM po_headers poh,
  mtl_supply ms
WHERE ms.to_organization_id   = x_organization_id
AND ms.supply_type_code      IN ('PO','SHIPMENT')
AND ms.po_header_id           = poh.po_header_id
AND ms.item_id                = x_item_id
AND ms.quantity              <> 0
AND ( (poh.type_lookup_code   = 'BLANKET'
AND poh.supply_agreement_flag = 'Y')
OR (poh.type_lookup_code      = 'STANDARD'
AND EXISTS
  (SELECT 1
  FROM PO_LINES PL,
    PO_HEADERS PH1
  WHERE PL.PO_LINE_ID           = MS.PO_LINE_ID
  AND PL.FROM_HEADER_ID        IS NOT NULL
  AND PL.FROM_HEADER_ID         = PH1.PO_HEADER_ID
  AND PH1.TYPE_LOOKUP_CODE      = 'BLANKET'
  AND PH1.GLOBAL_AGREEMENT_FLAG = 'Y'
  AND PH1.SUPPLY_AGREEMENT_FLAG = 'Y'
  ) ) )
AND poh.vendor_id +0                     = x_vendor_id
AND poh.vendor_site_id                   = x_vendor_site_id
AND ((NVL(x_include_future_rel_flag,'N') = 'N'
AND x_only_past_due_flag                 = 'Y'
AND ms.need_by_date                      < x_horizon_start_date + 1)
OR (NVL(x_include_future_rel_flag,'N')   = 'N'
AND x_only_past_due_flag                 = 'N'
AND ms.need_by_date                      < x_horizon_end_date + 1)
OR (x_include_future_rel_flag            = 'Y'
AND x_only_past_due_flag                 = 'N'
AND ms.need_by_date                     IS NOT NULL) );

/* DEBUG.  Pri C, Perform We do not need a cursor in this case to loop through
	all of the records.  We could of done a straight insert
	as select from.  We should modify in the future to improve
	performance */

BEGIN

   X_login_id        := fnd_global.login_id;
   X_last_updated_by := fnd_global.user_id;

   X_progress := '020';

   OPEN C1;

   LOOP

      --dbms_output.put_line('before fetch');

      X_progress := '030';

      FETCH C1 INTO   X_po_header_id,
		      X_po_line_id,
		      X_line_location_id,
		      X_to_org_primary_quantity,
	              X_to_org_primary_uom,
		      X_need_by_date;
      EXIT WHEN C1%notfound;

      X_progress := '040';

      insert into chv_item_orders(schedule_id,
			            schedule_item_id,
			            schedule_order_id,
			            supply_document_type,
                                    order_quantity,
				    order_quantity_primary,
			            purchasing_unit_of_measure,
			            primary_unit_of_measure,
			            due_date,
			            document_header_id,
			            last_update_date,
			            last_updated_by,
			            creation_date,
			            created_by,
				    last_update_login,
			            document_line_id,
			            document_shipment_id)
                             values(x_schedule_id,
			            x_schedule_item_id,
			            CHV_ITEM_ORDERS_S.nextval,
			            'RELEASE',
			            x_conversion_rate *
                                      X_to_org_primary_quantity,
				    X_to_org_primary_quantity,
			            x_purchasing_unit_of_measure,
			            X_to_org_primary_uom,
			            X_need_by_date,
			            X_po_header_id,
			            sysdate,
			            X_last_updated_by,
			            sysdate,
			            X_last_updated_by,
				    X_login_id,
                                    X_po_line_id,
                                    X_line_location_id) ;
    END LOOP;

    X_progress := '050';

    CLOSE C1;

EXCEPTION
  WHEN NO_DATA_FOUND THEN null;
  WHEN OTHERS THEN
    CLOSE C1;
    po_message_s.sql_error('load_approved_releases', X_progress, sqlcode);
    RAISE;


END load_approved_releases;

END CHV_LOAD_ORDERS ;

/
