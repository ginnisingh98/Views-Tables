--------------------------------------------------------
--  DDL for Package Body MSC_GANTT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_GANTT_PKG" AS
/* $Header: MSCGNTPB.pls 120.30 2006/09/20 00:28:24 pabram noship $  */

 -- Constants
   --separators
   FIELD_SEPERATOR constant varchar2(5) := msc_gantt_utils.FIELD_SEPERATOR;
   RECORD_SEPERATOR constant varchar2(5) := msc_gantt_utils.RECORD_SEPERATOR;
   RESOURCE_SEPERATOR constant varchar2(5) := msc_gantt_utils.RESOURCE_SEPERATOR;
   FORMAT_MASK constant varchar2(20) := msc_gantt_utils.FORMAT_MASK;
   COMMA_SEPARATOR constant varchar2(20) := msc_gantt_utils.COMMA_SEPARATOR;
   COLON_SEPARATOR constant varchar2(20) := msc_gantt_utils.COLON_SEPARATOR;

   --view types
   DEMAND_VIEW CONSTANT INTEGER := msc_gantt_utils.DEMAND_VIEW;
   ORDER_VIEW  CONSTANT INTEGER := msc_gantt_utils.ORDER_VIEW;
   RES_ACTIVITIES_VIEW CONSTANT INTEGER := msc_gantt_utils.RES_ACTIVITIES_VIEW;
   RES_UNITS_VIEW CONSTANT INTEGER := msc_gantt_utils.RES_UNITS_VIEW;
   RES_HOURS_VIEW CONSTANT INTEGER := msc_gantt_utils.RES_HOURS_VIEW;
   SUPPLIER_VIEW CONSTANT INTEGER := msc_gantt_utils.SUPPLIER_VIEW;

   --node types
   END_DEMAND_NODE constant INTEGER := msc_gantt_utils.END_DEMAND_NODE;
   JOB_NODE constant INTEGER := msc_gantt_utils.JOB_NODE;
   OP_NODE constant INTEGER := msc_gantt_utils.OP_NODE;
   RES_NODE constant INTEGER := msc_gantt_utils.RES_NODE;
   -- END_JOB_NODE CONSTANT INTEGER := msc_gantt_utils.END_JOB_NODE;
   COPROD_NODE constant INTEGER := msc_gantt_utils.COPROD_NODE;
   RES_INST_NODE CONSTANT INTEGER := msc_gantt_utils.RES_INST_NODE;

   --orders view types
   PEG_ORDERS constant integer := msc_gantt_utils.PEG_ORDERS;
   PEG_DOWN constant integer := msc_gantt_utils.PEG_DOWN;
   PEG_UP   constant integer := msc_gantt_utils.PEG_UP;
   PEG_UP_AND_DOWN   constant integer := msc_gantt_utils.PEG_UP_AND_DOWN;
   SHOW_CHILDREN constant integer := msc_gantt_utils.SHOW_CHILDREN;
   SHOW_PARENT constant integer := msc_gantt_utils.SHOW_PARENT;
   SHOW_PARENT_CHILDREN constant integer := msc_gantt_utils.SHOW_PARENT_CHILDREN;

   --diff peg vs same peg orders view
   SAME_PEG  constant INTEGER := msc_gantt_utils.SAME_PEG;
   ALL_PEG  constant INTEGER := msc_gantt_utils.ALL_PEG;

   --parent id
   SUMMARY_DATA constant integer := msc_gantt_utils.SUMMARY_DATA;
   DETAIL_DATA constant integer := msc_gantt_utils.DETAIL_DATA;

   -- res firm types
   NO_FIRM        CONSTANT INTEGER := msc_gantt_utils.NO_FIRM;
   FIRM_START     CONSTANT INTEGER := msc_gantt_utils.FIRM_START;
   FIRM_END       CONSTANT INTEGER := msc_gantt_utils.FIRM_END;
   FIRM_RESOURCE  CONSTANT INTEGER := msc_gantt_utils.FIRM_RESOURCE;
   FIRM_START_END CONSTANT INTEGER := msc_gantt_utils.FIRM_START_END;
   FIRM_START_RES CONSTANT INTEGER := msc_gantt_utils.FIRM_START_RES;
   FIRM_END_RES   CONSTANT INTEGER := msc_gantt_utils.FIRM_END_RES;
   FIRM_ALL       CONSTANT INTEGER := msc_gantt_utils.FIRM_ALL;

   --display types for res activities /hours view
   DISPLAY_NONE constant integer := msc_gantt_utils.DISPLAY_NONE;
   DISPLAY_LATE constant integer := msc_gantt_utils.DISPLAY_LATE;
   DISPLAY_EARLY constant integer := msc_gantt_utils.DISPLAY_EARLY;
   DISPLAY_FIRM constant integer := msc_gantt_utils.DISPLAY_FIRM;
   DISPLAY_OVERLOAD constant integer := msc_gantt_utils.DISPLAY_OVERLOAD;

   --res row types
   RES_REQ_ROW_TYPE constant INTEGER := msc_gantt_utils.RES_REQ_ROW_TYPE;
   RES_ACT_BATCHED_ROW_TYPE constant integer := msc_gantt_utils.RES_ACT_BATCHED_ROW_TYPE;

   --critical vs non critical orders view
   NON_CRITICAL_PATH constant integer := msc_gantt_utils.NON_CRITICAL_PATH;
   CRITICAL_PATH constant integer := msc_gantt_utils.CRITICAL_PATH;

   --filter types
   FILTER_TYPE_LIST constant integer := msc_gantt_utils.FILTER_TYPE_LIST;
   FILTER_TYPE_MFQ constant integer := msc_gantt_utils.FILTER_TYPE_MFQ;
   FILTER_TYPE_FOLDER_ID constant integer := msc_gantt_utils.FILTER_TYPE_FOLDER_ID;
   FILTER_TYPE_WHERE_STMT constant integer := msc_gantt_utils.FILTER_TYPE_WHERE_STMT;
   FILTER_TYPE_AMONG constant integer := msc_gantt_utils.FILTER_TYPE_AMONG;

   --misc
   MBP_NULL_VALUE constant integer := msc_gantt_utils.MBP_NULL_VALUE;
   MBP_NULL_VALUE_CHAR constant varchar2(30) := msc_gantt_utils.MBP_NULL_VALUE_CHAR;
   NULL_SPACE constant varchar2(1) := msc_gantt_utils.NULL_SPACE;

   SYS_YES constant INTEGER := msc_gantt_utils.SYS_YES;
   SYS_NO constant INTEGER := msc_gantt_utils.SYS_NO;


   TRANSFER_JOB_NODE constant integer := 1;
   OP_JOB_NODE constant integer := 2;

 -- Constants ends

   g_pref_id number;
   g_plan_id number;
   g_plan_type number;
   g_plan_info varchar2(5000);
   g_first_date date; --day level first date
   g_last_date date; --day level last date
   g_hour_bkt_start_date date; --hour bucket start date
   g_day_bkt_start_date date; --day bucket start after hour and min
   g_plan_start_date date; --plan start date
   g_cutoff_date date; -- plan cutoff date

   g_end_demand_id number;

   g_node_index number;
   g_node_level number;

   g_op_query_id number;
   g_dem_op_query_id number;
   g_end_peg_query_id number;
   g_order_query_id number;

   g_peg_up_and_down number;
   g_peg_type number;
   g_same_peg number;

-- cursors +

   -- demand node ids
   cursor demand_cur (x_plan_id number, x_demand_id number) is
   select md.sr_instance_id,
     md.organization_id,
     md.demand_id
   from msc_demands md
   where md.demand_id = x_demand_id
     and md.plan_id = x_plan_id
     and md.origination_type in (6,7,8,9,11,15,22,29,30);

   -- end demand node ids at same level for a given supply
   cursor end_demands_cur (x_plan_id number,
     x_instance_id number, x_supply_id number) is
   select md.sr_instance_id,
     md.organization_id,
     md.demand_id,
     md.using_assembly_demand_date start_date
   from msc_demands md,
     msc_full_pegging mfp1
   where mfp1.plan_id = x_plan_id
     and mfp1.transaction_id = x_supply_id
     and mfp1.sr_instance_id = x_instance_id
     and mfp1.plan_id = md.plan_id
     and mfp1.demand_id = md.demand_id
     and mfp1.sr_instance_id = md.sr_instance_id
     and md.origination_type in (6,7,8,9,11,15,22,29,30)
   order by md.using_assembly_demand_date;

   -- supplies pegged to this demand
   cursor end_pegs_cur (x_plan_id number, x_demand_id number) is
   select distinct ms.sr_instance_id,
     ms.organization_id,
     ms.transaction_id,
     msc_gantt_utils.isCriticalSupply(x_plan_id, g_end_demand_id,
       ms.transaction_id, ms.sr_instance_id) critical_supply
   from  msc_full_pegging mfp,
     msc_supplies ms
   where mfp.demand_id = x_demand_id
     and mfp.plan_id = x_plan_id
     and ms.plan_id = mfp.plan_id
     and ms.transaction_id = mfp.transaction_id
     and ms.sr_instance_id = mfp.sr_instance_id;

   -- op node ids
   cursor ops_mfq_cur (x_op_seq_query_id number, x_supply_id number,
     x_plan_id number, x_inst_id number) is
   select distinct
     to_char(number2),
     number2,
     number3,
     char9,
     date1
     from msc_form_query
     where query_id = x_op_seq_query_id
       and number1 = x_supply_id
/*
     and number2 not in
       (select mon.to_op_seq_num
        from msc_operation_networks mon,
          msc_resource_requirements mrr
        where mrr.plan_id = x_plan_id
          and mrr.sr_instance_id = x_inst_id
          and mrr.supply_id = x_supply_id
          and mrr.end_date is not null
          and mrr.department_id <> -1
          and nvl(mrr.parent_id,2) = 2
          and mrr.plan_id = mon.plan_id
          and mrr.sr_instance_id = mon.sr_instance_id
          and mrr.routing_sequence_id = mon.routing_sequence_id
          and mrr.operation_seq_num = mon.from_op_seq_num
          and mon.transition_type = 1 --primary
          and mon.to_op_seq_num is not null
       )
     order by number2;
*/
     order by date1;

   -- op node ids from msc_operation_networks for  intra routing
   cursor ops_intra_routing_cur (x_supply_id number, x_plan_id number, x_inst_id number) is
   select
      mon.from_op_seq_num,
      mgq1.row_index from_index,
      mon.to_op_seq_num,
      mgq2.row_index to_index,
      mon.dependency_type
   from msc_operation_networks mon,
     msc_resource_requirements mrr,
     msc_gantt_query mgq1,
     msc_gantt_query mgq2
   where mrr.plan_id = x_plan_id
     and mrr.sr_instance_id = x_inst_id
     and mrr.supply_id = x_supply_id
     and mrr.end_date is not null
     and mrr.department_id <> -1
     and nvl(mrr.parent_id,2) = 2
     and mrr.plan_id = mon.plan_id
     and mrr.sr_instance_id = mon.sr_instance_id
     --and mrr.organization_id = mon.organization_id  --org in mon is null
     and mrr.routing_sequence_id = mon.routing_sequence_id
     and mon.transition_type = 1 --primary
     and mon.from_op_seq_num = mrr.operation_seq_num
     and mgq1.query_id = g_order_query_id
     and mgq1.sr_instance_id = mon.sr_instance_id
     and mgq1.transaction_id = mrr.supply_id
     and mgq1.op_seq_num = mon.from_op_seq_num
     and mgq2.query_id = g_order_query_id
     and mgq2.sr_instance_id = mon.sr_instance_id
     and mgq2.transaction_id = mrr.supply_id
     and mgq2.op_seq_num = mon.to_op_seq_num
   order by
     mon.from_op_seq_num,
     mon.to_op_seq_num;

   -- resource node ids
   cursor resources_cur (x_plan_id number, x_instance_id number,
     x_org_id number, x_supply_id number, x_op_seq number) is
   select
     nvl(mrr.department_id, 0) department_id,
     nvl(mrr.resource_id, 0) resource_id,
     mrr.transaction_id,
     decode(g_end_demand_id, null, 0,
       msc_gantt_utils.isCriticalRes(x_plan_id,g_end_demand_id,
       ms.transaction_id, ms.sr_instance_id,
       mrr.operation_seq_num, mrr.routing_sequence_id)) critical_flag,
     mrr.operation_seq_num,
     mrr.resource_seq_num
   from msc_resource_requirements mrr,
     msc_supplies ms
   where mrr.plan_id = x_plan_id
     and mrr.sr_instance_id = x_instance_id
     and mrr.organization_id = x_org_id
     and mrr.supply_id = x_supply_id
     and mrr.operation_seq_num = x_op_seq
     and mrr.end_date is not null
     and mrr.parent_id =2
     and mrr.department_id <> -1
     and ms.plan_id = mrr.plan_id
     and ms.transaction_id = mrr.supply_id
     and ms.sr_instance_id = mrr.sr_instance_id
   order by
     mrr.operation_seq_num,
     mrr.resource_seq_num;

   -- supply node from mfq
   cursor supplies_mfq_cur(x_dem_op_query_id number,
     x_plan_id number, x_inst_id number,
     x_supply_id number) is
   select distinct
     mfq.number4,
     mfq.number5,
     mfq.number3,
     decode(g_end_demand_id, null, 0,
       msc_gantt_utils.isCriticalSupply(ms.plan_id, g_end_demand_id,
       ms.transaction_id, ms.sr_instance_id)) critical_supply,
     msc_gantt_utils.getActualStartDate(ms.order_type, msi.planning_make_buy_code,
       ms.organization_id, ms.source_organization_id, ms.new_dock_date,
       ms.new_wip_start_date, ms.new_ship_date,ms.new_schedule_date,
       ms.source_supplier_id) start_date,
     ms.order_type
   from msc_form_query mfq,
     msc_supplies ms,
     msc_system_items msi
   where mfq.query_id = x_dem_op_query_id
     and mfq.number1 = x_supply_id
     and ms.plan_id = x_plan_id
     and ms.sr_instance_id = x_inst_id
     and ms.transaction_id = mfq.number3
     and ms.plan_id = msi.plan_id
     and ms.organization_id = msi.organization_id
     and ms.sr_instance_id = msi.sr_instance_id
     and ms.inventory_item_id = msi.inventory_item_id
   order by msc_gantt_utils.getActualStartDate(ms.order_type, msi.planning_make_buy_code,
       ms.organization_id, ms.source_organization_id, ms.new_dock_date,
       ms.new_wip_start_date, ms.new_ship_date,ms.new_schedule_date,
       ms.source_supplier_id) desc;

   -- supply node <same peg - peg down>
   cursor supplies_same_down_cur (x_plan_id number,
     x_instance_id number, x_supply_id number,
     x_end_peg_query_id number, x_dem_op_query_id number) is
   select distinct ms.sr_instance_id,
     ms.organization_id,
     ms.transaction_id,
     decode(g_end_demand_id, null, 0,
       msc_gantt_utils.isCriticalSupply(ms.plan_id, g_end_demand_id,
       ms.transaction_id, ms.sr_instance_id)) critical_supply,
     msc_gantt_utils.getActualStartDate(ms.order_type, msi.planning_make_buy_code,
       ms.organization_id, ms.source_organization_id, ms.new_dock_date,
       ms.new_wip_start_date, ms.new_ship_date,ms.new_schedule_date,
       ms.source_supplier_id) start_date,
     ms.order_type
   from msc_full_pegging mfp1,
     msc_full_pegging mfp2,
     msc_form_query mfq,
     msc_supplies ms,
     msc_system_items msi
   where mfp1.plan_id = x_plan_id
     and mfp1.sr_instance_id = x_instance_id
     and mfp1.transaction_id = x_supply_id
     and mfq.query_id = x_end_peg_query_id
     and mfq.number1 = mfp1.end_pegging_id
     and mfp2.plan_id = mfp1.plan_id
     and mfp2.prev_pegging_id = mfp1.pegging_id
     and ms.plan_id = mfp2.plan_id
     and ms.sr_instance_id = mfp2.sr_instance_id
     and ms.transaction_id = mfp2.transaction_id
     and ms.transaction_id not in (
       select mfq.number3
       from msc_form_query mfq
       where mfq.query_id = x_dem_op_query_id
         and mfq.number1 = x_supply_id
         and mfq.number2 is not null
       )
    and ms.plan_id = msi.plan_id
    and ms.organization_id = msi.organization_id
    and ms.sr_instance_id = msi.sr_instance_id
    and ms.inventory_item_id = msi.inventory_item_id
   order by msc_gantt_utils.getActualStartDate(ms.order_type, msi.planning_make_buy_code,
       ms.organization_id, ms.source_organization_id, ms.new_dock_date,
       ms.new_wip_start_date, ms.new_ship_date,ms.new_schedule_date,
       ms.source_supplier_id) desc;

   -- supply node <diff peg - peg up>
   cursor supplies_diff_up_cur (x_plan_id number,
     x_instance_id number, x_supply_id number,
     x_end_peg_query_id number, x_dem_op_query_id number) is
   select distinct ms.sr_instance_id,
     ms.organization_id,
     ms.transaction_id,
     decode(g_end_demand_id, null, 0,
       msc_gantt_utils.isCriticalSupply(ms.plan_id, g_end_demand_id,
       ms.transaction_id, ms.sr_instance_id)) critical_supply,
     msc_gantt_utils.getActualStartDate(ms.order_type, msi.planning_make_buy_code,
       ms.organization_id, ms.source_organization_id, ms.new_dock_date,
       ms.new_wip_start_date, ms.new_ship_date,ms.new_schedule_date,
       ms.source_supplier_id) start_date,
     ms.order_type
   from msc_full_pegging mfp1,
     msc_full_pegging mfp2,
     msc_supplies ms,
     msc_system_items msi
   where mfp1.plan_id = x_plan_id
     and mfp1.sr_instance_id = x_instance_id
     and mfp1.transaction_id = x_supply_id
     and mfp2.plan_id = mfp1.plan_id
     and mfp2.pegging_id = mfp1.prev_pegging_id
     and ms.plan_id = mfp2.plan_id
     and ms.sr_instance_id = mfp2.sr_instance_id
     and ms.transaction_id = mfp2.transaction_id
     and ms.plan_id = msi.plan_id
     and ms.organization_id = msi.organization_id
     and ms.sr_instance_id = msi.sr_instance_id
     and ms.inventory_item_id = msi.inventory_item_id
   order by msc_gantt_utils.getActualStartDate(ms.order_type, msi.planning_make_buy_code,
       ms.organization_id, ms.source_organization_id, ms.new_dock_date,
       ms.new_wip_start_date, ms.new_ship_date,ms.new_schedule_date,
       ms.source_supplier_id) desc;

   -- supply node <diff peg - peg down>
   cursor supplies_diff_down_cur (x_plan_id number,
     x_instance_id number, x_supply_id number,
     x_end_peg_query_id number, x_dem_op_query_id number) is
   select distinct ms.sr_instance_id,
     ms.organization_id,
     ms.transaction_id,
     decode(g_end_demand_id, null, 0,
       msc_gantt_utils.isCriticalSupply(ms.plan_id, g_end_demand_id,
       ms.transaction_id, ms.sr_instance_id)) critical_supply,
     msc_gantt_utils.getActualStartDate(ms.order_type, msi.planning_make_buy_code,
       ms.organization_id, ms.source_organization_id, ms.new_dock_date,
       ms.new_wip_start_date, ms.new_ship_date,ms.new_schedule_date,
       ms.source_supplier_id) start_date,
     ms.order_type
   from msc_full_pegging mfp1,
     msc_full_pegging mfp2,
     msc_supplies ms,
     msc_system_items msi
   where mfp1.plan_id = x_plan_id
     and mfp1.sr_instance_id = x_instance_id
     and mfp1.transaction_id = x_supply_id
     and mfp2.plan_id = mfp1.plan_id
     and mfp2.prev_pegging_id = mfp1.pegging_id
     and ms.plan_id = mfp2.plan_id
     and ms.sr_instance_id = mfp2.sr_instance_id
     and ms.transaction_id = mfp2.transaction_id
     and ms.transaction_id not in (
       select mfq.number3
       from msc_form_query mfq
       where mfq.query_id = x_dem_op_query_id
         and mfq.number1 = x_supply_id
         and mfq.number2 is not null
       )
     and ms.plan_id = msi.plan_id
     and ms.organization_id = msi.organization_id
     and ms.sr_instance_id = msi.sr_instance_id
     and ms.inventory_item_id = msi.inventory_item_id
   order by msc_gantt_utils.getActualStartDate(ms.order_type, msi.planning_make_buy_code,
       ms.organization_id, ms.source_organization_id, ms.new_dock_date,
       ms.new_wip_start_date, ms.new_ship_date,ms.new_schedule_date,
       ms.source_supplier_id) desc;

   -- co-prod supply node <stickers>
   cursor coprod_supplies_cur (x_plan_id number,
     x_instance_id number, x_supply_id number) is
   select distinct ms.sr_instance_id,
     ms.organization_id,
     ms.transaction_id,
     decode(g_end_demand_id, null, 0,
       msc_gantt_utils.isCriticalSupply(x_plan_id,g_end_demand_id,
       ms.transaction_id, ms.sr_instance_id)) critical_supply,
     ms.new_wip_start_date start_date,
     ms.order_type
   from msc_supplies ms
   where ms.plan_id = x_plan_id
     and ms.sr_instance_id = x_instance_id
     and ms.disposition_id = x_supply_id
     -- and ms.order_type in (14,15,16,17,28)
     and ms.transaction_id not in (select mgq.transaction_id
       from msc_gantt_query mgq
       where mgq.query_id = g_order_query_id
	  and mgq.transaction_id = ms.transaction_id)
  order by ms.new_wip_start_date;

   -- get op/supply from msc_demands <same peg - peg down>
   cursor op_supp_same_down_cur (x_plan_id number,
     x_instance_id number, x_supply_id number,
     x_end_peg_query_id number, x_first_op number) is
   select distinct
     decode(md.op_seq_num, 1, x_first_op, md.op_seq_num),
     ms.transaction_id,
     ms.sr_instance_id,
     ms.organization_id,
     msc_gantt_utils.isCriticalSupply(ms.plan_id, g_end_demand_id,
       ms.transaction_id, ms.sr_instance_id) critical_supply
   from msc_full_pegging mfp1,
     msc_full_pegging mfp2,
     msc_supplies ms,
     msc_demands md,
     msc_form_query mfq
   where mfp1.plan_id = x_plan_id
     and mfp1.transaction_id = x_supply_id
     and mfp1.sr_instance_id = x_instance_id
     and mfq.query_id = x_end_peg_query_id
     and mfp1.end_pegging_id = mfq.number1
     and md.plan_id = mfp1.plan_id
     and md.disposition_id = mfp1.transaction_id
     and md.sr_instance_id = mfp1.sr_instance_id
     and nvl(md.op_seq_num,0) <> 0
     and mfp2.plan_id = mfp1.plan_id
     and mfp2.prev_pegging_id = mfp1.pegging_id
     and mfp2.demand_id = md.demand_id
     and ms.plan_id = mfp2.plan_id
     and ms.transaction_id = mfp2.transaction_id
     and ms.sr_instance_id = mfp2.sr_instance_id;

   -- get op/supply from msc_demands <diff peg - peg down>
   cursor op_supp_diff_down_cur (x_plan_id number,
     x_instance_id number, x_supply_id number,
     x_end_peg_query_id number, x_first_op number) is
   select distinct
     decode(md.op_seq_num, 1, x_first_op, md.op_seq_num),
     ms.transaction_id,
     ms.sr_instance_id,
     ms.organization_id,
     msc_gantt_utils.isCriticalSupply(ms.plan_id, g_end_demand_id,
       ms.transaction_id, ms.sr_instance_id) critical_supply
   from msc_full_pegging mfp1,
     msc_full_pegging mfp2,
     msc_supplies ms,
     msc_demands md
   where mfp1.plan_id = x_plan_id
     and mfp1.transaction_id = x_supply_id
     and mfp1.sr_instance_id = x_instance_id
     and md.plan_id = mfp1.plan_id
     and md.disposition_id = mfp1.transaction_id
     and md.sr_instance_id = mfp1.sr_instance_id
     and nvl(md.op_seq_num,0) <> 0
     and mfp2.plan_id = mfp1.plan_id
     and mfp2.prev_pegging_id = mfp1.pegging_id
     and mfp2.demand_id = md.demand_id
     and ms.plan_id = mfp2.plan_id
     and ms.transaction_id = mfp2.transaction_id
     and ms.sr_instance_id = mfp2.sr_instance_id;

  --misc
  cursor c_op_seq_num_cur (p_dem_op_query_id number,
    p_supply_id number, p_trans_id number) is
  select number2 --op_seq_num
  from msc_form_query mfq
  where mfq.query_id = p_dem_op_query_id
  and mfq.number1 = p_supply_id
  and mfq.number3 = p_trans_id;

  cursor c_op_row_index_cur (p_qid number,
    p_supply_id number, p_op_seq_num number)is
  select mgq.row_index
  from msc_gantt_query mgq
  where mgq.query_id = p_qid
    and mgq.transaction_id = p_supply_id
    and mgq.op_seq_num = p_op_seq_num;

    cursor check_job_row_cur (p_query number,
      p_plan number, p_inst number, p_trx number) is
    select count(*)
    from msc_gantt_query mgq
    where mgq.query_id = p_query
      --and mgq.plan_id = p_plan
      and mgq.sr_instance_id = p_inst
      and mgq.transaction_id = p_trx
    and rownum = 1;

   cursor c_dmd_row_index (p_query number, p_inst number, p_trx number) is
   select row_index
   from msc_gantt_query mgq
   where mgq.query_id = p_query
      and mgq.sr_instance_id = p_inst
      and mgq.transaction_id = p_trx;

  cursor check_supp_row_cur (p_query number,
      p_plan number, p_inst number, p_org number, p_item number,
      p_supp number, p_supp_site number) is
    select count(*)
    from msc_gantt_query mgq
    where mgq.query_id = p_query
      and mgq.plan_id = p_plan
      and mgq.sr_instance_id = p_inst
      and mgq.organization_id = p_org
      and mgq.inventory_item_id = p_item
      and mgq.supplier_id = p_supp
      and nvl(mgq.supplier_site_id, mbp_null_value) = nvl(p_supp_site, mbp_null_value)
    and rownum = 1;

  cursor c_check_row_type (p_query number, p_index number) is
  select node_type
  from msc_gantt_query
  where query_id = p_query
    and row_index = p_index;

  cursor c_parent_link (p_query number, p_index number) is
  select parent_link
  from msc_gantt_query
  where query_id = p_query
    and row_index = p_index;

-- cursors -

--Private Apis
procedure put_line(p_string varchar2) is
begin
  null;
  --dbms_output.put_line(p_string);
end put_line;

procedure linkQueries(p_parent_query_id number,
  p_child_query_id number, p_view_type number, p_list varchar2) is

  l_trx_id number;
  l_inst_id number;
  l_one_record varchar2(100);

  i number:=1;
begin
  if ( p_parent_query_id is null ) then -- {
    return;
  end if; -- }

  if ( p_view_type = DEMAND_VIEW ) then -- {
    l_trx_id := to_number(p_list);
  else
    l_one_record := substr(p_list,
      instr(p_list,'(',1,i)+1,instr(p_list,')',1,i)-instr(p_list,'(',1,i)-1);
    l_trx_id := to_number(substr(l_one_record,instr(l_one_record,',')+1));
  end if; -- }

  update msc_gantt_query
  set child_query_id = p_child_query_id
  where query_id = p_parent_query_id
    and transaction_id = l_trx_id ;

end linkQueries;

procedure updateParentLinkforCoprod(p_query_id number, p_row_index number,
  p_parent_link varchar2, p_dependency_type number default null) is
begin
  if ( p_parent_link is null ) then -- {
    return;
  end if; -- }

  put_line(' updateParentLinkforCoprod '
    ||' p_row_index '|| p_row_index
    ||' p_parent_link '|| p_parent_link);

  update msc_gantt_query
  set parent_link = decode(parent_link, null,p_parent_link,
	parent_link|| COMMA_SEPARATOR ||p_parent_link),
	dependency_type = p_dependency_type
  where query_id = p_query_id
    and row_index = p_row_index;

end updateParentLinkforCoprod;

procedure updateOpParentLink(p_query_id number, p_row_index number,
  p_parent_link varchar2, p_dependency_type number default null) is
begin
  if ( p_parent_link is null ) then -- {
    return;
  end if; -- }
  put_line(' updateOpParentLink '
    ||' p_row_index '|| p_row_index
    ||' p_parent_link '|| p_parent_link);

  update msc_gantt_query
  set parent_link = decode(parent_link,
    null, p_parent_link || FIELD_SEPERATOR || nvl(to_char(p_dependency_type), null_space),
	parent_link || FIELD_SEPERATOR || p_parent_link  || FIELD_SEPERATOR || nvl(to_char(p_dependency_type), null_space)),
	dependency_type = nvl(dependency_type,0)+1
  where query_id = p_query_id
    and row_index = p_row_index;

end updateOpParentLink;

procedure updateParentLink(p_query_id number, p_row_index number,
  p_parent_link varchar2, p_dependency_type number default null) is

  l_parent_row_type number;
  l_child_row_type number;
  l_child_parent_link msc_gantt_query.parent_link%type;
begin
  if ( p_parent_link is null ) then -- {
    return;
  end if; -- }
  put_line(' updateParentLink '
    ||' p_row_index '|| p_row_index
    ||' p_parent_link '|| p_parent_link);

  open c_check_row_type(p_query_id, p_parent_link);
  fetch c_check_row_type into l_parent_row_type;
  close c_check_row_type;

  open c_check_row_type(p_query_id, p_row_index);
  fetch c_check_row_type into l_child_row_type;
  close c_check_row_type;

  open c_parent_link(p_query_id, p_row_index);
  fetch c_parent_link into l_child_parent_link;
  close c_parent_link;

  if (l_parent_row_type = COPROD_NODE or l_child_row_type = COPROD_NODE ) then
    return;
  end if;

  if ( instr(l_child_parent_link,p_parent_link) <>  0 ) then
    return;
  end if;

  update msc_gantt_query
  set parent_link = decode(parent_link, null,p_parent_link,
	parent_link|| COMMA_SEPARATOR ||p_parent_link),
	dependency_type = p_dependency_type
  where query_id = p_query_id
    and row_index = p_row_index;

end updateParentLink;

procedure addEndDemandNodes(p_instance_id number, p_supply_id number, p_parent_index number) is

  l_child_count number := 0;

  l_inst_id number;
  l_org_id number;
  l_trans_id number;
  l_start_date date;

  l_row_index number;
begin
  open end_demands_cur(g_plan_id, p_instance_id, p_supply_id);
  loop -- {
    fetch end_demands_cur into l_inst_id, l_org_id, l_trans_id, l_start_date;
    exit when end_demands_cur%notfound;

    open c_dmd_row_index(g_order_query_id, l_inst_id, l_trans_id);
    fetch c_dmd_row_index into l_row_index;
    close c_dmd_row_index;

   if ( nvl(l_row_index, mbp_null_value) = mbp_null_value) then
    g_node_index := g_node_index + g_peg_type;

    msc_gantt_utils.populateRowKeysIntoGantt(
      p_query_id => g_order_query_id,
      p_index => g_node_index,
      p_node_path => g_node_index,
      p_node_type => END_DEMAND_NODE,
      p_inst_id => l_inst_id,
      p_org_id => l_org_id,
      p_transaction_id => l_trans_id,
      p_critical_flag => NON_CRITICAL_PATH,
      p_node_level => g_node_level
    );
    updateParentLink(g_order_query_id, p_parent_index, g_node_index, null);
    l_child_count := l_child_count + 1;
  else
    updateParentLink(g_order_query_id, p_parent_index, l_row_index, null);
  end if;
  end loop; -- }
  close end_demands_cur;
end addEndDemandNodes;

procedure addResources(p_nodepath varchar2,
  p_instance_id number, p_org_id number,
  p_supply_id number, p_op_seq_id number) is

  l_trans_id msc_gantt_utils.number_arr;
  l_dept_id msc_gantt_utils.number_arr;
  l_res_id msc_gantt_utils.number_arr;
  l_critical_flag msc_gantt_utils.number_arr;
  l_op_seq_num msc_gantt_utils.number_arr;
  l_res_seq_num msc_gantt_utils.number_arr;

  l_child_count number := 0;
begin
  open resources_cur (g_plan_id, p_instance_id, p_org_id, p_supply_id, p_op_seq_id);
  fetch resources_cur bulk collect into l_dept_id, l_res_id, l_trans_id, l_critical_flag,
    l_op_seq_num, l_res_seq_num;
  close resources_cur;

  for i in 1..l_dept_id.count
  loop -- {
    if ( g_peg_type = PEG_ORDERS ) then
      g_node_index := g_node_index + 1;
    else
      g_node_index := g_node_index + g_peg_type;
    end if;

    msc_gantt_utils.populateRowKeysIntoGantt(
      p_query_id => g_order_query_id,
      p_index => g_node_index,
      p_node_path => p_nodepath||COLON_SEPARATOR||to_char(l_child_count),
      p_node_type => RES_NODE,
      p_inst_id => p_instance_id,
      p_org_id => p_org_id,
      p_transaction_id => l_trans_id(i),
      p_dept_id => l_dept_id(i),
      p_res_id => l_res_id(i),
      p_node_level => g_node_level,
      p_critical_flag => l_critical_flag(i)
    );
    l_child_count := l_child_count + 1;
  end loop; -- }
end addResources;

procedure addOpResNodes(p_nodepath varchar2,
  p_instance_id number, p_org_id number, p_supply_id number,
  p_first_op out nocopy number) is

  l_critical_flag number;
  l_op_seq_num varchar2(50);
  l_op_seq_id number;
  l_op_desc varchar2(300);
  l_date1 date;
  l_from_row_index number;

  l_to_critical_flag number;
  l_to_op_seq_num varchar2(50);
  l_to_op_seq_id number;
  l_to_op_desc varchar2(300);
  l_dependency_type number;
  l_to_row_index number;

  isFirstOp boolean;
  l_op_node_path varchar2(50);
  l_child_count number := 0;

  l_dummy_date date;
  l_check_op_row number;

  l_from_op_seq number;
  l_from_dependency number;

  l_ops_intra_routing_cur ops_intra_routing_cur%rowtype;
begin
  put_line('addOpResNodes in');
  isFirstOp := true;
  p_first_op :=1;

  open ops_mfq_cur (g_op_query_id, p_supply_id, g_plan_id, p_instance_id);
  loop -- {
    fetch ops_mfq_cur into l_op_seq_num, l_op_seq_id, l_critical_flag, l_op_desc, l_date1;
    exit when ops_mfq_cur%notfound;

    l_from_row_index := mbp_null_value;
    l_check_op_row := mbp_null_value;
    open c_op_row_index_cur(g_order_query_id, p_supply_id, l_op_seq_num);
    fetch c_op_row_index_cur into l_check_op_row;
    close c_op_row_index_cur;

    put_line('regular oper '||l_op_seq_num||' '|| l_check_op_row);

  if ( nvl(l_check_op_row,mbp_null_value) = mbp_null_value) then --{
    if isFirstOp then
      p_first_op := l_op_seq_id;
      isFirstOp := false;
    end if;

    put_line('adding regular oper'||l_op_seq_num);

    if ( g_peg_type = PEG_ORDERS ) then
      g_node_index := g_node_index + 1;
    else
      g_node_index := g_node_index + g_peg_type;
    end if;

    msc_gantt_utils.populateRowKeysIntoGantt(
      p_query_id => g_order_query_id,
      p_index => g_node_index,
      p_node_path => p_nodepath||COLON_SEPARATOR||to_char(l_child_count),
      p_node_type => OP_NODE,
      p_transaction_id => p_supply_id,
      p_inst_id => p_instance_id,
      p_org_id => p_org_id,
      p_op_seq_num => l_op_seq_num,
      p_op_seq_id => l_op_seq_id,
      p_op_desc => l_op_desc,
      p_node_level => g_node_level,
      p_critical_flag => l_critical_flag
    );

    l_op_node_path := p_nodepath||COLON_SEPARATOR||to_char(l_child_count);
    l_child_count := l_child_count + 1;
    l_from_row_index := g_node_index;

    addResources(l_op_node_path, p_instance_id, p_org_id, p_supply_id, l_op_seq_num);
  end if; --}
  end loop; -- }
  close ops_mfq_cur;

    --intra-routing
    open ops_intra_routing_cur (p_supply_id, g_plan_id, p_instance_id);
    loop -- {
      fetch ops_intra_routing_cur into l_ops_intra_routing_cur;
      exit when ops_intra_routing_cur%notfound;
      updateOpParentLink(g_order_query_id, l_ops_intra_routing_cur.from_index,
        l_ops_intra_routing_cur.to_index, l_ops_intra_routing_cur.dependency_type);
    end loop; -- }
    close ops_intra_routing_cur;

  put_line('addOpResNodes out');
end addOpResNodes;

procedure insertOpIntoMFQ(p_instance_id number, p_org_id number, p_supply_id number) is
begin

    insert into msc_form_query
      (query_id,
      last_update_date, last_updated_by, creation_date, created_by, last_update_login,
      number1, number2, number3, char9, date1)
    select distinct
      g_op_query_id,
      trunc(sysdate), -1, trunc(sysdate), -1, -1,
      p_supply_id, mrr.operation_seq_num,
      msc_gantt_utils.isCriticalRes(g_plan_id, g_end_demand_id,
        mrr.supply_id, mrr.sr_instance_id,
	mrr.operation_seq_num, mrr.routing_sequence_id) critical_flag,
        mro.operation_description op_desc,
      mrr.start_date
    from msc_resource_requirements mrr,
      msc_routing_operations mro
    where mrr.plan_id = g_plan_id
      and mrr.sr_instance_id = p_instance_id
      and mrr.organization_id = p_org_id
      and mrr.supply_id = p_supply_id
      and mrr.end_date is not null
      and mrr.department_id <> -1
      and nvl(mrr.parent_id,2) = 2
      and mrr.plan_id = mro.plan_id (+)
      and mrr.sr_instance_id = mro.sr_instance_id (+)
      and mrr.routing_sequence_id = mro.routing_sequence_id (+)
      and mrr.operation_sequence_id = mro.operation_sequence_id (+);

end insertOpIntoMFQ;

procedure insertOpJobFromMDIntoMFQ (p_first_op number,
  p_instance_id number, p_org_id number, p_supply_id number) is

   l_inst_id msc_gantt_utils.number_arr;
   l_org_id msc_gantt_utils.number_arr;
   l_trans_id msc_gantt_utils.number_arr;
   l_op_seq_num msc_gantt_utils.number_arr;
   l_critical_flag msc_gantt_utils.number_arr;
begin
  if ( g_same_peg = SAME_PEG ) then -- {
    open op_supp_same_down_cur (g_plan_id, p_instance_id, p_supply_id,
      g_end_peg_query_id, p_first_op);
    fetch op_supp_same_down_cur bulk collect into l_op_seq_num, l_trans_id,
      l_inst_id, l_org_id, l_critical_flag;
    close op_supp_same_down_cur;
  elsif ( g_same_peg = ALL_PEG ) then
    open op_supp_diff_down_cur (g_plan_id, p_instance_id, p_supply_id,
      g_end_peg_query_id, p_first_op);
    fetch op_supp_diff_down_cur bulk collect into l_op_seq_num, l_trans_id,
      l_inst_id, l_org_id, l_critical_flag;
    close op_supp_diff_down_cur;
  end if; -- }

  -- supply_id, op_seq, tran_id, inst_id, org_id, critical
  for i in 1..l_op_seq_num.count
  loop -- {
    insert into msc_form_query
      (query_id,
      last_update_date, last_updated_by, creation_date, created_by, last_update_login,
      number1, number2, number3, number4,  number5, number6)
    values
      (g_dem_op_query_id,
      trunc(sysdate), -1, trunc(sysdate), -1, -1,
      p_supply_id, l_op_seq_num(i), l_trans_id(i),
      l_inst_id(i), l_org_id(i), l_critical_flag(i));
  end loop; -- }
end insertOpJobFromMDIntoMFQ;

-- if op exists in msc_demand but not in msc_resource_requirements,
-- show the op in the closest next op or prev op
procedure moveDmdOp(p_supply_id number) is

 v_op msc_gantt_utils.number_arr;
 v_new_op msc_gantt_utils.number_arr;
 v_dummy number;

begin
  select distinct mfq.number2, mfq.number2
    bulk collect into v_op, v_new_op
  from msc_form_query mfq
  where mfq.query_id = g_dem_op_query_id
    and mfq.number1 = p_supply_id
    and mfq.number2 not in (
      select mfq_mrr.number2
      from msc_form_query mfq_mrr
      where mfq_mrr.query_id = g_op_query_id
      and mfq_mrr.number1 = p_supply_id);
  for a in 1 .. v_op.count
  loop -- {
    -- find the closest next op
    select min(number2)
      into v_dummy
    from msc_form_query
    where query_id = g_op_query_id
      and   number1 = p_supply_id
      and   number2 > v_op(a);

    if v_dummy is null then
      -- if not found, find the closest prev op
      select max(number2)
        into v_dummy
      from msc_form_query
      where query_id = g_op_query_id
        and number1 = p_supply_id
        and number2 < v_op(a);
    end if;

    if (v_dummy is not null) then
      v_new_op(a) := v_dummy;
    else
      v_new_op(a) := v_op(a);
    end if;
  end loop; -- }

  forall a in 1.. v_op.count
    update msc_form_query
      set number2= v_new_op(a)
      where query_id = g_dem_op_query_id
        and number1 = p_supply_id
        and number2 = v_op(a);
  exception
    when no_data_found then
      null;
end moveDmdOp;

function getParentOpLink(p_supply_id1 number, p_supply_id2 number) return varchar2 is

  l_op_seq_num number;
  l_parent_link msc_gantt_query.parent_link%type;
begin
  if ( g_peg_type = PEG_DOWN ) then -- {
    open c_op_seq_num_cur(g_dem_op_query_id, p_supply_id1, p_supply_id2);
    fetch c_op_seq_num_cur into l_op_seq_num;
    close c_op_seq_num_cur;

    open c_op_row_index_cur(g_order_query_id, p_supply_id1, l_op_seq_num);
    fetch c_op_row_index_cur into l_parent_link;
    close c_op_row_index_cur;
  else -- PEG_UP
    open c_op_seq_num_cur(g_dem_op_query_id, p_supply_id2, p_supply_id1);
    fetch c_op_seq_num_cur into l_op_seq_num;
    close c_op_seq_num_cur;

    open c_op_row_index_cur(g_order_query_id, p_supply_id2, l_op_seq_num);
    fetch c_op_row_index_cur into l_parent_link;
    close c_op_row_index_cur;
  end if; -- }
  return l_parent_link;
end getParentOpLink;

procedure addCoProdNodes(p_parent_index number,
  p_instance_id number, p_org_id number, p_supply_id number) is

  l_inst_id msc_gantt_utils.number_arr;
  l_org_id msc_gantt_utils.number_arr;
  l_trans_id msc_gantt_utils.number_arr;
  l_op_seq_num msc_gantt_utils.number_arr;
  l_critical_flag msc_gantt_utils.number_arr;
  l_start_date msc_gantt_utils.char_arr;
  l_ordertype msc_gantt_utils.number_arr;

  cursor c_order_type (p_plan number, p_inst number, p_trx number) is
  select ms.order_type, ms.disposition_id
  from msc_supplies ms
  where ms.plan_id = p_plan
    and ms.sr_instance_id = p_inst
    and ms.transaction_id = p_trx;

  l_order_type number;
  l_disp_id number;
  l_node_type number;
begin
   open c_order_type (g_plan_id, p_instance_id, p_supply_id);
   fetch c_order_type into l_order_type, l_disp_id;
   close c_order_type;

   --put_line(' order type '||l_order_type||'  disp id '||l_disp_id);

   if l_order_type in (14,15,16,17,28) then
     open coprod_supplies_cur (g_plan_id, p_instance_id, l_disp_id);
     fetch coprod_supplies_cur bulk collect into l_inst_id, l_org_id,
       l_trans_id, l_critical_flag, l_start_date, l_ordertype;
     close coprod_supplies_cur;

   else
     open coprod_supplies_cur (g_plan_id, p_instance_id, p_supply_id);
     fetch coprod_supplies_cur bulk collect into l_inst_id, l_org_id,
       l_trans_id, l_critical_flag, l_start_date, l_ordertype;
     close coprod_supplies_cur;
   end if;

  for i in 1..l_inst_id.count
   loop -- {
     g_node_index := g_node_index + g_peg_type;

     if (l_ordertype(i) in (14,15,16,17,28)) then
       l_node_type := COPROD_NODE;
     else
       l_node_type := JOB_NODE;
     end if;

     put_line('addcoprodnodes p_supply_id '|| p_supply_id ||' l_trans_id '||l_trans_id(i) );

     msc_gantt_utils.populateRowKeysIntoGantt(
       p_query_id => g_order_query_id,
       p_index => g_node_index,
       p_node_path => g_node_index,
       p_node_type => l_node_type,
       p_inst_id => l_inst_id(i),
       p_org_id => l_org_id(i),
       p_transaction_id => l_trans_id(i),
       p_critical_flag => l_critical_flag(i),
       p_node_level => g_node_level
     );

  end loop; -- }

end addCoProdNodes;

procedure addPegUpNodes(p_parent_index number,
  p_instance_id number, p_org_id number, p_supply_id number) is

  l_parent_link msc_gantt_query.parent_link%type;
  l_first_op number;

  l_inst_id msc_gantt_utils.number_arr;
  l_org_id msc_gantt_utils.number_arr;
  l_trans_id msc_gantt_utils.number_arr;
  l_critical_flag msc_gantt_utils.number_arr;
  l_start_date msc_gantt_utils.char_arr;
  l_order_type msc_gantt_utils.number_arr;

  l_row_type number;
  l_row_index number;
begin
  open supplies_diff_up_cur (g_plan_id, p_instance_id, p_supply_id,
    g_end_peg_query_id, g_dem_op_query_id);
  fetch supplies_diff_up_cur bulk collect into l_inst_id, l_org_id,
      l_trans_id, l_critical_flag, l_start_date, l_order_type;
  close supplies_diff_up_cur;

  open c_check_row_type(g_order_query_id, p_parent_index);
  fetch c_check_row_type into l_row_type;
  close c_check_row_type;

  for i in 1..l_inst_id.count
  loop -- {

    put_line('addPegUpNodes in '||' p_supply_id ' || p_supply_id ||' l_trans_id '|| l_trans_id(i) );

    open c_dmd_row_index (g_order_query_id, l_inst_id(i), l_trans_id(i));
    fetch c_dmd_row_index into l_row_index;
    close c_dmd_row_index ;

    if (nvl(l_row_index, mbp_null_value)  = mbp_null_value) then

    g_node_index := g_node_index + g_peg_type;

    msc_gantt_utils.populateRowKeysIntoGantt(
      p_query_id => g_order_query_id,
      p_index => g_node_index,
      p_node_path => g_node_index,
      p_node_type => JOB_NODE,
      p_inst_id => l_inst_id(i),
      p_org_id => l_org_id(i),
      p_transaction_id => l_trans_id(i),
      p_critical_flag => l_critical_flag(i),
      p_node_level => g_node_level
    );

   if (l_row_type = JOB_NODE) then
     l_parent_link := getParentOpLink(p_supply_id, l_trans_id(i));
     updateParentLink(g_order_query_id, p_parent_index, nvl(l_parent_link, g_node_index) );
   elsif (l_row_type = COPROD_NODE) then
     updateParentLinkforCoprod(g_order_query_id, p_parent_index, g_node_index);
   end if;

   insertOpIntoMFQ(l_inst_id(i), l_org_id(i), l_trans_id(i));
   addOpResNodes(g_node_index, l_inst_id(i), l_org_id(i), l_trans_id(i), l_first_op);
   insertOpJobFromMDIntoMFQ(l_first_op, l_inst_id(i), l_org_id(i), l_trans_id(i));
   moveDmdOp(p_supply_id);
   addCoProdNodes(g_node_index, l_inst_id(i), l_org_id(i), l_trans_id(i));
   else
     -- row is already there, so just update the parent_link of this node to point to l_row_index
     updateParentLinkforCoprod(g_order_query_id, p_parent_index, l_row_index);
   end if;


  end loop; -- }
end addPegUpNodes;

function isDupInMGQ(p_query number, p_inst number, p_trx number) return number is

  cursor c_dup is
  select row_index
  from msc_gantt_query
  where query_id = p_query
    and sr_instance_id = p_inst
    and transaction_id = p_trx;

  l_temp number;
begin
  put_line('isDupInMGQ in  p_query '|| p_query || ' p_inst ' || p_inst ||' p_trx '|| p_trx );
  open c_dup;
  fetch c_dup into l_temp;
  close c_dup;

  l_temp := nvl(l_temp, mbp_null_value);
  put_line('isDupInMGQ out '||l_temp);
  return l_temp;
end isDupInMGQ;

procedure addPegDownJobNodes(p_parent_index number,
  p_instance_id number, p_org_id number,
  p_supply_id number, p_fetch_type number) is

  l_parent_link msc_gantt_query.parent_link%type;

  l_inst_id msc_gantt_utils.number_arr;
  l_org_id msc_gantt_utils.number_arr;
  l_trans_id msc_gantt_utils.number_arr;
  l_op_seq_num msc_gantt_utils.number_arr;
  l_critical_flag msc_gantt_utils.number_arr;
  l_start_date msc_gantt_utils.char_arr;
  l_order_type msc_gantt_utils.number_arr;

  l_node_type number;

  l_dup_row_index number;

  cursor c_check_op_in_mrr (p_plan number, p_supply number) is
  select 1
  from msc_resource_requirements
  where plan_id = p_plan
  and supply_id = p_supply
  and nvl(parent_id,2) = 2;

  l_parent_op_found number;
  l_child_op_found number;

begin
  put_line('addPegDownJobNodes in');
  if ( p_fetch_type = OP_JOB_NODE ) then -- {
    put_line('addPegDownJobNodes op_job_node ');
    open supplies_mfq_cur(g_dem_op_query_id, g_plan_id, p_instance_id, p_supply_id);
    fetch supplies_mfq_cur bulk collect into l_inst_id, l_org_id,
      l_trans_id, l_critical_flag, l_start_date, l_order_type;
    close supplies_mfq_cur;
  elsif ( g_same_peg = SAME_PEG ) then
    put_line('addPegDownJobNodes same_peg ');
    open supplies_same_down_cur (g_plan_id, p_instance_id, p_supply_id,
      g_end_peg_query_id, g_dem_op_query_id);
    fetch supplies_same_down_cur bulk collect into l_inst_id, l_org_id,
      l_trans_id, l_critical_flag, l_start_date, l_order_type;
    close supplies_same_down_cur;
  elsif ( g_same_peg = ALL_PEG ) then
    put_line('addPegDownJobNodes all_peg ');
    open supplies_diff_down_cur (g_plan_id, p_instance_id, p_supply_id,
      g_end_peg_query_id, g_dem_op_query_id);
    fetch supplies_diff_down_cur bulk collect into l_inst_id, l_org_id,
      l_trans_id, l_critical_flag, l_start_date, l_order_type;
    close supplies_diff_down_cur;
  end if; -- }

  for i in 1..l_inst_id.count
  loop -- {

    if ( p_fetch_type = OP_JOB_NODE ) then
      l_parent_link := getParentOpLink(p_supply_id, l_trans_id(i));
    elsif ( p_fetch_type = TRANSFER_JOB_NODE ) then
      l_parent_link := p_parent_index;
    end if;

    l_dup_row_index := isDupInMGQ(g_order_query_id, l_inst_id(i), l_trans_id(i));
    put_line('l_dup_row_index '|| l_dup_row_index);
    if ( l_dup_row_index <> mbp_null_value ) then -- {
      updateParentLink(g_order_query_id, l_dup_row_index, l_parent_link);
    else
      g_node_index := g_node_index + g_peg_type;
      if ( l_order_type(i) in (14,15,16,17,28) ) then
        l_node_type := COPROD_NODE;
      else
        l_node_type := JOB_NODE;
      end if;

      msc_gantt_utils.populateRowKeysIntoGantt(
        p_query_id => g_order_query_id,
        p_index => g_node_index,
        p_node_path => g_node_index,
        p_node_type => l_node_type,
        p_inst_id => l_inst_id(i),
        p_org_id => l_org_id(i),
        p_transaction_id => l_trans_id(i),
        p_parent_link => l_parent_link,
        p_critical_flag => l_critical_flag(i),
        p_node_level => g_node_level
      );


/*
      if (l_parent_link is null) then
        open c_check_op_in_mrr (g_plan_id, p_supply_id);
        fetch c_check_op_in_mrr into l_parent_op_found;
        close c_check_op_in_mrr;
      end if;
*/
        updateParentLink(g_order_query_id, g_node_index, p_parent_index);

      addCoProdNodes(g_node_index, l_inst_id(i), l_org_id(i), l_trans_id(i));
      put_line('addPegDownJobNodes '||l_trans_id(i) );
    end if;
  end loop; -- }
  put_line('addPegDownJobNodes out');
end addPegDownJobNodes;

procedure ordersPegging(p_start_index number default null) is

   p_supply_id number;
   p_instance_id number;
   p_org_id number;
   p_op_seq_id number;
   p_first_supply_id number;

   p_nodetype number;
   p_nodepath varchar2(200);

   current_index number := 0;
   hasMore boolean := true;
   l_dummy_sort varchar2(10);

  l_first_op number;

  cursor c_next_row (p_query_id number, p_row_index number) is
  select transaction_id, organization_id, sr_instance_id, op_seq_id,
    node_type, node_path
  from msc_gantt_query
  where query_id = p_query_id
    and row_index = p_row_index;

  cursor c_next_row_index (p_query_id number,
    p_row_index number, p_peg_dir number) is
  select row_index, '1' dummy_sort
  from msc_gantt_query
  where query_id = p_query_id
    and (node_type = JOB_NODE
      or (node_type = COPROD_NODE and p_peg_dir = PEG_UP)
      or (node_type = COPROD_NODE and p_peg_dir = PEG_DOWN)
      or (node_type = COPROD_NODE and p_peg_dir = PEG_ORDERS))
    and ((p_peg_dir = PEG_DOWN and row_index > p_row_index)
      or (p_peg_dir = PEG_ORDERS  and row_index > p_row_index)
      or (p_peg_dir = PEG_UP and row_index < p_row_index ))
  order by
    decode(p_peg_dir, PEG_UP, row_index, dummy_sort) desc,
    row_index asc;

  cursor c_next_node_level(p_query_id number,
    p_peg_dir number, p_row_index number) is
  select decode(p_peg_dir,
    PEG_UP, node_level + PEG_UP,
    PEG_DOWN, node_level + PEG_DOWN,
    PEG_ORDERS, node_level + 1 )
  from msc_gantt_query
  where query_id = p_query_id
    and row_index = p_row_index;

BEGIN
  put_line('ordersPegging in');
  put_line('query_ids g_op_query_id '||g_op_query_id
    ||' g_end_peg_query_id '||g_end_peg_query_id
    ||' g_dem_op_query_id '||g_dem_op_query_id );

   --5530776 bugfix, for demand view, start with 1 instead of 0
   if (p_start_index is not null) then
     current_index := p_start_index;
   end if;

   while ( hasMore )
   loop -- {

     open c_next_row(g_order_query_id, current_index);
     fetch c_next_row into p_supply_id, p_org_id, p_instance_id, p_op_seq_id,
       p_nodetype, p_nodepath;
     close c_next_row;

     if ( p_first_supply_id is null) then
       p_first_supply_id := p_supply_id;
     end if;

     put_line('node '
       || ' p_supply_id '|| p_supply_id
       || ' p_op_seq_id '|| p_op_seq_id
       || ' p_nodetype '|| p_nodetype
       || ' p_nodepath '|| p_nodepath
       || ' current_index '|| current_index
       || ' g_node_index '||g_node_index);

      if ( p_nodetype = JOB_NODE
           or ( p_nodetype = COPROD_NODE and g_peg_type in ( PEG_UP, PEG_DOWN, PEG_ORDERS ))) then -- {

        open c_next_node_level(g_order_query_id, g_peg_type, current_index);
	fetch c_next_node_level into g_node_level;
	close c_next_node_level;

        if ( g_peg_type in ( PEG_DOWN, PEG_ORDERS ) ) then -- {
	  insertOpIntoMFQ(p_instance_id, p_org_id, p_supply_id);
	  addOpResNodes(p_nodepath, p_instance_id, p_org_id, p_supply_id, l_first_op);
          if ( g_peg_type = PEG_DOWN ) then
    	    insertOpJobFromMDIntoMFQ( l_first_op, p_instance_id, p_org_id, p_supply_id);
            moveDmdOp(p_supply_id);
            if ( p_first_supply_id = p_supply_id ) then
              addCoProdNodes(current_index, p_instance_id, p_org_id, p_supply_id);
            end if;
	    addPegDownJobNodes(current_index, p_instance_id, p_org_id, p_supply_id, OP_JOB_NODE);
    	    addPegDownJobNodes(current_index, p_instance_id, p_org_id, p_supply_id, TRANSFER_JOB_NODE);
	  end if;
	else --PEG_UP
	  if ( g_peg_up_and_down <> PEG_UP_AND_DOWN and current_index = 0) then
  	    insertOpIntoMFQ(p_instance_id, p_org_id, p_supply_id);
	    addOpResNodes(p_nodepath, p_instance_id, p_org_id, p_supply_id, l_first_op);
	  end if;
            if ( p_first_supply_id = p_supply_id ) then
              addCoProdNodes(current_index, p_instance_id, p_org_id, p_supply_id);
            end if;
  	  addPegUpNodes(current_index, p_instance_id, p_org_id, p_supply_id);
	  addEndDemandNodes(p_instance_id, p_supply_id, current_index);
        end if; -- }
     end if;  -- }

     open c_next_row_index(g_order_query_id, current_index, g_peg_type);
     fetch c_next_row_index into current_index, l_dummy_sort;
     if ( c_next_row_index%notfound) then
       hasMore := false; -- no more data
     end if;
     close c_next_row_index;
     put_line('next row index '||current_index);
   end loop; -- }

put_line('ordersPegging out');
END ordersPegging;

procedure demandView (p_list varchar2) is

  l_inst_id msc_gantt_utils.number_arr;
  l_org_id msc_gantt_utils.number_arr;
  l_trans_id msc_gantt_utils.number_arr;
  l_op_seq_num msc_gantt_utils.number_arr;
  l_critical_flag msc_gantt_utils.number_arr;

  s_inst_id number;
  s_org_id number;
  s_trans_id number;

  i number ;
  l_one_record varchar2(100);
  l_parent_index number;

BEGIN
  put_line('demandView in');

  i := 1;
  l_one_record := substr(p_list,instr(p_list,'(',1,i)+1,
    instr(p_list,')',1,i)-instr(p_list,'(',1,i)-1);
  s_inst_id := to_number(substr(l_one_record,1,instr(l_one_record,',')-1));
  s_trans_id := to_number(substr(l_one_record,instr(l_one_record,',')+1));

    g_end_demand_id := s_trans_id;

  open demand_cur(g_plan_id, g_end_demand_id);
  fetch demand_cur into s_inst_id, s_org_id, s_trans_id ;
  close demand_cur;

  msc_gantt_utils.populateRowKeysIntoGantt(
	p_query_id => g_order_query_id,
	p_index => g_node_index,
	p_node_path => g_node_index,
	p_node_type => END_DEMAND_NODE,
	p_transaction_id => s_trans_id,
	p_inst_id => s_inst_id,
	p_org_id => s_org_id,
        p_critical_flag => 1,
	p_node_level => g_node_level
  );

  g_node_level := g_node_level + PEG_DOWN;
  l_parent_index := g_node_index;

  open end_pegs_cur(g_plan_id, g_end_demand_id);
  fetch end_pegs_cur bulk collect into  l_inst_id, l_org_id, l_trans_id, l_critical_flag;
  close end_pegs_cur;

  for a in 1.. l_org_id.count
  loop -- {
    g_node_index := g_node_index + PEG_DOWN;

    msc_gantt_utils.populateRowKeysIntoGantt(
      p_query_id => g_order_query_id,
      p_index => g_node_index,
      p_node_path => g_node_index,
      p_node_type => JOB_NODE,
      p_transaction_id => l_trans_id(a),
      p_inst_id => l_inst_id(a),
      p_org_id => l_org_id(a),
      p_critical_flag => l_critical_flag(a),
      p_node_level => g_node_level
    );

    updateParentLink(g_order_query_id, g_node_index, l_parent_index, null);

  end loop; -- }

  g_node_level := g_node_level + PEG_DOWN;

  g_end_peg_query_id := msc_gantt_utils.getMFQSequence(g_end_peg_query_id);
  msc_gantt_utils.populateEndPegsMFQ(g_plan_id, g_end_demand_id, g_end_peg_query_id);

  ordersPegging(1);

  put_line('demandView out');
END demandView;

procedure updateNodeLevels(p_query_id number) is
  l_min_node_level number;

  cursor c_min_level is
  select abs(min(node_level))
  from msc_gantt_query
  where query_id = p_query_id;

begin
  open c_min_level;
  fetch c_min_level into l_min_node_level;
  close c_min_level;

  update msc_gantt_query
  set node_level = l_min_node_level + node_level + 1
  where query_id = p_query_id;
end updateNodeLevels;

function getNodesCount(p_query_id number) return varchar2 is
  cursor c_node_count_cur is
  select node_type, count(*)
  from msc_gantt_query
  where query_id = p_query_id
  group by node_type;

  cursor c_first_row_cur is
  select min(row_index)
  from msc_gantt_query
  where query_id = p_query_id;

  l_node_type number;
  l_count number;
  l_first_index number;
  l_total_count number := 0;
  l_node_count varchar2(50);
begin
  open c_node_count_cur;
  loop -- {
    fetch c_node_count_cur into l_node_type, l_count;
    exit when c_node_count_cur%notfound;
    l_total_count := l_total_count + l_count;
    if ( l_node_count is null ) then
      l_node_count := l_node_type || COLON_SEPARATOR || l_count;
    else
      l_node_count := l_node_count || COLON_SEPARATOR ||
        l_node_type || COLON_SEPARATOR || l_count;
    end if;
  end loop; -- }
  close c_node_count_cur;

  open c_first_row_cur;
  fetch c_first_row_cur into l_first_index;
  close c_first_row_cur;

  l_node_count := l_total_count || COLON_SEPARATOR || l_first_index
    || COLON_SEPARATOR || l_node_count;
  return l_node_count;
end getNodesCount;

--
-- Public Apis
--
function orderView(p_query_id in number,
  p_plan_id number, p_list varchar2, p_filter_type number,
  p_view_type number, p_peg_type number,
  p_node_count out nocopy varchar2,
  p_refresh boolean default false) return number is

  cursor c_max_index_cur (l_query number) is
  select max(row_index)
  from msc_gantt_query
  where query_id = l_query ;
BEGIN
  put_line('orderView in');
  g_node_index := 0;
  g_node_level := 1;
  g_peg_type := p_peg_type;
  g_same_peg := ALL_PEG;
  g_peg_up_and_down := p_peg_type;

  g_plan_info := getPlanInfo(p_plan_id);
  if (p_query_id is null) then
    g_order_query_id := msc_gantt_utils.getGanttSequence();
  else
    g_order_query_id := p_query_id;
  end if;

  if ( p_view_type = DEMAND_VIEW ) then -- {
    g_node_level := 1;
    g_peg_type := PEG_DOWN;
    -- g_same_peg := SAME_PEG;
    g_same_peg := ALL_PEG; -- 3863300 bug fix...

    g_op_query_id := msc_gantt_utils.getMFQSequence(g_op_query_id);
    g_dem_op_query_id := msc_gantt_utils.getMFQSequence(g_dem_op_query_id);

    demandView(p_list);

    linkQueries(p_query_id, g_order_query_id, p_view_type, p_list);
    --updateNodeLevels(g_order_query_id);
    p_node_count := getNodesCount(g_order_query_id);
    return g_order_query_id;
  end if; -- }

  if (p_query_id is null) then
    msc_gantt_utils.populateListIntoGantt(g_order_query_id, p_plan_id,
      p_list, p_filter_type, ORDER_VIEW);
  end if;

  if ( g_peg_type = PEG_UP_AND_DOWN ) then -- {
    g_peg_type := PEG_DOWN;
    g_op_query_id := msc_gantt_utils.getMFQSequence(g_op_query_id);
    g_dem_op_query_id := msc_gantt_utils.getMFQSequence(g_dem_op_query_id);
    ordersPegging();

    g_peg_type := PEG_UP;
    g_node_index := 0;
    g_op_query_id := msc_gantt_utils.getMFQSequence(g_op_query_id);
    g_dem_op_query_id := msc_gantt_utils.getMFQSequence(g_dem_op_query_id);
    ordersPegging();
  elsif ( g_peg_type in (PEG_UP, PEG_DOWN) ) then
    g_op_query_id := msc_gantt_utils.getMFQSequence(g_op_query_id);
    g_dem_op_query_id := msc_gantt_utils.getMFQSequence(g_dem_op_query_id);
    ordersPegging();
  elsif ( g_peg_type = PEG_ORDERS ) then
    open c_max_index_cur(g_order_query_id);
    fetch c_max_index_cur into g_node_index;
    close c_max_index_cur;
    g_op_query_id := msc_gantt_utils.getMFQSequence(g_op_query_id);
    g_dem_op_query_id := msc_gantt_utils.getMFQSequence(g_dem_op_query_id);
    ordersPegging();
  end if; -- }

  if ( g_peg_type in (PEG_UP, PEG_UP_AND_DOWN) ) then
    --updateNodeLevels(g_order_query_id);
    null;
  end if;

  linkQueries(p_query_id, g_order_query_id, p_view_type, p_list);
  p_node_count := getNodesCount(g_order_query_id);

  put_line('orderView out');
  return g_order_query_id;
END orderView;

function getResult(p_query_id number,
  p_from_index number, p_to_index number,
  p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_node_level number default null,
  p_sort_node number default null,
  p_sort_column varchar2 default null,
  p_sort_order varchar2 default null,
  p_res_nodes_only varchar2 default null) return number is
begin
  return msc_gantt_utils.getResult(p_query_id, p_from_index, p_to_index,
    g_plan_id, p_out_data, p_node_level, p_sort_node, p_sort_column, p_sort_order,
    p_res_nodes_only);
end getResult;

--p_trx_list is (inst_id, trx id),(inst_id, trx_id)
procedure resCharges(p_query_id number,
  p_trx_list varchar2, p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl) is
begin
  msc_gantt_utils.resCharges(p_query_id, g_plan_id, p_trx_list, p_out_data);
end resCharges;

--p_trx_list is (inst_id, node_type, trx id),(inst_id, node_type, trx_id)
procedure segmentPegging(p_query_id number,
  p_trx_list varchar2, p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl) is
begin
  msc_gantt_utils.segmentPegging(p_query_id, g_plan_id, p_trx_list, p_out_data);
end segmentPegging;

function addSimuAltResToView(p_query_id number, p_view_type number,
  p_node_type number, p_node_list varchar2, p_out out nocopy varchar2) return number is

  l_row_index number;

  l_inst_id number;
  l_org_id number;
  l_dept_id number;
  l_res_id number;
  l_res_instance_id number;
  l_serial_number varchar2(30);
  l_one_record varchar2(250);

  cursor c_res_inst is
  select res_instance_id,
    nvl(serial_number, MBP_NULL_VALUE_CHAR) serial_number
  from msc_dept_res_instances
  where plan_id = g_plan_id
    and sr_instance_id = l_inst_id
    and organization_id = l_org_id
    and department_id = l_dept_id
    and resource_id = l_res_id;

l_row_count number;
begin
  select nvl(max(row_index),0)
  into l_row_index
  from msc_gantt_query
  where query_id = p_query_id;

  l_one_record := substr(p_node_list,instr(p_node_list,'(',1,1)+1,
          instr(p_node_list,')',1,1)-instr(p_node_list,'(',1,1)-1);

  msc_gantt_utils.parseResString(l_one_record, l_inst_id, l_org_id, l_dept_id, l_res_id,
    l_res_instance_id, l_serial_number);
  l_one_record := null;

  l_row_count := msc_gantt_utils.isResRowInGantt(p_query_id, g_plan_id, l_inst_id, l_org_id, l_dept_id,
    l_res_id, mbp_null_value, mbp_null_value_char);

  if ( l_row_count = sys_no ) then
    msc_gantt_utils.populateResIntoGantt(p_query_id, l_row_index, l_one_record,
      g_plan_id, l_inst_id, l_org_id, l_dept_id, l_res_id, MBP_NULL_VALUE, MBP_NULL_VALUE_CHAR, sys_no);
  end if;

    for c_res_inst_row in c_res_inst
    loop -- {
      l_row_count := msc_gantt_utils.isResRowInGantt(p_query_id, g_plan_id, l_inst_id, l_org_id,
        l_dept_id, l_res_id, c_res_inst_row.res_instance_id, c_res_inst_row.serial_number);

      if (l_row_count = sys_no ) then
        --l_row_index := l_row_index + 1;
        msc_gantt_utils.populateResIntoGantt(p_query_id, l_row_index, l_one_record,
          g_plan_id, l_inst_id, l_org_id, l_dept_id, l_res_id,
  	  c_res_inst_row.res_instance_id, c_res_inst_row.serial_number, sys_no);
      end if;
    end loop; -- }

  return l_row_index-1;
end addSimuAltResToView;

function addResToResView(p_from_query_id number, p_to_query_id in out nocopy number,
  p_from_index number, p_critical number) return number is

  cursor c_node_type_cur is
  select node_type, node_path
  from msc_gantt_query
  where query_id = p_from_query_id
  and row_index = p_from_index;

  l_node_type number;
  l_node_path varchar2(250);
  l_row_index number;
  l_one_record varchar2(250);

  v_inst_id msc_gantt_utils.number_arr;
  v_org_id msc_gantt_utils.number_arr;
  v_dept_id msc_gantt_utils.number_arr;
  v_res_id msc_gantt_utils.number_arr;

  l_row_found number := sys_no;
  checkRow boolean := false;

begin
  open c_node_type_cur;
  fetch c_node_type_cur into l_node_type, l_node_path;
  close c_node_type_cur;

  if ( p_to_query_id is null ) then -- {
    p_to_query_id := msc_gantt_utils.getGanttSequence();
    l_row_index := 1;
  else
    select nvl(max(row_index),0)
    into l_row_index
    from msc_gantt_query
    where query_id = p_to_query_id;
    checkRow := true;
  end if; -- }

  if (p_critical = CRITICAL_PATH ) then -- {
    select distinct sr_instance_id, organization_id, department_id, resource_id
    bulk collect into v_inst_id, v_org_id, v_dept_id, v_res_id
    from msc_gantt_query mgq
    where query_id = p_from_query_id
      and node_type = RES_NODE
      and ((p_from_index = 0) or ( (l_node_type in (JOB_NODE, OP_NODE) and node_path like l_node_path||':%')
            or (l_node_type = RES_NODE and row_index = p_from_index) ))
      and nvl(critical_flag, mbp_null_value)  > 0;
  else
    select distinct sr_instance_id, organization_id, department_id, resource_id
    bulk collect into v_inst_id, v_org_id, v_dept_id, v_res_id
    from msc_gantt_query mgq
    where query_id = p_from_query_id
      and node_type = RES_NODE
      and ((p_from_index = 0) or ( (l_node_type in (JOB_NODE, OP_NODE) and node_path like l_node_path||':%')
            or (l_node_type = RES_NODE and row_index = p_from_index) ));
  end if; -- }

  for i in 1..v_inst_id.count
  loop -- {
    if ( checkRow ) then
      l_row_found := msc_gantt_utils.isResRowInGantt(p_to_query_id, g_plan_id,
        v_inst_id(i), v_org_id(i), v_dept_id(i), v_res_id(i), MBP_NULL_VALUE, MBP_NULL_VALUE_CHAR);
    end if;

    if ( l_row_found = sys_no ) then
      msc_gantt_utils.populateResIntoGantt(p_to_query_id, l_row_index, l_one_record,
        g_plan_id, v_inst_id(i), v_org_id(i), v_dept_id(i), v_res_id(i),
	mbp_null_value, MBP_NULL_VALUE_CHAR, sys_yes); --5521235 will add res instances too
      l_row_index := l_row_index + 1;
    end if;
  end loop; -- }

  return l_row_index - 1;
end addResToResView;

function addSuppToSuppView(p_from_query_id number, p_to_query_id in out nocopy number,
  p_from_index number) return number is

  cursor c_node_type_cur is
  select node_type, node_path
  from msc_gantt_query
  where query_id = p_from_query_id
    and row_index = p_from_index;

  l_node_type number;
  l_node_path varchar2(250);
  l_row_index number;
  l_one_record varchar2(250);

  v_inst_id msc_gantt_utils.number_arr;
  v_org_id msc_gantt_utils.number_arr;
  v_item_id msc_gantt_utils.number_arr;
  v_supp_id msc_gantt_utils.number_arr;
  v_supp_site_id msc_gantt_utils.number_arr;

  l_row_found number := 0;
  checkRow boolean := false;
begin
  open c_node_type_cur;
  fetch c_node_type_cur into l_node_type, l_node_path;
  close c_node_type_cur;

  if ( l_node_type not in (JOB_NODE, COPROD_NODE) ) then
    return 0;
  end if;

  if ( p_to_query_id is null ) then -- {
    p_to_query_id := msc_gantt_utils.getGanttSequence();
    l_row_index := 1;
  else
    select nvl(max(row_index),0) + 1
    into l_row_index
    from msc_gantt_query
    where query_id = p_to_query_id;
    checkRow := true;
  end if; -- }

  select
    ms.sr_instance_id,
    ms.organization_id,
    ms.inventory_item_id,
    nvl(ms.supplier_id, mbp_null_value),
    nvl(ms.supplier_site_id, mbp_null_value)
  bulk collect into v_inst_id, v_org_id, v_item_id, v_supp_id, v_supp_site_id
  from msc_gantt_query mgq,
    msc_supplies ms
  where mgq.query_id = p_from_query_id
    and mgq.row_index = p_from_index
    and ms.plan_id = g_plan_id
    and ms.sr_instance_id = mgq.sr_instance_id
    and ms.transaction_id = mgq.transaction_id;

  for i in 1..v_inst_id.count
  loop -- {
    if ( checkRow ) then
      open check_supp_row_cur (p_to_query_id, g_plan_id,
        v_inst_id(i), v_org_id(i), v_item_id(i), v_supp_id(i), v_supp_site_id(i));
      fetch check_supp_row_cur into l_row_found;
      close check_supp_row_cur;
    end if;

    if ( l_row_found = 0 ) then
      msc_gantt_utils.populateSuppIntoGantt(p_to_query_id, l_row_index, l_one_record,
        g_plan_id, v_inst_id(i), v_org_id(i),v_item_id(i), v_supp_id(i), v_supp_site_id(i));
      l_row_index := l_row_index + 1;
    end if;
  end loop; -- }

  -- put_line('addSuppToSuppView: rows added: '||l_row_index - 1);
  return l_row_index - 1;
end addSuppToSuppView;

function AddToOrdersView(p_from_query_id number, p_to_query_id in out nocopy number,
  p_from_index number, p_from_view_type number,
  p_context_value varchar2, p_context_value2 varchar2  default null) return number is
  l_row_index number;

  v_inst_id msc_gantt_utils.number_arr;
  v_org_id msc_gantt_utils.number_arr;
  v_trx_id msc_gantt_utils.number_arr;

  l_row_found number := 0;
  checkRow boolean := false;
  l_temp_query_id number;
  l_node_count varchar2(100);

  l_row_type number;

  cursor c_rowtype (ll_query number, ll_index number)is
  select mgq.res_instance_id
  from msc_gantt_query mgq
   where mgq.query_id = ll_query
      and mgq.row_index = ll_index;

begin
  if ( p_to_query_id is null ) then -- {
    p_to_query_id := msc_gantt_utils.getGanttSequence();
    g_order_query_id := p_to_query_id;
    g_node_level := 1;
    l_row_index := 1;
  else
    select nvl(max(row_index),0) + 1
    into l_row_index
    from msc_gantt_query
    where query_id = p_to_query_id;
    checkRow := true;
    g_order_query_id := p_to_query_id;
  end if; -- }

  open c_rowtype (p_from_query_id, p_from_index);
  fetch c_rowtype into l_row_type;
  close c_rowtype;
  if ( p_from_view_type = RES_ACTIVITIES_VIEW ) then -- {
    if (l_row_type = mbp_null_value) then
    select distinct mrr.sr_instance_id, mrr.organization_id, mrr.supply_id
    bulk collect into v_inst_id, v_org_id, v_trx_id
    from msc_gantt_query mgq,
      msc_gantt_dtl_query mgdq,
      msc_resource_requirements mrr
    where mgq.query_id = p_from_query_id
      and mgq.row_index = p_from_index
      and mgq.query_id = mgdq.query_id
      and mgq.row_index = mgdq.row_index
      and mgdq.transaction_id = to_number(p_context_value)
      and mrr.plan_id = g_plan_id
      and mrr.sr_instance_id = mgq.sr_instance_id
      and mrr.organization_id = mgq.organization_id
      and mrr.department_id = mgq.department_id
      and mrr.resource_id = mgq.resource_id
      and mrr.transaction_id = mgdq.transaction_id
      and mrr.parent_id = 2;
    else
    select distinct mrir.sr_instance_id, mrir.organization_id, mrir.supply_id
    bulk collect into v_inst_id, v_org_id, v_trx_id
    from msc_gantt_query mgq,
      msc_gantt_dtl_query mgdq,
      msc_resource_instance_reqs mrir
    where mgq.query_id = p_from_query_id
      and mgq.row_index = p_from_index
      and mgq.query_id = mgdq.query_id
      and mgq.row_index = mgdq.row_index
      and mgdq.transaction_id = to_number(p_context_value)
      and mrir.plan_id = g_plan_id
      and mrir.sr_instance_id = mgq.sr_instance_id
      and mrir.organization_id = mgq.organization_id
      and mrir.department_id = mgq.department_id
      and mrir.resource_id = mgq.resource_id
      and mrir.res_instance_id = mgq.res_instance_id
      and mrir.serial_number = mgq.serial_number
      and mrir.res_inst_transaction_id = mgdq.transaction_id
      and mrir.parent_id = 2;
   end if;

  elsif ( p_from_view_type = RES_HOURS_VIEW ) then

    select distinct mrr.sr_instance_id, mrr.organization_id, mrr.supply_id
    bulk collect into v_inst_id, v_org_id, v_trx_id
    from msc_gantt_query mgq,
      msc_gantt_dtl_query mgdq,
      msc_resource_requirements mrr
    where mgq.query_id = p_from_query_id
      and mgq.row_index = p_from_index
      and mgq.query_id = mgdq.query_id
      and mgq.row_index = mgdq.row_index
      and mrr.plan_id = g_plan_id
      and mrr.sr_instance_id = mgq.sr_instance_id
      and mrr.organization_id = mgq.organization_id
      and mrr.department_id = mgq.department_id
      and mrr.resource_id = mgq.resource_id
      and ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrr.start_date,
              mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	      between to_date(p_context_value,FORMAT_MASK) and to_date(p_context_value2,FORMAT_MASK)
            or msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrr.start_date,
              mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	      between to_date(p_context_value,FORMAT_MASK) and to_date(p_context_value2,FORMAT_MASK))
      and mrr.parent_id = 2;

  elsif ( p_from_view_type = RES_UNITS_VIEW ) then
    return 0;  -- not supported for this view..
  elsif ( p_from_view_type = SUPPLIER_VIEW ) then
    select distinct msr.sr_instance_id, msr.organization_id, msr.supply_id
    bulk collect into v_inst_id, v_org_id, v_trx_id
    from msc_gantt_query mgq,
      msc_supplier_requirements msr
    where mgq.query_id = p_from_query_id
      and mgq.row_index = p_from_index
      and msr.plan_id = g_plan_id
      --and msr.sr_instance_id = mgq.sr_instance_id
      --and msr.organization_id = mgq.organization_id
      and msr.inventory_item_id = mgq.inventory_item_id
      and msr.supplier_id = mgq.supplier_id
      and msr.supplier_site_id = mgq.supplier_site_id
      and trunc(msr.consumption_date) between to_date(p_context_value,FORMAT_MASK)
        and to_date(p_context_value2,FORMAT_MASK);

  end if; -- }

  for i in 1..v_inst_id.count
  loop -- {
    if ( checkRow ) then
      open check_job_row_cur (g_order_query_id, g_plan_id, v_inst_id(i), v_trx_id(i));
      fetch check_job_row_cur into l_row_found;
      close check_job_row_cur;
    end if;

    if ( l_row_found = 0) then
    msc_gantt_utils.populateRowKeysIntoGantt(
      p_query_id => g_order_query_id,
      p_index => l_row_index,
      p_node_path => l_row_index,
      p_node_type => JOB_NODE,
      p_inst_id => v_inst_id(i),
      p_org_id => v_org_id(i),
      p_transaction_id => v_trx_id(i),
      p_critical_flag => 0,
      p_node_level => 1
    );

    l_row_index := l_row_index + 1;
    end if;
  end loop; -- }

  l_temp_query_id := msc_gantt_pkg.orderview(g_order_query_id, g_plan_id,
    null, null, ORDER_VIEW,
    PEG_ORDERS, l_node_count);

  return l_row_index - 1;
end AddToOrdersView;

--
--
function getGanttRowCount(p_query_id number) return number is
  cursor c_row is
  select count(*)
  from msc_gantt_query
  where query_id = p_query_id;
  l_count number;
begin
  open c_row;
  fetch c_row into l_count;
  close c_row;
  return l_count;
end getGanttRowCount;

function resourceView (p_query_id in out nocopy number,
  p_plan_id number, p_list varchar2,
  p_filter_type number, p_view_type number,
  p_from_index number, p_to_index number,
  p_name_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_require_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_avail_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_batched_res_act number default null,
  p_display_type number default null,
  p_refresh boolean default false,
  p_sort_column varchar2 default null,
  p_sort_order varchar2 default null,
  p_change_view boolean default false,
  p_folder_id number default null) return number is
begin
  put_line('resourceView in');

  if ( p_query_id is null ) then -- {
    g_plan_info := getPlanInfo(p_plan_id);
    p_query_id := msc_gantt_utils.getGanttSequence();

    msc_gantt_utils.populateListIntoGantt(p_query_id, p_plan_id, p_list,
      p_filter_type, p_view_type, p_folder_id);

  elsif ( p_refresh ) then

    update msc_gantt_query
      set is_fetched = SYS_NO,
        row_flag = SYS_NO
    where query_id = p_query_id;

    delete from msc_gantt_dtl_query
    where query_id = p_query_id;

  else
    update msc_gantt_query
      set is_fetched = SYS_NO,
        row_flag = SYS_NO
    where query_id = p_query_id;

    delete from msc_gantt_dtl_query
    where query_id = p_query_id;

  end if; -- }

  msc_gantt_utils.sendResourceNames(p_query_id, p_from_index, p_to_index,
    p_name_data, p_sort_column, p_sort_order);

  if ( p_view_type = RES_HOURS_VIEW ) then -- {

    msc_gantt_utils.populateResReqGanttNew(p_query_id,
      g_plan_start_date, g_cutoff_date, nvl(p_display_type, display_none));

    msc_gantt_utils.populateResAvailGantt(p_query_id, g_plan_start_date, g_cutoff_date);
    msc_gantt_utils.prepareResHoursGantt(p_query_id, p_plan_id, g_plan_start_date,
      g_cutoff_date, nvl(p_display_type, display_none));

    msc_gantt_utils.sendResourceGantt(p_query_id, p_view_type, SYS_YES,
      p_require_data, p_avail_data, false, nvl(p_display_type, display_none));

  elsif ( p_view_type = RES_UNITS_VIEW ) then

    msc_gantt_utils.populateResReqGanttNew(p_query_id, g_plan_start_date, g_day_bkt_start_date);
    msc_gantt_utils.populateResAvailGantt(p_query_id, g_plan_start_date, g_day_bkt_start_date);

    msc_gantt_utils.sendResourceGantt(p_query_id, p_view_type, SYS_NO, p_require_data,
      p_avail_data, false, DISPLAY_NONE);

  elsif (p_view_type = RES_ACTIVITIES_VIEW ) then

    msc_gantt_utils.populateResActGantt(p_query_id, g_plan_start_date, g_day_bkt_start_date,
      nvl(p_batched_res_act, RES_REQ_ROW_TYPE), p_require_data, nvl(p_display_type, display_none));

    msc_gantt_utils.populateResAvailGantt(p_query_id, g_plan_start_date, g_day_bkt_start_date);
    msc_gantt_utils.sendResourceGantt(p_query_id, p_view_type, SYS_NO, p_require_data,
      p_avail_data, true, nvl(p_display_type, display_none));

  end if; -- }

  -- set the is_fetched to SYS_YES
  update msc_gantt_query
    set is_fetched = SYS_YES
  where query_id = p_query_id
    and row_flag = SYS_YES ;

  put_line('resourceView out');

  return getGanttRowCount(p_query_id);
end resourceView ;

function supplierView(p_query_id in out nocopy number,
  p_plan_id number, p_list varchar2,
  p_filter_type number, p_view_type number,
  p_from_index number, p_to_index number,
  p_name_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_supp_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_refresh boolean default false,
  p_sort_column varchar2 default null,
  p_sort_order varchar2 default null) return number is
begin
  put_line('supplierView in');

  if ( p_query_id is null ) then  -- {
    g_plan_info := getPlanInfo(p_plan_id);
    p_query_id := msc_gantt_utils.getGanttSequence();

    msc_gantt_utils.populateListIntoGantt(p_query_id,
      p_plan_id, p_list, p_filter_type, p_view_type);

  elsif ( p_refresh ) then
    update msc_gantt_query
      set is_fetched = SYS_NO,
        row_flag = SYS_NO
    where query_id = p_query_id;

    delete from msc_gantt_dtl_query
    where query_id = p_query_id;
  else
    update msc_gantt_query
      set is_fetched = SYS_NO,
        row_flag = SYS_NO
    where query_id = p_query_id;

    delete from msc_gantt_dtl_query
    where query_id = p_query_id;
  end if; -- }

  msc_gantt_utils.sendSupplierNames(p_query_id, p_from_index, p_to_index, p_name_data,
    p_sort_column, p_sort_order);

  msc_gantt_utils.populateSupplierGantt(p_query_id, g_plan_id, g_plan_start_date, g_cutoff_date);
  msc_gantt_utils.prepareSupplierGantt(p_query_id, p_plan_id, g_plan_start_date, g_cutoff_date);
  msc_gantt_utils.sendSupplierGantt(p_query_id, p_supp_data);

  -- set the is_fetched to SYS_YES
  update msc_gantt_query
    set is_fetched = SYS_YES
  where query_id = p_query_id
    and row_flag = SYS_YES ;

  return getGanttRowCount(p_query_id);
  put_line('supplierView out');
end supplierView;

procedure sortResSuppView(p_query_id number,
  p_view_type number, p_from_index number, p_to_index number,
  p_name_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_sort_column varchar2 default null,
  p_sort_order varchar2 default null) is
begin
  if ( p_view_type = SUPPLIER_VIEW ) then
    msc_gantt_utils.sendSupplierNames(p_query_id, p_from_index, p_to_index,
      p_name_data, p_sort_column, p_sort_order);
  elsif (p_view_type in (RES_ACTIVITIES_VIEW, RES_UNITS_VIEW, RES_HOURS_VIEW) ) then
    msc_gantt_utils.sendResourceNames(p_query_id, p_from_index, p_to_index,
      p_name_data, p_sort_column, p_sort_order);
  end if;
end sortResSuppView;

procedure firmUnfirm(p_query_id number,
  p_view_type number, p_node_type number,
  p_firm_type number,
  p_start_date date, p_end_date date,
  p_trx_list varchar2,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2,
  p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_validate_flag boolean default true,
  p_res_firm_seq boolean default false,
  p_batched_res_act boolean default false) is

  l_inst_id number;
  l_trx_id number;
  l_one_record varchar2(100);

  i number;
  v_len number;
begin
  if ( p_view_type not in (RES_ACTIVITIES_VIEW, DEMAND_VIEW, ORDER_VIEW)
       or p_node_type not in (RES_NODE, RES_INST_NODE, JOB_NODE, COPROD_NODE) ) then
    p_return_status := 'ERROR';
    p_out := 'INVALID_VIEW_OR_NODE';
    return;
  end if;

  i :=1;

    if ( p_node_type in (RES_NODE, RES_INST_NODE) ) then -- {
      if (p_res_firm_seq) then -- {
	msc_gantt_utils.firmResourceSeqPub(g_plan_id, p_trx_list, p_firm_type,
	  p_return_status, p_out, p_node_type);
      elsif (p_batched_res_act) then
        l_one_record := substr(p_trx_list,
          instr(p_trx_list,'(',1,i)+1,instr(p_trx_list,')',1,i) - instr(p_trx_list,'(',1,i)-1);
        l_inst_id := to_number(substr(l_one_record,1,instr(l_one_record,',')-1));
        l_trx_id := to_number(substr(l_one_record,instr(l_one_record,',')+1));
        -- no firming of a batch...client should not call this..
	-- msc_gantt_utils.firmResourceBatchPub(g_plan_id,  l_trx_id, l_inst_id, p_firm_type,
	--  p_return_status, p_out, p_node_type);
      else
        v_len := length(p_trx_list);
	i :=1;
        while v_len > 1 loop
          l_one_record := substr(p_trx_list,
            instr(p_trx_list,'(',1,i)+1,instr(p_trx_list,')',1,i) - instr(p_trx_list,'(',1,i)-1);
          l_inst_id := to_number(substr(l_one_record,1,instr(l_one_record,',')-1));
          l_trx_id := to_number(substr(l_one_record,instr(l_one_record,',')+1));

	  msc_gantt_utils.firmResourcePub(g_plan_id, l_trx_id, l_inst_id, p_firm_type,
	    p_return_status, p_out, p_node_type);
          i := i+1;
          v_len := v_len - length(l_one_record)-3;
        end loop;
      end if; -- }
    elsif (p_node_type in (JOB_NODE, COPROD_NODE) ) then
        v_len := length(p_trx_list);
	i :=1;
        while v_len > 1 loop
          l_one_record := substr(p_trx_list,
            instr(p_trx_list,'(',1,i)+1,instr(p_trx_list,')',1,i) - instr(p_trx_list,'(',1,i)-1);
          l_inst_id := to_number(substr(l_one_record,1,instr(l_one_record,',')-1));
          l_trx_id := to_number(substr(l_one_record,instr(l_one_record,',')+1));

          msc_gantt_utils.firmSupplyPub(g_plan_id, l_trx_id, l_inst_id,
            p_firm_type, p_start_date, p_end_date, g_plan_start_date, g_cutoff_date,
 	    p_return_status, p_out, p_validate_flag, p_node_type);

	  i := i+1;
          v_len := v_len - length(l_one_record)-3;
        end loop;
    end if; -- }
end firmUnfirm;

procedure moveNode(p_query_id number, p_view_type number,
  p_node_type number, p_to_node_type number,
  p_trx_list varchar2, p_to_trx_list varchar2,
  p_start_date date, p_end_date date, p_duration varchar2,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2,
  p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_validate_flag boolean default true,
  p_res_firm_seq boolean default false,
  p_batched_res_act boolean default false) is

  l_inst_id number;
  l_trx_id number;

  l_to_res_id number;
  l_to_res_instance_id number;
  l_to_serial_number varchar2(30);
  l_to_alt_num number;

  l_one_record varchar2(100);

  i number;
  v_len number;

  p_return_trx_id number;
begin
  put_line('moveNode in');

  savepoint start_of_submission; --save point

  if ( p_view_type not in (RES_ACTIVITIES_VIEW, DEMAND_VIEW, ORDER_VIEW)
       or p_node_type not in (RES_NODE, RES_INST_NODE, JOB_NODE, COPROD_NODE) ) then
    p_return_status := 'ERROR';
    p_out := 'INVALID_VIEW_OR_NODE';
    return;
  end if;

    if ( p_node_type in (RES_NODE, RES_INST_NODE) ) then -- {
      if ( p_to_node_type is not null ) then -- {
        i:= 1;
        l_one_record := substr(p_to_trx_list,
          instr(p_to_trx_list,'(',1,i)+1,instr(p_to_trx_list,')',1,i)
	  - instr(p_to_trx_list,'(',1,i)-1);
        l_to_res_id := to_number(substr(l_one_record,1,instr(l_one_record,',')-1));
        l_to_res_instance_id := to_number(substr(l_one_record,instr(l_one_record,',',1,1)+1,
                       instr(l_one_record,',',1,2)-instr(l_one_record,',',1,1)-1));
        l_to_serial_number := substr(l_one_record,instr(l_one_record,',',1,2)+1,
                       instr(l_one_record,',',1,3)-instr(l_one_record,',',1,2)-1);
        l_to_alt_num := to_number(substr(l_one_record,instr(l_one_record,',',1,3)+1));

	put_line(' to_node '||l_to_res_id||' '||l_to_res_instance_id||' '||l_to_serial_number||' '||l_to_alt_num);

        l_one_record := substr(p_trx_list,
          instr(p_trx_list,'(',1,i)+1,instr(p_trx_list,')',1,i) - instr(p_trx_list,'(',1,i)-1);
        l_inst_id := to_number(substr(l_one_record,1,instr(l_one_record,',')-1));
        l_trx_id := to_number(substr(l_one_record,instr(l_one_record,',')+1));

	put_line(' from_node '|| l_inst_id ||' '||l_trx_id);

        if ( p_batched_res_act ) then  -- {
          msc_gantt_utils.loadAltResourceBatch(g_plan_id,
            l_trx_id, l_inst_id, l_to_res_id, l_to_res_instance_id, l_to_serial_number,
	    l_to_alt_num, p_node_type, p_to_node_type, p_return_trx_id,
            p_return_status, p_out);
	else
          msc_gantt_utils.loadAltResource(g_plan_id,
            l_trx_id, l_inst_id, l_to_res_id, l_to_res_instance_id, l_to_serial_number,
	    l_to_alt_num, p_node_type, p_to_node_type, p_return_trx_id,
            p_return_status, p_out);
	end if;  -- }

	if ( nvl(p_return_status, 'ERROR') <> 'OK' ) then -- {
         put_line('error while offloading - rolling back ');
         ROLLBACK TO start_of_submission;
	 return;
	end if; -- }

	put_line(' offloading done .now move the trx '||p_return_trx_id);

	msc_gantt_utils.moveResourcePub(g_plan_id, p_return_trx_id, l_inst_id,
	  p_start_date, p_end_date, p_duration, g_plan_start_date, g_cutoff_date,
	  p_return_status, p_out, p_validate_flag, p_res_firm_seq,  p_batched_res_act, p_node_type);

      else

        v_len := length(p_trx_list);
	i :=1;
        while v_len > 1 loop
          -- from node
          l_one_record := substr(p_trx_list,
          instr(p_trx_list,'(',1,i)+1,instr(p_trx_list,')',1,i) - instr(p_trx_list,'(',1,i)-1);
          l_inst_id := to_number(substr(l_one_record,1,instr(l_one_record,',')-1));
          l_trx_id := to_number(substr(l_one_record,instr(l_one_record,',')+1));

	  put_line(' move inst trx '||l_inst_id||' - '||l_trx_id);

          msc_gantt_utils.moveResourcePub(g_plan_id, l_trx_id, l_inst_id, p_start_date, p_end_date,
            p_duration, g_plan_start_date, g_cutoff_date, p_return_status, p_out,
    	    p_validate_flag, p_res_firm_seq,  p_batched_res_act, p_node_type);
          i := i+1;
          v_len := v_len - length(l_one_record)-3;
        end loop;

      end if; -- }
    elsif (p_node_type in (JOB_NODE, COPROD_NODE) ) then

        v_len := length(p_trx_list);
	i :=1;
        while v_len > 1 loop
          -- from node
          l_one_record := substr(p_trx_list,
          instr(p_trx_list,'(',1,i)+1,instr(p_trx_list,')',1,i) - instr(p_trx_list,'(',1,i)-1);
          l_inst_id := to_number(substr(l_one_record,1,instr(l_one_record,',')-1));
          l_trx_id := to_number(substr(l_one_record,instr(l_one_record,',')+1));

	  put_line(' move inst trx '||l_inst_id||' - '||l_trx_id);

	  msc_gantt_utils.moveSupplyPub (g_plan_id, l_trx_id, p_start_date, p_end_date,
            g_plan_start_date, g_cutoff_date, p_return_status, p_out);

	  i := i+1;
          v_len := v_len - length(l_one_record)-3;
        end loop;

    end if; -- }
  put_line('moveNode out');
end moveNode;

procedure moveAndFirm(p_node_type number, p_to_node_type number,
  p_firm_type number, p_trx_list varchar2, p_to_trx_list varchar2,
  p_start_date date, p_end_date date, p_duration varchar2,
  p_return_status OUT NOCOPY varchar2, p_out OUT NOCOPY varchar2,
  p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_validate_flag boolean default true,
  p_res_firm_seq boolean default false) is
begin

  if p_firm_type=0 then -- If user wants to unfirm, then do it first
	  msc_gantt_pkg.firmUnfirm(null, RES_ACTIVITIES_VIEW, p_node_type,
	    p_firm_type, p_start_date, p_end_date, p_trx_list,
	    p_return_status, p_out, p_out_data,
	    p_validate_flag, p_res_firm_seq, false);
       return;
   end if;

  msc_gantt_pkg.moveNode(null, RES_ACTIVITIES_VIEW, p_node_type, p_to_node_type,
    p_trx_list, p_to_trx_list, p_start_date, p_end_date, p_duration,
    p_return_status, p_out, p_out_data,
    p_validate_flag, p_res_firm_seq, false);

    if ( nvl(p_return_status, 'ERROR') <> 'OK' ) then -- {
--      p_out := p_return_status; -- Bug4552734
      return;
    end if; -- }
  if p_firm_type <> 0 then
	  msc_gantt_pkg.firmUnfirm(null, RES_ACTIVITIES_VIEW, p_node_type,
	    p_firm_type, p_start_date, p_end_date, p_trx_list,
	    p_return_status, p_out, p_out_data,
	    p_validate_flag, p_res_firm_seq, false);
  end if;
end moveAndFirm;

procedure updateResUnitsDirectly(p_query_id number,
  p_node_type number, p_inst_id number, p_trx_id number,
  p_assigned_units_hours number,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2) is

  l_res_hours number;
  l_child_count number;
begin
  if ( p_node_type = RES_NODE ) then
    select count(*)
      into l_child_count
    from msc_resource_requirements mrr,
      msc_resource_instance_reqs mrir
    where mrr.plan_id = g_plan_id
      and mrr.sr_instance_id = p_inst_id
      and mrr.transaction_id = p_trx_id
      and mrr.plan_id = mrir.plan_id
      and mrr.sr_instance_id = mrir.sr_instance_id
      and mrr.organization_id = mrir.organization_id
      and mrr.department_id = mrir.department_id
      and mrr.resource_id = mrir.resource_id
      and nvl(mrr.parent_id,2) = 2;

    if (l_child_count > 0) then
      p_return_status := 'ERROR';
      p_out := 'RES_SCHEDULED_TO_INSTANCE';
      return;
    end if;

    select mrr.resource_hours
    into l_res_hours
    from msc_resource_requirements mrr
    where mrr.plan_id = g_plan_id
      and mrr.sr_instance_id = p_inst_id
      and mrr.transaction_id = p_trx_id
    for update of mrr.resource_hours nowait;

    update msc_resource_requirements
    set status =0,
      applied=2,
      assigned_units = p_assigned_units_hours
    where plan_id = g_plan_id
      and transaction_id = p_trx_id
      and sr_instance_id = p_inst_id;

   end if;

  p_return_status := 'OK';
end updateResUnitsDirectly;

procedure updateResHoursDirectly(p_query_id number,
  p_node_type number, p_inst_id number, p_trx_id number,
  p_resource_hours number, p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2) is

  l_res_hours number;

begin

  if ( p_node_type = RES_NODE ) then
    select mrr.resource_hours
    into l_res_hours
    from msc_resource_requirements mrr
    where mrr.plan_id = g_plan_id
      and mrr.sr_instance_id = p_inst_id
      and mrr.transaction_id = p_trx_id
    for update of mrr.resource_hours nowait;

    update msc_resource_requirements
    set status =0,
      applied=2,
      resource_hours = p_resource_hours
    where plan_id = g_plan_id
      and transaction_id = p_trx_id
      and sr_instance_id = p_inst_id;

   elsif ( p_node_type = RES_INST_NODE ) then

    select mrir.resource_instance_hours
    into l_res_hours
    from msc_resource_instance_reqs mrir
    where mrir.plan_id = g_plan_id
      and mrir.sr_instance_id = p_inst_id
      and mrir.res_inst_transaction_id = p_trx_id
    for update of mrir.resource_instance_hours nowait;

    update msc_resource_instance_reqs
    set status =0,
      applied=2,
      resource_instance_hours = p_resource_hours
    where plan_id = g_plan_id
      and res_inst_transaction_id = p_trx_id
      and sr_instance_id = p_inst_id;
   end if;

  p_return_status := 'OK';
end updateResHoursDirectly;

--
--
function getPlanInfo(p_plan_id number) return varchar2 is
begin
  if (g_plan_id = p_plan_id) then
    return g_plan_info ;
  end if ;

  g_plan_info := msc_gantt_utils.getPlanInfo(p_plan_id,
    g_first_date, g_last_date,
    g_hour_bkt_start_date, g_day_bkt_start_date,
    g_plan_start_date, g_cutoff_date, g_plan_type);

  g_plan_id := p_plan_id;
  return g_plan_info ;
end getPlanInfo;

procedure getUserPref(p_pref_id number) is
begin
  msc_gantt_utils.getUserPref(p_pref_id);
end getUserPref;

procedure getSimuResource(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_name OUT NOCOPY varchar2, p_id OUT NOCOPY varchar2,
  p_node_type number default null) is
begin
  msc_gantt_utils.getSimuResource(p_plan_id,
    p_transaction_id, p_instance_id, p_name, p_id, p_node_type);
end getSimuResource;

procedure getAltResource(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_name OUT NOCOPY varchar2, p_id OUT NOCOPY varchar2,
  p_node_type number default null,
  p_from_form number default null) is
begin
  msc_gantt_utils.getAltResource(p_plan_id,
    p_transaction_id, p_instance_id, p_name, p_id, p_node_type, p_from_form);
end getAltResource;

function isPlanGanttEnabled(p_plan_id number) return boolean is
  cursor isconstrained is
  select daily_resource_constraints,
    weekly_resource_constraints,
    period_resource_constraints, plan_type
  from msc_plans
  where plan_id = p_plan_id;

  l_daily number;
  l_weekly number;
  l_monthly number;
  l_plantype number;
begin
   open isconstrained;
   fetch isconstrained into l_daily, l_weekly, l_monthly, l_plantype;
   close isconstrained;
   if  ( l_plantype in (4,5) or p_plan_id = -1 ) then
     return false;
   elsif ( l_daily = 1 or l_weekly = 1 or l_monthly = 1 ) then
     return true;
   end if;
   return false;
end isPlanGanttEnabled;

function isPlanDSEnabled(p_plan_id number) return boolean is
  cursor c_dsplan is
  select nvl(nvl(curr_ds_enabled_flag,ds_enabled_flag), sys_no) ds_enabled_flag
  from msc_plan_organizations
  where plan_id = p_plan_id;
  l_ds_enabled number;
begin
  open c_dsplan;
  loop
    fetch c_dsplan into l_ds_enabled;
    exit when c_dsplan%notfound;
    if ( l_ds_enabled = 1 ) then
      close c_dsplan;
      return true;
    end if;
  end loop;
  close c_dsplan;
  return false;
end isPlanDSEnabled;

function getEndDemandIds(p_plan_id number, p_view_type number, p_node_type number,
  p_trx_list varchar2, p_date1 date default null, p_date2 date default null) return number is
  v_mfq_to_query_id number;
  v_mfq_from_query_id number;
  v_query_id number;
  v_node_count varchar2(100);
  v_len number;
  v_one_record varchar2(50);
  i number := 1;

  l_inst_id number;
  l_org_id number;
  l_dept_id number;
  l_res_id number;
  l_res_instance_id number;
  l_serial_number varchar2(30);

begin
  v_mfq_from_query_id := msc_gantt_utils.getMFQSequence();
  v_mfq_to_query_id := msc_gantt_utils.getMFQSequence();

  if ( p_view_type in (RES_ACTIVITIES_VIEW, DEMAND_VIEW, ORDER_VIEW) ) then -- {
    v_len := length(p_trx_list);
    while v_len > 1 loop
      v_one_record := substr(p_trx_list,instr(p_trx_list,
        '(',1,i)+1, instr(p_trx_list,')',1,i)-instr(p_trx_list,'(',1,i)-1);

      msc_gantt_utils.populateOrdersIntoMFQ(null, null, v_mfq_from_query_id, v_one_record);

      i := i+1;
      v_len := v_len - length(v_one_record)-3;
    end loop;
  end if; -- }

  if ( p_view_type in (RES_ACTIVITIES_VIEW) ) then -- {

    if ( p_node_type = RES_NODE ) then -- {

      insert into msc_form_query
        (query_id, last_update_date, last_updated_by, creation_date, created_by,
        last_update_login, number1, number2)
      select distinct v_mfq_to_query_id, sysdate, -1, sysdate, -1, -1,
        mfp2.demand_id, mfp2.sr_instance_id
      from msc_full_pegging mfp2,
        msc_full_pegging mfp,
        msc_resource_requirements mrr,
        msc_form_query mfq
      where mfq.query_id = v_mfq_from_query_id
        and mrr.plan_id = p_plan_id
        and mrr.sr_instance_id =  mfq.number2
        and mrr.transaction_id = mfq.number1
        and mfp.plan_id = mrr.plan_id
        and mfp.transaction_id = mrr.supply_id
        and mfp2.plan_id = mfp.plan_id
        and mfp2.pegging_id = mfp.end_pegging_id;

     else

      insert into msc_form_query
        (query_id, last_update_date, last_updated_by, creation_date, created_by,
        last_update_login, number1, number2)
      select distinct v_mfq_to_query_id, sysdate, -1, sysdate, -1, -1,
        mfp2.demand_id, mfp2.sr_instance_id
      from msc_full_pegging mfp2,
        msc_full_pegging mfp,
        msc_resource_instance_reqs mrir,
        msc_form_query mfq
      where mfq.query_id = v_mfq_from_query_id
        and mrir.plan_id = p_plan_id
        and mrir.sr_instance_id =  mfq.number2
        and mrir.res_inst_transaction_id = mfq.number1
        and mfp.plan_id = mrir.plan_id
        and mfp.transaction_id = mrir.supply_id
        and mfp2.plan_id = mfp.plan_id
        and mfp2.pegging_id = mfp.end_pegging_id;

     end if; -- }

  elsif ( p_view_type in (RES_HOURS_VIEW) ) then

      v_one_record := substr(p_trx_list,instr(p_trx_list,
        '(',1,i)+1, instr(p_trx_list,')',1,i)-instr(p_trx_list,'(',1,i)-1);

    msc_gantt_utils.parseResString(v_one_record, l_inst_id, l_org_id,
     l_dept_id, l_res_id, l_res_instance_id, l_serial_number);

    if ( p_node_type = RES_NODE ) then -- {

      insert into msc_form_query
        (query_id, last_update_date, last_updated_by, creation_date, created_by,
        last_update_login, number1, number2)
      select distinct v_mfq_to_query_id, sysdate, -1, sysdate, -1, -1,
        mfp2.demand_id, mfp2.sr_instance_id
      from msc_full_pegging mfp2,
        msc_full_pegging mfp,
        msc_resource_requirements mrr
      where mrr.plan_id = p_plan_id
        and mrr.sr_instance_id =  l_inst_id
        and mrr.organization_id = l_org_id
        and mrr.department_id = l_dept_id
        and mrr.resource_id = l_res_id
	and ( nvl(mrr.firm_start_date, mrr.start_date) between p_date1 and p_date2
	      or nvl(mrr.firm_end_date, mrr.end_date) between p_date1 and p_date2
              or ( nvl(mrr.firm_start_date, mrr.start_date) <= p_date1
                    and nvl(mrr.firm_end_date, mrr.end_date) >= p_date2) ) --5456033 bugfix
        and mfp.plan_id = mrr.plan_id
        and mfp.transaction_id = mrr.supply_id
        and mfp2.plan_id = mfp.plan_id
        and mfp2.pegging_id = mfp.end_pegging_id;
    else

      insert into msc_form_query
        (query_id, last_update_date, last_updated_by, creation_date, created_by,
        last_update_login, number1, number2)
      select distinct v_mfq_to_query_id, sysdate, -1, sysdate, -1, -1,
        mfp2.demand_id, mfp2.sr_instance_id
      from msc_full_pegging mfp2,
        msc_full_pegging mfp,
        msc_resource_instance_reqs mrir
      where mrir.plan_id = p_plan_id
        and mrir.sr_instance_id =  l_inst_id
        and mrir.organization_id = l_org_id
        and mrir.department_id = l_dept_id
        and mrir.resource_id = l_res_id
        and mrir.res_instance_id = l_res_instance_id
        and mrir.serial_number = l_serial_number
	and ( nvl(mrir.start_date, mrir.start_date) between p_date1 and p_date2
	      or nvl(mrir.end_date, mrir.end_date) between p_date1 and p_date2
              or ( nvl(mrir.start_date, mrir.start_date) <= p_date1
                   and nvl(mrir.end_date, mrir.end_date) >= p_date2) )
        and mfp.plan_id = mrir.plan_id
        and mfp.transaction_id = mrir.supply_id
        and mfp2.plan_id = mfp.plan_id
        and mfp2.pegging_id = mfp.end_pegging_id;

    end if; -- }

  elsif ( p_view_type in (DEMAND_VIEW, ORDER_VIEW) ) then

    if ( p_node_type = RES_NODE ) then -- {

      insert into msc_form_query
        (query_id, last_update_date, last_updated_by, creation_date, created_by,
        last_update_login, number1, number2)
      select distinct v_mfq_to_query_id, sysdate, -1, sysdate, -1, -1,
        mfp2.demand_id, mfp2.sr_instance_id
      from msc_full_pegging mfp2,
        msc_full_pegging mfp,
        msc_resource_requirements mrr,
        msc_form_query mfq
      where mfq.query_id = v_mfq_from_query_id
        and mrr.plan_id = p_plan_id
        and mrr.sr_instance_id =  mfq.number2
        and mrr.transaction_id = mfq.number1
        and mfp.plan_id = mrr.plan_id
        and mfp.transaction_id = mrr.supply_id
        and mfp2.plan_id = mfp.plan_id
        and mfp2.pegging_id = mfp.end_pegging_id;

    else

      insert into msc_form_query
        (query_id, last_update_date, last_updated_by, creation_date, created_by,
        last_update_login, number1, number2)
      select distinct v_mfq_to_query_id, sysdate, -1, sysdate, -1, -1,
        mfp2.demand_id, mfp2.sr_instance_id
      from msc_full_pegging mfp2,
        msc_full_pegging mfp,
        msc_form_query mfq
      where mfq.query_id = v_mfq_from_query_id
        and mfp.plan_id = p_plan_id
        and mfp.sr_instance_id =  mfq.number2
        and mfp.transaction_id = mfq.number1
        and mfp2.plan_id = mfp.plan_id
        and mfp2.pegging_id = mfp.end_pegging_id;
    end if; --}
  else
    return -1;
  end if; -- }

  return v_mfq_to_query_id;
end getEndDemandIds;

--5516790 bugfix
function getNewViewStartDate(p_node_type number, p_trx_id number, p_to_view_type number) return date is
  cursor c_supp_view_date1 is
  select min(msr.consumption_date) start_date
  from msc_supplier_requirements msr
  where msr.plan_id = g_plan_id
    and msr.supply_id = p_trx_id;

  cursor c_supp_view_date2 is
  select min(msr.consumption_date) start_date
  from msc_supplier_requirements msr,
    msc_resource_requirements mrr
  where mrr.plan_id = g_plan_id
    and mrr.transaction_id = p_trx_id
    and msr.plan_id = mrr.plan_id
    and msr.sr_instance_id = mrr.sr_instance_id
    and msr.supply_id = mrr.supply_id;

  cursor c_res_view_date1 is
  select min(nvl(mrr.firm_start_date,mrr.start_date)) start_date
  from msc_resource_requirements mrr
  where mrr.plan_id = g_plan_id
    and mrr.supply_id = p_trx_id;

  cursor c_res_view_date2 is
  select min(nvl(mrr.firm_start_date,mrr.start_date)) start_date
  from msc_resource_requirements mrr
  where mrr.plan_id = g_plan_id
    and mrr.transaction_id = p_trx_id;

  l_date date;
begin
  if (p_to_view_type in (RES_HOURS_VIEW,RES_UNITS_VIEW) ) then
    if (p_node_type = RES_NODE) then
      open c_res_view_date2;
      fetch c_res_view_date2 into l_date;
      close c_res_view_date2;
      return l_date;
    elsif (p_node_type in (JOB_NODE,COPROD_NODE) ) then
      open c_res_view_date1;
      fetch c_res_view_date1 into l_date;
      close c_res_view_date1;
      return l_date;
    end if;
  elsif (p_to_view_type = SUPPLIER_VIEW) then
    if (p_node_type = RES_NODE ) then
      open c_supp_view_date2;
      fetch c_supp_view_date2 into l_date;
      close c_supp_view_date2;
      return l_date;
    elsif (p_node_type in (JOB_NODE,COPROD_NODE) ) then
      open c_supp_view_date1;
      fetch c_supp_view_date1 into l_date;
      close c_supp_view_date1;
      return l_date;
    end if;
  end if;
  return l_date;
end getNewViewStartDate;

procedure getProperty(p_plan_id number, p_instance_id number,
  p_transaction_id number, p_type number, p_view_type number,
  v_pro out NOCOPY varchar2, v_demand out NOCOPY varchar2) is
  l_end_demand_id number;
begin
  msc_gantt_utils.getProperty(p_plan_id, p_instance_id, p_transaction_id,
    p_type, p_view_type, l_end_demand_id, v_pro, v_demand);
end getProperty;

function getDebugProfile return varchar2 is
begin
 return fnd_profile.value('MSC_JAVA_DEBUG');
end;

End MSC_GANTT_PKG;

/
