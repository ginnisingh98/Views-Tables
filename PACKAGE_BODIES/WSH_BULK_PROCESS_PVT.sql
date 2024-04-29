--------------------------------------------------------
--  DDL for Package Body WSH_BULK_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_BULK_PROCESS_PVT" as
/* $Header: WSHBLPRB.pls 120.3.12000000.5 2007/01/23 19:27:27 rvishnuv ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_BULK_PROCESS_PVT';
l_vendor_party_id NUMBER;


--========================================================================
-- PROCEDURE : clear_wsh_prev_tabs
--
-- PARAMETERS:
--             p_line_rec
--             x_return_status         return status
-- COMMENT   : If OM calls Create_delivery_details several time in one session
--             this procedure will clear the previously populated tables.
--             Delete operation is not used to avoid extending performance
--             issues.
--========================================================================
PROCEDURE  clear_wsh_prev_tabs(
                    p_line_rec      IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
                    x_return_status OUT NOCOPY VARCHAR2)
IS
    l_debug_on BOOLEAN;
    --
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
               '.' || 'clear_wsh_prev_tabs';
    i    NUMBER;
    l_debug_num NUMBER := 0;

BEGIN
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'count ',
                                      p_line_rec.ship_from_location_id.COUNT);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     i := p_line_rec.ship_from_location_id.FIRST;
     WHILE i IS NOT NULL LOOP

        l_debug_num := 1;
        p_line_rec.country_of_origin(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.lpn_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.ship_from_location_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.ship_to_location_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.deliver_to_location_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.intmed_ship_to_location_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.intermed_ship_to_contact_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.requested_quantity(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.carrier_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.customer_item_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.dep_plan_required_flag(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.net_weight(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.volume(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.mvt_stat_status(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.organization_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.cancelled_quantity2(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.tracking_number(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.shipping_interfaced_flag(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.source_line_number(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.inspection_flag(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.gross_weight(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.seal_code(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.requested_quantity2(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.requested_quantity_uom2(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.revision(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.container_name(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.source_line_set_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.detail_container_item_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.master_container_item_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.original_subinventory(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.error_message_count(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.received_quantity(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.received_quantity2(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.line_set_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.drop_ship_flag(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.source_document_type_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.intermed_ship_to_org_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.delivery_detail_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.source_blanket_reference_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.source_blanket_reference_num(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.vendor_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.vendor_party_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.Days_early_receipt_allowed(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.Days_late_receipt_allowed(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.ship_from_site_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.hold_code(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.supplier_item_num(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.po_shipment_line_id(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.po_shipment_line_number(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.shipping_control(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.source_line_type_code(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.consolidate_quantity(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.po_revision(i) := NULL;
        l_debug_num := l_debug_num + 1;
        p_line_rec.release_revision(i) := NULL;
        l_debug_num := l_debug_num + 1;
        i := p_line_rec.ship_from_location_id.NEXT(i);

     END LOOP;
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_BULK_PROCESS_PVT.clear_wsh_prev_tabs');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'i ',i);
        WSH_DEBUG_SV.log(l_module_name,'l_debug_num ',l_debug_num);
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
           'Oracle error message is '||
           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
END clear_wsh_prev_tabs;




--========================================================================
-- PROCEDURE : calc_service_mode
--
-- PARAMETERS:
--             p_line_rec
--             p_cache_tbl             used to store the cache info
--             p_cache_ext_tbl         used to store the cache info
--             p_index                 current index for tables in
--                                     p_additional_line_info_rec
--             p_additional_line_info_rec
--             x_return_status         return status
-- COMMENT   : The service_level and mode_of_transport is calculated and
--             populated to the p_additional_line_info_rec.mode_of_transport
--             and p_additional_line_info_rec.service_level tables.
--             The index of these tables are cached, so that the for the same
--             ship_method_code these information is reused.
--========================================================================
  PROCEDURE calc_service_mode(
                       p_line_rec      IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
                       p_cache_tbl      IN OUT NOCOPY
                                              wsh_util_core.char500_tab_type,
                       p_cache_ext_tbl  IN OUT NOCOPY
                                               wsh_util_core.char500_tab_type,
                       p_index          IN NUMBER,
                       p_additional_line_info_rec IN OUT NOCOPY
                                                  additional_line_info_rec_type,
                       x_return_status   OUT NOCOPY VARCHAR2)
  IS
    l_debug_on BOOLEAN;
    --
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
               '.' || 'calc_service_mode';
    l_num_warnings   NUMBER;
    l_num_errors     NUMBER;
    l_index          NUMBER;
    l_return_status  VARCHAR2(1);
    l_value          NUMBER;
    l_ship_method_code VARCHAR2(30);
    l_carrier_rec    WSH_CARRIERS_GRP.Carrier_Service_InOut_Rec_Type;


  BEGIN
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'ship_method_code ',
                                  p_line_rec.shipping_method_code(p_index));
       WSH_DEBUG_SV.log(l_module_name,'p_index ',p_index);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     l_ship_method_code := p_line_rec.shipping_method_code(p_index);
     IF l_ship_method_code IS NOT NULL THEN --{
        wsh_util_core.get_cached_value(
                                       p_cache_tbl=> p_cache_tbl,
                                       p_cache_ext_tbl => p_cache_ext_tbl,
                                       p_value => l_ship_method_code,
                                       p_key   => l_index,
                                       p_action => 'GET',
                                       x_return_status => l_return_status) ;

         wsh_util_core.api_post_call(
                                   p_return_status => l_return_status,
                                   x_num_warnings  => l_num_warnings,
                                   x_num_errors    => l_num_errors);
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN --{
            --the information is not cached, so calculate it
            l_carrier_rec.ship_method_code := l_ship_method_code;

            WSH_CARRIERS_GRP.get_carrier_service_mode(
                             p_carrier_service_inout_rec => l_carrier_rec,
                             x_return_status => l_return_status);
            wsh_util_core.api_post_call(
                                   p_return_status => l_return_status,
                                   x_num_warnings  => l_num_warnings,
                                   x_num_errors    => l_num_errors);

            IF l_carrier_rec.generic_flag = 'Y' THEN
               p_line_rec.shipping_method_code(p_index) := NULL;
               p_line_rec.carrier_id(p_index) := NULL;
               l_ship_method_code := NULL;
            ELSE
               p_line_rec.carrier_id(p_index) := l_carrier_rec.carrier_id;
            END IF;
             p_additional_line_info_rec.service_level(p_index) := l_carrier_rec.service_level;
             p_additional_line_info_rec.mode_of_transport(p_index) := l_carrier_rec.mode_of_transport;
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'generic_flag ',
                                                   l_carrier_rec.generic_flag);
              WSH_DEBUG_SV.log(l_module_name,'calculated service level ',
                             p_additional_line_info_rec.service_level(p_index));
              WSH_DEBUG_SV.log(l_module_name,'calculated mode_of_transport ',
                         p_additional_line_info_rec.mode_of_transport(p_index));
            END IF;
            --insert the values into the cache
            wsh_util_core.get_cached_value(
                                       p_cache_tbl=> p_cache_tbl,
                                       p_cache_ext_tbl => p_cache_ext_tbl,
                                       p_value => l_ship_method_code,
                                       p_key   => p_index,
                                       p_action => 'PUT',
                                       x_return_status => l_return_status) ;
         ELSE --}{
            -- the values are already cached
            p_additional_line_info_rec.service_level(p_index) :=
                            p_additional_line_info_rec.service_level(l_index);
            p_additional_line_info_rec.mode_of_transport(p_index) :=
                         p_additional_line_info_rec.mode_of_transport(l_index);
            p_line_rec.shipping_method_code(p_index) :=
                           p_line_rec.shipping_method_code(l_index);
            p_line_rec.carrier_id(p_index) :=
                           p_line_rec.carrier_id(l_index);
         END IF; --}
     END IF; --}

     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'service level ',
                             p_additional_line_info_rec.service_level(p_index));
        WSH_DEBUG_SV.log(l_module_name,'mode of transport ',
                         p_additional_line_info_rec.mode_of_transport(p_index));
        WSH_DEBUG_SV.log(l_module_name,'shipping_method_code ',
                         p_line_rec.shipping_method_code(p_index));
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_BULK_PROCESS_PVT.calc_service_mode');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
           'Oracle error message is '||
           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
  END calc_service_mode;



-- Start of comments
-- API name : CHECK_NULL_FIELDS
-- Type     : Public
-- Pre-reqs : None.
-- Function : If the caller is not OM (e.g OKE) then this procedure will
--             check for the required fields.The fields which are NULL are
--             collected in the local variable l_token.
-- Parameters :
-- IN:
--                  p_index     IN  NUMBER
--                     The index of the record of the i/p table of records
--                     namely p_line_rec. Only the fields of the record
--                     corresponding to this index are checked for Null.
-- IN OUT:
--                  p_line_rec  IN OUT NOCOPY  OE_WSH_BULK_GRP.Line_rec_type
--                     The input table of records, which contains the fields
--                     to be checked for NULL.
-- OUT:
--                  x_return_status OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments



  PROCEDURE check_null_fields(
                  p_line_rec  IN OUT NOCOPY  OE_WSH_BULK_GRP.Line_rec_type,
                  p_index     IN  NUMBER,
                  x_return_status OUT NOCOPY VARCHAR2
  )
  IS

    l_token     VARCHAR2(200);
    --
    l_debug_on BOOLEAN;
    --
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
               '.' || 'check_null_fields';

  BEGIN

     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'p_index',p_index);
       WSH_DEBUG_SV.log(l_module_name,'p_line_rec.header_id.COUNT',p_line_rec.header_id.COUNT);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

/*bms create a message WSH_REQUIRED_FIELDS_NULL saying
  Fields  and FIELD_NAME cannot be null
*/
     IF p_line_rec.header_id(p_index) IS NULL THEN
        l_token := 'header_id ';
     END IF;
     IF p_line_rec.line_id(p_index) IS NULL THEN
        l_token := l_token || 'line_id ';
     END IF;
     IF p_line_rec.ordered_quantity(p_index) IS NULL THEN
        l_token := l_token || 'ordered_quantity ';
     END IF;
     IF p_line_rec.order_quantity_uom(p_index) IS NULL THEN
        l_token := l_token || 'order_quantity_uom ';
     END IF;
     IF (p_line_rec.inventory_item_id(p_index) IS NULL)
       AND (p_line_rec.item_description(p_index) IS NULL)
     THEN
        l_token := l_token || 'inventory_item_id item_description ';
     END IF;
     IF p_line_rec.organization_id(p_index) IS NULL THEN
        l_token := l_token || 'organization_id ';
     END IF;
     IF p_line_rec.source_header_number(p_index) IS NULL THEN
        l_token := l_token || 'source_header_number ';
     END IF;
     IF p_line_rec.source_line_number(p_index) IS NULL THEN
        l_token := l_token || 'source_line_number ';
     END IF;
     IF p_line_rec.ship_from_location_id(p_index) IS NULL THEN
        l_token := l_token || 'ship_from_location_id ';
     END IF;
     IF p_line_rec.ship_to_location_id(p_index) IS NULL THEN
        l_token := l_token || 'shipping_eligible_flag ';
     END IF;


     -- If true, it implies that certain field(s) are NULL.
     IF l_token IS NOT NULL THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_token ',l_token);
        END IF;

        FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELDS_NULL');
        FND_MESSAGE.SET_TOKEN('FIELD_NAMES',l_token);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(x_return_status, l_module_name);

     END IF;

     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;

  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_BULK_PROCESS_PVT.check_null_fields');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
           'Oracle error message is '||
           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
  END check_null_fields;






--========================================================================
-- PROCEDURE : Calc_wt_vol_qty
--
-- PARAMETERS: p_line_rec              Line record
--             p_additional_line_info_rec additional tables for the line
--             p_index                 The index for p_line_rec
--             x_return_status         return status
--
-- COMMENT   : This procedure calculates the weight, volume and quantity
--             related fields.
--========================================================================

  PROCEDURE Calc_wt_vol_qty(
                        p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
                        p_additional_line_info_rec   IN  OUT NOCOPY
                                           additional_line_info_rec_type ,
                        p_index    IN  NUMBER,
                        p_action_prms      IN  OUT NOCOPY
                               WSH_BULK_TYPES_GRP.action_parameters_rectype,
                        x_return_status OUT NOCOPY VARCHAR2
  )
  IS
    l_debug_on BOOLEAN;
    --
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
               '.' || 'CALC_WT_VOL_QTY';
    v_item_info_rec         wsh_util_validate.item_info_rec_type;
    l_return_status       VARCHAR2(1);
    l_item_type           VARCHAR2(30);
    l_token               VARCHAR2(100);
    l_num_warnings   NUMBER := 0;
    l_num_errors     NUMBER := 0;

    -- RV DEC_QTY
    l_max_decimal_digits NUMBER ;
    -- RV DEC_QTY

-- HW BUG #3064890 for HVOP for OPM
-- end of 3064890

  BEGIN

     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
     END IF;

     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     IF (p_line_rec.inventory_item_id(p_index) is NULL) THEN --{
        IF (p_line_rec.requested_quantity(p_index) is null ) THEN
           p_line_rec.requested_quantity_uom(p_index) :=
                                    p_line_rec.order_quantity_uom(p_index);
           p_line_rec.requested_quantity(p_index) :=
                                    p_line_rec.ordered_quantity(p_index);
        END IF;
        IF p_line_rec.volume IS NULL THEN
           l_token := 'volume';
        ELSIF p_line_rec.weight_uom_code IS NULL THEN
           l_token := 'weight_uom_code';
        ELSIF p_line_rec.net_weight IS NULL THEN
           l_token := 'net_weight';
        ELSIF p_line_rec.volume_uom_code IS NULL THEN
           l_token := 'volume_uom_code';
        END IF;

        IF l_token IS NOT NULL THEN

           FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
           FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_token);
           wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,
                                                              l_module_name);

           RAISE FND_API.G_EXC_ERROR;

        END IF;

        p_additional_line_info_rec.inv_interfaced_flag(p_index) := 'X';
     ELSE --}{
        IF p_line_rec.weight_uom_code(p_index) IS NULL OR
           p_line_rec.item_description(p_index) IS NULL OR
           p_line_rec.requested_quantity_uom(p_index) IS NULL OR
           p_line_rec.volume_uom_code(p_index) IS NULL
        THEN --{

           wsh_util_validate.get_item_info(
	     p_organization_id   => p_line_rec.organization_id(p_index),
             p_inventory_item_id => p_line_rec.inventory_item_id(p_index),
             x_Item_info_rec     => v_item_info_rec,
             x_return_status     => l_return_status);

	  wsh_util_core.api_post_call(
	     p_return_status => l_return_status,
	     x_num_warnings  => l_num_warnings,
	     x_num_errors    => l_num_errors);

           p_line_rec.item_description(p_index) := NVL(p_line_rec.item_description(p_index), v_item_info_rec.description);
           p_line_rec.requested_quantity_uom(p_index) := NVL(p_line_rec.requested_quantity_uom(p_index), v_item_info_rec.primary_uom_code);
           p_line_rec.weight_uom_code(p_index) := NVL(p_line_rec.weight_uom_code(p_index), v_item_info_rec.weight_uom_code);
           p_line_rec.volume_uom_code(p_index) := NVL(p_line_rec.volume_uom_code(p_index), v_item_info_rec.volume_uom_code);
           p_line_rec.mtl_unit_weight(p_index) := NVL(p_line_rec.mtl_unit_weight(p_index), v_item_info_rec.unit_weight);
           p_line_rec.mtl_unit_volume(p_index) := NVL(p_line_rec.mtl_unit_volume(p_index), v_item_info_rec.unit_volume);

        END IF;--}

-- HW need to branch for OPM and use conversion for OPM lines
-- HW OPM BUG#:3064890 HVOP for OPM

--HW OPMCONV. Removed code forking

          IF p_line_rec.requested_quantity(p_index) IS NULL THEN
            -- RV DEC_QTY
            IF (p_action_prms.caller = 'PO') THEN
            --{
              l_max_decimal_digits := WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS;
            --}
            ELSE
            --{
              l_max_decimal_digits := WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS_INV;
            --}
            END IF;
            -- RV DEC_QTY
            p_line_rec.requested_quantity(p_index) :=
               wsh_wv_utils.convert_uom(
                 p_line_rec.order_quantity_uom(p_index),
                 p_line_rec.requested_quantity_uom(p_index),
                 p_line_rec.ordered_quantity(p_index),
                 p_line_rec.inventory_item_id(p_index),
                 l_max_decimal_digits); -- RV DEC_QTY

          END IF;
-- HW OPMCONV - Removed code forking
-- end of 3064890

        p_line_rec.net_weight(p_index) := p_line_rec.mtl_unit_weight(p_index) *
              p_line_rec.requested_quantity(p_index);
        p_line_rec.volume(p_index) := p_line_rec.mtl_unit_volume(p_index) *
              p_line_rec.requested_quantity(p_index);

        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_validate_OM_QTY_WT_VOL_LVL) = 1
        OR  WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PO_CALC_WT_VOL_LVL) = 1  THEN --{
           p_line_rec.gross_weight(p_index) := p_line_rec.net_weight(p_index);
        ELSE --}{
           WSH_UTIL_VALIDATE.Find_Item_Type(
             p_inventory_item_id => p_line_rec.inventory_item_id(p_index),
             p_organization_id   => p_line_rec.organization_id(p_index) ,
             x_item_type         => l_item_type,
             x_return_status     => l_return_status );

--bms new message: containers cannot be imported.

           IF(l_item_type = 'CONT_ITEM') THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_BAD_ITEM_TYPE');
              wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,
                                                              l_module_name);
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF; --}
     END IF; --}

     l_token := NULL;
     IF p_line_rec.requested_quantity(p_index) IS NULL THEN
        l_token := 'requested_quantity';
     ELSIF P_line_rec.requested_quantity_uom(p_index) IS NULL THEN
        l_token := 'requested_quantity_uom';
     END IF;

     IF l_token IS NOT NULL THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_token);
        wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_token ',l_token);
        END IF;

        RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'requeste_quantity ',
                                   P_line_rec.requested_quantity(p_index));
           WSH_DEBUG_SV.log(l_module_name,'requested_quantity_uom',
                                   P_line_rec.requested_quantity_uom(p_index));
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has '
          || 'occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. ' ||
        'Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING '||
           'exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --

    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_BULK_PROCESS_PVT.Calc_wt_vol_qty');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
           'Oracle error message is '||
           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

  END Calc_wt_vol_qty;



--========================================================================
-- PROCEDURE : Create_delivery_details
--
-- PARAMETERS: p_action_prms           Additional attributes needed
--	       p_line_rec              Line record
--             x_return_status         return status
-- COMMENT   : This API is called from the wrapper API:
--             WSH_BULK_PROCESS_GRP.Create_update_delivery_details
--             It imports the order lines into Shipping tables
--========================================================================

  PROCEDURE Create_delivery_details(
                  p_action_prms      IN  OUT NOCOPY
                               WSH_BULK_TYPES_GRP.action_parameters_rectype,
                  p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.Line_rec_type,
                  x_return_status          OUT  NOCOPY VARCHAR2
  )
  IS
--Added the following cursor for Inbound Logistics

    --Cursor checks for PO data in WSH.
    CURSOR c_po_exists(p_header_id NUMBER,p_blanket_ref_id NUMBER) is
    SELECT '1'
    FROM wsh_delivery_details
    WHERE source_header_id = p_header_id
    AND source_code = 'PO'
    AND (
        (p_blanket_ref_id is NULL AND
         source_blanket_reference_id IS NULL)
         OR
         (p_blanket_ref_id IS NOT NULL AND
         source_blanket_reference_id = p_blanket_ref_id)
        );


    l_debug_on BOOLEAN;
    --
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
               '.' || 'CREATE_DELIVERY_DETAILS';
    l_return_status           VARCHAR2(1);
    l_num_warnings            NUMBER := 0;
    l_num_errors              NUMBER := 0;
    l_action_prms             WSH_BULK_TYPES_GRP.action_parameters_rectype;
    l_tab_count               NUMBER := 0;
    l_valid_rec_exist         NUMBER;
    l_eligible_rec_exist      NUMBER;
    l_additional_line_info_rec additional_line_info_rec_type;
    l_dd_list		      WSH_PO_CMG_PVT.dd_list_type;
    l_dd_exists               VARCHAR2(1);
    l_vendor_party_exists  VARCHAR2(1);
    l_index     NUMBER := NULL;
    l_action_prms1             WSH_BULK_TYPES_GRP.action_parameters_rectype;
    i    NUMBER;
  BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
    END IF;

    --

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    l_action_prms   := p_action_prms;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'count of wsh managed tables ',
                                      p_line_rec.ship_from_location_id.COUNT);
      WSH_DEBUG_SV.log(l_module_name,'Caller',p_action_prms.caller);
      WSH_DEBUG_SV.log(l_module_name,'Action Code',p_action_prms.action_code);
    END IF;

    IF p_action_prms.caller = 'OM'  AND p_line_rec.ship_from_location_id.COUNT > 0 THEN

       clear_wsh_prev_tabs(p_line_rec => p_line_rec,
                           x_return_status => l_return_status);
       wsh_util_core.api_post_call(
         p_return_status    => l_return_status,
         x_num_warnings     => l_num_warnings,
         x_num_errors       => l_num_errors);

    END IF;

    Extend_tables (
      p_line_rec       => p_line_rec,
      p_action_prms    => l_action_prms,
      x_table_count    => l_tab_count,
      x_additional_line_info_rec => l_additional_line_info_rec,
      x_return_status  => l_return_status
    );

    wsh_util_core.api_post_call(
      p_return_status    => l_return_status,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);



    --wsh_util_validate.G_ITEM_INFO_TAB.DELETE;
    --wsh_util_validate.G_ITEM_CATEGORY_INFO_TAB.DELETE;
    --wsh_util_validate.G_SHIPPING_PARAMS_INFO_EXP_TAB.DELETE;
    --wsh_util_validate.G_SHIPPING_PARAMS_INFO_TAB.DELETE;

    --Added for Inbound Logistics.
    /*PO will pass the action code as APPROVE_PO even for reapproval case.
      Depending on the cursor c_po_exists, we now need to set the action
      code as APPROVE_PO or REAPPROVE_PO */

    IF p_action_prms.caller = 'PO' AND
       p_action_prms.action_code = 'APPROVE_PO' THEN

      OPEN c_po_exists(p_line_rec.header_id(p_line_rec.header_id.FIRST),
                       p_line_rec.source_blanket_reference_id(p_line_rec.header_id.FIRST));
      FETCH c_po_exists INTO l_dd_exists;
      CLOSE c_po_exists;
      IF l_dd_exists = '1'  THEN
        p_action_prms.action_code := 'REAPPROVE_PO';
      ELSE
        p_action_prms.action_code := 'APPROVE_PO';
      END IF;
    END IF;

    IF p_action_prms.action_code = 'APPROVE_PO' THEN

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'p_line_rec.vendor_id(p_line_rec.vendor_id.FIRST)',p_line_rec.vendor_id(p_line_rec.vendor_id.FIRST));
        END IF;

        --To find the party ID for the given Vendor ID.
        l_vendor_party_exists := WSH_SUPPLIER_PARTY.VENDOR_PARTY_EXISTS(
	  p_vendor_id => p_line_rec.vendor_id(p_line_rec.vendor_id.FIRST),
	  x_party_id  => l_vendor_party_id);

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'p_line_rec.vendor_id(p_line_rec.vendor_id.FIRST)',p_line_rec.vendor_id(p_line_rec.vendor_id.FIRST));
           WSH_DEBUG_SV.log(l_module_name,'l_vendor_party_exists',l_vendor_party_exists);
	   WSH_DEBUG_SV.log(l_module_name,'l_vendor_party_id',l_vendor_party_id);
	END IF;


	IF l_vendor_party_exists = 'N' THEN
           -- { IB-Phase-2
           --If party not exists, throw an error message and return.
          IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Party does not Exist for the Vendor ');
	  END IF;
           raise fnd_api.g_exc_error;
           -- } IB-Phase-2
	END IF;


    END IF;

    --
    Validate_lines(
       p_line_rec           => p_line_rec,
       P_action_prms        => l_action_prms,
       p_additional_line_info_rec => l_additional_line_info_rec,
       x_valid_rec_exist    => l_valid_rec_exist,
       x_eligible_rec_exist => l_eligible_rec_exist,
       X_return_status      => l_return_status
       );

    wsh_util_core.api_post_call(
      p_return_status    => l_return_status,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_valid_rec_exist ',l_valid_rec_exist);
      WSH_DEBUG_SV.log(l_module_name,'l_eligible_rec_exist ',
                                                        l_eligible_rec_exist);
    END IF;

  IF l_valid_rec_exist = 0 THEN --{
    IF l_eligible_rec_exist > 0 THEN

       /* if no lines were validated successfully, but there were some
          eligible records then raise error */

          RAISE FND_API.G_EXC_ERROR;
    ELSE

       /* if no lines were validated successfully, and no lines were
          eligible then return success */

      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      RETURN;
    END IF;
  ELSE --}{
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'calling bulk insert');
      WSH_DEBUG_SV.log(l_module_name,'action code ', p_action_prms.action_code);
    END IF;

       --Added for Inbound Logistics
    IF p_action_prms.action_code = 'APPROVE_PO'  or
      p_action_prms.action_code = 'CREATE' THEN
      bulk_insert_details (
        P_line_rec       => P_line_rec,
	      p_index          => l_index,
        p_action_prms    => l_action_prms,
        p_additional_line_info_rec => l_additional_line_info_rec,
        X_return_status  => l_return_status
        );
      --skattama
      i:= l_additional_line_info_rec.latest_pickup_tpdate_excep.FIRST;
      WHILE i is not NULL LOOP
        WSH_TP_RELEASE.log_tpdate_exception('LINE',P_line_rec.delivery_detail_id(i),TRUE,l_additional_line_info_rec.earliest_pickup_date(i),l_additional_line_info_rec.latest_pickup_tpdate_excep(i));
        i := l_additional_line_info_rec.latest_pickup_tpdate_excep.NEXT(i);
      END LOOP;

      i:=l_additional_line_info_rec.latest_dropoff_tpdate_excep.FIRST;
      WHILE i is not null LOOP
        WSH_TP_RELEASE.log_tpdate_exception('LINE',P_line_rec.delivery_detail_id(i),TRUE,l_additional_line_info_rec.earliest_pickup_date(i),l_additional_line_info_rec.latest_dropoff_tpdate_excep(i));
        i := l_additional_line_info_rec.latest_dropoff_tpdate_excep.NEXT(i);
      END LOOP;
      --skattama
    --
    IF p_action_prms.action_code = 'APPROVE_PO'
				THEN
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
    --
    --
    l_action_prms1.caller := 'PO_INTG';
				--
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.handlePriorReceipts',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    --
    WSH_IB_TXN_MATCH_PKG.handlePriorReceipts
      (
        p_action_prms      => l_action_prms1,
        x_line_rec         => p_line_rec,
        x_return_status    => l_return_status
      );
				END IF;
     ELSIF p_action_prms.action_code = 'REAPPROVE_PO' THEN
       WSH_PO_CMG_PVT.Reapprove_PO(
         p_line_rec     => p_line_rec,
         p_action_prms  => p_action_prms,
         p_dd_list      => l_dd_list,
         x_return_status => l_return_status);
     ELSIF (p_action_prms.action_code = 'CANCEL_PO' OR
           p_action_prms.action_code = 'CLOSE_PO' OR
           p_action_prms.action_code = 'FINAL_CLOSE' OR
           p_action_prms.action_code = 'CLOSE_PO_FOR_RECEIVING' ) THEN
       WSH_PO_CMG_PVT.Cancel_Close_PO(
         p_line_rec       => p_line_rec,
         p_action_prms    => p_action_prms,
         x_return_status => l_return_status);
     ELSIF p_action_prms.action_code = 'REOPEN_PO' THEN
        WSH_PO_CMG_PVT.Reopen_PO(
          p_line_rec       => p_line_rec,
          x_return_status => l_return_status);
     END IF;

     x_return_status := l_return_status;

     wsh_util_core.api_post_call(
        p_return_status    => l_return_status,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
   END IF; --}

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                            'Number of Errors='||l_num_errors||',Number of Warnings='||l_num_warnings);
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

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has '
          || 'occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. ' ||
        'Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING '||
           'exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --

    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_BULK_PROCESS_PVT.Create_delivery_details');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
           'Oracle error message is '||
           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

  END Create_delivery_details;


--========================================================================
-- PROCEDURE : Extend_tables
--
-- PARAMETERS: p_line_rec              Line record
--             p_action_prms           Additional attributes needed
--             x_table_count           Size of each table
--             x_additional_line_info_rec Local record that is extended
--                                     and ready to use to store  additional
--                                     information for line record.
--             x_return_status         return status
-- COMMENT   : This procedure extends all the common table in p_line_rec
--             It also extends the local tables used during the import.
--========================================================================


  PROCEDURE Extend_tables (
           p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
           p_action_prms     IN WSH_BULK_TYPES_GRP.action_parameters_rectype ,
           x_table_count     OUT NOCOPY NUMBER ,
           x_additional_line_info_rec    OUT NOCOPY
                                           additional_line_info_rec_type ,
           x_return_status  OUT NOCOPY VARCHAR2
  )
  IS
    l_debug_on BOOLEAN;
    --
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
               '.' || 'EXTEND_TABLES';
    l_field_name   VARCHAR2(200);
    l_count         NUMBER;
    e_extend_error  EXCEPTION;

  BEGIN
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    x_table_count := p_line_rec.line_id.COUNT;
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_table_count ',x_table_count);
       WSH_DEBUG_SV.log(l_module_name,'caller is ',p_action_prms.caller);
    END IF;

    IF x_table_count = 0 THEN
       --bms do we need to set some message
       RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF p_line_rec.org_id.COUNT = 0 AND nvl(p_action_prms.caller,'@@@') <> 'WSH_IB_UTIL' THEN
       p_line_rec.org_id.EXTEND(x_table_count);
    ELSIF p_line_rec.org_id.COUNT <> x_table_count AND nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
       p_line_rec.org_id.EXTEND;
    END IF;

    l_count := p_line_rec.organization_id.COUNT;
    IF l_count <> x_table_count THEN
       IF l_count = 0 THEN
          p_line_rec.organization_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.organization_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.organization_id.EXTEND(x_table_count - l_count);
       END IF;
     END IF;

    l_count := p_line_rec.arrival_set_id.COUNT;
    IF l_count <> x_table_count THEN
       IF l_count = 0 THEN
          p_line_rec.arrival_set_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.arrival_set_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'arrival_set_id';
          RAISE e_extend_error;
       END IF;
    END IF;

    l_count := p_line_rec.ato_line_id.COUNT;
    IF p_line_rec.ato_line_id.COUNT <> x_table_count THEN
       IF p_line_rec.ato_line_id.COUNT = 0 THEN
          p_line_rec.ato_line_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ato_line_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'ato_line_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.lpn_id.COUNT;
    IF p_line_rec.lpn_id.COUNT <> x_table_count THEN
       IF l_count = 0 THEN
          p_line_rec.lpn_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.lpn_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.lpn_id.EXTEND(x_table_count - l_count);
       END IF;
     END IF;

    l_count := p_line_rec.attribute1.COUNT;
    IF p_line_rec.attribute1.COUNT <> x_table_count THEN
       IF p_line_rec.attribute1.COUNT = 0 THEN
          p_line_rec.attribute1.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute1.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute1';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute10.COUNT;
    IF p_line_rec.attribute10.COUNT <> x_table_count THEN
       IF p_line_rec.attribute10.COUNT = 0 THEN
          p_line_rec.attribute10.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute10.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute10';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute11.COUNT;
    IF p_line_rec.attribute11.COUNT <> x_table_count THEN
        IF p_line_rec.attribute11.COUNT = 0 THEN
           p_line_rec.attribute11.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
           p_line_rec.attribute11.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute11';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute12.COUNT;
    IF p_line_rec.attribute12.COUNT <> x_table_count THEN
       IF p_line_rec.attribute12.COUNT = 0 THEN
          p_line_rec.attribute12.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute12.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute12';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute13.COUNT;
    IF p_line_rec.attribute13.COUNT <> x_table_count THEN
       IF p_line_rec.attribute13.COUNT = 0 THEN
          p_line_rec.attribute13.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute13.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute13';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute14.COUNT;
    IF p_line_rec.attribute14.COUNT <> x_table_count THEN
       IF p_line_rec.attribute14.COUNT = 0 THEN
          p_line_rec.attribute14.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute14.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute14';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute15.COUNT;
    IF p_line_rec.attribute15.COUNT <> x_table_count THEN
       IF p_line_rec.attribute15.COUNT = 0 THEN
          p_line_rec.attribute15.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute15.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute15';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute16.COUNT;
    IF p_line_rec.attribute16.COUNT <> x_table_count THEN
       IF p_line_rec.attribute16.COUNT = 0 THEN
          p_line_rec.attribute16.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute16.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute16';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute17.COUNT;
    IF p_line_rec.attribute17.COUNT <> x_table_count THEN
       IF p_line_rec.attribute17.COUNT = 0 THEN
          p_line_rec.attribute17.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute17.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute17';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute18.COUNT;
    IF p_line_rec.attribute18.COUNT <> x_table_count THEN
       IF p_line_rec.attribute18.COUNT = 0 THEN
          p_line_rec.attribute18.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute18.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute18';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute19.COUNT;
    IF p_line_rec.attribute19.COUNT <> x_table_count THEN
       IF p_line_rec.attribute19.COUNT = 0 THEN
          p_line_rec.attribute19.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute19.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute19';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute2.COUNT;
    IF p_line_rec.attribute2.COUNT <> x_table_count THEN
       IF p_line_rec.attribute2.COUNT = 0 THEN
          p_line_rec.attribute2.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute2.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute2';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute20.COUNT;
    IF p_line_rec.attribute20.COUNT <> x_table_count THEN
       IF p_line_rec.attribute20.COUNT = 0 THEN
          p_line_rec.attribute20.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute20.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute20';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute3.COUNT;
    IF p_line_rec.attribute3.COUNT <> x_table_count THEN
       IF p_line_rec.attribute3.COUNT = 0 THEN
          p_line_rec.attribute3.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute3.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute3';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute4.COUNT;
    IF p_line_rec.attribute4.COUNT <> x_table_count THEN
       IF p_line_rec.attribute4.COUNT = 0 THEN
          p_line_rec.attribute4.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute4.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute4';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute5.COUNT;
    IF p_line_rec.attribute5.COUNT <> x_table_count THEN
       IF p_line_rec.attribute5.COUNT = 0 THEN
          p_line_rec.attribute5.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute5.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute5';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute6.COUNT;
    IF p_line_rec.attribute6.COUNT <> x_table_count THEN
       IF p_line_rec.attribute6.COUNT = 0 THEN
          p_line_rec.attribute6.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute6.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute6';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute7.COUNT;
    IF p_line_rec.attribute7.COUNT <> x_table_count THEN
       IF p_line_rec.attribute7.COUNT = 0 THEN
          p_line_rec.attribute7.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute7.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute7';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute8.COUNT;
    IF p_line_rec.attribute8.COUNT <> x_table_count THEN
       IF p_line_rec.attribute8.COUNT = 0 THEN
          p_line_rec.attribute8.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute8.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute8';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.attribute9.COUNT;
    IF p_line_rec.attribute9.COUNT <> x_table_count THEN
       IF p_line_rec.attribute9.COUNT = 0 THEN
          p_line_rec.attribute9.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.attribute9.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'attribute9';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.CONTEXT.COUNT;
    IF p_line_rec.CONTEXT.COUNT <> x_table_count THEN
       IF p_line_rec.CONTEXT.COUNT = 0 THEN
          p_line_rec.CONTEXT.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.CONTEXT.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'CONTEXT';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.customer_dock_code.COUNT;
    IF p_line_rec.customer_dock_code.COUNT <> x_table_count THEN
       IF p_line_rec.customer_dock_code.COUNT = 0 THEN
          p_line_rec.customer_dock_code.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.customer_dock_code.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'customer_dock_code';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.customer_job.COUNT;
    IF p_line_rec.customer_job.COUNT <> x_table_count THEN
       IF p_line_rec.customer_job.COUNT = 0 THEN
          p_line_rec.customer_job.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.customer_job.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'customer_job';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.customer_production_line.COUNT;
    IF p_line_rec.customer_production_line.COUNT <> x_table_count THEN
       IF p_line_rec.customer_production_line.COUNT = 0 THEN
          p_line_rec.customer_production_line.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.customer_production_line.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'customer_production_line';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.cust_model_serial_number.COUNT;
    IF p_line_rec.cust_model_serial_number.COUNT <> x_table_count THEN
       IF p_line_rec.cust_model_serial_number.COUNT = 0 THEN
          p_line_rec.cust_model_serial_number.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.cust_model_serial_number.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'cust_model_serial_number';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.cust_po_number.COUNT;
    IF p_line_rec.cust_po_number.COUNT <> x_table_count THEN
       IF p_line_rec.cust_po_number.COUNT = 0 THEN
          p_line_rec.cust_po_number.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.cust_po_number.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'cust_po_number';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.cust_production_seq_num.COUNT;
    IF p_line_rec.cust_production_seq_num.COUNT <> x_table_count THEN
       IF p_line_rec.cust_production_seq_num.COUNT = 0 THEN
          p_line_rec.cust_production_seq_num.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.cust_production_seq_num.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'cust_production_seq_num';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.deliver_to_contact_id.COUNT;
    IF p_line_rec.deliver_to_contact_id.COUNT <> x_table_count THEN
       IF p_line_rec.deliver_to_contact_id.COUNT = 0 THEN
          p_line_rec.deliver_to_contact_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.deliver_to_contact_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'deliver_to_contact_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.deliver_to_org_id.COUNT;
    IF p_line_rec.deliver_to_org_id.COUNT <> x_table_count THEN
       IF p_line_rec.deliver_to_org_id.COUNT = 0 THEN
          p_line_rec.deliver_to_org_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.deliver_to_org_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'deliver_to_org_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.dep_plan_required_flag.COUNT;
    IF p_line_rec.dep_plan_required_flag.COUNT <> x_table_count THEN
       IF p_line_rec.dep_plan_required_flag.COUNT = 0 THEN
          p_line_rec.dep_plan_required_flag.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.dep_plan_required_flag.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.dep_plan_required_flag.EXTEND(x_table_count - l_count);
       END IF;
     END IF;

    l_count := p_line_rec.end_item_unit_number.COUNT;
    IF p_line_rec.end_item_unit_number.COUNT <> x_table_count THEN
       IF p_line_rec.end_item_unit_number.COUNT = 0 THEN
          p_line_rec.end_item_unit_number.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.end_item_unit_number.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'end_item_unit_number';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.fob_point_code.COUNT;
    IF p_line_rec.fob_point_code.COUNT <> x_table_count THEN
       IF p_line_rec.fob_point_code.COUNT = 0 THEN
          p_line_rec.fob_point_code.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.fob_point_code.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'fob_point_code';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.freight_terms_code.COUNT;
    IF p_line_rec.freight_terms_code.COUNT <> x_table_count THEN
       IF p_line_rec.freight_terms_code.COUNT = 0 THEN
          p_line_rec.freight_terms_code.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.freight_terms_code.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'freight_terms_code';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.header_id.COUNT;
    IF p_line_rec.header_id.COUNT <> x_table_count THEN
       IF p_line_rec.header_id.COUNT = 0 THEN
          p_line_rec.header_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.header_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'header_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_CONTEXT.COUNT;
    IF p_line_rec.TP_CONTEXT.COUNT <> x_table_count THEN
       IF p_line_rec.TP_CONTEXT.COUNT = 0 THEN
          p_line_rec.TP_CONTEXT.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_CONTEXT.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_CONTEXT';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE1.COUNT;
    IF p_line_rec.TP_ATTRIBUTE1.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE1.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE1.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE1.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE1';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE2.COUNT;
    IF p_line_rec.TP_ATTRIBUTE2.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE2.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE2.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE2.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE2';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE3.COUNT;
    IF p_line_rec.TP_ATTRIBUTE3.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE3.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE3.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE3.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE3';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE4.COUNT;
    IF p_line_rec.TP_ATTRIBUTE4.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE4.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE4.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE4.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE4';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE5.COUNT;
    IF p_line_rec.TP_ATTRIBUTE5.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE5.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE5.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE5.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE5';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE6.COUNT;
    IF p_line_rec.TP_ATTRIBUTE6.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE6.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE6.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE6.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE6';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE7.COUNT;
    IF p_line_rec.TP_ATTRIBUTE7.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE7.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE7.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE7.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE7';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE8.COUNT;
    IF p_line_rec.TP_ATTRIBUTE8.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE8.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE8.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE8.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE8';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE9.COUNT;
    IF p_line_rec.TP_ATTRIBUTE9.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE9.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE9.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE9.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE9';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE10.COUNT;
    IF p_line_rec.TP_ATTRIBUTE10.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE10.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE10.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE10.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE10';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE11.COUNT;
    IF p_line_rec.TP_ATTRIBUTE11.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE11.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE11.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE11.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE11';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE12.COUNT;
    IF p_line_rec.TP_ATTRIBUTE12.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE12.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE12.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE12.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE12';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE13.COUNT;
    IF p_line_rec.TP_ATTRIBUTE13.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE13.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE13.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE13.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE13';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE14.COUNT;
    IF p_line_rec.TP_ATTRIBUTE14.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE14.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE14.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE14.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE14';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.TP_ATTRIBUTE15.COUNT;
    IF p_line_rec.TP_ATTRIBUTE15.COUNT <> x_table_count THEN
       IF p_line_rec.TP_ATTRIBUTE15.COUNT = 0 THEN
          p_line_rec.TP_ATTRIBUTE15.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.TP_ATTRIBUTE15.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'TP_ATTRIBUTE15';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.intermed_ship_to_contact_id.COUNT;
    IF p_line_rec.intermed_ship_to_contact_id.COUNT <> x_table_count THEN
       IF p_line_rec.intermed_ship_to_contact_id.COUNT = 0 THEN
          p_line_rec.intermed_ship_to_contact_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.intermed_ship_to_contact_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.intermed_ship_to_contact_id.EXTEND(x_table_count - l_count);
       END IF;
     END IF;

    l_count := p_line_rec.inventory_item_id.COUNT;
    IF p_line_rec.inventory_item_id.COUNT <> x_table_count THEN
       IF p_line_rec.inventory_item_id.COUNT = 0 THEN
          p_line_rec.inventory_item_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.inventory_item_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'inventory_item_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.line_number.COUNT;
    IF p_line_rec.line_number.COUNT <> x_table_count THEN
       IF p_line_rec.line_number.COUNT = 0  THEN
          p_line_rec.line_number.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.line_number.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'line_number';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.ordered_quantity.COUNT;
    IF p_line_rec.ordered_quantity.COUNT <> x_table_count THEN
       IF p_line_rec.ordered_quantity.COUNT = 0 THEN
          p_line_rec.ordered_quantity.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ordered_quantity.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'ordered_quantity';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.ordered_quantity2.COUNT;
    IF p_line_rec.ordered_quantity2.COUNT <> x_table_count THEN
       IF p_line_rec.ordered_quantity2.COUNT = 0 THEN
          p_line_rec.ordered_quantity2.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ordered_quantity2.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'ordered_quantity2';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.order_quantity_uom.COUNT;
    IF p_line_rec.order_quantity_uom.COUNT <> x_table_count THEN
       IF p_line_rec.order_quantity_uom.COUNT = 0 THEN
          p_line_rec.order_quantity_uom.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.order_quantity_uom.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'order_quantity_uom';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.ordered_quantity_uom2.COUNT;
    IF p_line_rec.ordered_quantity_uom2.COUNT <> x_table_count THEN
       IF p_line_rec.ordered_quantity_uom2.COUNT = 0 THEN
          p_line_rec.ordered_quantity_uom2.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ordered_quantity_uom2.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'ordered_quantity_uom2';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.preferred_grade.COUNT;
    IF p_line_rec.preferred_grade.COUNT <> x_table_count THEN
       IF p_line_rec.preferred_grade.COUNT = 0 THEN
          p_line_rec.preferred_grade.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.preferred_grade.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'preferred_grade';
          RAISE e_extend_error;
       END IF;
     END IF;


    l_count := p_line_rec.project_id.COUNT;
    IF p_line_rec.project_id.COUNT <> x_table_count THEN
       IF p_line_rec.project_id.COUNT = 0 THEN
          p_line_rec.project_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.project_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'project_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.request_date.COUNT;
    IF p_line_rec.request_date.COUNT <> x_table_count THEN
       IF p_line_rec.request_date.COUNT = 0 THEN
          p_line_rec.request_date.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.request_date.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'request_date';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.schedule_ship_date.COUNT;
    IF p_line_rec.schedule_ship_date.COUNT <> x_table_count THEN
       IF p_line_rec.schedule_ship_date.COUNT = 0 THEN
          p_line_rec.schedule_ship_date.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.schedule_ship_date.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'schedule_ship_date';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.shipment_priority_code.COUNT;
    IF p_line_rec.shipment_priority_code.COUNT <> x_table_count THEN
       IF p_line_rec.shipment_priority_code.COUNT = 0 THEN
          p_line_rec.shipment_priority_code.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.shipment_priority_code.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'shipment_priority_code';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.shipping_interfaced_flag.COUNT;
    IF p_line_rec.shipping_interfaced_flag.COUNT <> x_table_count THEN
       IF p_line_rec.shipping_interfaced_flag.COUNT = 0 THEN
          p_line_rec.shipping_interfaced_flag.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.shipping_interfaced_flag.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.shipping_interfaced_flag.EXTEND(x_table_count - l_count);
       END IF;
     END IF;

    l_count := p_line_rec.shipping_method_code.COUNT;
    IF p_line_rec.shipping_method_code.COUNT <> x_table_count THEN
       IF p_line_rec.shipping_method_code.COUNT = 0 THEN
          p_line_rec.shipping_method_code.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.shipping_method_code.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'shipping_method_code';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.ship_from_org_id.COUNT;
    IF p_line_rec.ship_from_org_id.COUNT <> x_table_count THEN
       IF p_line_rec.ship_from_org_id.COUNT = 0 THEN
          p_line_rec.ship_from_org_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ship_from_org_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'ship_from_org_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.ship_model_complete_flag.COUNT;
    IF p_line_rec.ship_model_complete_flag.COUNT <> x_table_count THEN
       IF p_line_rec.ship_model_complete_flag.COUNT = 0 THEN
          p_line_rec.ship_model_complete_flag.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ship_model_complete_flag.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'ship_model_complete_flag';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.ship_set_id.COUNT;
    IF p_line_rec.ship_set_id.COUNT <> x_table_count THEN
       IF p_line_rec.ship_set_id.COUNT = 0 THEN
          p_line_rec.ship_set_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ship_set_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'ship_set_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.ship_tolerance_above.COUNT;
    IF p_line_rec.ship_tolerance_above.COUNT <> x_table_count THEN
       IF p_line_rec.ship_tolerance_above.COUNT = 0 THEN
          p_line_rec.ship_tolerance_above.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ship_tolerance_above.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'ship_tolerance_above';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.ship_tolerance_below.COUNT;
    IF p_line_rec.ship_tolerance_below.COUNT <> x_table_count THEN
       IF p_line_rec.ship_tolerance_below.COUNT = 0 THEN
          p_line_rec.ship_tolerance_below.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ship_tolerance_below.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'ship_tolerance_below';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.ship_to_contact_id.COUNT;
    IF p_line_rec.ship_to_contact_id.COUNT <> x_table_count THEN
       IF p_line_rec.ship_to_contact_id.COUNT = 0 THEN
          p_line_rec.ship_to_contact_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ship_to_contact_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'ship_to_contact_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.ship_to_org_id.COUNT;
    IF p_line_rec.ship_to_org_id.COUNT <> x_table_count THEN
       IF p_line_rec.ship_to_org_id.COUNT = 0 THEN
          p_line_rec.ship_to_org_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ship_to_org_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'ship_to_org_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.sold_to_org_id.COUNT;
    IF p_line_rec.sold_to_org_id.COUNT <> x_table_count THEN
       IF p_line_rec.sold_to_org_id.COUNT = 0 THEN
          p_line_rec.sold_to_org_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.sold_to_org_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'sold_to_org_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.task_id.COUNT;
    IF p_line_rec.task_id.COUNT <> x_table_count THEN
       IF p_line_rec.task_id.COUNT = 0 THEN
          p_line_rec.task_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.task_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'task_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.top_model_line_id.COUNT;
    IF p_line_rec.top_model_line_id.COUNT <> x_table_count THEN
       IF p_line_rec.top_model_line_id.COUNT = 0 THEN
          p_line_rec.top_model_line_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.top_model_line_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'top_model_line_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.unit_list_price.COUNT;
    IF p_line_rec.unit_list_price.COUNT <> x_table_count THEN
       IF p_line_rec.unit_list_price.COUNT = 0 THEN
          p_line_rec.unit_list_price.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.unit_list_price.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'unit_list_price';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.ordered_item_id.COUNT;
    IF p_line_rec.ordered_item_id.COUNT <> x_table_count THEN
       IF p_line_rec.ordered_item_id.COUNT = 0 THEN
          p_line_rec.ordered_item_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ordered_item_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'ordered_item_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.item_identifier_type.COUNT;
    IF p_line_rec.item_identifier_type.COUNT <> x_table_count THEN
       IF p_line_rec.item_identifier_type.COUNT = 0 THEN
          p_line_rec.item_identifier_type.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.item_identifier_type.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'item_identifier_type';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.shipping_instructions.COUNT;
    IF p_line_rec.shipping_instructions.COUNT <> x_table_count THEN
       IF p_line_rec.shipping_instructions.COUNT = 0 THEN
          p_line_rec.shipping_instructions.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.shipping_instructions.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'shipping_instructions';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.packing_instructions.COUNT;
    IF p_line_rec.packing_instructions.COUNT <> x_table_count THEN
       IF p_line_rec.packing_instructions.COUNT = 0 THEN
          p_line_rec.packing_instructions.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.packing_instructions.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'packing_instructions';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.Line_set_id.COUNT;
    IF p_line_rec.Line_set_id.COUNT <> x_table_count THEN
       IF p_line_rec.Line_set_id.COUNT = 0 THEN
          p_line_rec.Line_set_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.Line_set_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.Line_set_id.EXTEND(x_table_count - l_count);
       END IF;
     END IF;

    l_count := p_line_rec.ORIGINAL_subinventory.COUNT;
    IF p_line_rec.ORIGINAL_subinventory.COUNT <> x_table_count THEN
       IF p_line_rec.ORIGINAL_subinventory.COUNT = 0 THEN
          p_line_rec.ORIGINAL_subinventory.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ORIGINAL_subinventory.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.ORIGINAL_subinventory.EXTEND(x_table_count - l_count);
       END IF;
     END IF;

    l_count := p_line_rec.subinventory.COUNT;
    IF p_line_rec.subinventory.COUNT <> x_table_count THEN
       IF p_line_rec.subinventory.COUNT = 0 THEN
          p_line_rec.subinventory.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.subinventory.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'subinventory';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.shipping_eligible_flag.COUNT;
    IF p_line_rec.shipping_eligible_flag.COUNT <> x_table_count THEN
       IF p_line_rec.shipping_eligible_flag.COUNT = 0 THEN --{

          IF p_action_prms.caller = 'OM' THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_table_count ',x_table_count);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          p_line_rec.shipping_eligible_flag.EXTEND;
          p_line_rec.shipping_eligible_flag(p_line_rec.shipping_eligible_flag.FIRST) := 'Y';
          IF x_table_count > 1 THEN
             p_line_rec.shipping_eligible_flag.EXTEND(x_table_count-1,1);
          END IF;
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.shipping_eligible_flag.EXTEND;
          p_line_rec.shipping_eligible_flag(p_line_rec.shipping_eligible_flag.COUNT) := 'Y';
       ELSIF l_count < x_table_count THEN --}{
          l_field_name := 'shipping_eligible_flag';
           RAISE e_extend_error;
       END IF; --}
     END IF;

    l_count := p_line_rec.error_message_count.COUNT;
    IF p_line_rec.error_message_count.COUNT <> x_table_count THEN
       IF p_line_rec.error_message_count.COUNT = 0 THEN
          p_line_rec.error_message_count.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.error_message_count.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.error_message_count.EXTEND(x_table_count - l_count);
       END IF;
     END IF;

    l_count := p_line_rec.sold_to_contact_id.COUNT;
    IF p_line_rec.sold_to_contact_id.COUNT <> x_table_count THEN
       IF p_line_rec.sold_to_contact_id.COUNT = 0 THEN
          p_line_rec.sold_to_contact_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.sold_to_contact_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'sold_to_contact_id';
          RAISE e_extend_error;
       END IF;
     END IF;

    l_count := p_line_rec.item_description.COUNT;
    IF p_line_rec.item_description.COUNT <> x_table_count THEN
       IF p_line_rec.item_description.COUNT = 0 THEN
          p_line_rec.item_description.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.item_description.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'item_description';
          RAISE e_extend_error;
       END IF;
    END IF;

    l_count := p_line_rec.hazard_class_id.COUNT;
    IF p_line_rec.hazard_class_id.COUNT <> x_table_count THEN
       IF p_line_rec.hazard_class_id.COUNT = 0 THEN
          p_line_rec.hazard_class_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.hazard_class_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'hazard_class_id';
          RAISE e_extend_error;
       END IF;
    END IF;

    l_count := p_line_rec.weight_uom_code.COUNT;
    IF p_line_rec.weight_uom_code.COUNT <> x_table_count THEN
       IF p_line_rec.weight_uom_code.COUNT = 0 THEN
          p_line_rec.weight_uom_code.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.weight_uom_code.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'weight_uom_code';
          RAISE e_extend_error;
       END IF;
    END IF;

    l_count := p_line_rec.Volume.COUNT;
    IF p_line_rec.Volume.COUNT <> x_table_count THEN
       IF p_line_rec.Volume.COUNT = 0 THEN
          p_line_rec.Volume.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.Volume.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.Volume.EXTEND(x_table_count - l_count);
       END IF;
    END IF;

    l_count := p_line_rec.volume_uom_code.COUNT;
    IF p_line_rec.volume_uom_code.COUNT <> x_table_count THEN
       IF p_line_rec.volume_uom_code.COUNT = 0 THEN
          p_line_rec.volume_uom_code.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.volume_uom_code.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name :='volume_uom_code';
          RAISE e_extend_error;
       END IF;
    END IF;

    l_count := p_line_rec.source_header_number.COUNT;
    IF p_line_rec.source_header_number.COUNT <> x_table_count THEN
       IF p_line_rec.source_header_number.COUNT = 0 THEN
          p_line_rec.source_header_number.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.source_header_number.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name :='source_header_number';
          RAISE e_extend_error;
       END IF;
    END IF;

    l_count := p_line_rec.source_header_type_id.COUNT;
    IF p_line_rec.source_header_type_id.COUNT <> x_table_count THEN
       IF p_line_rec.source_header_type_id.COUNT = 0 THEN
          p_line_rec.source_header_type_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.source_header_type_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name :='source_header_type_id';
          RAISE e_extend_error;
       END IF;
    END IF;

    l_count := p_line_rec.source_header_type_name.COUNT;
    IF p_line_rec.source_header_type_name.COUNT <> x_table_count THEN
       IF p_line_rec.source_header_type_name.COUNT = 0 THEN
          p_line_rec.source_header_type_name.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.source_header_type_name.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name :='source_header_type_name';
          RAISE e_extend_error;
       END IF;
    END IF;

    l_count := p_line_rec.mtl_unit_weight.COUNT;
    IF p_line_rec.mtl_unit_weight.COUNT <> x_table_count THEN
       IF p_line_rec.mtl_unit_weight.COUNT = 0 THEN
          p_line_rec.mtl_unit_weight.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.mtl_unit_weight.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name :='mtl_unit_weight';
          RAISE e_extend_error;
       END IF;
    END IF;

    l_count := p_line_rec.mtl_unit_volume.COUNT;
    IF p_line_rec.mtl_unit_volume.COUNT <> x_table_count THEN
       IF p_line_rec.mtl_unit_volume.COUNT = 0 THEN
          p_line_rec.mtl_unit_volume.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.mtl_unit_volume.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name :='mtl_unit_volume';
          RAISE e_extend_error;
       END IF;
    END IF;

    l_count := p_line_rec.currency_code.COUNT;
    IF p_line_rec.currency_code.COUNT <> x_table_count THEN
       IF p_line_rec.currency_code.COUNT = 0 THEN
          p_line_rec.currency_code.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.currency_code.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'currency_code';
          RAISE e_extend_error;
       END IF;
    END IF;

    l_count := p_line_rec.country_of_origin.COUNT;
    IF p_line_rec.country_of_origin.COUNT <> x_table_count THEN
       IF p_line_rec.country_of_origin.COUNT = 0 THEN
          p_line_rec.country_of_origin.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.country_of_origin.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.country_of_origin.EXTEND(x_table_count - l_count);
       END IF;
    END IF;

    l_count := p_line_rec.ship_from_location_id.COUNT;
    IF p_line_rec.ship_from_location_id.COUNT <> x_table_count THEN
       IF p_line_rec.ship_from_location_id.COUNT = 0 THEN
          p_line_rec.ship_from_location_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ship_from_location_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.ship_from_location_id.EXTEND(x_table_count - l_count);
       END IF;
    END IF;

    l_count := p_line_rec.ship_to_location_id.COUNT;
    IF p_line_rec.ship_to_location_id.COUNT <> x_table_count THEN
       IF p_line_rec.ship_to_location_id.COUNT = 0 THEN
          p_line_rec.ship_to_location_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ship_to_location_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.ship_to_location_id.EXTEND(x_table_count - l_count);
       END IF;
    END IF;

    l_count := p_line_rec.deliver_to_location_id.COUNT;
    IF p_line_rec.deliver_to_location_id.COUNT <> x_table_count THEN
       IF p_line_rec.deliver_to_location_id.COUNT = 0 THEN
          p_line_rec.deliver_to_location_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.deliver_to_location_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.deliver_to_location_id.EXTEND(x_table_count - l_count);
       END IF;
    END IF;

    l_count := p_line_rec.intmed_ship_to_location_id.COUNT;
    IF p_line_rec.intmed_ship_to_location_id.COUNT <> x_table_count THEN
       IF p_line_rec.intmed_ship_to_location_id.COUNT = 0 THEN
          p_line_rec.intmed_ship_to_location_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.intmed_ship_to_location_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.intmed_ship_to_location_id.EXTEND(x_table_count - l_count);
       END IF;
    END IF;

    l_count := p_line_rec.master_container_item_id.COUNT;
    IF p_line_rec.master_container_item_id.COUNT <> x_table_count THEN
       IF p_line_rec.master_container_item_id.COUNT = 0 THEN
          p_line_rec.master_container_item_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.master_container_item_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.master_container_item_id.EXTEND(x_table_count - l_count);
       END IF;
    END IF;

    l_count := p_line_rec.detail_container_item_id.COUNT;
    IF p_line_rec.detail_container_item_id.COUNT <> x_table_count THEN
       IF p_line_rec.detail_container_item_id.COUNT = 0 THEN
          p_line_rec.detail_container_item_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.detail_container_item_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.detail_container_item_id.EXTEND(x_table_count - l_count);
       END IF;
    END IF;

    l_count := p_line_rec.customer_item_id.COUNT;
    IF p_line_rec.customer_item_id.COUNT <> x_table_count THEN
       IF p_line_rec.customer_item_id.COUNT = 0 THEN
          p_line_rec.customer_item_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.customer_item_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.customer_item_id.EXTEND(x_table_count - l_count);
       END IF;
    END IF;

    l_count := p_line_rec.net_weight.COUNT;
    IF p_line_rec.net_weight.COUNT <> x_table_count THEN
       IF p_line_rec.net_weight.COUNT = 0 THEN
          p_line_rec.net_weight.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.net_weight.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.net_weight.EXTEND(x_table_count - l_count);
       END IF;
    END IF;

    l_count := p_line_rec.mvt_stat_status.COUNT;
    IF p_line_rec.mvt_stat_status.COUNT <> x_table_count THEN
       IF p_line_rec.mvt_stat_status.COUNT = 0 THEN
          p_line_rec.mvt_stat_status.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.mvt_stat_status.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.mvt_stat_status.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'count of p_line_recs p_del det id before extending it', p_line_rec.delivery_detail_id.count);
    END IF;

    l_count := p_line_rec.delivery_detail_id.COUNT;
    IF p_line_rec.delivery_detail_id.COUNT <> x_table_count THEN
       IF p_line_rec.delivery_detail_id.COUNT = 0 THEN
          p_line_rec.delivery_detail_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.delivery_detail_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.delivery_detail_id.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'count of p_line_recs p_del det id after extending it', p_line_rec.delivery_detail_id.count);
    END IF;

    l_count := p_line_rec.inspection_flag.COUNT;
    IF p_line_rec.inspection_flag.COUNT <> x_table_count THEN
       IF p_line_rec.inspection_flag.COUNT = 0 THEN
          p_line_rec.inspection_flag.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.inspection_flag.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.inspection_flag.EXTEND(x_table_count - l_count);
       END IF;
    END IF;

    l_count := p_line_rec.container_name.COUNT;
    IF p_line_rec.container_name.COUNT <> x_table_count THEN
       IF p_line_rec.container_name.COUNT = 0 THEN
          p_line_rec.container_name.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.container_name.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.container_name.EXTEND(x_table_count - l_count);
       END IF;
    END IF;

    l_count := p_line_rec.gross_weight.COUNT;
    IF p_line_rec.gross_weight.COUNT <> x_table_count THEN
       IF p_line_rec.gross_weight.COUNT = 0 THEN
          p_line_rec.gross_weight.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.gross_weight.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.gross_weight.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.seal_code.COUNT;
    IF p_line_rec.seal_code.COUNT <> x_table_count THEN
       IF p_line_rec.seal_code.COUNT = 0 THEN
          p_line_rec.seal_code.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.seal_code.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.seal_code.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.pickable_flag.COUNT;
    IF p_line_rec.pickable_flag.COUNT <> x_table_count THEN
       IF p_line_rec.pickable_flag.COUNT = 0 THEN
          p_line_rec.pickable_flag.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.pickable_flag.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'pickable_flag';
          RAISE e_extend_error;
       END IF;
    END IF;
    l_count := p_line_rec.source_line_set_id.COUNT;
    IF p_line_rec.source_line_set_id.COUNT <> x_table_count THEN
       IF p_line_rec.source_line_set_id.COUNT = 0 THEN
          p_line_rec.source_line_set_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.source_line_set_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.source_line_set_id.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.requested_quantity.COUNT;
    IF p_line_rec.requested_quantity.COUNT <> x_table_count THEN
       IF p_line_rec.requested_quantity.COUNT = 0 THEN
          p_line_rec.requested_quantity.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.requested_quantity.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.requested_quantity.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.requested_quantity2.COUNT;
    IF p_line_rec.requested_quantity2.COUNT <> x_table_count THEN
       IF p_line_rec.requested_quantity2.COUNT = 0 THEN
          p_line_rec.requested_quantity2.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.requested_quantity2.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.requested_quantity2.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.requested_quantity_uom2.COUNT;
    IF p_line_rec.requested_quantity_uom2.COUNT <> x_table_count THEN
       IF p_line_rec.requested_quantity_uom2.COUNT = 0 THEN
          p_line_rec.requested_quantity_uom2.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.requested_quantity_uom2.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.requested_quantity_uom2.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.cancelled_quantity.COUNT;
    IF p_line_rec.cancelled_quantity.COUNT <> x_table_count THEN
       IF p_line_rec.cancelled_quantity.COUNT = 0 THEN
          p_line_rec.cancelled_quantity.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.cancelled_quantity.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'cancelled_quantity';
          RAISE e_extend_error;
       END IF;
    END IF;
    l_count := p_line_rec.cancelled_quantity2.COUNT;
    IF p_line_rec.cancelled_quantity2.COUNT <> x_table_count THEN
       IF p_line_rec.cancelled_quantity2.COUNT = 0 THEN
          p_line_rec.cancelled_quantity2.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.cancelled_quantity2.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.cancelled_quantity2.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.source_line_number.COUNT;
    IF p_line_rec.source_line_number.COUNT <> x_table_count THEN
       IF p_line_rec.source_line_number.COUNT = 0 THEN
          p_line_rec.source_line_number.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.source_line_number.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.source_line_number.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.requested_quantity_uom.COUNT;
    IF p_line_rec.requested_quantity_uom.COUNT <> x_table_count THEN
       IF p_line_rec.requested_quantity_uom.COUNT = 0 THEN
          p_line_rec.requested_quantity_uom.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.requested_quantity_uom.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'requested_quantity_uom';
          RAISE e_extend_error;
       END IF;
    END IF;
    l_count := p_line_rec.revision.COUNT;
    IF p_line_rec.revision.COUNT <> x_table_count THEN
       IF p_line_rec.revision.COUNT = 0 THEN
          p_line_rec.revision.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.revision.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.revision.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.carrier_id.COUNT;
    IF p_line_rec.carrier_id.COUNT <> x_table_count THEN
       IF p_line_rec.carrier_id.COUNT = 0 THEN
          p_line_rec.carrier_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.carrier_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.carrier_id.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.tracking_number.COUNT;
    IF p_line_rec.tracking_number.COUNT <> x_table_count THEN
       IF p_line_rec.tracking_number.COUNT = 0 THEN
          p_line_rec.tracking_number.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.tracking_number.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.tracking_number.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.received_quantity.COUNT;
    IF p_line_rec.received_quantity.COUNT <> x_table_count THEN
       IF p_line_rec.received_quantity.COUNT = 0 THEN
          p_line_rec.received_quantity.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.received_quantity.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.received_quantity.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.received_quantity2.COUNT;
    IF p_line_rec.received_quantity2.COUNT <> x_table_count THEN
       IF p_line_rec.received_quantity2.COUNT = 0 THEN
          p_line_rec.received_quantity2.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.received_quantity2.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.received_quantity2.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.source_document_type_id.COUNT;
    IF p_line_rec.source_document_type_id.COUNT <> x_table_count THEN
       IF p_line_rec.source_document_type_id.COUNT = 0 THEN
          p_line_rec.source_document_type_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.source_document_type_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.source_document_type_id.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.latest_acceptable_date.COUNT;
    IF p_line_rec.latest_acceptable_date.COUNT <> x_table_count THEN
       IF p_line_rec.latest_acceptable_date.COUNT = 0 THEN
          p_line_rec.latest_acceptable_date.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.latest_acceptable_date.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'latest_acceptable_date';
          RAISE e_extend_error;
       END IF;
    END IF;
    l_count := p_line_rec.promise_date.COUNT;
    IF p_line_rec.promise_date.COUNT <> x_table_count THEN
       IF p_line_rec.promise_date.COUNT = 0 THEN
          p_line_rec.promise_date.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.promise_date.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'promise_date';
          RAISE e_extend_error;
       END IF;
    END IF;
    l_count := p_line_rec.schedule_arrival_date.COUNT;
    IF p_line_rec.schedule_arrival_date.COUNT <> x_table_count THEN
       IF p_line_rec.schedule_arrival_date.COUNT = 0 THEN
          p_line_rec.schedule_arrival_date.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.schedule_arrival_date.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'schedule_arrival_date';
          RAISE e_extend_error;
       END IF;
    END IF;
    l_count := p_line_rec.earliest_acceptable_date.COUNT;
    IF p_line_rec.earliest_acceptable_date.COUNT <> x_table_count THEN
       IF p_line_rec.earliest_acceptable_date.COUNT = 0 THEN
          p_line_rec.earliest_acceptable_date.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.earliest_acceptable_date.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'earliest_acceptable_date';
          RAISE e_extend_error;
       END IF;
    END IF;
   -- Added for Inbound Logistics
    l_count := p_line_rec.source_blanket_reference_id.COUNT;
    IF p_line_rec.source_blanket_reference_id.COUNT <> x_table_count THEN
       IF p_line_rec.source_blanket_reference_id.COUNT = 0 THEN
          p_line_rec.source_blanket_reference_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.source_blanket_reference_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.source_blanket_reference_id.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.source_blanket_reference_num.COUNT;
    IF p_line_rec.source_blanket_reference_num.COUNT <> x_table_count THEN
       IF p_line_rec.source_blanket_reference_num.COUNT = 0 THEN
          p_line_rec.source_blanket_reference_num.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.source_blanket_reference_num.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.source_blanket_reference_num.EXTEND(x_table_count - l_count);
       END IF;
    END IF;
    l_count := p_line_rec.vendor_id.COUNT;
    IF p_line_rec.vendor_id.COUNT <> x_table_count THEN
       IF p_line_rec.vendor_id.COUNT = 0 THEN
          p_line_rec.vendor_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.vendor_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.vendor_id.EXTEND(x_table_count - l_count);
       END IF;
     END IF;
    l_count := p_line_rec.ship_from_site_id.COUNT;
     IF p_line_rec.ship_from_site_id.COUNT <> x_table_count THEN
       IF p_line_rec.ship_from_site_id.COUNT = 0 THEN
          p_line_rec.ship_from_site_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ship_from_site_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.ship_from_site_id.EXTEND(x_table_count - l_count);
       END IF;
     END IF;
     l_count := p_line_rec.hold_code.COUNT;
     IF p_line_rec.hold_code.COUNT <> x_table_count THEN
       IF p_line_rec.hold_code.COUNT = 0 THEN
          p_line_rec.hold_code.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.hold_code.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.hold_code.EXTEND(x_table_count - l_count);
       END IF;
     END IF;
     l_count := p_line_rec.supplier_item_num.COUNT;
     IF p_line_rec.supplier_item_num.COUNT <> x_table_count THEN
       IF p_line_rec.supplier_item_num.COUNT = 0 THEN
          p_line_rec.supplier_item_num.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.supplier_item_num.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.supplier_item_num.EXTEND(x_table_count - l_count);
       END IF;
     END IF;
     l_count := p_line_rec.po_shipment_line_id.COUNT;
     IF p_line_rec.po_shipment_line_id.COUNT <> x_table_count THEN
       IF p_line_rec.po_shipment_line_id.COUNT = 0 THEN
          p_line_rec.po_shipment_line_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.po_shipment_line_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.po_shipment_line_id.EXTEND(x_table_count - l_count);
       END IF;
     END IF;
     l_count := p_line_rec.po_shipment_line_number.COUNT;
     IF p_line_rec.po_shipment_line_number.COUNT <> x_table_count THEN
       IF p_line_rec.po_shipment_line_number.COUNT = 0 THEN
          p_line_rec.po_shipment_line_number.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.po_shipment_line_number.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.po_shipment_line_number.EXTEND(x_table_count - l_count);
       END IF;
     END IF;
     l_count := p_line_rec.shipping_control.COUNT;
     IF p_line_rec.shipping_control.COUNT <> x_table_count THEN
       IF p_line_rec.shipping_control.COUNT = 0 THEN
          p_line_rec.shipping_control.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.shipping_control.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.shipping_control.EXTEND(x_table_count - l_count);
       END IF;
     END IF;
     l_count := p_line_rec.source_line_type_code.COUNT;
     IF p_line_rec.source_line_type_code.COUNT <> x_table_count THEN
       IF p_line_rec.source_line_type_code.COUNT = 0 THEN
          p_line_rec.source_line_type_code.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.source_line_type_code.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.source_line_type_code.EXTEND(x_table_count - l_count);
       END IF;
     END IF;
     l_count := p_line_rec.shipped_quantity.COUNT;
     IF p_line_rec.shipped_quantity.COUNT <> x_table_count THEN
       IF p_line_rec.shipped_quantity.COUNT = 0 THEN
          p_line_rec.shipped_quantity.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.shipped_quantity.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'shipped_quantity';
          RAISE e_extend_error;
       END IF;
     END IF;
     l_count := p_line_rec.shipped_quantity2.COUNT;
     IF p_line_rec.shipped_quantity2.COUNT <> x_table_count THEN
       IF p_line_rec.shipped_quantity2.COUNT = 0 THEN
          p_line_rec.shipped_quantity2.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.shipped_quantity2.EXTEND;
       ELSIF l_count < x_table_count THEN
          l_field_name := 'shipped_quantity2';
          RAISE e_extend_error;
       END IF;
     END IF;
    l_count := p_line_rec.consolidate_quantity.COUNT;
    IF p_line_rec.consolidate_quantity.COUNT <> x_table_count THEN
       IF p_line_rec.consolidate_quantity.COUNT = 0 THEN
          p_line_rec.consolidate_quantity.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.consolidate_quantity.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.consolidate_quantity.EXTEND(x_table_count - l_count);
       END IF;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'count of p_line_recs vendor_party_id before extending it', p_line_rec.vendor_party_id.COUNT);
      WSH_DEBUG_SV.log(l_module_name,'x_table_count', x_table_count);
    END IF;

     l_count := p_line_rec.vendor_party_id.COUNT;
     IF p_line_rec.vendor_party_id.COUNT <> x_table_count THEN
       IF p_line_rec.vendor_party_id.COUNT = 0 THEN
          p_line_rec.vendor_party_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.vendor_party_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.vendor_party_id.EXTEND(x_table_count - l_count);
       END IF;
     END IF;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'count of p_line_recs vendor_party_id after extending it', p_line_rec.vendor_party_id.COUNT);
    END IF;

     l_count := p_line_rec.Days_early_receipt_allowed.COUNT;
     IF p_line_rec.Days_early_receipt_allowed.COUNT <> x_table_count THEN
       IF p_line_rec.Days_early_receipt_allowed.COUNT = 0 THEN
          p_line_rec.Days_early_receipt_allowed.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.Days_early_receipt_allowed.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.Days_early_receipt_allowed.EXTEND(x_table_count - l_count);
       END IF;
     END IF;
     l_count := p_line_rec.Days_late_receipt_allowed.COUNT;
     IF p_line_rec.Days_late_receipt_allowed.COUNT <> x_table_count THEN
       IF p_line_rec.Days_late_receipt_allowed.COUNT = 0 THEN
          p_line_rec.Days_late_receipt_allowed.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.Days_late_receipt_allowed.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.Days_late_receipt_allowed.EXTEND(x_table_count - l_count);
       END IF;
     END IF;
     l_count := p_line_rec.drop_ship_flag.COUNT;
     IF p_line_rec.drop_ship_flag.COUNT <> x_table_count THEN
       IF p_line_rec.drop_ship_flag.COUNT = 0 THEN
          p_line_rec.drop_ship_flag.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.drop_ship_flag.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.drop_ship_flag.EXTEND(x_table_count - l_count);
       END IF;
     END IF;
     l_count := p_line_rec.intermed_ship_to_org_id.COUNT;
     IF p_line_rec.intermed_ship_to_org_id.COUNT <> x_table_count THEN
       IF p_line_rec.intermed_ship_to_org_id.COUNT = 0 THEN
          p_line_rec.intermed_ship_to_org_id.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.intermed_ship_to_org_id.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.intermed_ship_to_org_id.EXTEND(x_table_count - l_count);
       END IF;
     END IF;

     l_count := p_line_rec.po_revision.COUNT;
     IF p_line_rec.po_revision.COUNT <> x_table_count THEN
       IF p_line_rec.po_revision.COUNT = 0 THEN
          p_line_rec.po_revision.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.po_revision.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.po_revision.EXTEND(x_table_count - l_count);
       END IF;
     END IF;
     l_count := p_line_rec.release_revision.COUNT;
     IF p_line_rec.release_revision.COUNT <> x_table_count THEN
       IF p_line_rec.release_revision.COUNT = 0 THEN
          p_line_rec.release_revision.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.release_revision.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.release_revision.EXTEND(x_table_count - l_count);
       END IF;
     END IF;

     l_count := p_line_rec.ORDER_DATE_TYPE_CODE.COUNT;
     IF p_line_rec.ORDER_DATE_TYPE_CODE.COUNT <> x_table_count THEN
       IF p_line_rec.ORDER_DATE_TYPE_CODE.COUNT = 0 THEN
          p_line_rec.ORDER_DATE_TYPE_CODE.EXTEND(x_table_count);
       ELSIF nvl(p_action_prms.caller,'@@@') = 'WSH_IB_UTIL' THEN
          p_line_rec.ORDER_DATE_TYPE_CODE.EXTEND;
       ELSIF l_count < x_table_count THEN
          p_line_rec.ORDER_DATE_TYPE_CODE.EXTEND(x_table_count - l_count);
       END IF;
     END IF;



    IF nvl(p_action_prms.caller,'@@@') <> 'WSH_IB_UTIL' THEN
    --{
      x_additional_line_info_rec.RELEASED_STATUS.EXTEND(x_table_count)   ;
      x_additional_line_info_rec.inv_interfaced_flag.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute1.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute2.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute3.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute4.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute5.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute6.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute7.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute8.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute9.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute10.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute11.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute12.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute13.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute14.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute15.EXTEND(x_table_count);
      x_additional_line_info_rec.attribute_category.EXTEND(x_table_count);
      x_additional_line_info_rec.ignore_for_planning.EXTEND(x_table_count);
      x_additional_line_info_rec.earliest_pickup_date.EXTEND(x_table_count);
      x_additional_line_info_rec.latest_pickup_date.EXTEND(x_table_count);
      x_additional_line_info_rec.earliest_dropoff_date.EXTEND(x_table_count);
      x_additional_line_info_rec.latest_dropoff_date.EXTEND(x_table_count);
      x_additional_line_info_rec.service_level.EXTEND(x_table_count);
      x_additional_line_info_rec.mode_of_transport.EXTEND(x_table_count);
      x_additional_line_info_rec.cancelled_quantity2.EXTEND(x_table_count);
      x_additional_line_info_rec.cancelled_quantity.EXTEND(x_table_count);
      x_additional_line_info_rec.master_container_item_id.EXTEND(x_table_count);
      x_additional_line_info_rec.detail_container_item_id.EXTEND(x_table_count);
    --}
    END IF;
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has '
          || 'occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN e_extend_error THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      FND_MESSAGE.SET_NAME('WSH','WSH_TBL_EXTEND_ERR');
      FND_MESSAGE.SET_TOKEN('TBL_NAME',l_field_name);
      wsh_util_core.add_message(x_return_status, l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_field_name ',l_field_name);
        WSH_DEBUG_SV.log(l_module_name,'l_count ',l_count);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:e_extend_error');
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. ' ||
        'Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING '||
           'exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --

    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_BULK_PROCESS_PVT.Extend_tables');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
           'Oracle error message is '||
           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;


  END Extend_tables;



--========================================================================
-- PROCEDURE : Validate_lines
--
-- PARAMETERS: p_line_rec              Line record
--             p_action_prms           Additional attributes needed
--             x_table_count           Size of each table
--             x_additional_line_info_rec Local record that is extended
--                                     and ready to use to store  additional
--                                     information for line record.
--             x_valid_rec_exist       set to 1, if any record was validated
--                                     successfully
--             x_eligible_rec_exist    set to 1, if any eligible record exists.
--             x_return_status         return status
-- COMMENT   : This procedure goes through the tables in p_line_rec and
--             validates them.  If the validation is successful, a 'Y' will
--             be set in the table p_line_rec.shipping_interfaced_flag
--========================================================================


  PROCEDURE Validate_lines(
           p_line_rec      IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
           P_action_prms   IN OUT NOCOPY
                           WSH_BULK_TYPES_GRP.action_parameters_rectype,
           p_additional_line_info_rec   IN  OUT NOCOPY
                                           additional_line_info_rec_type ,
           x_valid_rec_exist  OUT NOCOPY NUMBER ,
           x_eligible_rec_exist OUT NOCOPY NUMBER ,
           X_return_status  OUT  NOCOPY VARCHAR2
  )
  IS
    l_debug_on BOOLEAN;
    --

    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
               '.' || 'VALIDATE_LINES';
    l_return_status     VARCHAR2(1);
    l_num_warnings      NUMBER := 0;
    l_num_errors        NUMBER := 0;
    l_dff_attribute     WSH_FLEXFIELD_UTILS.FlexfieldAttributeTabType ;
    l_dff_context       VARCHAR2(150);
    l_dff_update_flag   VARCHAR2(1);
    l_rec_count         NUMBER;
    l_stack_size_start  NUMBER;
    l_first             NUMBER;
    l_tp_is_installed   VARCHAR2(10);
    l_otm_is_installed  VARCHAR2(10);
    l_cache_tbl         wsh_util_core.char500_tab_type;
    l_cache_ext_tbl     wsh_util_core.char500_tab_type;
    l_index             NUMBER;
    l_caller		varchar2(2000);
    --OTM R12 Org-Specific
    l_gc3_is_installed  VARCHAR2(1);

    e_next_line         EXCEPTION;
  BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --

    IF l_debug_on THEN
       wsh_debug_sv.push (l_module_name);
       WSH_DEBUG_SV.log(l_module_name,'caller ',p_action_prms.caller);
       WSH_DEBUG_SV.log(l_module_name,'p_action_prms.org_id',
                                                  p_action_prms.org_id);
       WSH_DEBUG_SV.log(l_module_name,'line_rec org_id ',p_line_rec.org_id(p_line_rec.org_id.FIRST));
       WSH_DEBUG_SV.log(l_module_name,'l_gc3_is_installed ',l_gc3_is_installed); --OTM R12 Org-Specific.
    END IF;

    --OTM R12 Org-Specific start.
    l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;
    IF l_gc3_is_installed IS NULL THEN
      l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
    END IF;
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_gc3_is_installed ',l_gc3_is_installed);
    END IF;
    --OTM R12 End

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    x_valid_rec_exist := 0;
    x_eligible_rec_exist := 0;

    WSH_ACTIONS_LEVELS.set_validation_level (
      p_entity        => 'DLVB',
      p_caller        => p_action_prms.caller,
      p_phase         => nvl(p_action_prms.phase,1),
      p_action        => p_action_prms.action_code,
      x_return_status => l_return_status);
    --
    wsh_util_core.api_post_call(
      p_return_status    => l_return_status,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);


    IF p_action_prms.caller = 'OM' THEN
       p_additional_line_info_rec.source_code := 'OE';
    ELSIF p_action_prms.caller = 'PO' THEN
       p_additional_line_info_rec.source_code := 'PO';
       p_action_prms.org_id := p_line_rec.org_id(p_line_rec.org_id.FIRST);
    ELSIF p_action_prms.caller = 'OKE' THEN
       p_additional_line_info_rec.source_code := 'OKE';
       p_action_prms.org_id := p_line_rec.org_id(p_line_rec.org_id.FIRST);
    ELSE
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'bad caller ',p_action_prms.caller);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_action_prms.org_id IS NULL THEN
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'org_id is not passed ',
                                                  WSH_DEBUG_SV.C_EXCEP_LEVEL);
       END IF;
       FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
       FND_MESSAGE.SET_TOKEN('FIELD_NAME','ORG_ID');
       wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,
                                                              l_module_name);
       RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_POPULATE_ORGANIZATION_ID) = 1
    THEN
       l_index := p_line_rec.ship_from_org_id.FIRST;
       WHILE l_index IS NOT NULL LOOP
          p_line_rec.organization_id(l_index) :=
                                         p_line_rec.ship_from_org_id(l_index);
          l_index := p_line_rec.ship_from_org_id.NEXT(l_index);
       END LOOP;
--bms what to do for inbound
    END IF;

    l_tp_is_installed := wsh_util_core.tp_is_installed ;
    l_otm_is_installed := wsh_util_core.gc3_is_installed ;
    IF l_tp_is_installed = 'Y' OR l_otm_is_installed = 'Y' THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_tp_is_installed',l_tp_is_installed);
       END IF;
    ELSE
       l_tp_is_installed := 'N';
    END IF;

    WSH_FLEXFIELD_UTILS.Get_DFF_Defaults
      (p_flexfield_name    => 'WSH_DELIVERY_DETAILS',
       p_default_values    => l_dff_attribute,
       p_default_context   => l_dff_context,
       p_update_flag       => l_dff_update_flag,
       x_return_status     => l_return_status);

    wsh_util_core.api_post_call(
      p_return_status    => l_return_status,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);

    l_rec_count := p_line_rec.line_id.COUNT;
    l_first := p_line_rec.line_id.FIRST;

    FOR i in l_first..l_rec_count LOOP --{
     BEGIN --{

        IF NVL(p_line_rec.shipping_eligible_flag(i), 'N') <> 'Y' THEN
           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Not processing line ',
                                               p_line_rec.line_id(i));
           END IF;
           RAISE e_next_line;
        END IF;
        x_eligible_rec_exist :=  x_eligible_rec_exist + 1;

        Set_message(
           p_line_rec         =>p_line_rec,
           p_index            =>i,
           p_caller           =>p_action_prms.caller,
           p_first_call       => 'T',
           x_stack_size_start => l_stack_size_start,
           x_return_status    => l_return_status
        );

       IF p_line_rec.source_document_type_id(i) = 10 THEN
          p_line_rec.shipping_interfaced_flag(i) := 'N';
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Internal orders are not supported'
                                      ,p_line_rec.source_document_type_id(i));
          END IF;
       END IF;

       IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_VALIDATE_OKE_NULL_FIELDS_LVL) = 1
       THEN
          check_null_fields(p_line_rec      => p_line_rec,
                                p_index         => i,
                                x_return_status => l_return_status);

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
            AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
          THEN
             p_line_rec.shipping_interfaced_flag(i) := 'N';
          END IF;
       END IF;

       IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_GET_SHIP_FROM_LOC_LVL) = 1
       THEN
          WSH_UTIL_CORE.GET_LOCATION_ID('ORG',
                                         p_line_rec.organization_id(i),
                                         p_line_rec.ship_from_location_id(i),
                                         l_return_status);
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
            AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
          THEN
             p_line_rec.shipping_interfaced_flag(i) := 'N';
          END IF;
       END IF;


       IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_GET_SHIPTO_LOC_LVL) = 1
       THEN
          WSH_UTIL_CORE.GET_LOCATION_ID('CUSTOMER SITE',
                                         p_line_rec.ship_to_org_id(i),
                                         p_line_rec.ship_to_location_id(i),
                                         l_return_status);
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
            AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
          THEN
             p_line_rec.shipping_interfaced_flag(i) := 'N';
          END IF;
       END IF;

       IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_GET_DELIVER_TO_LOC_LVL) = 1
       THEN
          IF p_line_rec.deliver_to_org_id(i) IS NOT NULL THEN
             WSH_UTIL_CORE.GET_LOCATION_ID('CUSTOMER SITE',
                                         p_line_rec.deliver_to_org_id(i),
                                         p_line_rec.deliver_to_location_id(i),
                                         l_return_status);
             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
               AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
             THEN
                p_line_rec.shipping_interfaced_flag(i) := 'N';
             END IF;

          ELSE
             p_line_rec.deliver_to_location_id(i) :=
                                         p_line_rec.ship_to_location_id(i);
          END IF;
       END IF;


       IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_GET_INTMED_SHIPTO_LOC_LVL) = 1
       THEN
          IF p_line_rec.intermed_ship_to_org_id(i) IS NOT NULL THEN
             WSH_UTIL_CORE.GET_LOCATION_ID('CUSTOMER SITE',
                                       p_line_rec.intermed_ship_to_org_id(i),
                                       p_line_rec.intmed_ship_to_location_id(i),
                                      l_return_status);
             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
               AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
             THEN
                p_line_rec.shipping_interfaced_flag(i) := 'N';
             END IF;
          END IF;
       END IF;


       IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_VALIDATE_SHIP_FROM_LOC_LVL) = 1
       THEN
          l_caller := null;
          IF (p_action_prms.caller = 'PO') THEN
            l_caller:='PO';
          END IF;

          wsh_util_validate.validate_location(
                       p_location_id   => p_line_rec.ship_from_location_id(i),
                       p_caller	       => l_caller,
                       x_return_status => l_return_status,
                       p_isWshLocation => FALSE);

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
            AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
          THEN
             p_line_rec.shipping_interfaced_flag(i) := 'N';
          END IF;
       END IF;



       IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_VALIDATE_SHIPTO_LOC_LVL) = 1
       THEN
          l_caller := null;
          IF (p_action_prms.caller = 'PO') THEN
            l_caller:='PO';
          END IF;

          wsh_util_validate.validate_location(
                       p_location_id   => p_line_rec.ship_to_location_id(i),
                       p_caller        => l_caller,
                       x_return_status => l_return_status,
                       p_isWshLocation => FALSE);

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
            AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
          THEN
             p_line_rec.shipping_interfaced_flag(i) := 'N';
          END IF;
       END IF;

       IF p_action_prms.caller <> 'PO' THEN

         Calc_wt_vol_qty(p_line_rec      => p_line_rec,
                       p_additional_line_info_rec => p_additional_line_info_rec,
                       p_index         => i,
                       p_action_prms   => p_action_prms,
                       x_return_status => l_return_status);


          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
            AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
          THEN
             p_line_rec.shipping_interfaced_flag(i) := 'N';
          END IF;
       END IF;



       wsh_util_validate.Calc_ignore_for_planning(
                          p_organization_id => p_line_rec.organization_id(i),
                          p_carrier_id      => p_line_rec.carrier_id(i),
                          p_ship_method_code=>
                                           p_line_rec.shipping_method_code(i),
                          p_tp_installed    => l_tp_is_installed,
                          p_caller          => p_action_prms.caller,
                          x_ignore_for_planning =>
                              p_additional_line_info_rec.ignore_for_planning(i),
                          x_return_status   => l_return_status,
                          p_otm_installed   => l_gc3_is_installed); --OTM R12 Org-Specific.
        --OTM R12 Org-Specific start.
        IF (l_debug_on) THEN
          wsh_debug_sv.log(l_module_name,'ignore_for_planning(i) ',
                           p_additional_line_info_rec.ignore_for_planning(i));
          wsh_debug_sv.log(l_module_name,'l_return_status ',l_return_status);
        END IF;
        --OTM R12 End.
--added for Inbound Logistics
--{
        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PO_DERIVE_DROPSHIP_LVL) = 1
           AND  p_line_rec.drop_ship_flag(i) = 'Y' THEN
           WSH_INBOUND_UTIL_PKG.get_drop_ship_info(
             p_line_rec => p_line_rec,
             p_index =>i,
             x_return_status => l_return_status
             );
           wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_num_warnings,
             x_num_errors    => l_num_errors);

        END IF;


       IF p_action_prms.caller <> 'PO' OR
	  (p_action_prms.caller = 'PO' and p_line_rec.drop_ship_flag(i) = 'Y' ) THEN
       --{
         IF p_line_rec.shipping_method_code(i) IS NOT NULL THEN --{

	   --Call to API calc_service_mode. This call is made because PO does not capture
	   --ship method code, but OM passes ship method code. This API takes care of decomposing
	   --the ship method code to get the carrier, service level and ship method code.
           calc_service_mode(
                       p_line_rec         => p_line_rec,
                     --p_ship_method_code => p_line_rec.shipping_method_code(i),
                       p_cache_tbl        => l_cache_tbl,
                       p_cache_ext_tbl    => l_cache_ext_tbl,
                       p_index            => i,
                       p_additional_line_info_rec   =>
                                   p_additional_line_info_rec,
                       x_return_status   => l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
               AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
           THEN
                   p_line_rec.shipping_interfaced_flag(i) := 'N';
           END IF;
         END IF; --}
       --}
       END IF;
--
--}

       IF p_action_prms.caller <> 'PO' THEN --{
          wsh_tp_release.calculate_tp_dates(

                 p_request_date_type      =>
                            p_line_rec.ORDER_DATE_TYPE_CODE(i),
                 p_latest_acceptable_date =>
                            p_line_rec.latest_acceptable_date(i),
                 p_promise_date           =>
                            p_line_rec.promise_date(i),
                 p_schedule_arrival_date  =>
                            p_line_rec.schedule_arrival_date(i),
                 p_schedule_ship_date     =>
                            p_line_rec.schedule_ship_date(i),
                 p_earliest_acceptable_date =>
                            p_line_rec.earliest_acceptable_date(i),
                 p_demand_satisfaction_date =>
                            NULL,
                 p_source_line_id           =>
                            p_line_rec.line_id(i),
                 p_source_code              =>
                            p_additional_line_info_rec.source_code,
                 p_organization_id          =>
                             p_line_rec.organization_id(i),
                 p_inventory_item_id        =>
                            p_line_rec.inventory_item_id(i),
                 x_return_status            =>
                            l_return_status,
                 x_earliest_pickup_date     =>
                            p_additional_line_info_rec.earliest_pickup_date(i),
                 x_latest_pickup_date       =>
                            p_additional_line_info_rec.latest_pickup_date(i),
                 x_earliest_dropoff_date    =>
                            p_additional_line_info_rec.earliest_dropoff_date(i),
                 x_latest_dropoff_date      =>
                            p_additional_line_info_rec.latest_dropoff_date(i));

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
               AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
          THEN
             IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,
                                              'Error in calculating TP dates');
             END IF;
             p_line_rec.shipping_interfaced_flag(i) := 'N';
             FND_MESSAGE.SET_NAME('WSH','WSH_CALC_TP_DATES');
             WSH_UTIL_CORE.Add_Message(l_return_status,l_module_name);
          END IF;
          --skattama
          IF (p_additional_line_info_rec.earliest_pickup_date(i) > p_additional_line_info_rec.latest_pickup_date(i)) THEN
            p_additional_line_info_rec.latest_pickup_tpdate_excep(i) := p_additional_line_info_rec.latest_pickup_date(i);
            p_additional_line_info_rec.latest_pickup_date(i) := p_additional_line_info_rec.earliest_pickup_date(i);
          END IF;

          IF (p_additional_line_info_rec.earliest_dropoff_date(i) > p_additional_line_info_rec.latest_dropoff_date(i)) THEN
            p_additional_line_info_rec.latest_dropoff_tpdate_excep(i) := p_additional_line_info_rec.latest_dropoff_date(i);
            p_additional_line_info_rec.latest_dropoff_date(i) := p_additional_line_info_rec.earliest_dropoff_date(i);
          END IF;
          --skattama
       END IF ; --}

       -- Added for Inbound Logistics
       --{


        IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PO_CHECK_ORGID_LVL) = 1
	THEN

    	   IF p_line_rec.org_id(i) <> p_line_rec.org_id(p_line_rec.org_id.FIRST) then
             FND_MESSAGE.SET_NAME('WSH','WSH_ORG_ID_INVALID');
             WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR);
	     RAISE FND_API.G_EXC_ERROR;
    	   END IF;
  	END IF;

	IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PO_DEFAULT_SHIPFROM_LVL)=1
	THEN
     	   p_line_rec.ship_from_location_id(i) := -1;
     	   p_line_rec.vendor_party_id(i) := l_vendor_party_id;
        END IF;

	IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PO_VALIDATE_MAN_FIELDS_LVL) = 1
  	THEN
  	   validate_mandatory_info(
             p_line_rec  =>  p_line_rec ,
             p_index =>i,
             x_return_status => l_return_status
             );

	   wsh_util_core.api_post_call(
	     p_return_status => l_return_status,
	     x_num_warnings  => l_num_warnings,
	     x_num_errors    => l_num_errors);
  	END IF;
/* Moved the call to dervie drop ship info before calling calc_service_mode.
p_line_rec.shipping_method_code is populated only ion get_drop_ship_info API.
*/

/*	IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PO_DERIVE_DROPSHIP_LVL) = 1
	   AND  p_line_rec.drop_ship_flag(p_line_rec.drop_ship_flag.FIRST) = 'Y' THEN
  	   WSH_INBOUND_UTIL_PKG.get_drop_ship_info(
             p_line_rec => p_line_rec,
             p_index =>i,
             x_return_status => l_return_status
             );
	   wsh_util_core.api_post_call(
	     p_return_status => l_return_status,
	     x_num_warnings  => l_num_warnings,
	     x_num_errors    => l_num_errors);

	END IF;
*/
	IF  WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PO_VALIDATE_SHPTO_LOC_LVL) = 1
	THEN
           l_caller := null;
          IF (p_action_prms.caller = 'PO') THEN
            l_caller:='PO';
          END IF;

   	   wsh_util_validate.validate_location(
             p_location_id   => p_line_rec.ship_to_location_id(i),
             p_caller	     => l_caller,
             x_return_status => l_return_status,
             p_isWshLocation => FALSE);

	   wsh_util_core.api_post_call(
	     p_return_status => l_return_status,
	     x_num_warnings  => l_num_warnings,
	     x_num_errors    => l_num_errors);

        END IF;

	IF ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PO_VALIDATE_FOB_LVL)= 1 )
	   AND ( p_line_rec.fob_point_code(i) IS NOT NULL ) --condition added for bugfix 3679513
 	THEN
   	   WSH_UTIL_VALIDATE.validate_fob(
             p_fob           => p_line_rec.fob_point_code(i),
             x_return_status => l_return_status);

	   wsh_util_core.api_post_call(
	     p_return_status => l_return_status,
	     x_num_warnings  => l_num_warnings,
	     x_num_errors    => l_num_errors);
	END IF;

	IF (WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PO_VALIDATE_FR_TERMS_LVL) = 1)
	   AND (p_line_rec.freight_terms_code(i) IS NOT NULL) --condition added for bugfix 3679513
        THEN
           WSH_UTIL_VALIDATE.validate_freight_terms(
             p_freight_terms_code   => p_line_rec.freight_terms_code(i),
             x_return_status        => l_return_status);

	   wsh_util_core.api_post_call(
	     p_return_status => l_return_status,
	     x_num_warnings  => l_num_warnings,
	     x_num_errors    => l_num_errors);

        END IF;

	IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PO_CALC_WT_VOL_LVL) = 1  THEN
        --{
         IF p_line_rec.inventory_item_id(i) IS NOT NULL THEN
         --{
           Calc_wt_vol_qty(p_line_rec   => p_line_rec,
             p_additional_line_info_rec => p_additional_line_info_rec,
             p_index         => i,
             p_action_prms   => p_action_prms,
             x_return_status => l_return_status);

           wsh_util_core.api_post_call(
             p_return_status => l_return_status,
             x_num_warnings  => l_num_warnings,
             x_num_errors    => l_num_errors);
         ELSIF (p_line_rec.inventory_item_id(i) is NULL) THEN
           IF (p_line_rec.requested_quantity(i) is null ) THEN
             p_line_rec.requested_quantity_uom(i) :=
                                      p_line_rec.order_quantity_uom(i);
             p_line_rec.requested_quantity(i) :=
                                      p_line_rec.ordered_quantity(i);
             p_additional_line_info_rec.inv_interfaced_flag(i) := 'X';
           END IF;
         --}
         END IF;
        --}
        END IF;
--}
-- HW 3064890 Added AND condition
-- The calc_wt_vol_qty has been modified for OPM.So the following call is not
-- needed.

-- HW OPMCONV - Removed call to get_opm_quantity. This call
-- was commented earlier. So, it's a clean up

       IF p_action_prms.caller = 'OM' THEN --{

          IF p_line_rec.item_identifier_type(i) = 'CUST' THEN
             P_line_rec.customer_item_id(i) := p_line_rec.ordered_item_id(i);
          END IF;

          IF p_line_rec.pickable_flag(i) = 'Y' THEN
             p_additional_line_info_rec.RELEASED_STATUS(i) := 'R';
          ELSE
             p_additional_line_info_rec.RELEASED_STATUS(i) := 'X';
          END IF;

          P_line_rec.mvt_stat_status(i) := 'NEW';
          P_line_rec.original_subinventory(i) := p_line_rec.subinventory(i);
          p_additional_line_info_rec.cancelled_quantity2(i) := NULL;
          p_additional_line_info_rec.cancelled_quantity(i) := NULL;

       ELSE --}{
          p_additional_line_info_rec.RELEASED_STATUS(i) := 'X';
          IF p_line_rec.request_date(i) IS NULL THEN
             P_line_rec.request_date(i) := p_line_rec.schedule_ship_date(i);
          END IF;
          p_additional_line_info_rec.earliest_dropoff_date(i):=
             (NVL(p_line_rec.schedule_ship_date(i),p_line_rec.request_date(i)) -
              NVL(p_line_rec.Days_early_receipt_allowed(i),0));

          p_additional_line_info_rec.latest_dropoff_date(i) :=
             (NVL(p_line_rec.schedule_ship_date(i),p_line_rec.request_date(i)) +
              NVL(p_line_rec.Days_late_receipt_allowed(i),0));
       END IF; --}

       IF (l_dff_update_flag = 'Y')  AND ( WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_DEFAULT_FLEX_LVL) = 1)
       THEN --{
          IF p_action_prms.caller = 'OM' THEN --{
             p_additional_line_info_rec.attribute_category(i) := l_dff_context ;
             p_additional_line_info_rec.attribute1(i) :=l_dff_attribute(1);
             p_additional_line_info_rec.attribute2(i) :=l_dff_attribute(2);
             p_additional_line_info_rec.attribute3(i) :=l_dff_attribute(3);
             p_additional_line_info_rec.attribute4(i) :=l_dff_attribute(4);
             p_additional_line_info_rec.attribute5(i) :=l_dff_attribute(5);
             p_additional_line_info_rec.attribute6(i) :=l_dff_attribute(6);
             p_additional_line_info_rec.attribute7(i) :=l_dff_attribute(7);
             p_additional_line_info_rec.attribute8(i) :=l_dff_attribute(8);
             p_additional_line_info_rec.attribute9(i) :=l_dff_attribute(9);
             p_additional_line_info_rec.attribute10(i) :=l_dff_attribute(10);
             p_additional_line_info_rec.attribute11(i) := l_dff_attribute(11);
             p_additional_line_info_rec.attribute12(i) :=l_dff_attribute( 12);
             p_additional_line_info_rec.attribute13(i) :=l_dff_attribute(13);
             p_additional_line_info_rec.attribute14(i) :=l_dff_attribute(14);
             p_additional_line_info_rec.attribute15(i) :=l_dff_attribute(15);

          ELSE --}{
             p_additional_line_info_rec.attribute_category(i) :=
                                    nvl(p_line_rec.context(i),l_dff_context ) ;
             p_additional_line_info_rec.attribute1(i) :=
                             nvl(p_line_rec.attribute1(i),l_dff_attribute(1));
             p_additional_line_info_rec.attribute2(i) :=
                            nvl(p_line_rec.attribute2(i),l_dff_attribute(2) );
             p_additional_line_info_rec.attribute3(i) :=
                          nvl(p_line_rec.attribute3(i), l_dff_attribute( 3) );
             p_additional_line_info_rec.attribute4(i) :=
                          nvl(p_line_rec.attribute4(i), l_dff_attribute( 4) );
             p_additional_line_info_rec.attribute5(i) :=
                           nvl(p_line_rec.attribute5(i), l_dff_attribute( 5) );
             p_additional_line_info_rec.attribute6(i) :=
                           nvl(p_line_rec.attribute6(i), l_dff_attribute( 6) );
             p_additional_line_info_rec.attribute7(i) :=
                           nvl(p_line_rec.attribute7(i), l_dff_attribute( 7) );
             p_additional_line_info_rec.attribute8(i) :=
                           nvl(p_line_rec.attribute8(i), l_dff_attribute( 8) );
             p_additional_line_info_rec.attribute9(i) :=
                           nvl(p_line_rec.attribute9(i), l_dff_attribute( 9) );
             p_additional_line_info_rec.attribute10(i) :=
                          nvl(p_line_rec.attribute10(i), l_dff_attribute( 10));
             p_additional_line_info_rec.attribute11(i) :=
                          nvl(p_line_rec.attribute11(i), l_dff_attribute( 11));
             p_additional_line_info_rec.attribute12(i) :=
                          nvl(p_line_rec.attribute12(i), l_dff_attribute( 12));
             p_additional_line_info_rec.attribute13(i) :=
                          nvl(p_line_rec.attribute13(i), l_dff_attribute( 13));
             p_additional_line_info_rec.attribute14(i) :=
                          nvl(p_line_rec.attribute14(i), l_dff_attribute( 14));
             p_additional_line_info_rec.attribute15(i) :=
                          nvl(p_line_rec.attribute15(i), l_dff_attribute( 15));

          END IF; --}
       END IF; --}
       IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_DEFAULT_CONTAINEER_LVL) = 1 THEN
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'ordered_item_id ',
                                               p_line_rec.ordered_item_id(i));
          END IF;
          IF (p_line_rec.ordered_item_id(i) IS NOT NULL) AND (p_line_rec.item_identifier_type(i) = 'CUST') THEN
             wsh_util_validate.default_container(
                              p_item_id => p_line_rec.ordered_item_id(i) ,
                              x_master_container_item_id =>
                         p_additional_line_info_rec.master_container_item_id(i),
                              x_detail_container_item_id =>
                         p_additional_line_info_rec.detail_container_item_id(i),
                              x_return_status  => l_return_status);

             IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
               AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
             THEN
                p_line_rec.shipping_interfaced_flag(i) := 'N';
             END IF;
          END IF;
       END IF;

       IF nvl(p_line_rec.shipping_interfaced_flag(i) ,'-') <> 'N' THEN
          p_line_rec.shipping_interfaced_flag(i) := 'Y';
          x_valid_rec_exist :=  1;
       ELSE
          p_additional_line_info_rec.released_status(i) := 'D';
       END IF;

       Set_message(
             p_line_rec         =>p_line_rec,
             p_index            =>i,
             p_caller           =>p_action_prms.caller,
             p_first_call       => 'F',
             x_stack_size_start => l_stack_size_start,
             x_return_status    => l_return_status
          );


     EXCEPTION

       WHEN e_next_line THEN
         p_additional_line_info_rec.released_status(i) := 'D';
         p_line_rec.shipping_interfaced_flag(i) := 'N';
     END; --}

    END LOOP; --}


    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has '
          || 'occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. ' ||
        'Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING '||
           'exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --

    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_BULK_PROCESS_PVT.Validate_lines');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
           'Oracle error message is '||
           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

  END Validate_lines ;



--========================================================================
-- PROCEDURE : bulk_insert_details
--
-- PARAMETERS: p_line_rec              Line record
--             p_action_prms           Additional attributes needed
--             p_additional_line_info_rec Local record that is extended
--                                     and ready to use to store  additional
--                                     information for line record.
--             x_return_status         return status
-- COMMENT   : This procedure will bulk insert the records into tables
--              wsh_delivery_details and wsh_delivery_assignments_v
--========================================================================


  PROCEDURE bulk_insert_details (
           P_line_rec                 IN   OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
	   p_index                    IN   NUMBER,
           p_action_prms              IN   WSH_BULK_TYPES_GRP.action_parameters_rectype,
           p_additional_line_info_rec IN   additional_line_info_rec_type ,
           X_return_status            OUT  NOCOPY VARCHAR2
  )
  IS
    l_debug_on                  BOOLEAN;
    --
    l_module_name               CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
               '.' || 'BULK_INSERT_DETAILS';
    l_fnd_global_user_id        NUMBER := FND_GLOBAL.USER_ID;
    l_sysdate                   DATE;
    l_line_rec_count            NUMBER;
    l_rec_inserted_count        NUMBER;
    l_valid_ids                 wsh_util_core.Id_Tab_Type;
    l_invalid_ids               wsh_util_core.Id_Tab_Type;
    l_first                     NUMBER;
    l_last		        NUMBER;
    l_count                     NUMBER;
    l_eligible_count            NUMBER := 0;
    i                           NUMBER;
-- HW OPM BUG#:3064890 HVOP for OPM
 -- HW OPMCONV. Removed OPM variable

    l_del_det_id_tab            OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM();
    l_detail_tab                WSH_UTIL_CORE.id_tab_type; -- DBI Project
    l_dbi_rs                    VARCHAR2(1); -- Return Status from DBI API
-- end of changes for 3064890

    --OTM R12
    l_delivery_detail_tab	WSH_ENTITY_INFO_TAB;
    l_return_status		VARCHAR2(1);
    l_item_quantity_uom_tab	WSH_UTIL_CORE.COLUMN_TAB_TYPE;
    l_gc3_is_installed          VARCHAR2(1);
    l_tab_index                 NUMBER;
    --
    l_otm_installed VARCHAR2(1) ;
    e_success       EXCEPTION;

  BEGIN
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'number of rows inserting ',
                                                            l_line_rec_count);
      WSH_DEBUG_SV.log(l_module_name,'p_index ', p_index);
    END IF;

    l_otm_installed := WSH_UTIL_CORE.Get_Otm_Install_Profile_Value;
    IF l_otm_installed IN ( 'Y','P')
      AND NVL(p_action_prms.caller,'PO') <> 'OM'
    THEN
       RAISE e_success;
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    --OTM R12 initialize
    l_count := 0;
    l_tab_index := 1;
    i := 0;
    l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;
    IF l_gc3_is_installed IS NULL THEN
      l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
    END IF;
    IF (l_gc3_is_installed = 'Y') THEN
      l_delivery_detail_tab := WSH_ENTITY_INFO_TAB();
    END IF;
    --

    l_sysdate := SYSDATE;
    l_first := p_line_rec.line_id.FIRST; --always 1

    --Added for Inbound logistics

    IF p_index IS NULL THEN
       l_line_rec_count := p_line_rec.line_id.COUNT;
       l_first := p_line_rec.line_id.FIRST;
       l_last := l_line_rec_count;
       IF l_line_rec_count > 0 THEN
         l_del_det_id_tab.extend(l_line_rec_count);
       END IF;
    ELSE
       l_line_rec_count := 1;
       l_first := p_index;
       l_last := p_index;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'requested_quantity of line being inserted is', p_line_rec.requested_quantity(p_index));
      END IF;
    END IF;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'count of p_line_recs p_del det id ', p_line_rec.delivery_detail_id.count);
      WSH_DEBUG_SV.log(l_module_name,'l_first', l_first);
      WSH_DEBUG_SV.log(l_module_name,'l_last', l_last);
    END IF;


    FORALL i in l_first..l_last
       INSERT INTO wsh_delivery_details(
          source_code,
          source_header_id,
          source_line_id,
          customer_id,
          sold_to_contact_id,
          inventory_item_id,
          item_description,
          hazard_class_id,
          country_of_origin,
          ship_from_location_id,
          ship_to_location_id,
          ship_to_contact_id,
          ship_to_site_use_id,
          deliver_to_location_id,
          deliver_to_contact_id,
          deliver_to_site_use_id,
          intmed_ship_to_location_id,
          intmed_ship_to_contact_id,
          ship_tolerance_above,
          ship_tolerance_below,
          requested_quantity,
          requested_quantity_uom,
          subinventory,
          revision,
          date_requested,
          date_scheduled,
          master_container_item_id,
          detail_container_item_id,
          ship_method_code,
          carrier_id,
          freight_terms_code,
          shipment_priority_code,
          fob_code,
          customer_item_id,
          dep_plan_required_flag,
          customer_prod_seq,
          customer_dock_code,
          cust_model_serial_number,
          customer_job,
          customer_production_line,
          net_weight,
          weight_uom_code,
          volume,
          volume_uom_code,
          tp_attribute_category,
          tp_attribute1,
          tp_attribute2,
          tp_attribute3,
          tp_attribute4,
          tp_attribute5,
          tp_attribute6,
          tp_attribute7,
          tp_attribute8,
          tp_attribute9,
          tp_attribute10,
          tp_attribute11,
          tp_attribute12,
          tp_attribute13,
          tp_attribute14,
          tp_attribute15,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          created_by,
          creation_date,
          last_update_date,
          last_update_login,
          last_updated_by,
          program_application_id,
          program_id,
          program_update_date,
          mvt_stat_status,
          organization_id,
          ship_set_id,
          arrival_set_id,
          ship_model_complete_flag,
          top_model_line_id,
          source_header_number,
          source_header_type_id,
          source_header_type_name,
          cust_po_number,
          ato_line_id,
          src_requested_quantity,
          src_requested_quantity_uom,
          cancelled_quantity,
          tracking_number,
          shipping_instructions,
          packing_instructions,
          project_id,
          task_id,
          org_id,
          oe_interfaced_flag,
          inv_interfaced_flag,
          source_line_number,
          inspection_flag,
          released_status,
          delivery_detail_id,
          container_flag,
          gross_weight,
          seal_code,
          unit_number,
          unit_price,
          currency_code,
          --freight_class_cat_id,
          --commodity_code_cat_id,
          preferred_grade,
          src_requested_quantity2,
          src_requested_quantity_uom2,
          requested_quantity2,
          cancelled_quantity2,
          requested_quantity_uom2,
          pickable_flag,
          original_subinventory,
          received_quantity,
          received_quantity2,
          source_line_set_id,
          line_direction,
          ignore_for_planning,
          earliest_pickup_date,
          latest_pickup_date,
          earliest_dropoff_date,
          latest_dropoff_date,
          source_document_type_id,
          service_level,
          mode_of_transport,
	  source_blanket_reference_id,
	  source_blanket_reference_num,
	  vendor_id,
	  party_id,
	  ship_from_site_id,
	  hold_code,
	  supplier_item_number,
	  po_shipment_line_id,
	  po_shipment_line_number,
	  shipping_control,
	  source_line_type_code,
          po_revision_number,
          release_revision_number,
          WV_FROZEN_FLAG,
          UNIT_WEIGHT,
          UNIT_VOLUME
       ) VALUES (
          p_additional_line_info_rec.source_code,
          p_line_rec.header_id(i),
          p_line_rec.line_id(i),
          p_line_rec.sold_to_org_id(i),
          p_line_rec.sold_to_contact_id(i),
          p_line_rec.inventory_item_id(i),
          p_line_rec.item_description(i),
          p_line_rec.hazard_class_id(i),
          p_line_rec.country_of_origin(i),
          nvl(p_line_rec.ship_from_location_id(i),-1),
          p_line_rec.ship_to_location_id(i),
          p_line_rec.ship_to_contact_id(i),
          p_line_rec.ship_to_org_id(i),
          p_line_rec.deliver_to_location_id(i),
          p_line_rec.deliver_to_contact_id(i),
          p_line_rec.deliver_to_org_id(i),
          p_line_rec.intmed_ship_to_location_id(i),
          p_line_rec.intermed_ship_to_contact_id(i),
          p_line_rec.ship_tolerance_above(i),
          p_line_rec.ship_tolerance_below(i),
          nvl(p_line_rec.requested_quantity(i),-1),
          nvl ( p_line_rec.requested_quantity_uom(i), 'XX'),
          p_line_rec.subinventory(i),
          p_line_rec.revision(i),
          p_line_rec.request_date(i),
          p_line_rec.schedule_ship_date(i),
          p_additional_line_info_rec.master_container_item_id(i),
          p_additional_line_info_rec.detail_container_item_id(i),
          p_line_rec.shipping_method_code(i),
          p_line_rec.carrier_id(i),
          p_line_rec.freight_terms_code(i),
          p_line_rec.shipment_priority_code(i),
          p_line_rec.fob_point_code(i),
          p_line_rec.customer_item_id(i),
          p_line_rec.dep_plan_required_flag(i),
          p_line_rec.cust_production_seq_num(i),
          p_line_rec.customer_dock_code(i),
          p_line_rec.cust_model_serial_number(i),
          p_line_rec.customer_job(i),
          p_line_rec.customer_production_line(i),
          p_line_rec.net_weight(i),
          p_line_rec.weight_uom_code(i),
          p_line_rec.volume(i),
          p_line_rec.volume_uom_code(i),
          p_line_rec.TP_CONTEXT(i),
          p_line_rec.tp_attribute1(i),
          p_line_rec.tp_attribute2(i),
          p_line_rec.tp_attribute3(i),
          p_line_rec.tp_attribute4(i),
          p_line_rec.tp_attribute5(i),
          p_line_rec.tp_attribute6(i),
          p_line_rec.tp_attribute7(i),
          p_line_rec.tp_attribute8(i),
          p_line_rec.tp_attribute9(i),
          p_line_rec.tp_attribute10(i),
          p_line_rec.tp_attribute11(i),
          p_line_rec.tp_attribute12(i),
          p_line_rec.tp_attribute13(i),
          p_line_rec.tp_attribute14(i),
          p_line_rec.tp_attribute15(i),
          p_additional_line_info_rec.attribute_category(i),
          p_additional_line_info_rec.attribute1(i),
          p_additional_line_info_rec.attribute2(i),
          p_additional_line_info_rec.attribute3(i),
          p_additional_line_info_rec.attribute4(i),
          p_additional_line_info_rec.attribute5(i),
          p_additional_line_info_rec.attribute6(i),
          p_additional_line_info_rec.attribute7(i),
          p_additional_line_info_rec.attribute8(i),
          p_additional_line_info_rec.attribute9(i),
          p_additional_line_info_rec.attribute10(i),
          p_additional_line_info_rec.attribute11(i),
          p_additional_line_info_rec.attribute12(i),
          p_additional_line_info_rec.attribute13(i),
          p_additional_line_info_rec.attribute14(i),
          p_additional_line_info_rec.attribute15(i),
          l_FND_GLOBAL_USER_ID,
          l_SYSDATE,
          l_SYSDATE,
          l_FND_GLOBAL_USER_ID,
          l_FND_GLOBAL_USER_ID,
          NULL,
          NULL,
          NULL,
          p_line_rec.mvt_stat_status(i),
          p_line_rec.organization_id(i),
          p_line_rec.ship_set_id(i),
          p_line_rec.arrival_set_id(i),
          p_line_rec.ship_model_complete_flag(i),
          p_line_rec.top_model_line_id(i),
          p_line_rec.source_header_number(i),
          p_line_rec.source_header_type_id(i),
          p_line_rec.source_header_type_name(i),
          p_line_rec.cust_po_number(i),
          p_line_rec.ato_line_id(i),
          p_line_rec.ordered_quantity(i),
          p_line_rec.order_quantity_uom(i),
          p_additional_line_info_rec.cancelled_quantity(i),
          p_line_rec.tracking_number(i),
          p_line_rec.shipping_instructions(i),
          p_line_rec.packing_instructions(i),
          p_line_rec.project_id(i),
          p_line_rec.task_id(i),
          p_action_prms.org_id,
          decode(p_additional_line_info_rec.source_code,'OE','N','X'),
          nvl(p_additional_line_info_rec.inv_interfaced_flag(i),
                            decode(p_line_rec.pickable_flag(i),'Y','N','X')),
          p_line_rec.source_line_number(i),
          decode  (p_additional_line_info_rec.source_code, 'OKE' ,
              nvl (p_line_rec.inspection_flag(i), 'N') , 'N' ),
          p_additional_line_info_rec.released_status(i),
          wsh_delivery_details_s.nextval,
          'N',
          p_line_rec.gross_weight(i),
          p_line_rec.seal_code(i),
          p_line_rec.end_item_unit_number(i),
          p_line_rec.unit_list_price(i),
          p_line_rec.currency_code(i),
          --p_line_rec.freight_class_cat_id(i),
          --p_line_rec.commodity_code_cat_id(i),
          p_line_rec.preferred_grade(i),
          p_line_rec.ordered_quantity2(i),
          p_line_rec.ordered_quantity_uom2(i),
          p_line_rec.requested_quantity2(i),
          p_additional_line_info_rec.cancelled_quantity2(i),
          p_line_rec.requested_quantity_uom2(i),
          p_line_rec.pickable_flag(i),
          p_line_rec.original_subinventory(i),
          p_line_rec.received_quantity(i),
          p_line_rec.received_quantity2(i),
          p_line_rec.line_set_id(i),
          decode(p_additional_line_info_rec.source_code, 'OE', 'O', 'OKE', 'O',
                    'PO',decode(p_line_rec.drop_ship_flag(i),'Y','D','I'),'O'),
          NVL(p_additional_line_info_rec.ignore_for_planning(i),'N'),
          p_additional_line_info_rec.earliest_pickup_date(i),
          p_additional_line_info_rec.latest_pickup_date(i),
          p_additional_line_info_rec.earliest_dropoff_date(i),
          p_additional_line_info_rec.latest_dropoff_date(i),
          p_line_rec.source_document_type_id(i),
          p_additional_line_info_rec.service_level(i),
          p_additional_line_info_rec.mode_of_transport(i),
	  -- Added for Inbound Logistics
	  p_line_rec.source_blanket_reference_id(i),
	  p_line_rec.source_blanket_reference_num(i),
	  p_line_rec.vendor_id(i),
	  p_line_rec.vendor_party_id(i),
	  p_line_rec.ship_from_site_id(i),
	  p_line_rec.hold_code(i),
	  p_line_rec.supplier_item_num(i),
	  p_line_rec.po_shipment_line_id(i),
	  p_line_rec.po_shipment_line_number(i),
	  p_line_rec.shipping_control(i),
	  p_line_rec.source_line_type_code(i),
          p_line_rec.po_revision(i),
          p_line_rec.release_revision(i),
          'N' , -- WV_FROZEN_FLAG
          p_line_rec.mtl_unit_weight(i),
          p_line_rec.mtl_unit_volume(i)
       )
       RETURNING DELIVERY_DETAIL_ID
       BULK COLLECT INTO l_del_det_id_tab;
       --BULK COLLECT INTO p_line_rec.delivery_detail_id;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Count of l_del_det_id_tab' , l_del_det_id_tab.count);
      WSH_DEBUG_SV.log(l_module_name,'count of p_line_recs p_del det id after inert and before assignment', p_line_rec.delivery_detail_id.count);
    END IF;
       IF p_index is not null THEN
          p_line_rec.delivery_detail_id(p_index) := l_del_det_id_tab(l_del_det_id_tab.first);
          l_rec_inserted_count := l_del_det_id_tab.first;
          -- DBI Project, for p_index is not null
          l_detail_tab(1) := p_line_rec.delivery_detail_id(p_index);
       ELSE
          i := l_del_det_id_tab.FIRST;
          WHILE i IS NOT NULL LOOP
             p_line_rec.delivery_detail_id(i) := l_del_det_id_tab(i);
             l_detail_tab(i) := l_del_det_id_tab(i); -- DBI Project, change of datatypes requires this data transfer
             i := l_del_det_id_tab.NEXT(i);
          END LOOP;
          l_rec_inserted_count := l_del_det_id_tab.COUNT;
       END IF;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'count of p_line_recs p_del det id after inert and after assignment', p_line_rec.delivery_detail_id.count);
      WSH_DEBUG_SV.log(l_module_name,'p_line_rec.shipping_eligible_flag count', p_line_rec.shipping_eligible_flag.count);
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'number of rows inserted ',
                                                         l_rec_inserted_count);
      WSH_DEBUG_SV.log(l_module_name,'l_line_rec_count', l_line_rec_count);
      WSH_DEBUG_SV.log(l_module_name,'p_index', p_index);
    END IF;
    IF l_rec_inserted_count <> l_line_rec_count THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- DBI Project
    -- Insert of wsh_delivery_details,  call DBI API after the insert.
    -- This API will also check for DBI Installed or not
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail count-',l_detail_tab.count);
    END IF;
    WSH_INTEGRATION.DBI_Update_Detail_Log
      (p_delivery_detail_id_tab => l_detail_tab,
       p_dml_type               => 'INSERT',
       x_return_status          => l_dbi_rs);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
    END IF;
    IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      -- just pass this return status to caller API
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- End of Code for DBI Project
    --


-- HW OPM BUG#:3064890 HVOP for OPM
-- Bulk updating for OPM lines
-- Need to update opm inventory transaction by calling check_OPM_trans_for_so_line
    --Added for Inbound logistics

    IF p_index IS NULL THEN
       l_first := p_line_rec.delivery_detail_id.FIRST;
    ELSE
       l_first := p_index;
       l_rec_inserted_count := p_index;
       --l_first := l_del_det_id_tab.first;
       --l_rec_inserted_count := l_del_det_id_tab.last;
    END IF;

    FOR i in l_first..l_rec_inserted_count LOOP

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'p_line_rec.shipping_eligible_flag(i)', p_line_rec.shipping_eligible_flag(i));
    END IF;
       IF p_line_rec.shipping_eligible_flag(i) = 'Y' THEN
          l_eligible_count := l_eligible_count + 1;
       END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'p_line_rec.shipping_interfaced_flag(i)', p_line_rec.shipping_interfaced_flag(i));
      WSH_DEBUG_SV.log(l_module_name,'p_line_rec.organization_id(i)', p_line_rec.organization_id(i));
      WSH_DEBUG_SV.log(l_module_name,'p_additional_line_info_rec.source_code', p_additional_line_info_rec.source_code);
    END IF;
       IF p_line_rec.shipping_interfaced_flag(i) = 'Y' THEN --{
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Inside the if  p_line_rec.shipping_interfaced_flag');
         END IF;
--HW OPMCONV. Removed code forking

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Assigning the valid_ids directly');
           END IF;
           l_valid_ids(l_valid_ids.COUNT + 1) := p_line_rec.delivery_detail_id(i);

           --OTM R12
           --get the delivery detail information for the valid lines
           IF (l_gc3_is_installed = 'Y') THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'Delivery detail number',l_tab_index);
               WSH_DEBUG_SV.log(l_module_name,'delivery detail id',p_line_rec.delivery_detail_id(i));
               WSH_DEBUG_SV.log(l_module_name,'inventory item id',p_line_rec.inventory_item_id(i));
               WSH_DEBUG_SV.log(l_module_name,'net weight',p_line_rec.net_weight(i));
               WSH_DEBUG_SV.log(l_module_name,'organization id',p_line_rec.organization_id(i));
               WSH_DEBUG_SV.log(l_module_name,'weight uom code',p_line_rec.weight_uom_code(i));
               WSH_DEBUG_SV.log(l_module_name,'requested quantity',p_line_rec.requested_quantity(i));
               WSH_DEBUG_SV.log(l_module_name,'ship from location id',p_line_rec.ship_from_location_id(i));
               WSH_DEBUG_SV.log(l_module_name,'requested quantity uom',p_line_rec.requested_quantity_uom(i));
             END IF;

             l_delivery_detail_tab.EXTEND;
             l_delivery_detail_tab(l_tab_index) := WSH_ENTITY_INFO_REC(p_line_rec.delivery_detail_id(i),
                                                     NULL,
                                                     p_line_rec.inventory_item_id(i),
                                                     p_line_rec.net_weight(i),
                                                     0,
                                                     p_line_rec.organization_id(i),
                                                     p_line_rec.weight_uom_code(i),
                                                     p_line_rec.requested_quantity(i),
                                                     p_line_rec.ship_from_location_id(i),
                                                     NULL);
             l_item_quantity_uom_tab(l_tab_index) := p_line_rec.requested_quantity_uom(i);
             l_tab_index := l_tab_index + 1;
           END IF;
           --END OTM R12

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'After Assigning the valid_ids directly');
           END IF;

       ELSE -- of interfaced_flag }{
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Inside the eslse 2 portion');
              WSH_DEBUG_SV.log(l_module_name,'p_line_rec.delivery_detail_id(i)', p_line_rec.delivery_detail_id(i));
            END IF;
         l_invalid_ids(l_invalid_ids.COUNT + 1) := p_line_rec.delivery_detail_id(i);
       END IF;  -- of interfaced_flag }
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Going to next record in the loop');
           END IF;


    END LOOP; -- of loop


    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'After the loop');
    END IF;

    -- l_valid_ids is grater than 0, otherwise, this API would not
    -- even be called
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'number of invalid records ',
                                                         l_invalid_ids.COUNT);
      WSH_DEBUG_SV.log(l_module_name,'number of valid records ',
                                                         l_valid_ids.COUNT);
    END IF;

    IF l_invalid_ids.COUNT > 0 THEN

       l_first := l_invalid_ids.FIRST; --always 1
       l_count := l_invalid_ids.COUNT;

       FORALL i IN l_first..l_count
       DELETE FROM WSH_DELIVERY_DETAILS
       WHERE delivery_detail_id = l_invalid_ids(i);
       --put debug message for the rowcount

    END IF;

    l_sysdate := SYSDATE;

    l_first := l_valid_ids.FIRST; --always 1
    l_count := l_valid_ids.COUNT;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_first', l_first);
      WSH_DEBUG_SV.log(l_module_name,'l_count', l_count);
    END IF;
    FORALL I in l_first..l_count
    INSERT INTO wsh_delivery_assignments_v(
       delivery_assignment_id,
       delivery_detail_id,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_application_id,
       program_id,
       program_update_date
    ) values (
       wsh_delivery_assignments_s.nextval,
       l_valid_ids(i),
       l_SYSDATE,
       L_FND_GLOBAL_USER_ID,
       L_SYSDATE,
       L_FND_GLOBAL_USER_ID,
       L_FND_GLOBAL_USER_ID,
       NULL,
       NULL,
       NULL
    );

    --put debug message about the row count

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'After the insert');
    END IF;
    IF l_eligible_count <> l_valid_ids.COUNT THEN
       --return warning if there were some record that did not pass validations
       --For the case all the records were invalid, this API is
       --not even called
       RAISE wsh_util_core.G_EXC_WARNING;
    END IF;

    --OTM R12 calling delivery detail splitter if records exist, l_tab_index incremented
    IF (l_gc3_is_installed = 'Y' AND l_tab_index > 1) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_SPLITTER.TMS_DELIVERY_DETAIL_SPLIT',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_DELIVERY_DETAILS_SPLITTER.tms_delivery_detail_split(
             	p_detail_tab => l_delivery_detail_tab,
	      	p_item_quantity_uom_tab => l_item_quantity_uom_tab,
             	x_return_status => l_return_status);

      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_DELIVERY_DETAILS_SPLITTER.TMS_DELIVERY_DETAIL_SPLIT',l_return_status);
      END IF;
      -- we will not fail based on l_return_status here because
      -- we do not want to stop the flow
      -- if the detail doesn't split, it will be caught later in
      -- delivery splitting and will have exception on the detail
      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery detail split failed' );
        END IF;
      END IF;

    END IF;
    --END OTM R12

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  EXCEPTION

    WHEN e_success THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'e_success');
      END IF;

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has '
          || 'occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. ' ||
        'Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING '||
           'exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --

    WHEN OTHERS THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'inside when others - count of p_line_recs p_del det id ', p_line_rec.delivery_detail_id.count);
    END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_BULK_PROCESS_PVT.bulk_insert_details');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
           'Oracle error message is '||
           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;


  END bulk_insert_details;


--========================================================================
-- PROCEDURE : set_message
--
-- PARAMETERS: p_line_rec              Line record
--             p_index                 index for the line record
--             p_caller                caller OM, PO, OKE
--             p_first_call            pass 'T' to this API for the first time
--                                     this API is called.
--             X_stack_size_start      this will return the fnd message
--                                     stack size, if a 'T' is passed to
--                                     the parameter p_first_call
--             x_return_status         return status
-- COMMENT   : This API should be called twice, once at the begin of
--             the validation and once at the end.  If the caller is OM
--             this API will calculate the number of the messages that have
--             been added to the fnd_message stack and put this number into
--             table p_line_rec.error_message_count.
--             If the caller is not OM, then if any errors should be logged
--             for a certain line, this API would put one message at the begin
--             saying which line, header number is being processed and once
--             all the messages for this line has been put on the stack,
--             another message indicates that the validation has finished for
--             the line, header number.
--
--========================================================================



PROCEDURE Set_message(
           p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.Line_rec_type,
           p_index            IN NUMBER,
           p_caller           IN VARCHAR2,
           P_first_call       IN VARCHAR2,
           X_stack_size_start IN OUT NOCOPY NUMBER,
           X_return_status    OUT NOCOPY VARCHAR2
  )
  IS
    l_debug_on BOOLEAN;
    --
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
               '.' || 'SET_MESSAGE';
    l_msg_count          NUMBER := 0;
  BEGIN
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_caller ',p_caller);
      WSH_DEBUG_SV.log(l_module_name,'p_index ',p_index);
      WSH_DEBUG_SV.log(l_module_name,'P_first_call ',P_first_call);
      WSH_DEBUG_SV.log(l_module_name,'X_stack_size_start ',X_stack_size_start);
      WSH_DEBUG_SV.log(l_module_name,'header_number ',
                                     p_line_rec.source_header_number(p_index));
      WSH_DEBUG_SV.log(l_module_name,'line_number ',
                                     p_line_rec.source_line_number(p_index));
    END IF;
    IF P_first_call = 'T' THEN --{
      IF p_caller <> 'OM' THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_START_MESSAGING');
        FND_MESSAGE.SET_TOKEN('HEADER_NUMBER',
                                     p_line_rec.source_header_number(p_index));
        FND_MESSAGE.SET_TOKEN('LINE_NUMBER',
                                       p_line_rec.source_line_number(p_index));
        wsh_util_core.add_message(wsh_util_core.g_ret_sts_success,
                                                                l_module_name);
      END IF;
      X_stack_size_start := FND_MSG_PUB.Count_Msg;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'X_stack_size_start',
                                                          X_stack_size_start);
      END IF;
    ELSE --}{

      l_msg_count := FND_MSG_PUB.Count_Msg;

      IF l_msg_count > X_stack_size_start THEN --{
        IF p_caller <> 'OM' THEN --{
          FND_MESSAGE.SET_NAME('WSH','WSH_END_MESSAGING');
          FND_MESSAGE.SET_TOKEN('HEADER_NUMBER',
                                     p_line_rec.source_header_number(p_index));
          FND_MESSAGE.SET_TOKEN('LINE_NUMBER',
                                       p_line_rec.source_line_number(p_index));
          wsh_util_core.add_message(wsh_util_core.g_ret_sts_success,
                                                                l_module_name);
        ELSE --}{
          p_line_rec.error_message_count(p_index) := l_msg_count -
                                                           X_stack_size_start;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'OM message count',
                                       p_line_rec.error_message_count(p_index));
          END IF;
        END IF; --}
      ELSE --}{
        IF p_caller <> 'OM' THEN
         -- remove the previous message
          FND_MSG_PUB.Delete_Msg(X_stack_size_start);
        END IF;
      END IF; --}
    END IF; --}
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_BULK_PROCESS_PVT.Set_message');
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
           'Oracle error message is '||
           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

  END Set_message;



-- Added for Inbound Logistics



-- Start of comments
-- API name : VALIDATE_MANDATORY_INFO
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API checks for the validity of mandatory fields like
--              1.ordered_quantity
--		2.order_quantity_uom
--		3.organization_id
--		4.po_shipment_line_id
--              5.header_id
--		6.line_id
--		7.source_header_number
--		8.source_line_number
--              9.po_shipment_line_number
--		10.source_header_type_id
--		11.source_blanket_reference_id
--		12.source_blanket_reference_num
--		13.source_line_type_code
--		14.Ship_to_location_id
--		15.vendor_id
--		16.ship_from_site_id
--		17.org_id
--		18.source_header_type_name
--		19.shipping_control
--                  and sets a local variable to the name of the field which failed validity.
-- Parameters :
-- IN:
--	     	p_line_rec      IN  OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type
--                     The input table of records, which contains the fields
--                     to be checked for validity.
--	      	p_index         IN  NUMBER
--                     The index of the record of the i/p table of records
--                     namely p_line_rec. Only the fields of the record
--                     corresponding to this index are checked for validity.
-- IN OUT:
--
-- OUT:
--	   	x_return_status OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments



  PROCEDURE  validate_mandatory_info(
     	p_line_rec      IN  OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
      	p_index         IN  NUMBER,
     	x_return_status OUT NOCOPY VARCHAR2)  IS


  l_exc_mandatory EXCEPTION;
  l_api_name      CONSTANT VARCHAR2(30)  := 'validate_mandatory_info';
  l_token VARCHAR2(200);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_MANDATORY_INFO';
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
         --
         WSH_DEBUG_SV.log(l_module_name,'P_INDEX',P_INDEX);
     END IF;
     --
     x_return_status :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     IF    p_line_rec.ordered_quantity( p_index) IS NULL THEN
   	l_token := 'ORDERED QUANTITY';
   	raise   l_exc_mandatory;
     END IF;

     IF  p_line_rec.order_quantity_uom(p_index) IS NULL THEN
   	l_token := 'ORDERED QUANTITY UOM ';
   	raise   l_exc_mandatory;
     END IF;

     IF  p_line_rec.organization_id(p_index) IS NULL THEN
   	l_token := ' ORGANIZATION ID';
   	raise   l_exc_mandatory;
     END IF;

     IF p_line_rec.po_shipment_line_id(p_index) IS NULL THEN
   	l_token := 'PO LINE LOCATION ID';
   	raise   l_exc_mandatory;
     END IF;

     IF  p_line_rec.header_id(p_index) IS NULL THEN
   	l_token := 'PO HEADER ID';
   	raise   l_exc_mandatory;
     END IF;

     IF p_line_rec.line_id(p_index) IS NULL THEN
   	l_token := 'PO LINE ID';
   	raise   l_exc_mandatory;
     END IF;

     IF p_line_rec.source_header_number(p_index) IS NULL THEN
    	l_token := 'PO HEADER NUMBER';
    	raise   l_exc_mandatory;
     END IF;

     IF  p_line_rec.ship_to_location_id(p_index) IS NULL THEN
     	l_token := 'SHIP TO LOCATION';
     	raise   l_exc_mandatory;
     END IF;

     IF  p_line_rec.source_line_number(p_index) IS NULL THEN
     	l_token := 'PO LINE NUMBER';
     	raise   l_exc_mandatory;
     END IF;

     IF p_line_rec.po_shipment_line_number(p_index) IS NULL THEN
     	l_token := 'PO LINE LOCATION NUMBER';
     	raise   l_exc_mandatory;
     END IF;

     IF p_line_rec.source_header_type_id(p_index) IS NULL THEN
     	l_token := ' SOURCE HEADER TYPE ID ';
     	raise   l_exc_mandatory;
     ELSE

     --code for Bug # 3188208
        --source_header_type_id can have values of either 1 or 2.
	--  1 means a non-blanket PO.
	--  2 means a blanket PO.
        IF   ( p_line_rec.source_header_type_id(p_index) <> 1 )AND
             ( p_line_rec.source_header_type_id(p_index) <> 2 )   THEN
	  FND_MESSAGE.SET_NAME('WSH','WSH_IB_INVALID_SRC_HDR_TP');
       	  WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR);
	  RAISE FND_API.G_EXC_ERROR;
        END IF;


        -- If the PO is a non-blanket PO,then the fields 'source_blanket_reference_id '
	-- and 'source_blanket_reference_num' should be NULL.
	IF   p_line_rec.source_header_type_id(p_index) = 1  THEN
   	   IF  ( p_line_rec.source_blanket_reference_id(p_index) IS NOT NULL ) OR
	       ( p_line_rec.source_blanket_reference_num(p_index) IS NOT NULL) THEN
	      FND_MESSAGE.SET_NAME('WSH','WSH_IB_BLANKET_VAL_NOT_NULL');
              FND_MESSAGE.SET_TOKEN('PONUM',p_line_rec.source_header_number(p_index));
              WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR);
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
      	END IF;
      --end of code for Bug # 3188208

        -- If the PO is a blanket PO,then the fields 'source_blanket_reference_id '
	-- and 'source_blanket_reference_num' should not be NULL.
	IF   p_line_rec.source_header_type_id(p_index) = 2  THEN
   	   IF p_line_rec.source_blanket_reference_id(p_index) IS NULL THEN
      		l_token := 'BLANKET REFERENCE_ID';
      		raise   l_exc_mandatory;
	   END IF;
           IF p_line_rec.source_blanket_reference_num(p_index) IS NULL THEN
      		l_token := 'BLANKET REFERENCE NUMBER';
      		raise   l_exc_mandatory;
	   END IF;
     	END IF;

     END IF;

     --Source line type should be either GB (Goods Based)or GB_OSP
     --(Goods Based Outside Processing).
     IF p_line_rec.source_line_type_code(p_index) IS NULL THEN
       	l_token := 'SOURCE LINE TYPE CODE';
       	raise   l_exc_mandatory;
     ELSIF   p_line_rec.source_line_type_code(p_index) <> 'GB' AND
             p_line_rec.source_line_type_code(p_index) <> 'GB_OSP' THEN
	FND_MESSAGE.SET_NAME('WSH','WSH_IB_INVALID_SOURCE_LINE_TYPE');
       	WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR);
	RAISE FND_API.G_EXC_ERROR;
     END IF;

--
     IF p_line_rec.vendor_id(p_index) IS NULL THEN
     	l_token := 'VENDOR ID';
     	raise   l_exc_mandatory;
     END IF;

     IF p_line_rec.ship_from_site_id(p_index) IS NULL THEN
     	l_token := 'SHIP FROM SITE ID';
     	raise   l_exc_mandatory;
     END IF;

     IF p_line_rec.org_id(p_index) IS NULL THEN
     	l_token := 'ORG ID';
     	raise   l_exc_mandatory;
     END IF;

     IF p_line_rec.source_header_type_name(p_index) IS NULL THEN
     	l_token := 'SOURCE HEADER TYPE NAME';
     	raise   l_exc_mandatory;
     END IF;


     -- The 'shipping_control' should be either supplier/buyer for Inbound Logistics.
     IF p_line_rec.shipping_control(p_index) IS NULL THEN
     	l_token := 'SHIPPING CONTROL';
     	raise   l_exc_mandatory;
     ELSIF p_line_rec.shipping_control(p_index) <> 'BUYER'
           AND p_line_rec.shipping_control(p_index) <> 'SUPPLIER' THEN

	FND_MESSAGE.SET_NAME('WSH','WSH_IB_INVALID_SHIPPING_CNTRL');
       	WSH_UTIL_CORE.Add_Message(WSH_UTIL_CORE.G_RET_STS_ERROR);
	RAISE FND_API.G_EXC_ERROR;
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
     WHEN l_exc_mandatory  THEN
    	FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
    	FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_token);
    	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    	wsh_util_core.add_message(x_return_status,l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'L_EXC_MANDATORY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:L_EXC_MANDATORY');
END IF;
--
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
     WHEN OTHERS  THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_BULK_PROCESS_PVT.validate_mandatory_info',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END validate_mandatory_info;


END WSH_BULK_PROCESS_PVT;


/
