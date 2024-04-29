--------------------------------------------------------
--  DDL for Package Body WSH_SHIPMENT_REQUEST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SHIPMENT_REQUEST_PUB" as
/* $Header: WSHSRPBB.pls 120.0.12010000.6 2009/12/03 12:23:19 mvudugul noship $ */


G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_SHIPMENT_REQUEST_PUB';

--========================================================================
--PRIVATE APIS

  PROCEDURE Create_Shipment_Request
  ( p_shipment_request_info  IN   OUT NOCOPY Shipment_Request_Rec_Type,
    p_caller                 IN VARCHAR2,
    x_return_status          OUT NOCOPY    VARCHAR2);

  PROCEDURE Query_Shipment_Request
  (   p_shipment_request_info  IN   OUT NOCOPY Shipment_Request_Rec_Type,
    x_interface_errors_info  OUT NOCOPY Interface_Errors_Rec_Tab,
    x_return_status          OUT NOCOPY    VARCHAR2);

  PROCEDURE Update_Delete_Shipment_Request
  (
   p_action_code            IN   VARCHAR2,
   p_shipment_request_info  IN OUT NOCOPY Shipment_Request_Rec_Type,
   x_return_status          OUT NOCOPY    VARCHAR2);
--========================================================================

--========================================================================
-- PROCEDURE : Shipment_Request         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_action_code           'QUERY', 'CREATE', 'UPDATE' or 'DELETE'
--	           p_shipment_request_info Attributes for the shipment request entity
--                                     The attributes Documnet_number document revision are
--                                     mandatory parameters in all the cases.
--                                     The parameter 'line_number' should be passed if
--                                     the action is 'QUERY/UPDATE/DELETE' and only
--                                     the user is concerned with only a part of the set of
--                                     delivery details available for the document.
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or Updates or Deletes Shipment Request
--             specified in p_shipment_request_info
--========================================================================
PROCEDURE Shipment_Request(
                p_api_version_number     IN   NUMBER,
                p_init_msg_list          IN   VARCHAR2 ,
                p_action_code            IN   VARCHAR2 ,
                p_shipment_request_info  IN OUT NOCOPY Shipment_Request_Rec_Type,
                x_interface_errors_info  OUT NOCOPY Interface_Errors_Rec_Tab,
                p_commit                 IN  VARCHAR2 ,
                x_return_status          OUT NOCOPY    VARCHAR2,
                x_msg_count              OUT NOCOPY    NUMBER,
                x_msg_data               OUT NOCOPY    VARCHAR2) AS

    --
    l_return_status          VARCHAR2(100);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(1000);
    --
    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Shipment_Request';
    l_invalid_inputs  NUMBER;
    --
    l_api_version_number CONSTANT NUMBER := 1.0;
    l_api_name           CONSTANT VARCHAR2(30):= 'Shipment_Request';
    --

BEGIN
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

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'p_action_code',p_action_code);
        WSH_DEBUG_SV.log(l_module_name,'Number of WDDI Records',p_shipment_request_info.shipment_details_tab.count);
        WSH_DEBUG_SV.log(l_module_name,'p_commit',p_commit);
        WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
        WSH_DEBUG_SV.logmsg(l_module_name, '|          WNDI RECORD DETAILS              |');
        WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
        WSH_DEBUG_SV.log(l_module_name,'document_number',           p_shipment_request_info.document_number);
        WSH_DEBUG_SV.log(l_module_name,'document_revision',         p_shipment_request_info.document_revision);
        WSH_DEBUG_SV.log(l_module_name,'action_type',               p_shipment_request_info.action_type);
        WSH_DEBUG_SV.log(l_module_name,'organization_code',         p_shipment_request_info.organization_code);
        WSH_DEBUG_SV.log(l_module_name,'customer_id',               p_shipment_request_info.customer_id);
        WSH_DEBUG_SV.log(l_module_name,'customer_name',             p_shipment_request_info.customer_name);
        WSH_DEBUG_SV.log(l_module_name,'ship_to_customer_id',       p_shipment_request_info.ship_to_customer_id);
        WSH_DEBUG_SV.log(l_module_name,'ship_to_customer_name',     p_shipment_request_info.ship_to_customer_name);
        WSH_DEBUG_SV.log(l_module_name,'ship_to_address_id',        p_shipment_request_info.ship_to_address_id);
        WSH_DEBUG_SV.log(l_module_name,'ship_to_address1',          p_shipment_request_info.ship_to_address1);
        WSH_DEBUG_SV.log(l_module_name,'ship_to_address2',          p_shipment_request_info.ship_to_address2);
        WSH_DEBUG_SV.log(l_module_name,'ship_to_address3',          p_shipment_request_info.ship_to_address3);
        WSH_DEBUG_SV.log(l_module_name,'ship_to_address4',          p_shipment_request_info.ship_to_address4);
        WSH_DEBUG_SV.log(l_module_name,'ship_to_city',              p_shipment_request_info.ship_to_city);
        WSH_DEBUG_SV.log(l_module_name,'ship_to_state',             p_shipment_request_info.ship_to_state);
        WSH_DEBUG_SV.log(l_module_name,'ship_to_country',           p_shipment_request_info.ship_to_country);
        WSH_DEBUG_SV.log(l_module_name,'ship_to_postal_code',       p_shipment_request_info.ship_to_postal_code);
        WSH_DEBUG_SV.log(l_module_name,'ship_to_contact_id',        p_shipment_request_info.ship_to_contact_id);
        WSH_DEBUG_SV.log(l_module_name,'ship_to_contact_name',      p_shipment_request_info.ship_to_contact_name);
        WSH_DEBUG_SV.log(l_module_name,'ship_to_contact_phone',     p_shipment_request_info.ship_to_contact_phone);

        WSH_DEBUG_SV.log(l_module_name,'invoice_to_customer_id',    p_shipment_request_info.invoice_to_customer_id);
        WSH_DEBUG_SV.log(l_module_name,'invoice_to_customer_name',  p_shipment_request_info.invoice_to_customer_name);
        WSH_DEBUG_SV.log(l_module_name,'invoice_to_address_id',     p_shipment_request_info.invoice_to_address_id);
        WSH_DEBUG_SV.log(l_module_name,'invoice_to_address1',       p_shipment_request_info.invoice_to_address1);
        WSH_DEBUG_SV.log(l_module_name,'invoice_to_address2',       p_shipment_request_info.invoice_to_address2);
        WSH_DEBUG_SV.log(l_module_name,'invoice_to_address3',       p_shipment_request_info.invoice_to_address3);
        WSH_DEBUG_SV.log(l_module_name,'invoice_to_address4',       p_shipment_request_info.invoice_to_address4);
        WSH_DEBUG_SV.log(l_module_name,'invoice_to_city',           p_shipment_request_info.invoice_to_city);
        WSH_DEBUG_SV.log(l_module_name,'invoice_to_state',          p_shipment_request_info.invoice_to_state);
        WSH_DEBUG_SV.log(l_module_name,'invoice_to_country',        p_shipment_request_info.invoice_to_country);
        WSH_DEBUG_SV.log(l_module_name,'invoice_to_postal_code',    p_shipment_request_info.invoice_to_postal_code);
        WSH_DEBUG_SV.log(l_module_name,'invoice_to_contact_id',     p_shipment_request_info.invoice_to_contact_id);
        WSH_DEBUG_SV.log(l_module_name,'invoice_to_contact_name',   p_shipment_request_info.invoice_to_contact_name);
        WSH_DEBUG_SV.log(l_module_name,'invoice_to_contact_phone',  p_shipment_request_info.invoice_to_contact_phone);

        WSH_DEBUG_SV.log(l_module_name,'deliver_to_customer_id',    p_shipment_request_info.deliver_to_customer_id);
        WSH_DEBUG_SV.log(l_module_name,'deliver_to_customer_name',  p_shipment_request_info.deliver_to_customer_name);
        WSH_DEBUG_SV.log(l_module_name,'deliver_to_address_id',     p_shipment_request_info.deliver_to_address_id);
        WSH_DEBUG_SV.log(l_module_name,'deliver_to_address1',       p_shipment_request_info.deliver_to_address1);
        WSH_DEBUG_SV.log(l_module_name,'deliver_to_address2',       p_shipment_request_info.deliver_to_address2);
        WSH_DEBUG_SV.log(l_module_name,'deliver_to_address3',       p_shipment_request_info.deliver_to_address3);
        WSH_DEBUG_SV.log(l_module_name,'deliver_to_address4',       p_shipment_request_info.deliver_to_address4);
        WSH_DEBUG_SV.log(l_module_name,'deliver_to_city',           p_shipment_request_info.deliver_to_city);
        WSH_DEBUG_SV.log(l_module_name,'deliver_to_state',          p_shipment_request_info.deliver_to_state);
        WSH_DEBUG_SV.log(l_module_name,'deliver_to_country',        p_shipment_request_info.deliver_to_country);
        WSH_DEBUG_SV.log(l_module_name,'deliver_to_postal_code',    p_shipment_request_info.deliver_to_postal_code);
        WSH_DEBUG_SV.log(l_module_name,'deliver_to_contact_id',     p_shipment_request_info.deliver_to_contact_id);
        WSH_DEBUG_SV.log(l_module_name,'deliver_to_contact_name',   p_shipment_request_info.deliver_to_contact_name);
        WSH_DEBUG_SV.log(l_module_name,'deliver_to_contact_phone',  p_shipment_request_info.deliver_to_contact_phone);

        WSH_DEBUG_SV.log(l_module_name,'carrier_code',              p_shipment_request_info.carrier_code);
        WSH_DEBUG_SV.log(l_module_name,'service_level',             p_shipment_request_info.service_level);
        WSH_DEBUG_SV.log(l_module_name,'mode_of_transport',         p_shipment_request_info.mode_of_transport);
        WSH_DEBUG_SV.log(l_module_name,'freight_terms_code',        p_shipment_request_info.freight_terms_code);
        WSH_DEBUG_SV.log(l_module_name,'fob_code',                  p_shipment_request_info.fob_code);
        WSH_DEBUG_SV.log(l_module_name,'currency_code',             p_shipment_request_info.currency_code);
        WSH_DEBUG_SV.log(l_module_name,'transaction_type_id',       p_shipment_request_info.transaction_type_id);
        WSH_DEBUG_SV.log(l_module_name,'price_list_id',             p_shipment_request_info.price_list_id);
        WSH_DEBUG_SV.log(l_module_name,'client_code',               p_shipment_request_info.client_code);    -- LSP PROJECT

        IF p_shipment_request_info.shipment_details_tab.count>0 THEN
            FOR i in 1..p_shipment_request_info.shipment_details_tab.count LOOP
                WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
                WSH_DEBUG_SV.logmsg(l_module_name, '|           WDDI RECORD DETAILS - ' || i || '           |');
                WSH_DEBUG_SV.logmsg(l_module_name, '===============================================');
                WSH_DEBUG_SV.log(l_module_name,'line_number',                p_shipment_request_info.shipment_details_tab(i).line_number);
                WSH_DEBUG_SV.log(l_module_name,'item_number',                p_shipment_request_info.shipment_details_tab(i).item_number);
                WSH_DEBUG_SV.log(l_module_name,'inventory_item_id',          p_shipment_request_info.shipment_details_tab(i).inventory_item_id);
                WSH_DEBUG_SV.log(l_module_name,'item_description',           p_shipment_request_info.shipment_details_tab(i).item_description);
                WSH_DEBUG_SV.log(l_module_name,'requested_quantity',         p_shipment_request_info.shipment_details_tab(i).requested_quantity);
                WSH_DEBUG_SV.log(l_module_name,'requested_quantity_uom',     p_shipment_request_info.shipment_details_tab(i).requested_quantity_uom);
                WSH_DEBUG_SV.log(l_module_name,'customer_item_id',           p_shipment_request_info.shipment_details_tab(i).customer_item_id );
                WSH_DEBUG_SV.log(l_module_name,'customer_item_number',       p_shipment_request_info.shipment_details_tab(i).customer_item_number);
                WSH_DEBUG_SV.log(l_module_name,'date_requested',             p_shipment_request_info.shipment_details_tab(i).date_requested);
                WSH_DEBUG_SV.log(l_module_name,'date_scheduled',             p_shipment_request_info.shipment_details_tab(i).date_scheduled);
                WSH_DEBUG_SV.log(l_module_name,'ship_tolerance_above',       p_shipment_request_info.shipment_details_tab(i).ship_tolerance_above);
                WSH_DEBUG_SV.log(l_module_name,'ship_tolerance_below',       p_shipment_request_info.shipment_details_tab(i).ship_tolerance_below);
                WSH_DEBUG_SV.log(l_module_name,'packing_instructions',       p_shipment_request_info.shipment_details_tab(i).packing_instructions);
                WSH_DEBUG_SV.log(l_module_name,'shipping_instructions',      p_shipment_request_info.shipment_details_tab(i).shipping_instructions);
                WSH_DEBUG_SV.log(l_module_name,'shipment_priority_code',     p_shipment_request_info.shipment_details_tab(i).shipment_priority_code);
                WSH_DEBUG_SV.log(l_module_name,'ship_set_name',              p_shipment_request_info.shipment_details_tab(i).ship_set_name);
                WSH_DEBUG_SV.log(l_module_name,'subinventory',               p_shipment_request_info.shipment_details_tab(i).subinventory   );
                WSH_DEBUG_SV.log(l_module_name,'revision',                   p_shipment_request_info.shipment_details_tab(i).revision   );
                WSH_DEBUG_SV.log(l_module_name,'locator_code',               p_shipment_request_info.shipment_details_tab(i).locator_code   );
                WSH_DEBUG_SV.log(l_module_name,'locator_id',                 p_shipment_request_info.shipment_details_tab(i).locator_id   );
                WSH_DEBUG_SV.log(l_module_name,'lot_number',                 p_shipment_request_info.shipment_details_tab(i).lot_number   );
                WSH_DEBUG_SV.log(l_module_name,'unit_selling_price',         p_shipment_request_info.shipment_details_tab(i).unit_selling_price   );
                WSH_DEBUG_SV.log(l_module_name,'currency_code',              p_shipment_request_info.shipment_details_tab(i).currency_code   );
                WSH_DEBUG_SV.log(l_module_name,'earliest_pickup_date',       p_shipment_request_info.shipment_details_tab(i).earliest_pickup_date);
                WSH_DEBUG_SV.log(l_module_name,'latest_pickup_date',         p_shipment_request_info.shipment_details_tab(i).latest_pickup_date );
                WSH_DEBUG_SV.log(l_module_name,'earliest_dropoff_date',      p_shipment_request_info.shipment_details_tab(i).earliest_dropoff_date);
                WSH_DEBUG_SV.log(l_module_name,'latest_dropoff_date',        p_shipment_request_info.shipment_details_tab(i).latest_dropoff_date);
                WSH_DEBUG_SV.log(l_module_name,'cust_po_number',             p_shipment_request_info.shipment_details_tab(i).cust_po_number);
                WSH_DEBUG_SV.log(l_module_name,'source_header_number',       p_shipment_request_info.shipment_details_tab(i).source_header_number);
                WSH_DEBUG_SV.log(l_module_name,'src_requested_quantity',     p_shipment_request_info.shipment_details_tab(i).src_requested_quantity);
                WSH_DEBUG_SV.log(l_module_name,'src_requested_quantity_uom', p_shipment_request_info.shipment_details_tab(i).src_requested_quantity_uom);
                WSH_DEBUG_SV.log(l_module_name,'source_line_number',         p_shipment_request_info.shipment_details_tab(i).source_line_number );
            END LOOP;
        END IF;

    END IF;
    --
    l_invalid_inputs := 0;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    IF p_shipment_request_info.Document_Number IS NULL OR  p_shipment_request_info.Document_REVISION is NULL THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            fnd_message.set_name('WSH', 'WSH_STND_ATTR_MANDATORY');
            fnd_message.set_token('ATTRIBUTE','DOCUMENT_NUMBER and DOCUMENT_REVISION');
            wsh_util_core.add_message(x_return_status);

            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Mandatory input parameters have not been passed');
            END IF;
    END IF;

    IF p_shipment_request_info.Document_Number <= 0 OR
       p_shipment_request_info.Document_Number <> trunc(p_shipment_request_info.Document_Number) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        fnd_message.set_name('WSH', 'WSH_STND_POSITIVE_INTEGER');
        fnd_message.set_token('ATTRIBUTE', 'DOCUMENT_NUMBER');
        wsh_util_core.add_message(x_return_status);

        l_invalid_inputs := 1;
    END IF;
    IF p_shipment_request_info.Document_revision <= 0 OR
       p_shipment_request_info.Document_revision <> trunc(p_shipment_request_info.Document_revision ) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        fnd_message.set_name('WSH', 'WSH_STND_POSITIVE_INTEGER');
        fnd_message.set_token('ATTRIBUTE', 'DOCUMENT_REVISION');
        wsh_util_core.add_message(x_return_status);

        l_invalid_inputs := 1;
    END IF;

    IF p_shipment_request_info.ACTION_TYPE NOT IN ('A','C','D') THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        fnd_message.set_name('WSH', 'WSH_OI_INVALID_ATTRIBUTE');
        fnd_message.set_token('ATTRIBUTE', 'ACTION_TYPE');
        wsh_util_core.add_message(x_return_status);
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Action Type should be A or C or D. Action type',p_shipment_request_info.ACTION_TYPE);
        END IF;
        l_invalid_inputs := 1;
    END IF;

    IF l_invalid_inputs = 1 THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_action_code = 'CREATE' THEN
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Create_Shipment_Request with SHIPMENT_REQUEST', WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        Create_Shipment_Request(p_shipment_request_info  => p_shipment_request_info,
                                p_caller                 => 'SHIPMENT_REQUEST',
                                x_return_status          => l_return_status);

        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'The Action '||p_action_code||' failed');
            END IF;
            x_return_status := l_return_status;
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    ELSIF p_action_code = 'QUERY' THEN
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Query_Shipment_Request', WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        Query_Shipment_Request(p_shipment_request_info         => p_shipment_request_info,
                               x_interface_errors_info         => x_interface_errors_info ,
                               x_return_status                 => l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'The Action '||p_action_code||' failed');
            END IF;
            x_return_status := l_return_status;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    ELSIF p_action_code = 'UPDATE' OR p_action_code ='DELETE' THEN
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Update_Delete_Shipment_Request', WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        Update_Delete_Shipment_Request(
                            p_action_code           => p_action_code,
                            p_shipment_request_info => p_shipment_request_info,
                            x_return_status         => l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'The Action '||p_action_code||' failed');
            END IF;
            x_return_status := l_return_status;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        fnd_message.set_name('WSH', 'WSH_PUB_INVALID_ACTION');
        fnd_message.set_token('ACTION_CODE', p_action_code);
        wsh_util_core.add_message(x_return_status);
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'p_action_code should be CREATE/QUERY/UPDATE/DELETE.The current value is',p_action_code);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_commit = FND_API.G_TRUE THEN
       COMMIT;
    END IF;

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        p_shipment_request_info.delivery_interface_id := NULL;
        p_shipment_request_info.transaction_id := null;
        IF p_shipment_request_info.shipment_details_tab.count >0 THEN
            FOR i in 1..p_shipment_request_info.shipment_details_tab.count LOOP
                p_shipment_request_info.shipment_details_tab(i).delivery_detail_interface_id := NULL;
            END LOOP;
        END IF;
        fnd_msg_pub.count_and_get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => fnd_api.g_false);
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
        END IF;
        rollback;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Error performing the action '''|| p_action_code ||''' on Document_Number',p_shipment_request_info.Document_Number);
            WSH_DEBUG_SV.pop(l_module_name,'FND_API.G_EXC_ERROR');
        END IF;
    WHEN others THEN
        p_shipment_request_info.delivery_interface_id := NULL;
        p_shipment_request_info.transaction_id := null;
        IF p_shipment_request_info.shipment_details_tab.count >0 THEN
            FOR i in 1..p_shipment_request_info.shipment_details_tab.count LOOP
                p_shipment_request_info.shipment_details_tab(i).delivery_detail_interface_id := NULL;
            END LOOP;
        END IF;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
        END IF;
        rollback;
        fnd_msg_pub.count_and_get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => fnd_api.g_false);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Shipment_Request;

--========================================================================
-- PROCEDURE : Process_Shipment_Requests         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_process_mode          'ONLINE' or 'CONCURRENT'
--	           p_criteria_info         Attributes for the Process Shipment Request criteria
--	           p_log_level             0 or 1 to control the log messages
--             x_request_id            Concurrent request id when p_process_mode is 'CONCURRENT'
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Processes Shipment Requests as per criteria
--             specified in p_criteria_info
--========================================================================

PROCEDURE Process_Shipment_Requests(
                p_api_version_number     IN  NUMBER,
                p_init_msg_list          IN  VARCHAR2 ,
                p_process_mode           IN  VARCHAR2 ,
                p_criteria_info          IN  Criteria_Rec_Type,
                p_log_level              IN  NUMBER   ,
                p_commit                 IN  VARCHAR2 ,
                x_request_id             OUT NOCOPY    NUMBER,
                x_return_status          OUT NOCOPY    VARCHAR2,
                x_msg_count              OUT NOCOPY    NUMBER,
                x_msg_data               OUT NOCOPY    VARCHAR2) AS

    l_return_status VARCHAR2(100);
    --
    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Shipment_Requests';
    --
    CURSOR c_get_date(p_date1 DATE,p_date2 DATE) IS
    SELECT to_char(p_date1,'YYYY/MM/DD HH24:MI:SS'),to_char(p_date2,'YYYY/MM/DD HH24:MI:SS') FROM DUAL;

    l_from_date VARCHAR2(100);
    l_to_date VARCHAR2(100);
    --
    l_api_version_number CONSTANT NUMBER := 1.0;
    l_api_name           CONSTANT VARCHAR2(30):= 'Process_Shipment_Requests';
    --


BEGIN
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

    IF l_debug_on THEN
        --
        WSH_DEBUG_SV.log(l_module_name,'p_process_mode',p_process_mode);
        WSH_DEBUG_SV.log(l_module_name,'p_log_level',p_log_level);
        WSH_DEBUG_SV.log(l_module_name,'p_commit',p_commit);
        --
        WSH_DEBUG_SV.log(l_module_name,'p_process_mode',p_process_mode);
        WSH_DEBUG_SV.log(l_module_name,'p_criteria_info.shipment_request_status',p_criteria_info.shipment_request_status);
        WSH_DEBUG_SV.log(l_module_name,'p_criteria_info.from_shipment_request_number',p_criteria_info.from_shipment_request_number);
        WSH_DEBUG_SV.log(l_module_name,'p_criteria_info.to_shipment_request_number',p_criteria_info.to_shipment_request_number);
        WSH_DEBUG_SV.log(l_module_name,'p_criteria_info.from_shipment_request_date',p_criteria_info.from_shipment_request_date);
        WSH_DEBUG_SV.log(l_module_name,'p_criteria_info.to_shipment_request_date',p_criteria_info.to_shipment_request_date);
        WSH_DEBUG_SV.log(l_module_name,'p_criteria_info.transaction_id',p_criteria_info.transaction_id);
        WSH_DEBUG_SV.log(l_module_name,'p_criteria_info.client_code',p_criteria_info.client_code); -- LSP PROJECT
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF p_process_mode = 'ONLINE' THEN
        OPEN c_get_date(p_criteria_info.from_shipment_request_date,p_criteria_info.from_shipment_request_date);
        FETCH c_get_date into l_from_date,l_to_date;
        CLOSE c_get_date;

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_SHIPMENT_REQUEST_PKG.Process_Shipment_Request', WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        -- Passing p_commit as TRUE, irrespective of the value passed to PUBLIC API
        -- Issue if p_commit value passed FALSE:
        --   If Process_Shipment_Request fails then it deletes the existing error messages from WIE table(non-autonomous transaction)
        --   and inserts new error messages into WIE table(Autonomous transaction).
        --   If rollback  is performed in public API then there will be duplicate/extra error messages in WIE table.
        WSH_SHIPMENT_REQUEST_PKG.Process_Shipment_Request(
            p_commit_flag          => FND_API.G_TRUE,
            p_transaction_status   => p_criteria_info.shipment_request_status,
            p_client_code          => p_criteria_info.client_code, -- LSP PROJECT
            p_from_document_number => p_criteria_info.from_shipment_request_number,
            p_to_document_number   => p_criteria_info.to_shipment_request_number,
            p_from_creation_date   => l_from_date,
            p_to_creation_date     => l_to_date,
            p_transaction_id       => p_criteria_info.transaction_id,
            x_return_status        => l_return_status );


        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.Set_Name('WSH', 'WSH_SUCCESS_PROCESS');
            WSH_UTIL_CORE.Add_Message(l_return_status);
        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            x_return_status := l_return_status;
            fnd_msg_pub.count_and_get( p_encoded    => 'F'
                ,p_count      => x_msg_count
                ,p_data        => x_msg_data);
        ELSE
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Process_Shipment_Request completed with error');
            END IF;
            --
            x_return_status := l_return_status;
            FND_MESSAGE.Set_Name('WSH', 'WSH_STND_SR_PROCESS_ERROR');
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR);
            raise  FND_API.G_EXC_ERROR;
        END IF;


    ELSIF p_process_mode = 'CONCURRENT' THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Calling FND_REQUEST.SUBMIT_REQUEST', WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        x_request_id :=  FND_REQUEST.SUBMIT_REQUEST(
            application   =>  'WSH',
            program       =>  'WSHSRINB',
            description   =>  'Shipment Request Inbound Interface',
            start_time    =>   NULL,
            sub_request   =>   FALSE,
            argument1     =>   p_criteria_info.shipment_request_status,
            argument2     =>   p_criteria_info.from_shipment_request_number,
            argument3     =>   p_criteria_info.to_shipment_request_number,
            argument4     =>   l_from_date,
            argument5     =>   l_to_date,
            argument6     =>   p_criteria_info.transaction_id,
            argument7     =>   p_log_level  );

        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Request Id returned from FND_REQUEST.SUBMIT_REQUEST', x_request_id);
        END IF;
        --
        IF (nvl(x_request_id,0) <= 0) THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            raise  FND_API.G_EXC_ERROR;
        ELSE
            FND_MESSAGE.Set_Name('WSH', 'WSH_REQUEST_SUBMITTED');
            FND_MESSAGE.Set_Token('REQUEST_ID', x_request_id);
            WSH_UTIL_CORE.Add_Message(x_return_status);
        END IF;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        fnd_message.set_name('WSH', 'WSH_OI_INVALID_ATTRIBUTE');
        fnd_message.set_token('ATTRIBUTE', 'PROCESS_MODE');
        wsh_util_core.add_message(x_return_status);
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'p_process_mode should be ONLINE/CONCURRENT');
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        raise  FND_API.G_EXC_ERROR;
    END IF;

    IF p_commit =  FND_API.G_TRUE THEN
        COMMIT;
    END IF;
    fnd_msg_pub.count_and_get(p_count   => x_msg_count,
                          p_data    => x_msg_data,
                          p_encoded => fnd_api.g_false);
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        END IF;
        IF c_get_date%ISOPEN THEN
            CLOSE c_get_date;
        END IF;
        fnd_msg_pub.count_and_get( p_encoded    => 'F'
            ,p_count      => x_msg_count
            ,p_data        => x_msg_data);
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
        END IF;
        rollback;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Error occured while processing Shipment Request',p_criteria_info.transaction_id);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
    WHEN others THEN
        IF c_get_date%ISOPEN THEN
            CLOSE c_get_date;
        END IF;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
        END IF;
        rollback;

        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Process_Shipment_Requests;
--========================================================================
-- PROCEDURE : Create_Shipment_Request PRIVATE
--
-- PARAMETERS:
--	           p_shipment_request_info Attributes for the create shipment request
--             p_caller                Either SHIPMENT_REQUEST/UPDATE
--             x_return_status         return status
--
-- COMMENT   : If p_caller is SHIPMENT_REQUEST then records are inserted into
--             WNDI, WDDI, WDAI and WTH tables. If p_caller is UPDATE then
--             records are inserted only in WDDI and WDAI tables
--========================================================================
PROCEDURE Create_Shipment_Request(
                p_shipment_request_info  IN OUT NOCOPY Shipment_Request_Rec_Type,
                p_caller                 IN VARCHAR2,
                x_return_status          OUT NOCOPY    VARCHAR2) AS

    l_ins_rows                 NUMBER;
    l_exists                   NUMBER;
    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Shipment_Request';

    l_del_det_int_tab wsh_util_core.id_tab_type;
    --Bug8784331
    l_date_requested             wsh_util_core.Date_Tab_Type;
    l_date_scheduled             wsh_util_core.Date_Tab_Type;
    l_inventory_item_id          wsh_util_core.Id_Tab_Type;
    l_item_number                wsh_util_core.tbl_varchar;
    l_customer_item_id           wsh_util_core.Id_Tab_Type;
    l_customer_item_number       wsh_util_core.tbl_varchar;
    l_requested_quantity         wsh_util_core.Id_Tab_Type;
    l_requested_quantity_uom     wsh_util_core.tbl_varchar;
    l_src_requested_quantity     wsh_util_core.Id_Tab_Type;
    l_src_requested_quantity_uom wsh_util_core.tbl_varchar;
    l_line_number                wsh_util_core.Id_Tab_Type;
    l_source_line_number         wsh_util_core.tbl_varchar;
    l_source_header_number       wsh_util_core.tbl_varchar;
    l_earliest_pickup_date       wsh_util_core.Date_Tab_Type;
    l_latest_pickup_date         wsh_util_core.Date_Tab_Type;
    l_earliest_dropoff_date      wsh_util_core.Date_Tab_Type;
    l_latest_dropoff_date        wsh_util_core.Date_Tab_Type;
    l_ship_tolerance_above       wsh_util_core.Id_Tab_Type;
    l_ship_tolerance_below       wsh_util_core.Id_Tab_Type;
    l_shipping_instructions      wsh_util_core.tbl_varchar;
    l_packing_instructions       wsh_util_core.tbl_varchar;
    l_shipment_priority_code     wsh_util_core.tbl_varchar;
    l_cust_po_number             wsh_util_core.tbl_varchar;
    l_subinventory               wsh_util_core.tbl_varchar;
    l_locator_id                 wsh_util_core.Id_Tab_Type;
    l_locator_code               wsh_util_core.tbl_varchar;
    l_lot_number                 wsh_util_core.tbl_varchar;
    l_revision                   wsh_util_core.tbl_varchar;
    l_ship_set_name              wsh_util_core.tbl_varchar;
    l_unit_selling_price         wsh_util_core.Id_Tab_Type;
    --Bug8784331
BEGIN

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'Caller',p_caller);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    if p_caller ='SHIPMENT_REQUEST' THEN
    --{
        select count(*) into l_exists
        FROM   wsh_transactions_history
        WHERE  document_number = to_char(p_shipment_request_info.document_number)
        and    document_revision = p_shipment_request_info.document_revision
        AND    document_type = 'SR'
        AND    document_direction = 'I';

        if l_exists >0 THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            fnd_message.set_name('WSH', 'WSH_STND_DUP_DOCUMENT');
            fnd_message.set_token('DOCUMENT_NUMBER', p_shipment_request_info.document_number);
            fnd_message.set_token('DOCUMENT_REVISION', p_shipment_request_info.document_revision);
            wsh_util_core.add_message(x_return_status);
            IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name, 'The document already exists');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;


        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Inserting into WSH_NEW_DEL_INTERFACE');
        END IF;

        INSERT INTO WSH_NEW_DEL_INTERFACE(
                DELIVERY_INTERFACE_ID,
                PLANNED_FLAG,
                STATUS_CODE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                last_update_login,
                program_application_id,
                program_id,
                program_update_date,
                request_id,
                DELIVERY_TYPE,
                ORGANIZATION_CODE,
                CARRIER_CODE,
                SERVICE_LEVEL,
                MODE_OF_TRANSPORT,
                CUSTOMER_ID,
                CUSTOMER_NAME,
                SHIP_TO_CUSTOMER_ID,
                SHIP_TO_CUSTOMER_NAME,
                SHIP_TO_ADDRESS_ID,
                SHIP_TO_ADDRESS1,
                SHIP_TO_ADDRESS2,
                SHIP_TO_ADDRESS3,
                SHIP_TO_ADDRESS4,
                SHIP_TO_CITY,
                SHIP_TO_STATE,
                SHIP_TO_COUNTRY,
                SHIP_TO_POSTAL_CODE,
                SHIP_TO_CONTACT_ID,
                SHIP_TO_CONTACT_NAME,
                SHIP_TO_CONTACT_PHONE,
                INVOICE_TO_CUSTOMER_ID,
                INVOICE_TO_CUSTOMER_NAME,
                INVOICE_TO_ADDRESS_ID,
                INVOICE_TO_ADDRESS1,
                INVOICE_TO_ADDRESS2,
                INVOICE_TO_ADDRESS3,
                INVOICE_TO_ADDRESS4,
                INVOICE_TO_CITY,
                INVOICE_TO_STATE,
                INVOICE_TO_COUNTRY,
                INVOICE_TO_POSTAL_CODE,
                INVOICE_TO_CONTACT_ID,
                INVOICE_TO_CONTACT_NAME,
                INVOICE_TO_CONTACT_PHONE,
                DELIVER_TO_CUSTOMER_ID,
                DELIVER_TO_CUSTOMER_NAME,
                DELIVER_TO_ADDRESS_ID,
                DELIVER_TO_ADDRESS1,
                DELIVER_TO_ADDRESS2,
                DELIVER_TO_ADDRESS3,
                DELIVER_TO_ADDRESS4,
                DELIVER_TO_CITY,
                DELIVER_TO_STATE,
                DELIVER_TO_COUNTRY,
                DELIVER_TO_POSTAL_CODE,
                DELIVER_TO_CONTACT_ID,
                DELIVER_TO_CONTACT_NAME,
                DELIVER_TO_CONTACT_PHONE,
                FREIGHT_TERMS_CODE,
                FOB_CODE,
                TRANSACTION_TYPE_ID,
                PRICE_LIST_ID,
                CURRENCY_CODE,
                CLIENT_CODE,    -- LSP PROJECT
                INTERFACE_ACTION_CODE)
        Values(
                wsh_new_del_interface_s.nextval,
                'N',
                'OP',
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.LOGIN_ID,
                FND_GLOBAL.PROG_APPL_ID,
                FND_GLOBAL.Conc_Program_Id,
                sysdate,
                FND_GLOBAL.Conc_Request_Id,
                'I',
                p_shipment_request_info.organization_code,
                p_shipment_request_info.CARRIER_CODE,
                p_shipment_request_info.SERVICE_LEVEL,
                p_shipment_request_info.MODE_OF_TRANSPORT,
                p_shipment_request_info.customer_id,
                p_shipment_request_info.customer_name,
                p_shipment_request_info.ship_to_customer_id,
                p_shipment_request_info.ship_to_customer_name,
                p_shipment_request_info.ship_to_address_id,
                p_shipment_request_info.ship_to_address1,
                p_shipment_request_info.ship_to_address2,
                p_shipment_request_info.ship_to_address3,
                p_shipment_request_info.ship_to_address4,
                p_shipment_request_info.ship_to_city,
                p_shipment_request_info.ship_to_state,
                p_shipment_request_info.ship_to_country,
                p_shipment_request_info.ship_to_postal_code,
                p_shipment_request_info.ship_to_contact_id ,
                p_shipment_request_info.ship_to_contact_name,
                p_shipment_request_info.ship_to_contact_phone,
                p_shipment_request_info.invoice_to_customer_id,
                p_shipment_request_info.invoice_to_customer_name,
                p_shipment_request_info.invoice_to_address_id,
                p_shipment_request_info.invoice_to_address1,
                p_shipment_request_info.invoice_to_address2,
                p_shipment_request_info.invoice_to_address3,
                p_shipment_request_info.invoice_to_address4,
                p_shipment_request_info.invoice_to_city,
                p_shipment_request_info.invoice_to_state,
                p_shipment_request_info.invoice_to_country,
                p_shipment_request_info.invoice_to_postal_code,
                p_shipment_request_info.invoice_to_contact_id,
                p_shipment_request_info.invoice_to_contact_name,
                p_shipment_request_info.invoice_to_contact_phone,
                p_shipment_request_info.deliver_to_customer_id,
                p_shipment_request_info.deliver_to_customer_name,
                p_shipment_request_info.deliver_to_address_id,
                p_shipment_request_info.deliver_to_address1,
                p_shipment_request_info.deliver_to_address2,
                p_shipment_request_info.deliver_to_address3,
                p_shipment_request_info.deliver_to_address4,
                p_shipment_request_info.deliver_to_city,
                p_shipment_request_info.deliver_to_state,
                p_shipment_request_info.deliver_to_country,
                p_shipment_request_info.deliver_to_postal_code,
                p_shipment_request_info.deliver_to_contact_id,
                p_shipment_request_info.deliver_to_contact_name,
                p_shipment_request_info.deliver_to_contact_phone,
                p_shipment_request_info.freight_terms_code,
                p_shipment_request_info.fob_code,
                p_shipment_request_info.transaction_type_id,
                p_shipment_request_info.price_list_id,
                p_shipment_request_info.currency_code,
                p_shipment_request_info.client_code, -- LSP PROJECT
                '94X_STANDALONE'
                )
        RETURNING DELIVERY_INTERFACE_ID INTO p_shipment_request_info.delivery_interface_id;
        l_ins_rows := sql%rowcount;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Number of records inserted into WSH_NEW_DEL_INTERFACE',l_ins_rows);
            WSH_DEBUG_SV.log(l_module_name, 'Number of shipment details',p_shipment_request_info.shipment_details_tab.count);
        END IF;
    --}
    END IF;


    IF p_shipment_request_info.shipment_details_tab.count > 0 AND
       p_shipment_request_info.shipment_details_tab.count < 4 THEN
        --{
        IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Inserting into WSH_DEL_DETAILS_INTERFACE and WSH_DEL_ASSGN_INTERFACE');
        END IF;

        FOR i IN 1..p_shipment_request_info.shipment_details_tab.count LOOP
            --{
            INSERT INTO WSH_DEL_DETAILS_INTERFACE(
                    DELIVERY_DETAIL_INTERFACE_ID,
                    SOURCE_CODE,
                    SOURCE_LINE_ID,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    PROGRAM_APPLICATION_ID,
                    PROGRAM_ID,
                    PROGRAM_UPDATE_DATE,
                    REQUEST_ID,
                    CONTAINER_FLAG,
                    DATE_REQUESTED,
                    DATE_SCHEDULED,
                    INVENTORY_ITEM_ID,
                    ITEM_NUMBER,
                    CUSTOMER_ITEM_ID,
                    CUSTOMER_ITEM_NUMBER,
                    REQUESTED_QUANTITY,
                    REQUESTED_QUANTITY_UOM,
                    SRC_REQUESTED_QUANTITY,
                    SRC_REQUESTED_QUANTITY_UOM,
                    LINE_NUMBER,
                    SOURCE_LINE_NUMBER,
                    SOURCE_HEADER_NUMBER,
                    EARLIEST_PICKUP_DATE,
                    LATEST_PICKUP_DATE,
                    EARLIEST_DROPOFF_DATE,
                    LATEST_DROPOFF_DATE,
                    SHIP_TOLERANCE_ABOVE,
                    SHIP_TOLERANCE_BELOW,
                    SHIPPING_INSTRUCTIONS,
                    PACKING_INSTRUCTIONS,
                    SHIPMENT_PRIORITY_CODE,
                    CUST_PO_NUMBER,
                    SUBINVENTORY,
                    LOCATOR_ID,
                    LOCATOR_CODE,
                    LOT_NUMBER,
                    REVISION,
                    SHIP_SET_NAME,
                    UNIT_SELLING_PRICE,
                    LINE_DIRECTION,
                    INTERFACE_ACTION_CODE)
            VALUES(
                    wsh_del_details_interface_s.nextval,
                    'OE',
                    -1,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID,
                    FND_GLOBAL.PROG_APPL_ID,
                    FND_GLOBAL.Conc_Program_Id,
                    sysdate,
                    FND_GLOBAL.Conc_Request_Id,
                    'N',
                    p_shipment_request_info.shipment_details_tab(i).date_requested,
                    p_shipment_request_info.shipment_details_tab(i).date_scheduled,
                    p_shipment_request_info.shipment_details_tab(i).inventory_item_id,
                    p_shipment_request_info.shipment_details_tab(i).item_number,
                    p_shipment_request_info.shipment_details_tab(i).customer_item_id,
                    p_shipment_request_info.shipment_details_tab(i).customer_item_number,
                    p_shipment_request_info.shipment_details_tab(i).requested_quantity,
                    p_shipment_request_info.shipment_details_tab(i).requested_quantity_uom,
                    p_shipment_request_info.shipment_details_tab(i).src_requested_quantity,
                    p_shipment_request_info.shipment_details_tab(i).src_requested_quantity_uom,
                    p_shipment_request_info.shipment_details_tab(i).line_number,
                    p_shipment_request_info.shipment_details_tab(i).source_line_number,
                    p_shipment_request_info.shipment_details_tab(i).source_header_number,
                    p_shipment_request_info.shipment_details_tab(i).earliest_pickup_date,
                    p_shipment_request_info.shipment_details_tab(i).latest_pickup_date,
                    p_shipment_request_info.shipment_details_tab(i).earliest_dropoff_date,
                    p_shipment_request_info.shipment_details_tab(i).latest_dropoff_date,
                    p_shipment_request_info.shipment_details_tab(i).ship_tolerance_above,
                    p_shipment_request_info.shipment_details_tab(i).ship_tolerance_below,
                    p_shipment_request_info.shipment_details_tab(i).shipping_instructions,
                    p_shipment_request_info.shipment_details_tab(i).packing_instructions,
                    p_shipment_request_info.shipment_details_tab(i).shipment_priority_code,
                    p_shipment_request_info.shipment_details_tab(i).cust_po_number,
                    p_shipment_request_info.shipment_details_tab(i).subinventory,
                    p_shipment_request_info.shipment_details_tab(i).locator_id,
                    p_shipment_request_info.shipment_details_tab(i).locator_code,
                    p_shipment_request_info.shipment_details_tab(i).lot_number,
                    p_shipment_request_info.shipment_details_tab(i).revision,
                    p_shipment_request_info.shipment_details_tab(i).ship_set_name,
                    p_shipment_request_info.shipment_details_tab(i).unit_selling_price,
                    'O',
                    '94X_STANDALONE')
            RETURNING DELIVERY_DETAIL_INTERFACE_ID INTO p_shipment_request_info.shipment_details_tab(i).delivery_detail_interface_id;

            INSERT INTO WSH_DEL_ASSGN_INTERFACE(
                    DEL_ASSGN_INTERFACE_ID,
                    DELIVERY_DETAIL_INTERFACE_ID,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    PROGRAM_APPLICATION_ID,
                    PROGRAM_ID,
                    PROGRAM_UPDATE_DATE,
                    REQUEST_ID,
                    DELIVERY_INTERFACE_ID,
                    INTERFACE_ACTION_CODE
                    )
            VALUES(
                    wsh_del_assgn_interface_s.nextval,
                    p_shipment_request_info.shipment_details_tab(i).delivery_detail_interface_id,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID,
                    FND_GLOBAL.PROG_APPL_ID,
                    FND_GLOBAL.Conc_Program_Id,
                    sysdate,
                    FND_GLOBAL.Conc_Request_Id,
                    p_shipment_request_info.delivery_interface_id,
                    '94X_STANDALONE'
                    );

            IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name, 'Done Inserting into WSH_DEL_DETAILS_INTERFACE and WSH_DEL_ASSGN_INTERFACE'||p_shipment_request_info.shipment_details_tab(i).delivery_detail_interface_id);
            END IF;

            --}
        END LOOP;
        --}
    ELSIF p_shipment_request_info.shipment_details_tab.count > 0 THEN
        --{
        --Bug8784331
        FOR i IN  1..p_shipment_request_info.shipment_details_tab.count loop
               l_date_requested(i)               :=       p_shipment_request_info.shipment_details_tab(i).date_requested;
               l_date_scheduled(i)               :=       p_shipment_request_info.shipment_details_tab(i).date_scheduled;
               l_inventory_item_id(i)            :=       p_shipment_request_info.shipment_details_tab(i).inventory_item_id;
               l_item_number(i)                  :=       p_shipment_request_info.shipment_details_tab(i).item_number;
               l_customer_item_id(i)             :=       p_shipment_request_info.shipment_details_tab(i).customer_item_id;
               l_customer_item_number(i)         :=       p_shipment_request_info.shipment_details_tab(i).customer_item_number;
               l_requested_quantity(i)           :=       p_shipment_request_info.shipment_details_tab(i).requested_quantity;
               l_requested_quantity_uom(i)       :=       p_shipment_request_info.shipment_details_tab(i).requested_quantity_uom;
               l_src_requested_quantity(i)       :=       p_shipment_request_info.shipment_details_tab(i).src_requested_quantity;
               l_src_requested_quantity_uom(i)   :=       p_shipment_request_info.shipment_details_tab(i).src_requested_quantity_uom;
               l_line_number(i)                  :=       p_shipment_request_info.shipment_details_tab(i).line_number;
               l_source_line_number(i)           :=       p_shipment_request_info.shipment_details_tab(i).source_line_number;
               l_source_header_number(i)         :=       p_shipment_request_info.shipment_details_tab(i).source_header_number;
               l_earliest_pickup_date(i)         :=       p_shipment_request_info.shipment_details_tab(i).earliest_pickup_date;
               l_latest_pickup_date(i)           :=       p_shipment_request_info.shipment_details_tab(i).latest_pickup_date;
               l_earliest_dropoff_date(i)        :=       p_shipment_request_info.shipment_details_tab(i).earliest_dropoff_date;
               l_latest_dropoff_date(i)          :=       p_shipment_request_info.shipment_details_tab(i).latest_dropoff_date;
               l_ship_tolerance_above(i)         :=       p_shipment_request_info.shipment_details_tab(i).ship_tolerance_above;
               l_ship_tolerance_below(i)         :=       p_shipment_request_info.shipment_details_tab(i).ship_tolerance_below;
               l_shipping_instructions(i)        :=       p_shipment_request_info.shipment_details_tab(i).shipping_instructions;
               l_packing_instructions(i)         :=       p_shipment_request_info.shipment_details_tab(i).packing_instructions;
               l_shipment_priority_code(i)       :=       p_shipment_request_info.shipment_details_tab(i).shipment_priority_code;
               l_cust_po_number(i)               :=       p_shipment_request_info.shipment_details_tab(i).cust_po_number;
               l_subinventory(i)                 :=       p_shipment_request_info.shipment_details_tab(i).subinventory;
               l_locator_id(i)                   :=       p_shipment_request_info.shipment_details_tab(i).locator_id;
               l_locator_code(i)                 :=       p_shipment_request_info.shipment_details_tab(i).locator_code;
               l_lot_number(i)                   :=       p_shipment_request_info.shipment_details_tab(i).lot_number;
               l_revision(i)                     :=       p_shipment_request_info.shipment_details_tab(i).revision;
               l_ship_set_name(i)                :=       p_shipment_request_info.shipment_details_tab(i).ship_set_name;
               l_unit_selling_price(i)           :=       p_shipment_request_info.shipment_details_tab(i).unit_selling_price;
        END LOOP;
        --Bug8784331
        FORALL i IN  1..p_shipment_request_info.shipment_details_tab.count
        INSERT INTO WSH_DEL_DETAILS_INTERFACE(
                    DELIVERY_DETAIL_INTERFACE_ID,
                    SOURCE_CODE,
                    SOURCE_LINE_ID,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    PROGRAM_APPLICATION_ID,
                    PROGRAM_ID,
                    PROGRAM_UPDATE_DATE,
                    REQUEST_ID,
                    CONTAINER_FLAG,
                    DATE_REQUESTED,
                    DATE_SCHEDULED,
                    INVENTORY_ITEM_ID,
                    ITEM_NUMBER,
                    CUSTOMER_ITEM_ID,
                    CUSTOMER_ITEM_NUMBER,
                    REQUESTED_QUANTITY,
                    REQUESTED_QUANTITY_UOM,
                    SRC_REQUESTED_QUANTITY,
                    SRC_REQUESTED_QUANTITY_UOM,
                    LINE_NUMBER,
                    SOURCE_LINE_NUMBER,
                    SOURCE_HEADER_NUMBER,
                    EARLIEST_PICKUP_DATE,
                    LATEST_PICKUP_DATE,
                    EARLIEST_DROPOFF_DATE,
                    LATEST_DROPOFF_DATE,
                    SHIP_TOLERANCE_ABOVE,
                    SHIP_TOLERANCE_BELOW,
                    SHIPPING_INSTRUCTIONS,
                    PACKING_INSTRUCTIONS,
                    SHIPMENT_PRIORITY_CODE,
                    CUST_PO_NUMBER,
                    SUBINVENTORY,
                    LOCATOR_ID,
                    LOCATOR_CODE,
                    LOT_NUMBER,
                    REVISION,
                    SHIP_SET_NAME,
                    UNIT_SELLING_PRICE,
                    LINE_DIRECTION,
                    INTERFACE_ACTION_CODE)
            VALUES(
                    wsh_del_details_interface_s.nextval,
                    'OE',
                    -1,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID,
                    FND_GLOBAL.PROG_APPL_ID,
                    FND_GLOBAL.Conc_Program_Id,
                    sysdate,
                    FND_GLOBAL.Conc_Request_Id,
                    'N',
                    --Bug8784331
                    l_date_requested(i),
                    l_date_scheduled(i),
                    l_inventory_item_id(i),
                    l_item_number(i),
                    l_customer_item_id(i),
                    l_customer_item_number(i),
                    l_requested_quantity(i),
                    l_requested_quantity_uom(i),
                    l_src_requested_quantity(i),
                    l_src_requested_quantity_uom(i),
                    l_line_number(i),
                    l_source_line_number(i),
                    l_source_header_number(i),
                    l_earliest_pickup_date(i),
                    l_latest_pickup_date(i),
                    l_earliest_dropoff_date(i),
                    l_latest_dropoff_date(i),
                    l_ship_tolerance_above(i),
                    l_ship_tolerance_below(i),
                    l_shipping_instructions(i),
                    l_packing_instructions(i),
                    l_shipment_priority_code(i),
                    l_cust_po_number(i),
                    l_subinventory(i),
                    l_locator_id(i),
                    l_locator_code(i),
                    l_lot_number(i),
                    l_revision(i),
                    l_ship_set_name(i),
                    l_unit_selling_price(i),
                    --Bug8784331
                    'O',
                    '94X_STANDALONE')
            RETURNING DELIVERY_DETAIL_INTERFACE_ID BULK COLLECT INTO l_del_det_int_tab;
        l_ins_rows := sql%rowcount;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Number of records inserted into WSH_DEL_DETAILS_INTERFACE',l_ins_rows );
        END IF;

        FOR I IN 1..l_del_det_int_tab.Count LOOP
          p_shipment_request_info.shipment_details_tab(i).delivery_detail_interface_id := l_del_det_int_tab(i);
        END LOOP;
        FORALL i IN  1..p_shipment_request_info.shipment_details_tab.count
        INSERT INTO WSH_DEL_ASSGN_INTERFACE(
                    DEL_ASSGN_INTERFACE_ID,
                    DELIVERY_DETAIL_INTERFACE_ID,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    PROGRAM_APPLICATION_ID,
                    PROGRAM_ID,
                    PROGRAM_UPDATE_DATE,
                    REQUEST_ID,
                    DELIVERY_INTERFACE_ID,
                    INTERFACE_ACTION_CODE
                    )
            VALUES(
                    wsh_del_assgn_interface_s.nextval,
                    l_del_det_int_tab(i), --Bug8784331
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    sysdate,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID,
                    FND_GLOBAL.PROG_APPL_ID,
                    FND_GLOBAL.Conc_Program_Id,
                    sysdate,
                    FND_GLOBAL.Conc_Request_Id,
                    p_shipment_request_info.delivery_interface_id,
                    '94X_STANDALONE'
                    );
        l_ins_rows := sql%rowcount;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Number of records inserted into WSH_DEL_ASSGN_INTERFACE',l_ins_rows );
        END IF;
        --}
    END IF;--(if count >0)

    IF p_caller = 'SHIPMENT_REQUEST' THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Inserting into WSH_TRANSACTIONS_HISTORY' );
        END IF;
        INSERT INTO WSH_TRANSACTIONS_HISTORY(
                TRANSACTION_ID,
                DOCUMENT_TYPE,
                DOCUMENT_NUMBER,
                DOCUMENT_DIRECTION,
                TRANSACTION_STATUS,
                ACTION_TYPE,
                ENTITY_NUMBER,
                ENTITY_TYPE,
                TRADING_PARTNER_ID,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                REQUEST_ID,
                DOCUMENT_REVISION
                )
        VALUES (
                wsh_transaction_s.nextval,
                'SR',
                p_shipment_request_info.Document_Number,
                'I',
                'AP',
                p_shipment_request_info.ACTION_TYPE,
                p_shipment_request_info.delivery_interface_id,
                'DLVY_INT',
                -1,
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.LOGIN_ID,
                FND_GLOBAL.PROG_APPL_ID,
                FND_GLOBAL.Conc_Program_Id,
                sysdate,
                FND_GLOBAL.Conc_Request_Id,
                p_shipment_request_info.document_revision  )
        RETURNING TRANSACTION_ID INTO p_shipment_request_info.transaction_id;
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        p_shipment_request_info.delivery_interface_id := NULL;
        p_shipment_request_info.transaction_id := null;
        IF p_shipment_request_info.shipment_details_tab.count >0 THEN
            FOR i in 1..p_shipment_request_info.shipment_details_tab.count LOOP
                p_shipment_request_info.shipment_details_tab(i).delivery_detail_interface_id := NULL;
            END LOOP;
        END IF;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
        END IF;
        rollback;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Error occured while creating shipment request with document number and revision',p_shipment_request_info.document_number||' and '||p_shipment_request_info.document_revision);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;

    WHEN others THEN
        p_shipment_request_info.delivery_interface_id := NULL;
        p_shipment_request_info.transaction_id := null;
        IF p_shipment_request_info.shipment_details_tab.count >0 THEN
            FOR i in 1..p_shipment_request_info.shipment_details_tab.count LOOP
                p_shipment_request_info.shipment_details_tab(i).delivery_detail_interface_id := NULL;
            END LOOP;
        END IF;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
        END IF;
        rollback;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Create_Shipment_Request;
--========================================================================
-- PROCEDURE : Query_Shipment_Request  PRIVATE
--
-- PARAMETERS:
--	           p_shipment_request_info Attributes for the create shipment request
--             x_interface_errors_info Interface errors for WNDI and WDDI records
--             x_return_status         return status
--
-- COMMENT   : Queries records from WTH, WNDI, WDDI and WIE tables based on
--             document number and document revision passed.
--
--========================================================================
PROCEDURE Query_Shipment_Request(
                p_shipment_request_info  IN OUT NOCOPY Shipment_Request_Rec_Type,
                x_interface_errors_info  OUT NOCOPY Interface_Errors_Rec_Tab,
                x_return_status          OUT NOCOPY    VARCHAR2) AS


    CURSOR c_get_WIE_Rec IS
    SELECT p_shipment_request_info.document_number,p_shipment_request_info.document_revision,NULL,wie.error_message
      FROM WSH_INTERFACE_ERRORS WIE
     WHERE wie.interface_id = p_shipment_request_info.delivery_interface_id
       AND wie.interface_table_name = 'WSH_NEW_DEL_INTERFACE'
     UNION
    SELECT p_shipment_request_info.document_number,p_shipment_request_info.document_revision,wddi.line_number,wie.error_message
      FROM WSH_INTERFACE_ERRORS WIE,
           wsh_del_assgn_interface WDAI,
           WSH_DEL_DETAILS_INTERFACE WDDI
     WHERE wie.interface_table_name = 'WSH_DEL_DETAILS_INTERFACE'
       AND wie.interface_id = WDAI.delivery_detail_interface_id
       AND wddi.delivery_detail_interface_id = WDAI.delivery_detail_interface_id
       and WDAI.delivery_interface_id = p_shipment_request_info.delivery_interface_id;

    CURSOR c_get_WTH_WNDI_Rec IS
    SELECT WTH.transaction_id,
           WTH.action_type,
           WTH.document_number,
           WTH.document_revision,
           WNDI.delivery_interface_id,
           WNDI.organization_code,
           WNDI.customer_id,
           WNDI.customer_name,
           WNDI.ship_to_customer_id,
           WNDI.ship_to_customer_name,
           WNDI.ship_to_address_id,
           WNDI.ship_to_address1,
           WNDI.ship_to_address2,
           WNDI.ship_to_address3,
           WNDI.ship_to_address4,
           WNDI.ship_to_city,
           WNDI.ship_to_state,
           WNDI.ship_to_country,
           WNDI.ship_to_postal_code,
           WNDI.ship_to_contact_id,
           WNDI.ship_to_contact_name,
           WNDI.ship_to_contact_phone,
           WNDI.invoice_to_customer_id,
           WNDI.invoice_to_customer_name,
           WNDI.invoice_to_address_id,
           WNDI.invoice_to_address1,
           WNDI.invoice_to_address2,
           WNDI.invoice_to_address3,
           WNDI.invoice_to_address4,
           WNDI.invoice_to_city,
           WNDI.invoice_to_state,
           WNDI.invoice_to_country,
           WNDI.invoice_to_postal_code,
           WNDI.invoice_to_contact_id,
           WNDI.invoice_to_contact_name,
           WNDI.invoice_to_contact_phone,
           WNDI.deliver_to_customer_id,
           WNDI.deliver_to_customer_name,
           WNDI.deliver_to_address_id,
           WNDI.deliver_to_address1,
           WNDI.deliver_to_address2,
           WNDI.deliver_to_address3,
           WNDI.deliver_to_address4,
           WNDI.deliver_to_city,
           WNDI.deliver_to_state,
           WNDI.deliver_to_country,
           WNDI.deliver_to_postal_code,
           WNDI.deliver_to_contact_id,
           WNDI.deliver_to_contact_name,
           WNDI.deliver_to_contact_phone,
           WNDI.carrier_code,
           WNDI.service_level,
           WNDI.mode_of_transport,
           WNDI.freight_terms_code,
           WNDI.fob_code,
           WNDI.currency_code,
           WNDI.transaction_type_id,
           WNDI.price_list_id,
           WNDI.client_code  -- LSP PROJECT
      FROM WSH_TRANSACTIONS_HISTORY WTH,
           WSH_NEW_DEL_INTERFACE WNDI
     WHERE WTH.document_number   = to_char(p_shipment_request_info.document_number)
       AND WTH.document_revision = p_shipment_request_info.document_revision
       AND WTH.document_type ='SR'
       AND WTH.document_direction ='I'
       AND to_number(WTH.entity_number) = WNDI.delivery_interface_id
       AND WNDI.Interface_action_code = '94X_STANDALONE' ;

    CURSOR c_get_WDDI_Rec IS
    SELECT WDDI.delivery_detail_interface_id,
           WDDI.line_number,
           WDDI.item_number,
           WDDI.inventory_item_id,
           WDDI.item_description,
           WDDI.requested_quantity,
           WDDI.requested_quantity_uom,
           WDDI.customer_item_number,
           WDDI.customer_item_id,
           WDDI.date_requested,
           WDDI.date_scheduled,
           WDDI.ship_tolerance_above,
           WDDI.ship_tolerance_below,
           WDDI.packing_instructions,
           WDDI.shipping_instructions,
           WDDI.shipment_priority_code,
           WDDI.ship_set_name,
           WDDI.subinventory,
           WDDI.revision,
           WDDI.locator_code,
           WDDI.locator_id,
           WDDI.lot_number,
           WDDI.unit_selling_price,
           WDDI.currency_code,
           WDDI.earliest_pickup_date,
           WDDI.latest_pickup_date,
           WDDI.earliest_dropoff_date,
           WDDI.latest_dropoff_date,
           WDDI.cust_po_number,
           WDDI.source_header_number,
           WDDI.source_line_number,
           WDDI.src_requested_quantity,
           WDDI.src_requested_quantity_uom
      FROM WSH_DEL_DETAILS_INTERFACE WDDI ,
           WSH_DEL_ASSGN_INTERFACE WDAI
     WHERE WDDI.delivery_detail_interface_id = WDAI.delivery_detail_interface_id
       AND WDAI.delivery_interface_id = p_shipment_request_info.delivery_interface_id
       AND WDDI.Interface_action_code = '94X_STANDALONE';

    l_ins_rows                 NUMBER;

    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Query_Shipment_Request';

BEGIN
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name, 'Document Number',p_shipment_request_info.document_number);
        WSH_DEBUG_SV.log(l_module_name, 'Document Revision',p_shipment_request_info.document_revision);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    OPEN c_get_WTH_WNDI_Rec;
    FETCH c_get_WTH_WNDI_Rec INTO p_shipment_request_info.transaction_id,
                             p_shipment_request_info.action_type,
                             p_shipment_request_info.document_number,
                             p_shipment_request_info.document_revision,
                             p_shipment_request_info.delivery_interface_id,
                             p_shipment_request_info.organization_code,
                             p_shipment_request_info.customer_id,
                             p_shipment_request_info.customer_name,
                             p_shipment_request_info.ship_to_customer_id,
                             p_shipment_request_info.ship_to_customer_name,
                             p_shipment_request_info.ship_to_address_id,
                             p_shipment_request_info.ship_to_address1,
                             p_shipment_request_info.ship_to_address2,
                             p_shipment_request_info.ship_to_address3,
                             p_shipment_request_info.ship_to_address4,
                             p_shipment_request_info.ship_to_city,
                             p_shipment_request_info.ship_to_state,
                             p_shipment_request_info.ship_to_country,
                             p_shipment_request_info.ship_to_postal_code,
                             p_shipment_request_info.ship_to_contact_id,
                             p_shipment_request_info.ship_to_contact_name,
                             p_shipment_request_info.ship_to_contact_phone,
                             p_shipment_request_info.invoice_to_customer_id,
                             p_shipment_request_info.invoice_to_customer_name,
                             p_shipment_request_info.invoice_to_address_id,
                             p_shipment_request_info.invoice_to_address1,
                             p_shipment_request_info.invoice_to_address2,
                             p_shipment_request_info.invoice_to_address3,
                             p_shipment_request_info.invoice_to_address4,
                             p_shipment_request_info.invoice_to_city,
                             p_shipment_request_info.invoice_to_state,
                             p_shipment_request_info.invoice_to_country,
                             p_shipment_request_info.invoice_to_postal_code,
                             p_shipment_request_info.invoice_to_contact_id,
                             p_shipment_request_info.invoice_to_contact_name,
                             p_shipment_request_info.invoice_to_contact_phone,
                             p_shipment_request_info.deliver_to_customer_id,
                             p_shipment_request_info.deliver_to_customer_name,
                             p_shipment_request_info.deliver_to_address_id,
                             p_shipment_request_info.deliver_to_address1,
                             p_shipment_request_info.deliver_to_address2,
                             p_shipment_request_info.deliver_to_address3,
                             p_shipment_request_info.deliver_to_address4,
                             p_shipment_request_info.deliver_to_city,
                             p_shipment_request_info.deliver_to_state,
                             p_shipment_request_info.deliver_to_country,
                             p_shipment_request_info.deliver_to_postal_code,
                             p_shipment_request_info.deliver_to_contact_id,
                             p_shipment_request_info.deliver_to_contact_name,
                             p_shipment_request_info.deliver_to_contact_phone,
                             p_shipment_request_info.carrier_code,
                             p_shipment_request_info.service_level,
                             p_shipment_request_info.mode_of_transport,
                             p_shipment_request_info.freight_terms_code,
                             p_shipment_request_info.fob_code,
                             p_shipment_request_info.currency_code,
                             p_shipment_request_info.transaction_type_id,
                             p_shipment_request_info.price_list_id,
                             p_shipment_request_info.client_code; -- LSP PROJECT

    IF c_get_WTH_WNDI_Rec%NOTFOUND THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        fnd_message.set_name('WSH', 'WSH_STND_INVALID_DOC');
        fnd_message.set_token('DOCUMENT_NUMBER', p_shipment_request_info.document_number);
        fnd_message.set_token('DOCUMENT_REVISION', p_shipment_request_info.document_revision);
        wsh_util_core.add_message(x_return_status);

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'No Data found');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_ins_rows := sql%rowcount;
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Number of records returned from WTH and WNDI',l_ins_rows);
    END IF;
    CLOSE c_get_WTH_WNDI_Rec;


    OPEN c_get_WDDI_Rec;
    FETCH c_get_WDDI_Rec BULK COLLECT INTO p_shipment_request_info.shipment_details_tab;
    CLOSE c_get_WDDI_Rec;
    l_ins_rows := sql%rowcount;
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Number of records returned from WDDI',l_ins_rows);
    END IF;

    OPEN c_get_WIE_Rec;
    FETCH c_get_WIE_Rec BULK COLLECT INTO x_interface_errors_info ;
    CLOSE c_get_WIE_Rec;
    l_ins_rows := sql%rowcount;
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Number of records returned from WIE',l_ins_rows);
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        p_shipment_request_info.delivery_interface_id := NULL;
        p_shipment_request_info.transaction_id := null;
        IF p_shipment_request_info.shipment_details_tab.count >0 THEN
            FOR i in 1..p_shipment_request_info.shipment_details_tab.count LOOP
                p_shipment_request_info.shipment_details_tab(i).delivery_detail_interface_id := NULL;
            END LOOP;
        END IF;
        IF c_get_WTH_WNDI_Rec%ISOPEN THEN
            CLOSE c_get_WTH_WNDI_Rec;
        END IF;
        IF c_get_WIE_Rec%ISOPEN THEN
            CLOSE c_get_WIE_Rec;
        END IF;
        IF c_get_WDDI_Rec%ISOPEN THEN
            CLOSE c_get_WDDI_Rec;
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Error occured while querying shipment request with document number and revision',p_shipment_request_info.document_number||' and '||p_shipment_request_info.document_revision);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;

    WHEN others THEN
        IF c_get_WTH_WNDI_Rec%ISOPEN THEN
            CLOSE c_get_WTH_WNDI_Rec;
        END IF;
        IF c_get_WIE_Rec%ISOPEN THEN
            CLOSE c_get_WIE_Rec;
        END IF;
        IF c_get_WDDI_Rec%ISOPEN THEN
            CLOSE c_get_WDDI_Rec;
        END IF;
        p_shipment_request_info.delivery_interface_id := NULL;
        p_shipment_request_info.transaction_id := null;
        IF p_shipment_request_info.shipment_details_tab.count >0 THEN
            FOR i in 1..p_shipment_request_info.shipment_details_tab.count LOOP
                p_shipment_request_info.shipment_details_tab(i).delivery_detail_interface_id := NULL;
            END LOOP;
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Query_Shipment_Request;
--========================================================================
-- PROCEDURE : Update_Delete_Shipment_Request  PRIVATE
--
-- PARAMETERS:
--             p_action_code           UPDATE or DELETE
--	           p_shipment_request_info Attributes for the create shipment request
--             x_return_status         return status
--
-- COMMENT   : Queries records from WTH, WNDI, WDDI and WIE tables based on
--             document number and document revision passed.
--
--========================================================================
PROCEDURE Update_Delete_Shipment_Request(
                p_action_code            IN   VARCHAR2 ,
                p_shipment_request_info  IN OUT NOCOPY Shipment_Request_Rec_Type,
                x_return_status          OUT NOCOPY    VARCHAR2) AS

    CURSOR c_get_Details_DN IS
    SELECT wth.document_number,wth.document_revision,wndi.delivery_interface_id,wth.transaction_id
      FROM WSH_TRANSACTIONS_HISTORY WTH,
           WSH_NEW_DEL_INTERFACE WNDI,
           wsh_interface_errors   wie
     WHERE WTH.document_number   = to_char(p_shipment_request_info.document_number)
       and WTH.document_revision = p_shipment_request_info.document_revision
       and wth.document_type = 'SR'
       and wth.document_direction = 'I'
       and wie.interface_id(+) =  WNDI.delivery_interface_id
       and wie.interface_table_name(+) = 'WSH_NEW_DEL_INTERFACE'
       and to_number(WTH.entity_number) = WNDI.delivery_interface_id
       AND WNDI.Interface_action_code = '94X_STANDALONE'
       FOR UPDATE OF wth.transaction_id, wndi.delivery_interface_id ,wie.interface_id NOWAIT;

    CURSOR c_get_all_del_det_interface_id IS
    SELECT wdai.delivery_detail_interface_id
      FROM WSH_DEL_ASSGN_INTERFACE wdai,
           wsh_del_details_interface wddi,
           wsh_interface_errors   wie
     WHERE wdai.delivery_interface_id = p_shipment_request_info.delivery_interface_id
       and wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
       and wie.interface_id(+) = wdai.delivery_detail_interface_id
       and wie.interface_table_name(+) = 'WSH_DEL_DETAILS_INTERFACE'
       FOR UPDATE OF WDAI.delivery_detail_interface_id, wddi.delivery_detail_interface_id,wie.interface_id NOWAIT;

    CURSOR c_get_del_det_interface_id(c_line_number VARCHAR2) IS
    SELECT wdai.delivery_detail_interface_id
      FROM wsh_del_details_interface wddi,
           wsh_del_assgn_interface wdai,
           wsh_interface_errors   wie
     WHERE wddi.delivery_detail_interface_id = wdai.delivery_detail_interface_id
       AND wdai.delivery_interface_id= p_shipment_request_info.delivery_interface_id
       AND wddi.line_number = c_line_number
       and wie.interface_id(+) = wdai.delivery_detail_interface_id
       and wie.interface_table_name(+) = 'WSH_DEL_DETAILS_INTERFACE'
       FOR UPDATE OF WDAI.delivery_detail_interface_id, wddi.delivery_detail_interface_id,wie.interface_id NOWAIT;

    CURSOR C_OPEN_DEL_DET IS
    SELECT Count(*)
      from wsh_del_assgn_interface wdai
     where wdai.delivery_interface_id= p_shipment_request_info.delivery_interface_id;

    --
    l_delivery_interface_id          WSH_NEW_DEL_INTERFACE.delivery_interface_id%TYPE;
    l_transaction_id                 WSH_TRANSACTIONS_HISTORY.Transaction_Id%TYPE;
    l_del_det_int_tab wsh_util_core.id_tab_type;
    l_document_number                WSH_TRANSACTIONS_HISTORY.document_number%TYPE;
    l_document_revision              WSH_TRANSACTIONS_HISTORY.document_revision%TYPE;
    l_count                          NUMBER;
    l_ins_rows                       NUMBER;
    l_ins_count                      NUMBER :=1;
    l_upd_count                      NUMBER :=1;
    l_return_status                  VARCHAR2(100);
    l_tmp_status                     VARCHAR2(1);
    --
    l_insert_sr_info                 Shipment_Request_Rec_Type;
    l_update_sr_info                 Shipment_Request_Rec_Type;
    --
    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Update_Delete_Shipment_Request';
    --

    --
    RECORD_LOCKED                   EXCEPTION;
    PRAGMA EXCEPTION_INIT(record_locked, -54);
    --
    --Bug8784331
    l_date_requested             wsh_util_core.Date_Tab_Type;
    l_date_scheduled             wsh_util_core.Date_Tab_Type;
    l_inventory_item_id          wsh_util_core.Id_Tab_Type;
    l_item_number                wsh_util_core.tbl_varchar;
    l_customer_item_id           wsh_util_core.Id_Tab_Type;
    l_customer_item_number       wsh_util_core.tbl_varchar;
    l_requested_quantity         wsh_util_core.Id_Tab_Type;
    l_requested_quantity_uom     wsh_util_core.tbl_varchar;
    l_src_requested_quantity     wsh_util_core.Id_Tab_Type;
    l_src_requested_quantity_uom wsh_util_core.tbl_varchar;
    l_line_number                wsh_util_core.Id_Tab_Type;
    l_source_line_number         wsh_util_core.tbl_varchar;
    l_source_header_number       wsh_util_core.tbl_varchar;
    l_earliest_pickup_date       wsh_util_core.Date_Tab_Type;
    l_latest_pickup_date         wsh_util_core.Date_Tab_Type;
    l_earliest_dropoff_date      wsh_util_core.Date_Tab_Type;
    l_latest_dropoff_date        wsh_util_core.Date_Tab_Type;
    l_ship_tolerance_above       wsh_util_core.Id_Tab_Type;
    l_ship_tolerance_below       wsh_util_core.Id_Tab_Type;
    l_shipping_instructions      wsh_util_core.tbl_varchar;
    l_packing_instructions       wsh_util_core.tbl_varchar;
    l_shipment_priority_code     wsh_util_core.tbl_varchar;
    l_cust_po_number             wsh_util_core.tbl_varchar;
    l_subinventory               wsh_util_core.tbl_varchar;
    l_locator_id                 wsh_util_core.Id_Tab_Type;
    l_locator_code               wsh_util_core.tbl_varchar;
    l_lot_number                 wsh_util_core.tbl_varchar;
    l_revision                   wsh_util_core.tbl_varchar;
    l_ship_set_name              wsh_util_core.tbl_varchar;
    l_unit_selling_price         wsh_util_core.Id_Tab_Type;
    l_delivery_detail_interface_id   wsh_util_core.Id_Tab_Type;
    --Bug8784331


BEGIN

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'p_action_code',p_action_code);
        WSH_DEBUG_SV.log(l_module_name,'WDDI count',p_shipment_request_info.shipment_details_tab.count);
    END IF;


    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    l_tmp_status    := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
       wsh_debug_sv.logmsg(l_module_name, 'Taking locks on WTH,WNDI');
    END IF;

    OPEN c_get_Details_DN;
    FETCH c_get_Details_DN INTO l_document_number,l_document_revision,l_delivery_interface_id,l_transaction_id;
    IF c_get_Details_DN%NOTFOUND THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        fnd_message.set_name('WSH', 'WSH_STND_INVALID_DOC');
        fnd_message.set_token('DOCUMENT_NUMBER', p_shipment_request_info.document_number);
        fnd_message.set_token('DOCUMENT_REVISION', p_shipment_request_info.document_revision);
        wsh_util_core.add_message(x_return_status);
        IF l_debug_on THEN
           wsh_debug_sv.logmsg(l_module_name, 'Invalid parameters have been passed');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_get_Details_DN;

    p_shipment_request_info.delivery_interface_id := l_delivery_interface_id;

    IF p_shipment_request_info.shipment_details_tab.count > 0 THEN
        l_insert_sr_info.document_number       := p_shipment_request_info.document_number;
        l_insert_sr_info.document_revision     := p_shipment_request_info.document_revision;
        l_insert_sr_info.delivery_interface_id := p_shipment_request_info.delivery_interface_id;

        l_ins_count := 1;
        l_upd_count := 1;

        FOR i in 1..p_shipment_request_info.shipment_details_tab.count LOOP

           IF p_shipment_request_info.shipment_details_tab(i).line_number IS NULL THEN

                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                fnd_message.set_name('WSH', 'WSH_STND_ATTR_MANDATORY');
                fnd_message.set_token('ATTRIBUTE','LINE_NUMBER');
                wsh_util_core.add_message(x_return_status);
                IF l_debug_on THEN
                   wsh_debug_sv.logmsg(l_module_name, 'Line number is a mandatory parameter for delivery_detail_interface records');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF l_debug_on THEN
               wsh_debug_sv.logmsg(l_module_name, 'Taking locks on WDDI and WDAI for line number :'||p_shipment_request_info.shipment_details_tab(i).line_number);
            END IF;
            OPEN c_get_del_det_interface_id(p_shipment_request_info.shipment_details_tab(i).line_number);
            FETCH c_get_del_det_interface_id INTO l_del_det_int_tab(i);
            IF c_get_del_det_interface_id%NOTFOUND THEN
                IF p_action_code = 'UPDATE' THEN
                    --
                    IF l_debug_on THEN
                       wsh_debug_sv.logmsg(l_module_name, 'line number ' || p_shipment_request_info.shipment_details_tab(i).line_number || ' does not exist, so insert into WDDI');
                    END IF;
                    --
                    l_insert_sr_info.shipment_details_tab(l_ins_count):= p_shipment_request_info.shipment_details_tab(i);
                    l_ins_count := l_ins_count + 1;
                ELSE
                    --
                    IF l_debug_on THEN
                       wsh_debug_sv.logmsg(l_module_name, 'Error: Line number ' || p_shipment_request_info.shipment_details_tab(i).line_number || ' does not exist');
                    END IF;
                    --
                    l_tmp_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    fnd_message.set_name('WSH', 'WSH_STND_INVALID_DOC_LINE');
                    fnd_message.set_token('LINE_NUMBER', p_shipment_request_info.shipment_details_tab(i).line_number);
                    wsh_util_core.add_message(l_tmp_status);
                END IF;
            ELSE
                l_update_sr_info.shipment_details_tab(l_upd_count):= p_shipment_request_info.shipment_details_tab(i);
                l_upd_count :=l_upd_count + 1;
            END IF;
            CLOSE c_get_del_det_interface_id;
        END LOOP;
    ELSE
        IF p_action_code ='DELETE' THEN

            IF l_debug_on THEN
               wsh_debug_sv.logmsg(l_module_name, 'Taking locks on WDDI and WDAI');
            END IF;

            OPEN c_get_all_del_det_interface_id;
            FETCH c_get_all_del_det_interface_id BULK COLLECT INTO l_del_det_int_tab;
            CLOSE c_get_all_del_det_interface_id;
        END IF;
    END IF;

    IF l_tmp_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name, 'Successfully locked records of WTH,WNDI and WDDI');
    END IF;

    IF p_action_code ='UPDATE' THEN
        --{
        IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Updating WSH_NEW_DEL_INTERFACE');
        END IF;
        UPDATE WSH_NEW_DEL_INTERFACE
           SET last_update_date         = sysdate,
               last_updated_by          = FND_GLOBAL.USER_ID,
               last_update_login        = FND_GLOBAL.Login_Id,
               program_application_id   = FND_GLOBAL.Prog_Appl_Id,
               program_id               = FND_GLOBAL.Conc_Program_Id,
               program_update_date      = sysdate,
               request_id               = FND_GLOBAL.Conc_Request_Id,
               organization_code        = p_shipment_request_info.organization_code,
               carrier_code             = p_shipment_request_info.carrier_code,
               service_level            = p_shipment_request_info.service_level,
               mode_of_transport        = p_shipment_request_info.mode_of_transport,
               customer_id              = p_shipment_request_info.customer_id,
               customer_name            = p_shipment_request_info.customer_name,
               ship_to_customer_id      = p_shipment_request_info.ship_to_customer_id,
               ship_to_customer_name    = p_shipment_request_info.ship_to_customer_name,
               ship_to_address_id       = p_shipment_request_info.ship_to_address_id,
               ship_to_address1         = p_shipment_request_info.ship_to_address1,
               ship_to_address2         = p_shipment_request_info.ship_to_address2,
               ship_to_address3         = p_shipment_request_info.ship_to_address3,
               ship_to_address4         = p_shipment_request_info.ship_to_address4,
               ship_to_city             = p_shipment_request_info.ship_to_city,
               ship_to_state            = p_shipment_request_info.ship_to_state,
               ship_to_country          = p_shipment_request_info.ship_to_country,
               ship_to_postal_code      = p_shipment_request_info.ship_to_postal_code,
               ship_to_contact_id       = p_shipment_request_info.ship_to_contact_id ,
               ship_to_contact_name     = p_shipment_request_info.ship_to_contact_name,
               ship_to_contact_phone    = p_shipment_request_info.ship_to_contact_phone,
               invoice_to_customer_id   = p_shipment_request_info.invoice_to_customer_id,
               invoice_to_customer_name = p_shipment_request_info.invoice_to_customer_name,
               invoice_to_address_id    = p_shipment_request_info.invoice_to_address_id,
               invoice_to_address1      = p_shipment_request_info.invoice_to_address1,
               invoice_to_address2      = p_shipment_request_info.invoice_to_address2,
               invoice_to_address3      = p_shipment_request_info.invoice_to_address3,
               invoice_to_address4      = p_shipment_request_info.invoice_to_address4,
               invoice_to_city          = p_shipment_request_info.invoice_to_city,
               invoice_to_state         = p_shipment_request_info.invoice_to_state,
               invoice_to_country       = p_shipment_request_info.invoice_to_country,
               invoice_to_postal_code   = p_shipment_request_info.invoice_to_postal_code,
               invoice_to_contact_id    = p_shipment_request_info.invoice_to_contact_id,
               invoice_to_contact_name  = p_shipment_request_info.invoice_to_contact_name,
               invoice_to_contact_phone = p_shipment_request_info.invoice_to_contact_phone,
               deliver_to_customer_id   = p_shipment_request_info.deliver_to_customer_id,
               deliver_to_customer_name = p_shipment_request_info.deliver_to_customer_name,
               deliver_to_address_id    = p_shipment_request_info.deliver_to_address_id,
               deliver_to_address1      = p_shipment_request_info.deliver_to_address1,
               deliver_to_address2      = p_shipment_request_info.deliver_to_address2,
               deliver_to_address3      = p_shipment_request_info.deliver_to_address3,
               deliver_to_address4      = p_shipment_request_info.deliver_to_address4,
               deliver_to_city          = p_shipment_request_info.deliver_to_city,
               deliver_to_state         = p_shipment_request_info.deliver_to_state,
               deliver_to_country       = p_shipment_request_info.deliver_to_country,
               deliver_to_postal_code   = p_shipment_request_info.deliver_to_postal_code,
               deliver_to_contact_id    = p_shipment_request_info.deliver_to_contact_id,
               deliver_to_contact_name  = p_shipment_request_info.deliver_to_contact_name,
               deliver_to_contact_phone = p_shipment_request_info.deliver_to_contact_phone,
               freight_terms_code       = p_shipment_request_info.freight_terms_code,
               fob_code                 = p_shipment_request_info.fob_code,
               transaction_type_id      = p_shipment_request_info.transaction_type_id,
               price_list_id            = p_shipment_request_info.price_list_id,
               currency_code            = p_shipment_request_info.currency_code,
               client_code              = p_shipment_request_info.client_code  -- LSP PROJECT
         WHERE delivery_interface_id    = l_delivery_interface_id;

        l_ins_rows := sql%rowcount;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'WNDI : Number of records updated',l_ins_rows);
        END IF;

        IF l_update_sr_info.shipment_details_tab.count > 0 AND
           l_update_sr_info.shipment_details_tab.count < 4 THEN
            --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Updating in non-bulk mode', l_update_sr_info.shipment_details_tab.count);
            END IF;
            --
            FOR i in 1..l_update_sr_info.shipment_details_tab.count LOOP
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'updating delivery_detail_interface_id',l_update_sr_info.shipment_details_tab(i).delivery_detail_interface_id );
                END IF;
                --
                UPDATE WSH_DEL_DETAILS_INTERFACE
                   SET last_update_date             = sysdate,
                       last_updated_by              = FND_GLOBAL.USER_ID,
                       last_update_login            = FND_GLOBAL.Login_Id,
                       program_application_id       = FND_GLOBAL.Prog_Appl_Id,
                       program_id                   = FND_GLOBAL.Conc_Program_Id,
                       program_update_date          = sysdate,
                       request_id                   = FND_GLOBAL.Conc_Request_Id,
                       date_requested               = l_update_sr_info.shipment_details_tab(i).date_requested,
                       date_scheduled               = l_update_sr_info.shipment_details_tab(i).date_scheduled,
                       inventory_item_id            = l_update_sr_info.shipment_details_tab(i).inventory_item_id,
                       item_number                  = l_update_sr_info.shipment_details_tab(i).item_number,
                       customer_item_id             = l_update_sr_info.shipment_details_tab(i).customer_item_id,
                       customer_item_number         = l_update_sr_info.shipment_details_tab(i).customer_item_number,
                       requested_quantity           = l_update_sr_info.shipment_details_tab(i).requested_quantity,
                       requested_quantity_uom       = l_update_sr_info.shipment_details_tab(i).requested_quantity_uom,
                       src_requested_quantity       = l_update_sr_info.shipment_details_tab(i).src_requested_quantity,
                       src_requested_quantity_uom   = l_update_sr_info.shipment_details_tab(i).src_requested_quantity_uom,
                       line_number                  = l_update_sr_info.shipment_details_tab(i).line_number,
                       source_line_number           = l_update_sr_info.shipment_details_tab(i).source_line_number,
                       earliest_pickup_date         = l_update_sr_info.shipment_details_tab(i).earliest_pickup_date,
                       latest_pickup_date           = l_update_sr_info.shipment_details_tab(i).latest_pickup_date,
                       earliest_dropoff_date        = l_update_sr_info.shipment_details_tab(i).earliest_dropoff_date,
                       latest_dropoff_date          = l_update_sr_info.shipment_details_tab(i).latest_dropoff_date,
                       ship_tolerance_above         = l_update_sr_info.shipment_details_tab(i).ship_tolerance_above,
                       ship_tolerance_below         = l_update_sr_info.shipment_details_tab(i).ship_tolerance_below,
                       shipping_instructions        = l_update_sr_info.shipment_details_tab(i).shipping_instructions,
                       packing_instructions         = l_update_sr_info.shipment_details_tab(i).packing_instructions,
                       shipment_priority_code       = l_update_sr_info.shipment_details_tab(i).shipment_priority_code,
                       cust_po_number               = l_update_sr_info.shipment_details_tab(i).cust_po_number,
                       subinventory                 = l_update_sr_info.shipment_details_tab(i).subinventory,
                       locator_id                   = l_update_sr_info.shipment_details_tab(i).locator_id,
                       locator_code                 = l_update_sr_info.shipment_details_tab(i).locator_code,
                       lot_number                   = l_update_sr_info.shipment_details_tab(i).lot_number,
                       revision                     = l_update_sr_info.shipment_details_tab(i).revision,
                       ship_set_name                = l_update_sr_info.shipment_details_tab(i).ship_set_name,
                       unit_selling_price           = l_update_sr_info.shipment_details_tab(i).unit_selling_price
                 WHERE delivery_detail_interface_id = l_update_sr_info.shipment_details_tab(i).delivery_detail_interface_id;
            END LOOP;
            --}
        ELSIF l_update_sr_info.shipment_details_tab.count > 0 THEN
            --{
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Updating in bulk mode', l_update_sr_info.shipment_details_tab.count);
            END IF;
            --
            --Bug8784331
            FOR i in 1..l_update_sr_info.shipment_details_tab.count LOOP
                  l_date_requested(i)              := l_update_sr_info.shipment_details_tab(i).date_requested;
                  l_date_scheduled(i)              := l_update_sr_info.shipment_details_tab(i).date_scheduled;
                  l_inventory_item_id(i)           := l_update_sr_info.shipment_details_tab(i).inventory_item_id;
                  l_item_number(i)                 := l_update_sr_info.shipment_details_tab(i).item_number;
                  l_customer_item_id(i)            := l_update_sr_info.shipment_details_tab(i).customer_item_id;
                  l_customer_item_number(i)        := l_update_sr_info.shipment_details_tab(i).customer_item_number;
                  l_requested_quantity(i)          := l_update_sr_info.shipment_details_tab(i).requested_quantity;
                  l_requested_quantity_uom(i)      := l_update_sr_info.shipment_details_tab(i).requested_quantity_uom;
                  l_src_requested_quantity(i)      := l_update_sr_info.shipment_details_tab(i).src_requested_quantity;
                  l_src_requested_quantity_uom(i)  := l_update_sr_info.shipment_details_tab(i).src_requested_quantity_uom;
                  l_line_number(i)                 := l_update_sr_info.shipment_details_tab(i).line_number;
                  l_source_line_number(i)          := l_update_sr_info.shipment_details_tab(i).source_line_number;
                  l_earliest_pickup_date(i)        := l_update_sr_info.shipment_details_tab(i).earliest_pickup_date;
                  l_latest_pickup_date(i)          := l_update_sr_info.shipment_details_tab(i).latest_pickup_date;
                  l_earliest_dropoff_date(i)       := l_update_sr_info.shipment_details_tab(i).earliest_dropoff_date;
                  l_latest_dropoff_date(i)         := l_update_sr_info.shipment_details_tab(i).latest_dropoff_date;
                  l_ship_tolerance_above(i)        := l_update_sr_info.shipment_details_tab(i).ship_tolerance_above;
                  l_ship_tolerance_below(i)        := l_update_sr_info.shipment_details_tab(i).ship_tolerance_below;
                  l_shipping_instructions(i)       := l_update_sr_info.shipment_details_tab(i).shipping_instructions         ;
                  l_packing_instructions(i)        := l_update_sr_info.shipment_details_tab(i).packing_instructions;
                  l_shipment_priority_code(i)      := l_update_sr_info.shipment_details_tab(i).shipment_priority_code;
                  l_cust_po_number(i)              := l_update_sr_info.shipment_details_tab(i).cust_po_number;
                  l_subinventory(i)                := l_update_sr_info.shipment_details_tab(i).subinventory;
                  l_locator_id(i)                  := l_update_sr_info.shipment_details_tab(i).locator_id;
                  l_locator_code(i)                := l_update_sr_info.shipment_details_tab(i).locator_code;
                  l_lot_number(i)                  := l_update_sr_info.shipment_details_tab(i).lot_number;
                  l_revision(i)                    := l_update_sr_info.shipment_details_tab(i).revision;
                  l_ship_set_name(i)               := l_update_sr_info.shipment_details_tab(i).ship_set_name;
                  l_unit_selling_price(i)          := l_update_sr_info.shipment_details_tab(i).unit_selling_price;
                  l_delivery_detail_interface_id(i):= l_update_sr_info.shipment_details_tab(i).delivery_detail_interface_id;
            END LOOP;
            --Bug8784331
            FORALL i in 1..l_update_sr_info.shipment_details_tab.count
                UPDATE WSH_DEL_DETAILS_INTERFACE
                   SET last_update_date             = sysdate,
                       last_updated_by              = FND_GLOBAL.USER_ID,
                       last_update_login            = FND_GLOBAL.Login_Id,
                       program_application_id       = FND_GLOBAL.Prog_Appl_Id,
                       program_id                   = FND_GLOBAL.Conc_Program_Id,
                       program_update_date          = sysdate,
                       request_id                   = FND_GLOBAL.Conc_Request_Id,
                       --Bug8784331
                       date_requested               = l_date_requested(i),
                       date_scheduled               = l_date_scheduled(i) ,
                       inventory_item_id            = l_inventory_item_id(i),
                       item_number                  = l_item_number(i),
                       customer_item_id             = l_customer_item_id(i),
                       customer_item_number         = l_customer_item_number(i),
                       requested_quantity           = l_requested_quantity(i),
                       requested_quantity_uom       = l_requested_quantity_uom(i),
                       src_requested_quantity       = l_src_requested_quantity(i) ,
                       src_requested_quantity_uom   = l_src_requested_quantity_uom(i),
                       line_number                  = l_line_number(i),
                       source_line_number           = l_source_line_number(i),
                       earliest_pickup_date         = l_earliest_pickup_date(i),
                       latest_pickup_date           = l_latest_pickup_date(i),
                       earliest_dropoff_date        = l_earliest_dropoff_date(i),
                       latest_dropoff_date          = l_latest_dropoff_date(i),
                       ship_tolerance_above         = l_ship_tolerance_above(i)         ,
                       ship_tolerance_below         = l_ship_tolerance_below(i),
                       shipping_instructions        = l_shipping_instructions(i)        ,
                       packing_instructions         = l_packing_instructions(i),
                       shipment_priority_code       = l_shipment_priority_code(i),
                       cust_po_number               = l_cust_po_number(i),
                       subinventory                 = l_subinventory(i),
                       locator_id                   = l_locator_id(i),
                       locator_code                 = l_locator_code(i),
                       lot_number                   = l_lot_number(i),
                       revision                     = l_revision(i),
                       ship_set_name                = l_ship_set_name(i),
                       unit_selling_price           = l_unit_selling_price(i)
                 WHERE delivery_detail_interface_id = l_delivery_detail_interface_id(i) ;
                 --Bug8784331
            --}
        END IF;

        IF l_insert_sr_info.shipment_details_tab.count > 0 THEN
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Create_Shipment_Request with UPDATE', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            Create_Shipment_Request(p_shipment_request_info => l_insert_sr_info,
                                    p_caller                => 'UPDATE',
                                    x_return_status         => l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'The Action of inserting new del detail interface lines failed');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'The Action of inserting new del detail interface lines is successful');
            END IF;
        END IF;
        --}
    ELSE
        --{
        IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Deleting records from WTH,WDDI,WDAI,WNDI');
        END IF;
    ---------
        IF l_del_det_int_tab.count > 0 AND l_del_det_int_tab.count < 4 THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Deleting in non-bulk mode', l_del_det_int_tab.count);
            END IF;
            --
            FOR i in 1..l_del_det_int_tab.count LOOP
                delete from wsh_del_assgn_interface
                 where delivery_detail_interface_id = l_del_det_int_tab(i);
                l_ins_rows := sql%rowcount;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,i||' WDAI : Number of records Deleted',l_ins_rows);
                END IF;


                delete from WSH_DEL_DETAILS_INTERFACE
                 where delivery_detail_interface_id = l_del_det_int_tab(i);
                l_ins_rows := sql%rowcount;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,i||' WDDI : Number of records Deleted',l_ins_rows);
                END IF;

                delete from WSH_INTERFACE_ERRORS
                 where interface_id = l_del_det_int_tab(i)
                   and interface_table_name = 'WSH_DEL_DETAILS_INTERFACE';
                l_ins_rows := sql%rowcount;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,i||' WIE : Number of records Deleted',l_ins_rows);
                END IF;

            END LOOP;

        ELSIF l_del_det_int_tab.count > 0 THEN
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Deleting in bulk mode', l_del_det_int_tab.count);
            END IF;
            --
            FORALL i in 1..l_del_det_int_tab.count
                delete from wsh_del_assgn_interface
                 where delivery_detail_interface_id = l_del_det_int_tab(i);

            l_ins_rows := sql%rowcount;
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'WDAI : Number of records Deleted',l_ins_rows);
            END IF;

            FORALL i in 1..l_del_det_int_tab.count
                delete from WSH_DEL_DETAILS_INTERFACE
                 where delivery_detail_interface_id = l_del_det_int_tab(i);

            l_ins_rows := sql%rowcount;
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'WDDI : Number of records Deleted',l_ins_rows);
            END IF;

            FORALL i in 1..l_del_det_int_tab.count
                delete from WSH_INTERFACE_ERRORS
                 where interface_id = l_del_det_int_tab(i)
                   and interface_table_name= 'WSH_DEL_DETAILS_INTERFACE';
                l_ins_rows := sql%rowcount;
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'WIE : Number of records Deleted',l_ins_rows);
                END IF;

        END IF;
        ---------
        OPEN C_OPEN_DEL_DET;
        FETCH C_OPEN_DEL_DET into l_count;
        CLOSE C_OPEN_DEL_DET;

        IF l_count = 0 THEN --Will be deleting WNDI and WTH records only iof there are no more detail records for the shipment request
        ---------
            delete from wsh_new_del_interface where delivery_interface_id = l_delivery_interface_id;
            l_ins_rows := sql%rowcount;
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'WNDI : Number of records Deleted',l_ins_rows);
            END IF;
        ---------
            delete from wsh_transactions_history where transaction_id = l_transaction_id;
            l_ins_rows := sql%rowcount;
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'WTH : Number of records Deleted',l_ins_rows);
            END IF;
        ---------
            delete from wsh_interface_errors
             where interface_id = l_delivery_interface_id
               and interface_table_name = 'WSH_NEW_DEL_INTERFACE';
            l_ins_rows := sql%rowcount;
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'WIE : Number of records Deleted',l_ins_rows);
            END IF;
        END IF;

        IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Successfully deleted records.');
        END IF;
        --}
    END IF;

    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
EXCEPTION
    WHEN RECORD_LOCKED THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('WSH','WSH_NO_LOCK');
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
        END IF;
        rollback;
        wsh_util_core.add_message(x_return_status,l_module_name);
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
        END IF;
        IF c_get_Details_DN%ISOPEN THEN
            CLOSE c_get_Details_DN;
        END IF;
        IF c_get_all_del_det_interface_id%ISOPEN THEN
            CLOSE c_get_all_del_det_interface_id;
        END IF;
        IF c_get_del_det_interface_id%ISOPEN THEN
            CLOSE c_get_del_det_interface_id;
        END IF;

    WHEN FND_API.G_EXC_ERROR THEN
        p_shipment_request_info.delivery_interface_id := NULL;
        p_shipment_request_info.transaction_id := null;
        IF p_shipment_request_info.shipment_details_tab.count >0 THEN
            FOR i in 1..p_shipment_request_info.shipment_details_tab.count LOOP
                p_shipment_request_info.shipment_details_tab(i).delivery_detail_interface_id := NULL;
            END LOOP;
        END IF;
        IF c_get_Details_DN%ISOPEN THEN
            CLOSE c_get_Details_DN;
        END IF;
        IF c_get_del_det_interface_id%ISOPEN THEN
            CLOSE c_get_del_det_interface_id;
        END IF;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
        END IF;
        rollback;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Error occured while updating shipment request with document number and revision',p_shipment_request_info.document_number||' and '||p_shipment_request_info.document_revision);
            WSH_DEBUG_SV.pop(l_module_name,'FND_API.G_EXC_ERROR');
        END IF;

    WHEN others THEN
        IF c_get_Details_DN%ISOPEN THEN
            CLOSE c_get_Details_DN;
        END IF;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
        END IF;
        rollback;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Update_Delete_Shipment_Request;

END WSH_SHIPMENT_REQUEST_PUB;

/
