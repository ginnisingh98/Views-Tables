--------------------------------------------------------
--  DDL for Package Body INV_RCV_TXN_MATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_TXN_MATCH" AS
/* $Header: INVRCVMB.pls 120.7.12010000.8 2011/01/07 20:09:20 sfulzele ship $*/

 x_interface_type                       varchar2(25) := 'RCV-856';
 x_dummy_flag                           varchar2(1)  := 'Y';

 g_pkg_name CONSTANT VARCHAR2(30) := 'INV_RCV_TXN_MATCH';

PROCEDURE print_debug(p_err_msg VARCHAR2,
		      p_level NUMBER DEFAULT 4)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg,
      p_module => 'INV_RCV_TXN_MATCH',
      p_level => p_level);
   END IF;

--   dbms_output.put_line(p_err_msg);
END print_debug;


 PROCEDURE matching_logic
   (
     x_return_status        OUT        NOCOPY VARCHAR2
    ,x_msg_count            OUT        NOCOPY NUMBER
    ,x_msg_data             OUT        NOCOPY VARCHAR2
    ,x_cascaded_table    IN OUT NOCOPY INV_RCV_COMMON_APIS.cascaded_trans_tab_type
    ,n                   IN OUT	       NOCOPY BINARY_INTEGER
    ,temp_cascaded_table IN OUT NOCOPY INV_RCV_COMMON_APIS.cascaded_trans_tab_type
    ,p_receipt_num          IN         VARCHAR2
    ,p_match_type           IN         VARCHAR2
    ,p_lpn_id               IN         NUMBER)
   IS
      l_po_in_cascaded_table INV_RCV_COMMON_APIS.cascaded_trans_tab_type;
      l_po_out_cascaded_table INV_RCV_COMMON_APIS.cascaded_trans_tab_type;

      l_shipment_line_id  NUMBER;
      l_category_id NUMBER;
      l_unit_of_measure VARCHAR2(30);
      l_item_description  VARCHAR2(300);
      l_item_id NUMBER;
      l_receipt_source_code_t VARCHAR2(30);
      l_to_organization_id NUMBER;
      l_rcv_transaction_id NUMBER;
      l_oe_order_line_id NUMBER;
      l_progress VARCHAR2(5) := '10';

      CURSOR asn_direct_lines
	(   v_shipment_header_id  NUMBER
	    ,v_shipment_line_id   NUMBER
	    ,v_item_id            NUMBER
	    ,v_po_header_id       NUMBER
	    ,v_lpn_id             NUMBER
	    ,v_item_desc          VARCHAR2
	    ,v_project_id         NUMBER
	    ,v_task_id            NUMBER
	    ,v_wms_po_j_or_higher VARCHAR2)
	IS
	   SELECT rsl.shipment_line_id
	     , rsl.unit_of_measure
	     , rsl.item_id
	     , 'VENDOR'
	     , rsl.to_organization_id
	     , 0 -- rcv_transaction_id
	     , To_number(NULL)
	     , poll.po_header_id
	     , poll.po_line_id
	     , poll.line_location_id
	     , pod.po_distribution_id
	     , rsl.item_description
	     , Nvl(rsh.expected_receipt_date, Sysdate) expected_receipt_date
	     FROM rcv_shipment_lines rsl
	     , rcv_shipment_headers rsh
	     , po_line_locations poll
	     , po_distributions pod
	     , (SELECT DISTINCT source_line_id
		FROM wms_lpn_contents
		WHERE parent_lpn_id = v_lpn_id) wlc
	     WHERE rsl.shipment_header_id = rsh.shipment_header_id
	     AND rsl.shipment_header_id  = v_shipment_header_id
	     AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	     AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	     -- Bug 3213241
	     AND poll.po_line_id = wlc.source_line_id (+)
	     AND v_wms_po_j_or_higher = 'N'
	     AND pod.line_location_id = poll.line_location_id
	     AND (rsl.item_id = v_item_id
		  OR (v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	     AND poll.approved_flag = 'Y'
	     AND Nvl(poll.cancel_flag, 'N') = 'N'
	     AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	     AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	     AND poll.line_location_id = rsl.po_line_location_id
	     AND rsh.asn_type IN ('ASN', 'ASBN')
	     -- bug 2752051
	     AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
	     AND (  v_project_id is null or
		    (v_project_id = -9999 and pod.project_id is null) or -- bug2669021
		    pod.project_id = v_project_id
		    )
	     and (v_task_id is null or pod.task_id = v_task_id)
	 UNION ALL
	   SELECT rsl.shipment_line_id
	     , rsl.unit_of_measure
	     , rsl.item_id
	     , 'VENDOR'
	     , rsl.to_organization_id
	     , 0 -- rcv_transaction_id
	     , To_number(NULL)
	     , poll.po_header_id
	     , poll.po_line_id
	     , poll.line_location_id
	     , pod.po_distribution_id
	     , rsl.item_description
	     , Nvl(rsh.expected_receipt_date, Sysdate) expected_receipt_date
	     FROM rcv_shipment_lines rsl
	     , rcv_shipment_headers rsh
	     , po_line_locations poll
	     , po_distributions pod
	     WHERE rsl.shipment_header_id = rsh.shipment_header_id
	     AND rsl.shipment_header_id  = v_shipment_header_id
	     AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	     AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	     -- Bug 3213241
	     AND v_wms_po_j_or_higher = 'Y'
	     AND (((rsl.asn_lpn_id IS NOT NULL
		    AND rsl.asn_lpn_id = v_lpn_id
		    )
		   )
		  OR (rsl.asn_lpn_id IS NULL)
		  OR (v_lpn_id IS NULL)
		  )
	     AND pod.line_location_id = poll.line_location_id
	     AND (rsl.item_id = v_item_id
		  OR (v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	     AND poll.approved_flag = 'Y'
	     AND Nvl(poll.cancel_flag, 'N') = 'N'
	     AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	     AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	     AND poll.line_location_id = rsl.po_line_location_id
	     AND rsh.asn_type IN ('ASN', 'ASBN')
	     -- bug 2752051
	     AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
	     AND (  v_project_id is null or
		    (v_project_id = -9999 and pod.project_id is null) or -- bug2669021
		    pod.project_id = v_project_id
		    )
             and (v_task_id is null or pod.task_id = v_task_id)
        ORDER BY expected_receipt_date;

      CURSOR count_asn_direct_lines
	(   v_shipment_header_id NUMBER
	    ,v_shipment_line_id   NUMBER
	    ,v_item_id            NUMBER
	    ,v_po_header_id       NUMBER
	    ,v_lpn_id             NUMBER
	    ,v_item_desc          VARCHAR2
	    ,v_project_id         NUMBER
	    ,v_task_id            NUMBER
	    ,v_wms_po_j_or_higher     VARCHAR2)
	IS

	  --Bug5578552.The COUNT should be outside of UNION.
	  SELECT COUNT(*) FROM
	  ( SELECT 1
	     FROM rcv_shipment_lines rsl
	     , rcv_shipment_headers rsh
	     , po_line_locations poll
	     , po_distributions pod
	     , (SELECT DISTINCT source_line_id
		FROM wms_lpn_contents
		WHERE parent_lpn_id = v_lpn_id) wlc
	     WHERE rsl.shipment_header_id = rsh.shipment_header_id
	     AND rsl.shipment_header_id  = v_shipment_header_id
	     AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	     AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	     -- Bug 3213241
	     --AND poll.po_line_id = wlc.source_line_id (+)
	     AND poll.po_line_id = wlc.source_line_id (+)
	     AND v_wms_po_j_or_higher = 'N'
	     AND pod.line_location_id = poll.line_location_id
	     AND (rsl.item_id = v_item_id
		  OR (v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	     AND poll.approved_flag = 'Y'
	     AND Nvl(poll.cancel_flag, 'N') = 'N'
	     AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	     AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	     AND poll.line_location_id = rsl.po_line_location_id
	     AND rsh.asn_type IN ('ASN', 'ASBN')
	     -- bug 2752051
	     AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
	     AND ( v_project_id is null or
		   (v_project_id = -9999 and pod.project_id is null) or  --bug 2669021
		   pod.project_id = v_project_id
		   )
	     and   (v_task_id is null or pod.task_id = v_task_id)
	  UNION ALL
	   SELECT 1
	     FROM rcv_shipment_lines rsl
	     , rcv_shipment_headers rsh
	     , po_line_locations poll
	     , po_distributions pod
	     WHERE rsl.shipment_header_id = rsh.shipment_header_id
	     AND rsl.shipment_header_id  = v_shipment_header_id
	     AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	     AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	     -- Bug 3213241
	     AND v_wms_po_j_or_higher = 'Y'
	     AND (((rsl.asn_lpn_id IS NOT NULL
		    AND rsl.asn_lpn_id = v_lpn_id
		    )
		   )
		  OR (rsl.asn_lpn_id IS NULL)
		  OR (v_lpn_id IS NULL)
		  )
	     AND pod.line_location_id = poll.line_location_id
	     AND (rsl.item_id = v_item_id
		  OR (v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	     AND poll.approved_flag = 'Y'
	     AND Nvl(poll.cancel_flag, 'N') = 'N'
	     AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	     AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	     AND poll.line_location_id = rsl.po_line_location_id
	     AND rsh.asn_type IN ('ASN', 'ASBN')
	     -- bug 2752051
	     AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
	     AND (  v_project_id is null or
		    (v_project_id = -9999 and pod.project_id is null) or -- bug2669021
		    pod.project_id = v_project_id
		    )
             and (v_task_id is null or pod.task_id = v_task_id) ) ;

      CURSOR asn_receipt_lines
	(   v_shipment_header_id NUMBER
	    ,v_shipment_line_id   NUMBER
	    ,v_item_id            NUMBER
	    ,v_po_header_id       NUMBER
	    ,v_lpn_id             NUMBER
	    ,v_item_desc          VARCHAR2
	    ,v_project_id         NUMBER
	    ,v_task_id            NUMBER
	    ,v_wms_po_j_or_higher VARCHAR2)
	IS
	   SELECT rsl.shipment_line_id
	     , rsl.unit_of_measure
	     , rsl.item_id
	     , 'VENDOR'
	     , rsl.to_organization_id
	     , 0 -- rcv_transaction_id
	     , To_number(NULL)
	     , poll.po_header_id
	     , poll.po_line_id
	     , poll.line_location_id
	     , To_number(NULL)
	     , rsl.item_description
	     , Nvl(rsh.expected_receipt_date, Sysdate) expected_receipt_date
	     FROM rcv_shipment_lines rsl
	        , rcv_shipment_headers rsh
	        , po_line_locations poll
 	        , (SELECT DISTINCT source_line_id
		     FROM wms_lpn_contents
		    WHERE parent_lpn_id = v_lpn_id) wlc
	    WHERE rsl.shipment_header_id = rsh.shipment_header_id
	      AND rsl.shipment_header_id  = v_shipment_header_id
	      AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	      AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	      -- Bug 3213241
	      --AND poll.po_line_id = wlc.source_line_id (+)
	      AND poll.po_line_id = wlc.source_line_id (+)
	      AND v_wms_po_j_or_higher = 'N'
	     -- change to receive non-item master lines
	      --AND rsl.item_id = v_item_id
	      AND (   rsl.item_id = v_item_id
		  OR (    v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	      AND poll.approved_flag = 'Y'
	      AND Nvl(poll.cancel_flag, 'N') = 'N'
	      AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	      AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	      AND poll.line_location_id = rsl.po_line_location_id
	      AND rsh.asn_type IN ('ASN', 'ASBN')
	      -- bug 2752051
	      AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
	      AND exists
			( select '1'
			  from po_distributions_all pod
			  where pod.line_location_id = poll.line_location_id
			  and   (v_project_id is null or
				 (v_project_id = -9999 and pod.project_id is null) or -- bug2669021
				 pod.project_id = v_project_id
				 )
			  and   (v_task_id is null or pod.task_id = v_task_id)
			  )
	   UNION ALL
	      SELECT rsl.shipment_line_id
	     , rsl.unit_of_measure
	     , rsl.item_id
	     , 'VENDOR'
	     , rsl.to_organization_id
	     , 0 -- rcv_transaction_id
	     , To_number(NULL)
	     , poll.po_header_id
	     , poll.po_line_id
	     , poll.line_location_id
	     , To_number(NULL)
	     , rsl.item_description
	     , Nvl(rsh.expected_receipt_date, Sysdate) expected_receipt_date
	     FROM rcv_shipment_lines rsl
	        , rcv_shipment_headers rsh
	        , po_line_locations poll
	    WHERE rsl.shipment_header_id = rsh.shipment_header_id
	      AND rsl.shipment_header_id  = v_shipment_header_id
	      AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	      AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	      -- Bug 3213241
	      AND v_wms_po_j_or_higher = 'Y'
	      AND (((rsl.asn_lpn_id IS NOT NULL
		     AND rsl.asn_lpn_id = v_lpn_id
		     )
		    )
		   OR (rsl.asn_lpn_id IS NULL)
		   OR (v_lpn_id IS NULL)
		   )
	     -- change to receive non-item master lines
	      --AND rsl.item_id = v_item_id
	      AND (   rsl.item_id = v_item_id
		  OR (    v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	      AND poll.approved_flag = 'Y'
	      AND Nvl(poll.cancel_flag, 'N') = 'N'
	      AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	      AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	      AND poll.line_location_id = rsl.po_line_location_id
	      AND rsh.asn_type IN ('ASN', 'ASBN')
	      -- bug 2752051
	      AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
	      AND exists
			( select '1'
			  from po_distributions_all pod
			  where pod.line_location_id = poll.line_location_id
			  and   (v_project_id is null or
				 (v_project_id = -9999 and pod.project_id is null) or -- bug2669021
				 pod.project_id = v_project_id
				 )
			  and   (v_task_id is null or pod.task_id = v_task_id)
			  )
	      ORDER BY expected_receipt_date;

      CURSOR count_asn_receipt_lines
	(   v_shipment_header_id NUMBER
	   ,v_shipment_line_id   NUMBER
	   ,v_item_id            NUMBER
	   ,v_po_header_id       NUMBER
	   ,v_lpn_id             NUMBER
	   ,v_item_desc          VARCHAR2
	   ,v_project_id         NUMBER
	   ,v_task_id            NUMBER
	   ,v_wms_po_j_or_higher VARCHAR2)
	IS

	  --Bug5578552.The COUNT should be outside of UNION.
           SELECT COUNT(*) FROM
	   ( SELECT 1
	     FROM rcv_shipment_lines rsl
	        , rcv_shipment_headers rsh
	        , po_line_locations poll
 	        , (SELECT DISTINCT source_line_id
		     FROM wms_lpn_contents
		    WHERE parent_lpn_id = v_lpn_id) wlc
	    WHERE rsl.shipment_header_id = rsh.shipment_header_id
	      AND rsl.shipment_header_id  = v_shipment_header_id
	      AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	      AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	      -- Bug 3213241
	      --AND poll.po_line_id = wlc.source_line_id (+)
	      AND poll.po_line_id = wlc.source_line_id (+)
	      AND v_wms_po_j_or_higher = 'N'
	     -- change to receive non-item master lines
	      --AND rsl.item_id = v_item_id
	      AND (   rsl.item_id = v_item_id
		  OR (    v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	      AND poll.approved_flag = 'Y'
	      AND Nvl(poll.cancel_flag, 'N') = 'N'
	      AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	      AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	      AND poll.line_location_id = rsl.po_line_location_id
	      AND rsh.asn_type IN ('ASN', 'ASBN')
	      -- bug 2752051
	      AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
         AND exists
             ( select '1'
               from po_distributions_all pod
               where pod.line_location_id = poll.line_location_id
               and   (v_project_id is null or
                      (v_project_id = -9999 and pod.project_id is null) or -- bug2669021
                      pod.project_id = v_project_id
                      )
               and   (v_task_id is null or pod.task_id = v_task_id)
              )
	UNION ALL
	   SELECT 1
	     FROM rcv_shipment_lines rsl
	        , rcv_shipment_headers rsh
	        , po_line_locations poll
	    WHERE rsl.shipment_header_id = rsh.shipment_header_id
	      AND rsl.shipment_header_id  = v_shipment_header_id
	      AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	      AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	      -- Bug 3213241
	      AND v_wms_po_j_or_higher = 'Y'
	      AND (((rsl.asn_lpn_id IS NOT NULL
		     AND rsl.asn_lpn_id = v_lpn_id
		     )
		    )
		   OR (rsl.asn_lpn_id IS NULL)
		   OR (v_lpn_id IS NULL)
		   )
	     -- change to receive non-item master lines
	      --AND rsl.item_id = v_item_id
	      AND (   rsl.item_id = v_item_id
		  OR (    v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	      AND poll.approved_flag = 'Y'
	      AND Nvl(poll.cancel_flag, 'N') = 'N'
	      AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	      AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	      AND poll.line_location_id = rsl.po_line_location_id
	      AND rsh.asn_type IN ('ASN', 'ASBN')
	      -- bug 2752051
	      AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
	      AND exists
			( select '1'
			  from po_distributions_all pod
			  where pod.line_location_id = poll.line_location_id
			  and   (v_project_id is null or
				 (v_project_id = -9999 and pod.project_id is null) or -- bug2669021
				 pod.project_id = v_project_id
				 )
			  and   (v_task_id is null or pod.task_id = v_task_id)
			  ) );


-- For Bug 7440217 Defining Cursors
    CURSOR lcm_direct_lines
	(   v_shipment_header_id  NUMBER
	    ,v_shipment_line_id   NUMBER
	    ,v_item_id            NUMBER
	    ,v_po_header_id       NUMBER
	    ,v_lpn_id             NUMBER
	    ,v_item_desc          VARCHAR2
	    ,v_project_id         NUMBER
	    ,v_task_id            NUMBER
	    ,v_wms_po_j_or_higher VARCHAR2)
	IS
	   SELECT rsl.shipment_line_id
	     , rsl.unit_of_measure
	     , rsl.item_id
	     , 'VENDOR'
	     , rsl.to_organization_id
	     , 0 -- rcv_transaction_id
	     , To_number(NULL)
	     , poll.po_header_id
	     , poll.po_line_id
	     , poll.line_location_id
	     , pod.po_distribution_id
	     , rsl.item_description
	     , Nvl(rsh.expected_receipt_date, Sysdate) expected_receipt_date
	     FROM rcv_shipment_lines rsl
	     , rcv_shipment_headers rsh
	     , po_line_locations poll
	     , po_distributions pod
	     , (SELECT DISTINCT source_line_id
		FROM wms_lpn_contents
		WHERE parent_lpn_id = v_lpn_id) wlc
	     WHERE rsl.shipment_header_id = rsh.shipment_header_id
	     AND rsl.shipment_header_id  = v_shipment_header_id
	     AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	     AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	     -- Bug 3213241
	     AND poll.po_line_id = wlc.source_line_id (+)
	     AND v_wms_po_j_or_higher = 'N'
	     AND pod.line_location_id = poll.line_location_id
	     AND (rsl.item_id = v_item_id
		  OR (v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	     AND poll.approved_flag = 'Y'
	     AND Nvl(poll.cancel_flag, 'N') = 'N'
	     AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	     AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	     AND poll.line_location_id = rsl.po_line_location_id
	     AND rsh.asn_type IN ('LCM')
	     -- bug 2752051
	     AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
	     AND (  v_project_id is null or
		    (v_project_id = -9999 and pod.project_id is null) or -- bug2669021
		    pod.project_id = v_project_id
		    )
	     and (v_task_id is null or pod.task_id = v_task_id)
	 UNION ALL
	   SELECT rsl.shipment_line_id
	     , rsl.unit_of_measure
	     , rsl.item_id
	     , 'VENDOR'
	     , rsl.to_organization_id
	     , 0 -- rcv_transaction_id
	     , To_number(NULL)
	     , poll.po_header_id
	     , poll.po_line_id
	     , poll.line_location_id
	     , pod.po_distribution_id
	     , rsl.item_description
	     , Nvl(rsh.expected_receipt_date, Sysdate) expected_receipt_date
	     FROM rcv_shipment_lines rsl
	     , rcv_shipment_headers rsh
	     , po_line_locations poll
	     , po_distributions pod
	     WHERE rsl.shipment_header_id = rsh.shipment_header_id
	     AND rsl.shipment_header_id  = v_shipment_header_id
	     AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	     AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	     -- Bug 3213241
	     AND v_wms_po_j_or_higher = 'Y'
	     AND pod.line_location_id = poll.line_location_id
	     AND (rsl.item_id = v_item_id
		  OR (v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	     AND poll.approved_flag = 'Y'
	     AND Nvl(poll.cancel_flag, 'N') = 'N'
	     AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	     AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	     AND poll.line_location_id = rsl.po_line_location_id
	     AND rsh.asn_type IN ('LCM')
	     -- bug 2752051
	     AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
	     AND (  v_project_id is null or
		    (v_project_id = -9999 and pod.project_id is null) or -- bug2669021
		    pod.project_id = v_project_id
		    )
             and (v_task_id is null or pod.task_id = v_task_id)
        ORDER BY expected_receipt_date;

      CURSOR count_lcm_direct_lines
	(   v_shipment_header_id NUMBER
	    ,v_shipment_line_id   NUMBER
	    ,v_item_id            NUMBER
	    ,v_po_header_id       NUMBER
	    ,v_lpn_id             NUMBER
	    ,v_item_desc          VARCHAR2
	    ,v_project_id         NUMBER
	    ,v_task_id            NUMBER
	    ,v_wms_po_j_or_higher     VARCHAR2)
	IS

	  --Bug5578552.The COUNT should be outside of UNION.
	  SELECT COUNT(*) FROM
	  ( SELECT 1
	     FROM rcv_shipment_lines rsl
	     , rcv_shipment_headers rsh
	     , po_line_locations poll
	     , po_distributions pod
	     , (SELECT DISTINCT source_line_id
		FROM wms_lpn_contents
		WHERE parent_lpn_id = v_lpn_id) wlc
	     WHERE rsl.shipment_header_id = rsh.shipment_header_id
	     AND rsl.shipment_header_id  = v_shipment_header_id
	     AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	     AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	     -- Bug 3213241
	     --AND poll.po_line_id = wlc.source_line_id (+)
	     AND poll.po_line_id = wlc.source_line_id (+)
	     AND v_wms_po_j_or_higher = 'N'
	     AND pod.line_location_id = poll.line_location_id
	     AND (rsl.item_id = v_item_id
		  OR (v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	     AND poll.approved_flag = 'Y'
	     AND Nvl(poll.cancel_flag, 'N') = 'N'
	     AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	     AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	     AND poll.line_location_id = rsl.po_line_location_id
	     AND rsh.asn_type IN ('LCM')
	     -- bug 2752051
	     AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
	     AND ( v_project_id is null or
		   (v_project_id = -9999 and pod.project_id is null) or  --bug 2669021
		   pod.project_id = v_project_id
		   )
	     and   (v_task_id is null or pod.task_id = v_task_id)
	  UNION ALL
	   SELECT 1
	     FROM rcv_shipment_lines rsl
	     , rcv_shipment_headers rsh
	     , po_line_locations poll
	     , po_distributions pod
	     WHERE rsl.shipment_header_id = rsh.shipment_header_id
	     AND rsl.shipment_header_id  = v_shipment_header_id
	     AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	     AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	     -- Bug 3213241
	     AND v_wms_po_j_or_higher = 'Y'
	     AND pod.line_location_id = poll.line_location_id
	     AND (rsl.item_id = v_item_id
		  OR (v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	     AND poll.approved_flag = 'Y'
	     AND Nvl(poll.cancel_flag, 'N') = 'N'
	     AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	     AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	     AND poll.line_location_id = rsl.po_line_location_id
	     AND rsh.asn_type IN ('LCM')
	     -- bug 2752051
	     AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
	     AND (  v_project_id is null or
		    (v_project_id = -9999 and pod.project_id is null) or -- bug2669021
		    pod.project_id = v_project_id
		    )
             and (v_task_id is null or pod.task_id = v_task_id) ) ;

      CURSOR lcm_receipt_lines
	(   v_shipment_header_id NUMBER
	    ,v_shipment_line_id   NUMBER
	    ,v_item_id            NUMBER
	    ,v_po_header_id       NUMBER
	    ,v_lpn_id             NUMBER
	    ,v_item_desc          VARCHAR2
	    ,v_project_id         NUMBER
	    ,v_task_id            NUMBER
	    ,v_wms_po_j_or_higher VARCHAR2)
	IS
	   SELECT rsl.shipment_line_id
	     , rsl.unit_of_measure
	     , rsl.item_id
	     , 'VENDOR'
	     , rsl.to_organization_id
	     , 0 -- rcv_transaction_id
	     , To_number(NULL)
	     , poll.po_header_id
	     , poll.po_line_id
	     , poll.line_location_id
	     , To_number(NULL)
	     , rsl.item_description
	     , Nvl(rsh.expected_receipt_date, Sysdate) expected_receipt_date
	     FROM rcv_shipment_lines rsl
	        , rcv_shipment_headers rsh
	        , po_line_locations poll
 	        , (SELECT DISTINCT source_line_id
		     FROM wms_lpn_contents
		    WHERE parent_lpn_id = v_lpn_id) wlc
	    WHERE rsl.shipment_header_id = rsh.shipment_header_id
	      AND rsl.shipment_header_id  = v_shipment_header_id
	      AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	      AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	      -- Bug 3213241
	      --AND poll.po_line_id = wlc.source_line_id (+)
	      AND poll.po_line_id = wlc.source_line_id (+)
	      AND v_wms_po_j_or_higher = 'N'
	     -- change to receive non-item master lines
	      --AND rsl.item_id = v_item_id
	      AND (   rsl.item_id = v_item_id
		  OR (    v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	      AND poll.approved_flag = 'Y'
	      AND Nvl(poll.cancel_flag, 'N') = 'N'
	      AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	      AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	      AND poll.line_location_id = rsl.po_line_location_id
	      AND rsh.asn_type IN ('LCM')
	      -- bug 2752051
	      AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
	      AND exists
			( select '1'
			  from po_distributions_all pod
			  where pod.line_location_id = poll.line_location_id
			  and   (v_project_id is null or
				 (v_project_id = -9999 and pod.project_id is null) or -- bug2669021
				 pod.project_id = v_project_id
				 )
			  and   (v_task_id is null or pod.task_id = v_task_id)
			  )
	   UNION ALL
	      SELECT rsl.shipment_line_id
	     , rsl.unit_of_measure
	     , rsl.item_id
	     , 'VENDOR'
	     , rsl.to_organization_id
	     , 0 -- rcv_transaction_id
	     , To_number(NULL)
	     , poll.po_header_id
	     , poll.po_line_id
	     , poll.line_location_id
	     , To_number(NULL)
	     , rsl.item_description
	     , Nvl(rsh.expected_receipt_date, Sysdate) expected_receipt_date
	     FROM rcv_shipment_lines rsl
	        , rcv_shipment_headers rsh
	        , po_line_locations poll
	    WHERE rsl.shipment_header_id = rsh.shipment_header_id
	      AND rsl.shipment_header_id  = v_shipment_header_id
	      AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	      AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	      -- Bug 3213241
	      AND v_wms_po_j_or_higher = 'Y'
	     -- change to receive non-item master lines
	      --AND rsl.item_id = v_item_id
	      AND (   rsl.item_id = v_item_id
		  OR (    v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	      AND poll.approved_flag = 'Y'
	      AND Nvl(poll.cancel_flag, 'N') = 'N'
	      AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	      AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	      AND poll.line_location_id = rsl.po_line_location_id
	      AND rsh.asn_type IN ('LCM')
	      -- bug 2752051
	      AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
	      AND exists
			( select '1'
			  from po_distributions_all pod
			  where pod.line_location_id = poll.line_location_id
			  and   (v_project_id is null or
				 (v_project_id = -9999 and pod.project_id is null) or -- bug2669021
				 pod.project_id = v_project_id
				 )
			  and   (v_task_id is null or pod.task_id = v_task_id)
			  )
	      ORDER BY expected_receipt_date;

      CURSOR count_lcm_receipt_lines
	(   v_shipment_header_id NUMBER
	   ,v_shipment_line_id   NUMBER
	   ,v_item_id            NUMBER
	   ,v_po_header_id       NUMBER
	   ,v_lpn_id             NUMBER
	   ,v_item_desc          VARCHAR2
	   ,v_project_id         NUMBER
	   ,v_task_id            NUMBER
	   ,v_wms_po_j_or_higher VARCHAR2)
	IS

	  --Bug5578552.The COUNT should be outside of UNION.
           SELECT COUNT(*) FROM
	   ( SELECT 1
	     FROM rcv_shipment_lines rsl
	        , rcv_shipment_headers rsh
	        , po_line_locations poll
 	        , (SELECT DISTINCT source_line_id
		     FROM wms_lpn_contents
		    WHERE parent_lpn_id = v_lpn_id) wlc
	    WHERE rsl.shipment_header_id = rsh.shipment_header_id
	      AND rsl.shipment_header_id  = v_shipment_header_id
	      AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	      AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	      -- Bug 3213241
	      --AND poll.po_line_id = wlc.source_line_id (+)
	      AND poll.po_line_id = wlc.source_line_id (+)
	      AND v_wms_po_j_or_higher = 'N'
	     -- change to receive non-item master lines
	      --AND rsl.item_id = v_item_id
	      AND (   rsl.item_id = v_item_id
		  OR (    v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	      AND poll.approved_flag = 'Y'
	      AND Nvl(poll.cancel_flag, 'N') = 'N'
	      AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	      AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	      AND poll.line_location_id = rsl.po_line_location_id
	      AND rsh.asn_type IN ('LCM')
	      -- bug 2752051
	      AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
         AND exists
             ( select '1'
               from po_distributions_all pod
               where pod.line_location_id = poll.line_location_id
               and   (v_project_id is null or
                      (v_project_id = -9999 and pod.project_id is null) or -- bug2669021
                      pod.project_id = v_project_id
                      )
               and   (v_task_id is null or pod.task_id = v_task_id)
              )
	UNION ALL
	   SELECT 1
	     FROM rcv_shipment_lines rsl
	        , rcv_shipment_headers rsh
	        , po_line_locations poll
	    WHERE rsl.shipment_header_id = rsh.shipment_header_id
	      AND rsl.shipment_header_id  = v_shipment_header_id
	      AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	      AND poll.po_header_id = Nvl(v_po_header_id, poll.po_header_id)
	      -- Bug 3213241
	      AND v_wms_po_j_or_higher = 'Y'
	     -- change to receive non-item master lines
	      --AND rsl.item_id = v_item_id
	      AND (   rsl.item_id = v_item_id
		  OR (    v_item_id IS NULL
		      AND rsl.item_id IS NULL
		      AND rsl.item_description = v_item_desc))
	      AND poll.approved_flag = 'Y'
	      AND Nvl(poll.cancel_flag, 'N') = 'N'
	      AND Nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
	      AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	      AND poll.line_location_id = rsl.po_line_location_id
	      AND rsh.asn_type IN ('LCM')
	      -- bug 2752051
	      AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED') --<> 'CANCELLED'
	      AND exists
			( select '1'
			  from po_distributions_all pod
			  where pod.line_location_id = poll.line_location_id
			  and   (v_project_id is null or
				 (v_project_id = -9999 and pod.project_id is null) or -- bug2669021
				 pod.project_id = v_project_id
				 )
			  and   (v_task_id is null or pod.task_id = v_task_id)
			  ) );
-- End for Bug 7440217




      CURSOR int_req_receipt_lines
	(  v_shipment_header_id NUMBER
	  ,v_shipment_line_id   NUMBER
	  ,v_item_id            NUMBER
	  ,v_org_id             NUMBER
	  ,v_txn_date           DATE
          ,v_project_id         NUMBER
          ,v_task_id            NUMBER
          ,v_lpn_id             NUMBER
          ,v_lot_number         VARCHAR2  --9229228
	  ,v_serial_number     VARCHAR2  )--9651496,9764650
	IS
	   SELECT rsl.shipment_line_id
	     , rsl.unit_of_measure
	     , rsl.item_id
	     , Decode(rsl.source_document_code,'INVENTORY','INVENTORY','REQ','INTERNAL ORDER')
	     , rsl.to_organization_id
	     , 0 -- rcv_transaction_id
	     , To_number(NULL)
	     , To_number(NULL)
	     , To_number(NULL)
	     , To_number(NULL)
	     , To_number(NULL)
	     , rsl.item_description
	     , Nvl(rsh.expected_receipt_date, Sysdate) expected_receipt_date
	     FROM rcv_shipment_lines rsl
	        , rcv_shipment_headers rsh
	        , mtl_supply ms
	    WHERE rsl.shipment_header_id = v_shipment_header_id
	      AND rsh.shipment_header_id = rsl.shipment_header_id
	      AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	      AND rsl.item_id = v_item_id
	      AND rsh.receipt_source_code <> 'VENDOR'
	      AND ms.supply_type_code(+) = 'SHIPMENT'
	      AND ms.shipment_header_id = rsh.shipment_header_id
              and ms.shipment_line_id = rsl.shipment_line_id
	      AND rsl.to_organization_id = v_org_id
	      AND (((rsl.asn_lpn_id IS NOT NULL
		     AND rsl.asn_lpn_id = v_lpn_id
		     )
		    )
		   OR (rsl.asn_lpn_id IS NULL)
		   OR (v_lpn_id IS NULL)
		   )--bug 4608033: Should join on rsl.asn_lpn_id so that
		    --the correct rsl can be picked up
	      AND Nvl(rsh.shipped_date,Nvl(v_txn_date-1,Sysdate-1)) < Nvl(v_txn_date,Sysdate)
              AND (  (
                           rsl.source_document_code = 'REQ'
                      and exists
                           ( select '1'
                             from po_req_distributions_all prd
                             where rsl.requisition_line_id = prd.requisition_line_id
                             and   Nvl(rsl.req_distribution_id,prd.distribution_id) = prd.distribution_id--BUG4930681
                             and  (v_project_id is null or
                                    (v_project_id = -9999 and prd.project_id is null) or -- bug2669021
                                     prd.project_id = v_project_id
                                   )
                             and  (v_task_id is null or prd.task_id = v_task_id)
                           )
                     )
                    or rsl.source_document_code <> 'REQ'
                  )
              AND (   --9229228-Added this AND condition for lot.
                     v_lot_number IS NULL
                     OR
                     EXISTS
                          (
                            SELECT lot_num
                            FROM   rcv_lots_supply rls
                            WHERE  rls.shipment_line_id = rsl.shipment_line_id
                            AND    rls.lot_num = v_lot_number
			    AND    rls.supply_type_code = 'SHIPMENT'
                           )
                   )
	      AND (   --9651496,9764650-Added this AND condition for serial.
                     v_serial_number IS NULL
                     OR
                     EXISTS
                          (
                            SELECT serial_num
                            FROM   rcv_serials_supply rss
                            WHERE  rss.shipment_line_id = rsl.shipment_line_id
                            AND    rss.serial_num = v_serial_number
                            AND    rss.supply_type_code = 'SHIPMENT'
                           )
                   )
         ORDER BY Nvl(rsh.expected_receipt_date,Sysdate), rsl.shipment_line_id; --Bug 8374257

      CURSOR count_int_req_receipt_lines
	(  v_shipment_header_id NUMBER
	  ,v_shipment_line_id   NUMBER
	  ,v_item_id            NUMBER
	  ,v_org_id             NUMBER
	  ,v_txn_date           DATE
          ,v_project_id         NUMBER
          ,v_task_id            NUMBER
          ,v_lpn_id             NUMBER
          ,v_lot_number         VARCHAR2
	  ,v_serial_number     VARCHAR2) --9651496,9764650
	IS
	   SELECT COUNT(*)
	     FROM rcv_shipment_lines rsl
	        , rcv_shipment_headers rsh
	        , mtl_supply ms
	    WHERE rsl.shipment_header_id = v_shipment_header_id
	      AND rsh.shipment_header_id = rsl.shipment_header_id
	      AND rsl.shipment_line_id = Nvl(v_shipment_line_id, rsl.shipment_line_id)
	      AND rsl.item_id = v_item_id
	      AND rsh.receipt_source_code <> 'VENDOR'
	      AND ms.supply_type_code(+) = 'SHIPMENT'
	      AND ms.shipment_header_id = rsh.shipment_header_id
              and ms.shipment_line_id = rsl.shipment_line_id
	      AND rsl.to_organization_id = v_org_id
	      AND Nvl(rsh.shipped_date,Nvl(v_txn_date-1,Sysdate-1)) < Nvl(v_txn_date,Sysdate)
	      AND (((rsl.asn_lpn_id IS NOT NULL
		     AND rsl.asn_lpn_id = v_lpn_id
		     )
		    )
		   OR (rsl.asn_lpn_id IS NULL)
		   OR (v_lpn_id IS NULL)
		   )--bug 4608033: Should join on rsl.asn_lpn_id so that
		    --the correct rsl can be picked up
              AND (  (
                           rsl.source_document_code = 'REQ'
                      and exists
                           ( select '1'
                             from po_req_distributions_all prd
                             where rsl.requisition_line_id = prd.requisition_line_id
                             and   Nvl(rsl.req_distribution_id,prd.distribution_id) = prd.distribution_id--BUG4930681
                             and  (v_project_id is null or
                                    (v_project_id = -9999 and prd.project_id is null) or -- bug2669021
                                     prd.project_id = v_project_id
                                   )
                             and  (v_task_id is null or prd.task_id = v_task_id)
                           )
                     )
                    or rsl.source_document_code <> 'REQ'
                  )
              AND (   --9229228-Added this AND condition for lot.
                     v_lot_number IS NULL
                     OR
                     EXISTS
                          (
                            SELECT lot_num
                            FROM   rcv_lots_supply rls
                            WHERE  rls.shipment_line_id = rsl.shipment_line_id
                            AND    rls.lot_num = v_lot_number
                            AND    rls.supply_type_code = 'SHIPMENT'
                           )
                   )
	      AND (   --9651496,9764650-Added this AND condition for serial.
                     v_serial_number IS NULL
                     OR
                     EXISTS
                          (
                            SELECT serial_num
                            FROM   rcv_serials_supply rss
                            WHERE  rss.shipment_line_id = rsl.shipment_line_id
                            AND    rss.serial_num = v_serial_number
                            AND    rss.supply_type_code = 'SHIPMENT'
                           )
                   );


		 CURSOR rma_receipt_lines
		   (  v_oe_order_header_id NUMBER
		      ,v_oe_order_line_id   NUMBER
		      ,v_item_id            NUMBER
		      ,v_org_id             NUMBER
		      ,v_primary_uom        VARCHAR2
		      ,v_txn_date           DATE
		      ,v_project_id         NUMBER
		      ,v_task_id            NUMBER)
		   IS
		      SELECT To_number(NULL)
			,oel.order_quantity_uom --bug3592116-- v_primary_uom unit_of_measure -- the view was selecting the primary uom so just selected the same FROM the value passed TO avoid one more join.
			, oel.inventory_item_id item_id
			, 'CUSTOMER'
			, Nvl(oel.ship_from_org_id, oeh.ship_from_org_id) to_organization_id
			, 0 -- rcv_transaction_id
			, oel.line_id oe_order_line_id
			, To_number(NULL)
			, To_number(NULL)
			, To_number(NULL)
			, To_number(NULL)
			, To_char(NULL)
			, To_char(NULL)
			FROM oe_order_lines_all oel
			, oe_order_headers_all oeh
			--, wf_item_activity_statuses wf
			--, wf_process_activities wpa
			WHERE oel.header_id = oeh.header_id
			AND oel.header_id = v_oe_order_header_id
			AND oel.line_id = Nvl(v_oe_order_line_id, oel.line_id)
			AND oel.inventory_item_id = v_item_id
			AND oel.line_category_code = 'RETURN'
			AND oel.booked_flag = 'Y'
			AND oel.ordered_quantity > Nvl(oel.shipped_quantity,0)
			-- Date tolerance fix.
			AND (Trunc(Sysdate) >=
			     Nvl(Trunc(oel.earliest_acceptable_date),Trunc(Sysdate)))
			AND (Trunc(Sysdate) <=
			     Nvl(Trunc(oel.latest_acceptable_date),Trunc(Sysdate)))
			AND OEL.FLOW_STATUS_CODE = 'AWAITING_RETURN'
			-- performance fix
			--AND wpa.activity_item_type = 'OEOL'
			--AND wpa.activity_name = 'RMA_WAIT_FOR_RECEIVING'
			--AND wf.item_type = 'OEOL'
			--AND wf.process_activity = wpa.instance_id
			--AND wf.activity_status = 'NOTIFIED'
			--AND oel.line_id = To_number(wf.item_key)
			AND ( v_project_id is null
			      or (v_project_id = -9999 and oel.project_id is null) -- bug2669021
			      or (oel.project_id = v_project_id)
			      )
			AND (v_task_id is null or oel.task_id= v_task_id)
		        AND Nvl(oel.ship_from_org_id, oeh.ship_from_org_id) = v_org_id /*added for bug 3578489*/
                        ORDER BY Nvl(Nvl(oel.promise_date,oel.request_date),Sysdate);

			CURSOR count_rma_receipt_lines
			  (  v_oe_order_header_id NUMBER
			     ,v_oe_order_line_id   NUMBER
			     ,v_item_id            NUMBER
			     ,v_org_id             NUMBER
			     ,v_primary_uom        VARCHAR2
			     ,v_txn_date           DATE
			     ,v_project_id         NUMBER
			     ,v_task_id            NUMBER)
			  IS
			     SELECT COUNT(*)
			       FROM oe_order_lines_all oel
			       , oe_order_headers_all oeh
			       --, wf_item_activity_statuses wf
			       --, wf_process_activities wpa
			       WHERE oel.header_id = oeh.header_id
			       AND oel.header_id = v_oe_order_header_id
			       AND oel.line_id = Nvl(v_oe_order_line_id, oel.line_id)
			       AND oel.inventory_item_id = v_item_id
			       AND oel.line_category_code = 'RETURN'
			       AND oel.booked_flag = 'Y'
			       AND oel.ordered_quantity > Nvl(oel.shipped_quantity,0)
			       -- Date tolerance fix.
			       AND (Trunc(Sysdate) >=
				    Nvl(Trunc(oel.earliest_acceptable_date),Trunc(Sysdate)))
			       AND (Trunc(Sysdate) <=
				    Nvl(Trunc(oel.latest_acceptable_date),Trunc(Sysdate)))
			       AND OEL.FLOW_STATUS_CODE = 'AWAITING_RETURN'
			       -- performance fix
			       --AND wpa.activity_item_type = 'OEOL'
			       --AND wpa.activity_name = 'RMA_WAIT_FOR_RECEIVING'
			       --AND wf.item_type = 'OEOL'
			       --AND wf.process_activity = wpa.instance_id
			       --AND wf.activity_status = 'NOTIFIED'
			       --AND oel.line_id = To_number(wf.item_key)
			       AND ( v_project_id is null
				     or (v_project_id = -9999 and oel.project_id is null) -- bug2669021
				     or (oel.project_id = v_project_id)
				     )
                               AND (v_task_id is null or oel.task_id= v_task_id)
                               AND Nvl(oel.ship_from_org_id, oeh.ship_from_org_id) = v_org_id; --added for bug 3578489

    /* FP-J Lot/Serial Support Enhancement
    * Added two new arguments to the cursor, v_lot_number and v_lpn_id_to_match
    * Added conditions to match the lot number with that in RCV_LOTS_SUPPLY
    * and the LPN with that in RCV_SUPPLY for the parent trasnaction
    * This would be done only if WMS and PO patchset levels are J or higher
    */

     CURSOR int_req_delivery_lines(
     v_shipment_header_id NUMBER
    ,v_shipment_line_id   NUMBER
    ,v_item_id            NUMBER
    ,v_org_id             NUMBER
    ,v_receipt_num        VARCHAR2
    ,v_txn_date           DATE
    ,v_inspection_status  VARCHAR2
    ,v_lpn_id             NUMBER
    ,v_lot_number         VARCHAR2
    ,v_lpn_id_to_match    NUMBER
    ,v_parent_txn_id_to_match NUMBER)
	IS
	   SELECT rsup.shipment_line_id
	     , rt.unit_of_measure
	     -- Dont know if it is really correct, should be
	     -- rsl.unit_of_measure but this actually IS
	     -- rt.unit_of_measure....depends ON the transaction processor
	     -- ON what it puts FOR this column.
	     , rsup.item_id
	     , rsh.receipt_source_code
	     , rsup.to_organization_id
	     , rsup.rcv_transaction_id
	     , To_number(NULL) oe_order_line_id
	     , To_number(NULL) po_header_id
	     , To_number(NULL) po_line_id
	     , To_number(NULL) po_line_location_id
	     , To_number(NULL) po_distribution_id
	     , rsl.item_description item_description
	     , Nvl(rsh.expected_receipt_date, Sysdate) expected_receipt_date
	     FROM rcv_supply rsup
	        , rcv_transactions rt
	        , rcv_shipment_headers rsh
	        , rcv_shipment_lines rsl
	    WHERE rsl.shipment_header_id = v_shipment_header_id
	      AND rsl.shipment_line_id  = Nvl(v_shipment_line_id,rsl.shipment_line_id)
	      AND rsup.item_id = v_item_id
	      AND Nvl(rsh.receipt_num,'@@@') = Nvl(v_receipt_num, Nvl(rsh.receipt_num,'@@@'))
	      AND rt.transaction_date < Nvl(v_txn_date, (rt.transaction_date +1))
	      AND (RT.ROUTING_HEADER_ID IS NULL OR
		   RT.ROUTING_HEADER_ID <> 2 OR
		   (rt.routing_header_id = 2
		    AND rt.inspection_status_code <> 'NOT INSPECTED'
		    AND rt.inspection_status_code = Nvl(v_inspection_status,rt.inspection_status_code)))
		   --(RT.ROUTING_HEADER_ID = 2 AND rt.inspection_status_code <> 'NOT INSPECTED'))
	      AND RSUP.SUPPLY_TYPE_CODE = 'RECEIVING'
	      AND RSL.SHIPMENT_LINE_ID = RSUP.SHIPMENT_LINE_ID
	      AND RT.TRANSACTION_ID = RSUP.RCV_TRANSACTION_ID
	      AND RT.TRANSACTION_TYPE <> 'UNORDERED'
	      -- for all the transactions in rt for which we can putaway, the
	      -- transfer_lpn_id should match the lpn being putaway.
	      --AND Nvl(rt.transfer_lpn_id,-1)        = Nvl(v_lpn_id,-1)
	      -- Fix for 1865886. Commented the above and added the following for lpn
	      AND Nvl(v_lpn_id,-1) IN (select nvl(rt2.transfer_lpn_id,-1)
				         from rcv_transactions rt2
				        where rt2.transaction_type <> 'DELIVER'
				        start with rt2.transaction_id = rsup.supply_source_id
				      connect by prior rt2.transaction_id = rt2.parent_transaction_id
				    union all
				       select nvl(rt2.lpn_id,-1)
				         from rcv_transactions rt2
					/* Changes made for bug #4926987 -- added ACCEPT and REJECT */
				        where rt2.transaction_type not in ('RECEIVE', 'DELIVER','ACCEPT','REJECT')
					/* End of changes made for bug #4926987 -- added ACCEPT and REJECT */
				        start with rt2.transaction_id = rsup.supply_source_id
				      connect by prior rt2.transaction_id = rt2.parent_transaction_id
				       )
	      AND RSUP.to_organization_id = v_org_id
	      AND RSH.SHIPMENT_HEADER_ID = RSUP.SHIPMENT_HEADER_ID
        AND  (
               v_lot_number IS NULL OR EXISTS
               (
                 SELECT lot_num
                 FROM   rcv_lots_supply rls
                 WHERE  rls.transaction_id = rsup.supply_source_id
                 AND    rls.lot_num = v_lot_number
               )
             )
        AND  (
               v_parent_txn_id_to_match IS NULL
	      OR v_parent_txn_id_to_match = rsup.supply_source_id
             )
        AND  (
               v_lpn_id_to_match IS NULL
               OR (rsup.lpn_id = v_lpn_id_to_match)
             )
	    ORDER BY rt.transaction_date;

  CURSOR count_int_req_delivery_lines(
     v_shipment_header_id NUMBER
    ,v_shipment_line_id   NUMBER
    ,v_item_id            NUMBER
    ,v_org_id             NUMBER
    ,v_receipt_num        VARCHAR2
    ,v_txn_date           DATE
    ,v_inspection_status  VARCHAR2
    ,v_lpn_id             NUMBER
    ,v_lot_number         VARCHAR2
    ,v_lpn_id_to_match    NUMBER
    ,v_parent_txn_id_to_match NUMBER)
	IS
	   SELECT COUNT(*)
	     FROM rcv_supply rsup
	        , rcv_transactions rt
	        , rcv_shipment_headers rsh
	        , rcv_shipment_lines rsl
	    WHERE rsl.shipment_header_id = v_shipment_header_id
	      AND rsl.shipment_line_id  = Nvl(v_shipment_line_id,rsl.shipment_line_id)
	      AND rsup.item_id = v_item_id
	      AND Nvl(rsh.receipt_num,'@@@') = Nvl(v_receipt_num, Nvl(rsh.receipt_num,'@@@'))
	      AND rt.transaction_date < Nvl(v_txn_date, (rt.transaction_date +1))
	      AND (RT.ROUTING_HEADER_ID IS NULL OR
		   RT.ROUTING_HEADER_ID <> 2 OR
		   (rt.routing_header_id = 2
		    AND rt.inspection_status_code <> 'NOT INSPECTED'
		    AND rt.inspection_status_code = Nvl(v_inspection_status,rt.inspection_status_code)))
		   --(RT.ROUTING_HEADER_ID = 2 AND rt.inspection_status_code <> 'NOT INSPECTED'))
	      AND RSUP.SUPPLY_TYPE_CODE = 'RECEIVING'
	      AND RSL.SHIPMENT_LINE_ID = RSUP.SHIPMENT_LINE_ID
	      AND RT.TRANSACTION_ID = RSUP.RCV_TRANSACTION_ID
	      AND RT.TRANSACTION_TYPE <> 'UNORDERED'
	      -- for all the transactions in rt for which we can putaway, the
	      -- transfer_lpn_id should match the lpn being putaway.
	      --AND Nvl(rt.transfer_lpn_id,-1)        = Nvl(v_lpn_id,-1)
	      -- Fix for 1865886. Commented the above and added the following for lpn
	      AND Nvl(v_lpn_id,-1) IN (select nvl(rt2.transfer_lpn_id,-1)
				         from rcv_transactions rt2
				        where rt2.transaction_type <> 'DELIVER'
				        start with rt2.transaction_id = rsup.supply_source_id
				      connect by prior transaction_id = parent_transaction_id
				    union all
				       select nvl(lpn_id,-1)
				         from rcv_transactions
					/* Changes made for bug #4926987 -- added ACCEPT and REJECT */
				        where transaction_type not in ('RECEIVE', 'DELIVER', 'ACCEPT', 'REJECT')
					/* End Changes made for bug #4926987 -- added ACCEPT and REJECT */
				        start with transaction_id = rsup.supply_source_id
				      connect by prior transaction_id = parent_transaction_id
				       )
	      AND RSUP.to_organization_id = v_org_id
	      AND RSH.SHIPMENT_HEADER_ID = RSUP.shipment_header_id
        AND  (
               v_lot_number IS NULL OR EXISTS
               (
                 SELECT lot_num
                 FROM   rcv_lots_supply rls
                 WHERE  rls.transaction_id = rsup.supply_source_id
                 AND    rls.lot_num = v_lot_number
               )
             )
        AND  (
               v_parent_txn_id_to_match IS NULL
	      OR v_parent_txn_id_to_match = rsup.supply_source_id
             )
        AND  (
               v_lpn_id_to_match IS NULL
               OR (rsup.lpn_id = v_lpn_id_to_match)
             ) ;

   /* FP-J Lot/Serial Support Enhancement
    * Added two new arguments to the cursor, v_lot_number and v_lpn_id_to_match
    * Added conditions to match the lot number with that in RCV_LOTS_SUPPLY
    * and the LPN with that in RCV_SUPPLY for the parent trasnaction
    * This would be done only if WMS and PO patchset levels are J or higher
    */
   CURSOR rma_delivery_lines(
     v_oe_order_header_id NUMBER
    ,v_oe_order_line_id   NUMBER
    ,v_item_id            NUMBER
    ,v_org_id             NUMBER
    ,v_receipt_num        VARCHAR2
    ,v_txn_date           DATE
    ,v_inspection_status  VARCHAR2
    ,v_lpn_id             NUMBER
    ,v_lot_number         VARCHAR2
    ,v_lpn_id_to_match    NUMBER
    ,v_parent_txn_id_to_match NUMBER)
	IS
	   SELECT To_number(NULL)
	     , rt.unit_of_measure
	     -- Dont know if it is really correct, should be
	     -- rsl.unit_of_measure but this actually IS
	     -- rt.unit_of_measure....depends ON the transaction processor
	     -- ON what it puts FOR this column.
	     , rsup.item_id
	     , rsh.receipt_source_code
	     , rsup.to_organization_id
	     , rsup.rcv_transaction_id
	     , rsup.oe_order_line_id
	     , To_number(NULL)
	     , To_number(NULL)
	     , To_number(NULL)
	     , To_number(NULL)
	     , To_char(NULL)
	     , To_char(NULL)
	     FROM rcv_supply rsup
	        , rcv_transactions rt
	        , rcv_shipment_headers rsh
	    WHERE rsh.receipt_source_code = 'CUSTOMER'
	      AND rsup.item_id = v_item_id
	      AND rsup.oe_order_header_id = v_oe_order_header_id
	      AND rsup.oe_order_line_id = Nvl(v_oe_order_line_id,Nvl(rsup.oe_order_line_id,-1))
	      AND Nvl(rsh.receipt_num,'@@@') = Nvl(v_receipt_num, Nvl(rsh.receipt_num,'@@@'))
	      AND rt.transaction_date < Nvl(v_txn_date, (rt.transaction_date + 1))
	      AND (RT.ROUTING_HEADER_ID IS NULL OR
		   RT.ROUTING_HEADER_ID <> 2 OR
		   (rt.routing_header_id = 2
		    AND rt.inspection_status_code <> 'NOT INSPECTED'
		    AND rt.inspection_status_code = Nvl(v_inspection_status,rt.inspection_status_code)))
		   --(RT.ROUTING_HEADER_ID = 2 AND rt.inspection_status_code <> 'NOT INSPECTED'))
	      AND RSUP.SUPPLY_TYPE_CODE = 'RECEIVING'
	      AND RT.TRANSACTION_ID = RSUP.RCV_TRANSACTION_ID
	      AND RT.TRANSACTION_TYPE <> 'UNORDERED'
	      -- for all the transactions in rt for which we can putaway, the
	      -- transfer_lpn_id should match the lpn being putaway.
	      -- AND Nvl(rt.transfer_lpn_id,-1)        = Nvl(v_lpn_id,-1)
	      -- Fix for 1865886. Commented the above and added the following for lpn
	      AND Nvl(v_lpn_id,-1) IN (select nvl(rt2.transfer_lpn_id,-1)
				         from rcv_transactions rt2
				        where rt2.transaction_type <> 'DELIVER'
				        start with rt2.transaction_id = rsup.supply_source_id
				      connect by prior transaction_id = parent_transaction_id
				    union all
				       select nvl(lpn_id,-1)
				         from rcv_transactions
				        where transaction_type not in ('RECEIVE', 'DELIVER')
				        start with transaction_id = rsup.supply_source_id
				      connect by prior transaction_id = parent_transaction_id
				       )
	      AND RSUP.to_organization_id = v_org_id
	      AND RSH.SHIPMENT_HEADER_ID = RSUP.shipment_header_id
        AND  (
               v_lot_number IS NULL OR EXISTS
               (
                 SELECT lot_num
                 FROM   rcv_lots_supply rls
                 WHERE  rls.transaction_id = rsup.supply_source_id
                 AND    rls.lot_num = v_lot_number
               )
             )
        AND  (
               v_parent_txn_id_to_match IS NULL
	      OR v_parent_txn_id_to_match = rsup.supply_source_id
             )
        AND  (
               v_lpn_id_to_match IS NULL
               OR (rsup.lpn_id = v_lpn_id_to_match)
             )
	   ORDER BY rt.transaction_date;

   CURSOR count_rma_delivery_lines(
     v_oe_order_header_id NUMBER
    ,v_oe_order_line_id   NUMBER
    ,v_item_id            NUMBER
    ,v_org_id             NUMBER
    ,v_receipt_num        VARCHAR2
    ,v_txn_date           DATE
    ,v_inspection_status  VARCHAR2
    ,v_lpn_id             NUMBER
    ,v_lot_number         VARCHAR2
    ,v_lpn_id_to_match    NUMBER
    ,v_parent_txn_id_to_match NUMBER)
	IS
	   SELECT COUNT(*)
	     FROM rcv_supply rsup
	        , rcv_transactions rt
	        , rcv_shipment_headers rsh
	    WHERE rsh.receipt_source_code = 'CUSTOMER'
	      AND rsup.item_id = v_item_id
	      AND rsup.oe_order_header_id = v_oe_order_header_id
	      AND rsup.oe_order_line_id = Nvl(v_oe_order_line_id,Nvl(rsup.oe_order_line_id,-1))
	      AND Nvl(rsh.receipt_num,'@@@') = Nvl(v_receipt_num, Nvl(rsh.receipt_num,'@@@'))
	      AND rt.transaction_date < Nvl(v_txn_date, (rt.transaction_date + 1))
	      AND (RT.ROUTING_HEADER_ID IS NULL OR
		   RT.ROUTING_HEADER_ID <> 2 OR
		   (rt.routing_header_id = 2
		    AND rt.inspection_status_code <> 'NOT INSPECTED'
		    AND rt.inspection_status_code = Nvl(v_inspection_status,rt.inspection_status_code)))
		   --(RT.ROUTING_HEADER_ID = 2 AND rt.inspection_status_code <> 'NOT INSPECTED'))
	      AND RSUP.SUPPLY_TYPE_CODE = 'RECEIVING'
	      AND RT.TRANSACTION_ID = RSUP.RCV_TRANSACTION_ID
	      AND RT.TRANSACTION_TYPE <> 'UNORDERED'
	      -- for all the transactions in rt for which we can putaway, the
	      -- transfer_lpn_id should match the lpn being putaway.
	      --AND Nvl(rt.transfer_lpn_id,-1)        = Nvl(v_lpn_id,-1)
	      -- Fix for 1865886. Commented the above and added the following for lpn
	      AND Nvl(v_lpn_id,-1) IN (select nvl(rt2.transfer_lpn_id,-1)
				         from rcv_transactions rt2
				        where rt2.transaction_type <> 'DELIVER'
				        start with rt2.transaction_id = rsup.supply_source_id
				      connect by prior transaction_id = parent_transaction_id
				    union all
				       select nvl(lpn_id,-1)
				         from rcv_transactions
				        where transaction_type not in ('RECEIVE', 'DELIVER')
				        start with transaction_id = rsup.supply_source_id
				      connect by prior transaction_id = parent_transaction_id
				       )
	      AND RSUP.to_organization_id = v_org_id
	      AND RSH.SHIPMENT_HEADER_ID = RSUP.shipment_header_id
        AND  (
               v_lot_number IS NULL OR EXISTS
               (
                 SELECT lot_num
                 FROM   rcv_lots_supply rls
                 WHERE  rls.transaction_id = rsup.supply_source_id
                 AND    rls.lot_num = v_lot_number
               )
             )
        AND  (
               v_parent_txn_id_to_match IS NULL
	      OR v_parent_txn_id_to_match = rsup.supply_source_id
             )
        AND  (
               v_lpn_id_to_match IS NULL
               OR (rsup.lpn_id = v_lpn_id_to_match)
             ) ;

      CURSOR asn_delivery_lines(
     v_shipment_header_id NUMBER
    ,v_shipment_line_id   NUMBER
    ,v_item_id            NUMBER
    ,v_org_id             NUMBER
    ,v_receipt_num        VARCHAR2
    ,v_txn_date           DATE
    ,v_inspection_status  VARCHAR2
    ,v_lpn_id             NUMBER
    ,v_lot_number         VARCHAR2
    ,v_lpn_id_to_match    NUMBER
    ,v_parent_transaction_id  NUMBER)  -- Added for bug# 9879753
        IS
           SELECT rsup.shipment_line_id
             , rt.unit_of_measure
             -- Dont know if it is really correct, should be
             -- rsl.unit_of_measure but this actually IS
             -- rt.unit_of_measure....depends ON the transaction processor
             -- ON what it puts FOR this column.
             , rsup.item_id
             , rsh.receipt_source_code
             , rsup.to_organization_id
             , rsup.rcv_transaction_id
             , To_number(NULL) oe_order_line_id
             , rsup.po_header_id po_header_id
             , rsup.po_line_id po_line_id
             , rsup.po_line_location_id po_line_location_id
             , pod.po_distribution_id po_distribution_id
             , rsl.item_description item_description
	     , to_char(null)
             FROM rcv_supply rsup
                , rcv_transactions rt
                , rcv_shipment_headers rsh
                , rcv_shipment_lines rsl
                , po_line_locations poll
                , po_distributions pod
            WHERE rsl.shipment_header_id = v_shipment_header_id
              AND rsl.shipment_line_id  = Nvl(v_shipment_line_id,rsl.shipment_line_id)
              AND rsup.item_id = v_item_id
              AND rsup.po_header_id = pod.po_header_id
              AND rsup.PO_LINE_ID = pod.PO_LINE_ID
              AND rsup.PO_LINE_LOCATION_ID = pod.LINE_LOCATION_ID
              AND rsup.po_header_id = poll.po_header_id
              AND rsup.PO_LINE_ID = poll.PO_LINE_ID
              AND rsup.PO_LINE_LOCATION_ID = poll.LINE_LOCATION_ID
              and NVL(poll.APPROVED_FLAG,'N')        = 'Y'
              and NVL(poll.CANCEL_FLAG, 'N')         = 'N'
              and NVL(poll.CLOSED_CODE,'OPEN')       <> 'FINALLY CLOSED'
              and poll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
              AND rt.transaction_date < Nvl(v_txn_date, (rt.transaction_date +1))
	      AND (RT.ROUTING_HEADER_ID IS NULL OR
                   RT.ROUTING_HEADER_ID <> 2 OR
                   (rt.routing_header_id = 2
                    AND rt.inspection_status_code <> 'NOT INSPECTED'
                    AND rt.inspection_status_code = Nvl(v_inspection_status,rt.inspection_status_code)))
                   --(RT.ROUTING_HEADER_ID = 2 AND rt.inspection_status_code <> 'NOT INSPECTED'))
              AND RSUP.SUPPLY_TYPE_CODE = 'RECEIVING'
              AND RSL.SHIPMENT_LINE_ID = RSUP.SHIPMENT_LINE_ID
              AND RT.TRANSACTION_ID = RSUP.RCV_TRANSACTION_ID
              AND RT.TRANSACTION_TYPE <> 'UNORDERED'
              -- for all the transactions in rt for which we can putaway, the
              -- transfer_lpn_id should match the lpn being putaway.
              --AND Nvl(rt.transfer_lpn_id,-1)        = Nvl(v_lpn_id,-1)
              -- Fix for 1865886. Commented the above and added the following for lpn
              AND Nvl(v_lpn_id,-1) IN (select nvl(rt2.transfer_lpn_id,-1)
                                         from rcv_transactions rt2
                                        where rt2.transaction_type <> 'DELIVER'
                                        start with rt2.transaction_id = rsup.supply_source_id
                                      connect by prior rt2.transaction_id = rt2.parent_transaction_id
                                    union all
                                       select nvl(rt2.lpn_id,-1)
                                         from rcv_transactions rt2
                                        where rt2.transaction_type not in ('RECEIVE', 'DELIVER')
                                        start with rt2.transaction_id = rsup.supply_source_id
                                      connect by prior rt2.transaction_id = rt2.parent_transaction_id
                                       )
              AND RSUP.to_organization_id = v_org_id
              AND RSH.SHIPMENT_HEADER_ID = RSUP.SHIPMENT_HEADER_ID
			  AND RT.TRANSACTION_ID = NVL(v_parent_transaction_id, rt.transaction_id) -- 9879753
        AND  (
               v_lot_number IS NULL OR EXISTS
               (
                 SELECT lot_num
                 FROM   rcv_lots_supply rls
                 WHERE  rls.transaction_id = rsup.supply_source_id
                 AND    rls.lot_num = v_lot_number
               )
             )
        AND  (
               v_lpn_id_to_match IS NULL
               OR (rsup.lpn_id = v_lpn_id_to_match)
             )
            ORDER BY rt.transaction_date,
  	             rsup.rcv_transaction_id; -- Added for bug# 8931640


       CURSOR count_asn_delivery_lines(
     v_shipment_header_id NUMBER
    ,v_shipment_line_id   NUMBER
    ,v_item_id            NUMBER
    ,v_org_id             NUMBER
    ,v_receipt_num        VARCHAR2
    ,v_txn_date           DATE
    ,v_inspection_status  VARCHAR2
    ,v_lpn_id             NUMBER
    ,v_lot_number         VARCHAR2
    ,v_lpn_id_to_match        NUMBER
    ,v_parent_transaction_id  NUMBER)  -- Added for bug# 9879753

        IS
           SELECT COUNT(*)
             FROM rcv_supply rsup
                , rcv_transactions rt
                , rcv_shipment_headers rsh
                , rcv_shipment_lines rsl
                , po_line_locations poll
                , po_distributions pod
            WHERE rsl.shipment_header_id = v_shipment_header_id
              AND rsl.shipment_line_id  = Nvl(v_shipment_line_id,rsl.shipment_line_id)
              AND rsup.item_id = v_item_id
              AND rsup.po_header_id = pod.po_header_id
              AND rsup.PO_LINE_ID = pod.PO_LINE_ID
              AND rsup.PO_LINE_LOCATION_ID = pod.LINE_LOCATION_ID
              AND rsup.po_header_id = poll.po_header_id
              AND rsup.PO_LINE_ID = poll.PO_LINE_ID
              AND rsup.PO_LINE_LOCATION_ID = poll.LINE_LOCATION_ID
              and NVL(poll.APPROVED_FLAG,'N')        = 'Y'
              and NVL(poll.CANCEL_FLAG, 'N')         = 'N'
              and NVL(poll.CLOSED_CODE,'OPEN')       <> 'FINALLY CLOSED'
              and poll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
              AND rt.transaction_date < Nvl(v_txn_date, (rt.transaction_date +1))
              AND (RT.ROUTING_HEADER_ID IS NULL OR
                   RT.ROUTING_HEADER_ID <> 2 OR
                   (rt.routing_header_id = 2
                    AND rt.inspection_status_code <> 'NOT INSPECTED'
                    AND rt.inspection_status_code = Nvl(v_inspection_status,rt.inspection_status_code)))
                   --(RT.ROUTING_HEADER_ID = 2 AND rt.inspection_status_code <> 'NOT INSPECTED'))
              AND RSUP.SUPPLY_TYPE_CODE = 'RECEIVING'
              AND RSL.SHIPMENT_LINE_ID = RSUP.SHIPMENT_LINE_ID
              AND RT.TRANSACTION_ID = RSUP.RCV_TRANSACTION_ID
              AND RT.TRANSACTION_TYPE <> 'UNORDERED'
              -- for all the transactions in rt for which we can putaway, the
              -- transfer_lpn_id should match the lpn being putaway.
              --AND Nvl(rt.transfer_lpn_id,-1)        = Nvl(v_lpn_id,-1)
              -- Fix for 1865886. Commented the above and added the following for lpn
              AND Nvl(v_lpn_id,-1) IN (select nvl(rt2.transfer_lpn_id,-1)
                                         from rcv_transactions rt2
                                        where rt2.transaction_type <> 'DELIVER'
                                        start with rt2.transaction_id = rsup.supply_source_id
                                      connect by prior rt2.transaction_id = rt2.parent_transaction_id
                                    union all
                                       select nvl(rt2.lpn_id,-1)
                                         from rcv_transactions rt2
                                        where rt2.transaction_type not in ('RECEIVE', 'DELIVER')
                                        start with rt2.transaction_id = rsup.supply_source_id
                                      connect by prior rt2.transaction_id = rt2.parent_transaction_id
                                       )
              AND RSUP.to_organization_id = v_org_id
              AND RSH.SHIPMENT_HEADER_ID = RSUP.SHIPMENT_HEADER_ID
			  AND RT.TRANSACTION_ID = NVL(v_parent_transaction_id, rt.transaction_id) -- 9879753
        AND  (
               v_lot_number IS NULL OR EXISTS
               (
                 SELECT lot_num
                 FROM   rcv_lots_supply rls
                 WHERE  rls.transaction_id = rsup.supply_source_id
                 AND    rls.lot_num = v_lot_number
               )
             )
        AND  (
               v_lpn_id_to_match IS NULL
               OR (rsup.lpn_id = v_lpn_id_to_match)
             )
            ORDER BY rt.transaction_date;

-- For Bug 7440217 Cursors defined
      CURSOR lcm_delivery_lines(
     v_shipment_header_id NUMBER
    ,v_shipment_line_id   NUMBER
    ,v_item_id            NUMBER
    ,v_org_id             NUMBER
    ,v_receipt_num        VARCHAR2
    ,v_txn_date           DATE
    ,v_inspection_status  VARCHAR2
    ,v_lpn_id             NUMBER
    ,v_lot_number         VARCHAR2
    ,v_lpn_id_to_match    NUMBER)
        IS
           SELECT rsup.shipment_line_id
             , rt.unit_of_measure
             -- Dont know if it is really correct, should be
             -- rsl.unit_of_measure but this actually IS
             -- rt.unit_of_measure....depends ON the transaction processor
             -- ON what it puts FOR this column.
             , rsup.item_id
             , rsh.receipt_source_code
             , rsup.to_organization_id
             , rsup.rcv_transaction_id
             , To_number(NULL) oe_order_line_id
             , rsup.po_header_id po_header_id
             , rsup.po_line_id po_line_id
             , rsup.po_line_location_id po_line_location_id
             , pod.po_distribution_id po_distribution_id
             , rsl.item_description item_description
	     , to_char(null)
             FROM rcv_supply rsup
                , rcv_transactions rt
                , rcv_shipment_headers rsh
                , rcv_shipment_lines rsl
                , po_line_locations poll
                , po_distributions pod
            WHERE rsl.shipment_header_id = v_shipment_header_id
              AND rsl.shipment_line_id  = Nvl(v_shipment_line_id,rsl.shipment_line_id)
              AND rsup.item_id = v_item_id
              AND rsup.po_header_id = pod.po_header_id
              AND rsup.PO_LINE_ID = pod.PO_LINE_ID
              AND rsup.PO_LINE_LOCATION_ID = pod.LINE_LOCATION_ID
              AND rsup.po_header_id = poll.po_header_id
              AND rsup.PO_LINE_ID = poll.PO_LINE_ID
              AND rsup.PO_LINE_LOCATION_ID = poll.LINE_LOCATION_ID
              and NVL(poll.APPROVED_FLAG,'N')        = 'Y'
              and NVL(poll.CANCEL_FLAG, 'N')         = 'N'
              and NVL(poll.CLOSED_CODE,'OPEN')       <> 'FINALLY CLOSED'
              and poll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
              AND rt.transaction_date < Nvl(v_txn_date, (rt.transaction_date +1))
	      AND (RT.ROUTING_HEADER_ID IS NULL OR
                   RT.ROUTING_HEADER_ID <> 2 OR
                   (rt.routing_header_id = 2
                    AND rt.inspection_status_code <> 'NOT INSPECTED'
                    AND rt.inspection_status_code = Nvl(v_inspection_status,rt.inspection_status_code)))
                   --(RT.ROUTING_HEADER_ID = 2 AND rt.inspection_status_code <> 'NOT INSPECTED'))
              AND RSUP.SUPPLY_TYPE_CODE = 'RECEIVING'
              AND RSL.SHIPMENT_LINE_ID = RSUP.SHIPMENT_LINE_ID
              AND RT.TRANSACTION_ID = RSUP.RCV_TRANSACTION_ID
              AND RT.TRANSACTION_TYPE <> 'UNORDERED'
              -- for all the transactions in rt for which we can putaway, the
              -- transfer_lpn_id should match the lpn being putaway.
              --AND Nvl(rt.transfer_lpn_id,-1)        = Nvl(v_lpn_id,-1)
              -- Fix for 1865886. Commented the above and added the following for lpn
              AND Nvl(v_lpn_id,-1) IN (select nvl(rt2.transfer_lpn_id,-1)
                                         from rcv_transactions rt2
                                        where rt2.transaction_type <> 'DELIVER'
                                        start with rt2.transaction_id = rsup.supply_source_id
                                      connect by prior rt2.transaction_id = rt2.parent_transaction_id
                                    union all
                                       select nvl(rt2.lpn_id,-1)
                                         from rcv_transactions rt2
                                        where rt2.transaction_type not in ('RECEIVE', 'DELIVER')
                                        start with rt2.transaction_id = rsup.supply_source_id
                                      connect by prior rt2.transaction_id = rt2.parent_transaction_id
                                       )
              AND RSUP.to_organization_id = v_org_id
              AND RSH.SHIPMENT_HEADER_ID = RSUP.SHIPMENT_HEADER_ID
        AND  (
               v_lot_number IS NULL OR EXISTS
               (
                 SELECT lot_num
                 FROM   rcv_lots_supply rls
                 WHERE  rls.transaction_id = rsup.supply_source_id
                 AND    rls.lot_num = v_lot_number
               )
             )
        AND  (
               v_lpn_id_to_match IS NULL
               OR (rsup.lpn_id = v_lpn_id_to_match)
             )
            ORDER BY rt.transaction_date;


       CURSOR count_lcm_delivery_lines(
     v_shipment_header_id NUMBER
    ,v_shipment_line_id   NUMBER
    ,v_item_id            NUMBER
    ,v_org_id             NUMBER
    ,v_receipt_num        VARCHAR2
    ,v_txn_date           DATE
    ,v_inspection_status  VARCHAR2
    ,v_lpn_id             NUMBER
    ,v_lot_number         VARCHAR2
    ,v_lpn_id_to_match    NUMBER)
        IS
           SELECT COUNT(*)
             FROM rcv_supply rsup
                , rcv_transactions rt
                , rcv_shipment_headers rsh
                , rcv_shipment_lines rsl
                , po_line_locations poll
                , po_distributions pod
            WHERE rsl.shipment_header_id = v_shipment_header_id
              AND rsl.shipment_line_id  = Nvl(v_shipment_line_id,rsl.shipment_line_id)
              AND rsup.item_id = v_item_id
              AND rsup.po_header_id = pod.po_header_id
              AND rsup.PO_LINE_ID = pod.PO_LINE_ID
              AND rsup.PO_LINE_LOCATION_ID = pod.LINE_LOCATION_ID
              AND rsup.po_header_id = poll.po_header_id
              AND rsup.PO_LINE_ID = poll.PO_LINE_ID
              AND rsup.PO_LINE_LOCATION_ID = poll.LINE_LOCATION_ID
              and NVL(poll.APPROVED_FLAG,'N')        = 'Y'
              and NVL(poll.CANCEL_FLAG, 'N')         = 'N'
              and NVL(poll.CLOSED_CODE,'OPEN')       <> 'FINALLY CLOSED'
              and poll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
              AND rt.transaction_date < Nvl(v_txn_date, (rt.transaction_date +1))
              AND (RT.ROUTING_HEADER_ID IS NULL OR
                   RT.ROUTING_HEADER_ID <> 2 OR
                   (rt.routing_header_id = 2
                    AND rt.inspection_status_code <> 'NOT INSPECTED'
                    AND rt.inspection_status_code = Nvl(v_inspection_status,rt.inspection_status_code)))
                   --(RT.ROUTING_HEADER_ID = 2 AND rt.inspection_status_code <> 'NOT INSPECTED'))
              AND RSUP.SUPPLY_TYPE_CODE = 'RECEIVING'
              AND RSL.SHIPMENT_LINE_ID = RSUP.SHIPMENT_LINE_ID
              AND RT.TRANSACTION_ID = RSUP.RCV_TRANSACTION_ID
              AND RT.TRANSACTION_TYPE <> 'UNORDERED'
              -- for all the transactions in rt for which we can putaway, the
              -- transfer_lpn_id should match the lpn being putaway.
              --AND Nvl(rt.transfer_lpn_id,-1)        = Nvl(v_lpn_id,-1)
              -- Fix for 1865886. Commented the above and added the following for lpn
              AND Nvl(v_lpn_id,-1) IN (select nvl(rt2.transfer_lpn_id,-1)
                                         from rcv_transactions rt2
                                        where rt2.transaction_type <> 'DELIVER'
                                        start with rt2.transaction_id = rsup.supply_source_id
                                      connect by prior rt2.transaction_id = rt2.parent_transaction_id
                                    union all
                                       select nvl(rt2.lpn_id,-1)
                                         from rcv_transactions rt2
                                        where rt2.transaction_type not in ('RECEIVE', 'DELIVER')
                                        start with rt2.transaction_id = rsup.supply_source_id
                                      connect by prior rt2.transaction_id = rt2.parent_transaction_id
                                       )
              AND RSUP.to_organization_id = v_org_id
              AND RSH.SHIPMENT_HEADER_ID = RSUP.SHIPMENT_HEADER_ID
        AND  (
               v_lot_number IS NULL OR EXISTS
               (
                 SELECT lot_num
                 FROM   rcv_lots_supply rls
                 WHERE  rls.transaction_id = rsup.supply_source_id
                 AND    rls.lot_num = v_lot_number
               )
             )
        AND  (
               v_lpn_id_to_match IS NULL
               OR (rsup.lpn_id = v_lpn_id_to_match)
             )
            ORDER BY rt.transaction_date;
-- End for Bug 7440217


      x_MatchedRec	                int_req_delivery_lines%ROWTYPE;
      x_record_count		        NUMBER;

      x_remaining_quantity		NUMBER := 0;
      x_remaining_qty_po_uom            NUMBER := 0;
      x_bkp_qty                         NUMBER := 0;
      x_progress			VARCHAR2(3);
      x_converted_trx_qty		NUMBER := 0;
      transaction_ok			BOOLEAN	:= FALSE;
      x_expected_date		        rcv_transactions_interface.expected_receipt_date%TYPE;
      high_range_date		        DATE;
      low_range_date			DATE;
      rows_fetched		        NUMBER := 0;
      x_tolerable_qty		        NUMBER := 0;
      x_first_trans			BOOLEAN := TRUE;
      x_sysdate			        DATE	:= Sysdate;
      current_n                         BINARY_INTEGER := 0;
      insert_into_table                 BOOLEAN := FALSE;
      x_qty_rcv_exception_code          po_line_locations.qty_rcv_exception_code%type;
      tax_amount_factor                 NUMBER;
      lastrecord                        BOOLEAN := FALSE;

      po_asn_uom_qty                    NUMBER;
      po_primary_uom_qty                NUMBER;

      already_allocated_qty             NUMBER := 0;

      x_item_id                         NUMBER;
      x_approved_flag                   VARCHAR(1);
      x_cancel_flag                     VARCHAR(1);
      x_closed_code                     VARCHAR(25);
      x_shipment_type                   VARCHAR(25);
      x_ship_to_organization_id         NUMBER;
      x_ship_to_location_id             NUMBER;
      x_vendor_product_num              VARCHAR(25);
      x_temp_count                      NUMBER;

      x_under_return_tolerance          NUMBER;
      x_qty_rcv_tolerance               NUMBER;
      x_oe_line_qty                     NUMBER;

      l_parent_id                       NUMBER;
      l_receipt_source_code             VARCHAR2(14);
      l_return_status                   VARCHAR2(1);
      l_msg_count                       NUMBER;
      l_msg_data                        VARCHAR2(400);
      l_sh_result_count                 NUMBER;
      l_rma_uom                         VARCHAR2(25); --bug3592116

      l_api_name             CONSTANT VARCHAR2(30) := 'matching_logic';

     l_err_message VARCHAR2(100);
     l_temp_message VARCHAR2(100);
     l_msg_prod VARCHAR2(5);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    --New variables for FP-J Lot/Serial Support
    l_lot_number_to_match  mtl_lot_numbers.lot_number%TYPE;
    l_lpn_id_to_match      NUMBER;
    l_parent_txn_id_to_match NUMBER;
    l_passed_parent_txn_id NUMBER;
    l_wms_po_j_or_higher   BOOLEAN;

    l_patch_j_or_higher    VARCHAR2(3) := 'N';

 --Bug 4004656-Added the local variables for the quantity fields.
 l_rem_qty_trans_uom             NUMBER := 0; -- Remaining quantity to be received in transaction uom
 l_rcv_qty_trans_uom             NUMBER := 0; -- Quantity received in transaction uom
 l_rcv_qty_po_uom               NUMBER := 0; -- Quantity received in uom of the po.
 l_bkp_qty_trans_uom             NUMBER := 0;
 l_trx_qty_po_uom               NUMBER := 0; -- Transaction quantity in the uom of the po.
 l_trx_qty_trans_uom             NUMBER := 0; -- Transaction quantity in the transaction uom.
 l_tol_qty_po_uom               NUMBER := 0; -- Tolerable quantity in the uom of the po.
 --End of fix for Bug 4004656

 l_rcv_tolerance_qty_rma_uom  NUMBER := 0; --Bug 4747997: Tolerance qty in RMA UOM
 l_rcv_tolerance_qty_txn_uom  NUMBER := 0; --Bug 4747997: Tolerance qty in transaction UOM


 BEGIN
    IF (l_debug = 1) THEN
       print_debug('Enter matching_logic: 1 ' || to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
       print_debug('p_receipt_num = ' ||  p_receipt_num, 4);
       print_debug('p_match_type = ' ||  p_match_type, 4);
       print_debug('p_lpn_id = ' ||  p_lpn_id, 4);
       print_debug('n = ' ||  n, 4);
       print_debug('item_id = ' ||  x_cascaded_table(n).item_id, 4);
       print_debug('item_desc = ' ||  x_cascaded_table(n).item_desc, 4);
       print_debug('shipment_header_id = ' ||  x_cascaded_table(n).shipment_header_id, 4);
       print_debug('oe_order_header_id = ' ||  x_cascaded_table(n).oe_order_header_id, 4);
       print_debug('trasnsaction_type = ' ||  x_cascaded_table(n).transaction_type, 4);
       print_debug('error_status = ' ||  x_cascaded_table(n).error_status, 4);
       print_debug('project id = ' ||  x_cascaded_table(n).project_id);
       print_debug('task id = ' || x_cascaded_table(n).task_id);
       print_debug('parent txn id = ' || x_cascaded_table(n).parent_transaction_id);
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT rcv_transactions_gen_sa;

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
      l_patch_j_or_higher := 'Y';
      IF (l_debug = 1) THEN
        print_debug('WMS and PO patch levels are J or higher', 4);
      END IF;
    ELSE
      l_wms_po_j_or_higher := FALSE;
      l_patch_j_or_higher := 'N';
      IF (l_debug = 1) THEN
        print_debug('Either WMS or/and PO patch level(s) are lower than J', 4);
      END IF;
    END IF;

    -- the following steps will create a set of rows linking the line_record with
    -- its corresponding po_line_location rows until the quantity value from
    -- the asn is consumed.  (Cascade)
    IF (((x_cascaded_table(n).shipment_header_id IS NOT NULL) OR
	 (x_cascaded_table(n).oe_order_header_id IS NOT NULL)) AND
	((x_cascaded_table(n).item_id IS NOT NULL OR
	  (x_cascaded_table(n).item_desc IS NOT NULL
-- For Bug 7440217 Added LCM Doc type
	   AND p_match_type in ('ASN', 'LCM')))) AND
-- End for Bug 7440217
	(x_cascaded_table(n).error_status IN ('S','W'))) THEN

       -- Copy record from main table to temp table

       current_n := 1;
       temp_cascaded_table(current_n) := x_cascaded_table(n);
       IF (l_debug = 1) THEN
          print_debug('copied rec from main table to temp table', 4);
       END IF;

       -- Get all rows which meet this condition
       IF (x_cascaded_table(n).transaction_type = 'RECEIVE')
	 OR (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
	  IF (l_debug = 1) THEN
	     print_debug('Transaction type is receive or deliver with match type:'||p_match_type||':txn_type:'||x_cascaded_table(n).transaction_type, 4);
	  END IF;

	  l_progress := '20';
	  IF p_match_type = 'ASN' THEN
	     IF (l_debug = 1) THEN
   	     print_debug('parameters for Opening for ASN', 4);
   	     print_debug('shipment_header_id'||temp_cascaded_table(current_n).shipment_header_id,4);
   	     print_debug('shipment_line_id'||temp_cascaded_table(current_n).shipment_line_id, 4);
   	     print_debug('item_id'||temp_cascaded_table(current_n).item_id, 4);
   	     print_debug('po_header_id'||temp_cascaded_table(current_n).po_header_id, 4);
   	     print_debug('p_lpn_id'||p_lpn_id, 4);
   	     print_debug('item_desc'||temp_cascaded_table(current_n).item_desc, 4);
	     END IF;
	     IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN
		IF (l_debug = 1) THEN
		   print_debug('Opening for ASN standard receipt', 4);
		END IF;
		OPEN asn_receipt_lines
		  (temp_cascaded_table(current_n).shipment_header_id,
		   temp_cascaded_table(current_n).shipment_line_id,
		   temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   l_patch_j_or_higher);

		OPEN count_asn_receipt_lines
		  (temp_cascaded_table(current_n).shipment_header_id,
		   temp_cascaded_table(current_n).shipment_line_id,
		   temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   l_patch_j_or_higher);
	      ELSE    -- x_cascaded_table(n).transaction_type = 'DELIVER'
		IF (l_debug = 1) THEN
		   print_debug('Opening for ASN direct receipt', 4);
		END IF;
		OPEN asn_direct_lines
		  (temp_cascaded_table(current_n).shipment_header_id,
		   temp_cascaded_table(current_n).shipment_line_id,
		   temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   l_patch_j_or_higher);

		OPEN count_asn_direct_lines
		  (temp_cascaded_table(current_n).shipment_header_id,
		   temp_cascaded_table(current_n).shipment_line_id,
		   temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   l_patch_j_or_higher);
	     END IF;

-- For Bug 7440217 Code for Doc type LCM
	   ELSIF p_match_type = 'LCM' THEN
	     IF (l_debug = 1) THEN
   	     print_debug('parameters for Opening for LCM', 4);
   	     print_debug('shipment_header_id'||temp_cascaded_table(current_n).shipment_header_id,4);
   	     print_debug('shipment_line_id'||temp_cascaded_table(current_n).shipment_line_id, 4);
   	     print_debug('item_id'||temp_cascaded_table(current_n).item_id, 4);
   	     print_debug('po_header_id'||temp_cascaded_table(current_n).po_header_id, 4);
   	     print_debug('p_lpn_id'||p_lpn_id, 4);
   	     print_debug('item_desc'||temp_cascaded_table(current_n).item_desc, 4);
	     END IF;
	     IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN
		IF (l_debug = 1) THEN
		   print_debug('Opening for LCM standard receipt', 4);
		END IF;
		OPEN lcm_receipt_lines
		  (temp_cascaded_table(current_n).shipment_header_id,
		   temp_cascaded_table(current_n).shipment_line_id,
		   temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   l_patch_j_or_higher);

		OPEN count_lcm_receipt_lines
		  (temp_cascaded_table(current_n).shipment_header_id,
		   temp_cascaded_table(current_n).shipment_line_id,
		   temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   l_patch_j_or_higher);
	      ELSE    -- x_cascaded_table(n).transaction_type = 'DELIVER'
		IF (l_debug = 1) THEN
		   print_debug('Opening for LCM direct receipt', 4);
		END IF;
		OPEN lcm_direct_lines
		  (temp_cascaded_table(current_n).shipment_header_id,
		   temp_cascaded_table(current_n).shipment_line_id,
		   temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   l_patch_j_or_higher);

		OPEN count_lcm_direct_lines
		  (temp_cascaded_table(current_n).shipment_header_id,
		   temp_cascaded_table(current_n).shipment_line_id,
		   temp_cascaded_table(current_n).item_id,
		   temp_cascaded_table(current_n).po_header_id,
		   p_lpn_id,
		   temp_cascaded_table(current_n).item_desc,
		   temp_cascaded_table(current_n).project_id,
		   temp_cascaded_table(current_n).task_id,
		   l_patch_j_or_higher);
	     END IF;
-- End for Bug 7440217

	   ELSIF p_match_type = 'INTRANSIT SHIPMENT' THEN
	     l_progress := '30';
	     IF (l_debug = 1) THEN
   	     print_debug('Opening cursor in matching for intransit shipments FOR parameters:',4);
   	     print_debug('shipment_header_id:'||temp_cascaded_table(current_n).shipment_header_id,4);
   	     print_debug('shipment_line_id:'||temp_cascaded_table(current_n).shipment_line_id,4);
   	     print_debug('item_id:'||temp_cascaded_table(current_n).item_id,4);
   	     print_debug('to_organization_id:'||temp_cascaded_table(current_n).to_organization_id,4);
   	     print_debug('expected_receipt_date:'||temp_cascaded_table(current_n).expected_receipt_date,4);
   	     print_debug('p_lpn_id'||p_lpn_id, 4);
	     print_debug('serial_number'||temp_cascaded_table(current_n).serial_number,4);
	     END IF;
	     OPEN int_req_receipt_lines
	       (temp_cascaded_table(current_n).shipment_header_id,
		temp_cascaded_table(current_n).shipment_line_id,
		temp_cascaded_table(current_n).item_id,
		temp_cascaded_table(current_n).to_organization_id,
		temp_cascaded_table(current_n).expected_receipt_date,
		temp_cascaded_table(current_n).project_id,
		temp_cascaded_table(current_n).task_id,
		p_lpn_id,
                temp_cascaded_table(current_n).lot_number, --9229228
		temp_cascaded_table(current_n).serial_number);-- 9651496,9764650

	     -- count_shipments just gets the count of rows found in shipments
	     OPEN count_int_req_receipt_lines
	       (temp_cascaded_table(current_n).shipment_header_id,
		temp_cascaded_table(current_n).shipment_line_id,
	        temp_cascaded_table(current_n).item_id,
		temp_cascaded_table(current_n).to_organization_id,
		temp_cascaded_table(current_n).expected_receipt_date,
		temp_cascaded_table(current_n).project_id,
		temp_cascaded_table(current_n).task_id,
		p_lpn_id ,
                temp_cascaded_table(current_n).lot_number, --9229228
		temp_cascaded_table(current_n).serial_number);-- 9651496,9764650
	   ELSIF p_match_type = 'RMA' THEN
	     l_progress := '30.1';
	     IF (l_debug = 1) THEN
		print_debug('Opening cursor in matching for rmas FOR parameters:',4);
		print_debug('oe_order_header_id:'||temp_cascaded_table(current_n).oe_order_header_id,4);
		print_debug('oe_order_line_id:'||temp_cascaded_table(current_n).oe_order_line_id,4);
		print_debug('item_id:'||temp_cascaded_table(current_n).item_id,4);
		print_debug('to_organization_id:'||temp_cascaded_table(current_n).to_organization_id,4);
		print_debug('primary_unit_of_measure:'||temp_cascaded_table(current_n).primary_unit_of_measure,4);
		print_debug('expected_receipt_date:'||temp_cascaded_table(current_n).expected_receipt_date,4);
		print_debug('project id ' ||  temp_cascaded_table(current_n).project_id);
		print_debug('task_id : ' || temp_cascaded_table(current_n).task_id);
	     END IF;
	     OPEN rma_receipt_lines
	       (temp_cascaded_table(current_n).oe_order_header_id,
	        temp_cascaded_table(current_n).oe_order_line_id,
	        temp_cascaded_table(current_n).item_id,
	        temp_cascaded_table(current_n).to_organization_id,
		temp_cascaded_table(current_n).primary_unit_of_measure,
		temp_cascaded_table(current_n).expected_receipt_date,
		temp_cascaded_table(current_n).project_id,
		temp_cascaded_table(current_n).task_id);

	     -- count_shipments just gets the count of rows found in shipments
	     OPEN count_rma_receipt_lines
	       (temp_cascaded_table(current_n).oe_order_header_id,
		temp_cascaded_table(current_n).oe_order_line_id,
		temp_cascaded_table(current_n).item_id,
		temp_cascaded_table(current_n).to_organization_id,
		temp_cascaded_table(current_n).primary_unit_of_measure,
		temp_cascaded_table(current_n).expected_receipt_date,
		temp_cascaded_table(current_n).project_id,
		temp_cascaded_table(current_n).task_id);
	  END IF; -- p_match_type = 'ASN'

	ELSIF (x_cascaded_table(n).transaction_type = 'STD_DELIVER') THEN
	  IF (l_debug = 1) THEN
	     print_debug('Transaction type is std. delivery',4);
	  END IF;
	  l_progress := '40';

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
     * int_req_delivery_lines and count_std_distributions (for int ship/int req)
     * , rma_delivery_lines and count_rma_delivery_lines (for RMA)
     */
	  IF p_match_type = 'INTRANSIT SHIPMENT' THEN
	     IF (l_debug = 1) THEN
   	     print_debug('Opening cursor in matching for intransit shipments FOR parameters:',4);
   	     print_debug('shipment_header_id:'||temp_cascaded_table(current_n).shipment_header_id,4);
   	     print_debug('shipment_line_id:'||temp_cascaded_table(current_n).shipment_line_id,4);
   	     print_debug('item_id:'||temp_cascaded_table(current_n).item_id,4);
   	     print_debug('to_organization_id:'||temp_cascaded_table(current_n).to_organization_id,4);
   	     print_debug('p_receipt_num:'||p_receipt_num,4);
   	     print_debug('expected_receipt_date:'||temp_cascaded_table(current_n).expected_receipt_date,4);
   	     print_debug('inspection_status_code:'||temp_cascaded_table(current_n).inspection_status_code,4);
   	     print_debug('p_lpn_id:'||temp_cascaded_table(current_n).p_lpn_id,4);
	     END IF;

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

       OPEN int_req_delivery_lines(
         temp_cascaded_table(current_n).shipment_header_id,
         temp_cascaded_table(current_n).shipment_line_id,
         temp_cascaded_table(current_n).item_id,
         temp_cascaded_table(current_n).to_organization_id,
         p_receipt_num,
         temp_cascaded_table(current_n).expected_receipt_date,
         temp_cascaded_table(current_n).inspection_status_code,
         temp_cascaded_table(current_n).p_lpn_id,
         l_lot_number_to_match,
         l_lpn_id_to_match,
         l_parent_txn_id_to_match);

	     -- count_shipments just gets the count of rows found in shipments
       OPEN count_int_req_delivery_lines(
         temp_cascaded_table(current_n).shipment_header_id,
         temp_cascaded_table(current_n).shipment_line_id,
         temp_cascaded_table(current_n).item_id,
         temp_cascaded_table(current_n).to_organization_id,
         p_receipt_num,
         temp_cascaded_table(current_n).expected_receipt_date,
         temp_cascaded_table(current_n).inspection_status_code,
         temp_cascaded_table(current_n).p_lpn_id,
         l_lot_number_to_match,
         l_lpn_id_to_match,
         l_parent_txn_id_to_match);
     ELSIF p_match_type = 'RMA' THEN
	     IF (l_debug = 1) THEN
   	     print_debug('Opening cursor in matching for rmas FOR parameters:',4);
   	     print_debug('oe_order_header_id:'||temp_cascaded_table(current_n).oe_order_header_id,4);
   	     print_debug('oe_order_line_id:'||temp_cascaded_table(current_n).oe_order_line_id,4);
   	     print_debug('item_id:'||temp_cascaded_table(current_n).item_id,4);
   	     print_debug('to_organization_id:'||temp_cascaded_table(current_n).to_organization_id,4);
   	     print_debug('p_receipt_num:'||p_receipt_num,4);
   	     print_debug('expected_receipt_date:'||temp_cascaded_table(current_n).expected_receipt_date,4);
   	     print_debug('inspection_status_code:'||temp_cascaded_table(current_n).inspection_status_code,4);
   	     print_debug('p_lpn_id:'||temp_cascaded_table(current_n).p_lpn_id,4);
	     END IF;

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

       OPEN rma_delivery_lines(
         temp_cascaded_table(current_n).oe_order_header_id,
         temp_cascaded_table(current_n).oe_order_line_id,
         temp_cascaded_table(current_n).item_id,
         temp_cascaded_table(current_n).to_organization_id,
         p_receipt_num,
         temp_cascaded_table(current_n).expected_receipt_date,
         temp_cascaded_table(current_n).inspection_status_code,
         temp_cascaded_table(current_n).p_lpn_id,
         l_lot_number_to_match,
         l_lpn_id_to_match,
         l_parent_txn_id_to_match);

	     -- count_shipments just gets the count of rows found in shipments
       OPEN count_rma_delivery_lines(
         temp_cascaded_table(current_n).oe_order_header_id,
         temp_cascaded_table(current_n).oe_order_line_id,
         temp_cascaded_table(current_n).item_id,
         temp_cascaded_table(current_n).to_organization_id,
         p_receipt_num,
         temp_cascaded_table(current_n).expected_receipt_date,
         temp_cascaded_table(current_n).inspection_status_code,
         temp_cascaded_table(current_n).p_lpn_id,
         l_lot_number_to_match,
         l_lpn_id_to_match,
         l_parent_txn_id_to_match);

     ELSIF p_match_type = 'ASN' THEN
               IF (l_debug = 1) THEN
                  print_debug('Opening cursor in matching for ASNs FOR parameters:',4);
                  print_debug('shipment_header_id:'||temp_cascaded_table(current_n).shipment_header_id,4);
                  print_debug('shipment_line_id:'||temp_cascaded_table(current_n).shipment_line_id,4);
                  print_debug('item_id:'||temp_cascaded_table(current_n).item_id,4);
                  print_debug('to_organization_id:'||temp_cascaded_table(current_n).to_organization_id,4);
                  print_debug('p_receipt_num:'||p_receipt_num,4);
                  print_debug('expected_receipt_date:'||temp_cascaded_table(current_n).expected_receipt_date,4);
                  print_debug('inspection_status_code:'||temp_cascaded_table(current_n).inspection_status_code,4);
                  print_debug('p_lpn_id:'||temp_cascaded_table(current_n).p_lpn_id,4);
               END IF;

               IF (l_wms_po_j_or_higher) THEN
                  l_lot_number_to_match := temp_cascaded_table(current_n).lot_number;
                  l_lpn_id_to_match     := temp_cascaded_table(current_n).p_lpn_id;
				  l_parent_txn_id_to_match := l_passed_parent_txn_id; -- 9879753
                ELSE
                  l_lot_number_to_match := NULL;
                  l_lpn_id_to_match     := NULL;
				  l_parent_txn_id_to_match := NULL; -- 9879753
               END IF;

               IF (l_debug = 1) THEN
                  print_debug('l_lot_number_to_match: ' || l_lot_number_to_match, 4);
                  print_debug('l_lpn_id_to_match: ' || l_lpn_id_to_match, 4);
				  print_debug('::bug9879753::l_parent_txn_id_to_match: ' || l_parent_txn_id_to_match, 4); -- 9879753
               END IF;
               OPEN asn_delivery_lines(
                                       temp_cascaded_table(current_n).shipment_header_id,
                                       temp_cascaded_table(current_n).shipment_line_id,
                                       temp_cascaded_table(current_n).item_id,
                                       temp_cascaded_table(current_n).to_organization_id,
                                       p_receipt_num,
                                       temp_cascaded_table(current_n).expected_receipt_date,
                                       temp_cascaded_table(current_n).inspection_status_code,
                                       temp_cascaded_table(current_n).p_lpn_id,
                                       l_lot_number_to_match,
                                       l_lpn_id_to_match,
                                       l_parent_txn_id_to_match); -- 9879753

               -- count_shipments just gets the count of rows found in shipments
               OPEN count_asn_delivery_lines(
                                             temp_cascaded_table(current_n).shipment_header_id,
                                             temp_cascaded_table(current_n).shipment_line_id,
                                             temp_cascaded_table(current_n).item_id,
                                             temp_cascaded_table(current_n).to_organization_id,
                                             p_receipt_num,
                                             temp_cascaded_table(current_n).expected_receipt_date,
                                             temp_cascaded_table(current_n).inspection_status_code,
                                             temp_cascaded_table(current_n).p_lpn_id,
                                             l_lot_number_to_match,
                                             l_lpn_id_to_match,
                                             l_parent_txn_id_to_match); -- 9879753

-- For Bug 7440217 Code of rdoc type LCM
--	  END IF; -- p_match_type = 'INTRANSIT SHIPMENT'
       ELSIF p_match_type = 'LCM' THEN
               IF (l_debug = 1) THEN
                  print_debug('Opening cursor in matching for LCMs FOR parameters:',4);
                  print_debug('shipment_header_id:'||temp_cascaded_table(current_n).shipment_header_id,4);
                  print_debug('shipment_line_id:'||temp_cascaded_table(current_n).shipment_line_id,4);
                  print_debug('item_id:'||temp_cascaded_table(current_n).item_id,4);
                  print_debug('to_organization_id:'||temp_cascaded_table(current_n).to_organization_id,4);
                  print_debug('p_receipt_num:'||p_receipt_num,4);
                  print_debug('expected_receipt_date:'||temp_cascaded_table(current_n).expected_receipt_date,4);
                  print_debug('inspection_status_code:'||temp_cascaded_table(current_n).inspection_status_code,4);
                  print_debug('p_lpn_id:'||temp_cascaded_table(current_n).p_lpn_id,4);
               END IF;

               IF (l_wms_po_j_or_higher) THEN
                  l_lot_number_to_match := temp_cascaded_table(current_n).lot_number;
                  l_lpn_id_to_match     := temp_cascaded_table(current_n).p_lpn_id;
                ELSE
                  l_lot_number_to_match := NULL;
                  l_lpn_id_to_match     := NULL;
               END IF;

               IF (l_debug = 1) THEN
                  print_debug('l_lot_number_to_match: ' || l_lot_number_to_match, 4);
                  print_debug('l_lpn_id_to_match: ' || l_lpn_id_to_match, 4);
               END IF;
               OPEN lcm_delivery_lines(
                                       temp_cascaded_table(current_n).shipment_header_id,
                                       temp_cascaded_table(current_n).shipment_line_id,
                                       temp_cascaded_table(current_n).item_id,
                                       temp_cascaded_table(current_n).to_organization_id,
                                       p_receipt_num,
                                       temp_cascaded_table(current_n).expected_receipt_date,
                                       temp_cascaded_table(current_n).inspection_status_code,
                                       temp_cascaded_table(current_n).p_lpn_id,
                                       l_lot_number_to_match,
                                       l_lpn_id_to_match);

               -- count_shipments just gets the count of rows found in shipments
               OPEN count_lcm_delivery_lines(
                                             temp_cascaded_table(current_n).shipment_header_id,
                                             temp_cascaded_table(current_n).shipment_line_id,
                                             temp_cascaded_table(current_n).item_id,
                                             temp_cascaded_table(current_n).to_organization_id,
                                             p_receipt_num,
                                             temp_cascaded_table(current_n).expected_receipt_date,
                                             temp_cascaded_table(current_n).inspection_status_code,
                                             temp_cascaded_table(current_n).p_lpn_id,
                                             l_lot_number_to_match,
                                             l_lpn_id_to_match);


	  END IF; -- p_match_type = 'LCM'
-- End for Bug 7440217

       END IF;

       l_progress := '60';
       -- Assign shipped quantity to remaining quantity
    -- x_remaining_quantity	 := temp_cascaded_table(current_n).quantity;  --Bug 4004656
       l_rem_qty_trans_uom       := temp_cascaded_table(current_n).quantity;  --Bug 4004656
       -- used for decrementing cum qty for first record
    -- x_bkp_qty                 := x_remaining_quantity;  --Bug 4004656
    -- x_remaining_qty_po_uom    := 0;                     --Bug 4004656
       l_bkp_qty_trans_uom       := l_rem_qty_trans_uom;   --Bug 4004656
       l_rcv_qty_trans_uom       := 0;		           --Bug 4004656
       l_rcv_qty_po_uom          := 0;                     --Bug 4004656
       -- Calculate tax_amount_factor for calculating tax_amount for
       -- each cascaded line
       IF Nvl(temp_cascaded_table(current_n).tax_amount,0) <> 0 THEN
          /* Bug 4567809 -Modified the below assignment */
	  --tax_amount_factor := temp_cascaded_table(current_n).tax_amount/x_remaining_quantity;
	  tax_amount_factor := temp_cascaded_table(current_n).tax_amount/l_rem_qty_trans_uom;
	  /* End of fix for Bug 4567809 */
	ELSE
	  tax_amount_factor := 0;
       END IF;

       x_first_trans    := TRUE;
       transaction_ok   := FALSE;

       l_progress := '70';
       -- Get the count of the number of records depending on the
       -- the transaction type
       IF (x_cascaded_table(n).transaction_type = 'RECEIVE')
	 OR (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
	  l_progress := '80';

 	  IF p_match_type = 'ASN' THEN
	     IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN
		FETCH count_asn_receipt_lines INTO x_record_count;
	      ELSE  -- (x_cascaded_table(n).transaction_type = 'DELIVER')
		FETCH count_asn_direct_lines INTO x_record_count;
	     END IF;

-- For Bug 7440217 Added the code below for LCM changes
          ELSIF p_match_type = 'LCM' THEN
	     IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN
		FETCH count_lcm_receipt_lines INTO x_record_count;
	      ELSE  -- (x_cascaded_table(n).transaction_type = 'DELIVER')
		FETCH count_lcm_direct_lines INTO x_record_count;
	     END IF;
-- End for Bug 7440217

      ELSIF p_match_type = 'INTRANSIT SHIPMENT' THEN
       FETCH count_int_req_receipt_lines INTO x_record_count;
	   ELSIF p_match_type = 'RMA' THEN
	     FETCH count_rma_receipt_lines INTO x_record_count;
	  END IF;
	ELSIF (x_cascaded_table(n).transaction_type = 'STD_DELIVER') THEN
	  l_progress := '90';
	  IF p_match_type = 'INTRANSIT SHIPMENT' THEN
	     FETCH count_int_req_delivery_lines INTO x_record_count;
	   ELSIF p_match_type = 'RMA' THEN
	     FETCH count_rma_delivery_lines INTO x_record_count;
	   ELSIF p_match_type = 'ASN' THEN
             FETCH count_asn_delivery_lines INTO x_record_count;
-- For Bug 7440217 LCm Changes
       ELSIF p_match_type = 'LCM' THEN
             FETCH count_lcm_delivery_lines INTO x_record_count;
-- End for Bug 7440217
	  END IF;
       END IF;
       l_progress := '100';

       IF (l_debug = 1) THEN
          print_debug('Initial Rows fetched into matching cursor :'||x_record_count,4);
       END IF;

       LOOP
	  -- Fetch the appropriate record
	  l_progress := '110';
	  IF (x_cascaded_table(n).transaction_type = 'RECEIVE')
	    OR (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
	     l_progress := '120';

	     IF p_match_type = 'ASN' THEN
		IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN
		   FETCH asn_receipt_lines INTO x_MatchedRec;
		   IF (asn_receipt_lines%NOTFOUND) THEN
		      lastrecord := TRUE;
		   END IF;
		   rows_fetched := asn_receipt_lines%rowcount;

		 ELSE  --IF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
		   FETCH asn_direct_lines INTO x_MatchedRec;
		   IF (asn_direct_lines%NOTFOUND) THEN
		      lastrecord := TRUE;
		   END IF;
		   rows_fetched := asn_direct_lines%rowcount;

		END IF;

-- For Bug 7440217 Added for LCM Changes
       ELSIF p_match_type = 'LCM' THEN
		IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN
		   FETCH lcm_receipt_lines INTO x_MatchedRec;
		   IF (lcm_receipt_lines%NOTFOUND) THEN
		      lastrecord := TRUE;
		   END IF;
		   rows_fetched := lcm_receipt_lines%rowcount;

		 ELSE  --IF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
		   FETCH lcm_direct_lines INTO x_MatchedRec;
		   IF (lcm_direct_lines%NOTFOUND) THEN
		      lastrecord := TRUE;
		   END IF;
		   rows_fetched := lcm_direct_lines%rowcount;
		END IF;
-- End for Bug 7440217


	      ELSIF p_match_type = 'INTRANSIT SHIPMENT' THEN
		FETCH int_req_receipt_lines INTO x_MatchedRec;
		IF (int_req_receipt_lines%NOTFOUND) THEN
		   lastrecord := TRUE;
		END IF;
		rows_fetched := int_req_receipt_lines%rowcount;
	      ELSIF p_match_type = 'RMA' THEN
		FETCH rma_receipt_lines INTO x_MatchedRec;
		IF (rma_receipt_lines%NOTFOUND) THEN
		   lastrecord := TRUE;
		END IF;
		rows_fetched := rma_receipt_lines%rowcount;
	     END IF;
	   ELSIF (x_cascaded_table(n).transaction_type = 'STD_DELIVER') THEN
	     l_progress := '130';
	     IF p_match_type = 'INTRANSIT SHIPMENT' THEN
		FETCH int_req_delivery_lines INTO x_MatchedRec;
		IF (int_req_delivery_lines%NOTFOUND) THEN
		   lastrecord := TRUE;
		END IF;
		rows_fetched := int_req_delivery_lines%rowcount;
	      ELSIF p_match_type = 'RMA' THEN
		FETCH rma_delivery_lines INTO x_MatchedRec;
		IF (rma_delivery_lines%NOTFOUND) THEN
		   lastrecord := TRUE;
		END IF;
		rows_fetched := rma_delivery_lines%rowcount;
	      ELSIF p_match_type = 'ASN' THEN
                FETCH asn_delivery_lines INTO x_MatchedRec;
                IF (asn_delivery_lines%NOTFOUND) THEN
                   lastrecord := TRUE;
                END IF;
                rows_fetched := asn_delivery_lines%rowcount;
-- For Bug 7440217 Added for LCM changes
          ELSIF p_match_type = 'LCM' THEN
                FETCH lcm_delivery_lines INTO x_MatchedRec;
                IF (lcm_delivery_lines%NOTFOUND) THEN
                   lastrecord := TRUE;
                END IF;
                rows_fetched := lcm_delivery_lines%rowcount;
-- End for Bug 7440217
	     END IF;
	  END IF;
	  IF (l_debug = 1) THEN
   	  print_debug('Row fetched from matching cursor and being processed',4);
   	--print_debug('Remaining qty:'||x_remaining_quantity,4); --Bug 4004656
	  print_debug('Remaining qty:'||l_rem_qty_trans_uom,4);  --Bug 4004656
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
	  l_progress := '150';

            /* Bug 4004656 -Commented the following statement
	    IF (lastrecord OR x_remaining_quantity <= 0) THEN */
            /* Bug 4747997: We have to compare the rounded off values by 5 decimal places,
                            as the value hold by this variable is non-rounded value returned
                            from the API rcv_transactions_interface_sv.convert_into_correct_qty() */
	    IF (lastrecord OR round(l_rem_qty_trans_uom,5) <=0) THEN --Bug 4004656, Bug:4747997
	     IF (l_debug = 1) THEN
   	     print_debug('No more rows or the remaining qty is less than zero',4);
	     END IF;

	     IF NOT x_first_trans  THEN
		-- x_first_trans has been reset which means some cascade has
		-- happened. Otherwise current_n = 1
		current_n := current_n -1 ;
	     END IF;

	     -- do the tolerance act here

	     -- lastrecord...we have run out of rows and
	     -- we still have quantity to allocate

	     -- Assuming that one cannot over receive for PO's
	     -- defaulting the value of x_qty_rcv_exception_code to REJECT
	     --
	     -- If one can over receive, then this initialisation should
	     -- be cahged to include the actual value.
	     /* Bug 4004656 -Commented the following statement
	     IF x_remaining_quantity > 0   THEN */
	     IF round(l_rem_qty_trans_uom,5) > 0 THEN --Bug 4747997
		IF (l_debug = 1) THEN
		   print_debug('No more recs but still qty left',4);
		END IF;
		IF NOT x_first_trans THEN
		   IF (l_debug = 1) THEN
		      print_debug('Atleast one row returned in matching cursor',4);
		   END IF;
		   -- we had got atleast some rows from our shipments cursor
		   -- we have atleast one row cascaded (not null line_location_id)
-- For Bug 7440217 for LCM changes
		   IF p_match_type IN ('ASN', 'LCM') AND
-- End for Bug 7440217
			Nvl(x_cascaded_table(n).transaction_type,'DELIVER') <> 'STD_DELIVER' THEN
		      -- for ASN, we will deal with the exception status
		      -- in po matching ????
		      l_sh_result_count := temp_cascaded_table.COUNT;

		      -- po matchings input should include the lines
		      -- already detailed by shipment matching
		      IF l_sh_result_count > 0 THEN
			 FOR i in 1..l_sh_result_count LOOP
			    l_po_in_cascaded_table(i) := temp_cascaded_table(i);
			 END LOOP;
		      END IF;

		      IF temp_cascaded_table(l_sh_result_count).quantity <> 0 THEN
			 l_sh_result_count := l_sh_result_count + 1;
		      END IF;

		      -- put a new line at the end
		      -- with quantity equals remaining quanitity
		      l_po_in_cascaded_table(l_sh_result_count) := temp_cascaded_table(1);

		      /* Bug 4567809 -Modifying the assignment of quantity to l_rem_qty_trans_uom */

		      --l_po_in_cascaded_table(l_sh_result_count).quantity := x_remaining_quantity
		      l_po_in_cascaded_table(l_sh_result_count).quantity := l_rem_qty_trans_uom;

		      /* End of fix for Bug 4567809 */


		      inv_rcv_txn_interface.matching_logic
			(x_return_status      =>   l_return_status,
			 x_msg_count          =>   l_msg_count,
			 x_msg_data           =>   l_msg_data,
			 x_cascaded_table     =>   l_po_in_cascaded_table,
			 n                    =>   l_sh_result_count,
			 temp_cascaded_table  =>   l_po_out_cascaded_table,
			 p_receipt_num        =>   p_receipt_num,
			 p_shipment_header_id =>   temp_cascaded_table(1).shipment_header_id,
			 p_lpn_id             =>   p_lpn_id
			 );

		      IF (l_debug = 1) THEN
			 print_debug('after po matching  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
			 print_debug('after po matching  l_return_status = '|| l_return_status, 4);
			 print_debug('after po matching  l_msg_count = '|| l_msg_count, 4);
			 print_debug('after po matching  l_msg_data = '||l_msg_data , 4);
		      END IF;

		      IF l_return_status = fnd_api.g_ret_sts_error THEN
			 RAISE fnd_api.g_exc_error;
		      END IF;
		      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
			 RAISE fnd_api.g_exc_unexpected_error;
		      END IF;
		      IF l_po_in_cascaded_table(l_sh_result_count).error_status = 'E' THEN
			 x_cascaded_table(n).error_status := l_po_in_cascaded_table(l_sh_result_count).error_status;
			 x_cascaded_table(n).error_message := l_po_in_cascaded_table(l_sh_result_count).error_message;
			 IF (l_debug = 1) THEN
			    print_debug('error calling po matching'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
			 END IF;
			 IF temp_cascaded_table.COUNT > 0 THEN
			    FOR i in 1..temp_cascaded_table.COUNT LOOP
			       temp_cascaded_table.DELETE(i);
			    END LOOP;
			 END IF;
		       else
			 -- need to consolidate the qty for each shipment line ???
			 -- now just append the qty detailed from PO to the end
			 IF l_po_out_cascaded_table.COUNT > 0 THEN
		      FOR i in 1..l_po_out_cascaded_table.COUNT LOOP
			 temp_cascaded_table(l_sh_result_count + i - 1) := l_po_out_cascaded_table(i);
		      END LOOP;
		   END IF;
		END IF;
-- For Bug 7440217 for LCM changes
		x_qty_rcv_exception_code := p_match_type;
-- End for Bug 7440217
	      ELSIF p_match_type = 'RMA' THEN
		l_sh_result_count := temp_cascaded_table.COUNT;
		OE_RMA_Receiving.Get_RMA_Tolerances( temp_cascaded_table(l_sh_result_count).oe_order_line_id,
       				 		     x_under_return_tolerance,
       						     x_qty_rcv_tolerance,
       						     l_return_status,
        					     l_msg_count,
        					     l_msg_data );

		IF x_qty_rcv_tolerance IS NOT NULL THEN
		   select ordered_qty
		     into x_oe_line_qty
		     from oe_po_enter_receipts_v
		     where oe_order_line_id =
		     temp_cascaded_table(l_sh_result_count).oe_order_line_id;

		  /* Bug 4004656 - Commented out the following line
		  IF (x_remaining_quantity > (x_oe_line_qty * (x_qty_rcv_tolerance/100)))*/

 /* Bug 4747997: When Over shipment tolerance is set for RMA, the tolerance value
                 is getting calculated in RMA uom instead of transaction uom.
                 So, We need to convert the tolerance qty for RMA to transaction uom. */
		   l_rcv_tolerance_qty_rma_uom := x_oe_line_qty * (x_qty_rcv_tolerance/100);

		   l_rcv_tolerance_qty_txn_uom := rcv_transactions_interface_sv.convert_into_correct_qty(
		                                     l_rcv_tolerance_qty_rma_uom,
		                                     x_MatchedRec.unit_of_measure,
		                                     temp_cascaded_table(1).item_id,
		                                     temp_cascaded_table(1).unit_of_measure);

		  IF (round(l_rem_qty_trans_uom,5) > round(l_rcv_tolerance_qty_txn_uom,5))--Bug 4004656, Bug 4747997
		  THEN
		      x_qty_rcv_exception_code := 'REJECT';
		    ELSE
     		  /* Bug 4004656 - Commented out the following line
		      temp_cascaded_table(l_sh_result_count).quantity :=
			temp_cascaded_table(l_sh_result_count).quantity + x_remaining_quantity; */
	              temp_cascaded_table(l_sh_result_count).quantity :=
			temp_cascaded_table(l_sh_result_count).quantity + l_rem_qty_trans_uom; --Bug 4004656
     		  /* Bug 4004656 - Commented out the following line
		      temp_cascaded_table(l_sh_result_count).primary_quantity :=
			temp_cascaded_table(l_sh_result_count).primary_quantity + x_remaining_quantity; */
		      temp_cascaded_table(l_sh_result_count).primary_quantity :=
			temp_cascaded_table(l_sh_result_count).primary_quantity + l_rem_qty_trans_uom;
		      x_qty_rcv_exception_code := 'RMA';
		   END IF;
		 ELSE
		   x_qty_rcv_exception_code := 'REJECT';
		END IF;
	      ELSE -- p_match_type = 'ASN';
		x_qty_rcv_exception_code := 'REJECT';
	     END IF;
	     IF (l_debug = 1) THEN
		print_debug('x_qty_rcv_exception_code:'||x_qty_rcv_exception_code,4);
	     END IF;

	     IF x_qty_rcv_exception_code = 'REJECT' THEN
		IF (l_debug = 1) THEN
		   print_debug('rejecting and deleting matched rows since over the tolerance',4);
		END IF;
		x_cascaded_table(n).error_status := 'E';
		x_cascaded_table(n).error_message := 'INV_RCV_QTY_OVER_TOLERANCE';

		IF temp_cascaded_table.COUNT > 0 THEN
		   FOR i in 1..temp_cascaded_table.COUNT LOOP
		      temp_cascaded_table.DELETE(i);
		   END LOOP;
		END IF;
	     END IF;
	   ELSE -- for if  remaining_qty > 0 and not x_first_trans
	     IF (l_debug = 1) THEN
		print_debug('first transaction and qty remains so over tolerance',4);
	     END IF;
	     x_cascaded_table(n).error_status := 'E';
	     x_cascaded_table(n).error_message := 'INV_RCV_QTY_OVER_TOLERANCE';

	     IF rows_fetched = 0 THEN
		x_cascaded_table(n).error_message := 'INV_RCV_NO_ROWS';
		IF (l_debug = 1) THEN
		   print_debug('matching_logic - No rows were retrieved from cursor ', 4);
		END IF;
	      ELSIF x_first_trans THEN
		x_cascaded_table(n).error_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
		IF (l_debug = 1) THEN
		   print_debug('matching_logic -  No rows were cascaded', 4);
		END IF;
	     END IF;

	     -- Delete the temp_cascaded_table just to be sure
	     IF temp_cascaded_table.COUNT > 0 THEN
		FOR i IN 1..temp_cascaded_table.COUNT LOOP
		   temp_cascaded_table.DELETE(i);
		END LOOP;
	     END IF;
	  END IF;
     ELSE -- for if x_remaining_qty > 0
       NULL;
    END IF;

    -- close cursors
    IF int_req_receipt_lines%isopen THEN
       CLOSE int_req_receipt_lines;
    END IF;

    IF count_int_req_receipt_lines%isopen THEN
       CLOSE count_int_req_receipt_lines;
    END IF;

    IF rma_receipt_lines%isopen THEN
       CLOSE rma_receipt_lines;
    END IF;

    IF count_rma_receipt_lines%isopen THEN
       CLOSE count_rma_receipt_lines;
    END IF;

    IF asn_receipt_lines%isopen THEN
       CLOSE asn_receipt_lines;
    END IF;

    IF count_asn_receipt_lines%isopen THEN
       CLOSE count_asn_receipt_lines;
    END IF;

    IF asn_direct_lines%isopen THEN
       CLOSE asn_direct_lines;
    END IF;

    IF count_asn_direct_lines%isopen THEN
       CLOSE count_asn_direct_lines;
    END IF;

-- For Bug 7440217 for LCM changes
    IF lcm_receipt_lines%isopen THEN
       CLOSE lcm_receipt_lines;
    END IF;

    IF count_lcm_receipt_lines%isopen THEN
       CLOSE count_lcm_receipt_lines;
    END IF;

    IF lcm_direct_lines%isopen THEN
       CLOSE lcm_direct_lines;
    END IF;

    IF count_lcm_direct_lines%isopen THEN
       CLOSE count_lcm_direct_lines;
    END IF;

    IF lcm_delivery_lines%isopen THEN
       CLOSE lcm_delivery_lines;
    END IF;

    IF count_lcm_delivery_lines%isopen THEN
       CLOSE count_lcm_delivery_lines;
    END IF;

-- End for Bug 7440217

    IF int_req_delivery_lines%isopen THEN
       CLOSE int_req_delivery_lines;
    END IF;

    IF count_int_req_delivery_lines%isopen THEN
       CLOSE count_int_req_delivery_lines;
    END IF;

    IF rma_delivery_lines%isopen THEN
       CLOSE rma_delivery_lines;
    END IF;

    IF count_rma_delivery_lines%isopen THEN
       CLOSE count_rma_delivery_lines;
    END IF;

    IF asn_delivery_lines%isopen THEN
       CLOSE asn_delivery_lines;
    END IF;

    IF count_asn_delivery_lines%isopen THEN
       CLOSE count_asn_delivery_lines;
    END IF;

    EXIT;

	  END IF;

	  -- Here should be checking for the date tolerances but, I donot
	  -- think that date tolerance is to be checked for the intransit
	  -- shipments.

	  -- Here should also be checking for the ship_to_location
	  -- enforcement. But I think for intransit shipment it is not
	  -- enforced.

	  -- Changes to accept Vendor_Item_num without ITEM_ID/NUM
	  -- Item_id could be null if the ASN has the vendor_item_num provided
	  -- We need to put a value into item_id based on the cursor
	  -- We need to also figure out the primary unit for the item_id
	  -- We will do it for the first record only. Subsequent records in the
	  -- temp_table are copies of the previous one

	  -- Assuming that vendor_item_num refers to a single item. If the items
	  -- could be different then we need to move this somewhere below

	  IF (x_first_trans) AND temp_cascaded_table(current_n).item_id IS NULL THEN
	     IF (l_debug = 1) THEN
   	     print_debug('First txn and item id is null',4);
	     END IF;
	     temp_cascaded_table(current_n).item_id := x_MatchedRec.item_id;
	     IF x_cascaded_table(n).primary_unit_of_measure IS NULL THEN
		IF x_cascaded_table(n).item_id IS NOT NULL THEN
                   BEGIN
		      SELECT primary_unit_of_measure
			INTO temp_cascaded_table(current_n).primary_unit_of_measure
			FROM mtl_system_items
		       WHERE mtl_system_items.inventory_item_id =
			        temp_cascaded_table(current_n).item_id
			 AND mtl_system_items.organization_id =
			        temp_cascaded_table(current_n).to_organization_id;
		   EXCEPTION
		      WHEN no_data_found THEN
			 temp_cascaded_table(current_n).error_status  := 'W';
			 temp_cascaded_table(current_n).error_message :=
			   'Need an error message';
		   END;
		 ELSE
		   temp_cascaded_table(current_n).primary_unit_of_measure
		     := x_MatchedRec.unit_of_measure;
		END IF;
	     END IF;
	  END IF;

	  insert_into_table := FALSE;
	  already_allocated_qty := 0;

	  -- Get the available quantity for the shipment line
	  -- that is available for allocation by this transaction
	  --
	  -- Direct delivery quantity for intransit shipments should be the
	  -- same as the receiving quantity.
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

	  IF (x_cascaded_table(n).transaction_type = 'RECEIVE')
	    OR (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
	     IF p_match_type = 'INTRANSIT SHIPMENT' THEN
		l_parent_id := x_MatchedRec.shipment_line_id;
		l_receipt_source_code := x_MatchedRec.receipt_source_code;
-- For Bug 7440217 for LCM changes
	      ELSIF p_match_type IN ('ASN', 'LCM') THEN
-- End for Bug 7440217
		-- for ASN, we have to hardcode this value
		-- to get the available qty from shipment lines
		l_receipt_source_code := 'INVENTORY';
		l_parent_id := x_MatchedRec.shipment_line_id;
	      ELSIF p_match_type = 'RMA' THEN
		l_receipt_source_code := x_MatchedRec.receipt_source_code;
		l_parent_id := x_MatchedRec.oe_order_line_id;
		--bug3592116 for RMA the uom code is got from oe_order_lines_all but we need to get
		--unit_of_measure to convert the rma line quantity to user input qty.
		SELECT unit_of_measure INTO l_rma_uom
		FROM mtl_units_of_measure
		WHERE uom_code = x_MatchedRec.unit_of_measure;
		x_MatchedRec.unit_of_measure := l_rma_uom;
		-- bug3592116

	     END IF;

	     IF (l_debug = 1) THEN
   	     print_debug('Receive/deliver l_parent_id:'||l_parent_id,4);
   	     print_debug('l_receipt_source_code:'||l_receipt_source_code,4);
	     END IF;
	     rcv_quantities_s.get_available_quantity
	       ('RECEIVE',
		l_parent_id,
		l_receipt_source_code,
		NULL,
		NULL,
		NULL,
		x_converted_trx_qty,
		x_tolerable_qty,
		x_MatchedRec.unit_of_measure);

	   -- Bug 4004656-Added the following two assignment statements
	      l_trx_qty_po_uom := x_converted_trx_qty;
	      l_tol_qty_po_uom := x_tolerable_qty;
	   -- End of fix for Bug 4004656

	     IF (l_debug = 1) THEN
   	   --print_debug('x_converted_trx_qty:'||x_converted_trx_qty,4);  --Bug 4004656
   	     print_debug('l_trx_qty_po_uom:'||l_trx_qty_po_uom,4);        --Bug 4004656
	   --print_debug('x_tolerable_qty:'||x_tolerable_qty,4);	  --Bug 4004656
	     print_debug('l_tol_qty_po_uom:'||l_tol_qty_po_uom,4);        --Bug 4004656
   	     print_debug('unit_of_measure:'||x_MatchedRec.unit_of_measure,4);
	     END IF;

	     -- this is done because for the deliver transaction there is
	     -- no concept of tolerance. Tolerances are only applicable at
	     -- the time of receipt, so does not really matter.
	  -- x_tolerable_qty := x_converted_trx_qty;  --Bug 4004656
	     l_tol_qty_po_uom := l_trx_qty_po_uom ;   --Bug 4004656

	     -- If qtys have already been allocated for this shipment line
	     -- during a cascade process which has not been written to the db yet,
	     -- we need to decrement it from the total available quantity
	     -- We traverse the actual pl/sql table and accumulate the quantity by
	     -- matching the shipment line id
	     IF (l_debug = 1) THEN
   	     print_debug('n:'||n,4);
	     END IF;
	     IF n > 1 THEN    -- We will do this for all rows except the 1st
		FOR i IN 1..(n-1) LOOP
		   IF p_match_type = 'INTRANSIT SHIPMENT'
-- For Bug 7440217 for LCM changes
		     OR p_match_type IN ('ASN', 'LCM') THEN
-- End for Bug 7440217
		      IF x_cascaded_table(i).shipment_line_id =
			x_MatchedRec.shipment_line_id THEN
			 IF (l_debug = 1) THEN
   			 print_debug('Already allocated some qty for this shipment_line',4);
			 END IF;
			 already_allocated_qty := already_allocated_qty +
			   x_cascaded_table(i).source_doc_quantity;
		      END IF;
		    ELSIF p_match_type = 'RMA' THEN
		      IF x_cascaded_table(i).oe_order_line_id =
			x_MatchedRec.oe_order_line_id THEN
			 IF (l_debug = 1) THEN
   			 print_debug('Already allocated some qty for this rma',4);
			 END IF;
			 already_allocated_qty := already_allocated_qty +
			   x_cascaded_table(i).source_doc_quantity;
		      END IF;
		   END IF;
		END LOOP;
	     END IF;

	   ELSIF (x_cascaded_table(n).transaction_type = 'STD_DELIVER') THEN

	     IF (l_debug = 1) THEN
   	     print_debug('standard delivery rcv_transaction_id:'||x_MatchedRec.rcv_transaction_id,4);
   	     print_debug('receipt_source_code:'||x_MatchedRec.receipt_source_code,4);
	     END IF;

-- For Bug 7440217 for LCM changes
	     IF p_match_type IN ('ASN', 'LCM') THEN
-- End for Bug 7440217
                print_debug('standard delivery',4);
                print_debug('po_distribution_id:'||x_MatchedRec.po_distribution_id,4);
                print_debug('rcv_transaction_id:'||x_MatchedRec.rcv_transaction_id,4);
                rcv_quantities_s.get_available_quantity(
                                                       'STANDARD DELIVER',
                                                       x_MatchedRec.po_distribution_id,
                                                       'VENDOR',
                                                       null,
                                                       x_MatchedRec.rcv_transaction_id,
                                                       null,
                                                       x_converted_trx_qty,
                                                       x_tolerable_qty,
                                                       x_MatchedRec.unit_of_measure);

           -- Bug 4004656-Added the following two assignment statements
	      l_trx_qty_po_uom := x_converted_trx_qty;
	      l_tol_qty_po_uom := x_tolerable_qty;
	   -- End of fix for Bug 4004656

             ELSE
	       rcv_quantities_s.get_available_quantity
	        ('DELIVER',
		x_MatchedRec.rcv_transaction_id,
		x_MatchedRec.receipt_source_code,
		NULL,
		NULL,--x_MatchedRec.rcv_transaction_id,
		NULL,
		x_converted_trx_qty,
		x_tolerable_qty,
		x_MatchedRec.unit_of_measure);

	  -- Bug 4004656-Added the following two assignment statements
              l_trx_qty_po_uom := x_converted_trx_qty;
	      l_tol_qty_po_uom := x_tolerable_qty;
	   -- End of fix for Bug 4004656


	     END IF;
	     IF (l_debug = 1) THEN
   	--   print_debug('x_converted_trx_qty:'||x_converted_trx_qty,4);  --Bug 4004656
             print_debug('l_trx_qty_po_uom:'||l_trx_qty_po_uom,4);        --Bug 4004656
   	--   print_debug('x_tolerable_qty:'||x_tolerable_qty,4);          --Bug 4004656
	     print_debug('l_tol_qty_po_uom:'||l_tol_qty_po_uom,4);        --Bug 4004656
	     print_debug('unit_of_measure:'||x_MatchedRec.unit_of_measure,4);
	     END IF;

	     -- this is done because for the deliver transaction there is
	     -- no concept of tolerance. Tolerances are only applicable at
	     -- the time of receipt, so it does not matter what we assign it.
	--   x_tolerable_qty := x_converted_trx_qty; --Bug 4004656
	     l_tol_qty_po_uom :=  l_trx_qty_po_uom ; --Bug 4004656

	     -- If qtys have already been allocated for this po_distribution_id
	     -- during
	     -- a cascade process which has not been written to the db yet, we need to
	     -- decrement it from the total available quantity
	     -- We traverse the actual pl/sql table and accumulate the quantity by
	     -- matching the
	     -- po_distribution_id
	     IF n > 1 THEN    -- We will do this for all rows except the 1st
		FOR i IN 1..(n-1) LOOP
		   IF p_match_type = 'INTRANSIT SHIPMENT'
-- For Bug 7440217 for LCM changes
		     OR p_match_type in ('ASN', 'LCM') THEN
-- End for Bug 7440217
		      IF x_cascaded_table(i).shipment_line_id =
			   x_MatchedRec.shipment_line_id AND
			x_cascaded_table(i).parent_transaction_id =
		           x_MatchedRec.rcv_transaction_id THEN
			 IF (l_debug = 1) THEN
   			 print_debug('Already allocated some qty for this shipment_line',4);
			 END IF;
			 already_allocated_qty := already_allocated_qty +
			   x_cascaded_table(i).source_doc_quantity;
		      END IF;
		    ELSIF p_match_type = 'RMA' THEN
		      IF x_cascaded_table(i).oe_order_line_id =
			   x_MatchedRec.oe_order_line_id AND
			x_cascaded_table(i).parent_transaction_id =
		           x_MatchedRec.rcv_transaction_id THEN
			 IF (l_debug = 1) THEN
   			 print_debug('Already allocated some qty for this rma',4);
			 END IF;
			 already_allocated_qty := already_allocated_qty +
			   x_cascaded_table(i).source_doc_quantity;
		      END IF;
		   END IF;
		END LOOP;
	     END IF;
	  END IF; -- type of transaction STD_DELIVER or RECEIVE or DELIVER
	  IF (l_debug = 1) THEN
   	  print_debug('Total already allocated qty:'||already_allocated_qty,4);
	  END IF;

	  -- if qty has already been allocated then reduce available and tolerable
	  -- qty by the allocated amount
          /* Bug 4004656-Modified the block with the new quantity fileds.
	  IF Nvl(already_allocated_qty,0) > 0 THEN
	     x_converted_trx_qty := x_converted_trx_qty - already_allocated_qty;
	     IF x_converted_trx_qty < 0 THEN
		x_converted_trx_qty := 0;
	     END IF;
	  END IF; */

           IF Nvl(already_allocated_qty,0) > 0 THEN
	   l_trx_qty_po_uom := l_trx_qty_po_uom - already_allocated_qty;
	   IF l_trx_qty_po_uom < 0 THEN
		l_trx_qty_po_uom := 0;
	     END IF;
	  END IF;
	  --End of fix for Bug 4004656

	--x_remaining_qty_po_uom := 0;  -- initialize --Bug 4004656
	  l_rcv_qty_trans_uom    := 0;		      --Bug 4004656
          l_rcv_qty_po_uom       := 0;		      --Bug 4004656
	  po_asn_uom_qty         := 0;  -- initialize
	  po_primary_uom_qty     := 0;  -- initialize

	    /* Bug 4004656 -Commented out the conversion that is being done
	            for the received quantity to the uom on the PO.
		    Retained it in the transaction uom through the variable l_rcv_qty_trans_uom
		    by assigning the value of the remaining quantity l_rem_qty_trans_uom
		    which is already in the transaciton uom */
	   /*  x_remaining_qty_po_uom :=
	    rcv_transactions_interface_sv.convert_into_correct_qty
	    (x_remaining_quantity,
	     temp_cascaded_table(1).unit_of_measure,
	     temp_cascaded_table(1).item_id,
	     x_MatchedRec.unit_of_measure);  */

	     l_rcv_qty_trans_uom := l_rem_qty_trans_uom ; --Bug 4004656

         /* Bug 4004656 - Printed debug messages for the quantities in the
	          new quantity variables
	  IF (l_debug = 1) THEN
   	  print_debug('x_remaining_qty_po_uom:'||x_remaining_qty_po_uom,4);
   	  print_debug('x_converted_trx_qty:'||x_converted_trx_qty,4);
	  END IF; */

	  IF (l_debug = 1) THEN
   	       print_debug('l_rcv_qty_trans_uom:'||l_rcv_qty_trans_uom,4);
   	       print_debug('l_trx_qty_po_uom:'||l_trx_qty_po_uom,4);
          END IF;

	 /* Bug 4004656 -Modified the condition with the new quantity field variable values
	  IF x_remaining_qty_po_uom <> 0 THEN -- otherwise no point in going further for this rec

	     IF x_converted_trx_qty > 0  THEN
		IF (x_converted_trx_qty < x_remaining_qty_po_uom) THEN
		   -- compare like uoms

		   x_remaining_qty_po_uom  := x_remaining_qty_po_uom -
		     x_converted_trx_qty;

		   -- change asn uom qty so both qtys are in sync
		   x_remaining_quantity :=
		     rcv_transactions_interface_sv.convert_into_correct_qty
		     (x_remaining_qty_po_uom,
		      x_MatchedRec.unit_of_measure,
		      temp_cascaded_table(1).item_id,
		      temp_cascaded_table(1).unit_of_measure);

		   insert_into_table := TRUE;
		 ELSE
		   x_converted_trx_qty  := x_remaining_qty_po_uom;
		   insert_into_table := TRUE;
		   x_remaining_qty_po_uom := 0;
		   x_remaining_quantity   := 0;
		END IF;
		IF (l_debug = 1) THEN
   		print_debug('x_remaining_qty_po_uom:'||x_remaining_qty_po_uom,4);
   		print_debug('x_converted_trx_qty:'||x_converted_trx_qty,4);
   		print_debug('x_remaining_quantity:'||x_remaining_quantity,4);
		END IF;

	      ELSE  -- no qty for this record but if last row we need it
		IF (l_debug = 1) THEN
   		print_debug('no qty for this record but if last row we need it',4);
		END IF;
		IF rows_fetched = x_record_count THEN
		   -- last row needs to be inserted anyway
		   -- so that the row can be used based on qty tolerance
		   -- checks
		   insert_into_table := TRUE;
		   x_converted_trx_qty := 0;
		 ELSE
		   x_remaining_qty_po_uom := 0;
		   -- we may have a diff uom on the next iteration
		   insert_into_table := FALSE;
		END IF;
	     END IF;
	     IF insert_into_table THEN
		IF (l_debug = 1) THEN
   		print_debug('insert_into_table:TRUE',4);
		END IF;
	      ELSE
		IF (l_debug = 1) THEN
   		print_debug('insert_into_table:FLASE',4);
		END IF;
	     END IF;

	  END IF;   -- remaining_qty_po_uom <> 0 */


       	  IF round(l_rcv_qty_trans_uom,5)  <> 0 THEN --Bug 4747997
	  if l_trx_qty_po_uom > 0  then
	         --Added the following code
	         l_trx_qty_trans_uom:=
	         rcv_transactions_interface_sv.convert_into_correct_qty
	         					            (l_trx_qty_po_uom,
	      							     x_MatchedRec.unit_of_measure,
	      							     temp_cascaded_table(1).item_id,
								     temp_cascaded_table(1).unit_of_measure);

		  IF (l_debug = 1) THEN
   		  print_debug('l_trx_qty_trans_uom:'||l_trx_qty_trans_uom,4);
                  END IF;

	       IF (round(l_trx_qty_trans_uom,5) < round(l_rcv_qty_trans_uom,5)) THEN --Bug: 4747997
		    -- compare like uoms which is the transaction uom
	      l_rcv_qty_trans_uom   := l_rcv_qty_trans_uom - l_trx_qty_trans_uom;
	      l_rcv_qty_po_uom:=  rcv_transactions_interface_sv.convert_into_correct_qty(l_rcv_qty_trans_uom,
		      									temp_cascaded_table(1).unit_of_measure,
		      									temp_cascaded_table(1).item_id,
									 		x_MatchedRec.unit_of_measure);


	       -- change asn uom qty so both qtys are in sync
               l_rem_qty_trans_uom := l_rcv_qty_trans_uom ;
	       insert_into_table := TRUE;
	       ELSE
	       l_trx_qty_trans_uom  :=  l_rcv_qty_trans_uom;
	       insert_into_table    := TRUE;
	       l_rcv_qty_trans_uom  := 0;
	       l_rcv_qty_po_uom     := 0;
	       l_rem_qty_trans_uom  := 0;
	       END IF;

	     IF (l_debug = 1) THEN
   		    print_debug('l_rcv_qty_trans_uom:'||l_rcv_qty_trans_uom,4);
   		    print_debug('l_rcv_qty_po_uom:'||l_rcv_qty_po_uom,4);
   		    print_debug('l_trx_qty_trans_uom:'||l_trx_qty_trans_uom,4);
   		    print_debug('l_rem_qty_trans_uom:'||l_rem_qty_trans_uom,4);
	     END IF;

	    ELSE  -- no qty for this record but if last row we need it
		 IF (l_debug = 1) THEN
   		    print_debug('no qty for this record but if last row we need it',4);
		 END IF;
		 IF rows_fetched = x_record_count THEN
		    -- last row needs to be inserted anyway
		    -- so that the row can be used based on qty tolerance
		    -- checks

		    insert_into_table := TRUE;
		    l_trx_qty_trans_uom := 0;
		  ELSE
		    l_rcv_qty_trans_uom := 0;
		    l_rcv_qty_po_uom := 0;
		    -- we may have a diff uom on the next iteration
		    insert_into_table := FALSE;
		 END IF;

	   END IF;
		    IF insert_into_table THEN
		       IF (l_debug = 1) THEN
   		       print_debug('insert_into_table:TRUE',4);
		       END IF;
		     ELSE
		       IF (l_debug = 1) THEN
   		       print_debug('insert_into_table:FLASE',4);
		       END IF;
		    END IF;
         END IF;   -- remaining_qty_po_uom <> 0 *

	  IF insert_into_table THEN
	     IF (x_first_trans) THEN
		x_first_trans := FALSE;
	      ELSE
		temp_cascaded_table(current_n) := temp_cascaded_table(current_n - 1);
	     END IF;

	     temp_cascaded_table(current_n).source_doc_quantity :=
	     --  x_converted_trx_qty;   -- in po uom --Bug 4004656
	     rcv_transactions_interface_sv.convert_into_correct_qty(
                                 l_trx_qty_trans_uom ,
                                 temp_cascaded_table(current_n).unit_of_measure,
                                 temp_cascaded_table(current_n).item_id,
                                 x_MatchedRec.unit_of_measure);
		-- End of fix for bug4004656

	     temp_cascaded_table(current_n).source_doc_unit_of_measure :=
	       x_MatchedRec.unit_of_measure;

	     IF (l_debug = 1) THEN
   	     print_debug('source_doc_quantity:'||temp_cascaded_table(current_n).source_doc_quantity,4);
   	     print_debug('source_doc_unit_of_measure:'||temp_cascaded_table(current_n).source_doc_unit_of_measure,4);
	     END IF;

	     temp_cascaded_table(current_n).quantity :=
	       /* Bug 4004656
	       rcv_transactions_interface_sv.convert_into_correct_qty
	       (x_converted_trx_qty,
		x_MatchedRec.unit_of_measure,
		temp_cascaded_table(current_n).item_id,
		temp_cascaded_table(current_n).unit_of_measure);  -- in asn uom */
	       l_trx_qty_trans_uom ; --Bug 4004656

	     IF (l_debug = 1) THEN
   	     print_debug('quantity:'||temp_cascaded_table(current_n).quantity,4);
	     END IF;

	     -- Primary qty in Primary UOM
	     temp_cascaded_table(current_n).primary_quantity :=
	     /* Bug 4004656
	       rcv_transactions_interface_sv.convert_into_correct_qty
	       (x_converted_trx_qty,
		x_MatchedRec.unit_of_measure,
		temp_cascaded_table(current_n).item_id,
		temp_cascaded_table(current_n).primary_unit_of_measure); */

	     rcv_transactions_interface_sv.convert_into_correct_qty(
                               l_trx_qty_trans_uom,
                               temp_cascaded_table(current_n).unit_of_measure,
                               temp_cascaded_table(current_n).item_id,
                               temp_cascaded_table(current_n).primary_unit_of_measure);
             --End of fix for Bug 4004656

	     IF (l_debug = 1) THEN
   	     print_debug('primary_quantity:'||temp_cascaded_table(current_n).primary_quantity,4);
	     END IF;

	     temp_cascaded_table(current_n).tax_amount :=
	       Round(temp_cascaded_table(current_n).quantity * tax_amount_factor,4);
	     IF (l_debug = 1) THEN
   	     print_debug('tax_amount:'||temp_cascaded_table(current_n).tax_amount,4);
	     END IF;
	     IF temp_cascaded_table(current_n).to_organization_id IS NULL THEN
		temp_cascaded_table(current_n).to_organization_id :=
		  x_MatchedRec.to_organization_id;
	     END IF;
	     IF (l_debug = 1) THEN
   	     print_debug('to_organization_id:'||temp_cascaded_table(current_n).to_organization_id,4);
	     END IF;

	     temp_cascaded_table(current_n).shipment_line_id := x_MatchedRec.shipment_line_id;
	     temp_cascaded_table(current_n).oe_order_line_id := x_MatchedRec.oe_order_line_id;
	     temp_cascaded_table(current_n).parent_transaction_id := x_MatchedRec.rcv_transaction_id;
	     IF (l_debug = 1) THEN
   	     print_debug('shipment_line_id:'||temp_cascaded_table(current_n).shipment_line_id,4);
   	     print_debug('oe_order_line_id:'||temp_cascaded_table(current_n).oe_order_line_id,4);
   	     print_debug('parent_transaction_id:'||temp_cascaded_table(current_n).parent_transaction_id,4);
	     END IF;

-- For Bug 7440217 for LCM changes
	     IF p_match_type in ('ASN', 'LCM') THEN
-- End for Bug 7440217
		temp_cascaded_table(current_n).po_header_id := x_MatchedRec.po_header_id;
		temp_cascaded_table(current_n).po_line_id := x_MatchedRec.po_line_id;
		temp_cascaded_table(current_n).po_line_location_id := x_MatchedRec.po_line_location_id;
		temp_cascaded_table(current_n).po_distribution_id := x_MatchedRec.po_distribution_id;
		temp_cascaded_table(current_n).item_desc := x_MatchedRec.item_description;
		IF (l_debug = 1) THEN
   		print_debug('po_header_id:'||temp_cascaded_table(current_n).po_header_id,4);
   		print_debug('po_line_id:'||temp_cascaded_table(current_n).po_line_id,4);
   		print_debug('po_line_location_id:'||temp_cascaded_table(current_n).po_line_location_id,4);
   		print_debug('po_distribution_id:'||temp_cascaded_table(current_n).po_distribution_id,4);
   		print_debug('item_desc:'||temp_cascaded_table(current_n).item_desc,4);
		END IF;
	     END IF;

	     current_n := current_n + 1;

	  END IF;
       END LOOP;

       -- point to the last row in the record structure before going back

     ELSE -- for the very first if
	     -- error_status and error_message are set after validate_quantity_shipped
	     IF x_cascaded_table(n).error_status IN ('S','W','F') THEN
		x_cascaded_table(n).error_status	:= 'E';
		IF (x_cascaded_table(n).error_message IS NULL) THEN
-- For Bug 7440217 for LCM changes
           IF p_match_type = 'ASN' THEN
		      x_cascaded_table(n).error_message	:= 'RCV_ASN_NO_PO_LINE_LOCATION_ID';
           ELSIF p_match_type = 'LCM' THEN
              x_cascaded_table(n).error_message	:= 'RCV_LCM_NO_PO_LINE_LOCATION_ID';
		   END IF;
-- End for Bug 7440217
		END IF;
	     END IF;
	     RETURN;
    END IF;       -- of (asn quantity_shipped was valid)

    -- close cursors
    IF int_req_receipt_lines%isopen THEN
       CLOSE int_req_receipt_lines;
    END IF;

    IF count_int_req_receipt_lines%isopen THEN
       CLOSE count_int_req_receipt_lines;
    END IF;

    IF rma_receipt_lines%isopen THEN
       CLOSE rma_receipt_lines;
    END IF;

    IF count_rma_receipt_lines%isopen THEN
       CLOSE count_rma_receipt_lines;
    END IF;

    IF asn_receipt_lines%isopen THEN
       CLOSE asn_receipt_lines;
    END IF;

    IF count_asn_receipt_lines%isopen THEN
       CLOSE count_asn_receipt_lines;
    END IF;

    IF asn_direct_lines%isopen THEN
       CLOSE asn_direct_lines;
    END IF;

    IF count_asn_direct_lines%isopen THEN
       CLOSE count_asn_direct_lines;
    END IF;

-- For Bug 7440217 for LCM changes
    IF lcm_receipt_lines%isopen THEN
       CLOSE lcm_receipt_lines;
    END IF;

    IF count_lcm_receipt_lines%isopen THEN
       CLOSE count_lcm_receipt_lines;
    END IF;

    IF lcm_direct_lines%isopen THEN
       CLOSE lcm_direct_lines;
    END IF;

    IF count_lcm_direct_lines%isopen THEN
       CLOSE count_lcm_direct_lines;
    END IF;

-- End for Bug 7440217


    IF int_req_delivery_lines%isopen THEN
       CLOSE int_req_delivery_lines;
    END IF;

    IF count_int_req_delivery_lines%isopen THEN
       CLOSE count_int_req_delivery_lines;
    END IF;

    IF rma_delivery_lines%isopen THEN
       CLOSE rma_delivery_lines;
    END IF;



 EXCEPTION
    WHEN fnd_api.g_exc_error THEN
       ROLLBACK TO rcv_transactions_gen_sa;
       x_return_status := fnd_api.g_ret_sts_error;

       --  Get message count and data
       fnd_msg_pub.count_and_get
	 (  p_count => x_msg_count
	    , p_data  => x_msg_data
	    );
       -- close cursors
       IF int_req_receipt_lines%isopen THEN
	  CLOSE int_req_receipt_lines;
       END IF;

       IF count_int_req_receipt_lines%isopen THEN
	  CLOSE count_int_req_receipt_lines;
       END IF;

       IF rma_receipt_lines%isopen THEN
	  CLOSE rma_receipt_lines;
       END IF;

       IF count_rma_receipt_lines%isopen THEN
	  CLOSE count_rma_receipt_lines;
       END IF;

       IF asn_receipt_lines%isopen THEN
	  CLOSE asn_receipt_lines;
       END IF;

       IF count_asn_receipt_lines%isopen THEN
	  CLOSE count_asn_receipt_lines;
       END IF;

       IF asn_direct_lines%isopen THEN
	  CLOSE asn_direct_lines;
       END IF;

       IF count_asn_direct_lines%isopen THEN
	  CLOSE count_asn_direct_lines;
       END IF;

-- For Bug 7440217 for LCM changes
       IF lcm_receipt_lines%isopen THEN
	  CLOSE lcm_receipt_lines;
       END IF;

       IF count_lcm_receipt_lines%isopen THEN
	  CLOSE count_lcm_receipt_lines;
       END IF;

       IF lcm_direct_lines%isopen THEN
	  CLOSE lcm_direct_lines;
       END IF;

       IF count_lcm_direct_lines%isopen THEN
	  CLOSE count_lcm_direct_lines;
       END IF;
-- End for Bug 7440217

       IF int_req_delivery_lines%isopen THEN
	  CLOSE int_req_delivery_lines;
       END IF;

       IF count_int_req_delivery_lines%isopen THEN
	  CLOSE count_int_req_delivery_lines;
       END IF;

       IF rma_delivery_lines%isopen THEN
	  CLOSE rma_delivery_lines;
       END IF;

       IF count_rma_delivery_lines%isopen THEN
          CLOSE count_asn_direct_lines;
       END IF;

       IF asn_delivery_lines%isopen THEN
          CLOSE int_req_delivery_lines;
       END IF;

       IF count_asn_delivery_lines%isopen THEN
          CLOSE count_int_req_delivery_lines;
       END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
       ROLLBACK TO rcv_transactions_gen_sa;
       x_return_status := fnd_api.g_ret_sts_unexp_error ;

       --  Get message count and data
       fnd_msg_pub.count_and_get
	 (  p_count  => x_msg_count
	    , p_data   => x_msg_data
	    );
       -- close cursors
       IF int_req_receipt_lines%isopen THEN
	  CLOSE int_req_receipt_lines;
       END IF;

       IF count_int_req_receipt_lines%isopen THEN
	  CLOSE count_int_req_receipt_lines;
       END IF;

       IF rma_receipt_lines%isopen THEN
	  CLOSE rma_receipt_lines;
       END IF;

       IF count_rma_receipt_lines%isopen THEN
	  CLOSE count_rma_receipt_lines;
       END IF;

       IF asn_receipt_lines%isopen THEN
	  CLOSE asn_receipt_lines;
       END IF;

       IF count_asn_receipt_lines%isopen THEN
	  CLOSE count_asn_receipt_lines;
       END IF;

       IF asn_direct_lines%isopen THEN
	  CLOSE asn_direct_lines;
       END IF;

       IF count_asn_direct_lines%isopen THEN
	  CLOSE count_asn_direct_lines;
       END IF;

-- For Bug 7440217 for LCM changes
       IF lcm_receipt_lines%isopen THEN
	  CLOSE lcm_receipt_lines;
       END IF;

       IF count_lcm_receipt_lines%isopen THEN
	  CLOSE count_lcm_receipt_lines;
       END IF;

       IF lcm_direct_lines%isopen THEN
	  CLOSE lcm_direct_lines;
       END IF;

       IF count_lcm_direct_lines%isopen THEN
	  CLOSE count_lcm_direct_lines;
       END IF;
-- End for Bug 7440217

       IF int_req_delivery_lines%isopen THEN
	  CLOSE int_req_delivery_lines;
       END IF;

       IF count_int_req_delivery_lines%isopen THEN
	  CLOSE count_int_req_delivery_lines;
       END IF;

       IF rma_delivery_lines%isopen THEN
	  CLOSE rma_delivery_lines;
       END IF;

    WHEN OTHERS THEN
       ROLLBACK TO rcv_transactions_gen_sa;
       x_return_status := fnd_api.g_ret_sts_unexp_error ;

       IF SQLCODE IS NOT NULL THEN
	  inv_mobile_helper_functions.sql_error('inv_rcv_txn_match.matching_logic', l_progress, SQLCODE);
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

       -- close cursors
       IF int_req_receipt_lines%isopen THEN
	  CLOSE int_req_receipt_lines;
       END IF;

       IF count_int_req_receipt_lines%isopen THEN
	  CLOSE count_int_req_receipt_lines;
       END IF;

       IF rma_receipt_lines%isopen THEN
	  CLOSE rma_receipt_lines;
       END IF;

       IF count_rma_receipt_lines%isopen THEN
	  CLOSE count_rma_receipt_lines;
       END IF;

       IF asn_receipt_lines%isopen THEN
	  CLOSE asn_receipt_lines;
       END IF;

       IF count_asn_receipt_lines%isopen THEN
	  CLOSE count_asn_receipt_lines;
       END IF;

       IF asn_direct_lines%isopen THEN
	  CLOSE asn_direct_lines;
       END IF;

       IF count_asn_direct_lines%isopen THEN
	  CLOSE count_asn_direct_lines;
       END IF;

-- For Bug 7440217 for LCM changes
       IF lcm_receipt_lines%isopen THEN
	  CLOSE lcm_receipt_lines;
       END IF;

       IF count_lcm_receipt_lines%isopen THEN
	  CLOSE count_lcm_receipt_lines;
       END IF;

       IF lcm_direct_lines%isopen THEN
	  CLOSE lcm_direct_lines;
       END IF;

       IF count_lcm_direct_lines%isopen THEN
	  CLOSE count_lcm_direct_lines;
       END IF;
-- End for Bug 7440217

       IF int_req_delivery_lines%isopen THEN
	  CLOSE int_req_delivery_lines;
       END IF;

       IF count_int_req_delivery_lines%isopen THEN
	  CLOSE count_int_req_delivery_lines;
       END IF;

       IF rma_delivery_lines%isopen THEN
	  CLOSE rma_delivery_lines;
       END IF;

       x_cascaded_table(n).error_status	:= 'E';

 END matching_logic;

END INV_rcv_txn_match;

/
