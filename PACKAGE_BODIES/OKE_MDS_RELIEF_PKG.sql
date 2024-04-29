--------------------------------------------------------
--  DDL for Package Body OKE_MDS_RELIEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_MDS_RELIEF_PKG" AS
/* $Header: OKEMDSFB.pls 120.2 2006/03/16 14:56:45 ausmani noship $ */

PROCEDURE write_log ( mesg  IN   VARCHAR2 ) IS
BEGIN
  fnd_file.put_line( fnd_file.log , mesg );
END write_log;


PROCEDURE Get_Record (x_mds_tbl IN OUT NOCOPY oke_mds_relief_pkg.mds_tbl_type) IS

  CURSOR Oke_C IS

    SELECT a.transaction_id
    ,      a.organization_id
    ,      a.inventory_item_id
    ,      nvl(a.transaction_source_id , 0) transaction_source_id
    ,      a.transaction_source_type_id
    ,      a.trx_source_delivery_id
    ,      a.trx_source_line_id
    ,      a.revision
    ,      a.subinventory_code
    ,      a.locator_id
    ,      a.primary_quantity
    ,      a.transaction_quantity
    ,      a.transaction_source_name
    ,      a.transaction_date
    ,      d.mps_transaction_id
    ,      d.quantity
    ,      d.project_id
    ,      d.task_id
    ,      d.unit_number
    FROM   mtl_system_items c
    ,      mtl_material_transactions a
    ,      oke_k_deliverables_b d
    ,      mrp_schedule_dates m
    WHERE a.source_code = 'OKE'
    AND a.organization_id = c.organization_id
    AND a.inventory_item_id = c.inventory_item_id
    AND a.primary_quantity < 0
    AND a.transaction_source_type_id = 16
    AND a.transaction_source_id = d.k_header_id
    AND d.deliverable_id = a.source_line_id
    And m.mps_transaction_id = d.mps_transaction_id
    And m.schedule_level = 2
    And m.supply_demand_type = 1
    And m.schedule_quantity > 0
    AND a.transaction_id > nvl( d.po_ref_3 , 0 )
    ORDER BY a.transaction_id ASC;

    i NUMBER := 1;

BEGIN

  x_mds_tbl.DELETE;

  FOR c_rec IN oke_c LOOP

    x_mds_tbl(i).mtl_transaction_id         := c_rec.transaction_id;
    x_mds_tbl(i).organization_id            := c_rec.organization_id;
    x_mds_tbl(i).inventory_item_id          := c_rec.inventory_item_id;
    x_mds_tbl(i).transaction_source_id      := c_rec.transaction_source_id;
    x_mds_tbl(i).transaction_source_type_id := c_rec.transaction_source_type_id;

    x_mds_tbl(i).trx_source_delivery_id     := c_rec.trx_source_delivery_id;
    x_mds_tbl(i).trx_source_line_id         := c_rec.trx_source_line_id;
    x_mds_tbl(i).revision                   := c_rec.revision;
    x_mds_tbl(i).subinventory_code          := c_rec.subinventory_code;
    x_mds_tbl(i).locator_id                 := c_rec.locator_id;

    x_mds_tbl(i).primary_quantity           := c_rec.primary_quantity;
    x_mds_tbl(i).transaction_quantity       := c_rec.transaction_quantity;
    x_mds_tbl(i).transaction_source_name    := c_rec.transaction_source_name;
    x_mds_tbl(i).transaction_date           := c_rec.transaction_date;
    x_mds_tbl(i).mps_transaction_id         := c_rec.mps_transaction_id;

    x_mds_tbl(i).order_quantity             := c_rec.quantity;
    x_mds_tbl(i).project_id                 := c_rec.project_id;
    x_mds_tbl(i).task_id                    := c_rec.task_id;
    x_mds_tbl(i).unit_number                := c_rec.unit_number;

    i := i + 1;

  END LOOP;

END Get_Record;


PROCEDURE Mds_Relief
( ERRBUF                           OUT NOCOPY    VARCHAR2
, RETCODE                          OUT NOCOPY    NUMBER
) IS

  l_mds_tbl oke_mds_relief_pkg.mds_tbl_type;
  l_transaction_id NUMBER;
  l_count NUMBER := 0;
  l_qty NUMBER;
  l_schedule_date DATE;
  i NUMBER;
  l_now DATE := SYSDATE;
  l_user_id NUMBER := fnd_global.user_id;
  l_login_id NUMBER := fnd_global.login_id;
  l_conc_request_id NUMBER := fnd_global.conc_request_id;
  l_prog_appl_id NUMBER := fnd_global.prog_appl_id;
  l_conc_program_id NUMBER := fnd_global.conc_program_id;

  CURSOR qty_c (p_transaction_id NUMBER) IS
    SELECT schedule_quantity, original_schedule_quantity, schedule_date
    FROM Mrp_Schedule_Dates
    WHERE mps_transaction_id = p_transaction_id
    AND Schedule_Level = 2
    AND supply_demand_type = 1
    AND Schedule_Quantity > 0
    FOR UPDATE OF schedule_quantity;

  CURSOR get_cancelled_line IS
  SELECT   d.mps_transaction_id
    ,      d.quantity
    ,      d.project_id
    ,      d.task_id
    ,      d.unit_number
    ,      m.schedule_quantity
    ,      m.schedule_date
    FROM   okc_k_lines_b a
    ,      oke_k_deliverables_b d
    ,      mrp_schedule_dates m
    ,      okc_statuses_b sts
    WHERE d.k_line_id = a.id
    And m.mps_transaction_id = d.mps_transaction_id
    And m.schedule_level = 2
    And m.supply_demand_type = 1
    And m.schedule_quantity > 0
    And sts.code =a.sts_code
    And sts.ste_code in ( 'CANCELLED','TERMINATED');
BEGIN

  Get_Record(l_mds_tbl);

  IF l_mds_tbl.count > 0 THEN

    FOR i IN l_mds_tbl.FIRST..l_mds_tbl.LAST LOOP

      write_log( 'Processing MTL transaction ' || l_mds_tbl(i).mtl_transaction_id );
      write_log( 'MDS Txn ID ......... ' || l_mds_tbl(i).mps_transaction_id );

      FOR qty_rec IN qty_c(l_mds_tbl(i).mps_transaction_id) LOOP

        l_qty := qty_rec.schedule_quantity;
        l_schedule_date := qty_rec.schedule_date;

        write_log( 'Original MDS qty ... ' || qty_rec.original_schedule_quantity );
        write_log( 'Deliverable qty ... ' || l_mds_tbl(i).order_quantity );
        write_log( 'Old MDS qty ... ' || qty_rec.schedule_quantity );
        write_log( 'Shipment qty ....... ' || -l_mds_tbl(i).primary_quantity );

        INSERT INTO mrp_schedule_consumptions(
           transaction_id,
           relief_type,
           disposition_type,
           disposition_id,
           line_num,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           order_date,
           order_quantity,
           relief_quantity,
           schedule_date
        ) VALUES (
           l_mds_tbl(i).mps_transaction_id,
           1,  -- MDS_RELIEF 1, MPS_RELIEF 2
           3,  -- R_WORK_ORDER 1, R_PURCH_ORDER 2, R_SALES_ORDER 3
           NULL, -- l_mds_tbl(i).mtl_transaction_id,
           NULL, -- No order line_num
           l_now,
           l_user_id,
           l_now,
           l_user_id,
           l_login_id,
           l_conc_request_id,
           l_prog_appl_id,
           l_conc_program_id,
           l_now,
           l_mds_tbl(i).transaction_date,
           l_mds_tbl(i).order_quantity,
          -l_mds_tbl(i).primary_quantity,
           l_schedule_date
        );

        write_log( 'Relief record created' );

        SELECT Greatest(Nvl(l_mds_tbl(i).order_quantity,0)-Nvl(SUM(RELIEF_QUANTITY),0),0)
          INTO l_qty
          FROM mrp_schedule_consumptions mc
          where mc.transaction_id = l_mds_tbl(i).mps_transaction_id
            AND mc.relief_type=1 AND mc.disposition_type=3
        ;

        write_log( 'New MDS qty ........ ' || l_qty );

        UPDATE mrp_schedule_dates d
          SET schedule_quantity = l_qty
          ,   original_schedule_quantity = l_mds_tbl(i).order_quantity
          ,   last_update_date       = l_now
          ,   last_updated_by        = l_user_id
          ,   request_id             = l_conc_request_id
          ,   program_application_id = l_prog_appl_id
          ,   program_id             = l_conc_program_id
          ,   program_update_date    = l_now
          WHERE CURRENT OF qty_c;

        write_log( 'MDS entry updated' );

        UPDATE oke_k_deliverables_b d
          SET PO_REF_3 = l_mds_tbl(i).mtl_transaction_id
          WHERE mps_transaction_id = l_mds_tbl(i).mps_transaction_id;

        write_log( 'DLV entry updated' );
        write_log( '' );

      END LOOP;

      --
      -- Invoke customer extension
      --
      OKE_MDS_RELIEF_EXT.Relief_Demand( P_mds_rec => l_mds_tbl(i) );

    END LOOP;
  END IF;

 write_log( l_mds_tbl.count || ' Material transactions processed.' );

  FOR cancel_rec IN get_cancelled_line LOOP
        l_count := l_count +1;
        write_log( 'MDS Txn ID ......... ' || cancel_rec.mps_transaction_id );
        write_log( 'cancel_rec.quantity ......... ' || cancel_rec.quantity );
         write_log( 'cancel_rec.schedule_date ......... ' || cancel_rec.schedule_date );
          write_log( 'cancel_rec.schedule_quantity ......... ' || cancel_rec.schedule_quantity );

     INSERT INTO mrp_schedule_consumptions(
           transaction_id,
           relief_type,
           disposition_type,
           disposition_id,
           line_num,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           order_date,
           order_quantity,
           relief_quantity,
           schedule_date
        ) VALUES (
           cancel_rec.mps_transaction_id,
           1,  -- MDS_RELIEF 1, MPS_RELIEF 2
           3,  -- R_WORK_ORDER 1, R_PURCH_ORDER 2, R_SALES_ORDER 3
           NULL, -- l_mds_tbl(i).mtl_transaction_id,
           NULL, -- No order line_num
           l_now,
           l_user_id,
           l_now,
           l_user_id,
           l_login_id,
           l_conc_request_id,
           l_prog_appl_id,
           l_conc_program_id,
           l_now,
           sysdate,
           cancel_rec.quantity,
           cancel_rec.schedule_quantity,
           cancel_rec.schedule_date
        );
     write_log( 'Relief record created' );

        SELECT Greatest(Nvl(cancel_rec.quantity,0)-Nvl(SUM(RELIEF_QUANTITY),0),0)
          INTO l_qty
          FROM mrp_schedule_consumptions mc
          where mc.transaction_id = cancel_rec.mps_transaction_id
            AND mc.relief_type=1 AND mc.disposition_type=3
        ;

        write_log( 'New MDS qty ........ ' || l_qty );

        UPDATE mrp_schedule_dates d
          SET schedule_quantity = l_qty
          ,   original_schedule_quantity = cancel_rec.quantity
          ,   last_update_date       = l_now
          ,   last_updated_by        = l_user_id
          ,   request_id             = l_conc_request_id
          ,   program_application_id = l_prog_appl_id
          ,   program_id             = l_conc_program_id
          ,   program_update_date    = l_now
          WHERE mps_transaction_id =cancel_rec.mps_transaction_id;

  end loop;


  write_log( l_count || ' Contract Line Cancellation/Termination processed.' );
  ERRBUF := NULL;
  RETCODE := 0;

EXCEPTION
WHEN OTHERS THEN
  ERRBUF := sqlerrm;
  RETCODE := 2;

END Mds_Relief;

END OKE_MDS_RELIEF_PKG;

/
