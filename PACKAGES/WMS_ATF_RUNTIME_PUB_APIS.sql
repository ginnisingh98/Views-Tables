--------------------------------------------------------
--  DDL for Package WMS_ATF_RUNTIME_PUB_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_ATF_RUNTIME_PUB_APIS" AUTHID CURRENT_USER AS
/* $Header: WMSATFRS.pls 120.2.12000000.1 2007/01/16 06:51:01 appldev ship $*/

--
-- File        : WMSATFRB.pls
-- Content     : WMS_ATF_RUNTIME_PUB_APIS package specification
-- Description : WMS ATF Run-time APIs
-- Notes       :
-- Modified    : 7/24/2003 lezhang created



-- API name    :
-- Type        : Public
-- Function    :
-- Pre-reqs    :
--
--
-- Parameters  :
--   Output:
--
--   Input:
--
--
-- Version
--   Currently version is 1.0
--

/**Constants defined for Inspection Flag in validate_operation
*/
G_NO_INSPECTION      CONSTANT NUMBER:=1;
G_PARTIAL_INSPECTION CONSTANT NUMBER:=2;
G_FULL_INSPECTION    CONSTANT NUMBER:=3;

/**Constants defined for Load Flag in validate_operation
*/
G_NO_LOAD      CONSTANT NUMBER:=1;
G_PARTIAL_LOAD CONSTANT NUMBER:=2;
G_FULL_LOAD    CONSTANT NUMBER:=3;


/**Constants defined for Drop Flag in validate_operation
*/
G_NO_DROP      CONSTANT NUMBER:=1;
G_PARTIAL_DROP CONSTANT NUMBER:=2;
G_FULL_DROP    CONSTANT NUMBER:=3;

/**Constants defined for Crossdock Flag in validate_operation
*/
G_NO_CROSSDOCK      CONSTANT NUMBER:=1;
G_PARTIAL_CROSSDOCK CONSTANT NUMBER:=2;
G_FULL_CROSSDOCK    CONSTANT NUMBER:=3;


TYPE task_id_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

/*Error Code Definitions for THE APIs*/

INVALID_DOC_ID                 CONSTANT NUMBER := -20001;

INVALID_PLAN_ID                CONSTANT NUMBER := -20002;

PLAN_INSTANCE_EXISTS           CONSTANT NUMBER := -20003;

PLAN_INSTANCE_NOT_EXITS        CONSTANT NUMBER := -20004;

INVALID_PLAN_INSTANCE          CONSTANT NUMBER := -20005;

OPERATION_INSTANCE_EXISTS      CONSTANT NUMBER := -20006;

OPERATION_INSTANCE_NOT_EXISTS  CONSTANT NUMBER := -20007;

INVALID_OPERATION_INSTANCE     CONSTANT NUMBER := -20008;

INVALID_TASK                   CONSTANT NUMBER := -20009;

TASK_NOT_EXISTS                CONSTANT NUMBER := -20010;

INVALID_INPUT                  CONSTANT NUMBER := -20011;

DERIVE_DEST_SUGGESTIONS_FAILED CONSTANT NUMBER := -20012;

DATA_INCONSISTENT              CONSTANT NUMBER := -20013;

INVALID_STATUS_FOR_OPERATION   CONSTANT NUMBER := -20014;

COMPLETE_PENDING_OP            CONSTANT NUMBER := -20015;

 /**
    *    Init_OP_Plan_Instance:
    * <p>For a given document record,this API initialises the Operation Plan Instance as well as the
    *      Operation instance for the first plan detail.</p>
    *  @param x_return_status  -Return Status
    *  @param x_msg_data       -Returns Message Data
    *  @param x_msg_count      -Returns the message count
    *  @param x_error_code     -Returns Appropriate error code in case of any error.
    *  @param p_source_task_id -Identifier of the document record.
    *  @param p_activity_id    -Identifier of the Activity Type.
    *
   **/
  PROCEDURE INIT_OP_PLAN_INSTANCE(
    x_return_status    OUT  NOCOPY    VARCHAR2
  , x_msg_data         OUT  NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
  , x_msg_count        OUT  NOCOPY    NUMBER
  , x_error_code       OUT  NOCOPY    NUMBER
  , p_source_task_id   IN             NUMBER
  , p_activity_id IN             NUMBER
  );

  /**
  *   Activate_operation_instance
  *   <p>For a given document record,this API activates the
  *      Operation Instance as well as the task
  *      associated with the current operation</p>
  *
  *  @param x_return_status    -Return Status
  *  @param x_msg_data         -Returns the Error message Data
  *  @param x_msg_count        -Returns the message count
  *  @param x_error_code       -Returns appropriate error code in case of any error.
  *  @param p_source_task_id   -Identifier of the document record.
  *  @param p_activity_id      -Identifier of the Activity Type.
  *  @param p_task_execute_rec -Input of WMS_DISPATCHED_TASKS to be created for the task.
  **/

  PROCEDURE ACTIVATE_OPERATION_INSTANCE(
       x_return_status     OUT  NOCOPY  VARCHAR2
      ,x_msg_data          OUT  NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE
      ,x_msg_count         OUT  NOCOPY  NUMBER
      ,x_error_code        OUT  NOCOPY  NUMBER
      ,x_drop_lpn_option   OUT  NOCOPY  NUMBER
      ,x_consolidation_method_id   OUT NOCOPY  NUMBER
      ,p_source_task_id    IN           NUMBER
      ,p_activity_id       IN           NUMBER
      ,p_operation_type_id IN           NUMBER
      ,p_task_execute_rec  IN           WMS_DISPATCHED_TASKS%ROWTYPE );

/**  Complete_Operation_instance
  *   <p>This procedure completes the current operation and  creates the next operation instance.
  *     If the operation is the last operation the plan is marked  as 'COMPLETED' and archived.</p>
  *
  *  @param x_return_status      -Return Status
  *  @param x_msg_data           -Returns the Error message Data
  *  @param x_msg_count          -Returns the message count
  *  @param x_error_code         -Returns appropriate error code in case of any error.
  *  @param p_source_task_id     -Identifier of the document record.
  *  @param p_activity_id        -Lookup Code for the Activity Type
  *  @param p_operation_type_id  -Input parameter containing the lookup code for the Operation
  *                               Type. Should be passed for inspect operation.
 **/
PROCEDURE Complete_Operation_Instance(
		 x_return_status     OUT  NOCOPY  VARCHAR2
      ,x_msg_data          OUT  NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE
      ,x_msg_count      OUT NOCOPY    NUMBER
		,x_error_code        OUT  NOCOPY  NUMBER
		,p_source_task_id    IN           NUMBER
		,p_activity_id       IN           NUMBER
		,p_operation_type_id IN           NUMBER );


/**  Validate_Operation
  *   <p>For a given criteria (LPN, Item or task), this API returns certain information,
  *      operation type in particular, about the current pending operation.
  *      Based on the return value, it is caller procedure's responsibility to determine
  *      whether user should be allowed to continue his/her operation.
  *  @param x_return_status        -Return Status
  *  @param x_msg_data             -Returns the Error message Data
  *  @param x_msg_count            -Returns the message count
  *  @param x_error_code           -Returns appropriate error code in case of any error.
  *  @param x_inspection_flag      -This parameter indicates the inspection requirement for the current pending
  *                                 operation instances for the given criteria. 1. No inspection is required;
  *                                  2. Part of the given criteria requires inspection;
  *                                  3. All operation instances for the given criteria require inspection
  *  @param x_drop_flag            -This parameter indicates the drop operation for the current pending
  *                                 operation instances for the given criteria.
  *                                 1. No drop is required; 2. Part of the given criteria requires drop;
  *                                 3. All operation instances for the given criteria require drop
  *  @param x_load_flag            -This parameter indicates the load operation for the current pending
  *                                 operation instances for the given criteria. 1. No load operation;
  *                                  2. Part of the given criteria requires load;
  *                                  3. All operation instances for the given criteria require load.

  *  @param x_crossdock_flag       -This parameter indicates the crossdock operation for the current pending
  *                                 or active operation instances for the given criteria.
  *                                  1. No crossdock operation;
  *                                  2. Part of the given criteria requires crossdock;
  *                                  3. All operation instances for the given criteria require crossdock.       *                                 IMPORTANT: For crossdock operation, we also set load/drop flag and quantity.
  *                                 This is because from crossdock itself we don not know if it is a load or
  *                                 drop, and we do need to know this.
  *
  *  @param x_load_prim_quantity   -If LPN/Item or move order line is passed, sum of the primary quantity from
  *                                 the document table for those document records whose pending operation is
  *                                 'Load'.
  *  @param x_drop_prim_Quantity   -If LPN/Item or move order line is passed, sum of the primary quantity from
  *                                 the document table for those document records whose pending operation is
  *                                 'Drop'.
  *  @param x_inspect_prim_Quantity-If LPN/Item or move order line is passed, sum of the primary quantity from
  *                                 the document table for those document records whose pending operation is
  *                                 'Inspect'.                                                                  *  @param x_crossdock_prim_quantity   -If LPN/Item or move order line is passed, sum of the primary quantity from
  *                               the document table for those document records whose pending operation is
  *                                 'Load'.

  *  @param p_source_task_id       -Identifier of the document record.
  *  @param p_move_order_line_id   -Move Order line Id that has to be validated.
  *  @param p_inventory_item_id    -Inventory Item Id that has to be validated.
  *  @param p_LPN_ID               -LPN id of the LPN that has to be validated.
  *  @param p_activity_type_id     -Lookup containing the Activity to be performed.
  **/
    PROCEDURE validate_operation
    (
     x_return_status         OUT  NOCOPY  VARCHAR2 ,
     x_msg_data              OUT  NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE ,
     x_msg_count             OUT  NOCOPY  NUMBER,
     x_error_code            OUT  NOCOPY  NUMBER ,
     x_inspection_flag       OUT  NOCOPY  NUMBER ,
     x_load_flag             OUT  NOCOPY  NUMBER ,
     x_drop_flag             OUT  NOCOPY  NUMBER ,
     x_crossdock_flag        OUT  NOCOPY  NUMBER ,
     x_load_prim_quantity    OUT  NOCOPY  NUMBER ,
     x_drop_prim_quantity    OUT  NOCOPY  NUMBER ,
     x_inspect_prim_quantity OUT  NOCOPY  NUMBER ,
     x_crossdock_prim_quantity  OUT NOCOPY  NUMBER ,
     p_source_task_id        IN           NUMBER ,
     p_move_order_line_id    IN           NUMBER ,
     p_inventory_item_id     IN           NUMBER ,
     p_LPN_ID                IN           NUMBER ,
     p_activity_type_id      IN           NUMBER ,
     p_organization_id       IN           NUMBER ,
     p_lot_number            IN           VARCHAR2 DEFAULT NULL ,
     p_revision              IN           VARCHAR2 DEFAULT NULL);



  /*
  *    Following is overloaded procedure of the above
    *  without x_crossdock_prim_quantity and x_crossdock_flag.
    *  This is for the convenience of existing RCV call.
  */

  PROCEDURE validate_operation
    (
     x_return_status         OUT  NOCOPY  VARCHAR2 ,
     x_msg_data              OUT  NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE ,
     x_msg_count             OUT  NOCOPY  NUMBER,
     x_error_code            OUT  NOCOPY  NUMBER ,
     x_inspection_flag       OUT  NOCOPY  NUMBER ,
     x_load_flag             OUT  NOCOPY  NUMBER ,
     x_drop_flag             OUT  NOCOPY  NUMBER ,
     x_load_prim_quantity    OUT  NOCOPY  NUMBER ,
     x_drop_prim_quantity    OUT  NOCOPY  NUMBER ,
     x_inspect_prim_quantity OUT  NOCOPY  NUMBER ,
     p_source_task_id        IN           NUMBER ,
     p_move_order_line_id    IN           NUMBER ,
     p_inventory_item_id     IN           NUMBER ,
     p_LPN_ID                IN           NUMBER ,
     p_activity_type_id      IN           NUMBER ,
     p_organization_id       IN           NUMBER ,
     p_lot_number            IN           VARCHAR2 DEFAULT NULL ,
     p_revision              IN           VARCHAR2 DEFAULT NULL
     );



/**
  *    Split_Operation_instance
  *   <p>This procedure splits the operation plan,parent document
  *   record accordingly.</p>
  *
  *  @param x_return_status     -Return Status
  *  @param x_msg_data          -Returns the Error message Data
  *  @param x_msg_count         -Returns the message count
  *  @param x_error_code        -Returns appropriate error code in case of an error .
  *  @param p_source_task_id    -Identifier of the source document record
  *  @param p_activity_type_id  - Lookup code of the Activity type Id
  *  @param p_new_Task_id_table -PL/SQL table of Numbers of the MMTT ids
  **/
PROCEDURE   Split_Operation_Instance(
		x_return_status     OUT  NOCOPY  VARCHAR2 ,
		x_msg_data          OUT  NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE ,
		x_msg_count         OUT  NOCOPY  NUMBER,
		x_error_code        OUT  NOCOPY  NUMBER ,
		p_source_task_id    IN           NUMBER ,
		p_activity_type_id  IN           NUMBER ,
		p_new_task_id_table IN           task_id_table_type);



/**
  *   Cleanup_operation_instance
  *   <p>This procedure reverts the status of current operation
  *   instance whenever any processing exception occurs i.e. ,
  *   when user presses F2 or transaction manager errors
  *   out.</p>
  *
  *  @param x_return_status    Return Status
  *  @param x_msg_data         REturns the Message Data
  *  @param x_msg_count        Returns the Error Message
  *  @param x_error_code       Returns appropriate error code in case of an error .
  *  @param p_source_task_id   Identifier of the source document record
  *  @param p_activity_type_id Lookup code of the Activity type Id
  **/
 PROCEDURE   Cleanup_Operation_Instance(
		x_return_status     OUT  NOCOPY  VARCHAR2,
		x_msg_data          OUT  NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE,
		x_msg_count         OUT  NOCOPY  NUMBER,
		x_error_code        OUT  NOCOPY  NUMBER,
		p_source_task_id    IN           NUMBER,
		p_activity_type_id  IN           NUMBER );

/**
  *   Cancel_operation_Plan
  *   <p>This procedure cancels the operation plan(s). It is called from control board</p>
  *
  *  @param x_return_status    Return Status
  *  @param x_msg_data         Returns the Message Data
  *  @param x_msg_count        Returns the Error Message
  *  @param x_error_code       Returns appropriate error code in case of an error .
  *  @param p_source_task_id   Identifier of the source document record
  *  @param p_activity_type_id Lookup code of the Activity type Id
  **/
 PROCEDURE  Cancel_Operation_Plan(
		x_return_status     OUT  NOCOPY  VARCHAR2,
		x_msg_data          OUT  NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE,
		x_msg_count         OUT  NOCOPY  NUMBER,
		x_error_code        OUT  NOCOPY  NUMBER,
		p_source_task_id    IN           NUMBER,
		p_activity_type_id  IN           NUMBER,
		p_retain_mmtt       IN   VARCHAR2 DEFAULT 'N',
		p_mmtt_error_code   IN   VARCHAR2 DEFAULT NULL,
	        p_mmtt_error_explanation   IN   VARCHAR2 DEFAULT NULL
		);


/**
  *   Abort_operation_Plan
  *   <p>This procedure aborts the operation plan(s). </p>
  *
  *  @param x_return_status    Return Status
  *  @param x_msg_data         Returns the Message Data
  *  @param x_msg_count        Returns the Error Message
  *  @param x_error_code       Returns appropriate error code in case of an error .
  *  @param p_source_task_id   Identifier of the source document record
  *  @param p_activity_type_id Lookup code of the Activity type Id
  **/
   PROCEDURE  Abort_Operation_Plan(
		x_return_status     OUT  NOCOPY  VARCHAR2,
		x_msg_data          OUT  NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE,
		x_msg_count         OUT  NOCOPY  NUMBER,
		x_error_code        OUT  NOCOPY  NUMBER,
		p_source_task_id    IN           NUMBER,
		p_activity_type_id  IN           NUMBER,
		p_for_manual_drop   IN  BOOLEAN DEFAULT FALSE
);

/**
  *   Rollback_operation_Plan
  *   <p>This procedure rollsback the operation plan. </p>
  *
  *  @param x_return_status    Return Status
  *  @param x_msg_data         Returns the Message Data
  *  @param x_msg_count        Returns the Error Message
  *  @param x_error_code       Returns appropriate error code in case of an error .
  *  @param p_source_task_id   Identifier of the source document record
  *  @param p_activity_type_id Lookup code of the Activity type Id
  **/
   PROCEDURE  Rollback_Operation_Plan(
		x_return_status     OUT  NOCOPY  VARCHAR2,
		x_msg_data          OUT  NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE,
		x_msg_count         OUT  NOCOPY  NUMBER,
		x_error_code        OUT  NOCOPY  NUMBER,
		p_source_task_id    IN           NUMBER,
		p_activity_type_id  IN           NUMBER );

/**
  *   Check_Plan_Status
  *   <p>This procedure returns the operation plan instance
  *   status for a given source task ID and activity.</p>
  *  @param x_return_status    Return Status
  *  @param x_msg_data         Returns the Message Data
  *  @param x_msg_count        Returns the Error Message
  *  @param x_error_code       Returns appropriate error code in case of an error .
  *  @param x_plan_status      Returns the Status of the Plan
  *  @param p_source_task_id   Identifier of the source document record
  *  @param p_activity_type_id Lookup code of the Activity type Id
  **/
   PROCEDURE  Check_Plan_Status(
		x_return_status     OUT  NOCOPY  VARCHAR2,
		x_msg_data          OUT  NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE,
		x_msg_count         OUT  NOCOPY  NUMBER,
		x_error_code        OUT  NOCOPY  NUMBER,
      x_plan_status       OUT  NOCOPY  NUMBER,
		p_source_task_id    IN           NUMBER,
		p_activity_type_id  IN           NUMBER );

END WMS_ATF_RUNTIME_PUB_APIS;

 

/
