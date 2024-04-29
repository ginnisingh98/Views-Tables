--------------------------------------------------------
--  DDL for Package Body WSH_SHIPMENT_ADVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SHIPMENT_ADVICE_PUB" as
/* $Header: WSHSAPBB.pls 120.0.12010000.1 2010/02/25 17:15:36 sankarun noship $ */

G_PKG_NAME VARCHAR2(100) := 'WSH_SHIPMENT_ADVICE_PUB';
G_INTERFACE_ACTION_CODE  VARCHAR2(100) := '94X_INBOUND';

--========================================================================
--PRIVATE APIS

PROCEDURE Create_Shipment_Advice(
                p_delivery_rec           IN  Delivery_Rec_Type,
                x_return_status          OUT NOCOPY    VARCHAR2);

PROCEDURE Debug_Shipment_Advice(
                p_delivery_rec           IN  Delivery_Rec_Type);

--========================================================================
--========================================================================
-- PROCEDURE : Shipment_Advice         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_action_code           'CREATE'
--             p_delivery_rec          Attributes for the Shipment Advice entity
--             p_commit                commit flag
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================

PROCEDURE Shipment_Advice(
                p_api_version_number     IN  NUMBER,
                p_init_msg_list          IN  VARCHAR2 ,
                p_delivery_rec           IN  Delivery_Rec_Type,
                p_action                 IN VARCHAR2,
                p_commit                 IN  VARCHAR2 ,
                x_return_status          OUT NOCOPY    VARCHAR2,
                x_msg_count              OUT NOCOPY    NUMBER,
                x_msg_data               OUT NOCOPY    VARCHAR2) IS

    l_return_status VARCHAR2(100);
    l_api_version_number CONSTANT NUMBER := 1.0;
    l_api_name           CONSTANT VARCHAR2(30):= 'Shipment_Advice';

    --
    l_debug_on      CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name   CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Shipment_Advice';
    --
BEGIN
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
        END IF;
        IF FND_API.to_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        IF NOT FND_API.Compatible_API_Call
          ( l_api_version_number
          , p_api_version_number
          , l_api_name
          , G_PKG_NAME
          )
        THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF p_action = 'CREATE' THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Create_Shipment_Advice', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            Create_Shipment_Advice(
                        p_delivery_rec       => p_delivery_rec,
                        x_return_status      => l_return_status);
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF p_commit = FND_API.G_TRUE THEN
                COMMIT;
            END IF;
        ELSE
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            fnd_message.set_name('WSH', 'WSH_PUB_INVALID_ACTION');
            fnd_message.set_token('ACTION_CODE', p_action);
            wsh_util_core.add_message(x_return_status);
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'p_action_code should be CREATE.The current value is',p_action);
            END IF;
            RAISE FND_API.G_EXC_ERROR;

        END IF;
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
        END IF;
        rollback;
        fnd_msg_pub.count_and_get(p_count   => x_msg_count,
                          p_data    => x_msg_data,
                          p_encoded => fnd_api.g_false);
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
        END IF;
        rollback;
        fnd_msg_pub.count_and_get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => fnd_api.g_false);

        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
        END IF;
    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
        END IF;
        fnd_msg_pub.count_and_get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => fnd_api.g_false);
        rollback;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Shipment_Advice;


--========================================================================
-- PROCEDURE : Create_Shipment_Advice PRIVATE
--
-- PARAMETERS:
--             p_delivery_rec          Attributes for the create shipment Advice
--             x_return_status         return status
--
-- COMMENT   : Inserts records into WTH,WDAI,WDDI,WNDI,WFCI,WTI,WTSI and WDLI
--========================================================================


PROCEDURE Create_Shipment_Advice(
                p_delivery_rec           IN  Delivery_Rec_Type,
                x_return_status          OUT NOCOPY    VARCHAR2) IS

    --
    l_delivery_interface_id         WSH_NEW_DEL_INTERFACE.delivery_interface_id%TYPE;
    l_del_detail_interface_id       WSH_DEL_DETAILS_INTERFACE.delivery_detail_interface_id%TYPE;
    l_del_leg_interface_id          NUMBER;
    l_pickup_stop_interface_id      NUMBER;
    l_dropoff_stop_interface_id     NUMBER;
    l_trip_interface_id             NUMBER;
    l_del_assgn_cnt                 NUMBER :=0;
    l_wdai_del_interface_id         WSH_UTIL_CORE.ID_TAB_TYPE;
    l_wdai_del_det_interface_id     WSH_UTIL_CORE.ID_TAB_TYPE;
    l_wdai_del_detail_id            WSH_UTIL_CORE.ID_TAB_TYPE;
    l_wdai_parent_del_detail_id     WSH_UTIL_CORE.ID_TAB_TYPE;
    --
    l_return_status VARCHAR2(100);
    l_exists        NUMBER;
    l_ins_rows      NUMBER;
    --
    l_debug_on      CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name   CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Create_Shipmemt_Advice';
    --
BEGIN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Debug_Shipment_Advice', WSH_DEBUG_SV.C_PROC_LEVEL);
            --Debug_Shipment_Advice(p_delivery_rec);
        END IF;
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        --
        IF p_delivery_rec.document_number IS NULL THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            fnd_message.set_name('WSH', 'WSH_SA_ATTR_MANDATORY');
            fnd_message.set_token('ATTRIBUTE','DOCUMENT_NUMBER ');
            wsh_util_core.add_message(x_return_status);

            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Mandatory input parameters have not been passed');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        select count(*) into l_exists
        FROM   wsh_transactions_history
        WHERE  document_number = p_delivery_rec.document_number
        AND    document_type = 'SA'
        AND    document_direction = 'I';

        if l_exists >0 THEN
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            fnd_message.set_name('WSH', 'WSH_SA_DUP_DOCUMENT');
            fnd_message.set_token('DOCUMENT_NUMBER', p_delivery_rec.document_number);
            wsh_util_core.add_message(x_return_status);
            IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name, 'The document already exists');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Inserting into WSH_NEW_DEL_INTERFACE');
        END IF;

        INSERT INTO WSH_NEW_DEL_INTERFACE(
                DELIVERY_INTERFACE_ID,
                NAME,
                DESCRIPTION,
                INITIAL_PICKUP_DATE,
                ULTIMATE_DROPOFF_DATE,
                FREIGHT_TERMS_CODE,
                GROSS_WEIGHT,
                NET_WEIGHT,
                WEIGHT_UOM_CODE,
                NUMBER_OF_LPN,
                VOLUME,
                VOLUME_UOM_CODE,
                SHIPPING_MARKS,
                FOB_CODE,
                SHIP_METHOD_CODE,
                ORGANIZATION_CODE,
                LOADING_SEQUENCE,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15,
                WAYBILL,
                carrier_code,
                SERVICE_LEVEL,
                MODE_OF_TRANSPORT,
                wv_frozen_flag,
                SHIPMENT_DIRECTION,
                DELIVERED_DATE,
                CUSTOMER_NAME,
                PLANNED_FLAG,
                STATUS_CODE,
                INTERFACE_ACTION_CODE,
                DELIVERY_TYPE,
                INITIAL_PICKUP_LOCATION_CODE,
                SHIP_TO_CUSTOMER_NAME,
                SHIP_TO_ADDRESS1,
                SHIP_TO_ADDRESS2,
                SHIP_TO_ADDRESS3,
                SHIP_TO_ADDRESS4,
                SHIP_TO_CITY,
                SHIP_TO_STATE,
                SHIP_TO_COUNTRY,
                SHIP_TO_POSTAL_CODE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                program_application_id,
                program_id,
                program_update_date,
                request_id
                )
         VALUES(
                wsh_new_del_interface_s.nextval,
                p_delivery_rec.name,
                p_delivery_rec.DESCRIPTION,
                p_delivery_rec.INITIAL_PICKUP_DATE,
                p_delivery_rec.ULTIMATE_DROPOFF_DATE,
                p_delivery_rec.FREIGHT_TERMS_CODE,
                p_delivery_rec.GROSS_WEIGHT,
                p_delivery_rec.NET_WEIGHT,
                p_delivery_rec.WEIGHT_UOM_CODE,
                p_delivery_rec.NUMBER_OF_LPN,
                p_delivery_rec.VOLUME,
                p_delivery_rec.VOLUME_UOM_CODE,
                p_delivery_rec.SHIPPING_MARKS,
                p_delivery_rec.FOB_CODE,
                p_delivery_rec.SHIP_METHOD_CODE,
                p_delivery_rec.ORGANIZATION_CODE,
                p_delivery_rec.LOADING_SEQUENCE,
                p_delivery_rec.ATTRIBUTE_CATEGORY,
                p_delivery_rec.ATTRIBUTE1,
                p_delivery_rec.ATTRIBUTE2,
                p_delivery_rec.ATTRIBUTE3,
                p_delivery_rec.ATTRIBUTE4,
                p_delivery_rec.ATTRIBUTE5,
                p_delivery_rec.ATTRIBUTE6,
                p_delivery_rec.ATTRIBUTE7,
                p_delivery_rec.ATTRIBUTE8,
                p_delivery_rec.ATTRIBUTE9,
                p_delivery_rec.ATTRIBUTE10,
                p_delivery_rec.ATTRIBUTE11,
                p_delivery_rec.ATTRIBUTE12,
                p_delivery_rec.ATTRIBUTE13,
                p_delivery_rec.ATTRIBUTE14,
                p_delivery_rec.ATTRIBUTE15,
                p_delivery_rec.WAYBILL,
                p_delivery_rec.carrier_code,
                p_delivery_rec.SERVICE_LEVEL,
                p_delivery_rec.MODE_OF_TRANSPORT,
                p_delivery_rec.wv_frozen_flag,
                p_delivery_rec.shipment_direction,
                p_delivery_rec.DELIVERED_DATE,
                p_delivery_rec.CUSTOMER_NAME,
                'N',
                'OP',
                G_INTERFACE_ACTION_CODE,
                'STANDARD',
                p_delivery_rec.INITIAL_PICKUP_LOCATION_CODE,
                p_delivery_rec.SHIP_TO_CUSTOMER_NAME,
                p_delivery_rec.SHIP_TO_ADDRESS1,
                p_delivery_rec.SHIP_TO_ADDRESS2,
                p_delivery_rec.SHIP_TO_ADDRESS3,
                p_delivery_rec.SHIP_TO_ADDRESS4,
                p_delivery_rec.SHIP_TO_CITY,
                p_delivery_rec.SHIP_TO_STATE,
                p_delivery_rec.SHIP_TO_COUNTRY,
                p_delivery_rec.SHIP_TO_POSTAL_CODE,
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.LOGIN_ID,
                FND_GLOBAL.PROG_APPL_ID,
                FND_GLOBAL.Conc_Program_Id,
                sysdate,
                FND_GLOBAL.Conc_Request_Id
                )
                RETURNING DELIVERY_INTERFACE_ID into l_delivery_interface_id;

        l_ins_rows := sql%rowcount;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Number of records inserted into WSH_NEW_DEL_INTERFACE',l_ins_rows);
            WSH_DEBUG_SV.log(l_module_name, 'Number of Delivery Freight records',p_delivery_rec.delivery_freight_tab.count);
        END IF;


        IF p_delivery_rec.delivery_freight_tab.count>0 THEN --Delivery's Freight costs
        --{
            IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name, 'Inserting WSH_FREIGHT_COSTS_INTERFACE for the delivery');
            END IF;
            FOR k in 1..p_delivery_rec.delivery_freight_tab.count LOOP  --Looping through Delivery's Freight costs

                INSERT INTO WSH_FREIGHT_COSTS_INTERFACE(
                        FREIGHT_COST_INTERFACE_ID,
                        INTERFACE_ACTION_CODE,
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        DELIVERY_INTERFACE_ID,
                        DELIVERY_DETAIL_INTERFACE_ID,
                        FREIGHT_COST_TYPE_CODE,
                        UNIT_AMOUNT,
                        CURRENCY_CODE)
                 VALUES(
                        wsh_freight_costs_interface_s.nextval,
                        G_INTERFACE_ACTION_CODE,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE_CATEGORY,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE1,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE2,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE3,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE4,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE5,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE6,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE7,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE8,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE9,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE10,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE11,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE12,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE13,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE14,
                        p_delivery_rec.delivery_freight_tab(k).ATTRIBUTE15,
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        l_delivery_interface_id,
                        NULL,
                        p_delivery_rec.delivery_freight_tab(k).FREIGHT_COST_TYPE_CODE,
                        p_delivery_rec.delivery_freight_tab(k).UNIT_AMOUNT,
                        p_delivery_rec.delivery_freight_tab(k).CURRENCY_CODE
                        );
            END LOOP;--End of looping through Delivery's Freight Costs..
        --}
        END IF;--Delivery's Freight costs
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Number of delivery details details',p_delivery_rec.delivery_details_tab.count);
        END IF;

        IF p_delivery_rec.delivery_details_tab.count > 0 THEN --Delivery details count
        --{
            IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name, 'Inserting into WDDI and WFCI(delivery details freight info))');
            END IF;
            FOR I in 1..p_delivery_rec.delivery_details_tab.count LOOP
            --{
                IF l_debug_on THEN
                    wsh_debug_sv.logmsg(l_module_name, 'Inserting Rec'||i||' into WSH_DEL_DETAILS_INTERFACE (validating source_line_id)');
                END IF;
                IF p_delivery_rec.delivery_details_tab(i).source_line_id IS NULL THEN

                    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    fnd_message.set_name('WSH', 'WSH_SA_ATTR_MANDATORY');
                    fnd_message.set_token('ATTRIBUTE','LINE_NUMBER');
                    wsh_util_core.add_message(x_return_status);
                    IF l_debug_on THEN
                       wsh_debug_sv.logmsg(l_module_name, 'Line number is a mandatory parameter for delivery_detail_interface records');
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                INSERT INTO WSH_DEL_DETAILS_INTERFACE(
                        DELIVERY_DETAIL_INTERFACE_ID,
                        ITEM_NUMBER,
                        REQUESTED_QUANTITY,
                        REQUESTED_QUANTITY_UOM,
                        ITEM_DESCRIPTION,
                        REVISION,
                        SHIPPED_QUANTITY,
                        VOLUME,
                        VOLUME_UOM_CODE,
                        GROSS_WEIGHT,
                        NET_WEIGHT,
                        WEIGHT_UOM_CODE,
                        DELIVERY_DETAIL_ID,
                        SOURCE_LINE_ID,
                        LOAD_SEQ_NUMBER,
                        SUBINVENTORY,
                        LOT_NUMBER,
                        PREFERRED_GRADE,
                        SERIAL_NUMBER,
                        TO_SERIAL_NUMBER,
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        SOURCE_HEADER_NUMBER,
                        LINE_DIRECTION,
                        WV_FROZEN_FLAG,
                        CYCLE_COUNT_QUANTITY,
                        LOCATOR_CODE,
                        SOURCE_CODE,
                        CONTAINER_FLAG,
                        INTERFACE_ACTION_CODE,
                        ORGANIZATION_CODE,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN,
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE,
                        REQUEST_ID
                       )
                VALUES(
                        wsh_del_details_interface_s.nextval,
                        p_delivery_rec.delivery_details_tab(i).ITEM_NUMBER,
                        p_delivery_rec.delivery_details_tab(i).REQUESTED_QUANTITY,
                        p_delivery_rec.delivery_details_tab(i).REQUESTED_QUANTITY_UOM,
                        p_delivery_rec.delivery_details_tab(i).ITEM_DESCRIPTION,
                        p_delivery_rec.delivery_details_tab(i).REVISION,
                        p_delivery_rec.delivery_details_tab(i).SHIPPED_QUANTITY,
                        p_delivery_rec.delivery_details_tab(i).VOLUME,
                        p_delivery_rec.delivery_details_tab(i).VOLUME_UOM_CODE,
                        p_delivery_rec.delivery_details_tab(i).GROSS_WEIGHT,
                        p_delivery_rec.delivery_details_tab(i).NET_WEIGHT,
                        p_delivery_rec.delivery_details_tab(i).WEIGHT_UOM_CODE,
                        p_delivery_rec.delivery_details_tab(i).delivery_detail_number,
                        p_delivery_rec.delivery_details_tab(i).source_line_id,
                        p_delivery_rec.delivery_details_tab(i).LOAD_SEQ_NUMBER,
                        p_delivery_rec.delivery_details_tab(i).SUBINVENTORY,
                        p_delivery_rec.delivery_details_tab(i).LOT_NUMBER,
                        p_delivery_rec.delivery_details_tab(i).PREFERRED_GRADE,
                        p_delivery_rec.delivery_details_tab(i).SERIAL_NUMBER,
                        p_delivery_rec.delivery_details_tab(i).TO_SERIAL_NUMBER,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE_CATEGORY,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE1,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE2,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE3,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE4,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE5,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE6,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE7,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE8,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE9,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE10,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE11,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE12,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE13,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE14,
                        p_delivery_rec.delivery_details_tab(i).ATTRIBUTE15,
                        p_delivery_rec.delivery_details_tab(i).SOURCE_HEADER_NUMBER,
                        p_delivery_rec.delivery_details_tab(i).line_direction,
                        p_delivery_rec.delivery_details_tab(i).WV_FROZEN_FLAG,
                        p_delivery_rec.delivery_details_tab(i).CYCLE_COUNT_QUANTITY,
                        p_delivery_rec.delivery_details_tab(i).LOCATOR_CODE,
                        'WSH',
                        'N',
                        G_INTERFACE_ACTION_CODE,
                        p_delivery_rec.ORGANIZATION_CODE,
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        FND_GLOBAL.LOGIN_ID,
                        FND_GLOBAL.PROG_APPL_ID,
                        FND_GLOBAL.Conc_Program_Id,
                        sysdate,
                        FND_GLOBAL.Conc_Request_Id)
                        RETURNING DELIVERY_DETAIL_INTERFACE_ID into l_del_detail_interface_id;

                l_del_assgn_cnt := l_del_assgn_cnt +1;
                l_WDAI_DEL_INTERFACE_ID(l_del_assgn_cnt)     :=  L_DELIVERY_INTERFACE_ID;
                l_WDAI_DEL_DET_INTERFACE_ID(l_del_assgn_cnt) :=  l_del_detail_interface_id;
                l_WDAI_DEL_DETAIL_ID(l_del_assgn_cnt)	  :=  p_delivery_rec.delivery_details_tab(i).delivery_detail_number;
                l_WDAI_PARENT_DEL_DETAIL_ID(l_del_assgn_cnt) :=   p_delivery_rec.delivery_details_tab(i).PARENT_DELIVERY_DETAIL_NUMBER;

                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'Number of delivery details Freight Records',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab.count);
                END IF;

                IF p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab.count > 0 THEN --Delivery details Freight costs count
                --{
                    IF l_debug_on THEN
                        wsh_debug_sv.logmsg(l_module_name, 'Inserting into WFCI for delivery detail rec ' || i);
                    END IF;
                    FOR k in 1..p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab.count LOOP
                    --{
                        INSERT INTO WSH_FREIGHT_COSTS_INTERFACE(
                                FREIGHT_COST_INTERFACE_ID,
                                INTERFACE_ACTION_CODE,
                                ATTRIBUTE_CATEGORY,
                                ATTRIBUTE1,
                                ATTRIBUTE2,
                                ATTRIBUTE3,
                                ATTRIBUTE4,
                                ATTRIBUTE5,
                                ATTRIBUTE6,
                                ATTRIBUTE7,
                                ATTRIBUTE8,
                                ATTRIBUTE9,
                                ATTRIBUTE10,
                                ATTRIBUTE11,
                                ATTRIBUTE12,
                                ATTRIBUTE13,
                                ATTRIBUTE14,
                                ATTRIBUTE15,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                DELIVERY_INTERFACE_ID,
                                DELIVERY_DETAIL_INTERFACE_ID,
                                FREIGHT_COST_TYPE_CODE,
                                UNIT_AMOUNT,
                                CURRENCY_CODE)
                         VALUES(
                                wsh_freight_costs_interface_s.nextval,
                                G_INTERFACE_ACTION_CODE,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE_CATEGORY,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE1,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE2,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE3,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE4,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE5,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE6,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE7,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE8,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE9,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE10,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE11,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE12,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE13,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE14,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).ATTRIBUTE15,
                                sysdate,
                                FND_GLOBAL.USER_ID,
                                sysdate,
                                FND_GLOBAL.USER_ID,
                                NULL,
                                l_del_detail_interface_id,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).FREIGHT_COST_TYPE_CODE,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).UNIT_AMOUNT,
                                p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).CURRENCY_CODE
                                );
                    --}
                    END LOOP;--End of looping through Delivery details' Freight Costs..
                --}
                END IF;--Delivery details Freight costs count

            --}
            END LOOP;--End of looping through Delivery details..
        --}
        END IF;--Delivery details count

        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'Number of Master Container Records',p_delivery_rec.container_tab.count);
        END IF;
        IF p_delivery_rec.container_tab.count > 0 THEN  --Master Containers
        --{
            IF l_debug_on THEN
                wsh_debug_sv.logmsg(l_module_name, 'Inserting Master Container records into WDDI');
            END IF;
            FOR i in 1..p_delivery_rec.container_tab.count LOOP  --Master Containers
            --{
                INSERT INTO WSH_DEL_DETAILS_INTERFACE(
                        DELIVERY_DETAIL_INTERFACE_ID,
                        CONTAINER_NAME,
                        SEAL_CODE,
                        ITEM_NUMBER,
                        ITEM_DESCRIPTION,
                        DELIVERY_DETAIL_ID,
                        GROSS_WEIGHT,
                        NET_WEIGHT,
                        WEIGHT_UOM_CODE,
                        VOLUME,
                        VOLUME_UOM_CODE,
                        TRACKING_NUMBER,
                        SHIPPING_INSTRUCTIONS,
                        PACKING_INSTRUCTIONS,
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        WV_FROZEN_FLAG,
                        FILLED_VOLUME,
                        FILL_PERCENT,
                        SOURCE_CODE,
                        CONTAINER_FLAG,
                        INTERFACE_ACTION_CODE,
                        LINE_DIRECTION,
                        SOURCE_LINE_ID,
                        ORGANIZATION_CODE,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY
                        )
                 VALUES(
                        wsh_del_details_interface_s.nextval,
                        p_delivery_rec.container_tab(i).CONTAINER_NAME,
                        p_delivery_rec.container_tab(i).SEAL_CODE,
                        p_delivery_rec.container_tab(i).ITEM_NUMBER,
                        p_delivery_rec.container_tab(i).ITEM_DESCRIPTION,
                        p_delivery_rec.container_tab(i).DELIVERY_DETAIL_NUMBER,
                        p_delivery_rec.container_tab(i).GROSS_WEIGHT,
                        p_delivery_rec.container_tab(i).NET_WEIGHT,
                        p_delivery_rec.container_tab(i).WEIGHT_UOM_CODE,
                        p_delivery_rec.container_tab(i).VOLUME,
                        p_delivery_rec.container_tab(i).VOLUME_UOM_CODE,
                        p_delivery_rec.container_tab(i).TRACKING_NUMBER,
                        p_delivery_rec.container_tab(i).SHIPPING_INSTRUCTIONS,
                        p_delivery_rec.container_tab(i).PACKING_INSTRUCTIONS,
                        p_delivery_rec.container_tab(i).ATTRIBUTE_CATEGORY,
                        p_delivery_rec.container_tab(i).ATTRIBUTE1,
                        p_delivery_rec.container_tab(i).ATTRIBUTE2,
                        p_delivery_rec.container_tab(i).ATTRIBUTE3,
                        p_delivery_rec.container_tab(i).ATTRIBUTE4,
                        p_delivery_rec.container_tab(i).ATTRIBUTE5,
                        p_delivery_rec.container_tab(i).ATTRIBUTE6,
                        p_delivery_rec.container_tab(i).ATTRIBUTE7,
                        p_delivery_rec.container_tab(i).ATTRIBUTE8,
                        p_delivery_rec.container_tab(i).ATTRIBUTE9,
                        p_delivery_rec.container_tab(i).ATTRIBUTE10,
                        p_delivery_rec.container_tab(i).ATTRIBUTE11,
                        p_delivery_rec.container_tab(i).ATTRIBUTE12,
                        p_delivery_rec.container_tab(i).ATTRIBUTE13,
                        p_delivery_rec.container_tab(i).ATTRIBUTE14,
                        p_delivery_rec.container_tab(i).ATTRIBUTE15,
                        p_delivery_rec.container_tab(i).WV_FROZEN_FLAG,
                        p_delivery_rec.container_tab(i).FILLED_VOLUME,
                        p_delivery_rec.container_tab(i).FILL_PERCENT,
                        'WSH',
                        'Y',
                        G_INTERFACE_ACTION_CODE,
                        p_delivery_rec.delivery_details_tab(i).line_direction,
                        p_delivery_rec.container_tab(i).DELIVERY_DETAIL_NUMBER,
                        p_delivery_rec.ORGANIZATION_CODE,
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        sysdate,
                        FND_GLOBAL.USER_ID)
                        RETURNING DELIVERY_DETAIL_INTERFACE_ID into l_del_detail_interface_id;
                l_del_assgn_cnt := l_del_assgn_cnt +1;
                l_WDAI_DEL_INTERFACE_ID(l_del_assgn_cnt)     := L_DELIVERY_INTERFACE_ID ;
                l_WDAI_DEL_DET_INTERFACE_ID(l_del_assgn_cnt) := l_del_detail_interface_id ;
                l_WDAI_DEL_DETAIL_ID(l_del_assgn_cnt)	  :=  p_delivery_rec.container_tab(i).delivery_detail_number ;
                l_WDAI_PARENT_DEL_DETAIL_ID(l_del_assgn_cnt) := NULL ;

                IF l_debug_on THEN
                    wsh_debug_sv.log(l_module_name, 'Number of Master Container Freight records',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab.count);
                END IF;
                IF p_delivery_rec.container_tab(i).Master_Container_Freight_Tab.count > 0 THEN --Master Containers Freight
                --{
                    IF l_debug_on THEN
                        wsh_debug_sv.logmsg(l_module_name, 'Inserting Master Container Freight records into WFCI');
                    END IF;
                    FOR k in  1..p_delivery_rec.container_tab(i).Master_Container_Freight_Tab.count LOOP --Master Containers Freight
                    --{
                        INSERT INTO WSH_FREIGHT_COSTS_INTERFACE(
                                FREIGHT_COST_INTERFACE_ID,
                                INTERFACE_ACTION_CODE,
                                ATTRIBUTE_CATEGORY,
                                ATTRIBUTE1,
                                ATTRIBUTE2,
                                ATTRIBUTE3,
                                ATTRIBUTE4,
                                ATTRIBUTE5,
                                ATTRIBUTE6,
                                ATTRIBUTE7,
                                ATTRIBUTE8,
                                ATTRIBUTE9,
                                ATTRIBUTE10,
                                ATTRIBUTE11,
                                ATTRIBUTE12,
                                ATTRIBUTE13,
                                ATTRIBUTE14,
                                ATTRIBUTE15,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                DELIVERY_INTERFACE_ID,
                                DELIVERY_DETAIL_INTERFACE_ID,
                                FREIGHT_COST_TYPE_CODE,
                                UNIT_AMOUNT,
                                CURRENCY_CODE)
                         VALUES(
                                wsh_freight_costs_interface_s.nextval,
                                G_INTERFACE_ACTION_CODE,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE_CATEGORY,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE1,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE2,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE3,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE4,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE5,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE6,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE7,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE8,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE9,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE10,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE11,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE12,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE13,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE14,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).ATTRIBUTE15,
                                sysdate,
                                FND_GLOBAL.USER_ID,
                                sysdate,
                                FND_GLOBAL.USER_ID,
                                NULL,
                                l_del_detail_interface_id,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).FREIGHT_COST_TYPE_CODE,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).UNIT_AMOUNT,
                                p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(k).CURRENCY_CODE
                                );
                    --}
                    END LOOP; --Master Containers Freight
                --}
                END IF; --Master Containers Freight

                IF l_debug_on THEN
                    wsh_debug_sv.log(l_module_name, 'Number of Inner Containers with in the Master Container',p_delivery_rec.container_tab(i).Container_Tab.count);
                END IF;
                IF p_delivery_rec.container_tab(i).Container_Tab.count > 0 THEN --Inner Containers
                --{

                    IF l_debug_on THEN
                        wsh_debug_sv.logmsg(l_module_name, 'Number of Inner containers : '||p_delivery_rec.container_tab(i).Container_Tab.count);
                    END IF;
                    FOR k in 1..p_delivery_rec.container_tab(i).Container_Tab.count LOOP  --Inner Containers
                    --{
                        IF l_debug_on THEN
                            wsh_debug_sv.logmsg(l_module_name, 'Inserting Inner Container records into WDDI');
                        END IF;
                        INSERT INTO WSH_DEL_DETAILS_INTERFACE(
                                DELIVERY_DETAIL_INTERFACE_ID,
                                CONTAINER_NAME,
                                SEAL_CODE,
                                ITEM_NUMBER,
                                ITEM_DESCRIPTION,
                                DELIVERY_DETAIL_ID,
                                GROSS_WEIGHT,
                                NET_WEIGHT,
                                WEIGHT_UOM_CODE,
                                VOLUME,
                                VOLUME_UOM_CODE,
                                TRACKING_NUMBER,
                                SHIPPING_INSTRUCTIONS,
                                PACKING_INSTRUCTIONS,
                                ATTRIBUTE_CATEGORY,
                                ATTRIBUTE1,
                                ATTRIBUTE2,
                                ATTRIBUTE3,
                                ATTRIBUTE4,
                                ATTRIBUTE5,
                                ATTRIBUTE6,
                                ATTRIBUTE7,
                                ATTRIBUTE8,
                                ATTRIBUTE9,
                                ATTRIBUTE10,
                                ATTRIBUTE11,
                                ATTRIBUTE12,
                                ATTRIBUTE13,
                                ATTRIBUTE14,
                                ATTRIBUTE15,
                                WV_FROZEN_FLAG,
                                FILLED_VOLUME,
                                FILL_PERCENT,
                                SOURCE_CODE,
                                CONTAINER_FLAG,
                                INTERFACE_ACTION_CODE,
                                LINE_DIRECTION,
                                SOURCE_LINE_ID,
                                ORGANIZATION_CODE,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY
                                )
                         VALUES(
                                wsh_del_details_interface_s.nextval,
                                p_delivery_rec.container_tab(i).container_tab(k).CONTAINER_NAME,
                                p_delivery_rec.container_tab(i).container_tab(k).SEAL_CODE,
                                p_delivery_rec.container_tab(i).container_tab(k).ITEM_NUMBER,
                                p_delivery_rec.container_tab(i).container_tab(k).ITEM_DESCRIPTION,
                                p_delivery_rec.container_tab(i).container_tab(k).DELIVERY_DETAIL_NUMBER,
                                p_delivery_rec.container_tab(i).container_tab(k).GROSS_WEIGHT,
                                p_delivery_rec.container_tab(i).container_tab(k).NET_WEIGHT,
                                p_delivery_rec.container_tab(i).container_tab(k).WEIGHT_UOM_CODE,
                                p_delivery_rec.container_tab(i).container_tab(k).VOLUME,
                                p_delivery_rec.container_tab(i).container_tab(k).VOLUME_UOM_CODE,
                                p_delivery_rec.container_tab(i).container_tab(k).TRACKING_NUMBER,
                                p_delivery_rec.container_tab(i).container_tab(k).SHIPPING_INSTRUCTIONS,
                                p_delivery_rec.container_tab(i).container_tab(k).PACKING_INSTRUCTIONS,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE_CATEGORY,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE1,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE2,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE3,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE4,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE5,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE6,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE7,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE8,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE9,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE10,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE11,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE12,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE13,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE14,
                                p_delivery_rec.container_tab(i).container_tab(k).ATTRIBUTE15,
                                p_delivery_rec.container_tab(i).container_tab(k).WV_FROZEN_FLAG,
                                p_delivery_rec.container_tab(i).container_tab(k).FILLED_VOLUME,
                                p_delivery_rec.container_tab(i).container_tab(k).FILL_PERCENT,
                                'WSH',
                                'Y',
                                G_INTERFACE_ACTION_CODE,
                                p_delivery_rec.delivery_details_tab(i).line_direction,
                                p_delivery_rec.container_tab(i).container_tab(k).DELIVERY_DETAIL_NUMBER,
                                p_delivery_rec.ORGANIZATION_CODE,
                                sysdate,
                                FND_GLOBAL.USER_ID,
                                sysdate,
                                FND_GLOBAL.USER_ID)
                                RETURNING DELIVERY_DETAIL_INTERFACE_ID into l_del_detail_interface_id;


                        l_del_assgn_cnt := l_del_assgn_cnt +1;
                        l_WDAI_DEL_INTERFACE_ID(l_del_assgn_cnt)     := L_DELIVERY_INTERFACE_ID ;
                        l_WDAI_DEL_DET_INTERFACE_ID(l_del_assgn_cnt) := l_del_detail_interface_id ;
                        l_WDAI_DEL_DETAIL_ID(l_del_assgn_cnt)	  := p_delivery_rec.container_tab(i).container_tab(k).delivery_detail_number ;
                        l_WDAI_PARENT_DEL_DETAIL_ID(l_del_assgn_cnt) := p_delivery_rec.container_tab(i).delivery_detail_number ;

                        IF l_debug_on THEN
                            wsh_debug_sv.log(l_module_name, 'Number of Inner Container Freight records', p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab.count);
                        END IF;
                        IF p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab.count > 0 THEN --Inner Containers Freight Costs
                        --{
                            IF l_debug_on THEN
                                wsh_debug_sv.logmsg(l_module_name, 'Inserting Inner Container Freight records into WFCI');
                            END IF;
                            FOR l in  1..p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab.count LOOP --Inner Containers Freight Costs
                            --{
                                INSERT INTO WSH_FREIGHT_COSTS_INTERFACE(
                                        FREIGHT_COST_INTERFACE_ID,
                                        INTERFACE_ACTION_CODE,
                                        ATTRIBUTE_CATEGORY,
                                        ATTRIBUTE1,
                                        ATTRIBUTE2,
                                        ATTRIBUTE3,
                                        ATTRIBUTE4,
                                        ATTRIBUTE5,
                                        ATTRIBUTE6,
                                        ATTRIBUTE7,
                                        ATTRIBUTE8,
                                        ATTRIBUTE9,
                                        ATTRIBUTE10,
                                        ATTRIBUTE11,
                                        ATTRIBUTE12,
                                        ATTRIBUTE13,
                                        ATTRIBUTE14,
                                        ATTRIBUTE15,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        DELIVERY_INTERFACE_ID,
                                        DELIVERY_DETAIL_INTERFACE_ID,
                                        FREIGHT_COST_TYPE_CODE,
                                        UNIT_AMOUNT,
                                        CURRENCY_CODE)
                                 VALUES(
                                        wsh_freight_costs_interface_s.nextval,
                                        G_INTERFACE_ACTION_CODE,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE_CATEGORY,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE1,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE2,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE3,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE4,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE5,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE6,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE7,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE8,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE9,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE10,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE11,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE12,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE13,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE14,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).ATTRIBUTE15,
                                        sysdate,
                                        FND_GLOBAL.USER_ID,
                                        sysdate,
                                        FND_GLOBAL.USER_ID,
                                        NULL,
                                        l_del_detail_interface_id,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).FREIGHT_COST_TYPE_CODE,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).UNIT_AMOUNT,
                                        p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).CURRENCY_CODE
                                        );
                            --}
                            END LOOP;--Inner Containers Freight Costs
                        --}
                        END IF;--Inner Containers Freight Costs
                    --}
                    END LOOP;--Inner Containers
                --}
                END IF;--Inner Containers


            --}
            END LOOP;--Master Containers
        --}
        END IF;--Master Containers

        IF l_debug_on THEN
            wsh_debug_sv.logmsg(l_module_name, 'Storing Trips and Trip Stops infp ');
        END IF;

        IF l_del_assgn_cnt > 0 THEN


            IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name, 'Inserting Records into WSH_DEL_ASSGN_INTERFACE.Number of Records',l_del_assgn_cnt);
            END IF;
            IF  l_del_assgn_cnt <4 THEN

                FOR I in 1..l_del_assgn_cnt LOOP

                    INSERT INTO WSH_DEL_ASSGN_INTERFACE(
                            DEL_ASSGN_INTERFACE_ID,
                            INTERFACE_ACTION_CODE,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            DELIVERY_INTERFACE_ID ,
                            DELIVERY_DETAIL_INTERFACE_ID ,
                            DELIVERY_DETAIL_ID,
                            PARENT_DELIVERY_DETAIL_ID)
                      VALUES(
                            wsh_del_assgn_interface_s.nextval,
                            G_INTERFACE_ACTION_CODE,
                            sysdate,
                            FND_GLOBAL.USER_ID,
                            sysdate,
                            FND_GLOBAL.USER_ID,
                            l_WDAI_DEL_INTERFACE_ID(i),
                            l_WDAI_DEL_DET_INTERFACE_ID(i),
                            l_WDAI_DEL_DETAIL_ID(i),
                            l_WDAI_PARENT_DEL_DETAIL_ID(i));

                END LOOP;

            ELSE

                FORALL I in 1..l_del_assgn_cnt

                    INSERT INTO WSH_DEL_ASSGN_INTERFACE(
                            DEL_ASSGN_INTERFACE_ID,
                            INTERFACE_ACTION_CODE,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            DELIVERY_INTERFACE_ID ,
                            DELIVERY_DETAIL_INTERFACE_ID ,
                            DELIVERY_DETAIL_ID,
                            PARENT_DELIVERY_DETAIL_ID)
                      VALUES(
                            wsh_del_assgn_interface_s.nextval,
                            G_INTERFACE_ACTION_CODE,
                            sysdate,
                            FND_GLOBAL.USER_ID,
                            sysdate,
                            FND_GLOBAL.USER_ID,
                            l_WDAI_DEL_INTERFACE_ID(i),
                            l_WDAI_DEL_DET_INTERFACE_ID(i),
                            l_WDAI_DEL_DETAIL_ID(i),
                            l_WDAI_PARENT_DEL_DETAIL_ID(i));
            END IF;

        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTERFACE_COMMON_ACTIONS.Int_Trip_Stop_Info', WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_INTERFACE_COMMON_ACTIONS.Int_Trip_Stop_Info(
                    p_delivery_interface_id =>l_delivery_interface_id,
                    p_act_dep_date          => p_delivery_rec.actual_departure_date,
                    p_dep_seal_code         => p_delivery_rec.departure_seal_code,
                    p_act_arr_date          => p_delivery_rec.actual_arrival_date	,
                    p_trip_vehicle_num      => p_delivery_rec.vehicle_number,
                    p_trip_veh_num_pfx      => p_delivery_rec.vehicle_num_prefix,
                    p_trip_route_id         => p_delivery_rec.route_id,
                    p_trip_routing_ins      => p_delivery_rec.routing_instructions,
                    p_operator              => p_delivery_rec.operator ,
                    x_return_status         => l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        INSERT INTO wsh_transactions_history (
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
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE)
         VALUES(
                wsh_transaction_s.nextval,
                'SA',
                p_delivery_rec.DOCUMENT_NUMBER,
                'I',
                'AP',
                'A',
                l_delivery_interface_id,
                'DLVY_INT',
                -1,
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.LOGIN_ID,
                FND_GLOBAL.Conc_Request_Id,
                FND_GLOBAL.PROG_APPL_ID,
                FND_GLOBAL.Conc_Program_Id,
                sysdate);

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Error Creating Shipment advance with Document_Number',p_delivery_rec.Document_Number);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Create_Shipment_Advice;

--========================================================================
-- PROCEDURE : Process_Shipment_Advice         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_process_mode          'ONLINE' or 'CONCURRENT'
--             p_log_level             0 or 1 to control the log messages
--             p_transaction_status    Status of Shipment Advice
--             p_from_document_number  From Document Number
--             p_to_document_number    To Document Number
--             p_from_creation_date    From Creation Date
--             p_to_creation_date      To Creation Date
--             x_return_status         return status
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Processes Shipment Advice as per criteria
--             specified in p_transaction_status,p_from_document_number,
--             p_to_document_number,p_from_creation_date and p_to_creation_date
--========================================================================

PROCEDURE Process_Shipment_Advice (
                p_api_version_number   IN  NUMBER,
                p_init_msg_list        IN  VARCHAR2,
                p_commit               IN  VARCHAR2,
                p_process_mode         IN  VARCHAR2 ,
                p_log_level            IN  NUMBER,
                p_transaction_status   IN  VARCHAR2,
                p_from_document_number IN  VARCHAR2,
                p_to_document_number   IN  VARCHAR2,
                p_from_creation_date   IN  DATE,
                p_to_creation_date     IN  DATE,
                p_transaction_id       IN  NUMBER,
                x_request_id           OUT NOCOPY NUMBER,
                x_return_status        OUT NOCOPY VARCHAR2,
                x_msg_count            OUT NOCOPY    NUMBER,
                x_msg_data             OUT NOCOPY    VARCHAR2)IS


    l_return_status VARCHAR2(100);

    l_api_version_number CONSTANT NUMBER := 1.0;
    l_api_name           CONSTANT VARCHAR2(30):= 'Process_Shipment_Advice';
    --
    l_debug_on      CONSTANT BOOLEAN       := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name   CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Process_Shipmemt_Advice';
    --

BEGIN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
        IF l_debug_on then
            wsh_debug_sv.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'p_process_mode',p_process_mode);
            WSH_DEBUG_SV.log(l_module_name,'p_log_level',p_log_level);
            WSH_DEBUG_SV.log(l_module_name,'p_commit',p_commit);
            WSH_DEBUG_SV.log(l_module_name,'p_init_msg_list',p_init_msg_list);
            --

            WSH_DEBUG_SV.log(l_module_name,'p_transaction_status',p_transaction_status);
            WSH_DEBUG_SV.log(l_module_name,'p_from_document_number',p_from_document_number);
            WSH_DEBUG_SV.log(l_module_name,'p_to_document_number',p_to_document_number);
            WSH_DEBUG_SV.log(l_module_name,'p_from_creation_date',p_from_creation_date);
            WSH_DEBUG_SV.log(l_module_name,'p_to_creation_date',p_to_creation_date);
            WSH_DEBUG_SV.log(l_module_name,'p_transaction_id',p_transaction_id);

        END IF;
        IF FND_API.to_Boolean(p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
        END IF;

        IF NOT FND_API.Compatible_API_Call
            ( l_api_version_number
            , p_api_version_number
            , l_api_name
            , G_PKG_NAME
            )
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF p_process_mode = 'ONLINE' THEN

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPMENT_ADVICE_PKG.Process_Shipment_Advice', WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            WSH_SHIPMENT_ADVICE_PKG.Process_Shipment_Advice(
                            p_commit_flag          => p_commit,
                            p_transaction_status   => p_transaction_status,
                            p_from_document_number => p_from_document_number ,
                            p_to_document_number   => p_to_document_number,
                            p_from_creation_date   => to_date(p_from_creation_date,'yy-mm-dd'),
                            p_to_creation_date     => to_date(p_to_creation_date,'yy-mm-dd'),
                            p_transaction_id       => p_transaction_id,
                            x_return_status        => l_return_status);

            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name, 'Process_Shipment_Advice completed with error');
                END IF;
                --
                x_return_status := l_return_status;
                FND_MESSAGE.Set_Name('WSH', 'WSH_SA_PROCESS_ERROR');
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
                program       =>  'WSHSAINB',
                description   =>  'Process Shipment Advices',
                start_time    =>   NULL,
                sub_request   =>   FALSE,
                argument1     =>   p_transaction_status,
                argument2     =>   p_from_document_number,
                argument3     =>   p_to_document_number,
                argument4     =>   to_date(p_from_creation_date,'yy-mm-dd'),
                argument5     =>   to_date(p_to_creation_date,'yy-mm-dd'),
                argument6     =>   p_transaction_id,
                argument7     =>   p_log_level);

            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Request Id returned from FND_REQUEST.SUBMIT_REQUEST', x_request_id);
            END IF;
            --
            IF (nvl(x_request_id,0) <= 0) THEN
                raise  FND_API.G_EXC_ERROR;
            END IF;
        ELSE
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            fnd_message.set_name('WSH', 'WSH_OI_INVALID_ATTRIBUTE');
            fnd_message.set_token('ATTRIBUTE', 'PROCESS_MODE');
            wsh_util_core.add_message(x_return_status);
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'p_process_mode should be ONLINE/CONCURRENT');
            END IF;
            raise  FND_API.G_EXC_ERROR;
        END IF;

        IF p_commit =  FND_API.G_TRUE THEN
            COMMIT;
        END IF;


        IF l_debug_on THEN
            wsh_debug_sv.pop(l_module_name);
        END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => fnd_api.g_false);
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Error Processing Shipment Advice ');
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
        END IF;
    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.count_and_get(p_count   => x_msg_count,
                                  p_data    => x_msg_data,
                                  p_encoded => fnd_api.g_false);
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;

END Process_Shipment_Advice;

--========================================================================
-- PROCEDURE : Debug_Shipment_Advice PRIVATE
--
-- PARAMETERS:
--             p_delivery_rec
--
-- COMMENT   : Reads all the inforamtion in 'p_delivery_rec' and writes to
--             debug log file.
--========================================================================


PROCEDURE Debug_Shipment_Advice(
                p_delivery_rec           IN  Delivery_Rec_Type) IS

    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Debug_Shipment_Advice';
BEGIN

            WSH_DEBUG_SV.push(l_module_name);
            WSH_DEBUG_SV.logmsg(l_module_name,'Delivery Rec Information for document '||p_delivery_rec.document_number);
            WSH_DEBUG_SV.logmsg(l_module_name,'-------------------------------------------------------------------');
            WSH_DEBUG_SV.logmsg(l_module_name,'-------------------------------------------------------------------');
            WSH_DEBUG_SV.log(l_module_name,'document_number',p_delivery_rec.document_number);
            WSH_DEBUG_SV.log(l_module_name,'name',p_delivery_rec.name);
            WSH_DEBUG_SV.log(l_module_name,'organization_code',p_delivery_rec.organization_code);
            WSH_DEBUG_SV.log(l_module_name,'customer_name',p_delivery_rec.customer_name);
            WSH_DEBUG_SV.log(l_module_name,'delivered_date',p_delivery_rec.delivered_date);
            WSH_DEBUG_SV.log(l_module_name,'description',p_delivery_rec.description);
            WSH_DEBUG_SV.log(l_module_name,'shipment_direction',p_delivery_rec.shipment_direction);
            WSH_DEBUG_SV.log(l_module_name,'carrier_code',p_delivery_rec.carrier_code);
            WSH_DEBUG_SV.log(l_module_name,'fob_code',p_delivery_rec.fob_code);
            WSH_DEBUG_SV.log(l_module_name,'freight_terms_code',p_delivery_rec.freight_terms_code);
            WSH_DEBUG_SV.log(l_module_name,'gross_weight',p_delivery_rec.gross_weight);
            WSH_DEBUG_SV.log(l_module_name,'net_weight',p_delivery_rec.net_weight);
            WSH_DEBUG_SV.log(l_module_name,'weight_uom_code',p_delivery_rec.weight_uom_code);
            WSH_DEBUG_SV.log(l_module_name,'volume',p_delivery_rec.volume);
            WSH_DEBUG_SV.log(l_module_name,'volume_uom_code',p_delivery_rec.volume_uom_code);
            WSH_DEBUG_SV.log(l_module_name,'initial_pickup_date',p_delivery_rec.initial_pickup_date);
            WSH_DEBUG_SV.log(l_module_name,'loading_sequence',p_delivery_rec.loading_sequence);
            WSH_DEBUG_SV.log(l_module_name,'number_of_lpn',p_delivery_rec.number_of_lpn);
            WSH_DEBUG_SV.log(l_module_name,'shipping_marks',p_delivery_rec.shipping_marks);
            WSH_DEBUG_SV.log(l_module_name,'ultimate_dropoff_date',p_delivery_rec.ultimate_dropoff_date);
            WSH_DEBUG_SV.log(l_module_name,'waybill',p_delivery_rec.waybill);
            WSH_DEBUG_SV.log(l_module_name,'service_level',p_delivery_rec.service_level);
            WSH_DEBUG_SV.log(l_module_name,'mode_of_transport',p_delivery_rec.mode_of_transport);
            WSH_DEBUG_SV.log(l_module_name,'wv_frozen_flag',p_delivery_rec.wv_frozen_flag);
            WSH_DEBUG_SV.log(l_module_name,'attribute_category',p_delivery_rec.attribute_category);
            WSH_DEBUG_SV.log(l_module_name,'attribute1',p_delivery_rec.attribute1);
            WSH_DEBUG_SV.log(l_module_name,'attribute2',p_delivery_rec.attribute2);
            WSH_DEBUG_SV.log(l_module_name,'attribute3',p_delivery_rec.attribute3);
            WSH_DEBUG_SV.log(l_module_name,'attribute4',p_delivery_rec.attribute4);
            WSH_DEBUG_SV.log(l_module_name,'attribute5',p_delivery_rec.attribute5);
            WSH_DEBUG_SV.log(l_module_name,'attribute6',p_delivery_rec.attribute6);
            WSH_DEBUG_SV.log(l_module_name,'attribute7',p_delivery_rec.attribute7);
            WSH_DEBUG_SV.log(l_module_name,'attribute8',p_delivery_rec.attribute8);
            WSH_DEBUG_SV.log(l_module_name,'attribute9',p_delivery_rec.attribute9);
            WSH_DEBUG_SV.log(l_module_name,'attribute10',p_delivery_rec.attribute10);
            WSH_DEBUG_SV.log(l_module_name,'attribute11',p_delivery_rec.attribute11);
            WSH_DEBUG_SV.log(l_module_name,'attribute12',p_delivery_rec.attribute12);
            WSH_DEBUG_SV.log(l_module_name,'attribute13',p_delivery_rec.attribute13);
            WSH_DEBUG_SV.log(l_module_name,'attribute14',p_delivery_rec.attribute14);
            WSH_DEBUG_SV.log(l_module_name,'attribute15',p_delivery_rec.attribute15);
            WSH_DEBUG_SV.log(l_module_name,'SHIP_TO_CUSTOMER_NAME',p_delivery_rec.SHIP_TO_CUSTOMER_NAME);
            WSH_DEBUG_SV.log(l_module_name,'SHIP_TO_ADDRESS1',p_delivery_rec.SHIP_TO_ADDRESS1);
            WSH_DEBUG_SV.log(l_module_name,'SHIP_TO_ADDRESS2',p_delivery_rec.SHIP_TO_ADDRESS2);
            WSH_DEBUG_SV.log(l_module_name,'SHIP_TO_ADDRESS3',p_delivery_rec.SHIP_TO_ADDRESS3);
            WSH_DEBUG_SV.log(l_module_name,'SHIP_TO_ADDRESS4',p_delivery_rec.SHIP_TO_ADDRESS4);
            WSH_DEBUG_SV.log(l_module_name,'SHIP_TO_CITY',p_delivery_rec.SHIP_TO_CITY);
            WSH_DEBUG_SV.log(l_module_name,'SHIP_TO_STATE',p_delivery_rec.SHIP_TO_STATE);
            WSH_DEBUG_SV.log(l_module_name,'SHIP_TO_COUNTRY',p_delivery_rec.SHIP_TO_COUNTRY);
            WSH_DEBUG_SV.log(l_module_name,'SHIP_TO_POSTAL_CODE',p_delivery_rec.SHIP_TO_POSTAL_CODE);
            WSH_DEBUG_SV.logmsg(l_module_name,'-------------------------------------------------------------------');

            WSH_DEBUG_SV.logmsg(l_module_name,'    -------------------------------------------------------------------');
            WSH_DEBUG_SV.logmsg(l_module_name,'    WSH_TRIP_STOPS_INTERFACE info');
            WSH_DEBUG_SV.log(l_module_name,'    actual_departure_date',p_delivery_rec.actual_departure_date);
            WSH_DEBUG_SV.log(l_module_name,'    actual_arrival_date',p_delivery_rec.actual_arrival_date);
            WSH_DEBUG_SV.log(l_module_name,'    departure_seal_code',p_delivery_rec.departure_seal_code);
            WSH_DEBUG_SV.logmsg(l_module_name,'    -------------------------------------------------------------------');

            WSH_DEBUG_SV.logmsg(l_module_name,'    -------------------------------------------------------------------');
            WSH_DEBUG_SV.logmsg(l_module_name,'    WSH_TRIPS_INTERFACE info');
            WSH_DEBUG_SV.log(l_module_name,'    vehicle_number',p_delivery_rec.vehicle_number);
            WSH_DEBUG_SV.log(l_module_name,'    vehicle_num_prefix',p_delivery_rec.vehicle_num_prefix);
            WSH_DEBUG_SV.log(l_module_name,'    route_id',p_delivery_rec.route_id);
            WSH_DEBUG_SV.log(l_module_name,'    routing_instructions',p_delivery_rec.routing_instructions);
            WSH_DEBUG_SV.log(l_module_name,'    operator',p_delivery_rec.operator);
            WSH_DEBUG_SV.logmsg(l_module_name,'    -------------------------------------------------------------------');

            WSH_DEBUG_SV.log(l_module_name,'p_delivery_rec.delivery_freight_tab.count',p_delivery_rec.delivery_freight_tab.count);
            --WSH_FREIGHT_COSTS_INTERFACE info
            IF p_delivery_rec.delivery_freight_tab.count > 0 THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'    WSH_FREIGHT_COSTS_INTERFACE info for the delivery');
                WSH_DEBUG_SV.logmsg(l_module_name,'    -------------------------------------------------------------------');
                FOR k in 1..p_delivery_rec.delivery_freight_tab.count LOOP
                    WSH_DEBUG_SV.log(l_module_name,'    freight_cost_type_code',p_delivery_rec.delivery_freight_tab(k).freight_cost_type_code);
                    WSH_DEBUG_SV.log(l_module_name,'    unit_amount',p_delivery_rec.delivery_freight_tab(k).unit_amount);
                    WSH_DEBUG_SV.log(l_module_name,'    currency_code',p_delivery_rec.delivery_freight_tab(k).currency_code);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute_category',p_delivery_rec.delivery_freight_tab(k).attribute_category);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute1',p_delivery_rec.delivery_freight_tab(k).attribute1);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute2',p_delivery_rec.delivery_freight_tab(k).attribute2);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute3',p_delivery_rec.delivery_freight_tab(k).attribute3);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute4',p_delivery_rec.delivery_freight_tab(k).attribute4);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute5',p_delivery_rec.delivery_freight_tab(k).attribute5);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute6',p_delivery_rec.delivery_freight_tab(k).attribute6);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute7',p_delivery_rec.delivery_freight_tab(k).attribute7);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute8',p_delivery_rec.delivery_freight_tab(k).attribute8);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute9',p_delivery_rec.delivery_freight_tab(k).attribute9);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute10',p_delivery_rec.delivery_freight_tab(k).attribute10);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute11',p_delivery_rec.delivery_freight_tab(k).attribute11);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute12',p_delivery_rec.delivery_freight_tab(k).attribute12);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute13',p_delivery_rec.delivery_freight_tab(k).attribute13);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute14',p_delivery_rec.delivery_freight_tab(k).attribute14);
                    WSH_DEBUG_SV.log(l_module_name,'    attribute15',p_delivery_rec.delivery_freight_tab(k).attribute15);
                END LOOP;
            END IF;
            WSH_DEBUG_SV.log(l_module_name,'delivery_details_tab.count',p_delivery_rec.delivery_details_tab.count);
            IF p_delivery_rec.delivery_details_tab.count > 0 THEN --Delivery details count
            --{
                WSH_DEBUG_SV.logmsg(l_module_name,'        WSH_DEL_DETAILS_INTERFACE info for the delivery');
                WSH_DEBUG_SV.logmsg(l_module_name,'        -------------------------------------------------------------------');

                FOR I in 1..p_delivery_rec.delivery_details_tab.count LOOP
                --{
                    WSH_DEBUG_SV.log(l_module_name,'        delivery_detail_number',p_delivery_rec.delivery_details_tab(I).delivery_detail_number);
                    WSH_DEBUG_SV.log(l_module_name,'        source_line_id',p_delivery_rec.delivery_details_tab(I).source_line_id);
                    WSH_DEBUG_SV.log(l_module_name,'        source_header_number',p_delivery_rec.delivery_details_tab(I).source_header_number);
                    WSH_DEBUG_SV.log(l_module_name,'        item_number',p_delivery_rec.delivery_details_tab(I).item_number);
                    WSH_DEBUG_SV.log(l_module_name,'        item_description',p_delivery_rec.delivery_details_tab(I).item_description);
                    WSH_DEBUG_SV.log(l_module_name,'        line_direction',p_delivery_rec.delivery_details_tab(I).line_direction);
                    WSH_DEBUG_SV.log(l_module_name,'        gross_weight',p_delivery_rec.delivery_details_tab(I).gross_weight);
                    WSH_DEBUG_SV.log(l_module_name,'        net_weight',p_delivery_rec.delivery_details_tab(I).net_weight);
                    WSH_DEBUG_SV.log(l_module_name,'        weight_uom_code',p_delivery_rec.delivery_details_tab(I).weight_uom_code);
                    WSH_DEBUG_SV.log(l_module_name,'        volume',p_delivery_rec.delivery_details_tab(I).volume);
                    WSH_DEBUG_SV.log(l_module_name,'        volume_uom_code',p_delivery_rec.delivery_details_tab(I).volume_uom_code);
                    WSH_DEBUG_SV.log(l_module_name,'        wv_frozen_flag',p_delivery_rec.delivery_details_tab(I).wv_frozen_flag);
                    WSH_DEBUG_SV.log(l_module_name,'        requested_quantity',p_delivery_rec.delivery_details_tab(I).requested_quantity);
                    WSH_DEBUG_SV.log(l_module_name,'        requested_quantity_uom',p_delivery_rec.delivery_details_tab(I).requested_quantity_uom);
                    WSH_DEBUG_SV.log(l_module_name,'        shipped_quantity',p_delivery_rec.delivery_details_tab(I).shipped_quantity);
                    WSH_DEBUG_SV.log(l_module_name,'        cycle_count_quantity',p_delivery_rec.delivery_details_tab(I).cycle_count_quantity);
                    WSH_DEBUG_SV.log(l_module_name,'        subinventory',p_delivery_rec.delivery_details_tab(I).subinventory);
                    WSH_DEBUG_SV.log(l_module_name,'        locator_code',p_delivery_rec.delivery_details_tab(I).locator_code);
                    WSH_DEBUG_SV.log(l_module_name,'        lot_number',p_delivery_rec.delivery_details_tab(I).lot_number);
                    WSH_DEBUG_SV.log(l_module_name,'        revision',p_delivery_rec.delivery_details_tab(I).revision);
                    WSH_DEBUG_SV.log(l_module_name,'        serial_number',p_delivery_rec.delivery_details_tab(I).serial_number);
                    WSH_DEBUG_SV.log(l_module_name,'        to_serial_number',p_delivery_rec.delivery_details_tab(I).to_serial_number);
                    WSH_DEBUG_SV.log(l_module_name,'        load_seq_number',p_delivery_rec.delivery_details_tab(I).load_seq_number);
                    WSH_DEBUG_SV.log(l_module_name,'        preferred_grade',p_delivery_rec.delivery_details_tab(I).preferred_grade);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute_category',p_delivery_rec.delivery_details_tab(I).attribute_category);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute1',p_delivery_rec.delivery_details_tab(I).attribute1);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute2',p_delivery_rec.delivery_details_tab(I).attribute2);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute3',p_delivery_rec.delivery_details_tab(I).attribute3);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute4',p_delivery_rec.delivery_details_tab(I).attribute4);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute5',p_delivery_rec.delivery_details_tab(I).attribute5);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute6',p_delivery_rec.delivery_details_tab(I).attribute6);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute7',p_delivery_rec.delivery_details_tab(I).attribute7);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute8',p_delivery_rec.delivery_details_tab(I).attribute8);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute9',p_delivery_rec.delivery_details_tab(I).attribute9);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute10',p_delivery_rec.delivery_details_tab(I).attribute10);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute11',p_delivery_rec.delivery_details_tab(I).attribute11);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute12',p_delivery_rec.delivery_details_tab(I).attribute12);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute13',p_delivery_rec.delivery_details_tab(I).attribute13);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute14',p_delivery_rec.delivery_details_tab(I).attribute14);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute15',p_delivery_rec.delivery_details_tab(I).attribute15);
                    WSH_DEBUG_SV.log(l_module_name,'        parent_delivery_detail_number',p_delivery_rec.delivery_details_tab(I).parent_delivery_detail_number);

                    WSH_DEBUG_SV.log(l_module_name,'        Detail_Freight_tab_count',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab.count);
                    IF p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab.count > 0 THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'            -----------------------------------------------------------');
                            WSH_DEBUG_SV.logmsg(l_module_name,'            ---------------Details Freight Cost Details----------------');
                        FOR k in 1..p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab.count LOOP

                            WSH_DEBUG_SV.log(l_module_name,'            freight_cost_type_code',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).freight_cost_type_code);
                            WSH_DEBUG_SV.log(l_module_name,'            unit_amount',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).unit_amount);
                            WSH_DEBUG_SV.log(l_module_name,'            currency_code',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).currency_code);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute_category',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute_category);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute1',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute1);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute2',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute2);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute3',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute3);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute4',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute4);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute5',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute5);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute6',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute6);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute7',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute7);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute8',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute8);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute9',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute9);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute10',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute10);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute11',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute11);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute12',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute12);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute13',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute13);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute14',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute14);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute15',p_delivery_rec.delivery_details_tab(I).Detail_Freight_Tab(k).attribute15);
                            WSH_DEBUG_SV.logmsg(l_module_name,'            -----------------------------------------------------------');
                        END LOOP;
                    END IF;
                --}
                END LOOP;
            END IF;

            WSH_DEBUG_SV.log(l_module_name,'Master_container_tab.count',p_delivery_rec.container_tab.count);
            IF p_delivery_rec.container_tab.count > 0 THEN --Delivery details count
            --{
                WSH_DEBUG_SV.logmsg(l_module_name,'     -------------------------------------------------------------------');
                WSH_DEBUG_SV.logmsg(l_module_name,'     WSH_DEL_DETAILS_INTERFACE(Master Containers) info for the delivery');

                FOR I in 1..p_delivery_rec.container_tab.count LOOP
                --{
                    WSH_DEBUG_SV.log(l_module_name,'        delivery_detail_number',p_delivery_rec.container_tab(i).delivery_detail_number);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute_category',p_delivery_rec.container_tab(i).attribute_category);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute1',p_delivery_rec.container_tab(i).attribute1);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute2',p_delivery_rec.container_tab(i).attribute2);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute3',p_delivery_rec.container_tab(i).attribute3);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute4',p_delivery_rec.container_tab(i).attribute4);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute5',p_delivery_rec.container_tab(i).attribute5);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute6',p_delivery_rec.container_tab(i).attribute6);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute7',p_delivery_rec.container_tab(i).attribute7);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute8',p_delivery_rec.container_tab(i).attribute8);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute9',p_delivery_rec.container_tab(i).attribute9);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute10',p_delivery_rec.container_tab(i).attribute10);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute11',p_delivery_rec.container_tab(i).attribute11);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute12',p_delivery_rec.container_tab(i).attribute12);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute13',p_delivery_rec.container_tab(i).attribute13);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute14',p_delivery_rec.container_tab(i).attribute14);
                    WSH_DEBUG_SV.log(l_module_name,'        attribute15',p_delivery_rec.container_tab(i).attribute15);
                    WSH_DEBUG_SV.log(l_module_name,'        container_name ',p_delivery_rec.container_tab(i).container_name );
                    WSH_DEBUG_SV.log(l_module_name,'        item_number',p_delivery_rec.container_tab(i).item_number);
                    WSH_DEBUG_SV.log(l_module_name,'        item_description',p_delivery_rec.container_tab(i).item_description);
                    WSH_DEBUG_SV.log(l_module_name,'        gross_weight',p_delivery_rec.container_tab(i).gross_weight);
                    WSH_DEBUG_SV.log(l_module_name,'        net_weight',p_delivery_rec.container_tab(i).net_weight);
                    WSH_DEBUG_SV.log(l_module_name,'        weight_uom_code',p_delivery_rec.container_tab(i).weight_uom_code);
                    WSH_DEBUG_SV.log(l_module_name,'        volume',p_delivery_rec.container_tab(i).volume);
                    WSH_DEBUG_SV.log(l_module_name,'        volume_uom_code',p_delivery_rec.container_tab(i).volume_uom_code);
                    WSH_DEBUG_SV.log(l_module_name,'        wv_frozen_flag',p_delivery_rec.container_tab(i).wv_frozen_flag);
                    WSH_DEBUG_SV.log(l_module_name,'        filled_volume',p_delivery_rec.container_tab(i).filled_volume);
                    WSH_DEBUG_SV.log(l_module_name,'        fill_percent',p_delivery_rec.container_tab(i).fill_percent);
                    WSH_DEBUG_SV.log(l_module_name,'        seal_code',p_delivery_rec.container_tab(i).seal_code);
                    WSH_DEBUG_SV.log(l_module_name,'        packing_instructions',p_delivery_rec.container_tab(i).packing_instructions);
                    WSH_DEBUG_SV.log(l_module_name,'        shipping_instructions',p_delivery_rec.container_tab(i).shipping_instructions);
                    WSH_DEBUG_SV.log(l_module_name,'        tracking_number',p_delivery_rec.container_tab(i).tracking_number);
                    WSH_DEBUG_SV.logmsg(l_module_name,'     -------------------------------------------------------------------');
                    WSH_DEBUG_SV.log(l_module_name,'        Master_Container_Freight_Tab.count',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab.count);
                    IF p_delivery_rec.container_tab(i).Master_Container_Freight_Tab.count >0 THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'         -------------------------------------------------------------------');
                        WSH_DEBUG_SV.logmsg(l_module_name,'            Master_Container_Freight_Tab Details');
                        WSH_DEBUG_SV.logmsg(l_module_name,'            -------------------------------------------------------------------');

                        FOR K in 1..p_delivery_rec.container_tab(i).Master_Container_Freight_Tab.count  LOOP
                            WSH_DEBUG_SV.log(l_module_name,'            freight_cost_type_code',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).freight_cost_type_code);
                            WSH_DEBUG_SV.log(l_module_name,'            unit_amount ',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).unit_amount );
                            WSH_DEBUG_SV.log(l_module_name,'            currency_code',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).currency_code);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute_category',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute_category);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute1',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute1);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute2',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute2);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute3',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute3);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute4',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute4);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute5',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute5);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute6',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute6);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute7',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute7);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute8',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute8);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute9',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute9);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute10',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute10);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute11',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute11);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute12',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute12);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute13',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute13);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute14',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute14);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute15',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).attribute15);
                            WSH_DEBUG_SV.log(l_module_name,'            unit_amount ',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).unit_amount );
                            WSH_DEBUG_SV.log(l_module_name,'            currency_code',p_delivery_rec.container_tab(i).Master_Container_Freight_Tab(K).currency_code);
                            WSH_DEBUG_SV.logmsg(l_module_name,'            -------------------------------------------------------------------');
                        END LOOP;
                    END IF;

                    WSH_DEBUG_SV.log(l_module_name,'        ',p_delivery_rec.container_tab(i).Container_Tab.count);

                    IF p_delivery_rec.container_tab(i).Container_Tab.count >0 THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'         -------------------------------------------------------------------');
                        WSH_DEBUG_SV.logmsg(l_module_name,'            Inner Containers Details');
                        WSH_DEBUG_SV.logmsg(l_module_name,'            -------------------------------------------------------------------');

                        FOR K in 1..p_delivery_rec.container_tab(i).Container_Tab.count  LOOP
                            WSH_DEBUG_SV.log(l_module_name,'            delivery_detail_number',p_delivery_rec.container_tab(i).container_tab(k).delivery_detail_number);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute_category',p_delivery_rec.container_tab(i).container_tab(k).attribute_category);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute1',p_delivery_rec.container_tab(i).container_tab(k).attribute1);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute2',p_delivery_rec.container_tab(i).container_tab(k).attribute2);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute3',p_delivery_rec.container_tab(i).container_tab(k).attribute3);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute4',p_delivery_rec.container_tab(i).container_tab(k).attribute4);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute5',p_delivery_rec.container_tab(i).container_tab(k).attribute5);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute6',p_delivery_rec.container_tab(i).container_tab(k).attribute6);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute7',p_delivery_rec.container_tab(i).container_tab(k).attribute7);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute8',p_delivery_rec.container_tab(i).container_tab(k).attribute8);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute9',p_delivery_rec.container_tab(i).container_tab(k).attribute9);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute10',p_delivery_rec.container_tab(i).container_tab(k).attribute10);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute11',p_delivery_rec.container_tab(i).container_tab(k).attribute11);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute12',p_delivery_rec.container_tab(i).container_tab(k).attribute12);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute13',p_delivery_rec.container_tab(i).container_tab(k).attribute13);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute14',p_delivery_rec.container_tab(i).container_tab(k).attribute14);
                            WSH_DEBUG_SV.log(l_module_name,'            attribute15',p_delivery_rec.container_tab(i).container_tab(k).attribute15);
                            WSH_DEBUG_SV.log(l_module_name,'            container_name ',p_delivery_rec.container_tab(i).container_tab(k).container_name );
                            WSH_DEBUG_SV.log(l_module_name,'            item_number',p_delivery_rec.container_tab(i).container_tab(k).item_number);
                            WSH_DEBUG_SV.log(l_module_name,'            item_description',p_delivery_rec.container_tab(i).container_tab(k).item_description);
                            WSH_DEBUG_SV.log(l_module_name,'            gross_weight',p_delivery_rec.container_tab(i).container_tab(k).gross_weight);
                            WSH_DEBUG_SV.log(l_module_name,'            net_weight',p_delivery_rec.container_tab(i).container_tab(k).net_weight);
                            WSH_DEBUG_SV.log(l_module_name,'            weight_uom_code',p_delivery_rec.container_tab(i).container_tab(k).weight_uom_code);
                            WSH_DEBUG_SV.log(l_module_name,'            volume',p_delivery_rec.container_tab(i).container_tab(k).volume);
                            WSH_DEBUG_SV.log(l_module_name,'            volume_uom_code',p_delivery_rec.container_tab(i).container_tab(k).volume_uom_code);
                            WSH_DEBUG_SV.log(l_module_name,'            wv_frozen_flag',p_delivery_rec.container_tab(i).container_tab(k).wv_frozen_flag);
                            WSH_DEBUG_SV.log(l_module_name,'            filled_volume',p_delivery_rec.container_tab(i).container_tab(k).filled_volume);
                            WSH_DEBUG_SV.log(l_module_name,'            fill_percent',p_delivery_rec.container_tab(i).container_tab(k).fill_percent);
                            WSH_DEBUG_SV.log(l_module_name,'            seal_code',p_delivery_rec.container_tab(i).container_tab(k).seal_code);
                            WSH_DEBUG_SV.log(l_module_name,'            packing_instructions',p_delivery_rec.container_tab(i).container_tab(k).packing_instructions);
                            WSH_DEBUG_SV.log(l_module_name,'            shipping_instructions',p_delivery_rec.container_tab(i).container_tab(k).shipping_instructions);
                            WSH_DEBUG_SV.log(l_module_name,'            tracking_number',p_delivery_rec.container_tab(i).container_tab(k).tracking_number);
                            WSH_DEBUG_SV.logmsg(l_module_name,'            -------------------------------------------------------------------');

                            WSH_DEBUG_SV.log(l_module_name,'        Inner Container Freight costs.count',p_delivery_rec.container_tab(i).container_tab(k).Container_Freight_Tab.count);
                            IF p_delivery_rec.container_tab(i).container_tab(k).Container_Freight_Tab.count >0 THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'                -------------------------------------------------------------------');
                                WSH_DEBUG_SV.logmsg(l_module_name,'                Inner Container Freight costs Details');
                                WSH_DEBUG_SV.logmsg(l_module_name,'                -------------------------------------------------------------------');

                                FOR l in 1..p_delivery_rec.container_tab(i).container_tab(k).Container_Freight_Tab.count  LOOP
                                    WSH_DEBUG_SV.log(l_module_name,'                freight_cost_type_code',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).freight_cost_type_code);
                                    WSH_DEBUG_SV.log(l_module_name,'                unit_amount ',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).unit_amount );
                                    WSH_DEBUG_SV.log(l_module_name,'                currency_code',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).currency_code);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute_category',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute_category);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute1',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute1);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute2',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute2);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute3',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute3);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute4',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute4);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute5',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute5);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute6',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute6);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute7',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute7);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute8',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute8);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute9',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute9);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute10',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute10);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute11',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute11);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute12',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute12);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute13',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute13);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute14',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute14);
                                    WSH_DEBUG_SV.log(l_module_name,'                attribute15',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).attribute15);
                                    WSH_DEBUG_SV.log(l_module_name,'                unit_amount ',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).unit_amount );
                                    WSH_DEBUG_SV.log(l_module_name,'                currency_code',p_delivery_rec.container_tab(i).Container_Tab(k).Container_Freight_Tab(l).currency_code);
                                    WSH_DEBUG_SV.logmsg(l_module_name,'                -------------------------------------------------------------------');
                                END LOOP;
                            END IF;
                        END LOOP;
                    END IF;

                --}
                END LOOP;
            END IF;
                wsh_debug_sv.pop(l_module_name);
EXCEPTION
    WHEN OTHERS THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Error in '||l_module_name, WSH_DEBUG_SV.C_STMT_LEVEL);
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        wsh_debug_sv.pop(l_module_name);

END Debug_Shipment_Advice;


END WSH_SHIPMENT_ADVICE_PUB;


/
