--------------------------------------------------------
--  DDL for Package Body MSC_SUPPLIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SUPPLIER_PKG" as
/* $Header: MSCHBSPB.pls 120.31.12010000.14 2010/03/10 13:50:13 wexia ship $ */
  SYS_YES         CONSTANT INTEGER := 1;
  SYS_NO          CONSTANT INTEGER := 2;

  --supply order types begins
  PLANNED_ORDER     CONSTANT INTEGER := 5;
  PURCHASE_ORDER    CONSTANT INTEGER := 1;
  PURCHASE_REQ      CONSTANT INTEGER := 2;
  PLANNED_ARRIVAL   CONSTANT INTEGER := 51;
  NEW_BUY_POS       CONSTANT INTEGER := 76;
  --supply order types ends

   function is_new_buy_order(p_order_type number, p_plan_type number, p_purchasing_enabled_flag number) return number is
  begin
    if (p_plan_type in (1,2,3,5,6,8,101,102,103,105) and (p_order_type in (1,2,76) or  (p_order_type=5 and p_purchasing_enabled_flag =1))) then
      return 1;
    end if;
    return 0;
  end is_new_buy_order;

  function is_rescheduled_po(p_order_type number, p_rescheduled_flag number,
    new_schedule_date date, old_schedule_date date) return number is
  begin
    if(p_order_type = 1) then
      if((p_rescheduled_flag IS NOT NULL) and (new_schedule_date <> old_schedule_date))then
        return 1;
      end if;
    end if;
    return 0;
  end is_rescheduled_po;


  function is_cancelled_po(p_order_type number, p_disposition_status_type number) return number is
  begin
    if(p_order_type = 1) then
      if(p_disposition_status_type = 2) then
        return 1;
      end if;
    end if;
    return 0;
  end is_cancelled_po;

  function supplier_spend_value(p_new_order_quantity number,
    p_list_price number, p_order_type number) return number is
  begin
    if (p_order_type in (1,2,5,76)) then
      return (p_new_order_quantity * p_list_price);
    end if;
    return 0;
  end supplier_spend_value;


    /*
        l_qid_req_org: organization_id, required_qty, po% etc
        l_qid_avail_req: avail_qty, net_avail_qty
        l_qid_avail_cum (dense): avail_qty, net_avail_qty, net_avail_qty_cum

        ETL steps:
        -- 10: populate l_qid_req_org from source
        -- 20: populate l_qid_avail from source
        -- 30: populate l_qid_avail_req from ((l_qid_req_org grouped to all orgs) union l_qid_avail)
        -- 40: populate l_qid_avail_req_org from ((l_qid_avail_req join dense_org_key) join l_qid_req_org)
        -- delete: (l_qid_req_org, l_qid_avail, l_qid_avail_req)
        -- 50: populate l_qid_avail_cum from (l_qid_avail_req_org join dense_time_key)
        -- 60: populate msc_suppliers_f from (l_qid_avail_req_org union l_qid_avail_cum)
        -- delete: (l_qid_avail_req_org, l_qid_avail_cum)
     */

  procedure populate_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
    p_plan_id number, p_plan_run_id number) AS
    l_plan_start_date date;
    l_plan_cutoff_date date;
    l_plan_type number;
    l_sr_instance_id number;
    l_plan_constrained number;

    l_stmt_id number ;

    l_qid_last_date number;
    l_qid_req_org number;
    l_qid_avail number;
    l_qid_avail_req number;
    l_qid_avail_req_org number;
    l_qid_avail_cum number;

    l_owning_currency_code varchar2(20) := msc_phub_util.get_owning_currency_code(p_plan_run_id);

  begin
        msc_phub_util.log('msc_supplier_pkg.populate_details');
        retcode := 0;
        errbuf := null;

        select plan_type, sr_instance_id, plan_start_date, plan_cutoff_date
        into l_plan_type, l_sr_instance_id, l_plan_start_date, l_plan_cutoff_date
        from msc_plan_runs
        where plan_id=p_plan_id
        and plan_run_id=p_plan_run_id;

        l_plan_constrained := msc_phub_util.is_plan_constrained(p_plan_id);
        if l_plan_type in (101,102,103,105) then
            l_plan_constrained := SYS_NO;
        end if;

        -- 10: populate l_qid_req_org from source
        l_stmt_id:=10;
        select msc_hub_query_s.nextval into l_qid_req_org from dual;
        insert into msc_hub_query(
            query_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            number1,   -- plan_id
            number2,   -- plan_run_id
            number3,   -- sr_instance_id
            number4,   -- organization_id
            number7,   -- inventory_item_id
            number8,   -- supplier_id
            number9,   -- supplier_site_id
            number10,  -- region_id
            date1,     -- analysis_date
            number11,  -- required_qty
            number12,  -- po_reschedule_count
            number13,  -- po_count
            number14,  -- po_cancel_count
            number15,  -- buy_order_value
            number16,  -- buy_order_value2
            number17   -- buy_order_count
        )
        select
            l_qid_req_org, sysdate, 1, sysdate, 1, 1,
            p_plan_id,
            p_plan_run_id,
            t.sr_instance_id,
            t.organization_id,
            t.inventory_item_id,
            t.supplier_id,
            t.supplier_site_id,
            nvl(mps.region_id, -23453) region_id,
            t.analysis_date,
            sum(t.required_qty) required_qty,
            sum(t.po_reschedule_count) po_reschedule_count,
            sum(t.po_count) po_count,
            sum(t.po_cancel_count) po_cancel_count,
            sum(t.buy_order_value) buy_order_value,
            sum(t.buy_order_value * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))) buy_order_value2,
            sum(buy_order_count) buy_order_count
        from (
            select
                msr.sr_instance_id sr_instance_id,
                msr.organization_id organization_id,
                nvl(mtp.currency_code, l_owning_currency_code) currency_code,
                msr.supplier_id supplier_id,
                nvl(msr.supplier_site_id, -23453) supplier_site_id,
                to_number(-23453) region_id,
                msr.inventory_item_id inventory_item_id,
                trunc(msr.consumption_date) analysis_date,
                sum(msr.consumed_quantity+msr.overloaded_capacity) required_qty,
                to_number(null) po_reschedule_count,
                to_number(null) po_count,
                to_number(null) po_cancel_count,
                to_number(null) buy_order_value,
                to_number(null) buy_order_count
            from msc_supplier_requirements msr,
                msc_trading_partners mtp
            where msr.plan_id =  p_plan_id
                and l_plan_constrained = SYS_YES
                and msr.sr_instance_id = mtp.sr_instance_id
                and msr.organization_id = mtp.sr_tp_id
                and mtp.partner_type = 3
            group by
                msr.sr_instance_id,
                msr.organization_id,
                nvl(mtp.currency_code, l_owning_currency_code),
                msr.supplier_id,
                nvl(msr.supplier_site_id,-23453),
                msr.inventory_item_id,
                trunc(msr.consumption_date)

            union all
            select
                ms.sr_instance_id  sr_instance_id,
                ms.organization_id organization_id,
                nvl(mtp.currency_code, l_owning_currency_code) currency_code,
                decode(ms.order_type, PLANNED_ORDER, ms.source_supplier_id,
                                                     PLANNED_ARRIVAL, ms.source_supplier_id,
                                                                      ms.supplier_id)    supplier_id,
                nvl(decode(ms.order_type, PLANNED_ORDER, ms.source_supplier_site_id,
                                                     PLANNED_ARRIVAL, ms.source_supplier_site_id,
                                                                      ms.supplier_site_id), -23453)   supplier_site_id,
                to_number(-23453) region_id,
                ms.inventory_item_id   inventory_item_id,
                -- SNO populates new_schedule_date
                decode(l_plan_type,
                  6, trunc(ms.new_schedule_date),
                  101, trunc(ms.new_schedule_date),
                  102, trunc(ms.new_schedule_date),
                  103, trunc(ms.new_schedule_date),
                  105, trunc(ms.new_schedule_date),
                  trunc(ms.new_order_placement_date)) analysis_date,
                sum(decode(l_plan_type,
                             5, decode(nvl(ms.disposition_status_type,1),
                                                          1, ms.new_order_quantity,
                                                          0),
                      4, decode(nvl(ms.disposition_status_type,1),
                                                          1, ms.new_order_quantity,
                                                          0),

                      6, 0,
                      decode(nvl(ms.disposition_status_type,1),1,
                      decode(l_plan_constrained,2,ms.new_order_quantity,0),0)))required_qty,
                sum(is_rescheduled_po(ms.order_type, ms.reschedule_flag,
                        ms.new_schedule_date, ms.old_schedule_date)) po_reschedule_count,
                sum(decode(ms.order_type, 1, 1, 0)) po_count,
                sum(is_cancelled_po(ms.order_type,
                                               ms.disposition_status_type)) po_cancel_count,
                sum(supplier_spend_value (ms.new_order_quantity,
                                               nvl(ms.DELIVERY_PRICE,msi.standard_cost), ms.order_type)) buy_order_value,
                sum(is_new_buy_order(ms.order_type, l_plan_type, msi.purchasing_enabled_flag)) buy_order_count
            from
                msc_supplies ms,
                msc_system_items msi,
                msc_trading_partners mtp
            where
                ms.plan_id = p_plan_id
                -- and l_plan_constrained = SYS_NO -- are we double counting constrained plan with previous?
                and ms.supplier_id is not null
                and ms.plan_id = msi.plan_id
                and ms.sr_instance_id = msi.sr_instance_id
                and ms.organization_id = msi.organization_id
                and ms.inventory_item_id = msi.inventory_item_id
                and ms.order_type in (PLANNED_ORDER,PURCHASE_ORDER,PURCHASE_REQ,PLANNED_ARRIVAL,NEW_BUY_POS)
                and ms.organization_id = mtp.sr_tp_id
                and ms.sr_instance_id = mtp.sr_instance_id
                and mtp.partner_type = 3
            group by
                ms.sr_instance_id,
                ms.organization_id,
                nvl(mtp.currency_code, l_owning_currency_code),
                decode(ms.order_type, PLANNED_ORDER, ms.source_supplier_id,
                                                     PLANNED_ARRIVAL, ms.source_supplier_id,
                                                                      ms.supplier_id),
                nvl(decode(ms.order_type, PLANNED_ORDER, ms.source_supplier_site_id,
                                                     PLANNED_ARRIVAL, ms.source_supplier_site_id,
                                                                      ms.supplier_site_id), -23453),
                ms.inventory_item_id,
                decode(l_plan_type,
                   6, trunc(ms.new_schedule_date),
                  101, trunc(ms.new_schedule_date),
                  102, trunc(ms.new_schedule_date),
                  103, trunc(ms.new_schedule_date),
                  105, trunc(ms.new_schedule_date),
                  trunc(ms.new_order_placement_date))

            union all
            select
                mbid.sr_instance_id,
                mbid.organization_id,
                nvl(mtp.currency_code, l_owning_currency_code) currency_code,
                mbid.supplier_id,
                nvl(mbid.supplier_site_id, -23453) supplier_site_id,
                nvl(mbid.zone_id, -23453) region_id,
                mbid.inventory_item_id,
                trunc(mbid.detail_date) analysis_date,
                mbid.supplier_usage required_qty,
                to_number(null) po_reschedule_count,
                to_number(null) po_count,
                to_number(null) po_cancel_count,
                to_number(null) buy_order_value,
                to_number(null) buy_order_count
            from
                msc_bis_inv_detail mbid,
                msc_trading_partners mtp
            where mbid.plan_id = p_plan_id
                and mbid.supplier_id is not null
                and mbid.organization_id = mtp.sr_tp_id
                and mbid.sr_instance_id = mtp.sr_instance_id
                and mtp.partner_type = 3
                and l_plan_type = 6) t,

            msc_currency_conv_mv mcc,
            msc_phub_suppliers_mv mps

        where mcc.from_currency(+) = t.currency_code
            and mcc.to_currency(+) = fnd_profile.value('MSC_HUB_CUR_CODE_RPT')
            and mcc.calendar_date(+) = t.analysis_date
            and mps.supplier_id(+) = nvl(t.supplier_id, -23453)
            and mps.supplier_site_id(+) = nvl(t.supplier_site_id, -23453)
            and mps.region_id(+) = decode(nvl(t.supplier_site_id, -23453),
                -23453, nvl(t.region_id, -23453), mps.region_id(+))
        group by
            t.sr_instance_id,
            t.organization_id,
            t.inventory_item_id,
            t.supplier_id,
            t.supplier_site_id,
            nvl(mps.region_id, -23453),
            t.analysis_date;

        msc_phub_util.log(l_stmt_id||', l_qid_req_org='||l_qid_req_org||', count='||sql%rowcount);
        commit;


        -- 20: populate l_qid_avail from source
        l_stmt_id:=20;
        select msc_hub_query_s.nextval into l_qid_avail from dual;
        insert into msc_hub_query(
            query_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            number1,   -- plan_id
            number2,   -- plan_run_id
            number3,   -- sr_instance_id
            number4,   -- organization_id
            number7,   -- inventory_item_id
            number8,   -- supplier_id
            number9,   -- supplier_site_id
            number10,  -- region_id
            date1,     -- analysis_date
            number20   -- avail_qty
        )
        select
            l_qid_avail, sysdate, 1, sysdate, 1, 1,
            p_plan_id,
            p_plan_run_id,
            t.sr_instance_id,
            t.organization_id,
            t.inventory_item_id,
            t.supplier_id,
            t.supplier_site_id,
            nvl(mps.region_id, -23453) region_id,
            t.analysis_date,
            sum(t.avail_qty)
        from
            (select
                mscp.sr_instance_id sr_instance_id,
                mscp.organization_id organization_id,
                mscp.supplier_id supplier_id,
                nvl(mscp.supplier_site_id, -23453) supplier_site_id,
                to_number(-23453) region_id,
                mscp.inventory_item_id inventory_item_id,
                trunc(mcd.calendar_date) analysis_date,
                to_number(null) required_qty,
                nvl(mscp.capacity, 1e20) avail_qty
            from
                msc_supplier_capacities mscp,
                msc_calendar_dates mcd,
                msc_trading_partners mtp,
                msc_item_suppliers mis
            where mscp.capacity > 0
                and mis.plan_id = mscp.plan_id
                and mis.supplier_id = mscp.supplier_id
                and mis.supplier_site_id = mscp.supplier_site_id
                and mis.organization_id = mscp.organization_id
                and mis.inventory_item_id = mscp.inventory_item_id
                and mis.sr_instance_id = mscp.sr_instance_id
                and mtp.sr_tp_id = mscp.organization_id
                and mtp.sr_instance_id = mscp.sr_instance_id
                and mtp.partner_type = 3
                and mcd.calendar_date between trunc(mscp.from_date) and trunc(nvl(mscp.to_date,l_plan_cutoff_date))
                and mcd.calendar_date between decode(l_plan_type, 4, trunc(l_plan_start_date),
                    nvl(trunc(mis.supplier_lead_time_date+1),trunc(l_plan_start_date)))
                    and trunc(l_plan_cutoff_date)
                and (((mis.delivery_calendar_code is not null and mcd.seq_num is not null)
                    or (mis.delivery_calendar_code is null and  l_plan_type <> 4))
                    or (l_plan_type = 4 and mcd.seq_num is not null))
                and  mcd.calendar_code = nvl(mis.delivery_calendar_code,mtp.calendar_code)
                and  mcd.exception_set_id = mtp.calendar_exception_set_id
                and  mcd.sr_instance_id = mtp.sr_instance_id
                and mscp.plan_id=p_plan_id

            union all
            select
                mbid.sr_instance_id,
                mbid.organization_id,
                mbid.supplier_id,
                nvl(mbid.supplier_site_id, -23453) supplier_site_id,
                nvl(mbid.zone_id, -23453) region_id,
                mbid.inventory_item_id,
                trunc(mbid.detail_date) analysis_date,
                to_number(null) required_qty,
                mbid.supplier_capacity avail_qty
            from
                msc_bis_inv_detail mbid,
                msc_trading_partners mtp
            where mbid.plan_id = p_plan_id
                and mbid.supplier_id is not null
                and mbid.organization_id = mtp.sr_tp_id
                and mbid.sr_instance_id = mtp.sr_instance_id
                and mtp.partner_type = 3
                and l_plan_type = 6) t,

            msc_phub_suppliers_mv mps

        where mps.supplier_id(+) = nvl(t.supplier_id, -23453)
            and mps.supplier_site_id(+) = nvl(t.supplier_site_id, -23453)
            and mps.region_id(+) = decode(nvl(t.supplier_site_id, -23453),
                -23453, nvl(t.region_id, -23453), mps.region_id(+))
        group by
            t.sr_instance_id,
            t.organization_id,
            t.inventory_item_id,
            t.supplier_id,
            t.supplier_site_id,
            nvl(mps.region_id, -23453),
            t.analysis_date;

        msc_phub_util.log(l_stmt_id||', l_qid_avail='||l_qid_avail||', count='||sql%rowcount);
        commit;

        -- 30: populate l_qid_avail_req from ((l_qid_req_org grouped to all orgs) union l_qid_avail)
        l_stmt_id:=30;
        select msc_hub_query_s.nextval into l_qid_avail_req from dual;
        insert into msc_hub_query(
            query_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            number1,   -- plan_id
            number2,   -- plan_run_id
            number3,   -- sr_instance_id
            number4,   -- organization_id
            number7,   -- inventory_item_id
            number8,   -- supplier_id
            number9,   -- supplier_site_id
            number10,  -- region_id
            date1,     -- analysis_date
            number11,  -- required_qty
            number20,  -- avail_qty
            number21   -- net_avail_qty

        )
        select
            l_qid_avail_req, sysdate, 1, sysdate, 1, 1,
            p_plan_id,
            p_plan_run_id,
            t.sr_instance_id,
            to_number(-1),
            t.inventory_item_id,
            t.supplier_id,
            t.supplier_site_id,
            t.region_id,
            t.analysis_date,
            sum(t.required_qty),
            sum(t.avail_qty),
            sum(nvl(t.avail_qty,0)-nvl(t.required_qty,0))
        from
            (select
                number3  sr_instance_id,
                number7  inventory_item_id,
                number8  supplier_id,
                number9  supplier_site_id,
                number10 region_id,
                date1    analysis_date,
                sum(number11) required_qty,
                to_number(null) avail_qty
            from msc_hub_query
            where query_id=l_qid_req_org
            group by number3, number7, number8, number9, number10, date1
            union all
            select distinct
                number3  sr_instance_id,
                number7  inventory_item_id,
                number8  supplier_id,
                number9  supplier_site_id,
                number10 region_id,
                date1    analysis_date,
                to_number(null) required_qty,
                number20 avail_qty
            from msc_hub_query
            where query_id=l_qid_avail) t

        group by
            t.sr_instance_id,
            t.inventory_item_id,
            t.supplier_id,
            t.supplier_site_id,
            t.region_id,
            t.analysis_date;

        msc_phub_util.log(l_stmt_id||', l_qid_avail_req='||l_qid_avail_req||', count='||sql%rowcount);
        commit;


        -- 40: populate l_qid_avail_req_org from ((l_qid_avail_req join dense_org_key) join l_qid_req_org)
        l_stmt_id:=40;
        select msc_hub_query_s.nextval into l_qid_avail_req_org from dual;
        insert into msc_hub_query(
            query_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            number1,   -- plan_id
            number2,   -- plan_run_id
            number3,   -- sr_instance_id
            number4,   -- organization_id
            number7,   -- inventory_item_id
            number8,   -- supplier_id
            number9,   -- supplier_site_id
            number10,  -- region_id
            date1,     -- analysis_date
            number11,  -- required_qty
            number12,  -- po_reschedule_count
            number13,  -- po_count
            number14,  -- po_cancel_count
            number15,  -- buy_order_value
            number16,  -- buy_order_value2
            number17,  -- buy_order_count
            number20,  -- avail_qty
            number21   -- net_avail_qty
        )
        select
            l_qid_avail_req_org, sysdate, 1, sysdate, 1, 1,
            p_plan_id,
            p_plan_run_id,
            k.number3  sr_instance_id,
            k.number4  organization_id,
            k.number7  inventory_item_id,
            k.number8  supplier_id,
            k.number9  supplier_site_id,
            k.number10 region_id,
            k.date1    analysis_date,
            f.number11 required_qty,
            f.number12 po_reschedule_count,
            f.number13 po_count,
            f.number14 po_cancel_count,
            f.number15 buy_order_value,
            f.number16 buy_order_value2,
            f.number17 buy_order_count,
            k.number20 avail_qty,
            k.number21 net_avail_qty
        from
            (select
                k1.number3,
                k2.number4,
                k1.number7,
                k1.number8,
                k1.number9,
                k1.number10,
                k1.date1,
                k1.number20,
                k1.number21
            from
                msc_hub_query k1,
                (select distinct number3, number4 from msc_hub_query where query_id=l_qid_req_org
                union
                select distinct sr_instance_id, organization_id
                from msc_supplier_capacities
                where plan_id=p_plan_id and l_plan_type<>6
                union all
                select distinct sr_instance_id, organization_id
                from msc_bis_inv_detail
                where plan_id=p_plan_id and l_plan_type=6) k2
            where k1.query_id=l_qid_avail_req
            ) k,
            msc_hub_query f
        where f.query_id(+)=l_qid_req_org
            and k.number3=f.number3(+)
            and k.number4=f.number4(+)
            and k.number7=f.number7(+)
            and k.number8=f.number8(+)
            and k.number9=f.number9(+)
            and k.number10=f.number10(+)
            and k.date1=f.date1(+);

        msc_phub_util.log(l_stmt_id||', l_qid_avail_req_org='||l_qid_avail_req_org||', count='||sql%rowcount);
        commit;

        -- delete: (l_qid_req_org, l_qid_avail, l_qid_avail_req)
        delete from msc_hub_query where query_id in (l_qid_req_org, l_qid_avail, l_qid_avail_req);
        commit;

        l_qid_last_date := msc_phub_util.get_reporting_dates(l_plan_start_date, l_plan_cutoff_date);

        -- 50: populate l_qid_avail_cum from (l_qid_avail_req_org join dense_time_key)
        l_stmt_id:=50;
        select msc_hub_query_s.nextval into l_qid_avail_cum from dual;
        insert into msc_hub_query(
            query_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            number1,   -- plan_id
            number2,   -- plan_run_id
            number3,   -- sr_instance_id
            number4,   -- organization_id
            number7,   -- inventory_item_id
            number8,   -- supplier_id
            number9,   -- supplier_site_id
            number10,  -- region_id
            date1,     -- analysis_date
            number22   -- net_avail_qty_cum
        )
        select
            l_qid_avail_cum, sysdate, 1, sysdate, 1, 1,
            p_plan_id,
            p_plan_run_id,
            f.number3,
            f.number4,
            f.number7,
            f.number8,
            f.number9,
            f.number10,
            d.date1,
            sum(f.number21) net_avail_qty_cum
        from
            msc_hub_query f,
            msc_hub_query d
        where f.query_id=l_qid_avail_req_org
            and d.query_id=l_qid_last_date
            and d.date1>=f.date1
        group by
            f.number3,
            f.number4,
            f.number7,
            f.number8,
            f.number9,
            f.number10,
            d.date1;

        msc_phub_util.log(l_stmt_id||', l_qid_avail_cum='||l_qid_avail_cum||', count='||sql%rowcount);
        commit;


        -- 60: populate msc_suppliers_f from (l_qid_avail_req_org union l_qid_avail_cum)
        l_stmt_id:=60;
        insert into msc_suppliers_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            owning_inst_id,
            owning_org_id,
            inventory_item_id,
            supplier_id,
            supplier_site_id,
            region_id,
            analysis_date,
            aggr_type, category_set_id, sr_category_id,
            required_qty,
            po_reschedule_count,
            po_count,
            po_cancel_count,
            buy_order_value,
            buy_order_value2,
            buy_order_count,
            avail_qty,
            net_avail_qty,
            net_avail_qty_cum,
            supplier_lead_time,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        select
            p_plan_id,
            p_plan_run_id,
            number3    sr_instance_id,
            number4    organization_id,
            decode(number3, -1, l_sr_instance_id, number3) owning_inst_id,
            decode(number4, -1, msc_hub_calendar.get_item_org(p_plan_id, number7,
                decode(number3,-1, l_sr_instance_id, number3)),
                number4) owning_org_id,
            number7    inventory_item_id,
            number8    supplier_id,
            number9    supplier_site_id,
            number10   region_id,
            date1      analysis_date,
            to_number(0) aggr_type,
            to_number(-23453) category_set_id,
            to_number(-23453) sr_category_id,
            sum(number11)    required_qty,
            sum(number12)    po_reschedule_count,
            sum(number13)    po_count,
            sum(number14)    po_cancel_count,
            sum(number15)    buy_order_value,
            sum(number16)    buy_order_value2,
            sum(number17)    buy_order_count,
            sum(number20)    avail_qty,
            sum(number21)    net_avail_qty,
            sum(number22)    net_avail_qty_cum,
            to_number(null)  supplier_lead_time,
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            (select
                number3, number4, number7, number8, number9, number10, date1,
                number11, number12, number13, number14, number15, number16,
                number17, number20, number21,
                to_number(null) number22
            from msc_hub_query where query_id=l_qid_avail_req_org
            union all
            select
                number3, number4, number7, number8, number9, number10, date1,
                to_number(null), to_number(null), to_number(null),
                to_number(null), to_number(null), to_number(null),
                to_number(null), to_number(null), to_number(null),
                number22
            from msc_hub_query where query_id=l_qid_avail_cum)
        group by
            number3, number4, number7, number8, number9, number10, date1;

        msc_phub_util.log('msc_suppliers_f, insert='||sql%rowcount);
        commit;

        -- delete: (l_qid_avail_req_org, l_qid_avail_cum)
        delete from msc_hub_query where query_id in (l_qid_avail_req_org, l_qid_avail_cum);
        commit;

        summarize_suppliers_f(errbuf, retcode, p_plan_id, p_plan_run_id);

    exception
        when dup_val_on_index then
            msc_phub_util.log('exception '||SQLCODE||', '||sqlerrm);
            errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_DUPLICATE_DATA')||SQLCODE||' -ERROR- '||sqlerrm;
            retcode := 2;
        when others then
            msc_phub_util.log('exception '||SQLCODE||', '||sqlerrm);
            errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_POPULATE_ERROR')||SQLCODE||' -ERROR- '||sqlerrm;
            retcode := 2;
  end populate_details;

    procedure summarize_suppliers_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_category_set_id1 number := fnd_profile.value('MSC_HUB_CAT_SET_ID_1');
    begin
        msc_phub_util.log('msc_supplier_pkg.summarize_suppliers_f');
        retcode := 0;
        errbuf := '';

        delete from msc_suppliers_f
        where plan_id=p_plan_id and plan_run_id=p_plan_run_id and aggr_type>0;
        msc_phub_util.log('msc_supplier_pkg.summarize_suppliers_f, delete='||sql%rowcount);
        commit;

        -- level 1
        insert into msc_suppliers_f (
            plan_id, plan_run_id,
            sr_instance_id, organization_id,
            owning_inst_id, owning_org_id, inventory_item_id,
            supplier_id, supplier_site_id, region_id,
            analysis_date,
            aggr_type, category_set_id, sr_category_id,
            required_qty,
            avail_qty,
            net_avail_qty,
            net_avail_qty_cum,
            po_reschedule_count,
            po_count,
            po_cancel_count,
            buy_order_value,
            buy_order_value2,
            buy_order_count,
            supplier_lead_time,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category (42, 43, 44)
        select
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            f.owning_inst_id, f.owning_org_id, to_number(-23453) inventory_item_id,
            f.supplier_id, f.supplier_site_id, f.region_id,
            f.analysis_date,
            to_number(42) aggr_type,
            l_category_set_id1 category_set_id,
            nvl(q.sr_category_id, -23453),
            sum(f.required_qty),
            sum(f.avail_qty),
            sum(f.net_avail_qty),
            sum(f.net_avail_qty_cum),
            sum(f.po_reschedule_count),
            sum(f.po_count),
            sum(f.po_cancel_count),
            sum(f.buy_order_value),
            sum(f.buy_order_value2),
            sum(f.buy_order_count),
            sum(f.supplier_lead_time),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_suppliers_f f,
            msc_phub_item_categories_mv q
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type=0
            and f.owning_inst_id=q.sr_instance_id(+)
            and f.owning_org_id=q.organization_id(+)
            and f.inventory_item_id=q.inventory_item_id(+)
            and q.category_set_id(+)=l_category_set_id1
        group by
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            f.owning_inst_id, f.owning_org_id,
            f.supplier_id, f.supplier_site_id, f.region_id,
            f.analysis_date,
            nvl(q.sr_category_id, -23453);

        msc_phub_util.log('msc_supplier_pkg.summarize_suppliers_f, level1='||sql%rowcount);
        commit;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_supplier_pkg.summarize_suppliers_f: '||sqlerrm;
            raise;

    end summarize_suppliers_f;

    procedure export_suppliers_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_supplier_pkg.export_suppliers_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_suppliers_f where st_transaction_id=p_st_transaction_id;
        commit;

        l_sql :=
            ' insert into msc_st_suppliers_f('||
            '     st_transaction_id,'||
            '     error_code,'||
            '     sr_instance_id,'||
            '     organization_id,'||
            '     owning_inst_id,'||
            '     owning_org_id,'||
            '     inventory_item_id,'||
            '     supplier_id,'||
            '     supplier_site_id,'||
            '     region_id,'||
            '     organization_code,'||
            '     owning_org_code,'||
            '     item_name,'||
            '     supplier_name,'||
            '     supplier_site_code,'||
            '     zone,'||
            '     analysis_date,'||
            '     required_qty,'||
            '     avail_qty,'||
            '     po_reschedule_count,'||
            '     po_count,'||
            '     po_cancel_count,'||
            '     buy_order_value,'||
            '     buy_order_value2,'||
            '     buy_order_count,'||
            '     net_avail_qty,'||
            '     net_avail_qty_cum,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     supplier_lead_time,';
        end if;
        l_sql := l_sql||
            '     created_by, creation_date,'||
            '     last_updated_by, last_update_date, last_update_login'||
            ' )'||
            ' select'||
            '     :p_st_transaction_id,'||
            '     0,'||
            '     f.sr_instance_id,'||
            '     f.organization_id,'||
            '     f.owning_inst_id,'||
            '     f.owning_org_id,'||
            '     f.inventory_item_id,'||
            '     f.supplier_id,'||
            '     f.supplier_site_id,'||
            '     f.region_id,'||
            '     mtp.organization_code,'||
            '     mtp2.organization_code,'||
            '     mi.item_name,'||
            '     decode(f.supplier_id, -23453, null, smv.supplier_name),'||
            '     decode(f.supplier_site_id, -23453, null, smv.supplier_site_code),'||
            '     decode(f.region_id, -23453, null, smv.zone),'||
            '     f.analysis_date,'||
            '     f.required_qty,'||
            '     f.avail_qty,'||
            '     f.po_reschedule_count,'||
            '     f.po_count,'||
            '     f.po_cancel_count,'||
            '     f.buy_order_value,'||
            '     f.buy_order_value2,'||
            '     f.buy_order_count,'||
            '     f.net_avail_qty,'||
            '     f.net_avail_qty_cum,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     f.supplier_lead_time,';
        end if;
        l_sql := l_sql||
            '     fnd_global.user_id, sysdate,'||
            '     fnd_global.user_id, sysdate, fnd_global.login_id'||
            ' from'||
            '     '||l_apps_schema||'.msc_suppliers_f'||l_suffix||' f,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp2,'||
            '     '||l_apps_schema||'.msc_items'||l_suffix||' mi,'||
            '     '||l_apps_schema||'.msc_phub_suppliers_mv'||l_suffix||' smv'||
            ' where f.plan_id=:p_plan_id'||
            '     and f.plan_run_id=:p_plan_run_id'||
            '     and f.aggr_type=0'||
            '     and mtp.partner_type(+)=3'||
            '     and mtp.sr_instance_id(+)=f.sr_instance_id'||
            '     and mtp.sr_tp_id(+)=f.organization_id'||
            '     and mtp2.partner_type(+)=3'||
            '     and mtp2.sr_instance_id(+)=f.owning_inst_id'||
            '     and mtp2.sr_tp_id(+)=f.owning_org_id'||
            '     and mi.inventory_item_id(+)=f.inventory_item_id'||
            '     and smv.supplier_id(+)=f.supplier_id'||
            '     and smv.supplier_site_id(+)=f.supplier_site_id'||
            '     and smv.region_id(+)=f.region_id';

        execute immediate l_sql using p_st_transaction_id, p_plan_id, p_plan_run_id;
        commit;
        msc_phub_util.log('msc_supplier_pkg.export_suppliers_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_supplier_pkg.export_suppliers_f: '||sqlerrm;
            msc_phub_util.log(errbuf);
    end export_suppliers_f;

    procedure import_suppliers_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_suppliers_f';
        l_fact_table varchar2(30) := 'msc_suppliers_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_supplier_pkg.import_suppliers_f');
        retcode := 0;
        errbuf := null;

        l_result := l_result + msc_phub_util.prepare_staging_dates(
            l_staging_table, 'analysis_date', p_st_transaction_id,
            p_upload_mode, p_overwrite_after_date,
            p_plan_start_date, p_plan_cutoff_date);

        l_result := l_result + msc_phub_util.prepare_fact_dates(
            l_fact_table, 1, 'analysis_date', p_plan_id, p_plan_run_id,
            p_upload_mode, p_overwrite_after_date);

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'sr_instance_id', 'organization_id', 'organization_code');

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'owning_inst_id', 'owning_org_id', 'owning_org_code');

        l_result := l_result + msc_phub_util.decode_item_key(
            l_staging_table, p_st_transaction_id, 'inventory_item_id', 'item_name');

        l_result := l_result + msc_phub_util.decode_supplier_key(
            l_staging_table, p_st_transaction_id,
            'supplier_id', 'supplier_site_id', 'region_id',
            'supplier_name', 'supplier_site_code', 'zone');

        msc_phub_util.log('msc_supplier_pkg.import_suppliers_f: insert into msc_suppliers_f');
        insert into msc_suppliers_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            owning_inst_id,
            owning_org_id,
            inventory_item_id,
            supplier_id,
            supplier_site_id,
            region_id,
            analysis_date,
            required_qty,
            avail_qty,
            po_reschedule_count,
            po_count,
            po_cancel_count,
            buy_order_value,
            buy_order_value2,
            buy_order_count,
            net_avail_qty,
            net_avail_qty_cum,
            supplier_lead_time,
            aggr_type, category_set_id, sr_category_id,
            created_by, creation_date,
            last_updated_by, last_update_date, last_update_login
        )
        select
            p_plan_id,
            p_plan_run_id,
            nvl(sr_instance_id, -23453),
            nvl(organization_id, -23453),
            nvl(owning_inst_id, -23453),
            nvl(owning_org_id, -23453),
            nvl(inventory_item_id, -23453),
            nvl(supplier_id, -23453),
            nvl(supplier_site_id, -23453),
            nvl(region_id, -23453),
            analysis_date,
            required_qty,
            avail_qty,
            po_reschedule_count,
            po_count,
            po_cancel_count,
            buy_order_value,
            buy_order_value2,
            buy_order_count,
            net_avail_qty,
            net_avail_qty_cum,
            supplier_lead_time,
            0, -23453, -23453,
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_suppliers_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_supplier_pkg.import_suppliers_f: inserted='||sql%rowcount);
        commit;

        summarize_suppliers_f(errbuf, retcode, p_plan_id, p_plan_run_id);

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_supplier_pkg.import_suppliers_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_supplier_pkg.import_suppliers_f: '||sqlerrm;
            msc_phub_util.log(errbuf);
    end import_suppliers_f;

end msc_supplier_pkg;

/
