--------------------------------------------------------
--  DDL for Package WMS_TASK_MGMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_TASK_MGMT_PUB" AUTHID CURRENT_USER AS
/*$Header: WMSTKMPS.pls 120.1 2007/12/28 05:47:01 anviswan noship $ */

TYPE task_output_rectype
IS
        RECORD
        (
        TASK_ID                    NUMBER,
        TRANSACTION_NUMBER         NUMBER,
        PARENT_LINE_ID             NUMBER,
        INVENTORY_ITEM_ID          NUMBER,
        ITEM                       VARCHAR2(240),
        ITEM_DESCRIPTION           VARCHAR2(240),
        UNIT_WEIGHT                NUMBER,
        WEIGHT_UOM_CODE            VARCHAR2(3),
        DISPLAY_WEIGHT             NUMBER,
        UNIT_VOLUME                NUMBER,
        VOLUME_UOM_CODE            VARCHAR2(3),
        DISPLAY_VOLUME             NUMBER,
        TIME_ESTIMATE              NUMBER,
        ORGANIZATION_ID            NUMBER,
        ORGANIZATION_CODE          VARCHAR2(3),
        REVISION                   VARCHAR2(3),
        SUBINVENTORY               VARCHAR2(10),
        LOCATOR_ID                 NUMBER,
        LOCATOR                    VARCHAR2(240),
        TRANSACTION_TYPE_ID        NUMBER,
        TRANSACTION_ACTION_ID      NUMBER,
        TRANSACTION_SOURCE_TYPE_ID NUMBER,
        TRANSACTION_SOURCE_TYPE    VARCHAR2(240),
        TRANSACTION_SOURCE_ID      NUMBER,
        TRANSACTION_SOURCE_LINE_ID NUMBER,
        TO_ORGANIZATION_ID         NUMBER,
        TO_ORGANIZATION_CODE       VARCHAR2(3),
        TO_SUBINVENTORY            VARCHAR2(10),
        TO_LOCATOR_ID              NUMBER,
        TO_LOCATOR                 VARCHAR2(204),
        TRANSACTION_UOM            VARCHAR2(3),
        TRANSACTION_QUANTITY       NUMBER,
        USER_TASK_TYPE_ID          NUMBER,
        USER_TASK_TYPE             VARCHAR2(4),
        PERSON_ID                  NUMBER,
        PERSON_ID_ORIGINAL         NUMBER,
        PERSON                     VARCHAR2(240),
        EFFECTIVE_START_DATE DATE,
        EFFECTIVE_END_DATE DATE,
        PERSON_RESOURCE_ID    NUMBER,
        PERSON_RESOURCE_CODE  VARCHAR2(10),
        MACHINE_RESOURCE_ID   NUMBER,
        MACHINE_RESOURCE_CODE VARCHAR2(10),
        EQUIPMENT_INSTANCE    VARCHAR2(30),
        STATUS_ID             NUMBER,
        STATUS_ID_ORIGINAL    NUMBER,
        STATUS                VARCHAR2(80),
        CREATION_TIME DATE,
        DISPATCHED_TIME DATE,
        LOADED_TIME DATE,
        DROP_OFF_TIME DATE,
        MMTT_LAST_UPDATE_DATE DATE,
        MMTT_LAST_UPDATED_BY NUMBER,
        WDT_LAST_UPDATE_DATE DATE,
        WDT_LAST_UPDATED_BY NUMBER,
        PRIORITY            NUMBER,
        PRIORITY_ORIGINAL   NUMBER,
        TASK_TYPE_ID        NUMBER,
        TASK_TYPE           VARCHAR2(80),
        MOVE_ORDER_LINE_ID  NUMBER,
        PICK_SLIP_NUMBER    NUMBER,
        CARTONIZATION_ID    NUMBER,
        ALLOCATED_LPN_ID    NUMBER,
        CONTAINER_ITEM_ID   NUMBER,
        CONTENT_LPN_ID      NUMBER,
        TO_LPN_ID           NUMBER,
        CONTAINER_ITEM      VARCHAR2(240),
        CARTONIZATION_LPN   VARCHAR2(30),
        ALLOCATED_LPN       VARCHAR2(30),
        CONTENT_LPN         VARCHAR2(30),
        TO_LPN              VARCHAR2(30),
        REFERENCE           VARCHAR2(240),
        REFERENCE_ID        NUMBER,
        CUSTOMER_ID         NUMBER,
        CUSTOMER            VARCHAR2(240),
        SHIP_TO_LOCATION_ID NUMBER,
        SHIP_TO_STATE       VARCHAR2(60),
        SHIP_TO_COUNTRY     VARCHAR2(60),
        SHIP_TO_POSTAL_CODE VARCHAR2(60),
        DELIVERY_ID         NUMBER,
        DELIVERY            VARCHAR2(30),
        SHIP_METHOD         VARCHAR2(80),
        CARRIER_ID          NUMBER,
        CARRIER             VARCHAR2(360),
        SHIPMENT_DATE DATE,
        SHIPMENT_PRIORITY   VARCHAR2(80),
        WIP_ENTITY_TYPE     NUMBER,
        WIP_ENTITY_ID       NUMBER,
        ASSEMBLY_ID         NUMBER,
        ASSEMBLY            VARCHAR2(240),
        LINE_ID             NUMBER,
        LINE                VARCHAR2(10),
        DEPARTMENT_ID       NUMBER ,
        DEPARTMENT          VARCHAR2(10),
        SOURCE_HEADER       VARCHAR2(240),
        LINE_NUMBER         VARCHAR2(240),
        OPERATION_PLAN_ID   NUMBER,
        OPERATION_PLAN      VARCHAR2(80),
        RESULT              VARCHAR2(1),
        ERROR               VARCHAR2(240),
        IS_MODIFIED         VARCHAR2(1),
        /*FROM_LPN_ID         NUMBER,
        FROM_LPN            VARCHAR2(30),
        NUM_OF_CHILD_TASKS  NUMBER ,
        EXPANSION_CODE      VARCHAR2(1),
        PLANS_TASKS         VARCHAR2(80),
        OP_PLAN_INSTANCE_ID NUMBER,
        OPERATION_SEQUENCE  NUMBER,
        TRANSACTION_SET_ID  NUMBER,
        PICKED_LPN_ID       NUMBER,
        PICKED_LPN          VARCHAR2(30),
        LOADED_LPN          VARCHAR2(30),
        LOADED_LPN_ID       NUMBER,
        DROP_LPN            VARCHAR2(30),
	SECONDARY_TRANSACTION_QUANTITY NUMBER,
	SECONDARY_TRANSACTION_UOM VARCHAR2(3),
	PRIMARY_PRODUCT VARCHAR2(240));*/
	--Munish added columns with new sequence as in table wms_waveplan_tasks_temp
	EXPANSION_CODE      VARCHAR2(1),
        FROM_LPN            VARCHAR2(30),
        FROM_LPN_ID         NUMBER,
        NUM_OF_CHILD_TASKS  NUMBER ,
        OPERATION_SEQUENCE  NUMBER,
        OP_PLAN_INSTANCE_ID NUMBER,
        PLANS_TASKS         VARCHAR2(80),
        TRANSACTION_SET_ID  NUMBER,
        PICKED_LPN_ID       NUMBER,
        PICKED_LPN          VARCHAR2(30),
        LOADED_LPN          VARCHAR2(30),
        LOADED_LPN_ID       NUMBER,
        DROP_LPN            VARCHAR2(30) ,
--Munish added 3 new columns got added in R12 in table wms_waveplan_tasks_temp
	secondary_transaction_quantity   NUMBER ,
        secondary_transaction_uom VARCHAR2(3),
        primary_product     VARCHAR2(240) ,
	--anjana
	load_seq_number     NUMBER );--this column was added to wms_waveplan_tasks_temp as a part of OTM project.

TYPE task_input_rectype
IS
        RECORD
        (
        field_name  wms_saved_queries.field_name%TYPE,
        field_value wms_saved_queries.field_value%TYPE );

TYPE task_tab_type
IS
        TABLE OF task_output_rectype INDEX BY binary_integer;

TYPE main_tab_type
IS
        TABLE OF task_input_rectype INDEX BY binary_integer;

TYPE query_tab_type
IS
        TABLE OF task_input_rectype INDEX BY binary_integer;
        g_main_tab main_tab_type;

TYPE op_plan_rec
is
        RECORD
        (
        system_task_type  NUMBER,
        organization_id   NUMBER,
        eabled_flag       VARCHAR2(1),
        activity_type_id  NUMBER,
        common_to_all_org VARCHAR2(1),
        plan_type_id      NUMBER );

TYPE task_qty_rec_type
IS
        RECORD
        (
        quantity      NUMBER ,
        uom           VARCHAR2(3) ,
        return_status VARCHAR2(1) );
TYPE task_rec_type
IS
        RECORD
        (
        transaction_temp_id NUMBER ,
        return_status       VARCHAR2(1) );
TYPE task_detail_rec_type
IS
        RECORD
        (
        Parent_task_id NUMBER,         --This will correspond to the record in task table
        Lot_number     VARCHAR2 (30),
        Lot_expiration_date DATE,
        Lot_Primary_quantity     NUMBER,
        Lot_Transaction_quantity NUMBER,
        From_serial_number       VARCHAR2 (30),
        To_serial_number         VARCHAR2 (30),
        Number_of_Serials        NUMBER ,  --Number of Serials
        Lot_status_id            NUMBER,   --Material Status Id.
        Serial_status_id         NUMBER    --Material Status Id.
        );
TYPE QTY_CHANGED_REC_TYPE
IS
        RECORD
        (
        transaction_quantity NUMBER ,
        primary_quantity     NUMBER );
TYPE NEW_TASK_REC
IS
        RECORD
        (
        transaction_temp_id NUMBER );
TYPE task_qty_tbl_type
IS
        TABLE OF task_qty_rec_type INDEX BY BINARY_INTEGER;
TYPE task_tbl_type
IS
        TABLE OF task_rec_type INDEX BY BINARY_INTEGER;
TYPE task_detail_tbl_type
IS
        TABLE OF task_detail_rec_type INDEX BY BINARY_INTEGER;
TYPE QTY_CHANGED_TBL_TYPE
IS
        TABLE OF QTY_CHANGED_REC_TYPE INDEX BY BINARY_INTEGER;
TYPE new_task_tbl
IS
        TABLE OF NEW_TASK_REC INDEX BY BINARY_INTEGER;
        task_detail_table task_detail_tbl_type;
        new_task_table new_task_tbl;

TYPE task_record_type
is
        RECORD
        (
        transaction_number NUMBER,
        status             VARCHAR2(1),
        error              VARCHAR2(230) );


PROCEDURE modify_task ( p_transaction_number IN NUMBER DEFAULT NULL ,
        p_task_table                         IN WMS_TASK_MGMT_PUB.task_tab_type ,
        p_new_task_status                    IN NUMBER DEFAULT NULL ,
        p_new_task_priority                  IN NUMBER DEFAULT NULL ,
        p_new_task_type                      IN VARCHAR2 DEFAULT NULL ,
        p_new_carton_lpn_id                  IN NUMBER DEFAULT NULL ,
        p_new_operation_plan_id              IN NUMBER DEFAULT NULL ,
        p_person_id                          IN NUMBER DEFAULT NULL ,
        p_commit                             IN VARCHAR2 DEFAULT FND_API.G_FALSE ,
        x_updated_tasks OUT NOCOPY WMS_TASK_MGMT_PUB.task_tab_type ,
        x_return_status OUT NOCOPY VARCHAR2 ,
        x_msg_count OUT NOCOPY     NUMBER ,
        x_msg_data OUT NOCOPY      VARCHAR2 );

PROCEDURE query_task ( p_transaction_number IN NUMBER DEFAULT NULL ,
        p_query_name                        IN VARCHAR2 ,
        x_task_tab OUT NOCOPY task_tab_type ,
        x_return_status OUT NOCOPY VARCHAR2 ,
        x_msg_count OUT NOCOPY     NUMBER ,
        x_msg_data OUT NOCOPY      VARCHAR2 );

PROCEDURE initialize_main_table;


PROCEDURE split_task ( p_source_transaction_number IN NUMBER DEFAULT NULL ,
        p_split_quantities                         IN task_qty_tbl_type ,
        p_commit                                   IN VARCHAR2 DEFAULT FND_API.G_FALSE ,
        x_resultant_tasks OUT NOCOPY WMS_TASK_MGMT_PUB.task_tab_type ,
        x_resultant_task_details OUT NOCOPY task_detail_tbl_type ,
        x_return_status OUT NOCOPY VARCHAR2 ,
        x_msg_count OUT NOCOPY     NUMBER ,
        x_msg_data OUT NOCOPY      VARCHAR2 );

procedure delete_tasks ( p_transaction_number IN NUMBER DEFAULT NULL ,
        p_commit                              IN VARCHAR2 DEFAULT FND_API.G_FALSE ,
        p_wms_task                            IN WMS_TASK_MGMT_PUB.task_tab_type ,
        x_undeleted_tasks OUT NOCOPY WMS_TASK_MGMT_PUB.task_tab_type ,
        x_return_status OUT NOCOPY VARCHAR2 ,
        x_msg_count OUT NOCOPY     NUMBER ,
        x_msg_data OUT NOCOPY      VARCHAR2 );

--praveen
PROCEDURE cancel_task(
   p_transaction_number            IN              NUMBER DEFAULT NULL,
   p_commit                        IN              VARCHAR2 DEFAULT fnd_api.g_false,
   p_wms_task                      IN              WMS_TASK_MGMT_PUB.task_tab_type,
   x_unprocessed_crossdock_tasks   OUT NOCOPY      WMS_TASK_MGMT_PUB.task_tab_type,
   x_return_status                 OUT NOCOPY      VARCHAR2,
   x_msg_count                     OUT NOCOPY      NUMBER,
   x_msg_data                      OUT NOCOPY      VARCHAR2
);

END WMS_TASK_MGMT_PUB;

/
