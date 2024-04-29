--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERIES_PUB" as
/* $Header: WSHDEPBB.pls 120.1.12010000.3 2009/12/03 15:25:50 gbhargav ship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_DELIVERIES_PUB';
-- add your constants here if any

--===================
-- PROCEDURES
--===================

PROCEDURE Rtrim_delivery (
             p_in_rec  IN  WSH_DELIVERIES_PUB.Delivery_Pub_Rec_Type,
             p_out_rec OUT NOCOPY  WSH_DELIVERIES_PUB.Delivery_Pub_Rec_Type)
 IS
  l_debug_on BOOLEAN;
  l_module_name                 CONSTANT VARCHAR2(100) := 'wsh.plsql.' ||
                            G_PKG_NAME || '.' || 'Rtrim_delivery';
BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name, 'Rtrim_delivery');
   END IF;

   p_out_rec := p_in_rec;


   p_out_rec.NAME                            :=RTRIM(p_in_rec.NAME);
   p_out_rec.DELIVERY_TYPE                   :=RTRIM(p_in_rec.DELIVERY_TYPE);
   p_out_rec.LOADING_ORDER_FLAG              :=RTRIM(p_in_rec.LOADING_ORDER_FLAG);
   p_out_rec.LOADING_ORDER_DESC              :=RTRIM(p_in_rec.LOADING_ORDER_DESC);
   p_out_rec.INITIAL_PICKUP_LOCATION_CODE    :=RTRIM(p_in_rec.INITIAL_PICKUP_LOCATION_CODE);
   p_out_rec.ORGANIZATION_CODE               :=RTRIM(p_in_rec.ORGANIZATION_CODE);
   p_out_rec.ULTIMATE_DROPOFF_LOCATION_CODE  :=RTRIM(p_in_rec.ULTIMATE_DROPOFF_LOCATION_CODE);
   p_out_rec.CUSTOMER_NUMBER                 :=RTRIM(p_in_rec.CUSTOMER_NUMBER);
   p_out_rec.INTMED_SHIP_TO_LOCATION_CODE    :=RTRIM(p_in_rec.INTMED_SHIP_TO_LOCATION_CODE);
   p_out_rec.POOLED_SHIP_TO_LOCATION_CODE    :=RTRIM(p_in_rec.POOLED_SHIP_TO_LOCATION_CODE);
   p_out_rec.CARRIER_CODE                    :=RTRIM(p_in_rec.CARRIER_CODE);
   p_out_rec.SHIP_METHOD_CODE                :=RTRIM(p_in_rec.SHIP_METHOD_CODE);
   p_out_rec.SHIP_METHOD_NAME                :=RTRIM(p_in_rec.SHIP_METHOD_NAME);
   p_out_rec.FREIGHT_TERMS_CODE              :=RTRIM(p_in_rec.FREIGHT_TERMS_CODE);
   p_out_rec.FREIGHT_TERMS_NAME              :=RTRIM(p_in_rec.FREIGHT_TERMS_NAME);
   p_out_rec.FOB_CODE                        :=RTRIM(p_in_rec.FOB_CODE);
   p_out_rec.FOB_NAME                        :=RTRIM(p_in_rec.FOB_NAME);
   p_out_rec.FOB_LOCATION_CODE               :=RTRIM(p_in_rec.FOB_LOCATION_CODE);
   p_out_rec.WAYBILL                         :=RTRIM(p_in_rec.WAYBILL);
   p_out_rec.DOCK_CODE                       :=RTRIM(p_in_rec.DOCK_CODE);
   p_out_rec.ACCEPTANCE_FLAG                 :=RTRIM(p_in_rec.ACCEPTANCE_FLAG);
   p_out_rec.ACCEPTED_BY                     :=RTRIM(p_in_rec.ACCEPTED_BY);
   p_out_rec.ACKNOWLEDGED_BY                 :=RTRIM(p_in_rec.ACKNOWLEDGED_BY);
   p_out_rec.CONFIRMED_BY                    :=RTRIM(p_in_rec.CONFIRMED_BY);
   p_out_rec.ASN_STATUS_CODE                 :=RTRIM(p_in_rec.ASN_STATUS_CODE);
   p_out_rec.WEIGHT_UOM_CODE                 :=RTRIM(p_in_rec.WEIGHT_UOM_CODE);
   p_out_rec.WEIGHT_UOM_DESC                 :=RTRIM(p_in_rec.WEIGHT_UOM_DESC);
   p_out_rec.VOLUME_UOM_CODE                 :=RTRIM(p_in_rec.VOLUME_UOM_CODE);
   p_out_rec.VOLUME_UOM_DESC                 :=RTRIM(p_in_rec.VOLUME_UOM_DESC);
   p_out_rec.ADDITIONAL_SHIPMENT_INFO        :=RTRIM(p_in_rec.ADDITIONAL_SHIPMENT_INFO);
   p_out_rec.CURRENCY_CODE                   :=RTRIM(p_in_rec.CURRENCY_CODE);
   p_out_rec.CURRENCY_NAME                   :=RTRIM(p_in_rec.CURRENCY_NAME);
   p_out_rec.ATTRIBUTE_CATEGORY              :=RTRIM(p_in_rec.ATTRIBUTE_CATEGORY);
   p_out_rec.ATTRIBUTE1                      :=RTRIM(p_in_rec.ATTRIBUTE1);
   p_out_rec.ATTRIBUTE2                      :=RTRIM(p_in_rec.ATTRIBUTE2);
   p_out_rec.ATTRIBUTE3                      :=RTRIM(p_in_rec.ATTRIBUTE3);
   p_out_rec.ATTRIBUTE4                      :=RTRIM(p_in_rec.ATTRIBUTE4);
   p_out_rec.ATTRIBUTE5                      :=RTRIM(p_in_rec.ATTRIBUTE5);
   p_out_rec.ATTRIBUTE6                      :=RTRIM(p_in_rec.ATTRIBUTE6);
   p_out_rec.ATTRIBUTE7                      :=RTRIM(p_in_rec.ATTRIBUTE7);
   p_out_rec.ATTRIBUTE8                      :=RTRIM(p_in_rec.ATTRIBUTE8);
   p_out_rec.ATTRIBUTE9                      :=RTRIM(p_in_rec.ATTRIBUTE9);
   p_out_rec.ATTRIBUTE10                     :=RTRIM(p_in_rec.ATTRIBUTE10);
   p_out_rec.ATTRIBUTE11                     :=RTRIM(p_in_rec.ATTRIBUTE11);
   p_out_rec.ATTRIBUTE12                     :=RTRIM(p_in_rec.ATTRIBUTE12);
   p_out_rec.ATTRIBUTE13                     :=RTRIM(p_in_rec.ATTRIBUTE13);
   p_out_rec.ATTRIBUTE14                     :=RTRIM(p_in_rec.ATTRIBUTE14);
   p_out_rec.ATTRIBUTE15                     :=RTRIM(p_in_rec.ATTRIBUTE15);
   p_out_rec.TP_ATTRIBUTE_CATEGORY           :=RTRIM(p_in_rec.TP_ATTRIBUTE_CATEGORY);
   p_out_rec.TP_ATTRIBUTE1                   :=RTRIM(p_in_rec.TP_ATTRIBUTE1);
   p_out_rec.TP_ATTRIBUTE2                   :=RTRIM(p_in_rec.TP_ATTRIBUTE2);
   p_out_rec.TP_ATTRIBUTE3                   :=RTRIM(p_in_rec.TP_ATTRIBUTE3);
   p_out_rec.TP_ATTRIBUTE4                   :=RTRIM(p_in_rec.TP_ATTRIBUTE4);
   p_out_rec.TP_ATTRIBUTE5                   :=RTRIM(p_in_rec.TP_ATTRIBUTE5);
   p_out_rec.TP_ATTRIBUTE6                   :=RTRIM(p_in_rec.TP_ATTRIBUTE6);
   p_out_rec.TP_ATTRIBUTE7                   :=RTRIM(p_in_rec.TP_ATTRIBUTE7);
   p_out_rec.TP_ATTRIBUTE8                   :=RTRIM(p_in_rec.TP_ATTRIBUTE8);
   p_out_rec.TP_ATTRIBUTE9                   :=RTRIM(p_in_rec.TP_ATTRIBUTE9);
   p_out_rec.TP_ATTRIBUTE10                  :=RTRIM(p_in_rec.TP_ATTRIBUTE10);
   p_out_rec.TP_ATTRIBUTE11                  :=RTRIM(p_in_rec.TP_ATTRIBUTE11);
   p_out_rec.TP_ATTRIBUTE12                  :=RTRIM(p_in_rec.TP_ATTRIBUTE12);
   p_out_rec.TP_ATTRIBUTE13                  :=RTRIM(p_in_rec.TP_ATTRIBUTE13);
   p_out_rec.TP_ATTRIBUTE14                  :=RTRIM(p_in_rec.TP_ATTRIBUTE14);
   p_out_rec.TP_ATTRIBUTE15                  :=RTRIM(p_in_rec.TP_ATTRIBUTE15);
   p_out_rec.GLOBAL_ATTRIBUTE_CATEGORY       :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE_CATEGORY);
   p_out_rec.GLOBAL_ATTRIBUTE1               :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE1);
   p_out_rec.GLOBAL_ATTRIBUTE2               :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE2);
   p_out_rec.GLOBAL_ATTRIBUTE3               :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE3);
   p_out_rec.GLOBAL_ATTRIBUTE4               :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE4);
   p_out_rec.GLOBAL_ATTRIBUTE5               :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE5);
   p_out_rec.GLOBAL_ATTRIBUTE6               :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE6);
   p_out_rec.GLOBAL_ATTRIBUTE7               :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE7);
   p_out_rec.GLOBAL_ATTRIBUTE8               :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE8);
   p_out_rec.GLOBAL_ATTRIBUTE9               :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE9);
   p_out_rec.GLOBAL_ATTRIBUTE10              :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE10);
   p_out_rec.GLOBAL_ATTRIBUTE11              :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE11);
   p_out_rec.GLOBAL_ATTRIBUTE12              :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE12);
   p_out_rec.GLOBAL_ATTRIBUTE13              :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE13);
   p_out_rec.GLOBAL_ATTRIBUTE14              :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE14);
   p_out_rec.GLOBAL_ATTRIBUTE15              :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE15);
   p_out_rec.GLOBAL_ATTRIBUTE16              :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE16);
   p_out_rec.GLOBAL_ATTRIBUTE17              :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE17);
   p_out_rec.GLOBAL_ATTRIBUTE18              :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE18);
   p_out_rec.GLOBAL_ATTRIBUTE19              :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE19);
   p_out_rec.GLOBAL_ATTRIBUTE20              :=RTRIM(p_in_rec.GLOBAL_ATTRIBUTE20);
   p_out_rec.COD_CURRENCY_CODE               :=RTRIM(p_in_rec.COD_CURRENCY_CODE);
   p_out_rec.COD_REMIT_TO                    :=RTRIM(p_in_rec.COD_REMIT_TO);
   p_out_rec.COD_CHARGE_PAID_BY              :=RTRIM(p_in_rec.COD_CHARGE_PAID_BY);
   p_out_rec.PROBLEM_CONTACT_REFERENCE       :=RTRIM(p_in_rec.PROBLEM_CONTACT_REFERENCE);
   p_out_rec.PORT_OF_LOADING                 :=RTRIM(p_in_rec.PORT_OF_LOADING);
   p_out_rec.PORT_OF_DISCHARGE               :=RTRIM(p_in_rec.PORT_OF_DISCHARGE);
   p_out_rec.FTZ_NUMBER                      :=RTRIM(p_in_rec.FTZ_NUMBER);
   p_out_rec.ROUTED_EXPORT_TXN               :=RTRIM(p_in_rec.ROUTED_EXPORT_TXN);
   p_out_rec.ENTRY_NUMBER                    :=RTRIM(p_in_rec.ENTRY_NUMBER);
   p_out_rec.ROUTING_INSTRUCTIONS            :=RTRIM(p_in_rec.ROUTING_INSTRUCTIONS);
   p_out_rec.IN_BOND_CODE                    :=RTRIM(p_in_rec.IN_BOND_CODE);
   p_out_rec.SHIPPING_MARKS                  :=RTRIM(p_in_rec.SHIPPING_MARKS);
   p_out_rec.SERVICE_LEVEL                   :=RTRIM(p_in_rec.SERVICE_LEVEL);
   p_out_rec.MODE_OF_TRANSPORT               :=RTRIM(p_in_rec.MODE_OF_TRANSPORT);
   p_out_rec.ASSIGNED_TO_FTE_TRIPS           :=RTRIM(p_in_rec.ASSIGNED_TO_FTE_TRIPS);
   p_out_rec.AUTO_SC_EXCLUDE_FLAG            :=RTRIM(p_in_rec.AUTO_SC_EXCLUDE_FLAG);
   p_out_rec.AUTO_AP_EXCLUDE_FLAG            :=RTRIM(p_in_rec.AUTO_AP_EXCLUDE_FLAG);
   p_out_rec.client_code                     :=RTRIM(p_in_rec.client_code );   -- LSP PROJECT


   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      wsh_util_core.default_handler (
        'WSH_TRIP_STOPS_GRP.Rtrim_delivery', l_module_name);
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured.'||
         ' Oracle error message is '|| SQLERRM,
                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
      RAISE;

END Rtrim_delivery;


--========================================================================
-- PROCEDURE : Validate_Delivery         PRIVATE
--
-- PARAMETERS: p_delivery_info         Attributes for the delivery entity
--             p_action_code           'CREATE', 'UPDATE'
--             x_return_status         Return status of API
-- COMMENT   : Validates p_delivery_info by calling column specific validations
--========================================================================
  PROCEDURE Validate_Delivery
      (p_delivery_info         IN OUT NOCOPY  delivery_pub_rec_type,
       p_action_code           IN     VARCHAR2,
       x_return_status         OUT    NOCOPY VARCHAR2) IS

  l_assigned_to_trip VARCHAR2(1);

  -- OTM R12, glog proj
  l_adjusted_amount  NUMBER;
  l_debug_on BOOLEAN;
  l_module_name                 CONSTANT VARCHAR2(100) := 'wsh.plsql.' ||G_PKG_NAME || '.' || 'Validate_Delivery';

  BEGIN
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
      wsh_debug_sv.push (l_module_name, 'Validate_Delivery');
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF (p_action_code <> 'CREATE') THEN

       IF (p_delivery_info.delivery_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.name <> FND_API.G_MISS_CHAR) THEN

            IF (p_delivery_info.name <> FND_API.G_MISS_CHAR) THEN
             p_delivery_info.delivery_id := NULL;
          END IF;

            wsh_util_validate.validate_delivery_name(
            p_delivery_info.delivery_id,
            p_delivery_info.name,
            x_return_status);

            IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               RETURN;
          END IF;

         END IF;

      END IF;

    IF (p_delivery_info.organization_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.organization_code <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.organization_code <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.organization_id := NULL;
       END IF;

         wsh_util_validate.validate_org(
         p_delivery_info.organization_id,
         p_delivery_info.organization_code,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RETURN;
       END IF;
    END IF;

    IF (nvl(p_delivery_info.delivery_type,'STANDARD') NOT IN ('STANDARD','CONSOLIDATED')) THEN
          p_delivery_info.delivery_type := 'STANDARD';

      END IF;

    IF (p_delivery_info.loading_order_flag <> FND_API.G_MISS_CHAR) OR (p_delivery_info.loading_order_desc <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.loading_order_desc <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.loading_order_flag := NULL;
       END IF;

         wsh_util_validate.validate_loading_order(
         p_delivery_info.loading_order_flag,
         p_delivery_info.loading_order_desc,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.initial_pickup_location_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.initial_pickup_location_code <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.initial_pickup_location_code <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.initial_pickup_location_id := NULL;
       END IF;

         wsh_util_validate.validate_location(
         p_delivery_info.initial_pickup_location_id,
         p_delivery_info.initial_pickup_location_code,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.ultimate_dropoff_location_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.ultimate_dropoff_location_code <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.ultimate_dropoff_location_code <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.ultimate_dropoff_location_id := NULL;
       END IF;

         wsh_util_validate.validate_location(
         p_delivery_info.ultimate_dropoff_location_id,
         p_delivery_info.ultimate_dropoff_location_code,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.intmed_ship_to_location_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.intmed_ship_to_location_code <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.intmed_ship_to_location_code <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.intmed_ship_to_location_id := NULL;
       END IF;

         wsh_util_validate.validate_location(
         p_delivery_info.intmed_ship_to_location_id,
         p_delivery_info.intmed_ship_to_location_code,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.pooled_ship_to_location_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.pooled_ship_to_location_code <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.pooled_ship_to_location_code <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.pooled_ship_to_location_id := NULL;
       END IF;

         wsh_util_validate.validate_location(
         p_delivery_info.pooled_ship_to_location_id,
         p_delivery_info.pooled_ship_to_location_code,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.customer_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.customer_number <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.customer_number <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.customer_id := NULL;
       END IF;

         wsh_util_validate.validate_customer(
         p_delivery_info.customer_id,
         p_delivery_info.customer_number,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RETURN;
       END IF;
      END IF;

    -- Carrier ID is not validated as it is not used...Ship method is used instead.

    IF (p_delivery_info.ship_method_code <> FND_API.G_MISS_CHAR) OR (p_delivery_info.ship_method_name <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.ship_method_code <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.ship_method_name := NULL;
       END IF;

         wsh_util_validate.validate_ship_method(
         p_delivery_info.ship_method_code,
         p_delivery_info.ship_method_name,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.freight_terms_code <> FND_API.G_MISS_CHAR) OR (p_delivery_info.freight_terms_name <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.freight_terms_name <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.freight_terms_name := NULL;
       END IF;

         wsh_util_validate.validate_freight_terms(
         p_delivery_info.freight_terms_code,
         p_delivery_info.freight_terms_name,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.fob_code <> FND_API.G_MISS_CHAR) OR (p_delivery_info.fob_name <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.fob_name <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.fob_code := NULL;
       END IF;

         wsh_util_validate.validate_fob(
         p_delivery_info.fob_code,
         p_delivery_info.fob_name,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.fob_location_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.fob_location_code <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.fob_location_code <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.fob_location_id := NULL;
       END IF;

         wsh_util_validate.validate_location(
         p_delivery_info.fob_location_id,
         p_delivery_info.fob_location_code,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.weight_uom_code <> FND_API.G_MISS_CHAR) OR (p_delivery_info.weight_uom_desc <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.weight_uom_desc <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.weight_uom_code := NULL;
       END IF;

         wsh_util_validate.validate_uom(
         'WEIGHT',
         p_delivery_info.organization_id,
         p_delivery_info.weight_uom_code,
         p_delivery_info.weight_uom_desc,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.volume_uom_code <> FND_API.G_MISS_CHAR) OR (p_delivery_info.volume_uom_desc <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.volume_uom_desc <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.volume_uom_code := NULL;
       END IF;

         wsh_util_validate.validate_uom(
         'VOLUME',
         p_delivery_info.organization_id,
         p_delivery_info.volume_uom_code,
         p_delivery_info.volume_uom_desc,
         x_return_status);

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RETURN;
       END IF;
      END IF;

    IF (p_delivery_info.currency_code <> FND_API.G_MISS_CHAR) OR (p_delivery_info.currency_name <> FND_API.G_MISS_CHAR) THEN

         IF (p_delivery_info.currency_name <> FND_API.G_MISS_CHAR) THEN
          p_delivery_info.currency_code := NULL;
         END IF;

         -- OTM R12, glog  project changes, to use name value notation
         WSH_UTIL_VALIDATE.validate_currency(
           p_currency_code     => p_delivery_info.currency_code,
           p_currency_name     => p_delivery_info.currency_name,
           p_amount            => NULL,
           x_return_status     => x_return_status,
           x_adjusted_amount   => l_adjusted_amount); -- OTM R12,glog project

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            RETURN;
         END IF;
      END IF;


      --
      -- manifesting code changes
      -- disallow update of ship method or its components if the delivery is assigned to trip.
      --

      IF (p_delivery_info.ship_method_code <> FND_API.G_MISS_CHAR) OR (p_delivery_info.ship_method_code IS NULL) OR
         (p_delivery_info.carrier_id <> FND_API.G_MISS_NUM) OR (p_delivery_info.carrier_id IS NULL) OR
         (p_delivery_info.service_level  <> FND_API.G_MISS_CHAR) OR (p_delivery_info.service_level IS NULL) OR
         (p_delivery_info.mode_of_transport <> FND_API.G_MISS_CHAR) OR (p_delivery_info.mode_of_transport IS NULL) THEN

          l_assigned_to_trip := WSH_Delivery_Validations.Del_Assigned_To_Trip
                                         (p_delivery_id =>  p_delivery_info.delivery_id,
                                          x_return_status => x_return_status);

          IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN

            RETURN;

          ELSIF l_assigned_to_trip = 'Y' THEN
             FND_MESSAGE.SET_NAME('WSH','WSH_DEL_ASSIGNED_ERROR');
             FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_info.delivery_id));
             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
             wsh_util_core.add_message(x_return_status);
             RETURN;
          END IF;
       END IF;



  EXCEPTION
       WHEN others THEN
          wsh_util_core.default_handler('WSH_DELIVERIES_PUB.Validate_Delivery');
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

  END Validate_Delivery;

/* I Harmonization -- rvishnuv */
  PROCEDURE map_pub_to_pvt(
    p_pub_rec IN delivery_pub_rec_type,
    x_pvt_rec OUT NOCOPY wsh_new_deliveries_pvt.delivery_rec_type,
    x_return_status OUT NOCOPY VARCHAR2)
  IS
    --
l_debug_on BOOLEAN;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MAP_PUB_TO_PVT';

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
      WSH_DEBUG_SV.push(l_module_name);
    END IF;
    x_return_status := wsh_util_core.g_ret_sts_success;
    --
    x_pvt_rec.DELIVERY_ID     := p_pub_rec.DELIVERY_ID;
    x_pvt_rec.NAME        := p_pub_rec.NAME;
    x_pvt_rec.DELIVERY_TYPE     := p_pub_rec.DELIVERY_TYPE;
    x_pvt_rec.LOADING_SEQUENCE      := p_pub_rec.LOADING_SEQUENCE;
    x_pvt_rec.LOADING_ORDER_FLAG    := p_pub_rec.LOADING_ORDER_FLAG;
    x_pvt_rec.LOADING_ORDER_DESC    := p_pub_rec.LOADING_ORDER_DESC;
    x_pvt_rec.INITIAL_PICKUP_DATE   := p_pub_rec.INITIAL_PICKUP_DATE;
    x_pvt_rec.INITIAL_PICKUP_LOCATION_ID  := p_pub_rec.INITIAL_PICKUP_LOCATION_ID;
    x_pvt_rec.INITIAL_PICKUP_LOCATION_CODE  := p_pub_rec.INITIAL_PICKUP_LOCATION_CODE;
    x_pvt_rec.ORGANIZATION_ID     := p_pub_rec.ORGANIZATION_ID;
    x_pvt_rec.ORGANIZATION_CODE     := p_pub_rec.ORGANIZATION_CODE;
    x_pvt_rec.ULTIMATE_DROPOFF_LOCATION_ID  := p_pub_rec.ULTIMATE_DROPOFF_LOCATION_ID;
    x_pvt_rec.ULTIMATE_DROPOFF_LOCATION_CODE  := p_pub_rec.ULTIMATE_DROPOFF_LOCATION_CODE;
    x_pvt_rec.ULTIMATE_DROPOFF_DATE   := p_pub_rec.ULTIMATE_DROPOFF_DATE;
    x_pvt_rec.CUSTOMER_ID     := p_pub_rec.CUSTOMER_ID;
    x_pvt_rec.CUSTOMER_NUMBER     := p_pub_rec.CUSTOMER_NUMBER;
    x_pvt_rec.INTMED_SHIP_TO_LOCATION_ID  := p_pub_rec.INTMED_SHIP_TO_LOCATION_ID;
    x_pvt_rec.INTMED_SHIP_TO_LOCATION_CODE  := p_pub_rec.INTMED_SHIP_TO_LOCATION_CODE;
    x_pvt_rec.POOLED_SHIP_TO_LOCATION_ID  := p_pub_rec.POOLED_SHIP_TO_LOCATION_ID;
    x_pvt_rec.POOLED_SHIP_TO_LOCATION_CODE  := p_pub_rec.POOLED_SHIP_TO_LOCATION_CODE;
    x_pvt_rec.CARRIER_ID      := p_pub_rec.CARRIER_ID;
    x_pvt_rec.CARRIER_CODE      := p_pub_rec.CARRIER_CODE;
    x_pvt_rec.SHIP_METHOD_CODE      := p_pub_rec.SHIP_METHOD_CODE;
    x_pvt_rec.SHIP_METHOD_NAME      := p_pub_rec.SHIP_METHOD_NAME;
    x_pvt_rec.FREIGHT_TERMS_CODE    := p_pub_rec.FREIGHT_TERMS_CODE;
    x_pvt_rec.FREIGHT_TERMS_NAME    := p_pub_rec.FREIGHT_TERMS_NAME;
    x_pvt_rec.FOB_CODE        := p_pub_rec.FOB_CODE;
    x_pvt_rec.FOB_NAME        := p_pub_rec.FOB_NAME;
    x_pvt_rec.FOB_LOCATION_ID     := p_pub_rec.FOB_LOCATION_ID;
    x_pvt_rec.FOB_LOCATION_CODE     := p_pub_rec.FOB_LOCATION_CODE;
    x_pvt_rec.WAYBILL       := p_pub_rec.WAYBILL;
    x_pvt_rec.DOCK_CODE       := p_pub_rec.DOCK_CODE;
    x_pvt_rec.ACCEPTANCE_FLAG     := p_pub_rec.ACCEPTANCE_FLAG;
    x_pvt_rec.ACCEPTED_BY     := p_pub_rec.ACCEPTED_BY;
    x_pvt_rec.ACCEPTED_DATE     := p_pub_rec.ACCEPTED_DATE;
    x_pvt_rec.ACKNOWLEDGED_BY     := p_pub_rec.ACKNOWLEDGED_BY;
    x_pvt_rec.CONFIRMED_BY      := p_pub_rec.CONFIRMED_BY;
    x_pvt_rec.CONFIRM_DATE      := p_pub_rec.CONFIRM_DATE;
    x_pvt_rec.ASN_DATE_SENT     := p_pub_rec.ASN_DATE_SENT;
    x_pvt_rec.ASN_STATUS_CODE     := p_pub_rec.ASN_STATUS_CODE;
    x_pvt_rec.ASN_SEQ_NUMBER      := p_pub_rec.ASN_SEQ_NUMBER;
    x_pvt_rec.GROSS_WEIGHT      := p_pub_rec.GROSS_WEIGHT;
    x_pvt_rec.NET_WEIGHT      := p_pub_rec.NET_WEIGHT;
    x_pvt_rec.WEIGHT_UOM_CODE     := p_pub_rec.WEIGHT_UOM_CODE;
    x_pvt_rec.WEIGHT_UOM_DESC     := p_pub_rec.WEIGHT_UOM_DESC;
    x_pvt_rec.VOLUME        := p_pub_rec.VOLUME;
    x_pvt_rec.VOLUME_UOM_CODE     := p_pub_rec.VOLUME_UOM_CODE;
    x_pvt_rec.VOLUME_UOM_DESC     := p_pub_rec.VOLUME_UOM_DESC;
    x_pvt_rec.ADDITIONAL_SHIPMENT_INFO    := p_pub_rec.ADDITIONAL_SHIPMENT_INFO;
    x_pvt_rec.CURRENCY_CODE     := p_pub_rec.CURRENCY_CODE;
    x_pvt_rec.CURRENCY_NAME     := p_pub_rec.CURRENCY_NAME;
    x_pvt_rec.ATTRIBUTE_CATEGORY    := p_pub_rec.ATTRIBUTE_CATEGORY;
    x_pvt_rec.ATTRIBUTE1      := p_pub_rec.ATTRIBUTE1;
    x_pvt_rec.ATTRIBUTE2      := p_pub_rec.ATTRIBUTE2;
    x_pvt_rec.ATTRIBUTE3      := p_pub_rec.ATTRIBUTE3;
    x_pvt_rec.ATTRIBUTE4      := p_pub_rec.ATTRIBUTE4;
    x_pvt_rec.ATTRIBUTE5      := p_pub_rec.ATTRIBUTE5;
    x_pvt_rec.ATTRIBUTE6      := p_pub_rec.ATTRIBUTE6;
    x_pvt_rec.ATTRIBUTE7      := p_pub_rec.ATTRIBUTE7;
    x_pvt_rec.ATTRIBUTE8      := p_pub_rec.ATTRIBUTE8;
    x_pvt_rec.ATTRIBUTE9      := p_pub_rec.ATTRIBUTE9;
    x_pvt_rec.ATTRIBUTE10     := p_pub_rec.ATTRIBUTE10;
    x_pvt_rec.ATTRIBUTE11     := p_pub_rec.ATTRIBUTE11;
    x_pvt_rec.ATTRIBUTE12     := p_pub_rec.ATTRIBUTE12;
    x_pvt_rec.ATTRIBUTE13     := p_pub_rec.ATTRIBUTE13;
    x_pvt_rec.ATTRIBUTE14     := p_pub_rec.ATTRIBUTE14;
    x_pvt_rec.ATTRIBUTE15     := p_pub_rec.ATTRIBUTE15;
    x_pvt_rec.TP_ATTRIBUTE_CATEGORY   := p_pub_rec.TP_ATTRIBUTE_CATEGORY;
    x_pvt_rec.TP_ATTRIBUTE1     := p_pub_rec.TP_ATTRIBUTE1;
    x_pvt_rec.TP_ATTRIBUTE2     := p_pub_rec.TP_ATTRIBUTE2;
    x_pvt_rec.TP_ATTRIBUTE3     := p_pub_rec.TP_ATTRIBUTE3;
    x_pvt_rec.TP_ATTRIBUTE4     := p_pub_rec.TP_ATTRIBUTE4;
    x_pvt_rec.TP_ATTRIBUTE5     := p_pub_rec.TP_ATTRIBUTE5;
    x_pvt_rec.TP_ATTRIBUTE6     := p_pub_rec.TP_ATTRIBUTE6;
    x_pvt_rec.TP_ATTRIBUTE7     := p_pub_rec.TP_ATTRIBUTE7;
    x_pvt_rec.TP_ATTRIBUTE8     := p_pub_rec.TP_ATTRIBUTE8;
    x_pvt_rec.TP_ATTRIBUTE9     := p_pub_rec.TP_ATTRIBUTE9;
    x_pvt_rec.TP_ATTRIBUTE10      := p_pub_rec.TP_ATTRIBUTE10;
    x_pvt_rec.TP_ATTRIBUTE11      := p_pub_rec.TP_ATTRIBUTE11;
    x_pvt_rec.TP_ATTRIBUTE12      := p_pub_rec.TP_ATTRIBUTE12;
    x_pvt_rec.TP_ATTRIBUTE13      := p_pub_rec.TP_ATTRIBUTE13;
    x_pvt_rec.TP_ATTRIBUTE14      := p_pub_rec.TP_ATTRIBUTE14;
    x_pvt_rec.TP_ATTRIBUTE15      := p_pub_rec.TP_ATTRIBUTE15;
    x_pvt_rec.GLOBAL_ATTRIBUTE_CATEGORY   := p_pub_rec.GLOBAL_ATTRIBUTE_CATEGORY;
    x_pvt_rec.GLOBAL_ATTRIBUTE1     := p_pub_rec.GLOBAL_ATTRIBUTE1;
    x_pvt_rec.GLOBAL_ATTRIBUTE2     := p_pub_rec.GLOBAL_ATTRIBUTE2;
    x_pvt_rec.GLOBAL_ATTRIBUTE3     := p_pub_rec.GLOBAL_ATTRIBUTE3;
    x_pvt_rec.GLOBAL_ATTRIBUTE4     := p_pub_rec.GLOBAL_ATTRIBUTE4;
    x_pvt_rec.GLOBAL_ATTRIBUTE5     := p_pub_rec.GLOBAL_ATTRIBUTE5;
    x_pvt_rec.GLOBAL_ATTRIBUTE6     := p_pub_rec.GLOBAL_ATTRIBUTE6;
    x_pvt_rec.GLOBAL_ATTRIBUTE7     := p_pub_rec.GLOBAL_ATTRIBUTE7;
    x_pvt_rec.GLOBAL_ATTRIBUTE8     := p_pub_rec.GLOBAL_ATTRIBUTE8;
    x_pvt_rec.GLOBAL_ATTRIBUTE9     := p_pub_rec.GLOBAL_ATTRIBUTE9;
    x_pvt_rec.GLOBAL_ATTRIBUTE10    := p_pub_rec.GLOBAL_ATTRIBUTE10;
    x_pvt_rec.GLOBAL_ATTRIBUTE11    := p_pub_rec.GLOBAL_ATTRIBUTE11;
    x_pvt_rec.GLOBAL_ATTRIBUTE12    := p_pub_rec.GLOBAL_ATTRIBUTE12;
    x_pvt_rec.GLOBAL_ATTRIBUTE13    := p_pub_rec.GLOBAL_ATTRIBUTE13;
    x_pvt_rec.GLOBAL_ATTRIBUTE14    := p_pub_rec.GLOBAL_ATTRIBUTE14;
    x_pvt_rec.GLOBAL_ATTRIBUTE15    := p_pub_rec.GLOBAL_ATTRIBUTE15;
    x_pvt_rec.GLOBAL_ATTRIBUTE16    := p_pub_rec.GLOBAL_ATTRIBUTE16;
    x_pvt_rec.GLOBAL_ATTRIBUTE17    := p_pub_rec.GLOBAL_ATTRIBUTE17;
    x_pvt_rec.GLOBAL_ATTRIBUTE18    := p_pub_rec.GLOBAL_ATTRIBUTE18;
    x_pvt_rec.GLOBAL_ATTRIBUTE19    := p_pub_rec.GLOBAL_ATTRIBUTE19;
    x_pvt_rec.GLOBAL_ATTRIBUTE20    := p_pub_rec.GLOBAL_ATTRIBUTE20;
    x_pvt_rec.CREATION_DATE     := p_pub_rec.CREATION_DATE;
    x_pvt_rec.CREATED_BY      := p_pub_rec.CREATED_BY;
    x_pvt_rec.LAST_UPDATE_DATE      := p_pub_rec.LAST_UPDATE_DATE;
    x_pvt_rec.LAST_UPDATED_BY     := p_pub_rec.LAST_UPDATED_BY;
    x_pvt_rec.LAST_UPDATE_LOGIN     := p_pub_rec.LAST_UPDATE_LOGIN;
    x_pvt_rec.PROGRAM_APPLICATION_ID    := p_pub_rec.PROGRAM_APPLICATION_ID;
    x_pvt_rec.PROGRAM_ID      := p_pub_rec.PROGRAM_ID;
    x_pvt_rec.PROGRAM_UPDATE_DATE   := p_pub_rec.PROGRAM_UPDATE_DATE;
    x_pvt_rec.REQUEST_ID      := p_pub_rec.REQUEST_ID;
    x_pvt_rec.NUMBER_OF_LPN     := p_pub_rec.NUMBER_OF_LPN;
    x_pvt_rec.COD_AMOUNT      := p_pub_rec.COD_AMOUNT;
    x_pvt_rec.COD_CURRENCY_CODE     := p_pub_rec.COD_CURRENCY_CODE;
    x_pvt_rec.COD_REMIT_TO      := p_pub_rec.COD_REMIT_TO;
    x_pvt_rec.COD_CHARGE_PAID_BY    := p_pub_rec.COD_CHARGE_PAID_BY;
    x_pvt_rec.PROBLEM_CONTACT_REFERENCE   := p_pub_rec.PROBLEM_CONTACT_REFERENCE;
    x_pvt_rec.PORT_OF_LOADING     := p_pub_rec.PORT_OF_LOADING;
    x_pvt_rec.PORT_OF_DISCHARGE     := p_pub_rec.PORT_OF_DISCHARGE;
    x_pvt_rec.FTZ_NUMBER      := p_pub_rec.FTZ_NUMBER;
    x_pvt_rec.ROUTED_EXPORT_TXN     := p_pub_rec.ROUTED_EXPORT_TXN;
    x_pvt_rec.ENTRY_NUMBER      := p_pub_rec.ENTRY_NUMBER;
    x_pvt_rec.ROUTING_INSTRUCTIONS    := p_pub_rec.ROUTING_INSTRUCTIONS;
    x_pvt_rec.IN_BOND_CODE      := p_pub_rec.IN_BOND_CODE;
    x_pvt_rec.SHIPPING_MARKS      := p_pub_rec.SHIPPING_MARKS;
    x_pvt_rec.SERVICE_LEVEL     := p_pub_rec.SERVICE_LEVEL;
    x_pvt_rec.MODE_OF_TRANSPORT     := p_pub_rec.MODE_OF_TRANSPORT;
    x_pvt_rec.ASSIGNED_TO_FTE_TRIPS   := p_pub_rec.ASSIGNED_TO_FTE_TRIPS;
    x_pvt_rec.PLANNED_FLAG              := FND_API.G_MISS_CHAR;
    x_pvt_rec.STATUS_CODE               := FND_API.G_MISS_CHAR;
    x_pvt_rec.BATCH_ID                  := FND_API.G_MISS_NUM;
    x_pvt_rec.HASH_VALUE                := FND_API.G_MISS_NUM;
    x_pvt_rec.SOURCE_HEADER_ID          := FND_API.G_MISS_NUM;
    x_pvt_rec.AUTO_SC_EXCLUDE_FLAG    := p_pub_rec.AUTO_SC_EXCLUDE_FLAG;
    x_pvt_rec.AUTO_AP_EXCLUDE_FLAG    := p_pub_rec.AUTO_AP_EXCLUDE_FLAG;
    x_pvt_rec.AP_BATCH_ID                 := FND_API.G_MISS_NUM;
    /*3667348*/
    x_pvt_rec.REASON_OF_TRANSPORT    := p_pub_rec.REASON_OF_TRANSPORT;
    x_pvt_rec.DESCRIPTION   := p_pub_rec.DESCRIPTION;
    -- Non Database field added for "Proration of weight from Delivery to delivery lines" Project(Bug#4254552).
    IF  p_pub_rec.prorate_wt_flag = FND_API.G_MISS_CHAR  THEN
    --{
       x_pvt_rec.prorate_wt_flag := WSH_UTIL_CORE.FTE_Is_Installed ;
    ELSIF p_pub_rec.prorate_wt_flag = 'Y' THEN
       x_pvt_rec.prorate_wt_flag := 'Y';
    ELSE
       x_pvt_rec.prorate_wt_flag := 'N';
    --}
    END IF;
    --
    -- LSP PROJECT : begin
    x_pvt_rec.client_id   := p_pub_rec.client_id;
    x_pvt_rec.client_code := p_pub_rec.client_code;
    -- LSP PROJECT : enb

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_DELIVERIES_PUB.map_pub_to_pvt',l_module_name);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  END map_pub_to_pvt;

--========================================================================
-- PROCEDURE : Create_Update_Delivery         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--         p_delivery_info         Attributes for the delivery entity
--             p_delivery_name         Delivery name for update
--              x_delivery_id - delivery_Id of new delivery,
--             x_name - Name of delivery
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_new_deliveries table
--             with information specified in p_delivery_info
--========================================================================

  PROCEDURE Create_Update_Delivery(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_delivery_info           IN OUT NOCOPY  Delivery_Pub_Rec_Type,
    p_delivery_name          IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    x_delivery_id            OUT NOCOPY   NUMBER,
    x_name                   OUT NOCOPY   VARCHAR2)

  IS

  l_api_version_number CONSTANT NUMBER := 1.0;
  l_api_name           CONSTANT VARCHAR2(30):= 'Create_Update_Delivery';

  -- <insert here your local variables declaration>
  l_message VARCHAR2(50);
  l_num_errors NUMBER;
  l_num_warnings NUMBER;
  l_rec_attr_tab      wsh_new_deliveries_pvt.delivery_attr_tbl_type;
  l_delivery_in_rec   wsh_deliveries_grp.Del_In_Rec_Type;
  l_del_out_rec_tab   wsh_deliveries_grp.Del_Out_Tbl_Type;
  l_return_status     VARCHAR2(1);
  l_commit            VARCHAR2(100) := FND_API.G_FALSE;
  l_weight_uom_code   VARCHAR2(10);
  l_volume_uom_code   VARCHAR2(10);
    --
  l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_DELIVERY_PUB';

  BEGIN
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
      wsh_debug_sv.push(l_module_name);
    END IF;
  -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number
      , p_api_version_number
      , l_api_name
      , G_PKG_NAME
      )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message stack if required
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;


    IF (p_action_code = 'UPDATE') THEN
      IF (p_delivery_name IS NOT NULL) OR (p_delivery_name <> FND_API.G_MISS_CHAR) THEN
        p_delivery_info.name := p_delivery_name;
      END IF;
    ELSIF ( p_action_code <> 'CREATE' ) THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_ACTION_CODE');
      FND_MESSAGE.SET_TOKEN('ACTION_CODE',p_action_code);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
    END IF;
    --
    map_pub_to_pvt(
      p_pub_rec  => p_delivery_info,
      x_pvt_rec  => l_rec_attr_tab(1),
      x_return_status => l_return_status);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling map_pub_to_pvt',l_return_status);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status => l_return_status,
      x_num_errors    => l_num_errors,
      x_num_warnings  => l_num_warnings);
    --
    IF (p_action_code = 'UPDATE') THEN
      --
      wsh_util_validate.validate_delivery_name(
        p_delivery_id   => l_rec_attr_tab(1).delivery_id,
        p_delivery_name => l_rec_attr_tab(1).name,
        x_return_status => l_return_status);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_delivery_name',l_return_status);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status => l_return_status,
        x_num_errors    => l_num_errors,
        x_num_warnings  => l_num_warnings);
      --
    -- bug 3666967 : else if p_action_code is 'CREATE'
    -- treating non passed parameters as FND_API.G_MISS_NUM
    ELSIF (p_action_code = 'CREATE') THEN
      IF (l_rec_attr_tab(1).gross_weight = FND_API.G_MISS_NUM AND
          l_rec_attr_tab(1).net_weight = FND_API.G_MISS_NUM AND
          l_rec_attr_tab(1).volume  = FND_API.G_MISS_NUM) THEN
        l_rec_attr_tab(1).wv_frozen_flag := 'N';
      ELSE
        l_rec_attr_tab(1).wv_frozen_flag := 'Y';
      END IF;

      --Added for bug 8369407
      IF (l_rec_attr_tab(1).ORGANIZATION_ID <> FND_API.G_MISS_NUM OR
          l_rec_attr_tab(1).ORGANIZATION_CODE <> FND_API.G_MISS_CHAR
          ) AND
         (l_rec_attr_tab(1).WEIGHT_UOM_CODE = FND_API.G_MISS_CHAR OR
          l_rec_attr_tab(1).VOLUME_UOM_CODE = FND_API.G_MISS_CHAR
          ) THEN
      --
         wsh_util_validate.validate_org( p_org_id        => l_rec_attr_tab(1).ORGANIZATION_ID ,
                                         p_org_code      => l_rec_attr_tab(1).ORGANIZATION_CODE ,
                                         x_return_status => l_return_status );
      --
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_org',l_return_status);
         END IF;
      --
         wsh_util_core.api_post_call(p_return_status => l_return_status,
                                     x_num_errors    => l_num_errors,
                                     x_num_warnings  => l_num_warnings );
      --
         wsh_wv_utils.get_default_uoms( p_organization_id => l_rec_attr_tab(1).ORGANIZATION_ID,
                                        x_weight_uom_code => l_weight_uom_code,
                                        x_volume_uom_code => l_volume_uom_code,
                                        x_return_status   => l_return_status );
      --
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling get_default_uoms',l_return_status);
         END IF;
      --
         wsh_util_core.api_post_call(p_return_status => l_return_status,
                                     x_num_errors    => l_num_errors,
                                     x_num_warnings  => l_num_warnings );
      --
         IF l_rec_attr_tab(1).WEIGHT_UOM_CODE = FND_API.G_MISS_CHAR THEN
            l_rec_attr_tab(1).WEIGHT_UOM_CODE := l_weight_uom_code ;
         END IF;
      --
         IF l_rec_attr_tab(1).VOLUME_UOM_CODE = FND_API.G_MISS_CHAR THEN
            l_rec_attr_tab(1).VOLUME_UOM_CODE := l_volume_uom_code ;
         END IF;
      --
      END IF;
    END IF;
      --
    l_delivery_in_rec.action_code := p_action_code;
    l_delivery_in_rec.caller := 'WSH_PUB';
    wsh_interface_grp.create_update_delivery(
      p_api_version_number =>  p_api_version_number,
      p_init_msg_list      =>  p_init_msg_list,
      p_commit             =>  l_commit,
      p_in_rec             =>  l_delivery_in_rec,
      p_rec_attr_tab       =>  l_rec_attr_tab,
      x_del_out_rec_tab    =>  l_del_out_rec_tab,
      x_return_status      =>  l_return_status,
      x_msg_count          =>  x_msg_count,
      x_msg_data           =>  x_msg_data);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling create_update_delivery',l_return_status);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status => l_return_status,
      x_num_errors    => l_num_errors,
      x_num_warnings  => l_num_warnings,
      p_msg_data      => x_msg_data);
     --
    --
    IF l_del_out_rec_tab.COUNT <> 0 THEN
      --
      x_delivery_id    := l_del_out_rec_tab(l_del_out_rec_tab.COUNT).delivery_id;
      x_name           := l_del_out_rec_tab(l_del_out_rec_tab.COUNT).name;
      --
    END IF;
    --
    IF l_num_warnings > 0 THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
    ELSE
      x_return_status := wsh_util_core.g_ret_sts_success; --bug 2398628
    END IF;
    --
    FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     );
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg
           ( G_PKG_NAME
           , '_x_'
           );
        END IF;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
  END Create_Update_Delivery;

  PROCEDURE Delivery_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2,
    p_action_code            IN   VARCHAR2,
    p_delivery_id            IN   NUMBER DEFAULT NULL,
    p_delivery_name          IN   VARCHAR2 DEFAULT NULL,
    p_asg_trip_id            IN   NUMBER DEFAULT NULL,
    p_asg_trip_name          IN   VARCHAR2 DEFAULT NULL,
    p_asg_pickup_stop_id     IN   NUMBER DEFAULT NULL,
    p_asg_pickup_loc_id      IN   NUMBER DEFAULT NULL,
    p_asg_pickup_stop_seq    IN   NUMBER DEFAULT NULL,
    p_asg_pickup_loc_code    IN   VARCHAR2 DEFAULT NULL,
    p_asg_pickup_arr_date    IN   DATE   DEFAULT NULL,
    p_asg_pickup_dep_date    IN   DATE   DEFAULT NULL,
    p_asg_dropoff_stop_id    IN   NUMBER DEFAULT NULL,
    p_asg_dropoff_loc_id     IN   NUMBER DEFAULT NULL,
    p_asg_dropoff_stop_seq   IN   NUMBER DEFAULT NULL,
    p_asg_dropoff_loc_code   IN   VARCHAR2 DEFAULT NULL,
    p_asg_dropoff_arr_date   IN   DATE   DEFAULT NULL,
    p_asg_dropoff_dep_date   IN   DATE   DEFAULT NULL,
    p_sc_action_flag         IN   VARCHAR2 DEFAULT 'S',
    p_sc_intransit_flag      IN   VARCHAR2 DEFAULT 'N',
    p_sc_close_trip_flag     IN   VARCHAR2 DEFAULT 'N',
    p_sc_create_bol_flag     IN   VARCHAR2 DEFAULT 'N',
    p_sc_stage_del_flag      IN   VARCHAR2 DEFAULT 'Y',
    p_sc_trip_ship_method    IN   VARCHAR2 DEFAULT NULL,
    p_sc_actual_dep_date     IN   DATE     DEFAULT NULL,
    p_sc_report_set_id       IN   NUMBER DEFAULT NULL,
    p_sc_report_set_name     IN   VARCHAR2 DEFAULT NULL,
    p_sc_defer_interface_flag IN  VARCHAR2 DEFAULT 'Y',
    p_sc_send_945_flag          IN   VARCHAR2 DEFAULT NULL,
    p_sc_rule_id             IN   NUMBER DEFAULT NULL,
    p_sc_rule_name           IN   VARCHAR2 DEFAULT NULL,
    p_wv_override_flag       IN   VARCHAR2 DEFAULT 'N',
    x_trip_id                OUT NOCOPY   VARCHAR2,
    x_trip_name              OUT NOCOPY   VARCHAR2)
    --
  IS
    --
    l_api_version_number CONSTANT NUMBER := 1.0;
    l_api_name           CONSTANT VARCHAR2(30):= 'Delivery_Action';
    --
l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELIVERY_ACTION_PUB';
    --
    --
    l_action_prms wsh_deliveries_grp.action_parameters_rectype;
    l_del_action_out_rec wsh_deliveries_grp.Delivery_Action_Out_Rec_Type;
    l_delivery_id_tab    wsh_util_core.id_tab_type;
    --
    l_delivery_id  NUMBER := p_delivery_id;
    --
    l_num_errors   NUMBER := 0;
    l_num_warnings NUMBER := 0;
    l_return_status VARCHAR2(1);
    l_first        NUMBER := 0;
    l_commit            VARCHAR2(100) := FND_API.G_FALSE;
    --
  BEGIN
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
      wsh_debug_sv.push(l_module_name);
    END IF;
    --
  -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number
      , p_api_version_number
      , l_api_name
      , G_PKG_NAME
      )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message stack if required
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

   wsh_util_validate.validate_delivery_name(
     p_delivery_id   => l_delivery_id,
     p_delivery_name => p_delivery_name,
     x_return_status => l_return_status);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling validate_delivery_name',l_return_status);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status => l_return_status,
      x_num_errors    => l_num_errors,
      x_num_warnings  => l_num_warnings);
    --
    l_action_prms.caller    := 'WSH_PUB';
    l_action_prms.action_code     := p_action_code;
    --
    -- initializing the action specific parameters
    l_action_prms.trip_id   := p_asg_trip_id;
    l_action_prms.trip_name   := p_asg_trip_name;
    l_action_prms.pickup_stop_id  := p_asg_pickup_stop_id;
    l_action_prms.pickup_loc_id   := p_asg_pickup_loc_id;
    l_action_prms.pickup_stop_seq := p_asg_pickup_stop_seq;
    l_action_prms.pickup_loc_code := p_asg_pickup_loc_code;
    l_action_prms.pickup_arr_date := p_asg_pickup_arr_date;
    l_action_prms.pickup_dep_date := p_asg_pickup_dep_date;
    l_action_prms.dropoff_stop_id := p_asg_dropoff_stop_id;
    l_action_prms.dropoff_loc_id  := p_asg_dropoff_loc_id;
    l_action_prms.dropoff_stop_seq  := p_asg_dropoff_stop_seq;
    l_action_prms.dropoff_loc_code  := p_asg_dropoff_loc_code;
    l_action_prms.dropoff_arr_date  := p_asg_dropoff_arr_date;
    l_action_prms.dropoff_dep_date  := p_asg_dropoff_dep_date;
    l_action_prms.action_flag     := p_sc_action_flag;
    l_action_prms.intransit_flag  := p_sc_intransit_flag;
    l_action_prms.close_trip_flag     := p_sc_close_trip_flag;
    l_action_prms.bill_of_lading_flag     := p_sc_create_bol_flag;
    l_action_prms.stage_del_flag      := p_sc_stage_del_flag;
    l_action_prms.ship_method_code    := p_sc_trip_ship_method;
    l_action_prms.actual_dep_date     := p_sc_actual_dep_date;
    l_action_prms.report_set_id   := p_sc_report_set_id;
    l_action_prms.report_set_name := p_sc_report_set_name;
    l_action_prms.defer_interface_flag  := p_sc_defer_interface_flag;
    l_action_prms.send_945_flag   := p_sc_send_945_flag;
    l_action_prms.sc_rule_id      := p_sc_rule_id;
    l_action_prms.sc_rule_name    := p_sc_rule_name;
    l_action_prms.override_flag   := p_wv_override_flag;
    IF p_action_code = 'WT-VOL' THEN
       l_action_prms.override_flag := 'Y';
    END IF;
    --
    l_delivery_id_tab(1)    := l_delivery_id;
    --
    wsh_interface_grp.Delivery_Action(
      p_api_version_number     =>  p_api_version_number,
      p_init_msg_list          =>  p_init_msg_list,
      p_commit                 =>  l_commit,
      p_action_prms            =>  l_action_prms,
      p_delivery_id_tab        =>  l_delivery_id_tab,
      x_delivery_out_rec       =>  l_del_action_out_rec,
      x_return_status          =>  x_return_status,
      x_msg_count              =>  x_msg_count,
      x_msg_data               =>  x_msg_data);
    --
    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Return Status After Calling Delivery_Action Wrapper',x_return_status);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status => x_return_status,
      x_num_errors    => l_num_errors,
      x_num_warnings  => l_num_warnings);
    --
    IF p_action_code = 'AUTOCREATE-TRIP' THEN
      IF l_del_action_out_rec.result_id_tab.count > 0 THEN
        l_first := l_del_action_out_rec.result_id_tab.first;
        IF l_del_action_out_rec.result_id_tab(l_first) IS NOT NULL THEN
          x_trip_id   := l_del_action_out_rec.result_id_tab(l_first);
          x_trip_name := wsh_trips_pvt.get_name(l_del_action_out_rec.result_id_tab(l_first));
        END IF;
      END IF;
    END IF;
    --
    IF l_num_warnings > 0 THEN
      x_return_status := wsh_util_core.g_ret_sts_warning;
    ELSE
      x_return_status := wsh_util_core.g_ret_sts_success; --bug 2398628
    END IF;
    --
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count
      , p_data  => x_msg_data
      );
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg
           ( G_PKG_NAME
           , '_x_'
           );
        END IF;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --

  END Delivery_Action;

--============================================================================
-- PROCEDURE   : Generate_Documents            PUBLIC API
--
-- PARAMETERS  : p_report_set_name             Report Set Name
--               p_organization_code           Organization Code
--               p_delivery_name               Delivery Name's
--               x_msg_count                   Error Message Count
--               x_msg_data                    Error Message
--               x_return_status               Return Status
--
-- VERSION     : current version               1.0
--               initial version               1.0
--
-- COMMENT     : This Procedure is created for Backward Compatability.
--               This procedure inturn calls procedure Delivery_Actions for
--               generating documents.
--
-- CREATED  BY : version 1.0.1                 UESHANKA
-- CREATION DT : version 1.0.1                 12/MAR/2003
--
--============================================================================

  PROCEDURE Generate_Documents
             ( p_report_set_name       IN   VARCHAR2,
               p_organization_code     IN   VARCHAR2,
               p_delivery_name         IN   WSH_UTIL_CORE.Column_Tab_Type,
               x_msg_count             OUT  NOCOPY  NUMBER,
               x_msg_data              OUT  NOCOPY  VARCHAR2,
               x_return_status         OUT  NOCOPY  VARCHAR2
             ) IS
 -- Local Variables
    l_delivery_count          NUMBER;
    l_count                   NUMBER;
    l_delivery_id             NUMBER;
    l_delivery_name           WSH_NEW_DELIVERIES.Name%TYPE;
    l_num_errors              NUMBER;
    l_num_warnings            NUMBER;

--  Debug Variables
    l_debug_on                BOOLEAN;
    l_module_name             CONSTANT VARCHAR2(75) := 'WSH.PLSQL.' ||
                                                        G_PKG_NAME  ||
                                                        '.Generate_Documents';

 -- Parameter Variables for WSH_DOCUMENT_SET.Print_Document_Sets
    l_report_set_id           NUMBER;
    l_organization_id         NUMBER;
    l_trip_id                 WSH_TRIPS.Trip_Id%TYPE;
    l_trip_name               WSH_TRIPS.Name%TYPE;
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(500);
    l_return_status           VARCHAR2(1);
    l_delivery_ids            WSH_UTIL_CORE.Id_Tab_Type;
    l_document_param_info     WSH_DOCUMENT_SETS.Document_Set_Tab_Type;

 -- Exception
    WSH_INVALID_ORGANIZATION  EXCEPTION;
    WSH_INVALID_DELIVERY      EXCEPTION;
  BEGIN
 -- Enabling Debug Starts
    l_debug_on := WSH_DEBUG_INTERFACE.G_DEBUG;

    IF ( l_debug_on IS NULL ) THEN
      l_debug_on := WSH_DEBUG_SV.Is_Debug_Enabled;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.Push(l_module_name, 'Generate_Documents');
      WSH_DEBUG_SV.Logmsg(l_module_name, 'Parameters passed to Generate_Documents');
      WSH_DEBUG_SV.Logmsg(l_module_name, 'P_Report_Set_Name   => ' || p_report_set_name);
      WSH_DEBUG_SV.Logmsg(l_module_name, 'P_Organization_Code => ' || p_organization_code);
      IF p_delivery_name.count > 0 THEN
        WSH_DEBUG_SV.Logmsg(l_module_name, 'Delivery Names Passed : ');
      FOR i IN 1..p_delivery_name.count LOOP
        WSH_DEBUG_SV.Logmsg(l_module_name, 'P_Delivery_Name(' || i || ') => '
                                                 || p_delivery_name(i));
      END LOOP;
      END IF;
    END IF;

 -- Assigning Success to x_return_status Initially
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    l_count := 0;

 -- Validation of Organization_Code
    WSH_UTIL_VALIDATE.Validate_Org(
                      l_organization_id  ,
                      p_organization_code,
                      x_return_status    );
    IF l_debug_on THEN
      WSH_DEBUG_SV.Logmsg(l_module_name, 'Return status from Validate_Org : ' || x_return_status);
    END IF;

    IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      RAISE WSH_INVALID_ORGANIZATION;
    END IF;

 -- Validation of Delivery Names
    l_delivery_count := p_delivery_name.count;

    IF (nvl(l_delivery_count, 0) > 0) THEN
      BEGIN
      FOR i in 1..l_delivery_count LOOP

        l_delivery_name := p_delivery_name(i);
        l_delivery_id   := NULL;
        WSH_UTIL_VALIDATE.Validate_Delivery_Name(
                          l_delivery_id  ,
                          l_delivery_name,
                          x_return_status);
        IF l_debug_on THEN
          WSH_DEBUG_SV.Logmsg(l_module_name, 'Return status for Delivery Name (' ||
                                             l_delivery_name || ') : ' || x_return_status);
        END IF;

        IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          FND_MESSAGE.Set_Name('WSH', 'WSH_INVALID_DELIVERY');
          FND_MESSAGE.Set_Token('DELIVERY', l_delivery_name);
          WSH_UTIL_CORE.Add_Message(x_return_status);
        ELSE
          l_count := l_count + 1;
          l_delivery_ids(l_count) := l_delivery_id;
        END IF;

      END LOOP;
      END;
    ELSE
      RAISE WSH_INVALID_DELIVERY;
    END IF;

 -- WSH_DELIVERIES_PUB.Delivery_Actions called for generating and printing reports.
    IF (l_count > 0) THEN
      FOR i IN 1..l_count LOOP -- { l_Count For Loop

        l_delivery_id := l_delivery_ids(i);
        WSH_DELIVERIES_PUB.Delivery_Action(
                           p_api_version_number  =>  1.0,
                           p_init_msg_list       =>  'F',
                           p_action_code         =>  'PRINT-DOC-SETS',
                           p_sc_report_set_name  =>  p_report_set_name,
                           p_delivery_id         =>  l_delivery_id  ,
                           x_msg_count           =>  l_msg_count,
                           x_msg_data            =>  l_msg_data,
                           x_trip_id             =>  l_trip_id ,
                           x_trip_name           =>  l_trip_name,
                           x_return_status       =>  l_return_status);

        WSH_UTIL_CORE.Api_Post_Call(
                    p_return_status  =>  l_return_status,
                    x_num_errors     =>  l_num_errors   ,
                    x_num_warnings   =>  l_num_warnings );

        IF l_debug_on THEN
          WSH_DEBUG_SV.Logmsg(l_module_name, 'Return status for Delivery Id (' ||
                                             l_delivery_id || ') : ' || l_return_status);
        END IF;

      END LOOP;  -- } l_Count For Loop.

      IF l_num_warnings > 0 THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      END IF;

    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.Logmsg(l_module_name,
              'Deliveries passed are Invalid for generating ' || upper(p_report_set_name));
      END IF;

    END IF;

    FND_MSG_PUB.Count_And_Get(
                p_count  => x_msg_count,
                p_data   => x_msg_data );

    IF l_debug_on THEN
      WSH_DEBUG_SV.Pop(l_module_name);
    END IF;

 -- Exception Handling Block
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.Logmsg(l_module_name,
                              'Expected error occured. Oracle error message is ' || SQLERRM,
                              WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.Pop(l_module_name, 'EXCEPTION: FND_API.G_EXC_ERROR');
        END IF;
        FND_MSG_PUB.Count_And_Get(
                    p_count  => x_msg_count,
                    p_data   => x_msg_data );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.Logmsg(l_module_name,
                              'Unexpected error occured. Oracle error message is ' || SQLERRM,
                              WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.Pop(l_module_name, 'EXCEPTION: FND_API.G_EXC_UNEXPECTED_ERROR');
        END IF;
        FND_MSG_PUB.Count_And_Get(
                    p_count  => x_msg_count,
                    p_data   => x_msg_data );

      WHEN WSH_INVALID_ORGANIZATION THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.Logmsg(l_module_name, 'WSH_INVALID_ORGANIZATION : ' || x_return_status);
        END IF;
        FND_MSG_PUB.Count_And_Get(
                    p_count  => x_msg_count,
                    p_data   => x_msg_data );

      WHEN WSH_INVALID_DELIVERY THEN
        FND_MESSAGE.Set_Name('WSH', 'WSH_DOC_INVALID_DELIVERY');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.Logmsg(l_module_name, 'WSH_INVALID_DELIVERY : ' || x_return_status);
        END IF;
        WSH_UTIL_CORE.Add_Message(x_return_status);
        FND_MSG_PUB.Count_And_Get(
                    p_count  => x_msg_count,
                    p_data   => x_msg_data );

      WHEN OTHERS THEN
        WSH_UTIL_CORE.Default_Handler('WSH_DELIVERIES_PUB.GENEREATE_DOCUMENTS');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.Logmsg(l_module_name, 'Unexpected Error : ' || x_return_status);
          WSH_DEBUG_SV.Logmsg(l_module_name, 'Error Message : ' || SQLERRM);
        END IF;
        FND_MSG_PUB.Count_And_Get(
                    p_count  => x_msg_count,
                    p_data   => x_msg_data );
  END Generate_Documents;



END WSH_DELIVERIES_PUB;

/
