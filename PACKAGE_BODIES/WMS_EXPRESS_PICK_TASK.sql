--------------------------------------------------------
--  DDL for Package Body WMS_EXPRESS_PICK_TASK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_EXPRESS_PICK_TASK" AS
/* $Header: WMSEXPTB.pls 120.1 2005/10/11 11:28:40 methomas noship $ */

   G_PKG_NAME    CONSTANT VARCHAR2(30) := 'WMS_EXPRESS_PICK_TASK';

   PROCEDURE MYDEBUG(MSG IN VARCHAR2) IS

     L_MSG VARCHAR2(5100);
     L_TS  VARCHAR2(30);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN

      L_MSG := MSG;

      INV_MOBILE_HELPER_FUNCTIONS.TRACELOG(
                                           P_ERR_MSG => L_MSG,
                                           P_MODULE  => 'WMS_EXPRESS_PICK_TASK',
                                           P_LEVEL   => 4
                                          );

      -- DBMS_OUTPUT.PUT_LINE(L_MSG);

   END;

  /*
   * Calls label printing API for the passed transaction temp Id
   * The process should go through fine even if Label printing
   * fails
   */
   PROCEDURE PRINT_LABEL(
                         X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                         X_MSG_COUNT     OUT NOCOPY NUMBER,
                         X_MSG_DATA      OUT NOCOPY VARCHAR2,
                         P_TEMP_ID       IN  NUMBER
                        ) IS
      L_TRANSACTION_TYPE_ID        NUMBER;
      L_TRANSACTION_SOURCE_TYPE_ID NUMBER;
      L_BUSINESS_FLOW_CODE         NUMBER := INV_LABEL.WMS_BF_PICK_LOAD;
      L_LABEL_STATUS               VARCHAR2(100);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN

      IF (l_debug = 1) THEN
         MYDEBUG('IN PROCEDURE PRINT_LABEL');
      END IF;

      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      SELECT TRANSACTION_TYPE_ID,
             TRANSACTION_SOURCE_TYPE_ID
      INTO   L_TRANSACTION_TYPE_ID,
             L_TRANSACTION_SOURCE_TYPE_ID
      FROM   MTL_MATERIAL_TRANSACTIONS_TEMP
      WHERE  TRANSACTION_TEMP_ID = P_TEMP_ID;

      IF L_TRANSACTION_TYPE_ID = 52 THEN
         -- Picking for sales order

         L_BUSINESS_FLOW_CODE := INV_LABEL.WMS_BF_PICK_LOAD;

      ELSIF L_TRANSACTION_TYPE_ID = 35 THEN
         -- WIP issue

         L_BUSINESS_FLOW_CODE := INV_LABEL.WMS_BF_WIP_PICK_LOAD;

      ELSIF L_TRANSACTION_TYPE_ID = 51 AND L_TRANSACTION_SOURCE_TYPE_ID = 13 THEN
         --Backflush

         L_BUSINESS_FLOW_CODE := INV_LABEL.WMS_BF_WIP_PICK_LOAD;

      ELSIF L_TRANSACTION_TYPE_ID =  64 AND L_TRANSACTION_SOURCE_TYPE_ID = 4 THEN
         --Replenishment

         L_BUSINESS_FLOW_CODE := INV_LABEL.WMS_BF_PICK_LOAD;

      END IF;

      INV_LABEL.PRINT_LABEL_WRAP(
                X_RETURN_STATUS      => X_RETURN_STATUS,
                X_MSG_COUNT          => X_MSG_COUNT,
                X_MSG_DATA           => X_MSG_DATA,
                X_LABEL_STATUS       => L_LABEL_STATUS,
                P_BUSINESS_FLOW_CODE => L_BUSINESS_FLOW_CODE,
                P_TRANSACTION_ID     => P_TEMP_ID
                                 );

      IF (l_debug = 1) THEN
         MYDEBUG('PRINT_LABEL : ' ||X_RETURN_STATUS||' LABEL:'||L_LABEL_STATUS);
      END IF;

    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

        WHEN OTHERS THEN

           X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
           IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'PRINT_LABEL');
           END IF;
           FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

    END PRINT_LABEL;

   PROCEDURE HAS_EXPRESS_PICK_TASKS(
                                    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                                    X_MSG_COUNT     OUT NOCOPY NUMBER,
                                    X_MSG_DATA      OUT NOCOPY VARCHAR2,
                                    P_USER_ID       IN  NUMBER,
                                    P_ORG_ID        IN  NUMBER
                                   ) IS

      L_DUMMY           NUMBER      := 0;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN

      BEGIN

         SELECT 1
         INTO   L_DUMMY
         FROM   WMS_DISPATCHED_TASKS
         WHERE  PERSON_ID       = P_USER_ID
         AND    ORGANIZATION_ID = P_ORG_ID
         AND    TASK_TYPE IN (1, 3, 4)
         AND    STATUS <= 3
         AND    IS_EXPRESS_PICK_TASK(TASK_ID) = 'S'
         AND    ROWNUM < 2;

         X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RAISE FND_API.G_EXC_ERROR;
      END;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

         X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

         X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN OTHERS THEN

         X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'HAS_EXPRESS_PICK_TASKS');
         END IF;
         FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

   END HAS_EXPRESS_PICK_TASKS;

   FUNCTION IS_EXPRESS_PICK_TASK(
                                 P_TASK_ID IN  NUMBER
                                ) RETURN VARCHAR2 IS

      X_RETURN_STATUS VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN

      SELECT IS_EXPRESS_PICK_TASK_ELIGIBLE(WDT.TRANSACTION_TEMP_ID)
      INTO   X_RETURN_STATUS
      FROM   WMS_DISPATCHED_TASKS WDT
      WHERE  WDT.TASK_ID = P_TASK_ID;

      RETURN X_RETURN_STATUS;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

         X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
         RETURN X_RETURN_STATUS;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

         X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
         RETURN X_RETURN_STATUS;

      WHEN OTHERS THEN

         X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
         RETURN X_RETURN_STATUS;

   END IS_EXPRESS_PICK_TASK;

   FUNCTION IS_EXPRESS_PICK_TASK_ELIGIBLE(
                                           P_TRANSACTION_TEMP_ID IN NUMBER
                                         ) RETURN VARCHAR2 IS

      X_RETURN_STATUS VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      L_SERIAL_CODE   NUMBER      := 1;
      L_LOT_CODE      NUMBER      := 1;
      L_DUMMY         NUMBER      := 1;
      L_IS_BULK_PICK  NUMBER      := 0;
      l_allocated_lpn_id NUMBER;

-- Start of Bugfix 2244633
   l_api_version_number  CONSTANT NUMBER := 1.0;
   l_init_msg_lst VARCHAR2(10)  := fnd_api.g_false;
	l_return_status VARCHAR2(10);
	l_msg_count NUMBER;
	l_msg_data VARCHAR2(5000);
	l_organization_id NUMBER;
	l_inventory_item_id NUMBER;
	l_is_revision_control VARCHAR2(5)  := 'false';
	l_is_lot_control VARCHAR2(5)	:= 'false';
	l_is_serial_control VARCHAR2(5)	:= 'false';
	l_revision VARCHAR2(30);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
	l_lot_number VARCHAR2(80);
	l_transaction_quantity NUMBER;
	l_transaction_uom VARCHAR2(10);
	l_subinventory_code VARCHAR2(10);
	l_locator_id NUMBER;
   l_revision_control_code NUMBER;
   l_lot_control_code NUMBER;
	s_ok_to_process VARCHAR2(10);
   l_transfer_subinventory VARCHAR2(10);

   -- end of part of bugfix 2244633

   -- bug 2675498
   l_sub_lpn_controlled_flag NUMBER;

   -- bug 2675498


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN

      IF (l_debug = 1) THEN
         MYDEBUG('IS_EXPRESS_PICK_TASK_ELIGIBLE: TRANSACTION_TEMP_ID: '||TO_CHAR(P_TRANSACTION_TEMP_ID));
      END IF;

      BEGIN
 -- Start of bugfix 2287341
 -- Selecting the allocated_lpn_id also

	 SELECT NVL(MSI.SERIAL_NUMBER_CONTROL_CODE,1),
	   NVL(MSI.LOT_CONTROL_CODE,1),
	   mmtt.allocated_lpn_id,
	   Nvl(sub.lpn_controlled_flag, 1),   -- bug 2675498
	   mmtt.inventory_item_id,
	   mmtt.subinventory_code,
	   mmtt.locator_id,
	   mmtt.organization_id
	   INTO   L_SERIAL_CODE,
	   L_LOT_CODE,
	   l_allocated_lpn_id,
	   l_sub_lpn_controlled_flag,   -- bug 2675498
	   l_inventory_item_id,
	   l_subinventory_code,
	   l_locator_id,
	   l_organization_id
	   FROM   MTL_MATERIAL_TRANSACTIONS_TEMP MMTT,
	   MTL_SYSTEM_ITEMS_B msi,
	   mtl_secondary_inventories sub   -- bug 2675498
	   WHERE  MMTT.TRANSACTION_TEMP_ID = P_TRANSACTION_TEMP_ID
	   AND    MMTT.ORGANIZATION_ID     = MSI.ORGANIZATION_ID
           AND    sub.ORGANIZATION_ID      = MSI.ORGANIZATION_ID -- Bug #2722444
	   AND    MMTT.INVENTORY_ITEM_ID   = MSI.inventory_item_id
	   AND    mmtt.subinventory_code = sub.secondary_inventory_name   -- bug 2675498
	   ;

	 -- bug 2675498

	 IF l_sub_lpn_controlled_flag = 1 THEN -- from sub is LPN controlled

	    IF (l_debug = 1) THEN
	       MYDEBUG('Pick from an LPN controlled sub. This task cannnot be express picked');
	    END IF;

	    RAISE fnd_api.g_exc_error;
	 END IF;

	 -- bug 2675498

-- Checking whether the lpn has been already allocated or not?

         IF l_allocated_lpn_id IS NOT NULL THEN
            IF (l_debug = 1) THEN
               MYDEBUG('LPN Allocation is already done, Cannot Express Pick This Task');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

-- End of bugfix 2287341

         IF L_SERIAL_CODE NOT IN ( 1, 6 ) THEN
            IF (l_debug = 1) THEN
               MYDEBUG('SERIAL CONTROL CODE: '||TO_CHAR(L_SERIAL_CODE));
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
               MYDEBUG('INVALID MMTT: ');
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      IF L_LOT_CODE <> 1 THEN

         BEGIN

            SELECT 1
            INTO   L_DUMMY
            FROM   MTL_TRANSACTION_LOTS_TEMP MTLT
            WHERE  MTLT.TRANSACTION_TEMP_ID = P_TRANSACTION_TEMP_ID;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               IF (l_debug = 1) THEN
                  MYDEBUG('INVALID LOT MMTT: ');
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            WHEN TOO_MANY_ROWS THEN
               IF (l_debug = 1) THEN
                  MYDEBUG('MULTIPLE LOTS FOR MMTT: ');
               END IF;
               RAISE FND_API.G_EXC_ERROR;
         END;

      END IF;

      BEGIN

         SELECT 1
         INTO   L_IS_BULK_PICK
         FROM   MTL_MATERIAL_TRANSACTIONS_TEMP
         WHERE  PARENT_LINE_ID =  P_TRANSACTION_TEMP_ID
         AND    ROWNUM < 2;

         IF (l_debug = 1) THEN
            MYDEBUG('THIS IS A BULK PICK TASK');
         END IF;
         RAISE FND_API.G_EXC_ERROR;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
               MYDEBUG('THIS IS NOT A BULK PICK TASK');
            END IF;
            NULL;
      END;


      /* comment out for bug 2675498


-- Bugfix 2244633 contd..
  BEGIN
        IF (l_debug = 1) THEN
           MYDEBUG('Is Express Pick Task? Checking for enough loose quantity');
        END IF;
--Bug 2676657
  SELECT
		MMTT.ORGANIZATION_ID,
		MMTT.INVENTORY_ITEM_ID,
		MSI.REVISION_QTY_CONTROL_CODE,
		MSI.LOT_CONTROL_CODE,
		MMTT.REVISION,
		MTLT.LOT_NUMBER,
		MMTT.TRANSACTION_QUANTITY,
		MMTT.TRANSACTION_UOM,
		MMTT.SUBINVENTORY_CODE,
		MMTT.LOCATOR_ID,
		MMTT.TRANSFER_SUBINVENTORY
	INTO	L_ORGANIZATION_ID,
		L_INVENTORY_ITEM_ID,
		L_REVISION_CONTROL_CODE,
		L_LOT_CONTROL_CODE,
		L_REVISION,
		L_LOT_NUMBER,
		L_TRANSACTION_QUANTITY,
		L_TRANSACTION_UOM,
		L_SUBINVENTORY_CODE,
		L_LOCATOR_ID,
		L_TRANSFER_SUBINVENTORY


	FROM   MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
		,MTL_SYSTEM_ITEMS_B MSI
		,MTL_TRANSACTION_LOTS_TEMP MTLT
	WHERE   MMTT.ORGANIZATION_ID      =  MSI.ORGANIZATION_ID
	AND 	MMTT.INVENTORY_ITEM_ID    =  MSI.INVENTORY_ITEM_ID
	AND 	MMTT.TRANSACTION_TEMP_ID  =   P_TRANSACTION_TEMP_ID
	AND     MMTT.TRANSACTION_TEMP_ID  =  MTLT.transaction_temp_id(+);

	IF (l_revision_control_code = 2) THEN
		IF (l_debug = 1) THEN
   		MYDEBUG('Revision Controlled item: ' || TO_CHAR(l_revision_control_code));
		END IF;
		l_is_revision_control := 'true';
	END IF;

   IF (l_lot_control_code = 2) THEN
		IF (l_debug = 1) THEN
   		MYDEBUG('Lot Controlled item: ' || TO_CHAR(l_lot_control_code));
		END IF;
		l_is_lot_control := 'true';
	END IF;

   IF (l_debug = 1) THEN
      MYDEBUG(' Before Calling Check_Loose_Quantity');
   END IF;

	INV_TXN_VALIDATIONS.CHECK_LOOSE_QUANTITY
	( p_api_version_number 	=> l_api_version_number,
	  p_init_msg_lst 	      => fnd_api.g_true,
	  x_return_status	      => l_return_status,
	  x_msg_count		      => l_msg_count,
	  x_msg_data		      => l_msg_data,
	  p_organization_id	   => l_organization_id,
	  p_inventory_item_id	=> l_inventory_item_id,
	  p_is_revision_control	=> l_is_revision_control,
	  p_is_lot_control	   => l_is_lot_control,
	  p_is_serial_control	=> l_is_serial_control,
	  p_revision		      => l_revision,
	  p_lot_number		      => l_lot_number,
	  p_transaction_quantity => l_transaction_quantity,
	  p_transaction_uom	   => l_transaction_uom,
	  p_subinventory_code	=> l_subinventory_code,
	  p_locator_id		      => l_locator_id,
	  p_transaction_temp_id	=> p_transaction_temp_id,
	  p_ok_to_process	      => s_ok_to_process,
     p_transfer_subinventory => l_transfer_subinventory
	);

   IF (l_debug = 1) THEN
      MYDEBUG(' After Calling Check_Loose_Quantity');
   END IF;

	IF l_return_status = fnd_api.g_ret_sts_error THEN
 	      IF (l_debug = 1) THEN
    	      MYDEBUG('return status = ' || l_return_status);
 	      END IF;
	      RAISE fnd_api.g_exc_error;
   END IF ;

   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	      IF (l_debug = 1) THEN
   	      MYDEBUG('return status = ' || l_return_status);
	      END IF;
	      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

	IF (l_debug = 1) THEN
   	MYDEBUG('s_ok_to_process = ' || s_ok_to_process);
	END IF;

	IF s_ok_to_process <> 'true' THEN
	     IF (l_debug = 1) THEN
   	     MYDEBUG(' Not Enough Loose Quantity. This task cannnot be express picked');
	     END IF;
	     RAISE fnd_api.g_exc_error;
	END IF;

	X_RETURN_STATUS := l_return_status;

   END;
    -- end of bugfix 2244633

    comment out for bug 2675498	*/

   RETURN X_RETURN_STATUS;


   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

         X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
         RETURN X_RETURN_STATUS;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

         X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
         RETURN X_RETURN_STATUS;

      WHEN OTHERS THEN

         X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
         RETURN X_RETURN_STATUS;

   END IS_EXPRESS_PICK_TASK_ELIGIBLE;

   PROCEDURE LOAD_AND_DROP(
                            X_RETURN_STATUS       OUT NOCOPY VARCHAR2,
                            X_MSG_COUNT           OUT NOCOPY NUMBER,
                            X_MSG_DATA            OUT NOCOPY VARCHAR2,
                            P_ORG_ID              IN  NUMBER,
                            P_TEMP_ID             IN  NUMBER,
                            P_TO_LPN              IN  VARCHAR2,
                            P_TO_SUB              IN  VARCHAR2,
                            P_TO_LOC              IN  NUMBER,
                            P_ACTION              IN  VARCHAR2,
                            P_USER_ID             IN  NUMBER,
                            P_TASK_TYPE           IN  NUMBER
                         ) IS

      L_LPN_ID         NUMBER := 0;
      L_TEMP_ID        NUMBER := 0;
      L_MMTT_TO_UPDATE VARCHAR2(100) := '';
      L_OK_TO_PROCESS  VARCHAR2(100) := 'false';
      L_TXN_HDR_ID     NUMBER := 0;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN

      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      BEGIN

         SELECT LPN_ID
         INTO   L_LPN_ID
         FROM   WMS_LICENSE_PLATE_NUMBERS
         WHERE  LICENSE_PLATE_NUMBER = P_TO_LPN
         AND    ORGANIZATION_ID = P_ORG_ID;

         IF (l_debug = 1) THEN
            MYDEBUG('THE LPN ID IS '||TO_CHAR(L_LPN_ID));
         END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF (l_debug = 1) THEN
               MYDEBUG('INVALID LPN'||P_TO_LPN);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
               MYDEBUG('UNEXPECTED ERROR IN FETCHING LPN '||SQLERRM);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      IF (l_debug = 1) THEN
         mydebug('current action is: ' || p_action);
      END IF;

      -- Check the value of p_action. If 'LOAD' then call procedure LOAD
      -- If 'LOAD_AND_DROP' then call procedure call 'LOAD_TASK' and 'DROP_TASK'
      IF (p_action = 'LOAD') THEN

        WMS_EXPRESS_PICK_TASK.LOAD_TASK(
              X_RETURN_STATUS => X_RETURN_STATUS,
              X_MSG_COUNT     => X_MSG_COUNT,
              X_MSG_DATA      => X_MSG_DATA,
              P_TEMP_ID       => P_TEMP_ID,
              P_LPN_ID        => L_LPN_ID,
              P_USER_ID       => P_USER_ID
             );

        IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
          IF (l_debug = 1) THEN
             MYDEBUG('ERROR IN LOAD_TASK ');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF (l_debug = 1) THEN
              MYDEBUG('UNEXPECTED ERROR IN LOAD_TASK ');
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      ELSIF (p_action = 'LOAD_AND_DROP') THEN

        WMS_EXPRESS_PICK_TASK.LOAD_TASK(
              X_RETURN_STATUS => X_RETURN_STATUS,
              X_MSG_COUNT     => X_MSG_COUNT,
              X_MSG_DATA      => X_MSG_DATA,
              P_TEMP_ID       => P_TEMP_ID,
              P_LPN_ID        => L_LPN_ID,
              P_USER_ID       => P_USER_ID
             );

        IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
          IF (l_debug = 1) THEN
             MYDEBUG('ERROR IN LOAD_TASK ');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF (l_debug = 1) THEN
              MYDEBUG('UNEXPECTED ERROR IN LOAD_TASK ');
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        WMS_EXPRESS_PICK_TASK.DROP_TASK(
              X_RETURN_STATUS => X_RETURN_STATUS,
              X_MSG_COUNT     => X_MSG_COUNT,
              X_MSG_DATA      => X_MSG_DATA,
              P_ORG_ID        => P_ORG_ID,
              P_TEMP_ID       => P_TEMP_ID,
              P_LPN_ID        => L_LPN_ID,
              P_TO_SUB        => P_TO_SUB,
              P_TO_LOC        => P_TO_LOC,
              P_USER_ID       => P_USER_ID,
              P_TASK_TYPE     => P_TASK_TYPE
             );

        IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
          IF (l_debug = 1) THEN
             MYDEBUG('ERROR IN DROP_TASK ');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF (l_debug = 1) THEN
              MYDEBUG('UNEXPECTED ERROR IN DROP_TASK ');
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END IF;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN OTHERS THEN

          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'LOAD_AND_DROP');
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

   END LOAD_AND_DROP;

  PROCEDURE LOAD_TASK(
                 X_RETURN_STATUS       OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT           OUT NOCOPY NUMBER,
                 X_MSG_DATA            OUT NOCOPY VARCHAR2,
                 P_TEMP_ID             IN  NUMBER,
                 P_LPN_ID              IN  NUMBER,
                 P_USER_ID             IN  NUMBER
                ) IS
    l_lpn_id NUMBER := p_lpn_id;
    l_temp_id NUMBER := p_temp_id;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF (l_debug = 1) THEN
       mydebug('in procedure load_task');
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    UPDATE mtl_material_transactions_temp
    SET    transfer_lpn_id = l_lpn_id,
           last_update_date = SYSDATE,
           last_updated_by = p_user_id
    WHERE transaction_temp_id = l_temp_id;

    IF (l_debug = 1) THEN
       mydebug('Updated MTTT row count: ' || SQL%ROWCOUNT);
    END IF;

    --Set the task status to Loaded
    UPDATE wms_dispatched_tasks
    SET    status = 4,
           loaded_time = SYSDATE,
           last_update_date = SYSDATE,
           last_updated_by = p_user_id
    WHERE  transaction_temp_id = l_temp_id;

    IF (l_debug = 1) THEN
       mydebug('Updated WDT row count: ' || SQL%ROWCOUNT);
    END IF;

    PRINT_LABEL(
                 X_RETURN_STATUS => X_RETURN_STATUS,
                 X_MSG_COUNT     => X_MSG_COUNT,
                 X_MSG_DATA      => X_MSG_DATA,
                 P_TEMP_ID       => P_TEMP_ID
               );

    IF (l_debug = 1) THEN
       MYDEBUG('IGNORE RETURN STATUS FOR LABEL PRINTING');
    END IF;

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN

          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN OTHERS THEN

          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'LOAD_TASK');
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

  END LOAD_TASK;

  PROCEDURE DROP_TASK(
                 X_RETURN_STATUS       OUT NOCOPY VARCHAR2,
                 X_MSG_COUNT           OUT NOCOPY NUMBER,
                 X_MSG_DATA            OUT NOCOPY VARCHAR2,
                 P_ORG_ID              IN  NUMBER,
                 P_TEMP_ID             IN  NUMBER,
                 P_LPN_ID              IN  NUMBER,
                 P_TO_SUB              IN  VARCHAR2,
                 P_TO_LOC              IN  NUMBER,
                 P_USER_ID             IN  NUMBER,
                 P_TASK_TYPE           IN  NUMBER
                ) IS
     l_lpn_id         NUMBER := p_lpn_id;
     l_temp_id        NUMBER := p_temp_id;
     l_txn_hdr_id     NUMBER := 0;
     s_ok_to_process  VARCHAR2(10);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN

     IF (l_debug = 1) THEN
        mydebug('in prod drop_task');
     END IF;

     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

     SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
     INTO   L_TXN_HDR_ID
     FROM   DUAL;

     IF (l_debug = 1) THEN
        MYDEBUG('L_TXN_HDR_ID  IS '|| L_TXN_HDR_ID);
     END IF;

     WMS_TASK_DISPATCH_GEN.COMPLETE_PICK(
                                           P_LPN               => NULL,
                                           P_CONTAINER_ITEM_ID => NULL,
                                           P_ORG_ID            => P_ORG_ID,
                                           P_TEMP_ID           => P_TEMP_ID,
                                           P_LOC               => P_TO_LOC,
                                           P_SUB               => P_TO_SUB,
                                           P_FROM_LPN_ID       => L_LPN_ID ,
                                           P_TXN_HDR_ID        => L_TXN_HDR_ID,
                                           P_USER_ID           => P_USER_ID,
                                           X_RETURN_STATUS     => X_RETURN_STATUS,
                                           X_MSG_COUNT         => X_MSG_COUNT,
                                           X_MSG_DATA          => X_MSG_DATA,
                                           P_OK_TO_PROCESS     => S_OK_TO_PROCESS
                                         );

       IF (l_debug = 1) THEN
          MYDEBUG('Finished Complete Pick. p_ok_to_process =' || s_ok_to_process);
       END IF;

      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
         IF (l_debug = 1) THEN
            MYDEBUG('ERROR IN COMPLETE PICK ');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
         IF (l_debug = 1) THEN
            MYDEBUG('UNEXPECTED ERROR IN COMPLETE PICK ');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      WMS_TASK_DISPATCH_GEN.PICK_DROP(
                                       P_TEMP_ID       => P_TEMP_ID,
                                       P_TXN_HEADER_ID => L_TXN_HDR_ID,
                                       P_ORG_ID        => P_ORG_ID,
                                       X_RETURN_STATUS => X_RETURN_STATUS,
                                       X_MSG_COUNT     => X_MSG_COUNT,
                                       X_MSG_DATA      => X_MSG_DATA,
                                       P_FROM_LPN_ID   => L_LPN_ID ,
                                       P_DROP_LPN      => NULL,
                                       P_LOC_REASON_ID => 0,
                                       P_SUB           => P_TO_SUB,
                                       P_LOC           => P_TO_LOC,
                                       P_ORIG_SUB      => P_TO_SUB,
                                       P_ORIG_LOC      => P_TO_LOC,
                                       P_USER_ID       => P_USER_ID,
                                       P_TASK_TYPE     => P_TASK_TYPE
                                     );

      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN
         IF (l_debug = 1) THEN
            MYDEBUG('ERROR IN PICK DROP ');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF X_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR THEN
         IF (l_debug = 1) THEN
            MYDEBUG('UNEXPECTED ERROR IN PICK DROP ');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN OTHERS THEN

          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'DROP_TASK');
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

  END DROP_TASK;

END WMS_EXPRESS_PICK_TASK;

/
