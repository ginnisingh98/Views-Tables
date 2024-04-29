--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_AUTOCREATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_AUTOCREATE" as
/* $Header: WSHDEAUB.pls 120.26.12010000.4 2009/12/03 13:38:29 mvudugul ship $ */

g_hash_base NUMBER := 1;
g_hash_size NUMBER := power(2, 25);


G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DELIVERY_AUTOCREATE';
-----------------------------------------------------------------------------
--
-- Procedure:   Get_Group_By_Attr
-- Parameters:  p_organization_id, x_group_by_flags, x_return_status
-- Description: Gets group by attributes for the delivery organization
--              and stores this in a temporary table for future comparison
--              p_delivery_id           - Delivery ID
--        x_group_by_flags    - group by attributes record
--
-- LSP PROJECT : Added client Id parameter : Get the group by attributes from client
--          if cleint_id is not null. If client_id is null then get the grouping paramters
--          for the organization
-----------------------------------------------------------------------------

PROCEDURE get_group_by_attr (
                p_organization_id       IN      NUMBER,
                p_client_id             IN      NUMBER DEFAULT NULL,
                x_group_by_flags    OUT NOCOPY   group_by_flags_rec_type,
                x_return_status OUT NOCOPY      VARCHAR2,
                p_group_by_header_flag IN VARCHAR2 DEFAULT 'N') IS

default_group_by_info   group_by_flags_rec_type;

l_autocreate_del_orders_flag    varchar2(1);
l_error_code number := NULL;
l_error_text varchar2(2000) := NULL;
l_shipping_params WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
l_client_params              inv_cache.ct_rec_type; -- LSP PROJECT

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_GROUP_BY_ATTR';

BEGIN
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
            WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
            -- LSP PROJECT
            WSH_DEBUG_SV.log(l_module_name,'P_CLIENT_ID',p_client_id);
            WSH_DEBUG_SV.log(l_module_name,'P_GROUP_BY_HEADER_FLAG',p_group_by_header_flag);
            -- LSP PROJECT
        END IF;
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        -- LSP PROJECT :
        IF (p_organization_id IS NULL and p_client_id IS NULL) THEN
                group_by_info := default_group_by_info;
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                --
                RETURN;
        END IF;

        -- LSP PROJECT: Get delivery grouping attributes from Client parameters.
        IF ( p_client_id IS NOT NULL AND WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'L' ) THEN
        --{
            -- Call to get client specific parameters.
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Calling INV_CACHE.GET_CLIENT_DEFAULT_PARAMETERS', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            inv_cache.get_client_default_parameters (
                p_client_id             => p_client_id,
                x_client_parameters_rec => l_client_params,
                x_return_status         => x_return_status);
            IF ( x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS ) THEN
            --{
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                wsh_util_core.add_message(x_return_status);
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                --
                RETURN;
            --}
            END IF;
            group_by_info.customer      := l_client_params.client_rec.GROUP_BY_CUSTOMER_FLAG;
            group_by_info.intmed        := 'N';
            group_by_info.fob           := l_client_params.client_rec.GROUP_BY_FOB_FLAG;
            group_by_info.freight_terms := l_client_params.client_rec.GROUP_BY_FREIGHT_TERMS_FLAG;
            group_by_info.ship_method   := l_client_params.client_rec.GROUP_BY_SHIP_METHOD_FLAG;
            group_by_info.carrier       := 'N';
            IF p_group_by_header_flag = 'N' THEN
              group_by_info.header := 'N';
            ELSE
              group_by_info.header := NVL(p_group_by_header_flag,l_client_params.client_rec.AUTOCREATE_DEL_ORDERS_FLAG);
            END IF;
            x_group_by_flags := group_by_info;
            --
        --}
        ELSE
        --{
            IF group_by_info_tab.exists(p_organization_id) THEN
              group_by_info := group_by_info_tab(p_organization_id);
              -- Bug 3575807
              -- The grouping flags are cached. If assignment is done in the
              -- same session as autocreate, we will use the flag for the groupby header
              -- that we used for autocreate, however this flag is not applicable
              -- to assignment, only to autocreate deliveries.
              IF p_group_by_header_flag = 'N' THEN
                group_by_info.header := 'N';
              END IF;
              --
              -- Debug Statements
              --
              --
              x_group_by_flags := group_by_info;
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.customer ' || group_by_info.customer  );
                WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.intmed ' || group_by_info.intmed  );
                WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.fob ' || group_by_info.fob  );
                WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.freight_terms ' || group_by_info.freight_terms  );
                WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.ship_method ' || group_by_info.ship_method  );
                WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.carrier ' || group_by_info.carrier  );
                WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.header ' || group_by_info.header  );
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              RETURN;
            END IF;
            --
            WSH_SHIPPING_PARAMS_PVT.Get(p_organization_id => p_organization_id,
                                    x_param_info      => l_shipping_params,
                                    x_return_status   => x_return_status);


            IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_SHP_NOT_FOUND');
              --
              -- Debug Statements
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_ORG_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              FND_MESSAGE.SET_TOKEN('ORG_NAME',wsh_util_core.get_org_name(p_organization_id));
              x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              wsh_util_core.add_message(x_return_status);
              --
              -- Debug Statements
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              RETURN;
            END IF;
            group_by_info.customer := l_shipping_params.GROUP_BY_CUSTOMER_FLAG;
            group_by_info.intmed := l_shipping_params.GROUP_BY_INTMED_SHIP_TO_FLAG;
            group_by_info.fob := l_shipping_params.GROUP_BY_FOB_FLAG;
            group_by_info.freight_terms := l_shipping_params.GROUP_BY_FREIGHT_TERMS_FLAG;
            group_by_info.ship_method := l_shipping_params.GROUP_BY_SHIP_METHOD_FLAG;
            group_by_info.carrier := l_shipping_params.GROUP_BY_CARRIER_FLAG;
            group_by_info.header := NVL(p_group_by_header_flag, l_shipping_params.AUTOCREATE_DEL_ORDERS_FLAG);

            group_by_info_tab(p_organization_id) := group_by_info;
            group_by_info_tab(p_organization_id).header := l_shipping_params.AUTOCREATE_DEL_ORDERS_FLAG;

            x_group_by_flags := group_by_info;
        --}
        END IF;
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.customer ' || group_by_info.customer  );
          WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.intmed ' || group_by_info.intmed  );
          WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.fob ' || group_by_info.fob  );
          WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.freight_terms ' || group_by_info.freight_terms  );
          WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.ship_method ' || group_by_info.ship_method  );
          WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.carrier ' || group_by_info.carrier  );
          WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.header ' || group_by_info.header  );
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
--
EXCEPTION
        WHEN Others THEN
           l_error_code := SQLCODE;
           l_error_text := SQLERRM;
           --
           -- Debug Statements
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM GET_GROUP_BY_ATTR IS ' || L_ERROR_TEXT  );
           END IF;
           --
           wsh_util_core.default_handler('WSH_DELIVERY_AUTOCREATE.GET_GROUP_BY_ATTR');
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END get_group_by_attr;



-- Create_Hash: This API will create a hash_string and generate corresponding hash value based on the
--              grouping attributes of the input records. It will not append the ship method
--              code or its components to the hash string.
-- p_grouping_attributes: record of attributes or entity that needs hash generated.

Procedure Create_Hash(p_grouping_attributes IN OUT NOCOPY grp_attr_tab_type,
          p_group_by_header IN varchar2,
          p_action_code IN varchar2,
          x_return_status OUT NOCOPY  VARCHAR2) IS


--bmso
CURSOR c_detail_group (p_dd_id IN NUMBER) IS
SELECT          NULL,
                NULL,
                wdd.delivery_detail_id,
                NULL,
                wdd.released_status,
                NULL,
                wdd.ship_to_location_id,
                wdd.ship_from_location_id,
                wdd.customer_id,
                wdd.intmed_ship_to_location_id,
                wdd.fob_code,
                wdd.freight_terms_code,
                wdd.ship_method_code,
                wdd.carrier_id,
                wdd.source_header_id,
                wdd.deliver_to_location_id,
                wdd.organization_id,
                wdd.date_scheduled,
                wdd.date_requested,
                wda.delivery_id,
                NVL(wdd.ignore_for_planning, 'N') ignore_for_planning, --J TP Release
                NVL(wdd.line_direction,'O') line_direction,   -- J-IB-NPARIKH
                wdd.shipping_control,   -- J-IB-NPARIKH
                wdd.vendor_id,   -- J-IB-NPARIKH
                wdd.party_id,   -- J-IB-NPARIKH
                wdd.mode_of_transport,
                wdd.service_level,
                wdd.lpn_id,
                wdd.inventory_item_id,
                wdd.source_code,
                wdd.container_flag,
                NULL,
                NULL,
                NULL,  -- X-dock, is_xdocked_flag
                wdd.client_id -- LSP PROJECT
FROM      wsh_delivery_details wdd,
          wsh_delivery_assignments_v wda
WHERE     wdd.delivery_detail_id = p_dd_id AND
          wdd.released_status <> 'D'AND
          wda.delivery_detail_id  = wdd.delivery_detail_id;

CURSOR          c_delivery_group (p_del_id IN NUMBER) IS
SELECT          NULL,
                NULL,
                wnd.delivery_id,
                NULL,
                wnd.status_code,
                NULL,
                wnd.ultimate_dropoff_location_id,
                wnd.initial_pickup_location_id,
                wnd.customer_id,
                wnd.intmed_ship_to_location_id,
                wnd.fob_code,
                wnd.freight_terms_code,
                wnd.ship_method_code,
                wnd.carrier_id,
                wnd.source_header_id,
                NULL,
                wnd.organization_id,
                wnd.initial_pickup_date,
                wnd.ultimate_dropoff_date,
                wnd.delivery_id,
                NVL(wnd.ignore_for_planning, 'N') ignore_for_planning, --J TP Release
                NVL(wnd.shipment_direction,'O') line_direction,   -- J-IB-NPARIKH
                wnd.shipping_control,   -- J-IB-NPARIKH
                wnd.vendor_id,   -- J-IB-NPARIKH
                wnd.party_id,   -- J-IB-NPARIKH
                wnd.mode_of_transport,
                wnd.service_level,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,  -- X-dock, is_xdocked_flag
                wnd.client_id  -- LSP PROJECT
FROM      wsh_new_deliveries wnd
WHERE     wnd.delivery_id = p_del_id;

i NUMBER;
l_grouping_attributes grp_attr_rec_type;
l1_hash_string  VARCHAR2(1000) := NULL;
l1_hash_value   NUMBER;
l_group_by_header VARCHAR2(1);

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_HASH';
BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       WSH_DEBUG_SV.logmsg(l_module_name,  'attributes count: '|| p_grouping_attributes.count);
   END IF;

 i :=  p_grouping_attributes.FIRST;
 WHILE i is NOT NULL LOOP

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'entity: '|| p_grouping_attributes(i).entity_type);
         WSH_DEBUG_SV.logmsg(l_module_name,  'entity_id: '|| p_grouping_attributes(i).entity_id);
         WSH_DEBUG_SV.logmsg(l_module_name,  'index: '||i);
      END IF;

      IF p_grouping_attributes(i).ship_to_location_id IS NULL OR p_grouping_attributes(i).ship_from_location_id IS NULL THEN

         IF p_grouping_attributes(i).entity_type = 'DELIVERY'
         AND p_grouping_attributes(i).entity_id IS NOT NULL THEN

           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,  'Before Calling c_delivery_group');
           END IF;

           OPEN c_delivery_group(p_grouping_attributes(i).entity_id);
           FETCH c_delivery_group INTO l_grouping_attributes;
           CLOSE c_delivery_group;

         ELSIF p_grouping_attributes(i).entity_type = 'DELIVERY_DETAIL'
         AND p_grouping_attributes(i).entity_id IS NOT NULL THEN

           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,  'Before Calling c_detail_group');
           END IF;


           OPEN c_detail_group(p_grouping_attributes(i).entity_id);
           FETCH c_detail_group INTO l_grouping_attributes;
           CLOSE c_detail_group;

         END IF;

         l_grouping_attributes.batch_id := p_grouping_attributes(i).batch_id;

      ELSE

         l_grouping_attributes := p_grouping_attributes(i);
         l_grouping_attributes.line_direction := NVL(p_grouping_attributes(i).line_direction, 'O');
         l_grouping_attributes.ignore_for_planning := NVL(p_grouping_attributes(i).ignore_for_planning, 'N');
      END IF;


      IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.header ' || p_group_by_header );
      END IF;

      -- LSP PROJECT : For matching groups at the time of pick release (action code ='MATCH_GROUPS_AT_PICK')
      --          ,defualt the "auto create delivery criteria" value from ORG/CLIENT defaults if
      --          passed value (group_by_header)is NULL.
      IF p_action_code IN ('AUTOCREATE_DELIVERIES','MATCH_GROUPS_AT_PICK') THEN

         l_group_by_header := p_group_by_header;

      ELSE

         l_group_by_header := 'N';

      END IF;
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.header ' || l_group_by_header );
        END IF;
      -- LSP PROJECT : Added client_id parameter.
      get_group_by_attr (
                p_organization_id => l_grouping_attributes.organization_id,
                p_client_id       => l_grouping_attributes.client_id,
                x_group_by_flags  => group_by_info,
                x_return_status   => x_return_status,
                p_group_by_header_flag => l_group_by_header);

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.header ' || group_by_info.header );
        END IF;

         --
         -- Line direction is also a mandatory grouping attribute.
         --
         --
         l1_hash_string := to_char(l_grouping_attributes.ship_to_location_id) ||'-'||  -- These three are always
                                                                              -- in the grouping rule
                          to_char(l_grouping_attributes.ship_from_location_id) ||'-'||
                          to_char(l_grouping_attributes.organization_id)
                          --bug fix 3286811
                          ||'-'|| (l_grouping_attributes.ignore_for_planning); --J TP Release




         --
         -- J-IB-NPARIKH-{
         --
         -- Adding other mandatory grouping attributes which are applicable only for inbound
         -- Attributes are:Shipping control, vendor id, party id, drop-ship customer id
         --
         -- For outbound, adding constants for these attributes as they are not applicable
         --
         IF l_grouping_attributes.line_direction IN ('O','IO')
         THEN
         --{
             l1_hash_string := l1_hash_string
                               || '-' || '!!!' -- Shipping control
                               || '-' || '1'   -- Vendor ID
                               || '-' || '1'   -- Party ID
                               || '-' || '1';  -- Drop-ship customer ID
         --}
         ELSE
         --{
             l1_hash_string := l1_hash_string || '-' || l_grouping_attributes.shipping_control;
             l1_hash_string := l1_hash_string || '-' || to_char(l_grouping_attributes.vendor_id);
             l1_hash_string := l1_hash_string || '-' || to_char(l_grouping_attributes.party_id);
             --
             p_grouping_attributes(i).shipping_control := l_grouping_attributes.shipping_control;
             p_grouping_attributes(i).vendor_id        := l_grouping_attributes.vendor_id;
             p_grouping_attributes(i).party_id         := l_grouping_attributes.party_id;
             --
             IF l_grouping_attributes.line_direction = 'D'
             THEN
             --{
                 l1_hash_string              := l1_hash_string
                                                || '-' || to_char(l_grouping_attributes.customer_id);
                 p_grouping_attributes(i).customer_id := l_grouping_attributes.customer_id;
             --}
             ELSE
             --{
                 l1_hash_string              := l1_hash_string || '-' || '1';
             --}
             END IF;

         --}
         END IF;
         --


         -- J-IB-NPARIKH-}

            p_grouping_attributes(i).ship_to_location_id := l_grouping_attributes.ship_to_location_id;
            p_grouping_attributes(i).ship_from_location_id := l_grouping_attributes.ship_from_location_id;
            p_grouping_attributes(i).organization_id := l_grouping_attributes.organization_id;
            p_grouping_attributes(i).ignore_for_planning := l_grouping_attributes.ignore_for_planning;
            p_grouping_attributes(i).line_direction      := l_grouping_attributes.line_direction;   -- J-IB-NPARIKH


    IF l_grouping_attributes.line_direction IN ('O','IO')    -- J-IB-NPARIKH
    THEN
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.customer ' || group_by_info.customer  );
               WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.intmed ' || group_by_info.intmed  );
               WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.fob ' || group_by_info.fob  );
               WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.freight_terms ' || group_by_info.freight_terms  );
               WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.ship_method ' || group_by_info.ship_method  );
               WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.carrier ' || group_by_info.carrier  );
               WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.customer ' || group_by_info.header  );
           END IF;
    --{
         IF (group_by_info.customer = 'Y') THEN
            l1_hash_string  := l1_hash_string ||'-'||to_char(l_grouping_attributes.customer_id);
            p_grouping_attributes(i).customer_id := l_grouping_attributes.customer_id;
         ELSE
            p_grouping_attributes(i).customer_id := NULL;
         END IF;
         IF (group_by_info.intmed = 'Y') THEN
            l1_hash_string  := l1_hash_string ||'-'||to_char(l_grouping_attributes.intmed_ship_to_location_id);
            p_grouping_attributes(i).intmed_ship_to_location_id := l_grouping_attributes.intmed_ship_to_location_id;
         ELSE
            p_grouping_attributes(i).intmed_ship_to_location_id := NULL;
         END IF;
         IF (group_by_info.fob = 'Y') THEN
            l1_hash_string  := l1_hash_string ||'-'||l_grouping_attributes.fob_code;
            p_grouping_attributes(i).fob_code := l_grouping_attributes.fob_code;
         ELSE
            p_grouping_attributes(i).fob_code := NULL;
         END IF;
         IF (group_by_info.freight_terms = 'Y') THEN
            l1_hash_string  := l1_hash_string ||'-'||l_grouping_attributes.freight_terms_code;
            p_grouping_attributes(i).freight_terms_code := l_grouping_attributes.freight_terms_code;
         ELSE
            p_grouping_attributes(i).freight_terms_code := NULL;
         END IF;
         IF (group_by_info.ship_method = 'Y') THEN
            p_grouping_attributes(i).carrier_id := l_grouping_attributes.carrier_id;
            p_grouping_attributes(i).mode_of_transport := l_grouping_attributes.mode_of_transport;
            p_grouping_attributes(i).service_level := l_grouping_attributes.service_level;
            p_grouping_attributes(i).ship_method_code := l_grouping_attributes.ship_method_code;
         ELSE
            p_grouping_attributes(i).carrier_id := NULL;
            p_grouping_attributes(i).mode_of_transport := NULL;
            p_grouping_attributes(i).service_level := NULL;
            p_grouping_attributes(i).ship_method_code := NULL;
         END IF;
         --LSP PROJECT : Begin : Add client to the delivery grouping attributes.
         IF (WMS_DEPLOY.wms_deployment_mode = 'L') THEN
             p_grouping_attributes(i).client_id := l_grouping_attributes.client_id;
         ELSE
             p_grouping_attributes(i).client_id := NULL;
         END IF;
         --LSP PROJECT : End
    --}
    END IF;

     IF (NVL(p_group_by_header, group_by_info.header) = 'Y'
        AND  l_grouping_attributes.line_direction IN ('O','IO') ) THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  'group_by_info.header ' || NVL(p_group_by_header, group_by_info.header)  );
        END IF;
        p_grouping_attributes(i).source_header_id := l_grouping_attributes.source_header_id;
     ELSE
        p_grouping_attributes(i).source_header_id := NULL;
     END IF;
        p_grouping_attributes(i).delivery_id := l_grouping_attributes.delivery_id;

     IF p_action_code = 'AUTOCREATE_DELIVERIES' THEN

        --  By default these will not be included in the hash string. They are checked
        --  though for each match of hash whether the criteria from wsh_tpa matches

        p_grouping_attributes(i).deliver_to_location_id := l_grouping_attributes.deliver_to_location_id;
        p_grouping_attributes(i).delivery_id := l_grouping_attributes.delivery_id;
        p_grouping_attributes(i).date_scheduled := l_grouping_attributes.date_scheduled;
        p_grouping_attributes(i).date_requested := l_grouping_attributes.date_requested;


/*
        IF l_grouping_attributes.status_code = 'C'   -- J-IB-NPARIKH
        THEN
         --{
             p_grouping_attributes(i).status_code  := 'IT';    -- J-IB-NPARIKH
             p_grouping_attributes(i).planned_flag := 'F';    -- J-IB-NPARIKH
         --}
         ELSIF l_grouping_attributes.status_code = 'L'   -- J-IB-NPARIKH
         THEN
         --{
             p_grouping_attributes(i).status_code  := 'CL';    -- J-IB-NPARIKH
             p_grouping_attributes(i).planned_flag := 'F';    -- J-IB-NPARIKH
         --}
         ELSE
         --{
   */
             p_grouping_attributes(i).status_code  := 'OP';
             p_grouping_attributes(i).planned_flag :=  'N';
         --}
         --END IF;

      END IF;




     p_grouping_attributes(i).l1_hash_string := l1_hash_string;


     l1_hash_value := dbms_utility.get_hash_value(
                              name => l1_hash_string,
                              base => g_hash_base,
                              hash_size =>g_hash_size );


     p_grouping_attributes(i).l1_hash_value := l1_hash_value;
     --
     -- Debug Statements

     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'L1_HASH_STRING '||L1_HASH_STRING ||' VALUE '||L1_HASH_VALUE  );
     END IF;


     --
     -- Debug Statements
     --

    IF i = p_grouping_attributes.last  THEN

       exit;

    END IF;

    i := p_grouping_attributes.next(i);


  END LOOP;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION

    WHEN Others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_DELIVERY_AUTOCREATE.Create_Hash');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;



END Create_Hash;

-- This API will create a hash based on the grouping attributes of the delivery
-- and update the hash_value and hash string in wsh_new_deliveries.
-- p_delivery_id : Delivery that needs hash value and string to be updated.

Procedure Create_Update_Hash(p_delivery_rec IN OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
                             x_return_status OUT NOCOPY varchar2) IS

l_grp_attr_tab grp_attr_tab_type;
l_tmp_grp_attr_tab grp_attr_tab_type;

FAIL_CREATE_HASH EXCEPTION;
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_HASH';
BEGIN

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
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      l_grp_attr_tab(1).ship_to_location_id := p_delivery_rec.ultimate_dropoff_location_id;
      l_grp_attr_tab(1).ship_from_location_id := p_delivery_rec.initial_pickup_location_id;
      l_grp_attr_tab(1).customer_id := p_delivery_rec.customer_id;
      l_grp_attr_tab(1).intmed_ship_to_location_id := p_delivery_rec.intmed_ship_to_location_id;
      l_grp_attr_tab(1).fob_code := p_delivery_rec.fob_code;
      l_grp_attr_tab(1).freight_terms_code := p_delivery_rec.freight_terms_code;
      l_grp_attr_tab(1).ship_method_code := p_delivery_rec.ship_method_code;
      l_grp_attr_tab(1).carrier_id := p_delivery_rec.carrier_id;
      l_grp_attr_tab(1).source_header_id := p_delivery_rec.source_header_id;
      l_grp_attr_tab(1).organization_id := p_delivery_rec.organization_id;
      l_grp_attr_tab(1).date_scheduled := p_delivery_rec.initial_pickup_date;
      l_grp_attr_tab(1).date_requested := p_delivery_rec.ultimate_dropoff_date;
      l_grp_attr_tab(1).ignore_for_planning := p_delivery_rec.ignore_for_planning;
      l_grp_attr_tab(1).line_direction := p_delivery_rec.shipment_direction;
      l_grp_attr_tab(1).shipping_control := p_delivery_rec.shipping_control;
      l_grp_attr_tab(1).vendor_id := p_delivery_rec.vendor_id;
      l_grp_attr_tab(1).party_id := p_delivery_rec.party_id;
      l_grp_attr_tab(1).client_id := p_delivery_rec.client_id; -- LSP PROJECT

      Create_Hash(p_grouping_attributes => l_grp_attr_tab,
                  p_group_by_header => 'N',
                  p_action_code => NULL,
                  x_return_status => x_return_status);


      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

         RAISE FAIL_CREATE_HASH;

      END IF;

      p_delivery_rec.hash_value := l_grp_attr_tab(1).l1_hash_value;

      p_delivery_rec.hash_string := l_grp_attr_tab(1).l1_hash_string;


      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;

EXCEPTION

      WHEN FAIL_CREATE_HASH THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('WSH','WSH_FAIL_CREATE_HASH');
         WSH_UTIL_CORE.Add_Message(x_return_status);
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'FAIL_CREATE_GROUP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FAIL_CREATE_HASH');
         END IF;
          --

      WHEN Others THEN
        WSH_UTIL_CORE.Default_Handler('WSH_DELIVERY_AUTOCREATE.Create_Update_Hash');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN

         WSH_DEBUG_SV.logmsg(l_module_name,'OTHERS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
          --


END Create_Update_Hash;


-- Create_Groupings: This API will group the attribute records together and update
--                   the group_id of each record. Records in the same group will
--                   share the same group_id.
-- p_attr_tab: Table of attributes to be grouped.


PROCEDURE Create_Groupings(p_attr_tab IN OUT NOCOPY grp_attr_tab_type,
                           p_group_tab IN OUT NOCOPY grp_attr_tab_type,
                           p_check_one_group varchar2,
                           p_action_code varchar2 DEFAULT NULL,
                           x_return_status out NOCOPY varchar2) IS

i NUMBER;
l_hashval_exists BOOLEAN;
l_group_index NUMBER;

MULTIPLE_GROUPS EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Groupings';
--
BEGIN
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
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  i :=  p_attr_tab.FIRST;
  WHILE i is NOT NULL LOOP

   -- X-dock
   IF p_attr_tab(i).is_xdocked_flag = 'Y' THEN
     -- Add this record to the group.
     p_attr_tab(i).group_id := null;
     goto end_of_loop;
   END IF;
   -- End of X-dock


   IF NOT (NVL(p_action_code, 'X') = 'AUTOCREATE_DELIVERIES' AND p_attr_tab(i).delivery_id IS NOT NULL) THEN

    l_hashval_exists := FALSE;
    l_group_index := p_attr_tab(i).l1_hash_value;

    WHILE NOT l_hashval_exists LOOP

    IF p_group_tab.exists(l_group_index) THEN

       -- Bugfix 5031971
       -- 1. Replaced OR with AND for NULL condition
       -- 2. Added code for Ship Method Code
       IF (p_group_tab(l_group_index).l1_hash_string = p_attr_tab(i).l1_hash_string)
       AND (((p_group_tab(l_group_index).carrier_id IS NULL) AND (p_attr_tab(i).carrier_id IS NULL))
        OR (p_attr_tab(i).carrier_id = p_group_tab(l_group_index).carrier_id))
       AND (((p_group_tab(l_group_index).ship_method_code IS NULL) AND (p_attr_tab(i).ship_method_code IS NULL))
        OR (p_attr_tab(i).ship_method_code = p_group_tab(l_group_index).ship_method_code))
       AND (((p_group_tab(l_group_index).service_level IS NULL) AND (p_attr_tab(i).service_level IS NULL))
        OR (p_attr_tab(i).service_level = p_group_tab(l_group_index).service_level))
       AND (((p_group_tab(l_group_index).mode_of_transport IS NULL) AND (p_attr_tab(i).mode_of_transport IS NULL))
        OR (p_attr_tab(i).mode_of_transport = p_group_tab(l_group_index).mode_of_transport))
       AND (((p_group_tab(l_group_index).delivery_id IS NULL)
        OR (p_attr_tab(i).delivery_id IS NULL))
        OR (p_attr_tab(i).delivery_id = p_group_tab(l_group_index).delivery_id))
       AND (p_attr_tab(i).source_header_id is NULL
        OR (p_attr_tab(i).source_header_id = p_group_tab(l_group_index).source_header_id))
       AND (NVL(p_attr_tab(i).batch_id,-1) = NVL(p_group_tab(l_group_index).batch_id, -1))
       AND (NVL(p_attr_tab(i).client_id,-1) = NVL(p_group_tab(l_group_index).client_id, -1)) --LSP PROJECT
       THEN

          -- Hash value exists, hash string/attributes match. Use this group.

          l_hashval_exists := TRUE;

          IF p_group_tab(l_group_index).carrier_id IS NULL
          AND p_attr_tab(i).carrier_id IS NOT NULL
          THEN

            p_group_tab(l_group_index).carrier_id := p_attr_tab(i).carrier_id;

          END IF;

          IF p_group_tab(l_group_index).service_level IS NULL
          AND p_attr_tab(i).service_level IS NOT NULL
          THEN

            p_group_tab(l_group_index).service_level := p_attr_tab(i).service_level;


          END IF;

          IF p_group_tab(l_group_index).mode_of_transport IS NULL
          AND p_attr_tab(i).mode_of_transport IS NOT NULL
          THEN

            p_group_tab(l_group_index).mode_of_transport := p_attr_tab(i).mode_of_transport;

          END IF;
          IF p_group_tab(l_group_index).ship_method_code IS NULL
          AND p_attr_tab(i).ship_method_code IS NOT NULL
          THEN

            p_group_tab(l_group_index).ship_method_code := p_attr_tab(i).ship_method_code;

          END IF;


          IF p_group_tab(l_group_index).delivery_id IS NULL
          AND p_attr_tab(i).delivery_id IS NOT NULL
          THEN

            p_group_tab(l_group_index).delivery_id := p_attr_tab(i).delivery_id;

          END IF;

          IF p_group_tab(l_group_index).source_header_id IS NULL
          AND p_attr_tab(i).source_header_id IS NOT NULL
          THEN

            p_group_tab(l_group_index).source_header_id := p_attr_tab(i).source_header_id;

          END IF;


          p_group_tab(l_group_index).date_scheduled := LEAST(p_attr_tab(i).date_scheduled, p_group_tab(l_group_index).date_scheduled);
          p_group_tab(l_group_index).date_requested := GREATEST(LEAST(p_attr_tab(i).date_requested, p_group_tab(l_group_index).date_requested), p_group_tab(l_group_index).date_scheduled);


          -- Add this record to the group.
          p_attr_tab(i).group_id := p_group_tab(l_group_index).group_id;

          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'Group: Hash String: '||p_group_tab(l_group_index).l1_hash_value);
              WSH_DEBUG_SV.logmsg(l_module_name,  'service_level: '||p_group_tab(l_group_index).service_level);
              WSH_DEBUG_SV.logmsg(l_module_name,  'mode_of_transport: '||p_group_tab(l_group_index).mode_of_transport);
	      WSH_DEBUG_SV.logmsg(l_module_name,  'ship_method_code: '||p_group_tab(l_group_index).ship_method_code);
              WSH_DEBUG_SV.logmsg(l_module_name,  'carrier_id: '||p_group_tab(l_group_index).carrier_id);
              WSH_DEBUG_SV.logmsg(l_module_name,  'delivery_id: '||p_group_tab(l_group_index).delivery_id);
              WSH_DEBUG_SV.logmsg(l_module_name,  'source_header_id: '||p_group_tab(l_group_index).source_header_id);
              WSH_DEBUG_SV.logmsg(l_module_name,  'group_id: '||p_group_tab(l_group_index).group_id);
              WSH_DEBUG_SV.logmsg(l_module_name,  'date_scheduled: '||p_group_tab(l_group_index).date_scheduled);
              WSH_DEBUG_SV.logmsg(l_module_name,  'date_requested: '||p_group_tab(l_group_index).date_requested);
          END IF;

       ELSE

       -- Index exists but the hash strings/attributes do not match.
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'Attribute: Hash String: '||p_attr_tab(i).l1_hash_value);
              WSH_DEBUG_SV.logmsg(l_module_name,  'service_level: '||p_attr_tab(i).service_level);
              WSH_DEBUG_SV.logmsg(l_module_name,  'mode_of_transport: '||p_attr_tab(i).mode_of_transport);
	      WSH_DEBUG_SV.logmsg(l_module_name,  'ship_method_code: '||p_attr_tab(i).ship_method_code);
              WSH_DEBUG_SV.logmsg(l_module_name,  'carrier_id: '||p_attr_tab(i).carrier_id);
              WSH_DEBUG_SV.logmsg(l_module_name,  'delivery_id: '||p_attr_tab(i).delivery_id);
              WSH_DEBUG_SV.logmsg(l_module_name,  'source_header_id: '||p_attr_tab(i).source_header_id);
              WSH_DEBUG_SV.logmsg(l_module_name,  'batch_id: '||p_attr_tab(i).batch_id);
              WSH_DEBUG_SV.logmsg(l_module_name,  'group_id: '||p_attr_tab(i).group_id);
              WSH_DEBUG_SV.logmsg(l_module_name,  'client_id: '||p_attr_tab(i).client_id);
          END IF;

          IF p_check_one_group = 'Y' THEN

          -- We have more than one group, error out.

             RAISE MULTIPLE_GROUPS;

          ELSE

          -- Bump up the index and continue looping.

          l_group_index := l_group_index + 1;
          l_hashval_exists := FALSE;

          END IF;

       END IF;

    ELSE


    -- Index does not exist. This is a new group.

       IF p_check_one_group = 'Y' and p_group_tab.count <> 0 THEN

       -- We have more than one group, error out.

          RAISE MULTIPLE_GROUPS;

       END IF;

       -- Use this hash value to create a new index in the group table
       -- and create a new group with these attributes.

       p_group_tab(l_group_index) := p_attr_tab(i);

       p_group_tab(l_group_index).date_requested := GREATEST(p_attr_tab(i).date_requested, p_attr_tab(i).date_scheduled);
       -- Generate a new group id and add this record to the group.
       --bug 7171766 created new recycle sequence
       select WSH_MATCH_GROUP_S.nextval into p_group_tab(l_group_index).group_id from dual;
       p_attr_tab(i).group_id := p_group_tab(l_group_index).group_id;

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'Group: Hash String: '||p_group_tab(l_group_index).l1_hash_value);
          WSH_DEBUG_SV.logmsg(l_module_name,  'service_level: '||p_group_tab(l_group_index).service_level);
          WSH_DEBUG_SV.logmsg(l_module_name,  'mode_of_transport: '||p_group_tab(l_group_index).mode_of_transport);
          WSH_DEBUG_SV.logmsg(l_module_name,  'ship_method_code: '||p_group_tab(l_group_index).ship_method_code);
          WSH_DEBUG_SV.logmsg(l_module_name,  'carrier_id: '||p_group_tab(l_group_index).carrier_id);
          WSH_DEBUG_SV.logmsg(l_module_name,  'delivery_id: '||p_group_tab(l_group_index).delivery_id);
          WSH_DEBUG_SV.logmsg(l_module_name,  'source_header_id: '||p_group_tab(l_group_index).source_header_id);
          WSH_DEBUG_SV.logmsg(l_module_name,  'group_id: '||p_group_tab(l_group_index).group_id);
          WSH_DEBUG_SV.logmsg(l_module_name,  'date_requested: '||p_group_tab(l_group_index).date_requested);
          WSH_DEBUG_SV.logmsg(l_module_name,  'date_scheduled: '||p_group_tab(l_group_index).date_scheduled);
          WSH_DEBUG_SV.logmsg(l_module_name,  'client_id: '||p_group_tab(l_group_index).client_id); -- LSP PROJECT
       END IF;

       l_hashval_exists := TRUE;

    END IF;

    END LOOP;


   END IF;
   IF i = p_attr_tab.last THEN

     exit;

   END IF;

   -- Marker added for X-dock changes related to cartonization
   <<end_of_loop>>
   i := p_attr_tab.next(i);



  END LOOP;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --


EXCEPTION
    WHEN MULTIPLE_GROUPS THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          FND_MESSAGE.SET_NAME('WSH','WSH_MULTIPLE_GROUPS');
          WSH_UTIL_CORE.Add_Message(x_return_status);
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'MULTIPE_GROUPS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_MULTIPE_GROUPS');
          END IF;
          --

    WHEN Others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_DELIVERY_AUTOCREATE.Create_Groups');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.
C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;

END;


-- Find_Matching_Groups: This API will find entities (deliveries/containers) that
--                       match the grouping criteria of the input table of entities.
-- p_attr_tab: Table of entities or record of grouping criteria that need to be matched.
-- p_action_rec: Record of specific actions and their corresponding parameters.
--               check_single_grp_only:  ('Y', 'N') will  check only of the records can be
--                                       grouped together.
--               output_entity_type: ('DLVY', 'CONT') the entity type that the input records
--                                   need to be matched with.
--               output_format_type: Format of the output.
--                                   'ID_TAB': table of id's of the matched entities
--                                   'TEMP_TAB': The output will be inserted into wsh_temp (wsh_temp
--                                               needs to be cleared after this API has been used).
--                                   'SQL_STRING': Will return a SQL query to find the matching entities
--                                                 as a string and values of the variables that will
--                                                 need to be bound to the string.
-- p_target_rec: Entity or grouping attributes that need to be matched with (if necessary)
-- x_matched_entities: table of ids of the matched entities
-- x_out_rec: Record of output values based on the actions and output format.
--            query_string: String to query for matching entities. The following
--            will have to be bound to the string before executing the query.
--            bind_hash_value
--            bind_hash_string
--            bind_batch_id
--            bind_carrier_id
--            bind_mode_of_transport
--            bind_service_level
-- x_return_status: 'S', 'E', 'U'.

procedure Find_Matching_Groups(p_attr_tab IN OUT NOCOPY grp_attr_tab_type,
                     p_action_rec IN action_rec_type,
                     p_target_rec IN grp_attr_rec_type,
                     p_group_tab IN OUT NOCOPY grp_attr_tab_type,
                     x_matched_entities OUT NOCOPY wsh_util_core.id_tab_type,
                     x_out_rec OUT NOCOPY out_rec_type,
                     x_return_status OUT NOCOPY varchar2) IS

--Bug 5241742 Added organization_id in where clause for indexing
--Bug 6074966 added Ship Method Code in all cursor for matching deliveries
--bug#6467751: Added new parameter p_ship_method_grp_flag for all cursors which
--            basically compares the ship method value only when ship method is part of delivery grouping.
cursor c_matching_deliveries(p_hash_value in number,
                      p_hash_string in varchar2,
                      p_carrier_id in number,
                      p_mode_of_transport in varchar2,
                      p_service_level in varchar2,
                      p_ship_method_code in varchar2,
		      p_organization_id in number ,
		      p_ship_method_grp_flag in varchar2 ) is
select delivery_id
from   wsh_new_deliveries wnd
where wnd.hash_value  = p_hash_value
and   wnd.hash_string = p_hash_string
and   wnd.organization_id = p_organization_id
and   (NVL(wnd.planned_flag, 'N') = 'N')
and   NVL(NVL(wnd.carrier_id, p_carrier_id),-1)
                     = NVL(NVL(p_carrier_id, wnd.carrier_id), -1)
and   NVL(NVL(wnd.service_level, p_service_level), -1)
                     = NVL(NVL(p_service_level, wnd.service_level), -1)
and   NVL(NVL(wnd.mode_of_transport, p_mode_of_transport), -1)
                     = NVL(NVL(p_mode_of_transport, wnd.mode_of_transport), -1)
and   NVL(wnd.ship_method_code,-1) = NVL(decode(p_ship_method_grp_flag,'Y',p_ship_method_code,wnd.ship_method_code),-1)
and   wnd.status_code in ('OP', 'SA');

-- 5167826 (frontported from 11.5.10 performance bug 5029788)
--   new cursor to use indexes on organization_id and customer_id
--   keep this in sync with cursor c_matching_deliveries above.
cursor c_matching_dels_new(p_hash_value        in number,
                           p_hash_string       in varchar2,
                           p_carrier_id        in number,
                           p_mode_of_transport in varchar2,
                           p_service_level     in varchar2,
			   p_ship_method_code in varchar2,
                           p_organization_id   in number,
                           p_customer_id       in number ,
			   p_ship_method_grp_flag in varchar2) is
select delivery_id
from   wsh_new_deliveries wnd
where wnd.hash_value      = p_hash_value
and   wnd.hash_string     = p_hash_string
and   wnd.organization_id = p_organization_id
and   wnd.customer_id     = p_customer_id
and   (NVL(wnd.planned_flag, 'N') = 'N')
and   NVL(NVL(wnd.carrier_id, p_carrier_id),-1)
                     = NVL(NVL(p_carrier_id, wnd.carrier_id), -1)
and   NVL(NVL(wnd.service_level, p_service_level), -1)
                     = NVL(NVL(p_service_level, wnd.service_level), -1)
and   NVL(NVL(wnd.mode_of_transport, p_mode_of_transport), -1)
                     = NVL(NVL(p_mode_of_transport, wnd.mode_of_transport), -1)
and   NVL(wnd.ship_method_code,-1) = NVL(decode(p_ship_method_grp_flag,'Y',p_ship_method_code,wnd.ship_method_code),-1)
and   wnd.status_code in ('OP', 'SA');

cursor c_matching_batch(p_hash_value in number,
                        p_hash_string in varchar2,
                        p_batch_id in number,
                        p_header_id number,
                        p_carrier_id in number,
                        p_mode_of_transport in varchar2,
                        p_service_level in varchar2 ,
			p_ship_method_code  in varchar2,
			p_ship_method_grp_flag in varchar2
			) is
select delivery_id
from wsh_new_deliveries wnd
where wnd.hash_value = p_hash_value
and   wnd.hash_string = p_hash_string
and   wnd.batch_id  = p_batch_id
and   (NVL(wnd.planned_flag, 'N') = 'N')
and   NVL(wnd.source_header_id, -1) = NVL(p_header_id, -1)
and   NVL(NVL(wnd.carrier_id, p_carrier_id), -1) = NVL(NVL(p_carrier_id, wnd.carrier_id), -1)
and   NVL(NVL(wnd.service_level, p_service_level), -1) = NVL(NVL(p_service_level, wnd.service_level), -1)
and   NVL(NVL(wnd.mode_of_transport, p_mode_of_transport), -1) = NVL(NVL(p_mode_of_transport, wnd.mode_of_transport), -1)
and   NVL(wnd.ship_method_code,-1) = NVL(decode(p_ship_method_grp_flag,'Y',p_ship_method_code,wnd.ship_method_code),-1)
and   wnd.status_code in ('OP', 'SA');
--
-- LSP PROJECT : LSP changes. : Created new cursros for LSP changes (same as old ones except clientId validation).
--
cursor c_matching_deliveries_lsp(p_hash_value in number,
                      p_hash_string in varchar2,
                      p_carrier_id in number,
                      p_mode_of_transport in varchar2,
                      p_service_level in varchar2,
                      p_ship_method_code in varchar2,
		      p_organization_id in number ,
		      p_ship_method_grp_flag in varchar2,
              p_client_id in number) is
select delivery_id
from   wsh_new_deliveries wnd
where wnd.hash_value  = p_hash_value
and   wnd.hash_string = p_hash_string
and   wnd.organization_id = p_organization_id
and   (NVL(wnd.planned_flag, 'N') = 'N')
and   NVL(NVL(wnd.carrier_id, p_carrier_id),-1)
                     = NVL(NVL(p_carrier_id, wnd.carrier_id), -1)
and   NVL(NVL(wnd.service_level, p_service_level), -1)
                     = NVL(NVL(p_service_level, wnd.service_level), -1)
and   NVL(NVL(wnd.mode_of_transport, p_mode_of_transport), -1)
                     = NVL(NVL(p_mode_of_transport, wnd.mode_of_transport), -1)
and   NVL(wnd.ship_method_code,-1) = NVL(decode(p_ship_method_grp_flag,'Y',p_ship_method_code,wnd.ship_method_code),-1)
and   wnd.status_code in ('OP', 'SA')
and   NVL(wnd.client_id,-1) = NVL(p_client_id,-1);

-- 5167826 (frontported from 11.5.10 performance bug 5029788)
--   new cursor to use indexes on organization_id and customer_id
--   keep this in sync with cursor c_matching_deliveries above.
cursor c_matching_dels_new_lsp(p_hash_value        in number,
                           p_hash_string       in varchar2,
                           p_carrier_id        in number,
                           p_mode_of_transport in varchar2,
                           p_service_level     in varchar2,
			   p_ship_method_code in varchar2,
                           p_organization_id   in number,
                           p_customer_id       in number ,
			   p_ship_method_grp_flag in varchar2,
                           p_client_id in number) is
select delivery_id
from   wsh_new_deliveries wnd
where wnd.hash_value      = p_hash_value
and   wnd.hash_string     = p_hash_string
and   wnd.organization_id = p_organization_id
and   wnd.customer_id     = p_customer_id
and   (NVL(wnd.planned_flag, 'N') = 'N')
and   NVL(NVL(wnd.carrier_id, p_carrier_id),-1)
                     = NVL(NVL(p_carrier_id, wnd.carrier_id), -1)
and   NVL(NVL(wnd.service_level, p_service_level), -1)
                     = NVL(NVL(p_service_level, wnd.service_level), -1)
and   NVL(NVL(wnd.mode_of_transport, p_mode_of_transport), -1)
                     = NVL(NVL(p_mode_of_transport, wnd.mode_of_transport), -1)
and   NVL(wnd.ship_method_code,-1) = NVL(decode(p_ship_method_grp_flag,'Y',p_ship_method_code,wnd.ship_method_code),-1)
and   wnd.status_code in ('OP', 'SA')
and   NVL(wnd.client_id,-1) = NVL(p_client_id,-1);

cursor c_matching_batch_lsp(p_hash_value in number,
                        p_hash_string in varchar2,
                        p_batch_id in number,
                        p_header_id number,
                        p_carrier_id in number,
                        p_mode_of_transport in varchar2,
                        p_service_level in varchar2 ,
			p_ship_method_code  in varchar2,
			p_ship_method_grp_flag in varchar2,
                        p_client_id in number
			) is
select delivery_id
from wsh_new_deliveries wnd
where wnd.hash_value = p_hash_value
and   wnd.hash_string = p_hash_string
and   wnd.batch_id  = p_batch_id
and   (NVL(wnd.planned_flag, 'N') = 'N')
and   NVL(wnd.source_header_id, -1) = NVL(p_header_id, -1)
and   NVL(NVL(wnd.carrier_id, p_carrier_id), -1) = NVL(NVL(p_carrier_id, wnd.carrier_id), -1)
and   NVL(NVL(wnd.service_level, p_service_level), -1) = NVL(NVL(p_service_level, wnd.service_level), -1)
and   NVL(NVL(wnd.mode_of_transport, p_mode_of_transport), -1) = NVL(NVL(p_mode_of_transport, wnd.mode_of_transport), -1)
and   NVL(wnd.ship_method_code,-1) = NVL(decode(p_ship_method_grp_flag,'Y',p_ship_method_code,wnd.ship_method_code),-1)
and   wnd.status_code in ('OP', 'SA')
and   NVL(wnd.client_id,-1) = NVL(p_client_id,-1);
--
-- LSP PROJECT: End
--

 --BUG 3383843
CURSOR c_dlvy_for_cont(p_organization_id NUMBER, p_ship_from_loc_id NUMBER) IS
select delivery_id
from wsh_new_deliveries d
where d.status_code IN ('OP','SA')
and   d.planned_flag = 'N'
and   NVL(p_ship_from_loc_id, nvl(d.initial_pickup_location_id, -1))
          = nvl(d.initial_pickup_location_id, -1)
and   NVL(p_organization_id, nvl(d.organization_id, -1))
          = nvl(d.organization_id, -1);
-- LSP PROJECT: Added client_id
CURSOR c_check_lpn(p_delivery_detail_id IN NUMBER) IS
SELECT container_flag, organization_id, ship_from_location_id, customer_id,client_id
FROM wsh_delivery_details
WHERE delivery_detail_id = p_delivery_detail_id;

l_container_flag VARCHAR2(1);
l_organization_id NUMBER;
l_ship_from_loc_id NUMBER;
l_empty_container VARCHAR2(30) := 'N';
l_return_status VARCHAR2(30);
 --BUG 3383843

l_batch_id NUMBER;
l_header_id NUMBER;
l_carrier_id NUMBER;
l_service_level VARCHAR2(30);
l_mode_of_transport VARCHAR2(30);
l_ship_method_code   VARCHAR2(30);   --bug 6074966
l_hash_value NUMBER;
l_hash_string varchar2(1000);
l_matched_entities   wsh_util_core.id_tab_type;
l_tmp_attr_tab grp_attr_tab_type;
l_check_one_group varchar2(1);
l_query_string varchar2(4000);

l_customer_id NUMBER;
l_client_id   NUMBER; -- LSP PROJECT : Added client_id

DELIVERY_NOT_MATCH EXCEPTION;
FAIL_CREATE_GROUP EXCEPTION;
FAIL_CREATE_HASH EXCEPTION;
INVALID_ACTION EXCEPTION;
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Find_Matching_Groups';

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_action_rec.action', p_action_rec.action);
      WSH_DEBUG_SV.log(l_module_name, 'p_action_rec.output_format_type', p_action_rec.output_format_type);
      WSH_DEBUG_SV.log(l_module_name, 'p_attr_tab count' , p_attr_tab.count);
      WSH_DEBUG_SV.log(l_module_name, 'p_group_tab count', p_group_tab.count);
      WSH_DEBUG_SV.log(l_module_name, 'p_target_rec.entity_type', p_target_rec.entity_type);
  END IF;


  -- Need to validate the input action.
  -- LSP PROJECT : Use_header_flag value defaulting (from org/client defaults) has been moved from pick release
  --          API WSH_PICK_LIST.xx to here and to recognize the change pick release API is
  --          passing action code as 'MATCH_GROUPS_AT_PICK' instead of 'MATCH_GROUPS'.
  IF p_action_rec.action NOT IN ('MATCH_GROUPS', 'CREATE_GROUPS', 'AUTOCREATE_DELIVERIES','MATCH_GROUPS_AT_PICK') THEN

     RAISE INVALID_ACTION;

  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  -- Mahech : consider the changed action 'MATCH_GROUPS_AT_PICK'
  IF p_action_rec.action IN ('MATCH_GROUPS','MATCH_GROUPS_AT_PICK') AND p_target_rec.entity_id is NOT NULL THEN

      p_attr_tab(p_attr_tab.FIRST - 1).entity_id := p_target_rec.entity_id;
      p_attr_tab(p_attr_tab.FIRST).entity_type := p_target_rec.entity_type;

  END IF;

  -- Mahech : consider the changed action 'MATCH_GROUPS_AT_PICK'
  --BUG 3383843
  --For calls from Group API to find matching groups, empty containers need to be handled separately
  --First check if the line is a container. If yes, check if container is empty.
   IF p_action_rec.action in ('MATCH_GROUPS','MATCH_GROUPS_AT_PICK')
     AND p_attr_tab.count > 0
   THEN
   --{
      IF p_attr_tab(p_attr_tab.FIRST).entity_type = 'DELIVERY_DETAIL'
      THEN
      --{
         IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'entity id', p_attr_tab(p_attr_tab.FIRST).entity_id);
         END IF;
         -- LSP PROJECT : Added client_id
         OPEN c_check_lpn(p_attr_tab(p_attr_tab.FIRST).entity_id);
         FETCH c_check_lpn INTO l_container_flag, l_organization_id,
                                l_ship_from_loc_id, l_customer_id,l_client_id;
         CLOSE c_check_lpn;

         IF l_debug_on THEN
            wsh_debug_sv.log(l_Module_name, 'Container Flag', l_container_flag);
            wsh_debug_sv.log(l_Module_name , 'l_organization_id', l_organization_id);
            wsh_debug_sv.log(l_Module_Name, 'l_ship_from_loc_id', l_ship_from_loc_id);
            wsh_debug_sv.log(l_Module_Name, 'l_customer_id ', l_customer_id);
            wsh_debug_sv.log(l_Module_Name, 'l_client_id ', l_client_id); -- LSP PROJECT
         END IF;

         IF nvl(l_container_flag, 'N') = 'Y'
         THEN
         --{
            WSH_CONTAINER_UTILITIES.Is_Empty (
             p_container_instance_id  => p_attr_tab(p_attr_tab.FIRST).entity_id,
             x_empty_flag => l_empty_container,
             x_return_status => x_return_status);

             IF x_return_status <> wsh_util_core.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_error;
             END IF;

             IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'l_empty_container', l_empty_container);
             END IF;
          --}
          END IF;
        --}
       END IF;
   --}
   END IF;
  --BUG 3383843


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Create_Hash',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
  Create_Hash(p_grouping_attributes => p_attr_tab,
              p_group_by_header => p_action_rec.group_by_header_flag,
              p_action_code => p_action_rec.action,
              x_return_status => x_return_status);

  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

     RAISE FAIL_CREATE_HASH;

  END IF;

  IF p_action_rec.check_single_grp = 'Y' THEN

     l_check_one_group := 'Y';

  ELSE

     l_check_one_group := 'N';

  END IF;
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Create_Groupings',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  Create_Groupings(p_attr_tab => p_attr_tab,
                   p_group_tab => p_group_tab,
                   p_check_one_group => l_check_one_group,
                   p_action_code =>  p_action_rec.action,
                   x_return_status => x_return_status);

  IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

     IF x_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN

        IF p_action_rec.check_single_grp = 'Y' THEN

        -- We need to check only if the records can be grouped together.

           x_out_rec.single_group := 'N';

           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;

           RETURN;

        END IF;

     ELSE

        RAISE FAIL_CREATE_GROUP;

     END IF;

  END IF;

  IF p_action_rec.check_single_grp = 'Y' THEN

     x_out_rec.single_group := 'Y';

  END IF;


  IF p_target_rec.entity_type = 'DELIVERY' AND p_target_rec.entity_id IS NULL THEN
     --BUG 3383843
     --If line is an empty container, need to use a select that does not use hash values
    IF nvl(l_container_flag, 'N') = 'Y'
       AND  nvl(l_empty_container, 'N') = 'Y'
    THEN
        OPEN c_dlvy_for_cont(l_organization_id, l_ship_from_loc_id);
        FETCH c_dlvy_for_cont BULK COLLECT INTO l_matched_entities;
        CLOSE c_dlvy_for_cont;
        --
        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name, 'Empty container match count=' || l_matched_entities.count);
        END IF;
    ELSE
     -- Find all matching deliveries
     -- Populate the following variables used to find matching deliveries.
     -- We assume that all the records can go into one group, so we can use
     -- the value of one record for common attributes.

       l_hash_value := p_group_tab(p_group_tab.FIRST).l1_hash_value;
       l_hash_string := p_group_tab(p_group_tab.FIRST).l1_hash_string;
       l_batch_id := p_group_tab(p_group_tab.FIRST).batch_id;
       l_header_id := p_group_tab(p_group_tab.FIRST).source_header_id;
       l_carrier_id := p_group_tab(l_hash_value).carrier_id;
       l_service_level := p_group_tab(l_hash_value).service_level;
       l_mode_of_transport :=  p_group_tab(l_hash_value).mode_of_transport;
       l_ship_method_code :=  p_group_tab(l_hash_value).ship_method_code; --bugfix 6074966
       l_client_id        :=  p_group_tab(l_hash_value).client_id; -- LSP PROJECT

       --Bug 5241742 setting l_customer_id = NULL if customer is not a part of grouping criteria.
        get_group_by_attr (
                p_organization_id  => l_organization_id,
                p_client_id        => l_client_id,
                x_group_by_flags   => group_by_info,
                x_return_status    => x_return_status
                          );
       IF l_debug_on THEN
           wsh_debug_sv.log(l_Module_name , 'group by ship method ', group_by_info.ship_method);
       END IF;

       IF group_by_info.customer = 'N' THEN
       l_customer_id := NULL;
       END IF;
       -- LSP PROJECT
       IF WMS_DEPLOY.wms_deployment_mode = 'L' THEN
       --{
           IF l_batch_id IS NOT NULL THEN

                OPEN c_matching_batch_lsp(p_hash_value  => l_hash_value,
                             p_hash_string  => l_hash_string,
                             p_batch_id => l_batch_id,
                             p_header_id => l_header_id,
                             p_carrier_id => l_carrier_id,
                             p_mode_of_transport => l_mode_of_transport,
                             p_service_level => l_service_level ,
			                 p_ship_method_code => l_ship_method_code ,
			                 p_ship_method_grp_flag=>group_by_info.ship_method,
                             p_client_id=>l_client_id);

               FETCH c_matching_batch_lsp BULK COLLECT INTO l_matched_entities; --anvarshn LSP
               CLOSE c_matching_batch_lsp;
           ELSE
               IF (l_organization_id is NOT NULL and l_customer_id is NOT NULL) THEN
                   OPEN c_matching_dels_new_lsp(
                           p_hash_value        => l_hash_value,
                           p_hash_string       => l_hash_string,
                           p_carrier_id        => l_carrier_id,
                           p_mode_of_transport => l_mode_of_transport,
                           p_service_level     => l_service_level,
			               p_ship_method_code => l_ship_method_code,
                           p_organization_id   => l_organization_id,
                           p_customer_id       => l_customer_id,
			               p_ship_method_grp_flag=>group_by_info.ship_method,
                           p_client_id           => l_client_id);

                   FETCH c_matching_dels_new_lsp BULK COLLECT INTO l_matched_entities; --anvarshn LSP
                   CLOSE c_matching_dels_new_lsp;
               ELSE
                   OPEN c_matching_deliveries_lsp(
                                  p_hash_value        => l_hash_value,
                                  p_hash_string       => l_hash_string,
				                  p_organization_id   => l_organization_id,
                                  p_carrier_id        => l_carrier_id,
                                  p_mode_of_transport => l_mode_of_transport,
                                  p_service_level     => l_service_level ,
				                  p_ship_method_code => l_ship_method_code,
				                  p_ship_method_grp_flag=>group_by_info.ship_method,
                                  p_client_id         => l_client_id);

                   FETCH c_matching_deliveries_lsp BULK COLLECT INTO l_matched_entities; --anvarshn LSP
                   CLOSE c_matching_deliveries_lsp;
               END IF;
           END IF;
       ELSE
           IF l_batch_id IS NOT NULL THEN

                OPEN c_matching_batch(p_hash_value  => l_hash_value,
                             p_hash_string  => l_hash_string,
                             p_batch_id => l_batch_id,
                             p_header_id => l_header_id,
                             p_carrier_id => l_carrier_id,
                             p_mode_of_transport => l_mode_of_transport,
                             p_service_level => l_service_level ,
			                 p_ship_method_code => l_ship_method_code ,
			                 p_ship_method_grp_flag=>group_by_info.ship_method);

               FETCH c_matching_batch BULK COLLECT INTO l_matched_entities;
               CLOSE c_matching_batch;
           ELSE
               IF (l_organization_id is NOT NULL and l_customer_id is NOT NULL) THEN
                   OPEN c_matching_dels_new(
                           p_hash_value        => l_hash_value,
                           p_hash_string       => l_hash_string,
                           p_carrier_id        => l_carrier_id,
                           p_mode_of_transport => l_mode_of_transport,
                           p_service_level     => l_service_level,
			               p_ship_method_code => l_ship_method_code,
                           p_organization_id   => l_organization_id,
                           p_customer_id       => l_customer_id,
			               p_ship_method_grp_flag=>group_by_info.ship_method);

                   FETCH c_matching_dels_new BULK COLLECT INTO l_matched_entities;
                   CLOSE c_matching_dels_new;
               ELSE
                   OPEN c_matching_deliveries(
                                  p_hash_value        => l_hash_value,
                                  p_hash_string       => l_hash_string,
				                  p_organization_id   => l_organization_id,
                                  p_carrier_id        => l_carrier_id,
                                  p_mode_of_transport => l_mode_of_transport,
                                  p_service_level     => l_service_level ,
				                  p_ship_method_code => l_ship_method_code,
				                  p_ship_method_grp_flag=>group_by_info.ship_method);

                   FETCH c_matching_deliveries BULK COLLECT INTO l_matched_entities;
                   CLOSE c_matching_deliveries;
               END IF;
           END IF;
       --}
       END IF; -- Deployement_mode -- LSP PROJECT
    END IF;

    IF p_action_rec.output_format_type = 'TEMP_TAB' THEN
    -- Insert into wsh_tmp

       delete from wsh_tmp;

       FORALL i IN 1..l_matched_entities.count
       INSERT INTO wsh_tmp (id) VALUES(l_matched_entities(i));

       x_return_status :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;

       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;

       RETURN;

    ELSIF p_action_rec.output_format_type = 'ID_TAB' THEN
    -- Insert into PL/SQL tble

       x_matched_entities := l_matched_entities;


       x_return_status :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;

       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;

       RETURN;

    ELSIF p_action_rec.output_format_type = 'SQL_STRING' THEN
    -- Return the string and the variables that need to be bound.

       l_query_string := 'select delivery_id '||
                         'from wsh_new_deliveries wnd '||
                         'where wnd.hash_value = :p_hash_value '||
                         'and   wnd.hash_string = :p_hash_string '||
                         'and   wnd.status_code = ''OP'' ';

       IF l_batch_id is NOT NULL THEN
          l_query_string := l_query_string || ' and   wnd.batch_id = :p_batch_id ';
       END IF;
       IF l_header_id is NOT NULL THEN
          l_query_string := l_query_string || ' and   wnd.source_header_id = :p_header_id ';
       END IF;
       IF l_carrier_id is NOT NULL THEN
          l_query_string :=  l_query_string || ' and  NVL(wnd.carrier_id, :p_carrier_id)  = :p_carrier_id ';
       END IF;
       IF l_service_level is NOT NULL THEN
          l_query_string :=  l_query_string || ' and  NVL(wnd.service_level, :p_service_level) = :p_service_level ';
       END IF;
       IF l_mode_of_transport is NOT NULL THEN
          l_query_string :=  l_query_string || ' and  NVL(wnd.mode_of_transport, :p_mode_of_transport) = :p_mode_of_transport ';
       END IF;
       --bug#6467751: Need to consider the ship method value only when ship method is part of delivery grouping.
       IF (group_by_info.ship_method = 'Y') THEN
       --{
          IF l_ship_method_code is NOT NULL THEN
             l_query_string :=  l_query_string || ' and  wnd.ship_method_code = :p_ship_method_code ';
          ELSE
             l_query_string :=  l_query_string || ' and  wnd.ship_method_code IS NULL ';
          END IF;
       --}
       END IF;
       --
       -- LSP PROJECT: Begin
       l_query_string :=  l_query_string || ' and   NVL(wnd.client_id,-1) = NVL(:p_client_id,-1) ';
       -- LSP PROJECT: End
       --
       x_out_rec.query_string := l_query_string;

       x_out_rec.bind_hash_value := l_hash_value;
       x_out_rec.bind_hash_string := l_hash_string;
       x_out_rec.bind_batch_id := l_batch_id;
       x_out_rec.bind_header_id := l_header_id;
       x_out_rec.bind_carrier_id := l_carrier_id;
       x_out_rec.bind_service_level := l_service_level;
       x_out_rec.bind_mode_of_transport := l_mode_of_transport;
       x_out_rec.bind_ship_method_code := l_ship_method_code;
       x_out_rec.bind_client_id := l_client_id; -- LSP PROJECT

       x_return_status :=  WSH_UTIL_CORE.G_RET_STS_SUCCESS;

       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;

       RETURN;


    END IF;

  END IF;


    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION
    WHEN fnd_api.g_exc_error THEN
          x_return_status := fnd_api.g_ret_sts_error;
          --
          IF l_debug_on THEN
             wsh_debug_sv.pop(l_module_name, 'EXCEPTION:FND_API.G_EXC_ERROR');
          END IF;
       --
    WHEN DELIVERY_NOT_MATCH THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_NOT_MATCH');
          WSH_UTIL_CORE.Add_Message(x_return_status);
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'DELIVERY_NOT_MATCH exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DELIVERY_NOT_MATCH');
          END IF;
          --
    WHEN FAIL_CREATE_GROUP THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('WSH','WSH_FAIL_CREATE_GROUP');
          WSH_UTIL_CORE.Add_Message(x_return_status);
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'MULTIPE_GROUPS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FAIL_CREATE_GROUP');
          END IF;
          --
    WHEN FAIL_CREATE_HASH THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('WSH','WSH_FAIL_CREATE_HASH');
          WSH_UTIL_CORE.Add_Message(x_return_status);
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FAIL_CREATE_GROUP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FAIL_CREATE_HASH');
          END IF;
          --

    WHEN Others THEN
         WSH_UTIL_CORE.Default_Handler('WSH_DELIVERY_AUTOCREATE.Find_Matching_Groups');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

         IF c_matching_deliveries%ISOPEN THEN
           CLOSE c_matching_deliveries;
         END IF;
         IF c_matching_dels_new%ISOPEN THEN
           CLOSE c_matching_dels_new;
         END IF;

         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;

END;








-----------------------------------------------------------------------------
--
-- Function:      Check_Sch_Date_Match
-- Parameters:    p_delivery_id, p_del_date, p_detail_date
-- Description:   Checks if scheduled date on line matches initial pickup date on delivery
--                FOR THE PRESENT, FUNCTION SIMPLY RETURNS TRUE
--
-----------------------------------------------------------------------------

--
--
FUNCTION Check_Sch_Date_Match ( p_delivery_id IN NUMBER,
				p_del_date IN DATE,
                                p_detail_date IN DATE) RETURN BOOLEAN IS
                                --
l_debug_on BOOLEAN;
                                --
                                l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_SCH_DATE_MATCH';
                                --
BEGIN

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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DEL_DATE',P_DEL_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_DATE',P_DETAIL_DATE);
   END IF;
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN TRUE;

END Check_Sch_Date_Match;

-----------------------------------------------------------------------------
--
-- Function:      Check_Req_Date_Match
-- arameters:    p_delivery_id, p_del_date, p_detail_date
-- Description:   Checks if requested date on line matches ultimate dropoff date on delivery
--                FOR THE PRESENT, FUNCTION SIMPLY RETURNS TRUE
--
-----------------------------------------------------------------------------

FUNCTION Check_Req_Date_Match ( p_delivery_id IN NUMBER,
				p_del_date IN DATE,
                                p_detail_date IN DATE) RETURN BOOLEAN IS
                                --
l_debug_on BOOLEAN;
                                --
                                l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_REQ_DATE_MATCH';
                                --
BEGIN

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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DEL_DATE',P_DEL_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_DETAIL_DATE',P_DETAIL_DATE);
   END IF;
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN TRUE;

END Check_Req_Date_Match;

-----------------------------------------------------------------------------
--
-- Procedure:      Autonomous_Create_Delivery
-- Parameters:     p_delivery_info, x_rowid, x_delivery_id, x_delivery_name, x_return_status
-- Description:    Local API for Autononmous Transaction for Creating Delivery in Parallel Pick
--                 Release worker processes.
--
-----------------------------------------------------------------------------

PROCEDURE Autonomous_Create_Delivery (
p_delivery_info         IN wsh_new_deliveries_pvt.delivery_rec_type,
x_rowid                 OUT NOCOPY VARCHAR2,
x_delivery_id           OUT NOCOPY NUMBER,
x_delivery_name         OUT NOCOPY VARCHAR2,
x_return_status         OUT NOCOPY VARCHAR2)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

others EXCEPTION;
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTONOMOUS_CREATE_DELIVERY';

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.CREATE_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  WSH_NEW_DELIVERIES_PVT.Create_Delivery(p_delivery_info, x_rowid, x_delivery_id, x_delivery_name, x_return_status);
  IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR IN WSH_NEW_DELIVERIES_PVT.CREATE_DELIVERY ');
      END IF;
      IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'PROC WSH_NEW_DELIVERIES_PVT.CREATE_DELIVERY RETURNED UNEXPECTED ERROR');
         END IF;
         RAISE OTHERS;
      ELSE
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'PROC WSH_NEW_DELIVERIES_PVT.CREATE_DELIVERY RETURNED ERROR');
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         ROLLBACK;
         RETURN;
      END IF;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,  'CREATED DELIVERY # '||X_DELIVERY_NAME  );
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FLEXFIELD_UTILS.WRITE_DFF_ATTRIBUTES',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  wsh_flexfield_utils.WRITE_DFF_ATTRIBUTES
                                (p_table_name => 'WSH_NEW_DELIVERIES',
                                 p_primary_id => x_delivery_id,
                                 x_return_status => x_return_status);

  IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'PROC WSH_FLEXFIELD_UTILS.WRITE_DFF_ATTRIBUTES RETURNED ERROR'  );
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     ROLLBACK;
     RETURN;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Autonomous Return status ', x_return_status);
  END IF;

  IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
     COMMIT;
  ELSE
     ROLLBACK;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    wsh_util_core.default_handler('WSH_DELIVERY_AUTOCREATE.AUTONOMOUS_CREATE_DELIVERY');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    ROLLBACK;
END Autonomous_Create_Delivery;

--------------------------------------------------------------------------
--
-- Procedure:   Autocreate_deliveries
-- Parameters:  p_line_rows, p_line_info_rows, p_init_flag,
--              p_use_header_flag, p_max_detail_commit, p_del_rows
-- Description: Used to automatically create deliveries
--              p_line_rows           - Table of delivery detail ids
--              p_init_flag           - 'Y' initializes the table of deliveries
--              p_pick_release_flag   - 'Y' means use header_id for grouping
--              p_container_flag      - 'Y' means call Autopack routine
--              p_check_flag          - 'Y' means delivery details will be
--                                         grouped without creating deliveries
--              p_generate_carton_group_id - 'Y' means api called for generate
--                                           carton group id only
--              p_max_detail_commit   - Commits data after delivery detail
--                                  count reaches this value - No Longer Used
--              x_del_rows            - Created delivery ids
--              p_grouping_rows       - returns group ids for each detail,
--                                        when p_check_flag is set to 'Y'
--              x_return_status - Status of execution
--------------------------------------------------------------------------

PROCEDURE autocreate_deliveries(
             p_line_rows                IN          wsh_util_core.id_tab_type,
             p_init_flag                IN          VARCHAR2,
             p_pick_release_flag        IN          VARCHAR2,
             p_container_flag           IN          VARCHAR2       :=   'N',
             p_check_flag               IN          VARCHAR2       :=   'N',
             p_caller                   IN          VARCHAR2  DEFAULT   NULL,
             p_generate_carton_group_id IN          VARCHAR2       :=   'N',
             p_max_detail_commit        IN          NUMBER         :=   1000,
             x_del_rows                 OUT NOCOPY  wsh_util_core.id_tab_type,
             x_grouping_rows            OUT NOCOPY  wsh_util_core.id_tab_type,
             x_return_status            OUT NOCOPY  VARCHAR2 ) IS


/* Bug 3206620 : cursor to get the container flag of the delivery detail*/
cursor c_cont (p_entity_id NUMBER) is
SELECT container_flag
FROM  wsh_delivery_details
WHERE delivery_detail_id = p_entity_id;

cursor c_matching_delivery(p_hash_value in number,
                        p_hash_string in varchar2,
                        p_batch_id in number,
                        p_header_id number,
                        p_carrier_id in number,
                        p_mode_of_transport in varchar2,
                        p_service_level in varchar2) is
select delivery_id, name, rowid
from wsh_new_deliveries wnd
where wnd.hash_value = p_hash_value
and   wnd.hash_string = p_hash_string
and   wnd.batch_id  = p_batch_id
and   (NVL(wnd.planned_flag, 'N') = 'N')
and   NVL(wnd.source_header_id, -1) = NVL(p_header_id, -1)
and   NVL(NVL(wnd.carrier_id, p_carrier_id), -1) = NVL(NVL(p_carrier_id, wnd.carrier_id), -1)
and   NVL(NVL(wnd.service_level, p_service_level), -1) = NVL(NVL(p_service_level, wnd.service_level), -1)
and   NVL(NVL(wnd.mode_of_transport, p_mode_of_transport), -1) = NVL(NVL(p_mode_of_transport, wnd.mode_of_transport), -1)
and   wnd.status_code in ('OP', 'SA');

l_group_info            grp_attr_tab_type;
l_delivery_info         wsh_new_deliveries_pvt.delivery_rec_type;
l_rowid                 VARCHAR2(30);
l_delivery_id           NUMBER;
l_delivery_name wsh_new_deliveries.name%TYPE;
l_weight_uom_code   VARCHAR2(10);
l_volume_uom_code   VARCHAR2(10);

l_assigned_flag VARCHAR2(1) := 'N';

l_return_status VARCHAR2(1);
l_dummy                 VARCHAR2(1);

i NUMBER;

--bug 1613019
l_line_lpn_id   varchar2(30);
--bug 1613019

l_error_code number := NULL;
l_error_text varchar2(2000) := NULL;

l_caller VARCHAR2(2000) := 'WSH_AUTO_CREATE_DEL';

--
-- BUG : 2286739
l_check_fte_inst   VARCHAR2(1) := 'N';    -- used to check is FTE is installed or not

-- bug 2691385
l_detail_is_empty_cont VARCHAR2(1) := 'N';
l_param_info WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;

l_attr_tab  wsh_delivery_autocreate.grp_attr_tab_type;
l_action_rec wsh_delivery_autocreate.action_rec_type;
l_target_rec wsh_delivery_autocreate.grp_attr_rec_type;
l_matched_entities wsh_util_core.id_tab_type;
l_out_rec wsh_delivery_autocreate.out_rec_type;
l_del_select_carrier  wsh_util_core.id_tab_type;
l_del_rate            wsh_util_core.id_tab_type;
l_del_rate_location   wsh_util_core.id_tab_type;

l_delivery_tab wsh_util_core.id_tab_type;
l_delivery_rows wsh_util_core.id_tab_type;
j NUMBER;

l_exception_id     NUMBER;
l_exception_message  VARCHAR2(2000);
l_in_param_rec       WSH_FTE_INTEGRATION.rate_del_in_param_rec;
l_out_param_rec      WSH_FTE_INTEGRATION.rate_del_out_param_rec;
l_log_itm_exc        VARCHAR2(1);

    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);

l_group_index NUMBER; -- frontport 5415196
l_notfound    BOOLEAN;

cannot_autocreate_del EXCEPTION;
others EXCEPTION;

e_return_excp EXCEPTION;  -- LPN CONV. rv

--Bug8727903 : begin
l_num_warnings      NUMBER;
l_num_errors        NUMBER;
--Bug8727903 : end

l_warn_num NUMBER := 0;

-- LPN CONV. rv
l_error_num NUMBER := 0;
l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
-- LPN CONV. rv

l_lock_handle VARCHAR2(100);
l_lock_status NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTOCREATE_DELIVERIES';
--
BEGIN

  /*
  p_max_detail_commit is not longer used but is retained as parameter
  because of dependency issues
  */

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'P_INIT_FLAG',        P_INIT_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_PICK_RELEASE_FLAG',P_PICK_RELEASE_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_FLAG',   P_CONTAINER_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_CHECK_FLAG',       P_CHECK_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'P_MAX_DETAIL_COMMIT',P_MAX_DETAIL_COMMIT);
    WSH_DEBUG_SV.log(l_module_name,'P_CALLER',           P_CALLER);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


  IF (p_line_rows.count = 0) THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'RAISING EXCEPTION WHEN OTHERS BECAUSE P_LINE_ROWS.COUNT IS 0'  );
    END IF;
    --
    raise others;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'INITIALIZING AUTO_DEL_IDS...'  );
  END IF;
  --

  FOR i IN 1..p_line_rows.count LOOP
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,  '**** PROCESSING DELIVERY DETAIL ID '||P_LINE_ROWS ( I ) ||' ****'  );
    END IF;
    --
    l_attr_tab(i).entity_id   := p_line_rows(i);
    l_attr_tab(i).entity_type := 'DELIVERY_DETAIL';
  END LOOP;

  l_action_rec.action := 'AUTOCREATE_DELIVERIES';

  l_action_rec.group_by_header_flag  := p_pick_release_flag;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,  'Calling Find_Matching_Groups'  );
  END IF;
  Find_Matching_Groups(p_attr_tab         => l_attr_tab,
                       p_action_rec       => l_action_rec,
                       p_target_rec       => l_target_rec,
                       p_group_tab        => l_group_info,
                       x_matched_entities => l_matched_entities,
                       x_out_rec          => l_out_rec,
                       x_return_status    => x_return_status);

  IF x_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    raise e_return_excp;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_group_info.COUNT', l_group_info.COUNT);
  END IF;

  j := 0;

  l_del_select_carrier.delete;
  l_del_rate.delete;
  l_del_rate_location.delete;

  -- frontport 5415196: removed WHILE loop; inside code is relocated below.
  --  We no longer loop through the groups to create a delivery for each group.
  --  Instead, we will create deliveries as needed when looping through
  --  the details.

  FOR i in 1..l_attr_tab.count LOOP

    IF (l_attr_tab(i).ship_to_location_id is NULL ) THEN --{
      -- identify the record with null ship-to location,
      -- set an appropriate message, and immediately return
      -- without autocreating any delivery.

      l_line_lpn_id := to_char(l_attr_tab(i).entity_id);
      /* Bug 3206620 */
      OPEN c_cont(l_attr_tab(i).entity_id);
      FETCH c_cont into l_attr_tab(i).container_flag;
      CLOSE c_cont;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'container flag is',l_attr_tab(i).container_flag);
      END IF;

      IF l_attr_tab(i).container_flag = 'Y' THEN --{
        WSH_CONTAINER_UTILITIES.Is_Empty (p_container_instance_id => l_attr_tab(i).entity_id,
                                        x_empty_flag => l_detail_is_empty_cont,
                                        x_return_status => l_return_status);

        IF (l_return_status  IN(WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          x_return_status := l_return_status;
          wsh_util_core.add_message(x_return_status);
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Error returned from WSH_CONTAINER_UTILITIES.Is_Empty');
          END IF;
          raise e_return_excp;  -- LPN CONV. rv
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,  'l_detail_is_empty_cont',l_detail_is_empty_cont );
        END IF;

        IF l_detail_is_empty_cont = 'Y' then
          FND_MESSAGE.SET_NAME('WSH','WSH_CONT_EMPTY');
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          wsh_util_core.add_message(x_return_status);
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,  'container empty,autocreate delivery not allowed');
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          raise e_return_excp;  -- LPN CONV. rv
        ELSE
          FND_MESSAGE.SET_NAME('WSH','WSH_ULT_DROPOFF_LOC_ID_NOT_FND');
          FND_MESSAGE.SET_TOKEN('LINE_LPN_ID',l_line_lpn_id);
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          wsh_util_core.add_message(x_return_status);
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,  'SHIPTO LOCATION NOT FOUND FOR '||P_LINE_ROWS ( I )  );
          END IF;
          raise e_return_excp;  -- LPN CONV. rv
        END IF;
      ELSE
        FND_MESSAGE.SET_NAME('WSH','WSH_ULT_DROPOFF_LOC_ID_NOT_FND');
        FND_MESSAGE.SET_TOKEN('LINE_LPN_ID',l_line_lpn_id);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        wsh_util_core.add_message(x_return_status);
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'SHIPTO LOCATION NOT FOUND FOR '||P_LINE_ROWS ( I )  );
        END IF;
        raise e_return_excp;  -- LPN CONV. rv
      END IF;
      -- the code will not continue; the above IFs and ELSEs
      -- will have raised the exception because of null ship-to location
    END IF; --}

    IF l_attr_tab(i).delivery_id IS NOT NULL THEN

      -- Use this flag to set a warning message at the end of the procedure
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'THE LINE IS ASSIGNED TO DELIVERY '||l_attr_tab(i).DELIVERY_ID  );
      END IF;
      --
      FND_MESSAGE.SET_NAME('WSH', 'WSH_DET_ASSIGNED_DEL');
      FND_MESSAGE.SET_TOKEN('DET_NAME', l_attr_tab(i).entity_id);
      FND_MESSAGE.SET_TOKEN('DEL_NAME', WSH_NEW_DELIVERIES_PVT.get_name(l_attr_tab(i).DELIVERY_ID));
      wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);

      l_assigned_flag := 'Y';

    ELSE --{ not assigned

      -- 5415196 start (code relocated from the WHILE loop deleted above)
      --   use the hash value as an index for tracking deliveries to be
      --   created.
      --   if pick release option is set to autocreate deliveries within
      --   orders, one hash value can be associated with more than 1 group
      --   which is based on source_header_id.

      l_group_index := l_attr_tab(i).l1_hash_value;

        -- Hash Values match but Attributes do not match. Need to find the correct Group
        WHILE l_attr_tab(i).group_id <> l_group_info(l_group_index).group_id LOOP
              l_group_index := l_group_index + 1;
        END LOOP;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'l_group_info(' || l_group_index || ').source_header_id', l_group_info(l_group_index).source_header_id);
          WSH_DEBUG_SV.log(l_module_name, 'l_attr_tab(' || i || ').source_header_id', l_attr_tab(i).source_header_id);
          WSH_DEBUG_SV.log(l_module_name, 'l_group_info(' || l_group_index || ').group_id', l_group_info(l_group_index).group_id);
          WSH_DEBUG_SV.log(l_module_name, 'l_attr_tab(=).group_id', l_attr_tab(i).group_id);
        END IF;

      IF     l_attr_tab(i).group_id IS NOT NULL
         AND NOT (l_delivery_tab.exists(l_attr_tab(i).group_id)) THEN  --{
        -- we need to create a new delivery or, if in parallel pick,
        -- use the matching delivery autocreated within the batch.
        --

        -- frontport 5415196: with pick release option to autocreate dels
        -- within orders, one hash value can represent multiple order groups;
        -- therefore, use the detail's source header to stamp the delivery.
        -- value will be NULL if not grouping by orders.
        l_delivery_info.source_header_id             := l_attr_tab(i).source_header_id;

        l_delivery_info.delivery_type                := 'STANDARD';
        l_delivery_info.ultimate_dropoff_location_id := l_group_info(l_group_index).ship_to_location_id;
        l_delivery_info.initial_pickup_location_id   := l_group_info(l_group_index).ship_from_location_id;
        l_delivery_info.organization_id              := l_group_info(l_group_index).organization_id;
        l_delivery_info.ignore_for_planning          := l_group_info(l_group_index).ignore_for_planning;
        l_delivery_info.shipment_direction           := l_group_info(l_group_index).line_direction;
        l_delivery_info.customer_id                  := l_group_info(l_group_index).customer_id;
        l_delivery_info.fob_code                     := l_group_info(l_group_index).fob_code;
        l_delivery_info.freight_terms_code           := l_group_info(l_group_index).freight_terms_code;
        l_delivery_info.intmed_ship_to_location_id   := l_group_info(l_group_index).intmed_ship_to_location_id;
        l_delivery_info.ship_method_code             := l_group_info(l_group_index).ship_method_code;
        l_delivery_info.carrier_id                   := l_group_info(l_group_index).carrier_id;
        l_delivery_info.initial_pickup_date          := l_group_info(l_group_index).date_scheduled;
        l_delivery_info.ultimate_dropoff_date        := l_group_info(l_group_index).date_requested;
        l_delivery_info.shipping_control             := l_group_info(l_group_index).shipping_control;
        l_delivery_info.vendor_id                    := l_group_info(l_group_index).vendor_id;
        l_delivery_info.party_id                     := l_group_info(l_group_index).party_id;
        l_delivery_info.mode_of_transport            := l_group_info(l_group_index).mode_of_transport;
        l_delivery_info.service_level                := l_group_info(l_group_index).service_level;
        l_delivery_info.status_code                  := l_group_info(l_group_index).status_code;
        l_delivery_info.batch_id                     := wsh_pick_list.g_batch_id;
        l_delivery_info.hash_value                   := l_group_info(l_group_index).l1_hash_value;
        l_delivery_info.hash_string                  := l_group_info(l_group_index).l1_hash_string;
        l_delivery_info.client_id                    := l_group_info(l_group_index).client_id ; -- LSP PROJECT


        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.GET_DEFAULT_UOMS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        wsh_wv_utils.get_default_uoms(l_group_info(l_group_index).organization_id, l_weight_uom_code, l_volume_uom_code, x_return_status);
        -- Bug8727903 (begin): Now the get_default_uoms API can return error status also.
        --
        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_WV_UTILS.GET_DEFAULT_UOMS',x_return_status);
        END IF;
        --
        WSH_UTIL_CORE.api_post_call(
            p_return_status     => x_return_status,
            x_num_warnings      => l_num_warnings,
            x_num_errors        => l_num_errors);

        -- -- Bug8727903 (End)
        l_delivery_info.weight_uom_code := l_weight_uom_code;
        l_delivery_info.volume_uom_code := l_volume_uom_code;

        -- 5415196: frontport reconciled with parallel pick release
        --          and LPN convergence

        IF      WSH_PICK_LIST.G_BATCH_ID IS NOT NULL
            AND WSH_PICK_LIST.G_PICK_REL_PARALLEL    THEN --{
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Acquiring lock on :'||l_delivery_info.hash_value||'-'||l_delivery_info.batch_id);
          END IF;
          DBMS_LOCK.Allocate_Unique(lockname => l_delivery_info.hash_value||'-'||l_delivery_info.batch_id,
                                   lockhandle => l_lock_handle);
          l_lock_status := DBMS_LOCK.Request(lockhandle => l_lock_handle,
                                               lockmode => 6);
          IF l_lock_status = 0 THEN --{
            -- Successfully locked, so check if a delivery
            -- has been created in between acquiring the lock
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'p_header_id', l_delivery_info.source_header_id);
          END IF;

            OPEN c_matching_delivery(
                   p_hash_value        => l_delivery_info.hash_value,
                   p_hash_string       => l_delivery_info.hash_string,
                   p_batch_id          => l_delivery_info.batch_id,
                   p_header_id         => l_delivery_info.source_header_id,
                   p_carrier_id        => l_delivery_info.carrier_id,
                   p_mode_of_transport => l_delivery_info.mode_of_transport,
                   p_service_level     => l_delivery_info.service_level);

            FETCH c_matching_delivery INTO l_delivery_id,
                                           l_delivery_name,
                                           l_rowid;
            l_notfound := c_matching_delivery%NOTFOUND;
            CLOSE c_matching_delivery;

            IF l_notfound THEN --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Matching delivery is not found, so create a new delivery ');
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Autonomous_Create_Delivery',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              Autonomous_Create_Delivery(l_delivery_info, l_rowid,
                        l_delivery_id, l_delivery_name, x_return_status);
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return from Autonomous_Create_Delivery, Return status', x_return_status);
              END IF;
              l_lock_status := DBMS_LOCK.Release(l_lock_handle);
              l_lock_handle := NULL;

              IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                  raise others;
                ELSE
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'PROC WSH_DELIVERY_AUTOCREATE.Autonomous_Create_Delivery RETURNED ERROR');
                  END IF;
                  raise e_return_excp;
                END IF;
              ELSE
                l_group_info(l_group_index).delivery_id := l_delivery_id;
              END IF;
              --}
            ELSE --{
              l_lock_status := DBMS_LOCK.Release(l_lock_handle);
              l_lock_handle := NULL;
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Matching delivery '||l_delivery_name||' already exists , so skip creating a new delivery ');
              END IF;

              l_group_info(l_group_index).delivery_id := l_delivery_id;
              GOTO SKIP_ITM_EXISTING_DEL;
              --}
            END IF;
          --}
          ELSE
            -- Any other problems in acquiring the lock,
            -- raise error and return
            -- This can happen only if there's a timeout issue
            -- or unexpected error
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'Error when trying to acquire User Lock, Lock Status :'||l_lock_status  );
            END IF;
            raise e_return_excp;
          END IF;  --}
        --}
        ELSE
          --{ non-parallel-pick case
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.CREATE_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          wsh_new_deliveries_pvt.create_delivery(l_delivery_info, l_rowid, l_delivery_id, l_delivery_name, x_return_status);
          IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR IN WSH_NEW_DELIVERIES_PVT.CREATE_DELIVERY FOR '||P_LINE_ROWS ( I )  );
            END IF;
            IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'PROC WSH_NEW_DELIVERIES_PVT.CREATE_DELIVERY RETURNED UNEXPECTED ERROR');
              END IF;
              raise others;
            ELSE
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'PROC WSH_NEW_DELIVERIES_PVT.CREATE_DELIVERY RETURNED ERROR');
              END IF;
              raise e_return_excp;
            END IF;
          END IF;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,  'CREATED DELIVERY # '||L_DELIVERY_NAME  );
          END IF;

          l_group_info(l_group_index).delivery_id := l_delivery_id;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FLEXFIELD_UTILS.WRITE_DFF_ATTRIBUTES',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          wsh_flexfield_utils.WRITE_DFF_ATTRIBUTES
                                    (p_table_name => 'WSH_NEW_DELIVERIES',
                                     p_primary_id => l_delivery_id,
                                     x_return_status => x_return_status);

          IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'PROC WSH_FLEXFIELD_UTILS.WRITE_DFF_ATTRIBUTES RETURNED ERROR'  );
            END IF;
            raise e_return_excp;
          END IF;

          --}
        END IF;

        -- following code is common for parallel and non-parallel cases
        -- of creating a new delivery, up to the label SKIP_ITM_EXISTING_DEL.

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.Get',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_SHIPPING_PARAMS_PVT.Get(
             p_organization_id => l_delivery_info.organization_id,
             x_param_info      => l_param_info,
             x_return_status   => l_return_status
             );

        -- Pack J: Bug fix 3043993. KVENKATE
        -- Add message if return status is not success
        -- Only modification is to add message. Since there was no code
        -- to exit or return after
        -- call to the above procedure, leaving that behavior the same.

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('WSH', 'WSH_PARAM_NOT_DEFINED');
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',
              wsh_util_core.get_org_name(l_delivery_info.organization_id));
          wsh_util_core.add_message(l_return_status,l_module_name);
        END IF;

        --
        -- ITM Check is required only for outbound lines
        --
        IF l_param_info.export_screening_flag IN ('C', 'A')
          AND l_delivery_info.shipment_direction in ('O','IO') -- J-IB-NPARIKH
        THEN --{ ITM check

          -- Pack J: ITM integration. If ITM screening is required
          -- at shipping param level,
          -- call Check_ITM_Required to see if the delivery criteria
          -- requires ITM screening and log exception.

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.Check_ITM_Required',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          l_log_itm_exc :=  WSH_DELIVERY_VALIDATIONS.Check_ITM_Required
                              (p_delivery_id => l_delivery_id,
                               x_return_status => l_return_status);
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_DELIVERY_VALIDATIONS.Check_ITM_Required',l_return_status);
          END IF;

          IF (l_return_status  IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            x_return_status := l_return_status;
            raise e_return_excp;  -- LPN CONV. rv
          END IF;

          IF l_log_itm_exc = 'Y' THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.Log_ITM_Exception',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            WSH_DELIVERY_VALIDATIONS.Log_ITM_Exception (
                             p_delivery_id => l_delivery_id,
                             p_action_type => 'CREATE_DELIVERY',
                             p_ship_from_location_id =>  l_delivery_info.initial_pickup_location_id,
                             x_return_status => l_return_status);
            IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name,'Return Status After Calling WSH_DELIVERY_VALIDATIONS.Log_ITM_Exception',l_return_status);
            END IF;

            IF (l_return_status  IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
              x_return_status := l_return_status;
              raise e_return_excp;  -- LPN CONV. rv
            END IF;
          END IF;

        END IF;  --}

        -- R12 ECO bug 4467032
        -- if p_caller is FTE_LINE_TO_TRIP,
        --                      do not execute Apply Routing Guide
        --                      do not execute Rating

        -- Hiding project
        -- Line level autocreate trip -> no routing, no rating

        IF (NVL(l_param_info.AUTO_APPLY_ROUTING_RULES, 'N') = 'D' AND
           (( p_caller <> 'WSH_AUTO_CREATE_DEL_TRIP' AND
           p_caller <> 'FTE_LINE_TO_TRIP') OR p_caller IS NULL)) THEN
          -- auto apply routing rule at delivery creation
          l_del_select_carrier(l_del_select_carrier.count+1) := l_delivery_id;
          IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,'calling routing_guide',p_caller);
          END IF;
        END IF;

        -- Hiding project
        IF (   l_param_info.auto_calc_fgt_rate_cr_del = 'Y'
           AND ( (    p_caller <> 'WSH_AUTO_CREATE_DEL_TRIP'
                  AND p_caller <> 'FTE_LINE_TO_TRIP')
                OR p_caller IS NULL)
               ) THEN
          -- auto rate deliveries at delivery creation
          l_del_rate(l_del_rate.count+1) := l_delivery_id;
          l_del_rate_location(l_del_rate_location.count+1) := l_delivery_info.initial_pickup_location_id;
        END IF;

        <<SKIP_ITM_EXISTING_DEL>>

        l_delivery_tab(l_attr_tab(i).group_id) := l_delivery_id;

        j := j + 1;
        l_delivery_rows(j) := l_delivery_id;

      END IF; --}
      -- 5415196 end

      wsh_delivery_details_actions.assign_detail_to_delivery(
                    p_detail_id     => l_attr_tab(i).entity_id,
                    p_delivery_id   => l_delivery_tab(l_attr_tab(i).group_id),
                    x_return_status => x_return_status,
                    p_caller        => 'AUTOCREATE'); --bug 5100229


      IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'ERROR IN WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_DETAIL_TO_DELIVERY FOR '||P_LINE_ROWS ( I ) || ' TO '||L_DELIVERY_ID  );
        END IF;
        --
        IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,  'PROC WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_DETAIL_TO_DELIVERY RETURNED UNEXPECTED ERROR'  );
          END IF;
          --
          raise others;
        ELSE
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,  'PROC WSH_DELIVERY_DETAILS_ACTIONS.ASSIGN_DETAIL_TO_DELIVERY RETURNED ERROR'  );
          END IF;
          raise e_return_excp;  -- LPN CONV. rv
        END IF;

      END IF; --}

    END IF; --}

    x_grouping_rows(i) := l_attr_tab(i).group_id;

  END LOOP;


  IF (l_assigned_flag = 'Y') THEN
    IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    END IF;
  END IF;

  IF (l_group_info.count = 0) THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,  'NO DELIVERIES ARE CREATED IN THIS CALL. RAISING EXCEPTION'  );
    END IF;
    --
    raise cannot_autocreate_del;
  END IF;

  -- Bug 4658241
  wsh_tp_release.calculate_cont_del_tpdates(
        p_entity => 'DLVY',
        p_entity_ids => l_delivery_rows,
        x_return_status => l_return_status);
  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
    raise others;
  ELSIF  l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR , WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
    l_warn_num := l_warn_num + 1;
  END IF;
  -- Bug 4658241 end

  -- PATCHSET H Change FOR FTE INtegration With CARRIER_SELECTION
  -- [AAB]
  -- [03/22/2002]
  --
  --
  -- <<< START OF NEW CODE >>> ********************************
  --
  -- This is a code addition for Patchset H to perform carrier
  -- selection if installed and the shipping parameter is on
  -- NOTE: for pick released auto create deliveries, the carrier selection check is
  -- performed in the Pick release procedure
  --
  -- [AAB][04/04/2002]
  -- [BUG: 2301717] added check to IF statement below to ensure that
  -- a table of deliveries is populated with at least one delivery so
  -- that processing can be done correctly
  --
  l_check_fte_inst := WSH_UTIL_CORE.FTE_Is_Installed;
  IF (l_check_fte_inst = 'Y') THEN

    IF ((WSH_PICK_LIST.G_BATCH_ID is null) AND
       (l_delivery_rows.COUNT > 0) AND l_del_select_carrier.count > 0 ) THEN
      --
      -- no batch Id so this is not from pick release
      -- so lets try it
      --

      IF p_caller = 'WSH_AUTO_CREATE_DEL_TRIP' THEN
        l_caller := p_caller;
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.PROCESS_CARRIER_SELECTION',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --

      WSH_NEW_DELIVERY_ACTIONS.PROCESS_CARRIER_SELECTION(p_delivery_id_tab => l_del_select_carrier,
                                                         p_batch_id        => null,
                                                         p_form_flag       => 'N',
                                                         p_caller          => l_caller,
                                                         x_return_message  => l_error_text,
                                                         x_return_status   => l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          raise others;
        ELSE
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,  'Return status from WSH_NEW_DELIVERY_ACTIONS.Process_Carrier_Selection', l_return_status  );
          END IF;
          --
        END IF;
        l_warn_num := l_warn_num + 1;
      END IF;
    END IF;

    -- <<< END OF NEW CODE  >>> ********************************
    --
    -- End of FTE Integration for Carrier Selection - PATCHSET H
    --
    --

    -- Pack J: Added Rate delivery for autocreate deliveries.
    -- Bug 3714834: Since autocreate del at pick release does rating
    -- do not rate if called by pick release.

    IF (l_del_rate.count > 0) AND (WSH_PICK_LIST.G_BATCH_ID is null) THEN

      l_in_param_rec.delivery_id_list := l_del_rate;
      l_in_param_rec.action           := 'RATE';
      l_in_param_rec.seq_tender_flag  := 'Y'; -- R12 Select Carrier

      WSH_FTE_INTEGRATION.Rate_Delivery(
               p_api_version      => 1.0,
               p_init_msg_list    => FND_API.G_FALSE,
               p_commit           => FND_API.G_FALSE,
               p_in_param_rec     => l_in_param_rec,
               x_out_param_rec    => l_out_param_rec,
               x_return_status    => l_return_status,
               x_msg_count        => l_msg_count,
               x_msg_data         => l_msg_data);
      --
      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'Return Status from WSH_FTE_INTEGRATION.Rate_Delivery' ,l_return_status);
      END IF;

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          raise others;
        ELSE
          i := l_out_param_rec.failed_delivery_id_list.FIRST;
          WHILE i is not NULL LOOP

            FND_MESSAGE.SET_NAME('WSH', 'WSH_RATE_CREATE_DEL');
            FND_MESSAGE.SET_TOKEN('DELIVERY_ID' , to_char(l_out_param_rec.failed_delivery_id_list(i)));
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING);

            FND_MESSAGE.SET_NAME('WSH', 'WSH_RATE_CREATE_DEL');
            FND_MESSAGE.SET_TOKEN('DELIVERY_ID' , to_char(l_out_param_rec.failed_delivery_id_list(i)));
            l_exception_message := FND_MESSAGE.Get;
            l_exception_id := NULL;

            wsh_xc_util.log_exception(
                     p_api_version           => 1.0,
                     x_return_status         => l_return_status,
                     x_msg_count             => l_msg_count,
                     x_msg_data              => l_msg_data,
                     x_exception_id          => l_exception_id,
                     p_exception_location_id => l_del_rate_location(i),
                     p_logged_at_location_id => l_del_rate_location(i),
                     p_logging_entity        => 'SHIPPER',
                     p_logging_entity_id     => FND_GLOBAL.USER_ID,
                     p_exception_name        => 'WSH_RATE_CREATE_DEL',
                     p_message               => substrb(l_exception_message,1,2000),
                     p_delivery_id           => l_out_param_rec.failed_delivery_id_list(i));
            i := l_out_param_rec.failed_delivery_id_list.next(i);
          END LOOP;
          l_warn_num := l_warn_num + 1;
        END IF;
      END IF;
    END IF;
  END IF;

  -- LPN CONV. rv
  --
  IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'  THEN
  --{

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
       (
         p_in_rec             => l_lpn_in_sync_comm_rec,
         x_return_status      => l_return_status,
         x_out_rec            => l_lpn_out_sync_comm_rec
       );
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
    END IF;
    --
    WSH_UTIL_CORE.API_POST_CALL
       (
         p_return_status    => l_return_status,
         x_num_warnings     => l_warn_num,
         x_num_errors       => l_error_num,
         p_raise_error_flag => false
       );
  --}
  END IF;
  -- LPN CONV. rv
  --

  x_del_rows := l_delivery_rows;
  IF l_error_num > 0 THEN  -- LPN CONV. rv
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF      x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS
        AND  l_warn_num > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING ;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,  'Return status from WSH_DELIVERY_AUTOCREATE.autocreate_deliveries', x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --

EXCEPTION

  -- LPN CONV. rv
  WHEN e_return_excp THEN
    --
    FND_MESSAGE.SET_NAME('WSH','WSH_AUTOCREATE_DEL_ERROR');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    wsh_util_core.add_message(x_return_status);
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y' THEN
      --{
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
              (
                p_in_rec             => l_lpn_in_sync_comm_rec,
                x_return_status      => l_return_status,
                x_out_rec            => l_lpn_out_sync_comm_rec
              );
            --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      --}
    END IF;
    --
    -- LPN CONV. rv
    --
    IF c_cont%ISOPEN THEN
      CLOSE c_cont;
    END IF;
    IF c_matching_delivery%ISOPEN THEN
      CLOSE c_matching_delivery;
    END IF;
    IF l_lock_handle IS NOT NULL THEN
      l_lock_status := DBMS_LOCK.Release(l_lock_handle);
    END IF;

  WHEN cannot_autocreate_del THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_AUTOCREATE_DEL_ERROR');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    wsh_util_core.add_message(x_return_status);
    --
    -- LPN CONV. rv
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y' THEN
      --{
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
               (
                 p_in_rec             => l_lpn_in_sync_comm_rec,
                 x_return_status      => l_return_status,
                 x_out_rec            => l_lpn_out_sync_comm_rec
               );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
      END IF;
      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      --
      --}
    END IF;
    -- LPN CONV. rv
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION CANNOT_AUTOCREATE_DEL RAISED'  );
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'CANNOT_AUTOCREATE_DEL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:CANNOT_AUTOCREATE_DEL');
    END IF;
    --
    IF c_cont%ISOPEN THEN
      CLOSE c_cont;
    END IF;
    IF c_matching_delivery%ISOPEN THEN
      CLOSE c_matching_delivery;
    END IF;
    IF l_lock_handle IS NOT NULL THEN
       l_lock_status := DBMS_LOCK.Release(l_lock_handle);
    END IF;

  WHEN Others THEN

    IF c_cont%ISOPEN THEN
      CLOSE c_cont;
    END IF;
    IF c_matching_delivery%ISOPEN THEN
      CLOSE c_matching_delivery;
    END IF;
    IF l_lock_handle IS NOT NULL THEN
      l_lock_status := DBMS_LOCK.Release(l_lock_handle);
    END IF;

    l_error_code := SQLCODE;
    l_error_text := SQLERRM;
    --
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y' THEN
      --{
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
               (
                 p_in_rec             => l_lpn_in_sync_comm_rec,
                 x_return_status      => l_return_status,
                 x_out_rec            => l_lpn_out_sync_comm_rec
               );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
      END IF;
      --}
    END IF;
    --
    -- LPN CONV. rv
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM WSH_DELIVERY_AUTOCREATE.AUTOCREATE_DELIVERIES IS ' || L_ERROR_TEXT  );
    END IF;
    --
    wsh_util_core.default_handler('WSH_DELIVERY_AUTOCREATE.AUTOCREATE_DELIVERIES');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
END autocreate_deliveries;

--------------------------------------------------------------------------
--
-- Procedure:	Autocreate_del_across_orgs
-- Parameters:	p_line_rows, p_line_info_rows, p_init_flag,
--		p_use_header_flag, p_max_detail_commit, p_del_rows
-- Description:	Used to automatically create deliveries across orgs
--		p_line_rows		- Table of delivery detail ids
--		p_org_rows 		- a table of organization_ids.  If this
-- 			     		- table is not available to pass
--                      		- then pass a dummy value in. the table
-- 			     		- will get regenerated when calling
--                      		- WSH_DELIVERY_AUTOCREATE.autocreate_del_across_orgs
--		p_container_flag	- 'Y' means call Autopack routine
--		p_check_flag		- 'Y' means delivery details will be
--		  	     	       grouped without creating deliveries
--		p_max_detail_commit	- Commits data after delivery detail
--					       count reaches this value
--		p_del_rows		- Created delivery ids
--		p_grouping_rows	- returns group ids for each detail,
--					       when p_check_flag is set to 'Y'
--		x_return_status	- Status of execution
--------------------------------------------------------------------------

PROCEDURE autocreate_del_across_orgs(
			p_line_rows 		IN 	wsh_util_core.id_tab_type,
			p_org_rows		IN 	wsh_util_core.id_tab_type,
			p_container_flag	IN	VARCHAR2 := 'N',
			p_check_flag		IN	VARCHAR2 := 'N',
                        p_caller                IN      VARCHAR2  DEFAULT   NULL,
			p_max_detail_commit	IN	NUMBER := 1000,
			p_group_by_header_flag  IN      VARCHAR2 DEFAULT NULL,
			x_del_rows 		OUT NOCOPY  	wsh_util_core.id_tab_type,
			x_grouping_rows		OUT NOCOPY 	wsh_util_core.id_tab_type,
			x_return_status 	OUT NOCOPY  	VARCHAR2 ) IS

lower_bound    		NUMBER;
upper_bound    		NUMBER;
j 	          		NUMBER;

TYPE line_org_rec_type IS RECORD(
   line_id          	NUMBER,
   warehouse_id          NUMBER);
TYPE line_org_type IS TABLE OF line_org_rec_type INDEX BY BINARY_INTEGER;
l_line_warehouse_ids 	line_org_type;
t_line_warehouse_id 	line_org_rec_type;

l_param_info WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;

temp_ids	          	wsh_util_core.id_tab_type;
curr_warehouse_id   	NUMBER;

l_count       NUMBER;
l_prev_count  NUMBER;
delcount      NUMBER;
l_del_rows    wsh_util_core.id_tab_type;
l_return_status   VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_warn_num    NUMBER := 0;
--BUG 3379499
l_err_num NUMBER := 0;
l_ac_dlvy_count NUMBER := 0;

Others 		     	EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'AUTOCREATE_DEL_ACROSS_ORGS';
--
BEGIN

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
       WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_FLAG',P_CONTAINER_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_CHECK_FLAG',P_CHECK_FLAG);
       WSH_DEBUG_SV.log(l_module_name,'P_MAX_DETAIL_COMMIT',P_MAX_DETAIL_COMMIT);
       WSH_DEBUG_SV.log(l_module_name,'P_CALLER',P_CALLER);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF (p_line_rows.count = 0) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      fnd_message.SET_name('WSH', 'WSH_NOT_ELIGIBLE_DELIVERIES');
      wsh_util_core.add_message(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;

   IF (p_org_rows.count <> 0) AND (p_line_rows.count = p_org_rows.count) THEN
      FOR i in 1..p_line_rows.count LOOP
         l_line_warehouse_ids(i).warehouse_id := p_org_rows(i);
         l_line_warehouse_ids(i).line_id := p_line_rows(i);
      END LOOP;
   ELSE
      FOR i in 1..p_line_rows.count LOOP
         SELECT organization_id
         INTO l_line_warehouse_ids(i).warehouse_id
         FROM wsh_delivery_details
         WHERE delivery_detail_id = p_line_rows(i);
         l_line_warehouse_ids(i).line_id := p_line_rows(i);
      END LOOP;
   END IF;

   -- Sorting the table l_line_warehouse_ids according to the warehouse_id.
   lower_bound := 1;
   upper_bound := l_line_warehouse_ids.count;
   FOR i IN (lower_bound + 1)..upper_bound LOOP
      t_line_warehouse_id := l_line_warehouse_ids(i);
      j := i-1;
      -- Shift elements down until insertion point found
      WHILE ((j >= lower_bound) AND (l_line_warehouse_ids(j).warehouse_id > t_line_warehouse_id.warehouse_id)) LOOP
         l_line_warehouse_ids(j+1) := l_line_warehouse_ids(j);
         j := j-1;
      END LOOP;
      -- insert
      l_line_warehouse_ids(j+1) := t_line_warehouse_id;
   END LOOP;

   -- Looping through l_line_warehouse_ids and grouping delivery_detail_id's with same warehouse id
   -- Call autocreate_deliveries to create delivery.
   curr_warehouse_id := l_line_warehouse_ids(1).warehouse_id;
   FOR i in 1..l_line_warehouse_ids.count LOOP
      IF ( curr_warehouse_id <> l_line_warehouse_ids(i).warehouse_id ) THEN
         -- LSP PROJECT : Passing the value of autocreate_del_orders_flag from ORG is not
         --          required here as the defualting logic from ORG is already present
         --          in the create_hash API. It is a duplicate code and hence removing the same.
         /*
         WSH_SHIPPING_PARAMS_PVT.Get(
                                      p_organization_id => curr_warehouse_id,
                                      x_param_info   => l_param_info,
                                      x_return_status   => x_return_status
                                    );

        Pack J: Bug fix 3043993. KVENKATE
          Add message if return status is not success
          Only modification is to add message. Since there was no code to exit or return after
          call to the above procedure, leaving that behavior the same.


       IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('WSH', 'WSH_PARAM_NOT_DEFINED');
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',
                          wsh_util_core.get_org_name(curr_warehouse_id));
            wsh_util_core.add_message(x_return_status,l_module_name);
       END IF;


         -- Process Deliveries change, use set up from shipping parameter only if
         -- p_group_by_header_flag is NULL
         IF p_group_by_header_flag in ('Y', 'N') THEN
            l_param_info.autocreate_del_orders_flag := p_group_by_header_flag;
         END IF; */

         l_del_rows.delete;

         autocreate_deliveries(
                        p_line_rows => temp_ids,
                        p_init_flag => 'N',
                        p_pick_release_flag => p_group_by_header_flag, -- LSP PROJECT directly pass p_group_by_header_flag
                        p_container_flag => p_container_flag,
		        p_check_flag => p_check_flag,
                        p_caller     => p_caller,
                        p_max_detail_commit => p_max_detail_commit,
		        x_del_rows => l_del_rows,
                        x_grouping_rows => x_grouping_rows,
                        x_return_status => l_return_status);

          --BUG 3379499
          --Keep count of calls to autocreate_deliveries
          l_ac_dlvy_count := l_ac_dlvy_count + 1;

         --bug 3348614
         l_count:=l_del_rows.COUNT;
         l_prev_count:=x_del_rows.COUNT;

         FOR delcount IN 1..l_count LOOP
           x_del_rows(l_prev_count+delcount):=l_del_rows(delcount);
         END LOOP;

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
              raise others;
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
               FND_MESSAGE.SET_NAME('WSH', 'WSH_AUTOCREATE_DEL_ORG_ERR');
               FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',
               wsh_util_core.get_org_name(curr_warehouse_id));
               wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
               --BUG 3379499
               --Keep count of errors
                 l_err_num := l_err_num + 1;
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FND_MESSAGE.SET_NAME('WSH', 'WSH_AUTOCREATE_DEL_ORG_WRN');
               FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',
               wsh_util_core.get_org_name(curr_warehouse_id));
               wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
               l_warn_num := l_warn_num + 1;
            END IF;
         END IF;
     -- Bug 4658241
	 /*wsh_tp_release.calculate_cont_del_tpdates(
				p_entity => 'DLVY',
				p_entity_ids => x_del_rows,
			        x_return_status => l_return_status);
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise others;
         ELSIF  l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR , WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            l_warn_num := l_warn_num + 1;
         END IF; */
       -- Bug 4658241 end
         temp_ids.delete;
         curr_warehouse_id := l_line_warehouse_ids(i).warehouse_id;
      END IF;
      temp_ids(temp_ids.count + 1) := l_line_warehouse_ids(i).line_id;
   END LOOP;
   -- Handling the case when it is the last warehouse group or the only warehouse group in the table
   IF temp_ids.count > 0 THEN
      -- LSP PROJECT : Passing the value of autocreate_del_orders_flag from ORG is not
      --          required here as the defualting logic from ORG is already present
      --          in the create_hash API. It is a duplicate code and hence removing the same.
      /*
      WSH_SHIPPING_PARAMS_PVT.Get(
                                    p_organization_id => curr_warehouse_id,
                                    x_param_info   => l_param_info,
			            x_return_status => l_return_status
                                                                     );

        Pack J: Bug fix 3043993. KVENKATE
          Add message if return status is not success
          Only modification is to add message. Since there was no code to exit or return after
          call to the above procedure, leaving that behavior the same.


       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('WSH', 'WSH_PARAM_NOT_DEFINED');
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',
                          wsh_util_core.get_org_name(curr_warehouse_id));
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
          l_warn_num := l_warn_num + 1;
       END IF;

      -- Process Deliveries change, use set up from shipping parameter only if
      -- p_group_by_header_flag is NULL
      IF p_group_by_header_flag in ('Y', 'N') THEN
         l_param_info.autocreate_del_orders_flag := p_group_by_header_flag;
      END IF; */

      l_del_rows.delete;
      autocreate_deliveries(
                        p_line_rows => temp_ids,
                        p_init_flag => 'Y',
                        p_pick_release_flag => p_group_by_header_flag, -- LSP PROJECT directly pass p_group_by_header_flag
                        p_container_flag => p_container_flag,
                        p_check_flag => p_check_flag,
                        p_caller     => p_caller,
                        p_max_detail_commit => p_max_detail_commit,
                        x_del_rows => l_del_rows,
                        x_grouping_rows => x_grouping_rows,
                        x_return_status => l_return_status);
       --BUG 3379499
       --Keep count of calls to autocreate_deliveries
       l_ac_dlvy_count := l_ac_dlvy_count + 1;

       --bug 3348614
       l_count:=l_del_rows.COUNT;
       l_prev_count:=x_del_rows.COUNT;

       FOR delcount IN 1..l_count LOOP
         x_del_rows(l_prev_count+delcount):=l_del_rows(delcount);
       END LOOP;

       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            raise others;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
             FND_MESSAGE.SET_NAME('WSH', 'WSH_AUTOCREATE_DEL_ORG_ERR');
             FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',
             wsh_util_core.get_org_name(curr_warehouse_id));
             wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
             --BUG 3379499
             --Keep count of errors
               l_err_num := l_err_num + 1;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
             FND_MESSAGE.SET_NAME('WSH', 'WSH_AUTOCREATE_DEL_ORG_WRN');
             FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',
             wsh_util_core.get_org_name(curr_warehouse_id));
             wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
             l_warn_num := l_warn_num + 1;
          END IF;
       END IF;

      temp_ids.delete;
       -- Bug 4658241
      /*wsh_tp_release.calculate_cont_del_tpdates(
                                p_entity => 'DLVY',
                                p_entity_ids => x_del_rows,
                                x_return_status => l_return_status);
      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
        raise others;
      ELSIF  l_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR , WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
        l_warn_num := l_warn_num + 1;
      END IF; */
      -- Bug 4658241 end
   END IF;

  --BUG 3379499
  --Handle return status using l_err_num and l_warn_num
  IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'l_ac_dlvy_count', l_ac_dlvy_count);
     wsh_debug_sv.log(l_module_name, 'l_err_num', l_err_num);
     wsh_debug_sv.log(l_module_name, 'l_warn_num', l_warn_num);
  END IF;
  IF l_err_num > 0 THEN
    IF l_err_num < l_ac_dlvy_count
    THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    END IF;
  ELSIF l_warn_num > 0 THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_del_rows ',x_del_rows.COUNT);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;



--
   EXCEPTION
      WHEN Others THEN

	 wsh_util_core.default_handler('WSH_DELIVERY_AUTOCREATE.AUTOCREATE_DEL_ACROSS_ORGS');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END autocreate_del_across_orgs;

--------------------------------------------------------------------------
--
-- Procedure:   Delete_Empty_Deliveries
-- Parameters:  p_batch_id
--
-- Description: Used to Delete Empty Deliveries existing after Pick Release
--              p_batch_id      - Pick Release Batch Id
--              x_return_status - Status of execution
--------------------------------------------------------------------------

PROCEDURE Delete_Empty_Deliveries(p_batch_id      IN NUMBER,
                                  x_return_status OUT NOCOPY      VARCHAR2 ) IS
                                  --
l_debug_on         BOOLEAN;
                                  --
l_module_name      CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_EMPTY_DELIVERIES';

l_gc3_is_installed VARCHAR2(1);  --OTM R12

BEGIN
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
      WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
  END IF;
  --
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,  'DELETING EMPTY DELIVERIES FOR BATCH '||P_BATCH_ID  );
  END IF;
  --
  --OTM R12
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED; -- this is global variable

  IF l_gc3_is_installed IS NULL THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED; -- this is actual function
  END IF;                                  --
  --

  IF (p_batch_id is NOT NULL and p_batch_id > 0) THEN
    IF l_debug_on IS NULL THEN
       WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
    END IF;

    --OTM R12, allow delete of 'NS' deliveries
    IF (l_gc3_is_installed = 'Y') THEN
      DELETE FROM wsh_new_deliveries wnd
      WHERE  batch_id = p_batch_id
      AND    NVL(TMS_INTERFACE_FLAG, WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT)
             = WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT
      AND    NOT EXISTS (
             SELECT 'x'
             FROM   wsh_delivery_assignments wda
             WHERE  wda.delivery_id = wnd.delivery_id
             AND    wda.delivery_id IS NOT NULL);
    --END OTM R12
    ELSE
      DELETE FROM wsh_new_deliveries wnd
      WHERE  batch_id = p_batch_id
      AND    NOT EXISTS (
             SELECT 'x'
             FROM   wsh_delivery_assignments wda
             WHERE  wda.delivery_id = wnd.delivery_id
             AND    wda.delivery_id IS NOT NULL);
    END IF;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'DELETED '||SQL%ROWCOUNT||' EMPTY DELIVERIES AFTER PICK RELEASE'  );
        WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
    END IF;
    --

  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN OTHERS THEN
    wsh_util_core.default_handler('WSH_DELIVERY_AUTOCREATE.DELETE_EMPTY_DELIVERIES');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END DELETE_EMPTY_DELIVERIES;

--------------------------------------------------------------------------
--
-- Procedure:   unassign_empty_containers
-- Parameters:  p_delivery_id
--
-- Description: Used to unassign empty containers from delivery after Pick Release
--              p_delivery_ids  - table index by delivery ids
--              x_return_status - Status of execution
--------------------------------------------------------------------------

PROCEDURE unassign_empty_containers(
                        p_delivery_ids      IN   WSH_PICK_LIST.unassign_delivery_id_type,
                        x_return_status     OUT NOCOPY   VARCHAR2 ) IS


-- LPN CONV. rv
l_wms_org VARCHAR2(10) := 'N';
l_sync_tmp_wms_recTbl wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;
l_sync_tmp_inv_recTbl wsh_glbl_var_strct_grp.sync_tmp_recTbl_type;

l_cnt_wms_counter NUMBER;
l_cnt_inv_counter NUMBER;
l_delivery_id     NUMBER;
l_parent_detail_id  NUMBER;
l_return_status   VARCHAR2(10);
l_num_warnings     NUMBER :=0;
l_num_errors       NUMBER :=0;
l_msg_count        NUMBER;
l_msg_data        VARCHAR2(32767);
l_index NUMBER;

l_del_det_id_tbl      wsh_util_core.id_tab_type;
l_organization_id_tbl wsh_util_core.id_tab_type;
l_line_direction_tbl  wsh_util_core.column_tab_type;

l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
l_operation_type VARCHAR2(100);

CURSOR l_detail_assgn_info_csr (p_detail_id IN NUMBER) is
SELECT delivery_id,
       parent_delivery_detail_id
FROM   wsh_delivery_assignments_v
where  delivery_detail_id = p_detail_id;
-- LPN CONV. rv

-- bug 4416863
l_gross_weight_tbl  wsh_util_core.id_tab_type;
l_net_weight_tbl    wsh_util_core.id_tab_type;
l_volume_tbl        wsh_util_core.id_tab_type;
l_filled_volume_tbl wsh_util_core.id_tab_type;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UNASSIGN_EMPTY_CONTAINERS';
--
BEGIN

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
   END IF;
   --
   IF (p_delivery_ids.count > 0) THEN
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'UNASSIGNING EMPTY CONTAINERS FROM DELIVERIES'  );
     END IF;
     --
     FOR i in p_delivery_ids.FIRST .. p_delivery_ids.LAST LOOP
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  I  );
       END IF;
       --
     END LOOP;
   END IF;
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
   END IF;
   IF (p_delivery_ids.count > 0) THEN
      -- Bug 2543667 : Grouping Attributes of LPN are retained after backordering at Pick Release
      -- Empty Containers should not have any grouping attributes
      FORALL l_counter in INDICES OF p_delivery_ids
         UPDATE wsh_delivery_details wdd
         SET    wdd.customer_id                = NULL,
                wdd.ship_to_location_id        = NULL,
                wdd.intmed_ship_to_location_id = NULL,
                wdd.fob_code                   = NULL,
                wdd.freight_terms_code         = NULL,
                wdd.ship_method_code           = NULL,
                wdd.deliver_to_location_id     = NULL,
                wdd.client_id                  = NULL -- LSP PROJECT
         WHERE  wdd.delivery_detail_id in (
                SELECT wda.delivery_detail_id
                FROM   wsh_delivery_assignments_v wda
                WHERE  wda.delivery_id = p_delivery_ids(l_counter)
                AND    wda.delivery_id IS NOT NULL
                AND    wda.delivery_detail_id not in (
                       SELECT wda1.delivery_detail_id
                       FROM   wsh_delivery_assignments_v wda1
                       START  WITH   wda1.delivery_detail_id in (
                                     SELECT wda2.delivery_detail_id
                                     FROM   wsh_delivery_details wdd1 ,
                                            wsh_delivery_assignments_v wda2
                                     WHERE  wda2.delivery_id = p_delivery_ids(l_counter)
                                     AND    wda2.delivery_detail_id = wdd1.delivery_detail_id
                                     AND    wdd1.container_flag = 'N')
                       CONNECT BY wda1.delivery_detail_id = prior wda1.parent_delivery_detail_id))
         AND     wdd.container_flag = 'Y'
         RETURNING delivery_detail_id, organization_id, line_direction, gross_weight,
                   net_weight, volume, filled_volume BULK COLLECT into l_del_det_id_tbl,
                   l_organization_id_tbl, l_line_direction_tbl, l_gross_weight_tbl,
                   l_net_weight_tbl, l_volume_tbl, l_filled_volume_tbl; -- LPN CONV. rv

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'UPDATED '||SQL%ROWCOUNT||' RECORDS IN WSH_DELIVERY_DETAILS'  );
      END IF;
      --
      -- LPN CONV. rv
      IF  WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
      AND l_del_det_id_tbl.count              > 0
      THEN
      --{
          --
          l_index := l_del_det_id_tbl.first;
          l_cnt_wms_counter := 1;
          l_cnt_inv_counter := 1;

          WHILE (l_index is not null)
          LOOP
          --{
              l_delivery_id := NULL;
              l_parent_detail_id := NULL;
	      --
              open  l_detail_assgn_info_csr(l_del_det_id_tbl(l_index));
              fetch l_detail_assgn_info_csr into l_delivery_id, l_parent_detail_id;
              close l_detail_assgn_info_csr;

              l_wms_org := wsh_util_validate.check_wms_org(l_organization_id_tbl(l_index));
	      --
              IF (l_wms_org = 'Y' and nvl(l_line_direction_tbl(l_index), 'O') in ('O', 'IO')) THEN
                l_sync_tmp_wms_recTbl.delivery_detail_id_tbl(l_cnt_wms_counter) := l_del_det_id_tbl(l_index);
                l_sync_tmp_wms_recTbl.delivery_id_tbl(l_cnt_wms_counter) := l_delivery_id;
                l_sync_tmp_wms_recTbl.parent_detail_id_tbl(l_cnt_wms_counter) := l_parent_detail_id;
                l_sync_tmp_wms_recTbl.operation_type_tbl(l_cnt_wms_counter) := 'UPDATE';
                l_cnt_wms_counter := l_cnt_wms_counter + 1;

              ELSIF (l_wms_org = 'N' and nvl(l_line_direction_tbl(l_index), 'O') in ('O', 'IO')) THEN
                l_sync_tmp_inv_recTbl.delivery_detail_id_tbl(l_cnt_inv_counter) := l_del_det_id_tbl(l_index);
                l_sync_tmp_inv_recTbl.delivery_id_tbl(l_cnt_inv_counter) := l_delivery_id;
                l_sync_tmp_inv_recTbl.parent_detail_id_tbl(l_cnt_inv_counter) := l_parent_detail_id;
                l_sync_tmp_inv_recTbl.operation_type_tbl(l_cnt_inv_counter) := 'UPDATE';
                l_cnt_inv_counter := l_cnt_inv_counter + 1;
              END IF;

              l_index := l_del_det_id_tbl.next(l_index);
          --}
          END LOOP;
          --
      --}
      END IF;

      -- LPN CONV. rv
      --
      IF l_debug_on THEN
        wsh_debug_sv.LOG(l_module_name, 'Count of l_sync_tmp_wms_recTbl', l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.count);
        wsh_debug_sv.LOG(l_module_name, 'Count of l_sync_tmp_inv_recTbl', l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.count);
      END IF;
      --
      --
      IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
      THEN
      --{
          --
          l_operation_type := 'UPDATE';
          --
          IF  (   WSH_WMS_LPN_GRP.GK_WMS_UPD_GRP
               OR WSH_WMS_LPN_GRP.GK_WMS_UPD_WV
               OR WSH_WMS_LPN_GRP.GK_WMS_UPD_FILL
              )
          AND l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.count > 0
          THEN
          --{
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
                (
                  p_sync_tmp_recTbl   => l_sync_tmp_wms_recTbl,
                  x_return_status     => l_return_status,
                  p_operation_type    => l_operation_type
                );
              --
              IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'Return status after the call to WSH_WMS_SYNC_TMP_PKG.MERGE_BULK is ', l_return_status);
              END IF;
              --
              WSH_UTIL_CORE.API_POST_CALL
                (
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors
                );
          --}
          ELSIF (   WSH_WMS_LPN_GRP.GK_INV_UPD_GRP
                 OR WSH_WMS_LPN_GRP.GK_INV_UPD_WV
                 OR WSH_WMS_LPN_GRP.GK_INV_UPD_FILL
                )
          AND l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.count > 0
          THEN
          --{
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
                (
                  p_sync_tmp_recTbl   => l_sync_tmp_inv_recTbl,
                  x_return_status     => l_return_status,
                  p_operation_type    => l_operation_type
                );

              --
              IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'Return status after the call to WSH_WMS_SYNC_TMP_PKG.MERGE_BULK is ', l_return_status);
              END IF;
              --
              WSH_UTIL_CORE.API_POST_CALL
                (
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors
                );
          --}
          END IF;
      --}
      END IF;
      --
      -- Now, we need to again call the merge APIs for 'PRIOR' for the same
      -- set of delivery detail ids
      --
      IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
      THEN
      --{
          --
          l_operation_type := 'PRIOR';
          l_sync_tmp_inv_recTbl.operation_type_tbl(1) := 'PRIOR';
          --
          IF  (   WSH_WMS_LPN_GRP.GK_WMS_UNPACK
               OR WSH_WMS_LPN_GRP.GK_WMS_UNASSIGN_DLVY
              )
          AND l_sync_tmp_wms_recTbl.delivery_detail_id_tbl.count > 0
          THEN
          --{
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
                (
                  p_sync_tmp_recTbl   => l_sync_tmp_wms_recTbl,
                  x_return_status     => l_return_status,
                  p_operation_type    => l_operation_type
                );
              --
              IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'Return status after the call to WSH_WMS_SYNC_TMP_PKG.MERGE_BULK is ', l_return_status);
              END IF;
              --
              WSH_UTIL_CORE.API_POST_CALL
                (
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors
                );
          --}
          ELSIF (   WSH_WMS_LPN_GRP.GK_INV_UNPACK
                 OR WSH_WMS_LPN_GRP.GK_INV_UNASSIGN_DLVY
                )
          AND l_sync_tmp_inv_recTbl.delivery_detail_id_tbl.count > 0
          THEN
          --{
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WMS_SYNC_TMP_PKG.MERGE_BULK',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              WSH_WMS_SYNC_TMP_PKG.MERGE_BULK
                (
                  p_sync_tmp_recTbl   => l_sync_tmp_inv_recTbl,
                  x_return_status     => l_return_status,
                  p_operation_type    => l_operation_type
                );

              --
              IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'Return status after the call to WSH_WMS_SYNC_TMP_PKG.MERGE_BULK is ', l_return_status);
              END IF;
              --
              WSH_UTIL_CORE.API_POST_CALL
                (
                  p_return_status    => l_return_status,
                  x_num_warnings     => l_num_warnings,
                  x_num_errors       => l_num_errors
                );
          --}
          END IF;
      --}
      END IF;
      -- LPN CONV. rv

-- bug 4416863
     --
     -- Bug 5548080 : Check that the table actually has records in it before attempting to loop
     --
     IF l_del_det_id_tbl.COUNT > 0 THEN
      --{
      IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name, 'l_del_det_id_tbl.COUNT', l_del_det_id_tbl.COUNT);
      END IF;
      --
      FOR l_counter in l_del_det_id_tbl.FIRST .. l_del_det_id_tbl.LAST LOOP
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_WV_UTILS.DD_WV_Post_Process(
            p_delivery_detail_id => l_del_det_id_tbl(l_counter),
            p_diff_gross_wt      => -1 * nvl(l_gross_weight_tbl(l_counter), 0),
            p_diff_net_wt        => -1 * nvl(l_net_weight_tbl(l_counter), 0),
            p_diff_volume        => -1 * nvl(l_volume_tbl(l_counter), 0),
            p_diff_fill_volume   => -1 * nvl(l_filled_volume_tbl(l_counter), 0),
            x_return_status      => l_return_status);

        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
          --
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          WSH_UTIL_CORE.Add_Message(x_return_status);
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status',x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
        END IF;
      END LOOP;
      --}
      END IF; --end Bug 5548080
-- end bug 4416863

      -- Now it is a simple update
   -- LPN CONV. rv

      FORALL l_counter in indices of l_del_det_id_tbl
        UPDATE WSH_DELIVERY_ASSIGNMENTS_V
        SET DELIVERY_ID = NULL,
            PARENT_DELIVERY_DETAIL_ID = NULL
        WHERE DELIVERY_DETAIL_ID = l_del_det_id_tbl(l_counter);

      -- MDC: Delete the consol record, if exists.
      WSH_DELIVERY_DETAILS_ACTIONS.Delete_Consol_Record(
                       p_detail_id_tab   => l_del_det_id_tbl,
                       x_return_status   => x_return_status);



/*
      FORALL l_counter in p_delivery_ids.FIRST .. p_delivery_ids.LAST
         UPDATE wsh_delivery_assignments wda
         SET    wda.parent_delivery_detail_id = null,
                wda.delivery_id               = null
         WHERE  wda.delivery_id = p_delivery_ids(l_counter)
         AND    wda.delivery_id IS NOT NULL
         AND    wda.delivery_detail_id not in(
                SELECT wda1.delivery_detail_id
                FROM   wsh_delivery_assignments wda1
                START  WITH   wda1.delivery_detail_id in (
                       SELECT wda2.delivery_detail_id
                       FROM   wsh_delivery_details wdd ,
                              wsh_delivery_assignments wda2
                       WHERE  wda2.delivery_id = wda.delivery_id
                       AND    wda2.delivery_detail_id = wdd.delivery_detail_id
                       AND    wdd.container_flag = 'N')
                CONNECT BY wda1.delivery_detail_id = prior wda1.parent_delivery_detail_id);
*/
   -- LPN CONV. rv
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'UPDATED '||SQL%ROWCOUNT||' RECORDS IN WSH_DELIVERY_ASSIGNMENTS'  );
      END IF;
      --
   END IF;
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
   END IF;

   -- LPN CONV. rv
   --
   IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
   THEN
   --{

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
         (
           p_in_rec             => l_lpn_in_sync_comm_rec,
           x_return_status      => l_return_status,
           x_out_rec            => l_lpn_out_sync_comm_rec
         );
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
       END IF;
       --
       WSH_UTIL_CORE.API_POST_CALL
         (
           p_return_status    => l_return_status,
           x_num_warnings     => l_num_warnings,
           x_num_errors       => l_num_errors,
           p_raise_error_flag => false
         );
   --}
   END IF;
   --
   --
   --
   --
   IF l_num_errors   > 0 THEN
     x_return_status := wsh_util_core.g_ret_sts_error;
   ELSIF l_num_warnings > 0 THEN
     x_return_status := wsh_util_core.g_ret_sts_warning;
   ELSE
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;
   -- LPN CONV. rv
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,  'END OF API FOR UNASSIGNING EMPTY CONTAINERS FROM DELIVERIES'  );
   END IF;
   --
   --x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS; LPN CONV. rv

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS FROM FND_API.G_EXC_ERROR',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    THEN
    --{
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
          (
            p_in_rec             => l_lpn_in_sync_comm_rec,
            x_return_status      => l_return_status,
            x_out_rec            => l_lpn_out_sync_comm_rec
          );
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
        END IF;
        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
    --}
    END IF;
    --
    -- LPN CONV. rv
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS FROM FND_API.G_EXC_UNEXPECTED_ERROR',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    THEN
    --{

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --

        WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
          (
            p_in_rec             => l_lpn_in_sync_comm_rec,
            x_return_status      => l_return_status,
            x_out_rec            => l_lpn_out_sync_comm_rec
          );
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
        END IF;
        IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
        END IF;
    --}
    END IF;
    --
    -- LPN CONV. rv
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
    --
  WHEN OTHERS THEN
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS FROM WHEN OTHERS',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
    THEN
    --{
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --

        WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
          (
            p_in_rec             => l_lpn_in_sync_comm_rec,
            x_return_status      => l_return_status,
            x_out_rec            => l_lpn_out_sync_comm_rec
          );
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', l_return_status);
        END IF;
    --}
    END IF;
    --
    -- LPN CONV. rv
    --
    wsh_util_core.default_handler('WSH_DELIVERY_AUTOCREATE.unassign_empty_containers');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END unassign_empty_containers;

PROCEDURE Reset_WSH_TMP IS

BEGIN

delete from wsh_tmp;

END Reset_WSH_TMP;

/**________________________________________________________________________
--
-- Name:
-- Autocreate_Consol_Del
--
-- Purpose:
-- This API takes in a table of child deliveries and delivery attributes,
-- and creates a consolidation delivery. It currently assumes that
-- all the child deliveries can be grouped together and assigned to
-- a single parent delivery when called by the WSH CONSOL SRS.
-- Parameters:
-- p_del_attributes_tab: Table of deliveries and attributes that need to
-- have parent delivery autocreated.
-- p_caller: Calling entity/action
-- x_parent_del_tab: Delivery ids of the newly created parent deliveries.
-- x_return_status: status.
**/

PROCEDURE Autocreate_Consol_Delivery(
 p_del_attributes_tab IN WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
 p_caller IN VARCHAR2,
 p_trip_prefix IN VARCHAR2,
 x_parent_del_id OUT NOCOPY NUMBER,
 x_parent_trip_id OUT NOCOPY NUMBER,
 x_return_status OUT NOCOPY VARCHAR2) IS


 CURSOR c_trip_info(p_delivery_id IN NUMBER) IS
 SELECT s1.trip_id,
        NVL(d.ignore_for_planning, 'N')  --OTM R12, delivery ignore same as trip's
 FROM  wsh_delivery_legs l, wsh_trip_stops s1, wsh_new_deliveries d
 WHERE l.delivery_id = p_delivery_id
 AND   d.delivery_id = l.delivery_id
 AND   s1.stop_id = l.pick_up_stop_id
 AND   s1.stop_location_id = d.initial_pickup_location_id;

 CURSOR c_empty_stops(p_trip_id NUMBER) IS
 SELECT wts.stop_id
 FROM wsh_trip_stops wts
 WHERE wts.trip_id = p_trip_id
 AND NOT EXISTS (
  SELECT wdl.delivery_leg_id
  FROM wsh_delivery_legs wdl
  WHERE wdl.pick_up_stop_id = wts.stop_id
  OR wdl.drop_off_stop_id = wts.stop_id
  AND rownum = 1);


 l_trip_id NUMBER;
 l_trip_id_temp NUMBER;
-- l_trip_info_rec_tab is table of c_trip_info%rowtype index by binary_integer;

 l_del_attributes  WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
 l_del_tab  WSH_UTIL_CORE.id_tab_type;
 l_trip_del_tab  WSH_UTIL_CORE.id_tab_type;
 l_intermediate_loc_tab WSH_UTIL_CORE.id_tab_type;
 l_pickup_stop_id NUMBER;
 l_dropoff_stop_id NUMBER;
 l_caller VARCHAR2(30);
 l_delivery_leg_id_dummy NUMBER;
 l_intermediate_loc_id NUMBER;
 l_msg_count NUMBER;
 l_msg_data VARCHAR2(2000);
 i NUMBER;
 j NUMBER := 0;
 k NUMBER := 0;
 l_weight_uom_code VARCHAR2(3);
 l_volume_uom_code VARCHAR2(3);
 l_dummy           VARCHAR2(1);
 l_rowid           VARCHAR2(30);
 l_delivery_id     NUMBER;
 l_delivery_name   VARCHAR2(30);
 l_delivery_id_tab WSH_UTIL_CORE.id_tab_type;
 l_valid_trip VARCHAR2(1);
 l_trip_name_tab   wsh_util_core.Column_Tab_Type;
 l_trip_id_tab     wsh_util_core.id_tab_type;
 l_empty_stops_tab     wsh_util_core.id_tab_type;
 l_transit_time    NUMBER;
 l_deconsol_do_date DATE;
 l_num_warnings              NUMBER  := 0;
 l_num_errors                NUMBER  := 0;
 l_return_status             VARCHAR2(30);

 WSH_INVALID_TRIPS EXCEPTION;

 --OTM R12, changes for MDC
 l_non_trip_del_tab     WSH_UTIL_CORE.id_tab_type;
 l_non_trip_del_count   NUMBER;
 l_trip_ignore          VARCHAR2(1);
 l_trip_ignore_temp     VARCHAR2(1);
 l_gc3_is_installed     VARCHAR2(1);
 l_otm_trip_tab         WSH_UTIL_CORE.id_tab_type;
 --END OTM R12

 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Autocreate_Consol_Delivery';
 l_debug_on BOOLEAN;

BEGIN


  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
     wsh_debug_sv.push (l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'p_caller', p_caller);
     WSH_DEBUG_SV.log(l_module_name,'p_trip_prefix', p_trip_prefix);
  END IF;

  --OTM R12, initialize
  l_non_trip_del_count := 1;
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED; -- this is global variable

  IF l_gc3_is_installed IS NULL THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED; -- this is actual function
  END IF;
  --END OTM R12

  -- If the caller is consolidation SRS program then
  -- we can assume that all the child deliveries can
  -- be grouped into one parent delivery.
  IF p_caller <> 'WSH_CONSOL_SRS' THEN

      -- check if the deliveries are attached to common trips.
      -- If there is a common trip we will assign the consol delivery to that trip.

      i := p_del_attributes_tab.FIRST;
      WHILE i is not NULL LOOP
        j := j+1;
        l_del_tab(j) := p_del_attributes_tab(i).delivery_id;

        OPEN c_trip_info(p_del_attributes_tab(i).delivery_id);
        FETCH c_trip_info INTO l_trip_id_temp, l_trip_ignore_temp;

        IF (c_trip_info%FOUND) THEN
           IF l_trip_id IS NULL THEN
              l_trip_id := l_trip_id_temp;
              l_trip_ignore := l_trip_ignore_temp; --OTM R12, saving the ignore for planning status
           ELSIF l_trip_id <> l_trip_id_temp THEN
              CLOSE c_trip_info;
              RAISE WSH_INVALID_TRIPS;
           END IF;
           k := k+1;
           l_trip_del_tab(k) := p_del_attributes_tab(i).delivery_id;
           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_trip_del_tab:  '||k,l_trip_del_tab(k));
           END IF;
        END IF;

        --OTM R12, get the non trip deliveries for ignore for planning action
        IF (c_trip_info%NOTFOUND OR l_trip_id_temp IS NULL) THEN
          l_non_trip_del_tab(l_non_trip_del_count) := p_del_attributes_tab(i).delivery_id;

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_non_trip_del_tab:  '||l_non_trip_del_count,l_non_trip_del_tab(l_non_trip_del_count));
          END IF;

          l_non_trip_del_count := l_non_trip_del_count + 1;
        END IF;
        --END OTM R12

        CLOSE c_trip_info;

        i := p_del_attributes_tab.next(i);
      END LOOP;

      -- Check if we can consolidate the deliveries together

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FTE_COMP_CONSTRAINT_GRP.is_valid_consol',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_FTE_COMP_CONSTRAINT_GRP.is_valid_consol(
                       p_init_msg_list               =>  fnd_api.g_false,
                       p_input_delivery_id_tab       =>  l_del_tab,
                       p_target_consol_delivery_id   => NULL,
                       x_deconsolidation_location    => l_intermediate_loc_id,
                       x_return_status               => l_return_status,
                       x_msg_count                   => l_msg_count,
                       x_msg_data                    => l_msg_data
                       );

      wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

      l_del_tab.delete;
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_intermediate_loc_id', l_intermediate_loc_id);
      END IF;



  END IF;


  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_trip_id', l_trip_id);
    WSH_DEBUG_SV.log(l_module_name,'l_trip_ignore', l_trip_ignore);
  END IF;

  --OTM R12, changing the trip and deliveries to ignore for planning
  IF (l_gc3_is_installed = 'Y'
      AND l_trip_id IS NOT NULL
      AND l_trip_ignore = 'N') THEN

    l_otm_trip_tab(1) := l_trip_id;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TP_RELEASE.change_ignoreplan_status',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    WSH_TP_RELEASE.change_ignoreplan_status
                   (p_entity        => 'TRIP',
                    p_in_ids        => l_otm_trip_tab,
                    p_action_code   => 'IGNORE_PLAN',
                    x_return_status => l_return_status);

    wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

    --now call for the deliveries
    IF (l_non_trip_del_tab.COUNT > 0) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TP_RELEASE.change_ignoreplan_status',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_TP_RELEASE.change_ignoreplan_status
                   (p_entity        => 'DLVY',
                    p_in_ids        => l_non_trip_del_tab,
                    p_action_code   => 'IGNORE_PLAN',
                    x_return_status => l_return_status);

      wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
    END IF;
  END IF;
  --OTM R12

  i := p_del_attributes_tab.FIRST;
  l_del_attributes.initial_pickup_date := p_del_attributes_tab(p_del_attributes_tab.FIRST).initial_pickup_date;
  l_del_attributes.ultimate_dropoff_date := p_del_attributes_tab(p_del_attributes_tab.FIRST).ultimate_dropoff_date;
  WHILE i is not NULL LOOP
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'delivery: '|| i, p_del_attributes_tab(i).delivery_id);
      END IF;
      l_del_attributes.initial_pickup_date :=  GREATEST(l_del_attributes.initial_pickup_date, p_del_attributes_tab(i).initial_pickup_date);
      l_deconsol_do_date := GREATEST(LEAST(l_del_attributes.ultimate_dropoff_date,
                                           p_del_attributes_tab(i).ultimate_dropoff_date),
                                     l_del_attributes.initial_pickup_date);
      IF l_deconsol_do_date = l_del_attributes.initial_pickup_date THEN
         l_deconsol_do_date := l_deconsol_do_date + 1/144;
      END IF;


      i := p_del_attributes_tab.next(i);
  END LOOP;


  IF p_caller = 'WSH_CONSOL_SRS' THEN
     l_del_attributes.ultimate_dropoff_location_id := p_del_attributes_tab(p_del_attributes_tab.FIRST).intmed_ship_to_location_id;
     l_del_attributes.customer_id :=  p_del_attributes_tab(p_del_attributes_tab.FIRST).customer_id;
     l_del_attributes.fob_code :=  p_del_attributes_tab(p_del_attributes_tab.FIRST).fob_code;
     l_del_attributes.freight_terms_code :=  p_del_attributes_tab(p_del_attributes_tab.FIRST).freight_terms_code;
     l_del_attributes.ship_method_code :=  p_del_attributes_tab(p_del_attributes_tab.FIRST).ship_method_code;
     l_del_attributes.carrier_id :=  p_del_attributes_tab(p_del_attributes_tab.FIRST).carrier_id;
     l_del_attributes.mode_of_transport :=  p_del_attributes_tab(p_del_attributes_tab.FIRST).mode_of_transport;
     l_del_attributes.service_level :=  p_del_attributes_tab(p_del_attributes_tab.FIRST).service_level;
  ELSE
     l_del_attributes.ultimate_dropoff_location_id := l_intermediate_loc_id;
  END IF;

  l_del_attributes.intmed_ship_to_location_id := NULL;
  l_del_attributes.delivery_id := NULL;
  l_del_attributes.name := NULL;
  l_del_attributes.delivery_type := 'CONSOLIDATION';
  l_del_attributes.shipment_direction := 'O';
  l_del_attributes.organization_id := p_del_attributes_tab(p_del_attributes_tab.FIRST).organization_id;
  l_del_attributes.initial_pickup_location_id := p_del_attributes_tab(p_del_attributes_tab.FIRST).initial_pickup_location_id;
  --OTM R12, when OTM is installed, the ignore for planning will be Y
  IF (l_gc3_is_installed = 'Y'
      AND l_trip_id IS NOT NULL
      AND l_trip_ignore = 'N') THEN
    l_del_attributes.ignore_for_planning := 'Y';
  ELSE
    l_del_attributes.ignore_for_planning := p_del_attributes_tab(p_del_attributes_tab.FIRST).ignore_for_planning;
  END IF;
  --END OTM R12

  l_del_attributes.status_code := 'OP';

  l_transit_time := NULL;
  IF l_del_attributes.ship_method_code IS NOT NULL THEN

     FTE_LANE_SEARCH.Get_Transit_Time(
                           p_ship_from_loc_id => l_del_attributes.initial_pickup_location_id,
                           p_ship_to_site_id  => l_del_attributes.ultimate_dropoff_location_id,
                           p_carrier_id       => l_del_attributes.carrier_id,
                           p_service_code     => l_del_attributes.service_level,
                           p_mode_code        => l_del_attributes.mode_of_transport,
                           p_from             => 'FTE',
                           x_transit_time     => l_transit_time,
                           x_return_status    => l_return_status);

  END IF;
  IF l_transit_time IS NOT NULL
  AND (l_deconsol_do_date >  l_del_attributes.initial_pickup_date + l_transit_time) THEN
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_transit_time',l_transit_time);
     END IF;

     l_del_attributes.ultimate_dropoff_date := l_del_attributes.initial_pickup_date + l_transit_time;
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'ultimate_dropoff_date',l_del_attributes.ultimate_dropoff_date);
     END IF;

  ELSE
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_transit_time',l_transit_time);
     END IF;

     l_del_attributes.ultimate_dropoff_date := l_del_attributes.initial_pickup_date +
                                               ((l_deconsol_do_date - l_del_attributes.initial_pickup_date)/2);

     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'initial_pickup_date',l_del_attributes.initial_pickup_date);
        WSH_DEBUG_SV.log(l_module_name,'l_deconsol_do_date',l_deconsol_do_date);
        WSH_DEBUG_SV.log(l_module_name,'ultimate_dropoff_date',l_del_attributes.ultimate_dropoff_date);
     END IF;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_wv_utils.get_default_uoms',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  wsh_wv_utils.get_default_uoms(l_del_attributes.organization_id, l_weight_uom_code, l_volume_uom_code, l_dummy);

  l_del_attributes.weight_uom_code := l_weight_uom_code;
  l_del_attributes.volume_uom_code := l_volume_uom_code;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'l_weight_uom_code',l_weight_uom_code);
     WSH_DEBUG_SV.log(l_module_name,'l_volume_uom_code',l_volume_uom_code);
  END IF;

  -- Create the delivery

  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'wsh_new_deliveries_pvt.create_delivery',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  wsh_new_deliveries_pvt.create_delivery(l_del_attributes, l_rowid, l_delivery_id, l_delivery_name, l_return_status);

  wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

  l_delivery_id_tab(1) := l_delivery_id;

  -- If there is a common trip, unassign the child deliveries from the trip, as the dropoff locations differ.
  -- they will get reassigned to the trip at the pickup and deconsol point.
  -- we then assign the consol delivery to the trip

  IF l_trip_id IS NOT NULL THEN

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TRIPS_ACTIONS.Unassign_Trip',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     WSH_TRIPS_ACTIONS.Unassign_Trip(p_del_rows => l_trip_del_tab,
                                      p_trip_id  => l_trip_id,
                                      x_return_status => l_return_status);

     wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

     -- Delete the empty stops on the trip.
     OPEN c_empty_stops(l_trip_id);
     FETCH c_empty_stops BULK COLLECT INTO l_empty_stops_tab;
     CLOSE c_empty_stops;

     IF l_empty_stops_tab.count > 0 THEN
        IF l_debug_on THEN
           FOR i in 1 .. l_empty_stops_tab.count LOOP
             WSH_DEBUG_SV.log(l_module_name,'empty stop '||i,l_empty_stops_tab(i));
           END LOOP;
        END IF;

        WSH_UTIL_CORE.Delete(p_type => 'STOP',
                       p_rows => l_empty_stops_tab,
                       x_return_status => l_return_status);

        wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

     END IF;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TRIPS_ACTIONS.assign_Trip',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     WSH_TRIPS_ACTIONS.assign_trip(
                p_del_rows              => l_delivery_id_tab,
                p_trip_id               => l_trip_id,
                p_pickup_location_id    => l_del_attributes.initial_pickup_location_id,
                p_dropoff_location_id   => l_del_attributes.ultimate_dropoff_location_id,
                p_pickup_arr_date       => l_del_attributes.initial_pickup_date,
                p_pickup_dep_date       => l_del_attributes.initial_pickup_date,
                p_dropoff_arr_date      => l_del_attributes.ultimate_dropoff_date,
                p_dropoff_dep_date      => l_del_attributes.ultimate_dropoff_date,
                x_return_status         => l_return_status,
                p_caller                => p_caller);

     wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
  ELSE

     -- Autocreate trip for consol del
     l_trip_name_tab(1) := p_trip_prefix;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TRIPS_ACTIONS.autocreate_trip_multi',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     WSH_TRIPS_ACTIONS.autocreate_trip_multi(
                          p_del_rows      => l_delivery_id_tab,
                          x_trip_ids      => l_trip_id_tab,
                          x_trip_names    => l_trip_name_tab,
                          x_return_status => l_return_status);

     wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
     l_trip_id := l_trip_id_tab(1);
  END IF;

  -- Now assign the child deliveries to the parent.
  -- This would also assign the child delivery to the
  -- trip if it is already not assigned.

  -- Set the p_caller:

  IF p_caller like 'WSH%' THEN
     l_caller := 'WSH_AUTOCREATE_CONSOL';
  ELSIF p_caller like 'WMS%' THEN
     l_caller := 'WMS_AUTOCREATE_CONSOL';
  END IF;


  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'WSH_NEW_DELIVERY_ACTIONS.Assign_Del_to_Consol_Del',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  WSH_NEW_DELIVERY_ACTIONS.Assign_Del_to_Consol_Del(
          p_del_tab       => p_del_attributes_tab,
          p_parent_del_id => l_delivery_id,
          p_caller        => l_caller,
          x_return_status => l_return_status);

  wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );

  IF p_trip_prefix IS NOT NULL THEN
     update wsh_trips set
     name =  p_trip_prefix ||'-'|| name
     where trip_id = l_trip_id_tab(1);
  END IF;


  IF l_num_errors > 0
  THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF l_num_warnings > 0
  THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  END IF;

  x_parent_del_id := l_delivery_id;
  x_parent_trip_id := l_trip_id;
  --
IF l_debug_on THEN
wsh_debug_sv.pop(l_module_name);
END IF;
EXCEPTION
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
  WHEN WSH_INVALID_TRIPS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_TRIPS');
        WSH_UTIL_CORE.Add_Message(x_return_status);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_TRIPS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);

        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_TRIPS');
        END IF;
        --

  WHEN OTHERS THEN
    wsh_util_core.default_handler('WSH_DELIVERY_AUTOCREATE.Autocreate_Consol_Delivery',l_module_name);
      --
    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
    END IF;

END Autocreate_Consol_Delivery;

END WSH_DELIVERY_AUTOCREATE;


/
