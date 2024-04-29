--------------------------------------------------------
--  DDL for Package Body MTL_CC_TRANSACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CC_TRANSACT_PKG" as
/* $Header: INVATC2B.pls 120.0.12010000.2 2010/03/18 22:29:21 mchemban ship $ */

function CC_TRANSACT (  org_id                  NUMBER                   ,
                        cc_header_id            NUMBER                   ,
                        item_id                 NUMBER                   ,
                        sub                     VARCHAR2                 ,
                        PUOMQty                 NUMBER                   ,
                        TxnQty                  NUMBER                   ,
                        TxnUOM                  VARCHAR2                 ,
                        TxnDate                 DATE                     ,
                        TxnAcctId               NUMBER                   ,
                        LotNum                  VARCHAR2                 ,
                        LotExpDate              DATE                     ,
                        rev                     VARCHAR2                 ,
                        locator_id              NUMBER                   ,
                        TxnRef                  VARCHAR2                 ,
                        ReasonId                NUMBER                   ,
                        UserId                  NUMBER                   ,
                        cc_entry_id             NUMBER                   ,
                        LoginId                 NUMBER                   ,
                        TxnProcMode             NUMBER                   ,
                        TxnHeaderId             NUMBER                   ,
                        SerialNum               VARCHAR2                 ,
                        TxnTempId               NUMBER                   ,
                        SerialPrefix            VARCHAR2                 ,
                        lpn_id                  NUMBER                   ,
                        transfer_sub            VARCHAR2 DEFAULT NULL    ,
                        transfer_loc_id         NUMBER DEFAULT NULL      ,
                        cost_group_id           NUMBER DEFAULT NULL      ,
                        lpn_discrepancy         NUMBER DEFAULT 2
                        ,secUOM                 VARCHAR2 DEFAULT NULL    -- INVCONV,NSRIVAST
                        ,secQty                 NUMBER DEFAULT NULL      -- INVCONV,NSRIVAST

                        )                       RETURN NUMBER
  IS

     v_period_id              NUMBER;
     v_open_past_period       BOOLEAN := FALSE;
     v_profile_value          NUMBER  := 0;
     v_transaction_action_id  NUMBER;
     l_transaction_temp_id    NUMBER;
     l_serial_temp_id         NUMBER;
     v_transaction_type_id    NUMBER;   --4159102

     /* WMS variables needed */
     l_result                 NUMBER;
     l_proc_msg               VARCHAR2(300);
     l_wms_installed          VARCHAR2(10);
     l_lot_exp_date           DATE;
     l_serial_prefix          VARCHAR2(30);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (fnd_profile.defined('TRANSACTION_DATE')) THEN
      v_profile_value := TO_NUMBER(fnd_profile.value('TRANSACTION_DATE'));

      -- Profile value of:
      -- 1 = Any open period
      -- 2 = No past date
      -- 3 = No past periods
      -- 4 = Warn when past period

      IF (v_profile_value = 3) THEN
         v_open_past_period := TRUE;
      END IF;
    ELSE
      FND_MESSAGE.SET_NAME('FND','PROFILES-CANNOT READ');
      FND_MESSAGE.SET_TOKEN('OPTION','TRANSACTION_DATE',TRUE);
      FND_MESSAGE.SET_TOKEN('ROUTINE',
                            'MTL_CC_TRANSACT_PKG.CC_TRANSACT ',TRUE);

      --Bug 4171757- Added the below statement to capture messages in the calling program
      FND_MSG_PUB.ADD;
      --End of fix for Bug 4171757

      --Bug 4171757 -Added the following for messages in the INV debug file.
      IF (l_debug = 1) THEN
       inv_log_util.TRACE('Errors out here with the message to user: ' || 'PROFILES-CANNOT READ', 'MTL_CC_TRANSACT_PKG', 9);
      END IF;
      --End of fix for Bug 4171757

      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN -1;
   END IF;

   IF (v_profile_value = 2 AND TxnDate < TRUNC(SYSDATE)) THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_NO_PAST_TXN_DATES');

      --Bug 4171757- Added the below statement to capture messages in the calling program
      FND_MSG_PUB.ADD;
      --End of fix for Bug 4171757

      --Bug 4171757 -Added the following for messages in the INV debug file.
      IF (l_debug = 1) THEN
       inv_log_util.TRACE('Errors out here with the message to user: ' || 'INV_NO_PAST_TXN_DATES', 'MTL_CC_TRANSACT_PKG', 9);
      END IF;
      --End of fix for Bug 4171757

      app_exception.raise_exception;
      RETURN -1;
   END IF;

   invttmtx.tdatechk(org_id,
                     TxnDate,
                     v_period_id,
                     v_open_past_period);

   IF (v_period_id = 0) THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_NO_OPEN_PERIOD');

      --Bug 4171757- Added the below statement to capture messages in the calling program
      FND_MSG_PUB.ADD;
      --End of fix for Bug 4171757

      --Bug 4171757 -Added the following for messages in the INV debug file.
      IF (l_debug = 1) THEN
       inv_log_util.TRACE('Errors out here with the message to user: ' || 'INV_NO_OPEN_PERIOD', 'MTL_CC_TRANSACT_PKG', 9);
      END IF;
      --End of fix for Bug 4171757

      app_exception.raise_exception;
      RETURN -1;
    ELSIF (v_period_id = -1) THEN
      app_exception.raise_exception;
      RETURN -1;
    ELSE
      IF (v_profile_value = 3) AND
        NOT (v_open_past_period) THEN
         FND_MESSAGE.SET_NAME('INV', 'INV_NO_PAST_TXN_PERIODS');

        --Bug 4171757- Added the below statement to capture messages in the calling program
        FND_MSG_PUB.ADD;
        --End of fix for Bug 4171757

       --Bug 4171757 -Added the following for messages in the INV debug file.
       IF (l_debug = 1) THEN
          inv_log_util.TRACE('Errors out here with the message to user: ' || 'INV_NO_PAST_TXN_PERIODS', 'MTL_CC_TRANSACT_PKG', 9);
       END IF;
       --End of fix for Bug 4171757

         app_exception.raise_exception;
         RETURN -1;
      END IF;
   END IF;

   --Check whether WMS is installed
   IF inv_install.adv_inv_installed(NULL) THEN
     l_wms_installed := 'TRUE';
   ELSE
     l_wms_installed := 'FALSE';
   END IF;

   --Check the materisl status applicability for the org, item and lot number
   --combination for the cycle count adjust transaction. If it is not valid
   --then set the return value to "2" to indicate invalid lot status
   IF l_wms_installed = 'TRUE' AND  LotNum IS NOT NULL THEN
     IF  inv_material_status_grp.is_status_applicable
              ( l_wms_installed,
                NULL,
                4,
                NULL,
                NULL,
                org_id,
                item_id,
                NULL,
                NULL,
                LotNum,
                NULL,
                'O') = 'Y' THEN
       NULL;
     ELSE
       RETURN 2;
     END IF;
   END IF;

   --Check the material status applicability for the org, item and serial number
   --combination for the cycle count adjust transaction. If it is not valid
   --then set the return value to "3" to indicate invalid serial status
   IF l_wms_installed = 'TRUE' AND  SerialNum IS NOT NULL THEN
     IF  inv_material_status_grp.is_status_applicable
              ( l_wms_installed,
                NULL,
                4,  --transaction_type_id
                NULL,
                NULL,
                org_id,
                item_id,
                NULL,
                NULL,
                NULL,
                SerialNum,
                'S') = 'Y' THEN
       NULL;
     ELSE
       RETURN 3;
     END IF;
   END IF;

   IF transfer_sub IS NOT NULL AND transfer_loc_id IS NOT NULL THEN
      v_transaction_action_id := 2;
      v_transaction_type_id := 5; -- 4159102
    ELSE
      v_transaction_action_id := 4;
      v_transaction_type_id := 4; -- 4159102
   END IF;
   --inv_debug.message('ssia', 'In INVATC2B.pls ');
   --inv_debug.message('ssia', 'Transaction header id is ' ||   TxnHeaderId);
   --inv_Debug.message('ssia', 'Transaction temp id is ' || TxnTempId);
   --inv_Debug.message('ssia', 'Item id is ' || item_id);
   --inv_Debug.message('ssia', 'Sub is ' ||sub);
   IF (TxnTempId IS NULL) THEN
      SELECT mtl_material_transactions_s.NEXTVAL
        INTO l_transaction_temp_id
        FROM dual;
    ELSE
      l_transaction_temp_id := TxnTempId;
   END IF;

   -- Whether WMS is installed or not installed,
   -- it is required to insert a record into MMTT.

   IF (lpn_discrepancy = 2) THEN
      -- Normal cycle count transaction insertion

      -- Insert adjustment record into MMTT with no
      -- values for Lot_Number and Serial_Number
      IF (txnqty < 0) THEN
         -- Negative adjustment quantity so the LPN column to insert into
         -- should be LPN_ID

         -- Bug# 2872044
         -- TM orders by the txn batch ID instead of txn temp ID as of
         -- patchset I so store the value of the txn temp ID in the batch
         -- ID column to maintain the order in which MMTT records are processed
         INSERT INTO MTL_MATERIAL_TRANSACTIONS_TEMP
           (
             TRANSACTION_HEADER_ID,
             TRANSACTION_TEMP_ID,
             INVENTORY_ITEM_ID,
             SUBINVENTORY_CODE,
             PRIMARY_QUANTITY,
             TRANSACTION_QUANTITY,
             TRANSACTION_UOM,
             TRANSACTION_DATE,
             ORGANIZATION_ID,
             ACCT_PERIOD_ID,
             TRANSACTION_MODE,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             TRANSACTION_SOURCE_ID,
             TRANSACTION_SOURCE_TYPE_ID,
             CYCLE_COUNT_ID,
             TRANSACTION_TYPE_ID,
             TRANSACTION_ACTION_ID,
             TRANSACTION_REFERENCE,
             REASON_ID,
             DISTRIBUTION_ACCOUNT_ID,
             --LOT_NUMBER,
             --WAYBILL_AIRBILL, /* Lot expiration date */
             REVISION,
             LOCATOR_ID,
             --SERIAL_NUMBER,
             PROCESS_FLAG,
             LAST_UPDATE_LOGIN,
             CREATED_BY,
             CREATION_DATE,
             LPN_ID,
             TRANSFER_SUBINVENTORY,
             TRANSFER_TO_LOCATION,
             COST_GROUP_ID,
             TRANSACTION_BATCH_ID,
             TRANSACTION_BATCH_SEQ,
	     -- BEGIN INVCONV
             SECONDARY_UOM_CODE,
	     SECONDARY_TRANSACTION_QUANTITY
	     -- END INVCONV
             )
           VALUES
           (
             TxnHeaderId,
             l_transaction_Temp_id,
             item_id,
             sub,
             PUOMQty,
             TxnQty,
             TxnUOM,
             TxnDate,
             org_id,
             v_period_id,
             TxnProcMode,
             SYSDATE,
             UserID,
             cc_header_id,
             9,
             cc_entry_id,
             v_transaction_type_id,              -- 4159102
             v_transaction_action_id,
             TxnRef,
             ReasonId,
             TxnAcctID,
             --LotNum,
             --LotExpDate,
             rev,
             locator_id,
             --SerialNum,
             'Y',
             LoginID,
             UserID,
             SYSDATE,
             lpn_id,
             transfer_sub,
             transfer_loc_id,
             cost_group_id,
             l_transaction_Temp_id,
             l_transaction_Temp_id,
	     -- BEGIN INVCONV
             secUOM,
	     secQty
	     -- END INVCONV
             );
       ELSE
         -- Positive adjustment quantity so the LPN column to insert into
         -- should be TRANSFER_LPN_ID

         -- Bug# 2872044
         -- TM orders by the txn batch ID instead of txn temp ID as of
         -- patchset I so store the value of the txn temp ID in the batch
         -- ID column to maintain the order in which MMTT records are processed
         INSERT INTO MTL_MATERIAL_TRANSACTIONS_TEMP
           (
             TRANSACTION_HEADER_ID,
             TRANSACTION_TEMP_ID,
             INVENTORY_ITEM_ID,
             SUBINVENTORY_CODE,
             PRIMARY_QUANTITY,
             TRANSACTION_QUANTITY,
             TRANSACTION_UOM,
             TRANSACTION_DATE,
             ORGANIZATION_ID,
             ACCT_PERIOD_ID,
             TRANSACTION_MODE,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             TRANSACTION_SOURCE_ID,
             TRANSACTION_SOURCE_TYPE_ID,
             CYCLE_COUNT_ID,
             TRANSACTION_TYPE_ID,
             TRANSACTION_ACTION_ID,
             TRANSACTION_REFERENCE,
             REASON_ID,
             DISTRIBUTION_ACCOUNT_ID,
             --LOT_NUMBER,
             --WAYBILL_AIRBILL, /* Lot expiration date */
             REVISION,
             LOCATOR_ID,
             --SERIAL_NUMBER,
             PROCESS_FLAG,
             LAST_UPDATE_LOGIN,
             CREATED_BY,
             CREATION_DATE,
             TRANSFER_LPN_ID,
             TRANSFER_SUBINVENTORY,
             TRANSFER_TO_LOCATION,
             COST_GROUP_ID,
             TRANSACTION_BATCH_ID,
             TRANSACTION_BATCH_SEQ,
	     -- BEGIN INVCONV
             SECONDARY_UOM_CODE,
	     SECONDARY_TRANSACTION_QUANTITY
	     -- END INVCONV
             )
           VALUES
           (
             TxnHeaderId,
             l_transaction_Temp_id,
             item_id,
             sub,
             PUOMQty,
             TxnQty,
             TxnUOM,
             TxnDate,
             org_id,
             v_period_id,
             TxnProcMode,
             SYSDATE,
             UserID,
             cc_header_id,
             9,
             cc_entry_id,
             v_transaction_type_id,              -- 4159102
             v_transaction_action_id,
             TxnRef,
             ReasonId,
             TxnAcctID,
             --LotNum,
             --LotExpDate,
             rev,
             locator_id,
             --SerialNum,
             'Y',
             LoginID,
             UserID,
             SYSDATE,
             lpn_id,
             transfer_sub,
             transfer_loc_id,
             cost_group_id,
             l_transaction_Temp_id,
             l_transaction_Temp_id,
	     -- BEGIN INVCONV
             secUOM,
	     secQty
	     -- END INVCONV
             );
      END IF;

      -- Item is lot controlled
      IF (LotNum IS NOT NULL) THEN

         -- If item is also serial controlled,
         -- generate a serial transaction temp ID
         IF (SerialNum IS NOT NULL) THEN
            SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
              INTO l_serial_temp_id
              FROM DUAL;
          ELSE
            l_serial_temp_id := NULL;
         END IF;

         -- Get the Lot Expiration Date
         -- for this Lot Number if none was passed in
         IF (LotExpDate IS NULL) THEN
            SELECT  EXPIRATION_DATE
              INTO    l_lot_exp_date
              FROM    MTL_LOT_NUMBERS
              WHERE   INVENTORY_ITEM_ID = item_id
              AND     ORGANIZATION_ID = org_id
              AND     LOT_NUMBER = LotNum;
          ELSE
            l_lot_exp_date := LotExpDate;
         END IF;

         -- Insert a record into MTLT
         INSERT INTO MTL_TRANSACTION_LOTS_TEMP
           ( TRANSACTION_TEMP_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             TRANSACTION_QUANTITY,
             PRIMARY_QUANTITY,
             LOT_NUMBER,
             LOT_EXPIRATION_DATE,
             SERIAL_TRANSACTION_TEMP_ID,
             GROUP_HEADER_ID
             , secondary_quantity         -- INVCONV,NSRIVAST
             , secondary_unit_of_measure  -- INVCONV,NSRIVAST
             )
           VALUES
           ( l_transaction_Temp_id,
             SYSDATE,
             UserID,
             SYSDATE,
             UserID,
             LoginID,
             TxnQty,
             PUOMQty,
             LotNum,
             l_lot_exp_date,
             l_serial_temp_id,
             TxnHeaderId
             ,secQty  -- INVCONV,NSRIVAST
             ,secUOM  -- INVCONV,NSRIVAST
             );
      END IF;

      -- Item is serial controlled
      IF (SerialNum IS NOT NULL) THEN

         -- If Item is not Lot controlled,
         -- then use the transaction temp ID
         -- from the MMTT record
         IF (LotNum IS NULL) THEN
            l_serial_temp_id := l_transaction_temp_id;
         END IF;

         --Get the serial prefix for this serial number
         SELECT    AUTO_SERIAL_ALPHA_PREFIX
           INTO    l_serial_prefix
           FROM    MTL_SYSTEM_ITEMS
           WHERE   INVENTORY_ITEM_ID = item_id
           AND     ORGANIZATION_ID = org_id;

         INSERT INTO MTL_SERIAL_NUMBERS_TEMP
           ( TRANSACTION_TEMP_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             FM_SERIAL_NUMBER,
             TO_SERIAL_NUMBER,
             SERIAL_PREFIX,
             GROUP_HEADER_ID
             )
           VALUES
           ( l_serial_temp_id,
             SYSDATE,
             UserID,
             SYSDATE,
             UserID,
             LoginID,
             SerialNum,
             SerialNum,
             l_serial_prefix,
             TxnHeaderId);
      END IF;

    ELSE -- lpn_discrepancy = 1
      -- LPN discrepancy transaction so the LPN column to
      -- insert into is CONTENT_LPN_ID
      INSERT INTO MTL_MATERIAL_TRANSACTIONS_TEMP
        (
          TRANSACTION_HEADER_ID,
          TRANSACTION_TEMP_ID,
          INVENTORY_ITEM_ID,
          SUBINVENTORY_CODE,
          PRIMARY_QUANTITY,
          TRANSACTION_QUANTITY,
          TRANSACTION_UOM,
          TRANSACTION_DATE,
          ORGANIZATION_ID,
          ACCT_PERIOD_ID,
          TRANSACTION_MODE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          TRANSACTION_SOURCE_ID,
          TRANSACTION_SOURCE_TYPE_ID,
          CYCLE_COUNT_ID,
          TRANSACTION_TYPE_ID,
          TRANSACTION_ACTION_ID,
          TRANSACTION_REFERENCE,
          REASON_ID,
          DISTRIBUTION_ACCOUNT_ID,
          LOT_NUMBER,
          WAYBILL_AIRBILL, /* Lot expiration date */
          REVISION,
          LOCATOR_ID,
          SERIAL_NUMBER,
          PROCESS_FLAG,
          LAST_UPDATE_LOGIN,
          CREATED_BY,
          CREATION_DATE,
          CONTENT_LPN_ID,
          TRANSFER_SUBINVENTORY,
          TRANSFER_TO_LOCATION,
          COST_GROUP_ID,
          TRANSACTION_BATCH_ID,
          TRANSACTION_BATCH_SEQ,
          -- BEGIN INVCONV
          SECONDARY_UOM_CODE,
	  SECONDARY_TRANSACTION_QUANTITY
	  -- END INVCONV
          )
        VALUES
        (
          TxnHeaderId,
          l_transaction_Temp_id,
          item_id,
          sub,
          PUOMQty,
          TxnQty,
          TxnUOM,
          TxnDate,
          org_id,
          v_period_id,
          TxnProcMode,
          SYSDATE,
          UserID,
          cc_header_id,
          9,
          NULL, --cc_entry_id,9452528
          v_transaction_type_id,                 --4159102
          v_transaction_action_id,
          TxnRef,
          ReasonId,
          TxnAcctID,
          LotNum,
          LotExpDate,
          rev,
          locator_id,
          SerialNum,
          'Y',
          LoginID,
          UserID,
          SYSDATE,
          lpn_id,
          transfer_sub,
          transfer_loc_id,
          cost_group_id,
          l_transaction_Temp_id,
          l_transaction_Temp_id,
          -- BEGIN INVCONV
          secUOM,
	  secQty
	  -- END INVCONV
          );
   END IF;

   RETURN 1;

EXCEPTION
   WHEN OTHERS THEN
     --Bug 4171757 -Throwing the error message "Transaction Failed " to the user if an exception is raised.

     FND_MESSAGE.SET_NAME('INV','INV_FAILED');
     FND_MSG_PUB.ADD ;

     --End of fix for Bug 4171757

    --Bug 4171757 -Added the following for messages in the INV debug file.
    IF (l_debug = 1) THEN
       inv_log_util.TRACE('In the exception block, here throwing the message to the user: ' || 'INV_FAILED', 'MTL_CC_TRANSACT_PKG', 9);
    END IF;
    --End of fix for Bug 4171757

   RETURN - 1;

END CC_TRANSACT;


END MTL_CC_TRANSACT_PKG;

/
