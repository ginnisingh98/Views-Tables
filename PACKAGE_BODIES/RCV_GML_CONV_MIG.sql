--------------------------------------------------------
--  DDL for Package Body RCV_GML_CONV_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_GML_CONV_MIG" AS
/* $Header: RCVMGGMB.pls 120.6.12010000.3 2011/06/28 14:28:31 adeshmuk ship $ */
/*===========================================================================
--  PROCEDURE:
--    RCV_MIG_GML_DATA
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to all the RCV entities for Inv Convergence
--    project. Main Procedure that calls the other 3 procedures.
--
--  PARAMETERS:
--    None
--
--  SYNOPSIS:
--    rcv_mig_gml_data;
--
--  HISTORY
--    P. Bamb  10-May-2005   Created
--=========================================================================== */
Procedure rcv_mig_gml_data IS

BEGIN


   --Call proc to update lots with the latest migrated lot number in rcv_lot_Transactions.
   Update_rcv_lot_transactions;

   --Call proc to update secondary unit of measure and secondary quantity in rcv_supply.
   Update_rcv_supply;

   --Call proc to update lots with migrated lot number in rcv_lots_supply.
   Update_rcv_lots_supply;

END rcv_mig_gml_data;


/*===========================================================================
--  PROCEDURE:
--    update_rcv_lot_transactions
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to Update RCV_LOT_TRANSACTIONS for LOT_NUM.
--
--  PARAMETERS:
--    None
--
--  SYNOPSIS:
--    update_rcv_lot_transactions;
--
--  HISTORY
--    P. Bamb  10-May-2005   Created
--    KBAVADEK 10-MAR-2011   Bug#11670689.Modified sql in cursor CR_GET_TRX_LOTS
--                           for performance issue
--    ASATPUTE 22-Jun-2011   Bug 12591131 Update only those transctions that
-- 		contain lots that were ALREADY migrated
--=========================================================================== */
PROCEDURE update_rcv_lot_transactions IS

/* Fix for Bug#11670689. Added hints in select and subquery clause */

-- Cursor CR_GET_TRX_LOTS IS
-- SELECT /*+ parallel(rlt)  */ rlt.rowid,
--        rlt.transaction_id transaction_id,
--        rlt.source_transaction_id source_transaction_id,
--        rt.SHIPMENT_HEADER_ID shipment_header_id,
--        rlt.SHIPMENT_LINE_ID shipment_line_id,
--        rlt.lot_num lot_num,
--        rlt.sublot_num,
--        rlt.item_id,
--        rt.organization_id organization_id,
--        rt.subinventory subinventory,
--        rt.locator_id locator_id,
--        rlt.correction_transaction_id
-- FROM   rcv_transactions rt ,
--        rcv_lot_transactions rlt,
--        mtl_parameters mp
-- WHERE  rlt.lot_transaction_type = 'TRANSACTION'
-- and    rlt.source_transaction_id = rt.transaction_id
-- and    (rlt.sublot_num <> '-1' or rlt.sublot_num is NULL)
-- and    rt.organization_id = mp.organization_id
-- and    mp.process_enabled_flag = 'Y'
-- and not exists
--       (SELECT /*+ push_subq no_unnest */ 'x'
--        FROM   GML_RCV_LOTS_MIGRATION glm
--        WHERE  table_name = 'RCV_LOT_TRANSACTIONS'
--        AND    glm.source_transaction_id = rlt.source_transaction_id
--        AND    glm.transaction_id = rlt.transaction_id
--        AND    glm.correction_transaction_id = rlt.correction_transaction_id);
--
/* Bug 12591131
* Instead of updating ALL the receiving transactions - update only a
* subset i.e. If a lot was ALREADY migrated (for some other considerations) then
* only update the  corresponding receiving transactions, therefore a join with
* mig tables. Also get the ODM lot number from mig table and use it in update */

Cursor CR_GET_TRX_LOTS IS
SELECT /*+ parallel(rlt)  */ rlt.rowid,
       rlt.transaction_id transaction_id,
       rlt.source_transaction_id source_transaction_id,
       rt.SHIPMENT_HEADER_ID shipment_header_id,
       rlt.SHIPMENT_LINE_ID shipment_line_id,
       rlt.lot_num lot_num,
       rlt.sublot_num,
       mlot.lot_number,
       rlt.item_id,
       rt.organization_id organization_id,
       rt.subinventory subinventory,
       rt.locator_id locator_id,
       rlt.correction_transaction_id
FROM
	ic_item_mst_b_mig mitm,
	ic_lots_mst_mig mlot,
	rcv_transactions rt ,
	rcv_lot_transactions rlt,
	mtl_parameters mp
WHERE
mitm.organization_id = mlot.organization_id
AND mitm.item_id = mlot.item_id
AND rlt.item_id = mitm.inventory_item_id
AND rlt.lot_num = mlot.lot_number
AND rt.organization_id = mlot.organization_id
AND rt.organization_id = mitm.organization_id
AND rlt.lot_transaction_type = 'TRANSACTION'
AND rlt.source_transaction_id = rt.transaction_id
AND (rlt.sublot_num <> '-1' or rlt.sublot_num is NULL)
AND rt.organization_id = mp.organization_id
AND mlot.lot_number is NOT NULL
AND mp.process_enabled_flag = 'Y'
AND NOT EXISTS
      (SELECT /*+ push_subq no_unnest */ 'x'
       FROM   GML_RCV_LOTS_MIGRATION glm
       WHERE  table_name = 'RCV_LOT_TRANSACTIONS'
       AND  glm.source_transaction_id = rlt.source_transaction_id
       AND  glm.transaction_id = rlt.transaction_id
       AND  glm.correction_transaction_id = rlt.correction_transaction_id);

/* Bug 12591131
* Instead of updating ALL the receiving transactions - update only a
* subset i.e. If a lot was ALREADY migrated (for some other considerations) then
* only update the  corresponding receiving transactions, therefore a join with
* mig tables. Also get the ODM lot number from mig table and use it in update */
/* CURSOR CR_GET_SHIP_LOTS IS
SELECT rlt.rowid,
       rlt.transaction_id transaction_id,
       rsl.SHIPMENT_HEADER_ID shipment_header_id,
       rsl.SHIPMENT_LINE_ID shipment_line_id,
       rlt.lot_num lot_num,
       rlt.sublot_num,
       rlt.item_id,
       rsl.to_organization_id organization_id,
       rsl.to_subinventory subinventory,
       rsl.locator_id locator_id,
       rlt.correction_transaction_id,
       rlt.source_transaction_id
FROM   rcv_lot_transactions rlt ,
       rcv_shipment_lines rsl,
       mtl_parameters mp
WHERE  rlt.lot_transaction_type = 'SHIPMENT'
and    rsl.shipment_line_id = rlt.shipment_line_id
and    (rlt.sublot_num <> '-1' or rlt.sublot_num IS NULL)
and    rsl.to_organization_id = mp.organization_id
and    mp.process_enabled_flag = 'Y'
and not exists
      (SELECT 'x' from GML_RCV_LOTS_MIGRATION glm
       WHERE  table_name = 'RCV_LOT_TRANSACTIONS'
         And glm.shipment_line_id = rlt.shipment_line_id);
*/

CURSOR CR_GET_SHIP_LOTS IS
SELECT rlt.rowid,
       rlt.transaction_id transaction_id,
       rsl.SHIPMENT_HEADER_ID shipment_header_id,
       rsl.SHIPMENT_LINE_ID shipment_line_id,
       rlt.lot_num lot_num,
       rlt.sublot_num,
       mlot.lot_number,
       rlt.item_id,
       rsl.to_organization_id organization_id,
       rsl.to_subinventory subinventory,
       rsl.locator_id locator_id,
       rlt.correction_transaction_id,
       rlt.source_transaction_id
FROM
        ic_lots_mst_mig mlot,
        ic_item_mst_b_mig mitm,
	rcv_lot_transactions rlt ,
	rcv_shipment_lines rsl,
	mtl_parameters mp
WHERE
mitm.organization_id = mlot.organization_id
AND mitm.item_id = mlot.item_id
AND rlt.item_id = mitm.inventory_item_id
AND rlt.lot_num = mlot.lot_number
AND rsl.to_organization_id = mlot.organization_id
AND rsl.to_organization_id = mitm.organization_id
AND rlt.lot_transaction_type = 'SHIPMENT'
AND rsl.shipment_line_id = rlt.shipment_line_id
AND (rlt.sublot_num <> '-1' or rlt.sublot_num IS NULL)
AND rsl.to_organization_id = mp.organization_id
AND mlot.lot_number is NOT NULL
AND mp.process_enabled_flag = 'Y'
AND not exists
      (SELECT 'x' from GML_RCV_LOTS_MIGRATION glm
       WHERE  table_name = 'RCV_LOT_TRANSACTIONS'
         And glm.shipment_line_id = rlt.shipment_line_id);

l_lot_num        VARCHAR2(80);
l_parent_lot_num VARCHAR2(80);
l_count          NUMBER;
cr_rec           CR_GET_TRX_LOTS%ROWTYPE;
cr_rec1          CR_GET_SHIP_LOTS%ROWTYPE;
l_errm           VARCHAR2(2000);
BEGIN

   FOR cr_rec in cr_get_trx_lots LOOP
    BEGIN
 /* Bug  12591131
 * No need to call API - Now we do not expect to cause lot migration during this
 * procedure. As well the ODM lot number is obtained in the cursor
 *
       INV_OPM_LOT_MIGRATION.GET_ODM_LOT(
           P_MIGRATION_RUN_ID     => 1,
           P_INVENTORY_ITEM_ID    => cr_rec.item_id,
           P_LOT_NO               => cr_rec.lot_num,
           P_SUBLOT_NO            => cr_rec.sublot_num,
           P_ORGANIZATION_ID      => cr_rec.organization_id,
           P_LOCATOR_ID           => cr_rec.locator_id,
           P_COMMIT               => 'Y',
           X_LOT_NUMBER           => l_lot_num,
           X_PARENT_LOT_NUMBER    => l_parent_lot_num,
           X_FAILURE_COUNT        => l_count
           );

     --Call INVENTORY API that returns the new Lot number for the item, organization, lot, sublot,
     --   Subinventory and Locator
     --For any errors raise exception rcv_lot_transactions_data;

     Update rcv_lot_transactions
     set    LOT_NUM = l_lot_num
     where  rowid = cr_rec.rowid;
    */

     Update rcv_lot_transactions
     set    LOT_NUM = cr_rec.lot_number
     where  rowid = cr_rec.rowid;


     INSERT INTO GML_RCV_LOTS_MIGRATION
            ( TABLE_NAME,
              TRANSACTION_ID,
              SOURCE_TRANSACTION_ID,
              SHIPMENT_LINE_ID,
              CORRECTION_TRANSACTION_ID,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE)
     VALUES ( 'RCV_LOT_TRANSACTIONS',
              cr_rec.transaction_id,
              cr_rec.source_transaction_id,
              cr_rec.shipment_line_id,
              cr_rec.correction_transaction_id,
              1,
              sysdate,
              1,
              sysdate);

    EXCEPTION
              WHEN OTHERS THEN
            l_errm := sqlerrm;
               insert into gml_po_mig_errors
				(migration_type,po_header_id,po_line_id,line_location_id,
				 transaction_id, shipment_header_id,shipment_line_id,
				 column_name,table_name,error_message,
				 creation_date,last_update_date)
			values ('CONVERGENCE',NULL, NULL, NULL,
				cr_rec.transaction_id, cr_rec.shipment_header_id, cr_rec.shipment_line_id,
				'LOT_NUM','RCV_LOT_TRANSACTIONS',
				'ERROR DERIVING NEW LOT NUM-'||substr(l_errm,1,1970),sysdate,sysdate);
    END;
   END LOOP;

 COMMIT;


   FOR cr_rec1 in cr_get_ship_lots LOOP
     BEGIN
/* Bug  12591131
 *  * No need to call API - Now we do not expect to cause lot migration during
 *  this
 *   * procedure. As well the ODM lot number is obtained in the cursor
 *    *
 *
         INV_OPM_LOT_MIGRATION.GET_ODM_LOT(
           P_MIGRATION_RUN_ID     => 1,
           P_INVENTORY_ITEM_ID    => cr_rec1.item_id,
           P_LOT_NO               => cr_rec1.lot_num,
           P_SUBLOT_NO            => cr_rec1.sublot_num,
           P_ORGANIZATION_ID      => cr_rec1.organization_id,
           P_LOCATOR_ID           => cr_rec1.locator_id,
           P_COMMIT               => 'Y',
           X_LOT_NUMBER           => l_lot_num,
           X_PARENT_LOT_NUMBER    => l_parent_lot_num,
           X_FAILURE_COUNT        => l_count
           );

      --Call INVENTORY API that returns the new Lot number for the item, organization, lot, sublot,
      --   Subinventory and Locator
      --For any errors raise exception rcv_lot_transactions_data;

      UPDATE rcv_lot_transactions
      SET    LOT_NUM = l_lot_num
     where  rowid = cr_rec1.rowid;
 */
      UPDATE rcv_lot_transactions
      SET    LOT_NUM = cr_rec1.lot_number
     where  rowid = cr_rec1.rowid;

      INSERT INTO GML_RCV_LOTS_MIGRATION
         ( TABLE_NAME,
           TRANSACTION_ID,
           SOURCE_TRANSACTION_ID,
           SHIPMENT_LINE_ID,
           CORRECTION_TRANSACTION_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE)
      VALUES ( 'RCV_LOT_TRANSACTIONS',
           cr_rec1.transaction_id,
           cr_rec1.source_transaction_id,
           cr_rec1.shipment_line_id,
           cr_rec1.correction_transaction_id,
           1,
           sysdate,
           1,
           sysdate);

      EXCEPTION
           WHEN OTHERS THEN
            l_errm := sqlerrm;
            insert into gml_po_mig_errors
				(migration_type,po_header_id,po_line_id,line_location_id,
				 transaction_id, shipment_header_id,shipment_line_id,
				 column_name,table_name,error_message,
				 creation_date,last_update_date)
			values ('CONVERGENCE',NULL, NULL, NULL,
				cr_rec1.transaction_id, cr_rec1.shipment_header_id, cr_rec1.shipment_line_id,
				'LOT_NUM','RCV_LOT_TRANSACTIONS',
				'ERROR DERIVING NEW LOT NUM-'||substr(l_errm,1,1970),sysdate,sysdate);
      END;
   END LOOP;

COMMIT;
END Update_rcv_lot_transactions;


/*===========================================================================
--  PROCEDURE:
--    update_rcv_supply
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to Update RCV_SUPPLY for secondary_quantity
--    and secondary_unit_of_measure
--
--  PARAMETERS:
--    None
--
--  SYNOPSIS:
--    update_rcv_supply;
--
--  HISTORY
--    P. Bamb  10-May-2005   Created
--=========================================================================== */
PROCEDURE update_rcv_supply IS

CURSOR cr_get_supply IS
SELECT rs.rowid,
       rs.quantity,
       rs.Unit_of_measure,
       rs.Secondary_quantity,
       rs.Secondary_unit_of_measure,
       msi.secondary_uom_code,
       rs.To_organization_id,
       rs.To_subinventory,
       rs.To_locator_id,
       rs.Item_id,
       rs.po_header_id    ,
       rs.po_line_id      ,
       rs.po_line_location_id   ,
       rs.shipment_header_id    ,
       rs.shipment_line_id      ,
       rs.rcv_transaction_id
FROM   rcv_supply rs ,
       mtl_system_items_b msi,
       mtl_parameters mp
WHERE  nvl(rs.quantity,0) <> 0
AND    rs.secondary_quantity is null
AND    rs.item_id = msi.INVENTORY_ITEM_ID
AND    msi.ORGANIZATION_ID = to_organization_id
AND    msi.tracking_quantity_ind = 'PS'
AND    rs.to_organization_id = mp.organization_id
AND    mp.process_enabled_flag = 'Y';

l_secondary_unit_of_measure VARCHAR2(25);
l_secondary_quantity NUMBER;
rcv_supply_data_err EXCEPTION;

cr_rec cr_get_supply%ROWTYPE;
l_errm           VARCHAR2(2000);


BEGIN

   FOR cr_rec IN cr_get_supply LOOP
     BEGIN

      SELECT UNIT_OF_MEASURE
      INTO   l_secondary_unit_of_measure
      FROM   MTL_UNITS_OF_MEASURE
      WHERE  UOM_CODE = cr_rec.secondary_uom_code;


      l_secondary_quantity := INV_CONVERT.inv_um_convert(
                                                  item_id        => cr_rec.item_id,
                                                  precision      => 6,
                                                  from_quantity  => cr_rec.quantity,
                                                  from_unit      => NULL,
                                                  to_unit        => NULL,
                                                  from_name      => cr_rec.unit_of_measure ,
                                                  to_name        => l_secondary_unit_of_measure ); --Bug# 5584581
        IF l_secondary_quantity  <=0 THEN
          raise rcv_supply_data_err;
        End If;

        UPDATE rcv_supply
        SET    secondary_quantity = l_secondary_quantity,
               secondary_unit_of_measure = l_secondary_unit_of_measure
        WHERE  rowid = cr_rec.rowid;

      EXCEPTION
         WHEN rcv_supply_data_err Then
            insert into gml_po_mig_errors
				(migration_type,po_header_id,po_line_id,line_location_id,
				 transaction_id, shipment_header_id,shipment_line_id,
				 column_name,table_name,error_message,
				 creation_date,last_update_date)
			values ('CONVERGENCE',cr_rec.po_header_id,cr_rec.po_line_id,cr_rec.po_line_location_id,
				cr_rec.rcv_transaction_id, cr_rec.shipment_header_id, cr_rec.shipment_line_id,
				'SECONDARY_QUANTITY','RCV_SUPPLY',
				'ERROR DERIVING SECONDARY_QUANTITY FROM QUANTITY',sysdate,sysdate);
         WHEN OTHERS Then
            l_errm := sqlerrm;
            insert into gml_po_mig_errors
				(migration_type,po_header_id,po_line_id,line_location_id,
				 transaction_id, shipment_header_id,shipment_line_id,
				 column_name,table_name,error_message,
				 creation_date,last_update_date)
			values ('CONVERGENCE',cr_rec.po_header_id,cr_rec.po_line_id,cr_rec.po_line_location_id,
				cr_rec.rcv_transaction_id, cr_rec.shipment_header_id, cr_rec.shipment_line_id,
				'SECONDARY_QUANTITY','RCV_SUPPLY',
				'WHEN OTHERS IN DERIVING SECONDARY_QUANTITY FROM QUANTITY-'||substr(l_errm,1,1925),sysdate,sysdate);
     END;
   END LOOP;
   Commit;

END Update_rcv_supply;

/*===========================================================================
--  PROCEDURE:
--    update_rcv_lots_supply
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to Update RCV_LOTS_SUPPLY for LOT_NUM
--
--  PARAMETERS:
--    None
--
--  SYNOPSIS:
--    update_rcv_lots_supply;
--
--  HISTORY
--    P. Bamb  10-May-2005   Created
--=========================================================================== */
PROCEDURE update_rcv_lots_supply IS

CURSOR CR_GET_LOT_SUPPLY IS
SELECT rls.rowid,
       rls.transaction_id transaction_id,
       rt.SHIPMENT_HEADER_ID shipment_header_id,
       rls.SHIPMENT_LINE_ID shipment_line_id,
       rls.lot_num lot_num,
       rls.sublot_num,
       rt.organization_id organization_id,
       rt.subinventory subinventory,
       rt.locator_id locator_id,
       rls.reason_code,
       rsl.item_id
FROM   rcv_transactions rt ,
       rcv_lots_supply rls,
       rcv_shipment_lines rsl,
       mtl_parameters mp
WHERE  rls.supply_type_code = 'RECEIVING'
and    rls.transaction_id = rt.transaction_id
and    (rls.sublot_num <> '-1' or rls.sublot_num IS NULL)
AND    rt.organization_id = mp.organization_id
AND    rt.shipment_header_id = rsl.shipment_header_id
AND    rt.shipment_line_id = rsl.shipment_line_id
AND    mp.process_enabled_flag = 'Y'
and not exists
       (SELECT 'x' from GML_RCV_LOTS_MIGRATION glm
        WHERE  table_name = 'RCV_LOTS_SUPPLY'
        and    glm.transaction_id = rls.transaction_id
        and    glm.shipment_line_id = rls.shipment_line_id)
ORDER BY rls.transaction_id;

CURSOR CR_GET_LOT_SUPPLY_S IS
SELECT rlt.rowid,
       rsl.SHIPMENT_HEADER_ID shipment_header_id,
       rsl.SHIPMENT_LINE_ID shipment_line_id,
       rlt.lot_num lot_num,
       rlt.sublot_num,
       rsl.item_id,
       rsl.to_organization_id organization_id,
       rsl.to_subinventory subinventory,
       rsl.locator_id locator_id,
       rlt.reason_code reason_code,
       rlt.transaction_id
from   rcv_lots_supply rlt ,
       rcv_shipment_lines rsl,
       mtl_parameters mp
WHERE  rlt.supply_type_code = 'SHIPMENT'
and    rsl.shipment_line_id = rlt.shipment_line_id
and    (rlt.sublot_num <> '-1' or rlt.sublot_num is NULL)
AND    mp.organization_id = rsl.to_organization_id
AND    mp.process_enabled_flag = 'Y'
/*and not exists
      (SELECT 'x' from GML_RCV_LOTS_MIGRATION glm
       WHERE  table_name = 'RCV_LOTS_SUPPLY'
         And glm.shipment_line_id = rls.shipment_line_id)*/
ORDER BY rsl.shipment_line_id
FOR UPDATE OF LOT_NUM;

l_lot_num        VARCHAR2(80);
l_parent_lot_num VARCHAR2(80);
l_count          NUMBER;

l_reason_id      NUMBER;
rcv_lot_supply_data_err EXCEPTION;

cr_rec           CR_GET_LOT_SUPPLY%ROWTYPE;
cr_rec1          CR_GET_LOT_SUPPLY_S%ROWTYPE;
l_errm           VARCHAR2(2000);

BEGIN

   FOR cr_rec IN cr_get_lot_supply LOOP
     BEGIN
      INV_OPM_LOT_MIGRATION.GET_ODM_LOT(
        P_MIGRATION_RUN_ID     => 1,
        P_INVENTORY_ITEM_ID    => cr_rec.item_id,
        P_LOT_NO               => cr_rec.lot_num,
        P_SUBLOT_NO            => cr_rec.sublot_num,
        P_ORGANIZATION_ID      => cr_rec.organization_id,
        P_LOCATOR_ID           => cr_rec.locator_id,
        P_COMMIT               => 'Y',
        X_LOT_NUMBER           => l_lot_num,
        X_PARENT_LOT_NUMBER    => l_parent_lot_num,
        X_FAILURE_COUNT        => l_count
        );

      IF cr_rec.reason_code IS NOT NULL THEN
         Select reason_id
         into l_reason_id
         from mtl_transaction_reasons
         where reason_name = cr_rec.reason_code;
      END IF;

      --Call INVENTORY API that returns the new Lot number for the item, organization, lot, sublot,
      --   Subinventory and Locator
      --For any errors raise exception rcv_lot_transactions_data;

      UPDATE rcv_lots_supply
      SET    LOT_NUM = l_lot_num,
             REASON_ID = l_reason_id
      WHERE  rowid = cr_rec.rowid;

      INSERT INTO GML_RCV_LOTS_MIGRATION
         ( TABLE_NAME,
           TRANSACTION_ID,
           SOURCE_TRANSACTION_ID,
           SHIPMENT_LINE_ID,
           CORRECTION_TRANSACTION_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE)
      VALUES ( 'RCV_LOTS_SUPPLY',
           cr_rec.transaction_id,
           NULL,
           cr_rec.shipment_line_id,
           NULL,
           1,
           sysdate,
           1,
           sysdate);

      EXCEPTION
           WHEN OTHERS THEN
            l_errm := sqlerrm;
            insert into gml_po_mig_errors
				(migration_type,po_header_id,po_line_id,line_location_id,
				 transaction_id, shipment_header_id,shipment_line_id,
				 column_name,table_name,error_message,
				 creation_date,last_update_date)
			values ('CONVERGENCE',NULL, NULL, NULL,
				cr_rec.transaction_id, cr_rec.shipment_header_id, cr_rec.shipment_line_id,
				'LOT_NUM','RCV_LOT_SUPPLY',
				'ERROR DERIVING LOT_NUM-'||substr(l_errm,1,1975),sysdate,sysdate);
     END;
   END LOOP;
  COMMIT;


   FOR cr_rec1 IN cr_get_lot_supply_s LOOP
     BEGIN
      INV_OPM_LOT_MIGRATION.GET_ODM_LOT(
        P_MIGRATION_RUN_ID     => 1,
        P_INVENTORY_ITEM_ID    => cr_rec1.item_id,
        P_LOT_NO               => cr_rec1.lot_num,
        P_SUBLOT_NO            => cr_rec1.sublot_num,
        P_ORGANIZATION_ID      => cr_rec1.organization_id,
        P_LOCATOR_ID           => cr_rec1.locator_id,
        P_COMMIT               => 'Y',
        X_LOT_NUMBER           => l_lot_num,
        X_PARENT_LOT_NUMBER    => l_parent_lot_num,
        X_FAILURE_COUNT        => l_count
        );

      IF cr_rec1.reason_code IS NOT NULL THEN
         Select reason_id
         into l_reason_id
         from mtl_transaction_reasons
         where reason_name = cr_rec1.reason_code;
      END IF;

      --Call INVENTORY API that returns the new Lot number for the item, organization, lot, sublot,
      --   Subinventory and Locator
      --For any errors raise exception rcv_lot_transactions_data;

      UPDATE rcv_lots_supply
      SET    LOT_NUM = l_lot_num,
             REASON_ID = l_reason_id
      WHERE  rowid = cr_rec1.rowid;

      INSERT INTO GML_RCV_LOTS_MIGRATION
         ( TABLE_NAME,
           TRANSACTION_ID,
           SOURCE_TRANSACTION_ID,
           SHIPMENT_LINE_ID,
           CORRECTION_TRANSACTION_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE)
      VALUES ( 'RCV_LOTS_SUPPLY',
           cr_rec1.transaction_id,
           NULL,
           cr_rec1.shipment_line_id,
           NULL,
           1,
           sysdate,
           1,
           sysdate);

      EXCEPTION
           --WHEN rcv_lot_supply_data_err THEN
           WHEN OTHERS THEN
            l_errm := sqlerrm;
            insert into gml_po_mig_errors
				(migration_type,po_header_id,po_line_id,line_location_id,
				 transaction_id, shipment_header_id,shipment_line_id,
				 column_name,table_name,error_message,
				 creation_date,last_update_date)
			values ('CONVERGENCE',NULL, NULL, NULL,
				NULL, cr_rec1.shipment_header_id, cr_rec1.shipment_line_id,
				'LOT_NUM','RCV_LOT_SUPPLY',
				'ERROR DERIVING LOT_NUM-'||substr(l_errm,1,1975),sysdate,sysdate);
     END;
   END LOOP;
  COMMIT;
END Update_rcv_lots_supply;

END RCV_GML_CONV_MIG;


/
