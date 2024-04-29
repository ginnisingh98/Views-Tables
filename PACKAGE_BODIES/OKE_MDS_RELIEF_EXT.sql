--------------------------------------------------------
--  DDL for Package Body OKE_MDS_RELIEF_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_MDS_RELIEF_EXT" AS
/* $Header: OKEXMRFB.pls 115.0 2002/12/04 08:45:26 alaw noship $ */

Procedure write_log ( mesg  IN   VARCHAR2 ) IS
Begin
  fnd_file.put_line( fnd_file.log , mesg );
End write_log;


--
--  Name          : Relief_Demand
--  Pre-reqs      :
--  Function      : This function returns the cost of sales account
--                  for a given shipping delivery detail
--
--
--  Parameters    :
--  IN            : P_MDS_Rec               OKE_MDS_RELIEF_PKG.mds_rec_type
--
--  OUT           : None
--
--  Returns       : None
--

PROCEDURE Relief_Demand
( P_MDS_Rec                 IN          OKE_MDS_RELIEF_PKG.mds_rec_type
) IS

  --
  -- This cursor selects MDS schedules in a given organization.
  --
  -- You can modify the matching conditions to meet your requirements,
  -- for example, searching for one or more specific MDS schedules.
  --
  CURSOR p IS
    SELECT schedule_designator
    FROM   mrp_schedule_designators s
    WHERE  organization_id = P_mds_rec.organization_id
    AND    schedule_type = 1
    AND    nvl(disable_date , trunc(sysdate) + 1) > trunc(sysdate)
    AND NOT EXISTS (
        SELECT null
        FROM   mrp_schedule_dates
        WHERE  mps_transaction_id = P_mds_rec.mps_transaction_id
        AND    schedule_designator = s.schedule_designator )
    /*
    AND    schedule_designator IN ('<schedule 1>' , '<schedule 2'>)
    */
    ORDER BY schedule_designator;

  --
  -- This cursor selects MDS entries for a given MDS that matches the
  -- original demand that is being processed.  The entry represented
  -- by the value in MPS_TRANSACTION_ID is already processed by the base
  -- program so there is no need to re-relieve the same demand.
  --
  -- You can modify the matching conditions to meet your requirements.
  --
  CURSOR e ( X_schedule_designator  VARCHAR2 ) IS
    SELECT mps_transaction_id
    ,      schedule_quantity
    FROM   mrp_schedule_dates
    WHERE  schedule_designator  = X_schedule_designator
    AND    organization_id      = P_mds_rec.organization_id
    AND    inventory_item_id    = P_mds_rec.inventory_item_id
    AND    mps_transaction_id  <> P_mds_rec.mps_transaction_id
    AND    schedule_date        = P_mds_rec.transaction_date
    AND    project_id           = P_mds_rec.project_id
    AND    task_id              = P_mds_rec.task_id
    AND    end_item_unit_number = P_mds_rec.unit_number
    AND    schedule_level       = 2
    AND    schedule_quantity    > 0
    ORDER BY schedule_date , mps_transaction_id
    FOR UPDATE OF schedule_quantity;

  l_remain_qty       number;
  l_relief_qty       number;
  l_new_demand_qty   number;

BEGIN
  --
  -- To enable this extension, please comment the following return
  -- statement and make the necessary changes to the sample processing
  -- logic.
  --
  return;

  write_log( '+++ Invoking custom extension...' );

  for prec in p loop

    write_log( '+++ Processing schedule ' || prec.schedule_designator );

    l_remain_qty := (-1) * P_mds_rec.primary_quantity;

    for erec in e ( prec.schedule_designator ) loop

      write_log( '+++ MDS Txn ID ......... ' || erec.mps_transaction_id );
      --
      -- The following logic determines the quantity to be relieved.
      -- If the shipment quantity is greater than the remaining schedule
      -- quantity, then the lesser of the two is used.
      --
      if ( erec.schedule_quantity < l_remain_qty ) then
	l_relief_qty := erec.schedule_quantity;
      else
	l_relief_qty := l_remain_qty;
      end if;
      l_new_demand_qty := erec.schedule_quantity - l_relief_qty;

      write_log( '+++ Original MDS qty ... ' || erec.schedule_quantity );
      write_log( '+++ Relief qty ......... ' || l_relief_qty );
      write_log( '+++ New MDS qty ........ ' || l_new_demand_qty );

      --
      -- The following updates the MDS record with the new quantity
      --
      update mrp_schedule_dates
      set schedule_quantity      = l_new_demand_qty
      ,   last_update_date       = sysdate
      ,   last_updated_by        = fnd_global.user_id
      ,   request_id             = fnd_global.conc_request_id
      ,   program_application_id = fnd_global.prog_appl_id
      ,   program_id             = fnd_global.conc_program_id
      ,   program_update_date    = sysdate
      where mps_transaction_id = erec.mps_transaction_id
      and schedule_level = 2;

      write_log( '+++ MDS entry updated' );

      --
      -- The following creates the relief record.  The relief quantity
      -- is based on the entire shipment quantity, not the actual
      -- quantity relieved as calculated previously.
      --
      INSERT INTO mrp_schedule_consumptions
      ( transaction_id
      , relief_type
      , disposition_type
      , disposition_id
      , line_num
      , last_update_date
      , last_updated_by
      , creation_date
      , created_by
      , last_update_login
      , request_id
      , program_application_id
      , program_id
      , program_update_date
      , order_date
      , order_quantity
      , relief_quantity
      , schedule_date
      ) VALUES
      ( erec.mps_transaction_id
      , 1           -- MDS_RELIEF 1, MPS_RELIEF 2
      , 3           -- R_WORK_ORDER 1, R_PURCH_ORDER 2, R_SALES_ORDER 3
      , null
      , null
      , sysdate
      , fnd_global.user_id
      , sysdate
      , fnd_global.user_id
      , fnd_global.login_id
      , fnd_global.conc_request_id
      , fnd_global.prog_appl_id
      , fnd_global.conc_program_id
      , sysdate
      , P_mds_rec.transaction_date
      , P_mds_rec.order_quantity
      , l_relief_qty
      , P_mds_rec.transaction_date
      );

      write_log( '+++ Relief record created' );

      l_remain_qty := l_remain_qty - l_relief_qty;

      EXIT WHEN l_remain_qty = 0;

    end loop; -- cursor e

    write_log( '+++ Done processing schedule ' || prec.schedule_designator );

  end loop; -- cursor p

  write_log( '+++ End of custom extension' || fnd_global.newline );

END Relief_Demand;

END OKE_MDS_RELIEF_EXT;

/
