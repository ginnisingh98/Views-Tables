--------------------------------------------------------
--  DDL for Package Body OKE_PA_MDS_RELIEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_PA_MDS_RELIEF_PKG" AS
/* $Header: OKEVMDSB.pls 120.0 2005/05/25 17:34:01 appldev noship $ */

Procedure write_log ( mesg  IN   VARCHAR2 ) IS
Begin
  fnd_file.put_line( fnd_file.log , mesg );
End write_log;


Procedure Get_Record (x_mds_tbl IN OUT NOCOPY oke_pa_mds_relief_pkg.mds_tbl_type) Is

  Cursor Oke_C Is

    Select a.transaction_id
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
    ,      d.reference2
    ,      b.quantity
    ,      b.source_header_id
    ,      d.task_id
    ,      b.unit_number
    From   mtl_system_items c
    ,      mtl_material_transactions a
    , 	   oke_deliverables_b b
    ,      oke_deliverable_actions d
    ,      mrp_schedule_dates m
    where a.source_code = 'OKE'
    And a.organization_id = c.organization_id
    And a.inventory_item_id = c.inventory_item_id
    And a.primary_quantity < 0
    And a.transaction_source_type_id = 16
--    And a.transaction_source_id = b.source_header_id bug 3863976
    And a.transaction_source_id = -99   -- bug 3863976
    And b.deliverable_id = d.deliverable_id
    And b.source_code = 'PA'
    And d.action_id = a.source_line_id
    And m.mps_transaction_id = d.reference2
    And m.schedule_level = 2
    And m.supply_demand_type = 1
    And m.schedule_quantity > 0
    And a.transaction_id > nvl( m.old_transaction_id , 0 )
    Order by a.transaction_id asc;

    l_mds_tbl oke_pa_mds_relief_pkg.mds_tbl_type;
    l_found Boolean := False;
    i Number := 1;

Begin

  For c_rec in oke_c loop

    l_mds_tbl(i).mtl_transaction_id         := c_rec.transaction_id;
    l_mds_tbl(i).organization_id            := c_rec.organization_id;
    l_mds_tbl(i).inventory_item_id          := c_rec.inventory_item_id;
    l_mds_tbl(i).transaction_source_id      := c_rec.transaction_source_id;
    l_mds_tbl(i).transaction_source_type_id := c_rec.transaction_source_type_id;

    l_mds_tbl(i).trx_source_delivery_id     := c_rec.trx_source_delivery_id;
    l_mds_tbl(i).trx_source_line_id         := c_rec.trx_source_line_id;
    l_mds_tbl(i).revision                   := c_rec.revision;
    l_mds_tbl(i).subinventory_code          := c_rec.subinventory_code;
    l_mds_tbl(i).locator_id                 := c_rec.locator_id;

    l_mds_tbl(i).primary_quantity           := c_rec.primary_quantity;
    l_mds_tbl(i).transaction_quantity       := c_rec.transaction_quantity;
    l_mds_tbl(i).transaction_source_name    := c_rec.transaction_source_name;
    l_mds_tbl(i).transaction_date           := c_rec.transaction_date;
    l_mds_tbl(i).mps_transaction_id         := c_rec.reference2;

    l_mds_tbl(i).order_quantity             := c_rec.quantity;
    l_mds_tbl(i).project_id                 := c_rec.source_header_id;
    l_mds_tbl(i).task_id                    := c_rec.task_id;
    l_mds_tbl(i).unit_number                := c_rec.unit_number;

    i := i + 1;

  end loop;

  x_mds_tbl := l_mds_tbl;

end Get_Record;


Procedure Mds_Relief
( ERRBUF                           OUT NOCOPY    VARCHAR2
, RETCODE                          OUT NOCOPY    NUMBER
) Is

  l_mds_tbl oke_pa_mds_relief_pkg.mds_tbl_type;
  l_transaction_id Number;
  l_qty Number;
  l_qty_old Number;
  l_schedule_date Date;
  i Number;
  l_return_status Varchar2(1) := oke_api.g_ret_sts_success;
  l_found Boolean := True;
  l_api_name Varchar2(30) := 'MDS Relief';
  l_api_version Number := 1;
  L_Error_Buf  VARCHAR2(4000);
  l_old_transaction_id Number;
  l_disposition_id Number;
  l_value Number;

  Cursor qty_c Is
    Select schedule_quantity, schedule_date, old_transaction_id
    From Mrp_Schedule_Dates
    Where mps_transaction_id = l_transaction_id
    And Schedule_Level = 2
    And Schedule_Quantity > 0
    For Update Of schedule_quantity;

  Cursor c Is
    Select count(*) from mrp_schedule_consumptions
    Where disposition_id = l_disposition_id;

Begin

  Get_Record(l_mds_tbl);

  If l_mds_tbl.count > 0 Then

    i := l_mds_tbl.FIRST;
    loop

      write_log( 'Processing transaction ' || l_mds_tbl(i).mtl_transaction_id );
      write_log( 'MDS Txn ID ......... ' || l_mds_tbl(i).mps_transaction_id );

      l_transaction_id := l_mds_tbl(i).mps_transaction_id;

      for qty_rec in qty_c loop

        l_qty := qty_rec.schedule_quantity;
        l_schedule_date := qty_rec.schedule_date;
        l_old_transaction_id := qty_rec.old_transaction_id;

        l_qty_old := l_qty;

        if l_qty > l_mds_tbl(i).primary_quantity * (-1) then
          l_qty := l_qty + l_mds_tbl(i).primary_quantity;
        else
          l_qty := 0;
        end if;

        write_log( 'Original MDS qty ... ' || l_qty_old );
        write_log( 'Shipment qty ....... ' || (-1) * l_mds_tbl(i).primary_quantity );
        write_log( 'New MDS qty ........ ' || l_qty );

        if l_mds_tbl(i).mtl_transaction_id > nvl(l_old_transaction_id, 0) then

          update mrp_schedule_dates
          set schedule_quantity = l_qty,
              last_update_date = sysdate,
              last_updated_by = fnd_global.user_id,
              request_id = fnd_global.conc_request_id,
              program_application_id = fnd_global.prog_appl_id,
              program_id = fnd_global.conc_program_id,
              program_update_date = sysdate,
              old_transaction_id = l_mds_tbl(i).mtl_transaction_id
          where mps_transaction_id = l_mds_tbl(i).mps_transaction_id
          and schedule_level = 2;

          write_log( 'MDS entry updated' );

          INSERT INTO mrp_schedule_consumptions
          (transaction_id,
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
           schedule_date)
          VALUES
          (
           l_mds_tbl(i).mps_transaction_id,
           1,  -- MDS_RELIEF 1, MPS_RELIEF 2
           3,  -- R_WORK_ORDER 1, R_PURCH_ORDER 2, R_SALES_ORDER 3
           null, -- l_mds_tbl(i).mtl_transaction_id,
           null, -- No order line_num
           SYSDATE,
           fnd_global.user_id,
           SYSDATE,
           fnd_global.user_id,
           fnd_global.login_id,
           fnd_global.conc_request_id,
           fnd_global.prog_appl_id,
           fnd_global.conc_program_id,
           SYSDATE,
           l_mds_tbl(i).transaction_date,
           l_mds_tbl(i).order_quantity,
           l_mds_tbl(i).primary_quantity * -1,
           l_schedule_date);

          write_log( 'Relief record created' );

        end if;

        write_log( '' );

      END loop;

      --
      -- Invoke customer extension
      --
      -- OKE_MDS_RELIEF_EXT.Relief_Demand( P_mds_rec => l_mds_tbl(i) );

      EXIT WHEN i = l_mds_tbl.LAST;
      i := l_mds_tbl.NEXT(i);
    END LOOP;
  END IF;

  write_log( l_mds_tbl.count || ' transactions processed.' );

  RETCODE := 0;

EXCEPTION
WHEN OTHERS THEN
  ERRBUF := L_Error_Buf;
  RETCODE := 2;

END Mds_Relief;

END OKE_PA_MDS_RELIEF_PKG;

/
