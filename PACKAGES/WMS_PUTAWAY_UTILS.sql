--------------------------------------------------------
--  DDL for Package WMS_PUTAWAY_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_PUTAWAY_UTILS" AUTHID CURRENT_USER AS
/* $Header: WMSPUTLS.pls 120.4.12010000.2 2008/10/10 07:53:37 abasheer ship $*/

--WMS_PUTAWAY_UTILS  Package
-- File        : WMSPUTLS.pls
-- Content     : Contains procedures and fucntions for putaway utilities
-- Description : Contains procedures and fucntions for putaway utilities

   /**

   **/
-- Notes       : This package will contain the wrappers (which will be called from the java files)
--               for putaway.
--               This will also contain the grouping logic stuff which will populate the global
--               temp table WMS_PUTAWAY_GROUP_TASKS_GTEMP
-- Modified    : Mon Jul 28 18:08:27 GMT+05:30 2003



/**
  *   This function will return the subinventory_type for the
  *   subinventory and org combination passed as input. It will
  *   return the following values
  *   1  -- Storage Subinventory.
  *   2  -- Receiving Subinventory.
  *   -1 -- Error

  *  @param  p_organization_id   Organization ID
  *  @param  p_subinventory_code   Subinventory Code
  *  @ RETURN  number


**/
   FUNCTION get_subinventory_type(
      p_organization_id IN NUMBER,
      p_subinventory_code IN VARCHAR2)
     RETURN NUMBER;




/**
  *   This function will remove all the records in the temporary
  *   table WMS_PUTAWAY_GROUP_TASKS_TEMP
  *   The rows that has to be deleted depends on the i/p parameter
  *   p_del_type
  *
  *   p_del_type   Action
  *   ------------------------------------------------------------
  *   1        --  Delete tasks belonging to the group which is passed as input.
  *   2        --  Delete dummy rows whose drop_type is 'ID'
  *   This Funciton will delete both the group_tasks and all_task
  *   rows.
  *   It will return the number of rows deleted
  *   -1 in case of failure.

  *  @param  p_group_id   Group ID for which the records has to be deleted
  *  @ RETURN  NUMBER


**/
    FUNCTION Remove_Tasks_In_Group(
                 p_del_type  IN NUMBER
                ,p_group_id  IN NUMBER := NULL )
    RETURN NUMBER;



/**
  *   This procedure will populate the grouped tasks temporary
  *   table (WMS_PUTAWAY_GROUP_TASKS_GTEMP with the required data
  *   and also it will stamp the drop type for the tasks and will
  *   group them based on various criterias.

  *  @param  x_return_status  Return status of the procedure - Success, Error, Unexpected Error, Warning etc.,
  *  @param  x_msg_count      Count of messages in the stack
  *  @param  x_msg_data       Actual message if the count = 1 else it will be null.
  *  @param  p_org_id         Organization Id
  *  @param  p_drop_type      This indicates for which type of drop the temp table should be populated.
  *                           This can have the values
  *                              SD - 'System Drop'
  *                              DA - 'Drop All'
  *                              ED - 'Existing Putaway Drop'
  *  @param  p_emp_id         Employee identifier
  *  @param  p_lpn_id         LPN for which this procedure is called.
  *  @param  p_item_drop_flag Whether it is called for all item drops or not
  *  @param  p_lpn_is_loaded  Whether the LPN is already loaded or not.


**/
  PROCEDURE   Create_grouped_tasks(
    x_return_status   OUT  NOCOPY  VARCHAR2,
    x_msg_count       OUT  NOCOPY  NUMBER,
    x_msg_data        OUT  NOCOPY  VARCHAR2,
    p_org_id          IN           NUMBER,
    p_drop_type       IN           VARCHAR2,
    p_emp_id          IN           NUMBER,
    p_lpn_id          IN           NUMBER     DEFAULT NULL,
    p_item_drop_flag  IN           VARCHAR2   DEFAULT 'N',
    p_lpn_is_loaded   IN           VARCHAR2   DEFAULT 'N');


/**
  *   This procedure will explode the LPN passed and will get all the MMTTs
  *   for its contents  (including childs contents) and will call the ATF API to
  *   Abort the operation instance.
  *
  *   The parameter p_call_type will decide what ATF API to call
  *   p_call_type   Gloabl Constant      Meaning
  *   1             G_ATF_ACTIVATE_PLAN  Activate Plan
  *   2             G_ATF_ABORT_PLAN     Abort Plan
  *
  *  @param  p_call_type      Mode for which the procedure is called
  *  @param  p_org_id         Organization Identifier
  *  @param  p_lpn_id         LPN identifier
  *  @param  p_emp_id         Employee identifier
  *
  *  @param  x_return_status  Return status of the function - Success, Error, Unexpected Error, Warning etc.,
  *  @param  x_msg_count      Count of messages in the stack
  *  @param  x_msg_data       Actual message if the count = 1 else it will be null.
  *
**/

   -- In case of Manual/User Drop the ATF API's will be still used to create WDTs and WDTH.
   -- Before that the existing WDTs, Plans etc has to be deleted and hence Abort plan has to be called first.
   PROCEDURE ATF_For_Manual_Drop(
              x_return_status  OUT NOCOPY  VARCHAR2
             ,x_msg_count      OUT NOCOPY  NUMBER
             ,x_msg_data       OUT NOCOPY  VARCHAR2
             ,p_call_type      IN          NUMBER
             ,p_org_id         IN          NUMBER
             ,p_lpn_id         IN          NUMBER
             ,p_emp_id         IN          NUMBER
             );



/**
  *   This Procedure will do the ATF integration for the LOAD operation
  *   in case of single step drop or load portion of manual drop.
  *
  *   This procedure inturn will call Activate_Plan_For_Load to activate
  *   the plan for load and then will call Complete_Plan_For_Load to complete the LOAD step.
  *
  *   This procedure will be called from create_grouped_tasks in case of single step drop
  *   ie the LPN which has to be dropped is not loaded already.
  *
  *  @param   x_return_status   Return status of the function - Success, Error, Unexpected Error, Warning etc.,
  *  @param   x_msg_count       Count of messages in the stack
  *  @param   x_msg_data        Actual message if the count = 1 else it will be null.
  *  @param   p_org_id          Organization Identifier
  *  @param   p_lpn_id          LPN Identifier
  *  @param   p_emp_id          Employee Identifier
  *  @ RETURN  NUMBER


**/
   PROCEDURE Complete_ATF_Load(
       x_return_status OUT  NOCOPY  VARCHAR2
      ,x_msg_count     OUT  NOCOPY  NUMBER
      ,x_msg_data      OUT  NOCOPY  VARCHAR2
      ,p_org_id        IN           NUMBER
      ,p_lpn_id        IN           NUMBER
      ,p_emp_id        IN           NUMBER );




/**
  *   This function will call the ATF API to activate the operation instance for inspect.
  *   It will call the ATF API  wms_atf_runtime_pub_apis.activate_operation_instance for
  *   each MMTT. For the Move Order Line passed.
  *
  *   ATF will check whether the current step. If it is not inspect, it will inturn call
  *   the Abort operation instance to abort the current plan in progress. So we need not
  *   call Abort Explicitly in this case.
  *
  *   It returns the number of rows for which the plan is
  *   activated, will return -1 in case of failure.

  *  @param  x_return_status  Return status of the function - Success, Error, Unexpected Error, Warning etc.,
  *  @param  x_msg_count      Count of messages in the stack
  *  @param  x_msg_data       Actual message if the count = 1 else it will be null.
  *  @param   p_org_id          Organization Identifier
  *  @param   p_lpn_id          LPN Identifier
  *  @param   p_emp_id          Employee Identifier
  *
  *  @ RETURN  NUMBER


**/
   FUNCTION Activate_Plan_For_Inspect(
              x_return_status  OUT NOCOPY  VARCHAR2
             ,x_msg_count      OUT NOCOPY  NUMBER
             ,x_msg_data       OUT NOCOPY  VARCHAR2
             ,p_org_id         IN          NUMBER
             ,p_mo_line_id     IN           NUMBER )
     RETURN NUMBER;


/**
  *   This procedure will call the ATF API to cleanup / rollback
  *   the operation instance for load / drop / single step drop.
  *
  *   It will call the ATF APIs for each MMTT in the temp table
  *   if group_id is not passed else it will call ATF APIs only
  *   for that group in the temp table.
  *
  *   It returns the number of rows for which the plan is
  *   cleanedup / rolled back, will return -1 in case of failure.
  *
  *   The parameter p_call_type will decide what ATF API to call
  *   p_call_type   Gloabl Constant         Meaning
  *   ----------------------------------------------------------
  *   1             G_CT_NORMAL_LOAD        Called from Load scenario (Manual Load)
  *   2             G_CT_NORMAL_DROP        Called from Drop (LPN already loaded)
  *   3             G_CT_SINGLE_STEP_DROP   Called from Drop (LPN already loaded)
  *
  *   if p_call_type = 3, Rollback_operation_plan will be called
  *   else  Cleanup_Operation_Instance will be called.
  *
  *
  *  @param  x_return_status   Return status of the function - Success, Error, Unexpected Error,
  *                            Warning etc.,
  *  @param  x_msg_count       Count of messages in the stack
  *  @param  x_msg_data        Actual message if the count = 1 else it will be null.
  *  @param  p_org_id          Organization Identifier
  *  @param  p_call_type       Whether cleanup is called for load, drop or single step drop
  *  @param  p_lpn_id          LPN Identifier
  *  @param  p_group_id        Group ID for which cleanup has to be called.
  *                            Can have following values:
  *                            -1: Called when one of the tasks failed and
  *                                user decided to quit all tasks
  *                            -2: Called at the end of all tasks to clean up
  *                                task split during partial drop
  *                            NULL: Called in cases of Manual Drop, Inspection,
  *                                  Manual Load
  *                            Others: Called when one of the tasks failed and
  *                                    user wants to cancel just this task
  *  @ RETURN  NUMBER


**/
   PROCEDURE Cleanup_ATF(
          x_return_status OUT  NOCOPY  VARCHAR2
         ,x_msg_count     OUT  NOCOPY  NUMBER
         ,x_msg_data      OUT  NOCOPY  VARCHAR2
         ,p_org_id        IN           NUMBER
         ,p_call_type     IN           NUMBER
         ,p_lpn_id        IN           NUMBER   DEFAULT NULL
         ,p_group_id      IN           NUMBER   DEFAULT NULL
         ,p_parent_lpn_id IN           NUMBER   DEFAULT NULL
	 ,p_drop_all      IN           VARCHAR2 --BUG 5075410
	 ,p_emp_id        IN           NUMBER); --BUG 5075410


  /**
  *  Nested LPN changes, This procedure Loads the given FromLPN into ToLPN
  *  and calls suggestions_pub
  *  @param   p_org_id       Current Organization
  *  @param   p_sub_code     If tosub is receving then call transfer transaction
                             If to sub is inventory sub then call Pack Unpack API.
  *  @param   p_from_lpn_id  From LPN id
  *  @param   p_to_lpn_id    Transfer LPN id
  *  @param   p_mode
              1 - Load entire LPN
              If the parent_lpn for the given from lpn is not null then unpack the lpn from its parent
              If the to_lpn is not null then pack the lpn into tolpn.
              2 - Transfer All contents
              3 - Transfer parial quantity.

  *  @param   x_ret      returns the following values
  *           0 - Success
  *           1 - failure.
  *  @param   x_return_status
  *  @param   x_msg_count
  *  @param   x_context
  *  @param   p_user_id
  **/
  PROCEDURE suggestions_pub_wrapper(
    p_lpn_id               IN             NUMBER
  , p_org_id               IN             NUMBER
  , p_user_id              IN             NUMBER
  , p_eqp_ins              IN             VARCHAR2
  , p_status               IN             NUMBER := 3
  , p_check_for_crossdock  IN             VARCHAR2 := 'Y'
  , x_number_of_rows       OUT NOCOPY     NUMBER
  , x_return_status        OUT NOCOPY     VARCHAR2
  , x_msg_count            OUT NOCOPY     NUMBER
  , x_msg_data             OUT NOCOPY     VARCHAR2
  , x_crossdock            OUT NOCOPY     VARCHAR2
  );



 /**
  *   Nested LPN changes
  *   This procedure loads the given Nested LPN
  */
  PROCEDURE load_lpn(
      p_org_id         IN             NUMBER
    , p_sub_code       IN             VARCHAR2
    , p_loc_id         IN             NUMBER
    , p_from_lpn_id    IN             NUMBER
    , p_to_lpn_id      IN             NUMBER
    , p_mode           IN             NUMBER
    , p_user_id        IN             NUMBER
    , p_eqp_ins        IN             VARCHAR2
    , p_project_id     IN             NUMBER DEFAULT NULL
    , p_task_id        IN             NUMBER DEFAULT NULL
    , p_check_for_crossdock IN        VARCHAR2
    , x_return_status  OUT NOCOPY     VARCHAR2
    , x_msg_count      OUT NOCOPY     NUMBER
    , x_msg_data       OUT NOCOPY     VARCHAR2
    , x_crossdock      OUT NOCOPY     VARCHAR2
    );



     /**
   *  Nested LPN changes, This procedure explodes the given LPN
   *  and for each LPN checks the validity of the given LPN and returns
   *  @param   p_org_id   Current Organization
   *  @param   p_lpn_id   From LPN ID
   *  @param   p_mode
               Purpose of the parameter - This method can be called
               from both UI as well as grouping logic. If this method
               is called from grouping logic, check only for the given LPN
               and not for the child LPNs.
               0 - Check for the given LPN iteself and not for the child LPNs
               1 - Check for the given LPN as well as it child LPNs.

   *  @param   x_ret      returns the following values
   *           0 - Success
   *           1 - Entire LPN needs Inspection.
   *           2 - Entire LPN is Invalid
   *           3 - Entire LPN is Invalid and cannot be putawayed.
   *           4 - Some child LPNs are invalid and cannot be putawayed.
   *           5 - Some child LPNs need inspection.
   *  @param   x_loaded_stauts
   *           0 - not loaded
   *           1 - loaded
   *  @param   x_return_status
   *  @param   x_msg_count
   *  @param   x_context
   *  @param   p_user_id
   **/
  PROCEDURE check_lpn_validity_wrapper(
    p_org_id         IN             NUMBER
  , p_lpn_id         IN             NUMBER
  , p_user_id        IN             NUMBER
  , p_mode           IN             NUMBER
  , x_ret            OUT NOCOPY     NUMBER
  , x_lpn_context    OUT NOCOPY     NUMBER
  , x_loaded_status  OUT NOCOPY     VARCHAR2
  , x_return_status  OUT NOCOPY     VARCHAR2
  , x_msg_count      OUT NOCOPY     NUMBER
  , x_msg_data       OUT NOCOPY     VARCHAR2);


   /** Porcedure ot update Move order line */
   PROCEDURE update_mo(
      MoLineId            NUMBER   DEFAULT  -9999,
      ReferenceId         NUMBER   DEFAULT  -9999,
      Reference           VARCHAR2 DEFAULT '-9999',
      Reference_type_code NUMBER   DEFAULT  -9999,
      lpn_id              NUMBER   DEFAULT  -9999,
      wms_process_flag    NUMBER   DEFAULT  -9999,
      inspect_status      NUMBER   DEFAULT  -9999);



  /**
  *  This procedures transfer all the contents in from_LPN to into_LPN
  *  @param   p_org_id       Current Organization
  *  @param   p_sub_code     Not currently used
  *  @param   p_loc_id       Not currently used
  *  @param   p_from_lpn_id  From LPN id
  *  @param   p_into_lpn_id  Into LPN id to which the contents in From LPN
  *                          will be transfered
  *  @param   p_mode
  *  @param   p_user_id
  *  @param   p_eqp_ins
  *  @param   p_project_id
  *  @param   p_task_id
  *  @param   x_return_status
  *  @param   x_msg_count
  *  @param   x_msg_data
    **/
  PROCEDURE transfer_contents
    (
     p_org_id           IN             NUMBER    DEFAULT NULL
     , p_sub_code       IN             VARCHAR2 DEFAULT NULL
     , p_loc_id         IN             NUMBER   DEFAULT NULL
     , p_from_lpn_id    IN             NUMBER
     , p_into_lpn_id    IN             NUMBER
     , p_operation      IN             VARCHAR2
     , p_mode           IN             NUMBER
     , p_user_id        IN             NUMBER
     , p_eqp_ins        IN             VARCHAR2
     , p_project_id     IN             NUMBER   DEFAULT NULL
     , p_task_id        IN             NUMBER   DEFAULT NULL
     , x_return_status  OUT NOCOPY     VARCHAR2
     , x_msg_count      OUT NOCOPY     NUMBER
     , x_msg_data       OUT NOCOPY     VARCHAR2 );

 /**
  *   This procedure is a wrapper for the complete_putaway API and will be
  *   called for a group of tasks. Accepts the current group Id or
  *   transaction_header_id and the values confirmed by the user on the page
  *   and processes the eligible tasks
  *   Processing Logic:
  *     -> Loop through each task/MMTT row given the group_id/header_id
  *     -> Consume the task quantity based on the confirmed quantity
  *     -> Create the lots and serials interface records (receiving LPN)
  *     -> Create the WLPNI records (receiving LPN) or
  *        call pack/unpack API to reflect nesting changes
  *     -> Call the complete_putaway API for the given task
  *     -> Call the receiving Transaction Manager (receiving LPN)
  *
  *  @param  x_return_status            Return Status Indicator
  *  @param  x_msg_count                Stacked messages counter
  *  @param  x_msg_data                 Stacked Messages
  *  @param  p_group_id                 ID of the current group of tasks
  *  @param  p_txn_header_id            header_id for the current group of tasks
  *  @param  p_drop_type                Drop Type Identifier.<br>
  *                                     ID - Item Drop<br>
  *                                     CD - Consolidated Drop<br>
  *                                     MD - Manual Drop<br>
  *                                     UD - User Drop<br>
  *  @param  p_lpn_mode                 Flag for LPN actions
  *                                     1 - Transfer Contents<br>
  *                                     2 - Drop Entire LPN<br>
  *                                     3 - Item Drop
  *  @param  p_lpn_id                   LPN being putaway
  *  @param  p_lpn_context               Context of the LPN being putaway
  *  @param  p_organization_id          Organization ID
  *  @param  p_user_id                  Logged in Employee ID
  *  @param  p_item_id                  Item for the current group (item drop)
  *  @param  p_revision                 Revision confirmed (item drop)
  *  @param  p_lot_number               Lot Number confirmed (item drop)
  *  @param  p_subinventory_code        Drop to Subinventory Code
  *  @param  p_locator_id               Drop to Locator ID
  *  @param  p_quantity                 Quantity Confirmed (item drop)
  *  @param  p_uom_code                 Unit of Measure confirmed (item drop)
  *  @param  p_entire_lpn               Flag to indicate if entire LPN is putaway
  *  @param  p_to_lpn_name              License Plate number of the Into LPN
  *  @param  p_to_lpn_id                LPN Id of the Into LPN
  *  @param  p_project_id               Project ID
  *  @param  p_task_id                  Task ID
  *  @param  p_reference                MOL reference
  *  @param  p_qty_reason_id            Reason ID for Quantity Discrepancy
  *  @param  p_loc_reason_id            Reason ID for locator discrepancy
  *  @param  p_process_serial_flag      Flag set if serials are confirmed in UI
  *  @param  p_msni_txn_interface_id    Transaction_interface_id of MSNI records
  *                                     created from the UI
  *  @param  p_product_transaction_id   Product_transaction_id of MTLI/MSNI
  *                                     populated if user confirms partial qty
  **/
  PROCEDURE Complete_Putaway_Wrapper(
      x_return_status           OUT  NOCOPY VARCHAR2
    , x_msg_count               OUT  NOCOPY NUMBER
    , x_msg_data                OUT  NOCOPY VARCHAR2
      /* Added for LMS project: Anupam Jain*/
    , x_lms_operation_plan_id   OUT  NOCOPY NUMBER
      /* LMS change end*/
    , p_group_id                IN          NUMBER   DEFAULT NULL
    , p_txn_header_id           IN          NUMBER   DEFAULT NULL
    , p_drop_type               IN          VARCHAR2
    , p_lpn_mode                IN          NUMBER
    , p_lpn_id                  IN          NUMBER
    , p_lpn_context             IN          NUMBER
    , p_organization_id         IN          NUMBER
    , p_user_id                 IN          NUMBER
    , p_item_id                 IN          NUMBER   DEFAULT NULL
    , p_revision                IN          VARCHAR2 DEFAULT NULL
    , p_lot_number              IN          VARCHAR2 DEFAULT NULL
    , p_subinventory_code       IN          VARCHAR2
    , p_locator_id              IN          NUMBER
    , p_quantity                IN          NUMBER   DEFAULT NULL
    , p_uom_code                IN          VARCHAR2 DEFAULT NULL
    , p_entire_lpn              IN          VARCHAR2 DEFAULT 'Y'
    , p_to_lpn_name             IN          VARCHAR2
    , p_to_lpn_id               IN          NUMBER
    , p_project_id              IN          NUMBER   DEFAULT NULL
    , p_task_id                 IN          NUMBER   DEFAULT NULL
    , p_reference               IN          VARCHAR2 DEFAULT 'N'
    , p_qty_reason_id           IN          NUMBER   DEFAULT NULL
    , p_loc_reason_id           IN          NUMBER   DEFAULT NULL
    , p_process_serial_flag     IN          VARCHAR2 DEFAULT NULL
    , p_msni_txn_interface_id   IN          NUMBER   DEFAULT NULL
    , p_product_transaction_id  IN          NUMBER   DEFAULT NULL
    , p_secondary_quantity      IN          NUMBER   DEFAULT NULL --OPM Convergence
    , p_secondary_uom           IN          VARCHAR2 DEFAULT NULL --OPM Convergence
   , p_lpn_initially_loaded    IN          VARCHAR2 DEFAULT NULL );


     /**
   *  This procedure is called from the UI to check the validity of an into LPN
   *  @param   p_org_id              Current Organization
   *  @param   p_lpn_id              From LPN ID
   *  @param   p_project_id          Project ID of from LPN
   *  @param   p_task_id             Task ID of from LPN
   *  @param   p_employee_id
   *  @param   p_into_lpn            The license plate number that is entered in the
   *                                 intoLPN field
   *  @param   x_return_status
   *  @param   x_msg_count
   *  @param   x_msg_data
   *  @param   x_validation_passed   'Y' if all passed, 'N' otherwise
   *  @param   x_new_lpn_created     'Y' if a lpn is created, 'N' otherwise
     **/
   PROCEDURE validate_into_lpn
     (p_organization_id      IN    NUMBER             ,
      p_lpn_id               IN    NUMBER             ,
      p_employee_id          IN    NUMBER             ,
      p_into_lpn             IN    VARCHAR2           ,
      x_return_status        OUT   NOCOPY VARCHAR2    ,
      x_msg_count            OUT   NOCOPY NUMBER      ,
      x_msg_data             OUT   NOCOPY VARCHAR2    ,
      x_validation_passed    OUT   NOCOPY VARCHAR2    ,
      x_new_lpn_created      OUT   NOCOPY VARCHAR2    ,
      p_project_id           IN    NUMBER DEFAULT NULL,
      p_task_id              IN    NUMBER DEFAULT NULL,
      p_drop_type            IN    VARCHAR2 DEFAULT NULL,
      p_sub                  IN    VARCHAR2 DEFAULT NULL,
      p_loc                  IN    NUMBER DEFAULT NULL,
      p_crossdock_type       IN    VARCHAR2 DEFAULT NULL,
      p_consolidation_method_id   IN    NUMBER DEFAULT NULL,
      p_backorder_delivery_detail_id IN NUMBER DEFAULT NULL,
      p_suggested_into_lpn_id IN   NUMBER DEFAULT NULL
      );

   /**
   *   This function inserts an RTI record to tells the TM
   *   to move all the contents of LPN to transfer LPN.
   *  @param    p_from_org         from organization id
   *  @param    p_lpn_id           from LPN id
   *  @param    p_to_org           to organization id
   *  @param    p_to_sub           to subinventory code
   *  @param    p_to_loc           to locator id
   *  @param    p_xfer_lpn_id      to LPN id
   *  @param    p_first_time       1 if insert_rti is called the first
   *                               time.  It will generate a new group id, which will be used in
   *                               all subsequent call to this API.  It
   *                               will also call init_statup_values the first time
   *  @param    p_mobile_txn       'Y' if this is being called for a mobile transaction
   *  @param    p_txn_mode_code    'ONLINE' or 'IMMEDIATE'
   *  @param    x_return_status
   *  @param    x_msg_count
   *  @param    x_msg_data
   *  @ RETURN  number             Returns the group id under which the RTI
   *                               is inserted
   **/
     FUNCTION insert_rti( p_from_org IN NUMBER
        ,p_lpn_id IN NUMBER
        ,p_to_org IN NUMBER
        ,p_to_sub IN VARCHAR2
        ,p_to_loc IN NUMBER
        ,p_xfer_lpn_id IN NUMBER
        ,p_first_time IN NUMBER
        ,p_mobile_txn IN VARCHAR2
        ,p_txn_mode_code IN VARCHAR2
        ,x_return_status OUT nocopy VARCHAR2
        ,x_msg_count OUT nocopy NUMBER
        ,x_msg_data OUT nocopy VARCHAR2 )
     RETURN NUMBER;

   PROCEDURE get_crossdock_info
     (p_lpn_id                 IN NUMBER,
      p_organization_id        IN NUMBER,
      x_back_order_delivery_id OUT nocopy NUMBER,
      x_crossdock_type         OUT nocopy NUMBER,
      x_wip_supply_type        OUT nocopy NUMBER );

   PROCEDURE update_loc_suggested_capacity
     (x_return_status    OUT NOCOPY     VARCHAR2
      , x_msg_count        OUT NOCOPY     NUMBER
      , x_msg_data         OUT NOCOPY     VARCHAR2
      , p_organization_id  IN             NUMBER
      , p_lpn_id           IN             NUMBER
      , p_location_id      IN             NUMBER
      );

   PROCEDURE validate_material_status
     (x_passed             OUT nocopy     VARCHAR2
      , p_organization_id  IN             NUMBER
      , p_sub              IN             VARCHAR2
      , p_loc              IN             NUMBER
      );

   -- bug 5286880
   FUNCTION populate_grouping_rows
     (p_lpn_id            IN NUMBER)
   RETURN NUMBER;

   FUNCTION get_grouping_count
     (p_line_rows         IN WSH_UTIL_CORE.id_tab_type)
   RETURN NUMBER;

   FUNCTION get_grouping
     (p_bo_dd_id          IN NUMBER)
   RETURN NUMBER;
   -- bug 5286880

 --Added following procedure for bug 7143123
    PROCEDURE Cleanup_LPN_Crossdock_Wrapper(
      p_org_id         IN             NUMBER
    , p_lpn_id         IN             NUMBER
    , x_return_status  OUT NOCOPY     VARCHAR2
    );

END WMS_PUTAWAY_UTILS;


/
