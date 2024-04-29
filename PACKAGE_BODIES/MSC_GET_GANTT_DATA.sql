--------------------------------------------------------
--  DDL for Package Body MSC_GET_GANTT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_GET_GANTT_DATA" AS
/* $Header: MSCGNTDB.pls 120.1 2005/06/17 15:35:48 appldev  $  */

   field_seperator varchar2(5) := '|';
   record_seperator varchar2(5) := '&';
   resource_seperator varchar2(5) := '~';
   format_mask varchar2(20) :='MM/DD/YYYY HH24:MI';
   g_plan_id number;
   g_last_date date;
   g_first_date date;
   g_cutoff_date date;
   g_current_block number;
   g_supply_rec_count number :=0;
   g_supply_parentIndex number;
   g_supply_childIndex number :=0;
   g_supply_limit number := 10;
   g_resource_limit number := 15;
   g_has_more_supply boolean;
   g_has_prev_supply boolean;
   g_supply_query_id number;
   g_res_query_id number;
   g_supplier_query_id number;
   g_find_query_id number;
   g_end_demand_id number;
   g_dmd_priority number;
   TYPE number_arr IS TABLE OF number;
   g_block_start_item number_arr := number_arr(0);
   g_block_start_row number_arr := number_arr(0);
   g_buy_text varchar2(2000) := fnd_message.get_string('MSC','BUY_TEXT');
   g_make_text varchar2(2000) := fnd_message.get_string('MSC','MAKE_TEXT');
   g_transfer_text varchar2(2000) := fnd_message.get_string('MSC','TRANSFER_TEXT');
   NO_FIRM        CONSTANT INTEGER :=0;
   FIRM_START     CONSTANT INTEGER :=1;
   FIRM_END       CONSTANT INTEGER :=2;
   FIRM_RESOURCE  CONSTANT INTEGER :=3;
   FIRM_START_END CONSTANT INTEGER :=4;
   FIRM_START_RES CONSTANT INTEGER :=5;
   FIRM_END_RES   CONSTANT INTEGER :=6;
   FIRM_ALL       CONSTANT INTEGER :=7;

   ON_HAND CONSTANT INTEGER :=1;
   BUY_SUPPLY CONSTANT INTEGER :=2;
   MAKE_SUPPLY CONSTANT INTEGER :=3;
   TRANSFER_SUPPLY CONSTANT INTEGER :=4;

   peg_data peg_rec_type;
   the_index number :=0;

FUNCTION get_debug_mode RETURN VARCHAR2 IS
BEGIN
 return FND_PROFILE.Value('MSC_JAVA_DEBUG');
END;

FUNCTION replace_seperator(old_string varchar2) return varchar2 IS
  new_string varchar2(30000);
BEGIN
  new_string := old_string;
  new_string := replace(new_string,record_Seperator,'*');
  new_string := replace(new_string,resource_Seperator,'^');
  new_string := replace(new_string,field_Seperator,':');
  return new_string;
END replace_seperator;

Function fetchDeptResCode(p_plan_id number,
                            v_instance_id number,
                            v_org_id number,
                            v_dept_id number,
                            v_res_id number) RETURN varchar2 IS

  CURSOR name IS
  select mtp.organization_code
         ||':'||mdr.department_code || ':' || mdr.resource_code
  from   msc_department_resources mdr,
         msc_trading_partners mtp
  where mdr.department_id = v_dept_id
  and   mdr.resource_id = v_res_id
  and   mdr.plan_id = p_plan_id
  and   mdr.organization_id = v_org_id
  and   mdr.sr_instance_id = v_instance_id
  and   mtp.partner_type =3
  and   mtp.sr_tp_id = mdr.organization_id
  and   mtp.sr_instance_id = mdr.sr_instance_id;

  v_name varchar2(30);
BEGIN

  OPEN name;
  FETCH name INTO v_name;
  CLOSE name;
  return v_name;

END fetchDeptResCode;

Procedure setFetchRow(p_supply_limit number,
                      p_resource_limit number) IS
BEGIN
   g_supply_limit := p_supply_limit;
   g_resource_limit := p_resource_limit;

END setFetchRow;

Procedure fetchResourceData(p_plan_id number,
                                   p_res_list varchar2,
                                   p_fetch_type varchar2 default null,
                                   v_require_data OUT NOCOPY Child_Rec_Type,
                                   v_name OUT NOCOPY varchar2) IS
  v_org_id number;
  v_instance_id number;
  v_dept_id number;
  v_res_id number;
  v_len number;
  one_record varchar2(100);
  i number:=1;
  j number := 1;
  a number:=0;
  nameCount number:=0;
  recordCount number:=0;
  l_inventory_item_id number := -1;
  l_resource_constraint VARCHAR2(20);

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
  CURSOR resource_constraint_cur ( p_instance_id IN number
                                 , p_plan_id IN number
                                 , p_organization_id IN number
                                 , p_inventory_item_id IN number
                                 , p_department_id IN number
                                 , p_resource_id IN number
                                 , p_transaction_id IN number
                                 ) IS
  SELECT 'EXISTS'
  FROM   msc_exception_details
  WHERE  number1 = p_transaction_id
  AND    sr_instance_id = p_instance_id
  AND    plan_id = p_plan_id
  and    exception_type =36
  AND    organization_id = p_organization_id
  AND    inventory_item_id = p_inventory_item_id
  AND    department_id = p_department_id
  AND    resource_id = p_resource_id;

  CURSOR req IS
      select to_char(
               decode(nvl(mrr.firm_flag,0),
                      NO_FIRM, mrr.start_date,
                      FIRM_RESOURCE, mrr.start_date,
                      FIRM_END,
                        mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                      FIRM_END_RES,
                        mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                      nvl(mrr.firm_start_date, mrr.start_date)),
               format_mask) start_date,
             to_char(least(g_cutoff_date,
               nvl(
               decode(nvl(mrr.firm_flag,0),
                      NO_FIRM, mrr.end_date,
                      FIRM_RESOURCE, mrr.end_date,
                      FIRM_START,
                         mrr.firm_start_date + (mrr.end_date - mrr.start_date),
                      FIRM_START_RES,
                         mrr.firm_start_date + (mrr.end_date - mrr.start_date),
                      nvl(mrr.firm_end_date, mrr.end_date)),mrr.start_date)),
               format_mask) end_date,
             msc_get_gantt_data.order_number(ms.order_type,ms.order_number,
                         ms.plan_id, ms.sr_instance_id,
                         ms.transaction_id, ms.disposition_id)
                ||'/'||
                msi.item_name
                ||'('||mrr.operation_seq_num||':'||mrr.resource_seq_num
                ||')' job_name,
             mrr.transaction_id,
             nvl(mrr.status,0) status,
             nvl(mrr.applied,0) applied,
             mfg.meaning supply_type,
             mrr.sr_instance_id,
             nvl(mrr.firm_flag,0) res_firm_flag,
             ms.firm_planned_type sup_firm_flag,
             decode(sign(ms.new_schedule_date - (ms.need_by_date+1)), 1,
                    1,0) late_flag,
             mrr.supply_id
        from msc_resource_requirements mrr,
             msc_supplies ms,
             msc_items msi,
             mfg_lookups mfg
       where mrr.organization_id =v_org_id
         and mrr.sr_instance_id = v_instance_id
         and mrr.department_id = v_dept_id
         and mrr.resource_id = v_res_id
         and mrr.plan_id = p_plan_id
         and mrr.end_date is not null
         and ms.inventory_item_id = msi.inventory_item_id
         and mfg.lookup_type = 'MRP_ORDER_TYPE'
         and mfg.lookup_code = ms.order_type
         and nvl(mrr.parent_id,2) =2
         and nvl(mrr.firm_start_date,mrr.start_date) <= g_cutoff_date
         and ms.plan_id = mrr.plan_id
         and ms.transaction_id = mrr.supply_id
         and ms.sr_instance_id = mrr.sr_instance_id
       order by mrr.batch_number, nvl(mrr.firm_start_date, mrr.start_date);

  CURSOR req_find IS
      select to_char(
               decode(nvl(mrr.firm_flag,0),
                      NO_FIRM, mrr.start_date,
                      FIRM_RESOURCE, mrr.start_date,
                      FIRM_END,
                        mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                      FIRM_END_RES,
                        mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                      nvl(mrr.firm_start_date, mrr.start_date)),
               format_mask) start_date,
             to_char(least(g_cutoff_date,
               decode(nvl(mrr.firm_flag,0),
                      NO_FIRM, mrr.end_date,
                      FIRM_RESOURCE, mrr.end_date,
                      FIRM_START,
                         mrr.firm_start_date + (mrr.end_date - mrr.start_date),
                      FIRM_START_RES,
                         mrr.firm_start_date + (mrr.end_date - mrr.start_date),
                      nvl(mrr.firm_end_date, mrr.end_date))),
               format_mask) end_date,
             msc_get_gantt_data.order_number(ms.order_type,ms.order_number,
                         ms.plan_id, ms.sr_instance_id,
                         ms.transaction_id, ms.disposition_id)
                ||'/'||
                 msi.item_name
                ||'('||mrr.operation_seq_num||':'||mrr.resource_seq_num
                ||')' job_name,
             mrr.transaction_id,
             nvl(mrr.status,0) status,
             nvl(mrr.applied,0) applied,
             mfg.meaning supply_type,
             mrr.sr_instance_id,
             nvl(mrr.firm_flag,0) res_firm_flag,
             ms.firm_planned_type sup_firm_flag,
             decode(sign(ms.new_schedule_date - (ms.need_by_date+1)), 1,
                    1,0) late_flag,
             mrr.supply_id
        from msc_resource_requirements mrr,
             msc_supplies ms,
             msc_items msi,
             mfg_lookups mfg,
             msc_form_query mfq
       where mrr.organization_id =v_org_id
         and mrr.sr_instance_id = v_instance_id
         and mrr.department_id = v_dept_id
         and mrr.resource_id = v_res_id
         and mrr.plan_id = p_plan_id
         and mrr.end_date is not null
         and ms.inventory_item_id = msi.inventory_item_id
         and mfg.lookup_type = 'MRP_ORDER_TYPE'
         and mfg.lookup_code = ms.order_type
         and nvl(mrr.parent_id,2) =2
         and nvl(mrr.firm_start_date,mrr.start_date) <= g_cutoff_date
         and ms.plan_id = mrr.plan_id
         and ms.transaction_id = mrr.supply_id
         and ms.sr_instance_id = mrr.sr_instance_id
         and mfq.number6 = mrr.transaction_id
         and mfq.query_id = g_find_query_id
       order by mrr.batch_number, nvl(mrr.firm_start_date, mrr.start_date);

   req_rec req%ROWTYPE;

   one_name varchar2(100);
   rowCount number;
   currentItem number;
   startRow number;
   p_has_previous number :=0;
BEGIN

    -- parse the resource_list
    -- the format of res_list is
    -- (instance_id, org_id, dept_id, res_id),(ins_id, org_id, dept_id, res_id)

 if p_fetch_type is null then -- start from beginning
    g_current_block := 1;
    g_block_start_item.delete;
    g_block_start_row.delete;
    g_block_start_item.extend;
    g_block_start_row.extend;
    g_block_start_item(1) := 1;
    g_block_start_row(1) :=0;
 elsif p_fetch_type = 'PREV' then
    g_current_block := g_current_block -1;
 elsif p_fetch_type = 'NEXT' then
    g_current_block := g_current_block +1;
 elsif p_fetch_type = 'CURRENT' then
    g_current_block := nvl(g_current_block, 1);
 end if;

 v_len := length(p_res_list);
 recordCount := 0;
 currentItem := g_block_start_item(g_current_block);

 while v_len > 0 and j < g_resource_limit+2 LOOP
    one_record :=
      substr(p_res_list,instr(p_res_list,'(',1,i)+1,
                        instr(p_res_list,')',1,i)-instr(p_res_list,'(',1,i)-1);
    v_instance_id := to_number(substr(one_record,1,instr(one_record,',')-1));
    v_org_id := to_number(substr(one_record,instr(one_record,',',1,1)+1,
                       instr(one_record,',',1,2)-instr(one_record,',',1,1)-1));
    v_dept_id := to_number(substr(one_record,instr(one_record,',',1,2)+1
                      ,instr(one_record,',',1,3)-instr(one_record,',',1,2)-1));
    v_res_id := to_number(substr(one_record,instr(one_record,',',1,3)+1));
    recordCount := recordCount +1;

  if recordCount >= currentItem then
    rowCount :=0;
    a :=0;
    if recordCount = currentItem then
       startRow :=g_block_start_row(g_current_block);
    else
       startRow :=0;
    end if;

    if g_find_query_id is null then
      OPEN req;
    else
      OPEN req_find;
    end if;
    LOOP
    if g_find_query_id is null then
      FETCH req INTO req_rec;
      EXIT WHEN req%NOTFOUND or j > g_resource_limit +1 + p_has_previous or
                              a > startRow + g_resource_limit;
    else
      FETCH req_find INTO req_rec;
      EXIT WHEN req_find%NOTFOUND or j > g_resource_limit +1 + p_has_previous or
                              a > startRow + g_resource_limit;
    end if;
      a := a+1;

      if a > startRow then
       if g_current_block <> 1 and j = 1 then -- add prev node
          v_require_data.start_date(j) := req_rec.start_date;
          v_require_data.end_date(j) := req_rec.start_date;
          v_require_data.name(j) := 'Previous '||g_resource_limit;
          v_require_data.transaction_id(j):= -1;
          v_require_data.status(j):= req_rec.status;
          v_require_data.applied(j):= req_rec.applied;
          v_require_data.supply_type(j):= req_rec.supply_type;
          v_require_data.instance_id(j):= req_rec.sr_instance_id;
          v_require_data.res_firm_flag(j):= req_rec.res_firm_flag;
          v_require_data.sup_firm_flag(j):= req_rec.sup_firm_flag;
          v_require_data.late_flag(j):= 0;
          j := j+1;
          rowCount := rowCount+1;
          p_has_previous :=1;

       end if;

       if j = g_resource_limit +p_has_previous +1 then -- add next node
          v_require_data.start_date(j) := req_rec.start_date;
          v_require_data.end_date(j) := req_rec.start_date;
          v_require_data.name(j) := 'Next '||g_resource_limit;
          v_require_data.transaction_id(j):= -2;
          v_require_data.status(j):= req_rec.status;
          v_require_data.applied(j):= req_rec.applied;
          v_require_data.supply_type(j):= req_rec.supply_type;
          v_require_data.instance_id(j):= req_rec.sr_instance_id;
          v_require_data.res_firm_flag(j):= req_rec.res_firm_flag;
          v_require_data.sup_firm_flag(j):= req_rec.sup_firm_flag;
          v_require_data.late_flag(j):= 0;
          j := j+1;
         rowCount := rowCount+1;

       elsif j <= g_resource_limit + p_has_previous then
          v_require_data.start_date(j) := req_rec.start_date;
          v_require_data.end_date(j) := req_rec.end_date;
          v_require_data.name(j) := replace_seperator(req_rec.job_name);
          v_require_data.transaction_id(j):= req_rec.transaction_id;
          v_require_data.status(j):= req_rec.status;
          v_require_data.applied(j):= req_rec.applied;
          v_require_data.supply_type(j):= req_rec.supply_type;
          v_require_data.instance_id(j):= req_rec.sr_instance_id;
          v_require_data.res_firm_flag(j):= req_rec.res_firm_flag;
          v_require_data.sup_firm_flag(j):= req_rec.sup_firm_flag;
          v_require_data.late_flag(j):= req_rec.late_flag;

      if v_require_data.res_firm_flag(j) >= 8 then
         v_require_data.res_firm_flag(j) := 0;
      end if;
      OPEN resource_constraint_cur ( v_instance_id
                                   , p_plan_id
                                   , v_org_id
                                   , l_inventory_item_id
                                   , v_dept_id
                                   , v_res_id
                                   , req_rec.supply_id
                                   );
      FETCH resource_constraint_cur INTO l_resource_constraint;
      -- check for resource constraint exceptions
      IF resource_constraint_cur%FOUND THEN
        -- late_flag is true(1) if exception exists
        v_require_data.late_flag(j) := 1;
      ELSE
        -- and false(0) if it doesn't
        v_require_data.late_flag(j) := 0;
      END IF;
      CLOSE resource_constraint_cur;

      j := j+1;
      rowCount := rowCount+1;
       end if; -- if j = g_resource_limit +1

      end if; --  if a > startRow
    END LOOP;

    if g_find_query_id is null then
      CLOSE req;
    else
      CLOSE req_find;
    end if;

    one_name :=null;
    one_name := fetchDeptResCode(p_plan_id, v_instance_id, v_org_id,
                                 v_dept_id, v_res_id);
    IF one_name is not null THEN
       nameCount := nameCount+1;
       one_name := replace_seperator(one_name) || field_seperator ||
               v_instance_id || field_seperator ||
               v_org_id || field_seperator ||
               v_dept_id || field_seperator ||
               v_res_id ;
    v_require_data.record_count(nameCount) := rowCount;

      IF v_name IS NULL THEN
       v_name := one_name;
      ELSE
          v_name := v_name || resource_seperator || one_name;
      END IF;
    END IF;

  end if; -- end of if recordCount >= g_block_start_item(g_current_block)
    i := i+1;
    v_len := v_len - length(one_record)-3;

 END LOOP;  -- while v_len > 0
    v_name := nameCount || resource_seperator || v_name;

 if p_fetch_type = 'NEXT' or p_fetch_type is null then
    g_block_start_item.extend;
    g_block_start_row.extend;
    g_block_start_item(g_current_block+1) := recordCount;
    g_block_start_row(g_current_block+1) := a-1;
 end if;

END;

Procedure fetchLoadData(p_plan_id number,
                                   p_res_list varchar2,
                                   p_start varchar2 default null,
                                   p_end varchar2 default null,
                                   v_require_data IN OUT NOCOPY maxCharTbl,
                                   v_avail_data OUT NOCOPY varchar2) IS
  v_org_id number;
  v_instance_id number;
  v_dept_id number;
  v_res_id number;
  v_len number;
  one_record varchar2(100);
  i number:=1;
  j number:=1;
  k number:=0;
  a number;
  b number;
  oneAvailRecord varchar2(32000);
  oneAssignRecord maxCharTbl := maxCharTbl(0);
  availCount number;
  reqCount number;
  p_day_bkt_start_date date;
  p_hour_bkt_start_date date;
  new_hour number;
  time_change boolean :=false;
  v_total_avail number;
  CURSOR line_rate IS
     select max_rate
       from msc_department_resources
       where organization_id =v_org_id
         and sr_instance_id = v_instance_id
         and department_id = v_dept_id
         and resource_id = v_res_id
         and plan_id = -1;

  CURSOR finite_avail IS
     select 1
       from msc_net_resource_avail
       where organization_id =v_org_id
         and sr_instance_id = v_instance_id
         and department_id = v_dept_id
         and resource_id = v_res_id
         and plan_id = p_plan_id
         and nvl(parent_id, 0) <> -1;

  v_finite_avail number;

  TYPE date_arr IS TABLE OF date;
  v_req_start date_arr;
  v_req_end date_arr;
  v_avail_start date_arr;
  v_avail_end date_arr;
  v_bkt_start date_arr;
  v_bkt_end date_arr;

  v_req_qty number_arr;
  v_avail_qty number_arr;
  v_over_cap number_arr;
  v_batch number_arr;

  v_qty number :=0;
  new_start date;
  new_end date;
  bkt_qty number :=0;
  max_cap number;
  eff_rate number;

   v_line_rate number;
   v_dummy number;
   v_max_len number;
   v_one_record varchar2(200);

BEGIN
  select nvl(MIN_CUTOFF_BUCKET,0)+nvl(HOUR_CUTOFF_BUCKET,0)+data_start_date,
         nvl(MIN_CUTOFF_BUCKET,0)+data_start_date
    into p_day_bkt_start_date,
         p_hour_bkt_start_date
   from msc_plans
  where plan_id = p_plan_id;

    -- parse the resource_list
    -- the format of res_list is
    -- (instance_id, org_id, dept_id, res_id),(ins_id, org_id, dept_id, res_id)

 v_len := length(p_res_list);
 while v_len > 0 LOOP

    one_record :=
      substr(p_res_list,instr(p_res_list,'(',1,i)+1,
                        instr(p_res_list,')',1,i)-instr(p_res_list,'(',1,i)-1);

    v_instance_id := to_number(substr(one_record,1,instr(one_record,',')-1));

    v_org_id := to_number(substr(one_record,instr(one_record,',',1,1)+1,
                       instr(one_record,',',1,2)-instr(one_record,',',1,1)-1));

    v_dept_id := to_number(substr(one_record,instr(one_record,',',1,2)+1
                      ,instr(one_record,',',1,3)-instr(one_record,',',1,2)-1));

    v_res_id := to_number(substr(one_record,instr(one_record,',',1,3)+1));

    oneAvailRecord := null;
    availCount :=0;
    j := 1;
    oneAssignRecord.delete;
    oneAssignRecord.extend;
    reqCount :=0;

    if v_res_id =-1 then
      OPEN line_rate;
      FETCH line_rate INTO v_line_rate;
      CLOSE line_rate;
    else
      v_line_rate :=1;
    end if;

    v_finite_avail := null;

    OPEN finite_avail;
    FETCH finite_avail INTO v_finite_avail;
    CLOSE finite_avail;

    v_line_rate := nvl(v_line_rate, 1);

      select start_date, end_date, assigned_units, over_cap, batch_number
      BULK COLLECT INTO v_req_start, v_req_end, v_req_qty, v_over_cap, v_batch
      FROM (
           select  -- req has been moved will use parent_id =2
               decode(nvl(firm_flag,0),
                      NO_FIRM, start_date,
                      FIRM_RESOURCE, start_date,
                      FIRM_END,
                       firm_end_date - (end_date - start_date),
                      FIRM_END_RES,
                       firm_end_date - (end_date - start_date),
                      nvl(firm_start_date, start_date)) start_date,
               least(g_cutoff_date,
                decode(nvl(firm_flag,0),
                      NO_FIRM, end_date,
                      FIRM_RESOURCE, end_date,
                      FIRM_START,
                       firm_start_date + (end_date - start_date),
                      FIRM_START_RES,
                       firm_start_date + (end_date - start_date),
                      nvl(firm_end_date, end_date))) end_date,
             assigned_units,
             nvl(overloaded_capacity,0) over_cap,
             batch_number
        from msc_resource_requirements
       where organization_id =v_org_id
         and sr_instance_id = v_instance_id
         and department_id = v_dept_id
         and resource_id = v_res_id
         and plan_id = p_plan_id
         and end_date is not null
         and batch_number is null
         and nvl(parent_id,2) =2
         and status = 0
         and applied = 2
         and nvl(firm_start_date,start_date) <= g_cutoff_date
         and (  decode(nvl(firm_flag,0),
                      NO_FIRM, start_date,
                      FIRM_RESOURCE, start_date,
                      FIRM_END,
                       firm_end_date - (end_date - start_date),
                      FIRM_END_RES,
                       firm_end_date - (end_date - start_date),
                      nvl(firm_start_date, start_date)) <=
                  to_date(p_end,format_mask)
               and decode(nvl(firm_flag,0),
                      NO_FIRM, end_date,
                      FIRM_RESOURCE, end_date,
                      FIRM_START,
                       firm_start_date + (end_date - start_date),
                      FIRM_START_RES,
                       firm_start_date + (end_date - start_date),
                      nvl(firm_end_date, end_date)) >=
                  to_date(p_start,format_mask) )
     UNION ALL
           select  -- req has not been moved will use parent_id =1
             mrr2.start_date,
             least(g_cutoff_date,
                   decode(sign(mrr2.end_date-mrr2.start_date), 1,
                            mrr2.end_date, trunc(mrr2.start_date)+1
                          )
                  ) end_date,
             mrr2.resource_hours assigned_units,
             -1 over_cap,
             mrr2.batch_number
        from msc_resource_requirements mrr,
             msc_resource_requirements mrr2
       where mrr.organization_id =v_org_id
         and mrr.sr_instance_id = v_instance_id
         and mrr.department_id = v_dept_id
         and mrr.resource_id = v_res_id
         and mrr.plan_id = p_plan_id
         and mrr.batch_number is null
         and mrr.end_date is not null
         and nvl(mrr.parent_id,2) =2
         and (nvl(mrr.status,1) <> 0 or nvl(mrr.applied,1) <> 2)
         and nvl(mrr.firm_start_date,mrr.start_date) <= g_cutoff_date
         and (  decode(nvl(mrr.firm_flag,0),
                      NO_FIRM, mrr.start_date,
                      FIRM_RESOURCE, mrr.start_date,
                      FIRM_END,
                       mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                      FIRM_END_RES,
                       mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                      nvl(mrr.firm_start_date, mrr.start_date)) <=
                  to_date(p_end,format_mask)
               and decode(nvl(mrr.firm_flag,0),
                      NO_FIRM, mrr.end_date,
                      FIRM_RESOURCE, mrr.end_date,
                      FIRM_START,
                       mrr.firm_start_date + (mrr.end_date - mrr.start_date),
                      FIRM_START_RES,
                       mrr.firm_start_date + (mrr.end_date - mrr.start_date),
                      nvl(mrr.firm_end_date, mrr.end_date)) >=
                  to_date(p_start,format_mask) )
         and mrr2.parent_id =1
         and mrr2.organization_id =mrr.organization_id
         and mrr2.sr_instance_id = mrr.sr_instance_id
         and mrr2.department_id = mrr.department_id
         and mrr2.resource_id = mrr.resource_id
         and mrr2.plan_id = mrr.plan_id
         and mrr2.supply_id = mrr.supply_id
         and mrr2.resource_hours > 0
         and mrr2.operation_seq_num = mrr.operation_seq_num
         and mrr2.resource_seq_num = mrr.resource_seq_num
         and mrr2.end_date is not null
     UNION ALL
      select -- batch resource from parent_id = 1
             min(mrr2.start_date) start_date,
             max(least(g_cutoff_date,
                    decode(sign(mrr2.end_date-mrr2.start_date), 1,
                            mrr2.end_date, trunc(mrr2.start_date)+1
                          )
               )) end_date,
             max(mrr2.resource_hours) assigned_units,
             -1 over_cap,
             mrr2.batch_number
        from msc_resource_requirements mrr,
             msc_resource_requirements mrr2
       where mrr.organization_id =v_org_id
         and mrr.sr_instance_id = v_instance_id
         and mrr.department_id = v_dept_id
         and mrr.resource_id = v_res_id
         and mrr.plan_id = p_plan_id
         and mrr.batch_number is not null
         and mrr.end_date is not null
         and nvl(mrr.parent_id,2) =2
         and (nvl(mrr.status,1) <> 0 or nvl(mrr.applied,1) <> 2)
         and nvl(mrr.firm_start_date,mrr.start_date) <= g_cutoff_date
         and (  decode(nvl(mrr.firm_flag,0),
                      NO_FIRM, mrr.start_date,
                      FIRM_RESOURCE, mrr.start_date,
                      FIRM_END,
                       mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                      FIRM_END_RES,
                       mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                      nvl(mrr.firm_start_date, mrr.start_date)) <=
                  to_date(p_end,format_mask)
               and decode(nvl(mrr.firm_flag,0),
                      NO_FIRM, mrr.end_date,
                      FIRM_RESOURCE, mrr.end_date,
                      FIRM_START,
                       mrr.firm_start_date + (mrr.end_date - mrr.start_date),
                      FIRM_START_RES,
                       mrr.firm_start_date + (mrr.end_date - mrr.start_date),
                      nvl(mrr.firm_end_date, mrr.end_date)) >=
                  to_date(p_start,format_mask) )
         and mrr2.parent_id =1
         and mrr2.organization_id =mrr.organization_id
         and mrr2.sr_instance_id = mrr.sr_instance_id
         and mrr2.department_id = mrr.department_id
         and mrr2.resource_id = mrr.resource_id
         and mrr2.plan_id = mrr.plan_id
         and mrr2.supply_id = mrr.supply_id
         and mrr2.resource_hours > 0
         and mrr2.operation_seq_num = mrr.operation_seq_num
         and mrr2.resource_seq_num = mrr.resource_seq_num
         and mrr2.end_date is not null
      group by mrr2.batch_number
     UNION ALL
      select  -- batch resource from parent_id = 2
             min(
               decode(nvl(firm_flag,0),
                      NO_FIRM, start_date,
                      FIRM_RESOURCE, start_date,
                      FIRM_END,
                       firm_end_date - (end_date - start_date),
                      FIRM_END_RES,
                       firm_end_date - (end_date - start_date),
                      nvl(firm_start_date, start_date))) start_date,
             max(least(g_cutoff_date,
               decode(nvl(firm_flag,0),
                      NO_FIRM, end_date,
                      FIRM_RESOURCE, end_date,
                      FIRM_START,
                       firm_start_date + (end_date - start_date),
                      FIRM_START_RES,
                       firm_start_date + (end_date - start_date),
                      nvl(firm_end_date, end_date)))) end_date,
             max(assigned_units) assigned_units,
             max(nvl(overloaded_capacity,0)) over_cap
             , batch_number
        from msc_resource_requirements
       where organization_id =v_org_id
         and sr_instance_id = v_instance_id
         and department_id = v_dept_id
         and resource_id = v_res_id
         and plan_id = p_plan_id
         and batch_number is not null
         and end_date is not null
         and nvl(parent_id,2) =2
         and status =0
         and applied =2
         and nvl(firm_start_date,start_date) <= g_cutoff_date
         and (  decode(nvl(firm_flag,0),
                      NO_FIRM, start_date,
                      FIRM_RESOURCE, start_date,
                      FIRM_END,
                       firm_end_date - (end_date - start_date),
                      FIRM_END_RES,
                       firm_end_date - (end_date - start_date),
                      nvl(firm_start_date, start_date)) <=
                  to_date(p_end,format_mask)
               and decode(nvl(firm_flag,0),
                      NO_FIRM, end_date,
                      FIRM_RESOURCE, end_date,
                      FIRM_START,
                       firm_start_date + (end_date - start_date),
                      FIRM_START_RES,
                       firm_start_date + (end_date - start_date),
                      nvl(firm_end_date, end_date)) >=
                  to_date(p_start,format_mask))
       group by batch_number)
       order by start_date
;

      select
             shift_date+from_time/86400,
             decode(sign(to_time-from_time), 1,
                     shift_date+to_time/86400,
                     shift_date+1+to_time/86400),
             capacity_units
      bulk collect into v_avail_start, v_avail_end, v_avail_qty
        from msc_net_resource_avail mrr
       where organization_id =v_org_id
         and sr_instance_id = v_instance_id
         and department_id = v_dept_id
         and resource_id = v_res_id
         and plan_id = p_plan_id
         and nvl(parent_id,0) <> -1
         and capacity_units > 0
         and (shift_date+from_time/86400) <=
             to_date(p_end,format_mask)
         and decode(sign(to_time-from_time), 1,
                     shift_date+to_time/86400,
                     shift_date+1+to_time/86400) >=
             to_date(p_start,format_mask)
         and shift_date <= g_cutoff_date
       order by shift_date, from_time, to_time;

    select mpb.bkt_start_date,mpb.bkt_end_date
     BULK COLLECT INTO v_bkt_start, v_bkt_end
    from msc_plan_buckets mpb,
         msc_plans mp
    where mp.plan_id =p_plan_id
    and mpb.plan_id = mp.plan_id
    and mpb.organization_id = mp.organization_id
    and mpb.sr_instance_id = mp.sr_instance_id
    and ( mpb.bkt_start_date between to_date(p_start,format_mask) and
                                   to_date(p_end,format_mask)
          or
          mpb.bkt_end_date between to_date(p_start,format_mask) and
                                   to_date(p_end,format_mask) )
    and mpb.bkt_start_date >= p_day_bkt_start_date
    order by 1;

-- for hourly bucket, round down start_time/round up end_time to a whole hour

      for b in 1 .. v_avail_start.count loop
        time_change := false;
        if v_avail_start(b) >= p_hour_bkt_start_date and
           v_avail_start(b) < p_day_bkt_start_date then
           v_total_avail := (v_avail_end(b)-v_avail_start(b))*24*
                             v_avail_qty(b);
           if to_char(v_avail_start(b),'MI') <> '00' then
              v_avail_start(b) := to_date(to_char(
                                          v_avail_start(b),'MM/DD/RR, HH24'),
                                          'MM/DD/RR HH24');
              time_change := true;
           end if;
           if to_char(v_avail_end(b),'MI') <> '00' then
              if to_char(v_avail_end(b),'HH24') = '23' then
                 v_avail_end(b) := to_date(to_char(
                                          v_avail_start(b),'MM/DD/RR')||
                                          ' 23:59',
                                          'MM/DD/RR HH24:MI');
              else
                 new_hour := to_number(to_char(v_avail_end(b),'HH24'))+1;
                 v_avail_end(b) := to_date(to_char(
                                          v_avail_start(b),'MM/DD/RR')||' '||
                                          new_hour,
                                          'MM/DD/RR HH24');
              end if;
              time_change := true;
           end if;
           if time_change then
              v_avail_qty(b) := round(v_total_avail/
                                     ((v_avail_end(b)-v_avail_start(b))*24),6);
           end if;

        end if;

      end loop;

-- for minute and hourly bucket, don't group it
      for b in 1 .. v_avail_start.count loop
        if v_avail_start(b) < p_day_bkt_start_date then
             new_end := least(v_avail_end(b),p_day_bkt_start_date);
             if oneAvailRecord is not null then
                oneAvailRecord :=
                      oneAvailRecord || field_seperator ||
                      to_char(v_avail_start(b),format_mask) ||
                      field_seperator ||
                      to_char(new_end,format_mask) ||
                      field_seperator ||
                      fnd_number.number_to_canonical(v_avail_qty(b))||
                      field_seperator ||
                          0;
             else
                oneAvailRecord :=
                      to_char(v_avail_start(b),format_mask) ||
                      field_seperator ||
                      to_char(new_end,format_mask) ||
                      field_seperator ||
                      fnd_number.number_to_canonical(v_avail_qty(b))||
                      field_seperator ||
                          0;
             end if;
            availCount := availCount+1;
        end if;
      end loop;

      for b in 1 .. v_req_start.count loop
        if v_req_start(b) < p_day_bkt_start_date then
             v_qty := v_req_qty(b)* v_line_rate;
             new_end := least(v_req_end(b),p_day_bkt_start_date);
           if v_over_cap(b) = v_qty or -- req is overloaded during the break
                v_over_cap(b) = -1 then -- req from parent_id =1

             if v_over_cap(b) = -1 then -- from parent_id = 1
                  v_qty := round(v_req_qty(b)/((v_req_end(b)-v_req_start(b))*24),6);
                  v_over_cap(b) := v_qty;
             end if;
                v_one_record :=
                      to_char(v_req_start(b),format_mask) ||
                      field_seperator ||
                      to_char(new_end,format_mask) ||
                      field_seperator ||
                      fnd_number.number_to_canonical(v_qty)||
                      field_seperator ||
                      fnd_number.number_to_canonical(v_over_cap(b));
                v_max_len := nvl(length(oneAssignRecord(j)),0) +
                            nvl(length(v_one_record),0);
               if v_max_len > 30000 then
                     j := j+1;
                     oneAssignRecord.extend;
               end if;

               oneAssignRecord(j) := oneAssignRecord(j) || field_seperator ||
                          v_one_record;
               reqCount := reqCount+1;
         else -- only pass the req which has avail
          for a in 1 .. v_avail_start.count loop
             if (v_avail_start(a) >= v_req_start(b) and
                 v_avail_start(a) <= v_req_end(b)) or
                (v_avail_end(a) >= v_req_start(b) and
                 v_avail_end(a) <= v_req_end(b)) or
                (v_req_start(b) >= v_avail_start(a) and
                 v_req_end(b) <= v_avail_end(a))then
               new_start := greatest(v_req_start(b), v_avail_start(a));
               new_end := least(v_req_end(b), v_avail_end(a));
               v_one_record :=
                      to_char(new_start,format_mask) ||
                      field_seperator ||
                      to_char(new_end,format_mask) ||
                      field_seperator ||
                      fnd_number.number_to_canonical(v_qty)||
                      field_seperator ||
                      fnd_number.number_to_canonical(v_qty);
                v_max_len := nvl(length(oneAssignRecord(j)),0) +
                            nvl(length(v_one_record),0);
               if v_max_len > 30000 then
                     j := j+1;
                     oneAssignRecord.extend;
               end if;

               oneAssignRecord(j) := oneAssignRecord(j) || field_seperator ||
                          v_one_record;
            reqCount := reqCount+1;
             end if;
          end loop;

         end if;
        end if;
      end loop;


-- for daily, weekly, period buckets
    for a in 1 .. v_bkt_start.count loop

      bkt_qty := 0;
      v_qty := 0;
      eff_rate := 0;
      max_cap := 0;
    -- found all res avail for one bucket
      for b in 1 .. v_avail_start.count loop
        if (v_avail_start(b) > v_bkt_end(a) or
            v_avail_end(b) < v_bkt_start(a) ) then
            v_qty := 0;
        else
            new_start := greatest(v_avail_start(b), v_bkt_start(a));
            new_end := least(v_avail_end(b), v_bkt_end(a));
            v_qty := v_avail_qty(b);
        end if;
        if v_qty <> 0 then
           bkt_qty := bkt_qty +
                (new_end - new_start) * v_qty/(v_bkt_end(a)- v_bkt_start(a));
           max_cap := greatest(max_cap, v_qty);
        end if;
      end loop;

      if (bkt_qty <> 0) then
             eff_rate := bkt_qty / max_cap;
             bkt_qty := round(bkt_qty,6);
             if oneAvailRecord is not null then
                oneAvailRecord :=
                      oneAvailRecord || field_seperator ||
                      to_char(v_bkt_start(a),format_mask) || field_seperator ||
                      to_char(v_bkt_end(a),format_mask) || field_seperator ||
                      fnd_number.number_to_canonical(bkt_qty)||
                      field_seperator ||
                          0;
             else
                oneAvailRecord :=
                      to_char(v_bkt_start(a),format_mask) || field_seperator ||
                      to_char(v_bkt_end(a),format_mask) || field_seperator ||
                      fnd_number.number_to_canonical(bkt_qty)||
                      field_seperator ||
                          0;
             end if;
             availCount := availCount+1;
      end if;
      bkt_qty := 0;
      v_qty := 0;

-- found all req in one bucket
      for b in 1 .. v_req_start.count loop
        if (v_req_start(b) > v_bkt_end(a) or
            v_req_end(b) < v_bkt_start(a) ) then
            v_qty := 0;
        elsif  v_over_cap(b) <> -1 and -- not from parent_id = 1
              eff_rate = 0 and v_over_cap(b) <> v_req_qty(b) then
            v_qty := 0;
        else
            new_start := greatest(v_req_start(b), v_bkt_start(a));
            new_end := least(v_req_end(b), v_bkt_end(a));
            if v_over_cap(b) = -1 then -- from parent_id = 1
                  v_qty := v_req_qty(b)/((v_req_end(b)-v_req_start(b))*24);
            else
               v_qty := v_req_qty(b)* v_line_rate;
            end if;
        end if;
        if v_qty <> 0 then
           if (v_over_cap(b) = v_req_qty(b) or
                         v_over_cap(b) = -1 ) then
             bkt_qty := bkt_qty +
                (new_end - new_start)
                   * v_qty/(v_bkt_end(a)- v_bkt_start(a));
           else
             bkt_qty := bkt_qty +
                (new_end - new_start)
                   * v_qty * eff_rate/(v_bkt_end(a)- v_bkt_start(a));
           end if;
        end if;
      end loop;

      if bkt_qty <> 0 then
         bkt_qty := round(bkt_qty, 6);
         v_one_record :=
                      to_char(v_bkt_start(a),format_mask) || field_seperator ||
                      to_char(v_bkt_end(a),format_mask) || field_seperator ||
                      fnd_number.number_to_canonical(bkt_qty)||
                      field_seperator ||
                      fnd_number.number_to_canonical(bkt_qty);
         v_max_len := nvl(length(oneAssignRecord(j)),0) +
                            nvl(length(v_one_record),0);
         if v_max_len > 30000 then
                     j := j+1;
                     oneAssignRecord.extend;
         end if;
         oneAssignRecord(j) := oneAssignRecord(j) || field_seperator ||
                          v_one_record;
         reqCount := reqCount+1;
      end if;
    end loop;

    v_require_data.extend;
    k := k+1;
    if i = 1 then -- not the first record
       v_require_data(k) := to_char(i-1) || field_seperator ||
                            reqCount;
    else
       v_require_data(k) := record_seperator ||
                            to_char(i-1) || field_seperator ||
                            reqCount;
    end if;

    for j in 1 .. oneAssignRecord.count loop
      if j = 1 then
         v_require_data(k) := v_require_data(k) || oneAssignRecord(j);
      else
          v_require_data.extend;
          k := k+1;
          v_require_data(k) := oneAssignRecord(j);
      end if;
    end loop;

    if v_finite_avail is null and oneAvailRecord is null then
       oneAvailRecord := 1;
    end if;

       if v_avail_data is not null then
          v_avail_data := v_avail_data || record_seperator ||
                            to_char(i-1) || field_seperator ||
                            availCount || field_seperator ||
                            oneAvailRecord;
        else
          v_avail_data :=
                           to_char(i-1) || field_seperator ||
                           availCount || field_seperator ||
                            oneAvailRecord;
        end if;



    i := i+1;
    v_len := v_len - length(one_record)-3;
 END LOOP;

END;


Function loadAltResource(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             p_alt_resource number,
                             p_alt_num number) return Varchar2 IS
   l_firm_flag number;
   l_basis_type number;
   l_rout_seq number;
   l_op_seq number;
   l_res_seq number;
   l_supply_id number;
   l_act_group number;
   l_avail_res_seq number;

   CURSOR res_seq IS
    Select distinct mors.resource_seq_num
     from  msc_operation_resource_seqs mors
     where mors.plan_id = p_plan_id
       and mors.routing_sequence_id = l_rout_seq
       and mors.operation_sequence_id = l_op_seq
       and mors.sr_instance_id = p_instance_id
       and mors.activity_group_id = l_act_group
       ;

   CURSOR res_group IS
    SELECT distinct mrr.transaction_id,mor.principal_flag
      FROM msc_resource_requirements mrr,
           msc_operation_resources mor
     WHERE mrr.plan_id = p_plan_id
      AND mrr.sr_instance_id = p_instance_id
      and mrr.routing_sequence_id = l_rout_seq
      AND mrr.operation_sequence_id = l_op_seq
      AND mrr.resource_seq_num = l_res_seq
      and mor.plan_id = p_plan_id
      and mor.sr_instance_id = p_instance_id
      and mor.routing_sequence_id = mrr.routing_sequence_id
      and mor.operation_sequence_id = mrr.operation_sequence_id
      and mor.resource_seq_num = mrr.resource_seq_num
      and mor.resource_id = mrr.resource_id
      AND mor.alternate_number <> p_alt_num
      AND mrr.parent_id =2
      and mrr.supply_id = l_supply_id
      order by mor.principal_flag;

  CURSOR alt_res_group IS
    SELECT mor.resource_usage,
           mor.resource_units,
           mor.resource_id,
           mor.alternate_number,
           mor.principal_flag
      FROM msc_operation_resources mor
     WHERE mor.plan_id = p_plan_id
      AND mor.routing_sequence_id = l_rout_seq
      AND mor.sr_instance_id = p_instance_id
      AND mor.operation_sequence_id = l_op_seq
      AND mor.resource_seq_num = l_res_seq
      AND mor.alternate_number = p_alt_num
      order by mor.principal_flag;

  TYPE ResRecTyp IS RECORD (
         resource_usage number,
         resource_units number,
         resource_id number,
         alternate_number number,
         principal_flag number);
  TYPE SimRecTyp IS RECORD (
         transaction_id number,
         principal_flag number);

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
BEGIN
     --get corresponding info about this tranx
     select
            mrr.routing_sequence_id, mrr.operation_sequence_id,
            mrr.resource_seq_num,mrr.supply_id,mrr.basis_type
       into
            l_rout_seq, l_op_seq, l_res_seq, l_supply_id,l_basis_type
       FROM msc_resource_requirements mrr
      WHERE mrr.plan_id = p_plan_id
            and mrr.transaction_id = p_transaction_id
            and mrr.sr_instance_id = p_instance_id;

         IF l_basis_type = 1 THEN
           select new_order_quantity
             into v_qty
             from msc_supplies
            where plan_id = p_plan_id
              and transaction_id = l_supply_id;
         ELSE
           v_qty := 1;
         END IF;

     -- find the activity_group_id
     select activity_group_id
       into l_act_group
       from msc_operation_resource_seqs
      where plan_id = p_plan_id
        and routing_sequence_id = l_rout_seq
        and operation_sequence_id = l_op_seq
        and resource_seq_num = l_res_seq
        and sr_instance_id = p_instance_id;

     if l_act_group is null then
          l_all_seq(1) := l_res_seq;
     else
        i :=1;
        OPEN res_seq;
        LOOP
          FETCH res_seq INTO l_all_seq(i);
          EXIT WHEN res_seq%NOTFOUND;
          i:= i+1;
        END LOOP;
        CLOSE res_seq;

        select count(*)
          into l_avail_res_seq
          from (
             select distinct mors.resource_seq_num
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
                and mor.alternate_number = p_alt_num
          );
        if l_avail_res_seq is null or l_avail_res_seq < l_all_seq.LAST then
           return 'NO_ALT';
        end if;

     end if;

     for j in 1..l_all_seq.LAST LOOP
         -- fetch the resources in the same resource group
         l_res_seq := l_all_seq(j);
         i :=1;
         OPEN res_group;
         LOOP
           FETCH res_group INTO l_simu_res(i);
           EXIT WHEN res_group%NOTFOUND;
             i:= i+1;
         END LOOP;
         CLOSE res_group;

         -- fetch the resources in the alternate resource group
         i:=1;
         OPEN alt_res_group;
         LOOP
           FETCH alt_res_group INTO l_alt_res(i);
           EXIT WHEN alt_res_group%NOTFOUND;
           i:= i+1;
         END LOOP;
         CLOSE alt_res_group;

         i:=1;
         while (l_simu_res.LAST >= i or l_alt_res.LAST >= i)
         loop
           if i > l_simu_res.LAST THEN -- add the res from alt res group

             v_hours := v_qty * l_alt_res(i).resource_usage;

             insert into msc_resource_requirements(
                   TRANSACTION_ID                  ,
                   PLAN_ID                         ,
                   SUPPLY_ID                       ,
                   ORGANIZATION_ID                 ,
                   SR_INSTANCE_ID                  ,
                   ROUTING_SEQUENCE_ID             ,
                   OPERATION_SEQUENCE_ID           ,
                   RESOURCE_SEQ_NUM                ,
                   RESOURCE_ID                     ,
                   DEPARTMENT_ID                   ,
                   ALTERNATE_NUM                   ,
                   START_DATE                      ,
                   END_DATE                        ,
                   BKT_START_DATE                  ,
                   RESOURCE_HOURS                  ,
                   SET_UP                                   ,
                   BKT_END_DATE                             ,
                   TEAR_DOWN                                ,
                   AGGREGATE_RESOURCE_ID                    ,
                   SCHEDULE_FLAG                            ,
                   PARENT_ID                                ,
                   STD_OP_CODE                              ,
                   WIP_ENTITY_ID                            ,
                   ASSIGNED_UNITS                  ,
                   BASIS_TYPE                               ,
                   OPERATION_SEQ_NUM                        ,
                   LOAD_RATE                                ,
                   DAILY_RESOURCE_HOURS                     ,
                   STATUS                                   ,
                   APPLIED                                  ,
                   UPDATED                                  ,
                   SUBST_RES_FLAG                           ,
                   REFRESH_NUMBER                           ,
                   LAST_UPDATED_BY                 ,
                   LAST_UPDATE_DATE                ,
                   CREATED_BY                      ,
                   CREATION_DATE                   ,
                   LAST_UPDATE_LOGIN                        ,
                   SOURCE_ITEM_ID                           ,
                   ASSEMBLY_ITEM_ID                         ,
                   SUPPLY_TYPE                              ,
                   FIRM_START_DATE                          ,
                   FIRM_END_DATE                            ,
                   FIRM_FLAG                                )
            select msc_resource_requirements_s.nextval,
                   PLAN_ID                         ,
                   SUPPLY_ID                       ,
                   ORGANIZATION_ID                 ,
                   SR_INSTANCE_ID                  ,
                   ROUTING_SEQUENCE_ID             ,
                   OPERATION_SEQUENCE_ID           ,
                   RESOURCE_SEQ_NUM                ,
                   l_alt_res(i).resource_id        ,
                   DEPARTMENT_ID                   ,
                   l_alt_res(i).alternate_number   ,
                   START_DATE                      ,
                   END_DATE                        ,
                   BKT_START_DATE                  ,
                   v_hours                  ,
                   SET_UP                                   ,
                   BKT_END_DATE                             ,
                   TEAR_DOWN                                ,
                   AGGREGATE_RESOURCE_ID                    ,
                   SCHEDULE_FLAG                            ,
                   PARENT_ID                                ,
                   STD_OP_CODE                              ,
                   WIP_ENTITY_ID                            ,
                   ASSIGNED_UNITS                  ,
                   BASIS_TYPE                               ,
                   OPERATION_SEQ_NUM                        ,
                   LOAD_RATE                                ,
                   DAILY_RESOURCE_HOURS                     ,
                   0                                   ,
                   2                                  ,
                   UPDATED                                  ,
                   SUBST_RES_FLAG                           ,
                   REFRESH_NUMBER                           ,
                   LAST_UPDATED_BY                 ,
                   LAST_UPDATE_DATE                ,
                   CREATED_BY                      ,
                   CREATION_DATE                   ,
                   LAST_UPDATE_LOGIN                        ,
                   SOURCE_ITEM_ID                           ,
                   ASSEMBLY_ITEM_ID                         ,
                   SUPPLY_TYPE                              ,
                   FIRM_START_DATE                          ,
                   FIRM_END_DATE                            ,
                   FIRM_RESOURCE
             from msc_resource_requirements mrr
              WHERE mrr.plan_id = p_plan_id
              and mrr.transaction_id = l_simu_res(1).transaction_id
              and mrr.sr_instance_id = p_instance_id;

           ELSIF i > l_alt_res.LAST THEN -- delete the extra res
             select mrr.firm_flag
               into l_firm_flag
               FROM msc_resource_requirements mrr
              WHERE mrr.plan_id = p_plan_id
                and mrr.transaction_id = l_simu_res(i).transaction_id
                and mrr.sr_instance_id = p_instance_id
                for update of mrr.firm_flag nowait;
             delete msc_resource_requirements mrr
              where mrr.plan_id = p_plan_id
                and mrr.transaction_id = l_simu_res(i).transaction_id
                and mrr.sr_instance_id = p_instance_id;

           ELSE -- update the res to alt_res

             select mrr.firm_flag
               into l_firm_flag
               FROM msc_resource_requirements mrr
              WHERE mrr.plan_id = p_plan_id
                and mrr.transaction_id = l_simu_res(i).transaction_id
                and mrr.sr_instance_id = p_instance_id
                for update of mrr.firm_flag nowait;

             if l_firm_flag in (NO_FIRM, FIRM_RESOURCE) or l_firm_flag IS null THEN
                l_firm_flag := FIRM_RESOURCE;
             elsif l_firm_flag in (FIRM_START, FIRM_START_RES) THEN
                l_firm_flag := FIRM_START_RES;
             elsif l_firm_flag in (FIRM_END, FIRM_END_RES) THEN
                l_firm_flag := FIRM_END_RES;
             elsif l_firm_flag in (FIRM_ALL, FIRM_START_END) THEN
                l_firm_flag := FIRM_ALL;
             else
                l_firm_flag := FIRM_RESOURCE;
             end if;

             --undo_change(p_plan_id, l_rest_res(i), p_instance_id,
             --            l_firm_flag, l_firm_start, l_firm_end,
             --            l_alt_res(i).resource_id,
             --            l_alt_res(i).alternate_number,
             --            v_hours);
             v_hours := v_qty * l_alt_res(i).resource_usage;
             update msc_resource_requirements
                set status =0,
                    applied=2,
                    resource_id = l_alt_res(i).resource_id,
                    alternate_num = l_alt_res(i).alternate_number,
                    firm_flag = l_firm_flag,
                    resource_hours = v_hours
              where plan_id = p_plan_id
                and transaction_id = l_simu_res(i).transaction_id
                and sr_instance_id = p_instance_id;

           END IF;
           i := i+1;
         end loop;
     end LOOP;

         update msc_supplies
            set status = 0, applied = 2
         where  plan_id = p_plan_id
            and transaction_id = l_supply_id;

     --end LOOP;
     return 'OK';
exception
     when app_exception.record_lock_exception then
       return 'RECORD_LOCK';
END;

Function firmResource(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             p_firm_type number,
                             p_start varchar2,
                             p_end varchar2) return varchar2 IS
   v_start date;
   v_end date;
   v_return_status varchar2(10):= 'OK';
   v_out varchar2(100);
   l_firm_flag number;
   l_firm_start date;
   l_firm_end date;
   l_res_id number;
   l_alt_num number;
   l_supply_id number;
   v_transaction_id number;
   v_instance_id number;
   v_count number;
   l_start date;
   l_end date;

   CURSOR simu IS
    SELECT mrr2.transaction_id, mrr2.sr_instance_id
     FROM msc_resource_requirements mrr1,
          msc_resource_requirements mrr2
    WHERE mrr1.plan_id = p_plan_id
         and mrr1.transaction_id = p_transaction_id
         and mrr1.sr_instance_id = p_instance_id
         and mrr2.plan_id = mrr1.plan_id
         and mrr2.sr_instance_id = mrr1.sr_instance_id
         and mrr2.supply_id = mrr1.supply_id
         and mrr2.operation_seq_num = mrr1.operation_seq_num
         and mrr2.resource_seq_num = mrr1.resource_seq_num
         and mrr2.alternate_num = mrr1.alternate_num
         and mrr2.transaction_id <> mrr1.transaction_id
	 and mrr2.parent_id = 2;

BEGIN

    v_start := to_date(p_start, format_mask);
    v_end := to_date(p_end, format_mask);
    if (v_end <= v_start) then
       return 'END_BEFORE_START';
    end if;
    if p_firm_type not in (NO_FIRM,FIRM_RESOURCE) then
       -- validate if the time is OK

       validateTime(p_plan_id, p_transaction_id,
               p_instance_id, p_start,
               p_end,
               v_return_status, v_out);
    end if;

    if v_return_status = 'ERROR' then
       return v_out;
    else
     -- lock the record first

          select mrr.firm_flag,mrr.firm_start_date, mrr.firm_end_date,
                 mrr.resource_id, mrr.alternate_num, mrr.supply_id,
                 mrr.start_date, mrr.end_date
            into l_firm_flag, l_firm_start, l_firm_end,
                 l_res_id, l_alt_num, l_supply_id,
                 l_start, l_end
            FROM msc_resource_requirements mrr
            WHERE mrr.plan_id = p_plan_id
              and mrr.transaction_id = p_transaction_id
              and mrr.sr_instance_id = p_instance_id
              for update of mrr.firm_flag nowait;

       if p_firm_type in (NO_FIRM, FIRM_RESOURCE) THEN
          l_firm_start := to_date(null);
          l_firm_end := to_date(null);
          l_start := v_start;
          l_end := v_end;
       elsif p_firm_type in (FIRM_END, FIRM_END_RES) THEN
          l_firm_start := to_date(null);
          l_firm_end := v_end;
          l_start := v_start;
       elsif p_firm_type in (FIRM_START, FIRM_START_RES) THEN
          l_firm_start := v_start;
          l_firm_end := to_date(null);
          l_end := v_end;
       elsif p_firm_type in (FIRM_START_END,FIRM_ALL) THEN
          l_firm_start := v_start;
          l_firm_end := v_end;
       end if;

       --undo_change(p_plan_id, p_transaction_id, p_instance_id,
       --            p_firm_type, l_firm_start, l_firm_end,
       --            l_res_id, l_alt_num);

       update msc_resource_requirements
          set status =0,
              applied=2,
              firm_flag = p_firm_type,
              firm_start_date = l_firm_start,
              firm_end_date = l_firm_end,
              start_date = l_start,
              end_date = l_end
       where plan_id = p_plan_id
         and transaction_id = p_transaction_id
         and sr_instance_id = p_instance_id;

       update msc_supplies
          set status =0,
              applied=2
       where plan_id = p_plan_id
         and transaction_id = l_supply_id;

-- update the simultaneous resource also
      v_count :=0;
      OPEN simu;
      LOOP FETCH simu INTO v_transaction_id, v_instance_id;
      EXIT WHEN simu%NOTFOUND;

          select mrr.resource_id, mrr.alternate_num
            into l_res_id, l_alt_num
            FROM msc_resource_requirements mrr
            WHERE mrr.plan_id = p_plan_id
              and mrr.transaction_id = v_transaction_id
              and mrr.sr_instance_id = v_instance_id
              for update of mrr.firm_flag nowait;

       --undo_change(p_plan_id, v_transaction_id, v_instance_id,
       --            p_firm_type, l_firm_start, l_firm_end,
       --            l_res_id, l_alt_num);

       update msc_resource_requirements
          set status =0,
              applied=2,
              firm_flag = p_firm_type,
              firm_start_date = l_firm_start,
              firm_end_date = l_firm_end,
              start_date = l_start,
              end_date = l_end
       where plan_id = p_plan_id
         and transaction_id = v_transaction_id
         and sr_instance_id = v_instance_id;
       v_count := v_count+1;
      END LOOP;

      if v_count > 0 then
         return 'OK_WITH_ST_RES';
      else
         return 'OK';
      end if;
    end if;
exception when app_exception.record_lock_exception then
      return 'RECORD_LOCK';
END;

PROCEDURE fetchAltResource(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             v_name OUT NOCOPY varchar2,
                             v_id OUT NOCOPY varchar2) IS

  CURSOR alt_res IS
    SELECT mor.alternate_number ||':'||
           msc_get_name.resource_code(mor.resource_id, mrr.department_id,
                         mrr.organization_id, mrr.plan_id,
                         mrr.sr_instance_id),
           mor.resource_id,
           mor.alternate_number
      FROM msc_operation_resources mor,
           msc_resource_requirements mrr
     WHERE  mrr.plan_id = p_plan_id
      AND mrr.transaction_id = p_transaction_id
      AND mrr.sr_instance_id = p_instance_id
      AND mor.plan_id = mrr.plan_id
      AND mor.routing_sequence_id = mrr.routing_sequence_id
      AND mor.sr_instance_id = mrr.sr_instance_id
      AND mor.operation_sequence_id = mrr.operation_sequence_id
      AND mor.resource_seq_num = mrr.resource_seq_num
      AND mor.alternate_number <> mrr.alternate_num;

  CURSOR flag IS
    SELECT nvl(mrr.firm_flag,NO_FIRM)
      FROM msc_resource_requirements mrr
     WHERE mrr.plan_id = p_plan_id
      AND  mrr.transaction_id = p_transaction_id
      AND  mrr.sr_instance_id = p_instance_id;

  CURSOR activity_c IS
     select mors.activity_group_id,
            mrr.routing_sequence_id, mrr.operation_sequence_id,
            mrr.resource_seq_num
       from msc_operation_resource_seqs mors,
            msc_resource_requirements mrr
      where mrr.plan_id = p_plan_id
        and mrr.transaction_id = p_transaction_id
        and mrr.sr_instance_id = p_instance_id
        and mors.plan_id = mrr.plan_id
        and mors.routing_sequence_id = mrr.routing_sequence_id
        and mors.operation_sequence_id = mrr.operation_sequence_id
        and mors.resource_seq_num = mrr.resource_seq_num
        and mors.sr_instance_id = mrr.sr_instance_id;

 temp_name varchar2(30);
 temp_id number;
 temp_flag number;
 alt_number number;
 rowcount number;
 l_rout_seq number;
 l_op_seq number;
 l_res_seq number;
 l_total_seqs number;
 l_avail_seqs number;
 l_act_group number;
 l_flag varchar2(5);
BEGIN
     --get corresponding info about this tranx
     OPEN activity_c;
     FETCH activity_c INTO l_act_group,l_rout_seq, l_op_seq, l_res_seq;
     CLOSE activity_c;

      if l_act_group is not null then
         select count(*)
           into l_total_seqs
          from (Select distinct mors.resource_seq_num
                 from  msc_operation_resource_seqs mors
                 where mors.plan_id = p_plan_id
                   and mors.routing_sequence_id = l_rout_seq
                   and mors.operation_sequence_id = l_op_seq
                   and mors.sr_instance_id = p_instance_id
                   and mors.activity_group_id = l_act_group
               )  ;
      end if;

      rowcount :=0;
      OPEN alt_res;
      LOOP
         FETCH alt_res INTO temp_name, temp_id, alt_number;
         EXIT WHEN alt_res%NOTFOUND;
         rowcount := rowcount +1;
         if l_act_group is null then
            l_flag := 'Y';
         else
            select count(*)
              into l_avail_seqs
              from (
                select distinct mors.resource_seq_num
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
                   and mor.alternate_number = alt_number
              );
            if l_avail_seqs = l_total_seqs then
               l_flag := 'Y';
            else
               l_flag := 'N';
            end if;
        end if;

        if v_name is not null then
            v_name := v_name || field_seperator || temp_name;
            v_id := v_id || field_seperator || temp_id
                         || field_seperator || alt_number
                         || field_seperator || l_flag;
         else
            v_name := temp_name;
            v_id := temp_id || field_seperator || alt_number
                         || field_seperator || l_flag;
         end if;

      END LOOP;
      CLOSE alt_res;

      OPEN flag;
      FETCH flag INTO temp_flag;
      CLOSE flag;
      if temp_flag >= 8 then
           temp_flag := 0;
      end if;

       v_name := temp_flag || field_seperator ||
                 to_char(rowcount) || field_seperator || v_name;
       v_id := to_char(rowcount) || field_seperator || v_id;
END;

PROCEDURE fetchSimultaneousRes(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             v_name OUT NOCOPY varchar2,
                             v_id OUT NOCOPY varchar2) IS

  CURSOR smu_res IS
    SELECT msc_get_name.resource_code(mor.resource_id, mrr.department_id,
                         mrr.organization_id, mrr.plan_id,
                         mrr.sr_instance_id),
           mor.resource_id
      FROM msc_operation_resources mor,
           msc_resource_requirements mrr
     WHERE  mrr.plan_id = p_plan_id
      AND mrr.transaction_id = p_transaction_id
      AND mrr.sr_instance_id = p_instance_id
      AND mor.plan_id = mrr.plan_id
      AND mor.routing_sequence_id = mrr.routing_sequence_id
      AND mor.sr_instance_id = mrr.sr_instance_id
      AND mor.operation_sequence_id = mrr.operation_sequence_id
      AND mor.resource_seq_num = mrr.resource_seq_num
      AND mor.alternate_number = mrr.alternate_num
      AND mor.resource_id <> mrr.resource_id;

 temp_name varchar2(30);
 temp_id number;
 rowcount number;
BEGIN
      rowcount :=0;
      OPEN smu_res;
      LOOP
         FETCH smu_res INTO temp_name, temp_id;
         EXIT WHEN smu_res%NOTFOUND;
         rowcount := rowcount +1;
         if v_name is not null then
            v_name := v_name || field_seperator || temp_name;
            v_id := v_id || field_seperator || temp_id;
         else
            v_name := temp_name;
            v_id := temp_id;
         end if;

      END LOOP;
      CLOSE smu_res;
       v_name := to_char(rowcount) || field_seperator || v_name;
       v_id := to_char(rowcount) || field_seperator || v_id;

END;

PROCEDURE fetchPropertyData(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             v_job OUT NOCOPY varchar2,
                             v_demand OUT NOCOPY varchar2) IS

 CURSOR property IS
   SELECT msc_get_name.item_name(ms.inventory_item_id,null,null,null) item,
          mrr.operation_seq_num,
          ms.new_order_quantity qty,
          nvl(to_char(ms.firm_date,format_mask),'   ') firm_date,
          to_char(ms.new_schedule_date,format_mask) sugg_due_date,
          nvl(to_char(ms.need_by_date,format_mask),'   ') needby,
          nvl(ms.unit_number,'null') unit_number,
          nvl(msc_get_name.project(ms.project_id,
                               ms.organization_id,
                               ms.plan_id,
                               ms.sr_instance_id), 'null') project,
          nvl(msc_get_name.task(   ms.task_id,
                               ms.project_id,
                               ms.organization_id,
                               ms.plan_id,
                               ms.sr_instance_id),'null') task,
          ms.transaction_id,
          ms.organization_id,
          msc_get_name.org_code(mdr.organization_id, mdr.sr_instance_id) org,
          mdr.department_code,
          msc_get_gantt_data.order_number(ms.order_type,ms.order_number,
                         ms.plan_id, ms.sr_instance_id,
                         ms.transaction_id, ms.disposition_id) job_name,
          mrr.assigned_units,
          nvl(msc_get_name.lookup_meaning('RESOURCE_FIRM_TYPE',
                     nvl(mrr.firm_flag,NO_FIRM)),
              msc_get_name.lookup_meaning('RESOURCE_FIRM_TYPE',0))
              firm_flag,
          ms.firm_planned_type,
          nvl(mrr.alternate_num,0) alternate_num,
          mrr.resource_seq_num,
          nvl(mdr.resource_code, 'null') resource_code,
          mrr.resource_hours,
          nvl(msc_get_name.alternate_bom(pe.plan_id, pe.sr_instance_id,pe.bill_sequence_id),
              'null')
                    alternate_bom_designator,
          nvl(msc_get_name.alternate_bom(pe.plan_id, pe.sr_instance_id,pe.bill_sequence_id),
             'null')
                    alternate_routing_designator,
          nvl(to_char(msi.planning_time_fence_date, format_mask),'   ') time_fence,
          0 mtq_time, --get_MTQ_time(p_transaction_id, p_plan_id, p_instance_id) mtq_time,
          nvl(mdr.batchable_flag, 2) batchable,
          nvl(mrr.batch_number, -1) batch_number,
          nvl(mdr.unit_of_measure,'-1') uom,
          nvl(decode(mrr.basis_type, null, '-1',
            msc_get_name.lookup_meaning(
               'MSC_RES_BASIS_TYPE',mrr.basis_type)),'-1') basis_type,
          nvl(decode(mrr.schedule_flag, null, '-1',
            msc_get_name.lookup_meaning(
               'BOM_RESOURCE_SCHEDULE_TYPE',mrr.schedule_flag)),'-1') schedule_flag,
          nvl(to_char(mrr.EARLIEST_START_DATE,format_mask),'null') EPSD,
          nvl(to_char(mrr.EARLIEST_COMPLETION_DATE,format_mask),'null') EPCD,
          nvl(to_char(mrr.UEPSD,format_mask),'null') UEPSD,
          nvl(to_char(mrr.UEPCD,format_mask),'null') UEPCD,
          nvl(to_char(mrr.ULPSD,format_mask),'null') ULPSD,
          nvl(to_char(mrr.ULPCD,format_mask),'null') ULPCD
     FROM msc_supplies ms,
          msc_resource_requirements mrr,
          msc_department_resources mdr,
          msc_system_items msi,
          msc_process_effectivity pe
    WHERE pe.plan_id(+) = ms.plan_id
      AND pe.sr_instance_id(+) = ms.sr_instance_id
      AND pe.process_sequence_id(+) = ms.process_seq_id
      AND mrr.plan_id = p_plan_id
      AND mrr.transaction_id = p_transaction_id
      AND mrr.sr_instance_id = p_instance_id
      AND ms.plan_id = mrr.plan_id
      AND ms.transaction_id = mrr.supply_id
      AND ms.sr_instance_id = mrr.sr_instance_id
      AND mdr.plan_id = mrr.plan_id
      AND mdr.organization_id = mrr.organization_id
      AND mdr.sr_instance_id = mrr.sr_instance_id
      AND mdr.department_id = mrr.department_id
      AND mdr.resource_id = mrr.resource_id
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id;

 pro_record  property%ROWTYPE;

BEGIN
    OPEN property;
    FETCH property INTO pro_record;
    CLOSE property;

    v_job := replace_seperator(pro_record.item) || field_seperator ||
             pro_record.operation_seq_num || field_seperator ||
             pro_record.qty || field_seperator ||
             pro_record.firm_date || field_seperator ||
             pro_record.sugg_due_date || field_seperator ||
             pro_record.needby || field_seperator ||
             pro_record.unit_number || field_seperator ||
             pro_record.project || field_seperator ||
             pro_record.task || field_seperator ||
             replace_seperator(pro_record.department_code)|| field_seperator ||
             replace_seperator(pro_record.job_name) || field_seperator ||
             replace_seperator(pro_record.org) || field_seperator ||
             pro_record.assigned_units ||field_seperator ||
             pro_record.firm_flag || field_seperator ||
             pro_record.firm_planned_type || field_seperator ||
             pro_record.alternate_num || field_seperator ||
             pro_record.resource_seq_num || field_seperator ||
             replace_seperator(pro_record.resource_code) || field_seperator ||
             pro_record.resource_hours || field_seperator ||
             pro_record.alternate_bom_designator || field_seperator ||
             pro_record.alternate_routing_designator  || field_seperator ||
             pro_record.time_fence ||  field_seperator ||
             pro_record.mtq_time ||  field_seperator ||
             pro_record.batchable ||  field_seperator ||
             pro_record.batch_number ||  field_seperator ||
             pro_record.uom ||  field_seperator ||
             pro_record.basis_type ||  field_seperator ||
             pro_record.schedule_flag || field_seperator ||
             pro_record.EPSD || field_seperator ||
             pro_record.EPCD || field_seperator ||
             pro_record.UEPSD || field_seperator ||
             pro_record.UEPCD || field_seperator ||
             pro_record.ULPSD || field_seperator ||
             pro_record.ULPCD;

if pro_record.transaction_id is not null then
   fetchDemandData(p_plan_id, p_instance_id, pro_record.transaction_id,
                   pro_record.organization_id, v_demand);
end if;
END;

Procedure fetchDemandData( p_plan_id number,
                           p_instance_id number,
                           v_transaction_id number,
                           v_org_id number,
                           v_demand out NOCOPY varchar2) IS
 v_instance_id number;
 v_demand_id number;
 v_pegging_id number;
 v_pegged_qty number;
 v_days_late varchar2(3000);
 v_demand_quantity  number;
 v_item_id  number;
 v_demand_date  date;


 CURSOR pegging IS
  SELECT mfp2.demand_id, mfp2.sr_instance_id,
         sum(nvl(mfp1.allocated_quantity,0)),
         mfp2.demand_quantity,
         mfp2.demand_date,
         mfp2.inventory_item_id
    FROM msc_full_pegging mfp1,
         msc_full_pegging mfp2
   WHERE mfp1.plan_id = p_plan_id
         AND mfp1.organization_id = v_org_id
         AND mfp1.sr_instance_id = p_instance_id
         AND mfp1.transaction_id = v_transaction_id
         AND mfp2.plan_id = mfp1.plan_id
         AND mfp2.sr_instance_id = mfp1.sr_instance_id
         AND mfp2.pegging_id = mfp1.end_pegging_id
         group by mfp2.demand_id, mfp2.sr_instance_id,
                  mfp2.demand_quantity, mfp2.demand_date,
                  mfp2.inventory_item_id;

 CURSOR other_demand IS
  SELECT nvl(v_demand_quantity,0) qty,
         nvl(to_char(v_demand_date,
                  format_mask), 'null') demand_date,
          msc_get_name.lookup_meaning('MRP_FLP_SUPPLY_DEMAND_TYPE',
               v_demand_id) type,
          item_name item
     FROM msc_items
    WHERE inventory_item_id = v_item_id;

 CURSOR demand IS
   SELECT md.using_requirement_quantity qty,
          to_char(md.using_assembly_demand_date,
                  format_mask) demand_date,
          nvl(decode(md.schedule_designator_id, null, md.order_number,
                     msc_get_name.designator(md.schedule_designator_id)),
              'null') name,
          msc_get_name.lookup_meaning('MRP_DEMAND_ORIGINATION',
               md.origination_type) type,
          msc_get_name.item_name(md.inventory_item_id, null,null,null) item,
          nvl(md.demand_priority,0) priority,
          nvl(msc_get_name.customer(md.customer_id),
                      'null') customer,
          nvl(msc_get_name.customer_site(md.customer_site_id),
                      'null') customer_site,
          nvl(to_char(md.dmd_satisfied_date,format_mask),
                'null') satisfied_date,
          decode(sign(md.dmd_satisfied_date - md.using_assembly_demand_date),
                 1, GREATEST(round(md.dmd_satisfied_date -
              md.using_assembly_demand_date,2), 0.01), 0) days_late,
          nvl(to_char(md.quantity_by_due_date),'null') qty_by_due_date,
          msc_get_name.org_code(md.organization_id, md.sr_instance_id) org,
          nvl(md.demand_class,'null') demand_class
     FROM msc_demands md
    WHERE md.plan_id = p_plan_id
      AND md.demand_id = v_demand_id
      AND md.sr_instance_id =v_instance_id
      ;

 demand_rec demand%ROWTYPE;
 other_demand_rec other_demand%ROWTYPE;
 rowcount number;
BEGIN
    rowcount :=0;

    OPEN pegging;
    LOOP
     FETCH pegging INTO v_demand_id, v_instance_id, v_pegged_qty,
                        v_demand_quantity, v_demand_date, v_item_id;
     EXIT WHEN pegging%NOTFOUND or nvl(length(v_demand),0) > 31000;
     rowcount := rowcount +1;
     IF v_demand_id not in (-1,-2,-3,18) THEN
        OPEN demand;
        FETCH demand INTO demand_rec;
        CLOSE demand;
        v_days_late := demand_rec.days_late;
        if v_days_late = 0 then
             v_days_late := ' ';
        end if;
       if v_demand is not null then
          if v_demand_id = g_end_demand_id then
             v_demand :=
                  demand_rec.qty || field_seperator ||
                  demand_rec.demand_date || field_seperator ||
                  replace_seperator(demand_rec.name) || field_seperator ||
                  demand_rec.type ||  field_seperator ||
                  replace_seperator(demand_rec.item) || field_seperator ||
                  demand_rec.priority || field_seperator ||
                  replace_seperator(demand_rec.customer) || field_seperator ||
                  replace_seperator(demand_rec.customer_site)|| field_seperator ||
                  demand_rec.satisfied_date  || field_seperator ||
                  v_pegged_qty   || field_seperator ||
                  v_days_late || field_seperator ||
                  demand_rec.qty_by_due_date || field_seperator ||
                  demand_rec.org || field_seperator ||
                  demand_rec.demand_class ||
                  record_seperator ||v_demand;
          else
             v_demand := v_demand || record_seperator ||
                  demand_rec.qty || field_seperator ||
                  demand_rec.demand_date || field_seperator ||
                  replace_seperator(demand_rec.name) || field_seperator ||
                  demand_rec.type ||  field_seperator ||
                  replace_seperator(demand_rec.item) || field_seperator ||
                  demand_rec.priority || field_seperator ||
                  replace_seperator(demand_rec.customer) || field_seperator ||
                  replace_seperator(demand_rec.customer_site)  || field_seperator ||
                  demand_rec.satisfied_date  || field_seperator ||
                  v_pegged_qty   || field_seperator ||
                  v_days_late || field_seperator ||
                  demand_rec.qty_by_due_date || field_seperator ||
                  demand_rec.org || field_seperator ||
                  demand_rec.demand_class;
           end if;
       else
          v_demand :=
                  demand_rec.qty || field_seperator ||
                  demand_rec.demand_date || field_seperator ||
                  replace_seperator(demand_rec.name) || field_seperator ||
                  demand_rec.type || field_seperator ||
                  replace_seperator(demand_rec.item) || field_seperator ||
                  demand_rec.priority || field_seperator ||
                  replace_seperator(demand_rec.customer) || field_seperator ||
                  replace_seperator(demand_rec.customer_site)  || field_seperator ||
                  demand_rec.satisfied_date  || field_seperator ||
                  v_pegged_qty  || field_seperator ||
                  v_days_late || field_seperator ||
                  demand_rec.qty_by_due_date || field_seperator ||
                  demand_rec.org || field_seperator ||
                  demand_rec.demand_class ;
       end if;
     ELSE
        OPEN other_demand;
        FETCH other_demand INTO other_demand_rec;
        CLOSE other_demand;
       if v_demand is not null then
          v_demand := v_demand || record_seperator ||
                  other_demand_rec.qty || field_seperator ||
                  other_demand_rec.demand_date || field_seperator ||
                  'null' || field_seperator ||
                  other_demand_rec.type ||  field_seperator ||
                  replace_seperator(other_demand_rec.item)|| field_seperator ||
                  '0' || field_seperator ||
                  'null' || field_seperator ||
                  'null' || field_seperator ||
                  'null' || field_seperator ||
                  v_pegged_qty || field_seperator ||
                  'null' || field_seperator ||
                  'null' || field_seperator ||
                  'null' || field_seperator ||
                  'null' ;
       else
          v_demand :=
                  other_demand_rec.qty || field_seperator ||
                  other_demand_rec.demand_date || field_seperator ||
                  'null' || field_seperator ||
                  other_demand_rec.type || field_seperator ||
                  replace_seperator(other_demand_rec.item)|| field_seperator ||
                  '0' || field_seperator ||
                  'null' || field_seperator ||
                  'null' || field_seperator ||
                  'null' || field_seperator ||
                  v_pegged_qty  || field_seperator ||
                  'null' || field_seperator ||
                  'null' || field_seperator ||
                  'null' || field_seperator ||
                  'null';
      end if;
     END IF;
    END LOOP;
    CLOSE pegging;
    v_demand :=
                  to_char(rowcount) || record_seperator || v_demand;

END fetchDemandData;

Procedure fetchRescheduleData(p_plan_id number,
                            p_instance_id number,
                            p_org_id number,
                            p_dept_id number,
                            p_res_id number,
                            p_time varchar2,
                            v_require_data OUT NOCOPY varchar2) IS

  oneRecord varchar2(32000);
  rowCount number;

  CURSOR req IS
      select to_char(
               decode(nvl(mrr.firm_flag,0),
                      NO_FIRM, mrr.start_date,
                      FIRM_RESOURCE, mrr.start_date,
                      FIRM_END,
                        mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                      FIRM_END_RES,
                        mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                      nvl(mrr.firm_start_date, mrr.start_date)),
               format_mask) start_date,
             to_char(least(g_cutoff_date,
               decode(nvl(mrr.firm_flag,0),
                      NO_FIRM, mrr.end_date,
                      FIRM_RESOURCE, mrr.end_date,
                      FIRM_START,
                        mrr.firm_start_date + (mrr.end_date - mrr.start_date),
                      FIRM_START_RES,
                        mrr.firm_start_date + (mrr.end_date - mrr.start_date),
                      nvl(mrr.firm_end_date, mrr.end_date))),
               format_mask) end_date,
             nvl(msc_get_name.job_name(mrr.supply_id, p_plan_id),
                    to_char(mrr.supply_id)) job_name,
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
         and nvl(mrr.firm_start_date,mrr.start_date) <= g_cutoff_date
         and mrr.department_id = p_dept_id
         and mrr.resource_id = p_res_id
         and to_date(p_time, format_mask)
                 BETWEEN decode(nvl(mrr.firm_flag,0),
                      NO_FIRM, mrr.start_date,
                      FIRM_RESOURCE, mrr.start_date,
                      FIRM_END,
                        mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                      FIRM_END_RES,
                        mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                      nvl(mrr.firm_start_date, mrr.start_date)) AND
                        decode(nvl(mrr.firm_flag,0),
                      NO_FIRM, mrr.end_date,
                      FIRM_RESOURCE, mrr.end_date,
                      FIRM_START,
                        mrr.firm_start_date + (mrr.end_date - mrr.start_date),
                      FIRM_START_RES,
                        mrr.firm_start_date + (mrr.end_date - mrr.start_date),
                      nvl(mrr.firm_end_date, mrr.end_date))
       order by start_date;

   l_req_data req%ROWTYPE;
BEGIN
   rowCount :=0;
   OPEN req;
   LOOP
     FETCH req INTO l_req_data;
     EXIT WHEN req%NOTFOUND;
        if oneRecord is not null then
          oneRecord := oneRecord || record_seperator ||
                 replace_seperator(l_req_data.job_name) || field_seperator ||
                          l_req_data.start_date || field_seperator ||
                          l_req_data.end_date || field_seperator ||
                          l_req_data.supply_type || field_seperator ||
                          l_req_data.assigned_units || field_seperator ||
                          l_req_data.transaction_id || field_seperator ||
                          l_req_data.sr_instance_id ;
        else
          oneRecord :=
                  replace_seperator(l_req_data.job_name) || field_seperator ||
                          l_req_data.start_date || field_seperator ||
                          l_req_data.end_date || field_seperator ||
                          l_req_data.supply_type || field_seperator ||
                          l_req_data.assigned_units || field_seperator ||
                          l_req_data.transaction_id || field_seperator ||
                          l_req_data.sr_instance_id ;
        end if;
        rowCount := rowCount+1;
   END LOOP;
   CLOSE req;

   v_require_data :=  rowCount || record_seperator ||
                            oneRecord;

END;

Procedure fetchRescheduleData(p_plan_id number,
                            p_instance_id number,
                            p_transaction_id number,
                            v_require_data OUT NOCOPY varchar2) IS

  oneRecord varchar2(32000);
  rowCount number;

  CURSOR req IS
      select to_char(
               decode(nvl(mrr.firm_flag,0),
                      NO_FIRM, mrr.start_date,
                      FIRM_RESOURCE, mrr.start_date,
                      FIRM_END,
                        mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                      FIRM_END_RES,
                        mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                      nvl(mrr.firm_start_date, mrr.start_date)),
               format_mask) start_date,
             to_char(least(g_cutoff_date,
               decode(nvl(mrr.firm_flag,0),
                      NO_FIRM, mrr.end_date,
                      FIRM_RESOURCE, mrr.end_date,
                      FIRM_START,
                        mrr.firm_start_date + (mrr.end_date - mrr.start_date),
                      FIRM_START_RES,
                        mrr.firm_start_date + (mrr.end_date - mrr.start_date),
                      nvl(mrr.firm_end_date, mrr.end_date))),
               format_mask) end_date,
             nvl(msc_get_name.job_name(mrr.supply_id, p_plan_id),
                    to_char(mrr.supply_id)) job_name,
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
         and nvl(mrr.firm_start_date,mrr.start_date) <= g_cutoff_date
       order by start_date;

   l_req_data req%ROWTYPE;

BEGIN
   rowCount :=0;
   OPEN req;
   LOOP
     FETCH req INTO l_req_data;
     EXIT WHEN req%NOTFOUND;
        if oneRecord is not null then
          oneRecord := oneRecord || record_seperator ||
                   replace_seperator(l_req_data.job_name) || field_seperator ||
                          l_req_data.start_date || field_seperator ||
                          l_req_data.end_date || field_seperator ||
                          l_req_data.supply_type || field_seperator ||
                          l_req_data.assigned_units || field_seperator ||
                          l_req_data.transaction_id || field_seperator ||
                          l_req_data.sr_instance_id ;
        else
          oneRecord :=
                   replace_seperator(l_req_data.job_name) || field_seperator ||
                          l_req_data.start_date || field_seperator ||
                          l_req_data.end_date || field_seperator ||
                          l_req_data.supply_type || field_seperator ||
                          l_req_data.assigned_units || field_seperator ||
                          l_req_data.transaction_id || field_seperator ||
                          l_req_data.sr_instance_id ;
        end if;
        rowCount := rowCount+1;
   END LOOP;
   CLOSE req;

   v_require_data :=  rowCount || record_seperator ||
                            oneRecord;

END;

Procedure fetchAllResource(p_plan_id number,
                           p_where varchar2,
                                   v_name OUT NOCOPY varchar2) IS
  oneRecord varchar2(32000);
  rowCount number:=0;

    TYPE char_arr IS TABLE OF varchar2(100);
   v_dept_code char_arr;
   v_org number_arr;
   v_instance number_arr;
   v_dept number_arr;
   v_res number_arr;

BEGIN
    oneRecord := null;
    rowCount := 0;
        select distinct
           mtp.organization_code||':'||
           mdr.department_code||':'||
           mdr.resource_code,
           mdr.organization_id,
           mdr.sr_instance_id,
           mdr.department_id,
           mdr.resource_id
       bulk collect into
           v_dept_code,
                     v_org, v_instance, v_dept, v_res
                       FROM msc_department_resources mdr,
                            msc_trading_partners mtp,
                            msc_form_query mfq
                      WHERE mdr.plan_id = p_plan_id
                        AND mdr.organization_id = mfq.number2
                        AND mdr.sr_instance_id = mfq.number1
                        AND mdr.department_id = mfq.number3
                        AND mdr.resource_id = mfq.number4
                        AND mfq.query_id = g_res_query_id
                        AND mtp.partner_type = 3
                        AND mdr.organization_id = mtp.sr_tp_id
                        AND mdr.sr_instance_id = mtp.sr_instance_id
                        AND mdr.aggregate_resource_flag =2
                        ORDER BY 1,2,3 ;
     for a in 1..v_dept_code.count loop
          v_dept_code(a) := replace_seperator(v_dept_code(a));
          oneRecord := oneRecord || record_seperator ||
                          v_dept_code(a) || field_seperator ||
                          v_org(a) || field_seperator ||
                          v_instance(a) || field_seperator ||
                          v_dept(a) || field_seperator ||
                          v_res(a);
    end loop;

     rowCount := v_dept_code.count;

     v_name := rowCount || oneRecord;
END;

Function get_MTQ_time(p_transaction_id number,
                           p_plan_id number,
                           p_instance_id number) return number IS
l_mtq number;
l_cumm_quan number;
l_order_quan number;
Begin
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
exception when no_data_found then
   return 1;
End;

Procedure ValidateTime(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             p_start varchar2,
                             p_end varchar2,
                             p_return_status OUT NOCOPY varchar2,
                             p_out OUT NOCOPY varchar2) IS

 Cursor curr_res IS
  SELECT mrr.operation_seq_num,
         nvl(mrr.schedule_flag, 0) schedule_flag,
         decode(ms.order_type, 27,
                 1, ms.firm_planned_type) firm_planned_type,
         sysdate theDate,
         get_MTQ_time(p_transaction_id, p_plan_id, p_instance_id) mtq_time
    FROM msc_resource_requirements mrr,
         msc_supplies ms
   WHERE mrr.plan_id = p_plan_id
     and mrr.transaction_id = p_transaction_id
     and mrr.sr_instance_id = p_instance_id
     and ms.plan_id = mrr.plan_id
     and ms.transaction_id = mrr.supply_id
     and ms.sr_instance_id = mrr.sr_instance_id;

 Cursor lower_bound IS
  SELECT mrr2.operation_seq_num, mrr2.resource_seq_num, mrr2.transaction_id,
         nvl(mrr2.schedule_flag, 0) schedule_flag,
         decode(nvl(mrr2.firm_flag,0),
             NO_FIRM, mrr2.start_date,
             FIRM_RESOURCE, mrr2.start_date,
             FIRM_END,
               mrr2.firm_end_date - (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24)
                                      - mrr2.start_date),
             FIRM_END_RES,
               mrr2.firm_end_date - (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24)
                                      - mrr2.start_date),
             nvl(mrr2.firm_start_date, mrr2.start_date)) start_date,
         decode(nvl(mrr2.firm_flag,0),
             NO_FIRM, nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24),
             FIRM_RESOURCE, nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24),
             FIRM_START,
                mrr2.firm_start_date + (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24)
                                        - mrr2.start_date),
             FIRM_START_RES,
                mrr2.firm_start_date + (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24)
                                        - mrr2.start_date),
             nvl(nvl(mrr2.firm_end_date, mrr2.end_date),  mrr2.start_date+mrr2.resource_hours/24)) end_date,
         get_MTQ_time(mrr2.transaction_id, p_plan_id, p_instance_id) mtq_time
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
           or ( nvl(mr.cfm_routing_flag,2) = 3 and mrr2.operation_sequence_id in (
                                       select mon.from_op_seq_id from msc_operation_networks mon
                                       where mon.plan_id = mrr1.plan_id
                                         and mon.sr_instance_id = mrr1.sr_instance_id
                                         and mon.routing_sequence_id = mrr1.routing_sequence_id
                                         and mon.to_op_seq_id = mrr1.operation_sequence_id
          ))) or
          (mrr2.operation_seq_num = mrr1.operation_seq_num and
           mrr2.resource_seq_num < mrr1.resource_seq_num))
     and (mrr2.firm_start_date is not null or
         mrr2.firm_end_date is not null )
     and mrr2.firm_flag in (FIRM_START,FIRM_END,FIRM_START_END,FIRM_START_RES,
              FIRM_END_RES,FIRM_ALL)
   order by mrr2.operation_seq_num desc, mrr2.resource_seq_num desc;

 Cursor upper_bound IS
  SELECT mrr2.operation_seq_num, mrr2.resource_seq_num,mrr2.transaction_id,
         nvl(mrr2.schedule_flag, 0) schedule_flag,
         decode(nvl(mrr2.firm_flag,0),
           NO_FIRM, mrr2.start_date,
           FIRM_RESOURCE, mrr2.start_date,
           FIRM_END,
             mrr2.firm_end_date - (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24)
                                   - mrr2.start_date),
           FIRM_END_RES,
             mrr2.firm_end_date - (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24)
                                   - mrr2.start_date),
           nvl(mrr2.firm_start_date, mrr2.start_date)) start_date,
         decode(nvl(mrr2.firm_flag,0),
           NO_FIRM, nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24),
           FIRM_RESOURCE, nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24),
           FIRM_START,
              mrr2.firm_start_date + (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24)
                                        - mrr2.start_date),
           FIRM_START_RES,
              mrr2.firm_start_date + (nvl(mrr2.end_date, mrr2.start_date+mrr2.resource_hours/24)
                                        - mrr2.start_date),
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

   current_rec curr_res%ROWTYPE;
   lower_rec lower_bound%ROWTYPE;
   upper_rec upper_bound%ROWTYPE;
   v_lower_start date;
   v_upper_start Date;
   v_lower_start_id number;
   v_upper_start_id number;
   v_lower_end date;
   v_upper_end date;
   v_lower_end_id number;
   v_upper_end_id number;
   v_prev_op number;
   v_next_op number;
   v_lower_mtq_id number;
   v_upper_mtq_id number;
Begin

  IF to_date(p_end, format_mask) > g_last_date THEN
     p_return_status := 'ERROR';
     p_out := 'null'||field_seperator ||
              to_char(g_last_date,format_mask)||field_seperator||
              'null';
     return;
  END IF;

  OPEN curr_res;
  FETCH curr_res INTO current_rec;
  CLOSE curr_res;

  IF current_rec.firm_planned_type = 1 THEN
     p_return_status := 'ERROR';
     p_out := 'FIRM_SUPPLY';
     return;
  END IF;

  IF to_date(p_start, format_mask) < current_rec.theDate THEN
     p_return_status := 'ERROR';
     p_out := to_char(current_rec.theDate,format_mask)
                      || field_seperator ||'null'||field_seperator||'null' ;
     return;
  END IF;

  OPEN lower_bound;
  LOOP
        FETCH lower_bound INTO lower_rec;
        EXIT WHEN lower_bound%NOTFOUND;
        IF v_lower_start is not null and v_lower_end is not null THEN
           EXIT;
        ELSE
           IF v_prev_op is null and
              lower_rec.operation_seq_num < current_rec.operation_seq_num THEN
                 v_prev_op := lower_rec.operation_seq_num;
           END IF;
           IF v_lower_start is null then
                 v_lower_start := lower_rec.start_date;
                 v_lower_start_id := lower_rec.transaction_id;
           END IF;
           IF v_lower_end is null then
                 v_lower_end := lower_rec.end_date;
                 v_lower_end_id := lower_rec.transaction_id;
           END IF;
           IF v_lower_MTQ_id is null then
              IF not (v_prev_op is not null and
                 lower_rec.operation_seq_num = v_prev_op and
                 current_rec.schedule_flag = 3 and  -- prior
                 lower_rec.schedule_flag = 4) then
                 IF to_date(p_start,format_mask) < lower_rec.start_date + lower_rec.mtq_time*(
                                     lower_rec.end_date - lower_rec.start_date) then
                    v_lower_mtq_id := lower_rec.transaction_id;
                 END IF;
              END IF;
           END IF;
        END IF;
  END LOOP;
  CLOSE lower_bound;

  OPEN upper_bound;
  LOOP
        FETCH upper_bound INTO upper_rec;
        EXIT WHEN upper_bound%NOTFOUND;
        IF v_upper_start is not null and v_upper_end is not null THEN
           EXIT;
        ELSE
           IF v_next_op is null and
              upper_rec.operation_seq_num > current_rec.operation_seq_num THEN
                 v_next_op := upper_rec.operation_seq_num;
           END IF;
           IF v_upper_start is null then
                       v_upper_start := upper_rec.start_date;
                       v_upper_start_id := upper_rec.transaction_id;
           END IF;
           IF v_upper_end is null then
                 v_upper_end := upper_rec.end_date;
                 v_upper_end_id := upper_rec.transaction_id;
           END IF;
           IF v_upper_MTQ_id is null then
              IF not (v_next_op is not null and
                 upper_rec.operation_seq_num = v_next_op and
                 current_rec.schedule_flag = 4 and  --next
                 upper_rec.schedule_flag = 3) then
                 IF upper_rec.start_date < to_date(p_start, format_mask) + current_rec.mtq_time*
                                  (to_date(p_end, format_mask) - to_date(p_start, format_mask)) then
                    v_upper_mtq_id := upper_rec.transaction_id;
                 END IF;
              END IF;
           END IF;
        END IF;
  END LOOP;
  CLOSE upper_bound;

  p_return_status := 'OK';
  if v_lower_start is not null and to_date(p_start, format_mask) < v_lower_start then
     p_out := to_char(v_lower_start,format_mask) || field_seperator
                 || to_char(v_lower_start_id);
     p_return_status := 'ERROR';
  else
     p_out := 'null' || field_seperator || 'null';
  end if;

  if v_upper_start is not null and to_date(p_start, format_mask) > v_upper_start then
     p_out := p_out || field_seperator
              || to_char(v_upper_start,format_mask) || field_seperator
              || to_char(v_upper_start_id);
     p_return_status := 'ERROR';
  else
     p_out := p_out || field_seperator || 'null' || field_seperator || 'null';
  end if;

  if p_return_status = 'ERROR' then
     p_out := p_out || field_seperator || 'null' || field_seperator || 'null';
     p_out := p_out || field_seperator || 'null' || field_seperator || 'null';
     return;
  end if;

  if v_lower_end is not null and to_date(p_end, format_mask) < v_lower_end then
     p_out := p_out || field_seperator
              || to_char(v_lower_end,format_mask)|| field_seperator
              || to_char(v_lower_end_id);
     p_return_status := 'ERROR';
  else
     p_out := p_out || field_seperator || 'null' || field_seperator || 'null';
  end if;

  if v_upper_end is not null and to_date(p_end, Format_mask) > v_upper_end then
     p_out := p_out || field_seperator
              || to_char(v_upper_end,format_mask)|| field_seperator
              || to_char(v_upper_end_id);
     p_return_status := 'ERROR';
  else
     p_out := p_out || field_seperator|| 'null' || field_seperator || 'null';
  end if;

  if p_return_status = 'ERROR' then
     return;
  end if;

  if v_lower_mtq_id is not null or v_upper_mtq_id is not null then
     p_return_status := 'WARNING';
     p_out := nvl(to_char(v_lower_mtq_id), 'null') ||field_seperator
              || nvl(to_char(v_upper_mtq_id), 'null');
     return;
  end if;
END;

FUNCTION IsTimeFenceCrossed(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             p_start varchar2)
RETURN varchar2 IS
  l_timefence_date DATE;
  l_prev_start_date DATE;
BEGIN
  select decode(nvl(mrr.firm_flag,0),
                NO_FIRM, mrr.start_date,
                FIRM_RESOURCE, mrr.start_date,
                FIRM_END,
                   mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                FIRM_END_RES,
                   mrr.firm_end_date - (mrr.end_date - mrr.start_date),
                nvl(mrr.firm_start_date, mrr.start_date)),
         msi.PLANNING_TIME_FENCE_DATE
  into l_prev_start_date, l_timefence_date
  from msc_system_items msi,
       msc_resource_requirements mrr,
       msc_supplies ms
  where mrr.plan_id = p_plan_id
      and mrr.transaction_id = p_transaction_id
      and mrr.sr_instance_id = p_instance_id
      AND ms.plan_id = mrr.plan_id
      AND ms.transaction_id = mrr.supply_id
      AND ms.sr_instance_id = mrr.sr_instance_id
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id;

  if (l_timefence_date < l_prev_start_date and
     to_date(p_start, format_mask) < l_timefence_date) or
     (to_date(p_start, format_mask) > l_timefence_date and
     l_timefence_date > l_prev_start_date) then
     return 'Y';
  else
     return 'N';
  end if;
END IsTimeFenceCrossed;

Procedure ValidateAndMove(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             p_start varchar2,
                             p_end varchar2,
                             p_return_status OUT NOCOPY varchar2,
                             p_out OUT NOCOPY varchar2,
                             p_out2 OUT NOCOPY boolean) IS
   CURSOR simu IS
    SELECT mrr2.transaction_id, mrr2.sr_instance_id
     FROM msc_resource_requirements mrr1,
          msc_resource_requirements mrr2
    WHERE mrr1.plan_id = p_plan_id
         and mrr1.transaction_id = p_transaction_id
         and mrr1.sr_instance_id = p_instance_id
         and mrr2.plan_id = mrr1.plan_id
         and mrr2.sr_instance_id = mrr1.sr_instance_id
         and mrr2.supply_id = mrr1.supply_id
         and mrr2.operation_seq_num = mrr1.operation_seq_num
         and mrr2.resource_seq_num = mrr1.resource_seq_num
         and mrr2.alternate_num = mrr1.alternate_num
         and mrr2.transaction_id <> mrr1.transaction_id
	 and mrr2.parent_id = 2;
 row_count number;
 v_transaction_id number;
 v_instance_id number;
 p_saved_status varchar(20);
 p_saved_out varchar(400);
Begin
  p_out2 :=false;
  if (to_date(p_end,format_mask) <= to_date(p_start, format_mask)) then
     p_return_status := 'ERROR';
     p_out := 'END_BEFORE_START';
     return;
  end if;
  validateTime(p_plan_id, p_transaction_id,
               p_instance_id, p_start, p_end,
               p_return_status, p_out);
  if p_return_status = 'ERROR' then
     return;
  else
    if p_return_status = 'WARNING' then
       p_saved_status := p_return_status;
       p_saved_out := p_out;
    end if;
    moveResource(p_plan_id, p_transaction_id, p_instance_id,
                 p_start, p_end, p_return_status, p_out);
    if p_return_status = 'ERROR' then
       return;
    else
      if not p_out2 then
         if usingBatchableRes(p_plan_id, p_transaction_id, p_instance_id) then
            p_out2 := true;
         end if;
      end if;
      --update the simultaneous resources
      row_count :=0;
      OPEN simu;
      LOOP
        FETCH simu INTO v_transaction_id, v_instance_id;
        EXIT WHEN simu%NOTFOUND;
        row_count := row_count+1;
        moveResource(p_plan_id, v_transaction_id, v_instance_id,
                 p_start, p_end, p_return_status, p_out);
        if p_return_status = 'ERROR' then
           CLOSE simu;
           return;
        END IF;
        if not p_out2 then
           if usingBatchableRes(p_plan_id, v_transaction_id, v_instance_id) then
              p_out2 := true;
           end if;
        end if;
      END LOOP;
      CLOSE simu;

      if row_count > 0 then
        if p_saved_status = 'WARNING' then
           p_return_status := 'WITH_ST_RES_WITH_WARN';
           p_out := p_saved_out;
        else
           p_return_status := 'WITH_ST_RES';
        end if;
      else
        if p_saved_status = 'WARNING' then
           p_return_status := 'NO_ST_RES_WITH_WARN';
           p_out := p_saved_out;
        else
           p_return_status := 'NO_ST_RES';
        end if;
      end if;
    end if;
  end if;
END;

Function usingBatchableRes(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number) return boolean is
  v_flag number :=2;
Begin
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
     AND mdr.resource_id = mrr.resource_id
     ;
  if v_flag = 2 then
     return false;
  else
     return true;
  end if;
End;

Procedure MoveResource(p_plan_id number,
                             p_transaction_id number,
                             p_instance_id number,
                             p_start varchar2,
                             p_end varchar2,
                             p_return_status OUT NOCOPY varchar2,
                             p_out OUT NOCOPY varchar2) IS
   l_firm_flag number;
   l_firm_start date;
   l_firm_end date;
   l_start date;
   l_end date;
   l_res_id number;
   l_alt_num number;
   l_supply_id number;
BEGIN
      begin

          select mrr.firm_flag,mrr.firm_start_date, mrr.firm_end_date,
                 mrr.resource_id, mrr.alternate_num,
                 mrr.start_date, mrr.end_date, mrr.supply_id
            into l_firm_flag, l_firm_start, l_firm_end,
                 l_res_id, l_alt_num,
                 l_start, l_end, l_supply_id
            FROM msc_resource_requirements mrr
            WHERE mrr.plan_id = p_plan_id
              and mrr.transaction_id = p_transaction_id
              and mrr.sr_instance_id = p_instance_id
              for update of mrr.firm_flag nowait;
      exception when app_exception.record_lock_exception then
          p_return_status := 'ERROR';
          p_out := 'RECORD_LOCK';
          return;
      end;
      if (l_end-l_start) =
           (to_date(p_end, format_mask)-to_date(p_start,format_mask)) then
       if l_firm_flag in (NO_FIRM, FIRM_START) or l_firm_flag is null THEN
          l_firm_flag := FIRM_START;
       elsif l_firm_flag in (FIRM_END, FIRM_START_END) THEN
          l_firm_flag := FIRM_START_END;
       elsif l_firm_flag in (FIRM_RESOURCE, FIRM_START_RES) THEN
          l_firm_flag := FIRM_START_RES;
       elsif l_firm_flag in (FIRM_END_RES,FIRM_ALL) THEN
          l_firm_flag := FIRM_ALL;
       else
          l_firm_flag := FIRM_START;
       end if;
      else
       if l_firm_flag in
          (FIRM_RESOURCE,FIRM_START_RES,FIRM_END_RES,FIRM_ALL) THEN
          l_firm_flag := FIRM_ALL;
       else
          l_firm_flag := FIRM_START_END;
       end if;
      end if;

       if l_firm_flag in (NO_FIRM, FIRM_START,
                          FIRM_RESOURCE,FIRM_START_RES) THEN
          l_firm_end := to_date(null);
       else
          l_firm_end := to_date(p_end, format_mask);
       end if;
       l_firm_start := to_date(p_start, format_mask);

       --undo_change(p_plan_id, p_transaction_id, p_instance_id,
       --            l_firm_flag, l_firm_start, l_firm_end,
       --            l_res_id, l_alt_num);
      -- update data now
        update msc_resource_requirements
          set status =0,
              applied=2,
              firm_flag = l_firm_flag,
              firm_start_date =l_firm_start,
              firm_end_date =l_firm_end
        where plan_id = p_plan_id
         and transaction_id = p_transaction_id
         and sr_instance_id = p_instance_id;

       update msc_supplies
          set status =0,
              applied=2
       where plan_id = p_plan_id
         and transaction_id = l_supply_id;

     p_return_status := 'OK';
END;

Function get_start_date(p_plan_id number,
                           p_transaction_id number,
                           p_instance_id number)
return date IS
   Cursor activity_cur IS
    select decode(nvl( firm_flag,0),
                      NO_FIRM,  start_date,
                      FIRM_RESOURCE,  start_date,
                      FIRM_END,
                         firm_end_date - ( end_date -  start_date),
                      FIRM_END_RES,
                         firm_end_date - ( end_date -  start_date),
                      nvl(firm_start_date, start_date))
     from msc_resource_requirements
     where plan_id = p_plan_id
      and transaction_id = p_transaction_id
      and sr_instance_id = p_instance_id;
   v_temp date;
Begin
    OPEN activity_cur;
    FETCH activity_cur INTO v_temp;
    CLOSE activity_cur;
    return v_temp;
End get_start_date;

Function get_end_date(p_plan_id number,
                           p_transaction_id number,
                           p_instance_id number)
return date IS
   Cursor activity_cur IS
    select decode(nvl( firm_flag,0),
                      NO_FIRM,  end_date,
                      FIRM_RESOURCE,  end_date,
                      FIRM_START,
                          firm_start_date + ( end_date -  start_date),
                      FIRM_START_RES,
                          firm_start_date + ( end_date -  start_date),
                      nvl(firm_end_date, end_date))
     from msc_resource_requirements
     where plan_id = p_plan_id
      and transaction_id = p_transaction_id
      and sr_instance_id = p_instance_id;
   v_temp date;
Begin
    OPEN activity_cur;
    FETCH activity_cur INTO v_temp;
    CLOSE activity_cur;
    return v_temp;
End get_end_date;

Procedure findRequest(p_plan_id number,
                           p_where varchar2,
                           v_resource_list OUT NOCOPY varchar2,
                           v_supply_list OUT NOCOPY varchar2) IS
   TYPE GanttCurTyp IS REF CURSOR;
   resource_cursor GanttCurTyp;
   sql_statement varchar2(32000);
   l_dept number;
   l_res number;
   l_org number;
   l_instance number;
   l_supply number;
   l_transaction number;
   exc_where_stat varchar2(32000);
   where_stat varchar2(32000);

   CURSOR dept IS
     select distinct number1, number2, number3, number4
       from msc_form_query
      where query_id =g_find_query_id;

   CURSOR supply IS
     select distinct number1, number5
       from msc_form_query
      where query_id =g_find_query_id;

   v_one_record varchar2(200);
   v_len number;

BEGIN
    where_stat := ' SELECT sr_instance_id, ' ||
                            ' organization_id, '||
                            ' department_id, '||
                            ' resource_id, '||
                            ' transaction_id, ' ||
                            ' r_transaction_id ' ||
                    ' FROM (select mrr.sr_instance_id, '||
                                ' mrr.organization_id, ' ||
                                ' mtp.partner_id, ' ||
                                ' mrr.department_id, '||
                                ' mrr.resource_id, '||
                                ' mrr.transaction_id r_transaction_id, ' ||
                                ' mrr.supply_id transaction_id, ' ||
                                ' ms.inventory_item_id, ' ||
                                ' decode(sign(ms.new_schedule_date '||
                                '- (ms.need_by_date+1)),1,1,2) late_order, '||
                                ' msc_get_gantt_data.get_start_date( ' ||
                                'mrr.plan_id, mrr.transaction_id, ' ||
                                ' mrr.sr_instance_id) start_date, '||
                                ' msc_get_gantt_data.get_end_date( ' ||
                                'mrr.plan_id, mrr.transaction_id, ' ||
                                ' mrr.sr_instance_id) end_date '||
                      ' FROM msc_resource_requirements mrr, ' ||
                           ' msc_supplies ms, ' ||
                           ' msc_trading_partners mtp ' ||
                     ' WHERE ms.plan_id = :1 '||
                       ' and mrr.plan_id = ms.plan_id ' ||
                       ' and mrr.supply_id = ms.transaction_id ' ||
                       ' and mrr.sr_instance_id = ms.sr_instance_id ' ||
                       ' and mrr.organization_id = ms.organization_id ' ||
                       ' and mrr.organization_id = mtp.sr_tp_id ' ||
                       ' and mrr.sr_instance_id = mtp.sr_instance_id ' ||
                       ' and mrr.end_date is not null '||
                       ' and mtp.partner_type = 3 ' ||
          ' and nvl(mrr.parent_id,2) =2) ';

     exc_where_stat := ' SELECT sr_instance_id, ' ||
                            ' organization_id, '||
                            ' department_id, '||
                            ' resource_id, '||
                            ' transaction_id, ' ||
                            ' r_transaction_id ' ||
                         ' FROM (select mrr.sr_instance_id, '||
                                ' mrr.organization_id, ' ||
                                ' mtp.partner_id, ' ||
                                ' med.exception_type, ' ||
                                ' mrr.department_id, '||
                                ' mrr.resource_id, '||
                                ' mrr.transaction_id r_transaction_id, ' ||
                                ' mrr.supply_id transaction_id, ' ||
                                ' ms.inventory_item_id, ' ||
                                ' msc_get_gantt_data.get_start_date( ' ||
                                'mrr.plan_id, mrr.transaction_id, ' ||
                                ' mrr.sr_instance_id) start_date, '||
                                ' msc_get_gantt_data.get_end_date( ' ||
                                'mrr.plan_id, mrr.transaction_id, ' ||
                                ' mrr.sr_instance_id) end_date '||
                              ' FROM msc_resource_requirements mrr, ' ||
                           ' msc_supplies ms, ' ||
                           ' msc_trading_partners mtp, ' ||
                           ' msc_exception_details med ' ||
                     ' WHERE ms.plan_id = :1 '||
                       ' and mrr.plan_id = ms.plan_id ' ||
                       ' and mrr.supply_id = ms.transaction_id ' ||
                       ' and mrr.sr_instance_id = ms.sr_instance_id ' ||
                       ' and mrr.organization_id = ms.organization_id ' ||
                       ' and mrr.organization_id = mtp.sr_tp_id ' ||
                       ' and mrr.sr_instance_id = mtp.sr_instance_id ' ||
                       ' and mtp.partner_type = 3 ' ||
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
          ' and mrr.end_date is not null '||
          ' and nvl(mrr.parent_id,2) =2 )';

   if p_where is not null then
      if inStr(p_where, 'EXCEPTION_TYPE') <> 0 then
         sql_statement := exc_where_stat || ' where 1=1 '||p_where;
      else
         sql_statement := where_stat || ' where 1=1 '||p_where;
      end if;
   else
      sql_statement := where_stat;
   end if;

   if g_find_query_id is not null then
      delete msc_form_query
      where query_id = g_find_query_id;
   else
      select msc_form_query_s.nextval
       into g_find_query_id
        from dual;
   end if;
   OPEN resource_cursor FOR sql_statement
                        USING p_plan_id;

   LOOP
     FETCH resource_cursor INTO l_instance, l_org, l_dept, l_res,
                                l_supply, l_transaction;
     EXIT WHEN resource_cursor%NOTFOUND;

                insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,
                        NUMBER2,
                        NUMBER3,
                        NUMBER4,
                        NUMBER5,
                        NUMBER6)
                values (
                        g_find_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                         l_instance,
                         l_org,
                         l_dept,
                         l_res,
                         l_supply,
                         l_transaction);

   END LOOP;
   CLOSE resource_cursor;

   OPEN dept;
   LOOP
     FETCH dept INTO l_instance, l_org, l_dept, l_res;
     EXIT WHEN dept%NOTFOUND;
     v_one_record :=
          '('||l_instance ||','||l_org ||','||l_dept||','||l_res||')';
     v_len := nvl(length(v_resource_list),0) + nvl(length(v_one_record),0);
     if v_resource_list is null then
        v_resource_list := v_one_record;
     else
        if  v_len < 31000 then
          v_resource_list := v_resource_list ||','||v_one_record;
        else
          exit;
        end if;
     end if;
   END LOOP;
   CLOSE dept;

   OPEN supply;
      LOOP
     FETCH supply INTO l_instance, l_supply;
     EXIT WHEN supply%NOTFOUND;
     v_one_record :=   '('||l_instance ||','||l_supply ||')';
     v_len := nvl(length(v_supply_list),0) + nvl(length(v_one_record),0);
     if v_supply_list is null then
        v_supply_list := v_one_record;
     else
        if  v_len < 31000 then
          v_supply_list := v_supply_list ||','||v_one_record;
        else
          exit;
        end if;
     end if;
   END LOOP;
   CLOSE supply;

END findRequest;

FUNCTION constructSupplyRequest(p_from_block varchar2,
                           p_plan_id number,
                           p_where varchar2)
                           RETURN varchar2 IS
   TYPE GanttCurTyp IS REF CURSOR;
   the_cursor GanttCurTyp;
   l_instance number;
   l_supply number;
   l_exp_id number;
   sql_stat varchar2(32000);
   p_request varchar2(32000);
   l_char varchar2(32000);
   v_one_record varchar2(200);
   v_len number;
BEGIN
   if g_plan_id is null OR p_plan_id <> g_plan_id then
     l_char := get_plan_time(p_plan_id);
   end if;

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

         sql_stat :=
                     'SELECT mrr.sr_instance_id, '||
                           ' mrr.transaction_id '||
--                           ' med.exception_detail_id '||
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
--                    ' med.exception_detail_id '||
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

   OPEN the_cursor FOR sql_stat;
   LOOP
     FETCH the_cursor INTO l_instance, l_supply;
     EXIT WHEN the_cursor%NOTFOUND;
     v_one_record := '('||l_instance ||','||l_supply ||')';
     v_len := nvl(length(p_request),0) + nvl(length(v_one_record),0);
     if p_request is null then
        p_request := v_one_record;
     else
        if  v_len < 31000 then
           p_request := p_request ||','|| v_one_record;
        else
          exit;
        end if;
     end if;
   END LOOP;
   CLOSE the_cursor;
   return p_request;

END constructSupplyRequest;

FUNCTION constructResourceRequest(p_from_block varchar2,
                           p_plan_id number,
                           p_where varchar2) RETURN varchar2 IS
   TYPE GanttCurTyp IS REF CURSOR;
   the_cursor GanttCurTyp;
   l_dept number;
   l_res number;
   l_org number;
   l_instance number;
   sql_stat varchar2(32000);
   p_request varchar2(32000);
   l_char varchar2(2000);
   v_one_record varchar2(200);
   v_len number;
BEGIN
   if g_plan_id is null OR p_plan_id <> g_plan_id then
      l_char := get_plan_time(p_plan_id);
   end if;

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

   OPEN the_cursor FOR sql_stat USING p_plan_id, g_cutoff_date;
   LOOP
     FETCH the_cursor INTO l_instance, l_org, l_dept, l_res;
     EXIT WHEN the_cursor%NOTFOUND;
     v_one_record :=
        '('||l_instance ||','||l_org ||','||l_dept||','||l_res||')';
     v_len := nvl(length(p_request),0) + nvl(length(v_one_record),0);
     if p_request is null then
        p_request := v_one_record;
     else
        if  v_len < 31000 then
          p_request := p_request ||','|| v_one_record;
        else
          exit;
        end if;
     end if;
   END LOOP;
   CLOSE the_cursor;
   return p_request;

END constructResourceRequest;

FUNCTION constructRequest(p_type varchar2,
                           p_plan_id number,
                           p_where varchar2,
                           p_from_block varchar2) RETURN varchar2 IS
  p_request varchar2(32000);

  cursor supply_rec is
    select number2, number1
      from msc_form_query
     where query_id = g_supply_query_id;

  cursor res_rec is
    select distinct number1, number2,number3, number4
      from msc_form_query
     where query_id = g_res_query_id;

   l_dept number;
   l_res number;
   l_org number;
   l_instance number;
   l_supply number;
   v_one_record varchar2(200);
   v_len number;

BEGIN

 if p_from_block in ('LATE_DEMAND','ORDER') then
       if p_type = 'RESOURCE' then
          OPEN res_rec;
          LOOP
            FETCH res_rec into l_instance, l_org, l_dept, l_res;
            EXIT WHEN res_rec%NOTFOUND;
            v_one_record :=
               '('||l_instance ||','||l_org ||','||l_dept||','||l_res||')';
            v_len := nvl(length(p_request),0) + nvl(length(v_one_record),0);
            if p_request is null then
               p_request := v_one_record;
            else
               if  v_len < 31000 then
                   p_request := p_request ||','|| v_one_record;
               else
                   exit;
               end if;
            end if;
          END LOOP;
          CLOSE res_rec;
      else -- order centric view
          OPEN supply_rec;
          LOOP
            FETCH supply_rec into l_instance, l_supply;
            EXIT WHEN supply_rec%NOTFOUND;
            v_one_record :=  '('||l_instance ||','||l_supply ||')';
            v_len := nvl(length(p_request),0) + nvl(length(v_one_record),0);
            if p_request is null then
               p_request := v_one_record;
            else
               if  v_len < 31000 then
                   p_request := p_request ||','|| v_one_record;
               else
                   exit;
               end if;
            end if;
          END LOOP;
          CLOSE supply_rec;
       end if;
  else -- not from late demand and order view
    if p_type = 'RESOURCE' then
       p_request := constructResourceRequest(p_from_block,p_plan_id, p_where);
    else
       p_request := constructSupplyRequest(p_from_block,p_plan_id, p_where);
    end if;
  end if;
  return p_request;
END constructRequest;

Function print_one_record(i number) Return varchar2 IS
 temp varchar2(2000);
 v_critical_flag number;
Begin
   peg_data.name(i) := replace_seperator(peg_data.name(i));
   temp := peg_data.path(i)|| field_seperator ||
           peg_data.type(i) || field_seperator ||
           peg_data.transaction_id(i) ||field_seperator ||
           peg_data.name(i) ||field_seperator ||
           peg_data.instance_id(i) ||field_seperator ||
           peg_data.org_id(i);
   if peg_data.type(i) in (RES_NODE, END_JOB_NODE) then
     temp := temp ||field_seperator||peg_data.start_date(i)||
                    field_seperator||peg_data.end_date(i);
     if peg_data.type(i) = RES_NODE then
       temp := temp || field_seperator || peg_data.department_id(i)
                    || field_seperator || peg_data.status(i)
                    || field_seperator || peg_data.applied(i)
                    || field_seperator || peg_data.res_firm_flag(i)
                    || field_seperator || peg_data.late_flag(i);
     else
       temp := temp || field_seperator || peg_data.firm_flag(i);
     end if;
   elsif peg_data.type(i) in (JOB_NODE, PREV_NODE) then
      temp := temp ||field_seperator||peg_data.late_flag(i);
   end if;


      if peg_data.type(i) in (END_DEMAND_NODE,JOB_NODE) then
         temp := temp ||field_seperator||peg_data.start_date(i)||
                    field_seperator||peg_data.end_date(i);
      end if;

   if g_end_demand_id is not null then
      if peg_data.type(i) in (RES_NODE, JOB_NODE) then
         if peg_data.critical_flag(i) >=0 then
            v_critical_flag := 1;
         else
            v_critical_flag := 0;
         end if;
         temp := temp ||field_seperator||peg_data.u_early_start_date(i)
                      ||field_seperator||peg_data.u_early_end_date(i)
                      ||field_seperator||peg_data.latest_start_date(i)
                      ||field_seperator||peg_data.latest_end_date(i)
                      ||field_seperator||peg_data.min_start_date(i)
                      ||field_seperator||v_critical_flag
                      ||field_seperator||peg_data.early_start_date(i)
                      ||field_seperator||peg_data.early_end_date(i);
      end if;
   end if;

      if peg_data.type(i) = JOB_NODE then
         temp := temp ||field_seperator||peg_data.supply_type(i);
      end if;

   return temp;
End print_one_record;

Function get_plan_time (p_plan_id number) return varchar2 IS
   Cursor cutoff_date_cur IS
     select curr_cutoff_date +1, curr_cutoff_date +2
     from msc_plans
     where plan_id = p_plan_id;

  CURSOR daylevel_date_cur IS
  select min(mpb.bkt_start_date), max(mpb.bkt_end_date)
    from msc_plan_buckets mpb,
         msc_plans mp
    where mp.plan_id =p_plan_id
    and mpb.plan_id = mp.plan_id
    and mpb.organization_id = mp.organization_id
    and mpb.sr_instance_id = mp.sr_instance_id
    and mpb.bucket_type =1;

   TYPE date_arr IS TABLE OF date;
   v_date date_arr;
   v_period varchar2(32000);
   p_bkt_type number;
   v_buckets varchar2(3200);
   v_min_day number;
   v_hour_day number;
   v_date_day number;
   v_bkt_date date;
   p_gantt_end_date date;

  cursor bkt_cur is
  select max(mpb.bkt_end_date)
    from msc_plan_buckets mpb,
         msc_plans mp
    where mp.plan_id =p_plan_id
    and mpb.plan_id = mp.plan_id
    and mpb.organization_id = mp.organization_id
    and mpb.sr_instance_id = mp.sr_instance_id
    and mpb.bucket_type =p_bkt_type
    ;

Begin

   -- reset find query id
    g_find_query_id := null;

    g_plan_id := p_plan_id;

   OPEN daylevel_date_cur;
   FETCH daylevel_date_cur INTO g_first_date, g_last_date;
   CLOSE daylevel_date_cur;

   OPEN cutoff_date_cur;
   FETCH cutoff_date_cur INTO g_cutoff_date, p_gantt_end_date;
   CLOSE cutoff_date_cur;

   -- fetch period start date
   SELECT greatest(mpsd.period_start_date, mp.data_start_date)
     BULK COLLECT INTO v_date
     FROM   msc_trading_partners tp,
            msc_period_start_dates mpsd,
            msc_plans mp
     WHERE  mpsd.calendar_code = tp.calendar_code
     and mpsd.sr_instance_id = tp.sr_instance_id
     and mpsd.exception_set_id = tp.calendar_exception_set_id
     and tp.sr_instance_id = mp.sr_instance_id
     and tp.sr_tp_id = mp.organization_id
     and tp.partner_type =3
     and mp.plan_id = p_plan_id
     and (mpsd.period_start_date between mp.data_start_date
                                 and mp.curr_cutoff_date
         or mpsd.next_date between mp.data_start_date and
                                   mp.curr_cutoff_date)
     order by mpsd.period_start_date;

    v_period := to_char(v_date.count);
    for a in 1 .. v_date.count loop
        v_period := v_period || field_seperator||
              to_char(v_date(a), format_mask);
    end loop;

  -- fetch bucket days

  select nvl(MIN_CUTOFF_BUCKET,0),
         nvl(HOUR_CUTOFF_BUCKET,0),
         DAILY_CUTOFF_BUCKET
    into v_min_day, v_hour_day, v_date_day
   from msc_plans
  where plan_id = p_plan_id;

  if v_min_day <> 0 then
        v_buckets :=
              to_char(g_first_date + v_min_day, format_mask);
  else
        v_buckets := v_buckets || field_seperator|| '0';
  end if;

  if v_hour_day <> 0 then
        v_buckets := v_buckets || field_seperator||
              to_char(g_first_date + v_min_day+v_hour_day, format_mask);
  else
        v_buckets := v_buckets || field_seperator|| '0';
  end if;

  if v_min_day+v_hour_day <> v_date_day then
        v_buckets := v_buckets || field_seperator||
              to_char(g_last_date, format_mask);
  else
        v_buckets := v_buckets || field_seperator|| '0';
  end if;
  p_bkt_type := 1;
  for a in 1..2 loop
    v_bkt_date := null;
    p_bkt_type := p_bkt_type +1;
    OPEN bkt_cur;
    FETCH bkt_cur into v_bkt_date;
    CLOSE bkt_cur;
    if v_bkt_date is not null then
        v_buckets := v_buckets || field_seperator||
              to_char(v_bkt_date, format_mask);
    else
        v_buckets := v_buckets || field_seperator|| '0';
    end if;
  end loop;
   return record_seperator || to_char(g_first_date, format_mask)
       || record_seperator || to_char(p_gantt_end_date, format_mask)
       || record_seperator || v_period
       || record_seperator || v_buckets ;
END get_plan_time;

PROCEDURE validate_and_move_end_job (p_plan_id number,
                             p_supply_id number,
                             p_end varchar2,
                             p_return_status OUT NOCOPY varchar2,
                             p_out out NOCOPY varchar2 ) IS
  l_quan Number;

BEGIN
      if to_date(p_end,format_mask) < g_first_date then
         p_return_status := 'ERROR';
         p_out := 'START';
         return;
      elsif to_date(p_end,format_mask) > g_cutoff_date then
         p_return_status := 'ERROR';
         p_out := 'END';
         return;
      end if;

      BEGIN
        SELECT nvl(new_order_quantity,0)
        INTO l_quan
        FROM msc_supplies
        WHERE plan_id = p_plan_id
           AND transaction_id = p_supply_id
        FOR UPDATE OF firm_date NOWAIT;
      EXCEPTION WHEN app_exception.record_lock_exception THEN
          p_return_status := 'ERROR';
          return;
      END;
      -- now update
      UPDATE msc_supplies
         SET firm_date = to_date(p_end, format_mask), firm_quantity = l_quan,
             applied = 2, status = 0, firm_planned_type = 1
       WHERE plan_id = p_plan_id
         AND transaction_id = p_supply_id;

     p_return_status := 'OK';

END validate_and_move_end_job;

Function get_result(start_index IN number,
                    v_return_data OUT NOCOPY varchar2,
                    next_index OUT NOCOPY number)
 return boolean IS
  v_one_record varchar2(2000);
  v_len number :=0;
  i number;
Begin
     i := start_index;
  if peg_data.parent_index.count > 0 and
     i < peg_data.parent_index.count  then
     while i is not null loop
          v_one_record := print_one_record(i);
          v_len := nvl(length(v_return_data),0) + nvl(length(v_one_record),0);

          if v_len < 1000 then
            v_return_data := v_return_data || record_seperator || v_one_record;
            next_index := i+1;
            i := peg_data.parent_index.next(i);
          else
            exit;
          end if;
     end loop;
  end if;

  if next_index = peg_data.parent_index.count then
   if  g_has_more_supply and g_end_demand_id is null then
         -- add next code
     v_one_record := next_index+1|| field_seperator ||
           NEXT_NODE || field_seperator ||
           -1 ||field_seperator ||
           'Next '||g_supply_limit||field_seperator ||
           -1 ||field_seperator ||
           -1 ||field_seperator||0;
     v_return_data :=v_return_data || record_seperator ||
           v_one_record;
   end if;
     return false;
  elsif v_return_data is null then
     return false;
  else
     return true;
  end if;

End get_result;

Procedure explode_children(p_plan_id number,
                           p_critical number default -1) IS

   p_supply_id number;
   p_instance_id number;
   p_org_id number;
   p_op_seq number;
   p_query_id number;
   p_op_seq_query_id number;
   p_end_peg_query_id number;

   CURSOR ops_seq_cur IS
    select distinct to_char(number2),
           number2,
           OP_NODE,
           0,
           0,
           0
     from msc_form_query
     where query_id = p_op_seq_query_id
       and number1 = p_supply_id
     order by number2;

-- get children which are not components

   Cursor peg_data_cur IS
    select distinct ms.organization_id,
           ms.transaction_id,
           ms.sr_instance_id,
           msc_get_gantt_data.order_number(ms.order_type,ms.order_number,
                         ms.plan_id, ms.sr_instance_id,
                         ms.transaction_id, ms.disposition_id) ||' for '||
               msi.item_name ||
               ' in ' ||mtp.organization_code ||'('||
               ms.new_order_quantity||')',
           nvl(ms.firm_planned_type,2),
           nvl(ms.status, 0),
           nvl(ms.applied,0),
           msc_get_gantt_data.isSupplyLate(ms.plan_id,ms.sr_instance_id,
                  ms.organization_id,ms.inventory_item_id,ms.transaction_id),
           msc_get_gantt_data.actualStartDate(ms.order_type,
                                           msi.planning_make_buy_code,
                                           ms.organization_id,
                                           ms.source_organization_id,
                                           ms.new_dock_date,
                                           ms.new_wip_start_date,
                                           ms.new_ship_date,
                                           ms.new_schedule_date),
           nvl(to_char(ms.new_schedule_date,format_mask),'null'),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.EARLIEST_START_DATE,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.EARLIEST_COMPLETION_DATE,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.ULPSD,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.ULPCD,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.UEPSD,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.UEPCD,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.MIN_START_DATE,format_mask), 'null')),
           decode(g_end_demand_id, null, 0,
               msc_get_gantt_data.isCriticalSupply(p_plan_id,g_end_demand_id,
                ms.transaction_id, ms.sr_instance_id)),
           msc_get_gantt_data.supplyType(ms.order_type,
                                           msi.planning_make_buy_code,
                                           ms.organization_id,
                                           ms.source_organization_id),
           mtp.organization_code||':'||msi.item_name,
           ms.inventory_item_id,
           nvl(ms.supplier_id,-1)
     from msc_full_pegging mfp1,
          msc_full_pegging mfp2,
          msc_supplies ms,
          msc_system_items msi,
          msc_trading_partners mtp,
          msc_form_query mfq
     where mfp1.plan_id = p_plan_id
      and mfp1.transaction_id = p_supply_id
      and mfp1.sr_instance_id = p_instance_id
      and mfp1.end_pegging_id = mfq.number1
      and mfq.query_id = p_end_peg_query_id
      and mfp2.plan_id = mfp1.plan_id
      and mfp2.prev_pegging_id = mfp1.pegging_id
      and ms.plan_id = mfp2.plan_id
      and ms.transaction_id = mfp2.transaction_id
      and ms.sr_instance_id = mfp2.sr_instance_id
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id
      and mtp.partner_type=3
      and mtp.sr_tp_id=ms.organization_id
      and mtp.sr_instance_id = ms.sr_instance_id
      and ms.transaction_id not in (
            select mfq.number3
         from msc_form_query mfq
         where mfq.query_id = p_query_id
      and mfq.number1 = p_supply_id
      and mfq.number2 is not null -- op_seq_num is not null
      );

-- get the children which have operation in msc_resource_requirements
   Cursor job_data_cur(p_op_seq_num number) IS
    select distinct
           mfq.number3, -- ms.transaction_id,
           mfq.number4, -- ms.sr_instance_id,
           mfq.number5, -- ms.organization_id,
           mfq.char10 || ' for '|| -- ms.order_number
               mi.item_name ||
               ' in ' ||mtp.organization_code ||'('||
               mfq.number11||')',
           mfq.number7, -- nvl(ms.firm_planned_type,2),
           mfq.number8, -- nvl(ms.status, 0),
           mfq.number9, -- nvl(ms.applied,0),
           mfq.number10, -- late flag
           mfq.char1,
           mfq.char2,
           mfq.char3,
           mfq.char4,
           mfq.char5,
           mfq.char6,
           mfq.char7,
           mfq.char8,
           mfq.char9,
           mfq.number12,
           mfq.number13,
           mtp.organization_code||':'||mi.item_name,
           mfq.number14,
           mfq.number15
     from msc_form_query mfq,
          msc_items mi,
          msc_trading_partners mtp
     where mfq.query_id = p_query_id
      and mfq.number1 = p_supply_id
      and mfq.number2 =p_op_seq_num
      and mi.inventory_item_id = mfq.number6
      and mtp.partner_type=3
      and mtp.sr_tp_id=mfq.number5
      and mtp.sr_instance_id = mfq.number4;

   CURSOR ops_data_cursor IS
    select to_char(mrr.operation_seq_num)||'/'
           ||to_char(mrr.resource_seq_num)||
           '('||msc_get_name.department_resource_code(mrr.resource_id,
                  mrr.department_id, mrr.organization_id,
                  mrr.plan_id, mrr.sr_instance_id)||')',
           to_char(msc_get_gantt_data.get_start_date(
              mrr.plan_id, mrr.transaction_id, mrr.sr_instance_id),
              format_mask),
           to_char(nvl(msc_get_gantt_data.get_end_date(
              mrr.plan_id, mrr.transaction_id, mrr.sr_instance_id),
              mrr.start_date),
              format_mask),
           mrr.transaction_id,
           nvl(mrr.department_id, 0),
           nvl(mrr.resource_id, 0),
           nvl(mrr.status, 0),
           nvl(mrr.applied, 0),
           nvl(mrr.firm_flag, 0),
           msc_get_gantt_data.isSupplyLate(ms.plan_id,ms.sr_instance_id,
                  ms.organization_id,ms.inventory_item_id,ms.transaction_id),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(mrr.EARLIEST_START_DATE,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(mrr.EARLIEST_COMPLETION_DATE,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(mrr.ULPSD,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(mrr.ULPCD,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(mrr.UEPSD,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(mrr.UEPCD,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.MIN_START_DATE,format_mask), 'null')),
           decode(g_end_demand_id, null, 0,
               msc_get_gantt_data.isCriticalRes(p_plan_id,g_end_demand_id,
                ms.transaction_id, ms.sr_instance_id,
                mrr.operation_seq_num, mrr.routing_sequence_id))
     from msc_resource_requirements mrr,
          msc_supplies ms
     where mrr.plan_id = p_plan_id
       and mrr.supply_id = p_supply_id
       and mrr.parent_id =2
       and mrr.operation_seq_num = p_op_seq
       and mrr.sr_instance_id = p_instance_id
       and mrr.organization_id = p_org_id
       and mrr.end_date is not null
       and mrr.department_id <> -1
       and ms.plan_id = mrr.plan_id
       and ms.transaction_id = mrr.supply_id
       and ms.sr_instance_id = mrr.sr_instance_id
      order by 2,3,1;

   CURSOR date_cur IS
    select to_char(nvl(decode(nvl(firm_planned_type,2),2,
                              new_dock_date,
                              new_dock_date+(firm_date-new_schedule_date)),
                       new_schedule_date),
                   format_mask),
           to_char(decode(nvl(firm_planned_type,2),2,
                   new_schedule_date,nvl(firm_date,new_schedule_date)),
                     format_mask),
           nvl(firm_planned_type,2)
     from msc_supplies
    where plan_id = p_plan_id
      and transaction_id = p_supply_id;

   i number;

   current_index number;
   parent_index number;
   child_index number;
   hasMore boolean;
   moreParent boolean;
   next_row number;
   p_count number;
   firstOp boolean;
   p_first_op number;
   v_op number_arr;
   v_new_op number_arr;
   v_dummy number;
   v_org_id number;
   v_transaction_id number;
   v_instance_id number;
   v_dept_id number;
   v_res_id number;
   v_name varchar2(200);
   v_firm_flag number;
   v_status number;
   v_applied number;
   v_late_flag number;
   v_start_date varchar2(20);
   v_end_date varchar2(20);
   v_early_start_date varchar2(20);
   v_early_end_date varchar2(20);
   v_u_early_start_date varchar2(20);
   v_u_early_end_date varchar2(20);
   v_latest_start_date varchar2(20);
   v_latest_end_date varchar2(20);
   v_min_start_date varchar2(20);
   v_critical_flag number;
   v_supply_type number;
   v_supplier_id number;
   v_item_id number;
   v_org_code varchar2(300);

   p_end_supply_id number;

BEGIN

        -- find the end_pegging_id

   if g_end_demand_id is not null then

      select msc_form_query_s.nextval
       into p_end_peg_query_id
        from dual;

        insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1)
                select
                        p_end_peg_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                        mfp.end_pegging_id
                   from msc_full_pegging mfp
                  where mfp.plan_id = p_plan_id
                    and mfp.demand_id = g_end_demand_id;

   end if;
   i := the_index;
   the_index := 0;
   if i = 0 then
    hasMore := false;
   else
    hasMore := true;
   end if;
   if g_has_prev_supply and g_end_demand_id is null then
     current_index :=1;
   else
     current_index :=0;
   end if;
   parent_index :=0;
   while (hasMore) loop

        -- fetch the children
        next_row := -1;
        child_index :=0;
        p_supply_id := peg_data.transaction_id(current_index);
        p_instance_id := peg_data.instance_id(current_index);
        p_org_id := peg_data.org_id(current_index);
      if peg_data.type(current_index) = END_DEMAND_NODE then
         next_row := peg_data.next_record(current_index); -- move to the next record
      elsif peg_data.type(current_index) = JOB_NODE then
        if g_end_demand_id is null then
           p_end_supply_id :=
              peg_data.res_firm_flag(current_index); -- end supply tran id
        else
           p_end_supply_id := null;
        end if;
        -- populate op seq num from msc_resource_requirements to msc_form_query

           if p_op_seq_query_id is null then
              select msc_form_query_s.nextval
                into p_op_seq_query_id
               from dual;
           end if;
           if p_critical <> -1 then
              insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,  -- supply_id
                        NUMBER2)  -- op_seq
              select distinct
                        p_op_seq_query_id,
                        trunc(sysdate),
                        -1,
                        trunc(sysdate),
                        -1,
                        -1,
                        p_supply_id,
                        mrr.operation_seq_num
              from msc_resource_requirements mrr,
                   msc_critical_paths mcp
             where mrr.plan_id = p_plan_id
               and mrr.supply_id = p_supply_id
               and mrr.sr_instance_id = p_instance_id
               and mrr.end_date is not null
               and nvl(mrr.parent_id,2) =2
               and mrr.department_id <> -1
               and mrr.organization_id = p_org_id
               and mrr.plan_id = mcp.plan_id
               and mrr.sr_instance_id = mcp.sr_instance_id
               and mrr.supply_id = mcp.supply_id
               and nvl(mrr.routing_sequence_id,-1) =
                           nvl(mcp.routing_sequence_id,-1)
               and mrr.operation_seq_num = mcp.operation_sequence_id
               and mcp.demand_id = g_end_demand_id
               and nvl(mcp.path_number,1) =
                     decode(p_critical,0,0,nvl(mcp.path_number,1));
           else -- not critical only
              insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,  -- supply_id
                        NUMBER2)  -- op_seq
              select distinct
                        p_op_seq_query_id,
                        trunc(sysdate),
                        -1,
                        trunc(sysdate),
                        -1,
                        -1,
                        p_supply_id,
                        operation_seq_num
              from msc_resource_requirements
             where plan_id = p_plan_id
               and supply_id = p_supply_id
               and sr_instance_id = p_instance_id
               and end_date is not null
               and department_id <> -1
               and nvl(parent_id,2) =2
               and organization_id = p_org_id;
           end if;
       firstOp := true;
       p_first_op :=1;
        -- get it's operations
        OPEN ops_seq_cur;
        LOOP
           FETCH ops_seq_cur INTO peg_data.name(i),
                                  peg_data.op_seq(i),
                                  peg_data.type(i),
                                  peg_data.status(i),
                                  peg_data.applied(i),
                                  peg_data.res_firm_flag(i);
        EXIT WHEN ops_seq_cur%NOTFOUND;
        if firstOp then
           peg_data.status(i) :=1;
           p_first_op :=peg_data.op_seq(i);
           firstOp := false;
        else
           peg_data.status(i) :=0;
        end if;
        peg_data.res_firm_flag(i) := p_end_supply_id; -- end supply trans id
        peg_data.late_flag(i) := 0;
        peg_data.parent_index(i) := current_index;
        peg_data.next_record(i) := -1;
        peg_data.transaction_id(i) := p_supply_id;
        peg_data.instance_id(i) := p_instance_id;
        peg_data.org_id(i) := p_org_id;
        peg_data.path(i) := peg_data.path(current_index)||
                            '-'||to_char(child_index);
        peg_data.new_path(i) := peg_data.path(i);
        if next_row > 0 then
          peg_data.next_record(i-1) := i;
        end if;
        if next_row=-1 then
           next_row :=i;
        end if;

        i := i+1;
        child_index := child_index +1;

        END LOOP;
        CLOSE ops_seq_cur;

        -- populate the children to msc_form_query

           if p_query_id is null then
              select msc_form_query_s.nextval
                into p_query_id
               from dual;
           end if;

   -- get the end_pegging_id
   if g_end_demand_id is null then

      select msc_form_query_s.nextval
       into p_end_peg_query_id
        from dual;

        insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1)
                select
                        p_end_peg_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                        mfp.end_pegging_id
                   from msc_full_pegging mfp
                  where mfp.plan_id = p_plan_id
                    and mfp.transaction_id = p_end_supply_id;
   end if;

        -- only get the children which are in the same pegging tree

         if (p_critical <> -1) then

           insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,  -- supply_id
                        NUMBER2,  -- op_seq
                        NUMBER3,  -- tran_id
                        NUMBER4,  -- inst_id
                        NUMBER5,  -- org_id
                        NUMBER6,  -- item_id
                        NUMBER7,  --firm_type
                        NUMBER8,  -- status
                        NUMBER9,  -- applied
                        NUMBER10,  -- late_flag
                        NUMBER11,  -- qty
                        CHAR10,  -- order_number
                        CHAR1,  -- start date
                        CHAR2,  -- end date
                        CHAR3,  -- early start date
                        CHAR4,  -- early end date
                        CHAR5,  -- latest start date
                        CHAR6,  -- latest end date
                        CHAR7,  -- min start
                        CHAR8,  -- u early start date
                        CHAR9,  -- u early end date
                        NUMBER12, -- critical_flag
                        NUMBER13, -- supply type
                        NUMBER14, -- item_id
                        NUMBER15) -- supplier_id
                  select distinct
                        p_query_id,
                        trunc(sysdate),
                        -1,
                        trunc(sysdate),
                        -1,
                        -1,
           p_supply_id,
           decode(md.op_seq_num,1,p_first_op,md.op_seq_num),
           ms.transaction_id,
           ms.sr_instance_id,
           ms.organization_id,
           ms.inventory_item_id,
           nvl(ms.firm_planned_type,2),
           nvl(ms.status, 0),
           nvl(ms.applied,0),
           msc_get_gantt_data.isSupplyLate(ms.plan_id,ms.sr_instance_id,
                  ms.organization_id,ms.inventory_item_id,ms.transaction_id),
           ms.new_order_quantity,
           msc_get_gantt_data.order_number(ms.order_type,ms.order_number,
                         ms.plan_id, ms.sr_instance_id,
                         ms.transaction_id, ms.disposition_id),
           msc_get_gantt_data.actualStartDate(ms.order_type,
                                           msi.planning_make_buy_code,
                                           ms.organization_id,
                                           ms.source_organization_id,
                                           ms.new_dock_date,
                                           ms.new_wip_start_date,
                                           ms.new_ship_date,
                                           ms.new_schedule_date),
           nvl(to_char(ms.new_schedule_date,format_mask),'null'),
               nvl(to_char(ms.EARLIEST_START_DATE,format_mask),'null'),
               nvl(to_char(ms.EARLIEST_COMPLETION_DATE,format_mask),'null'),
               nvl(to_char(ms.ULPSD,format_mask),'null'),
               nvl(to_char(ms.ULPCD,format_mask),'null'),
               nvl(to_char(ms.MIN_START_DATE,format_mask), 'null'),
               nvl(to_char(ms.UEPSD,format_mask),'null'),
               nvl(to_char(ms.UEPCD,format_mask),'null'),
               1,
             msc_get_gantt_data.supplyType(ms.order_type,
                                           msi.planning_make_buy_code,
                                           ms.organization_id,
                                           ms.source_organization_id),
             ms.inventory_item_id,
             nvl(ms.supplier_id,-1)
     from msc_full_pegging mfp1,
          msc_full_pegging mfp2,
          msc_supplies ms,
          msc_demands md,
          msc_system_items msi,
          msc_critical_paths mcp,
          msc_form_query mfq
     where mfp1.plan_id = p_plan_id
      and mfp1.transaction_id = p_supply_id
      and mfp1.end_pegging_id = mfq.number1
      and mfq.query_id = p_end_peg_query_id
      and md.plan_id = mfp1.plan_id
      and md.disposition_id = mfp1.transaction_id
      and md.sr_instance_id = mfp1.sr_instance_id
      and nvl(md.op_seq_num,0) <> 0
      and mfp2.plan_id = mfp1.plan_id
      and mfp2.prev_pegging_id = mfp1.pegging_id
      and mfp2.demand_id = md.demand_id
      and ms.plan_id = mfp2.plan_id
      and ms.transaction_id = mfp2.transaction_id
      and mcp.plan_id = ms.plan_id
      and mcp.supply_id = ms.transaction_id
      and mcp.sr_instance_id = ms.sr_instance_id
      and mcp.demand_id = g_end_demand_id
      -- and mcp.routing_sequence_id is null
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id
      and nvl(mcp.path_number,1) =
                     decode(p_critical,0,0,nvl(mcp.path_number,1))
      ;

         else -- not critical_only
           insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,  -- supply_id
                        NUMBER2,  -- op_seq
                        NUMBER3,  -- tran_id
                        NUMBER4,  -- inst_id
                        NUMBER5,  -- org_id
                        NUMBER6,  -- item_id
                        NUMBER7,  --firm_type
                        NUMBER8,  -- status
                        NUMBER9,  -- applied
                        NUMBER10,  -- late_flag
                        NUMBER11, -- qty
                        CHAR10,  -- order_number
                        CHAR1,  -- start date
                        CHAR2,  -- end date
                        CHAR3,  -- early start date
                        CHAR4,  -- early end date
                        CHAR5,  -- latest start date
                        CHAR6,  -- latest end date
                        CHAR7,  -- min start
                        CHAR8,  -- u early start date
                        CHAR9,  -- u early end date
                        NUMBER12, -- critical_flag
                        NUMBER13, -- supply type
                        NUMBER14, -- item_id
                        NUMBER15)  -- supplier_id
                  select distinct
                        p_query_id,
                        trunc(sysdate),
                        -1,
                        trunc(sysdate),
                        -1,
                        -1,
           p_supply_id,
           decode(md.op_seq_num,1,p_first_op,md.op_seq_num),
           ms.transaction_id,
           ms.sr_instance_id,
           ms.organization_id,
           ms.inventory_item_id,
           nvl(ms.firm_planned_type,2),
           nvl(ms.status, 0),
           nvl(ms.applied,0),
           msc_get_gantt_data.isSupplyLate(ms.plan_id,ms.sr_instance_id,
                  ms.organization_id,ms.inventory_item_id,ms.transaction_id),
           ms.new_order_quantity,
           msc_get_gantt_data.order_number(ms.order_type,ms.order_number,
                         ms.plan_id, ms.sr_instance_id,
                         ms.transaction_id, ms.disposition_id),
           msc_get_gantt_data.actualStartDate(ms.order_type,
                                           msi.planning_make_buy_code,
                                           ms.organization_id,
                                           ms.source_organization_id,
                                           ms.new_dock_date,
                                           ms.new_wip_start_date,
                                           ms.new_ship_date,
                                           ms.new_schedule_date),
           nvl(to_char(ms.new_schedule_date,format_mask),'null'),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.EARLIEST_START_DATE,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.EARLIEST_COMPLETION_DATE,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.ULPSD,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.ULPCD,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.MIN_START_DATE,format_mask), 'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.UEPSD,format_mask),'null')),
           decode(g_end_demand_id, null, 'null',
               nvl(to_char(ms.UEPCD,format_mask),'null')),
           decode(g_end_demand_id, null, 0,
               msc_get_gantt_data.isCriticalSupply(p_plan_id,g_end_demand_id,
                ms.transaction_id, ms.sr_instance_id)),
           msc_get_gantt_data.supplyType(ms.order_type,
                                           msi.planning_make_buy_code,
                                           ms.organization_id,
                                           ms.source_organization_id),
           ms.inventory_item_id,
           nvl(ms.supplier_id,-1)
     from msc_full_pegging mfp1,
          msc_full_pegging mfp2,
          msc_system_items msi,
          msc_supplies ms,
          msc_demands md,
          msc_form_query mfq
     where mfp1.plan_id = p_plan_id
      and mfp1.transaction_id = p_supply_id
      and mfp1.end_pegging_id = mfq.number1
      and mfq.query_id = p_end_peg_query_id
      and md.plan_id = mfp1.plan_id
      and md.disposition_id = mfp1.transaction_id
      and md.sr_instance_id = mfp1.sr_instance_id
      and nvl(md.op_seq_num,0) <> 0
      and mfp2.plan_id = mfp1.plan_id
      and mfp2.prev_pegging_id = mfp1.pegging_id
      and mfp2.demand_id = md.demand_id
      and ms.plan_id = mfp2.plan_id
      and ms.transaction_id = mfp2.transaction_id
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id;

    end if;

      -- if op exists in msc_demand but not in msc_resource_requirements,
      -- show the op in the closest next op or prev op

      begin
        select distinct mfq.number2, mfq.number2
        bulk collect into v_op, v_new_op
          from msc_form_query mfq
         where mfq.query_id = p_query_id
           and mfq.number1 = p_supply_id
           and mfq.number2 not in (
           select mfq_mrr.number2
             from msc_form_query mfq_mrr
             where mfq_mrr.query_id = p_op_seq_query_id
              and mfq_mrr.number1 = p_supply_id);
          for a in 1 .. v_op.count loop
              -- find the closest next op
               select min(number2)
                 into v_dummy
                 from msc_form_query
                where query_id = p_op_seq_query_id
                  and   number1 = p_supply_id
                  and   number2 > v_op(a);
            if v_dummy is null then
              -- if not found, find the closest prev op
               select max(number2)
                 into v_dummy
                 from msc_form_query
                where query_id = p_op_seq_query_id
                  and number1 = p_supply_id
                  and number2 < v_op(a);
            end if;
             v_new_op(a) := v_dummy;
          end loop;

          forall a in 1.. v_op.count
            update msc_form_query
               set number2= v_new_op(a)
             where query_id = p_query_id
               and number1 = p_supply_id
               and number2 = v_op(a);

       exception when no_data_found then
         null;
       end;

        -- get its children which is not its component
       -- only get the children which are in the same pegging tree

        OPEN peg_data_cur;
        LOOP
           FETCH peg_data_cur INTO v_org_id,
                               v_transaction_id,
                               v_instance_id,
                               v_name,
                               v_firm_flag,
                               v_status,
                               v_applied,
                               v_late_flag,
                               v_start_date,
                               v_end_date,
                               v_early_start_date,
                               v_early_end_date,
                               v_latest_start_date,
                               v_latest_end_date,
                               v_u_early_start_date,
                               v_u_early_end_date,
                               v_min_start_date,
                               v_critical_flag,
                               v_supply_type,
                               v_org_code,
                               v_item_id,
                               v_supplier_id;
           EXIT WHEN peg_data_cur%NOTFOUND;
           if (p_critical =0 and v_critical_flag = 0) or -- critical path 0
              (p_critical =1 and v_critical_flag >= 0) or -- all critical path
              (p_critical = -1) then  -- all path
               peg_data.org_id(i) := v_org_id;
               peg_data.transaction_id(i) := v_transaction_id;
               peg_data.instance_id(i) := v_instance_id;
               peg_data.name(i) := v_name;
               peg_data.firm_flag(i) := v_firm_flag;
               peg_data.status(i) := v_status;
               peg_data.applied(i) := v_applied;
               peg_data.late_flag(i) := v_late_flag;
               peg_data.start_date(i) := v_start_date;
               peg_data.end_date(i) := v_end_date;
               peg_data.early_start_date(i) := v_early_start_date;
               peg_data.early_end_date(i) := v_early_end_date;
               peg_data.latest_start_date(i) := v_latest_start_date;
               peg_data.latest_end_date(i) := v_latest_end_date;
               peg_data.u_early_start_date(i) := v_u_early_start_date;
               peg_data.u_early_end_date(i) := v_u_early_end_date;
               peg_data.min_start_date(i) := v_min_start_date;
               peg_data.critical_flag(i) := v_critical_flag;
               peg_data.supply_type(i) := v_supply_type;
               peg_data.res_firm_flag(i) := p_end_supply_id; -- end supply id
               peg_data.parent_index(i) := current_index;
               peg_data.next_record(i) := -1;
               peg_data.type(i) := JOB_NODE;
               peg_data.path(i) := peg_data.path(current_index)||
                               '-'||to_char(child_index);
               peg_data.new_path(i) := peg_data.path(i);
               if next_row > 0 then
                  peg_data.next_record(i-1) := i;
               end if;
               if next_row=-1 then
                  next_row :=i;
               end if;
               i := i+1;
               child_index := child_index +1;

         if v_supplier_id <> -1 and
            g_supplier_query_id is not null then
            -- for supplier list
             insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,
                        NUMBER2,
                        NUMBER3,
                        NUMBER4,
                        char1)
                values (
                        g_supplier_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                         v_supplier_id,
                         v_org_id,
                         v_instance_id,
                         v_item_id,
                         v_org_code);
             end if;

            end if;
        END LOOP;
        CLOSE peg_data_cur;

        -- if no child and no operations, should be buy part
        if next_row = -1 and
           g_end_demand_id is null then
           OPEN date_cur;
           FETCH date_cur INTO peg_data.start_date(current_index),
                               peg_data.end_date(current_index),
                               peg_data.firm_flag(current_index);
           CLOSE date_cur;
           peg_data.type(current_index) := END_JOB_NODE;
        end if;


     elsif peg_data.type(current_index) = OP_NODE then
        p_op_seq := peg_data.op_seq(current_index);
        if g_end_demand_id is null then
           p_end_supply_id :=
              peg_data.res_firm_flag(current_index); -- end supply tran id
        else
           p_end_supply_id := null;
        end if;
        -- get the children
        OPEN job_data_cur(p_op_seq);
        LOOP
           FETCH job_data_cur INTO peg_data.transaction_id(i),
                                   peg_data.instance_id(i),
                                   peg_data.org_id(i),
                                   peg_data.name(i),
                                   peg_data.firm_flag(i),
                                   peg_data.status(i),
                                   peg_data.applied(i),
                                   peg_data.late_flag(i),
                                   peg_data.start_date(i),
                                   peg_data.end_date(i),
                                   peg_data.early_start_date(i),
                                   peg_data.early_end_date(i),
                                   peg_data.latest_start_date(i),
                                   peg_data.latest_end_date(i),
                                   peg_data.min_start_date(i),
                                   peg_data.u_early_start_date(i),
                                   peg_data.u_early_end_date(i),
                                   peg_data.critical_flag(i),
                                   peg_data.supply_type(i),
                                   v_org_code,
                                   v_item_id,
                                   v_supplier_id;
        EXIT WHEN job_data_cur%NOTFOUND;

        peg_data.res_firm_flag(i) := p_end_supply_id; -- store end supply id
        peg_data.parent_index(i) := current_index;
        peg_data.next_record(i) := -1;
        peg_data.type(i) := JOB_NODE;
        peg_data.path(i) := peg_data.path(current_index)||
                            '-'||to_char(child_index);
        peg_data.new_path(i) := peg_data.path(i);
        if next_row > 0 then
          peg_data.next_record(i-1) := i;
        end if;
        if next_row=-1 then
           next_row :=i;
        end if;

         if v_supplier_id <> -1 and
            g_supplier_query_id is not null then
            -- for supplier list
             insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,
                        NUMBER2,
                        NUMBER3,
                        NUMBER4,
                        char1)
                values (
                        g_supplier_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                         v_supplier_id,
                         peg_data.org_id(i),
                         peg_data.instance_id(i),
                         v_item_id,
                         v_org_code);
             end if;

        i := i+1;
        child_index := child_index +1;

        END LOOP;
        CLOSE job_data_cur;

     OPEN ops_data_cursor;
     LOOP
     FETCH ops_data_cursor INTO
                               v_name,
                               v_start_date,
                               v_end_date,
                               v_transaction_id,
                               v_dept_id,
                               v_res_id,
                               v_status,
                               v_applied,
                               v_firm_flag,
                               v_late_flag,
                               v_early_start_date,
                               v_early_end_date,
                               v_latest_start_date,
                               v_latest_end_date,
                               v_u_early_start_date,
                               v_u_early_end_date,
                               v_min_start_date,
                               v_critical_flag;
     EXIT WHEN ops_data_cursor%NOTFOUND;

        if (p_critical = 0 and v_critical_flag = 0) or
           (p_critical = 1 and v_critical_flag >= 0) or
           (p_critical = -1 ) then
               peg_data.transaction_id(i) := v_transaction_id;
               peg_data.department_id(i) := v_dept_id;
               peg_data.name(i) := v_name;
               peg_data.res_firm_flag(i) := v_firm_flag;
               if peg_data.res_firm_flag(i) >= 8 then
                  peg_data.res_firm_flag(i) := 0;
               end if;
               peg_data.status(i) := v_status;
               peg_data.applied(i) := v_applied;
               peg_data.late_flag(i) := v_late_flag;
               peg_data.start_date(i) := v_start_date;
               peg_data.end_date(i) := v_end_date;
               peg_data.early_start_date(i) := v_early_start_date;
               peg_data.early_end_date(i) := v_early_end_date;
               peg_data.latest_start_date(i) := v_latest_start_date;
               peg_data.latest_end_date(i) := v_latest_end_date;
               peg_data.u_early_start_date(i) := v_u_early_start_date;
               peg_data.u_early_end_date(i) := v_u_early_end_date;
               peg_data.min_start_date(i) := v_min_start_date;
               peg_data.critical_flag(i) := v_critical_flag;
               peg_data.org_id(i) := p_org_id;
               peg_data.instance_id(i) := p_instance_id;
               peg_data.type(i) := RES_NODE;
               peg_data.parent_index(i) := current_index;
               peg_data.next_record(i) := -1;
               peg_data.path(i) := peg_data.path(current_index)||
                            '-'||to_char(child_index);
               peg_data.new_path(i) := peg_data.path(i);
               i := i+1;
               child_index := child_index +1;

            -- for resource centric view
                insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,
                        NUMBER2,
                        NUMBER3,
                        NUMBER4)
                values (
                        g_res_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                         p_instance_id,
                         p_org_id,
                         v_dept_id,
                         v_res_id);
        end if;
     END LOOP;
     CLOSE ops_data_cursor;
     end if;
   if next_row =-1 then
     if peg_data.next_record(current_index) <> -1 then
      -- move to next record
        next_row := peg_data.next_record(current_index);
     elsif peg_data.next_record(current_index) = -1 and
             peg_data.parent_index(current_index) <> -1 then
       -- move to next parent
        parent_index := peg_data.parent_index(current_index);
        moreParent := true;
        while (moreParent) loop
           if peg_data.next_record(parent_index) <> -1 then
             next_row := peg_data.next_record(parent_index);
             moreParent := false;
           elsif peg_data.parent_index(parent_index) <> -1 then
             parent_index := peg_data.parent_index(parent_index);
           elsif peg_data.next_record(parent_index) = -1 and
                 peg_data.parent_index(parent_index) = -1 then
             moreParent := false;
             hasMore := false;
           end if;

        end loop;
     elsif peg_data.next_record(current_index) = -1 and
             peg_data.parent_index(current_index) = -1 then
       -- no more data
        hasMore := false;
     end if;
   end if;
     current_index := next_row;
   end loop;

END explode_children;

Procedure get_end_pegging(p_plan_id number) IS
   i number;
    TYPE char_arr IS TABLE OF varchar2(300);
   curr_org_id number_arr;
   curr_trans_id number_arr;
   curr_inst_id number_arr;
   curr_name char_arr;
   curr_end_pegging_id number_arr;
   curr_late_flag number_arr;
   curr_start_date char_arr;
   curr_end_date char_arr;
   curr_supply_type number_arr;
   v_current_block number;

   CURSOR end_peg_cur IS
    select distinct ms.organization_id,
           ms.transaction_id, ms.sr_instance_id,
           msc_get_gantt_data.order_number(ms.order_type,ms.order_number,
                         ms.plan_id, ms.sr_instance_id,
                         ms.transaction_id, ms.disposition_id) ||' for '||
               msi.item_name ||
               ' in ' || mtp.organization_code,
           1, -- mfp1.pegging_id,
           msc_get_gantt_data.isSupplyLate(ms.plan_id,ms.sr_instance_id,
                  ms.organization_id,ms.inventory_item_id,ms.transaction_id),
           msc_get_gantt_data.actualStartDate(ms.order_type,
                                           msi.planning_make_buy_code,
                                           ms.organization_id,
                                           ms.source_organization_id,
                                           ms.new_dock_date,
                                           ms.new_wip_start_date,
                                           ms.new_ship_date,
                                           ms.new_schedule_date),
           nvl(to_char(ms.new_schedule_date,format_mask),'null'),
           msc_get_gantt_data.supplyType(ms.order_type,
                                           msi.planning_make_buy_code,
                                           ms.organization_id,
                                           ms.source_organization_id)
    from  msc_full_pegging mfp1,
          msc_full_pegging mfp2,
          msc_form_query mfq,
          msc_supplies ms,
          msc_system_items msi,
          msc_trading_partners mtp
    where mfp1.pegging_id = mfp2.end_pegging_id
      and mfp1.plan_id = mfp2.plan_id
      and mfp1.sr_instance_id = mfp2.sr_instance_id
      and mfp2.plan_id = p_plan_id
      and mfp2.transaction_id = mfq.number1
      and mfp2.sr_instance_id = mfq.number2
      and mfq.query_id = g_supply_query_id
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id
      and mtp.partner_type =3
      and mtp.sr_tp_id = ms.organization_id
      and mtp.sr_instance_id = ms.sr_instance_id
      and ms.plan_id = mfp1.plan_id
      and ms.transaction_id = mfp1.transaction_id
      and ms.sr_instance_id = mfp1.sr_instance_id
      order by ms.transaction_id;

   CURSOR peg_cur IS
    select distinct ms.organization_id,
           ms.transaction_id, ms.sr_instance_id,
           msc_get_gantt_data.order_number(ms.order_type,ms.order_number,
                         ms.plan_id, ms.sr_instance_id,
                         ms.transaction_id, ms.disposition_id)||' for '||
               msi.item_name ||
               ' in ' || mtp.organization_code,
           1, -- mfp1.pegging_id,
           msc_get_gantt_data.isSupplyLate(ms.plan_id,ms.sr_instance_id,
                  ms.organization_id,ms.inventory_item_id,ms.transaction_id),
           msc_get_gantt_data.actualStartDate(ms.order_type,
                                           msi.planning_make_buy_code,
                                           ms.organization_id,
                                           ms.source_organization_id,
                                           ms.new_dock_date,
                                           ms.new_wip_start_date,
                                           ms.new_ship_date,
                                           ms.new_schedule_date),
           nvl(to_char(ms.new_schedule_date,format_mask),'null'),
           msc_get_gantt_data.supplyType(ms.order_type,
                                           msi.planning_make_buy_code,
                                           ms.organization_id,
                                           ms.source_organization_id)
    from  msc_full_pegging mfp2,
          msc_form_query mfq,
          msc_supplies ms,
          msc_system_items msi,
          msc_trading_partners mtp
    where mfp2.plan_id = p_plan_id
      and mfp2.transaction_id = mfq.number1
      and mfp2.sr_instance_id = mfq.number2
      and mfq.query_id = g_supply_query_id
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id
      and mtp.partner_type =3
      and mtp.sr_tp_id = ms.organization_id
      and mtp.sr_instance_id = ms.sr_instance_id
      and ms.plan_id = mfp2.plan_id
      and ms.transaction_id = mfp2.transaction_id
      and ms.sr_instance_id = mfp2.sr_instance_id
      order by ms.transaction_id;

  p_found boolean;

  --Limit Gantt Chart Orders View Hierarchy". Default = No [2]
  p_gantt_hier_prf varchar2(10) := nvl(fnd_profile.value('MSC_GANTT_ORDER_HIERARCHY'), 'N');

BEGIN

  i :=the_index;
  g_has_prev_supply := false;

  if i = 0 and g_current_block >= 2 then -- add prev node
        peg_data.org_id(i) := -1;
        peg_data.transaction_id(i) := -1;
        peg_data.instance_id(i) := -1;
        peg_data.name(i) := 'Previous '||g_supply_limit;
        peg_data.late_flag(i) := 0;
        peg_data.type(i) := PREV_NODE;
        peg_data.parent_index(i) := -1;
        peg_data.next_record(i) := -1;
        peg_data.path(i) := to_char(i);
      g_has_prev_supply := true;
      i := i +1;
  end if;
  v_current_block := 1;
  g_has_more_supply := false;
  p_found := false;

  if ( p_gantt_hier_prf = 'Y' ) then
    OPEN peg_cur;
  else
    OPEN end_peg_cur;
  end if;

  LOOP
    if ( p_gantt_hier_prf = 'Y' ) then
      FETCH peg_cur bulk collect into
                        curr_org_id, curr_trans_id,
                        curr_inst_id, curr_name,
                        curr_end_pegging_id,
                        curr_late_flag,
                        curr_start_date,
                        curr_end_date,
                        curr_supply_type LIMIT g_supply_limit;
      EXIT WHEN peg_cur%NOTFOUND or v_current_block > g_current_block +1;
    else
      FETCH end_peg_cur bulk collect into
                        curr_org_id, curr_trans_id,
                        curr_inst_id, curr_name,
                        curr_end_pegging_id,
                        curr_late_flag,
                        curr_start_date,
                        curr_end_date,
                        curr_supply_type LIMIT g_supply_limit;
      EXIT WHEN end_peg_cur%NOTFOUND or v_current_block > g_current_block +1;
    end if;

    if v_current_block = g_current_block then
     For a in 1.. curr_org_id.count loop
        peg_data.org_id(i) := curr_org_id(a);
        peg_data.transaction_id(i) := curr_trans_id(a);
        peg_data.instance_id(i) := curr_inst_id(a);
        peg_data.name(i) := curr_name(a);
        peg_data.late_flag(i) := curr_late_flag(a);
        peg_data.start_date(i) := curr_start_date(a);
        peg_data.end_date(i) := curr_end_date(a);
        peg_data.supply_type(i) := curr_supply_type(a);
        peg_data.type(i) := JOB_NODE;
        peg_data.res_firm_flag(i) := curr_trans_id(a); -- end supply trans id
        peg_data.parent_index(i) := -1;
        peg_data.next_record(i) := -1;
        peg_data.path(i) := to_char(i);
        peg_data.new_path(i) := peg_data.path(i);
        if i>0 then
           peg_data.next_record(i-1) := i;
        end if;
        i := i+1;
        p_found := true;
     END LOOP;
     the_index := i;
    end if;
    v_current_block := v_current_block +1;
  END LOOP;

  if ( p_gantt_hier_prf = 'Y' ) then
    CLOSE peg_cur;
  else
    CLOSE end_peg_cur;
  end if;

  if not(p_found) then -- last block
     For a in 1.. curr_org_id.count loop
        peg_data.org_id(i) := curr_org_id(a);
        peg_data.transaction_id(i) := curr_trans_id(a);
        peg_data.instance_id(i) := curr_inst_id(a);
        peg_data.name(i) := curr_name(a);
        peg_data.late_flag(i) := curr_late_flag(a);
        peg_data.start_date(i) := curr_start_date(a);
        peg_data.end_date(i) := curr_end_date(a);
        peg_data.supply_type(i) := curr_supply_type(a);
        peg_data.type(i) := JOB_NODE;
        peg_data.res_firm_flag(i) := curr_trans_id(a); -- end supply trans id
        peg_data.parent_index(i) := -1;
        peg_data.next_record(i) := -1;
        peg_data.path(i) := to_char(i);
        peg_data.new_path(i) := peg_data.path(i);
        if i>0 then
           peg_data.next_record(i-1) := i;
        end if;
        i := i+1;
     END LOOP;
     the_index := i;
  elsif curr_org_id.count > 0 then
      g_has_more_supply := true;
  end if;
END get_end_pegging;

Procedure fetchSupplyData(p_plan_id number, p_supply_list varchar2,
                          p_fetch_type varchar2 default null) IS
  v_transaction_id number;
  v_instance_id number;
  v_len number;
  one_record varchar2(100);
  i number:=1;


BEGIN

    -- the format of supply_list is
    -- (instance_id, transaction_id),(ins_id, transaction_id)

 msc_get_gantt_data.init;

   if g_current_block is null then
      g_current_block := 1;
   end if;

   if p_fetch_type is null then
      g_current_block := 1;
   elsif p_fetch_type = 'PREV' then
      g_current_block := g_current_block-1;
   elsif p_fetch_type = 'NEXT' then
      g_current_block := g_current_block+1;
   end if;

if p_fetch_type is null then
   if g_supply_query_id is not null then
      delete msc_form_query
      where query_id = g_supply_query_id;
   else
      select msc_form_query_s.nextval
       into g_supply_query_id
        from dual;
   end if;

   if g_res_query_id is not null then
      delete msc_form_query
      where query_id = g_res_query_id;
   else
      select msc_form_query_s.nextval
       into g_res_query_id
        from dual;
   end if;

   g_supplier_query_id := null;

 v_len := length(p_supply_list);
 while v_len > 0 LOOP
    one_record :=
      substr(p_supply_list,instr(p_supply_list,'(',1,i)+1,
                 instr(p_supply_list,')',1,i)-instr(p_supply_list,'(',1,i)-1);
    v_instance_id := to_number(substr(one_record,1,instr(one_record,',')-1));
    v_transaction_id := to_number(substr(one_record,instr(one_record,',')+1));

             insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,
                        NUMBER2)
                values (
                        g_supply_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                         v_transaction_id,
                         v_instance_id);
    i := i+1;
    v_len := v_len - length(one_record)-3;

 END LOOP;
end if; -- if p_patch_type is null

 get_end_pegging(p_plan_id);
 msc_get_gantt_data.explode_children(p_plan_id);

END fetchSupplyData;

Procedure get_property(p_plan_id number, p_instance_id number,
          p_transaction_id number, p_type number,
          v_pro out NOCOPY varchar2, v_demand out NOCOPY varchar2)
IS

   CURSOR job_cur IS
   SELECT msc_get_name.item_name(ms.inventory_item_id,null,null,null) item,
          ms.new_order_quantity qty,
          nvl(to_char(ms.firm_date,format_mask), '   ') firm_date,
          to_char(ms.new_schedule_date,format_mask) sugg_due_date,
          nvl(to_char(ms.need_by_date,format_mask), '   ') needby,
          nvl(ms.unit_number,'null') unit_number,
          nvl(msc_get_name.project(ms.project_id,
                               ms.organization_id,
                               ms.plan_id,
                               ms.sr_instance_id), 'null') project,
          nvl(msc_get_name.task(   ms.task_id,
                               ms.project_id,
                               ms.organization_id,
                               ms.plan_id,
                               ms.sr_instance_id),'null') task,
          msc_get_name.org_code(ms.organization_id, ms.sr_instance_id) org,
          msc_get_gantt_data.order_number(ms.order_type,ms.order_number,
                         ms.plan_id, ms.sr_instance_id,
                         ms.transaction_id, ms.disposition_id) job_name,
          ms.firm_planned_type,
          nvl(ms.alternate_bom_designator, 'null') alternate_bom_designator,
          nvl(ms.alternate_routing_designator, 'null')
                    alternate_routing_designator,
          ms.organization_id org_id,
          nvl(to_char(msi.planning_time_fence_date, format_mask),'   ') time_fence,
          msc_get_name.supply_type(ms.transaction_id, p_plan_id) supply_type,
          decode(msc_get_gantt_data.supplyType(ms.order_type,
                                         msi.planning_make_buy_code,
                                         ms.organization_id,
                                         ms.source_organization_id),
                  BUY_SUPPLY, g_buy_text,
                  TRANSFER_SUPPLY, g_transfer_text,
                  MAKE_SUPPLY, g_make_text) item_type,
          msi.description,
          nvl(msc_get_name.supplier(
                nvl(ms.source_supplier_id, ms.supplier_id)),'-1') supplier,
          nvl(msc_get_name.org_code(ms.source_organization_id,
                                    ms.source_sr_instance_id),'-1') source_org,
          nvl(ms.ship_method, '-1') ship_method,
          msc_get_name.lookup_meaning('SYS_YES_NO',
                           decode(ms.supply_is_shared,1,1,2)) share_supply,
          nvl(to_char(ms.EARLIEST_START_DATE,format_mask),'null') EPSD,
          nvl(to_char(ms.EARLIEST_COMPLETION_DATE,format_mask),'null') EPCD,
          nvl(to_char(ms.UEPSD,format_mask),'null') UEPSD,
          nvl(to_char(ms.UEPCD,format_mask),'null') UEPCD,
          nvl(to_char(ms.ULPSD,format_mask),'null') ULPSD,
          nvl(to_char(ms.ULPCD,format_mask),'null') ULPCD
     FROM msc_supplies ms,
          msc_system_items msi
    WHERE ms.plan_id = p_plan_id
      AND ms.transaction_id = p_transaction_id
      and ms.sr_instance_id = p_instance_id
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id;

   CURSOR res_cur IS
   SELECT msc_get_name.item_name(mrr.assembly_item_id,null,null,null) item,
          nvl(mrr.operation_seq_num,0) op_seq,
          msc_get_name.org_code(mrr.organization_id, mrr.sr_instance_id) org,
          msc_get_name.department_code(decode(mrr.resource_id, -1, 1,2),
                         mrr.department_id, mrr.organization_id,
                         mrr.plan_id, mrr.sr_instance_id) dept_code,
          nvl(msc_get_name.job_name(mrr.supply_id, p_plan_id),
                     to_char(mrr.supply_id)) job_name,
          nvl(mrr.assigned_units,0) assigned_units,
          msc_get_name.lookup_meaning('RESOURCE_FIRM_TYPE',
                     nvl(mrr.firm_flag,0)) firm_flag,
          nvl(mrr.alternate_num,0) alternate_num,
          nvl(mrr.resource_seq_num,0) res_seq_num,
          nvl(msc_get_name.resource_code(mrr.resource_id,
                         mrr.department_id, mrr.organization_id,
                         mrr.plan_id, mrr.sr_instance_id)
              , 'null') res_code,
          nvl(mrr.resource_hours,0) resource_hours,
          ms.organization_id org_id,
          ms.transaction_id trans_id,
          0 mtq_time, -- get_MTQ_time(p_transaction_id, p_plan_id, p_instance_id) mtq_time,
          nvl(mdr.batchable_flag,2) batchable,
          nvl(mrr.batch_number, -1) batch_number,
          nvl(mdr.unit_of_measure,'-1') uom,
          nvl(decode(mrr.basis_type, null, '-1',
            msc_get_name.lookup_meaning(
               'MSC_RES_BASIS_TYPE',mrr.basis_type)),'-1') basis_type,
          nvl(decode(mrr.schedule_flag, null, '-1',
            msc_get_name.lookup_meaning(
               'BOM_RESOURCE_SCHEDULE_TYPE',mrr.schedule_flag)),'-1') schedule_flag,
          nvl(to_char(mrr.EARLIEST_START_DATE,format_mask),'null') EPSD,
          nvl(to_char(mrr.EARLIEST_COMPLETION_DATE,format_mask),'null') EPCD,
          nvl(to_char(mrr.UEPSD,format_mask),'null') UEPSD,
          nvl(to_char(mrr.UEPCD,format_mask),'null') UEPCD,
          nvl(to_char(mrr.ULPSD,format_mask),'null') ULPSD,
          nvl(to_char(mrr.ULPCD,format_mask),'null') ULPCD
    FROM  msc_resource_requirements mrr,
          msc_supplies ms,
          msc_department_resources mdr
   WHERE  mrr.plan_id = p_plan_id
      AND mrr.transaction_id = p_transaction_id
      and mrr.sr_instance_id = p_instance_id
      and ms.sr_instance_id = mrr.sr_instance_id
      and ms.plan_id = p_plan_id
      and ms.transaction_id = mrr.supply_id
      AND mdr.plan_id = mrr.plan_id
      AND mdr.organization_id = mrr.organization_id
      AND mdr.sr_instance_id = mrr.sr_instance_id
      AND mdr.department_id = mrr.department_id
      AND mdr.resource_id = mrr.resource_id
      ;

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
BEGIN
    if p_type in (JOB_NODE, END_JOB_NODE) then
       -- calculate alloc_qty, excess_qty, and short_qty

       select mfp.end_pegging_id
         bulk collect into v_end_peg_id
         from msc_full_pegging mfp
        where mfp.plan_id = p_plan_id
          and mfp.demand_id = g_end_demand_id
          and mfp.pegging_id = mfp.end_pegging_id;
       for a in 1..v_end_peg_id.count loop
          p_end_peg_id := v_end_peg_id(a);
          v_qty1 :=0;
          v_qty2 :=0;
          open alloc_cur;
          fetch alloc_cur into v_qty1,v_qty2;
          close alloc_cur;
          v_excess_qty := v_excess_qty + nvl(v_qty1,0);
          v_alloc_qty := v_alloc_qty + nvl(v_qty2,0);
       end loop;

       OPEN job_cur;
       FETCH job_cur INTO job_cur_rec;
       CLOSE job_cur;
       v_pro := replace_seperator(job_cur_rec.item) || field_seperator ||
                job_cur_rec.qty || field_seperator ||
                job_cur_rec.firm_date || field_seperator ||
                job_cur_rec.sugg_due_date || field_seperator ||
                job_cur_rec.needby || field_seperator ||
                job_cur_rec.unit_number || field_seperator ||
                job_cur_rec.project || field_seperator ||
                job_cur_rec.task || field_seperator ||
                replace_seperator(job_cur_rec.org) || field_seperator ||
                replace_seperator(job_cur_rec.job_name) || field_seperator ||
                job_cur_rec.firm_planned_type || field_seperator ||
                job_cur_rec.alternate_bom_designator || field_seperator ||
                job_cur_rec.alternate_routing_designator || field_seperator ||
                job_cur_rec.time_fence || field_seperator ||
                nvl(job_cur_rec.supply_type, ' ')||field_seperator ||
                job_cur_rec.item_type || field_seperator ||
                replace_seperator(job_cur_rec.description)|| field_seperator ||
                nvl(v_alloc_qty,'-1') || field_seperator ||
                nvl(v_excess_qty,'-1')|| field_seperator ||
                replace_seperator(job_cur_rec.supplier) || field_seperator ||
                replace_seperator(job_cur_rec.source_org) || field_seperator ||
                replace_seperator(job_cur_rec.ship_method)|| field_seperator ||
                job_cur_rec.share_supply || field_seperator ||
                job_cur_rec.EPSD || field_seperator ||
                job_cur_rec.EPCD || field_seperator ||
                job_cur_rec.UEPSD || field_seperator ||
                job_cur_rec.UEPCD || field_seperator ||
                job_cur_rec.ULPSD || field_seperator ||
                job_cur_rec.ULPCD ;

       fetchDemandData(p_plan_id, p_instance_id, p_transaction_id,
                   job_cur_rec.org_id, v_demand);
    elsif p_type = RES_NODE then
       OPEN res_cur;
       FETCH res_cur INTO res_cur_rec;
       CLOSE res_cur;
       v_pro := replace_seperator(res_cur_rec.item) || field_seperator ||
                res_cur_rec.op_seq || field_seperator ||
                replace_seperator(res_cur_rec.org) || field_seperator ||
                replace_seperator(res_cur_rec.dept_code) || field_seperator ||
                replace_seperator(res_cur_rec.job_name) || field_seperator ||
                res_cur_rec.assigned_units || field_seperator ||
                res_cur_rec.firm_flag || field_seperator ||
                res_cur_rec.alternate_num || field_seperator ||
                res_cur_rec.res_seq_num || field_seperator ||
                replace_seperator(res_cur_rec.res_code) || field_seperator ||
                res_cur_rec.resource_hours || field_seperator ||
                res_cur_rec.mtq_time|| field_seperator ||
                res_cur_rec.batchable || field_seperator ||
                res_cur_rec.batch_number|| field_seperator ||
                res_cur_rec.uom|| field_seperator ||
                res_cur_rec.basis_type || field_seperator ||
                res_cur_rec.schedule_flag || field_seperator ||
                res_cur_rec.EPSD || field_seperator ||
                res_cur_rec.EPCD || field_seperator ||
                res_cur_rec.UEPSD || field_seperator ||
                res_cur_rec.UEPCD || field_seperator ||
                res_cur_rec.ULPSD || field_seperator ||
                res_cur_rec.ULPCD;

       fetchDemandData(p_plan_id, p_instance_id, res_cur_rec.trans_id,
                       res_cur_rec.org_id, v_demand);
    end if;

END get_property;

Procedure init IS
BEGIN

    peg_data.parent_index.delete;
    peg_data.next_record.delete;
    peg_data.org_id.delete;
    peg_data.transaction_id.delete;
    peg_data.instance_id.delete;
    peg_data.department_id.delete;
    peg_data.op_seq.delete;
    peg_data.type.delete;
    peg_data.path.delete;
    peg_data.name.delete;
    peg_data.firm_flag.delete;
    peg_data.start_date.delete;
    peg_data.end_date.delete;
    peg_data.status.delete;
    peg_data.applied.delete;
    peg_data.res_firm_flag.delete;
    peg_data.late_flag.delete;
    peg_data.early_start_date.delete;
    peg_data.early_end_date.delete;
    peg_data.u_early_start_date.delete;
    peg_data.u_early_end_date.delete;
    peg_data.latest_start_date.delete;
    peg_data.latest_end_date.delete;
    peg_data.min_start_date.delete;
    peg_data.critical_flag.delete;
    peg_data.supply_type.delete;
    peg_data.new_path.delete;
    the_index :=0;
    g_end_demand_id := null;

END init;


Procedure fetchSupplierLoadData(p_plan_id number,
                                   p_supplier_list varchar2,
                                   p_start varchar2 default null,
                                   p_end varchar2 default null,
                                   v_require_data IN OUT NOCOPY maxCharTbl,
                                   v_avail_data IN OUT NOCOPY maxCharTbl) IS
  v_org_id number;
  v_instance_id number;
  v_item_id number;
  v_supplier_id number;
  v_len number;
  one_record varchar2(100);
  i number:=1;
  j number:=1;
  k number:=0;
  n number:=0;
  a number;
  b number;
  c number;
  oneBigRecord maxCharTbl := maxCharTbl(0);
  recCount number :=0;
  TYPE date_arr IS TABLE OF date;
  v_req_start date_arr := date_arr(sysdate);
  v_req_end date_arr:= date_arr(sysdate);
  v_req_qty number_arr:= number_arr(0);
  v_req_qty_unmet number_arr:= number_arr(0);
  v_avail_start date_arr:= date_arr(sysdate);
  v_avail_end date_arr:= date_arr(sysdate);
  v_avail_qty number_arr:= number_arr(0);
  v_max_len number;
  v_one_record varchar2(200);
  p_start_date date;
  p_end_date date;
  v_cum_qty number;
  v_bkt_start date_arr;
  v_bkt_end date_arr;
  v_start date_arr;
  v_end date_arr;
  v_qty number_arr;
  v_bkt_qty number;
  cursor start_date_cur is
  select  nvl(trunc(mis.SUPPLIER_LEAD_TIME_DATE +1),
              trunc(mp.plan_start_date+2))
    from msc_item_suppliers mis,
         msc_plans mp
   where mis.plan_id = mp.plan_id
      and mis.inventory_item_id = v_item_id
      and mis.sr_instance_id = v_instance_id
      and mis.supplier_id = v_supplier_id
      and mis.organization_id = v_org_id
      and mp.plan_id = p_plan_id;

  p_promise_date_profile number :=
     nvl(FND_PROFILE.Value('MSC_PO_DOCK_DATE_CALC_PREF'),1);
  v_lead_time_date date;
BEGIN

    p_start_date := to_date(p_start,format_mask);
    p_end_date := to_date(p_end,format_mask);

    select mpb.bkt_start_date,mpb.bkt_end_date
     BULK COLLECT INTO v_bkt_start, v_bkt_end
    from msc_plan_buckets mpb,
         msc_plans mp
    where mp.plan_id =p_plan_id
    and mpb.plan_id = mp.plan_id
    and mpb.organization_id = mp.organization_id
    and mpb.sr_instance_id = mp.sr_instance_id
    and ( mpb.bkt_start_date between p_start_date and p_end_date
          or
          mpb.bkt_end_date between p_start_date and p_end_date )
    and mpb.bucket_type <> 1
    order by 1;

 -- parse the supplier_list
 -- the format of supplier_list is
 -- (instance_id, org_id,item_id, supplier_id)
 v_len := length(p_supplier_list);
 while v_len > 0 LOOP
    one_record :=
      substr(p_supplier_list,instr(p_supplier_list,'(',1,i)+1,
               instr(p_supplier_list,')',1,i)-instr(p_supplier_list,'(',1,i)-1);

    v_instance_id := to_number(substr(one_record,1,instr(one_record,',')-1));

    v_org_id := to_number(substr(one_record,instr(one_record,',',1,1)+1,
                       instr(one_record,',',1,2)-instr(one_record,',',1,1)-1));

    v_item_id := to_number(substr(one_record,instr(one_record,',',1,2)+1
                      ,instr(one_record,',',1,3)-instr(one_record,',',1,2)-1));

    v_supplier_id := to_number(substr(one_record,instr(one_record,',',1,3)+1));

    OPEN start_date_cur;
    FETCH start_date_cur INTO v_lead_time_date;
    CLOSE start_date_cur;
    select
           mca.calendar_date, mca.calendar_date+1, msc.capacity
    bulk collect into v_start, v_end, v_qty
    from msc_calendar_dates mca,
         msc_plans mp,
         msc_trading_partners mtp,
         msc_supplier_capacities msc
    where msc.plan_id = p_plan_id
      and msc.inventory_item_id = v_item_id
      and msc.sr_instance_id = v_instance_id
      and msc.supplier_id = v_supplier_id
      and msc.organization_id = v_org_id
      and msc.capacity > 0
      and msc.from_date <=p_end_date
      and msc.to_date >=v_lead_time_date
      and mp.plan_id = msc.plan_id
      and mtp.sr_tp_id = mp.organization_id
      and mtp.sr_instance_id = mp.sr_instance_id
      and mtp.partner_type =3
      and mca.sr_instance_id= mtp.sr_instance_id
      and mca.calendar_code = mtp.calendar_code
      and mca.exception_set_id = mtp.calendar_exception_set_id
      and mca.calendar_date between msc.from_date and msc.to_date
      and mca.seq_num is not null
     order by msc.transaction_id,msc.from_date, msc.to_date;

    c :=1;
    -- daily bkt
     for a in 1 .. v_start.count loop
       if (v_bkt_start.count = 0 or
           v_end(a) <= v_bkt_start(1)) and
          v_start(a) >= v_lead_time_date then
          v_avail_start.extend;
          v_avail_end.extend;
          v_avail_qty.extend;
          v_avail_start(c) := v_start(a);
          v_avail_end(c) := v_end(a);
          v_avail_qty(c) := v_qty(a);
          c := c+1;
        end if;
      end loop;

    -- weekly and period bkt
      for b in 1..v_bkt_start.count loop
        v_bkt_qty :=0;
        for a in 1 .. v_start.count loop
            if  v_start(a) >= v_lead_time_date and
                v_start(a) >= v_bkt_start(b) and
                v_end(a) <= v_bkt_end(b) then
                v_bkt_qty := v_bkt_qty + v_qty(a);
             end if;
        end loop;
        if v_bkt_qty > 0 then
           v_avail_start.extend;
           v_avail_end.extend;
           v_avail_qty.extend;
           v_avail_start(c) := v_bkt_start(b);
           v_avail_end(c) := v_bkt_end(b);
           v_avail_qty(c) := v_bkt_qty;
           c := c+1;
         end if;
      end loop;

    select trunc(ms.new_dock_date), trunc(ms.new_dock_date)+1,
           ms.new_order_quantity
    bulk collect into v_start, v_end, v_qty
      from msc_supplies ms
     where ms.plan_id = p_plan_id
      and ms.inventory_item_id = v_item_id
      and ms.sr_instance_id = v_instance_id
      and ms.supplier_id = v_supplier_id
      and ms.organization_id = v_org_id
      and ms.new_dock_date <= p_end_date
      and (ms.order_type <> 1 -- not for PO
           or
           (ms.order_type = 1 and
            ms.promised_date is null and
            p_promise_date_profile = 1))  -- promised_date
     order by ms.new_dock_date;

    oneBigRecord.delete;
    oneBigRecord.extend;
    recCount :=0;
    j :=1;
    c :=0;
    -- daily bkt
     for a in 1 .. v_start.count loop
       if v_bkt_start.count = 0 or
          v_end(a) <= v_bkt_start(1) then
          v_req_start.extend;
          v_req_end.extend;
          v_req_qty.extend;
          v_req_qty_unmet.extend;
          v_req_start(a) := v_start(a);
          v_req_end(a) := v_end(a);
          v_req_qty(a) := v_qty(a);
          v_req_qty_unmet(a) := v_qty(a);
          c := a;
        end if;
      end loop;
    -- weekly and period bkt
      for b in 1..v_bkt_start.count loop
        v_bkt_qty :=0;
        for a in 1 .. v_start.count loop

            if  v_start(a) >= v_bkt_start(b) and
                v_end(a) <= v_bkt_end(b) then
                v_bkt_qty := v_bkt_qty + v_qty(a);
             end if;
        end loop;
        if v_bkt_qty > 0 then
           c := c+1;
           v_req_start.extend;
           v_req_end.extend;
           v_req_qty.extend;
           v_req_qty_unmet.extend;
           v_req_start(c) := v_bkt_start(b);
           v_req_end(c) := v_bkt_end(b);
           v_req_qty(c) := v_bkt_qty; --v_bkt_qty/(v_bkt_end(b) - v_bkt_start(b));
           v_req_qty_unmet(c) := v_req_qty(c);
         end if;
      end loop;

-- get the actual req
     for b in 1 .. v_req_start.count-1 loop
         if v_req_end(b) >= p_start_date then
            v_one_record :=
                      to_char(v_req_start(b),format_mask) ||
                      field_seperator ||
                      to_char(v_req_end(b),format_mask) ||
                      field_seperator ||
                      v_req_qty(b);
            v_max_len := nvl(length(oneBigRecord(j)),0) +
                            nvl(length(v_one_record),0);
            if v_max_len > 30000 then
                     j := j+1;
                     oneBigRecord.extend;
            end if;

            oneBigRecord(j) := oneBigRecord(j) || field_seperator ||
                          v_one_record;
            recCount := recCount+1;
          end if;
      end loop;



    v_require_data.extend;
    k := k+1;
    if i = 1 then -- not the first record
       v_require_data(k) := to_char(i-1) || field_seperator ||
                            recCount;
    else
       v_require_data(k) := record_seperator ||
                            to_char(i-1) || field_seperator ||
                            recCount;
    end if;

    for j in 1 .. oneBigRecord.count loop
      if j = 1 then
         v_require_data(k) := v_require_data(k) || oneBigRecord(j);
      else
          v_require_data.extend;
          k := k+1;
          v_require_data(k) := oneBigRecord(j);
      end if;
    end loop;

    j := 1;
    oneBigRecord.delete;
    oneBigRecord.extend;
    recCount :=0;
    v_cum_qty :=0;

-- calculate the net accumulative supplier capacity
-- req will use the capacity which is before the req date, but not after

-- found the net accumulative avail qty
      for b in 1 .. v_avail_start.count loop
            v_cum_qty := v_cum_qty + v_avail_qty(b);
            for a in 1.. v_req_start.count-1 loop
                if v_avail_start(b) <= v_req_start(a) and
                   v_req_qty_unmet(a) > 0 and
                   v_cum_qty > 0 then
                   if v_cum_qty >= v_req_qty_unmet(a) then
                       v_cum_qty := v_cum_qty -v_req_qty_unmet(a);
                       v_req_qty_unmet(a) := 0;
                   else
                       v_req_qty_unmet(a) := v_req_qty_unmet(a) - v_cum_qty;
                       v_cum_qty := 0;
                   end if;

                end if;
            end loop; -- end of v_req_start loop
            v_avail_qty(b):= v_cum_qty;
      end loop; -- end of v_avail loop

    -- pad up net avail qty with req met qty so it won't be overload in chart
      for b in 1 .. v_req_start.count loop
          if v_req_end(b) >= p_start_date and
             v_req_qty_unmet(b) < v_req_qty(b) then
            v_bkt_qty := v_req_qty(b)-v_req_qty_unmet(b);
            v_one_record :=
                      to_char(v_req_start(b),format_mask) ||
                      field_seperator ||
                      to_char(v_req_end(b),format_mask) ||
                      field_seperator ||
                      v_bkt_qty;

            v_max_len := nvl(length(oneBigRecord(j)),0) +
                            nvl(length(v_one_record),0);
            if v_max_len > 30000 then
                     j := j+1;
                     oneBigRecord.extend;
            end if;

            oneBigRecord(j) := oneBigRecord(j) || field_seperator ||
                          v_one_record;
            recCount := recCount +1;
        end if;
      end loop;

      for b in 1 .. v_avail_start.count loop
          if v_avail_end(b) >= p_start_date then
            v_one_record :=
                      to_char(v_avail_start(b),format_mask) ||
                      field_seperator ||
                      to_char(v_avail_end(b),format_mask) ||
                      field_seperator ||
                      v_avail_qty(b);

            v_max_len := nvl(length(oneBigRecord(j)),0) +
                            nvl(length(v_one_record),0);
            if v_max_len > 30000 then
                     j := j+1;
                     oneBigRecord.extend;
            end if;

            oneBigRecord(j) := oneBigRecord(j) || field_seperator ||
                          v_one_record;
            recCount := recCount +1;
        end if;
      end loop;
    v_avail_data.extend;
    n := n+1;
    if i = 1 then -- not the first record
       v_avail_data(n) := to_char(i-1) || field_seperator ||
                            recCount;
    else
       v_avail_data(n) := record_seperator ||
                            to_char(i-1) || field_seperator ||
                            recCount;
    end if;

    for j in 1 .. oneBigRecord.count loop
      if j = 1 then
         v_avail_data(n) := v_avail_data(n) || oneBigRecord(j);
      else
          v_avail_data.extend;
          n := n+1;
          v_avail_data(n) := oneBigRecord(j);
      end if;
    end loop;


    v_req_start.delete;
    v_req_end.delete;
    v_req_qty.delete;
    v_req_qty_unmet.delete;

    i := i+1;
    v_len := v_len - length(one_record)-3;
 END LOOP;

END fetchSupplierLoadData;

Procedure fetchLateDemandData(p_plan_id number, p_demand_id number,
                              p_critical number default -1) IS
   CURSOR end_demand_cur IS
    select md.organization_id,
           md.demand_id, md.sr_instance_id,
           nvl(md.order_number,
               nvl(msc_get_name.designator(md.schedule_designator_id),
                   md.demand_id)) ||' for '||
               mi.item_name ||
               ' in ' || mtp.organization_code ||'('||
               md.using_requirement_quantity||')',
           to_char(md.using_assembly_demand_date,format_mask),
           to_char(nvl(md.dmd_satisfied_date,md.using_assembly_demand_date),format_mask),
           demand_priority
    from  msc_demands md,
          msc_items mi,
          msc_trading_partners mtp
    where md.demand_id = p_demand_id
      and md.plan_id = p_plan_id
      and mi.inventory_item_id = md.inventory_item_id
      and mtp.partner_type =3
      and mtp.sr_tp_id = md.organization_id
      and mtp.sr_instance_id = md.sr_instance_id;

   CURSOR end_peg_cur IS
    select distinct ms.organization_id,
           ms.transaction_id, ms.sr_instance_id,
           msc_get_gantt_data.order_number(ms.order_type,ms.order_number,
                         ms.plan_id, ms.sr_instance_id,
                         ms.transaction_id, ms.disposition_id)||' for '||
               msi.item_name ||
               ' in ' || mtp.organization_code ||'('||
               ms.new_order_quantity||')',
           msc_get_gantt_data.isSupplyLate(ms.plan_id,ms.sr_instance_id,
                  ms.organization_id,ms.inventory_item_id,ms.transaction_id),
           msc_get_gantt_data.actualStartDate(ms.order_type,
                                           msi.planning_make_buy_code,
                                           ms.organization_id,
                                           ms.source_organization_id,
                                           ms.new_dock_date,
                                           ms.new_wip_start_date,
                                           ms.new_ship_date,
                                           ms.new_schedule_date),
           nvl(to_char(ms.new_schedule_date,format_mask),'null'),
           nvl(to_char(ms.EARLIEST_START_DATE,format_mask),'null'),
           nvl(to_char(ms.EARLIEST_COMPLETION_DATE,format_mask),'null'),
           nvl(to_char(ms.ULPSD,format_mask),'null'),
           nvl(to_char(ms.ULPCD,format_mask),'null'),
           nvl(to_char(ms.UEPSD,format_mask),'null'),
           nvl(to_char(ms.UEPCD,format_mask),'null'),
           nvl(to_char(ms.MIN_START_DATE,format_mask), 'null'),
           msc_get_gantt_data.isCriticalSupply(p_plan_id,g_end_demand_id,
                ms.transaction_id, ms.sr_instance_id),
           msc_get_gantt_data.supplyType(ms.order_type,
                                           msi.planning_make_buy_code,
                                           ms.organization_id,
                                           ms.source_organization_id),
           mtp.organization_code ||':'||msi.item_name,
           ms.inventory_item_id,
           nvl(ms.supplier_id,-1)
    from  msc_full_pegging mfp,
          msc_supplies ms,
          msc_system_items msi,
          msc_trading_partners mtp
    where mfp.demand_id = p_demand_id
      and mfp.plan_id = p_plan_id
      and msi.plan_id = ms.plan_id
      and msi.organization_id = ms.organization_id
      and msi.sr_instance_id = ms.sr_instance_id
      and msi.inventory_item_id = ms.inventory_item_id
      and mtp.partner_type =3
      and mtp.sr_tp_id = ms.organization_id
      and mtp.sr_instance_id = ms.sr_instance_id
      and ms.plan_id = mfp.plan_id
      and ms.transaction_id = mfp.transaction_id
      and ms.sr_instance_id = mfp.sr_instance_id
      order by ms.transaction_id;

   i number;
   TYPE char_arr IS TABLE OF varchar2(300);
   curr_org_id number_arr;
   curr_trans_id number_arr;
   curr_inst_id number_arr;
   curr_name char_arr;
   curr_late_flag number_arr;
   curr_start_date char_arr;
   curr_end_date char_arr;
   curr_early_start_date char_arr;
   curr_early_end_date char_arr;
   curr_latest_start_date char_arr;
   curr_latest_end_date char_arr;
   curr_u_early_start_date char_arr;
   curr_u_early_end_date char_arr;
   curr_min_start_date char_arr;
   curr_critical_flag number_arr;
   curr_supply_type number_arr;
   curr_supplier_id number_arr;
   curr_item_id number_arr;
   curr_org_code char_arr;
BEGIN

  msc_get_gantt_data.init;
  g_end_demand_id := p_demand_id;

  -- for order centric view
   if g_supply_query_id is not null then
      delete msc_form_query
      where query_id = g_supply_query_id;
   else
      select msc_form_query_s.nextval
       into g_supply_query_id
        from dual;
   end if;
  -- for resource centric view
   if g_res_query_id is not null then
      delete msc_form_query
      where query_id = g_res_query_id;
   else
      select msc_form_query_s.nextval
       into g_res_query_id
        from dual;
   end if;
  -- for supplier list
   if g_supplier_query_id is not null then
      delete msc_form_query
      where query_id = g_supplier_query_id;
   else
      select msc_form_query_s.nextval
       into g_supplier_query_id
        from dual;
   end if;

  i :=the_index;
  OPEN end_demand_cur;
  FETCH end_demand_cur into    peg_data.org_id(i),
                               peg_data.transaction_id(i),
                               peg_data.instance_id(i),
                               peg_data.name(i),
                               peg_data.start_date(i),
                               peg_data.end_date(i),
                               g_dmd_priority;
  CLOSE end_demand_cur;
        peg_data.type(i) := END_DEMAND_NODE;
        peg_data.parent_index(i) := -1;
        peg_data.next_record(i) := -1;
        peg_data.path(i) := to_char(i);
        peg_data.new_path(i) := peg_data.path(i);
  i := i+1;
  OPEN end_peg_cur;
  FETCH end_peg_cur bulk collect into
                        curr_org_id, curr_trans_id,
                        curr_inst_id, curr_name,
                        curr_late_flag, curr_start_date,
                        curr_end_date, curr_early_start_date,
                        curr_early_end_date, curr_latest_start_date,
                        curr_latest_end_date, curr_u_early_start_date,
                        curr_u_early_end_date, curr_min_start_date,
                        curr_critical_flag, curr_supply_type,
                        curr_org_code, curr_item_id, curr_supplier_id;
  CLOSE end_peg_cur;
  For a in 1.. curr_org_id.count loop
    if (p_critical = 0 and curr_critical_flag(a)=0) or
       (p_critical = 1 and curr_critical_flag(a) >= 0) or
       (p_critical = -1) then
        peg_data.org_id(i) := curr_org_id(a);
        peg_data.transaction_id(i) := curr_trans_id(a);
        peg_data.instance_id(i) := curr_inst_id(a);
        peg_data.name(i) := curr_name(a);
        peg_data.late_flag(i) := curr_late_flag(a);
        peg_data.start_date(i) := curr_start_date(a);
        peg_data.end_date(i) := curr_end_date(a);
        peg_data.early_start_date(i) := curr_early_start_date(a);
        peg_data.early_end_date(i) := curr_early_end_date(a);
        peg_data.u_early_start_date(i) := curr_u_early_start_date(a);
        peg_data.u_early_end_date(i) := curr_u_early_end_date(a);
        peg_data.latest_start_date(i) := curr_latest_start_date(a);
        peg_data.latest_end_date(i) := curr_latest_end_date(a);
        peg_data.min_start_date(i) := curr_min_start_date(a);
        peg_data.critical_flag(i)  := curr_critical_flag(a);
        peg_data.supply_type(i)  := curr_supply_type(a);
        peg_data.type(i) := JOB_NODE;
        peg_data.parent_index(i) := -1;
        peg_data.next_record(i) := -1;
        peg_data.path(i) := '0-'||to_char(i-1);
        peg_data.new_path(i) := peg_data.path(i);
        if i>0 then
           peg_data.next_record(i-1) := i;
        end if;
        i := i+1;

        -- for order centric view

             insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,
                        NUMBER2)
                values (
                        g_supply_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                         curr_trans_id(a),
                         curr_inst_id(a));

         if curr_supplier_id(a) <> -1 then
            -- for supplier list
             insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1,
                        NUMBER2,
                        NUMBER3,
                        NUMBER4,
                        char1)
                values (
                        g_supplier_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                         curr_supplier_id(a),
                         curr_org_id(a),
                         curr_inst_id(a),
                         curr_item_id(a),
                         curr_org_code(a));
             end if;

    end if;
  END LOOP;
  the_index := i;
  msc_get_gantt_data.explode_children(p_plan_id, p_critical);

END fetchLateDemandData;


Procedure fetchAllSupplier(p_plan_id number,
                                   v_name OUT NOCOPY varchar2) IS
  oneRecord varchar2(32000);
  rowCount number:=0;
    TYPE char_arr IS TABLE OF varchar2(255);
   v_org_code char_arr;
   v_supplier_name char_arr;
   v_org number_arr;
   v_instance number_arr;
   v_item number_arr;
   v_supplier number_arr;

BEGIN
    oneRecord := null;
    rowCount := 0;
        select distinct
           mfq.char1,
           mtp.partner_name,
           mfq.number2,
           mfq.number3,
           mfq.number4,
           mfq.number1
       bulk collect into
           v_org_code, v_supplier_name,
                     v_org, v_instance, v_item, v_supplier
                       FROM msc_trading_partners mtp,
                            msc_form_query mfq
                      where mfq.query_id = g_supplier_query_id
                        AND mtp.partner_type = 1
                        AND mtp.partner_id = mfq.number1
                        ORDER BY 1,2 ;
     for a in 1..v_org_code.count loop
          v_supplier_name(a) := replace_seperator(v_supplier_name(a));
          oneRecord := oneRecord || record_seperator ||
                          replace_seperator(v_org_code(a)) ||':'||
                          v_supplier_name(a) || field_seperator ||
                          v_org(a) || field_seperator ||
                          v_instance(a) || field_seperator ||
                          v_item(a) || field_seperator ||
                          v_supplier(a);
    end loop;

     rowCount := v_org_code.count;

     v_name := rowCount || oneRecord;
END fetchAllSupplier;

Procedure fetchAllLateDemand(p_plan_id number,
                             p_demand_id number,
                                   v_name OUT NOCOPY varchar2) IS
  oneRecord varchar2(32000);
  rowCount number:=0;
    TYPE char_arr IS TABLE OF varchar2(600);
    TYPE dummy_date_arr IS TABLE OF date;
   v_order_name char_arr;
   v_demand_id number_arr;
   v_dummy_date dummy_date_arr;

BEGIN
    oneRecord := null;
    rowCount := 0;
        select distinct
               md.demand_id,
               nvl(md.order_number,
                   msc_get_name.designator(md.schedule_designator_id))
               ||'('||md.using_assembly_demand_date||','||
                      md.USING_REQUIREMENT_QUANTITY||')'  ,
               md.using_assembly_demand_date
       bulk collect into v_demand_id, v_order_name , v_dummy_date
                       FROM
                            msc_exception_details med,
                            msc_demands md,
                            msc_demands md2
                      where md2.plan_id = p_plan_id
                        and md2.demand_id = p_demand_id
                        and med.plan_id = md2.plan_id
                        and med.organization_id = md2.organization_id
                        and med.sr_instance_id = md2.sr_instance_id
                        and med.inventory_item_id = md2.inventory_item_id
                        and med.exception_type in (24,26)
                        and md.plan_id = med.plan_id
                        and md.demand_id = med.number1
                        order by md.using_assembly_demand_date ;


     for a in 1..v_order_name.count loop
          oneRecord := oneRecord || record_seperator ||
                      replace_seperator(v_order_name(a))|| field_seperator ||
                          v_demand_id(a) ;
    end loop;

     rowCount := v_order_name.count;

     v_name := rowCount || oneRecord;
END fetchAllLateDemand;

Function isCriticalSupply(p_plan_id number,
                          p_end_demand_id number,
                          p_transaction_id number,
                          p_inst_id number) Return number IS
  isCritical number :=-1;

  CURSOR critical_cur is
     select nvl(path_number,1)
       from msc_critical_paths
      where plan_id = p_plan_id
      and supply_id = p_transaction_id
      and sr_instance_id = p_inst_id
      and demand_id = p_end_demand_id
--      and routing_sequence_id is null
;

Begin
    OPEN critical_cur;
    FETCH critical_cur into isCritical;
    CLOSE critical_cur;

    return isCritical;
END isCriticalSupply;

Function isCriticalRes(p_plan_id number,
                          p_end_demand_id number,
                          p_transaction_id number,
                          p_inst_id number,
                          p_operation_seq_id number,
                          p_routing_seq_id number) Return number IS
  isCritical number :=-1;

  CURSOR critical_cur is
     select nvl(path_number,1)
       from msc_critical_paths
      where plan_id = p_plan_id
      and supply_id = p_transaction_id
      and sr_instance_id = p_inst_id
      and demand_id = p_end_demand_id
      and nvl(routing_sequence_id,-1) = nvl(p_routing_seq_id,-1)
      and operation_sequence_id = p_operation_seq_id;

Begin
    OPEN critical_cur;
    FETCH critical_cur into isCritical;
    CLOSE critical_cur;

    return isCritical;
END isCriticalRes;

Function supplyType(p_order_type number, p_make_buy_code number,
                    p_org_id number,p_source_org_id number) return number is
  p_supply_type number;
BEGIN
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

END supplyType;

Function actualStartDate(p_order_type number, p_make_buy_code number,
                         p_org_id number,p_source_org_id number,
                         p_dock_date date, p_wip_start_date date,
                         p_ship_date date, p_schedule_date date)
  return varchar2 is
  p_actual_start_date date;
  p_date varchar2(20);
  p_supply_type number;
BEGIN
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

END actualStartDate;

Function fetchSupplierPriority(p_plan_id number,
                               p_instance_id number,
                               p_org_id number,
                               p_item_id number,
                               p_supplier_id number,
                               p_start varchar2,
                               p_end varchar2) return varchar2 is
  p_start_date date:= to_date(p_start,format_mask);
  p_end_date date:= to_date(p_end,format_mask);
  v_qty number_arr;
  v_id number_arr;
  v_firm_qty number :=0;
  v_lower_qty number :=0;
  v_same_qty number :=0;
  v_higher_qty number :=0;
  b number;
  p_promise_date_profile number :=
     nvl(FND_PROFILE.Value('MSC_PO_DOCK_DATE_CALC_PREF'),1);
BEGIN

 if g_dmd_priority is null then
    g_dmd_priority :=0;
 end if;

 if trunc(p_start_date) = trunc(p_end_date) then
    p_end_date := p_end_date +1;
 end if;
   -- supplier requirements
    select decode(ms.firm_planned_type, 1, -1,
             msc_get_gantt_data.get_dmd_priority(
             ms.plan_id, ms.sr_instance_id, ms.transaction_id)),
           ms.new_order_quantity
    bulk collect into v_id,v_qty
      from msc_supplies ms
     where ms.plan_id = p_plan_id
      and ms.inventory_item_id = p_item_id
      and ms.sr_instance_id = p_instance_id
      and ms.supplier_id = p_supplier_id
      and ms.organization_id = p_org_id
      and trunc(ms.new_dock_date) >= trunc(p_start_date)
      and trunc(ms.new_dock_date) < trunc(p_end_date)
      and (ms.order_type <> 1 -- not for PO
           or
           (ms.order_type = 1 and
            ms.promised_date is null and
            p_promise_date_profile = 1));  -- promised_date
     for b in 1 .. v_id.count loop
            if v_id(b) = -1 then -- firm
               v_firm_qty := v_firm_qty + v_qty(b);
            elsif v_id(b) > g_dmd_priority then
               v_lower_qty := v_lower_qty + v_qty(b);
            elsif v_id(b) < g_dmd_priority then
               v_higher_qty := v_higher_qty + v_qty(b);
            else
               v_same_qty := v_same_qty + v_qty(b);
            end if;
      end loop;

      return
             v_lower_qty || field_seperator ||
             v_same_qty || field_seperator ||
             v_higher_qty|| field_seperator ||
             v_firm_qty ;

END fetchSupplierPriority;

Function fetchResourcePriority(p_plan_id number,
                               p_instance_id number,
                               p_org_id number,
                               p_dept_id number,
                               p_resource_id number,
                               p_start varchar2,
                               p_end varchar2) return varchar2 is
  p_start_date date:= trunc(to_date(p_start,format_mask));
  p_end_date date:= trunc(to_date(p_end,format_mask));
  v_qty number_arr;
  v_id number_arr;
  v_lower_qty number :=0;
  v_same_qty number :=0;
  v_higher_qty number :=0;
  v_firm_qty number :=0;
  b number;
  v_bkt_size number;
BEGIN

 if g_dmd_priority is null then
    g_dmd_priority :=0;
 end if;

 if p_start_date = p_end_date then
    p_end_date := p_start_date +1;
    v_bkt_size := 1;
 else
    v_bkt_size := p_end_date - p_start_date;
 end if;
   -- requirements
    select decode(ms.firm_planned_type, 1, -1,
             msc_get_gantt_data.get_dmd_priority(
             mrr.plan_id, mrr.sr_instance_id, mrr.supply_id)),
             mrr.resource_hours/24/v_bkt_size
    bulk collect into v_id,v_qty
      from msc_resource_requirements mrr,
           msc_supplies ms
     where mrr.plan_id = p_plan_id
      and mrr.department_id = p_dept_id
      and mrr.sr_instance_id = p_instance_id
      and mrr.resource_id = p_resource_id
      and mrr.organization_id = p_org_id
      and mrr.parent_id =1
      and mrr.resource_hours > 0
      and mrr.end_date is not null
      and mrr.start_date <= g_cutoff_date
      and mrr.start_date < trunc(p_end_date)
      and mrr.start_date >= trunc(p_start_date)
      and mrr.plan_id = ms.plan_id
      and mrr.supply_id = ms.transaction_id
      and mrr.sr_instance_id = ms.sr_instance_id;

     for b in 1 .. v_id.count loop
            if v_id(b) = -1 then -- firm
               v_firm_qty := v_firm_qty + v_qty(b);
            elsif v_id(b) > g_dmd_priority then
               v_lower_qty := v_lower_qty + v_qty(b);
            elsif v_id(b) < g_dmd_priority then
               v_higher_qty := v_higher_qty + v_qty(b);
            else
               v_same_qty := v_same_qty + v_qty(b);
            end if;
      end loop;

      if v_lower_qty <> 0 then
        v_lower_qty := greatest(round(v_lower_qty,2),0.01);
      end if;

      if v_same_qty <> 0 then
        v_same_qty := greatest(round(v_same_qty,2),0.01);
      end if;

      if v_higher_qty <> 0 then
        v_higher_qty := greatest(round(v_higher_qty,2),0.01);
      end if;

      if v_firm_qty <> 0 then
        v_firm_qty := greatest(round(v_firm_qty,2),0.01);
      end if;

      return
             v_lower_qty || field_seperator ||
             v_same_qty || field_seperator ||
             v_higher_qty || field_seperator ||
             v_firm_qty;

END fetchResourcePriority;

Function get_dmd_priority(p_plan_id number,
                          p_instance_id number,
                          p_transaction_id number) return number is
  CURSOR dmd_cur IS
  SELECT min(md.demand_priority)
  FROM msc_demands md,
       msc_full_pegging mfp2,
       msc_full_pegging mfp1
  WHERE mfp1.plan_id = p_plan_id
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

BEGIN
  if p_transaction_id is null or
     p_plan_id is null or
     p_instance_id is null then
     return null;
  end if;
  Open dmd_cur;
  Fetch dmd_cur Into l_priority;
  Close dmd_cur;

  return(l_priority);

END get_dmd_priority;

Procedure start_fetch(p_fetch_type IN varchar2,
                      v_return_data OUT NOCOPY varchar2,
                      start_index OUT NOCOPY number) is
  startParentIndex number;
  i number :=0;
  v_one_record varchar2(30000);
begin
 if p_fetch_type is null then -- start from beginning
    g_current_block := 1;
    g_block_start_row.delete;
    g_block_start_row.extend;
    g_block_start_row(1) :=0;
 elsif p_fetch_type = 'PREV' then
    g_current_block := g_current_block -1;
 elsif p_fetch_type = 'NEXT' then
    g_current_block := g_current_block +1;
 elsif p_fetch_type = 'CURRENT' then
    g_current_block := nvl(g_current_block, 1);
 end if;

  if p_fetch_type = 'NEXT' or p_fetch_type is null then
    g_block_start_row.extend;
    g_block_start_row(g_current_block+1) := null;
  end if;
  g_supply_rec_count :=0;

 -- find the parent node of the start node
  start_index := g_block_start_row(g_current_block);

  startParentIndex := peg_data.parent_index(start_index);

  -- find all the parent nodes of the start node
  if startParentIndex is not null and
     startParentIndex > 0 then
    i := startParentIndex;
    while i is not null and i > 0 loop

        v_one_record := i||field_seperator ||
                        peg_data.parent_index(i) ||field_seperator ||
                        msc_get_gantt_data.modify_parent_path(i) ||field_seperator ||
                        print_one_record(i);
        if v_return_data is null then
           v_return_data := v_one_record;
        else
           v_return_data := v_one_record || record_seperator || v_return_data;
        end if;
        g_supply_rec_count := g_supply_rec_count +1;
        i := peg_data.parent_index(i);
     end loop;

        v_one_record := print_one_record(0);
        v_return_data :=  record_seperator || v_one_record ||
                          record_seperator || v_return_data;
        g_supply_rec_count := g_supply_rec_count +1;

     if g_current_block >1 then -- add prev node
        v_one_record := msc_get_gantt_data.modify_parent_path(
                            start_index)
            || field_seperator ||
           PREV_NODE || field_seperator ||
           -1 ||field_seperator ||
           'Previous '||g_supply_limit||field_seperator ||
           -1 ||field_seperator ||
           -1 ||field_seperator||0;
        v_return_data := v_return_data||record_seperator || v_one_record;
      end if;
   end if;

end start_fetch;

Function get_new_result(start_index IN number,
                        v_return_data OUT NOCOPY varchar2,
                              next_index OUT NOCOPY number)
 return boolean IS
  v_one_record varchar2(2000);
  v_len number :=0;
  i number;
Begin

  i := start_index;

  if peg_data.parent_index.count > 0 and
     i < peg_data.parent_index.count  and
     g_supply_rec_count < g_supply_limit then
     g_supply_parentIndex := peg_data.parent_index(i);
     while i is not null and g_supply_rec_count < g_supply_limit loop
          if g_supply_parentIndex <> peg_data.parent_index(i) then
             g_supply_childIndex :=0;
             g_supply_parentIndex := peg_data.parent_index(i);
          end if;

          if g_supply_parentIndex >0 then
             peg_data.new_path(i) :=
               peg_data.new_path(g_supply_parentIndex) ||'-'||
                                 g_supply_childIndex;
          end if;

          v_one_record :=  i||field_seperator ||
                        peg_data.parent_index(i) ||field_seperator ||
                        peg_data.new_path(i) ||field_seperator ||
                        print_one_record(i);
          v_len := nvl(length(v_return_data),0) + nvl(length(v_one_record),0);

          if v_len < 1000 then
            v_return_data := v_return_data || record_seperator || v_one_record;
            g_supply_rec_count := g_supply_rec_count +1;
            next_index := i+1;
            i := peg_data.parent_index.next(i);
            g_supply_childIndex := g_supply_childIndex +1;
          else
            exit;
          end if;
     end loop;
  end if;

  if g_supply_rec_count >= g_supply_limit and
     next_index < peg_data.parent_index.count then
         -- add next code
     v_one_record := next_index+1|| field_seperator ||
           NEXT_NODE || field_seperator ||
           -1 ||field_seperator ||
           'Next '||g_supply_limit||field_seperator ||
           -1 ||field_seperator ||
           -1 ||field_seperator||0;
     v_return_data :=v_return_data || record_seperator ||
           v_one_record;
     g_block_start_row(g_current_block+1) := next_index;
     return false;
  end if;

  if next_index = peg_data.parent_index.count then
     g_block_start_row(g_current_block+1) := next_index;
     return false;
  elsif v_return_data is null then
     return false;
  else
     return true;
  end if;

End get_new_result;

Function modify_parent_path(i number) return varchar2 is
  new_path varchar2(200);
  level number :=1;
  a number;
Begin
     a := instr(peg_data.path(i), '-',1, level);

     while a >0 loop
        if new_path is null then
           new_path := '0-0';
        else
           new_path := new_path ||'-0';
        end if;
        level := level+1;
        a := instr(peg_data.path(i), '-',1, level);
     end loop;
     peg_data.new_path(i) := new_path;

     return new_path;
END modify_parent_path;

FUNCTION isSupplyLate(p_plan_id number,
                      p_instance_id number,
                      p_organization_id number,
                      p_inventory_item_id number,
                      p_transaction_id number) RETURN NUMBER IS
  CURSOR C IS
   select 1
   from msc_exception_details
  WHERE  number1 = p_transaction_id
  AND    sr_instance_id = p_instance_id
  AND    plan_id = p_plan_id
  and    exception_type =36
  AND    organization_id = p_organization_id
  AND    inventory_item_id = p_inventory_item_id;
  v_isLate number :=0;
BEGIN
  OPEN C;
  FETCH C INTO v_isLate;
  CLOSE C;
  return v_isLate;
END isSupplyLate;

Function order_number(p_order_type number, p_order_number varchar2,
                      p_plan_id number, p_inst_id number,
                      p_transaction_id number, p_disposition_id number)
return varchar2 IS
  v_text varchar2(300);
  cursor order_c is
    select order_number
      from msc_supplies
      where plan_id = p_plan_id
        and transaction_id = p_disposition_id
        and sr_instance_id = p_inst_id;
BEGIN


  if p_order_type = 5 then
     if p_order_number is null then
        return to_char(p_transaction_id);
     else
        return p_order_number||' '||to_char(p_transaction_id);
     end if;
  end if;

  if p_order_type in (14,17) then
     open order_c;
     fetch order_c into v_text;
     close order_c;

     if v_text is null then
        return to_char(p_disposition_id);
     else
        return v_text ||' '||to_char(p_disposition_id);
     end if;

  end if;

  if p_order_number is not null then
     return p_order_number;
  end if;

  --return null;
  return ' ';
End order_number;


END;

/
