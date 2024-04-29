--------------------------------------------------------
--  DDL for Package WSH_INTERFACE_EXT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_INTERFACE_EXT_GRP" AUTHID CURRENT_USER as
/* $Header: WSHEXGPS.pls 120.4 2007/12/21 14:57:57 mvudugul noship $ */


--lpn conv
FUNCTION Handle_missing_info
                  (p_value        IN  NUMBER,
                   p_entity       IN  VARCHAR2 DEFAULT NULL,
                   p_action       IN  VARCHAR2 DEFAULT NULL
                  ) RETURN NUMBER;
FUNCTION Handle_missing_info
                  (p_value        IN  VARCHAR2,
                   p_entity       IN  VARCHAR2 DEFAULT NULL,
                   p_action       IN  VARCHAR2 DEFAULT NULL
                  ) RETURN VARCHAR2;
FUNCTION Handle_missing_info
                  (p_value        IN  DATE,
                   p_entity       IN  VARCHAR2 DEFAULT NULL,
                   p_action       IN  VARCHAR2 DEFAULT NULL
                  ) RETURN DATE;
/***************************************************************************************************
*				IMPORTANT  NOTE
*
* While calling following API, please use FND_API.G_MISS_XXXX to set the value to NULL.
* API				Parameter
* --				---------
* Create_Update_Delivery 	p_rec_attr_tab
* Create_Update_Delivery_Detail	p_detail_info_tab
* Create_Update_Trip		p_trip_info_tab
* Create_Update_Stop		p_rec_attr_tab
* Create_Update_Freight_Costs	p_freight_info_tab
***************************************************************************************************/

--===================
-- PUBLIC VARS
--===================
TYPE del_action_parameters_rectype is RECORD (
  caller      VARCHAR2(50),
  phase     NUMBER,
  action_code   VARCHAR2(30),
  trip_id           NUMBER ,         --|
  trip_name   VARCHAR2(30) ,   --|
  pickup_stop_id    NUMBER ,         --|
  pickup_loc_id   NUMBER ,         --|
  pickup_stop_seq   NUMBER ,         --|
  pickup_loc_code   VARCHAR2(80) ,  --|
  pickup_arr_date   DATE   ,         --|   All these parameters
  pickup_dep_date   DATE   ,         --|   are used for the
        pickup_stop_status      VARCHAR2(2),     --|
  dropoff_stop_id   NUMBER ,         --|   Action
  dropoff_loc_id    NUMBER ,         --|   'UNASSIGN-TRIP'
  dropoff_stop_seq  NUMBER ,         --|
  dropoff_loc_code  VARCHAR2(80) ,  --|
  dropoff_arr_date  DATE   ,         --|
  dropoff_dep_date  DATE ,           --|
        dropoff_stop_status     VARCHAR2(2),     --|
  action_flag   VARCHAR2(1),
  intransit_flag    VARCHAR2(1),
  close_trip_flag   VARCHAR2(1) ,
  stage_del_flag    VARCHAR2(1),
  bill_of_lading_flag VARCHAR2(1),
  mc_bill_of_lading_flag  VARCHAR2(1),
  override_flag   VARCHAR2(1),
  defer_interface_flag  VARCHAR2(1),
  ship_method_code  VARCHAR2(240) ,
  actual_dep_date   DATE     ,
  report_set_id   NUMBER ,
  report_set_name   VARCHAR2(30) ,
  send_945_flag   VARCHAR2(1) ,
  action_type   VARCHAR2(1) ,
  document_type   VARCHAR2(2) ,
  organization_id   NUMBER ,
  reason_of_transport VARCHAR2(30),
  description   VARCHAR2(30),
  event         VARCHAR2(1) /* Pack J deliveryMerge */ );



TYPE Del_Action_Out_Rec_Type is RECORD (
  packing_slip_number VARCHAR2(50),
  valid_ids_tab           wsh_util_core.id_tab_type,
  result_id_tab           wsh_util_core.id_tab_type,
  selection_issue_flag    VARCHAR2(1)
  );


TYPE Del_In_Rec_Type is RECORD (
  caller      VARCHAR2(50),
  phase       NUMBER,
  action_code     VARCHAR2(30));

TYPE Del_Out_Rec_Type is RECORD (
  delivery_id   NUMBER,
  name      VARCHAR2(30),
        rowid                   VARCHAR2(4000));

TYPE Del_Out_Tbl_Type IS Table of Del_Out_Rec_Type INDEX BY BINARY_INTEGER;


TYPE Delivery_Rec_Type IS RECORD (
        DELIVERY_ID                     NUMBER,
        NAME                            VARCHAR2(30),
        PLANNED_FLAG                    VARCHAR2(1),
        STATUS_CODE                     VARCHAR2(2),
        DELIVERY_TYPE                   VARCHAR2(30),
        LOADING_SEQUENCE                NUMBER,
        LOADING_ORDER_FLAG              VARCHAR2(2),
        INITIAL_PICKUP_DATE             DATE,
        INITIAL_PICKUP_LOCATION_ID      NUMBER,
        ORGANIZATION_ID                 NUMBER,
        ULTIMATE_DROPOFF_LOCATION_ID    NUMBER,
        ULTIMATE_DROPOFF_DATE           DATE,
        CUSTOMER_ID                     NUMBER,
        INTMED_SHIP_TO_LOCATION_ID      NUMBER,
        POOLED_SHIP_TO_LOCATION_ID      NUMBER,
        CARRIER_ID                      NUMBER,
        SHIP_METHOD_CODE                VARCHAR2(30),
        FREIGHT_TERMS_CODE              VARCHAR2(30),
        FOB_CODE                        VARCHAR2(30),
        FOB_LOCATION_ID                 NUMBER,
        WAYBILL                         VARCHAR2(30),
        DOCK_CODE                       VARCHAR2(30),
        ACCEPTANCE_FLAG                 VARCHAR2(1),
        ACCEPTED_BY                     VARCHAR2(150),
        ACCEPTED_DATE                   DATE,
        ACKNOWLEDGED_BY                 VARCHAR2(150),
        CONFIRMED_BY                    VARCHAR2(150),
        CONFIRM_DATE                    DATE,
        ASN_DATE_SENT                   DATE,
        ASN_STATUS_CODE                 VARCHAR2(15),
        ASN_SEQ_NUMBER                  NUMBER,
        GROSS_WEIGHT                    NUMBER,
        NET_WEIGHT                      NUMBER,
        WEIGHT_UOM_CODE                 VARCHAR2(3),
        VOLUME                          NUMBER,
        VOLUME_UOM_CODE                 VARCHAR2(3),
        ADDITIONAL_SHIPMENT_INFO        VARCHAR2(500),
        CURRENCY_CODE                   VARCHAR2(15),
        ATTRIBUTE_CATEGORY              VARCHAR2(150),
        ATTRIBUTE1                      VARCHAR2(150),
        ATTRIBUTE2                      VARCHAR2(150),
        ATTRIBUTE3                      VARCHAR2(150),
        ATTRIBUTE4                      VARCHAR2(150),
        ATTRIBUTE5                      VARCHAR2(150),
        ATTRIBUTE6                      VARCHAR2(150),
        ATTRIBUTE7                      VARCHAR2(150),
        ATTRIBUTE8                      VARCHAR2(150),
        ATTRIBUTE9                      VARCHAR2(150),
        ATTRIBUTE10                     VARCHAR2(150),
        ATTRIBUTE11                     VARCHAR2(150),
        ATTRIBUTE12                     VARCHAR2(150),
        ATTRIBUTE13                     VARCHAR2(150),
        ATTRIBUTE14                     VARCHAR2(150),
        ATTRIBUTE15                     VARCHAR2(150),
        TP_ATTRIBUTE_CATEGORY           VARCHAR2(150),
        TP_ATTRIBUTE1                   VARCHAR2(150),
        TP_ATTRIBUTE2                   VARCHAR2(150),
        TP_ATTRIBUTE3                   VARCHAR2(150),
        TP_ATTRIBUTE4                   VARCHAR2(150),
        TP_ATTRIBUTE5                   VARCHAR2(150),
        TP_ATTRIBUTE6                   VARCHAR2(150),
        TP_ATTRIBUTE7                   VARCHAR2(150),
        TP_ATTRIBUTE8                   VARCHAR2(150),
        TP_ATTRIBUTE9                   VARCHAR2(150),
        TP_ATTRIBUTE10                  VARCHAR2(150),
        TP_ATTRIBUTE11                  VARCHAR2(150),
        TP_ATTRIBUTE12                  VARCHAR2(150),
        TP_ATTRIBUTE13                  VARCHAR2(150),
        TP_ATTRIBUTE14                  VARCHAR2(150),
        TP_ATTRIBUTE15                  VARCHAR2(150),
        GLOBAL_ATTRIBUTE_CATEGORY       VARCHAR2(30),
        GLOBAL_ATTRIBUTE1               VARCHAR2(150),
        GLOBAL_ATTRIBUTE2               VARCHAR2(150),
        GLOBAL_ATTRIBUTE3               VARCHAR2(150),
        GLOBAL_ATTRIBUTE4               VARCHAR2(150),
        GLOBAL_ATTRIBUTE5               VARCHAR2(150),
        GLOBAL_ATTRIBUTE6               VARCHAR2(150),
        GLOBAL_ATTRIBUTE7               VARCHAR2(150),
        GLOBAL_ATTRIBUTE8               VARCHAR2(150),
        GLOBAL_ATTRIBUTE9               VARCHAR2(150),
        GLOBAL_ATTRIBUTE10              VARCHAR2(150),
        GLOBAL_ATTRIBUTE11              VARCHAR2(150),
        GLOBAL_ATTRIBUTE12              VARCHAR2(150),
        GLOBAL_ATTRIBUTE13              VARCHAR2(150),
        GLOBAL_ATTRIBUTE14              VARCHAR2(150),
        GLOBAL_ATTRIBUTE15              VARCHAR2(150),
        GLOBAL_ATTRIBUTE16              VARCHAR2(150),
        GLOBAL_ATTRIBUTE17              VARCHAR2(150),
        GLOBAL_ATTRIBUTE18              VARCHAR2(150),
        GLOBAL_ATTRIBUTE19              VARCHAR2(150),
        GLOBAL_ATTRIBUTE20              VARCHAR2(150),
        CREATION_DATE                   DATE,
        CREATED_BY                      NUMBER,
        LAST_UPDATE_DATE                DATE,
        LAST_UPDATED_BY                 NUMBER,
        LAST_UPDATE_LOGIN               NUMBER,
        PROGRAM_APPLICATION_ID          NUMBER,
        PROGRAM_ID                      NUMBER,
        PROGRAM_UPDATE_DATE             DATE,
        REQUEST_ID                      NUMBER,
        BATCH_ID                        NUMBER,
        HASH_VALUE                      NUMBER,
        SOURCE_HEADER_ID                NUMBER,
        NUMBER_OF_LPN                   NUMBER,--bugfix 1426086: added number_of_lpn
/* Changes for the Shipping Data Model Bug#1918342*/
        COD_AMOUNT                      NUMBER,
        COD_CURRENCY_CODE               VARCHAR2(15),
        COD_REMIT_TO                    VARCHAR2(150),
        COD_CHARGE_PAID_BY              VARCHAR2(150),
        PROBLEM_CONTACT_REFERENCE       VARCHAR2(500),
        PORT_OF_LOADING                 VARCHAR2(150),
        PORT_OF_DISCHARGE               VARCHAR2(150),
        FTZ_NUMBER                      VARCHAR2(35),
        ROUTED_EXPORT_TXN               VARCHAR2(1),
        ENTRY_NUMBER                    VARCHAR2(35),
        ROUTING_INSTRUCTIONS            VARCHAR2(120),
        IN_BOND_CODE                    VARCHAR2(35),
        SHIPPING_MARKS                  VARCHAR2(100),
/* H Integration: datamodel changes wrudge */
        SERVICE_LEVEL                   VARCHAR2(30),
        MODE_OF_TRANSPORT               VARCHAR2(30),
        ASSIGNED_TO_FTE_TRIPS           VARCHAR2(1),
/* I Quickship : datamodel changes sperera */
        AUTO_SC_EXCLUDE_FLAG            VARCHAR2(1),
        AUTO_AP_EXCLUDE_FLAG            VARCHAR2(1),
        AP_BATCH_ID                     NUMBER,
/* I Harmonization: Non database Columns added rvishnuv */
        ROWID                           VARCHAR2(4000),
        LOADING_ORDER_DESC              VARCHAR2(80),
        ORGANIZATION_CODE               VARCHAR2(3),
        ULTIMATE_DROPOFF_LOCATION_CODE  VARCHAR2(500),
        INITIAL_PICKUP_LOCATION_CODE    VARCHAR2(500),
        CUSTOMER_NUMBER                 VARCHAR2(30),
        INTMED_SHIP_TO_LOCATION_CODE    VARCHAR2(500),
        POOLED_SHIP_TO_LOCATION_CODE    VARCHAR2(500),
        CARRIER_CODE                    VARCHAR2(360),
        SHIP_METHOD_NAME                VARCHAR2(240),
        FREIGHT_TERMS_NAME              VARCHAR2(80),
        FOB_NAME                        VARCHAR2(80),
        FOB_LOCATION_CODE               VARCHAR2(500),
        WEIGHT_UOM_DESC                 VARCHAR2(25),
        VOLUME_UOM_DESC                 VARCHAR2(25),
        CURRENCY_NAME                   VARCHAR2(80),
/* J Inbound Logistics New columns jckwok */
        VENDOR_ID                       NUMBER,
        PARTY_ID                        NUMBER,
        SHIPMENT_DIRECTION              VARCHAR2(30),
        ROUTING_RESPONSE_ID             NUMBER,
        RCV_SHIPMENT_HEADER_ID          NUMBER,
        ASN_SHIPMENT_HEADER_ID          NUMBER,
        SHIPPING_CONTROL                VARCHAR2(30)
        );

TYPE Delivery_Attr_Tbl_Type is TABLE of Delivery_Rec_Type index by binary_integer;








--========================================================================
-- PROCEDURE : Delivery_Action         Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error number
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_action_prms           Record of caller, phase, action_code and other
--                                     parameters specific to the actions.
--	       p_rec_attr_tab          Table of Attributes for the delivery entity
--             x_delivery_out_rec      Record of output parameters based on the actions.
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This procedure is used to perform an action specified
--             in p_action_prms.action_code on an existing delivery identified
--             by p_rec_attr.delivery_id/p_rec_attr.name.
--========================================================================
  PROCEDURE Delivery_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_action_prms            IN   WSH_INTERFACE_EXT_GRP.del_action_parameters_rectype,
    p_delivery_id_tab        IN   wsh_util_core.id_tab_type,
    x_delivery_out_rec       OUT  NOCOPY WSH_INTERFACE_EXT_GRP.Del_Action_Out_Rec_Type,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2);
--========================================================================

-- I Harmonization: rvishnuv ******* Actions ******

-- I Harmonization: rvishnuv ******* Create/Update ******
--========================================================================
-- PROCEDURE : Create_Update_Delivery  Wrapper API      PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_in_rec                Record for caller, phase
--                                     and action_code ( CREATE-UPDATE )
--	       p_rec_attr_tab          Table of Attributes for the delivery entity
--  	       x_del_out_rec           Record of delivery_id, and name of new deliveries,
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or updates a record in wsh_new_deliveries table with information
--             specified in p_delivery_info
--========================================================================
/***************************************************************************************************
*				IMPORTANT  NOTE
*
* While calling this API, please use FND_API.G_MISS_XXXX to set the value to NULL for parameter
* p_rec_attr_tab.
***************************************************************************************************/
  PROCEDURE Create_Update_Delivery
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit		     IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_in_rec                 IN   WSH_INTERFACE_EXT_GRP.Del_In_Rec_Type,
    p_rec_attr_tab	     IN   WSH_INTERFACE_EXT_GRP.Delivery_Attr_Tbl_Type,
    x_del_out_rec_tab        OUT  NOCOPY WSH_INTERFACE_EXT_GRP.Del_Out_Tbl_Type,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2);
--========================================================================

-- I Harmonization: rvishnuv ******* Create/Update ******




        TYPE det_action_parameters_rec_type IS RECORD
        (
            -- Generic
            Caller              VARCHAR2(50),
            Action_Code         VARCHAR2(30),
            Phase               NUMBER,
            -- Assign/Unassign
            delivery_id   NUMBER ,
            delivery_name VARCHAR2(32767),
            -- Calculate weight and volume
            wv_override_flag  VARCHAR2(32767),
            -- Cycle Count
            quantity_to_split NUMBER,
            quantity2_to_split  NUMBER,
            -- Pack, Unpack
            container_name      VARCHAR2(32767),
            container_instance_id NUMBER,
            container_flag      VARCHAR2(1),
            delivery_flag       VARCHAR2(1),
            -- Autopack
            group_id_tab        wsh_util_core.id_tab_type,
            -- Split Line
            split_quantity        NUMBER,
            split_quantity2       NUMBER
            );
        --


    TYPE det_action_out_rec_type IS RECORD
       (
        valid_id_tab          WSH_UTIL_CORE.id_tab_type,
        selection_issue_flag  VARCHAR2(1),
        delivery_id_tab       WSH_UTIL_CORE.id_tab_type,
        result_id_tab         WSH_UTIL_CORE.id_tab_type,
        split_quantity        NUMBER,
        split_quantity2       NUMBER);

        --

       TYPE Det_actionsInOutRecType  IS RECORD
       (
          split_quantity   NUMBER,
          split_quantity2  NUMBER
       );



TYPE Delivery_Details_Rec_Type IS RECORD
        (delivery_detail_id                     NUMBER,
        source_code                             VARCHAR2(30),
        source_header_id                        NUMBER,
        source_line_id                          NUMBER,
        customer_id                             NUMBER,
        sold_to_contact_id                      NUMBER,
        inventory_item_id                       NUMBER,
        item_description                        VARCHAR2(250),
        hazard_class_id                 NUMBER,
        country_of_origin                       VARCHAR2(50),
        classification                          VARCHAR2(30),
        ship_from_location_id           NUMBER,
        ship_to_location_id                     NUMBER,
        ship_to_contact_id                      NUMBER,
        ship_to_site_use_id                     NUMBER,
        deliver_to_location_id          NUMBER,
        deliver_to_contact_id           NUMBER,
        deliver_to_site_use_id          NUMBER,
        intmed_ship_to_location_id      NUMBER,
        intmed_ship_to_contact_id       NUMBER,
        hold_code                                       VARCHAR2(1),
        ship_tolerance_above            NUMBER,
        ship_tolerance_below            NUMBER,
        requested_quantity                      NUMBER,
        shipped_quantity                        NUMBER,
        delivered_quantity                      NUMBER,
        requested_quantity_uom          VARCHAR2(3),
        subinventory                            VARCHAR2(10),
        revision                                        VARCHAR2(3),
-- HW OPMCONV. Need to expand length of lot_number to 80
        lot_number                              VARCHAR2(80),
        customer_requested_lot_flag     VARCHAR2(1),
        serial_number                           VARCHAR2(30),
        locator_id                              NUMBER,
        date_requested                          DATE,
        date_scheduled                          DATE,
        master_container_item_id                NUMBER,
        detail_container_item_id                NUMBER,
        load_seq_number                 NUMBER,
        ship_method_code                        VARCHAR2(30),
        carrier_id                              NUMBER,
        freight_terms_code                      VARCHAR2(30),
        shipment_priority_code          VARCHAR2(30),
        fob_code                                        VARCHAR2(30),
        customer_item_id                        NUMBER,
        dep_plan_required_flag          VARCHAR2(1),
        customer_prod_seq                       VARCHAR2(50),
        customer_dock_code                      VARCHAR2(50),
        cust_model_serial_number                VARCHAR2(50),
        customer_job                            VARCHAR2(50),
        customer_production_line                VARCHAR2(50),
        net_weight                              NUMBER,
        weight_uom_code                 VARCHAR2(3),
        volume                                  NUMBER,
        volume_uom_code                 VARCHAR2(3),
        tp_attribute_category           VARCHAR2(240),
        tp_attribute1                           VARCHAR2(240),
        tp_attribute2                           VARCHAR2(240),
        tp_attribute3                           VARCHAR2(240),
        tp_attribute4                           VARCHAR2(240),
        tp_attribute5                           VARCHAR2(240),
        tp_attribute6                           VARCHAR2(240),
        tp_attribute7                           VARCHAR2(240),
        tp_attribute8                           VARCHAR2(240),
        tp_attribute9                           VARCHAR2(240),
        tp_attribute10                          VARCHAR2(240),
        tp_attribute11                          VARCHAR2(240),
        tp_attribute12                          VARCHAR2(240),
        tp_attribute13                          VARCHAR2(240),
        tp_attribute14                          VARCHAR2(240),
        tp_attribute15                          VARCHAR2(240),
        attribute_category                      VARCHAR2(150),
        attribute1                              VARCHAR2(150),
        attribute2                              VARCHAR2(150),
        attribute3                              VARCHAR2(150),
        attribute4                              VARCHAR2(150),
        attribute5                              VARCHAR2(150),
        attribute6                              VARCHAR2(150),
        attribute7                              VARCHAR2(150),
        attribute8                              VARCHAR2(150),
        attribute9                              VARCHAR2(150),
        attribute10                             VARCHAR2(150),
        attribute11                             VARCHAR2(150),
        attribute12                             VARCHAR2(150),
        attribute13                             VARCHAR2(150),
        attribute14                             VARCHAR2(150),
        attribute15                             VARCHAR2(150),
        created_by                              NUMBER,
        creation_date                           DATE,
        last_update_date                        DATE,
        last_update_login                       NUMBER,
        last_updated_by                 NUMBER,
        program_application_id          NUMBER,
        program_id                              NUMBER,
        program_update_date                     DATE,
        request_id                              NUMBER,
        mvt_stat_status                 VARCHAR2(30),
        released_flag                           VARCHAR2(1),
        organization_id                 NUMBER,
        transaction_temp_id                     NUMBER,
        ship_set_id                             NUMBER,
        arrival_set_id                          NUMBER,
        ship_model_complete_flag      VARCHAR2(1),
        top_model_line_id                       NUMBER,
        source_header_number            VARCHAR2(150),
        source_header_type_id           NUMBER,
        source_header_type_name         VARCHAR2(240),
        cust_po_number                          VARCHAR2(50),
        ato_line_id                             NUMBER,
        src_requested_quantity          NUMBER,
        src_requested_quantity_uom      VARCHAR2(3),
        move_order_line_id                      NUMBER,
        cancelled_quantity                      NUMBER,
        quality_control_quantity                NUMBER,
        cycle_count_quantity            NUMBER,
        tracking_number                 VARCHAR2(30),
        movement_id                             NUMBER,
        shipping_instructions           VARCHAR2(2000),
        packing_instructions            VARCHAR2(2000),
        project_id                              NUMBER,
        task_id                                 NUMBER,
        org_id                                  NUMBER,
        oe_interfaced_flag                      VARCHAR2(1),
        split_from_detail_id            NUMBER,
        inv_interfaced_flag                     VARCHAR2(1),
        source_line_number                      VARCHAR2(150),
        inspection_flag               VARCHAR2(1),
        released_status                 VARCHAR2(1),
        container_flag                          VARCHAR2(1),
        container_type_code             VARCHAR2(30),
        container_name                          VARCHAR2(30),
        fill_percent                            NUMBER,
        gross_weight                            NUMBER,
        master_serial_number            VARCHAR2(30),
        maximum_load_weight                     NUMBER,
        maximum_volume                          NUMBER,
        minimum_fill_percent            NUMBER,
        seal_code                                       VARCHAR2(30),
        unit_number                             VARCHAR2(30),
        unit_price                              NUMBER,
        currency_code                           VARCHAR2(15),
        freight_class_cat_id          NUMBER,
        commodity_code_cat_id         NUMBER,
-- hverddin 26-jun-2000 start of OPM changes
-- HW OPMCONV. Need to expand length of grade to 150
     preferred_grade               VARCHAR2(150),
     src_requested_quantity2       NUMBER,
     src_requested_quantity_uom2   VARCHAR2(3),
     requested_quantity2           NUMBER,
     shipped_quantity2             NUMBER,
     delivered_quantity2           NUMBER,
    cancelled_quantity2           NUMBER,
     quality_control_quantity2     NUMBER,
     cycle_count_quantity2         NUMBER,
     requested_quantity_uom2       VARCHAR2(3),
-- HW OPMCONV. No need for sublot anymore
--   sublot_number                 VARCHAR2(32) ,
-- hverddin 26-jun-2000 end of OPM changes
     lpn_id                         NUMBER ,
        pickable_flag                  VARCHAR2(1),
        original_subinventory          VARCHAR2(10),
        to_serial_number               VARCHAR2(30),
        picked_quantity                 NUMBER,
        picked_quantity2                NUMBER,
/* H Integration: datamodel changes wrudge */
        received_quantity                       NUMBER,
        received_quantity2                      NUMBER,
        source_line_set_id                      NUMBER,
-- 2678601
        transaction_id                          NUMBER,
/* J Inbound Logistics Changes jckwok */
        vendor_id                       NUMBER,
        ship_from_site_id               NUMBER,
        line_direction                  VARCHAR2(30),
        party_id                        NUMBER,
        routing_req_id                  NUMBER,
        shipping_control                VARCHAR2(30),
        source_blanket_reference_id     NUMBER,
        source_blanket_reference_num    NUMBER,
        po_shipment_line_id             NUMBER,
        po_shipment_line_number         NUMBER,
        returned_quantity               NUMBER,
        returned_quantity2              NUMBER,
        rcv_shipment_line_id            NUMBER,
        source_line_type_code           VARCHAR2(30),
        supplier_item_number            VARCHAR2(50),
        batch_id                        NUMBER, -- X-dock requirement
        replenishment_status            VARCHAR2(1)  --bug# 6689448 (replenishment project)
      );



TYPE Delivery_Details_Attr_Tbl_Type is TABLE of Delivery_Details_Rec_Type index by binary_integer;





 TYPE detailInRecType IS RECORD
        (
            --
            caller        VARCHAR2(50),
            action_code       VARCHAR2(30),
            phase       NUMBER,
            container_item_id     NUMBER,
            container_item_name   VARCHAR2(32767),
            container_item_seg    FND_FLEX_EXT.SegmentArray,
            organization_id       NUMBER,
            organization_code     VARCHAR2(32767),
            name_prefix           VARCHAR2(32767),
            name_suffix           VARCHAR2(32767),
            base_number           NUMBER,
            num_digits            NUMBER,
            quantity              NUMBER,
            container_name        VARCHAR2(32767),
            lpn_ids               wsh_util_core.id_tab_type
        );

  --
        TYPE detailOutRecType    IS   RECORD
        (
           --
           detail_ids WSH_UTIL_CORE.Id_Tab_Type
        );

    -- ---------------------------------------------------------------------
    -- Procedure:	Delivery_Detail_Action	Wrapper API
    --
    -- Parameters:
    --
    -- Description:  This procedure is the wrapper(overloaded) version for the
    --               main delivery_detail_group API. This is for use by public APIs
    --		 and by other product APIs. This signature does not have
    --               the form(UI) specific parameters
    -- Created :  Patchset I : Harmonziation Project
    -- Created by: KVENKATE
    -- -----------------------------------------------------------------------
    PROCEDURE Delivery_Detail_Action
    (
    -- Standard Parameters
       p_api_version_number        IN       NUMBER,
       p_init_msg_list             IN 	    VARCHAR2,
       p_commit                    IN 	    VARCHAR2,
       x_return_status             OUT 	NOCOPY    VARCHAR2,
       x_msg_count                 OUT 	NOCOPY    NUMBER,
       x_msg_data                  OUT 	NOCOPY    VARCHAR2,

    -- Procedure specific Parameters
       p_detail_id_tab             IN	    WSH_UTIL_CORE.id_tab_type,
       p_action_prms               IN	    WSH_INTERFACE_EXT_GRP.det_action_parameters_rec_type,
       x_action_out_rec            OUT NOCOPY     WSH_INTERFACE_EXT_GRP.det_action_out_rec_type
    );
    -- ---------------------------------------------------------------------
    -- Procedure:	Create_Update_Delivery_Detail	Wrapper API
    --
    -- Parameters:
    --
    -- Description:  This procedure is the new API for wrapping the logic of CREATE/UPDATE of delivery details
    -- Created    : Patchset I - Harmonization Project
    -- Created By : KVENKATE
    -- -----------------------------------------------------------------------

/***************************************************************************************************
*				IMPORTANT  NOTE
*
* While calling this API, please use FND_API.G_MISS_XXXX to set the value to NULL for parameter
* p_detail_info_tab.
***************************************************************************************************/
    PROCEDURE Create_Update_Delivery_Detail
    (
       -- Standard Parameters
       p_api_version_number	 IN	 NUMBER,
       p_init_msg_list           IN 	 VARCHAR2,
       p_commit                  IN 	 VARCHAR2,
       x_return_status           OUT NOCOPY	 VARCHAR2,
       x_msg_count               OUT NOCOPY 	 NUMBER,
       x_msg_data                OUT NOCOPY	 VARCHAR2,

       -- Procedure Specific Parameters
       p_detail_info_tab         IN 	WSH_INTERFACE_EXT_GRP.delivery_details_Attr_tbl_Type,
       p_IN_rec                  IN  	WSH_INTERFACE_EXT_GRP.detailInRecType,
       x_OUT_rec                 OUT NOCOPY	WSH_INTERFACE_EXT_GRP.detailOutRecType
    );



   TYPE  TripInRecType is RECORD(
        caller          VARCHAR2(50),
        phase           NUMBER,
        action_code     VARCHAR2(30));

    TYPE tripActionInRecType
    IS
    RECORD
      (
        action_code VARCHAR2(32767),
        wv_override_flag VARCHAR2(1) DEFAULT 'N'
      );

    TYPE tripOutRecType IS RECORD
      (
        rowid           VARCHAR2(32767),
        trip_id         NUMBER,
        trip_name       VARCHAR2(32767)
      );

TYPE trip_out_tab_type IS TABLE OF TripOutRecType INDEX BY BINARY_INTEGER;

    TYPE tripActionOutRecType
    IS
    RECORD
      (
          result_id_tab            wsh_util_core.id_tab_type,
          valid_ids_tab            wsh_util_core.id_tab_type,
          selection_issue_flag     VARCHAR2(1)
      );

    TYPE trip_action_parameters_rectype IS RECORD(
         caller                         VARCHAR2(50)
        ,phase                          NUMBER
        ,action_code                    VARCHAR2(30)
        ,organization_id                NUMBER
        ,report_set_id                  NUMBER
        ,override_flag                  VARCHAR2(500)
        ,trip_name                      VARCHAR2(30)
        ,actual_date                    DATE
        ,stop_id                        NUMBER                    --] These parameters
        ,action_flag                    VARCHAR2(1)               --] are used for
        ,autointransit_flag             VARCHAR2(1)               --] action_code = 'CONFIRM'
        ,autoclose_flag                 VARCHAR2(1)               --]
        ,stage_del_flag                 VARCHAR2(1)               --]
        ,ship_method                    VARCHAR2(30)              --]
        ,bill_of_lading_flag            VARCHAR2(1)               --]
        ,defer_interface_flag           VARCHAR2(1)               --]
        ,actual_departure_date          DATE                      --]
      );

TYPE trip_rec_type IS RECORD (
        TRIP_ID                         NUMBER,
        NAME                            VARCHAR2(30),
        PLANNED_FLAG                    VARCHAR2(1),
        ARRIVE_AFTER_TRIP_ID            NUMBER,
        STATUS_CODE                     VARCHAR2(2),
        VEHICLE_ITEM_ID                 NUMBER,
        VEHICLE_ORGANIZATION_ID         NUMBER,
        VEHICLE_NUMBER                  VARCHAR2(30),
        VEHICLE_NUM_PREFIX              VARCHAR2(10),
        CARRIER_ID                      NUMBER,
        SHIP_METHOD_CODE                VARCHAR2(30),
        ROUTE_ID                        NUMBER,
        ROUTING_INSTRUCTIONS            VARCHAR2(2000),
        ATTRIBUTE_CATEGORY              VARCHAR2(150),
        ATTRIBUTE1                      VARCHAR2(150),
        ATTRIBUTE2                      VARCHAR2(150),
        ATTRIBUTE3                      VARCHAR2(150),
        ATTRIBUTE4                      VARCHAR2(150),
        ATTRIBUTE5                      VARCHAR2(150),
        ATTRIBUTE6                      VARCHAR2(150),
        ATTRIBUTE7                      VARCHAR2(150),
        ATTRIBUTE8                      VARCHAR2(150),
        ATTRIBUTE9                      VARCHAR2(150),
        ATTRIBUTE10                     VARCHAR2(150),
        ATTRIBUTE11                     VARCHAR2(150),
        ATTRIBUTE12                     VARCHAR2(150),
        ATTRIBUTE13                     VARCHAR2(150),
        ATTRIBUTE14                     VARCHAR2(150),
        ATTRIBUTE15                     VARCHAR2(150),
        CREATION_DATE                   DATE,
        CREATED_BY                      NUMBER,
        LAST_UPDATE_DATE                DATE,
        LAST_UPDATED_BY                 NUMBER,
        LAST_UPDATE_LOGIN               NUMBER,
        PROGRAM_APPLICATION_ID          NUMBER,
        PROGRAM_ID                      NUMBER,
        PROGRAM_UPDATE_DATE             DATE,
        REQUEST_ID                      NUMBER,
/* H Integration: datamodel changes wrudge */
        SERVICE_LEVEL                   VARCHAR2(30),
        MODE_OF_TRANSPORT               VARCHAR2(30),
        FREIGHT_TERMS_CODE              VARCHAR2(30),
        CONSOLIDATION_ALLOWED           VARCHAR2(1),
/* I WSH-FTE Integration  , update to 30 */
        LOAD_TENDER_STATUS              VARCHAR2(30),
        ROUTE_LANE_ID                   NUMBER,
        LANE_ID                         NUMBER,
        SCHEDULE_ID                     NUMBER,
        BOOKING_NUMBER                  VARCHAR2(30),
/* I Harmonization: Non Database Columns Added rvishnuv */
        ROWID                           VARCHAR2(4000),
        ARRIVE_AFTER_TRIP_NAME          VARCHAR2(30),
        SHIP_METHOD_NAME                VARCHAR2(240),
        VEHICLE_ITEM_DESC               VARCHAR2(240),
        VEHICLE_ORGANIZATION_CODE       VARCHAR2(3),
/* I WSH-FTE LOAD TENDER Integration */
        LOAD_TENDER_NUMBER              NUMBER,
        VESSEL                          VARCHAR2(100),
        VOYAGE_NUMBER                   VARCHAR2(100),
        PORT_OF_LOADING                 VARCHAR2(240),
        PORT_OF_DISCHARGE               VARCHAR2(240),
        WF_NAME                         VARCHAR2(8),
        WF_PROCESS_NAME                 VARCHAR2(30),
        WF_ITEM_KEY                     VARCHAR2(240),
        CARRIER_CONTACT_ID              NUMBER,
        SHIPPER_WAIT_TIME               NUMBER,
        WAIT_TIME_UOM                   VARCHAR2(3),
        LOAD_TENDERED_TIME              DATE,
        CARRIER_RESPONSE                VARCHAR2(2000),
/* J Inbound Logistics new columns jckwok */
        SHIPMENTS_TYPE_FLAG             VARCHAR2(30)
        );


TYPE Trip_Attr_Tbl_Type is TABLE of trip_rec_type index by binary_integer;
--



 PROCEDURE Trip_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_entity_id_tab          IN   wsh_util_core.id_tab_type,
    p_action_prms            IN   WSH_INTERFACE_EXT_GRP.trip_action_parameters_rectype,
    x_trip_out_rec           OUT  NOCOPY WSH_INTERFACE_EXT_GRP.tripActionOutRecType,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2);

/***************************************************************************************************
*				IMPORTANT  NOTE
*
* While calling this API, please use FND_API.G_MISS_XXXX to set the value to NULL for parameter
* p_trip_info_tab.
***************************************************************************************************/
PROCEDURE Create_Update_Trip(
        p_api_version_number     IN     NUMBER,
        p_init_msg_list          IN     VARCHAR2,
        p_commit                 IN     VARCHAR2,
        x_return_status          OUT    NOCOPY VARCHAR2,
        x_msg_count              OUT    NOCOPY NUMBER,
        x_msg_data               OUT    NOCOPY VARCHAR2,
        p_trip_info_tab          IN     WSH_INTERFACE_EXT_GRP.Trip_Attr_Tbl_Type,
        p_In_rec                 IN     WSH_INTERFACE_EXT_GRP.tripInRecType,
        x_Out_Tab                OUT    NOCOPY WSH_INTERFACE_EXT_GRP.Trip_Out_Tab_Type);

     TYPE stop_action_parameters_rectype IS RECORD (
         caller                         VARCHAR2(50)
        ,phase                          NUMBER
        ,action_code                    VARCHAR2(30)
        ,stop_action                    VARCHAR2(30)
        ,organization_id                NUMBER
        ,actual_date                    DATE
        ,defer_interface_flag           VARCHAR2(500)
        ,report_set_id                  NUMBER
        ,override_flag                  VARCHAR2(500)
     );



    TYPE stopInRecType is RECORD(
        caller          VARCHAR2(50),
        phase           NUMBER,
        action_code     VARCHAR2(30));

    TYPE stopOutRecType IS RECORD (
        parameter1 VARCHAR2(32767) DEFAULT FND_API.G_MISS_CHAR,
        rowid           VARCHAR2(32767),
        stop_id         NUMBER
      );

TYPE stop_out_tab_type IS TABLE OF StopOutRecType INDEX BY BINARY_INTEGER;

    TYPE stopActionInRecType
    IS
    RECORD
      (
        action_code VARCHAR2(32767),
        actual_date        DATE        DEFAULT FND_API.G_MISS_DATE,
        defer_interface_flag VARCHAR2(1) DEFAULT 'Y'
      );


    TYPE stopActionOutRecType
    IS
    RECORD
      (
         result_id_tab            wsh_util_core.id_tab_type,
         valid_ids_tab            wsh_util_core.id_tab_type,
         selection_issue_flag     VARCHAR2(1)
      );

TYPE trip_stop_rec_type IS RECORD (
        STOP_ID                         NUMBER,
        TRIP_ID                         NUMBER,
        STOP_LOCATION_ID                NUMBER,
        STATUS_CODE                     VARCHAR2(2),
        STOP_SEQUENCE_NUMBER            NUMBER,
        PLANNED_ARRIVAL_DATE            DATE,
        PLANNED_DEPARTURE_DATE          DATE,
        ACTUAL_ARRIVAL_DATE             DATE,
        ACTUAL_DEPARTURE_DATE           DATE,
        DEPARTURE_GROSS_WEIGHT          NUMBER,
        DEPARTURE_NET_WEIGHT            NUMBER,
        WEIGHT_UOM_CODE                 VARCHAR2(3),
        DEPARTURE_VOLUME                NUMBER,
        VOLUME_UOM_CODE                 VARCHAR2(3),
        DEPARTURE_SEAL_CODE             VARCHAR2(30),
        DEPARTURE_FILL_PERCENT          NUMBER,
        TP_ATTRIBUTE_CATEGORY           VARCHAR2(150),
        TP_ATTRIBUTE1                   VARCHAR2(150),
        TP_ATTRIBUTE2                   VARCHAR2(150),
        TP_ATTRIBUTE3                   VARCHAR2(150),
        TP_ATTRIBUTE4                   VARCHAR2(150),
        TP_ATTRIBUTE5                   VARCHAR2(150),
        TP_ATTRIBUTE6                   VARCHAR2(150),
        TP_ATTRIBUTE7                   VARCHAR2(150),
        TP_ATTRIBUTE8                   VARCHAR2(150),
        TP_ATTRIBUTE9                   VARCHAR2(150),
        TP_ATTRIBUTE10                  VARCHAR2(150),
        TP_ATTRIBUTE11                  VARCHAR2(150),
        TP_ATTRIBUTE12                  VARCHAR2(150),
        TP_ATTRIBUTE13                  VARCHAR2(150),
        TP_ATTRIBUTE14                  VARCHAR2(150),
        TP_ATTRIBUTE15                  VARCHAR2(150),
        ATTRIBUTE_CATEGORY              VARCHAR2(150),
        ATTRIBUTE1                      VARCHAR2(150),
        ATTRIBUTE2                      VARCHAR2(150),
        ATTRIBUTE3                      VARCHAR2(150),
        ATTRIBUTE4                      VARCHAR2(150),
        ATTRIBUTE5                      VARCHAR2(150),
        ATTRIBUTE6                      VARCHAR2(150),
        ATTRIBUTE7                      VARCHAR2(150),
        ATTRIBUTE8                      VARCHAR2(150),
        ATTRIBUTE9                      VARCHAR2(150),
        ATTRIBUTE10                     VARCHAR2(150),
        ATTRIBUTE11                     VARCHAR2(150),
        ATTRIBUTE12                     VARCHAR2(150),
        ATTRIBUTE13                     VARCHAR2(150),
        ATTRIBUTE14                     VARCHAR2(150),
        ATTRIBUTE15                     VARCHAR2(150),
        CREATION_DATE                   DATE,
        CREATED_BY                      NUMBER,
        LAST_UPDATE_DATE                DATE,
        LAST_UPDATED_BY                 NUMBER,
        LAST_UPDATE_LOGIN               NUMBER,
        PROGRAM_APPLICATION_ID          NUMBER,
        PROGRAM_ID                      NUMBER,
        PROGRAM_UPDATE_DATE             DATE,
        REQUEST_ID                      NUMBER,
/* H Integration: datamodel changes wrudge */
        WSH_LOCATION_ID                 NUMBER,
        TRACKING_DRILLDOWN_FLAG         VARCHAR2(1),
        TRACKING_REMARKS                VARCHAR2(4000),
        CARRIER_EST_DEPARTURE_DATE      DATE,
        CARRIER_EST_ARRIVAL_DATE        DATE,
        LOADING_START_DATETIME          DATE,
        LOADING_END_DATETIME            DATE,
        UNLOADING_START_DATETIME        DATE,
        UNLOADING_END_DATETIME          DATE,
/* I Harmonization: Non Database Columns Added rvishnuv */
        ROWID                           VARCHAR2(4000),
        TRIP_NAME                       VARCHAR2(30),
        STOP_LOCATION_CODE              VARCHAR2(80),
        WEIGHT_UOM_DESC                 VARCHAR2(25),
        VOLUME_UOM_DESC                 VARCHAR2(25),
        LOCK_STOP_ID                    NUMBER,
        PENDING_INTERFACE_FLAG          VARCHAR2(1),
        TRANSACTION_HEADER_ID           NUMBER,
/* J Inbound Logistics new columns jckwok */
        SHIPMENTS_TYPE_FLAG             VARCHAR2(30)
);

TYPE Stop_Attr_Tbl_Type is TABLE of trip_stop_rec_type index by binary_integer;






  PROCEDURE Stop_Action
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_entity_id_tab          IN   wsh_util_core.id_tab_type,
    p_action_prms            IN   WSH_INTERFACE_EXT_GRP.stop_action_parameters_rectype,
    x_stop_out_rec           OUT  NOCOPY WSH_INTERFACE_EXT_GRP.stopActionOutRecType,
    x_return_status          OUT  NOCOPY VARCHAR2,
    x_msg_count              OUT  NOCOPY NUMBER,
    x_msg_data               OUT  NOCOPY VARCHAR2);


--heali
/***************************************************************************************************
*				IMPORTANT  NOTE
*
* While calling this API, please use FND_API.G_MISS_XXXX to set the value to NULL for parameter
* p_rec_attr_tab.
***************************************************************************************************/
PROCEDURE CREATE_UPDATE_STOP(
        p_api_version_number    IN  NUMBER,
        p_init_msg_list         IN  VARCHAR2,
        p_commit                IN  VARCHAR2,
        p_in_rec                IN  WSH_INTERFACE_EXT_GRP.stopInRecType,
        p_rec_attr_tab          IN  WSH_INTERFACE_EXT_GRP.Stop_Attr_Tbl_Type,
        x_stop_out_tab          OUT NOCOPY WSH_INTERFACE_EXT_GRP.stop_out_tab_type,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2);



TYPE FreightInRecType    IS     RECORD
      (
       caller           VARCHAR2(50),
       action_code      VARCHAR2(30),
       phase            NUMBER
      );

TYPE FreightOutRecType    IS   RECORD
      (
        freight_cost_id            NUMBER,
        rowid                      VARCHAR2(4000)
      );




TYPE Freight_Cost_Rec_Type IS RECORD (
  FREIGHT_COST_ID           NUMBER
, FREIGHT_COST_TYPE_ID        NUMBER
, UNIT_AMOUNT                 NUMBER
/* H Integration: datamodel changes wrudge (15->30) */
, CALCULATION_METHOD              VARCHAR2(30)
, UOM                         VARCHAR2(15)
, QUANTITY                    NUMBER
, TOTAL_AMOUNT                NUMBER
, CURRENCY_CODE               VARCHAR2(15)
, CONVERSION_DATE             DATE
, CONVERSION_RATE             NUMBER
, CONVERSION_TYPE_CODE        VARCHAR2(30)
, TRIP_ID                     NUMBER
, STOP_ID                     NUMBER
, DELIVERY_ID                 NUMBER
, DELIVERY_LEG_ID             NUMBER
, DELIVERY_DETAIL_ID          NUMBER
, ATTRIBUTE_CATEGORY          VARCHAR2(150)
, ATTRIBUTE1              VARCHAR2(150)
, ATTRIBUTE2              VARCHAR2(150)
, ATTRIBUTE3              VARCHAR2(150)
, ATTRIBUTE4              VARCHAR2(150)
, ATTRIBUTE5              VARCHAR2(150)
, ATTRIBUTE6              VARCHAR2(150)
, ATTRIBUTE7              VARCHAR2(150)
, ATTRIBUTE8              VARCHAR2(150)
, ATTRIBUTE9              VARCHAR2(150)
, ATTRIBUTE10             VARCHAR2(150)
, ATTRIBUTE11             VARCHAR2(150)
, ATTRIBUTE12             VARCHAR2(150)
, ATTRIBUTE13               VARCHAR2(150)
, ATTRIBUTE14             VARCHAR2(150)
, ATTRIBUTE15             VARCHAR2(150)
, CREATION_DATE           DATE
, CREATED_BY              NUMBER
, LAST_UPDATE_DATE          DATE
, LAST_UPDATE_LOGIN         NUMBER
, PROGRAM_APPLICATION_ID      NUMBER
, PROGRAM_ID                     NUMBER
, PROGRAM_UPDATE_DATE            DATE
, REQUEST_ID                     NUMBER
/* H Integration: datamodel changes wrudge */
, PRICING_LIST_HEADER_ID  NUMBER
, PRICING_LIST_LINE_ID    NUMBER
, APPLIED_TO_CHARGE_ID    NUMBER
, CHARGE_UNIT_VALUE   NUMBER
, CHARGE_SOURCE_CODE    VARCHAR2(30)
, LINE_TYPE_CODE    VARCHAR2(30)
, ESTIMATED_FLAG    VARCHAR2(1)
/* Harmonizing project I: heali */
, FREIGHT_CODE                  VARCHAR2(30)
, TRIP_NAME                     VARCHAR2(30)
, DELIVERY_NAME                 VARCHAR2(30)
, FREIGHT_COST_TYPE             VARCHAR2(30)
, STOP_LOCATION_ID              NUMBER
, PLANNED_DEP_DATE              DATE
, COMMODITY_CATEGORY_ID         NUMBER
);

TYPE freight_rec_tab_type IS TABLE OF Freight_Cost_Rec_Type INDEX BY BINARY_INTEGER;
TYPE freight_out_tab_type IS TABLE OF FreightOutRecType INDEX BY BINARY_INTEGER;

/***************************************************************************************************
*				IMPORTANT  NOTE
*
* While calling this API, please use FND_API.G_MISS_XXXX to set the value to NULL for parameter
* p_freight_info_tab.
***************************************************************************************************/
PROCEDURE Create_Update_Freight_Costs(
	p_api_version_number     IN     NUMBER,
	p_init_msg_list          IN     VARCHAR2,
	p_commit                 IN     VARCHAR2,
	x_return_status          OUT    NOCOPY VARCHAR2,
	x_msg_count              OUT    NOCOPY NUMBER,
	x_msg_data               OUT    NOCOPY VARCHAR2,
	p_freight_info_tab       IN     WSH_INTERFACE_EXT_GRP.freight_rec_tab_type,
	p_in_rec                 IN     WSH_INTERFACE_EXT_GRP.freightInRecType,
	x_out_tab                OUT    NOCOPY WSH_INTERFACE_EXT_GRP.freight_out_tab_type);
--heali

TYPE XC_REC_TYPE IS RECORD
     (exception_id	NUMBER,
     exception_name	VARCHAR2(30),
     status		VARCHAR2(30)
     );

TYPE XC_TAB_TYPE IS TABLE OF XC_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE XC_ACTION_REC_TYPE IS RECORD
        (
        -- The following fields are used for Logging exceptions
        request_id           NUMBER,           -- Also used for Purge
        batch_id             NUMBER,
        exception_id         NUMBER,
        exception_name       VARCHAR2(30),     -- Also used for Purge, Change_Status
        logging_entity       VARCHAR2(30),     -- Also used for Purge, Change_Status
        logging_entity_id    NUMBER,           -- Also used for Change_Status
        manually_logged      VARCHAR2(1),
        message              VARCHAR2(2000),
        logged_at_location_code       VARCHAR2(50),  -- Also used for Purge
        exception_location_code       VARCHAR2(50),  -- Also used for Purge
        severity             VARCHAR2(10),           -- Also used for Purge
        delivery_name        VARCHAR2(30),           -- Also used for Purge
        trip_name            VARCHAR2(30),
        stop_location_id     NUMBER,
        delivery_detail_id   NUMBER,
        container_name       VARCHAR2(50),
        org_id               NUMBER,
        inventory_item_id    NUMBER,
-- HW OPMCONV. Need to expand length of lot_number to 80
        lot_number           VARCHAR2(80),
-- HW OPMCONV. No need for sublot anymore
--      sublot_number        VARCHAR2(32),
        revision             VARCHAR2(3),
        serial_number        VARCHAR2(30),
        unit_of_measure      VARCHAR2(5),
        quantity             NUMBER,
        unit_of_measure2     VARCHAR2(3),
        quantity2            NUMBER,
        subinventory         VARCHAR2(10),
        locator_id           NUMBER,
        error_message        VARCHAR2(500),
        attribute_category   VARCHAR2(150),
        attribute1           VARCHAR2(150),
        attribute2           VARCHAR2(150),
        attribute3           VARCHAR2(150),
        attribute4           VARCHAR2(150),
        attribute5           VARCHAR2(150),
        attribute6           VARCHAR2(150),
        attribute7           VARCHAR2(150),
        attribute8           VARCHAR2(150),
        attribute9           VARCHAR2(150),
        attribute10          VARCHAR2(150),
        attribute11          VARCHAR2(150),
        attribute12          VARCHAR2(150),
        attribute13          VARCHAR2(150),
        attribute14          VARCHAR2(150),
        attribute15          VARCHAR2(150),
        departure_date       DATE,             -- Also used for Purge
        arrival_date         DATE,             -- Also used for Purge

        -- These fields are used for the Purge action.
        exception_type       VARCHAR2(25),
        status               VARCHAR2(30),
        departure_date_to    DATE,
        arrival_date_to      DATE,
        creation_date        DATE,
        creation_date_to     DATE,
        data_older_no_of_days    NUMBER,

        -- This field is used for Change_Status action.
        new_status           VARCHAR2(30),

        caller          VARCHAR2(100),
        phase           NUMBER
        );


------------------------------------------------------------------------------
-- Procedure:	Get_Exceptions
--
-- Parameters:  1) p_logging_entity_id - entity id for a particular entity name
--              2) p_logging_entity_name - can be 'TRIP', 'STOP', 'DELIVERY',
--                                       'DETAIL', or 'CONTAINER'
--              3) x_exceptions_tab - list of exceptions
--
-- Description: This procedure takes in a logging entity id and logging entity
--              name and create an exception table.
------------------------------------------------------------------------------

PROCEDURE Get_Exceptions (
        -- Standard parameters
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,

        -- program specific parameters
        p_logging_entity_id	IN 	NUMBER,
	p_logging_entity_name	IN	VARCHAR2,

        -- program specific out parameters
        x_exceptions_tab	OUT NOCOPY 	WSH_INTERFACE_EXT_GRP.XC_TAB_TYPE
	);

PROCEDURE Exception_Action (
	p_api_version	        IN	NUMBER,
	p_init_msg_list		IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_validation_level      IN      NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_commit                IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,
        x_return_status         OUT NOCOPY      VARCHAR2,

	p_exception_rec         IN OUT  NOCOPY WSH_INTERFACE_EXT_GRP.XC_ACTION_REC_TYPE,
        p_action                IN              VARCHAR2
	);


TYPE dlvy_leg_action_prms_rectype  IS RECORD(
caller              		VARCHAR2(50),
action_code			VARCHAR2(30),
phase				NUMBER,
p_Pick_Up_Location_Id		NUMBER,
p_Ship_Method			VARCHAR2(30),
p_Drop_Off_Location_Id		NUMBER,
p_Carrier_Id			NUMBER
);


TYPE dlvy_leg_action_out_rec_type IS RECORD(
valid_id_tab          		WSH_UTIL_CORE.id_tab_type,
x_trip_id			NUMBER,
x_trip_name			VARCHAR2(30),
x_delivery_id			NUMBER,
x_bol_number			VARCHAR2(50));


PROCEDURE Delivery_Leg_Action(
	p_api_version_number	 	IN 	NUMBER,
	p_init_msg_list			IN	VARCHAR2,
	p_commit                 	IN 	VARCHAR2,
	p_dlvy_leg_id_tab		IN	wsh_util_core.id_tab_type,
	p_action_prms			IN	WSH_INTERFACE_EXT_GRP.dlvy_leg_action_prms_rectype,
	x_action_out_rec		IN OUT  NOCOPY WSH_INTERFACE_EXT_GRP.dlvy_leg_action_out_rec_type,
	x_return_status  		OUT 	NOCOPY VARCHAR2,
	x_msg_count     		OUT 	NOCOPY NUMBER,
	x_msg_data       		OUT 	NOCOPY VARCHAR2
);

-- deliveryMerge
G_NO_APPENDING        VARCHAR2(1) := 'N';
G_START_OF_STAGING    VARCHAR2(1) := 'S';
G_END_OF_STAGING      VARCHAR2(1) := 'E';
G_START_OF_PACKING    VARCHAR2(1) := 'A';
G_START_OF_SHIPPING   VARCHAR2(1) := 'W';

--OTM R12
PROCEDURE OTM_PRE_SHIP_CONFIRM
 (p_delivery_id        IN         NUMBER,
  p_delivery_name      IN         VARCHAR2 DEFAULT NULL,
  p_tms_interface_flag IN         VARCHAR2,
  p_trip_id            IN         NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2);
--

END WSH_INTERFACE_EXT_GRP;

/
