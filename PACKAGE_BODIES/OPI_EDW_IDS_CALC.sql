--------------------------------------------------------
--  DDL for Package Body OPI_EDW_IDS_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_IDS_CALC" as
/*$Header: OPIMPPBB.pls 120.1 2005/06/07 03:30:10 appldev  $*/

TYPE bal_rec IS RECORD
  ( beg_int_qty     opi_ids_push_log.beg_int_qty%TYPE,
    beg_int_val_b   opi_ids_push_log.beg_int_val_b%TYPE,
    beg_onh_qty     opi_ids_push_log.beg_onh_qty%TYPE,
    beg_onh_val_b   opi_ids_push_log.beg_onh_val_b%TYPE,
    beg_wip_qty     opi_ids_push_log.beg_wip_qty%TYPE,
    beg_wip_val_b   opi_ids_push_log.beg_wip_val_b%TYPE,
    end_int_qty     opi_ids_push_log.end_int_qty%TYPE,
    end_int_val_b   opi_ids_push_log.end_int_val_b%TYPE,
    end_onh_qty     opi_ids_push_log.end_onh_qty%TYPE,
    end_onh_val_b   opi_ids_push_log.end_onh_val_b%TYPE,
    end_wip_qty     opi_ids_push_log.end_wip_qty%TYPE,
    end_wip_val_b   opi_ids_push_log.end_wip_val_b%TYPE,
    trx_date        opi_ids_push_log.trx_date%TYPE,
    base_uom        opi_ids_push_log.base_uom%TYPE,
    item_status     opi_ids_push_log.item_status%TYPE,
    item_type       opi_ids_push_log.item_type%TYPE,
    nettable_flag   opi_ids_push_log.nettable_flag%TYPE
    );

TYPE key_rec IS RECORD
  (  inventory_item_id   opi_ids_push_log.inventory_item_id%TYPE,
     organization_id     opi_ids_push_log.organization_id%TYPE,
     cost_group_id       opi_ids_push_log.cost_group_id%TYPE,
     revision            opi_ids_push_log.revision%TYPE,
     lot_number          opi_ids_push_log.lot_number%TYPE,
     subinventory_code   opi_ids_push_log.subinventory_code%TYPE,
     locator_id          opi_ids_push_log.locator_id%TYPE,
     project_locator_id  opi_ids_push_log.project_locator_id%TYPE);

PROCEDURE update_ids_push_log (p_ids_key  VARCHAR2,
                   p_bal_rec  bal_rec  ) IS
BEGIN
   UPDATE opi_ids_push_log
     SET
     beg_int_qty    = p_bal_rec.end_int_qty,
     beg_int_val_b  = p_bal_rec.end_int_val_b,
     beg_onh_qty    = p_bal_rec.end_onh_qty,
     beg_onh_val_b  = p_bal_rec.end_onh_val_b,
     beg_wip_qty    = p_bal_rec.end_wip_qty,
     beg_wip_val_b  = p_bal_rec.end_wip_val_b,
     end_int_qty    = p_bal_rec.end_int_qty,
     end_int_val_b  = p_bal_rec.end_int_val_b,
     end_onh_qty    = p_bal_rec.end_onh_qty,
     end_onh_val_b  = p_bal_rec.end_onh_val_b,
     end_wip_qty    = p_bal_rec.end_wip_qty,
     end_wip_val_b  = p_bal_rec.end_wip_val_b,
     base_uom       = p_bal_rec.base_uom,
     item_status    = p_bal_rec.item_status,
     item_type      = p_bal_rec.item_type,
     nettable_flag  = p_bal_rec.nettable_flag,
     push_flag      =1
     WHERE ids_key = p_ids_key;

END update_ids_push_log;

PROCEDURE insert_ids_push_log ( p_ids_key      VARCHAR2,
                p_trx_date     DATE,
                p_period_flag  NUMBER,
                p_key          key_rec,
                p_bal_rec      bal_rec) IS
BEGIN

   --dbms_output.put_line('count = 1 ' || p_key.organization_id);

   INSERT INTO opi_ids_push_log
     (ids_key,
      cost_group_id,
      organization_id,
      inventory_item_id,
      revision,
      subinventory_code,
      locator_id,
      project_locator_id,
      lot_number,
      trx_date,
      period_flag,
      push_flag,
      beg_int_qty, beg_int_val_b,
      beg_onh_qty, beg_onh_val_b,
      beg_wip_qty, beg_wip_val_b,
      end_int_qty, end_int_val_b,
      end_onh_qty, end_onh_val_b,
      end_wip_qty, end_wip_val_b,
      base_uom,
      item_status,
      item_type,
      nettable_flag)
     VALUES
     ( p_ids_key,
       p_key.cost_group_id,
       p_key.organization_id,
       p_key.inventory_item_id,
       p_key.revision,
       p_key.subinventory_code,
       p_key.locator_id,
       p_key.project_locator_id,
       p_key.lot_number,
       p_trx_date,
       p_period_flag,
       1,
       p_bal_rec.end_int_qty, p_bal_rec.end_int_val_b,
       p_bal_rec.end_onh_qty, p_bal_rec.end_onh_val_b,
       p_bal_rec.end_wip_qty, p_bal_rec.end_wip_val_b,
       p_bal_rec.end_int_qty, p_bal_rec.end_int_val_b,
       p_bal_rec.end_onh_qty, p_bal_rec.end_onh_val_b,
       p_bal_rec.end_wip_qty, p_bal_rec.end_wip_val_b,
       p_bal_rec.base_uom,
       p_bal_rec.item_status,
       p_bal_rec.item_type,
       p_bal_rec.nettable_flag);
END insert_ids_push_log;


PROCEDURE calc_prd_start_end ( p_from_date DATE,
                   p_to_date   DATE,
                   p_organization_id NUMBER,
                   x_status OUT NOCOPY  NUMBER  ) IS

  cursor get_max_push_from_date_csr is
     select max( last_push_inv_txn_date), max(last_push_wip_txn_date)
    from opi_ids_push_date_log
    where organization_id = p_organization_id;

  l_inv_txn_date            date;
  l_wip_txn_date            date;
  l_from_date               date;

  CURSOR l_key_combs_csr (p_from_date DATE, p_to_date DATE) IS
     SELECT DISTINCT inventory_item_id,
       organization_id,
       cost_group_id,
       revision,
       lot_number,
       subinventory_code,
       locator_id,
       project_locator_id
       FROM opi_ids_push_log
       WHERE trx_date BETWEEN (p_from_date -1) AND p_to_date
       AND organization_id = p_organization_id;

  CURSOR l_extraction_periods_csr ( l_organization_id NUMBER) IS
     SELECT  Trunc(period_start_date) start_date,
       Trunc(schedule_close_date) end_date
       FROM org_acct_periods
       WHERE organization_id = l_organization_id
       AND (( period_start_date between p_from_date
        and p_to_date )
        OR( schedule_close_date between p_from_date
        and p_to_date )
            OR
              ( (p_from_date between period_start_date and schedule_close_date)
                AND (p_to_date between period_start_date and
                     schedule_close_date) )
        )
       ORDER BY start_date;

  CURSOR l_period_end_entry_csr ( l_ids_key VARCHAR2) IS
     SELECT beg_int_qty, beg_int_val_b,
       beg_onh_qty, beg_onh_val_b,
       beg_wip_qty, beg_wip_val_b,
       end_int_qty, end_int_val_b,
       end_onh_qty, end_onh_val_b,
       end_wip_qty, end_wip_val_b,
       trx_date, base_uom, item_status, item_type, nettable_flag
       FROM opi_ids_push_log
       WHERE ids_key     = l_ids_key
       AND period_flag   = 1;

  CURSOR l_period_start_entry_csr ( l_ids_key VARCHAR2,
                    l_period_flag NUMBER := 0 ) IS
     SELECT beg_int_qty, beg_int_val_b,
       beg_onh_qty, beg_onh_val_b,
       beg_wip_qty, beg_wip_val_b,
       end_int_qty, end_int_val_b,
       end_onh_qty, end_onh_val_b,
       end_wip_qty, end_wip_val_b,
       trx_date, base_uom, item_status, item_type, nettable_flag
       FROM opi_ids_push_log
       WHERE ids_key = l_ids_key;

  CURSOR l_latest_activity_csr (l_inventory_item_id NUMBER,
                l_organization_id   NUMBER,
                l_cost_group_id     NUMBER,
                l_revision          VARCHAR2,
                l_lot_number        VARCHAR2,
                l_subinventory_code VARCHAR2,
                l_locator_id        NUMBER,
                l_trx_start_date    DATE,
                l_trx_end_date      DATE    ) IS
     SELECT beg_int_qty, beg_int_val_b,
       beg_onh_qty, beg_onh_val_b,
       beg_wip_qty, beg_wip_val_b,
       end_int_qty, end_int_val_b,
       end_onh_qty, end_onh_val_b,
       end_wip_qty, end_wip_val_b,
       trx_date, base_uom, item_status, item_type, nettable_flag
       FROM opi_ids_push_log
       WHERE inventory_item_id = l_inventory_item_id
       AND organization_id     = l_organization_id
       AND Nvl(cost_group_id, -999)  = Nvl(l_cost_group_id, -999)
       AND Nvl(revision, '-999')            = Nvl(l_revision, '-999')
       AND Nvl(lot_number, '-999')          = Nvl(l_lot_number, '-999')
       AND Nvl(subinventory_code, '-999')   = Nvl(l_subinventory_code, '-999')
       AND Nvl(project_locator_id, -999)     = Nvl(l_locator_id, -999)
       AND trx_date IN ( SELECT MAX(trx_date)
             FROM opi_ids_push_log
             WHERE inventory_item_id = l_inventory_item_id
             AND organization_id     = l_organization_id
             AND Nvl(cost_group_id, -999)  = Nvl(l_cost_group_id, -999)
             AND Nvl(revision, '-999')            = Nvl(l_revision, '-999')
             AND Nvl(lot_number, '-999')          = Nvl(l_lot_number, '-999')
             AND Nvl(subinventory_code, '-999')   =
                    Nvl(l_subinventory_code, '-999')
             AND Nvl(project_locator_id, -999)    = Nvl(l_locator_id, -999)
             AND trx_date BETWEEN l_trx_start_date AND l_trx_end_date
             -- activity check
             AND ( (Nvl(beg_int_qty,0) - Nvl(end_int_qty,0)) <> 0
                   OR ( Nvl(beg_int_val_b,0) - Nvl(end_int_val_b,0)) <> 0
                   OR ( Nvl(beg_onh_qty,0) - Nvl(end_onh_qty,0) ) <> 0
                   OR ( Nvl(beg_onh_val_b,0) - Nvl(end_onh_val_b,0)) <> 0
                   OR ( Nvl(beg_wip_qty,0) - Nvl(end_wip_qty,0) ) <> 0
                   OR ( Nvl(beg_wip_val_b,0) - Nvl(end_wip_val_b,0)) <> 0
                   OR nvl(total_rec_qty,0) <> 0
                   OR nvl(total_rec_val_b, 0) <> 0
                       OR nvl(tot_issues_qty,0) <> 0
                   OR nvl(tot_issues_val_b,0) <> 0
                   OR Nvl(from_org_qty,0) <> 0
                   OR Nvl(from_org_val_b,0) <> 0
                   OR Nvl(inv_adj_qty,0) <> 0
                   OR Nvl(inv_adj_val_b,0) <> 0
                   OR Nvl(po_del_qty, 0) <> 0
                   OR Nvl(po_del_val_b, 0) <> 0
                   OR Nvl(to_org_qty,0) <> 0
                   OR Nvl(to_org_val_b,0) <> 0
                   OR Nvl(tot_cust_ship_qty,0) <> 0
                   OR Nvl(tot_cust_ship_val_b, 0) <> 0
                   OR Nvl(wip_assy_qty, 0) <> 0
                   OR Nvl(wip_assy_val_b,0) <> 0
                               OR Nvl(wip_comp_qty,0) <> 0
                               OR Nvl(wip_comp_val_b,0) <> 0
                               OR Nvl(wip_issue_qty,0) <> 0
                               OR Nvl(wip_issue_val_b,0) <> 0
                   )
             );

  CURSOR l_initial_period_prev_csr (l_start_date DATE,
                    l_end_date DATE,
                    l_organization_id NUMBER ) IS
     SELECT Trunc(MAX(period_start_date)) start_date,
       Trunc(MAX(schedule_close_date)) end_date
       FROM org_acct_periods
       WHERE organization_id = l_organization_id
       AND schedule_close_date <l_start_date
       GROUP BY organization_id;

  CURSOR l_period_flag_activity_csr (l_ids_key VARCHAR2) IS
     SELECT Decode( nvl(period_flag, 999), 999,999,
                                            -- no period start/end entry
            1)  period_start_flag,
       Decode( (Nvl(beg_int_qty,0) - Nvl(end_int_qty,0)), 0,
        Decode( ( Nvl(beg_int_val_b,0) - Nvl(end_int_val_b,0)), 0,
         Decode( ( Nvl(beg_onh_qty,0) - Nvl(end_onh_qty,0) ), 0,
          Decode( ( Nvl(beg_onh_val_b,0) - Nvl(end_onh_val_b,0)), 0,
           Decode( ( Nvl(beg_wip_qty,0) - Nvl(end_wip_qty,0) ), 0,
            Decode( ( Nvl(beg_wip_val_b,0) - Nvl(end_wip_val_b,0)), 0,
             decode( nvl(total_rec_qty,0), 0,
              decode( nvl(total_rec_val_b, 0), 0,
               decode( nvl(tot_issues_qty,0), 0,
                decode( nvl(tot_issues_val_b,0), 0,
                 Decode(Nvl(from_org_qty,0), 0,
                  Decode(Nvl(from_org_val_b,0),0,
                   Decode(Nvl(inv_adj_qty,0),0,
                    Decode(Nvl(inv_adj_val_b,0),0,
                     Decode(Nvl(po_del_qty, 0),0,
                      Decode(Nvl(po_del_val_b, 0),0,
                       Decode( Nvl(to_org_qty,0),0,
                        Decode( Nvl(to_org_val_b,0),0,
                         Decode( Nvl(tot_cust_ship_qty,0),0,
                          Decode( Nvl(tot_cust_ship_val_b, 0),0,
                           Decode( Nvl(wip_assy_qty, 0),0,
                            Decode( Nvl(wip_assy_val_b,0),0,
                             Decode( Nvl(wip_comp_qty,0),0,
                              Decode( Nvl(wip_comp_val_b,0),0,
                               Decode( Nvl(wip_issue_qty,0),0,
                                Decode( Nvl(wip_issue_val_b,0),0,
                                       0,  -- no activity at all
                       1), 1), 1), 1), 1), 1), 1), 1), 1), 1), 1), 1), 1), 1),1), 1),
                   1), 1), 1), 1), 1), 1), 1), 1), 1), 1) activity_flag
       FROM  opi_ids_push_log
       WHERE ids_key = l_ids_key;
  /*
         Decode(Nvl(beg_int_qty,0), 0,
          Decode(Nvl(beg_int_val_b,0), 0,
        Decode(Nvl(beg_onh_qty,0),0,
          Decode(Nvl(beg_onh_val_b, 0),0,
            Decode(Nvl(beg_wip_qty, 0),0,
              Decode(Nvl(beg_wip_val_b,0),0,
            Decode(Nvl(end_int_qty,0),0,
              Decode(Nvl(end_int_val_b,0),0,
                Decode(Nvl(end_onh_qty,0),0,
                      Decode(Nvl(end_onh_val_b, 0),0,
                Decode(Nvl(end_wip_qty, 0),0,
                  Decode(Nvl(end_wip_val_b,0),0,0, --no balance at all
                    1 ), 1), 1), 1), 1), 1), 1), 1), 1), 1), 1), 1) bal_flag
       */

  l_last_period             l_extraction_periods_csr%ROWTYPE;

  l_latest_activity_entry   bal_rec;  -- l_latest_activity_csr%ROWTYPE;
  l_activity_flag           BOOLEAN := FALSE;

  l_last_period_end_entry   bal_rec;  --l_period_end_entry_csr%ROWTYPE;
  l_period__entry   bal_rec;  --l_period_end_entry_csr%ROWTYPE;
  l_last_period_end_flag    NUMBER := 999;

  l_beg_inv_bal_prd_start_entry bal_rec; --l_period_end_entry_csr%ROWTYPE;


  l_period_end_flag         NUMBER := 999;
  l_end_activity_flag       NUMBER := 999;
  --l_period_end_bal_flag         NUMBER := 999;

  l_period_start_flag       number := 999;
  l_start_activity_flag     number := 999;
  --l_period_start_bal_flag   NUMBER := 999;

  l_beg_inv_bal_flag        NUMBER := 999;

  l_prd_start_ids_key       VARCHAR2(240);
  l_prd_end_ids_key         VARCHAR2(240);

  l_ids_key                 VARCHAR2(240);

  l_first_push_date         DATE;

  l_combs_start_date        DATE := NULL;
BEGIN
    x_status := 0;

    -- get the very first period start date for which the beg_inv_bal is created
    select Trunc( min(trx_date) )
      into l_first_push_date
      from opi_ids_push_log
      where organization_id = p_organization_id;

    open get_max_push_from_date_csr;
    fetch get_max_push_from_date_csr into l_inv_txn_date, l_wip_txn_date;
    close get_max_push_from_date_csr;

    select least(p_from_date,
                 nvl(l_inv_txn_date, to_date('01-12-3000','DD-MM-YYYY') ),
                 nvl(l_wip_txn_date, to_date('01-12-3000','DD-MM-YYYY') ) )
      into l_from_date
      from dual;

    edw_log.put_line('now in calc_prd_start_end for org ' || p_organization_id
            || ' start date ' || To_char(p_from_date,'DD-MON-YYYY hh24:mi:ss')
            || ' to end date ' ||To_char(p_to_date ,'DD-MON-YYYY hh24:mi:ss')
            || ' l_from_date ' ||To_char(l_from_date ,
                                         'DD-MON-YYYY hh24:mi:ss'));

    -- get the date to start collecting combinations from.
    -- Since we delete all lines past the from date, we need to know
    -- all the collections as the beginning of the period. However, if we
    -- are collecting from the start date, we have deleted all start date
    -- records. We might lose all combinations that have a prior balance
    -- but no activity in this period. So start at the period end of the
    -- latest period before the collection start date.
    -- The only exception is if this is the very first defined period.
    -- In that case, just pick the start of this period.
    BEGIN
        SELECT max (trunc (schedule_close_date))
          INTO l_combs_start_date
          FROM org_acct_periods
          WHERE organization_id = p_organization_id
            AND schedule_close_date < trunc (l_from_date);
        -- use < instead of <= since if the from date is a period end date,
        -- then everything has been truncated for this period.

        IF (l_combs_start_date IS NULL) THEN

            SELECT max (trunc (period_start_date))
              INTO l_combs_start_date
              FROM org_acct_periods
              WHERE organization_id = p_organization_id
                AND period_start_date <= trunc (l_from_date);
            -- only happens if there is no prior period defined. Just take
            -- the first period start date then.

        END IF;

    END;

    -- debug
--    DBMS_OUTPUT.ENABLE (1000000);

--    DBMS_OUTPUT.PUT_LINE ('Start: ' || p_from_date || '---'
--                          || 'End: ' || p_to_date);


    FOR l_key IN l_key_combs_csr (l_combs_start_date, p_to_date) LOOP

        l_last_period_end_flag := 0;
        l_last_period_end_entry := NULL;
        FOR l_period IN l_extraction_periods_csr(l_key.organization_id) LOOP

            -- for period_start entry ids_key
            l_prd_start_ids_key := l_period.start_date || '-'
            || l_key.inventory_item_id
            || '-' || l_key.organization_id || '-' || l_key.cost_group_id
            || '-' || l_key.revision || '-' || l_key.lot_number
            || '-' || l_key.subinventory_code ||'-'||l_key.project_locator_id ;

            -- for period_end entry ids_key
            l_prd_end_ids_key := l_period.end_date || '-'
                || l_key.inventory_item_id
                || '-' || l_key.organization_id || '-' || l_key.cost_group_id
                || '-' || l_key.revision || '-' || l_key.lot_number
                || '-' || l_key.subinventory_code ||'-'
                || l_key.project_locator_id ;

            /*
            edw_log.put_line(' l_prd_start_ids_key is '
                             || l_prd_start_ids_key );
            edw_log.put_line(' l_prd_end_ids_key is ' || l_prd_end_ids_key );

            edw_log.put_line('---period ' || l_extraction_periods_csr%rowcount
                || ' start date is '|| l_period.start_date || ' '
                || l_period.end_date || 'l_last_period_end_flag is'
                || l_last_period_end_flag || ' --- '
                || l_last_period_end_entry.end_int_val_b|| ' --- '
                || l_last_period_end_entry.end_onh_qty|| ' --- '
                || l_last_period_end_entry.end_onh_val_b|| ' --- '
                || l_last_period_end_entry.end_wip_qty|| ' --- '
                || l_last_period_end_entry.end_wip_val_b|| ' --- '
                || l_last_period_end_entry.end_int_qty|| ' --- '
                || l_last_period_end_entry.end_int_val_b|| ' --- '
                || l_last_period_end_entry.end_onh_qty|| ' --- '
                || l_last_period_end_entry.end_onh_val_b|| ' --- '
                || l_last_period_end_entry.end_wip_qty|| ' --- '
                || l_last_period_end_entry.end_wip_val_b );
            */

            -- 1). get the one period before the initial_period
            IF l_extraction_periods_csr%rowcount = 1 THEN
                -- 1a). get last period
                OPEN l_initial_period_prev_csr(l_period.start_date,
                                               l_period.end_date,
                                               l_key.organization_id);
                FETCH l_initial_period_prev_csr INTO l_last_period;
                CLOSE l_initial_period_prev_csr;

                -- 1b). check existence of last period_end entry
                l_ids_key := l_last_period.end_date || '-'
                            || l_key.inventory_item_id
                            || '-' || l_key.organization_id || '-'
                            || l_key.cost_group_id
                            || '-' || l_key.revision || '-'
                            || l_key.lot_number
                            || '-' || l_key.subinventory_code ||'-'
                            || l_key.project_locator_id ;

                OPEN l_period_end_entry_csr (l_ids_key);
                FETCH l_period_end_entry_csr INTO l_last_period_end_entry;

                IF l_period_end_entry_csr%notfound THEN
                    l_last_period_end_flag := 0;
                ELSE
                    l_last_period_end_flag := 1;
                END IF;
                CLOSE l_period_end_entry_csr;

                --edw_log.put_line(' l_Ids_key ' || l_ids_key );
                --edw_log.put_line(' l_last_period_end_flag is ' || l_last_period_end_flag );
            END IF;

            -- check existing of period_start entry
            OPEN l_period_flag_activity_csr (l_prd_start_ids_key );
            FETCH l_period_flag_activity_csr
              INTO l_period_start_flag,
                   l_start_activity_flag; --, l_period_start_bal_flag;

            IF l_period_flag_activity_csr%notfound THEN
                l_period_start_flag := 0;
                l_start_activity_flag := 0;
                --l_period_start_bal_flag := 0;
            END IF;
            CLOSE l_period_flag_activity_csr;

             -- check existing of period_end entry
            OPEN l_period_flag_activity_csr (l_prd_end_ids_key );
            FETCH l_period_flag_activity_csr
              INTO l_period_end_flag,
                   l_end_activity_flag ; --, l_period_end_bal_flag;

            IF l_period_flag_activity_csr%notfound THEN
                l_period_end_flag := 0;
                l_end_activity_flag := 0;
                -- l_period_end_bal_flag := 0;
            END IF;
            CLOSE l_period_flag_activity_csr;

            --edw_log.put_line(' l_period_start_flag is '
            --                 || l_period_start_flag || ' activity is '
            --                 || l_start_activity_flag );
            --edw_log.put_line(' l_period_end_flag is '
            --                 || l_period_end_flag || 'activity is '
            --                 || l_end_activity_flag);

            -- 2). check if there is activity within the period
            OPEN l_latest_activity_csr(l_key.inventory_item_id,
                                       l_key.organization_id,
                                       l_key.cost_group_id,
                                       l_key.revision,
                                       l_key.lot_number,
                                       l_key.subinventory_code,
                                       l_key.project_locator_id,
                                       l_period.start_date,
                                       l_period.end_date);
            FETCH l_latest_activity_csr INTO l_latest_activity_entry;
            IF l_latest_activity_csr%notfound THEN
                l_activity_flag := FALSE;
                --edw_log.put_line('l_activity_flag is false ' );

            ELSE
                l_activity_flag := TRUE;
                --edw_log.put_line(' l_activity_flag is true '
                --                 || 'trx_date is '
                --                 || l_latest_activity_entry.trx_date );

            END IF;
            CLOSE l_latest_activity_csr;


            -- There is activity within the period
            IF l_activity_flag THEN
                IF l_last_period_end_flag <> 1 THEN
                    IF l_period_start_flag <> 1 THEN
                        IF  l_start_activity_flag <>1
                        AND l_period_start_flag <> 999 THEN

                            INSERT INTO opi_ids_push_log
                                (ids_key, cost_group_id,
                                 organization_id,inventory_item_id,
                                 revision, subinventory_code,
                                 locator_id, project_locator_id,
                                 lot_number, trx_date,
                                 period_flag, push_flag,
                                 beg_int_qty, beg_int_val_b,
                                 beg_onh_qty, beg_onh_val_b,
                                 beg_wip_qty, beg_wip_val_b,
                                 end_int_qty, end_int_val_b,
                                 end_onh_qty, end_onh_val_b,
                                 end_wip_qty, end_wip_val_b,
                                 base_uom, item_status,
                                 item_type,nettable_flag)
                            VALUES
                                ( l_prd_start_ids_key, l_key.cost_group_id,
                                  l_key.organization_id,
                                  l_key.inventory_item_id,
                                  l_key.revision, l_key.subinventory_code,
                                  l_key.locator_id, l_key.project_locator_id,
                                  l_key.lot_number, l_period.start_date,
                                  0, 1, 0,0,0,0,0,0, 0,0,0,0,0,0,
                                  l_latest_activity_entry.base_uom,
                                  l_latest_activity_entry.item_status,
                                  l_latest_activity_entry.item_type,
                                  l_latest_activity_entry.nettable_flag);

                            --edw_log.put_line('1 start no/no insert');

                        ELSE
                            -- if l_start_activity_flag = 1,
                            --    we have activity on start date-> update
                            -- if l_period_start_flag = 999,
                            --    we have beg_inv_bal entry on start_date --> update
                            UPDATE opi_ids_push_log
                              SET period_flag = 0,
                                  push_flag =1
                              WHERE ids_key = l_prd_start_ids_key;

                            --edw_log.put_line('1 start update');
                        END IF;

                        l_period_start_flag := 1;
                    ELSE -- l_period_start_flag = 1
                        IF l_start_activity_flag <>1 THEN
                            -- update existing period_start_entry with 0s
                            -- if the entry is not for the beg_inv_val
                            -- entry
                            IF l_period.start_date <> l_first_push_date
                            THEN
                                UPDATE opi_ids_push_log
                                  SET
                                    beg_int_qty    = 0,
                                    beg_int_val_b  = 0,
                                    beg_onh_qty    = 0,
                                    beg_onh_val_b  = 0,
                                    beg_wip_qty    = 0,
                                    beg_wip_val_b  = 0,
                                    end_int_qty    = 0,
                                    end_int_val_b  = 0,
                                    end_onh_qty    = 0,
                                    end_onh_val_b  = 0,
                                    end_wip_qty    = 0,
                                    end_wip_val_b  = 0,
                                    base_uom       =
                                        l_latest_activity_entry.base_uom,
                                    item_status    =
                                        l_latest_activity_entry.item_status,
                                    item_type      =
                                        l_latest_activity_entry.item_type,
                                    nettable_flag  =
                                        l_latest_activity_entry.nettable_flag,
                                    push_flag      = 1
                                  WHERE ids_key = l_prd_start_ids_key;
                            END IF;
                            --edw_log.put_line('1 start update 2');
                            -- ELSE do nothing;
                        END IF;
                    END IF;
                ELSE  -- the key combo does exist in previous period
                    IF l_period_start_flag <> 1 THEN
                        IF l_start_activity_flag <> 1 THEN
                        -- no activity on period_start
                        -- create one by copying the one last
                        -- period_end entry
                            IF l_period_start_flag = 0 THEN
                                insert_ids_push_log(l_prd_start_ids_key,
                                                    l_period.start_date,
                                                    0, -- p_period_flag
                                                    l_key,
                                                    l_last_period_end_entry );

                            --edw_log.put_line('1 start insert 2');

                            ELSIF l_period_start_flag = 999 THEN
                                UPDATE opi_ids_push_log
                                  SET period_flag = 0,
                                      push_flag =1
                                  WHERE ids_key = l_prd_start_ids_key;
                            END IF;
                        ELSE
                            -- activity on period_start, but
                            -- no period_start_entry
                            -- turn on the flag
                            UPDATE opi_ids_push_log
                              SET period_flag = 0,
                                  push_flag =1
                              WHERE ids_key = l_prd_start_ids_key;

                            --edw_log.put_line('1 start update 3');
                        END IF;
                        l_period_start_flag := 1;
                    ELSE -- period_start entry already existed
                        IF l_start_activity_flag <> 1 THEN
                            -- no activity on period_start
                            -- update existing one with numbers
                            -- from last period_end entry
                            update_ids_push_log(l_prd_start_ids_key,
                                                l_last_period_end_entry);

                            --edw_log.put_line('1 start update 4');
                        --ELSE do nothing
                        END IF;
                    END IF;
                END IF;  /* end of period_start entry */


                -- always calculate the period end entry
                IF l_period_end_flag = 1 THEN
                    -- period end entry exists
                    IF l_end_activity_flag <> 1 THEN
                        -- no activity on the period end date
                        -- update the existing period_end entry with
                        --    numbers from lastest activity entry

                        update_ids_push_log(l_prd_end_ids_key,
                                            l_latest_activity_entry);

                        --edw_log.put_line('1 end update');

                    --ELSE -- do nothing
                    END IF;
                ELSE -- period_entry doesn't exist yet
                    IF l_end_activity_flag <> 1 AND
                       l_period_end_flag = 0 THEN
                        -- create a period_end_entry with numbers
                        -- from latest activity entry
                        insert_ids_push_log(l_prd_end_ids_key,
                                            l_period.end_date,
                                            1, -- p_period_flag
                                            l_key,
                                            l_latest_activity_entry);
                        --edw_log.put_line('1 end insert');
                    ELSE
                        -- there is acitivity on period_end date
                        -- turn on the flag
                        -- l_end_activity_flag = 0 or 1,
                        -- l_period_end_flag = 999
                        UPDATE opi_ids_push_log
                          SET period_flag = 1, push_flag = 1
                          WHERE ids_key = l_prd_end_ids_key;

                        --edw_log.put_line('1 end update 2');
                    END IF;

                    -- now we have a period_end entry for this period
                    l_period_end_flag := 1;
                END IF;

                l_last_period_end_entry := l_latest_activity_entry;
                l_last_period_end_flag  := l_period_end_flag;
                /* end of period_end entry */
            END IF;  /* end of there is acitivity within the period */

            IF l_activity_flag = FALSE THEN
                -- no activity within the period
                -- either cleanup or carry over the balance
                -- for period_start/ period_end entries

                IF l_last_period_end_flag <> 1 THEN
                    -- delete the period_start entry if it exists
                    IF l_period_start_flag = 1 THEN
                        IF l_period.start_date <> l_first_push_date THEN
                            DELETE opi_ids_push_log
                              WHERE ids_key = l_prd_start_ids_key;

                            --edw_log.put_line('2 start del 0');

                            l_period_start_flag := 0;
                        END IF;-- l_period.start_date <> l_first_push_date
                    ELSIF l_period_start_flag = 999 THEN
                        -- the beg_inv_bal entry exists
                        -- a). if with bal, we need to carry over
                        -- b). if no bal, we need to delete it

                        OPEN l_period_start_entry_csr(l_prd_start_ids_key);
                        FETCH l_period_start_entry_csr
                          INTO l_beg_inv_bal_prd_start_entry;
                        CLOSE l_period_start_entry_csr;

                        -- b).
                        IF  Nvl(l_beg_inv_bal_prd_start_entry.beg_int_qty,0)= 0
                            AND Nvl(l_beg_inv_bal_prd_start_entry.beg_int_val_b,0)  = 0
                            AND Nvl(l_beg_inv_bal_prd_start_entry.beg_onh_qty,0)    = 0
                            AND Nvl(l_beg_inv_bal_prd_start_entry.beg_onh_val_b, 0) = 0
                            AND Nvl(l_beg_inv_bal_prd_start_entry.beg_wip_qty, 0)   = 0
                            AND Nvl(l_beg_inv_bal_prd_start_entry.beg_wip_val_b,0)  = 0
                            AND Nvl(l_beg_inv_bal_prd_start_entry.end_int_qty,0)    = 0
                            AND Nvl(l_beg_inv_bal_prd_start_entry.end_int_val_b,0)  = 0
                            AND Nvl(l_beg_inv_bal_prd_start_entry.end_onh_qty,0)    = 0
                            AND Nvl(l_beg_inv_bal_prd_start_entry.end_onh_val_b, 0) = 0
                            AND Nvl(l_beg_inv_bal_prd_start_entry.end_wip_qty, 0)   = 0
                            AND Nvl(l_beg_inv_bal_prd_start_entry.end_wip_val_b,0)  = 0
                        THEN
                            -- delete the period_start entry if it exists
                            DELETE opi_ids_push_log
                              WHERE ids_key = l_prd_start_ids_key;

                            l_period_start_flag := 0;

                            --edw_log.put_line('2 start del 1');
                        ELSE -- a).

                            UPDATE opi_ids_push_log
                              SET period_flag = 0, push_flag = 1
                              WHERE ids_key = l_prd_start_ids_key;

                            l_beg_inv_bal_flag  := 1;
                            l_period_start_flag := 1;
                            --edw_log.put_line('2 start update');
                        END IF;
                    END IF;
                ELSE -- last _period_end_entry exists
                    -- check begin/end on last_period_end_entry
                    IF  Nvl(l_last_period_end_entry.beg_int_qty,0) = 0
                        AND Nvl(l_last_period_end_entry.beg_int_val_b,0)=0
                        AND Nvl(l_last_period_end_entry.beg_onh_qty,0) = 0
                        AND Nvl(l_last_period_end_entry.beg_onh_val_b, 0)=0
                        AND Nvl(l_last_period_end_entry.beg_wip_qty, 0) = 0
                        AND Nvl(l_last_period_end_entry.beg_wip_val_b,0)= 0
                        AND Nvl(l_last_period_end_entry.end_int_qty,0) = 0
                        AND Nvl(l_last_period_end_entry.end_int_val_b,0)= 0
                        AND Nvl(l_last_period_end_entry.end_onh_qty,0) = 0
                        AND Nvl(l_last_period_end_entry.end_onh_val_b, 0)=0
                        AND Nvl(l_last_period_end_entry.end_wip_qty, 0) = 0
                        AND Nvl(l_last_period_end_entry.end_wip_val_b,0)= 0
                    THEN
                        -- delete the period_start entry if it exists
                        IF l_period_start_flag = 1 THEN
                            DELETE opi_ids_push_log
                              WHERE ids_key = l_prd_start_ids_key;
                            l_period_start_flag := 0;

                            --edw_log.put_line('2 start del 2');
                        END IF;
                    ELSE
                        IF l_period_start_flag = 1 THEN
                            -- update the existing period_start entry with the
                            -- numbers from last_period_end_entry.end****

                            update_ids_push_log(l_prd_start_ids_key,
                                                l_last_period_end_entry);

                            --edw_log.put_line('2 start update 2');
                        ELSIF l_period_start_flag = 0 THEN
                            insert_ids_push_log(l_prd_start_ids_key,
                                                l_period.start_date,
                                                0,
                                                l_key,
                                                l_last_period_end_entry);

                            l_period_start_flag := 1;

                            --edw_log.put_line('2 start insert 2');
                        ELSIF l_period_start_flag = 999 THEN
                            UPDATE opi_ids_push_log
                              SET period_flag = 0, push_flag = 1
                              WHERE ids_key = l_prd_start_ids_key;

                            --edw_log.put_line('2 start update 2.5');
                            l_period_start_flag := 1;
                        END IF;
                    END IF;
                END IF; /* end of period_start entry */

                -- always calculate period end entry
                IF l_period_start_flag = 1 THEN
                    IF l_period_end_flag = 1 THEN
                        IF l_beg_inv_bal_flag <> 1 THEN
                        -- should update the existing period_end entry with the
                        -- period_start entry
                        -- BUT here period_start entry is the same as
                        -- last_period_end_entry.end****

                            OPEN l_period_start_entry_csr(l_prd_start_ids_key);
                            FETCH l_period_start_entry_csr
                             INTO l_beg_inv_bal_prd_start_entry;
                            CLOSE l_period_start_entry_csr;

                            update_ids_push_log(l_prd_end_ids_key,
                                                l_beg_inv_bal_prd_start_entry);

                            -- Dinkar 11/20/02 -- added this line
                            l_last_period_end_entry :=
                                        l_beg_inv_bal_prd_start_entry;
                            --edw_log.put_line('2 end update ');

                        ELSIF l_beg_inv_bal_flag = 1 THEN
                            update_ids_push_log(l_prd_end_ids_key,
                                                l_beg_inv_bal_prd_start_entry);
                            l_beg_inv_bal_flag := 999;

                            l_period_end_flag := 1;
                            l_last_period_end_entry :=
                                    l_beg_inv_bal_prd_start_entry;

                            --edw_log.put_line('2 end update 2 ');
                        END IF;

                    ELSE
                        IF l_period_end_flag = 0 THEN
                            IF l_beg_inv_bal_flag <> 1 THEN

                                OPEN l_period_start_entry_csr
                                            (l_prd_start_ids_key);

                                FETCH l_period_start_entry_csr
                                  INTO l_beg_inv_bal_prd_start_entry;

                                CLOSE l_period_start_entry_csr;

                                insert_ids_push_log(l_prd_end_ids_key,
                                                    l_period.end_date,
                                                    1,
                                                    l_key,
                                                    l_beg_inv_bal_prd_start_entry);

                                -- Dinkar 11/20/02 -- added this line
                                l_last_period_end_entry :=
                                            l_beg_inv_bal_prd_start_entry;

                                --edw_log.put_line('2 end insert  ');
                            ELSIF l_beg_inv_bal_flag = 1 THEN
                                insert_ids_push_log(l_prd_end_ids_key,
                                                    l_period.end_date,
                                                    1,
                                                    l_key,
                                                    l_beg_inv_bal_prd_start_entry);
                                l_beg_inv_bal_flag := 999;

                                l_period_end_flag := 1;
                                l_last_period_end_entry :=
                                        l_beg_inv_bal_prd_start_entry;

                                --edw_log.put_line('2 end insert  2');
                            END IF;
                        ELSIF l_period_end_flag = 999 THEN
                            UPDATE opi_ids_push_log
                              SET period_flag = 1, push_flag = 1
                              WHERE ids_key = l_prd_end_ids_key;
                            --edw_log.put_line('2 end update 2.5');
                        END IF;

                        l_period_end_flag := 1;
                    END IF;
                ELSE
                    DELETE opi_ids_push_log
                      WHERE ids_key = l_prd_end_ids_key;

                    l_period_end_flag := 0;

                    --edw_log.put_line('2 end del 2  ');
                END IF;
                /* end of period_end_entry */

                l_last_period_end_flag := l_period_end_flag;
            END IF;  /* end of no activity within the period */

        END LOOP;  /* loop for periods */
    END LOOP;  /* loop for key combs  */

-- Fix for bug . Added procedures to fix the inv value for period start/end rows after standard cost update

   cost_update_inventory (p_from_date, p_to_date, p_organization_id,x_status);


EXCEPTION
   WHEN OTHERS THEN
      --dbms_output.put_line('sqlerrm ' ||Sqlerrm);
      edw_log.put_line('Error Code: ' || sqlcode);
      edw_log.put_line('Error Message: ' || sqlerrm);
      x_status := 1;
      --commit;
END calc_prd_start_end;



-- cost_on_date function
-- returns that cost of an item-org on a specified date.
-- Cost is of type NUMBER
FUNCTION cost_on_date (org_id IN NUMBER, item_id IN NUMBER,
                       cost_date IN DATE)
    RETURN NUMBER
IS
    -- Cursor for cost query. This returns the newest cost from
    -- the CST_STANDARD_COSTS table. This stores the latest
    -- cost, except for new items.
    CURSOR cost_on_date_csr (org_id NUMBER, item_id NUMBER,
                             cost_date DATE)
    IS
        SELECT csc.standard_cost unit_cost  -- Standard cost method logic.
          FROM CST_STANDARD_COSTS csc
          WHERE csc.ORGANIZATION_ID = org_id
            AND csc.INVENTORY_ITEM_ID = item_id
            AND csc.STANDARD_COST_REVISION_DATE =
                       (SELECT max(csc2.STANDARD_COST_REVISION_DATE)
                          FROM CST_STANDARD_COSTS csc2
                          WHERE csc2.ORGANIZATION_ID = org_id
                            AND csc2.INVENTORY_ITEM_ID = item_id
                            AND csc2.STANDARD_COST_REVISION_DATE <
                                trunc(cost_date) + 1 );

    -- cursor for getting the cost of a new item, when there is
    -- no cost in the CST_STANDARD_COST table.
    CURSOR new_item_cost_csr (org_id NUMBER, item_id NUMBER,p_cost_date DATE)
    IS
       select actual_cost
         from mtl_material_transactions
        where transaction_id = (
          select max(transaction_id)
            from mtl_material_transactions
           where inventory_item_id=item_id
             and organization_id=org_id
             and actual_cost is not null
             and transaction_date =
                (select max(transaction_date)
                   from mtl_material_transactions
                  where inventory_item_id=item_id
                    and organization_id=org_id
                    and trunc(transaction_date) <= p_cost_date
                    and actual_cost is not null));

    -- cost to return -- default is 0
    on_date_cost NUMBER := 0;

BEGIN

    --get the latest cost
    OPEN cost_on_date_csr (org_id, item_id, cost_date);

    FETCH cost_on_date_csr INTO on_date_cost;
    -- if there is no cost, then the item is probably new, so get cost from the
    -- new cost table

     IF cost_on_date_csr%NOTFOUND
     THEN
        OPEN new_item_cost_csr (org_id, item_id,cost_date);
        FETCH new_item_cost_csr INTO on_date_cost;
        CLOSE new_item_cost_csr;
     END IF;

    CLOSE cost_on_date_csr;

    RETURN on_date_cost;    -- cost on the given date

END cost_on_date;


-- activity_on_day function.
-- Returns true if there is activity on a given day (date is argument)
-- and false if there is no activity on the day for a given item
-- and org in the opi_ids_push_log.
FUNCTION activity_on_day (day_to_check IN DATE, p_organization_id IN NUMBER,
                          inv_item_id IN NUMBER)
    RETURN BOOLEAN

IS

    -- Cursor to see if there is any acitvity on the given day.
    -- If so, this cursor will return some data in it,
    -- else, it will not for the specified date, item and org in
    -- the opi_ids_push_log.
    CURSOR activity_log_csr (day_to_check DATE, p_organization_id NUMBER,
                             inv_item_id NUMBER)
    IS
      SELECT ids_key
      FROM opi_ids_push_log
      WHERE organization_id = p_organization_id
        AND inventory_item_id = inv_item_id
        AND trx_date = day_to_check
        AND ( NVL(beg_int_val_b,0) - NVL(end_int_val_b,0) <> 0
          OR  NVL(beg_onh_val_b,0) - NVL(end_onh_val_b,0) <> 0
          OR  NVL(beg_wip_val_b,0) - NVL(end_wip_val_b,0) <> 0);

    activity_instance activity_log_csr%ROWTYPE;

    activity_found BOOLEAN;

BEGIN

    -- we only need to fetch once from the cursor to see if
    -- any activity was found
    OPEN activity_log_csr (day_to_check, p_organization_id,
                           inv_item_id);
    FETCH activity_log_csr INTO activity_instance;
    activity_found := activity_log_csr%FOUND;
    CLOSE activity_log_csr;
    RETURN activity_found;
END activity_on_day;


-- function to return the next period start date, given any date.
-- Returns NULL if no such date is found. Note that we do not
-- care about the push flag anymore, nor the organization or
-- item ids.
-- Argument:
-- curr_date - date in this period

FUNCTION get_next_period_start (curr_date IN DATE,
                                p_organization_id IN NUMBER,
                                p_inventory_item_id IN NUMBER)
    RETURN DATE
IS

    -- cursor to select the next period start date.
    CURSOR next_period_start_csr (v_curr_date DATE,
                                  p_organization_id NUMBER,
                                  p_inventory_item_id NUMBER)
    IS
      SELECT min(push_log.trx_date)
        FROM opi_ids_push_log push_log
       WHERE push_log.period_flag = 0
         AND push_log.organization_id  = p_organization_id
         AND push_log.inventory_item_id = p_inventory_item_id
         AND push_log.trx_date > v_curr_date;

    -- variable to get data out of the date cursor
    next_period_start DATE; --next_period_start_csr%ROWTYPE;

BEGIN
    OPEN next_period_start_csr(curr_date, p_organization_id,
                               p_inventory_item_id);
    FETCH next_period_start_csr INTO next_period_start;
    CLOSE next_period_start_csr;
    RETURN next_period_start;
END get_next_period_start;


-- cost_update_inventory procedure
-- Description:
--  Finds all the items for a given org that have a cost update transaction
--  registered for them in the given from - to period. If there are items
--  cost updates, then it updates the end of periods (there might be many
--  period ends in the specified from-to date) intransit, on hand and WIP
--  inventory balances with the appropriate costs at the period_end_entries.
--
-- Arguments:
--  p_from_start - date of the start of period of transactions to update
--  p_end_end - date of the end of the period of transactions to update
--  p_organization_id - Org for which to find cost updates

PROCEDURE cost_update_inventory (p_from_date DATE, p_to_date DATE,
                                 p_organization_id NUMBER, p_status OUT NOCOPY NUMBER)
IS

    -- cost update transactions are stored in the mtl_material_transaction
    -- table
    -- standard cost update transaction type IDs in mtl_material_transaction
    -- table is 24
    COST_UPDATE_TRX_ID CONSTANT NUMBER := 24;

    -- period_flag = 1 for end of period entries in the opi_ids_push_log
    PERIOD_END_ENTRY_FLAG_VAL CONSTANT NUMBER := 1;

    -- period_flag = 0 for start of period entries in the opi_ids_push_log
    PERIOD_START_ENTRY_FLAG_VAL CONSTANT NUMBER := 0;

    -- push_flag = 1 for transactions just pushed into the opi_ids_push_log
    JUST_PUSHED_FLAG_VAL CONSTANT NUMBER:= 1;

    -- primary cost method for standard cost update is 1
    PRIMARY_COST_METHOD_UPDATE CONSTANT NUMBER := 1;


    -- cursor for all the distinct item-org combinations that have a
    -- registered cost update transaction in the mtl_material_transactions
    -- within the specified period dates (inclusive).
    -- We need to know the item id, the organization id, the transaction
    -- date.
    --
    -- The data is sorted by organization ID, item ID, and transaction
    -- date, so that we will only have to iterate through it once when
    -- going down the list and applying cost updates.
    CURSOR cost_update_trx_csr (p_from_date DATE, p_to_date DATE,
                                p_organization_id NUMBER)
    IS
        SELECT DISTINCT mmt.inventory_item_id inventory_item_id,
                        mmt.transaction_date transaction_date
          FROM mtl_material_transactions mmt, mtl_parameters mp,
               mtl_system_items_b msi
          WHERE mmt.transaction_type_id = 24
            AND mmt.transaction_date BETWEEN p_from_date AND p_to_date
            AND mmt.organization_id = p_organization_id
            AND mmt.organization_id = mp.organization_id   -- standard costing org
            AND msi.organization_id = mmt.organization_id
            AND msi.inventory_item_id = mmt.inventory_item_id
            AND msi.inventory_asset_flag = 'Y'  -- don't pick expense items
            AND mp.primary_cost_method = 1
            ORDER BY mmt.inventory_item_id, mmt.transaction_date;


        -- Cursor of all the distinct period end entry dates within the period
        -- start and period end dates (inclusive) with the specified item and
        -- org in the opi_ids_push_log.
        -- This means that the period_flag is set, the push_flag is set
        CURSOR period_end_dates_csr (p_organization_id NUMBER,
                                     p_inventory_item_id NUMBER,
                                     p_from_date DATE)
        IS
            SELECT push_log.trx_date trx_date
            FROM opi_ids_push_log push_log
            WHERE push_log.organization_id = p_organization_id
              AND push_log.inventory_item_id = p_inventory_item_id
              AND push_log.period_flag = 1
              AND push_log.push_flag = 1
              AND push_log.trx_date >= p_from_date
              GROUP BY push_log.trx_date
              ORDER BY trx_date;

    -- variable for updated cost - we need to get this separately due to another
    -- bug in costing. This is cost at the end of the period
    period_end_unit_cost NUMBER;

    -- variable for the cost at the beginning of the day at the end of the
    -- period
    period_end_beg_unit_cost NUMBER;

    -- variable for the unit cost as of the end of the start of the next period
    next_period_start_unit_cost NUMBER;

    -- variable for the next period start entry after a specified period end
    next_period_start DATE;

    -- start date of period which contains the p_from_date
    l_from_date_per_start DATE := NULL;

BEGIN

       -- setting OUT variable:  0 for success, 1 for failure
        p_status := 0;

    --DBMS_OUTPUT.PUT ('Cost Update for Org # ');
    --DBMS_OUTPUT.PUT_LINE (p_organization_id);

       -- select the start date of the period containing the p_from_date.
       -- We are assuming that the program is not run across periods.
       -- However, if there are two incremental runs in the period, we
       -- want the subsequent runs for the period to take the lastest
       -- cost even if the cost update was not part of this run dates.
       SELECT period_start_date
         INTO l_from_date_per_start
         FROM org_acct_periods
        WHERE period_start_date <= trunc (p_from_date)
          AND schedule_close_date >= trunc (p_from_date)
          AND organization_id = p_organization_id;


        -- for every item org combination, do a bulk update of
        -- of the inventory value at the period end
        FOR cost_update_item_org IN
        cost_update_trx_csr (l_from_date_per_start, p_to_date,
                             p_organization_id)
        LOOP

        --DBMS_OUTPUT.PUT_LINE ('Looking for period end entries.');

            -- Get all the period_ends in the specified date range for this
            -- item-org combination.
            -- Then update all inventory balances as of all these period
            -- end dates.
            FOR sub_period_end IN
                period_end_dates_csr (p_organization_id,
                                      cost_update_item_org.inventory_item_id,
                                      l_from_date_per_start)
            LOOP

        --DBMS_OUTPUT.PUT_LINE ('Looking for new cost.');

                -- Update the period end entry beginning and end
                -- balances.

                -- get unit cost of the item as of the end of period
                -- for the item/org combination that was updated
                period_end_unit_cost :=
                           cost_on_date (p_organization_id,
                               cost_update_item_org.inventory_item_id,
                               sub_period_end.trx_date);

                period_end_beg_unit_cost := period_end_unit_cost;

        -- Also, we need to update the beginning balance values for
                -- for the period end day we are updating the ending values
                -- The beginning value is the same as the ending value if
                -- there is no activity on the day. However, if there is
                -- activity, then we need to find the cost as of the previous
                -- day and then use that to update the beginning balance.
                IF (activity_on_day (sub_period_end.trx_date, p_organization_id,
                                     cost_update_item_org.inventory_item_id))
                THEN
                    -- Find the cost at the start of the period end date
                    -- i.e. the cost up to the day before
                    period_end_beg_unit_cost :=
                               cost_on_date (p_organization_id,
                                   cost_update_item_org.inventory_item_id,
                                   sub_period_end.trx_date - 1);

                END IF;    -- end IF (activity_on_day (sub_period_end.trx_date))


                -- Now update the end of day balances after checking if there
                -- was activity on the day
                UPDATE opi_ids_push_log
                  SET
                    beg_int_val_b = beg_int_qty * period_end_beg_unit_cost,
                    beg_onh_val_b = beg_onh_qty * period_end_beg_unit_cost,
                    beg_wip_val_b = beg_wip_qty * period_end_beg_unit_cost,
                    end_int_val_b = end_int_qty * period_end_unit_cost,
                    end_onh_val_b = end_onh_qty * period_end_unit_cost,
                    end_wip_val_b = end_wip_qty * period_end_unit_cost
                  WHERE organization_id = p_organization_id
                    AND inventory_item_id = cost_update_item_org.inventory_item_id
                    AND trx_date = sub_period_end.trx_date
                    AND subinventory_code NOT IN  -- don't update expense sub
                            (SELECT secondary_inventory_name
                               FROM mtl_secondary_inventories
                               WHERE organization_id = p_organization_id
                                 AND asset_inventory <> 1) -- expense sub
                    AND period_flag = 1        -- just to be safe
                    AND push_flag = 1;        -- just to be safe


                -- Now update the period start entries for the next period
                -- because those entries are out of date too.

                -- Get the first period start entry past this period end entry.

                next_period_start := get_next_period_start
                                         (sub_period_end.trx_date, p_organization_id,
                                          cost_update_item_org.inventory_item_id);

                IF(next_period_start is not null)
                THEN
                    next_period_start_unit_cost := period_end_unit_cost;

            -- The ending balance is trickier. If there is activity on the
                    -- next period start day, then the ending balance has to be
                    -- computed based on the costs of today (to account for
                    -- cost updates.
                    IF (activity_on_day (sub_period_end.trx_date, p_organization_id,
                                         cost_update_item_org.inventory_item_id))
            THEN
                        -- get the cost as of this day
                        next_period_start_unit_cost :=
                                   cost_on_date (p_organization_id,
                                                 cost_update_item_org.inventory_item_id,
                                                 next_period_start);
                    END IF;


                    -- The beginning balance is always the ending balance of
                    -- the previous period. We can set this after checking
                    -- if there was any activity on this day. The cost
                    -- is the same as the end of the previous period.
                    UPDATE opi_ids_push_log
                      SET
                        beg_int_val_b = beg_int_qty * period_end_unit_cost,
                        beg_onh_val_b = beg_onh_qty * period_end_unit_cost,
                        beg_wip_val_b = beg_wip_qty * period_end_unit_cost,
                        end_int_val_b = end_int_qty * next_period_start_unit_cost,
                        end_onh_val_b = end_onh_qty * next_period_start_unit_cost,
                        end_wip_val_b = end_wip_qty * next_period_start_unit_cost
                   WHERE organization_id = p_organization_id
                     AND inventory_item_id = cost_update_item_org.inventory_item_id
                    AND subinventory_code NOT IN  -- don't update expense sub
                            (SELECT secondary_inventory_name
                               FROM mtl_secondary_inventories
                               WHERE organization_id = p_organization_id
                                 AND asset_inventory <> 1) -- expense sub
                     AND trx_date = next_period_start
                     AND period_flag = 0        -- just to be safe
                     AND push_flag = 1;        -- just to be safe

            END IF; -- period_start_date not null

            END LOOP;   -- end FOR sub_period_end

        END LOOP;    -- end FOR cost_update_item_org


    EXCEPTION

        WHEN OTHERS
        THEN
            --DBMS_OUTPUT.PUT_LINE ('Exception Message: ' || SQLERRM);
            --DBMS_OUTPUT.PUT_LINE ('Exception Code: ' || SQLCODE);
            EDW_LOG.PUT_LINE ('Exception raised in cost_update_inventory');
            EDW_LOG.PUT_LINE ('Exception Message: ' || SQLERRM);
            EDW_LOG.PUT_LINE ('Exception Code: ' || SQLCODE);
            p_status := 1;

END cost_update_inventory;


End opi_edw_ids_calc;

/
