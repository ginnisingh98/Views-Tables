--------------------------------------------------------
--  DDL for Package RCV_ROI_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ROI_TRANSACTION" 
/* $Header: RCVPRETS.pls 120.3.12010000.9 2012/11/21 08:47:18 xiameng ship $*/
AUTHID CURRENT_USER AS

      CURSOR asn_shipments(
         v_shipment_header_id    NUMBER,
         v_shipment_line_id      NUMBER,
	 v_po_header_id          NUMBER,
         v_item_id               NUMBER,
         v_po_line_num           NUMBER,
         v_po_shipment_num      NUMBER,
         v_po_release_id         NUMBER,
         v_ship_to_org_id        NUMBER,
         v_ship_to_location_id   NUMBER,
         v_vendor_product_num    VARCHAR2,
	 v_include_closed_po     varchar2
      )
      IS
         SELECT rsl.po_line_location_id,
			pll.unit_meas_lookup_code,
                  	pll.unit_of_measure_class,
                  	NVL(pll.promised_date, pll.need_by_date) promised_date,
                  	rsl.to_organization_id ship_to_organization_id,
                  	pll.quantity quantity_ordered,
                  	0, --quantity_shipped,
                  	pll.receipt_days_exception_code,
                  	pll.qty_rcv_tolerance,
                  	pll.qty_rcv_exception_code,
                  	pll.days_early_receipt_allowed,
                  	pll.days_late_receipt_allowed,
                  	NVL(pll.price_override, pl.unit_price) unit_price,
                  	pll.match_option, -- 1845702
                    rsl.category_id,
                    rsl.item_description,
                  	pl.po_line_id,
                  	ph.currency_code,
                  	ph.rate_type, -- 1845702
                  	0 po_distribution_id,
                  	0 code_combination_id,
                  	0 req_distribution_id,
                  	0, --0 deliver_to_location_id,
                  	0, -- 0 deliver_to_person_id,
                  	ph.rate_date rate_date, --1845702
                  	ph.rate rate, --1845702
                        rsl.destination_type_code, --'' destination_type_code,
                  	rsl.to_organization_id destination_organization_id, -- 0 destination_organization_id,
                  	rsl.to_subinventory, -- '' destination_subinventory,
                  	0 wip_entity_id,
                  	0 wip_operation_seq_num,
                  	0 wip_resource_seq_num,
                  	0 wip_repetitive_schedule_id,
                  	0 wip_line_id,
                  	0 bom_resource_id,
                    0 project_id, /*  Bug 14725305 */
                    0 task_id,    /*  Bug 14725305 */
                  	'' ussgl_transaction_code,
                  	rsl.ship_to_location_id, --pll.ship_to_location_id,
                  	NVL(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code,
			rsl.shipment_line_id,
                  	rsl.item_id -- pl.item_id
			FROM
             		po_line_locations pll,
             		po_lines pl,
             		po_headers ph,
             		RCV_SHIPMENT_LINES RSL,
             		RCV_SHIPMENT_HEADERS RSH
			WHERE
            		rsh.shipment_header_id = v_shipment_header_id
			and rsl.shipment_header_id =  rsh.shipment_header_id
			and rsl.shipment_line_id = nvl(v_shipment_line_id,rsl.shipment_line_id)
			and rsl.po_header_id =  ph.po_header_id
			and ph.po_header_id = nvl(v_po_header_id,ph.po_header_id)
			and ((v_po_header_id is not null
			      and pl.line_num=NVL(v_po_line_num, pl.line_num)
			      and pll.shipment_num =
				   nvl(v_po_shipment_num,pll.shipment_num))
					 OR
			     v_po_header_id is null)
			and rsl.po_line_id =  pl.po_line_id
			and rsl.po_line_location_id =  pll.line_location_id
			and nvl(rsl.po_release_id,0) =  nvl(v_po_release_id,nvl(rsl.po_release_id,0))
			and nvl(rsl.item_id,0) = nvl(v_item_id,nvl(rsl.item_id,0))
			and rsl.to_organization_id = nvl(v_ship_to_org_id,rsl.to_organization_id)
			and nvl(rsl.shipment_line_status_code,'EXPECTED') <> 'FULLY RECEIVED'
			and nvl(rsl.asn_line_flag,'N') = 'Y'
			and rsh.receipt_source_code = 'VENDOR'
			AND rsl.ship_to_location_id = NVL(v_ship_to_location_id, rsl.ship_to_location_id)
            		and pll.po_line_id = pl.po_line_id
            		--and nvl(pl.item_id,0) =  nvl(rsl.item_id,0)
            		and NVL(pll.po_release_id, 0) = NVL(rsl.po_release_id, NVL(pll.po_release_id, 0))
            		AND NVL(pll.approved_flag, 'N') = 'Y'
              		AND NVL(pll.cancel_flag, 'N') = 'N'
              		AND ( ( (NVL(v_include_closed_po, 'N') = 'Y')
				 AND (NVL(pll.closed_code, 'OPEN')
					<> 'FINALLY CLOSED'))
					OR
			       ( (NVL(v_include_closed_po, 'N') = 'N')
                       		AND
                       		( NVL(pll.closed_code, 'OPEN') NOT IN
                                   ( 'FINALLY CLOSED', 'CLOSED',
				      'CLOSED FOR RECEIVING')))
                  	     )
              		AND pll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED')
              		AND pll.ship_to_organization_id =NVL(rsl.to_organization_id, pll.ship_to_organization_id)
              		--AND pll.ship_to_location_id =NVL(rsl.ship_to_location_id, pll.ship_to_location_id) - Bug 7677745
              		AND NVL(pl.vendor_product_num, '-999') =NVL(v_vendor_product_num,NVL(pl.vendor_product_num, '-999'))
			ORDER BY NVL(pll.promised_date, pll.need_by_date);

      CURSOR count_asn_shipments(
         v_shipment_header_id    NUMBER,
         v_shipment_line_id      NUMBER,
         v_po_header_id          NUMBER,
         v_item_id               NUMBER,
         v_po_line_num           NUMBER,
         v_po_shipment_num      NUMBER,
         v_po_release_id         NUMBER,
         v_ship_to_org_id        NUMBER,
         v_ship_to_location_id   NUMBER,
         v_vendor_product_num    VARCHAR2,
	 v_include_closed_po     varchar2
      )
      IS
         SELECT COUNT(*)
           FROM po_line_locations pll,
             		po_lines pl,
             		po_headers ph,
             		RCV_SHIPMENT_LINES RSL,
             		RCV_SHIPMENT_HEADERS RSH
			WHERE
            		rsh.shipment_header_id = v_shipment_header_id
			and rsl.shipment_header_id =  rsh.shipment_header_id
			and rsl.shipment_line_id = nvl(v_shipment_line_id,rsl.shipment_line_id)
			and rsl.po_header_id =  ph.po_header_id
			and ph.po_header_id = nvl(v_po_header_id,ph.po_header_id)
			and ((v_po_header_id is not null
			      and pl.line_num=NVL(v_po_line_num, pl.line_num)
			      and pll.shipment_num =
				   nvl(v_po_shipment_num,pll.shipment_num))
					 OR
			     v_po_header_id is null)
			and rsl.po_line_id =  pl.po_line_id
			and rsl.po_line_location_id =  pll.line_location_id
			and nvl(rsl.po_release_id,0) =  nvl(v_po_release_id,nvl(rsl.po_release_id,0))
			and nvl(rsl.item_id,0) = nvl(v_item_id,nvl(rsl.item_id,0))
			and rsl.to_organization_id = nvl(v_ship_to_org_id,rsl.to_organization_id)
			and (nvl(rsl.shipment_line_status_code,'EXPECTED') <> 'FULLY RECEIVED')
			and rsh.receipt_source_code = 'VENDOR'
			and nvl(rsl.asn_line_flag,'N') = 'Y'
			AND rsl.ship_to_location_id = NVL(v_ship_to_location_id, rsl.ship_to_location_id)
            		and pll.po_line_id = pl.po_line_id
            		--and nvl(pl.item_id,0) =  nvl(rsl.item_id,0)
            		and NVL(pll.po_release_id, 0) = NVL(rsl.po_release_id, NVL(pll.po_release_id, 0))
            		AND NVL(pll.approved_flag, 'N') = 'Y'
              		AND NVL(pll.cancel_flag, 'N') = 'N'
              		AND ( ( (NVL(v_include_closed_po, 'N') = 'Y')
				 AND (NVL(pll.closed_code, 'OPEN')
					<> 'FINALLY CLOSED'))
					OR
				( (NVL(v_include_closed_po, 'N') = 'N')
                       		AND ( NVL(pll.closed_code, 'OPEN') NOT IN
                                       ( 'FINALLY CLOSED', 'CLOSED',
                                          'CLOSED FOR RECEIVING')))
                            )
              		AND pll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED')
              		AND pll.ship_to_organization_id =NVL(rsl.to_organization_id, pll.ship_to_organization_id)
              		--AND pll.ship_to_location_id =NVL(rsl.ship_to_location_id, pll.ship_to_location_id) -Bug 7677745
              		AND NVL(pl.vendor_product_num, '-999') =NVL(v_vendor_product_num,NVL(pl.vendor_product_num, '-999'));

      /* Bug 3648871.
       * When v_po_header_id was null, we did not join po_distributions
       * table with other tables. Hence there was performance problem.
       * Changed the condition join po_distributions with po_line_locations
       * and po_lines in cursors asn_distributions and count_asn_distributions.
      */
      CURSOR asn_distributions(
         v_shipment_header_id    NUMBER,
         v_shipment_line_id      NUMBER,
         v_po_header_id          NUMBER,
         v_item_id               NUMBER,
         v_po_line_num           NUMBER,
         v_po_shipment_num       NUMBER,
	 v_po_distribution_num   NUMBER,
         v_po_release_id         NUMBER,
         v_ship_to_org_id        NUMBER,
         v_ship_to_location_id   NUMBER,
         v_vendor_product_num    VARCHAR2,
	 v_include_closed_po     varchar2
      )
      IS
         SELECT rsl.po_line_location_id,
		  pll.unit_meas_lookup_code,
                  pll.unit_of_measure_class,
                  NVL(pll.promised_date, pll.need_by_date) promised_date,
                  rsl.to_organization_id ship_to_organization_id,
                  pll.quantity quantity_ordered,
                  0, --quantity_shipped,
                  pll.receipt_days_exception_code,
                  pll.qty_rcv_tolerance,
                  pll.qty_rcv_exception_code,
                  pll.days_early_receipt_allowed,
                  pll.days_late_receipt_allowed,
                  NVL(pll.price_override, pl.unit_price) unit_price,
                  pll.match_option, -- 1845702
                  rsl.category_id,
                  rsl.item_description,
                  pl.po_line_id,
                  ph.currency_code,
                  ph.rate_type, -- 1845702
                  pod.po_distribution_id,
                  pod.code_combination_id,
                  pod.req_distribution_id,
                  pod.deliver_to_location_id,
                  pod.deliver_to_person_id,
                  pod.rate_date, pod.rate,
                  pod.destination_type_code,
                  pod.destination_organization_id,
                  pod.destination_subinventory,
                  pod.wip_entity_id,
                  pod.wip_operation_seq_num,
                  pod.wip_resource_seq_num,
                  pod.wip_repetitive_schedule_id,
                  pod.wip_line_id,
                  pod.bom_resource_id,
                  pod.project_id, /* Bug 14725305 */
                  pod.task_id,    /* Bug 14725305 */
                  pod.ussgl_transaction_code,
                  pll.ship_to_location_id,
                  NVL(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code,
		  rsl.shipment_line_id,
                  rsl.item_id
             FROM
             		po_distributions pod,
             		po_line_locations pll,
             		po_lines pl,
             		po_headers ph,
             		RCV_SHIPMENT_LINES RSL,
             		RCV_SHIPMENT_HEADERS RSH
			WHERE
            		rsh.shipment_header_id = v_shipment_header_id
			and rsl.shipment_header_id =  rsh.shipment_header_id
			and rsl.shipment_line_id = nvl(v_shipment_line_id,rsl.shipment_line_id)
			and rsl.po_header_id =  ph.po_header_id
			and ph.po_header_id = nvl(v_po_header_id,ph.po_header_id)
			and ((v_po_header_id is not null
			      and pl.line_num=NVL(v_po_line_num, pl.line_num)
			      and pll.shipment_num =
				   nvl(v_po_shipment_num,pll.shipment_num)
			      and pod.distribution_num =
				   nvl(v_po_distribution_num,pod.distribution_num))
					 OR
			     v_po_header_id is null)
		        and pod.po_header_id = ph.po_header_id
                        and pod.line_location_id = pll.line_location_id
			and rsl.po_line_id =  pl.po_line_id
			and rsl.po_line_location_id =  pll.line_location_id
			and nvl(rsl.po_release_id,0) =  nvl(v_po_release_id,nvl(rsl.po_release_id,0))
			and nvl(rsl.item_id,0) = nvl(v_item_id,nvl(rsl.item_id,0))
			and rsl.to_organization_id = nvl(v_ship_to_org_id,rsl.to_organization_id)
			and (nvl(rsl.shipment_line_status_code,'EXPECTED') <> 'FULLY RECEIVED')
			and rsh.receipt_source_code = 'VENDOR'
			and nvl(rsl.asn_line_flag,'N') = 'Y'
			AND rsl.ship_to_location_id = NVL(v_ship_to_location_id, rsl.ship_to_location_id)
            		and pll.po_line_id = pl.po_line_id
            		--and nvl(pl.item_id,0) = nvl(rsl.item_id,0)
            		and NVL(pll.po_release_id, 0) = NVL(rsl.po_release_id, NVL(pll.po_release_id, 0))
            		AND NVL(pll.approved_flag, 'N') = 'Y'
              		AND NVL(pll.cancel_flag, 'N') = 'N'
              		AND ( ( (NVL(v_include_closed_po, 'N') = 'Y')
                       		AND (NVL(pll.closed_code, 'OPEN')
					<> 'FINALLY CLOSED'))
                   		OR
				( (NVL(v_include_closed_po, 'N') = 'N')
                       		AND ( NVL(pll.closed_code, 'OPEN') NOT IN
                                      ( 'FINALLY CLOSED', 'CLOSED',
                                         'CLOSED FOR RECEIVING')))
                            )
              		AND pll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED')
              		AND pll.ship_to_organization_id =NVL(rsl.to_organization_id, pll.ship_to_organization_id)
              		--AND pll.ship_to_location_id =NVL(rsl.ship_to_location_id, pll.ship_to_location_id) - Bug 7677745
              		AND NVL(pl.vendor_product_num, '-999') =NVL(v_vendor_product_num,NVL(pl.vendor_product_num, '-999'));

      CURSOR count_asn_distributions(
         v_shipment_header_id    NUMBER,
         v_shipment_line_id      NUMBER,
         v_po_header_id          NUMBER,
         v_item_id               NUMBER,
         v_po_line_num           NUMBER,
         v_po_shipment_num       NUMBER,
	 v_po_distribution_num   NUMBER,
         v_po_release_id         NUMBER,
         v_ship_to_org_id        NUMBER,
         v_ship_to_location_id   NUMBER,
         v_vendor_product_num    VARCHAR2,
	 v_include_closed_po     varchar2
      )
      IS
         SELECT COUNT(*)
           FROM
             		po_distributions pod,
             		po_line_locations pll,
             		po_lines pl,
             		po_headers ph,
             		RCV_SHIPMENT_LINES RSL,
             		RCV_SHIPMENT_HEADERS RSH
			WHERE
            		rsh.shipment_header_id = v_shipment_header_id
			and rsl.shipment_header_id =  rsh.shipment_header_id
			and rsl.shipment_line_id = nvl(v_shipment_line_id,rsl.shipment_line_id)
			and rsl.po_header_id =  ph.po_header_id
			and ph.po_header_id = nvl(v_po_header_id,ph.po_header_id)
			and ((v_po_header_id is not null
			      and pl.line_num=NVL(v_po_line_num, pl.line_num)
			      and pll.shipment_num =
				   nvl(v_po_shipment_num,pll.shipment_num)
			      and pod.distribution_num =
				   nvl(v_po_distribution_num,pod.distribution_num))
					 OR
			     v_po_header_id is null)
		        and pod.po_header_id = ph.po_header_id
                        and pod.line_location_id = pll.line_location_id
			and rsl.po_line_id =  pl.po_line_id
			and rsl.po_line_location_id =  pll.line_location_id
			and nvl(rsl.po_release_id,0) =  nvl(v_po_release_id,nvl(rsl.po_release_id,0))
			and nvl(rsl.item_id,0) = nvl(v_item_id,nvl(rsl.item_id,0))
			and rsl.to_organization_id = nvl(v_ship_to_org_id,rsl.to_organization_id)
			and (nvl(rsl.shipment_line_status_code,'EXPECTED') <> 'FULLY RECEIVED')
			and rsh.receipt_source_code = 'VENDOR'
			and nvl(rsl.asn_line_flag,'N') = 'Y'
			AND rsl.ship_to_location_id = NVL(v_ship_to_location_id, rsl.ship_to_location_id)
            		and pll.po_line_id = pl.po_line_id
            		--and nvl(pl.item_id,0) = nvl(rsl.item_id,0)
            		and NVL(pll.po_release_id, 0) = NVL(rsl.po_release_id, NVL(pll.po_release_id, 0))
            		AND NVL(pll.approved_flag, 'N') = 'Y'
              		AND NVL(pll.cancel_flag, 'N') = 'N'
              		AND ( ( (NVL(v_include_closed_po, 'N') = 'Y')
                       		AND (NVL(pll.closed_code, 'OPEN')
						<> 'FINALLY CLOSED'))
					OR
				( (NVL(v_include_closed_po, 'N') = 'N')
                       		AND ( NVL(pll.closed_code, 'OPEN') NOT IN
                               		( 'FINALLY CLOSED', 'CLOSED',
                                           'CLOSED FOR RECEIVING')))
                             )
              		AND pll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED')
              		AND pll.ship_to_organization_id =NVL(rsl.to_organization_id, pll.ship_to_organization_id)
              		--AND pll.ship_to_location_id =NVL(rsl.ship_to_location_id, pll.ship_to_location_id) -Bug 7677745
              		AND NVL(pl.vendor_product_num, '-999') =NVL(v_vendor_product_num,NVL(pl.vendor_product_num, '-999'));

PROCEDURE derive_vendor_rcv_line (
           X_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer,
           temp_cascaded_table  IN OUT  NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           X_header_record      IN rcv_roi_preprocessor.header_rec_type);


PROCEDURE default_vendor_rcv_line (
           X_cascaded_table	    IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
		   n				    IN binary_integer,
 		   X_header_id			IN	    rcv_headers_interface.header_interface_id%type,
           X_header_record      IN      rcv_roi_preprocessor.header_rec_type);


PROCEDURE validate_vendor_rcv_line (
           X_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
  		   n				    IN	binary_integer,
  		   X_asn_type			IN	    rcv_headers_interface.asn_type%type,
           X_header_record      IN      rcv_roi_preprocessor.header_rec_type);


PROCEDURE derive_ship_to_org_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer,
           X_header_record      IN      rcv_roi_preprocessor.header_rec_type);

PROCEDURE derive_vendor_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_vendor_site_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_po_header_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_asn_header_info (
   x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
   n				    IN OUT  NOCOPY binary_integer,
x_header_record    IN              rcv_roi_preprocessor.header_rec_type);
PROCEDURE derive_item_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_substitute_item_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_po_line_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_from_org_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_transit_org_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_location_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_ship_to_location_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_routing_header_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_routing_step_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_deliver_to_person_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_deliver_to_loc_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_from_locator_id (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_to_locator_id (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE validate_non_services_fields(
           x_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
           n                  IN        BINARY_INTEGER );

PROCEDURE default_from_subloc_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN    binary_integer);

PROCEDURE default_to_subloc_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN    binary_integer);

PROCEDURE derive_reason_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_auto_transact_code (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer);

PROCEDURE derive_vendor_rcv_line_qty (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer,
           temp_cascaded_table  IN OUT  NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           X_header_record      IN rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_transaction_date (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_quantity_invoiced (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_transaction_uom (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN  binary_integer);

PROCEDURE validate_item_info (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN  binary_integer);

PROCEDURE validate_freight_carrier_code (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_dest_type (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_ship_to_loc (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_deliver_to_person (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_routing_record(
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_deliver_to_loc (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_subinventory (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_locator (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_tax_code (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer,
	   /* Bug3454491 (1) */
           x_asn_type         		    IN rcv_headers_interface.asn_type%TYPE);

PROCEDURE validate_country_of_origin (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_asl (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_consigned_inventory (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer,
	   /* Bug3454491 (2) */
           x_asn_type         		    IN rcv_headers_interface.asn_type%TYPE);

PROCEDURE validate_shipped_qty (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_ref_integrity (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer,
	   X_header_record      IN rcv_roi_preprocessor.header_rec_type);

PROCEDURE exchange_sub_items (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_ref_integ (
           x_ref_integrity_rec  IN OUT NOCOPY rcv_shipment_line_sv.ref_integrity_record_type,
           X_header_record      IN rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_inspection_status (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

PROCEDURE validate_transaction_type (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN binary_integer);

/** OPM change Bug# 3061052**/
-- added validate_opm_attributes to validate OPM specific columns.
PROCEDURE validate_opm_attributes(
      	   x_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      	   n                  IN              BINARY_INTEGER ) ;

PROCEDURE validate_temp_labor_info(
      v_trans_tab       IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                 IN              binary_integer,
      v_header_record   IN              rcv_roi_preprocessor.header_rec_type);

PROCEDURE validate_amount(
      v_trans_tab       IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                 IN              binary_integer,
      v_header_record   IN              rcv_roi_preprocessor.header_rec_type );

PROCEDURE HANDLE_RCV_ASN_TRANSACTIONS (V_TRANS_TAB     IN OUT  NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
                                       V_HEADER_RECORD IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type);


PROCEDURE derive_vendor_trans_del (
           X_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer,
           temp_cascaded_table  IN OUT  NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           X_header_record      IN rcv_roi_preprocessor.header_rec_type);

Procedure derive_parent_id(
           X_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer );

PROCEDURE derive_trans_del_line_quantity (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer,
           temp_cascaded_table  IN OUT  NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type);

PROCEDURE default_vendor_trans_del (
        X_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
                   n               IN binary_integer);

PROCEDURE derive_correction_line (
           X_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer,
           temp_cascaded_table  IN OUT  NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           X_header_record      IN rcv_roi_preprocessor.header_rec_type);


PROCEDURE derive_correction_line_qty (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer,
           temp_cascaded_table  IN OUT  NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type);


PROCEDURE derive_correction_line_amt (
           x_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    IN OUT  NOCOPY binary_integer,
           temp_cascaded_table  IN OUT  NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type);

PROCEDURE default_vendor_correct (
        X_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
                   n               IN binary_integer);


FUNCTION convert_into_correct_qty(source_qty in number,
                                   source_uom in varchar2,
                                   item_id    in number,
                                   dest_uom   in varchar2)
          RETURN NUMBER;


PROCEDURE get_interface_available_qty (
        X_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
                   n               IN binary_integer,
	x_interface_qty      OUT NOCOPY number);


PROCEDURE get_interface_available_amt(
        x_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
        n                  IN              BINARY_INTEGER,
        x_interface_amt       OUT NOCOPY   number);

PROCEDURE update_interface_available_qty (
        X_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
        n                IN binary_integer);

PROCEDURE update_interface_available_amt (
        X_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
        n                IN binary_integer);

PROCEDURE update_total_transaction_qty(
        p_interface_transaction_id  IN   rcv_transactions_interface.interface_transaction_id%type,
        p_parent_transaction_id     IN   rcv_transactions_interface.parent_transaction_id%type,
        p_parent_interface_txn_id   IN   rcv_transactions_interface.parent_interface_txn_id%type,
        p_primary_quantity          IN   rcv_transactions_interface.quantity%type,
        p_transaction_type          IN   rcv_transactions_interface.transaction_type%type,
        x_interface_transaction_qty OUT NOCOPY
                       rcv_transactions_interface.interface_transaction_qty%type
);

PROCEDURE update_total_transaction_amt(
        p_interface_transaction_id  IN   rcv_transactions_interface.interface_transaction_id%type,
        p_parent_transaction_id     IN   rcv_transactions_interface.parent_transaction_id%type,
        p_parent_interface_txn_id   IN   rcv_transactions_interface.parent_interface_txn_id%type,
        p_amount                    IN   rcv_transactions_interface.amount%type,
        p_transaction_type          IN   rcv_transactions_interface.transaction_type%type,
        x_interface_transaction_amt OUT NOCOPY
                       rcv_transactions_interface.interface_transaction_amt%type
);


PROCEDURE derive_vendor_rcv_line_amt(
      x_cascaded_table      IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                     IN OUT NOCOPY   BINARY_INTEGER,
      temp_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record       IN              rcv_roi_preprocessor.header_rec_type   );

   PROCEDURE validate_amt_based_rcv_line(
      x_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN              BINARY_INTEGER,
      x_asn_type         IN              rcv_headers_interface.asn_type%TYPE,
      x_header_record    IN              rcv_roi_preprocessor.header_rec_type
   );


/* Complex work.
 * We have a separate procedure derive_matching_basis
 * to get the matching basis now. This is because we
 * are going to get the matching_basis from
 * po_line_locations and hence moved it from
 * derive_po_line_info.
*/
PROCEDURE derive_matching_basis(
        x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
        n                IN            BINARY_INTEGER
    );

/* The following procedure and functions are added as part of Bug#6375015 fix.
    Procedure get_deliver_to_person_from_po()
    Function  get_deliver_to_person_from_rt()
    Function  get_deliver_to_person_from_rti() */

PROCEDURE get_deliver_to_person_from_po(
    x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
    n                   IN BINARY_INTEGER
);

FUNCTION get_deliver_to_person_from_rt(
    x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
    n                   IN BINARY_INTEGER
) RETURN NUMBER;

FUNCTION get_deliver_to_person_from_rti(
    x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
    n                   IN BINARY_INTEGER
) RETURN NUMBER;

PROCEDURE validate_lcm_line (
           X_cascaded_table		IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n                            IN binary_integer,
           X_asn_type                   IN rcv_headers_interface.asn_type%type,
           X_header_record              IN rcv_roi_preprocessor.header_rec_type);

--Bug 7651646
PROCEDURE validate_src_txn(
           x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n                IN            BINARY_INTEGER);

-- <Bug 9342280 : Added for CLM project>
PROCEDURE get_clm_info(  p_validate_type       VARCHAR2,
                         x_cascaded_table      IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
                         n                     IN BINARY_INTEGER,
                         x_is_clm_po           IN OUT NOCOPY VARCHAR2,
                         x_partial_funded_flag IN OUT NOCOPY VARCHAR2);

-- Bug 9705269
PROCEDURE validate_shipment_source(
           x_cascaded_table             IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n                                IN BINARY_INTEGER);

-- rtv project
PROCEDURE validate_parent_rtv
         ( x_cascaded_table             IN OUT  NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n                            IN binary_integer);

END RCV_ROI_TRANSACTION;


/
