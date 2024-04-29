--------------------------------------------------------
--  DDL for Package Body WSH_INBOUND_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_INBOUND_UTIL_PKG" as
/* $Header: WSHIBUTB.pls 120.6 2005/09/13 17:20:27 rvishnuv noship $ */


G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_INBOUND_UTIL_PKG';

--========================================================================
-- PROCEDURE : Copy_Po_Rec_To_Line_Rec  This procedure is used to copy
--                                      all the attributes into x_line_rec
--                                      either from p_po_line_rec or from
--                                      the previous record in x_line_rec
--                                      based on the value of
--                                      p_prev_line_rec_index.
--
-- PARAMETERS:  p_po_line_rec           PO_FTE_INTEGRATION_GRP.po_release_rec_type
--		x_line_rec              OE_WSH_BULK_GRP.line_rec_type
--              p_po_line_location_id   po_line_location_id of
--                                      po_line_locations_all.
--              p_prev_line_rec_index   previous record's index of
--                                      x_line_rec.
--		x_return_status         Return status of the API.
--
-- COMMENT   : This procedure is used to copy all the attributes into
--             x_line_rec either from p_po_line_rec or from the previous
--             record in x_line_rec based on the value of p_prev_line_rec_index.
--             We first call the Extend_Tables procedure to extend
--             x_line_rec by one more index.
--             If the p_prev_line_rec_index is null, then we copy
--             the data in the x_line_rec from p_po_line_rec
--             else we copy the data into x_line_rec from the previous
--             index (p_prev_line_rec_index) of x_line_rec.
--========================================================================
  PROCEDURE copy_po_rec_to_line_rec(
              p_po_line_rec IN PO_FTE_INTEGRATION_GRP.po_release_rec_type,
              x_line_rec    IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
              p_po_line_location_id IN NUMBER,
              p_prev_line_rec_index IN NUMBER,
              x_return_status OUT NOCOPY VARCHAR2)
  IS
  --{
    l_tab_count NUMBER;
    l_return_status VARCHAR2(1);
    l_num_errors NUMBER := 0;
    l_num_warnings NUMBER := 0;
    l_additional_line_info_rec WSH_BULK_PROCESS_PVT.additional_line_info_rec_type;
    l_action_prms WSH_BULK_TYPES_GRP.action_parameters_rectype;
    --
    --
    cursor l_fr_term_fob_code_csr(p_source_header_id IN NUMBER,
                                  p_source_line_id   IN NUMBER,
                                  p_po_shipment_line_id IN NUMBER) is

    select fob_code,
           freight_terms_code
    from   wsh_delivery_details
    where  source_line_id = p_source_line_id
    and    source_header_id = p_source_header_id
    and    po_shipment_line_id = p_po_shipment_line_id
    and    source_code = 'PO'
    and    rownum =1;

    l_fob_point_code VARCHAR2(32767);
    l_fr_terms_code VARCHAR2(32767);

    --
    --
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'COPY_PO_REC_TO_LINE_REC';

  --
  --}
  BEGIN
  --{
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_PO_LINE_LOCATION_ID',P_PO_LINE_LOCATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_PREV_LINE_REC_INDEX',P_PREV_LINE_REC_INDEX);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;

    /*
    x_line_rec.header_id.extend;
    x_line_rec.po_shipment_line_id.extend;
    x_line_rec.source_blanket_reference_id.extend;
    x_line_rec.sold_to_org_id.extend;
    x_line_rec.sold_to_contact_id.extend;
    x_line_rec.ship_from_location_id.extend;
    x_line_rec.ship_to_contact_id.extend;
    x_line_rec.deliver_to_location_id.extend;
    x_line_rec.deliver_to_contact_id.extend;
    x_line_rec.deliver_to_org_id.extend;
    x_line_rec.intmed_ship_to_location_id.extend;
    x_line_rec.intermed_ship_to_contact_id.extend;
    x_line_rec.requested_quantity.extend;
    x_line_rec.requested_quantity_uom.extend;
    x_line_rec.subinventory.extend;
    x_line_rec.shipping_method_code.extend;
    x_line_rec.customer_item_id.extend;
    x_line_rec.shipment_priority_code.extend;
    x_line_rec.dep_plan_required_flag.extend;
    x_line_rec.cust_production_seq_num.extend;
    x_line_rec.customer_dock_code.extend;
    x_line_rec.cust_model_serial_number.extend;
    x_line_rec.customer_job.extend;
    x_line_rec.customer_production_line.extend;
    x_line_rec.net_weight.extend;
    x_line_rec.weight_uom_code.extend;
    x_line_rec.volume.extend;
    x_line_rec.volume_uom_code.extend;
    x_line_rec.mvt_stat_status.extend;
    x_line_rec.ship_set_id.extend;
    x_line_rec.arrival_set_id.extend;
    x_line_rec.ship_model_complete_flag.extend;
    x_line_rec.top_model_line_id.extend;
    x_line_rec.source_header_number.extend;
    x_line_rec.source_header_type_id.extend;
    x_line_rec.source_header_type_name.extend;
    x_line_rec.cust_po_number.extend;
    x_line_rec.ato_line_id.extend;
    x_line_rec.shipping_instructions.extend;
    x_line_rec.packing_instructions.extend;
    x_line_rec.project_id.extend;
    x_line_rec.task_id.extend;
    x_line_rec.gross_weight.extend;
    x_line_rec.seal_code.extend;
    x_line_rec.end_item_unit_number.extend;
    x_line_rec.freight_class_cat_id.extend;
    x_line_rec.commodity_code_cat_id.extend;
    x_line_rec.requested_quantity2.extend;
    x_line_rec.requested_quantity_uom2.extend;
    x_line_rec.pickable_flag.extend;
    x_line_rec.original_subinventory.extend;
    x_line_rec.line_set_id.extend;
    x_line_rec.source_document_type_id.extend;
    x_line_rec.source_blanket_reference_num.extend;
    x_line_rec.hold_code.extend;
    x_line_rec.vendor_id.extend;
    x_line_rec.ship_from_site_id.extend;
    x_line_rec.freight_terms_code.extend;
    x_line_rec.fob_point_code.extend;
    x_line_rec.shipping_control.extend;
    x_line_rec.currency_code.extend;
    x_line_rec.source_line_number.extend;
    x_line_rec.supplier_item_num.extend;
    x_line_rec.source_line_type_code.extend;
    x_line_rec.hazard_class_id.extend;
    x_line_rec.inventory_item_id.extend;
    x_line_rec.item_description.extend;
    x_line_rec.revision.extend;
    x_line_rec.po_shipment_line_number.extend;
    x_line_rec.country_of_origin.extend;
    x_line_rec.organization_id.extend;
    x_line_rec.ship_to_location_id.extend;
    x_line_rec.ordered_quantity.extend;
    x_line_rec.order_quantity_uom.extend;
    x_line_rec.unit_list_price.extend;
    --x_line_rec.status_code.extend;
    x_line_rec.preferred_grade.extend;
    x_line_rec.cancelled_quantity.extend;
    x_line_rec.ordered_quantity2.extend;
    x_line_rec.ordered_quantity_uom2.extend;
    x_line_rec.ship_tolerance_above.extend;
    x_line_rec.ship_tolerance_below.extend;
    x_line_rec.qty_rcv_exception_code.extend;
    x_line_rec.request_date.extend;
    x_line_rec.schedule_ship_date.extend;
    x_line_rec.days_early_receipt_allowed.extend;
    x_line_rec.days_late_receipt_allowed.extend;
    x_line_rec.receipt_days_exception_code.extend;
    x_line_rec.enforce_ship_to_location_code.extend;
    x_line_rec.shipping_details_updated_on.extend;
    x_line_rec.ship_to_org_id.extend;
    x_line_rec.carrier_id.extend;
    x_line_rec.tracking_number.extend;
    x_line_rec.received_quantity2.extend;
    -- These are additional columns needed to be extended to prevent
    -- failing of insert
    x_line_rec.inspection_flag.extend;
    x_line_rec.tp_attribute1.extend;
    x_line_rec.tp_attribute10.extend;
    x_line_rec.tp_attribute11.extend;
    x_line_rec.tp_attribute12.extend;
    x_line_rec.tp_attribute13.extend;
    x_line_rec.tp_attribute14.extend;
    x_line_rec.tp_attribute15.extend;
    x_line_rec.tp_attribute2.extend;
    x_line_rec.tp_attribute3.extend;
    x_line_rec.tp_attribute4.extend;
    x_line_rec.tp_attribute5.extend;
    x_line_rec.tp_attribute6.extend;
    x_line_rec.tp_attribute7.extend;
    x_line_rec.tp_attribute8.extend;
    x_line_rec.tp_attribute9.extend;
    x_line_rec.TP_CONTEXT.extend;
    x_line_rec.shipping_interfaced_flag.extend;
    x_line_rec.shipping_eligible_flag.extend;
    */
    x_line_rec.line_id.extend;
    --x_line_rec.drop_ship_flag.extend;
    x_line_rec.closed_flag.extend;
    x_line_rec.closed_code.extend;
    x_line_rec.cancelled_flag.extend;
    x_line_rec.source_code.extend;


    -- extending the tables for storing the data from rcv_shipment_lines
    x_line_rec.shipment_header_id.extend;
    x_line_rec.shipment_num.extend;
    x_line_rec.receipt_num.extend;
    x_line_rec.bill_of_lading.extend;
    x_line_rec.rcv_carrier_id.extend;
    x_line_rec.expected_receipt_date.extend;
    x_line_rec.shipped_date.extend;
    x_line_rec.rcv_freight_terms_code.extend;
    x_line_rec.num_of_containers.extend;
    x_line_rec.rcv_gross_weight.extend;
    x_line_rec.rcv_gross_weight_uom_code.extend;
    x_line_rec.rcv_net_weight.extend;
    x_line_rec.rcv_net_weight_uom_code.extend;
    x_line_rec.rcv_tare_weight.extend;
    x_line_rec.rcv_tare_weight_uom_code.extend;
    x_line_rec.shipment_line_id.extend;
    x_line_rec.rcv_inventory_item_id.extend;
    x_line_rec.rcv_revision.extend;
    x_line_rec.rcv_item_description.extend;
    x_line_rec.packing_slip_number.extend;
    x_line_rec.qty_rcv_exception_code.extend;
    --x_line_rec.days_early_receipt_allowed.extend;
    --x_line_rec.days_late_receipt_allowed.extend;
    x_line_rec.receipt_days_exception_code.extend;
    x_line_rec.enforce_ship_to_location_code.extend;
    x_line_rec.shipping_details_updated_on.extend;

    -- bug 3199983
    x_line_rec.container_num.extend;
    x_line_rec.truck_num.extend;
    x_line_rec.lpn_id.extend;
    x_line_rec.asn_type.extend;
    -- bug 3199983

    l_action_prms.caller := 'WSH_IB_UTIL';
    WSH_BULK_PROCESS_PVT.Extend_tables (
      p_line_rec                    => x_line_rec,
      p_action_prms                 => l_action_prms,
      x_table_count                 => l_tab_count,
      x_additional_line_info_rec    => l_additional_line_info_rec,
      x_return_status               => l_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Return Status after calling the API Extend_tables is ', l_return_status);
        WSH_DEBUG_SV.log(l_module_name,'l_tab_count', l_tab_count);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);

    IF nvl( l_tab_count,0) = 0 THEN
      l_tab_count := x_line_rec.po_shipment_line_id.count;
    END IF;


    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'count of x_line_rec',l_tab_count);
    END IF;

    IF ( p_prev_line_rec_index IS NULL ) THEN
    --{
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Before initializing the attributes');
        END IF;
      x_line_rec.org_id(l_tab_count) := p_po_line_rec.org_id;
      x_line_rec.header_id(l_tab_count) := p_po_line_rec.header_id;
      x_line_rec.line_id(l_tab_count) := p_po_line_rec.line_id;
      x_line_rec.po_shipment_line_id(l_tab_count) :=  p_po_line_location_id;
      x_line_rec.source_blanket_reference_id(l_tab_count) := p_po_line_rec.source_blanket_reference_id;
      x_line_rec.source_blanket_reference_num(l_tab_count) := p_po_line_rec.source_blanket_reference_num;
      x_line_rec.source_header_number(l_tab_count) := p_po_line_rec.source_header_number;
      x_line_rec.hold_code(l_tab_count) := p_po_line_rec.hold_code;
      x_line_rec.vendor_id(l_tab_count) := p_po_line_rec.vendor_id;
      x_line_rec.ship_from_site_id(l_tab_count) := p_po_line_rec.ship_from_site_id;
      IF ( x_line_rec.source_blanket_reference_id(l_tab_count) IS NOT NULL) THEN
      --{
        open l_fr_term_fob_code_csr(p_po_line_rec.header_id,
                               p_po_line_rec.line_id,
                               p_po_line_location_id);
        fetch l_fr_term_fob_code_csr into l_fob_point_code, l_fr_terms_code;
        close l_fr_term_fob_code_csr;
        x_line_rec.freight_terms_code(l_tab_count) := l_fr_terms_code;
        x_line_rec.fob_point_code(l_tab_count) := l_fob_point_code;
      --}
      ELSE
      --{
        x_line_rec.freight_terms_code(l_tab_count) := p_po_line_rec.freight_terms_code;
        x_line_rec.fob_point_code(l_tab_count) := p_po_line_rec.fob_point_code;
      --}
      END IF;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Middle 1');
        END IF;
      x_line_rec.shipping_control(l_tab_count)  := p_po_line_rec.shipping_control;
      x_line_rec.po_revision(l_tab_count) := p_po_line_rec.po_revision;
      x_line_rec.currency_code(l_tab_count)     := p_po_line_rec.currency_code;
      x_line_rec.release_revision(l_tab_count) := p_po_line_rec.release_revision;
      x_line_rec.source_line_number(l_tab_count) := p_po_line_rec.source_line_number;
      x_line_rec.supplier_item_num(l_tab_count) := p_po_line_rec.supplier_item_num;
      x_line_rec.source_line_type_code(l_tab_count) := p_po_line_rec.source_line_type_code;
      x_line_rec.hazard_class_id(l_tab_count) := p_po_line_rec.hazard_class_id;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Middle 2');
        END IF;
      x_line_rec.inventory_item_id(l_tab_count) := p_po_line_rec.inventory_item_id;
      x_line_rec.item_description(l_tab_count)  := p_po_line_rec.item_description;
      x_line_rec.revision(l_tab_count)  := p_po_line_rec.revision;
      x_line_rec.po_shipment_line_number(l_tab_count) := p_po_line_rec.po_shipment_line_number;
      x_line_rec.country_of_origin(l_tab_count) := p_po_line_rec.country_of_origin;
      x_line_rec.organization_id(l_tab_count) := p_po_line_rec.organization_id;
      x_line_rec.ship_to_org_id(l_tab_count)  := null;
      --x_line_rec.ship_to_org_id(l_tab_count)  := p_po_line_rec.organization_id;
      x_line_rec.ship_to_location_id(l_tab_count) := p_po_line_rec.ship_to_location_id;
      x_line_rec.ordered_quantity(l_tab_count)  := p_po_line_rec.ordered_quantity;
      x_line_rec.order_quantity_uom(l_tab_count)  := p_po_line_rec.order_quantity_uom;
      x_line_rec.unit_list_price(l_tab_count) := p_po_line_rec.unit_list_price;
      --x_line_rec.status_code(l_tab_count) := p_po_line_rec.status_code;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Middle 3');
        END IF;
      x_line_rec.preferred_grade(l_tab_count) := p_po_line_rec.preferred_grade;
      x_line_rec.cancelled_quantity(l_tab_count)  := p_po_line_rec.cancelled_quantity;
      x_line_rec.ordered_quantity2(l_tab_count) := p_po_line_rec.ordered_quantity2;
      x_line_rec.ordered_quantity_uom2(l_tab_count) := p_po_line_rec.ordered_quantity_uom2;
      x_line_rec.ship_tolerance_above(l_tab_count)  := p_po_line_rec.ship_tolerance_above;
      x_line_rec.ship_tolerance_below(l_tab_count)  := p_po_line_rec.ship_tolerance_below;
      x_line_rec.request_date(l_tab_count)  := p_po_line_rec.request_date;
      x_line_rec.schedule_ship_date(l_tab_count)  := p_po_line_rec.schedule_ship_date;
      x_line_rec.qty_rcv_exception_code(l_tab_count)  := p_po_line_rec.qty_rcv_exception_code;
      x_line_rec.days_early_receipt_allowed(l_tab_count)  := p_po_line_rec.days_early_receipt_allowed;
      x_line_rec.days_late_receipt_allowed(l_tab_count) := p_po_line_rec.days_late_receipt_allowed;
      x_line_rec.receipt_days_exception_code(l_tab_count) := p_po_line_rec.receipt_days_exception_code;
      x_line_rec.enforce_ship_to_location_code(l_tab_count) := p_po_line_rec.enforce_ship_to_location_code;
      x_line_rec.shipping_details_updated_on(l_tab_count) := p_po_line_rec.shipping_details_updated_on;
      x_line_rec.carrier_id(l_tab_count) := p_po_line_rec.carrier_id;
      x_line_rec.drop_ship_flag(l_tab_count) := p_po_line_rec.drop_ship_flag;
      x_line_rec.closed_flag(l_tab_count) := p_po_line_rec.closed_flag;
      x_line_rec.closed_code(l_tab_count) := p_po_line_rec.closed_code;
      x_line_rec.cancelled_flag(l_tab_count) := p_po_line_rec.cancelled_flag;
      x_line_rec.source_code(l_tab_count) := 'PO';
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Middle 4');
        END IF;
      x_line_rec.shipping_interfaced_flag(l_tab_count) := 'Y';
      x_line_rec.shipping_eligible_flag(l_tab_count) := 'Y';
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Middle 5');
        END IF;
      -- bug 3151205
      x_line_rec.source_header_type_id(l_tab_count) := p_po_line_rec.source_header_type_id;
      x_line_rec.source_header_type_name(l_tab_count) := p_po_line_rec.source_header_type_name;
      x_line_rec.net_weight(l_tab_count) := p_po_line_rec.net_weight;
      x_line_rec.weight_uom_code(l_tab_count) := p_po_line_rec.weight_uom_code;
      x_line_rec.volume(l_tab_count) := p_po_line_rec.volume;
      x_line_rec.volume_uom_code(l_tab_count) := p_po_line_rec.volume_uom_code;
      x_line_rec.cancelled_quantity2(l_tab_count) := p_po_line_rec.cancelled_quantity2;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'After assigning the values');
    END IF;
      IF (nvl(x_line_rec.drop_ship_flag(l_tab_count),'N') = 'Y') THEN
      --{
        get_drop_ship_info(
          p_line_rec  => x_line_rec,
          p_index     => l_tab_count,
          x_return_status => l_return_status);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       wsh_util_core.api_post_call(
         p_return_status    => l_return_status,
         x_num_warnings     => l_num_warnings,
         x_num_errors       => l_num_errors);
      --}
      END IF;
    --}
    ELSE
    --{
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Before assigning the values');
      END IF;
      x_line_rec.org_id(l_tab_count) := x_line_rec.org_id(p_prev_line_rec_index);
      x_line_rec.header_id(l_tab_count) := x_line_rec.header_id(p_prev_line_rec_index);
      x_line_rec.line_id(l_tab_count) := x_line_rec.line_id(p_prev_line_rec_index);
      x_line_rec.po_shipment_line_id(l_tab_count) :=  x_line_rec.po_shipment_line_id(p_prev_line_rec_index);
      x_line_rec.source_blanket_reference_id(l_tab_count) := x_line_rec.source_blanket_reference_id(p_prev_line_rec_index);
      x_line_rec.source_blanket_reference_num(l_tab_count) := x_line_rec.source_blanket_reference_num(p_prev_line_rec_index);
      x_line_rec.source_header_number(l_tab_count) := x_line_rec.source_header_number(p_prev_line_rec_index);
      x_line_rec.hold_code(l_tab_count)      :=      x_line_rec.hold_code(p_prev_line_rec_index);
      x_line_rec.vendor_id(l_tab_count)      :=      x_line_rec.vendor_id(p_prev_line_rec_index);
      x_line_rec.ship_from_site_id(l_tab_count)      :=      x_line_rec.ship_from_site_id(p_prev_line_rec_index);
      x_line_rec.freight_terms_code(l_tab_count)      :=      x_line_rec.freight_terms_code(p_prev_line_rec_index);
      x_line_rec.fob_point_code(l_tab_count)      :=      x_line_rec.fob_point_code(p_prev_line_rec_index);
      x_line_rec.shipping_control(l_tab_count)      :=      x_line_rec.shipping_control(p_prev_line_rec_index);
      x_line_rec.po_revision(l_tab_count)      :=      x_line_rec.po_revision(p_prev_line_rec_index);
      x_line_rec.currency_code(l_tab_count)      :=      x_line_rec.currency_code(p_prev_line_rec_index);
       x_line_rec.release_revision(l_tab_count)      :=      x_line_rec.release_revision(p_prev_line_rec_index);
       x_line_rec.source_line_number(l_tab_count)      :=      x_line_rec.source_line_number(p_prev_line_rec_index);
       x_line_rec.supplier_item_num(l_tab_count)      :=      x_line_rec.supplier_item_num(p_prev_line_rec_index);
       x_line_rec.source_line_type_code(l_tab_count)      :=      x_line_rec.source_line_type_code(p_prev_line_rec_index);
       x_line_rec.hazard_class_id(l_tab_count)      :=      x_line_rec.hazard_class_id(p_prev_line_rec_index);
       x_line_rec.inventory_item_id(l_tab_count)      :=      x_line_rec.inventory_item_id(p_prev_line_rec_index);
       x_line_rec.item_description(l_tab_count)      :=      x_line_rec.item_description(p_prev_line_rec_index);
       x_line_rec.revision(l_tab_count)      :=      x_line_rec.revision(p_prev_line_rec_index);
       x_line_rec.po_shipment_line_number(l_tab_count)      :=      x_line_rec.po_shipment_line_number(p_prev_line_rec_index);
       x_line_rec.country_of_origin(l_tab_count)      :=      x_line_rec.country_of_origin(p_prev_line_rec_index);
       x_line_rec.organization_id(l_tab_count)      :=      x_line_rec.organization_id(p_prev_line_rec_index);
       x_line_rec.ship_to_org_id(l_tab_count)      :=      null;
       --x_line_rec.ship_to_org_id(l_tab_count)      :=      x_line_rec.ship_to_org_id(p_prev_line_rec_index);
       x_line_rec.ship_to_location_id(l_tab_count)      :=      x_line_rec.ship_to_location_id(p_prev_line_rec_index);
       x_line_rec.ordered_quantity(l_tab_count)      :=      x_line_rec.ordered_quantity(p_prev_line_rec_index);
       x_line_rec.order_quantity_uom(l_tab_count)      :=      x_line_rec.order_quantity_uom(p_prev_line_rec_index);
       x_line_rec.unit_list_price(l_tab_count)      :=      x_line_rec.unit_list_price(p_prev_line_rec_index);
       --x_line_rec.status_code(l_tab_count)      :=      x_line_rec.status_code(p_prev_line_rec_index);
       x_line_rec.preferred_grade(l_tab_count)      :=      x_line_rec.preferred_grade(p_prev_line_rec_index);
       x_line_rec.cancelled_quantity(l_tab_count)      :=      x_line_rec.cancelled_quantity(p_prev_line_rec_index);
       x_line_rec.ordered_quantity2(l_tab_count)      :=      x_line_rec.ordered_quantity2(p_prev_line_rec_index);
       x_line_rec.ordered_quantity_uom2(l_tab_count)      :=      x_line_rec.ordered_quantity_uom2(p_prev_line_rec_index);
       x_line_rec.ship_tolerance_above(l_tab_count)      :=      x_line_rec.ship_tolerance_above(p_prev_line_rec_index);
       x_line_rec.ship_tolerance_below(l_tab_count)      :=      x_line_rec.ship_tolerance_below(p_prev_line_rec_index);
       x_line_rec.qty_rcv_exception_code(l_tab_count)      :=      x_line_rec.qty_rcv_exception_code(p_prev_line_rec_index);
       x_line_rec.request_date(l_tab_count)      :=      x_line_rec.request_date(p_prev_line_rec_index);
       x_line_rec.schedule_ship_date(l_tab_count)      :=      x_line_rec.schedule_ship_date(p_prev_line_rec_index);
       x_line_rec.days_early_receipt_allowed(l_tab_count)      :=      x_line_rec.days_early_receipt_allowed(p_prev_line_rec_index);
       x_line_rec.days_late_receipt_allowed(l_tab_count)      :=      x_line_rec.days_late_receipt_allowed(p_prev_line_rec_index);
       x_line_rec.receipt_days_exception_code(l_tab_count)      :=      x_line_rec.receipt_days_exception_code(p_prev_line_rec_index);
       x_line_rec.enforce_ship_to_location_code(l_tab_count)      :=      x_line_rec.enforce_ship_to_location_code(p_prev_line_rec_index);
       x_line_rec.shipping_details_updated_on(l_tab_count)      :=      x_line_rec.shipping_details_updated_on(p_prev_line_rec_index);
       x_line_rec.carrier_id(l_tab_count)      :=      x_line_rec.carrier_id(p_prev_line_rec_index);
      x_line_rec.drop_ship_flag(l_tab_count) := x_line_rec.drop_ship_flag(p_prev_line_rec_index);
      x_line_rec.closed_flag(l_tab_count) := x_line_rec.closed_flag(p_prev_line_rec_index);
      x_line_rec.closed_code(l_tab_count) := x_line_rec.closed_code(p_prev_line_rec_index);
      x_line_rec.cancelled_flag(l_tab_count) := x_line_rec.cancelled_flag(p_prev_line_rec_index);
      x_line_rec.source_code(l_tab_count)      :=     'PO';
      -- bug 3151205
      x_line_rec.source_header_type_id(l_tab_count) := x_line_rec.source_header_type_id(p_prev_line_rec_index);
      x_line_rec.source_header_type_name(l_tab_count) := x_line_rec.source_header_type_name(p_prev_line_rec_index);
      x_line_rec.net_weight(l_tab_count) := x_line_rec.net_weight(p_prev_line_rec_index);
      x_line_rec.weight_uom_code(l_tab_count) := x_line_rec.weight_uom_code(p_prev_line_rec_index);
      x_line_rec.volume(l_tab_count) := x_line_rec.volume(p_prev_line_rec_index);
      x_line_rec.volume_uom_code(l_tab_count) := x_line_rec.volume_uom_code(p_prev_line_rec_index);
      x_line_rec.cancelled_quantity2(l_tab_count) := p_po_line_rec.cancelled_quantity2;
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'After assigning the values');
       END IF;
    --}
    END IF;
    --
    IF l_num_errors > 0
    THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    --
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INBOUND_UTIL_PKG.COPY_PO_REC_TO_LINE_REC');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END copy_po_rec_to_line_rec;

--========================================================================
-- PROCEDURE : get_rcv_line_attribs     This procedure derives the attributes
--                                      from rcv_fte_lines_v, rcv_fte_headers_v
--                                      based on the input p_shipment_line_id
--                                      updates x_line_rec with
--                                      these attributes.
--
-- PARAMETERS:  p_shipment_line_id      Shipment_line_id of rcv_shipment_lines
--		x_line_rec              OE_WSH_BULK_GRP.line_rec_type
--		x_return_status         Return status of the API.
--
-- COMMENT   : This procedure derives the x_line_rec based on the inputs
--             p_po_line_location_id and p_rcv_shipment_line_id
--             The following is the flow of this procedure -
--             1. We first check if a record already exists in the
--                x_line_rec before performing the query.  If it exists
--                we pass the previous record's index to l_prev_line_rec_index
--                else we call PO_FTE_INTEGRATION_GRP.get_po_release_attributes
--                to get the attributes from PO
--             2. Then we call the API copy_po_rec_to_line_rec
--                passing the appropriate inputs based on the step1.
--             3. Then we check if the input parameter p_rcv_shipment_line_id.
--                If it is not null, then we call get_rcv_line_attribs to
--                obtain the attributes into x_line_rec from rcv tables as well.
--========================================================================
  PROCEDURE get_rcv_line_attribs(
              p_shipment_line_id  IN NUMBER,
              x_line_rec    IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
              x_return_status OUT NOCOPY VARCHAR2)
  IS
  --{
    cursor l_shipment_header_csr (p_shipment_header_id IN NUMBER) is
    select SHIPMENT_NUM,
           RECEIPT_NUM,
           BILL_OF_LADING,
           CARRIER_ID,
           EXPECTED_RECEIPT_DATE,
           SHIPPED_DATE,
           PACKING_SLIP,
           FREIGHT_TERMS_CODE,
           WAYBILL_AIRBILL_NUMBER,
           NUM_OF_CONTAINERS,
           GROSS_WEIGHT,
           GROSS_WEIGHT_UOM_CODE,
           NET_WEIGHT,
           NET_WEIGHT_UOM_CODE,
           TARE_WEIGHT,
           TARE_WEIGHT_UOM_CODE,
           asn_type
    from   rcv_fte_headers_v
    where  shipment_header_id = p_shipment_header_id;

    cursor l_shipment_line_csr (p_shipment_line_id IN NUMBER) is
    select shipment_line_id,
           item_id,
           item_revision,
           item_description,
           quantity_shipped,
           quantity_received,
           packing_slip,
           secondary_quantity_shipped,
           secondary_quantity_received,
           container_num,
           truck_num,
           asn_lpn_id,
           shipment_header_id
     from  rcv_fte_lines_v
     where shipment_line_id = p_shipment_line_id;

    l_line_rec_count NUMBER;
    l_packing_slip_num VARCHAR2(32767);
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_RCV_LINE_ATTRIBS';
  --
  BEGIN
  --{
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_LINE_ID',P_SHIPMENT_LINE_ID);
    END IF;
    --
    l_line_rec_count := x_line_rec.po_shipment_line_id.count;

    open  l_shipment_line_csr(p_shipment_line_id);
    fetch l_shipment_line_csr into x_line_rec.shipment_line_id(l_line_rec_count),
                                   x_line_rec.rcv_inventory_item_id(l_line_rec_count),
                                   x_line_rec.rcv_revision(l_line_rec_count),
                                   x_line_rec.rcv_item_description(l_line_rec_count),
                                   x_line_rec.shipped_quantity(l_line_rec_count),
                                   x_line_rec.received_quantity(l_line_rec_count),
                                   x_line_rec.packing_slip_number(l_line_rec_count),
                                   x_line_rec.shipped_quantity2(l_line_rec_count),
                                   x_line_rec.received_quantity2(l_line_rec_count),
                                   x_line_rec.container_num(l_line_rec_count),
                                   x_line_rec.truck_num(l_line_rec_count),
                                   x_line_rec.lpn_id(l_line_rec_count),
                                   x_line_rec.shipment_header_id(l_line_rec_count);
    close l_shipment_line_csr;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'After fetching the shipment line');
    END IF;
    open  l_shipment_header_csr(x_line_rec.shipment_header_id(l_line_rec_count));
    fetch l_shipment_header_csr into x_line_rec.shipment_num(l_line_rec_count),
                                    x_line_rec.receipt_num(l_line_rec_count),
                                    x_line_rec.bill_of_lading(l_line_rec_count),
                                    x_line_rec.rcv_carrier_id(l_line_rec_count),
                                    x_line_rec.expected_receipt_date(l_line_rec_count),
                                    x_line_rec.shipped_date(l_line_rec_count),
                                    l_packing_slip_num,
                                    x_line_rec.rcv_freight_terms_code(l_line_rec_count),
                                    x_line_rec.tracking_number(l_line_rec_count),
                                    x_line_rec.num_of_containers(l_line_rec_count),
                                    x_line_rec.rcv_gross_weight(l_line_rec_count),
                                    x_line_rec.rcv_gross_weight_uom_code(l_line_rec_count),
                                    x_line_rec.rcv_net_weight(l_line_rec_count),
                                    x_line_rec.rcv_net_weight_uom_code(l_line_rec_count),
                                    x_line_rec.rcv_tare_weight(l_line_rec_count),
                                    x_line_rec.rcv_tare_weight_uom_code(l_line_rec_count),
                                    x_line_rec.asn_type(l_line_rec_count);
    close l_shipment_header_csr;

    x_line_rec.packing_slip_number(l_line_rec_count) := nvl(x_line_rec.packing_slip_number(l_line_rec_count), l_packing_slip_num);
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INBOUND_UTIL_PKG.GET_RCV_LINE_ATTRIBS');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END get_rcv_line_attribs;
--========================================================================
-- PROCEDURE : get_po_rcv_attributes    This procedure derives the
--                                      x_line_rec based on the inputs
--                                      p_po_line_location_id and
--                                      p_rcv_shipment_line_id.
--
-- PARAMETERS:  p_po_line_location_id   po_line_location_id of
--                                      po_line_locations_all
--		p_rcv_shipment_line_id  shipment_line_id of rcv_shipment_lines
--		x_line_rec              Out parameter of type
--                                      OE_WSH_BULK_GRP.line_rec_type
--		x_return_status         Return status of the API.
--
-- COMMENT   : This procedure derives the x_line_rec based on the inputs
--             p_po_line_location_id and p_rcv_shipment_line_id
--========================================================================

  PROCEDURE get_po_rcv_attributes(
              p_po_line_location_id IN NUMBER,
              p_rcv_shipment_line_id IN NUMBER DEFAULT NULL,
              x_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
              x_return_status OUT NOCOPY VARCHAR2)

  IS
  --{
    l_po_line_rec PO_FTE_INTEGRATION_GRP.po_release_rec_type;
    l_line_rec_count NUMBER;
    l_get_attr_from_po BOOLEAN := FALSE;
    l_prev_line_rec_index NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);
    l_num_warnings NUMBER;
    l_num_errors NUMBER;
  --}
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_PO_RCV_ATTRIBUTES';
  --
  BEGIN
  --{

    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_PO_LINE_LOCATION_ID',P_PO_LINE_LOCATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_RCV_SHIPMENT_LINE_ID',P_RCV_SHIPMENT_LINE_ID);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    l_line_rec_count := x_line_rec.po_shipment_line_id.count;
    IF l_line_rec_count < 1 THEN -- This means we have to call PO's API
      l_get_attr_from_po := TRUE;
    END IF;
    IF l_line_rec_count > 0 THEN
    --{
      IF (x_line_rec.po_shipment_line_id(l_line_rec_count) <> p_po_line_location_id) THEN
      --{
        l_get_attr_from_po := TRUE;
      --}
      ELSE
      --{
        l_prev_line_rec_index := x_line_rec.po_shipment_line_id.count;
      --}
      END IF;
    --}
    END IF;

    -- call PO's API to obtain all the attributes for the po_line_location_id
    IF l_get_attr_from_po THEN
    --{

      IF (PO_CODE_RELEASE_GRP.Current_Release >= PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J)  THEN
      --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit PO_FTE_INTEGRATION_GRP.GET_PO_RELEASE_ATTRIBUTES',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        PO_FTE_INTEGRATION_GRP.get_po_release_attributes(
          p_api_version            => 1.0,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data,
          p_line_location_id       => p_po_line_location_id,
          x_po_releases_attributes => l_po_line_rec);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status is',l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
    p_return_status    => l_return_status,
    x_num_warnings     => l_num_warnings,
    x_num_errors       => l_num_errors);
      --}
      ELSE
      --{
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'PO Release less than 11.5.10');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      --}
      END IF;
    --}
    END IF;

    copy_po_rec_to_line_rec(
      p_po_line_rec => l_po_line_rec,
      x_line_rec    => x_line_rec,
      p_po_line_location_id => p_po_line_location_id,
      p_prev_line_rec_index => l_prev_line_rec_index,
      x_return_status => l_return_status);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_return_status is',l_return_status);
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status    => l_return_status,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);

      --x_line_rec.po_shipment_line_id

    IF p_rcv_shipment_line_id IS NOT NULL THEN
    --{
      get_rcv_line_attribs(
        p_shipment_line_id => p_rcv_shipment_line_id,
        x_line_rec    => x_line_rec,
        x_return_status => l_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status is',l_return_status);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
    --}
    END IF;
    --
    IF l_num_errors > 0
    THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    --
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION
  --{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_INBOUND_UTIL_PKG.GET_PO_RCV_ATTRIBUTES');
  --}
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
  END get_po_rcv_attributes;

-- Start of comments
-- API name : GET_DROP_SHIP_INFO
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API derives the value for all the drop ship fields
--	      and populates the same into the p_line_rec sructure.
-- Parameters :
-- IN:
--         p_index     IN  NUMBER
--            The index of the record of the other i/p parameter p_line_rec
--	      on which the API has to perform its function.
-- IN OUT:
--         p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type
--            A record structure which contains all the attributes required
--	      for PO Integration for inbound shipments.
-- OUT:
--         x_return_status OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments


  PROCEDURE  get_drop_ship_info(
         p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
         p_index     IN  NUMBER,
         x_return_status OUT NOCOPY VARCHAR2
         ) IS


  --Cursor to get all the field/column values that are related to drop ship in the OE tables.
  CURSOR c_drop_ship(index_num number) IS
  SELECT
  oh.sold_to_org_id,
  oh.sold_to_contact_id,
  oh.ship_to_contact_id,
  oh.ship_to_org_id,
  oh.deliver_to_contact_id,
  oh.deliver_to_org_id,
  ol.intmed_ship_to_contact_id,
  ol.shipping_method_code,
  ol.cust_production_seq_num,
  ol.customer_dock_code,
  ol.cust_model_serial_number,
  ol.customer_job,
  ol.customer_production_line,
  ol.ship_model_complete_flag,
  ol.top_model_line_id,
  oh.cust_po_number,
  ol.ato_line_id,
  oh.shipping_instructions,
  ol.packing_instructions,
  decode(item_identifier_type,
         'CUST',
         ol.ordered_item_id,
         NULL
        ) customer_item_id,
  ol.intmed_ship_to_org_id
  FROM
  oe_order_headers_all oh,
  oe_order_lines_all ol,
  oe_drop_ship_sources od
  WHERE
  od.header_id = oh.header_id AND
  od.line_id = ol.line_id     AND
  oh.header_id = ol.header_id AND
  od.line_location_id = p_line_rec.po_shipment_line_id(index_num);


  l_return_status    VARCHAR2(1);
  l_api_name      CONSTANT VARCHAR2(30)  := 'get_drop_ship_info';
  l_num_warnings   NUMBER := 0;
  l_num_errors     NUMBER := 0;

  INVALID_DROP_SHIP_INFO   EXCEPTION;
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DROP_SHIP_INFO';
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
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.push(l_module_name);
         WSH_DEBUG_SV.log(l_module_name,'P_INDEX',P_INDEX);
         WSH_DEBUG_SV.log(l_module_name,'p_line_rec.po_shipment_line_id(p_index)',p_line_rec.po_shipment_line_id(p_index));
     END IF;
     --
     x_return_status :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     OPEN c_drop_ship(p_index);
     FETCH c_drop_ship
     INTO
      p_line_rec.sold_to_org_id(p_index),
  p_line_rec.sold_to_contact_id(p_index),
  p_line_rec.ship_to_contact_id(p_index),
  p_line_rec.ship_to_org_id(p_index),
  p_line_rec.deliver_to_contact_id(p_index),
  p_line_rec.deliver_to_org_id(p_index),
  p_line_rec.intermed_ship_to_contact_id(p_index),
  p_line_rec.shipping_method_code(p_index),
  p_line_rec.cust_production_seq_num(p_index),
  p_line_rec.customer_dock_code(p_index),
  p_line_rec.cust_model_serial_number(p_index),
  p_line_rec.customer_job(p_index),
  p_line_rec.customer_production_line(p_index),
  p_line_rec.ship_model_complete_flag(p_index),
  p_line_rec.top_model_line_id(p_index),
  p_line_rec.cust_po_number(p_index),
  p_line_rec.ato_line_id(p_index),
  p_line_rec.shipping_instructions(p_index),
  p_line_rec.packing_instructions(p_index),
  p_line_rec.customer_item_id(p_index),
  p_line_rec.intermed_ship_to_org_id(p_index);

     IF (c_drop_ship%NOTFOUND) THEN
       CLOSE c_drop_ship;
       RAISE INVALID_DROP_SHIP_INFO;
     END IF;

     CLOSE c_drop_ship;



     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,' p_line_rec.deliver_to_org_id(p_index)', p_line_rec.deliver_to_org_id(p_index));
         WSH_DEBUG_SV.log(l_module_name,'p_line_rec.intermed_ship_to_org_id(p_index)',p_line_rec.intermed_ship_to_org_id(p_index));
         WSH_DEBUG_SV.log(l_module_name,'p_line_rec.ship_to_location_id(p_index)',p_line_rec.ship_to_location_id(p_index));
     END IF;

    --Deriving deliver_to_location  from ship_to_location_id or deliver_to_org_id
    IF (p_line_rec.deliver_to_org_id(p_index) IS NOT NULL)  THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_LOCATION_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      --Call API WSH_UTIL_CORE.GET_LOCATION_ID to get the Deliver_to_location_id.
      WSH_UTIL_CORE.GET_LOCATION_ID(
        p_mode   =>   'CUSTOMER SITE',
        p_source_id  =>   p_line_rec.deliver_to_org_id(p_index),
        x_location_id  =>   p_line_rec.deliver_to_location_id(p_index),
        x_api_status =>   l_return_status);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
         p_return_status => l_return_status,
         x_num_warnings  => l_num_warnings,
         x_num_errors    => l_num_errors);

    --use the  ship_to_lcation_id as the deliver_to_location_id
     ELSE
        p_line_rec.deliver_to_location_id(p_index) := p_line_rec.ship_to_location_id(p_index);
     END IF;


     --Deriving intmed_ship_to_location  from ship_to_org_id
     IF (p_line_rec.intermed_ship_to_org_id(p_index) IS NOT NULL) THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_LOCATION_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       --Call API WSH_UTIL_CORE.GET_LOCATION_ID to get the intmed_ship_to_location_id.
       WSH_UTIL_CORE.GET_LOCATION_ID(
         p_mode   => 'CUSTOMER SITE',
         p_source_id  => p_line_rec.intermed_ship_to_org_id(p_index),
         x_location_id  => p_line_rec.intmed_ship_to_location_id(p_index),
         x_api_status => l_return_status);

       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       wsh_util_core.api_post_call(
         p_return_status => l_return_status,
         x_num_warnings  => l_num_warnings,
         x_num_errors    => l_num_errors);
     END IF;

    --
    IF l_num_errors > 0
    THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    --
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
   WHEN INVALID_DROP_SHIP_INFO THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('WSH','WSH_IB_DERIVE_DROPSHP_FAILED');
     WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_DROP_SHIP_INFO exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_DROP_SHIP_INFO');
     END IF;
     --
   WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_BULK_PROCESS_PVT.get_drop_ship_info',l_module_name);
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     --
END  get_drop_ship_info;



--
--========================================================================
-- PROCEDURE : split_inbound_delivery
--
-- PARAMETERS: p_delivery_detail_id_tbl Table of delivery lines to be split from original delivery
--             p_delivery_id            Original Delivery ID
--             x_delivery_id            New Delivery ID
--             x_return_status          Return status of the API
--
-- COMMENT   : This procedure is called only from the Inbound ASN/Receipt
--             integration to split an existing delivery.
--             It performs the following steps:
--             01. Validate that input delivery id is not null and is a valid delivery.
--             02. Validate that input table of lines contain at least one record.
--             03. If input delivery is outbound, return with error.
--             04. Clone the original delivery
--             05. Assign input lines to new delivery
--             06. Update Freight terms for new and original delivery
--             07. Update dates for new and original delivery
--
--========================================================================
--
PROCEDURE split_inbound_delivery
    (
        p_delivery_detail_id_tbl IN wsh_util_core.id_tab_type,
        p_delivery_id            IN NUMBER,
        x_delivery_id            IN OUT NOCOPY NUMBER,
        x_return_status      OUT NOCOPY     VARCHAR2,
        p_caller                   IN VARCHAR2 DEFAULT 'WSH_ASN_RECEIPT'
    )
IS
    CURSOR dlvy_csr (p_delivery_id IN NUMBER)
    IS
        SELECT organization_id,
               nvl(shipment_direction,'O') shipment_direction,
               name,
         initial_pickup_location_id,
       status_code
        FROM   wsh_new_deliveries wnd
        WHERE  delivery_id             = p_delivery_id;
    --
    --
    l_dlvy_rec dlvy_csr%ROWTYPE;
    --
    CURSOR wdd_csr(p_delivery_detail_id IN NUMBER)
    IS
    SELECT lpn_id,
           tracking_number,
           container_name
    FROM wsh_delivery_details
    WHERE delivery_detail_id = p_delivery_detail_id;
    --
    l_lpn_id           NUMBER;
    l_lpn_name     VARCHAR2(50);
    l_waybill          VARCHAR2(30);
    --
    --
    CURSOR wda_csr(p_delivery_id IN NUMBER)
    IS
    SELECT wdd.delivery_detail_id,
           wda.parent_delivery_detail_id
    FROM wsh_delivery_details wdd,
         wsh_delivery_assignments wda,
         wsh_wms_sync_tmp wwst
    WHERE wwst.delivery_id = p_delivery_id
    AND nvl(wda.type,'S') IN ('S','O')
    AND wdd.delivery_detail_id = wda.delivery_detail_id
    AND wwst.operation_type='VENDOR_MRG'
    AND wwst.temp_col IS NULL
    AND wdd.delivery_detail_id = wwst.delivery_detail_id
    AND wda.parent_delivery_detail_id IS NOT NULL
    ORDER BY wda.parent_delivery_detail_id;
    --
    l_wdd_id_tbl           wsh_util_core.id_tab_type;
    l_parent_wdd_id_tbl    wsh_util_core.id_tab_type;
    l_tmp_wdd_id_tbl       wsh_util_core.id_tab_type;
    l_index		   NUMBER;
    l_parent_wdd_id	   NUMBER;
    l_prev_parent_wdd_id   NUMBER;
    l_new_parent_wdd_id	   NUMBER;
    l_count		   NUMBER;
    l_txn_type		   VARCHAR2(20);
    l_temp_tbl		   wsh_util_core.id_tab_type;
    --
    l_num_warnings                NUMBER := 0;
    l_num_errors                  NUMBER := 0;
    l_return_status               VARCHAR2(10);
    --
    l_delivery_id                 NUMBER := NULL;
    l_rowid                       VARCHAR2(32767);

    l_query_count		NUMBER;
    --
   l_delivery_rec                 WSH_NEW_DELIVERIES_PVT.delivery_rec_type;
   l_leg_id_tbl                   wsh_util_core.id_tab_type;
   l_line_tbl                     wsh_util_core.id_tab_type;
   l_entity_ids                   wsh_util_core.id_tab_type;
   l_dlvy_freight_terms_code      VARCHAR2(30);
   --
   l_debug_on                    BOOLEAN;
   l_module_name        CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'split_inbound_delivery';
   --
   l_current_parent_wdd_id       NUMBER;
   --
BEGIN
    SAVEPOINT split_inbound_delivery_sp;
    --
    l_debug_on := wsh_debug_interface.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      --
      wsh_debug_sv.LOG(l_module_name, 'p_delivery_id', p_delivery_id);
      wsh_debug_sv.log(l_module_name, 'p_delivery_detail_id_tbl.COUNT', p_delivery_detail_id_tbl.COUNT);
    END IF;
    --
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    --
    IF p_delivery_id IS NULL
    THEN
    --{
        --
        -- p_delivery_id is mandatory
        --
        FND_MESSAGE.SET_NAME('WSH', 'WSH_REQUIRED_FIELD_NULL');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'p_delivery_id');
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    IF p_delivery_detail_id_tbl.count = 0
    THEN
    --{
        --
        -- p_delivery_detail_id_tbl should have at least one record
        --
        FND_MESSAGE.SET_NAME('WSH', 'WSH_EMPTY_TABLE_ERROR');
        FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'p_delivery_detail_id_tbl');
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --

    --
    OPEN dlvy_csr(p_delivery_id);
    FETCH dlvy_csr INTO l_dlvy_rec;
    CLOSE dlvy_csr;
    --
    IF l_dlvy_rec.initial_pickup_location_id IS NULL
    THEN
    --{
        FND_MESSAGE.SET_NAME('WSH','WSH_DLVY_NOT_EXIST');
        FND_MESSAGE.SET_TOKEN('DELIVERY_ID', p_delivery_id);
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    IF l_dlvy_rec.shipment_direction IN ('O','IO')
    THEN
    --{
        --
        -- Invalid operation for outbound delivery
        --
        FND_MESSAGE.SET_NAME('WSH','WSH_NOT_IB_DLVY_ERROR');
        FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', l_dlvy_rec.name);
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
        RAISE FND_API.G_EXC_ERROR;
    --}
    END IF;
    --
    --
    --
    IF x_delivery_id IS NULL THEN
	    l_delivery_rec.wv_frozen_flag := 'N';
	    l_delivery_rec.routing_response_id := FND_API.G_MISS_NUM ;

	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.clone',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;
	    --
	    -- Clone the input delivery
	    --
	    WSH_NEW_DELIVERIES_PVT.clone
	    (
		p_delivery_rec      => l_delivery_rec,
		p_delivery_id       => p_delivery_id,
		p_copy_legs         => 'Y',
		x_delivery_id       => l_delivery_id,
		x_rowid             => l_rowid,
		x_leg_id_tab        => l_leg_id_tbl,
		x_return_status     => l_return_Status
	    ) ;
	    --
	    wsh_util_core.api_post_call
	      (
		p_return_status => l_return_status,
		x_num_warnings  => l_num_warnings,
		x_num_errors    => l_num_errors
	      );
            --
            x_delivery_id := l_delivery_id;
            --
     ELSE
	     l_delivery_id := x_delivery_id;
	    --
     END IF;
    --
   --
   -- Assign input lines to new delivery.
   --
   FORALL i IN p_delivery_detail_id_tbl.FIRST..p_delivery_detail_id_tbl.LAST
   UPDATE wsh_delivery_assignments_v
   SET      delivery_id        = l_delivery_id,
            last_update_date   = SYSDATE,
            last_updated_by    = FND_GLOBAL.USER_ID,
            last_update_login  = FND_GLOBAL.LOGIN_ID
   WHERE    delivery_detail_id = p_delivery_detail_id_tbl(i);
   --
   --
   IF SQL%ROWCOUNT <> p_delivery_detail_id_tbl.COUNT
   THEN
   --{
        RAISE NO_DATA_FOUND;  ---add message later.
   --}
   END IF;
   --
   --
   IF p_caller = 'WSH_VENDOR_MERGE'  THEN
    --{
    OPEN wda_csr(p_delivery_id => p_delivery_id);
    FETCH wda_csr BULK COLLECT INTO l_wdd_id_tbl, l_parent_wdd_id_tbl;
    CLOSE wda_csr;
    --
    IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'l_wdd_id_tbl.COUNT', l_wdd_id_tbl.COUNT);
     wsh_debug_sv.log(l_module_name, 'l_parent_wdd_id_tbl.COUNT', l_parent_wdd_id_tbl.COUNT);
    END IF;
    --
    l_index := l_parent_wdd_id_tbl.FIRST;
    l_count := 1;
    --
    IF l_dlvy_rec.status_code ='IT' THEN
      l_txn_type := 'ASN';
    ELSE
      l_txn_type:='RECEIPT';
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'l_txn_type', l_txn_type);
    END IF;
    --
    IF l_index IS NOT NULL THEN
     --{
     WHILE TRUE -- will exit when l_index IS NULL
      --
      Loop
       --{
       l_current_parent_wdd_id := l_parent_wdd_id_tbl(nvl(l_index,l_parent_wdd_id_tbl.LAST));
       --
       IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name, '---------------------------------');
        wsh_debug_sv.log(l_module_name, 'l_index', l_index);
        wsh_debug_sv.log(l_module_name, 'l_prev_parent_wdd_id', l_prev_parent_wdd_id);
        wsh_debug_sv.log(l_module_name, 'l_current_parent_wdd_id', l_current_parent_wdd_id);
       END IF;
       --
       IF l_current_parent_wdd_id <> l_prev_parent_wdd_id or l_index IS NULL
       THEN
        --{
	l_parent_wdd_id := l_prev_parent_wdd_id;
	--
        IF l_debug_on THEN
         wsh_debug_sv.logmsg(l_module_name, '-----------------------------');
         wsh_debug_sv.log(l_module_name, 'Processing LPN', l_parent_wdd_id);
         wsh_debug_sv.logmsg(l_module_name, '------------------------------');
        END IF;
        --
        OPEN wdd_csr(p_delivery_detail_id =>l_parent_wdd_id);
        FETCH wdd_csr INTO l_lpn_id, l_lpn_name, l_waybill;
        CLOSE wdd_csr;
        --
        IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name, 'l_lpn_id', l_lpn_id);
         wsh_debug_sv.log(l_module_name, 'l_lpn_name', l_lpn_name);
         wsh_debug_sv.log(l_module_name, 'l_waybill', l_waybill);
        END IF;
        --
        l_new_parent_wdd_id :=NULL;
        --
        BEGIN
         --{
         SELECT wdd.delivery_detail_id
         INTO l_new_parent_wdd_id
         FROM wsh_delivery_Details wdd,
              wsh_delivery_assignments wda
         WHERE wda.delivery_id = l_delivery_id
         AND wda.delivery_detail_id = wdd.delivery_detail_id
         AND NVL(wda.type,'S') IN ('S','O')
         AND wdd.lpn_id = l_lpn_id;
         --
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_new_parent_wdd_id := NULL;
         --}
        END;
        --
        IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name, 'l_new_parent_wdd_id', l_new_parent_wdd_id);
        END IF;
        --
        IF l_new_parent_wdd_id IS NOT NULL  THEN
         --{
         FORALL I in l_tmp_wdd_id_tbl.first..l_tmp_wdd_id_tbl.last
          --
          UPDATE wsh_delivery_assignments
          SET parent_delivery_detail_id = l_new_parent_wdd_id
          WHERE delivery_detail_id = l_tmp_wdd_id_tbl(i);
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TP_RELEASE.CALCULATE_CONT_DEL_TPDATES',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          l_temp_tbl.delete ;
          l_temp_tbl(1) := l_parent_wdd_id;        --used to pass  l_parent_wdd_id in the procedure below
          --
          wsh_tp_release.calculate_cont_del_tpdates(
                             p_entity => 'LPN',
                             p_entity_ids => l_temp_tbl,
                             x_return_status => l_return_status
                             );
          --
          wsh_util_core.api_post_call(
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                           );
          --}
         ELSE
          --{
          IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.PACK_INBOUND_LINES',WSH_DEBUG_SV.C_PROC_LEVEL);
           WSH_DEBUG_SV.log(l_module_name, 'l_tmp_wdd_id_tbl.COUNT', l_tmp_wdd_id_tbl.COUNT);
          END IF;
          --
          wsh_container_actions.pack_inbound_lines(
                        p_lines_tbl       => l_tmp_wdd_id_tbl,
                        p_lpn_id          => l_lpn_id,
                        p_lpn_name        => l_lpn_name,
                        p_delivery_id     => l_delivery_id,
                        p_transactionType => l_txn_type,
                        x_return_status   => l_return_status,
                        p_waybill_number  => l_waybill,
                        p_caller          => p_caller
                       );
          --
          wsh_util_core.api_post_call(
                       p_return_status => l_return_status,
                       x_num_warnings  => l_num_warnings,
                       x_num_errors    => l_num_errors
                      );
          --}
         END IF; --IF l_new_parent_wdd_id IS NOT NULL
         --
         SELECT count(1) INTO l_query_count
         FROM wsh_delivery_assignments
         WHERE delivery_id = p_delivery_id
         AND parent_delivery_detail_id = l_parent_wdd_id
         AND nvl(type,'S') IN ('S','O');
         --
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'l_query_count', l_query_count);
         END IF;
         --
         IF l_query_count = 0  THEN
          --{
          DELETE FROM wsh_delivery_assignments
          WHERE delivery_detail_id = l_parent_wdd_id;
          --
          DELETE FROM wsh_delivery_details
          WHERE delivery_detail_id = l_parent_wdd_id;
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTEGRATION.DBI_UPDATE_DETAIL_LOG',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          l_temp_tbl.delete;
          l_temp_tbl(1) := l_parent_wdd_id; -- to pass  l_parent_wdd_id in procedure below
          --
          WSH_INTEGRATION.DBI_Update_Detail_Log(
                 p_delivery_detail_id_tab => l_temp_tbl,
                 p_dml_type => 'DELETE',
                 x_return_status   => l_return_status
               );
          --
          IF l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          --
          wsh_util_core.api_post_call(
                     p_return_status => l_return_status,
                     x_num_warnings  => l_num_warnings,
                     x_num_errors    => l_num_errors
                    );
          --}
         END IF; -- IF l_query_count = 0
         --
         l_tmp_wdd_id_tbl.delete;
         l_count := 1;
         --}
        END IF;
        --
        IF ( l_index IS NULL ) THEN
          EXIT; --come out of loop
        ELSE
          l_tmp_wdd_id_tbl(l_count) := l_wdd_id_tbl(l_index);
          l_count := l_count + 1;
          l_index := l_parent_wdd_id_tbl.next(l_index);
          l_prev_parent_wdd_id := l_current_parent_wdd_id;
        END IF;
        --}
       END LOOP;
       --}
      END IF; -- l_index IS NOT NULL
      --}
     END IF; -- if p_caller = 'WSH_VENDOR_MERGE'
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.update_freight_terms',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    -- Update freight terms for original delivery
    --
    WSH_NEW_DELIVERY_ACTIONS.update_freight_terms
        (
            p_delivery_id        => p_delivery_id,
            p_action_code        => 'UNASSIGN',
            x_return_status      => l_return_status,
            x_freight_terms_code => l_dlvy_freight_terms_code
        );
    --
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
   --
   --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.update_freight_terms',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    -- Update freight terms for new delivery
    --
    WSH_NEW_DELIVERY_ACTIONS.update_freight_terms
        (
            p_delivery_id        => l_delivery_id,
            p_action_code        => 'ASSIGN',
            x_return_status      => l_return_status,
            x_freight_terms_code => l_dlvy_freight_terms_code
        );
    --
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
   --
   l_entity_ids(1) := p_delivery_id;
   l_entity_ids(2) := l_delivery_id;
   --
   --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_tp_release.calculate_cont_del_tpdates',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
   --
   -- Calculate dates for new and original delivery.
   --
   wsh_tp_release.calculate_cont_del_tpdates
    (
        p_entity        => 'DLVY',
        p_entity_ids    => l_entity_ids,
        x_return_status => l_return_status
    );
   --
   wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
    --
   IF l_num_errors > 0
   THEN
        x_return_status         := WSH_UTIL_CORE.G_RET_STS_ERROR;
   ELSIF l_num_warnings > 0
   THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;
   --
   IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name);
   END IF;
    --
--}
EXCEPTION
--{
      --
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO  split_inbound_delivery_sp;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO  split_inbound_delivery_sp;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN

        ROLLBACK TO  split_inbound_delivery_sp;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        wsh_util_core.default_handler('split_inbound_delivery', l_module_name);
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
--}

END split_inbound_delivery;

--========================================================================
-- PROCEDURE : reRateDeliveries
--
-- PARAMETERS:  p_delivery_id_tab       Delivery to be Re-rated.
--		x_return_status         Return status of the API.
--
-- COMMENT   : This API Rates the Trip of the input Delivery Id, if their
--             corresponding legs are marked for Reprice.
--             Rating is done inline (by calling FTE_TRIP_RATING_GRP.Rate_Trip)
--             when the Receipt of the input Delivery was matched automatically.
--             Rating is done asynchronoulsy (by FND_REQUEST.SUBMIT_REQUEST)
--             when the Receipt of the input Delivery was matched Manually.
--             This (inline Rating or asynchronous rating) is determined
--             by the Global variable WSH_INBOUND_UTIL_PKG.G_ASN_RECEIPT_MATCH_TYPE.
--
--             Hence forth (R12 onwards) if a new Exception Handler is added for this API
--             or any other new return points are added, then care should be taken
--             to set Global variable WSH_INBOUND_UTIL_PKG.G_ASN_RECEIPT_MATCH_TYPE
--             to null.
--========================================================================
--
PROCEDURE reRateDeliveries
    (
        p_delivery_id_tab     IN          wsh_util_core.id_tab_type,
        x_return_status       OUT NOCOPY  VARCHAR2
    )
IS
--{
    CURSOR trips_csr (p_delivery_id IN NUMBER)
    IS
        SELECT wt.trip_id, wt.name, wt.lane_id,
               NVL(wdl.reprice_Required,'N') reprice_required
        FROM   wsh_trips wt,
               wsh_trip_stops wts,
               wsh_delivery_legs wdl
        WHERE  wdl.delivery_id     = p_delivery_id
        AND    wdl.pick_up_stop_id = wts.stop_id
        AND    wt.trip_id          = wts.trip_id
        AND    wt.lane_id IS NOT NULL;
    --
    --
    l_return_status         VARCHAR2(1);
    l_num_warnings          NUMBER;
    l_num_errors            NUMBER;
    l_requestIdList         VARCHAR2(32767);
    l_requestId             NUMBER;
    --
    --
    l_index                 NUMBER;
    --
    l_trip_tbl              wsh_util_core.key_value_tab_type;
    l_trip_ext_tbl          wsh_util_core.key_value_tab_type;
    --
    -- { IB-Phase-2
    l_action_params         FTE_TRIP_RATING_GRP.action_param_rec;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);
    -- } IB-Phase-2
    --
    l_debug_on              BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'reRateDeliveries';
    --
--}
BEGIN
--{
    --SAVEPOINT open_stop_begin_sp;
    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'p_delivery_id_tab.count',p_delivery_id_tab.count);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    --
    l_num_warnings  := 0;
    l_num_errors    := 0;
    --
    --
    -- { IB-Phase-2
    IF nvl(WSH_INBOUND_UTIL_PKG.G_ASN_RECEIPT_MATCH_TYPE,'MANUAL') = 'MANUAL'
    THEN
    --{
        l_index := p_delivery_id_tab.FIRST;
        --
        WHILE l_index IS NOT NULL
        LOOP
        --{
            FOR trips_rec IN trips_csr(p_delivery_id_tab(l_index))
            LOOP
            --{
                IF trips_Rec.reprice_required = 'Y'
                THEN
                --{
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.get_Cached_value',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_UTIL_CORE.get_Cached_value
                        (
                            p_cache_tbl         => l_trip_tbl,
                            p_cache_ext_tbl     => l_trip_ext_tbl,
                            p_key               => trips_rec.trip_id,
                            p_value             => trips_rec.trip_id,
                            p_action            => 'GET',
                            x_return_status     => l_return_status
                        );
                    --
                    --
                    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                    THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
                    THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
                    THEN
		    --{
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit  FND_REQUEST.SUBMIT_REQUEST',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
			l_requestId :=
			FND_REQUEST.SUBMIT_REQUEST
			  (
			    application    => 'FTE',
			    program        => 'FTE_TRIP_RERATE',
			    description    => NULL,
			    start_time     => NULL,
			    sub_request    => FALSE,
			    argument1      => trips_rec.trip_id,
			    argument2      => trips_rec.name
			  );
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'l_requestId',l_requestId);
                        END IF;
                        --
			IF l_requestId <> 0
			THEN
			--{
			    IF l_requestIdList IS NULL
			    THEN
			        l_requestIdList := l_requestId;
			    ELSE
			        l_requestIdList := SUBSTRB
						     (
						       l_requestIdList
						       || ','
						       || l_requestId,
						       1,1800);
			    END IF;
			--}
			ELSE
			--{
                            FND_MESSAGE.SET_NAME('WSH', 'WSH_IB_RATE_TRIP_ERROR');
                            FND_MESSAGE.SET_TOKEN('TRIP_NAME',trips_rec.name);
                            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
			--}
			END IF;
		    --}
                    END IF;
		    --
		    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.get_Cached_value',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_UTIL_CORE.get_Cached_value
                        (
                            p_cache_tbl         => l_trip_tbl,
                            p_cache_ext_tbl     => l_trip_ext_tbl,
                            p_key               => trips_rec.trip_id,
                            p_value             => trips_rec.trip_id,
                            p_action            => 'PUT',
                            x_return_status     => l_return_status
                        );
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
		    END IF;
                    --
                    WSH_UTIL_CORE.api_post_call
                      (
                          p_return_status => l_return_status,
                          x_num_warnings  => l_num_warnings,
                          x_num_errors    => l_num_errors
                      );
                --}
                END IF;
            --}
            END LOOP;
            --
            l_index := p_delivery_id_tab.NEXT(l_index);
        --}
        END LOOP;
	--
	--
	IF l_requestIdList IS NOT NULL
	THEN
	--{
            FND_MESSAGE.SET_NAME('WSH', 'WSH_IB_RATE_TRIP_MESSAGE');
            FND_MESSAGE.SET_TOKEN('REQ_IDS',l_requestIdList);
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_SUCCESS,l_module_name);
	--}
	END IF;
    --}
    --
    ELSE -- IF WSH_INBOUND_UTIL_PKG.G_ASN_RECEIPT_MATCH_TYPE = 'AUTO'
    --{
        l_index := p_delivery_id_tab.FIRST;
        --
        WHILE l_index IS NOT NULL
        LOOP
        --{
            FOR trips_rec IN trips_csr(p_delivery_id_tab(l_index))
            LOOP
            --{
                IF trips_Rec.reprice_required = 'Y'
                THEN
                --{

		    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.get_Cached_value',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    WSH_UTIL_CORE.get_Cached_value
                        (
                            p_cache_tbl         => l_trip_tbl,
                            p_cache_ext_tbl     => l_trip_ext_tbl,
                            p_key               => trips_rec.trip_id,
                            p_value             => trips_rec.trip_id,
                            p_action            => 'GET',
                            x_return_status     => l_return_status
                        );
  		    --
                    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                    THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
                    THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
                    THEN
		    --{
                        l_action_params.trip_id_list(l_action_params.trip_id_list.count + 1) := trips_rec.trip_id;

 	   	        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.get_Cached_value',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        WSH_UTIL_CORE.get_Cached_value
                            (
                                p_cache_tbl         => l_trip_tbl,
                                p_cache_ext_tbl     => l_trip_ext_tbl,
                                p_key               => trips_rec.trip_id,
                                p_value             => trips_rec.trip_id,
                                p_action            => 'PUT',
                                x_return_status     => l_return_status
                            );
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        wsh_util_core.api_post_call
                          (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                          );
                    --}
		    END IF;
                --}
	        END IF;
            --}
            END LOOP;
            --
            l_index := p_delivery_id_tab.NEXT(l_index);
        --}
        END LOOP;
	--
	--
        --}
        l_action_params.caller :='WSH';
        l_action_params.event  :='RE-RATING';
        l_action_params.action :='RATE';

        IF l_action_params.trip_id_list.count > 0
	THEN
        --{
            SAVEPOINT handle_rate_fail_sp; -- bugfix 4535358
            IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_TRIP_RATING_GRP.Rate_Trip',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            --
            FTE_TRIP_RATING_GRP.Rate_Trip (
                 p_api_version              => 1.0,
                 p_init_msg_list            => FND_API.G_FALSE,
                 p_action_params            => l_action_params,
                 p_commit                   => FND_API.G_FALSE,
		 p_init_prc_log	            => 'Y',
                 x_return_status            => l_return_status,
                 x_msg_count                => l_msg_count,
                 x_msg_data                 => l_msg_data);

            IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

	    --bugfix 4535358
	    --{
	    IF 	l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
	    THEN
	      IF l_debug_on THEN
	        wsh_debug_sv.logmsg(l_module_name, 'Rating has failed');
              END IF;
	      --Even if Rating fails for any Reason, IB will proceed with auto-matching of Receipt by
	      --reverting to the State before Rating was initiated.
	      ROLLBACK TO  handle_rate_fail_sp;
	      --
	    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
	    THEN
	      l_num_warnings := l_num_warnings + 1;
	    END IF;
	    --}
	--}
        END IF;

    END IF;
    --
    WSH_INBOUND_UTIL_PKG.G_ASN_RECEIPT_MATCH_TYPE := null;
    -- } IB-Phase-2
   --
   IF l_num_errors > 0
   THEN
        x_return_status         := WSH_UTIL_CORE.G_RET_STS_ERROR;
   ELSIF l_num_warnings > 0
   THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
            x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;
   --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
--}
EXCEPTION
--{
      --
    WHEN FND_API.G_EXC_ERROR THEN

      --ROLLBACK TO open_stop_begin_sp;
      --
      WSH_INBOUND_UTIL_PKG.G_ASN_RECEIPT_MATCH_TYPE := null;   -- IB-Phase-2
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      --ROLLBACK TO open_stop_begin_sp;
      --
      WSH_INBOUND_UTIL_PKG.G_ASN_RECEIPT_MATCH_TYPE := null;   -- IB-Phase-2
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      WSH_INBOUND_UTIL_PKG.G_ASN_RECEIPT_MATCH_TYPE := null;   -- IB-Phase-2
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
    WHEN others THEN
        wsh_util_core.default_handler('WSH_INBOUND_UTIL_PKG.reRateDeliveries',l_module_name);
        --
        --ROLLBACK TO open_stop_begin_sp;
        --
        WSH_INBOUND_UTIL_PKG.G_ASN_RECEIPT_MATCH_TYPE := null;   -- IB-Phase-2
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
--}
END reRateDeliveries;

PROCEDURE processStop
    (
        p_stop_id               IN          NUMBER,
        p_status_code           IN          VARCHAR2,
        p_shipements_type_flag  IN          VARCHAR2,
        p_action_code           IN          VARCHAR2 DEFAULT 'APPLY',
        x_processed             OUT NOCOPY  VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2
    )
IS
--{
    l_return_status         VARCHAR2(1);
    l_num_warnings          NUMBER;
    l_num_errors            NUMBER;
    l_message_name          VARCHAR2(50);
    --
    --
    CURSOR linked_stop_csr (p_stop_id IN NUMBER)
    IS
      SELECT 1
      FROM   wsh_trip_stops wts1,
             wsh_trip_stops wts2
      WHERE  wts2.stop_id          = p_stop_id
      AND    wts2.trip_id          = wts1.trip_id
      AND    wts1.physical_stop_id = p_stop_id
      AND    wts1.status_code IN ('OP','AR')
      AND    NVL(wts1.shipments_type_flag,'O') IN ('M','O');
    --
    --
    l_dummy                 NUMBER;
    l_stop_id               NUMBER;
    l_stop_in_rec           WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type;
    --
    l_debug_on              BOOLEAN;
    l_reopen_flag           BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'processStop';
    --
--}
BEGIN
--{
    --SAVEPOINT open_stop_begin_sp;
    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'p_stop_id',p_stop_id);
       WSH_DEBUG_SV.log(l_module_name,'p_status_code',p_status_code);
       WSH_DEBUG_SV.log(l_module_name,'p_shipements_type_flag',p_shipements_type_flag);
       WSH_DEBUG_SV.log(l_module_name,'p_action_code',p_action_code);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    --
    l_num_warnings  := 0;
    l_num_errors    := 0;
    --
    --
    x_processed := 'N';
    l_stop_id   := NULL;
    l_dummy     := NULL;
    --
    --
    IF p_action_code = 'APPLY'
    THEN
    --{
        l_reopen_flag := FALSE;
        --
        IF  p_shipements_type_flag = 'I'
        THEN
            IF p_status_code = 'CL'
            THEN
                x_processed := 'Y';
            ELSE
            --{
                OPEN linked_stop_csr(p_stop_id => p_stop_id);
                FETCH linked_stop_csr INTO l_dummy;
                CLOSE linked_stop_csr;
                --
                IF l_dummy IS NULL
                THEN
                    l_stop_id := p_stop_id;
                END IF;
            --}
            END IF;
        ELSE --- 'M'
            IF p_status_code = 'CL'
            THEN
                x_processed := 'Y';
            END IF;
        END IF;
    --}
    ELSE
    --{
        l_reopen_flag := TRUE;
        --
        IF  p_shipements_type_flag = 'I'
        THEN
            IF p_status_code = 'CL'
            THEN
            --{
                OPEN linked_stop_csr(p_stop_id => p_stop_id);
                FETCH linked_stop_csr INTO l_dummy;
                CLOSE linked_stop_csr;
                --
                IF l_dummy IS NULL
                THEN
                    l_stop_id := p_stop_id;
                ELSE
                    x_processed := 'Y';
                END IF;
            --}
            ELSE
                x_processed := 'Y';
            END IF;
        ELSE --- 'M'
           x_processed := 'Y';
        END IF;
    --}
    END IF;
    --
    --
    IF l_stop_id IS NOT NULL
    THEN
    --{
        l_stop_in_rec.stop_id      := l_stop_id;
        l_stop_in_rec.put_messages := FALSE;
        l_stop_in_rec.caller       := l_module_name;
        l_stop_in_rec.actual_date  := SYSDATE;
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_ACTIONS.autoCLOSE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_TRIP_STOPS_ACTIONS.autoCloseOpen
            (
                p_in_rec                => l_stop_in_rec,
                p_reopenStop            => l_reopen_flag,
                x_stop_processed        => x_processed,
                x_return_status         => l_return_status
            );
        --
        WSH_UTIL_CORE.api_post_call
            (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
            );
        --
        IF p_action_code = 'CANCEL'
        THEN
            x_processed := 'Y';
        END IF;
    --}
    END IF;
    --
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                            'Number of Errors='||l_num_errors||',Number of Warnings='||l_num_warnings);
    END IF;
   --
   IF l_num_errors > 0
   THEN
        x_return_status         := WSH_UTIL_CORE.G_RET_STS_ERROR;
   ELSIF l_num_warnings > 0
   THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
            x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;
   --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
--}
EXCEPTION
--{
      --
    WHEN FND_API.G_EXC_ERROR THEN

      --ROLLBACK TO open_stop_begin_sp;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      --ROLLBACK TO open_stop_begin_sp;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
    WHEN others THEN
        wsh_util_core.default_handler('WSH_INBOUND_UTIL_PKG.processStop',l_module_name);
        --
        --ROLLBACK TO open_stop_begin_sp;
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
--}
END processStop;

PROCEDURE setTripStopStatus
    (
        p_transaction_code    IN          VARCHAR2 DEFAULT 'RECEIPT',
        p_action_code         IN          VARCHAR2 DEFAULT 'APPLY',
        p_delivery_id_tab     IN          wsh_util_core.id_tab_type,
        x_return_status       OUT NOCOPY  VARCHAR2
    )
IS
--{

    CURSOR first_leg_csr (p_delivery_id IN NUMBER) IS
    SELECT  wnd.name delivery_name,
            wnd.status_code delivery_statusCode,
            wnd.ultimate_dropoff_location_id,
            wnd.asn_shipment_header_id,
            wnd.rcv_shipment_header_id,
            pu_stop.stop_id pu_stop_id,
            pu_Stop.status_code pu_stop_statusCode,
            NVL(pu_stop.shipments_type_flag,'O') pu_stop_shipTypeFlag,
            do_stop.stop_id do_stop_id,
            do_stop.stop_location_id do_stop_locationId,
            do_Stop.status_code do_stop_statusCode,
            NVL(do_stop.shipments_type_flag,'O') do_stop_shipTypeFlag,
            pu_stop.trip_id trip_id
    FROM    wsh_trip_stops pu_stop,
            wsh_trip_stops do_stop,
            wsh_delivery_legs wdl,
            wsh_new_deliveries wnd
    WHERE   wnd.delivery_id                      = p_delivery_id
    AND     wdl.delivery_id                      = wnd.delivery_id
    AND     NVL(wnd.shipment_direction,'O') NOT IN ('O','IO')
    AND     wdl.pick_up_stop_id                  = pu_stop.stop_id
    AND     wnd.initial_pickup_location_id       = pu_stop.stop_location_id
    AND     wdl.drop_off_stop_id                 = do_stop.stop_id;
    --
    CURSOR next_leg_csr (p_stop_id IN NUMBER, p_delivery_id IN NUMBER) IS
    SELECT next_leg_do_stop.status_code                  do_stop_statusCode,
           NVL(next_leg_do_stop.shipments_type_flag,'O') do_stop_shipTypeFlag,
           next_leg_do_stop.stop_location_id             do_stop_locationId,
           next_leg_do_stop.stop_id                      do_stop_id,
           next_leg_pu_stop.status_code                  pu_stop_statusCode,
           NVL(next_leg_pu_stop.shipments_type_flag,'O') pu_stop_shipTypeFlag,
           next_leg_pu_stop.stop_location_id             pu_stop_locationId,
           next_leg_pu_stop.stop_id                      pu_stop_id,
           NVL(wnd.shipment_direction,'O')               shipment_direction,
           wnd.status_code                               dlvy_status_code,
           wnd.ultimatE_dropoff_location_id              dlvy_ultimate_doLocationId,
           next_leg_pu_stop.trip_id                      trip_id --3410681
    FROM   wsh_trip_stops next_leg_do_stop,
           wsh_trip_stops next_leg_pu_stop,
           wsh_trip_stops curr_leg_do_stop,
           wsh_delivery_legs next_leg,
           wsh_delivery_legs curr_leg,
           wsh_new_deliveries wnd
    WHERE  next_leg.drop_off_stop_id         = next_leg_do_stop.stop_id
    --AND    st1.status_code = 'OP'
    AND    next_leg.pick_up_stop_id          = next_leg_pu_stop.stop_id
    AND    next_leg_pu_stop.stop_location_id = curr_leg_do_stop.stop_location_id
    AND    next_leg.delivery_id              = curr_leg.delivery_id
    AND    curr_leg_do_stop.stop_id          = p_stop_id
    AND    curr_leg.drop_off_stop_id         = p_stop_id
    AND    wnd.delivery_id                   = curr_leg.delivery_id
    AND    wnd.delivery_id                   = p_delivery_id;
    --AND    NVL(wnd.shipment_direction,'O') NOT IN ('O','IO')
    --
    --
    CURSOR dlvy_csr (p_delivery_id IN NUMBER)
    IS
        SELECT NVL(wnd.planned_flag,'N') planned_flag,
	       NVL(ignore_for_planning,'N') ignore_for_planning
        FROM   wsh_new_deliveries wnd
        WHERE  wnd.delivery_id     = p_delivery_id;
    --


    --Bug 3410681 fixed.
    --Cursor to find any stops not closed for a trip.
    CURSOR stop_csr (p_trip_id IN NUMBER) IS
      SELECT  count(stop_id)
       FROM   wsh_trip_stops
       WHERE  trip_id      = p_trip_id
       AND    status_code <> 'CL';

    l_trip_tbl              wsh_util_core.key_value_tab_type;
    l_trip_ext_tbl          wsh_util_core.key_value_tab_type;
    l_stop_count	    number := 0;
    --Bug 3410681 fixed.

    --
    l_return_status         VARCHAR2(1);
    l_num_warnings          NUMBER;
    l_num_errors            NUMBER;
    l_message_name          VARCHAR2(50);
    --
    --
    l_reopen_flag           BOOLEAN := FALSE;
    l_stop_id               NUMBER;
    l_next_stop_id          NUMBER;
    l_stop_locationId       NUMBER;
    l_index                 NUMBER;
    --
    --
    l_count                 NUMBER := 0;
    l_dlvy_tbl              wsh_util_core.id_tab_type;
    --
    l_trip_Status_code      VARCHAR2(30);
    l_stop_processed        VARCHAR2(10);
    l_allowed               VARCHAR2(10);
    --
    --l_trip_in_rec           WSH_TRIP_VALIDATIONS.ChgStatus_in_rec_type;
    l_stop_in_rec           WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type;


    --
    l_debug_on              BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'setTripStopStatus';
    --
--}
BEGIN
--{
    --SAVEPOINT open_stop_begin_sp;
    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'p_transaction_code',p_transaction_code);
       WSH_DEBUG_SV.log(l_module_name,'p_action_code',p_action_code);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    --
    l_num_warnings  := 0;
    l_num_errors    := 0;
    --
    --
    IF p_action_code = 'APPLY'
    THEN
        l_reopen_flag := FALSE;
    ELSE
        l_reopen_flag := TRUE;
    END IF;
    --
    l_index := p_delivery_id_tab.FIRST;
    --
    WHILE l_index IS NOT NULL
    LOOP
    --{
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_index',l_index);
            WSH_DEBUG_SV.log(l_module_name,'p_delivery_id_tab(l_index)',p_delivery_id_tab(l_index));
        END IF;
        --
								<<first_leg_loop>>
        FOR first_leg_rec IN first_leg_csr(p_delivery_id_tab(l_index))
        LOOP
        --{
            l_stop_id      := NULL;
            l_message_name := NULL;
            --

            --Bug 3410681 fixed
            wsh_util_core.get_cached_value (
              p_cache_tbl         => l_trip_tbl,
              p_cache_ext_tbl     => l_trip_ext_tbl,
              p_key               => first_leg_rec.trip_id,
              p_value             => first_leg_rec.trip_id,
              p_action            => 'PUT',
              x_return_status     => l_return_status);

            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'wsh_util_core.get_cached_value l_return_status',l_return_status);
                WSH_DEBUG_SV.log(l_module_name,'l_trip_tbl.count',l_trip_tbl.count);
            END IF;

            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --Bug 3410681 fixed

            IF p_transaction_code = 'ASN'
            THEN
            --{
                IF  p_action_code = 'APPLY'
                AND first_leg_rec.delivery_statusCode <> 'IT'
                THEN
                    l_message_name := 'WSH_DLVY_IT_ERROR';
                END IF;
                --
                IF  p_action_code = 'CANCEL'
                AND first_leg_rec.delivery_statusCode <> 'OP'
                THEN
                    l_message_name := 'WSH_DLVY_OP_ERROR';
                END IF;
                --
                IF l_message_name IS NOT NULL
                THEN
                --{
                    FND_MESSAGE.SET_NAME('WSH', l_message_name);
                    FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',first_leg_rec.delivery_name);
                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                    RAISE FND_API.G_EXC_ERROR;
                --}
                END IF;
            --}
            ELSIF p_transaction_code = 'RECEIPT'
            THEN
            --{
                IF  p_action_code = 'APPLY'
                AND first_leg_rec.delivery_statusCode <> 'CL'
                THEN
                    l_message_name := 'WSH_DLVY_CL_ERROR';
                END IF;
                --
                IF  p_action_code = 'CANCEL'
                THEN
                    IF first_leg_rec.asn_shipment_header_id IS NULL
                    THEN
                        IF first_leg_rec.delivery_statusCode  <> 'OP'
                        THEN
                            l_message_name := 'WSH_DLVY_OP_ERROR';
                        END IF;
                    ELSE
                        IF first_leg_rec.delivery_statusCode  <> 'IT'
                        THEN
                            l_message_name := 'WSH_DLVY_IT_ERROR';
                        END IF;
                    END IF;
                END IF;
                --
                IF l_message_name IS NOT NULL
                THEN
                --{
                    FND_MESSAGE.SET_NAME('WSH', l_message_name);
                    FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',first_leg_rec.delivery_name);
                    wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
                    RAISE FND_API.G_EXC_ERROR;
                --}
                END IF;
            --}
            END IF;
            --
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.processStop',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            --
            WSH_INBOUND_UTIL_PKG.processStop
              (
                p_stop_id               => first_leg_rec.pu_stop_id,
                p_status_code           => first_leg_rec.pu_stop_statusCode,
                p_shipements_type_flag  => first_leg_rec.pu_stop_shipTypeFlag,
                p_action_code           => p_action_code,
                x_processed             => l_stop_processed,
                x_return_status         => l_return_status
              );
            --
            --
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.log(l_module_name,'l_stop_processed',l_stop_processed);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_util_core.api_post_call',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
            --
            IF p_transaction_code = 'ASN'
            OR l_stop_processed   = 'N'
            THEN
                EXIT;
            END IF;
            --
            --
            IF l_stop_processed = 'Y'
            THEN
            --{
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.processStop',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                --
                WSH_INBOUND_UTIL_PKG.processStop
                  (
                    p_stop_id               => first_leg_rec.do_stop_id,
                    p_status_code           => first_leg_rec.do_stop_statusCode,
                    p_shipements_type_flag  => first_leg_rec.do_stop_shipTypeFlag,
                    p_action_code           => p_action_code,
                    x_processed             => l_stop_processed,
                    x_return_status         => l_return_status
                  );
                --
                --
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                    WSH_DEBUG_SV.log(l_module_name,'l_stop_processed',l_stop_processed);
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_util_core.api_post_call',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                wsh_util_core.api_post_call
                  (
                    p_return_status => l_return_status,
                    x_num_warnings  => l_num_warnings,
                    x_num_errors    => l_num_errors
                  );
                --
                IF l_stop_processed   = 'N'
                THEN
                    EXIT;
                END IF;
                --
                --
                l_stop_locationId := first_leg_rec.do_stop_locationId;
                l_next_stop_Id    := first_leg_rec.do_stop_id;
                --
                WHILE l_stop_locationId <> first_leg_rec.ultimate_dropoff_location_id
                --AND   l_stop_id         IS NULL
                LOOP
                --{
                    FOR next_leg_rec IN next_leg_csr(l_next_stop_id, p_delivery_id_tab(l_index))
                    LOOP
                    --{

                        --Bug 3410681 fixed
                        wsh_util_core.get_cached_value (
                          p_cache_tbl         => l_trip_tbl,
                          p_cache_ext_tbl     => l_trip_ext_tbl,
                          p_key               => next_leg_rec.trip_id,
                          p_value             => next_leg_rec.trip_id,
                          p_action            => 'PUT',
                          x_return_status     => l_return_status);

                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'wsh_util_core.get_cached_value l_return_status',l_return_status);
                            WSH_DEBUG_SV.log(l_module_name,'l_trip_tbl.count',l_trip_tbl.count);
                        END IF;

                        wsh_util_core.api_post_call (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors);

                        --Bug 3410681 fixed

                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.processStop',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        --
                        WSH_INBOUND_UTIL_PKG.processStop
                          (
                            p_stop_id               => next_leg_rec.pu_stop_id,
                            p_status_code           => next_leg_rec.pu_stop_statusCode,
                            p_shipements_type_flag  => next_leg_rec.pu_stop_shipTypeFlag,
                            p_action_code           => p_action_code,
                            x_processed             => l_stop_processed,
                            x_return_status         => l_return_status
                          );
                        --
                        --
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                            WSH_DEBUG_SV.log(l_module_name,'l_stop_processed',l_stop_processed);
                            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_util_core.api_post_call',WSH_DEBUG_SV.C_PROC_LEVEL);
                        END IF;
                        --
                        wsh_util_core.api_post_call
                          (
                            p_return_status => l_return_status,
                            x_num_warnings  => l_num_warnings,
                            x_num_errors    => l_num_errors
                          );
                        --
                        IF l_stop_processed   = 'N'
                        THEN
                            EXIT first_leg_loop;
                        END IF;
                        --
                        --
                        IF l_stop_processed = 'Y'
                        THEN
                        --{
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.processStop',WSH_DEBUG_SV.C_PROC_LEVEL);
                            END IF;
                            --
                            --
                            WSH_INBOUND_UTIL_PKG.processStop
                              (
                                p_stop_id               => next_leg_rec.do_stop_id,
                                p_status_code           => next_leg_rec.do_stop_statusCode,
                                p_shipements_type_flag  => next_leg_rec.do_stop_shipTypeFlag,
                                p_action_code           => p_action_code,
                                x_processed             => l_stop_processed,
                                x_return_status         => l_return_status
                              );
                            --
                            --
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                                WSH_DEBUG_SV.log(l_module_name,'l_stop_processed',l_stop_processed);
                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_util_core.api_post_call',WSH_DEBUG_SV.C_PROC_LEVEL);
                            END IF;
                            --
                            wsh_util_core.api_post_call
                              (
                                p_return_status => l_return_status,
                                x_num_warnings  => l_num_warnings,
                                x_num_errors    => l_num_errors
                              );
                            --
                            IF l_stop_processed   = 'N'
                            THEN
                                EXIT first_leg_loop;
                            END IF;
                        --}
                        END IF;
                        --
                        --
                        l_stop_locationId := next_leg_rec.do_stop_locationId;
                        l_next_stop_Id    := next_leg_rec.do_stop_id;
                    --}
                    END LOOP;
                --}
                END LOOP;
            --}
            END IF;
        --}
        END LOOP;
        --
        l_index := p_delivery_id_tab.NEXT(l_index);
    --}
    END LOOP;
    --
    --
    IF p_action_code = 'APPLY'
    THEN
    --{
        l_index := p_delivery_id_tab.FIRST;
	l_count := 0;
        --
        WHILE l_index IS NOT NULL
        LOOP
        --{
            FOR dlvy_rec IN dlvy_csr(p_delivery_id_tab(l_index))
            LOOP
            --{
                IF l_debug_on THEN
                   WSH_DEBUG_SV.log(l_module_name,'Delivery Id',p_delivery_id_tab(l_index));
                   WSH_DEBUG_SV.log(l_module_name,'dlvy_rec.planned_flag',dlvy_rec.planned_flag);
                   WSH_DEBUG_SV.log(l_module_name,'dlvy_rec.ignore_for_planning',dlvy_rec.ignore_for_planning);
                END IF;
                --
                --
                IF  dlvy_rec.planned_flag <> 'F'
		AND dlvy_rec.ignore_for_planning = 'N'
                THEN
                --{
		    IF dlvy_rec.planned_flag <> 'Y'
		    THEN
		        l_count             := l_count + 1;
		        l_dlvy_tbl(l_count) := p_delivery_id_tab(l_index);
		    END IF;
                --}
                END IF;
            --}
            END LOOP;
            --
            l_index := p_delivery_id_tab.NEXT(l_index);
        --}
        END LOOP;
	--
        --
	IF l_count > 0
	THEN
	--{
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_count',l_count);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.Plan',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            --
            WSH_NEW_DELIVERY_ACTIONS.Plan
              (
                p_del_rows      => l_dlvy_tbl,
                x_return_status => l_return_status

              );
            --
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            --
            wsh_util_core.api_post_call
              (
                p_return_status => l_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors
              );
	--}
	END IF;
        --
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.reRateDeliveries',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        --
        WSH_INBOUND_UTIL_PKG.reRateDeliveries
            (
                p_delivery_id_tab     => p_delivery_id_tab,
                x_return_status       => l_return_status
            );
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
    --}
    END IF;

    --Bug 3410681 fixed.
    --Give a warning, if trip has any not closed stop associate to it.
    IF (p_action_code = 'APPLY' AND  p_transaction_code = 'RECEIPT') THEN
    --{

       --Check for any stops not closed for trip.
       l_index := l_trip_tbl.FIRST;
       WHILE (l_index IS NOT NULL) LOOP

          OPEN stop_csr(l_index);
          FETCH stop_csr INTO l_stop_count;

          IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'trip_id',l_index);
               WSH_DEBUG_SV.log(l_module_name,'l_stop_count',l_stop_count);
          END IF;

          IF (l_stop_count > 0) THEN
              FND_MESSAGE.SET_NAME('WSH', 'WSH_IB_TRIP_NOT_CLOSE');
              FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(l_index));
              wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);

             l_num_warnings := l_num_warnings + 1;
             l_stop_count := 0;
          END IF;
          CLOSE stop_csr;

       l_index := l_trip_tbl.NEXT(l_index);
       END LOOP;

       l_index := l_trip_ext_tbl.FIRST;
       WHILE (l_index IS NOT NULL) LOOP

          OPEN stop_csr(l_index);
          FETCH stop_csr INTO l_stop_count;
          IF (l_stop_count > 0) THEN
              FND_MESSAGE.SET_NAME('WSH', 'WSH_TRIP_NOT_CLOSE');
              FND_MESSAGE.SET_TOKEN('TRIP_NAME',wsh_trips_pvt.get_name(l_index));
              wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
             l_num_warnings := l_num_warnings + 1;
             l_stop_count := 0;
          END IF;
          CLOSE stop_csr;

       l_index := l_trip_ext_tbl.NEXT(l_index);
       END LOOP;
    --}
    END IF;
    --Bug 3410681 fixed.

    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                            'Number of Errors='||l_num_errors||',Number of Warnings='||l_num_warnings);
    END IF;
   --
   IF l_num_errors > 0
   THEN
        x_return_status         := WSH_UTIL_CORE.G_RET_STS_ERROR;
   ELSIF l_num_warnings > 0
   THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
            x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;
   --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
--}
EXCEPTION
--{
      --
    WHEN FND_API.G_EXC_ERROR THEN

      --ROLLBACK TO open_stop_begin_sp;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      --ROLLBACK TO open_stop_begin_sp;
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
    WHEN others THEN
        wsh_util_core.default_handler('WSH_INBOUND_UTIL_PKG.setTripStopStatus',l_module_name);
        --
        --ROLLBACK TO open_stop_begin_sp;
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
--}
END setTripStopStatus;

-- Start of comments
-- API name : CONVERT_QUANTITY
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API is used to convert the quantity of an item
--             from one UOM code to another,Like 'DOZ' to 'EA'.
-- Parameters :
-- IN:
--		 p_inv_item_id		IN  NUMBER DEFAULT NULL
--                  The inventory item ID for which the conversion is done.
--		 p_organization_id	IN  NUMBER
--                  The organization of the Item.
--		 p_quantity		IN  NUMBER
--                  p_quantity is the quantity to be converted.
--		 p_qty_uom_code		IN  VARCHAR2
--		    p_qty_uom_code is the code which represents the curent uom code
--                  of the input p_quantity.
-- IN OUT:
--		 p_primary_uom_code	IN  OUT NOCOPY VARCHAR2
--                  p_primary_uom_code is the uom code into which the quantity has to be
--                  converted.
-- OUT:
--		 x_conv_qty		OUT NOCOPY NUMBER
--                  x_conv_qty will have the converted quantity in case of successfull
--	            conversion.
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

PROCEDURE  convert_quantity
( p_inv_item_id IN NUMBER DEFAULT NULL,
  p_organization_id IN NUMBER,
  p_primary_uom_code IN OUT NOCOPY VARCHAR2,
  p_quantity IN  NUMBER ,
  p_qty_uom_code  IN  VARCHAR2,
  x_conv_qty  OUT NOCOPY NUMBER,
  x_return_status IN OUT NOCOPY VARCHAR2
) IS

--To get Primary UOM code for the given inventory item.
CURSOR c_inventory_item_info(v_inventory_item_id number,
                                v_organization_id number) is
SELECT  primary_uom_code
FROM    mtl_system_items
WHERE   inventory_item_id = v_inventory_item_id
AND     organization_id  = v_organization_id;

l_return_status VARCHAR2(1);
l_is_org_type_opm VARCHAR2(1) := FND_API.G_FALSE;
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONVERT_QUANTITY';

BEGIN


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_inv_item_id',p_inv_item_id);
    WSH_DEBUG_SV.log(l_module_name,'p_organization_id',p_organization_id);
    WSH_DEBUG_SV.log(l_module_name,'p_primary_uom_code',p_primary_uom_code);
    WSH_DEBUG_SV.log(l_module_name,'p_quantity',p_quantity);
    WSH_DEBUG_SV.log(l_module_name,'p_qty_uom_code',p_qty_uom_code);
END IF;
--


x_return_status :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--assigning  p_quanity to x_conv quantity
x_conv_qty := p_quantity;

--The Items primary UOM and Current UOM are not NULL.
IF( (p_primary_uom_code IS NOT NULL) AND (p_qty_uom_code IS NOT NULL) )THEN
  -- If the UOM to be converted is same as the primary UOM.
  IF  p_primary_uom_code = p_qty_uom_code THEN

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
  END IF;
END IF;

--If the primary UOM is not passed to this API.Then find it in mtl_system_items table.
IF (p_inv_item_id IS NOT NULL ) AND (p_primary_uom_code IS NULL) THEN
  OPEN  c_inventory_item_info(p_inv_item_id,p_organization_id);
  FETCH c_inventory_item_info INTO p_primary_uom_code;
  CLOSE c_inventory_item_info;
END IF;

--If the UOMs (Primary Vs Current) are different then do a conversion

  --If the i/p inventory ID is null
-- HW OPMCONV - Removed code forking
-- New condition is the OR condition
  IF (p_inv_item_id IS NULL
      OR p_primary_uom_code <> p_qty_uom_code)  THEN
    --Call function WSH_WV_UTILS.CONVERT_UOM which returns the converted quantity.
    x_conv_qty := wsh_wv_utils.convert_uom(
        from_uom => p_qty_uom_code,
        to_uom   => p_primary_uom_code,
        quantity => p_quantity,
        item_id  => p_inv_item_id,
        p_max_decimal_digits => WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS);-- RV DEC_QTY


 -- HW OPMCONV - Removed code forking

  END IF;

--}

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_INBOUND_UTIL_PKG.convert_quantity',l_module_name);
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END convert_quantity;

-- Start of comments
-- API name : GET_OUTERMOST_LPN
-- Type     : Public
-- Pre-reqs : None.
-- Function :  This API is used to determine the outermost LPN id for
--             a given LPN id.
--             The input p_lpn_context should be equal to 7 in the case of
--	       ASN/RECEIPT.
--             If the outermost lpn id is found for the given lpn then
--             it is set in th variable x_outermost_lpn.
--             If the outermost lpn id is not found for the given lpn then
--             NULL is set to the variable x_outermost_lpn.
-- Parameters :
-- IN:
--		p_lpn_id		  IN NUMBER
--                The lpn_id for which the outermost LPN has to be found.
--		p_shipment_header_id	  IN NUMBER
--                The shipment header ID of the given i/p LPN ID.
--		p_lpn_context		  IN NUMBER
--
-- IN OUT:
--
-- OUT:
--		x_outermost_lpn	OUT NOCOPY NUMBER
--                The outermost LPN ID derived for the i/p LPN ID.
--		x_outermost_lpn_name  OUT NOCOPY VARCHAR2
--                The outermost LPNs name.
--		x_return_status	OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

PROCEDURE GET_OUTERMOST_LPN(
  p_lpn_id IN NUMBER,
  p_shipment_header_id IN NUMBER,
  p_lpn_context IN NUMBER,
  x_outermost_lpn OUT NOCOPY NUMBER,
  x_outermost_lpn_name OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2)
IS

--Cursor to get the outermost LPN for a given LPN.
CURSOR get_outer_most_lpn_id(p_lpn_id NUMBER,
             p_shipment_header_id NUMBER,
           p_lpn_context  NUMBER)
IS
select
--lpn_id
parent_lpn_id,
parent_license_plate_number
from
wms_lpn_histories
where
--parent_lpn_id  is null and
source_header_id = p_shipment_header_id
and source_type_id   = 1
and lpn_context = p_lpn_context
start with parent_lpn_id = p_lpn_id
connect by prior parent_lpn_id = lpn_id;


l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_OUTERMOST_LPN';


l_debug_on BOOLEAN;

BEGIN

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_lpn_id',p_lpn_id);
    WSH_DEBUG_SV.log(l_module_name,'p_shipment_header_id',p_shipment_header_id);
    WSH_DEBUG_SV.log(l_module_name,'p_lpn_context',p_lpn_context);
END IF;
--


x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
x_outermost_lpn := NULL;
x_outermost_lpn_name := NULL;

--The loop goes up by one LPN level(Parent LPN) for the given i/p LPN, during each iteration of the loop.
FOR get_outer_most_lpn_id_rec IN  get_outer_most_lpn_id(p_lpn_id ,
                   p_shipment_header_id ,
               p_lpn_context )
LOOP

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'get_outer_most_lpn_id_rec.parent_lpn_id',get_outer_most_lpn_id_rec.parent_lpn_id);
        WSH_DEBUG_SV.log(l_module_name,'get_outer_most_lpn_id_rec.parent_license_plate_number',get_outer_most_lpn_id_rec.parent_license_plate_number);
    END IF;
    x_outermost_lpn := get_outer_most_lpn_id_rec.parent_lpn_id;
    x_outermost_lpn_name := get_outer_most_lpn_id_rec.parent_license_plate_number;

END LOOP;
/*
FETCH get_outer_most_lpn_id INTO x_outermost_lpn;
CLOSE get_outer_most_lpn_id;

IF x_outermost_lpn IS NULL THEN
  x_outermost_lpn := p_lpn_id;
END IF;
*/

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_INBOUND_UTIL_PKG.GET_OUTERMOST_LPN',l_module_name);
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END GET_OUTERMOST_LPN;


--HACMS {
FUNCTION Is_Routing_Response_Send(p_delivery_detail_id  NUMBER,
                      x_routing_response_id OUT NOCOPY NUMBER) RETURN boolean
IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Is_Routing_Response_Send';

CURSOR get_routing_response IS
SELECT wnd.routing_response_id
FROM   wsh_new_deliveries wnd,
       wsh_delivery_assignments_v wda
WHERE  wnd.delivery_id = wda.delivery_id
AND    wda.delivery_detail_id = p_delivery_detail_id
AND    wnd.routing_response_id IS NOT NULL;

l_status  boolean:=false;
BEGIN
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_delivery_detail_id',p_delivery_detail_id);
 END IF;

 OPEN get_routing_response;
 FETCH get_routing_response INTO x_routing_response_id;
 IF (get_routing_response%FOUND) THEN
   l_status:=true;
 END IF;
 CLOSE get_routing_response;

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_routing_response_id',x_routing_response_id);
    WSH_DEBUG_SV.pop(l_module_name);
 END IF;

 RETURN l_status;

EXCEPTION
 WHEN OTHERS THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                                     SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    RETURN false;
END Is_Routing_Response_Send;
--HACMS }

END WSH_INBOUND_UTIL_PKG;

/
