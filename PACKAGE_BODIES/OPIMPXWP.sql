--------------------------------------------------------
--  DDL for Package Body OPIMPXWP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPIMPXWP" AS
/*$Header: OPIMXWPB.pls 120.1 2005/06/08 18:31:48 appldev  $ */

procedure calc_wip_balance(
          I_ORG_ID                        IN   NUMBER,
          I_PUSH_START_INV_TXN_DATE       IN   DATE,
          I_PUSH_START_WIP_TXN_DATE       IN   DATE,
          I_PUSH_LAST_INV_TXN_ID          IN   NUMBER,
          I_PUSH_LAST_WIP_TXN_ID          IN   NUMBER,
          I_PUSH_END_TXN_DATE             IN   DATE,
          I_FIRST_PUSH                    IN   NUMBER,
          O_ERR_NUM                      OUT NOCOPY  NUMBER,
          O_ERR_CODE                     OUT NOCOPY VARCHAR2,
          O_ERR_MSG                      OUT NOCOPY VARCHAR2
         ) IS

/*---------------------
  c_txn_daily_sum
----------------------*/
/* Cursor to summarize the total WIP charges from the start date thru the end
   -- date by item, bom revision and transaction date for the specified organization.
   -- Notes:  The item in this context is the assembly of the job/schedules.  Hence,
   -- components issues for the assembly's job should be included in the WIP charges.
   -- They should be grouped by the assembly item number derived from
   -- mmt.transaction_source_id (= we.primary_item_id).
*/

   CURSOR c_txn_daily_sum is
   select we.primary_item_id item_id,   -- matl charges for discrete jobs
      wdj.bom_revision b_revision,
      trunc(mmt.transaction_date) txn_date,
      sum(nvl(mta.base_transaction_value,0)) wip_txn_val
   from mtl_transaction_accounts mta,
        mtl_material_transactions mmt,
        wip_entities we,
        wip_discrete_jobs wdj
   where mmt.transaction_source_type_id = 5
     and mmt.organization_id = i_org_id
     and mmt.transaction_source_id = we.wip_entity_id
     and mmt.transaction_id = mta.transaction_id
     and mta.accounting_line_type = 7
     and mmt.transaction_date between i_push_start_inv_txn_date
                              and i_push_end_txn_date
     and mmt.transaction_id <= i_push_last_inv_txn_id
     and mmt.transaction_source_id = wdj.wip_entity_id
   group by trunc(mmt.transaction_date),
            we.primary_item_id,
            wdj.bom_revision
   UNION ALL
   select we.primary_item_id item_id,      -- matl charges for rep. schedules
      wrs.bom_revision b_revision,
      trunc(mmt.transaction_date) txn_date,
      sum(nvl(mta.base_transaction_value,0)) wip_txn_val
   from mtl_transaction_accounts mta,
        mtl_material_transactions mmt,
        wip_entities we,
        wip_repetitive_schedules wrs
   where mmt.transaction_source_type_id = 5
     and mmt.organization_id = i_org_id
     and mmt.transaction_source_id = we.wip_entity_id
     and mmt.transaction_id = mta.transaction_id
     and mta.accounting_line_type = 7
     and mmt.transaction_date between i_push_start_inv_txn_date
                              and i_push_end_txn_date
     and mmt.transaction_id <= i_push_last_inv_txn_id
     and mmt.transaction_source_id = wrs.wip_entity_id
   group by trunc(mmt.transaction_date),
            we.primary_item_id,
            wrs.bom_revision
   UNION ALL
   select we.primary_item_id item_id,    -- matl charges for flow schedules
      wfs.bom_revision b_revision,
      trunc(mmt.transaction_date) txn_date,
      sum(nvl(mta.base_transaction_value,0)) wip_txn_val
   from mtl_transaction_accounts mta,
        mtl_material_transactions mmt,
        wip_entities we,
        wip_flow_schedules wfs
   where mmt.transaction_source_type_id = 5
     and mmt.organization_id = i_org_id
     and mmt.transaction_source_id = we.wip_entity_id
     and mmt.transaction_id = mta.transaction_id
     and mta.accounting_line_type = 7
     and mmt.transaction_date between i_push_start_inv_txn_date
                              and i_push_end_txn_date
     and mmt.transaction_id <= i_push_last_inv_txn_id
     and mmt.transaction_source_id = wfs.wip_entity_id
   group by trunc(mmt.transaction_date),
            we.primary_item_id,
            wfs.bom_revision
   UNION ALL
   select wdj.primary_item_id item_id,   -- resource charges for discrete jobs
      wdj.bom_revision b_revision,
      trunc(wt.transaction_date) txn_date,
      sum(nvl(wta.base_transaction_value,0)) wip_txn_val
   from wip_transactions wt,
        wip_transaction_accounts wta,
        wip_discrete_jobs wdj
   where wt.organization_id = i_org_id
     and wt.transaction_id = wta.transaction_id
     and wta.accounting_line_type = 7
     and wt.transaction_date between i_push_start_wip_txn_date
                             and i_push_end_txn_date
     and wt.transaction_id <= i_push_last_wip_txn_id
     and wt.wip_entity_id = wdj.wip_entity_id
   group by trunc(wt.transaction_date),
            wdj.primary_item_id,
            wdj.bom_revision
   UNION ALL
   select we.primary_item_id item_id,   -- resource charges for rep. schedules
      wrs.bom_revision b_revision,
      trunc(wt.transaction_date) txn_date,
      sum(nvl(wta.base_transaction_value,0)) wip_txn_val
   from wip_transactions wt,
        wip_transaction_accounts wta,
        wip_repetitive_schedules wrs,
        wip_entities we
   where wt.organization_id = i_org_id
     and wt.transaction_id = wta.transaction_id
     and wta.accounting_line_type = 7
     and wt.transaction_date between i_push_start_wip_txn_date
                             and i_push_end_txn_date
     and wt.transaction_id <= i_push_last_wip_txn_id
     and wt.wip_entity_id = wrs.wip_entity_id
     and wt.wip_entity_id = we.wip_entity_id
   group by trunc(wt.transaction_date),
            we.primary_item_id,
            wrs.bom_revision
   UNION ALL
   select wfs.primary_item_id item_id,    -- resource charges for flow schedules
      wfs.bom_revision b_revision,
      trunc(wt.transaction_date) txn_date,
      sum(nvl(wta.base_transaction_value,0)) wip_txn_val
   from wip_transactions wt,
        wip_transaction_accounts wta,
        wip_flow_schedules wfs
   where wt.organization_id = i_org_id
     and wt.transaction_id = wta.transaction_id
     and wta.accounting_line_type = 7
     and wt.transaction_date between i_push_start_wip_txn_date
                             and i_push_end_txn_date
     and wt.transaction_id <= i_push_last_wip_txn_id
     and wt.wip_entity_id = wfs.wip_entity_id
   group by trunc(wt.transaction_date),
            wfs.primary_item_id,
            wfs.bom_revision
   order by 3,1,2;

          l_count                number;
          l_end_bal              number;
          l_prev_end_bal         number;
          l_last_item_id         number;
          l_last_revision        varchar2(3);
          l_last_txn_date        date;
          l_start_date           date;
          l_last_txn_amt         number;
          l_push_log_key         varchar2(240);
          l_stmt_num             number;
          l_err_num              number;
          l_err_code             varchar2(240);
          l_err_msg              varchar2(240);
          process_error          exception;
          no_process             exception;

BEGIN

   EDW_LOG.PUT_LINE('OPIMPXWP.calc_wip_balances. '
                                  || 'Processing org id: '
                                  || to_char(i_org_id));

/*
DBMS_OUTPUT.PUT_LINE('OPIMPXWP.calc_wip_balances. '
                                  || 'Processing org id: '
                                  || to_char(i_org_id));
*/

EDW_LOG.PUT_LINE('Start inv txn date: '
                 || to_char(i_push_start_inv_txn_date,'DD-MON-YYYY
                    hh24:mi:ss'));
EDW_LOG.PUT_LINE('Start wip txn date: '
                 || to_char(i_push_start_wip_txn_date,'DD-MON-YYYY
                    hh24:mi:ss'));
EDW_LOG.PUT_LINE('Txn end date: '
                 || to_char(i_push_end_txn_date,'DD-MON-YYYY
                    hh24:mi:ss'));
EDW_LOG.PUT_LINE('End inv txn id: '
                 || to_char(i_push_last_inv_txn_id));
EDW_LOG.PUT_LINE('End wip txn id: '
                 || to_char(i_push_last_wip_txn_id));

   -- initialize local variables
   l_stmt_num := 0;
   l_err_num := 0;
   l_err_code := '';
   l_err_msg := '';

-- Proceed only if we have at least one of the start date.
   if i_push_start_inv_txn_date is null
      and i_push_start_wip_txn_date is null then
         raise no_process;
   end if;

/*--------------------------------------------------------------
  Check if this is the first push for the organization.
    If so, we need to do the following:
    - delete existing WIP opi_ids_push_log rows within the process
      date ranges to avoid duplication in case of repush
    - calculate the beginning balance at the start date
    - update beginning balances with daily WIP transactions within
      the process date ranges.
  If it is not a first push and WIP rows exist within the date
  range,  it is a repush.  We need to set the push_flag to null
  to indicate that these rows are repushed.
------------------------------------------------------------------*/

   if i_push_start_inv_txn_date < i_push_start_wip_txn_date then
      l_start_date := i_push_start_inv_txn_date;
   else
      l_start_date := i_push_start_wip_txn_date;
   end if;

   l_stmt_num := 10;
   if i_first_push > 0 then     -- first push process

      l_stmt_num := 15;
      delete opi_ids_push_log
         where organization_id = i_org_id
           and trx_date between l_start_date and i_push_end_txn_date
           and cost_group_id is null
           and subinventory_code is null
           and locator_id is null
           and lot_number is null
	   and end_wip_val_b is not null
	   and end_wip_qty is not null;

/*
DBMS_OUTPUT.PUT_LINE('call calc_beginning_wip');
*/

      calc_beginning_wip(
                    i_org_id,
                    i_push_start_wip_txn_date,
                    l_err_num,
                    l_err_code,
                    l_err_msg);
      if l_err_num <> 0 then
         raise process_error;
      end if;
   else
      update opi_ids_push_log
         set push_flag = null,
             last_update_date = sysdate
         where organization_id = i_org_id
           and trx_date between l_start_date and i_push_end_txn_date
           and cost_group_id is null
           and subinventory_code is null
           and locator_id is null
           and lot_number is null;
   end if;  -- end first push

   l_stmt_num := 20;
   l_last_item_id := 0;
   l_last_revision := null;
   l_last_txn_date := null;
   l_last_txn_amt := 0;

/*
DBMS_OUTPUT.PUT_LINE('start c_txn_daily_sum loop');
*/

   for c_txn_daily_sum_rec in c_txn_daily_sum loop
      if c_txn_daily_sum_rec.wip_txn_val <> 0  then
          l_push_log_key := c_txn_daily_sum_rec.txn_date
                   || '-'
                   || c_txn_daily_sum_rec.item_id
                   || '-'
                   || i_org_id
                   || '-'
                   || '-'       -- no cost group
                   || c_txn_daily_sum_rec.b_revision
                   || '---';     -- no lot,sub or locator

/*
DBMS_OUTPUT.PUT_LINE('push key log: ' || l_push_log_key);
DBMS_OUTPUT.PUT_LINE('call update daily_wip');
DBMS_OUTPUT.PUT_LINE('item: '|| to_char(c_txn_daily_sum_rec.item_id));
DBMS_OUTPUT.PUT_LINE('rev: ' || c_txn_daily_sum_rec.b_revision);
DBMS_OUTPUT.PUT_LINE('txn date: ' || to_char(trunc(c_txn_daily_sum_rec.txn_date)));
DBMS_OUTPUT.PUT_LINE('value: ' || to_char(c_txn_daily_sum_rec.wip_txn_val));
*/

       l_stmt_num := 30;
       update_daily_wip(l_push_log_key,
                        i_org_id,
                        c_txn_daily_sum_rec.item_id,
                        c_txn_daily_sum_rec.b_revision,
                        c_txn_daily_sum_rec.txn_date,
                        c_txn_daily_sum_rec.wip_txn_val,
                        l_err_num,
                        l_err_code,
                        l_err_msg);

        if l_err_num <> 0 then
           raise process_error;
        end if;

      end if;   -- end checking wip_txn_val
   end loop;    -- c_txn_daily_sum

-- At the beginning of the process, opi_ids_push_log.push_flag is
-- set to null to ensure there is no balance duplication.  Since
-- potentially some keys may not have transactions at the beginning
-- of the date range, their push flag remain at null.  They should be
-- reset to 1 to make them available to be pushed.

      l_stmt_num := 40;
      update opi_ids_push_log
         set push_flag = 1,
             last_update_date = sysdate
         where organization_id = i_org_id
           and trx_date between l_start_date and i_push_end_txn_date
           and cost_group_id is null
           and subinventory_code is null
           and locator_id is null
           and lot_number is null
           and push_flag is null;


EXCEPTION
   when no_process then
      o_err_num := 0;
      o_err_code := '';
      o_err_msg := '';
      EDW_LOG.PUT_LINE('Org id: ' || to_char(i_org_id));
      EDW_LOG.PUT_LINE('OPIMPXWP.calc_wip_balance - No WIP data to extract');
   when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := 'OPIMPXWP.calc_wip_balance ('
                 || to_char(l_stmt_num)
                 || ')';

/*
DBMS_OUTPUT.PUT_LINE('OPIMPXWP.calc_wip_balance ('
                 || to_char(l_stmt_num)
                 || ')');
*/

   when others then
      o_err_num := SQLCODE;
      o_err_msg := 'OPIMPXWP.calc_wip_balance ('
                   || to_char(l_stmt_num)
                   || '): '
                   || substr(SQLERRM, 1,200);

/*
DBMS_OUTPUT.PUT_LINE( 'OPIMPXWP.calc_wip_balance ('
                   || to_char(l_stmt_num)
                   || '): '
                   || substr(SQLERRM, 1,200));
*/

END calc_wip_balance;

/*******************************************************************
** PROCEDURE
** calc_beginning_wip
**
** This procedure calculates the beginning WIP value and quantity
** balances for a specific organization.  It will do the following:
**    - calculate the current balances
**    - backtrack material and resource transactions up to the start
**      transaction id for mmt and transaction date for wta.
********************************************************************/

procedure calc_beginning_wip(
   i_org_id                    IN     NUMBER,
   i_push_start_wip_txn_date   IN     DATE,
   o_err_num                   OUT NOCOPY   NUMBER,
   o_err_code                  OUT NOCOPY   VARCHAR2,
   o_err_msg                   OUT NOCOPY   VARCHAR2
   ) IS
   l_stmt_num             number;
   l_err_num              number;
   l_err_code           varchar2(240);
   l_err_msg              varchar2(240);
   l_push_log_key         varchar2(240);
   l_push_log_count       number;
   l_update_flag          number;
   l_curr_date            date;
   process_error          exception;

/*-----------------------
  cursor c_curr_bal
-----------------------*/
   -- cursor to collect current WIP balances from wip_period_balances (WPB)
   -- by item and bom revision for a specified organization.
   -- We assume that the current WIP balance for flow schedules will allways
   -- be zero because flow schedules are maintained with work-order-less
   -- completion where all transactions are backflushed.

   cursor c_curr_bal is
   select wdj.primary_item_id item_id,    -- curr bal. for discrete jobs
       wdj.bom_revision b_revision,
       sum(nvl(tl_resource_in,0) - nvl(tl_resource_out,0)
              + nvl(tl_overhead_in,0) - nvl(tl_overhead_out,0)
            + nvl(tl_outside_processing_in,0) - nvl(tl_outside_processing_out,0)
              + nvl(pl_material_in,0) - nvl(pl_material_out,0)
              + nvl(pl_material_overhead_in,0) - nvl(pl_material_overhead_out,0)
              + nvl(pl_resource_in,0) - nvl(pl_resource_out,0)
              + nvl(pl_overhead_in,0) - nvl(pl_overhead_out,0)
              + nvl(pl_outside_processing_in,0) - nvl(pl_outside_processing_out,0)
              - nvl(tl_material_var,0)
              - nvl(tl_material_overhead_var,0)
              - nvl(tl_resource_var,0)
              - nvl(tl_outside_processing_var,0)
              - nvl(tl_overhead_var,0)
              - nvl(pl_material_var,0)
              - nvl(pl_material_overhead_var,0)
              - nvl(pl_resource_var,0)
              - nvl(pl_outside_processing_var,0)
              - nvl(pl_overhead_var,0)) curr_wip_bal
            from wip_period_balances wpb,
                 wip_discrete_jobs wdj
            where wpb.wip_entity_id = wdj.wip_entity_id
              and wdj.status_type in (3,4,5,6,14,15)
                   -- released, complete, complete no charge, on hold,
                   -- pending close, failed close respectively.
              and wpb.organization_id = wdj.organization_id
              and wdj.organization_id = i_org_id
            group by wdj.primary_item_id,
                  wdj.bom_revision
UNION ALL
   select we.primary_item_id item_id,     -- current bal. for repetitive schedules
      wrs.bom_revision b_revision,
      sum(nvl(tl_resource_in,0) - nvl(tl_resource_out,0)
              + nvl(tl_overhead_in,0) - nvl(tl_overhead_out,0)
            + nvl(tl_outside_processing_in,0) - nvl(tl_outside_processing_out,0)
              + nvl(pl_material_in,0) - nvl(pl_material_out,0)
              + nvl(pl_material_overhead_in,0) - nvl(pl_material_overhead_out,0)
              + nvl(pl_resource_in,0) - nvl(pl_resource_out,0)
              + nvl(pl_overhead_in,0) - nvl(pl_overhead_out,0)
              + nvl(pl_outside_processing_in,0) - nvl(pl_outside_processing_out,0)
              - nvl(tl_material_var,0)
              - nvl(tl_material_overhead_var,0)
              - nvl(tl_resource_var,0)
              - nvl(tl_outside_processing_var,0)
              - nvl(tl_overhead_var,0)
              - nvl(pl_material_var,0)
              - nvl(pl_material_overhead_var,0)
              - nvl(pl_resource_var,0)
              - nvl(pl_outside_processing_var,0)
              - nvl(pl_overhead_var,0)) curr_wip_bal
   from wip_period_balances wpb,
        wip_repetitive_schedules wrs,
        wip_entities we
   where wpb.wip_entity_id = wrs.wip_entity_id
         and wpb.wip_entity_id = we.wip_entity_id
         and wrs.status_type in (3,4,5,6,14,15)
                   -- released, complete, complete no charge, on hold,
                   -- pending close, failed close respectively.
         and wrs.organization_id = i_org_id
         and wpb.organization_id = wrs.organization_id
         and we.organization_id = wrs.organization_id
   group by we.primary_item_id,
            wrs.bom_revision
   order by 1, 2;

/*------------------------
  cursor c_txn_sum
-------------------------*/
   -- Cursor to summarize the total WIP charges from the start date thru the current
   -- date by item, by bom revision for the specified organization.
   -- Notes:  The item in this context is the assembly of the job/schedules.  Hence,
   -- components issues for the assembly's job should be included in the WIP charges.
   -- They should be grouped by the assembly item number derived from
   -- mmt.transaction_source_id (= we.primary_item_id).
   cursor c_txn_sum(c_end_date DATE) is
   select we.primary_item_id item_id,   -- matl charges for discrete jobs
      wdj.bom_revision b_revision,
      sum(nvl(mta.base_transaction_value,0)) wip_txn_val
   from mtl_transaction_accounts mta,
        mtl_material_transactions mmt,
        wip_entities we,
        wip_discrete_jobs wdj
   where mmt.transaction_source_type_id = 5
     and mmt.organization_id = i_org_id
     and mmt.transaction_source_id = we.wip_entity_id
     and mmt.transaction_id = mta.transaction_id
     and mta.accounting_line_type = 7
     and mmt.transaction_date between i_push_start_wip_txn_date
                              and c_end_date
     and mmt.transaction_source_id = wdj.wip_entity_id
   group by we.primary_item_id,
            wdj.bom_revision
   UNION ALL
   select we.primary_item_id item_id,      -- matl charges for rep. schedules
      wrs.bom_revision b_revision,
      sum(nvl(mta.base_transaction_value,0)) wip_txn_val
   from mtl_transaction_accounts mta,
        mtl_material_transactions mmt,
        wip_entities we,
        wip_repetitive_schedules wrs
   where mmt.transaction_source_type_id = 5
     and mmt.organization_id = i_org_id
     and mmt.transaction_source_id = we.wip_entity_id
     and mmt.transaction_id = mta.transaction_id
     and mta.accounting_line_type = 7
     and mmt.transaction_date between i_push_start_wip_txn_date
                              and c_end_date
     and mmt.transaction_source_id = wrs.wip_entity_id
   group by we.primary_item_id,
            wrs.bom_revision
   UNION ALL
   select we.primary_item_id item_id,    -- matl charges for flow schedules
      wfs.bom_revision b_revision,
      sum(nvl(mta.base_transaction_value,0)) wip_txn_val
   from mtl_transaction_accounts mta,
        mtl_material_transactions mmt,
        wip_entities we,
        wip_flow_schedules wfs
   where mmt.transaction_source_type_id = 5
     and mmt.organization_id = i_org_id
     and mmt.transaction_source_id = we.wip_entity_id
     and mmt.transaction_id = mta.transaction_id
     and mta.accounting_line_type = 7
     and mmt.transaction_date between i_push_start_wip_txn_date
                              and c_end_date
     and mmt.transaction_source_id = wfs.wip_entity_id
   group by we.primary_item_id,
            wfs.bom_revision
   UNION ALL
   select wdj.primary_item_id item_id,   -- resource charges for discrete jobs
      wdj.bom_revision b_revision,
      sum(nvl(wta.base_transaction_value,0)) wip_txn_val
   from wip_transactions wt,
        wip_transaction_accounts wta,
        wip_discrete_jobs wdj
   where wt.organization_id = i_org_id
     and wt.transaction_id = wta.transaction_id
     and wta.accounting_line_type = 7
     and wt.transaction_date between i_push_start_wip_txn_date
                             and c_end_date
     and wt.wip_entity_id = wdj.wip_entity_id
   group by wdj.primary_item_id,
            wdj.bom_revision
   UNION ALL
   select we.primary_item_id item_id,   -- resource charges for rep. schedules
      wrs.bom_revision b_revision,
      sum(nvl(wta.base_transaction_value,0)) wip_txn_val
   from wip_transactions wt,
        wip_transaction_accounts wta,
        wip_repetitive_schedules wrs,
        wip_entities we
   where wt.organization_id = i_org_id
     and wt.transaction_id = wta.transaction_id
     and wta.accounting_line_type = 7
     and wt.transaction_date between i_push_start_wip_txn_date
                             and c_end_date
     and wt.wip_entity_id = wrs.wip_entity_id
     and wt.wip_entity_id = we.wip_entity_id
   group by we.primary_item_id,
            wrs.bom_revision
   UNION ALL
   select wfs.primary_item_id item_id,    -- resource charges for flow schedules
      wfs.bom_revision b_revision,
      sum(nvl(wta.base_transaction_value,0)) wip_txn_val
   from wip_transactions wt,
        wip_transaction_accounts wta,
        wip_flow_schedules wfs
   where wt.organization_id = i_org_id
     and wt.transaction_id = wta.transaction_id
     and wta.accounting_line_type = 7
     and wt.transaction_date between i_push_start_wip_txn_date
                             and c_end_date
     and wt.wip_entity_id = wfs.wip_entity_id
   group by wfs.primary_item_id,
            wfs.bom_revision
   order by 1,2;

BEGIN
-- Initialize local variables
   l_stmt_num := 0;
   l_err_num := 0;
   l_err_code := '';
   l_err_msg := '';
   l_push_log_key := null;

   l_stmt_num := 10;

   EDW_LOG.PUT_LINE('Processing (OPIMPXWP.calc_beginning_wip)...');

/*===============================================================================
-- FIRST, get current wip balance and load it to push log with start date in key.
================================================================================*/
   select sysdate into l_curr_date
     from dual;

/*
DBMS_OUTPUT.PUT_LINE('calc_beg_bal: start c_curr_bal loop');
*/

   for c_curr_bal_rec in c_curr_bal loop

      if c_curr_bal_rec.curr_wip_bal <> 0 then
         l_push_log_key := null;
         l_push_log_key := trunc(i_push_start_wip_txn_date)
                        || '-'
                        || c_curr_bal_rec.item_id
                        || '-'
                        || i_org_id
                        || '-'
                        || '-'       -- no cost group
                        || c_curr_bal_rec.b_revision
                        || '---';    -- no lot,sub or locator


         l_stmt_num := 10;

/*
DBMS_OUTPUT.PUT_LINE('calc_beg_bal - call upd_first_push_wip');
DBMS_OUTPUT.PUT_LINE('key: ' || l_push_log_key);
DBMS_OUTPUT.PUT_LINE('c_curr_bal_rec.curr_wip_bal: '
                     || to_char(c_curr_bal_rec.curr_wip_bal));
*/

         upd_first_push_wip(l_push_log_key,
                         i_org_id,
                         c_curr_bal_rec.item_id,
                         c_curr_bal_rec.b_revision,
                         i_push_start_wip_txn_date,
                         c_curr_bal_rec.curr_wip_bal,
                         1,            -- add to wip balance
                         l_err_num,
                         l_err_code,
                         l_err_msg);

         if l_err_num <> 0 then
            raise process_error;
         end if;

      end if;       -- end checking curr_wip_bal
   end loop;  -- end c_curr_bal cursor loop

/*=============================================================
-- Then, net transactions from start date thru sysdate against
-- current wip balance to come up with beginning balance.
===============================================================*/

/*
DBMS_OUTPUT.PUT_LINE('Net transactions');
*/

      for c_txn_sum_rec in c_txn_sum(l_curr_date) loop

         if c_txn_sum_rec.wip_txn_val <> 0  then
            l_push_log_key := null;
            l_push_log_key := trunc(i_push_start_wip_txn_date)
                        || '-'
                        || c_txn_sum_rec.item_id
                        || '-'
                        || i_org_id
                        || '-'
                        || '-'       -- no cost group
                        || c_txn_sum_rec.b_revision
                        || '---';    -- no lot,sub or locator

/*
DBMS_OUTPUT.PUT_LINE('key: ' || l_push_log_key);
DBMS_OUTPUT.PUT_LINE('c_txn_sum_rec.wip_txn_val:'
                      || to_char(c_txn_sum_rec.wip_txn_val));
DBMS_OUTPUT.PUT_LINE('net trxn - call upd_first_push_wip...');
*/

         l_stmt_num := 20;
         upd_first_push_wip(l_push_log_key,
                         i_org_id,
                         c_txn_sum_rec.item_id,
                         c_txn_sum_rec.b_revision,
                         i_push_start_wip_txn_date,
                         c_txn_sum_rec.wip_txn_val,
                         2,      -- substract to update beginning balance
                         l_err_num,
                         l_err_code,
                         l_err_msg);
         if l_err_num <> 0 then
            raise process_error;
         end if;

      end if;
   end loop;  -- end c_txn_sum cursor loop

-- Delete rows with no WIP balances.  WIP rows will not have subinv code
-- and the only INV rows that have no subinv code should be those created
-- for in-transit or cost update.  Therefore, it should be safe to delete
-- rows that meet the following where clause conditions without running
-- the risk of deleting rows inserted by INV

   delete from opi_ids_push_log
   where beg_wip_val_b = 0
     and end_wip_val_b = 0
     and subinventory_code is null
     and push_flag = 1     -- available to be pushed
     and period_flag is null     -- not period end
     and nvl(beg_int_val_b,0) = 0
     and nvl(end_int_val_b,0) = 0
     and nvl(beg_onh_val_b,0) = 0
     and nvl(end_onh_val_b,0) = 0
     and nvl(total_rec_val_b,0) = 0
     and nvl(tot_issues_val_b,0) = 0;

 EXCEPTION
   when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;

/*
DBMS_OUTPUT.PUT_LINE('errnum: ' || to_char(o_err_num)
                     || ', errcode: ' || o_err_code);
DBMS_OUTPUT.PUT_LINE('errmsg: ' || o_err_msg);
*/

   when others then
      o_err_num := SQLCODE;
      o_err_msg := 'OPIMPXWP.calc_beginning_wip ('
                   || to_char(l_stmt_num)
                   || '): '
                   || substr(SQLERRM, 1,200);

/*
DBMS_OUTPUT.PUT_LINE('errnum: ' || to_char(o_err_num)
                     || ', errcode: ' || o_err_code);
DBMS_OUTPUT.PUT_LINE('errmsg: ' || o_err_msg);
*/

END calc_beginning_wip;

procedure upd_first_push_wip(
      i_ids_key        IN  VARCHAR2,
      i_org_id         IN  NUMBER,
      i_item_id        IN  NUMBER,
      i_revision       IN  VARCHAR2,
      i_txn_date       IN  DATE,
      i_wip_amount     IN  NUMBER,
      i_update_flag    IN  NUMBER,    -- (1=update bal , 2=substract from bal)
      o_err_num        OUT NOCOPY NUMBER,
      o_err_code       OUT NOCOPY VARCHAR2,
      o_err_msg        OUT NOCOPY VARCHAR2
      ) IS

      l_push_log_count number;
      l_item_status    varchar2(10);
      l_item_type      varchar2(30);
      l_base_uom       varchar2(3);
      l_wip_amount     number;
      l_stmt_num       number;
      l_err_num        number;
      l_err_code       varchar2(240);
      l_err_msg        varchar2(240);
      process_error    exception;

BEGIN

      l_push_log_count := 0;
      l_err_num := 0;
      l_err_code := '';
      l_err_msg := '';

-- check i_update_flag to passed the correct signed amount
         if i_update_flag = 1 then
            l_wip_amount := i_wip_amount;
         else
            l_wip_amount := -1 * i_wip_amount;
         end if;

-- check if there is already a row for key (maybe a row has already been inserted by
-- calc_inv_balances procedure).  If yes, update/revise beg_wip_val_b column; otherwise,
-- insert a row, populating beg_wip_val_b.

      l_stmt_num := 10;

      select count(*)
         into l_push_log_count
         from opi_ids_push_log ipl
         where ipl.ids_key = i_ids_key;

      if l_push_log_count <> 0 then   -- check existing row
         l_stmt_num := 20;

         update opi_ids_push_log ipl
            set beg_wip_val_b =
                   nvl(ipl.beg_wip_val_b,0) + nvl(l_wip_amount,0),
                end_wip_val_b =
                   nvl(ipl.end_wip_val_b,0) + nvl(l_wip_amount,0),
                avg_wip_val_b =
                   (nvl(ipl.beg_wip_val_b,0) + nvl(l_wip_amount,0)
                  + nvl(ipl.end_wip_val_b,0) + nvl(l_wip_amount,0))
                  / 2,
                ipl.push_flag = 1,
                ipl.last_update_date = sysdate
         where ipl.ids_key = i_ids_key;
      else  -- no existing row
         l_stmt_num := 30;
         if nvl(i_item_id,0) <> 0 then
            select msi.inventory_item_status_code,
                   msi.item_type,
                   msi.primary_uom_code
            into l_item_status,
                 l_item_type,
                 l_base_uom
            from mtl_system_items msi
            where msi.organization_id = i_org_id
              and msi.inventory_item_id = i_item_id;
         end if;

/*
 DBMS_OUTPUT.PUT_LINE('daily update - call insert_upd, key =' || i_ids_key);
*/

         OPIMPXIN.Insert_update_push_log(
                                   i_txn_date,
                                   i_org_id,
                                   i_item_id,
                                   null,                 -- cost group id
                                   i_revision,
                                   null,                 -- lot number
                                   null,                 -- subinventory code
                                   null,                 -- locator
                                   l_item_status,
                                   l_item_type,
                                   l_base_uom,
                                   'beg_wip_qty',        -- p_col_nam1
                                   0,                    -- p_total1
                                   'beg_wip_val_b',      -- p_col_nam2
                                   l_wip_amount,         -- p_total2
                                   'end_wip_qty',        -- p_col_nam3
                                   0,                    -- p_total3
                                   'end_wip_val_b',      -- p_col_nam4
                                   l_wip_amount,         -- p_total4
                                   'avg_wip_qty',        -- p_col_nam5
                                   0,                    -- p_total5
                                   'avg_wip_val_b',      -- p_col_nam6
                                   l_wip_amount,         -- p_total6
                                   2,                    -- selector
                                   l_err_num);           -- l_status
      if l_err_num <> 0 then
         EDW_LOG.PUT_LINE('Error calling OPIMPXIN.Insert_update_push_log');
         raise process_error;
      end if;
   end if;  -- end no existing row

 EXCEPTION
      when process_error then
      EDW_LOG.PUT_LINE('OPIMPXWP.upd_first_push_wip - ');
      EDW_LOG.PUT_LINE('Error processing (OPIMPXWP.upd_first_push_wip)...');
      EDW_LOG.PUT_LINE('Error Num= ' || to_char(l_err_num));
      EDW_LOG.PUT_LINE('Statement Num= ' || to_char(l_stmt_num));

   when no_data_found then
      EDW_LOG.PUT_LINE('OPIMPXWP.upd_first_push_wip - stmt: '
                       || to_char(l_stmt_num));
      EDW_LOG.PUT_LINE('No item in MSI - Item id: ' || to_char(i_item_id)
                      || 'org id: ' || to_char(i_org_id));

   when others then
      o_err_num := SQLCODE;
      o_err_msg := 'OPIMPXWP.upd_first_push_wip ('
                   || to_char(l_stmt_num)
                   || '): '
                   || substr(SQLERRM, 1,200);

END upd_first_push_wip;

FUNCTION get_prev_end_bal(
      i_ids_key        IN  VARCHAR2,
      i_org_id         IN  NUMBER,
      i_item_id        IN  NUMBER,
      i_revision       IN  VARCHAR2,
      i_txn_date       IN  DATE,
      o_err_num        OUT NOCOPY NUMBER,
      o_err_code       OUT NOCOPY VARCHAR2,
      o_err_msg        OUT NOCOPY VARCHAR2
      ) return number IS

      l_trx_date       date;
      l_ids_key        varchar2(240);
      l_return_val     number;
      l_stmt_num       number;
      l_err_num        number;
      l_err_code       varchar2(240);
      l_err_msg        varchar2(240);

BEGIN

      l_trx_date := null;
      l_err_num := 0;
      l_err_code := '';
      l_err_msg := '';
      l_return_val := 0;

-- Get the previous day that has balances.
   select max(trx_date)
      into l_trx_date
      from opi_ids_push_log ipl
          where ipl.organization_id = i_org_id
            and ipl.inventory_item_id = i_item_id
            and ipl.revision = i_revision
            and ipl.trx_date < i_txn_date
            and ipl.cost_group_id is null
            and ipl.lot_number is null
            and ipl.subinventory_code is null
            and ipl.locator_id is null;

           l_ids_key := l_trx_date
                        || '-'
                        || i_item_id
                        || '-'
                        || i_org_id
                        || '-'
                        || '-'       -- no cost group
                        || i_revision
                        || '---';    -- no lot,sub or locator

/*
DBMS_OUTPUT.PUT_LINE('prev ids key: ' || l_ids_key);
*/

-- ending wip balance of previous day.
      select Nvl(end_wip_val_b,0)
         into l_return_val
         from opi_ids_push_log ipl
         where ipl.ids_key = l_ids_key;

   return l_return_val;

EXCEPTION
   when no_data_found then
      l_return_val := 0;
      return l_return_val;
   when others then
      o_err_num := SQLCODE;
      o_err_msg := 'OPIMPXWP.get_prev_end_bal ('
                   || to_char(l_stmt_num)
                   || '): '
                   || substr(SQLERRM, 1,200);

END get_prev_end_bal;

PROCEDURE update_daily_wip(
      i_ids_key        IN  VARCHAR2,
      i_org_id         IN  NUMBER,
      i_item_id        IN  NUMBER,
      i_revision       IN  VARCHAR2,
      i_txn_date       IN  DATE,
      i_wip_amount     IN  NUMBER,
      o_err_num        OUT NOCOPY NUMBER,
      o_err_code       OUT NOCOPY VARCHAR2,
      o_err_msg        OUT NOCOPY VARCHAR2
      ) IS

      l_push_log_key   varchar2(240);
      l_prev_end_bal   number;
      l_start_value    number;
      l_end_value      number;
      l_avg_value      number;
      l_item_status    varchar2(10);
      l_item_type      varchar2(30);
      l_base_uom       varchar2(3);
      l_ipl_count      number;
      l_stmt_num       number;
      l_err_num        number;
      l_err_code       varchar2(240);
      l_err_msg        varchar2(240);
      l_push_flag      number;
      process_error    exception;

BEGIN

      l_prev_end_bal := 0;
      l_start_value := 0;
      l_end_value := 0;
      l_ipl_count := 0;
      l_err_num := 0;
      l_err_code := '';
      l_err_msg := '';

-- Get item status and item type.
   l_stmt_num := 10;
   if nvl(i_item_id,0) <> 0 then
      select msi.inventory_item_status_code,
             msi.item_type,
             msi.primary_uom_code
         into l_item_status,
              l_item_type,
              l_base_uom
         from mtl_system_items msi
         where msi.organization_id = i_org_id
           and msi.inventory_item_id = i_item_id;
   end if;

-- Check if row exists

   l_ipl_count := 0;
   select count(*)
      into l_ipl_count
      from opi_ids_push_log ipl
      where ipl.ids_key = i_ids_key;

-- If row exists and it's a repushed row, make sure we get the previous ending
-- balance for beg bal.  If there is no prev. ending bal, it is probably the
-- very first WIP row for key.  In this case, leave the current beg bal alone.

   if l_ipl_count <> 0 then      -- have existing push log row
      select push_flag, Nvl(beg_wip_val_b,0), Nvl(end_wip_val_b,0)
        into l_push_flag, l_start_value,l_end_value
        from opi_ids_push_log ipl
        where ipl.ids_key = i_ids_key;
      l_end_value := nvl(l_end_value,0) + nvl(i_wip_amount,0);

      if l_push_flag is null then                -- repushed row
         l_stmt_num := 11;
         l_prev_end_bal := get_prev_end_bal(
                                      i_ids_key,
                                      i_org_id,
                                      i_item_id,
                                      i_revision,
                                      i_txn_date,
                                      l_err_num,
                                      l_err_code,
                                      l_err_msg
                                      );
         if l_err_num <> 0 then
            raise process_error;
         end if;

         if l_prev_end_bal <> 0 then
            l_start_value := l_prev_end_bal;
         end if;

         l_end_value := l_start_value + nvl(i_wip_amount,0);
      end if;   -- end checking l_push_flag

/*
DBMS_OUTPUT.PUT_LINE('daily upd - upd key: ' || i_ids_key);
*/
      l_stmt_num := 12;
      update opi_ids_push_log ipl
        set ipl.beg_wip_val_b = l_start_value,
            ipl.end_wip_val_b = l_end_value,
            ipl.avg_wip_val_b = (l_start_value + l_end_value) / 2,
            ipl.push_flag = 1,
            ipl.last_update_date = sysdate
        where ipl.ids_key = i_ids_key;

   else     -- no push log row

-- Get previous wip day balance
      l_stmt_num := 20;
      l_prev_end_bal := get_prev_end_bal(
                                      i_ids_key,
                                      i_org_id,
                                      i_item_id,
                                      i_revision,
                                      i_txn_date,
                                      l_err_num,
                                      l_err_code,
                                      l_err_msg
                                      );
      if l_err_num <> 0 then
         raise process_error;
      end if;

-- calculate wip values and quantities for the key.  Quantities should be zero since we do not
-- collect wip quantities.
      l_start_value := nvl(l_prev_end_bal,0);
      l_end_value   := l_start_value + nvl(i_wip_amount,0);
      l_avg_value := (l_start_value + l_end_value) / 2;

/*
DBMS_OUTPUT.PUT_LINE('daily update - insert key: ' || i_ids_key);
DBMS_OUTPUT.PUT_LINE('start val: ' || to_char(l_start_value));
DBMS_OUTPUT.PUT_LINE('end val: ' || to_char(l_end_value));
DBMS_OUTPUT.PUT_LINE('avg_val: ' || to_char(l_avg_value));
*/

      l_stmt_num := 20;
      OPIMPXIN.Insert_update_push_log(
                                   i_txn_date,
                                   i_org_id,
                                   i_item_id,
                                   null,                 -- cost group id
                                   i_revision,
                                   null,                 -- lot number
                                   null,                 -- subinventory code
                                   null,                 -- locator
                                   l_item_status,
                                   l_item_type,
                                   l_base_uom,
                                   'beg_wip_qty',        -- p_col_nam1
                                   0,                    -- p_total1
                                   'beg_wip_val_b',      -- p_col_nam2
                                   l_start_value,        -- p_total2
                                   'end_wip_qty',        -- p_col_nam3
                                   0,                    -- p_total3
                                   'end_wip_val_b',      -- p_col_nam4
                                   l_end_value,          -- p_total4
                                   'avg_wip_qty',        -- p_col_nam5
                                   0,                    -- p_total5
                                   'avg_wip_val_b',      -- p_col_nam6
                                   l_avg_value,          -- p_total6
                                   2,                    -- selector
                                   l_err_num);           -- l_status
      if l_err_num <> 0 then
         EDW_LOG.PUT_LINE('Error calling OPIMPXIN.Insert_update_push_log');
         raise process_error;
      end if;
   end if;     -- end checking for existence of push log row

EXCEPTION
   when process_error then
      EDW_LOG.PUT_LINE('OPIMPXWP.update_daily_wip:');
      EDW_LOG.PUT_LINE('Error processing (OPIMPXWP.update_daily_wip)...');
      EDW_LOG.PUT_LINE('Error Num= ' || to_char(l_err_num));
      EDW_LOG.PUT_LINE('Statement Num= ' || to_char(l_stmt_num));

   when others then
      o_err_num := SQLCODE;
      o_err_msg := 'OPIMPXWP.update_daily_wip ('
                   || to_char(l_stmt_num)
                   || '): '
                   || substr(SQLERRM, 1,200);
      EDW_LOG.PUT_LINE('Error Code: ' || to_char(o_err_num));
      EDW_LOG.PUT_LINE(o_err_msg);

END update_daily_wip;

END OPIMPXWP;

/
