--------------------------------------------------------
--  DDL for Package WMS_SHIPPING_INTERFACE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_SHIPPING_INTERFACE_GRP" AUTHID CURRENT_USER AS
/* $Header: WMSGINTS.pls 120.2 2007/01/05 22:52:58 satkumar noship $ */

      g_action_assign_dlvy_trip   CONSTANT   VARCHAR2(30) := 'ASSIGN_DLVY_TRIP';
      g_action_unassign_dlvy_trip CONSTANT   VARCHAR2(30) := 'UNASSIGN_DLVY_TRIP';

      g_action_unassign_delivery  CONSTANT   VARCHAR2(20) := 'UNASSIGN_DELIVERY';
      g_action_ship_confirm       CONSTANT   VARCHAR2(20) := 'SHIP_CONFIRM';
      g_action_edit_shipped_qty   CONSTANT   VARCHAR2(20) := 'EDIT_SHIPPED_QTY';
      g_action_validate_sec_qty   CONSTANT   VARCHAR2(20) := 'VALIDATE_SEC_QTY';
      g_action_update             CONSTANT   VARCHAR2(20) := 'UPDATE';
      g_action_plan_delivery	  CONSTANT   VARCHAR2(30) := 'INCLUDE_DELIVERY_FOR_PLANNING';


      g_false                     CONSTANT   VARCHAR2(1) := fnd_api.g_false;
      g_true                      CONSTANT   VARCHAR2(1) := fnd_api.g_true;
      g_full_validation           CONSTANT   NUMBER   := fnd_api.g_valid_level_full;
      TYPE delivery_detail_tbl_rec IS RECORD
          (DELIVERY_DETAIL_ID             NUMBER
          ,SOURCE_CODE                    VARCHAR2(30)
          ,SOURCE_HEADER_ID               NUMBER
          ,SOURCE_LINE_ID                 NUMBER
          ,SOURCE_HEADER_NUMBER           VARCHAR2(150)
          ,SOURCE_HEADER_TYPE_ID          NUMBER
          ,SOURCE_HEADER_TYPE_NAME        VARCHAR2(240)
          ,CUST_PO_NUMBER                 VARCHAR2(50)
          ,CUSTOMER_ID                    NUMBER
          ,SOLD_TO_CONTACT_ID             NUMBER
          ,INVENTORY_ITEM_ID              NUMBER
          ,ITEM_DESCRIPTION               VARCHAR2(250)
          ,SHIP_SET_ID                    NUMBER
          ,ARRIVAL_SET_ID                 NUMBER
          ,TOP_MODEL_LINE_ID              NUMBER
          ,ATO_LINE_ID                    NUMBER
          ,HOLD_CODE                      VARCHAR2(1)
          ,SHIP_MODEL_COMPLETE_FLAG       VARCHAR2(1)
          ,HAZARD_CLASS_ID                NUMBER
          ,COUNTRY_OF_ORIGIN              VARCHAR2(50)
          ,CLASSIFICATION                 VARCHAR2(30)
          ,SHIP_FROM_LOCATION_ID          NUMBER
          ,ORGANIZATION_ID                NUMBER
          ,SHIP_TO_LOCATION_ID            NUMBER
          ,SHIP_TO_CONTACT_ID             NUMBER
          ,SHIP_TO_SITE_USE_ID            NUMBER
          ,DELIVER_TO_LOCATION_ID         NUMBER
          ,DELIVER_TO_CONTACT_ID          NUMBER
          ,DELIVER_TO_SITE_USE_ID         NUMBER
          ,INTMED_SHIP_TO_LOCATION_ID     NUMBER
          ,INTMED_SHIP_TO_CONTACT_ID      NUMBER
          ,SHIP_TOLERANCE_ABOVE           NUMBER
          ,SHIP_TOLERANCE_BELOW           NUMBER
          ,SRC_REQUESTED_QUANTITY         NUMBER
          ,SRC_REQUESTED_QUANTITY_UOM     VARCHAR2(3)
          ,CANCELLED_QUANTITY             NUMBER
          ,REQUESTED_QUANTITY             NUMBER
          ,REQUESTED_QUANTITY_UOM         VARCHAR2(3)
          ,SHIPPED_QUANTITY               NUMBER
          ,DELIVERED_QUANTITY             NUMBER
          ,QUALITY_CONTROL_QUANTITY       NUMBER
          ,CYCLE_COUNT_QUANTITY           NUMBER
          ,MOVE_ORDER_LINE_ID             NUMBER
          ,SUBINVENTORY                   VARCHAR2(10)
          ,REVISION                       VARCHAR2(3)
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
          ,LOT_NUMBER                     VARCHAR2(80)
          ,RELEASED_STATUS                VARCHAR2(1)
          ,CUSTOMER_REQUESTED_LOT_FLAG    VARCHAR2(1)
          ,SERIAL_NUMBER                  VARCHAR2(30)
          ,LOCATOR_ID                     NUMBER
          ,DATE_REQUESTED                 DATE
          ,DATE_SCHEDULED                 DATE
          ,MASTER_CONTAINER_ITEM_ID       NUMBER
          ,DETAIL_CONTAINER_ITEM_ID       NUMBER
          ,LOAD_SEQ_NUMBER                NUMBER
          ,SHIP_METHOD_CODE               VARCHAR2(30)
          ,CARRIER_ID                     NUMBER
          ,FREIGHT_TERMS_CODE             VARCHAR2(30)
          ,SHIPMENT_PRIORITY_CODE         VARCHAR2(30)
          ,FOB_CODE                       VARCHAR2(30)
          ,CUSTOMER_ITEM_ID               NUMBER
          ,DEP_PLAN_REQUIRED_FLAG         VARCHAR2(1)
          ,CUSTOMER_PROD_SEQ              VARCHAR2(50)
          ,CUSTOMER_DOCK_CODE             VARCHAR2(50)
          ,CUSTOMER_PRODUCTION_LINE       VARCHAR2(50)
          ,CUSTOMER_JOB                   VARCHAR2(50)
          ,NET_WEIGHT                     NUMBER
          ,CUST_MODEL_SERIAL_NUMBER       VARCHAR2(50)
          ,WEIGHT_UOM_CODE                VARCHAR2(3)
          ,VOLUME                         NUMBER
          ,VOLUME_UOM_CODE                VARCHAR2(3)
          ,SHIPPING_INSTRUCTIONS          VARCHAR2(2000)
          ,PACKING_INSTRUCTIONS           VARCHAR2(2000)
          ,PROJECT_ID                     NUMBER
          ,TASK_ID                        NUMBER
          ,ORG_ID                         NUMBER
          ,OE_INTERFACED_FLAG             VARCHAR2(1)
          ,MVT_STAT_STATUS                VARCHAR2(30)
          ,TRACKING_NUMBER                VARCHAR2(30)
          ,TRANSACTION_TEMP_ID            NUMBER
          ,TP_ATTRIBUTE_CATEGORY          VARCHAR2(240)
          ,TP_ATTRIBUTE1                  VARCHAR2(240)
          ,TP_ATTRIBUTE2                  VARCHAR2(240)
          ,TP_ATTRIBUTE3                  VARCHAR2(240)
          ,TP_ATTRIBUTE4                  VARCHAR2(240)
          ,TP_ATTRIBUTE5                  VARCHAR2(240)
          ,TP_ATTRIBUTE6                  VARCHAR2(240)
          ,TP_ATTRIBUTE7                  VARCHAR2(240)
          ,TP_ATTRIBUTE8                  VARCHAR2(240)
          ,TP_ATTRIBUTE9                  VARCHAR2(240)
          ,TP_ATTRIBUTE10                 VARCHAR2(240)
          ,TP_ATTRIBUTE11                 VARCHAR2(240)
          ,TP_ATTRIBUTE12                 VARCHAR2(240)
          ,TP_ATTRIBUTE13                 VARCHAR2(240)
          ,TP_ATTRIBUTE14                 VARCHAR2(240)
          ,TP_ATTRIBUTE15                 VARCHAR2(240)
          ,ATTRIBUTE_CATEGORY             VARCHAR2(150)
          ,ATTRIBUTE1                     VARCHAR2(150)
          ,ATTRIBUTE2                     VARCHAR2(150)
          ,ATTRIBUTE3                     VARCHAR2(150)
          ,ATTRIBUTE4                     VARCHAR2(150)
          ,ATTRIBUTE5                     VARCHAR2(150)
          ,ATTRIBUTE6                     VARCHAR2(150)
          ,ATTRIBUTE7                     VARCHAR2(150)
          ,ATTRIBUTE8                     VARCHAR2(150)
          ,ATTRIBUTE9                     VARCHAR2(150)
          ,ATTRIBUTE10                    VARCHAR2(150)
          ,ATTRIBUTE11                    VARCHAR2(150)
          ,ATTRIBUTE12                    VARCHAR2(150)
          ,ATTRIBUTE13                    VARCHAR2(150)
          ,ATTRIBUTE14                    VARCHAR2(150)
          ,ATTRIBUTE15                    VARCHAR2(150)
          ,CREATION_DATE                  DATE
          ,CREATED_BY                     NUMBER
          ,LAST_UPDATE_DATE               DATE
          ,LAST_UPDATED_BY                NUMBER
          ,LAST_UPDATE_LOGIN              NUMBER
          ,PROGRAM_APPLICATION_ID         NUMBER
          ,PROGRAM_ID                     NUMBER
          ,PROGRAM_UPDATE_DATE            DATE
          ,REQUEST_ID                     NUMBER
          ,MOVEMENT_ID                    NUMBER
          ,SPLIT_FROM_DELIVERY_DETAIL_ID  NUMBER
          ,INV_INTERFACED_FLAG            VARCHAR2(1)
          ,SOURCE_LINE_NUMBER             VARCHAR2(150)
          ,SEAL_CODE                      VARCHAR2(30)
          ,MINIMUM_FILL_PERCENT           NUMBER
          ,MAXIMUM_VOLUME                 NUMBER
          ,MAXIMUM_LOAD_WEIGHT            NUMBER
          ,MASTER_SERIAL_NUMBER           VARCHAR2(30)
          ,GROSS_WEIGHT                   NUMBER
          ,FILL_PERCENT                   NUMBER
          ,CONTAINER_NAME                 VARCHAR2(30)
          ,CONTAINER_TYPE_CODE            VARCHAR2(30)
          ,CONTAINER_FLAG                 VARCHAR2(1)
          ,PREFERRED_GRADE                VARCHAR2(4)
          ,SRC_REQUESTED_QUANTITY2        NUMBER
          ,SRC_REQUESTED_QUANTITY_UOM2    VARCHAR2(3)
          ,REQUESTED_QUANTITY2            NUMBER
          ,SHIPPED_QUANTITY2              NUMBER
          ,DELIVERED_QUANTITY2            NUMBER
          ,CANCELLED_QUANTITY2            NUMBER
          ,QUALITY_CONTROL_QUANTITY2      NUMBER
          ,CYCLE_COUNT_QUANTITY2          NUMBER
          ,REQUESTED_QUANTITY_UOM2        VARCHAR2(3)
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
          ,SUBLOT_NUMBER                  VARCHAR2(80)
          ,UNIT_PRICE                     NUMBER
          ,CURRENCY_CODE                  VARCHAR2(15)
          ,UNIT_NUMBER                    VARCHAR2(30)
          ,FREIGHT_CLASS_CAT_ID           NUMBER
          ,COMMODITY_CODE_CAT_ID          NUMBER
          ,LPN_ID                         NUMBER
          ,INSPECTION_FLAG                VARCHAR2(1)
          ,ORIGINAL_SUBINVENTORY          VARCHAR2(10)
          ,PICKABLE_FLAG                  VARCHAR2(1)
          ,TO_SERIAL_NUMBER               VARCHAR2(30)
          ,PICKED_QUANTITY                NUMBER
          ,PICKED_QUANTITY2               NUMBER
          ,RECEIVED_QUANTITY              NUMBER
          ,RECEIVED_QUANTITY2             NUMBER
          ,SOURCE_LINE_SET_ID             NUMBER
          ,BATCH_ID                       NUMBER
          ,LINE_DIRECTION                 VARCHAR2(30)
          ,r_message_appl                 VARCHAR2(3)
          ,r_message_code                 VARCHAR2(30)
          ,r_message_token                VARCHAR2(30)
          ,r_message_type                 VARCHAR2(1)
          ,r_message_text                 VARCHAR2(2000)
          ,return_status                  VARCHAR2(10));

      TYPE g_delivery_detail_tbl    IS TABLE OF delivery_detail_tbl_rec INDEX BY BINARY_INTEGER;

      TYPE dlvy_trip_tbl_rec IS RECORD
	(delivery_id           NUMBER
	 ,trip_id              NUMBER
	 ,r_message_appl       VARCHAR2(3)
	 ,r_message_code       VARCHAR2(30)
	 ,r_message_token      VARCHAR2(30) --value of the token
	 ,r_message_token_name VARCHAR2(30)
	 ,r_message_type       VARCHAR2(1)
	 ,r_message_text       VARCHAR2(2000)
	 ,return_status        VARCHAR2(10));

      TYPE g_dlvy_trip_tbl IS TABLE OF dlvy_trip_tbl_rec INDEX BY BINARY_INTEGER;

      TYPE serial_number_tbl_rec IS RECORD
	(inventory_item_id        NUMBER
	 ,serial_number           VARCHAR2(30)
	 ,current_organization_id NUMBER
	 ,lpn_id                  NUMBER
	 ,return_status           VARCHAR2(10) --Currently not use
	 );

      TYPE g_serial_number_tbl IS TABLE OF serial_number_tbl_rec INDEX BY BINARY_INTEGER;

      PROCEDURE process_delivery_details
	(p_api_version                IN                 NUMBER,
	 p_init_msg_list              IN                 VARCHAR2 := wms_shipping_interface_grp.g_false,
	 p_commit                     IN                 VARCHAR2 := wms_shipping_interface_grp.g_false,
	 p_validation_level           IN                 NUMBER   := wms_shipping_interface_grp.g_full_validation,
	 p_action                     IN                 VARCHAR2,
	 p_delivery_detail_tbl        IN OUT NOCOPY      wms_shipping_interface_grp.g_delivery_detail_tbl,
	 x_return_status              OUT    NOCOPY      VARCHAR2,
	 x_msg_count                  OUT    NOCOPY      NUMBER,
	 x_msg_data                   OUT    NOCOPY      VARCHAR2);

      PROCEDURE process_delivery_trip
	(p_api_version       IN            NUMBER
	 ,p_init_msg_list    IN            VARCHAR2 := wms_shipping_interface_grp.g_false
	 ,p_commit           IN            VARCHAR2 := wms_shipping_interface_grp.g_false
	 ,p_validation_level IN            NUMBER   := wms_shipping_interface_grp.g_full_validation
	 ,p_action           IN            VARCHAR2
	 ,p_dlvy_trip_tbl    IN OUT nocopy wms_shipping_interface_grp.g_dlvy_trip_tbl
	 ,x_return_status    OUT    nocopy VARCHAR2
	 ,x_msg_count        OUT    nocopy NUMBER
	 ,x_msg_data         OUT    nocopy VARCHAR2);

      PROCEDURE process_serial_number
	(p_api_version         IN NUMBER
	 ,p_init_msg_list      IN VARCHAR2 := wms_shipping_interface_grp.g_false
	 ,p_commit             IN VARCHAR2 := wms_shipping_interface_grp.g_false
	 ,p_validation_level   IN NUMBER := wms_shipping_interface_grp.g_full_validation
	 ,p_action             IN VARCHAR2
	 ,p_serial_number_tbl  IN OUT nocopy wms_shipping_interface_grp.g_serial_number_tbl
	 ,x_return_status      OUT nocopy VARCHAR2
	 ,x_msg_count          OUT nocopy NUMBER
	 ,x_msg_data           OUT nocopy VARCHAR2);

/* Added the following API, which will be called by WSH
with p_action as 'INCLUDE_DELIVERY_FOR_PLANNING', when
the delivery is not assigned to any trip, to validate whether
any LPN associated with this delivery is already loaded to dock door
*/

PROCEDURE process_deliveries
	 (p_api_version       IN            NUMBER
	  ,p_init_msg_list    IN            VARCHAR2 := Wms_Shipping_Interface_Grp.g_false
	  ,p_commit           IN            VARCHAR2 := Wms_Shipping_Interface_Grp.g_false
	  ,p_validation_level IN            NUMBER   := Wms_Shipping_Interface_Grp.g_full_validation
	  ,p_action           IN            VARCHAR2
	  ,x_dlvy_trip_tbl    IN OUT nocopy Wms_Shipping_Interface_Grp.g_dlvy_trip_tbl
	  ,x_return_status    OUT    nocopy VARCHAR2
	  ,x_msg_count        OUT    nocopy NUMBER
	  ,x_msg_data         OUT    nocopy VARCHAR2);



END WMS_SHIPPING_INTERFACE_GRP;

/
