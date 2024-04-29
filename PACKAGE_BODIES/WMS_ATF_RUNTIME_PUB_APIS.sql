--------------------------------------------------------
--  DDL for Package Body WMS_ATF_RUNTIME_PUB_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_ATF_RUNTIME_PUB_APIS" AS
  /* $Header: WMSATFRB.pls 120.18 2008/04/29 14:02:58 abaid ship $*/

  --
  -- File        : $RCSFile: $
  -- Content     : WMS_ATF_RUNTIME_PUB_APIS package Body
  -- Description : WMS Operation Plan Run-time APIs
  -- Notes       :
  -- Modified    : 7/24/2003 lezhang created

  g_txn_type_so_stg_xfr    NUMBER       := inv_globals.g_type_transfer_order_stgxfr;
  g_op_dest_sys_suggested  NUMBER       := wms_globals.g_op_dest_sys_suggested;
  g_op_dest_api            NUMBER       := wms_globals.g_op_dest_api;
  g_op_dest_pre_specified  NUMBER       := wms_globals.g_op_dest_pre_specified;
  g_op_dest_rules_engine   NUMBER       := wms_globals.g_op_dest_rules_engine;
  g_wms_task_type_pick     NUMBER       := wms_globals.g_wms_task_type_pick;
  g_wms_task_type_stg_move NUMBER       := wms_globals.g_wms_task_type_stg_move;
  g_wms_task_type_putaway  NUMBER       := wms_globals.g_wms_task_type_putaway;
  g_wms_task_type_inspect  NUMBER       := wms_globals.g_wms_task_type_inspect;
  g_op_drop_lpn_no_lpn     NUMBER       := wms_globals.g_op_drop_lpn_no_lpn;
  g_op_drop_lpn_optional   NUMBER       := wms_globals.g_op_drop_lpn_optional;
  g_ret_sts_success        VARCHAR2(1)  := fnd_api.g_ret_sts_success;
  g_ret_sts_unexp_error    VARCHAR2(1)  := fnd_api.g_ret_sts_unexp_error;
  g_ret_sts_error          VARCHAR2(1)  := fnd_api.g_ret_sts_error;
  g_msg_lvl_unexp_error    NUMBER       := fnd_msg_pub.g_msg_lvl_unexp_error;
  g_msg_lvl_error          NUMBER       := fnd_msg_pub.g_msg_lvl_error;
  g_version_printed        BOOLEAN      := FALSE;
  g_pkg_name               VARCHAR2(30) := 'WMS_ATF_RUNTIME_PUB_APIS';

  G_OP_TYPE_LOAD CONSTANT NUMBER := wms_globals.g_op_type_load;
  G_OP_TYPE_DROP CONSTANT NUMBER:= wms_globals.G_OP_TYPE_DROP;
  G_OP_TYPE_SORT CONSTANT NUMBER:= wms_globals.G_OP_TYPE_SORT;
  G_OP_TYPE_CONSOLIDATE CONSTANT NUMBER:= wms_globals.G_OP_TYPE_CONSOLIDATE;
  G_OP_TYPE_PACK CONSTANT NUMBER:= wms_globals.G_OP_TYPE_PACK;
  G_OP_TYPE_LOAD_SHIP CONSTANT NUMBER:= wms_globals.G_OP_TYPE_LOAD_SHIP;
  G_OP_TYPE_SHIP CONSTANT NUMBER:=  wms_globals.G_OP_TYPE_SHIP;
  G_OP_TYPE_CYCLE_COUNT CONSTANT NUMBER :=  wms_globals.G_OP_TYPE_CYCLE_COUNT;
  G_OP_TYPE_INSPECT CONSTANT NUMBER :=  wms_globals.G_OP_TYPE_INSPECT;
  G_OP_TYPE_CROSSDOCK CONSTANT NUMBER:= wms_globals.G_OP_TYPE_CROSSDOCK;

  G_OP_ACTIVITY_INBOUND CONSTANT NUMBER:= wms_globals.G_OP_ACTIVITY_INBOUND;
  g_task_status_dispatched CONSTANT NUMBER:= 3;
  g_task_status_loaded CONSTANT NUMBER:= 4;
  G_OP_INS_STAT_PENDING CONSTANT NUMBER := wms_globals.G_OP_INS_STAT_PENDING;
  G_OP_INS_STAT_ACTIVE CONSTANT NUMBER := wms_globals.G_OP_INS_STAT_ACTIVE;
  G_OP_INS_STAT_COMPLETED CONSTANT NUMBER := wms_globals.G_OP_INS_STAT_COMPLETED;
  G_OP_INS_STAT_ABORTED   CONSTANT NUMBER := WMS_GLOBALS.G_OP_INS_STAT_ABORTED;
  G_OP_INS_STAT_CANCELLED CONSTANT NUMBER := WMS_GLOBALS.G_OP_INS_STAT_CANCELLED;
  G_OP_INS_STAT_IN_PROGRESS CONSTANT NUMBER := WMS_GLOBALS.G_OP_INS_STAT_IN_PROGRESS;
  G_OP_DEST_SYS_SUGGESTED CONSTANT NUMBER := WMS_GLOBALS.G_OP_DEST_SYS_SUGGESTED;


  PROCEDURE print_debug(p_err_msg IN VARCHAR2, p_module_name IN VARCHAR2, p_level IN NUMBER) IS
  BEGIN
    IF NOT g_version_printed THEN
      inv_mobile_helper_functions.tracelog(p_err_msg => '$Header: WMSATFRB.pls 120.18 2008/04/29 14:02:58 abaid ship $', p_module => g_pkg_name, p_level => 9);
      g_version_printed  := TRUE;
    END IF;

--    dbms_output.put_line(p_module_name||'  :  '||p_err_msg);

    inv_mobile_helper_functions.tracelog(p_err_msg => p_err_msg, p_module => g_pkg_name || '.' ||p_module_name, p_level => p_level);
  END print_debug;



 /**
    *    INIT_OP_PLAN_INSTANCE:
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
  , p_activity_id      IN             NUMBER
  ) IS

  CURSOR inbound_document_details IS
     SELECT transaction_temp_id,
            operation_plan_id,
            inventory_item_id,
            subinventory_code,
            locator_id,
            transfer_subinventory,
            transfer_to_location,
            organization_id,
            wms_task_type,
            primary_quantity
       FROM mtl_material_transactions_temp
     WHERE transaction_temp_id=p_source_task_id;

  CURSOR c_operation_plan(v_operation_plan_id NUMBER) IS
     SELECT plan_type_id, crossdock_to_wip_flag
      FROM WMS_OP_PLANS_B
     WHERE operation_plan_id=v_operation_plan_id;

  CURSOR c_loc_selection_type(v_op_plan_id NUMBER) IS
     SELECT loc_selection_criteria
      FROM wms_op_plan_details
     WHERE operation_sequence=(SELECT MAX(operation_sequence)
                               FROM wms_op_plan_details
                               WHERE operation_plan_id=v_op_plan_id)
     AND operation_type IN (G_OP_TYPE_DROP,G_OP_TYPE_CROSSDOCK)
     AND operation_plan_id=v_op_plan_id;

  CURSOR c_plan_detail(v_operation_plan_id NUMBER) IS
     SELECT  operation_plan_detail_id
           , operation_sequence
           , is_in_inventory
           , operation_type
           , subsequent_op_plan_id
    FROM WMS_OP_PLAN_DETAILS
     WHERE operation_plan_id  = v_operation_plan_id
     AND   operation_sequence = (SELECT MIN(operation_sequence)
                                       FROM WMS_OP_PLAN_DETAILS
                                      WHERE operation_plan_id=v_operation_plan_id);

  CURSOR c_plan_instance_exists IS
     SELECT 1
     FROM WMS_OP_PLAN_INSTANCES
     WHERE source_task_id=p_source_task_id
     AND activity_type_id=p_activity_id;

  CURSOR c_operation_instance_exists IS
     SELECT 1
     FROM WMS_OP_OPERATION_INSTANCES
     WHERE source_task_id=p_source_task_id
     AND activity_type_id=p_activity_id;


                    l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
              l_module_name     VARCHAR2(30) := 'Init_OP_Plan_Instance';
                 l_progress     NUMBER;

          l_inbound_doc_rec     inbound_document_details%ROWTYPE :=NULL;
                 l_mmtt_rec     MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE:=NULL;
       l_operation_plan_rec     c_operation_plan%ROWTYPE:=NULL;
l_operation_plan_detail_rec     c_plan_detail%ROWTYPE:=NULL;
     l_op_plan_instance_rec     WMS_OP_PLAN_INSTANCES%ROWTYPE:=NULL;
   l_operation_instance_rec     WMS_OP_OPERATION_INSTANCES%ROWTYPE :=NULL;
        l_operation_plan_id     NUMBER;
         l_operation_exists     NUMBER;
              l_plan_exists     NUMBER;
           l_source_task_id     NUMBER;
          l_source_sub_code     VARCHAR2(10);
        l_source_locator_id     NUMBER;
     l_final_loc_sel_criter     NUMBER;
     l_revert_loc_capacity     BOOLEAN :=FALSE;

  BEGIN

       IF (l_debug = 1) THEN
         print_debug(' p_source_task_id   ==> ' || p_source_task_id, l_module_name,3);
         print_debug(' p_activity_id ==> ' || p_activity_id, l_module_name,3);
       END IF;

       SAVEPOINT init_plan_sp;

       x_return_status  := g_ret_sts_success;

       l_progress:=10;

       IF (p_source_task_id IS NULL OR p_activity_id IS NULL) THEN
          IF (l_debug=1) THEN
             print_debug('Source task Id is null',l_module_name,1);
          END IF;

          /*Raise Invalid Arguement exception*/
          --x_error_code:=1;
          --RAISE FND_API.G_EXC_ERROR;
          raise_application_error(INVALID_INPUT,'Invalid inputs passed'||p_source_task_id||' '||p_activity_id);

       END IF;

       IF p_activity_id NOT IN (G_OP_ACTIVITY_INBOUND) THEN

          /*Raise Invalid Arguement Exception*/
          raise_application_error(INVALID_INPUT,'Invalid inputs passed'||p_source_task_id||' '||p_activity_id);

       END IF;

       /*Query document table(s) based on p_activity_id and P_Source_task_ID.*/

       IF (p_activity_id =G_OP_ACTIVITY_INBOUND) THEN


           /*Fetching document Record for Inbound:from MMTT*/
             IF (l_debug=1) THEN
                  print_debug('Fetching document record for Inbound',l_module_name,9);
             END IF;

             OPEN inbound_document_details;
             FETCH inbound_document_details INTO l_inbound_doc_rec;

             IF (inbound_document_details%NOTFOUND) THEN
                IF (l_debug=1) THEN
                   print_debug('Invalid document',l_module_name,3);
                END IF;

                --x_error_code:=2;
                --RAISE FND_API.G_EXC_ERROR;
                CLOSE inbound_document_details;

                raise_application_error(INVALID_DOC_ID,'Invalid Document');
             END IF;

             CLOSE inbound_document_details;

             l_operation_plan_id:=l_inbound_doc_rec.operation_plan_id;
             l_progress:=20;

             IF (l_debug=1) THEN
                print_debug('Operation Plan id'||l_operation_plan_id,l_module_name,9);
             END IF;

             l_progress:=30;

       END IF;

       IF (l_operation_plan_id IS NULL) THEN
          /*
          * Null MMTT.Operation_Plan_ID is an error for this API. Not like activate_operation_instance
          * or complete_operation_instance, in which an MMTT record without operation_plan_ID
          * could have been loaded before J upgrade, init_plan_instance is always called after
          * operation plan assignment.
         */
          l_progress:=40;

          IF (l_debug=1) THEN
             print_debug('Operation Plan Id is null and unforgivable error',l_module_name,1);
          END IF;

          --x_error_code:=3;
          --RAISE FND_API.G_EXC_ERROR;
          raise_application_error(INVALID_PLAN_ID, 'Invalid Plan');
          /*Raise user defined exception to populated error code*/

       END IF;

       l_progress:=50;

       /* Query WMS_OP_PLANS_B for the operation_plan_id of this P_Source_task_ID;
        * and query WMS_OP_PLAN_DETAILS (WOPD) for the first (smallest operation_sequence)
        *  WOPD record for this plan for the operation_plan_id of this P_Source_task_ID;
        *  Populate PL/SQL records for these two tables.
        *  If Operation_Plan_ID is invalid then raise error exception.
        */

          IF (l_debug=1) THEN
            print_debug('Fetching the plan details for the operation plan stamped',l_module_name,9);
          END IF;

          OPEN c_operation_plan(l_operation_plan_id);

          FETCH c_operation_plan INTO l_operation_plan_rec;

          IF (c_operation_plan%NOTFOUND) THEN

             /*Invalid operation Plan stamped:Hence raise user defined exception and populate error code*/
             IF (l_debug=1) THEN
                print_debug('Invalid operation Plan stamped on document',l_module_name,3);
             END IF;
             --x_error_code:=4;
             --RAISE FND_API.G_EXC_ERROR;
             CLOSE c_operation_plan;
             raise_application_error(INVALID_PLAN_ID, 'Invalid Plan');

          END IF;

          CLOSE c_operation_plan;

          l_progress:=60;

          OPEN c_plan_detail(l_operation_plan_id);

          FETCH c_plan_detail INTO l_operation_plan_detail_rec;

          IF (c_plan_detail%NOTFOUND) THEN

             /*Invalid operation Plan stamped:Hence raise user defined exception and populate error code*/
             IF (l_debug=1) THEN
                print_debug('Invalid operation Plan stamped on document',l_module_name,3);
             END IF;
             --x_error_code:=4;
             --RAISE FND_API.G_EXC_ERROR;
             CLOSE c_plan_detail;
             raise_application_error(INVALID_PLAN_ID,'Invalid Plan');

          END IF;

          CLOSE c_plan_detail;
          l_progress:=70;


           /*Query WMS_OP_PLAN_INSTANCES for P_Source_task_ID,
             if the Source Task ID already has another Operation Plan Instance
             associated with it raise unexpected error exception. Populate proper error code. */

            OPEN c_plan_instance_exists;

            FETCH c_plan_instance_exists INTO l_plan_exists;

            l_progress:=90;

            IF c_plan_instance_exists%FOUND THEN
               IF (l_debug=1) THEN
                 print_debug('Plan instance already exists for Plan instance and src task id',l_module_name,1);
               END IF;

               --RAISE FND_API.G_EXC_ERROR;
               CLOSE c_plan_instance_exists;

               raise_application_error(PLAN_INSTANCE_EXISTS,'Plan Instance already exists');

            END IF;

            CLOSE c_plan_instance_exists;


       l_progress:=100;

       /* Query WMS_OP_OPERATION_INSTANCES for p_source_task_id. This should error out in case if
        * the p_source_task_id is already an operation instance.If so raise unexpected error condition
        */

       OPEN c_operation_instance_exists;

       FETCH c_operation_instance_exists INTO l_operation_exists;

       l_progress:=102;

       IF c_operation_instance_exists%FOUND THEN

          IF (l_debug=1) THEN
             print_debug('The Source task id passed already exists as an operation instance',l_module_name,1);
          END IF;

          CLOSE c_operation_instance_exists;

          RAISE_APPLICATION_ERROR(INVALID_DOC_ID,'Invalid Document Id');


       END IF;

       CLOSE c_operation_instance_exists;


       /*Create child document record */
       IF (p_activity_id =G_OP_ACTIVITY_INBOUND) THEN


          /*If the final determination method of the final drop is not System Suggested then the suggested
            capacity of the locator needs to be reverted*/


          OPEN c_loc_selection_type(l_operation_plan_id);

          FETCH c_loc_selection_type INTO l_final_loc_sel_criter;

          CLOSE c_loc_selection_type;

          IF (l_debug=1) THEN
             print_debug('Locator Selection Type'||l_final_loc_sel_criter,l_module_name,9);
          END IF;

          /*If Plan Type is inspect or the last drop in the in PLan does not have a determination type
            of system suggested*/

          IF l_operation_plan_rec.plan_type_id=2 OR
                            l_final_loc_sel_criter<>WMS_GLOBALS.G_OP_DEST_SYS_SUGGESTED THEN

             IF l_debug=1 THEN
               print_debug('Locator Capacity needs to be reverted',l_module_name,9);
             END IF;

             l_revert_loc_capacity:=TRUE;

          END IF;



          l_mmtt_rec.transaction_temp_id   := p_source_task_id;
          l_mmtt_rec.inventory_item_id     := l_inbound_doc_rec.inventory_item_id;
          l_mmtt_rec.subinventory_code     := l_inbound_doc_rec.subinventory_code;
          l_mmtt_rec.locator_id            := l_inbound_doc_rec.locator_id;
          l_mmtt_rec.transfer_subinventory := l_inbound_doc_rec.transfer_subinventory;
          l_mmtt_rec.transfer_to_location  := l_inbound_doc_rec.transfer_to_location;
          l_mmtt_rec.organization_id       := l_inbound_doc_rec.organization_id;
          l_mmtt_rec.wms_task_type         := l_inbound_doc_rec.wms_task_type;
          l_mmtt_rec.primary_quantity      := l_inbound_doc_rec.primary_quantity;

	  IF l_operation_plan_detail_rec.operation_type = g_op_type_crossdock THEN
	     IF (l_debug=1) THEN
		print_debug('Crossdock operation is the only operation in this plan',l_module_name,4);
	     END IF;
	     IF(Nvl(l_operation_plan_rec.crossdock_to_wip_flag, 'N')='N')THEN
		l_operation_plan_detail_rec.subsequent_op_plan_id := Nvl(l_operation_plan_detail_rec.subsequent_op_plan_id, 1);
	      ELSE -- don't need to stamp subsequent_op_plan_id for WIP
		l_operation_plan_detail_rec.subsequent_op_plan_id := l_operation_plan_id;
	     END IF;

	  END IF;

          /*Call document handler for creating child records*/
          IF (l_debug=1) THEN
             print_debug('Calling WMS_OP_INBOUND_PVT.INIT with the parameters',l_module_name,4);
             print_debug('p_source_task_id          ==>'||p_source_task_id,l_module_name,4);
             print_debug('p_operation_type          ==>'||l_operation_plan_detail_rec.operation_type,l_module_name,4);
             print_debug('MMTT.transaction_temp_id  ==>'||p_source_task_id,l_module_name,4);
             print_debug('MMTT.inventory_item_id    ==>'||l_inbound_doc_rec.inventory_item_id,l_module_name,4);
             print_debug('MMTT.subinventory_code    ==>'||l_mmtt_rec.subinventory_code,l_module_name,4);
             print_debug('MMTT.locator_id           ==>'||l_mmtt_rec.locator_id,l_module_name,4);
             print_debug('MMTT.transfer_to_location ==>'||l_mmtt_rec.transfer_to_location,l_module_name,4);
             print_debug('MMTT.transfer_subinventory==>'||l_mmtt_rec.transfer_subinventory,l_module_name,4);
             print_debug('MMTT.organization_id      ==>'||l_mmtt_rec.organization_id,l_module_name,4);
             print_debug('MMTT.wms_task_type        ==>'||l_mmtt_rec.wms_task_type,l_module_name,4);
	     print_debug('p_subsequent_op_plan_id   ==>'||l_operation_plan_detail_rec.subsequent_op_plan_id,l_module_name,4);
          END IF;

	  /*
	  {{
	    Operation plan only has one crossdock operation. Should verify from control board
	    that the parent task has inbound crossdock plan and child has outbound plan.

	    }}
	  */


          WMS_OP_INBOUND_PVT.INIT
             (
                   x_return_status    => x_return_status
              ,        x_msg_count    => x_msg_count
              ,         x_msg_data    => x_msg_data
              ,       x_error_code    => x_error_code
              ,   x_source_task_id    => l_source_task_id
              ,   p_source_task_id    => p_source_task_id
              ,     p_document_rec    => l_mmtt_rec
              , p_operation_type_id   => l_operation_plan_detail_rec.operation_type
              , p_revert_loc_capacity => l_revert_loc_capacity
	      , p_subsequent_op_plan_id => l_operation_plan_detail_rec.subsequent_op_plan_id
              );

          l_progress:=110;

          IF (x_return_status=g_ret_sts_error) THEN
             IF (l_debug=1) THEN
                print_debug('Error returned from doc handlers with err code'||x_error_code,l_module_name,9);
             END IF;
             RAISE FND_API.G_EXC_ERROR;


          ELSIF (x_return_status<>g_ret_sts_success) THEN

           IF (l_debug=1) THEN
              print_debug('unexpected error from doc handler',l_module_name,9);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          END IF;

          IF (l_debug=1) THEN
             print_debug('Child src task Id returned'||l_source_task_id,l_module_name,9);
          END IF;

          l_progress:=110;

          /*   Create WMS_OP_PLAN_INSTANCES PL/SQL record with proper operation_plan_ID,
               activity_type_ID, source_task_ID (P_source_task_ID), and original source/destination
               data from source task record, with 'Pending' status.*/

         IF (l_debug=1) THEN
            print_debug('Creating Plan Instance Record',l_module_name,9);
         END IF;

         IF (l_inbound_doc_rec.transfer_to_location IS NULL) THEN
            l_op_plan_instance_rec.orig_dest_sub_code   := l_inbound_doc_rec.subinventory_code;
            l_op_plan_instance_rec.orig_dest_loc_id     := l_inbound_doc_rec.locator_id;
            /*Add logic in Document handler to get source_sub_code and src_locator_id*/

         ELSE
            l_op_plan_instance_rec.orig_source_sub_code := l_inbound_doc_rec.subinventory_code;
            l_op_plan_instance_rec.orig_source_loc_id   := l_inbound_doc_rec.locator_id;
            l_op_plan_instance_rec.orig_dest_sub_code   := l_inbound_doc_rec.transfer_subinventory;
            l_op_plan_instance_rec.orig_dest_loc_id     := l_inbound_doc_rec.transfer_to_location;

         END IF;

       END IF;/*Activity Inbound*/

       SELECT  WMS_OP_INSTANCE_S.NEXTVAL
          INTO l_op_plan_instance_rec.op_plan_instance_id
       FROM dual;

       l_op_plan_instance_rec.operation_plan_id         := l_operation_plan_id;
       l_op_plan_instance_rec.activity_type_id          := p_activity_id;
       l_op_plan_instance_rec.plan_type_id              := l_operation_plan_rec.plan_type_id;
       l_op_plan_instance_rec.source_task_id            := p_source_task_id;
       l_op_plan_instance_rec.status                    := G_OP_INS_STAT_PENDING;
       l_op_plan_instance_rec.organization_id           := l_inbound_doc_rec.organization_id;
       l_op_plan_instance_rec.plan_execution_start_date := SYSDATE;

       l_progress:=120;

       IF (l_debug=1) THEN
          print_debug('Call table handler to insert Plan instance',l_module_name,4);
          print_debug('op_plan_instance_id       ==>'||l_op_plan_instance_rec.op_plan_instance_id,l_module_name,4);
          print_debug('operation_plan_id         ==>'||l_op_plan_instance_rec.operation_plan_id,l_module_name,4);
          print_debug('Activity_type_id          ==>'||l_op_plan_instance_rec.activity_type_id,l_module_name,4);
          print_debug('Plan_type_id              ==>'||l_op_plan_instance_rec.Plan_type_id,l_module_name,4);
          print_debug('source_task_id            ==>'||l_op_plan_instance_rec.source_task_id,l_module_name,4);
          print_debug('Status                    ==>'||l_op_plan_instance_rec.status,l_module_name,4);
          print_debug('Organization Id           ==>'||l_op_plan_instance_rec.organization_id,l_module_name,4);
          print_debug('Plan Execution Start_date ==>'||l_op_plan_instance_rec.plan_execution_start_date,l_module_name,4);
          print_debug('Orig_source_sub_code      ==>'||l_op_plan_instance_rec.orig_source_sub_code,l_module_name,4);
          print_debug('Orig_source_loc_id        ==>'||l_op_plan_instance_rec.orig_source_loc_id,l_module_name,4);
          print_debug('Orig_dest_sub_code        ==>'||l_op_plan_instance_rec.orig_dest_sub_code,l_module_name,4);
          print_debug('Orig_dest_loc_id          ==>'||l_op_plan_instance_rec.orig_dest_loc_id,l_module_name,4);
       END IF;

       /*Call WMS_OP_PLAN_INSTANCES table handler, WMS_OP_RUNTIME_PVT_APIS.INSERT_OPERATION_PLAN_INSTANCE,
        to insert record into the WMS_OP_PLAN_INSTANCES table.*/

       WMS_OP_RUNTIME_PVT_APIS.INSERT_PLAN_INSTANCE(
           x_return_status => x_return_status        ,
           x_msg_count     => x_msg_count            ,
           x_msg_data      => x_msg_data             ,
           p_insert_rec    => l_op_plan_instance_rec );

       l_progress:=130;

       IF (l_debug=1) THEN
          print_debug('Return Status from table handler',l_module_name,9);
       END IF;

       IF (x_return_status=g_ret_sts_error) THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF (x_return_status<>g_ret_sts_success) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       /*Create WMS_OP_OPERATION_INSTANCES (WOOI) PL/SQL record for the first operation.,
         with proper operation_type_ID, source_task_ID (ID which is returned by the document hanlder),
         etc. Status field as 'Pending'*/

        l_operation_instance_rec.operation_plan_detail_id := l_operation_plan_detail_rec.operation_plan_detail_id;
        l_operation_instance_rec.op_plan_instance_id      := l_op_plan_instance_rec.op_plan_instance_id ;
        l_operation_instance_rec.organization_id          := l_op_plan_instance_rec.organization_id;
        l_operation_instance_rec.operation_status         := G_OP_INS_STAT_PENDING;
        l_operation_instance_rec.operation_sequence       := l_operation_plan_detail_rec.operation_sequence;
        l_operation_instance_rec.is_in_inventory          := Nvl(l_operation_plan_detail_rec.is_in_inventory, 'N');
        l_operation_instance_rec.from_subinventory_code   := l_op_plan_instance_rec.orig_source_sub_code;
        l_operation_instance_rec.from_locator_id          := l_op_plan_instance_rec.orig_source_loc_id;
        l_operation_instance_rec.source_task_id           := l_source_task_id;
	     l_operation_instance_rec.activity_type_id         := p_activity_id;

        IF (l_operation_plan_detail_rec.operation_type=G_OP_TYPE_CROSSDOCK) THEN
            l_operation_instance_rec.operation_type_id := G_OP_TYPE_LOAD;
        ELSE
            l_operation_instance_rec.operation_type_id    := l_operation_plan_detail_rec.operation_type;
        END IF;

        l_progress:=140;

        IF (l_debug=1) THEN
          print_debug('Call table handler to insert operation instance',l_module_name,4);
          print_debug('operation_plan_detail_id ==>'||l_operation_instance_rec.operation_plan_detail_id,l_module_name,4);
          print_debug('op_plan_instance_id      ==>'||l_operation_instance_rec.op_plan_instance_id,l_module_name,4);
          print_debug('organization_id          ==>'||l_operation_instance_rec.organization_id,l_module_name,4);
          print_debug('operation_status         ==>'||l_operation_instance_rec.operation_status,l_module_name,4);
          print_debug('operation_sequence       ==>'||l_operation_instance_rec.operation_sequence,l_module_name,4);
          print_debug('is_in_inventory          ==>'||l_operation_instance_rec.is_in_inventory,l_module_name,4);
          print_debug('from_subinventory_code   ==>'||l_operation_instance_rec.from_subinventory_code,l_module_name,4);
          print_debug('from_locator_id          ==>'||l_operation_instance_rec.from_locator_id,l_module_name,4);
          print_debug('operation_type_id        ==>'||l_operation_instance_rec.operation_type_id,l_module_name,4);
          print_debug('Source Task Id           ==>'||l_operation_instance_rec.source_task_id,l_module_name,4);
        END IF;

       /*Call WMS_OP_OPERATION_INSTANCES table handler,  WMS_OP_RUNTIME_PVT_APIS.INSERT_OPERATION_INSTANCE,
         to insert record into the WMS_OP_OPERATION_INSTANCES table.*/

        WMS_OP_RUNTIME_PVT_APIS.insert_operation_instance
           ( x_return_status => x_return_status,
             x_msg_count     => x_msg_count,
             x_msg_data      => x_msg_data,
             p_insert_rec    => l_operation_instance_rec
           );

        l_progress:=150;

        IF (l_debug=1) THEN
          print_debug('Return Status from table handler',l_module_name,9);
        END IF;

        IF (x_return_status=g_ret_sts_error) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status<>g_ret_sts_success) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;



  EXCEPTION

       WHEN FND_API.G_EXC_ERROR THEN
          IF (l_debug=1) THEN
             print_debug('Expected Error Obtained at'||l_progress,l_module_name,1);
          END IF;
          IF (inbound_document_details%ISOPEN) THEN
             CLOSE inbound_document_details;
          END IF;

          IF (c_operation_plan%ISOPEN) THEN
             CLOSE c_operation_plan;
          END IF;

          IF (c_plan_detail%ISOPEN) THEN
             CLOSE c_plan_detail;
          END IF;

          IF (c_plan_instance_exists%ISOPEN) THEN
             CLOSE c_plan_instance_exists;
          END IF;

          IF (c_operation_instance_exists%ISOPEN) THEN
             CLOSE c_operation_instance_exists;
          END IF;

          ROLLBACK TO init_plan_sp;

          x_return_status:=g_ret_sts_error;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          IF (l_debug=1) THEN
             print_debug('UnExpected Error Obtained at'||l_progress||SQLERRM,l_module_name,1);
          END IF;
          IF (inbound_document_details%ISOPEN) THEN
             CLOSE inbound_document_details;
          END IF;

          IF (c_operation_plan%ISOPEN) THEN
             CLOSE c_operation_plan;
          END IF;

          IF (c_plan_detail%ISOPEN) THEN
             CLOSE c_plan_detail;
          END IF;

          IF (c_plan_instance_exists%ISOPEN) THEN
             CLOSE c_plan_instance_exists;
          END IF;

          IF (c_operation_instance_exists%ISOPEN) THEN
             CLOSE c_operation_instance_exists;
          END IF;

          ROLLBACK TO init_plan_sp;

          x_return_status:=g_ret_sts_unexp_error;

       WHEN OTHERS THEN

          print_debug(l_progress||' '||SQLERRM, l_module_name,1);

          IF fnd_msg_pub.check_msg_level(g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name, SQLERRM);
          END IF; /* fnd_msg.... */

          fnd_msg_pub.count_and_get(
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );

          IF (SQLCODE<-20000) THEN
            IF (l_debug=1) THEN
              print_debug('This is a user defined exception',l_module_name,1);
            END IF;

            x_error_code:=-(SQLCODE+20000);

            x_return_status:=g_ret_sts_error;


          ELSE

            x_return_status := g_ret_sts_unexp_error;

          END IF;

          IF (inbound_document_details%ISOPEN) THEN
             CLOSE inbound_document_details;
          END IF;

          IF (c_operation_plan%ISOPEN) THEN
             CLOSE c_operation_plan;
          END IF;

          IF (c_plan_detail%ISOPEN) THEN
             CLOSE c_plan_detail;
          END IF;

          IF (c_plan_instance_exists%ISOPEN) THEN
             CLOSE c_plan_instance_exists;
          END IF;

          IF (c_operation_instance_exists%ISOPEN) THEN
             CLOSE c_operation_instance_exists;
          END IF;

          ROLLBACK TO init_plan_sp;

  END init_op_plan_instance;


 /**
  *   Determine_Attributes
  *   <p>This private procedure returns the LPN, Locator, Subinventory
  *   attributes for a given operation and activity. Today we do this
  *   only for a Drop operation </p>
  *  @param x_return_status    Return Status
  *  @param x_msg_data         Returns the Message Data
  *  @param x_msg_count        Returns the Error Message
  *  @param x_error_code       Returns appropriate error code in case
  *                            of an error.
  *  @param x_attributes       Returns a record with the fetched attributes
  *  @param p_source_task_id   Identifier of the source document record
  *  @param p_activity_type_id Lookup code of the Activity type Id
  **/
   PROCEDURE  Determine_Attributes(
              x_return_status    OUT  NOCOPY  VARCHAR2,
              x_msg_data         OUT  NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE,
              x_msg_count        OUT  NOCOPY  NUMBER,
	      x_error_code       OUT  NOCOPY  NUMBER,
	      x_consolidation_method_id   OUT NOCOPY  NUMBER,
              x_drop_lpn_option  OUT  NOCOPY  NUMBER,	-- xdock
              x_plan_attributes  OUT  NOCOPY  WMS_OP_INBOUND_PVT.DEST_PARAM_REC_TYPE,
              p_source_task_id   IN           NUMBER,
	      p_activity_type_id IN           NUMBER,
	      p_inventory_item_id IN          NUMBER
                               ) IS

      l_debug       NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),0);
      l_module_name VARCHAR2(30) := 'Determine_Attributes';
      l_progress    VARCHAR2(30) := '0';

      l_attributes              WMS_OP_INBOUND_PVT.DEST_PARAM_REC_TYPE;

      l_sub_determination_method  NUMBER;
      l_loc_determination_method  NUMBER;
      l_lpn_determination_method  NUMBER;
      l_zone_determination_method NUMBER;


      l_return_status  VARCHAR2(1);
      l_msg_data       VARCHAR2(2000);
      l_msg_count      NUMBER;
      l_zone_id        NUMBER;
      l_valid_flag     VARCHAR2(1); -- dummy variable
      l_validate_loc   BOOLEAN := FALSE;
      l_mol_count      NUMBER; -- xdock
      l_consolidation_method_id NUMBER; -- xdock
      l_xd_loc_selection_criteria NUMBER; -- xdock
      l_xd_loc_selection_api_id NUMBER; -- xdock
      l_xd_drop_lpn_option NUMBER; -- xdock
      l_operation_plan_name VARCHAR2(80);

      CURSOR c_parent_locator IS
	 SELECT Nvl(mmtt.transfer_subinventory, mmtt.subinventory_code) subinventory_code,
	   Nvl(mmtt.transfer_to_location, mmtt.locator_id)        locator_id
	   FROM   mtl_material_transactions_temp mmtt
	   WHERE  mmtt.transaction_temp_id =
	   (SELECT child_mmtt.parent_line_id
	    FROM mtl_material_transactions_temp child_mmtt
	    WHERE child_mmtt.transaction_temp_id = p_source_task_id);

      CURSOR c_plan_details IS
      SELECT wopd.zone_selection_criteria  zone_selection_criteria,
             wopd.pre_specified_zone_id    pre_specified_zone_id,
             wopd.zone_selection_api_id    zone_selection_api_id,
             wopd.sub_selection_criteria   sub_selection_criteria,
             wopd.pre_specified_sub_code   pre_specified_sub_code,
             wopd.sub_selection_api_id     sub_selection_api_id,
             wopd.loc_selection_criteria   loc_selection_criteria,
             wopd.pre_specified_loc_id     pre_specified_loc_id,
             wopd.loc_selection_api_id     loc_selection_api_id,
             wopd.lpn_selection_criteria   lpn_selection_criteria,
	     wopd.lpn_selection_api_id     lpn_selection_api_id,
	     wopd.operation_type           operation_type,
             nvl(wopd.is_in_inventory,'N') is_in_inventory
	FROM   wms_op_operation_instances wooi,
             wms_op_plan_details wopd
      WHERE  wooi.activity_type_id = p_activity_type_id
	AND    wooi.source_task_id   = p_source_task_id
	AND    wooi.operation_status IN (g_op_ins_stat_pending,g_op_ins_stat_active)
	AND    wooi.operation_plan_detail_id = wopd.operation_plan_detail_id;

      l_plan_details c_plan_details%ROWTYPE;

      CURSOR c_mmtt_data IS
	 SELECT mol.project_id, mol.task_id,mmtt.organization_id, mmtt.operation_plan_id, mmtt.lpn_id,
	   Nvl(wopb.crossdock_to_wip_flag, 'N') crossdock_to_wip_flag
	   FROM mtl_material_transactions_temp mmtt,
	   mtl_txn_request_lines mol,
	   wms_op_plans_b wopb
	   WHERE mmtt.move_order_line_id = mol.line_id
	   AND mmtt.operation_plan_id = wopb.operation_plan_id
	   AND mmtt.transaction_temp_id = p_source_task_id;

      l_mmtt_data_rec c_mmtt_data%ROWTYPE;

      CURSOR c_item_attributes(v_org_id NUMBER) IS
         SELECT nvl(msi.RESTRICT_SUBINVENTORIES_CODE,2) restrict_subinventories_code
               ,nvl(msi.RESTRICT_LOCATORS_CODE,2) restrict_locators_code
          FROM  mtl_system_items msi
          WHERE msi.inventory_item_id = p_inventory_item_id
          AND   msi.organization_id   = v_org_id;

      l_item_attributes c_item_attributes%ROWTYPE;

      CURSOR c_item_sub(v_org_id NUMBER, v_subinventory VARCHAR2) IS
         SELECT 1
         FROM mtl_item_sub_inventories
         WHERE inventory_item_id   = p_inventory_item_id
         AND   organization_id     = v_org_id
         AND   secondary_inventory = v_subinventory;

      l_item_sub c_item_sub%ROWTYPE;

      CURSOR c_item_locator(v_org_id NUMBER,v_locator_id NUMBER) IS
         SELECT 1
         FROM mtl_secondary_locators
         WHERE inventory_item_id = p_inventory_item_id
         AND   secondary_locator = v_locator_id
         AND   organization_id   = v_org_id;

      l_item_locator c_item_locator%ROWTYPE;


   BEGIN

      IF (l_debug = 1) THEN
	 print_debug('Enter: ' , l_module_name, 1);
	 print_debug(' p_source_task_id => ' ||p_source_task_id, l_module_name, 1);
	 print_debug(' p_activity_type_id => ' ||p_activity_type_id , l_module_name, 1);
	 print_debug(' p_inventory_item_id => ' ||p_inventory_item_id, l_module_name, 1);

      END IF;

      x_return_status  := g_ret_sts_success;

      l_progress := '10';

      OPEN  c_plan_details;
      FETCH c_plan_details INTO l_plan_details;
      CLOSE c_plan_details;

      l_progress := '20';

      OPEN c_mmtt_data;
      FETCH c_mmtt_data INTO l_mmtt_data_rec;
      CLOSE c_mmtt_data;

      l_progress := '30';

      IF (l_debug = 1) THEN
	 print_debug('l_plan_details.zone_selection_criteria  => ' ||l_plan_details.zone_selection_criteria, l_module_name, 1);
	 print_debug('l_plan_details.pre_specified_zone_id  => ' ||l_plan_details.pre_specified_zone_id, l_module_name, 1);
	 print_debug('l_plan_details.zone_selection_api_id  => ' ||l_plan_details.zone_selection_api_id, l_module_name, 1);
	 print_debug('l_plan_details.sub_selection_criteria  => ' ||l_plan_details.sub_selection_criteria, l_module_name, 1);
	 print_debug('l_plan_details.pre_specified_sub_code  => ' ||l_plan_details.pre_specified_sub_code, l_module_name, 1);
	 print_debug('l_plan_details.sub_selection_api_id  => ' ||l_plan_details.sub_selection_api_id, l_module_name, 1);
	 print_debug('l_plan_details.loc_selection_criteria  => ' ||l_plan_details.loc_selection_criteria, l_module_name, 1);
	 print_debug('l_plan_details.pre_specified_loc_id  => ' ||l_plan_details.pre_specified_loc_id, l_module_name, 1);
	 print_debug('l_plan_details.loc_selection_api_id  => ' ||l_plan_details.loc_selection_api_id, l_module_name, 1);
	 print_debug('l_plan_details.lpn_selection_criteria  => ' ||l_plan_details.lpn_selection_criteria, l_module_name, 1);
	 print_debug('l_plan_details.lpn_selection_api_id  => ' ||l_plan_details.lpn_selection_api_id, l_module_name, 1);
	 print_debug('l_plan_details.operation_type  => ' ||l_plan_details.operation_type, l_module_name, 1);
	 print_debug('l_mmtt_data_rec.project_id => ' || l_mmtt_data_rec.project_id , l_module_name, 1);
 	 print_debug('l_mmtt_data_rec.task_id => ' || l_mmtt_data_rec.task_id , l_module_name, 1);
	 print_debug('l_mmtt_data_rec.operation_plan_id => ' || l_mmtt_data_rec.operation_plan_id , l_module_name, 1);
	 print_debug('l_mmtt_data_rec.lpn_id => ' || l_mmtt_data_rec.lpn_id , l_module_name, 1);
	 print_debug('l_mmtt_data_rec.crossdock_to_wip_flag => ' || l_mmtt_data_rec.crossdock_to_wip_flag , l_module_name, 1);

     END IF;

      IF NVL(l_plan_details.sub_selection_criteria,0) =
               wms_globals.G_OP_DEST_PRE_SPECIFIED
      THEN

         l_attributes.sug_sub_code := l_plan_details.pre_specified_sub_code;

      ELSE

         l_attributes.sug_sub_code := NULL;

      END IF; /* l_plan_details.sub_sug...*/

     /**
       * IF the selection criteria is Pre-Specified then fetch locator id
       * from Plan
       *
       * If the selection criteria is System suggested or from Custom we
       * call the wrapper to fetch the Locator Id
       *
       * If Rules suggested then this has to be the last operation and
       * we get the values from Parent MMTT record
       */

      IF NVL(l_plan_details.loc_selection_criteria,0) =
               wms_globals.G_OP_DEST_PRE_SPECIFIED
      THEN
	 l_attributes.sug_location_id := l_plan_details.pre_specified_loc_id;

    l_validate_loc  := TRUE;

      ELSIF NVL(l_plan_details.loc_selection_criteria,0) =
               wms_globals.G_OP_DEST_API OR
            NVL(l_plan_details.loc_selection_criteria,0) =
               wms_globals.G_OP_DEST_CUSTOM_API
      THEN

         /*
          * The API should be validating its inputs so not validating
          * for selection_api_id here
          */

	    IF (l_debug = 1) THEN
	       print_debug('Before calling wms_atf_dest_locator.get_dest_locator with following parameters: ' , l_module_name, 1);
	       print_debug('p_mode => ' || 1, l_module_name, 1);
	       print_debug('p_task_id => ' || p_source_task_id, l_module_name, 1);
	       print_debug('p_activity_type_id => ' || p_activity_type_id, l_module_name, 1);
	       print_debug('p_hook_call_id => ' || l_plan_details.loc_selection_api_id, l_module_name, 1);
	       print_debug('p_locator_id => ' || NULL, l_module_name, 1);
	       print_debug('p_item_id => ' || p_inventory_item_id, l_module_name, 1);
	    END IF;

	    l_progress := '40';

	    wms_atf_dest_locator.get_dest_locator
	    (
	      x_return_status         => l_return_status
	      ,  x_msg_count          => l_msg_count
	      ,  x_msg_data           => l_msg_data
	      ,  x_locator_id         => l_attributes.sug_location_id
	      ,  x_subinventory_code  => l_attributes.sug_sub_code
	      ,  x_zone_id            => l_zone_id
	      ,  x_loc_valid          => l_valid_flag
	      ,  p_mode               => 1
	      ,  p_task_id            => p_source_task_id
	      ,  p_activity_type_id   => p_activity_type_id
	      ,  p_hook_call_id       => l_plan_details.loc_selection_api_id
	      ,  p_locator_id         => NULL
	      ,  p_item_id            => p_inventory_item_id
	      ,  p_api_version        => NULL
	      ,  p_init_msg_list      => NULL
	      ,  p_commit             => NULL
	      );

	    l_progress := '50';

	    IF (l_debug = 1) THEN
	       print_debug('After calling wms_atf_dest_locator.get_dest_locator.' , l_module_name, 1);
	       print_debug('x_return_status => ' || l_return_status, l_module_name, 1);
	       print_debug('x_msg_count => ' || l_msg_count, l_module_name, 1);
	       print_debug('x_msg_data => ' || l_msg_data, l_module_name, 1);
	       print_debug('x_locator_id => ' || l_attributes.sug_location_id, l_module_name, 1);
	       print_debug('x_subinventory_code => ' || l_attributes.sug_sub_code, l_module_name, 1);
	       print_debug('x_zone_id => ' || l_zone_id, l_module_name, 1);
	       print_debug('x_loc_valid => ' || l_valid_flag, l_module_name, 1);
	    END IF;

	    IF l_return_status <> g_ret_sts_success THEN
	       IF (l_debug = 1) THEN
		  print_debug('wms_atf_dest_locator.get_dest_locator failed:  l_return_status = '|| l_return_status, l_module_name, 1);
	       END IF;
	       --	       fnd_message.set_name('WMS', 'WMS_ATF_LOC_DETERM_FAILED');
	       --	       fnd_msg_pub.ADD;

	       SELECT wopv.operation_plan_name
		 INTO l_operation_plan_name
		 FROM wms_op_plans_vl wopv,
		 mtl_material_transactions_temp mmtt
		 WHERE mmtt.transaction_temp_id = p_source_task_id
		 AND mmtt.operation_plan_id = wopv.operation_plan_id;

	       fnd_message.set_name('WMS', 'DERIVE_DEST_SUGGESTIONS_FAILED');
	       fnd_message.set_token('OPERATION_PLAN_NAME', l_operation_plan_name);
	       fnd_msg_pub.ADD;

	       RAISE FND_API.G_EXC_ERROR;

	    END IF;

	    IF l_attributes.sug_location_id IS NULL THEN

	       IF (l_debug = 1) THEN
		  print_debug('wms_atf_dest_locator.get_dest_locator returns NULL locator. ', l_module_name, 1);
	       END IF;
	       --	       fnd_message.set_name('WMS', 'WMS_ATF_LOC_DETERM_FAILED');
	       --	       fnd_msg_pub.ADD;

	       SELECT wopv.operation_plan_name
		 INTO l_operation_plan_name
		 FROM wms_op_plans_vl wopv,
		 mtl_material_transactions_temp mmtt
		 WHERE mmtt.transaction_temp_id = p_source_task_id
		 AND mmtt.operation_plan_id = wopv.operation_plan_id;

	       fnd_message.set_name('WMS', 'DERIVE_DEST_SUGGESTIONS_FAILED');
	       fnd_message.set_token('OPERATION_PLAN_NAME', l_operation_plan_name);
	       fnd_msg_pub.ADD;

	       RAISE FND_API.G_EXC_ERROR;

	    END IF;

       l_validate_loc := TRUE;

       /*
       {{
	 For corssdock operation, to determine drop off locator, should honor
	 subsequent outbound operation plan.
	 }}
       */
        ELSIF l_plan_details.operation_type = g_op_type_crossdock AND
              l_mmtt_data_rec.crossdock_to_wip_flag = 'N'
        THEN

	 BEGIN
	    SELECT  loc_selection_criteria
	      ,     loc_selection_api_id
	      ,     consolidation_method_id
	      ,     Nvl(drop_lpn_option,2)
	      INTO  l_xd_loc_selection_criteria
	      ,     l_xd_loc_selection_api_id
	      ,     l_consolidation_method_id
	      ,     l_xd_drop_lpn_option
	      FROM  wms_op_plan_details
	      WHERE operation_plan_id = l_mmtt_data_rec.operation_plan_id
	      AND   operation_type = 2;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('Error retrievine info from outbound plan',l_module_name,1);
	       END IF;
	       RAISE FND_API.G_EXC_ERROR;
	 END ;

	 IF (l_debug = 1) THEN
	    print_debug('l_consolidation_method_id =>'||l_consolidation_method_id,l_module_name,4);
	    print_debug('l_xd_loc_selection_criteria =>'||l_xd_loc_selection_criteria,l_module_name,4);
	    print_debug('l_xd_loc_selection_api_id =>'||l_xd_loc_selection_api_id,l_module_name,4);
	    print_debug('l_xd_drop_lpn_option =>'||l_xd_drop_lpn_option,l_module_name,4);
	 END IF;

	 IF (l_xd_loc_selection_criteria = wms_globals.g_op_dest_sys_suggested) THEN --4
	    IF (l_debug = 1) THEN
	       print_debug('Outbound plan should not have this value.',l_module_name,4);
	    END IF;
	    RAISE fnd_api.g_exc_error;
	  ELSIF (l_xd_loc_selection_criteria = wms_globals.g_op_dest_api) THEN --2
	    IF (l_xd_loc_selection_api_id = 1) THEN--Consolidation Lane

	       --If it is consolidation based in consolidation loc, always treat
	       --it as within delivery
	       x_consolidation_method_id := 2;

	       -- {{
	       --   Subsequent outbound plan indicates drop to consolidation locator
	       --   should suggest consolidation locator based on delivery consolidation
	       -- }}
	       IF (l_debug = 1) THEN
		  print_debug('Calling WMS_OP_DEST_SYS_APIS.Get_CONS_Loc_For_Delivery.', l_module_name, 4);
		  print_debug('p_call_mode = '||3, l_module_name, 4);
		  print_debug('p_task_type = '||g_wms_task_type_pick, l_module_name, 4);
		  print_debug('p_task_id = '||p_source_task_id, l_module_name, 4);
	       END IF;

	       l_progress := '50.10';

	       wms_op_dest_sys_apis.Get_CONS_Loc_For_Delivery
		 (x_return_status => l_return_status,
		  x_message => l_msg_data,
		  x_locator_id => l_attributes.sug_location_id,
		  x_zone_id => l_zone_id,
		  x_subinventory_code => l_attributes.sug_sub_code,
		  p_call_mode => 3,  -- xdock locator selection
		  p_task_type => g_wms_task_type_pick,  -- picking
		  p_task_id => p_source_task_id,
		  p_locator_id => NULL);

	       IF (l_debug = 1) THEN
		  print_debug('After calling wms_op_dest_sys_apis.Get_CONS_Loc_For_Delivery.', l_module_name, 4);
		  print_debug('x_return_status = '||l_return_status, l_module_name, 4);
		  print_debug('x_message = '||l_msg_data, l_module_name, 4);
		  print_debug('x_locator_id = '||l_attributes.sug_location_id, l_module_name, 4);
		  print_debug('x_subinventory_code = '||l_attributes.sug_sub_code, l_module_name, 4);
		  print_debug('x_zone_id = '||l_zone_id, l_module_name, 4);
	       END IF;

	       --{{
	       -- Warning messages, such as 'Consolidation locators full' should be passed back to the UI
	       -- Should prompt the user with this message and option to proceed or not.
	       -- 1. If user chooses yes, should proceed with the *warned* locator, e.g. the locator contains
	       --    other delivery
	       -- 2. If user choose no, should go back to menu and cleanup (rollback) the suggested loc/sub on MMTT
	       --}}
	       IF l_return_status <> g_ret_sts_success THEN
		  IF l_return_status = 'W' THEN
		     x_return_status := l_return_status;
		     x_msg_data := l_msg_data;
		   ELSE
		     RAISE fnd_api.g_exc_error;
		  END IF;

	       END IF;
	     ELSE --l_task_drop_loc_rec.loc_selection_api_id = 1 (Staging Lane)
	       -- {{
	       --   Subsequent outbound plan indicates drop to staging lane
	       --   should suggest staging locator based on delivery consolidation
	       -- }}


	       l_progress := '50.20';

	       --{{
	       -- If there are multiple move order lines in this LPN, don't care about MDC
	       -- always do consolidation within delivery
	       -- And need to pass the approriate x_consolidation_method_id flag back to caller
	       --}}

	       SELECT COUNT(line_id)
		 INTO l_mol_count
		 FROM mtl_txn_request_lines
		 WHERE lpn_id = l_mmtt_data_rec.lpn_id;

	       IF (l_debug = 1) THEN
		  print_debug('l_mol_count = '||l_mol_count, l_module_name , 4);
		  print_debug('l_consolidation_method_id = '||l_consolidation_method_id, l_module_name , 4);
	       END IF;

	       IF (l_mol_count = 1
		   AND l_consolidation_method_id = 1
		   AND l_xd_drop_lpn_option = 2) THEN

		  --Call MDC API
		  x_consolidation_method_id := 1; -- across delivery

		  --{{
		  -- When MDC is enabled and when there is only one move order line in this LPN
		  -- suggested sub/loc/LPN will be determined by MDC API
		  --}}
		  IF (l_debug = 1) THEN
		     print_debug('Before calling wms_mdc_pvt.suggest_to_lpn with following parameters:', l_module_name, 4);
		     print_debug('p_transfer_lpn_id : '||l_mmtt_data_rec.lpn_id , l_module_name, 4);
		  END IF;

		  wms_mdc_pvt.suggest_to_lpn
		    (p_lpn_id => l_mmtt_data_rec.lpn_id,
		     p_delivery_id => NULL,
		     x_to_lpn_id =>l_attributes.cartonization_id,
		     x_to_subinventory_code=>l_attributes.sug_sub_code,
		     x_to_locator_id =>l_attributes.sug_location_id,
		     x_return_status =>l_return_status,
		     x_msg_count =>l_msg_count,
		     x_msg_data =>l_msg_data);

		  IF (l_debug = 1) THEN
		     print_debug('After calling wms_mdc_pvt.suggest_to_lpn:', l_module_name, 4);
		     print_debug('x_return_status : '|| x_return_status, l_module_name, 4);
		     print_debug('x_to_lpn_id : '|| l_attributes.cartonization_id, l_module_name, 4);
		     print_debug('x_to_subinventory_code : '||l_attributes.sug_sub_code , l_module_name, 4);
		     print_debug('x_to_locator_id : '||l_attributes.sug_location_id , l_module_name, 4);
		  END IF;

		  IF l_return_status <> g_ret_sts_success THEN
		     IF (l_debug = 1) THEN
			print_debug('Failed calling wms_mdc_pvt.suggest_to_lpn.',l_module_name, 4);
		     END IF;

		     RAISE fnd_api.g_exc_error;
		  END IF;
	       END IF; --END IF (l_mol_count = 1)

	       IF (l_consolidation_method_id = 2 OR
		   l_xd_drop_lpn_option = 1 OR
		   l_attributes.cartonization_id IS NULL) THEN

		  IF (l_debug = 1) THEN
		     print_debug('Calling WMS_OP_DEST_SYS_APIS.Get_Staging_Loc_For_Delivery.', l_module_name, 4);
		     print_debug('p_call_mode = '||3, l_module_name, 4);
		     print_debug('p_task_type = '||g_wms_task_type_pick, l_module_name, 4);
		     print_debug('p_task_id = '||p_source_task_id, l_module_name, 4);
		  END IF;

		  x_consolidation_method_id := 2; -- within delivery

		  wms_op_dest_sys_apis.Get_Staging_Loc_For_Delivery
		    (x_return_status => l_return_status,
		     x_message => l_msg_data,
		     x_locator_id => l_attributes.sug_location_id,
		     x_zone_id => l_zone_id,
		     x_subinventory_code => l_attributes.sug_sub_code,
		     p_call_mode => 3,  -- locator selection
		     p_task_type => g_wms_task_type_pick,  -- picking
		     p_task_id => p_source_task_id,
		     p_locator_id => NULL);

		  IF (l_debug = 1) THEN
		     print_debug('After calling wms_op_dest_sys_apis.Get_Staging_Loc_For_Delivery.', l_module_name, 4);
		     print_debug('x_return_status = '||l_return_status, l_module_name, 4);
		     print_debug('x_message = '||l_msg_data, l_module_name, 4);
		     print_debug('x_locator_id = '||l_attributes.sug_location_id, l_module_name, 4);
		     print_debug('x_subinventory_code = '||l_attributes.sug_sub_code, l_module_name, 4);
		     print_debug('x_zone_id = '||l_zone_id, l_module_name, 4);
		  END IF;

		  --{{
		  -- Warning messages from get staging loc API should be passed back to the UI
		  -- Should prompt the user with this message and option to proceed or not.
		  -- 1. If user chooses yes, should proceed with the *warned* locator, e.g. the locator contains
		  --    other delivery
		  -- 2. If user choose no, should go back to menu and cleanup (rollback) the suggested loc/sub on MMTT
		  --}}
		  IF l_return_status <> g_ret_sts_success THEN
		     IF l_return_status = 'W' THEN
			x_return_status := l_return_status;
			x_msg_data := l_msg_data;
		      ELSE
			RAISE fnd_api.g_exc_error;
		     END IF;

		  END IF;
	       END IF; --END IF (l_consolidation_method_id = 2 OR
	    END IF;--END IF (l_plan_details.loc_selection_api_id = 1) THEN
	 END IF;--END IF (l_plan_details.loc_selection_criteria = wms_globals.g_op_dest_sys_suggested) THEN

	 IF l_attributes.sug_location_id IS NULL OR
	   l_attributes.sug_sub_code IS NULL THEN
	    IF (l_debug = 1) THEN
	       print_debug('MDC or staging suggestion api does not return anthing ',l_module_name, 4);
	    END IF;

            OPEN  c_parent_locator;
            FETCH c_parent_locator INTO l_attributes.sug_sub_code,
                                        l_attributes.sug_location_id;
            CLOSE c_parent_locator;


	 END IF;--END IF l_attributes.sug_location_id IS NULL OR

       ELSIF NVL(l_plan_details.loc_selection_criteria,0) =
	 wms_globals.G_OP_DEST_SYS_SUGGESTED
	 THEN

         IF p_activity_type_id = wms_globals.g_op_activity_inbound THEN

	    l_progress := '60';

            OPEN  c_parent_locator;
            FETCH c_parent_locator INTO l_attributes.sug_sub_code,
                                        l_attributes.sug_location_id;
            CLOSE c_parent_locator;

            l_validate_loc := FALSE;

	    l_progress := '70';

         ELSE

         /**
           * We should never come here, so raise Data Inconsistency Exception
           */
	     IF (l_debug = 1) THEN
		print_debug('Invalid activity '||p_activity_type_id,
			    l_module_name, 1);
	     END IF;


         END IF; /* p_activity_type_id ..*/

      ELSE

         /**
           * We should never come here, so raise Data Inconsistency Exception
           */
      	     IF (l_debug = 1) THEN
		print_debug('Invalid Selection critiera value '||
			    l_plan_details.loc_selection_criteria, l_module_name, 1);
	     END IF;

           RAISE FND_API.G_EXC_ERROR;

      END IF; /* l_plan_details.sug_loca.... */

      IF l_validate_loc THEN
         /*  WE need to validate whether suggestions made
          * confirm to the ItemSub ItemLocator relations
          */
        /* Making this check for Inventory as in Patchset J we cannot define Item Sub Item Locator
         * relationships for REceving Subs and Locators. This might change in future release so
         * we would need to just comment this line
         */
        IF l_plan_details.is_in_inventory = 'Y' THEN

           print_debug('Validating the Item Sub,Item Locator relationships',l_module_name,1);
           print_debug('Fetch the item Attributes',l_module_name,1);

           OPEN c_item_attributes(l_mmtt_data_rec.organization_id);

           FETCH c_item_attributes INTO l_item_attributes;

           CLOSE c_item_attributes;

           IF l_debug =1 THEN
            print_debug('Item Attributes fetched are as follows',l_module_name,9);
            print_debug('Restrict SubInventory Code'||l_item_attributes.restrict_subinventories_code,l_module_name,9);
            print_debug('Restrict Locator Code'||l_item_attributes.restrict_locators_code,l_module_name,9);
           END IF;

           IF (l_item_attributes.restrict_subinventories_code =1) THEN

              /*The Item needs to be validated for  Item Sub restrictions*/
              IF l_debug =1 THEN
                 print_debug('Need to validate item Sub Restriction',l_module_name,9);
              END IF;

              OPEN c_item_sub(l_mmtt_data_rec.organization_id,l_attributes.sug_sub_code);

              FETCH c_item_sub INTO l_item_sub;

              IF c_item_sub%NOTFOUND THEN

                 /*Suggested locators does not satisfy Item Sub relationship.Raise exception*/

                 IF l_debug = 1 THEN
                    print_debug('Suggested Sub does not satisfy Item Sub relationship',l_module_name,9);
                 END IF;

                 fnd_message.set_name('WMS','WMS_ATF_ITEM_SUBLOC_FAIL');
                 fnd_msg_pub.ADD;

                 CLOSE c_item_sub;

                 RAISE fnd_api.g_exc_error;

              END IF;

              CLOSE c_item_sub;


           END IF;

           IF (l_item_attributes.restrict_locators_code = 1)  THEN

              IF l_debug = 1 THEN
                 print_debug('Suggested Locator needs to validated agaisnt item-loc relationships',l_module_name,9);
              END IF;

              OPEN c_item_locator(l_mmtt_data_rec.organization_id,l_attributes.sug_location_id);

              FETCH c_item_locator INTO l_item_locator;

              IF c_item_locator%NOTFOUND THEN

                 IF l_debug=1 THEN
                    print_debug('The suggested locator fails the Items locator validatation',l_module_name,9);
                 END IF;

                 fnd_message.set_name('WMS','WMS_ATF_ITEM_SUBLOC_FAIL');
                 fnd_msg_pub.ADD;

                 RAISE fnd_api.g_exc_error;

              END IF;

           END IF;

        END IF;

      END IF;
      -- Bug 3405713
      -- Call wms_op_dest_sys_apis.create_pjm_locator before LPN suggestion API
      -- Because locator_ID on LPN is for logical locator
      -- wms_op_dest_sys_apis.create_pjm_locator will return a logical locator if it exists,
      -- otherwise create a logical locator.

      IF l_mmtt_data_rec.project_id IS NOT NULL OR
	l_mmtt_data_rec.task_id IS NOT NULL THEN

	 l_progress := '74';

	 IF (l_debug = 1) THEN
	    print_debug('Before calling wms_op_dest_sys_apis.create_pjm_locator with following parameters: ' , l_module_name, 1);
	    print_debug('x_locator_id => ' || l_attributes.sug_location_id , l_module_name, 1);
	    print_debug('p_project_id => ' ||  l_mmtt_data_rec.project_id, l_module_name, 1);
	    print_debug('p_task_id => ' ||  l_mmtt_data_rec.task_id, l_module_name, 1);

	 END IF;

	 wms_op_dest_sys_apis.create_pjm_locator
	   (x_locator_id => l_attributes.sug_location_id,
	    p_project_id => l_mmtt_data_rec.project_id,
	    p_task_id    => l_mmtt_data_rec.task_id
	    );

	 IF (l_debug = 1) THEN
	    print_debug('After calling wms_op_dest_sys_apis.create_pjm_locator : ' , l_module_name, 1);
	    print_debug('l_attributes.sug_location_id => ' ||  l_attributes.sug_location_id, l_module_name, 1);

	 END IF;
	 l_progress := '78';

      END IF;


      IF NVL(l_plan_details.lpn_selection_criteria,0) =
               wms_globals.G_OP_DEST_API OR
            NVL(l_plan_details.lpn_selection_criteria,0) =
               wms_globals.G_OP_DEST_CUSTOM_API
      THEN

         /*
          * The API should be validating its inputs so not validating
          * for selection_api_id here
          */


	    IF (l_debug = 1) THEN
	       print_debug('Before calling  wms_atf_dest_lpn.get_dest_lpn with following parameters: ' , l_module_name, 4);
	       print_debug('p_mode => ' || 1, l_module_name, 4);
	       print_debug('p_task_id => ' || p_source_task_id, l_module_name, 4);
	       print_debug('p_activity_type_id => ' || p_activity_type_id, l_module_name, 4);
	       print_debug('p_hook_call_id => ' || l_plan_details.lpn_selection_api_id, l_module_name, 4);
	       print_debug('p_lpn_id => ' || NULL, l_module_name, 4);
	       print_debug('p_item_id => ' || p_inventory_item_id, l_module_name, 4);
	    END IF;

	    l_progress := '80';

	    wms_atf_dest_lpn.get_dest_lpn
	    (
	      x_return_status         => l_return_status
	      ,  x_msg_count          => l_msg_count
	      ,  x_msg_data           => l_msg_data
	      ,  x_lpn_id             => l_attributes.cartonization_id
	      ,  x_valid_flag         => l_valid_flag
	      ,  p_mode               => 1
	      ,  p_task_id            => p_source_task_id
	      ,  p_activity_type_id   => p_activity_type_id
	      ,  p_hook_call_id       => l_plan_details.lpn_selection_api_id
	      ,  p_lpn_id             => NULL
	      ,  p_item_id            => p_inventory_item_id
	      ,  p_subinventory_code  => l_attributes.sug_sub_code
	      ,  p_locator_id         => l_attributes.sug_location_id
	      ,  p_api_version        => NULL
	      ,  p_init_msg_list      => NULL
	      ,  p_commit             => NULL
	      );

	    l_progress := '90';

	    IF (l_debug = 1) THEN
	       print_debug('After calling  wms_atf_dest_lpn.get_dest_lpn.' , l_module_name, 4);
	       print_debug('x_return_status => ' || l_return_status, l_module_name, 4);
	       print_debug('x_msg_count => ' || l_msg_count, l_module_name, 4);
	       print_debug('x_msg_data => ' || l_msg_data, l_module_name, 4);
	       print_debug('x_lpn_valid => ' || l_attributes.cartonization_id, l_module_name, 4);
	       print_debug('x_lpn_valid => ' || l_valid_flag, l_module_name, 4);
	    END IF;

	    IF l_return_status <> g_ret_sts_success THEN
	       IF (l_debug = 1) THEN
		  print_debug('wms_atf_dest_lpn.get_dest_lpn:  l_return_status = '|| l_return_status, l_module_name, 4);
	       END IF;

	       RAISE FND_API.G_EXC_ERROR;

	    END IF;

      ELSIF l_plan_details.operation_type = g_op_type_crossdock AND
            l_mmtt_data_rec.crossdock_to_wip_flag = 'N'
      THEN
	 --{{
	 -- If current operation is crossdock, need to determine whether to suggest LPN based on
	 -- subsequent outbound operation plan.
	 -- Also pass back drop LPN option based on operation plan i.e. 1,3 yes(2), 2, 4 No(1)
	 -- Putaway drop page should honor this with some tricky cases. check with gayu and mankumar
	 --}}
	 x_drop_lpn_option := l_xd_drop_lpn_option;

	 IF l_xd_drop_lpn_option = 2 THEN

	    --Call this API for:
	    -- (Default) LPN based consolidation in staging lane within delivery
	    -- LPN based consolidation in consolidation locator, within delivery in staging lane
	    -- LPN based consolidation in consolidation locator, across deliveries in staging lane
	    IF (x_consolidation_method_id = 2 OR l_xd_loc_selection_api_id = 1) THEN

	       IF (l_debug = 1) THEN
		  print_debug('Before calling wms_op_dest_sys_apis.Get_LPN_For_Delivery  with following parameters: ' , l_module_name, 4);
		  print_debug('p_task_id   => ' || p_source_task_id, l_module_name, 4);
		  print_debug('p_task_type => ' || g_wms_task_type_pick, l_module_name, 4);
		  print_debug('p_sug_sub   => ' ||l_attributes.sug_sub_code,l_module_name,4);
		  print_debug('p_sug_loc   => ' ||l_attributes.sug_location_id,l_module_name,4);
	       END IF;

	       l_progress := '90.10';

	       wms_op_dest_sys_apis.Get_LPN_For_Delivery
		 (
		   x_return_status         => l_return_status
		   ,  x_message            => l_msg_data
		   ,  x_lpn_id             => l_attributes.cartonization_id
		   ,  p_task_type          => g_wms_task_type_pick
		   ,  p_task_id            => p_source_task_id
		   ,  p_sug_sub            => l_attributes.sug_sub_code
		   ,  p_sug_loc            => l_attributes.sug_location_id
		   );

	       l_progress := '90.20';

	       IF (l_debug = 1) THEN
		  print_debug('After calling  wms_op_dest_sys_apis.Get_LPN_For_Delivery.' , l_module_name, 4);
		  print_debug('x_return_status => ' || l_return_status, l_module_name, 4);
		  print_debug('x_msg_data => ' || l_msg_data, l_module_name, 4);
		  print_debug('x_lpn_id => ' ||l_attributes.cartonization_id, l_module_name, 4);
	       END IF;

	       IF l_return_status <> g_ret_sts_success THEN
		  IF (l_debug = 1) THEN
		     print_debug('wms_atf_dest_lpn.get_dest_lpn:  l_return_status = '|| l_return_status, l_module_name, 4);
		  END IF;

		  RAISE FND_API.G_EXC_ERROR;

	       END IF;

	    END IF; -- (x_consolidation_method_id = 2) T

	  ELSE
	    x_drop_lpn_option := 1;
	 END IF;

       ELSIF l_plan_details.lpn_selection_criteria IS NOT NULL THEN

         /**
           * We should never come here, so raise Data Inconsistency Exception
           */
   	     IF (l_debug = 1) THEN
		print_debug('Invalid LPN Selection critiera value '||
			    l_plan_details.lpn_selection_criteria, l_module_name, 1);
	     END IF;

           RAISE FND_API.G_EXC_ERROR;

      END IF; /* lpn_selection...*/


      x_plan_attributes := l_attributes;

      --When x_return_status = 'W', x_msg_data is already
      --set to the translated string, so you do not want
      --to override it here
      IF (x_return_status <> 'W') THEN
	 fnd_msg_pub.count_and_get(
				    p_count => x_msg_count,
				    p_data  => x_msg_data
				    );
      END IF;

      --Moved this to the beginning because x_return_status could
      --have been updated to 'W', and this line will override the value
      --x_return_status  := g_ret_sts_success;

   EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
            print_debug(l_progress||' '||SQLERRM, l_module_name,1);

            IF fnd_msg_pub.check_msg_level(g_msg_lvl_error) THEN
               fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name, SQLERRM);
            END IF; /* fnd_msg.... */

	    IF (l_debug = 1) THEN
	       print_debug('Expected exception ', l_module_name, 1);
	    END IF;
            fnd_msg_pub.count_and_get(
                                       p_count => x_msg_count,
                                       p_data  => x_msg_data
                                      );
            x_error_code := SQLCODE;
            x_return_status := g_ret_sts_error;

	    IF c_mmtt_data%isopen THEN
	       CLOSE c_mmtt_data;
	    END IF;

	    IF c_plan_details%isopen THEN
	       CLOSE c_plan_details;
	    END IF;

	    IF c_parent_locator%isopen THEN
	       CLOSE c_parent_locator;
	    END IF;

       IF c_item_attributes%ISOPEN THEN
          CLOSE c_item_attributes;
       END IF;

       IF c_item_sub%ISOPEN THEN
          CLOSE c_item_sub;
       END IF;

       IF c_item_locator%ISOPEN THEN
          CLOSE c_item_locator;
       END IF;


         WHEN OTHERS THEN

            print_debug(l_progress||' '||SQLERRM, l_module_name,1);

            IF fnd_msg_pub.check_msg_level(g_msg_lvl_unexp_error) THEN
               fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name, SQLERRM);
            END IF; /* fnd_msg.... */

	    IF (l_debug = 1) THEN
	       print_debug('Other exceptions ', l_module_name, 1);
	    END IF;

            fnd_msg_pub.count_and_get(
                                       p_count => x_msg_count,
                                       p_data  => x_msg_data
                                      );
            x_error_code := SQLCODE;
            x_return_status := g_ret_sts_unexp_error;

	    IF c_mmtt_data%isopen THEN
	       CLOSE c_mmtt_data;
	    END IF;

	    IF c_plan_details%isopen THEN
	       CLOSE c_plan_details;
	    END IF;

	    IF c_parent_locator%isopen THEN
	       CLOSE c_parent_locator;
	    END IF;

       IF c_item_attributes%ISOPEN THEN
          CLOSE c_item_attributes;
       END IF;

       IF c_item_sub%ISOPEN THEN
          CLOSE c_item_sub;
       END IF;

       IF c_item_locator%ISOPEN THEN
          CLOSE c_item_locator;
       END IF;


   END Determine_Attributes;

/**
  * ACTIVATE_OPERATION_INSTANCE
  *   <p>For a given document record,this API activates the
  *      Operation Instance as well as the task
  *      associated with the current operation</p>
  *
  *  @param x_return_status    -Return Status
  *  @param x_msg_data         -Returns the Error message Status
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
      ,x_drop_lpn_option   OUT  NOCOPY  NUMBER	-- xdock
      ,x_consolidation_method_id   OUT NOCOPY  NUMBER
      ,p_source_task_id    IN           NUMBER
      ,p_activity_id       IN           NUMBER
      ,p_operation_type_id IN           NUMBER
      ,p_task_execute_rec  IN           WMS_DISPATCHED_TASKS%ROWTYPE ) IS


       CURSOR c_wdt_details IS
         SELECT status
           FROM wms_dispatched_tasks
          WHERE transaction_temp_id=p_source_task_id
          AND   task_type=g_wms_task_type_putaway;

       CURSOR c_inbound_doc IS
	  SELECT nvl(wopd.operation_plan_id, mmtt.operation_plan_id) operation_plan_id, -- get from wooi since mmtt may have subsequent plan ID
	    mmtt.transaction_source_type_id,
	    mmtt.transaction_action_id,
	    mmtt.organization_id,
	    mmtt.inventory_item_id,
	    mmtt.parent_line_id,
	    mmtt.primary_quantity,
	    mmtt.move_order_line_id
	    FROM mtl_material_transactions_temp mmtt,
	    wms_op_operation_instances wooi,
	    wms_op_plan_details wopd
	    WHERE mmtt.transaction_temp_id=p_source_task_id
	    AND mmtt.transaction_temp_id = wooi.source_task_id (+)
	    AND wooi.operation_plan_detail_id = wopd.operation_plan_detail_id(+);

       CURSOR c_operation_instance_details IS
          SELECT operation_type_id,
                 operation_status,
                 op_plan_instance_id,
                 operation_plan_detail_id,
                 operation_instance_id
          FROM wms_op_operation_instances
          WHERE source_task_id=p_source_task_id
	    AND operation_status IN (G_OP_INS_STAT_PENDING,G_OP_INS_STAT_ACTIVE)
	    ORDER BY operation_sequence DESC;

       CURSOR c_operation_sequence(v_op_plan_instance_id NUMBER) IS
          SELECT count(op_plan_instance_id) count
          FROM wms_op_operation_instances
          WHERE op_plan_instance_id=v_op_plan_instance_id
          GROUP BY op_plan_instance_id;

       CURSOR c_effective_date(v_person_id NUMBER) IS
          SELECT effective_start_date,effective_end_date
          FROM per_all_people_f
          WHERE person_id = v_person_id
          AND SYSDATE BETWEEN effective_start_date AND effective_end_date;


       l_wdt_rec                    WMS_DISPATCHED_TASKS%ROWTYPE := NULL;
       l_wdt_details                c_wdt_details%ROWTYPE;
       l_inbound_doc                c_inbound_doc%ROWTYPE;
       l_mmtt_rec                   MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE :=NULL;
       l_opertn_instance_details    c_operation_instance_details%ROWTYPE := NULL;
       l_op_plan_instance_id        NUMBER;
       l_operation_count            NUMBER;
       l_wooi_rec                   wms_op_operation_instances%ROWTYPE := NULL;
       l_wopi_rec                   wms_op_plan_instances%ROWTYPE := NULL;
       l_sug_sub_code               VARCHAR2(10);
       l_sug_location_id            NUMBER;
       l_sug_to_lpn_id              NUMBER;
       l_dest_param_rec             WMS_OP_INBOUND_PVT.DEST_PARAM_REC_TYPE;
       l_operation_type_id          NUMBER;

       l_debug       NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
       l_module_name VARCHAR2(30) := 'Activate_Operation_Instance';
       l_progress    NUMBER;

       l_return_status       VARCHAR2(1);
       l_msg_count           NUMBER;
       l_msg_data            VARCHAR2(400);
  BEGIN

      IF (l_debug = 1) THEN
          print_debug(' p_source_task_id ==> '||p_source_task_id ,l_module_name,3);
          print_debug(' p_activity_id    ==> '||p_activity_id,l_module_name,3);
          print_debug(' p_operation_type_id ==>'||p_operation_type_id,l_module_name,3);

      END IF;

      x_return_status  := g_ret_sts_success;
      l_progress:=10;

      SAVEPOINT activate_op_sp;

      l_operation_type_id := p_operation_type_id;

      IF (p_source_task_id IS NULL OR p_activity_id IS NULL) THEN
          IF (l_debug=1) THEN
             print_debug('Source task Id is null',l_module_name,1);
          END IF;

          /*Raise Invalid Arguement exception*/
          --x_error_code:=1;
          --RAISE FND_API.G_EXC_ERROR;
          raise_application_error(INVALID_INPUT,'Invalid inputs passed'||p_source_task_id||' '||p_activity_id);

       END IF;

       IF p_activity_id NOT IN (G_OP_ACTIVITY_INBOUND) THEN

        IF (l_debug=1) THEN
             print_debug('Invalid value of activity Id',l_module_name,1);
          END IF;

          /*Raise Invalid Arguement exception*/
          --x_error_code:=1;
          --RAISE FND_API.G_EXC_ERROR;
          raise_application_error(INVALID_INPUT,'Invalid inputs passed'||p_source_task_id||' '||p_activity_id);
       END IF;

       IF (p_activity_id =G_OP_ACTIVITY_INBOUND) THEN

          /* Create or update WDT
             This API can be called from 'Load', 'Drop', or 'Inspect' UI.
             Only when called from drop, there will be a WDT record with 'Loaded' status and
            'putaway' task type.For the other two cases, a new WDT record needs to be created.
          */
          l_progress:=20;

          OPEN c_wdt_details;

          FETCH c_wdt_details INTO l_wdt_details;

          IF (c_wdt_details%FOUND) THEN

             /*IF WDT.status = 'Dispatched' THEN
              *This is to carry over bug fix 2127361
              *Delete this WDT record*/
             IF (l_wdt_details.status=g_task_status_dispatched) THEN


                DELETE FROM wms_dispatched_tasks
                  WHERE transaction_temp_id=p_source_task_id;

                IF (l_debug=1) THEN
                  print_debug('Deleting the WDT record since in Dispatched status',l_module_name,9);
                END IF;

             END IF;

          END IF;/*WDT record exists*/
          CLOSE c_wdt_details;

          l_progress:=23;

          /* Setting the operation Type Id*/
          IF (l_wdt_details.status=g_task_status_loaded) THEN

             l_operation_type_id :=G_OP_TYPE_DROP;

             IF (l_debug=1) THEN
                print_debug('Operation is Drop',l_module_name,9);
             END IF;

          ELSIF ((l_wdt_details.status IS NULL OR l_wdt_details.status=g_task_status_dispatched) AND p_operation_type_id<>G_OP_TYPE_INSPECT) THEN

             IF (l_debug=1) THEN
                print_debug('Operation is Load',l_module_name,9);
             END IF;

             l_operation_type_id := G_OP_TYPE_LOAD;

          ELSE

             l_operation_type_id := p_operation_type_id;

          END IF;

          l_progress:=25;

          IF (l_wdt_details.status IS NULL OR l_wdt_details.status=g_task_status_dispatched) THEN

             /*IF WDT record does not exist OR WDT.status = 'Dispatched' THEN
              *Create WDT PL/SQL record with P_Task_Execute_Rec,
              *populate P_Source_Task_ID  into transaction_temp_ID, status 'Dispatched'
              */
             l_progress:=27;

             l_wdt_rec := p_task_execute_rec;

             l_wdt_rec.transaction_temp_id  := p_source_task_id;
             l_wdt_rec.status               := g_task_status_dispatched;

             IF (l_wdt_rec.person_id IS NOT NULL OR l_wdt_rec.person_id <>-1) THEN

                IF (l_debug=1) THEN
                  print_debug('Person id is not null ..hence fetching effective dates',l_module_name,4);
                END IF;

                OPEN c_effective_date(l_wdt_rec.person_id);

                FETCH c_effective_date INTO l_wdt_rec.effective_start_date,l_wdt_rec.effective_end_date;

                CLOSE c_effective_date;

                IF (l_debug=1) THEN
                 print_debug('Effective Dates fetched for Person are '||l_wdt_rec.effective_start_date||l_wdt_rec.effective_end_date,l_module_name,4);
                END IF;

             END IF;

             IF l_wdt_rec.effective_start_date IS NULL THEN

               l_wdt_rec.effective_start_date := SYSDATE;
               l_wdt_rec.effective_end_date   := SYSDATE;

             END IF;

             l_wdt_rec.dispatched_time      := SYSDATE;

             /*If P_Operation_Type_ID = 'Inspect' Then
              *  WDT.task_type = 'Inspect';
              *Else
              *  WDT.Task_Type = 'putaway';
              */
             IF (l_operation_type_id=G_OP_TYPE_INSPECT) THEN

                l_wdt_rec.task_type := g_wms_task_type_inspect;
             ELSE
                l_wdt_rec.task_type := g_wms_task_type_putaway;
             END IF;

          END IF;/*WDT not existing*/

          l_progress:=30;


        /* Check operation plan stamped or not.
         *  IF P_Activity_type_ID = Inbound THEN
         *  Query operation_plan_id from MMTT where transaction_temp_ID = P_Source_Task_ID
         *  If operation_plan_ID is NULL
         *   Return 'success' This handles the Non-ATF case
         */
          OPEN c_inbound_doc;

          FETCH c_inbound_doc INTO l_inbound_doc;

          IF (c_inbound_doc%NOTFOUND) THEN
             /* This is an Invalid document and hence raise exception*/
             IF (l_debug=1) THEN
                print_debug('Invalid Document Record',l_module_name,1);
             END IF;

             CLOSE c_inbound_doc;

             RAISE FND_API.G_EXC_ERROR;

          END IF;

          CLOSE c_inbound_doc;

          l_progress:=40;

          IF (l_inbound_doc.operation_plan_id IS NULL) THEN
             /*Non ATF case..Return after inserting WDT*/
             IF (l_debug=1) THEN
                print_debug('Operation Plan Id null on document record',l_module_name,9);
             END IF;

             l_progress:=50;

             IF (l_wdt_rec.transaction_temp_id IS NOT NULL) THEN   /*WDT record exists*/

                l_wdt_rec.operation_plan_id  := l_inbound_doc.operation_plan_id;
                l_wdt_rec.move_order_line_id := l_inbound_doc.move_order_line_id;

                IF (l_debug=1) THEN
                   print_debug('Calling the table handler to insert WDT records',l_module_name,9);
                   print_debug('Calling insert_Dispatched_tasks with the following values for WDT record',l_module_name,4);
                   print_debug('transaction_temp_id  ==>'||l_wdt_rec.transaction_temp_id,l_module_name,4);
                   print_debug('user_task_type       ==>'||l_wdt_rec.user_task_type,l_module_name,4);
                   print_debug('person_id            ==>'||l_wdt_rec.person_id,l_module_name,4);
                   print_debug('status               ==>'||l_wdt_rec.status,l_module_name,4);
                   print_debug('effective_start_date ==>'||l_wdt_rec.effective_start_date,l_module_name,4);
                   print_debug('equipment_id         ==>'||l_wdt_rec.equipment_id,l_module_name,4);
                   print_debug('equipment_instance   ==>'||l_wdt_rec.equipment_instance,l_module_name,4);
                   print_debug('person_resource_id   ==>'||l_wdt_rec.person_resource_id,l_module_name,4);
                   print_debug('machine_resource_id  ==>'||l_wdt_rec.machine_resource_id,l_module_name,4);
                   print_debug('loaded_time          ==>'||l_wdt_rec.loaded_time,l_module_name,4);
                   print_debug('drop_off_time        ==>'||l_wdt_rec.drop_off_time,l_module_name,4);
                   print_debug('last_update_date     ==>'||l_wdt_rec.last_update_date,l_module_name,4);
                   print_debug('last_update_by       ==>'||l_wdt_rec.last_updated_by,l_module_name,4);
                   print_debug('created_by           ==>'||l_wdt_rec.created_by,l_module_name,4);
                   print_debug('creation_date        ==>'||l_wdt_rec.creation_date,l_module_name,4);
                   print_debug('priority             ==>'||l_wdt_rec.priority,l_module_name,4);
                   print_debug('task_group_id        ==>'||l_wdt_rec.task_group_id,l_module_name,4);
                   print_debug('device_id            ==>'||l_wdt_rec.device_id,l_module_name,4);
                   print_debug('device_invoked       ==>'||l_wdt_rec.device_invoked,l_module_name,4);
                   print_debug('device_request_id    ==>'||l_wdt_rec.device_request_id,l_module_name,4);
                   print_debug('move_order_line_id   ==>'||l_wdt_rec.move_order_line_id,l_module_name,4);
                   print_debug('task_type            ==>'||l_wdt_rec.task_type,l_module_name,4);
                   print_debug('Operation Plan Id    ==>'||l_wdt_rec.operation_plan_id,l_module_name,4);
                   print_debug('Move Order Line Id   ==>'||l_wdt_rec.move_order_line_id,l_module_name,4);
                   print_debug('organization_id      ==>'||l_wdt_rec.organization_id,l_module_name,4);
                END IF;

                l_progress:=60;

                WMS_OP_RUNTIME_PVT_APIS.Insert_Dispatched_tasks
                ( p_wdt_rec        => l_wdt_rec,
                  p_source_task_id => p_source_task_id,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data
                 );

                l_progress:=65;

               IF (l_debug=1) THEN
                 print_debug('return status afte calling table handler '||x_return_status,l_module_name,9);
               END IF;

               IF (x_return_status=g_ret_sts_error) THEN

                 IF (l_debug=1) THEN
                   print_debug('Expected error from table handler',l_module_name,1);
                 END IF;

                 RAISE FND_API.G_EXC_ERROR;

               ELSIF (x_return_status<>g_ret_sts_success) THEN
                 IF (l_debug=1) THEN
                   print_debug('Unexpected error fromt table hander',l_module_name,1);
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               END IF;

             END IF; /*WDT Record to be inserted*/

             RETURN;
          END IF;/*Non ATF Case*/

       END IF;/*Activity Inbound*/

      /* Query WMS_OP_OPERATION_INSTANCES where source_task_ID = P_Source_Task_ID
       * with highest operation_sequence; populate this record into PL/SQL record.
       * Raise unexpected error if it does not exist, and return appropriate error code.
       */
       l_progress:=70;

       OPEN c_operation_instance_details;

       FETCH c_operation_instance_details INTO l_opertn_instance_details;

       IF (c_operation_instance_details%NOTFOUND) THEN

          /* This is an invalid condition for Activiate
             The cursor would also take care of the following validation:
             If the status for this WOOI record is other than 'pending' or 'Active',
             raise unexpected error and return error code.*/

          IF (l_debug=1) THEN
             print_debug('No operation INstance exists:invalid condition',l_module_name,1);
          END IF;

          CLOSE c_operation_instance_details;

          RAISE FND_API.G_EXC_ERROR;

       END IF;
       CLOSE c_operation_instance_details;

       IF (l_debug=1) THEN
	  print_debug('l_opertn_instance_details.operation_type_id= '||l_opertn_instance_details.operation_type_id,l_module_name,1);
	  print_debug('l_opertn_instance_details.operation_status = '||l_opertn_instance_details.operation_status,l_module_name,1);
	  print_debug('l_opertn_instance_details.op_plan_instance_id = '||l_opertn_instance_details.op_plan_instance_id,l_module_name,1);
	  print_debug('l_opertn_instance_details.operation_plan_detail_id = '||l_opertn_instance_details.operation_plan_detail_id,l_module_name,1);
	  print_debug('l_opertn_instance_details.operation_instance_id = '||l_opertn_instance_details.operation_instance_id,l_module_name,1);

       END IF;


       l_progress:=80;

       l_op_plan_instance_id:=l_opertn_instance_details.op_plan_instance_id;

       IF (p_activity_id=G_OP_ACTIVITY_INBOUND) THEN


         /*Calling the table handler to insert records in WDT*/
          IF (l_wdt_rec.transaction_temp_id IS NOT NULL) THEN   /*WDT record needs to be inserted*/
             l_progress:=90;

              l_wdt_rec.op_plan_instance_id := l_op_plan_instance_id;
              l_wdt_rec.operation_plan_id   := l_inbound_doc.operation_plan_id;
              l_wdt_rec.move_order_line_id  := l_inbound_doc.move_order_line_id;

              IF (l_debug=1) THEN
                 print_debug('Calling the table handler to insert WDT records',l_module_name,9);
                 print_debug('Calling insert_Dispatched_tasks with the following values for WDT record',l_module_name,4);
                 print_debug('transaction_temp_id  ==>'||l_wdt_rec.transaction_temp_id,l_module_name,4);
                 print_debug('user_task_type       ==>'||l_wdt_rec.user_task_type,l_module_name,4);
                 print_debug('person_id            ==>'||l_wdt_rec.person_id,l_module_name,4);
                 print_debug('status               ==>'||l_wdt_rec.status,l_module_name,4);
                 print_debug('effective_start_date ==>'||l_wdt_rec.effective_start_date,l_module_name,4);
                 print_debug('equipment_id         ==>'||l_wdt_rec.equipment_id,l_module_name,4);
                 print_debug('equipment_instance   ==>'||l_wdt_rec.equipment_instance,l_module_name,4);
                 print_debug('person_resource_id   ==>'||l_wdt_rec.person_resource_id,l_module_name,4);
                 print_debug('machine_resource_id  ==>'||l_wdt_rec.machine_resource_id,l_module_name,4);
                 print_debug('loaded_time          ==>'||l_wdt_rec.loaded_time,l_module_name,4);
                 print_debug('drop_off_time        ==>'||l_wdt_rec.drop_off_time,l_module_name,4);
                 print_debug('last_update_date     ==>'||l_wdt_rec.last_update_date,l_module_name,4);
                 print_debug('last_update_by       ==>'||l_wdt_rec.last_updated_by,l_module_name,4);
                 print_debug('created_by           ==>'||l_wdt_rec.created_by,l_module_name,4);
                 print_debug('creation_date        ==>'||l_wdt_rec.creation_date,l_module_name,4);
                 print_debug('priority             ==>'||l_wdt_rec.priority,l_module_name,4);
                 print_debug('task_group_id        ==>'||l_wdt_rec.task_group_id,l_module_name,4);
                 print_debug('device_id            ==>'||l_wdt_rec.device_id,l_module_name,4);
                 print_debug('device_invoked       ==>'||l_wdt_rec.device_invoked,l_module_name,4);
                 print_debug('device_request_id    ==>'||l_wdt_rec.device_request_id,l_module_name,4);
                 print_debug('move_order_line_id   ==>'||l_wdt_rec.move_order_line_id,l_module_name,4);
                 print_debug('task_type            ==>'||l_wdt_rec.task_type,l_module_name,4);
                 print_debug('Plan  Id             ==>'||l_wdt_rec.operation_plan_id,l_module_name,4);
                 print_debug('Plan Instance Id     ==>'||l_wdt_rec.op_plan_instance_id,l_module_name,4);
                 print_debug('Move Order Line Id   ==>'||l_wdt_rec.move_order_line_id,l_module_name,4);
              END IF;

              l_progress:=100;

              WMS_OP_RUNTIME_PVT_APIS.Insert_Dispatched_tasks
              ( p_wdt_rec        => l_wdt_rec,
                p_source_task_id => p_source_task_id,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data
               );

              l_progress:=110;

             IF (l_debug=1) THEN
               print_debug('return status afte calling table handler '||x_return_status,l_module_name,9);
             END IF;

             IF (x_return_status=g_ret_sts_error) THEN

               IF (l_debug=1) THEN
                 print_debug('Expected error from table handler',l_module_name,1);
               END IF;

               RAISE FND_API.G_EXC_ERROR;

             ELSIF (x_return_status<>g_ret_sts_success) THEN
               IF (l_debug=1) THEN
                 print_debug('Unexpected error fromt table hander',l_module_name,1);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

             END IF;

           END IF; /*WDT Record to be inserted*/



      /** If P_operation_Type_ID = 'Inspect' AND WOOI.operation_Type_ID = 'Load'
        *  This is the case where user inspects an LPN containing 2 mmtt lines:
        *  first with operation plan 'Inspect', second with operation plan 'load-drop-inspect'.
        *  User is allowed to inspect the full quantity. When inspect page calls activate_operation_instance
        *  for the second mmtt line, we should abort the operation plan.We first call abort_plan_instance
        *  to take care of plan/operation instances and null out MMTT.operation_plan_ID;
        *  then we call 'complete' document handler to take care of MMTT/MTRL etc.
        *  WMS_OP_RUNTIME_PUB.Abort_Plan_Instance
        *                      Return success;
        */

          IF (l_operation_type_id=G_OP_TYPE_INSPECT AND l_opertn_instance_details.operation_type_id=G_OP_TYPE_LOAD) THEN

             IF (l_debug=1) THEN
              print_debug('Aborting the Plan where the operation is load and user performs an inspect',l_module_name,9);
             END IF;

             Abort_Operation_Plan(  x_return_status    =>x_return_status
                               , x_msg_data         =>x_msg_data
                               , x_msg_count        =>x_msg_count
                               , x_error_code       =>x_error_code
                               , p_source_task_id   =>p_source_task_id
                               , p_activity_type_id =>p_activity_id);
             l_progress:=120;

           IF (l_debug=1) THEN
             print_debug('Return status of Abort_operation_plan'||x_return_status,l_module_name,9);
           END IF;

           IF (x_return_status=g_ret_sts_error) THEN
              IF (l_debug=1) THEN
                 print_debug('Error Obtained from Abort_operation_plan',l_module_name,1);
              END IF;
              RAISE FND_API.G_EXC_ERROR;

           ELSIF (x_return_status=g_ret_sts_unexp_error) THEN

             IF (l_debug=1) THEN
               print_debug('Error Obtained from Abort_operation_plan',l_module_name,1);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSE
             /*Return status from Abort is sucess.REturn from here*/
             RETURN;

          END IF;

       END IF;/*Operation Type Inspect*/

      END IF;/*Only incase of Inbound*/

      l_progress:=130;

      l_wooi_rec.operation_instance_id := l_opertn_instance_details.operation_instance_id;

      IF (l_opertn_instance_details.operation_status=G_OP_INS_STAT_PENDING) THEN
         IF (l_debug=1) THEN
            print_debug('Current Operation status is Pending,Update it to Active',l_module_name,9);
         END IF;

         /*If the status for this WOOI record is 'pending' update it to 'Active'*/
         l_wooi_rec.operation_status      := G_OP_INS_STAT_ACTIVE;

         l_progress:=140;

         IF (l_debug=1) THEN
            print_debug('the following values set',l_module_name,9);
            print_debug('status ==>'||l_wooi_rec.operation_status,l_module_name,9);
            print_debug('Operation Instance Id==>'||l_wooi_rec.operation_instance_id,l_module_name,9);
         END IF;

      END IF;/*Operation status is Pending*/

      l_progress:=150;

      /* If there is only one WOOI record for the same OP_PLAN_INSTANCE_ID,
       * it means it is the first step of this plan.
       * In this case, update WMS_OP_PLAN_INSTANCES status to 'Active' for this OP_PLAN_INSTANCE_ID.*/

      OPEN c_operation_sequence(l_op_plan_instance_id);

      FETCH c_operation_sequence INTO l_operation_count;

      CLOSE c_operation_sequence;

      l_progress:=160;

      IF (l_operation_count=1) THEN
         IF (l_debug=1) THEN
            print_debug('First operation in the plan,hence update plan status to In Progress',l_module_name,9);
         END IF;

         l_wopi_rec.op_plan_instance_id:=l_op_plan_instance_id;
         l_wopi_rec.status:=G_OP_INS_STAT_IN_PROGRESS;
	 l_wopi_rec.plan_execution_start_date := Sysdate;

         l_progress:=170;

         IF (l_debug=1) THEN
            print_debug('Calling WMS_OP_RUNTIME_PVT_APIS.UPDATE_PLAN_INSTANCE to update the foll values',l_module_name,9);
            print_debug('Status'||l_wopi_rec.status,l_module_name,9);
            print_debug('Plan Instance Id'||l_wopi_rec.op_plan_instance_id,l_module_name,9);

         END IF;

         WMS_OP_RUNTIME_PVT_APIS.UPDATE_PLAN_INSTANCE
           ( p_update_rec    => l_wopi_rec
            ,x_return_status => x_return_status
            ,x_msg_count     => x_msg_count
            ,x_msg_data      => x_msg_data);

         l_progress:=180;

         IF (l_debug=1) THEN
             print_debug('Return status from table hanlder'||x_return_status,l_module_name,9);
          END IF;

          IF (x_return_status=g_ret_sts_error) THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF (x_return_status<>g_ret_sts_success) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      END IF;/*Count=1*/

      /*IF P_Operation_Type_ID = 'Drop'
       * Derive destination methods.
       */

      IF ( l_operation_type_id=G_OP_TYPE_DROP AND p_activity_id=G_OP_ACTIVITY_INBOUND) THEN

         l_progress:=190;

         /*Calling Determine_attributes to get the suggested sub,locator and LPN based on the
           PLan Attributes*/
         IF (l_debug=1) THEN
            print_debug('Calling Determine_Attributes with the following parametemrs',l_module_name,9);
            print_debug('p_source_task_id  ==> '||p_source_task_id,l_module_name,4);
            print_debug('p_activity_id     ==> '||p_activity_id,l_module_name,4);
         END IF;

         Determine_Attributes(
              x_return_status    => x_return_status,
              x_msg_data         => x_msg_data,
              x_msg_count        => x_msg_count,
	      x_error_code       => x_error_code,
	      x_drop_lpn_option  => x_drop_lpn_option,
	      x_plan_attributes  => l_dest_param_rec,
	      x_consolidation_method_id => x_consolidation_method_id,
              p_source_task_id   => p_source_task_id,
	      p_activity_type_id => p_activity_id,
	      p_inventory_item_id => l_inbound_doc.inventory_item_id
	      );

         l_progress:=200;

         IF (l_debug=1) THEN
            print_debug('Return status from Determine Attributes'||x_return_status,l_module_name,9);
	    print_debug('x_drop_lpn_option = '||x_drop_lpn_option,l_module_name,9);

         END IF;

         IF (x_return_status=g_ret_sts_error) THEN
            IF (l_debug=1) THEN
               print_debug('Error obtained and hence raising exception',l_module_name,1);
            END IF;
            RAISE FND_API.G_EXC_ERROR;

         ELSIF (x_return_status=g_ret_sts_unexp_error) THEN
            IF (l_debug=1) THEN
               print_debug('Unexpected error obtained ',l_module_name,1);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         END IF;

         IF (l_debug=1) THEN
            print_debug('Values returned from Determine Attributes are',l_module_name,9);
            print_debug('suggested_sub_code ==>'||l_dest_param_rec.sug_sub_code,l_module_name,9);
            print_debug('Suggested Locator  ==>'||l_dest_param_rec.sug_location_id,l_module_name,9);
            print_debug('Suggested LPN      ==>'||l_dest_param_rec.cartonization_id,l_module_name,9);
         END IF;


         l_progress:=210;

         l_mmtt_rec.transaction_temp_id        := p_source_task_id;
         l_mmtt_rec.transaction_source_type_id := l_inbound_doc.transaction_source_type_id;
         l_mmtt_rec.transaction_action_id      := l_inbound_doc.transaction_action_id;
         l_mmtt_rec.organization_id            := l_inbound_doc.organization_id;
         l_mmtt_rec.parent_line_id             := l_inbound_doc.parent_line_id;
         l_mmtt_rec.primary_quantity           := l_inbound_doc.primary_quantity;
	 l_mmtt_rec.inventory_item_id          := l_inbound_doc.inventory_item_id;

         IF (l_debug=1) THEN
            print_debug('Doc attributes being passed to the DOc handler',l_module_name,9);
            print_debug('Trx Src Type Id ==>'||l_mmtt_rec.transaction_source_type_id,l_module_name,9);
            print_debug('Trx Action Id   ==>'||l_mmtt_rec.transaction_action_id,l_module_name,9);
            print_debug('Organization Id ==>'||l_mmtt_rec.organization_id,l_module_name,9);
	    print_debug('l_mmtt_rec.inventory_item_id  ==>'||l_mmtt_rec.inventory_item_id , l_module_name, 9);
         END IF;

         WMS_OP_INBOUND_PVT.ACTIVATE
            ( x_return_status    => l_return_status,--Use l_return_status instead
              x_msg_count        => l_msg_count,    --of x_return_status because
              x_msg_data         => l_msg_data,     --it will override the value
              x_error_code       => x_error_code,   --returned from determine_attributes
              p_source_task_id   => p_source_task_id,
              p_update_param_rec => l_dest_param_rec,
              p_document_rec     => l_mmtt_rec);


         l_progress:=220;

         IF (l_debug=1) THEN
             print_debug('Return status from document handler'||l_return_status,l_module_name,9);
         END IF;

         IF (l_return_status=g_ret_sts_error) THEN
             RAISE FND_API.G_EXC_ERROR;
         ELSIF (l_return_status<>g_ret_sts_success) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         l_progress:=230;

         l_wooi_rec.SUG_TO_SUB_CODE   := l_dest_param_rec.sug_sub_code;
         l_wooi_rec.SUG_TO_LOCATOR_ID := l_dest_param_rec.sug_location_id;
	 /* comment out  by GXIAO 12/10/03*/
         --l_wooi_rec.LPN_ID            := l_dest_param_rec.cartonization_id;
      END IF;/*Activity Inbound and Drop Operation*/

      l_progress:=240;

      WMS_OP_RUNTIME_PVT_APIS.UPDATE_OPERATION_INSTANCE
            (  x_return_status => l_return_status --Use l_return_status instead
             , x_msg_count     => l_msg_count     --of x_return_status because
             , x_msg_data      => l_msg_data      --it will override the value
             , p_update_rec    => l_wooi_rec);    --returned from determine_attributes

      IF (l_debug=1) THEN
        print_debug('Return status from table hanlder'||l_return_status,l_module_name,9);
      END IF;

      IF (l_return_status=g_ret_sts_error) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status<>g_ret_sts_success) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

         l_progress:=250;


  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
           IF (l_debug=1) THEN
             print_debug('Expected Error at '||l_progress, l_module_name,1);
           END IF;

           IF fnd_msg_pub.check_msg_level(g_msg_lvl_error) THEN
              fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name, SQLERRM);
           END IF; /* fnd_msg.... */

           fnd_msg_pub.count_and_get(
                                      p_count => x_msg_count,
                                      p_data  => x_msg_data
                                     );
           --x_error_code := SQLCODE;
           x_return_status := g_ret_sts_error;

           IF (c_inbound_doc%ISOPEN) THEN
              CLOSE c_inbound_doc;
           END IF;

           IF (c_wdt_details%ISOPEN) THEN
              CLOSE c_wdt_details;
           END IF;

           IF (c_operation_instance_details%ISOPEN) THEN
              CLOSE c_operation_instance_details;
           END IF;

           IF (c_operation_sequence%ISOPEN) THEN
              CLOSE c_operation_sequence;
           END IF;

           IF (c_effective_date%ISOPEN) THEN
              CLOSE c_effective_date;
           END IF;

           ROLLBACK TO activate_op_sp;

        WHEN OTHERS THEN
           IF (l_debug=1) THEN
             print_debug('Unexpected error at'||l_progress||' '||SQLERRM, l_module_name,1);
           END IF;


           IF fnd_msg_pub.check_msg_level(g_msg_lvl_unexp_error) THEN
              fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name, SQLERRM);
           END IF; /* fnd_msg.... */

           fnd_msg_pub.count_and_get(
                                      p_count => x_msg_count,
                                      p_data  => x_msg_data
                                     );
           --x_error_code := SQLCODE;
           x_return_status := g_ret_sts_unexp_error;
           IF (c_inbound_doc%ISOPEN) THEN
              CLOSE c_inbound_doc;
           END IF;

           IF (c_wdt_details%ISOPEN) THEN
              CLOSE c_wdt_details;
           END IF;

           IF (c_operation_instance_details%ISOPEN) THEN
              CLOSE c_operation_instance_details;
           END IF;

           IF (c_operation_sequence%ISOPEN) THEN
              CLOSE c_operation_sequence;
           END IF;

           IF (c_effective_date%ISOPEN) THEN
              CLOSE c_effective_date;
           END IF;


           ROLLBACK TO activate_op_sp;

 END ACTIVATE_OPERATION_INSTANCE;




/**  /**  Complete_Operation_instance
  *   <p>This procedure completes the current operation and  creates the next operation instance.
  *     If the operation is the last operation the plan is marked  as 'COMPLETED' and archived.</p>
  *
  *  @param x_return_status      -Return Status
  *  @param x_msg_data           -Returns the Error message Status
  *  @param x_msg_count          -Returns the message count
  *  @param x_error_code         -Returns appropriate error code in case of any error.
  *  @param p_source_task_id     -Identifier of the document record.
  *  @param p_activity_id        -Lookup Code for the Activity Type
  *  @param p_operation_type_id  -Input parameter containing the lookup code for the Operation
  *                               Type. Should be passed for inspect operation.
 **/
    PROCEDURE complete_operation_instance
    (
     x_return_status     OUT  NOCOPY  VARCHAR2
     ,x_msg_data          OUT  NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE
     ,x_msg_count         OUT  NOCOPY  NUMBER
     ,x_error_code        OUT  NOCOPY  NUMBER
     ,p_source_task_id    IN           NUMBER
     ,p_activity_id       IN           NUMBER
     ,p_operation_type_id IN           NUMBER )
    IS

       l_debug               NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
       l_module_name         VARCHAR2(30) := 'Complete_Operation_Instance';
       l_progress            NUMBER;
       l_return_status       VARCHAR2(1);
       l_msg_count           NUMBER;
       l_msg_data            VARCHAR2(400);

       l_wdt_task_id         NUMBER;
       l_wdt_status          NUMBER;
       l_operation_type_id   NUMBER;
       l_new_mmtt_id         NUMBER;
       l_atf_error_code      NUMBER;
       l_last_op_sequence    NUMBER;

       l_unforgivable_error_flag  VARCHAR2(1) := 'N';
       l_loc_sel_criteria_id      NUMBER;
       l_loc_sel_api_id           NUMBER;

       l_locator_id_dummy         NUMBER;
       l_subinventory_code_dummy  VARCHAR2(10);
       l_zone_id_dummy            NUMBER;
       l_valid_flag               VARCHAR2(1);
       l_lpn_controlled_flag        NUMBER;

       CURSOR c_inbound_document_details IS
	  SELECT transaction_temp_id,
            operation_plan_id,
            inventory_item_id,
            subinventory_code,
            locator_id,
            transfer_subinventory,
            transfer_to_location,
            organization_id,
            Decode(wms_task_type, -1, g_wms_task_type_putaway, wms_task_type) wms_task_type,
	    parent_line_id,
	    transaction_action_id,
	    transaction_source_type_id,
	    transaction_type_id,
	    move_order_line_id,
	    transaction_uom,
	    transaction_quantity,
	    lpn_id,
	    content_lpn_id,
	    transfer_lpn_id
	    FROM mtl_material_transactions_temp
	    WHERE transaction_temp_id=p_source_task_id;

       l_inbound_doc_rec  c_inbound_document_details%ROWTYPE;
       l_mmtt_rec mtl_material_transactions_temp%ROWTYPE;

       -- cursor to get the current active operation instance
       -- for the source task

       CURSOR c_wooi_data_rec IS
	  SELECT wooi.operation_instance_id,
	    wooi.operation_type_id,
	    wooi.operation_plan_detail_id,
	    wooi.op_plan_instance_id,
	    wooi.operation_status,
	    wooi.operation_sequence,
	    wooi.sug_to_sub_code,
	    wooi.sug_to_locator_id,
	    wooi.organization_id,
	    wopd.operation_plan_id
	    FROM wms_op_operation_instances wooi,
	    wms_op_plan_details wopd
	    WHERE wooi.source_task_id = p_source_task_id
	    AND wooi.activity_type_id = p_activity_id
	    AND wooi.operation_plan_detail_id = wopd.operation_plan_detail_id
	    ORDER BY wooi.operation_sequence DESC,
	    wooi.operation_type_id DESC; -- this is added for crossdock, the last two operations will have the same operation_sequence. But we want to show drop first in this query
--	    AND operation_status = g_op_ins_stat_active;

       l_wooi_data_rec c_wooi_data_rec%ROWTYPE;
       l_wooi_rec wms_op_operation_instances%ROWTYPE;

       -- cursor to get the plan detail for the next operation
       CURSOR c_next_plan_detail(v_operation_plan_id NUMBER,
				 v_current_detail_sequence NUMBER) IS
	  SELECT wopd1.operation_plan_detail_id
	    , wopd1.operation_sequence
	    , wopd1.is_in_inventory
	    , wopd1.operation_type
	    , Decode(Nvl(wopb.crossdock_to_wip_flag, 'N'),'N', Nvl(wopd1.subsequent_op_plan_id, 1),v_operation_plan_id) subsequent_op_plan_id-- added for planned xdocking
	    FROM wms_op_plan_details wopd1,
	    wms_op_plans_b wopb
	    WHERE wopd1.operation_plan_id  = v_operation_plan_id
	    AND wopb.operation_plan_id = v_operation_plan_id
	    AND   wopd1.operation_sequence = (SELECT MIN(wopd2.operation_sequence)
					      FROM wms_op_plan_details wopd2
					      WHERE wopd2.operation_plan_id = v_operation_plan_id
					      AND (wopd2.operation_sequence > v_current_detail_sequence  -- operations after the current
						   OR (wopd2.operation_type = g_op_type_crossdock -- when current is a load operation for crossdock, sequence can be same as current operation
						       AND wopd2.operation_sequence = v_current_detail_sequence)
						   )
					      );

       l_operation_plan_detail_rec c_next_plan_detail%ROWTYPE;

    BEGIN

       IF (l_debug = 1) THEN
	  print_debug(' Entered. ',l_module_name,1);

	  print_debug(' p_source_task_id==> '||p_source_task_id,l_module_name,3);
	  print_debug(' p_activity_id==> '||p_activity_id,l_module_name,3);
	  print_debug(' p_operation_type_id==> '||p_operation_type_id,l_module_name,3);
       END IF;

       x_return_status  := g_ret_sts_success;
       l_progress := 10;
       SAVEPOINT sp_complete_oprtn_instance;


       IF p_source_task_id IS NULL THEN
	  IF (l_debug=1) THEN
	     print_debug('Invalid input param. p_source_task_id Cannot be NULL.',l_module_name,4);
	  END IF;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;


       IF p_activity_id IS NULL THEN
	  IF (l_debug=1) THEN
	     print_debug('Invalid input param. p_activity_id Cannot be NULL.',l_module_name,4);
	  END IF;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF p_operation_type_id IS NOT NULL AND
	 p_operation_type_id NOT IN (g_op_type_drop, g_op_type_load, g_op_type_inspect)THEN
	  IF (l_debug=1) THEN
	     print_debug('Invalid input param. p_operation_type_id can only be load, drop, inspect or NULL.',l_module_name,4);
	  END IF;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;

       l_operation_type_id := p_operation_type_id;

       l_progress := 20;

       IF p_activity_id = g_op_activity_inbound THEN
	  IF (l_debug=1) THEN
	     print_debug('Inbound Activity.',l_module_name,4);
	  END IF;

	  OPEN c_inbound_document_details;

	  FETCH c_inbound_document_details
	    INTO l_inbound_doc_rec;

	  IF c_inbound_document_details%notfound THEN
	     IF (l_debug=1) THEN
		print_debug('Invalid input param. p_source_task_id does not match to an MMTT record.',l_module_name,4);
	     END IF;
	     RAISE FND_API.G_EXC_ERROR;
	  END IF;

	  CLOSE c_inbound_document_details;


	  l_mmtt_rec.transaction_temp_id := l_inbound_doc_rec.transaction_temp_id;
	  l_mmtt_rec.operation_plan_id := l_inbound_doc_rec.operation_plan_id;
	  l_mmtt_rec.inventory_item_id := l_inbound_doc_rec.inventory_item_id;
	  l_mmtt_rec.subinventory_code := l_inbound_doc_rec.subinventory_code;
	  l_mmtt_rec.locator_id := l_inbound_doc_rec.locator_id;
	  l_mmtt_rec.transfer_subinventory := l_inbound_doc_rec.transfer_subinventory;
	  l_mmtt_rec.transfer_to_location := l_inbound_doc_rec.transfer_to_location;
	  l_mmtt_rec.organization_id := l_inbound_doc_rec.organization_id;
	  l_mmtt_rec.wms_task_type := l_inbound_doc_rec.wms_task_type;
	  l_mmtt_rec.parent_line_id := l_inbound_doc_rec.parent_line_id;
	  l_mmtt_rec.transaction_action_id := l_inbound_doc_rec.transaction_action_id;
	  l_mmtt_rec.transaction_source_type_id := l_inbound_doc_rec.transaction_source_type_id;
	  l_mmtt_rec.transaction_type_id := l_inbound_doc_rec.transaction_type_id;
	  l_mmtt_rec.move_order_line_id := l_inbound_doc_rec.move_order_line_id;
	  l_mmtt_rec.transaction_uom := l_inbound_doc_rec.transaction_uom;
	  l_mmtt_rec.transaction_quantity := l_inbound_doc_rec.transaction_quantity;


	  IF (l_debug=1) THEN
	     print_debug('l_mmtt_rec.transaction_temp_id = '|| l_mmtt_rec.transaction_temp_id, l_module_name,4);
	     print_debug('l_mmtt_rec.operation_plan_id = '|| l_mmtt_rec.operation_plan_id, l_module_name,4);
	     print_debug('l_mmtt_rec.inventory_item_id = '|| l_mmtt_rec.inventory_item_id, l_module_name,4);
	     print_debug('l_mmtt_rec.subinventory_code = '|| l_mmtt_rec.subinventory_code, l_module_name,4);
	     print_debug('l_mmtt_rec.locator_id = '|| l_mmtt_rec.locator_id, l_module_name,4);
	     print_debug('l_mmtt_rec.transfer_subinventory = '|| l_mmtt_rec.transfer_subinventory, l_module_name,4);
	     print_debug('l_mmtt_rec.transfer_to_location  = '|| l_mmtt_rec.transfer_to_location , l_module_name,4);
	     print_debug('l_mmtt_rec.organization_id = '|| l_mmtt_rec.organization_id, l_module_name,4);
	     print_debug('l_mmtt_rec.wms_task_type = '|| l_mmtt_rec.wms_task_type, l_module_name,4);
	     print_debug('l_mmtt_rec.parent_line_id = '|| l_mmtt_rec.parent_line_id, l_module_name,4);
	     print_debug('l_mmtt_rec.transaction_action_id = '|| l_mmtt_rec.transaction_action_id, l_module_name,4);
	     print_debug('l_mmtt_rec.transaction_source_type_id = '|| l_mmtt_rec.transaction_source_type_id, l_module_name,4);
	     print_debug('l_mmtt_rec.transaction_type_id = '|| l_mmtt_rec.transaction_type_id, l_module_name,4);
	     print_debug('l_mmtt_rec.move_order_line_id = '|| l_mmtt_rec.move_order_line_id, l_module_name,4);
	     print_debug('l_mmtt_rec.transaction_uom = '|| l_mmtt_rec.transaction_uom, l_module_name,4);
	     print_debug('l_mmtt_rec.transaction_quantity = '|| l_mmtt_rec.transaction_quantity, l_module_name,4);
	     print_debug('l_inbound_doc_rec.lpn_id = '||l_inbound_doc_rec.lpn_id , l_module_name,4);
	     print_debug('l_inbound_doc_rec.content_lpn_id = '||l_inbound_doc_rec.content_lpn_id , l_module_name,4);
	     print_debug('l_inbound_doc_rec.transfer_lpn_id = '||l_inbound_doc_rec.transfer_lpn_id , l_module_name,4);

	  END IF;


	  l_progress := 23;

	  IF l_mmtt_rec.operation_plan_id IS NOT NULL THEN
	     -- fetch the current active operation instance for this task
	     OPEN c_wooi_data_rec;

	     FETCH c_wooi_data_rec INTO l_wooi_data_rec;
	     IF c_wooi_data_rec%notfound THEN
		IF (l_debug = 1) THEN
		   print_debug('Operation instance record does not exist for this task.',l_module_name,4);
		END IF;
		fnd_message.set_name('WMS', 'WMS_ATF_NO_ACTIVE_PLAN');
		fnd_msg_pub.ADD;
		RAISE FND_API.G_EXC_ERROR;
	     END IF;

	     CLOSE c_wooi_data_rec;

	     IF (l_debug = 1) THEN

		print_debug('l_wooi_data_rec.operation_instance_id = '|| l_wooi_data_rec.operation_instance_id,l_module_name,4);
		print_debug('l_wooi_data_rec.operation_type_id = '|| l_wooi_data_rec.operation_type_id,l_module_name,4);
		print_debug('l_wooi_data_rec.operation_plan_detail_id = '|| l_wooi_data_rec.operation_plan_detail_id,l_module_name,4);
		print_debug('l_wooi_data_rec.operation_plan_id = '|| l_wooi_data_rec.operation_plan_id,l_module_name,4);
		print_debug('l_wooi_data_rec.op_plan_instance_id = '|| l_wooi_data_rec.op_plan_instance_id,l_module_name,4);
		print_debug('l_wooi_data_rec.operation_status = '|| l_wooi_data_rec.operation_status,l_module_name,4);
		print_debug('l_wooi_data_rec.operation_sequence = '|| l_wooi_data_rec.operation_sequence,l_module_name,4);
		print_debug('l_wooi_data_rec.sug_to_sub_code = '|| l_wooi_data_rec.sug_to_sub_code,l_module_name,4);
		print_debug('l_wooi_data_rec.sug_to_locator_id = '|| l_wooi_data_rec.sug_to_locator_id,l_module_name,4);
	     END IF;

	     IF l_wooi_data_rec.operation_status = g_op_ins_stat_pending THEN
		-- Normally complete_operation_instance should not be called
		-- when operation instance is pending.
		-- It only occurs when complete_operation_instance is called
		-- from packing workbenches receiving TM call.
		-- In this case we raise an exception to by-pass all the logic below,
		-- and return a special x_error_code
		IF (l_debug = 1) THEN
		   print_debug('Operation instance pending.',l_module_name,4);
		END IF;
		raise_application_error(COMPLETE_PENDING_OP,'Complete a pending operation instance');
	      ELSIF l_wooi_data_rec.operation_status <> g_op_ins_stat_active THEN
		IF (l_debug = 1) THEN
		   print_debug('Invalid operation instance.',l_module_name,4);
		END IF;
		raise_application_error(INVALID_STATUS_FOR_OPERATION,'Invalid operation instance');
	     END IF;

	  END IF;


	  l_progress := 25;

         BEGIN
	    SELECT task_id, status
	      INTO l_wdt_task_id, l_wdt_status
	      FROM wms_dispatched_tasks
	      WHERE transaction_temp_id = p_source_task_id
	      AND task_type IN (g_wms_task_type_putaway, g_wms_task_type_inspect);

	 EXCEPTION
	    WHEN no_data_found THEN
	       IF (l_debug=1) THEN
		  print_debug('WDT does not exist for this MMTT.',l_module_name,4);
	       END IF;
	       RAISE FND_API.G_EXC_ERROR;

	 END;

	 l_progress := 30;

	 IF (l_debug=1) THEN
	    print_debug('l_wdt_task_id = '||l_wdt_task_id,l_module_name,4);
	    print_debug('l_wdt_status = '||l_wdt_status,l_module_name,4);
	 END IF;

	 IF l_wdt_status NOT IN (g_task_status_loaded, g_task_status_dispatched) THEN
	    IF (l_debug=1) THEN
	       print_debug('Invalid WDT status.' ,l_module_name,4);
	    END IF;
	    fnd_message.set_name('WMS', 'WMS_ATF_INVALID_TASK_STATUS');
	    fnd_msg_pub.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF; -- IF l_wdt_status NOT IN (g_task_status_loaded, g_task_status_dispatched)

       END IF;  -- IF p_activity_id = g_op_activity_inbound

       l_progress := 30;


       IF l_wdt_status = g_task_status_dispatched THEN


	  --This can happened for two operations today,
	  --1.	Inspect
	  --2.	Load

	  --NOTE: Today the status of WDT is going to be 'Dispatched' for load and inspect
	  --      (for drop it will be 'Loaded').
	  --      But for Outbound/Warehousing tasks or when we have Inbound
	  --      dispatched tasks then we CAN have a status of 'Active' for WDT records

	  IF (l_debug=1) THEN
	     print_debug('WDT status is dispatched.' ,l_module_name,4);
	  END IF;


	  IF p_operation_type_id = g_op_type_inspect THEN


	     IF (l_debug=1) THEN
		print_debug('Current operation is inspect.' ,l_module_name,4);
		print_debug('Set l_operation_type_id to inspect.' ,l_module_name,4);

		print_debug('Before calling wms_op_runtime_pvt_apis.archive_dispatched_tasks with following parameters' ,l_module_name,4);
		print_debug('p_task_id => '|| l_wdt_task_id,l_module_name,4);
		print_debug('p_source_task_id => '|| p_source_task_id,l_module_name,4);
		print_debug('p_activity_type_id => '|| p_activity_id,l_module_name,4);
	     END IF;

	     l_operation_type_id := g_op_type_inspect;

	     l_progress :=  40;

	     wms_op_runtime_pvt_apis.archive_dispatched_tasks
	       (
		x_return_status         => l_return_status
		, x_msg_count           => l_msg_count
		, x_msg_data            => l_msg_data
		, p_task_id             => l_wdt_task_id
		, p_source_task_id      => p_source_task_id
		, p_activity_type_id    => p_activity_id
		, p_op_plan_instance_id => NULL
      , p_op_plan_status      => NULL
		);

	     l_progress :=  50;

	     IF (l_debug=1) THEN
		print_debug('After calling wms_op_runtime_pvt_apis.archive_dispatched_tasks .' ,l_module_name,4);
		print_debug('x_return_status => '|| l_return_status,l_module_name,4);
		print_debug('x_msg_count => '|| l_msg_count,l_module_name,4);
		print_debug('x_msg_data => '|| l_msg_data,l_module_name,4);
	     END IF;


	     IF l_return_status <>FND_API.g_ret_sts_success THEN
		IF (l_debug=1) THEN
		   print_debug('wms_op_runtime_pvt_apis.archive_dispatched_tasks finished with error. l_return_status = ' || l_return_status,l_module_name,4);
		END IF;
		fnd_message.set_name('WMS', 'WMS_ATF_ARCHIVE_TASK_FAILURE');
		fnd_msg_pub.ADD;
		RAISE FND_API.G_EXC_ERROR;
	     END IF;

	   ELSIF p_operation_type_id IS NULL OR p_operation_type_id = g_op_type_load THEN
	     IF (l_debug=1) THEN
		print_debug('Current operation is load. Update WDT to loaded.' ,l_module_name,4);
	     END IF;


	     IF (l_debug=1) THEN
		print_debug('Set l_operation_type_id to load.' ,l_module_name,4);
	     END IF;

	     l_operation_type_id := g_op_type_load;


	     l_progress := 60;

	     UPDATE wms_dispatched_tasks
	       SET status = g_task_status_loaded,
	       loaded_time = Sysdate,
	       last_update_date = Sysdate,
	       last_updated_by = fnd_global.user_id
	       WHERE task_id = l_wdt_task_id;

	     l_progress := 70;

	   ELSE -- p_operation_type_id = g_op_type_inspect (not inspect or load or NULL)

	     IF (l_debug=1) THEN
		print_debug('Current operation ('|| p_operation_type_id ||') is not compatible with WDT status of dispatched.' ,l_module_name,4);
	     END IF;
	     fnd_message.set_name('WMS', 'WMS_ATF_INVALID_TASK_STATUS');
	     fnd_msg_pub.ADD;
	     RAISE FND_API.G_EXC_ERROR;

	  END IF; -- IF p_operation_type_id = g_op_type_inspect



	ELSIF l_wdt_status = g_task_status_loaded THEN
	  --This can happened for only for one operation today, i.e. 'Drop'
	  --Assumption here is that you always have a Load before a Drop, even for 'Single Step Drop'

	  IF (l_debug=1) THEN
	     print_debug('WDT status is loaded. Archive this WDT into WDTH.' ,l_module_name,4);
	     print_debug('Set l_operation_type_id to Drop.' ,l_module_name,4);
	  END IF;

	  l_operation_type_id := g_op_type_drop;

	  IF (l_debug=1) THEN

	     print_debug('Drop - Before calling wms_op_runtime_pvt_apis.archive_dispatched_tasks with following parameters' ,l_module_name,4);
	     print_debug('p_task_id => '|| l_wdt_task_id,l_module_name,4);
	     print_debug('p_source_task_id => '|| p_source_task_id,l_module_name,4);
	     print_debug('p_activity_type_id => '|| p_activity_id,l_module_name,4);
	  END IF;

	  l_progress :=  80;

	  wms_op_runtime_pvt_apis.archive_dispatched_tasks
	    (
	     x_return_status         => l_return_status
	     , x_msg_count           => l_msg_count
	     , x_msg_data            => l_msg_data
	     , p_task_id             => l_wdt_task_id
	     , p_source_task_id      => p_source_task_id
	     , p_activity_type_id    => p_activity_id
	     , p_op_plan_instance_id => NULL
        , p_op_plan_status      => NULL
	     );

	  l_progress :=  90;

	  IF (l_debug=1) THEN
	     print_debug('Drop - After calling wms_op_runtime_pvt_apis.archive_dispatched_tasks .' ,l_module_name,4);
	     print_debug('x_return_status => '|| l_return_status,l_module_name,4);
	     print_debug('x_msg_count => '|| l_msg_count,l_module_name,4);
	     print_debug('x_msg_data => '|| l_msg_data,l_module_name,4);
	  END IF;


	  IF l_return_status <>FND_API.g_ret_sts_success THEN
	     IF (l_debug=1) THEN
		print_debug('Drop - wms_op_runtime_pvt_apis.archive_dispatched_tasks finished with error. l_return_status = ' || l_return_status,l_module_name,4);
	     END IF;
	     fnd_message.set_name('WMS', 'WMS_ATF_ARCHIVE_TASK_FAILURE');
	     fnd_msg_pub.ADD;
	     RAISE FND_API.G_EXC_ERROR;
	  END IF;

	ELSE -- l_wdt_status = g_task_status_dispatched (not dispatched or loaded)

	  IF (l_debug=1) THEN
	     print_debug('Invalid WDT status.' ,l_module_name,4);
	  END IF;
	  fnd_message.set_name('WMS', 'WMS_ATF_INVALID_TASK_STATUS');
	  fnd_msg_pub.ADD;
	  RAISE FND_API.G_EXC_ERROR;


       END IF; -- IF l_wdt_status = g_task_status_dispatched

       -- Check operation plan stamped or not
       -- The assumption here is that we are looking at a pre-generated 11.5.9 MMTT record.
       -- This is possibly called either from user performing load, drop, or inspect operation.
       -- If 'Load', don't need to do anything to document records, simply return.

       -- If 'drop' or 'inspect', we need to update MOL and delete MMTT based on transaction type etc.
       -- This step basically becomes the last step of an operation plan.
       -- The 'Complete' inbound document handler should be able to handle this by passing 'p_last_operation_flag' = 'Y'.

       IF p_activity_id = g_op_activity_inbound THEN
	  IF (l_debug=1) THEN
	     print_debug('Inbound Activity.',l_module_name,4);
	  END IF;

	  IF l_mmtt_rec.operation_plan_id IS NULL THEN
	     IF (l_debug=1) THEN
		print_debug('Operation plan ID is null for this MMTT.',l_module_name,4);
	     END IF;

	     IF l_operation_type_id IN (g_op_type_drop, g_op_type_inspect) THEN

		IF (l_debug=1) THEN
		   print_debug('Current operation is DROP or INSPECT. Need to call COMPLETE document handler',l_module_name,4);
		   print_debug('Operation_plan_ID NULL - Before calling wms_op_inbound_pvt.complete with following parameters:',l_module_name,4);
		   print_debug('p_source_task_id => '|| p_source_task_id,l_module_name,4);
		   print_debug('p_document_rec.transaction_temp_id => '|| l_mmtt_rec.transaction_temp_id,l_module_name,4);
		   print_debug('p_operation_type_id => '|| l_operation_type_id,l_module_name,4);
		   print_debug('p_next_operation_type_id => '|| '',l_module_name,4);
		   print_debug('p_is_last_operation_flag => '|| 'Y',l_module_name,4);

		END IF;

		l_progress :=  100;

		wms_op_inbound_pvt.complete
		  (
		   x_return_status              => l_return_status
		   , x_msg_data                 => l_msg_data
		   , x_msg_count                => l_msg_count
		   , x_source_task_id           => l_new_mmtt_id
		   , x_error_code               => l_atf_error_code
		   , p_source_task_id           => p_source_task_id
		   , p_document_rec             => l_mmtt_rec
		   , p_operation_type_id        => l_operation_type_id
		   , p_next_operation_type_id   => NULL
		   , p_sug_to_sub_code		=> l_wooi_data_rec.sug_to_sub_code
		   , p_sug_to_locator_id	=> l_wooi_data_rec.sug_to_locator_id
		   , p_is_last_operation_flag   => 'Y'
		   );

		l_progress :=  102;

		IF (l_debug=1) THEN
		   print_debug('Inbound op plan null - After calling wms_op_inbound_pvt.complete. ', l_module_name,4);

		   print_debug('x_return_status => '||l_return_status, l_module_name,4);
		   print_debug('x_msg_data => '||l_msg_data, l_module_name,4);
		   print_debug('x_msg_count => '||l_msg_count, l_module_name,4);
		   print_debug('x_source_task_id => '||l_new_mmtt_id, l_module_name,4);
		   print_debug('x_error_code => '||l_atf_error_code, l_module_name,4);
		END IF;
      --bug 6924639
		 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          print_debug('Inbound op plan null - wms_op_inbound_pvt.complete finished with error. l_return_status = ' || l_return_status,l_module_name,4);
        END IF;

        fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          print_debug('Inbound op plan null - wms_op_inbound_pvt.complete finished with error. l_return_status = ' || l_return_status,l_module_name,4);
        END IF;

        fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
     --bug 6924639
      /*
		IF l_return_status <>FND_API.g_ret_sts_success THEN
		   IF (l_debug=1) THEN
		      print_debug('Inbound op plan null - wms_op_inbound_pvt.complete finished with error. l_return_status = ' || l_return_status,l_module_name,4);
		   END IF;

		   RAISE FND_API.G_EXC_ERROR;
		END IF;
		*/
	     END IF; -- IF l_operation_type_id IN (g_op_type_drop, g_op_type_inspect)
	     IF (l_debug=1) THEN
		print_debug(' Exit execution. Because operation plan does not exist, no need to proceed with ATF related code.', l_module_name,4);
		END IF;

	     RETURN;  -- Return because operation plan does not exist, no need to proceed with ATF related code

	  END IF; --  IF l_mmtt_rec.operation_plan_id IS NULL



       END IF;  -- IF p_activity_id = g_op_activity_inbound



       -- validate operation type on active operation instance
       -- against operation type passed in by the user

       IF l_operation_type_id <> l_wooi_data_rec.operation_type_id THEN
	  IF (l_debug = 1) THEN
	     print_debug('Operation type on operation instance : '||l_wooi_data_rec.operation_type_id||' does not match that passed in by user : '||l_operation_type_id, l_module_name,4);
	  END IF;
	  fnd_message.set_name('WMS', 'WMS_ATF_OPERATION_MISMATCH');
	  fnd_msg_pub.ADD;
 	  RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (l_debug=1) THEN
	  print_debug('Get MAX operation_sequence for the operation plan for detail ID: '||l_wooi_data_rec.operation_plan_detail_id,l_module_name,4);
       END IF;

       BEGIN
	  l_progress := 104;

	  SELECT MAX(wopd1.operation_sequence)
	    INTO l_last_op_sequence
	    FROM wms_op_plan_details wopd1
	    WHERE wopd1.operation_plan_id =
	    (SELECT wopd2.operation_plan_id
	     FROM wms_op_plan_details wopd2
	     WHERE wopd2.operation_plan_detail_id = l_wooi_data_rec.operation_plan_detail_id
	     );

	  l_progress := 106;

       EXCEPTION
	  WHEN OTHERS THEN
	     IF (l_debug=1) THEN
		print_debug('Exception when getting max operation_sequence.' ,l_module_name,4);
	     END IF;

	     RAISE FND_API.G_EXC_ERROR;
       END;


       IF (l_debug=1) THEN
	  print_debug('MAX operation_sequence (last step) is: '||l_last_op_sequence,l_module_name,4);
       END IF;


       -- Validate destination locator if this is not the last step of the plan
       IF p_activity_id = g_op_activity_inbound
	 AND l_operation_type_id = g_op_type_drop
	 AND l_wooi_data_rec.sug_to_locator_id IS NOT NULL
	   AND l_last_op_sequence <> l_wooi_data_rec.operation_sequence
	 THEN
	  IF (l_debug=1) THEN
	     print_debug('Inbound Activity and drop operation.',l_module_name,4);
	  END IF;

	  l_progress := 106.001;

	  SELECT
	    Nvl(lpn_controlled_flag, 2) -- 2 is non-lpn controlled
	    INTO l_lpn_controlled_flag
	    FROM mtl_secondary_inventories
	    WHERE secondary_inventory_name = Nvl(l_mmtt_rec.transfer_subinventory,
						 l_mmtt_rec.subinventory_code)
	    AND organization_id = l_mmtt_rec.organization_id;

	  l_progress := 106.002;

	  IF (l_debug=1) THEN
	     print_debug('LPN controlled code for sub '||Nvl(l_mmtt_rec.transfer_subinventory,l_mmtt_rec.subinventory_code)||' is '||l_lpn_controlled_flag,l_module_name,4);

	  END IF;

	  IF l_lpn_controlled_flag = 2 OR
	    (l_inbound_doc_rec.content_lpn_id IS NULL AND
	     l_inbound_doc_rec.transfer_lpn_id IS NULL) THEN
	     IF (l_debug=1) THEN
		print_debug('This sub is not LPN controlled, or user is dropping loose, this is an unforgivable error.',l_module_name,4);
	     END IF;

	     l_unforgivable_error_flag := 'Y';

	  END IF;



	  IF l_wooi_data_rec.sug_to_locator_id <> Nvl(l_mmtt_rec.transfer_to_location, l_mmtt_rec.locator_id)
	    AND l_unforgivable_error_flag <> 'Y' THEN

	     IF (l_debug=1) THEN
		print_debug('Destination locator on operation instance : '||l_wooi_data_rec.sug_to_locator_id || ' does not match that on MMTT.' ,l_module_name,4);
		print_debug('After user orverrides : '|| Nvl(l_mmtt_rec.transfer_to_location, l_mmtt_rec.locator_id)||' . Need to validate. ',l_module_name,4);
	     END IF;

	     l_progress := 108;

	     SELECT
	       loc_selection_criteria,
	       loc_selection_api_id
	       INTO
	       l_loc_sel_criteria_id,
	       l_loc_sel_api_id
	       FROM wms_op_plan_details
	       WHERE operation_plan_detail_id = l_wooi_data_rec.operation_plan_detail_id;
	     l_progress := 110;

	     IF (l_debug=1) THEN
		print_debug('l_loc_sel_criteria_id = '||l_loc_sel_criteria_id,l_module_name,4);
		print_debug('l_loc_sel_api_id = '||l_loc_sel_api_id,l_module_name,4);
	     END IF;

	     IF l_loc_sel_criteria_id = wms_globals.G_OP_DEST_PRE_SPECIFIED
	       OR l_loc_sel_criteria_id = wms_globals.G_OP_DEST_SYS_SUGGESTED
	       THEN

		IF (l_debug=1) THEN
		   print_debug('Unforgivable error: User overrides pre-specified or system-suggested locator, need to abort operation plan ',l_module_name,4);
		END IF;
		l_unforgivable_error_flag := 'Y';

	      ELSIF l_loc_sel_criteria_id = wms_globals.G_OP_DEST_API
		OR l_loc_sel_criteria_id = wms_globals.G_OP_DEST_CUSTOM_API
		THEN

		IF (l_debug=1) THEN
		   print_debug('User overrides API derived locator, need to validate',l_module_name,4);

		   print_debug('Before calling wms_atf_dest_locator.get_dest_locator with following parameters: ' , l_module_name, 4);
		   print_debug('p_mode => ' || 2, l_module_name, 4);
		   print_debug('p_task_id => ' || p_source_task_id, l_module_name, 4);
		   print_debug('p_activity_type_id => ' || p_activity_id, l_module_name, 4);
		   print_debug('p_hook_call_id => ' || l_loc_sel_api_id, l_module_name, 4);
		   print_debug('p_locator_id => ' || Nvl(l_mmtt_rec.transfer_to_location, l_mmtt_rec.locator_id), l_module_name, 4);
		   print_debug('p_item_id => ' || l_inbound_doc_rec.inventory_item_id, l_module_name, 4);
		END IF;

		wms_atf_dest_locator.get_dest_locator
		  (
		    x_return_status         => l_return_status
		    ,  x_msg_count          => l_msg_count
		    ,  x_msg_data           => l_msg_data
		    ,  x_locator_id         => l_locator_id_dummy
		    ,  x_subinventory_code  => l_subinventory_code_dummy
		    ,  x_zone_id            => l_zone_id_dummy
		    ,  x_loc_valid          => l_valid_flag
		    ,  p_mode               => 2
		    ,  p_task_id            => p_source_task_id
		    ,  p_activity_type_id   => p_activity_id
		    ,  p_hook_call_id       => l_loc_sel_api_id
		    ,  p_locator_id         => Nvl(l_inbound_doc_rec.transfer_to_location, l_inbound_doc_rec.locator_id)
		    ,  p_item_id            => l_inbound_doc_rec.inventory_item_id
		    ,  p_api_version        => NULL
		    ,  p_init_msg_list      => NULL
		    ,  p_commit             => NULL
		    );

		IF (l_debug = 1) THEN
		   print_debug('After calling wms_atf_dest_locator.get_dest_locator.' , l_module_name, 4);
		   print_debug('x_return_status => ' || l_return_status, l_module_name, 4);
		   print_debug('x_msg_count => ' || l_msg_count, l_module_name, 4);
		   print_debug('x_msg_data => ' || l_msg_data, l_module_name, 4);
		   print_debug('x_loc_valid => ' || l_valid_flag, l_module_name, 4);
		END IF;

		/*  When calling wms_atf_dest_locator.get_dest_locator for locator validation,
		we do not check for x_return_status, because it will return E if it cannot find any locator

		IF l_return_status <> g_ret_sts_success THEN
		   IF (l_debug = 1) THEN
		      print_debug('wms_atf_dest_locator.get_dest_locator failed:  l_return_status = '|| l_return_status, l_module_name, 4);
		   END IF;

		   RAISE FND_API.G_EXC_ERROR;

		END IF;
		  */
		IF l_valid_flag = 'E' THEN
		   IF (l_debug = 1) THEN
		      print_debug('Invalid locator according to API, need to abort operation plan '|| l_return_status, l_module_name, 4);
		   END IF;

		   l_unforgivable_error_flag := 'Y';

		END IF;

	      ELSE

		IF (l_debug=1) THEN
		   print_debug('Invalid locator determination method.',l_module_name,4);
		END IF;
		fnd_message.set_name('WMS', 'WMS_ATF_LOC_DET_NOT_DEFINED');
		fnd_msg_pub.ADD;
		RAISE FND_API.G_EXC_ERROR;

	     END IF;  -- IF NVL(l_loc_sel_criteria_id, 0) = wms_globals.G_OP_DEST_PRE_SPECIFIED

	  END IF; -- IF l_wooi_data_rec.sug_to_locator_id <> Nvl(l_mmtt_rec.transfer_to_location

	  IF l_unforgivable_error_flag = 'Y' THEN

	     IF (l_debug=1) THEN
		print_debug('Unforgivable error occured, abort operation plan, and complete the document execution',l_module_name,9);

		print_debug('Before calling WMS_ATF_RUNTIME_PUB_APIS.abort_operation_plan with following parameters : ',l_module_name,9);
		print_debug('p_source_task_id => '||p_source_task_id,l_module_name,9);
		print_debug('p_activity_id => '||p_activity_id,l_module_name,9);
	     END IF;

	     wms_atf_runtime_pub_apis.abort_operation_plan
	       (
		x_return_status      => l_return_status
		, x_msg_data         => l_msg_data
		, x_msg_count        => l_msg_count
		, x_error_code       => l_atf_error_code
		, p_source_task_id   => p_source_task_id
		, p_activity_type_id => p_activity_id);

	     IF (l_debug=1) THEN
		print_debug('After calling wms_atf_runtime_pub_apis.abort_operation_plan. ' ,l_module_name,9);
		print_debug('x_return_status => '||l_return_status,l_module_name,9);
		print_debug('x_msg_data => '||l_msg_data,l_module_name,9);
		print_debug('x_msg_count => '||l_msg_count,l_module_name,9);
		print_debug('x_error_code => '||l_atf_error_code,l_module_name,9);
	     END IF;

	     IF l_return_status <>FND_API.g_ret_sts_success THEN
		IF (l_debug=1) THEN
		   print_debug('wms_atf_runtime_pub_apis.abort_operation_plan finished with error. l_return_status = ' || l_return_status,l_module_name,4);
		END IF;

		RAISE FND_API.G_EXC_ERROR;
	     END IF;


	     IF (l_debug=1) THEN

		print_debug('Unforgivable error - Before calling wms_op_inbound_pvt.complete with following parameters:',l_module_name,4);
		print_debug('p_source_task_id => '|| p_source_task_id,l_module_name,4);
		print_debug('p_document_rec.transaction_temp_id => '|| l_mmtt_rec.transaction_temp_id,l_module_name,4);
		print_debug('p_operation_type_id => '|| l_operation_type_id,l_module_name,4);
		print_debug('p_next_operation_type_id => '|| '',l_module_name,4);
		print_debug('p_is_last_operation_flag => '|| 'Y',l_module_name,4);

	     END IF;


	     wms_op_inbound_pvt.complete
	       (
		x_return_status              => l_return_status
		, x_msg_data                 => l_msg_data
		, x_msg_count                => l_msg_count
		, x_source_task_id           => l_new_mmtt_id
		, x_error_code               => l_atf_error_code
		, p_source_task_id           => p_source_task_id
		, p_document_rec             => l_mmtt_rec
		, p_operation_type_id        => l_operation_type_id
		, p_next_operation_type_id   => NULL
		, p_sug_to_sub_code	     => l_wooi_data_rec.sug_to_sub_code
		, p_sug_to_locator_id	     => l_wooi_data_rec.sug_to_locator_id
		, p_is_last_operation_flag   => 'Y'
		);


	     IF (l_debug=1) THEN
		print_debug('Unforgivable Error - After calling wms_op_inbound_pvt.complete. ', l_module_name,4);

		print_debug('x_return_status => '||l_return_status, l_module_name,4);
		print_debug('x_msg_data => '||l_msg_data, l_module_name,4);
		print_debug('x_msg_count => '||l_msg_count, l_module_name,4);
		print_debug('x_source_task_id => '||l_new_mmtt_id, l_module_name,4);
		print_debug('x_error_code => '||l_atf_error_code, l_module_name,4);
	     END IF;
        --bug 6924639
         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
           print_debug('Unforgivable Error - wms_op_inbound_pvt.complete finished with error. l_return_status = ' || l_return_status,l_module_name,4);
        END IF;

        fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          print_debug('Unforgivable Error - wms_op_inbound_pvt.complete finished with error. l_return_status = ' || l_return_status,l_module_name,4);
        END IF;

        fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
      --bug 6924639
	     /*
	     IF l_return_status <>FND_API.g_ret_sts_success THEN
		IF (l_debug=1) THEN
		   print_debug('Unforgivable Error - wms_op_inbound_pvt.complete finished with error. l_return_status = ' || l_return_status,l_module_name,4);
		END IF;

		RAISE FND_API.G_EXC_ERROR;
	     END IF;
	     */

	     IF c_inbound_document_details%isopen THEN
		CLOSE c_inbound_document_details;
	     END IF;

	     IF c_wooi_data_rec%isopen THEN
		CLOSE c_wooi_data_rec;
	     END IF;

	     IF c_next_plan_detail%isopen THEN
		CLOSE c_next_plan_detail;
	     END IF;

	     RETURN;  -- return for unforgivable error

	  END IF;  -- IF l_unforgivable_error_flag = 'Y' THEN

	  l_progress:=115;


       END IF; --  IF p_activity_id = g_op_activity_inbound


       -- Update the current operation instance to complete
       -- And populate other data for a completed operation instance:
       -- 'load from' sub/loc for load operation
       -- 'drop to' sub/loc for drop operation
       --
       -- For a receiving delivery the drop to sub/loc are populated in subinventory_code and locator_id
       -- while receiving transfer and inventory transfer they are populated in transfer_subinventory and transfer_to_location
       --
       -- It is not nessary to populate equipment, employee data, which should
       -- has been done in activate_operation_instance

       l_wooi_rec.operation_instance_id := l_wooi_data_rec.operation_instance_id;
       l_wooi_rec.operation_status := g_op_ins_stat_completed;
       l_wooi_rec.complete_time := Sysdate;

       IF (l_debug=1) THEN
	  print_debug('Before updating WOOI: l_operation_type_id = ' ||l_operation_type_id,l_module_name,4);
       END if;

       IF l_operation_type_id = g_op_type_drop THEN
	  l_wooi_rec.to_subinventory_code := Nvl(l_mmtt_rec.transfer_subinventory, l_mmtt_rec.subinventory_code);
	  l_wooi_rec.to_locator_id := Nvl(l_mmtt_rec.transfer_to_location, l_mmtt_rec.locator_id);
	ELSIF l_operation_type_id IN (g_op_type_inspect, g_op_type_load) THEN
	  l_wooi_rec.from_subinventory_code := l_mmtt_rec.subinventory_code;
	  l_wooi_rec.from_locator_id := l_mmtt_rec.locator_id;
       END IF;  -- IF l_operation_type_id = g_op_type_drop T


       IF (l_debug=1) THEN
	  print_debug('Before calling wms_op_runtime_pvt_apis.update_operation_instance with following parameters: ',l_module_name,4);
	  print_debug('l_wooi_rec.operation_instance_id => '|| l_wooi_rec.operation_instance_id,l_module_name,4);
	  print_debug('l_wooi_rec.operation_status => '|| l_wooi_rec.operation_status,l_module_name,4);
	  print_debug('l_wooi_rec.complete_time => '|| To_char(l_wooi_rec.complete_time),l_module_name,4);
	  print_debug('l_wooi_rec.to_subinventory_code => '|| l_wooi_rec.to_subinventory_code,l_module_name,4);
	  print_debug('l_wooi_rec.to_locator_id => '|| l_wooi_rec.to_locator_id,l_module_name,4);
	  print_debug('l_wooi_rec.from_subinventory_code => '|| l_wooi_rec.from_subinventory_code,l_module_name,4);
	  print_debug('l_wooi_rec.from_locator_id => '|| l_wooi_rec.from_locator_id,l_module_name,4);
       END IF;

       l_progress := 120;

       wms_op_runtime_pvt_apis.update_operation_instance
	 (x_return_status     => l_return_status
	  , x_msg_count       => l_msg_count
	  , x_msg_data        => l_msg_data
	  , p_update_rec      => l_wooi_rec);

       l_progress := 130;

       IF (l_debug=1) THEN
	  print_debug('After calling wms_op_runtime_pvt_apis.update_operation_instance: ' ,l_module_name,4);
       	  print_debug('x_return_status => '|| l_return_status,l_module_name,4);
	  print_debug('x_msg_count => '|| l_msg_count,l_module_name,4);
	  print_debug('x_msg_data => '|| l_msg_data,l_module_name,4);
       END IF;

       IF l_return_status <>FND_API.g_ret_sts_success THEN
	  IF (l_debug=1) THEN
	     print_debug('wms_op_runtime_pvt_apis.update_operation_instance finished with error. l_return_status = ' || l_return_status,l_module_name,4);
	  END IF;

	  RAISE FND_API.G_EXC_ERROR;
       END IF;


       -- Handle situation where current operation is the last step in the plan.

       IF l_last_op_sequence = l_wooi_data_rec.operation_sequence  -- current operation sequence equals the max sequence in the plan
	 AND l_operation_type_id <> g_op_type_load -- and this is not the load operation for a crossdock
	 THEN

	  -- this is the last operation in the plan
	  IF (l_debug=1) THEN
	     print_debug('Current operation is the last step of the operation plan.',l_module_name,4);
	     print_debug('Before calling wms_op_runtime_pvt_apis.archive_dispatched_tasks with following parameters : ' , l_module_name,4);
	     print_debug('p_task_id             => '||'', l_module_name,4);
	     print_debug('p_source_task_id      => '||l_mmtt_rec.parent_line_id, l_module_name,4);
	     print_debug('p_activity_type_id    => '||p_activity_id, l_module_name,4);
	     print_debug('p_op_plan_instance_id => '||l_wooi_data_rec.op_plan_instance_id, l_module_name,4);
        print_debug('p_op_plan_status      => '||G_OP_INS_STAT_COMPLETED,l_module_name,4);
	  END IF;

	  -- Need to archive the parent MMTT record into WDTH
	  wms_op_runtime_pvt_apis.archive_dispatched_tasks
	    (
	     x_return_status          => l_return_status
	     , x_msg_count            => l_msg_count
	     , x_msg_data             => l_msg_data
	     , p_task_id              => NULL
	     , p_source_task_id       => l_mmtt_rec.parent_line_id
	     , p_activity_type_id     => p_activity_id
	     , p_op_plan_instance_id  => l_wooi_data_rec.op_plan_instance_id
        , p_op_plan_status       => G_OP_INS_STAT_COMPLETED
	     );

	  IF (l_debug=1) THEN
	     print_debug('After calling wms_op_runtime_pvt_apis.archive_dispatched_tasks.',l_module_name,4);
	     print_debug('x_return_status => '|| l_return_status,l_module_name,4);
	     print_debug('x_msg_count => '|| l_msg_count,l_module_name,4);
	     print_debug('x_msg_data => '|| l_msg_data,l_module_name,4);

	  END IF;

	  IF l_return_status <>FND_API.g_ret_sts_success THEN
	     IF (l_debug=1) THEN
		print_debug('Last operation: archive parent MMTT - wms_op_runtime_pvt_apis.archive_dispatched_tasks finished with error. l_return_status = ' || l_return_status,l_module_name,4);
	     END IF;
	     fnd_message.set_name('WMS', 'WMS_ATF_ARCHIVE_TASK_FAILURE');
	     fnd_msg_pub.ADD;
	     RAISE FND_API.G_EXC_ERROR;
	  END IF;

	  IF (l_debug=1) THEN
	     print_debug('Before calling wms_op_runtime_pvt_apis.complete_plan_instance with following parameters:', l_module_name,4);
	     print_debug('p_op_plan_instance_id => '||l_wooi_data_rec.op_plan_instance_id, l_module_name,4);
	  END IF;

	  -- Complete the operation plan instance
	  l_progress := 160;

	  wms_op_runtime_pvt_apis.complete_plan_instance
	    (x_return_status        => l_return_status,
	     x_msg_data             => l_msg_data,
	     x_msg_count            => l_msg_count,
	     p_op_plan_instance_id  => l_wooi_data_rec.op_plan_instance_id
	     );

	  l_progress := 170;

	  IF (l_debug=1) THEN
	     print_debug('After calling wms_op_runtime_pvt_apis.complete_plan_instance. ', l_module_name,4);

	     print_debug('x_return_status => '||l_return_status, l_module_name,4);
	     print_debug('x_msg_data => '||l_msg_data, l_module_name,4);
	     print_debug('x_msg_count => '||l_msg_count, l_module_name,4);
	  END IF;

	  IF l_return_status <>FND_API.g_ret_sts_success THEN
	     IF (l_debug=1) THEN
		print_debug('wms_op_runtime_pvt_apis.complete_plan_instance finished with error. l_return_status = ' || l_return_status,l_module_name,4);
	     END IF;

	     RAISE FND_API.G_EXC_ERROR;
	  END IF;



	  -- Complete the document

	  IF p_activity_id = g_op_activity_inbound THEN


	     IF (l_debug=1) THEN

		print_debug('Last operation in plan and inbound - Before calling wms_op_inbound_pvt.complete with following parameters:',l_module_name,4);
		print_debug('p_source_task_id => '|| p_source_task_id,l_module_name,4);
		print_debug('p_document_rec.transaction_temp_id => '|| l_mmtt_rec.transaction_temp_id,l_module_name,4);
		print_debug('p_operation_type_id => '|| l_operation_type_id,l_module_name,4);
		print_debug('p_next_operation_type_id => '|| '',l_module_name,4);
		print_debug('p_is_last_operation_flag => '|| 'Y',l_module_name,4);

	     END IF;

	     l_progress :=  180;

	     wms_op_inbound_pvt.complete
	       (
		x_return_status              => l_return_status
		, x_msg_data                 => l_msg_data
		, x_msg_count                => l_msg_count
		, x_source_task_id           => l_new_mmtt_id
		, x_error_code               => l_atf_error_code
		, p_source_task_id           => p_source_task_id
		, p_document_rec             => l_mmtt_rec
		, p_operation_type_id        => l_operation_type_id
		, p_next_operation_type_id   => NULL
		, p_sug_to_sub_code	     => l_wooi_data_rec.sug_to_sub_code
		, p_sug_to_locator_id	     => l_wooi_data_rec.sug_to_locator_id
		, p_is_last_operation_flag   => 'Y'
		);

	     l_progress :=  190;

	     IF (l_debug=1) THEN
		print_debug('Last operation in plan - After calling wms_op_inbound_pvt.complete. ', l_module_name,4);

		print_debug('x_return_status => '||l_return_status, l_module_name,4);
		print_debug('x_msg_data => '||l_msg_data, l_module_name,4);
		print_debug('x_msg_count => '||l_msg_count, l_module_name,4);
		print_debug('x_source_task_id => '||l_new_mmtt_id, l_module_name,4);
		print_debug('x_error_code => '||l_atf_error_code, l_module_name,4);
	     END IF;
        --bug 6924639
	     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          print_debug('Inbound op plan null - wms_op_inbound_pvt.complete finished with error. l_return_status = ' || l_return_status,l_module_name,4);
        END IF;

        fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          print_debug('Inbound op plan null - wms_op_inbound_pvt.complete finished with error. l_return_status = ' || l_return_status,l_module_name,4);
        END IF;

        fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
      --bug 6924639
        /*
	     IF l_return_status <>FND_API.g_ret_sts_success THEN
		IF (l_debug=1) THEN
		   print_debug('Last operation in plan - wms_op_inbound_pvt.complete finished with error. l_return_status = ' || l_return_status,l_module_name,4);
		END IF;

		RAISE FND_API.G_EXC_ERROR;
	     END IF;
	  */
	  END IF; -- IF p_activity_id = g_op_activity_inbound

	ELSE -- this is NOT the last operation in the plan
	  IF (l_debug=1) THEN
	     print_debug('Current operation is NOT the last step of the operation plan.',l_module_name,4);
	  END IF;

	  -- query operation plan detail for the next operation
	  OPEN c_next_plan_detail(l_wooi_data_rec.operation_plan_id,
				  l_wooi_data_rec.operation_sequence);

	  FETCH c_next_plan_detail INTO l_operation_plan_detail_rec;
	  IF c_next_plan_detail%notfound THEN
	     IF (l_debug=1) THEN
		print_debug('Current operation does not have a next operation.' ,l_module_name,4);
	     END IF;

	     fnd_message.set_name('WMS', 'WMS_ATF_NO_NEXT_OPERATION');
	     fnd_msg_pub.ADD;

	     RAISE FND_API.G_EXC_ERROR;

	  END IF;

	  CLOSE c_next_plan_detail;

	  -- construct operation instance record for the next operation in the plan

	  l_wooi_rec := NULL;

	  l_wooi_rec.operation_plan_detail_id := l_operation_plan_detail_rec.operation_plan_detail_id;
	  l_wooi_rec.op_plan_instance_id      := l_wooi_data_rec.op_plan_instance_id ;
	  l_wooi_rec.organization_id          := l_wooi_data_rec.organization_id;
	  l_wooi_rec.operation_status         := g_op_ins_stat_pending;
	  l_wooi_rec.operation_sequence       := l_operation_plan_detail_rec.operation_sequence; -- for crossdock, load and drop wooi will have the same sequence.
	  l_wooi_rec.is_in_inventory          := Nvl(l_operation_plan_detail_rec.is_in_inventory, 'N');
	  l_wooi_rec.from_subinventory_code   := Nvl(l_mmtt_rec.transfer_subinventory, l_mmtt_rec.subinventory_code);
	  l_wooi_rec.from_locator_id          := Nvl(l_mmtt_rec.transfer_to_location, l_mmtt_rec.locator_id);
	  l_wooi_rec.activity_type_id         := p_activity_id;
	  -- Need to set next operation_type properly.
	  -- Current operation 'Load' is always followed by a 'Drop'.
	  -- Otherwise, If WOPD definition for next step is 'crossdock', need to create a 'Load' operation instance.
	  -- Otherwise, use WOPD's operation type

	  IF l_operation_type_id = g_op_type_load THEN
	     l_wooi_rec.operation_type_id := g_op_type_drop;
	   ELSIF l_operation_plan_detail_rec.operation_type = g_op_type_crossdock THEN
	     l_wooi_rec.operation_type_id := g_op_type_load;
	   ELSE -- other operation type
	     l_wooi_rec.operation_type_id := l_operation_plan_detail_rec.operation_type;
	  END IF; -- IF l_operation_type_id = g_op_type_load


	  IF (l_debug=1) THEN
	     print_debug('l_wooi_rec.operation_plan_detail_id = '||l_wooi_rec.operation_plan_detail_id,l_module_name,4);
	     print_debug('l_wooi_rec.op_plan_instance_id = '||l_wooi_rec.op_plan_instance_id,l_module_name,4);
	     print_debug('l_wooi_rec.organization_id = '||l_wooi_rec.organization_id,l_module_name,4);
	     print_debug('l_wooi_rec.operation_status = '||l_wooi_rec.operation_status,l_module_name,4);
	     print_debug('l_wooi_rec.operation_sequence = '||l_wooi_rec.operation_sequence,l_module_name,4);
	     print_debug('l_wooi_rec.is_in_inventory = '||l_wooi_rec.is_in_inventory,l_module_name,4);
	     print_debug('l_wooi_rec.from_subinventory_code = '||l_wooi_rec.from_subinventory_code,l_module_name,4);
	     print_debug('l_wooi_rec.from_locator_id = '||l_wooi_rec.from_locator_id,l_module_name,4);
	     print_debug('l_wooi_rec.operation_type_id = '||l_wooi_rec.operation_type_id,l_module_name,4);
	     print_debug('l_wooi_rec.activity_type_id = '||l_wooi_rec.activity_type_id,l_module_name,4);
	     print_debug('l_operation_plan_detail_rec.subsequent_op_plan_id        ==>'||l_operation_plan_detail_rec.subsequent_op_plan_id,l_module_name,4);

	  END IF;

	  -- update document table

	  IF p_activity_id = g_op_activity_inbound THEN


	     IF (l_debug=1) THEN
		print_debug('NOT Last operation in plan and inbound - Before calling wms_op_inbound_pvt.complete with following parameters:',l_module_name,4);
		print_debug('p_source_task_id => '|| p_source_task_id,l_module_name,4);
		print_debug('p_document_rec.transaction_temp_id => '|| l_mmtt_rec.transaction_temp_id,l_module_name,4);
		print_debug('p_operation_type_id => '|| l_operation_type_id,l_module_name,4);
		print_debug('p_next_operation_type_id => '|| l_operation_plan_detail_rec.operation_type, l_module_name,4);
		print_debug('p_is_last_operation_flag => '|| 'N',l_module_name,4);
	     END IF;

	     l_progress :=  220;
	     /*{{
		 When completing the drop operation right before the crossdock operation
		 need to stamp subsequent outbound operation plan ID to the last task

	     }}
	       */

	     wms_op_inbound_pvt.complete
	       (
		x_return_status              => l_return_status
		, x_msg_data                 => l_msg_data
		, x_msg_count                => l_msg_count
		, x_source_task_id           => l_new_mmtt_id
		, x_error_code               => l_atf_error_code
		, p_source_task_id           => p_source_task_id
		, p_document_rec             => l_mmtt_rec
		, p_operation_type_id        => l_operation_type_id
		, p_next_operation_type_id   => l_operation_plan_detail_rec.operation_type
		, p_sug_to_sub_code	     => l_wooi_data_rec.sug_to_sub_code
		, p_sug_to_locator_id	     => l_wooi_data_rec.sug_to_locator_id
		, p_is_last_operation_flag   => 'N'
		, p_subsequent_op_plan_id    => l_operation_plan_detail_rec.subsequent_op_plan_id
		);

	     l_progress :=  230;

	     IF (l_debug=1) THEN
		print_debug('NOT Last operation in plan - After calling wms_op_inbound_pvt.complete. ', l_module_name,4);

		print_debug('x_return_status => '||l_return_status, l_module_name,4);
		print_debug('x_msg_data => '||l_msg_data, l_module_name,4);
		print_debug('x_msg_count => '||l_msg_count, l_module_name,4);
		print_debug('x_source_task_id => '||l_new_mmtt_id, l_module_name,4);
		print_debug('x_error_code => '||l_atf_error_code, l_module_name,4);
	     END IF;
	     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          print_debug('Inbound op plan null - wms_op_inbound_pvt.complete finished with error. l_return_status = ' || l_return_status,l_module_name,4);
        END IF;

        fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          print_debug('Inbound op plan null - wms_op_inbound_pvt.complete finished with error. l_return_status = ' || l_return_status,l_module_name,4);
        END IF;

        fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;


	  END IF; -- IF p_activity_id = g_op_activity_inbound

	  l_wooi_rec.source_task_id := Nvl(l_new_mmtt_id, p_source_task_id);

	  IF (l_debug=1) THEN
	     print_debug('l_wooi_rec.source_task_id = '||l_wooi_rec.source_task_id,l_module_name,4);
	  END IF;

	  -- create next operation instance

	  IF (l_debug=1) THEN
	     print_debug('Before calling wms_op_runtime_pvt_apis.insert_operation_instance:' ,l_module_name,4);
	  END IF;

	  wms_op_runtime_pvt_apis.insert_operation_instance
	    (
	     x_return_status => l_return_status        ,
	     x_msg_count     => x_msg_count            ,
	     x_msg_data      => x_msg_data             ,
	     p_insert_rec    => l_wooi_rec );

	  IF (l_debug=1) THEN
	     print_debug('After calling wms_op_runtime_pvt_apis.insert_operation_instance:' ,l_module_name,4);
	  END IF;

	  IF l_return_status <>FND_API.g_ret_sts_success THEN
	     IF (l_debug=1) THEN
		print_debug('wms_op_runtime_pvt_apis.insert_operation_instance finished with error. l_return_status = ' || l_return_status,l_module_name,4);
	     END IF;

	     RAISE FND_API.G_EXC_ERROR;
	  END IF;


       END IF;  -- IF l_last_op_sequence = l_wooi_data_rec.operation_sequence


       IF (l_debug = 1) THEN
	  print_debug('x_return_status ==> '||x_return_status,l_module_name,3);
	  print_debug('x_msg_data ==> '||x_msg_data,l_module_name,3);
	  print_debug('x_msg_count ==> '||x_msg_count,l_module_name,3);
	  print_debug('x_error_code ==> '||x_error_code,l_module_name,3);

	  print_debug(' Before Exiting . ',l_module_name,3);
       END IF;

  EXCEPTION

     WHEN fnd_api.g_exc_error THEN
	IF (l_debug=1) THEN
	   print_debug('Error (fnd_api.g_exc_error) occured at'||l_progress,l_module_name,1);
	END IF;
	x_return_status:=FND_API.G_RET_STS_ERROR;
	fnd_message.set_name('WMS', 'WMS_ATF_COMPLETE_OP_FAILURE');
	fnd_msg_pub.ADD;
--	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
	ROLLBACK TO sp_complete_oprtn_instance;

	IF (SQLCODE<-20000) THEN
	   IF (l_debug=1) THEN
              print_debug('This is a user defined exception',l_module_name,1);
	   END IF;

	   x_error_code:=-(SQLCODE+20000);
	END IF;


	IF c_inbound_document_details%isopen THEN
	   CLOSE c_inbound_document_details;
	END IF;

	IF c_wooi_data_rec%isopen THEN
	   CLOSE c_wooi_data_rec;
	END IF;

	IF c_next_plan_detail%isopen THEN
	   CLOSE c_next_plan_detail;
	END IF;


     WHEN fnd_api.g_exc_unexpected_error THEN

	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
	IF (l_debug=1) THEN
	   print_debug('Unexpected Error (fnd_api.g_exc_unexpected_error) occured at '||l_progress,l_module_name,3);
	END IF;
	IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	   fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
	END IF;
	--	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
	fnd_message.set_name('WMS', 'WMS_ATF_COMPLETE_OP_FAILURE');
	fnd_msg_pub.ADD;

	IF (SQLCODE<-20000) THEN
	   IF (l_debug=1) THEN
              print_debug('This is a user defined exception',l_module_name,1);
	   END IF;

	   x_error_code:=-(SQLCODE+20000);
	END IF;

	ROLLBACK TO sp_complete_oprtn_instance;

	IF c_inbound_document_details%isopen THEN
	   CLOSE c_inbound_document_details;
	END IF;

	IF c_wooi_data_rec%isopen THEN
	   CLOSE c_wooi_data_rec;
	END IF;

	IF c_next_plan_detail%isopen THEN
	   CLOSE c_next_plan_detail;
	END IF;

     WHEN OTHERS THEN

	x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
	IF (l_debug=1) THEN
	   print_debug('Other Error occured at '||l_progress,l_module_name,1);
	   IF SQLCODE IS NOT NULL AND SQLCODE >= -20000
	     THEN
	      print_debug('With SQL error : ' || SQLERRM(SQLCODE), l_module_name,1);
	   END IF;
	END IF;

	IF (SQLCODE<-20000) THEN
	   IF (l_debug=1) THEN
              print_debug('This is a user defined exception',l_module_name,1);
	   END IF;

	   x_error_code:=-(SQLCODE+20000);
	END IF;

	IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	   fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);
	END IF;
	--	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
	fnd_message.set_name('WMS', 'WMS_ATF_COMPLETE_OP_FAILURE');
	fnd_msg_pub.ADD;

	ROLLBACK TO sp_complete_oprtn_instance;

	IF c_inbound_document_details%isopen THEN
	   CLOSE c_inbound_document_details;
	END IF;

	IF c_wooi_data_rec%isopen THEN
	   CLOSE c_wooi_data_rec;
	END IF;

	IF c_next_plan_detail%isopen THEN
	   CLOSE c_next_plan_detail;
	END IF;

 END Complete_OPERATION_INSTANCE;

  /*
  *    Following is overloaded procedure
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
     p_revision              IN           VARCHAR2 DEFAULT NULL) IS

	l_crossdock_flag NUMBER;
	l_crossdock_prim_quantity NUMBER;
 BEGIN

    validate_operation
      (
       x_return_status         => x_return_status,
       x_msg_data              => x_msg_data,
       x_msg_count             => x_msg_count,
       x_error_code            => x_error_code,
       x_inspection_flag       => x_inspection_flag,
       x_load_flag             => x_load_flag,
       x_drop_flag             => x_drop_flag,
       x_crossdock_flag        => l_crossdock_flag,
       x_load_prim_quantity    => x_load_prim_quantity,
       x_drop_prim_quantity    => x_drop_prim_quantity,
       x_inspect_prim_quantity => x_inspect_prim_quantity,
       x_crossdock_prim_quantity => l_crossdock_prim_quantity,
       p_source_task_id        => p_source_task_id,
       p_move_order_line_id    => p_move_order_line_id,
       p_inventory_item_id     => p_inventory_item_id,
       p_LPN_ID                => p_lpn_id,
       p_activity_type_id      => p_activity_type_id,
       p_organization_id       => p_organization_id,
       p_lot_number            => p_lot_number,
       p_revision              => p_revision);


 END validate_operation;




/**  Validate_Operation
  *   <p>For a given criteria (LPN, Item or task), this API returns certain information,
  *      operation type in particular, about the current pending operation.
  *      Based on the return value, it is caller procedure' s responsibility to determine
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
  *  @param x_load_prim_quantity   -If LPN/Item or move order line is passed, sum of the primary quantity from
  *                                 the document table for those document records whose pending operation is
  *                                 'Load'.
  *  @param x_drop_prim_Quantity   -If LPN/Item or move order line is passed, sum of the primary quantity from
  *                                 the document table for those document records whose pending operation is
  *                                 'Drop'.
  *  @param x_inspect_prim_Quantity-If LPN/Item or move order line is passed, sum of the primary quantity from
  *                                 the document table for those document records whose pending operation is
  *                                 'Inspect'.
  *  @param p_source_task_id       -Identifier of the document record.
  *  @param p_move_order_line_id   -Move Order line Id that has to be validated.
  *  @param p_inventory_item_id    -Inventory Item Id that has to be validated.
  *  @param p_LPN_ID               -LPN id of the LPN that has to be validated.
  *  @param p_activity_type_id     -Lookup containing the Activity to be performed.
  *  @param p_organization_id      -Organization Id
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
     x_crossdock_prim_quantity OUT  NOCOPY  NUMBER ,
     p_source_task_id        IN           NUMBER ,
     p_move_order_line_id    IN           NUMBER ,
     p_inventory_item_id     IN           NUMBER ,
     p_LPN_ID                IN           NUMBER ,
     p_activity_type_id      IN           NUMBER ,
     p_organization_id       IN           NUMBER ,
     p_lot_number            IN           VARCHAR2 DEFAULT NULL,
     p_revision              IN           VARCHAR2 DEFAULT NULL) IS

    TYPE src_taskid_tab_type IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

    --3631633
    --Variable to hold license plate details
    l_subinventory_code WMS_LICENSE_PLATE_NUMBERS.SUBINVENTORY_CODE%TYPE;
    l_locator_id WMS_LICENSE_PLATE_NUMBERS.LOCATOR_ID%TYPE;

   CURSOR mol_details IS
      SELECT mol.inspection_status,
	SUM(NVL(mmtt.primary_quantity, wms_task_dispatch_gen.get_primary_quantity(mol.inventory_item_id,mol.organization_id,(mol.quantity - Nvl(mol.quantity_delivered,0)),mol.uom_code))) quantity,
	mmtt.operation_plan_id,mmtt.transaction_temp_id,mol.lpn_id,mol.inventory_item_id
      FROM mtl_txn_request_lines mol, mtl_material_transactions_temp mmtt
      WHERE       mol.line_id = mmtt.move_order_line_id(+)
      AND         mol.line_id = p_move_order_line_id
      AND mol.organization_id = p_organization_id
	AND mol.organization_id = mmtt.organization_id(+)
	AND mol.line_status <> 5  -- bug 4179991
      GROUP BY mol.inspection_status,mmtt.operation_plan_id,mmtt.transaction_temp_id, mol.lpn_id, mol.inventory_item_id;

   CURSOR lpn_details IS
      SELECT mol.inspection_status,mmtt.operation_plan_id,mmtt.transaction_temp_id
      FROM mtl_txn_request_lines mol, mtl_material_transactions_temp mmtt
      WHERE       mol.line_id = mmtt.move_order_line_id(+)
      AND          mol.lpn_id = p_lpn_id
	AND mol.organization_id = p_organization_id
	AND mol.line_status <> 5  -- bug 4179991
      AND mol.organization_id = mmtt.organization_id(+);

   CURSOR lpnitem_details IS
      SELECT mol.inspection_status,
	SUM(NVL(mmtt.primary_quantity,
		wms_task_dispatch_gen.get_primary_quantity(mol.inventory_item_id,mol.organization_id,(mol.quantity - Nvl(mol.quantity_delivered, 0)),mol.uom_code))) quantity,
	mol.lpn_id,mmtt.operation_plan_id,mmtt.transaction_temp_id,mol.lot_number,mol.revision
      FROM mtl_txn_request_lines mol, mtl_material_transactions_temp mmtt
      WHERE          mol.lpn_id = p_lpn_id
      AND mol.inventory_item_id = p_inventory_item_id
      AND           mol.line_id = mmtt.move_order_line_id(+)
      AND   mol.organization_id = p_organization_id
	AND   mol.organization_id = mmtt.organization_id(+)
	AND mol.line_status <> 5  -- bug 4179991
      GROUP BY mol.lpn_id,mol.inspection_status,mmtt.operation_plan_id,mmtt.transaction_temp_id,mol.lot_number,mol.revision;

   CURSOR c_operation_instance(v_source_task_id NUMBER) IS
      SELECT wopi.operation_type_id,
	wopd.operation_type wopd_op_type_id
	FROM wms_op_operation_instances wopi,
	wms_op_plan_details wopd
	WHERE  wopi.source_task_id = v_source_task_id
	AND wopi.operation_status  IN  (G_OP_INS_STAT_PENDING,G_OP_INS_STAT_ACTIVE)
	AND wopi.operation_plan_detail_id = wopd.operation_plan_detail_id
	ORDER BY wopi.operation_sequence DESC;

   CURSOR c_doc_detail IS
      SELECT mol.inspection_status,mmtt.operation_plan_id,
	NVL(mmtt.primary_quantity, wms_task_dispatch_gen.get_primary_quantity(mol.inventory_item_id,mol.organization_id,(mol.quantity - Nvl(mol.quantity_delivered,0)),mol.uom_code)) quantity
      FROM  mtl_material_transactions_temp mmtt , mtl_txn_request_lines mol
	WHERE mmtt.transaction_temp_id = p_source_task_id
	AND mol.line_status <> 5  -- bug 4179991
      AND   mmtt.move_order_line_id = mol.line_id;

   CURSOR c_quantity_details IS
    SELECT SUM(primary_transaction_quantity) quantity,lpn_id,inventory_item_id,lot_number,revision
    FROM mtl_onhand_quantities_detail
    WHERE lpn_id = p_lpn_id
    --3631633
    --Force to use the N5 index
    AND subinventory_code = l_subinventory_code
    AND locator_id = l_locator_id
    AND inventory_item_id =nvl(p_inventory_item_id,inventory_item_id)
    AND organization_id = p_organization_id
    GROUP BY lpn_id,inventory_item_id,lot_number,revision;


      l_debug              NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
      l_module_name        VARCHAR2(30) := 'Validate_Operation';
      l_progress           NUMBER       ;

      l_inspection_status  NUMBER:=-1;
      l_quantity           NUMBER:=0;
      l_lpn_id             NUMBER;
      l_operation_plan_id  NUMBER;
      l_source_task_id     NUMBER;
      l_operation_type_id  NUMBER;
      l_wopd_op_type_id    NUMBER;
      l_operation_seq      NUMBER;
      l_tab_index          PLS_INTEGER;

      l_src_taskid_tab     src_taskid_tab_type;
      l_inventory_item_id  NUMBER;

      l_mmtt_pri_qty       NUMBER := 0;

      l_lpn_context        NUMBER;

      l_doc_detail         c_doc_detail%ROWTYPE;

-- Increased lot size to 80 Char - Mercy Thomas - B4625329
      l_lot_number         VARCHAR2(80);
      l_revision           VARCHAR2(3);

      --Bug 4713903
      l_rev_control_code VARCHAR2(5):='FALSE';
      l_lot_control_code VARCHAR2(5):='FALSE';
      l_serial_control_code VARCHAR2(5):='FALSE';
      l_att NUMBER;
      l_qoh NUMBER;
      l_lpn_onhand NUMBER;
      l_return_msg VARCHAR2(2000);
      l_ret_val VARCHAR2(1);

 BEGIN
      IF (l_debug = 1) THEN
          print_DEBUG(' p_source_task_id     ==> '||p_source_task_id,l_module_name,3);
          print_DEBUG(' p_move_order_line_id ==> '||p_move_order_line_id,l_module_name,3);
          print_DEBUG(' p_inventory_item_id  ==> '||p_inventory_item_id ,l_module_name,3);
          print_DEBUG(' p_LPN_ID             ==> '||p_LPN_ID  ,l_module_name,3);
          print_DEBUG(' p_activity_type_id   ==> '||p_activity_type_id ,l_module_name,3);
          print_debug(' p_lot_number         ==> '||p_lot_number,l_module_name,3);
          print_debug(' p_revision           ==> '||p_revision,l_module_name,3);
      END IF;


      l_progress       :=10;
      /*Setting the default status of followinf output parameters*/
      x_return_status         := g_ret_sts_success;
      x_inspection_flag       := G_NO_INSPECTION;
      x_load_flag             := G_NO_LOAD;
      x_drop_flag             := G_NO_DROP;
      x_crossdock_flag        := g_no_crossdock;
      x_inspect_prim_quantity := 0;
      x_load_prim_quantity    := 0;
      x_drop_prim_quantity    := 0;
      x_crossdock_prim_quantity := 0;

      /*Validate inputs*/
      IF (p_source_task_id IS NULL) THEN
         IF (p_lpn_id IS NULL AND p_move_order_line_id IS NULL) THEN
            --x_error_code:=
            IF (l_debug=1) THEN
               print_debug('Invalid Argument set LPN: '||p_lpn_id||'Item :'||p_inventory_item_id||'MO Line Id'||p_move_order_line_id,l_module_name,1);
            END IF;
            RAISE_APPLICATION_ERROR(INVALID_INPUT,'Invalid Inputs passed');
         END IF;
      END IF;

      l_progress:=20;

       IF (p_activity_type_id=G_OP_ACTIVITY_INBOUND) THEN

         l_src_taskid_tab.DELETE;
         l_tab_index:=1;

         IF (p_source_task_id IS NULL) THEN

           /*Open the appropriate cursor based on the input*/
            IF (p_move_order_line_id IS NOT NULL) THEN

               l_progress:=30;
               OPEN mol_details;
               print_debug('MOL cursor openened',l_module_name,9);

            ELSIF (p_lpn_id IS NOT NULL AND p_inventory_item_id IS NOT NULL) THEN

               l_progress:=40;
               OPEN lpnitem_details;
               print_debug('LPN_ITEM cursor openened',l_module_name,9);

            ELSE

               l_progress:=50;
               OPEN lpn_details;
               print_debug('LPN cursor openened',l_module_name,9);

            END IF;

            LOOP
               IF (p_move_order_line_id IS NOT NULL) THEN

                    FETCH mol_details INTO l_inspection_status,l_quantity,l_operation_plan_id,l_source_task_id,l_lpn_id,l_inventory_item_id;
                    EXIT WHEN mol_details%NOTFOUND;

                    /*Validating to see if the values fetched tally with inputs*/
                    IF p_lpn_id IS NOT NULL AND p_lpn_id <>l_lpn_id THEN

                       IF l_debug=1 THEN
                         print_debug('LPN Value fetcched from MOLine: '||l_lpn_id,l_module_name,9);
                         print_debug('LPN Value passed as input'||p_lpn_id,l_module_name,9);
                       END IF;

                       RAISE_APPLICATION_ERROR(INVALID_INPUT,'Invalid Inputs passed');
                    END IF;

                    IF p_inventory_item_id IS NOT NULL AND p_inventory_item_id <>l_inventory_item_id  THEN
                       IF l_debug=1 THEN
                         print_debug('Item Value fetcched from MOLine: '||l_inventory_item_id,l_module_name,9);
                         print_debug('Item Value passed as input'||p_inventory_item_id,l_module_name,9);
                       END IF;

                       RAISE_APPLICATION_ERROR(INVALID_INPUT,'Invalid Inputs passed');
                    END IF;

                    l_progress:=60;

               ELSIF (p_lpn_id IS NOT NULL AND p_inventory_item_id IS NOT NULL) THEN

                    FETCH lpnitem_details INTO l_inspection_status,l_quantity,l_lpn_id,l_operation_plan_id,l_source_task_id,l_lot_number,l_revision;
                    EXIT WHEN lpnitem_details%NOTFOUND;

                    /*Checking if the Lot And REvision Controls passed match the input criteria*/
                    IF p_lot_number IS NOT NULL AND p_lot_number <> l_lot_number THEN
                       GOTO CONTINUE;
                    END IF;

                    IF p_revision IS NOT NULL AND p_revision <> l_revision THEN
                       GOTO CONTINUE;
                    END IF;
                    l_progress:=70;

               ELSE

                    FETCH lpn_details INTO l_inspection_status,l_operation_plan_id,l_source_task_id;
                    EXIT WHEN lpn_details%NOTFOUND;
                    l_progress:=80;

               END IF;

               IF (l_operation_plan_id IS NULL) THEN /*Case when no MMTTs exist*/
                    IF (l_inspection_status=1) THEN  /*Case when inspection required*/

                          IF (x_inspection_flag=G_NO_INSPECTION AND (x_load_flag<>G_NO_LOAD OR x_drop_flag<>G_NO_DROP)) THEN
                             x_inspection_flag:=G_PARTIAL_INSPECTION;
                          ELSE
                             x_inspection_flag:=G_FULL_INSPECTION;
                          END IF;
                          l_progress:=90;

                          IF (x_load_flag=G_FULL_LOAD) THEN
                             x_load_flag:=G_PARTIAL_LOAD;
                          END IF;
                          l_progress:=100;

                          x_inspect_prim_quantity:=x_inspect_prim_quantity+l_quantity;

                          IF (l_debug=1) THEN
                             print_debug('Inspection Flag set so far'||x_inspection_flag,l_module_name,9);
                             print_debug('Inspection Qty'||x_inspect_prim_quantity,l_module_name,9);
                          END IF;

                    ELSE
                          IF (x_load_flag=G_NO_LOAD AND (x_inspection_flag<>G_NO_INSPECTION OR x_drop_flag<>G_NO_DROP)) THEN
                             x_load_flag:=G_PARTIAL_LOAD;
                          ELSE
                             x_load_flag:=G_FULL_LOAD;
                          END IF;
                          l_progress:=110;

                          IF x_inspection_flag=G_FULL_INSPECTION THEN
                             x_inspection_flag:=G_PARTIAL_INSPECTION;
                          END IF;

                          x_load_prim_quantity:=x_load_prim_quantity+l_quantity;
                          l_progress:=120;

                          IF (l_debug=1) THEN
                             print_debug('Load Flag set so far'||x_inspection_flag,l_module_name,9);
                             print_debug('Load Qty'||x_inspect_prim_quantity,l_module_name,9);
                          END IF;


                    END IF;
                    l_quantity:=0;
               ELSE
                     l_src_taskid_tab(l_tab_index):= l_source_task_id;

                      l_tab_index:=l_tab_index+1;

                      l_progress:=130;

                      print_debug('Adding txn_temp_id to table'||l_source_task_id||l_tab_index,l_module_name,9);

               END IF;

            <<CONTINUE>>
               NULL;

            END LOOP;

            IF (mol_details%ISOPEN) THEN
               CLOSE mol_details;
            ELSIF (lpnitem_details%ISOPEN) THEN
               CLOSE lpnitem_details;
            ELSIF (lpn_details%ISOPEN) THEN
               CLOSE lpn_details;
            END IF;

            print_debug('Closed the open cursors',l_module_name,9);
            l_progress:=140;

            /*Incase none of the records are fetched from MTL_txn_request_lines for an inventory LPN
              returning with flag as FULL LOAD */

            IF p_lpn_id IS NOT NULL AND l_inspection_status=-1 THEN

               IF l_debug=1 THEN
                  print_debug('No move Order line exists for the LPN passed,returning status as Full Load reqd',l_module_name,9);
               END IF;

                /* We would return a full Load required incase a Move Order Line is not obtained.
                 * Today we do no validation of a possible data corruption from Inbound:
                 * i.e. those cases where the LPN is in Rcv and doesnt have a move order line
                 * associated.
                 * Also if an LPN has a item which has no Move Order associated with it then
                 * we would still return as Full Load required.
                 */
                   x_inspection_flag := G_NO_INSPECTION;
                   x_load_flag       := G_FULL_LOAD;
                   x_drop_flag       := G_NO_DROP;

                   /*Since there is no Move Order existing for this LPN we need to query MOQD for
                    * on hand quantities.This is done only when both LPN and Item are passed as
                    * we never return qty only if LPN is passed.
                    */
                  IF p_inventory_item_id IS NOT NULL THEN

		  --3631633
		  --Select license plate number details
		  IF p_lpn_id IS NOT NULL THEN
			select subinventory_code,locator_id into l_subinventory_code,l_locator_id from WMS_LICENSE_PLATE_NUMBERS where lpn_id=p_lpn_id;
		  END IF;

		    --Bug 4730925 BEGIN
		    --Get Item controls and then call quantity tree
		    SELECT Decode(revision_qty_control_code,1,'FALSE','TRUE'),
		      Decode(lot_control_code,1,'FALSE','TRUE'),
		      Decode(serial_number_control_code,1,'FALSE',6,'FALSE','TRUE')
		      INTO l_rev_control_code,
		      l_lot_control_code,
		      l_serial_control_code
		      FROM mtl_system_items_kfv
		      WHERE inventory_item_id = p_inventory_item_id
		      AND organization_id = p_organization_id;

		    IF p_lot_number IS NULL OR p_lot_number = '' THEN
			l_lot_control_code := 'FALSE';
		    END IF;
		    --Quantity Tree to get the availability
		    IF l_debug=1 THEN
                           print_debug(' p_lpn_id :'|| p_lpn_id ,l_module_name,9);
			   print_debug(' p_organization_id :'|| p_organization_id ,l_module_name,9);
			   print_debug(' p_inventory_item_id :'|| p_inventory_item_id ,l_module_name,9);
			   print_debug(' p_revision :'|| p_revision ,l_module_name,9);
			   print_debug(' l_locator_id :'|| l_locator_id ,l_module_name,9);
			   print_debug(' l_subinventory_code :'|| l_subinventory_code ,l_module_name,9);
			   print_debug(' p_lot_number :'|| p_lot_number ,l_module_name,9);
			   print_debug(' l_rev_control_code :'|| l_rev_control_code ,l_module_name,9);
			   print_debug(' l_serial_control_code :'|| l_serial_control_code ,l_module_name,9);
			   print_debug(' l_lot_control_code :'|| l_lot_control_code ,l_module_name,9);
                    END IF;

		    l_ret_val := inv_txn_validations.get_immediate_lpn_item_qty (
										 p_lpn_id => p_lpn_id,
										 p_organization_id => p_organization_id,
										 p_source_type_id => -9999,
										 p_inventory_item_id => p_inventory_item_id,
										 p_revision => p_revision,
										 p_locator_id => l_locator_id,
										 p_subinventory_code => l_subinventory_code,
										 p_lot_number => p_lot_number,
										 p_is_revision_control => l_rev_control_code,
										 p_is_serial_control => l_serial_control_code,
										 p_is_lot_control => l_lot_control_code,
										 x_transactable_qty => l_att,
										 x_qoh => l_qoh,
										 x_lpn_onhand => l_lpn_onhand,
										 x_return_msg => l_return_msg);

		    IF (l_ret_val = 'Y') THEN
		       x_load_prim_quantity := x_load_prim_quantity + l_att;
		     ELSE
		       x_load_prim_quantity := 0;
		    END IF;

		   /*
		   FOR l_quantity_details IN c_quantity_details LOOP

                      IF p_lot_number IS NOT NULL THEN

                         IF p_lot_number<>nvl(l_quantity_details.lot_number,'@#LOT#@') THEN
		            --If lot numbers are not matching skip this record
                            IF l_debug=1 THEN
                             print_debug('Lot mumber from MOQD'||l_quantity_details.lot_number,l_module_name,9);
                            END IF;
                            GOTO NEXT_RECORD;
                          END IF;
                        END IF;

                        --Checking if the revisions match
                        IF p_revision IS NOT NULL THEN
                          IF p_revision<>nvl(l_quantity_details.revision,'-') THEN
                             IF l_debug=1 THEN
                              print_debug('Revsions are differet,skipping record',l_module_name,9);
                             END IF;

                             GOTO NEXT_RECORD;
                           END IF;
                        END IF;

                        x_load_prim_quantity := x_load_prim_quantity+l_quantity_details.quantity;

                        IF l_debug=1 THEN
                           print_debug('Qty fetched'||l_quantity_details.quantity,l_module_name,9);
                           print_debug('Load Qty'||x_load_prim_quantity,l_module_name,9);
                        END IF;

                        <<NEXT_RECORD>>
                           NULL;
                   END LOOP;
		   Bug 4730925 END */
                  ELSE
                     x_load_prim_quantity :=0;


                  END IF;

                   IF l_debug=1 THEN
                    print_debug('Load Qty'||x_load_prim_quantity,l_module_name,9);
                   END IF;

                   x_inspect_prim_quantity :=0;
                   x_drop_prim_quantity    :=0;

            END IF;


         ELSE /*p_source_task_id not null*/

            IF l_debug=1 THEN
                     print_debug('Checking for non ATF case',l_module_name,9);
            END IF;

           OPEN c_doc_detail;

           FETCH c_doc_detail INTO l_doc_detail;

           IF c_doc_detail%NOTFOUND THEN

             IF l_debug=1 THEN
               print_debug('Invalid Input Doc Id passed',l_module_name,9);
             END IF;

             CLOSE c_doc_detail;

             RAISE_APPLICATION_ERROR(INVALID_INPUT,'Invalid Inputs passed');

           END IF;

           CLOSE c_doc_detail;

           IF l_doc_detail.operation_plan_id IS NULL THEN

             IF l_debug = 1 THEN
               print_debug('Operation Plan Id :Non-ATF Case',l_module_name,9);
               print_debug('Hence chekcing Move Order Line',l_module_name,9);
             END IF;

             IF (l_inspection_status=1) THEN  /*Case when inspection required*/

               IF (x_inspection_flag=G_NO_INSPECTION AND (x_load_flag<>G_NO_LOAD OR x_drop_flag<>G_NO_DROP)) THEN

                  x_inspection_flag:=G_PARTIAL_INSPECTION;

               ELSE

                  x_inspection_flag:=G_FULL_INSPECTION;

               END IF;

               l_progress:=201;

               IF (x_load_flag=G_FULL_LOAD) THEN
                  x_load_flag:=G_PARTIAL_LOAD;
               END IF;

               l_progress:=203;

               x_inspect_prim_quantity:=x_inspect_prim_quantity+l_doc_detail.quantity;

               IF (l_debug=1) THEN
                   print_debug('Inspection Flag set so far'||x_inspection_flag,l_module_name,9);
                   print_debug('Inspection Qty'||x_inspect_prim_quantity,l_module_name,9);
               END IF;

            ELSE
               IF (x_load_flag=G_NO_LOAD AND (x_inspection_flag<>G_NO_INSPECTION OR x_drop_flag<>G_NO_DROP)) THEN
                 x_load_flag:=G_PARTIAL_LOAD;

               ELSE

                 x_load_flag:=G_FULL_LOAD;

               END IF;
               l_progress:=205;

               IF x_inspection_flag=G_FULL_INSPECTION THEN
                  x_inspection_flag:=G_PARTIAL_INSPECTION;

               END IF;

               x_load_prim_quantity:=x_load_prim_quantity+l_doc_detail.quantity;
               l_progress:=120;

               IF (l_debug=1) THEN
                  print_debug('Load Flag set so far'||x_inspection_flag,l_module_name,9);
                  print_debug('Load Qty'||x_inspect_prim_quantity,l_module_name,9);
               END IF;


           END IF;

           ELSE

               l_src_taskid_tab(l_tab_index):=p_source_task_id;
               l_progress:=150;
                print_debug('Adding p_source_task_id to pl/sql table'||l_src_taskid_tab(l_tab_index),l_module_name,9);

           END IF;
         END IF;

         IF (l_src_taskid_tab.COUNT>0) THEN


              FOR j IN l_src_taskid_tab.FIRST..l_src_taskid_tab.LAST LOOP

                 OPEN c_operation_instance(l_src_taskid_tab(j));

                 FETCH c_operation_instance INTO l_operation_type_id, l_wopd_op_type_id;

                 IF (c_operation_instance%NOTFOUND) THEN

                    IF (l_debug=1) THEN
                       print_debug('No operation instance exitsting'||l_progress,l_module_name,9);
                       RAISE_APPLICATION_ERROR(OPERATION_INSTANCE_NOT_EXISTS,'Operation Instance does not exist for source_task id'||l_src_taskid_tab(j));
                    END IF;

                 END IF;

                 CLOSE c_operation_instance;

		 l_progress := 146;

		 IF (p_activity_type_id=G_OP_ACTIVITY_INBOUND) THEN

		    SELECT primary_quantity
		      INTO l_mmtt_pri_qty
		      FROM mtl_material_transactions_temp
		      WHERE transaction_temp_id = l_src_taskid_tab(j);

		 END IF;

       l_progress:=150;
		 IF (l_debug=1) THEN
		    print_debug('Operation Type Id in WOOI: '||l_operation_type_id,l_module_name,9);
		    print_debug('Operation Type Id in WOPD: '||l_wopd_op_type_id,l_module_name,9);
		    print_debug('l_mmtt_pri_qty = '||l_mmtt_pri_qty,l_module_name,9);
		 END IF;

                 IF (l_operation_type_id=G_OP_TYPE_INSPECT) THEN

		              x_inspect_prim_quantity := x_inspect_prim_quantity + l_mmtt_pri_qty;

                    IF (x_inspection_flag=G_NO_INSPECTION AND (x_load_flag<>G_NO_LOAD OR x_drop_flag<>G_NO_DROP)) THEN

                        x_inspection_flag:=G_PARTIAL_INSPECTION;
                    ELSE
                        x_inspection_flag:=G_FULL_INSPECTION;

                    END IF;
                    l_progress:=160;


                    IF (x_load_flag=G_FULL_LOAD) THEN
                       x_load_flag:=G_PARTIAL_LOAD;
                    END IF;


                    IF (x_drop_flag=G_FULL_DROP) THEN
                       x_drop_flag:=G_PARTIAL_DROP;
                    END IF;
                    l_progress:=170;

                    IF (l_debug=1) THEN
                        print_debug('Inspection Flag set so far'||x_inspection_flag,l_module_name,9);
                        print_debug('Load Flag set so far'||x_load_flag,l_module_name,9);
                        print_debug('Drop Flag set so far'||x_drop_flag,l_module_name,9);
                    END IF;


		  ELSIF (l_operation_type_id=G_OP_TYPE_LOAD) THEN

		    IF (l_wopd_op_type_id=g_op_type_crossdock) THEN
		       IF (x_crossdock_flag=g_partial_crossdock) OR (x_crossdock_flag = g_no_crossdock AND
			   (x_crossdock_prim_quantity < x_load_prim_quantity OR   -- there was some Non-crossdock load
			    x_crossdock_prim_quantity < x_drop_prim_quantity))THEN  -- there was some Non-crossdock drop
			  x_crossdock_flag := g_partial_crossdock;
			ELSE
			  x_crossdock_flag := g_full_crossdock;
		       END IF;  -- IF (x_crossdock_flag = g_no_crossdock

		       x_crossdock_prim_quantity := x_crossdock_prim_quantity + l_mmtt_pri_qty;

		     ELSE  --IF (l_wopd_op_type_id=g_op_type_crossdock)

		       IF (x_crossdock_flag = g_full_crossdock) THEN
			  x_crossdock_flag := g_partial_crossdock;
		       END IF; -- IF (x_crossdock_flag = g_full_crossdock)

		    END IF;  -- IF (l_wopd_op_type_id=g_op_type_crossdock)

                    x_load_prim_quantity := x_load_prim_quantity + l_mmtt_pri_qty;

                    IF (x_load_flag=G_NO_LOAD AND (x_inspection_flag<>G_NO_INSPECTION OR x_drop_flag<>G_NO_DROP)) THEN

                        x_load_flag:=G_PARTIAL_LOAD;
                    ELSE
                        x_load_flag:=G_FULL_LOAD;
                    END IF;

                    IF (x_inspection_flag=G_FULL_INSPECTION) THEN

                       x_inspection_flag:=G_PARTIAL_INSPECTION;
                    END IF;

                    IF (x_drop_flag=G_FULL_DROP) THEN

                       x_drop_flag:=G_PARTIAL_DROP;
                    END IF;
                    l_progress:=180;

                    IF (l_debug=1) THEN
                        print_debug('Inspection Flag set so far'||x_inspection_flag,l_module_name,9);
                        print_debug('Load Flag set so far'||x_load_flag,l_module_name,9);
                        print_debug('Drop Flag set so far'||x_drop_flag,l_module_name,9);
                    END IF;


		  ELSE

		    IF (l_wopd_op_type_id=g_op_type_crossdock) THEN
		       IF (x_crossdock_flag=g_partial_crossdock) OR(x_crossdock_flag = g_no_crossdock AND
			   (x_crossdock_prim_quantity < x_load_prim_quantity OR   -- there was some Non-crossdock load
			    x_crossdock_prim_quantity < x_drop_prim_quantity))THEN  -- there was some Non-crossdock drop
			  x_crossdock_flag := g_partial_crossdock;
			ELSE
			  x_crossdock_flag := g_full_crossdock;
		       END IF;  -- IF (x_crossdock_flag = g_no_crossdock

		       x_crossdock_prim_quantity := x_crossdock_prim_quantity + l_mmtt_pri_qty;

		     ELSE  --IF (l_wopd_op_type_id=g_op_type_crossdock)

		       IF (x_crossdock_flag = g_full_crossdock) THEN
			  x_crossdock_flag := g_partial_crossdock;
		       END IF; -- IF (x_crossdock_flag = g_full_crossdock)

		    END IF;  -- IF (l_wopd_op_type_id=g_op_type_crossdock)


		    x_drop_prim_quantity := x_drop_prim_quantity + l_mmtt_pri_qty;

                    IF (x_drop_flag=G_NO_DROP AND (x_inspection_flag<>G_NO_LOAD OR x_drop_flag<>G_NO_INSPECTION)) THEN

                         x_drop_flag:=G_PARTIAL_DROP;
                    ELSE
                         x_drop_flag:=G_FULL_DROP;
                    END IF;

                    IF (x_inspection_flag=G_FULL_INSPECTION) THEN

                        x_inspection_flag:=G_PARTIAL_INSPECTION;
                    END IF;

                    IF (x_load_flag=G_FULL_LOAD) THEN

                        x_load_flag:=G_PARTIAL_LOAD;
                    END IF;
                    l_progress:=190;

                    IF (l_debug=1) THEN
                        print_debug('Inspection Flag set so far'||x_inspection_flag,l_module_name,9);
                        print_debug('Load Flag set so far'||x_load_flag,l_module_name,9);
                        print_debug('Drop Flag set so far'||x_drop_flag,l_module_name,9);
                    END IF;

                 END IF;


              END LOOP;

              print_debug('Inspection Flag'||x_inspection_flag,l_module_name,9);
              print_debug('Load Flag'||x_load_flag,l_module_name,9);
              print_debug('Drop Flag'||x_drop_flag,l_module_name,9);
              print_debug('Crossdock Flag '||x_crossdock_flag,l_module_name,9);
              print_debug('Crossdock Primary Qty '||x_crossdock_prim_quantity,l_module_name,9);


         END IF;/*l_srctaskid_tab.COUNT>0*/

	 IF p_source_task_id IS NULL
	   AND p_move_order_line_id IS NULL
	     AND p_inventory_item_id IS NULL THEN

	    x_load_prim_quantity := 0;
	    x_drop_prim_quantity := 0;
	    x_inspect_prim_quantity := 0;

	 END IF;


         print_debug('Inspection Flag '||x_inspection_flag,l_module_name,9);
         print_debug('Load Flag '||x_load_flag,l_module_name,9);
         print_debug('Drop Flag '||x_drop_flag,l_module_name,9);
         print_debug('Load primary qty '||x_load_prim_quantity,l_module_name,9);
         print_debug('Drop primary qty '||x_drop_prim_quantity,l_module_name,9);
         print_debug('Inspect print_debug qty '||x_inspect_prim_quantity,l_module_name,9);
         print_debug('Crossdock Flag '||x_crossdock_flag,l_module_name,9);
         print_debug('Crossdock Primary Qty '||x_crossdock_prim_quantity,l_module_name,9);

       END IF;/*Activity Type =Inbound*/

 EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status:=g_ret_sts_error;
         IF mol_details%ISOPEN THEN
               CLOSE mol_details;
         END IF;
         IF lpnitem_details%ISOPEN THEN
               CLOSE lpnitem_details;
         END IF;
         IF lpn_details%ISOPEN THEN
               CLOSE lpn_details;
         END IF;
         IF c_operation_instance%ISOPEN THEN
                CLOSE c_operation_instance;
         END IF;

         IF c_doc_detail%ISOPEN THEN
             CLOSE c_doc_detail;
         END IF;

         IF c_quantity_details%ISOPEN THEN
            CLOSE c_quantity_details;
         END IF;

    /*Populate error message and error Code*/

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status:=g_ret_sts_unexp_error;

         IF (l_debug=1) THEN
          print_debug('Unexpected error'||SQLERRM||l_progress,l_module_name,1);
         END IF;

         IF mol_details%ISOPEN THEN
               CLOSE mol_details;
         END IF;
         IF lpnitem_details%ISOPEN THEN
               CLOSE lpnitem_details;
         END IF;
         IF lpn_details%ISOPEN THEN
               CLOSE lpn_details;
         END IF;

         IF c_doc_detail%ISOPEN THEN
             CLOSE c_doc_detail;
         END IF;

         IF c_quantity_details%ISOPEN THEN
          CLOSE c_quantity_details;
         END IF;

      WHEN OTHERS THEN
         IF (l_debug=1) THEN
           print_debug(SQLERRM||l_progress, l_module_name,1);
         END IF;

         IF (SQLCODE<-20000) THEN
            IF (l_debug=1) THEN
              print_debug('This is a user defined exception',l_module_name,1);
            END IF;

            x_error_code:=-(SQLCODE+20000);

            x_return_status:=g_ret_sts_error;


          ELSE

            x_return_status := g_ret_sts_unexp_error;

          END IF;


         IF mol_details%ISOPEN THEN
               CLOSE mol_details;
         END IF;
         IF lpnitem_details%ISOPEN THEN
               CLOSE lpnitem_details;
         END IF;
         IF (lpn_details%ISOPEN) THEN
               CLOSE lpn_details;
         END IF;

         IF c_operation_instance%ISOPEN THEN
               CLOSE c_operation_instance;
         END IF;

         IF c_doc_detail%ISOPEN THEN
             CLOSE c_doc_detail;
         END IF;

         IF c_quantity_details%ISOPEN THEN
            CLOSE c_quantity_details;
         END IF;


 END Validate_Operation;

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
      p_new_task_id_table IN           task_id_table_type) IS

   CURSOR inbound_document_details(v_task_id NUMBER) IS
      SELECT operation_plan_id
	, parent_line_id
	, transaction_quantity
	, primary_quantity
	, transaction_temp_id
	, inventory_item_id
	, organization_id
	, move_order_line_id
	FROM mtl_material_transactions_temp
	WHERE transaction_temp_id=v_task_id;


   CURSOR c_item_details(v_inventory_item_id NUMBER,v_organization_id NUMBER) IS
      SELECT nvl(lot_control_code,1)lot_control_code,nvl(serial_number_control_code,1) serial_number_control_code
	FROM mtl_system_items_b
	WHERE inventory_item_id = v_inventory_item_id
	AND organization_id   = v_organization_id;

   CURSOR wopi_cursor(v_source_task_id NUMBER) IS
      SELECT *
/*	  OP_PLAN_INSTANCE_ID,
          OPERATION_PLAN_ID,
          ACTIVITY_TYPE_ID,
          PLAN_TYPE_ID,
          SOURCE_TASK_ID,
          STATUS,
          PLAN_EXECUTION_START_DATE,
          PLAN_EXECUTION_END_DATE,
          ORGANIZATION_ID,
          ORIG_SOURCE_SUB_CODE,
          ORIG_SOURCE_LOC_ID,
          ORIG_DEST_SUB_CODE,
          ORIG_DEST_LOC_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
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
          ATTRIBUTE15 */
	FROM wms_op_plan_instances
	WHERE source_task_id = v_source_task_id;

   CURSOR wooi_cursor(v_op_plan_instance_id NUMBER) IS
      SELECT *
	/*
	OPERATION_INSTANCE_ID,
	OPERATION_PLAN_DETAIL_ID,
	OPERATION_SEQUENCE,
	OPERATION_TYPE_ID,
	OP_PLAN_INSTANCE_ID,
	OPERATION_STATUS,
	ACTIVITY_TYPE_ID,
	SOURCE_TASK_ID,
	ACTIVATE_TIME,
	COMPLETE_TIME,
	SUG_TO_SUB_CODE,
	SUG_TO_LOCATOR_ID,
	FROM_SUBINVENTORY_CODE,
	FROM_LOCATOR_ID,
	TO_SUBINVENTORY_CODE,
	TO_LOCATOR_ID,
	IS_IN_INVENTORY,
	ORGANIZATION_ID,
	EMPLOYEE_ID,
	EQUIPMENT_ID,
	CREATED_BY,
	LAST_UPDATE_DATE,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
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
	ATTRIBUTE15
	*/
	FROM wms_op_operation_instances
	WHERE op_plan_instance_id = v_op_plan_instance_id
       	ORDER BY operation_sequence DESC, operation_type_id DESC;
	--Bug 5749206. Added another order by "operation_type_id"

   CURSOR wdth_cursor(v_op_plan_instance_id NUMBER) IS
      SELECT task_id,
	transaction_id
	FROM wms_dispatched_tasks_history
       WHERE op_plan_instance_id = v_op_plan_instance_id;

   l_inbound_doc_child_rec           inbound_document_details%ROWTYPE;
   l_inbound_doc_parent_rec          inbound_document_details%ROWTYPE;
   l_inbound_doc_child_split_rec     inbound_document_details%ROWTYPE;
   l_inbound_doc_parent_split_rec    inbound_document_details%ROWTYPE;
   l_item_details_rec                c_item_details%ROWTYPE;
   l_wopi_orig_rec                   wopi_cursor%ROWTYPE;
   l_wopi_split_rec                  wopi_cursor%ROWTYPE;
   l_wooi_orig_rec                   wooi_cursor%ROWTYPE;
   l_wooi_new_rec                    wooi_cursor%ROWTYPE;
   i                                 INTEGER;
   l_n_return_status                 NUMBER;
   l_lot_trx_id                      NUMBER;
   l_proc_msg                        VARCHAR2(500);
   l_progress                        NUMBER;
   l_debug                           NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   l_module_name                     VARCHAR2(30) := 'Split_operation_instance';


   /* BEGIN GRACE11_02_2003 */
   l_next_task_id                    NUMBER;
   l_new_temp_id                     NUMBER;
   l_old_temp_id                     NUMBER;
   l_task_id                         NUMBER;
   l_wooi_index                      NUMBER;
   l_is_last_step_drop               BOOLEAN;
   l_num_wdts_for_mmtt               NUMBER;
   /* END GRACE11_02_2003 */
 BEGIN

      IF (l_debug = 1) THEN
          print_DEBUG(' p_source_task_id ==> '||p_source_task_id, l_module_name,3);
          print_DEBUG(' p_activity_type_id ==> '||p_activity_type_id, l_module_name,3);
      END IF;
      x_return_status  := g_ret_sts_success;

      l_progress := 10;
      SAVEPOINT split_op_instance_sp;

      IF (p_source_task_id IS NULL OR p_activity_type_id IS NULL) THEN
         IF (l_debug=1) THEN
            print_debug('Source task Id is null',l_module_name,1);
         END IF;
         /*Raise Invalid Arguement exception*/
         raise_application_error(INVALID_INPUT,'Invalid inputs passed'||p_source_task_id||' '||p_activity_type_id);
      END IF;

      /*Query document table(s) based on p_activity_id and P_Source_task_ID.*/
      IF (p_activity_type_id =G_OP_ACTIVITY_INBOUND) THEN
         /*Fetching document Record for Inbound:from MMTT*/
         IF (l_debug=1) THEN
            print_debug('Fetching document record for Inbound',l_module_name,9);
         END IF;

         OPEN inbound_document_details(p_source_task_id);
         FETCH inbound_document_details INTO l_inbound_doc_child_rec;

	 l_progress := 20;

         IF (inbound_document_details%NOTFOUND) THEN
            IF (l_debug=1) THEN
               print_debug('Invalid document',l_module_name,3);
            END IF;
            raise_application_error(INVALID_DOC_ID,'Invalid Document');
         END IF;

         CLOSE inbound_document_details;
      END IF;

      IF (l_inbound_doc_child_rec.operation_plan_id IS NULL OR l_inbound_doc_child_rec.parent_line_id IS NULL) THEN
         IF (l_debug=1) THEN
            print_debug('OP Plan ID or parent OP Plan ID is null and unforgivable error',l_module_name, 1);
         END IF;

	 --BUG 5075410: When splitting an MMTT, the WDT must also be
	 --split. If not, the split qty will not be loaded after the split
	 BEGIN
	    SELECT COUNT(1) INTO l_num_wdts_for_mmtt
	      FROM wms_dispatched_tasks
	      WHERE transaction_temp_id = l_inbound_doc_child_rec.transaction_temp_id;
	 EXCEPTION
	    WHEN OTHERS THEN
	       print_debug('Num of WDTs for orginal MMTT:'||l_num_wdts_for_mmtt,l_module_name,3);
	 END;

	 IF (l_debug = 1) THEN
	    print_debug('Num of WDTs for orginal MMTT:'||l_num_wdts_for_mmtt,l_module_name,3);
	 END IF;

	 IF (l_num_wdts_for_mmtt > 0) THEN
	    FOR i IN 1 ..  p_new_task_id_table.COUNT LOOP
	       OPEN inbound_document_details(p_new_task_id_table(i));
	       FETCH inbound_document_details INTO l_inbound_doc_child_split_rec;

	       IF (inbound_document_details%NOTFOUND) THEN
		  IF (l_debug=1) THEN
		     print_debug('Invalid document',l_module_name,3);
		  END IF;
		  raise_application_error(INVALID_DOC_ID,'Invalid Document');
	       END IF;

	       CLOSE inbound_document_details;

	       SELECT wms_dispatched_tasks_s.NEXTVAL
		 INTO   l_next_task_id
		 FROM   DUAL;

	       IF (l_debug = 1) THEN
		  print_debug('Inserting Duplicate WDT records using ID:'||l_next_task_id,l_module_name,3);
	       END IF;

	       INSERT INTO wms_dispatched_tasks
		 (
		  task_id
		  , transaction_temp_id
		  , organization_id
		  , user_task_type
		  , person_id
		  , effective_start_date
		  , effective_end_date
		  , equipment_id
		  , equipment_instance
		  , person_resource_id
		  , machine_resource_id
		  , status
		  , dispatched_time
		  , loaded_time
		  , drop_off_time
		  , last_update_date
		  , last_updated_by
		  , creation_date
		  , created_by
		  , last_update_login
		  , attribute_category
		  , attribute1
		  , attribute2
		  , attribute3
		  , attribute4
		  , attribute5
		  , attribute6
		  , attribute7
		  , attribute8
		  , attribute9
		  , attribute10
		  , attribute11
		  , attribute12
		  , attribute13
		  , attribute14
		  , attribute15
		  , task_type
		  , priority
		  , task_group_id
		  , device_id
		  , device_invoked
		  , device_request_id
		  , suggested_dest_subinventory
		  , suggested_dest_locator_id
		  , operation_plan_id
		  , move_order_line_id
		  , transfer_lpn_id
		  , op_plan_instance_id
		  , task_method
		 )
		 select l_next_task_id
		 , l_inbound_doc_child_split_rec.transaction_temp_id
		 , organization_id
		 , user_task_type
		 , person_id
		 , effective_start_date
		 , effective_end_date
		 , equipment_id
		 , equipment_instance
		 , person_resource_id
		 , machine_resource_id
		 , status
		 , dispatched_time
		 , loaded_time
		 , drop_off_time
		 , SYSDATE
		 , FND_GLOBAL.USER_ID
		 , creation_date
		 , created_by
		 , fnd_global.USER_ID
		 , attribute_category
		 , attribute1
		 , attribute2
		 , attribute3
		 , attribute4
		 , attribute5
		 , attribute6
		 , attribute7
		 , attribute8
		 , attribute9
		 , attribute10
		 , attribute11
		 , attribute12
		 , attribute13
		 , attribute14
		 , attribute15
		 , task_type
		 , priority
		 , task_group_id
		 , device_id
		 , device_invoked
		 , device_request_id
		 , suggested_dest_subinventory
		 , suggested_dest_locator_id
		 , operation_plan_id
		 , l_inbound_doc_child_split_rec.move_order_line_id
		 , transfer_lpn_id
		 , l_wopi_split_rec.op_plan_instance_id
		 , task_method
		 FROM wms_dispatched_tasks
		 WHERE transaction_temp_id = l_inbound_doc_child_rec.transaction_temp_id;
	    END LOOP;
	 END IF; --IF (l_num_wdts_for_mmtt > 1) THEN
	 --END BUG 5075410: When splitting an MMTT, the WDT must also be

	 RETURN;
         /*raise_application_error(INVALID_PLAN_ID, 'Invalid Plan');*/
         /*Raise user defined exception to populated error code*/
      END IF;

      /*Query MMTT based on parent_line_id*/
      OPEN inbound_document_details(l_inbound_doc_child_rec.parent_line_id);
      FETCH inbound_document_details INTO l_inbound_doc_parent_rec;
      l_progress := 30;

      IF (inbound_document_details%NOTFOUND) THEN
         IF (l_debug=1) THEN
            print_debug('Invalid document',l_module_name,3);
         END IF;
         raise_application_error(INVALID_DOC_ID,'Invalid Document');
      END IF;

      CLOSE inbound_document_details;

      /*update parent transaction quantity, PRIMARY_QUANTITY, create MTLT if appropriate*/
      l_inbound_doc_parent_rec.transaction_quantity := l_inbound_doc_child_rec.transaction_quantity;
      l_inbound_doc_parent_rec.primary_quantity := l_inbound_doc_child_rec.primary_quantity;

      l_progress := 40;
      --call MMTT table handler to update records in the table

      UPDATE mtl_material_transactions_temp
	SET transaction_quantity = l_inbound_doc_parent_rec.transaction_quantity,
	    primary_quantity = l_inbound_doc_child_rec.primary_quantity,
	    last_update_date = SYSDATE
	WHERE transaction_temp_id = l_inbound_doc_parent_rec.transaction_temp_id;
      l_progress := 50;


      /*If the item is a Lot Controlled Item, Query MTL_TRANSACTIONS_LOT_TEM (MTLT) based on
       P_Source_task_ID and poplate the PL/SQL record variable.*/
     /*Checking if the MTLTs exist for a Lot Controlled Item.If there are no records found throw an Invalid
      Document Error as the Assumption made is that rules will always create MTLTs for a lot controlled item
      --Have to finalise on this and will change if required*/

      OPEN c_item_details(l_inbound_doc_child_rec.INVENTORY_ITEM_ID,l_inbound_doc_child_rec.organization_id);

      FETCH c_item_details INTO l_item_details_rec;

      IF (c_item_details%NOTFOUND) THEN

         IF (l_debug=1) THEN
            print_debug('Item -Org combnation not found',l_module_name,1);
         END IF;
         RAISE FND_API.G_EXC_ERROR;

      END IF;

      CLOSE c_item_details;

      IF (l_item_details_rec.lot_control_code=2) THEN

          IF (l_debug=1) THEN
             print_debug('Item is lot Controlled',l_module_name,9);
          END IF;

	  --delete MTLT where transaction_temp_id = l_inbound_doc_parent_rec.transaction_temp_id
	  DELETE FROM mtl_transaction_lots_temp WHERE transaction_temp_id = l_inbound_doc_parent_rec.transaction_temp_id;

	  --create PL/SQL records for MTLT based on MTLT linked to l_inbound_doc_child_rec.transaction_temp_id



	     l_progress := 70;

	     INSERT INTO mtl_transaction_lots_temp
                (
                 transaction_temp_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , transaction_quantity
               , primary_quantity
               , secondary_quantity
               , secondary_unit_of_measure
               , lot_number
               , lot_expiration_date
               , serial_transaction_temp_id
               , description
               , vendor_name
               , supplier_lot_number
               , origination_date
               , date_code
               , grade_code
               , change_date
               , maturity_date
               , status_id
               , retest_date
               , age
               , item_size
               , color
               , volume
               , volume_uom
               , place_of_origin
               , best_by_date
               , LENGTH
               , length_uom
               , recycled_content
               , thickness
               , thickness_uom
               , width
               , width_uom
               , curl_wrinkle_fold
               , lot_attribute_category
               , c_attribute1
               , c_attribute2
               , c_attribute3
               , c_attribute4
               , c_attribute5
               , c_attribute6
               , c_attribute7
               , c_attribute8
               , c_attribute9
               , c_attribute10
               , c_attribute11
               , c_attribute12
               , c_attribute13
               , c_attribute14
               , c_attribute15
               , c_attribute16
               , c_attribute17
               , c_attribute18
               , c_attribute19
               , c_attribute20
               , d_attribute1
               , d_attribute2
               , d_attribute3
               , d_attribute4
               , d_attribute5
               , d_attribute6
               , d_attribute7
               , d_attribute8
               , d_attribute9
               , d_attribute10
               , n_attribute1
               , n_attribute2
               , n_attribute3
               , n_attribute4
               , n_attribute5
               , n_attribute6
               , n_attribute7
               , n_attribute8
               , n_attribute9
               , n_attribute10
               , vendor_id
               , territory_code
                )
	     SELECT l_inbound_doc_parent_rec.transaction_temp_id
	       , SYSDATE
               , FND_GLOBAL.USER_ID
               , SYSDATE
               , FND_GLOBAL.USER_ID
               , l_inbound_doc_parent_rec.transaction_quantity
               , l_inbound_doc_parent_rec.primary_quantity
               , secondary_quantity
               , secondary_unit_of_measure
               , lot_number
               , lot_expiration_date
               , serial_transaction_temp_id
               , description
               , vendor_name
               , supplier_lot_number
               , origination_date
               , date_code
               , grade_code
               , change_date
               , maturity_date
               , status_id
               , retest_date
               , age
               , item_size
               , color
               , volume
               , volume_uom
               , place_of_origin
               , best_by_date
               , LENGTH
               , length_uom
               , recycled_content
               , thickness
               , thickness_uom
               , width
               , width_uom
               , curl_wrinkle_fold
               , lot_attribute_category
               , c_attribute1
               , c_attribute2
               , c_attribute3
               , c_attribute4
               , c_attribute5
               , c_attribute6
               , c_attribute7
               , c_attribute8
               , c_attribute9
               , c_attribute10
               , c_attribute11
               , c_attribute12
               , c_attribute13
               , c_attribute14
               , c_attribute15
               , c_attribute16
               , c_attribute17
               , c_attribute18
               , c_attribute19
               , c_attribute20
               , d_attribute1
               , d_attribute2
               , d_attribute3
               , d_attribute4
               , d_attribute5
               , d_attribute6
               , d_attribute7
               , d_attribute8
               , d_attribute9
               , d_attribute10
               , n_attribute1
               , n_attribute2
               , n_attribute3
               , n_attribute4
               , n_attribute5
               , n_attribute6
               , n_attribute7
               , n_attribute8
               , n_attribute9
               , n_attribute10
               , vendor_id
               , territory_code
	       FROM mtl_transaction_lots_temp
	       WHERE transaction_temp_id = l_inbound_doc_child_rec.transaction_temp_id;

      END IF;

      /* BEGIN GRACE11-02-2003
       * If there is a WDT record for the original child MMTT, we need to
       * duplicate WDT for each new child MMTT records.
       */
      SELECT COUNT(1) INTO l_num_wdts_for_mmtt
	 FROM wms_dispatched_tasks
	 WHERE transaction_temp_id = l_inbound_doc_child_rec.transaction_temp_id;
      /* END: GRACE11-02-2003 */

      /* split parent MMTT, OP_Plan_Instance, OP_Operation_Instance.
       * Update parent_line_id for new child task records
       */
      FOR i IN 1 ..  p_new_task_id_table.COUNT LOOP
	 /*query document table based on new_p_task_id_table(i)*/
	 OPEN inbound_document_details(p_new_task_id_table(i));
	 FETCH inbound_document_details INTO l_inbound_doc_child_split_rec;
	 l_progress := 100;
	 IF (inbound_document_details%NOTFOUND) THEN
	    IF (l_debug=1) THEN
	       print_debug('Invalid document',l_module_name,3);
	    END IF;
	    raise_application_error(INVALID_DOC_ID,'Invalid Document');
	 END IF;

	 CLOSE inbound_document_details;

	 /*create parent document record for new task record*/

	 --copy l_inbound_doc_parent_rec into l_inbound_doc_parent_split_rec as new parent RECORD
	 l_inbound_doc_parent_split_rec := l_inbound_doc_parent_rec;
	 l_inbound_doc_parent_split_rec.transaction_quantity := l_inbound_doc_child_split_rec.transaction_quantity;
	 l_inbound_doc_parent_split_rec.primary_quantity := l_inbound_doc_child_split_rec.primary_quantity;
	 l_progress := 110;
	 --call MMTT(MTLT) table handlers to insert the new parent RECORD l_inbound_doc_parent_split_rec
	 inv_trx_util_pub.copy_insert_line_trx(
					       x_return_status            => x_return_status
					       , x_msg_data               => x_msg_data
					       , x_msg_count              => x_msg_count
					       , x_new_txn_temp_id        => l_inbound_doc_parent_split_rec.transaction_temp_id
					       , p_transaction_temp_id    => l_inbound_doc_parent_rec.transaction_temp_id
					       , p_txn_qty                => l_inbound_doc_parent_split_rec.transaction_quantity
                                               , p_primary_qty            => l_inbound_doc_parent_split_rec.primary_quantity
					       );

	 IF (x_return_status=g_ret_sts_error) THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (x_return_status<>g_ret_sts_success) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;


	 l_progress := 120;

	 l_inbound_doc_child_split_rec.parent_line_id := l_inbound_doc_parent_split_rec.transaction_temp_id;
	 --call MMTT table handlers to update the new child task record
	 UPDATE mtl_material_transactions_temp
	   SET parent_line_id = l_inbound_doc_parent_split_rec.transaction_temp_id
	   WHERE transaction_temp_id = l_inbound_doc_child_split_rec.transaction_temp_id;
	 l_progress := 140;

	 --TODO: create records for MTLT based on MTLT records linked to l_inbound_doc_child_split_rec.transaction_temp_id
	 --replace the transaction_temp_id with l_inbound_doc_parent_split_rec.transaction_temp_id, and insert into mtlt table


	 OPEN c_item_details(l_inbound_doc_child_split_rec.INVENTORY_ITEM_ID,l_inbound_doc_child_split_rec.organization_id);

	 FETCH c_item_details INTO l_item_details_rec;

	 IF (c_item_details%NOTFOUND) THEN

	    IF (l_debug=1) THEN
	       print_debug('Item -Org combnation not found',l_module_name,1);
	    END IF;
	    RAISE FND_API.G_EXC_ERROR;

	 END IF;

	 CLOSE c_item_details;

	 IF (l_item_details_rec.lot_control_code=2) THEN

	    IF (l_debug=1) THEN
	       print_debug('Item is lot Controlled',l_module_name,9);
	    END IF;

	    --create PL/SQL records for MTLT based on MTLT linked to l_inbound_doc_child_split_rec.transaction_temp_id


	    l_progress := 70;

	    INSERT INTO mtl_transaction_lots_temp
	      (
	       transaction_temp_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , transaction_quantity
               , primary_quantity
               , secondary_quantity
               , secondary_unit_of_measure
               , lot_number
               , lot_expiration_date
               , serial_transaction_temp_id
               , description
               , vendor_name
               , supplier_lot_number
               , origination_date
               , date_code
               , grade_code
               , change_date
               , maturity_date
               , status_id
               , retest_date
               , age
               , item_size
               , color
               , volume
               , volume_uom
               , place_of_origin
               , best_by_date
               , LENGTH
               , length_uom
               , recycled_content
               , thickness
               , thickness_uom
               , width
               , width_uom
               , curl_wrinkle_fold
               , lot_attribute_category
               , c_attribute1
               , c_attribute2
               , c_attribute3
               , c_attribute4
               , c_attribute5
               , c_attribute6
               , c_attribute7
               , c_attribute8
               , c_attribute9
               , c_attribute10
               , c_attribute11
               , c_attribute12
               , c_attribute13
               , c_attribute14
               , c_attribute15
               , c_attribute16
               , c_attribute17
               , c_attribute18
               , c_attribute19
               , c_attribute20
               , d_attribute1
               , d_attribute2
               , d_attribute3
               , d_attribute4
               , d_attribute5
               , d_attribute6
               , d_attribute7
               , d_attribute8
               , d_attribute9
               , d_attribute10
               , n_attribute1
               , n_attribute2
               , n_attribute3
               , n_attribute4
               , n_attribute5
               , n_attribute6
               , n_attribute7
               , n_attribute8
               , n_attribute9
               , n_attribute10
               , vendor_id
               , territory_code
                )
	      SELECT l_inbound_doc_parent_split_rec.transaction_temp_id
	       , SYSDATE
	       , FND_GLOBAL.USER_ID
               , SYSDATE
               , FND_GLOBAL.USER_ID
               , l_inbound_doc_parent_split_rec.transaction_quantity
               , l_inbound_doc_parent_split_rec.primary_quantity
               , secondary_quantity
               , secondary_unit_of_measure
               , lot_number
               , lot_expiration_date
               , serial_transaction_temp_id
               , description
               , vendor_name
               , supplier_lot_number
               , origination_date
               , date_code
               , grade_code
               , change_date
               , maturity_date
               , status_id
               , retest_date
               , age
               , item_size
               , color
               , volume
               , volume_uom
               , place_of_origin
               , best_by_date
               , LENGTH
               , length_uom
               , recycled_content
               , thickness
               , thickness_uom
               , width
               , width_uom
               , curl_wrinkle_fold
               , lot_attribute_category
               , c_attribute1
               , c_attribute2
               , c_attribute3
               , c_attribute4
               , c_attribute5
               , c_attribute6
               , c_attribute7
               , c_attribute8
               , c_attribute9
               , c_attribute10
               , c_attribute11
               , c_attribute12
               , c_attribute13
               , c_attribute14
               , c_attribute15
               , c_attribute16
               , c_attribute17
               , c_attribute18
               , c_attribute19
               , c_attribute20
               , d_attribute1
               , d_attribute2
               , d_attribute3
               , d_attribute4
               , d_attribute5
               , d_attribute6
               , d_attribute7
               , d_attribute8
               , d_attribute9
               , d_attribute10
               , n_attribute1
               , n_attribute2
               , n_attribute3
               , n_attribute4
               , n_attribute5
               , n_attribute6
               , n_attribute7
               , n_attribute8
               , n_attribute9
               , n_attribute10
               , vendor_id
               , territory_code
	      FROM mtl_transaction_lots_temp
	      WHERE transaction_temp_id = l_inbound_doc_child_split_rec.transaction_temp_id;

	 END IF;


	 /*create op_plan_instances record for new task record*/
	 OPEN wopi_cursor(l_inbound_doc_parent_rec.transaction_temp_id);
	 FETCH wopi_cursor INTO l_wopi_orig_rec;
	 l_progress := 150;
	 IF (wopi_cursor%NOTFOUND) THEN
	    -- NOTE: if no instances exist, the code below shouldn't be executed
	    raise_application_error(PLAN_INSTANCE_NOT_EXITS,'Operation plan instance not exists');
	 END IF;
	 -- TODO: what if multiple instances exist?
	 CLOSE wopi_cursor;

	 --populate l_wopi_split_rec based on l_wopi_orig_rec
	 l_wopi_split_rec := l_wopi_orig_rec;

	 --l_wopi_split_rec.operation_plan_id := l_inbound_doc_parent_rec.operation_plan_id;
	 l_wopi_split_rec.source_task_id := l_inbound_doc_parent_split_rec.transaction_temp_id;
	 --l_wopi_source_task_idsplit_rec.status := l_wopi_orig_rec.status;

	 l_progress := 160;
	 --use sequence to generate op_plan_instance_id
	 SELECT  WMS_OP_INSTANCE_S.NEXTVAL
	   INTO l_wopi_split_rec.op_plan_instance_id
	   FROM dual;
	 l_progress := 170;
	 --call wms_op_plan_instance table handler to insert l_wopi_split_rec INTO the table

	 l_progress := 180;
	 WMS_OP_RUNTIME_PVT_APIS.INSERT_PLAN_INSTANCE(
           x_return_status => x_return_status        ,
           x_msg_count     => x_msg_count            ,
           x_msg_data      => x_msg_data             ,
           p_insert_rec    => l_wopi_split_rec );

	 IF (x_return_status=g_ret_sts_error) THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (x_return_status<>g_ret_sts_success) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
	 /* BEGIN:  GRACE11-02-2003
	  * For each new WOPI that we are creating, we should copy all WDTH
	  * records from the the original WOPI, and link these new WDTH
	  * records to the new WOPI. The new WDTH will have same
	  * transaction_quantity as l_inbound_doc_parent_split_rec. And we need to
	  * update transaction_quantity of the original WDTHs to be same
	  * as l_inbound_doc_parent_rec.
	  */
	 l_progress := 185;

	  -- TODO: how is wms_dispatched_tasks_history linked to wms_op_plan_instances
	  UPDATE wms_dispatched_tasks_history
	    SET transaction_quantity = l_inbound_doc_parent_rec.transaction_quantity,
	        last_update_date = Sysdate    -- bug 3827507
	    WHERE op_plan_instance_id =l_wopi_orig_rec.op_plan_instance_id;

	  OPEN wdth_cursor(l_wopi_orig_rec.op_plan_instance_id);

	  -- loop through wdth with the same op_plan_instance_id -lezhang
	  LOOP
	     FETCH wdth_cursor INTO l_task_id, l_old_temp_id;
	     EXIT WHEN wdth_cursor%notfound;

	     SELECT wms_dispatched_tasks_s.NEXTVAL
	       INTO   l_next_task_id
	       FROM   DUAL;

	     SELECT mtl_material_transactions_s.NEXTVAL
	       INTO l_new_temp_id
	       FROM dual;
	     -- TODO: how to construct new WDTHs from those linked to orig WOPI
	     --INSERT INTO wms_dispatched_tasks_history ???;
	     INSERT INTO wms_dispatched_tasks_history
	       (
		task_id
		, transaction_id
		, organization_id
		, user_task_type
		, person_id
		, effective_start_date
		, effective_end_date
		, equipment_id
		, equipment_instance
		, person_resource_id
		, machine_resource_id
		, status
		, dispatched_time
		, loaded_time
		, drop_off_time
		, last_update_date
		, last_updated_by
		, creation_date
		, created_by
		, last_update_login
		, attribute_category
		, attribute1
		, attribute2
		, attribute3
		, attribute4
		, attribute5
		, attribute6
		, attribute7
		, attribute8
		, attribute9
		, attribute10
		, attribute11
		, attribute12
		, attribute13
		, attribute14
		, attribute15
		, task_type
		, priority
		, task_group_id
		, suggested_dest_subinventory
		, suggested_dest_locator_id
		, operation_plan_id
		, move_order_line_id
		, transfer_lpn_id
		, transaction_batch_id
		, transaction_batch_seq
		, inventory_item_id
		, revision
		, transaction_quantity
		, transaction_uom_code
		, source_subinventory_code
		, source_locator_id
		, dest_subinventory_code
	       , dest_locator_id
	       , lpn_id
	       , content_lpn_id
	       , is_parent
	       , parent_transaction_id
	       , transfer_organization_id
	       , source_document_id
	       , op_plan_instance_id
	       , task_method
	       , transaction_type_id
	       , transaction_source_type_id
	       , transaction_action_id
	       , transaction_temp_id  -- new link between wdth and we
	       )
	       SELECT l_next_task_id
	       , transaction_id
	       , organization_id
	       , user_task_type
	       , person_id
	       , effective_start_date
	       , effective_end_date
	       , equipment_id
	       , equipment_instance
	       , person_resource_id
	       , machine_resource_id
	       , status
	       , dispatched_time
	       , loaded_time
	       , drop_off_time
	       , SYSDATE
	       , fnd_global.user_id
	       , SYSDATE               -- bug 3827507
	       , fnd_global.user_id    -- bug 3827507
	       , fnd_global.user_id
	       , attribute_category
	       , attribute1
	       , attribute2
	       , attribute3
	       , attribute4
	       , attribute5
	       , attribute6
	       , attribute7
	       , attribute8
	       , attribute9
	       , attribute10
	       , attribute11
	       , attribute12
	       , attribute13
	       , attribute14
	       , attribute15
	       , task_type
	       , priority
	       , task_group_id
	       , suggested_dest_subinventory
	       , suggested_dest_locator_id
	       , operation_plan_id
	       , l_inbound_doc_child_split_rec.move_order_line_id
	       , transfer_lpn_id
	       , transaction_batch_id
	       , transaction_batch_seq
	       , inventory_item_id
	       , revision
	       , l_inbound_doc_parent_split_rec.transaction_quantity
	       , transaction_uom_code
	       , source_subinventory_code
	       , source_locator_id
	       , dest_subinventory_code
	       , dest_locator_id
	       , lpn_id
	       , content_lpn_id
	       , is_parent
	       , l_inbound_doc_parent_split_rec.transaction_temp_id
	       , transfer_organization_id
	       , source_document_id
	       , l_wopi_split_rec.op_plan_instance_id
	       , task_method
	       , transaction_type_id
	       , transaction_source_type_id
	       , transaction_action_id
	       , l_new_temp_id   -- new value to link wdth and we -- lezhang
	       FROM   wms_dispatched_tasks_history
	       WHERE  task_id = l_task_id;



	     INSERT INTO wms_exceptions
	       (
		task_id
		, sequence_number
		, organization_id
		, inventory_item_id
		, person_id
		, effective_start_date
		, effective_end_date
		, inventory_location_id
		, reason_id
		, discrepancy_type
		, archive_flag
		, subinventory_code
		, lot_number
		, revision
		, last_update_date
		, last_updated_by
		, creation_date
		, created_by
		, last_update_login
		, attribute_category
		, attribute1
		, attribute2
		, attribute3
		, attribute4
		, attribute5
		, attribute6
		, attribute7
		, attribute8
		, attribute9
		, attribute10
		, attribute11
		, attribute12
		, attribute13
		, attribute14
		, attribute15
		, transaction_header_id
		, wms_task_type
		, wf_item_key
		, lpn_id
		)
	       SELECT
	       l_new_temp_id -- new value to link wdth and we -- lezhang
	       , sequence_number
	       , organization_id
	       , inventory_item_id
	       , person_id
	       , effective_start_date
	       , effective_end_date
	       , inventory_location_id
	       , reason_id
	       , discrepancy_type
	       , archive_flag
	       , subinventory_code
	       , lot_number
	       , revision
	       , last_update_date
	       , last_updated_by
	       , creation_date
	       , created_by
	       , last_update_login
	       , attribute_category
	       , attribute1
	       , attribute2
	       , attribute3
	       , attribute4
	       , attribute5
	       , attribute6
	       , attribute7
	       , attribute8
	       , attribute9
	       , attribute10
	       , attribute11
	       , attribute12
	       , attribute13
	       , attribute14
	       , attribute15
	       , transaction_header_id
	       , wms_task_type
	       , wf_item_key
	       , lpn_id
	       FROM wms_exceptions
	       WHERE task_id = l_old_temp_id;

	  END LOOP;

	  CLOSE wdth_cursor;

	  -- END: GRACE11-02-2003
	  l_progress := 190;



	 /*create op_operation_instances record for new task record*/
	 -- NOTE: here assume that it is ok if no operation instances exist
	 OPEN wooi_cursor(l_wopi_orig_rec.op_plan_instance_id);
	 l_wooi_index := 0;
	 l_is_last_step_drop := FALSE;
	 LOOP
	    FETCH wooi_cursor INTO l_wooi_orig_rec;
	    l_progress := 200;
	    EXIT WHEN wooi_cursor%NOTFOUND;
	    --populate l_wooi_new_rec based on l_wooi_orig_rec
	    l_wooi_index := l_wooi_index + 1;
	    l_wooi_new_rec := l_wooi_orig_rec;

	    /* BEGIN GRACE11_02_2003, note that 'ORDER BY operation_sequence DESC' is added to the cursor definition
	     *  Now we update wooi.source_task_id if wooi.status =
	     *  'Pending'. We need to change this to: update
	     *  wooi.source_task_id for the last wooi, if the last step is
	     *  load; and update wooi.source_task_id for the last TWO wooi
	     *  records, if the last step is drop.
	     * IF (l_wooi_orig_rec.operation_status = G_OP_INS_STAT_PENDING) THEN
	     *   l_wooi_new_rec.source_task_id := p_new_task_id_table(i);
	     * END IF;
	     */
	    IF (l_wooi_index = 1) THEN
	       IF (l_wooi_orig_rec.OPERATION_TYPE_ID = 2) THEN
		  l_is_last_step_drop := TRUE;
	       END IF;
	       IF (l_wooi_orig_rec.OPERATION_TYPE_ID = 1 OR l_wooi_orig_rec.OPERATION_TYPE_ID = 2 OR
              l_wooi_orig_rec.operation_type_id =G_OP_TYPE_INSPECT ) THEN
		  l_wooi_new_rec.source_task_id := p_new_task_id_table(i);
	       END IF;
	    END IF;

	    IF (l_wooi_index = 2) THEN
	       IF (l_is_last_step_drop = TRUE) THEN
		  l_wooi_new_rec.source_task_id := p_new_task_id_table(i);
	       END IF;
	    END IF;
	    /* END GRACE11_02_2003 */

	    l_wooi_new_rec.op_plan_instance_id := l_wopi_split_rec.op_plan_instance_id;
	    l_progress := 210;
	    --Call wms_op_operation_instances table handler to insert the record
	    SELECT wms_op_instance_s.NEXTVAL
	      INTO l_wooi_new_rec.operation_instance_id
	      FROM dual;
	    l_progress := 220;

	    l_progress := 230;
	    WMS_OP_RUNTIME_PVT_APIS.insert_operation_instance
	      ( x_return_status => x_return_status,
		x_msg_count     => x_msg_count,
		x_msg_data      => x_msg_data,
		p_insert_rec    => l_wooi_new_rec
		);
	    l_progress := 240;

	    IF (l_debug=1) THEN
	       print_debug('Return Status from table handler',l_module_name,9);
	    END IF;

	    IF (x_return_status=g_ret_sts_error) THEN
	       RAISE FND_API.G_EXC_ERROR;
	     ELSIF (x_return_status<>g_ret_sts_success) THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;

	 END LOOP;
	 CLOSE wooi_cursor;

	 /* BEGIN GRACE11-02-2003
	  * If there is a WDT record for the original child MMTT, we need to
	  * duplicate WDT for each new child MMTT records.
	  */
	 IF (l_num_wdts_for_mmtt > 0) THEN
	    -- TODO: how to duplicate WDT of original child MMTT (l_inbound_doc_child_rec)???
	    --INSERT INTO wms_dispatched_tasks ???;
	    SELECT wms_dispatched_tasks_s.NEXTVAL
	      INTO   l_next_task_id
	      FROM   DUAL;

	    INSERT INTO wms_dispatched_tasks
	      (
	       task_id
	       , transaction_temp_id
	       , organization_id
	       , user_task_type
	       , person_id
	       , effective_start_date
	       , effective_end_date
	       , equipment_id
	       , equipment_instance
	       , person_resource_id
	       , machine_resource_id
	       , status
	       , dispatched_time
	       , loaded_time
	       , drop_off_time
	       , last_update_date
	       , last_updated_by
	       , creation_date
	       , created_by
	       , last_update_login
	       , attribute_category
	       , attribute1
	       , attribute2
	       , attribute3
	       , attribute4
	       , attribute5
	       , attribute6
	       , attribute7
	       , attribute8
	       , attribute9
	       , attribute10
	       , attribute11
	       , attribute12
	       , attribute13
	       , attribute14
	       , attribute15
	       , task_type
	       , priority
	       , task_group_id
	       , device_id
	       , device_invoked
	       , device_request_id
	       , suggested_dest_subinventory
	      , suggested_dest_locator_id
	      , operation_plan_id
	      , move_order_line_id
	      , transfer_lpn_id
	      , op_plan_instance_id
	      , task_method
	      )
	      select l_next_task_id
	      , l_inbound_doc_child_split_rec.transaction_temp_id
	      , organization_id
	      , user_task_type
	      , person_id
	      , effective_start_date
	      , effective_end_date
	      , equipment_id
	      , equipment_instance
	      , person_resource_id
	      , machine_resource_id
	      , status
	      , dispatched_time
	      , loaded_time
	      , drop_off_time
	      , SYSDATE
	      , FND_GLOBAL.USER_ID
	      , creation_date
	      , created_by
	      , fnd_global.USER_ID
	      , attribute_category
	      , attribute1
	      , attribute2
	      , attribute3
	      , attribute4
	      , attribute5
	      , attribute6
	      , attribute7
	      , attribute8
	      , attribute9
	      , attribute10
	      , attribute11
	      , attribute12
	      , attribute13
	      , attribute14
	      , attribute15
	      , task_type
	      , priority
	      , task_group_id
	      , device_id
	      , device_invoked
	      , device_request_id
	      , suggested_dest_subinventory
	      , suggested_dest_locator_id
	      , operation_plan_id
	      , l_inbound_doc_child_split_rec.move_order_line_id
	      , transfer_lpn_id
	      , l_wopi_split_rec.op_plan_instance_id
	      , task_method
	      FROM wms_dispatched_tasks
	      WHERE transaction_temp_id = l_inbound_doc_child_rec.transaction_temp_id;



	 END IF;
	 /* END: GRACE11-02-2003 */

      END LOOP;
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF (l_debug=1) THEN
	  print_debug('Error (fnd_api.g_exc_error) occured at'||l_progress,l_module_name,1);
       END IF;

       IF (inbound_document_details%ISOPEN) THEN
	  CLOSE inbound_document_details;
       END IF;

       IF (wopi_cursor%ISOPEN) THEN
	  CLOSE wopi_cursor;
       END IF;

       IF (wooi_cursor%ISOPEN) THEN
	  CLOSE wooi_cursor;
       END IF;

       IF (wdth_cursor%isopen) THEN
	  CLOSE wdth_cursor;
       END IF;

       ROLLBACK TO split_op_instance_sp;

       x_return_status:=g_ret_sts_error;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF (l_debug=1) THEN
	  print_debug('Unexpected Error (fnd_api.g_exc_unexpected_error) occured at '||l_progress,l_module_name,1);
	  --print_debug('UnExpected Error: '||SQLERRM,l_module_name,1);
       END IF;

       IF (inbound_document_details%ISOPEN) THEN
	  CLOSE inbound_document_details;
       END IF;

       IF (wopi_cursor%ISOPEN) THEN
             CLOSE wopi_cursor;
       END IF;

       IF (wooi_cursor%ISOPEN) THEN
	  CLOSE wooi_cursor;
       END IF;

       ROLLBACK TO split_op_instance_sp;

       x_return_status:=g_ret_sts_unexp_error;

    WHEN OTHERS THEN
       print_debug(SQLERRM, l_module_name, 1);

       IF fnd_msg_pub.check_msg_level(g_msg_lvl_unexp_error) THEN
	  fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name, SQLERRM);
       END IF; /* fnd_msg.... */

       fnd_msg_pub.count_and_get(
				  p_count => x_msg_count,
				  p_data  => x_msg_data
				  );

       IF (SQLCODE<-20000) THEN
	  IF (l_debug=1) THEN
	     print_debug('This is an user defined exception occured at '||l_progress,l_module_name,1);
	  END IF;
	  x_error_code:=-(SQLCODE+20000);
	  x_return_status:=g_ret_sts_error;
	ELSE
	  x_return_status := g_ret_sts_unexp_error;
       END IF;

       IF (inbound_document_details%ISOPEN) THEN
	  CLOSE inbound_document_details;
       END IF;

       IF (wopi_cursor%ISOPEN) THEN
	  CLOSE wopi_cursor;
       END IF;

       IF (wooi_cursor%ISOPEN) THEN
	  CLOSE wooi_cursor;
       END IF;

       IF (wdth_cursor%isopen) THEN
	  CLOSE wdth_cursor;
       END IF;

       ROLLBACK TO split_op_instance_sp;

 END Split_Operation_instance;



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
      p_activity_type_id  IN           NUMBER )IS

	 l_debug               NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
	 l_module_name         VARCHAR2(30) := 'Cleanup_operation_instance';
	 l_progress            NUMBER;
	 l_return_status       VARCHAR2(1);
	 l_msg_count           NUMBER;
	 l_msg_data            VARCHAR2(400);

	 l_wdt_task_id         NUMBER;
	 l_wdt_status          NUMBER;
	 l_first_op_sequence   NUMBER;

	 CURSOR c_inbound_document_details IS
	    SELECT transaction_temp_id,
	      operation_plan_id,
	      organization_id
	      FROM mtl_material_transactions_temp
	      WHERE transaction_temp_id=p_source_task_id;

	 l_inbound_doc_rec  c_inbound_document_details%ROWTYPE;

	 CURSOR c_wooi_data_rec IS
	    SELECT operation_instance_id,
	      operation_type_id,
	      operation_plan_detail_id,
	      op_plan_instance_id,
	      operation_status,
	      operation_sequence,
	      sug_to_sub_code,
	      sug_to_locator_id,
	      organization_id
	      FROM wms_op_operation_instances
	      WHERE source_task_id = p_source_task_id
	      AND activity_type_id = p_activity_type_id
	      AND operation_status = g_op_ins_stat_active;

	 l_wooi_data_rec c_wooi_data_rec%ROWTYPE:=NULL;
	 l_wooi_rec wms_op_operation_instances%ROWTYPE:=NULL;

	 l_wopi_update_rec wms_op_plan_instances%ROWTYPE:=NULL;
 BEGIN

    IF (l_debug = 1) THEN
       print_debug(' Entered. ',l_module_name,1);
       print_DEBUG(' p_source_task_id ==> '||p_source_task_id ,l_module_name,3);
       print_DEBUG(' p_activity_type_id ==> '||p_activity_type_id ,l_module_name,3);
    END IF;
    x_return_status  := g_ret_sts_success;
    l_progress := 10;
    SAVEPOINT sp_cleanup_oprtn_instance;


    IF p_source_task_id IS NULL THEN
       IF (l_debug=1) THEN
	  print_debug('Invalid input param. p_source_task_id Cannot be NULL.',l_module_name,4);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF p_activity_type_id IS NULL THEN
       IF (l_debug=1) THEN
	  print_debug('Invalid input param. p_activity_type_id Cannot be NULL.',l_module_name,4);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;


    l_progress := 20;

    BEGIN
       SELECT task_id, status
	 INTO l_wdt_task_id, l_wdt_status
	 FROM wms_dispatched_tasks
	 WHERE transaction_temp_id = p_source_task_id
	 AND task_type IN (g_wms_task_type_putaway, g_wms_task_type_inspect);

    EXCEPTION
       WHEN no_data_found THEN
	  IF (l_debug=1) THEN
	     print_debug('WDT does not exist for this MMTT.',l_module_name,4);
	  END IF;
	  RAISE FND_API.G_EXC_ERROR;

    END;

    l_progress := 30;

    IF (l_debug=1) THEN
       print_debug('l_wdt_task_id = '||l_wdt_task_id,l_module_name,4);
       print_debug('l_wdt_status = '||l_wdt_status,l_module_name,4);
    END IF;

    IF l_wdt_status NOT IN (g_task_status_loaded, g_task_status_dispatched) THEN
       IF (l_debug=1) THEN
	  print_debug('Invalid WDT status.' ,l_module_name,4);
       END IF;
       fnd_message.set_name('WMS', 'WMS_ATF_INVALID_TASK_STATUS');
       fnd_msg_pub.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF; -- IF l_wdt_status NOT IN (g_task_status_loaded, g_task_status_dispatched)


    IF l_wdt_status = g_task_status_dispatched THEN

       --This can happened for two operations today,
       --1.	Inspect
       --2.	Load

       --NOTE: Today the status of WDT is going to be 'Dispatched' for load and inspect
       --      (for drop it will be 'Loaded').
       --      But for Outbound/Warehousing tasks or when we have Inbound
       --      dispatched tasks then we CAN have a status of 'Active' for WDT records

       IF (l_debug=1) THEN
	  print_debug('WDT status is dispatched, delete WDT record : task_id = ' || l_wdt_task_id,l_module_name,4);
       END IF;

       l_progress := 40;

       DELETE wms_dispatched_tasks
	 WHERE task_id = l_wdt_task_id;

       l_progress := 50;

     ELSIF  l_wdt_status = g_task_status_loaded THEN

       IF (l_debug=1) THEN
	  print_debug('WDT status is loaded, Do not need to cleanup anything for this WDT: task_id = ' || l_wdt_task_id,l_module_name,4);
       END IF;


    END IF;  --  IF l_wdt_status = g_task_status_dispatched


    l_progress := 60;

    OPEN c_inbound_document_details;

    FETCH c_inbound_document_details
      INTO l_inbound_doc_rec;

    IF c_inbound_document_details%notfound THEN
       IF (l_debug=1) THEN
	  print_debug('Invalid input param. p_source_task_id does not match to an MMTT record.',l_module_name,4);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE c_inbound_document_details;

    l_progress := 65;



    IF l_inbound_doc_rec.operation_plan_id IS NULL THEN
       IF (l_debug=1) THEN
	  print_debug('Operation plan ID is null for this MMTT. Nothing more needs to be cleaned up.',l_module_name,4);
	  print_debug('x_return_status ==> '||x_return_status,l_module_name,3);
	  print_debug('x_msg_data ==> '||x_msg_data,l_module_name,3);
	  print_debug('x_msg_count ==> '||x_msg_count,l_module_name,3);
	  print_debug('x_error_code ==> '||x_error_code,l_module_name,3);

	  print_debug(' Before Exiting . ',l_module_name,3);

       END IF;

       IF  l_wdt_status = g_task_status_loaded THEN

	  IF (l_debug = 1) THEN
	     print_debug('l_wdt_status = '||g_task_status_loaded||', Drop operation, call WMS_OP_INBOUND_PVT.cleanup with following parameters: ',l_module_name,4);
	     print_debug('p_source_task_id => ' || p_source_task_id,l_module_name,4);
	  END IF;

	  l_progress := 72;

	  -- This call will cleanup wms_task_type (-1 -> 2) and lpn columns

	  wms_op_inbound_pvt.cleanup
	    (
	     x_return_status      => l_return_status
	     , x_msg_data         => l_msg_data
	     , x_msg_count        => l_msg_count
	     , p_source_task_id   => p_source_task_id
	     );

	  l_progress := 74;

	  IF (l_debug=1) THEN
	     print_debug('After calling wms_op_inbound_pvt.cleanup.',l_module_name,4);
	     print_debug('x_return_status => '|| l_return_status,l_module_name,4);
	     print_debug('x_msg_count => '|| l_msg_count,l_module_name,4);
	     print_debug('x_msg_data => '|| l_msg_data,l_module_name,4);
	  END IF;

	  IF l_return_status <>FND_API.g_ret_sts_success THEN
	     IF (l_debug=1) THEN
		print_debug('wms_op_inbound_pvt.cleanup finished with error. l_return_status = ' || l_return_status,l_module_name,4);
	     END IF;

	     RAISE FND_API.G_EXC_ERROR;
	  END IF;

       END IF;

       RETURN;

    END IF;  -- IF l_mmtt_rec.operation_plan_id IS NULL

    l_progress := 80;

    -- fetch the current active operation instance for this task
    OPEN c_wooi_data_rec;

    FETCH c_wooi_data_rec INTO l_wooi_data_rec;
    IF c_wooi_data_rec%notfound THEN
       IF (l_debug = 1) THEN
	  print_debug('Active operation instance record does not exist for this task.',l_module_name,4);
       END IF;
       fnd_message.set_name('WMS', 'WMS_ATF_NO_ACTIVE_PLAN');
       fnd_msg_pub.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE c_wooi_data_rec;

    l_progress := 90;

    l_wooi_rec.operation_instance_id := l_wooi_data_rec.operation_instance_id;
    l_wooi_rec.operation_status := g_op_ins_stat_pending;


    IF p_activity_type_id = g_op_activity_inbound THEN
       IF (l_debug=1) THEN
	  print_debug('Inbound Activity.',l_module_name,4);
       END IF;


       -- Firs need to update current active operation instance to pending

       IF (l_debug=1) THEN
	  print_debug('Before calling wms_op_runtime_pvt_apis.update_operation_instance with following parameters: ',l_module_name,4);
	  print_debug('l_wooi_rec.operation_instance_id => '|| l_wooi_rec.operation_instance_id,l_module_name,4);
	  print_debug('l_wooi_rec.operation_status => '|| l_wooi_rec.operation_status,l_module_name,4);
       END IF;

       l_progress := 120;

       wms_op_runtime_pvt_apis.update_operation_instance
	 (x_return_status     => l_return_status
	  , x_msg_count       => l_msg_count
	  , x_msg_data        => l_msg_data
	  , p_update_rec      => l_wooi_rec);

       l_progress := 130;

       IF (l_debug=1) THEN
	  print_debug('After calling wms_op_runtime_pvt_apis.update_operation_instance: ' ,l_module_name,4);
       	  print_debug('x_return_status => '|| l_return_status,l_module_name,4);
	  print_debug('x_msg_count => '|| l_msg_count,l_module_name,4);
	  print_debug('x_msg_data => '|| l_msg_data,l_module_name,4);
       END IF;

       IF l_return_status <>FND_API.g_ret_sts_success THEN
	  IF (l_debug=1) THEN
	     print_debug('wms_op_runtime_pvt_apis.update_operation_instance finished with error. l_return_status = ' || l_return_status,l_module_name,4);
	  END IF;

	  RAISE FND_API.G_EXC_ERROR;
       END IF;

       BEGIN
	  -- If this the first operation within a plan,
	  -- Need to revert plan instance to pending.

	  l_progress := 130;

	  SELECT MIN(wopd1.operation_sequence)
	    INTO l_first_op_sequence
	    FROM wms_op_plan_details wopd1
	    WHERE wopd1.operation_plan_id =
	    (SELECT wopd2.operation_plan_id
	     FROM wms_op_plan_details wopd2
	     WHERE wopd2.operation_plan_detail_id = l_wooi_data_rec.operation_plan_detail_id
	     );

	  l_progress := 140;

       EXCEPTION
	  WHEN OTHERS THEN
	     IF (l_debug=1) THEN
		print_debug('Exception when getting min operation_sequence.' ,l_module_name,4);
	     END IF;

	     RAISE FND_API.G_EXC_ERROR;
       END;


       IF l_first_op_sequence = l_wooi_data_rec.operation_sequence AND
	 l_wooi_data_rec.operation_type_id <> g_op_type_drop
	 -- This check is necessary to make sure crossdock plan
	 -- instance not incorrectly reverted to pending when cleaning up a drop
	 -- since load/drop for a crossdock operation have the same operation_sequence
	 THEN

	  l_wopi_update_rec.status              := g_op_ins_stat_pending;
	  l_wopi_update_rec.op_plan_instance_id := l_wooi_data_rec.op_plan_instance_id;

	  IF (l_debug=1) THEN
	     print_debug('Current operation is the first step of the operation plan.',l_module_name,4);

	     print_debug('Calling WMS_OP_RUNTIME_PVT_APIS.Update_plan_instance with the following values to be updated',l_module_name,4);
	     print_debug('l_wopi_update_rec.status    => '||l_wopi_update_rec.status,l_module_name,9);
	     print_debug('l_wopi_update_rec.op_plan_instance_id => '||l_wopi_update_rec.op_plan_instance_id,l_module_name,9);
	  END IF;

	  l_progress := 150;

	  WMS_OP_RUNTIME_PVT_APIS.Update_Plan_Instance
            (p_update_rec    => l_wopi_update_rec,
             x_return_status => l_return_status,
             x_msg_count     => x_msg_count,
             x_msg_data      => x_msg_data);

	  l_progress := 160;

	  IF (l_debug=1) THEN
	     print_debug('After calling WMS_OP_RUNTIME_PVT_APIS.Update_plan_instance.',l_module_name,4);
	     print_debug('x_return_status => '|| l_return_status,l_module_name,4);
	     print_debug('x_msg_count => '|| l_msg_count,l_module_name,4);
	     print_debug('x_msg_data => '|| l_msg_data,l_module_name,4);
	  END IF;

	  IF l_return_status <>FND_API.g_ret_sts_success THEN
	     IF (l_debug=1) THEN
		print_debug('wms_op_runtime_pvt_apis.Update_plan_instance finished with error. l_return_status = ' || l_return_status,l_module_name,4);
	     END IF;

	     RAISE FND_API.G_EXC_ERROR;
	  END IF;


       END IF;  -- IF l_first_op_sequence = l_wooi_data_rec.operation_sequence


       IF l_wooi_data_rec.operation_type_id = g_op_type_drop THEN
	  IF (l_debug = 1) THEN
	     print_debug('Drop operation, call WMS_OP_INBOUND_PVT.cleanup with following parameters: ',l_module_name,4);
	     print_debug('p_source_task_id => ' || p_source_task_id,l_module_name,4);
	  END IF;

	  l_progress := 170;

	  wms_op_inbound_pvt.cleanup
	    (
	     x_return_status      => l_return_status
	     , x_msg_data         => l_msg_data
	     , x_msg_count        => l_msg_count
	     , p_source_task_id   => p_source_task_id
	     );

	  l_progress := 180;

	  IF (l_debug=1) THEN
	     print_debug('After calling wms_op_inbound_pvt.cleanup.',l_module_name,4);
	     print_debug('x_return_status => '|| l_return_status,l_module_name,4);
	     print_debug('x_msg_count => '|| l_msg_count,l_module_name,4);
	     print_debug('x_msg_data => '|| l_msg_data,l_module_name,4);
	  END IF;

	  IF l_return_status <>FND_API.g_ret_sts_success THEN
	     IF (l_debug=1) THEN
		print_debug('wms_op_inbound_pvt.cleanup finished with error. l_return_status = ' || l_return_status,l_module_name,4);
	     END IF;

	     RAISE FND_API.G_EXC_ERROR;
	  END IF;


       END IF;  -- IF l_wooi_data_rec.operation_type_id = g_op_type_drop


    END IF; -- IF p_activity_type_id = g_op_activity_inbound


    IF (l_debug = 1) THEN
       print_debug('x_return_status ==> '||x_return_status,l_module_name,3);
       print_debug('x_msg_data ==> '||x_msg_data,l_module_name,3);
       print_debug('x_msg_count ==> '||x_msg_count,l_module_name,3);
       print_debug('x_error_code ==> '||x_error_code,l_module_name,3);

       print_debug(' Before Exiting . ',l_module_name,3);
    END IF;

 EXCEPTION

    WHEN fnd_api.g_exc_error THEN
       IF (l_debug=1) THEN
	  print_debug('Error (fnd_api.g_exc_error) occured at'||l_progress,l_module_name,1);
       END IF;
       x_return_status:=FND_API.G_RET_STS_ERROR;
       ROLLBACK TO sp_cleanup_oprtn_instance;

       IF c_inbound_document_details%isopen THEN
	  CLOSE c_inbound_document_details;
       END IF;

       IF c_wooi_data_rec%isopen THEN
	  CLOSE c_wooi_data_rec;
       END IF;
       fnd_message.set_name('WMS', 'WMS_ATF_CLEANUP_FAILURE');
       fnd_msg_pub.ADD;

    WHEN fnd_api.g_exc_unexpected_error THEN

       x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug=1) THEN
	  print_debug('Unexpected Error (fnd_api.g_exc_unexpected_error) occured at '||l_progress,l_module_name,3);
       END IF;
       ROLLBACK TO sp_cleanup_oprtn_instance;

       IF c_inbound_document_details%isopen THEN
	  CLOSE c_inbound_document_details;
       END IF;

       IF c_wooi_data_rec%isopen THEN
	  CLOSE c_wooi_data_rec;
       END IF;

       fnd_message.set_name('WMS', 'WMS_ATF_CLEANUP_FAILURE');
       fnd_msg_pub.ADD;

    WHEN OTHERS THEN

       x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
       IF (l_debug=1) THEN
	  print_debug('Other Error occured at '||l_progress,l_module_name,1);
	  IF SQLCODE IS NOT NULL THEN
	     print_debug('With SQL error : ' || SQLERRM(SQLCODE), l_module_name,1);
	  END IF;
       END IF;
       ROLLBACK TO sp_cleanup_oprtn_instance;

       IF c_inbound_document_details%isopen THEN
	  CLOSE c_inbound_document_details;
       END IF;

       IF c_wooi_data_rec%isopen THEN
	  CLOSE c_wooi_data_rec;
       END IF;
       fnd_message.set_name('WMS', 'WMS_ATF_CLEANUP_FAILURE');
       fnd_msg_pub.ADD;

 END Cleanup_Operation_instance;



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
      ) IS

      CURSOR c_inbound_doc IS
       SELECT operation_plan_id,
              transaction_temp_id,
              parent_line_id
       FROM MTL_MATERIAL_TRANSACTIONS_TEMP
       WHERE transaction_temp_id = p_source_task_id;

      CURSOR c_operation_instance IS
         SELECT operation_instance_id,
                operation_status,
                op_plan_instance_id,
                operation_type_id
         FROM WMS_OP_OPERATION_INSTANCES
         WHERE source_task_id = p_source_task_id
         AND activity_type_id = p_activity_type_id
	   AND operation_status <> g_op_ins_stat_completed
	   ORDER BY operation_sequence DESC;


       l_inbound_doc            c_inbound_doc%ROWTYPE;
       l_operation_instance_rec c_operation_instance%ROWTYPE;
       l_plan_status            NUMBER := -1;
       l_wooi_update_rec        WMS_OP_OPERATION_INSTANCES%ROWTYPE;
       l_wopi_update_rec        WMS_OP_PLAN_INSTANCES%ROWTYPE;
       l_parent_source_task_id  NUMBER;


       l_debug       NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
       l_module_name VARCHAR2(30) := 'Cancel_operation_Plan';
       l_progress    NUMBER;

   BEGIN

         IF (l_debug = 1) THEN
             print_DEBUG(' p_source_task_id ==> '||p_source_task_id ,l_module_name,3);
             print_DEBUG(' p_activity_type_id ==> '||p_activity_type_id ,l_module_name,3);
         END IF;

         SAVEPOINT cancel_op_plan_sp;

         x_return_status  := g_ret_sts_success;
         l_progress :=10;

         IF (p_source_task_id IS NULL OR p_activity_type_id IS NULL) THEN

            IF (l_debug=1) THEN
              print_debug('Invalid Input passed to Cancel_operation_plan',l_module_name,1);
            END IF;

            /*If the passed P_SOURCE_TASK_ID is null then raise Invalid Argument Error
             *and return with appropriate error code.
             */

            RAISE_APPLICATION_ERROR(INVALID_INPUT,'Invalid inputs passed'||p_source_task_id||' '||p_activity_type_id);

         END IF;

         l_progress:=20;

         /*Query the document tables based on p_source_task_id and populate the record variable.
           If p_activity_id=INBOUND then
           Query MMTT  where transaction_temp_id is equal p_source_task_id and
           populate the record variable.*/
         IF (p_activity_type_id = G_OP_ACTIVITY_INBOUND)  THEN

            OPEN c_inbound_doc;

            FETCH c_inbound_doc INTO l_inbound_doc;

            IF (c_inbound_doc%NOTFOUND) THEN

               CLOSE c_inbound_doc;

               IF (l_debug=1) THEN
                  print_debug('Document record does not exist',l_module_name,1);
               END IF;

               RAISE_APPLICATION_ERROR(INVALID_DOC_ID,'Invalid Document');

            END IF;

            CLOSE c_inbound_doc;

            l_progress:=30;

             /* Non ATF casse..Return Success*/
             IF l_inbound_doc.operation_plan_id IS NULL THEN

                IF (l_debug=1) THEN
                  print_debug('Operation Plan Id null on MMTT:non ATF Case',l_module_name,9);
                END IF;

                RETURN;

             ELSE
                l_parent_source_task_id:= l_inbound_doc.parent_line_id;

             END IF;/* Non ATF Case*/

         END IF; /*Activity is Inbound*/

         l_progress :=40;

         /*Populate the current Operation Instance (WOOI) record based
           on the p_source_task_id and the pending operation
          */
         OPEN c_operation_instance;

         FETCH c_operation_instance INTO l_operation_instance_rec;

         IF (c_operation_instance%NOTFOUND) THEN

            IF (l_debug=1) THEN
               print_debug('Operation Instance does not exists',l_module_name,9);
            END IF;

            CLOSE c_operation_instance;

            RAISE_APPLICATION_ERROR(OPERATION_INSTANCE_NOT_EXISTS,'Operation Instance does not exist for document record with Id '||p_source_task_id);

         END IF;

         CLOSE c_operation_instance;

         l_progress:=50;


         /* If the Operation Status is 'ACTIVE' then raise Invalid State Change Error,
          *  stating that you cannot change the status of a plan from 'ACTIVE' to 'CANCELLED'.
          */

         IF (l_operation_instance_rec.operation_status = G_OP_INS_STAT_ACTIVE)  THEN

            IF (l_debug=1) THEN
               print_debug('Invalid status for a cancel Operation',l_module_name,9);
            END IF;

            RAISE_APPLICATION_ERROR(INVALID_STATUS_FOR_OPERATION,'Cancellation cannot be performed on Active Record');
         END IF;

         l_progress:=60;

         /*If the current pending operation is 'DROP'
           Raise Error stating that cancellation cannot be performed
           for this operation and return appropriate err_code
           */
         IF (l_operation_instance_rec.operation_type_id =g_op_type_drop AND p_retain_mmtt = 'N') THEN
            IF (l_debug=1) THEN
               print_debug('Cancellation cannnot be performed on a Pending Drop operation',l_module_name,9);
            END IF;

            RAISE_APPLICATION_ERROR(INVALID_STATUS_FOR_OPERATION,'Cancellation cannot be performed on a Drop Operation');

         END IF;

         l_progress:=70;


         /*Mark the current Operation Plan (WOPI record) as 'Cancelled';
           call WMS_OP_RUNTIME_PVT_APIS.Update_operation_plan_instance to update
           the Operation Plan instance*/
         l_wopi_update_rec.status              := G_OP_INS_STAT_CANCELLED;
         l_wopi_update_rec.op_plan_instance_id := l_operation_instance_rec.op_plan_instance_id;

         l_progress := 100;

         IF (l_debug=1) THEN
            print_debug('Calling Update_plan_instance with the following values to be updated',l_module_name,9);
            print_debug('Plan status      => '||l_wopi_update_rec.status,l_module_name,9);
            print_debug('Plan Instance id => '||l_wopi_update_rec.op_plan_instance_id,l_module_name,9);
         END IF;

         WMS_OP_RUNTIME_PVT_APIS.Update_Plan_Instance
            (p_update_rec    => l_wopi_update_rec,
             x_return_status => x_return_status,
             x_msg_count     => x_msg_count,
             x_msg_data      => x_msg_data);

         l_progress:=110;

         IF (l_debug=1) THEN
           print_debug('Return status from table handler'||x_return_status,l_module_name,9);
         END IF;

         IF (x_return_status=g_ret_sts_error) THEN
           RAISE FND_API.G_EXC_ERROR;

         ELSIF (x_return_status<>g_ret_sts_success) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         END IF;

         l_progress:=120;

       /*Mark the current pending Operation (WOOI record) as 'Cancelled';
        * call WMS_OP_RUNTIME_APIS.Update_operation_instance to update the Operation instance
        */
        l_wooi_update_rec.operation_status      := G_OP_INS_STAT_CANCELLED;
        l_wooi_update_rec.operation_instance_id := l_operation_instance_rec.operation_instance_id;

        IF (l_debug=1) THEN
          print_debug('Updating Operation Instance with the following values',l_module_name,9);
          print_debug('Operation status      ==> '||l_wooi_update_rec.operation_status,l_module_name,9);
          print_debug('Operation Instance Id ==> '||l_wooi_update_rec.operation_instance_id,l_module_name,9);
        END IF;

        l_progress:=130;

        WMS_OP_RUNTIME_PVT_APIS.Update_Operation_Instance
            (p_update_rec    => l_wooi_update_rec,
             x_return_status => x_return_status,
             x_msg_count     => x_msg_count,
             x_msg_data      => x_msg_data);

        IF (l_debug=1) THEN
            print_debug('Return status from table handler'||x_return_status,l_module_name,9);
        END IF;

        IF (x_return_status=g_ret_sts_error) THEN

          RAISE FND_API.G_EXC_ERROR;

        ELSIF (x_return_status<>g_ret_sts_success) THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;


       l_progress:=140;
       /*Call WMS_OP_RUNTIME_PVT_APIS.Archive_op_plan_instance to archive the
        Cancelled operation plan instance.
        */
       IF (l_debug=1) THEN
         print_debug('Archiving Plan Instance with Plan Instance Id'||l_operation_instance_rec.op_plan_instance_id,l_module_name,9);
       END IF;

       WMS_OP_RUNTIME_PVT_APIS.Archive_Plan_Instance
         (p_op_plan_instance_id => l_operation_instance_rec.op_plan_instance_id,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data);

       IF (l_debug=1) THEN
            print_debug('Return status from Archive Plan Instance'||x_return_status,l_module_name,9);
       END IF;

       l_progress:=150;

       IF (x_return_status=g_ret_sts_error) THEN

          RAISE FND_API.G_EXC_ERROR;

       ELSIF (x_return_status<>g_ret_sts_success) THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       END IF;

       /*For MMTT.parent_line_id call WMS_OP_RUNTIME_PVT_API.Archive_Dispatched_tasks to Archive WDT*/
       l_progress:=160;

       IF (l_debug=1) THEN
          print_debug('Calling Archive_Dispatched_tasks with the following parameters',l_module_name,4);
          print_debug('p_source_task_id      ==> '||l_parent_source_task_id,l_module_name,4);
          print_debug('p_activity_type_id    ==> '||p_activity_type_id,l_module_name,4);
          print_debug('p_op_plan_instance_id ==> '||l_operation_instance_rec.op_plan_instance_id,l_module_name,4);
          print_debug('p_op_plan_status      ==> '||G_OP_INS_STAT_CANCELLED,l_module_name,4);
       END IF;

       WMS_OP_RUNTIME_PVT_APIS.archive_dispatched_tasks(
        x_return_status        => x_return_status
      , x_msg_count            => x_msg_count
      , x_msg_data             => x_msg_data
      , p_task_id              => NULL
      , p_source_task_id       => l_parent_source_task_id
      , p_activity_type_id     => p_activity_type_id
      , p_op_plan_instance_id  => l_operation_instance_rec.op_plan_instance_id
      , p_op_plan_status       => G_OP_INS_STAT_CANCELLED);

      IF (l_debug=1) THEN
         print_debug('Return Status from Archive_dispatched_tasks is '||x_return_status,l_module_name,9);
      END IF;

      l_progress :=170;

      IF (x_return_status=g_ret_sts_error) THEN

          RAISE FND_API.G_EXC_ERROR;

      ELSIF (x_return_status<>g_ret_sts_success) THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;

      IF (p_activity_type_id = G_OP_ACTIVITY_INBOUND) THEN

	 l_progress:=180;

	 IF (l_debug=1) THEN
	    print_debug('Inbound activity. ',l_module_name,4);
	    print_debug('Before calling wms_op_inbound_pvt.cancel with following parameters: ' ,l_module_name,4);
	    print_debug('p_source_task_id => '|| p_source_task_id,l_module_name,4);

	 END IF;

	 wms_op_inbound_pvt.cancel
	   (
	    x_return_status    => x_return_status,
	    x_msg_data         => x_msg_data,
	    x_msg_count        => x_msg_count,
	    p_source_task_id   => p_source_task_id,
	    p_retain_mmtt      => p_retain_mmtt,
	    p_mmtt_error_code  => p_mmtt_error_code,
	    p_mmtt_error_explanation => p_mmtt_error_explanation
	    );

	IF (l_debug=1) THEN
	   print_debug('After calling wms_op_inbound_pvt.cancel.' ,l_module_name,4);
	   print_debug('x_return_status => '|| x_return_status,l_module_name,4);
	   print_debug('x_msg_data => '|| x_msg_data,l_module_name,4);
	   print_debug('x_msg_count => '|| x_msg_count,l_module_name,4);
	END IF;

	IF x_return_status <>FND_API.g_ret_sts_success THEN
	   IF (l_debug=1) THEN
	      print_debug('wms_op_inbound_pvt.cancel finished with error. x_return_status = ' || x_return_status,l_module_name,4);
	   END IF;

	   RAISE FND_API.G_EXC_ERROR;
	END IF;

         l_progress := 200;
      END IF; -- IF (p_activity_type_id = G_OP_ACTIVITY_INBOUND)

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

          IF (l_debug=1) THEN
             print_debug('Expected Error Obtained at'||l_progress,l_module_name,1);
          END IF;

          IF c_inbound_doc%ISOPEN THEN
             CLOSE c_inbound_doc;
          END IF;

          IF c_operation_instance%ISOPEN THEN
             CLOSE c_operation_instance;
          END IF;


          ROLLBACK TO cancel_op_plan_sp;

          x_return_status:=g_ret_sts_error;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          IF (l_debug=1) THEN
             print_debug('UnExpected Error Obtained at'||l_progress||SQLERRM,l_module_name,1);
          END IF;

          IF (l_debug=1) THEN
             print_debug('Expected Error Obtained at'||l_progress,l_module_name,1);
          END IF;

          IF c_inbound_doc%ISOPEN THEN
             CLOSE c_inbound_doc;
          END IF;

          IF c_operation_instance%ISOPEN THEN
             CLOSE c_operation_instance;
          END IF;


          ROLLBACK TO cancel_op_plan_sp;
          x_return_status:=g_ret_sts_unexp_error;

       WHEN OTHERS THEN

          IF (l_debug=1) THEN
            print_debug(l_progress||' '||SQLERRM, l_module_name,1);
          END IF;

          IF fnd_msg_pub.check_msg_level(g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name, SQLERRM);
          END IF; /* fnd_msg.... */

          fnd_msg_pub.count_and_get(
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );

          IF (SQLCODE<-20000) THEN
            IF (l_debug=1) THEN
              print_debug('This is a user defined exception',l_module_name,1);
            END IF;

            x_error_code:=-(SQLCODE+20000);

            x_return_status:=g_ret_sts_error;


          ELSE

            x_return_status := g_ret_sts_unexp_error;

          END IF;

          IF c_inbound_doc%ISOPEN THEN
             CLOSE c_inbound_doc;
          END IF;

          IF c_operation_instance%ISOPEN THEN
             CLOSE c_operation_instance;
          END IF;


         ROLLBACK TO cancel_op_plan_sp;

   END Cancel_Operation_Plan;


/**
  *   Abort_operation_Plan
  *   <p>This procedure aborts the operation plan(s). It is called from control board</p>
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
   ) IS

       CURSOR c_inbound_doc IS
        SELECT operation_plan_id,
	  move_order_line_id,
	  parent_line_id,
	  transfer_to_location,
	  locator_id,
	  organization_id,
	  inventory_item_id,
	  primary_quantity
        FROM MTL_MATERIAL_TRANSACTIONS_TEMP
          WHERE transaction_temp_id = p_source_task_id;

       CURSOR c_operation_instance IS
          SELECT operation_instance_id,
                 operation_status,
                 op_plan_instance_id
          FROM WMS_OP_OPERATION_INSTANCES
          WHERE source_task_id = p_source_task_id
          AND operation_status <> G_OP_INS_STAT_COMPLETED
          AND activity_type_id = p_activity_type_id
	  ORDER BY operation_sequence DESC;

       CURSOR c_plan_instance(v_op_plan_instance_id NUMBER) IS
          SELECT status,
	    orig_dest_sub_code,
	    orig_dest_loc_id
          FROM WMS_OP_PLAN_INSTANCES
          WHERE op_plan_instance_id=v_op_plan_instance_id;


       l_plan_orig_dest_sub    VARCHAR2(10);
       l_plan_orig_dest_loc_id NUMBER;


       l_inbound_doc           c_inbound_doc%ROWTYPE;
       l_operation_plan_id     NUMBER;
       l_operation_instance     c_operation_instance%ROWTYPE;
       l_plan_inst_status      NUMBER := -1;
       l_wooi_update_rec       WMS_OP_OPERATION_INSTANCES%ROWTYPE:=NULL;
       l_wopi_update_rec       WMS_OP_PLAN_INSTANCES%ROWTYPE:=NULL;
       l_parent_source_task_id NUMBER;
       l_document_rec          mtl_material_transactions_temp%ROWTYPE;



       l_debug       NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
       l_module_name VARCHAR2(30) := 'Abort_operation_Plan';
       l_return_status  VARCHAR2(1);
       l_msg_count NUMBER;
       l_msg_data VARCHAR2(400);

       l_progress    NUMBER       ;

   BEGIN

         IF (l_debug = 1) THEN
             print_DEBUG(' p_source_task_id ==> '||p_source_task_id ,l_module_name,3);
             print_DEBUG(' p_activity_type_id ==> '||p_activity_type_id ,l_module_name,3);
         END IF;
         SAVEPOINT abort_plan_sp;

         x_return_status  := g_ret_sts_success;

         l_progress := 10;

         /*If the passed P_SOURCE_TASK_ID is null then raise Invalid Argument
           Error and return with appropriate error code.*/

         IF (p_source_task_id IS NULL OR p_activity_type_id IS NULL) THEN

            IF (l_debug=1) THEN
               print_debug('Invalid inputs passed'||p_source_task_id,l_module_name,9);
            END IF;

            RAISE_APPLICATION_ERROR(INVALID_INPUT,'Invalid inputs passed'||p_source_task_id||' '||p_activity_type_id);

         END IF;

         l_progress:=20;

         /* Query the document tables based on p_source_task_id and
          * populate the record variable.
          * If p_activity_id=INBOUND then
          * Query MMTT (MTLT) where transaction_temp_id is equal p_source_task_id and
          * populate the record variable.*/

         IF p_activity_type_id=G_OP_ACTIVITY_INBOUND THEN

            OPEN c_inbound_doc;

            FETCH c_inbound_doc INTO l_inbound_doc;

            IF c_inbound_doc%NOTFOUND THEN

               /* If there is no document record is found corresponding to
                * P_SOURCE_TASK_ID then raise Developer Error stating that
                * document must exist and return with appropriate error code.*/

               IF (l_debug=1) THEN
                  print_debug('Document record not found for source_task_id'||p_source_task_id,l_module_name,1);
               END IF;

               CLOSE c_inbound_doc;

               RAISE_APPLICATION_ERROR(INVALID_DOC_ID,'Invalid Document Record');
             END IF;

             CLOSE c_inbound_doc;

             l_progress:=30;

           /*Handle case where MMTT.Operation_Plan_ID is NULL.
             If MMTT.Operation_Plan_ID is NULL
               This could happen when 'user drop ' a pre-11.5.10 MMTT record.
           */
	          IF (l_inbound_doc.operation_plan_id IS NULL) THEN
              /* Non ATF Case*/
               IF (l_debug=1) THEN
                 print_debug('Operation Plan Id is null:non ATF case',l_module_name,9);
               END IF;

               RETURN;

             END IF; /*Non ATF case*/

             l_parent_source_task_id := l_inbound_doc.parent_line_id;

         END IF;/*Inbound*/


         l_progress :=40;

         /*Populate the current Operation Instance (WOOI) record based on
          * the p_source_task_id  and the pending operation
         */

         OPEN c_operation_instance;

         FETCH c_operation_instance INTO l_operation_instance;

         IF (c_operation_instance%NOTFOUND) THEN

            IF (l_debug=1) THEN
               print_debug('Operation instance does not exist for record',l_module_name,1);
            END IF;

            CLOSE c_operation_instance;

            RAISE_APPLICATION_ERROR(OPERATION_INSTANCE_NOT_EXISTS,'Operation Instance does not exist for document record with Id '||p_source_task_id);
         END IF;

         CLOSE c_operation_instance;

         l_progress:=50;

         /*Populate Operation Plan Instance (WOPI) into the Operation Plan Instance record
          * based on the Operation Plan Instance field*/

         OPEN c_plan_instance(l_operation_instance.op_plan_instance_id);

	  FETCH c_plan_instance INTO
	    l_plan_inst_status,
	    l_plan_orig_dest_sub,
	    l_plan_orig_dest_loc_id;

         CLOSE c_plan_instance;

         l_progress:=60;

         IF l_plan_inst_status IS NULL OR l_plan_inst_status=-1 THEN

            IF (l_debug=1) THEN
               print_debug('Invalid Operation Plan Instance',l_module_name,1);
            END IF;

            RAISE_APPLICATION_ERROR(INVALID_PLAN_INSTANCE,'Invalid Operation Plan Instance');
         END IF;

         l_progress:=70;

         /*Mark the current Operation Plan (WOPI record) as 'Aborted;
           call WMS_OP_RUNTIME_PVT_APIS.Update_operation_plan_instance to update
           the Operation Plan instance*/
         l_wopi_update_rec.status              := G_OP_INS_STAT_ABORTED;
         l_wopi_update_rec.op_plan_instance_id := l_operation_instance.op_plan_instance_id;

         l_progress := 80;

         IF (l_debug=1) THEN
            print_debug('Calling Update_plan_instance with the following values to be updated',l_module_name,9);
            print_debug('Plan status      => '||l_wopi_update_rec.status,l_module_name,9);
            print_debug('Plan Instance id => '||l_wopi_update_rec.op_plan_instance_id,l_module_name,9);
         END IF;

         WMS_OP_RUNTIME_PVT_APIS.Update_Plan_Instance
            (p_update_rec    => l_wopi_update_rec,
             x_return_status => x_return_status,
             x_msg_count     => x_msg_count,
             x_msg_data      => x_msg_data);

         l_progress:=90;

         IF (l_debug=1) THEN
           print_debug('Return status from table handler'||x_return_status,l_module_name,9);
         END IF;

         IF (x_return_status=g_ret_sts_error) THEN
           RAISE FND_API.G_EXC_ERROR;

         ELSIF (x_return_status<>g_ret_sts_success) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         END IF;

         l_progress:=100;

       /*Mark the current pending Operation (WOOI record) as 'Aborted;
        * call WMS_OP_RUNTIME_APIS.Update_operation_instance to update the Operation instance
        */
        l_wooi_update_rec.operation_status      := G_OP_INS_STAT_ABORTED;
        l_wooi_update_rec.operation_instance_id := l_operation_instance.operation_instance_id;

        IF (l_debug=1) THEN
          print_debug('Updating Operation Instance with the following values',l_module_name,9);
          print_debug('Operation status      ==> '||l_wooi_update_rec.operation_status,l_module_name,9);
          print_debug('Operation Instance Id ==> '||l_wooi_update_rec.operation_instance_id,l_module_name,9);
        END IF;

        l_progress:=110;

        WMS_OP_RUNTIME_PVT_APIS.Update_Operation_Instance
            (p_update_rec    => l_wooi_update_rec,
             x_return_status => x_return_status,
             x_msg_count     => x_msg_count,
             x_msg_data      => x_msg_data);

        IF (l_debug=1) THEN
            print_debug('Return status from table handler'||x_return_status,l_module_name,9);
        END IF;

        IF (x_return_status=g_ret_sts_error) THEN

          RAISE FND_API.G_EXC_ERROR;

        ELSIF (x_return_status<>g_ret_sts_success) THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;


       l_progress:=120;

       /*Call WMS_OP_RUNTIME_PVT_APIS.Archive_op_plan_instance to archive the
        aborted operation plan instance.
        */
       IF (l_debug=1) THEN
         print_debug('Archiving Plan Instance with Plan Instance Id'||l_operation_instance.op_plan_instance_id,l_module_name,9);
       END IF;

       WMS_OP_RUNTIME_PVT_APIS.Archive_Plan_Instance
         (p_op_plan_instance_id => l_operation_instance.op_plan_instance_id,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data);

       IF (l_debug=1) THEN
            print_debug('Return status from Archive Plan Instance'||x_return_status,l_module_name,9);
       END IF;

       l_progress:=130;

       IF (x_return_status=g_ret_sts_error) THEN

          RAISE FND_API.G_EXC_ERROR;

       ELSIF (x_return_status<>g_ret_sts_success) THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       END IF;

       /*For MMTT.parent_line_id call WMS_OP_RUNTIME_PVT_API.Archive_Dispatched_tasks to Archive WDT*/
       l_progress:=140;

       IF (l_debug=1) THEN
          print_debug('Calling Archive_Dispatched_tasks with the following parameters',l_module_name,4);
          print_debug('p_source_task_id      ==> '||l_parent_source_task_id,l_module_name,4);
          print_debug('p_activity_type_id    ==> '||p_activity_type_id,l_module_name,4);
          print_debug('p_op_plan_instance_id ==> '||l_operation_instance.op_plan_instance_id,l_module_name,4);
          print_debug('p_op_plan_status      ==> '||G_OP_INS_STAT_ABORTED,l_module_name,4);
       END IF;

       WMS_OP_RUNTIME_PVT_APIS.archive_dispatched_tasks(
        x_return_status        => x_return_status
      , x_msg_count            => x_msg_count
      , x_msg_data             => x_msg_data
      , p_task_id              => NULL
      , p_source_task_id       => l_parent_source_task_id
      , p_activity_type_id     => p_activity_type_id
      , p_op_plan_instance_id  => l_operation_instance.op_plan_instance_id
      , p_op_plan_status       => G_OP_INS_STAT_ABORTED);

      IF (l_debug=1) THEN
         print_debug('Return Status from Archive_dispatched_tasks is '||x_return_status,l_module_name,9);
      END IF;

      l_progress :=150;

      IF (x_return_status=g_ret_sts_error) THEN

          RAISE FND_API.G_EXC_ERROR;

      ELSIF (x_return_status<>g_ret_sts_success) THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;

      IF (p_activity_type_id = G_OP_ACTIVITY_INBOUND) THEN


	 l_progress:=160;
         /* null out the Operation Plan Id ,parent Line Id and delete the Parent transaction temp Id*/
         /*Call table hanlder to delete MMTT/MSNT/MTLT for the Parent MMTT*/

/*	 INV_TRX_UTIL_PUB.Delete_transaction
           (x_return_status       => x_return_status,
            x_msg_data            => x_msg_data,
            x_msg_count           => x_msg_count,
            p_transaction_temp_id => l_parent_source_task_id,
            p_update_parent       => FALSE);

        IF (l_debug=1) THEN
            print_debug('Return status from Delete Transaction'||x_return_status,l_module_name,9);
        END IF;

        IF (x_return_status=g_ret_sts_error) THEN

          RAISE FND_API.G_EXC_ERROR;

        ELSIF (x_return_status<>g_ret_sts_success) THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

        l_progress:=170;

        IF (l_debug=1) THEN
           print_debug('Updating parent Line id and Operation plan id for Src Document record',l_module_name,9);
	   print_debug('Also update destination sub/loc Src Document record to that of the original task: l_plan_orig_dest_sub = '||l_plan_orig_dest_sub || '  l_plan_orig_dest_loc_id = ' || l_plan_orig_dest_loc_id,l_module_name,9);
	   print_debug('l_inbound_doc.locator_id = '|| l_inbound_doc.locator_id,l_module_name,9);
    	   print_debug('l_inbound_doc.locator_id = '|| l_inbound_doc.locator_id,l_module_name,9);
    	   print_debug('l_inbound_doc.transfer_to_location = '|| l_inbound_doc.transfer_to_location,l_module_name,9);
	END IF;

	IF l_inbound_doc.locator_id IS NULL THEN
	   UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
	     SET operation_plan_id  = NULL ,
	     parent_line_id     = NULL,
	     subinventory_code  = l_plan_orig_dest_sub,
	     locator_id         = l_plan_orig_dest_loc_id
	     WHERE transaction_temp_id = p_source_task_id;
	 ELSIF  l_inbound_doc.transfer_to_location IS NULL THEN
	   UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
	     SET operation_plan_id  = NULL ,
	     parent_line_id     = NULL,
	     transfer_subinventory  = l_plan_orig_dest_sub,
	     transfer_to_location         = l_plan_orig_dest_loc_id
	     WHERE transaction_temp_id = p_source_task_id;
	END IF;


       l_progress := 180;
	     */

	     l_document_rec.transaction_temp_id := p_source_task_id;
	   l_document_rec.parent_line_id := l_inbound_doc.parent_line_id;
	   l_document_rec.locator_id := l_inbound_doc.locator_id;
	   l_document_rec.transfer_to_location := l_inbound_doc.transfer_to_location;
	   l_document_rec.organization_id := l_inbound_doc.organization_id;
	   l_document_rec.inventory_item_id := l_inbound_doc.inventory_item_id;
	   l_document_rec.primary_quantity := l_inbound_doc.primary_quantity;

	   IF l_debug=1 THEN
	      print_debug('Before calling wms_op_inbound_pvt.ABORT with following parameters:',l_module_name,4);
	      print_debug('l_document_rec.transaction_temp_id => '|| l_document_rec.transaction_temp_id,l_module_name,4);
	      print_debug('l_document_rec.parent_line_id => '||l_document_rec.parent_line_id,l_module_name,4);
	      print_debug('l_document_rec.locator_id => '||l_document_rec.locator_id,l_module_name,4);
	      print_debug('l_document_rec.transfer_to_location => '||l_document_rec.transfer_to_location,l_module_name,4);
	      print_debug('p_plan_orig_sub_code => '||l_plan_orig_dest_sub,l_module_name,4);
	      print_debug('p_plan_orig_loc_id => '||l_plan_orig_dest_loc_id,l_module_name,4);
	      IF(p_for_manual_drop = TRUE) THEN
		 print_debug('p_for_manual_drop => TRUE',l_module_name, 4);
	       ELSE
		 print_debug('p_for_manual_drop => FALSE',l_module_name,4);
	      END IF;

	   END IF;


	   wms_op_inbound_pvt.ABORT
	    (x_return_status         => l_return_status,
	     x_msg_data              => l_msg_data,
	     x_msg_count             => l_msg_count,
	     p_document_rec          => l_document_rec,
	     p_plan_orig_sub_code    => l_plan_orig_dest_sub,
	     p_plan_orig_loc_id      => l_plan_orig_dest_loc_id,
	     p_for_manual_drop       => p_for_manual_drop
	     );

	   IF l_debug=1 THEN
	      print_debug('After calling wms_op_inbound_pvt.ABORT:',l_module_name,4);
	      print_debug('x_return_status => '||l_return_status,l_module_name,4);
	      print_debug('x_msg_data => '||l_msg_data,l_module_name,4);
	      print_debug('x_msg_count => '||l_msg_count,l_module_name,4);
	   END IF;

	   IF l_return_status <> FND_API.g_ret_sts_success THEN
	     IF (l_debug=1) THEN
		print_debug(' wms_op_inbound_pvt.ABORT finished with error. l_return_status = ' || l_return_status,l_module_name,4);
	     END IF;

	     RAISE FND_API.G_EXC_ERROR;
	  END IF;

       IF l_debug=1 THEN
          print_debug('Need to update the WDT /WDTH records nulling out operation Plan id',l_module_name,9);
          print_debug(' and also op_plan_instance_id ',l_module_name,9);
       END IF;

       -- Do not nul out operation_plan_id and op_plan_instance_id
       -- since DBI uses these columns for exception related KPI
       -- It is ok for WMS because without parent_transaction_id
       -- the aborted WDTH is still viewed as an independent task
       -- from control board.
       UPDATE wms_dispatched_tasks_history
	 SET parent_transaction_id = NULL
	 WHERE transaction_id = p_source_task_id;

/*       UPDATE wms_dispatched_tasks
          SET operation_plan_id = NULL,
              op_plan_instance_id = NULL
       WHERE transaction_temp_id = p_source_task_id;

       l_progress := 190;

       IF SQL%ROWCOUNT=0 THEN

          IF l_debug =1 THEN
             print_debug('Could be an archived record,hence updating WDT',l_module_name,9);
          END IF;

          l_progress :=200;

          UPDATE wms_dispatched_tasks_history
             SET operation_plan_id     = NULL,
                 op_plan_instance_id   = NULL,
                 parent_transaction_id = NULL
          WHERE transaction_id = p_source_task_id;

	END IF;
*/

      END IF;

      /*Need for calling a document handler or not..mostly not*/

   EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

          IF (l_debug=1) THEN
             print_debug('Expected Error Obtained at'||l_progress,l_module_name,1);
          END IF;

          IF c_inbound_doc%ISOPEN THEN
             CLOSE c_inbound_doc;
          END IF;

          IF c_operation_instance%ISOPEN THEN
             CLOSE c_operation_instance;
          END IF;

          IF c_plan_instance%ISOPEN THEN
             CLOSE c_plan_instance;
          END IF;

          ROLLBACK TO abort_plan_sp;

          x_return_status:=g_ret_sts_error;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          IF (l_debug=1) THEN
             print_debug('UnExpected Error Obtained at'||l_progress||SQLERRM,l_module_name,1);
          END IF;

          IF (l_debug=1) THEN
             print_debug('Expected Error Obtained at'||l_progress,l_module_name,1);
          END IF;

          IF c_inbound_doc%ISOPEN THEN
             CLOSE c_inbound_doc;
          END IF;

          IF c_operation_instance%ISOPEN THEN
             CLOSE c_operation_instance;
          END IF;

          IF c_plan_instance%ISOPEN THEN
             CLOSE c_plan_instance;
          END IF;

          ROLLBACK TO abort_plan_sp;
          x_return_status:=g_ret_sts_unexp_error;

       WHEN OTHERS THEN

          IF (l_debug=1) THEN
            print_debug(l_progress||' '||SQLERRM, l_module_name,1);
          END IF;

          IF fnd_msg_pub.check_msg_level(g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name, SQLERRM);
          END IF; /* fnd_msg.... */

          fnd_msg_pub.count_and_get(
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );

          IF (SQLCODE<-20000) THEN
            IF (l_debug=1) THEN
              print_debug('This is a user defined exception',l_module_name,1);
            END IF;

            x_error_code:=-(SQLCODE+20000);

            x_return_status:=g_ret_sts_error;


          ELSE

            x_return_status := g_ret_sts_unexp_error;

          END IF;

          IF c_inbound_doc%ISOPEN THEN
             CLOSE c_inbound_doc;
          END IF;

          IF c_operation_instance%ISOPEN THEN
             CLOSE c_operation_instance;
          END IF;

          IF c_plan_instance%ISOPEN THEN
             CLOSE c_plan_instance;
          END IF;


         ROLLBACK TO abort_plan_sp;


   END Abort_Operation_Plan;


 /**
  *   Rollback_operation_Plan
  *   <p>This procedure rollsback the operation plan(s).This API is called for a Single Step Drop
  *      Operation and it rollsback to Load Pending.</p>
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
      p_activity_type_id  IN           NUMBER ) IS


      CURSOR c_wdt_details IS
         SELECT status,
                task_id
         FROM wms_dispatched_tasks
         WHERE transaction_temp_id = p_source_task_id;

      CURSOR c_inbound_document_details IS
         SELECT operation_plan_id
         FROM mtl_material_transactions_temp
         WHERE transaction_temp_id = p_source_task_id;


      CURSOR c_operation_instances IS
         SELECT operation_instance_id,
                op_plan_instance_id,
                operation_type_id,
                operation_sequence,
                operation_plan_detail_id,
                operation_status
         FROM wms_op_operation_instances
         WHERE source_task_id = p_source_task_id
         AND activity_type_id = p_activity_type_id
         ORDER BY 4;

      CURSOR c_min_operation_seq (v_op_plan_id NUMBER) IS
         SELECT MIN(operation_sequence)
          FROM wms_op_plan_details
         WHERE operation_plan_id = v_op_plan_id;




       l_wdt_details          c_wdt_details%ROWTYPE;
       l_inbound_document     c_inbound_document_details%ROWTYPE;
       l_wooi_data_rec        c_operation_instances%ROWTYPE;
       l_min_opertn_sequence  NUMBER := -1;
       l_op_plan_instance_id  NUMBER;
       l_wooi_rec             wms_op_operation_instances%ROWTYPE;
       l_plan_detail_id       NUMBER;
       l_first_opertn_seq     NUMBER;
       l_wopi_rec             wms_op_plan_instances%ROWTYPE;
       l_op_plan_id           NUMBER;

       l_debug       NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
       l_module_name VARCHAR2(30) := 'Rollback_operation_Plan';
       l_progress    NUMBER       ;

   BEGIN

         IF (l_debug = 1) THEN
             print_DEBUG(' p_source_task_id ==> '||p_source_task_id ,l_module_name,3);
             print_DEBUG(' p_activity_type_id ==> '||p_activity_type_id ,l_module_name,3);
         END IF;
         x_return_status  := g_ret_sts_success;

         SAVEPOINT rollback_op_plan_sp;
         l_progress :=10;

         /*If the p_source_task_id is null or p_activity_type_id is null then raise invalid arguement error and
          * return by populating appropriate error code.
          */
         IF p_source_task_id IS NULL OR p_activity_type_id IS NULL THEN

            IF (l_debug=1) THEN
               print_debug('Invalid Inputs passed to Rollback Operation Plan '||p_source_task_id||' '||p_activity_type_id,l_module_name,9);
            END IF;

            RAISE_APPLICATION_ERROR(INVALID_INPUT,'Invalid inputs passed'||p_source_task_id||' '||p_activity_type_id);

         END IF;

         l_progress:=20;


         /* Update or remove WDT. Based on the p_source_task_id query WMS_DISPATCHED_TASKS and populate WDT record variable as follows:
          * a.	If no record is found in WDT for source_task_id then raise unexpected error and return after populating appropriate error code.
          * b.	If WDT.status = 'Dispatched' or 'Loaded' THEN
          *      a.	Remove WDT
          * End IF; (If Dispatched)
          */

         IF (p_activity_type_id =G_OP_ACTIVITY_INBOUND) THEN

            OPEN c_wdt_details;

            FETCH c_wdt_details INTO l_wdt_details;

            IF (c_wdt_details%NOTFOUND) THEN

              IF (l_debug=1) THEN
                 print_debug('No WDT record found for source task id '||p_source_task_id,l_module_name,1);
              END IF;

              CLOSE c_wdt_details;

              RAISE_APPLICATION_ERROR(TASK_NOT_EXISTS,'Task Record does not exist for source task Id :'||p_source_task_id);

            END IF;

            CLOSE c_wdt_details;

            l_progress:=30;

            IF (l_debug=1) THEN
               print_debug('Status of the task record fetched is '||l_wdt_details.status,l_module_name,9);
            END IF;

            IF l_wdt_details.status NOT IN (g_task_status_dispatched,g_task_status_loaded) THEN

               IF l_debug=1 THEN
                  print_debug('Invalid task record',l_module_name,1);
               END IF;

               RAISE_APPLICATION_ERROR(INVALID_TASK,'Invalid Task Record for task Id '||l_wdt_details.task_id||' and status '||l_wdt_details.status);

            END IF;

            l_progress := 40;


	    -- Moved delete WDT to after WMS_OP_INBOUND_PVT.Cleanup


            /* Query the document tables based on p_source_taks_id and p_activity_id and populate the document record.
             *   If p_activity_id=INBOUND then
             *      Query MMTT (MTLT) where transaction_temp_id is equal p_source_task_id and populate the record variable.
             *   End If
             */

             OPEN c_inbound_document_details;

             FETCH c_inbound_document_details INTO l_inbound_document;

             IF c_inbound_document_details%NOTFOUND THEN

                CLOSE c_inbound_document_details;

                IF l_debug=1 THEN

                   print_debug('Inbound document record does not exist for source task Id :'||p_source_task_id,l_module_name,9);

                END IF;

                RAISE_APPLICATION_ERROR(INVALID_DOC_ID,'Invalid Document Record with document Id: '||p_source_task_id);

             END IF;

             CLOSE c_inbound_document_details;

             /*	If Operation_plan_id on MMTT record variable is null then return as Success
              *   Non ATF case
              */
             l_progress:=60;

             IF l_inbound_document.operation_plan_id IS NULL THEN

                IF (l_debug=1) THEN
                   print_debug('Operation PLan Id null on document record:Non ATF case',l_module_name,9);
                END IF;
		/* for bug#5997558 */
		IF p_activity_type_id =G_OP_ACTIVITY_INBOUND THEN

                WMS_OP_INBOUND_PVT.Cleanup
                  (  x_return_status   => x_return_status
 	               , x_msg_data         => x_msg_data
 	               , x_msg_count        => x_msg_count
 	               , p_source_task_id   => p_source_task_id
 	              );

               IF l_debug=1 THEN
                  print_debug(' Return Status from Cleanup '||x_return_status,l_module_name,9);
               END IF;


               IF (x_return_status=g_ret_sts_error) THEN
                    RAISE FND_API.G_EXC_ERROR;

               ELSIF (x_return_status<>g_ret_sts_success) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               END IF;
	       end if ;

	       /* End for bug#5997558 */

		-- Before we return, we should delete WDT here
		-- since now we delete WDT after calling WMS_OP_INBOUND_PVT.Cleanup at the end.

		DELETE FROM WMS_DISPATCHED_TASKS
		  WHERE transaction_temp_id = p_source_task_id
		  AND task_id = l_wdt_details.task_id;

		IF c_wdt_details%ISOPEN THEN
		   CLOSE c_wdt_details;
		END IF;

		IF c_inbound_document_details%ISOPEN THEN
		   CLOSE c_inbound_document_details;
		END IF;

		IF c_operation_instances%ISOPEN THEN
		   CLOSE c_operation_instances;
		END IF;

		IF c_min_operation_seq%ISOPEN THEN
		   CLOSE c_min_operation_seq;
		END IF;

                RETURN;

             END IF; /* non ATF case*/

             l_op_plan_id := l_inbound_document.operation_plan_id;

         END IF;/*Inbound*/

             /* Populate the Operation Instance (WOOI) record based on the
              * current Active operation for p_source_task_id.
              * Populate the Operation Plan Instance (WOPI) Record based on the Operation Plan
              * Instance of the operation Instance.
              */
             l_progress := 70;

             OPEN c_operation_instances;

             LOOP

              FETCH c_operation_instances INTO l_wooi_data_rec;

              EXIT WHEN c_operation_instances%NOTFOUND;

              IF l_wooi_data_rec.operation_type_id = G_OP_TYPE_LOAD AND l_wooi_data_rec.operation_status = G_OP_INS_STAT_COMPLETED THEN

               /* Call WMS_OP_RUNTIME_APIS_PVT.UPDATE_OPERATION_INSTANCE
                * to update the Operation Instance populated in WOOI record
                * tp statsu Pending
                */

                 l_wooi_rec.operation_instance_id := l_wooi_data_rec.operation_instance_id;
                 l_wooi_rec.operation_status      := G_OP_INS_STAT_PENDING;


                IF (l_debug=1) THEN
                   print_debug('Load Operation is Completed,hence updating the Operation Instance Record tp Pending',l_module_name,9);
                   print_debug('CAlling Update_Operation_instance with the Operation Instance Id as '||l_wooi_rec.operation_instance_id,l_module_name,9);
                   print_debug('Operation status as :'||l_wooi_rec.operation_status,l_module_name,9);
                END IF;

                l_progress := 80;

                WMS_OP_RUNTIME_PVT_APIS.UPDATE_OPERATION_INSTANCE
                   (p_update_rec    => l_wooi_rec,
                    x_return_status => x_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data);

                IF (l_debug = 1) THEN
                   print_debug('Return Status from Update Operation Instance is '||x_return_status,l_module_name,9);
                END IF;

                IF (x_return_status=g_ret_sts_error) THEN
                   RAISE FND_API.G_EXC_ERROR;

                ELSIF (x_return_status<>g_ret_sts_success) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                END IF;

                l_op_plan_instance_id := l_wooi_data_rec.op_plan_instance_id;


                /* Fetching the minimum sequence of the Operation Plan Detail to check later if it is the
                 * first operation
                 */

                l_min_opertn_sequence := l_wooi_data_rec.operation_sequence;

                l_plan_detail_id := l_wooi_data_rec.operation_plan_detail_id;


              END IF;/* Operation is Load */

              l_progress := 90;

              IF l_wooi_data_rec.operation_type_id = G_OP_TYPE_DROP AND l_wooi_data_rec.operation_status IN (G_OP_INS_STAT_PENDING,G_OP_INS_STAT_ACTIVE)  THEN

                 IF (l_debug=1) THEN
                    print_debug('Operation is Drop,hence deleting the Operation Instance',l_module_name,9);
                 END IF;

                 /*Checking if operation Plan Instances are the same on both the Operation instance records
                  * Ideally this condition should never occur,checking for data corruption
                  */

                 IF l_op_plan_instance_id IS NOT NULL AND l_op_plan_instance_id <> l_wooi_data_rec.op_plan_instance_id THEN

                    IF (l_debug=1) THEN
                       print_debug('Invalid condition where the Operation plan Instances are different for the same source_task id',l_module_name,1);
                    END IF;

                    RAISE_APPLICATION_ERROR(DATA_INCONSISTENT,'Operation plan Instance different for the same Source task id in different Operation Instances');

                END IF;

                l_op_plan_instance_id := l_wooi_data_rec.op_plan_instance_id;

                l_progress := 100;

                /* Checking if the Operation Sequnce of Load is greater than that of Drop
                 * Ideally this case should never occur.Indication of data corruption
                 */

                IF (l_min_opertn_sequence > l_wooi_data_rec.operation_sequence) THEN

                   IF (l_debug=1) THEN
                      print_debug('Operation sequence of Load greater than that of drop for the same source task id',l_module_name,9);
                   END IF;

                   RAISE_APPLICATION_ERROR(DATA_INCONSISTENT,'Operation Sequence of Load Operation greater than that of Drop');
                END IF;

                l_progress := 110;

                IF (l_debug=1) THEN
                   print_debug('Calling Deleting Operation Instance with operation Instance Id'||l_wooi_data_rec.operation_instance_id,l_module_name,9);
                END IF;

                WMS_OP_RUNTIME_PVT_APIS.DELETE_OPERATION_INSTANCE
                   ( p_operation_instance_id => l_wooi_data_rec.operation_instance_id
                    ,x_return_status => x_return_status
                    ,x_msg_count     => x_msg_count
                    ,x_msg_data      => x_msg_data);

                l_progress:=120;

                IF l_debug=1 THEN
                   print_debug('Return Status from Delete Operation Instance '||x_return_status,l_module_name,9);
                END IF;

                IF (x_return_status=g_ret_sts_error) THEN
                   RAISE FND_API.G_EXC_ERROR;

                ELSIF (x_return_status<>g_ret_sts_success) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                END IF;

              END IF; /*Operation Type Drop*/

             END LOOP;

             l_progress:=130;

             /* If the above fetched operation is the first in the Plan then
              * Call WMS_OP_RUNTIME_APIS_PVT.UPDATE_PLAN_INSTANCE to set the plan status as Pending.
				  */
              OPEN c_min_operation_seq(l_op_plan_id);

              FETCH c_min_operation_seq INTO l_first_opertn_seq;

              IF (c_min_operation_seq%NOTFOUND) THEN

                 IF (l_debug=1) THEN
                    print_debug('NO Operation Detail Record found',l_module_name,9);
                 END IF;

                 CLOSE c_min_operation_seq;

                 RAISE_APPLICATION_ERROR(INVALID_PLAN_ID,'Invalid Plan Id stamped on document record');

              END IF;

              CLOSE c_min_operation_seq;

              l_progress := 140;

              IF (l_first_opertn_seq = l_min_opertn_sequence) THEN

                 IF (l_debug=1) THEN
                    print_debug('It is the first Operation in the Plan,hence update status to pending',l_module_name,9);
                 END IF;

                 l_wopi_rec.op_plan_instance_id := l_op_plan_instance_id;

                 l_wopi_rec.status              := G_OP_INS_STAT_PENDING;

                 l_progress :=150;

                 IF l_debug=1 THEN
                    print_debug('Calling WMS_OP_RUNTIME_APIS_PVT.UPDATE_PLAN_INSTANCE with the following parameters',l_module_name,9);
                    print_debug('Op_plan_instance_id => '||l_wopi_rec.op_plan_instance_id,l_module_name,9);
                    print_debug('Status              => '||l_wopi_rec.status,l_module_name,9);
                 END IF;

                 WMS_OP_RUNTIME_PVT_APIS.UPDATE_PLAN_INSTANCE
                   (p_update_rec    => l_wopi_rec,
                    x_return_status => x_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data);

                 IF (l_debug =1) THEN
                    print_debug('Return Status from Update Plan Instance'||x_return_status,l_module_name,9);
                 END IF;

                 IF (x_return_status=g_ret_sts_error) THEN
                   RAISE FND_API.G_EXC_ERROR;

                 ELSIF (x_return_status<>g_ret_sts_success) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                 END IF;

              END IF;/*First Operation in Plan*/

              /*If p_activity_id =INBOUND then
               *  Call WMS_OP_INBOUND_PVT.Cleanup
               *End If;
               */
              l_progress :=160;
             IF p_activity_type_id =G_OP_ACTIVITY_INBOUND THEN

                WMS_OP_INBOUND_PVT.Cleanup
                  (  x_return_status   => x_return_status
 	               , x_msg_data         => x_msg_data
 	               , x_msg_count        => x_msg_count
 	               , p_source_task_id   => p_source_task_id
 	              );

               IF l_debug=1 THEN
                  print_debug(' Return Status from Cleanup '||x_return_status,l_module_name,9);
               END IF;


               IF (x_return_status=g_ret_sts_error) THEN
                    RAISE FND_API.G_EXC_ERROR;

               ELSIF (x_return_status<>g_ret_sts_success) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               END IF;


	       /* Deleting the WDT record as the status is being reverted to Load Pending */
	       -- Moved delete WDT to after calling  WMS_OP_INBOUND_PVT.Cleanup
	       -- because WMS_OP_INBOUND_PVT.Cleanup now calls putaway_cleanup, which assumes WDT still exists.

	       DELETE FROM WMS_DISPATCHED_TASKS
		 WHERE transaction_temp_id = p_source_task_id
		 AND task_id = l_wdt_details.task_id;

	       l_progress := 170;

             END IF;/*Activity is Inbound*/

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

         IF (l_debug=1) THEN
            print_debug('Expected Error Obtained at'||l_progress,l_module_name,1);
         END IF;

         IF c_wdt_details%ISOPEN THEN
            CLOSE c_wdt_details;
         END IF;

         IF c_inbound_document_details%ISOPEN THEN
            CLOSE c_inbound_document_details;
         END IF;

         IF c_operation_instances%ISOPEN THEN
            CLOSE c_operation_instances;
         END IF;

         IF c_min_operation_seq%ISOPEN THEN
            CLOSE c_min_operation_seq;
         END IF;

         x_return_status := g_ret_sts_error;

         ROLLBACK TO rollback_op_plan_sp;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

         IF (l_debug=1) THEN
            print_debug('Expected Error Obtained at'||l_progress,l_module_name,1);
         END IF;

         IF c_wdt_details%ISOPEN THEN
            CLOSE c_wdt_details;
         END IF;

         IF c_inbound_document_details%ISOPEN THEN
            CLOSE c_inbound_document_details;
         END IF;

         IF c_operation_instances%ISOPEN THEN
            CLOSE c_operation_instances;
         END IF;

         IF c_min_operation_seq%ISOPEN THEN
            CLOSE c_min_operation_seq;
         END IF;

         x_return_status := g_ret_sts_unexp_error;

         ROLLBACK TO rollback_op_plan_sp;

      WHEN OTHERS THEN

            print_debug(SQLERRM, l_module_name,1);
            IF (l_debug=1) THEN
              print_debug(l_progress||' '||SQLERRM, l_module_name,1);
            END IF;

            IF fnd_msg_pub.check_msg_level(g_msg_lvl_unexp_error) THEN
              fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name, SQLERRM);
            END IF; /* fnd_msg.... */

            fnd_msg_pub.count_and_get(
                                   p_count => x_msg_count,
                                   p_data  => x_msg_data
                                  );

            IF (SQLCODE<-20000) THEN
              IF (l_debug=1) THEN
                print_debug('This is a user defined exception',l_module_name,1);
              END IF;

              x_error_code:=-(SQLCODE+20000);

              x_return_status:=g_ret_sts_error;


            ELSE

              x_return_status := g_ret_sts_unexp_error;

            END IF;

            IF c_wdt_details%ISOPEN THEN
              CLOSE c_wdt_details;
           END IF;

           IF c_inbound_document_details%ISOPEN THEN
              CLOSE c_inbound_document_details;
           END IF;

           IF c_operation_instances%ISOPEN THEN
              CLOSE c_operation_instances;
           END IF;

           IF c_min_operation_seq%ISOPEN THEN
              CLOSE c_min_operation_seq;
           END IF;


            ROLLBACK TO rollback_op_plan_sp;

   END Rollback_Operation_Plan;


/**
  *   Check_Plan_Status
  *   <p>This procedure returns the operation plan instance
  *   status for a given source task ID and activity.</p>
  *  @param x_return_status    Return Status
  *  @param x_msg_data         Returns the Message Data
  *  @param x_msg_count        Returns the Error Message
  *  @param x_error_code       Returns appropriate error code in case
  *                            of an error.
  *  @param x_plan_status      Returns the Status of the Plan
  *  @param p_source_task_id   Identifier of the source document record
  *  @param p_activity_type_id Lookup code of the Activity type Id
  **/
   PROCEDURE  Check_Plan_Status(
              x_return_status    OUT  NOCOPY  VARCHAR2,
              x_msg_data         OUT  NOCOPY  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE,
              x_msg_count        OUT  NOCOPY  NUMBER,
              x_error_code       OUT  NOCOPY  NUMBER,
              x_plan_status      OUT  NOCOPY  NUMBER,
              p_source_task_id   IN           NUMBER,
              p_activity_type_id IN           NUMBER
                               ) IS

      l_debug       NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'),0);
      l_module_name VARCHAR2(30) := 'Check_Plan_Status';
      l_progress    VARCHAR2(30);

      l_status      NUMBER := -1;
      l_plan_id     NUMBER := -1;

      CURSOR source_plan IS
      SELECT mmtt.operation_plan_id
      FROM   mtl_material_transactions_temp mmtt
      WHERE  mmtt.transaction_temp_id = p_source_task_id;

      CURSOR plan_status IS
      SELECT wopi.status
      FROM   wms_op_plan_instances wopi
      WHERE  wopi.activity_type_id = p_activity_type_id
      AND    wopi.source_task_id = p_source_task_id;

      CURSOR op_plan_status IS
       SELECT wopi.status
         FROM wms_op_plan_instances wopi
        WHERE wopi.op_plan_instance_id = (SELECT op_plan_instance_id
                                          FROM wms_op_operation_instances wooi
                                          WHERE wooi.source_task_id = p_source_task_id
                                          AND wooi.activity_type_id = p_activity_type_id
                                          AND ROWNUM =1);


   BEGIN

         l_progress := '10';

         IF (l_debug = 1) THEN
             print_debug(' p_source_task_id ==> '||p_source_task_id ,
                           l_module_name,3);
             print_debug(' p_activity_type_id ==> '||p_activity_type_id ,
                           l_module_name,3);
         END IF;

         l_progress := '20';
         /*
          * The activity type and the the source task cannot be null
          * Raise Illegal Argument Exception
          */

         IF (p_source_task_id IS NULL OR p_activity_type_id IS NULL) THEN

            /*RAISE fnd_api.g_exc_error;*/
            RAISE_APPLICATION_ERROR(INVALID_INPUT,'Invalid inputs passed'||p_source_task_id||p_activity_type_id);

         END IF; /* p_source_task_id IS...*/

         l_progress := '30';

         /*
          * If the activity type is Inbound then the source task type Id
          * corresponds to a MMTT record.
          *
          * This API is called from CREATE_SUGGESTIONS.. and it is possible
          * that is called for MMTT records that do not have an operation
          * plan
          * In such a case we should return a success and plan status
          * should be NULL
          *
          * If a plan exists then find out the plan status
          */
         IF p_activity_type_id = g_op_activity_inbound THEN

            OPEN  source_plan;
            FETCH source_plan INTO l_plan_id;
            CLOSE source_plan;

            l_progress := '40';

           /*
            * l_plan_id has a value of -1 if the cursor failed to fetch
            * any rows, this means that there is no MMTT corresponding
            * to the passed document Id,i.e. The document Id passed is
            * invalid.
            *
            * In this case Raise Illegal Argument Error.
            */

            IF l_plan_id = -1 THEN

               /*RAISE fnd_api.g_exc_error;*/
               RAISE_APPLICATION_ERROR(INVALID_DOC_ID,'Document Record does not exist for Source_task_id'||p_source_task_id);

            END IF; /* l_plan_id = -1 */

            l_progress := '50';

           /*
            * MMTT exists but plan id is NULL
            */
            IF l_plan_id IS NULL THEN

               l_status := NULL;
               GOTO success;

            END IF; /* l_plan_id IS NULL*/

         END IF; /* p_activity...*/

         l_progress := '60';
         /*
          * The assumption being made here is that the source task id
          * passed is the parent document id.
          */

         OPEN plan_status;
         FETCH plan_status INTO l_status;
         CLOSE plan_status;

         l_progress := '70';

         /*
          * l_status has a value of -1 if the cursor failed to fetch
          * any rows, this means that there is no plan corresponding
          * to the passed document Id,therefore need to check the
          * if the document Id is a part of Operation Instance,then
          * fetch plan status for the Operation Plan Instance correspomding
          * to the Operation
          * else
          *   Raise Expected Error.
          */
         IF l_status = -1 THEN

            OPEN op_plan_status;

            FETCH op_plan_status INTO l_status;

            CLOSE op_plan_status;

            IF l_status=-1 THEN
               /* Operation Instance does not exist*/

               RAISE_APPLICATION_ERROR(OPERATION_INSTANCE_NOT_EXISTS,'Operation instance does not exist for Source task Id'||p_source_task_id);
            END IF;

            l_progress :=75;

         END IF; /* l_status = -1 */

         l_progress := '80';

         <<SUCCESS>>

         x_return_status  := g_ret_sts_success;
         x_plan_status    := l_status;
         fnd_msg_pub.count_and_get(
                                    p_count => x_msg_count,
                                    p_data  => x_msg_data
                                  );

   EXCEPTION

         /*WHEN FND_API.G_EXC_ERROR THEN
            print_debug(l_progress||' '||SQLERRM, l_module_name,1);

            IF fnd_msg_pub.check_msg_level(g_msg_lvl_error) THEN
               fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name, SQLERRM);
            END IF; /* fnd_msg.... */

            /*fnd_msg_pub.count_and_get(
                                       p_count => x_msg_count,
                                       p_data  => x_msg_data
                                      );
            x_error_code := SQLCODE;
            x_return_status := g_ret_sts_error;*/

         WHEN OTHERS THEN

            print_debug(l_progress||' '||SQLERRM, l_module_name,1);

            IF fnd_msg_pub.check_msg_level(g_msg_lvl_unexp_error) THEN
               fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name, SQLERRM);
            END IF; /* fnd_msg.... */

            fnd_msg_pub.count_and_get(
                                       p_count => x_msg_count,
                                       p_data  => x_msg_data
                                      );
            IF (SQLCODE<-20000) THEN
               IF (l_debug=1) THEN
                 print_debug('This is a user defined exception',l_module_name,1);
               END IF;

               x_error_code:=-(SQLCODE+20000);

               x_return_status:=g_ret_sts_error;


            ELSE

               x_return_status := g_ret_sts_unexp_error;
            END IF;

   END Check_Plan_Status;




END WMS_ATF_RUNTIME_PUB_APIS;

/
