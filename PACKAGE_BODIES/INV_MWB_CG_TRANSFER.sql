--------------------------------------------------------
--  DDL for Package Body INV_MWB_CG_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MWB_CG_TRANSFER" AS
/* $Header: INVCGTRB.pls 120.2 2005/10/10 12:53:54 methomas noship $ */

   g_pkg_name CONSTANT VARCHAR2(30) := 'INV_MWB_CG_TRANSFER';


   PROCEDURE mdebug(msg in varchar2) IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      -- dbms_output.put_line(msg);
      null;
   END;

   PROCEDURE TRANSFER(
                       X_RETURN_STATUS          OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
                       X_MSG_COUNT              OUT NOCOPY /* file.sql.39 change */    NUMBER,
                       X_MSG_DATA               OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
                       X_TRANSACTION_HEADER_ID  IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
                       P_IS_REVISION_CONTROLLED IN     VARCHAR2,
                       P_IS_LOT_CONTROLLED      IN     VARCHAR2,
                       P_IS_SERIAL_CONTROLLED   IN     VARCHAR2,
                       P_ORG_ID                 IN     NUMBER,
                       P_INVENTORY_ITEM_ID      IN     NUMBER,
                       P_REVISION               IN     VARCHAR2,
                       P_SUBINVENTORY           IN     VARCHAR2,
                       P_LOCATOR_ID             IN     NUMBER,
                       P_LPN_ID                 IN     NUMBER,
                       P_LOT_NUMBER             IN     VARCHAR2,
                       P_EXP_DATE               IN     DATE,
                       P_SERIAL_NUMBER          IN     VARCHAR2,
                       P_ONHAND                 IN     NUMBER,
                       P_AVAILABILITY           IN     NUMBER,
                       P_UOM                    IN     VARCHAR2,
                       P_PRIMARY_UOM            IN     VARCHAR2,
                       P_COSTGROUP_ID           IN     NUMBER,
                       P_XFR_COSTGROUP_ID       IN     NUMBER,
                       P_USER_ID                IN     NUMBER
                      ) IS
      L_RETURN_STATUS              NUMBER := 0;
      L_PROC_MSG                   VARCHAR2(2000);
      L_TRANSACTION_TEMP_ID        NUMBER;
      L_SERIAL_TRANSACTION_TEMP_ID NUMBER;
      L_PRIMARY_QUANTITY           NUMBER := P_ONHAND;
      L_EXP_DATE                   DATE   := P_EXP_DATE;
      L_ONHAND                     NUMBER := P_ONHAND;

      /*
      ** For Cost Group Transfer
      ** TRANSACTION_TYPE_ID  = 86
      ** TRANSACTION_SOURCE_TYPE_ID = 13
      ** TRANSACTION_ACTION = 55
      */

      L_TRANSACTION_TYPE_ID        NUMBER := 86;
      L_TRANSACTION_SOURCE_TYPE_ID NUMBER := 13;
      L_TRANSACTION_ACTION_ID      NUMBER := 55;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN

      IF P_IS_SERIAL_CONTROLLED = 'Y' THEN
         L_ONHAND := 1;
      END IF;

      IF P_UOM <> P_PRIMARY_UOM THEN

         L_PRIMARY_QUANTITY := INV_CONVERT.INV_UM_CONVERT(
                                           ITEM_ID       => P_INVENTORY_ITEM_ID,
                                           PRECISION     => NULL,
                                           FROM_QUANTITY => L_ONHAND,
                                           FROM_UNIT     => P_UOM,
                                           TO_UNIT       => P_PRIMARY_UOM,
                                           FROM_NAME     => NULL,
                                           TO_NAME       => NULL
                                                         );

      END IF;

	/*
          LINE_INSERT_TRX creates a transaction_temp_id for a transaction.

          X_TRANSACTION_HEADER_ID is an IN/OUT parameter representing the
          transaction header id used for the transaction.

          When X_TRANSACTION_HEADER_ID is passed as null, LINE_INSERT_TRX
          uses the newly created transaction_temp_id as the transaction header id
          for the transaction.

          When X_TRANSACTION_HEADER_ID is passed a value, LINE_INSERT_TRX
          uses this value as the transaction header id for the transaction.

          So for the first transaction in the group, X_TRANSACTION_HEADER_ID is
          passed as null to  LINE_INSERT_TRX. For subsequent calls, the value is
          available and is used.
	*/


      SAVEPOINT TRX_BEGIN;

      L_RETURN_STATUS := INV_TRX_UTIL_PUB.INSERT_LINE_TRX(
                                      p_trx_hdr_id        => X_TRANSACTION_HEADER_ID,
                                      p_item_id           => P_INVENTORY_ITEM_ID,
                                      p_revision          => P_REVISION,
                                      p_org_id            => P_ORG_ID,
                                      p_trx_action_id     => L_TRANSACTION_ACTION_ID,
                                      p_subinv_code       => P_SUBINVENTORY ,
                                      p_tosubinv_code     => NULL,
                                      p_locator_id        => P_LOCATOR_ID,
                                      p_tolocator_id      => NULL,
                                      p_xfr_org_id        => NULL,
                                      p_trx_type_id       => L_TRANSACTION_TYPE_ID,
                                      p_trx_src_type_id   => L_TRANSACTION_SOURCE_TYPE_ID,
                                      p_trx_qty           => L_ONHAND,
                                      p_pri_qty           => L_PRIMARY_QUANTITY,
                                      p_uom               => P_UOM,
                                      p_date              => SYSDATE,
                                      p_reason_id         => NULL,
                                      p_user_id           => P_USER_ID,
                                      p_frt_code          => NULL,
                                      p_ship_num          => NULL,
                                      p_dist_id           => NULL,
                                      p_way_bill          => NULL,
                                      p_exp_arr           => NULL,
                                      p_cost_group        => P_COSTGROUP_ID,
                                      p_from_lpn_id       => P_LPN_ID,
                                      p_cnt_lpn_id        => NULL,
                                      p_xfr_lpn_id        => P_LPN_ID,
                                      p_trx_src_id        => NULL,
                                      x_trx_tmp_id        => L_TRANSACTION_TEMP_ID,
                                      x_proc_msg          => L_PROC_MSG,
                                      p_xfr_cost_group    => P_XFR_COSTGROUP_ID,
                                      p_completion_trx_id => NULL,
                                      p_flow_schedule     => NULL,
                                      p_trx_cost          => NULL
                                                         );

      IF L_RETURN_STATUS <> 0 THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF P_IS_LOT_CONTROLLED = 'Y' AND P_IS_SERIAL_CONTROLLED <> 'Y' THEN

         IF L_EXP_DATE IS NULL THEN

            SELECT EXPIRATION_DATE
            INTO   L_EXP_DATE
            FROM   MTL_LOT_NUMBERS_ALL_V
            WHERE  ORGANIZATION_ID = P_ORG_ID
            AND    INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
            AND    LOT_NUMBER = P_LOT_NUMBER;

         END IF;

         L_RETURN_STATUS := INV_TRX_UTIL_PUB.INSERT_LOT_TRX(
                                         p_trx_tmp_id => L_TRANSACTION_TEMP_ID,
                                         p_user_id    => P_USER_ID,
                                         p_lot_number => P_LOT_NUMBER,
                                         p_trx_qty    => L_ONHAND,
                                         p_pri_qty    => L_PRIMARY_QUANTITY,
                                         x_ser_trx_id => L_SERIAL_TRANSACTION_TEMP_ID,
                                         x_proc_msg   => L_PROC_MSG,
                                         p_exp_date   => L_EXP_DATE
                                                           );

         IF L_RETURN_STATUS <> 0 THEN

            FND_MESSAGE.SET_NAME('INV','INV_LOT_COMMIT_FAILURE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         END IF;

      END IF; -- for Only Lot Controlled Items

      IF P_IS_LOT_CONTROLLED = 'Y' AND P_IS_SERIAL_CONTROLLED = 'Y' THEN

         L_RETURN_STATUS := INV_TRX_UTIL_PUB.INSERT_LOT_TRX(
                                         p_trx_tmp_id => L_TRANSACTION_TEMP_ID,
                                         p_user_id    => P_USER_ID,
                                         p_lot_number => P_LOT_NUMBER,
                                         p_trx_qty    => 1,
                                         p_pri_qty    => 1,
                                         x_ser_trx_id => L_SERIAL_TRANSACTION_TEMP_ID,
                                         x_proc_msg   => L_PROC_MSG,
                                         p_exp_date   => NULL
                                                           );

         IF L_RETURN_STATUS <> 0 THEN

            FND_MESSAGE.SET_NAME('INV','INV_LOT_COMMIT_FAILURE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         END IF;

         L_RETURN_STATUS := INV_TRX_UTIL_PUB.INSERT_SER_TRX(
                                         p_trx_tmp_id => L_SERIAL_TRANSACTION_TEMP_ID,
                                         p_user_id    => P_USER_ID,
                                         p_fm_ser_num => P_SERIAL_NUMBER,
                                         p_to_ser_num => P_SERIAL_NUMBER,
                                         x_proc_msg   => L_PROC_MSG
                                                           );

         IF L_RETURN_STATUS <> 0 THEN

            FND_MESSAGE.SET_NAME('INV','INV_SERIAL_COMMIT_FAILURE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         END IF;

      END IF; -- for Lot and Serial Controlled Items

      IF P_IS_LOT_CONTROLLED <> 'Y' AND P_IS_SERIAL_CONTROLLED = 'Y' THEN

         L_RETURN_STATUS := INV_TRX_UTIL_PUB.INSERT_SER_TRX(
                                         p_trx_tmp_id => L_TRANSACTION_TEMP_ID,
                                         p_user_id    => P_USER_ID,
                                         p_fm_ser_num => P_SERIAL_NUMBER,
                                         p_to_ser_num => P_SERIAL_NUMBER,
                                         x_proc_msg   => L_PROC_MSG
                                                           );

         IF L_RETURN_STATUS <> 0 THEN

            FND_MESSAGE.SET_NAME('INV','INV_SERIAL_COMMIT_FAILURE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         END IF;

      END IF; -- Only Serial Controlled Items

      IF X_TRANSACTION_HEADER_ID IS NULL THEN
         X_TRANSACTION_HEADER_ID := L_TRANSACTION_TEMP_ID;
      END IF;

      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

          ROLLBACK TO TRX_BEGIN;
          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          ROLLBACK TO TRX_BEGIN;
          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN OTHERS THEN

          ROLLBACK TO TRX_BEGIN;
          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'TRANSFER');
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

   END TRANSFER;

   PROCEDURE VALIDATE(
                       X_RETURN_STATUS          OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
                       X_MSG_COUNT              OUT NOCOPY /* file.sql.39 change */    NUMBER,
                       X_MSG_DATA               OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
                       X_ONHAND                 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
		       X_AVAILABILITY           IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
                       P_IS_REVISION_CONTROLLED IN     VARCHAR2,
                       P_IS_LOT_CONTROLLED      IN     VARCHAR2,
                       P_IS_SERIAL_CONTROLLED   IN     VARCHAR2,
                       P_ORG_ID                 IN     NUMBER,
                       P_INVENTORY_ITEM_ID      IN     NUMBER,
                       P_REVISION               IN     VARCHAR2,
                       P_SUBINVENTORY           IN     VARCHAR2,
                       P_LOCATOR_ID             IN     NUMBER,
                       P_LPN_ID                 IN     NUMBER,
                       P_LOT_NUMBER             IN     VARCHAR2,
                       P_SERIAL_NUMBER          IN     VARCHAR2,
                       P_IS_LPN_REQUIRED        IN     VARCHAR2,
                       P_COST_GROUP_ID          IN     NUMBER
                      ) IS

      L_RETURN_STATUS              VARCHAR2(1);
      L_MSG_DATA                   VARCHAR2(2000);
      L_MSG_COUNT                  NUMBER;
      L_CG_ID                      NUMBER  := P_COST_GROUP_ID;
      L_LPN_QOH                    NUMBER;
      L_QOH                        NUMBER;
      L_PQOH                       NUMBER := 0;
      L_RQOH                       NUMBER;
      L_QR                         NUMBER;
      L_QS                         NUMBER;
      L_ATT                        NUMBER;
      L_ATR                        NUMBER;
      L_IS_LOT_CONTROLLED          BOOLEAN := FALSE;
      L_IS_REVISION_CONTROLLED     BOOLEAN := FALSE;
      L_IS_SERIAL_CONTROLLED       BOOLEAN := FALSE;
      L_V_IS_LOT_CONTROLLED        VARCHAR2(5) := 'FALSE';
      L_V_IS_REVISION_CONTROLLED   VARCHAR2(5) := 'FALSE';
      L_V_IS_SERIAL_CONTROLLED     VARCHAR2(5) := 'FALSE';
      L_TREE_ID                    NUMBER;
      L_PROJ_ID                    NUMBER;
      /*
      ** For Cost Group Transfer
      ** TRANSACTION_TYPE_ID  = 86
      ** TRANSACTION_SOURCE_TYPE_ID = 13
      ** TRANSACTION_ACTION = 55
      */

      L_TRANSACTION_TYPE_ID        NUMBER := 86;
      L_TRANSACTION_SOURCE_TYPE_ID NUMBER := 13;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN

      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      IF P_IS_REVISION_CONTROLLED = 'Y' THEN
         L_IS_REVISION_CONTROLLED   := TRUE;
         L_V_IS_REVISION_CONTROLLED := 'TRUE';
      END IF;

      IF P_IS_SERIAL_CONTROLLED = 'Y' THEN
         L_IS_SERIAL_CONTROLLED   := TRUE;
         L_V_IS_SERIAL_CONTROLLED := 'TRUE';
      END IF;

      IF P_IS_LOT_CONTROLLED = 'Y' THEN
         L_IS_LOT_CONTROLLED   := TRUE;
         L_V_IS_LOT_CONTROLLED := 'TRUE';
      END IF;

      IF P_ORG_ID IS NULL OR P_INVENTORY_ITEM_ID IS NULL OR P_SUBINVENTORY IS NULL OR
         P_LOCATOR_ID IS NULL OR P_COST_GROUP_ID IS NULL
      THEN

         FND_MESSAGE.SET_NAME('WMS','WMS_ATT_CGU_REQ');
         FND_MSG_PUB.ADD;
         X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

      END IF;

      IF P_IS_REVISION_CONTROLLED = 'Y' AND P_REVISION IS NULL THEN

         FND_MESSAGE.SET_NAME('WMS','WMS_ATT_TRN_EXP');
         FND_MESSAGE.SET_TOKEN('TOKEN',FND_MESSAGE.GET_STRING('WMS','WMS_REV'));
         FND_MSG_PUB.ADD;
         X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

      END IF;

      IF P_IS_LOT_CONTROLLED = 'Y' AND P_LOT_NUMBER IS NULL THEN

         FND_MESSAGE.SET_NAME('WMS','WMS_ATT_TRN_EXP');
         FND_MESSAGE.SET_TOKEN('TOKEN',FND_MESSAGE.GET_STRING('WMS','WMS_LOT'));
         FND_MSG_PUB.ADD;
         X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

      END IF;

      IF P_IS_SERIAL_CONTROLLED = 'Y' AND P_SERIAL_NUMBER IS NULL THEN

         FND_MESSAGE.SET_NAME('WMS','WMS_ATT_TRN_EXP');
         FND_MESSAGE.SET_TOKEN('TOKEN',FND_MESSAGE.GET_STRING('WMS','WMS_SER'));
         FND_MSG_PUB.ADD;
         X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

      END IF;

      IF P_IS_LPN_REQUIRED = 'Y' AND P_LPN_ID IS NULL THEN

         FND_MESSAGE.SET_NAME('WMS','WMS_ATT_TRN_EXP');
         FND_MESSAGE.SET_TOKEN('TOKEN',FND_MESSAGE.GET_STRING('WMS','WMS_LPN'));
         FND_MSG_PUB.ADD;
         X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

      END IF;

         /* Bug no 2925346 to disallow the cost group transfers
      for the cost group material*/
       IF (X_RETURN_STATUS NOT LIKE 'E')
	THEN
        SELECT segment19 INTO L_PROJ_ID FROM MTL_ITEM_LOCATIONS
         WHERE INVENTORY_LOCATION_ID=p_locator_id;

      IF L_PROJ_ID IS NOT NULL
      THEN

         FND_MESSAGE.SET_NAME('INV','INV_PRJ_CG_XFR_DISALLOWED');
         fnd_msg_pub.add;
         X_RETURN_STATUS:=FND_API.G_RET_STS_ERROR;
         END IF;
	END IF;

      IF P_ORG_ID IS NOT NULL AND P_INVENTORY_ITEM_ID IS NOT NULL AND
         P_SUBINVENTORY IS NOT NULL THEN

         L_RETURN_STATUS := INV_MATERIAL_STATUS_GRP.IS_STATUS_APPLICABLE(
                                                                         'TRUE',
                                                                         NULL,
                                                                         L_TRANSACTION_TYPE_ID,
                                                                         NULL,
                                                                         NULL,
                                                                         P_ORG_ID,
                                                                         P_INVENTORY_ITEM_ID,
                                                                         P_SUBINVENTORY,
                                                                         NULL,
                                                                         NULL,
                                                                         NULL,
                                                                         'Z'
                                                                        );
         IF L_RETURN_STATUS = 'N' THEN

            FND_MESSAGE.SET_NAME('WMS','WMS_ATT_STATUS_NA');
            FND_MESSAGE.SET_TOKEN('TOKEN',FND_MESSAGE.GET_STRING('INV','INV_SUBINV'));
            FND_MSG_PUB.ADD;
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

         END IF;

      END IF; -- Subinventory Status Check

      IF P_ORG_ID IS NOT NULL AND P_INVENTORY_ITEM_ID IS NOT NULL AND
         P_SUBINVENTORY IS NOT NULL AND P_LOCATOR_ID IS NOT NULL THEN

         L_RETURN_STATUS := INV_MATERIAL_STATUS_GRP.IS_STATUS_APPLICABLE(
                                                                         'TRUE',
                                                                         NULL,
                                                                         L_TRANSACTION_TYPE_ID,
                                                                         NULL,
                                                                         NULL,
                                                                         P_ORG_ID,
                                                                         P_INVENTORY_ITEM_ID,
                                                                         P_SUBINVENTORY,
                                                                         P_LOCATOR_ID,
                                                                         NULL,
                                                                         NULL,
                                                                         'L'
                                                                        );
         IF L_RETURN_STATUS = 'N' THEN

            FND_MESSAGE.SET_NAME('WMS','WMS_ATT_STATUS_NA');
            FND_MESSAGE.SET_TOKEN('TOKEN',FND_MESSAGE.GET_STRING('WMS','WMS_LOC'));
            FND_MSG_PUB.ADD;
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

         END IF;

      END IF; -- Locator Status Check.

      IF P_ORG_ID IS NOT NULL AND P_INVENTORY_ITEM_ID IS NOT NULL AND
         P_LOT_NUMBER IS NOT NULL THEN

         L_RETURN_STATUS := INV_MATERIAL_STATUS_GRP.IS_STATUS_APPLICABLE(
                                                                         'TRUE',
                                                                         NULL,
                                                                         L_TRANSACTION_TYPE_ID,
                                                                         NULL,
                                                                         NULL,
                                                                         P_ORG_ID,
                                                                         P_INVENTORY_ITEM_ID,
                                                                         NULL,
                                                                         NULL,
                                                                         P_LOT_NUMBER,
                                                                         NULL,
                                                                         'O'
                                                                        );
         IF L_RETURN_STATUS = 'N' THEN

            FND_MESSAGE.SET_NAME('WMS','WMS_ATT_STATUS_NA');
            FND_MESSAGE.SET_TOKEN('TOKEN',FND_MESSAGE.GET_STRING('WMS','WMS_LOT'));
            FND_MSG_PUB.ADD;
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

         END IF;

      END IF; -- Lot Number Status Check.

      IF P_ORG_ID IS NOT NULL AND P_INVENTORY_ITEM_ID IS NOT NULL AND
         P_SERIAL_NUMBER IS NOT NULL THEN

         L_RETURN_STATUS := INV_MATERIAL_STATUS_GRP.IS_STATUS_APPLICABLE(
                                                                         'TRUE',
                                                                         NULL,
                                                                         L_TRANSACTION_TYPE_ID,
                                                                         NULL,
                                                                         NULL,
                                                                         P_ORG_ID,
                                                                         P_INVENTORY_ITEM_ID,
                                                                         P_SUBINVENTORY,
                                                                         P_LOCATOR_ID,
                                                                         P_LOT_NUMBER,
                                                                         P_SERIAL_NUMBER,
                                                                         'A'
                                                                        );
         IF L_RETURN_STATUS = 'N' THEN

            FND_MESSAGE.SET_NAME('WMS','WMS_ATT_STATUS_NA');
            FND_MESSAGE.SET_TOKEN('TOKEN',FND_MESSAGE.GET_STRING('WMS','WMS_SER'));
            FND_MSG_PUB.ADD;
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

         END IF;

      END IF; -- Serial Number Status Check.

      IF X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN

         IF X_AVAILABILITY IS NULL THEN
            /*Changed from serial and not controlled to only check if serial controlled bug3405867*/
            IF L_IS_SERIAL_CONTROLLED THEN --AND NOT L_IS_LOT_CONTROLLED THEN
            /*Bug fix 3405867 ends*/

            /*
            ** For serial controlled items always return 1 as onhand and available quantity
            */

               L_ATT := 1;
               L_QOH := 1;

            ELSIF P_IS_LPN_REQUIRED = 'Y' THEN

               L_RETURN_STATUS :=  INV_TXN_VALIDATIONS.GET_IMMEDIATE_LPN_ITEM_QTY(
                                                       p_lpn_id              => P_LPN_ID,
                                                       p_organization_id     => P_ORG_ID,
                                                       p_source_type_id      => L_TRANSACTION_SOURCE_TYPE_ID,
                                                       p_inventory_item_id   => P_INVENTORY_ITEM_ID,
   			                               p_revision            => P_REVISION,
			                               p_locator_id          => P_LOCATOR_ID,
			                               p_subinventory_code   => P_SUBINVENTORY,
			                               p_lot_number          => P_LOT_NUMBER,
			                               p_is_revision_control => L_V_IS_REVISION_CONTROLLED,
			                               p_is_serial_control   => L_V_IS_SERIAL_CONTROLLED,
			                               p_is_lot_control      => L_V_IS_LOT_CONTROLLED,
			                               x_transactable_qty    => L_ATT,
			                               x_qoh                 => L_LPN_QOH,
			                               x_lpn_onhand          => L_QOH,
			                               x_return_msg          => L_MSG_DATA
                                                                                 );
                IF L_RETURN_STATUS = 'N' THEN

                   L_ATT := 0;
                   L_QOH := X_ONHAND;
                   FND_MESSAGE.SET_NAME('INV','INV_ERROR_FIND_LPN_QTY');
                   FND_MSG_PUB.ADD;
                   X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

                END IF;

            ELSE

                IF P_LOCATOR_ID IS NULL THEN
                   L_CG_ID := NULL;
                END IF;
	/* added as part of bug fix 2460413 */
            /*    INV_QUANTITY_TREE_PUB.QUERY_QUANTITIES( */

	   /*  Clear the quantity tree cache first to get the right values */
	    INV_QUANTITY_TREE_PUB.CLEAR_QUANTITY_CACHE();

	   /* CREATE THE QUANTITY TREE */
              INV_QUANTITY_TREE_PVT.CREATE_TREE(p_api_version_number  => 1.0,
	                                        x_return_status       => L_RETURN_STATUS,
                                                x_msg_count           => L_MSG_COUNT,
	                                        x_msg_data            => L_MSG_DATA,
                                                p_organization_id     => P_ORG_ID,
	                                        p_inventory_item_id   => P_INVENTORY_ITEM_ID,
                                                p_tree_mode           => 3,
	                                        p_is_revision_control => L_IS_REVISION_CONTROLLED,
	                                        p_is_lot_control      => L_IS_LOT_CONTROLLED,
	                                        p_is_serial_control   => L_IS_SERIAL_CONTROLLED,
						x_tree_id             => L_TREE_ID
	                                        );

	    INV_QUANTITY_TREE_PVT.QUERY_TREE(
                                      p_api_version_number  => 1.0,
	                              x_return_status       => L_RETURN_STATUS,
	                              x_msg_count           => L_MSG_COUNT,
	                              x_msg_data            => L_MSG_DATA,
				      p_tree_id             =>L_TREE_ID,
	                              p_revision            => P_REVISION,
	                              p_lot_number          => P_LOT_NUMBER,
	                              p_subinventory_code   => P_SUBINVENTORY,
	                              p_locator_id          => P_LOCATOR_ID,
	                              p_cost_group_id       => L_CG_ID,
                                      p_transfer_subinventory_code =>P_SUBINVENTORY, -- Bug 2269454
	                              x_qoh                 => L_QOH,
				      x_pqoh                => L_PQOH,
	                              x_rqoh                => L_RQOH,
	                              x_qr                  => L_QR,
	                              x_qs                  => L_QS,
	                              x_att                 => L_ATT,
	                              x_atr                 => L_ATR
	                                        );
 /* packed quantity should not be considered into onhand for loose items */
		L_QOH:=NVL(L_QOH,0)-NVL(L_PQOH,0);
           /* end of bug fix 2460413 */

		IF L_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN

                   X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

                END IF;

             END IF; -- Is Serial controlled / Is LPN Required

             IF NVL(L_ATT,0) <> L_QOH THEN

                FND_MESSAGE.SET_NAME('WMS','WMS_COMMINGLE_WARN');
                FND_MSG_PUB.ADD;
                X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

             END IF;

         END IF; -- Availability is null

      END IF; -- Success so far.

      X_AVAILABILITY := NVL(L_ATT,0);
      X_ONHAND       := NVL(L_QOH,0);

      IF X_RETURN_STATUS = FND_API.G_RET_STS_ERROR THEN

         FND_MSG_PUB.COUNT_AND_GET( P_COUNT =>  X_MSG_COUNT, P_DATA => X_MSG_DATA );

      END IF;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

          X_AVAILABILITY  := NVL(X_AVAILABILITY,0);
          X_ONHAND        := NVL(X_ONHAND,0);
          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          X_AVAILABILITY  := NVL(X_AVAILABILITY,0);
          X_ONHAND        := NVL(X_ONHAND,0);
          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

      WHEN OTHERS THEN

          X_AVAILABILITY  := NVL(X_AVAILABILITY,0);
          X_ONHAND        := NVL(X_ONHAND,0);
          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'VALIDATE');
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

   END VALIDATE;

   PROCEDURE UPDATE_QUANTITY_TREE(
                                  X_RETURN_STATUS          OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
                                  X_MSG_COUNT              OUT NOCOPY /* file.sql.39 change */    NUMBER,
                                  X_MSG_DATA               OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
                                  P_IS_LOT_CONTROLLED      IN     VARCHAR2,
                                  P_IS_SERIAL_CONTROLLED   IN     VARCHAR2,
                                  P_IS_LPN_REQUIRED        IN     VARCHAR2,
                                  P_ORG_ID                 IN     NUMBER,
                                  P_INVENTORY_ITEM_ID      IN     NUMBER,
                                  P_REVISION               IN     VARCHAR2,
                                  P_SUBINVENTORY           IN     VARCHAR2,
                                  P_LOCATOR_ID             IN     NUMBER,
                                  P_LOT_NUMBER             IN     VARCHAR2,
                                  P_ONHAND                 IN     NUMBER,
                                  P_UOM                    IN     VARCHAR2,
                                  P_PRIMARY_UOM            IN     VARCHAR2,
                                  P_COSTGROUP_ID           IN     NUMBER,
                                  P_XFR_COSTGROUP_ID       IN     NUMBER
                                 ) IS

      L_MSG_COUNT                  NUMBER;
      L_MSG_DATA                   VARCHAR2(2000);
      L_RETURN_STATUS              VARCHAR2(1);
      L_PRIMARY_QUANTITY           NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
      L_LOT_NUMBER                 VARCHAR2(80);
      L_COST_GROUP_ID              NUMBER;
      L_QOH                        NUMBER;
      L_ATT                        NUMBER;
      L_CONTAINERIZED              NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN

      L_PRIMARY_QUANTITY := INV_CONVERT.INV_UM_CONVERT(
                                        ITEM_ID       => P_INVENTORY_ITEM_ID,
                                        PRECISION     => NULL,
                                        FROM_QUANTITY => P_ONHAND,
                                        FROM_UNIT     => P_UOM,
                                        TO_UNIT       => P_PRIMARY_UOM,
                                        FROM_NAME     => NULL,
                                        TO_NAME       => NULL
                                                      );

      IF P_IS_LOT_CONTROLLED  = 'Y' THEN

         L_LOT_NUMBER := P_LOT_NUMBER;

      ELSE

         L_LOT_NUMBER := NULL;

      END IF;

      IF P_IS_SERIAL_CONTROLLED  = 'Y' THEN

         L_PRIMARY_QUANTITY := 1;

      END IF;

      IF P_IS_LPN_REQUIRED = 'Y' THEN

         L_CONTAINERIZED := 1;

      ELSE

         L_CONTAINERIZED := 0;

      END IF;

      INV_ITEM_INQ.UPDATE_QUANTITY(
                                   P_ORGANIZATION_ID   => P_ORG_ID,
                                   P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID,
                                   P_REVISION          => P_REVISION,
                                   P_LOT_NUMBER        => L_LOT_NUMBER,
                                   P_SUBINVENTORY_CODE => P_SUBINVENTORY ,
                                   P_LOCATOR_ID        => P_LOCATOR_ID,
                                   P_COST_GROUP_ID     => P_COSTGROUP_ID,
                                   P_PRIMARY_QUANTITY  => ( -1 * L_PRIMARY_QUANTITY ),
                                   P_CONTAINERIZED     => L_CONTAINERIZED,
                                   X_QOH               => L_QOH,
                                   X_ATT               => L_ATT,
                                   X_RETURN_STATUS     => L_RETURN_STATUS,
                                   X_MSG_DATA          => L_MSG_DATA,
                                   X_MSG_COUNT         => L_MSG_COUNT
                                  );

      INV_ITEM_INQ.UPDATE_QUANTITY(
                                   P_ORGANIZATION_ID   => P_ORG_ID,
                                   P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID,
                                   P_REVISION          => P_REVISION,
                                   P_LOT_NUMBER        => L_LOT_NUMBER,
                                   P_SUBINVENTORY_CODE => P_SUBINVENTORY ,
                                   P_LOCATOR_ID        => P_LOCATOR_ID,
                                   P_COST_GROUP_ID     => P_XFR_COSTGROUP_ID,
                                   P_PRIMARY_QUANTITY  => L_PRIMARY_QUANTITY,
                                   P_CONTAINERIZED     => L_CONTAINERIZED,
                                   X_QOH               => L_QOH,
                                   X_ATT               => L_ATT,
                                   X_RETURN_STATUS     => L_RETURN_STATUS,
                                   X_MSG_DATA          => L_MSG_DATA,
                                   X_MSG_COUNT         => L_MSG_COUNT
                                  );

      IF L_RETURN_STATUS <> 'S'  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;


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
             FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'TRANSFER');
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

   END UPDATE_QUANTITY_TREE;

END INV_MWB_CG_TRANSFER;

/
