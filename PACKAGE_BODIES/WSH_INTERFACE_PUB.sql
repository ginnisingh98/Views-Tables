--------------------------------------------------------
--  DDL for Package Body WSH_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_INTERFACE_PUB" as
/* $Header: WSHDDITB.pls 120.0 2005/05/26 18:06:48 appldev noship $ */

--  Procedure:      Create_Shipment_Lines
--
--  Parameters:     p_delivery_details_info  IN WSH_DELIVERY_DETAILS_PKG.Deliver
--				y_Details_Rec_Type

--  Description:    This procedure is a wraper for the create_delivery_Details.
--                  It is called by any system that is pushing shipment lines
--                  into shipping system.
--
--

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_INTERFACE_PUB';
--
PROCEDURE Create_Shipment_Lines(
  p_delivery_details_info IN OUT NOCOPY   wsh_delivery_details_pkg.Delivery_Details_Rec_Type,
  x_delivery_Detail_id out NOCOPY  number,
  x_return_status out NOCOPY  varchar2) is

      -- Harmonization Project
      l_detail_info_tab WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
      l_in_rec   	WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
      l_dummy_ids       wsh_util_core.id_Tab_type;
      l_out_Rec       WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;
      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2(32767);
      l_number_of_errors    NUMBER := 0;
      l_number_of_warnings  NUMBER := 0;
      l_return_status       VARCHAR2(32767);
      l_api_version         NUMBER := 1.0;
      l_init_msg_list       VARCHAR2(32767);
      l_commit              VARCHAR2(32767);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_SHIPMENT_LINES';
--
BEGIN
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
	wsh_debug_sv.push(l_module_name, 'Create_Shipment_Lines');
	wsh_debug_sv.log (l_module_name, 'Source Code', p_delivery_details_info.source_code);
	wsh_debug_sv.log (l_module_name, 'Source Header Id', p_delivery_details_info.source_header_id);
	wsh_debug_sv.log (l_module_name, 'Source Line Id', p_delivery_details_info.source_line_id);
	wsh_debug_sv.log (l_module_name,'src_requested_quantity', p_delivery_details_info.src_requested_quantity);
	wsh_debug_sv.log(l_module_name,'src_requested_quantity_uom', p_delivery_details_info.src_requested_quantity_uom);
	wsh_debug_sv.log (l_module_name,'Item ID', p_delivery_details_info.inventory_item_id);
	wsh_debug_sv.log (l_module_name, 'Ship From Location Id', p_delivery_details_info.ship_from_location_id);
	wsh_debug_sv.log (l_module_name, 'Ship To Location Id', p_delivery_details_info.ship_to_location_id);
	wsh_debug_sv.log (l_module_name, 'Organization Id', p_delivery_details_info.organization_id);
	wsh_debug_sv.log (l_module_name, 'Org Id', p_delivery_details_info.org_id);
	wsh_debug_sv.log (l_module_name, 'source_header_number', p_delivery_details_info.source_header_number);
	wsh_debug_sv.log (l_module_name, 'Source Line Number', p_delivery_details_info.source_line_number);
     END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     IF (p_delivery_details_info.source_code='OKE') THEN

        l_detail_info_tab(1).delivery_detail_id := p_delivery_details_info.delivery_detail_id;
        l_detail_info_tab(1).source_code := p_delivery_details_info.source_code;
        l_detail_info_tab(1).source_header_id := p_delivery_details_info.source_header_id;
        l_detail_info_tab(1).source_line_id := p_delivery_details_info.source_line_id;
        l_detail_info_tab(1).customer_id := p_delivery_details_info.customer_id;
        l_detail_info_tab(1).sold_to_contact_id := p_delivery_details_info.sold_to_contact_id;
        l_detail_info_tab(1).inventory_item_id := p_delivery_details_info.inventory_item_id;
        l_detail_info_tab(1).item_description := p_delivery_details_info.item_description;
        l_detail_info_tab(1).hazard_class_id := p_delivery_details_info.hazard_class_id;
        l_detail_info_tab(1).country_of_origin := p_delivery_details_info.country_of_origin;
        l_detail_info_tab(1).classification := p_delivery_details_info.classification;
        l_detail_info_tab(1).ship_from_location_id := p_delivery_details_info.ship_from_location_id;
        l_detail_info_tab(1).ship_to_location_id := p_delivery_details_info.ship_to_location_id;
        l_detail_info_tab(1).ship_to_contact_id := p_delivery_details_info.ship_to_contact_id;
        l_detail_info_tab(1).ship_to_site_use_id := p_delivery_details_info.ship_to_site_use_id;
        l_detail_info_tab(1).deliver_to_location_id := p_delivery_details_info.deliver_to_location_id;
        l_detail_info_tab(1).deliver_to_contact_id := p_delivery_details_info.deliver_to_contact_id;
        l_detail_info_tab(1).deliver_to_site_use_id := p_delivery_details_info.deliver_to_site_use_id;
        l_detail_info_tab(1).intmed_ship_to_location_id := p_delivery_details_info.intmed_ship_to_location_id;
        l_detail_info_tab(1).intmed_ship_to_contact_id := p_delivery_details_info.intmed_ship_to_contact_id;
        l_detail_info_tab(1).hold_code := p_delivery_details_info.hold_code;
        l_detail_info_tab(1).ship_tolerance_above := p_delivery_details_info.ship_tolerance_above;
        l_detail_info_tab(1).ship_tolerance_below := p_delivery_details_info.ship_tolerance_below;
        l_detail_info_tab(1).requested_quantity := p_delivery_details_info.requested_quantity;
        l_detail_info_tab(1).shipped_quantity := p_delivery_details_info.shipped_quantity;
        l_detail_info_tab(1).delivered_quantity := p_delivery_details_info.delivered_quantity;
        l_detail_info_tab(1).requested_quantity_uom := p_delivery_details_info.requested_quantity_uom;
        l_detail_info_tab(1).subinventory := p_delivery_details_info.subinventory;
        l_detail_info_tab(1).revision := p_delivery_details_info.revision;
        l_detail_info_tab(1).lot_number := p_delivery_details_info.lot_number;
        l_detail_info_tab(1).customer_requested_lot_flag := p_delivery_details_info.customer_requested_lot_flag;
        l_detail_info_tab(1).serial_number := p_delivery_details_info.serial_number;
        l_detail_info_tab(1).locator_id := p_delivery_details_info.locator_id;
        l_detail_info_tab(1).date_requested := p_delivery_details_info.date_requested;
        l_detail_info_tab(1).date_scheduled := p_delivery_details_info.date_scheduled;
        l_detail_info_tab(1).master_container_item_id := p_delivery_details_info.master_container_item_id;
        l_detail_info_tab(1).detail_container_item_id := p_delivery_details_info.detail_container_item_id;
        l_detail_info_tab(1).load_seq_number := p_delivery_details_info.load_seq_number;
        l_detail_info_tab(1).ship_method_code := p_delivery_details_info.ship_method_code;
        l_detail_info_tab(1).carrier_id := p_delivery_details_info.carrier_id;
        l_detail_info_tab(1).freight_terms_code := p_delivery_details_info.freight_terms_code;
        l_detail_info_tab(1).shipment_priority_code := p_delivery_details_info.shipment_priority_code;
        l_detail_info_tab(1).fob_code := p_delivery_details_info.fob_code;
        l_detail_info_tab(1).customer_item_id := p_delivery_details_info.customer_item_id;
        l_detail_info_tab(1).dep_plan_required_flag := p_delivery_details_info.dep_plan_required_flag;
        l_detail_info_tab(1).customer_prod_seq := p_delivery_details_info.customer_prod_seq;
        l_detail_info_tab(1).customer_dock_code := p_delivery_details_info.customer_dock_code;
        l_detail_info_tab(1).cust_model_serial_number := p_delivery_details_info.cust_model_serial_number;
        l_detail_info_tab(1).customer_job         := p_delivery_details_info.customer_job        ;
        l_detail_info_tab(1).customer_production_line := p_delivery_details_info.customer_production_line;
        l_detail_info_tab(1).net_weight := p_delivery_details_info.net_weight;
        l_detail_info_tab(1).weight_uom_code := p_delivery_details_info.weight_uom_code;
        l_detail_info_tab(1).volume := p_delivery_details_info.volume;
        l_detail_info_tab(1).volume_uom_code := p_delivery_details_info.volume_uom_code;
        l_detail_info_tab(1).tp_attribute_category := p_delivery_details_info.tp_attribute_category;
        l_detail_info_tab(1).tp_attribute1 := p_delivery_details_info.tp_attribute1;
        l_detail_info_tab(1).tp_attribute2 := p_delivery_details_info.tp_attribute2;
        l_detail_info_tab(1).tp_attribute3 := p_delivery_details_info.tp_attribute3;
        l_detail_info_tab(1).tp_attribute4 := p_delivery_details_info.tp_attribute4;
        l_detail_info_tab(1).tp_attribute5 := p_delivery_details_info.tp_attribute5;
        l_detail_info_tab(1).tp_attribute6 := p_delivery_details_info.tp_attribute6;
        l_detail_info_tab(1).tp_attribute7 := p_delivery_details_info.tp_attribute7;
        l_detail_info_tab(1).tp_attribute8 := p_delivery_details_info.tp_attribute8;
        l_detail_info_tab(1).tp_attribute9 := p_delivery_details_info.tp_attribute9;
        l_detail_info_tab(1).tp_attribute10 := p_delivery_details_info.tp_attribute10;
        l_detail_info_tab(1).tp_attribute11 := p_delivery_details_info.tp_attribute11;
        l_detail_info_tab(1).tp_attribute12 := p_delivery_details_info.tp_attribute12;
        l_detail_info_tab(1).tp_attribute13 := p_delivery_details_info.tp_attribute13;
        l_detail_info_tab(1).tp_attribute14 := p_delivery_details_info.tp_attribute14;
        l_detail_info_tab(1).tp_attribute15 := p_delivery_details_info.tp_attribute15;
        l_detail_info_tab(1).attribute_category := p_delivery_details_info.attribute_category;
        l_detail_info_tab(1).attribute1 := p_delivery_details_info.attribute1;
        l_detail_info_tab(1).attribute2 := p_delivery_details_info.attribute2;
        l_detail_info_tab(1).attribute3 := p_delivery_details_info.attribute3;
        l_detail_info_tab(1).attribute4 := p_delivery_details_info.attribute4;
        l_detail_info_tab(1).attribute5 := p_delivery_details_info.attribute5;
        l_detail_info_tab(1).attribute6 := p_delivery_details_info.attribute6;
        l_detail_info_tab(1).attribute7 := p_delivery_details_info.attribute7;
        l_detail_info_tab(1).attribute8 := p_delivery_details_info.attribute8;
        l_detail_info_tab(1).attribute9 := p_delivery_details_info.attribute9;
        l_detail_info_tab(1).attribute10 := p_delivery_details_info.attribute10;
        l_detail_info_tab(1).attribute11 := p_delivery_details_info.attribute11;
        l_detail_info_tab(1).attribute12 := p_delivery_details_info.attribute12;
        l_detail_info_tab(1).attribute13 := p_delivery_details_info.attribute13;
        l_detail_info_tab(1).attribute14 := p_delivery_details_info.attribute14;
        l_detail_info_tab(1).attribute15 := p_delivery_details_info.attribute15;
        l_detail_info_tab(1).created_by := p_delivery_details_info.created_by;
        l_detail_info_tab(1).creation_date := p_delivery_details_info.creation_date;
        l_detail_info_tab(1).last_update_date := p_delivery_details_info.last_update_date;
        l_detail_info_tab(1).last_update_login := p_delivery_details_info.last_update_login;
        l_detail_info_tab(1).last_updated_by := p_delivery_details_info.last_updated_by;
        l_detail_info_tab(1).program_application_id := p_delivery_details_info.program_application_id;
        l_detail_info_tab(1).program_id := p_delivery_details_info.program_id;
        l_detail_info_tab(1).program_update_date := p_delivery_details_info.program_update_date;
        l_detail_info_tab(1).request_id := p_delivery_details_info.request_id;
        l_detail_info_tab(1).mvt_stat_status := p_delivery_details_info.mvt_stat_status;
        l_detail_info_tab(1).released_flag := p_delivery_details_info.released_flag;
        l_detail_info_tab(1).organization_id := p_delivery_details_info.organization_id;
        l_detail_info_tab(1).transaction_temp_id := p_delivery_details_info.transaction_temp_id;
        l_detail_info_tab(1).ship_set_id := p_delivery_details_info.ship_set_id;
        l_detail_info_tab(1).arrival_set_id := p_delivery_details_info.arrival_set_id;
        l_detail_info_tab(1).ship_model_complete_flag := p_delivery_details_info.ship_model_complete_flag;
        l_detail_info_tab(1).top_model_line_id := p_delivery_details_info.top_model_line_id;
        l_detail_info_tab(1).source_header_number := p_delivery_details_info.source_header_number;
        l_detail_info_tab(1).source_header_type_id := p_delivery_details_info.source_header_type_id;
        l_detail_info_tab(1).source_header_type_name := p_delivery_details_info.source_header_type_name;
        l_detail_info_tab(1).cust_po_number := p_delivery_details_info.cust_po_number;
        l_detail_info_tab(1).ato_line_id := p_delivery_details_info.ato_line_id;
        l_detail_info_tab(1).src_requested_quantity := p_delivery_details_info.src_requested_quantity;
        l_detail_info_tab(1).src_requested_quantity_uom := p_delivery_details_info.src_requested_quantity_uom;
        l_detail_info_tab(1).move_order_line_id := p_delivery_details_info.move_order_line_id;
        l_detail_info_tab(1).cancelled_quantity := p_delivery_details_info.cancelled_quantity;
        l_detail_info_tab(1).quality_control_quantity := p_delivery_details_info.quality_control_quantity;
        l_detail_info_tab(1).cycle_count_quantity := p_delivery_details_info.cycle_count_quantity;
        l_detail_info_tab(1).tracking_number := p_delivery_details_info.tracking_number;
        l_detail_info_tab(1).movement_id := p_delivery_details_info.movement_id;
        l_detail_info_tab(1).shipping_instructions := p_delivery_details_info.shipping_instructions;
        l_detail_info_tab(1).packing_instructions := p_delivery_details_info.packing_instructions;
        l_detail_info_tab(1).project_id := p_delivery_details_info.project_id;
        l_detail_info_tab(1).task_id	 := p_delivery_details_info.task_id	;
        l_detail_info_tab(1).org_id	 := p_delivery_details_info.org_id	;
        l_detail_info_tab(1).oe_interfaced_flag := p_delivery_details_info.oe_interfaced_flag;
        l_detail_info_tab(1).split_from_detail_id := p_delivery_details_info.split_from_detail_id;
        l_detail_info_tab(1).inv_interfaced_flag := p_delivery_details_info.inv_interfaced_flag;
        l_detail_info_tab(1).source_line_number := p_delivery_details_info.source_line_number;
        l_detail_info_tab(1).inspection_flag := p_delivery_details_info.inspection_flag;
        l_detail_info_tab(1).released_status := p_delivery_details_info.released_status;
        l_detail_info_tab(1).container_flag := p_delivery_details_info.container_flag;
        l_detail_info_tab(1).container_type_code := p_delivery_details_info.container_type_code;
        l_detail_info_tab(1).container_name := p_delivery_details_info.container_name;
        l_detail_info_tab(1).fill_percent := p_delivery_details_info.fill_percent;
        l_detail_info_tab(1).gross_weight := p_delivery_details_info.gross_weight;
        l_detail_info_tab(1).master_serial_number := p_delivery_details_info.master_serial_number;
        l_detail_info_tab(1).maximum_load_weight := p_delivery_details_info.maximum_load_weight;
        l_detail_info_tab(1).maximum_volume := p_delivery_details_info.maximum_volume;
        l_detail_info_tab(1).minimum_fill_percent := p_delivery_details_info.minimum_fill_percent;
        l_detail_info_tab(1).seal_code := p_delivery_details_info.seal_code;
        l_detail_info_tab(1).unit_number := p_delivery_details_info.unit_number;
        l_detail_info_tab(1).unit_price := p_delivery_details_info.unit_price;
        l_detail_info_tab(1).currency_code := p_delivery_details_info.currency_code;
        l_detail_info_tab(1).freight_class_cat_id := p_delivery_details_info.freight_class_cat_id;
        l_detail_info_tab(1).commodity_code_cat_id := p_delivery_details_info.commodity_code_cat_id;
        l_detail_info_tab(1).preferred_grade  := p_delivery_details_info.preferred_grade ;
        l_detail_info_tab(1).src_requested_quantity2  := p_delivery_details_info.src_requested_quantity2 ;
        l_detail_info_tab(1).src_requested_quantity_uom2 := p_delivery_details_info.src_requested_quantity_uom2;
        l_detail_info_tab(1).requested_quantity2     := p_delivery_details_info.requested_quantity2    ;
        l_detail_info_tab(1).shipped_quantity2       := p_delivery_details_info.shipped_quantity2      ;
        l_detail_info_tab(1).delivered_quantity2     := p_delivery_details_info.delivered_quantity2    ;
        l_detail_info_tab(1).cancelled_quantity2     := p_delivery_details_info.cancelled_quantity2    ;
        l_detail_info_tab(1).quality_control_quantity2   := p_delivery_details_info.quality_control_quantity2  ;
        l_detail_info_tab(1).cycle_count_quantity2   := p_delivery_details_info.cycle_count_quantity2  ;
        l_detail_info_tab(1).requested_quantity_uom2 := p_delivery_details_info.requested_quantity_uom2;
        l_detail_info_tab(1).lpn_id   := p_delivery_details_info.lpn_id  ;
        l_detail_info_tab(1).pickable_flag := p_delivery_details_info.pickable_flag;
        l_detail_info_tab(1).original_subinventory := p_delivery_details_info.original_subinventory;
        l_detail_info_tab(1).to_serial_number     := p_delivery_details_info.to_serial_number    ;
        l_detail_info_tab(1).picked_quantity := p_delivery_details_info.picked_quantity;
        l_detail_info_tab(1).picked_quantity2 := p_delivery_details_info.picked_quantity2;
        l_detail_info_tab(1).received_quantity := p_delivery_details_info.received_quantity;
        l_detail_info_tab(1).received_quantity2 := p_delivery_details_info.received_quantity2;
        l_detail_info_tab(1).source_line_set_id := p_delivery_details_info.source_line_set_id;
        l_detail_info_tab(1).batch_id := p_delivery_details_info.batch_id;
        l_detail_info_tab(1).ROWID := p_delivery_details_info.ROWID;
        l_detail_info_tab(1).transaction_id := p_delivery_details_info.transaction_id;
        l_detail_info_tab(1).VENDOR_ID := p_delivery_details_info.VENDOR_ID;
        l_detail_info_tab(1).SHIP_FROM_SITE_ID := p_delivery_details_info.SHIP_FROM_SITE_ID;
        l_detail_info_tab(1).LINE_DIRECTION   := p_delivery_details_info.LINE_DIRECTION  ;
        l_detail_info_tab(1).PARTY_ID        := p_delivery_details_info.PARTY_ID       ;
        l_detail_info_tab(1).ROUTING_REQ_ID := p_delivery_details_info.ROUTING_REQ_ID;
        l_detail_info_tab(1).SHIPPING_CONTROL := p_delivery_details_info.SHIPPING_CONTROL;
        l_detail_info_tab(1).SOURCE_BLANKET_REFERENCE_ID := p_delivery_details_info.SOURCE_BLANKET_REFERENCE_ID;
        l_detail_info_tab(1).SOURCE_BLANKET_REFERENCE_NUM := p_delivery_details_info.SOURCE_BLANKET_REFERENCE_NUM;
        l_detail_info_tab(1).PO_SHIPMENT_LINE_ID         := p_delivery_details_info.PO_SHIPMENT_LINE_ID        ;
        l_detail_info_tab(1).PO_SHIPMENT_LINE_NUMBER    := p_delivery_details_info.PO_SHIPMENT_LINE_NUMBER   ;
        l_detail_info_tab(1).RETURNED_QUANTITY         := p_delivery_details_info.RETURNED_QUANTITY        ;
        l_detail_info_tab(1).RETURNED_QUANTITY2       := p_delivery_details_info.RETURNED_QUANTITY2      ;
        l_detail_info_tab(1).RCV_SHIPMENT_LINE_ID    := p_delivery_details_info.RCV_SHIPMENT_LINE_ID   ;
        l_detail_info_tab(1).SOURCE_LINE_TYPE_CODE  := p_delivery_details_info.SOURCE_LINE_TYPE_CODE ;
        l_detail_info_tab(1).SUPPLIER_ITEM_NUMBER  := p_delivery_details_info.SUPPLIER_ITEM_NUMBER ;
        l_detail_info_tab(1).IGNORE_FOR_PLANNING := p_delivery_details_info.IGNORE_FOR_PLANNING;
        l_detail_info_tab(1).EARLIEST_PICKUP_DATE   := p_delivery_details_info.EARLIEST_PICKUP_DATE  ;
        l_detail_info_tab(1).LATEST_PICKUP_DATE     := p_delivery_details_info.LATEST_PICKUP_DATE    ;
        l_detail_info_tab(1).EARLIEST_DROPOFF_DATE  := p_delivery_details_info.EARLIEST_DROPOFF_DATE ;
        l_detail_info_tab(1).LATEST_DROPOFF_DATE    := p_delivery_details_info.LATEST_DROPOFF_DATE   ;
        l_detail_info_tab(1).REQUEST_DATE_TYPE_CODE := p_delivery_details_info.REQUEST_DATE_TYPE_CODE;
        l_detail_info_tab(1).tp_delivery_detail_id := p_delivery_details_info.tp_delivery_detail_id;
        l_detail_info_tab(1).source_document_type_id := p_delivery_details_info.source_document_type_id;
        l_detail_info_tab(1).unit_weight := p_delivery_details_info.unit_weight;
        l_detail_info_tab(1).unit_volume := p_delivery_details_info.unit_volume;
        l_detail_info_tab(1).filled_volume := p_delivery_details_info.filled_volume;
        l_detail_info_tab(1).wv_frozen_flag := p_delivery_details_info.wv_frozen_flag;
        l_detail_info_tab(1).mode_of_transport := p_delivery_details_info.mode_of_transport;
        l_detail_info_tab(1).service_level      := p_delivery_details_info.service_level     ;
        l_detail_info_tab(1).po_revision_number := p_delivery_details_info.po_revision_number;
        l_detail_info_tab(1).release_revision_number  := p_delivery_details_info.release_revision_number ;
       -- Harmonization Project. Call Group API.
       l_in_rec.caller := 'WSH_PUB';
       l_in_rec.action_code := 'CREATE';


             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_GRP.CREATE_UPDATE_DELIVERY_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

       wsh_interface_grp.create_update_delivery_detail(
       p_api_version_number	 => l_api_version,
       p_init_msg_list           => l_init_msg_list,
       p_commit                  => l_commit,
       x_return_status           => l_return_status,
       x_msg_count               => l_msg_count,
       x_msg_data                => l_msg_data,
       p_detail_info_tab         => l_detail_info_tab,
       p_IN_rec                  => l_in_rec,
       x_OUT_rec                 => l_out_rec);

             --
             wsh_util_core.api_post_call(
                      p_return_status => l_return_status,
                      x_num_warnings  => l_number_of_warnings,
                      x_num_errors    => l_number_of_errors,
                      p_msg_data      => l_msg_data
                      );

        x_delivery_Detail_id := l_out_rec.detail_ids(l_out_rec.detail_ids.first);

      END IF;
        IF l_debug_on THEN
	 wsh_debug_sv.pop(l_module_name);
        END IF;

	EXCEPTION
              when fnd_api.g_exc_error then
                x_return_status := FND_API.G_RET_STS_ERROR ;

               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
               END IF;
--
		when others then
			x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                        wsh_util_core.default_handler('WSH_INTERFACE_PUB.Create_Shipment_Lines');
                        IF l_debug_on THEN
                         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                        END IF;

END Create_Shipment_Lines;


END WSH_INTERFACE_PUB;

/
