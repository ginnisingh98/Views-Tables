--------------------------------------------------------
--  DDL for Package Body INV_RCV_TXN_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_TXN_INTERFACE" AS
/* $Header: INVTISVB.pls 120.7.12010000.11 2010/04/07 10:21:51 jianxzhu ship $*/

 x_interface_type                       varchar2(25) := 'RCV-856';
 x_dummy_flag                           varchar2(1)  := 'Y';

 g_pkg_name CONSTANT VARCHAR2(30) := 'INV_RCV_TXN_INTERFACE';

PROCEDURE print_debug(p_err_msg VARCHAR2,
		      p_level NUMBER DEFAULT 4)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg,
      p_module => g_pkg_name,
      p_level => p_level);
   END IF;

--   dbms_output.put_line(p_err_msg);
END print_debug;


PROCEDURE matching_logic
  (
   x_return_status         OUT nocopy VARCHAR2
   ,x_msg_count            OUT nocopy NUMBER
   ,x_msg_data             OUT nocopy VARCHAR2
   ,x_cascaded_table    IN OUT NOCOPY INV_RCV_COMMON_APIS.cascaded_trans_tab_type
   ,n                   IN OUT nocopy BINARY_INTEGER
   ,temp_cascaded_table IN OUT nocopy INV_RCV_COMMON_APIS.cascaded_trans_tab_type
   ,p_receipt_num          IN         VARCHAR2
   ,p_shipment_header_id   IN         NUMBER
   ,p_lpn_id               IN         NUMBER)
  IS

     l_allow_routing_override VARCHAR2(1);

     CURSOR asn_shipments
       (
	v_item_id   		  NUMBER
	, v_po_line_id            NUMBER
	, v_po_line_location_id   NUMBER
	, v_po_release_id         NUMBER
	, v_ship_to_org_id        NUMBER
	, v_ship_to_location_id   NUMBER
	, v_shipment_header_id    NUMBER
	, v_lpn_id                NUMBER
	, v_item_desc             VARCHAR2
	, v_project_id 		  NUMBER
	, v_task_id		  NUMBER
	, v_inspection_status_code  VARCHAR2
	, v_organization_id		NUMBER)
       IS
	  SELECT
	    pll.line_location_id
	    , pll.unit_meas_lookup_code
	    , Nvl(pll.promised_date,pll.need_by_date)	promised_date
	    , pll.quantity_shipped
	    , pll.receipt_days_exception_code
	    , pll.qty_rcv_exception_code
	    , pll.days_early_receipt_allowed
	    , pll.days_late_receipt_allowed
	    , 0          					po_distribution_id
	    , pll.ship_to_location_id
	    , Nvl(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code
	    , 0 rcv_transaction_id -- only need it for std_deliver
	    , pl.item_revision --only needed for std_deliver
	    FROM
	    po_line_locations_trx_v	pll, -- CLM project, bug 9403291
	    po_lines_trx_v		pl, -- CLM project, bug 9403291
            -- Bug 3444226 The Join with po_headers is unnecessary
	    -- po_headers          ph,
	    rcv_shipment_lines  rsl,
	    (SELECT DISTINCT source_line_id
	     FROM wms_lpn_contents
	     WHERE parent_lpn_id = v_lpn_id) wlc
	    WHERE pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
	    AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
	    AND Nvl(pll.po_release_id,0)          = Nvl(v_po_release_id,Nvl(pll.po_release_id,0))
	    AND pll.po_line_id                    = pl.po_line_id
	    -- change for non item master receipts.
	    --AND pl.item_id      	          = v_item_id
	    and (   pl.item_id                    = v_item_id
		 OR (    v_item_id IS NULL
		     AND pl.item_id IS NULL
		     AND pl.item_description = v_item_desc))
	    AND NVL(pll.APPROVED_FLAG,'N')        = 'Y'
	    AND NVL(pll.CANCEL_FLAG, 'N')         = 'N'
	    AND NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	    AND pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
	    AND pll.ship_to_organization_id       = Nvl(v_ship_to_org_id,pll.ship_to_organization_id)
	    AND pll.ship_to_location_id           = Nvl(v_ship_to_location_id,pll.ship_to_location_id)
	    AND rsl.shipment_header_id            = v_shipment_header_id
	    AND rsl.po_line_location_id           = pll.line_location_id
	    AND pll.po_line_id                    = wlc.source_line_id (+)
            AND Nvl(pll.receiving_routing_id,1)   = Decode(l_allow_routing_override,
							   'Y',
							   Nvl(pll.receiving_routing_id,1),
   							   Decode(v_inspection_status_code,
								  'Y',
								  2,
								  1)
							   )
            AND pll.line_location_id in
             ( select pod.line_location_id from po_distributions_trx_v pod -- CLM project, bug 9403291
		         where (v_project_id is null or
			 	         (v_project_id = -9999 and pod.project_id is null) or --Bug# 2669021
                      pod.project_id = v_project_id
                     )
				  and (v_task_id is null or pod.task_id = v_task_id)
              and  pod.po_header_id = pll.po_header_id
	       )
	    ORDER BY Nvl(pll.promised_date,pll.need_by_date);


     CURSOR count_asn_shipments
       (
	v_item_id   		  NUMBER
	, v_po_line_id            NUMBER
	, v_po_line_location_id   NUMBER
	, v_po_release_id         NUMBER
	, v_ship_to_org_id        NUMBER
	, v_ship_to_location_id   NUMBER
	, v_shipment_header_id    NUMBER
	, v_lpn_id                NUMBER
	, v_item_desc             VARCHAR2
	, v_project_id 		  NUMBER
	, v_task_id		  NUMBER
	, v_inspection_status_code VARCHAR2
	, v_organization_id		NUMBER)
       IS
	  SELECT COUNT(*)
	    FROM
	    po_line_locations_trx_v 	pll, -- CLM project, bug 9403291
	    po_lines_trx_v		pl, -- CLM project, bug 9403291
            -- Bug 3444226 The Join with po_headers is unnecessary
	    -- po_headers          ph,
	    rcv_shipment_lines  rsl,
	    (SELECT DISTINCT source_line_id
	     FROM wms_lpn_contents
	     WHERE parent_lpn_id = v_lpn_id) wlc
	    WHERE pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
	    AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
	    AND Nvl(pll.po_release_id,0)          = Nvl(v_po_release_id,Nvl(pll.po_release_id,0))
	    AND pll.po_line_id                    = pl.po_line_id
	    -- change for non item master receipts.
	    --AND pl.item_id      	          = v_item_id
	    and (   pl.item_id                    = v_item_id
		 OR (    v_item_id IS NULL
		     AND pl.item_id IS NULL
		     AND pl.item_description = v_item_desc))
	    AND NVL(pll.APPROVED_FLAG,'N')        = 'Y'
	    AND NVL(pll.CANCEL_FLAG, 'N')         = 'N'
	    AND NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	    AND pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
	    AND pll.ship_to_organization_id       = Nvl(v_ship_to_org_id,pll.ship_to_organization_id)
	    AND pll.ship_to_location_id           = Nvl(v_ship_to_location_id,pll.ship_to_location_id)
	    AND rsl.shipment_header_id            = v_shipment_header_id
	    AND rsl.po_line_location_id           = pll.line_location_id
	    AND pll.po_line_id                    = wlc.source_line_id (+)
            AND Nvl(pll.receiving_routing_id,1)   = Decode(l_allow_routing_override,
							   'Y',
							   Nvl(pll.receiving_routing_id,1),
   							   Decode(v_inspection_status_code,
								  'Y',
								  2,
								  1)
							   )
	    AND pll.line_location_id in
                ( select pod.line_location_id
                  from po_distributions_trx_v pod -- CLM project, bug 9403291
		            where ( v_project_id is null or
		       	          (v_project_id = -9999 and pod.project_id is null) or --Bug# 2669021
                         pod.project_id = v_project_id
                        )
		       	  and (v_task_id is null or pod.task_id = v_task_id)
                 and   pod.po_header_id = pll.po_header_id
                );

     CURSOR asn_shipments_w_po
       (
	  header_id 	 	  NUMBER
	, v_item_id   		  NUMBER
	, v_po_line_id            NUMBER
	, v_po_line_location_id   NUMBER
	, v_po_release_id         NUMBER
	, v_ship_to_org_id        NUMBER
	, v_ship_to_location_id   NUMBER
	, v_shipment_header_id    NUMBER
	, v_lpn_id                NUMBER
	, v_item_desc             VARCHAR2
	, v_project_id 		  NUMBER
	, v_task_id		  NUMBER
	, v_inspection_status_code VARCHAR2
	, v_organization_id		NUMBER)
       IS
	  SELECT
	    pll.line_location_id
	    , pll.unit_meas_lookup_code
	    , Nvl(pll.promised_date,pll.need_by_date)	promised_date
	    , pll.quantity_shipped
	    , pll.receipt_days_exception_code
	    , pll.qty_rcv_exception_code
	    , pll.days_early_receipt_allowed
	    , pll.days_late_receipt_allowed
	    , 0          					po_distribution_id
	    , pll.ship_to_location_id
	    , Nvl(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code
	    , 0 rcv_transaction_id -- only need it for std_deliver
	    , pl.item_revision --only needed for std_deliver
	    FROM
	    po_line_locations_trx_v	pll, -- CLM project, bug 9403291
	    po_lines_trx_v		pl, -- CLM project, bug 9403291
            -- Bug 3444226 The Join with po_headers is unnecessary
	    -- po_headers          ph,
	    rcv_shipment_lines  rsl,
	    (SELECT DISTINCT source_line_id
	     FROM wms_lpn_contents
	     WHERE parent_lpn_id = v_lpn_id) wlc
            -- Bug 3444226 The condition with po_headers is unnecessary
	    -- WHERE ph.po_header_id 	          = header_id
	    WHERE pll.po_header_id 	          = header_id
	    AND pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
	    AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
	    AND Nvl(pll.po_release_id,0)          = Nvl(v_po_release_id,Nvl(pll.po_release_id,0))
	    AND pll.po_line_id                    = pl.po_line_id
	    -- change for non item master receipts.
	    --AND pl.item_id      	          = v_item_id
	    and (   pl.item_id                    = v_item_id
		 OR (    v_item_id IS NULL
		     AND pl.item_id IS NULL
		     AND pl.item_description = v_item_desc))
	    AND NVL(pll.APPROVED_FLAG,'N')        = 'Y'
	    AND NVL(pll.CANCEL_FLAG, 'N')         = 'N'
	    AND NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	    AND pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
	    AND pll.ship_to_organization_id       = Nvl(v_ship_to_org_id,pll.ship_to_organization_id)
	    AND pll.ship_to_location_id           = Nvl(v_ship_to_location_id,pll.ship_to_location_id)
	    AND rsl.shipment_header_id            = v_shipment_header_id
	    AND rsl.po_line_location_id           = pll.line_location_id
	    AND pll.po_line_id                    = wlc.source_line_id (+)
            AND Nvl(pll.receiving_routing_id,1)   = Decode(l_allow_routing_override,
							   'Y',
							   Nvl(pll.receiving_routing_id,1),
   							   Decode(v_inspection_status_code,
								  'Y',
								  2,
								  1)
							   )
	    AND pll.line_location_id in
                ( select pod.line_location_id
                  from po_distributions_trx_v pod -- CLM project, bug 9403291
		            where ( v_project_id is null or
		       	          (v_project_id = -9999 and pod.project_id is null) or --Bug# 2669021
                         pod.project_id = v_project_id
                        )
		       	  and (v_task_id is null or pod.task_id = v_task_id)
                 and   pod.po_header_id = pll.po_header_id
                )
	    ORDER BY Nvl(pll.promised_date,pll.need_by_date);


     CURSOR count_asn_shipments_w_po
       (
	  header_id 	 	  NUMBER
	, v_item_id   		  NUMBER
	, v_po_line_id            NUMBER
	, v_po_line_location_id   NUMBER
	, v_po_release_id         NUMBER
	, v_ship_to_org_id        NUMBER
	, v_ship_to_location_id   NUMBER
	, v_shipment_header_id    NUMBER
	, v_lpn_id                NUMBER
	, v_item_desc             VARCHAR2
	, v_project_id 		  NUMBER
	, v_task_id		  NUMBER
	, v_inspection_status_code VARCHAR2
	, v_organization_id		NUMBER)
       IS
	  SELECT COUNT(*)
	    FROM
	    po_line_locations_trx_v	pll, -- CLM project, bug 9403291
	    po_lines_trx_v		pl, -- CLM project, bug 9403291
            -- Bug 3444226 The Join with po_headers is unnecessary
	    -- po_headers          ph,
	    rcv_shipment_lines  rsl,
	    (SELECT DISTINCT source_line_id
	     FROM wms_lpn_contents
	     WHERE parent_lpn_id = v_lpn_id) wlc
            -- Bug 3444226 The Join with po_headers is unnecessary
	    -- WHERE ph.po_header_id 	          = header_id
	    WHERE pll.po_header_id 	          = header_id
	    AND pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
	    AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
	    AND Nvl(pll.po_release_id,0)          = Nvl(v_po_release_id,Nvl(pll.po_release_id,0))
	    AND pll.po_line_id                    = pl.po_line_id
	    -- change for non item master receipts.
	    --AND pl.item_id      	          = v_item_id
	    and (   pl.item_id                    = v_item_id
		 OR (    v_item_id IS NULL
		     AND pl.item_id IS NULL
		     AND pl.item_description = v_item_desc))
	    AND NVL(pll.APPROVED_FLAG,'N')        = 'Y'
	    AND NVL(pll.CANCEL_FLAG, 'N')         = 'N'
	    AND NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	    AND pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
	    AND pll.ship_to_organization_id       = Nvl(v_ship_to_org_id,pll.ship_to_organization_id)
	    AND pll.ship_to_location_id           = Nvl(v_ship_to_location_id,pll.ship_to_location_id)
	    AND rsl.shipment_header_id            = v_shipment_header_id
	    AND rsl.po_line_location_id           = pll.line_location_id
	    AND pll.po_line_id                    = wlc.source_line_id (+)
            AND Nvl(pll.receiving_routing_id,1)   = Decode(l_allow_routing_override,
							   'Y',
							   Nvl(pll.receiving_routing_id,1),
   							   Decode(v_inspection_status_code,
								  'Y',
								  2,
								  1)
							   )
	    AND pll.line_location_id in
                ( select pod.line_location_id
                  from po_distributions_trx_v pod -- CLM projrect, bug 9403291
		            where ( v_project_id is null or
		       	          (v_project_id = -9999 and pod.project_id is null) or --Bug# 2669021
                         pod.project_id = v_project_id
                        )
		       	  and (v_task_id is null or pod.task_id = v_task_id)
                 and   pod.po_header_id = pll.po_header_id
                ) ;

-- For Bug 7440217 Added the following cursors

     CURSOR lcm_shipments
       (
	v_item_id   			NUMBER
	, v_po_line_id			NUMBER
	, v_po_line_location_id		NUMBER
	, v_po_release_id		NUMBER
	, v_ship_to_org_id		NUMBER
	, v_ship_to_location_id		NUMBER
	, v_shipment_header_id		NUMBER
	, v_lpn_id			NUMBER
	, v_item_desc			VARCHAR2
	, v_project_id 			NUMBER
	, v_task_id			NUMBER
	, v_inspection_status_code	VARCHAR2
	, v_organization_id		NUMBER)
       IS
	  SELECT
	    pll.line_location_id
	    , pll.unit_meas_lookup_code
	    , Nvl(pll.promised_date,pll.need_by_date)	promised_date
	    , pll.quantity_shipped
	    , pll.receipt_days_exception_code
	    , pll.qty_rcv_exception_code
	    , pll.days_early_receipt_allowed
	    , pll.days_late_receipt_allowed
	    , 0          					po_distribution_id
	    , pll.ship_to_location_id
	    , Nvl(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code
	    , 0 rcv_transaction_id -- only need it for std_deliver
	    , pl.item_revision --only needed for std_deliver
	    FROM
	    po_line_locations_trx_v	pll, -- CLM project, bug 9403291
	    po_lines_trx_v		pl, -- CLM project, bug 9403291
            -- Bug 3444226 The Join with po_headers is unnecessary
	    -- po_headers          ph,
	    rcv_shipment_lines  rsl,
	    (SELECT DISTINCT source_line_id
	     FROM wms_lpn_contents
	     WHERE parent_lpn_id = v_lpn_id) wlc
	    WHERE pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
	    AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
	    AND Nvl(pll.po_release_id,0)          = Nvl(v_po_release_id,Nvl(pll.po_release_id,0))
	    AND pll.po_line_id                    = pl.po_line_id
	    -- change for non item master receipts.
	    --AND pl.item_id      	          = v_item_id
	    and (   pl.item_id                    = v_item_id
		 OR (    v_item_id IS NULL
		     AND pl.item_id IS NULL
		     AND pl.item_description = v_item_desc))
	    AND NVL(pll.APPROVED_FLAG,'N')        = 'Y'
	    AND NVL(pll.CANCEL_FLAG, 'N')         = 'N'
	    AND NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	    AND pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
	    AND pll.ship_to_organization_id       = Nvl(v_ship_to_org_id,pll.ship_to_organization_id)
	    AND pll.ship_to_location_id           = Nvl(v_ship_to_location_id,pll.ship_to_location_id)
	    AND rsl.shipment_header_id            = v_shipment_header_id
	    AND rsl.po_line_location_id           = pll.line_location_id
	    AND pll.po_line_id                    = wlc.source_line_id (+)
            AND Nvl(pll.receiving_routing_id,1)   = Decode(l_allow_routing_override,
							   'Y',
							   Nvl(pll.receiving_routing_id,1),
   							   Decode(v_inspection_status_code,
								  'Y',
								  2,
								  1)
							   )
            AND pll.line_location_id in
             ( select pod.line_location_id from po_distributions_trx_v pod  -- CLM project, bug 9403291
		         where (v_project_id is null or
			 	         (v_project_id = -9999 and pod.project_id is null) or --Bug# 2669021
                      pod.project_id = v_project_id
                     )
				  and (v_task_id is null or pod.task_id = v_task_id)
              and  pod.po_header_id = pll.po_header_id
	       )
	    ORDER BY Nvl(pll.promised_date,pll.need_by_date);


     CURSOR count_lcm_shipments
       (
	v_item_id   			NUMBER
	, v_po_line_id			NUMBER
	, v_po_line_location_id		NUMBER
	, v_po_release_id		NUMBER
	, v_ship_to_org_id		NUMBER
	, v_ship_to_location_id		NUMBER
	, v_shipment_header_id		NUMBER
	, v_lpn_id			NUMBER
	, v_item_desc			VARCHAR2
	, v_project_id 			NUMBER
	, v_task_id			NUMBER
	, v_inspection_status_code	VARCHAR2
	, v_organization_id		NUMBER)
       IS
	  SELECT COUNT(*)
	    FROM
	    po_line_locations_trx_v	pll, -- CLM project, bug 9403291
	    po_lines_trx_v		pl, -- CLM project, bug 9403291
            -- Bug 3444226 The Join with po_headers is unnecessary
	    -- po_headers          ph,
	    rcv_shipment_lines  rsl,
	    (SELECT DISTINCT source_line_id
	     FROM wms_lpn_contents
	     WHERE parent_lpn_id = v_lpn_id) wlc
	    WHERE pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
	    AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
	    AND Nvl(pll.po_release_id,0)          = Nvl(v_po_release_id,Nvl(pll.po_release_id,0))
	    AND pll.po_line_id                    = pl.po_line_id
	    -- change for non item master receipts.
	    --AND pl.item_id      	          = v_item_id
	    and (   pl.item_id                    = v_item_id
		 OR (    v_item_id IS NULL
		     AND pl.item_id IS NULL
		     AND pl.item_description = v_item_desc))
	    AND NVL(pll.APPROVED_FLAG,'N')        = 'Y'
	    AND NVL(pll.CANCEL_FLAG, 'N')         = 'N'
	    AND NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	    AND pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
	    AND pll.ship_to_organization_id       = Nvl(v_ship_to_org_id,pll.ship_to_organization_id)
	    AND pll.ship_to_location_id           = Nvl(v_ship_to_location_id,pll.ship_to_location_id)
	    AND rsl.shipment_header_id            = v_shipment_header_id
	    AND rsl.po_line_location_id           = pll.line_location_id
	    AND pll.po_line_id                    = wlc.source_line_id (+)
            AND Nvl(pll.receiving_routing_id,1)   = Decode(l_allow_routing_override,
							   'Y',
							   Nvl(pll.receiving_routing_id,1),
   							   Decode(v_inspection_status_code,
								  'Y',
								  2,
								  1)
							   )
	    AND pll.line_location_id in
                ( select pod.line_location_id
                  from po_distributions_trx_v pod -- CLM project, bug 9403291
		            where ( v_project_id is null or
		       	          (v_project_id = -9999 and pod.project_id is null) or --Bug# 2669021
                         pod.project_id = v_project_id
                        )
		       	  and (v_task_id is null or pod.task_id = v_task_id)
                 and   pod.po_header_id = pll.po_header_id
                );

     CURSOR lcm_shipments_w_po
       (
	  header_id 	 		NUMBER
	, v_item_id   			NUMBER
	, v_po_line_id			NUMBER
	, v_po_line_location_id		NUMBER
	, v_po_release_id		NUMBER
	, v_ship_to_org_id		NUMBER
	, v_ship_to_location_id		NUMBER
	, v_shipment_header_id		NUMBER
	, v_lpn_id			NUMBER
	, v_item_desc			VARCHAR2
	, v_project_id 			NUMBER
	, v_task_id			NUMBER
	, v_inspection_status_code	VARCHAR2
	, v_organization_id		NUMBER)
       IS
	  SELECT
	    pll.line_location_id
	    , pll.unit_meas_lookup_code
	    , Nvl(pll.promised_date,pll.need_by_date)	promised_date
	    , pll.quantity_shipped
	    , pll.receipt_days_exception_code
	    , pll.qty_rcv_exception_code
	    , pll.days_early_receipt_allowed
	    , pll.days_late_receipt_allowed
	    , 0          					po_distribution_id
	    , pll.ship_to_location_id
	    , Nvl(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code
	    , 0 rcv_transaction_id -- only need it for std_deliver
	    , pl.item_revision --only needed for std_deliver
	    FROM
	    po_line_locations_trx_v	pll, -- CLM project, bug 9403291
	    po_lines_trx_v		pl, -- CLM project, bug 9403291
            -- Bug 3444226 The Join with po_headers is unnecessary
	    -- po_headers          ph,
	    rcv_shipment_lines  rsl,
	    (SELECT DISTINCT source_line_id
	     FROM wms_lpn_contents
	     WHERE parent_lpn_id = v_lpn_id) wlc
            -- Bug 3444226 The condition with po_headers is unnecessary
	    -- WHERE ph.po_header_id 	          = header_id
	    WHERE pll.po_header_id 	          = header_id
	    AND pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
	    AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
	    AND Nvl(pll.po_release_id,0)          = Nvl(v_po_release_id,Nvl(pll.po_release_id,0))
	    AND pll.po_line_id                    = pl.po_line_id
	    -- change for non item master receipts.
	    --AND pl.item_id      	          = v_item_id
	    and (   pl.item_id                    = v_item_id
		 OR (    v_item_id IS NULL
		     AND pl.item_id IS NULL
		     AND pl.item_description = v_item_desc))
	    AND NVL(pll.APPROVED_FLAG,'N')        = 'Y'
	    AND NVL(pll.CANCEL_FLAG, 'N')         = 'N'
	    AND NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	    AND pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
	    AND pll.ship_to_organization_id       = Nvl(v_ship_to_org_id,pll.ship_to_organization_id)
	    AND pll.ship_to_location_id           = Nvl(v_ship_to_location_id,pll.ship_to_location_id)
	    AND rsl.shipment_header_id            = v_shipment_header_id
	    AND rsl.po_line_location_id           = pll.line_location_id
	    AND pll.po_line_id                    = wlc.source_line_id (+)
            AND Nvl(pll.receiving_routing_id,1)   = Decode(l_allow_routing_override,
							   'Y',
							   Nvl(pll.receiving_routing_id,1),
   							   Decode(v_inspection_status_code,
								  'Y',
								  2,
								  1)
							   )
	    AND pll.line_location_id in
                ( select pod.line_location_id
                  from po_distributions_trx_v pod -- CLM project, bug 9403291
		            where ( v_project_id is null or
		       	          (v_project_id = -9999 and pod.project_id is null) or --Bug# 2669021
                         pod.project_id = v_project_id
                        )
		       	  and (v_task_id is null or pod.task_id = v_task_id)
                 and   pod.po_header_id = pll.po_header_id
                )
	    ORDER BY Nvl(pll.promised_date,pll.need_by_date);


     CURSOR count_lcm_shipments_w_po
       (
	  header_id 	 		NUMBER
	, v_item_id   			NUMBER
	, v_po_line_id			NUMBER
	, v_po_line_location_id		NUMBER
	, v_po_release_id		NUMBER
	, v_ship_to_org_id		NUMBER
	, v_ship_to_location_id		NUMBER
	, v_shipment_header_id		NUMBER
	, v_lpn_id			NUMBER
	, v_item_desc			VARCHAR2
	, v_project_id 			NUMBER
	, v_task_id			NUMBER
	, v_inspection_status_code	VARCHAR2
	, v_organization_id		NUMBER)
       IS
	  SELECT COUNT(*)
	    FROM
	    po_line_locations_trx_v	pll, -- CLM project, bug 9403291
	    po_lines_trx_v		pl, -- CLM project, bug 9403291
            -- Bug 3444226 The Join with po_headers is unnecessary
	    -- po_headers          ph,
	    rcv_shipment_lines  rsl,
	    (SELECT DISTINCT source_line_id
	     FROM wms_lpn_contents
	     WHERE parent_lpn_id = v_lpn_id) wlc
            -- Bug 3444226 The Join with po_headers is unnecessary
	    -- WHERE ph.po_header_id 	          = header_id
	    WHERE pll.po_header_id 	          = header_id
	    AND pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
	    AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
	    AND Nvl(pll.po_release_id,0)          = Nvl(v_po_release_id,Nvl(pll.po_release_id,0))
	    AND pll.po_line_id                    = pl.po_line_id
	    -- change for non item master receipts.
	    --AND pl.item_id      	          = v_item_id
	    and (   pl.item_id                    = v_item_id
		 OR (    v_item_id IS NULL
		     AND pl.item_id IS NULL
		     AND pl.item_description = v_item_desc))
	    AND NVL(pll.APPROVED_FLAG,'N')        = 'Y'
	    AND NVL(pll.CANCEL_FLAG, 'N')         = 'N'
	    AND NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	    AND pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
	    AND pll.ship_to_organization_id       = Nvl(v_ship_to_org_id,pll.ship_to_organization_id)
	    AND pll.ship_to_location_id           = Nvl(v_ship_to_location_id,pll.ship_to_location_id)
	    AND rsl.shipment_header_id            = v_shipment_header_id
	    AND rsl.po_line_location_id           = pll.line_location_id
	    AND pll.po_line_id                    = wlc.source_line_id (+)
            AND Nvl(pll.receiving_routing_id,1)   = Decode(l_allow_routing_override,
							   'Y',
							   Nvl(pll.receiving_routing_id,1),
   							   Decode(v_inspection_status_code,
								  'Y',
								  2,
								  1)
							   )
	    AND pll.line_location_id in
                ( select pod.line_location_id
                  from po_distributions_trx_v pod -- CLM project, bug 9403291
		            where ( v_project_id is null or
		       	          (v_project_id = -9999 and pod.project_id is null) or --Bug# 2669021
                         pod.project_id = v_project_id
                        )
		       	  and (v_task_id is null or pod.task_id = v_task_id)
                 and   pod.po_header_id = pll.po_header_id
                ) ;
-- End for Bug 7440217


     cursor shipments
       (
	  header_id 	 	 NUMBER
	, v_item_id   		 NUMBER
        , v_revision             VARCHAR2
	, v_po_line_id           NUMBER
	, v_po_line_location_id  NUMBER
	, v_po_release_id        NUMBER
	, v_ship_to_org_id       NUMBER
	, v_ship_to_location_id  NUMBER
	, v_item_desc            VARCHAR2
	, v_project_id 		  NUMBER
	, v_task_id		  NUMBER
	, v_inspection_status_code VARCHAR2
	, v_organization_id		NUMBER)
       is
	  select
	    pll.line_location_id
	    , pll.unit_meas_lookup_code
	    , nvl(pll.promised_date,pll.need_by_date)	promised_date
	    , pll.quantity_shipped
	    , pll.receipt_days_exception_code
	    , pll.qty_rcv_exception_code
	    , pll.days_early_receipt_allowed
	    , pll.days_late_receipt_allowed
	    , 0          					po_distribution_id
	    , pll.ship_to_location_id
	    , nvl(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code
	    , 0 rcv_transaction_id -- only need it for std_deliver
	    , pl.item_revision --only needed for std_deliver
	    from  	po_line_locations_trx_v	pll, -- CLM project, bug 9403291
	    po_lines_trx_v		pl -- CLM project, bug 9403291
-- For Bug 7440217
      , mtl_parameters mp,
        rcv_parameters rp
-- End for Bug 7440217
            -- Bug 3444226 The Join with po_headers is unnecessary
	    -- po_headers_all          	ph
	    -- where ph.po_header_id 		  = header_id
	    where pll.po_header_id 	          = header_id
-- For Bug 7440217
          AND mp.organization_id = v_organization_id
          AND rp.organization_id = v_organization_id
          AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                    OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                        OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
              )
-- End for Bug 7440217
	    AND pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
	    AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
	    and nvl(pll.po_release_id,0)          = nvl(v_po_release_id,nvl(pll.po_release_id,0))
	    and pll.po_line_id   	          = pl.po_line_id
	    -- change for non item master receipts.
	    and (   pl.item_id                    = v_item_id
		 OR (    v_item_id IS NULL
		     AND pl.item_id IS NULL
		     AND pl.item_description = v_item_desc))
	    AND ((v_revision IS NOT NULL
                  AND Nvl(pl.item_revision, v_revision) = v_revision)
                 OR (v_revision IS NULL))
	    and NVL(pll.APPROVED_FLAG,'N')        = 'Y'
	    and NVL(pll.CANCEL_FLAG, 'N')         = 'N'
	    and NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	    and pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
	    and pll.ship_to_organization_id       = nvl(v_ship_to_org_id,pll.ship_to_organization_id)
	    and pll.ship_to_location_id           = nvl(v_ship_to_location_id,pll.ship_to_location_id)
            AND Nvl(pll.receiving_routing_id,1)   = Decode(l_allow_routing_override,
							   'Y',
							   Nvl(pll.receiving_routing_id,1),
   							   Decode(v_inspection_status_code,
								  'Y',
								  2,
								  1)
							   )
	    AND pll.line_location_id in
                ( select pod.line_location_id
                  from po_distributions_trx_v pod -- CLM project, bug 9403291
                  where (v_project_id is null
                         or ((v_project_id = -9999 and pod.project_id is null)--Bug# 2669021
                             or (nvl(pod.project_id,-99) = v_project_id )))
                  and   (v_task_id is null or nvl(pod.task_id,-9999) = v_task_id)
                  and   pod.po_header_id = pll.po_header_id
                 )
	    order by pl.item_revision, nvl(pll.promised_date,pll.need_by_date);


     CURSOR count_shipments
       (  header_id 	 	  NUMBER
	, v_item_id   		  NUMBER
        , v_revision              VARCHAR2
	, v_po_line_id            NUMBER
	, v_po_line_location_id   NUMBER
	, v_po_release_id         NUMBER
	, v_ship_to_org_id        NUMBER
	, v_ship_to_location_id   NUMBER
	, v_item_desc            VARCHAR2
	, v_project_id 		  NUMBER
        , v_task_id		  NUMBER
	, v_inspection_status_code VARCHAR2
	, v_organization_id		NUMBER)

       IS
	  SELECT COUNT(*)
	    from  po_line_locations_trx_v	pll, -- CLM project, bug 9403291
	          po_lines_trx_v			pl -- CLM project, bug 9403291
-- For Bug 7440217
            , mtl_parameters mp,
              rcv_parameters rp
-- End for Bug 7440217
	    WHERE pll.po_header_id 	          = header_id
-- For Bug 7440217
          AND mp.organization_id = v_organization_id
          AND rp.organization_id = v_organization_id
          AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                   OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                       OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
               )
-- End for Bug 7440217
	    AND pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
	    AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
	    and nvl(pll.po_release_id,0)          = nvl(v_po_release_id,nvl(pll.po_release_id,0))
	    and pll.po_line_id   	          = pl.po_line_id
	    -- change for non item master receipts.
	    and (   pl.item_id                    = v_item_id
		 OR (    v_item_id IS NULL
		     AND pl.item_id IS NULL
		     AND pl.item_description = v_item_desc))
	    -- and pl.item_id                        = v_item_id
	    AND ((v_revision IS NOT NULL
                  AND Nvl(pl.item_revision, v_revision) = v_revision)
                 OR (v_revision IS NULL))
	    and NVL(pll.APPROVED_FLAG,'N')        = 'Y'
	    and NVL(pll.CANCEL_FLAG, 'N')         = 'N'
	    and NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	    and pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
	    and pll.ship_to_organization_id       = nvl(v_ship_to_org_id,pll.ship_to_organization_id)
	    and pll.ship_to_location_id           = nvl(v_ship_to_location_id,pll.ship_to_location_id)
            AND Nvl(pll.receiving_routing_id,1)   = Decode(l_allow_routing_override,
							   'Y',
							   Nvl(pll.receiving_routing_id,1),
   							   Decode(v_inspection_status_code,
								  'Y',
								  2,
								  1)
							   )
	    AND pll.line_location_id in
                ( select pod.line_location_id
                  from po_distributions_trx_v pod -- CLM project, bug 9403291
                  where (v_project_id is null
                         or ((v_project_id = -9999 and pod.project_id is null)--Bug# 2669021
                             or (nvl(pod.project_id,-99) = v_project_id )))
                  and   (v_task_id is null or nvl(pod.task_id,-9999) = v_task_id)
                  and   pod.po_header_id = pll.po_header_id
                 );

 cursor distributions (
  header_id             number
 ,v_item_id             number
 ,v_revision            VARCHAR2
 ,v_po_line_id          NUMBER
 ,v_po_line_location_id NUMBER
 ,v_po_distribution_id  NUMBER
 ,v_po_release_id       number
 ,v_ship_to_org_id      number
 ,v_ship_to_location_id NUMBER
 ,v_item_desc           VARCHAR2
 , v_project_id		  NUMBER
 , v_task_id		  NUMBER
, v_organization_id		NUMBER) is
 select
  pll.line_location_id
 ,pll.unit_meas_lookup_code
 ,nvl(pll.promised_date,pll.need_by_date)	promised_date
 ,pll.quantity_shipped
 ,pll.receipt_days_exception_code
 ,pll.qty_rcv_exception_code
 ,pll.days_early_receipt_allowed
 ,pll.days_late_receipt_allowed
 ,pod.po_distribution_id
 ,pll.ship_to_location_id
 ,nvl(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code
 ,0 rcv_transaction_id -- only need it for std_deliver
 ,pl.item_revision --only needed for std_deliver
 from  po_distributions_trx_v    pod, -- CLM project, bug 9403291
       po_line_locations_trx_v   pll, -- CLM project, bug 9403291
       po_lines_trx_v		   pl, -- CLM project, bug 9403291
       po_headers_trx_v          ph -- CLM project, bug 9403291
 where ph.po_header_id 		       = header_id
 and pod.po_header_id   	       = header_id
 AND pod.po_line_id                    = Nvl(v_po_line_id, pod.po_line_id)
 AND pod.line_location_id              = Nvl(v_po_line_location_id, pod.line_location_id)
 AND pod.po_distribution_id            = Nvl(v_po_distribution_id, pod.po_distribution_id)
 and ph.po_header_id 		       = pl.po_header_id
 and nvl(pll.po_release_id,0) 	       = nvl(v_po_release_id,nvl(pll.po_release_id,0))
 and pll.po_line_id   		       = pl.po_line_id
 --and pl.item_id       	               = v_item_id
 -- change for non item master receipts.
 and (   pl.item_id                    = v_item_id
      OR (  v_item_id IS NULL
	       AND pl.item_id IS NULL
	       AND pl.item_description = v_item_desc))
 AND ((v_revision IS NOT NULL
       AND Nvl(pl.item_revision, v_revision) = v_revision)
      OR (v_revision IS NULL))
 and NVL(pll.APPROVED_FLAG,'N')        = 'Y'
 and NVL(pll.CANCEL_FLAG, 'N')         = 'N'
 and NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
 and pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
 and pll.line_location_id 	       = pod.line_location_id
 and pll.ship_to_organization_id       = nvl(v_ship_to_org_id,pll.ship_to_organization_id)
 and pll.ship_to_location_id           = nvl(v_ship_to_location_id,pll.ship_to_location_id)
 AND Nvl(pll.receiving_routing_id,1)   = Decode(l_allow_routing_override,
						'Y',
						Nvl(pll.receiving_routing_id,1),
						3)
 and (v_project_id is null or
       ( v_project_id = -9999 and pod.project_id is null ) or --Bug# 2669021
         pod.project_id = v_project_id)
 and (v_task_id is null or pod.task_id = v_task_id)
 order by pl.item_revision, nvl(pll.promised_date,pll.need_by_date);

 cursor count_distributions (
   header_id 			number
 , v_item_id 			number
 , v_revision                   VARCHAR2
 , v_po_line_id                 NUMBER
 , v_po_line_location_id        NUMBER
 , v_po_distribution_id         NUMBER
 , v_po_release_id 		number
 , v_ship_to_org_id 		number
 , v_ship_to_location_id 	number
 , v_item_desc                  VARCHAR2
 , v_project_id 		NUMBER
 , v_task_id		  	NUMBER
, v_organization_id		NUMBER) is
 select count(*)
 from po_distributions_trx_v 	pod, -- CLM project, bug 9403291
      po_line_locations_trx_v	pll, -- CLM project, bug 9403291
      po_lines_trx_v		pl -- CLM project, bug 9403291
 where pll.po_header_id 	       = header_id
 AND pod.po_line_id                    = Nvl(v_po_line_id, pod.po_line_id)
 AND pod.line_location_id              = Nvl(v_po_line_location_id, pod.line_location_id)
 AND pod.po_distribution_id            = Nvl(v_po_distribution_id, pod.po_distribution_id)
 and nvl(pll.po_release_id,0) 	       = nvl(v_po_release_id,nvl(pll.po_release_id,0))
 and pll.po_line_id   		       = pl.po_line_id
 --and pl.item_id       	               = v_item_id
 -- change for non item master receipts.
 and (   pl.item_id                    = v_item_id
      OR (  v_item_id IS NULL
	       AND pl.item_id IS NULL
	       AND pl.item_description = v_item_desc))
 AND ((v_revision IS NOT NULL
       AND Nvl(pl.item_revision, v_revision) = v_revision)
      OR (v_revision IS NULL))
 and NVL(pll.APPROVED_FLAG,'N')        = 'Y'
 and NVL(pll.CANCEL_FLAG, 'N')         = 'N'
 and NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
 and pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
 and pll.line_location_id 	       = pod.line_location_id
 and pll.ship_to_organization_id       = nvl(v_ship_to_org_id,pll.ship_to_organization_id)
 and pll.ship_to_location_id           = nvl(v_ship_to_location_id,pll.ship_to_location_id)
 AND Nvl(pll.receiving_routing_id,1)   = Decode(l_allow_routing_override,
						'Y',
						Nvl(pll.receiving_routing_id,1),
						3)
 and (v_project_id is null or
       ( v_project_id = -9999 and pod.project_id is null ) or --Bug# 2669021
         pod.project_id = v_project_id)
 and (v_task_id is null or pod.task_id = v_task_id) ;

 ----
 /* FP-J Lot/Serial Support Enhancement
  * Added two new arguments to the cursor, v_lot_number and v_lpn_id_to_match
  * Added conditions to match the lot number with that in RCV_LOTS_SUPPLY
  * and the LPN with that in RCV_SUPPLY for the parent trasnaction
  * This would be done only if WMS and PO patchset levels are J or higher
  */
 CURSOR std_distributions (
   header_id             NUMBER
  ,v_item_id             NUMBER
  ,v_revision            VARCHAR2
  ,v_po_line_id          NUMBER
  ,v_po_line_location_id NUMBER
  ,v_po_distribution_id  NUMBER
  ,v_po_release_id       NUMBER
  ,v_ship_to_org_id      NUMBER
  ,v_ship_to_location_id NUMBER
  ,v_receipt_num         VARCHAR2
  ,v_txn_date            DATE
  ,v_inspection_status   VARCHAR2
  ,v_lpn_id              NUMBER
  ,v_lot_number          VARCHAR2
  ,v_lpn_id_to_match     NUMBER
  ,v_parent_txn_id_to_match NUMBER
, v_organization_id		NUMBER) IS
 SELECT
  pll.line_location_id
 ,pll.unit_meas_lookup_code
 ,nvl(pll.promised_date,pll.need_by_date)	promised_date
 ,0 --pll.quantity_shipped
 ,pll.receipt_days_exception_code
 ,pll.qty_rcv_exception_code
 ,pll.days_early_receipt_allowed
 ,pll.days_late_receipt_allowed
 ,pod.po_distribution_id
 ,pll.ship_to_location_id
 ,nvl(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code
 ,rs.rcv_transaction_id
 ,rs.item_revision
 from  po_distributions_trx_v     pod, -- CLM project, bug 9403291
       po_line_locations_trx_v    pll, -- CLM project, bug 9403291
       po_lines_trx_v		    pl, -- CLM project, bug 9403291
       -- Bug 3444226 The Join with po_headers is unnecessary
       -- po_headers           ph,
       rcv_supply           rs,
       rcv_shipment_headers rsh,
--       rcv_shipment_lines   rsl,
       rcv_transactions     rt
 where rsh.receipt_source_code         = 'VENDOR'
 -- Bug 3444226 The Join with po_headers is unnecessary
 -- AND ph.po_header_id 		       = header_id
 AND pod.po_line_id                    = Nvl(v_po_line_id, pod.po_line_id)
 AND pod.line_location_id              = Nvl(v_po_line_location_id, pod.line_location_id)
 AND pod.po_distribution_id            = Nvl(v_po_distribution_id, pod.po_distribution_id)
 and pl.po_line_id                     = rs.po_line_id
 and pll.line_location_id              = rs.po_line_location_id
 and pod.line_location_id              = rs.po_line_location_id
-- and pl.item_id          	       = v_item_id
 and NVL(pll.APPROVED_FLAG,'N')        = 'Y'
 and NVL(pll.CANCEL_FLAG, 'N')         = 'N'
 and NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED')
 and pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
 and pll.ship_to_organization_id       = nvl(v_ship_to_org_id,pll.ship_to_organization_id)
 and pll.ship_to_location_id           = nvl(v_ship_to_location_id,pll.ship_to_location_id)
 AND RT.TRANSACTION_TYPE               <> 'UNORDERED'
 -- for all the transactions in rt for which we can putaway, the
 -- transfer_lpn_id should match the lpn being putaway.
 --AND Nvl(rt.transfer_lpn_id,-1)        = Nvl(v_lpn_id,-1)
 -- Fix for 1865886. Commented the above and added the following for lpn
 AND Nvl(v_lpn_id,-1) IN (select nvl(rt2.transfer_lpn_id,-1)
			    from rcv_transactions rt2
			   where rt2.transaction_type <> 'DELIVER'
			   start with rt2.transaction_id = rs.supply_source_id
			 connect by prior rt2.transaction_id = rt2.parent_transaction_id
			union all
			  select nvl(rt2.lpn_id,-1)
			    from rcv_transactions rt2
			   where rt2.transaction_type not in ('RECEIVE', 'DELIVER')
			   start with rt2.transaction_id = rs.supply_source_id
			 connect by prior rt2.transaction_id = rt2.parent_transaction_id
			  )
  --
 and rs.supply_type_code               = 'RECEIVING'
 --and rsl.shipment_line_id   = rs.shipment_line_id
 and rsh.shipment_header_id            = rs.shipment_header_id
 AND (Nvl(rsh.receipt_num,'@@@'))      = Nvl(v_receipt_num,Nvl(rsh.receipt_num,'@@@'))
 and rt.transaction_id                 = rs.rcv_transaction_id
 AND rt.transaction_date               < Nvl(v_txn_date,(rt.transaction_date + 1))
 --and rt.transaction_type <> 'UNORDERED'
 --
 and rs.po_header_id = header_id
 and rs.item_id      = v_item_id
 AND ((v_revision IS NOT NULL
       AND Nvl(rs.item_revision, v_revision) = v_revision)
      OR (v_revision IS NULL))
 AND (rt.routing_header_id IS NULL OR
      rt.routing_header_id <> 2 OR
      (rt.routing_header_id = 2
       AND rt.inspection_status_code <> 'NOT INSPECTED'
       AND rt.inspection_status_code = Nvl(v_inspection_status,rt.inspection_status_code)))
 AND  (
       v_lot_number IS NULL OR EXISTS
        (
          SELECT lot_num
          FROM   rcv_lots_supply rls
          WHERE  rls.transaction_id = rs.supply_source_id
          AND    rls.lot_num = v_lot_number
        )
      )
 AND  (
       v_parent_txn_id_to_match IS NULL
       OR v_parent_txn_id_to_match = rs.supply_source_id
       )
 AND  (
        v_lpn_id_to_match IS NULL
        OR (rs.lpn_id = v_lpn_id_to_match)
     )
 --
 order by rs.item_revision, nvl(pll.promised_date,pll.need_by_date);

 CURSOR count_std_distributions (
    header_id             NUMBER
  , v_item_id             NUMBER
  , v_revision            VARCHAR2
  , v_po_line_id          NUMBER
  , v_po_line_location_id NUMBER
  , v_po_distribution_id  NUMBER
  , v_po_release_id       NUMBER
  , v_ship_to_org_id      NUMBER
  , v_ship_to_location_id NUMBER
  , v_receipt_num         VARCHAR2
  , v_txn_date            DATE
  , v_inspection_status   VARCHAR2
  , v_lpn_id              NUMBER
  , v_lot_number          VARCHAR2
  , v_lpn_id_to_match     NUMBER
  ,v_parent_txn_id_to_match NUMBER
, v_organization_id		NUMBER) IS
SELECT count(*)
FROM  po_distributions_trx_v     pod, -- CLM project, bug 9403291
       po_line_locations_trx_v    pll, -- CLM project, bug 9403291
       po_lines_trx_v		    pl, -- CLM project, bug 9403291
       -- Bug 3444226 The Join with po_headers is unnecessary
       -- po_headers           ph,
       rcv_supply           rs,
       rcv_shipment_headers rsh,
--       rcv_shipment_lines   rsl,
       rcv_transactions     rt
 where rsh.receipt_source_code         = 'VENDOR'
 -- Bug 3444226 The Join with po_headers is unnecessary
 -- AND ph.po_header_id 		       = header_id
 AND pod.po_line_id                    = Nvl(v_po_line_id, pod.po_line_id)
 AND pod.line_location_id              = Nvl(v_po_line_location_id, pod.line_location_id)
 AND pod.po_distribution_id            = Nvl(v_po_distribution_id, pod.po_distribution_id)
 and pl.po_line_id                     = rs.po_line_id
 and pll.line_location_id              = rs.po_line_location_id
 and pod.line_location_id              = rs.po_line_location_id
-- and NVL(pl.item_id,0)       	       = nvl(v_item_id,nvl(pl.item_id,0))
 and NVL(pll.APPROVED_FLAG,'N')        = 'Y'
 and NVL(pll.CANCEL_FLAG, 'N')         = 'N'
 and NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED')
 and pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
 and pll.ship_to_organization_id       = nvl(v_ship_to_org_id,pll.ship_to_organization_id)
 and pll.ship_to_location_id           = nvl(v_ship_to_location_id,pll.ship_to_location_id)
 AND RT.TRANSACTION_TYPE               <> 'UNORDERED'
 -- for all the transactions in rt for which we can putaway, the
 -- transfer_lpn_id should match the lpn being putaway.
 --AND Nvl(rt.transfer_lpn_id,-1)        = Nvl(v_lpn_id,-1)
 -- Fix for 1865886. Commented the above and added the following for lpn
 AND Nvl(v_lpn_id,-1) IN (select nvl(rt2.transfer_lpn_id,-1)
			    from rcv_transactions rt2
			   where rt2.transaction_type <> 'DELIVER'
			   start with rt2.transaction_id = rs.supply_source_id
			 connect by prior rt2.transaction_id = rt2.parent_transaction_id
			union all
			  select nvl(rt2.lpn_id,-1)
			    from rcv_transactions rt2
			   where rt2.transaction_type not in ('RECEIVE', 'DELIVER')
			   start with rt2.transaction_id = rs.supply_source_id
			 connect by prior rt2.transaction_id = rt2.parent_transaction_id
			  )
  --
 and rs.supply_type_code               = 'RECEIVING'
 --and rsl.shipment_line_id   = rs.shipment_line_id
 and rsh.shipment_header_id            = rs.shipment_header_id
 AND (Nvl(rsh.receipt_num,'@@@'))      = Nvl(v_receipt_num,Nvl(rsh.receipt_num,'@@@'))
 and rt.transaction_id                 = rs.rcv_transaction_id
 AND rt.transaction_date               < Nvl(v_txn_date,(rt.transaction_date + 1))
 --and rt.transaction_type <> 'UNORDERED'
 --
 and rs.po_header_id = header_id
 and rs.item_id      = v_item_id
 AND ((v_revision IS NOT NULL
       AND Nvl(rs.item_revision, v_revision) = v_revision)
      OR (v_revision IS NULL))
 AND (rt.routing_header_id IS NULL OR
      rt.routing_header_id <> 2 OR
      (rt.routing_header_id = 2
       AND rt.inspection_status_code <> 'NOT INSPECTED'
       AND rt.inspection_status_code = Nvl(v_inspection_status,rt.inspection_status_code)))
 AND  (
       v_lot_number IS NULL OR EXISTS
        (
          SELECT lot_num
          FROM   rcv_lots_supply rls
          WHERE  rls.transaction_id = rs.supply_source_id
          AND    rls.lot_num = v_lot_number
        )
      )
 AND  (
       v_parent_txn_id_to_match IS NULL
       OR v_parent_txn_id_to_match = rs.supply_source_id
       )
 AND  (
        v_lpn_id_to_match IS NULL
        OR (rs.lpn_id = v_lpn_id_to_match)
      );
--4364407
   CURSOR std_distributions_exp (
   header_id             NUMBER
  ,v_item_id             NUMBER
  ,v_revision            VARCHAR2
  ,v_po_line_id          NUMBER
  ,v_po_line_location_id NUMBER
  ,v_po_distribution_id  NUMBER
  ,v_po_release_id       NUMBER
  ,v_ship_to_org_id      NUMBER
  ,v_ship_to_location_id NUMBER
  ,v_receipt_num         VARCHAR2
  ,v_txn_date            DATE
  ,v_inspection_status   VARCHAR2
  ,v_lpn_id              NUMBER
  ,v_lot_number          VARCHAR2
  ,v_lpn_id_to_match     NUMBER
  ,v_parent_txn_id_to_match NUMBER
, v_organization_id		NUMBER) IS
 SELECT
  pll.line_location_id
 ,pll.unit_meas_lookup_code
 ,nvl(pll.promised_date,pll.need_by_date)	promised_date
 ,0 --pll.quantity_shipped
 ,pll.receipt_days_exception_code
 ,pll.qty_rcv_exception_code
 ,pll.days_early_receipt_allowed
 ,pll.days_late_receipt_allowed
 ,pod.po_distribution_id
 ,pll.ship_to_location_id
 ,nvl(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code
 ,rs.rcv_transaction_id
 ,rs.item_revision
 from  po_distributions_trx_v     pod,         -- CLM project, bug 9403291
       po_line_locations_trx_v    pll,               -- CLM project, bug 9403291
       po_lines_trx_v		    pl,                 -- CLM project, bug 9403291
       rcv_supply           rs,
       rcv_shipment_headers rsh,
       rcv_transactions     rt
 where rsh.receipt_source_code         = 'VENDOR'
 AND pod.po_line_id                          = Nvl(v_po_line_id, pod.po_line_id)
 AND pod.line_location_id                  = Nvl(v_po_line_location_id, pod.line_location_id)
 AND pod.po_distribution_id            = Nvl(v_po_distribution_id, pod.po_distribution_id)
 and pl.po_line_id                     = rs.po_line_id
 and pll.line_location_id              = rs.po_line_location_id
 and pod.line_location_id              = rs.po_line_location_id
 and NVL(pll.APPROVED_FLAG,'N')        = 'Y'
 and NVL(pll.CANCEL_FLAG, 'N')         = 'N'
 --and NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
 and NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED')
 and pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
 and pll.ship_to_organization_id       = nvl(v_ship_to_org_id,pll.ship_to_organization_id)
 and pll.ship_to_location_id           = nvl(v_ship_to_location_id,pll.ship_to_location_id)
 AND RT.TRANSACTION_TYPE               <> 'UNORDERED'
 AND Nvl(v_lpn_id,-1) IN (select nvl(rt2.transfer_lpn_id,-1)
			    from rcv_transactions rt2
			   where rt2.transaction_type <> 'DELIVER'
			   start with rt2.transaction_id = rs.supply_source_id
			 connect by prior rt2.transaction_id = rt2.parent_transaction_id
			union all
			  select nvl(rt2.lpn_id,-1)
			    from rcv_transactions rt2
			   where rt2.transaction_type not in ('RECEIVE', 'DELIVER')
			   start with rt2.transaction_id = rs.supply_source_id
			 connect by prior rt2.transaction_id = rt2.parent_transaction_id
			  )
  and rs.supply_type_code               = 'RECEIVING'
 --and rsl.shipment_line_id   = rs.shipment_line_id
 and rsh.shipment_header_id            = rs.shipment_header_id
 AND (Nvl(rsh.receipt_num,'@@@'))      = Nvl(v_receipt_num,Nvl(rsh.receipt_num,'@@@'))
 and rt.transaction_id                 = rs.rcv_transaction_id
 AND rt.transaction_date               < Nvl(v_txn_date,(rt.transaction_date + 1))
 and rs.po_header_id = header_id
--and rs.item_id      = v_item_id
 AND ((v_revision IS NOT NULL
       AND Nvl(rs.item_revision, v_revision) = v_revision)
      OR (v_revision IS NULL))
 AND (rt.routing_header_id IS NULL OR
      rt.routing_header_id <> 2 OR
      (rt.routing_header_id = 2
       AND rt.inspection_status_code <> 'NOT INSPECTED'
       AND rt.inspection_status_code = Nvl(v_inspection_status,rt.inspection_status_code)))
 AND  (
       v_lot_number IS NULL OR EXISTS
        (
          SELECT lot_num
          FROM   rcv_lots_supply rls
          WHERE  rls.transaction_id = rs.supply_source_id
          AND    rls.lot_num = v_lot_number
        )
      )
 AND  (
       v_parent_txn_id_to_match IS NULL
       OR v_parent_txn_id_to_match = rs.supply_source_id
       )
 AND  (
        v_lpn_id_to_match IS NULL
        OR (rs.lpn_id = v_lpn_id_to_match)
     )
order by rs.item_revision, nvl(pll.promised_date,pll.need_by_date);

 CURSOR count_std_distributions_exp (
    header_id             NUMBER
  , v_item_id             NUMBER
  , v_revision            VARCHAR2
  , v_po_line_id          NUMBER
  , v_po_line_location_id NUMBER
  , v_po_distribution_id  NUMBER
  , v_po_release_id       NUMBER
  , v_ship_to_org_id      NUMBER
  , v_ship_to_location_id NUMBER
  , v_receipt_num         VARCHAR2
  , v_txn_date            DATE
  , v_inspection_status   VARCHAR2
  , v_lpn_id              NUMBER
  , v_lot_number          VARCHAR2
  , v_lpn_id_to_match     NUMBER
  ,v_parent_txn_id_to_match NUMBER
, v_organization_id		NUMBER) IS
SELECT count(*)
FROM  po_distributions_trx_v     pod,       -- CLM project, bug 9403291
       po_line_locations_trx_v    pll,         -- CLM project, bug 9403291
       po_lines_trx_v		    pl,                 -- CLM project, bug 9403291
       rcv_supply           rs,
       rcv_shipment_headers rsh,
       rcv_transactions     rt
 where rsh.receipt_source_code         = 'VENDOR'
  AND pod.po_line_id                    = Nvl(v_po_line_id, pod.po_line_id)
 AND pod.line_location_id              = Nvl(v_po_line_location_id, pod.line_location_id)
 AND pod.po_distribution_id            = Nvl(v_po_distribution_id, pod.po_distribution_id)
 and pl.po_line_id                     = rs.po_line_id
 and pll.line_location_id              = rs.po_line_location_id
 and pod.line_location_id              = rs.po_line_location_id
 and NVL(pll.APPROVED_FLAG,'N')        = 'Y'
 and NVL(pll.CANCEL_FLAG, 'N')         = 'N'
 --and NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
 and NVL(pll.CLOSED_CODE,'OPEN')       NOT IN ('FINALLY CLOSED')
 and pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
 and pll.ship_to_organization_id       = nvl(v_ship_to_org_id,pll.ship_to_organization_id)
 and pll.ship_to_location_id           = nvl(v_ship_to_location_id,pll.ship_to_location_id)
 AND RT.TRANSACTION_TYPE               <> 'UNORDERED'
 AND Nvl(v_lpn_id,-1) IN (select nvl(rt2.transfer_lpn_id,-1)
			    from rcv_transactions rt2
			   where rt2.transaction_type <> 'DELIVER'
			   start with rt2.transaction_id = rs.supply_source_id
			 connect by prior rt2.transaction_id = rt2.parent_transaction_id
			union all
			  select nvl(rt2.lpn_id,-1)
			    from rcv_transactions rt2
			   where rt2.transaction_type not in ('RECEIVE', 'DELIVER')
			   start with rt2.transaction_id = rs.supply_source_id
			 connect by prior rt2.transaction_id = rt2.parent_transaction_id
			  )
 and rs.supply_type_code               = 'RECEIVING'
 --and rsl.shipment_line_id   = rs.shipment_line_id
 and rsh.shipment_header_id            = rs.shipment_header_id
 AND (Nvl(rsh.receipt_num,'@@@'))      = Nvl(v_receipt_num,Nvl(rsh.receipt_num,'@@@'))
 and rt.transaction_id                 = rs.rcv_transaction_id
 AND rt.transaction_date               < Nvl(v_txn_date,(rt.transaction_date + 1))
 and rs.po_header_id = header_id
 --and rs.item_id      = v_item_id
 AND ((v_revision IS NOT NULL
       AND Nvl(rs.item_revision, v_revision) = v_revision)
      OR (v_revision IS NULL))
 AND (rt.routing_header_id IS NULL OR
      rt.routing_header_id <> 2 OR
      (rt.routing_header_id = 2
       AND rt.inspection_status_code <> 'NOT INSPECTED'
       AND rt.inspection_status_code = Nvl(v_inspection_status,rt.inspection_status_code)))
 AND  (
       v_lot_number IS NULL OR EXISTS
        (
          SELECT lot_num
          FROM   rcv_lots_supply rls
          WHERE  rls.transaction_id = rs.supply_source_id
          AND    rls.lot_num = v_lot_number
        )
      )
 AND  (
       v_parent_txn_id_to_match IS NULL
       OR v_parent_txn_id_to_match = rs.supply_source_id
       )
 AND  (
        v_lpn_id_to_match IS NULL
        OR (rs.lpn_id = v_lpn_id_to_match)
      );
--Bug 4364407
 ----

/*
** Debug: had to change this to the distribution record
** Might be a compatibility issue between the two record definitions
*/
 x_ShipmentDistributionRec	distributions%rowtype;
 x_record_count		        number;

 x_remaining_quantity		number := 0;
 x_remaining_qty_po_uom         number := 0;
 x_bkp_qty                      number := 0;
 x_progress			varchar2(3);
 x_converted_trx_qty		number := 0;
 transaction_ok			boolean	:= FALSE;
 x_expected_date		rcv_transactions_interface.expected_receipt_date%TYPE;
 high_range_date		DATE;
 low_range_date			DATE;
 rows_fetched		        number := 0;
 x_tolerable_qty		number := 0;
 x_first_trans			boolean := TRUE;
 x_sysdate			DATE	:= sysdate;
 current_n                      binary_integer := 0;
 insert_into_table              boolean := FALSE;
 x_qty_rcv_exception_code       po_line_locations.qty_rcv_exception_code%type;
 tax_amount_factor              number;
 lastrecord                     boolean := FALSE;
 -- Bug# 5739706
 l_date_reject                  boolean := FALSE;

 po_asn_uom_qty                 number;
 po_primary_uom_qty             number;

 already_allocated_qty          number := 0;

 x_item_id                      number;
 x_approved_flag                varchar(1);
 x_cancel_flag                  varchar(1);
 x_closed_code                  varchar(25);
 x_shipment_type                varchar(25);
 x_ship_to_location_id          number;
 x_vendor_product_num           varchar(25);
 x_temp_count                   number;
 l_asn_received_qty             NUMBER := 0;
 l_poll_qty			NUMBER := 0;
 l_poll_tolerance_pct		NUMBER := 0;
 l_poll_tolerance_qty		NUMBER := 0;


 l_api_name             CONSTANT VARCHAR2(30) := 'matching_logic';

 l_progress VARCHAR2(5) := '10';

 l_print_debug NUMBER := nvl(fnd_profile.value('INV_DEBUG_TRACE'), 2);

 l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

 --New variables for FP-J Lot/Serial Support
 l_lot_number_to_match  mtl_lot_numbers.lot_number%TYPE;
 l_lpn_id_to_match      NUMBER;
 l_parent_txn_id_to_match NUMBER;
 l_passed_parent_txn_id NUMBER;
 l_wms_po_j_or_higher   BOOLEAN;

 --Bug 4004656-Added the local variables for the quantity fields.
 l_rem_qty_trans_uom             NUMBER := 0; -- Remaining quantity to be received in transaction uom
 l_rcv_qty_trans_uom             NUMBER := 0; -- Quantity received in transaction uom
 l_rcv_qty_po_uom                NUMBER := 0; -- Quantity received in uom of the po.
 l_bkp_qty_trans_uom             NUMBER := 0;
 l_trx_qty_po_uom                NUMBER := 0; -- Transaction quantity in the uom of the po.
 l_trx_qty_trans_uom             NUMBER := 0; -- Transaction quantity in the transaction uom.
 l_tol_qty_po_uom                NUMBER := 0; -- Tolerable quantity in the uom of the po.
 --End of fix for Bug 4004656

 l_blind_receiving_flag          VARCHAR2(1) := 'N'; -- Bug 6365270
 l_asn_exists_code               rcv_parameters.receipt_asn_exists_code%TYPE; --Bug 8726009
 l_asn_count                     NUMBER := 0; --Bug 8726009
 l_asn_validation_failed         VARCHAR2(1) :='N';
-- For Bug 7440217
 l_asn_type                      VARCHAR2(40);
-- End for Bug 7440217
 l_client_code VARCHAR2(40);    /* Bug 9158529: LSP Changes */

 -- <Bug 9403291 : Added for CLM project>
l_distribution_type       VARCHAR2(100);
l_matching_basis          VARCHAR2(100);
l_accrue_on_receipt_flag  VARCHAR2(100);
l_code_combination_id     NUMBER;
l_budget_account_id       NUMBER;
l_partial_funded_flag     VARCHAR2(5) := 'N';
l_unit_meas_lookup_code   VARCHAR2(100);
l_funded_value            NUMBER;
l_quantity_funded         NUMBER;
l_amount_funded           NUMBER;
l_quantity_received       NUMBER;
l_amount_received         NUMBER;
l_quantity_delivered      NUMBER;
l_amount_delivered        NUMBER;
l_quantity_billed         NUMBER;
l_amount_billed           NUMBER;
l_quantity_cancelled      NUMBER;
l_amount_cancelled        NUMBER;
l_return_status_clm       VARCHAR2(100);
-- <End of bug 9403291>

BEGIN

   x_return_status := fnd_api.g_ret_sts_success;

   SAVEPOINT rcv_transactions_sa;

   l_allow_routing_override := fnd_profile.value('OVERRIDE_ROUTING');
   IF l_allow_routing_override IS NULL THEN
      l_allow_routing_override := 'N';
   end IF;

   -- the following steps will create a set of rows linking the line_record with
   -- its corresponding po_line_location rows until the quantity value from
   -- the asn is consumed.  (Cascade)
   IF l_print_debug = 1 THEN
      IF (l_debug = 1) THEN
         print_debug('po_header_id in matching logic is :'||x_cascaded_table(n).po_header_id);
         print_debug('item_id in matching logic is :'||x_cascaded_table(n).item_id);
         print_debug('revision in matching logic is :'||x_cascaded_table(n).revision);
         print_debug('item_desc in matching logic is :'||x_cascaded_table(n).item_desc);
         print_debug('transaction_type in matching logic is :'||x_cascaded_table(n).transaction_type);
	 print_debug('parent txn id = ' || x_cascaded_table(n).parent_transaction_id);
	 print_debug('l_allow_routing_override = ' || l_allow_routing_override);
      END IF;
   END IF;

   -- storing the passed value to match with the parent_txn_id in a local
   -- var and nulling out the variable in the record to simulate the
   -- behavior as was prior to patchset J changes.
   l_passed_parent_txn_id := x_cascaded_table(n).parent_transaction_id;
   x_cascaded_table(n).parent_transaction_id := NULL;

   /* FP-J Lot/Serial Support Enhancement
   * Read the currentand PO patch levels and set the flag (that would be used to
   * match the Lot Number and the LPN) accordingly
   */
  IF ((inv_rcv_common_apis.g_wms_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
      (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
    l_wms_po_j_or_higher := TRUE;
    IF (l_debug = 1) THEN
      print_debug('WMS and PO patch levels are J or higher', 4);
    END IF;
  ELSE
    l_wms_po_j_or_higher := FALSE;
    IF (l_debug = 1) THEN
      print_debug('Either WMS or/and PO patch level(s) are lower than J', 4);
    END IF;
  END IF;
   if ((x_cascaded_table(n).po_header_id is not null) 		AND
       ((x_cascaded_table(n).item_id is not NULL
	 OR (x_cascaded_table(n).item_desc IS NOT NULL
	     AND x_cascaded_table(n).transaction_type in ('DELIVER','RECEIVE','STD_DELIVER')))) 	AND  --4364407  Added STD_DELIVER also
       (x_cascaded_table(n).error_status in ('S','W'))) then
       -- Copy record from main table to temp table
       current_n := 1;
       temp_cascaded_table(current_n) := x_cascaded_table(n);
       -- Get all rows which meet this condition
       IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN
-- For Bug 7440217 Checking if doc is not LCM
        IF (p_shipment_header_id IS NOT NULL) THEN -- matching is called from ASN shipment matching
	     SELECT    ASN_TYPE
	     INTO      l_asn_type
	     FROM      RCV_SHIPMENT_HEADERS
	     WHERE     SHIPMENT_HEADER_ID = p_shipment_header_id;
        END IF;
-- End for Bug 7440217
       IF l_asn_type = 'ASN' THEN
-- End for Bug 7440217
	     l_progress := '20';
	     IF l_print_debug = 1 THEN
		IF (l_debug = 1) THEN
   		print_debug('Opening for ASN with parameters:',4);
   		print_debug('po_header_id:'||temp_cascaded_table(current_n).po_header_id,4);
   		print_debug('item_id:'||temp_cascaded_table(current_n).item_id,4);
   		print_debug('po_line_id:'||temp_cascaded_table(current_n).po_line_id,4);
   		print_debug('po_line_location_id:'||temp_cascaded_table(current_n).po_line_location_id,4);
   		print_debug('po_release_id:'||temp_cascaded_table(current_n).po_release_id,4);
   		print_debug('to_organization_id:'||temp_cascaded_table(current_n).to_organization_id,4);
   		print_debug('p_shipment_header_id:'||p_shipment_header_id,4);
   		print_debug('p_lpn_id:'||p_lpn_id,4);
   		print_debug('item_desc:'||temp_cascaded_table(current_n).item_desc,4);
   		print_debug('inspection_status_code:'||temp_cascaded_table(current_n).inspection_status_code,4);
		END IF;
	     END IF;
	     IF temp_cascaded_table(current_n).po_header_id IS NULL THEN
		OPEN asn_shipments
		  (temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_line_id,
		   temp_cascaded_table(current_n).po_line_location_id,
		   temp_cascaded_table(current_n).po_release_id,
		   temp_cascaded_table(current_n).to_organization_id,
		   NULL,--temp_cascaded_table(current_n).ship_to_location_id,
		   p_shipment_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   temp_cascaded_table(current_n).inspection_status_code,
		   temp_cascaded_table(current_n).to_organization_id);

		OPEN count_asn_shipments
		  (temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_line_id,
		   temp_cascaded_table(current_n).po_line_location_id,
		   temp_cascaded_table(current_n).po_release_id,
		   temp_cascaded_table(current_n).to_organization_id,
		   NULL,--temp_cascaded_table(current_n).ship_to_location_id,
		   p_shipment_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   temp_cascaded_table(current_n).inspection_status_code,
		   temp_cascaded_table(current_n).to_organization_id);
	      ELSE
		OPEN asn_shipments_w_po
		  (temp_cascaded_table(current_n).po_header_id,
		   temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_line_id,
		   temp_cascaded_table(current_n).po_line_location_id,
		   temp_cascaded_table(current_n).po_release_id,
		   temp_cascaded_table(current_n).to_organization_id,
		   NULL,--temp_cascaded_table(current_n).ship_to_location_id,
		   p_shipment_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   temp_cascaded_table(current_n).inspection_status_code,
		   temp_cascaded_table(current_n).to_organization_id);
		OPEN count_asn_shipments_w_po
		  (temp_cascaded_table(current_n).po_header_id,
		   temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_line_id,
		   temp_cascaded_table(current_n).po_line_location_id,
		   temp_cascaded_table(current_n).po_release_id,
		   temp_cascaded_table(current_n).to_organization_id,
		   NULL,--temp_cascaded_table(current_n).ship_to_location_id,
		   p_shipment_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   temp_cascaded_table(current_n).inspection_status_code,
		   temp_cascaded_table(current_n).to_organization_id);
      END IF;

-- For Bug 7440217 if doc type is LCM
       ELSIF l_asn_type = 'LCM' THEN
	     l_progress := '20a';
	     IF l_print_debug = 1 THEN
		IF (l_debug = 1) THEN
   		print_debug('Opening for LCM with parameters:',4);
   		print_debug('po_header_id:'||temp_cascaded_table(current_n).po_header_id,4);
   		print_debug('item_id:'||temp_cascaded_table(current_n).item_id,4);
   		print_debug('po_line_id:'||temp_cascaded_table(current_n).po_line_id,4);
   		print_debug('po_line_location_id:'||temp_cascaded_table(current_n).po_line_location_id,4);
   		print_debug('po_release_id:'||temp_cascaded_table(current_n).po_release_id,4);
   		print_debug('to_organization_id:'||temp_cascaded_table(current_n).to_organization_id,4);
   		print_debug('p_shipment_header_id:'||p_shipment_header_id,4);
   		print_debug('p_lpn_id:'||p_lpn_id,4);
   		print_debug('item_desc:'||temp_cascaded_table(current_n).item_desc,4);
   		print_debug('inspection_status_code:'||temp_cascaded_table(current_n).inspection_status_code,4);
		END IF;
	     END IF;
	     IF temp_cascaded_table(current_n).po_header_id IS NULL THEN
		OPEN lcm_shipments
		  (temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_line_id,
		   temp_cascaded_table(current_n).po_line_location_id,
		   temp_cascaded_table(current_n).po_release_id,
		   temp_cascaded_table(current_n).to_organization_id,
		   NULL,--temp_cascaded_table(current_n).ship_to_location_id,
		   p_shipment_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   temp_cascaded_table(current_n).inspection_status_code,
		   temp_cascaded_table(current_n).to_organization_id);
                 print_debug('IN SVSVSVSV LCM 01010101010a');
		OPEN count_lcm_shipments
		  (temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_line_id,
		   temp_cascaded_table(current_n).po_line_location_id,
		   temp_cascaded_table(current_n).po_release_id,
		   temp_cascaded_table(current_n).to_organization_id,
		   NULL,--temp_cascaded_table(current_n).ship_to_location_id,
		   p_shipment_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   temp_cascaded_table(current_n).inspection_status_code,
		   temp_cascaded_table(current_n).to_organization_id);
		   print_debug('IN SVSVSVSV LCM 121212121212a');
	      ELSE
		OPEN lcm_shipments_w_po
		  (temp_cascaded_table(current_n).po_header_id,
		   temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_line_id,
		   temp_cascaded_table(current_n).po_line_location_id,
		   temp_cascaded_table(current_n).po_release_id,
		   temp_cascaded_table(current_n).to_organization_id,
		   NULL,--temp_cascaded_table(current_n).ship_to_location_id,
		   p_shipment_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   temp_cascaded_table(current_n).inspection_status_code,
		   temp_cascaded_table(current_n).to_organization_id);
		    print_debug('IN SVSVSVSV LCM 141414514141414a');
		OPEN count_lcm_shipments_w_po
		  (temp_cascaded_table(current_n).po_header_id,
		   temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_line_id,
		   temp_cascaded_table(current_n).po_line_location_id,
		   temp_cascaded_table(current_n).po_release_id,
		   temp_cascaded_table(current_n).to_organization_id,
		   NULL,--temp_cascaded_table(current_n).ship_to_location_id,
		   p_shipment_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   temp_cascaded_table(current_n).inspection_status_code,
		   temp_cascaded_table(current_n).to_organization_id);
		    print_debug('IN SVSVSVSV LCM 564563634564356a');
       END IF;
-- End for Bug 7440217

       ELSE -- normal PO receipt
	     l_progress := '30';
	     IF l_print_debug = 1 THEN
		IF (l_debug = 1) THEN
   		print_debug('Opening for PO with parameters:',4);
   		print_debug('po_header_id:'||temp_cascaded_table(current_n).po_header_id,4);
   		print_debug('item_id:'||temp_cascaded_table(current_n).item_id,4);
   		print_debug('revision:'||temp_cascaded_table(current_n).revision,4);
   		print_debug('po_line_id:'||temp_cascaded_table(current_n).po_line_id,4);
   		print_debug('po_line_location_id:'||temp_cascaded_table(current_n).po_line_location_id,4);
   		print_debug('po_release_id:'||temp_cascaded_table(current_n).po_release_id,4);
   		print_debug('to_organization_id:'||temp_cascaded_table(current_n).to_organization_id,4);
   		print_debug('item_desc:'||temp_cascaded_table(current_n).item_desc,4);
		END IF;
	     END IF;
	     OPEN shipments (temp_cascaded_table(current_n).po_header_id,
			     temp_cascaded_table(current_n).item_id,
			     temp_cascaded_table(current_n).revision,
			     temp_cascaded_table(current_n).po_line_id,
			     temp_cascaded_table(current_n).po_line_location_id,
			     temp_cascaded_table(current_n).po_release_id,
			     temp_cascaded_table(current_n).to_organization_id,
			     NULL, --temp_cascaded_table(current_n).ship_to_location_id,
			     temp_cascaded_table(current_n).item_desc,
			     temp_cascaded_table(current_n).project_id,
			     temp_cascaded_table(current_n).task_id,
			     temp_cascaded_table(current_n).inspection_status_code,
		         temp_cascaded_table(current_n).to_organization_id);

	     -- count_shipments just gets the count of rows found in shipments

	     OPEN count_shipments (temp_cascaded_table(current_n).po_header_id,
				   temp_cascaded_table(current_n).item_id,
			           temp_cascaded_table(current_n).revision,
				   temp_cascaded_table(current_n).po_line_id,
				   temp_cascaded_table(current_n).po_line_location_id,
				   temp_cascaded_table(current_n).po_release_id,
				   temp_cascaded_table(current_n).to_organization_id,
				   NULL, --temp_cascaded_table(current_n).ship_to_location_id,
				   temp_cascaded_table(current_n).item_desc,
				   temp_cascaded_table(current_n).project_id,
				   temp_cascaded_table(current_n).task_id,
				   temp_cascaded_table(current_n).inspection_status_code,
		           temp_cascaded_table(current_n).to_organization_id);
	  END IF;

       ELSIF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN

	  l_progress := '40';
	  IF l_print_debug = 1 THEN
	     IF (l_debug = 1) THEN
   	     print_debug('Opening for PO distribution with parameters:',4);
   	     print_debug('po_header_id:'||temp_cascaded_table(current_n).po_header_id,4);
   	     print_debug('item_id:'||temp_cascaded_table(current_n).item_id,4);
   	     print_debug('revision:'||temp_cascaded_table(current_n).revision,4);
   	     print_debug('po_line_id:'||temp_cascaded_table(current_n).po_line_id,4);
   	     print_debug('po_line_location_id:'||temp_cascaded_table(current_n).po_line_location_id,4);
   	     print_debug('po_distribution_id:'||temp_cascaded_table(current_n).po_distribution_id,4);
   	     print_debug('po_release_id:'||temp_cascaded_table(current_n).po_release_id,4);
   	     print_debug('to_organization_id:'||temp_cascaded_table(current_n).to_organization_id,4);
   	     print_debug('item_desc:'||temp_cascaded_table(current_n).item_desc,4);
	     END IF;
	  END IF;
	  open distributions (temp_cascaded_table(current_n).po_header_id,
                              temp_cascaded_table(current_n).item_id,
			      temp_cascaded_table(current_n).revision,
			      temp_cascaded_table(current_n).po_line_id,
			      temp_cascaded_table(current_n).po_line_location_id,
			      temp_cascaded_table(current_n).po_distribution_id,
                              temp_cascaded_table(current_n).po_release_id,
                              temp_cascaded_table(current_n).to_organization_id,
                              NULL, --temp_cascaded_table(current_n).ship_to_location_id,
			      temp_cascaded_table(current_n).item_desc,
		temp_cascaded_table(current_n).project_id,
		temp_cascaded_table(current_n).task_id,
		              temp_cascaded_table(current_n).to_organization_id);

          -- count_distributions just gets the count of rows found in distributions

          open count_distributions (temp_cascaded_table(current_n).po_header_id,
                                    temp_cascaded_table(current_n).item_id,
			            temp_cascaded_table(current_n).revision,
				    temp_cascaded_table(current_n).po_line_id,
				    temp_cascaded_table(current_n).po_line_location_id,
				    temp_cascaded_table(current_n).po_distribution_id,
                   		    temp_cascaded_table(current_n).po_release_id,
                   		    temp_cascaded_table(current_n).to_organization_id,
                   		    NULL, --temp_cascaded_table(current_n).ship_to_location_id,
				    temp_cascaded_table(current_n).item_desc,
		temp_cascaded_table(current_n).project_id,
		temp_cascaded_table(current_n).task_id,
		              temp_cascaded_table(current_n).to_organization_id);

       ELSIF (x_cascaded_table(n).transaction_type = 'STD_DELIVER') THEN
	  l_progress := '50';
--	  If  (x_cascaded_table(n).item_id IS not  NULL )  THEN   --4364407, moved it down.
	  IF l_print_debug = 1 THEN
	     IF (l_debug = 1) THEN
   	     print_debug('Opening for PO std distribution with parameters:',4);
   	     print_debug('po_header_id:'||temp_cascaded_table(current_n).po_header_id,4);
   	     print_debug('item_id:'||temp_cascaded_table(current_n).item_id,4);
   	     print_debug('revision:'||temp_cascaded_table(current_n).revision,4);
   	     print_debug('po_line_id:'||temp_cascaded_table(current_n).po_line_id,4);
   	     print_debug('po_line_location_id:'||temp_cascaded_table(current_n).po_line_location_id,4);
   	     print_debug('po_distribution_id:'||temp_cascaded_table(current_n).po_distribution_id,4);
   	     print_debug('po_release_id:'||temp_cascaded_table(current_n).po_release_id,4);
   	     print_debug('to_organization_id:'||temp_cascaded_table(current_n).to_organization_id,4);
   	     print_debug('item_desc:'||temp_cascaded_table(current_n).item_desc,4);
   	     print_debug('p_receipt_num:'||p_receipt_num,4);
   	     print_debug('expected_receipt_date:'||temp_cascaded_table(current_n).expected_receipt_date,4);
   	     print_debug('inspection_status_code:'||temp_cascaded_table(current_n).inspection_status_code,4);
   	     print_debug('p_lpn_id:'||temp_cascaded_table(current_n).p_lpn_id,4);
	     END IF;
	   END IF;

      /* FP-J Lot/Serial Support Enhancement
       * If WMS and PO patch levels are J or higher, then we need to:
       *   a) Match the lot number with that in RCV_LOTS_SUPPLY for the
       *      the parent transaction in RCV_SUPPLY if lot number is not NULL
       *   b) Match the LPN being delivered with the LPN in the RCV_SUPPLY for
       *      the parent transaction
       *   c) Set the value of lot_number to the cursor from that in the cascaded table
       *      Set the value of lpn_id_to_match to the lpn being delivered (p_lpn_id)
       * If either of these are not at J, we should retain the original functionality
       * and so explictily set these values to NULL
       * Nevertheless, we should pass these two new values to the cursors
       * std_distributions and count_std_distributions
       */
      IF (l_wms_po_j_or_higher) THEN
        l_lot_number_to_match := temp_cascaded_table(current_n).lot_number;
        l_lpn_id_to_match     := temp_cascaded_table(current_n).p_lpn_id;
	l_parent_txn_id_to_match := l_passed_parent_txn_id;
      ELSE
        l_lot_number_to_match := NULL;
        l_lpn_id_to_match     := NULL;
	l_parent_txn_id_to_match := NULL;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('l_lot_number_to_match: ' || l_lot_number_to_match, 4);
        print_debug('l_lpn_id_to_match: ' || l_lpn_id_to_match, 4);
	print_debug('l_parent_txn_id_to_match: ' || l_parent_txn_id_to_match, 4);
      END IF;

     If  (x_cascaded_table(n).item_id IS not  NULL )  THEN   --4364407

      OPEN std_distributions (
            temp_cascaded_table(current_n).po_header_id,
            temp_cascaded_table(current_n).item_id,
            temp_cascaded_table(current_n).revision,
            temp_cascaded_table(current_n).po_line_id,
            temp_cascaded_table(current_n).po_line_location_id,
            temp_cascaded_table(current_n).po_distribution_id,
            temp_cascaded_table(current_n).po_release_id,
            temp_cascaded_table(current_n).to_organization_id,
            NULL,--temp_cascaded_table(current_n).ship_to_location_id,
            p_receipt_num,
            temp_cascaded_table(current_n).expected_receipt_date,
            temp_cascaded_table(current_n).inspection_status_code,
            temp_cascaded_table(current_n).p_lpn_id,
            l_lot_number_to_match,
            l_lpn_id_to_match,
	    l_parent_txn_id_to_match,
  	    temp_cascaded_table(current_n).to_organization_id);

          -- count_distributions just gets the count of rows found in distributions

      OPEN count_std_distributions (
            temp_cascaded_table(current_n).po_header_id,
            temp_cascaded_table(current_n).item_id,
            temp_cascaded_table(current_n).revision,
            temp_cascaded_table(current_n).po_line_id,
            temp_cascaded_table(current_n).po_line_location_id,
            temp_cascaded_table(current_n).po_distribution_id,
            temp_cascaded_table(current_n).po_release_id,
            temp_cascaded_table(current_n).to_organization_id,
            NULL,--temp_cascaded_table(current_n).ship_to_location_id,
            p_receipt_num,
            temp_cascaded_table(current_n).expected_receipt_date,
            temp_cascaded_table(current_n).inspection_status_code,
            temp_cascaded_table(current_n).p_lpn_id,
            l_lot_number_to_match,
            l_lpn_id_to_match,
	    l_parent_txn_id_to_match,
  	    temp_cascaded_table(current_n).to_organization_id);

--4364407
      Else
      OPEN std_distributions_exp (
            temp_cascaded_table(current_n).po_header_id,
            temp_cascaded_table(current_n).item_id,
            temp_cascaded_table(current_n).revision,
            temp_cascaded_table(current_n).po_line_id,
            temp_cascaded_table(current_n).po_line_location_id,
            temp_cascaded_table(current_n).po_distribution_id,
            temp_cascaded_table(current_n).po_release_id,
            temp_cascaded_table(current_n).to_organization_id,
            NULL,--temp_cascaded_table(current_n).ship_to_location_id,
            p_receipt_num,
            temp_cascaded_table(current_n).expected_receipt_date,
            temp_cascaded_table(current_n).inspection_status_code,
            temp_cascaded_table(current_n).p_lpn_id,
            l_lot_number_to_match,
            l_lpn_id_to_match,
	    l_parent_txn_id_to_match,
  	    temp_cascaded_table(current_n).to_organization_id);

          -- count_distributions just gets the count of rows found in distributions

      OPEN count_std_distributions_exp (
            temp_cascaded_table(current_n).po_header_id,
            temp_cascaded_table(current_n).item_id,
            temp_cascaded_table(current_n).revision,
            temp_cascaded_table(current_n).po_line_id,
            temp_cascaded_table(current_n).po_line_location_id,
            temp_cascaded_table(current_n).po_distribution_id,
            temp_cascaded_table(current_n).po_release_id,
            temp_cascaded_table(current_n).to_organization_id,
            NULL,--temp_cascaded_table(current_n).ship_to_location_id,
            p_receipt_num,
            temp_cascaded_table(current_n).expected_receipt_date,
            temp_cascaded_table(current_n).inspection_status_code,
            temp_cascaded_table(current_n).p_lpn_id,
            l_lot_number_to_match,
            l_lpn_id_to_match,
	    l_parent_txn_id_to_match,
  	    temp_cascaded_table(current_n).to_organization_id);
       END IF;
--4364407

       END IF;

       l_progress := '60';
       -- Assign shipped quantity to remaining quantity

     --x_remaining_quantity	:= temp_cascaded_table(current_n).quantity; --Bug 4004656
       l_rem_qty_trans_uom      := temp_cascaded_table(current_n).quantity; --Bug 4004656


       -- used for decrementing cum qty for first record


     --x_bkp_qty                 := x_remaining_quantity;  --Bug 4004656
     --x_remaining_qty_po_uom    := 0;                     --Bug 4004656
       l_bkp_qty_trans_uom       := l_rem_qty_trans_uom;   --Bug 4004656
       l_rcv_qty_trans_uom       := 0;		           --Bug 4004656
       l_rcv_qty_po_uom	         := 0;		    	   --Bug 4004656
       -- Calculate tax_amount_factor for calculating tax_amount for
       -- each cascaded line

       if nvl(temp_cascaded_table(current_n).tax_amount,0) <> 0 THEN
	  /*Bug 4004656 -Commented out the below statement
	  tax_amount_factor := temp_cascaded_table(current_n).tax_amount/x_remaining_quantity; */
	  tax_amount_factor := temp_cascaded_table(current_n).tax_amount/l_rem_qty_trans_uom;
	  --End of fix for Bug 4004656
	else
	  tax_amount_factor := 0;
       end if;

       x_first_trans    := TRUE;
       transaction_ok   := FALSE;


       l_progress := '70';
       -- Get the count of the number of records depending on the
       -- the transaction type

       IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN
	  l_progress := '80';

	  IF p_shipment_header_id IS NOT NULL THEN

-- For Bug 7440217
	    IF l_asn_type = 'ASN' THEN
	     IF temp_cascaded_table(current_n).po_header_id IS NULL THEN
		FETCH count_asn_shipments INTO x_record_count;
	      ELSE
		FETCH count_asn_shipments_w_po INTO x_record_count;
	     END IF;
	    ELSIF l_asn_type = 'LCM' THEN
	      IF temp_cascaded_table(current_n).po_header_id IS NULL THEN
		FETCH count_lcm_shipments INTO x_record_count;
	      ELSE
		FETCH count_lcm_shipments_w_po INTO x_record_count;
	     END IF;
	   ELSE
	     FETCH count_shipments INTO x_record_count;
	  END IF;
	 END IF;
-- End for Bug 7440217

	ELSIF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
	  l_progress := '90';

	  FETCH count_distributions INTO x_record_count;

	ELSIF (x_cascaded_table(n).transaction_type = 'STD_DELIVER') THEN
	  l_progress := '100';

          If  (x_cascaded_table(n).item_id is NOT NULL  ) THEN  --4364407
             FETCH count_std_distributions INTO x_record_count;
          else
            FETCH count_std_distributions_exp INTO x_record_count; --4364407
          end if;

       END IF;

       IF l_print_debug = 1 THEN
	  IF (l_debug = 1) THEN
   	  print_debug('Rows fetched into matching cursor :'||x_record_count,4);
	  END IF;
       END IF;

       LOOP

	  -- Fetch the appropriate record
	  l_progress := '110';

	  IF (l_debug = 1) THEN
   	     print_debug('Inside the loop',4);
	  END IF;

	  IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN
	     l_progress := '120';

	     IF (l_debug = 1) THEN
 	       print_debug('Inside loop for condition of RECEIVE',4);
             END IF;

	     IF p_shipment_header_id IS NOT NULL THEN

		IF (l_debug = 1) THEN
		  print_debug('Inside shipment_header_id not null case, value of po_header_id:'|| x_cascaded_table(n).po_header_id ,4);
  	        END IF;

	        /* Bug 4901154- When looping, for current_n=2, no value has been
				assigned to temp_cascaded_table(2), hence NO_DATA_FOUND
				exception is raised.
                 		Inside the loop, using x_cascaded_table instead of
				temp_cascaded_table.

		IF temp_cascaded_table(current_n).po_header_id IS NULL THEN */

-- For Bug 7440217
                IF l_asn_type = 'ASN' THEN
                 IF x_cascaded_table(n).po_header_id IS NULL THEN
		/* End of fix for Bug 4901154 */

		   FETCH asn_shipments INTO x_ShipmentDistributionRec;
		   -- Check if this is the last record
		   IF (asn_shipments%NOTFOUND) THEN
		      lastrecord := TRUE;
		   END IF;
		   rows_fetched := asn_shipments%rowcount;
		  ELSE
		   FETCH asn_shipments_w_po INTO x_shipmentdistributionrec;
		   -- Check if this is the last record
		   IF (asn_shipments_w_po%NOTFOUND) THEN
		      lastrecord := TRUE;
		   END IF;
		   rows_fetched := asn_shipments_w_po%rowcount;
		 END IF;
                ELSIF l_asn_type = 'LCM' THEN
		 IF x_cascaded_table(n).po_header_id IS NULL THEN
		/* End of fix for Bug 4901154 */

		   FETCH lcm_shipments INTO x_ShipmentDistributionRec;
		   -- Check if this is the last record
		   IF (lcm_shipments%NOTFOUND) THEN
		      lastrecord := TRUE;
		   END IF;
		   rows_fetched := lcm_shipments%rowcount;
		 ELSE
		   FETCH lcm_shipments_w_po INTO x_shipmentdistributionrec;
		   -- Check if this is the last record
		   IF (lcm_shipments_w_po%NOTFOUND) THEN
		      lastrecord := TRUE;
		   END IF;
		   rows_fetched := lcm_shipments_w_po%rowcount;
		END IF;
               END IF;
-- End for Bug 7440217

	      ELSE

		FETCH shipments INTO x_ShipmentDistributionRec;
		-- Check if this is the last record
		IF (shipments%NOTFOUND) THEN
		   lastrecord := TRUE;
		END IF;
		rows_fetched := shipments%rowcount;
	     END IF;


	   ELSIF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
	     l_progress := '130';

	     fetch distributions into x_ShipmentDistributionRec;

	     -- Check if this is the last record
	     if (distributions%NOTFOUND) THEN
		lastrecord := TRUE;
	     END IF;

	     rows_fetched := distributions%rowcount;
	   ELSIF (x_cascaded_table(n).transaction_type = 'STD_DELIVER') THEN
	     l_progress := '140';
             If  (x_cascaded_table(n).item_id IS NOT NULL )THEN        --4364407
               fetch std_distributions into x_ShipmentDistributionRec;

	     -- Check if this is the last record
	     if (std_distributions%NOTFOUND) THEN
		lastrecord := TRUE;
	     END IF;

	     rows_fetched := std_distributions%rowcount;
--4364407
             else
               fetch std_distributions_exp into x_ShipmentDistributionRec;
             -- Check if this is the last record
             if (std_distributions_exp%NOTFOUND) THEN
                lastrecord := TRUE;
             END IF;

             rows_fetched := std_distributions_exp%rowcount;
             end if;
--4364407

	  END IF;
	  IF l_print_debug = 1 THEN
	     IF (l_debug = 1) THEN
   	     print_debug('Rows fetched from matching cursor :'||rows_fetched,4);
    	   --print_debug('Remaining qty:'||x_remaining_quantity,4);--Bug 4004656
             print_debug('Remaining qty:'||l_rem_qty_trans_uom,4); --Bug 4004656
	     print_debug('current_n:'||current_n,4);
	     END IF;
	     IF x_first_trans THEN
		IF (l_debug = 1) THEN
   		print_debug('x_first_trans:TRUE',4);
		END IF;
	      ELSE
		IF (l_debug = 1) THEN
   		print_debug('x_first_trans:FLASE',4);
		END IF;
	     END IF;
	     IF lastrecord THEN
		IF (l_debug = 1) THEN
   		print_debug('lastrecord:TRUE',4);
		END IF;
	      ELSE
		IF (l_debug = 1) THEN
   		print_debug('lastrecord:FLASE',4);
		END IF;
	     END IF;
	  END IF;
	  l_progress := '150';
	  /* Bug 4004656 -Commented the following statement
	  if (lastrecord or x_remaining_quantity <= 0) then */
          /* Bug 4747997: We have to compare the rounded off values by 5 decimal places,
                          as the value hold by this variable is non-rounded value returned
                          from the API rcv_transactions_interface_sv.convert_into_correct_qty() */

	  if (lastrecord or round(l_rem_qty_trans_uom,5) <= 0) then --Bug 4747997
	  --End of fix for Bug 4004656
	     IF l_print_debug = 1 THEN
		IF (l_debug = 1) THEN
   		print_debug('No more rows or the remaining qty is less than zero',4);
		END IF;
	     END IF;

	     if not x_first_trans  then
		-- x_first_trans has been reset which means some cascade has
		-- happened. Otherwise current_n = 1
		current_n := current_n -1 ;
	     end if;
         /* Bug 8726009.
         * We need to use the ASN control action set in the Receiving
         * Options window. Get the control code from rcv_parameters.
         * If the transaction type is Receive/Dir Deliver and if there is an
         * ASN existing for that PO, then depending on this value
         * we should either allow or error out.
         */

	/* Bug 9158529: LSP Changes */

        BEGIN
           IF (NVL(FND_PROFILE.VALUE('WMS_DEPLOYMENT_MODE'), 1) = 3) THEN

            l_client_code := wms_deploy.get_po_client_code(temp_cascaded_table(current_n).po_header_id);


            If (l_client_code IS NOT NULL) THEN

            select nvl(max(receipt_asn_exists_code),'NONE')
  	        into   l_asn_exists_code
  	        from mtl_client_parameters
            WHERE client_code = l_client_code;

             ELSE

            SELECT NVL(receipt_asn_exists_code, 'NONE')
            INTO l_asn_exists_code
            FROM rcv_parameters
            WHERE organization_id = temp_cascaded_table(current_n).to_organization_id;

            End If;

           Else

           SELECT NVL(receipt_asn_exists_code, 'NONE')
           INTO l_asn_exists_code
           FROM rcv_parameters
           WHERE organization_id = temp_cascaded_table(current_n).to_organization_id;

           END IF;

            EXCEPTION
            when others then
            NULL;
          END;

	  /* End Bug 9158529 */

         IF l_print_debug = 1 THEN
               IF (l_debug = 1) THEN
                 print_debug('ASN CODE IN rcv_parameters = '||l_asn_exists_code,4);
                 print_debug('x_cascaded_table(n).transaction_type = '||x_cascaded_table(n).transaction_type,4);
                 print_debug('x_cascaded_table(n).shipment_header_id = '||x_cascaded_table(n).shipment_header_id,4);
                 print_debug('x_shipmentdistributionrec.line_location_id = '||x_shipmentdistributionrec.line_location_id,4);
               END IF;
         END IF;

         IF (    ((x_cascaded_table(n).transaction_type in ('RECEIVE','DELIVER')))
               AND l_asn_exists_code in ('WARNING', 'REJECT')
               AND (x_cascaded_table(n).shipment_header_id is null)) THEN

               SELECT COUNT(*)
               INTO   l_asn_count
               FROM   rcv_shipment_headers rsh,
                      rcv_shipment_lines rsl
               WHERE  rsh.shipment_header_id = rsl.shipment_header_id
               AND    NVL(rsh.asn_type, 'STD') IN ('ASN','ASBN')
               AND    NVL(rsl.shipment_line_status_code, 'EXPECTED') NOT IN('CANCELLED', 'FULLY RECEIVED')
               AND    rsl.po_line_location_id = x_shipmentdistributionrec.line_location_id;

               IF l_print_debug = 1 THEN
                     IF (l_debug = 1) THEN
                       print_debug('l_asn_count ' || l_asn_count, 4);
                     END IF;
               END IF;

               IF (l_asn_count <> 0) THEN
                   IF (l_asn_exists_code = 'WARNING') THEN
                       temp_cascaded_table(current_n).error_status := 'W';
                       temp_cascaded_table(current_n).error_message := 'RCV_ASN_EXISTS_FOR_POLINE';
                   ELSIF (l_asn_exists_code = 'REJECT') THEN
                       x_cascaded_table(n).error_status  := 'E';
                       x_cascaded_table(n).error_message := 'RCV_ASN_EXISTS_FOR_POLINE';
                       if temp_cascaded_table.count > 0 then
                           for i in 1..temp_cascaded_table.count loop
                               temp_cascaded_table.delete(i);
                           end loop;
                       end if;
                       l_asn_validation_failed :='Y';
                   END IF;
               END IF;
         END IF;
         /* End of Changes for Bug 8726009 */
	    -- do the tolerance act here

	    -- lastrecord...we have run out of rows and
	    -- we still have quantity to allocate

	     /* Bug 4004656 -Commented the following statement
	     if x_remaining_quantity > 0   then */
	     if round(l_rem_qty_trans_uom,5) > 0 and l_asn_validation_failed='N' then --Bug 4747997
		IF l_print_debug = 1 THEN
		   IF (l_debug = 1) THEN
   		   print_debug('No more recs but still qty left',4);
		   END IF;
		END IF;
		if not x_first_trans then
		   IF l_print_debug = 1 THEN
		      IF (l_debug = 1) THEN
   		      print_debug('Atleast one row returned in matching cursor',4);
		      END IF;
		   END IF;
		   -- we had got atleast some rows from our shipments cursor
		   -- we have atleast one row cascaded (not null line_location_id)
		  IF x_cascaded_table(n).transaction_type IN  ('RECEIVE', 'DELIVER') THEN
            -- CLM Project, bug 9403291
            if PO_CLM_INTG_GRP.is_clm_po(null,null,x_shipmentdistributionrec.line_location_id,null) = 'Y' and l_partial_funded_flag = 'Y' then
		             x_qty_rcv_exception_code := 'REJECT';
            else
                 x_qty_rcv_exception_code := temp_cascaded_table(current_n).qty_rcv_exception_code;
            end if;
            -- bug 9403291

		   ELSE
		     x_qty_rcv_exception_code := 'REJECT';
		  END IF;
		  /* 3126097 */
		  IF x_qty_rcv_exception_code IN ('REJECT','WARNING') then
                    BEGIN
                      select quantity, nvl(qty_rcv_tolerance,0)
                      into l_poll_qty, l_poll_tolerance_pct
                      from po_line_locations_all
                      where line_location_id =  temp_cascaded_table(current_n).po_line_location_id ;
		     EXCEPTION
		      when others then
 			NULL;
 		    END;
 		    l_poll_tolerance_qty :=  (l_poll_qty*l_poll_tolerance_pct)/100 ;
   	         -- print_debug('Remaining PO qty:'||x_remaining_qty_po_uom,4); --Bug 4004656
		    print_debug('Remaining PO qty:'||l_rcv_qty_po_uom,4);       --Bug 4004656
   	            print_debug('po tolerance qty:'||l_poll_tolerance_qty,4);

                    -- The following needs not to be done for STD_DELIVER TXN.

		    --BUG #3325627
		    --IF x_cascaded_table(n).transaction_type IN  ('STD_DELIVER') THEN
   	            --   print_debug('No need to change Exception code -- STD DELIVER Txn ',4);
                    --ELSE
                    --   IF (x_remaining_qty_po_uom <= l_poll_tolerance_qty) THEN
                    --      print_debug('setting x_qty_rcv_exception_code to NONE',4);
                    --      x_qty_rcv_exception_code := 'NONE';
                    --   END IF;
                    --END IF;
                 END IF;

		  IF l_print_debug = 1 THEN
		     IF (l_debug = 1) THEN
   		     print_debug('x_qty_rcv_exception_code:'||x_qty_rcv_exception_code,4);
		     END IF;
		  END IF;

                   -- Start of fix for Bug 6365270
                 BEGIN
                    SELECT blind_receiving_flag
                    INTO l_blind_receiving_flag
                    FROM rcv_parameters
                    WHERE organization_id = temp_cascaded_table(current_n).to_organization_id;
                 EXCEPTION
                    when others then
                    NULL;
                 END;

-- CLM project, bug 9403291
      if PO_CLM_INTG_GRP.is_clm_po(null,null,x_shipmentdistributionrec.line_location_id,null) = 'Y' and l_partial_funded_flag = 'Y' then
           l_blind_receiving_flag := 'N';
      end if;
-- End of CLM project, bug 9403291

                 IF l_print_debug = 1 THEN
                    IF (l_debug = 1) THEN
                      print_debug('Current Organization id = '|| temp_cascaded_table(current_n).to_organization_id,4);
                      print_debug('Blind Receiving Flag = '|| l_blind_receiving_flag,4);
                    END IF;
                 END IF;
                   -- End of fix for Bug 6365270

              -- The following if condition is commented out as part of bug 6365270
	      -- if x_qty_rcv_exception_code IN ('NONE','WARNING')  then
		     temp_cascaded_table(current_n).quantity :=
		       temp_cascaded_table(current_n).quantity +
		      --x_remaining_quantity; --Bug 4004656
		      l_rem_qty_trans_uom;    --Bug 4004656

		     temp_cascaded_table(current_n).quantity_shipped :=
		       temp_cascaded_table(current_n).quantity_shipped +
		       --x_remaining_quantity; --Bug 4004656
		       l_rem_qty_trans_uom;    --Bug 4004656

		     temp_cascaded_table(current_n).source_doc_quantity :=
		       temp_cascaded_table(current_n).source_doc_quantity +
		       --x_remaining_qty_po_uom; --Bug 4004656
		         l_rcv_qty_po_uom;       --Bug 4004656
		     IF temp_cascaded_table(1).primary_unit_of_measure IS
			NULL THEN
			temp_cascaded_table(1).primary_unit_of_measure :=
			  x_ShipmentDistributionRec.unit_meas_lookup_code;
		     END IF;
		     temp_cascaded_table(current_n).primary_quantity :=
		       temp_cascaded_table(current_n).primary_quantity +
		       /* Bug 4004656
		       rcv_transactions_interface_sv.convert_into_correct_qty(
                                     x_remaining_quantity,
                                     temp_cascaded_table(1).unit_of_measure,
                                     temp_cascaded_table(1).item_id,
                                     temp_cascaded_table(1).primary_unit_of_measure); */
		       rcv_transactions_interface_sv.convert_into_correct_qty(
		                     l_rem_qty_trans_uom,
				     temp_cascaded_table(1).unit_of_measure,
                                     temp_cascaded_table(1).item_id,
                                     temp_cascaded_table(1).primary_unit_of_measure);
	              --End of fix for Bug 4004656

		     temp_cascaded_table(current_n).tax_amount :=
		       round(temp_cascaded_table(current_n).quantity * tax_amount_factor,6);

                     -- Bug 6365270 - Modified the if condition to check for blind receiving flag
		     if (x_qty_rcv_exception_code = 'WARNING' AND NVL(l_blind_receiving_flag,'N') <> 'Y') then
			-- bug 2787530
			IF temp_cascaded_table(current_n).error_status = 'W' THEN
			   temp_cascaded_table(current_n).error_message :=
			     'INV_RCV_GEN_TOLERANCE_EXCEED';
			 ELSE
			   temp_cascaded_table(current_n).error_status := 'W';
			   temp_cascaded_table(current_n).error_message :=
			     'INV_RCV_QTY_OVER_TOLERANCE';
			END IF;
		     -- end if; -- Commented out as part of bug 6365270

                     -- Bug 6365270 - Modified the elsif condition to check for blind receiving flag
                     -- and the transaction type
		     elsif ((x_qty_rcv_exception_code = 'REJECT'  AND NVL(l_blind_receiving_flag,'N') <> 'Y') OR
                            (x_qty_rcv_exception_code = 'REJECT' AND x_cascaded_table(n).transaction_type ='STD_DELIVER'))                             then

		     x_cascaded_table(n).error_status := 'E';
            -- CLM project, bug 9403291
                if PO_CLM_INTG_GRP.is_clm_po(null,null,x_shipmentdistributionrec.line_location_id,null) = 'Y' then
                   x_cascaded_table(n).error_message := 'INV_RCV_QTY_OVER_FUNDED_LIMIT';
                else
                    x_cascaded_table(n).error_message := 'INV_RCV_QTY_OVER_TOLERANCE';
                end if;
             -- End of CLM project, bug 9403291

        	         if temp_cascaded_table.count > 0 then
		  	    for i in 1..temp_cascaded_table.count loop
			    temp_cascaded_table.delete(i);
			    end loop;
		         end if;
		     end if;

		 ELSE -- for if  remaining_qty > 0 and not x_first_trans
		   IF l_print_debug = 1 THEN
		      IF (l_debug = 1) THEN
   		      print_debug('first transaction and qty remains so over tolerance',4);
		      END IF;
		   END IF;

		   x_cascaded_table(n).error_status := 'E';
		   x_cascaded_table(n).error_message := 'INV_RCV_QTY_OVER_TOLERANCE';

		  if rows_fetched = 0 then
		     x_cascaded_table(n).error_message := 'INV_RCV_NO_ROWS';
		     IF l_print_debug = 1 THEN
			IF (l_debug = 1) THEN
   			print_debug('matching_logic - No rows were retrieved from cursor ', 4);
			END IF;
		     END IF;
		   elsif x_first_trans then
                     -- Bug# 5739706
                     -- Tolerance could also fail because of Receipt date being breached
                     -- Hence we need to display the appropriate message.
                     if (l_date_reject) then
                       x_cascaded_table(n).error_message := 'INV_RCV_DATE_OVER_TOLERANCE';
                     else
                       x_cascaded_table(n).error_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
                     end if;

		     IF l_print_debug = 1 THEN
			IF (l_debug = 1) THEN
   			print_debug('matching_logic -  No rows were cascaded', 4);
			END IF;
		     END IF;
		  end if;

		  -- Delete the temp_cascaded_table just to be sure
		  if temp_cascaded_table.count > 0 then
		     for i in 1..temp_cascaded_table.count loop
			temp_cascaded_table.delete(i);
		     end loop;
		  end if;
	       END IF;
	     else
	       null;

	    end if; -- x_remaining_qty > 0
	    -- close cursors
	    if shipments%isopen then
	       close shipments;
	    end if;

	    if count_shipments%isopen then
	       close count_shipments;
	    end if;

	    IF asn_shipments%isopen THEN
	       CLOSE asn_shipments;
	    END IF;

	    IF count_asn_shipments%isopen THEN
	       CLOSE count_asn_shipments;
	    END IF;

	    IF asn_shipments_w_po%isopen THEN
	       CLOSE asn_shipments_w_po;
	    END IF;

	    IF count_asn_shipments_w_po%isopen THEN
	       CLOSE count_asn_shipments_w_po;
	    END IF;


-- For Bug 7440217 Closing the cursors
	    IF lcm_shipments%isopen THEN
	       CLOSE lcm_shipments;
	    END IF;

	    IF count_lcm_shipments%isopen THEN
	       CLOSE count_lcm_shipments;
	    END IF;

	    IF lcm_shipments_w_po%isopen THEN
	       CLOSE lcm_shipments_w_po;
	    END IF;

	    IF count_lcm_shipments_w_po%isopen THEN
	       CLOSE count_lcm_shipments_w_po;
	    END IF;
-- End for Bug 7440217

	    if distributions%isopen then
	       close distributions;
	    end if;

	    if count_distributions%isopen then
	       close count_distributions;
	    end if;

	    IF std_distributions%isopen THEN
	       CLOSE std_distributions;
	    END IF;

	    IF count_std_distributions%isopen THEN
	       CLOSE count_std_distributions;
	    END IF;

--4364407
	    IF std_distributions_exp%isopen THEN
	       CLOSE std_distributions_exp;
	    END IF;
	    IF count_std_distributions_exp%isopen THEN
	       CLOSE count_std_distributions_exp;
	    END IF;
--4364407
	    exit;

	 end if; -- if (lastrecord or x_remaining_quantity <= 0)

	 -- eliminate the row if it fails the date check
	 IF l_print_debug = 1 THEN
	    IF (l_debug = 1) THEN
   	    print_debug('expected_receipt_date:'||temp_cascaded_table(1).expected_receipt_date,4);
   	    print_debug('ship_to_location_id:'||temp_cascaded_table(1).ship_to_location_id,4);
   	    print_debug('promised_date:'||x_shipmentdistributionrec.promised_date,4);
   	    print_debug('days_early_receipt_allowed:'||x_shipmentdistributionrec.days_early_receipt_allowed,4);
   	    print_debug('days_late_receipt_allowed:'||x_shipmentdistributionrec.days_late_receipt_allowed,4);
   	    print_debug('enforce_ship_to_location_code:'||x_shipmentdistributionrec.enforce_ship_to_location_code,4);
   	    print_debug('ship_to_location_id:'||x_shipmentdistributionrec.ship_to_location_id,4);
	    END IF;
	 END IF;
	 if ((temp_cascaded_table(1).expected_receipt_date is not null) and
	      (x_cascaded_table(n).transaction_type <> 'STD_DELIVER')) then --BUG3210820
	    if (x_ShipmentDistributionRec.promised_date is not null) then
               -- bug 2750081
	       -- the null days early allowed and days late allowed should
	       -- be interpreted as infinite and not zero.
	       IF x_ShipmentDistributionRec.days_early_receipt_allowed IS NULL THEN
		  low_range_date := Trunc(temp_cascaded_table(1).expected_receipt_date);
		else
		  low_range_date  := x_ShipmentDistributionRec.promised_date -
		                        nvl(x_ShipmentDistributionRec.days_early_receipt_allowed,0);
	       END IF;
	       IF x_ShipmentDistributionRec.days_late_receipt_allowed IS NULL THEN
		  high_range_date := Trunc(temp_cascaded_table(1).expected_receipt_date);
		else
		  high_range_date :=  x_ShipmentDistributionRec.promised_date +
		                        nvl(x_ShipmentDistributionRec.days_late_receipt_allowed,0);
	       END IF;
	     else
	       IF x_ShipmentDistributionRec.days_early_receipt_allowed IS NULL THEN
		  low_range_date :=  Trunc(temp_cascaded_table(1).expected_receipt_date);
		else
		  low_range_date  :=  x_sysdate -
		                         nvl(x_ShipmentDistributionRec.days_early_receipt_allowed,0);
	       END IF;
	       IF x_ShipmentDistributionRec.days_late_receipt_allowed IS NULL THEN
		  high_range_date :=  Trunc(temp_cascaded_table(1).expected_receipt_date);
		else
		  high_range_date :=  x_sysdate +
		                         nvl(x_ShipmentDistributionRec.days_late_receipt_allowed,0);
	       END IF;
	    end if;
	    print_debug('Low date:'||low_range_date,4);
	    print_debug('High date:'||high_range_date,4);
	    if (Trunc(temp_cascaded_table(1).expected_receipt_date) >= low_range_date and
		Trunc(temp_cascaded_table(1).expected_receipt_date) <= high_range_date) then
	        x_ShipmentDistributionRec.receipt_days_exception_code := 'NONE';
	    end if;
	  else
	    x_ShipmentDistributionRec.receipt_days_exception_code := 'NONE';
	 end if;
	 if x_ShipmentDistributionRec.receipt_days_exception_code is null then
	    x_ShipmentDistributionRec.receipt_days_exception_code := 'NONE';
	 end if;

	 -- if the row does not fall within the date tolerance we just
	 -- leave it aside and then take the next row. If the date
	 -- tolerance is just set to warning then we continue with this
	 -- row. The same applies to the ship to location check too.


	 -- Check ship_to_location enforcement
	 IF x_shipmentdistributionrec.enforce_ship_to_location_code <> 'NONE' THEN
	    IF nvl(temp_cascaded_table(1).ship_to_location_id,x_ShipmentDistributionRec.ship_to_location_id) = x_ShipmentDistributionRec.ship_to_location_id THEN
	       x_shipmentdistributionrec.enforce_ship_to_location_code := 'NONE';
	    END IF;
	 END IF;

	 IF l_print_debug = 1 THEN
	    IF (l_debug = 1) THEN
   	    print_debug('receipt_days_exception_code:'||x_shipmentdistributionrec.receipt_days_exception_code,4);
   	    print_debug('enforce_ship_to_location_code:'||x_shipmentdistributionrec.enforce_ship_to_location_code,4);
	    END IF;
	 END IF;
         -- Bug# 5739706
         -- Need to add the appropriate error message if the receipt date tolerance has been
         -- breached and the receipt_days_exception_code = 'REJECT'
         if (x_ShipmentDistributionRec.receipt_days_exception_code = 'REJECT') then
           l_date_reject := TRUE;
         elsif (x_ShipmentDistributionRec.receipt_days_exception_code IN ('NONE', 'WARNING')) and
	   (x_ShipmentDistributionRec.enforce_ship_to_location_code IN ('NONE','WARNING')) THEN
	    -- derived by the date tolerance procedure
	    -- derived by shipto_enforcement

	    insert_into_table := FALSE;
	    already_allocated_qty := 0;
	    IF l_print_debug = 1 THEN
	       IF insert_into_table THEN
		  IF (l_debug = 1) THEN
   		  print_debug('insert_into_table:TRUE',4);
		  END IF;
		ELSE
		  IF (l_debug = 1) THEN
   		  print_debug('insert_into_table:FLASE',4);
		  END IF;
	       END IF;
	       IF (l_debug = 1) THEN
   	       print_debug('already_allocated_qty:'||already_allocated_qty,4);
	       END IF;
	    END IF;
	    -- Get the available quantity for the shipment or distribution
	    -- that is available for allocation by this interface transaction
	    IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN
	       IF l_print_debug = 1 THEN
		  IF (l_debug = 1) THEN
   		  print_debug('Receive',4);
   		  print_debug('line_location_id:'||x_ShipmentDistributionRec.line_location_id,4);
		  END IF;
	       END IF;
	       rcv_quantities_s.get_available_quantity(
						       'RECEIVE',
							       x_ShipmentDistributionRec.line_location_id,
						       'VENDOR',
						       null,
						       null,
						       null,
						       x_converted_trx_qty,
						       x_tolerable_qty,
						       x_ShipmentDistributionRec.unit_meas_lookup_code);


				-- Bug 9403291, CLM Project
				If (l_partial_funded_flag = 'N') THEN
				   po_clm_intg_grp.get_funding_info( p_po_header_id            => NULL,
                                            p_po_line_id              => NULL,
                                            p_line_location_id        => x_ShipmentDistributionRec.line_location_id,
                                            p_po_distribution_id      => null,
                                            x_distribution_type       => l_distribution_type,
                                            x_matching_basis          => l_matching_basis,
                                            x_accrue_on_receipt_flag  => l_accrue_on_receipt_flag,
                                            x_code_combination_id     => l_code_combination_id,
                                            x_budget_account_id       => l_budget_account_id,
                                            x_partial_funded_flag     => l_partial_funded_flag,
                                            x_unit_meas_lookup_code   => l_unit_meas_lookup_code,
                                            x_funded_value            => l_funded_value,
                                            x_quantity_funded         => l_quantity_funded,
                                            x_amount_funded           => l_amount_funded,
                                            x_quantity_received       => l_quantity_received,
                                            x_amount_received         => l_amount_received,
                                            x_quantity_delivered      => l_quantity_delivered,
                                            x_amount_delivered        => l_amount_delivered,
                                            x_quantity_billed         => l_quantity_billed,
                                            x_amount_billed           => l_amount_billed,
                                            x_quantity_cancelled      => l_quantity_cancelled,
                                            x_amount_cancelled        => l_amount_cancelled,
                                            x_return_status           => l_return_status_clm
                                            );
           l_partial_funded_flag := nvl(l_partial_funded_flag,'N');
        END IF;
				-- End of Bug 9403291, CLM Project

	        -- Bug 4004656-Added the following two assignment statements
	           l_trx_qty_po_uom := x_converted_trx_qty;
		   l_tol_qty_po_uom := x_tolerable_qty;
		-- End of fix for Bug 4004656

	       IF l_print_debug = 1 THEN
		  IF (l_debug = 1) THEN
  	        --print_debug('x_converted_trx_qty:'||x_converted_trx_qty,4);  --Bug 4004656
		  print_debug('l_trx_qty_po_uom:'||l_trx_qty_po_uom,4);        --Bug 4004656
	        --print_debug('x_remaining_quantity:'||x_remaining_quantity,4);--Bug 4004656
   		  print_debug('l_rem_qty_trans_uom:'||l_rem_qty_trans_uom,4);  --Bug 4004656
	        --print_debug('x_tolerable_qty:'||x_tolerable_qty,4);          --Bug 4004656
		  print_debug('l_tol_qty_po_uom:'||l_tol_qty_po_uom,4);        --Bug 4004656
   	          print_debug('unit_of_measure:'||x_ShipmentDistributionRec.unit_meas_lookup_code,4);
		  END IF;
	       END IF;
	       -- If qtys have already been allocated for this po_line_location_id
	       -- during a cascade process which has not been written to the db yet,
	       -- we need to decrement it from the total available quantity
	       -- We traverse the actual pl/sql table and accumulate the quantity by
	       -- matching the po_line_location_id

	       l_asn_received_qty := 0;
	       IF n > 1 THEN    -- We will do this for all rows except the 1st
		  FOR i in 1..(n-1) LOOP
		     IF x_cascaded_table(i).po_line_location_id =
		       x_ShipmentDistributionRec.line_location_id THEN
			IF l_print_debug = 1 THEN
			   IF (l_debug = 1) THEN
   			   print_debug('Already allocated some qty for this po',4);
			   END IF;
			END IF;
			already_allocated_qty := already_allocated_qty +
			  x_cascaded_table(i).source_doc_quantity;
			IF p_shipment_header_id IS NOT NULL THEN
			   l_asn_received_qty := already_allocated_qty;
			END IF;
		     END IF;
		  END LOOP;
	       END IF;

	     ELSIF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
	       IF l_print_debug = 1 THEN
		  IF (l_debug = 1) THEN
   		  print_debug('Direct delivery',4);
   		  print_debug('po_distribution_id:'||x_ShipmentDistributionRec.po_distribution_id,4);
		  END IF;
	       END IF;
	       rcv_quantities_s.get_available_quantity(
						       'DIRECT RECEIPT',
						       x_ShipmentDistributionRec.po_distribution_id,
						       'VENDOR',
						       null,
						       null,
						       null,
						       x_converted_trx_qty,
						       x_tolerable_qty,
						       x_ShipmentDistributionRec.unit_meas_lookup_code);

				 -- Bug 9403291, CLM Project
				If (l_partial_funded_flag = 'N') THEN
				   po_clm_intg_grp.get_funding_info( p_po_header_id            => NULL,
                                            p_po_line_id              => NULL,
                                            p_line_location_id        => null,
                                            p_po_distribution_id      => x_ShipmentDistributionRec.po_distribution_id,
                                            x_distribution_type       => l_distribution_type,
                                            x_matching_basis          => l_matching_basis,
                                            x_accrue_on_receipt_flag  => l_accrue_on_receipt_flag,
                                            x_code_combination_id     => l_code_combination_id,
                                            x_budget_account_id       => l_budget_account_id,
                                            x_partial_funded_flag     => l_partial_funded_flag,
                                            x_unit_meas_lookup_code   => l_unit_meas_lookup_code,
                                            x_funded_value            => l_funded_value,
                                            x_quantity_funded         => l_quantity_funded,
                                            x_amount_funded           => l_amount_funded,
                                            x_quantity_received       => l_quantity_received,
                                            x_amount_received         => l_amount_received,
                                            x_quantity_delivered      => l_quantity_delivered,
                                            x_amount_delivered        => l_amount_delivered,
                                            x_quantity_billed         => l_quantity_billed,
                                            x_amount_billed           => l_amount_billed,
                                            x_quantity_cancelled      => l_quantity_cancelled,
                                            x_amount_cancelled        => l_amount_cancelled,
                                            x_return_status           => l_return_status_clm
                                            );
           l_partial_funded_flag := nvl(l_partial_funded_flag,'N');
        END IF;
				-- End of Bug 9403291, CLM Project
	       --BUG #3325627
	       --	       x_tolerable_qty := x_converted_trx_qty;

	        -- Bug 4004656-Added the following two assignment statements
	           l_trx_qty_po_uom := x_converted_trx_qty;
		   l_tol_qty_po_uom := x_tolerable_qty;
		-- End of fix for Bug 4004656

	       IF l_print_debug = 1 THEN
		  IF (l_debug = 1) THEN
   	      --  print_debug('x_converted_trx_qty:'||x_converted_trx_qty,4);  --Bug 4004656
		  print_debug('l_trx_qty_po_uom:'||l_trx_qty_po_uom,4);        --Bug 4004656
	      --  print_debug('x_remaining_quantity:'||x_remaining_quantity,4);--Bug 4004656
   		  print_debug('l_rem_qty_trans_uom:'||l_rem_qty_trans_uom,4);  --Bug 4004656
	      --  print_debug('x_tolerable_qty:'||x_tolerable_qty,4);          --Bug 4004656
	          print_debug('l_tol_qty_po_uom:'||l_tol_qty_po_uom,4);        --Bug 4004656
   	          print_debug('unit_of_measure:'||x_ShipmentDistributionRec.unit_meas_lookup_code,4);
		  END IF;
	       END IF;
	       -- If qtys have already been allocated for this po_distribution_id
	       -- during
	       -- a cascade process which has not been written to the db yet, we need to
	       -- decrement it from the total available quantity
	       -- We traverse the actual pl/sql table and accumulate the quantity by
	       -- matching the
	       -- po_distribution_id
	       IF n > 1 THEN    -- We will do this for all rows except the 1st
		  FOR i in 1..(n-1) LOOP
		     IF x_cascaded_table(i).po_distribution_id =
		       x_ShipmentDistributionRec.po_distribution_id THEN
			IF l_print_debug = 1 THEN
			   IF (l_debug = 1) THEN
   			   print_debug('Already allocated some qty for this po',4);
			   END IF;
			END IF;
			already_allocated_qty := already_allocated_qty +
			  x_cascaded_table(i).source_doc_quantity;
		     END IF;
		  END LOOP;
	       END IF;

	     ELSIF (x_cascaded_table(n).transaction_type = 'STD_DELIVER') THEN
	       IF l_print_debug = 1 THEN
		  IF (l_debug = 1) THEN
   		  print_debug('standard delivery',4);
   		  print_debug('po_distribution_id:'||x_ShipmentDistributionRec.po_distribution_id,4);
   		  print_debug('rcv_transaction_id:'||x_ShipmentDistributionRec.rcv_transaction_id,4);
		  END IF;
	       END IF;
	       rcv_quantities_s.get_available_quantity(
						       'STANDARD DELIVER',
						       x_ShipmentDistributionRec.po_distribution_id,
						       'VENDOR',
						       null,
						       x_ShipmentDistributionRec.rcv_transaction_id,
						       null,
						       x_converted_trx_qty,
						       x_tolerable_qty,
						       x_ShipmentDistributionRec.unit_meas_lookup_code);

				-- Bug 9403291, CLM Project
				If (l_partial_funded_flag = 'N') THEN
				   po_clm_intg_grp.get_funding_info( p_po_header_id            => NULL,
                                            p_po_line_id              => NULL,
                                            p_line_location_id        => null,
                                            p_po_distribution_id      => x_ShipmentDistributionRec.po_distribution_id,
                                            x_distribution_type       => l_distribution_type,
                                            x_matching_basis          => l_matching_basis,
                                            x_accrue_on_receipt_flag  => l_accrue_on_receipt_flag,
                                            x_code_combination_id     => l_code_combination_id,
                                            x_budget_account_id       => l_budget_account_id,
                                            x_partial_funded_flag     => l_partial_funded_flag,
                                            x_unit_meas_lookup_code   => l_unit_meas_lookup_code,
                                            x_funded_value            => l_funded_value,
                                            x_quantity_funded         => l_quantity_funded,
                                            x_amount_funded           => l_amount_funded,
                                            x_quantity_received       => l_quantity_received,
                                            x_amount_received         => l_amount_received,
                                            x_quantity_delivered      => l_quantity_delivered,
                                            x_amount_delivered        => l_amount_delivered,
                                            x_quantity_billed         => l_quantity_billed,
                                            x_amount_billed           => l_amount_billed,
                                            x_quantity_cancelled      => l_quantity_cancelled,
                                            x_amount_cancelled        => l_amount_cancelled,
                                            x_return_status           => l_return_status_clm
                                            );
           l_partial_funded_flag := nvl(l_partial_funded_flag,'N');
        END IF;
				-- End of Bug 9403291, CLM Project
	       --x_tolerable_qty := x_converted_trx_qty; --Bug 4004656
               -- Bug 4004656-Added the following two assignment statements
	           l_trx_qty_po_uom := x_converted_trx_qty;
		   l_tol_qty_po_uom := x_tolerable_qty;
		   l_tol_qty_po_uom := l_trx_qty_po_uom;
	      -- End of fix for Bug 4004656

	       IF l_print_debug = 1 THEN
		  IF (l_debug = 1) THEN
	      --  print_debug('x_converted_trx_qty:'||x_converted_trx_qty,4);  --Bug 4004656
		  print_debug('l_trx_qty_po_uom:'||l_trx_qty_po_uom,4);        --Bug 4004656
	      --  print_debug('x_remaining_quantity:'||x_remaining_quantity,4);--Bug 4004656
   		  print_debug('l_rem_qty_trans_uom:'||l_rem_qty_trans_uom,4);  --Bug 4004656
	      --  print_debug('x_tolerable_qty:'||x_tolerable_qty,4);          --Bug 4004656
	          print_debug('l_tol_qty_po_uom:'||l_tol_qty_po_uom,4);        --Bug 4004656
   	          print_debug('unit_of_measure:'||x_ShipmentDistributionRec.unit_meas_lookup_code,4);
		  END IF;
	       END IF;
	       -- If qtys have already been allocated for this po_distribution_id
	       -- during
	       -- a cascade process which has not been written to the db yet, we need to
	       -- decrement it from the total available quantity
	       -- We traverse the actual pl/sql table and accumulate the quantity by
	       -- matching the
	       -- po_distribution_id
	       IF n > 1 THEN    -- We will do this for all rows except the 1st
		  FOR i in 1..(n-1) LOOP
		     IF x_cascaded_table(i).po_distribution_id =
		       x_ShipmentDistributionRec.po_distribution_id AND
		       x_cascaded_table(i).parent_transaction_id =
		       x_ShipmentDistributionRec.rcv_transaction_id THEN
			IF l_print_debug = 1 THEN
			   IF (l_debug = 1) THEN
   			   print_debug('Already allocated some qty for this po',4);
			   END IF;
			END IF;
			already_allocated_qty := already_allocated_qty +
			  x_cascaded_table(i).source_doc_quantity;
		     END IF;
		  END LOOP;
	       END IF;
	    END IF;
	    IF l_print_debug = 1 THEN
	       IF (l_debug = 1) THEN
   	       print_debug('Total already allocated qty:'||already_allocated_qty,4);
	       END IF;
	    END IF;
	    -- if qty has already been allocated then reduce available and tolerable
	    -- qty by the allocated amount

	    /* Bug 4004656-Modified the block with the new quantity fileds.
	    IF nvl(already_allocated_qty,0) > 0 THEN
	       x_converted_trx_qty := x_converted_trx_qty - already_allocated_qty;
	       x_tolerable_qty     := x_tolerable_qty     - already_allocated_qty;
	       IF x_converted_trx_qty < 0 THEN
		  x_converted_trx_qty := 0;
	       END IF;
	       IF x_tolerable_qty < 0 THEN
		  x_tolerable_qty := 0;
	       END IF;
	    END IF; */

	    IF nvl(already_allocated_qty,0) > 0 THEN
	       l_trx_qty_po_uom := l_trx_qty_po_uom - already_allocated_qty;
	       l_tol_qty_po_uom := l_tol_qty_po_uom - already_allocated_qty;
	       IF l_trx_qty_po_uom < 0 THEN
		  l_trx_qty_po_uom := 0;
	       END IF;
	       IF l_tol_qty_po_uom < 0 THEN
		  l_tol_qty_po_uom := 0;
		END IF;
	     END IF;
	    -- End of fix for Bug 4004656

	    -- We can use the first record since the item_id and uom are not going to
	    -- change
	    -- Check that we can convert between ASN-> PO  uom
	    --                                   PO -> ASN uom
	    --                                   PO -> PRIMARY uom
	    -- If any of the conversions fail then we cannot use that record

	  --x_remaining_qty_po_uom := 0;  -- initialize --Bug 4004656
	    l_rcv_qty_trans_uom    := 0;		--Bug 4004656
	    l_rcv_qty_po_uom       := 0;		--Bug 4004656
	    po_asn_uom_qty         := 0;  -- initialize
	    po_primary_uom_qty     := 0;  -- initialize

	    -- converts from temp_cascaded_table(1).unit_of_measure to
	    -- x_ShipmentDistributionRec.unit_meas_lookup_code
	    /* Bug 4004656 -Commented out the conversion that is being done
	            for the received quantity to the uom on the PO.
		    Retained it in the transaction uom through the variable l_rcv_qty_trans_uom
		    by assigning the value of the remaining quantity l_rem_qty_trans_uom
		    which is already in the transaciton uom */
	   /* x_remaining_qty_po_uom :=
	      rcv_transactions_interface_sv.convert_into_correct_qty(x_remaining_quantity,
								     temp_cascaded_table(1).unit_of_measure,
								     temp_cascaded_table(1).item_id,
								     x_ShipmentDistributionRec.unit_meas_lookup_code); */

	   l_rcv_qty_trans_uom := l_rem_qty_trans_uom ; --Bug 4004656

	    IF l_print_debug = 1 THEN
	       /* Bug 4004656 - Printed debug messages for the quantities in the
	          new quantity variables
	       IF (l_debug = 1) THEN
   	       print_debug('x_remaining_qty_po_uom:'||x_remaining_qty_po_uom,4);
   	       print_debug('x_converted_trx_qty:'||x_converted_trx_qty,4);
   	       print_debug('x_tolerable_qty:'||x_tolerable_qty,4);
	       END IF; */
	       IF (l_debug = 1) THEN
   	       print_debug('l_rcv_qty_trans_uom:'||l_rcv_qty_trans_uom,4);
   	       print_debug('l_trx_qty_po_uom:'||l_trx_qty_po_uom,4);
   	       print_debug('l_tol_qty_po_uom:'||l_tol_qty_po_uom,4);
	       END IF;
               --End of fix for Bug 4004656
	    END IF;

	   -- IF x_remaining_qty_po_uom <> 0 THEN  --Bug 4004656
	       IF round(l_rcv_qty_trans_uom,5)   <> 0 THEN  --Bug 4004656, 4747997
	       -- If last row set available = tolerable - shipped
	       -- else                      = available - shipped
	       -- Debug: Were a bit troubled here.  How do we know if the shipment
	       -- is taken into account here.  I guess if the transaction
	       -- has the shipment line id then we should take the quantity from
	       -- the shipped quantity.  Need to walk through the different
	       -- scenarios
	       IF p_shipment_header_id IS NULL THEN
		  l_asn_received_qty := 0;
	       END IF;
	       IF l_print_debug = 1 THEN
		  IF (l_debug = 1) THEN
   		  print_debug('p_shipment_header_id:'||p_shipment_header_id,4);
   		  print_debug('ASN Receipt qty:'||l_asn_received_qty,4);
		  END IF;
	       END IF;

	      if rows_fetched = x_record_count then
		 -- Bug 2496230
		 -- For asn receipts, the shipped quantity also includes
		 -- the current quantity being received. So the converted
		 -- and the tolerable quantity should add the
		 -- l_asn_received_qty as already_allocated_qty has been
		 -- reduced from the converted and tolerable qty above.
		 -- Otherwise it will resuly in double decrementing.
	         -- x_converted_trx_qty := x_tolerable_qty -  --Bug 4004656
		   l_trx_qty_po_uom    := l_tol_qty_po_uom -
		   nvl(x_ShipmentDistributionRec.quantity_shipped,0) +
		   l_asn_received_qty;
	       else
		-- x_converted_trx_qty := x_converted_trx_qty -  --Bug 4004656
		   l_trx_qty_po_uom := 	l_trx_qty_po_uom -
		   nvl(x_ShipmentDistributionRec.quantity_shipped,0) +
		   l_asn_received_qty;
	      end if;

	      /* Bug 4004656 -Modified the condition with the new quantity field variable values
	      if x_converted_trx_qty > 0  then
		 if (x_converted_trx_qty < x_remaining_qty_po_uom) then
		    -- compare like uoms

		    x_remaining_qty_po_uom  := x_remaining_qty_po_uom -
		      x_converted_trx_qty;

		    -- change asn uom qty so both qtys are in sync

		    x_remaining_quantity :=
		      rcv_transactions_interface_sv.convert_into_correct_qty(x_remaining_qty_po_uom,
                                  x_ShipmentDistributionRec.unit_meas_lookup_code,
                                  temp_cascaded_table(1).item_id,
                                  temp_cascaded_table(1).unit_of_measure);

		    insert_into_table := TRUE;
		  else
		    x_converted_trx_qty  := x_remaining_qty_po_uom;
		    insert_into_table := TRUE;
		    x_remaining_qty_po_uom := 0;
		    x_remaining_quantity   := 0;

		 end if;
		 IF l_print_debug = 1 THEN
		    IF (l_debug = 1) THEN
   		    print_debug('x_remaining_qty_po_uom:'||x_remaining_qty_po_uom,4);
   		    print_debug('x_converted_trx_qty:'||x_converted_trx_qty,4);
   		    print_debug('x_remaining_quantity:'||x_remaining_quantity,4);
		    END IF;
		 END IF;

	       else  -- no qty for this record but if last row we need it
		 IF l_print_debug = 1 THEN
		    IF (l_debug = 1) THEN
   		    print_debug('no qty for this record but if last row we need it',4);
		    END IF;
		 END IF;
		 if rows_fetched = x_record_count then
		    -- last row needs to be inserted anyway
		    -- so that the row can be used based on qty tolerance
		    -- checks

		    insert_into_table := TRUE;
		    x_converted_trx_qty := 0;

		  else
		    x_remaining_qty_po_uom := 0;
		    -- we may have a diff uom on the next iteration
		    insert_into_table := FALSE;
		 end if;
		 IF l_print_debug = 1 THEN
		    IF insert_into_table THEN
		       IF (l_debug = 1) THEN
   		       print_debug('insert_into_table:TRUE',4);
		       END IF;
		     ELSE
		       IF (l_debug = 1) THEN
   		       print_debug('insert_into_table:FLASE',4);
		       END IF;
		    END IF;
		 END IF;

	      end if; */
	    if l_trx_qty_po_uom > 0  then
	         --Added the following code
	         l_trx_qty_trans_uom:=
	         rcv_transactions_interface_sv.convert_into_correct_qty
	         					            (l_trx_qty_po_uom,
	      							     x_ShipmentDistributionRec.unit_meas_lookup_code,
	      							     temp_cascaded_table(1).item_id,
								     temp_cascaded_table(1).unit_of_measure);
   	        IF l_print_debug = 1 THEN

		  IF (l_debug = 1) THEN
   		  print_debug('l_trx_qty_trans_uom:'||l_trx_qty_trans_uom,4);
		  END IF;

		END IF;

	         if (round(l_trx_qty_trans_uom,5) < round(l_rcv_qty_trans_uom,5)) then --Bug 4747997
		    -- compare like uoms which is the transaction uom
		      l_rcv_qty_trans_uom   := l_rcv_qty_trans_uom - l_trx_qty_trans_uom;
		      l_rcv_qty_po_uom:=  rcv_transactions_interface_sv.convert_into_correct_qty(l_rcv_qty_trans_uom,
		      									temp_cascaded_table(1).unit_of_measure,
		      									temp_cascaded_table(1).item_id,
									 		x_ShipmentDistributionRec.unit_meas_lookup_code);


		    -- change asn uom qty so both qtys are in sync
		    l_rem_qty_trans_uom := l_rcv_qty_trans_uom ;
		    insert_into_table := TRUE;
		  else
		    l_trx_qty_trans_uom  :=  l_rcv_qty_trans_uom;
		    insert_into_table    := TRUE;
		    l_rcv_qty_trans_uom  := 0;
		    l_rcv_qty_po_uom     := 0;
		    l_rem_qty_trans_uom  := 0;

		 end if;
		 IF l_print_debug = 1 THEN
		    IF (l_debug = 1) THEN
   		    print_debug('l_rcv_qty_trans_uom:'||l_rcv_qty_trans_uom,4);
   		    print_debug('l_rcv_qty_po_uom:'||l_rcv_qty_po_uom,4);
   		    print_debug('l_trx_qty_trans_uom:'||l_trx_qty_trans_uom,4);
   		    print_debug('l_rem_qty_trans_uom:'||l_rem_qty_trans_uom,4);
		    END IF;
		 END IF;

	       else  -- no qty for this record but if last row we need it
		 IF l_print_debug = 1 THEN
		    IF (l_debug = 1) THEN
   		    print_debug('no qty for this record but if last row we need it',4);
		    END IF;
		 END IF;
		 if rows_fetched = x_record_count then
		    -- last row needs to be inserted anyway
		    -- so that the row can be used based on qty tolerance
		    -- checks

		    insert_into_table := TRUE;
		    l_trx_qty_trans_uom := 0;

		  else
		    l_rcv_qty_trans_uom := 0;
		    l_rcv_qty_po_uom := 0;
		    -- we may have a diff uom on the next iteration
		    insert_into_table := FALSE;

		 end if;

		 IF l_print_debug = 1 THEN
		    IF insert_into_table THEN
		       IF (l_debug = 1) THEN
   		       print_debug('insert_into_table:TRUE',4);
		       END IF;
		     ELSE
		       IF (l_debug = 1) THEN
   		       print_debug('insert_into_table:FLASE',4);
		       END IF;
		    END IF;
		 END IF;

	      end if;
	      --End of fix for bug 4004656

	    end if;   -- remaining_qty_po_uom <> 0



	    if insert_into_table then
	       if (x_first_trans) then
		  x_first_trans				:= FALSE;
		else
		  temp_cascaded_table(current_n) := temp_cascaded_table(current_n - 1);
	       end if;

	       --   source_doc_quantity -> in po_uom
	       --   primary_quantity    -> in primary_uom
	       --   cum_qty             -> in primary_uom
	       --   quantity,quantity_shipped -> in ASN uom

	       temp_cascaded_table(current_n).source_doc_quantity :=
		-- x_converted_trx_qty;   -- in po uom --Bug 4004656
		  rcv_transactions_interface_sv.convert_into_correct_qty(
                                 l_trx_qty_trans_uom ,
                                 temp_cascaded_table(current_n).unit_of_measure,
                                 temp_cascaded_table(current_n).item_id,
                                 x_ShipmentDistributionRec.unit_meas_lookup_code);
		-- End of fix for bug4004656

	       temp_cascaded_table(current_n).source_doc_unit_of_measure :=
		 x_ShipmentDistributionRec.unit_meas_lookup_code;

	       temp_cascaded_table(current_n).quantity :=
		  /* Bug 4004656
		              rcv_transactions_interface_sv.convert_into_correct_qty(
                       	       x_converted_trx_qty,
                               x_ShipmentDistributionRec.unit_meas_lookup_code,
                                 temp_cascaded_table(current_n).item_id,
                                 temp_cascaded_table(current_n).unit_of_measure);  -- in asn uom */
		   l_trx_qty_trans_uom ; --Bug 4004656

	       temp_cascaded_table(current_n).quantity_shipped	:=
		 temp_cascaded_table(current_n).quantity; -- in asn uom

	       -- Primary qty in Primary UOM
	       IF temp_cascaded_table(current_n).primary_unit_of_measure IS
		  NULL THEN
		  temp_cascaded_table(current_n).primary_unit_of_measure :=
		    x_ShipmentDistributionRec.unit_meas_lookup_code;
	       END IF;
	       temp_cascaded_table(current_n).primary_quantity :=
		/*  Bug 4004656
		               rcv_transactions_interface_sv.convert_into_correct_qty(
                               x_converted_trx_qty,
                               x_ShipmentDistributionRec.unit_meas_lookup_code,
                               temp_cascaded_table(current_n).item_id,
                               temp_cascaded_table(current_n).primary_unit_of_measure); */

	 	 	       rcv_transactions_interface_sv.convert_into_correct_qty(
                               l_trx_qty_trans_uom,
                               temp_cascaded_table(current_n).unit_of_measure,
                               temp_cascaded_table(current_n).item_id,
                               temp_cascaded_table(current_n).primary_unit_of_measure);

	       IF l_print_debug = 1 THEN
		  IF (l_debug = 1) THEN
   		  print_debug('source_doc_quantity:'||temp_cascaded_table(current_n).source_doc_quantity,4);
   		  print_debug('source_doc_unit_of_measure:'||temp_cascaded_table(current_n).source_doc_unit_of_measure,4);
   		  print_debug('quantity:'||temp_cascaded_table(current_n).quantity,4);
   		  print_debug('quantity_shipped:'||temp_cascaded_table(current_n).quantity_shipped,4);
   		  print_debug('primary_unit_of_measure:'||temp_cascaded_table(current_n).primary_unit_of_measure,4);
   		  print_debug('primary_quantity:'||temp_cascaded_table(current_n).primary_quantity,4);
		  END IF;
	       END IF;

	       temp_cascaded_table(current_n).tax_amount :=
		 round(temp_cascaded_table(current_n).quantity * tax_amount_factor,4);

	       IF l_print_debug = 1 THEN
		  IF (l_debug = 1) THEN
   		  print_debug('transaction_type:'||x_cascaded_table(n).transaction_type,4);
   		  print_debug('Selected record information',4);
   		  print_debug('qty_rcv_exception_code:'||x_shipmentdistributionrec.qty_rcv_exception_code,4);
   		  print_debug('enforce_ship_to_location_code:'||x_shipmentdistributionrec.enforce_ship_to_location_code,4);
   		  print_debug('receipt_days_exception_code:'||x_shipmentdistributionrec.receipt_days_exception_code,4);
		  END IF;
	       END IF;
	       IF x_shipmentdistributionrec.qty_rcv_exception_code IS NULL THEN
		  temp_cascaded_table(current_n).qty_rcv_exception_code := 'NONE';
		ELSE
		  temp_cascaded_table(current_n).qty_rcv_exception_code :=
		    x_shipmentdistributionrec.qty_rcv_exception_code;
	       END IF;

	        -- CLM project , bug 9403291
          if PO_CLM_INTG_GRP.is_clm_po(null,null,x_shipmentdistributionrec.line_location_id,null) = 'Y' and l_partial_funded_flag = 'Y' THEN
              temp_cascaded_table(current_n).qty_rcv_exception_code := 'REJECT';
          END IF;
         -- End of CLM project


	       temp_cascaded_table(current_n).po_line_location_id  :=
		 x_ShipmentDistributionRec.line_location_id;

	       IF x_ShipmentDistributionRec.enforce_ship_to_location_code =
		 'WARNING' AND (x_cascaded_table(n).transaction_type IN
		 ('RECEIVE', 'DELIVER')) THEN
		  -- bug 2787530
		  IF temp_cascaded_table(current_n).error_status = 'W' THEN
		     temp_cascaded_table(current_n).error_message :=
		       'INV_RCV_GEN_TOLERANCE_EXCEED';
		   ELSE
		     temp_cascaded_table(current_n).error_status := 'W';
		     temp_cascaded_table(current_n).error_message := 'INV_RCV_WARN_SHIP_TO_LOC';
		  END IF;
	       END IF;

	       IF x_ShipmentDistributionRec.receipt_days_exception_code =
		 'WARNING' AND (x_cascaded_table(n).transaction_type IN
		 ('RECEIVE', 'DELIVER')) THEN
		  -- bug 2787530
		  IF temp_cascaded_table(current_n).error_status = 'W' THEN
		     temp_cascaded_table(current_n).error_message :=
		       'INV_RCV_GEN_TOLERANCE_EXCEED';
		   ELSE
		     temp_cascaded_table(current_n).error_status := 'W';
		     temp_cascaded_table(current_n).error_message := 'INV_RCV_WARN_RECEIPT_DATE';
		  END IF;
	       END IF;
	       IF l_print_debug = 1 THEN
		  IF (l_debug = 1) THEN
   		  print_debug('line_location_id:'||temp_cascaded_table(current_n).po_line_location_id,4);
   		  print_debug('qty_rcv_exception_code:'||temp_cascaded_table(current_n).qty_rcv_exception_code,4);
   		  print_debug('tax_amount:'||temp_cascaded_table(current_n).tax_amount,4);
   		  print_debug('error_status:'||temp_cascaded_table(current_n).error_status,4);
   		  print_debug('error_message:'||temp_cascaded_table(current_n).error_message,4);
		  END IF;
	       END IF;
	       -- Copy the distribution specific information only if this is a
	       -- direct receipt.
	       IF (x_cascaded_table(n).transaction_type in ('DELIVER','STD_DELIVER')) THEN

		  temp_cascaded_table(current_n).po_distribution_id  :=
		    x_ShipmentDistributionRec.po_distribution_id;
		  temp_cascaded_table(current_n).parent_transaction_id  :=
		    x_ShipmentDistributionRec.rcv_transaction_id;
		  IF l_print_debug = 1 THEN
		     IF (l_debug = 1) THEN
   		     print_debug('po_distribution_id:'||temp_cascaded_table(current_n).po_distribution_id,4);
   		     print_debug('parent_transaction_id:'||temp_cascaded_table(current_n).parent_transaction_id,4);
		     END IF;
		  END IF;
	       END IF;

	       current_n := current_n + 1;

	    end if;
	 end if;
      end loop;

      -- current_n := current_n - 1;
      -- point to the last row in the record structure before going back

    else
      -- error_status and error_message are set after validate_quantity_shipped

      if x_cascaded_table(n).error_status in ('S','W','F') then
         x_cascaded_table(n).error_status	:= 'E';

        if (x_cascaded_table(n).error_message IS NULL) THEN

-- For Bug 7440217 Error Message for LCM doc failure
	   IF l_asn_type = 'ASN' THEN
             x_cascaded_table(n).error_message	:= 'RCV_ASN_NO_PO_LINE_LOCATION_ID';
	   ELSE
	     x_cascaded_table(n).error_message	:= 'RCV_LCM_NO_PO_LINE_LOCATION_ID';
	   END IF;
-- End for Bug 7440217

        END IF;
      end if;
      return;
  end if;       -- of (asn quantity_shipped was valid)

  if shipments%isopen then
     close shipments;
  end if;

  if count_shipments%isopen then
     close count_shipments;
  end if;

  IF asn_shipments%isopen THEN
     CLOSE asn_shipments;
  END IF;

  IF count_asn_shipments%isopen THEN
     CLOSE count_asn_shipments;
  END IF;

  IF asn_shipments_w_po%isopen THEN
     CLOSE asn_shipments_w_po;
  END IF;

  IF count_asn_shipments_w_po%isopen THEN
     CLOSE count_asn_shipments_w_po;
  END IF;

-- For Bug 7440217 Closing the cursors
  IF lcm_shipments%isopen THEN
     CLOSE lcm_shipments;
  END IF;

  IF count_lcm_shipments%isopen THEN
     CLOSE count_lcm_shipments;
  END IF;

  IF lcm_shipments_w_po%isopen THEN
     CLOSE lcm_shipments_w_po;
  END IF;

  IF count_lcm_shipments_w_po%isopen THEN
     CLOSE count_lcm_shipments_w_po;
  END IF;
-- End for Bug 7440217

  if distributions%isopen then
     close distributions;
  end if;

  if count_distributions%isopen then
     close count_distributions;
  end if;

  IF std_distributions%isopen THEN
     CLOSE std_distributions;
  END IF;

  IF count_std_distributions%isopen THEN
     CLOSE count_std_distributions;
  END IF;

--4364407
	    IF std_distributions_exp%isopen THEN
	       CLOSE std_distributions_exp;
	    END IF;
	    IF count_std_distributions_exp%isopen THEN
	       CLOSE count_std_distributions_exp;
	    END IF;
--4364407

 exception
    WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO rcv_transactions_sa;
        x_return_status := fnd_api.g_ret_sts_error;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

       if shipments%isopen then
          close shipments;
       end if;

       if count_shipments%isopen then
          close count_shipments;
       end if;

       IF asn_shipments%isopen THEN
	  CLOSE asn_shipments;
       END IF;

       IF count_asn_shipments%isopen THEN
	  CLOSE count_asn_shipments;
       END IF;

       IF asn_shipments_w_po%isopen THEN
	  CLOSE asn_shipments_w_po;
       END IF;

       IF count_asn_shipments_w_po%isopen THEN
	  CLOSE count_asn_shipments_w_po;
       END IF;

-- For Bug 7440217 Closing the cursors
       IF lcm_shipments%isopen THEN
	  CLOSE lcm_shipments;
       END IF;

       IF count_lcm_shipments%isopen THEN
	  CLOSE count_lcm_shipments;
       END IF;

       IF lcm_shipments_w_po%isopen THEN
	  CLOSE lcm_shipments_w_po;
       END IF;

       IF count_lcm_shipments_w_po%isopen THEN
	  CLOSE count_lcm_shipments_w_po;
       END IF;
-- End for Bug 7440217

       if distributions%isopen then
          close distributions;
       end if;

       if count_distributions%isopen then
          close count_distributions;
       end if;

       IF std_distributions%isopen THEN
	  CLOSE std_distributions;
       END IF;

       IF count_std_distributions%isopen THEN
	  CLOSE count_std_distributions;
       END IF;
--4364407
	    IF std_distributions_exp%isopen THEN
	       CLOSE std_distributions_exp;
	    END IF;
	    IF count_std_distributions_exp%isopen THEN
	       CLOSE count_std_distributions_exp;
	    END IF;
--4364407

     WHEN fnd_api.g_exc_unexpected_error THEN
	ROLLBACK TO rcv_transactions_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

       if shipments%isopen then
          close shipments;
       end if;

       if count_shipments%isopen then
          close count_shipments;
       end if;

       IF asn_shipments%isopen THEN
	  CLOSE asn_shipments;
       END IF;

       IF count_asn_shipments%isopen THEN
	  CLOSE count_asn_shipments;
       END IF;

       IF asn_shipments_w_po%isopen THEN
	  CLOSE asn_shipments_w_po;
       END IF;

       IF count_asn_shipments_w_po%isopen THEN
	  CLOSE count_asn_shipments_w_po;
       END IF;

-- For Bug 7440217 Closing the cursors
       IF lcm_shipments%isopen THEN
	  CLOSE lcm_shipments;
       END IF;

       IF count_lcm_shipments%isopen THEN
	  CLOSE count_lcm_shipments;
       END IF;

       IF lcm_shipments_w_po%isopen THEN
	  CLOSE lcm_shipments_w_po;
       END IF;

       IF count_lcm_shipments_w_po%isopen THEN
	  CLOSE count_lcm_shipments_w_po;
       END IF;
-- End for Bug 7440217


       if distributions%isopen then
          close distributions;
       end if;

       if count_distributions%isopen then
          close count_distributions;
       end if;

       IF std_distributions%isopen THEN
	  CLOSE std_distributions;
       END IF;

       IF count_std_distributions%isopen THEN
	  CLOSE count_std_distributions;
       END IF;
--4364407
	    IF std_distributions_exp%isopen THEN
	       CLOSE std_distributions_exp;
	    END IF;
	    IF count_std_distributions_exp%isopen THEN
	       CLOSE count_std_distributions_exp;
	    END IF;
--4364407

    WHEN OTHERS THEN
	ROLLBACK TO rcv_transactions_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
	IF SQLCODE IS NOT NULL THEN
	   inv_mobile_helper_functions.sql_error('INV_RCV_TXN_INTERFACE.matching_logic', l_progress, SQLCODE);
	END IF;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

       if shipments%isopen then
          close shipments;
       end if;

       if count_shipments%isopen then
          close count_shipments;
       end if;

       IF asn_shipments%isopen THEN
	  CLOSE asn_shipments;
       END IF;

       IF count_asn_shipments%isopen THEN
	  CLOSE count_asn_shipments;
       END IF;

       IF asn_shipments_w_po%isopen THEN
	  CLOSE asn_shipments_w_po;
       END IF;

       IF count_asn_shipments_w_po%isopen THEN
	  CLOSE count_asn_shipments_w_po;
       END IF;

-- For Bug 7440217 Closing the cursors
       IF lcm_shipments%isopen THEN
	  CLOSE lcm_shipments;
       END IF;

       IF count_lcm_shipments%isopen THEN
	  CLOSE count_lcm_shipments;
       END IF;

       IF lcm_shipments_w_po%isopen THEN
	  CLOSE lcm_shipments_w_po;
       END IF;

       IF count_lcm_shipments_w_po%isopen THEN
	  CLOSE count_lcm_shipments_w_po;
       END IF;
-- End for Bug 7440217


       if distributions%isopen then
          close distributions;
       end if;

       if count_distributions%isopen then
          close count_distributions;
       end if;

       IF std_distributions%isopen THEN
	  CLOSE std_distributions;
       END IF;

       IF count_std_distributions%isopen THEN
	  CLOSE count_std_distributions;
       END IF;
--4364407
	    IF std_distributions_exp%isopen THEN
	       CLOSE std_distributions_exp;
	    END IF;
	    IF count_std_distributions_exp%isopen THEN
	       CLOSE count_std_distributions_exp;
	    END IF;
--4364407

       x_cascaded_table(n).error_status	:= 'E';

 END matching_logic;
END INV_rcv_txn_interface;

/
