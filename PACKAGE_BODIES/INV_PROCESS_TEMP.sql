--------------------------------------------------------
--  DDL for Package Body INV_PROCESS_TEMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PROCESS_TEMP" AS
/* $Header: INVMMTTB.pls 120.1 2005/12/09 16:56:04 kdong noship $ */

-- presently has only TIMEBASED validation
-- eventually we will provide the complete validation
FUNCTION processTransaction(headerID IN NUMBER,
                            validationLevel IN NUMBER,
                            errorTolerance  IN NUMBER) RETURN NUMBER
IS
  status       NUMBER := 1;
  hasErrors    BOOLEAN := FALSE;
  l_txnrecs    TXNRECS;
  l_txnrecord  TXNREC;
  l_org        INV_Validate.ORG;
  l_item       INV_Validate.ITEM;
  l_openAcctPeriod NUMBER;

  l_row_count   NUMBER;
  l_errorTolerance NUMBER;
BEGIN
  -- get the user information and populate
  -- this info is used to stamp the transaction records incase of errors
  userid := fnd_global.user_id;
  loginid := fnd_global.login_id;
  applid := fnd_global.prog_appl_id;
  reqstid := fnd_global.conc_request_id;
  progid := fnd_global.conc_program_id;
  INV_PROCESS_TEMP.validationLevel := validationLevel;

  header_id := headerID;
  l_errorTolerance := errorTolerance;
-- Bug 2574288 added rownum < 2 to the where clause

  if(l_errorTolerance <> IGNORE_NONE) then
    select count(1)
      into l_row_count
      from mtl_material_transactions_temp
     where transaction_header_id = header_id
       and process_flag = 'Y'
       and transaction_status = TS_PROCESS
       and rownum < 2;
    if(l_row_count = 1) then l_errorTolerance := IGNORE_NONE; end if;
  end if;

  status := validateSupportedTxns(validationLevel);
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateFromOrganization;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateToOrganization;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateItem;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateFromSubinventory;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateFromLocator;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateToSubinventory;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateToLocator;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateTxnUOM;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateTransactionSource;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateSourceProject;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateSourceTask;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateCostGroups;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateExpenditureType;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateExpenditureOrg;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateToOrgItem;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateToOrgItemRevision;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateInterOrgItemControls;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  status := validateFreightInfo;
  if(not hasErrors and status <> 1)
  then
    hasErrors := TRUE;
    if(l_errorTolerance = IGNORE_NONE) then return 0; end if;
  end if;

  -- Bug 4200332
  -- Round transaction/primary quantities to 5 decimals

  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
  SET    PRIMARY_QUANTITY = ROUND(PRIMARY_QUANTITY,5),
         TRANSACTION_QUANTITY = ROUND(TRANSACTION_QUANTITY,5)
  WHERE  TRANSACTION_HEADER_ID = header_id
  AND    PROCESS_FLAG = 'Y'
  AND    TRANSACTION_STATUS = 3;

  -- validation for individual records
  OPEN l_TXNRECS FOR
       SELECT MMTT.*,ROWID
         FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
        WHERE TRANSACTION_HEADER_ID = headerID
          AND PROCESS_FLAG='Y'
          AND TRANSACTION_STATUS = TS_PROCESS
       ORDER BY ORGANIZATION_ID,INVENTORY_ITEM_ID,REVISION,
                SUBINVENTORY_CODE,LOCATOR_ID;
  LOOP
    FETCH l_txnrecs INTO l_txnrecord;
    EXIT WHEN l_TXNRECS%NOTFOUND;
    -- get key entity objects
    l_org.organization_id := l_txnrecord.organization_id;
    status := INV_Validate.Organization(l_org);

    l_item.organization_id := l_txnrecord.organization_id;
    l_item.inventory_item_id := l_txnrecord.inventory_item_id;
    status := INV_Validate.Inventory_Item(l_item,l_org);

    status := validateLOT(l_txnrecord,l_org,l_item);
    status := validateUnitNumber(l_txnrecord);

    l_openAcctPeriod := getAccountPeriodId(l_txnrecord.organization_id,
                                           l_txnrecord.transaction_date);
    if(l_openAcctPeriod <= 0) then
      loadmsg('INV_INT_PRDCODE','INV_INT_PRDCODE');
      if(l_openAcctPeriod = 0) then
        loadmsg('INV_INT_PRDCODE','INV_NO_OPEN_PERIOD');
      end if;
      errupdate(l_txnrecord.rowid);
    end if;

    UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           ACCT_PERIOD_ID = l_openAcctPeriod
     WHERE ROWID = l_txnrecord.rowid;
  END LOOP;

  if hasErrors then return 0; else return 1; end if;
END processTransaction;

/* validates a transaction against supported list of transactions
   based on the validation Level. Presently supported transactions are

   TIME BASED:
      TXN SRC      TXN TYPE     TXN ACTION
        13            2             2
	2	      52	    28
        8	      53	    28
	4	      64	    2
        4	      63            1
   FULL       eventually everything should be supported for this.
      TXN SRC      TXN TYPE     TXN ACTION
*/
FUNCTION validateSupportedTxns(validationLevel IN NUMBER) RETURN NUMBER
IS
BEGIN
  loadmsg('INV_TXN_NOT_SUPPORTED','INV_TXN_NOT_SUPPORTED_VLEVEL');
  if(validationLevel = INV_PROCESS_TEMP.TIMEBASED)
  then
    UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           TRANSACTION_STATUS = 1,
           LOCK_FLAG = 'N',
           ERROR_CODE = substr(err_code,1,240),
           ERROR_EXPLANATION = substr(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND (NOT (TRANSACTION_SOURCE_TYPE_ID IN (13, 2, 4)
                AND TRANSACTION_ACTION_ID IN (2, 28, 1)
		AND TRANSACTION_TYPE_ID not in (33)));
  end if;
  if(SQL%FOUND) then return 0; else return 1; end if;
END validateSupportedTxns;

/* validates from organization */
FUNCTION validateFromOrganization RETURN NUMBER
IS
BEGIN
  loadmsg('INV_INT_ORGCODE','INV_INT_ORGEXP');

  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
        SET LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = userid,
            LAST_UPDATE_LOGIN = loginid,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROCESS_FLAG = 'E',
            TRANSACTION_STATUS = 1,
            LOCK_FLAG = 'N',
            ERROR_CODE = substr(err_code,1,240),
            ERROR_EXPLANATION = substr(error_exp,1,240)
      WHERE TRANSACTION_HEADER_ID = header_id
        AND PROCESS_FLAG = 'Y'
        AND TRANSACTION_STATUS = 3
        AND NOT EXISTS (
           SELECT NULL
             FROM ORG_ORGANIZATION_DEFINITIONS OOD
            WHERE OOD.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
              AND NVL(OOD.DISABLE_DATE, SYSDATE + 1) > SYSDATE);
  if(SQL%FOUND) then return 0; else return 1; end if;
END validateFromOrganization;

/* validates to organization */
FUNCTION validateToOrganization RETURN NUMBER
IS
BEGIN
  loadmsg('INV_INT_XORGCODE','INV_INT_XORGEXP');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           TRANSACTION_STATUS = 1,
           LOCK_FLAG = 'N',
           ERROR_CODE = substr(err_code,1,240),
           ERROR_EXPLANATION = substr(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND TRANSACTION_ACTION_ID in (3,21)
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND (NOT EXISTS (
           SELECT NULL
           FROM ORG_ORGANIZATION_DEFINITIONS OOD
           WHERE OOD.ORGANIZATION_ID = MMTT.TRANSFER_ORGANIZATION
             AND NVL(OOD.DISABLE_DATE, SYSDATE + 1) > SYSDATE)
           OR NOT EXISTS (
           SELECT NULL
           FROM MTL_INTERORG_PARAMETERS MIP
           WHERE MIP.TO_ORGANIZATION_ID = MMTT.TRANSFER_ORGANIZATION
             AND MIP.FROM_ORGANIZATION_ID = MMTT.ORGANIZATION_ID));
  if(SQL%FOUND) then return 0; else return 1; end if;
END validateToOrganization;

/* validates item */
FUNCTION validateItem RETURN NUMBER
IS
  l_status    NUMBER;
BEGIN
  if validationLevel = TIMEBASED then return 1; end if;

  loadmsg('INV_INT_ITMCODE','INV_INT_ITMEXP');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
            SET LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = userid,
            LAST_UPDATE_LOGIN = loginid,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROCESS_FLAG = 'E',
            TRANSACTION_STATUS = 1,
            LOCK_FLAG = 'N',
            ERROR_CODE = substr(err_code,1,240),
            ERROR_EXPLANATION = substr(error_exp,1,240)
  WHERE TRANSACTION_HEADER_ID = header_id
    AND PROCESS_FLAG = 'Y'
    AND TRANSACTION_STATUS = 3
    AND ((INVENTORY_ITEM_ID IS NOT NULL
              AND (TRANSACTION_ACTION_ID NOT IN (1, 27, 33, 34)
              OR TRANSACTION_SOURCE_TYPE_ID <> 5)) OR
            (TRANSACTION_ACTION_ID <> 24
              AND NVL(SHIPPABLE_FLAG,'Y') = 'Y'))
    AND NOT EXISTS (
         SELECT NULL
           FROM MTL_SYSTEM_ITEMS MSI
          WHERE MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
            AND MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
            AND MSI.INVENTORY_ITEM_FLAG = 'Y');
  if(SQL%FOUND) then l_status := 0; else l_status := 1; end if;

  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND TRANSACTION_ACTION_ID = 24
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_SYSTEM_ITEMS MSI
           WHERE MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
             AND MSI.INVENTORY_ITEM_FLAG = 'Y'
             AND MSI.INVENTORY_ASSET_FLAG = 'Y'
             AND MSI.COSTING_ENABLED_FLAG = 'Y');
   if SQL%FOUND then l_status := 0; end if;
   return l_status;
END validateItem;

/* validates item's revision */
FUNCTION validateItemRevision RETURN NUMBER
IS
BEGIN
  if validationLevel = TIMEBASED then return 1; end if;
  loadmsg('INV_INT_REVCODE','INV_INT_REVEXP');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 1
       AND TRANSACTION_ACTION_ID NOT IN (24,33,34)
       AND NOT EXISTS (
           SELECT NULL
             FROM MTL_ITEM_REVISIONS MIR,
                  MTL_SYSTEM_ITEMS MSI
            WHERE MSI.REVISION_QTY_CONTROL_CODE = 2
              AND MIR.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
              AND MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
              AND MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
              AND MIR.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MSI.ORGANIZATION_ID
              AND MIR.REVISION = MMTT.REVISION
             UNION
              SELECT NULL
                FROM MTL_SYSTEM_ITEMS ITM
               WHERE ITM.REVISION_QTY_CONTROL_CODE = 1
                 AND MMTT.REVISION IS NULL
                 AND ITM.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
                 AND ITM.ORGANIZATION_ID = MMTT.ORGANIZATION_ID);
   if SQL%FOUND then return 0; else return 1; end if;
END validateItemRevision;

/* validates item in to org context */
FUNCTION validateToOrgItem RETURN NUMBER
IS
BEGIN
-- Bug 3951494
-- The validation should happen for the MMTT record not the MTI record.
-- Changing the below sql validation against MMTT.
  if validationLevel = TIMEBASED then return 1; end if;
  loadmsg('INV_INT_ITEMCODE','INV_INT_XFRITEMEXP');
/*  UPDATE MTL_TRANSACTIONS_INTERFACE MTI
     SET LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATED_BY = userid,
         LAST_UPDATE_LOGIN = loginid,
         PROGRAM_UPDATE_DATE = SYSDATE,
         PROCESS_FLAG = 3,
         LOCK_FLAG = 2,
         ERROR_CODE = substrb(err_code,1,240),
         ERROR_EXPLANATION = substrb(error_exp,1,240)
   WHERE TRANSACTION_HEADER_ID = header_id
     AND TRANSACTION_ACTION_ID = 3
     AND PROCESS_FLAG = 1
     AND NVL(SHIPPABLE_FLAG,'Y') = 'Y'
     AND NOT EXISTS (
          SELECT NULL
           FROM MTL_SYSTEM_ITEMS MSI
           WHERE MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
             AND MSI.ORGANIZATION_ID = MTI.TRANSFER_ORGANIZATION
             AND MSI.MTL_TRANSACTIONS_ENABLED_FLAG = 'Y'); */

  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
     SET LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATED_BY = userid,
         LAST_UPDATE_LOGIN = loginid,
         PROGRAM_UPDATE_DATE = SYSDATE,
         PROCESS_FLAG = 'E',
         LOCK_FLAG = 'N',
         ERROR_CODE = substrb(err_code,1,240),
         ERROR_EXPLANATION = substrb(error_exp,1,240)
   WHERE TRANSACTION_HEADER_ID = header_id
     AND TRANSACTION_ACTION_ID = 3
     AND PROCESS_FLAG = 'Y'
     AND NVL(SHIPPABLE_FLAG,'Y') = 'Y'
     AND NOT EXISTS (
          SELECT NULL
           FROM MTL_SYSTEM_ITEMS MSI
           WHERE MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MSI.ORGANIZATION_ID = MMTT.TRANSFER_ORGANIZATION
             AND MSI.MTL_TRANSACTIONS_ENABLED_FLAG = 'Y');
  if SQL%FOUND then return 0; else return 1; end if;
END validateToOrgItem;

/* validates item's revision in to org context */
FUNCTION validateToOrgItemRevision RETURN NUMBER
IS
BEGIN
-- Bug 3951494
-- The validation should happen for the MMTT record not the MTI record.
-- Changing the below sql validation against MMTT.
  if validationLevel = TIMEBASED then return 1; end if;
  loadmsg('INV_INT_REVCODE','INV_INT_REVXFREXP');
/*  UPDATE MTL_TRANSACTIONS_INTERFACE MTI
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 3,
           LOCK_FLAG = 2,
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 1
       AND TRANSACTION_ACTION_ID = 3
       AND NOT EXISTS (
            SELECT NULL
             FROM MTL_ITEM_REVISIONS MIR,
                  MTL_SYSTEM_ITEMS MSI
            WHERE MSI.REVISION_QTY_CONTROL_CODE = 2
              AND MIR.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MTI.TRANSFER_ORGANIZATION
              AND MIR.REVISION = MTI.REVISION
              AND MSI.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
              AND MSI.ORGANIZATION_ID = MTI.TRANSFER_ORGANIZATION
              AND MIR.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MSI.ORGANIZATION_ID
            UNION
              SELECT NULL
                FROM MTL_SYSTEM_ITEMS ITM
               WHERE ITM.REVISION_QTY_CONTROL_CODE = 1
                 AND MTI.REVISION IS NULL
                 AND ITM.INVENTORY_ITEM_ID = MTI.INVENTORY_ITEM_ID
                 AND ITM.ORGANIZATION_ID = MTI.TRANSFER_ORGANIZATION); */

  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_ACTION_ID = 3
       AND NOT EXISTS (
            SELECT NULL
             FROM MTL_ITEM_REVISIONS MIR,
                  MTL_SYSTEM_ITEMS MSI
            WHERE MSI.REVISION_QTY_CONTROL_CODE = 2
              AND MIR.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MMTT.TRANSFER_ORGANIZATION
              AND MIR.REVISION = MMTT.REVISION
              AND MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
              AND MSI.ORGANIZATION_ID = MMTT.TRANSFER_ORGANIZATION
              AND MIR.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
              AND MIR.ORGANIZATION_ID = MSI.ORGANIZATION_ID
            UNION
              SELECT NULL
                FROM MTL_SYSTEM_ITEMS ITM
               WHERE ITM.REVISION_QTY_CONTROL_CODE = 1
              -- AND MTI.REVISION IS NULL not required as per bug 3285134
                 AND ITM.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
                 AND ITM.ORGANIZATION_ID = MMTT.TRANSFER_ORGANIZATION);
  if SQL%FOUND then return 0; else return 1; end if;
END validateToOrgItemRevision;

/* validates subinventory code */
FUNCTION validateFromSubinventory RETURN NUMBER
IS
  l_status      NUMBER;
BEGIN
    loadmsg('INV_INT_SUBCODE','INV_INT_SUBEXP');

     UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
            SET LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = userid,
            LAST_UPDATE_LOGIN = loginid,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROCESS_FLAG = 'E',
            TRANSACTION_STATUS = 1,
            LOCK_FLAG = 'N',
            ERROR_CODE = substr(err_code,1,240),
            ERROR_EXPLANATION = substr(error_exp,1,240)
      WHERE TRANSACTION_HEADER_ID = header_id
        AND PROCESS_FLAG = 'Y'
        AND TRANSACTION_STATUS = 3
        AND TRANSACTION_ACTION_ID NOT IN (24, 30) /* CFM Scrap Transactions */
        AND (NVL(SHIPPABLE_FLAG,'Y') = 'Y'
             AND NOT EXISTS (
             SELECT NULL
               FROM MTL_SECONDARY_INVENTORIES MSI
              WHERE MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
                AND MSI.SECONDARY_INVENTORY_NAME = MMTT.SUBINVENTORY_CODE
                AND NVL(DISABLE_DATE,SYSDATE+1) >= SYSDATE)
             OR (SHIPPABLE_FLAG = 'N'
                 AND SUBINVENTORY_CODE IS NOT NULL
                 AND NOT EXISTS (
                 SELECT NULL
                 FROM MTL_SECONDARY_INVENTORIES MSI
                 WHERE MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
                 AND MSI.SECONDARY_INVENTORY_NAME = MMTT.SUBINVENTORY_CODE)));
                  -- should we use disable state here?

  if(SQL%FOUND) then l_status := 0; else l_status := 1; end if;

  if validationLevel = TIMEBASED then return l_status; end if;

  loadmsg('INV_INT_SUBCODE','INV_INT_RESUBEXP');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND SUBINVENTORY_CODE IS NOT NULL
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_ITEM_SUB_INVENTORIES MIS,
                MTL_SYSTEM_ITEMS MSI
           WHERE MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
             AND MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MSI.RESTRICT_SUBINVENTORIES_CODE = 1
             AND MIS.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
             AND MIS.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MIS.ORGANIZATION_ID = MSI.ORGANIZATION_ID
             AND MIS.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
             AND MIS.SECONDARY_INVENTORY = MMTT.SUBINVENTORY_CODE
           UNION
             SELECT NULL
               FROM MTL_SYSTEM_ITEMS ITM
              WHERE ITM.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
                AND ITM.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
                AND ITM.RESTRICT_SUBINVENTORIES_CODE = 2);
   if SQL%FOUND then l_status := 0; end if;
   return l_status;
END validateFromSubinventory;

/* validates from locator */
FUNCTION validateFromLocator RETURN NUMBER
IS
  l_status      NUMBER;
BEGIN
  loadmsg('INV_INT_LOCCODE','INV_INT_LOCEXP');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND LOCATOR_ID IS NOT NULL
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_ITEM_LOCATIONS MIL
           WHERE MIL.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
             AND MIL.SUBINVENTORY_CODE = MMTT.SUBINVENTORY_CODE
             AND MIL.INVENTORY_LOCATION_ID = MMTT.LOCATOR_ID
             AND NVL(DISABLE_DATE,SYSDATE+1) >= SYSDATE);
  if SQL%FOUND then l_status := 0; else l_status := 1; end if;
  if validationLevel = TIMEBASED then return l_status; end if;

  loadmsg('INV_INT_LOCCODE','INV_INT_RESLOCEXP');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND LOCATOR_ID IS NOT NULL
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_SECONDARY_LOCATORS MSL,
                MTL_SYSTEM_ITEMS MSI
           WHERE MSI.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
             AND MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MSI.RESTRICT_LOCATORS_CODE = 1
             AND MSL.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
             AND MSL.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MSL.ORGANIZATION_ID = MSI.ORGANIZATION_ID
             AND MSL.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
             AND MSL.SUBINVENTORY_CODE = MMTT.SUBINVENTORY_CODE
             AND MSL.SECONDARY_LOCATOR = MMTT.LOCATOR_ID
           UNION
           SELECT NULL
             FROM MTL_SYSTEM_ITEMS ITM
            WHERE ITM.RESTRICT_LOCATORS_CODE = 2
              AND ITM.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
              AND ITM.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID);
   if SQL%FOUND then l_status := 0; end if;
   return l_status;
END validateFromLocator;

/* validates to subinventory */
FUNCTION validateToSubinventory RETURN NUMBER
IS
  l_status      NUMBER;
BEGIN
  loadmsg('INV_INT_XSUBCODE','INV_INT_XSUBEXP');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           TRANSACTION_STATUS = 1,
           LOCK_FLAG = 'N',
           ERROR_CODE = substr(err_code,1,240),
           ERROR_EXPLANATION = substr(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND (TRANSACTION_ACTION_ID IN (2,3,21)
                AND TRANSFER_SUBINVENTORY IS NOT NULL)
       AND ((NVL(SHIPPABLE_FLAG,'Y') = 'Y'
           AND NOT EXISTS (
           SELECT NULL
             FROM MTL_SECONDARY_INVENTORIES MSI
            WHERE MSI.ORGANIZATION_ID =
                         DECODE(MMTT.TRANSACTION_ACTION_ID,2,
                         MMTT.ORGANIZATION_ID,MMTT.TRANSFER_ORGANIZATION)
              AND MSI.SECONDARY_INVENTORY_NAME = MMTT.TRANSFER_SUBINVENTORY
              AND NVL(MSI.DISABLE_DATE,SYSDATE+1) > SYSDATE)))
           OR (SHIPPABLE_FLAG = 'N'
              AND TRANSFER_SUBINVENTORY IS NOT NULL
              AND NOT EXISTS (
              SELECT NULL
              FROM MTL_SECONDARY_INVENTORIES MSI
              WHERE MSI.ORGANIZATION_ID =
                        DECODE(MMTT.TRANSACTION_ACTION_ID,3,
                        MMTT.TRANSFER_ORGANIZATION,21,
                        MMTT.TRANSFER_ORGANIZATION,MMTT.ORGANIZATION_ID)
              AND MSI.SECONDARY_INVENTORY_NAME =
                              MMTT.TRANSFER_SUBINVENTORY));
  if(SQL%FOUND) then l_status := 0; else l_status := 1; end if;

  if validationLevel = TIMEBASED then return l_status; end if;

  loadmsg('INV_INT_XSUBCODE','INV_INT_RESXFRSUBEXP');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND TRANSFER_SUBINVENTORY IS NOT NULL
       AND TRANSACTION_ACTION_ID in (2,21,3)
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_ITEM_SUB_INVENTORIES MIS,
                MTL_SYSTEM_ITEMS MSI
           WHERE MSI.ORGANIZATION_ID = decode(MMTT.TRANSACTION_ACTION_ID, 2,
                 MMTT.ORGANIZATION_ID, MMTT.TRANSFER_ORGANIZATION)
             AND MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MSI.RESTRICT_SUBINVENTORIES_CODE = 1
             AND MIS.ORGANIZATION_ID = decode(MMTT.TRANSACTION_ACTION_ID, 2,
                 MMTT.ORGANIZATION_ID, MMTT.TRANSFER_ORGANIZATION)
             AND MIS.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MIS.ORGANIZATION_ID = MSI.ORGANIZATION_ID
             AND MIS.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
             AND MIS.SECONDARY_INVENTORY = MMTT.TRANSFER_SUBINVENTORY
           UNION
           SELECT NULL
             FROM MTL_SYSTEM_ITEMS ITM
           WHERE ITM.ORGANIZATION_ID = decode(MMTT.TRANSACTION_ACTION_ID, 2,
                 MMTT.ORGANIZATION_ID, MMTT.TRANSFER_ORGANIZATION)
             AND ITM.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND ITM.RESTRICT_SUBINVENTORIES_CODE = 2);
   if SQL%FOUND then l_status := 0; end if;
   return l_status;
END validateToSubinventory;

/* validates to locator */
FUNCTION validateToLocator RETURN NUMBER
IS
  l_status         NUMBER;
BEGIN
  loadmsg('INV_INT_XLOCCODE','INV_INT_XFRLOCEXP');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND TRANSACTION_ACTION_ID IN (2,3)
       AND TRANSFER_TO_LOCATION IS NOT NULL
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_ITEM_LOCATIONS MIL
           WHERE MIL.ORGANIZATION_ID = decode(MMTT.TRANSACTION_ACTION_ID,3,
                 MMTT.TRANSFER_ORGANIZATION,MMTT.ORGANIZATION_ID)
             AND MIL.SUBINVENTORY_CODE = MMTT.TRANSFER_SUBINVENTORY
             AND MIL.INVENTORY_LOCATION_ID = MMTT.TRANSFER_TO_LOCATION);
  if(SQL%FOUND) then l_status := 0; else l_status := 1; end if;

  if validationLevel = TIMEBASED then return l_status; end if;

  loadmsg('INV_INT_XLOCCODE','INV_INT_RESXFRLOCEXP');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND TRANSACTION_ACTION_ID in (2,21,3)
       AND TRANSFER_TO_LOCATION IS NOT NULL
       AND NOT EXISTS (
           SELECT NULL
           FROM MTL_SECONDARY_LOCATORS MSL,
                MTL_SYSTEM_ITEMS MSI
           WHERE MSI.ORGANIZATION_ID = decode(MMTT.TRANSACTION_ACTION_ID, 2,
                 MMTT.ORGANIZATION_ID, MMTT.TRANSFER_ORGANIZATION)
             AND MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MSI.RESTRICT_LOCATORS_CODE = 1
             AND MSL.ORGANIZATION_ID = decode(MMTT.TRANSACTION_ACTION_ID, 2,
                 MMTT.ORGANIZATION_ID, MMTT.TRANSFER_ORGANIZATION)
             AND MSL.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MSL.ORGANIZATION_ID = MSI.ORGANIZATION_ID
             AND MSL.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
             AND MSL.SUBINVENTORY_CODE = MMTT.TRANSFER_SUBINVENTORY
             AND MSL.SECONDARY_LOCATOR = MMTT.TRANSFER_TO_LOCATION
           UNION
           SELECT NULL
           FROM MTL_SYSTEM_ITEMS MSI
           WHERE MSI.ORGANIZATION_ID = decode(MMTT.TRANSACTION_ACTION_ID, 2,
                 MMTT.ORGANIZATION_ID, MMTT.TRANSFER_ORGANIZATION)
             AND MSI.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MSI.RESTRICT_LOCATORS_CODE = 2);
  if SQL%FOUND then l_status := 0; end if;
  return l_status;
END validateToLocator;

/* validates source project */
FUNCTION validateSourceProject RETURN NUMBER
IS
BEGIN
  loadmsg('INV_PRJ_ERR','INV_PRJ_ERR');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
            SET LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = userid,
            LAST_UPDATE_LOGIN = loginid,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROCESS_FLAG = 'E',
            TRANSACTION_STATUS = 1,
            LOCK_FLAG = 'N',
            ERROR_CODE = substr(err_code,1,240),
            ERROR_EXPLANATION = substr(error_exp,1,240)
        WHERE TRANSACTION_HEADER_ID = header_id
        AND ((TRANSACTION_SOURCE_TYPE_ID IN (3, 6, 13 )) OR
             (TRANSACTION_SOURCE_TYPE_ID > 100 ) )
        AND TRANSACTION_ACTION_ID IN (1, 27 )
        AND PROCESS_FLAG = 'Y'
        AND TRANSACTION_STATUS = 3
        AND EXISTS (
            SELECT NULL
            FROM MTL_TRANSACTION_TYPES MTTY
            WHERE MTTY.TRANSACTION_TYPE_ID = MMTT.TRANSACTION_TYPE_ID
            AND MTTY.TYPE_CLASS = 1 )
        AND NOT EXISTS (
           SELECT NULL
             FROM pa_projects_expend_v prj1
            WHERE prj1.project_id = mmtt.source_project_id ) ;
  if(SQL%FOUND) then return 0; else return 1; end if;
END validateSourceProject;

/* validates source task */
FUNCTION validateSourceTask RETURN NUMBER
IS
BEGIN
  loadmsg('INV_TASK_ERR','INV_TASK_ERR');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
            SET LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = userid,
            LAST_UPDATE_LOGIN = loginid,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROCESS_FLAG = 'E',
            TRANSACTION_STATUS = 1,
            LOCK_FLAG = 'N',
            ERROR_CODE = substr(err_code,1,240),
            ERROR_EXPLANATION = substr(error_exp,1,240)
   WHERE TRANSACTION_HEADER_ID = header_id
     AND ((TRANSACTION_SOURCE_TYPE_ID IN (3, 6, 13 )) OR
             (TRANSACTION_SOURCE_TYPE_ID > 100 ) )
     AND TRANSACTION_ACTION_ID IN (1, 27 )
     AND PROCESS_FLAG = 'Y'
     AND TRANSACTION_STATUS = 3
     AND EXISTS (
            SELECT NULL
            FROM MTL_TRANSACTION_TYPES MTTY
            WHERE MTTY.TRANSACTION_TYPE_ID = MMTT.TRANSACTION_TYPE_ID
            AND MTTY.TYPE_CLASS = 1 )
     AND NOT EXISTS (
            SELECT NULL
            FROM PA_TASKS_LOWEST_V TSK
            WHERE TSK.PROJECT_ID = MMTT.SOURCE_PROJECT_ID AND
            TSK.TASK_ID = MMTT.SOURCE_TASK_ID );
  if(SQL%FOUND) then return 0; else return 1; end if;
END validateSourceTask;


/* validates cost group ids */
FUNCTION validateCostGroups RETURN NUMBER
IS
BEGIN
    loadmsg('INV_COST_GROUP_ERROR', 'INV_COST_GROUP_ERROR');
    UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
            SET LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = userid,
            LAST_UPDATE_LOGIN = loginid,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROCESS_FLAG = 'E',
            TRANSACTION_STATUS = 1,
            LOCK_FLAG = 'N',
            ERROR_CODE = substr(err_code,1,240),
            ERROR_EXPLANATION = substr(error_exp,1,240)
    WHERE TRANSACTION_HEADER_ID = header_id
      AND PROCESS_FLAG = 'Y'
      AND TRANSACTION_STATUS = 3
      AND TRANSACTION_ACTION_ID = 24
      AND TRANSACTION_SOURCE_TYPE_ID = 13
      AND COST_GROUP_ID IS NOT NULL
      AND NOT EXISTS (
            SELECT NULL
              FROM CST_COST_GROUPS CCG
             WHERE CCG.COST_GROUP_ID = MMTT.COST_GROUP_ID
               AND NVL(CCG.ORGANIZATION_ID, MMTT.ORGANIZATION_ID) = MMTT.ORGANIZATION_ID
               AND TRUNC(NVL(CCG.DISABLE_DATE,SYSDATE+1)) >= TRUNC(SYSDATE) ) ;
  if(SQL%FOUND) then return 0; else return 1; end if;
END validateCostGroups;

/* validates expenditure type */
FUNCTION validateExpenditureType RETURN NUMBER
IS
  exp_type_required   NUMBER;
BEGIN
    exp_type_required := to_number(nvl(fnd_profile.value('INV_PROJ_MISC_TXN_EXP_TYPE'),1));

    loadmsg('INV_ETYPE_ERR','INV_ETYPE_ERR');
    if ( exp_type_required = 2 ) then

      UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
         SET LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY = userid,
             LAST_UPDATE_LOGIN = loginid,
             PROGRAM_UPDATE_DATE = SYSDATE,
             PROCESS_FLAG = 'E',
             TRANSACTION_STATUS = 1,
             LOCK_FLAG = 'N',
             ERROR_CODE = substrb(err_code,1,240),
             ERROR_EXPLANATION = substrb(error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = header_id
         AND ((TRANSACTION_SOURCE_TYPE_ID IN (3, 6, 13 )) OR
              (TRANSACTION_SOURCE_TYPE_ID > 100 ) )
         AND TRANSACTION_ACTION_ID IN (1, 27 )
         AND PROCESS_FLAG = 'Y'
         AND TRANSACTION_STATUS = 3
         AND EXISTS (
              SELECT NULL
                FROM MTL_TRANSACTION_TYPES MTTY
               WHERE MTTY.TRANSACTION_TYPE_ID = MMTT.TRANSACTION_TYPE_ID
                 AND MTTY.TYPE_CLASS = 1 )
         AND NOT EXISTS (
              SELECT NULL
                FROM CST_PROJ_EXP_TYPES_VAL_V CET
               WHERE CET.EXPENDITURE_TYPE = MMTT.EXPENDITURE_TYPE
                 AND CET.COST_ELEMENT_ID = 1
                 AND TRUNC(MMTT.TRANSACTION_DATE) >= CET.SYS_LINK_START_DATE
                 AND TRUNC(MMTT.TRANSACTION_DATE) <= NVL(SYS_LINK_END_DATE,
                                                    MMTT.TRANSACTION_DATE + 1)
                 AND TRUNC(MMTT.TRANSACTION_DATE) >= CET.EXP_TYPE_START_DATE
                 AND TRUNC(MMTT.TRANSACTION_DATE) >= NVL(EXP_TYPE_END_DATE,
                                                    MMTT.TRANSACTION_DATE+1)) ;
    else
      UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
         SET LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY = userid,
             LAST_UPDATE_LOGIN = loginid,
             PROGRAM_UPDATE_DATE = SYSDATE,
             PROCESS_FLAG = 'E',
             TRANSACTION_STATUS = 1,
             LOCK_FLAG = 'N',
             ERROR_CODE = substrb(err_code,1,240),
             ERROR_EXPLANATION = substrb(error_exp,1,240)
       WHERE TRANSACTION_HEADER_ID = header_id
         AND ((TRANSACTION_SOURCE_TYPE_ID IN (3, 6, 13 )) OR
              (TRANSACTION_SOURCE_TYPE_ID > 100 ) )
         AND TRANSACTION_ACTION_ID IN (1, 27 )
         AND PROCESS_FLAG = 'Y'
         AND TRANSACTION_STATUS = 3
         AND EXISTS (
              SELECT NULL
                FROM MTL_TRANSACTION_TYPES MTTY
               WHERE MTTY.TRANSACTION_TYPE_ID = MMTT.TRANSACTION_TYPE_ID
                 AND MTTY.TYPE_CLASS = 1 )
         AND MMTT.EXPENDITURE_TYPE IS NOT NULL ;
    end if;
  if(SQL%FOUND) then return 0; else return 1; end if;
END validateExpenditureType;

/* validates expenditure org */
FUNCTION validateExpenditureOrg RETURN NUMBER
IS
BEGIN
   loadmsg('INV_PAORG_ERR','INV_PAORG_ERR');

     UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
        SET LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = userid,
            LAST_UPDATE_LOGIN = loginid,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROCESS_FLAG = 'E',
            TRANSACTION_STATUS = 1,
            LOCK_FLAG = 'N',
            ERROR_CODE = substrb(err_code,1,240),
            ERROR_EXPLANATION = substrb(error_exp,1,240)
      WHERE TRANSACTION_HEADER_ID = header_id
        AND ((TRANSACTION_SOURCE_TYPE_ID IN (3, 6, 13 )) OR
             (TRANSACTION_SOURCE_TYPE_ID > 100 ) )
        AND TRANSACTION_ACTION_ID IN (1, 27 )
        AND PROCESS_FLAG = 'Y'
        AND TRANSACTION_STATUS = 3
        AND EXISTS (
            SELECT NULL
            FROM MTL_TRANSACTION_TYPES MTTY
            WHERE MTTY.TRANSACTION_TYPE_ID = MMTT.TRANSACTION_TYPE_ID
            AND MTTY.TYPE_CLASS = 1 )
        AND NOT EXISTS (
             SELECT NULL
               FROM PA_ORGANIZATIONS_EXPEND_V POE
              WHERE POE.ORGANIZATION_ID = MMTT.PA_EXPENDITURE_ORG_ID
                AND TRUNC(SYSDATE) BETWEEN POE.DATE_FROM
                AND NVL(POE.DATE_TO, TRUNC(SYSDATE)));
       /* should we check if txn date is betwe en org active date range ? */
  if(SQL%FOUND) then return 0; else return 1; end if;

END validateExpenditureOrg;

/* validates transaction UOM */
FUNCTION validateTxnUOM RETURN NUMBER
IS
BEGIN
    loadmsg('INV_INT_UOMCODE','INV_INT_UOMEXP');

    UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           TRANSACTION_STATUS = 1,
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND INVENTORY_ITEM_ID IS NOT NULL
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND NOT EXISTS (
           SELECT NULL
             FROM MTL_ITEM_UOMS_VIEW MIUV
            WHERE MIUV.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
              AND MIUV.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
              AND MIUV.UOM_CODE = MMTT.TRANSACTION_UOM);
  if(SQL%FOUND) then return 0; else return 1; end if;
END validateTxnUOM;

/* validates lot,serial and revision controlled items for interorg transactions */
FUNCTION validateInterOrgItemControls RETURN NUMBER
IS
BEGIN
  loadmsg('INV_INT_ITMCTRL','INV_INT_ITMECTRL');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND TRANSACTION_ACTION_ID = 3
       AND EXISTS (
           SELECT NULL
           FROM MTL_SYSTEM_ITEMS MS1,
                MTL_SYSTEM_ITEMS MS2
           WHERE MS1.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MS1.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
             AND MS2.INVENTORY_ITEM_ID = MMTT.INVENTORY_ITEM_ID
             AND MS2.ORGANIZATION_ID = MMTT.TRANSFER_ORGANIZATION
             AND ((MS1.LOT_CONTROL_CODE = 1 AND
                   MS2.LOT_CONTROL_CODE = 2)
                 OR (MS1.SERIAL_NUMBER_CONTROL_CODE IN (1,6)
                 AND MS2.SERIAL_NUMBER_CONTROL_CODE IN (2,3,5))
                 OR (MS1.REVISION_QTY_CONTROL_CODE = 1 AND
                     MS2.REVISION_QTY_CONTROL_CODE = 2)));
  if(SQL%FOUND) then return 0; else return 1; end if;
END validateInterOrgItemControls;

/* validates transaction sources */
FUNCTION validateTransactionSource RETURN NUMBER
IS
  l_status      NUMBER;
BEGIN
  loadmsg('INV_INT_SRCCODE','INV_INT_SALEXP');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND TRANSACTION_SOURCE_TYPE_ID in (2,8)
       AND NOT EXISTS (
           SELECT NULL
             FROM MTL_SALES_ORDERS MSO
            WHERE MSO.SALES_ORDER_ID = MMTT.TRANSACTION_SOURCE_ID
              AND NVL(START_DATE_ACTIVE, SYSDATE - 1) <= SYSDATE
              AND NVL(END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE
              AND ENABLED_FLAG = 'Y');
  if(SQL%FOUND) then l_status := 0; else l_status := 1; end if;

  --bugfix 4750835 added trunc on the effectivity date validation. we are to take the account effectivity date
  --which does not have timestamp as date with timestamp 23:59:59

  loadmsg('INV_INT_SRCCODE','INV_INT_ACCTEXP');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND TRANSACTION_SOURCE_TYPE_ID = 3
       AND NOT EXISTS (
           SELECT NULL
             FROM GL_CODE_COMBINATIONS GCC,
                  ORG_ORGANIZATION_DEFINITIONS OOD
            WHERE GCC.CODE_COMBINATION_ID = MMTT.TRANSACTION_SOURCE_ID
              AND GCC.CHART_OF_ACCOUNTS_ID = OOD.CHART_OF_ACCOUNTS_ID
              AND OOD.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
              AND GCC.ENABLED_FLAG = 'Y'
              AND trunc(NVL(GCC.START_DATE_ACTIVE, SYSDATE - 1)) <= trunc(SYSDATE)
              AND trunc(NVL(GCC.END_DATE_ACTIVE, SYSDATE + 1)) > trunc(SYSDATE));

   if(SQL%FOUND) then l_status := 0; end if;

   loadmsg('INV_INT_SRCCODE','INV_INT_ALIASEXP');
   UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
      SET LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = userid,
          LAST_UPDATE_LOGIN = loginid,
          PROGRAM_UPDATE_DATE = SYSDATE,
          PROCESS_FLAG = 'E',
          LOCK_FLAG = 'N',
          ERROR_CODE = substrb(err_code,1,240),
          ERROR_EXPLANATION = substrb(error_exp,1,240)
    WHERE TRANSACTION_HEADER_ID = header_id
      AND PROCESS_FLAG = 'Y'
      AND TRANSACTION_STATUS = 3
      AND TRANSACTION_SOURCE_TYPE_ID = 6
      AND NOT EXISTS (
           SELECT NULL
             FROM MTL_GENERIC_DISPOSITIONS MGD
            WHERE MGD.DISPOSITION_ID = MMTT.TRANSACTION_SOURCE_ID
              AND MGD.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
              AND MGD.ENABLED_FLAG = 'Y'
              AND NVL(MGD.START_DATE_ACTIVE, SYSDATE - 1) <= SYSDATE
              AND NVL(MGD.END_DATE_ACTIVE, SYSDATE + 1) > SYSDATE );
   if(SQL%FOUND) then l_status := 0; end if;
   return l_status;
END validateTransactionSource;

/* validates transaction reason */
FUNCTION validateTransactionReason RETURN NUMBER
IS
BEGIN
  loadmsg('INV_INT_REACODE','INV_INT_REAEXP');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND REASON_ID IS NOT NULL
       AND NOT EXISTS (
           SELECT NULL
             FROM MTL_TRANSACTION_REASONS MTR
            WHERE MTR.REASON_ID = MMTT.REASON_ID
              AND NVL(MTR.DISABLE_DATE, SYSDATE + 1) > SYSDATE);
  if SQL%FOUND then return 0; else return 1; end if;
END validateTransactionReason;

/* validates freight and freight account */
FUNCTION validateFreightInfo RETURN NUMBER
IS
  l_status      NUMBER;
BEGIN
  loadmsg('INV_INT_FRTCODE','INV_INT_FRTEXP');
  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND TRANSACTION_ACTION_ID in (3,21)
       AND FREIGHT_CODE IS NOT NULL
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND NOT EXISTS (
           SELECT NULL
           FROM ORG_FREIGHT FR
           WHERE FR.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
             AND FR.FREIGHT_CODE    = MMTT.FREIGHT_CODE
             AND NVL(FR.DISABLE_DATE, SYSDATE + 1) > SYSDATE);
  if SQL%FOUND then l_status := 0; else l_status := 1; end if;

  loadmsg('INV_INT_FRTACTCODE','INV_INT_FRTACTEXP');
    UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
       SET LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = userid,
           LAST_UPDATE_LOGIN = loginid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROCESS_FLAG = 'E',
           LOCK_FLAG = 'N',
           ERROR_CODE = substrb(err_code,1,240),
           ERROR_EXPLANATION = substrb(error_exp,1,240)
     WHERE TRANSACTION_HEADER_ID = header_id
       AND TRANSACTION_ACTION_ID in (3,21)
       AND TRANSPORTATION_ACCOUNT IS NOT NULL
       AND PROCESS_FLAG = 'Y'
       AND TRANSACTION_STATUS = 3
       AND NOT EXISTS (
           SELECT NULL
           FROM ORG_FREIGHT FR
           WHERE FR.ORGANIZATION_ID = MMTT.ORGANIZATION_ID
             AND FR.FREIGHT_CODE    = MMTT.FREIGHT_CODE
             AND FR.DISTRIBUTION_ACCOUNT = MMTT.TRANSPORTATION_ACCOUNT
             AND NVL(FR.DISABLE_DATE, SYSDATE + 1) > SYSDATE);
  if SQL%FOUND then l_status := 0; end if;
  return l_status;
END validateFreightInfo;

/* validates lot details */
FUNCTION validateLOT(txnrec      IN TXNREC,
                     org         IN INV_Validate.ORG,
                     item        IN INV_Validate.ITEM) RETURN NUMBER
IS
   CURSOR  LOT_DETAILS(txnTempID
             MTL_MATERIAL_TRANSACTIONS_TEMP.TRANSACTION_TEMP_ID%TYPE) IS
               SELECT LOT_NUMBER,
                      TRANSACTION_QUANTITY,
                      SERIAL_TRANSACTION_TEMP_ID,
                      fnd_date.date_to_canonical(LOT_EXPIRATION_DATE) LOT_EXPIRATION_DATE,
                      ROWID
                 FROM MTL_TRANSACTION_LOTS_TEMP
                WHERE TRANSACTION_TEMP_ID = txnTempID;

   l_dummy  NUMBER;
BEGIN
  if(not (item.lot_control_code = 2 AND txnrec.transaction_action_id = 24))
  then
    if(txnrec.transaction_temp_id <> NULL) then
      DELETE FROM MTL_TRANSACTION_LOTS_TEMP
       WHERE TRANSACTION_temp_id = txnrec.transaction_temp_id;
    end if;
    if((item.serial_number_control_code in (2,5) OR
        (item.serial_number_control_code = 6 AND
         txnrec.transaction_source_type_id = 2 AND
         txnrec.transaction_action_id = 1)) AND
       txnrec.transaction_action_id <> 24) then
       if txnrec.transaction_temp_id IS NULL then
         loadmsg('INV_INT_SERMISCODE','INV_INT_SERMISEXP');
         errupdate(txnrec.rowid);
         return 0;
       else
         BEGIN
           SELECT 1
             INTO l_dummy
             FROM MTL_SERIAL_NUMBERS_TEMP
            WHERE TRANSACTION_TEMP_ID = txnrec.transaction_temp_id
              AND rownum < 2;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
            loadmsg('INV_INT_SERMISCODE','INV_INT_SERMISEXP');
            errupdate(txnrec.rowid);
         END;
       end if;
    else
      if txnrec.transaction_temp_id IS NOT NULL then
        DELETE FROM MTL_SERIAL_NUMBERS_TEMP
         WHERE TRANSACTION_TEMP_ID = txnrec.transaction_temp_id;
      end if;
    end if;
  else
    loadmsg('INV_INT_LOTCODE','INV_INT_LOTEXP');
    if txnrec.transaction_temp_id IS NULL then
      errupdate(txnrec.rowid);
      return 0;
    else

  UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
     SET LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATED_BY = userid,
         LAST_UPDATE_LOGIN = loginid,
         PROGRAM_UPDATE_DATE = SYSDATE,
         PROCESS_FLAG = 'E',
         TRANSACTION_STATUS = 1,
         LOCK_FLAG = 'N',
         ERROR_CODE = substrb(err_code,1,240),
         ERROR_EXPLANATION = substrb(error_exp,1,240)
   WHERE ROWID = txnrec.rowid
     AND ABS(TRANSACTION_QUANTITY) <>
             (SELECT ABS(SUM(TRANSACTION_QUANTITY))
                FROM MTL_TRANSACTION_LOTS_TEMP MTLT
               WHERE MTLT.TRANSACTION_TEMP_ID = txnrec.transaction_temp_id);

   if(SQL%FOUND) then return 0; else return 1; end if;

   if org.lot_number_uniqueness = 1 then
      loadmsg('INV_INT_LOTUNIQCODE','INV_INT_LOTUNIQEXP');
      UPDATE MTL_TRANSACTION_LOTS_TEMP MTLT
         SET LAST_UPDATE_DATE = SYSDATE,
             LAST_UPDATED_BY = userid,
             LAST_UPDATE_LOGIN = loginid,
             PROGRAM_APPLICATION_ID = applid,
             PROGRAM_ID = progid,
             PROGRAM_UPDATE_DATE = SYSDATE,
             REQUEST_ID = reqstid,
             ERROR_CODE = substrb(err_code,1,240)
       WHERE TRANSACTION_TEMP_ID = txnrec.transaction_temp_id
         AND EXISTS (
              SELECT NULL
              FROM MTL_LOT_NUMBERS MLN
              WHERE MLN.LOT_NUMBER = MTLT.LOT_NUMBER
              AND MLN.INVENTORY_ITEM_ID <> item.inventory_item_id);

      if(SQL%ROWCOUNT > 1) then
        UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP MTT
           SET LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = userid,
               LAST_UPDATE_LOGIN = loginid,
               PROGRAM_UPDATE_DATE = SYSDATE,
               PROCESS_FLAG = 'E',
               TRANSACTION_STATUS = 1,
               LOCK_FLAG = 'N',
               ERROR_CODE = substrb(err_code,1,240),
               ERROR_EXPLANATION = substrb(error_exp,1,240)
         WHERE ROWID = txnrec.rowid;
         return 0;
      end if;
   end if;
   FOR lotrec IN LOT_DETAILS(txnrec.transaction_temp_id)
   LOOP
     -- uom conversion
     if (item.shelf_life_code <> 1 AND
         lotrec.lot_expiration_date IS NULL)
     then
        SELECT fnd_date.date_to_canonical(EXPIRATION_DATE)
          INTO lotrec.lot_expiration_date
          FROM MTL_LOT_NUMBERS
         WHERE INVENTORY_ITEM_ID = item.inventory_item_id
           AND ORGANIZATION_ID = org.organization_id
           AND LOT_NUMBER = lotrec.lot_number;
        if(item.shelf_life_code = 2 AND
          lotrec.lot_expiration_date IS NULL) then
          lotrec.lot_expiration_date :=
            fnd_date.date_to_canonical(SYSDATE+item.shelf_life_days);
        end if;
        if(item.shelf_life_code = 4 AND
          lotrec.lot_expiration_date IS NULL) then
          loadmsg('INV_LOT_EXPREQD','INV_LOT_EXPREQD');
          UPDATE MTL_TRANSACTION_LOTS_TEMP MTLT
             SET LAST_UPDATE_DATE = SYSDATE,
                 LAST_UPDATED_BY = userid,
                 LAST_UPDATE_LOGIN = loginid,
                 PROGRAM_APPLICATION_ID = applid,
                 PROGRAM_ID = progid,
                 PROGRAM_UPDATE_DATE = SYSDATE,
                 REQUEST_ID = reqstid,
                 ERROR_CODE = substrb(err_code,1,240)
           WHERE ROWID = lotrec.rowid;
           UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
              SET ERROR_CODE = substrb(err_code,1,240),
                  ERROR_EXPLANATION = substrb(error_exp,1,240),
                  LAST_UPDATE_DATE = sysdate,
                  LAST_UPDATED_BY = userid,
                  LAST_UPDATE_LOGIN = loginid,
                  PROGRAM_UPDATE_DATE = SYSDATE,
                  PROCESS_FLAG = 'E',
                  TRANSACTION_STATUS = 1,
                  LOCK_FLAG = 'N'
            WHERE ROWID = txnrec.rowid;
           return 0;
        end if;
     end if;

     if(item.serial_number_control_code in (2,5,6) and
        txnrec.transaction_source_type_id = 2 and
        txnrec.transaction_action_id = 1) then
        BEGIN
          SELECT 1
            INTO l_dummy
            FROM MTL_SERIAL_NUMBERS_TEMP
           WHERE TRANSACTION_TEMP_ID = txnrec.transaction_temp_id
             AND rownum < 2;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
             loadmsg('INV_INT_SERMISCODE','INV_INT_SERMISEXP');
             UPDATE MTL_TRANSACTION_LOTS_TEMP MTLT
                SET LAST_UPDATE_DATE = SYSDATE,
                    LAST_UPDATED_BY = userid,
                    LAST_UPDATE_LOGIN = loginid,
                    PROGRAM_APPLICATION_ID = applid,
                    PROGRAM_ID = progid,
                    PROGRAM_UPDATE_DATE = SYSDATE,
                    REQUEST_ID = reqstid,
                    ERROR_CODE = substrb(err_code,1,240)
              WHERE ROWID = lotrec.rowid;

             UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
                SET LAST_UPDATE_DATE = SYSDATE,
                    LAST_UPDATED_BY = userid,
                    LAST_UPDATE_LOGIN = loginid,
                    PROGRAM_UPDATE_DATE = SYSDATE,
                    PROCESS_FLAG = 'E',
                    TRANSACTION_STATUS = 1,
                    LOCK_FLAG = 'N',
                    ERROR_CODE = substrb(err_code,1,240),
                    ERROR_EXPLANATION = substrb(error_exp,1,240)
              WHERE ROWID = txnrec.rowid;
             return 0;
        END;
     else
        if(lotrec.SERIAL_TRANSACTION_TEMP_ID IS NOT NULL) then
           DELETE FROM MTL_SERIAL_NUMBERS_TEMP
            WHERE TRANSACTION_TEMP_ID = lotrec.SERIAL_TRANSACTION_TEMP_ID;
           lotrec.SERIAL_TRANSACTION_TEMP_ID := NULL;
        end if;
     end if;
     UPDATE MTL_TRANSACTION_LOTS_INTERFACE MTLI
        SET LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = userid,
            LAST_UPDATE_LOGIN = loginid,
            PROGRAM_APPLICATION_ID = applid,
            PROGRAM_ID = progid,
            PROGRAM_UPDATE_DATE = SYSDATE,
            REQUEST_ID = reqstid,
         -- PRIMARY_QUANTITY = l_priqty,
            LOT_EXPIRATION_DATE =
                fnd_date.canonical_to_date(lotrec.lot_expiration_date),
            SERIAL_TRANSACTION_TEMP_ID = lotrec.SERIAL_TRANSACTION_TEMP_ID
      WHERE ROWID = lotrec.rowid;
   END LOOP;
   end if;
  end if;
   return 1;
EXCEPTION
   WHEN OTHERS THEN
     return 0;
END validateLOT;

/* validates unit number */
FUNCTION validateUnitNumber(txnrec IN TXNREC) RETURN NUMBER
IS
  l_dummy  NUMBER;
BEGIN
  IF(NVL(PJM_UNIT_EFF.ENABLED,'N') = 'Y') THEN
    IF(PJM_UNIT_EFF.UNIT_EFFECTIVE_ITEM(txnrec.inventory_item_id,
                                        txnrec.organization_id) = 'Y') then
      IF(txnrec.transaction_source_type_id = 3 AND
         txnrec.transaction_action_id IN (3,21) AND
         txnrec.end_item_unit_number IS NOT NULL) THEN
         BEGIN
           SELECT 1
             INTO l_dummy
             FROM PJM_UNIT_NUMBERS_LOV_V
            WHERE UNIT_NUMBER = txnrec.end_item_unit_number;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             loadmsg('INV_INT_UNITNUMBER','INV_INT_UNITNUMBER');
             return 0;
         END;
      END IF;
    END IF;
  END IF;
  return 1;
EXCEPTION
  WHEN OTHERS THEN
    return 0;
END validateUnitNumber;

FUNCTION getAccountPeriodId(orgID IN NUMBER,txndate IN DATE) RETURN NUMBER
IS
  l_period_id NUMBER;
  l_open_past_period BOOLEAN := FALSE;
BEGIN
  INVTTMTX.tdatechk(orgId,txndate,l_period_id,l_open_past_period);
  return l_period_id;

END getAccountPeriodId;

PROCEDURE loadmsg(errorCode IN VARCHAR2,errorExplanation IN VARCHAR2)
IS
BEGIN
   FND_MESSAGE.SET_NAME('INV',errorCode);
   err_code := FND_MESSAGE.GET;
   FND_MESSAGE.CLEAR;
   FND_MESSAGE.SET_NAME('INV',errorExplanation);
   error_exp := FND_MESSAGE.GET;
   FND_MESSAGE.CLEAR;
END loadmsg;

PROCEDURE errupdate(err_row_id IN ROWID)
IS
BEGIN
   UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
      SET ERROR_CODE = substrb(err_code,1,240),
          ERROR_EXPLANATION = substrb(error_exp,1,240),
          LAST_UPDATE_DATE = sysdate,
          LAST_UPDATED_BY = userid,
          LAST_UPDATE_LOGIN = loginid,
          PROGRAM_UPDATE_DATE = SYSDATE,
          PROCESS_FLAG = 'E',
          TRANSACTION_STATUS = 1,
          LOCK_FLAG = 'N'
    WHERE ROWID = err_row_id;
END errupdate;

END INV_PROCESS_TEMP;

/
