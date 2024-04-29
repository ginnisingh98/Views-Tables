--------------------------------------------------------
--  DDL for Package Body WMS_PUTAWAY_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_PUTAWAY_UTILS" AS
/* $Header: WMSPUTLB.pls 120.40.12010000.12 2010/02/24 09:28:40 kjujjuru ship $*/


--WMS_PUTAWAY_UTILS  Package
-- File        : WMSPUTLB.pls
-- Content     :
-- Description :
/**
  *   This is a new package created in 11510 (FPJ)
  *   This Contains Procedures/Functions for putaway utilites.
**/
-- Notes       : This package will contain the wrappers (which will be called from the java files)
--               for putaway.
--               This will also contain the grouping logic stuff which will populate the global
--               temp table WMS_PUTAWAY_GROUP_TASKS_GTEMP
-- Modified    : Mon Jul 28 18:08:27 GMT+05:30 2003


-- Global Variables definition section

      --Commonly used variables
      g_version_printed BOOLEAN        := FALSE;
      g_pkg_name        VARCHAR2(30)   := 'WMS_PUTAWAY_UTILS';
      --l_debug           NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

      G_DT_CONSOLIDATED_DROP  CONSTANT VARCHAR2(2) := 'CD';
      G_DT_ITEM_DROP          CONSTANT VARCHAR2(2) := 'ID';
      G_DT_USER_DROP          CONSTANT VARCHAR2(2) := 'UD';
      G_DT_MANUAL_DROP        CONSTANT VARCHAR2(2) := 'MD';
      G_DT_DROP_ALL           CONSTANT VARCHAR2(2) := 'DA';

      G_OK_TO_PROCESS         CONSTANT VARCHAR2(10) := 'Y';

      G_ROW_TP_ALL_TASK       CONSTANT VARCHAR2(15) := 'All Task';
      G_ROW_TP_GROUP_TASK     CONSTANT VARCHAR2(15) := 'Group Task';
      G_ROW_TP_LPN_TASK       CONSTANT VARCHAR2(15) := 'LPN Task';

      G_LPN_CONTEXT_INV       CONSTANT NUMBER := 1;
      G_LPN_CONTEXT_WIP       CONSTANT NUMBER := 2;
      G_LPN_CONTEXT_RCV       CONSTANT NUMBER := 3;

      -- ATF Related constants
      G_ATF_ACTIVATE_PLAN    CONSTANT NUMBER := 1;
      G_ATF_ABORT_PLAN       CONSTANT NUMBER := 2;
      G_ATF_CANCEL_PLAN      CONSTANT NUMBER := 3;

      G_OP_TYPE_LOAD          CONSTANT NUMBER := wms_globals.g_op_type_load;
      G_OP_TYPE_DROP          CONSTANT NUMBER := wms_globals.G_OP_TYPE_DROP;
      G_OP_TYPE_INSPECT       CONSTANT NUMBER := wms_globals.G_OP_TYPE_INSPECT;
      G_OP_TYPE_PACK          CONSTANT NUMBER := wms_globals.G_OP_TYPE_PACK;
      G_OP_TYPE_CROSSDOCK     CONSTANT NUMBER := wms_globals.G_OP_TYPE_CROSSDOCK;

      G_OP_ACTIVITY_INBOUND     CONSTANT NUMBER := wms_globals.G_OP_ACTIVITY_INBOUND;
      G_TASK_STATUS_DISPATCHED  CONSTANT NUMBER := 3;
      G_TASK_STATUS_LOADED      CONSTANT NUMBER := 4;

      /*
      G_OP_INS_STAT_PENDING     CONSTANT NUMBER := wms_globals.G_OP_INS_STAT_PENDING;
      G_OP_INS_STAT_ACTIVE      CONSTANT NUMBER := wms_globals.G_OP_INS_STAT_ACTIVE;
      G_OP_INS_STAT_COMPLETED   CONSTANT NUMBER := wms_globals.G_OP_INS_STAT_COMPLETED;
      G_OP_INS_STAT_ABORTED     CONSTANT NUMBER := WMS_GLOBALS.G_OP_INS_STAT_ABORTED;
      G_OP_INS_STAT_CANCELLED   CONSTANT NUMBER := WMS_GLOBALS.G_OP_INS_STAT_CANCELLED;
      */

      --Constant to hold values for call type param
      G_CT_NORMAL_LOAD          CONSTANT NUMBER := 1;
      G_CT_NORMAL_DROP          CONSTANT NUMBER := 2;
      G_CT_SINGLE_STEP_DROP     CONSTANT NUMBER := 3;
      G_CT_INSPECT_TM_FAILED    CONSTANT NUMBER := 4;
      G_CT_INSPECT_B4_TM        CONSTANT NUMBER := 5;

      -- Bulk fetch limit.
      -- This limit will be used wherever bulk collect is used in this package
      -- It is hardcoded to 2000, but later it can be changed to suit the requirements
      l_limit          NUMBER  := 2000;


      -- Define collections for commonly used datatypes. These collections will be
      -- used for bulk fetch.

      TYPE lpn_name_tab IS TABLE OF WMS_LICENSE_PLATE_NUMBERS.LICENSE_PLATE_NUMBER%TYPE
        INDEX BY BINARY_INTEGER;
      TYPE sub_name_tab IS TABLE OF MTL_SECONDARY_INVENTORIES.SECONDARY_INVENTORY_NAME%TYPE
        INDEX BY BINARY_INTEGER;
      TYPE row_type_tab IS TABLE OF WMS_PUTAWAY_GROUP_TASKS_GTMP.ROW_TYPE%TYPE
        INDEX BY BINARY_INTEGER;
      TYPE item_tab     IS TABLE OF MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE
        INDEX BY BINARY_INTEGER;


      TYPE num_tab      IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE date_tab     IS TABLE OF DATE   INDEX BY BINARY_INTEGER;
      TYPE rowid_tab    IS TABLE OF urowid INDEX BY BINARY_INTEGER;
      TYPE varchar240_tab IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

      TYPE uom_tab      IS TABLE OF MTL_UNITS_OF_MEASURE_TL.UOM_CODE%TYPE INDEX BY BINARY_INTEGER;
      TYPE lot_tab      IS TABLE OF MTL_LOT_NUMBERS.LOT_NUMBER%TYPE       INDEX BY BINARY_INTEGER;
      TYPE rev_tab      IS TABLE OF MTL_ITEM_REVISIONS.REVISION%TYPE      INDEX BY BINARY_INTEGER;

      TYPE entity_tab   IS TABLE OF WIP_ENTITIES.WIP_ENTITY_NAME%TYPE     INDEX BY BINARY_INTEGER;
      TYPE line_tab     IS TABLE OF WIP_LINES.LINE_CODE%TYPE              INDEX BY BINARY_INTEGER;
      TYPE dept_tab     IS TABLE OF BOM_DEPARTMENTS.DEPARTMENT_CODE%TYPE  INDEX BY BINARY_INTEGER;
      TYPE schedule_tab IS TABLE OF WIP_ENTITIES.WIP_ENTITY_NAME%TYPE     INDEX BY BINARY_INTEGER;

      TYPE ser_num_tab  IS TABLE OF mtl_serial_numbers.serial_number%TYPE
           INDEX BY BINARY_INTEGER;
      TYPE ser_mark_tab  IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

      TYPE mol_in_rec IS RECORD(
          line_id NUMBER
        , prim_qty NUMBER
      );
      TYPE split_mo_tb_tp IS TABLE OF mol_in_rec INDEX BY BINARY_INTEGER;

      -- Task Record
      SUBTYPE task_rec IS wms_dispatched_tasks%ROWTYPE;

      --Added for bug 5286880
      g_line_rows WSH_UTIL_CORE.id_tab_type;
      g_grouping_rows WSH_UTIL_CORE.id_tab_type;


/**
  *   This procedure will call the inv_log_util package to log the messages
  *   This will prepend package name and the module (which is passed) to the log message
  *   This will also print the version of the file during the first execution only.

  *  @param  p_message   The message which is to be logged
  *  @param  p_module    Procedure/Function from which this is called
  *  @param  p_level     Log level, if it is not passed a default value of 9 will be assumed.
**/
   PROCEDURE DEBUG(p_message  IN  VARCHAR2,
                   p_module   IN  VARCHAR2   := ' ',
                   p_level    IN  NUMBER     := 9 ) IS
   BEGIN

     IF NOT g_version_printed THEN
         inv_log_util.trace('$Header: WMSPUTLB.pls 120.40.12010000.12 2010/02/24 09:28:40 kjujjuru ship $',g_pkg_name, 9);
         g_version_printed := TRUE;
     END IF;

     inv_log_util.trace(p_message, g_pkg_name || '.' || p_module,p_level);
     --dbms_output.put_line(substr(g_pkg_name || p_module || p_message,1,255) );
   END DEBUG; -- Procedure debug



/**
  *   This function will return the subinventory_type for the
  *   subinventory and org combination passed as input. It will
  *   return the following values
  *   1 -- Storage Subinventory.
  *   2 -- Receiving Subinventory.

  *  @param  p_organization_id   Organization ID
  *  @param  p_subinventory_code   Subinventory Code
  *  @ RETURN  number


**/
   FUNCTION Get_Subinventory_Type(
                  p_organization_id   IN NUMBER,
                  p_subinventory_code IN VARCHAR2)
     RETURN NUMBER
     IS
        l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
        l_progress  VARCHAR2(10) := '10';
        l_proc_name VARCHAR2(30) := 'Get_Subinventory_Type:';
        l_sub_type  NUMBER       := 1;
   BEGIN

      IF (l_debug = 1) THEN
        DEBUG(' Function Entered at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
        DEBUG(' p_organization_id   => '||p_organization_id,l_proc_name , 4);
        DEBUG(' p_subinventory_code => '||p_subinventory_code,l_proc_name, 4);
      END IF;

      l_progress := '100';
      BEGIN

        l_progress := '110';
        -- Get teh subinventory type for the passed sub_code

        SELECT nvl(subinventory_type,1)
          INTO l_sub_type
        FROM mtl_secondary_inventories
          WHERE organization_id = p_organization_id
                AND secondary_inventory_name = p_subinventory_code;

        l_progress := '120';

      EXCEPTION
        WHEN OTHERS THEN
          DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
          DEBUG(SQLERRM,l_proc_name,1);
          l_sub_type := -1;
      END;

      l_progress := '150';
      IF (l_debug = 1) THEN
        DEBUG(' l_sub_type => '|| l_sub_type,l_proc_name,4);
        DEBUG(' Function Exited at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
      END IF;
      l_progress := '160';

      -- Return the subinventory type for the i/p parameters passed
      RETURN l_sub_type;

   EXCEPTION
     WHEN OTHERS THEN
      DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
      DEBUG(SQLERRM,l_proc_name,1);
      RETURN -1;
   END get_subinventory_type; --Function get_subinventory_type




/**
  *   This function will get the count of number of rows in the
  *   global temporary table WMS_PUTAWAY_GROUP_TASKS_GTMP
  *   The rows counted will depend on the mode for which it is called
  *   Mode    Meaning
  *   ----------------------------------------------------------------
  *   1       Get the count of all the rows in the temp table
  *   2       Get the count of only 'All Task' rows in the temp table
  *   3       Get the count of only 'Group Task' rows in the temp table
  *   4       Get the count of only 'LPN Task' rows in the temp table

  *  @param  p_mode   Mode of count
  *  @ RETURN  NUMBER


**/
   FUNCTION Get_Row_Count (p_mode IN NUMBER)
   RETURN NUMBER
   IS
     l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress  VARCHAR2(10) := '10';
     l_proc_name VARCHAR2(30) := 'Get_Row_Count:';
     l_rec_count NUMBER       := 0;
   BEGIN

     IF (l_debug = 1) THEN
      DEBUG(' Function Entered at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
      DEBUG(' p_mode ==> ' || p_mode,l_proc_name,4);
     END IF;

     l_progress := '90';

     IF (p_mode = 1) THEN --check for p_mode

      -- Get the count of all rows in the temp table
      l_progress := '100';
      SELECT count(ROWID)
      INTO   l_rec_count
      FROM   WMS_PUTAWAY_GROUP_TASKS_GTMP;
      l_progress := '110';

     ELSIF (p_mode = 2) THEN

       -- Get the count of all 'All Task' Rows in the temp table
       l_progress := '200';
       SELECT count(ROWID)
       INTO   l_rec_count
       FROM   WMS_PUTAWAY_GROUP_TASKS_GTMP
       WHERE  row_type = G_ROW_TP_ALL_TASK;
       l_progress := '210';

     ELSIF (p_mode = 3) THEN

       -- Get the count of all 'Group Task' Rows in the temp table
       l_progress := '300';
       SELECT count(ROWID)
       INTO   l_rec_count
       FROM   WMS_PUTAWAY_GROUP_TASKS_GTMP
       WHERE  row_type = G_ROW_TP_GROUP_TASK;
       l_progress := '310';

     ELSIF (p_mode = 4) THEN

       -- Get the count of all 'LPN Task' Rows in the temp table
       l_progress := '400';
       SELECT count(ROWID)
       INTO   l_rec_count
       FROM   WMS_PUTAWAY_GROUP_TASKS_GTMP
       WHERE  row_type = G_ROW_TP_LPN_TASK;
       l_progress := '410';

     ELSE
        -- Invalid input passed for p_mode and hence error out
        l_rec_count := -1;
     END IF; --check for p_mode


    --This function can be later modified to return the follwing information
    -- Item drop count
    -- Consolidated LPN drop count
    -- Group task records alone
    -- All task records

    l_progress := '900';
    IF (l_debug = 1) THEN
      DEBUG(' l_rec_count => '|| l_rec_count,l_proc_name,4);
      DEBUG(' Function Exited at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
    END IF;
    l_progress := '910';

    -- Retrun the number of rows in the temp table
    RETURN l_rec_count;

    EXCEPTION
     WHEN OTHERS THEN
      DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
      DEBUG(SQLERRM,l_proc_name);
      RETURN -1;
     END get_row_count; --Function get_row_count




/**
  *   This function will remove all the records in the temporary
  *   table WMS_PUTAWAY_GROUP_TASKS_GTMP
  *   The rows that has to be deleted depends on the i/p parameter
  *   p_del_type
  *
  *   p_del_type   Action
  *   ------------------------------------------------------------
  *   1        --  Delete tasks belonging to the group which is passed as input.
  *   2        --  Delete dummy rows which has been inserted for LPNs without contents
  *   3        --  Deletes all the records in the temp table.
  *	4	 --  Delete processed tasks belonging to the group which is passed as input.
  *   This Funciton will delete both the group_tasks and all_task
  *   rows.
  *   It will return the number of rows deleted
  *   -1 in case of failure.

  *  @param  p_group_id   Group ID for which the records has to be deleted
  *  @ RETURN  NUMBER


**/
   FUNCTION Remove_Tasks_In_Group(
                 p_del_type  IN NUMBER
                ,p_group_id  IN NUMBER )
     RETURN NUMBER
     IS
     l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress  VARCHAR2(10) := '10';
     l_proc_name VARCHAR2(30) := 'Remove_Tasks_In_Group:';
     l_rec_count NUMBER       := 0;

     l_rowid_tab      rowid_tab;

     -- This cursor will select the dummy rows in the temp table which can be deleted
     CURSOR c_dummy_task IS
       SELECT ROWID
       FROM   WMS_PUTAWAY_GROUP_TASKS_GTMP
       WHERE  row_type = G_ROW_TP_LPN_TASK;


   BEGIN

     IF (l_debug = 1) THEN
      DEBUG(' Function Entered at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
     END IF;

     IF (l_debug = 1) THEN
      DEBUG(' p_del_type ==> '||p_del_type,l_proc_name,4);
      DEBUG(' p_group_id ==> '||p_group_id,l_proc_name,4);
     END IF;

      l_progress := '100';

      IF p_del_type = 1 THEN
        -- Delete the tasks for the group_id passed
          l_progress := '105';
          IF (l_debug = 1) THEN
           DEBUG(' Deleting tasks for the group id passed',l_proc_name,9);
          END IF;

          IF p_group_id = -1 THEN
            IF (l_debug = 1) THEN
             DEBUG(' Group ID is -1 and returning -1 ',l_proc_name,9);
            END IF;
            RETURN -1;
          END IF;

          l_progress := '110';
          DELETE FROM WMS_PUTAWAY_GROUP_TASKS_GTMP
            WHERE group_id = p_group_id;
          l_progress := '120';

          -- Get the number of rows processed by the above SQL
          l_progress := '130';
          l_rec_count := SQL%rowcount;
          l_progress := '140';

      ELSIF p_del_type = 2 THEN
        -- Delete the dummy records which has been inserted for LPNs without contents

          l_progress := '205';
          IF (l_debug = 1) THEN
           DEBUG(' Deleting tasks for the group id passed',l_proc_name,9);
          END IF;

          l_progress := '210';
          OPEN c_dummy_task;
          l_progress := '220';

          LOOP --dummy_task_cursor

            EXIT WHEN c_dummy_task%NOTFOUND;
            l_progress := '230';

            -- Fetch the records which needs to be deleted
            l_progress := '240';
            FETCH   c_dummy_task
              BULK COLLECT
              INTO  l_rowid_tab
              LIMIT l_limit;
            l_progress := '250';


            -- Bulk delete the dummy records
            FORALL i IN 1 .. l_rowid_tab.COUNT
              DELETE FROM WMS_PUTAWAY_GROUP_TASKS_GTMP
              WHERE ROWID = l_rowid_tab(i);

            l_progress := '260';
          END LOOP; --dummy_task_cursor

          l_progress := '270';
          CLOSE c_dummy_task;
          l_progress := '280';


      ELSIF p_del_type = 3 THEN
              --Delete all records from WMS_PUTAWAY_GROUP_TASKS_GTMP

              l_progress := '305';
              IF (l_debug = 1) THEN
               DEBUG(' Deleting all the rows from the global temp table',l_proc_name,9);
              END IF;

              l_progress := '310';
              DELETE FROM WMS_PUTAWAY_GROUP_TASKS_GTMP;
              l_progress := '320';

              -- Get the number of rows processed by the above SQL
              l_progress := '330';
              l_rec_count := SQL%rowcount;
              l_progress := '340';

      ELSIF p_del_type = 4 THEN  -- Added for Bug 8827145
           -- Delete the tasks for the group_id passed
             l_progress := '405';
             IF (l_debug = 1) THEN
              DEBUG(' Deleting processed tasks for the group id passed',l_proc_name,9);
             END IF;

             IF p_group_id = -1 THEN
               IF (l_debug = 1) THEN
                DEBUG(' Group ID is -1 and returning -1 ',l_proc_name,9);
               END IF;
               RETURN -1;
             END IF;

             l_progress := '410';
             DELETE FROM WMS_PUTAWAY_GROUP_TASKS_GTMP
               WHERE group_id = p_group_id
                 AND (PROCESS_FLAG = 'Y' OR ROW_TYPE = G_ROW_TP_GROUP_TASK);
             l_progress := '420';

             -- Get the number of rows processed by the above SQL
             l_progress := '430';
             l_rec_count := SQL%rowcount;
             l_progress := '440';

      ELSE
          l_progress := '800';
          IF (l_debug = 1) THEN
           DEBUG(' Invalid value for p_',l_proc_name,9);
          END IF;

          l_rec_count := -1;
      END IF; -- p_del_type check

      l_progress := '900';
      IF (l_debug = 1) THEN
        DEBUG(' l_rec_count => '|| l_rec_count,l_proc_name,4);
        DEBUG(' Function Exited at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
      END IF;

      -- return the number of rows deleted
      RETURN l_rec_count;

   EXCEPTION
     WHEN OTHERS THEN
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name);

       -- Close the cursors if they are open
       IF c_dummy_task%isopen THEN
         CLOSE c_dummy_task;
       END IF;

       RETURN -1;
   END Remove_Tasks_In_Group;


   /**
     *   This function will remove all the processed records in the temporary
     *   table WMS_PUTAWAY_GROUP_TASKS_GTMP and insert the newly created tasks
     *   during a partial putaway
     *  @param  p_group_id   Group ID for which the records has to be deleted


   **/
      -- Added for Bug 8827145
      PROCEDURE Update_Tasks_In_Group(
         x_return_status           OUT  NOCOPY VARCHAR2
       , x_msg_count               OUT  NOCOPY NUMBER
       , x_msg_data                OUT  NOCOPY VARCHAR2
       , x_rec_count               OUT  NOCOPY NUMBER
       , p_organization_id         IN   NUMBER
       , p_drop_type               IN   VARCHAR2
                   , p_lpn_id                  IN   NUMBER
       , p_group_id                IN   NUMBER
       , p_emp_id                  IN   NUMBER)
        IS
        l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
        l_progress  VARCHAR2(10) := '10';
        l_proc_name VARCHAR2(30) := 'Update_Tasks_In_Group:';
        l_rec_count NUMBER       := 0;
        l_task_rec        task_rec   := NULL;
       l_txn_header_id    NUMBER;
       l_txn_temp_id_tab  num_tab;
       l_error_code            NUMBER;
       l_drop_lpn_option  NUMBER;
       l_consolidation_method_id NUMBER;

      BEGIN

       IF (l_debug = 1) THEN
         DEBUG(' Function Entered at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       END IF;

       x_return_status  := fnd_api.g_ret_sts_success;

       SAVEPOINT update_gtmp_sp;

       l_task_rec.person_id       := p_emp_id;
       l_task_rec.organization_id := p_organization_id;
       l_task_rec.user_task_type  := -1;

          -- To insert the newly split MMTT and MTRL records to GTMP table....

       FOR gtmp_rec IN (SELECT DISTINCT
                       mmtt.organization_id,
                       mmtt.transaction_temp_id,
                       mmtt.transaction_header_id,
                       mtrl.lpn_id,
                       mmtt.cartonization_id,  --INTO LPN ID
                       mmtt.inventory_item_id,
                       msik.concatenated_segments item, --Item
                       mtrl.lot_number,
                       mmtt.revision,
                       mmtt.transaction_quantity,
                       mmtt.transaction_uom,
                       inv_project.get_locsegs (mmtt.locator_id, mmtt.organization_id ) LOCATOR,
                       msik.primary_uom_code,
                       NVL(mmtt.transfer_subinventory,mmtt.subinventory_code) dest_subinventory,
                       NVL(mmtt.transfer_to_location, mmtt.locator_id)        dest_locator,
                       NVL (msik.revision_qty_control_code, 1) revision_qty_control_code,
                       NVL (msik.lot_control_code, 1) lot_control_code,
                       NVL (msik.serial_number_control_code, 1) serial_number_control_code,
                       NVL (msik.restrict_subinventories_code, 2) restrict_subinventories_code,
                       NVL (msik.restrict_locators_code, 2) restrict_locators_code,
                       NVL (msik.location_control_code, 1) location_control_code,
                       NVL (msik.allowed_units_lookup_code, 2) allowed_units_lookup_code,
                       NVL (mtrl.backorder_delivery_detail_id, 0) backorder_delivery_detail_id,
                       NVL (mtrl.crossdock_type, 0) crossdock_type,
                       NVL (mmtt.wip_supply_type, 0) wip_supply_type,
                       mmtt.subinventory_code from_subinventory,
                       mmtt.locator_id from_locator,
                       mmtt.transfer_subinventory,
                       mmtt.transfer_to_location,
                       mmtt.transfer_organization,
                       mmtt.transaction_action_id,
                       mtrl.REFERENCE,
                       mtrl.line_id,
                       mtrl.project_id,
                       mtrl.task_id,
                       mtrl.txn_source_id,
                       mmtt.primary_quantity
                   FROM mtl_material_transactions_temp mmtt
                       ,mtl_txn_request_lines mtrl
                       ,wms_dispatched_tasks wdt
                       --,mtl_item_locations milk
                       ,mtl_system_items_kfv msik
                       ,mtl_txn_request_headers mtrh
                 WHERE wdt.organization_id = p_organization_id
                       AND wdt.person_id = Decode(p_drop_type, g_dt_drop_all,p_emp_id,wdt.person_id)
                       AND wdt.status = 4
                       AND wdt.task_type   = 2
                       AND wdt.transaction_temp_id = mmtt.transaction_temp_id
                       AND mmtt.move_order_line_id = mtrl.line_id
                       AND NVL (mmtt.wms_task_type, 0) <> -1
                       AND mtrl.lpn_id IN (SELECT     lpn_id
                                             FROM wms_license_plate_numbers
                                             WHERE organization_id = p_organization_id
                                       START WITH lpn_id = p_lpn_id
                                       CONNECT BY parent_lpn_id = PRIOR lpn_id)
                       AND mtrl.header_id = mtrh.header_id
                       AND mtrh.move_order_type = 6
                       AND mmtt.organization_id = msik.organization_id
                       AND mmtt.inventory_item_id = msik.inventory_item_id
                       AND mmtt.transaction_temp_id NOT IN (SELECT TRANSACTION_TEMP_ID FROM WMS_PUTAWAY_GROUP_TASKS_GTMP)) LOOP

             IF (l_debug = 1) THEN
               DEBUG('Calling activate_operation_instance with ...',l_proc_name,9);
               DEBUG('p_source_task_id    => ' || gtmp_rec.transaction_temp_id,l_proc_name,9);
               DEBUG('p_activity_type_id  => ' || G_OP_ACTIVITY_INBOUND,l_proc_name,9);
               DEBUG('p_operation_type_id => ' || G_OP_TYPE_DROP,l_proc_name,9);
             END IF;

             l_progress := '250';


             wms_atf_runtime_pub_apis.activate_operation_instance
               (  p_source_task_id    => gtmp_rec.transaction_temp_id
               ,p_activity_id       => G_OP_ACTIVITY_INBOUND
               ,p_task_execute_rec  => l_task_rec
               ,p_operation_type_id => G_OP_TYPE_LOAD
               ,x_return_status     => x_return_status
               ,x_msg_data          => x_msg_data
               ,x_msg_count         => x_msg_count
               ,x_error_code        => l_error_code
	       ,x_drop_lpn_option   => l_drop_lpn_option
               ,x_consolidation_method_id  => l_consolidation_method_id
               );


             l_progress := '260';

             IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
                IF (l_debug = 1) THEN
                   DEBUG(l_error_code || ' Error in activate_operation_instance ' ,l_proc_name,1);
                END IF;
                l_progress := '270';
                RAISE fnd_api.g_exc_error;
             END IF;


             INSERT INTO WMS_PUTAWAY_GROUP_TASKS_GTMP
               (
                       ORGANIZATION_ID
                       ,TRANSACTION_TEMP_ID
                       ,TRANSACTION_HEADER_ID
                       ,LPN_ID
                       ,LPN_NAME
                       ,LPN_CONTEXT
                       ,PARENT_LPN_ID
                       ,PARENT_LPN_NAME
                       ,OUTERMOST_LPN_ID
                       ,OUTERMOST_LPN_NAME
                       ,CONSOLIDATED_LPN_ID
                       ,CONSOLIDATED_LPN_NAME
                       ,INTO_LPN_ID
                       ,INTO_LPN_NAME
                       ,DROP_TYPE
                       ,DROP_ORDER
                       ,INVENTORY_ITEM_ID
                       ,ITEM
                       ,GROUP_ID
                       ,LOT_NUMBER
                       ,REVISION
                       ,TRANSACTION_QUANTITY
                       ,TRANSACTION_UOM
                       ,LOCATOR
                       ,PRIMARY_UOM_CODE
                       ,DEST_SUBINVENTORY
                       ,DEST_LOCATOR
                       ,REVISION_QTY_CONTROL_CODE
                       ,LOT_CONTROL_CODE
                       ,SERIAL_NUMBER_CONTROL_CODE
                       ,RESTRICT_SUBINVENTORIES_CODE
                       ,RESTRICT_LOCATORS_CODE
                       ,LOCATION_CONTROL_CODE
                       ,ALLOWED_UNITS_LOOKUP_CODE
                       ,BACKORDER_DELIVERY_DETAIL
                       ,CROSSDOCK_TYPE
                       ,WIP_SUPPLY_TYPE
                       ,FROM_SUBINVENTORY
                       ,FROM_LOCATOR
                       ,TRANSFER_SUBINVENTORY
                       ,TRANSFER_TO_LOCATION
                       ,TRANSFER_ORGANIZATION
                       ,TRANSACTION_ACTION_ID
                       ,REFERENCE
                       ,LOC_DROPPING_ORDER
                       ,SUB_DROPPING_ORDER
                       ,ROW_TYPE
                       ,MOVE_ORDER_LINE_ID
                       ,PROJECT_ID
                       ,TASK_ID
                       ,TXN_SOURCE_ID
                       ,PRIMARY_QUANTITY
                       ,LPN_LEVEL
               )

                 SELECT DISTINCT
                       gtmp_rec.organization_id,
                       gtmp_rec.transaction_temp_id,
                       gtmp_rec.transaction_header_id,
                       gtmp_rec.lpn_id,
                       wln.license_plate_number,                   --lpn_name
                       wln.lpn_context,
                       wln.parent_lpn_id,
                       NULL,
                       wln.outermost_lpn_id,        --Outermost LPN ID
                       (SELECT license_plate_number FROM wms_license_plate_numbers WHERE lpn_id=wln.outermost_lpn_id),                   --Outermost LPN Name
                       TO_NUMBER(NULL),        --Consolidated LPN ID
                       NULL,                   --Consolidated LPN Name
                       gtmp_rec.cartonization_id,  --INTO LPN ID
                       NULL,                   --INTO LPN Name
                       G_DT_ITEM_DROP,         --Drop Type
                       p_group_id,                 --Drop Order
                       gtmp_rec.inventory_item_id,
                       gtmp_rec.item, --Item
                       p_group_id,        --Group ID
                       gtmp_rec.lot_number,
                       gtmp_rec.revision,
                       gtmp_rec.transaction_quantity,
                       gtmp_rec.transaction_uom,
                       gtmp_rec.LOCATOR, --inv_project.get_locsegs (milk.inventory_location_id, milk.organization_id ) LOCATOR,
                       gtmp_rec.primary_uom_code,
                       gtmp_rec.dest_subinventory,
                       gtmp_rec.dest_locator,
                       gtmp_rec.revision_qty_control_code,
                       gtmp_rec.lot_control_code,
                       gtmp_rec.serial_number_control_code,
                       gtmp_rec.restrict_subinventories_code,
                       gtmp_rec.restrict_locators_code,
                       gtmp_rec.location_control_code,
                       gtmp_rec.allowed_units_lookup_code,
                       gtmp_rec.backorder_delivery_detail_id,
                       gtmp_rec.crossdock_type,
                       gtmp_rec.wip_supply_type,
                       gtmp_rec.from_subinventory,
                       gtmp_rec.from_locator,
                       gtmp_rec.transfer_subinventory,
                       gtmp_rec.transfer_to_location,
                       gtmp_rec.transfer_organization,
                       gtmp_rec.transaction_action_id,
                       gtmp_rec.REFERENCE,
                       to_number(null), -- milk.dropping_order,
                       to_number(NULL), -- msi.dropping_order,
                       G_ROW_TP_ALL_TASK,
                       gtmp_rec.line_id,
                       gtmp_rec.project_id,
                       gtmp_rec.task_id,
                       gtmp_rec.txn_source_id,
                       gtmp_rec.primary_quantity,
                       (SELECT     level
                                             FROM wms_license_plate_numbers
                                             WHERE organization_id = p_organization_id
                                             AND lpn_id=gtmp_rec.lpn_id
                                             AND ROWNUM=1
                                       START WITH lpn_id = p_lpn_id
                                       CONNECT BY parent_lpn_id = PRIOR lpn_id)
                   FROM wms_license_plate_numbers wln
                 WHERE wln.organization_id = p_organization_id
                         AND wln.lpn_id = gtmp_rec.lpn_id;


       END LOOP;

       l_progress := '280';
       -- Remove the already processed records in the GTMP table.

       x_rec_count := Remove_Tasks_In_Group(
                         p_del_type  =>  4
                       , p_group_id  =>  p_group_id);

       IF (l_debug = 1) THEN
         DEBUG(' After removing '||x_rec_count||' processed tasks for the group '||p_group_id,l_proc_name,1);
       END IF;

       -- This will group the all task rows where drop tpe = 'ID' based on the grouping criteria
       l_progress := '290';
       FOR grp_rec IN (SELECT MIN(ROWID) row_id
                             ,MIN(drop_order) drop_order
                             ,SUM(transaction_quantity) transaction_quantity
                             ,SUM(primary_quantity) primary_quantity
                       FROM  WMS_PUTAWAY_GROUP_TASKS_GTMP
                       WHERE row_type = G_ROW_TP_ALL_TASK
                         AND drop_type = G_DT_ITEM_DROP
                         AND group_id=p_group_id
                         AND NOT (crossdock_type > 1
                                   AND backorder_delivery_detail > 0
                                   AND wip_supply_type = 1
                                   )
                       GROUP BY  lpn_id
                         ,inventory_item_id
                         ,transaction_uom
                         ,revision
                         ,lot_number
                         ,dest_locator
                             ,into_lpn_id) LOOP

             INSERT INTO WMS_PUTAWAY_GROUP_TASKS_GTMP
             (
               ORGANIZATION_ID
              ,TRANSACTION_TEMP_ID
              ,TRANSACTION_HEADER_ID
              ,LPN_ID
              ,LPN_NAME
              ,LPN_CONTEXT
              ,PARENT_LPN_ID
              ,PARENT_LPN_NAME
              ,OUTERMOST_LPN_ID
              ,OUTERMOST_LPN_NAME
              ,CONSOLIDATED_LPN_ID
              ,CONSOLIDATED_LPN_NAME
              ,INTO_LPN_ID
              ,INTO_LPN_NAME
              ,DROP_TYPE
              ,DROP_ORDER
              ,INVENTORY_ITEM_ID
              ,ITEM
              ,GROUP_ID
              ,LOT_NUMBER
              ,REVISION
              ,TRANSACTION_QUANTITY
              ,TRANSACTION_UOM
              ,LOCATOR
              ,PRIMARY_UOM_CODE
              ,DEST_SUBINVENTORY
              ,DEST_LOCATOR
              ,REVISION_QTY_CONTROL_CODE
              ,LOT_CONTROL_CODE
              ,SERIAL_NUMBER_CONTROL_CODE
              ,RESTRICT_SUBINVENTORIES_CODE
              ,RESTRICT_LOCATORS_CODE
              ,LOCATION_CONTROL_CODE
              ,ALLOWED_UNITS_LOOKUP_CODE
              ,BACKORDER_DELIVERY_DETAIL
              ,CROSSDOCK_TYPE
              ,WIP_SUPPLY_TYPE
              ,FROM_SUBINVENTORY
              ,FROM_LOCATOR
              ,TRANSFER_SUBINVENTORY
              ,TRANSFER_TO_LOCATION
              ,TRANSFER_ORGANIZATION
              ,TRANSACTION_ACTION_ID
              ,REFERENCE
              ,LOC_DROPPING_ORDER
              ,SUB_DROPPING_ORDER
              ,ROW_TYPE
              ,MOVE_ORDER_LINE_ID
              ,PROJECT_ID
              ,TASK_ID
              ,TXN_SOURCE_ID
              ,PRIMARY_QUANTITY
              ,PROCESS_FLAG
              ,WIP_JOB
              ,WIP_LINE
              ,WIP_DEPT
              ,WIP_OP_SEQ
              ,WIP_ENTITY_TYPE
              ,WIP_START_DATE
              ,WIP_SCHEDULE
              ,WIP_ASSEMBLY
             )
                 SELECT
                   ORGANIZATION_ID
                  ,TRANSACTION_TEMP_ID
                  ,TRANSACTION_HEADER_ID
                  ,LPN_ID
                  ,LPN_NAME
                  ,LPN_CONTEXT
                  ,PARENT_LPN_ID
                  ,PARENT_LPN_NAME
                  ,OUTERMOST_LPN_ID
                  ,OUTERMOST_LPN_NAME
                  ,CONSOLIDATED_LPN_ID
                  ,CONSOLIDATED_LPN_NAME
                  ,INTO_LPN_ID
                  ,INTO_LPN_NAME
                  ,DROP_TYPE
                  ,grp_rec.drop_order
                  ,INVENTORY_ITEM_ID
                  ,ITEM
                  ,p_group_id
                  ,LOT_NUMBER
                  ,REVISION
                  ,grp_rec.transaction_quantity
                  ,TRANSACTION_UOM
                  ,LOCATOR
                  ,PRIMARY_UOM_CODE
                  ,DEST_SUBINVENTORY
                  ,DEST_LOCATOR
                  ,REVISION_QTY_CONTROL_CODE
                  ,LOT_CONTROL_CODE
                  ,SERIAL_NUMBER_CONTROL_CODE
                  ,RESTRICT_SUBINVENTORIES_CODE
                  ,RESTRICT_LOCATORS_CODE
                  ,LOCATION_CONTROL_CODE
                  ,ALLOWED_UNITS_LOOKUP_CODE
                  ,BACKORDER_DELIVERY_DETAIL
                  ,CROSSDOCK_TYPE
                  ,WIP_SUPPLY_TYPE
                  ,FROM_SUBINVENTORY
                  ,FROM_LOCATOR
                  ,TRANSFER_SUBINVENTORY
                  ,TRANSFER_TO_LOCATION
                  ,TRANSFER_ORGANIZATION
                  ,TRANSACTION_ACTION_ID
                  ,REFERENCE
                  ,LOC_DROPPING_ORDER
                  ,SUB_DROPPING_ORDER
                  ,G_ROW_TP_GROUP_TASK
                  ,MOVE_ORDER_LINE_ID
                  ,PROJECT_ID
                  ,TASK_ID
                  ,TXN_SOURCE_ID
                  ,grp_rec.primary_quantity
                  ,PROCESS_FLAG
                  ,WIP_JOB
                  ,WIP_LINE
                  ,WIP_DEPT
                  ,WIP_OP_SEQ
                  ,WIP_ENTITY_TYPE
                  ,WIP_START_DATE
                  ,WIP_SCHEDULE
                  ,WIP_ASSEMBLY
                 FROM  WMS_PUTAWAY_GROUP_TASKS_GTMP
                 WHERE ROWID = grp_rec.row_id;

       END LOOP;
       l_progress := '300';

       SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
           INTO l_txn_header_id
           FROM dual;

       l_progress := '310';

       UPDATE WMS_PUTAWAY_GROUP_TASKS_GTMP
         SET  transaction_header_id = l_txn_header_id
       WHERE  group_id = p_group_id
         RETURNING transaction_temp_id
         BULK COLLECT INTO l_txn_temp_id_tab;

       l_progress := '320';

       IF (l_debug = 1) THEN
         DEBUG(sql%rowcount || ' Row(s) updated in WMS_PUTAWAY_GROUP_TASKS_GTMP with txn_header_id = ' || l_txn_header_id ||
               ' and group_id = ' || p_group_id
               ,l_proc_name,9);
       END IF;

       l_progress := '330';


       FORALL i IN 1 ..l_txn_temp_id_tab.COUNT
         UPDATE  MTL_MATERIAL_TRANSACTIONS_TEMP
           SET   transaction_header_id = l_txn_header_id
           WHERE  transaction_temp_id = l_txn_temp_id_tab(i);

       l_progress := '340';

       IF (l_debug = 1) THEN
         DEBUG(sql%rowcount || ' Row(s) updated in WMS_PUTAWAY_GROUP_TASKS_GTMP with txn_header_id= ' || l_txn_header_id ,l_proc_name,9);
       END IF;

       l_progress := '350';

      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              IF (l_debug=1) THEN
                DEBUG('Expected Error at '||l_progress, l_proc_name,1);
              END IF;

              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                 fnd_msg_pub.add_exc_msg(g_pkg_name, l_proc_name, SQLERRM);
              END IF; /* fnd_msg.... */

              fnd_msg_pub.count_and_get(
                                         p_count => x_msg_count,
                                         p_data  => x_msg_data
                                        );
              --x_error_code := SQLCODE;
              x_return_status := fnd_api.g_ret_sts_error;

              ROLLBACK TO update_gtmp_sp;

        WHEN OTHERS THEN
              IF (l_debug=1) THEN
                DEBUG('Unexpected error at'||l_progress||' '||SQLERRM, l_proc_name,1);
              END IF;


              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                 fnd_msg_pub.add_exc_msg(g_pkg_name, l_proc_name, SQLERRM);
              END IF; /* fnd_msg.... */

              fnd_msg_pub.count_and_get(
                                         p_count => x_msg_count,
                                         p_data  => x_msg_data
                                        );
              --x_error_code := SQLCODE;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ROLLBACK TO update_gtmp_sp;
      END Update_Tasks_In_Group;



/**
  *   This function will update the transaction_header_id of the
  *   group(both in the global temp table and in MMTT) with same
  *   value.
  *   It will also stamp a common group_id for the group.

  *  @ RETURN  NUMBER

**/
   FUNCTION Sync_Group_Tasks
     RETURN NUMBER
     IS
     l_debug            NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress         VARCHAR2(10) := '10';
     l_proc_name        VARCHAR2(30) := 'Sync_Group_Tasks:';
     l_rec_count        NUMBER       := 0;

     l_drop_order       NUMBER;
     l_txn_header_id    NUMBER;

     l_txn_temp_id_tab  num_tab;

     CURSOR c_all_group_tasks_cursor IS
       SELECT drop_order
       FROM   WMS_PUTAWAY_GROUP_TASKS_GTMP
       WHERE  row_type = G_ROW_TP_GROUP_TASK;

   BEGIN

     IF (l_debug = 1) THEN
      DEBUG(' Function Entered at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
     END IF;
     l_progress := '100';

     BEGIN
        OPEN c_all_group_tasks_cursor;
        l_progress := '110';

        LOOP --c_all_group_tasks_cursor loop
          FETCH  c_all_group_tasks_cursor
            INTO l_drop_order;
          l_progress := '120';

          EXIT WHEN c_all_group_tasks_cursor%NOTFOUND;
          l_progress := '130';

          --l_txn_header_id := MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL;

          SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
            INTO l_txn_header_id
            FROM dual;
          l_progress := '140';

          UPDATE WMS_PUTAWAY_GROUP_TASKS_GTMP
            SET  transaction_header_id = l_txn_header_id
                ,group_id              = l_drop_order
          WHERE  drop_order = l_drop_order
            RETURNING transaction_temp_id
            BULK COLLECT INTO l_txn_temp_id_tab;
          l_progress := '150';

          l_rec_count := l_rec_count + SQL%rowcount;
          IF (l_debug = 1) THEN
           DEBUG(sql%rowcount || ' Row(s) updated in WMS_PUTAWAY_GROUP_TASKS_GTMP with txn_header_id = ' || l_txn_header_id ||
                 ' and group_id = ' || l_drop_order
                  ,l_proc_name,9);
          END IF;
          l_progress := '160';


          FORALL i IN 1 ..l_txn_temp_id_tab.COUNT
            UPDATE  MTL_MATERIAL_TRANSACTIONS_TEMP
              SET   transaction_header_id = l_txn_header_id
             WHERE  transaction_temp_id = l_txn_temp_id_tab(i);
          l_progress := '170';

          l_rec_count := l_rec_count + SQL%rowcount;
          IF (l_debug = 1) THEN
           DEBUG(sql%rowcount || ' Row(s) updated in WMS_PUTAWAY_GROUP_TASKS_GTMP with txn_header_id= ' || l_txn_header_id ,l_proc_name,9);
          END IF;
          l_progress := '180';


        END LOOP;--c_all_group_tasks_cursor loop

        CLOSE c_all_group_tasks_cursor;
        l_progress := '190';

     EXCEPTION
       WHEN OTHERS THEN
         DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
         DEBUG(SQLERRM,l_proc_name);

         IF c_all_group_tasks_cursor%ISOPEN THEN
           CLOSE c_all_group_tasks_cursor;
         END IF;

         RETURN -1;
     END;

     IF (l_debug = 1) THEN
      DEBUG(' Function Exited at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
     END IF;
     l_progress := '490';

     RETURN l_rec_count;
     l_progress := '500';
   EXCEPTION
     WHEN OTHERS THEN
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name);
       RETURN -1;

   END Sync_Group_Tasks;



/**
  *   This function will mark the consolidated LPN of all the
  *   child records of the lpn_id and lpn_name passed.
  *   This will also mark the drop_order with the minimum
  *   drop_order in that group.
  *   This will return the number of rows processed. This will
  *   return -1 in case of failure.

  *  @param  p_lpn_id   LPN ID for whose childs the allocated LPN has to be marked.
  *  @ RETURN  NUMBER


**/
   FUNCTION Mark_Consolidated_LPN( p_lpn_id     IN NUMBER
                                  ,p_lpn_name   IN VARCHAR2 )
     RETURN NUMBER
     IS

     l_debug          NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress       VARCHAR2(10) := '10';
     l_proc_name      VARCHAR2(30) := 'Mark_Consolidated_LPN:';
     l_rec_count      NUMBER       := 0;
     l_min_drop_order NUMBER;

     l_lpn_id_tab   num_tab;

     --This cursor will fetch all the child LPNs for the LPN Passed
     CURSOR c_child_lpn_cursor IS
        SELECT lpn_id
        FROM   wms_license_plate_numbers
        START  WITH lpn_id = p_lpn_id
        CONNECT BY PRIOR lpn_id = parent_lpn_id;

   BEGIN

     l_progress := '100';

     IF (l_debug = 1) THEN
      DEBUG(' p_lpn_id     ==> '||p_lpn_id,l_proc_name,4);
      DEBUG(' p_lpn_name   ==> '||p_lpn_name,l_proc_name,4);
     END IF;

     l_progress := '130';
     OPEN  c_child_lpn_cursor;
     l_progress := '140';

     FETCH c_child_lpn_cursor
       BULK COLLECT INTO l_lpn_id_tab;
     l_progress := '150';

     CLOSE c_child_lpn_cursor;
     l_progress := '160';

     SELECT MIN(drop_order)
     INTO   l_min_drop_order
     FROM   wms_putaway_group_tasks_gtmp
     WHERE  lpn_id = p_lpn_id
     OR     lpn_id IN ( SELECT lpn_id
                        FROM   wms_license_plate_numbers
                        START  WITH lpn_id = p_lpn_id
                        CONNECT BY PRIOR lpn_id = parent_lpn_id
                      );
     l_progress := '170';

     --Update the cosolidated lpn for the child LPNs with the lpn passed
/*     UPDATE wms_putaway_group_tasks_gtmp
       SET  consolidated_lpn_id    = p_lpn_id
           ,consolidated_lpn_name  = l_lpn_name
           ,drop_order             = p_drop_order
       WHERE lpn_id IN (SELECT lpn_id
                        FROM   wms_license_plate_numbers
                        START  WITH lpn_id = p_lpn_id
                        CONNECT BY PRIOR lpn_id = parent_lpn_id
                      );*/


     -- Do bulk update for all LPN and all itz child the consolidated LPN and the min drop order in that group
     FORALL i IN 1 .. l_lpn_id_tab.COUNT
      UPDATE wms_putaway_group_tasks_gtmp
       SET  consolidated_lpn_id    = p_lpn_id
           ,consolidated_lpn_name  = p_lpn_name
           ,drop_order             = l_min_drop_order
       WHERE lpn_id = l_lpn_id_tab(i);

     l_progress := '240';

     IF (l_debug = 1) THEN
      DEBUG('Updated the consolidated LPN columns for the children ',l_proc_name,9);
     END IF;


     l_progress := '250';
     l_rec_count := SQL%rowcount;
     l_progress := '160';

     IF (l_debug = 1) THEN
       DEBUG(' l_rec_count => '|| l_rec_count,l_proc_name,4);
       DEBUG(' Function Exited at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
     END IF;
     l_progress := '280';

     -- Return the number of rows updated for consolidated drop
     RETURN l_rec_count;

   EXCEPTION
     WHEN OTHERS THEN
     DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
     DEBUG(SQLERRM,l_proc_name,1);
     RETURN -1;
   END Mark_Consolidated_LPN;




/**
  *   This function will mark drop_type as 'ID'(Item Drop) for
  *   all the contents of the lpn which is passed as input and
  *   all its parents. This will call the same function
  *   recursively till it doesn't find parent lpn.
  *   This function will return the number of rows updated as
  *   Item Drop. This will retun -1 in case of a failure.

  *  @ RETURN  NUMBER


**/
   FUNCTION Mark_Item_Drop(p_lpn_id IN NUMBER)
     RETURN NUMBER
     IS
     l_debug          NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress       VARCHAR2(10) := '10';
     l_proc_name      VARCHAR2(30) := 'Mark_Item_Drop:';
     l_rec_count      NUMBER       := 0;
     l_temp           NUMBER       := 0;
     l_parent_lpn_id  NUMBER;
   BEGIN
    IF (l_debug = 1) THEN
      DEBUG(' p_lpn_id ==> '||p_lpn_id,'Mark_Item_Drop',4);
    END IF;

    BEGIN --ID Marking
        -- Select the parent lpn id of the passed lpn
        l_progress := '100';
        SELECT parent_lpn_id
          INTO l_parent_lpn_id
          FROM WMS_PUTAWAY_GROUP_TASKS_GTMP
          WHERE lpn_id = p_lpn_id
                AND ROWNUM < 2;
        l_progress := '110';

        -- Set the drop type to 'ID' for all the contents of the lpn passed
        l_progress := '120';
        UPDATE WMS_PUTAWAY_GROUP_TASKS_GTMP
          SET drop_type = G_DT_ITEM_DROP
          WHERE lpn_id = p_lpn_id;
        l_progress := '130';

        l_progress := '135';
        l_rec_count := SQL%rowcount;
        l_progress := '138';

    EXCEPTION
      WHEN no_data_found THEN
        l_progress := '139';
        -- Parent LPN is not in GTMP so mark the parent as null so that the recursion ends.
        l_parent_lpn_id := NULL;

      WHEN OTHERS THEN
        DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
        DEBUG(SQLERRM,l_proc_name,1);
        RETURN -1;
    END; --ID Marking


    IF l_parent_lpn_id IS NOT NULL THEN

      l_progress := '140';
      -- Call Mark_Item_Drop for the parent LPN
      l_temp     := Mark_Item_Drop(l_parent_lpn_id);
      l_progress := '150';

      IF l_temp <> -1 THEN
        --Increment the record updated counter
        l_progress := '160';
        l_rec_count := l_rec_count + l_temp;

      ELSE
      --returned -1 and hence error so fail
        l_progress := '170';
        RETURN -1;
      END IF;

    END IF;

    IF (l_debug = 1) THEN
      DEBUG(' l_rec_count => '|| l_rec_count,l_proc_name,4);
      DEBUG(' Function Exited at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
    END IF;
    l_progress := '180';


    -- Return the number of rows marked for item drop
    RETURN l_rec_count;

   EXCEPTION
     WHEN OTHERS THEN
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);
       RETURN -1;
   END Mark_Item_Drop;


/**
  *   This function will create the group task row in the global temp table
  *   With the data passed as input
  *
  *   This will return the number of rows inserted as output.
  *   This will return -1 in case of failure.
  *  @ RETURN  NUMBER

**/
   FUNCTION Insert_Group_Tasks (
      l_rowid_tab      IN rowid_tab
     ,l_txn_qty_tab    IN num_tab
     ,l_pri_qty_tab    IN num_tab
     ,l_drop_order_tab IN num_tab
     ,l_show_message_tab IN num_tab --R12
     ,l_error_code_tab IN varchar240_tab
     ,l_drop_lpn_option_tab IN num_tab
     ,l_consolidation_method_id_tab IN num_tab )
     RETURN NUMBER
     IS
     l_debug            NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress         VARCHAR2(10) := '10';
     l_proc_name        VARCHAR2(30) := 'Insert_Group_Tasks:';
     l_rec_count        NUMBER       := 0;

   BEGIN

     IF (l_debug = 1) THEN
       DEBUG('Start of Function ', l_proc_name,9);
     END IF;
     l_progress := '100';

     -- Printing the i/p parameters
     IF (l_debug = 1) THEN
       FOR i IN 1 .. l_rowid_tab.COUNT
       LOOP
         DEBUG('l_txn_qty_tab    ==> ' || l_txn_qty_tab(i),l_proc_name,4);
         DEBUG('l_pri_qty_tab    ==> ' || l_pri_qty_tab(i),l_proc_name,4);
         DEBUG('l_drop_order_tab ==> ' || l_drop_order_tab(i),l_proc_name,4);
         DEBUG('l_show_message_tab ==> ' || l_show_message_tab(i),l_proc_name,4);
         DEBUG('l_error_code_tab   ==> ' || l_error_code_tab(i),l_proc_name,4);
       END LOOP;
     END IF; -- Printing the i/p parameters
     l_progress := '110';

       -- This will bulk insert consolidated records for group tasks into the temp table
       FORALL i IN 1 .. l_rowid_tab.COUNT
          INSERT INTO WMS_PUTAWAY_GROUP_TASKS_GTMP
          (
            ORGANIZATION_ID
           ,TRANSACTION_TEMP_ID
           ,TRANSACTION_HEADER_ID
           ,LPN_ID
           ,LPN_NAME
           ,LPN_CONTEXT
           ,PARENT_LPN_ID
           ,PARENT_LPN_NAME
           ,OUTERMOST_LPN_ID
           ,OUTERMOST_LPN_NAME
           ,CONSOLIDATED_LPN_ID
           ,CONSOLIDATED_LPN_NAME
           ,INTO_LPN_ID
           ,INTO_LPN_NAME
           ,DROP_TYPE
           ,DROP_ORDER
           ,INVENTORY_ITEM_ID
           ,ITEM
           ,GROUP_ID
           ,LOT_NUMBER
           ,REVISION
           ,TRANSACTION_QUANTITY
           ,TRANSACTION_UOM
           ,LOCATOR
           ,PRIMARY_UOM_CODE
           ,DEST_SUBINVENTORY
           ,DEST_LOCATOR
           ,REVISION_QTY_CONTROL_CODE
           ,LOT_CONTROL_CODE
           ,SERIAL_NUMBER_CONTROL_CODE
           ,RESTRICT_SUBINVENTORIES_CODE
           ,RESTRICT_LOCATORS_CODE
           ,LOCATION_CONTROL_CODE
           ,ALLOWED_UNITS_LOOKUP_CODE
           ,BACKORDER_DELIVERY_DETAIL
           ,CROSSDOCK_TYPE
           ,WIP_SUPPLY_TYPE
           ,FROM_SUBINVENTORY
           ,FROM_LOCATOR
           ,TRANSFER_SUBINVENTORY
           ,TRANSFER_TO_LOCATION
           ,TRANSFER_ORGANIZATION
           ,TRANSACTION_ACTION_ID
           ,REFERENCE
           ,LOC_DROPPING_ORDER
           ,SUB_DROPPING_ORDER
           ,ROW_TYPE
           ,MOVE_ORDER_LINE_ID
           ,PROJECT_ID
           ,TASK_ID
           ,TXN_SOURCE_ID
           ,PRIMARY_QUANTITY
           ,PROCESS_FLAG
           ,WIP_JOB
           ,WIP_LINE
           ,WIP_DEPT
           ,WIP_OP_SEQ
           ,WIP_ENTITY_TYPE
           ,WIP_START_DATE
           ,WIP_SCHEDULE
           ,WIP_ASSEMBLY
           ,SECONDARY_QUANTITY --OPM Convergence
           ,SECONDARY_UOM --OPM Convergence
	   ,show_message -- R12
	   ,error_code --R12
           ,drop_lpn_option --R12
	   ,consolidation_method_id --R12
	   ,sub_lpn_controlled_flag --R12
	 )
              SELECT
                ORGANIZATION_ID
               ,TRANSACTION_TEMP_ID
               ,TRANSACTION_HEADER_ID
               ,LPN_ID
               ,LPN_NAME
               ,LPN_CONTEXT
               ,PARENT_LPN_ID
               ,PARENT_LPN_NAME
               ,OUTERMOST_LPN_ID
               ,OUTERMOST_LPN_NAME
               ,CONSOLIDATED_LPN_ID
               ,CONSOLIDATED_LPN_NAME
               ,INTO_LPN_ID
               ,INTO_LPN_NAME
               ,DROP_TYPE
               ,l_drop_order_tab(i)
               ,INVENTORY_ITEM_ID
               ,ITEM
               ,GROUP_ID
               ,LOT_NUMBER
               ,REVISION
               ,l_txn_qty_tab(i)
               ,TRANSACTION_UOM
               ,LOCATOR
               ,PRIMARY_UOM_CODE
               ,DEST_SUBINVENTORY
               ,DEST_LOCATOR
               ,REVISION_QTY_CONTROL_CODE
               ,LOT_CONTROL_CODE
               ,SERIAL_NUMBER_CONTROL_CODE
               ,RESTRICT_SUBINVENTORIES_CODE
               ,RESTRICT_LOCATORS_CODE
               ,LOCATION_CONTROL_CODE
               ,ALLOWED_UNITS_LOOKUP_CODE
               -- ,BACKORDER_DELIVERY_DETAIL
               ,DECODE(backorder_delivery_detail,NULL,NULL,0,0,get_grouping(backorder_delivery_detail)) --Added for bug 5286880
               ,CROSSDOCK_TYPE
               ,WIP_SUPPLY_TYPE
               ,FROM_SUBINVENTORY
               ,FROM_LOCATOR
               ,TRANSFER_SUBINVENTORY
               ,TRANSFER_TO_LOCATION
               ,TRANSFER_ORGANIZATION
               ,TRANSACTION_ACTION_ID
               ,REFERENCE
               ,LOC_DROPPING_ORDER
               ,SUB_DROPPING_ORDER
               ,G_ROW_TP_GROUP_TASK
               ,MOVE_ORDER_LINE_ID
               ,PROJECT_ID
               ,TASK_ID
               ,TXN_SOURCE_ID
               ,l_pri_qty_tab(i)
               ,PROCESS_FLAG
               ,WIP_JOB
               ,WIP_LINE
               ,WIP_DEPT
               ,WIP_OP_SEQ
               ,WIP_ENTITY_TYPE
               ,WIP_START_DATE
               ,WIP_SCHEDULE
               ,WIP_ASSEMBLY
               ,SECONDARY_QUANTITY --OPM Convergence
	       ,SECONDARY_UOM --OPM Convergence
	       ,l_show_message_tab(i) --R12
	       ,l_error_code_tab(i) --R12
	       ,l_drop_lpn_option_tab(i) --R12
	       ,l_consolidation_method_id_tab(i) --R12
               ,sub_lpn_controlled_flag --R12
	      FROM  WMS_PUTAWAY_GROUP_TASKS_GTMP
              WHERE ROWID = l_rowid_tab(i);
       l_progress := '120';

       l_rec_count := SQL%rowcount;
       l_progress := '150';

       IF (l_debug = 1) THEN
         DEBUG('l_rec_count = ' || l_rec_count, l_proc_name,9);
       END IF;
       l_progress := '990';
       RETURN l_rec_count;

   EXCEPTION
     WHEN OTHERS THEN
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);
       RETURN -1;

   END Insert_Group_Tasks;


/**
  *   This function will insert the group_task rows
  *   This will insert one group task row per group.
  *
  *
  *   This will return the number of groups created as
  *   output.This will return -1 in case of failure.

  *  @ RETURN  NUMBER


**/
   FUNCTION Group_Consolidated_Drop_Tasks
     RETURN NUMBER
     IS
     l_debug            NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress         VARCHAR2(10) := '10';
     l_proc_name        VARCHAR2(30) := 'Group_Consolidated_Drop_Task:';
     l_rec_count        NUMBER       := 0;
     l_cur_count        NUMBER       := 0;

     l_rowid_tab        rowid_tab;
     l_txn_qty_tab      num_tab;
     l_pri_qty_tab      num_tab;
     l_drop_order_tab   num_tab;
     l_sec_qty_tab      num_tab; --OPM Convergence
     l_show_message_tab  num_tab;--R12
     l_error_code_tab   varchar240_tab;
     l_drop_lpn_option_tab num_tab;
     l_consolidation_method_id_tab num_tab;

     CURSOR c_group_tasks_cursor IS
       SELECT min(ROWID)
             ,SUM(transaction_quantity)
             ,SUM(primary_quantity)
             ,drop_order
             ,SUM(secondary_quantity) --OPM Convergence
	     ,MAX(show_message) --R12
	     ,MAX(error_code) --R12
	     ,MAX(drop_lpn_option) --R12: This value should be unique per group
	     ,MAX(consolidation_method_id) --R12: This value should be unique per group
       FROM   WMS_PUTAWAY_GROUP_TASKS_GTMP
       WHERE  row_type IN (G_ROW_TP_ALL_TASK, G_ROW_TP_LPN_TASK)
              AND drop_type = G_DT_CONSOLIDATED_DROP
       GROUP BY  drop_order;

   BEGIN

     IF (l_debug = 1) THEN
       DEBUG('Start of Function ', l_proc_name,9);
     END IF;
     l_progress := '100';

     -- Actual logic here
     OPEN c_group_tasks_cursor;
     l_progress := '110';

     LOOP --c_group_tasks_cursor

       EXIT WHEN c_group_tasks_cursor%NOTFOUND;
       l_progress := '200';

       FETCH c_group_tasks_cursor
        BULK COLLECT
         INTO  l_rowid_tab
              ,l_txn_qty_tab
              ,l_pri_qty_tab
              ,l_drop_order_tab
              ,l_sec_qty_tab --OPM Convergence
	      ,l_show_message_tab --R12
	      ,l_error_code_tab --R12
	      ,l_drop_lpn_option_tab   --R12
              ,l_consolidation_method_id_tab  --R12
	 LIMIT l_limit;
       l_progress := '210';

      -- Insert group task row into temp table
       /* Note: Not passing l_sec_qty_tab as input to insert_group_tasks
                since only l_rowid_tab is used in this function to fetch
                the corresponding records from the gtmp table. Infact all
                the other tables are not needed to pass as inputs to this
                Function
        */
       l_cur_count := Insert_Group_Tasks (
              l_rowid_tab      => l_rowid_tab
             ,l_txn_qty_tab    => l_txn_qty_tab
             ,l_pri_qty_tab    => l_pri_qty_tab
             ,l_drop_order_tab => l_drop_order_tab
	     ,l_show_message_tab=> l_show_message_tab  --R12
	     ,l_error_code_tab  => l_error_code_tab    --R12
	     ,l_drop_lpn_option_tab => l_drop_lpn_option_tab              --R12
             ,l_consolidation_method_id_tab => l_consolidation_method_id_tab);	       --R12
       l_progress := '230';

       -- Check for errors while inserting group task row
       IF l_cur_count = -1 THEN
         l_progress := '232';
         RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       l_rec_count := l_rec_count + l_cur_count;
       l_progress := '235';

       IF (l_debug = 1) THEN
        DEBUG( l_cur_count|| ' Group task Row(s) inserted in WMS_PUTAWAY_GROUP_TASKS_GTMP '
              ,l_proc_name,9);
       END IF;
       l_progress := '240';

       l_rec_count := l_rec_count + l_cur_count;
       l_progress := '250';

     END LOOP;--c_group_tasks_cursor


     IF (l_debug = 1) THEN
       DEBUG(' l_rec_count => '|| l_rec_count,l_proc_name,4);
       DEBUG(' Function Exited at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
     END IF;

     l_progress := '990';
     CLOSE c_group_tasks_cursor;
     l_progress := '1000';

     RETURN l_rec_count;

   EXCEPTION

     WHEN fnd_api.g_exc_unexpected_error THEN
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_group_tasks_cursor%isopen THEN
         CLOSE c_group_tasks_cursor;
       END IF;

       RETURN -1;

     WHEN OTHERS THEN
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_group_tasks_cursor%isopen THEN
         CLOSE c_group_tasks_cursor;
       END IF;

       RETURN -1;

   END Group_Consolidated_Drop_Tasks;



/**
  *   This function will group the MMTTs which are marked as
  *   'ID' -- Item Drop
  *
  *   This will return the number of rows processed as
  *   output.This will return -1 in case of failure.

  *  @ RETURN  NUMBER


**/
   FUNCTION Group_Item_Drop_Tasks
     RETURN NUMBER
     IS
     l_debug            NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress         VARCHAR2(10) := '10';
     l_proc_name        VARCHAR2(30) := 'Group_Item_Drop_Tasks:';
     l_rec_count        NUMBER       := 0;
     l_cur_count        NUMBER       := 0;

     l_rowid_tab        rowid_tab;
     l_tempid_tab       num_tab;
     l_txn_qty_tab      num_tab;
     l_pri_qty_tab      num_tab;
     l_drop_order_tab   num_tab;
     l_sec_qty_tab      num_tab; --OPM Convergence

     l_lpn_id_tab                num_tab;
     l_inventory_item_id_tab     num_tab;
     l_transaction_uom_tab       uom_tab;
     l_revision_tab              rev_tab;
     l_lot_number_tab            lot_tab;
     l_dest_locator_tab          num_tab;
     l_bk_dl_detail_tab          num_tab;
     l_into_lpn_id_tab           num_tab;
     l_out_drop_order_tab        num_tab;
     l_show_message_tab           num_tab;
     l_error_code_tab   varchar240_tab;
     l_drop_lpn_option_tab num_tab;
     l_consolidation_method_id_tab num_tab;

     -- WIP related variables
     l_wip_entity_type_tab       num_tab;
     l_job_tab                   entity_tab;
     l_line_tab                  line_tab;
     l_dept_tab                  dept_tab;
     l_operation_seq_num_tab     num_tab;
     l_start_date_tab            date_tab;
     l_schedule_tab              entity_tab;
     l_assembly_tab              item_tab;
     l_wip_entity_id_tab         num_tab;

     l_return_status             VARCHAR2(30);
     l_msg_count                 NUMBER;
     l_msg_data                  VARCHAR2(10000);

     -- This cursor will group the all task rows where drop tpe = 'ID' based on the grouping criteria
     -- This will ignore the rows which are cross-docked to WIP Issue
     CURSOR c_group_item_drop_tasks_cursor IS
      SELECT MIN(ROWID)
            ,MIN(drop_order)
            ,SUM(transaction_quantity)
            ,SUM(primary_quantity)
            ,SUM(secondary_quantity) --OPM Convergence
            ,MAX(show_message)
	    ,MAX(error_code)
	    ,MAX(drop_lpn_option) --R12: This value should be unique per group
	    ,MAX(consolidation_method_id) --R12: This value should be unique per group
	FROM   WMS_PUTAWAY_GROUP_TASKS_GTMP
       WHERE  row_type = G_ROW_TP_ALL_TASK
              AND drop_type = G_DT_ITEM_DROP
              AND NOT (crossdock_type > 1
                       AND backorder_delivery_detail > 0
                       AND wip_supply_type = 1
                      )
       GROUP BY  lpn_id
                ,inventory_item_id
                ,transaction_uom
                ,revision
                ,lot_number
                ,dest_locator
	        ,into_lpn_id
	        --,backorder_delivery_detail; --R12
                ,decode(BACKORDER_DELIVERY_DETAIL,null,null,0,0,get_grouping(BACKORDER_DELIVERY_DETAIL)); --Added for bug 5286880

     -- This cursor will group the all task rows where drop tpe = 'ID' based on the grouping criteria
     -- This will consider only the rows which are cross-docked to WIP Issue
     CURSOR c_wip_item_drop_tasks_cursor IS
      SELECT MIN(ROWID)
            ,MIN(drop_order)
            ,SUM(transaction_quantity)
            ,SUM(primary_quantity)
            ,SUM(secondary_quantity) --OPM Convergence
	    ,MAX(show_message)
	    ,MAX(error_code)
	    ,MAX(drop_lpn_option) --R12: This value should be unique per group
	    ,MAX(consolidation_method_id) --R12: This value should be unique per group
	FROM   WMS_PUTAWAY_GROUP_TASKS_GTMP
       WHERE  row_type = G_ROW_TP_ALL_TASK
              AND drop_type = G_DT_ITEM_DROP
              AND crossdock_type > 1
              AND backorder_delivery_detail > 0
              AND wip_supply_type = 1
       GROUP BY  lpn_id
                ,inventory_item_id
                ,transaction_uom
                ,revision
                ,lot_number
                ,dest_locator
                ,into_lpn_id
                ,BACKORDER_DELIVERY_DETAIL
                ,WIP_JOB
                ,WIP_LINE
                ,WIP_DEPT
                ,WIP_OP_SEQ
                ,WIP_ENTITY_TYPE
                ,WIP_START_DATE
                ,WIP_SCHEDULE
                ,WIP_ASSEMBLY;

     CURSOR c_group_tasks_cursor IS
        SELECT lpn_id
              ,inventory_item_id
              ,transaction_uom
              ,revision
              ,lot_number
              ,dest_locator
              ,BACKORDER_DELIVERY_DETAIL
              ,into_lpn_id
              ,drop_order
              ,WIP_JOB
              ,WIP_LINE
              ,WIP_DEPT
              ,WIP_OP_SEQ
              ,WIP_ENTITY_TYPE
              ,WIP_START_DATE
              ,WIP_SCHEDULE
              ,WIP_ASSEMBLY
        FROM   WMS_PUTAWAY_GROUP_TASKS_GTMP
        WHERE  drop_type = G_DT_ITEM_DROP
               AND row_type = G_ROW_TP_GROUP_TASK;

   BEGIN

     IF (l_debug = 1) THEN
       DEBUG('Start of Function ', l_proc_name,9);
     END IF;
     l_progress := '100';


     -- Actual logic here
     -- Insert the group task rows -- first for the normal tasks
     --                               and then for tasks that are cross docked to wip issue

     OPEN c_group_item_drop_tasks_cursor;
     l_progress := '110';

     LOOP --c_group_item_drop_tasks_cursor

       EXIT WHEN c_group_item_drop_tasks_cursor%NOTFOUND;
       l_progress := '200';

       FETCH c_group_item_drop_tasks_cursor
        BULK COLLECT
         INTO  l_rowid_tab
              ,l_drop_order_tab
              ,l_txn_qty_tab
              ,l_pri_qty_tab
              ,l_sec_qty_tab --OPM Convergence
	      ,l_show_message_tab        --R12
	      ,l_error_code_tab          --R12
	      ,l_drop_lpn_option_tab  --R12
              ,l_consolidation_method_id_tab --R12
         LIMIT l_limit;
       l_progress := '210';

      -- Insert group task row into temp table
       /* Note: OPM Convergence Not passing l_sec_qty_tabl to insert_group_tasks,
                since this table will not be used in that function
        */
       l_cur_count := Insert_Group_Tasks (
              l_rowid_tab      => l_rowid_tab
             ,l_txn_qty_tab    => l_txn_qty_tab
             ,l_pri_qty_tab    => l_pri_qty_tab
             ,l_drop_order_tab => l_drop_order_tab
	     ,l_show_message_tab=> l_show_message_tab  --R12
	     ,l_error_code_tab  => l_error_code_tab    --R12
	     ,l_drop_lpn_option_tab => l_drop_lpn_option_tab              --R12
             ,l_consolidation_method_id_tab => l_consolidation_method_id_tab);	       --R12

       l_progress := '230';

       -- Check for errors while inserting group task row
       IF l_cur_count = -1 THEN
         l_progress := '232';
         RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       l_rec_count := l_rec_count + l_cur_count;
       l_progress := '235';

       IF (l_debug = 1) THEN
        DEBUG( l_cur_count|| ' Group task Row(s) inserted in WMS_PUTAWAY_GROUP_TASKS_GTMP '
              ,l_proc_name,9);
       END IF;
       l_progress := '240';

     END LOOP;--c_group_item_drop_tasks_cursor

     l_progress := '250';
     CLOSE c_group_item_drop_tasks_cursor;
     l_progress := '260';


     OPEN c_wip_item_drop_tasks_cursor;
     l_progress := '305';

     LOOP --c_wip_item_drop_tasks_cursor

       EXIT WHEN c_wip_item_drop_tasks_cursor%NOTFOUND;
       l_progress := '308';

       FETCH c_wip_item_drop_tasks_cursor
        BULK COLLECT
         INTO  l_rowid_tab
              ,l_drop_order_tab
              ,l_txn_qty_tab
              ,l_pri_qty_tab
	      ,l_sec_qty_tab --OPM Convergence
	      ,l_show_message_tab --R12
	      ,l_error_code_tab --R12
	      ,l_drop_lpn_option_tab  --R12
              ,l_consolidation_method_id_tab  --R12
         LIMIT l_limit;
       l_progress := '310';

      -- Reset the counter for cur tasks count
      l_cur_count := 0;
      l_progress := '320';

      -- Insert group task row into temp table
       l_cur_count := Insert_Group_Tasks (
              l_rowid_tab      => l_rowid_tab
             ,l_txn_qty_tab    => l_txn_qty_tab
             ,l_pri_qty_tab    => l_pri_qty_tab
             ,l_drop_order_tab => l_drop_order_tab
	     ,l_show_message_tab=> l_show_message_tab
	     ,l_error_code_tab  => l_error_code_tab
	     ,l_drop_lpn_option_tab => l_drop_lpn_option_tab              --R12
             ,l_consolidation_method_id_tab => l_consolidation_method_id_tab);	       --R12
       l_progress := '330';

       -- Check for errors while inserting group task row
       IF l_cur_count = -1 THEN
         l_progress := '332';
         RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       l_rec_count := l_rec_count + l_cur_count;
       l_progress := '335';

       IF (l_debug = 1) THEN
        DEBUG( l_cur_count|| ' Group task Row(s) inserted in WMS_PUTAWAY_GROUP_TASKS_GTMP for crossdocked to WIP ISSUE tasks'
              ,l_proc_name,9);
       END IF;
       l_progress := '340';

     END LOOP;--c_wip_item_drop_tasks_cursor

     l_progress := '350';
     CLOSE c_wip_item_drop_tasks_cursor;
     l_progress := '360';

     BEGIN -- This will create link between 'Group Task' which was inserteed above with its corresponding 'All Task' rows

         OPEN c_group_tasks_cursor;
         l_progress := '600';

         LOOP --c_group_tasks_cursor

             EXIT WHEN c_group_tasks_cursor%NOTFOUND;
             l_progress := '610';

             FETCH c_group_tasks_cursor
              BULK COLLECT
              INTO l_lpn_id_tab
                  ,l_inventory_item_id_tab
                  ,l_transaction_uom_tab
                  ,l_revision_tab
                  ,l_lot_number_tab
                  ,l_dest_locator_tab
                  ,l_bk_dl_detail_tab
                  ,l_into_lpn_id_tab
                  ,l_out_drop_order_tab
                  ,l_job_tab
                  ,l_line_tab
                  ,l_dept_tab
                  ,l_operation_seq_num_tab
                  ,l_wip_entity_type_tab
                  ,l_start_date_tab
                  ,l_schedule_tab
                  ,l_assembly_tab
               LIMIT l_limit;
             l_progress := '620';


             FORALL i IN 1 ..l_lpn_id_tab.COUNT
              UPDATE WMS_PUTAWAY_GROUP_TASKS_GTMP
               SET   drop_order = l_out_drop_order_tab(i)
               WHERE drop_type  = G_DT_ITEM_DROP
                     AND lpn_id                      = l_lpn_id_tab(i)
                     AND inventory_item_id           = l_inventory_item_id_tab(i)
                     AND transaction_uom             = l_transaction_uom_tab(i)
                     AND NVL(revision,'@@@')         = NVL(l_revision_tab(I), '@@@')
                     AND NVL(lot_number,'@@@')       = NVL(l_lot_number_tab(i),'@@@')
                     AND NVL(dest_locator,-999)      = NVL(l_dest_locator_tab(i),-999)
                     --AND NVL(BACKORDER_DELIVERY_DETAIL,-999)  = NVL(l_bk_dl_detail_tab(i),-999) --Commented for bug 5286880
                     AND Decode(BACKORDER_DELIVERY_DETAIL,NULL,-999,0,-999,Decode(row_type,g_row_tp_all_task,get_grouping(backorder_delivery_detail),backorder_delivery_detail)) = NVL(l_bk_dl_detail_tab(i),-999)
                     AND NVL(into_lpn_id,-999)       = NVL(l_into_lpn_id_tab(i),-999)
                     AND NVL(wip_job,'@@@')          = NVL(l_job_tab(i),'@@@')
                     AND NVL(wip_line,'@@@')         = NVL(l_line_tab(i),'@@@')
                     AND NVL(wip_dept,'@@@')         = NVL(l_dept_tab(i),'@@@')
                     AND NVL(wip_op_seq,-999)        = NVL(l_operation_seq_num_tab(i),-999)
                     AND NVL(wip_entity_type,-999)   = NVL(l_wip_entity_type_tab(i),-999)
                     AND NVL(wip_start_date,SYSDATE) = NVL(l_start_date_tab(i),SYSDATE)
                     AND NVL(wip_schedule,'@@@')     = NVL(l_schedule_tab(i),'@@@')
                     AND NVL(wip_assembly,'@@@')     = NVL(l_assembly_tab(i),'@@@');

             l_progress := '640';

             l_rec_count := l_rec_count + sql%rowcount;
             IF (l_debug = 1) THEN
              DEBUG(sql%rowcount || ' Group task Row(s) updated in WMS_PUTAWAY_GROUP_TASKS_GTMP '
                    ,l_proc_name,9);
             END IF;

             l_progress := '650';

       END LOOP; --loop through all the group tasks

       CLOSE c_group_tasks_cursor;
       l_progress := '680';


     EXCEPTION
       WHEN OTHERS THEN
         RAISE fnd_api.g_exc_unexpected_error;
     END;


     IF (l_debug = 1) THEN
       DEBUG(' l_rec_count => '|| l_rec_count,l_proc_name,4);
       DEBUG(' Function Exited at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
     END IF;

     l_progress := '1000';
     RETURN l_rec_count;

  EXCEPTION
     WHEN fnd_api.g_exc_unexpected_error THEN
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_group_item_drop_tasks_cursor%isopen THEN
         CLOSE c_group_item_drop_tasks_cursor;
       END IF;

       IF c_group_tasks_cursor%isopen THEN
         CLOSE c_group_tasks_cursor;
       END IF;

       IF c_wip_item_drop_tasks_cursor%isopen THEN
         CLOSE c_wip_item_drop_tasks_cursor;
       END IF;

       RETURN -1;


     WHEN OTHERS THEN
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_group_item_drop_tasks_cursor%isopen THEN
         CLOSE c_group_item_drop_tasks_cursor;
       END IF;

       IF c_group_tasks_cursor%isopen THEN
         CLOSE c_group_tasks_cursor;
       END IF;

       IF c_wip_item_drop_tasks_cursor%isopen THEN
         CLOSE c_wip_item_drop_tasks_cursor;
       END IF;

       RETURN -1;
   END Group_Item_Drop_Tasks;



/**
  *   This function will group the tasks and will stamp the
  *   drop_type properly as item drop/consolidated
  *   drop('ID'/'CD'). The logic is
  *
  *   Loop through all the lpns starting from the innermost LPN
  *     If drop type = consolidated drop then
  *       Mark item drop if the contents go to diff location or
  *          has different to lpn.
  *       Mark item drop if there are some contents which
  *          doesn't have allocations (under allocation case)
  *
  *       If parent exists
  *           get drop_type, dest sub/loc of parent
  *
  *           if drop type = consolidated then
  *              if the dest sub/loc is null then
  *                 update it with childs dest sub/loc
  *              else if it is different from childs
  *                 mark item drop for the parent
  *
  *   This will return the number of rows processed as
  *   output.This will return -1 in case of failure.

  *  @ RETURN  NUMBER


**/
   FUNCTION Populate_Drop_Type
     RETURN NUMBER
     IS
     l_debug            NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress         VARCHAR2(10) := '10';
     l_proc_name        VARCHAR2(30) := 'Populate_Drop_Type:';
     l_rec_count        NUMBER       := 0;

     l_lpn_id_tab         num_tab;
     l_into_lpn_id_tab    num_tab;
     l_into_lpn_name_tab  lpn_name_tab;
     l_parent_lpn_id_tab  num_tab;
     l_dest_sub_tab       sub_name_tab;
     l_dest_loc_tab       num_tab;
     l_lpn_level_tab      num_tab;
     l_row_type_tab       row_type_tab;
     l_rowid_tab          rowid_tab;

     l_parent_dest_sub    VARCHAR2(10);
     l_parent_dest_loc    NUMBER;
     l_parent_drop_order  NUMBER;
     l_parent_into_lpn_id NUMBER;
     l_drop_order         NUMBER  := 0;
     l_parent_into_lpn_name VARCHAR2(30);

     l_rowid              urowid;

     l_loc_count          NUMBER  := 0;
     l_to_lpn_count       NUMBER  := 0;
     l_qty_disc_count     NUMBER  := 0;


     -- WIP related variables

     l_del_detail_id_count    NUMBER  := 0;
     l_wip_job_count          NUMBER  := 0;
     l_wip_line_count         NUMBER  := 0;
     l_wip_dept_count         NUMBER  := 0;
     l_wip_op_seq_count       NUMBER  := 0;
     l_wip_entity_type_count  NUMBER  := 0;
     l_wip_start_date_count   NUMBER  := 0;
     l_wip_schedule_count     NUMBER  := 0;
     l_wip_assembly_count     NUMBER  := 0;

     l_job                WIP_ENTITIES.WIP_ENTITY_NAME%TYPE;
     l_line               WIP_LINES.LINE_CODE%TYPE;
     l_dept               BOM_DEPARTMENTS.DEPARTMENT_CODE%TYPE;
     l_operation_seq_num  NUMBER;
     l_wip_entity_type    NUMBER;
     l_start_date         DATE;
     l_schedule           WIP_ENTITIES.WIP_ENTITY_NAME%TYPE;
     l_assembly           MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;
     l_wip_entity_id      NUMBER;

     l_crossdock_type             NUMBER;
     l_backorder_delivery_detail  NUMBER;
     l_wip_supply_type            NUMBER;

     l_crossdock_type_tab        num_tab;
     l_bk_dl_detail_tab          num_tab;
     l_wip_supply_type_tab       num_tab;
     l_wip_entity_type_tab       num_tab;
     l_job_tab                   entity_tab;
     l_line_tab                  line_tab;
     l_dept_tab                  dept_tab;
     l_operation_seq_num_tab     num_tab;
     l_start_date_tab            date_tab;
     l_schedule_tab              entity_tab;
     l_assembly_tab              item_tab;
     l_wip_entity_id_tab         num_tab;

     l_drop_order_tab        num_tab;
     l_outermost_lpn_id_tab  num_tab;

     --BUG 3435079: Used to retrieve WLPN info
     l_wpgtt_lpn_id_tab              lpn_name_tab;

     l_lpn_name_tab            lpn_name_tab;
     l_parent_lpn_name_tab     lpn_name_tab;
     l_outermost_lpn_name_tab  lpn_name_tab;

     --Bug 5286880
     l_grouping_count NUMBER;
     l_count NUMBER;


     -- This cursor will select all the levels in the temp table
     -- For which the drop type is 'CD'
     CURSOR c_lpn_level_cursor IS
       SELECT DISTINCT
              lpn_level
       FROM   wms_putaway_group_tasks_gtmp
       WHERE  drop_type = G_DT_CONSOLIDATED_DROP
       ORDER BY lpn_level DESC;

     -- This cursor will get all the LPNs, their dest sub/loc and its parent lpn id where drop_type is CD
     -- For the level passed
     CURSOR c_lpn_cursor(v_lpn_level NUMBER) IS
        SELECT DISTINCT
               lpn_id
              ,parent_lpn_id
              ,dest_subinventory
              ,dest_locator
              ,into_lpn_id
              ,into_lpn_name
              ,row_type
              ,crossdock_type
              ,backorder_delivery_detail
              ,wip_supply_type
              ,WIP_JOB
              ,WIP_LINE
              ,WIP_DEPT
              ,WIP_OP_SEQ
              ,WIP_ENTITY_TYPE
              ,WIP_START_DATE
              ,WIP_SCHEDULE
              ,WIP_ASSEMBLY
        FROM   WMS_PUTAWAY_GROUP_TASKS_GTMP
        WHERE  drop_type = G_DT_CONSOLIDATED_DROP
               AND lpn_level = v_lpn_level;

     -- This cursor will get the rowid, dest sub/loc for the lpn passed where drop type is CD
     CURSOR c_parent_lpn_cursor(v_parent_lpn_id NUMBER) IS
        SELECT   ROWID
                ,dest_subinventory
                ,dest_locator
                ,into_lpn_id
                ,into_lpn_name
                ,crossdock_type
                ,backorder_delivery_detail
                ,wip_supply_type
                ,WIP_JOB
                ,WIP_LINE
                ,WIP_DEPT
                ,WIP_OP_SEQ
                ,WIP_ENTITY_TYPE
                ,WIP_START_DATE
                ,WIP_SCHEDULE
                ,WIP_ASSEMBLY
        FROM   WMS_PUTAWAY_GROUP_TASKS_GTMP
        WHERE  lpn_id = v_parent_lpn_id
               AND drop_type = G_DT_CONSOLIDATED_DROP
               AND ROWNUM < 2;

     -- This cursor will get the tasks in proper order and will also be used to resolve
     -- the LPN columns.

     --BUG 3435079: For performance reason, do not join with WLPN here,
     --because the 'order by' clauses forces the DB to do a full table
     --scan of WLPN.  Retrieval of WLPN info will be done later.
     CURSOR c_group_tasks_order_by IS
            SELECT wpgtt.ROWID
	           ,ROWNUM
	           ,wpgtt.lpn_id               lpn_id
            FROM    wms_putaway_group_tasks_gtmp wpgtt
            ORDER BY wpgtt.sub_dropping_order,
                     wpgtt.dest_subinventory,
                     wpgtt.loc_dropping_order,
                     wpgtt.LOCATOR,
                     wpgtt.inventory_item_id,
                     wpgtt.revision,
                     wpgtt.lot_number;


   BEGIN
     IF (l_debug = 1) THEN
       DEBUG('Start of Function ', l_proc_name,9);
     END IF;

      BEGIN --Block to stamp the drop_order

        IF (l_debug = 1) THEN
          DEBUG('Stamping the drop_order and resolving the lpn columns ',l_proc_name,9);
        END IF;

         l_progress := '20';
         OPEN c_group_tasks_order_by;
         l_progress := '30';

          LOOP -- c_group_tasks_order_by cursor

              EXIT WHEN c_group_tasks_order_by%NOTFOUND;

              l_progress := '40';
              FETCH c_group_tasks_order_by
                BULK COLLECT
                INTO  l_rowid_tab
                     ,l_drop_order_tab
		     ,l_wpgtt_lpn_id_tab
                LIMIT l_limit;
              l_progress := '50';

                 --Stamp the drop_order in the temp table
                 FOR i IN 1..l_rowid_tab.COUNT
                 LOOP

                   -- Increment the drop order
                   l_drop_order := l_drop_order + 1;
                   l_progress   := '60';

		   --BUG 3435079: For performance reason, get the
		   --LPN info here, instead of getting it in the
		   --c_group_tasks_order_by cursor
		   BEGIN
		      SELECT
			wlpn1.license_plate_number   lpn_name
			,wlpn2.lpn_id               parent_lpn_id
			,wlpn2.license_plate_number parent_lpn_name
			,wlpn3.lpn_id               outermost_lpn_id
			,wlpn3.license_plate_number outermost_lpn_name
			INTO
			l_lpn_name_tab(i)
			,l_parent_lpn_id_tab(i)
			,l_parent_lpn_name_tab(i)
			,l_outermost_lpn_id_tab(i)
			,l_outermost_lpn_name_tab(i)
			FROM
			wms_license_plate_numbers wlpn1
			,wms_license_plate_numbers wlpn2
			,wms_license_plate_numbers wlpn3
			WHERE
			wlpn1.lpn_id = l_wpgtt_lpn_id_tab(i)
			AND wlpn1.outermost_lpn_id = wlpn3.lpn_id
			AND wlpn2.lpn_id(+) = wlpn1.parent_lpn_id;
		   EXCEPTION
		      WHEN too_many_rows THEN
			 IF (l_debug = 1) THEN
			    DEBUG('Too many rows returned when getting LPN, parent lpn, outermost lpn info' || l_parent_lpn_id_tab(i),l_proc_name,9);
			 END IF;
		      WHEN no_data_found THEN
			 IF (l_debug = 1) THEN
			    DEBUG('No rows returned when getting LPN, parent lpn, outermost lpn info' || l_parent_lpn_id_tab(i),l_proc_name,9);
			 END IF;
		      WHEN OTHERS THEN
			 IF (l_debug = 1) THEN
			    DEBUG('Other exception occurred when getting LPN, parent lpn, outermost lpn info' || l_parent_lpn_id_tab(i),l_proc_name,9);
			 END IF;
		   END;

                   -- update the drop order and LPN columns back to temp table
                   UPDATE wms_putaway_group_tasks_gtmp
                   SET    drop_order          = l_drop_order
                         ,lpn_name            = l_lpn_name_tab(i)
                         ,parent_lpn_id       = l_parent_lpn_id_tab(i)
                         ,parent_lpn_name     = l_parent_lpn_name_tab(i)
                         ,outermost_lpn_id    = l_outermost_lpn_id_tab(i)
                         ,outermost_lpn_name  = l_outermost_lpn_name_tab(i)
                   WHERE  ROWID = l_rowid_tab(i);
                   l_progress := '65';
                 END LOOP;

                 l_progress := '70';

           END LOOP; -- c_group_tasks_order_by cursor

           CLOSE c_group_tasks_order_by;
           l_progress := '75';

      EXCEPTION
           WHEN OTHERS THEN
              DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
              DEBUG(SQLERRM,l_proc_name,1);

              IF  c_group_tasks_order_by%isopen THEN
                CLOSE c_group_tasks_order_by;
              END IF;

              RETURN -1;
      END; --Block to stamp the drop_order


      OPEN c_lpn_level_cursor;

      FETCH c_lpn_level_cursor
        BULK COLLECT INTO
        l_lpn_level_tab;

      CLOSE c_lpn_level_cursor;


      FOR i IN 1 .. l_lpn_level_tab.COUNT
      LOOP --lpn level cursor

             l_progress := '100';
             OPEN c_lpn_cursor(l_lpn_level_tab(i));

             l_progress := '110';

             LOOP --c_lpn_cursor loop


               EXIT WHEN c_lpn_cursor%NOTFOUND;
               l_progress := '120';

               l_progress := '130';
               FETCH c_lpn_cursor
                BULK COLLECT
                INTO l_lpn_id_tab
                    ,l_parent_lpn_id_tab
                    ,l_dest_sub_tab
                    ,l_dest_loc_tab
                    ,l_into_lpn_id_tab
                    ,l_into_lpn_name_tab
                    ,l_row_type_tab
                    ,l_crossdock_type_tab
                    ,l_bk_dl_detail_tab
                    ,l_wip_supply_type_tab
                    ,l_job_tab
                    ,l_line_tab
                    ,l_dept_tab
                    ,l_operation_seq_num_tab
                    ,l_wip_entity_type_tab
                    ,l_start_date_tab
                    ,l_schedule_tab
                    ,l_assembly_tab
                 LIMIT l_limit;
               l_progress := '140';


               FOR i IN 1 .. l_lpn_id_tab.COUNT
               LOOP --lpn_cursor_bulk collect loop

               -- Do all the checks only if the drop type is consolidated drop
               --IF l_drop_type = G_DT_CONSOLIDATED_DROP THEN

                   -- Check whether all the contents go to the same location
                   -- and whether the suggested to_lpn is same for all the contents within that LPN
                   BEGIN -- Check for destination locator/LPN

                     --Don't do these checks for a dummy LPN record since it won't have any contents, MTRL or MMTT
                     IF l_row_type_tab(i) <> G_ROW_TP_LPN_TASK THEN --dummy record check

                       IF (l_debug = 1) THEN
                         DEBUG('Checking whether CD is possible (check for dest loc/LPN Discrepancy) for LPN ' || l_lpn_id_tab(i),l_proc_name,9);
                       END IF;

                       l_progress := 145;
                       SELECT  COUNT(DISTINCT NVL(transfer_to_location,locator_id))
                              ,COUNT(DISTINCT cartonization_id)
                       INTO  l_loc_count
                            ,l_to_lpn_count
                       FROM  mtl_material_transactions_temp  mmtt
                            ,mtl_txn_request_lines mtrl
                       WHERE  mmtt.move_order_line_id = mtrl.line_id
                              AND mtrl.lpn_id = l_lpn_id_tab(i);
                       l_progress := '150';

                       --Begin bug 5286880
                       l_count := populate_grouping_rows(l_lpn_id_tab(i));
                       l_grouping_count := get_grouping_count(g_grouping_rows);
                       IF (l_debug = 1) THEN
                                debug('l_grouping_count='||l_grouping_count, l_proc_name, 9);
                       END IF;
                       --End bug 5286880


                       -- If there are no suggestions. This case maynot be possible
                       -- but still checking this for safety
                       IF l_loc_count = 0 THEN
                          l_progress := '160';

                          IF (l_debug = 1) THEN
                            DEBUG('There are no MMTTs for this LPN and hence erroring out ' || l_lpn_id_tab(i),l_proc_name,9);
                          END IF;

                          RETURN -1;
                       END IF;

                       --IF l_loc_count > 1 OR l_to_lpn_count > 1 THEN
                       --Commented for bug 5286880 and added one more condition for l_grouping_count
                       IF l_loc_count > 1 OR l_to_lpn_count > 1 OR l_grouping_count > 1 THEN

                         IF (l_debug = 1) THEN
                           DEBUG('Either locator or LPN Discrepancy. Hence calling Mark Item Drop for LPN ' || l_lpn_id_tab(i),l_proc_name,9);
                         END IF;

                         l_progress := '170';

                         -- The contents either doesn't go to same location or same TO LPN
                         -- and hence can't be dropped by consolidated drop. So mark item drop
                         -- for the lpn and its parents.
                         l_rec_count := l_rec_count + Mark_Item_Drop(l_lpn_id_tab(i));

                         l_progress := '180';


                         IF l_rec_count = -1 THEN
                           l_progress := '190';

                           IF (l_debug = 1) THEN
                             DEBUG('Mark Item Drop Returned Error and hence Exiting.. ',l_proc_name,9);
                           END IF;

                           RETURN -1;
                         END IF;

                       END IF; --loc/to_lpn count check
                     END IF; --dummy record check
                   EXCEPTION
                     WHEN OTHERS THEN
                       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
                       DEBUG(SQLERRM,l_proc_name,1);
                       RETURN -1;
                   END; -- Check for destination locator/LPN


                   -- Check whether there are any other contents in that LPN
                   -- which don't have MMTT or allocations is less.
                   -- In this case we can't do a consolidated drop but have to do an item drop.
                   BEGIN -- Check for other contents/under allocation of the LPN

                     BEGIN
                       l_progress := '200';

                       --Don't do these checks for a dummy LPN record since it won't have any contents, MTRL or MMTT
                       IF l_row_type_tab(i) <> G_ROW_TP_LPN_TASK THEN --dummy record check

                         IF (l_debug = 1) THEN
                           DEBUG('Checking whether CD is possible (check qty disc) for LPN ' || l_lpn_id_tab(i),l_proc_name,9);
                         END IF;

                         -- This SQL will check whether there are any incomplete allocations for the LPn passed
                         -- Incomplete allocation may be partial allocation or no allocation.
                         l_progress := '205';

                           SELECT 1
                           INTO l_qty_disc_count
                             FROM dual
                             WHERE EXISTS (
                                 SELECT mtrl.line_id
                                 FROM   mtl_txn_request_lines mtrl
                                        ,mtl_txn_request_headers mtrh
                                 WHERE  1 = 1
                                        AND mtrl.header_id = mtrh.header_id
                                        AND mtrh.move_order_type = 6
                                        AND mtrl.lpn_id = l_lpn_id_tab(i)
					AND mtrl.line_status = 7 --BUG 3352572
					AND ((NOT exists
                                                (SELECT 1
                                                 FROM mtl_material_transactions_temp mmtt1
                                                 WHERE mtrl.line_status = 7
                                                 AND mmtt1.move_order_line_id = mtrl.line_id)
                                               ) OR
                                              (( (NVL(quantity,0) - NVL(quantity_delivered,0) ) )
                                                > (SELECT SUM(transaction_quantity)
                                                   FROM   mtl_material_transactions_temp mmtt
                                                   WHERE  mtrl.line_status = 7
                                                   AND mmtt.move_order_line_id = mtrl.line_id
                                                   ))
                                              )
                                          );


                          l_progress := '210';
                       END IF;--dummy record check
                     EXCEPTION
                       WHEN no_data_found THEN
                         l_qty_disc_count :=0;
                         l_progress := '215';
                     END;


                      IF l_qty_disc_count = 1 THEN
                          -- reset the flag
                          l_qty_disc_count := 0;

                          IF (l_debug = 1) THEN
                            DEBUG('Quantity Discrepancy and hence calling Mark Item Drop for LPN ' || l_lpn_id_tab(i),l_proc_name,9);
                          END IF;


                         l_progress := '220';

                          -- The contents haven't been allocated fully
                         -- and hence can't be dropped by consolidated drop. So mark item drop
                         -- for the lpn and its parents.
                         l_rec_count := l_rec_count + Mark_Item_Drop(l_lpn_id_tab(i));
                         l_progress := '230';

                      END IF;

                   EXCEPTION
                     WHEN OTHERS THEN
                       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
                       DEBUG(SQLERRM,l_proc_name,1);
                       RETURN -1;
                   END; -- Check for other contents/under allocation of the LPN


                   BEGIN --wip_integration

                      -- Get the count of crossdocks for all those rows which crossdocked to wip issue
                      -- for the current lpn being processed
                      l_progress := '250';
                      SELECT  COUNT(DISTINCT BACKORDER_DELIVERY_DETAIL)
                             ,COUNT(DISTINCT WIP_JOB)
                             ,COUNT(DISTINCT WIP_LINE)
                             ,COUNT(DISTINCT WIP_DEPT)
                             ,COUNT(DISTINCT WIP_OP_SEQ)
                             ,COUNT(DISTINCT WIP_ENTITY_TYPE)
                             ,COUNT(DISTINCT WIP_START_DATE)
                             ,COUNT(DISTINCT WIP_SCHEDULE)
                             ,COUNT(DISTINCT WIP_ASSEMBLY)
                       INTO  l_del_detail_id_count
                            ,l_wip_job_count
                            ,l_wip_line_count
                            ,l_wip_dept_count
                            ,l_wip_op_seq_count
                            ,l_wip_entity_type_count
                            ,l_wip_start_date_count
                            ,l_wip_schedule_count
                            ,l_wip_assembly_count
                      FROM   WMS_PUTAWAY_GROUP_TASKS_GTMP
                      WHERE  row_type = G_ROW_TP_ALL_TASK
                             AND crossdock_type > 1
                             AND backorder_delivery_detail > 0
                             AND wip_supply_type = 1
                             AND lpn_id = l_lpn_id_tab(i);

                      l_progress := '260';

                      -- Check for consolidation drop based on number of crossdocks
                      IF(l_del_detail_id_count > 1 OR
                         l_wip_job_count > 1 OR
                         l_wip_line_count > 1 OR
                         l_wip_dept_count > 1 OR
                         l_wip_op_seq_count > 1 OR
                         l_wip_entity_type_count > 1 OR
                         l_wip_start_date_count > 1 OR
                         l_wip_schedule_count > 1 OR
                         l_wip_assembly_count > 1
                        ) THEN

                        -- Crossdocked to diff job/schedule/assembly/.... hence it is item drop
                        l_progress := '265';

                        IF (l_debug = 1) THEN
                          DEBUG('Cross docked to different job/schedule/op seq/assmebly... and hence calling Mark Item Drop for LPN ' || l_lpn_id_tab(i),l_proc_name,9);
                        END IF;

                        l_rec_count := l_rec_count + Mark_Item_Drop(l_lpn_id_tab(i));
                        l_progress := '270';

                      END IF; -- same job details check

                   EXCEPTION
                     WHEN OTHERS THEN
                       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
                       DEBUG(SQLERRM,l_proc_name,1);
                       RETURN -1;
                   END; --wip_integration


                   -- Get the parent record
                   BEGIN
                      l_progress := '300';

                      IF l_parent_lpn_id_tab(i) IS NOT NULL THEN

                        l_progress := '310';
                        -- Get the details of the parent lpn record
                        OPEN  c_parent_lpn_cursor(l_parent_lpn_id_tab(i));
                        l_progress := '320';

                        FETCH  c_parent_lpn_cursor
                         INTO  l_rowid
                              ,l_parent_dest_sub
                              ,l_parent_dest_loc
                              ,l_parent_into_lpn_id
                              ,l_parent_into_lpn_name
                              ,l_crossdock_type
                              ,l_backorder_delivery_detail
                              ,l_wip_supply_type
                              ,l_job
                              ,l_line
                              ,l_dept
                              ,l_operation_seq_num
                              ,l_wip_entity_type
                              ,l_start_date
                              ,l_schedule
                              ,l_assembly;
                         l_progress := '330';

                         CLOSE c_parent_lpn_cursor;

                         -- If there is no parent, check that case and we should not exit out of the loop
                         -- We should proceed with the next record and hence the exit is commented out.
                         --EXIT WHEN c_parent_lpn_cursor%NOTFOUND;

                         -- If the parent record exists
                         IF l_rowid IS NOT NULL THEN
                           l_progress := '340';

                           -- Check if the dest locator is null or into LPN is null for the parent
                           -- Parent dest loc can be null only if it is a dummy row in that case even the into lpn id will be null
                           -- checking it again for safety
                           -- wip_supply_type <> 1 check was added to ensure that you select the dummy rows alone
                           -- for LPNs which are crossdocked to wip issue (since dest_loc_id and dest_lpn_id can be null for this case)
                           IF ( (l_parent_dest_loc IS NULL)    AND
                                (l_parent_into_lpn_id IS NULL) AND
                                (l_wip_supply_type <> 1) ) THEN
                             l_progress := '350';

                             -- Dest sub/loc of the parent is null and hence update the dest sub/loc with that of childs
                             UPDATE  WMS_PUTAWAY_GROUP_TASKS_GTMP
                              SET    dest_subinventory = l_dest_sub_tab(i)
                                    ,dest_locator      = l_dest_loc_tab(i)
                                    ,into_lpn_id       = l_into_lpn_id_tab(i)
                                    ,into_lpn_name     = l_into_lpn_name_tab(i)
                                    ,crossdock_type             = l_crossdock_type_tab(i)
                                    ,backorder_delivery_detail  = l_bk_dl_detail_tab(i)
                                    ,wip_supply_type            = l_wip_supply_type_tab(i)
                                    ,WIP_JOB                    = l_job_tab(i)
                                    ,WIP_LINE                   = l_line_tab(i)
                                    ,WIP_DEPT                   = l_dept_tab(i)
                                    ,WIP_OP_SEQ                 = l_operation_seq_num_tab(i)
                                    ,WIP_ENTITY_TYPE            = l_wip_entity_type_tab(i)
                                    ,WIP_START_DATE             = l_start_date_tab(i)
                                    ,WIP_SCHEDULE               = l_schedule_tab(i)
                                    ,WIP_ASSEMBLY               = l_assembly_tab(i)
                              WHERE  ROWID = l_rowid;
                             l_progress := '360';

                             IF (l_debug = 1) THEN
                               DEBUG('Parent Dest loc for LPN ' || l_lpn_id_tab(i) || ' updated with dest_locator ' || l_dest_loc_tab(i) ,l_proc_name,9);
                               DEBUG('Parent Dest LPN for LPN ' || l_lpn_id_tab(i) || ' updated with into_lpn     ' || l_into_lpn_id_tab(i) ,l_proc_name,9);
                               DEBUG('Parent crossdock_type for LPN            ' || l_lpn_id_tab(i) || ' updated with ' || l_crossdock_type_tab(i) ,l_proc_name,9);
                               DEBUG('Parent backorder_delivery_detail for LPN ' || l_lpn_id_tab(i) || ' updated with ' || l_bk_dl_detail_tab(i) ,l_proc_name,9);
                               DEBUG('Parent wip_supply_type for LPN           ' || l_lpn_id_tab(i) || ' updated with ' || l_wip_supply_type_tab(i) ,l_proc_name,9);
                               DEBUG('Parent WIP_JOB for LPN         ' || l_lpn_id_tab(i) || ' updated with ' || l_job_tab(i) ,l_proc_name,9);
                               DEBUG('Parent WIP_LINE for LPN        ' || l_lpn_id_tab(i) || ' updated with ' || l_line_tab(i) ,l_proc_name,9);
                               DEBUG('Parent WIP_DEPT for LPN        ' || l_lpn_id_tab(i) || ' updated with ' || l_dept_tab(i) ,l_proc_name,9);
                               DEBUG('Parent WIP_OP_SEQ for LPN      ' || l_lpn_id_tab(i) || ' updated with ' || l_operation_seq_num_tab(i) ,l_proc_name,9);
                               DEBUG('Parent WIP_ENTITY_TYPE for LPN ' || l_lpn_id_tab(i) || ' updated with ' || l_wip_entity_type_tab(i) ,l_proc_name,9);
                               DEBUG('Parent WIP_START_DATE for LPN  ' || l_lpn_id_tab(i) || ' updated with ' || l_start_date_tab(i) ,l_proc_name,9);
                               DEBUG('Parent WIP_SCHEDULE for LPN    ' || l_lpn_id_tab(i) || ' updated with ' || l_schedule_tab(i) ,l_proc_name,9);
                               DEBUG('Parent WIP_ASSEMBLY for LPN    ' || l_lpn_id_tab(i) || ' updated with ' || l_assembly_tab(i) ,l_proc_name,9);
                             END IF;


                           -- Parent record has dest locator/into LPN
                           ELSE
                             l_progress := '370';

                             -- Check the dest loc/into lpn of parent with the child
                              IF ( (l_parent_dest_loc <> l_dest_loc_tab(i)) OR
                                   (NVL(l_parent_into_lpn_id,-999) <> NVL(l_into_lpn_id_tab(i),-999) ) ) THEN
                                l_progress := '380';

                                IF (l_debug = 1) THEN
                                  DEBUG('Loc/Into LPN mismatch with the parent and hence calling Mark Item Drop for parent ' || l_parent_lpn_id_tab(i),l_proc_name,9);
                                END IF;

                                 -- Dest loc / Into LPN of parent is not equal that of child and hence
                                 -- can't be dropped by consolidated drop. So mark item drop for the Parent.

                                l_rec_count := l_rec_count + Mark_Item_Drop(l_parent_lpn_id_tab(i));

                                l_progress := '390';

                              END IF; -- Dest loc check with child


                              -- wip_integration
                              -- WIP Crossdock check (do only if it is crossdocked to wip for a push type
                              IF ( l_crossdock_type_tab(i)  > 1  AND
                                   l_bk_dl_detail_tab(i)    > 0  AND
                                   l_wip_supply_type_tab(i) = 1
                                 ) THEN

                                l_progress := '400';

                                --Check if parent goes to same job/line/schedule etc.., as that of the child
                                IF ( l_crossdock_type <> l_crossdock_type_tab(i) OR
                                     l_backorder_delivery_detail <> l_bk_dl_detail_tab(i) OR
                                     l_wip_supply_type <> l_wip_supply_type_tab(i) OR
                                     l_job  <> l_job_tab(i) OR
                                     l_line <> l_line_tab(i) OR
                                     l_dept <> l_dept_tab(i) OR
                                     l_operation_seq_num <> l_operation_seq_num_tab(i) OR
                                     l_wip_entity_type   <> l_wip_entity_type_tab(i) OR
                                     l_start_date <> l_start_date_tab(i) OR
                                     l_schedule   <> l_schedule_tab(i) OR
                                     l_assembly   <> l_assembly_tab(i)
                                   ) THEN
                                    -- Dest loc / Into LPN of parent is not equal that of child and hence
                                    -- can't be dropped by consolidated drop. So mark item drop for the Parent.
                                    l_progress := '410';

                                    IF (l_debug = 1) THEN
                                      DEBUG('WIP Details mismatch with the parent and hence calling Mark Item Drop for parent LPN ' || l_parent_lpn_id_tab(i),l_proc_name,9);
                                    END IF;

                                    l_rec_count := l_rec_count + Mark_Item_Drop(l_parent_lpn_id_tab(i));
                                    l_progress := '420';
                                END IF; --check for parents job/line/schedule etc..,

                              END IF; --WIP Crosdock check


                           END IF;-- dest loc / into LPN not null check

                         END IF; -- l_rowid not null check


                      END IF; -- parent_lpn_id not null check
                      l_progress := '400';

                   EXCEPTION
                     WHEN OTHERS THEN
                      DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
                      DEBUG(SQLERRM,l_proc_name,1);

                      IF c_parent_lpn_cursor%isopen THEN
                        CLOSE c_parent_lpn_cursor;
                      END IF;

                      IF c_lpn_cursor%isopen THEN
                        CLOSE c_lpn_cursor;
                      END IF;

                      RETURN -1;
                   END;

        --       END IF; -- drop type check

               END LOOP; --lpn_cursor_bulk collect loop


             END LOOP; --c_lpn_cursor loop

             CLOSE c_lpn_cursor;

      END LOOP;--lpn level cursor


      --R12: Revert MDC suggestions for all tasks that is flagged as item drop
      BEGIN
	 UPDATE mtl_material_transactions_temp
	   SET  cartonization_id = NULL
	   WHERE transaction_temp_id IN (SELECT gtmp.transaction_temp_id
					 FROM wms_putaway_group_tasks_gtmp gtmp
					 WHERE gtmp.consolidation_method_id = 1 --???MDC
					 AND gtmp.drop_type = g_dt_item_drop);

	 IF (l_debug = 1) THEN
	    DEBUG('Num of MMTT rows updated:' ||SQL%rowcount,l_proc_name,4);
	 END IF;

	 UPDATE wms_putaway_group_tasks_gtmp
	   SET  consolidation_method_id = 0
	   WHERE consolidation_method_id = 1
	   AND   drop_type = g_dt_item_drop;

	 IF (l_debug = 1) THEN
	    DEBUG('Num of GTMP rows updated:' ||SQL%rowcount,l_proc_name,4);
	 END IF;

      EXCEPTION
        WHEN OTHERS THEN
	   IF (l_debug = 1) THEN
	      DEBUG('ERROR REVERTING MDC SUGGESTIONS',l_proc_name,4);
	   END IF;
	   RAISE fnd_api.g_exc_unexpected_error;
      END;
      --R12 END

     l_progress := '500';
     IF (l_debug = 1) THEN
       DEBUG(' l_rec_count => '|| l_rec_count,l_proc_name,4);
       DEBUG(' Function Exited at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
     END IF;
     l_progress := '510';

     IF c_parent_lpn_cursor%isopen THEN
        CLOSE c_parent_lpn_cursor;
     END IF;
     l_progress := '515';

     IF c_lpn_cursor%isopen THEN
        CLOSE c_lpn_cursor;
     END IF;
     l_progress := '520';

     -- Return the number of rows populated as item drop in total
     RETURN l_rec_count;

    EXCEPTION
     WHEN OTHERS THEN
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_parent_lpn_cursor%isopen THEN
         CLOSE c_parent_lpn_cursor;
       END IF;

       IF c_lpn_cursor%isopen THEN
         CLOSE c_lpn_cursor;
       END IF;

       RETURN -1;
     END Populate_Drop_Type;




/**
  *   This function will populate the global temporary table
  *   WMS_PUTAWAY_GROUP_TASKS_GTMP with the required data and
  *   will return the count of rows in the temporary table as
  *   output.

  *   This method will also insert the dummy records for those
  *   LPN which doesnt have contents

  *   Drop all scenario is also taken care while inserting
  *   For drop all case, we will always start with the outermost lpn id.
  *   because we should be suggesting the consolidated lpn wherever possible

  *  @param  p_org_id    Organization ID
  *  @param  p_drop_type Drop Type
  *  @param  p_emp_id    Employee ID
  *  @param  p_lpn_id    LPN ID
  *  @ RETURN  NUMBER


**/
   FUNCTION Populate_Group_Tasks(
                  p_org_id          IN NUMBER,
                  p_drop_type       IN VARCHAR2,
                  p_emp_id          IN NUMBER,
                  p_lpn_id          IN NUMBER,
          p_item_drop_flag  IN VARCHAR2)
     RETURN NUMBER
     IS
      l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
      l_progress  VARCHAR2(10) := '10';
      l_proc_name VARCHAR2(30) := 'Populate_Group_Tasks:';
      l_rec_count NUMBER       := 0;

      l_rowid_tab            rowid_tab;
      l_tempid_tab           num_tab;
      l_orgid_tab            num_tab;
      l_parent_lpn_id_tab    num_tab;

      l_lpn_id_tab              num_tab;
      l_lpn_level_tab           num_tab;
      l_lpn_context_tab         num_tab;

      l_has_contents  NUMBER := 0;

      -- WIP related variables
      l_xdock_type_tab            num_tab;
      l_wip_supply_type_tab       num_tab;
      l_wip_entity_type_tab       num_tab;
      l_job_tab                   entity_tab;
      l_line_tab                  line_tab;
      l_dept_tab                  dept_tab;
      l_operation_seq_num_tab     num_tab;
      l_start_date_tab            date_tab;
      l_schedule_tab              entity_tab;
      l_assembly_tab              item_tab;
      l_wip_entity_id_tab         num_tab;

      l_return_status         VARCHAR2(30);
      l_msg_count             NUMBER;
      l_msg_data              VARCHAR2(10000);

      l_error_code            NUMBER;
      l_prim_qty              NUMBER;
      l_inspection_flag       NUMBER;
      l_load_flag             NUMBER;
      l_drop_flag             NUMBER;
      l_crossdock_flag        NUMBER;
      l_load_prim_quantity    NUMBER;
      l_inspect_prim_quantity NUMBER;
      l_drop_prim_quantity    NUMBER;
      l_xdock_prim_quantity   NUMBER;
      b_iscrossdocked         BOOLEAN := FALSE;

      -- This cursor will fetch all the lpns starting with the LPN passed
      -- For drop all, this will get all the LPNs which the user has loaded
      -- This cursor will also select the dummy LPN rows (lpn without contents)
      -- and also the level of the LPN
      CURSOR c_all_lpn_cursor IS
        SELECT lpn_id
              ,parent_lpn_id
              ,LEVEL
              ,lpn_context
        FROM wms_license_plate_numbers wln
        START WITH LPN_ID IN (
                              SELECT  wln.lpn_id
                              FROM    wms_license_plate_numbers wln
                              WHERE   p_drop_type <> G_DT_DROP_ALL
                                      AND wln.lpn_id = p_lpn_id
                              UNION ALL
                              SELECT wln.outermost_lpn_id
                              FROM   wms_dispatched_tasks     wdt
			            ,mtl_txn_request_lines    mtrl
			            ,mtl_material_transactions_temp mmtt
			            ,mtl_txn_request_headers  mtrh
                                    ,wms_license_plate_numbers wln
                              WHERE p_drop_type = G_DT_DROP_ALL
                                    AND mtrh.header_id = mtrl.header_id
                                    AND mtrh.move_order_type = 6
                                    AND mtrl.line_status = 7
			            AND wdt.transaction_temp_id = mmtt.transaction_temp_id
			            AND mmtt.move_order_line_id = mtrl.line_id
                                    AND wdt.STATUS = 4
                                    AND wdt.person_id = p_emp_id
                                    AND wln.lpn_id = mtrl.lpn_id
                              )
      CONNECT BY PRIOR wln.lpn_id = wln.parent_lpn_id;

      -- This cursor will get the temp ids of all the MMTTs in the temp table
      -- which are crossdocked to WIP Issue.
      CURSOR c_back_ordered_cursor IS
        SELECT ROWID
              ,transaction_temp_id
              ,organization_id
              ,Nvl(crossdock_type,0)
              ,Nvl(wip_supply_type,0)
   FROM  WMS_PUTAWAY_GROUP_TASKS_GTMP
        WHERE  1 = 1
               AND row_type = G_ROW_TP_ALL_TASK
               --AND crossdock_type > 1
               AND backorder_delivery_detail > 0;
               --AND wip_supply_type = 1;

   BEGIN
     --Printing the input parameters
     IF (l_debug = 1) THEN
      DEBUG(' Function Entered at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
      DEBUG(' p_org_id    => '||p_org_id,l_proc_name,4);
      DEBUG(' p_drop_type => '||p_drop_type,l_proc_name,4);
      DEBUG(' p_emp_id    => '||p_emp_id,l_proc_name,4);
      DEBUG(' p_lpn_id    => '||p_lpn_id,l_proc_name,4);
     END IF;

     l_progress := '15';

     BEGIN --Block to insert the 'All Task' rows

       OPEN c_all_lpn_cursor;
       l_progress := '20';
       LOOP --c_all_lpn_cursor cursor
         EXIT WHEN c_all_lpn_cursor%NOTFOUND;
         l_progress := '22';

         FETCH c_all_lpn_cursor
           BULK COLLECT
            INTO  l_lpn_id_tab
                 ,l_parent_lpn_id_tab
                 ,l_lpn_level_tab
                 ,l_lpn_context_tab
           LIMIT l_limit;
         l_progress := '25';

         FOR i IN 1..l_lpn_id_tab.COUNT
         LOOP -- all LPNs loop
           l_progress := '27';
           BEGIN -- Check Whether contents exists for this lpn
             l_progress := '30';
             SELECT 1
             INTO   l_has_contents
             FROM   wms_lpn_contents
             WHERE  parent_lpn_id = l_lpn_id_tab(i)
                    AND ROWNUM < 2;
             l_progress := '31';

           EXCEPTION
             WHEN no_data_found THEN
               l_progress := '33';
               l_has_contents := 0;
             WHEN OTHERS THEN
               l_progress := '35';
               RAISE fnd_api.g_exc_unexpected_error;
           END;-- Check Whether contents exists for this lpn

           --Check for contents
           IF l_has_contents = 0 THEN
             l_progress := '40';

             -- Don't insert dummy rows for all item drops
             -- In case of all item drop the consolidated lpn will be same as that of the lpn and
             -- drop type will be ID so we don't need dummy rows.
             IF p_item_drop_flag <> 'Y' THEN

                 l_progress := '45';
                 -- LPN don't have contents, so insert a dummy row
                 INSERT INTO WMS_PUTAWAY_GROUP_TASKS_GTMP
                   (
                           ORGANIZATION_ID
                          ,LPN_ID
                          ,PARENT_LPN_ID
                          ,DROP_TYPE
                          ,ROW_TYPE
                          ,LPN_LEVEL
                          ,LPN_CONTEXT
                          ,WIP_SUPPLY_TYPE
                   )
                 VALUES
                   (
                           p_org_id
                          ,l_lpn_id_tab(i)
                          ,l_parent_lpn_id_tab(i)
                          ,G_DT_CONSOLIDATED_DROP
                          ,G_ROW_TP_LPN_TASK
                          ,l_lpn_level_tab(i)
                          ,l_lpn_context_tab(I)
                          ,0
                   );
                 l_progress := '46';

                 IF (l_debug = 1) THEN
                   DEBUG('Inserted dummy row for lpn id ' || l_lpn_id_tab(i),l_proc_name,9);
                 END IF;

             END IF;


           ELSIF l_has_contents = 1 THEN
             -- LPN has contents so query from MTRL,WDT and insert into temp table

              l_progress := '50';
              --Data has to be ordered in the temp table later before processing, because ORDER BY during insert is not supported
              INSERT INTO WMS_PUTAWAY_GROUP_TASKS_GTMP
                (
                        ORGANIZATION_ID
                       ,TRANSACTION_TEMP_ID
                       ,TRANSACTION_HEADER_ID
                       ,LPN_ID
                       ,LPN_NAME
                       ,LPN_CONTEXT
                       ,PARENT_LPN_ID
                       ,PARENT_LPN_NAME
                       ,OUTERMOST_LPN_ID
                       ,OUTERMOST_LPN_NAME
                       ,CONSOLIDATED_LPN_ID
                       ,CONSOLIDATED_LPN_NAME
                       ,INTO_LPN_ID
                       ,INTO_LPN_NAME
                       ,DROP_TYPE
                       ,DROP_ORDER
                       ,INVENTORY_ITEM_ID
                       ,ITEM
                       ,GROUP_ID
                       ,LOT_NUMBER
                       ,REVISION
                       ,TRANSACTION_QUANTITY
                       ,TRANSACTION_UOM
                       ,LOCATOR
                       ,PRIMARY_UOM_CODE
                       ,DEST_SUBINVENTORY
                       ,DEST_LOCATOR
                       ,REVISION_QTY_CONTROL_CODE
                       ,LOT_CONTROL_CODE
                       ,SERIAL_NUMBER_CONTROL_CODE
                       ,RESTRICT_SUBINVENTORIES_CODE
                       ,RESTRICT_LOCATORS_CODE
                       ,LOCATION_CONTROL_CODE
                       ,ALLOWED_UNITS_LOOKUP_CODE
                       ,BACKORDER_DELIVERY_DETAIL
                       ,CROSSDOCK_TYPE
                       ,WIP_SUPPLY_TYPE
                       ,FROM_SUBINVENTORY
                       ,FROM_LOCATOR
                       ,TRANSFER_SUBINVENTORY
                       ,TRANSFER_TO_LOCATION
                       ,TRANSFER_ORGANIZATION
                       ,TRANSACTION_ACTION_ID
                       ,REFERENCE
                       ,LOC_DROPPING_ORDER
                       ,SUB_DROPPING_ORDER
                       ,ROW_TYPE
                       ,MOVE_ORDER_LINE_ID
                       ,PROJECT_ID
                       ,TASK_ID
                       ,TXN_SOURCE_ID
                       ,PRIMARY_QUANTITY
                       ,LPN_LEVEL
                       ,SECONDARY_QUANTITY --OPM Convergence
                       ,SECONDARY_UOM --OPM Convergence
		       ,show_message --R12
		       ,error_code --R12
		       ,error_explanation --R12
		)

                  SELECT DISTINCT
                        mmtt.organization_id,
                        mmtt.transaction_temp_id,
                        mmtt.transaction_header_id,
                        mtrl.lpn_id,
                        NULL,                   --lpn_name
                        l_lpn_context_tab(i),
                        --TO_NUMBER(NULL),        --Parent LPN ID
                        l_parent_lpn_id_tab(i), --Parent LPN ID
                        NULL,                   --Parent LPN Name
                        TO_NUMBER(NULL),        --Outermost LPN ID
                        NULL,                   --Outermost LPN Name
                        TO_NUMBER(NULL),        --Consolidated LPN ID
                        NULL,                   --Consolidated LPN Name
                        mmtt.cartonization_id,  --INTO LPN ID
                        NULL,                   --INTO LPN Name
                        decode(p_item_drop_flag,'Y',G_DT_ITEM_DROP,G_DT_CONSOLIDATED_DROP),                   --Drop Type
                        ROWNUM,                 --Drop Order
                        mmtt.inventory_item_id,
                        msik.concatenated_segments item, --Item
                        TO_NUMBER(NULL),        --Group ID
                        mtrl.lot_number,
                        mmtt.revision,
                        mmtt.transaction_quantity,
                        mmtt.transaction_uom,
                        NULL LOCATOR, --inv_project.get_locsegs (milk.inventory_location_id, milk.organization_id ) LOCATOR,
                        msik.primary_uom_code,
                        --DECODE (transaction_action_id, 2, mmtt.transfer_subinventory,mmtt.subinventory_code) dest_subinventory,
                        --DECODE (transaction_action_id, 2, mmtt.transfer_to_location, mmtt.locator_id) dest_locator,
                        NVL(mmtt.transfer_subinventory,mmtt.subinventory_code) dest_subinventory,
                        NVL(mmtt.transfer_to_location, mmtt.locator_id)        dest_locator,
                        NVL (msik.revision_qty_control_code, 1),
                        NVL (msik.lot_control_code, 1),
                        NVL (msik.serial_number_control_code, 1),
                        NVL (msik.restrict_subinventories_code, 2),
                        NVL (msik.restrict_locators_code, 2),
                        NVL (msik.location_control_code, 1),
                        NVL (msik.allowed_units_lookup_code, 2),
                        NVL (mtrl.backorder_delivery_detail_id, 0),
                        NVL (mtrl.crossdock_type, 0),
                        NVL (mmtt.wip_supply_type, 0),
                        mmtt.subinventory_code from_subinventory,
                        mmtt.locator_id from_locator,
                        mmtt.transfer_subinventory,
                        mmtt.transfer_to_location,
                        mmtt.transfer_organization,
                        mmtt.transaction_action_id,
                        mtrl.REFERENCE,
                        to_number(null), -- milk.dropping_order,
                        to_number(NULL), -- msi.dropping_order,
                        G_ROW_TP_ALL_TASK,
                        mtrl.line_id,
                        mtrl.project_id,
                        mtrl.task_id,
                        mtrl.txn_source_id,
                        mmtt.primary_quantity,
                        l_lpn_level_tab(i),
                        mmtt.secondary_transaction_quantity, --OPM Convergence
                        mmtt.secondary_uom_code, --OPM Convergence

		        --R12: Change Management: If suggested loc = wlpn.loc, should show iser wanring message
		        Decode(wln.locator_id,NVL(mmtt.transfer_to_location, mmtt.locator_id),1,0) show_message,
		        mmtt.error_code,
		        mmtt.error_explanation
		        --R12 End
		   FROM mtl_material_transactions_temp mmtt
                        ,mtl_txn_request_lines mtrl
                        ,wms_dispatched_tasks wdt
                        --,mtl_item_locations milk
                        ,mtl_system_items_kfv msik
                        ,mtl_txn_request_headers mtrh
                        ,wms_license_plate_numbers wln
                        --,mtl_secondary_inventories msi
                  WHERE wdt.organization_id = p_org_id
                -- kajain
                -- added the decode since a lpn loaded by someone
                -- should be eligible to be dropped by some other user
                -- also added a check to make sure that wdt.status = 4
                        AND wdt.person_id = Decode(p_drop_type, g_dt_drop_all,p_emp_id,wdt.person_id)
                        AND wdt.status = 4
                        AND wdt.task_type   = 2
                        AND wdt.transaction_temp_id = mmtt.transaction_temp_id
                        AND mmtt.move_order_line_id = mtrl.line_id
                        AND NVL (mmtt.wms_task_type, 0) <> -1
                        AND mtrl.lpn_id = l_lpn_id_tab(i)
                        AND wln.organization_id = p_org_id
                        AND mtrl.lpn_id    = wln.lpn_id
                        AND mtrl.header_id = mtrh.header_id
                        AND mtrh.move_order_type = 6
                        --AND NVL(mmtt.transfer_to_location,mmtt.locator_id) = milk.inventory_location_id(+)
                        --AND msi.organization_id(+) = mmtt.organization_id
                        --AND NVL(mmtt.transfer_subinventory,mmtt.subinventory_code)  = msi.secondary_inventory_name(+)
                        --AND mmtt.organization_id = milk.organization_id(+)
                        AND mmtt.organization_id = msik.organization_id
                        AND mmtt.inventory_item_id = msik.inventory_item_id;

              l_progress := '51';


              IF (l_debug = 1) THEN
                DEBUG('Inserted ' || SQL%rowcount || ' all task rows for lpn id ' || l_lpn_id_tab(i),l_proc_name,9);
              END IF;

           END IF;
           --Check for contents

         END LOOP; -- all LPNs loop

       END LOOP; --c_all_lpn_cursor cursor

       IF c_all_lpn_cursor%ISOPEN THEN
         l_progress := '60';
         CLOSE c_all_lpn_cursor;
         l_progress := '61';
       END IF;


     EXCEPTION
       WHEN OTHERS THEN
         l_progress := '90';
         RAISE fnd_api.g_exc_unexpected_error;
     END; --Block to insert the 'All Task' rows


      BEGIN -- WIP Integration

        l_progress := '300';

        IF (l_debug = 1) THEN
          DEBUG('Checking whether WIP Crossdock is possible ' ,l_proc_name,9);
        END IF;

        OPEN c_back_ordered_cursor;
        l_progress := '310';

        FETCH c_back_ordered_cursor
          BULK COLLECT
          INTO l_rowid_tab
              ,l_tempid_tab
              ,l_orgid_tab
              ,l_xdock_type_tab
              ,l_wip_supply_type_tab;
        l_progress := '320';

        CLOSE c_back_ordered_cursor;
        l_progress := '330';

        FOR i IN 1 .. l_rowid_tab.COUNT
        LOOP -- x-dock info loop

          -- Call Validate_Operation for this MMTT to check whetehr the current step is crossdock.
          -- Call the WIP Integration APIs only if the current step is crossdock
          -- Else reset the WIP Related columns in the temp table.
          -- If this is any other xdock reset the xdock columns as well
          wms_atf_runtime_pub_apis.validate_operation
          ( x_return_status         => l_return_status
           ,x_msg_data              => l_msg_data
           ,x_msg_count             => l_msg_count
           ,x_error_code            => l_error_code
           ,x_inspection_flag       => l_inspection_flag
           ,x_load_flag             => l_load_flag
           ,x_drop_flag             => l_drop_flag
           ,x_crossdock_flag        => l_crossdock_flag
           ,x_load_prim_quantity    => l_load_prim_quantity
           ,x_drop_prim_quantity    => l_drop_prim_quantity
           ,x_inspect_prim_quantity => l_inspect_prim_quantity
           ,x_crossdock_prim_quantity => l_xdock_prim_quantity
           ,p_source_task_id        => l_tempid_tab(i)
           ,p_move_order_line_id    => NULL
           ,p_inventory_item_id     => NULL
           ,p_lpn_id                => NULL
           ,p_activity_type_id      => G_OP_ACTIVITY_INBOUND
           ,p_organization_id       => l_orgid_tab(i));

          l_progress := '331';
          IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
               DEBUG(' Validate Operation failed for MMTT = ' || l_tempid_tab(i) || ' hence erroring out' ,l_proc_name,1);
               DEBUG(' Error = ' || l_msg_data,l_proc_name,1);
            END IF;
            --RAISE fnd_api.g_exc_error;
            RETURN -1;
          ELSE
              -- Successful execution. Check whether this step if crossdocked/not
             IF (l_debug = 1) THEN
                debug(' l_crossdock_flag is : ' || l_crossdock_flag,l_proc_name,1);
             END IF;

             IF (l_crossdock_flag = 1) THEN
                 b_iscrossdocked := FALSE;
             ELSE
                 b_iscrossdocked := TRUE;
             END IF;

          END IF;
          l_progress := '332';

          IF (l_debug = 1) THEN
             DEBUG(' API for temp_id  ' || l_tempid_tab(i) ,l_proc_name,9);
          END IF;

          IF (b_iscrossdocked) THEN --iscrossdocked

             l_progress := '332.1';
             IF (l_debug = 1) THEN
                DEBUG('XDOCK TYPE: ' || l_xdock_type_tab(i) ,l_proc_name,9);
                DEBUG('WIP_SUPPLY_TYPE: ' || l_wip_supply_type_tab(i) ,l_proc_name,9);
                DEBUG('TEMP_ID: ' || l_tempid_tab(i) ,l_proc_name,9);
             END IF;

             IF l_xdock_type_tab(i) = 2 AND l_wip_supply_type_tab(i) = 1 THEN
                IF (l_debug = 1) THEN
                  DEBUG('Calling WIP Integration API for temp_id  ' || l_tempid_tab(i) ,l_proc_name,9);
                END IF;
                l_progress := '333';

                wms_wip_integration.get_wip_info_for_putaway
                  (
                                 p_temp_id            => l_tempid_tab(i)
                                ,x_wip_entity_type    => l_wip_entity_type_tab(i)
                                ,x_job                => l_job_tab(i)
                                ,x_line               => l_line_tab(i)
                                ,x_dept               => l_dept_tab(i)
                                ,x_operation_seq_num  => l_operation_seq_num_tab(i)
                                ,x_start_date         => l_start_date_tab(i)
                                ,x_schedule           => l_schedule_tab(i)
                                ,x_assembly           => l_assembly_tab(i)
                                ,x_wip_entity_id      => l_wip_entity_id_tab(i)
                                ,x_return_status      => l_return_status
                                ,x_msg_count          => l_msg_count
                                ,x_msg_data           => l_msg_data
                               );
                l_progress := '334';

                IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                   IF (l_debug = 1) THEN
                      DEBUG('WIP info for putaway failed for MMTT = ' || l_tempid_tab(i) ,l_proc_name,1);
                      DEBUG('Error = ' || l_msg_data,l_proc_name,1);
                   END IF;
                   --RAISE fnd_api.g_exc_error;
                   RETURN -1;
                   l_progress := '340';
                END IF;
             ELSE
               --not crossdocked to WIP Issue
                l_wip_entity_type_tab(i)   := 0;
                l_job_tab(i)               := NULL;
                l_line_tab(i)              := NULL;
                l_dept_tab(i)              := NULL;
                l_operation_seq_num_tab(i) := NULL;
                l_wip_entity_type_tab(i)   := NULL;
                l_start_date_tab(i)        := NULL;
                l_schedule_tab(i)          := NULL;
                l_assembly_tab(i)          := NULL;
             END IF;
          ELSE
            -- The current step is not crossdock for this operation.
            -- so reset the crossdock related columns in the temp table.
            l_progress := '350';
            IF (l_debug = 1) THEN
              DEBUG('Resetting the xdock related cols for temp_id  ' || l_tempid_tab(i) ,l_proc_name,9);
            END IF;

            UPDATE  WMS_PUTAWAY_GROUP_TASKS_GTMP
              SET   wip_supply_type = 0
                   ,backorder_delivery_detail = 0
                   ,crossdock_type = 0
              WHERE transaction_temp_id = l_tempid_tab(i);
            l_progress := '355';

            -- Setting these wip related columns explicitly to null
            -- so that the a row is created in the pl/sql table for that rowid
            -- and hence the bulk update below won't fail.
            l_wip_entity_type_tab(i)   := 0;
            l_job_tab(i)               := NULL;
            l_line_tab(i)              := NULL;
            l_dept_tab(i)              := NULL;
            l_operation_seq_num_tab(i) := NULL;
            l_wip_entity_type_tab(i)   := NULL;
            l_start_date_tab(i)        := NULL;
            l_schedule_tab(i)          := NULL;
            l_assembly_tab(i)          := NULL;

            l_progress := '360';

          END IF; --iscrossdocked

        END LOOP; -- WIP info loop

        l_progress := '370';

        -- Update back these details into the temp table
        FORALL i IN 1 .. l_rowid_tab.COUNT
          UPDATE WMS_PUTAWAY_GROUP_TASKS_GTMP
          SET    WIP_JOB  = l_job_tab(i)
                ,WIP_LINE = l_line_tab(i)
                ,WIP_DEPT = l_dept_tab(i)
                ,WIP_OP_SEQ      = l_operation_seq_num_tab(i)
                ,WIP_ENTITY_TYPE = l_wip_entity_type_tab(i)
                ,WIP_START_DATE  = l_start_date_tab(i)
                ,WIP_SCHEDULE    = l_schedule_tab(i)
                ,WIP_ASSEMBLY    = l_assembly_tab(i)
                ,BACKORDER_DELIVERY_DETAIL = l_wip_entity_type_tab(i)
          WHERE  ROWID = l_rowid_tab(i)
          AND Nvl(crossdock_type,1) = 2
          AND wip_supply_type = 1;

          l_progress := '380';

        IF (l_debug = 1) THEN
          DEBUG('After updating the WIP related for ' || l_rowid_tab.COUNT || ' row(s) ' ,l_proc_name,9);
        END IF;
        l_progress := '390';

      EXCEPTION
        WHEN OTHERS THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END; -- WIP Integration


      IF (l_debug = 1) THEN
        DEBUG(' Before calling pvt function get_row_count ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,9);
      END IF;

      l_progress := '500';
      --Calling get_row_count to get the number of rows in global temp table
      l_rec_count := get_row_count(p_mode => 2);
      l_progress := '510';

      IF (l_debug = 1) THEN
        DEBUG(' After calling pvt function get_row_count ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,9);
        DEBUG(' l_rec_count => '|| l_rec_count,l_proc_name,4);
      END IF;


      l_progress := '900';
      IF (l_debug = 1) THEN
       DEBUG(' l_rec_count => '|| l_rec_count,l_proc_name,4);
       DEBUG(' Function Exited at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
      END IF;
      l_progress := '910';

     -- Return the number of rows in the temp table after populate
     RETURN l_rec_count;


   EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_all_lpn_cursor%ISOPEN THEN
         CLOSE c_all_lpn_cursor;
       END IF;

       IF c_back_ordered_cursor%ISOPEN THEN
        CLOSE c_back_ordered_cursor;
       END IF;

       RETURN -1;


     WHEN fnd_api.g_exc_unexpected_error THEN
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_all_lpn_cursor%ISOPEN THEN
         CLOSE c_all_lpn_cursor;
       END IF;

       IF c_back_ordered_cursor%ISOPEN THEN
        CLOSE c_back_ordered_cursor;
       END IF;

       RETURN -1;


      WHEN OTHERS THEN
        DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
        DEBUG(SQLERRM,l_proc_name,1);

        IF c_all_lpn_cursor%ISOPEN THEN
          CLOSE c_all_lpn_cursor;
        END IF;

        IF c_back_ordered_cursor%ISOPEN THEN
         CLOSE c_back_ordered_cursor;
        END IF;

        RETURN -1;
     END Populate_group_tasks;


/**
  *   This function will call the ATF API to activate the
  *   operation instance for load. It will call the ATF API
  *   wms_atf_runtime_pub_apis.activate_operation_instance for
  *   each MMTT. For the immediate and the child contents of the
  *   LPN being passed.
  *
  *   It returns the number of rows for which the plan is
  *   activated, will return -1 in case of failure.

  *  @param   x_return_status   Return status of the function - Success, Error, Unexpected Error, Warning etc.,
  *  @param   x_msg_count       Count of messages in the stack
  *  @param   x_msg_data        Actual message if the count = 1 else it will be null.
  *  @param   p_org_id          Organization Identifier
  *  @param   p_lpn_id          LPN Identifier
  *  @param   p_emp_id          Employee Identifier
  *  @ RETURN  NUMBER


**/
   FUNCTION Activate_Plan_For_Load(
       x_return_status OUT  NOCOPY  VARCHAR2
      ,x_msg_count     OUT  NOCOPY  NUMBER
      ,x_msg_data      OUT  NOCOPY  VARCHAR2
      ,p_org_id        IN           NUMBER
      ,p_lpn_id        IN           NUMBER
      ,p_emp_id        IN           NUMBER )
     RETURN NUMBER
     IS

     l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress  VARCHAR2(10) := '10';
     l_rec_count NUMBER       := 0;
     l_proc_name VARCHAR2(30) := 'Activate_Plan_For_Load:';

     l_error_code         NUMBER;
     l_task_rec           task_rec   := NULL;
     l_tempid_tab         num_tab;

     l_consolidation_method_id NUMBER;
     l_drop_lpn_option NUMBER;

     -- This cursor will get the MMTTs assoicated with the contents of the LPN passed
     -- along with the MMTTs of the contents of all its child LPNs also.
     --Bug5723418.Performance fix.Moved wlpn to FROM clause. Added hint
     -- Performane fix as a part of bug 7143123
    	CURSOR c_all_mmtt_cursor IS 	-- Bug 7453925
	SELECT  /*+ ORDERED USE_NL(mtrl mmtt) INDEX(MTRL MTL_TXN_REQUEST_LINES_N7) */
              mmtt.transaction_temp_id
        FROM     ( SELECT lpn_id FROM   wms_license_plate_numbers
                                  START  WITH lpn_id = p_lpn_id
                                  CONNECT BY PRIOR lpn_id = parent_lpn_id
                       ) wlpn,
                      mtl_txn_request_lines mtrl,
                      mtl_material_transactions_temp mmtt
	WHERE mtrl.line_id = mmtt.move_order_line_id
             AND mtrl.line_status = 7
 	     AND mtrl.lpn_id = wlpn.lpn_id ;


   BEGIN

     IF (l_debug = 1) THEN
        DEBUG('Start of function ' || l_proc_name ,l_proc_name,9);
        DEBUG('  p_org_id ==> '|| p_org_id,l_proc_name,4);
        DEBUG('  p_lpn_id ==> '|| p_lpn_id,l_proc_name,4);
        DEBUG('  p_emp_id ==> '|| p_emp_id,l_proc_name,4);
     END IF;

     -- Set the return status to success.
     l_progress := '20';
     x_return_status  := fnd_api.g_ret_sts_success;
     l_progress := '30';

       -- Setting the values for the task record
       -- Neednot set these values for drop since there ia already WDT,
       -- ATF will just change the status of this WDT record

       l_task_rec.person_id       := p_emp_id;
       l_task_rec.organization_id := p_org_id;
       l_task_rec.user_task_type  := -1;

     l_progress := '100';
     OPEN c_all_mmtt_cursor;
     l_progress := '110';

     LOOP -- c_all_mmtt_cursor loop

       EXIT WHEN c_all_mmtt_cursor%NOTFOUND;
       l_progress := '200';

       FETCH c_all_mmtt_cursor
         BULK COLLECT
          INTO l_tempid_tab
         LIMIT l_limit;
       l_progress := '210';

       l_rec_count := l_rec_count + l_tempid_tab.COUNT;
       l_progress := '220';

       -- Activate each MMTT's
       FOR i IN 1 .. l_tempid_tab.COUNT
       LOOP --All temp ids loop

          IF (l_debug = 1) THEN
             DEBUG('Calling activate_operation_instance with ...',l_proc_name,9);
             DEBUG('p_source_task_id    => ' || l_tempid_tab(i),l_proc_name,9);
             DEBUG('p_activity_type_id  => ' || G_OP_ACTIVITY_INBOUND,l_proc_name,9);
             DEBUG('p_task_execute_rec  => l_task_rec',l_proc_name,9);
             DEBUG('p_operation_type_id => ' || G_OP_TYPE_DROP,l_proc_name,9);
          END IF;
          l_progress := '300';

          wms_atf_runtime_pub_apis.activate_operation_instance
             (  p_source_task_id    => l_tempid_tab(i)
               ,p_activity_id       => G_OP_ACTIVITY_INBOUND
               ,p_task_execute_rec  => l_task_rec
               ,p_operation_type_id => G_OP_TYPE_LOAD
               ,x_return_status     => x_return_status
               ,x_msg_data          => x_msg_data
               ,x_msg_count         => x_msg_count
               ,x_error_code        => l_error_code
	       ,x_consolidation_method_id => l_consolidation_method_id
	       ,x_drop_lpn_option   => l_drop_lpn_option
		);
          l_progress := '310';

          IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
             IF (l_debug = 1) THEN
                DEBUG(l_error_code || ' Error in activate_operation_instance ' ,l_proc_name,1);
             END IF;
             l_progress := '320';

             RAISE fnd_api.g_exc_error;
          END IF;

       END LOOP; --All temp ids loop

     END LOOP; -- c_all_mmtt_cursor loop


     IF c_all_mmtt_cursor%ISOPEN THEN
       CLOSE c_all_mmtt_cursor;
     END IF;

     l_progress := '990';
     --Return the count of rows processed
     RETURN l_rec_count;

   EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       x_return_status  := fnd_api.g_ret_sts_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_all_mmtt_cursor%ISOPEN THEN
         CLOSE c_all_mmtt_cursor;
       END IF;

       RETURN -1;


     WHEN fnd_api.g_exc_unexpected_error THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_all_mmtt_cursor%ISOPEN THEN
         CLOSE c_all_mmtt_cursor;
       END IF;

       RETURN -1;


     WHEN OTHERS THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_all_mmtt_cursor%ISOPEN THEN
         CLOSE c_all_mmtt_cursor;
       END IF;

       RETURN -1;

   END Activate_Plan_For_Load;


/**
  *   This function will call the ATF API to complete the operation instance for load.
  *   It will call the ATF API  wms_atf_runtime_pub_apis.activate_operation_instance for
  *   each MMTT. For the immediate and the child contents of the LPN being passed.
  *
  *   It returns the number of rows for which the plan is  completed. will return -1 in case of failure.

  *  @param   x_return_status   Return status of the function - Success, Error, Unexpected Error, Warning etc.,
  *  @param   x_msg_count       Count of messages in the stack
  *  @param   x_msg_data        Actual message if the count = 1 else it will be null.
  *  @param   p_org_id          Organization Identifier
  *  @param   p_lpn_id          LPN Identifier
  *  @param   p_emp_id          Employee Identifier
  *  @ RETURN  NUMBER


**/
   FUNCTION Complete_Plan_For_Load(
       x_return_status OUT  NOCOPY  VARCHAR2
      ,x_msg_count     OUT  NOCOPY  NUMBER
      ,x_msg_data      OUT  NOCOPY  VARCHAR2
      ,p_org_id        IN           NUMBER
      ,p_lpn_id        IN           NUMBER
      ,p_emp_id        IN           NUMBER )
     RETURN NUMBER
     IS

     l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress  VARCHAR2(10) := '10';
     l_rec_count NUMBER       := 0;
     l_proc_name VARCHAR2(30) := 'Complete_Plan_For_Load:';

     l_error_code         NUMBER;
     l_tempid_tab         num_tab;

     -- This cursor will get the MMTTs assoicated with the contents of the LPN passed
     -- along with the MMTTs of the contents of all its child LPNs also.
     --Bug5723418.Performance fix.Moved wlpn to FROM clause.Also added hint
     -- Performane fix as a part of bug 7143123
    	CURSOR c_all_mmtt_cursor IS 	-- Bug 7453925
	SELECT  /*+ ORDERED USE_NL(mtrl mmtt) INDEX(MTRL MTL_TXN_REQUEST_LINES_N7) */
              mmtt.transaction_temp_id
        FROM     ( SELECT lpn_id FROM   wms_license_plate_numbers
                                  START  WITH lpn_id = p_lpn_id
                                  CONNECT BY PRIOR lpn_id = parent_lpn_id
                       ) wlpn,
                      mtl_txn_request_lines mtrl,
                      mtl_material_transactions_temp mmtt
	WHERE mtrl.line_id = mmtt.move_order_line_id
             AND mtrl.line_status = 7
 	     AND mtrl.lpn_id = wlpn.lpn_id ;


   BEGIN

     IF (l_debug = 1) THEN
        DEBUG('Start of function ' || l_proc_name ,l_proc_name,9);
        DEBUG('  p_org_id ==> '|| p_org_id,l_proc_name,4);
        DEBUG('  p_lpn_id ==> '|| p_lpn_id,l_proc_name,4);
        DEBUG('  p_emp_id ==> '|| p_emp_id,l_proc_name,4);
     END IF;

     -- Set the return status to success.
     l_progress := '20';
     x_return_status  := fnd_api.g_ret_sts_success;
     l_progress := '30';

     l_progress := '100';
     OPEN c_all_mmtt_cursor;
     l_progress := '110';

     LOOP -- c_all_mmtt_cursor loop

       EXIT WHEN c_all_mmtt_cursor%NOTFOUND;
       l_progress := '200';

       FETCH c_all_mmtt_cursor
         BULK COLLECT
          INTO l_tempid_tab
         LIMIT l_limit;
       l_progress := '210';

       l_rec_count := l_rec_count + l_tempid_tab.COUNT;
       l_progress := '220';

       -- Complete the Load Operation for each MMTT's
       FOR i IN 1 .. l_tempid_tab.COUNT
       LOOP --All temp ids loop

          IF (l_debug = 1) THEN
             DEBUG('Calling complete_operation_instance with ...',l_proc_name,9);
             DEBUG('p_source_task_id    => ' || l_tempid_tab(i),l_proc_name,9);
             DEBUG('p_activity_type_id  => ' || G_OP_ACTIVITY_INBOUND,l_proc_name,9);
             DEBUG('p_task_execute_rec  => l_task_rec',l_proc_name,9);
             DEBUG('p_operation_type_id => ' || G_OP_TYPE_DROP,l_proc_name,9);
          END IF;
          l_progress := '300';

          wms_atf_runtime_pub_apis.complete_operation_instance
             (  p_source_task_id    => l_tempid_tab(i)
               ,p_activity_id       => G_OP_ACTIVITY_INBOUND
               ,p_operation_type_id => G_OP_TYPE_LOAD
               ,x_return_status     => x_return_status
               ,x_msg_data          => x_msg_data
               ,x_msg_count         => x_msg_count
               ,x_error_code        => l_error_code
             );
          l_progress := '310';

          IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
             IF (l_debug = 1) THEN
                DEBUG(l_error_code || ' Error in complete_operation_instance ' ,l_proc_name,1);
             END IF;
             l_progress := '320';

             RAISE fnd_api.g_exc_error;
          END IF;

       END LOOP; --All temp ids loop

     END LOOP; -- c_all_mmtt_cursor loop


     IF c_all_mmtt_cursor%ISOPEN THEN
       CLOSE c_all_mmtt_cursor;
     END IF;

     l_progress := '990';
     --Return the count of rows processed
     RETURN l_rec_count;

   EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       x_return_status  := fnd_api.g_ret_sts_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_all_mmtt_cursor%ISOPEN THEN
         CLOSE c_all_mmtt_cursor;
       END IF;

       RETURN -1;


     WHEN fnd_api.g_exc_unexpected_error THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_all_mmtt_cursor%ISOPEN THEN
         CLOSE c_all_mmtt_cursor;
       END IF;

       RETURN -1;


     WHEN OTHERS THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_all_mmtt_cursor%ISOPEN THEN
         CLOSE c_all_mmtt_cursor;
       END IF;

       RETURN -1;

   END Complete_Plan_For_Load;




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
      ,p_emp_id        IN           NUMBER )
     IS

     l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress  VARCHAR2(10) := '10';
     l_rec_count NUMBER       := 0;
     l_proc_name VARCHAR2(30) := 'Complete_ATF_Load:';

     l_tempid_tab         num_tab;

   BEGIN

     IF (l_debug = 1) THEN
        DEBUG('Start of Procedure ' || l_proc_name ,l_proc_name,9);
        DEBUG('  p_org_id ==> '|| p_org_id,l_proc_name,4);
        DEBUG('  p_lpn_id ==> '|| p_lpn_id,l_proc_name,4);
        DEBUG('  p_emp_id ==> '|| p_emp_id,l_proc_name,4);
     END IF;

     -- Set the return status to success.
     l_progress := '20';
     x_return_status  := fnd_api.g_ret_sts_success;
     l_progress := '30';

     IF (l_debug = 1) THEN
        DEBUG(' Calling Activate Instance for the LOAD Operation ... ' || x_msg_data ,l_proc_name,9);
     END IF;

     l_progress := '100';
     -- Activate the LOAD operation
     l_rec_count := Activate_Plan_For_Load(
                             x_return_status  => x_return_status
                            ,x_msg_count      => x_msg_count
                            ,x_msg_data       => x_msg_data
                            ,p_org_id         => p_org_id
                            ,p_lpn_id         => p_lpn_id
                            ,p_emp_id         => p_emp_id);

     l_progress := '110';

     IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
        IF (l_debug = 1) THEN
           DEBUG(' Error in Activate_Plan_For_Load ' || x_msg_data ,l_proc_name,1);
        END IF;
        l_progress := '120';

        RAISE fnd_api.g_exc_error;
     ELSE
       IF (l_debug = 1) THEN
          DEBUG('Successfully called Activate_Plan_For_Load for ' || l_rec_count || ' row(s)' ,l_proc_name,9);
       END IF;
       l_progress := '130';

     END IF;

     IF (l_debug = 1) THEN
        DEBUG(' Calling Complete Instance for the LOAD Operation ... ' || x_msg_data ,l_proc_name,9);
     END IF;

     l_progress := '200';
     -- Complete the LOAD operation
     l_rec_count := Complete_Plan_For_Load(
                             x_return_status  => x_return_status
                            ,x_msg_count      => x_msg_count
                            ,x_msg_data       => x_msg_data
                            ,p_org_id         => p_org_id
                            ,p_lpn_id         => p_lpn_id
                            ,p_emp_id         => p_emp_id);

     l_progress := '210';

     IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
        IF (l_debug = 1) THEN
           DEBUG(' Error in Complete_Plan_For_Load ' || x_msg_data ,l_proc_name,1);
        END IF;
        l_progress := '220';

        RAISE fnd_api.g_exc_error;
     ELSE
        IF (l_debug = 1) THEN
           DEBUG('Successfully called Complete_Plan_For_Load for ' || l_rec_count || ' row(s)' ,l_proc_name,9);
        END IF;
        l_progress := '130';

     END IF;

     l_progress := '990';

   EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       x_return_status  := fnd_api.g_ret_sts_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

     WHEN fnd_api.g_exc_unexpected_error THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

     WHEN OTHERS THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

   END Complete_ATF_Load;





/**
  *   This function will call the ATF API to activate the operation instance for drop
  *   It will call the ATF API wms_atf_runtime_pub_apis.activate_operation_instance
  *   for each 'All Task' row in the temp table.
  *
  *   After call to ATF API the new dest sub/loc/LPN will be updated back to the
  *   global temp table.
  *
  *   It returns the number of rows for which the plan is activated
  *   will return -1 in case of failure.

  *  @param  x_return_status  Return status of the function - Success, Error, Unexpected Error, Warning etc.,
  *  @param  x_msg_count      Count of messages in the stack
  *  @param  x_msg_data       Actual message if the count = 1 else it will be null.
  *
  *  @ RETURN  number


**/
     FUNCTION Activate_Plan_For_Drop(
                      x_return_status   OUT  NOCOPY  VARCHAR2,
                      x_msg_count       OUT  NOCOPY  NUMBER,
                      x_msg_data        OUT  NOCOPY  VARCHAR2 )

       RETURN NUMBER
       IS
        l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
        l_progress  VARCHAR2(10) := '10';
        l_rec_count NUMBER       := 0;
        l_proc_name VARCHAR2(30) := 'Activate_Plan_For_Drop:';

        l_error_code         NUMBER;
        l_task_rec           task_rec   := NULL;
        l_rowid_tab          rowid_tab;
        l_tempid_tab         num_tab;
        l_into_lpn_id_tab    num_tab;
        l_into_lpn_name_tab  lpn_name_tab;
        l_dest_sub_tab       sub_name_tab;
        l_dest_loc_tab       num_tab;
        l_sub_drop_order_tab num_tab;
        l_loc_drop_order_tab num_tab;
	l_show_message_tab   num_tab;--R12
	l_error_code_tab     varchar240_tab;
	l_drop_lpn_option_tab num_tab;
	l_consolidation_method_id_tab num_tab;
	l_lpn_controlled_flag_tab num_tab;
	l_lpn_locator_tab    num_tab;

	l_drop_lpn_option NUMBER;

	l_consolidation_method_id NUMBER;
        -- This cursor will get the transaction_temp_id of all the MMTTs which are going to
        -- be processed for this drop.
        -- The rowid is also selected inorder to update back the dest sub/loc/LPN to the temp table.
        CURSOR c_all_tasks_cursor IS
          SELECT ROWID
	         ,transaction_temp_id
	         ,show_message
	         ,error_code
          FROM   wms_putaway_group_tasks_gtmp
          WHERE  row_type = G_ROW_TP_ALL_TASK;

        -- This cursor will get the MMTT details for the temp id passed
        CURSOR c_mmtt_cursor(v_transaction_temp_id NUMBER) IS
          SELECT NVL(mmtt.transfer_subinventory,mmtt.subinventory_code) dest_subinventory
                ,NVL(mmtt.transfer_to_location, mmtt.locator_id)        dest_locator
                ,mmtt.cartonization_id        into_lpn_id
                ,wlpn.license_plate_number    into_lpn_name
                ,msi.dropping_order           sub_dropping_order
	        ,milk.dropping_order          loc_dropping_order
	        ,Nvl(msi.lpn_controlled_flag,2) lpn_controlled_flag
	  FROM   mtl_material_transactions_temp mmtt
                ,wms_license_plate_numbers      wlpn
                ,mtl_secondary_inventories      msi
                ,mtl_item_locations_kfv         milk
          WHERE mmtt.transaction_temp_id  = v_transaction_temp_id
                AND mmtt.cartonization_id = wlpn.lpn_id(+)
                AND NVL(mmtt.transfer_to_location,mmtt.locator_id) = milk.inventory_location_id(+)
                AND msi.organization_id(+) = mmtt.organization_id
                AND NVL(mmtt.transfer_subinventory,mmtt.subinventory_code)  = msi.secondary_inventory_name(+)
                AND mmtt.organization_id = milk.organization_id(+);

     BEGIN

       IF (l_debug = 1) THEN
          DEBUG('Start of function ' || l_proc_name ,l_proc_name,9);
       END IF;


       -- Set the return status to success.
       l_progress := '20';
       x_return_status  := fnd_api.g_ret_sts_success;
       l_progress := '30';

       -- Setting the values for the task record
       -- Neednot set these values for drop since there ia already WDT,
       -- ATF will just change the status of this WDT record
       /*
       l_task_rec.person_id       := p_emp_id;
       l_task_rec.organization_id := p_org_id;
       l_task_rec.user_task_type  := -1;
       */

       l_progress := '100';
       OPEN c_all_tasks_cursor;
       l_progress := '110';

       LOOP -- c_all_tasks_cursor loop

         EXIT WHEN c_all_tasks_cursor%NOTFOUND;
         l_progress := '200';

         FETCH c_all_tasks_cursor
           BULK COLLECT
            INTO l_rowid_tab
	         ,l_tempid_tab
	         ,l_show_message_tab
	         ,l_error_code_tab
           LIMIT l_limit;
         l_progress := '210';

         l_rec_count := l_rec_count + l_tempid_tab.COUNT;
         l_progress := '220';

         -- Activate each MMTT's
         FOR i IN 1 .. l_tempid_tab.COUNT
         LOOP --All temp ids loop

            IF (l_debug = 1) THEN
               DEBUG('Calling activate_operation_instance with ...',l_proc_name,9);
               DEBUG('p_source_task_id    => ' || l_tempid_tab(i),l_proc_name,9);
               DEBUG('p_activity_type_id  => ' || G_OP_ACTIVITY_INBOUND,l_proc_name,9);
               DEBUG('p_task_execute_rec  => l_task_rec',l_proc_name,9);
               DEBUG('p_operation_type_id => ' || G_OP_TYPE_DROP,l_proc_name,9);
            END IF;
            l_progress := '300';

            wms_atf_runtime_pub_apis.activate_operation_instance
               (  p_source_task_id    => l_tempid_tab(i)
                 ,p_activity_id       => G_OP_ACTIVITY_INBOUND
                 ,p_task_execute_rec  => l_task_rec
                 ,p_operation_type_id => G_OP_TYPE_DROP
                 ,x_return_status     => x_return_status
                 ,x_msg_data          => x_msg_data
                 ,x_msg_count         => x_msg_count
                 ,x_error_code        => l_error_code
		 ,x_consolidation_method_id => l_consolidation_method_id
		 ,x_drop_lpn_option   => l_drop_lpn_option
		  );
            l_progress := '310';

	    IF (l_debug = 1) THEN
               DEBUG('activate_operation_instance returned',l_proc_name,9);
               DEBUG('x_return_status            => '||x_return_status,l_proc_name,9);
               DEBUG('x_consolidation_method_id  => '||l_consolidation_method_id,l_proc_name,9);
	       debug('x_drop_lpn_option          => '||l_drop_lpn_option,l_proc_name,9);
	       debug('x_msg_data                 => '||x_msg_data,l_proc_name,9);
	       debug('x_msg_count                => '||x_msg_count,l_proc_name,9);
	       debug('x_error_code               => '||l_error_code,l_proc_name,9);
	    END IF;

	    --R12: ATF will pass back the status 'W' if all the
	    --consolidation locators are full.  If so, get the message from
	    --the stack and store it in the GTMP
	    IF (x_return_status = 'W') THEN
	       l_show_message_tab(i) := 2;
	       --Assume that x_msg_data stores the translated string, so
	       --the UI just needs to show the string without any translation
	       l_error_code_tab(i) := x_msg_data;

	     ELSIF (x_return_status <> fnd_api.g_ret_sts_success) THEN
               IF (l_debug = 1) THEN
                  DEBUG(l_error_code || ' Error in activate_operation_instance ' ,l_proc_name,1);
               END IF;
               l_progress := '320';

               RAISE fnd_api.g_exc_error;
            END IF;

	    l_drop_lpn_option_tab(i) := l_drop_lpn_option;
	    l_consolidation_method_id_tab(i) := l_consolidation_method_id;

         -- ATF would have updated the dest sub/loc/LPN in MMTT. So query it and sync it with the temp table.

         -- Querying the dest sub/loc/LPN for the acitvated row
         l_progress := '400';
         OPEN c_mmtt_cursor(l_tempid_tab(i));
         l_progress := '410';

         IF (l_debug = 1) THEN
            DEBUG(' Getting the details of the activated row ' ,l_proc_name,9);
         END IF;

         FETCH  c_mmtt_cursor
           INTO l_dest_sub_tab(i)
               ,l_dest_loc_tab(i)
               ,l_into_lpn_id_tab(i)
               ,l_into_lpn_name_tab(i)
               ,l_sub_drop_order_tab(i)
	       ,l_loc_drop_order_tab(i)
	       ,l_lpn_controlled_flag_tab(i);

	 IF (l_debug = 1) THEN
            DEBUG('show_message: '||l_show_message_tab(i),l_proc_name,9);
         END IF;

	 l_progress := '420';

         CLOSE c_mmtt_cursor;
         l_progress := '430';

         END LOOP; --All temp ids loop

         IF (l_debug = 1) THEN
            DEBUG('Doing a BULK update of temp table with the ATF suggested dest sub/loc/LPN ' ,l_proc_name,9);
         END IF;

         -- Do the bulk update on the temp table with the ATF suggested dest sub/loc/lpn
         FORALL i IN 1 .. l_tempid_tab.COUNT
           UPDATE wms_putaway_group_tasks_gtmp
           SET    dest_subinventory  = l_dest_sub_tab(i)
                 ,dest_locator       = l_dest_loc_tab(i)
                 ,into_lpn_id        = l_into_lpn_id_tab(i)
                 ,into_lpn_name      = l_into_lpn_name_tab(i)
                 ,locator            = inv_project.get_locsegs (l_dest_loc_tab(i), organization_id)
                 ,sub_dropping_order = l_sub_drop_order_tab(i)
                 ,loc_dropping_order = l_loc_drop_order_tab(i)
	         ,show_message       = l_show_message_tab(i) --R12
	         ,error_code         = l_error_code_tab(i) --???
	         ,drop_lpn_option  = l_drop_lpn_option_tab(i) --R12
	         ,consolidation_method_id = l_consolidation_method_id_tab(i) --R12
	         ,sub_lpn_controlled_flag = l_lpn_controlled_flag_tab(i) --R12
	   WHERE ROWID = l_rowid_tab(i);
         l_progress := '440';

         IF (l_debug = 1) THEN
            DEBUG('Done a BULK update of this set of acivated MMTTs. rows = ' || SQL%ROWCOUNT ,l_proc_name,9);
         END IF;


       END LOOP; -- c_all_tasks_cursor loop

       -- Close all the open cursors if any.
       IF c_all_tasks_cursor%ISOPEN THEN
         l_progress := '500';
         CLOSE c_all_tasks_cursor;
       END IF;

       IF c_mmtt_cursor%ISOPEN THEN
         l_progress := '510';
         CLOSE c_mmtt_cursor;
       END IF;

       l_progress := '990';
       --Return the count of rows processed
       RETURN l_rec_count;

     EXCEPTION
       WHEN fnd_api.g_exc_error THEN
         x_return_status  := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
         DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
         DEBUG(SQLERRM,l_proc_name,1);

         IF c_all_tasks_cursor%ISOPEN THEN
            CLOSE c_all_tasks_cursor;
         END IF;

         IF c_mmtt_cursor%ISOPEN THEN
           CLOSE c_mmtt_cursor;
         END IF;

         RETURN -1;


       WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status  := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

         DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
         DEBUG(SQLERRM,l_proc_name,1);

         IF c_all_tasks_cursor%ISOPEN THEN
            CLOSE c_all_tasks_cursor;
         END IF;

         IF c_mmtt_cursor%ISOPEN THEN
           CLOSE c_mmtt_cursor;
         END IF;

         RETURN -1;


       WHEN OTHERS THEN
         x_return_status  := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
         DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
         DEBUG(SQLERRM,l_proc_name,1);

         IF c_all_tasks_cursor%ISOPEN THEN
            CLOSE c_all_tasks_cursor;
         END IF;

         IF c_mmtt_cursor%ISOPEN THEN
           CLOSE c_mmtt_cursor;
         END IF;

         RETURN -1;

     END Activate_Plan_For_Drop;


/**
  *   This procedure will lock the LPNs which are in the temp table.
  *   Though the LPN is locked in the method Check_LPN_Validity,
  *   We are locking it again since the commits in between will releive the locks.

  *  @param  x_return_status  Return status of the procedure - Success, Error, Unexpected Error, Warning etc.,
  *  @param  x_msg_count      Count of messages in the stack
  *  @param  x_msg_data       Actual message if the count = 1 else it will be null.
**/
  PROCEDURE Lock_LPNs(
            x_return_status   OUT  NOCOPY  VARCHAR2
           ,x_msg_count       OUT  NOCOPY  NUMBER
           ,x_msg_data        OUT  NOCOPY  VARCHAR2 )
    IS

    l_debug         NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_progress      VARCHAR2(10)  := '10';
    l_proc_name     VARCHAR2(30)  := 'Lock_LPNs:';
    l_rec_count     NUMBER        := 0;

    -- Need to trap the error returned when
    -- unable to lock the lpn record.
    record_locked      EXCEPTION;
    PRAGMA EXCEPTION_INIT(record_locked, -54);

    l_lpn_id_tab    num_tab;

  BEGIN

    IF (l_debug = 1) THEN
      debug(' Start of procedure. Trying to lock all the LPNs in the temp table', l_proc_name,1);
    END IF;

    l_progress := '100';
    x_return_status  := fnd_api.g_ret_sts_success;
    l_progress := '110';

    -- Bulk Lock all LPNs which are in the temp table.
    -- So that other user can't work on them

    -- Bug#3821032 We need not lock the LPNs in receiving since it will cause deadlock if called in concurrent mode
    -- For receiving LPNs the Check_LPN_Validity wrapper takes care of locking Operation Instance records.
    -- So that other user(s) can't work on this LPN.
    SELECT  lpn_id
      BULK COLLECT
      INTO  l_lpn_id_tab
      FROM  WMS_LICENSE_PLATE_NUMBERS
      WHERE lpn_id IN ( SELECT  DISTINCT lpn_id
                        FROM    wms_putaway_group_tasks_gtmp
                        WHERE   row_type = G_ROW_TP_ALL_TASK
                                AND lpn_context <> 3
                      )
      FOR UPDATE NOWAIT;

    l_progress := '120';

    IF (l_debug = 1) THEN
      debug(' End of procedure:' || SQL%rowcount || ' LPN(s) locked ', l_proc_name,1);
    END IF;

    l_progress := '200';

  EXCEPTION
      WHEN no_data_found THEN
        debug(' No LPNs found in the temp table for locking', l_proc_name,1);
        x_return_status  := fnd_api.g_ret_sts_success;

      WHEN record_locked THEN
        debug(' LPN Already locked by someone else', l_proc_name,1);
        x_return_status  := fnd_api.g_ret_sts_error;

        fnd_message.set_name('WMS', 'WMS_LPN_UNAVAIL');
        fnd_msg_pub.ADD;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      WHEN OTHERS THEN
        debug(' Exception while trying to lock LPN(s) ' || SQLERRM, l_proc_name,1);
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

    END Lock_LPNs;


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
  PROCEDURE   Create_Grouped_Tasks(
                x_return_status   OUT  NOCOPY  VARCHAR2
               ,x_msg_count       OUT  NOCOPY  NUMBER
               ,x_msg_data        OUT  NOCOPY  VARCHAR2
               ,p_org_id          IN           NUMBER
               ,p_drop_type       IN           VARCHAR2
               ,p_emp_id          IN           NUMBER
               ,p_lpn_id          IN           NUMBER
               ,p_item_drop_flag  IN           VARCHAR2
               ,p_lpn_is_loaded   IN           VARCHAR2 )
    IS
    l_debug         NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_progress      VARCHAR2(10)  := '10';
    l_proc_name     VARCHAR2(30)  := 'Create_Grouped_Tasks:';
    l_rec_count     NUMBER        := 0;
    l_del_count     NUMBER        := 0;

    l_rowid_tab      rowid_tab;
    l_drop_order_tab num_tab;
    l_lpn_id_tab     num_tab;
    l_lpn_name_tab   lpn_name_tab;
    l_lpn_level_tab  num_tab;
    l_parent_lpn_id  NUMBER;

    -- This cursor will get all the LPNs and their drop_order where drop_type is CD.
    -- This cursor will be used to mark the consolidated LPN of all itz children with the current lpn.
    -- Start with the outermost LPN first and progress towards the childs.

    -- For optimization we are marking the consolidated LPN from top down (order by lpn_level asc)
    -- and hence if consolidated lpn is marked we neednot mark it again for the children (since Mark Consolidated lpn
    -- would have already marked the consolidated lpn to the childs also)
    CURSOR c_lpn_cursor IS
       SELECT DISTINCT
              lpn_id
             ,lpn_name
             ,lpn_level
       FROM   WMS_PUTAWAY_GROUP_TASKS_GTMP
       WHERE  consolidated_lpn_id IS NULL
              AND drop_type = G_DT_CONSOLIDATED_DROP
       ORDER BY lpn_level ASC;


   BEGIN

      IF (l_debug = 1) THEN
         DEBUG(' Procedure Entered at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
         DEBUG(' p_org_id    => '||p_org_id,   l_proc_name,4);
         DEBUG(' p_drop_type => '||p_drop_type,l_proc_name,4);
         DEBUG(' p_emp_id    => '||p_emp_id,   l_proc_name,4);
         DEBUG(' p_lpn_id    => '||p_lpn_id,   l_proc_name,4);
         DEBUG(' p_item_drop_flag    => '||p_item_drop_flag,  l_proc_name,4);
         DEBUG(' p_lpn_is_loaded     => '||p_lpn_is_loaded, l_proc_name,4);
      END IF;

      l_progress := '20';
      x_return_status  := fnd_api.g_ret_sts_success;
      l_progress := '30';

      -- Always delete the existing records in the temp table before creating it.
      -- This code has to be later forked if the grouping logic has to be called for
      -- Restamping the drop type. In that case both delete and populate_group_tasks functions
      -- should not be called.

      BEGIN -- Delete Existing rows in the temp table

        l_progress := '40';
        -- Delete all the rows in the temp table
        l_del_count := Remove_Tasks_In_Group(
                          p_del_type  =>  3
                        );
        l_progress := '50';

        IF l_del_count = -1 THEN
          --Deletion has failed so raise error.
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        l_progress := '60';

      EXCEPTION
        WHEN OTHERS THEN
           RAISE fnd_api.g_exc_unexpected_error;
      END; -- Delete Existing rows in the temp table


      -- Check whether the LPN is already loaded or not.
      -- If already loaded procced with grouping logic,
      -- else call the ATF APIs to simulate the LOAD operation.

      --LPN already loaded check
      IF p_lpn_is_loaded <> 'Y' THEN

          l_progress := '100';
          -- We have to call the ATF APis to simulate the LOAD operation in case of single step drop
          BEGIN -- Simulate LOAAD

	     --BUG 3495726 Issue 25: Unpack from parent LPN first
	     SELECT parent_lpn_id
	       INTO l_parent_lpn_id
	       FROM wms_license_plate_numbers
	       WHERE lpn_id = p_lpn_id;

	     IF (l_parent_lpn_id IS NOT NULL) THEN
	       IF (l_debug = 1) THEN
		  DEBUG(' Unpacking LPN from Parent LPN' ,l_proc_name,9);
	       END IF;
	       wms_container_pvt.packunpack_container
		 (p_api_version       =>   1.0
		  ,p_content_lpn_id    =>  p_lpn_id
		  ,p_lpn_id           =>   l_parent_lpn_id
		  ,p_operation        =>   2 /* Unpack */
		  ,p_organization_id  =>   p_org_id
		  ,x_return_status    =>   x_return_status
		  ,x_msg_count        =>   x_msg_count
		  ,x_msg_data         =>   x_msg_data
		  );
	       IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
		  IF (l_debug = 1) THEN
		     DEBUG(' Error Unpacking LPN from Parent LPN' ,l_proc_name,9);
		  END IF;
		  RAISE fnd_api.g_exc_error;
	       END IF;
	    END IF;

            IF (l_debug = 1) THEN
               DEBUG(' Calling Complete Instance for the LOAD Operation ... ' || x_msg_data ,l_proc_name,9);
            END IF;

            l_progress := '110';
            Complete_ATF_Load (x_return_status  => x_return_status
                              ,x_msg_count      => x_msg_count
                              ,x_msg_data       => x_msg_data
                              ,p_org_id         => p_org_id
                              ,p_lpn_id         => p_lpn_id
                              ,p_emp_id         => p_emp_id );
            l_progress := '120';


            -- Check for the return status
            IF x_return_status = fnd_api.g_ret_sts_success THEN
              -- Activate completed successfully.
              NULL;

            ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;

            ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;

            END IF;

            l_progress := '130';

          EXCEPTION
            WHEN OTHERS THEN
              RAISE fnd_api.g_exc_unexpected_error;
          END; -- Simulate LOAAD

      END IF; --LPN already loaded check




      --Grouping logic
      /*  This procedure is the starting point for groupping logic
       *  This inturn will do the following
       *
       *  1. Populate group tasks with the required data
       *  2. Order the temp  table and stamp the drop_order
       *  3. Resolve the columns like parent_lpn_id, outermost_lpn_id and LPN_NAME etc.,
       *  4. Group the tasks
      */

      IF (l_debug = 1) THEN
        DEBUG(' Before calling pvt function Populate_group_tasks ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,9);
        DEBUG(' p_org_id    => '||p_org_id,   l_proc_name,4);
        DEBUG(' p_drop_type => '||p_drop_type,l_proc_name,4);
        DEBUG(' p_emp_id    => '||p_emp_id,   l_proc_name,4);
        DEBUG(' p_lpn_id    => '||p_lpn_id,   l_proc_name,4);
      END IF;

      --Calling Populate_group_tasks to populate the global temp table
      l_progress := '200';
      l_rec_count := Populate_group_tasks( p_org_id         => p_org_id
                                          ,p_drop_type      => p_drop_type
                                          ,p_emp_id         => p_emp_id
                                          ,p_lpn_id         => p_lpn_id
                                          ,p_item_drop_flag => p_item_drop_flag
                                         );
      l_progress := '210';

      IF (l_debug = 1) THEN
        DEBUG(' After calling pvt function Populate_group_tasks ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,9);
        DEBUG(' l_rec_count => '|| l_rec_count,l_proc_name,4);
      END IF;

      -- Record count take the following values after calling Populate_group_tasks
      -- -1  --> In case of failure
      --  0  --> No rows found
      --  >1 --> In case of success.

      -- Error out since it is failure case
      IF l_rec_count = -1 THEN
        l_progress := '220';
        RAISE fnd_api.g_exc_error;
      END IF;

      -- No tasks available. Set the message and display it in the UI
      IF l_rec_count = 0 THEN
          l_progress := '225';
          -- No Tasks found for the data passed
          -- Set error message and raise error handle it in exception block.
          FND_MESSAGE.SET_NAME('WMS','WMS_NO_TASKS');
          fnd_msg_pub.ADD;
          -- Instead of raising an error, return with success
          RETURN;
      END IF;


      --Call ATF API for stamping the dest sub/loc/LPN
      BEGIN --ATF Call to Activate

        l_progress := '250';
        l_rec_count := Activate_Plan_For_Drop (x_return_status => x_return_status
                                              ,x_msg_count     => x_msg_count
                                              ,x_msg_data      => x_msg_data );
        l_progress := '260';


        -- Check for the return status
        IF x_return_status = fnd_api.g_ret_sts_success THEN
          -- Activate completed successfully.
          NULL;

        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;

        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;

        ELSIF l_rec_count = -1 THEN
          RAISE fnd_api.g_exc_unexpected_error;

        END IF;


      EXCEPTION
        WHEN OTHERS THEN
          RAISE fnd_api.g_exc_unexpected_error;

      END; --ATF Call to Activate

       -- Core Grouping logic
         -- call the grouping function for consolidating drop
         -- call the API for stamping the consolidated lpn
         -- call the grouping function for grouping the MMTTs for item drop
         -- call the function to insert group tasks rows

       -- Call the function which will populate the drop type correctly and
       -- group the tasks

      --IF p_item_drop_flag <> 'Y' THEN --p_item_drop_flag check
         BEGIN  --Populating the drop type

            l_progress := '300';

            IF (l_debug = 1) THEN
              DEBUG(' Before calling pvt function Populate_Drop_type ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,9);
            END IF;

            -- This function call will group the tasks and populate the drop type correctly
            -- After this function call, the temp table will have the tasks grouped correctly.
            l_progress := '310';
            l_rec_count := Populate_Drop_Type;
            l_progress := '320';

            IF (l_debug = 1) THEN
              DEBUG(' After calling pvt function Populate_Drop_type ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,9);
            END IF;

            IF l_rec_count = -1 THEN -- l_rec_count check
              l_progress := '330';
              IF (l_debug = 1) THEN
                DEBUG('Populate_Drop_type returned error and hence raising exception ',l_proc_name,1);
              END IF;

              l_progress := '340';
              RAISE fnd_api.g_exc_error;
            END IF; -- l_rec_count check

            l_progress := '350';
         EXCEPTION
           WHEN OTHERS THEN
              RAISE fnd_api.g_exc_unexpected_error;
         END;--Populating the drop type

--      END IF; --p_item_drop_flag check


        -- Call the function which will mark the consolidated LPN and the drop_order
        -- This function will be called only for those LPNs which have drop_type as 'CD'
        BEGIN  -- Mark Consolidated LPN

           l_progress := '400';
           OPEN c_lpn_cursor;
           l_progress := '410';

           LOOP -- c_lpn_cursor

             --BUG 5187983: Requery c_lpn_cursor everytime
             --so that it will won't pick up the same lines
             --already marked by Mark_Consolidated_LPN
             l_lpn_id_tab.delete;
             l_lpn_name_tab.delete;
             l_lpn_level_tab.delete;

             FETCH   c_lpn_cursor
               INTO  l_lpn_id_tab(1)
                    ,l_lpn_name_tab(1)
                    ,l_lpn_level_tab(1);

             EXIT WHEN c_lpn_cursor%NOTFOUND;
             l_progress := '405';

             CLOSE c_lpn_cursor;

             IF (l_debug = 1) Then
                DEBUG('COUNT:'||l_lpn_id_tab.COUNT,l_proc_name,9);
                DEBUG('LPN_ID:'||l_lpn_id_tab(1));
                DEBUG('LPN_NAME:'||l_lpn_name_tab(1));
                DEBUG('LPN_LEVEL:'||l_lpn_level_tab(1));
             END IF;

             l_progress := '460';

             IF (l_debug = 1) THEN
               DEBUG(' Before calling pvt function Mark_Consolidated_LPN ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,9);
             END IF;

             -- This function call will group the tasks and populate the drop type correctly
             -- After this function call, the temp table will have the tasks grouped correctly.
             l_progress := '470';
             l_rec_count := Mark_Consolidated_LPN( p_lpn_id     => l_lpn_id_tab(1)
                                                  ,p_lpn_name   => l_lpn_name_tab(1)
                                                 );
             l_progress := '480';

             IF (l_debug = 1) THEN
                DEBUG(' After calling pvt function Mark_Consolidated_LPN ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,9);
             END IF;

             l_progress := '490';

             IF l_rec_count = -1 THEN -- l_rec_count check
                l_progress := '500';
                IF (l_debug = 1) THEN
                   DEBUG('Mark_Consolidated_LPN returned error and hence raising exception ',l_proc_name,1);
                END IF;

                l_progress := '510';
                RAISE fnd_api.g_exc_error;
             END IF; -- l_rec_count check

             OPEN c_lpn_cursor;
             -- END BUG 5187983
           END LOOP; -- c_lpn_cursor

           l_progress := '520';
           CLOSE c_lpn_cursor;
           l_progress := '525';


        EXCEPTION
          WHEN OTHERS THEN
             RAISE fnd_api.g_exc_unexpected_error;
        END;-- Mark Consolidated LPN


        BEGIN --Group_Item_Drop_Tasks

            -- Calling the method to insert the consolidate group tasks
            l_rec_count := Group_Item_Drop_Tasks;
            l_progress := '620';

            IF l_rec_count = -1 THEN -- l_rec_count check
              l_progress := '630';
              IF (l_debug = 1) THEN
                DEBUG('Group_Item_Drop_Tasks returned error and hence raising exception ',l_proc_name,1);
              END IF;

              l_progress := '640';
              RAISE fnd_api.g_exc_error;
            END IF; -- l_rec_count check

            l_progress := '650';

        EXCEPTION
          WHEN OTHERS THEN
             RAISE fnd_api.g_exc_unexpected_error;
        END;--Group_Item_Drop_Tasks



        BEGIN --Group_Consolidated_Drop_Tasks

            -- Calling the method to insert the consolidate group tasks
            l_rec_count := Group_Consolidated_Drop_Tasks;
            l_progress := '720';

            IF l_rec_count = -1 THEN -- l_rec_count check
              l_progress := '730';
              IF (l_debug = 1) THEN
                DEBUG('Group_Consolidated_Drop_Tasks returned error and hence raising exception ',l_proc_name,1);
              END IF;

              l_progress := '740';
              RAISE fnd_api.g_exc_error;
            END IF; -- l_rec_count check

            l_progress := '750';

        EXCEPTION
          WHEN OTHERS THEN
             RAISE fnd_api.g_exc_unexpected_error;
        END;--Group_Consolidated_Drop_Tasks


        BEGIN --Sync_Group_Tasks

            -- Calling the method to insert common transaction_header_id and group_id for a group
            l_rec_count := Sync_Group_Tasks;
            l_progress := '820';

            IF l_rec_count = -1 THEN -- l_rec_count check
              l_progress := '830';
              IF (l_debug = 1) THEN
                DEBUG('Sync_Group_Tasks returned error and hence raising exception ',l_proc_name,1);
              END IF;

              l_progress := '840';
              RAISE fnd_api.g_exc_error;
            END IF; -- l_rec_count check

            l_progress := '850';

        EXCEPTION
          WHEN OTHERS THEN
             RAISE fnd_api.g_exc_unexpected_error;
        END;--Sync_Group_Tasks


      -- Done with the grouping logic, so go ahead and delete the dummy rows
      BEGIN --Delete dummy rows

        l_progress := '940';
        -- Delete all the rows in the temp table
        l_del_count := Remove_Tasks_In_Group(
                          p_del_type  =>  2
                        );
        l_progress := '950';

      EXCEPTION
        WHEN OTHERS THEN
           NULL;
      END; --Delete dummy rows

      l_progress := '960';
      -- Building the temp table is successful.. go ahead and commit the changes
      COMMIT;
      l_progress := '965';

    -- Lock all the LPNs the user is currently working on
	 -- We are re-locking again since the commit above would have relieved the lock.
	 Lock_LPNs( x_return_status  => x_return_status
		    ,x_msg_count      => x_msg_count
		    ,x_msg_data       => x_msg_data );

	 l_progress := '970';

	 IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       DEBUG(' Error in locking LPNs ' || x_msg_data ,l_proc_name,1);
	    END IF;

	    l_progress := '980';
	    RAISE fnd_api.g_exc_error;
	 END IF;


	 IF (l_debug = 1) THEN
	    DEBUG(' x_return_status => '|| x_return_status,l_proc_name,4);
	    DEBUG(' x_msg_count     => '|| x_msg_count,l_proc_name,4);
	    DEBUG(' x_msg_data      => '|| x_msg_data,l_proc_name,4);
	    DEBUG(' Procedure Exited at ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
	 END IF;

      l_progress := '1000';

   EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       x_return_status  := fnd_api.g_ret_sts_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_lpn_cursor%isopen THEN
         CLOSE c_lpn_cursor;
       END IF;

     WHEN fnd_api.g_exc_unexpected_error THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_lpn_cursor%isopen THEN
         CLOSE c_lpn_cursor;
       END IF;


     WHEN OTHERS THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_lpn_cursor%isopen THEN
         CLOSE c_lpn_cursor;
       END IF;


   END Create_grouped_tasks; -- Procedure Create_grouped_tasks


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
             ) IS
     l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress  VARCHAR2(10) := '10';
     l_rec_count NUMBER       := 0;
     l_proc_name VARCHAR2(30) := 'ATF_For_Manual_Drop:';

     l_error_code         NUMBER;
     l_tempid_tab         num_tab;
     l_task_rec           task_rec   := NULL;

     l_consolidation_method_id NUMBER;
     l_drop_lpn_option NUMBER;

     -- This cursor will get the MMTTs assoicated with the contents of the LPN passed
     -- along with the MMTTs of the contents of all its child LPNs also.
      --Bug5723418.Performance fix.Moved wlpn to FROM clause.
      -- Performane fix as a part of bug 7143123
     CURSOR c_all_mmtt_cursor IS
       SELECT /*+ ORDERED USE_NL(WLPN MTRL MMTT) INDEX(MTRL MTL_TXN_REQUEST_LINES_N7) */
		MMTT.TRANSACTION_TEMP_ID
	FROM
	      ( SELECT LPN_ID
		FROM WMS_LICENSE_PLATE_NUMBERS START WITH LPN_ID = p_lpn_id CONNECT BY PRIOR LPN_ID = PARENT_LPN_ID ) WLPN,
	      MTL_TXN_REQUEST_LINES MTRL,
	      MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
	WHERE MTRL.LINE_ID = MMTT.MOVE_ORDER_LINE_ID
	  AND LINE_STATUS = 7
	  AND MTRL.LPN_ID = WLPN.LPN_ID ;


   BEGIN

     IF (l_debug = 1) THEN
        DEBUG('Start of function ' || l_proc_name ,l_proc_name,9);
     END IF;

     -- Set the return status to success.
     l_progress := '20';
     x_return_status  := fnd_api.g_ret_sts_success;
     l_progress := '30';

     -- Setting the values for the task record
     -- Thought this is for Drop, The existing WDTs if any for load would have been deleted
     -- and hence these records has to be created afresh.
     l_task_rec.person_id       := p_emp_id;
     l_task_rec.organization_id := p_org_id;
     l_task_rec.user_task_type  := -1;


     l_progress := '100';
     OPEN c_all_mmtt_cursor;
     l_progress := '110';

     LOOP -- c_all_tasks_cursor loop

       EXIT WHEN c_all_mmtt_cursor%NOTFOUND;
       l_progress := '200';

       FETCH c_all_mmtt_cursor
         BULK COLLECT
          INTO l_tempid_tab
         LIMIT l_limit;
       l_progress := '210';

       l_rec_count := l_rec_count + l_tempid_tab.COUNT;
       l_progress := '220';

       -- Activate each MMTT's
       FOR i IN 1 .. l_tempid_tab.COUNT
       LOOP --All temp ids loop

         -- Check the mode for which the integration API is called
         IF p_call_type = G_ATF_ABORT_PLAN THEN

          IF (l_debug = 1) THEN
             DEBUG('Calling abort_operation_instance with ...',l_proc_name,9);
             DEBUG('p_source_task_id    => ' || l_tempid_tab(i),l_proc_name,9);
             DEBUG('p_activity_type_id  => ' || G_OP_ACTIVITY_INBOUND,l_proc_name,9);
          END IF;
          l_progress := '300';

	  --BUG 3666138: Pass in 1 more parameter, p_for_manual_drop, so
	  --that ATF would call revert_loc_sugg_capacity with an
	  --autonomous commit
          wms_atf_runtime_pub_apis.Abort_Operation_Plan
             (  p_source_task_id    => l_tempid_tab(i)
               ,p_activity_type_id  => G_OP_ACTIVITY_INBOUND
               ,x_return_status     => x_return_status
               ,x_msg_data          => x_msg_data
               ,x_msg_count         => x_msg_count
	       ,x_error_code        => l_error_code
	       ,p_for_manual_drop   => true
             );

          l_progress := '310';

          IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
             IF (l_debug = 1) THEN
                DEBUG(l_error_code || ' Error in abort_operation_instance ' ,l_proc_name,1);
             END IF;
             l_progress := '320';

             RAISE fnd_api.g_exc_error;
          END IF;

	 ELSIF p_call_type = g_atf_cancel_plan THEN
            IF (l_debug = 1) THEN
               DEBUG('Calling cancel_operation_plan with ...',l_proc_name,9);
               DEBUG('p_source_task_id    => ' || l_tempid_tab(i),l_proc_name,9);
               DEBUG('p_activity_type_id  => ' || G_OP_ACTIVITY_INBOUND,l_proc_name,9);
            END IF;
            l_progress := '330';

            wms_atf_runtime_pub_apis.cancel_operation_plan
               (  p_source_task_id    => l_tempid_tab(i)
                 ,p_activity_type_id  => G_OP_ACTIVITY_INBOUND
                 ,x_return_status     => x_return_status
                 ,x_msg_data          => x_msg_data
                 ,x_msg_count         => x_msg_count
                 ,x_error_code        => l_error_code
		  );
            l_progress := '340';

            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
               IF (l_debug = 1) THEN
                  DEBUG(l_error_code || ' Error in cancel_operation_plan ' ,l_proc_name,1);
               END IF;
               l_progress := '350';

               RAISE fnd_api.g_exc_error;
            END IF;
         ELSIF p_call_type = G_ATF_ACTIVATE_PLAN  THEN
            IF (l_debug = 1) THEN
               DEBUG('Calling activate_operation_instance with ...',l_proc_name,9);
               DEBUG('p_source_task_id    => ' || l_tempid_tab(i),l_proc_name,9);
               DEBUG('p_activity_type_id  => ' || G_OP_ACTIVITY_INBOUND,l_proc_name,9);
               DEBUG('p_task_execute_rec  => l_task_rec',l_proc_name,9);
               DEBUG('p_operation_type_id => ' || G_OP_TYPE_DROP,l_proc_name,9);
            END IF;
            l_progress := '330';

            wms_atf_runtime_pub_apis.activate_operation_instance
               (  p_source_task_id    => l_tempid_tab(i)
                 ,p_activity_id       => G_OP_ACTIVITY_INBOUND
                 ,p_task_execute_rec  => l_task_rec
                 ,p_operation_type_id => G_OP_TYPE_DROP
                 ,x_return_status     => x_return_status
                 ,x_msg_data          => x_msg_data
                 ,x_msg_count         => x_msg_count
                 ,x_error_code        => l_error_code
		 ,x_consolidation_method_id => l_consolidation_method_id
		 ,x_drop_lpn_option   => l_drop_lpn_option
		  );
            l_progress := '340';

            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
               IF (l_debug = 1) THEN
                  DEBUG(l_error_code || ' Error in activate_operation_instance ' ,l_proc_name,1);
               END IF;
               l_progress := '350';

               RAISE fnd_api.g_exc_error;
            END IF;

         ELSE
           -- Invalid value for mode, return error
           RAISE fnd_api.g_exc_error;

         END IF; -- Check the mode for which the integration API is called


       END LOOP; --All temp ids loop

     END LOOP; -- c_all_tasks_cursor loop

     -- Close all the open cursors if any.
     IF c_all_mmtt_cursor%ISOPEN THEN
       l_progress := '500';
       CLOSE c_all_mmtt_cursor;
     END IF;


   EXCEPTION

     WHEN fnd_api.g_exc_error THEN
       x_return_status  := fnd_api.g_ret_sts_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_all_mmtt_cursor%isopen THEN
         CLOSE c_all_mmtt_cursor;
       END IF;

     WHEN fnd_api.g_exc_unexpected_error THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_all_mmtt_cursor%isopen THEN
         CLOSE c_all_mmtt_cursor;
       END IF;


     WHEN OTHERS THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_all_mmtt_cursor%isopen THEN
         CLOSE c_all_mmtt_cursor;
       END IF;

   END ATF_For_Manual_Drop;



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
     RETURN NUMBER
     IS

     l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress  VARCHAR2(10) := '10';
     l_rec_count NUMBER       := 0;
     l_proc_name VARCHAR2(30) := 'Activate_Plan_For_Inspect:';

     l_error_code    NUMBER;
     l_task_rec      task_rec   := NULL;
     l_tempid_tab    num_tab;
     l_user_id       NUMBER   := fnd_global.user_id;
     l_emp_id        NUMBER;

     l_consolidation_method_id NUMBER;
     l_drop_lpn_option NUMBER;

     -- This cursor will get the MMTTs assoicated with the move order line passed
     CURSOR c_mol_mmtt_cursor IS
       SELECT mmtt.transaction_temp_id
       FROM   mtl_material_transactions_temp mmtt
             ,mtl_txn_request_lines mtrl
       WHERE mtrl.line_id = mmtt.move_order_line_id
             AND mtrl.line_id = p_mo_line_id
             AND mtrl.line_status = 7
             AND mtrl.organization_id = p_org_id;

   BEGIN

     IF (l_debug = 1) THEN
        DEBUG('Start of function ' || l_proc_name ,l_proc_name,9);
        DEBUG('  p_org_id     ==> '|| p_org_id,l_proc_name,4);
        DEBUG('  p_mo_line_id ==> '|| p_mo_line_id,l_proc_name,4);
     END IF;

     -- Set the return status to success.
     l_progress := '20';
     x_return_status  := fnd_api.g_ret_sts_success;
     l_progress := '30';

    -- Get the employee ID so we can populate
    -- the person_id column in WDT properly.
    BEGIN -- Get the employee id

      l_progress := '30';
      SELECT NVL(employee_id, -1)
      INTO   l_emp_id
      FROM   fnd_user
      WHERE  user_id = l_user_id;
      l_progress := '40';

      IF (l_debug = 1) THEN
         DEBUG(' Got the employee id =  '|| l_emp_id || ' for the user ' || l_user_id,l_proc_name,9);
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DEBUG('Couldnot get the employee id and hence setting it to null ' ,l_proc_name,1);
        l_emp_id := NULL;
        l_progress := '50';

    END; -- Get the employee id
    l_progress := '60';


     -- Setting the values for the task record
     -- Neednot set these values for drop since there ia already WDT,
     -- ATF will just change the status of this WDT record
     l_task_rec.person_id       := l_emp_id;
     l_task_rec.organization_id := p_org_id;
     l_task_rec.user_task_type  := -1;

     l_progress := '100';
     OPEN c_mol_mmtt_cursor;
     l_progress := '110';

     LOOP -- c_all_mmtt_cursor loop

       EXIT WHEN c_mol_mmtt_cursor%NOTFOUND;
       l_progress := '200';

       FETCH c_mol_mmtt_cursor
         BULK COLLECT
          INTO l_tempid_tab
         LIMIT l_limit;
       l_progress := '210';

       l_rec_count := l_rec_count + l_tempid_tab.COUNT;
       l_progress := '220';

       -- Activate each MMTT's
       FOR i IN 1 .. l_tempid_tab.COUNT
       LOOP --All temp ids loop

            IF (l_debug = 1) THEN
               DEBUG('Calling activate_operation_instance with ...',l_proc_name,9);
               DEBUG('p_source_task_id    => ' || l_tempid_tab(i),l_proc_name,9);
               DEBUG('p_activity_type_id  => ' || G_OP_ACTIVITY_INBOUND,l_proc_name,9);
               DEBUG('p_task_execute_rec  => l_task_rec',l_proc_name,9);
               DEBUG('p_operation_type_id => ' || G_OP_TYPE_DROP,l_proc_name,9);
            END IF;
          l_progress := '300';

            wms_atf_runtime_pub_apis.activate_operation_instance
               (  p_source_task_id    => l_tempid_tab(i)
                 ,p_activity_id       => G_OP_ACTIVITY_INBOUND
                 ,p_task_execute_rec  => l_task_rec
                 ,p_operation_type_id => G_OP_TYPE_INSPECT
                 ,x_return_status     => x_return_status
                 ,x_msg_data          => x_msg_data
                 ,x_msg_count         => x_msg_count
                 ,x_error_code        => l_error_code
		 ,x_consolidation_method_id => l_consolidation_method_id
		 ,x_drop_lpn_option   => l_drop_lpn_option
               );
          l_progress := '310';

            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
               IF (l_debug = 1) THEN
                  DEBUG(l_error_code || ' Error in activate_operation_instance ' ,l_proc_name,1);
               END IF;
             l_progress := '320';

               RAISE fnd_api.g_exc_error;
            END IF;

       END LOOP; --All temp ids loop

     END LOOP; -- c_all_mmtt_cursor loop


     IF c_mol_mmtt_cursor%ISOPEN THEN
       CLOSE c_mol_mmtt_cursor;
     END IF;

     l_progress := '990';
     --Return the count of rows processed
     RETURN l_rec_count;

   EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       x_return_status  := fnd_api.g_ret_sts_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_mol_mmtt_cursor%ISOPEN THEN
         CLOSE c_mol_mmtt_cursor;
       END IF;

       RETURN -1;


     WHEN fnd_api.g_exc_unexpected_error THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_mol_mmtt_cursor%ISOPEN THEN
         CLOSE c_mol_mmtt_cursor;
       END IF;

       RETURN -1;


     WHEN OTHERS THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_mol_mmtt_cursor%ISOPEN THEN
         CLOSE c_mol_mmtt_cursor;
       END IF;

       RETURN -1;

   END Activate_Plan_For_Inspect;


/**
  *   This function will call the ATF API to cleanup / rollback
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
  *   4             G_CT_INSPECT_TM_FAILED  Called from Inspect when it is after tm failure
  *   5             G_CT_INSPECT_B4_TM      Called from Inspect when it is before calling TM
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
         ,p_lpn_id        IN           NUMBER
         ,p_group_id      IN           NUMBER
	 ,p_parent_lpn_id IN           NUMBER
	 ,p_drop_all      IN           VARCHAR2 --BUG 5075410
	 ,p_emp_id        IN           NUMBER)  --BUG 5075410
     IS
     l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress  VARCHAR2(10) := '10';
     l_rec_count NUMBER       := 0;
     l_proc_name VARCHAR2(30) := 'Cleanup_ATF:';

     l_error_code    NUMBER;
     l_tempid_tab    num_tab;

     l_op_plan_id       NUMBER;
     l_lpn_context      NUMBER;
	 l_lpn_cxt          NUMBER;
	 l_parent_lpn_cxt   NUMBER;
     l_mmtt_item_id     NUMBER;
     l_mmtt_uom         VARCHAR2(3);
     l_mmtt_qty         NUMBER;
     l_mol_id           NUMBER;
     l_mol_uom          VARCHAR2(3);
     l_mmtt_qty_mol_uom NUMBER;
     l_wms_process_flag NUMBER;
     l_outermost_lpn_id NUMBER;

     -- This cursor will get the all the MMTTs assoicated with the lpn_id passed.
     -- Cleanup shouldn't be called if there is not WDT and hence added a join with WDT.
     CURSOR c_mol_mmtt_cursor IS
       SELECT mmtt.transaction_temp_id
       FROM   mtl_material_transactions_temp mmtt
             ,mtl_txn_request_lines mtrl
             ,wms_dispatched_tasks wdt
	     ,(SELECT lpn_id     FROM   wms_license_plate_numbers   /*Bug5723418.*/
                                 START  WITH lpn_id = p_lpn_id
                                 CONNECT BY PRIOR lpn_id = parent_lpn_id
                                ) wlpn
       WHERE wdt.transaction_temp_id = mmtt.transaction_temp_id
	 --  BUG 5075410: WDT MOL is not being kept in sync when split.
	 --  Querying through WDT->MMTT->MTRL should be enough
	 --  AND wdt.move_order_line_id = mtrl.line_id
             AND mtrl.line_id = mmtt.move_order_line_id
             AND mtrl.line_status = 7
             AND mtrl.organization_id = p_org_id
             AND mtrl.lpn_id = wlpn.lpn_id;


     -- This cursor will get the MMTTs assoicated with the group_id passed from the temp table
     CURSOR c_tmp_mmtt_cursor IS
       SELECT transaction_temp_id
       FROM   wms_putaway_group_tasks_gtmp
       WHERE  group_id = p_group_id
	 AND row_type = G_ROW_TP_ALL_TASK;

     --BUG 5075410: The c_all_mmtt_cursor is used in the following scenarios:
     --1) When user finishes all tasks (p_group_id = -2), system only needs
     --   to cleanup the tasks split when User performed partial. So join
     --   on task_type/wms_process_flag/transaction_status so that the txn
     --   submitted from transaction is picked up
     --2) When user presses F2 (p_group_id = -1)
     --3) When user encounter an error, and he decides to quit all tasks
     --   (p_group_id = -1).  In this cursor, select all the tasks that
     --   have drop active op plan or tasks that have wdt status 4 (loaded).
     CURSOR c_all_mmtt_cursor IS
	SELECT mmtt.transaction_temp_id
	  FROM wms_dispatched_tasks     wdt
	  ,mtl_txn_request_lines    mtrl
	  ,mtl_material_transactions_temp mmtt
	  ,mtl_txn_request_headers  mtrh
	  WHERE  mtrh.header_id = mtrl.header_id
	  AND mtrh.move_order_type = 6
	  AND mtrl.line_status = 7
	  AND wdt.transaction_temp_id = mmtt.transaction_temp_id
	  AND mmtt.move_order_line_id = mtrl.line_id
	  AND ((p_group_id = -2
		AND Nvl(mtrl.wms_process_flag,1) <> 2   --RCV would set this to 2 for mol being processed
		AND Nvl(mmtt.wms_task_type,2) <> -1     --RCV would set this to -1 for MMTT being processed
		AND Nvl(mmtt.transaction_status,2) <> 3 --WIP would set this to 3 for MMTT being processed
		) OR
	       (p_group_id = -1))
	  AND wdt.STATUS = 4
	  AND wdt.task_type = 2
	  AND mtrl.lpn_id IN (SELECT lpn_id
			      FROM   wms_license_plate_numbers
			      START  WITH lpn_id = l_outermost_lpn_id
			      CONNECT BY PRIOR lpn_id = parent_lpn_id
			      )
	  AND ((mmtt.operation_plan_id IS NOT NULL
		AND exists (SELECT 1
			    FROM   wms_op_operation_instances wooi
			    WHERE  wooi.source_task_id = mmtt.transaction_temp_id
			    AND    wooi.operation_status = 2
			    AND    wooi.operation_type_id = 2))
	       OR
	       (mmtt.operation_plan_id IS NULL))
	  AND p_drop_all <> 'Y'
     UNION ALL
       SELECT mmtt.transaction_temp_id
	  FROM wms_dispatched_tasks     wdt
	  ,mtl_txn_request_lines    mtrl
	  ,mtl_material_transactions_temp mmtt
	  ,mtl_txn_request_headers  mtrh
	  WHERE  mtrh.header_id = mtrl.header_id
	  AND mtrh.move_order_type = 6
	  AND mtrl.line_status = 7
	  AND wdt.transaction_temp_id = mmtt.transaction_temp_id
	  AND mmtt.move_order_line_id = mtrl.line_id
	  AND ((p_group_id = -2
		AND Nvl(mtrl.wms_process_flag,1) <> 2   --RCV would set this to 2 for mol being processed
		AND Nvl(mmtt.wms_task_type,2) <> -1     --RCV would set this to -1 for MMTT being processed
		AND Nvl(mmtt.transaction_status,2) <> 3 --WIP would set this to 3 for MMTT being processed
		) OR
	       (p_group_id = -1))
	  AND wdt.task_type = 2
	  AND wdt.STATUS = 4
	  AND wdt.person_id = p_emp_id
	  AND ((mmtt.operation_plan_id IS NOT NULL
		AND exists (SELECT 1
			    FROM   wms_op_operation_instances wooi
			    WHERE  wooi.source_task_id = mmtt.transaction_temp_id
			    AND    wooi.operation_status = 2
			    AND    wooi.operation_type_id = 2))
	       OR
	       (mmtt.operation_plan_id IS NULL))
          AND p_drop_all = 'Y';

   BEGIN

      --Part of bugfix 4114695 - should initialize this variable so that
      --calls from java aren't mislead to think this failed when indeed
      --it was a clean exit.  Upon EXCEPTION, this flag is changedw
     x_return_status := fnd_api.g_ret_sts_success;

     IF (l_debug = 1) THEN
        DEBUG('Start of function ' || l_proc_name ,l_proc_name,9);
        DEBUG('  p_call_type ==> '|| p_call_type,l_proc_name,4);
        DEBUG('  p_lpn_id    ==> '|| p_lpn_id,l_proc_name,4);
        DEBUG('  p_group_id  ==> '|| p_group_id,l_proc_name,4);
        DEBUG('  p_parent_lpn_id  ==> '|| p_parent_lpn_id,l_proc_name,4);
        DEBUG('  p_drop_all       ==> '|| p_drop_all,l_proc_name,4);
        DEBUG('  p_emp_id         ==> '|| p_emp_id,l_proc_name,4);
     END IF;


     -- Check which cursor to open
     IF p_group_id IS NOT NULL THEN
       -- user has passed group id hence fetch from the temp table
       l_progress := '100';

       IF (p_group_id in (-1,-2)) THEN
	  BEGIN
	     SELECT outermost_lpn_id
	       ,    lpn_context
	       INTO l_outermost_lpn_id
	       ,    l_lpn_context
	       FROM wms_license_plate_numbers
	       WHERE lpn_id = p_lpn_id;
	  EXCEPTION
	     WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		   DEBUG('Error querying WLPN. SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_proc_name,9);
		END IF;
		RAISE fnd_api.g_exc_error;
	  END;

	  IF (l_debug = 1) THEN
	     DEBUG('Outermost LPN_ID:'||l_outermost_lpn_id,l_proc_name,9);
	  END IF;

	  OPEN c_all_mmtt_cursor;
	ELSE
	  OPEN c_tmp_mmtt_cursor;
       END IF;

       l_progress := '110';

       IF (p_group_id IN (-1,-2)) THEN
	  FETCH c_all_mmtt_cursor
	    BULK COLLECT
	    INTO l_tempid_tab;
	ELSE
	  FETCH c_tmp_mmtt_cursor
	    BULK COLLECT
	    INTO l_tempid_tab;
       END IF;

       l_progress := '120';

       IF (p_group_id IN (-1,-2)) THEN
	  CLOSE c_all_mmtt_cursor;
	ELSE
	  CLOSE c_tmp_mmtt_cursor;
       END IF;

       l_progress := '130';

       l_rec_count := l_tempid_tab.COUNT;
       l_progress := '140';

     ELSIF p_lpn_id IS NOT NULL THEN
       -- user has not passed the group id but passed the lpn id hence fetch from MMTT/MTRL

       l_progress := '200';
       OPEN c_mol_mmtt_cursor;
       l_progress := '210';

       FETCH c_mol_mmtt_cursor
         BULK COLLECT
          INTO l_tempid_tab;
       l_progress := '220';

       CLOSE c_mol_mmtt_cursor;
       l_progress := '230';

       l_rec_count := l_tempid_tab.COUNT;
       l_progress := '240';

     ELSE
       -- Invalid inputs passed hence error out
       l_progress := '299';
       RAISE fnd_api.g_exc_error;

     END IF; -- Check which cursor to open


     IF p_call_type = G_CT_SINGLE_STEP_DROP THEN
       -- Single step drop hence we have to call Rollback_operation_plan

	-- For single step drop, if the LPN is originally nested inside
	-- another LPN, during simulation of load, it will get unpacked
	-- from the outer LPN.  So we must pack it back during the cleanup
	-- here.
	/* Start bug 9295496 */
	BEGIN

     SELECT lpn_context
     INTO   l_lpn_cxt
     FROM   wms_license_plate_numbers
     WHERE  lpn_id=  p_lpn_id ;

     IF p_parent_lpn_id is not null THEN
	 SELECT lpn_context
     INTO   l_parent_lpn_cxt
     FROM   wms_license_plate_numbers
     WHERE  lpn_id= p_parent_lpn_id  ;
	 END IF;

     EXCEPTION
     WHEN OTHERS THEN
     DEBUG('In exception block while fetching lpn_context:l_parent_lpn_cxt ' || Nvl(l_parent_lpn_cxt, -999) ||
		   ' l_lpn_cxt ' || Nvl(l_lpn_cxt, -999), l_proc_name,9);
     END;
	 /* End bug 9295496 */

	IF (Nvl(p_parent_lpn_id, 0) <> 0 AND Nvl(p_lpn_id, 0) <> 0 AND nvl(l_lpn_cxt,0)=nvl(l_parent_lpn_cxt,0) ) THEN  -- bug 9295496 added condition
	  IF (l_debug = 1) THEN
	     DEBUG('Packing LPN ' || Nvl(p_lpn_id, -999) ||
		   ' into Parent LPN ' || Nvl(p_parent_lpn_id, -999), l_proc_name,9);
	  END IF;

	  wms_container_pvt.packunpack_container
	    (p_api_version       =>   1.0
	     ,p_content_lpn_id   =>   p_lpn_id
	     ,p_lpn_id           =>   p_parent_lpn_id
	     ,p_operation        =>   1 -- Pack
	     ,p_organization_id  =>   p_org_id
	     ,x_return_status    =>   x_return_status
	     ,x_msg_count        =>   x_msg_count
	     ,x_msg_data         =>   x_msg_data
	     );
	  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	     IF (l_debug = 1) THEN
		DEBUG('Error packing LPN into original parent...', l_proc_name,9);
	     END IF;
	     RAISE fnd_api.g_exc_error;
	  END IF;
       END IF;

       l_lpn_context := NULL;

       -- All MMTTs loop
       FOR i IN 1..l_tempid_tab.COUNT
       LOOP

           IF (l_debug = 1) THEN
              DEBUG('Calling Rollback_operation_plan with ...',l_proc_name,9);
              DEBUG('p_source_task_id    => ' || l_tempid_tab(i),l_proc_name,9);
              DEBUG('p_activity_type_id  => ' || G_OP_ACTIVITY_INBOUND,l_proc_name,9);
           END IF;
            l_progress := '300';

           wms_atf_runtime_pub_apis.Rollback_operation_plan
              (  p_source_task_id    => l_tempid_tab(i)
                ,p_activity_type_id  => G_OP_ACTIVITY_INBOUND
                ,x_return_status     => x_return_status
                ,x_msg_data          => x_msg_data
                ,x_msg_count         => x_msg_count
                ,x_error_code        => l_error_code
              );
           l_progress := '310';

           IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                 DEBUG(l_error_code || ' Error in Rollback_operation_plan ' ,l_proc_name,1);
              END IF;
              l_progress := '320';
              x_return_status  := fnd_api.g_ret_sts_error;
              /* Don't raise error in case of failure, instead set the ret status as error
                 and proceed with the next record */
              --RAISE fnd_api.g_exc_error;
           END IF;

	    --Bug 5075410: If the cleanup is called
	    --for a single step drop for an inventory lpn and there is
	    --no operation plan associated with the lpn then, we should
	    --delete the task and close the MOL.

	    IF (l_debug = 1) THEN
	       debug('Inside the begin, before selection from mmtt',l_proc_name,1);
	    END IF;

	    BEGIN
	       SELECT mmtt.operation_plan_id
		 ,    mmtt.transaction_uom
		 ,    mmtt.transaction_quantity
		 ,    mmtt.move_order_line_id
		 ,    mmtt.inventory_item_id
		 ,    mtrl.uom_code
		 ,    mtrl.wms_process_flag
		 INTO l_op_plan_id
		 ,    l_mmtt_uom
		 ,    l_mmtt_qty
		 ,    l_mol_id
		 ,    l_mmtt_item_id
		 ,    l_mol_uom
		 ,    l_wms_process_flag
		 FROM mtl_material_transactions_temp mmtt
		 ,    mtl_txn_request_lines mtrl
		 WHERE mmtt.transaction_temp_id = l_tempid_tab(i)
		 AND   mmtt.move_order_line_id = mtrl.line_id;
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     debug('Error querying op_plan_id of MMTT. SQLERRM:'||Sqlerrm,l_proc_name,1);
		  END IF;
		  RAISE fnd_api.g_exc_error;
	    END;

	    IF (l_lpn_context IS NULL) THEN
               BEGIN
		  SELECT lpn_context
		    INTO l_lpn_context
		    FROM wms_license_plate_numbers
		    WHERE lpn_id = p_lpn_id;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			debug('Error querying lpn_context of WLPN. SQLERRM:'||Sqlerrm,l_proc_name,1);
		     END IF;
		     RAISE fnd_api.g_exc_error;
	       END;
	    END IF;

	    l_mmtt_qty_mol_uom := inv_convert.inv_um_convert
	                             (item_id        =>  l_mmtt_item_id
				      ,precision     =>  NULL
				      ,from_quantity => l_mmtt_qty
				      ,from_unit     => l_mmtt_uom
				      ,to_unit       => l_mol_uom
				      ,from_name =>  NULL
				      ,to_name   =>  NULL
				      );

	    IF (l_debug = 1) THEN
	       debug('l_op_plan_id:'||l_op_plan_id||
		     ' l_lpn_context:'||l_lpn_context||
		     ' l_mmtt_uom:'||l_mmtt_uom||
		     ' l_mmtt_qty:'||l_mmtt_qty||
		     ' l_mol_id:'||l_mol_id||
		     ' l_mol_uom:'||l_mol_uom||
		     ' l_mmtt_item_id:'||l_mmtt_item_id||
		     ' l_mmtt_qty_mol_uom:'||l_mmtt_qty_mol_uom||
		     ' l_wms_process_flag:'||l_wms_process_flag
		     ,l_proc_name,1);
	    END IF;

	    IF (l_lpn_context IN (g_lpn_context_inv,g_lpn_context_wip)) THEN
	       --Delete WDT
	       BEGIN
		  DELETE FROM wms_dispatched_tasks
		    WHERE transaction_temp_id = l_tempid_tab(i);
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			debug('Error deleting WDT. SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_proc_name,1);
		     END IF;
	       END;

	       IF (l_debug = 1) THEN
		  debug('# of WDT deleted:'||SQL%rowcount,l_proc_name,1);
	       END IF;
	    END IF;

	    IF (l_op_plan_id IS NULL AND l_lpn_context = g_lpn_context_inv) THEN
	       IF (l_debug = 1) THEN
		  debug('DELETE MMTT/MTLT and close/reduce MOL for:'||l_tempid_tab(i),l_proc_name,1);
	       END IF;

	       BEGIN
		 --update MOL
		 UPDATE mtl_txn_request_lines mol
		   SET quantity = quantity - l_mmtt_qty_mol_uom
		   ,   quantity_detailed = quantity_detailed - l_mmtt_qty_mol_uom
		   ,   line_status = Decode(quantity-Nvl(quantity_delivered,0)-l_mmtt_qty_mol_uom
					    ,0
					    ,inv_globals.g_to_status_closed
					    ,line_status)
		   WHERE  line_id = l_mol_id;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			debug('Error updating MOL. SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_proc_name,1);
		     END IF;
	       END;

	       IF (l_debug = 1) THEN
		  debug('# of MOL updated/closed:'||SQL%rowcount,l_proc_name,1);
	       END IF;

	       BEGIN
		  --delete MTLT
		  DELETE FROM mtl_transaction_lots_temp
		    WHERE transaction_temp_id = l_tempid_tab(i);
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			debug('Error deleting MTLT. SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_proc_name,1);
		     END IF;
	       END;

	       IF (l_debug = 1) THEN
		  debug('# of MTLT closed:'||SQL%rowcount,l_proc_name,1);
	       END IF;

	       BEGIN
		  --delete MMTT
		  DELETE FROM mtl_material_transactions_temp
		    WHERE transaction_temp_id = l_tempid_tab(i);
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			debug('Error deleting MMTT. SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM,l_proc_name,1);
		     END IF;
	       END;

	       IF (l_debug = 1) THEN
		  debug('# of MMTT closed:'||SQL%rowcount,l_proc_name,1);
	       END IF;
	    END IF;--END IF l_op_plan_id IS NULL AND l_lpn_context = g_lpn_context_inv) THEN

	    IF (l_wms_process_flag = 2) THEN
	      BEGIN
		 UPDATE mtl_txn_request_lines
		   SET  wms_process_flag = 1
		   WHERE  line_id = l_mol_id;
	      EXCEPTION
		 WHEN OTHERS THEN
		    IF (l_debug = 1) THEN
		       debug('No MOL updated. SQLERRM:'||Sqlerrm,l_proc_name,1);
		    END IF;
	      END;

	      IF (l_debug = 1) THEN
		 debug('# of MOL with process_flag = 2 updated:'||SQL%rowcount,l_proc_name,1);
	      END IF;
	    END IF;--END IF (l_wms_process_flag = 2) THEN
	    --END BUG 5075410
         END LOOP;  -- All MMTTs loop

     ELSIF ( p_call_type = G_CT_NORMAL_LOAD OR
             p_call_type = G_CT_NORMAL_DROP OR
             p_call_type = G_CT_INSPECT_TM_FAILED OR
	     p_call_type = G_CT_INSPECT_B4_TM) THEN
	-- Normal Load/Drop or Inspect scenario hence call Cleanup_Operation_Instance

	-- BUG 3288374
	IF (p_call_type = g_ct_inspect_b4_tm) THEN
	   ROLLBACK;
	END IF;

	-- All MMTTs loop
	FOR i IN 1..l_tempid_tab.COUNT
       LOOP

	  -- BUG 3288374
	  -- If call type is G_CT_INSPECT_B4_TM, then we have to roll back
	  -- AND then delete the dispatched task.  Otherwise, we can just
	  -- call complete_operation_instance
	  IF (p_call_type = g_ct_inspect_b4_tm) THEN
	     IF (l_debug = 1) THEN
		DEBUG('Calling DELETE_DISPATCHED_TASK ...',l_proc_name,9);
		DEBUG('p_source_task_id    => ' || l_tempid_tab(i),l_proc_name,9);
		DEBUG('p_wms_task_type =====> ' || WMS_GLOBALS.G_WMS_TASK_TYPE_PUTAWAY,l_proc_name,9);
	     END IF;
	     l_progress := '305';

	     WMS_OP_RUNTIME_PVT_APIS.delete_dispatched_task
	       ( p_source_task_id         => l_tempid_tab(i)
		 ,p_wms_task_type         => WMS_GLOBALS.G_WMS_TASK_TYPE_INSPECT
		 ,x_return_status         => x_return_status
		 ,x_msg_count             => x_msg_count
		 ,x_msg_data              => x_msg_data
		 );
	     IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
		IF (l_debug = 1) THEN
		   DEBUG('Error in Delete_dispatched_tasks ' ,l_proc_name,1);
		END IF;
		l_progress := '306';
		x_return_status := fnd_api.g_ret_sts_error;
	     END IF;

	   ELSE --IF (p_call_type = g_ct_inspect_b4_tm)
	     IF (l_debug = 1) THEN
		DEBUG('Calling Cleanup_Operation_Instance with ...',l_proc_name,9);
		DEBUG('p_source_task_id    => ' || l_tempid_tab(i),l_proc_name,9);
		DEBUG('p_activity_type_id  => ' || G_OP_ACTIVITY_INBOUND,l_proc_name,9);
	     END IF;
	     l_progress := '310';

	     wms_atf_runtime_pub_apis.Cleanup_Operation_Instance
	       (  p_source_task_id    => l_tempid_tab(i)
		  ,p_activity_type_id  => G_OP_ACTIVITY_INBOUND
		  ,x_return_status     => x_return_status
		  ,x_msg_data          => x_msg_data
		  ,x_msg_count         => x_msg_count
		  ,x_error_code        => l_error_code
		  );
	     l_progress := '320';

	     IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
		IF (l_debug = 1) THEN
		   DEBUG(l_error_code || ' Error in Cleanup_Operation_Instance ' ,l_proc_name,1);
		END IF;
		l_progress := '330';
		x_return_status  := fnd_api.g_ret_sts_error;
		/* Don't raise error in case of failure, instead set the ret status as error
		and proceed with the next record */
		  --RAISE fnd_api.g_exc_error;
		  END IF;
	  END IF;--IF (p_call_type = g_ct_inspect_b4_tm) THEN

	  --BUG 5075410
	  BEGIN
	     UPDATE   mtl_txn_request_lines
	       SET    wms_process_flag = 1
	       WHERE  line_id IN (SELECT move_order_line_id
				  FROM mtl_material_transactions_temp
				  WHERE transaction_temp_id = l_tempid_tab(i))
	       AND    wms_process_flag = 2;
	  EXCEPTION
	     WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		   debug('No MOL updated. SQLERRM:'||Sqlerrm,l_proc_name,1);
		END IF;
	  END;

	  IF (l_debug = 1) THEN
	     debug('# of MOL with process_flag = 2 updated:'||SQL%rowcount,l_proc_name,1);
	  END IF;
	  --END BUG 5075410
       END LOOP;  -- All MMTTs loop

     ELSE
       -- Invalid inputs passed hence error out
       l_progress := '340';
       RAISE fnd_api.g_exc_error;
     END IF;


     IF c_mol_mmtt_cursor%ISOPEN THEN
       l_progress := '970';
       CLOSE c_mol_mmtt_cursor;
     END IF;

     IF c_tmp_mmtt_cursor%ISOPEN THEN
       l_progress := '980';
       CLOSE c_tmp_mmtt_cursor;
     END IF;

     IF c_all_mmtt_cursor%isopen THEN
	CLOSE c_all_mmtt_cursor;
     END IF;

     l_progress := '985';


     l_progress := '990';

     -- Also need to clean up the TM variables.  This is needed because
     -- in an online transactions, the variables will not be reset
     inv_rcv_common_apis.rcv_clear_global;

   EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       x_return_status  := fnd_api.g_ret_sts_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_mol_mmtt_cursor%ISOPEN THEN
         CLOSE c_mol_mmtt_cursor;
       END IF;

       IF c_tmp_mmtt_cursor%ISOPEN THEN
         CLOSE c_tmp_mmtt_cursor;
       END IF;

       IF c_all_mmtt_cursor%isopen THEN
	  CLOSE c_all_mmtt_cursor;
       END IF;

     WHEN fnd_api.g_exc_unexpected_error THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_mol_mmtt_cursor%ISOPEN THEN
         CLOSE c_mol_mmtt_cursor;
       END IF;

       IF c_tmp_mmtt_cursor%ISOPEN THEN
         CLOSE c_tmp_mmtt_cursor;
       END IF;

       IF c_all_mmtt_cursor%isopen THEN
	  CLOSE c_all_mmtt_cursor;
       END IF;
     WHEN OTHERS THEN
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
       DEBUG(' Exception occured at l_progress = ' || l_progress || ' during ' || to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
       DEBUG(SQLERRM,l_proc_name,1);

       IF c_mol_mmtt_cursor%ISOPEN THEN
         CLOSE c_mol_mmtt_cursor;
       END IF;

       IF c_tmp_mmtt_cursor%ISOPEN THEN
         CLOSE c_tmp_mmtt_cursor;
       END IF;

       IF c_all_mmtt_cursor%isopen THEN
	  CLOSE c_all_mmtt_cursor;
       END IF;
   END Cleanup_ATF;


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
               1 - Check for the given LPN as well as it child LPNs (All
                   putaway other than MANUAL LOAD.
               2 - Check for the given LPN as well as it child LPNs (for
                   the MANUAL DROP case)
   *  @param   x_ret      returns the following values
   *           0 - Success
   *           1 - Entire LPN needs Inspection.
   *           2 - Entire LPN is Invalid
   *           3 - Entire LPN is Invalid and cannot be putawayed.
   *           4 - Some child LPNs are invalid and cannot be putawayed.
   *           5 - Some child LPNs need inspection.
   *           6 - There is no contents in LPN or an inner LPN inside the LPN
   *           7 - LPN invalid because you cannot load the LPN due to sub
   *               transfer restrictions specified in the material status form
   *  @param   x_loaded_stauts
   *           0 - not loaded
   *           1 - loaded
   *  @param   x_return_status
   *  @param   x_msg_count
   *  @param   x_context
   *  @param   p_user_id
   **/

   PROCEDURE Check_LPN_Validity_Wrapper(
     p_org_id         IN             NUMBER
   , p_lpn_id         IN             NUMBER
   , p_user_id        IN             NUMBER
   , p_mode           IN             NUMBER
   , x_ret            OUT NOCOPY     NUMBER
   , x_lpn_context    OUT NOCOPY     NUMBER
   , x_loaded_status  OUT NOCOPY     VARCHAR2
   , x_return_status  OUT NOCOPY     VARCHAR2
   , x_msg_count      OUT NOCOPY     NUMBER
   , x_msg_data       OUT NOCOPY     VARCHAR2
   ) IS
     l_progress         NUMBER;
     l_lpn_id           NUMBER;
     l_debug            NUMBER           := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_content_lpn      VARCHAR2(1)      := 'N';
     l_x_ret            NUMBER           :=0;

     l_x_msg_count      NUMBER;
     l_x_return_status  VARCHAR2(2);
     l_x_msg_data       VARCHAR2(2000);
     l_x_context        NUMBER;
     l_is_nested_lpn    VARCHAR2(1)      := 'N';
     l_lpn_has_contents VARCHAR2(1)      := 'N';
     l_lpn_sub          VARCHAR2(10);
     l_lpn_loc          NUMBER;
     l_drop_active      VARCHAR(1)       :=  'N';
     l_userid           NUMBER;
     l_username         VARCHAR2(100);

     -- Flags to identify the LPN validity
     l_entire_lpn_empty BOOLEAN          := TRUE;

     l_child_lpn_state   VARCHAR2(1)      := NULL;  -- 'V' Valid, 'I' Inspect 'U' INVALID
     l_parent_lpn_state  VARCHAR2(1)      := NULL;  -- 'V' Valid, 'I' Inspect 'U' INVALID.

     CURSOR lpn_cursor IS
       SELECT     lpn_id
             FROM wms_license_plate_numbers
            WHERE lpn_id <> p_lpn_id
       START WITH lpn_id = p_lpn_id
       CONNECT BY parent_lpn_id = PRIOR lpn_id;
   BEGIN

     -- Intialize out variables.
     l_progress := 10;
     l_content_lpn := 'N';
     x_return_status := fnd_api.g_ret_sts_success;
     x_loaded_status := 'N';
     x_ret := 0;

     IF (l_debug = 1) THEN
       debug('Patchset J code - Chcek_LPN_Validity_Wrapper');
       debug('p_org_id==> '|| p_org_id);
       debug('p_lpn_id==> '|| p_lpn_id);
     END IF;

     -- Get LPN Context
     SELECT lpn_context,subinventory_code,locator_id
     INTO x_lpn_context,l_lpn_sub,l_lpn_loc
     FROM   wms_license_plate_numbers
     WHERE  lpn_id = p_lpn_id;

     --BUG 3473899: p_mode = 2 => it is coming from MANUAL_LOAD
     --check the material status, and see if a sub transfer is allowed
     --in the source LPN sub/loc.  If it is not, that you cannot load the
     --LPN
     IF (p_mode = 2 AND x_lpn_context = 1) THEN
	IF (inv_material_status_grp.is_status_applicable('TRUE',
                        NULL,
                        2,--subtransfer
                        NULL,
                        NULL,
                        p_org_id,
                        NULL,
                        l_lpn_sub,
                        l_lpn_loc,
                        NULL,
                        NULL,
                        'Z') <> 'Y' OR
	    inv_material_status_grp.is_status_applicable('TRUE',
                        NULL,
			2,--Sub Transfer
                        NULL,
                        NULL,
                        p_org_id,
                        NULL,
                        l_lpn_sub,
                        l_lpn_loc,
                        NULL,
                        NULL,
                        'L') <> 'Y') THEN
	   x_ret := 7;
	   RETURN ;
	END IF;
     END IF;

     IF (x_lpn_context = 3) THEN
	--BUG 3625990: For receiving, instead of checking if the LPN is
	--locked or not, check if it has any WOOI that has type 'DROP'
	--and status 'ACTIVE'.  This is because in WMSTKPTB.CHECK_LPN_VALIDITY,
	--we no longer lock the LPN if it is a Receiving LPN
	l_drop_active := 'N';
        BEGIN
	   SELECT DISTINCT 'Y'
	     ,    wooi.last_updated_by
	     INTO l_drop_active
	     ,    l_userid
	     FROM  mtl_txn_request_lines mtrl,
	     mtl_material_transactions_temp mmtt,
	     wms_op_operation_instances wooi ,
	     (SELECT wlpn.lpn_id                 /*5723418*/
		      FROM   wms_license_plate_numbers wlpn
                      START WITH wlpn.lpn_id = p_lpn_id
		      CONNECT BY PRIOR wlpn.lpn_id = wlpn.parent_lpn_id) wlpn
	     WHERE mtrl.lpn_id = wlpn.lpn_id
	     AND   mmtt.move_order_line_id = mtrl.line_id
	     AND   wooi.source_task_id = mmtt.transaction_temp_id
	     AND   wooi.operation_status = 2
	     AND   wooi.operation_type_id = 2
	     AND   wooi.last_updated_by <> p_user_id;
	EXCEPTION
	   WHEN no_data_found THEN
	      IF (l_debug = 1) THEN
		 debug('No Operation Plan with status Drop Active');
	      END IF;
	      l_drop_active := 'N';
	   WHEN too_many_rows THEN
	      IF (l_debug = 1) THEN
		 debug('More than 1 Operation Plan with status Drop Active');
	      END IF;
	      l_drop_active := 'Y';
	      l_username := NULL;
	      l_userid := NULL;
	END;

	IF (l_debug = 1) THEN
	   debug(' Drop Active by another user? '||l_drop_active);
	END IF;

	IF (l_drop_active = 'Y') THEN
	   IF (l_userid IS NOT NULL) THEN
              BEGIN
		 SELECT user_name
		   INTO l_username
		   FROM fnd_user
		   WHERE user_id = l_userid;
	      EXCEPTION
		 WHEN OTHERS THEN
		    l_username := NULL;
	      END;

	      IF (l_username IS NOT NULL) THEN
		 fnd_message.set_name('WMS','WMS_PUTAWAY_LPN_LOCKED');
		 fnd_message.set_token('USER',l_username);
		 fnd_msg_pub.ADD;
		 fnd_message.set_name('WMS','WMS_CONT_INVALID_LPN');
		 fnd_msg_pub.ADD;
	      END IF;

	   END IF;
	   x_ret := 3; --return error
	   x_return_status := fnd_api.g_ret_sts_success;
	   RETURN;
	END IF;--END IF (l_drop_active = 'Y') THEN
     END IF;--END IF (x_lpn_context = 3) THEN

     -- Check if the given lpn has contents.

     BEGIN
       SELECT 'Y','Y'
         INTO l_content_lpn,l_lpn_has_contents
         FROM wms_lpn_contents
        WHERE parent_lpn_id = p_lpn_id
          AND ROWNUM<2;
     EXCEPTION
       WHEN no_data_found THEN
         l_content_lpn := 'N';
     END;

     IF l_content_lpn='Y' THEN
	wms_task_dispatch_put_away.check_lpn_validity
	  (p_org_id=> p_org_id
	   , p_lpn_id=> p_lpn_id
	   , x_ret=> l_x_ret
	   , x_return_status=> l_x_return_status
	   , x_msg_count=> l_x_msg_count
	   , x_msg_data=> l_x_msg_data
	   , x_context=> l_x_context
	   , p_user_id=> p_user_id
	   );

        -- Check if the lPN is alredy  loaded
        BEGIN
	  SELECT 'Y'  INTO x_loaded_status FROM dual where exists
                      (SELECT 1 from
                       wms_dispatched_tasks W,
		       mtl_material_transactions_temp t,
		       mtl_txn_request_lines M
                       WHERE m.lpn_id = p_lpn_id
		       AND   m.organization_id = p_org_id
		       AND   m.line_status <> 5
		       AND   m.quantity-Nvl(m.quantity_delivered,0)>0
		       AND   t.move_order_line_id = m.line_id
		       AND   t.organization_id = p_org_id
		       AND   w.organization_id = p_org_id
                       AND   t.transaction_temp_id = w.transaction_temp_id
                       AND   w.status = 4);
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
	   x_loaded_status := 'N';
       END;

       --bug 5590439
       -- Bug 5768339 ( Regression of 5590439)
        begin
         if (x_lpn_context =1 and x_loaded_status = 'N' ) then
         -- SELECT 'Y' INTO x_loaded_status FROM dual where exists
   	    SELECT 'Z' INTO x_loaded_status FROM dual where exists        -- End of changes for the bug 5768339.
            (SELECT 1 FROM mtl_material_transactions_temp mmtt, wms_dispatched_tasks wdt
            WHERE mmtt.transaction_temp_id = wdt.transaction_temp_id
            AND mmtt.organization_id = wdt.organization_id
            AND wdt.status = 4
            AND wdt.organization_id = p_org_id
            AND (
	    ((mmtt.lpn_id = p_lpn_id) AND (mmtt.transfer_lpn_id IS NOT NULL))
	                    OR
            ((mmtt.content_lpn_id = p_lpn_id) AND (mmtt.transfer_lpn_id IS NOT NULL))
            ));
         end if;
       Exception
	 when no_data_found then
	   x_loaded_status := 'N';
       end;
       --bug 5590439 end

	 l_entire_lpn_empty := FALSE;
     END IF;--IF l_content_lpn='Y' AND l_drop_active = 'N' THEN

     IF(l_debug =1) THEN
        debug('  Loaded status of the LPN is '|| x_loaded_status );
     END IF;


     -- If return value is error then parent lpn state 'U' - INVALID
     -- else if return  value = 0 then parent lpn state 'V' - VALID;
     -- else if return value = 1  then parent lpn state 'I' - INSPECT;
     -- else paretn lpn statue -  'U'  - INVALID.
     IF (l_x_return_status = fnd_api.g_ret_sts_error  OR  l_x_return_status = fnd_api.g_ret_sts_unexp_error ) THEN
       l_parent_lpn_state := 'U';   -- invalid
     ELSIF (l_x_ret =0) THEN
         l_parent_lpn_state := 'V'; -- valid.
     ELSIF (l_x_ret =1) THEN
         l_parent_lpn_state := 'I'; -- Inspect required
     ELSIF (l_x_ret =4) THEN
         x_ret := 5;
         RETURN;
     ELSE
         l_parent_lpn_state := 'U';  -- Invalid
     END IF; -- for return state.

     IF(l_debug= 1) THEN
        debug('l_x_return_status ' || l_x_return_status);
        debug('l_x_ret ' || l_x_ret);
     END IF;


     -- If mode value is '0' then this method is called from grouping logic,
     -- In this case check for the given LPN itself and return.

     IF p_mode = 0 THEN
         -- In case of failures l_x_ret might be '0' set it to proper value;
         IF (l_x_return_status = fnd_api.g_ret_sts_error  OR
             l_x_return_status = fnd_api.g_ret_sts_unexp_error ) THEN
             l_x_ret := 3;
         END IF;
         x_ret := l_x_ret;
         RETURN;
     END IF;

     -- Check the validity of child LPNs
     IF (l_debug = 1)  THEN
        debug('Given LPN is validity checked, Now check if the child LPNs are valid');
     END IF;

     OPEN lpn_cursor;

     LOOP
       FETCH lpn_cursor INTO l_lpn_id;
       EXIT WHEN lpn_cursor%NOTFOUND;
       l_content_lpn      := 'N';

       IF(l_debug = 1) THEN
         debug('Checking validity of Child Lpn ' || l_lpn_id);
       END IF;

       -- Check lpn has contents
       BEGIN
         SELECT 'Y','Y'
           INTO l_content_lpn,l_lpn_has_contents
           FROM wms_lpn_contents
          WHERE parent_lpn_id = l_lpn_id
            AND ROWNUM<2;
       EXCEPTION
         WHEN no_data_found THEN
           l_content_lpn := 'N';
       END;

       IF l_debug = 1 THEN
         IF (l_content_lpn = 'N') THEN debug('lpn ' || l_lpn_id || 'has no contents'); END IF;
         IF (l_content_lpn = 'Y') THEN debug('lpn ' || l_lpn_id || 'has contents'); END IF;
       END IF;

       IF l_content_lpn ='Y' THEN
           --BUG 5130266 - No need to check for drop active here, because
           --the CONNECT BY PRIOR query on the outermost LPN would have
           --checked
           wms_task_dispatch_put_away.check_lpn_validity
             (p_org_id=> p_org_id
            , p_lpn_id=> l_lpn_id
            , x_ret=> l_x_ret
            , x_return_status=> l_x_return_status
            , x_msg_count=> l_x_msg_count
            , x_msg_data=> l_x_msg_data
            , x_context=> l_x_context
            , p_user_id=> p_user_id
	   );

           IF(l_debug= 1) THEN
             debug('After checking validity for lpn '|| l_lpn_id);
             debug('Return status ' || l_x_return_status);
             debug('return value for the chld LPN ' || l_x_ret);
           END IF;

           -- If return value is error then child lpn state 'U' - INVALID
           -- else if return  value = 0 then child lpn state 'V' - VALID;
           -- else if return value = 1  then child lpn state 'I' - INSPECT;
           -- else paretn lpn statue -  'U'  - INVALID.
           IF (l_x_return_status = fnd_api.g_ret_sts_error  OR  l_x_return_status = fnd_api.g_ret_sts_unexp_error ) THEN
             l_child_lpn_state := 'U';   -- invalid
           ELSIF (l_x_ret =0) THEN
               l_child_lpn_state := 'V';    -- valid.
           ELSIF (l_x_ret =1) THEN
               l_child_lpn_state := 'I';  -- Inspect required
           ELSE
               l_child_lpn_state := 'U';  -- Invalid
           END IF; -- for return state.

           -- logic used.

           /*-------------------------------------------------------------------
            * Given lpn          child LPN        result
            *-------------------------------------------------------------------
            *  INVALID           VALID            oh.. oh.. We have a problem
            *                                     Break the loop, return 4
            *  INSP REQ          VALID            Break the loop, return 4
            *  INSP Req          Invalid          Break the loop, return 4
            *  VALID             INVALID          Break the loop, return 4
            *  INSP Req          INSP Req         Continue loop. return 1 if
            *                                     entire lpn req inspection.
            *  INVALID           INVALID          No problem continue looping,
            *                                     Until you find valid lpn.
            *  VAlID             VALID            No Problem continue looping
                                                  Until you find Invalid lpn.
            ------------------------------------------------------------------*/

            -- Conclusion: From above table if Given LPN and child LPN states
            -- are same continue/otherwise error out.


           IF (l_parent_lpn_state <> l_child_lpn_state) THEN
              x_ret := 4; RETURN;
           END IF;

           /*--------------------------------------------------------------------
            * If one child LPN is loaded then the entire LPN is loaded.
            * To know whether a lpn is loaded or not, that lpn should have
            * some cotents inside it. An lpn with some contents here after
            * will be called as content lpn.
            *
            * To make sure loaded check will be called only for one contentlpn
            * and not every lpn, make use of the flag l_entire_lpn_empty.
            *
            * First time when the flow comes here l_entire_lpn_empty will be false,
            * and from second time it will be true because we are updating
            * l_entire_lpn_empty flag in the end. This way we can make sure
            * loaded check will be called only once.
            ------------------------------------------------------------------------*/

           IF l_entire_lpn_empty THEN
              BEGIN
                SELECT 'Y'  INTO x_loaded_status FROM dual where exists
                           (select 1 from
                            WMS_DISPATCHED_TASKS W, MTL_MATERIAL_TRANSACTIONS_TEMP T
                            WHERE T.lpn_id = l_lpn_id
			    AND t.organization_id = p_org_id
			    AND w.organization_id = p_org_id
                            AND T.transaction_temp_id = W.transaction_temp_id
                            AND W.STATUS = 4 );
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  x_loaded_status := 'N';
              END;
           END IF;
           l_entire_lpn_empty := FALSE;
       END IF;
     END LOOP;

     -- Compare with childs state only atleast one child is processed.
     -- If child lpn state is null, then no child is so far processed.
     IF (l_parent_lpn_state <> nvl(l_child_lpn_state,l_parent_lpn_state)) THEN
        x_ret := 4;
     END IF;

     IF(l_parent_lpn_state = nvl(l_child_lpn_state,l_parent_lpn_state)) THEN
        IF l_parent_lpn_state = 'I' THEN
           x_ret:=1;
        ELSIF (l_parent_lpn_state = 'U') THEN
          x_ret := 3;
        ELSIF (l_parent_lpn_state = 'V') THEN
          x_ret :=0;
        END IF;
     END IF;

     IF (l_lpn_has_contents = 'N') THEN
        x_ret := 6;
     END IF;

     IF lpn_cursor%isopen THEN
       CLOSE lpn_cursor;
     END IF;

     RETURN;


   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       x_ret           := 3;
       debug(SQLCODE, 1);

       IF lpn_cursor%isopen THEN
         CLOSE lpn_cursor;
       END IF;

       IF SQLCODE IS NOT NULL THEN
         l_progress := 100;
         inv_mobile_helper_functions.sql_error('validate_nested_lpns', l_progress, SQLCODE);
       END IF;
   END check_lpn_validity_wrapper;



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
   ) IS

     l_lpn_id             NUMBER;
     l_number_of_rows     NUMBER := 0;
     l_x_crossdock        VARCHAR2(2) := 'Y';
     l_progress           NUMBER := 10;
     l_is_content_lpn     VARCHAR2(2) := 'N';
     l_debug           NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_error_messages     VARCHAR2(1200);
     l_msg_count           NUMBER;
     l_msg_data           VARCHAR2(1200);
     CURSOR lpn_cursor IS
           SELECT lpn_id
             FROM wms_license_plate_numbers
       START WITH lpn_id = p_lpn_id
       CONNECT BY parent_lpn_id = PRIOR lpn_id;
   BEGIN

     -- Intializat out variables.
     x_return_status := fnd_api.g_ret_sts_success;

     -- Explode the LPN and for each child LPN call suggestions_pub_wrapper.
     IF (l_debug = 1) THEN
       debug('Patchset J code');
       debug('  p_org_id==> '|| p_org_id);
       debug('  p_lpn_id==> '|| p_lpn_id);
       debug('  p_user_id==> '|| p_user_id);
     END IF;

     -- Initialize out variables
     x_return_status := fnd_api.g_ret_sts_success;
     x_crossdock:= 'N';
     x_number_of_rows := 0;

     OPEN lpn_cursor;
     LOOP
       FETCH lpn_cursor INTO l_lpn_id;
       EXIT WHEN lpn_cursor%notfound;
         -- Check if the given LPN has contents.
         BEGIN
             SELECT 'Y' INTO l_is_content_lpn
             FROM   wms_lpn_contents
             WHERE  parent_lpn_id = l_lpn_id
             AND    ROWNUM<2;
         EXCEPTION
           WHEN no_data_found  THEN l_is_content_lpn := 'N';
         END;

         -- Call suggestions pub for each of the LPN.
         IF (l_is_content_lpn = 'Y') THEN

           wms_Task_Dispatch_put_away.suggestions_pub(
              p_lpn_id               => l_lpn_id
             ,p_org_id               => p_org_id
             ,p_user_id              => p_user_id
             ,p_eqp_ins              => p_eqp_ins
             ,x_number_of_rows       => l_number_of_rows
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             ,x_crossdock            => l_x_crossdock
             ,p_status               => p_status
             ,p_check_for_crossdock  => p_check_for_crossdock
             ,p_commit               => 'N');


         IF (l_debug=1) THEN
           debug('ret status after suggestion pug for :  ' ||l_lpn_id||' is '|| x_return_status);
         END IF;


         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
--	    IF x_msg_count = 0 THEN
--	       FND_MESSAGE.SET_NAME('WMS','WMS_LOG_EXCEPTION_FAIL');
--	       FND_MSG_PUB.ADD;
--	    END IF;
	    RAISE FND_API.g_exc_unexpected_error;

          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
--	    IF x_msg_count = 0 THEN
--	    FND_MESSAGE.SET_NAME('WMS','WMS_LOG_EXCEPTION_FAIL');
--	    FND_MSG_PUB.ADD;
--	    END IF;
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF l_x_crossdock = 'Y' THEN
            x_crossdock := 'Y';
         END IF;
         x_number_of_rows := l_number_of_rows+x_number_of_rows;
       END IF;
     END LOOP;

     IF l_debug = 1 THEN
        debug('End of loop: Final ret status: ' || x_return_status || ' no of rows: ' || x_number_of_rows);
     END IF;



     IF x_number_of_rows = 0 THEN
	fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data =>
				  l_msg_data);
	IF l_debug = 1 THEN
	   debug('l_msg_count: ' || l_msg_count);
	   debug('l_msg_data: ' || l_msg_data);
	END IF;

	IF (l_msg_count IS NULL OR l_msg_count = 0) THEN
	   -- use default message if there are no message on stack
	   -- first reset message stack
     fnd_msg_pub.initialize();
	   FND_MESSAGE.SET_NAME('WMS','WMS_ALLOCATE_FAIL');
	   FND_MSG_PUB.ADD;
  ELSIF l_msg_count > 1 THEN
 	  FOR i IN 2 .. l_msg_count LOOP
 	    fnd_msg_pub.delete_msg(i);
 	  END LOOP;
	END IF;
	RAISE fnd_api.g_exc_error;
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       debug(SQLCODE, 1);

       IF lpn_cursor%isopen THEN
         CLOSE lpn_cursor;
       END IF;

       -- Get rid of the folloiwng, as it appends a junk message to the
       -- error message stack
       --       IF SQLCODE IS NOT NULL AND l_no_lines <> 1 THEN
       --         l_progress := 100;
       --	 inv_mobile_helper_functions.sql_error('suggestions_pub_wrapper', l_progress, SQLCODE);
       --       END IF;
   END suggestions_pub_wrapper;

   /**
   *  Nested LPN changes, This procedure packs the given from lpn into tolpn
   *  and calls suggestions_pub
   *  @param   p_org_id       Current Organization
   *  @param   p_sub_code     If tosub is receving then call transfer transaction
                              If to sub is inventory sub then call Pack Unpack API.
   *  @param   p_from_lpn_id  From LPN id
   *  @param   p_to_lpn_id    Transfer LPN id
   *  @param   p_mode
               1 - Pack from_lpn into to_lpn
               2 - unpack to_lpn from from_lpn
               for unpcaking lpn
               fromlpnid -> parentlpnid
               tolpnid   -> child lPNID
   *  @param   x_ret      returns the following values
   *           0 - Success
   *           1 - failure.
   **/
   PROCEDURE PackUnpack_lpn(
     p_from_lpn_id    IN             NUMBER
   , p_to_lpn_id      IN             NUMBER
   , p_org_id         IN             NUMBER
   , p_sub_code       IN             VARCHAR2
   , p_loc_id         IN             NUMBER
   , p_user_id        IN             NUMBER
   , p_project_id     IN             NUMBER  DEFAULT NULL
   , p_task_id        IN             NUMBER  DEFAULT NULL
   , p_trx_header_id  IN             NUMBER
   , p_mode           IN             NUMBER
   , p_batch_id       IN             NUMBER DEFAULT NULL
   , p_batch_seq      IN             NUMBER DEFAULT NULL
   , x_return_status  OUT NOCOPY     VARCHAR2
   , x_msg_count      OUT NOCOPY     NUMBER
   , x_msg_data       OUT NOCOPY     VARCHAR2
   ) IS
     l_progress    NUMBER;
     l_txn_temp_id NUMBER;
     l_debug       NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_ret         NUMBER;

 BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := 10;

   IF(l_debug =1) THEN
     debug('In Patchset J code: ','PackUnpackLpn');
   END IF;


   -- Pack from lpn into to lpn
   IF p_mode = 1 THEN
       l_ret := inv_trx_util_pub.insert_line_trx(
          p_trx_hdr_id           => p_trx_header_id
        , p_item_id              => '0'
        , p_org_id               => p_org_id
        , p_trx_action_id        => inv_globals.g_action_containerpack
        , p_subinv_code          => p_sub_code
        , p_locator_id           => p_loc_id
        , p_trx_type_id          => inv_globals.g_type_container_pack
        , p_trx_src_type_id      => inv_globals.g_sourcetype_inventory
        , p_trx_qty              => 1
        , p_pri_qty              => 1
        , p_uom                  => 'Ea'
        , p_user_id              => p_user_id
        , p_from_lpn_id          => NULL
        , p_cnt_lpn_id           => p_from_lpn_id
        , p_xfr_lpn_id           => p_to_lpn_id
        , x_trx_tmp_id           => l_txn_temp_id
        , x_proc_msg             => x_msg_data
        , p_project_id           => p_project_id
        , p_task_id              => p_task_id);
   END IF;


   -- UnPack to lpn from from lpn
   IF p_mode = 2 THEN
       l_ret := inv_trx_util_pub.insert_line_trx(
          p_trx_hdr_id           => p_trx_header_id
        , p_item_id              => '-1'
        , p_org_id               => p_org_id
        , p_trx_action_id        => inv_globals.g_action_containerunpack
        , p_subinv_code          => p_sub_code
        , p_locator_id           => p_loc_id
        , p_trx_type_id          => inv_globals.g_type_container_unpack
        , p_trx_src_type_id      => inv_globals.g_sourcetype_inventory
        , p_trx_qty              => 1
        , p_pri_qty              => 1
        , p_uom                  => 'Ea'
        , p_user_id              => p_user_id
        , p_from_lpn_id          => p_from_lpn_id
        , p_cnt_lpn_id           => p_to_lpn_id
        , p_xfr_lpn_id           => NULL
        , x_trx_tmp_id           => l_txn_temp_id
        , x_proc_msg             => x_msg_data
        , p_project_id           => p_project_id
        , p_task_id              => p_task_id);
   END IF;

   IF (l_txn_temp_id <=0 ) OR (l_ret<>0) THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
   END IF;

   -- Update batch id and seq id
   IF p_batch_id IS NOT NULL AND p_batch_seq IS NOT NULL THEN
     UPDATE  mtl_material_transactions_temp
       SET   transaction_header_id = p_trx_header_id
           , transaction_batch_id  = p_batch_id
           , transaction_batch_seq = p_batch_seq
     WHERE   transaction_temp_id   = l_txn_temp_id;
   END IF; -- Update batch id

   IF l_debug = 1  THEN
     debug('return status' || l_ret);
     debug('New transaction created with transaction temp id ' || l_txn_temp_id,'packunpack_lpn');
   END IF;

 EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      debug(SQLCODE, 1);

      IF SQLCODE IS NOT NULL THEN
        l_progress := 100;
        inv_mobile_helper_functions.sql_error('Pack Unpack Lpn', l_progress, SQLCODE);
      END IF;
 END;


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
  ) IS
     l_progress          NUMBER;
     l_lpn_context       NUMBER;
     l_parent_lpn_id     NUMBER;
     l_trx_header_id     NUMBER;
     l_debug             NUMBER   := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_x_num_of_rows     NUMBER   := 0;
     l_x_return_status   VARCHAR2(2);
     l_x_msg_count       NUMBER;
     l_x_msg_data        VARCHAR2(2000);
     l_ret               NUMBER;
     l_is_tm_call_needed BOOLEAN := FALSE;
     l_is_rcv_tm_call_needed BOOLEAN := FALSE;
     l_old_txn_mode_code VARCHAR2(10);
     l_group_id          NUMBER;
     l_to_sub            VARCHAR2(10);
     l_to_loc            NUMBER;
     l_to_context        NUMBER;
     l_sub_loc_changed   VARCHAR2(1);
     l_txn_temp_id NUMBER;
     TYPE number_tb_tp IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     l_mmtt_ids          number_tb_tp;
     l_emp_id NUMBER;
     l_task_execute_rec wms_dispatched_tasks%ROWTYPE;
     l_error_code        NUMBER;

     l_consolidation_method_id NUMBER;
     l_drop_lpn_option NUMBER;

     l_msg_count                 NUMBER;
     l_msg_data                  VARCHAR2(10000);
     l_discrepancy       NUMBER;
 BEGIN
     l_progress := 10;
     x_return_status := fnd_api.g_ret_sts_success;

     IF (l_debug = 1) THEN
       debug('Patchset J code - Load LPN');
       debug('  p_org_id=======> '|| p_org_id);
       debug('  p_from_lpn_id==> '|| p_from_lpn_id);
       debug('  p_to_lpn_id====> '|| p_to_lpn_id);
       debug('  p_user_id======> '|| p_user_id);
       debug('  p_sub_code=====> '|| p_sub_code);
       debug('  p_loc_id=======> '|| p_loc_id);
     END IF;

     SELECT parent_lpn_id,lpn_context
       INTO l_parent_lpn_id,l_lpn_context
       FROM wms_license_plate_numbers
       WHERE lpn_id = p_from_lpn_id;

     IF (p_to_lpn_id IS NOT NULL AND p_to_lpn_id <> 0) THEN
  l_progress := 20;
  BEGIN
     SELECT lpn_context,subinventory_code,locator_id
       INTO l_to_context,l_to_sub,l_to_loc
       FROM wms_license_plate_numbers
       WHERE lpn_id = p_to_lpn_id;
  EXCEPTION
     WHEN OTHERS THEN
        l_to_context := -1;
        l_to_sub := NULL;
        l_to_loc := NULL;
  END;
  l_progress := 30;
     END IF;

     -- Set variable if sub/loc of toLPN is different from that of from LPN
     IF (Nvl(p_to_lpn_id,0) <> 0
   AND l_to_context IN (1,2,3)  -- No need to call TM if DFBU LPN
   AND (Nvl(l_to_sub,'@@@') <> Nvl(p_sub_code,'@@@')
        OR Nvl(l_to_loc,-1) <> Nvl(p_loc_id,-1))) THEN
  l_sub_loc_changed := 'Y';
      ELSE
  l_sub_loc_changed := 'N';
     END IF;

     IF (l_debug = 1) THEN
  debug('Sub/loc changed: ' || l_sub_loc_changed,9);
  debug('l_to_sub => ' || l_to_sub,9);
  debug('l_to_loc => ' || l_to_loc,9);
     END IF;

     -- Get Transaction header id.

     SELECT mtl_material_transactions_s.NEXTVAL
       INTO l_trx_header_id
       FROM dual;


     -- Pack Entire lpn witn LPN context Resides in inventory
     IF l_lpn_context = 1 AND p_mode = 1 THEN

       IF l_parent_lpn_id IS NOT NULL THEN

         IF(l_debug =1) THEN
           debug('Inventory LPN, Parent lpn is not null, Unpack '||p_from_lpn_id|| ' from ' ||l_parent_lpn_id);
         END IF;

         PackUnpack_LPN(
                 p_from_lpn_id   => l_parent_lpn_id
               , p_to_lpn_id     => p_from_lpn_id
               , p_org_id        => p_org_id
               , p_sub_code      => p_sub_code
               , p_loc_id        => p_loc_id
               , p_user_id       => p_user_id
               , p_project_id    => p_project_id
               , p_task_id       => p_task_id
               , p_trx_header_id => l_trx_header_id
         , p_mode          => 2
         , p_batch_id      => l_trx_header_id
         , p_batch_seq     => 1
               , x_return_status => l_x_return_status
               , x_msg_count     => l_x_msg_count
               , x_msg_data      => l_x_msg_data);

         l_is_tm_call_needed := TRUE;
       END IF;

       IF  (p_to_lpn_id IS NOT NULL) AND (p_to_lpn_id <> p_from_lpn_id) AND (p_to_lpn_id <> 0) THEN

         IF (l_debug = 1) THEN
           debug('Inventory LPN, To lpn is not null, Pack  '||p_from_lpn_id|| ' Into  ' ||p_to_lpn_id);
         END IF;

   IF (l_sub_loc_changed = 'Y') THEN
      l_ret := inv_trx_util_pub.insert_line_trx
        (
         p_trx_hdr_id           => l_trx_header_id
         , p_item_id              => '0'
         , p_org_id               => p_org_id
         , p_trx_action_id        => 2
         , p_subinv_code          => p_sub_code
         , p_tosubinv_code        => l_to_sub
         , p_locator_id           => p_loc_id
         , p_tolocator_id         => l_to_loc
         , p_trx_type_id          => 2
         , p_trx_src_type_id      => 13
         , p_trx_qty              => 1
         , p_pri_qty              => 1
         , p_uom                  => 'Ea'
         , p_user_id              => p_user_id
         , p_from_lpn_id          => NULL
         , p_cnt_lpn_id           => p_from_lpn_id
         , p_xfr_lpn_id           => NULL
         , x_trx_tmp_id           => l_txn_temp_id
         , x_proc_msg             => x_msg_data
         , p_project_id           => p_project_id
         , p_task_id              => p_task_id);
      IF (l_txn_temp_id <= 0 ) OR (l_ret<>0) THEN
         IF (l_debug = 1) THEN
      debug('Error inserting MMTT ID: ' ||
      l_txn_temp_id,9);
         END IF;
         RAISE fnd_api.g_exc_error;
      END IF;

      BEGIN
         UPDATE  mtl_material_transactions_temp
     SET   transaction_header_id = l_trx_header_id
     , transaction_batch_id  = l_trx_header_id
     , transaction_batch_seq = 2
     WHERE   transaction_temp_id   = l_txn_temp_id;
      EXCEPTION
         WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         debug('Error updating MMTT with ID: ' ||
         l_txn_temp_id,9);
      END IF;
      RAISE fnd_api.g_exc_error;
      END;

      packunpack_lpn
        (
         p_from_lpn_id   => p_from_lpn_id
         , p_to_lpn_id     => p_to_lpn_id
         , p_org_id        => p_org_id
         , p_sub_code      => l_to_sub
         , p_loc_id        => l_to_loc
         , p_user_id       => p_user_id
         , p_project_id    => p_project_id
         , p_task_id       => p_task_id
         , p_trx_header_id => l_trx_header_id
         , p_mode          => 1 -- Pack
         , p_batch_id      => l_trx_header_id
         , p_batch_seq     => 3
         , x_return_status => l_x_return_status
         , x_msg_count     => l_x_msg_count
         , x_msg_data      => l_x_msg_data);
      ELSE -- If no sub/loc changed
      packunpack_lpn
        (
         p_from_lpn_id   => p_from_lpn_id
         , p_to_lpn_id     => p_to_lpn_id
         , p_org_id        => p_org_id
         , p_sub_code      => p_sub_code
         , p_loc_id        => p_loc_id
         , p_user_id       => p_user_id
         , p_project_id    => p_project_id
         , p_task_id       => p_task_id
         , p_trx_header_id => l_trx_header_id
         , p_mode          => 1 -- Pack
         , p_batch_id      => l_trx_header_id
         , p_batch_seq     => 2
         , x_return_status => l_x_return_status
         , x_msg_count     => l_x_msg_count
         , x_msg_data      => l_x_msg_data);
   END IF;
         l_is_tm_call_needed := TRUE;
       END IF;

     END IF; ---IF l_lpn_context = 1 AND p_mode = 1 THEN

     IF(l_debug = 1) THEN
        debug('After calling pack unpack ');
     END IF;

     -- Call pup if 1) it is WIP LPN, or if 2) it is RCV LPN and
     -- i) it is not doing any nesting
     -- ii) or if it is, the sub and loc is the same as the from LPN
     IF p_mode = 1
        AND ((l_lpn_context = 3 AND l_sub_loc_changed = 'N')
       OR l_lpn_context = 2) THEN

       -- Unpack the given LPN from its parent lpn
       IF l_parent_lpn_id IS NOT NULL THEN
          IF(l_debug = 1) THEN
             debug('Receiving LPN, Parent lpn is not null, Unpack '||p_from_lpn_id||' from ' ||l_parent_lpn_id);
          END IF;
          wms_container_pvt.packunpack_container
            (p_api_version       =>   1.0
            ,p_content_lpn_id   =>   p_from_lpn_id
            ,p_lpn_id           =>   l_parent_lpn_id
            ,p_operation        =>   2 -- Unpack
            ,p_organization_id  =>   p_org_id
            ,p_commit           =>   fnd_api.g_false
            ,x_return_status    =>   x_return_status
            ,x_msg_count        =>   x_msg_count
            ,x_msg_data         =>   x_msg_data);

    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
       IF (l_debug = 1) THEN
    DEBUG('Error unpacking content_lpn = ' ||
          p_from_lpn_id || ' into lpn = ' ||
          l_parent_lpn_id,'load_lpn',9);
    debug('Error message:'||x_msg_data,9);
       END IF;
       RAISE fnd_api.g_exc_error;
    END IF;
       END IF; --IF l_parent_lpn_id IS NOT NULL THEN

       -- Pack the given LPN into ToLPN
       IF p_to_lpn_id IS NOT NULL AND p_to_lpn_id <> p_from_lpn_id AND (p_to_lpn_id <> 0) THEN
         IF(l_debug = 1) THEN
            debug('Receiving LPN, To lpn is not null, Pack  '||p_from_lpn_id|| ' Into  ' ||p_to_lpn_id);
         END IF;

   -- Only modify LPN sub/loc if it is WIP LPN, since the RCV case
   -- won't even reach this point
   IF (l_lpn_context=2 AND l_sub_loc_changed = 'Y') THEN
      wms_container_pvt.modify_lpn_wrapper
        ( p_api_version    =>  1.0
    ,x_return_status =>  x_return_status
    ,x_msg_count     =>  x_msg_count
    ,x_msg_data      =>  x_msg_data
    ,p_lpn_id        =>  p_from_lpn_id
    ,p_subinventory  =>  l_to_sub
    ,p_locator_id    =>  l_to_loc
    );
      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
         IF (l_debug = 1) THEN
      debug('Error modifying lpn',
      'load_lpn', 9);
         END IF;
      END IF;
   END IF;

   wms_container_pvt.packunpack_container
           (p_api_version       =>   1.0
           ,p_content_lpn_id   =>   p_from_lpn_id
           ,p_lpn_id           =>   p_to_lpn_id
           ,p_operation        =>   1 --Pack
           ,p_organization_id  =>   p_org_id
           ,p_commit           =>   fnd_api.g_false
           ,x_return_status    =>   x_return_status
           ,x_msg_count        =>   x_msg_count
           ,x_msg_data         =>   x_msg_data);
    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
       IF (l_debug = 1) THEN
    DEBUG('Error packing content_lpn = ' ||
          p_from_lpn_id || ' into lpn = ' ||
          p_to_lpn_id,'load_lpn',9);
    debug('Error message:'||x_msg_data,9);
       END IF;
       RAISE fnd_api.g_exc_error;
    END IF;
       END IF; -- IF p_to_lpn_id IS NOT NULL AND p_to_lpn_id <> p_from_lpn_id AND (p_to_lpn_id <> 0) THEN

     END IF; --IF p_mode = 1

     -- only call rcv tm if loading into an lpn with different sub/loc
     IF l_lpn_context = 3 AND l_sub_loc_changed = 'Y' THEN
  l_group_id := insert_rti
    (p_from_org  => p_org_id
     ,p_lpn_id   => p_from_lpn_id
     ,p_to_org  => p_org_id  -- same as from lpn
     ,p_to_sub  => l_to_sub
     ,p_to_loc  => l_to_loc
     ,p_xfer_lpn_id => p_from_lpn_id
     ,p_first_time => 1
     ,p_mobile_txn => 'Y'
     ,p_txn_mode_code =>  'ONLINE'
     ,x_return_status => x_return_status
     ,x_msg_count => x_msg_count
     ,x_msg_data => x_msg_data);
  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
     IF (l_debug = 1) THEN
        debug('Error inserting RTI');
     END IF;
     RAISE fnd_api.g_exc_error;
  END IF;

  IF (l_debug = 1 ) then
     debug('RTI inserted with group_id:'|| l_group_id, 9);
  END IF;

  inv_rcv_integration_apis.insert_wlpni
    (p_api_version    =>  1.0
     ,x_return_status =>  x_return_status
     ,x_msg_count     =>  x_msg_count
     ,x_msg_data      =>  x_msg_data
     ,p_organization_id => p_org_id
     ,p_lpn_id          => p_from_lpn_id
     ,p_license_plate_number =>  NULL
     ,p_lpn_group_id    =>   l_group_id
     ,p_parent_lpn_id   =>   p_to_lpn_id
     );
  l_is_rcv_tm_call_needed := TRUE;
     END IF; -- If Into LPN has different sub/loc

     -- Call suggestions_pub_wrapper for the from lpn
     suggestions_pub_wrapper(
          p_lpn_id                    => p_from_lpn_id
        , p_org_id                    => p_org_id
        , p_user_id                   => p_user_id
        , p_eqp_ins                   => p_eqp_ins
        , p_status                    => 4 --loaded
        , p_check_for_crossdock       => p_check_for_crossdock
        , x_number_of_rows            => l_x_num_of_rows
        , x_return_status             => l_x_return_status
        , x_msg_count                 => l_x_msg_count
        , x_msg_data                  => l_x_msg_data
        , x_crossdock                 => x_crossdock
     );

     IF(l_debug = 1) THEN
       debug('x_return_status from suggestions_pub ' || l_x_return_status);
       debug('After creating suggestions for ' || p_from_lpn_id);
     END IF;


     IF l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
--	IF (x_msg_count = 0) THEN
--	   FND_MESSAGE.SET_NAME('WMS','WMS_LOG_EXCEPTION_FAIL');
--	   FND_MSG_PUB.ADD;
--	END IF;
	RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_x_return_status = FND_API.G_RET_STS_ERROR THEN
--	IF (x_msg_count = 0 ) THEN
--	   FND_MESSAGE.SET_NAME('WMS','WMS_LOG_EXCEPTION_FAIL');
--	   FND_MSG_PUB.ADD;
--	END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     --BUG 4345714: If any line is not detailed, then fail.
     BEGIN
	SELECT  /*+ ORDERED INDEX(MTRL MTL_TXN_REQUEST_LINES_N7) */  1
	  INTO l_discrepancy
	  FROM mtl_txn_request_lines mtrl ,
	      (SELECT wlpn.lpn_id                 /*5723418*/
		FROM wms_license_plate_numbers wlpn
		START WITH  wlpn.lpn_id = p_from_lpn_id
        	CONNECT BY PRIOR wlpn.lpn_id = wlpn.parent_lpn_id) wlpn

	  WHERE mtrl.lpn_id = wlpn.lpn_id
	  AND mtrl.line_status = 7
	  AND (mtrl.quantity-Nvl(mtrl.quantity_delivered,0)) <> Nvl(mtrl.quantity_detailed,0)
	  AND mtrl.organization_id = p_org_id;
     EXCEPTION
	WHEN too_many_rows THEN
	   l_discrepancy := 1;
	WHEN no_data_found THEN
	   l_discrepancy := 0;
	WHEN OTHERS THEN
	   l_discrepancy := 0;
     END;

     IF (l_debug = 1) THEN
	debug('l_discrepancy = ' || l_discrepancy, 'load_lpn', 9);
     END IF;

     IF l_discrepancy = 1 THEN
	fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data =>
				  l_msg_data);
	IF l_debug = 1 THEN
	   debug('l_msg_count: ' || l_msg_count);
	   debug('l_msg_data: ' || l_msg_data);
	END IF;

	IF (l_msg_count IS NULL OR l_msg_count = 0) THEN
	   -- use default message if there are no message on stack
	   -- first reset message stack
	   fnd_msg_pub.initialize();
	   FND_MESSAGE.SET_NAME('WMS','WMS_ALLOCATE_FAIL');
	   FND_MSG_PUB.ADD;
	 ELSIF l_msg_count > 1 THEN
	   FOR i IN 2 .. l_msg_count LOOP
	      fnd_msg_pub.delete_msg(i);
	   END LOOP;
	END IF;

	-- 6962664
        debug('Suggested locator capacity should be reverted as putaway fails');
        debug('Before calling the revert_loc_suggested_capacity');
        wms_task_dispatch_put_away.revert_loc_suggested_capacity(
              x_return_status       => l_x_return_status
            , x_msg_count           => l_x_msg_count
            , x_msg_data            => l_x_msg_data
            , p_organization_id     => p_org_id
            , p_lpn_id              => p_from_lpn_id
            );
        debug('After calling the revert_loc_suggested_capacity');
        ROLLBACK;
	-- 6962664

	RAISE fnd_api.g_exc_error;
     END IF;

     --  Call TM for Pack/Unpack the given lpn
     IF (l_is_tm_call_needed = TRUE) THEN
        l_ret := inv_lpn_trx_pub.process_lpn_trx(
                 p_trx_hdr_id => l_trx_header_id,
                 p_commit => fnd_api.g_false,
                 x_proc_msg => x_msg_data,
                 p_atomic => fnd_api.g_true);
       -- Check return value and in case of failure raise exception
       IF (l_ret <> 0)  THEN
          IF l_debug = 1 THEN
            debug('TM call for pack unpack faluire');
            debug('Failure message ' || x_msg_data);
          END IF;
          FND_MESSAGE.SET_NAME('WMS','WMS_LOG_EXCEPTION_FAIL');
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

     IF (l_is_rcv_tm_call_needed = TRUE) THEN

	--BUG 3359835: Must call activate_operation_instance
	l_progress := 40;
	SELECT mmtt.transaction_temp_id
	  bulk collect INTO l_mmtt_ids
	  FROM mtl_material_transactions_temp mmtt
	  WHERE mmtt.organization_id = p_org_id
	  AND mmtt.move_order_line_id IN
	  ( SELECT mtrl.line_id
	    FROM   mtl_txn_request_lines mtrl ,
	    (SELECT wlpn.lpn_id   /* 5723418 */
		     FROM wms_license_plate_numbers wlpn
		     START WITH wlpn.lpn_id = p_from_lpn_id
		     CONNECT BY PRIOR wlpn.lpn_id = wlpn.parent_lpn_id) wlpn
	    WHERE mtrl.organization_id = p_org_id
	    AND mtrl.lpn_id = wlpn.lpn_id );
	l_progress := 50;

        BEGIN
	   SELECT employee_id
	     INTO l_emp_id
	     FROM fnd_user
	     WHERE user_id = p_user_id;
	EXCEPTION
	   WHEN OTHERS THEN
	      IF (l_debug = 1) THEN
		 DEBUG('There is no employee id tied to the user','load_lpn',9);
	      END IF;
	      fnd_message.set_name('WMS', 'WMS_NO_EMP_FOR_USR');
	      fnd_msg_pub.ADD;
	      RAISE fnd_api.g_exc_error;
	END;

	-- BEGIN DBI FIX
	l_task_execute_rec.person_id := l_emp_id;
	l_task_execute_rec.organization_id := p_org_id;
	l_task_execute_rec.loaded_time := Sysdate;
	l_task_execute_rec.user_task_type := -1;
	-- END DBI FIX

	FOR i IN 1 .. l_mmtt_ids.COUNT LOOP
	   IF (l_debug = 1) THEN
	      DEBUG('Calling activate_operation_instance','load_lpn',1);
	      DEBUG(' ( p_source_task_id     => ' || l_mmtt_ids(i),'load_lpn',9);
	      DEBUG('   ,p_activity_type_id  => 1','load_lpn',9);
	      DEBUG('   ,p_task_execute_rec  => l_task_execute_rec','load_lpn',9);
	      DEBUG('   ,p_operation_type_id => 1 )','load_lpn',9);
	   END IF;

	   --Moving the following line before the loop starts to stamp the
	   --same time on all tasks for the given lpn - BEGIN DBI FIX
	   --l_task_execute_rec.person_id := l_emp_id;
	   --l_task_execute_rec.organization_id := p_org_id;
	   --l_task_execute_rec.loaded_time := Sysdate;
	   --l_task_execute_rec.user_task_type := -1;
	   --END DBI FIX

	   wms_atf_runtime_pub_apis.activate_operation_instance
	     (  p_source_task_id  => l_mmtt_ids(i)
		,p_activity_id => 1 -- Inbound
		,p_task_execute_rec => l_task_execute_rec
		,p_operation_type_id => 1 -- load
		,x_return_status     => x_return_status
		,x_msg_data          => x_msg_data
		,x_msg_count         => x_msg_count
		,x_error_code        => l_error_code
		,x_consolidation_method_id => l_consolidation_method_id
		,x_drop_lpn_option   => l_drop_lpn_option
		);
	   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	      IF (l_debug = 1) THEN
		 DEBUG('xxx: Error in activate_operation_instance','transfer_contents',9);
	      END IF;
	      RAISE fnd_api.g_exc_error;
	   END IF;
	END LOOP;

	--End of BUG FIX 3359835

	l_old_txn_mode_code := inv_rcv_common_apis.g_po_startup_value.transaction_mode;
	inv_rcv_common_apis.g_po_startup_value.transaction_mode :=  'ONLINE';

  l_progress := 100;

        BEGIN
     inv_rcv_mobile_process_txn.rcv_process_receive_txn
       (x_return_status    =>  x_return_status
        ,x_msg_data        =>  x_msg_data
        );
  EXCEPTION
     WHEN OTHERS THEN
        inv_rcv_common_apis.g_po_startup_value.transaction_mode := l_old_txn_mode_code;
        IF (l_debug = 1) THEN
     DEBUG('xxx: Error - Rcv TM Failed','load_lpn',9);
        END IF;
        RAISE fnd_api.g_exc_error;
  END;

  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
     IF (l_debug = 1) THEN
        DEBUG('xxx: Error - Rcv TM Failed','load_lpn',9);
     END IF;
     inv_rcv_common_apis.g_po_startup_value.transaction_mode := l_old_txn_mode_code;
     RAISE fnd_api.g_exc_error;
  END IF;

  l_progress := 150;

  inv_rcv_common_apis.g_po_startup_value.transaction_mode := l_old_txn_mode_code;
  inv_rcv_common_apis.rcv_clear_global;
     END IF;

     -- RCV TM would call complete_operation_instance
     IF (l_is_rcv_tm_call_needed <> TRUE) THEN
        BEGIN
     SELECT employee_id
       INTO l_emp_id
       FROM fnd_user
       WHERE user_id = p_user_id;
  EXCEPTION
     WHEN OTHERS THEN
        IF (l_debug = 1) THEN
     DEBUG('There is no employee id tied to the user','transfer_contents',9);
        END IF;
        fnd_message.set_name('WMS', 'WMS_NO_EMP_FOR_USR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
  END;
  debug('Calling complete_atf_load for:'||p_from_lpn_id);
  DEBUG(' p_org_id    => '||p_org_id,     'load_lpn',4);
  DEBUG(' p_emp_id    => '||l_emp_id,     'load_lpn',4);

  Complete_ATF_Load (x_return_status  => x_return_status
         ,x_msg_count      => x_msg_count
         ,x_msg_data       => x_msg_data
         ,p_org_id         => p_org_id
         ,p_lpn_id         => p_from_lpn_id
         ,p_emp_id         => l_emp_id );

  -- Check for the return status
  IF x_return_status = fnd_api.g_ret_sts_success THEN
     -- Activate completed successfully.
     NULL;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
     RAISE fnd_api.g_exc_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;
     END IF;

     -- Before returning commit all changes to datbase.
     COMMIT;

   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       debug(SQLCODE, 1);

       -- Get rid of the folloiwng, as it appends a junk message to the
       -- error message stack
--       IF SQLCODE IS NOT NULL THEN
--         l_progress := 100;
--         debug('Exception in load_lpn : ' || SQLCODE);
--         inv_mobile_helper_functions.sql_error('load_lpn', l_progress, SQLCODE);
--       END IF;
 END;


  PROCEDURE update_mo(
        MoLineId NUMBER,
        ReferenceId NUMBER,
        Reference VARCHAR2,
        Reference_type_code NUMBER,
        lpn_id NUMBER,
        wms_process_flag NUMBER,
        inspect_status NUMBER)
 IS
 BEGIN
    UPDATE mtl_txn_request_lines
      SET Reference_id        = decode(ReferenceId,-9999,referenceId,NULL,NULL,referenceId),
          Reference           = decode(Reference,'-9999',reference,NULL,NULL,reference),
          Reference_type_code = decode(Reference_type_code,'-9999',reference_type_code,NULL,NULL,reference_type_code),
          lpn_id              = decode(lpn_id,-9999,lpn_id,NULL,NULL,lpn_id),
          wms_process_flag    = decode(wms_process_flag,-9999,wms_process_flag,NULL,NULL,wms_process_flag),
          inspection_status   = decode(inspect_status,-9999,inspect_status,NULL,null,inspect_status)
    WHERE line_id  = MoLineid;
 END;


 FUNCTION insert_rti(p_from_org IN NUMBER
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
   RETURN NUMBER
   IS
      l_rowid VARCHAR2(40);
      l_interface_transaction_id NUMBER;
      l_group_id NUMBER;
      l_sysdate DATE := Sysdate;
      l_user_id NUMBER := fnd_global.user_id;
      l_login_id NUMBER := fnd_global.login_id;
      l_to_sub VARCHAR2(10);
      l_to_loc NUMBER;
      l_lpn_id NUMBER;
      l_xfer_lpn_id NUMBER;
      l_from_org NUMBER;
      l_to_org NUMBER;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_progress VARCHAR(3) := '0';
      l_txn_mode_code VARCHAR2(10);
      l_error_code NUMBER;

      l_operating_unit_id MO_GLOB_ORG_ACCESS_TMP.ORGANIZATION_ID%TYPE;   --<R12 MOAC>

 BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    l_to_sub := p_to_sub;
    l_to_loc  := p_to_loc;
    l_lpn_id  := p_lpn_id;
    l_xfer_lpn_id  := p_xfer_lpn_id;
    l_from_org := p_from_org;
    l_to_org := p_to_org;
    l_txn_mode_code := p_txn_mode_code;

    IF (l_debug = 1) THEN
       DEBUG('Entering...', 'insert_rti', 9);
       debug(' (p_to_sub => ' || p_to_sub, 'insert_rti', 9);
       debug('  p_from_org => ' || p_from_org, 'insert_rti', 9);
       debug('  p_to_org => ' || p_to_org, 'insert_rti', 9);
       debug('  p_to_loc => ' || p_to_loc, 'insert_rti', 9);
       debug('  p_lpn_id => ' || p_lpn_id, 'insert_rti', 9);
       debug('  p_xfer_lpn_id   => ' || p_xfer_lpn_id, 'insert_rti', 9);
       debug('  p_first_time    => ' || p_first_time, 'insert_rti', 9);
       debug('  p_mobile_txn    => ' || p_mobile_txn, 'insert_rti', 9);
       debug('  p_txn_mode_code => ' || p_txn_mode_code||')', 'insert_rti', 9);
    END IF;

    IF (p_first_time = 1) THEN
       IF (l_debug = 1) THEN
    debug('Calling init_startup_values','insert_rti',9);
    debug('  p_org_id => '||l_from_org, 'insert_rti',9);
       END IF;

       BEGIN
    inv_rcv_common_apis.init_startup_values(l_from_org);
       EXCEPTION
    WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('INV', 'INV_RCV_PARAM');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
       END;

       l_progress := '2';

       IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN
	  --BUG 3435079: For performance reason, do not go against the view
	  --org_organization_definitions.  instead, use
	  --the query below
	  SELECT TO_NUMBER(hoi.org_information1)
	    INTO  inv_rcv_common_apis.g_po_startup_value.sob_id
	    FROM hr_organization_information hoi
	    WHERE hoi.organization_id = l_from_org
	    AND (hoi.org_information_context || '') = 'Accounting Information';

       END IF;

       l_progress := '4';

       IF (l_debug = 1) THEN
	  debug('init_startup_value exited.  Calling validate_trx_date'
		,'insert_rti', 9);
       END IF;

       inv_rcv_common_apis.validate_trx_date
	 (
	  p_trx_date              => SYSDATE
	  , p_organization_id     => l_from_org
	  , p_sob_id              => inv_rcv_common_apis.g_po_startup_value.sob_id
	  , x_return_status       => x_return_status
	  , x_error_code          => l_error_code
	  );

       IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
    IF (l_debug = 1)THEN
       debug('Date validation failed','insert_rti',9);
    END IF;
    RAISE fnd_api.g_exc_error;
       END IF;

       l_progress := '6';

    END IF; --IF (p_first_time = 1)

    SELECT rcv_transactions_interface_s.NEXTVAL
      INTO l_interface_transaction_id
      FROM dual;

    -- init_start_values should have called gen_txn_group_id
    l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;

    IF (l_debug = 1) THEN
       DEBUG('Calling rcv_trx_interface_insert_pkg.insert_row',
             'insert_rti', 9);
    END IF;

    SELECT org_information2
      INTO l_operating_unit_id
      FROM hr_organization_information
      WHERE organization_id = l_to_org
      AND org_information_context || '' ='Accounting Information';    --<R12 MOAC>

    l_progress := '10';

    rcv_trx_interface_insert_pkg.insert_row
      (
       x_rowid                      =>  l_rowid
       ,x_interface_transaction_id  =>  l_interface_transaction_id
       ,x_group_id                  =>  l_group_id
       ,x_last_update_date          =>  l_sysdate
       ,x_last_updated_by           =>  l_user_id
       ,x_creation_date             =>  l_sysdate
       ,x_created_by                =>  l_user_id
       ,x_last_update_login         =>  l_login_id
       ,x_transaction_type          =>  'TRANSFER'
       ,x_transaction_date          =>  l_sysdate
       ,x_processing_status_code    =>  'PENDING'
       ,x_processing_mode_code      =>  l_txn_mode_code
       ,x_processing_request_id     =>  NULL
       ,x_transaction_status_code   =>  'PENDING'
       ,x_category_id               =>  NULL
       ,x_quantity                  =>  0
       ,x_unit_of_measure           =>  'X'
       ,x_interface_source_code     =>  'RCV'
       ,x_interface_source_line_id  =>  NULL
       ,x_inv_transaction_id        =>  NULL
       ,x_item_id                   =>  NULL
      ,x_item_description          =>  NULL
      ,x_item_revision             =>  NULL
      ,x_uom_code                  =>  NULL
      ,x_employee_id               =>  l_user_id
      ,x_auto_transact_code        =>  NULL
      ,x_shipment_header_id        =>  NULL
      ,x_shipment_line_id          =>  NULL
      ,x_ship_to_location_id       =>  NULL
      ,x_primary_quantity          =>  NULL
      ,x_primary_unit_of_measure   =>  NULL
      ,x_receipt_source_code       =>  NULL
      ,x_vendor_id                 =>  NULL
      ,x_vendor_site_id            =>  NULL
      ,x_from_organization_id      =>  l_from_org
      ,x_to_organization_id        =>  l_to_org
      ,x_routing_header_id         =>  NULL
      ,x_routing_step_id           =>  NULL
      ,x_source_document_code      =>  NULL
      ,x_parent_transaction_id     =>  NULL
      ,x_po_header_id              =>  NULL
      ,x_po_revision_num           =>  NULL
      ,x_po_release_id             =>  NULL
      ,x_po_line_id                =>  NULL
      ,x_po_line_location_id       =>  NULL
      ,x_po_unit_price             =>  NULL
      ,x_currency_code             =>  NULL
      ,x_currency_conversion_type  =>  NULL
      ,x_currency_conversion_rate  =>  NULL
      ,x_currency_conversion_date  =>  NULL
      ,x_po_distribution_id        =>  NULL
      ,x_requisition_line_id       =>  NULL
      ,x_req_distribution_id       =>  NULL
      ,x_charge_account_id         =>  NULL
      ,x_substitute_unordered_code =>  NULL
      ,x_receipt_exception_flag    =>  NULL
      ,x_accrual_status_code       =>  NULL
      ,x_inspection_status_code    =>  NULL
      ,x_inspection_quality_code   =>  NULL
      ,x_destination_type_code     =>  'RECEIVING'
      ,x_deliver_to_person_id      =>  NULL
      ,x_location_id               =>  NULL
      ,x_deliver_to_location_id    =>  NULL
      ,x_subinventory              =>  l_to_sub
      ,x_locator_id                =>  l_to_loc
      ,x_wip_entity_id             =>  NULL
      ,x_wip_line_id               =>  NULL
      ,x_department_code           =>  NULL
      ,x_wip_repetitive_schedule_id=>  NULL
      ,x_wip_operation_seq_num     =>  NULL
      ,x_wip_resource_seq_num      =>  NULL
      ,x_bom_resource_id           =>  NULL
      ,x_shipment_num              =>  NULL
      ,x_freight_carrier_code      =>  NULL
      ,x_bill_of_lading            =>  NULL
      ,x_packing_slip              =>  NULL
      ,x_shipped_date              =>  NULL
      ,x_expected_receipt_date     =>  NULL
      ,x_actual_cost               =>  NULL
      ,x_transfer_cost             =>  NULL
      ,x_transportation_cost       =>  NULL
      ,x_transportation_account_id =>  NULL
      ,x_num_of_containers         =>  NULL
      ,x_waybill_airbill_num       =>  NULL
      ,x_vendor_item_num           =>  NULL
      ,x_vendor_lot_num            =>  NULL
      ,x_rma_reference             =>  NULL
      ,x_comments                  =>  NULL
      ,x_attribute_category        =>  NULL
      ,x_attribute1                =>  NULL
      ,x_attribute2                =>  NULL
      ,x_attribute3                =>  NULL
      ,x_attribute4                =>  NULL
      ,x_attribute5                =>  NULL
      ,x_attribute6                =>  NULL
      ,x_attribute7                =>  NULL
      ,x_attribute8                =>  NULL
      ,x_attribute9                =>  NULL
      ,x_attribute10               =>  NULL
      ,x_attribute11               =>  NULL
      ,x_attribute12               =>  NULL
      ,x_attribute13               =>  NULL
      ,x_attribute14               =>  NULL
      ,x_attribute15               =>  NULL
      ,x_ship_head_attribute_category =>  NULL
      ,x_ship_head_attribute1      =>  NULL
      ,x_ship_head_attribute2      =>  NULL
      ,x_ship_head_attribute3      =>  NULL
      ,x_ship_head_attribute4      =>  NULL
      ,x_ship_head_attribute5      =>  NULL
      ,x_ship_head_attribute6      =>  NULL
      ,x_ship_head_attribute7      =>  NULL
      ,x_ship_head_attribute8      =>  NULL
      ,x_ship_head_attribute9      =>  NULL
      ,x_ship_head_attribute10     =>  NULL
      ,x_ship_head_attribute11     =>  NULL
      ,x_ship_head_attribute12     =>  NULL
      ,x_ship_head_attribute13     =>  NULL
      ,x_ship_head_attribute14     =>  NULL
      ,x_ship_head_attribute15     =>  NULL
      ,x_ship_line_attribute_category =>  NULL
      ,x_ship_line_attribute1      =>  NULL
      ,x_ship_line_attribute2      =>  NULL
      ,x_ship_line_attribute3      =>  NULL
      ,x_ship_line_attribute4      =>  NULL
      ,x_ship_line_attribute5      =>  NULL
      ,x_ship_line_attribute6      =>  NULL
      ,x_ship_line_attribute7      =>  NULL
      ,x_ship_line_attribute8      =>  NULL
      ,x_ship_line_attribute9      =>  NULL
      ,x_ship_line_attribute10     =>  NULL
      ,x_ship_line_attribute11     =>  NULL
      ,x_ship_line_attribute12     =>  NULL
      ,x_ship_line_attribute13     =>  NULL
      ,x_ship_line_attribute14     =>  NULL
      ,x_ship_line_attribute15     =>  NULL
      ,x_ussgl_transaction_code    =>  NULL
      ,x_government_context        =>  NULL
      ,x_reason_id                 =>  NULL
      ,x_destination_context       =>  NULL
      ,x_source_doc_quantity       =>  NULL
      ,x_source_doc_unit_of_measure=>  NULL
      ,x_lot_number_cc             =>  NULL
      ,x_serial_number_cc          =>  NULL
      ,x_qa_collection_id          =>  NULL
      ,x_country_of_origin_code    =>  NULL
      ,x_oe_order_header_id        =>  NULL
      ,x_oe_order_line_id          =>  NULL
      ,x_customer_item_num         =>  NULL
      ,x_customer_id               =>  NULL
      ,x_customer_site_id          =>  NULL
      ,x_put_away_rule_id          =>  NULL
      ,x_put_away_strategy_id      =>  NULL
      ,x_lpn_id                    =>  l_lpn_id
      ,x_transfer_lpn_id           =>  l_xfer_lpn_id
      ,x_cost_group_id             =>  NULL
      ,x_mmtt_temp_id              =>  NULL
      ,x_mobile_txn                =>  p_mobile_txn
      ,x_transfer_cost_group_id    =>  NULL
      ,x_secondary_quantity        =>  NULL
      ,x_secondary_unit_of_measure =>  NULL
      ,p_org_id                    =>  l_operating_unit_id   --<R12 MOAC>
      );

    UPDATE
      rcv_transactions_interface
    SET
      validation_flag = 'Y'
      ,lpn_group_id = l_group_id
      WHERE ROWID = l_rowid;

    l_progress := '20';

    IF (l_debug = 1) THEN
       DEBUG('Quiting with group_id = '||l_group_id, 'insert_rti', 9);
    END IF;

    RETURN l_group_id;
 EXCEPTION
    WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_error;
       IF (l_debug = 1) THEN
          debug('Error after progress = ' || l_progress,
                'insert_rti',
                9);
       END IF;
       IF SQLCODE IS NOT NULL THEN
          IF (l_debug = 1) THEN
             debug(SQLCODE, 'insert_rti', 9);
          END IF;
       END IF;
       RETURN -1;
 END insert_rti;


 PROCEDURE pre_process_lpn (
    x_return_status           OUT  NOCOPY VARCHAR2
  , x_msg_count               OUT  NOCOPY NUMBER
  , x_msg_data                OUT  NOCOPY VARCHAR2
  , p_from_lpn_id             IN  NUMBER
  , p_organization_id         IN NUMBER
  , p_subinventory_code       IN VARCHAR2
  , p_lpn_mode                IN NUMBER
  , p_locator_id              IN NUMBER
  , p_to_lpn_id               IN NUMBER
  , p_project_id              IN NUMBER   DEFAULT NULL
  , p_task_id                 IN NUMBER   DEFAULT NULL
  , p_user_id                 IN NUMBER
  , p_lpn_context             IN NUMBER
  , p_batch_id                IN NUMBER
  , p_batch_seq               IN NUMBER
  , p_pack_trans_id           IN NUMBER
  , x_batch_seq               OUT NOCOPY NUMBER --BUG 3544918
) IS
   l_debug             NUMBER   := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_group_id          NUMBER;
   l_progress          NUMBER;
   l_ret               NUMBER;
   l_lpn_id            NUMBER;
   p_parent_lpn_id     NUMBER;
   l_lpn_sub           mtl_secondary_inventories.secondary_inventory_name%TYPE;
   l_lpn_loc           NUMBER;
   l_to_lpn_id         NUMBER;


   CURSOR lpn_cursor IS
   SELECT lpn_id
     FROM wms_license_plate_numbers
     WHERE parent_lpn_id = p_from_lpn_id;

   l_batch_seq NUMBER := p_batch_seq;

 BEGIN

   l_progress := 10;

   x_return_status := fnd_api.g_ret_sts_success;

   IF (l_debug = 1) THEN
     debug('Pre_Process_lpn : Patchset J code - Nested LPNs are supported');
     debug(' p_from_lpn_id: '||p_from_lpn_id);
     debug(' p_to_lpn_id: '||p_to_lpn_id);
   END IF;

   BEGIN
      -- Get Parent lpn id
      SELECT parent_lpn_id
	,subinventory_code
	,locator_id
	INTO p_parent_lpn_id
	,l_lpn_sub
	,l_lpn_loc
	FROM wms_license_plate_numbers
	WHERE lpn_id = p_from_lpn_id;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    debug('Error retrieving parent_lpn_id');
	    debug('SQLCODE:'||SQLCODE||' SQLERRM'||Sqlerrm,9);
	 END IF;
   END;

   -- Get LPN group Id
   IF p_lpn_context = 3 THEN
     IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL   THEN
       SELECT rcv_interface_groups_s.NEXTVAL
       INTO   l_group_id
       FROM   DUAL;
       inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
     ELSE
       l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
     END IF;
   END IF;

   -- Drop Entire LPN,
   IF p_lpn_mode = 2 THEN

     -- Process Resides in inventory LPN
     IF p_lpn_context = 1 AND p_parent_lpn_id IS NOT NULL THEN

       IF(l_debug =1) THEN
         debug('Inventory LPN, Parent lpn is not null, Unpack '||p_from_lpn_id|| ' from ' ||p_parent_lpn_id);
       END IF;

       -- Unpack the given LPN from its parent.
       PackUnpack_LPN(
               p_from_lpn_id   => p_parent_lpn_id
             , p_to_lpn_id     => p_from_lpn_id
             , p_org_id        => p_organization_id
             , p_sub_code      => l_lpn_sub
             , p_loc_id        => l_lpn_loc
             , p_user_id       => p_user_id
             , p_project_id    => p_project_id
             , p_task_id       => p_task_id
             , p_trx_header_id => p_pack_trans_id
             , p_mode          => 2 -- unpack
             , p_batch_id      => p_batch_id
             , p_batch_seq     => l_batch_seq
             , x_return_status => x_return_status
             , x_msg_count     => x_msg_count
             , x_msg_data      => x_msg_data);

       -- Check return value and in case of failure raise exception
       IF (l_ret <> 0)  THEN
         IF l_debug = 1 THEN
           debug('TM call for pack unpack faluire');
           debug('Failure message ' || x_msg_data);
         END IF;
         FND_MESSAGE.SET_NAME('WMS','WMS_LOG_EXCEPTION_FAIL');
         RAISE FND_API.G_EXC_ERROR;
       END IF;

       l_batch_seq := l_batch_seq + 1;
     END IF;

     -- Process Resides in Wip LPN
     IF p_lpn_context=2 AND  p_parent_lpn_id  IS NOT NULL THEN

       IF(l_debug = 1) THEN
          debug('Resides in WIP LPN, Parent lpn is not null, Unpack '||p_from_lpn_id||' from ' ||p_parent_lpn_id);
       END IF;

       -- unpack from LPN from its parent.
       wms_container_pvt.packunpack_container
         (p_api_version       =>   1.0
         ,p_content_lpn_id   =>   p_from_lpn_id
         ,p_lpn_id           =>   p_parent_lpn_id
         ,p_operation        =>   2 -- Unpack
         ,p_organization_id  =>   p_organization_id
         ,p_commit           =>   fnd_api.g_false
         ,x_return_status    =>   x_return_status
         ,x_msg_count        =>   x_msg_count
         ,x_msg_data         =>   x_msg_data);

     END IF;

     -- Process Resides in receiving LPN
     IF p_lpn_context = 3 THEN

         IF p_from_lpn_id = p_to_lpn_id  THEN
           l_to_lpn_id := NULL;
         ELSE
           l_to_lpn_id := p_to_lpn_id;
         END IF;

         inv_rcv_integration_apis.insert_wlpni(
           p_api_version           => 1.0
          ,x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data
          ,p_organization_id       => p_organization_id
          ,p_lpn_id                => p_from_lpn_id
          ,p_license_plate_number  => NULL
          ,p_lpn_group_id          => l_group_id
          ,p_parent_lpn_id         => l_to_lpn_id);

      END IF;
   END IF;

   -- If p_lpn_mode is transfer all contents then do the following.
   IF p_lpn_mode = 1  THEN

       OPEN lpn_cursor;
       LOOP
         FETCH lpn_cursor INTO l_lpn_id;
         EXIT WHEN lpn_cursor%NOTFOUND;

         --UnPack child LPNs from the ginve LPN Resides in inventory
         IF p_lpn_context = 1  THEN

             IF(l_debug =1) THEN
               debug('Inventory LPN, Parent lpn is not null, Unpack '||l_lpn_id|| ' from ' ||p_from_lpn_id);
             END IF;

             PackUnpack_LPN(
                     p_from_lpn_id   => p_from_lpn_id
                   , p_to_lpn_id     => l_lpn_id --BUG 3544918
                   , p_org_id        => p_organization_id
                   , p_sub_code      => l_lpn_sub
                   , p_loc_id        => l_lpn_loc
                   , p_user_id       => p_user_id
                   , p_project_id    => p_project_id
                   , p_task_id       => p_task_id
                   , p_trx_header_id => p_pack_trans_id
                   , p_mode          => 2
	           , p_batch_id      => p_batch_id
	           , p_batch_seq     => l_batch_seq
                   , x_return_status => x_return_status
                   , x_msg_count     => x_msg_count
                   , x_msg_data      => x_msg_data);

             -- Check return value and in case of failure raise exception
             IF (l_ret <> 0)  THEN
               IF l_debug = 1 THEN
                 debug('TM call for pack unpack faluire');
                 debug('Failure message ' || x_msg_data);
               END IF;
               FND_MESSAGE.SET_NAME('WMS','WMS_LOG_EXCEPTION_FAIL');
               RAISE FND_API.G_EXC_ERROR;
             END IF; -- if l_ret<> 0

	     l_batch_seq := l_batch_seq + 1;

         -- If the lpn context is resides in WIP and transaction mode is transfer all
         -- contents, then unpack each child LPN lpn from its parent
         ELSIF p_lpn_context = 2 THEN

                IF(l_debug = 1) THEN
                   debug('WIP  LPN, Parent lpn is not null, Unpack '||l_lpn_id||' from ' ||p_from_lpn_id);
                END IF;

                wms_container_pvt.packunpack_container
                  (p_api_version       =>   1.0
                  ,p_content_lpn_id   =>   l_lpn_id      -- child LPN ID
                  ,p_lpn_id           =>   p_from_lpn_id -- Parent LPN ID
                  ,p_operation        =>   2 -- Unpack
                  ,p_organization_id  =>   p_organization_id
                  ,p_commit           =>   fnd_api.g_false
                  ,x_return_status    =>   x_return_status
                  ,x_msg_count        =>   x_msg_count
                  ,x_msg_data         =>   x_msg_data);

         ELSIF p_lpn_context = 3 THEN

                  -- Resides in Receving LPN, Unpack all child LPNs from their parents.
                  inv_rcv_integration_apis.insert_wlpni(
                    p_api_version           => 1.0
                   ,x_return_status         => x_return_status
                   ,x_msg_count             => x_msg_count
                   ,x_msg_data              => x_msg_data
                   ,p_organization_id       => p_organization_id
                   ,p_lpn_id                => l_lpn_id
                   ,p_license_plate_number  => NULL
                   ,p_lpn_group_id          => l_group_id
                   ,p_parent_lpn_id         => p_to_lpn_id);
         END IF;     -- If lpn context =1
       END LOOP;

       IF lpn_cursor%isopen THEN
         CLOSE lpn_cursor;
       END IF;

       x_batch_seq := l_batch_seq;
   END IF;


 EXCEPTION

   WHEN OTHERS THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     debug(SQLCODE, 1);

     IF lpn_cursor%isopen THEN
       CLOSE lpn_cursor;
     END IF;

     IF SQLCODE IS NOT NULL THEN
       l_progress := 100;
       inv_mobile_helper_functions.sql_error('pre_process_lpn', l_progress, SQLCODE);
     END IF;

 END pre_process_lpn;

 PROCEDURE post_process_lpn (
    x_return_status           OUT  NOCOPY VARCHAR2
  , x_msg_count               OUT  NOCOPY NUMBER
  , x_msg_data                OUT  NOCOPY VARCHAR2
  , p_from_lpn_id             IN NUMBER
  , p_organization_id         IN NUMBER
  , p_subinventory_code       IN VARCHAR2
  , p_lpn_mode                IN VARCHAR2
  , p_locator_id              IN NUMBER
  , p_to_lpn_id               IN NUMBER
  , p_project_id              IN NUMBER   DEFAULT NULL
  , p_task_id                 IN NUMBER   DEFAULT NULL
  , p_user_id                 IN NUMBER
  , p_lpn_context             IN NUMBER
  , p_pack_trans_id           IN NUMBER
  , p_batch_id                IN NUMBER
  , p_batch_seq               IN NUMBER
 ) IS
   l_debug             NUMBER   := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_group_id          NUMBER;
   l_progress          NUMBER;
   l_ret               NUMBER;
   l_lpn_id            NUMBER;

   CURSOR lpn_cursor IS
   SELECT lpn_id
     FROM wms_license_plate_numbers
    WHERE parent_lpn_id = p_from_lpn_id;

   l_batch_seq NUMBER := p_batch_seq; --BUG 3544918
 BEGIN

   l_progress := 10;

   x_return_status := fnd_api.g_ret_sts_success;

   IF (l_debug = 1) THEN
     debug('Post_Process_lpn : Patchset J code - Nested LPNs are supported');
   END IF;


   -- Drop entire LPN
   IF(p_lpn_mode = 2 ) THEN

     IF  (p_lpn_context = 1  OR p_lpn_context = 2) AND (p_to_lpn_id IS NOT NULL) AND
         (p_to_lpn_id <> p_from_lpn_id) AND (p_to_lpn_id <> 0) THEN

       IF (l_debug = 1) THEN
         debug('Inventory/WP LPN, To lpn is not null, Pack  '||p_from_lpn_id|| ' Into  ' ||p_to_lpn_id);
       END IF;

       PackUnpack_LPN(
               p_from_lpn_id   => p_from_lpn_id
             , p_to_lpn_id     => p_to_lpn_id
             , p_org_id        => p_organization_id
             , p_sub_code      => p_subinventory_code
             , p_loc_id        => p_locator_id
             , p_user_id       => p_user_id
             , p_project_id    => p_project_id
             , p_task_id       => p_task_id
             , p_trx_header_id => p_pack_trans_id
             , p_mode          => 1 -- Pack
             , p_batch_id      => p_batch_id
             , p_batch_seq     => l_batch_seq
             , x_return_status => x_return_status
             , x_msg_count     => x_msg_count
             , x_msg_data      => x_msg_data);

     END IF;
   END IF;

   -- Transfer All contents
   IF p_lpn_mode = 1  THEN

     OPEN lpn_cursor;
     LOOP
       FETCH lpn_cursor INTO l_lpn_id;
       EXIT WHEN lpn_cursor%NOTFOUND;

       IF  (p_lpn_context = 1  OR p_lpn_context = 2) AND (p_to_lpn_id IS NOT NULL) AND
           (p_to_lpn_id <> p_from_lpn_id) AND (p_to_lpn_id <> 0) THEN

         IF (l_debug = 1) THEN
           debug('Inventory/WP LPN, To lpn is not null, Pack  '||l_lpn_id || ' Into  ' ||p_to_lpn_id);
         END IF;

         PackUnpack_LPN(
                 p_from_lpn_id   => l_lpn_id
               , p_to_lpn_id     => p_to_lpn_id
               , p_org_id        => p_organization_id
               , p_sub_code      => p_subinventory_code
               , p_loc_id        => p_locator_id
               , p_user_id       => p_user_id
               , p_project_id    => p_project_id
               , p_task_id       => p_task_id
               , p_trx_header_id => p_pack_trans_id
               , p_mode          => 1 -- Pack
               , p_batch_id      => p_batch_id
               , p_batch_seq     => l_batch_seq
               , x_return_status => x_return_status
               , x_msg_count     => x_msg_count
               , x_msg_data      => x_msg_data);
	 l_batch_seq := l_batch_seq + 1;
       END IF;
     END LOOP;

   END IF;

   IF lpn_cursor%isopen THEN
     CLOSE lpn_cursor;
   END IF;


 EXCEPTION

   WHEN OTHERS THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     debug(SQLCODE, 1);

     IF lpn_cursor%isopen THEN
       CLOSE lpn_cursor;
     END IF;

     IF SQLCODE IS NOT NULL THEN
       l_progress := 100;
       inv_mobile_helper_functions.sql_error('post_process_lpn', l_progress, SQLCODE);
     END IF;

 END post_process_lpn;

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
    , x_msg_data       OUT NOCOPY     VARCHAR2 )
   IS
      TYPE number_tb_tp IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE varchar30_tb_tp IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
      l_from_context NUMBER;
      l_into_context NUMBER;
      l_is_loaded  VARCHAR2(1);
      l_number_of_rows NUMBER;
      l_crossdock  VARCHAR2(1); --??
      l_count NUMBER;
      l_org_id NUMBER;
      l_lpn_ids number_tb_tp;
      l_serial_numbers varchar30_tb_tp;
      l_txn_tmp_id_tb number_tb_tp;
      l_txn_tmp_id NUMBER;
      l_hdr_id NUMBER;
      l_sub_code VARCHAR2(10);
      l_loc_id NUMBER;
      l_to_sub VARCHAR2(10);
      l_to_loc NUMBER;
      l_ser_trx_id NUMBER;
      l_return_status NUMBER;
      l_task_execute_rec wms_dispatched_tasks%ROWTYPE;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_progress VARCHAR2(10) := '0';
      l_user_id NUMBER;
      l_emp_id NUMBER;
      l_error_code NUMBER;
      l_message VARCHAR2(1);
      l_prim_qty NUMBER;
      l_loose_contents NUMBER := 0;
      l_old_txn_mode_code VARCHAR2(10);
      l_inspection_flag NUMBER;
      l_load_flag  NUMBER;
      l_drop_flag NUMBER;
      l_load_prim_quantity NUMBER;
      l_inspect_prim_quantity NUMBER;
      l_drop_prim_quantity NUMBER;
      l_sub_loc_changed VARCHAR2(1);
      l_batch_seq NUMBER := 1;
      l_uom VARCHAR2(5);

      l_consolidation_method_id NUMBER;
      l_drop_lpn_option NUMBER;

      CURSOR wlpnc_cur IS
         SELECT
           wlpnc.inventory_item_id
           ,wlpnc.organization_id
           ,wlpnc.revision
           ,wlpnc.lot_number
           ,wlpnc.quantity
           ,wlpnc.uom_code
           ,msi.serial_number_control_code
     ,msi.primary_uom_code
           FROM
           wms_lpn_contents wlpnc, mtl_system_items msi
           WHERE
           wlpnc.parent_lpn_id = p_from_lpn_id
           AND wlpnc.inventory_item_id = msi.inventory_item_id
     AND wlpnc.organization_id = msi.organization_id;

      l_msg_count                 NUMBER;
      l_msg_data                  VARCHAR2(10000);

 BEGIN
    IF (l_debug = 0) THEN
       DEBUG('Entering transfer_contents.pls', 'transfer_contents', 9);
       DEBUG('  ( p_from_lpn_id => ' || p_from_lpn_id,'transfer_contents',9);
       DEBUG('    ,p_into_lpn_id=> ' || p_into_lpn_id,'transfer_contents',9);
       DEBUG('    ,p_org_id     => ' || p_org_id,'transfer_contents',9);
       DEBUG('    ,p_operation  => ' || p_operation,'transfer_contents',9);
       DEBUG('    ,p_mode       => ' || p_mode,'transfer_contents',9);
       DEBUG('    ,p_user_id    => ' || p_user_id,'transfer_contents',9);
       DEBUG('    ,p_eqp_ins    => ' || p_eqp_ins || ')','transfer_contents',9);
    END IF;
    -- ignore operation/mode.
    -- assume 'XFER_CONTENTS' and 'LOAD' for now

    SAVEPOINT transfer_contents_pub;

    l_progress := '3';

    IF (p_user_id IS NULL) THEN
       l_user_id := fnd_global.user_id;
     ELSE
       l_user_id := p_user_id;
    END IF;

    l_progress := '5';
    BEGIN
       SELECT employee_id
         INTO l_emp_id
         FROM fnd_user
         WHERE user_id = l_user_id;
    EXCEPTION
       WHEN OTHERS THEN
          IF (l_debug = 1) THEN
             DEBUG('There is no employee id tied to the user','transfer_contents',9);
          END IF;
    fnd_message.set_name('WMS', 'WMS_NO_EMP_FOR_USR');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
   END;

   l_progress := '7';

   BEGIN
      SELECT
        lpn_context from_context
        ,organization_id organization_id
        ,subinventory_code
        ,locator_id
        INTO
        l_from_context
        ,l_org_id
        ,l_sub_code
        ,l_loc_id
        FROM
        wms_license_plate_numbers
        WHERE
        lpn_id = p_from_lpn_id;
   EXCEPTION
      WHEN OTHERS THEN
         IF (l_debug = 1) THEN
            DEBUG('from LPN not found in WMS_LICENSE_PLATE_NUMBERS',
                  'transfer_contents',9);
         END IF;
   fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
   fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
   END;

   l_progress := '9';

   BEGIN
      SELECT
        lpn_context
  ,subinventory_code
  ,locator_id
        INTO
        l_into_context
  ,l_to_sub
  ,l_to_loc
        FROM
        wms_license_plate_numbers
        WHERE
        lpn_id = p_into_lpn_id;
   EXCEPTION
      WHEN OTHERS THEN
         IF (l_debug = 1) THEN
            DEBUG('INTO LPN not found in WMS_LICENSE_PLATE_NUMBERS',
                  'transfer_contents',9);
         END IF;
   fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
   fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
   END;

   -- Set variable if sub/loc of toLPN is different from that of from LPN
   IF (Nvl(p_into_lpn_id,0) <> 0
       AND l_into_context IN (1,2,3)  -- No need to call TM if DFBU LPN
       AND (Nvl(l_to_sub,'@@@') <> Nvl(p_sub_code,'@@@')
      OR Nvl(l_to_loc,-1) <> Nvl(p_loc_id,-1))) THEN
      l_sub_loc_changed := 'Y';
    ELSE
      l_sub_loc_changed := 'N';
   END IF;

   l_progress := '10';
   IF (l_debug = 1) THEN
      DEBUG('from_content = ' || l_from_context ||
      ' into_context = ' || l_into_context ||
      ' from_sub_code = ' || l_sub_code ||
            ' from_loc_id = ' || l_loc_id
      || ' l_to_sub = '||l_to_sub ||
      ' l_to_loc = ' || l_to_loc ||
      ' l_sub_loc_changed = ' || l_sub_loc_changed
            ,'transfer_contents', 9);
   END IF;

   -- From LPN must be either in receiving, inventory, or WIP
   IF (l_from_context NOT IN (1, 2, 3)) THEN
      IF (l_debug = 1) THEN
         DEBUG('Invalid context for from_lpn_id',
               'transfer_contents', 9);
      END IF;
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN_CONTEXT');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   l_progress := '30';

   IF (l_debug = 1) THEN
      DEBUG('Calling suggestions_pub_wrapper','transfer_contents',9);
      DEBUG('  (p_lpn_id   => ' || p_from_lpn_id,'transfer_contents',9);
      DEBUG('   ,p_org_id  => ' || l_org_id,'transfer_contents',9);
      DEBUG('   ,p_user_id => ' || l_user_id,'transfer_contents',9);
      DEBUG('   ,p_eqp_ins => ' || p_eqp_ins || ')','transfer_contents',9);
   END IF;

   wms_putaway_utils.suggestions_pub_wrapper
     (p_lpn_id    =>   p_from_lpn_id
      ,p_org_id   =>   l_org_id
      ,p_user_id  =>   l_user_id
      ,p_eqp_ins  =>   p_eqp_ins
      ,x_number_of_rows => l_number_of_rows
      ,x_return_status =>  x_return_status
      ,x_msg_count     =>  x_msg_count
      ,x_msg_data      =>  x_msg_data
      ,x_crossdock     =>  l_crossdock
      );

   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
         DEBUG('Error in suggestions_pub_wrapper','transfer_contents',9);
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   l_progress := '40';

   IF (l_debug = 1) THEN
      DEBUG('Suggestions_pub_wrapper returns sucessfully','transfer_contents',9);
   END IF;


   --BUG 4345714: Change the way quantities is validated from 11.5.10
   BEGIN
      SELECT /*+ ORDERED INDEX(MTRL MTL_TXN_REQUEST_LINES_N7) */ 1
	INTO l_count
	FROM mtl_txn_request_lines mtrl ,
	    (SELECT wlpn.lpn_id                /*5723418*/
	      FROM wms_license_plate_numbers wlpn
	      START WITH  wlpn.lpn_id = p_from_lpn_id
	      CONNECT BY PRIOR wlpn.lpn_id = wlpn.parent_lpn_id ) wlpn
	WHERE mtrl.lpn_id = wlpn.lpn_id
	AND mtrl.line_status = 7
	AND (mtrl.quantity-Nvl(mtrl.quantity_delivered,0)) <> Nvl(mtrl.quantity_detailed,0)
	AND mtrl.organization_id = l_org_id;
   EXCEPTION
      WHEN too_many_rows THEN
	 l_count := 1;
      WHEN no_data_found THEN
	 l_count := 0;
      WHEN OTHERS THEN
	 l_count := 0;
   END;


   l_progress := '50';

   IF (l_count > 0) THEN
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data =>
				l_msg_data);
      IF l_debug = 1 THEN
	 debug('l_msg_count: ' || l_msg_count);
	 debug('l_msg_data: ' || l_msg_data);
      END IF;

      IF (l_msg_count IS NULL OR l_msg_count = 0) THEN
	 -- use default message if there are no message on stack
	 -- first reset message stack
	 fnd_msg_pub.initialize();
	 FND_MESSAGE.SET_NAME('WMS','WMS_ALLOCATE_FAIL');
	 FND_MSG_PUB.ADD;
       ELSIF l_msg_count > 1 THEN
	 FOR i IN 2 .. l_msg_count LOOP
	    fnd_msg_pub.delete_msg(i);
	 END LOOP;
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   l_progress := '60';

   -- Retrieve all the suggestion MMTT
   IF (l_from_context = 3) THEN
      -- Retrieve all the suggestion MMTT
      -- Distinguish from other dummy ones
      BEGIN
      -- Bug 5231114: Added the condition on transaction_source_type_id and
      -- transaction_action_id for the following combinations:13/12 and 4/27
         SELECT
           mmtt.transaction_temp_id
      BULK COLLECT INTO
           l_txn_tmp_id_tb
         FROM mtl_material_transactions_temp mmtt
         WHERE -- suggestion mmtts?
           ( ( mmtt.transaction_source_type_id = 1 AND
               mmtt.transaction_action_id = 27) OR
             ( mmtt.transaction_source_type_id = 7 AND
               mmtt.transaction_action_id = 12) OR
             ( mmtt.transaction_source_type_id = 12 AND
               mmtt.transaction_action_id = 27) OR
             ( mmtt.transaction_source_type_id = 13 AND
               mmtt.transaction_action_id = 12) OR
	     ( mmtt.transaction_source_type_id = 4 AND
               mmtt.transaction_action_id = 27)) AND
	   mmtt.organization_id = l_org_id AND
           mmtt.move_order_line_id --BUG 3435079: use org_id for performace reason
           IN ( SELECT mtrl.line_id
                FROM   mtl_txn_request_lines mtrl,
                     ( SELECT wlpn.lpn_id     /*5723418*/
                        FROM wms_license_plate_numbers wlpn
                        START WITH wlpn.lpn_id = p_from_lpn_id
                        CONNECT BY PRIOR wlpn.lpn_id = wlpn.parent_lpn_id ) wlpn
                WHERE  mtrl.organization_id = l_org_id
		 --BUG 3435079: use org_id for performace reason
		 AND mtrl.lpn_id = wlpn.lpn_id );

      EXCEPTION
         WHEN OTHERS THEN
            IF (l_debug = 1 ) THEN
               DEBUG('Unexpected Exception Raised in Bulk Select'
                     ,'transfer_contents', 9);
            END IF;
            RAISE fnd_api.g_exc_error;
      END;

      IF (l_debug = 1) THEN
	 debug('# of MMTT returned: '||l_txn_tmp_id_tb.COUNT,'transfer_contents',9);
      END IF;

      IF (l_txn_tmp_id_tb.COUNT = 0) THEN
	 IF (l_debug = 1) THEN
	    debug('No MMTT returned!','transfer_contents',9);
	 END IF;
	 FND_MESSAGE.SET_NAME('WMS','WMS_ALLOCATE_FAIL');
	 FND_MSG_PUB.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      -- For inventory and wip, just query based on move_order_line_id
      BEGIN
         SELECT
           mmtt.transaction_temp_id
      BULK COLLECT INTO
           l_txn_tmp_id_tb
         FROM mtl_material_transactions_temp mmtt
         WHERE -- suggestion mmtts?
	   mmtt.organization_id = l_org_id AND
           mmtt.move_order_line_id --BUG 3435079: use org_id for performace reason
           IN ( SELECT mtrl.line_id
                FROM   mtl_txn_request_lines mtrl ,
		(SELECT wlpn.lpn_id     /*5723418*/
                        FROM wms_license_plate_numbers wlpn
                        START WITH wlpn.lpn_id = p_from_lpn_id
                        CONNECT BY PRIOR wlpn.lpn_id = wlpn.parent_lpn_id ) wlpn
                WHERE  mtrl.organization_id = l_org_id AND --BUG 3435079: use org_id for performace reason
		mtrl.lpn_id =  wlpn.lpn_id  );
      EXCEPTION
         WHEN OTHERS THEN
            IF (l_debug = 1 ) THEN
               DEBUG('Unexpected Exception Raised in Bulk Select'
                     ,'transfer_contents', 9);
            END IF;
            RAISE fnd_api.g_exc_error;
      END;
   END IF; -- IF (l_from_context = 3)

   l_progress := '70';

   l_task_execute_rec.person_id := l_emp_id;
   l_task_execute_rec.organization_id := l_org_id;
   l_task_execute_rec.loaded_time := Sysdate;
   l_task_execute_rec.user_task_type := -1;

   -- Activate each MMTT's
   FOR i IN 1 .. l_txn_tmp_id_tb.COUNT LOOP
      l_progress := '73';

      wms_atf_runtime_pub_apis.validate_operation
  (x_return_status    =>   x_return_status
   ,x_msg_data         =>   x_msg_data
   ,x_msg_count        =>   x_msg_count
   ,x_error_code       =>   l_error_code
   ,x_inspection_flag  =>   l_inspection_flag
   ,x_load_flag        =>   l_load_flag
   ,x_drop_flag        =>   l_drop_flag
   ,x_load_prim_quantity => l_load_prim_quantity
   ,x_drop_prim_quantity => l_drop_prim_quantity
   ,x_inspect_prim_quantity => l_inspect_prim_quantity
   ,p_source_task_id   =>   l_txn_tmp_id_tb(i)
   ,p_move_order_line_id => NULL
   ,p_inventory_item_id =>  NULL
   ,p_lpn_id           =>   NULL
   ,p_activity_type_id =>   1 -- INBOUND
   ,p_organization_id  =>   l_org_id);
      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
   IF (l_debug = 1) THEN
      debug('Validate_operation failed','transfer_contents',9);
   END IF;
   RAISE fnd_api.g_exc_error;
      END IF;

      l_progress := '75';

      IF (l_load_flag <> 3) THEN
   debug('MMTT:'||l_txn_tmp_id_tb(i)||' not full loaded','transfer_contents',9);
   RAISE fnd_api.g_exc_error;
      END IF;

      l_progress := '77';

      IF (l_debug = 1) THEN
         DEBUG('Calling activate_operation_instance','transfer_contents',9);
         DEBUG(' ( p_source_task_id     => ' || l_txn_tmp_id_tb(i),'transfer_contents',9);
         DEBUG('   ,p_activity_type_id  => 1','transfer_contents',9);
         DEBUG('   ,p_task_execute_rec  => l_task_execute_rec','transfer_contents',9);
         DEBUG('   ,p_operation_type_id => 1 )','transfer_contents',9);
      END IF;

      wms_atf_runtime_pub_apis.activate_operation_instance
  (  p_source_task_id  => l_txn_tmp_id_tb(i)
     ,p_activity_id => 1 -- Inbound
           ,p_task_execute_rec => l_task_execute_rec
           ,p_operation_type_id => 1 -- load
           ,x_return_status     => x_return_status
           ,x_msg_data          => x_msg_data
           ,x_msg_count         => x_msg_count
           ,x_error_code        => l_error_code
           ,x_consolidation_method_id => l_consolidation_method_id
           ,x_drop_lpn_option   => l_drop_lpn_option
           );
      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
         IF (l_debug = 1) THEN
            DEBUG('xxx: Error in activate_operation_instance','transfer_contents',9);
         END IF;
   RAISE fnd_api.g_exc_error;
      END IF;
   END LOOP;

   l_progress := '80';

   IF (l_from_context = 3) THEN -- resides in receiving
      IF (l_debug = 1) THEN
         DEBUG('xxx: l_from_context = ' || l_from_context
                     || '. Resides in receiving','transfer_contents',9);
      END IF;

      l_progress := '90';

      BEGIN
         SELECT COUNT(lpn_content_id)
           INTO l_count
           FROM wms_lpn_contents
          WHERE parent_lpn_id = p_from_lpn_id;
      EXCEPTION
         WHEN no_data_found THEN
            l_count := 0;
      END;

      l_progress := '100';

      --loose item exists or the into lpn sub/loc is different than
      -- that of the from lpn
      IF (l_count > 0 OR l_sub_loc_changed = 'Y') THEN
         IF (l_debug = 1) THEN
            DEBUG('xxx: There are ' || l_count ||
                        ' entries of wlpnc.  Inserting rti...','transfer_contents',9);
            DEBUG('      (p_from_org => ' || l_org_id,'transfer_contents',9);
            DEBUG('       p_to_org   => ' || l_org_id,'transfer_contents',9);
            DEBUG('       p_to_sub   => ' || l_sub_code,'transfer_contents',9);
            DEBUG('       p_to_loc   => ' || l_loc_id,'transfer_contents',9);
            DEBUG('       p_lpn_id   => ' || p_from_lpn_id,'transfer_contents',9);
            DEBUG('       p_xfer_lpn_id => ' || p_into_lpn_id,'transfer_contents',9);
         END IF;

         l_progress := '110';

   IF (l_sub_loc_changed = 'Y') THEN
      l_return_status := insert_rti
        (p_from_org => l_org_id
         ,p_lpn_id => p_from_lpn_id
         ,p_to_org   => l_org_id
               ,p_to_sub => l_to_sub
               ,p_to_loc => l_to_loc
               ,p_xfer_lpn_id  => p_into_lpn_id
               ,p_first_time  => 1
               ,p_mobile_txn => 'Y'
               ,p_txn_mode_code => 'ONLINE'
               ,x_return_status =>  x_return_status
               ,x_msg_count     =>  x_msg_count
               ,x_msg_data      =>  x_msg_data
               );
    ELSE -- If no sub/loc changed, then into LPN must be DFBU
      -- So pass in sub/loc of the from LPN
      l_return_status := insert_rti
        (p_from_org => l_org_id
         ,p_lpn_id => p_from_lpn_id
         ,p_to_org   => l_org_id
               ,p_to_sub => l_sub_code
               ,p_to_loc => l_loc_id
               ,p_xfer_lpn_id  => p_into_lpn_id
               ,p_first_time  => 1
               ,p_mobile_txn => 'Y'
               ,p_txn_mode_code => 'ONLINE'
               ,x_return_status =>  x_return_status
               ,x_msg_count     =>  x_msg_count
               ,x_msg_data      =>  x_msg_data
               );
   END IF; -- IF (l_sub_loc_changed = 'Y') THEN

         IF (x_return_status <> fnd_api.g_ret_sts_success OR l_return_status = -1) THEN
            IF (l_debug = 1) THEN
               DEBUG('xxx: Error inserting_rti','transfer_contents',9);
            END IF;
            RAISE fnd_api.g_exc_error;
         END IF;

         l_progress := '120';

   -- Update WMS_PROCESS_FLAG of MOL to 2
   BEGIN
      UPDATE
        mtl_txn_request_lines
        SET
        wms_process_flag = 2
        WHERE
        lpn_id IN (SELECT wlpn.lpn_id
       FROM   wms_license_plate_numbers wlpn
       START WITH wlpn.lpn_id = p_from_lpn_id
       CONNECT BY PRIOR wlpn.lpn_id =
       wlpn.parent_lpn_id);
   EXCEPTION
      WHEN OTHERS THEN
         IF (l_debug = 1 ) THEN
      debug('Error updating MOL statuses','transfer_contents',9);
         END IF;
   END;

   --call rcv tm
         l_progress := '130';
         IF (l_debug = 1) THEN
            DEBUG('xxx: Calling rcv_process_receive_txn','transfer_contents',9);
         END IF;

   l_old_txn_mode_code := inv_rcv_common_apis.g_po_startup_value.transaction_mode;
   inv_rcv_common_apis.g_po_startup_value.transaction_mode := 'ONLINE';

   l_progress := '135';

   BEGIN
      inv_rcv_mobile_process_txn.rcv_process_receive_txn
        (x_return_status    =>  x_return_status
         ,x_msg_data        =>  x_msg_data
         );
   EXCEPTION
      WHEN OTHERS THEN
         inv_rcv_common_apis.g_po_startup_value.transaction_mode := l_old_txn_mode_code;
         IF (l_debug = 1) THEN
      DEBUG('xxx: Error - Rcv TM Failed','transfer_contents',9);
         END IF;
         RAISE fnd_api.g_exc_error;
   END;

         IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
               DEBUG('xxx: Error - Rcv TM Failed','transfer_contents',9);
            END IF;
      inv_rcv_common_apis.g_po_startup_value.transaction_mode := l_old_txn_mode_code;
            RAISE fnd_api.g_exc_error;
         END IF;

         l_progress := '140';

         inv_rcv_common_apis.g_po_startup_value.transaction_mode := l_old_txn_mode_code;
         inv_rcv_common_apis.rcv_clear_global;

       ELSE -- No loose items and no sub/loc change
         IF (l_debug = 1) THEN
            DEBUG('xxx: No loose items exist','transfer_contents',9);
         END IF;

         l_progress := '150';

         BEGIN
            SELECT lpn_id
              bulk collect INTO l_lpn_ids
              FROM wms_license_plate_numbers
              WHERE parent_lpn_id = p_from_lpn_id;
         EXCEPTION
            WHEN OTHERS THEN
               IF (l_debug = 1) THEN
                  DEBUG('xxx: Error getting nested lpns','transfer_contents',9);
               END IF;
         END;

         l_progress := '160';

         -- Call packunpack on each inner LPN
         FOR i IN 1 .. l_lpn_ids.COUNT LOOP
            wms_container_pvt.packunpack_container
              (p_api_version       =>   1.0
               ,p_content_lpn_id    =>  l_lpn_ids(i)
               ,p_lpn_id           =>   p_from_lpn_id
               ,p_operation        =>   2 /* Unpack */
               ,p_organization_id  =>   l_org_id
               ,x_return_status    =>   x_return_status
               ,x_msg_count        =>   x_msg_count
               ,x_msg_data         =>   x_msg_data
               );
            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
               IF (l_debug = 1) THEN
                  DEBUG('xxx: Error unpacking content_lpn = ' ||
                              l_lpn_ids(i) || ' from lpn = ' ||
                              p_from_lpn_id,'transfer_contents',9);
               END IF;
               RAISE fnd_api.g_exc_error;
            END IF;

            wms_container_pvt.packunpack_container
              (p_api_version       =>   1.0
               ,p_content_lpn_id   =>   l_lpn_ids(i)
               ,p_lpn_id           =>   p_into_lpn_Id
               ,p_operation        =>   1 /* Pack */
               ,p_organization_id  =>   l_org_id
               ,x_return_status    =>   x_return_status
               ,x_msg_count        =>   x_msg_count
               ,x_msg_data         =>   x_msg_data
               );
            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
               IF (l_debug = 1) THEN
                  DEBUG('xxx: Error packing content_lpn = ' ||
                              l_lpn_ids(i) || ' into lpn = ' ||
                              p_into_lpn_id,'transfer_contents',9);
               END IF;
               RAISE fnd_api.g_exc_error;
            END IF;
         END LOOP;  -- end nested lpn loop

         l_progress := '170';

         -- At the end, update the intoLPN context into 3 (RCV)
         wms_container_pub.modify_lpn_wrapper
           ( p_api_version    =>  1.0
             ,x_return_status =>  x_return_status
             ,x_msg_count     =>  x_msg_count
             ,x_msg_data      =>  x_msg_data
             ,p_lpn_id        =>  p_into_lpn_id
             ,p_lpn_context   =>  3 --RCV
       ,p_subinventory  =>  l_sub_code -- same as from LPN
       ,p_locator_id    =>  l_loc_id
             );
         IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
               debug('Error modifying lpn',
                     'transfer_contents', 9);
            END IF;
         END IF;

         -- Call complete operation instance
         FOR i IN 1 .. l_txn_tmp_id_tb.COUNT LOOP
            wms_atf_runtime_pub_apis.complete_operation_instance
              ( p_source_task_id  =>  l_txn_tmp_id_tb(i)
                ,p_activity_id    =>  1 -- inbound
                ,p_operation_type_id => 1 -- load
                ,x_return_status  =>  x_return_status
                ,x_msg_data       =>  x_msg_data
                ,x_msg_count      =>  x_msg_count
                ,x_error_code     =>  l_error_code
                );
            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
               IF (l_debug = 1) THEN
                  DEBUG('xxx: Error in complete_operation_instance on '
                        || ' MMTT = ' || l_txn_tmp_id_tb(i),'transfer_contents',9);
               END IF;
               RAISE fnd_api.g_exc_error;
            END IF;

      END LOOP;

      -- No need to update any MMTT/MOL, since there will none
      -- assoc with from_lpn
      END IF; -- end count > 0
    ELSIF (l_from_context = 2) THEN -- WIP LPN

      l_progress := '180';

      IF (l_debug = 1) THEN
         DEBUG('xxx: l_from_context = ' || l_from_context
                     || '. Resides in WIP','transfer_contents',9);
      END IF;

      -- Deal with loose item
      -- First deal with non-serial controlled items
      l_loose_contents := 0;
      FOR l_wlpnc_rec IN wlpnc_cur LOOP
         IF (l_loose_contents = 0) THEN
            l_loose_contents := 1;
         END IF;
         IF Nvl(l_wlpnc_rec.serial_number_control_code,1) IN (1, 6) THEN
            -- ??
            IF (l_debug = 1) THEN
               debug('calling pup on item:
                     '||l_wlpnc_rec.inventory_item_id,
                     'transfer_contents',9);
            END IF;

            wms_container_pvt.packunpack_container
              (p_api_version       =>   1.0
               ,p_lpn_id           =>   p_from_lpn_id
               ,p_operation        =>   2 -- UNPACK
               ,p_organization_id  =>   l_org_id
               ,p_content_item_id  =>   l_wlpnc_rec.inventory_item_id
               ,p_revision         =>   l_wlpnc_rec.revision
               ,p_lot_number       =>   l_wlpnc_rec.lot_number
               ,p_quantity         =>   l_wlpnc_rec.quantity
               ,p_uom              =>   l_wlpnc_rec.uom_code
               ,x_return_status    =>   x_return_status
               ,x_msg_count        =>   x_msg_count
               ,x_msg_data         =>   x_msg_data
               );
            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
               IF (l_debug = 1) THEN
                  DEBUG('xxx: Error unpacking item_id = ' ||
                              l_wlpnc_rec.inventory_item_id || ' from lpn = ' ||
                              p_from_lpn_id,'transfer_contents',9);
               END IF;
               RAISE fnd_api.g_exc_error;
            END IF;

            wms_container_pvt.packunpack_container
              (p_api_version       =>   1.0
               ,p_lpn_id           =>   p_into_lpn_id
               ,p_operation        =>   1 -- PACK
               ,p_organization_id  =>   l_org_id
               ,p_content_item_id  =>   l_wlpnc_rec.inventory_item_id
               ,p_revision         =>   l_wlpnc_rec.revision
               ,p_lot_number       =>   l_wlpnc_rec.lot_number
               ,p_quantity         =>   l_wlpnc_rec.quantity
               ,p_uom              =>   l_wlpnc_rec.uom_code
               ,x_return_status    =>   x_return_status
               ,x_msg_count        =>   x_msg_count
               ,x_msg_data         =>   x_msg_data
               );
            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
               IF (l_debug = 1) THEN
                  DEBUG('xxx: Error packing item_id = ' ||
                              l_wlpnc_rec.inventory_item_id || ' from lpn = ' ||
                              p_from_lpn_id,'transfer_contents',9);
               END IF;
               RAISE fnd_api.g_exc_error;
            END IF;
    ELSE -- If item is serial controlled
      -- Call packunpack on each serial number
      IF (l_serial_numbers.COUNT > 0) THEN
         l_serial_numbers.DELETE;
      END IF;

      BEGIN
               SELECT serial_number
                 bulk collect INTO l_serial_numbers
                 FROM mtl_serial_numbers
                 WHERE lpn_id = p_from_lpn_id
     AND inventory_item_id = l_wlpnc_rec.inventory_item_id
     AND Nvl(lot_number, '@@@') = Nvl(l_wlpnc_rec.lot_number, '@@@')
                 AND Nvl(revision, '@@@') = Nvl(l_wlpnc_rec.revision,'@@@');
            EXCEPTION
               WHEN OTHERS THEN
                  IF (l_debug = 1) THEN
                     debug('Error retrieving entries from MTL_SERIAL_NUMBERS',
                           'transfer_contents', 9);
                  END IF;
      RAISE fnd_api.g_exc_error;
            END;

      FOR i IN 1 .. l_serial_numbers.COUNT LOOP
         IF (l_debug = 1) THEN
      DEBUG('transfer_contents: unpacking serial number:'
      || l_serial_numbers(i),9);
         END IF;
         wms_container_pvt.packunpack_container
     (p_api_version       =>   1.0
      ,p_lpn_id           =>   p_from_lpn_id
      ,p_operation        =>   2 -- UNPACK
      ,p_organization_id  =>   l_org_id
      ,p_content_item_id  =>   l_wlpnc_rec.inventory_item_id
      ,p_revision         =>   l_wlpnc_rec.revision
      ,p_lot_number       =>   l_wlpnc_rec.lot_number
      ,p_from_serial_number => l_serial_numbers(i)
      ,p_to_serial_number =>   l_serial_numbers(i)
      ,p_uom              =>   l_wlpnc_rec.uom_code
      ,x_return_status    =>   x_return_status
      ,x_msg_count        =>   x_msg_count
      ,x_msg_data         =>   x_msg_data
      );
         IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
         DEBUG('xxx: Error unpacking serial_number = ' ||
         l_serial_numbers(i) || ' from lpn = ' ||
         p_from_lpn_id,'transfer_contents',9);
      END IF;
      RAISE fnd_api.g_exc_error;
         END IF;
         wms_container_pvt.packunpack_container
     (p_api_version       =>   1.0
      ,p_lpn_id           =>   p_into_lpn_id
      ,p_operation        =>   1 -- PACK
      ,p_organization_id  =>   l_org_id
      ,p_content_item_id  =>   l_wlpnc_rec.inventory_item_id
      ,p_revision         =>   l_wlpnc_rec.revision
      ,p_lot_number       =>   l_wlpnc_rec.lot_number
      ,p_from_serial_number => l_serial_numbers(i)
      ,p_to_serial_number =>   l_serial_numbers(i)
      ,p_uom              =>   l_wlpnc_rec.uom_code
      ,x_return_status    =>   x_return_status
      ,x_msg_count        =>   x_msg_count
      ,x_msg_data         =>   x_msg_data
      );
         IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
         DEBUG('xxx: Error packing serial_number = ' ||
         l_serial_numbers(i) || ' from lpn = ' ||
         p_from_lpn_id,'transfer_contents',9);
      END IF;
      RAISE fnd_api.g_exc_error;
         END IF;
      END LOOP; --  FOR i in 1 .. l_serial_numbers.COUNT LOOP
   END IF; -- IF Nvl(l_wlpnc_rec.serial_number_control_code,1) IN (1, 6) THEN
      END LOOP; --FOR l_wlpnc_rec IN wlpnc_cur LOOP

      l_progress := '200';

      -- Now deal with Nested LPN.  For now, there should be none
      BEGIN
         SELECT lpn_id
           bulk collect INTO l_lpn_ids
           FROM wms_license_plate_numbers
           WHERE parent_lpn_id = p_from_lpn_id;
      EXCEPTION
         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
               DEBUG('xxx: Error getting nested lpns','transfer_contents',9);
            END IF;
      END;

      l_progress := '210';

      FOR i IN 1 .. l_lpn_ids.COUNT LOOP
         wms_container_pvt.packunpack_container
           (p_api_version       =>   1.0
            ,p_content_lpn_id    =>  l_lpn_ids(i)
            ,p_lpn_id           =>   p_from_lpn_id
            ,p_operation        =>   2 /* Unpack */
            ,p_organization_id  =>   l_org_id
            ,x_return_status    =>   x_return_status
            ,x_msg_count        =>   x_msg_count
            ,x_msg_data         =>   x_msg_data
            );
         IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
               DEBUG('xxx: Error unpacking lpn = ' ||
                           l_lpn_ids(i) || ' from lpn = ' ||
                           p_from_lpn_id,'transfer_contents',9);
            END IF;
            RAISE fnd_api.g_exc_error;
         END IF;
         wms_container_pvt.packunpack_container
           (p_api_version       =>   1.0
            ,p_content_lpn_id   =>   l_lpn_ids(i)
            ,p_lpn_id           =>   p_into_lpn_Id
            ,p_operation        =>   1 /* Pack */
            ,p_organization_id  =>   l_org_id
            ,x_return_status    =>   x_return_status
            ,x_msg_count        =>   x_msg_count
            ,x_msg_data         =>   x_msg_data
            );
         IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
               DEBUG('xxx: Error packing lpn = ' ||
                           l_lpn_ids(i) || ' into lpn = ' ||
                           p_into_lpn_id,'transfer_contents',9);
            END IF;
            RAISE fnd_api.g_exc_error;
         END IF;
      END LOOP;

      l_progress := '220';

      -- At the end, update the intoLPN context into 2 (WIP
      wms_container_pub.modify_lpn_wrapper
        ( p_api_version    =>  1.0
          ,x_return_status =>  x_return_status
          ,x_msg_count     =>  x_msg_count
          ,x_msg_data      =>  x_msg_data
          ,p_lpn_id        =>  p_into_lpn_id
          ,p_lpn_context   =>  2 --WIP
          );
      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
         IF (l_debug = 1) THEN
            debug('Error modifying lpn context to wip',
                  'transfer_contents', 9);
         END IF;
      END IF;

      -- Call complete operation instance
      FOR i IN 1 .. l_txn_tmp_id_tb.COUNT LOOP
         wms_atf_runtime_pub_apis.complete_operation_instance
           ( p_source_task_id  =>  l_txn_tmp_id_tb(i)
             ,p_activity_id    =>  1 -- inbound
             ,p_operation_type_id => 1 -- load
             ,x_return_status  =>  x_return_status
             ,x_msg_data       =>  x_msg_data
             ,x_msg_count      =>  x_msg_count
             ,x_error_code     =>  l_error_code
             );
         IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
               DEBUG('xxx: Error in complete_operation_instance on '
                           || ' MMTT = ' || l_txn_tmp_id_tb(i),'transfer_contents',9);
            END IF;
            RAISE fnd_api.g_exc_error;
         END IF;

      END LOOP;

      -- Update MOL to new LPN id, only if there are loose contents
      -- associated with fromLPN
      IF (l_loose_contents = 1) THEN
         -- Update any MMTT assoc with the old LPN to the new LPN id
         IF (l_debug = 1) THEN
            -- ER 7307189 changes start
            debug('Updating MMTT...','transfer_contents',9);
            debug('Updating MMTT...','transfer_contents p_into_lpn_id'||p_into_lpn_id,9);
            debug('Updating MMTT...','transfer_contents p_from_lpn_id'||p_from_lpn_id,9);
            -- ER 7307189 changes end
         END IF;

	 --BUG 3435079: The query doesn't seem to be picking up the lpn_id
	 --index on MMTT.  So replace it with the following, and also
	 --Move it BEFORE updating MOL
         UPDATE
           mtl_material_transactions_temp
           SET
           lpn_id = p_into_lpn_id
           WHERE
	   lpn_id = p_from_lpn_id;


         BEGIN
            UPDATE
              mtl_txn_request_lines
              SET
              lpn_id = p_into_lpn_id
              WHERE
              lpn_id = p_from_lpn_id;
         EXCEPTION
            WHEN OTHERS THEN
               IF (l_debug =1 ) THEN
                  DEBUG('xxx: Error updating MOL','transfer_contents',9);
               END IF;
               RAISE fnd_api.g_exc_error;
         END;

         l_progress := '230';

      END IF;

    ELSE -- inventory LPN l_from_context = 1

      IF (l_debug = 1) THEN
         DEBUG('xxx: l_from_context = ' || l_from_context
                     || '. Resides in Inventory','transfer_contents',9);
      END IF;

      l_progress := '240';

      -- create MMTT records for each loose item, each inner LPN
      -- Group them into same header, and then call inventory TM
      SELECT mtl_material_transactions_s.NEXTVAL
        INTO   l_hdr_id
        FROM   dual;

      l_progress := '250';

      IF (l_sub_loc_changed = 'Y') THEN
   l_return_status := inv_trx_util_pub.insert_line_trx
     (
      p_trx_hdr_id           => l_hdr_id
      , p_item_id              => '0'
      , p_org_id               => l_org_id
      , p_trx_action_id        => 2
      , p_subinv_code          => l_sub_code
      , p_tosubinv_code        => l_to_sub
      , p_locator_id           => l_loc_id
      , p_tolocator_id         => l_to_loc
      , p_trx_type_id          => 2
      , p_trx_src_type_id      => 13
      , p_trx_qty              => 1
      , p_pri_qty              => 1
      , p_uom                  => 'Ea'
      , p_user_id              => l_user_id
      , p_from_lpn_id          => NULL
      , p_cnt_lpn_id           => p_from_lpn_id
      , p_xfr_lpn_id           => NULL
      , x_trx_tmp_id           => l_txn_tmp_id
      , x_proc_msg             => x_msg_data
      , p_project_id           => p_project_id
      , p_task_id              => p_task_id);
   IF (l_txn_tmp_id <= 0 ) OR (l_return_status<>0) THEN
      IF (l_debug = 1) THEN
         debug('Error inserting MMTT ID: ' ||
         l_txn_tmp_id,'transfer_contents',9);
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   BEGIN
      UPDATE  mtl_material_transactions_temp
        SET   transaction_header_id = l_hdr_id
        , transaction_batch_id  = l_hdr_id
        , transaction_batch_seq = l_batch_seq
        WHERE   transaction_temp_id   = l_txn_tmp_id;
   EXCEPTION
      WHEN OTHERS THEN
         IF (l_debug = 1) THEN
      debug('Error updating MMTT with ID: ' ||
      l_txn_tmp_id,9);
         END IF;
         RAISE fnd_api.g_exc_error;
   END;

   l_batch_seq := l_batch_seq + 1;
   -- update local variables for sub and loc
   l_sub_code := l_to_sub;
   l_loc_id := l_to_loc;

      END IF; --IF (l_sub_loc_changed = 'Y') THEN

      -- Deal with Nested LPN first
      BEGIN
         SELECT lpn_id
           bulk collect INTO l_lpn_ids
         FROM wms_license_plate_numbers
         WHERE parent_lpn_id = p_from_lpn_id;
      EXCEPTION
         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
               DEBUG('xxx: Error getting nested lpns','transfer_contents',9);
            END IF;
      END;

      l_progress := '260';

      FOR i IN 1 .. l_lpn_ids.COUNT LOOP
         IF (l_debug = 1) THEN
            DEBUG('Inserting MMTT for lpn: ' || l_lpn_ids(i),
                  'transfer_contents',
                  9);
         END IF;

   l_return_Status := inv_trx_util_pub.insert_line_trx
     (
      p_trx_hdr_id             => l_hdr_id
      , p_item_id              => -1
      , p_org_id               => l_org_id
      , p_trx_action_id        => inv_globals.g_action_containersplit
      , p_subinv_code          => l_sub_code
      , p_locator_id           => l_loc_id
      , p_trx_type_id          => inv_globals.g_type_container_split
      , p_trx_src_type_id      => inv_globals.g_sourcetype_inventory
      , p_trx_qty              => 1
      , p_pri_qty              => 1
      , p_uom                  => 'X'
      , p_user_id              => l_user_id  --??
      , p_from_lpn_id          => p_from_lpn_id
      , p_cnt_lpn_id           => l_lpn_ids(i)
      , p_xfr_lpn_id           => p_into_lpn_id
      , x_trx_tmp_id           => l_txn_tmp_id
      , x_proc_msg             => x_msg_data );

   IF (l_return_status = -1) THEN
      IF (l_debug = 1) THEN
         debug('Error inserting MMTT', 'transfer_contents', 9);
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   BEGIN
      UPDATE  mtl_material_transactions_temp
        SET   transaction_header_id = l_hdr_id
        , transaction_batch_id  = l_hdr_id
        , transaction_batch_seq = l_batch_seq
        WHERE   transaction_temp_id   = l_txn_tmp_id;
   EXCEPTION
      WHEN OTHERS THEN
         IF (l_debug = 1) THEN
      debug('Error updating MMTT with ID: ' ||
      l_txn_tmp_id,9);
         END IF;
         RAISE fnd_api.g_exc_error;
   END;

   l_batch_seq := l_batch_seq + 1;
      END LOOP;

      l_progress := '270';

      -- Now deal with loose items
      l_loose_contents := 0;
      FOR l_wlpnc_rec IN wlpnc_cur LOOP
         IF (l_loose_contents = 0) THEN
            l_loose_contents := 1;
         END IF;

         IF (l_wlpnc_rec.uom_code <> l_wlpnc_rec.primary_uom_code) THEN
            l_prim_qty := inv_rcv_cache.convert_qty
	                     (p_inventory_item_id => l_wlpnc_rec.inventory_item_id
			      ,p_from_qty         => l_wlpnc_rec.quantity
			      ,p_from_uom_code    => l_wlpnc_rec.uom_code
			      ,p_to_uom_code      => l_wlpnc_rec.primary_uom_code);
          ELSE
            l_prim_qty := l_wlpnc_rec.quantity;
         END IF;

   IF (l_debug = 1) THEN
            debug('Inserting MMTT...', 'transfer_contents', 9);
         END IF;
         l_return_status := inv_trx_util_pub.insert_line_trx
           (
            p_trx_hdr_id             => l_hdr_id
            , p_item_id              => l_wlpnc_rec.inventory_item_id
            , p_revision             => l_wlpnc_rec.revision
            , p_org_id               => l_org_id
            , p_trx_action_id        => inv_globals.g_action_containersplit
            , p_subinv_code          => l_sub_code
            , p_locator_id           => l_loc_id
            , p_trx_type_id          => inv_globals.g_type_container_split
            , p_trx_src_type_id      => inv_globals.g_sourcetype_inventory
            , p_trx_qty              => l_wlpnc_rec.quantity
            , p_pri_qty              => l_prim_qty
            , p_uom                  => l_wlpnc_rec.uom_code
            , p_user_id              => l_user_id --??
            , p_from_lpn_id          => p_from_lpn_id
            , p_xfr_lpn_id           => p_into_lpn_id
            , x_trx_tmp_id           => l_txn_tmp_id
            , x_proc_msg             => x_msg_data);
   IF (l_return_status = -1) THEN
      IF (l_debug = 1) THEN
         debug('Error inserting MMTT', 'transfer_contents', 9);
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   BEGIN
      UPDATE  mtl_material_transactions_temp
        SET   transaction_header_id = l_hdr_id
        , transaction_batch_id  = l_hdr_id
        , transaction_batch_seq = l_batch_seq
        WHERE   transaction_temp_id   = l_txn_tmp_id;
   EXCEPTION
      WHEN OTHERS THEN
         IF (l_debug = 1) THEN
      debug('Error updating MMTT with ID: ' ||
      l_txn_tmp_id,9);
         END IF;
         RAISE fnd_api.g_exc_error;
   END;

   l_batch_seq := l_batch_seq + 1;

         IF (l_debug = 1) THEN
            debug('MMTT:' || l_txn_tmp_id || 'Inserted', 'transfer_contents', 9);
         END IF;

         IF (l_wlpnc_rec.lot_number IS NOT NULL) THEN
            l_return_status := inv_trx_util_pub.insert_lot_trx
              ( p_trx_tmp_id   => l_txn_tmp_id
                ,p_user_id     => l_user_id
                ,p_lot_number  => l_wlpnc_rec.lot_number
                ,p_trx_qty     => l_wlpnc_rec.quantity
                ,p_pri_qty     => l_prim_qty
                ,x_ser_trx_id  => l_ser_trx_id
                ,x_proc_msg    => x_msg_data);
      IF (l_return_status = -1) THEN
         IF (l_debug = 1) THEN
      debug('Error inserting MTLT', 'transfer_contents', 9);
         END IF;
         RAISE fnd_api.g_exc_error;
      END IF;
         END IF;

         IF (Nvl(l_wlpnc_rec.serial_number_control_code,1)
             NOT IN (1, 6)) THEN -- Item is serial control
      IF (l_serial_numbers.COUNT > 0) THEN
         l_serial_numbers.DELETE;
      END IF;

            BEGIN
               SELECT serial_number
                 bulk collect INTO l_serial_numbers
                 FROM mtl_serial_numbers
                 WHERE lpn_id = p_from_lpn_id
     AND inventory_item_id = l_wlpnc_rec.inventory_item_id
     AND Nvl(lot_number, '@@@') = Nvl(l_wlpnc_rec.lot_number, '@@@')
                 AND Nvl(revision, '@@@') = Nvl(l_wlpnc_rec.revision,'@@@');
            EXCEPTION
               WHEN OTHERS THEN
                  IF (l_debug = 1) THEN
                     debug('Error retrieving entries from MTL_SERIAL_NUMBERS',
                           'transfer_contents', 9);
                  END IF;
      RAISE fnd_api.g_exc_error;
            END;

      IF (l_wlpnc_rec.lot_number IS NOT NULL) THEN
         l_txn_tmp_id := l_ser_trx_id;
      END IF;

            FOR i IN 1 .. l_serial_numbers.COUNT LOOP
         l_return_status := inv_trx_util_pub.insert_ser_trx
     (p_trx_tmp_id => l_txn_tmp_id
      ,p_user_id   => l_user_id
      ,p_fm_ser_num=> l_serial_numbers(i)
      ,p_to_ser_num=> l_serial_numbers(i)
      ,x_proc_msg  => x_msg_data );
         IF (l_return_status = -1) THEN
      IF (l_debug = 1) THEN
         debug('Error inserting MSNT', 'transfer_contents', 9);
      END IF;
      RAISE fnd_api.g_exc_error;
         END IF;
            END LOOP;
         END IF;
      END LOOP;

      IF (l_debug = 1) THEN
         DEBUG('xxx: Calling process_lpn_trx','transfer_contents',9);
         DEBUG('      (p_trx_hdr_id => ' || l_hdr_id,'transfer_contents',9);
      END IF;

      l_return_status :=inv_lpn_trx_pub.process_lpn_trx
        (p_trx_hdr_id         => l_hdr_id
   ,p_proc_mode         => 1
         ,p_commit            => fnd_api.g_false
         ,x_proc_msg          => x_msg_data);

   -- Call complete operation instance
   FOR i IN 1 .. l_txn_tmp_id_tb.COUNT LOOP
      wms_atf_runtime_pub_apis.complete_operation_instance
  ( p_source_task_id  =>  l_txn_tmp_id_tb(i)
    ,p_activity_id    =>  1 -- inbound
    ,p_operation_type_id => 1 -- load
    ,x_return_status  =>  x_return_status
    ,x_msg_data       =>  x_msg_data
    ,x_msg_count      =>  x_msg_count
    ,x_error_code     =>  l_error_code
    );
      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
   IF (l_debug = 1) THEN
               DEBUG('xxx: Error in complete_operation_instance on '
         || ' MMTT = ' || l_txn_tmp_id_tb(i),'transfer_contents',9);
   END IF;
   RAISE fnd_api.g_exc_error;
      END IF;

   END LOOP;

      -- Update any MOL assoc with the old LPN to new LPN id
      IF (l_loose_contents = 1) THEN
   l_progress := '290';
   -- Update any MMTT assoc with the old LPN to the new LPN id
   IF (l_debug = 1) THEN
      -- ER 7307189 changes start
      debug('Updating MMTT...','transfer_contents11111',9);
      debug('Updating MMTT...','transfer_contents p_into_lpn_id'||p_into_lpn_id,9);
      debug('Updating MMTT...','transfer_contents p_from_lpn_id'||p_from_lpn_id,9);
      -- ER 7307189 changes end

   END IF;

   --BUG 3435079: The query doesn't seem to be picking up the lpn_id
   --index on MMTT.  So replace it with the following, and also
   --Move it BEFORE updating MOL
   UPDATE
     mtl_material_transactions_temp
     SET
     lpn_id = p_into_lpn_id
     WHERE
     lpn_id = p_from_lpn_id;

   IF (l_debug = 1) THEN
      debug('Updating MOL...','transfer_contents',9);
   END IF;

   BEGIN
      UPDATE
        mtl_txn_request_lines
        SET
        lpn_id = p_into_lpn_id
        WHERE
        lpn_id = p_from_lpn_id;
   EXCEPTION
      WHEN OTHERS THEN
         IF (l_debug = 1) THEN
	    DEBUG('xxx: Error updating MOLs','transfer_contents',9);
         END IF;
         RAISE fnd_api.g_exc_error;
   END;

   l_progress := '300';

      END IF;
   END IF; -- end l_from_context check

   IF (l_debug = 1) THEN
      DEBUG('Exiting transfer_contents','transfer_contents', 9);
   END IF;

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name('WMS', 'WMS_TASK_ERROR');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
         debug('Exception occured after l_progress ='|| l_progress, 'transfer_contents', 9);
      END IF;
      IF (wlpnc_cur%isopen) THEN
	 CLOSE wlpnc_cur;
      END IF;
      BEGIN
	 ROLLBACK TO transfer_contents_pub;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       debug('SQLCODE:'||SQLCODE||' SQLERRM'||Sqlerrm,9);
	    END IF;
      END;
END transfer_contents;


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
    , p_group_id                IN          NUMBER
    , p_txn_header_id           IN          NUMBER
    , p_drop_type               IN          VARCHAR2
    , p_lpn_mode                IN          NUMBER
    , p_lpn_id                  IN          NUMBER
    , p_lpn_context             IN          NUMBER
    , p_organization_id         IN          NUMBER
    , p_user_id                 IN          NUMBER
    , p_item_id                 IN          NUMBER
    , p_revision                IN          VARCHAR2
    , p_lot_number              IN          VARCHAR2
    , p_subinventory_code       IN          VARCHAR2
    , p_locator_id              IN          NUMBER
    , p_quantity                IN          NUMBER
    , p_uom_code                IN          VARCHAR2
    , p_entire_lpn              IN          VARCHAR2
    , p_to_lpn_name             IN          VARCHAR2
    , p_to_lpn_id               IN          NUMBER
    , p_project_id              IN          NUMBER
    , p_task_id                 IN          NUMBER
    , p_reference               IN          VARCHAR2
    , p_qty_reason_id           IN          NUMBER
    , p_loc_reason_id           IN          NUMBER
    , p_process_serial_flag     IN          VARCHAR2
    , p_msni_txn_interface_id   IN          NUMBER
    , p_product_transaction_id  IN          NUMBER
    , p_secondary_quantity      IN          NUMBER --OPM Convergence
    , p_secondary_uom           IN          VARCHAR2 --OPM Convergence
    , p_lpn_initially_loaded    IN          VARCHAR2 ) IS

    --Cursor Declarations

    --Fetches the move order lines in the global temporary table for the current group
    CURSOR mol_csr IS
       SELECT  mtrl.line_id
	       , mtrl.quantity
	       , NVL(mtrl.quantity_detailed, 0)
	       , NVL(mtrl.quantity_delivered, 0)
 	       , mtrl.uom_code
	       , mtrl.secondary_quantity --OPM Convergence
	       , NVL(mtrl.secondary_quantity_detailed, 0) --OPM Convergence
	       , NVL(mtrl.secondary_quantity_delivered, 0) --OPM Convergence
	       , mtrl.secondary_uom_code --OPM Convergence
	 FROM mtl_txn_request_lines mtrl
	 WHERE mtrl.line_id IN (SELECT  DISTINCT  gtmp.move_order_line_id
			   FROM    wms_putaway_group_tasks_gtmp gtmp
			   WHERE   gtmp.group_id = p_group_id
			   AND     gtmp.transaction_header_id = p_txn_header_id
			   AND     gtmp.row_type = g_row_tp_all_task);

    --R12: This cursor is used to find out the matching MOL for a
    --given group of serials with a particular inspection status and
    --lot number
    CURSOR serial_mol_csr(v_inspect_status NUMBER, v_lot_number VARCHAR2) IS
       SELECT  mtrl.line_id
	       , mtrl.quantity
	       , NVL(mtrl.quantity_detailed, 0)
	       , NVL(mtrl.quantity_delivered, 0)
 	       , mtrl.uom_code
	       , mtrl.secondary_quantity --OPM Convergence
	       , NVL(mtrl.secondary_quantity_detailed, 0) --OPM Convergence
	       , NVL(mtrl.secondary_quantity_delivered, 0) --OPM Convergence
	       , mtrl.secondary_uom_code --OPM Convergence
	 FROM mtl_txn_request_lines mtrl
	 WHERE mtrl.line_id IN (SELECT  DISTINCT  gtmp.move_order_line_id
			   FROM    wms_putaway_group_tasks_gtmp gtmp
			   WHERE   gtmp.group_id = p_group_id
			   AND     gtmp.transaction_header_id = p_txn_header_id
			   AND     gtmp.row_type = g_row_tp_all_task)
	 AND   Nvl(mtrl.lot_number,'&*_') = Nvl(v_lot_number,'&*_')
	 AND   Nvl(mtrl.inspection_status,-1) = Nvl(v_inspect_status,-1);

    --Fetches the details of the current task from the global temp table
    --drop types 'Consolidated Drop' or 'Item Drop'
    CURSOR all_tasks_csr(v_disc VARCHAR2) IS
      SELECT  transaction_temp_id
            , lpn_id
            , move_order_line_id
            , inventory_item_id
            , revision
            , lot_number
            , transaction_quantity
            , transaction_uom
            , txn_source_id
            , backorder_delivery_detail
            , crossdock_type
            , wip_supply_type
            , secondary_quantity  -- OPM Convergence
	    , inspection_status
	    , primary_uom_code
      FROM    wms_putaway_group_tasks_gtmp
      WHERE   group_id = p_group_id
      AND     transaction_header_id = p_txn_header_id
      AND     row_type = G_ROW_TP_ALL_TASK
      AND     ( (v_disc = 'N') --no qty idsc
                OR
                (v_disc = 'Y' AND p_drop_type = G_DT_ITEM_DROP
                 AND process_flag = 'Y'  --item drop and qty disc
                )
              );

    --Fetches the information for the current task for the drop types
    --'Manual Drop' or 'User Drop'
    CURSOR md_tasks_csr IS
      SELECT  mmtt.transaction_temp_id
            , mtrl.lpn_id
            , mtrl.line_id
            , mmtt.inventory_item_id
            , mmtt.revision
            , mtrl.lot_number
            , mmtt.transaction_quantity
            , mmtt.transaction_uom
            , mtrl.txn_source_id
            , mtrl.backorder_delivery_detail_id
            , mtrl.crossdock_type
            , mmtt.wip_supply_type
            , mmtt.secondary_transaction_quantity --OPM Convergence
	    , mtrl.inspection_status
	    , msi.primary_uom_code
      FROM    mtl_material_transactions_temp mmtt
            , mtl_txn_request_lines mtrl
	    , mtl_txn_request_headers mtrh
	    , mtl_system_items_kfv msi
	    , (          /*5723418*/
                SELECT  wlpn.lpn_id
                FROM    wms_license_plate_numbers wlpn
                START WITH wlpn.lpn_id = p_lpn_id
                CONNECT BY PRIOR wlpn.lpn_id = wlpn.parent_lpn_id
              ) wlpn
      WHERE   mtrh.organization_id = p_organization_id
      AND     mtrh.move_order_type = 6
      AND     mtrl.header_id = mtrh.header_id
      AND     mtrl.line_id = mmtt.move_order_line_id
      AND     mtrl.line_status = 7
      AND     mtrl.lpn_id = wlpn.lpn_id
      AND     msi.inventory_item_id = mtrl.inventory_item_id
      AND     msi.organization_id = mtrl.organization_id;

    --R12: This cursor will return all serials entered by the user
    --in this transaction
    CURSOR rcv_serials_csr IS
       SELECT  msn.serial_number
	 ,     'N'
	 ,     msn.inspection_status
	 ,     msn.lot_number
	 FROM    mtl_serial_numbers_interface msni
	 ,       mtl_serial_numbers msn
	 ,       rcv_serials_supply rss
	 WHERE   msni.transaction_interface_id = p_msni_txn_interface_id
	 AND   msn.serial_number BETWEEN msni.fm_serial_number AND Nvl(msni.to_serial_number,  msni.fm_serial_number)
	 AND   Length(msn.serial_number) = Length(msni.fm_serial_number)
	 AND   msn.inventory_item_id = p_item_id
	 AND   msn.current_organization_id = p_organization_id
	 AND   msn.lpn_id = p_lpn_id
	 AND   rss.serial_num = msn.serial_number
	 AND   rss.supply_type_code = 'RECEIVING'
	 ORDER BY msn.serial_number,msn.lot_number;

    --Fetches the serials that were consumed by the user in UI if user confirms
    --partial quantity for an Inventory/WIP LPN
    CURSOR  msnt_ser_csr(v_lpn_id  NUMBER
                       , v_item_id NUMBER) IS
      SELECT  serial_number
            , 'N'
      FROM    mtl_serial_numbers
      WHERE   inventory_item_id = v_item_id
      AND     lpn_id = v_lpn_id
      AND     (
                (p_revision IS NOT NULL and revision = p_revision)
                OR
                (p_revision IS NULL)
              )
      AND     (
                (p_lot_number IS NOT NULL and lot_number = p_lot_number)
                OR
                (p_lot_number IS NULL)
              )
      AND     group_mark_id = -4936;

    --Local variables
    l_quantity                NUMBER;   --Quantity passed to complete_putaway
    l_remaining_qty           NUMBER;   --Track remaining quantity to confirm
    l_sug_grp_quantity        NUMBER;   --Total suggested quantity for the group
    l_grp_prm_quantity        NUMBER;   --Total group quantity in primary UOM
    l_rem_grp_quantity        NUMBER;   --Remaining quantity to consume for MO splits
    l_prm_user_qty            NUMBER;   --Confirmed quantity in primary uom
    l_rem_user_qty            NUMBER;   --Remaining quantity to be confirmed
    l_mol_qty                 NUMBER;   --MOL quantity
    l_mol_qty_detailed        NUMBER;   --MOL total allocated quantity
    l_mol_qty_delivered       NUMBER;   --MOL transacted quantity
    l_new_txn_header_id       NUMBER;   --New value for transaction_header_id
    l_mol_uom_code            MTL_UNITS_OF_MEASURE_TL.uom_code%TYPE;   --MOL uom code
    l_tmp_qty1                NUMBER;   --MOL Qty - MOL Delivered Qty
    l_tmp_prm_qty             NUMBER;   --MOL Qty - Delivered Qty  in primary uom
    l_lpn_controlled_flag     NUMBER;   --LPN controlled flag for the drop sub
    l_qty_to_split            NUMBER;   --Quantity to split
    l_uom_con_sug_grp_qty     NUMBER;   --Suggested quantity converted to primary UOM???
    l_grp_uom_code            MTL_UNITS_OF_MEASURE_TL.uom_code%TYPE;
    l_uom_code                MTL_UNITS_OF_MEASURE_TL.uom_code%TYPE;
    l_primary_uom_code        MTL_UNITS_OF_MEASURE_TL.uom_code%TYPE;
    l_serialized_item         BOOLEAN;  --Flag to indicate if the item is serialized
    l_group_id                NUMBER;   -- Group ID
    l_product_transaction_id  NUMBER;   --Product transaction id for complete_putaway
    l_item_id                 NUMBER;   --Item ID for complete_putaway
    l_subinventory_code       mtl_secondary_inventories.secondary_inventory_name%TYPE;
    l_locator_id              NUMBER;   --Locator for complete_putaway
    l_lpn_id                  NUMBER;   --p_LPN_ID for complete_putaway???--check
    l_to_lpn_id               NUMBER;   --To LPN ID -- for pack/unpack
    l_to_lpn_name             wms_license_plate_numbers.license_plate_number%TYPE;
    l_revision                mtl_item_revisions.revision%TYPE;   --p_rev for complete_putaway
    l_lot_number              mtl_lot_numbers.lot_number%type;    --p_lot for complete_putaway
    l_mmtt_prm_qty             NUMBER;  --Lot quantity in primary uom
    l_lot_expiration_date     DATE;     --Lot expiration date
    l_lot_status_id           NUMBER;   --Lot Status
    l_cur_ser_number          mtl_serial_numbers.serial_number%TYPE;
    l_mmtt_temp_id            NUMBER;   --Variable to store p_temp_id of complete_putaway
    l_mmtt_temp_id_tbl        num_tab;  --Transaction_Temp_ids for the current group
    l_mmtt_item_id_tbl        num_tab;  --Item ID for the current group
    l_mmtt_rev_tbl            rev_tab;  --Revision for the current group
    l_mmtt_lot_tbl            lot_tab;  --Lot Number for the current group
    l_mmtt_qty_tbl            num_tab;  --transaction_quantity for the current group
    l_mmtt_uom_tbl            uom_tab;  --uom for the current group
    l_bk_del_det_tbl          num_tab;  --Backorder Delivery Detail to hold crossdock infor
    l_xdock_type_tbl          num_tab;  --Crossdock type for the current group
    l_wip_sup_typ_tbl         num_tab;  --Wip Supply Type for the current group
    l_mol_line_id             NUMBER;   --MO Line ID
    l_mol_lpn_id_tbl          num_tab;  --LPN_ID for the current task => p_lpn_id of complete_putaway
    l_mol_line_id_tbl         num_tab;  --MO Line ID
    l_parent_txn_id_tbl       num_tab;  --Parent Transaction Id - for rcv_serials_supply
    l_parent_txn_id           NUMBER;   --Parent Transaction Id - for rcv_serials_supply
    l_lot_control_code        NUMBER;   --Item Lot control code
    l_serial_control_code     NUMBER;   --Item Serial control code
    l_mmtt_count              NUMBER;   --No. of MMTTs for the current MOL
    l_ser_intf_id             NUMBER;   --Updated txn_interface_id for MSNI
    l_cur_task_ser_count      NUMBER;   --Count of serials consumed for the current task
    l_entire_lpn              VARCHAR2(1);    --Is entire LPN putaway
    l_process_flag            VARCHAR2(10);   --Indicator to pick tasks from global temp table
    l_disc                    VARCHAR2(10);   --Quantity discrepancy indicator
    l_serial_txn_temp_id      NUMBER;   --Serial temp id for lot and serial controlled item
    l_serial_temp_id          NUMBER;   --serial_transaction_temp_id - for MSNI
    l_temp_id_tbl             num_tab;  --Table of transaction_temp_id for the group
    l_ser_num_tbl             ser_num_tab;  --Table to hold serials in MSNI
    l_parent_ser_tbl          ser_num_tab;  --Table for serials for the parent serial
    l_ser_mark_tbl            ser_mark_tab; --Flag to indicate if serial is confirmed
    l_ser_qty                 NUMBER;       --Quantity for process_lot_serial API
    l_action                  NUMBER;       --Action code for the process_lot_serial API
    l_txn_ret                 NUMBER := 0;  --Return status of the Inventory TM
    l_msg_data                VARCHAR2(10000);
    l_del_count               NUMBER;       --No. of rows deleted in the temp table
    l_business_flow_code      NUMBER := 30; -- default to Inventory Putaway
    l_debug                   NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_progress                VARCHAR2(10);       --Progress indicator
    l_proc_name               VARCHAR2(30) := 'complete_putaway_wrapper';
    l_mos_to_split_tbl        split_mo_tb_tp;
    l_mo_splt_tb              inv_rcv_integration_apis.mo_in_tb_tp;
    l_mo_splt_cnt             NUMBER;       --MO Split table counter
    l_rcv_commit              BOOLEAN := FALSE;
    l_lpn_mode                NUMBER;    -- Drop mode
    l_drop_sub_type           NUMBER;    -- Drop subinventory type
    l_xdock_to_wip            BOOLEAN;   -- Flag to indicate if the task is xdocked to WIP
    l_transaction_interface_id  NUMBER;  -- For interface recors
    l_dummy_temp_id           NUMBER;
    l_emp_id                  NUMBER;
    l_batch_seq               NUMBER;  --BUG 3306988
    l_lpn_serials_cnt         NUMBER := 0;  --Count of serials in the LPN
    l_skip_mmtt               BOOLEAN := FALSE; --
    l_error_code            NUMBER;
    l_drop_off_time           DATE := Sysdate; --DBI FIX
    l_grp_sec_quantity      NUMBER; --OPM Convergence
    l_grp_sec_uom           VARCHAR2(3); --OPM Convergence
    l_mol_sec_qty                 NUMBER;   --OPM Convergence
    l_mol_sec_qty_detailed        NUMBER;   --OPM Convergence
    l_mol_sec_qty_delivered       NUMBER;   --OPM Convergence
    l_mol_sec_uom_code       VARCHAR2(3); --OPM Convergence
    l_tmp_sec_qty            NUMBER; --OPM Convergence
    l_sec_user_qty NUMBER; --opm convergence
    l_mmtt_sec_qty_tbl            num_tab;  --OPM Convergence
    l_remaining_sec_qty     NUMBER; --OPM Convergence
    l_mmtt_sec_qty    NUMBER;--OPM Convergence
    l_secondary_quantity NUMBER; --OPM Convergence
    l_secondary_uom NUMBER; --OPM Convergence
    l_prim_qty_consumable     NUMBER; --BUG 5075410

    l_msni_inspect_status_tbl num_tab;
    TYPE varchar80_tab IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
    l_msni_lot_tbl varchar80_tab;
    l_msni_qty_tbl num_tab;
    l_inspection_status_tbl num_tab;
    l_ser_inspect_status_tbl num_tab;
    l_ser_lot_num_tbl varchar80_tab;
    TYPE varchar3_tab IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
    l_primary_uom_code_tbl varchar3_tab;
    l_result BOOLEAN;
    -- LMS specific variable
    l_lms_rec_count NUMBER       := 0;
    -- LMS code end


BEGIN
    IF (l_debug = 1) THEN
      DEBUG('Entered complete_putaway_wrapper with the following params:', l_proc_name);
      DEBUG(' p_group_id               ==> '||p_group_id, l_proc_name);
      DEBUG(' p_txn_header_id          ==> '||p_txn_header_id,l_proc_name);
      DEBUG(' p_drop_type              ==> '||p_drop_type,l_proc_name);
      DEBUG(' p_drop_type              ==> '||p_drop_type,l_proc_name);
      DEBUG(' p_lpn_mode               ==> '||p_lpn_mode,l_proc_name);
      DEBUG(' p_lpn_id                 ==> '||p_lpn_id,l_proc_name);
      DEBUG(' p_organization_id        ==> '||p_organization_id,l_proc_name);
      DEBUG(' p_user_id                ==> '||p_user_id,l_proc_name);
      DEBUG(' p_item_id                ==> '||p_item_id,l_proc_name);
      DEBUG(' p_revision               ==> '||p_revision,l_proc_name);
      DEBUG(' p_lot_number             ==> '||p_lot_number,l_proc_name);
      DEBUG(' p_subinventory_code      ==> '||p_subinventory_code,l_proc_name);
      DEBUG(' p_locator_id             ==> '||p_locator_id,l_proc_name);
      DEBUG(' p_quantity               ==> '||p_quantity,l_proc_name);
      DEBUG(' p_uom_code               ==> '||p_uom_code,l_proc_name);
      DEBUG(' p_to_lpn_name            ==> '||p_to_lpn_name,l_proc_name);
      DEBUG(' p_to_lpn_id              ==> '||p_to_lpn_id,l_proc_name);
      DEBUG(' p_project_id             ==> '||p_project_id,l_proc_name);
      DEBUG(' p_task_id                ==> '||p_task_id,l_proc_name);
      DEBUG(' p_reference              ==> '||p_reference, l_proc_name);
      DEBUG(' p_qty_reason_id          ==> '||p_qty_reason_id,l_proc_name);
      DEBUG(' p_loc_reason_id          ==> '||p_loc_reason_id,l_proc_name);
      DEBUG(' p_process_serial_flag    ==> '||p_process_serial_flag,l_proc_name);
      DEBUG(' p_entire_lpn             ==> '||p_entire_lpn,l_proc_name);
      DEBUG(' p_msni_txn_interface_id  ==> '||p_msni_txn_interface_id,l_proc_name);
      DEBUG(' p_product_transaction_id ==> '||p_product_transaction_id,l_proc_name);
      DEBUG(' p_secondary_quantity     ==> '||p_secondary_quantity,l_proc_name);
      DEBUG(' p_secondary_uom          ==> '||p_secondary_uom,l_proc_name);
      DEBUG(' p_lpn_initially_loaded   ==> '||p_lpn_initially_loaded,l_proc_name);
    END IF;

    -- Initialize the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Read the input parameters
    l_group_id               := p_group_id;
    l_product_transaction_id := p_product_transaction_id;
    l_serialized_item        := FALSE;
    l_mo_splt_cnt            := 0;
    l_lpn_serials_cnt        := 0;
    l_skip_mmtt              := FALSE;

    IF (l_debug = 1) THEN
      DEBUG('Entering complete_putaway_wrapper. Entry time : ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), l_proc_name);
    END IF;

    -- Create the save point
    SAVEPOINT complete_putaway_wrap_sp;

    -- Assign p_lpn_mode to l_lpn_mode
    l_lpn_mode := p_lpn_mode;

    -- For manual drops, since a load is not explicitly done first, we need
    -- to perform the activate and complete operation instance for load.
    -- We also then need to activate the drop operation.
    IF (p_drop_type = G_DT_MANUAL_DROP) THEN
      IF (l_debug = 1) THEN
        DEBUG('complete_putaway_wrapper: Activate/Complete operations for Manual Drop');
      END IF;
      l_progress := '5.1';

      BEGIN
        SELECT employee_id
        INTO   l_emp_id
        FROM   fnd_user
        WHERE  user_id = p_user_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (l_debug = 1) THEN
            DEBUG('complete_putaway_wrapper: There is no employee tied to the user');
          END IF;
          l_emp_id := NULL;
      END;
      IF (l_debug = 1) THEN
        DEBUG('complete_putaway_wrapper: Employee ID: ' || l_emp_id);
      END IF;
      l_progress := '5.2';

      BEGIN -- Simulate Load Operation
        IF (l_debug = 1) THEN
          DEBUG('complete_putaway_wrapper: Calling Complete_ATF_Load API');
        END IF;
        l_progress := '5.3';

        WMS_PUTAWAY_UTILS.Complete_ATF_Load
          (x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_org_id         => p_organization_id,
           p_lpn_id         => p_lpn_id,
           p_emp_id         => l_emp_id);
        IF (l_debug = 1) THEN
           DEBUG('complete_putaway_wrapper: Successfully called Complete_ATF_Load');
        END IF;
        l_progress := '5.4';

        -- Check for the return status
        IF (l_debug = 1) THEN
           debug('complete_putaway_wrapper: Return status of API: ' || x_return_status);
        END IF;

        IF x_return_status = fnd_api.g_ret_sts_success THEN
          -- Activate completed successfully.
          NULL;
        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        l_progress := '5.5';
      EXCEPTION
        WHEN OTHERS THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END; -- Simulate Load Operation

      BEGIN -- Activate operation for Drop
        IF (l_debug = 1) THEN
          DEBUG('complete_putaway_wrapper: Calling ATF_For_Manual_Drop API');
        END IF;
        l_progress := '5.6';

        WMS_PUTAWAY_UTILS.ATF_For_Manual_Drop
          (x_return_status => x_return_status,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
           p_call_type     => G_ATF_ACTIVATE_PLAN,
           p_org_id        => p_organization_id,
           p_lpn_id        => p_lpn_id,
           p_emp_id        => l_emp_id);
        IF (l_debug = 1) THEN
           DEBUG('complete_putaway_wrapper: Successfully called ATF_For_Manual_Drop');
        END IF;

        l_progress := '5.7';
        IF (l_debug = 1) THEN
          debug('complete_putaway_wrapper: Return status of API: ' || x_return_status);
        END IF;

        IF x_return_status = fnd_api.g_ret_sts_success THEN
          -- Activate op plan completed successfully.
          NULL;
        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        l_progress := '5.8';
      EXCEPTION
        WHEN OTHERS THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END; -- Activate operation for Drop
    END IF; -- Manual Drop activate/complete operation instance

    --For the item drop scenario, first check if there was a quantity discrepancy
    --and set the flag appropriately
    IF (p_drop_type = G_DT_ITEM_DROP) THEN
      BEGIN
        l_progress := '10';

         --Get the primary_uom_code, lot_control_code and serial_control_code
         --for the item being dropped
        SELECT transaction_quantity
             , transaction_uom
             , primary_quantity
             , primary_uom_code
             , lot_control_code
             , serial_number_control_code
             , secondary_quantity --OPM Convergence
             , secondary_uom --OPM Convergence
        INTO   l_sug_grp_quantity
             , l_grp_uom_code
             , l_grp_prm_quantity
             , l_primary_uom_code
             , l_lot_control_code
             , l_serial_control_code
             , l_grp_sec_quantity
             , l_grp_sec_uom
        FROM   wms_putaway_group_tasks_gtmp
        WHERE  group_id = p_group_id
        AND    transaction_header_id = p_txn_header_id
        AND    row_type = G_ROW_TP_GROUP_TASK;

        IF (l_debug =1) THEN
          DEBUG('The suggested quantity for the group: ' || l_sug_grp_quantity, l_proc_name);
          DEBUG('lot code: ' || l_lot_control_code || ', serial code: ' || l_serial_control_code);
        END IF;

        l_progress := '20';

        --Convert the grp quantity into transaction uom
        IF l_grp_uom_code <> p_uom_code THEN
	   l_uom_con_sug_grp_qty := inv_rcv_cache.convert_qty
	                               (p_inventory_item_id => p_item_id
					,p_from_qty         => l_sug_grp_quantity
					,p_from_uom_code    => l_grp_uom_code
					,p_to_uom_code      => p_uom_code);
	 ELSE
          l_uom_con_sug_grp_qty := l_sug_grp_quantity;
        END IF;

        l_progress := '30';

        --Convert the confirmed quantity into primary uom
        IF (p_uom_code <> l_primary_uom_code) THEN
	   l_prm_user_qty := inv_rcv_cache.convert_qty
	                        (p_inventory_item_id => p_item_id
				 ,p_from_qty         => p_quantity
				 ,p_from_uom_code    => p_uom_code
				 ,p_to_uom_code      => l_primary_uom_code);
        ELSE
          l_prm_user_qty := p_quantity;
        END IF;
        l_sec_user_qty := p_secondary_quantity; --OPM Convergence
        --Set the discrepancy flag if confirmed quantity does not match the
        --total quantity for the current group
        IF l_prm_user_qty <> l_grp_prm_quantity THEN
          l_disc := 'Y';
        ELSE
          l_disc := 'N';
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            DEBUG('Error fetching MMTTs for the current group. Cannot drop', l_proc_name, 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_TASK_ERROR');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
      END;
    ELSE
      --For other drop types, the user would not be confirming quantity and uom
      --We would be transacting only the suggested quantities. Only sub and loc
      --would be user entered. So, set the quantity discrepancy flag as 'N'
      l_disc := 'N';
    END IF; --END IF check qty discrepancy for item drop

    l_progress := '40';

    IF (l_debug = 1) THEN
      DEBUG('complete_putaway_wrapper: Progress: ' || l_progress || '. Quantity Discrepancy flag: ' || l_disc, l_progress);
    END IF;

    --Move Order Splits
    --For an item drop scenario, we would need to split the move order line under
    --the following scenarios:
    --   a) User confirmed lesser than the suggested quantity in the UI
    --   b) Part of the MO Line is detailed to an MMTT record in another group
    --   c) Move Order line is not completely detailed
    --We would need to split the move orders only for an item drop since
    --the user would be transacting the entire quantity for other drop types

    --Decide on move order splits based on whether the item is serialized
    --This is needed since we will be matching the parent transactions with the
    --serials confirmed in the UI
    --The check for serialized item is needed only for a receiving LPN
    --We need this because for splitting move orders, we must first consume those
    --MOLS with serials of the parent txn
    --Eg. MOL1 has serials S1 - S5 with parent tranasction RT1 (rcv_serials_supply)
    --    MOL2 has serials S6 -S10 with parent transaction RT2
    --    User confirms S2, S6, S8 from the UI.
    --We should split MOL1 into MOL1 = 1 and create new line MOL3 for qty 4
    --We should split MOL2 into MOL2 = 2 and create new line MOL4 for qty 3
    --Later we would match the the serials S1, S6 and S8 against the parent txn
    --Even for a receiving LPN, if the user confirms the entire quantity, we
    --would be splitting the move order lines as if it were a non-serialized item
    --since the serials are anyway matched and only the quantity needs to be
    --matched.
    IF (p_drop_type = G_DT_ITEM_DROP) THEN
    --{

      -- BUG 5198628
      -- Get the serialized flag irrespective of l_disc
      IF (p_lpn_context = G_LPN_CONTEXT_RCV) THEN
          --Bug 5208888
          --For internal receipts, serials would be populated even if the serial control
          --code is dynamic at SO issue
          IF (l_serial_control_code = 6) THEN
            SELECT count(1)
            INTO   l_lpn_serials_cnt
            FROM   mtl_serial_numbers
            WHERE  lpn_id = p_lpn_id
            AND    inventory_item_id = p_item_id;
          END IF;
          IF ((l_serial_control_code IN (2, 5)) OR
              (l_serial_control_code = 6 AND p_reference = 'ORDER_LINE_ID') OR
              (l_serial_control_code = 6 AND p_reference = 'SHIPMENT_LINE_ID' AND
               l_lpn_serials_cnt > 0)) THEN
            l_serialized_item := TRUE;
          ELSE
            l_serialized_item := FALSE;
          END IF;
        ELSE
          l_serialized_item := FALSE;
        END IF;
   -- bug 5333789
   -- ELSE
   --   l_serialized_item := FALSE;
   -- END IF;

   -- IF (l_disc = 'Y' ) THEN
   -- bug 5333789

      --Initialize the remaining quantity in primary uom
      l_rem_user_qty := l_prm_user_qty;

      IF (l_debug = 1) THEN
      DEBUG('complete_putaway_wrapper: Progress: ' || l_progress || '. Item Drop scenario. Checking if MO Splits are required', l_proc_name);
      END IF;

      --The logic would be different based on whether the item is serial controlled or not
      -- IF (l_serialized_item) THEN bug 5333789
      IF (l_serialized_item and l_disc = 'Y') THEN
      --{
	 IF (l_debug = 1) THEN
	    DEBUG('complete_putaway_wrapper: Progress: ' || l_progress || '. Processing the MO lines for a serialized item', l_proc_name);
	 END IF;

	 l_progress := '50';

	 --R12: Find out the serials entered by the user in the UI,
	 --grouping by their inspection_status and lot_number
	 SELECT count(1), Nvl(msn.inspection_status,-1), Nvl(msn.lot_number,'&*_')
	 bulk collect INTO  l_msni_qty_tbl, l_msni_inspect_status_tbl, l_msni_lot_tbl
          FROM   mtl_serial_numbers_interface msni, mtl_serial_numbers msn
	  WHERE  msni.transaction_interface_id = p_msni_txn_interface_id
	   AND   msn.serial_number BETWEEN msni.fm_serial_number AND Nvl(msni.to_serial_number,msni.fm_serial_number)
	   AND   Length(msn.serial_number) = Length(msni.fm_serial_number)
	   GROUP BY msn.inspection_status, msn.lot_number;

	 IF (l_debug = 1) THEN
	    debug('Number of serial groups:'||l_msni_qty_tbl.COUNT,l_proc_name);
	 END IF;

	 --R12: Loop through each group of serials and find
	 --the MOL to consume
	 FOR i IN 1..l_msni_inspect_status_tbl.COUNT LOOP

	    IF (l_debug = 1) THEN
	       debug('Group ('||i||') Number:'||l_msni_qty_tbl(i)||' Inspect Status:'||
		     l_msni_inspect_status_tbl(i)||' lot NUMBER:'
		     ||l_msni_lot_tbl(i),l_proc_name);
	    END IF;

	    --Processing for a serialized item

	    OPEN serial_mol_csr(l_msni_inspect_status_tbl(i),l_msni_lot_tbl(i));

	    LOOP
	       FETCH serial_mol_csr
		 INTO l_mol_line_id
		 , l_mol_qty
		 , l_mol_qty_detailed
		 , l_mol_qty_delivered
		 , l_mol_uom_code
		 , l_mol_sec_qty --OPM Convergence
		 , l_mol_sec_qty_detailed --OPM Convergence
		 , l_mol_sec_qty_delivered --OPM Convergence
		 , l_mol_sec_uom_code;
		 EXIT WHEN serial_mol_csr%NOTFOUND;

	       l_progress := '60';

	       --Have consumed the entire quantity confirmed and marked the temp table records
	       IF l_rem_user_qty = 0 OR l_msni_qty_tbl(i) = 0 THEN
		  EXIT;
	       END IF;

	       IF (l_debug = 1) THEN
		  DEBUG('complete_putaway_wrapper: Working with mol: ' || l_mol_line_id ||
			' qty: ' || l_mol_qty || ' qty det: ' || l_mol_qty_detailed || ' qty del: '
			|| l_mol_qty_delivered || ' uom_code: ' || l_mol_uom_code, l_proc_name);
	       END IF;

	       --First get the difference between the quantity and quantity delivered
	       l_tmp_qty1 := l_mol_qty - l_mol_qty_delivered;

	       l_progress := '70';

	       --Convert this into primary uom
	       IF (l_mol_uom_code <> l_primary_uom_code) THEN
		  l_tmp_prm_qty := inv_rcv_cache.convert_qty
		                      (p_inventory_item_id => p_item_id
				       ,p_from_qty         => l_tmp_qty1
				       ,p_from_uom_code    => l_mol_uom_code
				       ,p_to_uom_code      => l_primary_uom_code
				       );
		ELSE
		  l_tmp_prm_qty := l_tmp_qty1;
	       END IF;

	       IF(l_debug = 1) THEN
		  DEBUG('complete_putaway_wrapper: Progress: ' || l_progress ||
			'. Available MO quantity for this group: ' || l_tmp_prm_qty, l_proc_name);
	       END IF;

	       l_progress := '80';

	       --Now that we are ready with quantity calculations, mark the all tasks
	       --in the current group for this move order line
	       UPDATE wms_putaway_group_tasks_gtmp
		 SET    process_flag = 'Y'
		 WHERE  group_id = p_group_id
		 AND    transaction_header_id = p_txn_header_id
		 AND    move_order_line_id = l_mol_line_id;

	       IF l_tmp_prm_qty <= l_msni_qty_tbl(i) THEN
		  --Consumed the entire MOL qty. Still need to check other MOLs
		  l_rem_user_qty := l_rem_user_qty - l_tmp_prm_qty;
		  l_msni_qty_tbl(i) := l_msni_qty_tbl(i) - l_tmp_prm_qty;
		ELSE
		  --OK. The total available quantity is greater than the confirmed quantity
		  --We have to split the move order line. So populate the table
		  l_mo_splt_cnt := l_mo_splt_cnt + 1;

		  --MOL.qty = 10, MOL.qty_delivered = 4. remaining user qty = 3
		  --So we need to split the mol and create a mew one for 10-4-3 = 3
		  l_qty_to_split := l_tmp_prm_qty - l_msni_qty_tbl(i);

		  --First decrement the remaining quantity
		  l_rem_user_qty := l_rem_user_qty - l_msni_qty_tbl(i);
		  l_msni_qty_tbl(i) := 0;

		  IF (l_debug = 1) THEN
		     DEBUG('complete_putaway_wrapper: Need to split the move order line id: '
			   || l_mol_line_id || ' with qty: ' || l_qty_to_split, l_proc_name);
		  END IF;

		  l_mos_to_split_tbl(l_mo_splt_cnt).line_id := l_mol_line_id;
		  l_mos_to_split_tbl(l_mo_splt_cnt).prim_qty := l_qty_to_split;
	       END IF;   --END IF compare the remaining qty with available qty
	    END LOOP;   --END loop through each mol for the current group

	    IF l_msni_qty_tbl(i) > 0 THEN
	       IF(l_debug = 1) THEN
		  DEBUG('complete_putaway_wrapper: Unable to match MOL for all serial IN the group! How?',l_proc_name);
	       END IF;
	       RAISE fnd_api.g_exc_error;
	    END IF;
	 END LOOP;

      --MO Splits for a non-serialized item
      --}
      ELSE
      --{
        l_progress := '90';

        --Processing for a non-serialized item
        IF (l_debug = 1) THEN
          DEBUG('complete_putaway_wrapper: Progress: ' || l_progress ||
            '. Processing the MO lines for a non-serialized item', l_proc_name);
        END IF;

        OPEN mol_csr;
        LOOP
	  FETCH mol_csr
	   INTO l_mol_line_id
	      , l_mol_qty
              , l_mol_qty_detailed
              , l_mol_qty_delivered
              , l_mol_uom_code
              , l_mol_sec_qty --OPM Convergence
              , l_mol_sec_qty_detailed --OPM Convergence
              , l_mol_sec_qty_delivered --OPM Convergence
              , l_mol_sec_uom_code; --OPM Convergence
	  EXIT WHEN mol_csr%NOTFOUND;

          --Have consumed the entire quantity confirmed and marked the temp table records
          IF l_rem_user_qty = 0 THEN
            EXIT;
          END IF;

	  --BUG 5075410: MOL1 has 6, MMTT1 3 LOC1 MMTT2 3 LOC2
	  --             MOL2 has 3, MMTT3 3 LOC1
	  --System would suggest task for 6 to LOC1, 3 to LOC2
	  --If the user enter 5 for the first task, then we cannot
	  --just use the 5 from MOL1.  We must use 3 from MOL1 and
	  --2 from MOL2, or vice versa.  So the following check is
	  --needed to find out the quantity from the MOL that is
	  --suggested for the current group of tasks
	  BEGIN
	     SELECT  SUM(mmtt.primary_quantity)
	       INTO  l_prim_qty_consumable
	       FROM  mtl_material_transactions_temp mmtt
	       ,     mtl_txn_request_lines mtrl
	       WHERE mmtt.transaction_header_id = p_txn_header_id
	       AND   mtrl.line_id = l_mol_line_id
	       AND   mtrl.line_id = mmtt.move_order_line_id;
	  EXCEPTION
	     WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		   debug('Error querying total consumable qty. SQLCODE:'||SQLCODE||' Sqlerrm:'||SQLERRM,l_proc_name,1);
		END IF;
	  END;

          IF (l_debug = 1) THEN
            DEBUG('complete_putaway_wrapper: Working with mol: ' || l_mol_line_id ||
              ' qty: ' || l_mol_qty || ' qty det: ' || l_mol_qty_detailed || ' qty del: '
              || l_mol_qty_delivered || ' uom_code: ' || l_mol_uom_code||
	      ' consumable qty'||l_prim_qty_consumable, l_proc_name);
          END IF;

          --First get the difference between the quantity and quantity delivered
          l_tmp_qty1 := l_mol_qty - l_mol_qty_delivered;

          --Convert this into primary uom
          IF (l_mol_uom_code <> l_primary_uom_code) THEN
	     l_tmp_prm_qty := inv_rcv_cache.convert_qty
	                         (p_inventory_item_id => p_item_id
				  ,p_from_qty         => l_tmp_qty1
				  ,p_from_uom_code    => l_mol_uom_code
				  ,p_to_uom_code      => l_primary_uom_code);
          ELSE
            l_tmp_prm_qty := l_tmp_qty1;
          END IF;

          /*OPM Convergence get the difference between the secondary quantity
            and the secondary quantity delivered. */
          l_tmp_sec_qty := l_mol_sec_qty - l_mol_sec_qty_delivered;

          l_progress := '100';

          IF(l_debug = 1) THEN
            DEBUG('complete_putaway_wrapper: Progress: ' || l_progress ||
             '. Available MO quantity for this group: ' || l_tmp_prm_qty, l_proc_name);
          END IF;

          --Now that we are ready with quantity calculations, mark the all tasks
          --in the current group for this move order line
          UPDATE wms_putaway_group_tasks_gtmp
          SET    process_flag = 'Y'
          WHERE  group_id = p_group_id
          AND    transaction_header_id = p_txn_header_id
          AND    move_order_line_id = l_mol_line_id;

	  IF l_prim_qty_consumable <= l_rem_user_qty THEN
            l_rem_user_qty := l_rem_user_qty - l_prim_qty_consumable;

	    IF (l_prim_qty_consumable < l_tmp_prm_qty) THEN
	       l_qty_to_split := l_tmp_prm_qty - l_prim_qty_consumable;
	       IF (l_debug = 1) THEN
		  DEBUG('complete_putaway_wrapper: Need to split the move order line id: '
			|| l_mol_line_id || ' with qty: ' || l_qty_to_split, l_proc_name);
	       END IF;

	       l_mo_splt_cnt := l_mo_splt_cnt + 1;
	       l_mos_to_split_tbl(l_mo_splt_cnt).line_id := l_mol_line_id;
	       l_mos_to_split_tbl(l_mo_splt_cnt).prim_qty := l_qty_to_split;
	    END IF;
	  ELSE
            --OK. The total available quantity is greater than the confirmed quantity
            --We have to split the move order line. So populate the table
            l_mo_splt_cnt := l_mo_splt_cnt + 1;

            --MOL.qty = 10, MOL.qty_delivered = 4. remaining user qty = 3
            --So we need to split the mol and create a mew one for 10-4-3 = 3
            l_qty_to_split := l_tmp_prm_qty - l_rem_user_qty;

            IF (l_debug = 1) THEN
              DEBUG('complete_putaway_wrapper: Need to split the move order line id: '
                || l_mol_line_id || ' with qty: ' || l_qty_to_split, l_proc_name);
            END IF;

            l_mos_to_split_tbl(l_mo_splt_cnt).line_id := l_mol_line_id;
            l_mos_to_split_tbl(l_mo_splt_cnt).prim_qty := l_qty_to_split;

            --Non-serialized item. Only one MO line can be split
            l_rem_user_qty := 0;
          END IF;   --END IF compare remaining qty and MOL qty
        END LOOP;   --END loop through each mol for the current group
      --}
      END IF;   --END IF MO processing based on serialized flag

      IF (l_rem_user_qty > 0) THEN
	 IF (l_debug = 1) THEN
	    DEBUG('complete_putaway_wrapper: l_rem_user_qty > 0. Unable to find MOL for qty.  There must be some data corruption'||l_proc_name);
	 END IF;
	 RAISE fnd_api.g_exc_error;
      END IF;

      --Close the mol cursor
      IF mol_csr%ISOPEN THEN
        CLOSE mol_csr;
      END IF;

      IF serial_mol_csr%ISOPEN THEN
	 CLOSE serial_mol_csr;
      END IF;

      --If at all any move order lines belonging to the current group have been
      --identified for splits, they would have been populated in the PL/SQL table
      --Loop through each and call the split_mo API to split the move order lines
      --Pass two additional parameters that are needed to sync up the
      --global temporary table with the move order lines/MMTTs so that when we
      --actually loop through the tasks in the group, they will reflect the changes
      IF (l_debug = 1) THEN
        DEBUG('complete_putaway_wrapper: Count of move order lines that need to be split: ' || l_mo_splt_cnt, l_proc_name);
      END IF;

      l_progress := '110';

      IF (l_mo_splt_cnt > 0) THEN
        FOR i IN 1 .. l_mo_splt_cnt LOOP
          l_qty_to_split := l_mos_to_split_tbl(i).prim_qty;
          l_mo_splt_tb(1).prim_qty := l_qty_to_split;
          --Call the Split_MO API
          IF (l_debug = 1) THEN
            debug('complete_putaway_wrapper: Progress: ' || l_progress ||
              '. Calling the split_mo API with primary qty: ' || l_qty_to_split, 4);
          END IF;

          inv_rcv_integration_apis.split_mo(
              p_orig_mol_id           =>  l_mos_to_split_tbl(i).line_id
            , p_mo_splt_tb            =>  l_mo_splt_tb
            , p_updt_putaway_temp_tbl =>  FND_API.G_TRUE
            , p_txn_header_id         =>  p_txn_header_id
            , x_return_status         =>  x_return_status
            , x_msg_count             =>  x_msg_count
            , x_msg_data              =>  x_msg_data);

          IF (l_debug = 1) THEN
            DEBUG('complete_putaway_wrapper: split_mo API return status: ' || x_return_status, 4);
          END IF;

          IF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          IF (l_debug = 1) THEN
            DEBUG('complete_putaway_wrapper: new MOL ID: ' || l_mo_splt_tb(1).line_id, 4);
          END IF;

	  --Bug 5075410: Cannot cleanup here because say 1 MOL
	  --have two MMTT, then complete 1 of the task would cause
	  --cleanup of the other MMTT, and transaction will fail
	  --when user tries to complete the second task
        END LOOP;   --END Loop through each MOL identified for split
      END IF;   --END IF l_mo_splt_cnt > 0
    -- bug 5333789
    --}
    ELSE
    --{
        l_serialized_item := FALSE;
    --}
    -- bug 5333789
    END IF;    --END IF p_drop_type = G_DT_ITEM_DROP AND l_disc = 'Y'

    --Now that the MO splits are done, we have the temp table in sync and we
    --know the rows that we need to process.

    l_progress := '120';

    --Get the lpn_controlled_flag and subinventory_type attributes for the
    --destination subinventory
    BEGIN
      SELECT NVL(lpn_controlled_flag, 1)
           , NVL(subinventory_type, 1)
      INTO   l_lpn_controlled_flag
           , l_drop_sub_type
      FROM   mtl_secondary_inventories
      WHERE  organization_id = p_organization_id
      AND    secondary_inventory_name = p_subinventory_code;
    EXCEPTION
      WHEN OTHERS THEN
        l_lpn_controlled_flag := 2;
    END;

    IF (p_lpn_context IN (G_LPN_CONTEXT_INV, G_LPN_CONTEXT_WIP)) THEN

      SELECT mtl_material_transactions_s.NEXTVAL
      INTO   l_new_txn_header_id
      FROM   DUAL;

      --For an item drop of an Inventory/WIP LPN with quantity
      --discrepancy/partial lpn drop,
      --we would have marked the serials in UI. Have to first fetch all such
      --serials and then consume these for each task on a FIFO basis.
      --Basically, no matching is needed unlike receiving LPNs
      IF ((p_drop_type = G_DT_ITEM_DROP) AND (l_disc = 'Y' OR p_entire_lpn = 'N') AND
          (l_serial_control_code IN (2,5))) THEN

        l_progress := '130';

	IF (l_debug = 1) THEN
	   DEBUG('complete_putaway_wrapper: Progress: ' ||l_progress ||'. Process Serials', l_proc_name);
	END IF;

        OPEN msnt_ser_csr(p_lpn_id, p_item_id);
        FETCH msnt_ser_csr
        BULK COLLECT INTO l_ser_num_tbl, l_ser_mark_tbl;

        IF (l_debug = 1) THEN
          DEBUG('complete_putaway_wrapper: Progress: ' || l_progress || '. Serial item partial qty. '
            || l_ser_num_tbl.COUNT || ' serials confirmed in UI', l_proc_name);
        END IF;
      END IF;
    ELSE
      --For a reveiving LPN, setting l_new_txn_header_id to the parameter.
      --This is not actually needed since for receiving LPNs, a new txn_hdr_id
      --would always be created for each MMTT we process.
      l_new_txn_header_id := p_txn_header_id;

      --R12: Open the rcv_serials_csr here.  It will be used later
      --when we try to match serials with the MMTT quantitty
      IF (p_drop_type = g_dt_item_drop AND
	  l_disc = 'Y'AND
	  ((l_serial_control_code > 1  AND l_serial_control_code <> 6) OR
	   (l_serial_control_code = 6 AND p_reference = 'ORDER_LINE_ID') OR
	   (l_serial_control_code = 6 AND p_reference = 'SHIPMENT_LINE_ID' AND l_lpn_serials_cnt > 0))) THEN

	 OPEN rcv_serials_csr;
	 FETCH rcv_serials_csr
	 BULK COLLECT INTO l_ser_num_tbl, l_ser_mark_tbl,l_ser_inspect_status_tbl,l_ser_lot_num_tbl;

	 DELETE FROM mtl_serial_numbers_interface
	   WHERE transaction_interface_id = p_msni_txn_interface_id;

	 IF (l_debug = 1) THEN
	    debug('Number of MSNI deleted: '||SQL%rowcount,l_proc_name,9);
	 END IF;
      END IF;
    END IF;   --END IF Inventory/WIP LPNs

    IF (msnt_ser_csr%ISOPEN) THEN
      CLOSE msnt_ser_csr;
    END IF;

    --Nested LPN changes
    pre_process_lpn(
          x_return_status           => x_return_status
        , x_msg_count               => x_msg_count
        , x_msg_data                => x_msg_data
        , p_from_lpn_id             => p_lpn_id
        , p_organization_id         => p_organization_id
        , p_subinventory_code       => p_subinventory_code
        , p_lpn_mode                => l_lpn_mode
        , p_locator_id              => p_locator_id
        , p_to_lpn_id               => p_to_lpn_id
        , p_project_id              => p_project_id
        , p_task_id                 => p_task_id
        , p_user_id                 => p_user_id
        , p_lpn_context             => p_lpn_context
        , p_batch_id                => l_new_txn_header_id
        , p_batch_seq               => 1
        , p_pack_trans_id           => l_new_txn_header_id
        , x_batch_seq               => l_batch_seq ); --BUG 3544918
    IF (l_debug = 1) THEN
      DEBUG('complete_putaway_wrapper: Progress: ' || l_progress || '. pre_process_lpn returns: ' || x_return_status, 4);
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    -- Nested LPN changes end;

    --We should be calling complete_putaway for the eligible rows
    --Based on the drop type, open the appropriate cursors
    IF (p_drop_type IN (G_DT_CONSOLIDATED_DROP, G_DT_ITEM_DROP)) THEN
      OPEN all_tasks_csr(l_disc);
    ELSIF (p_drop_type IN (G_DT_USER_DROP, G_DT_MANUAL_DROP)) THEN
      IF (l_debug = 1) THEN
        DEBUG('complete_putaway_wrapper: Manual Drop case. Opening the md_tasks_csr to fetch the tasks', l_proc_name);
      END IF;
      OPEN md_tasks_csr;
    END IF;

    --Fetch all the tasks for the current group being putaway
    --LOOP
    IF (p_drop_type IN (G_DT_CONSOLIDATED_DROP, G_DT_ITEM_DROP)) THEN
      l_progress := 140;
      IF (l_debug = 1) THEN
        DEBUG('complete_putaway_wrapper: Fetching the all_tasks_csr...', l_proc_name);
      END IF;
      FETCH all_tasks_csr
      BULK COLLECT INTO
          l_temp_id_tbl
        , l_mol_lpn_id_tbl
        , l_mol_line_id_tbl
        , l_mmtt_item_id_tbl
        , l_mmtt_rev_tbl
        , l_mmtt_lot_tbl
        , l_mmtt_qty_tbl
        , l_mmtt_uom_tbl
        , l_parent_txn_id_tbl
        , l_bk_del_det_tbl
        , l_xdock_type_tbl
        , l_wip_sup_typ_tbl
        , l_mmtt_sec_qty_tbl
        , l_inspection_status_tbl
        , l_primary_uom_code_tbl;
      --EXIT WHEN all_tasks_csr%NOTFOUND;
    ELSIF (p_drop_type IN (G_DT_USER_DROP, G_DT_MANUAL_DROP)) THEN
      l_progress := '150';
      IF (l_debug = 1) THEN
        DEBUG('complete_putaway_wrapper: Fetching the md_tasks_csr...', l_proc_name);
      END IF;
      FETCH md_tasks_csr
      BULK COLLECT INTO
          l_temp_id_tbl
        , l_mol_lpn_id_tbl
        , l_mol_line_id_tbl
        , l_mmtt_item_id_tbl
        , l_mmtt_rev_tbl
        , l_mmtt_lot_tbl
        , l_mmtt_qty_tbl
        , l_mmtt_uom_tbl
        , l_parent_txn_id_tbl
        , l_bk_del_det_tbl
        , l_xdock_type_tbl
        , l_wip_sup_typ_tbl
        , l_mmtt_sec_qty_tbl
	, l_inspection_status_tbl
        , l_primary_uom_code_tbl;
      --EXIT WHEN md_tasks_csr%NOTFOUND;
    END IF;

    --At this stage, I know the list of 'All Task' rows for the current group.
    --Will be fetching the details of each task, do the calculations and call
    --the complete_putaway for the current task
    IF (l_debug = 1) THEN
      DEBUG('complete_putaway_wrapper: Progress: ' || l_progress || 'No. of tasks for this group: ' || l_temp_id_tbl.COUNT, l_proc_name);
    END IF;

    IF (l_temp_id_tbl.COUNT = 0) THEN
      fnd_message.set_name('WMS', 'WMS_TASK_ERROR');
      fnd_msg_pub.ADD;
    END IF;

    IF (p_drop_type = G_DT_ITEM_DROP) THEN
      --First get the total drop quantity in transaction uom
      l_remaining_qty := p_quantity;
      l_remaining_sec_qty := p_secondary_quantity;
    END IF;

    FOR i IN 1 .. l_temp_id_tbl.COUNT
    LOOP

      l_mmtt_temp_id           := l_temp_id_tbl(i);
      l_item_id                := l_mmtt_item_id_tbl(i);
      l_product_transaction_id := p_product_transaction_id;
      --Initialize the count of serials to be consumed for the current task
      l_cur_task_ser_count := 0;

      --After inspecting a serialized item, there is one MO line for each serial inspected.
      --If the user confirms partial quantity, then we might be fetching a move order line
      --whose parent RT record might not correspond to the serial confirmed on the UI.
      -- eg: MO1   RT1   1 Ea  SN1, MO2   RT2  1 Ea  SN2, MO3   RT3   1 Ea SN3
      --If the user confirms the serials SN1 and SN3 on the UI, we should create deliver
      --RTIs only for RT1 and RT3. But we might have MMTT corresponding to MO2 fetched by
      --the tasks cursor. In which case, we would not be able to match the serials with the
      --parent transaction. So we should not call the complete_putaway API for this MMTT.
      --For this purpose have created the flag below which would always be FALSE
      --and will be set only if no serials can be matched for the current move order line
      l_skip_mmtt := FALSE;

      l_progress := '160';
      IF (l_debug = 1) THEN
        DEBUG('complete_putaway_wrapper: Progress: ' || l_progress || '. Am working on the task with temp_id: ' || l_mmtt_temp_id, l_proc_name);
      END IF;

      --Process the current task based on the drop type
      IF (p_drop_type = G_DT_ITEM_DROP) THEN

        --If I have consumed the entire drop quantity confirmed by the user
        --should be coming out of the processing loop
        IF (l_remaining_qty = 0) THEN
          IF (l_debug = 1) THEN
            DEBUG('complete_putaway_wrapper: Have consumed entire quantity confirmed by the user. No further processing', l_proc_name);
          END IF;
          EXIT;
        END IF;

        IF (l_debug =1) THEN
          DEBUG('complete_putaway_wrapper: Qty still to drop: ' || l_remaining_qty, l_proc_name);
        END IF;

        --Convert the current task quantity into the user confirmed UOM code
        IF (l_mmtt_uom_tbl(i) <> p_uom_code) THEN
	   l_quantity := inv_rcv_cache.convert_qty
	                   (p_inventory_item_id => l_mmtt_item_id_tbl(i)
			    ,p_from_qty         => l_mmtt_qty_tbl(i)
			    ,p_from_uom_code    => l_mmtt_uom_tbl(i)
			    ,p_to_uom_code      => p_uom_code);
        ELSE
          l_quantity := l_mmtt_qty_tbl(i);
        END IF;

        IF (l_debug = 1) THEN
          DEBUG('Item Drop - Current Task quantity: ' || l_quantity, l_proc_name);
        END IF;

        l_progress := '170';

        IF (l_disc = 'Y' OR p_entire_lpn = 'N') THEN
          SELECT mtl_material_transactions_s.NEXTVAL
          INTO l_dummy_temp_id
          FROM dual;
        END IF;

        IF (l_quantity <= l_remaining_qty) THEN
          l_remaining_qty := l_remaining_qty - l_quantity;
        ELSE  --Is this possible?
          l_remaining_qty := l_quantity;
        END IF;

        --Set the rev, lot, sub and loc from the values confirmed in the UI
        l_lpn_id            := l_mol_lpn_id_tbl(i);
        l_entire_lpn        := p_entire_lpn;
        l_revision          := p_revision;
        l_lot_number        := p_lot_number;
        l_uom_code          := p_uom_code;
        l_subinventory_code := p_subinventory_code;
        l_locator_id        := p_locator_id;

        --If user scans the same LPN in case of quantity discrepancy, we need
        --to stamp the transfer_lpn_id and not content_lpn_id. This will
        --be done through the p_entire_lpn_flag. Reference - Bug #2310097
        IF (l_disc = 'Y' and l_entire_lpn = 'Y') THEN
          l_entire_lpn := 'N';
        END IF;

        --In case of a quantity discrepancy for a lot/serialized items,
        --have to create the interface records for lots and serials from
        --here itself and we would not be doing it from complete_putaway
        --More importantly, do it only if there is a quantity discrepancy
	--Also create interface record if entire_lpn is 'N'
        IF (l_disc = 'Y' OR p_entire_lpn = 'N') THEN
         --Convert the task quantity into primary uom
          IF (l_mmtt_uom_tbl(i) <> l_primary_uom_code) THEN
	     l_mmtt_prm_qty := inv_rcv_cache.convert_qty
	                          (p_inventory_item_id => l_mmtt_item_id_tbl(i)
				   ,p_from_qty         => l_mmtt_qty_tbl(i)
				   ,p_from_uom_code    => l_mmtt_uom_tbl(i)
				   ,p_to_uom_code      => l_primary_uom_code);
          ELSE
            l_mmtt_prm_qty := l_mmtt_qty_tbl(i);
          END IF;   --END IF UOM conversions for lot quantity
          l_mmtt_sec_qty := l_mmtt_qty_tbl(i); --OPM Convergence

          IF (p_lpn_context = G_LPN_CONTEXT_RCV) THEN
            --On inspecting a serialized item, one move order line is created for each
            --serial number. When the user confirms the serials on the UI, we generate
            --one single product_transaction_id for all such serials. However, when we
            --create the RTI records for these we have to associate only that serial
            --number corresponding to the parent transaction. So in such cases, we have to
            --generate a new value of product_transaction_id while updating the MSNI
            --ramarava
            IF (l_serialized_item AND l_mmtt_prm_qty = 1) THEN
              SELECT  rcv_transactions_interface_s.NEXTVAL
              INTO    l_product_transaction_id
              FROM    sys.dual;
            END IF;

            --Insert MSNI for receiving LPN
            IF (l_lot_control_code > 1 AND p_lot_number IS NOT NULL) THEN
              l_progress := '180';
              IF (l_debug =1) THEN
                DEBUG('complete_putaway_wrapper: Progress: ' || l_progress ||
                      ' Have to create MTLIs for prm qty ' || l_mmtt_prm_qty, l_proc_name);
              END IF;

              --Get the lot expiration date and lot status
              SELECT  expiration_date
                    , status_id
              INTO    l_lot_expiration_date
                    , l_lot_status_id
              FROM    mtl_lot_numbers
              WHERE   lot_number = p_lot_number
              AND     inventory_item_id = p_item_id
              AND     organization_id = p_organization_id;

              --Call the insert_mtli API to insert the lot_number in MTLI
              inv_rcv_integration_apis.insert_mtli(
                  p_api_version                 =>  1.0
                , p_init_msg_lst                =>  FND_API.G_FALSE
                , x_return_status               =>  x_return_status
                , x_msg_count                   =>  x_msg_count
                , x_msg_data                    =>  x_msg_data
                , p_transaction_interface_id    =>  l_dummy_temp_id --l_mmtt_temp_id
                , p_lot_number                  =>  p_lot_number
                , p_transaction_quantity        =>  l_mmtt_qty_tbl(i)
                , p_primary_quantity            =>  l_mmtt_prm_qty
                , p_organization_id             =>  p_organization_id
                , p_inventory_item_id           =>  p_item_id
                , p_expiration_date             =>  l_lot_expiration_date
                , p_status_id                   =>  l_lot_status_id
                , x_serial_transaction_temp_id  =>  l_serial_temp_id
                , p_product_transaction_id      =>  l_product_transaction_id
                , p_product_code                =>  'RCV'
                , p_att_exist                   =>  'Y'
                , p_update_mln                  =>  'N'
                , p_secondary_quantity          =>  l_mmtt_sec_qty); --OPM CONVERGENCE

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                IF (l_debug = 1) THEN
                  DEBUG('complete_putaway_wrapper: Error at progress: ' || l_progress ||
                        ' insert_mtli returns g_exc_error', l_proc_name, 1);
                END IF;
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                IF (l_debug = 1) THEN
                  DEBUG('complete_putaway_wrapper: Error at progress: ' || l_progress ||
                        ' insert_mtli returns g_unexp_error', l_proc_name, 1);
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

              IF (l_debug = 1) THEN
                DEBUG('complete_putaway_wrapper: Inserted MTLI intf_txn_id: ' || l_transaction_interface_id ||
                      ', ser_temp_id : ' || l_serial_temp_id || ' , prod_txn_id: ' || l_product_transaction_id);
              END IF;
            END IF;   --END Insert MTLI for receiving LPN

            --Match serial numbers for receiving LPN
            IF ((l_serial_control_code > 1  AND l_serial_control_code <> 6) OR
                (l_serial_control_code = 6 AND p_reference = 'ORDER_LINE_ID') OR
                (l_serial_control_code = 6 AND p_reference = 'SHIPMENT_LINE_ID' AND
                 l_lpn_serials_cnt > 0)) THEN

              l_progress := '190';
              IF (l_debug =1) THEN
                DEBUG('complete_putaway_wrapper: Progress: ' || l_progress ||
                      ' Should match serials for the parent txn ' || l_parent_txn_id_tbl(i), l_proc_name);
              END IF;

              FOR j in 1 .. l_ser_num_tbl.COUNT LOOP

		 IF ((l_ser_mark_tbl(j) = 'Y') OR
		     (Nvl(l_ser_inspect_status_tbl(j),-1) <> Nvl(l_inspection_status_tbl(i),-1)) OR
		     (Nvl(l_ser_lot_num_tbl(j),'&*_') <> Nvl(l_lot_number,'&*_'))) THEN
		    NULL;
		  ELSE
		    --The MSNI records would have been created with a dummy interface_transaction_id.
		    --On matching the serial, we need to update the transaction_interface_id
		    --with the transaction_temp_id (for a serial and non-lot controlled item)
		    --or with the serial_transaction_temp_id of the MTLI (for lot and serial controlled item)
		    l_cur_ser_number := l_ser_num_tbl(j);
		    DEBUG('complete_putaway_wrapper: cur_serial_number: ' || l_cur_ser_number);

		    IF (l_lot_control_code > 1) THEN
		       l_ser_intf_id := l_serial_temp_id;
		     ELSE
		       l_ser_intf_id := l_dummy_temp_id;--l_mmtt_temp_id;
		    END IF;

		    -- INSERT MSNI HERE
		    l_result := wms_task_dispatch_put_away.insert_msni_helper
		                         (p_txn_if_id         =>  l_ser_intf_id
					  , p_serial_number   =>  l_cur_ser_number
					  , p_org_id          =>  p_organization_id
					  , p_item_id         =>  p_item_id
					  , p_product_txn_id  =>  l_product_transaction_id
					  );

		    IF NOT l_result THEN
		       IF (l_debug = 1) THEN
			  debug('Failure while Inserting MSNI records - lot and serial controlled item',l_proc_name);
		       END IF;
		       RAISE fnd_api.g_exc_unexpected_error;
		    END IF; -- END IF check l_result

		    l_cur_task_ser_count := l_cur_task_ser_count + 1;
		    l_ser_mark_tbl(j) := 'Y';

		    IF (l_cur_task_ser_count = l_mmtt_prm_qty) THEN
		       EXIT;
		    END IF;

		 END IF;
              END LOOP;   --END LOOP through serials for the parent transaction

	      --On matching all the serials for the current task, exit out the loop
	      IF (l_cur_task_ser_count = l_mmtt_prm_qty) THEN
		 l_skip_mmtt := FALSE; -- Bug 3495726 issue 33
	       ELSE --l_cur_task_ser_count < l_mmtt_prm_qty
		 IF (l_debug = 1) THEN
		    DEBUG('complete_putaway_wrapper: l_cur_task_ser_count < l_mmtt_prm_qty.  how???',l_proc_name);
		 END IF;
	      END IF;   --END IF check if all serials are consumed

	      --We have now consumed all the serials for the current task after
              --matching them with the serials entered.
              --Compare the serials consumed with the task quantity in primary uom
              --In case of a mismatch, throw error
              l_progress := '200';
              IF (l_debug = 1) THEN
                DEBUG('complete_putaway_wrapper: Progress: ' || l_progress || '. Have matched ' ||
                       l_cur_task_ser_count || ' as against the task qty: ' || l_mmtt_prm_qty);
              END IF;
              IF (l_cur_task_ser_count <> l_mmtt_prm_qty) THEN
                NULL; --Do I throw the serial mismatch error here itself
              END IF;
            END IF;   --END IF Match serial numbers for receiving LPN
          --LPN context is Inventory/WIP
          ELSE
            --Create MSNT records for the serials confirmed from the UI
            l_progress := '210';
            IF (l_debug = 1) THEN
              DEBUG('complete_putaway_wrapper: Progress: ' || l_progress ||
                '. INV/WIP LPN. Count of serials confirmed in the UI: ' || l_ser_num_tbl.COUNT, l_proc_name);
            END IF;

            FOR k IN 1 .. l_ser_num_tbl.COUNT LOOP
              --Process the serial only if the serial has not already been
              --marked
              IF l_ser_mark_tbl(k) <> 'Y' THEN

                --For a serialized item, the user can enter the quantity
                --ONLY in the item's primary UOM
                IF l_remaining_qty = 0 THEN
		  l_ser_qty := l_mmtt_prm_qty;
                ELSIF l_remaining_qty < l_mmtt_prm_qty THEN
                  l_ser_qty := l_remaining_qty;
                ELSE
                  l_ser_qty := l_mmtt_prm_qty;
                END IF;

                l_cur_ser_number := l_ser_num_tbl(k);

                IF (l_lot_control_code > 1) THEN
                  l_action := 2;
                ELSE
                  l_action := 3;
                END IF;

                --Call the API to create the MSNT records for the current serial number
                wms_task_dispatch_gen.process_lot_serial(
                    p_org_id        =>  p_organization_id
                  , p_user_id       =>  p_user_id
                  , p_temp_id       =>  l_mmtt_temp_id
                  , p_item_id       =>  p_item_id
                  , p_qty           =>  l_ser_qty
                  , p_uom           =>  p_uom_code
                  , p_lot           =>  p_lot_number
                  , p_fm_serial     =>  l_cur_ser_number
                  , p_to_serial     =>  l_cur_ser_number
                  , p_action        =>  l_action
                  , x_return_status =>  x_return_status
                  , x_msg_count     =>  x_msg_count
                  , x_msg_data      =>  x_msg_data);

                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  IF (l_debug = 1) THEN
                    DEBUG('complete_putaway_wrapper: Error at progress: ' || l_progress ||
                      ' process_lot_serial API returns g_exc_error', l_proc_name, 1);
                  END IF;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  IF (l_debug = 1) THEN
                    DEBUG('complete_putaway_wrapper: Error at progress: ' || l_progress ||
                      ' process_lot_serial API returns g_unexp_error', l_proc_name, 1);
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                --Mark the serial as processed so that it does not get picked up again
                l_ser_mark_tbl(k) := 'Y';

              END IF;   --END IF l_ser_mark_tbl(k) <> 'Y' THEN
            END LOOP;   --END Loop through all serials confirmed in the UI
          END IF;   --END Do the lot and serial processing based on LPN context

        --Item based Drop, with no quantity discrepancy
        ELSE
          l_progress := '210';
          IF (l_debug = 1) THEN
            DEBUG('complete_putaway_wrapper: Progress: ' || l_progress ||
              '. Item based drop but no quantity discrepancy', l_proc_name);
          END IF;
        END IF;   --END IF (l_disc = 'Y')

        --BUG 5208888
        IF (l_serialized_item AND p_lpn_context = 3) THEN
          IF (l_entire_lpn = 'Y' OR NVL(l_lpn_controlled_flag,2) = 2) THEN -- Bug9318984 Modified the condition.
            If (l_debug = 1) THEN
              DEBUG('Serials not entered from UI. Setting DISC flag to N so complete_putaway will insert the interface records',l_proc_name);
            END IF;
            l_disc := 'N';
          ELSE
            If (l_debug = 1) THEN
              DEBUG('Serials entered from UI. Setting DISC flag to Y so that complete_putaway will not insert the interface records',l_proc_name);
            END IF;
            l_disc := 'Y';
          END IF;
        END IF;

      --For other drop types (Consolidated Drop/Manual Drop/User Drop)
      ELSE
        l_progress := '220';
        IF (l_debug = 1) THEN
            DEBUG('complete_putaway_wrapper: Progress: ' || l_progress ||
              '. Drop type is CD/UD/MD. Consume MMTT directly', l_proc_name);
        END IF;

        --As the user does not confirm item, quantity, rev etc. we just need
        --read them from the MMTT and pass it on to complete_putaway. The
        --subinventory and locator must be set from the UI though
        l_lpn_id            := l_mol_lpn_id_tbl(i);
        l_quantity          := l_mmtt_qty_tbl(i);
        l_uom_code          := l_mmtt_uom_tbl(i);
        l_revision          := l_mmtt_rev_tbl(i);
        l_lot_number        := l_mmtt_lot_tbl(i);
        l_subinventory_code := p_subinventory_code;
        l_locator_id        := p_locator_id;

        l_secondary_quantity := l_mmtt_sec_qty_tbl(i); --OPM Convergence
        l_secondary_uom := p_secondary_uom;
        If (l_debug = 1) THEN
          DEBUG('CD/MD : Current Task quantity: ' || l_quantity, l_proc_name);
        END IF;

        --Setting the p_entire_lpn_flag for complete_putaway
        --If there is only one MMTT for the current mol, then p_entire_flag
        --should be 'N' else it should be 'Y'
        SELECT count(1)
        INTO   l_mmtt_count
        FROM   mtl_material_transactions_temp
        WHERE  move_order_line_id = l_mol_line_id_tbl(i);

        IF l_mmtt_count > 1 THEN
          l_entire_lpn := 'N';
        ELSE
          l_entire_lpn := 'Y';
        END IF;
      END IF;   --END IF Process the current task based on the drop type

      --Do this stuff if the flag to skip the current task is not set
      IF l_skip_mmtt = FALSE THEN

        l_xdock_to_wip := FALSE;
        --Set the flag to check if the current task is crossdocked to a
        --WIP Issue job since for this case, we have to drop tht material as loose
        --So even if I have an entire nested LPN being crossdocked to a WIP issue
        --job, at the end of the drop, the entire nesting structure must be broken
        --Set this flag only if the destination sub is a storage sub since the user
        --might be performing a manual drop of a crossdocked line to receiving sub
        IF ((l_bk_del_det_tbl(i) IS NOT NULL) AND
            (NVL(l_xdock_type_tbl(i), 0) = 2) AND
            (NVL(l_wip_sup_typ_tbl(i),0) IN (1, 5)) AND
            (l_drop_sub_type = 1)) THEN
          l_xdock_to_wip := TRUE;
        END IF;


        /* Setting the p_to_lpn_id parameter for complete_putaway
         * If the drop sub is not LPN controlled, always pass to_lpn as NULL
         * Elsif the task is crossdocked to WIP issue job, pass to_lpn as NULL
         * Else
         *  If we are transacting the immediate contents of the from LPN Then
         *   IF Drop Mode =  Transfer contents then
         *     pass p_to_lpn_name (from parameter) to complete_putaway
         *   ELSE if Drop Mode = Drop Entire LPN then
         *     pass lpn_name of p_lpn_id itself (since we would create a new
         *       pack transaction for packing the from LPN into the "Into LPN")
         *   END IF;
         *  Else
         *   Read the LPN name and pass it to the complete_putaway_wrapper
         *  End If;
         * End IF;
         */
        IF l_lpn_controlled_flag = 2 THEN
          l_to_lpn_name := NULL;
        ELSIF l_xdock_to_wip = TRUE THEN
          l_to_lpn_name := NULL;
        ELSE
          IF ((l_mol_lpn_id_tbl(i) = p_lpn_id) AND (l_lpn_mode <> 2))  THEN
            l_to_lpn_name := p_to_lpn_name;
          ELSE
            --Replace this with LPN_NAME from global_temp table for this task
            SELECT license_plate_number
            INTO   l_to_lpn_name
            FROM   wms_license_plate_numbers
            WHERE  lpn_id = l_mol_lpn_id_tbl(i);
          END IF;   --END IF check MOL LPN and confirmed LPN
        END IF;   --END IF check lpn_controlled_flag for the sub

        --For INV/WIP LPNs, we would be calling the Inventory TM for the current
        --group. So, should update the MMTT with the new txn_header_id
        IF (p_lpn_context <> G_LPN_CONTEXT_RCV) THEN
          UPDATE  mtl_material_transactions_temp
          SET     transaction_header_id = l_new_txn_header_id
                , transaction_batch_id  = l_new_txn_header_id
                , transaction_batch_seq = l_batch_seq --BUG 3306988
          WHERE   transaction_temp_id = l_mmtt_temp_id;
  	      l_batch_seq := l_batch_seq + 1;
        END IF;

	--Begin DBI FIX
	--Need to update the drop_off_time on WDT for all the tasks
	l_progress := '228';

	BEGIN
	   UPDATE wms_dispatched_tasks
	     SET drop_off_time = l_drop_off_time
	     WHERE transaction_temp_id = l_mmtt_temp_id;
	EXCEPTION
	   WHEN OTHERS THEN
	      NULL;
	END;
	--END DBI FIX

        l_progress := '230';
        IF (l_debug = 1) THEN
            DEBUG('complete_putaway_wrapper: Progress: ' || l_progress, l_proc_name);
            DEBUG('Calling complete_putaway API with the following parameters: ', l_proc_name);
            DEBUG('p_lpn_id                  => ' || l_mol_lpn_id_tbl(i), l_proc_name);
            DEBUG('p_org_id                  => ' || p_organization_id, l_proc_name);
            DEBUG('p_temp_id                 => ' || l_mmtt_temp_id, l_proc_name);
            DEBUG('p_item_id                 => ' || l_item_id, l_proc_name);
            DEBUG('p_rev                     => ' || l_revision, l_proc_name);
            DEBUG('p_lot                     => ' || l_lot_number, l_proc_name);
            DEBUG('p_loc                     => ' || l_locator_id, l_proc_name);
            DEBUG('p_sub                     => ' || l_subinventory_code, l_proc_name);
            DEBUG('p_qty                     => ' || l_quantity, l_proc_name);
            DEBUG('p_uom                     => ' || l_uom_code, l_proc_name);
            DEBUG('p_user_id                 => ' || p_user_id, l_proc_name);
            DEBUG('p_disc                    => ' || l_disc, l_proc_name);
            DEBUG('p_entire_lpn              => ' || l_entire_lpn, l_proc_name);
            DEBUG('p_to_lpn                  => ' || l_to_lpn_name, l_proc_name);
            DEBUG('p_qty_reason_id           => ' || p_qty_reason_id, l_proc_name);
            DEBUG('p_loc_reason_id           => ' || p_loc_reason_id, l_proc_name);
            DEBUG('p_loc_reason_id           => ' || p_loc_reason_id, l_proc_name);
            DEBUG('p_process_serial_flag     => ' || p_process_serial_flag, l_proc_name);
            DEBUG('p_product_transaction_id  => ' || l_product_transaction_id, l_proc_name);
            DEBUG('p_new_txn_header_id       => ' || l_new_txn_header_id, l_proc_name);
        END IF;

        --Now that I have all the values calculated and set for this task,
        --call the complete_putaway API
        wms_task_dispatch_put_away.complete_putaway(
            p_lpn_id                  =>  l_mol_lpn_id_tbl(i)
          , p_org_id                  =>  p_organization_id
          , p_temp_id                 =>  l_mmtt_temp_id
          , p_item_id                 =>  l_item_id
          , p_rev                     =>  l_revision
          , p_lot                     =>  l_lot_number
          , p_loc                     =>  l_locator_id
          , p_sub                     =>  l_subinventory_code
          , p_qty                     =>  l_quantity
          , p_uom                     =>  l_uom_code
          , p_user_id                 =>  p_user_id
          , p_disc                    =>  l_disc
          , x_return_status           =>  x_return_status
          , x_msg_count               =>  x_msg_count
          , x_msg_data                =>  x_msg_data
          , p_entire_lpn              =>  l_entire_lpn
          , p_to_lpn                  =>  l_to_lpn_name
          , p_qty_reason_id           =>  p_qty_reason_id
          , p_loc_reason_id           =>  p_loc_reason_id
          , p_process_serial_flag     =>  p_process_serial_flag
          , p_commit                  =>  'N'
          , p_product_transaction_id  =>  l_product_transaction_id
          , p_lpn_mode                =>  l_lpn_mode
          , p_new_txn_header_id       =>  l_new_txn_header_id
          , p_secondary_quantity      =>  l_secondary_quantity  --OPM Convergence
          , p_secondary_uom           =>  l_secondary_uom --OPM Convergence
          , p_primary_uom             =>  l_primary_uom_code_tbl(i)
	  );

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          IF (l_debug = 1) THEN
            DEBUG('complete_putaway_wrapper: Error at progress: ' || l_progress || ' complete_putaway API returns g_exc_error', l_proc_name, 1);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF (l_debug = 1) THEN
            DEBUG('complete_putaway_wrapper: Error at progress: ' || l_progress || ' complete_putaway API returns g_unexp_error', l_proc_name, 1);
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (l_debug = 1) THEN
          DEBUG('complete_putaway_wrapper: successful execution of complete_putaway for temp_id : ' || l_mmtt_temp_id, l_proc_name);
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          DEBUG('complete_putaway_wrapper: skip_mmtt is TRUE, should not drop this task.' ||
                ' Could be because the serial could not be matched with the task', l_proc_name);
        END IF;
        l_remaining_qty := l_remaining_qty + l_mmtt_prm_qty;
      END IF;  --END IF l_skip_mmtt = FALSE
    END LOOP;   --END For each MMTT in the group
    --END LOOP;   --END loop through all the tasks for the current group

    --Close the cursor opened above
    IF all_tasks_csr%ISOPEN THEN
      CLOSE all_tasks_csr;
    END IF;

    IF md_tasks_csr%ISOPEN THEN
      CLOSE md_tasks_csr;
    END IF;

    --So far so good. We're done with the RTIs/MMTTs for this group
    --Should now process all the MMTTs for the current group and call
    --the appropriate Transaction Managers
    IF (p_lpn_context = G_LPN_CONTEXT_RCV) THEN
      l_progress := '240';

      -- LMS code (start) (Anupam Jain)
      -- get the distinct OperationPlanId from MMTT for receiving LPNs
      -- logic is: return the operationplanid only if it is same for all the MMTTs
      -- for the given transaction_header_id

      IF (l_debug = 1) THEN
        debug('complete_putaway_wrapper: Before calling LMS Code for receiving LPNs', l_proc_name);
      END IF;


      SELECT count(DISTINCT operation_plan_id) INTO l_lms_rec_count
      FROM mtl_material_transactions_temp mmtt
      WHERE transaction_header_id = p_txn_header_id;

      IF (l_debug = 1) THEN
           debug('complete_putaway_wrapper: LMS Code, l_lms_rec_count: ' || l_lms_rec_count , l_proc_name);
      END IF;

      IF l_lms_rec_count = 1 THEN
          -- since same OperationPlanId stamped for all the MMTTs of the group
          -- return its value for LMS data capture
          SELECT operation_plan_id INTO x_lms_operation_plan_id
          FROM mtl_material_transactions_temp
          WHERE transaction_header_id = p_txn_header_id
          AND ROWNUM = 1;

          IF (l_debug = 1) THEN
           debug('complete_putaway_wrapper: LMS Code, p_lms_operation_plan_id: ' || x_lms_operation_plan_id , l_proc_name);
          END IF;

      END IF;

      IF (l_debug = 1) THEN
       debug('complete_putaway_wrapper: After calling LMS Code for receiving LPNs', l_proc_name);
      END IF;

      -- LMS Code (end)

      --Receiving LPN. Call Receiving Transaction Manager
      IF (l_debug = 1) THEN
        DEBUG('complete_putaway_wrapper: LPN Resides in receiving. Calling the receiving manager...');
      END IF;

      INV_RCV_MOBILE_PROCESS_TXN.rcv_process_receive_txn(
          x_return_status =>  x_return_status
        , x_msg_data      =>  l_msg_data);

      --Set the flag to indicate that data has been committed (would be used
      --to rollback to the appropriate savepoint)
      l_rcv_commit := TRUE;

      IF (l_debug = 1) THEN
        DEBUG('complete_putaway_wrapper: After calling the receiving manager');
        DEBUG('status returned by the receiving manager ' || x_return_status, 4);
        DEBUG('complete_putaway_wrapper: Rxing TM Txn Message: ' || l_msg_data, 4);
      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        IF (l_debug = 1) THEN
          DEBUG('complete_putaway_wrapper: Encountered g_exc_error while calling receiving manager;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;
        fnd_message.set_name('WMS', 'WMS_TD_TXNMGR_ERROR');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF (l_debug = 1) THEN
          DEBUG('complete_putaway_wrapper: Encountered g_exc_unexp_error while calling receiving manager;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;
        fnd_message.set_name('WMS', 'WMS_TD_TXNMGR_ERROR');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      /*************** For bug 7428404 *****************/
         --Done with the TM calls. Go delete the processed records from the global temp rable
         --for the current group
          l_progress := 245;

          IF p_drop_type = G_DT_ITEM_DROP AND l_disc = 'Y' THEN


              Update_Tasks_In_Group(
                      x_return_status => x_return_status
                    , x_msg_count => x_msg_count
                    , x_msg_data =>  l_msg_data
                    , x_rec_count =>  l_del_count
                    , p_organization_id =>  p_organization_id
                    , p_drop_type => p_drop_type
                                , p_lpn_id => p_lpn_id
                    , p_group_id => p_group_id
                    , p_emp_id => l_emp_id );

               IF (l_debug = 1) THEN
                 DEBUG('complete_putaway_wrapper: After calling Update_Tasks_In_Group');
                 DEBUG('status returned by Update_Tasks_In_Group ' || x_return_status, 4);
                 DEBUG('complete_putaway_wrapper: Txn Message: ' || l_msg_data, 4);
               END IF;

               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 IF (l_debug = 1) THEN
                   DEBUG('complete_putaway_wrapper: Encountered g_exc_error while calling Update_Tasks_In_Group;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
                 END IF;
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

               IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 IF (l_debug = 1) THEN
                   DEBUG('complete_putaway_wrapper: Encountered g_exc_unexp_error while calling Update_Tasks_In_Group;'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 4);
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;


          ELSE
               l_del_count := Remove_Tasks_In_Group(
                                p_del_type  =>  1
                              , p_group_id  =>  p_group_id);
          END IF;


    --If the LPN context is Inventory/WIP
    ELSE
      l_progress := '240';
      IF (p_lpn_context = G_LPN_CONTEXT_WIP) THEN
        --For WIP Putaway, use the new business flow code
        l_business_flow_code := 35;
      END IF;

      IF (l_debug = 1) THEN
        DEBUG('complete_putaway_wrapper: Progress: ' || l_progress || '. Calling post_process_lpn', l_proc_name);
      END IF;

      -- Nested LPN changes
      --Do not call the post_process_lpn if dest sub is NOT LPN controlled or passed to_lpn is NULL
      IF (l_lpn_controlled_flag = 2 OR p_to_lpn_name IS NULL) THEN
        IF l_debug = 1 THEN
          DEBUG('Dest sub is not LPN controlled, or passed TO LPN is NULL or Dest sub is not storage sub . No post_process_lpn calls.', l_proc_name);
          DEBUG('l_drop_sub_type : '||  l_drop_sub_type || ' to_lpn_name : ' || p_to_lpn_name || ' l_lpn_controlled_flag : ' || l_lpn_controlled_flag );
        END IF;

      ELSE
        IF l_debug = 1 THEN
          DEBUG('Calling post_process_lpn to handle the pack/unpacks.', l_proc_name);
        END IF;

        post_process_lpn(
             x_return_status          => x_return_status
           , x_msg_count              => x_msg_count
           , x_msg_data               => x_msg_data
           , p_from_lpn_id            => p_lpn_id
           , p_organization_id        => p_organization_id
           , p_subinventory_code      => p_subinventory_code
           , p_lpn_mode               => l_lpn_mode
           , p_locator_id             => p_locator_id
           , p_to_lpn_id              => p_to_lpn_id
           , p_project_id             => p_project_id
           , p_task_id                => p_task_id
           , p_user_id                => p_user_id
           , p_lpn_context            => p_lpn_context
           , p_pack_trans_id          => l_new_txn_header_id
           , p_batch_id               => l_new_txn_header_id
           , p_batch_seq              => l_batch_seq );

        IF (l_debug = 1) THEN
          DEBUG('complete_putaway_wrapper: post_process_lpn returns: ' || x_return_status, 4);
        END IF;

        IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;
      -- Nested LPN changes end

      --Call the Inventory Transaction Manager
      IF (l_debug = 1) THEN
        DEBUG('complete_putaway_wrapper: INV or WIP LPN. Am calling the Inventory TM with txn_header_id ' || l_new_txn_header_id, l_proc_name);
      END IF;

      IF p_lpn_context = 2 THEN
        l_txn_ret := inv_lpn_trx_pub.process_lpn_trx(
            p_trx_hdr_id             => l_new_txn_header_id
          , p_commit                 => fnd_api.g_false
          , x_proc_msg               => x_msg_data
          , p_business_flow_code     => l_business_flow_code
          , p_proc_mode              => 1);
      ELSE
        l_txn_ret := inv_lpn_trx_pub.process_lpn_trx(
            p_trx_hdr_id             => l_new_txn_header_id
          , p_commit                 => fnd_api.g_false
          , x_proc_msg               => x_msg_data
          , p_business_flow_code     => l_business_flow_code);
      END IF;

      IF (l_debug = 1) THEN
        debug('complete_putaway_wrapper: After Calling Inventory TM', l_proc_name);
        debug('complete_putaway_wrapper: l_txn_ret: ' || l_txn_ret, l_proc_name);
        debug('complete_putaway_wrapper: Txn Message ' || x_msg_data, l_proc_name);
      END IF;

      IF (l_txn_ret <> 0) THEN
        fnd_message.set_name('WMS', 'WMS_TD_TXNMGR_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;


    --Done with the TM calls. Go delete the records from the global temp rable
    --for the current group
    l_progress := '250';
    l_del_count := Remove_Tasks_In_Group(
                      p_del_type  =>  1
                    , p_group_id  =>  p_group_id);

    END IF;   --END IF call the managers based on lpn_context

     -- Call the API to clear the receiving global variables
     inv_rcv_common_apis.rcv_clear_global;

    --At last, I'm done for the current group. Can go ahead and commit my work!
    COMMIT;

    --BUG 3625990: Do not lock the LPN if it has context 3
    IF (p_lpn_context <> 3) THEN
       -- Lock all the remaining LPNs the user is currently working on
       -- We are re-locking again since the commit above would have relieved the lock.
       Lock_LPNs( x_return_status  => x_return_status
		  ,x_msg_count      => x_msg_count
		  ,x_msg_data       => x_msg_data );

       l_progress := '260';

       IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
	  IF (l_debug = 1) THEN
	     DEBUG(' Error in locking LPNs ' || x_msg_data ,l_proc_name,1);
	  END IF;
	  RAISE fnd_api.g_exc_error;
       END IF;

       IF (l_debug = 1) THEN
	  DEBUG(':-)complete_putaway_wrapper exitted with success for group id ' || p_group_id || ' :-). Exit time: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), l_proc_name);
       END IF;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
       --Close the cursors
      IF mol_csr%ISOPEN THEN
        CLOSE mol_csr;
      END IF;
      IF all_tasks_csr%ISOPEN THEN
        CLOSE all_tasks_csr;
      END IF;
      IF md_tasks_csr%ISOPEN THEN
        CLOSE md_tasks_csr;
      END IF;
      IF rcv_serials_csr%ISOPEN THEN
        CLOSE rcv_serials_csr;
      END IF;
      IF msnt_ser_csr%ISOPEN THEN
        CLOSE msnt_ser_csr;
      END IF;

      IF NOT l_rcv_commit THEN
        ROLLBACK TO complete_putaway_wrap_sp;
      END IF;

      IF (l_debug = 1) THEN
        DEBUG('complete_putaway_wrapper: G_EXC_ERROR ocurred after l_progress = ' || l_progress, l_proc_name);
      END IF;

      --Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

       --Close the cursors
      IF mol_csr%ISOPEN THEN
        CLOSE mol_csr;
      END IF;
      IF all_tasks_csr%ISOPEN THEN
        CLOSE all_tasks_csr;
      END IF;
      IF md_tasks_csr%ISOPEN THEN
        CLOSE md_tasks_csr;
      END IF;
      IF rcv_serials_csr%ISOPEN THEN
        CLOSE rcv_serials_csr;
      END IF;
      IF msnt_ser_csr%ISOPEN THEN
        CLOSE msnt_ser_csr;
      END IF;

      IF NOT l_rcv_commit THEN
        ROLLBACK TO complete_putaway_wrap_sp;
      END IF;

      IF (l_debug = 1) THEN
        DEBUG('complete_putaway_wrapper: G_EXC_UNEXPECTED_ERROR ocurred after l_progress = ' || l_progress, l_proc_name);
      END IF;

      --Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      --Close the cursors
      IF mol_csr%ISOPEN THEN
        CLOSE mol_csr;
      END IF;
      IF all_tasks_csr%ISOPEN THEN
        CLOSE all_tasks_csr;
      END IF;
      IF md_tasks_csr%ISOPEN THEN
        CLOSE md_tasks_csr;
      END IF;
      IF rcv_serials_csr%ISOPEN THEN
        CLOSE rcv_serials_csr;
      END IF;
      IF msnt_ser_csr%ISOPEN THEN
        CLOSE msnt_ser_csr;
      END IF;

      IF NOT l_rcv_commit THEN
        ROLLBACK TO complete_putaway_wrap_sp;
      END IF;

      IF (l_debug = 1) THEN
        DEBUG('complete_putaway_wrapper: OTHER EXCEPTION ' || SQLERRM || ' ocurred after l_progress = ' || l_progress, l_proc_name);
      END IF;

      --Get message count and data
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('wms_putaway_utils_pvt.complete_putaway_wrapper',l_progress, SQLCODE);
      END IF;

  END complete_putaway_wrapper;

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
   p_project_id           IN    NUMBER ,
   p_task_id              IN    NUMBER ,
   p_drop_type            IN    VARCHAR2 ,
   p_sub                  IN    VARCHAR2 ,
   p_loc                  IN    NUMBER ,
   p_crossdock_type       IN    VARCHAR2,
   p_consolidation_method_id   IN    NUMBER,
   p_backorder_delivery_detail_id IN NUMBER,
   p_suggested_into_lpn_id IN   NUMBER
   )
IS
   l_api_name             CONSTANT VARCHAR2(30) := 'validate_into_lpn';
   l_progress             VARCHAR2(10);
   l_count                NUMBER;
   l_into_lpn_id          NUMBER;
   l_lpn_context          NUMBER;
   l_lpn_sub              VARCHAR2(10);
   l_lpn_loc_id           NUMBER;
   l_into_lpn_sub         VARCHAR2(10);
   l_into_lpn_loc_id      NUMBER;
   l_into_lpn_context     NUMBER;
   l_into_lpn_project_id  NUMBER;
   l_into_lpn_task_id     NUMBER;
   l_passed               VARCHAR2(1);
   l_item_count           NUMBER;
   l_lot_count            NUMBER;
   l_rev_count            NUMBER;
   l_qty_gtmp             NUMBER;
   l_qty_wlc              NUMBER;
   l_debug                NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_back_order_delivery_id NUMBER := -999;
   l_crossdock_type         NUMBER;
   l_wip_supply_type        NUMBER := -999;
   l_sub_validation_passed  NUMBER := 1;
   l_lpn_sub_type           NUMBER;
   l_lpn_controlled_flag    NUMBER;
   l_reservable_type        NUMBER;
   l_sub_type               NUMBER;
   l_allowed                VARCHAR2(1);--R12
   l_into_outermost_lpn_id  NUMBER;
   l_lpn_has_material       NUMBER;
BEGIN
   IF (l_debug = 1) THEN
      debug('***Calling validate_into_lpn with the following parameters***','validate_into_lpn',9);
      debug('p_organization_id: => ' || p_organization_id,'validate_into_lpn',9);
      debug('p_lpn_id: ==========> ' || p_lpn_id,'validate_into_lpn',9);
      debug('p_employee_id: =====> ' || p_employee_id,'validate_into_lpn',9);
      debug('p_project_id: =====> ' || p_project_id,'validate_into_lpn',9);
      debug('p_task_id: =====> ' || p_task_id,'validate_into_lpn',9);
      debug('p_into_lpn: ========> ' || p_into_lpn,'validate_into_lpn',9);
      debug('p_drop_type: ========> ' || p_drop_type,'validate_into_lpn',9);
      debug('p_sub: ==============> ' || p_sub,'validate_into_lpn',9);
      debug('p_loc: ==============> ' || p_loc,'validate_into_lpn',9);
      debug('p_crossdock_type================>'||p_crossdock_type,'validate_into_lpn',9);
      debug('p_consolidation_method_id=======>'||p_consolidation_method_id,'validate_into_lpn',9);
      debug('p_backorder_delivery_detail_id==>'||p_backorder_delivery_detail_id,'validate_into_lpn',9);
      debug('p_suggested_into_lpn_id=========>'||p_suggested_into_lpn_id,'validate_into_lpn',9);
   END IF;

   -- Set the savepoint
   SAVEPOINT validate_lpn_sp;
   x_return_status := fnd_api.g_ret_sts_success;

   l_progress  := '10';

   -- Get the required LPN values
   SELECT lpn_context, subinventory_code, locator_id
     INTO l_lpn_context, l_lpn_sub, l_lpn_loc_id
     FROM wms_license_plate_numbers
     WHERE organization_id = p_organization_id
     AND lpn_id = p_lpn_id;
   l_progress := '20';
   IF (l_debug = 1) THEN
      debug('Retrieved LPN attributes','validate_into_lpn',9);
      debug('LPN Context: =======> ' || l_lpn_context,'validate_into_lpn',9);
      debug('Subinventory: ======> ' || l_lpn_sub,'validate_into_lpn',9);
      debug('Locator ID: ========> ' || l_lpn_loc_id,'validate_into_lpn',9);
   END IF;

   -- See if the Into LPN exists
   BEGIN
      SELECT 1, lpn_id, subinventory_code, locator_id, lpn_context,outermost_lpn_id
  INTO l_count, l_into_lpn_id, l_into_lpn_sub, l_into_lpn_loc_id, l_into_lpn_context,
       l_into_outermost_lpn_id
  FROM  wms_license_plate_numbers
  WHERE license_plate_number = p_into_lpn
  AND   organization_id      = p_organization_id
  FOR UPDATE OF lpn_id NOWAIT;
      -- lock so no other user can load into this lpn
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
   l_count := 0;
   END;
   l_progress := '30';
   IF (l_debug = 1) THEN
      debug('Into LPN count: ' || l_count,'validate_into_lpn',9);
   END IF;

   --BUG 3354934
   IF (l_count <> 0 AND l_into_lpn_context = 5) THEN
      IF (l_debug = 1) THEN
	 debug('Into LPN context is 5, so bypass all validation','validate_into_lpn',9);
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;
      x_validation_passed := 'Y';
      x_new_lpn_created := 'N';
      RETURN;
   END IF;

   IF (l_count = 0) THEN
      -- New LPN
      IF (l_debug = 1) THEN
   debug('LPN does not exist so create new LPN','validate_into_lpn',9);
      END IF;

      -- Create the LPN
      wms_container_pub.create_lpn
  ( p_api_version       => 1.0,
    p_init_msg_list     => fnd_api.g_false,
    p_commit            => fnd_api.g_false,
    x_return_status     => x_return_status,
    x_msg_count         => x_msg_count,
    x_msg_data          => x_msg_data,
    p_lpn               => p_into_lpn,
    p_organization_id   => p_organization_id,
    p_container_item_id => NULL,
    p_lot_number        => NULL,
    p_revision          => NULL,
    p_serial_number     => NULL,
--    p_subinventory      => l_lpn_sub,
--    p_locator_id        => l_lpn_loc_id,
    p_source            => 5, -- defined but not used
    p_cost_group_id     => NULL,
    x_lpn_id            => l_into_lpn_id
    );
      l_progress := '40';
      IF (l_debug = 1) THEN
   debug('Finished calling create LPN API: ' || l_into_lpn_id,'validate_into_lpn',9);
      END IF;

      -- Check the return status from the API call
      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
         IF (l_debug = 1) THEN
            debug('Success returned from wms_container_pub.create_lpn API','validate_into_lpn',9);
         END IF;
             ELSE
         IF (l_debug = 1) THEN
            debug('Failure returned from wms_container_pub.create_lpn API','validate_into_lpn',9);
         END IF;
         FND_MESSAGE.SET_NAME('WMS', 'WMS_TD_CREATE_LPN_ERROR');
         FND_MSG_PUB.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;
      l_progress := '60';

      -- Set the validation passed output parameter
      x_validation_passed := 'Y';

      -- Set the new LPN created output parameter
      x_new_lpn_created := 'Y';

      --BUG 3354934
      IF (l_debug = 1) THEN
	 debug('LPN created.  Can bypass rest of validation','validate_into_lpn',9);
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;
      RETURN;

    ELSE
      -- Existing LPN
      IF (l_debug =1 ) THEN
        debug('INTO LPN exists so validate it','validate_into_lpn',9);
        debug('Retrieved INTO LPN attributes','validate_into_lpn',9);
        debug('LPN ID: ============> ' || l_into_lpn_id,'validate_into_lpn',9);
        debug('LPN Context: =======> ' || l_into_lpn_context,'validate_into_lpn',9);
        debug('Subinventory: ======> ' || l_into_lpn_sub,'validate_into_lpn',9);
        debug('Locator ID: ========> ' || l_into_lpn_loc_id,'validate_into_lpn',9);
      END IF;

      -- Set the new LPN created output parameter
      x_new_lpn_created := 'N';

      l_count := 0;

      IF p_drop_type = 'LOAD'  THEN

        BEGIN
	   -- Validate the LPN
	   -- Bug 4652943
	   -- For Performance Reason the count for WMS_LPN_CONTENTS
	   -- is done outside.

	   l_lpn_has_material := 0;

	   select NVL(count(1),0)
	     into l_lpn_has_material
	     FROM wms_lpn_contents
	     WHERE parent_lpn_id IN (SELECT wlpn1.lpn_id
				     FROM   wms_license_plate_numbers wlpn1
				     START WITH wlpn1.lpn_id = l_into_outermost_lpn_id
				     CONNECT BY PRIOR wlpn1.lpn_id = wlpn1.parent_lpn_id);

	  SELECT 1
            INTO l_count
            FROM dual
            WHERE EXISTS
           (SELECT 'INTO_LPN_EXISTS'
            FROM wms_license_plate_numbers wlpn
            WHERE wlpn.organization_id = p_organization_id
            AND wlpn.lpn_id <> p_lpn_id
            AND wlpn.lpn_id = l_into_lpn_id
            AND (wlpn.lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED
            OR (wlpn.lpn_context = l_lpn_context
           AND (
           ( l_lpn_has_material = 0
           --NOT EXISTS (SELECT 'LPN_HAS_MATERIAL'
           --FROM wms_lpn_contents
           --WHERE parent_lpn_id IN (SELECT wlpn1.lpn_id
           --      FROM   wms_license_plate_numbers wlpn1
           --      START WITH wlpn1.lpn_id = wlpn.outermost_lpn_id
           --      CONNECT BY PRIOR wlpn1.lpn_id = wlpn1.parent_lpn_id)
           --)
           )
          OR
          /** Bug:5650113
              While performing Manual Load by Item by Item, mmtt.lpn_id
              is stamped with from lpn_id not with into_lpn_id and
              because of this no rows is getting fetched for the query
              'LOADED_BY_SAME_USER'.
              So, modified mmmt.lpn_id to mtrl.lpn_id and introduced join
              with mmmt and mtrl table.
           */
          (EXISTS (SELECT 'LOADED_BY_SAME_USER'
             FROM  mtl_material_transactions_temp mmtt,
             wms_dispatched_tasks wdt,--5650113
             mtl_txn_request_lines mtrl--5650113
             WHERE mmtt.organization_id = p_organization_id
             AND mmtt.transaction_temp_id = wdt.transaction_temp_id
             AND wdt.organization_id = p_organization_id
             AND wdt.task_type = 2
             AND wdt.status = 4
             AND wdt.person_id = p_employee_id
             AND mtrl.line_id = mmtt.move_order_line_id--5650113
             AND mtrl.lpn_id IN (SELECT lpn_id--5650113
               FROM wms_license_plate_numbers
               START WITH lpn_id = wlpn.outermost_lpn_id
               CONNECT BY PRIOR lpn_id = parent_lpn_id
               )
             )
           )
          )
        )
      )
      AND inv_material_status_grp.is_status_applicable('TRUE',
                        NULL,
                        INV_GLOBALS.G_TYPE_CONTAINER_PACK,
                        NULL,
                        NULL,
                        p_organization_id,
                        NULL,
                        wlpn.subinventory_code,
                        wlpn.locator_id,
                        NULL,
                        NULL,
                        'Z') = 'Y'
           AND inv_material_status_grp.is_status_applicable('TRUE',
                        NULL,
                        INV_GLOBALS.G_TYPE_CONTAINER_PACK,
                        NULL,
                        NULL,
                        p_organization_id,
                        NULL,
                        wlpn.subinventory_code,
                        wlpn.locator_id,
                        NULL,
                        NULL,
                        'L') = 'Y');
            EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_count := 0;
            IF (l_debug = 1) THEN
               debug('No data found','validate_into_lpn',9);
            END IF;
            END;
            l_progress := '70';
            IF (l_debug = 1) THEN
         debug('Validated Into LPN count: ' || l_count,'validate_into_lpn',9);
            END IF;

            IF (l_count = 0) THEN
         x_validation_passed := 'N';
         IF (l_debug = 1) THEN
            debug('Into LPN validation failed!','validate_into_lpn',9);
         END IF;
   FND_MESSAGE.SET_NAME('WMS','WMS_NO_LPN_LOAD_ALLOWED');
   FND_MSG_PUB.ADD;
         RAISE fnd_api.g_exc_error;
             ELSE
         x_validation_passed := 'Y';
         IF (l_debug = 1) THEN
            debug('Into LPN validation passed!','validate_into_lpn',9);
         END IF;
            END IF;
         END IF;

       -- Validate Into lpn for drop
       IF (p_drop_type IN ('MANUAL_DROP', 'SYSTEM_DROP')) THEN

	  --R12
	  IF (p_crossdock_type IS NOT NULL AND
	      p_backorder_delivery_detail_id IS NOT NULL AND
	      l_into_lpn_context = 11) THEN
	     IF (p_consolidation_method_id = 1) THEN

		--If user override the LPN suggested by MDC
		IF (p_suggested_into_lpn_id IS NOT NULL AND
		    p_suggested_into_lpn_id <> l_into_lpn_id) THEN

		   IF (l_debug = 1) THEN
		      debug('Calling wms_mdc_pvt.validate_to_lpn','validate_into_lpn',9);
		   END IF;

		   wms_mdc_pvt.validate_to_lpn
		     (p_from_lpn_id       => p_lpn_id
		      ,p_to_lpn_id        => l_into_lpn_id
		      ,p_is_from_to_delivery_same => 'U'
		      ,x_allow_packing    => l_allowed
		      ,x_return_status    => x_return_status
		      ,x_msg_count        => x_msg_count
		      ,x_msg_data         => x_msg_data
		      );

		   IF (x_return_status = 'U') THEN
		      IF (l_debug = 1) THEN
			 DEBUG(' Error in wms_mdc_pvt.validate_to_lpn','validate_into_lpn',9);
		      END IF;
		      RAISE fnd_api.g_exc_error;
		    ELSE
		      IF (l_allowed = 'Y') THEN
			 IF (l_debug = 1) THEN
			    debug(' validation passed!','validate_into_lpn',9);
			 END IF;
		       ELSE
			 x_validation_passed := 'N';
			 RETURN;
		      END IF;
		   END IF;
		END IF;--IF (p_suggested_into_lpn_id IS NOT NULL AND p_suggested_into_lpn_id <> l_into_lpn_id) THEN

	      ELSE --Non-MDC cases

		IF (l_debug = 1) THEN
		  debug('Checking for comingling','validate_into_lpn',9);
		END IF;

		-- Make sure that the Into LPN does not contain other deliveres
		BEGIN
		   SELECT 'N'
		     INTO l_allowed
		     FROM wsh_delivery_assignments_v wda1
		     ,    wsh_delivery_assignments_v wda2
		     ,    wsh_delivery_details wdd
		     WHERE wda1.delivery_detail_id = p_backorder_delivery_detail_id
		     AND   wda2.delivery_detail_id = wdd.delivery_detail_id
		     AND   wdd.lpn_id = l_into_lpn_id
		     AND   Nvl(wda1.delivery_id,-1) <> Nvl(wda2.delivery_id,-2);
		EXCEPTION
		   WHEN too_many_rows THEN
		      IF (l_debug = 1) THEN
			 debug('too many rows','validate_into_lpn',9);
		      END IF;
		      l_allowed := 'N';
		   WHEN no_data_found THEN
		      IF (l_debug = 1) THEN
			 debug('no data found','validate_into_lpn',9);
		      END IF;
		      l_allowed := 'Y';
		   WHEN OTHERS THEN
		      IF (l_debug = 1) THEN
			 debug('others exception: '||Sqlerrm,'validate_into_lpn',9);
		      END IF;
		      l_allowed := 'N';
		END;

		IF (l_debug = 1) THEN
		   debug('l_allowed:'||l_allowed,'validate_into_lpn',9);
		END IF;

                /* Bug 5474915: Changed the error message from
                   WMS_COMMINGLE_EXISTS to WMS_LOOSE_TO_LPN.*/

		IF l_allowed = 'N' THEN
		   x_return_status := fnd_api.g_ret_sts_error;
		   x_validation_passed := 'N';
		   fnd_message.set_name('WMS', 'WMS_LOOSE_TO_LPN');
		   fnd_msg_pub.ADD;
		   RETURN;
		END IF;
	     END IF;
	     x_validation_passed := 'Y';
	     RETURN;
	  END IF;
	  --R12 END

         ---Check If the from LPN and ToLPN are same.
         IF p_lpn_id = l_into_lpn_id  THEN

           -- Check there are no child LPNs and there is only one item left for Item drop
           BEGIN
               select  count(DISTINCT inventory_item_id),count(DISTINCT lot_number),count(DISTINCT revision)
                 into  l_item_count,l_lot_count,l_rev_count
                 from  WMS_PUTAWAY_GROUP_TASKS_GTMP wpgtg
                where  lpn_id = p_lpn_id
                  and  drop_type='ID'
		 and  row_type = 'Group Task'
                  and  not exists
                     (select 1
                          from wms_license_plate_numbers wln
                       where wln.parent_lpn_id = p_lpn_id);
           EXCEPTION
             WHEN OTHERS THEN
               l_item_count :=2;
           END;

           IF (l_item_count > 1 OR l_lot_count > 1 OR l_rev_count > 1) THEN
             IF (l_debug = 1) THEN
                debug('There are multiple items/lot/rev in the LPN or the LPN has child LPNS.!','validate_into_lpn',9);
             END IF;

              x_validation_passed := 'N';
              RETURN;
           END IF;

           -- check LPN is fully allocated.
           select sum(primary_quantity) INTO l_qty_gtmp
             from WMS_PUTAWAY_GROUP_TASKS_GTMP
      where lpn_id = p_lpn_id
              and row_type = 'Group Task'
              and drop_type = 'ID';

           select sum(quantity) into l_qty_wlc
             from wms_lpn_contents
            where parent_lpn_id = p_lpn_id;

           IF (l_qty_gtmp<>l_qty_wlc) THEN
             IF (l_debug = 1) THEN
                debug(' quantity from global temp table ' || l_qty_gtmp);
                debug(' quantity from wms license plate Numbers ' || l_qty_wlc);
                debug('Given LPN is not fully allocated!','validate_into_lpn',9);
             END IF;
             x_validation_passed := 'N';
             RETURN;
           END IF;
     /** Bug 5684823:
          During Drop txn, if "from lpn" and "to lpn" are same, no need to
          verify the "to lpn" exists and it is in loaded state through the query
          "INTO_LPN_EXISTS". We can safely bypass it, as the "to lpn" will exist
          as "from lpn" exists and "from lpn" will be in loaded status irrespective
          of system generated drop or manual drop.
          So, bypassing the query 'INTO_LPN_EXISTS' and setting l_count to 1.
      */
      l_count := 1;
     ELSE--IF p_lpn_id = l_into_lpn_id  THEN
         BEGIN
            SELECT 1 INTO l_count
              FROM DUAL
             WHERE EXISTS (
                  SELECT 'INTO_LPN_EXISTS'
                    FROM wms_license_plate_numbers wlpn
                   WHERE wlpn.organization_id = p_organization_id
		     AND wlpn.lpn_id = l_into_lpn_id
	             AND (wlpn.lpn_context = 5 OR
			  ((wlpn.lpn_context = 1 AND l_lpn_context IN (1,2) ) OR
			   wlpn.lpn_context IN (1,3) AND l_lpn_context = 3)--BUG 3463634
			  AND (p_lpn_id = wlpn.lpn_id OR --BUG 3368408
			       (NOT EXISTS (SELECT 'LOADED'
					    FROM  mtl_material_transactions_temp mmtt,
					    wms_dispatched_tasks wdt
					    WHERE mmtt.organization_id = p_organization_id
					    AND mmtt.transaction_temp_id = wdt.transaction_temp_id
					    AND wdt.organization_id = p_organization_id
					    AND wdt.task_type = 2
					    AND wdt.status = 4
					    AND mmtt.lpn_id IN (SELECT wlpn2.lpn_id
								FROM wms_license_plate_numbers wlpn2
								START WITH wlpn2.lpn_id = wlpn.outermost_lpn_id
								CONNECT BY PRIOR wlpn2.lpn_id = wlpn2.parent_lpn_id
								)
					    )
				)
			       )
			  AND inv_material_status_grp.is_status_applicable
  			         ('TRUE',NULL,inv_globals.g_type_container_pack,
				  NULL,NULL,p_organization_id,NULL,wlpn.subinventory_code,
				  wlpn.locator_id,NULL,NULL,'Z') = 'Y'
			  AND inv_material_status_grp.is_status_applicable
	                         ('TRUE',NULL,inv_globals.g_type_container_pack,NULL,
				  NULL,p_organization_id,NULL,wlpn.subinventory_code,
				  wlpn.locator_id,NULL,NULL,'L') = 'Y'
	                  )
	           );
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_count := 0;
            IF (l_debug = 1) THEN
               debug('No data found for drop','validate_into_lpn',9);
            END IF;
         END; -- End for validation of drop

     END IF;--IF p_lpn_id = l_into_lpn_id  THEN
         l_progress := '70';

         IF (l_debug = 1) THEN
            debug('Validated Into LPN count for drop: ' || l_count,'validate_into_lpn',9);
         END IF;

         IF (l_count = 0) THEN
           x_validation_passed := 'N';
           IF (l_debug = 1) THEN
              debug('Into LPN validation failed! for drop! ','validate_into_lpn',9);
           END IF;
           RAISE fnd_api.g_exc_error;
         ELSE
           x_validation_passed := 'Y';
           IF (l_debug = 1) THEN
              debug('Into LPN validation passed for drop!','validate_into_lpn',9);
           END IF;
         END IF; -- end for l_count=0

	 -- LPN Sub/LOC validation
   --Bug #4414782
	 IF (l_into_lpn_context = 3 AND
	     l_into_lpn_sub IS NULL AND
       p_sub IS NULL AND p_loc IS NULL) THEN
	    --The user should be be allowed to nest a LPN with sub/loc
	    --into a RCV LPN that has no sub/loc
	    l_sub_validation_passed := 0;
	  ELSIF  (p_drop_type = 'MANUAL_DROP' AND l_lpn_context <> l_into_lpn_context) THEN
	    --If it is a Manual Drop, then the user should be able to drop
	    --into a storage inventory if it is in RCV or WIP
	    l_sub_validation_passed := 1;
	  ELSE
	    IF (l_into_lpn_sub IS NOT NULL AND l_into_lpn_loc_id IS NOT NULL) THEN
	       IF (p_sub IS NOT NULL AND p_loc IS NOT NULL) THEN
		  -- This is called from the PutawayDropPage
		  -- So p_sub and p_loc must match the sub/loc of the
		  -- into LPN
		  IF (l_debug = 1) THEN
		     debug('Validate sub for PutawayDrop scenario','validate_into_lpn',9);
		  END IF;

		  IF (p_lpn_id <> l_into_lpn_id AND --If user enter same into
		                                    --lpn AS the from LPN,
		                                    --We should allow him move it
		                                    --to a different place
		      (p_sub <> Nvl(l_into_lpn_sub, '@@@') OR
		       p_loc <> Nvl(l_into_lpn_loc_id,-999))) THEN
		     l_sub_validation_passed := 0;
		   ELSE
		     l_sub_validation_passed := 1;
		  END IF;
		ELSE
		  IF (l_debug = 1) THEN
		     debug('Calling get_crossdock_info','validate_into_lpn',9);
		     debug('  p_lpn_id =======> '||p_lpn_id,'validate_into_lpn',9);
		     debug('  p_organization_id ===> '||p_organization_id,'validate_into_lpn',9);
		  END IF;
		  wms_putaway_utils.get_crossdock_info
		    (p_lpn_id          => p_lpn_id
		     ,p_organization_id => p_organization_id
		     ,x_back_order_delivery_id => l_back_order_delivery_id
		     ,x_crossdock_type         => l_crossdock_type
		     ,x_wip_supply_type        => l_wip_supply_type
		     );
		  IF (l_debug = 1) THEN
		     debug('After calling get_crossdock_info','validate_into_lpn',9);
		     debug('  l_crossdock_type =======> '||l_crossdock_type,'validate_into_lpn',9);
		  END IF;

	          BEGIN
		     SELECT lpn_controlled_flag,reservable_type,Nvl(subinventory_type,1)
		       INTO l_lpn_controlled_flag,l_reservable_type,l_lpn_sub_type
		       FROM mtl_secondary_inventories
		       WHERE organization_id = p_organization_id
		       AND secondary_inventory_name = l_into_lpn_sub
		       AND ((Nvl(subinventory_type,1)=1 AND
			     NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE))
			    OR
			    (Nvl(subinventory_type,1)=2 AND
			     (trunc(disable_date + (300*365)) >= trunc(SYSDATE)
			      OR TO_CHAR(disable_date, 'YYYY/MM/DD') = '1700/01/01')))
		       AND (((Nvl(subinventory_type,1)=1) AND
			     inv_ui_item_sub_loc_lovs.validate_lpn_sub
			     (p_organization_id,
			      secondary_inventory_name,
			      p_lpn_id) = 'Y') OR
			    Nvl(subinventory_type,1)=2);
		  EXCEPTION
		     WHEN OTHERS THEN
			l_lpn_sub_type := -999;
			l_lpn_controlled_flag := -999;
			l_reservable_type := -999;
		  END;

		  IF (p_drop_type <> 'MANUAL_DROP') THEN
		     --If it is MANUAL_DROP, p_sub won't be passed
	             BEGIN
			SELECT Nvl(subinventory_type,1)
			  INTO l_sub_type
			  FROM mtl_secondary_inventories
			  WHERE organization_id = p_organization_id
			  AND secondary_inventory_name = p_sub
			  AND ((Nvl(subinventory_type,1)=1 AND
				NVL(disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE))
			       OR
			       (Nvl(subinventory_type,1)=2 AND
				(trunc(disable_date + (300*365)) >= trunc(SYSDATE)
				 OR TO_CHAR(disable_date,'YYYY/MM/DD') = '1700/01/01')));
		     EXCEPTION
			WHEN OTHERS THEN
			   l_sub_type := -999;
		     END;
		  END IF;

		  IF (l_debug = 1) THEN
		     debug('l_lpn_sub_type: ' || l_lpn_sub_type,'validate_into_lpn',9);
		     debug('l_lpn_controlled_flag: ' || l_lpn_controlled_flag ,'validate_into_lpn',9);
		     debug('l_reservable_type: ' || l_reservable_type,'validate_into_lpn',9);
		     debug('l_sub_type: ' || l_sub_type,'validate_into_lpn',9);
		  END IF;


		  IF l_crossdock_type = 0 THEN
		     --No crossdocking
		     IF p_drop_type = 'SYSTEM_DROP' THEN
			--Directed Drop:
			--In this case, lpn sub must be same as suggested sub
			IF (p_lpn_id <> l_into_lpn_id) THEN --bug 5380737
			  IF (l_sub_type = 1	AND l_lpn_sub_type = 1) OR
			    (l_sub_type = 2 AND l_lpn_sub_type = 2) THEN
			     l_sub_validation_passed := 1;
			  ELSE
			    l_sub_validation_passed := 0;
			  END IF;
			ELSE
			  l_sub_validation_passed := 1;
			END IF;
		      ELSE
			--Manual drop, all sub is OK
			l_sub_validation_passed := 1;
		     END IF; --IF p_drop_type = 'SYSTEM_DROP' THEN
		   ELSIF l_crossdock_type = 1 THEN
		     --SO xdock:
		     IF (p_drop_type = 'MANUAL_DROP') THEN
			--If fromLPN is a WIP lpn, then LPN sub
			--must be storage sub, reservable and lpn-controlled
			--Otherwise, it can be rcv sub and a valid storage sub
			IF (l_lpn_context = 2
			    AND l_lpn_sub_type = 1
			    AND l_lpn_controlled_flag = 1
			    AND l_reservable_type = 1) OR
			  (l_lpn_context = 3
			   AND (l_lpn_sub_type = 3 OR
				(l_lpn_sub_type = 1
				 AND l_lpn_controlled_flag = 1
				 AND l_reservable_type = 1)
				)
			   ) THEN
			   l_sub_validation_passed := 1;
			 ELSE
			   l_sub_validation_passed := 0;
			END IF;
		      ELSE
			--If system suggested storage sub, then
			--LPN sub must be valid storage sub
			IF (p_lpn_id <> l_into_lpn_id) THEN --bug 5380737
			  IF (l_sub_type = 1
			     AND l_lpn_sub_type = 1
			     AND l_lpn_controlled_flag = 1
			     AND l_reservable_type = 1) OR
			     (l_sub_type = 2
			     AND l_lpn_sub_type = 2) THEN
			    l_sub_validation_passed := 1;
			  ELSE
			    l_sub_validation_passed := 0;
			  END IF;
			ELSE
			  l_sub_validation_passed := 1;
			END IF;
		     END IF; --IF (p_drop_type = 'MANUAL_DROP') THEN
		   ELSIF l_crossdock_type = 2 THEN
		     --WIP PULL
		     IF (p_drop_type = 'MANUAL_LOAD') THEN
			IF (l_lpn_context = 2) THEN
			   --Destination sub is not lpn controlled.
			   --So shouldn't be allowed to enter LPN
			   l_sub_validation_passed := 0;
			 ELSE
			   IF (l_lpn_sub_type = 2) THEN
			      l_sub_validation_passed := 1;
			    ELSE
			      l_sub_validation_passed := 0;
			   END IF;
			END IF;
		      ELSE
			--The user should not be allowed to enter
			--LPN in inventory LPN
			IF (p_lpn_id <> l_into_lpn_id) THEN --bug 5380737
			  IF (l_sub_type = 2
			      AND l_lpn_sub_type = 2) THEN
			     l_sub_validation_passed := 1;
			  ELSE
			     l_sub_validation_passed := 0;
			  END IF;
			ELSE
			  l_sub_validation_passed := 1;
			END IF;
		     END IF;
		   ELSIF l_crossdock_type = 3 THEN
		     -- WIP Push.  Into LPN field shouldn't be shown
		     l_sub_validation_passed := 1;
		   ELSE --l_crossdock_type = 4: SO XDOCK mixed with WIP PULL
		     IF l_lpn_context = 2 THEN
			l_sub_validation_passed := 0;
		      ELSE
			--System won't suggest inventory loc
			IF (l_lpn_sub_type = 2) THEN
			   l_sub_validation_passed := 1;
			 ELSE
			   l_sub_validation_passed := 0;
			END IF;
		     END IF; --IF l_lpn_context = 2 THEN
		  END IF; --IF l_crossdock_type = 0 THEN
	       END IF;--IF (p_sub IS NOT NULL AND p_loc IS NOT NULL) THEN
	    END IF;--IF (p_drop_type = 'MANUAL_DROP' AND l_lpn_context <> l_into_lpn_context) THEN
	 END IF;--IF (l_into_lpn_sub IS NOT NULL AND l_into_lpn_loc_id IS NOT NULL) THEN

	 IF (l_debug = 1) THEN
	    debug('l_sub_validation_passed ===> '||l_sub_validation_passed,'validate_into_lpn',9);
	 END IF;

	 IF (l_sub_validation_passed <> 1) THEN
	    x_validation_passed := 'N';
	 END IF;

       END IF; -- Enf for p_drop_type = 'MANUAL_DROP' or p_drop_type = 'SYSTEM_DROP
       -- End for validating drop
   END IF;

-- if into LPN is an old one, need to check project/task ID
   IF (x_new_lpn_created = 'N') THEN
      IF (l_debug = 1) THEN
         debug('Validating project and task IDs...','validate_into_lpn', 9);
      END IF;

      BEGIN
  IF (l_lpn_context = 1) THEN
     SELECT
       project_id
       ,task_id
       INTO
       l_into_lpn_project_id
       ,l_into_lpn_task_id
       FROM
       mtl_item_locations
       WHERE
       inventory_location_id = l_into_lpn_loc_id;
   ELSE -- context is 2 or 3
     SELECT
       project_id
       ,task_id
       INTO
       l_into_lpn_project_id
       ,l_into_lpn_task_id
       FROM
       mtl_txn_request_lines mtrl, (SELECT lpn_id
                   FROM wms_license_plate_numbers
                   START WITH lpn_id = 1
                   CONNECT BY PRIOR lpn_id = parent_lpn_id
                  ) wlpn2
      WHERE
      mtrl.lpn_id= wlpn2.lpn_id
      AND ROWNUM = 1;
  END IF;
      EXCEPTION
   WHEN no_data_found THEN
      l_into_lpn_project_id := null;
      l_into_lpn_task_id := null;
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         debug('unexpected exception in select project/task id',
         'validate_into_lpn', 9);
      END IF;
      END;

      IF (l_debug = 1) THEN
   debug('Into LPN Project Id = '||l_into_lpn_project_id
         ||' Task Id = ' || l_into_lpn_task_id,
         'validate_into_lpn', 9);
      END IF;

      IF NOT (Nvl(p_project_id, -9999) = Nvl(l_into_lpn_project_id, -9999) AND
        Nvl(p_task_id, -9999) = Nvl(l_into_lpn_task_id, -9999)) THEN
   IF (l_debug = 1) THEN
      debug('validate project/task ID failed','validate_into_lpn',9);
   END IF;

   x_validation_passed := 'N';
   RAISE fnd_api.g_exc_error;
      END IF; --NOT (Nvl(p_project_id, 9999) = Nvl(l_into_lpn_project_id, 9999)
              -- AND Nvl(p_task_id, 9999) = Nvl(l_into_lpn_task_id, 9999))
   END IF;  -- IF (x_new_lpn_created = 'N')

   -- Set the return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '80';

   IF (l_debug = 1) THEN
      debug('***End of validate_into_lpn***','validate_into_lpn',9);
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_lpn_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      x_validation_passed := 'N';
      x_new_lpn_created := 'N';
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
        p_data  => x_msg_data);
      IF (l_debug = 1) THEN
     debug('Exiting validate_into_lpn - Execution error: ' ||
         l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),'validate_into_lpn',9);
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_lpn_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_validation_passed := 'N';
      x_new_lpn_created := 'N';
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
        p_data  => x_msg_data);
      IF (l_debug = 1) THEN
     debug('Exiting validate_into_lpn - Unexpected error: ' ||
         l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),'validate_into_lpn',9);
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO validate_lpn_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_validation_passed := 'N';
      x_new_lpn_created := 'N';
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
        p_data  => x_msg_data);
      IF (l_debug = 1) THEN
     debug('Exiting validate_into_lpn - Others exception: ' ||
         l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),'validate_into_lpn',9);
      END IF;

END validate_into_lpn;

PROCEDURE get_crossdock_info
  (p_lpn_id                 IN NUMBER,
   p_organization_id        IN NUMBER,
   x_back_order_delivery_id OUT nocopy NUMBER,
   x_crossdock_type         OUT nocopy NUMBER,
   x_wip_supply_type        OUT nocopy NUMBER )
  IS
     l_back_order_delivery_id NUMBER := -1;
     l_crossdock_type         NUMBER := -1;
     l_wip_supply_type        NUMBER := -1;
     l_backorder_delivery_ids num_tab;
     l_crossdock_types         num_tab;
     l_wip_supply_types        num_tab;
     l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),
				     0);
     l_progress VARCHAR(5) := '0';

BEGIN
   IF (l_debug = 1) THEN
      debug('Entering get_crossdock_into:','get_crossdock_info',9);
      debug('  p_lpn_id ==========> ' || p_lpn_id, 'get_crossdock_info',9);
      debug('  p_organization_id =>'||p_organization_id,'get_crossdock_info',9);
   END IF;

   l_progress := '10';

   BEGIN
      SELECT
	DISTINCT
	Nvl(mol.backorder_delivery_detail_id,-1) back_order_delivery_detail_id,
	Nvl(mol.crossdock_type,1) crossdock_type,
	Nvl(mmtt.wip_supply_type,0) wip_supply_type
	bulk collect INTO
	l_backorder_delivery_ids,
	l_crossdock_types,
	l_wip_supply_types
	FROM
	mtl_txn_request_lines mol,
	mtl_material_transactions_temp mmtt ,
	(SELECT wlpn.lpn_id  /*5723418*/
		FROM   wms_license_plate_numbers wlpn
		START WITH wlpn.lpn_id = p_lpn_id
		CONNECT BY PRIOR wlpn.lpn_id = wlpn.parent_lpn_id ) wlpn
	WHERE 	mol.lpn_id = wlpn.lpn_id
	AND mol.organization_id = p_organization_id
	AND mol.line_id = mmtt.move_order_line_id
	AND mmtt.organization_id = p_organization_id
	ORDER BY wip_supply_type DESC;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    debug('MMTT exists. Treat it as no crossdock','get_crossdock_info',9);
	 END IF;
   END;

   l_progress := '20';

   l_crossdock_type := 0;

   FOR i IN 1 .. l_backorder_delivery_ids.COUNT LOOP
      IF l_wip_supply_types(i) = 1 THEN
	 l_crossdock_type := 3; -- WIP PUSH overrides all other types
	 EXIT;
      END IF;

      IF l_backorder_delivery_ids(i) <> -1 AND l_crossdock_types(i) = 1 THEN
	 IF (l_crossdock_type = 0) THEN
	    l_crossdock_type := 1; -- SO xdock.
	  ELSIF (l_crossdock_type = 2) THEN
	    l_crossdock_type := 4; -- Both SO xdock and WIP Pulled XDOCK
	    -- No need to look further, since if there
	    -- is a WIP push, it should have been already processed
	    EXIT;
	 END IF;
      END IF;

      IF l_backorder_delivery_ids(i) <> -1 AND l_crossdock_types(i) = 2 THEN
	 -- If it comes here, then it must by a WIP PULL xdock
	 IF (l_crossdock_type = 0) THEN
	    l_crossdock_type := 2;
	  ELSIF (l_crossdock_type = 1) THEN
	    l_crossdock_type := 4; -- Both SO xdock and WIP Pulled XDOCK
	    EXIT;
	 END IF;
      END IF;
   END LOOP;

   l_progress := '30';

   x_back_order_delivery_id := -9999;
   x_crossdock_type := l_crossdock_type;
   x_wip_supply_type :=  -9999;

   IF (l_debug = 1) THEN
      debug('Exitting get_crossdock_into:','get_crossdock_info',9);
      debug('  x_backorder_delivery_detail_id ==========> ' || l_back_order_delivery_id, 'get_crossdock_info',9);
      debug('  x_crossdock_type =>'||l_crossdock_type,'get_crossdock_info',9);
      debug('  x_wip_supply_type =>'||l_wip_supply_type,'get_crossdock_info',9);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 debug('Exception occured after progress' || l_progress,'get_crossdock_info',9);
      END IF;

      NULL;
END get_crossdock_info;

PROCEDURE update_loc_suggested_capacity(
    x_return_status    OUT NOCOPY     VARCHAR2
  , x_msg_count        OUT NOCOPY     NUMBER
  , x_msg_data         OUT NOCOPY     VARCHAR2
  , p_organization_id  IN             NUMBER
  , p_lpn_id           IN             NUMBER
  , p_location_id      IN             NUMBER
) IS
    l_api_name CONSTANT VARCHAR2(30) := 'update_loc_suggested_capacity';
    l_progress          VARCHAR2(10);
    l_item_id           NUMBER;
    l_locator_id        NUMBER;
    l_quantity          NUMBER;
    l_uom_code          VARCHAR2(3);
    l_debug             NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    CURSOR l_suggestions_cursor IS
       --BUG 3435079: Use organization_id MTRL and MMTT
       --for performance reason
       SELECT mmtt.inventory_item_id
           , mmtt.locator_id
           , mmtt.transaction_quantity
           , mmtt.transaction_uom
      FROM   mtl_material_transactions_temp mmtt,
             mtl_txn_request_lines mtrl ,
	     (SELECT lpn_id     /*5723418*/
                   FROM wms_license_plate_numbers
		   START WITH lpn_id = p_lpn_id
		   CONNECT BY PRIOR lpn_id = parent_lpn_id) wlpn
	WHERE  mmtt.move_order_line_id = mtrl.line_id
	AND  mmtt.organization_id = p_organization_id
	AND  mtrl.organization_id = p_organization_id
        AND  mtrl.lpn_id  = wlpn.lpn_id
        AND  NVL(mmtt.wms_task_type, 0) <> -1;

  BEGIN
    IF (l_debug = 1) THEN
      debug('***Calling WMSPUTLB.update_loc_suggested_capacity***');
      debug('Org ID: => ' || p_organization_id);
      debug('LPN ID: => ' || p_lpn_id);
      debug('USER ENTERED LOCATOR ID: => ' || p_location_id);
    END IF;

    -- Set the savepoint
    SAVEPOINT update_capacity_sp;
    l_progress := '10';
    -- Loop through each suggested MMTT line for the LPN
    OPEN l_suggestions_cursor;

    LOOP
      FETCH l_suggestions_cursor INTO l_item_id, l_locator_id, l_quantity, l_uom_code;
      EXIT WHEN l_suggestions_cursor%NOTFOUND;

      IF (l_debug = 1) THEN
        debug('Current MMTT suggestion values:');
        debug('Inventory Item ID: => ' || l_item_id);
        debug('Locator ID: ========> ' || l_locator_id);
        debug('Transaction qty: ===> ' || l_quantity);
        debug('Transaction UOM: ===> ' || l_uom_code);
      END IF;

      l_progress := '20';

      IF (l_debug = 1) THEN
        debug('Call INV_LOC_WMS_UTILS.update_loc_suggested_capacity API');
      END IF;

      inv_loc_wms_utils.update_loc_suggested_capacity(
        x_return_status             => x_return_status
      , x_msg_count                 => x_msg_count
      , x_msg_data                  => x_msg_data
      , p_organization_id           => p_organization_id
      , p_inventory_location_id     => p_location_id
      , p_inventory_item_id         => l_item_id
      , p_primary_uom_flag          => 'N'
      , p_transaction_uom_code      => l_uom_code
      , p_quantity                  => l_quantity
      );
      l_progress := '30';

      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
        IF (l_debug = 1) THEN
          debug('Success returned from update_loc_suggested_capacity API');
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          debug('Failure returned from update_loc_suggested_capacity API');
        END IF;
        -- Bug 5393727: do not raise an exception if locator API returns an error
        -- RAISE fnd_api.g_exc_error;
      END IF;

      l_progress := '40';
    END LOOP;

    CLOSE l_suggestions_cursor;
    -- Set the output variable
    x_return_status := fnd_api.g_ret_sts_success;
    l_progress := '50';

    IF (l_debug = 1) THEN
      debug('***End of update_loc_suggested_capacity***');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_capacity_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        debug(
          'Exiting update_loc_suggested_capacity - Execution error: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        );
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_capacity_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        debug(
          'Exiting update_loc_suggested_capacity - Unexpected error: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        );
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO update_capacity_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        debug(
          'Exiting update_loc_suggested_capacity - Others exception: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        );
      END IF;
END update_loc_suggested_capacity;

PROCEDURE validate_material_status
  (x_passed             OUT NOCOPY     VARCHAR2
   , p_organization_id  IN             NUMBER
   , p_sub              IN             VARCHAR2
   , p_loc              IN             NUMBER
   ) IS
      l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
      l_proc_name VARCHAR2(30) := 'validate_material_status';
BEGIN
   IF (l_debug = 1) THEN
      DEBUG(' Function Entered at ' ||
	    to_char(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),l_proc_name,1);
      DEBUG(' p_organization_id   => '||p_organization_id,l_proc_name , 4);
      DEBUG(' p_sub => '||p_sub,l_proc_name, 4);
      DEBUG(' p_loc => '||p_loc,l_proc_name, 4);
   END IF;

   IF (inv_material_status_grp.is_status_applicable('TRUE',
                        NULL,
                        2,--subtransfer
                        NULL,
                        NULL,
                        p_organization_id,
                        NULL,
                        p_sub,
                        p_loc,
                        NULL,
                        NULL,
                        'Z') ='Y' AND
	    inv_material_status_grp.is_status_applicable('TRUE',
                        NULL,
			2,--Sub Transfer
                        NULL,
                        NULL,
                        p_organization_id,
                        NULL,
                        p_sub,
                        p_loc,
                        NULL,
                        NULL,
                        'L') = 'Y') THEN
      x_passed := 'Y';
    ELSE
      x_passed := 'N';
   END IF;
   IF (l_debug = 1) THEN
      DEBUG(' x_passed => '||x_passed,l_proc_name, 4);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_passed := 'Y';
END validate_material_status;

FUNCTION populate_grouping_rows
           (p_lpn_id    IN NUMBER)
         RETURN NUMBER IS

	CURSOR c_lpn_bo_dd_id (v_lpn_id NUMBER)IS
     	SELECT mtrl.backorder_delivery_detail_id,
               wda.delivery_id
     	FROM   mtl_txn_request_lines mtrl,
               wsh_delivery_assignments_v wda
     	WHERE  lpn_id = v_lpn_id
        AND    mtrl.backorder_delivery_detail_id = wda.delivery_detail_id;

	l_count NUMBER := 1;
        l_bo_dd_id NUMBER;
        l_return_status VARCHAR2(1);
        l_progress NUMBER;
	l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
	l_proc_name VARCHAR2(30) := 'populate_grouping_rows';

BEGIN

	g_line_rows.delete;
        g_grouping_rows.delete;

	IF (l_debug = 1) THEN
		debug('populate_grouping_rows: p_lpn_id='||p_lpn_id);
	END IF;

	l_progress := 100;

	OPEN  c_lpn_bo_dd_id(p_lpn_id);

        FETCH c_lpn_bo_dd_id BULK COLLECT INTO g_line_rows, g_grouping_rows;
	CLOSE c_lpn_bo_dd_id;

	l_progress := 300;

	IF (l_debug = 1) THEN
		debug('populate_grouping_rows: g_line_rows.count='||g_line_rows.count);
		debug('populate_grouping_rows: g_grouping_rows.count='||g_grouping_rows.COUNT);
	END IF;

	RETURN g_grouping_rows.COUNT;

END populate_grouping_rows;

FUNCTION get_grouping_count
	   (p_line_rows  IN WSH_UTIL_CORE.id_tab_type)
	RETURN NUMBER IS

	l_count NUMBER;
	l_bo_dd_id NUMBER := -1;
	l_duplicate NUMBER := 0;
	l_progress NUMBER;
        l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
        l_proc_name VARCHAR2(30) := 'get_grouping_count';

BEGIN

	IF (l_debug = 1) THEN
		debug('get_grouping_count: Inside get_grouping_count');
	END IF;

	FOR l_count IN 1..p_line_rows.COUNT LOOP
		IF (l_debug = 1) THEN
			debug('get_grouping_count: l_bo_dd_id='||l_bo_dd_id);
                	debug('get_grouping_count: p_line_rows(l_count)='||p_line_rows(l_count));
		END IF;

		IF (l_bo_dd_id <> p_line_rows(l_count)) THEN
                        l_duplicate := l_duplicate + 1;
                END IF;

                l_bo_dd_id := p_line_rows(l_count);
	END LOOP;

	IF (l_debug = 1) THEN
		debug('get_grouping_count: l_duplicate='||l_duplicate);
	END IF;

	RETURN l_duplicate;

END get_grouping_count;

FUNCTION get_grouping
	   (p_bo_dd_id IN NUMBER)
	RETURN NUMBER IS

	l_index NUMBER;
	i NUMBER;
	l_progress NUMBER;
        l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
        l_proc_name VARCHAR2(30) := 'get_grouping';

BEGIN
	IF (l_debug = 1) THEN
		debug('get_grouping: p_bo_dd_id='||p_bo_dd_id);
	END IF;

	<<get_grouping_loop>>
	FOR i IN 1..g_line_rows.COUNT LOOP
		IF (l_debug = 1) THEN
			debug('get_grouping: g_line_rows(i)='||g_line_rows(i));
		END IF;
		IF (g_line_rows(i) = p_bo_dd_id) THEN
			l_index := i;
			debug('get_grouping: l_index='||l_index);
			EXIT get_grouping_loop;
		END IF;
	END LOOP;

	IF (l_debug = 1) THEN
	   debug('get_grouping: l_index='||l_index);
	   IF l_index IS NOT NULL THEN
	      debug('get_grouping: g_grouping_rows(l_index)='||g_grouping_rows(l_index));
	   END IF;
	END IF;

	IF l_index IS NOT NULL THEN
	   RETURN g_grouping_rows(l_index);
	 ELSE
	   RETURN p_bo_dd_id;
	END IF;

END get_grouping;

--Added following procedure for bug 7143123
 /**
    *  Cleanup_LPN_Crossdock_Wrapper, This procedure explodes the given LPN
    *  and for each LPN checks whether crossdock move order exists and if so clean up the crossdock related data.
    *  @param   p_org_id   Current Organization
    *  @param   p_lpn_id   From LPN ID
    *  @param   x_return_status
    **/

    PROCEDURE Cleanup_LPN_Crossdock_Wrapper(
      p_org_id         IN             NUMBER
    , p_lpn_id         IN             NUMBER
    , x_return_status  OUT NOCOPY     VARCHAR2
    )
     IS
      l_progress         NUMBER;
      l_lpn_id           NUMBER;
      l_tempid           NUMBER;
      l_debug            NUMBER           := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
      l_content_lpn      VARCHAR2(1)      := 'N';
      l_lpn_context      NUMBER;
      l_lpn_has_contents VARCHAR2(1)      := 'N';
      l_x_msg_count      NUMBER;
      l_error_code       NUMBER;
      l_x_msg_data       FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE; --VARCHAR2(2000);
      l_proc_name        VARCHAR2(100)    := 'Cleanup_LPN_Crossdock_Wrapper';


      CURSOR lpn_cursor IS
	SELECT     lpn_id
	      FROM wms_license_plate_numbers
	START WITH lpn_id = p_lpn_id
	CONNECT BY parent_lpn_id = PRIOR lpn_id;

     CURSOR c_mmtt_cursor(p_lpn number) IS
	 SELECT mmtt.transaction_temp_id,
	  mmtt.parent_line_id,
		mmtt.operation_plan_id,
		mol.line_id move_order_line_id,
		mmtt.operation_seq_num,
		mmtt.repetitive_line_id,
		mmtt.primary_quantity,
		mmtt.inventory_item_id,
		mol.crossdock_type,
		mol.backorder_delivery_detail_id
	   FROM  mtl_material_transactions_temp mmtt,
		 mtl_txn_request_lines mol
	  WHERE  mmtt.move_order_line_id(+) = mol.line_id
	     AND mmtt.wms_task_type=2
	     AND mol.organization_id = mmtt.organization_id(+)
	     AND mol.organization_id=p_org_id
	     AND mol.lpn_id = p_lpn
	     AND mol.LINE_STATUS <> 5
	     AND EXISTS (SELECT 1 FROM mtl_txn_request_lines
			  WHERE lpn_id = p_lpn
			   AND BACKORDER_DELIVERY_DETAIL_ID IS NOT NULL);

       l_mmtt_rec c_mmtt_cursor%ROWTYPE;
       PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN

      -- Intialize out variables.
      l_progress := 10;
      l_content_lpn := 'N';
      x_return_status := fnd_api.g_ret_sts_success;

      IF (l_debug = 1) THEN
	debug(l_progress||'Patchset J code - Cleanup_LPN_Crossdock_Wrapper');
	debug(l_progress||'p_org_id==> '|| p_org_id);
	debug(l_progress||'p_lpn_id==> '|| p_lpn_id);
      END IF;

      -- Get LPN Context
      SELECT lpn_context
      INTO l_lpn_context
      FROM   wms_license_plate_numbers
      WHERE  lpn_id = p_lpn_id;

      l_progress := 20;

      OPEN lpn_cursor;
       l_progress := 30;
      LOOP
	FETCH lpn_cursor INTO l_lpn_id;
	EXIT WHEN lpn_cursor%NOTFOUND;
	l_content_lpn      := 'N';

	IF(l_debug = 1) THEN
	  debug(l_progress||'cleaning crossdock of Lpn ' || l_lpn_id);
	END IF;
       l_progress := 40;
	-- Check lpn has contents
	BEGIN
	  SELECT 'Y','Y'
	    INTO l_content_lpn,l_lpn_has_contents
	    FROM wms_lpn_contents
	   WHERE parent_lpn_id = l_lpn_id
	     AND ROWNUM<2;
	EXCEPTION
	  WHEN no_data_found THEN
	    l_content_lpn := 'N';
	END;

	IF l_debug = 1 THEN
	  IF (l_content_lpn = 'N') THEN debug(l_progress||'lpn ' || l_lpn_id || 'has no contents'); END IF;
	  IF (l_content_lpn = 'Y') THEN debug(l_progress||'lpn ' || l_lpn_id || 'has contents'); END IF;
	END IF;

	IF l_content_lpn ='Y' THEN
	   IF (l_lpn_context = 3) THEN
	      OPEN  c_mmtt_cursor(l_lpn_id);
       l_progress := 50;
      LOOP
      FETCH c_mmtt_cursor INTO l_mmtt_rec;
      EXIT WHEN c_mmtt_cursor%NOTFOUND;

      IF (l_debug=1) THEN
			   debug(l_progress||'Before calling revert_crossdock with following params:', l_proc_name,1);
			   debug(l_progress||'transaction_temp_id => '|| l_mmtt_rec.transaction_temp_id, l_proc_name,1);
			   debug(l_progress||'parent_line_id => '|| l_mmtt_rec.parent_line_id, l_proc_name,1);
			   debug(l_progress||'p_move_order_line_id => '|| l_mmtt_rec.move_order_line_id, l_proc_name,1);
			   debug(l_progress||'p_crossdock_type => '|| l_mmtt_rec.crossdock_type, l_proc_name,1);
			   debug(l_progress||'p_backorder_delivery_detail_id => '|| l_mmtt_rec.backorder_delivery_detail_id, l_proc_name,1);
			   debug(l_progress||'p_repetitive_line_id => '|| l_mmtt_rec.repetitive_line_id, l_proc_name,1);
			   debug(l_progress||'p_operation_seq_number => '|| l_mmtt_rec.operation_seq_num, l_proc_name,1);
			   debug(l_progress||'p_inventory_item_id => '|| l_mmtt_rec.inventory_item_id, l_proc_name,1);
			   debug(l_progress||'p_primary_quantity => '|| l_mmtt_rec.primary_quantity, l_proc_name,1);
		  END IF;

       l_progress := 60;
      IF l_mmtt_rec.transaction_temp_id IS NOT NULL THEN
      wms_atf_runtime_pub_apis.Cleanup_Operation_Instance
		(  p_source_task_id    => l_mmtt_rec.transaction_temp_id
		       , p_activity_type_id  => G_OP_ACTIVITY_INBOUND
		       , x_return_status     => x_return_status
		       , x_msg_data          => l_x_msg_data
		       , x_msg_count         => l_x_msg_count
		       , x_error_code        => l_error_code
		      );

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
		 IF (l_debug = 1) THEN
		    debug(l_progress||l_error_code || ' Error in Cleanup_Operation_Instance ' ,l_proc_name,1);
		 END IF;
		 l_progress := 70;
		 x_return_status  := fnd_api.g_ret_sts_error;
		 /* Don't raise error in case of failure, instead set the ret status as error
		 and proceed with the next record */
		   END IF;

       l_progress := 80;

       FOR wooi IN (SELECT operation_instance_id
			   FROM wms_op_operation_instances
			  WHERE source_task_id = l_mmtt_rec.transaction_temp_id
		   ) LOOP

	 wms_op_runtime_pvt_apis.delete_operation_instance
	   (  p_operation_instance_id  => wooi.operation_instance_id
	    , x_return_status          => x_return_status
			, x_msg_data               => l_x_msg_data
			, x_msg_count              => l_x_msg_count
	   );

	   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
		 IF (l_debug = 1) THEN
		    debug(l_progress||l_error_code || ' Error in delete_operation_instance ' ,l_proc_name,1);
		 END IF;
		 l_progress := 90;
		 x_return_status  := fnd_api.g_ret_sts_error;
		 /* Don't raise error in case of failure, instead set the ret status as error
		 and proceed with the next record */
		   END IF;


       END LOOP;
       l_progress := 100;

       FOR wopi IN (SELECT OP_PLAN_INSTANCE_ID
			   FROM wms_op_plan_instances
			  WHERE source_task_id = l_mmtt_rec.parent_line_id
		    ) LOOP
	 l_progress := 110;
	 wms_op_runtime_pvt_apis.delete_plan_instance
	   (  p_op_plan_instance_id  => wopi.OP_PLAN_INSTANCE_ID
	    , x_return_status          => x_return_status
			, x_msg_data               => l_x_msg_data
			, x_msg_count              => l_x_msg_count
	   );

	   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
		 IF (l_debug = 1) THEN
		    debug(l_progress||l_error_code || ' Error in delete_plan_instance ' ,l_proc_name,1);
		 END IF;
		 l_progress := 120;
		 x_return_status  := fnd_api.g_ret_sts_error;
		 /* Don't raise error in case of failure, instead set the ret status as error
		 and proceed with the next record */
		   END IF;

       END LOOP;

       l_progress := 130;
      inv_trx_util_pub.delete_transaction
	  (  x_return_status        => x_return_status
		       , x_msg_data             => l_x_msg_data
		       , x_msg_count            => l_x_msg_count
	   , p_transaction_temp_id  => l_mmtt_rec.transaction_temp_id
	   , p_update_parent        => true
	  );

      IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
		 IF (l_debug = 1) THEN
		    debug(l_progress||' Error in delete_transaction ' ,l_proc_name,1);
		 END IF;
		 l_progress := 140;
		 x_return_status  := fnd_api.g_ret_sts_error;
		 /* Don't raise error in case of failure, instead set the ret status as error
		 and proceed with the next record */
		   END IF;
       END IF;

      l_progress := 150;


       IF l_mmtt_rec.backorder_delivery_detail_id IS NOT NULL then
      WMS_OP_INBOUND_PVT.revert_crossdock
			  (x_return_status                  => x_return_status
			   , x_msg_count                    => l_x_msg_count
			   , x_msg_data                     => l_x_msg_data
			   , p_move_order_line_id           => l_mmtt_rec.move_order_line_id
			   , p_crossdock_type               => l_mmtt_rec.crossdock_type
			   , p_backorder_delivery_detail_id => l_mmtt_rec.backorder_delivery_detail_id
			   , p_repetitive_line_id           => l_mmtt_rec.repetitive_line_id
			   , p_operation_seq_number         => l_mmtt_rec.operation_seq_num
			   , p_inventory_item_id            => l_mmtt_rec.inventory_item_id
			   , p_primary_quantity             => l_mmtt_rec.primary_quantity
			   );

	 IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
		 IF (l_debug = 1) THEN
		    debug(l_progress||' Error in revert_crossdock ' ,l_proc_name,1);
		 END IF;
		 l_progress := 160;
		 x_return_status  := fnd_api.g_ret_sts_error;
		 /* Don't raise error in case of failure, instead set the ret status as error
		 and proceed with the next record */
		   END IF;

       END IF;
       l_progress := 170;

       UPDATE mtl_txn_request_lines SET quantity_detailed=NULL WHERE line_id=l_mmtt_rec.move_order_line_id;

       l_progress := 180;

      END LOOP;

      IF c_mmtt_cursor%isopen THEN
	CLOSE c_mmtt_cursor;
      END IF;
      l_progress := 190;

	    END IF;

	    IF(l_debug= 1) THEN
	      debug(l_progress||'After cleaning crossdock for lpn '|| l_lpn_id);
	      debug(l_progress||'Return status ' || x_return_status);
	    END IF;

	l_progress := 200;
	END IF;
      END LOOP;

      l_progress := 210;
      IF lpn_cursor%isopen THEN
	CLOSE lpn_cursor;
      END IF;

      COMMIT;
      RETURN;


    EXCEPTION
      WHEN OTHERS THEN
	ROLLBACK;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	debug(l_progress||SQLCODE, 1);

	IF lpn_cursor%isopen THEN
	  CLOSE lpn_cursor;
	END IF;

	IF c_mmtt_cursor%isopen THEN
	CLOSE c_mmtt_cursor;
      END IF;

	IF SQLCODE IS NOT NULL THEN
	  l_progress := 220;
	  inv_mobile_helper_functions.sql_error('Cleanup_LPN_Crossdock_Wrapper', l_progress, SQLCODE);
	END IF;
    END Cleanup_LPN_Crossdock_Wrapper;

END WMS_PUTAWAY_UTILS; --End of Package

/
