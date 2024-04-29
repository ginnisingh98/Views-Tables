--------------------------------------------------------
--  DDL for Package WMS_OP_RUNTIME_PVT_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_OP_RUNTIME_PVT_APIS" AUTHID CURRENT_USER AS
   /*$Header: WMSOPPVS.pls 120.0.12000000.1 2007/01/16 06:54:59 appldev ship $*/

  /**
   * <p>Procedure:<b>Insert_Plan_instance</b>
   *    This procedure inserts data into the table WMS_OP_PLAN_INSTANCES.</p>
   * @param p_insert_rec          - Record Variable of type WMS_OP_PLAN_INSTANCES%rowtype
   * @param x_return_status       - Return Status
   * @param x_msg_count           - Returns the Message Count
   * @param x_msg_data            - Returns Error Message
   */
  PROCEDURE insert_plan_instance(
    p_insert_rec          IN            wms_op_plan_instances%ROWTYPE
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
  );

  /**
   * <p>Procedure:<b>Update_Plan_instance</b>
   *    This procedure updates data into the table WMS_OP_PLAN_INSTANCES.</p>
   * @param p_insert_rec          - Record Variable of type WMS_OP_PLAN_INSTANCES%rowtype
   * @param x_return_status      - Return Status
   * @param x_msg_count          - Returns Message Count
   * @param x_msg_data           - Returns Error Message
   */
  PROCEDURE update_plan_instance(
    p_update_rec          IN            wms_op_plan_instances%ROWTYPE
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
  );

  /**
     * <p>Procedure:<b>Delete_Plan_instance</b>
     *    This procedure inserts data into the table WMS_OP_PLAN_INSTANCES.</p>
     * @param p_op_plan_instance_id - Operation Plan Instance Id of the Plan that has to be deleted
     * @param x_return_status      - Return Status
     * @param x_msg_count          - Returns Message Count
     * @param x_msg_data           - Returns Error Message
     */
  PROCEDURE delete_plan_instance(
    p_op_plan_instance_id IN            NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
  );

    /**
      * <p>Procedure:<b>Archive_Plan_instance</b>
      *    This procedure inserts data into the table WMS_OP_PLAN_INSTANCES.</p>
      * @param p_op_plan_instance_id - Operation Plan Instance Id of the Plan that has to be archived.
      * @param p_inventory_item_id     Inventory Item Id of the Plan
      * @param p_transaction_quantity  Transaction Quantitity of the Plan
      * @param p_transaction_uom       Transaction UOM of the Plan
      * @param x_return_status      - Return Status
      * @param x_msg_count          - Returns Message Count
      * @param x_msg_data           - Returns Error Message
      */
        PROCEDURE archive_plan_instance(
          p_op_plan_instance_id IN            NUMBER
        , x_return_status       OUT NOCOPY    VARCHAR2
        , x_msg_count           OUT NOCOPY    NUMBER
        , x_msg_data            OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE);

 /**
     * <p>Procedure:<b>Complete_Plan_instance</b>
     *    This procedure inserts data into the table WMS_OP_PLAN_INSTANCES.</p>
     * @param p_op_plan_instance_id - Operation Plan Instance Id of the Plan that has to be completed.
     * @param x_return_status      - Return Status
     * @param x_msg_count          - Returns Message Count
     * @param x_msg_data           - Returns Error Message
     */
    PROCEDURE complete_plan_instance(
       p_op_plan_instance_id IN            NUMBER
     , x_return_status       OUT NOCOPY    VARCHAR2
     , x_msg_count           OUT NOCOPY    NUMBER
     , x_msg_data            OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
     );

  /**
    * <p>Procedure:<b>Insert_operation_instance</b>
    *    This procedure inserts data into the table WMS_OP_OPERATION_INSTANCES.</p>
    * @param p_insert_rec            - Record Variable of type WMS_OP_OPERATION_INSTANCES%rowtype
    * @param x_return_status         - Return Status
    * @param x_msg_count             - Returns Message Count
    * @param x_msg_data              - Returns Error Message
    */
  PROCEDURE insert_operation_instance(
    p_insert_rec    IN            wms_op_operation_instances%ROWTYPE
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
  );

  /**
      * <p>Procedure:<b>Update_Operation_instance</b>
      *    This procedure updates data into the table WMS_OP_PLAN_INSTANCES.</p>
      * @param p_update_rec            - Record Variable of type WMS_OP_OPERATION_INSTANCES%rowtype
      * @param x_return_status         - Return Status
      * @param x_msg_count             - Returns Message Count
      * @param x_msg_data              - Returns Error Message
      */
  PROCEDURE update_operation_instance(
    p_update_rec    IN            wms_op_operation_instances%ROWTYPE
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
  );

  /**
      * <p>Procedure:<b>Delete_Operation_instance</b>
      *    This procedure deletes the data in the table WMS_OP_PLAN_INSTANCES.</p>
      * @param p_op_plan_instance_id     - Plan Instance Id of all the Operations that has to be deleted
      * @param x_return_status        - Return Status
      * @param x_msg_count             - Returns Message Count
      * @param x_msg_data              - Returns Error Message
      */
  PROCEDURE delete_operation_instance(
    p_operation_instance_id            NUMBER
  , x_return_status         OUT NOCOPY VARCHAR2
  , x_msg_count             OUT NOCOPY NUMBER
  , x_msg_data              OUT NOCOPY fnd_new_messages.MESSAGE_TEXT%TYPE
  );


  /**
      * <p>Procedure:<b>Update_Dispatched_tasks</b>
      *    This procedure updates the task records in WMS_DISPATCHED_TASKS</p>
      * @param p_wdt_rec               - WDT record that has to be updated.
      * @param x_return_status         - Return Status
      * @param x_msg_count             - Returns Message Count
      * @param x_msg_data              - Returns Error Message
      */
  PROCEDURE update_dipatched_tasks(
    p_wdt_rec       IN            wms_dispatched_tasks%ROWTYPE
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
  );

    /**
      * <p>Procedure:<b>Insert_Dispatched_tasks</b>
      *    This procedure inserts the task records into WMS_DISPATCHED_TASKS</p>
      *    AND THERE IS AN AUTONOMOUS COMMIT IN THIS INSERT!!!
      * @param p_wdt_rec               - WDT record that has to be inserted.
      * @param p_source_task_id        - Transaction Temp Id of the WDT record.
      * @param x_return_status         - Return Status
      * @param x_msg_count             - Returns Message Count
      * @param x_msg_data              - Returns Error Message
      */
  PROCEDURE insert_dispatched_tasks(
    p_wdt_rec        IN            wms_dispatched_tasks%ROWTYPE
  , p_source_task_id IN            NUMBER
  , x_return_status  OUT NOCOPY    VARCHAR2
  , x_msg_count      OUT NOCOPY    NUMBER
  , x_msg_data       OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
				    );

      /**
      * <p>Procedure:<b>Delete_Dispatched_taska</b>
      *    This procedure deletes the task records into WMS_DISPATCHED_TASKS</p>
      *    AND THERE IS AN AUTOMONOUS COMMIT IN THIS DELETE!
      *    SO IT SHOULD ONLY BE USED TO DELETE WDT CREATED BY insert_dispatched_tasks.
      * @param p_source_task_id        - Transaction Temp Id of the WDT record.
      * @param x_return_status         - Return Status
      * @param x_msg_count             - Returns Message Count
      * @param x_msg_data              - Returns Error Message
      */
	PROCEDURE delete_dispatched_task
	(
	 p_source_task_id IN            NUMBER
	 , p_wms_task_type  IN            NUMBER
	 , x_return_status  OUT NOCOPY    VARCHAR2
	 , x_msg_count      OUT NOCOPY    NUMBER
	 , x_msg_data       OUT NOCOPY    fnd_new_messages.MESSAGE_TEXT%TYPE
	 );

      /**
    * <p>Procedure:<b>Archive_Dispatched_tasks</b>
    *    This procedure archives the task records into WMS_DISPATCHED_TASKS_HISTORY</p>
    *    @param p_task_id             - Task Id of WMS_DISPATCHED_TASKS
    *    @param p_source_task_id      - Document Id for the Parent document record
    *    @param p_activity_type_id    - Activity Type Id
    *    @param p_op_plan_instance_id - Operation Plan Id for the Parent Record
    *    @param p_op_plan_status      - Plan Status for the parent record to be archived
    */

    PROCEDURE archive_dispatched_tasks(
      x_return_status            OUT NOCOPY VARCHAR2
    , x_msg_count                OUT NOCOPY NUMBER
    , x_msg_data                 OUT NOCOPY fnd_new_messages.MESSAGE_TEXT%TYPE
    , p_task_id                  IN  NUMBER
    , p_source_task_id           IN  NUMBER
    , p_activity_type_id         IN  NUMBER
    , p_op_plan_instance_id      IN  NUMBER
    , p_op_plan_status           IN  NUMBER
    );




END wms_op_runtime_pvt_apis;

 

/
