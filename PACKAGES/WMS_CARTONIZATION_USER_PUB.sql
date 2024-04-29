--------------------------------------------------------
--  DDL for Package WMS_CARTONIZATION_USER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CARTONIZATION_USER_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSCRTUS.pls 120.1 2008/01/07 21:20:57 rsagar noship $*/

   TYPE task_rec_type
   IS RECORD
   (
     TRANSACTION_HEADER_ID                   NUMBER
   , TRANSACTION_TEMP_ID                     NUMBER
   , SOURCE_CODE                             VARCHAR2(30)
   , SOURCE_LINE_ID                          NUMBER
   , TRANSACTION_MODE                        NUMBER
   , LOCK_FLAG                               VARCHAR2(1)
   , LAST_UPDATE_DATE                        DATE
   , LAST_UPDATED_BY                         NUMBER
   , CREATION_DATE                           DATE
   , CREATED_BY                              NUMBER
   , LAST_UPDATE_LOGIN                       NUMBER
   , REQUEST_ID                              NUMBER
   , PROGRAM_APPLICATION_ID                  NUMBER
   , PROGRAM_ID                              NUMBER
   , PROGRAM_UPDATE_DATE                     DATE
   , INVENTORY_ITEM_ID                       NUMBER
   , REVISION                                VARCHAR2(3)
   , ORGANIZATION_ID                         NUMBER
   , SUBINVENTORY_CODE                       VARCHAR2(10)
   , LOCATOR_ID                              NUMBER
   , TRANSACTION_QUANTITY                    NUMBER
   , PRIMARY_QUANTITY                        NUMBER
   , TRANSACTION_UOM                         VARCHAR2(3)
   , TRANSACTION_COST                        NUMBER
   , TRANSACTION_TYPE_ID                     NUMBER
   , TRANSACTION_ACTION_ID                   NUMBER
   , TRANSACTION_SOURCE_TYPE_ID              NUMBER
   , TRANSACTION_SOURCE_ID                   NUMBER
   , TRANSACTION_SOURCE_NAME                 VARCHAR2(30)
   , TRANSACTION_DATE                        DATE
   , ACCT_PERIOD_ID                          NUMBER
   , DISTRIBUTION_ACCOUNT_ID                 NUMBER
   , TRANSACTION_REFERENCE                   VARCHAR2(240)
   , REQUISITION_LINE_ID                     NUMBER
   , REQUISITION_DISTRIBUTION_ID             NUMBER
   , REASON_ID                               NUMBER
   , LOT_NUMBER                              VARCHAR2(80)
   , LOT_EXPIRATION_DATE                     DATE
   , SERIAL_NUMBER                           VARCHAR2(30)
   , RECEIVING_DOCUMENT                      VARCHAR2(10)
   , DEMAND_ID                               NUMBER
   , RCV_TRANSACTION_ID                      NUMBER
   , MOVE_TRANSACTION_ID                     NUMBER
   , COMPLETION_TRANSACTION_ID               NUMBER
   , WIP_ENTITY_TYPE                         NUMBER
   , SCHEDULE_ID                             NUMBER
   , REPETITIVE_LINE_ID                      NUMBER
   , EMPLOYEE_CODE                           VARCHAR2(10)
   , PRIMARY_SWITCH                          NUMBER
   , SCHEDULE_UPDATE_CODE                    NUMBER
   , SETUP_TEARDOWN_CODE                     NUMBER
   , ITEM_ORDERING                           NUMBER
   , NEGATIVE_REQ_FLAG                       NUMBER
   , OPERATION_SEQ_NUM                       NUMBER
   , PICKING_LINE_ID                         NUMBER
   , TRX_SOURCE_LINE_ID                      NUMBER
   , TRX_SOURCE_DELIVERY_ID                  NUMBER
   , PHYSICAL_ADJUSTMENT_ID                  NUMBER
   , CYCLE_COUNT_ID                          NUMBER
   , RMA_LINE_ID                             NUMBER
   , CUSTOMER_SHIP_ID                        NUMBER
   , CURRENCY_CODE                           VARCHAR2(10)
   , CURRENCY_CONVERSION_RATE                NUMBER
   , CURRENCY_CONVERSION_TYPE                VARCHAR2(30)
   , CURRENCY_CONVERSION_DATE                DATE
   , USSGL_TRANSACTION_CODE                  VARCHAR2(30)
   , VENDOR_LOT_NUMBER                       VARCHAR2(30)
   , ENCUMBRANCE_ACCOUNT                     NUMBER
   , ENCUMBRANCE_AMOUNT                      NUMBER
   , SHIP_TO_LOCATION                        NUMBER
   , SHIPMENT_NUMBER                         VARCHAR2(30)
   , TRANSFER_COST                           NUMBER
   , TRANSPORTATION_COST                     NUMBER
   , TRANSPORTATION_ACCOUNT                  NUMBER
   , FREIGHT_CODE                            VARCHAR2(30)
   , CONTAINERS                              NUMBER
   , WAYBILL_AIRBILL                         VARCHAR2(20)
   , EXPECTED_ARRIVAL_DATE                   DATE
   , TRANSFER_SUBINVENTORY                   VARCHAR2(10)
   , TRANSFER_ORGANIZATION                   NUMBER
   , TRANSFER_TO_LOCATION                    NUMBER
   , NEW_AVERAGE_COST                        NUMBER
   , VALUE_CHANGE                            NUMBER
   , PERCENTAGE_CHANGE                       NUMBER
   , MATERIAL_ALLOCATION_TEMP_ID             NUMBER
   , DEMAND_SOURCE_HEADER_ID                 NUMBER
   , DEMAND_SOURCE_LINE                      VARCHAR2(30)
   , DEMAND_SOURCE_DELIVERY                  VARCHAR2(30)
   , ITEM_SEGMENTS                           VARCHAR2(240)
   , ITEM_DESCRIPTION                        VARCHAR2(240)
   , ITEM_TRX_ENABLED_FLAG                   VARCHAR2(1)
   , ITEM_LOCATION_CONTROL_CODE              NUMBER
   , ITEM_RESTRICT_SUBINV_CODE               NUMBER
   , ITEM_RESTRICT_LOCATORS_CODE             NUMBER
   , ITEM_REVISION_QTY_CONTROL_CODE          NUMBER
   , ITEM_PRIMARY_UOM_CODE                   VARCHAR2(3)
   , ITEM_UOM_CLASS                          VARCHAR2(10)
   , ITEM_SHELF_LIFE_CODE                    NUMBER
   , ITEM_SHELF_LIFE_DAYS                    NUMBER
   , ITEM_LOT_CONTROL_CODE                   NUMBER
   , ITEM_SERIAL_CONTROL_CODE                NUMBER
   , ITEM_INVENTORY_ASSET_FLAG               VARCHAR2(1)
   , ALLOWED_UNITS_LOOKUP_CODE               NUMBER
   , DEPARTMENT_ID                           NUMBER
   , DEPARTMENT_CODE                         VARCHAR2(10)
   , WIP_SUPPLY_TYPE                         NUMBER
   , SUPPLY_SUBINVENTORY                     VARCHAR2(10)
   , SUPPLY_LOCATOR_ID                       NUMBER
   , VALID_SUBINVENTORY_FLAG                 VARCHAR2(1)
   , VALID_LOCATOR_FLAG                      VARCHAR2(1)
   , LOCATOR_SEGMENTS                        VARCHAR2(240)
   , CURRENT_LOCATOR_CONTROL_CODE            NUMBER
   , NUMBER_OF_LOTS_ENTERED                  NUMBER
   , WIP_COMMIT_FLAG                         VARCHAR2(1)
   , NEXT_LOT_NUMBER                         VARCHAR2(80)
   , LOT_ALPHA_PREFIX                        VARCHAR2(30)
   , NEXT_SERIAL_NUMBER                      VARCHAR2(30)
   , SERIAL_ALPHA_PREFIX                     VARCHAR2(30)
   , SHIPPABLE_FLAG                          VARCHAR2(1)
   , POSTING_FLAG                            VARCHAR2(1)
   , REQUIRED_FLAG                           VARCHAR2(1)
   , PROCESS_FLAG                            VARCHAR2(1)
   , ERROR_CODE                              VARCHAR2(240)
   , ERROR_EXPLANATION                       VARCHAR2(240)
   , ATTRIBUTE_CATEGORY                      VARCHAR2(30)
   , ATTRIBUTE1                              VARCHAR2(150)
   , ATTRIBUTE2                              VARCHAR2(150)
   , ATTRIBUTE3                              VARCHAR2(150)
   , ATTRIBUTE4                              VARCHAR2(150)
   , ATTRIBUTE5                              VARCHAR2(150)
   , ATTRIBUTE6                              VARCHAR2(150)
   , ATTRIBUTE7                              VARCHAR2(150)
   , ATTRIBUTE8                              VARCHAR2(150)
   , ATTRIBUTE9                              VARCHAR2(150)
   , ATTRIBUTE10                             VARCHAR2(150)
   , ATTRIBUTE11                             VARCHAR2(150)
   , ATTRIBUTE12                             VARCHAR2(150)
   , ATTRIBUTE13                             VARCHAR2(150)
   , ATTRIBUTE14                             VARCHAR2(150)
   , ATTRIBUTE15                             VARCHAR2(150)
   , MOVEMENT_ID                             NUMBER
   , RESERVATION_QUANTITY                    NUMBER
   , SHIPPED_QUANTITY                        NUMBER
   , TRANSACTION_LINE_NUMBER                 NUMBER
   , TASK_ID                                 NUMBER(15)
   , TO_TASK_ID                              NUMBER(15)
   , SOURCE_TASK_ID                          NUMBER
   , PROJECT_ID                              NUMBER(15)
   , SOURCE_PROJECT_ID                       NUMBER
   , PA_EXPENDITURE_ORG_ID                   NUMBER
   , TO_PROJECT_ID                           NUMBER(15)
   , EXPENDITURE_TYPE                        VARCHAR2(30)
   , FINAL_COMPLETION_FLAG                   VARCHAR2(1)
   , TRANSFER_PERCENTAGE                     NUMBER
   , TRANSACTION_SEQUENCE_ID                 NUMBER
   , MATERIAL_ACCOUNT                        NUMBER
   , MATERIAL_OVERHEAD_ACCOUNT               NUMBER
   , RESOURCE_ACCOUNT                        NUMBER
   , OUTSIDE_PROCESSING_ACCOUNT              NUMBER
   , OVERHEAD_ACCOUNT                        NUMBER
   , FLOW_SCHEDULE                           VARCHAR2(1)
   , COST_GROUP_ID                           NUMBER
   , DEMAND_CLASS                            VARCHAR2(30)
   , QA_COLLECTION_ID                        NUMBER
   , KANBAN_CARD_ID                          NUMBER
   , OVERCOMPLETION_TRANSACTION_QTY          NUMBER
   , OVERCOMPLETION_PRIMARY_QTY              NUMBER
   , OVERCOMPLETION_TRANSACTION_ID           NUMBER
   , END_ITEM_UNIT_NUMBER                    VARCHAR2(60)
   , SCHEDULED_PAYBACK_DATE                  DATE
   , LINE_TYPE_CODE                          NUMBER
   , PARENT_TRANSACTION_TEMP_ID              NUMBER
   , PUT_AWAY_STRATEGY_ID                    NUMBER
   , PUT_AWAY_RULE_ID                        NUMBER
   , PICK_STRATEGY_ID                        NUMBER
   , PICK_RULE_ID                            NUMBER
   , MOVE_ORDER_LINE_ID                      NUMBER
   , TASK_GROUP_ID                           NUMBER
   , PICK_SLIP_NUMBER                        NUMBER
   , RESERVATION_ID                          NUMBER
   , COMMON_BOM_SEQ_ID                       NUMBER
   , COMMON_ROUTING_SEQ_ID                   NUMBER
   , ORG_COST_GROUP_ID                       NUMBER
   , COST_TYPE_ID                            NUMBER
   , TRANSACTION_STATUS                      NUMBER
   , STANDARD_OPERATION_ID                   NUMBER
   , TASK_PRIORITY                           NUMBER
   , WMS_TASK_TYPE                           NUMBER
   , PARENT_LINE_ID                          NUMBER
   , SOURCE_LOT_NUMBER                       VARCHAR2(80)
   , TRANSFER_COST_GROUP_ID                  NUMBER
   , LPN_ID                                  NUMBER
   , TRANSFER_LPN_ID                         NUMBER
   , WMS_TASK_STATUS                         NUMBER
   , CONTENT_LPN_ID                          NUMBER
   , CONTAINER_ITEM_ID                       NUMBER
   , CARTONIZATION_ID                        NUMBER
   , PICK_SLIP_DATE                          DATE
   , REBUILD_ITEM_ID                         NUMBER
   , REBUILD_SERIAL_NUMBER                   VARCHAR2(30)
   , REBUILD_ACTIVITY_ID                     NUMBER
   , REBUILD_JOB_NAME                        VARCHAR2(240)
   , ORGANIZATION_TYPE                       NUMBER
   , TRANSFER_ORGANIZATION_TYPE              NUMBER
   , OWNING_ORGANIZATION_ID                  NUMBER
   , OWNING_TP_TYPE                          NUMBER
   , XFR_OWNING_ORGANIZATION_ID              NUMBER
   , TRANSFER_OWNING_TP_TYPE                 NUMBER
   , PLANNING_ORGANIZATION_ID                NUMBER
   , PLANNING_TP_TYPE                        NUMBER
   , XFR_PLANNING_ORGANIZATION_ID            NUMBER
   , TRANSFER_PLANNING_TP_TYPE               NUMBER
   , SECONDARY_UOM_CODE                      VARCHAR2(240)
   , SECONDARY_TRANSACTION_QUANTITY          NUMBER
   , ALLOCATED_LPN_ID                        NUMBER
   , SCHEDULE_NUMBER                         VARCHAR2(60)
   , SCHEDULED_FLAG                          NUMBER
   , CLASS_CODE                              VARCHAR2(10)
   , SCHEDULE_GROUP                          NUMBER
   , BUILD_SEQUENCE                          NUMBER
   , BOM_REVISION                            VARCHAR2(3)
   , ROUTING_REVISION                        VARCHAR2(3)
   , BOM_REVISION_DATE                       DATE
   , ROUTING_REVISION_DATE                   DATE
   , ALTERNATE_BOM_DESIGNATOR                VARCHAR2(10)
   , ALTERNATE_ROUTING_DESIGNATOR            VARCHAR2(10)
   , TRANSACTION_BATCH_ID                    NUMBER
   , TRANSACTION_BATCH_SEQ                   NUMBER
   , OPERATION_PLAN_ID                       NUMBER
   , INTRANSIT_ACCOUNT                       NUMBER
   , FOB_POINT                               NUMBER
   , LOGICAL_TRX_TYPE_CODE                   NUMBER
   , MOVE_ORDER_HEADER_ID                    NUMBER
   , ORIGINAL_TRANSACTION_TEMP_ID            NUMBER
   , SERIAL_ALLOCATED_FLAG                   VARCHAR2(1)
   , TRX_FLOW_HEADER_ID                      NUMBER
   );

   TYPE mmtt_type
   IS TABLE OF task_rec_type INDEX BY binary_integer;

   PROCEDURE cartonize
                  ( x_return_status    OUT NOCOPY VARCHAR2,
                    x_msg_count        OUT NOCOPY NUMBER,
                    x_msg_data         OUT NOCOPY VARCHAR2,
                    x_task_table       OUT NOCOPY mmtt_type,
                    p_organization_id  IN  NUMBER,
                    p_task_table       IN  mmtt_type
                    );

END WMS_CARTONIZATION_USER_PUB;

/
