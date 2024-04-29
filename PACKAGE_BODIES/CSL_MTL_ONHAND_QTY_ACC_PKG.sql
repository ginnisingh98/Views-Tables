--------------------------------------------------------
--  DDL for Package Body CSL_MTL_ONHAND_QTY_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_MTL_ONHAND_QTY_ACC_PKG" AS
/* $Header: cslo1acb.pls 120.0 2005/08/30 01:38:06 utekumal noship $ */


/*** Globals for notifications ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_MTL_ONHAND_QTY_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_MTL_ONHAND_QTY');
g_table_name            CONSTANT VARCHAR2(30) := 'MTL_ONHAND_QUANTITIES';
g_pk1_name              CONSTANT VARCHAR2(30) := 'INVENTORY_ITEM_ID';
g_pk2_name              CONSTANT VARCHAR2(30) := 'ORGANIZATION_ID';
g_pk3_name              CONSTANT VARCHAR2(30) := 'SUBINVENTORY_CODE';
g_debug_level           NUMBER;

PROCEDURE REFRESH_ONHAND_QTY
IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  TYPE sub_codeTab IS TABLE OF mtl_onhand_quantities.subinventory_code%TYPE INDEX BY BINARY_INTEGER;
  TYPE inv_idTab   IS TABLE OF mtl_onhand_quantities.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE org_idTab   IS TABLE OF mtl_onhand_quantities.organization_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE revisionTab IS TABLE OF mtl_onhand_quantities.revision%TYPE INDEX BY BINARY_INTEGER;
  TYPE locatorTab  IS TABLE OF mtl_onhand_quantities.locator_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tran_qtyTab IS TABLE OF mtl_onhand_quantities.transaction_quantity%TYPE INDEX BY BINARY_INTEGER;
  TYPE lot_numTab  IS TABLE OF mtl_onhand_quantities.lot_number%TYPE INDEX BY BINARY_INTEGER;
  sub_code  sub_codeTab;
  inv_id    inv_idTab;
  org_id    org_idTab;
  rvision   revisionTab;
  loc_id    locatorTab;
  qty       tran_qtyTab;
  lot_num   lot_numTab;

  l_current_run_date DATE;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_table_name
    , v_message     => 'Entering REFRESH_ONHAND_QTY'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
  END IF;

  l_current_run_date := SYSDATE;

  UPDATE JTM_CON_REQUEST_DATA SET LAST_RUN_DATE = l_current_run_date
  WHERE PRODUCT_CODE = 'CSL'
  AND   PACKAGE_NAME = 'CSL_MTL_ONHAND_QTY_ACC_PKG'
  AND   PROCEDURE_NAME = 'REFRESH_ONHAND_QTY';

  /*** First UPDATE existing MV records that changed ***/
  /*** Fetch all records in a Bulk recordset ***/
  SELECT ohq.subinventory_code
  ,      ohq.inventory_item_id
  ,      ohq.organization_id
  ,      ohq.revision
  ,      ohq.locator_id
  ,      ohq.lot_number
  ,      SUM(ohq.transaction_quantity)
  BULK COLLECT INTO sub_code, inv_id, org_id,rvision, loc_id,lot_num, qty
            FROM mtl_onhand_quantities ohq
  WHERE (ohq.subinventory_code, ohq.organization_id) IN
  ( SELECT secinv.secondary_inventory_name
    ,       secinv.organization_id
    FROM    jtm_csp_sec_inv_acc secacc
    ,       csp_sec_inventories secinv
    WHERE   secacc.secondary_inventory_id = secinv.secondary_inventory_id
    AND     condition_type = 'G'
  )
         GROUP BY ohq.subinventory_code,
                  ohq.inventory_item_id,
                  ohq.organization_id,
                  ohq.revision,
                  ohq.locator_id,
                  ohq.lot_number
  HAVING SUM(ohq.transaction_quantity) <>
  (
    SELECT tot_txn_quantity
    FROM   csl_mtl_onhand_qty_mv ohqmv
   WHERE ((ohqmv.LOT_NUMBER IS NULL AND ohq.LOT_NUMBER IS NULL) OR (ohqmv.LOT_NUMBER = ohq.LOT_NUMBER))
               AND ((ohqmv.LOCATOR_ID IS NULL AND ohq.LOCATOR_ID IS NULL) OR (ohqmv.LOCATOR_ID = ohq.LOCATOR_ID))
                AND ((ohqmv.REVISION IS NULL AND ohq.REVISION IS NULL) OR (ohqmv.REVISION = ohq.REVISION))
    AND ohqmv.organization_id = ohq.organization_id
    AND ohqmv.inventory_item_id = ohq.inventory_item_id
    AND ohqmv.subinventory_code = ohq.subinventory_code
  );

  /*** Process all records from Bulk recordset ***/
  IF (sub_code.COUNT > 0) THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
       ( v_object_id   => null
       , v_object_name => g_table_name
       , v_message     => 'Number of updated records for REFRESH_ONHAND_QTY : '
   || sub_code.COUNT
       , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
       , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
    END IF;
    FORALL i IN sub_code.FIRST..sub_code.LAST
      UPDATE CSL_MTL_ONHAND_QTY_MV SET LAST_UPDATE_DATE = l_current_run_date, TOT_TXN_QUANTITY = qty(i)
    WHERE subinventory_code = sub_code(i)
      AND inventory_item_id = inv_id(i)
      AND organization_id   = org_id(i)
      AND (LOT_NUMBER IS NULL OR LOT_NUMBER = lot_num(i))
      AND (LOCATOR_ID IS NULL OR LOCATOR_ID = loc_id(i))
      AND (REVISION IS NULL OR revision = rvision(i));
  END IF;

  /*** INSERT all newly created records for existing mobile users ***/
  INSERT INTO CSL_MTL_ONHAND_QTY_MV (subinventory_code
  ,  inventory_item_id,  organization_id,  revision,  locator_id
  ,  lot_number,  last_update_date,  tot_txn_quantity) (
   SELECT ohq.subinventory_code,  ohq.inventory_item_id
   ,  ohq.organization_id,  ohq.revision,  ohq.locator_id
   ,  ohq.lot_number,  l_current_run_date
   ,  SUM(ohq.transaction_quantity) tot_txn_quantity
   FROM   mtl_onhand_quantities ohq
   WHERE  (subinventory_code, organization_id) IN
   ( SELECT csi.secondary_inventory_name
     ,      csi.organization_id
     FROM   jtm_csp_sec_inv_acc   secacc
     ,      csp_sec_inventories   csi
     WHERE  csi.SECONDARY_INVENTORY_ID = secacc.SECONDARY_INVENTORY_ID
     AND    csi.CONDITION_TYPE = 'G'
   )
   AND NOT EXISTS ( SELECT NULL
     FROM CSL_MTL_ONHAND_QTY_MV   ohqmv
     WHERE    ((ohqmv.LOT_NUMBER IS NULL AND ohq.LOT_NUMBER IS NULL) OR (ohqmv.LOT_NUMBER = ohq.LOT_NUMBER))
     AND      ((ohqmv.LOCATOR_ID IS NULL AND ohq.LOCATOR_ID IS NULL) OR (ohqmv.LOCATOR_ID = ohq.LOCATOR_ID))
     AND      ((ohqmv.REVISION IS NULL AND ohq.REVISION IS NULL) OR (ohqmv.REVISION = ohq.REVISION))
     AND      ohqmv.ORGANIZATION_ID = ohq.ORGANIZATION_ID
     AND      ohqmv.INVENTORY_ITEM_ID = ohq.INVENTORY_ITEM_ID
     AND      ohqmv.SUBINVENTORY_CODE = ohq.SUBINVENTORY_CODE
     )
   GROUP BY ohq.subinventory_code
        ,  ohq.inventory_item_id
        ,  ohq.organization_id
        ,  ohq.revision
        ,  ohq.locator_id
        ,  ohq.lot_number);

  /*** DELETE all records for inventories that are no longer replicated ***/
  DELETE FROM CSL_MTL_ONHAND_QTY_MV
  WHERE (subinventory_code, organization_id) not in (
    SELECT csi.secondary_inventory_name
        ,  csi.organization_id
    FROM   jtm_csp_sec_inv_acc   secacc
    ,      csp_sec_inventories   csi
    WHERE  secacc.secondary_inventory_id = csi.secondary_inventory_id
    AND    csi.condition_type = 'G'
    );

  /*** DELETE all records that are no longer present in inventory ohq table ***/
  DELETE CSL_MTL_ONHAND_QTY_MV oqv
  WHERE (subinventory_code
    ,  inventory_item_id,  organization_id,  revision,  locator_id
    ,  lot_number) NOT IN (
     SELECT subinventory_code,  inventory_item_id
     ,  organization_id,  revision,  locator_id
     ,  lot_number
     FROM   mtl_onhand_quantities
     WHERE  (subinventory_code, organization_id) IN (
       SELECT csi.secondary_inventory_name
       ,      csi.organization_id
       FROM   jtm_csp_sec_inv_acc   secacc
       ,      csp_sec_inventories   csi
       WHERE  csi.SECONDARY_INVENTORY_ID = secacc.SECONDARY_INVENTORY_ID
       AND    csi.CONDITION_TYPE = 'G'
    )
  );

  COMMIT;

  /*** Processed MV table, now push changes to ACC table ***/
  PROCESS_ACC(l_current_run_date);

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => 1
    , v_object_name => g_table_name
    , v_message     => 'Leaving REFRESH_ONHAND_QTY'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
  END IF;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => 1
    , v_object_name => g_table_name
    , v_message     => 'Caught exception in REFRESH_ONHAND_QTY hook:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
    , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
  END IF;
  ROLLBACK;
  fnd_msg_pub.Add_Exc_Msg('CSL_MTL_ONHAND_QTY_ACC_PKG','REFRESH_ONHAND_QTY',sqlerrm);

END REFRESH_ONHAND_QTY;

PROCEDURE PROCESS_ACC( l_current_run_date IN DATE)
IS

  CURSOR c_secinv_resources IS (
  SELECT DISTINCT resource_id
  FROM JTM_CSP_INV_LOC_ASS_ACC);

  r_secinv_resources c_secinv_resources%ROWTYPE;

  CURSOR c_trackable_flag(b_inventory_item_id IN NUMBER
                         ,b_organization_id  IN NUMBER
	          ) IS
  SELECT COMMS_NL_TRACKABLE_FLAG
  FROM MTL_SYSTEM_ITEMS_B
  WHERE INVENTORY_ITEM_ID = b_inventory_item_id
  AND   ORGANIZATION_ID = b_organization_id;

  r_trackable_flag c_trackable_flag%ROWTYPE;

  TYPE access_idTab  IS TABLE OF csl_mtl_onhand_qty_acc.access_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE inv_idTab     IS TABLE OF csl_mtl_onhand_qty_acc.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE org_idTab     IS TABLE OF csl_mtl_onhand_qty_acc.organization_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE sub_codeTab   IS TABLE OF csl_mtl_onhand_qty_acc.subinventory_code%TYPE INDEX BY BINARY_INTEGER;
  TYPE rvsionTab     IS TABLE OF csl_mtl_onhand_qty_acc.revision%TYPE INDEX BY BINARY_INTEGER;
  TYPE loc_idTab     IS TABLE OF csl_mtl_onhand_qty_acc.locator_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE lot_numTab    IS TABLE OF csl_mtl_onhand_qty_acc.lot_number%TYPE INDEX BY BINARY_INTEGER;
  TYPE res_idTab     IS TABLE OF csl_mtl_onhand_qty_acc.resource_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE track_flagTab IS TABLE OF mtl_system_items_b.comms_nl_trackable_flag%TYPE INDEX BY BINARY_INTEGER;
  acc_id     access_idTab;
  inv_id     inv_idTab;
  org_id     org_idTab;
  sub_code   sub_codeTab;
  rvsion     rvsionTab;
  loc_id     loc_idTab;
  lot_num    lot_numTab;
  res_id     res_idTab;
  track_flag track_flagTab;

  l_dummy BOOLEAN;

BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => TO_CHAR(l_current_run_date,'MM-DD-YYYY HH24:MI:SS')
    , v_object_name => g_table_name
    , v_message     => 'Entering PROCESS_ACC'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
  END IF;

  /*** Loop through resources to which a subinventory is assigned ***/
  FOR r_secinv_resources IN c_secinv_resources LOOP
    /*** First retrieve access_id of updated records and push them ***/

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => TO_CHAR(l_current_run_date,'MM-DD-YYYY HH24:MI:SS')
      , v_object_name => g_table_name
      , v_message     => 'Checking updates and inserts for resource_id = ' || r_secinv_resources.resource_id
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
    END IF;

    /*** Push updated record to client ***/
    SELECT ohqacc.access_id
      BULK COLLECT INTO acc_id
      FROM csl_mtl_onhand_qty_mv ohqmv,
           csl_mtl_onhand_qty_acc ohqacc
     WHERE ((ohqmv.lot_number IS NULL AND ohqacc.lot_number IS NULL) OR (ohqmv.lot_number = ohqacc.lot_number))
       AND ((ohqmv.locator_id IS NULL AND ohqacc.locator_id IS NULL) OR (ohqmv.locator_id = ohqacc.locator_id))
       AND ((ohqmv.revision IS NULL AND ohqacc.revision IS NULL) OR (ohqmv.revision = ohqacc.revision))
       AND ohqmv.organization_id = ohqacc.organization_id
       AND ohqmv.inventory_item_id = ohqacc.inventory_item_id
       AND ohqmv.subinventory_code = ohqacc.subinventory_code
       AND ohqacc.resource_id = r_secinv_resources.resource_id
       AND ohqmv.last_update_date = l_current_run_date;

    IF (acc_id.COUNT > 0) THEN
      /*** push to oLite using asg_download ***/

      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => TO_CHAR(l_current_run_date,'MM-DD-YYYY HH24:MI:SS')
        , v_object_name => g_table_name
        , v_message     => 'Pushing ' || acc_id.COUNT || ' updated record(s)'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
        , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
      END IF;

      FOR i IN acc_id.FIRST..acc_id.LAST LOOP
        IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => TO_CHAR(l_current_run_date,'MM-DD-YYYY HH24:MI:SS')
          , v_object_name => g_table_name
          , v_message     => 'Pushing record with access_id = ' || acc_id(i)
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
          , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
        END IF;

        l_dummy := asg_download.markdirty(
          P_PUB_ITEM         => g_publication_item_name(1)
        , P_ACCESSID         => acc_id(i)
        , P_RESOURCEID       => r_secinv_resources.resource_id
        , P_DML              => 'U'
        , P_TIMESTAMP        => SYSDATE
        );
      END LOOP;
    END IF;

    /*** Push inserted records to client ***/
    acc_id.DELETE;
    inv_id.DELETE;
    org_id.DELETE;
    sub_code.DELETE;
    rvsion.DELETE;
    loc_id.DELETE;
    lot_num.DELETE;
    acc_id.DELETE;
    track_flag.DELETE;
    SELECT ohqmv.INVENTORY_ITEM_ID
    ,      ohqmv.ORGANIZATION_ID
    ,      ohqmv.SUBINVENTORY_CODE
    ,      ohqmv.REVISION,ohqmv.LOCATOR_ID
    ,      ohqmv.LOT_NUMBER
    ,      JTM_ACC_TABLE_S.NEXTVAL ACCESS_ID
    ,      msi.COMMS_NL_TRACKABLE_FLAG
    BULK COLLECT INTO inv_id, org_id, sub_code, rvsion, loc_id,lot_num, acc_id,track_flag
    FROM csl_mtl_onhand_qty_mv ohqmv
    ,    mtl_system_items      msi
    WHERE msi.INVENTORY_ITEM_ID = ohqmv.INVENTORY_ITEM_ID
    AND msi.ORGANIZATION_ID = ohqmv.ORGANIZATION_ID
    AND (ohqmv.subinventory_code, ohqmv.organization_id) IN
    ( SELECT ila.subinventory_code, ila.organization_id
      FROM csp_inv_loc_assignments ila
      ,    jtm_csp_inv_loc_ass_acc ilaacc
      WHERE ilaacc.resource_id = r_secinv_resources.resource_id
      AND ilaacc.csp_inv_loc_assignment_id = ila.csp_inv_loc_assignment_id
      AND SYSDATE BETWEEN NVL(ila.effective_date_start, SYSDATE)
          AND NVL(ila.effective_date_end, SYSDATE)
    )
    AND NOT EXISTS (
      SELECT NULL
      FROM csl_mtl_onhand_qty_acc ohqacc
     WHERE ((ohqacc.lot_number IS NULL AND ohqmv.lot_number IS NULL) OR (ohqacc.lot_number = ohqmv.lot_number))
      AND ((ohqacc.locator_id IS NULL AND ohqmv.locator_id IS NULL) OR (ohqacc.locator_id = ohqmv.locator_id))
      AND ((ohqacc.revision IS NULL AND ohqmv.revision IS NULL) OR (ohqacc.revision = ohqmv.revision))
      AND ohqacc.organization_id = ohqmv.organization_id
      AND ohqacc.inventory_item_id = ohqmv.inventory_item_id
      AND ohqacc.subinventory_code = ohqmv.subinventory_code
      AND ohqacc.resource_id = r_secinv_resources.resource_id
    );

    IF (acc_id.COUNT > 0) THEN
      /*** push to oLite using asg_download ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => TO_CHAR(l_current_run_date,'MM-DD-YYYY HH24:MI:SS')
        , v_object_name => g_table_name
        , v_message     => 'Pushing ' || acc_id.COUNT || ' inserted record(s)'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
        , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
      END IF;

      FORALL i IN acc_id.FIRST..acc_id.LAST
      INSERT INTO CSL_MTL_ONHAND_QTY_ACC (RESOURCE_ID,INVENTORY_ITEM_ID,ORGANIZATION_ID,
      SUBINVENTORY_CODE,REVISION,LOCATOR_ID,LOT_NUMBER,ACCESS_ID,COUNTER,LAST_UPDATE_DATE,LAST_UPDATED_BY,
      CREATION_DATE,CREATED_BY) VALUES (r_secinv_resources.resource_id,inv_id(i), org_id(i), sub_code(i),
      rvsion(i), loc_id(i), lot_num(i), acc_id(i),1,SYSDATE,1,SYSDATE,1);

      FOR i IN acc_id.FIRST..acc_id.LAST LOOP

        IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => TO_CHAR(l_current_run_date,'MM-DD-YYYY HH24:MI:SS')
          , v_object_name => g_table_name
          , v_message     => 'Pushing record with access_id = ' || acc_id(i)
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
          , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
        END IF;

        l_dummy := asg_download.markdirty(
            P_PUB_ITEM         => g_publication_item_name(1)
          , P_ACCESSID         => acc_id(i)
          , P_RESOURCEID       => r_secinv_resources.resource_id
          , P_DML              => 'I'
          , P_TIMESTAMP        => SYSDATE
          );

        IF NVL(track_flag(i),'N') <> 'Y' THEN
          IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
            jtm_message_log_pkg.Log_Msg
            ( v_object_id   => TO_CHAR(l_current_run_date,'MM-DD-YYYY HH24:MI:SS')
            , v_object_name => g_table_name
            , v_message     => 'Calling CSL_MTL_SYSTEM_ITEMS_ACC_PKG.PRE_INSERT_CHILD'
            , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
            , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
          END IF;
          CSL_MTL_SYSTEM_ITEMS_ACC_PKG.PRE_INSERT_CHILD(inv_id(i),org_id(i),r_secinv_resources.resource_id);
        END IF;

      END LOOP;
    END IF;

    /*** Push deleted records to client ***/
    acc_id.DELETE;
    track_flag.DELETE;
    inv_id.DELETE;
    org_id.DELETE;
    sub_code.DELETE;
    SELECT ohqacc.ACCESS_ID
    ,      ohqacc.inventory_item_id
    ,      ohqacc.organization_id
    ,      ohqacc.subinventory_code
    ,      msi.COMMS_NL_TRACKABLE_FLAG
    BULK COLLECT INTO acc_id,inv_id, org_id, sub_code, track_flag
    FROM csl_mtl_onhand_qty_acc ohqacc
    ,    mtl_system_items      msi
    WHERE msi.INVENTORY_ITEM_ID = ohqacc.INVENTORY_ITEM_ID
    AND msi.ORGANIZATION_ID = ohqacc.ORGANIZATION_ID
    AND ohqacc.resource_id = r_secinv_resources.resource_id
    AND NOT EXISTS (
      SELECT null
      FROM csl_mtl_onhand_qty_mv ohqmv
      WHERE ((ohqacc.lot_number IS NULL AND ohqmv.lot_number IS NULL) OR (ohqacc.lot_number = ohqmv.lot_number))
      AND ((ohqacc.locator_id IS NULL AND ohqmv.locator_id IS NULL) OR (ohqacc.locator_id = ohqmv.locator_id))
      AND ((ohqacc.revision IS NULL AND ohqmv.revision IS NULL) OR (ohqacc.revision = ohqmv.revision))
      AND ohqacc.organization_id = ohqmv.organization_id
      AND ohqacc.inventory_item_id = ohqmv.inventory_item_id
      AND ohqacc.subinventory_code = ohqmv.subinventory_code
    );

    IF (acc_id.COUNT > 0) THEN
      /*** push to oLite using asg_download ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => TO_CHAR(l_current_run_date,'MM-DD-YYYY HH24:MI:SS')
        , v_object_name => g_table_name
        , v_message     => 'Pushing ' || acc_id.COUNT || ' deleted record(s)'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
        , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
      END IF;

      FOR i IN acc_id.FIRST..acc_id.LAST LOOP

        IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => TO_CHAR(l_current_run_date,'MM-DD-YYYY HH24:MI:SS')
          , v_object_name => g_table_name
          , v_message     => 'Pushing record with access_id = ' || acc_id(i)
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
          , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
        END IF;

        l_dummy := asg_download.markdirty(
            P_PUB_ITEM         => g_publication_item_name(1)
          , P_ACCESSID         => acc_id(i)
          , P_RESOURCEID       => r_secinv_resources.resource_id
          , P_DML              => 'D'
          , P_TIMESTAMP        => SYSDATE
          );

        IF NVL(track_flag(i),'N') <> 'Y' THEN
          IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
            jtm_message_log_pkg.Log_Msg
            ( v_object_id   => TO_CHAR(l_current_run_date,'MM-DD-YYYY HH24:MI:SS')
            , v_object_name => g_table_name
            , v_message     => 'Calling CSL_MTL_SYSTEM_ITEMS_ACC_PKG.POST_DELETE_CHILD'
            , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
            , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
          END IF;

          CSL_MTL_SYSTEM_ITEMS_ACC_PKG.POST_DELETE_CHILD( inv_id(i)
	                                                , org_id(i)
							, r_secinv_resources.resource_id);
        END IF;
      END LOOP;

      FORALL i IN acc_id.FIRST..acc_id.LAST
      DELETE CSL_MTL_ONHAND_QTY_ACC
      WHERE  ACCESS_ID = acc_id(i);
    END IF;
    COMMIT;
  END LOOP;

  /** Call out to item instances program to insert the OHQ instances **/
  CSL_CSI_ITEM_INSTANCES_ACC_PKG.CONC_ITEM_INSTANCES(l_current_run_date);

  COMMIT;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => TO_CHAR(l_current_run_date,'MM-DD-YYYY HH24:MI:SS')
    , v_object_name => g_table_name
    , v_message     => 'Leaving PROCESS_ACC'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
  END IF;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => 1
    , v_object_name => g_table_name
    , v_message     => 'Caught exception in PROCESS_ACC hook:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
    , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
  END IF;
  ROLLBACK;
  fnd_msg_pub.Add_Exc_Msg('CSL_MTL_ONHAND_QTY_ACC_PKG','PROCESS_ACC',sqlerrm);
END PROCESS_ACC;

/*Delete all records for non-existing user ( e.g user was deleted )*/
PROCEDURE DELETE_ALL_ACC_RECORDS( p_resource_id IN NUMBER
                                , x_return_status OUT NOCOPY VARCHAR2 )
IS
  l_tab_access_id dbms_sql.Number_Table;
  l_dummy BOOLEAN;
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Entering DELETE_ALL_ACC_RECORDS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , v_module      => 'csl_mtl_onhand_qty_acc_pkg'
    );
  END IF;

/*  DELETE CSL_MTL_ONHAND_QTY_ACC
  WHERE  RESOURCE_ID = p_resource_id
  RETURNING ACCESS_ID BULK COLLECT INTO l_tab_access_id;*/

  SELECT ACCESS_ID
  BULK COLLECT INTO l_tab_access_id
  FROM CSL_MTL_ONHAND_QTY_ACC
  WHERE  RESOURCE_ID = p_resource_id;

  IF l_tab_access_id.COUNT > 0 THEN
   IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Pulling '||l_tab_access_id.COUNT||' records from Oracle Lite for resource '||p_resource_id
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
    , v_module      => 'csl_mtl_onhand_qty_acc_pkg'
    );
    END IF;

   FOR i IN l_tab_access_id.FIRST..l_tab_access_id.LAST LOOP
    /*** 1 or more acc rows retrieved -> push to resource ***/
    l_dummy := asg_download.markdirty(
              P_PUB_ITEM         => g_publication_item_name(1)
            , P_ACCESSID         => l_tab_access_id(i)
            , P_RESOURCEID       => p_resource_id
            , P_DML              => 'D'
            , P_TIMESTAMP        => SYSDATE
            );
   END LOOP;

   FORALL i IN l_tab_access_id.FIRST..l_tab_access_id.LAST
    DELETE CSL_MTL_ONHAND_QTY_ACC
    WHERE ACCESS_ID = l_tab_access_id(i);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_resource_id
    , g_table_name
    , 'Leaving DELETE_ALL_ACC_RECORDS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , v_module      => 'csl_mtl_onhand_qty_acc_pkg'
    );
  END IF;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => 1
    , v_object_name => g_table_name
    , v_message     => 'Caught exception in DELETE_ALL_ACC_RECORDS hook:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
    , v_module      => 'csl_mtl_onhand_qty_acc_pkg');
  END IF;
  fnd_msg_pub.Add_Exc_Msg('CSL_MTL_ONHAND_QTY_ACC_PKG','PROCESS_ACC',sqlerrm);
END DELETE_ALL_ACC_RECORDS;



END CSL_MTL_ONHAND_QTY_ACC_PKG;

/
