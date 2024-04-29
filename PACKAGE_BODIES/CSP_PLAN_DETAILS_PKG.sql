--------------------------------------------------------
--  DDL for Package Body CSP_PLAN_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PLAN_DETAILS_PKG" AS
/*$Header: csptpldb.pls 120.59 2008/06/03 00:01:33 hhaugeru noship $*/
  l_organization_id               number := 0;
  l_inventory_item_id             number := 0;
  l_forecast_rule_id              number := 0;
  l_forecast_periods              number := 0;
  l_forecast_period_size          number := 0;
  l_forecast_method               number := 0;
  l_history_periods               number := 0;
  l_period_size                   number := 0;
  l_orig_forecast_periods         number := 0;
  l_orig_period_size              number := 0;
  l_usable_assignment_set_id      number := 0;
  l_defective_assignment_set_id   number := 0;
  l_repair_assignment_set_id      number := 0;
  l_edq_multiple                  number := 1;
  l_reschedule_rule_id            number := null;
  l_onhand_type_in                number;
  l_start_day_in                  number;
  l_end_day_in                    number;
  l_onhand_condition_in           number;
  l_periods_in                    number;
  l_onhand_type_out               number;
  l_start_day_out                 number;
  l_end_day_out                   number;
  l_onhand_value_out              number;
  l_edq_multiple_out              number;
  l_periods_out                   number;
  l_minimum_value                 number := 0;
  g_retcode                       number := 0;

Procedure Add_Err_Msg Is
l_msg_index_out		  NUMBER;
x_msg_data_temp		  Varchar2(2000);
x_msg_data		  Varchar2(4000);
Begin
If fnd_msg_pub.count_msg > 0 Then
  FOR i IN REVERSE 1..fnd_msg_pub.count_msg Loop
	fnd_msg_pub.get(p_msg_index => i,
		   p_encoded => 'F',
		   p_data => x_msg_data_temp,
		   p_msg_index_out => l_msg_index_out);
	x_msg_data := x_msg_data || x_msg_data_temp;
   End Loop;
   FND_FILE.put_line(FND_FILE.log,x_msg_data);
   fnd_msg_pub.delete_msg;
   g_retcode := 1;
End if;
End;

procedure order_automation is
  cursor c_business_rule is
  select cwrv.wrp_rule_id,
         cwrv.excess_value_limit,
         cwrv.excess_ts_min,
         cwrv.excess_ts_max,
         cwrv.excess_lead_time,
         cwrv.rep_int_value_limit,
         cwrv.rep_int_ts_min,
         cwrv.rep_int_ts_max,
         cwrv.rep_int_lead_time,
         cwrv.rep_ext_value_limit,
         cwrv.rep_ext_ts_min,
         cwrv.rep_ext_ts_max,
         cwrv.rep_ext_lead_time,
         cwrv.nb_int_value_limit,
         cwrv.nb_int_ts_min,
         cwrv.nb_int_ts_max,
         cwrv.nb_int_lead_time,
         cwrv.nb_ext_value_limit,
         cwrv.nb_ext_ts_min,
         cwrv.nb_ext_ts_max,
         cwrv.nb_ext_lead_time
  from   csp_wrp_rules_vl cwrv,
         csp_planning_parameters cpp
  where  cpp.organization_id = l_organization_id
  and    cpp.organization_type = 'W'
  and    cwrv.wrp_rule_id = cpp.wrp_rule_id;

  cursor c_planned_orders is
  select cpd.inventory_item_id,
         nvl(cpd.related_item_id, cpd.inventory_item_id) supplied_item_id,
         cpd.plan_detail_type,
         cpd.source_organization_id,
         cpd.quantity,
         cpd.plan_date,
         nvl(cuh.tracking_signal,0) tracking_signal,
         nvl(cpl.newbuy_lead_time,0) newbuy_lead_time,
         nvl(cpl.repair_lead_time,0) repair_lead_time,
         nvl(cpl.excess_lead_time,0) excess_lead_time,
         nvl(cic.item_cost,0) item_cost
  from   csp_plan_details cpd,
         csp_plan_leadtimes cpl,
         cst_item_costs cic,
         mtl_parameters mp,
         csp_usage_headers cuh
  where  cpd.organization_id = l_organization_id
  and    cpl.organization_id = cpd.organization_id
  and    cpl.inventory_item_id = cpd.inventory_item_id
  and    cpd.plan_detail_type in ('4110','4210','4310')
  and    cic.organization_id = cpd.organization_id
  and    cic.inventory_item_id = cpd.inventory_item_id
  and    cic.cost_type_id = mp.primary_cost_method
  and    mp.organization_id = cpd.organization_id
  and    cuh.organization_id(+) = cpd.organization_id
  and    cuh.inventory_item_id(+) = cpd.inventory_item_id
  and    cuh.header_data_type(+) = '4'
  and    nvl(cic.item_cost,0) > 0;

  cursor c_rep_int_ext(p_organization_id number,p_supplied_item_id number) is
  select decode(misl.source_type,1,'INTERNAL','EXTERNAL')
  from MRP_ITEM_SOURCING_LEVELS_V  misl, csp_planning_parameters cpp
  where cpp.organization_id = p_organization_id
  and misl.organization_id = cpp.organization_id
  and misl.assignment_set_id =cpp.repair_assignment_set_id
  and inventory_item_id = p_supplied_item_id
  and SOURCE_TYPE       in (1,3)
  and sourcing_level = (select min(sourcing_level) from
MRP_ITEM_SOURCING_LEVELS_V
                        where organization_id = p_organization_id
                        and assignment_set_id =  cpp.repair_assignment_set_id
                        and inventory_item_id = p_supplied_item_id
                        and sourcing_level not in (2,9))
  order by misl.rank;

  cursor c_nb_int_ext(p_organization_id number, p_supplied_item_id number) is
  select decode(nvl(msi.source_type,mp.source_type),1,'INTERNAL','EXTERNAL')
  from   mtl_system_items msi,
         mtl_parameters mp
  where  mp.organization_id = msi.organization_id
  and    msi.organization_id = p_organization_id
  and    msi.inventory_item_id = p_supplied_item_id;

  cursor c_statistics is
  select decode(cpd.parent_type,'8611','NewBuy Internal Inside ',
                            '8612','NewBuy Internal Outside',
                            '8613','NewBuy External Inside ',
                            '8614','NewBuy External Outside',
                            '8621','Repair Internal Inside ',
                            '8622','Repair Internal Outside',
                            '8623','Repair External Inside ',
                            '8624','Repair External Outside',
                            '8631','Excess Internal Inside ',
                            '8632','Excess Internal Outside',
                                   '.......................') ||
                            lpad(to_char(count(*)),15,' ') ||
                            lpad(to_char(round(
                            sum(cpd.quantity * cic.item_cost),2)),15,' ') ||
                            lpad(to_char(sum(cpd.quantity)),15,' ') ||
                            lpad(to_char(round(avg(
                            nvl(cuh.tracking_signal,0)),2)),11,' ') statistics
  from   csp_plan_details cpd,
         cst_item_costs cic,
         mtl_parameters mp,
         csp_usage_headers cuh
  where  cic.organization_id = cpd.organization_id
  and    cic.inventory_item_id = cpd.inventory_item_id
  and    cpd.plan_detail_type in ('8610','8620','8630')
  and    mp.organization_id = cpd.organization_id
  and    cic.cost_type_id = mp.primary_cost_method
  and    cuh.organization_id(+) = cpd.organization_id
  and    cuh.inventory_item_id(+) = cpd.inventory_item_id
  and    cuh.header_data_type(+) = '4'
  group by cpd.parent_type;

  l_wrp_rule_id number := null;
  l_excess_value_limit number := null;
  l_excess_ts_min number := null;
  l_excess_ts_max number := null;
  l_excess_lead_time number := null;
  l_rep_int_value_limit number := null;
  l_rep_int_ts_min number := null;
  l_rep_int_ts_max number := null;
  l_rep_int_lead_time number := null;
  l_rep_ext_value_limit number := null;
  l_rep_ext_ts_min number := null;
  l_rep_ext_ts_max number := null;
  l_rep_ext_lead_time number := null;
  l_nb_int_value_limit number := null;
  l_nb_int_ts_min number := null;
  l_nb_int_ts_max number := null;
  l_nb_int_lead_time number := null;
  l_nb_ext_value_limit number := null;
  l_nb_ext_ts_min number := null;
  l_nb_ext_ts_max number := null;
  l_nb_ext_lead_time number := null;
  l_order number := null;
  l_nb_int_ext varchar2(30);
  l_rep_int_ext varchar2(30);
  l_line_tbl   CSP_PLANNED_ORDERS.Line_Tbl_Type;
  l_return_status        VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_data             VARCHAR2(2000);
  l_msg_count            NUMBER;
  l_parent_type          varchar2(30) := null;

  begin
    open  c_business_rule;
    fetch c_business_rule into
      l_wrp_rule_id,
      l_excess_value_limit,
      l_excess_ts_min ,
      l_excess_ts_max ,
      l_excess_lead_time ,
      l_rep_int_value_limit ,
      l_rep_int_ts_min ,
      l_rep_int_ts_max ,
      l_rep_int_lead_time ,
      l_rep_ext_value_limit ,
      l_rep_ext_ts_min ,
      l_rep_ext_ts_max ,
      l_rep_ext_lead_time ,
      l_nb_int_value_limit ,
      l_nb_int_ts_min ,
      l_nb_int_ts_max ,
      l_nb_int_lead_time ,
      l_nb_ext_value_limit ,
      l_nb_ext_ts_min ,
      l_nb_ext_ts_max ,
      l_nb_ext_lead_time;
    close c_business_rule;
    if l_wrp_rule_id is not null then
      if l_excess_value_limit is not null or
         l_excess_ts_min is not null or
         l_excess_ts_max is not null or
         l_excess_lead_time is not null then
        l_excess_value_limit := nvl(l_excess_value_limit,999999999999);
        l_excess_ts_min := nvl(l_excess_ts_min,-999999999999);
        l_excess_ts_max := nvl(l_excess_ts_max,999999999999);
        l_excess_lead_time := nvl(l_excess_lead_time,3);
      end if;
      if l_rep_int_value_limit is not null or
         l_rep_int_ts_min is not null or
         l_rep_int_ts_max is not null or
         l_rep_int_lead_time is not null then
        l_rep_int_value_limit := nvl(l_rep_int_value_limit,999999999999);
        l_rep_int_ts_min := nvl(l_rep_int_ts_min,-999999999999);
        l_rep_int_ts_max := nvl(l_rep_int_ts_max,999999999999);
        l_rep_int_lead_time := nvl(l_rep_int_lead_time,3);
      end if;
      if l_rep_ext_value_limit is not null or
         l_rep_ext_ts_min is not null or
         l_rep_ext_ts_max is not null or
         l_rep_ext_lead_time is not null then
        l_rep_ext_value_limit := nvl(l_rep_ext_value_limit,999999999999);
        l_rep_ext_ts_min := nvl(l_rep_ext_ts_min,-999999999999);
        l_rep_ext_ts_max := nvl(l_rep_ext_ts_max,999999999999);
        l_rep_ext_lead_time := nvl(l_rep_ext_lead_time,3);
      end if;
      if l_nb_int_value_limit is not null or
         l_nb_int_ts_min is not null or
         l_nb_int_ts_max is not null or
         l_nb_int_lead_time is not null then
        l_nb_int_value_limit := nvl(l_nb_int_value_limit,999999999999);
        l_nb_int_ts_min := nvl(l_nb_int_ts_min,-999999999999);
        l_nb_int_ts_max := nvl(l_nb_int_ts_max,999999999999);
        l_nb_int_lead_time := nvl(l_nb_int_lead_time,3);
      end if;
      if l_nb_ext_value_limit is not null or
         l_nb_ext_ts_min is not null or
         l_nb_ext_ts_max is not null or
         l_nb_ext_lead_time is not null then
        l_nb_ext_value_limit := nvl(l_nb_ext_value_limit,999999999999);
        l_nb_ext_ts_min := nvl(l_nb_ext_ts_min,-999999999999);
        l_nb_ext_ts_max := nvl(l_nb_ext_ts_max,999999999999);
        l_nb_ext_lead_time := nvl(l_nb_ext_lead_time,3);
      end if;
      for cr in c_planned_orders loop
        l_order := 0;
        if cr.plan_detail_type = '4110' then

          if  l_excess_lead_time = 1
            and cr.plan_date < trunc(sysdate) + cr.excess_lead_time
            and cr.tracking_signal between l_excess_ts_min
                                       and l_excess_ts_max
            and cr.item_cost * cr.quantity < l_excess_value_limit then
            l_parent_type := '8631';
            l_order := 1;
          elsif l_excess_lead_time =2
            and cr.plan_date >= trunc(sysdate) + cr.excess_lead_time
            and cr.tracking_signal between l_excess_ts_min
                                       and l_excess_ts_max
            and cr.item_cost * cr.quantity < l_excess_value_limit then
            l_parent_type := '8632';
            l_order := 1;
          elsif l_excess_lead_time =3
            and cr.tracking_signal between l_excess_ts_min
                                       and l_excess_ts_max
            and cr.item_cost * cr.quantity < l_excess_value_limit then
            if cr.plan_date <= trunc(sysdate) + cr.excess_lead_time then
               l_parent_type := '8631';
            else
               l_parent_type := '8632';
            end if;
            l_order := 1;
          end if;
        elsif cr.plan_detail_type = '4210' then

          open  c_rep_int_ext(l_organization_id,cr.supplied_item_id);
          fetch c_rep_int_ext into l_rep_int_ext;
          close c_rep_int_ext;

          if l_rep_int_ext = 'INTERNAL' then
            if  l_rep_int_lead_time = 1
            and cr.plan_date < trunc(sysdate) + cr.repair_lead_time
            and cr.tracking_signal between l_rep_int_ts_min
                                              and l_rep_int_ts_max
            and cr.item_cost * cr.quantity < l_rep_int_value_limit then
              l_parent_type := '8621';
              l_order := 1;
            elsif l_rep_int_lead_time = 2
            and cr.plan_date >= trunc(sysdate) + cr.repair_lead_time
            and cr.tracking_signal between l_rep_int_ts_min
                                       and l_rep_int_ts_max
            and cr.item_cost * cr.quantity < l_rep_int_value_limit then
              l_parent_type := '8622';
              l_order := 1;
            elsif l_rep_int_lead_time = 3
            and cr.tracking_signal between l_rep_int_ts_min
                                              and l_rep_int_ts_max
            and cr.item_cost * cr.quantity < l_rep_int_value_limit then
              if cr.plan_date <= trunc(sysdate) + cr.repair_lead_time then
                 l_parent_type := '8621';
              else
                 l_parent_type := '8622';
              end if;
              l_order := 1;
            end if;
          else
            if  l_rep_ext_lead_time = 1
            and cr.plan_date < trunc(sysdate) + cr.repair_lead_time
            and cr.tracking_signal between l_rep_ext_ts_min
                                              and l_rep_ext_ts_max
            and cr.item_cost * cr.quantity < l_rep_ext_value_limit then
              l_parent_type := '8623';
              l_order := 1;
            elsif l_rep_ext_lead_time = 2
            and cr.plan_date >= trunc(sysdate) + cr.repair_lead_time
            and cr.tracking_signal between l_rep_ext_ts_min
                                              and l_rep_ext_ts_max
            and cr.item_cost * cr.quantity < l_rep_ext_value_limit then
              l_parent_type := '8624';
              l_order := 1;
            elsif l_rep_ext_lead_time =3
            and cr.tracking_signal between l_rep_ext_ts_min
                                              and l_rep_ext_ts_max
            and cr.item_cost * cr.quantity < l_rep_ext_value_limit then
              if cr.plan_date <= trunc(sysdate) + cr.repair_lead_time then
                 l_parent_type := '8623';
              else
                 l_parent_type := '8624';
              end if;
              l_order := 1;
            end if;
          end if;
        elsif cr.plan_detail_type = '4310' then
          open  c_nb_int_ext(l_organization_id,cr.supplied_item_id);
          fetch c_nb_int_ext into l_nb_int_ext;
          close c_nb_int_ext;

          if l_nb_int_ext = 'INTERNAL' then
            if  l_nb_int_lead_time = 1
            and cr.plan_date < trunc(sysdate) + cr.newbuy_lead_time
            and cr.tracking_signal between l_nb_int_ts_min
                                              and l_nb_int_ts_max
            and cr.item_cost * cr.quantity < l_nb_int_value_limit then
              l_parent_type := '8611';
              l_order := 1;
            elsif l_nb_int_lead_time =2
            and cr.plan_date >= trunc(sysdate) + cr.newbuy_lead_time
            and cr.tracking_signal between l_nb_int_ts_min
                                              and l_nb_int_ts_max
            and cr.item_cost * cr.quantity < l_nb_int_value_limit then
              l_parent_type := '8612';
              l_order := 1;
            elsif l_nb_int_lead_time = 3
            and cr.tracking_signal between l_nb_int_ts_min
                                              and l_nb_int_ts_max
            and cr.item_cost * cr.quantity < l_nb_int_value_limit then
              if cr.plan_date <= trunc(sysdate) + cr.newbuy_lead_time then
                 l_parent_type := '8611';
              else
                 l_parent_type := '8612';
              end if;
              l_order := 1;
            end if;
          else

            if  l_nb_ext_lead_time = 1
            and cr.plan_date < trunc(sysdate) + cr.newbuy_lead_time
            and cr.tracking_signal between l_nb_ext_ts_min
                                              and l_nb_ext_ts_max
            and cr.item_cost * cr.quantity < l_nb_ext_value_limit then
              l_parent_type := '8613';
              l_order := 1;
            elsif l_nb_ext_lead_time = 2
            and cr.plan_date >= trunc(sysdate) + cr.newbuy_lead_time
            and cr.tracking_signal between l_nb_ext_ts_min
                                              and l_nb_ext_ts_max
            and cr.item_cost * cr.quantity < l_nb_ext_value_limit then
              l_parent_type := '8614';
              l_order := 1;
            elsif l_nb_ext_lead_time = 3
            and cr.tracking_signal between l_nb_ext_ts_min
                                              and l_nb_ext_ts_max
            and cr.item_cost * cr.quantity < l_nb_ext_value_limit then
              if cr.plan_date <= trunc(sysdate) + cr.newbuy_lead_time then
                 l_parent_type := '8613';
              else
                 l_parent_type := '8614';
              end if;
              l_order := 1;
            end if;
          end if;
        end if;

        if l_order = 1 then
          l_line_tbl(1).supplied_item_id := cr.supplied_item_id;
          l_line_tbl(1).planned_order_type := cr.plan_detail_type;
          l_line_tbl(1).source_organization_id := cr.source_organization_id;
          l_line_tbl(1).quantity := cr.quantity;
          l_line_tbl(1).plan_Date := cr.plan_date;

          CSP_PLANNED_ORDERS.create_orders(
            p_api_version             => 1.0
          , p_Init_Msg_List           => FND_API.G_FALSE
          , p_commit                  => FND_API.G_FALSE
          , p_organization_id         => l_organization_id
          , p_inventory_item_id       => cr.supplied_item_id
          , px_line_tbl               => l_line_tbl
          , x_return_status           => l_Return_status
          , x_msg_count               => l_msg_count
          , x_msg_data                => l_msg_data);


          if l_return_status = FND_API.G_RET_STS_SUCCESS then
            update csp_plan_details
            set    plan_detail_type = decode(cr.plan_detail_type,'4110','8630',
                                                                 '4210','8620',
                                                                 '4310','8610'),
                   parent_type = l_parent_type
            where  inventory_item_id = cr.inventory_item_id
            and    organization_id = l_organization_id
            and    plan_detail_type = cr.plan_detail_type
            and    quantity = cr.quantity
            and    plan_date = cr.plan_date;
          else
            add_err_msg;
          end if;
        end if;
      end loop;
      FND_FILE.put_line(FND_FILE.output,'Supply Internal Lead    Planned                                      Tracking');
      FND_FILE.put_line(FND_FILE.output,'Type   External Time    Orders         Value          Parts          Signal Avg');
      FND_FILE.put_line(FND_FILE.output,'------ -------- ------- -------------- -------------- -------------- ----------');
      for cr in c_statistics loop
        FND_FILE.put_line(FND_FILE.output,cr.statistics);
      end loop;
      FND_FILE.put_line(FND_FILE.output,'------ -------- ------- -------------- -------------- -------------- ----------');
    end if;
  end;

  procedure leadtimes is
  begin

      delete from csp_plan_leadtimes
      where  organization_id = l_organization_id
      and    inventory_item_id = nvl(l_inventory_item_id,inventory_item_id);

      insert into csp_plan_leadtimes(
        inventory_item_id,
        organization_id,
        excess_lead_time,
        repair_lead_time,
        newbuy_lead_time,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
        select
           cpd.inventory_item_id,
           cpd.organization_id,
          (select max(nvl(mism1.intransit_time, 0))
           from MRP_ITEM_SOURCING_LEVELS_V  misl, csp_planning_parameters cpp, mtl_interorg_ship_methods mism1
           where mism1.to_organization_id = cpp.organization_id
           and mism1.from_organization_id =  misl.source_organization_id
           and mism1.default_flag = 1
           and cpp.organization_id = cpd.organization_id
           and misl.organization_id = cpp.organization_id
           and misl.assignment_set_id =cpp.usable_assignment_set_id
           and misl.inventory_item_id = cpd.inventory_item_id
           and misl.SOURCE_TYPE       = 1
           and sourcing_level = (select min(sourcing_level)
                                 from MRP_ITEM_SOURCING_LEVELS_V
                                 where organization_id = cpd.organization_id
                                 and assignment_set_id =  cpp.usable_assignment_set_id
                                 and inventory_item_id = cpd.inventory_item_id
                                 and sourcing_level not in (2,9))) Excess_Lead_Time,
          (select max(nvl(mism.intransit_time, 0) +
                  nvl(msib.repair_leadtime, 0) +
                  (select nvl(max(nvl(mism2.intransit_time, 0)), 0)
                   from MRP_ITEM_SOURCING_LEVELS_V  misl1,
                        csp_planning_parameters cpp,
                        mtl_interorg_ship_methods mism2
                   where mism2.to_organization_id = decode(misl.source_type, 1, misl.source_organization_id, 3, hoi.organization_id)
                   and mism2.from_organization_id =  misl1.source_organization_id
                   and mism2.default_flag = 1
                   and cpp.organization_id = cpd.organization_id
                   and misl1.organization_id = cpp.organization_id
                   and misl1.assignment_set_id =cpp.defective_assignment_set_id
                   and misl1.inventory_item_id = cpd.inventory_item_id
                   and SOURCE_TYPE       = 1
                   and sourcing_level = (select min(sourcing_level)
                                         from MRP_ITEM_SOURCING_LEVELS_V
                                         where organization_id = cpd.organization_id
                                         and assignment_set_id =  cpp.defective_assignment_set_id
                                         and inventory_item_id = cpd.inventory_item_id
                                         and sourcing_level not in (2,9))
                  ))
           from MRP_ITEM_SOURCING_LEVELS_V  misl,
                csp_planning_parameters cpp,
                mtl_interorg_ship_methods mism,
                mtl_system_items_b msib,
                hr_organization_information hoi
           where msib.inventory_item_id = cpd.inventory_item_id
           and msib.organization_id = decode(misl.source_type, 1, misl.source_organization_id, 3, hoi.organization_id)
           and mism.to_organization_id = misl.organization_id
           and mism.from_organization_id = decode(misl.source_type, 1, misl.source_organization_id, 3, hoi.organization_id)
           and mism.default_flag = 1
           and cpp.organization_id = cpd.organization_id
           and misl.organization_id = cpp.organization_id
           and misl.assignment_set_id = cpp.repair_assignment_set_id
           and misl.inventory_item_id = cpd.inventory_item_id
           and misl.SOURCE_TYPE in ( 1, 3)
           and sourcing_level = (select min(sourcing_level)
                                 from MRP_ITEM_SOURCING_LEVELS_V
                                 where organization_id = cpd.organization_id
                                 and assignment_set_id =  cpp.repair_assignment_set_id
                                 and inventory_item_id = cpd.inventory_item_id
                                 and sourcing_level not in (2,9))
           and hoi.ORG_INFORMATION_CONTEXT(+) = 'Customer/Supplier Association'
           and hoi.org_information3(+) = misl.vendor_id
           ) Repair_Lead_time,
          (select decode(nvl(msib.preprocessing_lead_time, 0) +
                  nvl(msib.full_lead_time, 0) +
                  nvl(msib.postprocessing_lead_time,0),0,null,
                  nvl(msib.preprocessing_lead_time, 0) +
                  nvl(msib.full_lead_time, 0) +
                  nvl(msib.postprocessing_lead_time,0))
           from mtl_system_items_b msib
           where inventory_item_id = cpd.inventory_item_id
           and organization_id = cpd.organization_id) NewBuy_Lead_Time,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.login_id
         from csp_plan_Details cpd
         where plan_detail_type = '1'
         and organization_id = l_organization_id
         and inventory_item_id = nvl(l_inventory_item_id, inventory_item_id)
         group by organization_id, inventory_item_id;
    EXCEPTION
      WHEN no_data_found THEN
          null ;
  end leadtimes;

  procedure reorders(p_organization_id number,p_inventory_item_id number) is
  begin

     delete from csp_plan_reorders
     where  organization_id = p_organization_id
     and    inventory_item_id = nvl(p_inventory_item_id,inventory_item_id);

     insert into csp_plan_reorders(
        inventory_item_id,
        organization_id,
        excess_rop,
        repair_rop,
        newbuy_rop,
        excess_edq,
        repair_edq,
        newbuy_edq,
        excess_safety_stock,
        repair_safety_stock,
        newbuy_safety_stock,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
       (select b.inventory_item_id,
               b.organization_id,
              (nvl(csf.safety_factor,0) * b.standard_deviation + b.excess_total_req) excess_rop,
              (nvl(csf1.safety_factor, 0) * b.standard_deviation + b.repair_total_req) repair_rop,
              (nvl(csf2.safety_factor, 0) * b.standard_deviation + b.newbuy_total_req) newbuy_rop,
               b.excess_edq,
               b.repair_edq,
               b.newbuy_edq,
              (nvl(csf.safety_factor,0) * nvl(b.standard_deviation, 0)) excess_safety_stock,
              (nvl(csf1.safety_factor,0) * nvl(b.standard_deviation, 0)) repair_safety_stock,
              (nvl(csf2.safety_factor,0) * nvl(b.standard_deviation, 0)) newbuy_safety_stock,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.login_id
        from csp_safety_factors csf,
             csp_Safety_factors csf1,
             csp_safety_factors csf2,
            (select decode(nvl(cpp1.safety_stock_flag, 'N'), 'N', 0, decode(a.excess_awr, 0, 0 , decode(nvl(cuh.item_cost, 0), 0, 0, decode(nvl(cipp.excess_edq_factor, cpp1.excess_edq_factor), 0, 0,
                      LEAST(52, GREATEST(3, ROUND(a.excess_awr * 52/(ROUND(nvl(cipp.excess_edq_factor, cpp1.excess_edq_factor) * (SQRT(52 * a.excess_awr * cuh.item_Cost)/cuh.item_Cost),4))))))))) excess_exposures
                  , a.excess_total_req
                  , decode(cic.item_cost, 0, 0, decode(a.excess_awr, 0, 0, ROUND(nvl(cipp.excess_edq_factor, cpp1.excess_edq_factor) * (SQRT(52 * a.excess_awr * cic.item_Cost)/cic.item_Cost),4))) Excess_EDQ
                  , decode(nvl(cpp1.safety_stock_flag, 'N'), 'N', 0, decode(a.repair_awr, 0, 0, decode(nvl(cic.item_cost, 0), 0, 0, decode(nvl(cipp.repair_edq_factor, cpp1.repair_edq_factor), 0, 0,
                     LEAST(52, GREATEST(3, ROUND(a.repair_awr * 52/(ROUND(nvl(cipp.repair_Edq_factor, cpp1.repair_edq_factor) * (SQRT(52 * a.repair_awr * cic.item_cost)/cic.item_cost),4))))))))) repair_exposures
                  , a.repair_total_req
                  , decode(cic.item_cost, 0, 0, decode(a.repair_awr, 0, 0, ROUND(nvl(cipp.repair_edq_Factor, cpp1.repair_edq_factor) * (SQRT(52 * a.repair_awr * cic.item_cost)/cic.item_cost),4))) Repair_EDQ
                  , decode(nvl(cpp1.safety_stock_flag, 'N'), 'N', 0, decode(a.newbuy_awr, 0, 0, decode(nvl(cic.item_cost, 0), 0, 0, decode(nvl(cipp.newbuy_edq_factor, cpp1.newbuy_edq_factor), 0, 0,
                      LEAST(52, GREATEST(3, ROUND(a.newbuy_awr * 52/(ROUND(nvl(cipp.newbuy_edq_factor, cpp1.newbuy_edq_factor) * (SQRT(52 * a.newbuy_awr * cic.item_cost)/cic.item_cost),4))))))))) newbuy_exposures
                  , a.newbuy_total_req
                  , decode(cic.item_cost, 0, 0, decode(a.newbuy_awr, 0, 0, ROUND(nvl(cipp.newbuy_edq_factor, cpp1.newbuy_edq_factor) * (SQRT(52 * a.newbuy_awr * cic.item_cost)/cic.item_cost),4))) NewBuy_EDQ
                  , a.inventory_item_id
                  , a.organization_id
                  , nvl(nvl(cipp.excess_service_level, cpp1.excess_service_level), cpp1.service_level) excess_service_level
                  ,nvl(nvl(cipp.repair_service_level, cpp1.repair_service_level), cpp1.service_level) repair_service_level
                  ,nvl(nvl(cipp.newbuy_service_level, cpp1.newbuy_service_level), cpp1.service_level) newbuy_service_level
                  ,nvl(cuh.standard_deviation, 0) standard_deviation
             from csp_usage_headers cuh,
                  cst_item_costs cic,
                  mtl_parameters mp,
                  csp_planning_parameters cpp1,
                  csp_item_pl_params cipp,
                 (select decode(nvl(cpl.Excess_Lead_Time, 0), 0, 0, round(sum(decode((cfrb.period_size *
floor(cpl.Excess_Lead_Time/cfrb.period_size)), 0, 0, decode(floor((cpd.plan_date - trunc(sysdate))/(cfrb.period_size *
floor(cpl.Excess_Lead_Time/cfrb.period_size))), 0, cpd.quantity, 0))) +
                          sum(decode(sign(cpl.Excess_lead_time - cfrb.period_size), -1,
                            decode(sign((cpd.plan_date - trunc(sysdate)) - cfrb.period_size), -1, cpd.quantity, 0), decode(floor((cpd.plan_date - trunc(sysdate))
                             /(cfrb.period_size *
floor(cpl.Excess_Lead_Time/cfrb.period_size))), 1, decode(sign(plan_date - trunc(sysdate)- cpl.excess_lead_time), -1, cpd.quantity, 0), 0)))* ((cpl.Excess_lead_time - (cfrb.period_size *
floor(cpl.Excess_Lead_Time/cfrb.period_size)))/cfrb.period_size), 4))  Excess_Total_Req,
                         (decode(nvl(cpl.Excess_Lead_Time, 0), 0, 0, round(sum(decode((cfrb.period_size *
floor(cpl.Excess_Lead_Time/cfrb.period_size)), 0, 0, decode(floor((cpd.plan_date - trunc(sysdate))/(cfrb.period_size *
floor(cpl.Excess_Lead_Time/cfrb.period_size))), 0, cpd.quantity, 0))) +
                          sum(decode(sign(cpl.Excess_lead_time - cfrb.period_size), -1,
                           decode(sign((cpd.plan_date - trunc(sysdate)) - cfrb.period_size), -1, cpd.quantity, 0), decode(floor((cpd.plan_date - trunc(sysdate))
                            /(cfrb.period_size *
floor(cpl.Excess_Lead_Time/cfrb.period_size))), 1, decode(sign(plan_date - trunc(sysdate)- cpl.excess_lead_time), -1, cpd.quantity, 0), 0)))* ((cpl.Excess_lead_time - (cfrb.period_size *
floor(cpl.Excess_Lead_Time/cfrb.period_size)))/cfrb.period_size) , 4))/ cpl.Excess_Lead_Time) * 7  excess_awr,
                         decode(nvl(cpl.Repair_Lead_Time, 0), 0, 0, round(sum(decode((cfrb.period_size *
floor(cpl.Repair_Lead_Time/cfrb.period_size)), 0, 0, decode(floor((cpd.plan_date - trunc(sysdate))/(cfrb.period_size *
floor(cpl.Repair_Lead_Time/cfrb.period_size))), 0, cpd.quantity, 0))) +
                           sum(decode(sign(cpl.repair_lead_time - cfrb.period_size), -1,
                            decode(sign((cpd.plan_date - trunc(sysdate)) - cfrb.period_size), -1, cpd.quantity, 0), decode(floor((cpd.plan_date - trunc(sysdate))
                             /(cfrb.period_size * floor(cpl.Repair_Lead_Time/cfrb.period_size))), 1, decode(sign(plan_date -
trunc(sysdate)- cpl.repair_lead_time), -1, cpd.quantity, 0), 0)))*
((cpl.Repair_lead_time - (cfrb.period_size * floor(cpl.Repair_Lead_Time/cfrb.period_size)))/cfrb.period_size), 4)) Repair_Total_Req,
                         (decode(nvl(cpl.Repair_Lead_Time, 0), 0, 0, round(sum(decode((cfrb.period_size *
floor(cpl.Repair_Lead_Time/cfrb.period_size)), 0, 0, decode(floor((cpd.plan_date - trunc(sysdate))/(cfrb.period_size *
floor(cpl.Repair_Lead_Time/cfrb.period_size))), 0, cpd.quantity, 0))) +
                          sum(decode(sign(cpl.repair_lead_time - cfrb.period_size), -1,
                           decode(sign((cpd.plan_date - trunc(sysdate)) - cfrb.period_size), -1, cpd.quantity, 0), decode(floor((cpd.plan_date - trunc(sysdate))
                            /(cfrb.period_size *
floor(cpl.Repair_Lead_Time/cfrb.period_size))), 1, decode(sign(plan_date - trunc(sysdate)- cpl.repair_lead_time), -1, cpd.quantity, 0), 0)))*
((cpl.Repair_lead_time - (cfrb.period_size *
floor(cpl.Repair_Lead_Time/cfrb.period_size)))/cfrb.period_size), 4))/cpl.repair_lead_time) * 7 Repair_AWR,
                         decode(nvl(cpl.NewBuy_Lead_Time, 0), 0, 0, round(sum(decode((cfrb.period_size *
floor(cpl.NewBuy_Lead_Time/cfrb.period_size)), 0, 0, decode(floor((cpd.plan_date - trunc(sysdate))/(cfrb.period_size *
floor(cpl.NewBuy_Lead_Time/cfrb.period_size))), 0, cpd.quantity, 0))) +
                          sum(decode(sign(cpl.NewBuy_lead_time - cfrb.period_size), -1,
                           decode(sign((cpd.plan_date - trunc(sysdate)) - cfrb.period_size), -1, cpd.quantity, 0), decode(floor((cpd.plan_date - trunc(sysdate))
                            /(cfrb.period_size * floor(cpl.NewBuy_Lead_Time/cfrb.period_size))), 1, decode(sign(plan_date
- trunc(sysdate)- cpl.newbuy_lead_time), -1, cpd.quantity, 0), 0)))*
((cpl.NewBuy_lead_time - (cfrb.period_size * floor(cpl.NewBuy_Lead_Time/cfrb.period_size)))/cfrb.period_size), 4)) NewBuy_Total_Req,
                         (decode(nvl(cpl.NewBuy_Lead_Time, 0), 0, 0, round(sum(decode((cfrb.period_size *
floor(cpl.NewBuy_Lead_Time/cfrb.period_size)), 0, 0, decode(floor((cpd.plan_date - trunc(sysdate))/(cfrb.period_size *
floor(cpl.NewBuy_Lead_Time/cfrb.period_size))), 0, cpd.quantity, 0))) +
                          sum(decode(sign(cpl.NewBuy_lead_time - cfrb.period_size), -1,
                           decode(sign((cpd.plan_date - trunc(sysdate)) - cfrb.period_size), -1, cpd.quantity, 0), decode(floor((cpd.plan_date - trunc(sysdate))
                            /(cfrb.period_size *
floor(cpl.NewBuy_Lead_Time/cfrb.period_size))), 1, decode(sign(plan_date - trunc(sysdate)- cpl.newbuy_lead_time), -1, cpd.quantity, 0), 0)))* ((cpl.NewBuy_lead_time - (cfrb.period_size *
floor(cpl.NewBuy_Lead_Time/cfrb.period_size)))/cfrb.period_size),4))/ cpl.newbuy_lead_time) * 7 NewBuy_AWR,
                         cpd.inventory_item_id,
                         cpd.organization_id
                  from csp_plan_details cpd,
                       csp_plan_leadtimes cpl,
                       csp_planning_parameters cpp,
                       csp_forecast_rules_b cfrb
                  where cpd.organization_id = p_organization_id
                  and cpd.inventory_item_id = nvl(p_inventory_item_id, cpd.inventory_item_id)
                  and cpd.plan_detail_type = 1000
                  and cpd.plan_Date between trunc(sysdate)
                      and trunc(sysdate) + greatest(nvl(cpl.excess_lead_time, 0), nvl(cpl.repair_lead_time, 0), cpl.newbuy_lead_time)
                  and cpl.inventory_item_id(+) = cpd.inventory_item_id
                  and cpl.organization_id(+) = cpd.organization_id
                  and cpp.organization_id = cpd.organization_id
                  and cfrb.forecast_rule_id = cpp.forecast_rule_id
                  group by cpd.organization_id, cpd.inventory_item_id, cfrb.period_size,
                           cpl.excess_lead_time, cpl.repair_lead_time, cpl.newbuy_lead_time) a
                  where cuh.organization_id(+) = a.organization_id
                  and cuh.inventory_item_id(+) = a.inventory_item_id
                  and cuh.secondary_inventory(+) = '-'
                  and cuh.header_data_type(+)  = 4
                  and cpp1.organization_type = 'W'
                  and  cpp1.organization_id = a.organization_id
                  and cipp.organization_id(+) = a.organization_id
                  and cipp.inventory_item_id(+) = a.inventory_item_id
                  and cic.inventory_item_id = a.inventory_item_id(+)
                  AND cic.organization_id = mp.organization_id
                  AND cic.cost_type_id = mp.primary_cost_method
                  AND mp.organization_id = a.organization_id) b
             where csf.exposures(+) = b.excess_exposures
             and csf.service_level(+) = b.excess_service_level
             and csf1.exposures(+) = b.repair_exposures
             and csf1.service_level(+) = b.repair_Service_level
             and csf2.exposures(+) = b.newbuy_exposures
             and csf2.service_level(+) = b.newbuy_Service_level    );
       end reorders;

procedure return_history is

begin
      insert into csp_plan_details(
             plan_detail_type,
             parent_type,
             inventory_item_id,
             related_item_id,
             organization_id,
             source_organization_id,
             quantity,
             plan_date,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login)
      select decode(cpd.related_item_id,null,min('6100'),min('6200')),
             min('6000'),
             cpd.inventory_item_id,
             cpd.related_item_id,
             cpd.organization_id,
             cpd.source_organization_id,
             sum(mmt.primary_quantity),
             trunc(trunc(sysdate) - round((trunc(sysdate) - trunc(mmt.transaction_date))/cfrb.period_size)*cfrb.period_size),
	  		 fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id
      from   csp_plan_details cpd,
             csp_planning_parameters cpp,
             csp_forecast_rules_b cfrb,
             mtl_material_transactions mmt,
             csp_usg_transaction_types cutt
      where  cpd.plan_detail_type in ('9002','9003')
      and    cpd.organization_id = l_organization_id
      and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
      and    cpp.organization_id = cpd.source_organization_id
      and    cfrb.forecast_rule_id = cpp.forecast_rule_id
      and    mmt.organization_id = cpd.source_organization_id
      and    mmt.inventory_item_id = nvl(cpd.related_item_id,cpd.inventory_item_id)
      and    cutt.forecast_rule_id = cpp.forecast_rule_id
      and    cutt.transaction_type_id = mmt.transaction_type_id
      and    mmt.transaction_date between trunc(sysdate) - (cfrb.history_periods*cfrb.period_size) and trunc(sysdate)
      group by cpd.inventory_item_id,
             cpd.related_item_id,
             cpd.organization_id,
             cpd.source_organization_id,
             trunc(trunc(sysdate) - round((trunc(sysdate) - trunc(mmt.transaction_date))/cfrb.period_size)*cfrb.period_size);

     insert into csp_plan_details(
             plan_detail_type,
             parent_type,
             source_number,
             source_organization_id,
             quantity,
             plan_date,
             inventory_item_id,
             organization_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login,
             forecast_periods,
             period_size)
	  select min('6000'),
	  		 null,
	  		 null,
	  		 cpd.source_organization_id,
	   		 sum(quantity),
       		 cpd.plan_date,
	   		 cpd.inventory_item_id,
	  		 cpd.organization_id,
	  		 fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id,
             max(a.history_periods),
             max(a.period_size)
      from   csp_plan_details cpd,
             (select round(max(cfrb.history_periods*cfrb.period_size)/max(cfrb.period_size)+0.499999) history_periods,max(cfrb.period_size) period_size,cpd.organization_id,cpd.inventory_item_id
              from   csp_forecast_rules_b cfrb,
                     csp_planning_parameters cpp,
                     csp_plan_details cpd
              where  cfrb.forecast_rule_id = cpp.forecast_rule_id
              and    cpd.plan_detail_type in ('6100','6200')
              and    cpd.source_organization_id = cpp.organization_id
              group by cpd.organization_id, cpd.inventory_item_id) a
      where  cpd.plan_detail_type in ('6100','6200')
      and    cpd.organization_id = l_organization_id
      and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
      and    a.inventory_item_id = cpd.inventory_item_id
      and    a.organization_id = cpd.organization_id
      group by cpd.plan_date,cpd.inventory_item_id,cpd.organization_id,cpd.source_organization_id;

-- Delete 6100 if no 6200 exists, to allow for better display of defective returns
      delete from csp_plan_details cpd
      where cpd.plan_detail_type = '6100'
      and   cpd.organization_id = l_organization_id
      and   cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
      and  not exists
      (select 'x'
       from   csp_plan_details
       where  plan_detail_type = '6200'
       and    inventory_item_id = cpd.inventory_item_id
       and    organization_id = cpd.organization_id);
end return_history;

PROCEDURE return_forecast IS

  l_forecast              number := 0;
  l_period                number := 1;
  l_previous_base         number := 0;
  l_trend                 number := 0;
  l_item                  number := null;
  l_start                 number := 0;
  l_repair_lead_time      number := 0;

  cursor c_items is
  select cpd.organization_id,
         cpd.inventory_item_id,
         l_history_periods - round((trunc(sysdate) - trunc(plan_date))/l_forecast_period_size) period,
         quantity,
         alpha,
         beta,
         nvl(cpl.repair_lead_time,0) repair_lead_time
  from   csp_plan_details cpd,
         csp_plan_leadtimes cpl,
         csp_forecast_rules_b cfrb
  where  cpd.organization_id = l_organization_id
  and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
  and    cpd.plan_detail_type = '6000'
  and    cfrb.forecast_rule_id = l_forecast_rule_id
  and    cpl.organization_id = cpd.organization_id
  and    cpl.inventory_item_id = cpd.inventory_item_id
  order by cpd.organization_id,
         cpd.inventory_item_id,
         plan_date;

begin

  insert into csp_plan_details(
         plan_detail_type,
         parent_type,
         source_number,
         source_organization_id,
         quantity,
         plan_date,
         inventory_item_id,
         organization_id,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login)
  select '7000',
         null,
         null,
         null,
         a.quantity,
         trunc(sysdate + cpl.repair_lead_time + (rownum-1) * l_period_size),
         cpd.inventory_item_id,
         cpd.organization_id,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.login_id
  from   csp_plan_details cpd,
         csp_plan_leadtimes cpl,
    (select round(sum(cpd2.quantity* l_period_size /cfrb.period_size/cfrb.history_periods)) quantity,
            cpd2.organization_id organization_id,
            cpd2.inventory_item_id inventory_item_id
    from   csp_plan_details cpd2,
           csp_forecast_rules_b cfrb,
           csp_planning_parameters cpp
    where  cpd2.plan_detail_type = '6000'
    and    cpp.organization_id = cpd2.source_organization_id
    and    cfrb.forecast_rule_id = cpp.forecast_rule_id
    and    cfrb.forecast_method in (1,3,4)
    group by cpd2.organization_id,
           cpd2.inventory_item_id) a
  where    cpd.organization_id = l_organization_id
  and      cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
  and      a.organization_id = cpd.organization_id
  and      a.inventory_item_id = cpd.inventory_item_id
  and      cpl.organization_id = cpd.organization_id
  and      cpl.inventory_item_id = cpd.inventory_item_id
  and      rownum <= l_forecast_periods;

  insert into csp_plan_details(
         plan_detail_type,
         parent_type,
         source_number,
         source_organization_id,
         quantity,
         plan_date,
         inventory_item_id,
         organization_id,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login)
  select '7000',
         null,
         null,
         null,
         a.quantity,
         trunc(sysdate + cpl.repair_lead_time + (rownum-1) * l_period_size),
         cpd.inventory_item_id,
         cpd.organization_id,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.login_id
  from   csp_plan_details cpd,
         csp_plan_leadtimes cpl,
    (select round(sum(quantity*decode(round((trunc(sysdate)-trunc(plan_date))/l_forecast_period_size),
		 	1,weighted_avg_period1,
			2,weighted_avg_period2,
			3,weighted_avg_period3,
			4,weighted_avg_period4,
			5,weighted_avg_period5,
			6,weighted_avg_period6,
			7,weighted_avg_period7,
			8,weighted_avg_period8,
			9,weighted_avg_period9,
			10,weighted_avg_period10,
			11,weighted_avg_period11,
			12,weighted_avg_period12))*l_period_size/l_forecast_period_size) quantity,
            cpd2.organization_id organization_id,
            cpd2.inventory_item_id inventory_item_id
    from   csp_plan_details cpd2,
           csp_forecast_rules_b cfrb,
           csp_planning_parameters cpp
    where  cpd2.plan_detail_type = '6000'
    and    cpp.organization_id = cpd2.source_organization_id
    and    cfrb.forecast_rule_id = cpp.forecast_rule_id
    and    cfrb.forecast_method = 2
    group by cpd2.organization_id,
           cpd2.inventory_item_id) a
  where    cpd.organization_id = l_organization_id
  and      cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
  and      a.organization_id = cpd.organization_id
  and      a.inventory_item_id = cpd.inventory_item_id
  and      cpl.organization_id = cpd.organization_id
  and      cpl.inventory_item_id = cpd.inventory_item_id
  and      rownum <= l_forecast_periods;

  if l_forecast_method = -3 then
    for cr in c_items loop
      if nvl(l_item,cr.inventory_item_id) <> cr.inventory_item_id  then
        insert into csp_plan_details(
             plan_detail_type,
             parent_type,
             source_number,
             source_organization_id,
             quantity,
             plan_date,
             inventory_item_id,
             organization_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login)
        select '7000',
             null,
             null,
             null,
             l_forecast * l_period_size/l_forecast_period_size,
             trunc(sysdate + cr.repair_lead_time + (rownum-1) * l_period_size),
             l_item,
             l_organization_id,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id
        from csp_plan_details
        where organization_id = l_organization_id
        and   rownum <= l_forecast_periods;
        l_start := 1;
        l_forecast := 0;
      end if;
      l_item := cr.inventory_item_id;
      l_repair_lead_time := cr.repair_lead_time;
      for l_period in l_start..cr.period loop
        if cr.period = 1 then
          l_forecast := cr.quantity;
        elsif l_period < cr.period then
          l_forecast := nvl(l_forecast,0) * (1 - cr.alpha);
        elsif l_period = cr.period then
          l_forecast := cr.quantity * cr.alpha + nvl(l_forecast,0) * (1 - cr.alpha);
        end if;
        l_start := l_period + 1;
      end loop;
    end loop;
    insert into csp_plan_details(
             plan_detail_type,
             parent_type,
             source_number,
             source_organization_id,
             quantity,
             plan_date,
             inventory_item_id,
             organization_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login)
    select   '7000',
             null,
             null,
             null,
             l_forecast * l_period_size/l_forecast_period_size,
             trunc(sysdate + l_repair_lead_time + (rownum -1) * l_period_size),
             l_item,
             l_organization_id,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id
    from     csp_plan_details
    where    organization_id = l_organization_id
    and      rownum <= l_forecast_periods;
  elsif l_forecast_method = -4 then
    for cr in c_items loop
      if nvl(l_item,cr.inventory_item_id) <> cr.inventory_item_id then
        insert into csp_plan_details(
             plan_detail_type,
             parent_type,
             source_number,
             source_organization_id,
             quantity,
             plan_date,
             inventory_item_id,
             organization_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login)
        select '7000',
             null,
             null,
             null,
             l_forecast + l_trend * rownum * l_period_size/l_forecast_period_size,
             trunc(sysdate + cr.repair_lead_time + (rownum-1) * l_period_size),
             l_item,
             l_organization_id,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id
        from csp_plan_details
        where organization_id = l_organization_id
        and   rownum <= l_forecast_periods;
        l_start := 1;
        l_forecast := 0;
        l_trend := 0;
        l_previous_base := 0;
      end if;

      l_item := cr.inventory_item_id;
      l_repair_lead_time := cr.repair_lead_time;

      for l_period in l_start..cr.period loop
        l_previous_base := l_forecast;
        if cr.period = 1 then
          l_forecast := cr.quantity;
        elsif l_period < cr.period then
          l_forecast := nvl(l_forecast,0) * (1 - cr.alpha);
        elsif l_period = cr.period then
          l_forecast := cr.quantity * cr.alpha + nvl(l_forecast,0) * (1 - cr.alpha);
        end if;
        if l_period = 2 then
          l_trend := nvl(l_forecast,0) - l_previous_base;
        elsif l_period > 2 then
          l_trend := (nvl(l_forecast,0) - l_previous_base) * cr.beta + l_trend * (1 - cr.beta);
        end if;
        l_start := l_period + 1;
      end loop;
    end loop;
    insert into csp_plan_details(
             plan_detail_type,
             parent_type,
             source_number,
             source_organization_id,
             quantity,
             plan_date,
             inventory_item_id,
             organization_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login)
    select   '7000',
             null,
             null,
             null,
             l_forecast + l_trend * rownum * l_period_size/l_forecast_period_size,
             trunc(sysdate + l_repair_lead_time + (rownum-1) * l_period_size),
             l_item,
             l_organization_id,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id
    from     csp_plan_details
    where    organization_id = l_organization_id
    and      rownum <= l_forecast_periods;

  end if;

end return_forecast;

  procedure forecast is
    begin
      for l_counter in 1..l_forecast_periods loop
      -- Usage Forecast
      insert into csp_plan_details(
             plan_detail_type,
             parent_type,
             source_number,
             source_organization_id,
             quantity,
             plan_date,
             inventory_item_id,
             organization_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login)
      select '1100',
             min('1000'),
             null,
             null,
             round(sum(quantity*l_period_size/cfrb.period_size)),
             trunc(sysdate) + (l_counter - 1) * l_period_size,
             inventory_item_id,
             organization_id,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id
      from   csp_usage_histories cuh,
             csp_forecast_rules_b cfrb
      where  history_data_type = 2
      and    period_start_date between decode(l_forecast_method,4,trunc(sysdate) + (l_counter - 1) * l_period_size,period_start_date)
                               and     decode(l_forecast_method,4,trunc(sysdate) + (l_counter - 1) * l_period_size + (l_period_size - 1),trunc(sysdate) + l_period_size * l_forecast_periods - 1)
      and    organization_id = l_organization_id
      and    subinventory_code = '-'
      and    inventory_item_id = nvl(l_inventory_item_id,inventory_item_id)
      and    cfrb.forecast_rule_id = l_forecast_rule_id
      and    cuh.quantity > 0
      group by decode(history_data_type,2,'1100',7,'1300',8,'1400'),
             trunc(sysdate) + (l_counter - 1) * l_period_size,
             inventory_item_id,
             organization_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id;
-- Manual Forecast
      insert into csp_plan_details(
             plan_detail_type,
             parent_type,
             source_number,
             source_organization_id,
             quantity,
             plan_date,
             inventory_item_id,
             organization_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login)
      select decode(history_data_type,7,'1300',8,'1400'),
             min('1000'),
             null,
             null,
             sum(quantity),
             trunc(sysdate) + (l_counter - 1) * l_period_size,
             inventory_item_id,
             organization_id,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id
      from   csp_usage_histories cuh
      where  history_data_type in (7,8)
      and    period_start_date between trunc(sysdate) + (l_counter - 1) * l_period_size
                               and     trunc(sysdate) + l_counter * l_period_size - 1
      and    organization_id = l_organization_id
      and    subinventory_code = '-'
      and    inventory_item_id = nvl(l_inventory_item_id,inventory_item_id)
      group by decode(history_data_type,7,'1300',8,'1400'),
             trunc(sysdate) + (l_counter - 1) * l_period_size,
             inventory_item_id,
             organization_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id;

      -- Population Forecast
      insert into csp_plan_details(
             plan_detail_type,
             parent_type,
             source_number,
             source_organization_id,
             quantity,
             plan_date,
             inventory_item_id,
             organization_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login)
      select '1200',
             '1000',
             null,
             null,
             round(sum(cpc.population_change*nvl(cfr.manual_failure_rate,cfr.calculated_failure_rate)/7 * l_period_size *
             (least(cpc.end_date,(trunc(sysdate)+(l_counter)*l_period_size)) - trunc(sysdate))/(cpc.end_date - cpc.start_date))),
             trunc(sysdate) +      (l_counter-1) * l_period_size,
             cfr.inventory_item_id,
             cpc.organization_id,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id
      from   csp_failure_rates cfr,
             csp_population_changes cpc,
             csp_planning_parameters cpp
      where  cfr.inventory_item_id = nvl(l_inventory_item_id,cfr.inventory_item_id)
      and    cfr.product_id = cpc.product_id
      and    cpc.organization_id = l_organization_id
      and    cpp.organization_id = cpc.organization_id
      and    cpp.organization_type = 'W'
      and    cfr.planning_parameters_id = cpp.product_norm_node_id
      and    trunc(cpc.end_date) > trunc(sysdate)
      and    trunc(cpc.start_date) < trunc(sysdate)+(l_counter-1)*l_period_size
      group by
             cpc.organization_id,
             cfr.inventory_item_id;
      commit;
      end loop;

      -- Warehouse Planned Orders
      insert into csp_plan_details(
             plan_detail_type,
             parent_type,
             source_number,
             source_organization_id,
             quantity,
             plan_date,
             inventory_item_id,
             organization_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login)
      select max('1610'),
             max('1600'),
             null,
             cpd.organization_id,
             greatest(sum(cpd.quantity),0),
             max(trunc(trunc(sysdate) + ((cpd.plan_date - trunc(sysdate))/l_period_size)*l_period_size)),
             cpd.inventory_item_id,
             cpd.source_organization_id,
             max(fnd_global.user_id),
             max(sysdate),
             max(fnd_global.user_id),
             max(sysdate),
             max(fnd_global.login_id)
      from   csp_plan_details cpd
      where  cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
      and    cpd.source_organization_id = l_organization_id
      and    cpd.plan_detail_type = '4310'
      group by cpd.organization_id,cpd.inventory_item_id,cpd.source_organization_id,cpd.plan_date;--heh
      commit;
            insert into csp_plan_details(
             plan_detail_type,
             parent_type,
             source_number,
             source_organization_id,
             quantity,
             plan_date,
             inventory_item_id,
             organization_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login)
      select max('1600'),
             max('1000'),
             null,
             null,
             greatest(sum(cpd.quantity),0),
             cpd.plan_date,
             cpd.inventory_item_id,
             cpd.organization_id,
             max(fnd_global.user_id),
             max(sysdate),
             max(fnd_global.user_id),
             max(sysdate),
             max(fnd_global.login_id)
      from   csp_plan_details cpd
      where  cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
      and    cpd.organization_id = l_organization_id
      and    cpd.plan_detail_type = '1610'
      group by
             cpd.organization_id,
             cpd.inventory_item_id,
             cpd.plan_date;
      commit;

    end forecast;


  procedure orders is
  begin
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select min('1500'),
           min('1000'),
           null,
           null,
           sum(nvl(oola.ordered_quantity,0) - nvl(oola.cancelled_quantity,0) - nvl(oola.shipped_quantity,0)),
           decode(sign(trunc(nvl(oola.schedule_ship_date,nvl(oola.promise_date,oola.request_date)))-trunc(sysdate)),
                  -1,trunc(sysdate-l_period_size),
                   0,trunc(sysdate),
                   1,trunc(sysdate) + trunc((trunc(nvl(oola.schedule_ship_date,nvl(oola.promise_date,oola.request_date)))-trunc(sysdate))/l_period_size)*l_period_size),
           oola.inventory_item_id,
           oola.ship_from_org_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   oe_order_lines_all oola
    where  oola.ship_from_org_id = l_organization_id
    and    oola.open_flag         =  'Y'
    and    nvl(oola.order_source_id,0) <> 10
    and    nvl(oola.schedule_ship_date,nvl(oola.promise_date,oola.request_date)) < trunc(sysdate) + l_period_size * l_forecast_periods
    and    oola.inventory_item_id = nvl(l_inventory_item_id,oola.inventory_item_id)
    group by
           decode(sign(trunc(nvl(oola.schedule_ship_date,nvl(oola.promise_date,oola.request_date)))-trunc(sysdate)),
                  -1,trunc(sysdate-l_period_size),
                   0,trunc(sysdate),
                   1,trunc(sysdate) + trunc((trunc(nvl(oola.schedule_ship_date,nvl(oola.promise_date,oola.request_date)))-trunc(sysdate))/l_period_size)*l_period_size),
           oola.inventory_item_id,
           oola.ship_from_org_id;
  end orders;

  procedure supply is
  begin
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select decode(nvl(cpt.req_line_id,nvl(crph.requisition_header_id,nvl(ms.from_organization_id*-1,-1))),
                  -1,'2310',
                  ms.from_organization_id*-1,'2110',
                  crph.requisition_header_id,'2210',
                  cpt.req_line_id,'2210'),
           decode(nvl(cpt.req_line_id,nvl(crph.requisition_header_id,nvl(ms.from_organization_id*-1,-1))),
                  -1,'2300',
                  ms.from_organization_id*-1,'2100',
                  crph.requisition_header_id,'2200',
                  cpt.req_line_id,'2200'),
           pv.vendor_name||'.'||pha.segment1,
           nvl(ms.from_organization_id,-1),
           sum(to_org_primary_quantity),
           trunc(nvl(expected_delivery_date,nvl(crph.need_by_date,nvl(ms.need_by_date,trunc(sysdate))))),
           ms.item_id,
           ms.to_organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   mtl_supply ms,
           csp_repair_po_headers crph,
           po_headers_all pha,
           po_vendors pv,
           csd_product_transactions cpt
    where  ms.to_organization_id = l_organization_id
    and	   ms.item_id > 0
    and    ms.supply_type_code <> 'REQ'
    and    ms.item_id = nvl(l_inventory_item_id,ms.item_id)
    and    crph.purchase_order_header_id(+) = ms.po_header_id
    and    pha.po_header_id = ms.po_header_id
    and    pha.vendor_id = pv.vendor_id
    and    cpt.req_line_id(+) = ms.req_line_id
    group by decode(nvl(cpt.req_line_id,nvl(crph.requisition_header_id,nvl(ms.from_organization_id*-1,-1))),
                  -1,'2310',
                  ms.from_organization_id*-1,'2110',
                  crph.requisition_header_id,'2210',
                  cpt.req_line_id,'2210'),
           decode(nvl(cpt.req_line_id,nvl(crph.requisition_header_id,nvl(ms.from_organization_id*-1,-1))),
                  -1,'2300',
                  ms.from_organization_id*-1,'2100',
                  crph.requisition_header_id,'2200',
                  cpt.req_line_id,'2200'),
           pv.vendor_name||'.'||pha.segment1,
           nvl(ms.from_organization_id,-1),
           trunc(nvl(expected_delivery_date,nvl(crph.need_by_date,nvl(ms.need_by_date,trunc(sysdate))))),
           ms.item_id,
           ms.to_organization_id;

    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select decode(nvl(cpt.req_line_id,nvl(crph.requisition_header_id,nvl(ms.from_organization_id*-1,-1))),
                  -1,'2310',
                  ms.from_organization_id*-1,'2110',
                  crph.requisition_header_id,'2210',
                  cpt.req_line_id,'2210'),
           decode(nvl(cpt.req_line_id,nvl(crph.requisition_header_id,nvl(ms.from_organization_id*-1,-1))),
                  -1,'2300',
                  ms.from_organization_id*-1,'2100',
                  crph.requisition_header_id,'2200',
                  cpt.req_line_id,'2200'),
           nvl(ooha.order_number,prha.segment1),
           nvl(ms.from_organization_id,-1),
           sum(ms.to_org_primary_quantity),
           trunc(nvl(ms.expected_delivery_date,nvl(crph.need_by_date,nvl(ms.need_by_date,trunc(sysdate))))),
           ms.item_id,
           ms.to_organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   mtl_supply ms,
           csp_repair_po_headers crph,
           po_requisition_headers_all prha,
           oe_order_headers_all ooha,
           csd_product_transactions cpt
    where  ms.to_organization_id = l_organization_id
    and	   ms.item_id > 0
    and    ms.supply_type_code = 'REQ'
    and    ms.item_id = nvl(l_inventory_item_id,ms.item_id)
    and    crph.requisition_header_id(+) = ms.req_header_id
    and    prha.requisition_header_id = ms.req_header_id
    and    ooha.order_source_id(+) = 10
    and    ooha.orig_sys_document_ref(+) = prha.segment1
    and    cpt.req_line_id(+) = ms.req_line_id
    group by decode(nvl(cpt.req_line_id,nvl(crph.requisition_header_id,nvl(ms.from_organization_id*-1,-1))),
                  -1,'2310',
                  ms.from_organization_id*-1,'2110',
                  crph.requisition_header_id,'2210',
                  cpt.req_line_id,'2210'),
           decode(nvl(cpt.req_line_id,nvl(crph.requisition_header_id,nvl(ms.from_organization_id*-1,-1))),
                  -1,'2300',
                  ms.from_organization_id*-1,'2100',
                  crph.requisition_header_id,'2200',
                  cpt.req_line_id,'2200'),
           nvl(ooha.order_number,prha.segment1),
           nvl(ms.from_organization_id,-1),
           trunc(nvl(ms.expected_delivery_date,nvl(crph.need_by_date,nvl(ms.need_by_date,trunc(sysdate))))),
           ms.item_id,
           ms.to_organization_id;

    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select decode(pria.source_type_code,'VENDOR',decode(crph.requisition_line_id,null,'2310','2210'),'2110'),
           decode(pria.source_type_code,'VENDOR',decode(crph.requisition_line_id,null,'2300','2200'),'2100'),
           pria.req_number_segment1,
           nvl(pria.source_organization_id,-1),
           pria.quantity,
           trunc(nvl(pria.need_by_date,nvl(crph.need_by_date,trunc(sysdate)))),
           pria.item_id,
           pria.destination_organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   po_requisitions_interface_all pria,
           csp_repair_po_headers crph
    where  pria.destination_organization_id = l_organization_id
    and    pria.item_id = nvl(l_inventory_item_id,pria.item_id)
    and    crph.requisition_line_id(+) = pria.requisition_line_id;
/* Not needed
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select '2310',
           '2300',
           wjsi.job_name,
           wjsi.organization_id,
           wjsi.start_quantity,
           trunc(nvl(wjsi.last_unit_completion_date,sysdate)),
           wjsi.primary_item_id,
           wjsi.organization_id,
           -1001012,--fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   wip_job_schedule_interface wjsi
    where  wjsi.organization_id = l_organization_id
    and    wjsi.primary_item_id = nvl(l_inventory_item_id,wjsi.primary_item_id);
*/
  end supply;

  procedure total_requirement is
  begin

    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select parent_type,
           '1',
           null,
           null,
           greatest(sum(quantity),0),
           plan_date,
           inventory_item_id,
           organization_id,
           min(created_by),
           min(creation_date),
           min(last_updated_by),
           min(last_update_date),
           min(last_update_login)
    from   csp_plan_details cpd
    where  parent_type = '1000'
    and    plan_detail_type in ('1100','1200','1300','1500','1600')
    and    organization_id = l_organization_id
    and    inventory_item_id = nvl(l_inventory_item_id,inventory_item_id)
    and    not exists (select 'x'
                      from csp_plan_details
                      where organization_id = cpd.organization_id
                      and   inventory_item_id = cpd.inventory_item_id
                      and   plan_date = cpd.plan_date
                      and   plan_detail_type = '1400')
    group by parent_type,'1',null,null,plan_date,inventory_item_id,organization_id;

    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select parent_type,
           '1',
           null,
           null,
           greatest(sum(quantity),0),
           plan_date,
           inventory_item_id,
           organization_id,
           min(created_by),
           min(creation_date),
           min(last_updated_by),
           min(last_update_date),
           min(last_update_login)
    from   csp_plan_details cpd
    where  parent_type = '1000'
    and    plan_detail_type in ('1400','1500','1600')
    and    organization_id = l_organization_id
    and    inventory_item_id = nvl(l_inventory_item_id,inventory_item_id)
    and    not exists (select 'x'
                      from csp_plan_details
                      where organization_id = cpd.organization_id
                      and   inventory_item_id = cpd.inventory_item_id
                      and   plan_date = cpd.plan_date
                      and   plan_detail_type in ('1000'))
    group by parent_type,'1',null,null,plan_date,inventory_item_id,organization_id;


  end total_requirement;

  procedure total_on_order is
  begin
  --Total On Order
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select parent_type,
           '2000',
           null,
           null,
           sum(quantity),
           plan_date, --hehtrunc(greatest(trunc(sysdate) + floor(((plan_date - trunc(sysdate))/l_period_size))*l_period_size,trunc(sysdate) - l_period_size)),
           inventory_item_id,
           organization_id,
           min(created_by),
           min(creation_date),
           min(last_updated_by),
           min(last_update_date),
           min(last_update_login)
    from   csp_plan_details
    where  parent_type in ('2100','2200','2300')
    and    organization_id = l_organization_id
    and    inventory_item_id = nvl(l_inventory_item_id,inventory_item_id)
    group by parent_type,plan_date,--trunc(greatest(trunc(sysdate) + floor(((plan_date - trunc(sysdate))/l_period_size))*l_period_size,trunc(sysdate) - l_period_size)),
          inventory_item_id,organization_id;

    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select min('2000'),
           min('1'),
           null,
           null,
           sum(quantity),
           plan_date,
           inventory_item_id,
           organization_id,
           min(created_by),
           min(creation_date),
           min(last_updated_by),
           min(last_update_date),
           min(last_update_login)
    from   csp_plan_details
    where  plan_detail_type in ('2100','2200','2300')
    and    organization_id = l_organization_id
    and    inventory_item_id = nvl(l_inventory_item_id,inventory_item_id)
    group by organization_id,inventory_item_id,plan_date;

  end total_on_order;

  procedure unfilled_requirement(p_source_type varchar2) is
    i       number := 0;
    begin
      for i in 0..l_forecast_periods loop
        insert into csp_plan_details(
               plan_detail_type,
               parent_type,
               source_number,
               source_organization_id,
               quantity,
               plan_date,
               inventory_item_id,
               organization_id,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login)
        select
               min('9004'),
               min('1'),
               null,
               null,
               least(0,sum(decode(cpd.plan_detail_type,'1000',decode(sign(trunc(sysdate+6+i*l_period_size)-cpd.plan_date),-1,0,cpd.quantity*-1),
                                                       '4220',decode(sign(trunc(sysdate+6+i*l_period_size)-cpd.plan_date),-1,0,cpd.quantity),
                                                       '1'   ,cpd.available_quantity,cpd.quantity))
               - decode(p_source_type,
                          'EXCESS',min(nvl(cpr.excess_safety_stock,0)),
                          'REPAIR',min(nvl(cpr.repair_safety_stock,0)),
                          'REPAIR_FORECAST',min(nvl(cpr.repair_safety_stock,0)),
                          'NEWBUY',min(nvl(cpr.newbuy_safety_stock,0)))) * -1,
               min(trunc(sysdate+i*l_period_size)),
               cpd.inventory_item_id,
               cpd.organization_id,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.login_id
        from   csp_plan_details cpd,
               csp_plan_reorders cpr
        where  cpd.plan_detail_type in ('1','1000','2000','4110','4210','4310','4220')
        and    cpr.organization_id (+) = cpd.organization_id
        and    cpr.inventory_item_id (+) = cpd.inventory_item_id
        and    cpd.organization_id = nvl(l_organization_id,cpd.organization_id)
        and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
        group by cpd.organization_id,cpd.inventory_item_id;
/*
        where  cpd.plan_detail_type in ('1','4110','4210','4310','4220')
        and        cpd2.plan_detail_type = '3000'
        and    cpd2.plan_date = trunc(sysdate+i*l_period_size)
        and        cpd2.organization_id = cpd.organization_id
        and        cpd2.inventory_item_id = cpd.inventory_item_id
        and        cpd.plan_date <= trunc(sysdate+i*l_period_size)
        and    cpr.organization_id (+) = cpd.organization_id
        and    cpr.inventory_item_id (+) = cpd.inventory_item_id
        and    cpd.organization_id = nvl(l_organization_id,cpd.organization_id)
        and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
        group by cpd.organization_id,cpd.inventory_item_id;
*/
      end loop;
      -- delete unfilled requirement for parts that are superseded
      delete from csp_plan_details cpd
      where  (organization_id,inventory_item_id) in
      (select csi.organization_id,csi.inventory_item_id
       from   csp_supersede_items csi
       where  csi.inventory_item_id = cpd.inventory_item_id
       and    csi.organization_id = cpd.organization_id
       and    csi.sub_inventory_code = '-'
       and    csi.item_supplied <> csi.inventory_item_id)
      and    cpd.organization_id = l_organization_id
      and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
      and    cpd.plan_detail_type = '9004';

    end unfilled_requirement;

  procedure newbuy_excess_onorder is
  begin
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
   select
           min('8110'),
           null,
           null,
           null,
           greatest(0,least(sum(decode(cpd.plan_detail_type,'2300',nvl(cpd.quantity,0),0)),
           sum(decode(cpd.plan_detail_type,'2300',0,
                                           '1',nvl(cpd.available_quantity,0),
                                           nvl(cpd.quantity,0)))
           -greatest(nvl(cpr.newbuy_rop,0)+nvl(cpr.newbuy_edq,0)*nvl(min(cipp.newbuy_edq_multiple),nvl(l_edq_multiple,1)),
                      nvl(cpr.repair_rop,0)+nvl(cpr.repair_edq,0)*nvl(min(cipp.repair_edq_multiple),nvl(l_edq_multiple,1)),
                      nvl(cpr.excess_rop,0)+nvl(cpr.excess_edq,0)*nvl(min(cipp.excess_edq_multiple),nvl(l_edq_multiple,1)),0))) excess_cancel_newbuy,
           min(cpd.plan_date),
           cpd.inventory_item_id,
           cpd.organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   csp_plan_details cpd,
	       csp_plan_reorders cpr,
	       csp_item_pl_params cipp
    where  cpd.organization_id = l_organization_id
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    cpd.plan_detail_type in ('1','2000','2300')
    and    cpd.quantity > 0
    and	   cpr.organization_id(+) = cpd.organization_id
    and	   cpr.inventory_item_id(+) = cpd.inventory_item_id
    and	   cipp.organization_id(+) = cpd.organization_id
    and	   cipp.inventory_item_id(+) = cpd.inventory_item_id
    group by cpr.newbuy_rop,
           cpr.newbuy_edq,
           cpr.repair_rop,
           cpr.repair_edq,
           cpr.excess_rop,
           cpr.excess_edq,
           cpd.inventory_item_id,
           cpd.organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id;
-- Delete new buy excess on orders that have a value less than minimum value
    delete from csp_plan_details
    where  (plan_detail_type,organization_id,inventory_item_id) in
    (select cpd.plan_detail_type,cpd.organization_id,cpd.inventory_item_id
     from   csp_plan_details cpd,
            mtl_parameters mp,
            cst_item_costs cict
     where  cpd.plan_detail_type = '8110'
     and    mp.organization_id = cict.organization_id
     and    cict.inventory_item_id = cpd.inventory_item_id
     and    cict.organization_id = cpd.organization_id
     and    cict.cost_type_id = mp.primary_cost_method
     and    cpd.organization_id = l_organization_id
     and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
     and    nvl(cpd.quantity * cict.item_cost,1) <= l_minimum_value);
  end;

 procedure unutilized_excess is
  begin
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select min('8210'), --Cancel new-buy
           null,
           null,
           null,
           greatest(least(sum(decode(cpd.plan_detail_type,'8110',nvl(cpd.quantity*-1,0),'2300',nvl(cpd.quantity,0),0)),
                 sum(decode(cpd.plan_detail_type,'4110',nvl(cpd.quantity*-1,0),'9001',nvl(cpd.quantity,0),0))),0),
           min(cpd.plan_date),
           cpd.inventory_item_id,
           cpd.organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   csp_plan_details cpd,
	       csp_plan_reorders cpr
    where  cpd.organization_id = l_organization_id
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    cpd.plan_detail_type in ('2300','8110','4110','9001')
    and    cpd.quantity > 0
    and	   cpr.organization_id(+) = cpd.organization_id
    and	   cpr.inventory_item_id(+) = cpd.inventory_item_id
    group by cpr.newbuy_rop,
           cpr.newbuy_edq,
           cpr.repair_rop,
           cpr.repair_edq,
           cpr.excess_rop,
           cpr.excess_edq,
           cpd.inventory_item_id,
           cpd.organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id;
/*
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select min('8220'), --Cancel repair
           null,
           null,
           null,
           greatest(least(sum(decode(cpd.plan_detail_type,'8120',nvl(cpd.quantity*-1,0),'2200',nvl(cpd.quantity,0),0)),
                 sum(decode(cpd.plan_detail_type,'2100',nvl(cpd.quantity*-1,0),'8210',nvl(cpd.quantity*-1,0),'9001',nvl(cpd.quantity,0),0))),0),
           min(cpd.plan_date),
           cpd.inventory_item_id,
           cpd.organization_id,
           -10014,--fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   csp_plan_details cpd,
	       csp_plan_reorders cpr
    where  cpd.organization_id = l_organization_id
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    cpd.plan_detail_type in ('2100','2200','8120','8210','9001')
    and    cpd.quantity > 0
    and	   cpr.organization_id(+) = cpd.organization_id
    and	   cpr.inventory_item_id(+) = cpd.inventory_item_id
    group by cpr.newbuy_rop,
           cpr.newbuy_edq,
           cpr.repair_rop,
           cpr.repair_edq,
           cpr.excess_rop,
           cpr.excess_edq,
           cpd.inventory_item_id,
           cpd.organization_id,
           -10016,--fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id;
*/
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select min('8220'), --Cancel repair
           null,
           null,
           null,
           greatest(least(sum(decode(cpd.plan_detail_type,'8120',nvl(cpd.quantity*-1,0),'2200',nvl(cpd.quantity,0),0)),
                 sum(decode(cpd.plan_detail_type,'4100',nvl(cpd.quantity*-1,0),'8210',nvl(cpd.quantity*-1,0),'9001',nvl(cpd.quantity,0),0))),0),
           min(cpd.plan_date),
           cpd.inventory_item_id,
           cpd.organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   csp_plan_details cpd,
	       csp_plan_reorders cpr
    where  cpd.organization_id = l_organization_id
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    cpd.plan_detail_type in ('4100','2200','8120','8210','9001')
    and    cpd.quantity > 0
    and	   cpr.organization_id(+) = cpd.organization_id
    and	   cpr.inventory_item_id(+) = cpd.inventory_item_id
    group by cpr.newbuy_rop,
           cpr.newbuy_edq,
           cpr.repair_rop,
           cpr.repair_edq,
           cpr.excess_rop,
           cpr.excess_edq,
           cpd.inventory_item_id,
           cpd.organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id;

    delete from csp_plan_details
    where  (plan_detail_type,organization_id,inventory_item_id) in
    (select cpd.plan_detail_type,cpd.organization_id,cpd.inventory_item_id
     from   csp_plan_details cpd,
            mtl_parameters mp,
            cst_item_costs cict
     where  cpd.plan_detail_type in ('8210','8220')
     and    mp.organization_id = cict.organization_id
     and    cict.inventory_item_id = cpd.inventory_item_id
     and    cict.organization_id = cpd.organization_id
     and    cict.cost_type_id = mp.primary_cost_method
     and    cpd.organization_id = l_organization_id
     and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
     and    nvl(cpd.quantity * cict.item_cost,1) <= l_minimum_value);
  end;

 procedure unutilized_repair is
  begin
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select min('8310'), --Cancel new-buy
           null,
           null,
           null,
           greatest(least(sum(decode(cpd.plan_detail_type,'4200',nvl(cpd.quantity*-1,0),'9002',nvl(cpd.available_quantity,0),'9003',nvl(cpd.available_quantity,0),0)),
                 sum(decode(cpd.plan_detail_type,'8110',nvl(cpd.quantity*-1,0),'8210',nvl(cpd.quantity*-1,0),'2300',nvl(cpd.quantity,0),0))),0),
           min(cpd.plan_date),
           cpd.inventory_item_id,
           cpd.organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   csp_plan_details cpd,
	       csp_plan_reorders cpr
    where  cpd.organization_id = l_organization_id
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    cpd.plan_detail_type in ('4200','2300','8110','8210','9002','9003')
    and    cpd.quantity > 0
    and	   cpr.organization_id(+) = cpd.organization_id
    and	   cpr.inventory_item_id(+) = cpd.inventory_item_id
    group by cpr.newbuy_rop,
           cpr.newbuy_edq,
           cpr.repair_rop,
           cpr.repair_edq,
           cpr.excess_rop,
           cpr.excess_edq,
           cpd.inventory_item_id,
           cpd.organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id;

    delete from csp_plan_details
    where  (plan_detail_type,organization_id,inventory_item_id) in
    (select cpd.plan_detail_type,cpd.organization_id,cpd.inventory_item_id
     from   csp_plan_details cpd,
            mtl_parameters mp,
            cst_item_costs cict
     where  cpd.plan_detail_type = '8310'
     and    mp.organization_id = cict.organization_id
     and    cict.inventory_item_id = cpd.inventory_item_id
     and    cict.organization_id = cpd.organization_id
     and    cict.cost_type_id = mp.primary_cost_method
     and    cpd.organization_id = l_organization_id
     and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
     and    nvl(cpd.quantity * cict.item_cost,1) <= l_minimum_value);
  end;

  procedure repair_excess_onorder is
  begin
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select min('8120'),
           null,
           null,
           null,
           greatest(least(sum(decode(cpd.plan_detail_type,'2200',nvl(cpd.quantity,0),0)),
           sum(decode(cpd.plan_detail_type,
                      '1',nvl(cpd.available_quantity,0),
                      '8110',nvl(cpd.quantity*-1,0),
                      '2200',0,
                      nvl(cpd.quantity,0))) -
           greatest(nvl(cpr.newbuy_rop,0)+nvl(cpr.newbuy_edq,0)*nvl(min(cipp.newbuy_edq_multiple),nvl(l_edq_multiple,1)),
                      nvl(cpr.repair_rop,0)+nvl(cpr.repair_edq,0)*nvl(min(cipp.repair_edq_multiple),nvl(l_edq_multiple,1)),
                      nvl(cpr.excess_rop,0)+nvl(cpr.excess_edq,0)*nvl(min(cipp.excess_edq_multiple),nvl(l_edq_multiple,1)))),0),
           min(cpd.plan_date),
           cpd.inventory_item_id,
           cpd.organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   csp_plan_details cpd,
	       csp_plan_reorders cpr,
	       csp_item_pl_params cipp
    where  cpd.organization_id = l_organization_id
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    cpd.plan_detail_type in ('1','2000','2200','8110')
    and    cpd.quantity > 0
    and	   cpr.organization_id(+) = cpd.organization_id
    and	   cpr.inventory_item_id(+) = cpd.inventory_item_id
    and	   cipp.organization_id(+) = cpd.organization_id
    and	   cipp.inventory_item_id(+) = cpd.inventory_item_id
    group by cpr.newbuy_rop,
           cpr.newbuy_edq,
           cpr.repair_rop,
           cpr.repair_edq,
           cpr.excess_rop,
           cpr.excess_edq,
           cpd.inventory_item_id,
           cpd.organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id;

-- Delete repair excess on orders that have a value less than minimum value
    delete from csp_plan_details
    where  (plan_detail_type,organization_id,inventory_item_id) in
    (select cpd.plan_detail_type,cpd.organization_id,cpd.inventory_item_id
     from   csp_plan_details cpd,
            mtl_parameters mp,
            cst_item_costs cict
     where  cpd.plan_detail_type = '8120'
     and    mp.organization_id = cict.organization_id
     and    cict.inventory_item_id = cpd.inventory_item_id
     and    cict.organization_id = cpd.organization_id
     and    cict.cost_type_id = mp.primary_cost_method
     and    cpd.organization_id = l_organization_id
     and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
     and    nvl(cpd.quantity * cict.item_cost,1) <= l_minimum_value);
  end;

  procedure reschedule_in is
  begin
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           inventory_item_id,
           organization_id,
           plan_date,
           quantity,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select '8410',
           null,
           cpd.inventory_item_id,
           cpd.organization_id,
           cpd.plan_date,
           (cpd.quantity - decode(l_onhand_condition_in,
                                 0,0,
                                 1,greatest(cpr.repair_safety_stock,
                                              cpr.excess_safety_stock,
                                              cpr.newbuy_safety_stock),
                                 2,greatest(cpr.repair_rop,
                                              cpr.excess_rop,
                                              cpr.newbuy_rop)))*-1,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   csp_plan_details cpd,
           csp_plan_reorders cpr
    where  cpd.organization_id = l_organization_id
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    cpd.plan_detail_type = l_onhand_type_in
    and    cpd.quantity < decode(l_onhand_condition_in,
                                 0,0,
                                 1,greatest(cpr.repair_safety_stock,
                                              cpr.excess_safety_stock,
                                              cpr.newbuy_safety_stock),
                                 2,greatest(cpr.repair_rop,
                                              cpr.excess_rop,
                                              cpr.newbuy_rop))
    and    cpd.plan_date between trunc(sysdate+decode(nvl(l_start_day_in,0),0,l_period_size * -1,l_start_day_in))
                             and trunc(sysdate+l_end_day_in)
    and	   cpr.organization_id = cpd.organization_id
    and	   cpr.inventory_item_id = cpd.inventory_item_id
    and exists (select 'x'
                from csp_plan_details
                where organization_id = cpd.organization_id
                and   inventory_item_id = cpd.inventory_item_id
                and   plan_detail_type = '2000'
                and   quantity > 0
                and   plan_date >= cpd.plan_date)
                and   plan_date >= trunc(sysdate);

    delete from csp_plan_details
    where  (plan_detail_type,organization_id,inventory_item_id) in
    (select cpd.plan_detail_type,cpd.organization_id,cpd.inventory_item_id
     from   csp_plan_details cpd
     where  cpd.plan_detail_type = '8410'
     and    cpd.organization_id = l_organization_id
     and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
     group by cpd.plan_detail_type,cpd.organization_id,cpd.inventory_item_id
     having count(*) < l_periods_in);
  /*
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select '8410',
           null,
           cpd.inventory_item_id,
           cpd.organization_id,
           -1001872,--fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   csp_plan_details cpd,
           csp_plan_reorders cpr
    where  cpd.organization_id = l_organization_id
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    cpd.plan_detail_type = l_onhand_type_in
    and    cpd.quantity < decode(l_onhand_condition_in,
                                 0,0,
                                 1,greatest(cpr.repair_safety_stock,
                                              cpr.excess_safety_stock,
                                              cpr.newbuy_safety_stock),
                                 2,greatest(cpr.repair_rop,
                                              cpr.excess_rop,
                                              cpr.newbuy_rop))
    and    cpd.plan_date between trunc(sysdate+l_start_day_in) and trunc(sysdate+l_end_day_in)
    and	   cpr.organization_id = cpd.organization_id
    and	   cpr.inventory_item_id = cpd.inventory_item_id
    group by cpd.organization_id,cpd.inventory_item_id
    having count(*) > l_periods_in;
    */
  end reschedule_in;

  procedure reschedule_out is
  begin
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           inventory_item_id,
           organization_id,
           plan_date,
           quantity,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select '8420',
           null,
           cpd.inventory_item_id,
           cpd.organization_id,
           cpd.plan_date,
           cpd.quantity - greatest(cpr.repair_rop + cpr.repair_edq * l_edq_multiple_out,
                                       cpr.excess_rop + cpr.excess_edq * l_edq_multiple_out,
                                       cpr.newbuy_rop + cpr.newbuy_edq * l_edq_multiple_out),
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   csp_plan_details cpd,
           csp_plan_reorders cpr,
           cst_item_costs cic,
           mtl_parameters mp
    where  cpd.organization_id = l_organization_id
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    cpd.plan_detail_type = l_onhand_type_out
    and    cpd.quantity > greatest(cpr.repair_rop + cpr.repair_edq * l_edq_multiple_out,
                                   cpr.excess_rop + cpr.excess_edq * l_edq_multiple_out,
                                   cpr.newbuy_rop + cpr.newbuy_edq * l_edq_multiple_out)
    and    cpd.plan_date between trunc(sysdate+decode(nvl(l_start_day_out,0),0,l_period_size*-1,l_start_day_out)) and trunc(sysdate+l_end_day_out)
    and	   cpr.organization_id = cpd.organization_id
    and	   cpr.inventory_item_id = cpd.inventory_item_id
    and    cic.inventory_item_id = cpd.inventory_item_id
    and    cic.organization_id = cpd.organization_id
    and    cic.cost_type_id = mp.primary_cost_method
    and    mp.organization_id = cpd.organization_id
    and    cic.item_cost * (cpd.quantity - greatest(cpr.repair_rop + cpr.repair_edq * l_edq_multiple_out,
                                                    cpr.excess_rop + cpr.excess_edq * l_edq_multiple_out,
                                                    cpr.newbuy_rop + cpr.newbuy_edq * l_edq_multiple_out)) > l_onhand_value_out;

    delete from csp_plan_details
    where  (plan_detail_type,organization_id,inventory_item_id) in
    (select cpd.plan_detail_type,cpd.organization_id,cpd.inventory_item_id
     from   csp_plan_details cpd
     where  cpd.plan_detail_type = '8420'
     and    cpd.organization_id = l_organization_id
     and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
     group by cpd.plan_detail_type,cpd.organization_id,cpd.inventory_item_id
     having count(*) < l_periods_out);
  end reschedule_out;

  procedure excess_excess_onorder is
  begin
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select min('8130'),
           null,
           null,
           null,
           greatest(least(sum(decode(cpd.plan_detail_type,'2100',nvl(cpd.quantity,0),0)),
           sum(decode(cpd.plan_detail_type,
                      '8110',nvl(cpd.quantity*-1,0),
                      '8120',nvl(cpd.quantity*-1,0),
                      '2100',0,
                      '1'   ,nvl(cpd.available_quantity,0),
                      nvl(cpd.quantity,0)))
           - greatest(nvl(cpr.newbuy_rop,0)+nvl(cpr.newbuy_edq,0)*nvl(l_edq_multiple,1),
                      nvl(cpr.repair_rop,0)+nvl(cpr.repair_edq,0)*nvl(l_edq_multiple,1),
                      nvl(cpr.excess_rop,0)+nvl(cpr.excess_edq,0)*nvl(l_edq_multiple,1))),0),
           min(cpd.plan_date),
           cpd.inventory_item_id,
           cpd.organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   csp_plan_details cpd,
	       csp_plan_reorders cpr
    where  cpd.organization_id = l_organization_id
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    cpd.quantity > 0
    and    cpd.plan_detail_type in ('1','2000','2100','8110','8120')
    and	   cpr.organization_id(+) = cpd.organization_id
    and	   cpr.inventory_item_id(+) = cpd.inventory_item_id
    group by cpr.newbuy_rop,
           cpr.newbuy_edq,
           cpr.repair_rop,
           cpr.repair_edq,
           cpr.excess_rop,
           cpr.excess_edq,
           cpd.inventory_item_id,
           cpd.organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id;

-- Delete excess excess on orders that have a value less than minimum value
    delete from csp_plan_details
    where  (plan_detail_type,organization_id,inventory_item_id) in
    (select cpd.plan_detail_type,cpd.organization_id,cpd.inventory_item_id
     from   csp_plan_details cpd,
            mtl_parameters mp,
            cst_item_costs cict
     where  cpd.plan_detail_type = '8130'
     and    mp.organization_id = cict.organization_id
     and    cict.inventory_item_id = cpd.inventory_item_id
     and    cict.organization_id = cpd.organization_id
     and    cict.cost_type_id = mp.primary_cost_method
     and    cpd.organization_id = l_organization_id
     and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
     and    nvl(cpd.quantity * cict.item_cost,1) <= l_minimum_value);
  end;

  procedure excess is
  begin
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           available_quantity,
           excess_quantity,
           onhand_quantity,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select min('9001'),
           null,
           null,
           mislv.source_organization_id,
           nvl(csp_validate_pub.get_avail_qty(mislv.source_organization_id,null,null,mislv.inventory_item_id),0),
           greatest(0,nvl(csp_validate_pub.get_available_qty,0)
           - greatest(nvl(cpr.newbuy_rop,0)+nvl(cpr.newbuy_edq,0),
                      nvl(cpr.repair_rop,0)+nvl(cpr.repair_edq,0),
                      nvl(cpr.excess_rop,0)+nvl(cpr.excess_edq,0))),
           nvl(csp_validate_pub.get_onhand_qty,0),
           greatest(0,nvl(csp_validate_pub.get_available_qty,0)
           - greatest(nvl(cpr.newbuy_rop,0)+nvl(cpr.newbuy_edq,0),
                      nvl(cpr.repair_rop,0)+nvl(cpr.repair_edq,0),
                      nvl(cpr.excess_rop,0)+nvl(cpr.excess_edq,0))),
           min(trunc(sysdate)),
           mislv.inventory_item_id,
           l_organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   MRP_ITEM_SOURCING_LEVELS_V mislv,
	       csp_plan_reorders cpr,
	       csp_plan_details cpd
    where  mislv.organization_id = l_organization_id
    and    mislv.assignment_set_id = l_usable_assignment_set_id
    and    mislv.inventory_item_id = cpd.inventory_item_id
    and    mislv.sourcing_level not in (2,9)
    and    mislv.source_organization_id <> l_organization_id
    and	   cpr.organization_id(+) = mislv.source_organization_id
    and	   cpr.inventory_item_id(+) = mislv.inventory_item_id
    and    cpd.organization_id = l_organization_id
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    cpd.plan_detail_type = '1'
    group by cpr.newbuy_rop,
           cpr.newbuy_edq,
           cpr.repair_rop,
           cpr.repair_edq,
           cpr.excess_rop,
           cpr.excess_edq,
           mislv.inventory_item_id,
           mislv.source_organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id;
  end;

  procedure repair is
  begin
    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           available_quantity,
           onhand_quantity,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select '9002',
           null,
           null,
           mislv.source_organization_id,
           nvl(csp_validate_pub.get_avail_qty(mislv.source_organization_id,null,null,mislv.inventory_item_id),0),
           nvl(csp_validate_pub.get_onhand_qty,0),
           nvl(csp_validate_pub.get_available_qty,0),
           trunc(sysdate),
           mislv.inventory_item_id,
           cpd.organization_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   MRP_ITEM_SOURCING_LEVELS_V mislv,
	       csp_plan_details cpd
    where  mislv.organization_id = cpd.organization_id
    and    mislv.assignment_set_id = l_defective_assignment_set_id
    and    mislv.inventory_item_id = cpd.inventory_item_id
    and    mislv.sourcing_level not in (2,9)
    and    mislv.source_organization_id <> l_organization_id
    and    cpd.organization_id = l_organization_id
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    cpd.plan_detail_type = '1';

    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           available_quantity,
           onhand_quantity,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           related_item_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select '9003',
           null,
           null,
           mislv.source_organization_id,
           nvl(csp_validate_pub.get_avail_qty(mislv.source_organization_id,null,null,mri.inventory_item_id),0),
           nvl(csp_validate_pub.get_onhand_qty,0),
           nvl(csp_validate_pub.get_available_qty,0),
           trunc(sysdate),
           mri.related_item_id,
           cpd.organization_id,
           mri.inventory_item_id,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.login_id
    from   MRP_ITEM_SOURCING_LEVELS_V mislv,
	       csp_plan_details cpd,
	       mtl_related_items mri,
	       mtl_parameters mp
    where  mislv.organization_id = cpd.organization_id
    and    mislv.assignment_set_id = l_defective_assignment_set_id
    and    mislv.inventory_item_id = cpd.inventory_item_id
    and    mislv.sourcing_level not in (2,9)
    and    mislv.source_organization_id <> cpd.organization_id
    and    cpd.organization_id = l_organization_id
    and    cpd.plan_detail_type = '1'
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    mp.organization_id = cpd.organization_id
    and    mri.organization_id = mp.master_organization_id
    and    mri.relationship_type_id = 18
    and    mri.related_item_id = cpd.inventory_item_id;
/*
-- Delete repair information for down level parts
    delete from csp_plan_details cpd
    where  cpd.plan_detail_type = '9002'
    and    cpd.organization_id = l_organization_id
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    cpd.inventory_item_id in
           (select cpd2.related_item_id
            from   csp_plan_details cpd2
            where  cpd2.plan_detail_type = '9003'
            and    cpd2.organization_id = l_organization_id
            and    cpd2.related_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id));
*/
  end;

  procedure planned_orders(p_source_type varchar2) is
    l_source_organization_id      number;
    l__quantity            number;
    l_order_edq                  number;
    l_excess_order_quantity       number;
    lv_unfilled_requirement       number;
    l_plan_date                   date;
    l_edq_quantity                number := 0;
    l_unfilled_quantity           number := 0;
    l_order_quantity              number := 0;
    l_avail_quantity              number := 0;
    l_adjusted                    number := 0;
    l_related_item_id             number := null;
    l_rep_return_date             date   := null;
    l_source_type                 varchar2(15);

    cursor c_unfilled_items is
    select distinct cpd.inventory_item_id,
           cpd.organization_id
    from   csp_plan_details cpd
    where  cpd.organization_id = nvl(l_organization_id,cpd.organization_id)
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    cpd.plan_detail_type = '9004'
    and    cpd.quantity > 0;

    cursor c_unfilled_requirements(p_inventory_item_id number) is
    select cpd.quantity,
--           greatest(nvl(cpr.excess_safety_stock,0),
--                    nvl(cpr.repair_safety_stock,0),
--                    nvl(cpr.newbuy_safety_stock,0)) +
--                    nvl(cpr.excess_safety_stock,0) +
--           nvl(decode(p_source_type,'EXCESS',cpr.excess_safety_stock,
--                                    'REPAIR',cpr.repair_safety_stock,
--                                    'NEWBUY',cpr.newbuy_safety_stock,
--                                    'REPAIR_FORECAST',cpr.repair_safety_stock),0) unfilled_quantity,
           decode(p_source_type,'EXCESS',cpr.excess_edq,
                                'REPAIR',cpr.repair_edq,
                                'NEWBUY',cpr.newbuy_edq,
                                'REPAIR_FORECAST',cpr.repair_edq) edq_quantity,
           trunc(cpd.plan_date) plan_date,
           cpr.newbuy_safety_stock - cpr.repair_safety_stock
    from   csp_plan_details cpd,
           csp_plan_reorders cpr
    where  cpd.organization_id = nvl(l_organization_id,cpd.organization_id)
    and    cpd.inventory_item_id = p_inventory_item_id
    and    cpr.organization_id(+) = cpd.organization_id
    and    cpr.inventory_item_id(+) = cpd.inventory_item_id
    and    cpd.plan_detail_type = '9004'
    and    cpd.quantity > 0
--    and    cpd.plan_date > nvl(l_rep_return_date,cpd.plan_date-1)
    order by cpd.organization_id,
           cpd.inventory_item_id,
           cpd.plan_date;

    cursor c_excess(p_inventory_item_id number) is
    select cpd.source_organization_id,
           sum(decode(cpd.plan_detail_type,'4110',nvl(cpd.quantity,0)*-1,
                                           nvl(cpd.quantity,0)))
    from   csp_plan_details cpd
    where  cpd.organization_id = nvl(l_organization_id,cpd.organization_id)
    and    cpd.inventory_item_id = p_inventory_item_id
    and    cpd.plan_detail_type in ('4110','9001')
    group by cpd.source_organization_id,
           cpd.inventory_item_id
    order by 2 desc;

    cursor c_repair(p_inventory_item_id number) is
    select cpd.source_organization_id,
           sum(decode(cpd.plan_detail_type,'4210',nvl(cpd.quantity,0)*-1,
                                           nvl(cpd.available_quantity,0))),
           cpd.related_item_id
    from   csp_plan_details cpd
    where  cpd.organization_id = nvl(l_organization_id,cpd.organization_id)
    and    cpd.inventory_item_id = p_inventory_item_id
    and    cpd.plan_detail_type in ('4210','9002','9003')
    group by cpd.source_organization_id,
           cpd.inventory_item_id,
           cpd.related_item_id
    order by cpd.related_item_id desc, 2 desc;

    cursor c_repair_forecast(p_inventory_item_id number) is
    select null,
           sum(nvl(decode(cpd.plan_detail_type,'4220',cpd.quantity*-1,cpd.quantity),0)),
           cpr.repair_edq,
           null
    from   csp_plan_reorders cpr,
	       csp_plan_details cpd
    where  cpr.organization_id = l_organization_id
    and	   cpr.inventory_item_id = p_inventory_item_id
    and    cpd.organization_id = cpr.organization_id
    and    cpd.inventory_item_id = p_inventory_item_id
    and    cpd.plan_detail_type in ('4220','7000')
    and    cpd.plan_date <= l_plan_date
    group by
           cpr.repair_edq
    order by 2 desc;

    cursor c_newbuy(p_inventory_item_id number) is
    select nvl(msib.source_organization_id,mp.source_organization_id),
           cpr.newbuy_edq,
           null
    from   mtl_system_items_b msib,
           mtl_parameters mp,
	       csp_plan_reorders cpr
    where  msib.organization_id = l_organization_id
    and    msib.inventory_item_id = p_inventory_item_id
    and    mp.organization_id = msib.organization_id
    and    cpr.organization_id = msib.organization_id
    and    cpr.inventory_item_id = msib.inventory_item_id;

    begin

      for cr in c_unfilled_items loop
        loop
          l_source_organization_id := null;
          l_avail_quantity := 0;
          l_order_edq := 0;
          l_related_item_id := null;
          open  c_unfilled_requirements(cr.inventory_item_id);
          fetch c_unfilled_requirements into l_unfilled_quantity,l_edq_quantity,l_plan_date,l_adjusted;
          exit when c_unfilled_requirements%notfound;
          close c_unfilled_requirements;

          if p_source_type = 'EXCESS' then
            l_source_type := p_source_type;
            open  c_excess(cr.inventory_item_id);
            fetch c_excess into l_source_organization_id,l_avail_quantity;
            close c_excess;
          elsif p_source_type = 'REPAIR' then
            l_source_type := p_source_type;
            open  c_repair(cr.inventory_item_id);
            loop
              fetch c_repair into l_source_organization_id,l_avail_quantity,l_related_item_id;

              if c_repair%notfound or nvl(l_avail_quantity,0) > 0 then
                close c_repair;
                exit;
              end if;
            end loop;
          elsif p_source_type = 'REPAIR_FORECAST' then
            l_source_type := 'REPAIR_FORECAST';
            open  c_repair_forecast(cr.inventory_item_id);
            fetch c_repair_forecast into l_source_organization_id,l_avail_quantity,l_edq_quantity,l_related_item_id;
            close c_repair_forecast;

            if nvl(l_avail_quantity,0) <= 0 and
              l_plan_date < trunc(sysdate)+l_period_size*l_forecast_periods then
              l_source_type := 'NEWBUY';
              open  c_newbuy(cr.inventory_item_id);
              fetch c_newbuy into l_source_organization_id,l_edq_quantity,l_related_item_id;
              close c_newbuy;
              l_avail_quantity := l_unfilled_quantity + l_adjusted;
            end if;
          else
            l_source_type := 'NEWBUY';
            open  c_newbuy(cr.inventory_item_id);
            fetch c_newbuy into l_source_organization_id,l_edq_quantity,l_related_item_id;
            close c_newbuy;
            l_avail_quantity := l_unfilled_quantity;
          end if;
          /*
          elsif p_source_type = 'REPAIR_FORECAST' then
            open  c_repair_forecast(cr.inventory_item_id);
            fetch c_repair_forecast into l_source_organization_id,l_avail_quantity,l_order_edq,l_related_item_id;
            close c_repair_forecast;
          else
            open  c_newbuy(cr.inventory_item_id);
            fetch c_newbuy into l_source_organization_id,l_order_edq,l_related_item_id;
            close c_newbuy;
            l_avail_quantity := l_unfilled_quantity;
          end if;
          */
          if (nvl(l_avail_quantity,0) <= 0 and p_source_type = l_source_type) or l_unfilled_quantity <= 0 then
            exit;
          else
            if l_source_type = 'NEWBUY' then
              if p_source_type = 'REPAIR_FORECAST' then
                l_unfilled_quantity := l_unfilled_quantity + l_adjusted;
              end if;
              if nvl(l_edq_quantity,0) = 0 or l_avail_quantity > nvl(l_edq_quantity,0) then
                l_order_quantity := l_avail_quantity;
                if l_order_quantity <= 0 and p_source_type <> 'REPAIR_FORECAST' then exit; end if;
              else
                l_order_quantity := ceil(l_avail_quantity/nvl(l_edq_quantity,1))*nvl(l_edq_quantity,1);
                if l_order_quantity <= 0 and p_source_type <> 'REPAIR_FORECAST' then exit; end if;
              end if;
            elsif l_source_type = 'REPAIR_FORECAST' then
              l_order_quantity := least(l_avail_quantity,l_unfilled_quantity);
              l_unfilled_quantity := l_order_quantity;
            else
              if nvl(l_edq_quantity,0) = 0 then
                l_order_quantity := least(l_avail_quantity,l_unfilled_quantity);
              else
                if round(l_avail_quantity/l_edq_quantity) > 0 then
                  l_edq_quantity := l_avail_quantity/round(l_avail_quantity/l_edq_quantity);
                else
                  l_edq_quantity := l_avail_quantity;
                end if;
                l_order_quantity := least(l_avail_quantity,
                ceil(l_unfilled_quantity/nvl(l_edq_quantity,1))*nvl(l_edq_quantity,1));
              end if;
            end if;
          if l_order_quantity > 0 then
            insert into csp_plan_details(
                 plan_detail_id,
                 plan_detail_type,
                 parent_type,
                 source_number,
                 source_organization_id,
                 quantity,
                 plan_date,
                 inventory_item_id,
                 organization_id,
                 related_item_id,
                 created_by,
                 creation_date,
                 last_updated_by,
                 last_update_date,
                 last_update_login)
            select csp_plan_details_s1.nextval,
                 decode(l_source_type,'EXCESS','4110',
                                      'REPAIR','4210',
                                      'NEWBUY','4310',
                                      'REPAIR_FORECAST','4220'),
                 decode(l_source_type,'EXCESS','4100',
                                      'REPAIR','4200',
                                      'NEWBUY','4300',
                                      'REPAIR_FORECAST','1'),
                 null,
                 l_source_organization_id,
                 l_order_quantity,
--heh                 greatest(decode(l_source_type,'REPAIR_FORECAST',trunc(l_plan_date),
--                          trunc(l_plan_date+(l_period_size-(l_unfilled_quantity/cpd.quantity)*l_period_size))),
--                          trunc(sysdate+1)),
                 greatest(trunc(l_plan_date),trunc(sysdate+1)),
                 cr.inventory_item_id,
                 l_organization_id,
                 l_related_item_id,
                 fnd_global.user_id,
                 sysdate,
                 fnd_global.user_id,
                 sysdate,
                 fnd_global.login_id
            from csp_plan_details cpd
            where cpd.organization_id = l_organization_id
            and   cpd.inventory_item_id = cr.inventory_item_id
            and   cpd.plan_detail_type = '1000'
            and   cpd.plan_date = l_plan_date;

            update csp_plan_details
            set    quantity = quantity - l_order_quantity
            where  organization_id = l_organization_id
            and    inventory_item_id = cr.inventory_item_id
            and    plan_date >= l_plan_date
            and    plan_detail_type = '9004';
          end if;
            if p_source_type = 'REPAIR_FORECAST' then
              update csp_plan_details
              set    quantity = 0
              where  organization_id = l_organization_id
              and    inventory_item_id = cr.inventory_item_id
              and    plan_date = l_plan_date
              and    plan_detail_type = '9004';
            end if;
          end if;
        end loop;
        if c_unfilled_requirements%isopen then
          close c_unfilled_requirements;
        end if;
      end loop;

      delete from csp_plan_details
      where  organization_id = l_organization_id
      and    plan_detail_type = '9004';
end planned_orders;

procedure total_planned_orders is
begin

      insert into csp_plan_details(
               plan_detail_type,
               parent_type,
               source_number,
               source_organization_id,
               quantity,
               plan_date,
               inventory_item_id,
               organization_id,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login)
      select   decode(cpd.plan_detail_type,'4110','4100','4210','4200','4310','4300'),
               min('4000'),
               null,
               null,
               sum(cpd.quantity),
               trunc(plan_date),--trunc(trunc(sysdate) + (trunc((plan_date - trunc(sysdate))/l_period_size))*l_period_size),
               cpd.inventory_item_id,
               cpd.organization_id,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.login_id
        from   csp_plan_details cpd
        where  cpd.plan_detail_type in ('4110','4210','4310')
        and    cpd.organization_id = l_organization_id
        and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
        group by cpd.organization_id,cpd.inventory_item_id,trunc(plan_date),--hehtrunc(trunc(sysdate) + (trunc((plan_date - trunc(sysdate))/l_period_size))*l_period_size)
        cpd.plan_detail_type;

      insert into csp_plan_details(
               plan_detail_type,
               parent_type,
               source_number,
               source_organization_id,
               quantity,
               plan_date,
               inventory_item_id,
               organization_id,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login)
      select   min('4000'),
               min('1'),
               null,
               null,
               sum(cpd.quantity),
               cpd.plan_date,
               cpd.inventory_item_id,
               cpd.organization_id,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.login_id
        from   csp_plan_details cpd
        where  cpd.plan_detail_type in ('4100','4200','4300')
        and    cpd.organization_id = l_organization_id
        and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
        group by cpd.organization_id,cpd.inventory_item_id,cpd.plan_detail_type,cpd.plan_date;
    end total_planned_orders;

  procedure projected_onhand_1 is
    i       number;
    begin
      for i in 0..l_forecast_periods loop
        insert into csp_plan_details(
               plan_detail_type,
               parent_type,
               source_number,
               source_organization_id,
               quantity,
               plan_date,
               inventory_item_id,
               organization_id,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login)
        select min('3000'),
               min('1'),
               null,
               null,
               min(cpd2.available_quantity)+sum(decode(cpd.plan_detail_type,'1000',cpd.quantity*-1,cpd.quantity)),
               trunc(max(sysdate + (i-1)*l_period_size)),
               cpd.inventory_item_id,
               cpd.organization_id,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.login_id
        from   csp_plan_details cpd,csp_plan_details cpd2
        where  cpd.plan_detail_type in ('1000','2000')
        and	   cpd2.plan_detail_type = '1'
        and	   cpd.organization_id = cpd2.organization_id
        and	   cpd.inventory_item_id = cpd2.inventory_item_id
        and    cpd.organization_id = l_organization_id
        and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
        and	   cpd.plan_date < trunc(sysdate+i*l_period_size)
        group by cpd.organization_id,cpd.inventory_item_id;
      end loop;

    end projected_onhand_1;

  procedure projected_onhand_2 is
    begin
      insert into csp_plan_details(
               plan_detail_type,
               parent_type,
               source_number,
               source_organization_id,
               quantity,
               plan_date,
               inventory_item_id,
               organization_id,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login)
      select   min('5000'),
               min('1'),
               null,
               null,
               min(cpd.quantity)+
               sum(nvl(cpd2.quantity,0)),
               cpd.plan_date,
               cpd.inventory_item_id,
               cpd.organization_id,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.login_id
      from     csp_plan_details cpd,
               csp_plan_details cpd2
      where    cpd.plan_detail_type = '3000'
      and      cpd.organization_id = nvl(l_organization_id,cpd.organization_id)
      and      cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
      and      cpd2.organization_id = cpd.organization_id
      and      cpd2.inventory_item_id = cpd.inventory_item_id
      and      cpd2.plan_date <= cpd.plan_date+6
      and      cpd2.plan_detail_type in ('4000','4220')
      group by cpd.organization_id,cpd.inventory_item_id,cpd.plan_date;

      insert into csp_plan_details(
               plan_detail_type,
               parent_type,
               source_number,
               source_organization_id,
               quantity,
               plan_date,
               inventory_item_id,
               organization_id,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login)
      select   '5000',
               '1',
               null,
               null,
               cpd.quantity,
               cpd.plan_date,
               cpd.inventory_item_id,
               cpd.organization_id,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.login_id
        from   csp_plan_details cpd
        where  cpd.plan_detail_type = '3000'
        and    cpd.organization_id = nvl(l_organization_id,cpd.organization_id)
        and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
        and    cpd.plan_date not in
              (select cpd2.plan_date
               from   csp_plan_details cpd2
               where  cpd2.organization_id = cpd.organization_id
               and    cpd2.inventory_item_id = cpd.inventory_item_id
               and cpd2.plan_detail_type = '5000');

    end projected_onhand_2;

  procedure onhand is
    begin
      insert into csp_plan_details(
             plan_detail_type,
             parent_type,
             source_number,
             source_organization_id,
             available_quantity,
             onhand_quantity,
             excess_quantity,
             quantity,
             plan_date,
             inventory_item_id,
             organization_id,
             period_size,
             forecast_periods,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login)
      select '1',
             '0',
             null,
             null,
                         nvl(csp_validate_pub.get_avail_qty(msib.organization_id,null,null,msib.inventory_item_id),0),
                         nvl(csp_validate_pub.get_onhand_qty,0),
                         greatest(0,nvl(csp_validate_pub.get_available_qty,0)
                    - greatest(nvl(cpr.newbuy_rop,0)+nvl(cpr.newbuy_edq,0),
                      nvl(cpr.repair_rop,0)+nvl(cpr.repair_edq,0),
                      nvl(cpr.excess_rop,0)+nvl(cpr.excess_edq,0))),
             nvl(csp_validate_pub.get_onhand_qty,0),
                         trunc(sysdate),
                         msib.inventory_item_id,
                         l_organization_id,
             l_orig_period_size,
             l_orig_forecast_periods,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id
	  from   mtl_system_items_b msib,
		     csp_plan_reorders cpr
      where  msib.organization_id = l_organization_id
      and    msib.inventory_item_id = nvl(l_inventory_item_id,msib.inventory_item_id)
      and    cpr.organization_id(+) = msib.organization_id
      and    cpr.inventory_item_id(+) = msib.inventory_item_id
      and    msib.inventory_item_id in
	     (select l_inventory_item_id
              from   dual
              union
              select distinct cpd2.inventory_item_id
	      from   csp_plan_details cpd2
	      where  cpd2.plan_detail_type in ('1000','2000')
	      and    cpd2.organization_id = l_organization_id
	      and    cpd2.inventory_item_id = nvl(l_inventory_item_id,cpd2.inventory_item_id));
    end onhand;

  procedure review_superseded_parts is
  begin

    insert into csp_plan_details(
           plan_detail_type,
           parent_type,
           source_number,
           source_organization_id,
           quantity,
           plan_date,
           inventory_item_id,
           organization_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login)
    select min('8510'),
           null,
           null,
           null,
           null,
           min(cpd.plan_date),
           cpd.inventory_item_id,
           cpd.organization_id,
           min(cpd.created_by),
           min(cpd.creation_date),
           min(cpd.last_updated_by),
           min(cpd.last_update_date),
           min(cpd.last_update_login)
    from   csp_plan_details cpd,
           csp_supersede_items csi
    where  cpd.plan_detail_type in ('1200','1300','1400','2000')
    and    cpd.organization_id = l_organization_id
    and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
    and    csi.organization_id = cpd.organization_id
    and    csi.sub_inventory_code = '-'
    and    csi.inventory_item_id = cpd.inventory_item_id
    and    csi.inventory_item_id <> csi.item_supplied
    group by cpd.organization_id,cpd.inventory_item_id;

-- Delete recommendations for superseeded parts
      delete from csp_plan_details cpd
      where  (organization_id,inventory_item_id) in
      (select csi.organization_id,csi.inventory_item_id
       from   csp_supersede_items csi
       where  csi.inventory_item_id = cpd.inventory_item_id
       and    csi.organization_id = cpd.organization_id
       and    csi.sub_inventory_code = '-'
       and    csi.item_supplied <> csi.inventory_item_id)
      and    cpd.organization_id = l_organization_id
      and    cpd.inventory_item_id = nvl(l_inventory_item_id,cpd.inventory_item_id)
      and    cpd.plan_detail_type in ('8110','8120','8130','8210','8220','8310','8410','8420');
  end review_superseded_parts;
procedure regenerate(p_organization_id in number,
                     p_inventory_item_id in number,
                     p_forecast_rule_id in number,
                     p_forecast_periods in number,
                     p_period_size in number) is
 errbuf              varchar2(2000);
 retcode             number;
begin
  main(errbuf            => errbuf,
       retcode           => retcode,
       p_organization_id   => p_organization_id,
       p_inventory_item_id => p_inventory_item_id,
       p_forecast_rule_id  => p_forecast_rule_id,
       p_forecast_periods  => p_forecast_periods,
       p_period_size       => p_period_size);
end;

procedure create_plan_history(p_organization_id number,
                              p_inventory_item_id number,
                              p_history_type varchar2) is
  l_history_date date := sysdate;
begin


  insert into csp_plan_histories(
                plan_detail_type,
                organization_id,
                inventory_item_id,
                parent_type,
                plan_date,
                source_number,
                source_organization_id,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                related_item_id,
                available_quantity,
                excess_quantity,
                onhand_quantity,
                quantity,
                security_group_id,
                plan_detail_id,
                period_size,
                forecast_periods,
                history_type,
                history_date)
  select        plan_detail_type,
                organization_id,
                inventory_item_id,
                parent_type,
                plan_date,
                source_number,
                source_organization_id,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                related_item_id,
                available_quantity,
                excess_quantity,
                onhand_quantity,
                quantity,
                security_group_id,
                plan_detail_id,
                period_size,
                forecast_periods,
                p_history_type,
                l_history_date
  from          csp_plan_details
  where         organization_id = p_organization_id
  and           inventory_item_id = nvl(p_inventory_item_id,inventory_item_id);
  insert into csp_pl_param_histories(
                organization_id,
                inventory_item_id,
                excess_service_level,
                repair_service_level,
                newbuy_service_level,
                excess_edq_factor,
                repair_edq_factor,
                newbuy_edq_factor,
                excess_edq_multiple,
                repair_edq_multiple,
                newbuy_edq_multiple,
                excess_rop,
                repair_rop,
                newbuy_rop,
                excess_safety_stock,
                repair_safety_stock,
                newbuy_safety_stock,
                excess_edq,
                repair_edq,
                newbuy_edq,
                excess_lead_time,
                repair_lead_time,
                newbuy_lead_time,
                history_type,
                history_date,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login)
  select        cpd.organization_id,
                cpd.inventory_item_id,
                nvl(cipp.excess_service_level,cpp.excess_service_level),
                nvl(cipp.repair_service_level,cpp.repair_service_level),
                nvl(cipp.newbuy_service_level,cpp.newbuy_service_level),
                nvl(cipp.excess_edq_factor,cpp.excess_edq_factor),
                nvl(cipp.repair_edq_factor,cpp.repair_edq_factor),
                nvl(cipp.newbuy_edq_factor,cpp.newbuy_edq_factor),
                nvl(cipp.excess_edq_multiple,cpp.edq_multiple),
                nvl(cipp.repair_edq_multiple,cpp.edq_multiple),
                nvl(cipp.newbuy_edq_multiple,cpp.edq_multiple),
                cpr.excess_rop,
                cpr.repair_rop,
                cpr.newbuy_rop,
                cpr.excess_safety_stock,
                cpr.repair_safety_stock,
                cpr.newbuy_safety_stock,
                cpr.excess_edq,
                cpr.repair_edq,
                cpr.newbuy_edq,
                cpl.excess_lead_time,
                cpl.repair_lead_time,
                cpl.newbuy_lead_time,
                p_history_type,
                l_history_date,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.login_id
  from          csp_plan_details cpd,
                csp_planning_parameters cpp,
                csp_plan_reorders cpr,
                csp_plan_leadtimes cpl,
                csp_item_pl_params cipp
  where         cpd.plan_detail_type = '1'
  and           cpd.organization_id = p_organization_id
  and           cpd.inventory_item_id = nvl(p_inventory_item_id,cpd.inventory_item_id)
  and           cpp.organization_id = cpd.organization_id
  and           cpr.organization_id(+) = cpd.organization_id
  and           cpr.inventory_item_id(+) = cpd.inventory_item_id
  and           cpl.organization_id(+) = cpd.organization_id
  and           cpl.inventory_item_id(+) = cpd.inventory_item_id
  and           cipp.organization_id(+) = cpd.organization_id
  and           cipp.inventory_item_id(+) = cpd.inventory_item_id;

end;

procedure purge_saved_plans(p_days number) is
begin
  delete from csp_plan_histories
  where  history_date < sysdate - p_days
  and    organization_id = nvl(l_organization_id,organization_id);
end;

procedure copy_plan_history(p_organization_id number,
                            p_inventory_item_id number,
                            p_history_date date) is
begin

  delete from csp_plan_details
  where       organization_id = p_organization_id
  and         inventory_item_id = p_inventory_item_id;

  insert into csp_plan_details(
                plan_detail_type,
                organization_id,
                inventory_item_id,
                parent_type,
                plan_date,
                source_number,
                source_organization_id,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                related_item_id,
                available_quantity,
                excess_quantity,
                onhand_quantity,
                quantity,
                security_group_id,
                plan_detail_id,
                period_size,
                forecast_periods)
  select        plan_detail_type,
                organization_id,
                inventory_item_id,
                parent_type,
                plan_date,
                source_number,
                source_organization_id,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                related_item_id,
                available_quantity,
                excess_quantity,
                onhand_quantity,
                quantity,
                security_group_id,
                plan_detail_id,
                period_size,
                forecast_periods
  from          csp_plan_histories
  where         organization_id = p_organization_id
  and           inventory_item_id = nvl(p_inventory_item_id,inventory_item_id)
  and           history_date = p_history_date;
end;

  procedure current_onhand(
               p_organization_id   in number default null,
               p_inventory_item_id in number default null) is
  cursor c_forecast_rules is
  select cfrb.forecast_periods,
         cfrb.period_size
  from   csp_forecast_rules_b cfrb,
         csp_planning_parameters cpp
  where  cfrb.forecast_rule_id = cpp.forecast_rule_id
  and    cpp.organization_id = p_organization_id
  and    cpp.organization_type = 'W';

  begin
    open  c_forecast_rules;
    fetch c_forecast_rules into l_orig_forecast_periods, l_orig_period_size;
    close c_forecast_rules;
    l_organization_id := p_organization_id;
    l_inventory_item_id := p_inventory_item_id;
    begin
      delete from csp_plan_details
      where  organization_id = p_organization_id
      and    inventory_item_id = p_inventory_item_id
      and    plan_detail_type in ('1','9001','9002','9003');
    exception
    when others then
      null;
    end;
    onhand;
    repair;
    excess;
    commit;
  end current_onhand;

procedure main(errbuf out nocopy varchar2,
               retcode out nocopy number,
               p_organization_id   in number,
               p_save_system_plan  in varchar2,
               p_save_planner_plan in varchar2,
               p_purge_saved_plans in number,
               p_inventory_item_id in number,
               p_forecast_rule_id  in number,
               p_forecast_periods  in number,
               p_period_size       in number) is

--  errbuf       varchar2(2000);
--  retcode      number;
  cursor c_forecast_method is
  select cfrb.forecast_rule_id,
         cfrb.forecast_periods,
         cfrb.forecast_method,
         cfrb.history_periods,
         cfrb.period_size,
         cpp.organization_id,
         cpp.usable_assignment_set_id,
         cpp.defective_assignment_set_id,
         cpp.repair_assignment_set_id,
         cpp.edq_multiple,
         cpp.level_id,
         cpp.reschedule_rule_id,
         cpp.minimum_value
  from   csp_forecast_rules_b cfrb,
         csp_planning_parameters cpp
  where  cfrb.forecast_rule_id = cpp.forecast_rule_id
  and    cpp.organization_id = nvl(l_organization_id,cpp.organization_id)
  and    cpp.organization_type = 'W';

  cursor c_reschedule is
  select onhand_type_in,
         start_day_in,
         end_day_in,
         onhand_condition_in,
         periods_in,
         onhand_type_out,
         start_day_out,
         end_day_out,
         onhand_value_out,
         edq_multiple_out,
         periods_out
  from   csp_reschedule_rules_vl
  where  reschedule_rule_id = l_reschedule_rule_id;

  cursor c_order_automation(p_organization_id number) is
  select inventory_item_id
  from   csp_plan_details
  where  organization_id = p_organization_id
  and    plan_detail_type in ('8610','8620','8630');

begin
  l_organization_id := p_organization_id;
  l_inventory_item_id := p_inventory_item_id;
  EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
  if p_save_planner_plan = '1' then
    create_plan_history(p_organization_id => l_organization_id,
                        p_inventory_item_id => null,
                        p_history_type => 'PLANNER');
  end if;
  if nvl(p_purge_saved_plans,0) > 0 then
    purge_saved_plans(p_days => p_purge_saved_plans);
  end if;

  if l_inventory_item_id is null then
    delete from csp_plan_details
    where       organization_id   = nvl(l_organization_id,organization_id)
    and         inventory_item_id = nvl(l_inventory_item_id,inventory_item_id);
    commit;
  else
    delete from csp_plan_details
    where       organization_id   = nvl(l_organization_id,organization_id)
    and         inventory_item_id = nvl(l_inventory_item_id,inventory_item_id)
    and         plan_detail_type not in ('8610','8620','8630');
    commit;
  end if;

  for cr in c_forecast_method loop
    l_period_size := nvl(p_period_size,cr.period_size);
    l_orig_period_size := l_period_size;
    l_forecast_periods := nvl(p_forecast_periods,cr.forecast_periods);
    l_orig_forecast_periods := l_forecast_periods;

    l_organization_id := cr.organization_id;
    l_forecast_rule_id := cr.forecast_rule_id;
    l_forecast_period_size := cr.period_size;
    l_forecast_method := cr.forecast_method;
    l_history_periods := cr.history_periods;
    l_usable_assignment_set_id := cr.usable_assignment_set_id;
    l_defective_assignment_set_id := cr.defective_assignment_set_id;
    l_repair_assignment_set_id := cr.repair_assignment_set_id;
    l_edq_multiple := cr.edq_multiple;
    l_reschedule_rule_id := cr.reschedule_rule_id;
    l_minimum_value := cr.minimum_value;

    if l_period_size > 7 then
       l_forecast_periods := round(l_forecast_periods * l_period_size / 7);
       l_period_size := 7;
    end if;

    if l_reschedule_rule_id is not null then
      open  c_reschedule;
      fetch c_reschedule into
            l_onhand_type_in,
            l_start_day_in,
            l_end_day_in,
            l_onhand_condition_in,
            l_periods_in,
            l_onhand_type_out,
            l_start_day_out,
            l_end_day_out,
            l_onhand_value_out,
            l_edq_multiple_out,
            l_periods_out;
      close c_reschedule;
    end if;
    if nvl(l_period_size,0) <> 0 then
      if l_inventory_item_id is null then

        csp_auto_aslmsl_pvt.Generate_Recommendations(retcode,errbuf,2.0,cr.level_id);
        forecast;commit;
        orders;commit;
        supply;commit;
        total_requirement;commit;
        total_on_order;commit;
        onhand;commit;
        leadtimes;commit;
        reorders(l_organization_id,l_inventory_item_id);commit;
      else
        forecast;commit;
        orders;commit;
        supply;commit;
        total_requirement;commit;
        total_on_order;commit;
        onhand;commit;
      end if;
      excess;commit;
      repair;commit;
      projected_onhand_1;commit;
      if cr.usable_assignment_set_id is not null then
        unfilled_requirement('EXCESS');commit;
        planned_orders('EXCESS');commit;
      end if;


      if cr.defective_assignment_set_id is not null and
        cr.repair_assignment_set_id is not null then

        unfilled_requirement('REPAIR');commit;
        planned_orders('REPAIR');commit;
        return_history;commit;
        return_forecast;commit;
        unfilled_requirement('REPAIR_FORECAST');commit;
        planned_orders('REPAIR_FORECAST');commit;

      end if;

      unfilled_requirement('NEWBUY');commit;

      planned_orders('NEWBUY');commit;
      total_planned_orders;commit;
      projected_onhand_2;commit;

-- Exceptions
      newbuy_excess_onorder;commit;
      repair_excess_onorder;commit;
      excess_excess_onorder;commit;
      unutilized_excess;commit;
      unutilized_repair;commit;
      reschedule_in;commit;
      reschedule_out;commit;
      review_superseded_parts;commit;
-- Clean up exceptions
      delete from csp_plan_details
      where  plan_detail_type in ('8110','8120','8130','8210',
                                  '8220','8310','8410','8420')
      and    organization_id = l_organization_id
      and    inventory_item_id = nvl(l_inventory_item_id,inventory_item_id)
      and    quantity = 0;
      commit;

-- Order Automation
      if l_inventory_item_id is null then
        order_automation;commit;--hehxx added commit
        for coa in c_order_automation(cr.organization_id) loop
          regenerate(  p_organization_id   => cr.organization_id,
                       p_inventory_item_id => coa.inventory_item_id,
                       p_forecast_rule_id  => cr.forecast_rule_id,
                       p_forecast_periods  => cr.forecast_periods,
                       p_period_size       => cr.period_size);
        end loop;
      end if;

      if p_save_system_plan = '1' then
        create_plan_history(p_organization_id => l_organization_id,
                            p_inventory_item_id => null,
                            p_history_type => 'SYSTEM');commit;
      end if;
    end if;
  end loop;
  retcode := g_retcode;
end main;
end;

/
