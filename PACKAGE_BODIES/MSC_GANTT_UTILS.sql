--------------------------------------------------------
--  DDL for Package Body MSC_GANTT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_GANTT_UTILS" AS
/* $Header: MSCGNTUB.pls 120.61.12010000.5 2010/03/15 18:06:16 pabram ship $  */

  g_plan_cal varchar2(50);
  g_plan_cal_inst_id number;
  g_plan_cal_excp_id number;
  g_plan_cal_from_profile varchar2(50);
  g_plan_inst_id number;
  g_plan_org_id number;

  g_plan_id number;
  g_plan_type number;

  g_category_set_id number;
  g_pref_id number;

  --res act view - activity labels
  g_gantt_act_label_1 number;
  g_gantt_act_label_2 number;
  g_gantt_act_label_3 number;

  --res act view - batch activity labels
  g_gantt_batches_label_1 number;
  g_gantt_batches_label_2 number;
  g_gantt_batches_label_3 number;

  --order view - order labels
  g_gantt_supply_orders_label_1 number;
  g_gantt_supply_orders_label_2 number;
  g_gantt_supply_orders_label_3 number;

  --order view - operation labels
  g_gantt_oper_label_1 number;
  g_gantt_oper_label_2 number;
  g_gantt_oper_label_3 number;

  --order view - activity labels
  g_gantt_res_act_label_1 number;
  g_gantt_res_act_label_2 number;
  g_gantt_res_act_label_3 number;

  g_gantt_ra_toler_days_early number;
  g_gantt_ra_toler_days_late number;

  g_gantt_rh_toler_days_early number;
  g_gantt_rh_toler_days_late number;

  --job node labels
  g_job_none_lbl constant number := 0;
  g_job_item_lbl constant number := 1;
  g_job_org_lbl constant number := 2;
  g_job_order_number_lbl constant number := 3;
  g_job_order_type_lbl constant number := 4;
  g_job_qty_lbl constant number := 5;

  -- op node lables
  g_op_none_lbl constant number := 0;
  g_op_seq_lbl constant number := 1;
  g_op_dept_lbl constant number := 2;
  g_op_desc_lbl constant number := 3;

  -- res node labels - orders view
  g_res_none_lbl constant number := 0;
  g_res_seq_lbl constant number := 1;
  g_res_dept_lbl constant number := 2;
  g_res_lbl constant number := 3;
  g_res_setup_lbl constant number := 4;
  g_res_batch_lbl constant number := 5;
  g_res_alt_flag_lbl constant number := 6;
  g_res_units_lbl constant number := 7;

  -- res node labels - res act view
  g_res_act_none_lbl constant number := 0;
  g_res_act_item_lbl constant number := 1;
  g_res_act_setup_lbl constant number := 2;
  g_res_act_org_lbl constant number := 3;
  g_res_act_qty_lbl constant number := 4;
  g_res_act_batch_lbl constant number := 5;
  g_res_act_alt_flag_lbl constant number := 6;
  g_res_act_units_lbl constant number := 7;
  g_res_act_order_type_lbl constant number := 8;
  g_res_act_op_sdesc_lbl constant number := 9;
  g_res_act_op_seq_lbl constant number := 10;
  g_res_act_req_comp_date_lbl constant number := 11;
  g_res_act_order_number_lbl constant number := 12;

  -- batched res node labels
  g_batch_none_lbl constant number := 0;
  g_batch_setup_lbl constant number := 1;
  g_batch_org_lbl constant number := 2;
  g_batch_qty_lbl constant number := 3;
  g_batch_num_lbl constant number := 4;
  g_batch_util_pct_lbl constant number := 5;

  g_folder_res_field_name constant varchar2(50) := 'RESOURCE_ID';

-- cursors  +
  cursor active_res_rows_cur(p_query_id number) is
  select mgq.row_index
  from msc_gantt_query mgq
  where query_id = p_query_id
    and row_flag = sys_yes
  order by 1;

  cursor res_req_info (p_plan number, p_inst number, p_trx number) is
  select mrr.firm_flag, mrr.firm_Start_date, mrr.firm_end_date, mrr.batch_number,
    mrr.group_sequence_id, mrr.group_sequence_number
  from msc_resource_requirements mrr
  where mrr.plan_id = p_plan
    and mrr.sr_instancE_id = p_inst
    and mrr.transaction_id = p_trx
    and nvl(mrr.parent_id, 2) = 2;

  cursor res_inst_req_info (p_plan number, p_inst number, p_trx number) is
  select mrir.batch_number
  from msc_resource_instance_reqs mrir
  where mrir.plan_id = p_plan
    and mrir.sr_instancE_id = p_inst
    and mrir.res_inst_transaction_id = p_trx
    and nvl(mrir.parent_id, 2) = 2;

 cursor simu_res_cur (p_plan number, p_inst number, p_trx number) is
 select mrr2.transaction_id, mrr2.sr_instance_id
   from msc_resource_requirements mrr1,
   msc_resource_requirements mrr2
 where mrr1.plan_id = p_plan
   and mrr1.transaction_id = p_trx
   and mrr1.sr_instance_id = p_inst
   and mrr2.plan_id = mrr1.plan_id
   and mrr2.sr_instance_id = mrr1.sr_instance_id
   and mrr2.supply_id = mrr1.supply_id
   and mrr2.operation_seq_num = mrr1.operation_seq_num
   and mrr2.resource_seq_num = mrr1.resource_seq_num
   and mrr2.alternate_num = mrr1.alternate_num
   and mrr2.transaction_id <> mrr1.transaction_id
   and mrr1.setup_id is null  -- only non setup rows
   and mrr1.schedule_flag  = 1 -- only run req rows
   and nvl(mrr2.parent_id,2) = 2;

  cursor res_inst_cur (p_plan number, p_inst number, p_org number, p_dept number, p_res number)is
  select mdr.owning_department_id department_id,
    mdri.res_instance_id,
    mdri.serial_number
  from msc_dept_res_instances mdri,
    msc_department_resources mdr
  where mdr.plan_id = p_plan
  and mdr.sr_instance_id = p_inst
  and mdr.organization_id = p_org
  and mdr.department_id = p_dept
  and mdr.resource_id = p_res
  and mdri.plan_id = mdr.plan_id
  and mdri.sr_instance_id = mdr.sr_instance_id
  and mdri.organization_id = mdr.organization_id
  and mdri.department_id = nvl(mdr.owning_department_id, mdr.department_id)
  and mdri.resource_id = mdr.resource_id;

  cursor inst_res_cur (p_plan number, p_inst number, p_org number, p_dept number, p_res number,
	p_res_instance number, p_serial_number varchar2 )is
  select distinct mdr.department_id department_id
  from msc_dept_res_instances mdri,
    msc_department_resources mdr
  where mdr.plan_id = p_plan
  and mdr.sr_instance_id = p_inst
  and mdr.organization_id = p_org
  and mdr.department_id = p_dept
  and mdr.resource_id = p_res;

  cursor c_res_node_label (p_plan_id number, p_inst_id number, p_trx_id number) is
    select msi.item_name,
    nvl(decode(mrr.setup_id, to_number(null), null,
      msc_gantt_utils.getSetupCode(mrr.plan_id,
        mrr.sr_instance_id, mrr.resource_id, mrr.setup_id)), null) setup_type,
    mtp.organization_code org_code,
    ms.new_order_quantity qty,
    mrr.batch_number,
    msc_get_name.alternate_rtg(mrr.plan_id, mrr.sr_instance_id, mrr.routing_sequence_id) alt_rtg,
    mrr.assigned_units,
    msc_get_name.lookup_meaning('MRP_ORDER_TYPE', ms.order_type) order_type,
    mro.operation_description op_sdesc,
    mrr.operation_seq_num,
    mrr.resource_seq_num,
    ms.requested_completion_date req_comp_date,
    msc_get_name.supply_order_number(ms.order_type, ms.order_number, ms.plan_id,
        ms.sr_instance_id, ms.transaction_id, ms.disposition_id) order_number,
    mdr.department_code,
    mdr.resource_code
  from msc_resource_requirements mrr,
    msc_supplies ms,
    msc_system_items msi,
    msc_department_resources mdr,
    msc_routing_operations mro,
    msc_trading_partners mtp
  where mrr.plan_id = ms.plan_id
    and mrr.sr_instance_id = ms.sr_instance_id
    and mrr.supply_id = ms.transaction_id
    and ms.plan_id = msi.plan_id
    and ms.sr_instance_id = msi.sr_instance_id
    and ms.organization_id = msi.organization_id
    and ms.inventory_item_id = msi.inventory_item_id
    and ms.sr_instance_id = mtp.sr_instance_id
    and ms.organization_id = mtp.sr_tp_id
    and mtp.partner_type = 3
    and mdr.plan_id = mrr.plan_id
    and mdr.organization_id = mrr.organization_id
    and mdr.sr_instance_id = mrr.sr_instance_id
    and mdr.department_id = mrr.department_id
    and mdr.resource_id = mrr.resource_id
    and mrr.plan_id = mro.plan_id (+)
    and mrr.sr_instance_id = mro.sr_instance_id (+)
    and mrr.routing_sequence_id = mro.routing_sequence_id (+)
    and mrr.operation_sequence_id = mro.operation_sequence_id (+)
    and mrr.plan_id = p_plan_id
    and mrr.sr_instance_id = p_inst_id
    and mrr.transaction_id = p_trx_id;

-- cursors  -

procedure put_line(p_string varchar2) is
begin
  null;
  --dbms_output.put_line(p_string);
end put_line;

function escapeSplChars(p_value varchar2) return varchar2 is
 l_value varchar2(1000);
begin
  l_value := p_value;
  l_value := replace(l_value, FIELD_SEPERATOR, FIELD_SEPERATOR_ESC);
  l_value := replace(l_value, RECORD_SEPERATOR, RECORD_SEPERATOR_ESC);
  return l_value;
end escapeSplChars;

function get_child_res_trx_id(p_plan_id number, p_instance_id number,
  p_res_trx_id number) return number is

  cursor child_res_inst_info (p_plan number, p_inst number, p_trx number) is
  select mrir.res_inst_transaction_id
  from msc_resource_requirements mrr,
    msc_resource_instance_reqs mrir
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.transaction_id = p_trx
    and mrr.plan_id = mrir.plan_id
    and mrr.sr_instance_id = mrir.sr_instance_id
    and mrr.organization_id = mrir.organization_id
    and mrr.department_id = mrir.department_id
    and mrr.resource_id = mrir.resource_id
    and mrr.supply_id = mrir.supply_id
    and mrr.operation_seq_num = mrir.operation_seq_num
    and mrr.resource_seq_num = mrir.resource_seq_num
    and nvl(mrr.orig_resource_seq_num, mbp_null_value) = nvl(mrir.orig_resource_seq_num, mbp_null_value)
    and nvl(mrr.parent_seq_num, mbp_null_value) = nvl(mrir.parent_seq_num, mbp_null_value)
    and nvl(mrr.parent_id, mbp_null_value) = nvl(mrir.parent_id, mbp_null_value)
    and nvl(mrr.firm_start_date, mrr.start_date) = mrir.start_date
    and nvl(mrr.firm_end_date, mrr.end_date) = mrir.end_date
    and nvl(mrir.parent_id,2) = 2;

  l_trx_id number;
begin
  put_line('get_child_res_trx_id p_plan_id p_instance_id p_res_trx_id '||
	p_plan_id||' '||p_instance_id||' '||p_res_trx_id);
  -- get the child_res_inst_info
  open child_res_inst_info(p_plan_id, p_instance_id, p_res_trx_id);
  fetch child_res_inst_info into l_trx_id;
  close child_res_inst_info;
  put_line('get_child_res_trx_id l_trx_id '||l_trx_id);
  return l_trx_id;
end get_child_res_trx_id;


function get_parent_res_trx_id(p_plan_id number, p_instance_id number,
  p_res_inst_trx_id number) return number is

  cursor parent_res_info (p_plan number, p_inst number, p_trx number) is
  select mrr.transaction_id
  from msc_resource_requirements mrr,
    msc_resource_instance_reqs mrir
  where mrir.plan_id = p_plan
    and mrir.sr_instance_id = p_inst
    and mrir.res_inst_transaction_id = p_trx
    and mrir.plan_id = mrr.plan_id
    and mrir.sr_instance_id = mrr.sr_instance_id
    and mrir.organization_id = mrr.organization_id
    and mrir.department_id = mrr.department_id
    and mrir.resource_id = mrr.resource_id
    and mrir.supply_id = mrr.supply_id
    and mrir.operation_seq_num = mrr.operation_seq_num
    and mrir.resource_seq_num = mrr.resource_seq_num
    and nvl(mrir.orig_resource_seq_num, mbp_null_value) = nvl(mrr.orig_resource_seq_num, mbp_null_value)
    and nvl(mrir.parent_seq_num, mbp_null_value) = nvl(mrr.parent_seq_num, mbp_null_value)
    and nvl(mrir.parent_id, mbp_null_value) = nvl(mrr.parent_id, mbp_null_value)
    and mrir.start_date = nvl(mrr.firm_start_date, mrr.start_date)
    and mrir.end_date = nvl(mrr.firm_end_date, mrr.end_date)
    and nvl(mrr.parent_id,2) = 2;

  l_trx_id number;
begin
  open parent_res_info(p_plan_id, p_instance_id, p_res_inst_trx_id);
  fetch parent_res_info into l_trx_id;
  close parent_res_info;
  return l_trx_id;
end get_parent_res_trx_id;

procedure populateRowKeysIntoGantt(p_query_id number,
  p_index number, p_node_path varchar2, p_node_type number,
  p_transaction_id number, p_inst_id number, p_org_id number,
  p_dept_id number default null, p_res_id number default null,
  p_op_seq_num varchar2 default null, p_op_seq_id number default null,
  p_op_desc varchar2 default null, p_critical_flag number default null,
  p_parent_link varchar2 default null, p_node_level number default null) is
begin

  insert into msc_gantt_query (query_id,
    last_update_date, last_updated_by, creation_date, created_by,
    last_update_login, row_index, node_path, node_type, transaction_id,
    sr_instance_id, organization_id, department_id, resource_id, critical_flag,
    op_seq_id, op_seq_num, op_desc, parent_link, node_level )
  values (p_query_id,
    trunc(sysdate), -1, trunc(sysdate), -1, -1,
    p_index, p_node_path, p_node_type, p_transaction_id, p_inst_id, p_org_id,
    p_dept_id, p_res_id, p_critical_flag, p_op_seq_id, p_op_seq_num, p_op_desc,
    p_parent_link, p_node_level);

end populateRowKeysIntoGantt;

procedure populateEndPegsMFQ(p_plan_id in number,
  p_end_demand_id in number, p_query_id in number) is
begin

  insert into msc_form_query (query_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    number1)
  select
    p_query_id,
    sysdate, -1, sysdate, -1,-1,
    mfp.end_pegging_id
  from msc_full_pegging mfp
  where mfp.plan_id = p_plan_id
    and mfp.demand_id = p_end_demand_id;

end populateEndPegsMFQ;

procedure populateOrdersIntoGantt(p_plan_id number,
  p_query_id number, p_mfq_query_id number) is

  cursor c_mfq is
  select distinct
    ms.sr_instance_id,
    ms.organization_id,
    ms.transaction_id,
    decode(ms.order_type,
      14, COPROD_NODE,
      15, COPROD_NODE,
      16, COPROD_NODE,
      17, COPROD_NODE,
      28, COPROD_NODE,
      JOB_NODE) nodetype
  from msc_form_query mfq,
    msc_supplies ms
  where mfq.query_id = p_mfq_query_id
    and mfq.NUMBER2 = ms.sr_instance_id
    and mfq.NUMBER1 = ms.transaction_id
    and ms.plan_id = p_plan_id
  union all
  select distinct
    md.sr_instance_id,
    md.organization_id,
    md.demand_id,
    END_DEMAND_NODE nodetype
  from msc_form_query mfq,
    msc_demands md
  where mfq.query_id = p_mfq_query_id
    and mfq.NUMBER2 = md.sr_instance_id
    and mfq.NUMBER1 = md.demand_id
    and md.plan_id = p_plan_id;

 l_inst_id number;
 l_org_id number;
 l_trx_id number;
 l_node_type number;
 l_row_index number := 0;
BEGIN

  open c_mfq;
  loop
    fetch c_mfq into l_inst_id, l_org_id, l_trx_id, l_node_type;
    exit when c_mfq%notfound;

    insert into msc_gantt_query (
      query_id, last_update_date, last_updated_by, creation_date, created_by,
      last_update_login, row_index, node_level, node_path, node_type,
      sr_instance_id, organization_id, transaction_id )
    values (
      p_query_id, trunc(sysdate), -1, trunc(sysdate), -1, -1,
      l_row_index, 0, l_row_index, l_node_type, l_inst_id, l_org_id, l_trx_id );
    l_row_index := l_row_index + 1;
  end loop;
  close c_mfq;

END populateOrdersIntoGantt;

procedure populateOrdersIntoMFQ(p_inst_id in number,
  p_trx_id in number, p_query_id in number,
  p_one_record varchar2 default null) is
  v_instance_id number;
  v_transaction_id number;
begin

  if ( p_one_record is not null ) then
    v_instance_id := to_number(substr(p_one_record,1,instr(p_one_record,',')-1));
    v_transaction_id := to_number(substr(p_one_record,instr(p_one_record,',')+1));
  else
    v_instance_id := p_inst_id;
    v_transaction_id := p_trx_id;
  end if;

  insert into msc_form_query
  (query_id, last_update_date, last_updated_by, creation_date, created_by,
    last_update_login, number1, number2)
  values
  ( p_query_id, sysdate, -1, sysdate, -1, -1, v_transaction_id, v_instance_id);

end populateOrdersIntoMFQ;

procedure populateResIntoGanttFromGantt(p_query_id number, p_list varchar2, p_plan_id number) is
begin
       insert into msc_gantt_query ( query_id,
         last_update_date, last_updated_by, creation_date, created_by, last_update_login,
         row_index, plan_id, sr_instance_id, organization_id, department_id, resource_id,
         res_instance_id, serial_number, is_fetched )
       select p_query_id,
         sysdate, -1, sysdate, -1,-1,
         row_index, plan_id, sr_instance_id, organization_id, department_id, resource_id,
         res_instance_id, serial_number, sys_no
       from msc_gantt_query
       where query_id = to_number(p_list);
end populateResIntoGanttFromGantt;

procedure populateResIntoGantt(p_query_id number,
  p_row_index in out nocopy number, p_one_record in out nocopy varchar2,
  p_plan_id number, p_inst_id number default null, p_org_id number default null,
  p_dept_id number default null, p_res_id number default null,
  p_res_instance_id number default null, p_serial_number varchar2 default null,
  p_add_nodes number default null) is

  v_inst_id number;
  v_org_id number;
  v_dept_id number;
  v_res_id number;
  v_res_instance_id number;
  v_serial_number varchar2(30);

  l_row_found number;

begin

  if (p_one_record is not null) then
    parseResString(p_one_record, v_inst_id, v_org_id, v_dept_id, v_res_id,
      v_res_instance_id, v_serial_number);
  else
    v_inst_id := p_inst_id;
    v_org_id := p_org_id;
    v_dept_id := p_dept_id;
    v_res_id := p_res_id;
    v_res_instance_id := p_res_instance_id;
    v_serial_number := p_serial_number;
  end if;

  --insert if this is a resource first
  if ( nvl(v_res_instance_id,mbp_null_value) = mbp_null_value ) then -- {
    l_row_found := msc_gantt_utils.isResRowInGantt(p_query_id, p_plan_id,
      v_inst_id, v_org_id, v_dept_id, v_res_id,
      nvl(v_res_instance_id,mbp_null_value), nvl(v_serial_number,mbp_null_value_char));
    if (l_row_found = sys_no) then -- {
      p_row_index := p_row_index + 1;
      insert into msc_gantt_query ( query_id,
        last_update_date, last_updated_by, creation_date, created_by, last_update_login,
        row_index, plan_id, sr_instance_id, organization_id, department_id, resource_id,
        res_instance_id, serial_number, is_fetched )
      values ( p_query_id,
        sysdate, -1, sysdate, -1,-1,
        p_row_index, p_plan_id, v_inst_id, v_org_id, v_dept_id, v_res_id,
        nvl(v_res_instance_id,mbp_null_value), nvl(v_serial_number,mbp_null_value_char), sys_no );
    end if; -- }
  end if; -- }

  if ( nvl(p_add_nodes, sys_yes) = sys_yes ) then -- {
    if ( nvl(v_res_instance_id,mbp_null_value) = mbp_null_value ) then --{
      -- find res instances
      for c_res_inst in res_inst_cur(p_plan_id, v_inst_id, v_org_id, v_dept_id, v_res_id)
      loop -- {
        l_row_found := msc_gantt_utils.isResRowInGantt(p_query_id, p_plan_id,
	  v_inst_id, v_org_id, c_res_inst.department_id, v_res_id,
          nvl(c_res_inst.res_instance_id,mbp_null_value),
	  nvl(c_res_inst.serial_number,mbp_null_value_char));

        if (l_row_found = sys_no) then -- {
          p_row_index := p_row_index + 1;
          insert into msc_gantt_query ( query_id,
            last_update_date, last_updated_by, creation_date, created_by, last_update_login,
            row_index, plan_id, sr_instance_id, organization_id, department_id, resource_id,
            res_instance_id, serial_number, is_fetched )
          values ( p_query_id,
            sysdate, -1, sysdate, -1,-1,
            p_row_index, p_plan_id, v_inst_id, v_org_id, c_res_inst.department_id, v_res_id,
            nvl(c_res_inst.res_instance_id,mbp_null_value),
	    nvl(c_res_inst.serial_number,mbp_null_value_char), sys_no );
	end if; -- }
      end loop; -- }
    else
      -- find res
      for c_inst_res in inst_res_cur(p_plan_id, v_inst_id, v_org_id, v_dept_id, v_res_id,
        v_res_instance_id, v_serial_number)
      loop -- {
        l_row_found := msc_gantt_utils.isResRowInGantt(p_query_id, p_plan_id,
	  v_inst_id, v_org_id, c_inst_res.department_id, v_res_id,
          mbp_null_value, mbp_null_value_char);

        if (l_row_found = sys_no) then -- {
          p_row_index := p_row_index + 1;
          insert into msc_gantt_query ( query_id,
            last_update_date, last_updated_by, creation_date, created_by, last_update_login,
            row_index, plan_id, sr_instance_id, organization_id, department_id, resource_id,
            res_instance_id, serial_number, is_fetched )
          values ( p_query_id,
            sysdate, -1, sysdate, -1,-1,
            p_row_index, p_plan_id, v_inst_id, v_org_id, c_inst_res.department_id, v_res_id,
            mbp_null_value, mbp_null_value_char, sys_no );
	end if; -- }
      end loop; -- }
    end if; -- }
  end if; -- }

  --insert if this is a res inst node last
  if ( nvl(v_res_instance_id,mbp_null_value) <>  mbp_null_value ) then --{
    l_row_found := msc_gantt_utils.isResRowInGantt(p_query_id, p_plan_id,
      v_inst_id, v_org_id, v_dept_id, v_res_id,
      nvl(v_res_instance_id,mbp_null_value),
      nvl(v_serial_number,mbp_null_value_char));

    if (l_row_found = sys_no) then -- {
      p_row_index := p_row_index + 1;
      insert into msc_gantt_query ( query_id,
        last_update_date, last_updated_by, creation_date, created_by, last_update_login,
        row_index, plan_id, sr_instance_id, organization_id, department_id, resource_id,
        res_instance_id, serial_number, is_fetched )
      values ( p_query_id,
        sysdate, -1, sysdate, -1,-1,
        p_row_index, p_plan_id, v_inst_id, v_org_id, v_dept_id, v_res_id,
        nvl(v_res_instance_id,mbp_null_value), nvl(v_serial_number,mbp_null_value_char), sys_no );
     end if; -- }
   end if; -- }

end populateResIntoGantt;

procedure populateResIntoGanttFromMfq(p_query_id number,
  p_list varchar2, p_plan_id number) is

  v_inst_id number_arr;
  v_org_id number_arr;
  v_dept_id number_arr;
  v_res_id number_arr;
  v_res_instance_id number_arr;
  v_serial_number char_arr;

  v_one_record varchar2(100) := null;
  l_row_index number := 0;
begin

  select number1, number2, number3, number4, number5, char1
  bulk collect into v_inst_id, v_org_id, v_dept_id, v_res_id,
    v_res_instance_id, v_serial_number
  from msc_form_query
  where query_id = to_number(p_list);

  for i in 1.. v_inst_id.count loop
    populateResIntoGantt(p_query_id, l_row_index, v_one_record,p_plan_id, v_inst_id(i),
      v_org_id(i), v_dept_id(i), v_res_id(i), v_res_instance_id(i), v_serial_number(i));
  end loop;

end populateResIntoGanttFromMfq;

procedure populateResIntoMfq(p_query_id number, p_res_id number,
  p_res_instance_id number default null, p_serial_number varchar2 default null,
  p_res_name varchar2 default null, p_alt_number varchar2 default null) is
begin

  insert into msc_form_query ( query_id,
    last_update_date, last_updated_by, creation_date, created_by, last_update_login,
    number1, number2, char1, char9, number3)
  values ( p_query_id,
    sysdate, -1, sysdate, -1,-1,
    p_res_id, p_res_instance_id, p_serial_number, p_res_name, p_alt_number);

end populateResIntoMfq;

procedure getItemBomType(p_plan_id number, p_item_id number,
  p_bom_item_type out nocopy number, p_base_item_id out nocopy varchar2) is

  cursor c_bom_item is
  select bom_item_type, base_item_id
  from msc_system_items
  where plan_id = p_plan_id
    and inventory_item_id = p_item_id;
begin
  open c_bom_item;
  fetch c_bom_item into p_bom_item_type, p_base_item_id;
  close c_bom_item;
end getItemBomType;

procedure populateSuppIntoGantt(p_query_id number,
  p_row_index number, p_one_record in out nocopy varchar2, p_plan_id number,
  p_inst_id number default null, p_org_id number default null,
  p_item_id number default null, p_supplier_id number default null,
  p_supplier_site_id number default null) is

  v_inst_id number;
  v_org_id number;
  v_item_id number;
  v_supplier_id number;
  v_supplier_site_id number;

  v_bom_item_type number;
  v_base_item_id number;
begin

  if (p_one_record is not null) then
    parseSuppString(p_one_record, v_inst_id, v_org_id,
      v_item_id, v_supplier_id, v_supplier_site_id);
  else
    v_inst_id := p_inst_id;
    v_org_id := p_org_id;
    v_item_id := p_item_id;
    v_supplier_id := p_supplier_id;
    v_supplier_site_id := p_supplier_site_id;
  end if;

  getItemBomType(p_plan_id, v_item_id, v_bom_item_type, v_base_item_id);

  insert into msc_gantt_query (
    query_id,
    last_update_date, last_updated_by, creation_date, created_by, last_update_login,
    row_index, plan_id, inventory_item_id, supplier_id,
    supplier_site_id, is_fetched, dependency_type, department_id)
  values (
    p_query_id,
    sysdate, -1, sysdate, -1,-1,
    p_row_index, p_plan_id, v_item_id, v_supplier_id,
    nvl(v_supplier_site_id, -23453), sys_no, v_bom_item_type, v_base_item_id);

end populateSuppIntoGantt;

procedure populateSuppIntoGanttFromMfq(p_query_id number,
  p_list varchar2, p_plan_id number) is
  v_inst_id number_arr;
  v_org_id number_arr;
  v_item_id number_arr;
  v_supplier_id number_arr;
  v_supplier_site_id number_arr;
  v_one_record varchar2(100) := null;
begin

  select number1, number2, number3, number4, number5
  bulk collect into v_inst_id, v_org_id, v_item_id, v_supplier_id, v_supplier_site_id
  from msc_form_query
  where query_id = to_number(p_list);

  for i in 1.. v_inst_id.count loop
    populateSuppIntoGantt(p_query_id, i, v_one_record,p_plan_id,
      v_inst_id(i), v_org_id(i), v_item_id(i), v_supplier_id(i), v_supplier_site_id(i));
      null;
  end loop;

end populateSuppIntoGanttFromMfq;

procedure populateResDtlIntoGantt(p_query_id number,
 p_row_type number, p_row_index number,
 p_start_date date, p_end_date date,
 p_resource_units number, p_resource_hours number,
 p_schedule_flag number, p_detail_type number,
 p_display_type number default null) is
begin

  insert into msc_gantt_dtl_query ( query_id, row_type, row_index, parent_id,
    last_update_date, last_updated_by, creation_date, created_by, last_update_login,
    start_date, end_date, resource_units, resource_hours, schedule_flag, display_flag)
  values ( p_query_id, p_row_type, p_row_index, p_detail_type,
    sysdate, -1, sysdate, -1,-1,
    p_start_date, p_end_date, p_resource_units, p_resource_hours, p_schedule_flag, p_display_type);

end populateResDtlIntoGantt;

procedure populateResDtlTabIntoGantt(p_query_id number,
 p_row_type number, p_row_index number_arr,
 p_start_date date_arr, p_end_date date_arr,
 p_resource_units number_arr, p_resource_hours number_arr,
 p_schedule_flag number_arr, p_detail_type number,
 p_display_type number_arr default null,
 p_from_batch_node number default null) is

 l_display_type number;
 l_res_hours number;
 l_res_units number;
begin

  for i in 1..p_start_date.count
  loop -- {
    if ( p_row_type = RES_REQ_ROW_TYPE ) then -- {
      l_display_type := p_display_type(i);
    end if; -- }

    if ( nvl(p_from_batch_node, sys_no) = sys_yes) then
      l_res_units := ceil(p_resource_units(i));
      l_res_hours := l_res_units * p_resource_hours(i);
    else
      l_res_units := p_resource_units(i);
      l_res_hours := p_resource_hours(i);
    end if;

    insert into msc_gantt_dtl_query (
      query_id, row_type, row_index, parent_id,
      last_update_date, last_updated_by, creation_date, created_by, last_update_login,
      start_date, end_date, resource_units, resource_hours, schedule_flag,
      display_flag)
    values (
      p_query_id, p_row_type, p_row_index(i), p_detail_type,
      sysdate, -1, sysdate, -1,-1,
      p_start_date(i), p_end_date(i), l_res_units, l_res_hours,
      p_schedule_flag(i), l_display_type );
  end loop;  --}

end populateResDtlTabIntoGantt;

procedure populateSuppDtlIntoGantt(p_query_id number, p_row_type number,
  p_row_index number, p_start_date date, p_avail_qty number, p_overload_qty number,
  p_consume_qty number, p_detail_type number) is
begin

  insert into msc_gantt_dtl_query ( query_id, row_type, row_index, parent_id,
    last_update_date, last_updated_by, creation_date, created_by, last_update_login,
    start_date, supp_avail_qty, supp_overload_qty, supp_consume_qty)
  values ( p_query_id, p_row_type, p_row_index, p_detail_type,
    sysdate, -1, sysdate, -1,-1,
    p_start_date, p_avail_qty, p_overload_qty, p_consume_qty);

end populateSuppDtlIntoGantt;

procedure populateSuppDtlTabIntoGantt(p_query_id number,
 p_row_type number, p_row_index number_arr,
 p_start_date date_arr, p_units number_arr, p_number2 number_arr, p_detail_type number) is

  l_consumed_qty number;
begin

  for i in 1..p_start_date.count
  loop
    if ( p_row_type = SUPP_ALL_ROW_TYPE ) then
      l_consumed_qty := p_number2(i);
    else
      l_consumed_qty := to_number(null);
    end if;
    insert into msc_gantt_dtl_query (
      query_id, row_type, row_index, parent_id,
      last_update_date, last_updated_by, creation_date, created_by, last_update_login,
      start_date, resource_units, resource_hours)
    values (
      p_query_id, p_row_type, p_row_index(i), p_detail_type,
      sysdate, -1, sysdate, -1,-1,
      p_start_date(i), p_units(i), l_consumed_qty);
  end loop;

end populateSuppDtlTabIntoGantt;

procedure populateResActIntoDtlGantt(p_query_id number,
 p_row_type number, p_detail_type number,
 p_row_index number_arr, p_sr_instance_id number_arr,
 p_organization_id number_arr, p_supply_id number_arr, p_transaction_id number_arr,
 p_status number_arr, p_applied number_arr, p_res_firm_flag number_arr,
 p_sup_firm_flag number_arr, p_start_date date_arr, p_end_date date_arr,
 p_schedule_flag number_arr, p_res_constraint number_arr, p_qty number_arr,
 p_batch_number number_arr,  p_resource_units number_arr,
 p_group_sequence_id number_arr, p_group_sequence_number number_arr,
 p_cepst date_arr, p_cepct date_arr, p_ulpst date_arr, p_ulpct date_arr,
 p_uepst date_arr, p_uepct date_arr, p_eact date_arr, p_item_id number_arr,
 p_bar_text char_arr, p_order_number char_arr,
 p_op_seq number_arr, p_res_seq number_arr, p_res_desc char_arr, p_item_name char_arr,
 p_assy_item_desc char_arr, p_schedule_qty number_arr,
 p_from_setup_code char_arr, p_to_setup_code char_arr, p_std_op_code char_arr,
 p_changeover_time char_arr, p_changeover_penalty char_arr,
 p_overload_flag number_arr) is

begin

  forall i in p_sr_instance_id.first .. p_sr_instance_id.last
  --loop
    insert into msc_gantt_dtl_query (
      query_id, row_type, row_index, parent_id,
      last_update_date, last_updated_by, creation_date, created_by, last_update_login,
      sr_instance_id, organization_id, supply_id, transaction_id, status, applied,
      res_firm_flag, sup_firm_flag, start_date, end_date, schedule_flag, late_flag,
      supply_qty, batch_number, resource_units, group_sequence_id, group_sequence_number,
      cepst, cepct, ulpst, ulpct, uepst, uepct, eact, inventory_item_id, bar_label,
      order_number, op_seq_num, resource_seq_num, resource_description, item_name, assembly_item_desc, schedule_qty,
      from_setup_code, to_setup_code, std_op_code, changeover_time, changeover_penalty, supp_avail_qty)
    values (
      p_query_id, p_row_type, p_row_index(i), p_detail_type,
      sysdate, -1, sysdate, -1,-1,
      p_sr_instance_id(i), p_organization_id(i), p_supply_id(i), p_transaction_id(i),
      p_status(i), p_applied(i), p_res_firm_flag(i), p_sup_firm_flag(i),
      p_start_date(i), p_end_date(i), p_schedule_flag(i), p_res_constraint(i),
      p_qty(i), p_batch_number(i), p_resource_units(i), p_group_sequence_id(i),
      p_group_sequence_number(i), p_cepst(i), p_cepct(i), p_ulpst(i), p_ulpct(i),
      p_uepst(i), p_uepct(i), p_eact(i), p_item_id(i), p_bar_text(i),
      p_order_number(i), p_op_seq(i), p_res_seq(i), p_res_desc(i), p_item_name(i),
      p_assy_item_desc(i), p_schedule_qty(i),
      p_from_setup_code(i), p_to_setup_code(i), p_std_op_code(i), p_changeover_time(i),
      p_changeover_penalty(i), p_overload_flag(i));
  --end loop;

end populateResActIntoDtlGantt;

procedure populateBtchResIntoDtlGantt(p_query_id number,
 p_row_type number, p_detail_type number,
 p_row_index number_arr, p_sr_instance_id number_arr,
 p_organization_id number_arr, p_start_date date_arr, p_end_date date_arr,
 p_schedule_flag number_arr, p_batch_number number_arr,
 p_qty number_arr, p_bar_text char_arr, p_node_type number) is

   l_min_capacity number;
   l_max_capacity number;
   l_capacity_used number;
   l_res_desc varchar2(300);
begin

  for i in 1..p_sr_instance_id.count
  loop

    msc_gantt_utils.getBatchValues(g_plan_id, p_sr_instance_id(i), p_batch_number(i),
      l_res_desc, l_min_capacity, l_max_capacity, l_capacity_used);

    insert into msc_gantt_dtl_query (
      query_id, row_type, row_index, parent_id,
      last_update_date, last_updated_by, creation_date, created_by, last_update_login,
      sr_instance_id, organization_id, start_date, end_date, schedule_flag,
      batch_number, supply_qty, bar_label,
      resource_description, min_capacity, max_capacity, capacity_used)
    values (
      p_query_id, p_row_type, p_row_index(i), p_detail_type,
      sysdate, -1, sysdate, -1,-1,
      p_sr_instance_id(i), p_organization_id(i),
      p_start_date(i), p_end_date(i), p_schedule_flag(i),
      p_batch_number(i), p_qty(i), p_bar_text(i),
      l_res_desc, l_min_capacity, l_max_capacity, l_capacity_used);
  end loop;

end populateBtchResIntoDtlGantt;

function getResReqStartDate(p_firm_flag number,
  p_start_date date, p_end_date date,
  p_firm_start_date date, p_firm_end_date date, p_status number, p_applied number) return date is
  p_return_date date;
begin
  --5153956 bugfix
  if ( nvl(p_status,-1) = 0 and nvl(p_applied,-1) = 2) then
    p_return_date := nvl(p_firm_start_date, p_start_date);
    return p_return_date;
  else
    p_return_date := p_start_date;
  end if;
  --5153956 bugfix ends

  if ( p_firm_flag = NO_FIRM ) then
    p_return_date := p_start_date;
  elsif ( p_firm_flag = FIRM_RESOURCE ) then
    p_return_date := p_start_date;
  elsif ( p_firm_flag = FIRM_END ) then
    p_return_date := nvl(p_firm_end_date, p_end_date) - (p_end_date - p_start_date);
  elsif ( p_firm_flag = FIRM_END_RES ) then
    p_return_date := nvl(p_firm_end_date, p_end_date) - (p_end_date - p_start_date);
  else
    p_return_date := nvl(p_firm_start_date, p_start_date);
  end if;
  return p_return_date;

end getResReqStartDate;

function getResReqEndDate(p_firm_flag number,
  p_start_date date, p_end_date date,
  p_firm_start_date date, p_firm_end_date date, p_status number, p_applied number) return date is
  p_return_date date;
begin
  --5153956 bugfix
  if ( nvl(p_status,-1) = 0 and nvl(p_applied,-1) = 2) then
    p_return_date := nvl(p_firm_end_date, p_end_date);
    return p_return_date;
  else
    p_return_date := p_end_date;
  end if;
  --5153956 bugfix ends

  if ( p_firm_flag = NO_FIRM ) then
    p_return_date := p_end_date;
  elsif ( p_firm_flag = FIRM_RESOURCE ) then
    p_return_date := p_end_date;
  elsif ( p_firm_flag = FIRM_START ) then
    p_return_date := nvl(p_firm_start_date, p_start_date) + (p_end_date - p_start_date);
  elsif ( p_firm_flag = FIRM_START_RES ) then
    p_return_date := nvl(p_firm_start_date, p_start_date) + (p_end_date - p_start_date);
  else
    p_return_date := nvl(p_firm_end_date, p_end_date);
  end if;
  return p_return_date;

end getResReqEndDate;

function getResReqType(p_plan_id number,
  p_schedule_flag number, p_parent_seq_num number, p_setup_id number) return number is
  l_schedule_flag number;
begin

  if ( p_setup_id is not null ) then  -- sds row
     if ( p_schedule_flag = SCHEDULE_FLAG_YES ) then
       l_schedule_flag := RES_REQ_SDS_ROW_TYPE; -- SDS_RUN
     else
       l_schedule_flag := RES_SETUP_FIXED_ROW_TYPE; -- SDS_SETUP
     end if;
  else -- non-sds row
     if ( p_schedule_flag = SCHEDULE_FLAG_YES ) then
       l_schedule_flag := RES_REQ_ROW_TYPE; -- NORMAL_RUN
     else
       l_schedule_flag := RES_SETUP_ROW_TYPE; -- NORMAL_SETUP
     end if;
  end if ;
  return l_schedule_flag;

/*
  if ( p_parent_seq_num is not null ) then -- {
    if ( p_schedule_flag = SCHEDULE_FLAG_YES ) then -- {
      l_schedule_flag := RES_SETUP_ROW_TYPE; -- NORMAL_SETUP
    elsif ( p_schedule_flag in (SCHEDULE_FLAG_PRIOR, SCHEDULE_FLAG_NEXT) ) then
      l_schedule_flag := RES_SETUP_FIXED_ROW_TYPE; -- SDS_SETUP
    end if; -- }
  else
    if ( p_schedule_flag = SCHEDULE_FLAG_YES ) then -- {
      l_schedule_flag := RES_REQ_ROW_TYPE; -- NORMAL_RUN
    elsif ( p_schedule_flag in (SCHEDULE_FLAG_PRIOR, SCHEDULE_FLAG_NEXT) ) then
      l_schedule_flag := RES_REQ_SDS_ROW_TYPE; -- SDS_RUN
    end if;
  end if; -- }
*/
  return l_schedule_flag;
end getResReqType;

function getSetupCode(p_plan_id number, p_inst_id number,
  p_resource_id number, p_setup_id number) return varchar2 is
  l_setup_code varchar2(100);
begin

  select setup_code
  into l_setup_code
  from msc_resource_setups
  where plan_id = p_plan_id
    and sr_instance_id = p_inst_id
    and resource_id = p_resource_id
    and setup_id = p_setup_id;
  return l_setup_code;

exception
  when others then
    return null_space;

end getSetupCode;

function getMTQTime(p_transaction_id number,
  p_plan_id number, p_instance_id number) return number IS

  l_mtq number;
  l_cumm_quan number;
  l_order_quan number;
begin

   select mro.MINIMUM_TRANSFER_QUANTITY,
          mrr.cummulative_quantity, ms.new_order_quantity
     into l_mtq,l_cumm_quan, l_order_quan
     from msc_routing_operations mro,
          msc_resource_requirements mrr,
          msc_supplies ms
    where mrr.plan_id = p_plan_id
      and mrr.sr_instance_id = p_instance_id
      and mrr.transaction_id = p_transaction_id
      and mro.routing_sequence_id = mrr.routing_sequence_id
      and mro.operation_sequence_id = mrr.operation_sequence_id
      and mro.plan_id = p_plan_id
      and mro.sr_instance_id = p_instance_id
      and ms.plan_id = p_plan_id
      and ms.sr_instance_id = p_instance_id
      and ms.transaction_id = mrr.supply_id;

   if l_mtq is null then
      return 1;
   end if;

   if l_cumm_quan is null then
      if l_order_quan is null then
         return 1;
      end if;
      l_cumm_quan := l_order_quan;
   end if;

   if l_mtq >= l_cumm_quan or l_mtq < 0 then
      return 1;
   else
      return l_mtq/l_cumm_quan;
   end if;

exception
  when no_data_found then
    return 1;
end getMTQTime;

function isResOverload(p_plan_id number,
  p_instance_id number, p_organization_id number, p_inventory_item_id number,
  p_department_id number, p_resource_id number,
  p_transaction_id number) return number is

 cursor c_53 is
 select 'EXISTS'
 from   msc_exception_details
 where  number1 = p_transaction_id
 and    sr_instance_id = p_instance_id
 and    plan_id = p_plan_id
 and    exception_type = 53
 and    organization_id = p_organization_id
 --and    inventory_item_id = p_inventory_item_id
 and    department_id = p_department_id
 and    resource_id = p_resource_id;

 retval number;
 l_temp varchar2(10);

begin

   open c_53;
   fetch c_53 into l_temp;
   if c_53%found then
     retval := sys_yes;
   else
     retval := sys_no;
   end if;
   close c_53;
   return retval;

end isResOverload;

function isResConstraint(p_plan_id number,
  p_instance_id number, p_organization_id number, p_inventory_item_id number,
  p_department_id number, p_resource_id number,
  p_transaction_id number) return number is

 -------------------------------------------------------
 -- bug 2116260: logic for late_flag changed
 -- old logic:
 --     late if need_by_date < new_schedule_date
 -- new logic:
 --     late if HLS generated resource constraint
 --     (exception type = 36) while scheduling this
 --     supply for this transaction (even if there is
 --     one exception in any date-range)
 --------------------------------------------------------
 cursor resource_constraint_cur is
 select 'EXISTS'
 from   msc_exception_details
 where  number1 = p_transaction_id
 and    sr_instance_id = p_instance_id
 and    plan_id = p_plan_id
 and    exception_type =36
 and    organization_id = p_organization_id
 --and    inventory_item_id = p_inventory_item_id
 and    department_id = p_department_id
 and    resource_id = p_resource_id;

 retval number;
 l_resource_constraint varchar2(10);

begin

   open resource_constraint_cur;
   fetch resource_constraint_cur into l_resource_constraint;
   if resource_constraint_cur%found then
     retval := sys_yes;
   else
     retval := sys_no;
   end if;
   close resource_constraint_cur;
   return retval;

end isResConstraint;

function isExcpExists(p_plan_id number, p_instance_id number, p_organization_id number,
  p_department_id number, p_resource_id number, p_exception_type number) return number is

 cursor c_excp is
 select 'EXISTS'
 from msc_exception_details
 where plan_id = p_plan_id
   and sr_instance_id = p_instance_id
   and organization_id = p_organization_id
   and department_id = p_department_id
   and resource_id = p_resource_id
   and exception_type = p_exception_type;

 retval number;
 l_temp varchar2(10);

begin

   open c_excp;
   fetch c_excp into l_temp;
   if c_excp%found then
     retval := sys_yes;
   else
     retval := sys_no;
   end if;
   close c_excp;
   return retval;

end isExcpExists;

function isTimeFenceCrossed(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_start_date date) RETURN varchar2 IS

  l_timefence_date DATE;
  l_prev_start_date DATE;

BEGIN

  select getResReqStartDate(nvl(mrr.firm_flag,0),
    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) start_date,
    msi.planning_time_fence_date
  into l_prev_start_date, l_timefence_date
  from msc_system_items msi,
    msc_resource_requirements mrr,
    msc_supplies ms
  where mrr.plan_id = p_plan_id
    and mrr.transaction_id = p_transaction_id
    and mrr.sr_instance_id = p_instance_id
    and ms.plan_id = mrr.plan_id
    and ms.transaction_id = mrr.supply_id
    and ms.sr_instance_id = mrr.sr_instance_id
    and msi.plan_id = ms.plan_id
    and msi.organization_id = ms.organization_id
    and msi.sr_instance_id = ms.sr_instance_id
    and msi.inventory_item_id = ms.inventory_item_id;

  if ( l_timefence_date < l_prev_start_date
       and p_start_date < l_timefence_date )
    or (p_start_date > l_timefence_date
       and l_timefence_date > l_prev_start_date ) then
     return 'Y';
  else
     return 'N';
  end if;

end isTimeFenceCrossed;

function usingBatchableRes(p_plan_id number,
  p_transaction_id number, p_instance_id number) return boolean is

  v_flag number :=2;

begin

  select nvl(mdr.batchable_flag, 2)
    into v_flag
    from msc_resource_requirements mrr,
         msc_department_resources mdr
   where mrr.plan_id = p_plan_id
     and mrr.transaction_id = p_transaction_id
     and mrr.sr_instance_id = p_instance_id
     AND mdr.plan_id = mrr.plan_id
     AND mdr.organization_id = mrr.organization_id
     AND mdr.sr_instance_id = mrr.sr_instance_id
     AND mdr.department_id = mrr.department_id
     AND mdr.resource_id = mrr.resource_id;

  if v_flag = 2 then
     return false;
  else
     return true;
  end if;

end usingBatchableRes;

function isBatchable(p_plan_id number, p_inst_id number, p_org_id number,
  p_dept_id number, p_res_id number ) return number is

  l_flag number;
begin

  select nvl(batchable_flag, SYS_NO)
  into l_flag
  from msc_department_resources
  where plan_id = p_plan_id
  and sr_instance_id = p_inst_id
  and organization_id = p_org_id
  and department_id = p_dept_id
  and resource_id = p_res_id;

  return l_flag;

end isBatchable;

function isBtchResWithoutBatch(p_plan_id number, p_instance_id number, p_organization_id number,
  p_department_id number, p_resource_id number, p_res_inst_id number) return number is
  cursor c_temp is
  select sys_yes
  from msc_resource_requirements mrr
    where mrr.plan_id = p_plan_id
    and mrr.sr_instance_id = p_instance_id
    and mrr.organization_id = p_organization_id
    and mrr.department_id = p_department_id
    and mrr.resource_id = p_resource_id
    and mrr.parent_id = 2
    and batch_number is null
    and rownum = 1;
    l_temp number;
begin
  open c_temp;
  fetch c_temp into l_temp;
  close c_temp;
  return nvl(l_temp,sys_no);
end isBtchResWithoutBatch;

/*
function isResRowInGantt(p_query_id number,
  p_res_instance_id number, p_batchable number,
  p_ignore_batch_flag number default null) return number is

  cursor c_check_res_row is
  select sys_yes
  from msc_gantt_query mgq,
  msc_department_resources mdr
  where mgq.query_id = p_query_id
    and mgq.row_flag = SYS_YES
    and g_plan_id = mdr.plan_id
    and mgq.sr_instance_id = mdr.sr_instance_id
    and mgq.organization_id = mdr.organization_id
    and mgq.department_id = mdr.department_id
    and mgq.resource_id = mdr.resource_id
    and ( ( p_res_instance_id = sys_yes and mgq.res_instance_id <> mbp_null_value )
          or ( p_res_instance_id = sys_no and mgq.res_instance_id = mbp_null_value ) )
    and ( nvl(mdr.batchable_flag, sys_no) = p_batchable or nvl(p_ignore_batch_flag,2) = sys_yes)
    and rownum = 1;

  l_temp number;
begin
  open c_check_res_row;
  fetch c_check_res_row into l_temp;
  if (c_check_res_row%notfound) then
    l_temp := sys_no;
  end if;
  close c_check_res_row;
  return l_temp;
end isResRowInGantt;
*/
--4997096 bugfix
--commented the above fn isResRowInGantt as part of 4997096 bugfix
--provided a new procedure for the same

procedure isResRowInGantt(p_query_id number,
  p_res_rows out nocopy number,
  p_res_inst_rows out nocopy number,
  p_res_batch_rows out nocopy number,
  p_res_inst_batch_rows out nocopy number,
  p_batch_flag number default null) is

  l_temp number;
begin
  --regular resource
  select count(*)
    into l_temp
  from msc_gantt_query mgq,
  msc_department_resources mdr
  where mgq.query_id = p_query_id
    and mgq.row_flag = sys_yes
    and g_plan_id = mdr.plan_id
    and mgq.sr_instance_id = mdr.sr_instance_id
    and mgq.organization_id = mdr.organization_id
    and mgq.department_id = mdr.department_id
    and mgq.resource_id = mdr.resource_id
    and mgq.res_instance_id = mbp_null_value
    and ( ( nvl(mdr.batchable_flag, sys_no) = sys_no  and p_batch_flag is null)
          or (p_batch_flag = sys_no)
	  or isBtchResWithoutBatch(mdr.plan_id, mdr.sr_instance_id, mdr.organization_id,
	                                          mdr.department_id, mdr.resource_id, to_number(null))  = sys_yes );

    if (l_temp = 0) then
      p_res_rows := sys_no;
    else
      p_res_rows := sys_yes;
    end if;
    --regular resource ends

  --regular resource instance
  select count(*)
    into l_temp
  from msc_gantt_query mgq,
  msc_department_resources mdr
  where mgq.query_id = p_query_id
    and mgq.row_flag = sys_yes
    and g_plan_id = mdr.plan_id
    and mgq.sr_instance_id = mdr.sr_instance_id
    and mgq.organization_id = mdr.organization_id
    and mgq.department_id = mdr.department_id
    and mgq.resource_id = mdr.resource_id
    and mgq.res_instance_id <> mbp_null_value
    and ( ( nvl(mdr.batchable_flag, sys_no) = sys_no  and p_batch_flag is null)
          or (p_batch_flag = sys_no)
	  or isBtchResWithoutBatch(mdr.plan_id, mdr.sr_instance_id, mdr.organization_id,
	                                          mdr.department_id, mdr.resource_id, to_number(null))  = sys_yes );

    if (l_temp = 0) then
      p_res_inst_rows := sys_no;
    else
      p_res_inst_rows := sys_yes;
    end if;
    --regular resource  instance ends

  --regular batched resource
  select count(*)
    into l_temp
  from msc_gantt_query mgq,
  msc_department_resources mdr
  where mgq.query_id = p_query_id
    and mgq.row_flag = sys_yes
    and g_plan_id = mdr.plan_id
    and mgq.sr_instance_id = mdr.sr_instance_id
    and mgq.organization_id = mdr.organization_id
    and mgq.department_id = mdr.department_id
    and mgq.resource_id = mdr.resource_id
    and mgq.res_instance_id = mbp_null_value
    and nvl(mdr.batchable_flag, sys_no) = sys_yes;

    if (l_temp = 0) then
      p_res_batch_rows := sys_no;
    else
      p_res_batch_rows := sys_yes;
    end if;
    --regular batched resource ends

   --regular resource instance
  select count(*)
    into l_temp
  from msc_gantt_query mgq,
  msc_department_resources mdr
  where mgq.query_id = p_query_id
    and mgq.row_flag = sys_yes
    and g_plan_id = mdr.plan_id
    and mgq.sr_instance_id = mdr.sr_instance_id
    and mgq.organization_id = mdr.organization_id
    and mgq.department_id = mdr.department_id
    and mgq.resource_id = mdr.resource_id
    and mgq.res_instance_id <> mbp_null_value
    and nvl(mdr.batchable_flag, sys_no) = sys_yes;

    if (l_temp = 0) then
      p_res_inst_batch_rows := sys_no;
    else
      p_res_inst_batch_rows := sys_yes;
    end if;
    --regular resource  instance ends
end isResRowInGantt;

function isResRowInGantt(p_query_id number, p_plan_id number,
  p_inst_id number, p_org_id number, p_dept_id number, p_res_id number,
  p_res_inst_id number, p_serial_number varchar2) return number is

  cursor check_res_row_cur (p_query number,
    p_plan number, p_inst number, p_org number, p_dept number,
    p_res number, p_res_inst number, p_serial_num varchar2) is
  select count(*)
  from msc_gantt_query mgq
  where mgq.query_id = p_query
    and mgq.plan_id = p_plan
    and mgq.sr_instance_id = p_inst
    and mgq.organization_id = p_org
    and mgq.department_id = p_dept
    and mgq.resource_id = p_res
    and nvl(mgq.res_instance_id, MBP_NULL_VALUE) = nvl(p_res_inst, MBP_NULL_VALUE)
    and nvl(mgq.serial_number, MBP_NULL_VALUE_CHAR) = nvl(p_serial_num, MBP_NULL_VALUE_CHAR)
    and rownum = 1;

  l_row_count number;
begin
  open check_res_row_cur(p_query_id, p_plan_id, p_inst_id, p_org_id, p_dept_id,
    p_res_id, p_res_inst_id, p_serial_number);
  fetch check_res_row_cur into l_row_count;
  close check_res_row_cur;

  if (l_row_count > 0) then
    return sys_yes;
  end if;
  return sys_no;
end isResRowInGantt;


function getOrderNumber(p_plan_id number, p_inst_id number, p_trx_id number, p_disposition_id number,
  p_order_type number, p_order_number varchar2) return varchar2 is

  /*cursor c_order_number is
  select decode(p_order_type,
    5, decode(p_order_number, null, to_char(p_trx_id),
	p_order_number|| null_space ||to_char(p_trx_id)),
    14, decode(substr(msc_get_name.get_order_number(p_inst_id, p_plan_id,
	  p_disposition_id, 1),1,240), null, to_char(p_disposition_id),
        substr(msc_get_name.get_order_number(p_inst_id, p_plan_id,
	  p_disposition_id, 1),1,240)
	  || null_space || to_char(p_disposition_id)),
      17, decode(substr(msc_get_name.get_order_number(p_inst_id, p_plan_id,
        p_disposition_id, 1),1,240), null, to_char(p_disposition_id),
        substr(msc_get_name.get_order_number(p_inst_id, p_plan_id,
	  p_disposition_id, 1),1,240) || null_space || to_char(p_disposition_id)),
    51,to_char(p_trx_id),
    52,to_char(p_trx_id),
    15,to_char(p_trx_id),
    16,to_char(p_trx_id),
    28,to_char(p_trx_id),
    p_order_number)
  from dual;*/

  l_order_number varchar2(300);
  l_temp  varchar2(300);
begin
  /*open c_order_number;
  fetch c_order_number into l_order_number;
  close c_order_number;*/
  If p_order_type In (15,16,28,51,52) Then
      l_order_number := To_Char(p_trx_id);
  Elsif p_order_type = 5 Then
      If p_order_number Is Null Then
        l_order_number := To_Char(p_trx_id);
      Else
        l_order_number := p_order_number|| null_space ||To_Char(p_trx_id);
      End If;
  Elsif p_order_type In (14, 17) Then
      l_temp := Substr(msc_get_name.get_order_number
                          (p_inst_id, p_plan_id,
                           p_disposition_id, 1),1,240);
      If l_temp Is Null Then
        l_order_number := To_Char(p_disposition_id);
      Else
        l_order_number := l_temp ||null_space || To_Char(p_disposition_id);
      End If;
  Else
    l_order_number := p_order_number;
  End If;
  return l_order_number;

end getOrderNumber;

function getDeptResInstCode(p_plan_id number, p_instance_id number,
  p_org_id number, p_dept_id number, p_res_id number, p_res_instance_id number,
  p_serial_number varchar2) return varchar2 is

  cursor name is
  select mtp.organization_code
       ||':'||mdr.department_code || ':' || mdr.resource_code
  from   msc_department_resources mdr,
       msc_trading_partners mtp
  where mdr.department_id = p_dept_id
  and   mdr.resource_id = p_res_id
  and   mdr.plan_id = p_plan_id
  and   mdr.organization_id = p_org_id
  and   mdr.sr_instance_id = p_instance_id
  and   mtp.partner_type =3
  and   mtp.sr_tp_id = mdr.organization_id
  and   mtp.sr_instance_id = mdr.sr_instance_id;

  cursor inst_name is
  select msc_get_name.item_name(mdri.equipment_item_id, null, null, null)
     ||decode(mdri.serial_number, null, null_space, COLON_SEPARATOR || mdri.serial_number)
  from   msc_dept_res_instances mdri,
    msc_department_resources mdr,
    msc_trading_partners mtp
  where mdr.plan_id = p_plan_id
  and mdr.sr_instance_id = p_instance_id
  and mdr.organization_id = p_org_id
  and mdr.department_id = p_dept_id
  and mdr.resource_id = p_res_id
  and mdri.plan_id = mdr.plan_id
  and mdri.sr_instance_id = mdr.sr_instance_id
  and mdri.organization_id = mdr.organization_id
  and mdri.department_id = nvl(mdr.owning_department_id, mdr.department_id)
  and mdri.resource_id = mdr.resource_id
  and mdri.res_instance_id = p_res_instance_id
  and nvl(mdri.serial_number, MBP_NULL_VALUE_CHAR) = nvl(p_serial_number, MBP_NULL_VALUE_CHAR)
  and mtp.partner_type = 3
  and mtp.sr_tp_id = mdr.organization_id
  and mtp.sr_instance_id = mdr.sr_instance_id;

  v_name varchar2(240);
  v_inst_name varchar2(240);
begin

  if (p_res_instance_id = mbp_null_value) then
    return '';
  elsif (p_res_instance_id is not null) then
    open inst_name;
    fetch inst_name into v_inst_name;
    close inst_name;
    return v_inst_name;
  else
    open name;
    fetch name into v_name;
    close name;
    return v_name;
  end if;

end getDeptResInstCode;

procedure getBatchValues(p_plan_id number, p_instance_id number, p_batch_number number,
  p_res_desc out nocopy varchar2, p_min_capacity out nocopy number, p_max_capacity out nocopy number,
  p_capacity_used out nocopy number) is

  cursor c_batch is
  select mdr.resource_description,
    nvl(mrr.minimum_capacity, mdr.min_capacity),
    nvl(mrr.maximum_capacity, mdr.max_capacity),
    mrr.capacity_consumed_ratio * nvl(mrr.maximum_capacity, mdr.max_capacity) capacity_used
    from msc_resource_requirements mrr,
         msc_department_resources mdr
   where mrr.plan_id = p_plan_id
     and mrr.sr_instance_id = p_instance_id
     and mrr.batch_number = p_batch_number
     and mdr.plan_id = mrr.plan_id
     and mdr.organization_id = mrr.organization_id
     and mdr.sr_instance_id = mrr.sr_instance_id
     and mdr.department_id = mrr.department_id
     and mdr.resource_id = mrr.resource_id;
begin

  open c_batch;
  fetch c_batch into p_res_desc, p_min_capacity, p_max_capacity, p_capacity_used;
  close c_batch;

end getBatchValues;

function getTansitionValue(p_plan_id number, p_instance_id number,
  p_org_id number, p_dept_id number, p_res_id number, p_from_setup_id number,
  p_to_setup_id number, p_value_code varchar2) return varchar2 is

  cursor c_mst is
  select
    mst.transition_time,
    mst.transition_uom,
    mst.transition_penalty,
    mst.standard_operation_code
  from
    msc_setup_transitions mst
  where mst.plan_id = p_plan_id
    and mst.sr_instance_id = p_instance_id
    and mst.resource_id = p_res_id
    and mst.organization_id = p_org_id
    and mst.from_setup_id = p_from_setup_id
    and mst.to_setup_id = p_to_setup_id;

  l_transition_time number;
  l_transition_uom varchar2(10);
  l_transition_penalty number;
  l_std_op_code varchar2(10);
begin

  open c_mst;
  fetch c_mst into l_transition_time, l_transition_uom,
    l_transition_penalty, l_std_op_code;
  close c_mst;

  if (p_value_code = 'TRANSITION_TIME') then
    return l_transition_time;
  elsif (p_value_code = 'TRANSITION_UOM') then
    return l_transition_uom;
  elsif (p_value_code = 'TRANSITION_PENALTY') then
    return l_transition_penalty;
  elsif (p_value_code = 'STANDARD_OPERATION_CODE') then
    return l_std_op_code;
  else
    return null_space;
  end if;

end getTansitionValue;

function getDmdPriority(p_plan_id number,
  p_instance_id number, p_transaction_id number) return number is

  cursor dmd_cur is
  select min(md.demand_priority)
  from msc_demands md,
       msc_full_pegging mfp2,
       msc_full_pegging mfp1
  where mfp1.plan_id = p_plan_id
   and  mfp1.transaction_id = p_transaction_id
   and  mfp1.sr_instance_id = p_instance_id
   and  mfp2.pegging_id = mfp1.end_pegging_id
   and  mfp2.plan_id = mfp1.plan_id
   and  mfp2.sr_instance_id = mfp1.sr_instance_id
   and  md.plan_id = mfp2.plan_id
   and  md.sr_instance_id = mfp2.sr_instance_id
   and  md.demand_id = mfp2.demand_id
   and  md.demand_priority is not null;

  l_priority number;

begin

  if p_transaction_id is null or p_plan_id is null or
    p_instance_id is null then
    return null;
  end if;

  open dmd_cur;
  fetch dmd_cur into l_priority;
  close dmd_cur;
  return(l_priority);

end getDmdPriority;

function isResChargeable(p_plan_id number, p_instance_id number, p_org_id number,
  p_dept_id number, p_res_id number, p_res_instance_id number) RETURN number is

  cursor c_charge is
  select chargeable_flag
  from msc_department_resources mdr
  where mdr.plan_id = p_plan_id
  and mdr.sr_instance_id = p_instance_id
  and mdr.organization_id = p_org_id
  and mdr.department_id = p_dept_id
  and mdr.resource_id = p_res_id;

  l_chargeable_flag number;
begin

  open c_charge;
  fetch c_charge into l_chargeable_flag;
  close c_charge;
  return l_chargeable_flag;

end isResChargeable;

function isSupplyLate(p_plan_id number,
  p_instance_id number, p_organization_id number,
  p_inventory_item_id number, p_transaction_id number) return number is

  cursor c is
  select 1
  from msc_exception_details
  where number1 = p_transaction_id
    and sr_instance_id = p_instance_id
    and plan_id = p_plan_id
    and exception_type =36
    and organization_id = p_organization_id
    and inventory_item_id = p_inventory_item_id;

  v_isLate number := 0;

begin

  open c;
  fetch c into v_islate;
  close c;
  return v_isLate;

end isSupplyLate;

function getActualStartDate(p_order_type number, p_make_buy_code number,
  p_org_id number,p_source_org_id number,
  p_dock_date date, p_wip_start_date date,
  p_ship_date date, p_schedule_date date,
  p_source_supp_id number) return varchar2 is

  p_actual_start_date date;
  p_date varchar2(20);
  p_supply_type number;

begin

  if p_order_type = 3 then --5165402 bugfix
       p_supply_type := MAKE_SUPPLY;
  elsif p_org_id <> nvl(p_source_org_id, mbp_null_value) then
     p_supply_type := TRANSFER_SUPPLY;
  elsif p_order_type in (1,2,8,11,12) then
     p_supply_type := BUY_SUPPLY;
  elsif p_order_type = 5 then
     if p_source_supp_id is not null then --5057260 bugfix
       p_supply_type := BUY_SUPPLY;
     else
       p_supply_type := MAKE_SUPPLY;
     end if;
  else
     p_supply_type := MAKE_SUPPLY;
  end if;

  if p_supply_type = BUY_SUPPLY then
     p_actual_start_date := p_dock_date;
  elsif p_supply_type = MAKE_SUPPLY then
     p_actual_start_date := p_wip_start_date;
  elsif p_supply_type = TRANSFER_SUPPLY then
     p_actual_start_date := p_ship_date;
  else
     p_actual_start_date := p_schedule_date;
  end if;
  return to_char(nvl(p_actual_start_date,p_schedule_date),format_mask);

end getActualStartDate;

function isCriticalSupply(p_plan_id number, p_end_demand_id number,
  p_transaction_id number, p_inst_id number) Return number IS

  cursor critical_cur is
     select nvl(path_number,1)
       from msc_critical_paths
      where plan_id = p_plan_id
      and sr_instance_id = p_inst_id
      and supply_id = p_transaction_id
--      and routing_sequence_id is null
      and demand_id = p_end_demand_id;

  isCritical number :=-1;

begin

  open critical_cur;
  fetch critical_cur into iscritical;
  close critical_cur;
  return iscritical;

end isCriticalSupply;

function isCriticalRes(p_plan_id number,
  p_end_demand_id number, p_transaction_id number,
  p_inst_id number, p_operation_seq_id number,
  p_routing_seq_id number) return number is

  cursor critical_cur is
  select nvl(path_number,1)
  from msc_critical_paths
  where plan_id = p_plan_id
    and supply_id = p_transaction_id
    and sr_instance_id = p_inst_id
    and demand_id = p_end_demand_id
    and nvl(routing_sequence_id,-1) = nvl(p_routing_seq_id,-1)
    and operation_sequence_id = p_operation_seq_id;

  isCritical number;

begin
  isCritical := -1;
  open critical_cur;
  fetch critical_cur into iscritical;
  close critical_cur;
  return isCritical;

end isCriticalRes;

function getSupplyType(p_order_type number, p_make_buy_code number,
  p_org_id number,p_source_org_id number) return number is

  p_supply_type number;

begin

  if p_org_id <> p_source_org_id then
     p_supply_type := TRANSFER_SUPPLY;
  elsif p_order_type in (1,2,8,11,12) then
     p_supply_type := BUY_SUPPLY;
  elsif p_order_type = 5 and
        p_make_buy_code = 2 then
     p_supply_type := BUY_SUPPLY;
  else
     p_supply_type := MAKE_SUPPLY;
  end if;
  return p_supply_type;

end getSupplyType;

function getPlanInfo(p_plan_id number,
  p_first_date out nocopy date,  p_last_date out nocopy date,
  p_hour_bkt_start_date out nocopy date, p_day_bkt_start_date out nocopy date,
  p_plan_start_date out nocopy date, p_plan_end_date out nocopy date,
  p_plan_type out nocopy number) return varchar2 IS

   cursor cutoff_date_cur is
   select curr_start_date, curr_cutoff_date,
     nvl(min_cutoff_bucket,0)+nvl(hour_cutoff_bucket,0)+data_start_date daybkt_start,
     nvl(min_cutoff_bucket,0)+data_start_date hrbkt_start,
     decode(nvl(hour_cutoff_bucket,0),0, to_date(null),data_start_date) minbkt_start,
     sr_instance_id,
     organization_id
   from msc_plans
   where plan_id = p_plan_id;

  cursor daylevel_date_cur is
  select min(mpb.bkt_start_date), max(mpb.bkt_end_date)
  from msc_plan_buckets mpb,
    msc_plans mp
  where mp.plan_id =p_plan_id
    and mpb.plan_id = mp.plan_id
    and mpb.organization_id = mp.organization_id
    and mpb.sr_instance_id = mp.sr_instance_id
    and mpb.bucket_type =1;

   v_date date_arr;
   v_period varchar2(32000);
   p_bkt_type number;
   v_buckets varchar2(3200);
   v_min_day number;
   v_hour_day number;
   v_date_day number;
   v_bkt_date date;

  cursor bkt_cur is
  select max(mpb.bkt_end_date)
  from msc_plan_buckets mpb,
    msc_plans mp
  where mp.plan_id =p_plan_id
    and mpb.plan_id = mp.plan_id
    and mpb.organization_id = mp.organization_id
    and mpb.sr_instance_id = mp.sr_instance_id
    and mpb.bucket_type = p_bkt_type;

  cursor c_plan_cal is
  select mtp.calendar_code, mtp.sr_instance_id,
    mtp.calendar_exception_set_id, plan_type
  from msc_trading_partners mtp,
    msc_plans mp
  where mp.plan_id = p_plan_id
    and mp.sr_instance_id = mtp.sr_instance_id
    and mp.organization_id = mtp.sr_tp_id
    and mtp.partner_type = 3;

  cursor c_ds_orgs is
  select organization_id,
    nvl(curr_frozen_horizon_days, frozen_horizon_days) frozen_days
  from msc_plan_organizations
  where plan_id = p_plan_id
    and nvl(nvl(curr_ds_enabled_flag, ds_enabled_flag),2) = 1;

  v_org_id number_arr;
  v_frozen_days number_arr;
  v_ds_orgs_stream varchar2(200);

  p_min_bkt_start_date date;
begin
  open c_plan_cal;
  fetch c_plan_cal into g_plan_cal, g_plan_cal_inst_id,
    g_plan_cal_excp_id, p_plan_type;
  close c_plan_cal;

  g_plan_type := p_plan_type;
  g_plan_id := p_plan_id;

  open daylevel_date_cur;
  fetch daylevel_date_cur into p_first_date, p_last_date;
  close daylevel_date_cur;

  open cutoff_date_cur;
  fetch cutoff_date_cur into p_plan_start_date, p_plan_end_date,
    p_day_bkt_start_date, p_hour_bkt_start_date, p_min_bkt_start_date,
    g_plan_inst_id, g_plan_org_id;
  close cutoff_date_cur;

  -- fetch period start date
  select greatest(mpsd.period_start_date, mp.data_start_date)
  bulk collect into v_date
  from   msc_trading_partners tp,
    msc_period_start_dates mpsd,
    msc_plans mp
  where  mpsd.calendar_code = tp.calendar_code
    and mpsd.sr_instance_id = tp.sr_instance_id
    and mpsd.exception_set_id = tp.calendar_exception_set_id
    and tp.sr_instance_id = mp.sr_instance_id
    and tp.sr_tp_id = mp.organization_id
    and tp.partner_type =3
    and mp.plan_id = p_plan_id
    and (mpsd.period_start_date
      between mp.data_start_date and mp.curr_cutoff_date
      or mpsd.next_date between mp.data_start_date and mp.curr_cutoff_date)
  order by mpsd.period_start_date;

  v_period := to_char(v_date.count);
  for a in 1 .. v_date.count loop
    v_period := v_period || field_seperator|| to_char(v_date(a), format_mask);
  end loop;

  -- fetch bucket days
  select nvl(min_cutoff_bucket, 0),
    nvl(hour_cutoff_bucket, 0),
    nvl(daily_cutoff_bucket, 0)
  into v_min_day, v_hour_day, v_date_day
  from msc_plans
  where plan_id = p_plan_id;

  if v_min_day <> 0 then
    v_buckets := to_char(p_first_date + v_min_day, format_mask);
  else
    v_buckets := v_buckets || field_seperator|| null_space;
  end if;

  if v_hour_day <> 0 then
    v_buckets := v_buckets || field_seperator||
      to_char(p_first_date + v_min_day+v_hour_day, format_mask);
  else
    v_buckets := v_buckets || field_seperator|| null_space;
  end if;
  if v_min_day+v_hour_day <> v_date_day then
    v_buckets := v_buckets || field_seperator|| to_char(p_last_date, format_mask);
  else
    v_buckets := v_buckets || field_seperator|| null_space;
  end if;

  p_bkt_type := 1;
  for a in 1..2 loop -- {
    v_bkt_date := null;
    p_bkt_type := p_bkt_type +1;
    open bkt_cur;
    fetch bkt_cur into v_bkt_date;
    close bkt_cur;
    if v_bkt_date is not null then
        v_buckets := v_buckets || field_seperator||to_char(v_bkt_date, format_mask);
    else
        v_buckets := v_buckets || field_seperator|| null_space;
    end if;
  end loop; -- }

  open c_ds_orgs;
  fetch c_ds_orgs bulk collect into v_org_id, v_frozen_days;
  close c_ds_orgs;

  if (v_org_id.count = 0) then
    v_ds_orgs_stream := record_seperator||'0';
  end if;
  for a in 1..v_org_id.count
  loop
    if ( v_ds_orgs_stream is null ) then
      v_ds_orgs_stream := record_seperator
        || v_org_id.count || field_seperator|| v_org_id(a)
        || field_seperator || nvl(to_char(v_frozen_days(a)), null_space);
    else
      v_ds_orgs_stream := v_ds_orgs_stream || field_seperator ||
        v_org_id(a) || field_seperator || nvl(to_char(v_frozen_days(a)), null_space);
    end if;
  end loop;

  g_plan_cal_from_profile := fnd_profile.value('MSC_BKT_REFERENCE_CALENDAR');

  return p_plan_type || field_seperator ||
    to_char(p_plan_start_date, format_mask) || field_seperator ||
    to_char(p_plan_end_date, format_mask) || field_seperator ||
    v_buckets || record_seperator || v_period || v_ds_orgs_stream;

end getPlanInfo;

procedure sendSegmentPegStream(p_row_type number, p_row_index number, p_from_index number,
  p_producer_trans_id number_arr, p_producer_sr_instance_id number_arr,
  p_producer_op_seq_id number_arr, p_producer_op_seq_num number_arr, p_producer_res_seq_num number_arr,
  p_consumer_trans_id number_arr, p_consumer_sr_instance_id number_arr,
  p_consumer_op_seq_id number_arr, p_consumer_op_seq_num number_arr, p_consumer_res_seq_num number_arr,
  p_segment_start_date date_arr, p_segment_end_date date_arr, p_segment_quantity number_arr,
  p_consumer_start_date date_arr, p_consumer_end_date date_arr, p_allocation_type number_arr,
  p_dependency_type number_arr,  p_minimum_time_offset number_arr,
  p_maximum_time_offset number_arr, p_actual_time_offset number_arr,
  p_data_stream IN OUT NOCOPY msc_gantt_utils.maxCharTbl) is

  oneBigRecord maxCharTbl := maxCharTbl(0);
  l_data_stream maxCharTbl := maxCharTbl(0);
  reccount number := 0;
  j number :=1;
  ctr number;
  v_one_record varchar2(1000);
  v_max_len number;
  l_temp_len number;
begin

  put_line(' sendSegmentPegStream in');
   oneBigRecord.delete;
   oneBigRecord.extend;

   for b in 1 .. p_producer_trans_id.count loop -- {
     v_one_record := p_producer_trans_id(b)
       || field_seperator || p_producer_sr_instance_id(b)
       || field_seperator || nvl(to_char(p_producer_op_seq_id(b)), null_space)
       || field_seperator || nvl(to_char(p_producer_op_seq_num(b)), null_space)
       || field_seperator || nvl(to_char(p_producer_res_seq_num(b)), null_space)
       || field_seperator || p_consumer_trans_id(b)
       || field_seperator || p_consumer_sr_instance_id(b)
       || field_seperator || nvl(to_char(p_consumer_op_seq_id(b)), null_space)
       || field_seperator || nvl(to_char(p_consumer_op_seq_num(b)), null_space)
       || field_seperator || nvl(to_char(p_consumer_res_seq_num(b)), null_space)
       || field_seperator || nvl(to_char(p_segment_start_date(b),format_mask), null_space)
       || field_seperator || nvl(to_char(p_segment_end_date(b), format_mask), null_space)
       || field_seperator || fnd_number.number_to_canonical(nvl(p_segment_quantity(b),0))
       || field_seperator || nvl(to_char(p_consumer_start_date(b), format_mask), null_space)
       || field_seperator || nvl(to_char(p_consumer_end_date(b), format_mask), null_space)
       || field_seperator || nvl(to_char(p_allocation_type(b)), null_space)
       || field_seperator || nvl(to_char(p_dependency_type(b)), null_space)
       || field_seperator || nvl(to_char(p_minimum_time_offset(b)), null_space)
       || field_seperator || nvl(to_char(p_maximum_time_offset(b)), null_space)
       || field_seperator || nvl(to_char(p_actual_time_offset(b)), null_space);

     v_max_len := nvl(length(oneBigRecord(j)),0) + nvl(length(v_one_record),0);
     if v_max_len > 30000 then
       j := j+1;
       oneBigRecord.extend;
     end if;
     oneBigRecord(j) := oneBigRecord(j) || record_seperator || v_one_record;
     recCount := recCount+1;
   end loop; -- }

   if ( recCount > 0 ) then -- {
   ctr := p_data_stream.count;
   if ( nvl(length(p_data_stream(ctr)),0) = 1 ) then
     p_data_stream(ctr) := to_char(p_row_index) || field_seperator || recCount;
   elsif ( nvl(length(p_data_stream(ctr)),0) < 30000 ) then
     p_data_stream(ctr) := p_data_stream(ctr) || record_seperator
       || to_char(p_row_index) || field_seperator || recCount;
   else
     p_data_stream.extend;
     ctr := ctr + 1;
     p_data_stream(ctr) := p_data_stream(ctr) || record_seperator
       || to_char(p_row_index) || field_seperator || recCount;
   end if;

   for j in 1 .. oneBigRecord.count loop -- {
     l_temp_len := nvl(length(p_data_stream(ctr)),0)+ nvl(length(oneBigRecord(j)),0);
     if ( j = 1 ) then
       if (l_temp_len < 30000 ) then
         p_data_stream(ctr) := p_data_stream(ctr) || oneBigRecord(j);
       else
         p_data_stream.extend;
         ctr := ctr + 1;
         p_data_stream(ctr) := p_data_stream(ctr) || oneBigRecord(j);
       end if;
     elsif ( l_temp_len < 30000 ) then
       p_data_stream(ctr) := p_data_stream(ctr) || oneBigRecord(j);
     else
       p_data_stream.extend;
       ctr := ctr + 1;
       p_data_stream(ctr) := oneBigRecord(j);
     end if;
   end loop; -- }
   end if; -- }
  put_line(' sendSegmentPegStream out');

end sendSegmentPegStream;

procedure sendResReqAvailSuppStream(p_row_type number, p_row_index number,
  p_from_index number, p_start date_arr, p_end date_arr,
  p_resource_hours number_arr, p_resource_units number_arr,
  p_schedule_flag number_arr,
  p_data_stream IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_avail_qty number_arr default null, p_overload_qty number_arr default null,
  p_consume_qty number_arr default null, p_cum_avail_qty number_arr default null) is

  oneBigRecord maxCharTbl := maxCharTbl(0);
  l_data_stream maxCharTbl := maxCharTbl(0);
  reccount number := 0;
  j number :=1;
  ctr number;
  v_one_record varchar2(100);
  v_max_len number;
  l_temp_len number;

begin

   oneBigRecord.delete;
   oneBigRecord.extend;

   for b in 1 .. p_start.count loop -- {
     if ( p_row_type = RES_REQ_ROW_TYPE ) then
       v_one_record := to_char(p_start(b),format_mask) ||
         field_seperator || to_char(p_end(b),format_mask) ||
         field_seperator || nvl(to_char(fnd_number.number_to_canonical(p_resource_hours(b))), null_space) ||
         field_seperator || nvl(to_char(fnd_number.number_to_canonical(p_resource_units(b))), null_space) ||
         field_seperator || nvl(to_char(p_schedule_flag(b)), null_space) ||
         field_seperator || nvl(to_char(fnd_number.number_to_canonical(p_avail_qty(b))), null_space);
     elsif ( p_row_type = SUPP_ALL_ROW_TYPE ) then
       v_one_record := to_char(p_start(b),format_mask) ||
         field_seperator || nvl(to_char(fnd_number.number_to_canonical(p_consume_qty(b))), null_space)||
         field_seperator || nvl(to_char(fnd_number.number_to_canonical(p_overload_qty(b))), null_space)||
         field_seperator || nvl(to_char(fnd_number.number_to_canonical(p_avail_qty(b))), null_space);
     elsif ( p_row_type in (RES_CHARGES_ROW_TYPE, RES_AVAIL_ROW_TYPE) ) then
       v_one_record := to_char(p_start(b),format_mask) ||
         field_seperator || to_char(p_end(b),format_mask) ||
         field_seperator || nvl(to_char(fnd_number.number_to_canonical(p_resource_hours(b))), null_space)||
         field_seperator || nvl(to_char(fnd_number.number_to_canonical(p_resource_units(b))), null_space);
     elsif ( p_row_type = RES_REQ_DISPLAY_ROW_TYPE ) then
       v_one_record := to_char(p_start(b),format_mask) ||
         field_seperator || nvl(to_char(p_schedule_flag(b)), null_space)||
         field_seperator || nvl(to_char(fnd_number.number_to_canonical(p_avail_qty(b))), null_space)||
         field_seperator || nvl(to_char(fnd_number.number_to_canonical(p_resource_hours(b))), null_space);
     end if;

     v_max_len := nvl(length(oneBigRecord(j)),0) + nvl(length(v_one_record),0);
     if v_max_len > 30000 then
       j := j+1;
       oneBigRecord.extend;
     end if;
     oneBigRecord(j) := oneBigRecord(j) || record_seperator || v_one_record;
     recCount := recCount+1;
   end loop; -- }

   if ( recCount > 0 ) then -- {
   ctr := p_data_stream.count;
   if ( nvl(length(p_data_stream(ctr)),0) = 1 ) then
     p_data_stream(ctr) := to_char(p_row_index) || field_seperator || recCount;
   elsif ( nvl(length(p_data_stream(ctr)),0) < 30000 ) then
     p_data_stream(ctr) := p_data_stream(ctr) || record_seperator
       || to_char(p_row_index) || field_seperator || recCount;
   else
     p_data_stream.extend;
     ctr := ctr + 1;
     p_data_stream(ctr) := p_data_stream(ctr) || record_seperator
       || to_char(p_row_index) || field_seperator || recCount;
   end if;

   put_line('sendResReqAvailSuppStream: row_index row_type  rec_count: '
	||to_char(p_row_index) || field_seperator || to_char(p_row_type)
	|| field_seperator || to_char(recCount));

   for j in 1 .. oneBigRecord.count loop -- {
     l_temp_len := nvl(length(p_data_stream(ctr)),0)+ nvl(length(oneBigRecord(j)),0);
     if ( j = 1 ) then
       if (l_temp_len < 30000 ) then
         p_data_stream(ctr) := p_data_stream(ctr) || oneBigRecord(j);
       else
         p_data_stream.extend;
         ctr := ctr + 1;
         p_data_stream(ctr) := p_data_stream(ctr) || oneBigRecord(j);
       end if;
     elsif ( l_temp_len < 30000 ) then
       p_data_stream(ctr) := p_data_stream(ctr) || oneBigRecord(j);
     else
       p_data_stream.extend;
       ctr := ctr + 1;
       p_data_stream(ctr) := oneBigRecord(j);
     end if;
   end loop; -- }

   end if; -- }

end sendResReqAvailSuppStream;

procedure sendResActStream(p_row_index number, p_from_index number,
  p_inst_id number_arr, p_org_id number_arr,
  p_supply_id number_arr, p_trx_id number_arr, p_status number_arr,
  p_applied number_arr, p_res_firm_flag number_arr, p_sup_firm_flag number_arr,
  p_start_date date_arr, p_end_date date_arr, p_schedule_flag number_arr,
  p_res_constraint number_arr, p_qty number_arr, p_batch_number number_arr,
  p_resource_units number_arr, p_group_sequence_id number_arr,
  p_group_sequence_number number_arr, p_bar_text char_arr,
  p_display_type number_arr, p_cepst date_arr, p_cepct date_arr,
  p_ulpst date_arr, p_ulpct date_arr, p_uepst date_arr, p_uepct date_arr,
  p_eact date_arr, p_dept_id number_arr, p_res_id number_arr, p_item_id number_arr,
  p_order_number char_arr, p_op_seq number_arr, p_res_seq number_arr, p_res_desc char_arr,
  p_item_name char_arr, p_assy_item_desc char_arr, p_schedule_qty number_arr,
  p_from_setup_code char_arr, p_to_setup_code char_arr, p_std_op_code char_arr,
  p_changeover_time char_arr, p_changeover_penalty char_arr,
  p_min_capacity number_arr, p_max_capacity number_arr, p_capacity_used number_arr,
  p_overload_flag number_arr,
  p_data_stream IN OUT NOCOPY msc_gantt_utils.maxCharTbl) is

  oneBigRecord maxCharTbl := maxCharTbl(0);
  l_data_stream maxCharTbl := maxCharTbl(0);
  reccount number := 0;
  j number :=1;
  ctr number;
  v_one_record varchar2(1500);
  v_max_len number;
  l_temp_len number;


begin
   oneBigRecord.delete;
   oneBigRecord.extend;

   for b in 1 .. p_start_date.count loop -- {
      v_one_record := p_row_index || FIELD_SEPERATOR || null_space
        || FIELD_SEPERATOR || null_space || FIELD_SEPERATOR || null_space
        || FIELD_SEPERATOR || null_space
        || FIELD_SEPERATOR || null_space || FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || to_char(p_start_date(b), format_mask)
	|| FIELD_SEPERATOR || to_char(p_end_date(b), format_mask)
	|| FIELD_SEPERATOR || fnd_number.number_to_canonical(p_qty(b)) || FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || p_batch_number(b) || FIELD_SEPERATOR || fnd_number.number_to_canonical(p_resource_units(b))
	|| FIELD_SEPERATOR || null_space || FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || p_sup_firm_flag(b) || FIELD_SEPERATOR || p_res_firm_flag(b)
	|| FIELD_SEPERATOR || p_status(b) || FIELD_SEPERATOR || p_applied(b)
	|| FIELD_SEPERATOR || p_schedule_flag(b) || FIELD_SEPERATOR || p_supply_id(b)
	|| FIELD_SEPERATOR || p_trx_id(b) || FIELD_SEPERATOR || escapeSplChars(p_bar_text(b))
	|| FIELD_SEPERATOR || nvl(to_char(p_display_type(b)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_cepst(b),format_mask),null_space)
        || FIELD_SEPERATOR || nvl(to_char(p_cepct(b),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_ulpst(b),format_mask),null_space)
        || FIELD_SEPERATOR || nvl(to_char(p_ulpct(b),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_uepst(b),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_uepct(b),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_eact(b),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_inst_id(b)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_org_id(b)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_dept_id(b)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_res_id(b)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_item_id(b)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_res_seq(b)), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(p_order_number(b)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_op_seq(b)), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(p_res_desc(b)), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(p_item_name(b)), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(p_assy_item_desc(b)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(fnd_number.number_to_canonical(p_schedule_qty(b))), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(p_from_setup_code(b)), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(p_to_setup_code(b)), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(p_std_op_code(b)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_changeover_time(b)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_changeover_penalty(b)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(fnd_number.number_to_canonical(p_min_capacity(b))), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(fnd_number.number_to_canonical(p_max_capacity(b))), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(fnd_number.number_to_canonical(p_capacity_used(b))), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_group_sequence_id(b)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_group_sequence_number(b)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(p_overload_flag(b)), null_space)
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || null_space;

     v_max_len := nvl(length(oneBigRecord(j)),0) + nvl(length(v_one_record),0);
     if v_max_len > 30000 then
       j := j+1;
       oneBigRecord.extend;
     end if;
     oneBigRecord(j) := oneBigRecord(j) || record_seperator || v_one_record;
     recCount := recCount+1;
   end loop; -- }

   if ( recCount > 0 ) then -- {

   ctr := p_data_stream.count;
   if ( nvl(length(p_data_stream(ctr)),0) = 1 ) then
     p_data_stream(ctr) := to_char(p_row_index) || field_seperator || recCount;
   elsif ( nvl(length(p_data_stream(ctr)),0) < 30000 ) then
     p_data_stream(ctr) := p_data_stream(ctr) || record_seperator
       || to_char(p_row_index) || field_seperator || recCount;
   else
     p_data_stream.extend;
     ctr := ctr + 1;
     p_data_stream(ctr) := p_data_stream(ctr) || record_seperator
       || to_char(p_row_index) || field_seperator || recCount;
   end if;

put_line(' sendResActStream: row_index rec_count: '|| to_char(p_row_index) || field_seperator || to_char(recCount));

   for j in 1 .. oneBigRecord.count loop -- {
     l_temp_len := nvl(length(p_data_stream(ctr)),0)+ nvl(length(oneBigRecord(j)),0);
     if ( j = 1 ) then
       if (l_temp_len < 30000 ) then
         p_data_stream(ctr) := p_data_stream(ctr) || oneBigRecord(j);
       else
         p_data_stream.extend;
         ctr := ctr + 1;
         p_data_stream(ctr) := p_data_stream(ctr) || oneBigRecord(j);
       end if;
     elsif ( l_temp_len < 30000 ) then
       p_data_stream(ctr) := p_data_stream(ctr) || oneBigRecord(j);
     else
       p_data_stream.extend;
       ctr := ctr + 1;
       p_data_stream(ctr) := oneBigRecord(j);
     end if;
   end loop; -- }
   end if; -- }

end sendResActStream;

procedure populateResAvailGantt(p_query_id number,
  p_start_date date, p_end_date date) is

  v_avail_start date_arr;
  v_avail_end date_arr;
  v_resource_hours number_arr;
  v_resource_units number_arr;
  v_row_index number_arr;
  v_schdule_flag number_arr;

  l_res_rows number;
  l_res_inst_rows number;
  l_res_batch_rows number;
  l_res_inst_batch_rows number;

begin

  --l_res_rows := msc_gantt_utils.isResRowInGantt(p_query_id, sys_no, sys_no, sys_yes);
  --l_res_inst_rows := msc_gantt_utils.isResRowInGantt(p_query_id, sys_yes, sys_no, sys_yes);
  --4997096 bugfix, instead calls the below procedure
  msc_gantt_utils.isResRowInGantt(p_query_id, l_res_rows, l_res_inst_rows, l_res_batch_rows, l_res_inst_batch_rows);

  put_line('populateResAvailGantt: res - res inst - res batch - res inst batch : '
	||l_res_rows ||' - '|| l_res_inst_rows ||' - '||l_res_batch_rows ||' - '||l_res_inst_batch_rows);

  if ( l_res_rows = sys_yes or l_res_batch_rows = sys_yes ) then -- {

    select mgq.row_index,
      mrr.shift_date + mrr.from_time/86400 start_date,
      decode(sign(mrr.to_time - mrr.from_time), 1,
        mrr.shift_date + mrr.to_time/86400,
        mrr.shift_date + 1 + mrr.to_time/86400) end_date,
      (decode(sign(to_time - from_time), 1,
        shift_date + to_time/86400,
        shift_date + 1 + to_time/86400) -
	  (shift_date + from_time/86400)) * 24 * capacity_units res_hours,
      mrr.capacity_units,
      to_number(null) schdule_flag
    bulk collect into v_row_index, v_avail_start, v_avail_end,
      v_resource_hours, v_resource_units, v_schdule_flag
    from msc_net_resource_avail mrr,
      msc_gantt_query mgq
    where mgq.query_id = p_query_id
      and mgq.row_flag = SYS_YES
      and mgq.is_fetched = SYS_NO
      and mgq.res_instance_id = MBP_NULL_VALUE
      and mrr.plan_id = mgq.plan_id
      and mrr.sr_instance_id = mgq.sr_instance_id
      and mrr.organization_id = mgq.organization_id
      and mrr.department_id = mgq.department_id
      and mrr.resource_id = mgq.resource_id
      and nvl(mrr.parent_id,0) <> -1
      and mrr.capacity_units > 0
      and mrr.shift_date between p_start_date and p_end_date;

    put_line('populateResAvailGantt: res rows: '||v_avail_start.count );

    populateResDtlTabIntoGantt(p_query_id, RES_AVAIL_ROW_TYPE, v_row_index,
      v_avail_start, v_avail_end, v_resource_units, v_resource_hours,
      v_schdule_flag, SUMMARY_DATA);

  end if; -- }

  if ( l_res_inst_rows = sys_yes  or l_res_inst_batch_rows = sys_yes ) then -- {

    select mgq.row_index,
      mrr.shift_date + mrr.from_time/86400 start_date,
      decode(sign(mrr.to_time - mrr.from_time), 1,
        mrr.shift_date + mrr.to_time/86400,
        mrr.shift_date + 1 + mrr.to_time/86400) end_date,
      (decode(sign(to_time - from_time), 1,
        shift_date + to_time/86400,
        shift_date + 1 + to_time/86400) - (shift_date + from_time/86400)) * 24 res_hours,
      1 capacity_units,
      to_number(null) schdule_flag
    bulk collect into v_row_index, v_avail_start, v_avail_end,
      v_resource_hours, v_resource_units, v_schdule_flag
    from msc_net_res_inst_avail mrr,
      msc_gantt_query mgq
    where mgq.query_id = p_query_id
      and mgq.row_flag = SYS_YES
      and mgq.is_fetched = SYS_NO
      and mgq.res_instance_id <> MBP_NULL_VALUE
      and mrr.plan_id = mgq.plan_id
      and mrr.sr_instance_id = mgq.sr_instance_id
      and mrr.organization_id = mgq.organization_id
      and mrr.department_id = mgq.department_id
      and mrr.resource_id = mgq.resource_id
      and mrr.res_instance_id = mgq.res_instance_id
      and nvl(mrr.serial_number, MBP_NULL_VALUE_CHAR) = nvl(mgq.serial_number, MBP_NULL_VALUE_CHAR)
      and nvl(mrr.parent_id,0) <> -1
      and nvl(mrr.capacity_units,1) > 0
      and mrr.shift_date between p_start_date and p_end_date;

    put_line('populateResAvailGantt: res inst rows: '||v_avail_start.count );

    populateResDtlTabIntoGantt(p_query_id, RES_AVAIL_ROW_TYPE, v_row_index,
      v_avail_start, v_avail_end, v_resource_units, v_resource_hours,
      v_schdule_flag, SUMMARY_DATA);

  end if; -- }

end populateResAvailGantt;

function getResReqUlpsd(p_plan number, p_inst number, p_org number, p_dept number,
  p_res number, p_supply number, p_op_seq number, p_res_seq number,
  p_orig_res_seq number, p_parent_seq number) return date is

  cursor c_ulpsd is
  select mrr.ulpsd
  from msc_resource_requirements mrr
  where mrr.plan_id = p_plan
    and mrr.sr_instancE_id = p_inst
    and mrr.organization_id = p_org
    and mrr.department_id = p_dept
    and mrr.resource_id = p_res
    and mrr.supply_id = p_supply
    and mrr.operation_seq_num = p_op_seq
    and mrr.resource_seq_num = p_res_seq
    and nvl(mrr.orig_resource_seq_num, mbp_null_value) = nvl(p_orig_res_seq, mbp_null_value)
    and nvl(mrr.parent_seq_num, mbp_null_value) = nvl(p_parent_seq, mbp_null_value)
    and nvl(parent_id,2) = 2;

    l_ulpsd date;
 begin
   open c_ulpsd;
   fetch c_ulpsd into l_ulpsd;
   close c_ulpsd;

   return l_ulpsd;
 end getResReqUlpsd;

procedure populateResReqGanttNew(p_query_id number,
  p_start_date date, p_end_date date,
  p_display_type number default null) is

  v_row_index number_arr;
  v_req_start date_arr;
  v_req_end date_arr;
  v_resource_units number_arr;
  v_resource_hours number_arr;
  v_batch number_arr;
  v_schedule_flag  number_arr;
  v_res_firm_flag  number_arr;
  v_res_const_flag  number_arr;
  v_ulpsd_flag  date_arr;
  v_display_type number_arr;

  -- parent_id = 1 daily  requirements
  -- parent_id = 2 aggregated requirements

  cursor res_req_cur is
  select mgq.row_index,
    msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
        mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) start_date,
    msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
      mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) end_date,
    mrr.assigned_units,
    mrr.resource_hours,
    mrr.batch_number,
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id) schedule_flag,
    msc_gantt_utils.getDisplayType(p_display_type,
      msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
      mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
  	msc_gantt_utils.getResReqUlpsd(mrr.plan_id, mrr.sr_instancE_id, mrr.organization_id,
	  mrr.department_id, mrr.resource_id, mrr.supply_id, mrr.operation_seq_num, mrr.resource_seq_num,
	  mrr.orig_resource_seq_num, mrr.parent_seq_num),
        mrr.firm_flag,
        msc_gantt_utils.isResConstraint(mrr.plan_id,
	mrr.sr_instance_id, mrr.organization_id,
	ms.inventory_item_id, mrr.department_id, mrr.resource_id, mrr.supply_id),
        g_gantt_rh_toler_days_early,
        g_gantt_rh_toler_days_late) display_type
  from msc_gantt_query mgq,
    msc_resource_requirements mrr,
    msc_supplies ms
  where mgq.query_id = p_query_id
    and mgq.row_flag = SYS_YES
    and mgq.is_fetched = SYS_NO
    and mgq.res_instance_id = MBP_NULL_VALUE
    and mrr.plan_id = mgq.plan_id
    and mrr.sr_instance_id = mgq.sr_instance_id
    and mrr.organization_id = mgq.organization_id
    and mrr.department_id = mgq.department_id
    and mrr.resource_id = mgq.resource_id
    and mrr.plan_id = ms.plan_id
    and mrr.sr_instance_id = ms.sr_instance_id
    and mrr.supply_id = ms.transaction_id
    and mrr.batch_number is null and mrr.end_date is not null and mrr.resource_hours > 0
    and nvl(mrr.parent_id, 2) = 2
    and nvl(mrr.status,-1) = 0
    and nvl(mrr.applied,-1) = 2
    and ( ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date
	 )
         or ( msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date )
         or ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) <= p_start_date
           and msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) >= p_end_date )
       )
  union all
  select mgq.row_index,
    msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
        mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) start_date,
    msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
      mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) end_date,
    mrr.assigned_units,
    mrr.resource_hours,
    mrr.batch_number,
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id) schedule_flag,
    msc_gantt_utils.getDisplayType(p_display_type,
        msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
  	mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
  	msc_gantt_utils.getResReqUlpsd(mrr.plan_id, mrr.sr_instancE_id, mrr.organization_id,
	  mrr.department_id, mrr.resource_id, mrr.supply_id, mrr.operation_seq_num, mrr.resource_seq_num,
	  mrr.orig_resource_seq_num, mrr.parent_seq_num),
        mrr.firm_flag,
        msc_gantt_utils.isResConstraint(mrr.plan_id,
	mrr.sr_instance_id, mrr.organization_id,
	ms.inventory_item_id, mrr.department_id, mrr.resource_id, mrr.supply_id),
        g_gantt_rh_toler_days_early,
        g_gantt_rh_toler_days_late) display_type
  from msc_gantt_query mgq,
    msc_resource_requirements mrr,
    msc_resource_requirements mrr1,
    msc_supplies ms
  where mgq.query_id = p_query_id
    and mgq.row_flag = SYS_YES
    and mgq.is_fetched = SYS_NO
    and mgq.res_instance_id = MBP_NULL_VALUE
    and mrr.plan_id = mgq.plan_id
    and mrr.sr_instance_id = mgq.sr_instance_id
    and mrr.organization_id = mgq.organization_id
    and mrr.department_id = mgq.department_id
    and mrr.resource_id = mgq.resource_id
    and mrr.plan_id = ms.plan_id
    and mrr.sr_instance_id = ms.sr_instance_id
    and mrr.supply_id = ms.transaction_id
    and mrr.plan_id = mrr1.plan_id
    and mrr.sr_instancE_id = mrr1.sr_instancE_id
    and mrr.organization_id = mrr1.organization_id
    and mrr.department_id = mrr1.department_id
    and mrr.resource_id = mrr1.resource_id
    and mrr.supply_id = mrr1.supply_id
    and mrr.operation_seq_num = mrr1.operation_seq_num
    and mrr.resource_seq_num = mrr1.resource_seq_num
    and nvl(mrr.orig_resource_seq_num, mbp_null_value) = nvl(mrr1.orig_resource_seq_num, mbp_null_value)
    and nvl(mrr.parent_seq_num, mbp_null_value) = nvl(mrr1.parent_seq_num, mbp_null_value)
    and mrr.batch_number is null and mrr.end_date is not null and mrr.resource_hours > 0
    and mrr1.batch_number is null and mrr1.end_date is not null and mrr1.resource_hours > 0
    and nvl(mrr1.parent_id, 2) = 2
    and nvl(mrr1.status,-1) <> 0
    and nvl(mrr1.applied,-1) <> 2
    and nvl(mrr.parent_id,-1) = 1
    and ( ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date
	 )
         or ( msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date )
         or ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) <= p_start_date
           and msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) >= p_end_date )
       ) ;

  cursor res_inst_req_cur is
  select mgq.row_index,
    msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrir.start_date, mrir.end_date,
        mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) start_date,
    msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrir.start_date, mrir.end_date,
      mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) end_date,
    1 assigned_units,
    mrir.resource_instance_hours,
    mrr.batch_number,
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id) schedule_flag,
    msc_gantt_utils.getDisplayType(p_display_type,
      msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
  	mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
  	msc_gantt_utils.getResReqUlpsd(mrr.plan_id, mrr.sr_instancE_id, mrr.organization_id,
	  mrr.department_id, mrr.resource_id, mrr.supply_id, mrr.operation_seq_num, mrr.resource_seq_num,
	  mrr.orig_resource_seq_num, mrr.parent_seq_num),
        mrr.firm_flag,
        msc_gantt_utils.isResConstraint(mrr.plan_id,
	mrr.sr_instance_id, mrr.organization_id,
	ms.inventory_item_id, mrr.department_id, mrr.resource_id, mrr.supply_id),
        g_gantt_rh_toler_days_early,
        g_gantt_rh_toler_days_late) display_type
  from msc_gantt_query mgq,
    msc_resource_requirements mrr,
    msc_resource_instance_reqs mrir,
    msc_supplies ms
  where mgq.query_id = p_query_id
    and mgq.row_flag = SYS_YES
    and mgq.is_fetched = SYS_NO
    and mgq.res_instance_id <> MBP_NULL_VALUE
    and mrir.plan_id = mgq.plan_id
    and mrir.sr_instance_id = mgq.sr_instance_id
    and mrir.organization_id = mgq.organization_id
    and mrir.department_id = mgq.department_id
    and mrir.resource_id = mgq.resource_id
    and mrir.res_instance_id = mgq.res_instance_id
    and nvl(mrir.serial_number, MBP_NULL_VALUE_CHAR) = nvl(mgq.serial_number, MBP_NULL_VALUE_CHAR)
    and mrir.end_date is not null
    and mrir.plan_id = mrr.plan_id
    and mrir.sr_instance_id = mrr.sr_instance_id
    and mrir.organization_id = mrr.organization_id
    and mrir.department_id = mrr.department_id
    and mrir.resource_id = mrr.resource_id
    and mrir.supply_id = mrr.supply_id
    and mrir.operation_seq_num = mrr.operation_seq_num
    and mrir.resource_seq_num = mrr.resource_seq_num
    and nvl(mrir.orig_resource_seq_num, mbp_null_value) = nvl(mrr.orig_resource_seq_num, mbp_null_value)
    and nvl(mrir.parent_seq_num, mbp_null_value) = nvl(mrr.parent_seq_num, mbp_null_value)
    and nvl(mrir.parent_id, mbp_null_value) = nvl(mrr.parent_id, mbp_null_value)
    and mrir.start_date = nvl(mrr.firm_start_date, mrr.start_date)
    and mrir.end_date = nvl(mrr.firm_end_date, mrr.end_date)
    and mrr.plan_id = ms.plan_id
    and mrr.sr_instance_id = ms.sr_instance_id
    and mrr.supply_id = ms.transaction_id
    and mrr.batch_number is null and mrr.end_date is not null and mrr.resource_hours > 0
    and nvl(mrr.parent_id, 2) = 2
    and nvl(mrr.status,-1) = 0
    and nvl(mrr.applied,-1) = 2
    and ( ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date
	 )
         or ( msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date )
         or ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) <= p_start_date
           and msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) >= p_end_date )
       )
  union all
  select mgq.row_index,
    msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrir.start_date, mrir.end_date,
        mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) start_date,
      msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrir.start_date, mrir.end_date,
      mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) end_date,
    1 assigned_units,
    mrir.resource_instance_hours,
    mrr.batch_number,
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id) schedule_flag,
    msc_gantt_utils.getDisplayType(p_display_type,
      msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
  	mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
  	msc_gantt_utils.getResReqUlpsd(mrr.plan_id, mrr.sr_instancE_id, mrr.organization_id,
	  mrr.department_id, mrr.resource_id, mrr.supply_id, mrr.operation_seq_num, mrr.resource_seq_num,
	  mrr.orig_resource_seq_num, mrr.parent_seq_num),
        mrr.firm_flag,
        msc_gantt_utils.isResConstraint(mrr.plan_id,
	mrr.sr_instance_id, mrr.organization_id,
	ms.inventory_item_id, mrr.department_id, mrr.resource_id, mrr.supply_id),
        g_gantt_rh_toler_days_early,
        g_gantt_rh_toler_days_late) display_type
  from msc_gantt_query mgq,
    msc_resource_requirements mrr,
    msc_resource_requirements mrr1,
    msc_resource_instance_reqs mrir,
    msc_supplies ms
  where mgq.query_id = p_query_id
    and mgq.row_flag = SYS_YES
    and mgq.is_fetched = SYS_NO
    and mgq.res_instance_id <> MBP_NULL_VALUE
    and mrir.plan_id = mgq.plan_id
    and mrir.sr_instance_id = mgq.sr_instance_id
    and mrir.organization_id = mgq.organization_id
    and mrir.department_id = mgq.department_id
    and mrir.resource_id = mgq.resource_id
    and mrir.res_instance_id = mgq.res_instance_id
    and nvl(mrir.serial_number, MBP_NULL_VALUE_CHAR) = nvl(mgq.serial_number, MBP_NULL_VALUE_CHAR)
    and mrir.end_date is not null
    and mrir.plan_id = mrr.plan_id
    and mrir.sr_instance_id = mrr.sr_instance_id
    and mrir.organization_id = mrr.organization_id
    and mrir.department_id = mrr.department_id
    and mrir.resource_id = mrr.resource_id
    and mrir.supply_id = mrr.supply_id
    and mrir.operation_seq_num = mrr.operation_seq_num
    and mrir.resource_seq_num = mrr.resource_seq_num
    and nvl(mrir.orig_resource_seq_num, mbp_null_value) = nvl(mrr.orig_resource_seq_num, mbp_null_value)
    and nvl(mrir.parent_seq_num, mbp_null_value) = nvl(mrr.parent_seq_num, mbp_null_value)
    and nvl(mrir.parent_id, mbp_null_value) = nvl(mrr.parent_id, mbp_null_value)
    and mrir.start_date = nvl(mrr.firm_start_date, mrr.start_date)
    and mrir.end_date = nvl(mrr.firm_end_date, mrr.end_date)
    and mrr.plan_id = ms.plan_id
    and mrr.sr_instance_id = ms.sr_instance_id
    and mrr.supply_id = ms.transaction_id
    and mrr.plan_id = mrr1.plan_id
    and mrr.sr_instancE_id = mrr1.sr_instancE_id
    and mrr.organization_id = mrr1.organization_id
    and mrr.department_id = mrr1.department_id
    and mrr.resource_id = mrr1.resource_id
    and mrr.supply_id = mrr1.supply_id
    and mrr.operation_seq_num = mrr1.operation_seq_num
    and mrr.resource_seq_num = mrr1.resource_seq_num
    and nvl(mrr.orig_resource_seq_num, mbp_null_value) = nvl(mrr1.orig_resource_seq_num, mbp_null_value)
    and nvl(mrr.parent_seq_num, mbp_null_value) = nvl(mrr1.parent_seq_num, mbp_null_value)
    and mrr.batch_number is null and mrr.end_date is not null and mrr.resource_hours > 0
    and mrr1.batch_number is null and mrr1.end_date is not null and mrr1.resource_hours > 0
    and nvl(mrr1.parent_id, 2) = 2
    and nvl(mrr1.status,-1) <> 0
    and nvl(mrr1.applied,-1) <> 2
    and nvl(mrr.parent_id,-1) = 1
    and ( ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date
	 )
         or ( msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date )
         or ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) <= p_start_date
           and msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) >= p_end_date )
       );

  cursor res_req_btch_cur is
  select mgq.row_index,
    min(msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
        mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)) start_date,
    max(msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrr.start_date,
        mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)) end_date,
    sum(mrr.capacity_consumed_ratio) assigned_units,
    avg(mrr.resource_hours) resource_hours,
    mrr.batch_number,
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id) schedule_flag,
    decode(p_display_type, DISPLAY_NONE, sys_no,
      msc_gantt_utils.getDisplayType(p_display_type,
          msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
  	  mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
  	  msc_gantt_utils.getResReqUlpsd(mrr.plan_id, mrr.sr_instancE_id, mrr.organization_id,
	    mrr.department_id, mrr.resource_id, mrr.supply_id, mrr.operation_seq_num, mrr.resource_seq_num,
	    mrr.orig_resource_seq_num, mrr.parent_seq_num),
          mrr.firm_flag,
          msc_gantt_utils.isResConstraint(mrr.plan_id,
	    mrr.sr_instance_id, mrr.organization_id,
	    ms.inventory_item_id, mrr.department_id, mrr.resource_id, mrr.supply_id),
          g_gantt_rh_toler_days_early,
          g_gantt_rh_toler_days_late)) display_type
  from msc_gantt_query mgq,
    msc_resource_requirements mrr,
    msc_resource_batches mrb,
    msc_supplies ms
  where mgq.query_id = p_query_id
    and mgq.row_flag = SYS_YES
    and mgq.is_fetched = SYS_NO
    and mgq.res_instance_id = MBP_NULL_VALUE
    and mrr.plan_id = mgq.plan_id
    and mrr.sr_instance_id = mgq.sr_instance_id
    and mrr.organization_id = mgq.organization_id
    and mrr.department_id = mgq.department_id
    and mrr.resource_id = mgq.resource_id
    and mrb.plan_id = mrr.plan_id
    and mrb.sr_instance_id = mrr.sr_instance_id
    and mrb.organization_id= mrr.organization_id
    and mrb.department_id = mrr.department_id
    and mrb.resource_id = mrr.resource_id
    and mrb.batch_number = mrr.batch_number
    and mrr.plan_id = ms.plan_id
    and mrr.sr_instance_id = ms.sr_instance_id
    and mrr.supply_id = ms.transaction_id
    and mrr.batch_number is not null and mrr.end_date is not null and mrr.resource_hours > 0
    and nvl(mrr.parent_id, 2) = 2
    and nvl(mrr.status,-1) = 0
    and nvl(mrr.applied,-1) = 2
    and ( ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date
	 )
         or ( msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date )
         or ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) <= p_start_date
           and msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) >= p_end_date )
       )
    group by
    mgq.row_index,
    mrr.batch_number,
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id),
    msc_gantt_utils.getDisplayType(p_display_type,
        msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
  	mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
        msc_gantt_utils.getResReqUlpsd(mrr.plan_id, mrr.sr_instancE_id, mrr.organization_id,
	  mrr.department_id, mrr.resource_id, mrr.supply_id, mrr.operation_seq_num, mrr.resource_seq_num,
	  mrr.orig_resource_seq_num, mrr.parent_seq_num),
        mrr.firm_flag,
        msc_gantt_utils.isResConstraint(mrr.plan_id,
	  mrr.sr_instance_id, mrr.organization_id,
	  ms.inventory_item_id, mrr.department_id, mrr.resource_id, mrr.supply_id),
        g_gantt_rh_toler_days_early,
        g_gantt_rh_toler_days_late)
  union all
  select mgq.row_index,
    min(msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
        mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)) start_date,
    max(msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrr.start_date,
        mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)) end_date,
    sum(mrr.capacity_consumed_ratio) assigned_units,
    avg(mrr.resource_hours) resource_hours,
    mrr.batch_number,
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id) schedule_flag,
    decode(p_display_type, DISPLAY_NONE, sys_no,
      msc_gantt_utils.getDisplayType(p_display_type,
          msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
  	  mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
  	  msc_gantt_utils.getResReqUlpsd(mrr.plan_id, mrr.sr_instancE_id, mrr.organization_id,
	    mrr.department_id, mrr.resource_id, mrr.supply_id, mrr.operation_seq_num, mrr.resource_seq_num,
	    mrr.orig_resource_seq_num, mrr.parent_seq_num),
          mrr.firm_flag,
          msc_gantt_utils.isResConstraint(mrr.plan_id,
	    mrr.sr_instance_id, mrr.organization_id,
	    ms.inventory_item_id, mrr.department_id, mrr.resource_id, mrr.supply_id),
          g_gantt_rh_toler_days_early,
          g_gantt_rh_toler_days_late)) display_type
  from msc_gantt_query mgq,
    msc_resource_requirements mrr,
    msc_resource_requirements mrr1,
    msc_resource_batches mrb,
    msc_supplies ms
  where mgq.query_id = p_query_id
    and mgq.row_flag = SYS_YES
    and mgq.is_fetched = SYS_NO
    and mgq.res_instance_id = MBP_NULL_VALUE
    and mrr.plan_id = mgq.plan_id
    and mrr.sr_instance_id = mgq.sr_instance_id
    and mrr.organization_id = mgq.organization_id
    and mrr.department_id = mgq.department_id
    and mrr.resource_id = mgq.resource_id
    and mrb.plan_id = mrr.plan_id
    and mrb.sr_instance_id = mrr.sr_instance_id
    and mrb.organization_id= mrr.organization_id
    and mrb.department_id = mrr.department_id
    and mrb.resource_id = mrr.resource_id
    and mrb.batch_number = mrr.batch_number
    and mrr.plan_id = ms.plan_id
    and mrr.sr_instance_id = ms.sr_instance_id
    and mrr.supply_id = ms.transaction_id
    and mrr.plan_id = mrr1.plan_id
    and mrr.sr_instancE_id = mrr1.sr_instancE_id
    and mrr.organization_id = mrr1.organization_id
    and mrr.department_id = mrr1.department_id
    and mrr.resource_id = mrr1.resource_id
    and mrr.supply_id = mrr1.supply_id
    and mrr.operation_seq_num = mrr1.operation_seq_num
    and mrr.resource_seq_num = mrr1.resource_seq_num
    and nvl(mrr.orig_resource_seq_num, mbp_null_value) = nvl(mrr1.orig_resource_seq_num, mbp_null_value)
    and nvl(mrr.parent_seq_num, mbp_null_value) = nvl(mrr1.parent_seq_num, mbp_null_value)
    and mrr.batch_number is not null and mrr.end_date is not null and mrr.resource_hours > 0
    and mrr1.batch_number is not null and mrr1.end_date is not null and mrr1.resource_hours > 0
    and nvl(mrr1.parent_id, 2) = 2
    and nvl(mrr1.status,-1) <> 0
    and nvl(mrr1.applied,-1) <> 2
    and nvl(mrr.parent_id,-1) = 1
    and ( ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date
	 )
         or ( msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date )
         or ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) <= p_start_date
           and msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) >= p_end_date )
       )
    group by
    mgq.row_index,
    mrr.batch_number,
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id),
    msc_gantt_utils.getDisplayType(p_display_type,
        msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
  	mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
        msc_gantt_utils.getResReqUlpsd(mrr.plan_id, mrr.sr_instancE_id, mrr.organization_id,
	  mrr.department_id, mrr.resource_id, mrr.supply_id, mrr.operation_seq_num, mrr.resource_seq_num,
	  mrr.orig_resource_seq_num, mrr.parent_seq_num),
        mrr.firm_flag,
        msc_gantt_utils.isResConstraint(mrr.plan_id,
	  mrr.sr_instance_id, mrr.organization_id,
	  ms.inventory_item_id, mrr.department_id, mrr.resource_id, mrr.supply_id),
        g_gantt_rh_toler_days_early,
        g_gantt_rh_toler_days_late);

  cursor res_inst_req_btch_cur is
  select mgq.row_index,
     min(msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrir.start_date, mrir.end_date,
        mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)) start_date,
    max(msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrir.start_date,
        mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)) end_date,
    sum(mrir.capacity_consumed_ratio) assigned_units,
    avg(mrir.resource_instance_hours) resource_hours,
    mrir.batch_number,
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id) schedule_flag,
    decode(p_display_type, DISPLAY_NONE, sys_no,
      msc_gantt_utils.getDisplayType(p_display_type,
          msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
  	  mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
  	  msc_gantt_utils.getResReqUlpsd(mrr.plan_id, mrr.sr_instancE_id, mrr.organization_id,
	    mrr.department_id, mrr.resource_id, mrr.supply_id, mrr.operation_seq_num, mrr.resource_seq_num,
	    mrr.orig_resource_seq_num, mrr.parent_seq_num),
          mrr.firm_flag,
          msc_gantt_utils.isResConstraint(mrr.plan_id,
	    mrr.sr_instance_id, mrr.organization_id,
	    ms.inventory_item_id, mrr.department_id, mrr.resource_id, mrr.supply_id),
          g_gantt_rh_toler_days_early,
          g_gantt_rh_toler_days_late)) display_type
  from msc_gantt_query mgq,
    msc_resource_requirements mrr,
    msc_resource_instance_reqs mrir,
    msc_resource_batches mrb,
    msc_supplies ms
  where mgq.query_id = p_query_id
    and mgq.row_flag = SYS_YES
    and mgq.is_fetched = SYS_NO
    and mgq.res_instance_id <> MBP_NULL_VALUE
    and mrir.plan_id = mgq.plan_id
    and mrir.sr_instance_id = mgq.sr_instance_id
    and mrir.organization_id = mgq.organization_id
    and mrir.department_id = mgq.department_id
    and mrir.resource_id = mgq.resource_id
    and mrir.res_instance_id = mgq.res_instance_id
    and nvl(mrir.serial_number, MBP_NULL_VALUE_CHAR) = nvl(mgq.serial_number, MBP_NULL_VALUE_CHAR)
    and mrir.end_date is not null
    and mrir.plan_id = mrr.plan_id
    and mrir.sr_instance_id = mrr.sr_instance_id
    and mrir.organization_id = mrr.organization_id
    and mrir.department_id = mrr.department_id
    and mrir.resource_id = mrr.resource_id
    and mrir.supply_id = mrr.supply_id
    and mrir.resource_seq_num = mrr.resource_seq_num
    and mrir.operation_seq_num = mrr.operation_seq_num
    and nvl(mrir.orig_resource_seq_num, mbp_null_value) = nvl(mrr.orig_resource_seq_num, mbp_null_value)
    and nvl(mrir.parent_seq_num, mbp_null_value) = nvl(mrr.parent_seq_num, mbp_null_value)
    and nvl(mrir.parent_id, mbp_null_value) = nvl(mrr.parent_id, mbp_null_value)
    and mrir.start_date = nvl(mrr.firm_start_date, mrr.start_date)
    and mrir.end_date = nvl(mrr.firm_end_date, mrr.end_date)
    and mrb.plan_id = mrr.plan_id
    and mrb.sr_instance_id = mrr.sr_instance_id
    and mrb.organization_id= mrr.organization_id
    and mrb.department_id = mrr.department_id
    and mrb.resource_id = mrr.resource_id
    and mrb.batch_number = mrr.batch_number
    and mrr.plan_id = ms.plan_id
    and mrr.sr_instance_id = ms.sr_instance_id
    and mrr.supply_id = ms.transaction_id
    and mrr.batch_number is not null and mrr.end_date is not null and mrr.resource_hours > 0
    and nvl(mrr.parent_id, 2) = 2
    and nvl(mrr.status,-1) = 0
    and nvl(mrr.applied,-1) = 2
    and ( ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date
	 )
         or ( msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date )
         or ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) <= p_start_date
           and msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) >= p_end_date )
       )
    group by
    mgq.row_index,
    mrir.batch_number,
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id),
    msc_gantt_utils.getDisplayType(p_display_type,
      msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
  	mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
	msc_gantt_utils.getResReqUlpsd(mrr.plan_id, mrr.sr_instancE_id, mrr.organization_id,
	  mrr.department_id, mrr.resource_id, mrr.supply_id, mrr.operation_seq_num, mrr.resource_seq_num,
	  mrr.orig_resource_seq_num, mrr.parent_seq_num),
        mrr.firm_flag,
        msc_gantt_utils.isResConstraint(mrr.plan_id,
	  mrr.sr_instance_id, mrr.organization_id,
	  ms.inventory_item_id, mrr.department_id, mrr.resource_id, mrr.supply_id),
        g_gantt_rh_toler_days_early,
        g_gantt_rh_toler_days_late)
  union all
  select mgq.row_index,
     min(msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrir.start_date, mrir.end_date,
        mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)) start_date,
    max(msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrir.start_date,
        mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)) end_date,
    sum(mrir.capacity_consumed_ratio) assigned_units,
    avg(mrir.resource_instance_hours) resource_hours,
    mrir.batch_number,
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id) schedule_flag,
    decode(p_display_type, DISPLAY_NONE, sys_no,
      msc_gantt_utils.getDisplayType(p_display_type,
        msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
  	  mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
  	  msc_gantt_utils.getResReqUlpsd(mrr.plan_id, mrr.sr_instancE_id, mrr.organization_id,
	    mrr.department_id, mrr.resource_id, mrr.supply_id, mrr.operation_seq_num, mrr.resource_seq_num,
	    mrr.orig_resource_seq_num, mrr.parent_seq_num),
          mrr.firm_flag,
          msc_gantt_utils.isResConstraint(mrr.plan_id,
	    mrr.sr_instance_id, mrr.organization_id,
	    ms.inventory_item_id, mrr.department_id, mrr.resource_id, mrr.supply_id),
          g_gantt_rh_toler_days_early,
          g_gantt_rh_toler_days_late)) display_type
  from msc_gantt_query mgq,
    msc_resource_requirements mrr,
    msc_resource_requirements mrr1,
    msc_resource_batches mrb,
    msc_resource_instance_reqs mrir,
    msc_supplies ms
  where mgq.query_id = p_query_id
    and mgq.row_flag = SYS_YES
    and mgq.is_fetched = SYS_NO
    and mgq.res_instance_id <> MBP_NULL_VALUE
    and mrir.plan_id = mgq.plan_id
    and mrir.sr_instance_id = mgq.sr_instance_id
    and mrir.organization_id = mgq.organization_id
    and mrir.department_id = mgq.department_id
    and mrir.resource_id = mgq.resource_id
    and mrir.res_instance_id = mgq.res_instance_id
    and nvl(mrir.serial_number, MBP_NULL_VALUE_CHAR) = nvl(mgq.serial_number, MBP_NULL_VALUE_CHAR)
    and mrir.end_date is not null
    and mrir.plan_id = mrr.plan_id
    and mrir.sr_instance_id = mrr.sr_instance_id
    and mrir.organization_id = mrr.organization_id
    and mrir.department_id = mrr.department_id
    and mrir.resource_id = mrr.resource_id
    and mrir.supply_id = mrr.supply_id
    and mrir.resource_seq_num = mrr.resource_seq_num
    and mrir.operation_seq_num = mrr.operation_seq_num
    and nvl(mrir.orig_resource_seq_num, mbp_null_value) = nvl(mrr.orig_resource_seq_num, mbp_null_value)
    and nvl(mrir.parent_seq_num, mbp_null_value) = nvl(mrr.parent_seq_num, mbp_null_value)
    and nvl(mrir.parent_id, mbp_null_value) = nvl(mrr.parent_id, mbp_null_value)
    and mrir.start_date = nvl(mrr.firm_start_date, mrr.start_date)
    and mrir.end_date = nvl(mrr.firm_end_date, mrr.end_date)
    and mrb.plan_id = mrr.plan_id
    and mrb.sr_instance_id = mrr.sr_instance_id
    and mrb.organization_id= mrr.organization_id
    and mrb.department_id = mrr.department_id
    and mrb.resource_id = mrr.resource_id
    and mrb.batch_number = mrr.batch_number
    and mrr.plan_id = ms.plan_id
    and mrr.sr_instance_id = ms.sr_instance_id
    and mrr.supply_id = ms.transaction_id
    and mrr.plan_id = mrr1.plan_id
    and mrr.sr_instancE_id = mrr1.sr_instancE_id
    and mrr.organization_id = mrr1.organization_id
    and mrr.department_id = mrr1.department_id
    and mrr.resource_id = mrr1.resource_id
    and mrr.supply_id = mrr1.supply_id
    and mrr.operation_seq_num = mrr1.operation_seq_num
    and mrr.resource_seq_num = mrr1.resource_seq_num
    and nvl(mrr.orig_resource_seq_num, mbp_null_value) = nvl(mrr1.orig_resource_seq_num, mbp_null_value)
    and nvl(mrr.parent_seq_num, mbp_null_value) = nvl(mrr1.parent_seq_num, mbp_null_value)
    and mrr.batch_number is not null and mrr.end_date is not null and mrr.resource_hours > 0
    and mrr1.batch_number is not null and mrr1.end_date is not null and mrr1.resource_hours > 0
    and nvl(mrr1.parent_id, 2) = 2
    and nvl(mrr1.status,-1) <> 0
    and nvl(mrr1.applied,-1) <> 2
    and nvl(mrr.parent_id,-1) = 1
    and ( ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date
	 )
         or ( msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date )
         or ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) <= p_start_date
           and msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) >= p_end_date )
       )
    group by
    mgq.row_index,
    mrir.batch_number,
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id),
    msc_gantt_utils.getDisplayType(p_display_type,
        msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
  	mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
	msc_gantt_utils.getResReqUlpsd(mrr.plan_id, mrr.sr_instancE_id, mrr.organization_id,
	  mrr.department_id, mrr.resource_id, mrr.supply_id, mrr.operation_seq_num, mrr.resource_seq_num,
	  mrr.orig_resource_seq_num, mrr.parent_seq_num),
        mrr.firm_flag,
        msc_gantt_utils.isResConstraint(mrr.plan_id,
	  mrr.sr_instance_id, mrr.organization_id,
	  ms.inventory_item_id, mrr.department_id, mrr.resource_id, mrr.supply_id),
        g_gantt_rh_toler_days_early,
        g_gantt_rh_toler_days_late);

  l_res_rows number;
  l_res_inst_rows number;
  l_res_batch_rows number;
  l_res_inst_batch_rows number;

begin

  --l_res_rows := msc_gantt_utils.isResRowInGantt(p_query_id, sys_no, sys_no, sys_yes);
  --l_res_inst_rows := msc_gantt_utils.isResRowInGantt(p_query_id, sys_yes, sys_no, sys_yes);
  --l_res_batch_rows := msc_gantt_utils.isResRowInGantt(p_query_id, sys_no, sys_yes);
  --l_res_inst_batch_rows := msc_gantt_utils.isResRowInGantt(p_query_id, sys_yes, sys_yes);
  --4997096 bugfix, instead calls the below procedure
  msc_gantt_utils.isResRowInGantt(p_query_id, l_res_rows, l_res_inst_rows, l_res_batch_rows, l_res_inst_batch_rows);

  put_line('populateResReqGanttNew: res - res inst - res batch - res inst batch: '||
    l_res_rows ||' - '|| l_res_inst_rows ||' - '|| l_res_batch_rows
    ||' - '|| l_res_inst_batch_rows);

  if ( l_res_rows = sys_yes ) then
    open res_req_cur;
    fetch res_req_cur bulk collect into v_row_index, v_req_start,
      v_req_end, v_resource_units, v_resource_hours, v_batch, v_schedule_flag,
      v_display_type;
    close res_req_cur;

    put_line('populateResReqGanttNew: NEW LOGIC res req rows: '||v_row_index.count);

    populateResDtlTabIntoGantt(p_query_id, RES_REQ_ROW_TYPE, v_row_index,
      v_req_start, v_req_end, v_resource_units, v_resource_hours, v_schedule_flag, SUMMARY_DATA,
      v_display_type);
  end if;

  if ( l_res_batch_rows = sys_yes ) then
    open res_req_btch_cur;
    fetch res_req_btch_cur bulk collect into v_row_index, v_req_start,
      v_req_end, v_resource_units, v_resource_hours, v_batch, v_schedule_flag,
      v_display_type;
    close res_req_btch_cur;

    put_line('populateResReqGanttNew: NEW LOGIC batch res req rows: '||v_row_index.count);

    populateResDtlTabIntoGantt(p_query_id, RES_REQ_ROW_TYPE, v_row_index,
     v_req_start, v_req_end, v_resource_units, v_resource_hours, v_schedule_flag, SUMMARY_DATA,
     v_display_type, sys_yes);
  end if;

  if ( l_res_inst_rows = sys_yes ) then
    open res_inst_req_cur;
    fetch res_inst_req_cur bulk collect into v_row_index, v_req_start,
      v_req_end, v_resource_units, v_resource_hours, v_batch, v_schedule_flag,
      v_display_type;
    close res_inst_req_cur;

    put_line('populateResReqGanttNew: NEW LOGIC res inst req rows: '||v_row_index.count);

    populateResDtlTabIntoGantt(p_query_id, RES_REQ_ROW_TYPE, v_row_index,
      v_req_start, v_req_end, v_resource_units, v_resource_hours, v_schedule_flag, SUMMARY_DATA,
      v_display_type);

  end if;

  if ( l_res_inst_batch_rows = sys_yes ) then
    open res_inst_req_btch_cur;
    fetch res_inst_req_btch_cur bulk collect into v_row_index, v_req_start,
      v_req_end, v_resource_units, v_resource_hours, v_batch, v_schedule_flag,
      v_display_type;
    close res_inst_req_btch_cur;

    put_line('populateResReqGanttNew: NEW LOGIC batch res inst req rows: '||v_row_index.count);

    populateResDtlTabIntoGantt(p_query_id, RES_REQ_ROW_TYPE, v_row_index,
      v_req_start, v_req_end, v_resource_units, v_resource_hours, v_schedule_flag, SUMMARY_DATA,
      v_display_type, sys_yes);

  end if;

end populateResReqGanttNew;

function isResRowValidforResActView(p_plan number, p_inst number, p_org number,
  p_dept number, p_res number, p_start_date date, p_end_date date) return number is

  cursor c_res_row is
  select sys_yes
  from msc_plan_organizations mpo,
    msc_resource_requirements mrr,
    msc_department_resources mdr,
    msc_plans mp
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.organization_id = p_org
    and mrr.department_id = p_dept
    and mrr.resource_id = p_res
    and mdr.plan_id = mrr.plan_id
    and mdr.organization_id = mrr.organization_id
    and mdr.sr_instance_id = mrr.sr_instance_id
    and mdr.department_id = mrr.department_id
    and mdr.resource_id = mrr.resource_id
    and mrr.plan_id = mpo.plan_id
    and mrr.sr_instance_id = mpo.sr_instance_id
    and mrr.organization_id = mpo.organization_id
    and mrr.plan_id = mp.plan_id
    and ( ( nvl(nvl(curr_ds_enabled_flag, ds_enabled_flag),2) = 2 or nvl(mdr.schedule_to_instance, sys_no) = sys_no )
          or ( nvl(nvl(curr_ds_enabled_flag, ds_enabled_flag),2) = 1
	    and ( nvl(mdr.schedule_to_instance, sys_no) = sys_yes
                  and p_start_date >= nvl(mp.min_cutoff_bucket,0)+mp.data_start_date )
	    ));

  l_temp varchar2(10);
begin
  open c_res_row;
  fetch c_res_row into l_temp;
  close c_res_row;
  return l_temp;
end isResRowValidforResActView;

procedure populateResActGantt(p_query_id number,
  p_start_date date, p_end_date date,
  p_batched_res_act number,
  p_require_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_display_type number) is

 cursor res_act_cur is
 select mgq.row_index,
   mrr.sr_instance_id,
   mrr.organization_id,
   mrr.supply_id,
   mrr.transaction_id,
   nvl(mrr.status,0) status,
   nvl(mrr.applied,0) applied,
   nvl(mrr.firm_flag,0) res_firm_flag,
   ms.firm_planned_type sup_firm_flag,
   msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
     mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) start_date,
   msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
     mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) end_date,
   msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id) schedule_flag,
   msc_gantt_utils.isResConstraint(mrr.plan_id, mrr.sr_instance_id,
     mrr.organization_id, ms.inventory_item_id,
     mrr.department_id, mrr.resource_id, mrr.supply_id) res_constraint,
   ms.new_order_quantity qty,
   nvl(mrr.batch_number, mbp_null_value),
   mrr.assigned_units,
   nvl(mrr.group_sequence_id, mbp_null_value),
   nvl(mrr.group_sequence_number, mbp_null_value),
   mrr.earliest_start_date,
   mrr.earliest_completion_date,
   mrr.ulpsd,
   mrr.ulpcd,
   mrr.uepsd,
   mrr.uepcd,
   mrr.eacd,
   msc_gantt_utils.getResActResNodeLabel(mrr.plan_id, mrr.sr_instance_id, mrr.transaction_id) bar_text,
     ms.inventory_item_id,
     msc_get_name.supply_order_number(ms.order_type, ms.order_number, ms.plan_id,
       ms.sr_instance_id, ms.transaction_id, ms.disposition_id) order_number,
     mrr.operation_seq_num,
     mrr.resource_seq_num,
    mdr.resource_description,
      mi.item_name item,
      mi2.description assembly_item_desc,
      decode(mrr.resource_hours, 0, to_number(null),
        nvl(mrr.cummulative_quantity,ms.new_order_quantity)) schedule_qty,
  decode(mrr.from_setup_id,
    to_number(null), null,
    msc_get_name.setup_code(mrr.plan_id, mrr.sr_instance_id, mrr.resource_id,
      mrr.organization_id, mrr.from_setup_id)) from_setup_code,
  decode(mrr.setup_id,
    to_number(null), null,
    msc_get_name.setup_code(mrr.plan_id, mrr.sr_instance_id, mrr.resource_id,
      mrr.organization_id, mrr.setup_id)) to_setup_code,
  decode(mrr.from_setup_id,
    to_number(null), null,
    msc_gantt_utils.getTansitionValue(mrr.plan_id, mrr.sr_instance_id,
      mrr.organization_id, mrr.department_id, mrr.resource_id, mrr.from_setup_id,
        mrr.setup_id, 'STANDARD_OPERATION_CODE')) std_op_code,
  decode(mrr.from_setup_id,
    to_number(null), null,
    msc_gantt_utils.getTansitionValue(mrr.plan_id, mrr.sr_instance_id, mrr.organization_id,
      mrr.department_id, mrr.resource_id, mrr.from_setup_id,
      mrr.setup_id, 'TRANSITION_TIME')) changeover_time,
  decode(mrr.from_setup_id,
    to_number(null), null,
    msc_gantt_utils.getTansitionValue(mrr.plan_id, mrr.sr_instance_id, mrr.organization_id,
    mrr.department_id, mrr.resource_id, mrr.from_setup_id,
    mrr.setup_id, 'TRANSITION_PENALTY')) changeover_penalty,
   msc_gantt_utils.isResOverload(mrr.plan_id, mrr.sr_instance_id,
     mrr.organization_id, ms.inventory_item_id,
     mrr.department_id, mrr.resource_id, mrr.supply_id) res_overload
 from msc_resource_requirements mrr,
   msc_department_resources mdr,
   msc_supplies ms,
   msc_items mi,
   msc_items mi2,
   msc_gantt_query mgq,
   msc_plan_organizations mpo,
   msc_plans mp
 where mgq.query_id = p_query_id
   and mgq.row_flag = SYS_YES
   and (    ( p_batched_res_act = RES_REQ_ROW_TYPE )
         or ( p_batched_res_act = RES_ACT_BATCHED_ROW_TYPE and ( nvl(mdr.batchable_flag,2) = 2 or mrr.batch_number is null) ) )
   and mgq.is_fetched = SYS_NO
   and mgq.res_instance_id = MBP_NULL_VALUE
   and mrr.plan_id = mgq.plan_id
   and mrr.sr_instance_id = mgq.sr_instance_id
   and mrr.organization_id = mgq.organization_id
   and mrr.department_id = mgq.department_id
   and mrr.resource_id = mgq.resource_id
   and mrr.end_date is not null
   and nvl(mrr.parent_id,2) =2
   and ( ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date
	 )
         or ( msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date )
         or ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) <= p_start_date
           and msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) >= p_end_date )
       )
   and mrr.plan_id = mdr.plan_id
   and mrr.organization_id = mdr.organization_id
   and mrr.sr_instance_id = mdr.sr_instance_id
   and mrr.department_id = mdr.department_id
   and mrr.resource_id = mdr.resource_id
   and ms.plan_id = mrr.plan_id
   and ms.transaction_id = mrr.supply_id
   and ms.sr_instance_id = mrr.sr_instance_id
   and ms.inventory_item_id = mi.inventory_item_id
   and mrr.assembly_item_id = mi2.inventory_item_id
   and mrr.plan_id = mpo.plan_id
   and mrr.sr_instance_id = mpo.sr_instance_id
   and mrr.organization_id = mpo.organization_id
   and mrr.plan_id = mp.plan_id
   and ( ( nvl(nvl(mpo.curr_ds_enabled_flag, mpo.ds_enabled_flag),2) = 2 or nvl(mdr.schedule_to_instance, sys_no) = sys_no )
          or ( nvl(nvl(mpo.curr_ds_enabled_flag, mpo.ds_enabled_flag),2) = 1
	    and ( nvl(mdr.schedule_to_instance, sys_no) = sys_yes
                  and p_start_date >= nvl(mp.min_cutoff_bucket,0)+mp.data_start_date )
	    ));

 cursor res_inst_act_cur is
 select mgq.row_index,
   mrr.sr_instance_id,
   mrr.organization_id,
   mrr.supply_id,
   mrir.res_inst_transaction_id,
   nvl(mrr.status,0) status,
   nvl(mrr.applied,0) applied,
   nvl(mrr.firm_flag,0) res_firm_flag,
   ms.firm_planned_type sup_firm_flag,
   msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrir.start_date, mrir.end_date,
    mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) start_date,
   msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrir.start_date, mrir.end_date,
    mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) end_date,
   msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id) schedule_flag,
   msc_gantt_utils.isResConstraint(mrr.plan_id, mrr.sr_instance_id,
     mrr.organization_id, ms.inventory_item_id,
     mrr.department_id, mrr.resource_id, mrr.supply_id) res_constraint,
   ms.new_order_quantity qty,
   nvl(mrir.batch_number, mbp_null_value),
   1 assigned_units,
   nvl(mrr.group_sequence_id, mbp_null_value),
   nvl(mrr.group_sequence_number, mbp_null_value),
   mrr.earliest_start_date,
   mrr.earliest_completion_date,
   mrr.ulpsd,
   mrr.ulpcd,
   mrr.uepsd,
   mrr.uepcd,
   mrr.eacd,
   msc_gantt_utils.getResActResNodeLabel(mrr.plan_id, mrr.sr_instance_id, mrr.transaction_id) bar_text,
     ms.inventory_item_id,
     msc_get_name.supply_order_number(ms.order_type, ms.order_number, ms.plan_id,
       ms.sr_instance_id, ms.transaction_id, ms.disposition_id) order_number,
     mrr.operation_seq_num,
     mrr.resource_seq_num,
    mdr.resource_description,
      mi.item_name item,
      mi2.description assembly_item_desc,
      decode(mrr.resource_hours, 0, to_number(null),
        nvl(mrr.cummulative_quantity,ms.new_order_quantity)) schedule_qty,
  decode(mrr.from_setup_id,
    to_number(null), null,
    msc_get_name.setup_code(mrr.plan_id, mrr.sr_instance_id, mrr.resource_id,
      mrr.organization_id, mrr.from_setup_id)) from_setup_code,
  decode(mrr.setup_id,
    to_number(null), null,
    msc_get_name.setup_code(mrr.plan_id, mrr.sr_instance_id, mrr.resource_id,
      mrr.organization_id, mrr.setup_id)) to_setup_code,
  decode(mrr.from_setup_id,
    to_number(null), null,
    msc_gantt_utils.getTansitionValue(mrr.plan_id, mrr.sr_instance_id,
      mrr.organization_id, mrr.department_id, mrr.resource_id, mrr.from_setup_id,
        mrr.setup_id, 'STANDARD_OPERATION_CODE')) std_op_code,
  decode(mrr.from_setup_id,
    to_number(null), null,
    msc_gantt_utils.getTansitionValue(mrr.plan_id, mrr.sr_instance_id, mrr.organization_id,
      mrr.department_id, mrr.resource_id, mrr.from_setup_id,
      mrr.setup_id, 'TRANSITION_TIME')) changeover_time,
  decode(mrr.from_setup_id,
    to_number(null), null,
    msc_gantt_utils.getTansitionValue(mrr.plan_id, mrr.sr_instance_id, mrr.organization_id,
    mrr.department_id, mrr.resource_id, mrr.from_setup_id,
    mrr.setup_id, 'TRANSITION_PENALTY')) changeover_penalty,
   msc_gantt_utils.isResOverload(mrr.plan_id, mrr.sr_instance_id,
     mrr.organization_id, ms.inventory_item_id,
     mrr.department_id, mrr.resource_id, mrr.supply_id) res_overload
 from msc_resource_instance_reqs mrir,
   msc_resource_requirements mrr,
   msc_department_resources mdr,
   msc_supplies ms,
   msc_items mi,
   msc_items mi2,
   msc_gantt_query mgq
 where mgq.query_id = p_query_id
   and mgq.row_flag = SYS_YES
   and (    ( p_batched_res_act = RES_REQ_ROW_TYPE )
         or ( p_batched_res_act = RES_ACT_BATCHED_ROW_TYPE and ( nvl(mdr.batchable_flag,2) = 2  or mrir.batch_number is null )) )
   and mgq.is_fetched = SYS_NO
   and mgq.res_instance_id <> MBP_NULL_VALUE
   and mrir.plan_id = mgq.plan_id
   and mrir.sr_instance_id = mgq.sr_instance_id
   and mrir.organization_id = mgq.organization_id
   and mrir.department_id = mgq.department_id
   and mrir.resource_id = mgq.resource_id
   and mrir.res_instance_id = mgq.res_instance_id
   and nvl(mrir.serial_number, MBP_NULL_VALUE_CHAR) = nvl(mgq.serial_number, MBP_NULL_VALUE_CHAR)
   and mrir.end_date is not null
   and nvl(mrir.parent_id,2) =2
   and mrir.plan_id = mrr.plan_id
   and mrir.sr_instance_id = mrr.sr_instance_id
   and mrir.organization_id = mrr.organization_id
   and mrir.department_id = mrr.department_id
   and mrir.resource_id = mrr.resource_id
   and mrir.supply_id = mrr.supply_id
   and mrir.operation_seq_num = mrr.operation_seq_num
   and mrir.resource_seq_num = mrr.resource_seq_num
   and nvl(mrir.orig_resource_seq_num, mbp_null_value) = nvl(mrr.orig_resource_seq_num, mbp_null_value)
   and nvl(mrir.parent_seq_num, mbp_null_value) = nvl(mrr.parent_seq_num, mbp_null_value)
   and nvl(mrir.parent_id, mbp_null_value) = nvl(mrr.parent_id, mbp_null_value)
   and mrir.start_date = nvl(mrr.firm_start_date, mrr.start_date)
   and mrir.end_date = nvl(mrr.firm_end_date, mrr.end_date)
   and nvl(mrr.parent_id, 2) = 2
   and ( ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date
	 )
         or ( msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date )
         or ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) <= p_start_date
           and msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) >= p_end_date )
       )
   and ms.plan_id = mrr.plan_id
   and ms.transaction_id = mrr.supply_id
   and ms.sr_instance_id = mrr.sr_instance_id
   and mrr.plan_id = mdr.plan_id
   and mrr.organization_id = mdr.organization_id
   and mrr.sr_instance_id = mdr.sr_instance_id
   and mrr.department_id = mdr.department_id
   and mrr.resource_id = mdr.resource_id
   and ms.inventory_item_id = mi.inventory_item_id
   and mrr.assembly_item_id = mi2.inventory_item_id;

 cursor res_act_batch_cur is
 select mgq.row_index,
   mrr.sr_instance_id,
   mrr.organization_id,
  msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
    mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) start_date,
  msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
    mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) end_date,
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id) schedule_flag,
    sum(ms.new_order_quantity) qty,
    mrr.batch_number,
  msc_gantt_utils.getResBatchNodeLabel(
     nvl(decode(mrr.setup_id,
       to_number(null), null_space,
        msc_gantt_utils.getSetupCode(mrr.plan_id,
          mrr.sr_instance_id, mrr.resource_id, mrr.setup_id)),
       null_space),
    msc_get_name.org_code(mrr.organization_id, mrr.sr_instance_id),
    to_char(sum(ms.new_order_quantity)),
    to_char(mrr.batch_number),
    to_char(sum(mrr.capacity_consumed_ratio))) bar_text
 from msc_resource_requirements mrr,
   msc_supplies ms,
   msc_gantt_query mgq,
   msc_plan_organizations mpo,
   msc_department_resources mdr,
   msc_plans mp
 where mgq.query_id = p_query_id
   and mgq.row_flag = SYS_YES
   and mgq.is_fetched = SYS_NO
   and mgq.res_instance_id = MBP_NULL_VALUE
   and mrr.plan_id = mgq.plan_id
   and mrr.sr_instance_id = mgq.sr_instance_id
   and mrr.organization_id = mgq.organization_id
   and mrr.department_id = mgq.department_id
   and mrr.resource_id = mgq.resource_id
   and mrr.batch_number is not null
   and mrr.end_date is not null
   and nvl(mrr.parent_id,2) = 2
   and ( ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date
	 )
         or ( msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date )
         or ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) <= p_start_date
           and msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) >= p_end_date )
       )
   and ms.plan_id = mrr.plan_id
   and ms.transaction_id = mrr.supply_id
   and ms.sr_instance_id = mrr.sr_instance_id
   and mdr.plan_id = mrr.plan_id
   and mdr.organization_id = mrr.organization_id
   and mdr.sr_instance_id = mrr.sr_instance_id
   and mdr.department_id = mrr.department_id
   and mdr.resource_id = mrr.resource_id
   and mrr.plan_id = mpo.plan_id
   and mrr.sr_instance_id = mpo.sr_instance_id
   and mrr.organization_id = mpo.organization_id
   and mrr.plan_id = mp.plan_id
   and ( ( nvl(nvl(mpo.curr_ds_enabled_flag, mpo.ds_enabled_flag),2) = 2 or nvl(mdr.schedule_to_instance, sys_no) = sys_no )
          or ( nvl(nvl(mpo.curr_ds_enabled_flag, mpo.ds_enabled_flag),2) = 1
	    and ( nvl(mdr.schedule_to_instance, sys_no) = sys_yes
                  and p_start_date >= nvl(mp.min_cutoff_bucket,0)+mp.data_start_date )
	    ))
  group by mgq.row_index,
    mrr.plan_id,
    mrr.sr_instance_id,
    mrr.organization_id,
    msc_get_name.org_code(mrr.organization_id, mrr.sr_instance_id),
    mrr.resource_id,
    mrr.batch_number,
    msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
      mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
    msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
      mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id),
    mrr.setup_id;

cursor res_inst_act_batch_cur is
 select mgq.row_index,
   mrr.sr_instance_id,
   mrr.organization_id,
   msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrir.start_date, mrir.end_date,
     mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) start_date,
   msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrir.start_date, mrir.end_date,
     mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) end_date,
   msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id) schedule_flag,
   sum(ms.new_order_quantity) qty,
   mrir.batch_number,
   msc_gantt_utils.getResBatchNodeLabel(
     nvl(decode(mrr.setup_id,
       to_number(null), null_space,
        msc_gantt_utils.getSetupCode(mrr.plan_id,
          mrr.sr_instance_id, mrr.resource_id, mrr.setup_id)),
       null_space),
     msc_get_name.org_code(mrr.organization_id, mrr.sr_instance_id),
     to_char(sum(ms.new_order_quantity)),
     to_char(mrir.batch_number),
     to_char(sum(mrir.capacity_consumed_ratio))) bar_text
 from msc_resource_instance_reqs mrir,
   msc_resource_requirements mrr,
   msc_supplies ms,
   msc_gantt_query mgq
 where mgq.query_id = p_query_id
   and mgq.row_flag = SYS_YES
   and mgq.is_fetched = SYS_NO
   and mgq.res_instance_id <> MBP_NULL_VALUE
   and mrir.plan_id = mgq.plan_id
   and mrir.sr_instance_id = mgq.sr_instance_id
   and mrir.organization_id = mgq.organization_id
   and mrir.department_id = mgq.department_id
   and mrir.resource_id = mgq.resource_id
   and mrir.res_instance_id = mgq.res_instance_id
   and nvl(mrir.serial_number, MBP_NULL_VALUE_CHAR) = nvl(mgq.serial_number, MBP_NULL_VALUE_CHAR)
   and mrir.end_date is not null
   and mrir.batch_number is not null
   and nvl(mrir.parent_id,2) =2
   and mrir.plan_id = mrr.plan_id
   and mrir.sr_instance_id = mrr.sr_instance_id
   and mrir.organization_id = mrr.organization_id
   and mrir.department_id = mrr.department_id
   and mrir.resource_id = mrr.resource_id
   and mrir.supply_id = mrr.supply_id
   and mrir.operation_seq_num = mrr.operation_seq_num
   and mrir.resource_seq_num = mrr.resource_seq_num
   and nvl(mrir.orig_resource_seq_num, mbp_null_value) = nvl(mrr.orig_resource_seq_num, mbp_null_value)
   and nvl(mrir.parent_seq_num, mbp_null_value) = nvl(mrr.parent_seq_num, mbp_null_value)
   and nvl(mrir.parent_id, mbp_null_value) = nvl(mrr.parent_id, mbp_null_value)
   and mrir.start_date = nvl(mrr.firm_start_date, mrr.start_date)
   and mrir.end_date = nvl(mrr.firm_end_date, mrr.end_date)
   and nvl(mrr.parent_id, 2) = 2
   and ( ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date
	 )
         or ( msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
	    between p_start_date and p_end_date )
         or ( msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) <= p_start_date
           and msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	    mrir.start_date, mrir.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) >= p_end_date )
       )
   and ms.plan_id = mrr.plan_id
   and ms.transaction_id = mrr.supply_id
   and ms.sr_instance_id = mrr.sr_instance_id
  group by mgq.row_index,
    mrr.plan_id,
    mrr.sr_instance_id,
    mrr.organization_id,
    msc_get_name.org_code(mrr.organization_id, mrr.sr_instance_id),
    mrr.resource_id,
    mrir.batch_number,
    msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0), mrir.start_date, mrir.end_date,
      mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
    msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrir.start_date, mrir.end_date,
      mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied),
    msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id),
    mrr.setup_id;

l_op_seq number_arr;
l_res_seq number_arr;
l_res_desc char_arr;
l_item_name char_arr;
l_assy_item_desc char_arr;
l_schedule_qty number_arr;

l_from_setup_code char_arr;
l_to_setup_code char_arr;
l_std_op_code char_arr;
l_changeover_time char_arr;
l_changeover_penalty char_arr;

l_min_capacity number_arr;
l_max_capacity number_arr;
l_capacity_used number_arr;

l_row_index number_arr;
l_sr_instance_id number_arr;
l_organization_id number_arr;
l_inventory_item_id number_arr;
l_dept_id number_arr;
l_res_id number_arr;
l_supply_id number_arr;
l_transaction_id number_arr;
l_status number_arr;
l_applied number_arr;
l_res_firm_flag number_arr;
l_sup_firm_flag number_arr;
l_start_date date_arr;
l_end_date date_arr;
l_schedule_flag number_arr;
l_res_constraint number_arr;
l_qty number_arr;
l_batch_number number_arr;
l_resource_units number_arr;
l_group_sequence_id  number_arr;
l_group_sequence_number number_arr;
l_cepst date_arr;
l_cepct date_arr;
l_ulpst date_arr;
l_ulpct date_arr;
l_uepst date_arr;
l_uepct date_arr;
l_eacd date_arr;
l_bar_text char_arr;
l_display_type number_arr;
l_order_number char_arr;
l_overload_flag number_arr;

  l_res_rows number;
  l_res_inst_rows number;
  l_res_batch_rows number;
  l_res_inst_batch_rows number;

  p_start_index number;
  l_batch_flag number;
begin

  p_start_index := mbp_null_value;
  if ( p_batched_res_act = RES_ACT_BATCHED_ROW_TYPE) then -- {
    l_batch_flag := sys_yes;
  else
    l_batch_flag := sys_no;
  end if; -- }

  --l_res_rows := msc_gantt_utils.isResRowInGantt(p_query_id, sys_no, sys_no, sys_yes);
  --l_res_inst_rows := msc_gantt_utils.isResRowInGantt(p_query_id, sys_yes, sys_no, sys_yes);
  --l_res_batch_rows := msc_gantt_utils.isResRowInGantt(p_query_id, sys_no, sys_yes);
  --l_res_inst_batch_rows := msc_gantt_utils.isResRowInGantt(p_query_id, sys_yes, sys_yes);
  --4997096 bugfix, instead calls the below procedure
  msc_gantt_utils.isResRowInGantt(p_query_id, l_res_rows, l_res_inst_rows, l_res_batch_rows, l_res_inst_batch_rows, l_batch_flag);

  put_line('populateResActGantt: res - inst- res batch - inst batch: '||l_res_rows ||' - '|| l_res_inst_rows ||' - '|| l_res_batch_rows ||' - '|| l_res_inst_batch_rows);

  if ( l_res_rows = sys_yes ) then -- {

    open res_act_cur;
    fetch res_act_cur bulk collect into l_row_index, l_sr_instance_id, l_organization_id,
      l_supply_id, l_transaction_id, l_status, l_applied, l_res_firm_flag,
      l_sup_firm_flag, l_start_date, l_end_date, l_schedule_flag, l_res_constraint,
      l_qty, l_batch_number, l_resource_units, l_group_sequence_id, l_group_sequence_number,
      l_cepst, l_cepct, l_ulpst, l_ulpct, l_uepst, l_uepct, l_eacd, l_bar_text, l_inventory_item_id,
      l_order_number, l_op_seq, l_res_seq, l_res_desc, l_item_name, l_assy_item_desc, l_schedule_qty,
      l_from_setup_code, l_to_setup_code, l_std_op_code, l_changeover_time, l_changeover_penalty, l_overload_flag;
    close res_act_cur;

    put_line('populateResActGantt: res act rows: '||l_sr_instance_id.count);

    populateResActIntoDtlGantt(p_query_id, RES_REQ_ROW_TYPE, SUMMARY_DATA,
      l_row_index, l_sr_instance_id, l_organization_id, l_supply_id,
      l_transaction_id, l_status, l_applied, l_res_firm_flag, l_sup_firm_flag,
      l_start_date, l_end_date, l_schedule_flag, l_res_constraint, l_qty, l_batch_number,
      l_resource_units, l_group_sequence_id, l_group_sequence_number,
      l_cepst, l_cepct, l_ulpst, l_ulpct, l_uepst, l_uepct, l_eacd, l_inventory_item_id, l_bar_text,
      l_order_number, l_op_seq, l_res_seq, l_res_desc, l_item_name, l_assy_item_desc, l_schedule_qty,
      l_from_setup_code, l_to_setup_code, l_std_op_code, l_changeover_time, l_changeover_penalty, l_overload_flag);

  end if; -- }

  if ( l_res_inst_rows = sys_yes ) then -- {

    open res_inst_act_cur;
    fetch res_inst_act_cur bulk collect into l_row_index, l_sr_instance_id, l_organization_id,
      l_supply_id, l_transaction_id, l_status, l_applied, l_res_firm_flag,
      l_sup_firm_flag, l_start_date, l_end_date, l_schedule_flag, l_res_constraint,
      l_qty, l_batch_number, l_resource_units, l_group_sequence_id, l_group_sequence_number,
      l_cepst, l_cepct, l_ulpst, l_ulpct, l_uepst, l_uepct, l_eacd, l_bar_text, l_inventory_item_id,
      l_order_number, l_op_seq, l_res_seq, l_res_desc, l_item_name, l_assy_item_desc, l_schedule_qty,
      l_from_setup_code, l_to_setup_code, l_std_op_code, l_changeover_time, l_changeover_penalty, l_overload_flag;
    close res_inst_act_cur;

    put_line('populateResActGantt: res inst act rows: '||l_sr_instance_id.count);

    populateResActIntoDtlGantt(p_query_id, RES_REQ_ROW_TYPE, SUMMARY_DATA,
      l_row_index, l_sr_instance_id, l_organization_id, l_supply_id,
      l_transaction_id, l_status, l_applied, l_res_firm_flag, l_sup_firm_flag,
      l_start_date, l_end_date, l_schedule_flag, l_res_constraint, l_qty, l_batch_number,
      l_resource_units, l_group_sequence_id, l_group_sequence_number,
      l_cepst, l_cepct, l_ulpst, l_ulpct, l_uepst, l_uepct, l_eacd, l_inventory_item_id, l_bar_text,
      l_order_number, l_op_seq, l_res_seq, l_res_desc, l_item_name, l_assy_item_desc, l_schedule_qty,
      l_from_setup_code, l_to_setup_code, l_std_op_code, l_changeover_time, l_changeover_penalty, l_overload_flag);

  end if; -- }

  if ( p_batched_res_act = RES_ACT_BATCHED_ROW_TYPE) then -- {
    if ( l_res_batch_rows = sys_yes ) then -- {

      open res_act_batch_cur;
      fetch res_act_batch_cur bulk collect into l_row_index, l_sr_instance_id, l_organization_id,
        l_start_date, l_end_date, l_schedule_flag, l_qty, l_batch_number, l_bar_text;
      close res_act_batch_cur;

      put_line('populateResActGantt: batch res act rows: '||l_sr_instance_id.count);

      populateBtchResIntoDtlGantt(p_query_id, RES_ACT_BATCHED_ROW_TYPE, SUMMARY_DATA,
       l_row_index, l_sr_instance_id, l_organization_id,
       l_start_date, l_end_date, l_schedule_flag, l_batch_number, l_qty, l_bar_text, RES_NODE);

    end if; -- }

    if ( l_res_inst_batch_rows = sys_yes ) then -- {

      open res_inst_act_batch_cur;
      fetch res_inst_act_batch_cur bulk collect into l_row_index, l_sr_instance_id, l_organization_id,
        l_start_date, l_end_date, l_schedule_flag, l_qty, l_batch_number, l_bar_text;
      close res_inst_act_batch_cur;

      put_line('populateResActGantt: batch res inst act rows: '||l_sr_instance_id.count);

      populateBtchResIntoDtlGantt(p_query_id, RES_ACT_BATCHED_ROW_TYPE, SUMMARY_DATA,
       l_row_index, l_sr_instance_id, l_organization_id,
       l_start_date, l_end_date, l_schedule_flag, l_batch_number, l_qty, l_bar_text, RES_INST_NODE);

    end if; -- }
 end if; -- }

  for active_row in active_res_rows_cur(p_query_id) loop -- {
    if ( p_start_index = mbp_null_value) then
      p_start_index := active_row.row_index;
    end if;

    select nvl(mgdq.sr_instance_id, mbp_null_value),
      nvl(mgdq.organization_id,  mbp_null_value),
      nvl(mgdq.supply_id, mbp_null_value),
      nvl(mgdq.transaction_id, mbp_null_value),
      nvl(mgdq.status, mbp_null_value),
      nvl(mgdq.applied, mbp_null_value),
      nvl(mgdq.res_firm_flag, mbp_null_value),
      nvl(mgdq.sup_firm_flag, mbp_null_value),
      mgdq.start_date,
      mgdq.end_date,
      nvl(mgdq.schedule_flag, mbp_null_value),
      nvl(mgdq.late_flag, mbp_null_value),
      nvl(mgdq.supply_qty, mbp_null_value),
      nvl(mgdq.batch_number, mbp_null_value),
      nvl(mgdq.resource_units, mbp_null_value),
      nvl(mgdq.group_sequence_id, mbp_null_value),
      nvl(mgdq.group_sequence_number, mbp_null_value),
      nvl(mgdq.bar_label, null_space),
      msc_gantt_utils.getDisplayType(p_display_type, mgdq.end_date, mgdq.ulpst,
	mgdq.res_firm_flag, mgdq.late_flag, g_gantt_ra_toler_days_early,
	g_gantt_ra_toler_days_late) display_type,
      mgdq.cepst,
      mgdq.cepct,
      mgdq.ulpst,
      mgdq.ulpct,
      mgdq.uepst,
      mgdq.uepct,
      mgdq.eact,
      mgq.department_id,
      mgq.resource_id,
      mgdq.inventory_item_id,
      mgdq.order_number,
      mgdq.op_seq_num,
      mgdq.resource_seq_num,
      mgdq.resource_description,
      mgdq.item_name,
      mgdq.assembly_item_desc,
      mgdq.schedule_qty,
      mgdq.from_setup_code,
      mgdq.to_setup_code,
      mgdq.std_op_code,
      mgdq.changeover_time,
      mgdq.changeover_penalty,
      mgdq.min_capacity,
      mgdq.max_capacity,
      mgdq.capacity_used,
      mgdq.supp_avail_qty
    bulk collect into l_sr_instance_id, l_organization_id,
      l_supply_id, l_transaction_id, l_status, l_applied, l_res_firm_flag,
      l_sup_firm_flag, l_start_date, l_end_date, l_schedule_flag, l_res_constraint,
      l_qty, l_batch_number, l_resource_units,
      l_group_sequence_id, l_group_sequence_number, l_bar_text, l_display_type,
      l_cepst, l_cepct, l_ulpst, l_ulpct, l_uepst, l_uepct, l_eacd,
      l_dept_id, l_res_id, l_inventory_item_id, l_order_number,
      l_op_seq, l_res_seq, l_res_desc, l_item_name, l_assy_item_desc, l_schedule_qty,
      l_from_setup_code, l_to_setup_code, l_std_op_code, l_changeover_time,
      l_changeover_penalty, l_min_capacity, l_max_capacity, l_capacity_used,
      l_overload_flag
    from msc_gantt_dtl_query mgdq,
      msc_gantt_query mgq
    where mgq.query_id = p_query_id
      and mgq.row_index = active_row.row_index
      and mgq.query_id = mgdq.query_id
      and mgq.row_index = mgdq.row_index
      and mgdq.row_type in (RES_REQ_ROW_TYPE, RES_ACT_BATCHED_ROW_TYPE)
      and mgdq.parent_id = SUMMARY_DATA
    order by mgdq.start_date;

   put_line('sending res act stream '||active_row.row_index);

   sendResActStream(active_row.row_index, p_start_index, l_sr_instance_id,
     l_organization_id, l_supply_id, l_transaction_id, l_status, l_applied,
     l_res_firm_flag, l_sup_firm_flag, l_start_date, l_end_date, l_schedule_flag,
     l_res_constraint, l_qty, l_batch_number, l_resource_units, l_group_sequence_id,
     l_group_sequence_number, l_bar_text, l_display_type, l_cepst, l_cepct, l_ulpst,
     l_ulpct, l_uepst, l_uepct, l_eacd, l_dept_id, l_res_id, l_inventory_item_id,
     l_order_number, l_op_seq, l_res_seq, l_res_desc, l_item_name, l_assy_item_desc, l_schedule_qty,
     l_from_setup_code, l_to_setup_code, l_std_op_code, l_changeover_time, l_changeover_penalty,
     l_min_capacity, l_max_capacity, l_capacity_used, l_overload_flag, p_require_data);
  end loop;  -- }

end populateResActGantt;

function getDisplayType(p_display_type number, p_end_date date,
  p_ulpsd date, p_res_firm_flag number, p_overload_flag number,
  p_days_early number, p_days_late number) return number is

  retVal number := sys_no;

begin
  if  ( p_display_type = DISPLAY_LATE ) then -- {
   if ( p_ulpsd + p_days_late > p_end_date ) then
     retVal := sys_yes;
   end if;
  elsif  ( p_display_type = DISPLAY_EARLY ) then
   if ( p_ulpsd + p_days_early < p_end_date ) then
     retVal := sys_yes;
   end if;
  elsif  ( p_display_type = DISPLAY_FIRM ) then
    if ( nvl(p_res_firm_flag,0) > 0 ) then
      retVal := sys_yes;
    end if;
  elsif  ( p_display_type = DISPLAY_OVERLOAD ) then
    retVal := p_overload_flag;
  elsif  ( p_display_type = DISPLAY_NONE ) then
    retVal := sys_no;
  end if; -- }

  return retVal;
end getDisplayType;

procedure populateSupplierGantt(p_query_id number, p_plan_id number,
  p_start_date date, p_end_date date) is

  v_row_index number_arr := number_arr(0);
  v_start_date date_arr := date_arr(sysdate);
  v_qty number_arr:= number_arr(0);
  v_overload_qty number_arr:= number_arr(0);
  v_consumed_qty number_arr:= number_arr(0);

  v_bkt_start date_arr;
  v_bkt_end date_arr;

  l_mfg_cal_query_id number;

  cursor c_mgq_rows is
  select row_index, inventory_item_id, supplier_id, supplier_site_id
  from msc_gantt_query
  where query_id = p_query_id;

  cursor c_mis_inst_org (l_plan number, l_item number, l_supp number, l_supp_site number) is
  select sr_instance_id, organization_id
  from msc_item_suppliers
  where plan_id = l_plan
    and inventory_item_id = l_item
    and supplier_id = l_supp
    and supplier_site_id = l_supp_site;

  l_row_index number;
  l_inventory_item_id number;
  l_supplier_id number;
  l_supplier_site_id number;
  l_org_id  number;
  l_inst_id number;

begin

for cur_mgq_rows  in c_mgq_rows
loop -- {

  l_row_index := cur_mgq_rows.row_index;
  l_inventory_item_id := cur_mgq_rows.inventory_item_id;
  l_supplier_id := cur_mgq_rows.supplier_id;
  l_supplier_site_id := cur_mgq_rows.supplier_site_id;

  open c_mis_inst_org (g_plan_id, l_inventory_item_id, l_supplier_id, l_supplier_site_id);
  fetch c_mis_inst_org into l_inst_id, l_org_id;
  close c_mis_inst_org;

   -- 1. available capacity for items with delivery calendar
   select mgq.row_index, mca.calendar_date, msc.capacity
     bulk collect into v_row_index, v_start_date, v_qty
   from msc_calendar_dates mca,
         msc_plans mp,
         msc_supplier_capacities msc,
	 msc_item_suppliers mis,
	 msc_gantt_query mgq
   where mgq.query_id = p_query_id
     and mgq.row_index = l_row_index
     and mgq.row_flag = SYS_YES
     and mgq.is_fetched = SYS_NO
     and msc.plan_id = mgq.plan_id
     and msc.sr_instance_id = l_inst_id
     and msc.organization_id = l_org_id
     and msc.inventory_item_id = mgq.inventory_item_id
     and msc.supplier_id = mgq.supplier_id
     and msc.supplier_site_id = mgq.supplier_site_id
     and msc.capacity >= 0 --4476899 bugfix
     and mp.plan_id = msc.plan_id
     and msc.plan_id = mis.plan_id
     and msc.sr_instance_id = mis.sr_instance_id
     and msc.organization_id = mis.organization_id
     and msc.inventory_item_id = mis.inventory_item_id
     and msc.supplier_id = mis.supplier_id
     and msc.supplier_site_id = mis.supplier_site_id
     and mca.calendar_date between p_start_date and p_end_date
     and mca.calendar_date between trunc(msc.from_date) and trunc(nvl(msc.to_date,p_end_date))
     and mca.calendar_date >= nvl(trunc(mis.supplier_lead_time_date+1),trunc(mp.plan_start_date+2))
     and mca.calendar_code = mis.delivery_calendar_code
     and mis.delivery_calendar_code is not null
     and mca.sr_instance_id = g_plan_cal_inst_id
     and mca.exception_set_id =  g_plan_cal_excp_id
     and mca.seq_num is not null;

    put_line('SUPP_AVAIL_ROW_TYPE rows items with delivery.cal: '|| v_row_index.count);

    populateSuppDtlTabIntoGantt(p_query_id, SUPP_AVAIL_ROW_TYPE,
      v_row_index, v_start_date, v_qty, v_consumed_qty, SUMMARY_DATA);

    l_mfg_cal_query_id := getMFQSequence(l_mfg_cal_query_id);
    msc_gantt_utils.getBucketDates(p_start_date, p_end_date, v_bkt_start, v_bkt_end, l_mfg_cal_query_id);

   -- 2. available capacity for items with NO delivery calendar
   select mgq.row_index, mfq.date1, msc.capacity
     bulk collect into v_row_index, v_start_date, v_qty
   from msc_form_query mfq,
         msc_plans mp,
         msc_supplier_capacities msc,
	 msc_item_suppliers mis,
	 msc_gantt_query mgq
   where mgq.query_id = p_query_id
     and mgq.row_index = l_row_index
     and mgq.row_flag = SYS_YES
     and mgq.is_fetched = SYS_NO
     and msc.plan_id = mgq.plan_id
     and msc.sr_instance_id = l_inst_id
     and msc.organization_id = l_org_id
     and msc.inventory_item_id = mgq.inventory_item_id
     and msc.supplier_id = mgq.supplier_id
     and msc.supplier_site_id = mgq.supplier_site_id
     and msc.capacity >= 0  --4476899 bugfix
     and mp.plan_id = msc.plan_id
     and msc.plan_id = mis.plan_id
     and msc.sr_instance_id = mis.sr_instance_id
     and msc.organization_id = mis.organization_id
     and msc.inventory_item_id = mis.inventory_item_id
     and msc.supplier_id = mis.supplier_id
     and msc.supplier_site_id = mis.supplier_site_id
     and mis.delivery_calendar_code is null
     and mfq.query_id = l_mfg_cal_query_id
     and mfq.date1 between p_start_date and p_end_date
     and mfq.date1 between trunc(msc.from_date) and trunc(nvl(msc.to_date,p_end_date))
     and mfq.date1 >= nvl(trunc(mis.supplier_lead_time_date+1),trunc(mp.plan_start_date+2));

    put_line('SUPP_AVAIL_ROW_TYPE rows items with NO delivery.cal: '|| v_row_index.count);

    populateSuppDtlTabIntoGantt(p_query_id, SUPP_AVAIL_ROW_TYPE,
      v_row_index, v_start_date, v_qty, v_consumed_qty, SUMMARY_DATA);

  end loop; -- }

   -- 3. req/consumed capacity for all the items except MODELs
   select mgq.row_index,
     msr.consumption_date,
     sum(msr.overloaded_capacity) overload_qty,
     sum(msr.consumed_quantity) consumed_qty
     bulk collect into v_row_index, v_start_date, v_overload_qty, v_consumed_qty
   from msc_gantt_query mgq,
     msc_supplier_requirements msr
   where mgq.query_id = p_query_id
     and mgq.row_flag = SYS_YES
     and mgq.is_fetched = SYS_NO
     and mgq.dependency_type <> 1 -- bom_item_type, all the items except MODELs
     and msr.plan_id = mgq.plan_id
     --and msr.sr_instance_id = mgq.sr_instance_id
     --and msr.organization_id = mgq.organization_id
     and msr.inventory_item_id = mgq.inventory_item_id
     and msr.supplier_id = mgq.supplier_id
     and msr.supplier_site_id = mgq.supplier_site_id
   group by mgq.row_index, msr.consumption_date;

   put_line('SUPP_ALL_ROW_TYPE rows for all the items except MODELs : '|| v_row_index.count);
   populateSuppDtlTabIntoGantt(p_query_id, SUPP_ALL_ROW_TYPE,
      v_row_index, v_start_date, v_overload_qty, v_consumed_qty, SUMMARY_DATA);

   -- 3. req/consumed capacity for MODEL items only
   select mgq.row_index,
     msr.consumption_date,
     sum(msr.overloaded_capacity) overload_qty,
     sum(msr.consumed_quantity) consumed_qty
     bulk collect into v_row_index, v_start_date, v_overload_qty, v_consumed_qty
   from msc_gantt_query mgq,
     msc_supplier_requirements msr,
     msc_system_items msi
   where mgq.query_id = p_query_id
     and mgq.row_flag = SYS_YES
     and mgq.is_fetched = SYS_NO
     and mgq.dependency_type = 1 -- bom_item_type, MODELs
     and msi.plan_id = mgq.plan_id
     --and msi.sr_instance_id = mgq.sr_instance_id
     --and msi.organization_id = mgq.organization_id
     and ( msi.base_item_id = mgq.inventory_item_id or msi.inventory_item_id = mgq.inventory_item_id)  --5220804 bugfix
     and msr.plan_id = mgq.plan_id
     and msr.sr_instance_id = msi.sr_instance_id
     and msr.organization_id = msi.organization_id
     and msr.inventory_item_id = msi.inventory_item_id
     and msr.supplier_id = mgq.supplier_id
     and msr.supplier_site_id = mgq.supplier_site_id
   group by mgq.row_index, msr.consumption_date;

   put_line('SUPP_ALL_ROW_TYPE rows for MODEL items only : '|| v_row_index.count);
   populateSuppDtlTabIntoGantt(p_query_id, SUPP_ALL_ROW_TYPE,
      v_row_index, v_start_date, v_overload_qty, v_consumed_qty, SUMMARY_DATA);

end populateSupplierGantt;

procedure prepareSupplierGantt(p_query_id in number,
  p_plan_id number, p_start_date date, p_end_date date) is

  v_bkt_start date_arr := date_arr(sysdate);
  v_bkt_end date_arr := date_arr(sysdate);

  v_avail_start date_arr := date_arr(sysdate);
  v_avail_qty number_arr:= number_arr(0);

  v_consume_start date_arr := date_arr(sysdate);
  v_overload_qty number_arr:= number_arr(0);
  v_consume_qty number_arr:= number_arr(0);

  l_avail_qty number;
  l_overload_qty number;
  l_consume_qty number;

  p_start_index number;
  l_bkt_query_id number := -1;

  cursor c_supp_infinite_date(p_query number, p_row_index number, p_plan number,
    p_plan_end date) is
  select max(from_date) max_bkt_start_date,
    max(nvl(to_date,p_plan_end)) max_bkt_end_date
  from  msc_gantt_query mgq,
    msc_supplier_capacities msc1
  where mgq.query_id = p_query
    and mgq.row_index = p_row_index
    and msc1.plan_id = p_plan
    and msc1.supplier_id = mgq.supplier_id
    and msc1.supplier_site_id = mgq.supplier_site_id
    --and msc1.organization_id = mgq.organization_id
    --and msc1.sr_instance_id = mgq.sr_instance_id
    and msc1.inventory_item_id = mgq.inventory_item_id;

  l_supp_bkt_start_date date;
  l_supp_bkt_end_date date;

begin
  msc_gantt_utils.put_line('prepareSupplierGantt in ');
  p_start_index := mbp_null_value;

  msc_gantt_utils.getBucketDates(p_start_date, p_end_date, v_bkt_start, v_bkt_end, l_bkt_query_id);

  msc_gantt_utils.put_line('claendar rows ' || v_bkt_start.count);

  for active_row in active_res_rows_cur(p_query_id) loop -- {
    if ( p_start_index = mbp_null_value) then
      p_start_index := active_row.row_index;
    end if;

    --4476899 bugfix, send infinite capacity as -1 to client
    open c_supp_infinite_date(p_query_id, active_row.row_index, p_plan_id, p_end_date);
    fetch c_supp_infinite_date into l_supp_bkt_start_date, l_supp_bkt_end_date;
    close c_supp_infinite_date;

    select trunc(start_date), nvl(resource_units,0)
      bulk collect into v_avail_start, v_avail_qty
    from msc_gantt_dtl_query
    where query_id = p_query_id
    and row_index = active_row.row_index
    and row_type = SUPP_AVAIL_ROW_TYPE
    and parent_id = SUMMARY_DATA;

   put_line(' row index and SUPP_AVAIL_ROW_TYPE count '||active_row.row_index||' '||v_avail_start.count);

    select trunc(start_date), nvl(resource_units,0), nvl(resource_hours,0)
      bulk collect into v_consume_start, v_overload_qty, v_consume_qty
    from msc_gantt_dtl_query
    where query_id = p_query_id
    and row_index = active_row.row_index
    and row_type = SUPP_ALL_ROW_TYPE
    and parent_id = SUMMARY_DATA
    order by start_date;

   put_line(' row index and SUPP_ALL_ROW_TYPE count '||active_row.row_index||' '|| v_consume_start.count);

    -- for daily, weekly, period buckets
    for a in 1 .. v_bkt_start.count
    loop -- {
      l_avail_qty := 0;
      l_overload_qty := 0;
      l_consume_qty := 0;

      --4476899 bugfix, send infinite capacity as -1 to client
      if (l_supp_bkt_start_date is null and l_supp_bkt_end_date is null) then  --capacity not defined, every thing is infinite
        l_avail_qty := -1;
      elsif (v_bkt_start(a) > l_supp_bkt_end_date) then  --every thing is infinite from this date onwards
        l_avail_qty := -1;
      else
      for b in 1 .. v_avail_start.count loop  -- {
        if ( v_avail_start(b) = v_bkt_start(a) ) then
          l_avail_qty := l_avail_qty  + v_avail_qty(b);
	end if;
      end loop; -- }
      end if;


      for b in 1 .. v_consume_start.count loop  -- {
        if ( v_consume_start(b) = v_bkt_start(a) ) then
          l_overload_qty := l_overload_qty  + v_overload_qty(b);
	end if;
      end loop; -- }

      for b in 1 .. v_consume_start.count loop  -- {
        if ( v_consume_start(b) = v_bkt_start(a) ) then
          l_consume_qty := l_consume_qty  + v_consume_qty(b);
	end if;
      end loop; -- }

      --if ( nvl(l_avail_qty,0) <> 0 or nvl(l_overload_qty,0) <> 0 or nvl(l_consume_qty,0) <> 0 ) then
        populateSuppDtlIntoGantt(p_query_id, SUPP_ALL_ROW_TYPE,
	  active_row.row_index, v_bkt_start(a), l_avail_qty, l_overload_qty,
	  l_consume_qty, DETAIL_DATA);
     --end if;
     -- 4476899 bug fix, pass zero's also

    end loop; -- }
  end loop; -- }
  msc_gantt_utils.put_line('prepareSupplierGantt out ');

end prepareSupplierGantt;

procedure sendSupplierGantt(p_query_id number,
  p_supp_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl) is

  v_start_date date_arr := date_arr(sysdate);
  v_avail_qty number_arr:= number_arr(0);
  v_overload_qty number_arr:= number_arr(0);
  v_consume_qty number_arr:= number_arr(0);

  p_start_index number;
begin
  p_start_index := mbp_null_value;

  for active_row in active_res_rows_cur(p_query_id) loop -- {
    if ( p_start_index = mbp_null_value) then
      p_start_index := active_row.row_index;
    end if;

    select trunc(start_date),
      round(supp_avail_qty, ROUND_FACTOR),
      round(supp_overload_qty, ROUND_FACTOR),
      round(supp_consume_qty, ROUND_FACTOR)
    bulk collect into v_start_date, v_avail_qty, v_overload_qty, v_consume_qty
    from msc_gantt_dtl_query
    where query_id = p_query_id
      and row_index = active_row.row_index
      and row_type = SUPP_ALL_ROW_TYPE
      and parent_id = DETAIL_DATA
    order by start_date;

    put_line('sendSupplierGantt rows '||v_start_date.count||' '||v_avail_qty.count
      ||' '|| v_overload_qty.count ||' '|| v_consume_qty.count
      ||' '|| active_row.row_index);

    sendResReqAvailSuppStream(SUPP_ALL_ROW_TYPE, active_row.row_index, p_start_index,
      v_start_date, null, null, null, null, p_supp_data,
      v_avail_qty, v_overload_qty, v_consume_qty);
  end loop; -- }

end sendSupplierGantt;

procedure sendResourceGantt(p_query_id number, p_view_type number,
  p_isBucketed number, p_require_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_avail_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_onlyAvailData boolean, p_display_type number) is

  v_start date_arr:= date_arr(sysdate);
  v_end date_arr:= date_arr(sysdate);
  v_resource_hours number_arr:= number_arr(0);
  v_resource_units number_arr:= number_arr(0);
  v_schedule_flag number_arr:= number_arr(0);
  v_display_flag number_arr:= number_arr(0);

  p_start_index number;
begin
  put_line('sendResourceGantt in');

  p_start_index := mbp_null_value;

  for active_row in active_res_rows_cur(p_query_id) loop -- {
    if ( p_start_index = mbp_null_value) then
      p_start_index := active_row.row_index;
    end if;

   if ( not(p_onlyAvailData) ) then -- {

    if ( p_view_type = RES_HOURS_VIEW ) then
--    and p_display_type <> DISPLAY_NONE ) then
      select start_date, end_date,
        round(resource_hours, ROUND_FACTOR) resource_hours,
        to_number(null) resource_units,
        schedule_flag,
        display_flag
      bulk collect into v_start, v_end, v_resource_hours, v_resource_units,
        v_schedule_flag, v_display_flag
      from msc_gantt_dtl_query
      where query_id = p_query_id
        and row_index = active_row.row_index
        and row_type = RES_REQ_ROW_TYPE
        and ( ( parent_id = SUMMARY_DATA and p_isBucketed = SYS_NO )
           or (parent_id = DETAIL_DATA and p_isBucketed = SYS_YES ) )
        --and display_flag = sys_yes
      order by start_date, end_date;

      sendResReqAvailSuppStream(RES_REQ_DISPLAY_ROW_TYPE, active_row.row_index,
        p_start_index, v_start, v_end, v_resource_hours, v_resource_units,
	v_schedule_flag, p_require_data, v_display_flag);
    else
      select start_date, end_date,
        round(resource_hours, ROUND_FACTOR) resource_hours,
        round(resource_units, ROUND_FACTOR) resource_units,
        schedule_flag,
        display_flag
      bulk collect into v_start, v_end, v_resource_hours, v_resource_units,
        v_schedule_flag, v_display_flag
      from msc_gantt_dtl_query
      where query_id = p_query_id
        and row_index = active_row.row_index
        and row_type = RES_REQ_ROW_TYPE
        and ( ( parent_id = SUMMARY_DATA and p_isBucketed = SYS_NO )
           or (parent_id = DETAIL_DATA and p_isBucketed = SYS_YES ) )
      order by start_date, end_date;

       sendResReqAvailSuppStream(RES_REQ_ROW_TYPE, active_row.row_index,
         p_start_index, v_start, v_end, v_resource_hours, v_resource_units,
	 v_schedule_flag, p_require_data, v_display_flag);
     end if;
   end if; -- }

   select start_date, end_date,
     round(resource_hours, ROUND_FACTOR) resource_hours,
     round(resource_units, ROUND_FACTOR) resource_units,
     schedule_flag
   bulk collect into v_start, v_end, v_resource_hours, v_resource_units, v_schedule_flag
   from msc_gantt_dtl_query
   where query_id = p_query_id
   and row_index = active_row.row_index
   and row_type = RES_AVAIL_ROW_TYPE
   and ( ( parent_id = SUMMARY_DATA and p_isBucketed = SYS_NO )
         or (parent_id = DETAIL_DATA and p_isBucketed = SYS_YES ) )
   order by start_date, end_date;

   sendResReqAvailSuppStream(RES_AVAIL_ROW_TYPE, active_row.row_index, p_start_index,
     v_start, v_end, v_resource_hours, v_resource_units, v_schedule_flag, p_avail_data);
end loop; -- }
put_line('sendResourceGantt out');

end sendResourceGantt;

procedure calculateResHours(p_query_id number, p_row_index number, p_row_type number,
  p_bkt_start date, p_bkt_end date, p_line_rate number,
  p_start date_arr, p_end date_arr, p_hours number_arr,
  p_display_type number_arr) is

  new_start_yes date;
  new_end_yes date;
  v_qty_yes number;
  bkt_qty_yes number;

  new_start_no date;
  new_end_no date;
  v_qty_no number;
  bkt_qty_no number;

begin
      bkt_qty_yes := 0;
      v_qty_yes := 0;
      bkt_qty_no := 0;
      v_qty_no := 0;

      for b in 1 .. p_start.count loop -- {
        if (p_start(b) > p_bkt_end or p_end(b) < p_bkt_start ) then
          v_qty_yes := 0;
          v_qty_no := 0;
        elsif (p_start(b) >= p_bkt_start and p_end(b) <= p_bkt_end ) then
          if ( p_display_type(b) = sys_yes ) then
            v_qty_yes := p_hours(b)* p_line_rate;
            bkt_qty_yes := bkt_qty_yes + v_qty_yes;
	  else
            v_qty_no := p_hours(b)* p_line_rate;
            bkt_qty_no := bkt_qty_no + v_qty_no;
          end if;
        else
          if ( p_display_type(b) = sys_yes ) then
            new_start_yes := greatest(p_start(b), p_bkt_start);
            new_end_yes := least(p_end(b), p_bkt_end);
            v_qty_yes := p_hours(b)* p_line_rate;
	    v_qty_yes := p_hours(b) / ((p_end(b)- p_start(b))*24);
            bkt_qty_yes := bkt_qty_yes + (((new_end_yes - new_start_yes) * v_qty_yes)*24);
	  else
            new_start_no := greatest(p_start(b), p_bkt_start);
            new_end_no := least(p_end(b), p_bkt_end);
            v_qty_no := p_hours(b)* p_line_rate;
	    v_qty_no := p_hours(b) / ((p_end(b)- p_start(b))*24);
            bkt_qty_no := bkt_qty_no + (((new_end_no - new_start_no) * v_qty_no)*24);
	  end if;
        end if;
      end loop; -- }

      if nvl(bkt_qty_yes,0) <> 0 then
        populateResDtlIntoGantt(p_query_id, RES_REQ_ROW_TYPE, p_row_index,
	  p_bkt_start, p_bkt_end, null, bkt_qty_yes, p_row_type,
	  DETAIL_DATA, sys_yes);
      end if;

      if nvl(bkt_qty_no,0) <> 0 then
        populateResDtlIntoGantt(p_query_id, RES_REQ_ROW_TYPE, p_row_index,
	  p_bkt_start, p_bkt_end, null, bkt_qty_no, p_row_type,
	  DETAIL_DATA, sys_no);
      end if;

 end calculateResHours;

procedure getBucketDates(p_start_date date, p_end_date date,
  v_bkt_start in out nocopy msc_gantt_utils.date_arr,
  v_bkt_end in out nocopy msc_gantt_utils.date_arr,
  p_query_id in out nocopy number) is
  p_temp_start date;
  i number;
begin
  if (p_query_id = -1) then
    v_bkt_start := date_arr(sysdate);
    v_bkt_end := date_arr(sysdate);
    v_bkt_start.delete;
    v_bkt_end.delete;

    p_temp_start := trunc(p_start_date);
    i := 1;
    loop
      if (p_temp_start>p_end_date) then
        exit;
      end if;
      v_bkt_start.extend;
      v_bkt_end.extend;
      v_bkt_start(i) := p_temp_start;
      v_bkt_end(i) := p_temp_start+1;
      i := i + 1;
      p_temp_start := p_temp_start+1;
    end loop;
    return;
  else
    p_temp_start := trunc(p_start_date);
    i := 1;
    loop
      if (p_temp_start>p_end_date) then
        exit;
      end if;
      i := i + 1;

      insert into msc_form_query
        ( query_id, last_update_date, last_updated_by, creation_date, created_by, last_update_login,
        date1, date2)
      values
        ( p_query_id, sysdate, -1, sysdate, -1, -1, p_temp_start, p_temp_start+1);

      p_temp_start := p_temp_start+1;
    end loop;
    return;
  end if;

end getBucketDates;

procedure prepareResHoursGantt(p_query_id in number, p_plan_id number,
  p_start_date date, p_end_date date, p_display_type number default null) is

  v_setup_start date_arr;
  v_setup_end date_arr;
  v_setup_hours number_arr;
  v_setup_display_type number_arr;

  v_req_start date_arr;
  v_req_end date_arr;
  v_req_hours number_arr;
  v_req_display_type number_arr;

  v_avail_start date_arr;
  v_avail_end date_arr;
  v_avail_hours number_arr;

  v_bkt_start date_arr;
  v_bkt_end date_arr;

  cursor line_rate (l_query_id number, l_row_index number) is
  select mdr.max_rate
  from msc_department_resources mdr,
    msc_gantt_query mgq
  where mgq.query_id = l_query_id
    and mgq.row_index = l_row_index
    and mgq.organization_id = mdr.organization_id
    and mgq.sr_instance_id = mdr.sr_instance_id
    and mgq.department_id = mdr.department_id
    and mgq.resource_id = mdr.resource_id
    and mdr.plan_id = -1;

  cursor finite_avail (l_query_id number, l_row_index number) is
  select 1
  from msc_net_resource_avail mnra,
    msc_gantt_query mgq
  where mgq.query_id = l_query_id
    and mgq.row_index = l_row_index
    and mgq.organization_id = mnra.organization_id
    and mgq.sr_instance_id = mnra.sr_instance_id
    and mgq.department_id = mnra.department_id
    and mgq.resource_id = mnra.resource_id
    and mgq.plan_id = mnra.plan_id
    and nvl(mnra.parent_id, 0) <> -1;

  v_finite_avail number;
  v_line_rate number;
  max_cap number;
  eff_rate number;

  v_qty_yes number;
  bkt_qty_yes number;

  p_start_index number;
  l_bkt_query_id number := -1;
begin

  msc_gantt_utils.put_line('prepareResHoursGantt in ');
  p_start_index := mbp_null_value;

  msc_gantt_utils.getBucketDates(p_start_date, p_end_date, v_bkt_start, v_bkt_end, l_bkt_query_id);

  msc_gantt_utils.put_line('prepareResHoursGantt: claendar rows: ' || v_bkt_start.count);

  for active_row in active_res_rows_cur(p_query_id) loop -- {
    if ( p_start_index = mbp_null_value) then
      p_start_index := active_row.row_index;
    end if;

    select start_date, end_date, resource_hours, nvl(display_flag, sys_no)
      bulk collect into v_setup_start, v_setup_end, v_setup_hours, v_setup_display_type
    from msc_gantt_dtl_query
    where query_id = p_query_id
      and row_index = active_row.row_index
      and row_type = RES_REQ_ROW_TYPE
      and parent_id = SUMMARY_DATA
      and schedule_flag  in (RES_SETUP_ROW_TYPE, RES_SETUP_FIXED_ROW_TYPE)
    order by start_date;  --only setup time

  msc_gantt_utils.put_line('prepareResHoursGantt: res seup rows: '||v_setup_start.count);


    select start_date, end_date, resource_hours, nvl(display_flag, sys_no)
      bulk collect into v_req_start, v_req_end, v_req_hours, v_req_display_type
    from msc_gantt_dtl_query
    where query_id = p_query_id
      and row_index = active_row.row_index
      and row_type = RES_REQ_ROW_TYPE
      and parent_id = SUMMARY_DATA
      and schedule_flag  in (RES_REQ_ROW_TYPE, RES_REQ_SDS_ROW_TYPE)
    order by start_date;  --only run time

  msc_gantt_utils.put_line('prepareResHoursGantt: res req rows: '|| v_req_start.count);

    select start_date, end_date, resource_hours
      bulk collect into v_avail_start, v_avail_end, v_avail_hours
    from msc_gantt_dtl_query
    where query_id = p_query_id
      and row_index = active_row.row_index
      and parent_id = SUMMARY_DATA
      and row_type = RES_AVAIL_ROW_TYPE
    order by start_date;  --avail time

  msc_gantt_utils.put_line('prepareResHoursGantt: res avail rows: '|| v_avail_start.count);

    OPEN line_rate(p_query_id, active_row.row_index);
    FETCH line_rate INTO v_line_rate;
    CLOSE line_rate;
    v_line_rate := nvl(v_line_rate, 1);

    v_finite_avail := null;
    OPEN finite_avail(p_query_id, active_row.row_index);
    FETCH finite_avail INTO v_finite_avail;
    CLOSE finite_avail;


    -- for daily, weekly, period buckets
    for a in 1 .. v_bkt_start.count loop -- {
      -- find all res avail in one bucket
      bkt_qty_yes := 0;
      v_qty_yes := 0;
      for b in 1 .. v_avail_start.count loop  -- {
        v_qty_yes := 0;
        if ( trunc(v_bkt_start(a)) = trunc(v_avail_start(b)) ) then
          v_qty_yes := v_avail_hours(b);
          bkt_qty_yes := bkt_qty_yes  + ( v_qty_yes / (v_bkt_end(a)- v_bkt_start(a)));
        end if;
      end loop; -- }

      if (bkt_qty_yes <> 0) then
        populateResDtlIntoGantt(p_query_id, RES_AVAIL_ROW_TYPE, active_row.row_index,
	  v_bkt_start(a), v_bkt_end(a), null, bkt_qty_yes, null, DETAIL_DATA);
      end if;
      -- find all res avail in one bucket

      -- for run hours
      calculateResHours(p_query_id, active_row.row_index, SCHEDULE_FLAG_YES, v_bkt_start(a), v_bkt_end(a),
        v_line_rate, v_req_start, v_req_end, v_req_hours, v_req_display_type);

      -- for setup hours
      calculateResHours(p_query_id, active_row.row_index, SCHEDULE_FLAG_NO, v_bkt_start(a), v_bkt_end(a),
        v_line_rate, v_setup_start, v_setup_end, v_setup_hours, v_setup_display_type);

    end loop; -- }
  end loop; -- }
  msc_gantt_utils.put_line('prepareResHoursGantt out ');

end prepareResHoursGantt;


procedure parseResString(p_one_record in varchar2,
  p_inst_id out nocopy number, p_org_id out nocopy number,
  p_dept_id out nocopy number, p_res_id out nocopy number,
  p_res_instance_id out nocopy number,
  p_serial_number out nocopy varchar2) is

begin

     p_inst_id := to_number(substr(p_one_record,1,instr(p_one_record,',')-1));
     p_org_id := to_number(substr(p_one_record,instr(p_one_record,',',1,1)+1,
                       instr(p_one_record,',',1,2)-instr(p_one_record,',',1,1)-1));
     p_dept_id := to_number(substr(p_one_record,instr(p_one_record,',',1,2)+1
                      ,instr(p_one_record,',',1,3)-instr(p_one_record,',',1,2)-1));
     p_res_id := to_number(substr(p_one_record,instr(p_one_record,',',1,3)+1
                      ,instr(p_one_record,',',1,4)-instr(p_one_record,',',1,3)-1));
     p_res_instance_id := to_number(substr(p_one_record,instr(p_one_record,',',1,4)+1
                      ,instr(p_one_record,',',1,5)-instr(p_one_record,',',1,4)-1));
     p_serial_number := substr(p_one_record,instr(p_one_record,',',1,5)+1);

end parseResString;

procedure parseSuppString(p_one_record in varchar2,
  p_inst_id out nocopy number, p_org_id out nocopy number,
  p_item_id out nocopy number, p_supplier_id out nocopy number,
  p_supplier_site_id out nocopy number) is

begin

    p_inst_id := to_number(substr(p_one_record,1,instr(p_one_record,',')-1));
    p_org_id := to_number(substr(p_one_record,instr(p_one_record,',',1,1)+1,
                       instr(p_one_record,',',1,2)-instr(p_one_record,',',1,1)-1));
    p_item_id := to_number(substr(p_one_record,instr(p_one_record,',',1,2)+1
                      ,instr(p_one_record,',',1,3)-instr(p_one_record,',',1,2)-1));
    p_supplier_id := to_number(substr(p_one_record,instr(p_one_record,',',1,3)+1
                      ,instr(p_one_record,',',1,4)-instr(p_one_record,',',1,3)-1));
    p_supplier_site_id := to_number(substr(p_one_record,instr(p_one_record,',',1,4)+1));

end parseSuppString;

procedure populateListIntoGantt(p_query_id number,
  p_plan_id number, p_list varchar2,
  p_filter_type number, p_view_type number,
  p_folder_id number default null) is

  i number:=1;
  v_len number;
  one_record varchar2(200);
  l_mfq_query_id number;
  l_row_index number := 0;

begin

  l_mfq_query_id := getMFQSequence(l_mfq_query_id);

  if ( p_filter_type = FILTER_TYPE_LIST ) then

    v_len := length(p_list);
    while v_len > 1 loop
      if ( p_view_type = SUPPLIER_VIEW ) then
        one_record := substr(p_list,instr(p_list,'(',1,i)+1,
          instr(p_list,')',1,i)-instr(p_list,'(',1,i)-1);
	if ( ltrim(rtrim(one_record)) is not null) then
          populateSuppIntoGantt(p_query_id, i, one_record, p_plan_id);
	end if;
      elsif ( p_view_type = ORDER_VIEW ) then
        one_record := substr(p_list,instr(p_list,'(',1,i)+1,
                 instr(p_list,')',1,i)-instr(p_list,'(',1,i)-1);
	if ( ltrim(rtrim(one_record)) is not null) then
          populateOrdersIntoMFQ(null, null, l_mfq_query_id, one_record);
	end if;
      elsif ( p_view_type in (RES_HOURS_VIEW, RES_UNITS_VIEW, RES_ACTIVITIES_VIEW) ) then
        one_record := substr(p_list,instr(p_list,'(',1,i)+1,
          instr(p_list,')',1,i)-instr(p_list,'(',1,i)-1);
	if ( ltrim(rtrim(one_record)) is not null) then
          populateResIntoGantt(p_query_id, l_row_index, one_record, p_plan_id);
	end if;
      end if;
      i := i+1;
      v_len := v_len - length(one_record)-3;
    end loop;

    if ( p_view_type = ORDER_VIEW ) then
      populateOrdersIntoGantt(p_plan_id, p_query_id, l_mfq_query_id);
    end if;

    elsif ( p_filter_type = FILTER_TYPE_MFQ ) then
      if ( p_view_type = SUPPLIER_VIEW ) then
        populateSuppIntoGanttFromMfq(p_query_id, p_list, p_plan_id);
      elsif ( p_view_type = ORDER_VIEW ) then
        populateOrdersIntoGantt(p_plan_id, p_query_id, p_list);
      elsif ( p_view_type in (RES_HOURS_VIEW, RES_UNITS_VIEW, RES_ACTIVITIES_VIEW) ) then
	populateResIntoGanttFromMfq(p_query_id, p_list, p_plan_id);
      end if;
    elsif ( p_filter_type = FILTER_TYPE_FOLDER_ID ) then
	null; --not supported currently..
    elsif ( p_filter_type = FILTER_TYPE_WHERE_STMT ) then
        msc_gantt_utils.findRequest(p_plan_id, p_list,
	p_query_id, p_view_type, FILTER_TYPE_WHERE_STMT, p_folder_id);
    elsif ( p_filter_type = FILTER_TYPE_AMONG ) then
        msc_gantt_utils.findRequest(p_plan_id, p_list,
	p_query_id, p_view_type, FILTER_TYPE_AMONG);
    elsif ( p_filter_type = FILTER_TYPE_QUERY_ID ) then
       populateResIntoGanttFromGantt(p_query_id, p_list, p_plan_id);
    end if;  -- if ( p_filter_type = 1 ) then

end populateListIntoGantt;

procedure findRequest(p_plan_id number,
  p_where varchar2, p_query_id number,
  p_view_type varchar2 default null,
  p_filter_type number default null,
  p_folder_id number default null) is

   TYPE GanttCurTyp IS REF CURSOR;
   theCursor GanttCurTyp;
   sql_statement varchar2(32000);

   l_dept number;
   l_res number;
   l_res_instance_id number;
   l_serial_number varchar2(80);
   l_org number;
   l_instance number;
   l_item_id number;
   l_supp_id number;
   l_supp_site_id number;
   l_supply number;
   l_transaction number;
   exc_where_stat varchar2(32000);
   where_stat varchar2(32000);

   l_one_record varchar2(100) := null;
   orders_where_stat varchar2(32000);
   supp_where_stat varchar2(32000);
   res_where_stat varchar2(32000);

   i number;

  l_mfq_query_id number;
  l_row_index number := 0;

  cursor c_check_res_among (p_folder number, p_res_field varchar2) is
  select count(*)
  from msc_among_values
  where folder_id = p_folder
    and ltrim(rtrim(field_name)) = p_res_field;
  l_res_among_rows number;
  l_among_mfq_query_id number;
begin

  if ( p_where is null ) then
    return;
  end if;

  if ( p_view_type = SUPPLIER_VIEW ) then
    if (p_filter_type = FILTER_TYPE_WHERE_STMT) then
      supp_where_stat := 'select distinct '
        ||' inventory_item_id, supplier_id, supplier_site_id '
        ||' from msc_item_supplier_v '
        ||' where plan_id = :1 '
        ||' and category_set_id = '|| g_category_set_id
        ||' and 1=1 '||p_where;

    elsif (p_filter_type = FILTER_TYPE_AMONG) then
     null; --pabram need to check..
    end if;
    i := 1;
    open theCursor for supp_where_stat using p_plan_id;
    loop
      fetch theCursor into l_item_id, l_supp_id, l_supp_site_id;
      exit when theCursor%notfound;

      populateSuppIntoGantt(p_query_id, i, l_one_record, p_plan_id,
      l_instance, l_org, l_item_id, l_supp_id, l_supp_site_id);
      i := i+1;
    end loop;
    close theCursor;
  elsif ( p_view_type in (DEMAND_VIEW, ORDER_VIEW) ) then
    l_mfq_query_id := getMFQSequence(l_mfq_query_id);

    if (p_filter_type = FILTER_TYPE_WHERE_STMT) then
      orders_where_stat := 'select sr_instance_id, transaction_id '
        ||' from msc_orders_v '
        ||' where plan_id = :1 '
        ||' and category_set_id = '|| g_category_set_id
        ||' and source_table = ''MSC_SUPPLIES'' '
        ||' and 1=1 '||p_where;

    elsif (p_filter_type = FILTER_TYPE_AMONG) then
     null; --pabram need to check..
    end if;

    i := 1;
    open theCursor for orders_where_stat using p_plan_id;
    loop
      fetch theCursor into l_instance, l_transaction;
      exit when theCursor%notfound;
      populateOrdersIntoMFQ(l_instance, l_transaction, l_mfq_query_id, null);
      i := i+1;
    end loop;
    close theCursor;
    populateOrdersIntoGantt(p_plan_id, p_query_id, l_mfq_query_id);

  elsif ( p_view_type in (RES_UNITS_VIEW, RES_HOURS_VIEW, RES_ACTIVITIES_VIEW) ) then
    if (p_filter_type = FILTER_TYPE_WHERE_STMT) then

      open c_check_res_among(p_folder_id, g_folder_res_field_name);
      fetch c_check_res_among into l_res_among_rows;
      close c_check_res_among;

      put_line('res among rows '||l_res_among_rows);

      if ( l_res_among_rows = 0 ) then
        put_line(' regular res where ');
      res_where_stat := 'select sr_instance_id, organization_id, '
        ||' department_id, resource_id, res_instance_id, serial_number '
        ||' from msc_res_and_inst_v '
        ||' where plan_id = :1 '
        --||' and res_instance_id is null '
        ||' and 1=1 '||p_where;
      else
        put_line(' among res where ');
        l_among_mfq_query_id := getMFQSequence(l_among_mfq_query_id);

	put_line(' l_among_mfq_query_id '||l_among_mfq_query_id);
      res_where_stat := 'insert into msc_form_query(query_id, number1, number2, '
        ||' number3, number4, number5, char1, '
	||' last_update_date, last_updated_by, creation_date, created_by) '
	||' select '||l_among_mfq_query_id
        ||' ,sr_instance_id, organization_id, '
        ||' department_id, resource_id, res_instance_id, serial_number, '
        ||' sysdate, -1, sysdate, -1 '
        ||' from msc_res_and_inst_v '
        ||' where plan_id = '||p_plan_id
        --||' and res_instance_id is null '
        ||' and 1=1 '||p_where;

	msc_get_name.execute_dsql(res_where_stat);

      res_where_stat := 'select number1, number2, number3, number4, number5, char1 '
	||' from msc_form_query mfq, '
	||' msc_among_values mav '
	||' where mfq.query_id = :p_mfq_query '
	||' and mav.folder_id = :p_folder '
	||' and ltrim(rtrim(mav.field_name)) = :p_res_field '
	||' and mfq.number4 = mav.hidden_values '
	||' order by mav.order_by_sequence ';

      end if;

    elsif (p_filter_type = FILTER_TYPE_AMONG) then
     null; --pabram need to check..
    end if;
 --put_line('res stmt '||res_where_stat);
    i := 1;
    if ( l_res_among_rows = 0 ) then
      open theCursor for res_where_stat using p_plan_id;
    else
      open theCursor for res_where_stat using l_among_mfq_query_id, p_folder_id,g_folder_res_field_name;
    end if;
    loop
      fetch theCursor into l_instance, l_org, l_dept, l_res, l_res_instance_id, l_serial_number;
      exit when theCursor%notfound;
      populateResIntoGantt(p_query_id, l_row_index, l_one_record, p_plan_id,
        l_instance, l_org, l_dept, l_res, l_res_instance_id, l_serial_number, sys_yes);
      i := i+1;
    end loop;
    close theCursor;
  end if;

  if ( p_view_type in (DEMAND_VIEW, ORDER_VIEW,
	  RES_UNITS_VIEW, RES_HOURS_VIEW, RES_ACTIVITIES_VIEW, SUPPLIER_VIEW) ) then
    return;
  end if;

end findRequest;

procedure constructSupplyRequest(p_query_id number,
  p_from_block varchar2, p_plan_id number,
  p_plan_end_date date, p_where varchar2) is

   TYPE GanttCurTyp IS REF CURSOR;
   the_cursor GanttCurTyp;
   l_instance number;
   l_supply number;
   l_exp_id number;
   sql_stat varchar2(32000);
   l_char varchar2(32000);
BEGIN

   if p_from_block = 'RESOURCE' then
         sql_stat := ' SELECT distinct mrr.sr_instance_id, ' ||
                            ' mrr.supply_id ' ||
                      ' FROM msc_resource_requirements mrr, ' ||
                           ' msc_department_resources mdr ' ||
                     ' WHERE mrr.plan_id = '||p_plan_id ||
                       ' AND mdr.plan_id = mrr.plan_id '||
                       ' AND mdr.organization_id = mrr.organization_id ' ||
                       ' AND mdr.sr_instance_id = mrr.sr_instance_id'||
                       ' AND mdr.department_id = mrr.department_id'||
                       ' AND mdr.resource_id = mrr.resource_id '||
                       ' AND mdr.aggregate_resource_flag =2 '||
          ' and mrr.end_date is not null '||
          ' and nvl(mrr.parent_id,2) =2 '||
                             p_where;
   elsif p_from_block = 'EXCEPTION' then
         sql_stat := 'SELECT mrr.sr_instance_id, '||
                           ' mrr.transaction_id '||
                     ' FROM msc_supplies mrr, '||
                          ' msc_exception_details med '||
                    ' WHERE mrr.plan_id = '||p_plan_id ||
       ' and mrr.plan_id = med.plan_id '||
       ' and (  (mrr.transaction_id = med.number1 and '||
               ' med.exception_type in (6,7,8,9,10,32,34,53,54,58))'||
           ' or (mrr.transaction_id = med.number2 and '||
               ' med.exception_type = 37)) '|| p_where ||
       ' union select mrr.sr_instance_id, '||
                    ' mrr.supply_id transaction_id '||
              ' FROM msc_resource_requirements mrr, '||
                   ' msc_exception_details med '||
           ' where med.exception_type in (21,22,36,45,46) '||
                       ' AND med.plan_id = mrr.plan_id ' ||
                       ' AND med.organization_id = mrr.organization_id ' ||
                       ' AND med.sr_instance_id = mrr.sr_instance_id ' ||
                       ' AND med.department_id = mrr.department_id '||
                       ' AND med.plan_id = '||p_plan_id ||
                       ' AND med.resource_id = mrr.resource_id '||
                       ' and mrr.end_date is not null '||
               p_where;

   else
        sql_stat := 'SELECT mrr.sr_instance_id, '||
                          ' mrr.transaction_id '||
                      'FROM msc_supplies mrr '||
                    ' WHERE mrr.plan_id = '||p_plan_id ||p_where;
   end if;

   open the_cursor for sql_stat;
   loop
     fetch the_cursor into l_instance, l_supply;
     exit when the_cursor%notfound;
     populateOrdersIntoMFQ(l_instance, l_supply, p_query_id);
   end loop;
   close the_cursor;

end constructSupplyRequest;

procedure constructResourceRequest(p_query_id number,
  p_from_block varchar2, p_plan_id number,
  p_plan_end_date date,  p_where varchar2) IS

   TYPE GanttCurTyp IS REF CURSOR;
   the_cursor GanttCurTyp;
   l_dept number;
   l_res number;
   l_org number;
   l_instance number;
   sql_stat varchar2(32000);
   l_char varchar2(2000);
   v_one_record varchar2(100);
   i number := 1;

BEGIN

   if p_from_block = 'EXCEPTION' then
         sql_stat := ' SELECT distinct mrr.sr_instance_id, ' ||
                            ' mrr.organization_id, '||
                            ' mrr.department_id, '||
                            ' mrr.resource_id '||
                      ' FROM msc_resource_requirements mrr, ' ||
                           ' msc_department_resources mdr, ' ||
                           ' msc_exception_details med ' ||
                     ' WHERE mrr.plan_id = :1 '||
                       ' AND mdr.plan_id = mrr.plan_id '||
                       ' AND mdr.organization_id = mrr.organization_id ' ||
                       ' AND mdr.sr_instance_id = mrr.sr_instance_id'||
                       ' AND mdr.department_id = mrr.department_id'||
                       ' AND mdr.resource_id = mrr.resource_id '||
                       ' AND mdr.aggregate_resource_flag =2 '||
                       ' AND med.plan_id = mrr.plan_id ' ||
                       ' AND med.organization_id = mrr.organization_id ' ||
                       ' AND med.sr_instance_id = mrr.sr_instance_id ' ||
                      ' AND decode(med.department_id, -1, mrr.department_id,'||
                       '     med.department_id) = mrr.department_id ' ||
                       ' AND decode(med.resource_id, -1, mrr.resource_id, '||
                       '     med.resource_id) = mrr.resource_id '||
                       ' AND decode(med.inventory_item_id, -1, '||
                                    ' mrr.assembly_item_id, '||
                       '  med.inventory_item_id) = mrr.assembly_item_id '||
       ' and (  (mrr.supply_id = med.number1 and '||
               ' med.exception_type in (6,7,8,9,10,32,34,53,54,58))'||
           ' or (mrr.supply_id = med.number2 and '||
               ' med.exception_type = 37) '||
           ' or (med.exception_type in (21,22,36,45,46)))'||
          ' and nvl(mrr.parent_id,2) =2 ' ||
          ' and mrr.end_date is not null '||
           ' and nvl(mrr.firm_end_date,mrr.end_date) <= :2 '||
                             p_where;
   else
         sql_stat := ' SELECT distinct mrr.sr_instance_id, ' ||
                            ' mrr.organization_id, '||
                            ' mrr.department_id, '||
                            ' mrr.resource_id '||
                      ' FROM msc_resource_requirements mrr, ' ||
                           ' msc_department_resources mdr ' ||
                     ' WHERE mrr.plan_id = :1 '||
                       ' AND mdr.plan_id = mrr.plan_id '||
                       ' AND mdr.organization_id = mrr.organization_id ' ||
                       ' AND mdr.sr_instance_id = mrr.sr_instance_id'||
                       ' AND mdr.department_id = mrr.department_id'||
                       ' AND mdr.resource_id = mrr.resource_id '||
                       ' AND mdr.aggregate_resource_flag =2 '||
          ' and mrr.end_date is not null '||
          ' and nvl(mrr.parent_id,2) =2 ' ||
           ' and nvl(mrr.firm_end_date,mrr.end_date) <= :2 '||
                             p_where;
   end if;

   open the_cursor for sql_stat using p_plan_id, p_plan_end_date;
   loop
     fetch the_cursor into l_instance, l_org, l_dept, l_res;
     exit when the_cursor%notfound;

     v_one_record := '('||l_instance ||','||l_org ||','||l_dept||','||l_res||','||MBP_NULL_VALUE||')';
     populateresintogantt(p_query_id, i, v_one_record, p_plan_id);
     i := i+1;

   end loop;
   close the_cursor;

end constructResourceRequest;

procedure constructRequest(p_query_id number, p_type varchar2, p_plan_id number,
  p_plan_end_date date, p_where varchar2, p_from_block varchar2) is

begin

 if p_from_block in ('LATE_DEMAND','ORDER') then
   null;
 else -- not from late demand and order view
   if p_type = 'RESOURCE' then
     constructResourceRequest(p_query_id, p_from_block,p_plan_id, p_plan_end_date, p_where);
   else
     constructSupplyRequest(p_query_id, p_from_block,p_plan_id, p_plan_end_date, p_where);
   end if;
 end if;

end constructRequest;

function getMFQSequence (p_query_id in number default null) Return number is
  l_query_id number;
begin

  if (p_query_id is not null) then
    delete from msc_form_query where query_id = p_query_id;
    return p_query_id;
  end if;

  select msc_form_query_s.nextval
    into l_query_id
  from dual;
  return l_query_id;

end getMFQSequence;

function getGanttSequence (p_query_id in number default null) return number is
  l_query_id number;
begin
  if (p_query_id is not null) then
    delete from msc_gantt_query where query_id = p_query_id;
    return p_query_id;
  end if;
  select msc_gantt_query_s.nextval
    into l_query_id
  from dual;
  return l_query_id;

end getGanttSequence;

procedure loadAltResourceBatch(p_plan_id number, p_transaction_id number,
  p_instance_id number, p_alt_resource number, p_alt_resource_inst number,
  p_serial_number varchar2, p_alt_num number,
  p_node_type number, p_to_node_type number, p_return_trx_id out nocopy number,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2
  ) is

  cursor c_res_batch_rows (p_plan number, p_inst number, p_trx number) is
  select mrrb.sr_instance_id, mrrb.transaction_id
  from msc_resource_requirements mrr,
    msc_resource_requirements mrrb
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.transaction_id = p_trx
    and mrr.plan_id = mrrb.plan_id
    and mrr.sr_instance_id = mrrb.plan_id
    and mrr.batch_number = mrrb.batch_number;

  l_inst_id number;
  l_trx_id number;

begin

  open c_res_batch_rows(p_plan_id, p_instance_id, p_transaction_id);
  loop
    fetch c_res_batch_rows into l_inst_id, l_trx_id;
    exit when c_res_batch_rows%notfound;

    msc_gantt_utils.loadAltResource(p_plan_id,
      l_inst_id, l_trx_id, p_alt_resource, p_alt_resource_inst, p_serial_number, p_alt_num,
      p_node_type, p_to_node_type, p_return_trx_id, p_return_status, p_out);
  end loop;
  close c_res_batch_rows;

end loadAltResourceBatch;

procedure loadAltResource(p_plan_id number, p_transaction_id number,
  p_instance_id number, p_alt_resource number, p_alt_resource_inst number,
  p_serial_number varchar2, p_alt_num number,
  p_node_type number, p_to_node_type number, p_return_trx_id out nocopy number,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2
  ) is

   l_firm_flag number;
   l_basis_type number;
   l_rout_seq number;
   l_op_seq number;
   l_op_seq_num number;
   l_res_seq number;
   l_supply_id number;
   l_act_group number;
   l_avail_res_seq number;
   l_resource_id number;
   l_assigned_units number;

  cursor c_inst_req_for_same_req (p_plan number, p_res number, p_res_inst number, p_serial varchar2,
    p_supply number, p_op_seq_num number) is
  select count(*)
  from msc_resource_instance_reqs
  where plan_id = p_plan
    and resource_id = p_res
    and res_instance_id = p_res_inst
    and nvl(serial_number, mbp_null_value_char) = nvl(p_serial, mbp_null_value_char)
    and supply_id = p_supply
    and operation_seq_num = p_op_seq_num;
  l_temp_inst_rows number;

  cursor c_res_trx_info(p_plan number, p_inst number, p_trx number) is
  select mrr.resource_id, mrr.routing_sequence_id,
    mrr.operation_sequence_id,
    mrr.operation_seq_num,
    mrr.resource_seq_num,
    mrr.supply_id,
    mrr.basis_type,
    mors.activity_group_id,
    ms.new_order_quantity qty,
    mrr.assigned_units,
    mrr.firm_flag
  from msc_resource_requirements mrr,
    msc_operation_resource_seqs mors,
    msc_supplies ms
  where mrr.plan_id = p_plan
    and mrr.transaction_id = p_trx
    and mrr.sr_instance_id = p_inst
    and mors.plan_id = mrr.plan_id
    and mors.sr_instance_id = mrr.sr_instance_id
    and mors.routing_sequence_id = mrr.routing_sequence_id
    and mors.operation_sequence_id = mrr.operation_sequence_id
    and mors.resource_seq_num = mrr.resource_seq_num
    and ms.plan_id = mrr.plan_id
    and ms.sr_instance_id = mrr.sr_instance_id
    and ms.transaction_id = mrr.supply_id
  union all --5478582 bugfix
  select mrr.resource_id, mrr.routing_sequence_id,
    mrr.operation_sequence_id,
    mrr.operation_seq_num,
    mrr.resource_seq_num,
    mrr.supply_id,
    mrr.basis_type,
    mjor.activity_group_id,
    ms.new_order_quantity qty,
    mrr.assigned_units,
    mrr.firm_flag
  from msc_resource_requirements mrr,
    msc_job_op_resources mjor,
    msc_supplies ms
  where mrr.plan_id = p_plan
    and mrr.transaction_id = p_trx
    and mrr.sr_instance_id = p_inst
    and mrr.routing_sequence_id is null
    and mjor.plan_id = mrr.plan_id
    and mjor.sr_instance_id = mrr.sr_instance_id
    and mjor.transaction_id = mrr.supply_id
    and mjor.resource_id = mrr.resource_id
    and mjor.operation_seq_num = mrr.operation_seq_num
    and mjor.resource_seq_num = mrr.resource_seq_num
    and ms.plan_id = mrr.plan_id
    and ms.sr_instance_id = mrr.sr_instance_id
    and ms.transaction_id = mrr.supply_id;

    cursor c_avail_res_seq_count(p_plan number, p_inst number, p_op_seq number,
      p_rout_seq number, p_act_group number, p_alternate_num number) is
    select count(*)
    from (select distinct mors.resource_seq_num
          from msc_operation_resource_seqs mors,
            msc_operation_resources mor
          where mors.plan_id = p_plan
            and mors.sr_instance_id = p_inst
            and mors.operation_sequence_id = p_op_seq
            and mors.routing_sequence_id = p_rout_seq
            and mors.activity_group_id = p_act_group
            and mor.plan_id = mors.plan_id
            and mor.sr_instance_id = mors.sr_instance_id
            and mor.routing_sequence_id = mors.routing_sequence_id
            and mor.operation_sequence_id = mors.operation_sequence_id
            and mor.resource_seq_num = mors.resource_seq_num
            and mor.alternate_number = p_alternate_num);

   cursor all_res_seq(p_plan number, p_inst number, p_op_seq number,
      p_rout_seq number, p_act_group number) is
   select
     distinct mors.resource_seq_num
   from  msc_operation_resource_seqs mors
   where mors.plan_id = p_plan
     and mors.sr_instance_id = p_inst
     and mors.routing_sequence_id = p_rout_seq
     and mors.operation_sequence_id = p_op_seq
     and mors.activity_group_id = p_act_group;

   cursor same_res_group(p_plan number, p_inst number, p_op_seq number,
      p_rout_seq number, p_act_group number, p_res_seq number,
      p_alternate_num number, p_supply_id number, p_op_seq_num number) is
   select distinct mrr.transaction_id,
     mor.principal_flag,
     mrr.resource_id
   from msc_resource_requirements mrr,
     msc_operation_resources mor
   where mrr.plan_id = p_plan
     and mrr.sr_instance_id = p_inst
     and mrr.routing_sequence_id = p_rout_seq
     and mrr.operation_sequence_id = p_op_seq
     and mrr.resource_seq_num = p_res_seq
     and mor.plan_id = mrr.plan_id
     and mor.sr_instance_id = mrr.sr_instance_id
     and mor.routing_sequence_id = mrr.routing_sequence_id
     and mor.operation_sequence_id = mrr.operation_sequence_id
     and mor.resource_seq_num = mrr.resource_seq_num
     and mor.resource_id = mrr.resource_id
     and mor.alternate_number <> p_alternate_num
     and mrr.parent_id = 2
     and mrr.supply_id = p_supply_id
  union all --5478582 bugfix
   select distinct mrr.transaction_id,
     mjor.principal_flag,
     mrr.resource_id
   from msc_resource_requirements mrr,
    msc_job_op_resources mjor
   where mrr.plan_id = p_plan
     and mrr.sr_instance_id = p_inst
     and mrr.routing_sequence_id is null
     and mrr.operation_seq_num = p_op_seq_num
     and mrr.resource_seq_num = p_res_seq
     and mjor.plan_id = mrr.plan_id
     and mjor.sr_instance_id = mrr.sr_instance_id
     and mjor.transaction_id = mrr.supply_id
     and mjor.operation_seq_num = mrr.operation_seq_num
     and mjor.resource_seq_num = mrr.resource_seq_num
     and mjor.resource_id = mrr.resource_id
     and mjor.alternate_num <> p_alternate_num
     and mrr.parent_id = 2
     and mrr.supply_id = p_supply_id
   order by 2;

  cursor alt_res_group(p_plan number, p_inst number, p_op_seq number,
      p_rout_seq number, p_res_seq number, p_alternate_num number,
      p_supply_id number, p_op_seq_num number) is
  select mor.resource_usage,
    mor.resource_units,
    mor.resource_id,
    mor.alternate_number,
    mor.principal_flag,
    mor.basis_type,
    mor.orig_resource_seq_num
  from msc_operation_resources mor
  where mor.plan_id = p_plan
    and mor.sr_instance_id = p_inst
    and mor.routing_sequence_id = p_rout_seq
    and mor.operation_sequence_id = p_op_seq
    and mor.resource_seq_num = p_res_seq
    and mor.alternate_number = p_alternate_num
  union all --5478582 bugfix
  select mjor.usage_rate_or_amount resource_usage,
    mjor.assigned_units resource_units,
    mjor.resource_id,
    mjor.alternate_num,
    mjor.principal_flag,
    mjor.basis_type,
    mjor.orig_resource_seq_num
  from msc_job_op_resources mjor
  where mjor.plan_id = p_plan
    and mjor.sr_instance_id = p_inst
    and mjor.transaction_id = p_supply_id
    and mjor.operation_seq_num = p_op_seq_num
    and mjor.resource_seq_num = p_res_seq
    and mjor.alternate_num = p_alternate_num
    and p_rout_seq is null
  order by 5;

   -- 4561112 bugfix
  cursor assembly_qty (p_plan number, p_supply number) is
    select nvl(assembly_quantity,1) assembly_quantity
    from msc_boms mb,
      msc_supplies ms,
      msc_process_effectivity mpe,
      msc_resource_requirements mrr
    where ms.plan_id = p_plan
      and ms.transaction_id = p_supply
      and ms.plan_id = mrr.plan_id
      and ms.sr_instance_id = mrr.sr_instance_id
      and ms.transaction_id = mrr.supply_id
      and nvl(mrr.parent_id,2) =2
      and ms.plan_id = mpe.plan_id
      and ms.sr_instance_id = mpe.sr_instance_id
      and ms.process_seq_id = mpe.process_sequence_id
      and mpe.plan_id = mb.plan_id
      and mpe.sr_instance_id = mb.sr_instance_id
      and mpe.bill_sequence_id = mb.bill_sequence_id
      and mrr.assembly_item_id = mb.assembly_item_id;
   v_assembly_quantity number;
   -- 4561112 bugfix

  TYPE ResRecTyp IS RECORD (
         resource_usage number,
         resource_units number,
         resource_id number,
         alternate_number number,
         principal_flag number,
	 basis_type number,
         orig_resource_seq_num number);

  TYPE SimRecTyp IS RECORD (
         transaction_id number,
         principal_flag number,
	 resource_id number);

  TYPE numTabTyp IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE FromTabTyp IS TABLE OF SimRecTyp INDEX BY BINARY_INTEGER;
  TYPE ToTabTyp IS TABLE OF ResRecTyp INDEX BY BINARY_INTEGER;

  l_simu_res   FromTabTyp;
  l_alt_res    ToTabTyp;
  l_all_seq    numTabTyp;
  i BINARY_INTEGER := 0;
  j BINARY_INTEGER := 0;

  v_usage number;
  v_qty number;
  v_hours number;

  ll_res_inst_trx_id number;
  ll_res_trx_id number;
  ll_temp_res_inst_trx_id number;

  l_dummy_id number;
  l_temp_trx_id number;

  l_dummy_name_data varchar2(10000);
  l_dummy_id_data varchar2(10000);
  l_alt_count number;

  l_within_res number;

begin
  put_line('loadAltResource in');
  put_line('plan inst trx '||p_plan_id||' '||p_transaction_id||' '||p_instance_id);

  if ( p_node_type = RES_INST_NODE ) then -- {
    ll_res_inst_trx_id := p_transaction_id;
    ll_res_trx_id := get_parent_res_trx_id(p_plan_id, p_instance_id, ll_res_inst_trx_id);
    put_line(' res-inst node res-trx res-inst-trx '||ll_res_trx_id||' '||ll_res_inst_trx_id);
  else
    ll_res_trx_id := p_transaction_id;
    ll_res_inst_trx_id := get_child_res_trx_id(p_plan_id, p_instance_id, ll_res_trx_id);
    put_line(' res node res-trx res-inst-trx '||ll_res_trx_id||' '||ll_res_inst_trx_id);
  end if; -- }

  if ( p_to_node_type = RES_NODE ) then
    p_return_trx_id := ll_res_trx_id;
  else
    p_return_trx_id := ll_res_inst_trx_id;
  end if;

  put_line(' res-trx inst-trx '||ll_res_trx_id||' '||ll_res_inst_trx_id);

  --get corresponding info about this tranx
  open c_res_trx_info(p_plan_id, p_instance_id, ll_res_trx_id);
  fetch c_res_trx_info into l_resource_id, l_rout_seq, l_op_seq, l_op_seq_num, l_res_seq,
    l_supply_id,l_basis_type, l_act_group, v_qty, l_assigned_units, l_firm_flag;
  close c_res_trx_info;

  --4931312 bufix
    if ( nvl(l_firm_flag,0) <> 0 ) then
      p_return_status := 'ERROR';
      p_out := 'REQ_IS_FIRMED';
      put_line('req_is_firmed 1');
      return;
    end if;
  --4931312 bufix  ends

     -- 4561112 bugfix
     open assembly_qty(p_plan_id, l_supply_id);
     fetch assembly_qty into v_assembly_quantity;
     close assembly_qty;
     if (v_assembly_quantity is null or v_assembly_quantity = 0) then
       v_assembly_quantity := 1;
     end if;
     -- 4561112 bugfix

  -- 4569506 bugfix
  --trying to move within a resource
  l_within_res := sys_no;
  if ( p_node_type = RES_INST_NODE and p_to_node_type = RES_INST_NODE) then --{
   if (l_resource_id = p_alt_resource) then
     l_within_res := sys_yes;
   end if;
  end if; --}
  -- 4569506 bugfix ends

  msc_gantt_utils.getAltResource(p_plan_id, p_transaction_id, p_instance_id,
    l_dummy_name_data, l_dummy_id_data, p_node_type, sys_yes);

  select count(*)
    into l_alt_count
  from msc_form_query
  where query_id = to_number(l_dummy_id_data)
    and number1 = p_alt_resource
    and nvl(number2, mbp_null_value) = nvl(p_alt_resource_inst, mbp_null_value)
    and nvl(char1, mbp_null_value_char)  = nvl(p_serial_number, mbp_null_value_char)
    and number3 = p_alt_num;

  if (l_alt_count = 0 and l_within_res = sys_no) then
      p_return_status := 'ERROR';
      p_out := 'NOT_A_VALID_ALTERNATE';
      return;
  end if;

  --let's do some validation of from and to
  if ( p_node_type = RES_NODE and p_to_node_type = RES_NODE ) then -- {
    null; -- this is okay;
  elsif ( p_node_type = RES_NODE and p_to_node_type = RES_INST_NODE ) then
    if ( l_assigned_units <> 1 ) then
      p_return_status := 'ERROR';
      p_out := 'CANNOT_OFFLOAD_1_ASGN_UNITS';
      return;
    end if;
  elsif ( p_node_type = RES_INST_NODE and p_to_node_type = RES_NODE ) then
    if ( l_resource_id = p_alt_resource) then
      p_return_status := 'ERROR';
      p_out := 'CANNOT_OFFLOAD_TO_PARENT_RESOURCE';
      return;
    elsif ( l_assigned_units <> 1 ) then
      p_return_status := 'ERROR';
      p_out := 'CANNOT_OFFLOAD_1_ASGN_UNITS';
      return;
    end if;
  elsif ( p_node_type = RES_INST_NODE and p_to_node_type = RES_INST_NODE ) then
    if ( l_resource_id = p_alt_resource) then
      open c_inst_req_for_same_req(p_plan_id, p_alt_resource, p_alt_resource_inst,
        p_serial_number, l_supply_id, l_op_seq_num);
      fetch c_inst_req_for_same_req into l_temp_inst_rows;
      close c_inst_req_for_same_req;

      if (l_temp_inst_rows <> 0) then
        p_return_status := 'ERROR';
        p_out := 'CANNOT_OFFLOAD_TO_SAME_REQ';
        return;
      end if;
    elsif ( l_assigned_units <> 1 ) then
      p_return_status := 'ERROR';
      p_out := 'CANNOT_OFFLOAD_1_ASGN_UNITS';
      return;
    end if;

    msc_gantt_utils.updateReqInstFromAlt(p_plan_id, p_instance_id,
      ll_res_inst_trx_id, p_alt_resource, p_alt_resource_inst, p_serial_number,
      null, p_alt_resource, null);

    -- update requirement's supply
    msc_gantt_utils.updateSupplies(p_plan_id, l_supply_id, TOUCH_SUPPLY);

    p_return_status := 'OK';
    p_out := '';
    return;

  end if; -- }
  --validation ends

  if l_act_group is null then -- {
    l_all_seq(1) := l_res_seq;
  else
    open all_res_seq(p_plan_id, p_instance_id, l_op_seq, l_rout_seq, l_act_group);
    fetch all_res_seq bulk collect into l_all_seq;
    close all_res_seq;

    open c_avail_res_seq_count(p_plan_id, p_instance_id, l_op_seq, l_rout_seq, l_act_group, p_alt_num);
    fetch c_avail_res_seq_count into l_avail_res_seq;
    close c_avail_res_seq_count;

    if l_avail_res_seq is null or l_avail_res_seq < l_all_seq.LAST then -- {
      p_return_status := 'ERROR';
      p_out := 'NO_ALT';
      return;
    end if; -- }
  end if; -- }

  for j in 1..l_all_seq.last
  loop -- {
    l_res_seq := l_all_seq(j);

    -- fetch the resources in the same resource group
    open same_res_group(p_plan_id, p_instance_id, l_op_seq, l_rout_seq,
      l_act_group, l_res_seq, p_alt_num, l_supply_id, l_op_seq_num);
    fetch same_res_group bulk collect into l_simu_res;
    close same_res_group;

    -- fetch the resources in the alternate resource group
    open alt_res_group(p_plan_id, p_instance_id, l_op_seq,
      l_rout_seq, l_res_seq, p_alt_num, l_supply_id, l_op_seq_num);
    fetch alt_res_group bulk collect into l_alt_res;
    close alt_res_group;

    put_line(' for loop : index all_seq same_res_group alt_res_group '||j
      || null_space || l_all_seq.count || null_space ||l_simu_res.count
      || null_space ||l_alt_res.count);

    i:=1;
    while (l_simu_res.LAST >= i or l_alt_res.LAST >= i)
    loop -- {

    put_line(' while loop : index  '||i);

    if ( l_simu_res.LAST >= i ) then
      put_line(' same_res_id '||l_simu_res(i).resource_id);
    end if;

    if ( l_alt_res.LAST >= i ) then
      put_line(' alt_res_id '||l_alt_res(i).resource_id);
    end if;

      -- add the res from alt res group
      if i > l_simu_res.last then -- {

	put_line(' in i > l_simu_res.last - inserting alt res into mrr ');

        if ( l_alt_res(i).basis_type = 1 ) then
          v_hours := v_qty * l_alt_res(i).resource_usage;
          v_hours := v_hours/v_assembly_quantity;  --4561112 bugfix
        else
          v_hours := l_alt_res(i).resource_usage;
        end if;

        ll_temp_res_inst_trx_id := get_child_res_trx_id(p_plan_id, p_instance_id, l_simu_res(1).transaction_id);

	  l_dummy_id := msc_gantt_utils.insertReqFromAlt(p_plan_id, p_instance_id,
	  l_simu_res(1).transaction_id , l_alt_res(i).resource_id, v_hours,
	  l_alt_res(i).alternate_number, l_alt_res(i).basis_type,
          l_alt_res(i).orig_resource_seq_num);

        DeleteReqInstFromAlt(p_plan_id, p_instance_id, ll_temp_res_inst_trx_id);
      elsif i > l_alt_res.last then -- delete the extra res

	put_line(' in i > l_alt_res.last - deleting alt res into mrr ');
        ll_temp_res_inst_trx_id := get_child_res_trx_id(p_plan_id, p_instance_id, l_simu_res(i).transaction_id);
	msc_gantt_utils.DeleteReqFromAlt(p_plan_id, p_instance_id, l_simu_res(i).transaction_id);
        DeleteReqInstFromAlt(p_plan_id, p_instance_id, ll_temp_res_inst_trx_id);

      else -- update the res to alt_res

	put_line(' in else simu trx id '||l_simu_res(i).transaction_id||' updating  alt res into mrr ');
        if ( l_alt_res(i).basis_type = 1 ) then
          v_hours := v_qty * l_alt_res(i).resource_usage;
          v_hours := v_hours/v_assembly_quantity;  --4561112 bugfix
        else
          v_hours := l_alt_res(i).resource_usage;
        end if;

	ll_temp_res_inst_trx_id := get_child_res_trx_id(p_plan_id, p_instance_id, l_simu_res(i).transaction_id);
        put_line(' in else simu ll_temp_res_inst_trx_id '||ll_temp_res_inst_trx_id);

	msc_gantt_utils.updateReqFromAlt(p_plan_id, p_instance_id,
	  l_simu_res(i).transaction_id, l_alt_res(i).resource_id,
	  v_hours, l_alt_res(i).alternate_number, l_alt_res(i).basis_type,
          l_alt_res(i).orig_resource_seq_num);

        DeleteReqInstFromAlt(p_plan_id, p_instance_id, ll_temp_res_inst_trx_id);

        if (l_simu_res(i).transaction_id = ll_res_trx_id ) then -- {
	  put_line(' in res inst update insert');
 	  if ( p_node_type = RES_NODE and p_to_node_type = RES_INST_NODE ) then
	    put_line(' res inst insert');
	    l_temp_trx_id := msc_gantt_utils.insertReqInstFromAlt(p_plan_id,
	      p_instance_id, ll_res_trx_id, p_alt_resource, p_alt_resource_inst,
	      p_serial_number, v_hours, p_alt_num, RES_NODE,
              l_alt_res(i).orig_resource_seq_num);
	    p_return_trx_id := l_temp_trx_id ;
	  elsif ( p_node_type = RES_INST_NODE and p_to_node_type = RES_INST_NODE ) then
	    put_line(' res inst update');
	    msc_gantt_utils.updateReqInstFromAlt(p_plan_id, p_instance_id,
	      ll_res_inst_trx_id, p_alt_resource, p_alt_resource_inst, p_serial_number,
	      v_hours, l_alt_res(i).alternate_number,
              l_alt_res(i).orig_resource_seq_num);
	  end if;
	end if; -- }

      end if; -- }
      i := i+1;
    end loop; -- }
  end loop; -- }

  -- update requirement's supply
  msc_gantt_utils.updateSupplies(p_plan_id, l_supply_id, TOUCH_SUPPLY);

  p_return_status := 'OK';
  p_out := '';
exception
  when app_exception.record_lock_exception then
    p_return_status := 'ERROR';
    p_out := 'RECORD_LOCK';
end loadAltResource;

procedure lockReqInstNGetData(p_plan_id number, p_inst_id number, p_trx_id number,
  p_supply_id out nocopy number, p_start_date out nocopy date, p_end_date out nocopy date,
  p_return_status in OUT NOCOPY varchar2, p_out in OUT NOCOPY varchar2) is

begin

  put_line(' lockReqInstNGetData in');
  -- lock the record first
  select mrir.supply_id, mrir.start_date, mrir.end_date
    into p_supply_id, p_start_date, p_end_date
    from msc_resource_instance_reqs mrir
    where mrir.plan_id = p_plan_id
      and mrir.sr_instance_id = p_inst_id
      and mrir.res_inst_transaction_id = p_trx_id
    for update of mrir.supply_id nowait;

  put_line(' lockReqInstNGetData out');
exception
  when no_data_found then
    null;
  when app_exception.record_lock_exception then
    p_return_status := 'ERROR';
    p_out := 'RECORD_LOCK';
end lockReqInstNGetData;

procedure lockReqNGetData(p_plan_id number, p_inst_id number, p_trx_id number,
  p_firm_type out nocopy number, p_supply_id out nocopy number, p_start_date out nocopy date, p_end_date out nocopy date,
  p_firm_start_date out nocopy date, p_firm_end_date out nocopy date,
  p_return_status in OUT NOCOPY varchar2, p_out in OUT NOCOPY varchar2) is

begin

  put_line(' lockReqNGetData in');
    -- lock the record first
    select mrr.firm_start_date, mrr.firm_end_date,
      mrr.start_date, mrr.end_date, mrr.supply_id, mrr.firm_flag
    into p_firm_start_date, p_firm_end_date,
      p_start_date, p_end_date, p_supply_id, p_firm_type
    from msc_resource_requirements mrr
    where mrr.plan_id = p_plan_id
      and mrr.sr_instance_id = p_inst_id
      and mrr.transaction_id = p_trx_id
    for update of mrr.firm_flag nowait;

--5153956 bugfix
/*
    if p_firm_type in (NO_FIRM, FIRM_RESOURCE) then -- {
      p_firm_start_date := to_date(null);
      p_firm_end_date := to_date(null);
    elsif p_firm_type in (FIRM_END, FIRM_END_RES) then
      p_firm_start_date := to_date(null);
      p_firm_end_date := p_end_date;
    elsif p_firm_type in (FIRM_START, FIRM_START_RES) then
      p_firm_start_date := p_start_date;
      p_firm_end_date := to_date(null);
    elsif p_firm_type in (FIRM_START_END,FIRM_ALL) then
      p_firm_start_date := p_start_date;
      p_firm_end_date := p_end_date;
    end if; -- }
*/
  put_line(' lockReqNGetData out');
exception
  when no_data_found then
    null;
  when app_exception.record_lock_exception then
    p_return_status := 'ERROR';
    p_out := 'RECORD_LOCK';
end lockReqNGetData;

procedure updateBatchReq(p_plan_id number, p_inst_id number, p_batch_number number,
  p_start_date date, p_end_date date, p_firm_flag number, p_update_mode number,
  p_return_status in OUT NOCOPY varchar2, p_out in OUT NOCOPY varchar2) is

  l_resource_id number_arr;
  l_temp number;

begin

  -- lock MRR
  begin
    select mrr.resource_id
    bulk collect into l_resource_id
    from msc_resource_requirements mrr
    where mrr.plan_id = p_plan_id
      and mrr.sr_instance_id = p_inst_id
      and mrr.batch_number = p_batch_number
    for update of mrr.resource_id nowait;

    select count(*)
    into l_temp
    from msc_resource_requirements mrr
    where mrr.plan_id = p_plan_id
      and mrr.sr_instance_id = p_inst_id
      and mrr.batch_number = p_batch_number
      and nvl(firm_flag,0) <> 0;

    if ( l_temp > 0 ) then
      p_return_status := 'ERROR';
      p_out := 'REQ_IS_FIRMED';
    end if;

  exception
    when app_exception.record_lock_exception then
      p_return_status := 'ERROR';
      p_out := 'RECORD_LOCK';
      return;
  end;

  -- update MRR
  update msc_resource_requirements
  set status =0,
    applied=2,
    firm_flag = decode( p_update_mode,  FIRM_MRR, p_firm_flag, firm_flag),
    start_date = decode( p_update_mode, MOVE_MRR, p_start_date, start_date),
    end_date = decode( p_update_mode, MOVE_MRR, p_end_date, end_date)
  where plan_id = p_plan_id
    and sr_instance_id = p_inst_id
    and batch_number = p_batch_number;

  -- just update MS...we may need to lock in future..
  update msc_supplies
  set status = 0,
    applied = 2
  where plan_id = p_plan_id
    and sr_instance_id = p_inst_id
    and transaction_id in
      ( select distinct mrr.supply_id
        from msc_resource_requirements mrr
	where mrr.plan_id = p_plan_id
          and mrr.sr_instance_id = p_inst_id
          and mrr.batch_number = p_batch_number );

end updateBatchReq;

procedure updateBatchInstReq(p_plan_id number, p_inst_id number, p_batch_number number,
  p_start_date date, p_end_date date, p_firm_flag number, p_update_mode number,
  p_return_status in OUT NOCOPY varchar2, p_out in OUT NOCOPY varchar2) is

  l_resource_id number_arr;
  l_temp number;

begin

  -- lock MRIR
  begin
    select mrir.resource_id
    bulk collect into l_resource_id
    from msc_resource_instance_reqs mrir
    where mrir.plan_id = p_plan_id
      and mrir.sr_instance_id = p_inst_id
      and mrir.batch_number = p_batch_number
    for update of mrir.resource_id nowait;

    select count(*)
      into l_temp
    from msc_resource_requirements mrr,
      msc_resource_instance_reqs mrir
    where mrir.plan_id = p_plan_id
      and mrir.sr_instance_id = p_inst_id
      and mrir.batch_number = p_batch_number
      and mrir.plan_id = mrr.plan_id
      and mrir.sr_instance_id = mrr.sr_instance_id
      and mrir.organization_id = mrr.organization_id
      and mrir.department_id = mrr.department_id
      and mrir.resource_id = mrr.resource_id
      and mrir.supply_id = mrr.supply_id
      and mrir.operation_seq_num = mrr.operation_seq_num
      and mrir.resource_seq_num = mrr.resource_seq_num
      and nvl(mrir.orig_resource_seq_num, mbp_null_value) = nvl(mrr.orig_resource_seq_num, mbp_null_value)
      and nvl(mrir.parent_seq_num, mbp_null_value) =  nvl(mrr.parent_seq_num, mbp_null_value)
      and nvl(mrir.parent_id, mbp_null_value) = nvl(mrr.parent_id, mbp_null_value)
      and mrir.start_date = nvl(mrr.firm_start_date, mrr.start_date)
      and mrir.end_date = nvl(mrr.firm_end_date, mrr.end_date)
      and nvl(mrir.parent_id,2) = 2
      and nvl(mrr.firm_flag,0) <> 0;

    if ( l_temp > 0 ) then
      p_return_status := 'ERROR';
      p_out := 'REQ_IS_FIRMED';
    end if;

  exception
    when app_exception.record_lock_exception then
      p_return_status := 'ERROR';
      p_out := 'RECORD_LOCK';
      return;
  end;

  -- update MRIR
  update msc_resource_instance_reqs
  set status =0,
    applied=2,
    start_date = p_start_date,
    end_date = p_end_date
  where plan_id = p_plan_id
    and sr_instance_id = p_inst_id
    and batch_number = p_batch_number;

  -- just update MS...we may need to lock in future..
  update msc_supplies
  set status = 0,
    applied = 2
  where plan_id = p_plan_id
    and sr_instance_id = p_inst_id
    and transaction_id in
      ( select distinct mrir.supply_id
        from msc_resource_instance_reqs mrir
	where mrir.plan_id = p_plan_id
          and mrir.sr_instance_id = p_inst_id
          and mrir.batch_number = p_batch_number );

end updateBatchInstReq;

procedure updateResSeq(p_plan_id number, p_inst_id number,
  p_group_sequence_id number, p_duration varchar2,
  p_plan_start_date date, p_plan_end_date date,
  p_return_status in OUT NOCOPY varchar2, p_out in OUT NOCOPY varchar2,
  p_validate_flag boolean, p_node_type number ) is

  l_resource_id number_arr;

  cursor c_firm_seq_req_row (p_plan number, p_inst number, p_group_seq number) is
  select mrr.transaction_id, mrr.start_date, mrr.end_date,
   mrr.firm_flag, mrr.firm_start_date, mrr.firm_end_date
  from msc_resource_requirements mrr
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.group_sequence_id = p_group_seq ;

  l_trx_id number;
  l_start_date date;
  l_end_date date;
  l_firm_flag number;
  l_firm_start_date date;
  l_firm_end_date date;

begin

put_line(' updateResSeq in');

  -- lock MRR
  begin
    select mrr.resource_id
    bulk collect into l_resource_id
    from msc_resource_requirements mrr
    where mrr.plan_id = p_plan_id
      and mrr.sr_instance_id = p_inst_id
      and mrr.group_sequence_id = p_group_sequence_id
    for update of mrr.resource_id nowait;
  exception
    when app_exception.record_lock_exception then
      p_return_status := 'ERROR';
      p_out := 'RECORD_LOCK';
      return;
  end;

  open c_firm_seq_req_row(p_plan_id, p_inst_id, p_group_sequence_id);
  loop
    fetch c_firm_seq_req_row into l_trx_id, l_start_date, l_end_date,
      l_firm_flag, l_firm_start_date, l_firm_end_date;
    exit when c_firm_seq_req_row%notfound;

    l_start_date := l_start_date + to_number(p_duration)/86400;
    l_end_date := l_end_date + to_number(p_duration)/86400;
    l_firm_start_date := l_firm_start_date + to_number(p_duration)/86400;
    l_firm_end_date := l_firm_end_date + to_number(p_duration)/86400;

    if ( p_validate_flag ) then -- {
      validateTime(p_plan_id, l_trx_id, p_inst_id, l_start_date, l_end_date,
        p_plan_start_date, p_plan_end_date, p_return_status, p_out, p_node_type);
      if p_return_status = 'ERROR' then
        return ;
      end if;
    end if; -- }

    moveOneResource(p_plan_id, l_trx_id, p_inst_id, l_start_date, l_end_date,
      p_return_status, p_out, RES_NODE);

    if p_return_status = 'ERROR' then
      return;
    end if;

    -- update the simultaneous resource for a given res trans id
    msc_gantt_utils.updateReqSimu(p_plan_id, p_inst_id, l_trx_id,
      l_firm_flag, l_start_date, l_end_date, l_firm_start_date, l_firm_end_date,
      MOVE_MRR, p_return_status, p_out);

    if p_return_status = 'ERROR' then
      return;
    end if;

  end loop;
  close c_firm_seq_req_row;

  -- just update MS...we may need to lock in future..
  update msc_supplies
  set status = 0,
    applied = 2
  where plan_id = p_plan_id
    and sr_instance_id = p_inst_id
    and transaction_id in
      ( select distinct mrr.supply_id
        from msc_resource_requirements mrr
	where mrr.plan_id = p_plan_id
          and mrr.sr_instance_id = p_inst_id
          and mrr.group_sequence_id = p_group_sequence_id );
put_line(' updateResSeq out');

end updateResSeq;

procedure updateReqFromAlt(p_plan_id number, p_inst_id number, p_simu_res_trx number,
  p_alt_res_id number, p_alt_res_hours number, p_alt_res_alt_num number, p_alt_res_basis_type number,
  p_alt_orig_res_seq_num number) is
    l_firm_flag number;
begin
  select mrr.firm_flag
  into l_firm_flag
  from msc_resource_requirements mrr
  where mrr.plan_id = p_plan_id
    and mrr.transaction_id = p_simu_res_trx
    and mrr.sr_instance_id = p_inst_id
  for update of mrr.firm_flag nowait;

  if l_firm_flag in (NO_FIRM, FIRM_RESOURCE) or l_firm_flag is null then -- {
    l_firm_flag := FIRM_RESOURCE;
  elsif l_firm_flag in (FIRM_START, FIRM_START_RES) THEN
    l_firm_flag := FIRM_START_RES;
  elsif l_firm_flag in (FIRM_END, FIRM_END_RES) THEN
    l_firm_flag := FIRM_END_RES;
  elsif l_firm_flag in (FIRM_ALL, FIRM_START_END) THEN
    l_firm_flag := FIRM_ALL;
  else
    l_firm_flag := FIRM_RESOURCE;
  end if; -- }

put_line(' updateReqFromAlt updating to alt_res_id '||p_alt_res_id);

  update msc_resource_requirements
    set status = 0,
    applied=2,
    resource_id = p_alt_res_id,
    alternate_num = p_alt_res_alt_num,
    --firm_flag = l_firm_flag,
    resource_hours = p_alt_res_hours,
    orig_resource_seq_num = p_alt_orig_res_seq_num,
    basis_type = p_alt_res_basis_type
  where plan_id = p_plan_id
    and transaction_id = p_simu_res_trx
    and sr_instance_id = p_inst_id;

end updateReqFromAlt;

procedure updateReqInstFromAlt(p_plan_id number, p_inst_id number, p_simu_res_trx number,
  p_alt_res_id number, p_alt_res_instance_id number, p_serial_number varchar2,
  p_alt_res_hours number, p_alt_res_alt_num number,
  p_alt_orig_res_seq_num number) is

  l_resource_id number;
  l_hours number;
begin
    select mrir.resource_id, resource_instance_hours
    into l_resource_id, l_hours
    from msc_resource_instance_reqs mrir
    where mrir.plan_id = p_plan_id
      and mrir.sr_instance_id = p_inst_id
      and mrir.res_inst_transaction_id = p_simu_res_trx
    for update of mrir.resource_id nowait;

  update msc_resource_instance_reqs
    set status = 0,
    applied=2,
    resource_id = p_alt_res_id,
    res_instance_id = p_alt_res_instance_id,
    serial_number = p_serial_number,
    orig_resource_seq_num = nvl(p_alt_orig_res_seq_num,orig_resource_seq_num),
    resource_instance_hours = nvl(p_alt_res_hours,resource_instance_hours)
  where plan_id = p_plan_id
    and res_inst_transaction_id = p_simu_res_trx
    and sr_instance_id = p_inst_id;
end updateReqInstFromAlt;

procedure DeleteReqFromAlt(p_plan_id number, p_inst_id number, p_simu_res_trx number) is
  l_firm_flag number;
begin
  select mrr.firm_flag
  into l_firm_flag
  from msc_resource_requirements mrr
  where mrr.plan_id = p_plan_id
    and mrr.sr_instance_id = p_inst_id
    and mrr.transaction_id = p_simu_res_trx
  for update of mrr.firm_flag nowait;

  delete msc_resource_requirements mrr
  where mrr.plan_id = p_plan_id
    and mrr.sr_instance_id = p_inst_id
    and mrr.transaction_id = p_simu_res_trx;
  exception
    when no_data_found then
      null;
end DeleteReqFromAlt;

procedure DeleteReqInstFromAlt(p_plan_id number,
  p_inst_id number, p_res_inst_trx number) is
  l_resource_id number;
begin
  put_line('DeleteReqInstFromAlt in '||p_plan_id||' '||p_inst_id||' '||p_res_inst_trx);
  select mrir.resource_id
  into l_resource_id
  from msc_resource_instance_reqs mrir
  where mrir.plan_id = p_plan_id
    and mrir.sr_instance_id = p_inst_id
    and mrir.res_inst_transaction_id = p_res_inst_trx
  for update of mrir.resource_id nowait;

  delete msc_resource_instance_reqs mrir
  where mrir.plan_id = p_plan_id
    and mrir.sr_instance_id = p_inst_id
    and mrir.res_inst_transaction_id = p_res_inst_trx;

  exception
    when no_data_found then
      null;
end DeleteReqInstFromAlt;

function insertReqInstFromAlt(p_plan_id number, p_inst_id number,
  p_simu_res_inst_trx number, p_alt_res_id number, p_alt_res_instance_id number,
  p_serial_number varchar2, p_alt_res_hours number, p_alt_res_alt_num number,
  p_from_node number,
  p_alt_orig_res_seq_num number) return number is

  l_trx_id number;

  cursor c_inst_row is
    select count(*)
    from msc_resource_instance_reqs
    where plan_id = p_plan_id
      and res_inst_transaction_id = l_trx_id;

  cursor c_equipment is
  select equipment_item_id
  from msc_dept_res_instances
  where plan_id = p_plan_id
    and resource_id = p_alt_res_id
    and res_instance_id = p_alt_res_instance_id
    and nvl(serial_number,mbp_null_value_char) = nvl(p_serial_number,mbp_null_value_char);

  l_equip_item_id number;

  l_temp number;
begin
  put_line(' insertReqInstFromAlt plan inst trx '|| p_plan_id ||' '|| p_inst_id||' '|| p_simu_res_inst_trx);
  select msc_resource_instance_reqs_s.nextval
  into l_trx_id
  from dual;

  open c_equipment;
  fetch c_equipment into l_equip_item_id;
  close c_equipment;

  -- p_node_type = RES_NODE and p_to_node_type = RES_INST_NODE
  if (p_from_node = RES_INST_NODE) then -- {
    put_line(' insertReqInstFromAlt : trying to insert a row in mrir from mrir l_trx_id '||l_trx_id);

  insert into msc_resource_instance_reqs(
    RES_INST_TRANSACTION_ID, PLAN_ID, SR_INSTANCE_ID, ORGANIZATION_ID,
    SUPPLY_ID, DEPARTMENT_ID, RESOURCE_ID, RES_INSTANCE_ID, SERIAL_NUMBER, EQUIPMENT_ITEM_ID,
    PARENT_ID, PARENT_SEQ_NUM, OPERATION_SEQ_NUM, RESOURCE_SEQ_NUM, ORIG_RESOURCE_SEQ_NUM,
    SETUP_SEQUENCE_NUM, WIP_ENTITY_ID, START_DATE, END_DATE,
    RESOURCE_INSTANCE_HOURS, CAPACITY_CONSUMED, CAPACITY_CONSUMED_RATIO, BATCH_NUMBER,
    STATUS, APPLIED, UPDATED,
    LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,LAST_UPDATE_LOGIN, REFRESH_NUMBER
    )
  select
    l_trx_id, PLAN_ID, SR_INSTANCE_ID, ORGANIZATION_ID,
    SUPPLY_ID, DEPARTMENT_ID, p_alt_res_id, p_alt_res_instance_id, p_serial_number, l_equip_item_id,
    PARENT_ID, PARENT_SEQ_NUM, OPERATION_SEQ_NUM, RESOURCE_SEQ_NUM, p_alt_orig_res_seq_num,
    SETUP_SEQUENCE_NUM, WIP_ENTITY_ID, START_DATE, END_DATE,
    p_alt_res_hours, CAPACITY_CONSUMED, CAPACITY_CONSUMED_RATIO, BATCH_NUMBER,
    STATUS, APPLIED, UPDATED,
    LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,LAST_UPDATE_LOGIN, REFRESH_NUMBER
  from msc_resource_instance_reqs mrir
  where mrir.plan_id = p_plan_id
    and mrir.sr_instance_id = p_inst_id
    and mrir.res_inst_transaction_id = p_simu_res_inst_trx;

  open c_inst_row;
  fetch c_inst_row into l_temp;
  close c_inst_row;
  put_line(' inserted '||l_temp||' rows ');

  if (l_temp > 0) then
    return l_trx_id;
  end if;
  end if; -- }

  if (p_from_node = RES_NODE) then -- {

  put_line(' insertReqInstFromAlt : trying to insert a row in mrir from mrr l_trx_id '||l_trx_id);

  insert into msc_resource_instance_reqs(
    RES_INST_TRANSACTION_ID, PLAN_ID, SR_INSTANCE_ID, ORGANIZATION_ID,
    SUPPLY_ID, DEPARTMENT_ID, RESOURCE_ID, RES_INSTANCE_ID, SERIAL_NUMBER, EQUIPMENT_ITEM_ID,
    PARENT_ID, PARENT_SEQ_NUM, OPERATION_SEQ_NUM, RESOURCE_SEQ_NUM, ORIG_RESOURCE_SEQ_NUM,
    --SETUP_SEQUENCE_NUM,
    WIP_ENTITY_ID, START_DATE, END_DATE,
    RESOURCE_INSTANCE_HOURS,
    --CAPACITY_CONSUMED, CAPACITY_CONSUMED_RATIO,
    BATCH_NUMBER, STATUS, APPLIED, UPDATED,
    LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,LAST_UPDATE_LOGIN, REFRESH_NUMBER
    )
  select
    l_trx_id, PLAN_ID, SR_INSTANCE_ID, ORGANIZATION_ID,
    SUPPLY_ID, DEPARTMENT_ID, p_alt_res_id, p_alt_res_instance_id, p_serial_number, l_equip_item_id,
    PARENT_ID, PARENT_SEQ_NUM, OPERATION_SEQ_NUM, RESOURCE_SEQ_NUM, ORIG_RESOURCE_SEQ_NUM,
    --SETUP_SEQUENCE_NUM,
    WIP_ENTITY_ID, START_DATE, END_DATE, p_alt_res_hours,
    --CAPACITY_CONSUMED, CAPACITY_CONSUMED_RATIO,
    BATCH_NUMBER, STATUS, APPLIED, UPDATED,
    LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,LAST_UPDATE_LOGIN, REFRESH_NUMBER
  from msc_resource_requirements mrr
  where mrr.plan_id = p_plan_id
    and mrr.sr_instance_id = p_inst_id
    and mrr.transaction_id = p_simu_res_inst_trx;

  open c_inst_row;
  fetch c_inst_row into l_temp;
  close c_inst_row;
  put_line(' inserted '||l_temp||' rows ');
  end if; -- }

  return l_trx_id;
end insertReqInstFromAlt;

function insertReqFromAlt(p_plan_id number, p_inst_id number,
  p_simu_res_trx number,
  p_alt_res_id number,
  p_alt_res_hours number,
  p_alt_res_alt_num number,
  p_alt_res_basis_type number,
  p_alt_orig_res_seq_num number) return number is
  l_trx_id number;
begin
  select msc_resource_instance_reqs_s.nextval
  into l_trx_id
  from dual;

  insert into msc_resource_requirements(
    TRANSACTION_ID, PLAN_ID, SUPPLY_ID, ORGANIZATION_ID, SR_INSTANCE_ID,
    ROUTING_SEQUENCE_ID, OPERATION_SEQUENCE_ID, RESOURCE_SEQ_NUM, RESOURCE_ID,
    DEPARTMENT_ID, ALTERNATE_NUM, START_DATE, END_DATE, BKT_START_DATE,
    RESOURCE_HOURS, SET_UP, BKT_END_DATE, TEAR_DOWN, AGGREGATE_RESOURCE_ID,
    SCHEDULE_FLAG, PARENT_ID, STD_OP_CODE, WIP_ENTITY_ID, ASSIGNED_UNITS, BASIS_TYPE,
    OPERATION_SEQ_NUM, LOAD_RATE, DAILY_RESOURCE_HOURS, STATUS, APPLIED, UPDATED,
    SUBST_RES_FLAG, REFRESH_NUMBER,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, CREATED_BY, CREATION_DATE, LAST_UPDATE_LOGIN,
    SOURCE_ITEM_ID, ASSEMBLY_ITEM_ID, SUPPLY_TYPE, FIRM_START_DATE, FIRM_END_DATE, FIRM_FLAG,
    ORIG_RESOURCE_SEQ_NUM
    )
  select l_trx_id, PLAN_ID, SUPPLY_ID, ORGANIZATION_ID, SR_INSTANCE_ID,
    ROUTING_SEQUENCE_ID, OPERATION_SEQUENCE_ID,
    RESOURCE_SEQ_NUM, p_alt_res_id, DEPARTMENT_ID, p_alt_res_alt_num,
    START_DATE, END_DATE, BKT_START_DATE, p_alt_res_hours, SET_UP, BKT_END_DATE, TEAR_DOWN,
    AGGREGATE_RESOURCE_ID, SCHEDULE_FLAG, PARENT_ID, STD_OP_CODE, WIP_ENTITY_ID, ASSIGNED_UNITS,
    p_alt_res_basis_type, OPERATION_SEQ_NUM, LOAD_RATE, DAILY_RESOURCE_HOURS, 0, 2, UPDATED,
    SUBST_RES_FLAG, REFRESH_NUMBER,
    LAST_UPDATED_BY, LAST_UPDATE_DATE, CREATED_BY, CREATION_DATE, LAST_UPDATE_LOGIN,
    SOURCE_ITEM_ID, ASSEMBLY_ITEM_ID, SUPPLY_TYPE, FIRM_START_DATE, FIRM_END_DATE, FIRM_RESOURCE,
    p_alt_orig_res_seq_num
  from msc_resource_requirements mrr
  where mrr.plan_id = p_plan_id
    and mrr.transaction_id = p_simu_res_trx
    and mrr.sr_instance_id = p_inst_id;

  return l_trx_id;
end insertReqFromAlt;

procedure updateReq(p_plan_id number, p_inst_id number, p_trx_id number,
  p_firm_type number, p_start_date date, p_end_date date,
  p_firm_start_date date, p_firm_end_date date,
  p_update_mode number) is

begin
  -- 5153956 bugfix, dont update start_date, end_date

  -- 4673468 bugfix
  -- valid firm_type values
  -- 0 Un Firm
  -- 1 Firm Start Date
  -- 2 Firm End Date
  -- 3 Firm Resource
  -- 4 Firm Start Date and End Date
  -- 5 Firm Start Date and Resource
  -- 6 Firm End Date and Resource
  -- 7 Firm All
  update msc_resource_requirements
  set status =0,
    applied=2,
    firm_flag = decode(p_update_mode,
	MOVE_MRR, firm_flag,
	FIRM_MRR, p_firm_type,
	firm_flag),
    firm_start_date = decode(p_update_mode,
	FIRM_MRR, decode(p_firm_type,
			0, to_date(null),
			3, to_date(null),
                        nvl(firm_start_date, start_date)),
	MOVE_MRR, p_start_date,
	firm_start_date),
    firm_end_date = decode(p_update_mode,
	FIRM_MRR, decode(p_firm_type,
			0, to_date(null),
			3, to_date(null),
		   	nvl(firm_end_date, end_date)),
        MOVE_MRR, p_end_date,
	firm_end_date),
    --start_date = p_start_date,
    --end_date = p_end_date,
    resource_hours = decode(p_update_mode,
	FIRM_MRR, resource_hours,
	MOVE_MRR, resource_hours + (assigned_units *
	  (((p_end_date - p_start_date) * 24) - ((end_date - start_date) * 24))),
	  resource_hours),
     batch_number = decode(p_update_mode, MOVE_MRR, to_number(null), batch_number)
  where plan_id = p_plan_id
    and transaction_id = p_trx_id
    and sr_instance_id = p_inst_id;

end updateReq;

-- update the simultaneous resource for a given res trans id
procedure updateReqSimu(p_plan_id number, p_inst_id number, p_trx_id number,
  p_firm_type number, p_start_date in out nocopy date, p_end_date in out nocopy date,
  p_firm_start_date date, p_firm_end_date date,
  p_update_mode number,
  p_return_status in OUT NOCOPY varchar2,
  p_out in OUT NOCOPY varchar2) is

  l_transaction_id number;
  l_instance_id number;
  l_count number :=0;

  l_res_id number;
begin
    open simu_res_cur(p_plan_id, p_inst_id, p_trx_id);
    loop  -- {
      fetch simu_res_cur into l_transaction_id, l_instance_id;
      exit when simu_res_cur%notfound;

      p_out := 'OK_WITH_SIMU_RES';

      select mrr.resource_id
      into l_res_id
      from msc_resource_requirements mrr
      where mrr.plan_id = p_plan_id
        and mrr.transaction_id = l_transaction_id
        and mrr.sr_instance_id = l_instance_id
      for update of mrr.firm_flag nowait;

      if ( p_update_mode = FIRM_MRR ) then
        -- update requirement
        msc_gantt_utils.updateReq(p_plan_id, l_instance_id, l_transaction_id,
          p_firm_type, p_start_date, p_end_date, p_firm_start_date, p_firm_end_date, p_update_mode);
      elsif ( p_update_mode = MOVE_MRR ) then
        moveOneResource(p_plan_id, l_transaction_id, l_instance_id,
	  p_start_date, p_end_date, p_return_status, p_out, RES_NODE);
      end if;

       if ( p_return_status = 'ERROR' ) then
         close simu_res_cur;
         return ;
       end if;

      l_count := l_count + 1;
    end loop; -- }
    close simu_res_cur;
end updateReqSimu;

procedure updateReqInst(p_plan_id number, p_inst_id number, p_trx_id number,
  p_start_date date, p_end_date date) is
begin
  update msc_resource_instance_reqs
  set status =0,
    applied=2,
    start_date = p_start_date,
    end_date = p_end_date,
    batch_number = to_number(null),
    resource_instance_hours = resource_instance_hours
      + (((p_end_date - p_start_date) * 24) - ((end_date - start_date) * 24))
  where plan_id = p_plan_id
    and res_inst_transaction_id = p_trx_id
    and sr_instance_id = p_inst_id;
end updateReqInst;

procedure firmReqInst(p_plan_id number, p_inst_id number, p_res_trx_id number, p_res_inst_trx_id number ) is

   cursor c_res_req_dates is
    select nvl(mrr.firm_start_date, mrr.start_date),
       nvl(mrr.firm_end_date, mrr.end_date)
    from msc_resource_requirements mrr
    where mrr.plan_id = p_plan_id
      and mrr.sr_instance_id = p_inst_id
      and mrr.transaction_id = p_res_trx_id;

   l_start_date date;
   l_end_date date;
begin
  open c_res_req_dates;
  fetch c_res_req_dates into l_start_date, l_end_date;
  close c_res_req_dates;

  update msc_resource_instance_reqs
  set status =0,
    applied=2,
    start_date = l_start_date,
    end_date = l_end_date
  where plan_id = p_plan_id
    and res_inst_transaction_id = p_res_inst_trx_id
    and sr_instance_id = p_inst_id;
end firmReqInst;

procedure updateSupplies(p_plan_id number,
  p_trx_id number, p_update_type number,
  p_firm_type number default null,
  p_firm_date date default null,
  p_firm_qty number default null) is
begin
  update msc_supplies
  set status = 0,
    applied = 2,
    firm_planned_type = decode(p_update_type,
	FIRM_SUPPLY, p_firm_type,
        FIRM_ALL_SUPPLY, p_firm_type,
	firm_planned_type),
    firm_date = decode(p_update_type,
        FIRM_ALL_SUPPLY, p_firm_date,
	firm_date),
    firm_quantity = decode(p_update_type,
        FIRM_ALL_SUPPLY, p_firm_qty,
	firm_quantity)
  where plan_id = p_plan_id
    and transaction_id = p_trx_id;
end updateSupplies;

procedure validateTime(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_start_date date, p_end_date date,
  p_plan_start_date date, p_plan_end_date date,
  p_return_status in OUT NOCOPY varchar2,
  p_out in OUT NOCOPY varchar2,
  p_node_type number) IS

  cursor curr_res is
  select mrr.operation_seq_num,
    nvl(mrr.schedule_flag, 0) schedule_flag,
    decode(ms.order_type, 27, 1, ms.firm_planned_type) firm_planned_type,
    sysdate theDate,
    getMTQTime(p_transaction_id, p_plan_id, p_instance_id) mtq_time
  from msc_resource_requirements mrr,
    msc_supplies ms
  where mrr.plan_id = p_plan_id
    and mrr.sr_instance_id = p_instance_id
    and mrr.transaction_id = p_transaction_id
    and ms.plan_id = mrr.plan_id
    and ms.transaction_id = mrr.supply_id
    and ms.sr_instance_id = mrr.sr_instance_id;

  cursor lower_bound is
  select mrr2.operation_seq_num,
    mrr2.resource_seq_num,
    mrr2.transaction_id,
    nvl(mrr2.schedule_flag, 0) schedule_flag,
    decode(nvl(mrr2.firm_flag,0),
      NO_FIRM, mrr2.start_date,
      FIRM_RESOURCE, mrr2.start_date,
      FIRM_END, mrr2.firm_end_date -
	 (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24) - mrr2.start_date),
      FIRM_END_RES, mrr2.firm_end_date -
         (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24) - mrr2.start_date),
      nvl(mrr2.firm_start_date, mrr2.start_date)) start_date,
    decode(nvl(mrr2.firm_flag,0),
      NO_FIRM, nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24),
      FIRM_RESOURCE, nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24),
      FIRM_START, mrr2.firm_start_date +
        (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24) - mrr2.start_date),
      FIRM_START_RES, mrr2.firm_start_date +
        (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24) - mrr2.start_date),
      nvl(nvl(mrr2.firm_end_date, mrr2.end_date),  mrr2.start_date+mrr2.resource_hours/24)) end_date,
    msc_gantt_utils.getMTQTime(mrr2.transaction_id, p_plan_id, p_instance_id) mtq_time
  from msc_resource_requirements mrr1,
    msc_resource_requirements mrr2,
    msc_routings mr
  where mrr1.plan_id = p_plan_id
    and mrr1.transaction_id = p_transaction_id
    and mrr1.sr_instance_id = p_instance_id
    and mrr2.plan_id = mrr1.plan_id
    and mrr2.supply_id = mrr1.supply_id
    and mrr2.sr_instance_id = mrr1.sr_instance_id
    and nvl(mrr2.parent_id,2) =2
    and mr.plan_id = mrr1.plan_id
    and mr.sr_instance_id = mrr1.sr_instance_id
    and mr.routing_sequence_id = mrr1.routing_sequence_id
    and (((nvl(mr.cfm_routing_flag,2) <> 3 and mrr2.operation_seq_num < mrr1.operation_seq_num)
           or ( nvl(mr.cfm_routing_flag,2) = 3
	         and mrr2.operation_sequence_id in (
                                       select mon.from_op_seq_id
				       from msc_operation_networks mon
                                       where mon.plan_id = mrr1.plan_id
                                         and mon.sr_instance_id = mrr1.sr_instance_id
                                         and mon.routing_sequence_id = mrr1.routing_sequence_id
                                         and mon.to_op_seq_id = mrr1.operation_sequence_id
          ))) or
          (mrr2.operation_seq_num = mrr1.operation_seq_num and
           mrr2.resource_seq_num < mrr1.resource_seq_num))
     and (mrr2.firm_start_date is not null or mrr2.firm_end_date is not null )
     and mrr2.firm_flag in (FIRM_START,FIRM_END,FIRM_START_END,FIRM_START_RES,FIRM_END_RES,FIRM_ALL)
   order by mrr2.operation_seq_num desc, mrr2.resource_seq_num desc;

  cursor upper_bound is
  select mrr2.operation_seq_num,
    mrr2.resource_seq_num,
    mrr2.transaction_id,
    nvl(mrr2.schedule_flag, 0) schedule_flag,
    decode(nvl(mrr2.firm_flag,0),
      NO_FIRM, mrr2.start_date,
      FIRM_RESOURCE, mrr2.start_date,
      FIRM_END, mrr2.firm_end_date -
        (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24) - mrr2.start_date),
      FIRM_END_RES, mrr2.firm_end_date -
        (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24) - mrr2.start_date),
      nvl(mrr2.firm_start_date, mrr2.start_date)) start_date,
    decode(nvl(mrr2.firm_flag,0),
      NO_FIRM, nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24),
      FIRM_RESOURCE, nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24),
      FIRM_START, mrr2.firm_start_date +
        (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24) - mrr2.start_date),
      FIRM_START_RES, mrr2.firm_start_date +
        (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24) - mrr2.start_date),
      nvl(nvl(mrr2.firm_end_date, mrr2.end_date),  mrr2.start_date+mrr2.resource_hours/24)) end_date
  from msc_resource_requirements mrr1,
    msc_resource_requirements mrr2,
    msc_routings mr
  where mrr1.plan_id = p_plan_id
    and mrr1.transaction_id = p_transaction_id
    and mrr1.sr_instance_id = p_instance_id
    and mrr2.plan_id = mrr1.plan_id
    and mrr2.supply_id = mrr1.supply_id
    and mrr2.sr_instance_id = mrr1.sr_instance_id
    and nvl(mrr2.parent_id,2) =2
    and mr.plan_id = mrr1.plan_id
    and mr.sr_instance_id = mrr1.sr_instance_id
    and mr.routing_sequence_id = mrr1.routing_sequence_id
    and (((nvl(mr.cfm_routing_flag,2) <> 3 and mrr2.operation_seq_num > mrr1.operation_seq_num)
           or ( nvl(mr.cfm_routing_flag,2) = 3 and mrr2.operation_sequence_id in (
                                       select mon.to_op_seq_id from msc_operation_networks mon
                                       where mon.plan_id = mrr1.plan_id
                                         and mon.sr_instance_id = mrr1.sr_instance_id
                                         and mon.routing_sequence_id = mrr1.routing_sequence_id
                                         and mon.from_op_seq_id = mrr1.operation_sequence_id
          ))) or
          (mrr2.operation_seq_num = mrr1.operation_seq_num and
           mrr2.resource_seq_num > mrr1.resource_seq_num))
     and (mrr2.firm_start_date is not null or
         mrr2.firm_end_date is not null )
     and mrr2.firm_flag in (FIRM_START,FIRM_END,FIRM_START_END,FIRM_START_RES,
              FIRM_END_RES,FIRM_ALL)
   order by mrr2.operation_seq_num, mrr2.resource_seq_num;


  cursor curr_res_inst is
  select mrr.operation_seq_num,
    nvl(mrr.schedule_flag, 0) schedule_flag,
    decode(ms.order_type, 27, 1, ms.firm_planned_type) firm_planned_type,
    sysdate theDate,
    getMTQTime(p_transaction_id, p_plan_id, p_instance_id) mtq_time
  from msc_resource_requirements mrr,
    msc_resource_instance_reqs mrir,
    msc_supplies ms
  where mrir.plan_id = p_plan_id
    and mrir.sr_instance_id = p_instance_id
    and mrir.res_inst_transaction_id = p_transaction_id
    and mrir.plan_id = mrr.plan_id
    and mrir.sr_instance_id = mrr.sr_instance_id
    and mrir.organization_id = mrr.organization_id
    and mrir.department_id = mrr.department_id
    and mrir.resource_id = mrr.resource_id
    and mrir.supply_id = mrr.supply_id
    and mrir.operation_seq_num = mrr.operation_seq_num
    and mrir.resource_seq_num = mrr.resource_seq_num
    and nvl(mrir.orig_resource_seq_num, mbp_null_value) = nvl(mrr.orig_resource_seq_num, mbp_null_value)
    and nvl(mrir.parent_seq_num, mbp_null_value) = nvl(mrr.parent_seq_num, mbp_null_value)
    and nvl(mrir.parent_id, mbp_null_value) = nvl(mrr.parent_id, mbp_null_value)
    and mrir.start_date = nvl(mrr.firm_start_date, mrr.start_date)
    and mrir.end_date = nvl(mrr.firm_end_date, mrr.end_date)
    and ms.plan_id = mrr.plan_id
    and ms.transaction_id = mrr.supply_id
    and ms.sr_instance_id = mrr.sr_instance_id;

  cursor lower_bound_res_inst is
  select mrr2.operation_seq_num,
    mrr2.resource_seq_num,
    mrr2.transaction_id,
    nvl(mrr2.schedule_flag, 0) schedule_flag,
    decode(nvl(mrr2.firm_flag,0),
      NO_FIRM, mrir2.start_date,
      FIRM_RESOURCE, mrir2.start_date,
      FIRM_END, mrr2.firm_end_date -
	 (nvl(mrir2.end_date, mrir2.start_date+mrir2.resource_instance_hours/24) - mrir2.start_date),
      FIRM_END_RES, mrr2.firm_end_date -
         (nvl(mrir2.end_date, mrir2.start_date+mrir2.resource_instance_hours/24) - mrir2.start_date),
      nvl(mrr2.firm_start_date, mrir2.start_date)) start_date,
    decode(nvl(mrr2.firm_flag,0),
      NO_FIRM, nvl(mrir2.end_date, mrir2.start_date+mrir2.resource_instance_hours/24),
      FIRM_RESOURCE, nvl(mrir2.end_date, mrir2.start_date+mrir2.resource_instance_hours/24),
      FIRM_START, mrr2.firm_start_date +
        (nvl(mrir2.end_date, mrir2.start_date+mrir2.resource_instance_hours/24) - mrir2.start_date),
      FIRM_START_RES, mrr2.firm_start_date +
        (nvl(mrir2.end_date, mrir2.start_date+mrir2.resource_instance_hours/24) - mrir2.start_date),
      nvl(nvl(mrr2.firm_end_date, mrir2.end_date),  mrir2.start_date+mrir2.resource_instance_hours/24)) end_date,
    msc_gantt_utils.getMTQTime(mrr2.transaction_id, p_plan_id, p_instance_id) mtq_time
  from msc_resource_requirements mrr1,
    msc_resource_instance_reqs mrir1,
    msc_resource_requirements mrr2,
    msc_resource_instance_reqs mrir2,
    msc_routings mr
  where mrir1.plan_id = p_plan_id
    and mrir1.res_inst_transaction_id = p_transaction_id
    and mrir1.sr_instance_id = p_instance_id
    and mrir1.plan_id = mrr1.plan_id
    and mrir1.sr_instance_id = mrr1.sr_instance_id
    and mrir1.organization_id = mrr1.organization_id
    and mrir1.department_id = mrr1.department_id
    and mrir1.resource_id = mrr1.resource_id
    and mrir1.supply_id = mrr1.supply_id
    and mrir1.operation_seq_num = mrr1.operation_seq_num
    and mrir1.resource_seq_num = mrr1.resource_seq_num
    and nvl(mrir1.orig_resource_seq_num, mbp_null_value) = nvl(mrr1.orig_resource_seq_num, mbp_null_value)
    and nvl(mrir1.parent_seq_num, mbp_null_value) = nvl(mrr1.parent_seq_num, mbp_null_value)
    and nvl(mrir1.parent_id, mbp_null_value) = nvl(mrr1.parent_id, mbp_null_value)
    and mrir1.start_date = nvl(mrr1.firm_start_date, mrr1.start_date)
    and mrir1.end_date = nvl(mrr1.firm_end_date, mrr1.end_date)
    and mrr2.plan_id = mrr1.plan_id
    and mrr2.supply_id = mrr1.supply_id
    and mrr2.sr_instance_id = mrr1.sr_instance_id
    and nvl(mrr2.parent_id,2) =2
    and mrir2.plan_id = mrr2.plan_id
    and mrir2.sr_instance_id = mrr2.sr_instance_id
    and mrir2.organization_id = mrr2.organization_id
    and mrir2.department_id = mrr2.department_id
    and mrir2.resource_id = mrr2.resource_id
    and mrir2.supply_id = mrr2.supply_id
    and mrir2.operation_seq_num = mrr2.operation_seq_num
    and mrir2.resource_seq_num = mrr2.resource_seq_num
    and nvl(mrir2.orig_resource_seq_num, mbp_null_value) = nvl(mrr2.orig_resource_seq_num, mbp_null_value)
    and nvl(mrir2.parent_seq_num, mbp_null_value) = nvl(mrr2.parent_seq_num, mbp_null_value)
    and nvl(mrir2.parent_id, mbp_null_value) = nvl(mrr2.parent_id, mbp_null_value)
    and mrir2.start_date = nvl(mrr2.firm_start_date, mrr2.start_date)
    and mrir2.end_date = nvl(mrr2.firm_end_date, mrr2.end_date)
    and mr.plan_id = mrr1.plan_id
    and mr.sr_instance_id = mrr1.sr_instance_id
    and mr.routing_sequence_id = mrr1.routing_sequence_id
    and (((nvl(mr.cfm_routing_flag,2) <> 3 and mrr2.operation_seq_num < mrr1.operation_seq_num)
           or ( nvl(mr.cfm_routing_flag,2) = 3
	         and mrr2.operation_sequence_id in (
                                       select mon.from_op_seq_id
				       from msc_operation_networks mon
                                       where mon.plan_id = mrr1.plan_id
                                         and mon.sr_instance_id = mrr1.sr_instance_id
                                         and mon.routing_sequence_id = mrr1.routing_sequence_id
                                         and mon.to_op_seq_id = mrr1.operation_sequence_id
          ))) or
          (mrr2.operation_seq_num = mrr1.operation_seq_num and
           mrr2.resource_seq_num < mrr1.resource_seq_num))
     and (mrr2.firm_start_date is not null or mrr2.firm_end_date is not null )
     and mrr2.firm_flag in (FIRM_START,FIRM_END,FIRM_START_END,FIRM_START_RES,FIRM_END_RES,FIRM_ALL)
   order by mrr2.operation_seq_num desc, mrr2.resource_seq_num desc;

  cursor upper_bound_res_inst is
  select mrr2.operation_seq_num,
    mrr2.resource_seq_num,
    mrr2.transaction_id,
    nvl(mrr2.schedule_flag, 0) schedule_flag,
    decode(nvl(mrr2.firm_flag,0),
      NO_FIRM, mrir2.start_date,
      FIRM_RESOURCE, mrir2.start_date,
      FIRM_END, mrr2.firm_end_date -
	 (nvl(mrir2.end_date, mrir2.start_date+mrir2.resource_instance_hours/24) - mrir2.start_date),
      FIRM_END_RES, mrr2.firm_end_date -
         (nvl(mrir2.end_date, mrir2.start_date+mrir2.resource_instance_hours/24) - mrir2.start_date),
      nvl(mrr2.firm_start_date, mrir2.start_date)) start_date,
    decode(nvl(mrr2.firm_flag,0),
      NO_FIRM, nvl(mrir2.end_date, mrir2.start_date+mrir2.resource_instance_hours/24),
      FIRM_RESOURCE, nvl(mrir2.end_date, mrir2.start_date+mrir2.resource_instance_hours/24),
      FIRM_START, mrr2.firm_start_date +
        (nvl(mrir2.end_date, mrir2.start_date+mrir2.resource_instance_hours/24) - mrir2.start_date),
      FIRM_START_RES, mrr2.firm_start_date +
        (nvl(mrir2.end_date, mrir2.start_date+mrir2.resource_instance_hours/24) - mrir2.start_date),
      nvl(nvl(mrr2.firm_end_date, mrir2.end_date),  mrir2.start_date+mrir2.resource_instance_hours/24)) end_date
  from msc_resource_requirements mrr1,
    msc_resource_instance_reqs mrir1,
    msc_resource_requirements mrr2,
    msc_resource_instance_reqs mrir2,
    msc_routings mr
  where mrir1.plan_id = p_plan_id
    and mrir1.res_inst_transaction_id = p_transaction_id
    and mrir1.sr_instance_id = p_instance_id
    and mrir1.plan_id = mrr1.plan_id
    and mrir1.sr_instance_id = mrr1.sr_instance_id
    and mrir1.organization_id = mrr1.organization_id
    and mrir1.department_id = mrr1.department_id
    and mrir1.resource_id = mrr1.resource_id
    and mrir1.supply_id = mrr1.supply_id
    and mrir1.resource_seq_num = mrr1.resource_seq_num
    and mrir1.operation_seq_num = mrr1.operation_seq_num
    and nvl(mrir1.orig_resource_seq_num, mbp_null_value) = nvl(mrr1.orig_resource_seq_num, mbp_null_value)
    and nvl(mrir1.parent_seq_num, mbp_null_value) = nvl(mrr1.parent_seq_num, mbp_null_value)
    and nvl(mrir1.parent_id, mbp_null_value) = nvl(mrr1.parent_id, mbp_null_value)
    and mrir1.start_date = nvl(mrr1.firm_start_date, mrr1.start_date)
    and mrir1.end_date = nvl(mrr1.firm_end_date, mrr1.end_date)
    and mrr2.plan_id = mrr1.plan_id
    and mrr2.supply_id = mrr1.supply_id
    and mrr2.sr_instance_id = mrr1.sr_instance_id
    and nvl(mrr2.parent_id,2) =2
    and mrir2.plan_id = mrr2.plan_id
    and mrir2.sr_instance_id = mrr2.sr_instance_id
    and mrir2.organization_id = mrr2.organization_id
    and mrir2.department_id = mrr2.department_id
    and mrir2.resource_id = mrr2.resource_id
    and mrir2.supply_id = mrr2.supply_id
    and mrir2.operation_seq_num = mrr2.operation_seq_num
    and mrir2.resource_seq_num = mrr2.resource_seq_num
    and nvl(mrir2.orig_resource_seq_num, mbp_null_value) = nvl(mrr2.orig_resource_seq_num, mbp_null_value)
    and nvl(mrir2.parent_seq_num, mbp_null_value) = nvl(mrr2.parent_seq_num, mbp_null_value)
    and nvl(mrir2.parent_id, mbp_null_value) = nvl(mrr2.parent_id, mbp_null_value)
    and mrir2.start_date = nvl(mrr2.firm_start_date, mrr2.start_date)
    and mrir2.end_date = nvl(mrr2.firm_end_date, mrr2.end_date)
    and mr.plan_id = mrr1.plan_id
    and mr.sr_instance_id = mrr1.sr_instance_id
    and mr.routing_sequence_id = mrr1.routing_sequence_id
    and (((nvl(mr.cfm_routing_flag,2) <> 3 and mrr2.operation_seq_num > mrr1.operation_seq_num)
           or ( nvl(mr.cfm_routing_flag,2) = 3 and mrr2.operation_sequence_id in (
                                       select mon.to_op_seq_id from msc_operation_networks mon
                                       where mon.plan_id = mrr1.plan_id
                                         and mon.sr_instance_id = mrr1.sr_instance_id
                                         and mon.routing_sequence_id = mrr1.routing_sequence_id
                                         and mon.from_op_seq_id = mrr1.operation_sequence_id
          ))) or
          (mrr2.operation_seq_num = mrr1.operation_seq_num and
           mrr2.resource_seq_num > mrr1.resource_seq_num))
     and (mrr2.firm_start_date is not null or
         mrr2.firm_end_date is not null )
     and mrr2.firm_flag in (FIRM_START,FIRM_END,FIRM_START_END,FIRM_START_RES,
              FIRM_END_RES,FIRM_ALL)
   order by mrr2.operation_seq_num, mrr2.resource_seq_num;

   v_lower_start_id number;
   v_lower_start date;
   v_lower_end date;
   v_lower_end_id number;
   v_lower_mtq_id number;

   v_upper_start Date;
   v_upper_start_id number;
   v_upper_end date;
   v_upper_end_id number;
   v_upper_mtq_id number;

   v_prev_op number;
   v_next_op number;


  ll_operation_seq_num varchar2(80);
  ll_schedule_flag number;
  ll_firm_planned_type number;
  ll_theDate date;
  ll_mtq_time number;

  lower_operation_seq_num varchar2(80);
  lower_resource_seq_num varchar2(80);
  lower_transaction_id number;
  lower_schedule_flag number;
  lower_start_date date;
  lower_end_date date;
  lower_mtq_time number;

  upper_operation_seq_num varchar2(80);
  upper_resource_seq_num varchar2(80);
  upper_transaction_id number;
  upper_schedule_flag number;
  upper_start_date date;
  upper_end_date date;
  upper_mtq_time number;

begin
  p_return_status := 'OK';

  -- end_date_greater_than_plan_end
  if p_end_date > p_plan_end_date then -- {
    p_return_status := 'ERROR';
    p_out := 'END_DATE_GREATER_THAN_PLAN_END';
    return;
  end if; -- }

  -- start_date_less_than_plan_start
  if p_start_date < p_plan_start_date then -- {
    p_return_status := 'ERROR';
     p_out := 'START_DATE_LESS_THAN_PLAN_START';
    return;
  end if; -- }

  -- start_date_greater_than_end_date
  if p_start_date > p_end_date then -- {
    p_return_status := 'ERROR';
     p_out := 'START_DATE_GREATER_THAN_END_DATE';
    return;
  end if; -- }

  if ( p_node_type = RES_NODE ) then
    open curr_res;
    fetch curr_res into ll_operation_seq_num, ll_schedule_flag, ll_firm_planned_type, ll_theDate, ll_mtq_time;
    close curr_res;
  else
    open curr_res_inst;
    fetch curr_res_inst into ll_operation_seq_num, ll_schedule_flag, ll_firm_planned_type, ll_theDate, ll_mtq_time;
    close curr_res_inst;
  end if;

  -- associated supply is firmed..cannot be firmed
  if ll_firm_planned_type = 1 then -- {
     p_return_status := 'ERROR';
     p_out := 'FIRM_SUPPLY';
     return;
  end if; -- }

  -- start date is less than sysdate..cannot be firmed
  if p_start_date < ll_thedate then -- {
    p_return_status := 'ERROR';
    --p_out := to_char(ll_theDate,format_mask)|| field_seperator ||null_space||field_seperator||null_space ;
    --5728088, send translated message to pld
    fnd_message.set_name('MSC', 'MSC_GC_START_DT_LT_SYSDATE');
    fnd_message.set_token('START_DATE', to_char(p_start_date,format_mask));
    p_out := fnd_message.get;
    return;
  end if; -- }

  if ( p_node_type = RES_NODE ) then
    open lower_bound;
  else
    open lower_bound_res_inst;
  end if;

  loop  -- {
    if ( p_node_type = RES_NODE ) then -- {
      fetch lower_bound into lower_operation_seq_num, lower_resource_seq_num,
        lower_transaction_id, lower_schedule_flag,
        lower_start_date, lower_end_date, lower_mtq_time;
      exit when lower_bound%notfound;
    else
      fetch lower_bound_res_inst into lower_operation_seq_num, lower_resource_seq_num,
        lower_transaction_id, lower_schedule_flag,
        lower_start_date, lower_end_date, lower_mtq_time;
      exit when lower_bound_res_inst%notfound;
    end if; -- }

    if v_lower_start is not null and v_lower_end is not null then -- {
      exit;
     else
      if ( v_prev_op is null
        and lower_operation_seq_num < ll_operation_seq_num ) then -- {
        v_prev_op := lower_operation_seq_num;
      end if; -- }
      if v_lower_start is null then -- {
        v_lower_start := lower_start_date;
        v_lower_start_id := lower_transaction_id;
      end if; -- }
      if v_lower_end is null then -- {
        v_lower_end := lower_end_date;
        v_lower_end_id := lower_transaction_id;
      end if; -- }
      if v_lower_mtq_id is null then -- {
        if not (v_prev_op is not null and
           lower_operation_seq_num = v_prev_op and
           ll_schedule_flag = 3 and  -- prior
           lower_schedule_flag = 4) then -- {
           if p_start_date <
	      lower_start_date + lower_mtq_time*(lower_end_date - lower_start_date) then -- {
             v_lower_mtq_id := lower_transaction_id;
           end if; -- }
         end if; -- }
       end if; -- }
      end if; -- }
  end loop; -- }
  if ( p_node_type = RES_NODE ) then
    close lower_bound;
  else
    close lower_bound_res_inst;
  end if;

  if ( p_node_type = RES_NODE ) then
    open upper_bound;
  else
    open upper_bound_res_inst;
  end if;
  loop -- {
    if ( p_node_type = RES_NODE ) then
      fetch upper_bound into upper_operation_seq_num, upper_resource_seq_num,
        upper_transaction_id, upper_schedule_flag,
        upper_start_date, upper_end_date;
      exit when upper_bound%notfound;
    else
      fetch upper_bound_res_inst into upper_operation_seq_num, upper_resource_seq_num,
        upper_transaction_id, upper_schedule_flag,
        upper_start_date, upper_end_date;
      exit when upper_bound_res_inst%notfound;
    end if;


    if v_upper_start is not null and v_upper_end is not null then -- {
      exit;
    else
      if v_next_op is null and
        upper_operation_seq_num > ll_operation_seq_num then -- {
        v_next_op := upper_operation_seq_num;
      end if; -- }
      if v_upper_start is null then -- {
        v_upper_start := upper_start_date;
        v_upper_start_id := upper_transaction_id;
      end if; -- }
      if v_upper_end is null then -- {
        v_upper_end := upper_end_date;
        v_upper_end_id := upper_transaction_id;
      end if; -- }
      if v_upper_mtq_id is null then -- {
        if not (v_next_op is not null and
          upper_operation_seq_num = v_next_op and
          ll_schedule_flag = 4 and  --next
          upper_schedule_flag = 3) then -- {
          if upper_start_date < p_start_date +
	    ll_mtq_time* (p_end_date - p_start_date) then -- {
            v_upper_mtq_id := upper_transaction_id;
          end if; -- }
        end if; -- }
      end if; --}
    end if; -- }
  end loop; -- }
  if ( p_node_type = RES_NODE ) then
    close upper_bound;
  else
    close upper_bound_res_inst;
  end if;

  if v_lower_start is not null and p_start_date < v_lower_start then -- {
    --p_out := to_char(v_lower_start,format_mask) || field_seperator|| to_char(v_lower_start_id);
    --5728088, send translated message to pld
    fnd_message.set_name('MSC', 'MSC_GC_START_DT_LT_CONS_DATE');
    fnd_message.set_token('DATE1', to_char(v_lower_start,format_mask));
    fnd_message.set_token('TRX_ID', to_char(v_lower_start_id));
    p_out := fnd_message.get;
    p_return_status := 'ERROR';
  else
    p_out := null_space || field_seperator || null_space;
  end if; -- }

  if v_upper_start is not null and p_start_date > v_upper_start then -- {
     p_out := p_out || field_seperator || to_char(v_upper_start,format_mask)
       || field_seperator || to_char(v_upper_start_id);
     p_return_status := 'ERROR';
  else
     p_out := p_out || field_seperator || null_space || field_seperator || null_space;
  end if; -- }
  if p_return_status = 'ERROR' then -- {
     p_out := p_out || field_seperator || null_space || field_seperator || null_space;
     p_out := p_out || field_seperator || null_space || field_seperator || null_space;
     return;
  end if; -- }

  if v_lower_end is not null and p_end_date < v_lower_end then -- {
     --p_out := p_out || field_seperator|| to_char(v_lower_end,format_mask)|| field_seperator || to_char(v_lower_end_id);
    --5728088, send translated message to pld
     fnd_message.set_name('MSC', 'MSC_GC_END_DT_LT_CONS_DATE');
     fnd_message.set_token('DATE1', to_char(v_lower_end,format_mask));
     fnd_message.set_token('TRX_ID', to_char(v_lower_end_id));
     p_out := fnd_message.get;
     p_return_status := 'ERROR';
  end if; -- }

  if v_upper_end is not null and p_end_date > v_upper_end then  -- {
     --p_out := p_out || field_seperator || to_char(v_upper_end,format_mask)|| field_seperator || to_char(v_upper_end_id);
    --5728088, send translated message to pld
     fnd_message.set_name('MSC', 'MSC_GC_END_DT_LT_CONS_DATE');
     fnd_message.set_token('DATE1', to_char(v_upper_end,format_mask));
     fnd_message.set_token('TRX_ID', to_char(v_lower_end_id));
     p_out := fnd_message.get;
     p_return_status := 'ERROR';
  end if; -- }

  if p_return_status = 'ERROR' then -- {
     return;
  end if; -- }

  if v_lower_mtq_id is not null or v_upper_mtq_id is not null then -- {
     --p_return_status := 'WARNING';
     --p_out := nvl(to_char(v_lower_mtq_id), null_space) ||field_seperator || nvl(to_char(v_upper_mtq_id), null_space);
     --5728088 commented, since we dont need to show warnings
     return;
  end if; -- }
end validateTime;

-- public API
-- 1) if a res is firmed, firm the resource, firm the simu res, and firm ALL the res instances
-- 2) if a res inst is firmed, firm the res inst and firm the res also..

procedure firmResourcePub (p_plan_id number, p_transaction_id number,
  p_instance_id number, p_firm_type number, p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2, p_node_type number) is

  l_firm_type number;
  l_supply_id number;
  l_firm_start date;
  l_firm_end date;
  l_start date;
  l_end date;

  ll_res_inst_trx_id number;
  ll_res_trx_id number;

  vv_res_inst_inst_id number_arr;
  vv_res_inst_trx_id number_arr;

BEGIN
  put_line(' firmResourcePub in ');
    p_return_status := 'OK';

    --firm the res instance..
    if ( p_node_type = RES_INST_NODE ) then -- {
      ll_res_inst_trx_id := p_transaction_id;
      ll_res_trx_id := get_parent_res_trx_id(p_plan_id, p_instance_id, ll_res_inst_trx_id);
    else
      ll_res_trx_id := p_transaction_id;
    end if; -- }
  put_line('ll_res_trx_id ll_res_inst_trx_id '||ll_res_trx_id||' - '||ll_res_inst_trx_id);

    -- lock the mrr and getData
    msc_gantt_utils.lockReqNGetData(p_plan_id, p_instance_id, ll_res_trx_id,
      l_firm_type, l_supply_id, l_start, l_end, l_firm_start, l_firm_end,
      p_return_status, p_out);

    if p_return_status = 'ERROR' then
      return ;
    end if;


    -- update requirement
    msc_gantt_utils.updateReq(p_plan_id, p_instance_id, ll_res_trx_id,
      p_firm_type, l_start, l_end, l_firm_start, l_firm_end, FIRM_MRR);

    -- update requirement
    msc_gantt_utils.firmReqInst(p_plan_id, p_instance_id, ll_res_trx_id, ll_res_inst_trx_id);

    -- update requirement's supply
    msc_gantt_utils.updateSupplies(p_plan_id, l_supply_id, TOUCH_SUPPLY);

    -- update the simultaneous resource for a given res trans id
    msc_gantt_utils.updateReqSimu(p_plan_id, p_instance_id, ll_res_trx_id,
      p_firm_type, l_start, l_end, l_firm_start, l_firm_end, FIRM_MRR, p_return_status, p_out);

  put_line(' firmResourcePub out ');
end firmResourcePub;

procedure firmResourceSeqPub(p_plan_id number,
  p_trx_list varchar2, p_firm_type number,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2,
  p_node_type number) is

  l_start date;
  l_end date;
  l_supply_id number;
  l_firm_type number;
  l_firm_start date;
  l_firm_end date;
  l_batch_number number;
  l_group_sequence_id number;
  l_group_sequence_number number;

  l_inst_id number;
  l_trx_id number;
  ll_res_trx_id number;

  p_new_group_seq_id number;
  p_new_group_seq_number number;

  v_len number;
  i number := 1;
  l_one_record varchar2(100);

begin
  put_line(' firmResourceSeqPub in ');
    p_return_status := 'OK';

    v_len := length(p_trx_list);
    while v_len > 1 loop
      l_one_record := substr(p_trx_list,instr(p_trx_list,'(',1,i)+1,
          instr(p_trx_list,')',1,i)-instr(p_trx_list,'(',1,i)-1);
      l_inst_id := to_number(substr(l_one_record,1,instr(l_one_record,',')-1));
      l_trx_id := to_number(substr(l_one_record,instr(l_one_record,',')+1));
      ll_res_trx_id := l_trx_id;


      if ( p_node_type = RES_INST_NODE ) then -- {
        ll_res_trx_id := get_parent_res_trx_id(p_plan_id, l_inst_id, l_trx_id);
      end if; -- }

      if ( p_new_group_seq_id is null ) then
        -- get the new group seq id and number
        select max(nvl(mrr.group_sequence_id,0))+1
          into p_new_group_seq_id
        from msc_resource_requirements mrr
        where mrr.plan_id = p_plan_id
          and mrr.sr_instance_id = l_inst_id;
	p_new_group_seq_number := 0;
      end if;
      p_new_group_seq_number := p_new_group_seq_number + 10;

      -- lock the mrr and getNewData
      msc_gantt_utils.lockReqNGetData(p_plan_id, l_inst_id, ll_res_trx_id,
        l_firm_type, l_supply_id, l_start, l_end, l_firm_start, l_firm_end,
        p_return_status, p_out);

      update msc_resource_requirements
        set group_sequence_id = decode(p_firm_type,
	                               0, to_number(null),
					p_new_group_seq_id),
	  group_sequence_number = decode(p_firm_type,
	                               0, to_number(null),
					p_new_group_seq_number)
	where plan_id = p_plan_id
	  and sr_instance_id = l_inst_id
	  and transaction_id = ll_res_trx_id ;

      if ( p_out is null ) then
        p_out := '('|| l_inst_id || COMMA_SEPARATOR
	  || l_trx_id || COMMA_SEPARATOR
	  || p_new_group_seq_id || COMMA_SEPARATOR
	  || p_new_group_seq_number ||')';
      else
        p_out := p_out || COMMA_SEPARATOR ||
	  '('||l_inst_id || COMMA_SEPARATOR
	  || l_trx_id || COMMA_SEPARATOR
	  || p_new_group_seq_id || COMMA_SEPARATOR
	  || p_new_group_seq_number || ')';
      end if;

      i := i+1;
      v_len := v_len - length(l_one_record)-3;
    end loop;

  put_line(' firmResourceSeqPub out ');
end firmResourceSeqPub;

procedure firmResourceBatchPub(p_plan_id number,
  p_transaction_id number, p_instance_id number, p_firm_type number,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2,
  p_node_type number) is

  l_start date;
  l_end date;
  l_supply_id number;
  l_firm_type number;
  l_firm_start date;
  l_firm_end date;
  l_batch_number number;
  l_group_sequence_id number;
  l_group_sequence_number number;

begin
  if ( p_node_type = RES_NODE ) then -- {
    -- in both the cases, res or res inst move, move the simultaneous res req
    open res_req_info(p_plan_id, p_instance_id, p_transaction_id);
    fetch res_req_info into l_firm_type, l_firm_start, l_firm_end,
      l_batch_number, l_group_sequence_id, l_group_sequence_number;
    close res_req_info;

    msc_gantt_utils.updateBatchReq(p_plan_id, p_instance_id, l_batch_number,
      to_date(null), to_date(null), p_firm_type, FIRM_MRR, p_return_status, p_out);
  else
    open res_inst_req_info(p_plan_id, p_instance_id, p_instance_id);
    fetch res_inst_req_info into l_batch_number;
    close res_inst_req_info;

    msc_gantt_utils.updateBatchInstReq(p_plan_id, p_instance_id, l_batch_number,
      to_date(null), to_date(null), p_firm_type, FIRM_MRR, p_return_status, p_out);
  end if; -- }
end firmResourceBatchPub;


procedure firmSupplyPub(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_firm_type number,
  p_start_date date, p_end_date date,
  p_plan_start_date date, p_plan_end_date date,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2,
  p_validate_flag boolean default true,
  p_node_type number) is

begin
  p_return_status := 'OK';

  -- update requirement's supply
  msc_gantt_utils.updateSupplies(p_plan_id, p_transaction_id, FIRM_SUPPLY, p_firm_type);

  --pabram ... need to verify
end firmSupplyPub;

procedure getAltResource(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_name OUT NOCOPY varchar2, p_id OUT NOCOPY varchar2,
  p_node_type number default null,
  p_from_form number default null) is

  cursor c_alt_res_res (p_plan number, p_inst number, p_trx number)is
  select distinct mor.alternate_number || COLON_SEPARATOR ||
    msc_get_name.resource_code(mor.resource_id, mrr.department_id,
      mrr.organization_id, mrr.plan_id, mrr.sr_instance_id),
    mor.resource_id,
    mbp_null_value res_instance_id,
    mbp_null_value_char serial_number,
    mor.alternate_number
  from msc_operation_resources mor,
    msc_resource_requirements mrr
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.transaction_id = p_trx
    and mor.plan_id = mrr.plan_id
    and mor.routing_sequence_id = mrr.routing_sequence_id
    and mor.sr_instance_id = mrr.sr_instance_id
    and mor.operation_sequence_id = mrr.operation_sequence_id
    and mor.resource_seq_num = mrr.resource_seq_num
    and mor.alternate_number <> mrr.alternate_num
    and mor.principal_flag <> 2
  union all --5478582 bugfix
  select distinct mjor.alternate_num || COLON_SEPARATOR ||
    msc_get_name.resource_code(mjor.resource_id, mrr.department_id,
      mrr.organization_id, mrr.plan_id, mrr.sr_instance_id),
    mjor.resource_id,
    mbp_null_value res_instance_id,
    mbp_null_value_char serial_number,
    mjor.alternate_num
  from msc_job_op_resources mjor,
    msc_resource_requirements mrr
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.transaction_id = p_trx
    and mrr.routing_sequence_id is null
    and mjor.plan_id = mrr.plan_id
    and mjor.transaction_id = mrr.supply_id
    and mjor.sr_instance_id = mrr.sr_instance_id
    and mjor.operation_seq_num = mrr.operation_seq_num
    and mjor.resource_seq_num = mrr.resource_seq_num
    and mjor.alternate_num <> mrr.alternate_num
    and mjor.resource_id <> -1
    and mjor.principal_flag <> 2;

  cursor c_alt_res_inst (p_plan number, p_inst number, p_trx number)is
  select distinct mor.alternate_number
    || COLON_SEPARATOR || msc_gantt_utils.getDeptResInstCode(mdri.plan_id,
      mdri.sr_instance_id, mdri.organization_id, mdri.department_id,
      mdri.resource_id, mdri.res_instance_id, mdri.serial_number),
    mdri.resource_id,
    mdri.res_instance_id,
    mdri.serial_number,
    mor.alternate_number
  from msc_operation_resources mor,
    msc_resource_requirements mrr,
    msc_dept_res_instances mdri
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.transaction_id = p_trx
    and mrr.assigned_units = 1
    and mor.plan_id = mrr.plan_id
    and mor.routing_sequence_id = mrr.routing_sequence_id
    and mor.sr_instance_id = mrr.sr_instance_id
    and mor.operation_sequence_id = mrr.operation_sequence_id
    and mor.resource_seq_num = mrr.resource_seq_num
    and mor.alternate_number <> mrr.alternate_num
    and mor.principal_flag <> 2
    and mor.plan_id = mdri.plan_id
    and mor.sr_instance_id = mdri.sr_instance_id
    and mor.resource_id = mdri.resource_id
  union all --5478582 bugfix
  select distinct mjor.alternate_num
    || COLON_SEPARATOR || msc_gantt_utils.getDeptResInstCode(mdri.plan_id,
      mdri.sr_instance_id, mdri.organization_id, mdri.department_id,
      mdri.resource_id, mdri.res_instance_id, mdri.serial_number),
    mdri.resource_id,
    mdri.res_instance_id,
    mdri.serial_number,
    mjor.alternate_num
  from msc_job_op_resources mjor,
    msc_resource_requirements mrr,
    msc_dept_res_instances mdri
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.transaction_id = p_trx
    and mrr.routing_sequence_id is null
    and mrr.assigned_units = 1
    and mjor.plan_id = mrr.plan_id
    and mjor.transaction_id = mrr.supply_id
    and mjor.sr_instance_id = mrr.sr_instance_id
    and mjor.operation_seq_num = mrr.operation_seq_num
    and mjor.resource_seq_num = mrr.resource_seq_num
    and mjor.alternate_num <> mrr.alternate_num
    and mjor.resource_id <> -1
    and mjor.principal_flag <> 2
    and mjor.plan_id = mdri.plan_id
    and mjor.sr_instance_id = mdri.sr_instance_id
    and mjor.resource_id = mdri.resource_id;


  cursor c_alt_inst_res (p_plan number, p_inst number, p_trx number)is
  select distinct mor.alternate_number
   || COLON_SEPARATOR ||msc_get_name.resource_code(mor.resource_id, mrr.department_id,
     mrr.organization_id, mrr.plan_id, mrr.sr_instance_id),
    mor.resource_id,
    mbp_null_value res_instance_id,
    mbp_null_value_char serial_number,
    mor.alternate_number
  from msc_operation_resources mor,
    msc_resource_requirements mrr
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.transaction_id = p_trx
    and mor.plan_id = mrr.plan_id
    and mor.routing_sequence_id = mrr.routing_sequence_id
    and mor.sr_instance_id = mrr.sr_instance_id
    and mor.operation_sequence_id = mrr.operation_sequence_id
    and mor.resource_seq_num = mrr.resource_seq_num
    and mor.alternate_number <> mrr.alternate_num
    and mor.principal_flag <> 2
  union all --5478582 bugfix
  select distinct mjor.alternate_num
   || COLON_SEPARATOR ||msc_get_name.resource_code(mjor.resource_id, mrr.department_id,
     mrr.organization_id, mrr.plan_id, mrr.sr_instance_id),
    mjor.resource_id,
    mbp_null_value res_instance_id,
    mbp_null_value_char serial_number,
    mjor.alternate_num
  from msc_job_op_resources mjor,
    msc_resource_requirements mrr
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.transaction_id = p_trx
    and mrr.routing_sequence_id is null
    and mjor.plan_id = mrr.plan_id
    and mjor.transaction_id = mrr.supply_id
    and mjor.sr_instance_id = mrr.sr_instance_id
    and mjor.operation_seq_num = mrr.operation_seq_num
    and mjor.resource_seq_num = mrr.resource_seq_num
    and mjor.alternate_num <> mrr.alternate_num
    and mjor.resource_id <> -1
    and mjor.principal_flag <> 2;

  cursor c_alt_inst_inst (p_plan number, p_inst number, p_trx number,
    p_res_instance_id number, p_serial_number varchar2, p_equipment_item_id number )is
  select distinct mor.alternate_number ||':'||msc_gantt_utils.getDeptResInstCode(mdri.plan_id,
    mdri.sr_instance_id, mdri.organization_id, mdri.department_id,
    mdri.resource_id, mdri.res_instance_id, mdri.serial_number),
    mdri.resource_id,
    mdri.res_instance_id,
    mdri.serial_number,
    mor.alternate_number
  from msc_operation_resources mor,
    msc_resource_requirements mrr,
    msc_dept_res_instances mdri
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.transaction_id = p_trx
    and mor.plan_id = mrr.plan_id
    and mor.routing_sequence_id = mrr.routing_sequence_id
    and mor.sr_instance_id = mrr.sr_instance_id
    and mor.operation_sequence_id = mrr.operation_sequence_id
    and mor.resource_seq_num = mrr.resource_seq_num
    and mor.alternate_number <> mrr.alternate_num
    and mor.principal_flag <> 2
    and mor.plan_id = mdri.plan_id
    and mor.sr_instance_id = mdri.sr_instance_id
    and mor.resource_id = mdri.resource_id
  union all --5513960 bugfix
  select distinct mrr.alternate_num ||':'||msc_gantt_utils.getDeptResInstCode(mdri.plan_id,
    mdri.sr_instance_id, mdri.organization_id, mdri.department_id,
    mdri.resource_id, mdri.res_instance_id, mdri.serial_number),
    mdri.resource_id,
    mdri.res_instance_id,
    mdri.serial_number,
    mrr.alternate_num
  from msc_resource_requirements mrr,
    msc_dept_res_instances mdri
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.transaction_id = p_trx
    and mrr.plan_id = mdri.plan_id
    and mrr.sr_instance_id = mdri.sr_instance_id
    and mrr.organization_id = mdri.organization_id
    and mrr.department_id = mdri.department_id
    and mrr.resource_id = mdri.resource_id
    and nvl(mdri.serial_number,mbp_null_value_char) <> nvl(p_serial_number,mbp_null_value_char)
    --and nvl(mdri.equipment_item_id,mbp_null_value) <> nvl(p_equipment_item_id,mbp_null_value)
  union all --5478582 bugfix
  select distinct mjor.alternate_num ||':'||msc_gantt_utils.getDeptResInstCode(mdri.plan_id,
    mdri.sr_instance_id, mdri.organization_id, mdri.department_id,
    mdri.resource_id, mdri.res_instance_id, mdri.serial_number),
    mdri.resource_id,
    mdri.res_instance_id,
    mdri.serial_number,
    mjor.alternate_num
  from msc_job_op_resources mjor,
    msc_resource_requirements mrr,
    msc_dept_res_instances mdri
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.transaction_id = p_trx
    and mrr.routing_sequence_id is null
    and mjor.plan_id = mrr.plan_id
    and mjor.transaction_id = mrr.supply_id
    and mjor.sr_instance_id = mrr.sr_instance_id
    and mjor.operation_seq_num = mrr.operation_seq_num
    and mjor.resource_seq_num = mrr.resource_seq_num
    and mjor.alternate_num <> mrr.alternate_num
    and mjor.resource_id <> -1
    and mjor.principal_flag <> 2
    and mjor.plan_id = mdri.plan_id
    and mjor.sr_instance_id = mdri.sr_instance_id
    and mjor.resource_id = mdri.resource_id;

  cursor flag (p_plan number, p_inst number, p_trx number)is
  select nvl(mrr.firm_flag,no_firm)
  from msc_resource_requirements mrr
  where mrr.plan_id = p_plan
    and  mrr.transaction_id = p_trx
    and  mrr.sr_instance_id = p_inst;

  cursor activity_c (p_plan number, p_inst number, p_trx number) is
  select mors.activity_group_id, mrr.routing_sequence_id,
    mrr.operation_sequence_id, mrr.resource_seq_num
  from msc_operation_resource_seqs mors,
    msc_resource_requirements mrr
  where mrr.plan_id = p_plan
    and mrr.transaction_id = p_trx
    and mrr.sr_instance_id = p_inst
    and mors.plan_id = mrr.plan_id
    and mors.routing_sequence_id = mrr.routing_sequence_id
    and mors.operation_sequence_id = mrr.operation_sequence_id
    and mors.resource_seq_num = mrr.resource_seq_num
    and mors.sr_instance_id = mrr.sr_instance_id;

  --5513960 bugfix
  cursor c_res_inst_info (p_plan number, p_inst number, p_trx number)is
  select mrir.res_instance_id, mrir.serial_number, mrir.equipment_item_id
  from msc_resource_instance_reqs mrir
  where mrir.plan_id = p_plan
    and mrir.sr_instance_id = p_inst
    and mrir.res_inst_transaction_id = p_trx;

  ll_res_instance_id number;
  ll_serial_number varchar2(30);
  ll_equipment_item_id number;
  --5513960 bugfix ends

 temp_name varchar2(240);
 temp_id number;
 temp_inst_id number;
 temp_serial_number varchar2(40);
 temp_flag number;
 alt_number number;
 rowcount number := 0;
 l_rout_seq number;
 l_op_seq number;
 l_res_seq number;
 l_total_seqs number;
 l_avail_seqs number;
 l_act_group number;
 l_flag varchar2(5);

 ll_res_inst_trx_id number;
 ll_res_trx_id number;

 l_query_id number;

begin
  put_line('in getAltResource');
  --firm the res instance..
  if ( p_node_type = RES_INST_NODE ) then -- {
    ll_res_inst_trx_id := p_transaction_id;
    ll_res_trx_id := get_parent_res_trx_id(p_plan_id, p_instance_id, ll_res_inst_trx_id);

    --5513960 bugfix
    open c_res_inst_info (p_plan_id, p_instance_id, ll_res_inst_trx_id);
    fetch c_res_inst_info into ll_res_instance_id, ll_serial_number, ll_equipment_item_id;
    close c_res_inst_info;
    --5513960 bugfix ends

  else
    ll_res_trx_id := p_transaction_id;
  end if; -- }

  if ( nvl(p_from_form,-1) = sys_yes ) then
    l_query_id := getMFQSequence();
  else
    l_query_id := mbp_null_value;
  end if;

  --get corresponding info about this tranx
  open activity_c(p_plan_id, p_instance_id, ll_res_trx_id);
  fetch activity_c into l_act_group,l_rout_seq, l_op_seq, l_res_seq;
  close activity_c;

/*
  if l_act_group is not null then -- {
    select count(*)
    into l_total_seqs
    from (select distinct mors.resource_seq_num
          from  msc_operation_resource_seqs mors
          where mors.plan_id = p_plan_id
            and mors.routing_sequence_id = l_rout_seq
            and mors.operation_sequence_id = l_op_seq
            and mors.sr_instance_id = p_instance_id
            and mors.activity_group_id = l_act_group);

      select count(*)
      into l_avail_seqs
      from (select distinct mors.resource_seq_num
            from msc_operation_resource_seqs mors,
              msc_operation_resources mor
            where mors.plan_id = p_plan_id
              and mors.sr_instance_id = p_instance_id
              and mors.operation_sequence_id = l_op_seq
              and mors.routing_sequence_id = l_rout_seq
              and mors.activity_group_id = l_act_group
              and mor.plan_id = p_plan_id
              and mor.routing_sequence_id = mors.routing_sequence_id
              and mor.operation_sequence_id = mors.operation_sequence_id
              and mor.sr_instance_id = p_instance_id
              and mor.resource_seq_num = mors.resource_seq_num
              and mor.alternate_number = alt_number);

      if l_avail_seqs = l_total_seqs then -- {
        l_flag := 'Y';
      else
        l_flag := 'N';
      end if; -- }

  else
    l_flag := 'Y';
  end if; -- }

*/
    l_flag := 'Y'; -- pabram need to check with emily the commented code , and this stmt

  if ( nvl(p_node_type, RES_NODE) = RES_NODE ) then -- {

    put_line(' finding alternates for a resource node ');
    -- res to res
    open c_alt_res_res(p_plan_id, p_instance_id, ll_res_trx_id);
    loop -- {
      fetch c_alt_res_res into temp_name, temp_id, temp_inst_id, temp_serial_number, alt_number;
      exit when c_alt_res_res%notfound;
      rowcount := rowcount +1;
      put_line(' c_alt_res_res '|| temp_name );
      if p_name is not null then -- {
        p_name := p_name || field_seperator || temp_name;
        p_id := p_id || field_seperator || temp_id || field_seperator
	  ||  temp_inst_id || field_seperator || temp_serial_number
	  || field_seperator || alt_number || field_seperator || l_flag;
      else
        p_name := temp_name;
        p_id := temp_id || field_seperator ||  temp_inst_id || field_seperator
	  || temp_serial_number|| field_seperator || alt_number || field_seperator || l_flag;
      end if; -- }

      if ( l_query_id <> mbp_null_value ) then
        populateResIntoMfq(l_query_id, temp_id, temp_inst_id, temp_serial_number, temp_name, alt_number);
      end if;

    end loop; -- }
    close c_alt_res_res;

    -- res to res inst
    open c_alt_res_inst(p_plan_id, p_instance_id, ll_res_trx_id);
    loop -- {
      fetch c_alt_res_inst into temp_name, temp_id, temp_inst_id, temp_serial_number, alt_number;
      exit when c_alt_res_inst%notfound;
      rowcount := rowcount +1;
      put_line(' c_alt_res_inst '|| temp_name );
      if p_name is not null then -- {
        p_name := p_name || field_seperator || temp_name;
        p_id := p_id || field_seperator || temp_id || field_seperator
	  ||  temp_inst_id || field_seperator || temp_serial_number
	  || field_seperator || alt_number || field_seperator || l_flag;
      else
        p_name := temp_name;
        p_id := temp_id || field_seperator ||  temp_inst_id || field_seperator
	  || temp_serial_number|| field_seperator || alt_number || field_seperator || l_flag;
      end if; -- }

      if ( l_query_id <> mbp_null_value ) then
        populateResIntoMfq(l_query_id, temp_id, temp_inst_id, temp_serial_number, temp_name, alt_number);
      end if;

    end loop; -- }
    close c_alt_res_inst;

  else
    put_line(' finding alternates for a resource instance node ');
    -- inst to res
    open c_alt_inst_res(p_plan_id, p_instance_id, ll_res_trx_id);
    loop -- {
      fetch c_alt_inst_res into temp_name, temp_id, temp_inst_id, temp_serial_number, alt_number;
      exit when c_alt_inst_res%notfound;
      rowcount := rowcount +1;
      put_line(' c_alt_inst_res '|| temp_name );
      if p_name is not null then -- {
        p_name := p_name || field_seperator || temp_name;
        p_id := p_id || field_seperator || temp_id || field_seperator
	  ||  temp_inst_id || field_seperator || temp_serial_number
	  || field_seperator || alt_number || field_seperator || l_flag;
      else
        p_name := temp_name;
        p_id := temp_id || field_seperator ||  temp_inst_id || field_seperator
	  || temp_serial_number|| field_seperator || alt_number || field_seperator || l_flag;
      end if; -- }

      if ( l_query_id <> mbp_null_value ) then
        populateResIntoMfq(l_query_id, temp_id, temp_inst_id, temp_serial_number, temp_name, alt_number);
      end if;

    end loop; -- }
    close c_alt_inst_res;

    -- inst to inst
    open c_alt_inst_inst(p_plan_id, p_instance_id, ll_res_trx_id,
	ll_res_instance_id, ll_serial_number, ll_equipment_item_id);
    loop -- {
      fetch c_alt_inst_inst into temp_name, temp_id, temp_inst_id, temp_serial_number, alt_number;
      exit when c_alt_inst_inst%notfound;
      rowcount := rowcount +1;
      put_line(' c_alt_inst_inst '|| temp_name );
      if p_name is not null then -- {
        p_name := p_name || field_seperator || temp_name;
        p_id := p_id || field_seperator || temp_id || field_seperator
	  ||  temp_inst_id || field_seperator || temp_serial_number
	  || field_seperator || alt_number || field_seperator || l_flag;
      else
        p_name := temp_name;
        p_id := temp_id || field_seperator ||  temp_inst_id || field_seperator
	  || temp_serial_number|| field_seperator || alt_number || field_seperator || l_flag;
      end if; -- }

      if ( l_query_id <> mbp_null_value ) then
        populateResIntoMfq(l_query_id, temp_id, temp_inst_id, temp_serial_number, temp_name, alt_number);
      end if;

    end loop; -- }
    close c_alt_inst_inst;

  end if; -- }

  temp_flag := 0;
  open flag(p_plan_id, p_instance_id, ll_res_trx_id);
  fetch flag into temp_flag;
  close flag;

  if temp_flag >= 8 then
    temp_flag := 0;
  end if;

  p_name := temp_flag || field_seperator ||to_char(rowcount) || field_seperator || p_name;
  p_id := to_char(rowcount) || field_seperator || p_id;

  if ( l_query_id <> mbp_null_value ) then
    p_id := l_query_id;
  end if;

  put_line('out getAltResource');
end getAltResource;

procedure getSimuResource(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_name OUT NOCOPY varchar2, p_id OUT NOCOPY varchar2,
  p_node_type number default null) IS

  cursor c_simu_res_res(p_plan_id number, p_inst_id number, p_trx_id number ) is
  select msc_get_name.resource_code(mor.resource_id, mrr.department_id,
      mrr.organization_id, mrr.plan_id, mrr.sr_instance_id) resource_code,
    mor.resource_id resource_id,
    mbp_null_value res_instance_id,
    mbp_null_value_char serial_number
  from msc_operation_resources mor,
    msc_resource_requirements mrr
  where  mrr.plan_id = p_plan_id
    and mrr.transaction_id = p_trx_id
    and mrr.sr_instance_id = p_inst_id
    and mor.plan_id = mrr.plan_id
    and mor.sr_instance_id = mrr.sr_instance_id
    and mor.routing_sequence_id = mrr.routing_sequence_id
    and mor.operation_sequence_id = mrr.operation_sequence_id
    and mor.resource_seq_num = mrr.resource_seq_num
    and mor.alternate_number = mrr.alternate_num
    and mor.resource_id <> mrr.resource_id;

  cursor c_simu_res_inst(p_plan number, p_inst number, p_trx number)is
  select mor.alternate_number ||':'||msc_gantt_utils.getDeptResInstCode(mdri.plan_id,
    mdri.sr_instance_id, mdri.organization_id, mdri.department_id,
    mdri.resource_id, mdri.res_instance_id, mdri.serial_number) resource_code,
    mdri.resource_id,
    mdri.res_instance_id,
    mdri.serial_number
  from msc_operation_resources mor,
    msc_resource_requirements mrr,
    msc_dept_res_instances mdri
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.transaction_id = p_trx
    and mor.plan_id = mrr.plan_id
    and mor.sr_instance_id = mrr.sr_instance_id
    and mor.routing_sequence_id = mrr.routing_sequence_id
    and mor.operation_sequence_id = mrr.operation_sequence_id
    and mor.resource_seq_num = mrr.resource_seq_num
    and mor.alternate_number = mrr.alternate_num
    and mor.resource_id <> mrr.resource_id
    and mor.plan_id = mdri.plan_id
    and mor.sr_instance_id = mdri.sr_instance_id
    and mor.resource_id = mdri.resource_id;

  cursor c_simu_inst_res (p_plan number, p_inst number, p_trx number)is
  select mor.alternate_number ||':'||msc_get_name.resource_code(mor.resource_id, mrr.department_id,
    mrr.organization_id, mrr.plan_id, mrr.sr_instance_id) resource_code,
    mor.resource_id,
    mbp_null_value res_instance_id,
    mbp_null_value_char serial_number
  from msc_operation_resources mor,
    msc_resource_requirements mrr
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.transaction_id = p_trx
    and mor.plan_id = mrr.plan_id
    and mor.sr_instance_id = mrr.sr_instance_id
    and mor.routing_sequence_id = mrr.routing_sequence_id
    and mor.operation_sequence_id = mrr.operation_sequence_id
    and mor.resource_seq_num = mrr.resource_seq_num
    and mor.alternate_number = mrr.alternate_num
    and mor.resource_id <> mrr.resource_id;

  cursor c_simu_inst_inst (p_plan number, p_inst number, p_trx number)is
  select mor.alternate_number ||':'||msc_gantt_utils.getDeptResInstCode(mdri.plan_id,
    mdri.sr_instance_id, mdri.organization_id,
    mdri.department_id, mdri.resource_id, mdri.res_instance_id, mdri.serial_number) resource_code,
    mdri.resource_id,
    mdri.res_instance_id,
    mdri.serial_number
  from msc_operation_resources mor,
    msc_resource_requirements mrr,
    msc_dept_res_instances mdri
  where mrr.plan_id = p_plan
    and mrr.sr_instance_id = p_inst
    and mrr.transaction_id = p_trx
    and mor.plan_id = mrr.plan_id
    and mor.routing_sequence_id = mrr.routing_sequence_id
    and mor.sr_instance_id = mrr.sr_instance_id
    and mor.operation_sequence_id = mrr.operation_sequence_id
    and mor.resource_seq_num = mrr.resource_seq_num
    and mor.alternate_number = mrr.alternate_num
    and mor.resource_id <> mrr.resource_id
    and mor.plan_id = mdri.plan_id
    and mor.sr_instance_id = mdri.sr_instance_id
    and mor.resource_id = mdri.resource_id;

  rowcount number := 0;

 ll_res_inst_trx_id number;
 ll_res_trx_id number;

begin
  --firm the res instance..
  if ( p_node_type = RES_INST_NODE ) then -- {
    ll_res_inst_trx_id := p_transaction_id;
    ll_res_trx_id := get_parent_res_trx_id(p_plan_id, p_instance_id, ll_res_inst_trx_id);
  else
    ll_res_trx_id := p_transaction_id;
  end if; -- }

  if ( nvl(p_node_type, RES_NODE) = RES_NODE ) then -- {

    for c_simu_res_res_row in c_simu_res_res(p_plan_id, p_instance_id, ll_res_trx_id)
    loop -- {
      rowcount := rowcount +1;
      if p_name is not null then -- {
        p_name := p_name || field_seperator || c_simu_res_res_row.resource_code;
        p_id := p_id || field_seperator || c_simu_res_res_row.resource_id;
	--|| field_seperator || c_simu_res_res_row.res_instance_id
	--|| field_seperator || c_simu_res_res_row.serial_number;
        --4710508, res_instance_id, serial_number is not required by client
      else
        p_name := c_simu_res_res_row.resource_code;
        p_id := c_simu_res_res_row.resource_id;
	  --|| field_seperator || c_simu_res_res_row.res_instance_id
  	  --|| field_seperator || c_simu_res_res_row.serial_number;
      end if; -- }
    end loop; -- }

    -- only resources need to be sent to client per pm
    /*
    for c_simu_res_inst_row in c_simu_res_inst(p_plan_id, p_instance_id, ll_res_trx_id)
    loop -- {
      rowcount := rowcount +1;
      if p_name is not null then -- {
        p_name := p_name || field_seperator || c_simu_res_inst_row.resource_code;
        p_id := p_id || field_seperator || c_simu_res_inst_row.resource_id
	  || field_seperator || c_simu_res_inst_row.res_instance_id
  	  || field_seperator || c_simu_res_inst_row.serial_number;
      else
        p_name := c_simu_res_inst_row.resource_code;
        p_id := c_simu_res_inst_row.resource_id
          || field_seperator || c_simu_res_inst_row.res_instance_id
  	  || field_seperator || c_simu_res_inst_row.serial_number;
      end if; -- }
    end loop; -- }
    */
  else -- instance node
    null;
    -- only resources need to be sent to client per pm
    /*
    for c_simu_inst_res_row in c_simu_inst_res(p_plan_id, p_instance_id, ll_res_inst_trx_id)
    loop -- {
      rowcount := rowcount +1;
      if p_name is not null then -- {
        p_name := p_name || field_seperator || c_simu_inst_res_row.resource_code;
        p_id := p_id || field_seperator || c_simu_inst_res_row.resource_id
	  || field_seperator || c_simu_inst_res_row.res_instance_id
  	  || field_seperator || c_simu_inst_res_row.serial_number;
      else
        p_name := c_simu_inst_res_row.resource_code;
        p_id := c_simu_inst_res_row.resource_id
          || field_seperator || c_simu_inst_res_row.res_instance_id
  	  || field_seperator || c_simu_inst_res_row.serial_number;
      end if; -- }
    end loop; -- }

    for c_simu_inst_inst_row in c_simu_inst_inst(p_plan_id, p_instance_id, ll_res_inst_trx_id)
    loop -- {
      rowcount := rowcount +1;
      if p_name is not null then -- {
        p_name := p_name || field_seperator || c_simu_inst_inst_row.resource_code;
        p_id := p_id || field_seperator || c_simu_inst_inst_row.resource_id
	  || field_seperator || c_simu_inst_inst_row.res_instance_id
  	  || field_seperator || c_simu_inst_inst_row.serial_number;
      else
        p_name := c_simu_inst_inst_row.resource_code;
        p_id := c_simu_inst_inst_row.resource_id
          || field_seperator || c_simu_inst_inst_row.res_instance_id
  	  || field_seperator || c_simu_inst_inst_row.serial_number;
      end if; -- }
    end loop; -- }
    */
  end if; -- }

  p_name := to_char(rowcount) || field_seperator || p_name;
  p_id := to_char(rowcount) || field_seperator || p_id;
end getSimuResource;

procedure moveSupplyPub (p_plan_id number,
  p_supply_id number, p_start_date date, p_end_date date,
  p_plan_start_date date, p_plan_end_date date,
  p_return_status OUT NOCOPY varchar2,
  p_out out NOCOPY varchar2 ) is

  l_quan Number;
begin

  if p_start_date < p_plan_start_date then
    p_return_status := 'ERROR';
    p_out := 'START_DATE_LESS_THAN_PLAN_START';
    return;
  elsif p_end_date > p_plan_end_date then
    p_return_status := 'ERROR';
    p_out := 'END_DATE_GREATER_THAN_PLAN_END';
    return;
  end if;

  begin
    select nvl(new_order_quantity,0)
    into l_quan
    from msc_supplies
    where plan_id = p_plan_id
      and transaction_id = p_supply_id
    for update of firm_date nowait;
  exception
    when app_exception.record_lock_exception then
      p_return_status := 'ERROR';
      return;
  end;

  -- now update
  msc_gantt_utils.updateSupplies(p_plan_id, p_supply_id,
    FIRM_ALL_SUPPLY, SYS_YES, p_end_date, l_quan);

  p_return_status := 'OK';

end moveSupplyPub;

procedure moveOneResource(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_start_date date, p_end_date date,
  p_return_status in OUT NOCOPY varchar2,
  p_out in OUT NOCOPY varchar2,
  p_node_type number) is

   l_firm_flag number;
   l_firm_start date;
   l_firm_end date;
   l_start date;
   l_end date;
   l_supply_id number;

   ll_res_inst_trx_id number;
   ll_res_trx_id number;
begin
  if ( p_node_type = RES_NODE ) then -- {
    ll_res_trx_id := p_transaction_id;

    -- lock the mrr and getNewData
    msc_gantt_utils.lockReqNGetData(p_plan_id, p_instance_id, ll_res_trx_id,
      l_firm_flag, l_supply_id, l_start, l_end, l_firm_start, l_firm_end,
      p_return_status, p_out);

    l_start := p_start_date;
    l_end := p_end_date;

    -- update requirement
    msc_gantt_utils.updateReq(p_plan_id, p_instance_id, ll_res_trx_id,
       l_firm_flag, l_start, l_end, l_firm_start, l_firm_end, MOVE_MRR);

    -- update requirement's supply
    msc_gantt_utils.updateSupplies(p_plan_id, l_supply_id, TOUCH_SUPPLY);

  else
   ll_res_inst_trx_id := p_transaction_id;

   -- lock the mrr and getNewData
   msc_gantt_utils.lockReqInstNGetData(p_plan_id, p_instance_id, ll_res_inst_trx_id,
     l_supply_id, l_start, l_end, p_return_status, p_out);

   l_start := p_start_date;
   l_end := p_end_date;

   -- update requirement
   msc_gantt_utils.updateReqInst(p_plan_id, p_instance_id, ll_res_inst_trx_id, l_start, l_end);

   -- update requirement's supply
   msc_gantt_utils.updateSupplies(p_plan_id, l_supply_id, TOUCH_SUPPLY);

  end if; -- }

-- when the move is made, no need to update the firm dates...
/*
  if (l_end - l_start) = ( p_end_date - p_start_date ) then -- {
    if l_firm_flag in (NO_FIRM, FIRM_START) or l_firm_flag is null then -- {
      l_firm_flag := FIRM_START;
    elsif l_firm_flag in (FIRM_END, FIRM_START_END) THEN
      l_firm_flag := FIRM_START_END;
    elsif l_firm_flag in (FIRM_RESOURCE, FIRM_START_RES) THEN
      l_firm_flag := FIRM_START_RES;
    elsif l_firm_flag in (FIRM_END_RES,FIRM_ALL) THEN
      l_firm_flag := FIRM_ALL;
    else
      l_firm_flag := FIRM_START;
    end if; -- }
  else
    if l_firm_flag in (FIRM_RESOURCE,FIRM_START_RES,FIRM_END_RES,FIRM_ALL) THEN -- {
      l_firm_flag := FIRM_ALL;
    else
      l_firm_flag := FIRM_START_END;
    end if; -- }
  end if; -- }

  if l_firm_flag in (NO_FIRM,FIRM_START,FIRM_RESOURCE,FIRM_START_RES) then -- {
    l_firm_end := to_date(null);
  else
    l_firm_end := p_end_date;
  end if; -- }
  l_firm_start := p_start_date;
*/
end moveOneResource;

procedure moveResourceBatch(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_start_date date, p_end_date date,
  p_plan_start_date date, p_plan_end_date date,
  p_return_status OUT NOCOPY varchar2, p_out OUT NOCOPY varchar2,
  p_validate_flag boolean, p_node_type number) is

  l_start date;
  l_end date;
  l_firm_flag number;
  l_firm_start date;
  l_firm_end date;
  l_batch_number number;
  l_group_sequence_id number;
  l_group_sequence_number number;

  ll_res_inst_trx_id number;
  ll_res_trx_id number;
begin
  put_line(' moveResourceBatch in ');

/*
  if ( p_validate_flag ) then -- {
    validateTime(p_plan_id, p_transaction_id, p_instance_id, p_start_date, p_end_date,
      p_plan_start_date, p_plan_end_date, p_return_status, p_out, p_node_type);

    if p_return_status = 'ERROR' then
      return ;
    end if;
  end if; -- }
*/

  if ( p_node_type = RES_NODE ) then -- {

    -- in both the cases, res or res inst move, move the simultaneous res req
    open res_req_info(p_plan_id, p_instance_id, p_transaction_id);
    fetch res_req_info into l_firm_flag, l_firm_start, l_firm_end,
      l_batch_number, l_group_sequence_id, l_group_sequence_number;
    close res_req_info;

    msc_gantt_utils.updateBatchReq(p_plan_id, p_instance_id, l_batch_number,
      p_start_date, p_end_date, l_firm_flag, MOVE_MRR, p_return_status, p_out);

  else

    open res_inst_req_info(p_plan_id, p_instance_id, p_instance_id);
    fetch res_inst_req_info into l_batch_number;
    close res_inst_req_info;

    msc_gantt_utils.updateBatchInstReq(p_plan_id, p_instance_id, l_batch_number,
      p_start_date, p_end_date, l_firm_flag, MOVE_MRR, p_return_status, p_out);

  end if; -- }

  put_line(' moveResourceBatch out ');
end moveResourceBatch;

procedure moveResourceSeq(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_duration varchar2, p_plan_start_date date, p_plan_end_date date,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2,
  p_validate_flag boolean,
  p_node_type number) IS

  l_start date;
  l_end date;
  l_firm_flag number;
  l_firm_start date;
  l_firm_end date;
  l_batch_number number;
  l_group_sequence_id number;
  l_group_sequence_number number;

  ll_res_inst_trx_id number;
  ll_res_trx_id number;

begin
  put_line('moveResourceSeq in ');
    if ( p_node_type = RES_INST_NODE ) then -- {
      ll_res_inst_trx_id := p_transaction_id;
      ll_res_trx_id := get_parent_res_trx_id(p_plan_id, p_instance_id, ll_res_inst_trx_id);
    else
      ll_res_trx_id := p_transaction_id;
    end if; -- }

    -- in both the cases, res or res inst move, move the simultaneous res req
    open res_req_info(p_plan_id, p_instance_id, ll_res_trx_id);
    fetch res_req_info into l_firm_flag, l_firm_start, l_firm_end,
      l_batch_number, l_group_sequence_id, l_group_sequence_number;
    close res_req_info;

    if ( l_group_sequence_id is null or l_group_sequence_number is null ) then
      p_return_status := 'ERROR';
      p_out := 'RES_REQ_NOT_IN_FIRM_SEQ';
      return;
    end if;

    if (p_duration is not null) then
      msc_gantt_utils.updateResSeq(p_plan_id, p_instance_id,
        l_group_sequence_id, p_duration, p_plan_start_date, p_plan_end_date,
        p_return_status, p_out, p_validate_flag, p_node_type);
    end if;

  put_line('moveResourceSeq out ');
end moveResourceSeq;


procedure moveResourcePub(p_plan_id number,
  p_transaction_id number, p_instance_id number,
  p_start_date date, p_end_date date,
  p_duration varchar2,
  p_plan_start_date date, p_plan_end_date date,
  p_return_status OUT NOCOPY varchar2,
  p_out OUT NOCOPY varchar2,
  p_validate_flag boolean,
  p_res_firm_seq boolean,
  p_batched_res_act boolean,
  p_node_type number) IS

   row_count number;
   v_transaction_id number;
   v_instance_id number;

  l_start date;
  l_end date;
  l_firm_flag number;
  l_firm_start date;
  l_firm_end date;
  l_batch_number number;
  l_group_sequence_id number;
  l_group_sequence_number number;

  ll_res_inst_trx_id number;
  ll_res_trx_id number;

begin
  put_line(' moveResourcePub in ');
    p_return_status := 'OK';

    -- res/res inst firm seq move logic and batched res/res inst move logic
    if ( p_res_firm_seq ) then
      put_line(' before moveResourceSeq');
      msc_gantt_utils.moveResourceSeq(p_plan_id, p_transaction_id, p_instance_id,
        p_duration, p_plan_start_date, p_plan_end_date,
	p_return_status, p_out, p_validate_flag, p_node_type);
      return; --end this process here itself..
    elsif ( p_batched_res_act ) then
      put_line(' before moveResourceBatch');
      msc_gantt_utils.moveResourceBatch(p_plan_id, p_transaction_id, p_instance_id,
        p_start_date, p_end_date, p_plan_start_date, p_plan_end_date,
	p_return_status, p_out, p_validate_flag, p_node_type);
      return; --end this process here itself..
    end if; -- }
    -- res/res inst firm seq move logic and batched res/res inst move logic

    -- res/res inst normal move ......

    if ( p_validate_flag ) then -- {
      put_line(' before validateTime');
      validateTime(p_plan_id, p_transaction_id, p_instance_id, p_start_date, p_end_date,
        p_plan_start_date, p_plan_end_date, p_return_status, p_out, p_node_type);
      if p_return_status = 'ERROR' then
        return ;
      end if;
    end if; -- }

    if ( p_node_type = RES_INST_NODE ) then -- {
      ll_res_inst_trx_id := p_transaction_id;
      ll_res_trx_id := get_parent_res_trx_id(p_plan_id, p_instance_id, ll_res_inst_trx_id);
    else
      ll_res_trx_id := p_transaction_id;
      ll_res_inst_trx_id := get_child_res_trx_id(p_plan_id, p_instance_id, ll_res_trx_id);
    end if; -- }

   put_line('ll_res_trx_id ll_res_inst_trx_id '||ll_res_trx_id||' - '||ll_res_inst_trx_id);

    -- in both the cases, res or res inst move, move the simultaneous res req
    open res_req_info(p_plan_id, p_instance_id, ll_res_trx_id);
    fetch res_req_info into l_firm_flag, l_firm_start, l_firm_end,
      l_batch_number, l_group_sequence_id, l_group_sequence_number;
    close res_req_info;

    l_start := p_start_date;
    l_end := p_end_date;

    if ( nvl(l_firm_flag,0) <> 0 ) then
      p_return_status := 'ERROR';
      p_out := 'REQ_IS_FIRMED';
      return;
    end if;

    if ( p_node_type = RES_INST_NODE ) then -- {
      -- move res inst node
      msc_gantt_utils.moveOneResource(p_plan_id, ll_res_inst_trx_id, p_instance_id, p_start_date, p_end_date,
        p_return_status, p_out, RES_INST_NODE);
      if p_return_status = 'ERROR' then
        return;
      end if;
      -- move res node also
      msc_gantt_utils.moveOneResource(p_plan_id, ll_res_trx_id, p_instance_id, p_start_date, p_end_date,
        p_return_status, p_out, RES_NODE);
      if p_return_status = 'ERROR' then
        return;
      end if;
    else
      -- move res node only
      msc_gantt_utils.moveOneResource(p_plan_id, ll_res_trx_id, p_instance_id, p_start_date, p_end_date,
        p_return_status, p_out, RES_NODE);
      if p_return_status = 'ERROR' then
        return;
      end if;
      -- move all the res instance if the resource is moved.
      msc_gantt_utils.moveOneResource(p_plan_id, ll_res_inst_trx_id, p_instance_id,
        l_start, l_end, p_return_status, p_out, RES_INST_NODE);
      if p_return_status = 'ERROR' then
        return;
       end if;
    end if; -- }

  -- update the simultaneous resource for a given res trans id
  msc_gantt_utils.updateReqSimu(p_plan_id, p_instance_id, ll_res_trx_id,
    l_firm_flag, l_start, l_end, l_firm_start, l_firm_end, MOVE_MRR, p_return_status, p_out);
  -- in both the cases, res or res inst move, move the simultaneous res req ends


  put_line(' moveResourcePub out');
end moveResourcePub;

-- property +
procedure getProperty(p_plan_id number, p_instance_id number,
  p_transaction_id number, p_type number, p_view_type number, p_end_demand_id number,
  v_pro out NOCOPY varchar2, v_demand out NOCOPY varchar2) is

  l_buy_text varchar2(2000) := fnd_message.get_string('MSC','BUY_TEXT');
  l_make_text varchar2(2000) := fnd_message.get_string('MSC','MAKE_TEXT');
  l_transfer_text varchar2(2000) := fnd_message.get_string('MSC','TRANSFER_TEXT');

  cursor job_cur is
  select msi.item_name item,
    ms.new_order_quantity qty,
    nvl(to_char(ms.firm_date,format_mask), null_space) firm_date,
    to_char(ms.new_schedule_date,format_mask) sugg_due_date,
    nvl(to_char(ms.need_by_date,format_mask), null_space) needby,
    nvl(ms.unit_number,null_space) unit_number,
    nvl(msc_get_name.project(ms.project_id,ms.organization_id,
      ms.plan_id, ms.sr_instance_id), null_space) project,
    nvl(msc_get_name.task(ms.task_id, ms.project_id, ms.organization_id,
      ms.plan_id, ms.sr_instance_id),null_space) task,
    msc_get_name.org_code(ms.organization_id, ms.sr_instance_id) org,
    decode(ms.order_type,
      5, decode(ms.order_number,
           null, to_char(ms.transaction_id),
           replace(ms.order_number,'~','^')||' '||to_char(ms.transaction_id)),
      nvl(replace(ms.order_number,'~','^'), to_char(ms.transaction_id))) job_name,
    ms.firm_planned_type,
    nvl(ms.alternate_bom_designator, null_space) alternate_bom_designator,
    nvl(ms.alternate_routing_designator, null_space) alternate_routing_designator,
    ms.organization_id org_id,
    nvl(to_char(msi.planning_time_fence_date, format_mask),null_space) time_fence,
    nvl(msc_get_name.supply_type(ms.transaction_id, p_plan_id), null_space) supply_type,
    decode(msc_gantt_utils.getSupplyType(ms.order_type, msi.planning_make_buy_code,
      ms.organization_id, ms.source_organization_id),
      BUY_SUPPLY, l_buy_text,
      TRANSFER_SUPPLY, l_transfer_text,
      MAKE_SUPPLY, l_make_text) item_type,
    msi.description,
    nvl(msc_get_name.supplier(nvl(ms.source_supplier_id, ms.supplier_id)), null_space) supplier,
    nvl(msc_get_name.org_code(ms.source_organization_id, ms.source_sr_instance_id),null_space) source_org,
    nvl(ms.ship_method, null_space) ship_method,
    msc_get_name.lookup_meaning('SYS_YES_NO', decode(ms.supply_is_shared,1,1,2)) share_supply,
    nvl(to_char(ms.EARLIEST_START_DATE,format_mask),null_space) EPSD,
    nvl(to_char(ms.EARLIEST_COMPLETION_DATE,format_mask),null_space) EPCD,
    nvl(to_char(ms.UEPSD,format_mask),null_space) UEPSD,
    nvl(to_char(ms.UEPCD,format_mask),null_space) UEPCD,
    nvl(to_char(ms.ULPSD,format_mask),null_space) ULPSD,
    nvl(to_char(ms.ULPCD,format_mask),null_space) ULPCD
    from msc_supplies ms,
      msc_system_items msi
    where ms.plan_id = p_plan_id
      and ms.transaction_id = p_transaction_id
      and ms.sr_instance_id = p_instance_id
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id;

  cursor res_cur is
  select msc_get_name.item_name(mrr.assembly_item_id,null,null,null) item,
    nvl(mrr.operation_seq_num,0) op_seq,
    msc_get_name.org_code(mrr.organization_id, mrr.sr_instance_id) org,
    msc_get_name.department_code(decode(mrr.resource_id, -1, 1,2),
      mrr.department_id, mrr.organization_id, mrr.plan_id, mrr.sr_instance_id) dept_code,
    nvl(msc_get_name.job_name(mrr.supply_id, p_plan_id), to_char(mrr.supply_id)) job_name,
    nvl(mrr.assigned_units,0) assigned_units,
    msc_get_name.lookup_meaning('RESOURCE_FIRM_TYPE', nvl(mrr.firm_flag,0)) firm_flag,
    nvl(mrr.alternate_num,0) alternate_num,
    nvl(mrr.resource_seq_num,0) res_seq_num,
    nvl(msc_get_name.resource_code(mrr.resource_id, mrr.department_id,
      mrr.organization_id, mrr.plan_id, mrr.sr_instance_id), null_space) res_code,
    nvl(mrr.resource_hours,0) resource_hours,
    ms.organization_id org_id,
    ms.transaction_id trans_id,
    0 mtq_time, -- getMTQTime(p_transaction_id, p_plan_id, p_instance_id) mtq_time,
    nvl(mdr.batchable_flag,2) batchable,
    nvl(to_char(mrr.batch_number), null_space) batch_number,
    nvl(mdr.unit_of_measure,null_space) uom,
    nvl(decode(mrr.basis_type,
      null, null_space,
      msc_get_name.lookup_meaning('MSC_RES_BASIS_TYPE',mrr.basis_type)),null_space) basis_type,
    nvl(decode(mrr.schedule_flag,
      null, null_space,
      msc_get_name.lookup_meaning('BOM_RESOURCE_SCHEDULE_TYPE',mrr.schedule_flag)),null_space) schedule_flag,
    nvl(to_char(mrr.EARLIEST_START_DATE,format_mask),null_space) EPSD,
    nvl(to_char(mrr.EARLIEST_COMPLETION_DATE,format_mask),null_space) EPCD,
    nvl(to_char(mrr.UEPSD,format_mask),null_space) UEPSD,
    nvl(to_char(mrr.UEPCD,format_mask),null_space) UEPCD,
    nvl(to_char(mrr.ULPSD,format_mask),null_space) ULPSD,
    nvl(to_char(mrr.ULPCD,format_mask),null_space) ULPCD
  from  msc_resource_requirements mrr,
    msc_supplies ms,
    msc_department_resources mdr
  where  mrr.plan_id = p_plan_id
    and mrr.transaction_id = p_transaction_id
    and mrr.sr_instance_id = p_instance_id
    and ms.sr_instance_id = mrr.sr_instance_id
    and ms.plan_id = p_plan_id
    and ms.transaction_id = mrr.supply_id
    and mdr.plan_id = mrr.plan_id
    and mdr.organization_id = mrr.organization_id
    and mdr.sr_instance_id = mrr.sr_instance_id
    and mdr.department_id = mrr.department_id
    and mdr.resource_id = mrr.resource_id;

   job_cur_rec job_cur%ROWTYPE;
   res_cur_rec res_cur%ROWTYPE;

   p_end_peg_id number;

   cursor alloc_cur is
    select sum(decode(mfp.demand_id, -1, mfp.allocated_quantity, 0)),
           sum(mfp.allocated_quantity)
      from msc_full_pegging mfp
     where mfp.plan_id = p_plan_id
       AND mfp.transaction_id = p_transaction_id
       and mfp.end_pegging_id = p_end_peg_id;

   v_end_peg_id number_arr;
   a number;
   v_qty1 number;
   v_qty2 number;
   v_excess_qty number :=0;
   v_alloc_qty number :=0;

begin
  if p_type in (JOB_NODE, COPROD_NODE) then -- {

    -- calculate alloc_qty, excess_qty, and short_qty
    select mfp.end_pegging_id
    bulk collect into v_end_peg_id
    from msc_full_pegging mfp
    where mfp.plan_id = p_plan_id
      and mfp.demand_id = p_end_demand_id
      and mfp.pegging_id = mfp.end_pegging_id;

    for a in 1..v_end_peg_id.count
    loop -- {
      p_end_peg_id := v_end_peg_id(a);
      v_qty1 :=0;
      v_qty2 :=0;

      open alloc_cur;
      fetch alloc_cur into v_qty1,v_qty2;
      close alloc_cur;

      v_excess_qty := v_excess_qty + nvl(v_qty1,0);
      v_alloc_qty := v_alloc_qty + nvl(v_qty2,0);
    end loop;  -- }

    open job_cur;
    fetch job_cur into job_cur_rec;
    close job_cur;

    v_pro := job_cur_rec.item || field_seperator || job_cur_rec.qty
      || field_seperator || job_cur_rec.firm_date || field_seperator || job_cur_rec.sugg_due_date
      || field_seperator || job_cur_rec.needby || field_seperator || job_cur_rec.unit_number
      || field_seperator || job_cur_rec.project || field_seperator || job_cur_rec.task
      || field_seperator || job_cur_rec.org || field_seperator || job_cur_rec.job_name
      || field_seperator || job_cur_rec.firm_planned_type
      || field_seperator || job_cur_rec.alternate_bom_designator
      || field_seperator || job_cur_rec.alternate_routing_designator
      || field_seperator || job_cur_rec.time_fence || field_seperator || job_cur_rec.supply_type
      ||field_seperator || job_cur_rec.item_type || field_seperator || job_cur_rec.description
      || field_seperator || nvl(to_char(v_alloc_qty), null_space)
      || field_seperator || nvl(to_char(v_excess_qty), null_space)
      || field_seperator || job_cur_rec.supplier || field_seperator ||job_cur_rec.source_org
      || field_seperator || job_cur_rec.ship_method || field_seperator || job_cur_rec.share_supply
      || field_seperator || job_cur_rec.EPSD || field_seperator ||job_cur_rec.EPCD
      || field_seperator || job_cur_rec.UEPSD || field_seperator || job_cur_rec.UEPCD
      || field_seperator || job_cur_rec.ULPSD || field_seperator || job_cur_rec.ULPCD ;

    demandPropertyData(p_plan_id, p_instance_id, p_transaction_id,
      job_cur_rec.org_id, p_end_demand_id, v_demand);

  elsif p_type = RES_NODE then

     open res_cur;
     fetch res_cur into res_cur_rec;
     close res_cur;

     resPropertyData(p_plan_id, p_transaction_id, p_instance_id, p_end_demand_id, v_pro, v_demand);

      demandPropertyData(p_plan_id, p_instance_id, res_cur_rec.trans_id,
        res_cur_rec.org_id, p_end_demand_id, v_demand);

  elsif p_type = END_DEMAND_NODE then
      demandPropertyData(p_plan_id, p_instance_id, null,
        null, p_transaction_id, v_demand);
  end if; -- }

end getProperty;

procedure resPropertyData(p_plan_id number,
  p_transaction_id number, p_instance_id number, p_end_demand_id number,
  v_job OUT NOCOPY varchar2, v_demand OUT NOCOPY varchar2) IS

 cursor property is
 select msc_get_name.item_name(ms.inventory_item_id,null,null,null) item,
   mrr.operation_seq_num,
   ms.new_order_quantity qty,
   nvl(to_char(ms.firm_date,format_mask),null_space) firm_date,
   to_char(ms.new_schedule_date,format_mask) sugg_due_date,
   nvl(to_char(ms.need_by_date,format_mask),null_space) needby,
   nvl(ms.unit_number,null_space) unit_number,
   nvl(msc_get_name.project(ms.project_id,ms.organization_id,
     ms.plan_id, ms.sr_instance_id), null_space) project,
   nvl(msc_get_name.task(ms.task_id, ms.project_id, ms.organization_id,
     ms.plan_id, ms.sr_instance_id),null_space) task,
   ms.transaction_id,
   ms.organization_id,
   msc_get_name.org_code(mdr.organization_id, mdr.sr_instance_id) org,
   mdr.department_code,
   decode(ms.order_type,
     5, decode(ms.order_number,
       null,to_char(ms.transaction_id),
       replace(ms.order_number,'~','^')||' '||to_char(ms.transaction_id)),
     nvl(replace(ms.order_number,'~','^'),to_char(ms.transaction_id))) job_name,
   mrr.assigned_units,
   nvl(msc_get_name.lookup_meaning('RESOURCE_FIRM_TYPE',nvl(mrr.firm_flag,NO_FIRM)),
     msc_get_name.lookup_meaning('RESOURCE_FIRM_TYPE',0))
   firm_flag,
   ms.firm_planned_type,
   nvl(mrr.alternate_num,0) alternate_num,
   mrr.resource_seq_num,
   nvl(mdr.resource_code, null_space) resource_code,
   mrr.resource_hours,
   nvl(msc_get_name.alternate_bom(pe.plan_id, pe.sr_instance_id,
     pe.bill_sequence_id),null_space) alternate_bom_designator,
   nvl(msc_get_name.alternate_bom(pe.plan_id, pe.sr_instance_id,
     pe.bill_sequence_id),null_space) alternate_routing_designator,
   nvl(to_char(msi.planning_time_fence_date, format_mask),null_space) time_fence,
   0 mtq_time, --getMTQTime(p_transaction_id, p_plan_id, p_instance_id) mtq_time,
   nvl(mdr.batchable_flag, 2) batchable,
   nvl(to_char(mrr.batch_number), null_space) batch_number,
   nvl(mdr.unit_of_measure,null_space) uom,
   nvl(decode(to_char(mrr.basis_type),
     null, null_space,
     msc_get_name.lookup_meaning('MSC_RES_BASIS_TYPE',mrr.basis_type)),null_space) basis_type,
   nvl(decode(to_char(mrr.schedule_flag),
     null, null_space,
     msc_get_name.lookup_meaning('BOM_RESOURCE_SCHEDULE_TYPE',mrr.schedule_flag)),null_space) schedule_flag,
   nvl(to_char(mrr.EARLIEST_START_DATE,format_mask),null_space) EPSD,
   nvl(to_char(mrr.EARLIEST_COMPLETION_DATE,format_mask),null_space) EPCD,
   nvl(to_char(mrr.UEPSD,format_mask),null_space) UEPSD,
   nvl(to_char(mrr.UEPCD,format_mask),null_space) UEPCD,
   nvl(to_char(mrr.ULPSD,format_mask),null_space) ULPSD,
   nvl(to_char(mrr.ULPCD,format_mask),null_space) ULPCD
 from msc_supplies ms,
   msc_resource_requirements mrr,
   msc_department_resources mdr,
   msc_system_items msi,
   msc_process_effectivity pe
 where pe.plan_id(+) = ms.plan_id
   and pe.sr_instance_id(+) = ms.sr_instance_id
   and pe.process_sequence_id(+) = ms.process_seq_id
   and mrr.plan_id = p_plan_id
   and mrr.transaction_id = p_transaction_id
   and mrr.sr_instance_id = p_instance_id
   and ms.plan_id = mrr.plan_id
   and ms.transaction_id = mrr.supply_id
   and ms.sr_instance_id = mrr.sr_instance_id
   and mdr.plan_id = mrr.plan_id
   and mdr.organization_id = mrr.organization_id
   and mdr.sr_instance_id = mrr.sr_instance_id
   and mdr.department_id = mrr.department_id
   and mdr.resource_id = mrr.resource_id
   and msi.plan_id = ms.plan_id
   and msi.organization_id = ms.organization_id
   and msi.sr_instance_id = ms.sr_instance_id
   and msi.inventory_item_id = ms.inventory_item_id;

 pro_record  property%ROWTYPE;

begin

  open property;
  fetch property into pro_record;
  close property;

  v_job := pro_record.item || field_seperator ||pro_record.operation_seq_num
    || field_seperator || pro_record.qty
    || field_seperator || pro_record.firm_date
    || field_seperator || pro_record.sugg_due_date || field_seperator || pro_record.needby
    || field_seperator || pro_record.unit_number || field_seperator || pro_record.project
    || field_seperator || pro_record.task || field_seperator || pro_record.department_code
    || field_seperator || pro_record.job_name || field_seperator || pro_record.org
    || field_seperator || pro_record.assigned_units
    || field_seperator || pro_record.firm_flag
    || field_seperator || pro_record.firm_planned_type || field_seperator || pro_record.alternate_num
    || field_seperator || pro_record.resource_seq_num || field_seperator || pro_record.resource_code
    || field_seperator || pro_record.resource_hours
    || field_seperator || pro_record.alternate_bom_designator
    || field_seperator || pro_record.alternate_routing_designator
    || field_seperator || pro_record.time_fence ||  field_seperator || pro_record.mtq_time
    || field_seperator || pro_record.batchable ||  field_seperator || pro_record.batch_number
    || field_seperator || pro_record.uom ||  field_seperator || pro_record.basis_type
    || field_seperator || pro_record.schedule_flag || field_seperator || pro_record.EPSD
    || field_seperator || pro_record.EPCD || field_seperator || pro_record.UEPSD
    || field_seperator || pro_record.UEPCD || field_seperator || pro_record.ULPSD
    || field_seperator || pro_record.ULPCD;

  if pro_record.transaction_id is not null then -- {
     demandPropertyData(p_plan_id, p_instance_id, pro_record.transaction_id,
        pro_record.organization_id, p_end_demand_id, v_demand);
  end if; -- }

end resPropertyData;

procedure demandPropertyData( p_plan_id number,
  p_instance_id number, v_transaction_id number,
  v_org_id number, p_end_demand_id number,
  v_demand out NOCOPY varchar2) IS

  v_instance_id number;
  v_demand_id number;
  v_pegging_id number;
  v_pegged_qty number;
  v_days_late varchar2(3000);
  v_demand_quantity  number;
  v_item_id  number;
  v_demand_date  date;

  cursor pegging is
  select mfp2.demand_id, mfp2.sr_instance_id,
    sum(nvl(mfp1.allocated_quantity,0)),
    mfp2.demand_quantity,
    mfp2.demand_date,
    mfp2.inventory_item_id
  from msc_full_pegging mfp1,
    msc_full_pegging mfp2
  where mfp1.plan_id = p_plan_id
    and mfp1.organization_id = v_org_id
    and mfp1.sr_instance_id = p_instance_id
    and mfp1.transaction_id = v_transaction_id
    and mfp2.plan_id = mfp1.plan_id
    and mfp2.sr_instance_id = mfp1.sr_instance_id
    and mfp2.pegging_id = mfp1.end_pegging_id
  group by mfp2.demand_id,
    mfp2.sr_instance_id,
    mfp2.demand_quantity,
    mfp2.demand_date,
    mfp2.inventory_item_id;

  cursor other_demand is
  select nvl(v_demand_quantity,0) qty,
    nvl(to_char(v_demand_date,format_mask), null_space) demand_date,
    msc_get_name.lookup_meaning('MRP_FLP_SUPPLY_DEMAND_TYPE', v_demand_id) type,
    item_name item
  from msc_items
  where inventory_item_id = v_item_id;

  cursor demand is
  select md.using_requirement_quantity qty,
    to_char(md.using_assembly_demand_date, format_mask) demand_date,
    msc_get_name.demand_order_number (md.plan_id,md.sr_instance_id,md.demand_id) name,
    msc_get_name.lookup_meaning('MRP_DEMAND_ORIGINATION', md.origination_type) type,
    msc_get_name.item_name(md.inventory_item_id, null,null,null) item,
    nvl(md.demand_priority,0) priority,
    nvl(replace(msc_get_name.customer(md.customer_id),'&','*'), null_space) customer,
    nvl(replace(msc_get_name.customer_site(md.customer_site_id),'&','*'), null_space) customer_site,
    nvl(to_char(md.dmd_satisfied_date,format_mask), null_space) satisfied_date,
    decode(sign(md.dmd_satisfied_date - md.using_assembly_demand_date),
      1, GREATEST(round(md.dmd_satisfied_date - md.using_assembly_demand_date,2), 0.01), 0) days_late,
    nvl(to_char(md.quantity_by_due_date),null_space) qty_by_due_date,
    msc_get_name.org_code(md.organization_id, md.sr_instance_id) org,
    nvl(md.demand_class,null_space) demand_class
  from msc_demands md
  where md.plan_id = p_plan_id
    and md.demand_id = v_demand_id
    and md.sr_instance_id = v_instance_id;

  demand_rec demand%ROWTYPE;
  other_demand_rec other_demand%ROWTYPE;
  rowcount number;

begin
  --for demand node only
  rowcount :=0;
  if (p_end_demand_id is not null) then
    v_instance_id := p_instance_id;
    v_demand_id := p_end_demand_id;

    open demand;
    fetch demand into demand_rec;
    close demand;

    v_days_late := demand_rec.days_late;
    if v_days_late = 0 then -- {
      v_days_late := null_space;
    end if; -- }

    v_demand :=  demand_rec.qty
          || field_seperator || demand_rec.demand_date
          || field_seperator || demand_rec.name || field_seperator || demand_rec.type
	  || field_seperator || demand_rec.item || field_seperator || demand_rec.priority
	  || field_seperator || demand_rec.customer || field_seperator || demand_rec.customer_site
	  || field_seperator || demand_rec.satisfied_date  || field_seperator || null_space
	  || field_seperator || v_days_late || field_seperator || demand_rec.qty_by_due_date
	  || field_seperator || demand_rec.org || field_seperator || demand_rec.demand_class ;

    rowcount := rowcount +1;
    v_demand := to_char(rowcount) || record_seperator || v_demand;
    return;
  end if;

  rowcount :=0;

  open pegging;
  loop -- {
    fetch pegging into v_demand_id, v_instance_id, v_pegged_qty,
      v_demand_quantity, v_demand_date, v_item_id;
    exit when pegging%notfound or nvl(length(v_demand),0) > 31000;

    rowcount := rowcount +1;

    if v_demand_id not in (-1,-2,-3,18) then -- {

      open demand;
      fetch demand into demand_rec;
      close demand;

      v_days_late := demand_rec.days_late;
      if v_days_late = 0 then -- {
        v_days_late := null_space;
      end if; -- }

      if v_demand is not null then -- {
        if v_demand_id = p_end_demand_id then -- {
          v_demand := demand_rec.qty
            || field_seperator || demand_rec.demand_date
	    || field_seperator || demand_rec.name || field_seperator || demand_rec.type
	    || field_seperator || demand_rec.item || field_seperator || demand_rec.priority
	    || field_seperator || demand_rec.customer || field_seperator || demand_rec.customer_site
	    || field_seperator || demand_rec.satisfied_date
	    || field_seperator || v_pegged_qty
	    || field_seperator || v_days_late
            || field_seperator || demand_rec.qty_by_due_date
	    || field_seperator || demand_rec.org || field_seperator || demand_rec.demand_class
	    || record_seperator ||v_demand;
        else
          v_demand := v_demand || record_seperator
            || demand_rec.qty
	    || field_seperator || demand_rec.demand_date || field_seperator || demand_rec.name
	    || field_seperator || demand_rec.type ||  field_seperator || demand_rec.item
	    || field_seperator || demand_rec.priority || field_seperator || demand_rec.customer
	    || field_seperator || demand_rec.customer_site  || field_seperator || demand_rec.satisfied_date
	    || field_seperator || v_pegged_qty
            || field_seperator || v_days_late
	    || field_seperator || demand_rec.qty_by_due_date || field_seperator || demand_rec.org
	    || field_seperator || demand_rec.demand_class;
        end if; -- }
       else
        v_demand :=  demand_rec.qty
          || field_seperator || demand_rec.demand_date
	  || field_seperator || demand_rec.name || field_seperator || demand_rec.type
	  || field_seperator || demand_rec.item || field_seperator || demand_rec.priority
	  || field_seperator || demand_rec.customer || field_seperator || demand_rec.customer_site
	  || field_seperator || demand_rec.satisfied_date
          || field_seperator || v_pegged_qty
	  || field_seperator || v_days_late
          || field_seperator || demand_rec.qty_by_due_date
	  || field_seperator || demand_rec.org || field_seperator || demand_rec.demand_class ;
       end if; -- }
    else
      open other_demand;
      fetch other_demand into other_demand_rec;
      close other_demand;

      if v_demand is not null then -- {
        v_demand := v_demand
          || record_seperator || other_demand_rec.qty
	  || field_seperator || other_demand_rec.demand_date || field_seperator || null_space
	  || field_seperator || other_demand_rec.type ||  field_seperator || other_demand_rec.item
	  || field_seperator || null_space || field_seperator || null_space
	  || field_seperator || null_space || field_seperator || null_space
	  || field_seperator || v_pegged_qty
          || field_seperator || null_space
	  || field_seperator || null_space || field_seperator || null_space
	  || field_seperator || null_space ;
       else
         v_demand :=  other_demand_rec.qty
           || field_seperator || other_demand_rec.demand_date
	   || field_seperator || null_space || field_seperator || other_demand_rec.type
	   || field_seperator || other_demand_rec.item || field_seperator || null_space
	   || field_seperator || null_space || field_seperator || null_space
	   || field_seperator || null_space
           || field_seperator || v_pegged_qty
	   || field_seperator || null_space || field_seperator || null_space
	   || field_seperator || null_space || field_seperator || null_space;
      end if; -- }
    end if;  -- }
  end loop; -- }
  close pegging;
  v_demand := to_char(rowcount) || record_seperator || v_demand;

end demandPropertyData;
-- property data -

procedure rescheduleData(p_plan_id number,
  p_instance_id number, p_org_id number,
  p_dept_id number, p_res_id number,
  p_time varchar2,
  p_plan_end_date date,
  v_require_data OUT NOCOPY varchar2) IS

  oneRecord varchar2(32000);
  rowCount number;

  cursor req is
  select
    to_char(msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
      mrr.start_date, mrr.end_date,mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied), format_mask) start_date,
    to_char(msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
      mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied), format_mask) end_date,
    nvl(msc_get_name.job_name(mrr.supply_id, p_plan_id), to_char(mrr.supply_id)) job_name,
    msc_get_name.supply_type(mrr.supply_id, mrr.plan_id) supply_type,
    mrr.assigned_units,
    mrr.transaction_id,
    mrr.sr_instance_id
  from msc_resource_requirements mrr
  where mrr.sr_instance_id = p_instance_id
    and mrr.plan_id = p_plan_id
    and mrr.organization_id = p_org_id
    and mrr.end_date is not null
    and nvl(mrr.parent_id,2) =2
    and nvl(mrr.firm_start_date,mrr.start_date) <= p_plan_end_date
    and mrr.department_id = p_dept_id
    and mrr.resource_id = p_res_id
    and to_date(p_time, format_mask)
      between msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
	mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
      and msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0),
	mrr.start_date, mrr.end_date, mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied)
  order by start_date;

  l_req_data req%ROWTYPE;

begin

  rowCount :=0;
  open req;
  loop -- {
    fetch req into l_req_data;
    exit when req%notfound;

    if oneRecord is not null then -- {
      oneRecord := oneRecord || record_seperator || l_req_data.job_name
        || field_seperator || l_req_data.start_date || field_seperator || l_req_data.end_date
	|| field_seperator || l_req_data.supply_type
        || field_seperator || l_req_data.assigned_units
	|| field_seperator || l_req_data.transaction_id || field_seperator || l_req_data.sr_instance_id ;
    else
      oneRecord :=  l_req_data.job_name || field_seperator || l_req_data.start_date
        || field_seperator || l_req_data.end_date || field_seperator || l_req_data.supply_type
	|| field_seperator || l_req_data.assigned_units
        || field_seperator || l_req_data.transaction_id
	|| field_seperator || l_req_data.sr_instance_id ;
    end if; -- }
    rowCount := rowCount+1;
   end loop; -- }
   close req;

   v_require_data :=  rowCount || record_seperator || oneRecord;

end rescheduleData;

procedure rescheduleData(p_plan_id number,
  p_instance_id number, p_transaction_id number,
  p_plan_end_date date,
  v_require_data OUT NOCOPY varchar2) IS

  oneRecord varchar2(32000);
  rowCount number;

  cursor req is
    select
      to_char(msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
        mrr.start_date, mrr.end_date,mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied), format_mask) start_date,
      to_char(msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
        mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied), format_mask) end_date,
      nvl(msc_get_name.job_name(mrr.supply_id, p_plan_id), to_char(mrr.supply_id)) job_name,
      msc_get_name.supply_type(mrr.supply_id, mrr.plan_id) supply_type,
      mrr.assigned_units,
      mrr.transaction_id,
      mrr.sr_instance_id
    from msc_resource_requirements mrr
    where mrr.sr_instance_id = p_instance_id
      and mrr.plan_id = p_plan_id
      and mrr.transaction_id = p_transaction_id
      and mrr.end_date is not null
      and mrr.department_id <> -1
      and nvl(mrr.parent_id,2) =2
      and nvl(mrr.firm_start_date,mrr.start_date) <= p_plan_end_date
    order by start_date;

   l_req_data req%ROWTYPE;

begin
  rowCount :=0;
  open req;
  loop  -- {
    fetch req into l_req_data;
    exit when req%notfound;

    if oneRecord is not null then -- {
      oneRecord := oneRecord || record_seperator || l_req_data.job_name
        || field_seperator || l_req_data.start_date || field_seperator || l_req_data.end_date
	|| field_seperator || l_req_data.supply_type
        || field_seperator || l_req_data.assigned_units
	|| field_seperator || l_req_data.transaction_id || field_seperator || l_req_data.sr_instance_id ;
    else
      oneRecord :=  l_req_data.job_name || field_seperator || l_req_data.start_date
        || field_seperator || l_req_data.end_date || field_seperator || l_req_data.supply_type
	|| field_seperator || l_req_data.assigned_units
        || field_seperator || l_req_data.transaction_id
	|| field_seperator || l_req_data.sr_instance_id ;
    end if; -- }
    rowCount := rowCount+1;
   end loop; -- }
   close req;

   v_require_data :=  rowCount || record_seperator ||oneRecord;

end rescheduleData;

function getDependencyType(p_plan_id number, p_trans_id number, p_inst_id number,
  p_op_seq_id number, p_op_seq_num number, p_res_seq_num number,
  c_trans_id number, c_inst_id number,
  c_op_seq_id number, c_op_seq_num number, c_res_seq_num number) return number is

  cursor c_intra_rtg is
  select distinct mon.dependency_type
  from msc_resource_requirements mrr,
    msc_operation_networks mon
  where mrr.plan_id = p_plan_id
    and mrr.sr_instance_id = p_inst_id
    and mrr.supply_id = p_trans_id
    and mon.plan_id = mrr.plan_id
    and mon.sr_instance_id = mrr.sr_instance_id
    and mon.routing_sequence_id = mrr.routing_sequence_id
    and mon.transition_type = 1
    and nvl(mon.from_op_seq_id, MBP_NULL_VALUE) = nvl(p_op_seq_id, MBP_NULL_VALUE)
    and nvl(mon.to_op_seq_id, MBP_NULL_VALUE) = nvl(c_op_seq_id, MBP_NULL_VALUE);

  cursor c_inter_rtg is
  select mjon.dependency_type
  from msc_job_operation_networks mjon
  where mjon.plan_id = p_plan_id
    and mjon.sr_instance_id = p_inst_id
    and mjon.transaction_id = p_trans_id
    and mjon.to_transaction_id = c_trans_id
    and mjon.transition_type = 1
    and nvl(mjon.from_op_seq_id, MBP_NULL_VALUE) = nvl(p_op_seq_id, MBP_NULL_VALUE)
    and nvl(mjon.to_op_seq_id, MBP_NULL_VALUE) = nvl(c_op_seq_id, MBP_NULL_VALUE);

  l_dependency_type number;

begin
  if ( p_inst_id = c_inst_id and p_trans_id = c_trans_id ) then --{
    --intra-routing
    open c_intra_rtg;
    fetch c_intra_rtg into l_dependency_type;
    close c_intra_rtg;

    return nvl(l_dependency_type,-1);

  else
    --inter-routing
    open c_inter_rtg;
    fetch c_inter_rtg into l_dependency_type;
    close c_inter_rtg;

    return nvl(l_dependency_type,-1);
  end if; -- }

  return -1;
 exception
   when others then
     return -1;
end getDependencyType;


procedure segmentPegging(p_query_id number, p_plan_id number,
  p_trx_list varchar2, p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl) is

  i number := 1;

  l_len number;
  l_inst_id number;
  l_trx_id number;
  l_node_type number;
  l_one_record varchar2(100);

  c_trans_id number_arr;
  c_inst_id number_arr;
  seg_start date_arr;
  seg_end date_arr;
  seg_qty number_arr;
  c_start date_arr;
  c_end date_arr;

  v_one_record varchar2(300);
  oneBigRecord maxCharTbl := maxCharTbl(0);
  v_max_len number;
  reqCount number;

  cursor c_seg_peg (p_plan number, p_inst number, p_trx number) is
  select producer_trans_id,
    producer_sr_instance_id,
    from_operation_seq_id,
    from_operation_sequence,
    from_resource_sequence,
    consumer_trans_id,
    consumer_sr_instance_id,
    to_operation_seq_id,
    to_operation_sequence,
    to_resource_sequence,
    from_start_date,
    from_end_date,
    from_quantity,
    to_start_date,
    to_end_date,
    -23453 allocation_type,
    nvl(dependency_type_id, -1) dependency_type,
   minimum_time_offset,
   maximum_time_offset,
   actual_time_offset
  from msc_material_flow_details_v
  where plan_id = p_plan
    and ( ( producer_sr_instance_id = p_inst and producer_trans_id = p_trx )
    or ( consumer_sr_instance_id = p_inst and consumer_trans_id = p_trx ) );

  l_producer_trans_id msc_gantt_utils.number_arr;
  l_producer_sr_instance_id msc_gantt_utils.number_arr;
  l_producer_op_seq_id msc_gantt_utils.number_arr;
  l_producer_op_seq_num msc_gantt_utils.number_arr;
  l_producer_res_seq_num msc_gantt_utils.number_arr;
  l_consumer_trans_id msc_gantt_utils.number_arr;
  l_consumer_sr_instance_id msc_gantt_utils.number_arr;
  l_consumer_op_seq_id msc_gantt_utils.number_arr;
  l_consumer_op_seq_num msc_gantt_utils.number_arr;
  l_consumer_res_seq_num msc_gantt_utils.number_arr;
  l_segment_start_date msc_gantt_utils.date_arr;
  l_segment_end_date msc_gantt_utils.date_arr;
  l_segment_quantity msc_gantt_utils.number_arr;
  l_consumer_start_date msc_gantt_utils.date_arr;
  l_consumer_end_date msc_gantt_utils.date_arr;
  l_allocation_type msc_gantt_utils.number_arr;
  l_dependency_type msc_gantt_utils.number_arr;
  l_minimum_time_offset msc_gantt_utils.number_arr;
  l_maximum_time_offset msc_gantt_utils.number_arr;
  l_actual_time_offset msc_gantt_utils.number_arr;

begin
    l_len := length(p_trx_list);
    while l_len > 0 loop
      l_one_record := substr(p_trx_list,instr(p_trx_list,'(',1,i)+1,
        instr(p_trx_list,')',1,i)-instr(p_trx_list,'(',1,i)-1);
      l_inst_id := to_number(substr(l_one_record,1,instr(l_one_record,',')-1));
      l_node_type := to_number(substr(l_one_record,instr(l_one_record,',',1,1)+1,
        instr(l_one_record,',',1,2)-instr(l_one_record,',',1,1)-1));
      l_trx_id := to_number(substr(l_one_record,instr(l_one_record,',',1,2)+1));

      if (l_node_type = res_node) then
        null;
      elsif (l_node_type in (JOB_NODE, COPROD_NODE) ) then
        open c_seg_peg(p_plan_id, l_inst_id, l_trx_id);
        fetch c_seg_peg bulk collect into l_producer_trans_id, l_producer_sr_instance_id,
	  l_producer_op_seq_id, l_producer_op_seq_num, l_producer_res_seq_num,
	  l_consumer_trans_id, l_consumer_sr_instance_id,
	  l_consumer_op_seq_id, l_consumer_op_seq_num, l_consumer_res_seq_num,
	  l_segment_start_date, l_segment_end_date, l_segment_quantity,
	  l_consumer_start_date, l_consumer_end_date, l_allocation_type, l_dependency_type,
	  l_minimum_time_offset, l_maximum_time_offset, l_actual_time_offset;
        close c_seg_peg;

      sendSegmentPegStream(SEGMENT_PEG_ROW_TYPE, i, 1,
        l_producer_trans_id, l_producer_sr_instance_id,
        l_producer_op_seq_id, l_producer_op_seq_num, l_producer_res_seq_num,
	l_consumer_trans_id, l_consumer_sr_instance_id,
	l_consumer_op_seq_id, l_consumer_op_seq_num, l_consumer_res_seq_num,
	l_segment_start_date, l_segment_end_date, l_segment_quantity,
	l_consumer_start_date, l_consumer_end_date, l_allocation_type, l_dependency_type,
        l_minimum_time_offset, l_maximum_time_offset, l_actual_time_offset,
	p_out_data);

      end if;
      i := i+1;
      l_len := l_len - length(l_one_record)-3;
    end loop;
end segmentPegging;

procedure resCharges(p_query_id number, p_plan_id number,
  p_trx_list varchar2, p_out_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl) is

  v_start_date msc_gantt_utils.date_arr;
  v_end_date msc_gantt_utils.date_arr;
  v_qty msc_gantt_utils.number_arr;

  i number := 1;

  l_len number;
  l_inst_id number;
  l_trx_id number;
  l_one_record varchar2(100);

  l_index number :=0;
begin
  l_len := length(p_trx_list);
  while l_len > 0 loop -- {
    l_one_record := substr(p_trx_list,instr(p_trx_list,'(',1,i)+1,
      instr(p_trx_list,')',1,i)-instr(p_trx_list,'(',1,i)-1);
    l_inst_id := to_number(substr(l_one_record,1,instr(l_one_record,',')-1));
    l_trx_id := to_number(substr(l_one_record,instr(l_one_record,',',1,1)+1));

    l_index := l_index + 1;

    select charge_start_datetime, charge_end_datetime, charge_quantity
    bulk collect into v_start_date, v_end_date, v_qty
    from msc_resource_charges
    where plan_id = p_plan_id
      and sr_instance_id = l_inst_id
      and res_transaction_id = l_trx_id
    order by 1;

    sendResReqAvailSuppStream(RES_CHARGES_ROW_TYPE, l_index, 1,
      v_start_date, v_end_date, v_qty, v_qty, v_qty, p_out_data);

    i := i+1;
    l_len := l_len - length(l_one_record)-3;

  end loop; -- }
end resCharges;

procedure setRowFlag(p_query_id number, p_node_id number, p_row_flag number) is
begin
  update msc_gantt_query
    set row_flag = p_row_flag
  where query_id = p_query_id
    and row_index = p_node_id;
end setRowFlag;


procedure sendSupplierNames(p_query_id number,
  p_from_index number, p_to_index number,
  p_name_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_sort_column varchar2 default null,
  p_sort_order varchar2 default null) is

  l_node_id char_arr;
  l_supp char_arr;
  l_supp_site char_arr;
  l_org char_arr;
  l_item char_arr;
  l_buyer char_arr;
  l_planner char_arr;

  l_inst_id number_arr;
  l_org_id number_arr;
  l_supp_id number_arr;
  l_supp_site_id number_arr;
  l_item_id number_arr;

  i number := 1;
  j number := 0;
  k number := 0;

  v_one_record varchar2(300);
  oneBigRecord maxCharTbl := maxCharTbl(0);
  v_max_len number;
  reqCount number;

  TYPE GanttCurTyp IS REF CURSOR;
  the_cursor GanttCurTyp;
  sql_stmt varchar2(32000);
begin

  sql_stmt := ' select distinct mgq.row_index,
    mis.supplier_id,
    mis.supplier_site_id,
    mis.inventory_item_id,
    mtp.partner_name SUPPLIER,
    mtps.tp_site_code SUPPLIER_SITE,
    --mtp2.organization_code ORGANIZATION,
    null ORGANIZATION,
    msi.item_name ITEM,
    null BUYER,
    null PLANNER
  FROM msc_trading_partners mtp,
    --msc_trading_partners mtp2,
    msc_trading_partner_sites mtps,
    msc_system_items msi,
    msc_item_suppliers mis,
    msc_gantt_query mgq
  WHERE mgq.query_id = :p_query_id
    and mis.plan_id = mgq.plan_id
    and mis.supplier_id = mgq.supplier_id
    and mis.supplier_site_id = mgq.supplier_site_id
    and mis.inventory_item_id = mgq.inventory_item_id
    and mis.plan_id = msi.plan_id
    and mis.organization_id = msi.organization_id
    and mis.sr_instance_id = msi.sr_instance_id
    and mis.inventory_item_id = msi.inventory_item_id
    and mtp.partner_id = mis.supplier_id
    and mtp.partner_type = 1
    and mtps.partner_id(+) = mis.supplier_id
    and mtps.partner_site_id(+) = mis.supplier_site_id
    --and mtp2.sr_tp_id = mis.organization_id
    --and mtp2.sr_instance_id = mis.sr_instance_id
    --and mtp2.partner_type = 3
   ';

  if ( p_sort_column is not null ) then
    sql_stmt := sql_stmt ||' order by '||p_sort_column||' '||p_sort_order;
  else
    sql_stmt := sql_stmt ||' order by mgq.row_index ';
  end if;

  --put_line('sql-stmt' ||sql_stmt);

  open the_cursor for sql_stmt using p_query_id;
  fetch the_cursor bulk collect into l_node_id, l_supp_id,
    l_supp_site_id, l_item_id, l_supp, l_supp_site, l_org, l_item, l_buyer, l_planner;
  close the_cursor;

  put_line('sendSupplierNames: names: '||l_node_id.count);

    j := 1;
    reqCount := 0;
    p_name_data.delete;
    oneBigRecord.delete;
    oneBigRecord.extend;
    for i in 1..l_node_id.count loop -- {
      if ( i >= p_from_index) then -- {
        put_line(' supList '||l_node_id(i)||null_space||l_supp(i));

        v_one_record := l_node_id(i)
          || field_seperator || mbp_null_value_char
          || field_seperator || mbp_null_value_char
          || field_seperator || l_supp_id(i)
          || field_seperator || nvl(to_char(l_supp_site_id(i)), mbp_null_value_char)
          || field_seperator || l_item_id(i)
          || field_seperator || escapeSplChars(l_supp(i))
          || field_seperator || escapeSplChars(l_supp_site(i))
  	  || field_seperator || escapeSplChars(nvl(l_org(i),mbp_null_value_char))
  	  || field_seperator || escapeSplChars(l_item(i))
	  || field_seperator || nvl(escapeSplChars(l_buyer(i)), null_space)
	  || field_seperator || nvl(escapeSplChars(l_planner(i)), null_space);

        reqCount := reqCount + 1;
        v_max_len := nvl(length(oneBigRecord(j)),0) + nvl(length(v_one_record),0);
        if v_max_len > 30000 then
          j := j+1;
          oneBigRecord.extend;
        end if;
        if ( oneBigRecord(j) is null ) then
          oneBigRecord(j) := record_seperator || v_one_record;
        else
          oneBigRecord(j) := oneBigRecord(j) || record_seperator ||v_one_record;
        end if;
        setRowFlag(p_query_id, l_node_id(i), SYS_YES);
      end if; -- }
      exit when i >= p_to_index;
    end loop; -- }

    p_name_data.extend;
    k := k+1;
    j := 1;
    p_name_data(k) := reqCount || oneBigRecord(1);

    for j in 2.. oneBigRecord.count loop -- {
      p_name_data.extend;
      k := k+1;
      p_name_data(k) := oneBigRecord(j);
    end loop; -- }

end sendSupplierNames;

procedure sendResourceNames(p_query_id number,
  p_from_index number, p_to_index number,
  p_name_data IN OUT NOCOPY msc_gantt_utils.maxCharTbl,
  p_sort_column varchar2 default null,
  p_sort_order varchar2 default null) is

  l_node_id char_arr;
  l_org char_arr;
  l_dept char_arr;
  l_owning_dept char_arr;
  l_resource_code char_arr;
  l_resource_type char_arr;
  l_res_inst char_arr;

  l_inst_id number_arr;
  l_org_id number_arr;
  l_dept_id number_arr;
  l_res_id number_arr;
  l_res_instance_id number_arr;
  l_serial_number char_arr;

  i number := 1;
  j number := 0;
  k number := 0;

  v_one_record varchar2(300);
  oneBigRecord maxCharTbl := maxCharTbl(0);
  v_max_len number;
  reqCount number;

  TYPE GanttCurTyp IS REF CURSOR;
  the_cursor GanttCurTyp;
  sql_stmt varchar2(32000);
begin

  sql_stmt := ' select mgq.row_index,
    mgq.sr_instance_id,
    mgq.organization_id,
    mgq.department_id,
    mgq.resource_id,
    mgq.res_instance_id,
    mgq.serial_number,
    msc_get_name.org_code(res.organization_id, res.sr_instance_id) ORGANIZATION,
    res.department_code DEPARTMENT,
    decode(res.resource_id,-1, null,
      msc_get_name.department_code(2, res.owning_department_id,
      res.organization_id, res.plan_id,res.sr_instance_id)) OWN_DEPT,
    res.resource_code RESOURCE_CODE,
    msc_get_name.lookup_meaning(''BOM_RESOURCE_TYPE'',res.resource_type) RES_TYPE,
    msc_gantt_utils.getDeptResInstCode(res.plan_id, res.sr_instance_id, res.organization_id,
      res.department_id, res.resource_id, mgq.res_instance_id, mgq.serial_number) EQUIP_NUMBER
  from msc_department_resources res,
    msc_gantt_query mgq
  where mgq.query_id = :p_query_id
    and res.plan_id = mgq.plan_id
    and res.sr_instance_id = mgq.sr_instance_id
    and res.organization_id = mgq.organization_id
    and res.department_id = mgq.department_id
    and res.resource_id = mgq.resource_id ';

  if ( p_sort_column is not null ) then
    sql_stmt := sql_stmt ||' order by '||p_sort_column||' '||p_sort_order;
  else
    sql_stmt := sql_stmt ||' order by mgq.row_index ';
  end if;

  open the_cursor for sql_stmt using p_query_id;
  fetch the_cursor bulk collect into l_node_id, l_inst_id, l_org_id,
    l_dept_id, l_res_id, l_res_instance_id, l_serial_number, l_org, l_dept, l_owning_dept,
    l_resource_code, l_resource_type, l_res_inst;
  close the_cursor;

  put_line('sendResourceNames: names: '||l_node_id.count);

    j := 1;
    reqCount := 0;
    p_name_data.delete;
    oneBigRecord.delete;
    oneBigRecord.extend;
    for i in 1..l_node_id.count loop -- {

      if ( i >= p_from_index) then -- {
        put_line(' resList '||l_node_id(i)||null_space||l_resource_code(i));

        v_one_record := l_node_id(i)
          || field_seperator || l_inst_id(i)
          || field_seperator || l_org_id(i)
          || field_seperator || l_dept_id(i)
          || field_seperator || l_res_id(i)
          || field_seperator || nvl(l_res_instance_id(i), mbp_null_value_char)
          || field_seperator || nvl(l_serial_number(i), mbp_null_value_char)
          || field_seperator || escapeSplChars(l_org(i))
    	  || field_seperator || escapeSplChars(l_dept(i))
	  || field_seperator || nvl(escapeSplChars(l_owning_dept(i)), null_space)
	  || field_seperator || escapeSplChars(l_resource_code(i))
	  || field_seperator || escapeSplChars(l_resource_type(i))
	  || field_seperator || nvl(escapeSplChars(l_res_inst(i)), null_space);

        reqCount := reqCount + 1;
        v_max_len := nvl(length(oneBigRecord(j)),0) + nvl(length(v_one_record),0);
        if v_max_len > 30000 then
          j := j+1;
          oneBigRecord.extend;
        end if;
        if ( oneBigRecord(j) is null ) then
          oneBigRecord(j) := record_seperator || v_one_record;
        else
          oneBigRecord(j) := oneBigRecord(j) || record_seperator ||v_one_record;
        end if;
        setRowFlag(p_query_id, l_node_id(i), SYS_YES);
      end if; -- }
      exit when i >= p_to_index;
    end loop; -- }

    p_name_data.extend;
    k := k+1;
    j := 1;
    if (reqCount = 0) then
      p_name_data(k) := reqCount;
      return;
    end if;

    p_name_data(k) := reqCount || oneBigRecord(1);
    for j in 2.. oneBigRecord.count loop
      p_name_data.extend;
      k := k+1;
      p_name_data(k) := oneBigRecord(j);
    end loop;
end sendResourceNames;

function countStrOccurence (p_string_in in varchar2,
  p_substring_in in varchar2) return number is
  search_loc number := 1;
  substring_len number := length (p_substring_in);
  check_again boolean := true;
  return_value number := 1;
begin
  if p_string_in is not null and p_substring_in is not null then
    while check_again
    loop
      search_loc := INSTR (p_string_in, p_substring_in, search_loc, 1);
      check_again := search_loc > 0;
      if check_again then
        return_value := return_value + 1;
        search_loc := search_loc + substring_len;
      end if;
     end loop;
  end if;
  return return_value;
END countStrOccurence;

function getResBatchNodeLabel(p_res_req_type varchar2, p_org varchar2,
  p_batch_qty varchar2, p_batch_number varchar2, p_batch_util_pct varchar2) return varchar2 is

  l_node_label1 varchar2(500);
  l_node_label2 varchar2(500);
  l_node_label3 varchar2(500);

begin
  if ( g_gantt_batches_label_1 = g_batch_none_lbl ) then -- {
    l_node_label1 := null;
  elsif ( g_gantt_batches_label_1 = g_batch_setup_lbl ) then
    l_node_label1 := p_res_req_type;
  elsif ( g_gantt_batches_label_1 = g_batch_org_lbl ) then
    l_node_label1 := p_org;
  elsif ( g_gantt_batches_label_1 = g_batch_qty_lbl ) then
    l_node_label1 := p_batch_qty;
  elsif ( g_gantt_batches_label_1 = g_batch_num_lbl ) then
    l_node_label1 := p_batch_number;
  elsif ( g_gantt_batches_label_1 = g_batch_util_pct_lbl ) then
    l_node_label1 := p_batch_util_pct * 100;
  end if; -- }

  if ( g_gantt_batches_label_2 = g_batch_none_lbl ) then -- {
    l_node_label2 := null;
  elsif ( g_gantt_batches_label_2 = g_batch_setup_lbl ) then
    l_node_label2 := p_res_req_type;
  elsif ( g_gantt_batches_label_2 = g_batch_org_lbl ) then
    l_node_label2 := p_org;
  elsif ( g_gantt_batches_label_2 = g_batch_qty_lbl ) then
    l_node_label2 := p_batch_qty;
  elsif ( g_gantt_batches_label_2 = g_batch_num_lbl ) then
    l_node_label2 := p_batch_number;
  elsif ( g_gantt_batches_label_2 = g_batch_util_pct_lbl ) then
    l_node_label2 := p_batch_util_pct * 100;
  end if; -- }

  if ( g_gantt_batches_label_3 = g_batch_none_lbl ) then -- {
    l_node_label3 := null;
  elsif ( g_gantt_batches_label_3 = g_batch_setup_lbl ) then
    l_node_label3 := p_res_req_type;
  elsif ( g_gantt_batches_label_3 = g_batch_org_lbl ) then
    l_node_label3 := p_org;
  elsif ( g_gantt_batches_label_3 = g_batch_qty_lbl ) then
    l_node_label3 := p_batch_qty;
  elsif ( g_gantt_batches_label_3 = g_batch_num_lbl ) then
    l_node_label3 := p_batch_number;
  elsif ( g_gantt_batches_label_3 = g_batch_util_pct_lbl ) then
    l_node_label3 := p_batch_util_pct * 100;
  end if; -- }

  if ( l_node_label1 is null and l_node_label2 is null and l_node_label3 is null ) then
    return null_space;
  end if;

  return substr(nvl(l_node_label1,null_space),1,80) || COLON_SEPARATOR ||
    substr(nvl(l_node_label2,null_space),1,80) || COLON_SEPARATOR ||
    substr(nvl(l_node_label3,null_space),1,80);

end getResBatchNodeLabel;

function getResActResNodeLabelLocal(p_label number,
  res_label_rec c_res_node_label%rowtype) return varchar2 is
  l_node_label1 varchar2(500);
begin
  if ( p_label = g_res_none_lbl ) then -- {
    l_node_label1 := null;
  elsif ( p_label = g_res_act_item_lbl ) then
    l_node_label1 := res_label_rec.item_name;
  elsif ( p_label = g_res_act_setup_lbl ) then
    l_node_label1 := res_label_rec.setup_type;
  elsif ( p_label = g_res_act_org_lbl ) then
    l_node_label1 := res_label_rec.org_code;
  elsif ( p_label = g_res_act_qty_lbl ) then
    l_node_label1 := res_label_rec.qty;
  elsif ( p_label = g_res_act_batch_lbl ) then
    l_node_label1 := res_label_rec.batch_number;
  elsif ( p_label = g_res_act_alt_flag_lbl ) then
    l_node_label1 := res_label_rec.alt_rtg;
  elsif ( p_label = g_res_act_units_lbl ) then
    l_node_label1 := res_label_rec.assigned_units;
  elsif ( p_label = g_res_act_order_type_lbl ) then
    l_node_label1 := res_label_rec.order_type;
  elsif ( p_label = g_res_act_op_sdesc_lbl ) then
    l_node_label1 := res_label_rec.op_sdesc;
  elsif ( p_label = g_res_act_op_seq_lbl ) then
    l_node_label1 := res_label_rec.operation_seq_num;
  elsif ( p_label = g_res_act_req_comp_date_lbl ) then
    l_node_label1 := to_char(res_label_rec.req_comp_date, format_mask);
  elsif ( p_label = g_res_act_order_number_lbl ) then
    l_node_label1 := res_label_rec.order_number;
  end if; -- }
  return l_node_label1;
end getResActResNodeLabelLocal;

function getResActResNodeLabel(p_plan_id number, p_inst_id number, p_trx_id number) return varchar2 is

  res_label_rec c_res_node_label%rowtype;
  l_node_label1 varchar2(500);
  l_node_label2 varchar2(500);
  l_node_label3 varchar2(500);
begin
  open c_res_node_label(p_plan_id, p_inst_id, p_trx_id);
  fetch c_res_node_label into res_label_rec;
  close c_res_node_label;

  l_node_label1 := getResActResNodeLabelLocal(g_gantt_act_label_1, res_label_rec);
  l_node_label2 := getResActResNodeLabelLocal(g_gantt_act_label_2, res_label_rec);
  l_node_label3 := getResActResNodeLabelLocal(g_gantt_act_label_3, res_label_rec);

  if ( l_node_label1 is null and l_node_label2 is null and l_node_label3 is null ) then
    return null_space;
  end if;

  return substr(nvl(l_node_label1,null_space),1,80) || COLON_SEPARATOR ||
    substr(nvl(l_node_label2,null_space),1,80) || COLON_SEPARATOR ||
    substr(nvl(l_node_label3,null_space),1,80);

end getResActResNodeLabel;

function getOrderViewResNodeLabelLocal(p_label number,
  res_label_rec c_res_node_label%rowtype) return varchar2 is
  l_node_label1 varchar2(500);
begin
  if ( p_label = g_res_none_lbl ) then -- {
    l_node_label1 := null;
  elsif ( p_label = g_res_seq_lbl ) then
    l_node_label1 := res_label_rec.resource_seq_num;
  elsif ( p_label = g_res_dept_lbl ) then
    l_node_label1 := res_label_rec.department_code;
  elsif ( p_label = g_res_lbl ) then
    l_node_label1 := res_label_rec.resource_code;
  elsif ( p_label = g_res_setup_lbl ) then
    l_node_label1 := res_label_rec.setup_type;
  elsif ( p_label = g_res_batch_lbl ) then
    l_node_label1 := res_label_rec.batch_number;
  elsif ( p_label = g_res_alt_flag_lbl ) then
    l_node_label1 := res_label_rec.alt_rtg;
  elsif ( p_label = g_res_units_lbl ) then
    l_node_label1 := res_label_rec.assigned_units;
  end if; -- }
  return l_node_label1;
end getOrderViewResNodeLabelLocal;

function getOrderViewResNodeLabel(p_plan_id number, p_inst_id number,
  p_trx_id number) return varchar2 is

  l_node_label1 varchar2(500);
  l_node_label2 varchar2(500);
  l_node_label3 varchar2(500);

  res_label_rec c_res_node_label%rowtype;
begin
  open c_res_node_label(p_plan_id, p_inst_id, p_trx_id);
  fetch c_res_node_label into res_label_rec;
  close c_res_node_label;

  l_node_label1 := getOrderViewResNodeLabelLocal(g_gantt_res_act_label_1, res_label_rec);
  l_node_label2 := getOrderViewResNodeLabelLocal(g_gantt_res_act_label_2, res_label_rec);
  l_node_label3 := getOrderViewResNodeLabelLocal(g_gantt_res_act_label_3, res_label_rec);

  if ( l_node_label1 is null and l_node_label2 is null and l_node_label3 is null ) then
    return null_space;
  end if;

  return substr(nvl(l_node_label1,null_space),1,80) || COLON_SEPARATOR ||
    substr(nvl(l_node_label2,null_space),1,80) || COLON_SEPARATOR ||
    substr(nvl(l_node_label3,null_space),1,80);

end getOrderViewResNodeLabel;

function getOpNodeLabel(p_op_seq varchar2,
  p_dept varchar2, p_op_desc varchar2, p_plan_id number) return varchar2 is

  l_node_label1 varchar2(500);
  l_node_label2 varchar2(500);
  l_node_label3 varchar2(500);

  cursor c_dept (p_plan number, p_supply number) is
  select distinct department_line_code
  from msc_resource_requirements_v
  where plan_id = p_plan
  and source_transaction_id = p_supply;

  l_dept varchar2(240);
begin
  if ( g_gantt_oper_label_1 = g_op_dept_lbl or
    g_gantt_oper_label_2 = g_op_dept_lbl or
    g_gantt_oper_label_3 = g_op_dept_lbl) then
    open c_dept(p_plan_id, p_dept);
    fetch c_dept into l_dept;
    close c_dept;
  end if;

  if ( g_gantt_oper_label_1 = g_op_none_lbl ) then -- {
    l_node_label1 := null;
  elsif ( g_gantt_oper_label_1 = g_op_seq_lbl ) then
    l_node_label1 := p_op_seq;
  elsif ( g_gantt_oper_label_1 = g_op_dept_lbl ) then
    l_node_label1 := l_dept;
  elsif ( g_gantt_oper_label_1 = g_op_desc_lbl ) then
    l_node_label1 := p_op_desc;
  end if; -- }

  if ( g_gantt_oper_label_2 = g_op_none_lbl ) then -- {
    l_node_label2 := null;
  elsif ( g_gantt_oper_label_2 = g_op_seq_lbl ) then
    l_node_label2 := p_op_seq;
  elsif ( g_gantt_oper_label_2 = g_op_dept_lbl ) then
    l_node_label2 := l_dept;
  elsif ( g_gantt_oper_label_2 = g_op_desc_lbl ) then
    l_node_label2 := p_op_desc;
  end if; -- }

  if ( g_gantt_oper_label_3 = g_op_none_lbl ) then -- {
    l_node_label3 := null;
  elsif ( g_gantt_oper_label_3 = g_op_seq_lbl ) then
    l_node_label3 := p_op_seq;
  elsif ( g_gantt_oper_label_3 = g_op_dept_lbl ) then
    l_node_label3 := l_dept;
  elsif ( g_gantt_oper_label_3 = g_op_desc_lbl ) then
    l_node_label3 := p_op_desc;
  end if; -- }

  if ( l_node_label1 is null and l_node_label2 is null and l_node_label3 is null ) then
    return null_space;
  end if;

  return substr(nvl(l_node_label1,null_space),1,80) || COLON_SEPARATOR ||
    substr(nvl(l_node_label2,null_space),1,80) || COLON_SEPARATOR ||
    substr(nvl(l_node_label3,null_space),1,80);

end getOpNodeLabel;

function getJobNodeLabel(p_item_name varchar2, p_org_code varchar2,
  p_order_number varchar2, p_order_type varchar2, p_qty number) return varchar2 is
  l_node_label1 varchar2(500);
  l_node_label2 varchar2(500);
  l_node_label3 varchar2(500);
begin
  if ( g_gantt_supply_orders_label_1 = g_job_none_lbl ) then -- {
    l_node_label1 := null;
  elsif ( g_gantt_supply_orders_label_1 = g_job_item_lbl ) then
    l_node_label1 := p_item_name;
  elsif ( g_gantt_supply_orders_label_1 = g_job_org_lbl ) then
    l_node_label1 := p_org_code;
  elsif ( g_gantt_supply_orders_label_1 = g_job_order_number_lbl ) then
    l_node_label1 := p_order_number;
  elsif ( g_gantt_supply_orders_label_1 = g_job_order_type_lbl ) then
    l_node_label1 := p_order_type;
  elsif ( g_gantt_supply_orders_label_1 = g_job_qty_lbl ) then
    l_node_label1 := to_char(p_qty);
  end if; -- }

  if ( g_gantt_supply_orders_label_2 = g_job_none_lbl ) then -- {
    l_node_label2 := null;
  elsif ( g_gantt_supply_orders_label_2 = g_job_item_lbl ) then
    l_node_label2 := p_item_name;
  elsif ( g_gantt_supply_orders_label_2 = g_job_org_lbl ) then
    l_node_label2 := p_org_code;
  elsif ( g_gantt_supply_orders_label_2 = g_job_order_number_lbl ) then
    l_node_label2 := p_order_number;
  elsif ( g_gantt_supply_orders_label_2 = g_job_order_type_lbl ) then
    l_node_label2 := p_order_type;
  elsif ( g_gantt_supply_orders_label_2 = g_job_qty_lbl ) then
    l_node_label2 := to_char(p_qty);
  end if; -- }

  if ( g_gantt_supply_orders_label_3 = g_job_none_lbl ) then -- {
    l_node_label3 := null;
  elsif ( g_gantt_supply_orders_label_3 = g_job_item_lbl ) then
    l_node_label3 := p_item_name;
  elsif ( g_gantt_supply_orders_label_3 = g_job_org_lbl ) then
    l_node_label3 := p_org_code;
  elsif ( g_gantt_supply_orders_label_3 = g_job_order_number_lbl ) then
    l_node_label3 := p_order_number;
  elsif ( g_gantt_supply_orders_label_3 = g_job_order_type_lbl ) then
    l_node_label3 := p_order_type;
  elsif ( g_gantt_supply_orders_label_3 = g_job_qty_lbl ) then
    l_node_label3 := to_char(p_qty);
  end if; -- }

  if ( l_node_label1 is null and l_node_label2 is null and l_node_label3 is null ) then
    return null_space;
  end if;

  return substr(nvl(l_node_label1,null_space),1,80) || COLON_SEPARATOR ||
    substr(nvl(l_node_label2,null_space),1,80) || COLON_SEPARATOR ||
    substr(nvl(l_node_label3,null_space),1,80);

end getJobNodeLabel;

procedure getUserPref(p_pref_id number) is

  cursor c_pref_values (p_user number, p_pref_id number, p_plan_type number, p_from_flag number)is
  select mupv.key pref_key, nvl(mupv.value, mupk.default_value) pref_value
  from msc_user_preferences mup,
    msc_user_preference_keys mupk,
    msc_user_preference_values mupv
  where p_from_flag <> 0
    and mup.user_id = p_user
    and mup.preference_id = p_pref_id
    and mup.preference_id = mupv.preference_id
    and mupv.key = mupk.preference_key
    and mupk.plan_type = 1 -- look at only p_plan_type 1, per emily
    and mupv.key in ('CATEGORY_SET_ID',
      'GANTT_RA_ACT_LBL_1', 'GANTT_RA_ACT_LBL_2', 'GANTT_RA_ACT_LBL_3',
      'GANTT_RA_BATCH_LBL_1', 'GANTT_RA_BATCH_LBL_2', 'GANTT_RA_BATCH_LBL_3',
      'GANTT_SUP_ORD_LBL_1', 'GANTT_SUP_ORD_LBL_2', 'GANTT_SUP_ORD_LBL_3',
      'GANTT_OPR_LBL_1', 'GANTT_OPR_LBL_2', 'GANTT_OPR_LBL_3',
      'GANTT_RES_ACT_LBL_1', 'GANTT_RES_ACT_LBL_2', 'GANTT_RES_ACT_LBL_3',
      'GANTT_RA_TOL_DAYS_EARLY', 'GANTT_RA_TOL_DAYS_LATE', 'SUMMARY_DECIMAL_PLACES',
      'GANTT_RH_TOL_DAYS_EARLY', 'GANTT_RH_TOL_DAYS_LATE')
   union all
   select mupk.preference_key pref_key,
     mupk.default_value pref_value
   from  msc_user_preference_keys mupk
   where p_from_flag = 0
     and mupk.plan_type = 1 -- look at only p_plan_type 1, per emily
     and mupk.preference_key in ('CATEGORY_SET_ID',
      'GANTT_RA_ACT_LBL_1', 'GANTT_RA_ACT_LBL_2', 'GANTT_RA_ACT_LBL_3',
      'GANTT_RA_BATCH_LBL_1', 'GANTT_RA_BATCH_LBL_2', 'GANTT_RA_BATCH_LBL_3',
      'GANTT_SUP_ORD_LBL_1', 'GANTT_SUP_ORD_LBL_2', 'GANTT_SUP_ORD_LBL_3',
      'GANTT_OPR_LBL_1', 'GANTT_OPR_LBL_2', 'GANTT_OPR_LBL_3',
      'GANTT_RES_ACT_LBL_1', 'GANTT_RES_ACT_LBL_2', 'GANTT_RES_ACT_LBL_3',
      'GANTT_RA_TOL_DAYS_EARLY', 'GANTT_RA_TOL_DAYS_LATE', 'SUMMARY_DECIMAL_PLACES',
      'GANTT_RH_TOL_DAYS_EARLY', 'GANTT_RH_TOL_DAYS_LATE');

  cursor c_rows (p_pref_id number) is
  select count(*)
  from msc_user_preference_values mupv
  where mupv.preference_id = p_pref_id;

  l_from_flag number;

  cursor c_default_cat is
  select category_set_id
  from msc_category_sets
  where default_flag = 1;

  l_dflt_cat_set_id number;

begin
  -- order view
  -- supply bar : 0 none, 1 item, 2 org, 3 order number, 4 order type, 5 qty
  -- op bar : 0 none, 1 op seq, 2 dept, 3 op desc
  -- res bar : 0 none, 1 res seq, 2 dept, 3 res, 4 setup type, 5 batch no, 6 alt flag, 7 assgned units

  -- res activities view
  -- res bar : same as above
  -- batch bar : 0 none, 1 setup type, 2 org, 3 batch qty, 4 batch no, 5 batch util %

  if ( g_pref_id is null or g_pref_id <> p_pref_id ) then -- {
    if (p_pref_id is null) then
      g_pref_id := mbp_null_value;
    else
      g_pref_id := p_pref_id;
    end if;

    open c_rows(g_pref_id);
    fetch c_rows into l_from_flag;
    close c_rows;
    for c_user_pref_row in c_pref_values(fnd_global.user_id, g_pref_id, g_plan_type, l_from_flag)
    loop -- {
      if ( c_user_pref_row.pref_key = 'CATEGORY_SET_ID' ) then -- {
        if ( rtrim(ltrim(c_user_pref_row.pref_value)) is null) then
	  open c_default_cat;
	  fetch c_default_cat into l_dflt_cat_set_id;
	  close c_default_cat;
	  if ( l_dflt_cat_set_id is null ) then
	    l_dflt_cat_set_id := fnd_profile.value('MSC_SRA_CATEGORY_SET');
	  end if;
          g_category_set_id := l_dflt_cat_set_id;
	else
          g_category_set_id := c_user_pref_row.pref_value;
	end if;
      elsif ( c_user_pref_row.pref_key = 'GANTT_RA_ACT_LBL_1' ) then
        g_gantt_act_label_1 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_RA_ACT_LBL_2' ) then
        g_gantt_act_label_2 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_RA_ACT_LBL_3' ) then
        g_gantt_act_label_3 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_RA_BATCH_LBL_1' ) then
        g_gantt_batches_label_1 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_RA_BATCH_LBL_2' ) then
        g_gantt_batches_label_2 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_RA_BATCH_LBL_3' ) then
        g_gantt_batches_label_3 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_SUP_ORD_LBL_1' ) then
        g_gantt_supply_orders_label_1 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_SUP_ORD_LBL_2' ) then
        g_gantt_supply_orders_label_2 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_SUP_ORD_LBL_3' ) then
        g_gantt_supply_orders_label_3 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_OPR_LBL_1' ) then
        g_gantt_oper_label_1 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_OPR_LBL_2' ) then
        g_gantt_oper_label_2 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_OPR_LBL_3' ) then
        g_gantt_oper_label_3 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_RES_ACT_LBL_1' ) then
        g_gantt_res_act_label_1 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_RES_ACT_LBL_2' ) then
        g_gantt_res_act_label_2 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_RES_ACT_LBL_3' ) then
       g_gantt_res_act_label_3 := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_RA_TOL_DAYS_EARLY' ) then
       g_gantt_ra_toler_days_early := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_RA_TOL_DAYS_LATE' ) then
       g_gantt_ra_toler_days_late := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_RH_TOL_DAYS_EARLY' ) then
       g_gantt_rh_toler_days_early := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'GANTT_RH_TOL_DAYS_LATE' ) then
       g_gantt_rh_toler_days_late := c_user_pref_row.pref_value;
      elsif ( c_user_pref_row.pref_key = 'SUMMARY_DECIMAL_PLACES' ) then
       if ( c_user_pref_row.pref_value is null) then
         round_factor := 2;
       else
         round_factor :=  c_user_pref_row.pref_value;
       end if;
      end if; -- }
    end loop; -- }
  end if; -- }
end getUserPref;

procedure addToOutStream(p_one_record varchar2,
  p_out_data_index in out nocopy number,
  p_out_data in out nocopy msc_gantt_utils.maxchartbl) is
begin
  if (nvl(length(p_out_data(1)),0) = 1) then -- {
    p_out_data(1) := p_one_record;
  elsif ( nvl(length(p_out_data(p_out_data_index)),0) + length(p_one_record) < 31000 ) then
    p_out_data(p_out_data_index) := p_out_data(p_out_data_index) || RECORD_SEPERATOR || p_one_record;
  else
    p_out_data_index := p_out_data_index + 1;
    p_out_data.extend;
    p_out_data(p_out_data_index) := RECORD_SEPERATOR || p_one_record;
  end if; -- }

end addToOutStream;

procedure parseParentLink(p_list varchar2, pQueryId in number) is
  occurrence NUMBER := 1;
  stringstart NUMBER := 1;
  stringend NUMBER := 1;
  pos NUMBER;
  token NUMBER;
begin
  loop
    pos := INSTR(p_list, ',', 1, occurrence);
    occurrence := occurrence + 1;
    IF pos = 0 THEN
      stringend := LENGTH(p_list);
      token := to_number(SUBSTR(p_list, stringstart, stringend - stringstart + 1));
      if token is not null then
        insert into msc_form_query(
          query_id, last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, number1)
        values (
          pQueryId, trunc(sysdate), -1, trunc(sysdate), -1, -1, token );
      end if;
      exit;
    end if;
    stringend := pos - 1;
    token := to_number(substr(p_list, stringstart, stringend - stringstart + 1));
    if token is not null then
      insert into msc_form_query(
        query_id, last_update_date, last_updated_by, creation_date, created_by,
        last_update_login, number1)
      values (
        pQueryId, trunc(sysdate), -1, trunc(sysdate), -1, -1, token);
    end if;
    stringstart := stringend + 2;
  end loop;
end parseParentLink;

function getParentLinkRec(p_query_id number, p_plan_id number,
  p_trx number, p_parent_link varchar2) return varchar2 is

  cursor c_alloc_qty (p_plan number, p_trx number,
    p_mfq_query_id number, p_mgq_query_id number) is
   select mgq.row_index,
     sum(nvl(mfp1.allocated_quantity,0)) allocated_quantity
   from msc_full_pegging mfp1,
     msc_full_pegging mfp2,
     msc_gantt_query mgq,
     msc_form_query mfq
   where mfp1.plan_id = p_plan
     and mfp1.transaction_id = p_trx
     and mfq.query_id = p_mfq_query_id
     and mgq.query_id = p_mgq_query_id
     and mgq.row_index = mfq.number1
     and mfp2.plan_id = mfp1.plan_id
     and mfp2.end_pegging_id = mfp1.end_pegging_id
     and mfp2.transaction_id = mgq.transaction_id
     group by mgq.row_index
   union all
   select mgq.row_index,
     nvl(mfp1.allocated_quantity,0) allocated_quantity
   from msc_full_pegging mfp1,
     msc_gantt_query mgq,
     msc_form_query mfq
   where mfp1.plan_id = p_plan
     and mfp1.transaction_id = p_trx
     and mfq.query_id = p_mfq_query_id
     and mgq.query_id = p_mgq_query_id
     and mgq.row_index = mfq.number1
     and mfp1.demand_id = mgq.transaction_id ;

  l_mfq_query_id number;
  l_row_count number := 0;
  l_parent_link_rec varchar2(2000);
begin

  l_mfq_query_id := getMFQSequence(l_mfq_query_id);
  l_parent_link_rec := null;
  parseParentLink(p_parent_link, l_mfq_query_id);

  put_line(' getParentLinkRec '
    ||' p_plan_id '|| p_plan_id
    ||' p_trx '|| p_trx
    ||' l_mfq_query_id '|| l_mfq_query_id
    ||' p_query_id '||p_query_id);

  for c_alloc_qty_cur in c_alloc_qty (p_plan_id, p_trx, l_mfq_query_id, p_query_id)
  loop
    if (l_parent_link_rec is null) then
      l_parent_link_rec := c_alloc_qty_cur.row_index
	|| FIELD_SEPERATOR || nvl(to_char(fnd_number.number_to_canonical(c_alloc_qty_cur.allocated_quantity)), null_space);
    else
      l_parent_link_rec := l_parent_link_rec|| FIELD_SEPERATOR ||
      c_alloc_qty_cur.row_index
      || FIELD_SEPERATOR || nvl(to_char(fnd_number.number_to_canonical(c_alloc_qty_cur.allocated_quantity)), null_space);
    end if;
    l_row_count := l_row_count + 1;
  end loop;
  l_parent_link_rec := l_row_count || FIELD_SEPERATOR || l_parent_link_rec;

  return l_parent_link_rec;
end getParentLinkRec;

function getResult(p_query_id number,
  p_from_index number, p_to_index number, p_plan_id number,
  p_out_data in out nocopy msc_gantt_utils.maxchartbl,
  p_node_level number default null,
  p_sort_node number default null,
  p_sort_column varchar2 default null,
  p_sort_order varchar2 default null,
  p_res_nodes_only varchar2 default null) return number is

  i number;

  l_row_index msc_gantt_utils.number_arr;
  l_item_prompt msc_gantt_utils.char_arr;
  l_node_type msc_gantt_utils.number_arr;
  l_node_path msc_gantt_utils.char_arr;
  l_parent_link msc_gantt_utils.char_arr;
  l_start_date msc_gantt_utils.date_arr;
  l_start_date_char msc_gantt_utils.char_arr;
  l_end_date msc_gantt_utils.date_arr;
  l_priority msc_gantt_utils.number_arr;

 l_from_setup_code char_arr;
 l_to_setup_code char_arr;
 l_std_op_code char_arr;
 l_changeover_time char_arr;
 l_changeover_penalty char_arr;

  l_critical_flag msc_gantt_utils.number_arr;
  l_item_name msc_gantt_utils.char_arr;
  l_org_code msc_gantt_utils.char_arr;
  l_order_type msc_gantt_utils.char_arr;
  l_order_type_text msc_gantt_utils.char_arr;
  l_order_number msc_gantt_utils.char_arr;
  l_qty msc_gantt_utils.number_arr;
  l_cepst msc_gantt_utils.date_arr;
  l_cepct msc_gantt_utils.date_arr;
  l_ulpst msc_gantt_utils.date_arr;
  l_ulpct msc_gantt_utils.date_arr;
  l_uepst msc_gantt_utils.date_arr;
  l_uepct msc_gantt_utils.date_arr;
  l_min_start_time msc_gantt_utils.date_arr;
  l_eacd  msc_gantt_utils.date_arr;
  l_req_start_date msc_gantt_utils.date_arr;
  l_req_end_date msc_gantt_utils.date_arr;
  l_req_due_date msc_gantt_utils.date_arr;
  l_item_type msc_gantt_utils.char_arr;
  l_res_req_type msc_gantt_utils.char_arr;
  l_supply_firm_type msc_gantt_utils.number_arr;
  l_res_firm_type msc_gantt_utils.number_arr;
  l_status msc_gantt_utils.number_arr;
  l_applied msc_gantt_utils.number_arr;
  l_supplier_id msc_gantt_utils.number_arr;
  l_supplier_site_id msc_gantt_utils.number_arr;
  l_item_desc msc_gantt_utils.char_arr;
  l_assy_item_desc msc_gantt_utils.char_arr;
  l_category_name msc_gantt_utils.char_arr;
  l_prod_family msc_gantt_utils.char_arr;
  l_planner_code msc_gantt_utils.char_arr;
  l_planning_group msc_gantt_utils.char_arr;
  l_project msc_gantt_utils.char_arr;
  l_task msc_gantt_utils.char_arr;
  l_sugg_ship_date msc_gantt_utils.date_arr;
  l_sugg_due_date msc_gantt_utils.date_arr;
  l_sugg_order_date msc_gantt_utils.date_arr;
  l_sugg_start_date msc_gantt_utils.date_arr;
  l_sugg_dock_date msc_gantt_utils.date_arr;
  l_ship_method msc_gantt_utils.char_arr;
  l_transaction_id msc_gantt_utils.number_arr;
  l_res_transaction_id msc_gantt_utils.number_arr;
  l_customer msc_gantt_utils.char_arr;
  l_customer_site msc_gantt_utils.char_arr;
  l_source_org msc_gantt_utils.char_arr;
  l_supplier msc_gantt_utils.char_arr;
  l_supplier_site msc_gantt_utils.char_arr;
  l_sched_group msc_gantt_utils.char_arr;
  l_actual_start_date msc_gantt_utils.date_arr;

  l_sr_instance_id msc_gantt_utils.number_arr;
  l_organization_id msc_gantt_utils.number_arr;
  l_inventory_item_id msc_gantt_utils.number_arr;
  l_dept_id msc_gantt_utils.number_arr;
  l_res_id msc_gantt_utils.number_arr;

  l_dept_code msc_gantt_utils.char_arr;
  l_res_code msc_gantt_utils.char_arr;
  l_res_desc msc_gantt_utils.char_arr;
  l_op_seq msc_gantt_utils.char_arr;
  l_op_desc msc_gantt_utils.char_arr;
  l_adjusted_res_hours msc_gantt_utils.number_arr;
  l_schedule_qty msc_gantt_utils.number_arr;
  l_batch_number msc_gantt_utils.char_arr;
  l_assigned_units msc_gantt_utils.number_arr;
  l_alternate_flag msc_gantt_utils.char_arr;
  l_res_seq msc_gantt_utils.char_arr;
  l_wip_status_text msc_gantt_utils.char_arr;
  l_setup_type_text msc_gantt_utils.char_arr;
  l_alternate_num msc_gantt_utils.char_arr;

  l_demand_class msc_gantt_utils.char_arr;
  l_material_avail_date msc_gantt_utils.date_arr;
  l_bar_text msc_gantt_utils.char_arr;

  l_one_record varchar2(4000);
  l_out_data_index number := 1;

  l_mfq_query_id number;

  TYPE GanttCurTyp IS REF CURSOR;
  the_cursor GanttCurTyp;
  sql_stmt varchar2(32000);
  sort_columns varchar2(1000);
  node_level_stmt varchar2(200);

  l_parent_link_rec varchar2(2000);

begin
  put_line('getResult in ');
  sort_columns := ' ORDERS ITEM ITEM_CATEGORY ITEM_DESC PRODUCT_FAMILY PLANNER PLN_GROUP PROJECT TASK ';
  sort_columns := sort_columns ||' SUGG_ORDER_DATE SUGG_START_DATE SUGG_SHIP_DATE SUGG_DOCK_DATE SUGG_DUE_DATE ';
  sort_columns := sort_columns ||' ORGANIZATION DEPARTMENT RESOURCE LINE SR_ORG SUPPLIER SUPPLIER_SITE SHIP_METHOD ';
  sort_columns := sort_columns ||' ORDER_TYPE ORDER_NUMBER SCHEDULE_GROUP CUSTOMER CUSTOMER_SITE ';
  sort_columns := sort_columns ||' REQ_START_DATE REQ_COMPL_DATE QUANTITY ADJ_RESOURCE_HR ASSIGNED_UNITS ';
  sort_columns := sort_columns ||' BATCH ALTERNATE WIP_STATUS OPER_DESC OWN_DEPT RES_TYPE EQUIP_NUMBER BUYER ';

  if ( p_sort_column is not null and ( instr(sort_columns, upper(p_sort_column)) <= 0) ) then
    put_line(' error in sort option');
    return SYS_NO;
  end if;

  if ( p_node_level is not null ) then
    node_level_stmt := node_level_stmt ||' and mgq.node_level between '
	||' (-1 * abs('||p_node_level||')) and abs('||p_node_level||') ';
  else
    node_level_stmt := null_space;
  end if;


  --Demand Node Info
  sql_stmt := ' select mgq.row_index,
    msc_get_name.demand_order_number ( md.plan_id, md.sr_instance_id, md.demand_id )
      ||'' for ''||msi.item_name ||'' in '' || mtp.organization_code  ORDERS,
    mgq.node_type,
    mgq.node_path,
    mgq.parent_link,
    nvl(mgq.critical_flag,0) critical_flag,
    msi.item_name ITEM,
    mtp.organization_code ORGANIZATION,
    md.origination_type order_type_id,
    msc_get_name.lookup_meaning(''MRP_DEMAND_ORIGINATION'', md.origination_type) ORDER_TYPE,
    msc_get_name.demand_order_number ( md.plan_id, md.sr_instance_id, md.demand_id )
      ORDER_NUMBER,
   decode(md.customer_id, null,
     msc_get_name.get_other_customers(md.plan_id, md.schedule_designator_id),
     msc_get_name.customer(md.customer_id)) CUSTOMER,
   decode(md.customer_site_id, null,
     msc_get_name.get_other_customers(md.plan_id,md.schedule_designator_id),
     msc_get_name.customer_site(md.customer_site_id)) CUSTOMER_SITE,
   md.using_assembly_demand_date start_date,
   nvl(md.dmd_satisfied_date,md.using_assembly_demand_date) end_date,
   demand_priority,
   --md.quantity_by_due_date QUANTITY,
   md.using_requirement_quantity QUANTITY,
   msi.description ITEM_DESC,
   mic.category_name ITEM_CATEGORY,
   msc_get_name.item_name(msi.product_family_id,null,null,null) PRODUCT_FAMILY,
   msi.planner_code PLANNER,
   md.planning_group PLN_GROUP,
   decode(md.project_id, null, null, msc_get_name.project(md.project_id,
     md.organization_id, md.plan_id, md.sr_instance_id)) PROJECT,
   decode(md.task_id, null, null, msc_get_name.task(md.task_id,
     md.project_id,md.organization_id, md.plan_id, md.sr_instance_id)) TASK,
   md.planned_ship_date SUGG_SHIP_DATE,
   md.using_assembly_demand_date SUGG_DUE_DATE,
   md.ship_method SHIP_METHOD,
   md.demand_id transaction_id,
   md.sr_instance_id,
   md.organization_id,
   md.inventory_item_id,
   md.demand_class,
   md.dmd_satisfied_date material_avail_date
  from  msc_demands md,
    msc_system_items msi,
    msc_item_categories mic,
    msc_trading_partners mtp,
    msc_gantt_query mgq
  where mgq.query_id = :p_query_id
    and mgq.node_type = :END_DEMAND_NODE
    and mgq.row_index between :p_from_index and :p_to_index
    and md.plan_id = :p_plan_id
    and md.sr_instance_id = mgq.sr_instance_id
    and md.demand_id = mgq.transaction_id
    and md.plan_id = msi.plan_id
    and md.sr_instance_id = msi.sr_instance_id
    and md.organization_id = msi.organization_id
    and md.inventory_item_id = msi.inventory_item_id
    and msi.sr_instance_id = mic.sr_instance_id
    and msi.organization_id = mic.organization_id
    and msi.inventory_item_id = mic.inventory_item_id
    and mic.category_set_id = :g_category_set_id
    and mtp.partner_type = 3
    and mtp.sr_tp_id = md.organization_id
    and mtp.sr_instance_id = md.sr_instance_id ';

  sql_stmt := sql_stmt || node_level_stmt;
  --node level logic

put_line(' g_category_set_id '||g_category_set_id);

  if ( p_sort_column is not null and nvl(p_sort_node, END_DEMAND_NODE) = END_DEMAND_NODE )  then
    sql_stmt := sql_stmt ||' order by '||p_sort_column||' '||p_sort_order;
  end if;

  open the_cursor for sql_stmt
    using p_query_id, END_DEMAND_NODE, p_from_index, p_to_index, p_plan_id, g_category_set_id;
  fetch the_cursor bulk collect into l_row_index, l_item_prompt, l_node_type, l_node_path, l_parent_link,
    l_critical_flag, l_item_name, l_org_code, l_order_type, l_order_type_text,
    l_order_number, l_customer, l_customer_site, l_start_date, l_end_date, l_priority,
    l_qty, l_item_desc, l_category_name, l_prod_family, l_planner_code, l_planning_group,
    l_project, l_task, l_sugg_ship_date, l_sugg_due_date, l_ship_method, l_transaction_id,
    l_sr_instance_id, l_organization_id, l_inventory_item_id,
    l_demand_class, l_material_avail_date;
  close the_cursor;

  put_line(' demands count '||l_row_index.count);
  for i in 1..l_row_index.count
  loop -- {
      l_one_record := l_row_index(i)
        || FIELD_SEPERATOR || escapeSplChars(l_item_prompt(i))
        || FIELD_SEPERATOR || l_node_type(i)
	|| FIELD_SEPERATOR || l_node_path(i)
        || FIELD_SEPERATOR || nvl(l_parent_link(i), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_critical_flag(i)), 0)
	|| FIELD_SEPERATOR || escapeSplChars(l_item_name(i))
	|| FIELD_SEPERATOR || escapeSplChars(l_org_code(i))
	|| FIELD_SEPERATOR || l_order_type(i)
	|| FIELD_SEPERATOR || escapeSplChars(l_order_type_text(i))
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_order_number(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_customer(i)), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_customer_site(i)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_start_date(i),format_mask), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_end_date(i),format_mask), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_priority(i)),null_space)
	|| FIELD_SEPERATOR || to_char(round(nvl(fnd_number.number_to_canonical(l_qty(i)),0), round_factor))
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_item_desc(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_category_name(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_prod_family(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_planner_code(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_planning_group(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_project(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_task(i)),null_space)
        || FIELD_SEPERATOR || nvl(to_char(l_sugg_ship_date(i),format_mask), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_sugg_due_date(i),format_mask), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_ship_method(i)), null_space)
	|| FIELD_SEPERATOR || l_transaction_id(i)
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || l_sr_instance_id(i)
	|| FIELD_SEPERATOR || l_organization_id(i)
	|| FIELD_SEPERATOR || l_inventory_item_id(i)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_demand_class(i)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_material_avail_date(i),format_mask), null_space);

    addToOutStream(l_one_record, l_out_data_index, p_out_data);

    put_line(l_row_index(i) || FIELD_SEPERATOR || l_item_prompt(i));
  end loop; -- }

  --Supply/Co-prod Node Info
  sql_stmt := ' select mgq.row_index,
    decode(ms.order_type, 18, msc_get_name.lookup_meaning(''MRP_ORDER_TYPE'', 18),
    msc_get_name.supply_order_number(ms.order_type, ms.order_number, ms.plan_id,
      ms.sr_instance_id, ms.transaction_id, ms.disposition_id)) ||'' for ''||
      msi.item_name ||'' in '' || mtp.organization_code ||''(''|| round(ms.new_order_quantity,:round_factor)||'')'' ORDERS,
    mgq.node_type,
    mgq.node_path,
    mgq.parent_link,
    mgq.critical_flag,
    msi.item_name ITEM,
    mtp.organization_code ORGANIZATION,
    to_char(least(to_date(msc_gantt_utils.getActualStartDate(ms.order_type, msi.planning_make_buy_code,
       ms.organization_id, ms.source_organization_id, ms.new_dock_date,
       ms.new_wip_start_date, ms.new_ship_date,ms.new_schedule_date, ms.source_supplier_id), :format_mask),
      nvl(ms.firm_date, ms.new_schedule_date)),:format_mask) start_date,
    nvl(ms.firm_date, ms.new_schedule_date) end_date,
    ms.order_type order_type_id,
    mfg.meaning ORDER_TYPE,
    msc_get_name.supply_order_number(ms.order_type, ms.order_number, ms.plan_id,
      ms.sr_instance_id, ms.transaction_id, ms.disposition_id) order_number,
    ms.new_order_quantity QUANTITY,
    ms.earliest_start_date,
    ms.earliest_completion_date,
    ms.ulpsd,
    ms.ulpcd,
    ms.uepsd,
    ms.uepcd,
    ms.min_start_date,
    ms.requested_start_date REQ_START_DATE,
    ms.requested_completion_date REQ_COMPL_DATE,
    msi.planning_make_buy_code item_type,
    nvl(ms.firm_planned_type,2) supply_firm_type,
    nvl(ms.status, 0) status,
    nvl(ms.applied, 0) applied,
    nvl(ms.supplier_id, 0) supplier_id,
    nvl(ms.supplier_site_id, 0) supplier_site_id,
    msi.description ITEM_DESC,
    mic.category_name ITEM_CATEGORY,
    msc_get_name.item_name(msi.product_family_id,null,null,null) PRODUCT_FAMILY,
    msi.planner_code PLANNER,
    ms.planning_group PLN_GROUP,
    decode(ms.project_id, null, null, msc_get_name.project(ms.project_id,
      ms.organization_id, ms.plan_id, ms.sr_instance_id)) PROJECT,
    decode(ms.task_id, null, null, msc_get_name.task(ms.task_id,
      ms.project_id, ms.organization_id, ms.plan_id, ms.sr_instance_id)) TASK,
    ms.new_order_placement_date SUGG_ORDER_DATE,
    ms.new_wip_start_date SUGG_START_DATE,
    ms.new_ship_date SUGG_SHIP_DATE,
    ms.new_dock_date SUGG_DOCK_DATE,
    ms.new_schedule_date SUGG_DUE_DATE,
    msc_get_name.org_code(ms.source_organization_id, ms.source_sr_instance_id) SR_ORG,
    msc_get_name.supplier(ms.supplier_id) SUPPLIER,
    msc_get_name.supplier_site(ms.supplier_site_id) SUPPLIER_SITE,
    ms.ship_method SHIP_METHOD,
    ms.schedule_group_name SCHEDULE_GROUP,
    ms.transaction_id transaction_id,
    ms.sr_instance_id,
    ms.organization_id,
    ms.inventory_item_id,
    ms.schedule_priority,
    msi.description,
    msc_get_name.lookup_meaning(''WIP_JOB_STATUS'', ms.wip_status_code) wip_status_text,
    ms.new_schedule_date,
    ms.actual_start_date
  from  msc_supplies ms,
    msc_system_items msi,
    msc_item_categories mic,
    msc_trading_partners mtp,
    mfg_lookups mfg,
    msc_gantt_query mgq
  where mgq.query_id = :p_query_id
    and mgq.node_type in (:JOB_NODE, :COPROD_NODE)
    and mgq.row_index between :p_from_index and :p_to_index
    and ms.plan_id = :p_plan_id
    and ms.sr_instance_id = mgq.sr_instance_id
    and ms.transaction_id = mgq.transaction_id
    and ms.plan_id = msi.plan_id
    and ms.organization_id = msi.organization_id
    and ms.sr_instance_id = msi.sr_instance_id
    and ms.inventory_item_id = msi.inventory_item_id
    and msi.sr_instance_id = mic.sr_instance_id
    and msi.organization_id = mic.organization_id
    and msi.inventory_item_id = mic.inventory_item_id
    and mic.category_set_id = :g_category_set_id
    and mfg.lookup_type = ''MRP_ORDER_TYPE''
    and mfg.lookup_code = ms.order_type
    and mtp.partner_type = 3
    and mtp.sr_tp_id = ms.organization_id
    and mtp.sr_instance_id = ms.sr_instance_id ';

  sql_stmt := sql_stmt || node_level_stmt;
  --node level logic

  if ( p_sort_column is not null and nvl(p_sort_node, JOB_NODE) in (JOB_NODE, COPROD_NODE) )  then
    sql_stmt := sql_stmt ||' order by '||p_sort_column||' '||p_sort_order;
  else
    sql_stmt := sql_stmt ||' order by mgq.row_index ';
  end if;

  open the_cursor for sql_stmt
    using round_factor, format_mask, format_mask, p_query_id, JOB_NODE ,COPROD_NODE, p_from_index, p_to_index, p_plan_id, g_category_set_id;
  fetch the_cursor bulk collect into l_row_index, l_item_prompt, l_node_type, l_node_path, l_parent_link,
    l_critical_flag, l_item_name, l_org_code, l_start_date_char, l_end_date,
    l_order_type, l_order_type_text, l_order_number, l_qty,
    l_cepst, l_cepct, l_ulpst, l_ulpct, l_uepst, l_uepct, l_min_start_time,
    l_req_start_date, l_req_end_date, l_item_type,
    l_supply_firm_type, l_status, l_applied, l_supplier_id, l_supplier_site_id,
    l_item_desc, l_category_name, l_prod_family, l_planner_code, l_planning_group, l_project,
    l_task, l_sugg_order_date, l_sugg_start_date, l_sugg_ship_date, l_sugg_dock_date,
    l_sugg_due_date, l_source_org, l_supplier, l_supplier_site, l_ship_method,
    l_sched_group, l_transaction_id, l_sr_instance_id, l_organization_id, l_inventory_item_id,
    l_priority, l_item_desc, l_wip_status_text, l_req_end_date, l_actual_start_date;
  close the_cursor;

  put_line(' supplies count '||l_row_index.count);
  for i in 1..l_row_index.count
  loop -- {
    l_parent_link_rec := null;
    -- find allocated quantity
    if (l_parent_link(i) is not null) then
      l_parent_link_rec := getParentLinkRec(p_query_id, p_plan_id, l_transaction_id(i), l_parent_link(i));
      put_line(' parent link for '||l_transaction_id(i)|| '  ' || l_parent_link_rec);
    end if;

      l_one_record := l_row_index(i)
        || FIELD_SEPERATOR || escapeSplChars(l_item_prompt(i))
        || FIELD_SEPERATOR || l_node_type(i)
	|| FIELD_SEPERATOR || l_node_path(i)
        || FIELD_SEPERATOR || nvl(to_char(l_parent_link_rec), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_critical_flag(i)), 0)
	|| FIELD_SEPERATOR || escapeSplChars(l_item_name(i))
	|| FIELD_SEPERATOR || nvl(l_start_date_char(i), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_end_date(i),format_mask),null_space)
	|| FIELD_SEPERATOR || escapeSplChars(l_org_code(i))
	|| FIELD_SEPERATOR || l_order_type(i)
	|| FIELD_SEPERATOR || escapeSplChars(l_order_type_text(i))
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_order_number(i)), null_space)
	|| FIELD_SEPERATOR || to_char(round(nvl(fnd_number.number_to_canonical(l_qty(i)),0), round_factor))
	|| FIELD_SEPERATOR || nvl(to_char(l_cepst(i),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_cepct(i),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_ulpst(i),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_ulpct(i),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_uepst(i),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_uepct(i),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_min_start_time(i),format_mask),null_space)
	|| FIELD_SEPERATOR || escapeSplChars(l_item_type(i))
	|| FIELD_SEPERATOR || l_supply_firm_type(i)
	|| FIELD_SEPERATOR || l_status(i)
	|| FIELD_SEPERATOR || l_applied(i)
	|| FIELD_SEPERATOR || l_supplier_id(i)
	|| FIELD_SEPERATOR || l_supplier_site_id(i)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_item_desc(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_category_name(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_prod_family(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_planner_code(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_planning_group(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_project(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_task(i)),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_sugg_order_date(i),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_sugg_start_date(i),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_sugg_ship_date(i),format_mask),null_space)
        || FIELD_SEPERATOR || nvl(to_char(l_sugg_dock_date(i),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_sugg_due_date(i),format_mask),null_space)
        || FIELD_SEPERATOR || nvl(escapeSplChars(l_source_org(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_supplier(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_supplier_site(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_ship_method(i)),null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_sched_group(i)),null_space)
	|| FIELD_SEPERATOR || l_transaction_id(i)
        || FIELD_SEPERATOR || nvl(to_char(l_req_start_date(i),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_req_end_date(i),format_mask),null_space)
	|| FIELD_SEPERATOR || escapeSplChars(msc_gantt_utils.getJobNodeLabel(l_item_name(i), l_org_code(i),
	  l_order_number(i), l_order_type_text(i), l_qty(i)))
	|| FIELD_SEPERATOR || l_sr_instance_id(i)
	|| FIELD_SEPERATOR || l_organization_id(i)
	|| FIELD_SEPERATOR || l_inventory_item_id(i)
	|| FIELD_SEPERATOR || nvl(to_char(l_priority(i)), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_item_desc(i)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_req_end_date(i),format_mask),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_wip_status_text(i)),null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_actual_start_date(i),format_mask),null_space);

    addToOutStream(l_one_record, l_out_data_index, p_out_data);

    put_line(l_row_index(i) || FIELD_SEPERATOR || l_item_prompt(i));
  end loop; -- }

  --Op Node Info
  sql_stmt := ' select mgq.row_index,
    mgq.op_seq_num,
    mgq.node_type,
    mgq.node_path,
    decode(mgq.dependency_type,
      null, null,
      mgq.dependency_type||:FIELD_SEPERATOR || mgq.parent_link),
    mgq.op_desc,
    mgq.transaction_id
  from msc_gantt_query mgq
  where mgq.query_id = :p_query_id
    and mgq.node_type = :OP_NODE
    and substr(mgq.node_path ,1, instr(mgq.node_path, :COLON_SEPARATOR)-1)
      between :p_from_index and :p_to_index  '|| node_level_stmt || '
    order by to_number(substr(mgq.node_path ,1, instr(mgq.node_path, :COLON_SEPARATOR)-1)),
      to_number(substr(mgq.node_path , instr(mgq.node_path, :COLON_SEPARATOR)+1))';

  open the_cursor for sql_stmt
    using FIELD_SEPERATOR, p_query_id, OP_NODE, COLON_SEPARATOR, p_from_index, p_to_index, COLON_SEPARATOR, COLON_SEPARATOR;
  fetch the_cursor bulk collect into l_row_index, l_item_prompt, l_node_type,
    l_node_path, l_parent_link, l_op_desc, l_transaction_id;
  close the_cursor;

  put_line(' op count '||l_row_index.count);
  for i in 1..l_row_index.count
  loop -- {
      l_one_record := l_row_index(i)
        || FIELD_SEPERATOR || escapeSplChars(l_item_prompt(i))
        || FIELD_SEPERATOR || l_node_type(i)
	|| FIELD_SEPERATOR || l_node_path(i)
        || FIELD_SEPERATOR || nvl(l_parent_link(i), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_op_desc(i)), null_space)
	|| FIELD_SEPERATOR || escapeSplChars(msc_gantt_utils.getOpNodeLabel(l_item_prompt(i), l_transaction_id(i),
	  l_op_desc(i), p_plan_id));

    addToOutStream(l_one_record, l_out_data_index, p_out_data);

    put_line(l_row_index(i) || FIELD_SEPERATOR || l_item_prompt(i));
  end loop; -- }

  --Resource Node Info
  sql_stmt := ' select mgq.row_index,
      to_char(mrr.operation_seq_num)||''/''||to_char(mrr.resource_seq_num)||
        ''(''||msc_get_name.department_resource_code(mrr.resource_id,
        mrr.department_id, mrr.organization_id, mrr.plan_id, mrr.sr_instance_id)||'')'',
      mgq.node_type,
      mgq.node_path,
      mgq.parent_link,
      mdr.department_code,
      mdr.resource_code,
      msc_gantt_utils.getResReqStartDate(nvl(mrr.firm_flag,0),
        mrr.start_date, mrr.end_date,mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) start_date,
      msc_gantt_utils.getResReqEndDate(nvl(mrr.firm_flag,0), mrr.start_date, mrr.end_date,
        mrr.firm_start_date, mrr.firm_end_date, mrr.status, mrr.applied) end_date,
      ms.new_order_quantity QUANTITY,
      mrr.resource_hours adjusted_res_hours,
      mrr.batch_number,
      mrr.assigned_units,
      msc_get_name.alternate_rtg(mrr.plan_id, mrr.sr_instance_id, mrr.routing_sequence_id),
      msc_get_name.lookup_meaning(''WIP_JOB_STATUS'', ms.wip_status_code) wip_status_text,
      nvl(ms.firm_planned_type,2) supply_firm_type,
      nvl(mrr.firm_flag,0) res_firm_type,
      nvl(mrr.status, 0) status,
      nvl(mrr.applied, 0) applied,
      msc_gantt_utils.getResReqType(mrr.plan_id, mrr.schedule_flag, mrr.parent_seq_num, mrr.setup_id) res_req_type,
      mrr.supply_id transaction_id,
      mrr.transaction_id res_transaction_id,
      mrr.resource_seq_num,
      decode(mrr.setup_id, to_number(null), null,
      msc_gantt_utils.getSetupCode(mrr.plan_id, mrr.sr_instance_id, mrr.resource_id, mrr.setup_id)),
      mrr.earliest_start_date,
      mrr.earliest_completion_date,
      mrr.ulpsd,
      mrr.ulpcd,
      mrr.uepsd,
      mrr.uepcd,
      mrr.eacd,
      mrr.sr_instance_id,
      mrr.organization_id,
      mrr.department_id,
      mrr.resource_id,
      ms.inventory_item_id,
      msc_get_name.supply_order_number(ms.order_type, ms.order_number, ms.plan_id,
        ms.sr_instance_id, ms.transaction_id, ms.disposition_id) order_number,
      mrr.operation_seq_num,
      mdr.resource_description,
      mi.item_name item,
      mi2.description assembly_item_desc,
      decode(mrr.resource_hours, 0, to_number(null),
        nvl(mrr.cummulative_quantity,ms.new_order_quantity)) schedule_qty,
      msc_gantt_utils.getOrderViewResNodeLabel(mrr.plan_id, mrr.sr_instance_id,
        mrr.transaction_id) bar_text,
      mrr.alternate_num,
      mrr.actual_start_date,
      mgq.critical_flag
    from msc_resource_requirements mrr,
      msc_department_resources mdr,
      msc_supplies ms,
      msc_items mi,
      msc_items mi2,
      msc_trading_partners mtp,
      msc_gantt_query mgq
    where mgq.query_id = :p_query_id
      and mgq.node_type = :RES_NODE
      and ( ( nvl(:p_res_nodes_only,2) = 2
	    and substr(mgq.node_path ,1, instr(mgq.node_path, :COLON_SEPARATOR)-1)
        		between :p_from_index and :p_to_index)
           or ( nvl(:p_res_nodes_only,2) = 1
	    and mgq.row_index between :p_from_index and :p_to_index)
          )
      and mrr.plan_id = :p_plan_id
      and mrr.sr_instance_id = mgq.sr_instance_id
      and mrr.organization_id = mgq.organization_id
      and mrr.transaction_id = mgq.transaction_id
      and mrr.parent_id = 2
      and mrr.end_date is not null
      and mrr.department_id <> -1
      and mrr.plan_id = mdr.plan_id
      and mrr.organization_id = mdr.organization_id
      and mrr.sr_instance_id = mdr.sr_instance_id
      and mrr.department_id = mdr.department_id
      and mrr.resource_id = mdr.resource_id
      and mrr.plan_id = ms.plan_id
      and mrr.supply_id = ms.transaction_id
      and mrr.sr_instance_id = ms.sr_instance_id
      and mtp.partner_type = 3
      and mtp.sr_tp_id = ms.organization_id
      and mtp.sr_instance_id = ms.sr_instance_id
      and ms.inventory_item_id = mi.inventory_item_id
      and mrr.assembly_item_id = mi2.inventory_item_id '|| node_level_stmt || '
    order by to_number(substr(mgq.node_path ,1, instr(mgq.node_path, :COLON_SEPARATOR)-1)),
      to_number(substr(mgq.node_path, instr(mgq.node_path, :COLON_SEPARATOR,1,1)+1,
        instr(mgq.node_path, :COLON_SEPARATOR,1,2)-instr(mgq.node_path, :COLON_SEPARATOR,1,1)-1)),
      to_number(substr(mgq.node_path , instr(mgq.node_path,:COLON_SEPARATOR,1,2)+1)) ';

  open the_cursor for sql_stmt
    using p_query_id, RES_NODE, p_res_nodes_only, COLON_SEPARATOR, p_from_index, p_to_index,
    p_res_nodes_only, p_from_index, p_to_index,
    p_plan_id,
    COLON_SEPARATOR, COLON_SEPARATOR, COLON_SEPARATOR, COLON_SEPARATOR, COLON_SEPARATOR;

  fetch the_cursor bulk collect into l_row_index, l_item_prompt, l_node_type,
    l_node_path, l_parent_link, l_dept_code, l_res_code, l_start_date, l_end_date,
    l_qty, l_adjusted_res_hours, l_batch_number, l_assigned_units, l_alternate_flag,
    l_wip_status_text, l_supply_firm_type, l_res_firm_type, l_status, l_applied,
    l_res_req_type, l_transaction_id, l_res_transaction_id, l_res_seq, l_setup_type_text,
    l_cepst, l_cepct, l_ulpst, l_ulpct, l_uepst, l_uepct, l_eacd, l_sr_instance_id,
    l_organization_id, l_dept_id, l_res_id, l_inventory_item_id, l_order_number,
    l_op_seq, l_res_desc, l_item_name, l_assy_item_desc, l_schedule_qty, l_bar_text,
    l_alternate_num, l_actual_start_date, l_critical_flag;
  close the_cursor;

  put_line(' res count '||l_row_index.count);
  for i in 1..l_row_index.count
  loop -- {
      if( nvl(p_res_nodes_only,sys_no) = sys_yes) then
      l_one_record := l_row_index(i)
	|| FIELD_SEPERATOR || nvl(to_char(l_start_date(i), format_mask), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_end_date(i), format_mask), null_space);
      else
      l_one_record := l_row_index(i)
        || FIELD_SEPERATOR || escapeSplChars(l_item_prompt(i))
        || FIELD_SEPERATOR || l_node_type(i)
	|| FIELD_SEPERATOR || l_node_path(i)
        || FIELD_SEPERATOR || nvl(to_char(l_parent_link(i)), null_space)
        || FIELD_SEPERATOR || nvl(escapeSplChars(l_dept_code(i)) , null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_res_code(i)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_start_date(i), format_mask), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_end_date(i), format_mask), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(round(nvl(fnd_number.number_to_canonical(l_qty(i)),0),round_factor)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(fnd_number.number_to_canonical(l_adjusted_res_hours(i))), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_batch_number(i)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(fnd_number.number_to_canonical(l_assigned_units(i))), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(to_char(l_alternate_flag(i))), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_wip_status_text(i)), null_space)
	|| FIELD_SEPERATOR || l_supply_firm_type(i)
	|| FIELD_SEPERATOR || l_res_firm_type(i)
	|| FIELD_SEPERATOR || l_status(i)
	|| FIELD_SEPERATOR || l_applied(i)
	|| FIELD_SEPERATOR || l_res_req_type(i)
	|| FIELD_SEPERATOR || l_transaction_id(i)
	|| FIELD_SEPERATOR || l_res_transaction_id(i)
	|| FIELD_SEPERATOR || escapeSplChars(l_bar_text(i))
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || nvl(to_char(l_cepst(i), format_mask), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_cepct(i), format_mask), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_ulpst(i), format_mask), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_ulpct(i), format_mask), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_uepst(i), format_mask), null_space)
        || FIELD_SEPERATOR || nvl(to_char(l_uepct(i), format_mask), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_eacd(i), format_mask), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_sr_instance_id(i)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_organization_id(i)), null_space)
        || FIELD_SEPERATOR || nvl(to_char(l_dept_id(i)), null_space)
        || FIELD_SEPERATOR || nvl(to_char(l_res_id(i)), null_space)
        || FIELD_SEPERATOR || nvl(to_char(l_inventory_item_id(i)), null_space)
        || FIELD_SEPERATOR || nvl(to_char(l_res_seq(i)), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_order_number(i)), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(to_char(l_op_seq(i))), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_res_desc(i)), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_item_name(i)), null_space)
	|| FIELD_SEPERATOR || nvl(escapeSplChars(l_assy_item_desc(i)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(fnd_number.number_to_canonical(l_schedule_qty(i))), null_space)
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || null_space
	|| FIELD_SEPERATOR || nvl(to_char(l_alternate_num(i)), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_actual_start_date(i), format_mask), null_space)
	|| FIELD_SEPERATOR || nvl(to_char(l_critical_flag(i)), null_space);
     end if;

    addToOutStream(l_one_record, l_out_data_index, p_out_data);

    put_line(l_row_index(i) || FIELD_SEPERATOR || l_item_prompt(i));
  end loop; -- }
  put_line('getResult out ');

 return SYS_YES;
End getResult;


END MSC_GANTT_UTILS;

/
