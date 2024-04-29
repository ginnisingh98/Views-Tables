--------------------------------------------------------
--  DDL for Package Body WMS_WORKFLOW_WRAPPERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_WORKFLOW_WRAPPERS" as
/* $Header: WMSWFWRB.pls 120.6.12010000.4 2009/05/13 05:18:58 kjujjuru ship $ */

g_pkg_name CONSTANT VARCHAR(30) := 'wms_workflow_wrappers';
g_return_status     VARCHAR2(30) := NULL; --Bug 6116046
-- to turn off debugger, comment out the line 'dbms_output.put_line(msg);'

PROCEDURE mdebug(msg in varchar2)
IS
   l_msg VARCHAR2(5100);
   l_ts VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   select to_char(sysdate,'MM/DD/YYYY HH:MM:SS') INTO l_ts from dual;

   l_msg:=l_ts||'  '||msg;

   inv_mobile_helper_functions.tracelog
     (p_err_msg => l_msg,
      p_module => 'wms_workflow_wrappers',
      p_level => 4);

   --dbms_output.put_line(msg);
   null;
END;

-- This is the procedure called by LoadPick.
-- wf_wrapper in turn calls wf_start_workflow which kicks off the workflow
PROCEDURE wf_wrapper(p_api_version                     IN          NUMBER
		     , p_init_msg_list                 IN          VARCHAR2 := fnd_api.g_false
		     , p_commit	                       IN          VARCHAR2 := fnd_api.g_false
		     , x_return_status                 OUT NOCOPY  VARCHAR2
		     , x_msg_count                     OUT NOCOPY  NUMBER
		     , x_msg_data                      OUT NOCOPY  VARCHAR2
		     , p_org_id                        IN          NUMBER
		     , p_rsn_id                        IN          NUMBER
		     , p_calling_program               IN          VARCHAR2
		     , p_tmp_id                        IN          NUMBER DEFAULT NULL
		     , p_quantity_picked               IN          NUMBER DEFAULT NULL
                     , p_dest_sub                      IN          VARCHAR2 DEFAULT NULL
		     , p_dest_loc                      IN          NUMBER DEFAULT NULL
		     )
  IS
     l_api_name	            CONSTANT VARCHAR2(30)  := 'wf_wrapper';
     l_api_version	    CONSTANT NUMBER	   := 1.0;

       lX_RETURN_STATUS					VARCHAR2(250);
       lX_MSG_DATA					VARCHAR2(250);
       lX_MSG_COUNT					NUMBER;
       lX_ORGANIZATION_ID				NUMBER;
       lX_SUBINVENTORY					VARCHAR2(250);
       lX_SUBINVENTORY_STATUS				NUMBER;
       lX_LOCATOR					NUMBER;
       lX_LOCATOR_STATUS				NUMBER;
       lX_LPN_ID					NUMBER;
       lX_LPN_STATUS					NUMBER;
       lX_INVENTORY_ITEM_ID				NUMBER;
       lX_REVISION					VARCHAR2(250);
       lX_LOT_NUMBER					VARCHAR2(250);
       lX_LOT_STATUS					NUMBER;
       lX_QUANTITY					NUMBER;
       lX_UOM_CODE					VARCHAR2(250);
       lX_PRIMARY_QUANTITY				NUMBER;
       lX_TRANSACTION_QUANTITY 				NUMBER;
       lX_RESERVATION_ID				NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      mdebug('In workflow wrapper');
   END IF;
   -- Standard Start of API savepoint
   SAVEPOINT	wf_wrapper_PVT;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version	,
					p_api_version	,
					l_api_name      ,
					G_PKG_NAME )
     THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    /* Comment this out because FND package not working in WMSTST
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
     -- FND_MSG_PUB.initialize;
      END IF;
      */

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (l_debug = 1) THEN
       mdebug('before calling wms_workflow_wrappers.wf_start_workflow');
    END IF;

    --p_dest_sub = sub suggested by system
    --p_dest_loc = loc suggested by system
    wms_workflow_wrappers.wf_start_workflow(
                     P_REASON_ID				=> p_rsn_id,
                     P_CALLING_PROGRAM_NAME			=> p_calling_program,
                     P_SOURCE_ORGANIZATION_ID		=> p_org_id,
                     P_REASON_NAME				=> NULL,
                     P_DESTINATION_ORGANIZATION_ID		=> NULL,
                     P_SOURCE_SUBINVENTORY			=> p_dest_sub,
                     P_SOURCE_SUBINVENTORY_STATUS		=> NULL,
                     P_DESTINATION_SUBINVENTORY		=> NULL,
                     P_DESTINATION_SUBINVENTORY_ST           => NULL,
                     P_SOURCE_LOCATOR			=> p_dest_loc,
                     P_SOURCE_LOCATOR_STATUS			=> NULL,
                     P_DESTINATION_LOCATOR			=> NULL,
                     P_DESTINATION_LOCATOR_STATUS		=> NULL,
                     P_LPN_ID				=> NULL,
                     P_LPN_STATUS				=> NULL,
                     P_CONTENT_LPN_ID	       		=> NULL,
                     P_CONTENT_LPN_STATUS		       	=> NULL,
                     p_source_parent_lpn_id  		=> NULL,
                     P_SOURCE_parent_LPN_STATUS		=> NULL,
                     P_SOURCE_OUTERMOST_LPN_ID		=> NULL,
                     P_SOURCE_OUTERMOST_LPN_STATUS		=> NULL,
                     p_dest_lpn_id                 		=> NULL,
                     p_dest_lpn_status        	        => NULL,
                     p_dest_parent_lpn_id     		=> NULL,
                     p_dest_parent_lpn_status        	=> NULL,
                     P_DEST_OUTERMOST_LPN_ID  		=> NULL,
                     P_DEST_OUTERMOST_LPN_STATUS      	=> NULL,
                     P_INVENTORY_ITEM_ID			=> NULL,
                     P_REVISION				=> NULL,
                     P_LOT_NUMBER				=> NULL,
                     p_to_lot_number                         => NULL,
                     P_LOT_STATUS				=> NULL,
                     P_SERIAL_NUMBER				=> NULL,
                     p_to_serial_number                      => NULL,
                     P_SERIAL_NUMBER_STATUS			=> NULL,
                     P_PRIMARY_UOM				=> NULL,
                     P_TRANSACTION_UOM			=> NULL,
                     P_PRIMARY_QUANTITY			=> NULL,
                     P_TRANSACTION_QUANTITY			=> p_quantity_picked,
                     P_TRANSACTION_ACTION_ID			=> NULL,
                     P_TRANSACTION_SOURCE_TYPE_ID		=> NULL,
                     P_TRANSACTION_SOURCE			=> NULL,
                     P_RESERVATION_ID			=> NULL,
                     P_EQUIPMENT_ID				=> NULL,
                     P_USER_ID				=> FND_GLOBAL.user_id,
                     P_TASK_TYPE_ID				=> NULL,
                     P_TASK_ID				=> NULL,
                     p_txn_temp_id                           => p_tmp_id,
                     p_update_status_method                  => NULL,
                     P_PROGRAM_CONTROL_ARG1			=> NULL,
                     P_PROGRAM_CONTROL_ARG2			=> NULL,
                     P_PROGRAM_CONTROL_ARG3			=> NULL,
                     P_PROGRAM_CONTROL_ARG4			=> NULL,
                     P_PROGRAM_CONTROL_ARG5			=> NULL,
                     P_PROGRAM_CONTROL_ARG6 			=> NULL
                     ,X_RETURN_STATUS		=> lX_RETURN_STATUS
                     ,X_MSG_DATA			=> lX_MSG_DATA
                     ,X_MSG_COUNT		        => lX_MSG_COUNT
                     ,X_ORGANIZATION_ID		=> lX_ORGANIZATION_ID
                     ,X_SUBINVENTORY			=> lX_SUBINVENTORY
                     ,X_SUBINVENTORY_STATUS		=> lX_SUBINVENTORY_STATUS
                     ,X_LOCATOR			=> lX_LOCATOR
                     ,X_LOCATOR_STATUS		=> lX_LOCATOR_STATUS
                     ,X_LPN_ID			=> lX_LPN_ID
                     ,X_LPN_STATUS			=> lX_LPN_STATUS
                     ,X_INVENTORY_ITEM_ID		=> lX_INVENTORY_ITEM_ID
                     ,X_REVISION			=> lX_REVISION
                     ,X_LOT_NUMBER			=> lX_LOT_NUMBER
                     ,X_LOT_STATUS			=> lX_LOT_STATUS
                     ,X_QUANTITY			=> lX_QUANTITY
                     ,X_UOM_CODE			=> lX_UOM_CODE
                     ,X_PRIMARY_QUANTITY		=> lX_PRIMARY_QUANTITY
                     ,X_TRANSACTION_QUANTITY 	=> lX_TRANSACTION_QUANTITY
                     ,X_RESERVATION_ID		=> lX_RESERVATION_ID
                       );

		  x_return_status := lX_RETURN_STATUS;  --Bug 6116046
        --bug 6924639
        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          mdebug('call to startworkflow failed at 1');
        END IF;

        fnd_message.set_name('WMS', 'WMS_START_WORKFLOW_FAILED');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          mdebug('call to startworkflow failed at 2 ');
        END IF;

        fnd_message.set_name('WMS', 'WMS_START_WORKFLOW_FAILED');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
      --bug 6924639
                 /*
                  -- after API call, validate return status
                  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS AND x_return_status <> 'Y') THEN --bug 6924639 added condition to check for x_return_status<>'Y'
                     IF (l_debug = 1) THEN
                        mdebug('call to startworkflow failed ');
                     END IF;
                     FND_MESSAGE.SET_NAME('WMS', 'WMS_START_WORKFLOW_FAILED');
                     FND_MSG_PUB.ADD;
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
   */
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 1) THEN
         mdebug('expected error in '||l_api_name);
      END IF;
      ROLLBACK TO wf_wrapper_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				,p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 1) THEN
         mdebug('unexpected error in '||l_api_name);
      END IF;
      ROLLBACK TO wf_wrapper_pvt;
        mdebug('ROLLBACK to wf_wrapper_pvt succeeded');
     	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				  ,p_data => x_msg_data);

   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         mdebug('others error in '||l_api_name);
      END IF;
	ROLLBACK TO wf_wrapper_pvt;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     	END IF;
     	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				  , p_data => x_msg_data);
END wf_wrapper;



-- New workflow (replacing wms_txnreasons_pub.Start_Workflow)
-- if task_id is populated, then all the parameters will be
-- obtained from tables except for the following:
-- p_to_serial_number, p_to_lot_number, p_update_status_method (these are
-- all for Janet's API call)

PROCEDURE wf_start_workflow(
                     P_REASON_ID				IN	NUMBER,
                     P_CALLING_PROGRAM_NAME			IN      VARCHAR2,
                     P_SOURCE_ORGANIZATION_ID		IN	NUMBER,
                     P_REASON_NAME				IN	VARCHAR2 DEFAULT NULL,
                     P_DESTINATION_ORGANIZATION_ID		IN	NUMBER DEFAULT NULL,
                     P_SOURCE_SUBINVENTORY			IN	VARCHAR2 DEFAULT NULL,
                     P_SOURCE_SUBINVENTORY_STATUS		IN	NUMBER DEFAULT NULL,
                     P_DESTINATION_SUBINVENTORY		IN	VARCHAR2 DEFAULT NULL,
                     P_DESTINATION_SUBINVENTORY_ST           IN	NUMBER DEFAULT NULL,
                     P_SOURCE_LOCATOR			IN	NUMBER DEFAULT NULL,
                     P_SOURCE_LOCATOR_STATUS			IN	NUMBER DEFAULT NULL,
                     P_DESTINATION_LOCATOR			IN	NUMBER DEFAULT NULL,
                     P_DESTINATION_LOCATOR_STATUS		IN      NUMBER DEFAULT NULL,
                     P_LPN_ID				IN	NUMBER DEFAULT NULL,
		     P_ONHAND_STATUS                    IN      VARCHAR2 DEFAULT NULL, -- Added for Onhand material support --6633612
                     P_LPN_STATUS				IN	NUMBER DEFAULT NULL,
                     P_CONTENT_LPN_ID	       		IN	NUMBER DEFAULT NULL,
                     P_CONTENT_LPN_STATUS		       	IN	NUMBER DEFAULT NULL,
                     p_source_parent_lpn_id  		IN	NUMBER DEFAULT NULL,
                     P_SOURCE_parent_LPN_STATUS		IN	NUMBER DEFAULT NULL,
                     P_SOURCE_OUTERMOST_LPN_ID		IN	NUMBER DEFAULT NULL,
                     P_SOURCE_OUTERMOST_LPN_STATUS		IN      NUMBER DEFAULT NULL,
                     p_dest_lpn_id                 		IN	NUMBER DEFAULT NULL,
                     p_dest_lpn_status        	        IN	NUMBER DEFAULT NULL,
                     p_dest_parent_lpn_id     		IN	NUMBER DEFAULT NULL,
                     p_dest_parent_lpn_status        	IN	NUMBER DEFAULT NULL,
                     P_DEST_OUTERMOST_LPN_ID  		IN	NUMBER DEFAULT NULL,
                     P_DEST_OUTERMOST_LPN_STATUS      	IN	NUMBER DEFAULT NULL,
                     P_INVENTORY_ITEM_ID			IN	NUMBER DEFAULT NULL,
                     P_REVISION				IN	VARCHAR2 DEFAULT NULL,
                     P_LOT_NUMBER				IN	VARCHAR2 DEFAULT NULL,
                     p_to_lot_number                         IN      VARCHAR2 DEFAULT NULL,
                     P_LOT_STATUS				IN	NUMBER DEFAULT NULL,
                     P_SERIAL_NUMBER				IN	VARCHAR2 DEFAULT NULL,
                     p_to_serial_number                      IN      VARCHAR2 DEFAULT NULL,
                     P_SERIAL_NUMBER_STATUS			IN	NUMBER DEFAULT NULL,
                     P_PRIMARY_UOM				IN	VARCHAR2 DEFAULT NULL,
                     P_TRANSACTION_UOM			IN	VARCHAR2 DEFAULT NULL,
                     P_PRIMARY_QUANTITY			IN	NUMBER DEFAULT NULL,
                     P_TRANSACTION_QUANTITY			IN	NUMBER DEFAULT NULL,
                     P_TRANSACTION_ACTION_ID			IN	NUMBER DEFAULT NULL,
                     P_TRANSACTION_SOURCE_TYPE_ID		IN	NUMBER DEFAULT NULL,
                     P_TRANSACTION_SOURCE			IN	NUMBER DEFAULT NULL,
                     P_RESERVATION_ID			IN	NUMBER DEFAULT NULL,
                     P_EQUIPMENT_ID				IN	NUMBER DEFAULT NULL,
                     P_USER_ID				IN	NUMBER DEFAULT NULL,
                     P_TASK_TYPE_ID				IN	NUMBER DEFAULT NULL,
                     P_TASK_ID				IN	NUMBER DEFAULT NULL,
                     p_txn_temp_id                           IN      NUMBER DEFAULT NULL,
                     p_update_status_method                  IN 	VARCHAR2 DEFAULT NULL,
                     P_PROGRAM_CONTROL_ARG1			IN	VARCHAR2 DEFAULT NULL,
                     P_PROGRAM_CONTROL_ARG2			IN	VARCHAR2 DEFAULT NULL,
                     P_PROGRAM_CONTROL_ARG3			IN	VARCHAR2 DEFAULT NULL,
                     P_PROGRAM_CONTROL_ARG4			IN	VARCHAR2 DEFAULT NULL,
                     P_PROGRAM_CONTROL_ARG5			IN	VARCHAR2 DEFAULT NULL,
                     P_PROGRAM_CONTROL_ARG6 			IN	VARCHAR2 DEFAULT NULL,
                     X_RETURN_STATUS				OUT NOCOPY	VARCHAR2,
                     X_MSG_DATA				OUT NOCOPY	VARCHAR2,
                     X_MSG_COUNT				OUT NOCOPY	NUMBER,
                     X_ORGANIZATION_ID			OUT NOCOPY	NUMBER,
                     X_SUBINVENTORY				OUT NOCOPY	VARCHAR2,
                     X_SUBINVENTORY_STATUS			OUT NOCOPY	NUMBER,
                     X_LOCATOR				OUT NOCOPY	NUMBER,
                     X_LOCATOR_STATUS			OUT NOCOPY	NUMBER,
                     X_LPN_ID				OUT NOCOPY	NUMBER,
                     X_LPN_STATUS				OUT NOCOPY	NUMBER,
                     X_INVENTORY_ITEM_ID			OUT NOCOPY	NUMBER,
                     X_REVISION				OUT NOCOPY	VARCHAR2,
                     X_LOT_NUMBER				OUT NOCOPY	VARCHAR2,
                     X_LOT_STATUS				OUT NOCOPY	NUMBER,
                     X_QUANTITY				OUT NOCOPY	NUMBER,
                     X_UOM_CODE				OUT NOCOPY	VARCHAR2,
                     X_PRIMARY_QUANTITY			OUT NOCOPY	NUMBER,
                     X_TRANSACTION_QUANTITY 			OUT NOCOPY	NUMBER,
                     X_RESERVATION_ID			OUT NOCOPY	NUMBER
                       )
  IS

 -- defining input variables and initializing them to null;
      L_REASON_NAME				 	VARCHAR2(250) := NULL;
      L_SOURCE_ORGANIZATION_N				VARCHAR2(250) := NULL;
      L_DESTINATION_ORGANIZATION_ID		 	NUMBER := NULL;
      L_SOURCE_SUBINVENTORY			 	VARCHAR2(250) := NULL;
      L_SOURCE_SUBINVENTORY_STATUS		 	NUMBER := NULL;
      L_DESTINATION_SUBINVENTORY		 	VARCHAR2(250) := NULL;
      L_DESTINATION_SUBINVENTORY_ST            	NUMBER := NULL;
      L_SOURCE_LOCATOR			 	NUMBER := NULL;
      L_SOURCE_LOCATOR_N		 	        VARCHAR2(250) :=NULL;
      L_SOURCE_LOCATOR_STATUS			 	NUMBER := NULL;
      L_DESTINATION_LOCATOR				NUMBER := NULL;
      L_DESTINATION_LOCATOR_STATUS		        NUMBER := NULL;
      L_LPN_ID				 	NUMBER := NULL;
      L_LPN_N				 	        VARCHAR2(250) :=NULL;
      L_LPN_STATUS				 	NUMBER := NULL;
      L_CONTENT_LPN_ID	       		 	NUMBER := NULL;
      L_CONTENT_LPN_STATUS		       	 	NUMBER := NULL;
      L_source_parent_lpn_id  		 	NUMBER := NULL;
      L_SOURCE_parent_LPN_STATUS		 	NUMBER := NULL;
      L_SOURCE_OUTERMOST_LPN_ID		 	NUMBER := NULL;
      L_SOURCE_OUTERMOST_LPN_STATUS		 	NUMBER := NULL;
      L_dest_lpn_id                 		 	NUMBER := NULL;
      L_dest_lpn_status        	        	NUMBER := NULL;
      L_dest_parent_lpn_id     		 	NUMBER := NULL;
      L_dest_parent_lpn_status        	 	NUMBER := NULL;
      L_DEST_OUTERMOST_LPN_ID  		 	NUMBER := NULL;
      L_DEST_OUTERMOST_LPN_STATUS      	 	NUMBER := NULL;
      L_INVENTORY_ITEM_ID			 	NUMBER := NULL;
      L_INVENTORY_ITEM_NAME			 	VARCHAR2(250) := NULL;
      L_REVISION				 	VARCHAR2(250) := NULL;
      L_LOT_NUMBER				 	VARCHAR2(250) := NULL;
      L_to_lot_number                                 VARCHAR2(250) := NULL;
      L_LOT_STATUS				 	NUMBER := NULL;
      L_SERIAL_NUMBER				 	VARCHAR2(250) := NULL;
      L_to_serial_number                              VARCHAR2(250) := NULL;
      L_SERIAL_NUMBER_STATUS			 	NUMBER := NULL;
      L_PRIMARY_UOM				 	VARCHAR2(250) := NULL;
      L_TRANSACTION_UOM			 	VARCHAR2(250) := NULL;
      L_PRIMARY_QUANTITY			 	NUMBER := NULL;
      L_TRANSACTION_QUANTITY			 	NUMBER := NULL;
      l_transaction_header_id                         NUMBER := NULL;
      l_mo_line_id                                    NUMBER := NULL;
      L_TRANSACTION_ACTION_ID			 	NUMBER := NULL;
      L_TRANSACTION_SOURCE_TYPE_ID		 	NUMBER := NULL;
      L_TRANSACTION_SOURCE			 	NUMBER := NULL;
      L_RESERVATION_ID			 	NUMBER := NULL;
      L_EQUIPMENT_ID				 	NUMBER := NULL;
      L_USER_ID				 	NUMBER := NULL;
      l_user_name                              	VARCHAR2(250) := NULL;
      L_TASK_TYPE_ID				 	NUMBER := NULL;
      L_TASK_ID				 	NUMBER := NULL;
      l_txn_temp_id                                   NUMBER := NULL;
      L_update_status_method                    	VARCHAR2(250) := NULL;
      L_PROGRAM_CONTROL_ARG1			 	VARCHAR2(250) := NULL;
      L_PROGRAM_CONTROL_ARG2			 	VARCHAR2(250) := NULL;
      L_PROGRAM_CONTROL_ARG3			 	VARCHAR2(250) := NULL;
      L_PROGRAM_CONTROL_ARG4			 	VARCHAR2(250) := NULL;
      L_PROGRAM_CONTROL_ARG5			 	VARCHAR2(250) := NULL;
      L_PROGRAM_CONTROL_ARG6 			 	VARCHAR2(250) := NULL;
      --Bug 7504490 l_allocated_lpn_id
      l_allocated_lpn_id                    NUMBER;

      -- temp variables
      l_transaction_temp_id NUMBER;
      l_error NUMBER;

      -- variables to create workflow process
      l_workflow_name		varchar2(250);
      l_workflow_process	varchar2(250);
      l_sequence_number	number ;
      l_item_key 		varchar2(500);

      -- debug variable

     l_api_name	            CONSTANT VARCHAR2(30)  := 'wf_start_workflow';

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      mdebug('In Start_Workflow');
   END IF;

    -- Standard Start of API savepoint
   SAVEPOINT	wf_start_workflow_PVT;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- given the reason id, get reason name
   IF p_reason_name IS NULL THEN
      SELECT reason_name
	INTO l_reason_name
	FROM mtl_transaction_reasons
	WHERE reason_id = p_reason_id;
    ELSE
      l_reason_name := p_reason_name;
   END IF;
   IF (l_debug = 1) THEN
      mdebug('after gettting reason name');
   END IF;
   -- populate local variables from wdt table

   --Now using mmtt id instead of task id
   l_transaction_temp_id := p_txn_temp_id;
   IF (l_debug = 1) THEN
      mdebug('mmtt_id: '||l_transaction_temp_id );
   END IF;

   IF (p_task_id IS NOT NULL AND p_task_id>0) THEN
      l_task_id := p_task_id;
      IF (l_debug = 1) THEN
         mdebug('l_task_id: '||l_task_id);
      END IF;
   ELSE
      IF (l_debug = 1) THEN
         mdebug('IN ELSE before : l_task_id: '||l_task_id);
      END IF;
      BEGIN
	 SELECT task_id
	   INTO l_task_id
	   FROM wms_dispatched_tasks
	   WHERE transaction_temp_id=l_transaction_temp_id;
	   IF (l_debug = 1) THEN
   	       mdebug('IN ELSE after : l_task_id: '||l_task_id);
	   END IF;
      EXCEPTION
	 WHEN no_data_found THEN
	    l_task_id := NULL;
      END;

   END IF;
   IF (l_debug = 1) THEN
      mdebug('after getting task id: '||l_task_id);
   END IF;

-- from mmtt_id populate local variables obtained from mmtt table
--Bug 7504490 l_allocated_lpn_id
   SELECT subinventory_code, locator_id, transfer_organization,
        wms_task_type, lpn_id, content_lpn_id, transfer_lpn_id,
	inventory_item_id, revision, lot_number, serial_number,
	primary_quantity, item_primary_uom_code,
	transaction_quantity, transaction_uom,
	transaction_header_id, transaction_action_id, transaction_source_type_id,
	transaction_source_id,
	reservation_id, move_order_line_id, allocated_lpn_id

   INTO  l_destination_subinventory, l_destination_locator,l_destination_organization_id,
	l_task_type_id, l_lpn_id, l_content_lpn_id, l_dest_lpn_id,
	l_inventory_item_id, l_revision, l_lot_number, l_serial_number,
	l_primary_quantity, l_primary_uom,
	l_transaction_quantity, l_transaction_uom,
	l_transaction_header_id, l_transaction_action_id, l_transaction_source_type_id,
	l_transaction_source,
	l_reservation_id, l_mo_line_id, l_allocated_lpn_id
   FROM mtl_material_transactions_temp
   WHERE transaction_temp_id = l_transaction_temp_id;

      IF (l_debug = 1) THEN
         mdebug('after select from mmtt ');
      END IF;

   -- if the input variable is not null, populate the local
   -- variable with the input variable
   IF p_destination_organization_id IS NOT NULL THEN
      l_destination_organization_id := p_destination_organization_id;
   END IF;

   IF p_source_subinventory IS NOT NULL THEN
      l_source_subinventory := p_source_subinventory;
   END IF;

   IF p_destination_subinventory IS NOT NULL THEN
      l_destination_subinventory := p_destination_subinventory;
   END IF;

   IF p_source_locator IS NOT NULL THEN
      l_source_locator := p_source_locator;
   END IF;

   IF p_destination_locator IS NOT NULL THEN
      l_destination_locator := p_destination_locator;
   END IF;

   IF p_lpn_id IS NOT NULL THEN
      l_lpn_id := p_lpn_id;
   END IF;

   IF p_content_lpn_id IS NOT NULL THEN
      l_content_lpn_id := p_content_lpn_id;
   END IF;

   l_error := 1;

   -- get content lpn status,

   IF (l_debug = 1) THEN
      mdebug(' l_content_lpn_id '||l_content_lpn_id);
      mdebug(' p_content_lpn_status '||p_content_lpn_status);
   END IF;
   IF l_content_lpn_id IS NOT NULL AND l_content_lpn_id > 0 THEN
      IF p_content_lpn_status IS NULL THEN
	 BEGIN
	    SELECT status_id
	      INTO l_content_lpn_status
	      FROM wms_license_plate_numbers
	      WHERE lpn_id = l_content_lpn_id
	      AND organization_id = p_source_organization_id;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
   	       mdebug('Exception occurred '||Sqlerrm);
   	       mdebug('while getting the content lpn status');
	       END IF;
	 END;

       ELSE
	       l_content_lpn_status := p_content_lpn_status;
      END IF;
   END IF;

   l_error := 2;

   -- for source lpn: get lpn name, parent lpn id and outermost lpn id and status id
   -- and then replace local variables with input parameters
   -- where input parameters are not null
   IF (l_debug = 1) THEN
      mdebug('l_lpn_id '||l_lpn_id);
   END IF;
   IF l_lpn_id IS NOT NULL  AND l_lpn_id > 0 THEN
      BEGIN
	 SELECT license_plate_number, parent_lpn_id, outermost_lpn_id, status_id
	   INTO l_lpn_n, l_source_parent_lpn_id, l_source_outermost_lpn_id,
	   l_lpn_status
	   FROM wms_license_plate_numbers
	   WHERE lpn_id = l_lpn_id
	   AND organization_id = p_source_organization_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
   	    mdebug('Exception occurred '||Sqlerrm);
   	    mdebug('for source lpn: get lpn name, parent lpn id and outermost lpn id and status id');
	    END IF;
      END;

   END IF;

   IF p_source_parent_lpn_id IS NOT NULL THEN
      l_source_parent_lpn_id := p_source_parent_lpn_id;
   END IF;

   IF p_source_outermost_lpn_id IS NOT NULL THEN
      l_source_outermost_lpn_id := p_source_outermost_lpn_id;
   END IF;

   IF p_lpn_status IS NOT NULL THEN
      l_lpn_status := p_lpn_status;
   END IF;

   l_error := 3;
   -- get source parent lpn status id
   IF l_source_parent_lpn_id IS NOT NULL THEN
      IF p_source_parent_lpn_status IS NULL THEN
	 SELECT status_id
	   INTO l_source_parent_lpn_status
	   FROM wms_license_plate_numbers
	   WHERE lpn_id = l_source_parent_lpn_id
	   AND organization_id = p_source_organization_id;
       ELSE
	 l_source_parent_lpn_status := p_source_parent_lpn_status;
      END IF;
   END IF;

   l_error := 4;
   -- get source outermost status id
   IF l_source_outermost_lpn_id IS NOT NULL THEN
     IF p_source_outermost_lpn_status IS NULL THEN
	SELECT status_id
	  INTO l_source_outermost_lpn_status
	  FROM wms_license_plate_numbers
	  WHERE lpn_id = l_source_outermost_lpn_id
	  AND organization_id = p_source_organization_id;
      ELSE
	l_source_outermost_lpn_id := p_source_outermost_lpn_id;
     END IF;
   END IF;


   IF p_dest_lpn_id IS NOT NULL THEN
       l_dest_lpn_id := p_dest_lpn_id;
   END IF;

   l_error := 5;

   -- for dest lpn: get parent lpn id and outermost lpn id and status id
   -- and then replace local variables with input parameters
   -- where input parameters are not null
   IF l_dest_lpn_id IS NOT NULL THEN
      SELECT parent_lpn_id, outermost_lpn_id, status_id
	INTO l_dest_parent_lpn_id, l_dest_outermost_lpn_id,
	     l_dest_lpn_status
	FROM wms_license_plate_numbers
	WHERE lpn_id = l_dest_lpn_id
	AND organization_id = p_source_organization_id;
   END IF;

   IF p_dest_parent_lpn_id IS NOT NULL THEN
      l_dest_parent_lpn_id := p_dest_parent_lpn_id;
   END IF;

   IF p_dest_outermost_lpn_id IS NOT NULL THEN
      l_dest_outermost_lpn_id := p_dest_outermost_lpn_id;
   END IF;

   IF p_dest_lpn_status IS NOT NULL THEN
      l_dest_lpn_status := p_dest_lpn_status;
   END IF;

   l_error := 6;
    -- get dest parent lpn status id
   IF l_dest_parent_lpn_id IS NOT NULL THEN
      IF p_dest_parent_lpn_status IS NULL THEN
	 SELECT status_id
	   INTO l_dest_parent_lpn_status
	   FROM wms_license_plate_numbers
	   WHERE lpn_id = l_dest_parent_lpn_id
	   AND organization_id = p_source_organization_id;
       ELSE
	 l_dest_parent_lpn_status := p_dest_parent_lpn_status;
      END IF;
   END IF;

   l_error := 7;

   -- get dest outermost lpn status id
   IF l_dest_outermost_lpn_id IS NOT NULL THEN
     IF p_dest_outermost_lpn_status IS NULL THEN
	SELECT status_id
	  INTO l_dest_outermost_lpn_status
	  FROM wms_license_plate_numbers
	  WHERE lpn_id = l_dest_outermost_lpn_id
	  AND organization_id = p_source_organization_id;
      ELSE
	l_dest_outermost_lpn_id := p_dest_outermost_lpn_id;
     END IF;
   END IF;
   l_error := 8;
   -- get source subinventory status
   IF l_source_subinventory IS NOT NULL THEN
      IF p_source_subinventory_status IS NULL THEN
	 SELECT status_id
	   INTO l_source_subinventory_status
	   FROM mtl_secondary_inventories
	   WHERE secondary_inventory_name = l_source_subinventory
	   AND organization_id = p_source_organization_id;
       ELSE
	 l_source_subinventory_status := p_source_subinventory_status;
      END IF;
   END IF;
   l_error := 9;
     -- get destination subinventory status
   IF (l_destination_subinventory IS NOT NULL AND
       l_destination_organization_id IS NOT NULL) THEN
      IF p_destination_subinventory_st IS NULL THEN
	 SELECT status_id
	   INTO l_destination_subinventory_st
	   FROM mtl_secondary_inventories
	   WHERE secondary_inventory_name = l_destination_subinventory
	   AND organization_id = l_destination_organization_id;
       ELSE
	 l_destination_subinventory_st := p_destination_subinventory_st;
      END IF;
   END IF;
   l_error := 10;
    -- get source locator status
   IF l_source_locator IS NOT NULL THEN
      IF p_source_locator_status IS NULL THEN
	 SELECT status_id
	   INTO l_source_locator_status
	   FROM mtl_item_locations
	   WHERE  inventory_location_id = l_source_locator
	   AND organization_id = p_source_organization_id;
       ELSE
	 l_source_locator_status := p_source_locator_status;
      END IF;
   END IF;
   l_error := 11;
      -- get destination locator status
   IF (l_destination_locator IS NOT NULL
       AND l_destination_organization_id IS NOT NULL) THEN
      IF p_destination_locator_status IS NULL THEN
	 SELECT status_id
	   INTO l_destination_locator_status
	   FROM mtl_item_locations
	   WHERE inventory_location_id = l_destination_locator
	   AND organization_id = l_destination_organization_id;
       ELSE
	 l_destination_locator_status := p_destination_locator_status;
      END IF;
   END IF;
   l_error := 12;

   IF p_inventory_item_id IS NOT NULL THEN
       l_inventory_item_id := p_inventory_item_id;
   END IF;

   IF p_serial_number IS NOT NULL THEN
       l_serial_number := p_serial_number;
   END IF;

   IF p_lot_number IS NOT NULL THEN
      l_lot_number := p_lot_number;
   END IF;
   l_error := 13;
   -- get status id for serial and lot numbers
   IF (l_inventory_item_id IS NOT NULL
       AND l_serial_number IS NOT NULL) THEN
      IF p_serial_number_status IS NULL THEN
	 SELECT status_id
	   INTO l_serial_number_status
	   FROM mtl_serial_numbers
	   WHERE serial_number = l_serial_number
	   AND inventory_item_id = l_inventory_item_id;
       ELSE
	 l_serial_number_status := p_serial_number_status;
      END IF;
   END IF;

   IF (l_inventory_item_id IS NOT NULL
       AND l_lot_number IS NOT NULL) THEN
      IF p_lot_status IS NULL THEN
	 SELECT status_id
	   INTO l_lot_status
	   FROM mtl_lot_numbers
	   WHERE lot_number = l_lot_number
	   AND inventory_item_id = l_inventory_item_id
	   AND organization_id = p_source_organization_id;
       ELSE
	 l_lot_status := p_lot_status;
      END IF;
   END IF;
   l_error := 14;
   -- get inventory_item_name from inventory_item_id
   IF (l_inventory_item_id IS NOT NULL) THEN
       SELECT concatenated_segments
	   INTO l_inventory_item_name
	   FROM mtl_system_items_kfv
	 WHERE inventory_item_id = l_inventory_item_id
	 AND organization_id = p_source_organization_id;
   END IF;
   l_error := 15;
   -- verify that the rest of the input parameters that are not
   -- null are copied to the local variables


   IF p_revision IS NOT NULL THEN
      l_revision := p_revision;
   END IF;


   IF p_to_lot_number IS NOT NULL THEN
       l_to_lot_number := p_to_lot_number;
   END IF;


    IF p_to_serial_number IS NOT NULL THEN
       l_to_serial_number := p_to_serial_number;
    END IF;

    IF p_primary_uom IS NOT NULL THEN
       l_primary_uom := p_primary_uom;
    END IF;

    IF p_transaction_uom IS NOT NULL THEN
       l_transaction_uom := p_transaction_uom;
    END IF;

    IF p_primary_quantity IS NOT NULL THEN
       l_primary_quantity := p_primary_quantity;
    END IF;

    IF p_transaction_quantity IS NOT NULL THEN
       l_transaction_quantity := p_transaction_quantity;
    END IF;

    IF p_transaction_action_id IS NOT NULL THEN
       l_transaction_action_id := p_transaction_action_id;
    END IF;

    IF p_transaction_source_type_id IS NOT NULL THEN
       l_transaction_source_type_id := p_transaction_source_type_id;
    END IF;

    IF p_transaction_source IS NOT NULL THEN
       l_transaction_source := p_transaction_source;
    END IF;

    IF p_reservation_id IS NOT NULL THEN
       l_reservation_id := p_reservation_id;
    END IF;

    IF p_equipment_id IS NOT NULL THEN
       l_equipment_id := p_equipment_id;
    END IF;

    IF p_user_id IS NOT NULL THEN
       l_user_id := p_user_id;
    END IF;

      l_error := 16;
    -- get user name from user_id
    IF (l_user_id IS NOT NULL) THEN
       SELECT user_name
	 INTO l_user_name
	 FROM fnd_user
	 WHERE user_id = l_user_id;
   END IF;
   l_error := 17;

   -- get source org name
   select organization_code
     INTO l_source_organization_n
     from mtl_parameters
     where organization_id=p_source_organization_id;
   l_error :=18;

   -- get source locator name
   IF (l_source_locator IS NOT NULL) THEN
      select concatenated_segments
	INTO l_source_locator_n
	from mtl_item_locations_kfv
	where inventory_location_id = l_source_locator
	and organization_id = p_source_organization_id;
   END IF;
   l_error:=19;

    IF p_task_type_id IS NOT NULL THEN
       l_task_type_id := p_task_type_id;
    END IF;

    IF p_update_status_method IS NOT NULL THEN
       l_update_status_method := p_update_status_method;
    END IF;

    IF p_program_control_arg1 IS NOT NULL THEN
       l_program_control_arg1 := p_program_control_arg1;
    END IF;

    IF p_program_control_arg2 IS NOT NULL THEN
       l_program_control_arg2 := p_program_control_arg2;
    END IF;

    IF p_program_control_arg3 IS NOT NULL THEN
       l_program_control_arg3 := p_program_control_arg3;
    END IF;

    IF p_program_control_arg4 IS NOT NULL THEN
       l_program_control_arg4 := p_program_control_arg4;
    END IF;

    IF p_program_control_arg5 IS NOT NULL THEN
       l_program_control_arg5 := p_program_control_arg5;
    END IF;

    IF p_program_control_arg6 IS NOT NULL THEN
       l_program_control_arg6 := p_program_control_arg6;
    END IF;

    --check to see if local variables populated before calling workflow
    IF (l_debug = 1) THEN
       mdebug('Checking the 47 input parameters...');
       mdebug('P_reason_id: '||p_reason_id);
       mdebug('P_CALLING_PROGRAM_NAME: '|| p_calling_program_name);
       mdebug('P_source_organization_id: '|| p_source_organization_id);
       mdebug('P_source_organization_name: '|| l_source_organization_n);
       mdebug('L_REASON_NAME: '|| l_reason_name);
       mdebug('L_DESTINATION_ORGANIZATION_ID: '||l_destination_organization_id);
       mdebug('L_SOURCE_SUBINVENTORY: '||l_source_subinventory);
       mdebug('L_SOURCE_SUBINVENTORY_STATUS: '||l_source_subinventory_status);
       mdebug('L_DESTINATION_SUBINVENTORY: '||l_destination_subinventory);
       mdebug('L_DESTINATION_SUBINVENTORY_ST: '||l_destination_subinventory_st);
       mdebug('L_SOURCE_LOCATOR: '||l_source_locator);
       mdebug('L_SOURCE_LOCATOR_NAME: '||l_source_locator_n);
       mdebug('L_SOURCE_LOCATOR_STATUS: '||l_source_locator_status);
       mdebug('L_DESTINATION_LOCATOR: '||L_DESTINATION_LOCATOR);
       mdebug('L_DESTINATION_LOCATOR_STATUS: '||l_destination_locator_status);
       mdebug('L_LPN_ID: '||l_lpn_id);
       mdebug('L_LPN_NAME: '||l_lpn_n);
       mdebug('L_LPN_STATUS: '||l_lpn_status);
       mdebug('L_CONTENT_LPN_ID: '||l_content_lpn_id);
       mdebug('L_CONTENT_LPN_STATUS: '||l_content_lpn_status);
       mdebug('L_source_parent_lpn_id: '||l_source_parent_lpn_id);
       mdebug('L_SOURCE_parent_LPN_STATUS: '||l_source_parent_lpn_status);
       mdebug('L_SOURCE_OUTERMOST_LPN_ID: '||l_source_outermost_lpn_id);
       mdebug('L_SOURCE_OUTERMOST_LPN_STATUS: '||l_source_outermost_lpn_status);
       mdebug('L_dest_lpn_id: '||l_dest_lpn_id);
       mdebug('L_dest_lpn_status: '||l_dest_lpn_status);
       mdebug('L_dest_parent_lpn_id: '||l_dest_parent_lpn_id);
       mdebug('L_dest_parent_lpn_status: '||l_dest_parent_lpn_status);
       mdebug('L_DEST_OUTERMOST_LPN_ID: '||l_dest_outermost_lpn_id);
       mdebug('L_DEST_OUTERMOST_LPN_STATUS: '||l_dest_outermost_lpn_status);
       mdebug('L_INVENTORY_ITEM_ID: '||l_inventory_item_id);
       mdebug('L_INVENTORY_ITEM_NAME: '||l_inventory_item_name);
       mdebug('L_REVISION: '||l_revision);
       mdebug('L_LOT_NUMBER: '||l_lot_number);
       mdebug('L_to_lot_number: '||l_to_lot_number);
       mdebug('L_LOT_STATUS: '||l_lot_status);
       mdebug('L_SERIAL_NUMBER: '||l_serial_number);
       mdebug('L_to_serial_number: '||l_to_serial_number);
       mdebug('L_serial_number_status: '||l_serial_number_status);
       mdebug('L_PRIMARY_UOM: '||l_primary_uom);
       mdebug('L_TRANSACTION_UOM: '||l_transaction_uom);
       mdebug('L_PRIMARY_QUANTITY: '||l_primary_quantity);
       mdebug('L_TRANSACTION_QUANTITY: '||l_transaction_quantity);
       mdebug('L_TRANSACTION_HEADER_ID: '||l_transaction_header_id);
       mdebug('L_TRANSACTION_MO_LINE_ID: '||l_mo_line_id);
       mdebug('L_TRANSACTION_ACTION_ID: '||l_transaction_action_id);
       mdebug('L_TRANSACTION_SOURCE_TYPE_ID: '||l_transaction_source_type_id);
       mdebug('L_TRANSACTION_SOURCE: '||l_transaction_source);
       mdebug('L_RESERVATION_ID: '||l_reservation_id);
       mdebug('L_EQUIPMENT_ID: '||l_equipment_id);
       mdebug('L_USER_ID: '||l_user_id);
       mdebug('L_USER_NAME: '||l_user_name);
       mdebug('L_TASK_TYPE_ID: '||l_task_type_id);
       mdebug('L_TASK_ID: '|| l_task_id);
       mdebug('L_transaction_temp_id: '|| l_transaction_temp_id);
       mdebug('L_update_status_method: '||l_update_status_method);
       mdebug('l_program_control_arg1: '||l_program_control_arg1);
       mdebug('l_program_control_arg2: '||l_program_control_arg2);
       mdebug('l_program_control_arg3: '||l_program_control_arg3);
       mdebug('l_program_control_arg4: '||l_program_control_arg4);
       mdebug('l_program_control_arg5: '||l_program_control_arg5);
       mdebug('l_program_control_arg6: '||l_program_control_arg6);
    END IF;


    -- calling workflow

    -- make sure that reason name is not null
    if (p_reason_id is null ) then
       fnd_message.set_name('INV','INV_FIELD_INVALID');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    end if;

  IF (l_debug = 1) THEN
     mdebug('Before Select WORKFLOW_NAME, WORKFLOW_PROCESS ');
  END IF;
  -- get workflow_name and workflow_process from mtl_transaction_reasons.
  -- This is needed to create the workflow process
  SELECT WORKFLOW_NAME, WORKFLOW_PROCESS
    INTO  l_workflow_name, l_workflow_process
    FROM MTL_TRANSACTION_REASONS
    WHERE REASON_ID  = P_REASON_ID ;

  IF (l_debug = 1) THEN
     mdebug('Workflow name is: '|| l_workflow_name);
     mdebug('Workflow process: '|| l_workflow_process);
  END IF;

  -- generate item key using sequence number and concat with txnworkflow 'twflow'.
  -- This is needed to create the workflow process
  SELECT WMS_DISPATCHED_TASKS_S.nextval INTO l_sequence_number FROM DUAL ;

  l_item_key := 'twflow' || l_sequence_number ;
  IF (l_debug = 1) THEN
     mdebug('Item key is: '|| l_item_key);
  END IF;

  -- initialize workflow
  wf_engine.CreateProcess(itemtype	=>	l_workflow_name,
			  itemkey	=>	l_item_key,
			  process	=>	l_workflow_process);

  -- set the attribute values of workflow with the local parameters
  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_REASON_ID',
			      avalue	=>	P_REASON_ID);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_CALLING_PROGRAM_NAME',
			    avalue	=>	P_CALLING_PROGRAM_NAME);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_SOURCE_ORGANIZATION_ID',
			      avalue	=>	P_SOURCE_ORGANIZATION_ID);
  l_error:=100;
  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_SOURCE_ORGANIZATION_N',
			    avalue	=>	L_SOURCE_ORGANIZATION_N);
  l_error:=101;
  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_REASON_NAME',
			    avalue	=>	L_REASON_NAME);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_DESTINATION_ORGANIZATION_ID',
			      avalue	=>      L_DESTINATION_ORGANIZATION_ID);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_SOURCE_SUBINVENTORY',
			    avalue	=>	L_SOURCE_SUBINVENTORY);

  wf_engine.setitemattrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_SOURCE_SUBINVENTORY_STATUS',
			      avalue	=>	L_SOURCE_SUBINVENTORY_STATUS);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_DESTINATION_SUBINVENTORY',
			    avalue	=>	L_DESTINATION_SUBINVENTORY);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_DESTINATION_SUBINVENTORY_ST',
			      avalue	=>	L_DESTINATION_SUBINVENTORY_ST);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_SOURCE_LOCATOR',
			      avalue	=>	L_SOURCE_LOCATOR);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_SOURCE_LOCATOR_N',
			      avalue	=>	L_SOURCE_LOCATOR_N);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_SOURCE_LOCATOR_STATUS',
			      avalue	=>	L_SOURCE_LOCATOR_STATUS);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_DESTINATION_LOCATOR',
			      avalue	=>	L_DESTINATION_LOCATOR);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_DESTINATION_LOCATOR_STATUS',
			    avalue	=>	L_DESTINATION_LOCATOR_STATUS);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_LPN_ID',
			      avalue	=>	L_LPN_ID);

   wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_LPN_N',
			      avalue	=>	L_LPN_N);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_LPN_STATUS',
			      avalue	=>	L_LPN_STATUS);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_CONTENT_LPN_ID',
			      avalue	=>	L_CONTENT_LPN_ID);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_CONTENT_LPN_STATUS',
			      avalue	=>	L_CONTENT_LPN_STATUS);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_SOURCE_PARENT_LPN_ID',
			      avalue	=>	L_SOURCE_PARENT_LPN_ID);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_SOURCE_PARENT_LPN_STATUS',
			      avalue	=>	L_SOURCE_PARENT_LPN_STATUS);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_SOURCE_OUTERMOST_LPN_ID',
			      avalue	=>	L_SOURCE_OUTERMOST_LPN_ID);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_SOURCE_OUTERMOST_LPN_STATUS',
			      avalue	=>	L_SOURCE_OUTERMOST_LPN_STATUS);

 wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_DEST_LPN_ID',
			      avalue	=>	L_DEST_LPN_ID);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_DEST_LPN_STATUS',
			      avalue	=>	L_DEST_LPN_STATUS);

   wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_DEST_PARENT_LPN_ID',
			      avalue	=>	L_DEST_PARENT_LPN_ID);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_DEST_PARENT_LPN_STATUS',
			      avalue	=>	L_DEST_PARENT_LPN_STATUS);

   wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_DEST_OUTERMOST_LPN_ID',
			      avalue	=>	L_DEST_OUTERMOST_LPN_ID);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_DEST_OUTERMOST_LPN_STATUS',
			      avalue	=>	L_DEST_OUTERMOST_LPN_STATUS);

--Bug 7504490 l_allocated_lpn_id
  wf_engine.SetItemAttrNumber(itemtype => l_workflow_name,
                               itemkey => l_item_key,
                               aname => 'PW_ALLOCATED_LPN_ID',
                               avalue => l_allocated_lpn_id);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_INVENTORY_ITEM_ID',
			      avalue	=>	L_INVENTORY_ITEM_ID);

  wf_engine.setitemattrtext(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_INVENTORY_ITEM_NAME',
			      avalue	=>	L_INVENTORY_ITEM_NAME);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_REVISION',
			    avalue	=>	L_REVISION);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_LOT_NUMBER',
			    avalue	=>	L_LOT_NUMBER);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_TO_LOT_NUMBER',
			    avalue	=>	L_TO_LOT_NUMBER);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_LOT_STATUS',
			      avalue	=>	L_LOT_STATUS);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_SERIAL_NUMBER',
			    avalue	=>	L_SERIAL_NUMBER);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_TO_SERIAL_NUMBER',
			    avalue	=>	L_TO_SERIAL_NUMBER);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_SERIAL_NUMBER_STATUS',
			      avalue	=>	L_SERIAL_NUMBER_STATUS);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_PRIMARY_UOM',
			    avalue	=>	L_PRIMARY_UOM);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_TRANSACTION_UOM',
			    avalue	=>	L_TRANSACTION_UOM);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_PRIMARY_QUANTITY',
			      avalue	=>	L_PRIMARY_QUANTITY);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_TRANSACTION_QUANTITY',
			      avalue	=>	L_TRANSACTION_QUANTITY);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_TRANSACTION_HEADER_ID',
			      avalue	=>	L_TRANSACTION_HEADER_ID);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_TRANSACTION_MO_LINE_ID',
			      avalue	=>	L_MO_LINE_ID);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_TRANSACTION_ACTION_ID',
			      avalue	=>	L_TRANSACTION_ACTION_ID);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_TRANSACTION_SOURCE_TYPE_ID',
			      avalue	=>	L_TRANSACTION_SOURCE_TYPE_ID);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_TRANSACTION_SOURCE',
			      avalue	=>	L_TRANSACTION_SOURCE);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_RESERVATION_ID',
			      avalue	=>	L_RESERVATION_ID);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_EQUIPMENT_ID',
			      avalue	=>	L_EQUIPMENT_ID);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_USER_ID',
			      avalue	=>	L_USER_ID);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_USER_NAME',
			      avalue	=>	L_USER_NAME);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_TASK_TYPE_ID',
			      avalue	=>	L_TASK_TYPE_ID);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_TASK_ID',
			      avalue	=>	L_TASK_ID);

  wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			      itemkey	=>	l_item_key,
			      aname	=>	'PW_TXN_TEMP_ID',
			      avalue	=>	L_transaction_temp_id);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_UPDATE_STATUS_METHOD',
			    avalue	=>	L_UPDATE_STATUS_METHOD);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_PROGRAM_CONTROL_ARG1',
			    avalue	=>	L_PROGRAM_CONTROL_ARG1);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_PROGRAM_CONTROL_ARG2',
			    avalue	=>	L_PROGRAM_CONTROL_ARG2);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_PROGRAM_CONTROL_ARG3',
			    avalue	=>	L_PROGRAM_CONTROL_ARG3);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_PROGRAM_CONTROL_ARG4',
			    avalue	=>	L_PROGRAM_CONTROL_ARG4);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_PROGRAM_CONTROL_ARG5',
			    avalue	=>	L_PROGRAM_CONTROL_ARG5);

  wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'PW_PROGRAM_CONTROL_ARG6',
			    avalue	=>	L_PROGRAM_CONTROL_ARG6);

   -- start workflow
  IF (l_debug = 1) THEN
     mdebug('Before wf_engine.StartProcess of: ' || l_workflow_name);
  END IF;
  wf_engine.StartProcess (itemtype	=>	l_workflow_name,
			  itemkey	=>	l_item_key);



  -- on completion of the workflow, the output parameters are populated with the
  -- workflow attribute values
  X_RETURN_STATUS	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				 	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_RETURN_STATUS');

  X_MSG_DATA	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_MSG_DATA');

  X_MSG_COUNT	:= wf_engine.GetItemAttrNumber(itemtype	=>	l_workflow_name,
				    	       itemkey	=>	l_item_key,
				    	       aname	=>      'XW_MSG_COUNT');

  X_ORGANIZATION_ID:= wf_engine.GetItemAttrNumber(itemtype=>	l_workflow_name,
				    		itemkey	=>	l_item_key,
				    		aname	=>	'XW_ORGANIZATION_ID');

  X_SUBINVENTORY	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_SUBINVENTORY');

  X_SUBINVENTORY_STATUS:=wf_engine.GetItemAttrNumber(itemtype=>	l_workflow_name,
				  		 itemkey =>	l_item_key,
				  		 aname	 =>	'XW_SUBINVENTORY_STATUS');

  X_LOCATOR	:= wf_engine.GetItemAttrNumber(itemtype	=>	l_workflow_name,
				    	       itemkey	=>	l_item_key,
				    	       aname	=>	'XW_LOCATOR');

  X_LOCATOR_STATUS:= wf_engine.GetItemAttrNumber(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_LOCATOR_STATUS');

  X_LPN_ID 	:= wf_engine.GetItemAttrNumber(itemtype	=>	l_workflow_name,
				    	       itemkey	=>	l_item_key,
				    	       aname	=>	'XW_LPN_ID');

  X_LPN_STATUS	:= wf_engine.GetItemAttrNumber(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
					       aname	=>      'XW_LPN_STATUS');

  X_INVENTORY_ITEM_ID:=wf_engine.GetItemAttrNumber(itemtype=>	l_workflow_name,
				    		 itemkey =>	l_item_key,
				    		 aname	 =>     'XW_INVENTORY_ITEM_ID');

  X_REVISION	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_REVISION');

  X_LOT_NUMBER	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_LOT_NUMBER');

  X_LOT_STATUS	:= wf_engine.GetItemAttrNumber(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
					       aname	=>	'XW_LOT_STATUS');

  X_QUANTITY	:= wf_engine.GetItemAttrNumber(itemtype	=>	l_workflow_name,
				    	       itemkey	=>	l_item_key,
				    	       aname	=>      'XW_QUANTITY');

  X_UOM_CODE	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				  	     itemkey	=>	l_item_key,
				  	     aname	=>	'XW_UOM_CODE');

  X_PRIMARY_QUANTITY:=wf_engine.GetItemAttrNumber(itemtype=>	l_workflow_name,
				    	        itemkey	=>	l_item_key,
				    	        aname	=>	'XW_PRIMARY_QUANTITY');

  X_TRANSACTION_QUANTITY:=wf_engine.GetItemAttrNumber(itemtype=>	l_workflow_name,
				    		    itemkey =>	l_item_key,
				    		    aname   =>  'XW_TRANSACTION_QUANTITY');

  X_RESERVATION_ID   := wf_engine.GetItemAttrNumber(itemtype=>	l_workflow_name,
						  itemkey	=>	l_item_key,
						  aname	=>	'XW_RESERVATION_ID');
BEGIN
   UPDATE wms_exceptions
     SET
     wf_item_key = l_item_key
     WHERE
     transaction_header_id = l_transaction_header_id;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         mdebug('exception while updating the workflow item key ');
      END IF;
END;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 1) THEN
         mdebug('exception:FND_API.G_EXC_ERROR at l_error: '||l_error);
      END IF;
      ROLLBACK TO wf_start_workflow_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				,p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF (l_debug = 1) THEN
          mdebug('exception:  FND_API.G_EXC_UNEXPECTED_ERROR at l_error: '||l_error);
       END IF;
      ROLLBACK TO wf_start_workflow_pvt;
     	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				  ,p_data => x_msg_data);

     WHEN OTHERS THEN
	IF (l_debug = 1) THEN
   	mdebug('exception: in when otheres at l_error: '||l_error);
	END IF;
	ROLLBACK TO wf_start_workflow_pvt;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     	END IF;
     	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				  , p_data => x_msg_data);
END wf_start_workflow;


PROCEDURE WF_SUGGEST_ALT_LOC    (itemtype	IN	VARCHAR2,
				 itemkey	        IN	VARCHAR2,
				 actid		IN	NUMBER,
				 funcmode	IN	VARCHAR2,
				 result		OUT NOCOPY	VARCHAR2)
IS

-- local variables
   l_workflow_name                     VARCHAR2(250) ;
   l_item_key                        VARCHAR2(250) ;
   lp_api_version_number             NUMBER := 1.0;
   lp_init_msg_lst                   VARCHAR2(250) := FND_API.G_FALSE;
   lp_commit                         VARCHAR2(250) := FND_API.G_FALSE;
   lx_return_status                  VARCHAR2(1) ;
   lx_msg_count                      NUMBER   ;
   lx_msg_data                       VARCHAR2(250);
   lp_organization_id                NUMBER;
   lp_task_id                        NUMBER;
   lp_qty_picked                     NUMBER := 0;
   lp_qty_uom                        VARCHAR2(3);
   lp_carton_id                      VARCHAR2(250) := NULL;
   lp_user_id                        VARCHAR2(250);
   lp_reason_id                      NUMBER;
   lp_mmtt_id                         NUMBER;
   lp_locator_id                      NUMBER;
   lp_sub_code                        VARCHAR2(10);
   lp_line_num                         NUMBER;


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
      IF (l_debug = 1) THEN
         mdebug('In WMS_Suggest_Alt_Loc');
      END IF;

      l_workflow_name := itemtype;
      l_item_key := itemkey;


-- populating the local procedure variables with the corresponding attributes from workflow
   lp_organization_id	:= wf_engine.GetItemAttrNumber(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
						       aname	=> 'PW_SOURCE_ORGANIZATION_ID');

   lp_task_id	        := wf_engine.GetItemAttrNumber(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
                                                       aname	=> 'PW_TASK_ID');

   -- MRANA: added this to get the temp_id instead of querying WDT to get it
   -- ALSO ,. deleted the query to wdt to get the temp_id based on task_id (pw_task_id)
   lp_mmtt_id	        := wf_engine.GetItemAttrNumber(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
                                                       aname	=> 'PW_TXN_TEMP_ID');

   lp_qty_picked	:= wf_engine.GetItemAttrNumber(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
						       aname	=> 'PW_TRANSACTION_QUANTITY');

   lp_qty_uom	        := wf_engine.GetItemAttrText(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
						       aname	=> 'PW_TRANSACTION_UOM');

   lp_carton_id	        := wf_engine.getItemAttrText(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
						       aname	=> 'PW_LPN_ID');

   lp_user_id	        := wf_engine.GetItemAttrText(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
                                                       aname	=> 'PW_USER_ID');

   lp_reason_id	        := wf_engine.GetItemAttrNumber(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
                                                       aname	=> 'PW_REASON_NAME');
  IF (l_debug = 1) THEN
     mdebug('before select temp id');
  END IF;
-- get data to call suggest_alternate_locatoin

   SELECT subinventory_code,locator_id, move_order_line_id
   INTO lp_sub_code,lp_locator_id, lp_line_num
     FROM  mtl_material_transactions_temp
     WHERE transaction_temp_id=lp_mmtt_id;
   IF (l_debug = 1) THEN
      mdebug('before calling wms_txnrsn_actions_pub.suggest_alternate_location ');
   END IF;

   g_return_status := FND_API.G_RET_STS_SUCCESS; --Bug 6116046
   mdebug('Setting g_return_status to success');
   wms_txnrsn_actions_pub.suggest_alternate_location
                          (p_api_version_number          =>lp_api_version_number
                         , p_init_msg_lst                =>lp_init_msg_lst
                         , p_commit                      =>lp_commit
                         , x_return_status               =>lx_return_status
                         , x_msg_count                   =>lx_msg_count
                         , x_msg_data                    =>lx_msg_data
                         , p_organization_id             =>lp_organization_id
                         , p_mmtt_id                     =>lp_mmtt_id
                         , p_task_id                     =>lp_task_id
                         , p_subinventory_code           =>lp_sub_code
                         , p_locator_id                  =>lp_locator_id
                         , p_carton_id                   =>lp_carton_id
                         , p_user_id                     =>lp_user_id
                         , p_qty_picked                  =>lp_qty_picked
                         , p_line_num                    =>lp_line_num
                         );

   IF (l_debug = 1) THEN
      mdebug('After calling wms_txnrsn_actions_pub.suggest_alternate_location');
   END IF;
   -- setting the workflow attributes with the output results of
   -- the API wms_txnrsn_actions_pub.Inadequate_Qty
   wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			     itemkey	=>	l_item_key,
			     aname	=>	'XW_RETURN_STATUS',
			     avalue	=>	lx_return_status);

   wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			       itemkey	=>	l_item_key,
			       aname	=>	'XW_MSG_COUNT',
			       avalue	=>	lx_msg_count);

   wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			     itemkey	=>	l_item_key,
			     aname	=>	'XW_MSG_DATA',
			     avalue	=>	lx_msg_data);

   g_return_status := lx_return_status; --Bug 6116046
   mdebug('Setting g_returnstatus to success');
-- check for errors
   fnd_msg_pub.count_and_get
          (  p_count  => lx_msg_count
           , p_data   => lx_msg_data
             );

   IF (lx_msg_count = 0) THEN
        IF (l_debug = 1) THEN
           mdebug('Inadequate quantity successful');
        END IF;
   ELSIF (lx_msg_count = 1) THEN
       IF (l_debug = 1) THEN
          mdebug(replace(lx_msg_data,chr(0),' '));
       END IF;
   ELSE
       For I in 1..lx_msg_count LOOP
        	lx_msg_data := fnd_msg_pub.get(I,'F');
        	IF (l_debug = 1) THEN
           	mdebug(replace(lx_msg_data,chr(0),' '));
        	END IF;
       END LOOP;
   END IF;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN
      lx_return_status := fnd_api.g_ret_sts_error;
   --Bug 6116046 Begin
   mdebug('Setting g_return_status to fnd_api.g_ret_sts_error');
   g_return_status := fnd_api.g_ret_sts_error; --Bug 6116046

   mdebug('exception:  fnd_api.g_exc_error');
   mdebug('wf_suggest_alt_loc lx_return_status to ' || lx_return_status);

   wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			     itemkey	=>	l_item_key,
			     aname	=>	'XW_RETURN_STATUS',
			     avalue	=>	lx_return_status);

   wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			       itemkey	=>	l_item_key,
			       aname	=>	'XW_MSG_COUNT',
			       avalue	=>	lx_msg_count);

   wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			     itemkey	=>	l_item_key,
			     aname	=>	'XW_MSG_DATA',
			     avalue	=>	lx_msg_data);

-- check for errors
   fnd_msg_pub.count_and_get
          (  p_count  => lx_msg_count
           , p_data   => lx_msg_data
             );

   IF (lx_msg_count = 0) THEN
        IF (l_debug = 1) THEN
           mdebug('Inadequate quantity successful');
        END IF;
   ELSIF (lx_msg_count = 1) THEN
       IF (l_debug = 1) THEN
          mdebug(replace(lx_msg_data,chr(0),' '));
       END IF;
   ELSE
       For I in 1..lx_msg_count LOOP
        	lx_msg_data := fnd_msg_pub.get(I,'F');
        	IF (l_debug = 1) THEN
           	mdebug(replace(lx_msg_data,chr(0),' '));
        	END IF;
       END LOOP;
   END IF;

   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
      fnd_msg_pub.add_exc_msg
        (  g_pkg_name
           , 'WMS_Inadequate_Quantity'
        );
   END IF;


   WHEN fnd_api.g_exc_unexpected_error THEN
   lx_return_status := fnd_api.g_ret_sts_unexp_error ;

   mdebug('Setting g_return_status to fnd_api.g_ret_sts_unexp_error');

   g_return_status := fnd_api.g_ret_sts_unexp_error; --Bug 6116046

   mdebug('exception:  fnd_api.g_exc_unexpected_error');
   mdebug('wf_suggest_alt_loc lx_return_status to ' || lx_return_status);

   wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			     itemkey	=>	l_item_key,
			     aname	=>	'XW_RETURN_STATUS',
			     avalue	=>	lx_return_status);

   wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			       itemkey	=>	l_item_key,
			       aname	=>	'XW_MSG_COUNT',
			       avalue	=>	lx_msg_count);

   wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			     itemkey	=>	l_item_key,
			     aname	=>	'XW_MSG_DATA',
			     avalue	=>	lx_msg_data);

-- check for errors
   fnd_msg_pub.count_and_get
          (  p_count  => lx_msg_count
           , p_data   => lx_msg_data
             );

   IF (lx_msg_count = 0) THEN
        IF (l_debug = 1) THEN
           mdebug('Inadequate quantity successful');
        END IF;
   ELSIF (lx_msg_count = 1) THEN
       IF (l_debug = 1) THEN
          mdebug(replace(lx_msg_data,chr(0),' '));
       END IF;
   ELSE
       For I in 1..lx_msg_count LOOP
        	lx_msg_data := fnd_msg_pub.get(I,'F');
        	IF (l_debug = 1) THEN
           	mdebug(replace(lx_msg_data,chr(0),' '));
        	END IF;
       END LOOP;
   END IF;

   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
      fnd_msg_pub.add_exc_msg
        (  g_pkg_name
           , 'WMS_Inadequate_Quantity'
        );
   END IF;



   WHEN OTHERS THEN
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'WMS_Inadequate_Quantity'
              );
        END IF;


   mdebug('exception:  fnd_api.g_exc_unexpected_error');
   mdebug('wf_suggest_alt_loc lx_return_status to ' || lx_return_status);
   g_return_status := fnd_api.g_ret_sts_unexp_error; --Bug 6116046
   wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			     itemkey	=>	l_item_key,
			     aname	=>	'XW_RETURN_STATUS',
			     avalue	=>	lx_return_status);

   wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			       itemkey	=>	l_item_key,
			       aname	=>	'XW_MSG_COUNT',
			       avalue	=>	lx_msg_count);

   wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			     itemkey	=>	l_item_key,
			     aname	=>	'XW_MSG_DATA',
			     avalue	=>	lx_msg_data);

-- check for errors
   fnd_msg_pub.count_and_get
          (  p_count  => lx_msg_count
           , p_data   => lx_msg_data
             );

   IF (lx_msg_count = 0) THEN
        IF (l_debug = 1) THEN
           mdebug('Inadequate quantity successful');
        END IF;
   ELSIF (lx_msg_count = 1) THEN
       IF (l_debug = 1) THEN
          mdebug(replace(lx_msg_data,chr(0),' '));
       END IF;
   ELSE
       For I in 1..lx_msg_count LOOP
        	lx_msg_data := fnd_msg_pub.get(I,'F');
        	IF (l_debug = 1) THEN
           	mdebug(replace(lx_msg_data,chr(0),' '));
        	END IF;
       END LOOP;
   END IF;

   IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
      fnd_msg_pub.add_exc_msg
        (  g_pkg_name
           , 'WMS_Inadequate_Quantity'
        );
   END IF;

   --Bug 6116046 End

END wf_suggest_alt_loc;






/*==================================================================================*/
 --     This procedure does the following:
 --     - Creates a cycle count request when there is insufficient quantity
 --       to be picked.

PROCEDURE wf_Cycle_Count	 	        (itemtype	IN	VARCHAR2,
						 itemkey	IN	VARCHAR2,
						 actid		IN	NUMBER,
						 funcmode	IN	VARCHAR2,
						 result		OUT NOCOPY	VARCHAR2)
IS

-- local variables
x_return_status		VARCHAR2(30);
x_msg_count		NUMBER;
x_msg_data		VARCHAR2(240);

l_workflow_name         VARCHAR2(250);
l_item_key              VARCHAR2(250);

l_organization_id       NUMBER;
l_subinventory_code     VARCHAR2(250);
l_locator_id            NUMBER;
l_inventory_item_id     NUMBER;    --BUG #2867331

lmsg		varchar(300);    /*for debugging cycle count call*/
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
--Bug 7504490 l_allocated_lpn_id
l_allocated_lpn_id      NUMBER;
l_revision              VARCHAR2(250);

BEGIN
       IF (l_debug = 1) THEN
          mdebug('In Cycle_Count');
       END IF;
        -- set itemtype and itemkey to local variables
        l_workflow_name := itemtype;
        l_item_key := itemkey;


      -- set workflow attributes to local parameters
      l_organization_id	:= wf_engine.GetItemAttrNumber(itemtype	=>	l_workflow_name,
				    		     itemkey	=>	l_item_key,
				    		     aname	=>	'PW_SOURCE_ORGANIZATION_ID');

      l_subinventory_code	:= wf_engine.GetItemAttrText(itemtype	=>	l_workflow_name,
				    		     itemkey	=>	l_item_key,
				    		     aname	=>	'PW_SOURCE_SUBINVENTORY');


      l_locator_id	         := wf_engine.GetItemAttrNumber(itemtype	=>	l_workflow_name,
				    		     itemkey	=>	l_item_key,
				    		     aname	=>	'PW_SOURCE_LOCATOR');
      --BUG #2867331
      l_inventory_item_id     := wf_engine.GetItemAttrNumber(itemtype     =>  l_workflow_name,
						       itemkey      =>   l_item_key,
						       aname        =>  'PW_INVENTORY_ITEM_ID');
      --Bug 7504490 l_allocated_lpn_id
      l_allocated_lpn_id     := wf_engine.GetItemAttrNumber(itemtype     =>  l_workflow_name,
                                                        itemkey      =>   l_item_key,
                                                        aname        =>  'PW_ALLOCATED_LPN_ID');

      l_revision             := wf_engine.GetItemAttrText(itemtype     =>  l_workflow_name,
                                                        itemkey      =>   l_item_key,
                                                        aname        =>  'PW_REVISION');

       --Bug 6116046 Begin
       mdebug('g_return_status value is' || g_return_status);

       IF (g_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF (l_debug = 1) THEN
             mdebug('Throwing exception as g_return_status is not success');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --Bug 6116046 End

      IF (l_debug = 1) THEN
         mdebug('before calling wms_cycle_pvt.create_unscheduled_counts');
         mdebug('l_organization_id: '||l_organization_id);
         mdebug('l_subinventory_code: '||l_subinventory_code);
         mdebug('l_locator_id: '||l_locator_id);
         mdebug('l_inventory_item_id: '||l_inventory_item_id);  --BUG #2867331
         --Bug 7504490 l_allocated_lpn_id
	 mdebug('l_allocated_lpn_id '|| l_allocated_lpn_id);
         mdebug('l_revision '|| l_revision);

      END IF;

      -- call a cycle count request for this location.
      wms_cycle_pvt.create_unscheduled_counts
                     ( p_api_version   	    =>	    1.0,
                      p_init_msg_list	    =>	    fnd_api.g_false,
                      p_commit	      	    =>	    fnd_api.g_false,
                      x_return_status	    => 	    x_return_status,
                      x_msg_count          => 	    x_msg_count,
                      x_msg_data	    =>	    x_msg_data,
                      p_organization_id    =>      l_organization_id,
                      p_subinventory       =>      l_subinventory_code,
                      p_locator_id         =>      l_locator_id,
                      p_inventory_item_id  =>      l_inventory_item_id,  --BUG #2867331
                      p_lpn_id             =>      l_allocated_lpn_id, --Bug 7504490 l_allocated_lpn_id
                      p_revision           =>      l_revision);

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF (l_debug = 1) THEN
             mdebug('wms_cycle_pvt.create_unscheduled_counts failed');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
        IF (l_debug = 1) THEN
           mdebug('after calling wms_cycle_pvt.create_unscheduled_counts');
        END IF;
    -- debugging for cycle count

      for x in 1..x_msg_count loop
         lmsg := fnd_msg_pub.get;
         IF (l_debug = 1) THEN
            mdebug(x||':'||substr(lmsg, 0, 240));
         END IF;
      end loop;

    -- set outputs
        wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			  itemkey	=>	l_item_key,
			  aname		=>	'XW_RETURN_STATUS',
			  avalue	=>	x_return_status);

        wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'XW_MSG_COUNT',
			    avalue	=>	x_msg_count);

        wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			  itemkey	=>	l_item_key,
			  aname		=>	'XW_MSG_DATA',
			  avalue	=>	x_msg_data);

EXCEPTION

       WHEN fnd_api.g_exc_error THEN
	  IF (l_debug = 1) THEN
   	  mdebug('exc error in wf_cycle_count');
	  END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

	--Bug 6116046 Begin
	 wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			  itemkey	=>	l_item_key,
			  aname		=>	'XW_RETURN_STATUS',
			  avalue	=>	x_return_status);

        wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'XW_MSG_COUNT',
			    avalue	=>	x_msg_count);

        wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			  itemkey	=>	l_item_key,
			  aname		=>	'XW_MSG_DATA',
			  avalue	=>	x_msg_data);
	--Bug 6116046 End

       WHEN fnd_api.g_exc_unexpected_error THEN
	   IF (l_debug = 1) THEN
   	   mdebug('unexpected error in wf_cycle_count');
	   END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
	--Bug 6116046 Begin
	 wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			  itemkey	=>	l_item_key,
			  aname		=>	'XW_RETURN_STATUS',
			  avalue	=>	x_return_status);

        wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'XW_MSG_COUNT',
			    avalue	=>	x_msg_count);

        wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			  itemkey	=>	l_item_key,
			  aname		=>	'XW_MSG_DATA',
			  avalue	=>	x_msg_data);
	--Bug 6116046 End


       WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
   	    mdebug('others error in wf_cycle_count');
	    END IF;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'wf_cycle_count'
              );
        END IF;
         fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );
	--Bug 6116046 Begin
	 wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			  itemkey	=>	l_item_key,
			  aname		=>	'XW_RETURN_STATUS',
			  avalue	=>	x_return_status);

        wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			    itemkey	=>	l_item_key,
			    aname	=>	'XW_MSG_COUNT',
			    avalue	=>	x_msg_count);

        wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			  itemkey	=>	l_item_key,
			  aname		=>	'XW_MSG_DATA',
			  avalue	=>	x_msg_data);
	--Bug 6116046 End

END wf_cycle_count ;


--Checks to see if task manager is done.  if 'Y' is returned, then
-- the following variables are populated temporarily:
-- PW_PROGRAM_ARG1 = header id
-- XW_Return_Status can have value: 'Y','N' or 'E'
-- if 'E' then error out.

PROCEDURE WF_is_task_processed           (itemtype	IN	VARCHAR2,
					    itemkey	IN	VARCHAR2,
					    actid	IN	NUMBER,
					    funcmode	IN	VARCHAR2,
					    result	OUT NOCOPY     VARCHAR2)
  IS

     x_return_status		VARCHAR2(30);
     x_msg_count		NUMBER;
     x_msg_data		        VARCHAR2(240);
     lx_processed               VARCHAR2(10);

     l_workflow_name         VARCHAR2(250);
     l_item_key              VARCHAR2(250);
     l_txn_header_id NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    lx_return_status        VARCHAR2(1);
BEGIN
   IF (l_debug = 1) THEN
      mdebug('In wf_is_task_processed');
   END IF;

   -- set itemtype and itemkey to local variables
   l_workflow_name := itemtype;
   l_item_key := itemkey;

   lx_return_status := FND_API.G_RET_STS_SUCCESS;

   l_txn_header_id := wf_engine.GetItemAttrNumber(itemtype  =>	l_workflow_name,
						itemkey	  =>	l_item_key,
						aname	  =>	'PW_TRANSACTION_HEADER_ID');

   IF (l_debug = 1) THEN
      mdebug('txn header id '||l_txn_header_id);
      mdebug('before wms_task_utils_pvt.is_task_processed ');
   END IF;

    wms_task_utils_pvt.is_task_processed
      ( x_processed => lx_processed,
	p_header_id => l_txn_header_id);

    IF (l_debug = 1) THEN
       mdebug('after wms_task_utils_pvt.is_task_processed');
       mdebug('x_processed: '||lx_processed);
    END IF;

    IF (Upper(lx_processed) NOT IN ('Y','N')) THEN
       lx_return_status:= FND_API.G_RET_STS_ERROR ;
    END IF;

    -- workflow will check whether x_processed is either 'Y','N' or 'E'
    wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			     itemkey	=>	l_item_key,
			     aname	=>	'XW_RETURN_STATUS',
			     avalue	=>	lx_return_status);

    IF (Upper(lx_processed) = 'Y') THEN
       result :=wf_engine.eng_completed||':IS_TASK_PROCESS_YES';

    ELSIF (Upper(lx_processed) = 'N') THEN
       result :=wf_engine.eng_completed||':IS_TASK_PROCESS_NO';

     ELSE
       result :=wf_engine.eng_completed||':IS_TASK_PROCESS_ERROR';
       RAISE fnd_api.g_exc_error;
    END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      IF (l_debug = 1) THEN
         mdebug('exc error in wf_is_task_processed');
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	 );

       WHEN fnd_api.g_exc_unexpected_error THEN
	   IF (l_debug = 1) THEN
   	   mdebug('unexpected error in wf_is_task_processed');
	   END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );


       WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
   	    mdebug('others error in wf_is_task_processed at');
	    END IF;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'wf_is_task_processed'
              );
        END IF;
     fnd_msg_pub.count_and_get
	( p_count => x_msg_count,
	  p_data  => x_msg_data
	  );

END wf_is_task_processed ;


PROCEDURE wf_generate_next_task           (itemtype	IN	VARCHAR2,
					    itemkey	IN	VARCHAR2,
					    actid	IN	NUMBER,
					    funcmode	IN	VARCHAR2,
					    result	OUT NOCOPY     VARCHAR2)
  IS

     lx_return_status		VARCHAR2(30);
     lx_msg_count		NUMBER;
     lx_msg_data		        VARCHAR2(240);
     lx_ret_code VARCHAR2(30);
     l_workflow_name         VARCHAR2(250);
     l_item_key              VARCHAR2(250);

     l_header_id NUMBER;
     l_mo_line_id NUMBER;
     l_old_sub_code VARCHAR2(30);
     l_old_loc_id NUMBER;
     l_task_type_id NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      mdebug('in wf_generate_next_task');
   END IF;
   -- set itemtype and itemkey to local variables
   l_workflow_name := itemtype;
   l_item_key := itemkey;

   l_header_id := wf_engine.GetItemAttrNumber(itemtype    =>	l_workflow_name,
					      itemkey	  =>	l_item_key,
					      aname	  =>
					      'PW_TRANSACTION_HEADER_ID');

   l_mo_line_id := wf_engine.GetItemAttrNumber(itemtype    =>	l_workflow_name,
					      itemkey	  =>	l_item_key,
					      aname	  =>
					      'PW_TRANSACTION_MO_LINE_ID');

   l_old_sub_code := wf_engine.GetItemAttrText(itemtype      =>	l_workflow_name,
					       itemkey       =>	l_item_key,
					       aname	       =>
					       'PW_SOURCE_SUBINVENTORY');

   l_old_loc_id := wf_engine.GetItemAttrNumber(itemtype      =>	l_workflow_name,
					       itemkey	  =>	l_item_key,
					       aname	  =>
					       'PW_SOURCE_LOCATOR');

   l_task_type_id := wf_engine.GetItemAttrNumber(itemtype      =>	l_workflow_name,
					       itemkey	  =>	l_item_key,
					       aname	  =>  'PW_TASK_TYPE_ID');

   -- call generate_next_task
      IF (l_debug = 1) THEN
         mdebug('before wms_task_utils_pvt.generate_next_task');
         mdebug('header_id '||l_header_id);
         mdebug('header_id '||l_mo_line_id);
      END IF;

  wms_task_utils_pvt.generate_next_task
        ( x_return_status        =>   lx_return_status,
         x_msg_count            =>   lx_msg_count,
         x_msg_data             =>   lx_msg_data,
         x_ret_code             =>   lx_ret_code,
         p_old_header_id        =>   l_header_id,
         p_mo_line_id           =>   l_mo_line_id,
         p_old_sub_CODE         =>   l_old_sub_code,
         p_old_loc_id           =>   l_old_loc_id,
         p_wms_task_type        =>   l_task_type_id );

  IF (l_debug = 1) THEN
     mdebug('after wms_task_utils_pvt.generate_next_task');
     mdebug('x_ret_code: '||lx_ret_code);
  END IF;

  IF (lx_return_status =  fnd_api.g_ret_sts_success) THEN
     result :=wf_engine.eng_completed||':GEN_NEXT_TASK_YES';
      IF (l_debug = 1) THEN
         mdebug('In Generate Next Task -> Success');
      END IF;
   ELSE
     IF (Upper(lx_ret_code) = 'QTY_NOT_AVAIL') THEN
	result :=wf_engine.eng_completed||':GEN_NEXT_TASK_NO_QTY';
	IF (l_debug = 1) THEN
   	mdebug('In Generate Next Task -> No Available Qty');
	END IF;
      ELSE
	result :=wf_engine.eng_completed||':GEN_NEXT_TASK_ERROR';
	IF (l_debug = 1) THEN
   	mdebug('In Generate Next Task -> Error');
	END IF;
     END IF;
  END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      IF (l_debug = 1) THEN
         mdebug('exc error in wf_generate_next_task');
      END IF;
      lx_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	( p_count => lx_msg_count,
	  p_data  => lx_msg_data
	 );

       WHEN fnd_api.g_exc_unexpected_error THEN
	   IF (l_debug = 1) THEN
   	   mdebug('unexpected error in wf_generate_next_task');
	   END IF;
      lx_return_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	( p_count => lx_msg_count,
	  p_data  => lx_msg_data
	  );


       WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
   	    mdebug('others error in wf_generate_next_task');
	    END IF;
        lx_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'wf_generate_next_task'
              );
        END IF;
     fnd_msg_pub.count_and_get
	( p_count => lx_msg_count,
	  p_data  => lx_msg_data
	  );

END wf_generate_next_task;

-- This procedure does nothing.  It's just like a NOOP (a placeholder).
-- It is associated with a high cost in workflow and will be sent to the
-- background manager to be processed.
PROCEDURE wf_send_to_bg(itemtype	IN	VARCHAR2,
			itemkey	IN	VARCHAR2,
			actid	IN	NUMBER,
			funcmode IN	VARCHAR2,
			result	OUT NOCOPY     VARCHAR2)

  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      mdebug('In wf_send_to_bg');
   END IF;
END wf_send_to_bg;

     -- WMS_Insuff_Qty_Wrapper - This is a wrapper procedure that calls a workflow
-- (given a reason id).  As of now the only workflow called is 'Inadequate
-- Quantity', with reason_id=184.  This workflow needs as its input a task id,
-- hence the parameter p_tsk_id.  The parameter p_quantity_picked is the amount
-- of item(s) that was actually picked by the user.


PROCEDURE wms_insuff_qty_wrapper( p_api_version_number             IN  NUMBER
				  , x_return_status                 OUT NOCOPY VARCHAR2
				  , x_msg_count                     OUT NOCOPY NUMBER
				   , x_msg_data                      OUT NOCOPY VARCHAR2
				   , p_tsk_id                        IN  NUMBER
				   , p_user_id                       IN  VARCHAR2
				   , p_organization_id               IN  NUMBER
				   , p_rsn_id                        IN  NUMBER
				   , p_quantity_picked	             IN  NUMBER
				   )

  IS
      l_api_version		CONSTANT NUMBER := 1.0;
      l_api_name		CONSTANT VARCHAR2(30) := 'wms_insuff_qty_wrapper';

      l_inventory_item_id NUMBER;
      l_subinventory_code VARCHAR2(250);
      l_transaction_temp_id NUMBER;
      l_locator_id NUMBER;
      l_transaction_uom VARCHAR2(3);

      -- defining output variables
         lX_RETURN_STATUS		VARCHAR2(250);
	 lX_MSG_DATA			VARCHAR2(250);
    	 lX_MSG_COUNT			NUMBER;
	 lX_REVISION			VARCHAR2(250);
	 lX_LOT_NUMBER			VARCHAR2(250);
	 lX_LOT_STATUS			VARCHAR2(250);
	 lX_SUBLOT_NUMBER		VARCHAR2(250);
	 lX_SUBLOT_STATUS		VARCHAR2(250);
	 lX_LPN_ID			NUMBER;
	 lX_LPN_STATUS			VARCHAR2(250);
	 lX_UOM_CODE			VARCHAR2(250);
	 lX_QUANTITY			NUMBER;
	 lX_INVENTORY_ITEM_ID		NUMBER;
	 lX_ORGANIZATION_ID		NUMBER;
	 lX_SUBINVENTORY		VARCHAR2(250);
	 lX_SUBINVENTORY_STATUS		VARCHAR2(250);
	 lX_LOCATOR			NUMBER;
	 lX_LOCATOR_STATUS		VARCHAR2(250);
	 lX_PRIMARY_QUANTITY		NUMBER;
	 lX_TRANSACTION_QUANTITY 	NUMBER;
	 lX_NEXT_FORM			VARCHAR2(250);
	 lX_NEXT_MOBILE_FORM		VARCHAR2(250);
	 lX_NEXT_PLSQL_PROGRAM		VARCHAR2(250);
	 lX_RESERVATION_ID		NUMBER;
 	 lX_IS_RESERVATION_SUCCESSFUL	VARCHAR2(250);
	 lX_IS_CYCLE_COUNT_SUCCESSFUL	VARCHAR2(250);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     IF (l_debug = 1) THEN
        mdebug('In workflow wrapper');
     END IF;
     -- Set savepoint for this API
     SAVEPOINT wms_insuff_qty_PUB;

     -- Initialize API return status to success
     x_return_status := fnd_api.g_ret_sts_success;
     IF p_tsk_id>0 THEN
        -- get necessary data to call workflow
         SELECT transaction_temp_id
           INTO l_transaction_temp_id
           FROM wms_dispatched_tasks
           WHERE task_id=p_tsk_id;
          IF (l_debug = 1) THEN
             mdebug('l_transaction_temp_id: '|| l_transaction_temp_id);
          END IF;

         SELECT inventory_item_id, subinventory_code, transaction_uom, locator_id
           INTO l_inventory_item_id, l_subinventory_code, l_transaction_uom, l_locator_id
           FROM mtl_material_transactions_temp
           WHERE transaction_temp_id = l_transaction_temp_id;

         IF (l_debug = 1) THEN
            mdebug('l_transaction_uom: '|| l_transaction_uom);
            mdebug('After the 2 select statements');
         END IF;
         wms_txnreasons_pub.Start_Workflow(
                      P_REASON_ID			=> p_rsn_id
                      ,P_REASON_NAME			=> NULL
                      ,P_SOURCE_ORGANIZATION_ID	=> p_organization_id
                      ,P_DESTINATION_ORGANIZATION_ID	=> NULL
                      ,P_LPN_ID			=> NULL		/* = carton_id */
                      ,P_INVENTORY_ITEM_ID		=> l_inventory_item_id
                      ,P_REVISION			=> NULL
                      ,P_LOT_NUMBER			=> NULL
                      ,P_LOT_STATUS			=> NULL
                      ,P_SUBLOT_NUMBER		=> NULL
                      ,P_SUBLOT_STATUS		=> NULL
                      ,P_SOURCE_SUBINVENTORY		=> l_subinventory_code    /* = subinventory_code from mmtt */
                      ,P_SOURCE_SUBINVENTORY_STATUS	=> NULL
                      ,P_DESTINATION_SUBINVENTORY	=> NULL
                      ,P_DESTINATION_SUBINVENTORY_ST  => NULL
                      ,P_SOURCE_LOCATOR		=> l_locator_id
                      ,P_SOURCE_LOCATOR_STATUS	=> NULL
                      ,P_DESTINATION_LOCATOR		=> NULL
                      ,P_DESTINATION_LOCATOR_STATUS	=> NULL
                      ,P_SOURCE_IMMEDIATE_LPN_ID	=> NULL
                      ,P_SOURCE_IMMEDIATE_LPN_STATUS	=> NULL
                      ,P_SOURCE_TOPLEVEL_LPN_ID	=> NULL
                      ,P_SOURCE_TOPLEVEL_LPN_STATUS	=> NULL
                      ,P_DEST_IMMEDIATE_LPN_ID 	=> NULL
                      ,P_DEST_IMMEDIATE_LPN_STATUS    => NULL
                      ,P_DEST_TOPLEVEL_LPN_ID  	=> NULL
                      ,P_DEST_TOPLEVEL_LPN_STATUS     => NULL
                      ,P_SERIAL_NUMBER		=> NULL
                      ,P_SERIAL_NUMBER_STATUS		=> NULL
                      ,P_PRIMARY_UOM			=> NULL
                      ,P_TRANSACTION_UOM		=> l_transaction_uom
                      ,P_PRIMARY_QUANTITY		=> NULL
                      ,P_TRANSACTION_QUANTITY		=> p_quantity_picked		/* = quantity picked */
                      ,P_TRANSACTION_ACTION_ID	=> NULL
                      ,P_TRANSACTION_SOURCE_TYPE_ID	=> NULL
                      ,P_TRANSACTION_SOURCE		=> NULL
                      ,P_PARENT_TRANSACTION_SOURCE	=> NULL
                      ,P_PARENT_TRANS_ACTION_ID	=> NULL
                      ,P_PARENT_TRANS_SOURCE_TYPE_ID  => NULL
                      ,P_RESERVATION_ID		=> NULL
                      ,P_EQUIPMENT_ID			=> NULL
                      ,P_ROLE_ID			=> NULL
                      ,P_EMPLOYEE_ID			=> p_user_id	/* = user_id */
                      ,P_TASK_TYPE_ID			=> NULL
                      ,P_TASK_ID			=> p_tsk_id
                      ,P_CALLING_PROGRAM_NAME		=> NULL
                      ,P_EMAIL_ID			=> NULL
                      ,P_PROGRAM_NAME			=> NULL
                      ,P_RUN_MODE			=> NULL
                      ,P_INIT_MSG_LST   		=> NULL
                      ,P_PROGRAM_CONTROL_ARG1		=> NULL
                      ,P_PROGRAM_CONTROL_ARG2		=> NULL
                      ,P_PROGRAM_CONTROL_ARG3		=> NULL
                      ,P_PROGRAM_CONTROL_ARG4		=> NULL
                      ,P_PROGRAM_CONTROL_ARG5		=> NULL
                      ,P_PROGRAM_CONTROL_ARG6 	=> NULL
                      ,X_RETURN_STATUS		=> lX_RETURN_STATUS
                      ,X_MSG_DATA			=> lX_MSG_DATA
                      ,X_MSG_COUNT		        => lX_MSG_COUNT
                      ,X_REVISION			=> lX_REVISION
                      ,X_LOT_NUMBER			=> lX_LOT_NUMBER
                      ,X_LOT_STATUS			=> lX_LOT_STATUS
                      ,X_SUBLOT_NUMBER		=> lX_SUBLOT_NUMBER
                      ,X_SUBLOT_STATUS		=> lX_SUBLOT_STATUS
                      ,X_LPN_ID			=> lX_LPN_ID
                      ,X_LPN_STATUS			=> lX_LPN_STATUS
                      ,X_UOM_CODE			=> lX_UOM_CODE
                      ,X_QUANTITY			=> lX_QUANTITY
                      ,X_INVENTORY_ITEM_ID		=> lX_INVENTORY_ITEM_ID
                      ,X_ORGANIZATION_ID		=> lX_ORGANIZATION_ID
                      ,X_SUBINVENTORY			=> lX_SUBINVENTORY
                      ,X_SUBINVENTORY_STATUS		=> lX_SUBINVENTORY_STATUS
                      ,X_LOCATOR			=> lX_LOCATOR
                      ,X_LOCATOR_STATUS		=> lX_LOCATOR_STATUS
                      ,X_PRIMARY_QUANTITY		=> lX_PRIMARY_QUANTITY
                      ,X_TRANSACTION_QUANTITY 	=> lX_TRANSACTION_QUANTITY
                      ,X_NEXT_FORM			=> lX_NEXT_FORM
                      ,X_NEXT_MOBILE_FORM		=> lX_NEXT_MOBILE_FORM
                      ,X_NEXT_PLSQL_PROGRAM		=> lX_NEXT_PLSQL_PROGRAM
                      ,X_RESERVATION_ID		=> lX_RESERVATION_ID
                      ,X_IS_RESERVATION_SUCCESSFUL 	=> lX_IS_RESERVATION_SUCCESSFUL
                      ,X_IS_CYCLE_COUNT_SUCCESSFUL	=> lX_IS_CYCLE_COUNT_SUCCESSFUL
                      );
      END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     	--
     	x_return_status := FND_API.G_RET_STS_ERROR;
     	--
     	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				  ,p_data => x_msg_data);
     	--
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     	--
     	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     	--
     	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				  ,p_data => x_msg_data);
     	--
     WHEN OTHERS THEN
	ROLLBACK TO wms_insuff_qty_PUB;
     	--
     	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     	--
     	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     	END IF;
     	--
     	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
				  , p_data => x_msg_data);


END wms_insuff_qty_wrapper;


/* PROCEDURE WMS_Inadequate_Quantity
    - This procedure is called when someone discovers
      an inadequate quantity of items in a location (which means there is a
      discrepancy between the number of items that are physically at the location
      and the number of items which the system _thinks_ is in the location).
      This procedure does the following:
        -  updates the value from column quantity_detailed
           in the table mtl_txn_request_lines
           to quantity_detailed less quantity_picked
        -  updates the values from columns reservation_quantity
           and primary_quantity
           in the table mtl_material_transaction_temp
           to reservation_quantity less quantity_picked and
           primary_quantity less quantity picked respectively
        -  updates reservation_quantity and primary_reservation_quantity
           in the table mtl_reservations
           to reservation_quantity less quantity_picked
           and primary_reservation_quantity less quantity_picked
        -  creates a new row in the table mtl_reservations.  This row
           acts as a cycle count request.
           where .  Note: The only way to check that this row is
           created is to query the table with the organization_id,
           inventory_item_id and demand_source_header_id=9 (for cycle
           count request).
 */

PROCEDURE WMS_Inadequate_Quantity      (itemtype	IN	VARCHAR2,
					itemkey	        IN	VARCHAR2,
					actid		IN	NUMBER,
					funcmode	IN	VARCHAR2,
					result		OUT NOCOPY	VARCHAR2)
IS

-- local variables
   l_workflow_name                     VARCHAR2(250)
   ; l_item_key                        VARCHAR2(250)
   ; lp_api_version_number             NUMBER := 1.0
   ; lp_init_msg_lst                   VARCHAR2(250) := FND_API.G_FALSE
   ; lp_commit                         VARCHAR2(250) := FND_API.G_FALSE
   ; lx_return_status                  VARCHAR2(1)
   ; lx_msg_count                      NUMBER
   ; lx_msg_data                       VARCHAR2(250)
   ; lp_organization_id                NUMBER
   ; lp_task_id                        NUMBER
   ; lp_qty_picked                     NUMBER := 0
   ; lp_qty_uom                        VARCHAR2(3)
   ; lp_carton_id                      VARCHAR2(250) := NULL
   ; lp_user_id                        VARCHAR2(250)
   ; lp_reason_id                      NUMBER
   ; lp_mmtt_id                         NUMBER
   ; lp_locator_id                      NUMBER
   ; lp_sub_code                        VARCHAR2(10)
   ; lp_line_num                         NUMBER
   ;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
      IF (l_debug = 1) THEN
         mdebug('In WMS_Inadequate_Quantity');
      END IF;

      l_workflow_name := itemtype;
      l_item_key := itemkey;

-- populating the local procedure variables with the corresponding attributes from workflow
   lp_organization_id	:= wf_engine.GetItemAttrNumber(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
						       aname	=> 'PW_SOURCE_ORGANIZATION_ID');

   lp_task_id	        := wf_engine.GetItemAttrNumber(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
                                                       aname	=> 'PW_TASK_ID');

   lp_qty_picked	:= wf_engine.GetItemAttrNumber(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
						       aname	=> 'PW_TRANSACTION_QUANTITY');

   lp_qty_uom	        := wf_engine.GetItemAttrText(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
						       aname	=> 'PW_TRANSACTION_UOM');

   lp_carton_id	        := wf_engine.getItemAttrText(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
						       aname	=> 'PW_LPN_ID');

   lp_user_id	        := wf_engine.GetItemAttrText(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
                                                       aname	=> 'PW_EMPLOYEE_ID');

   lp_reason_id	        := wf_engine.GetItemAttrNumber(itemtype	=> l_workflow_name,
						       itemkey	=> l_item_key,
                                                       aname	=> 'PW_REASON_NAME');


   IF (l_debug = 1) THEN
      mdebug('Before calling wms_txnrsn_actions_pub.Inadequate Quantity');
   END IF;


-- get data to call suggest_alternate_locatoin
   --Get MMTT id from WMS_Dispatched_tasks
   SELECT transaction_temp_id
     INTO lp_mmtt_id
     FROM wms_dispatched_tasks
     WHERE task_id=lp_task_id;
     IF (l_debug = 1) THEN
        mdebug('lp_mmtt_id: '|| lp_mmtt_id);
     END IF;

   SELECT subinventory_code,locator_id, move_order_line_id
   INTO lp_sub_code,lp_locator_id, lp_line_num
     FROM  mtl_material_transactions_temp
     WHERE transaction_temp_id=lp_mmtt_id;

   wms_txnrsn_actions_pub.suggest_alternate_location
       (p_api_version_number          =>lp_api_version_number
      , p_init_msg_lst                =>lp_init_msg_lst
      , p_commit                      =>lp_commit
      , x_return_status               =>lx_return_status
      , x_msg_count                   =>lx_msg_count
      , x_msg_data                    =>lx_msg_data
      , p_organization_id             =>lp_organization_id
      , p_mmtt_id                     =>lp_mmtt_id
      , p_task_id                     =>lp_task_id
      , p_subinventory_code           =>lp_sub_code
      , p_locator_id                  =>lp_locator_id
      , p_carton_id                   =>lp_carton_id
      , p_user_id                     =>lp_user_id
      , p_qty_picked                  =>lp_qty_picked
      , p_line_num                    =>lp_line_num
      );

   IF (l_debug = 1) THEN
      mdebug('After calling wms_txnrsn_actions_pub.suggest_alternate_location');
   END IF;
   -- setting the workflow attributes with the output results of
   -- the API wms_txnrsn_actions_pub.Inadequate_Qty
   wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			     itemkey	=>	l_item_key,
			     aname	=>	'XW_RETURN_STATUS',
			     avalue	=>	lx_return_status);

   wf_engine.SetItemAttrNumber(itemtype	=>	l_workflow_name,
			       itemkey	=>	l_item_key,
			       aname	=>	'XW_MSG_COUNT',
			       avalue	=>	lx_msg_count);

   wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
			     itemkey	=>	l_item_key,
			     aname	=>	'XW_MSG_DATA',
			     avalue	=>	lx_msg_data);

-- check for errors
   fnd_msg_pub.count_and_get
          (  p_count  => lx_msg_count
           , p_data   => lx_msg_data
             );

   IF (lx_msg_count = 0) THEN
        IF (l_debug = 1) THEN
           mdebug('Inadequate quantity successful');
        END IF;
   ELSIF (lx_msg_count = 1) THEN
        IF (l_debug = 1) THEN
           mdebug(replace(lx_msg_data,chr(0),' '));
        END IF;
   ELSE
       For I in 1..lx_msg_count LOOP
        	lx_msg_data := fnd_msg_pub.get(I,'F');
        	IF (l_debug = 1) THEN
           	mdebug(replace(lx_msg_data,chr(0),' '));
        	END IF;
       END LOOP;
   END IF;




   -- if successful, populate the workflow attribute XW_IS_RESERVATION_SUCCESSFUL
   -- with 'Y', otherwise populate with 'N'
if (lx_return_status = fnd_api.g_ret_sts_success) then
	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'XW_IS_RESERVATION_SUCCESSFUL',
				  avalue	=>	'YES');
else
	wf_engine.SetItemAttrText(itemtype	=>	l_workflow_name,
				  itemkey	=>	l_item_key,
				  aname		=>	'XW_IS_RESERVATION_SUCCESSFUL',
				  avalue	=>	'NO');
end if;
EXCEPTION

 WHEN fnd_api.g_exc_error THEN
      lx_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
      lx_return_status := fnd_api.g_ret_sts_unexp_error ;

   WHEN OTHERS THEN
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'WMS_Inadequate_Quantity'
              );
        END IF;
END wms_inadequate_quantity;


END wms_workflow_wrappers;



/
