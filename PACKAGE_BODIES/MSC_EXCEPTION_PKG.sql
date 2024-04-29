--------------------------------------------------------
--  DDL for Package Body MSC_EXCEPTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_EXCEPTION_PKG" as
/* $Header: MSCHBEXB.pls 120.22.12010000.18 2010/03/03 23:44:10 wexia ship $ */

    PROCEDURE populate_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
            p_plan_id number, p_plan_run_id number) IS

        l_owning_currency_code varchar2(20) := msc_phub_util.get_owning_currency_code(p_plan_run_id);
        l_plan_start_date date;
        l_plan_cutoff_date date;
        l_plan_type number;
        l_sr_instance_id number;

    BEGIN
        msc_phub_util.log('msc_exception_pkg.populate_details:');
        retcode := 0;
        errbuf := NULL;

        select plan_type, sr_instance_id, plan_start_date, plan_cutoff_date
        into l_plan_type, l_sr_instance_id, l_plan_start_date, l_plan_cutoff_date
        from msc_plan_runs
        where plan_id=p_plan_id
        and plan_run_id=p_plan_run_id;

        insert into msc_exceptions_f
           (plan_id,
            plan_run_id,
            organization_id,
            sr_instance_id,
            inventory_item_id,
            department_id,
            resource_id,
            supplier_id,
            supplier_site_id,
            supplier_region_id,
            customer_id,
            customer_site_id,
            customer_region_id,
            project_id,
            task_id,
            owning_org_id,
            owning_inst_id,
            ship_method,
            analysis_date,
            aggr_type, category_set_id, sr_category_id,
            exception_type,
            exception_count,
            exception_value,
            exception_value2,
            exception_days,
            exception_quantity,
            exception_ratio,
            created_by,
            creation_date,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_id,
            program_login_id,
            program_application_id,
            request_id)
     select
               exception_tbl.plan_id,
               p_plan_run_id,
               exception_tbl.organization_id,
               exception_tbl.sr_instance_id,
               exception_tbl.inventory_item_id,
               exception_tbl.department_id,
               exception_tbl.resource_id,
               exception_tbl.supplier_id,
               exception_tbl.supplier_site_id,
               nvl(mps.region_id, -23453) supplier_region_id,
               exception_tbl.customer_id,
               exception_tbl.customer_site_id,
               nvl(mpc.region_id, -23453) customer_region_id,
               exception_tbl.project_id,
               exception_tbl.task_id,
               exception_tbl.owning_org_id,
               exception_tbl.owning_inst_id,
               nvl(exception_tbl.ship_method, '-23453'),
               exception_tbl.analysis_date,
               to_number(0) aggr_type,
               to_number(-23453) category_set_id,
               to_number(-23453) sr_category_id,
               exception_tbl.exception_type,
               exception_tbl.exception_count,
               exception_tbl.exception_value,
               exception_tbl.exception_value
                            * decode(exception_tbl.currency_code,
                                  fnd_profile.value('MSC_HUB_CUR_CODE_RPT'),1, nvl(mcc.CONV_RATE,0))
                                  exception_value2,
               exception_tbl.exception_days,
               exception_tbl.exception_quantity,
             exception_tbl.exception_ratio,
             fnd_global.user_id,
             sysdate,
             sysdate,
             fnd_global.user_id,
             fnd_global.login_id,
             fnd_global.conc_program_id,
             fnd_global.conc_login_id,
             fnd_global.prog_appl_id,
             fnd_global.conc_request_id
        from (
                select
                    med.plan_id,
                    decode(sign(nvl(med.organization_id, -23453)),
                        -1, -23453, med.organization_id) organization_id,
                    decode(sign(nvl(med.organization_id, -23453)),
                        -1, -23453, med.sr_instance_id) sr_instance_id,
                    nvl(decode(med.inventory_item_id,-1,
                                                 decode(med.exception_type,23,
                                                           md.inventory_item_id,
                                                           nvl(ms.inventory_item_id,md.inventory_item_id)),
                            med.inventory_item_id), -23453) inventory_item_id,
                    nvl(decode(med.department_id, -1, -23453, med.department_id), -23453) department_id,
                    nvl(decode(med.department_id, -1, -23453, med.resource_id), -23453) resource_id,
                    nvl(decode(med.exception_type,48,decode(med.number2,1,-23453,
                                nvl(med.supplier_id, ms.supplier_id)),
                49, -23453,
                                nvl(med.supplier_id, ms.supplier_id)), -23453) supplier_id,
                    nvl(decode(med.exception_type,48,decode(med.number2,1,-23453,
                                nvl(med.supplier_site_id, ms.supplier_site_id)),
                49, -23453,
                                nvl(med.supplier_site_id, ms.supplier_site_id)), -23453) supplier_site_id,
                    nvl(decode(med.exception_type,48,decode(med.number2,1,-23453,
                                nvl(med.zone_id, ms.zone_id)),
                49, -23453,
                                nvl(med.zone_id, ms.zone_id)), -23453) supplier_region_id,
                    nvl(decode(med.exception_type, 24, md.customer_id,
                                               25, md.customer_id,
                                               26,md.customer_id,
                                               27, md.customer_id,
                                               52,md.customer_id,
                                               13,md.customer_id,
                                               67,md.customer_id,
                                               68,md.customer_id,
                                               70,md.customer_id,
                                               71,md.customer_id,
                                               97,med.customer_id,
                                               md2.customer_id), -23453) customer_id,
                    nvl(decode(med.exception_type, 24, md.customer_site_id,
                                               25, md.customer_site_id,
                                               26,md.customer_site_id,
                                               27, md.customer_site_id,
                                               52, md.customer_site_id,
                                               13, md.customer_site_id,
                                               67, md.customer_site_id,
                                               68, md.ship_to_site_id,
                                               70, md.customer_site_id,
                                               71, md.customer_site_id,
                                               97, med.customer_site_id,
                                               md2.customer_site_id), -23453) customer_site_id,
                    nvl(decode(med.exception_type, 24, md.zone_id,
                                               25, md.zone_id,
                                               26,md.zone_id,
                                               27, md.zone_id,
                                               52, md.zone_id,
                                               13, md.zone_id,
                                               67, md.zone_id,
                                               68, -23453,
                                               70, md.zone_id,
                                               71, md.zone_id,
                                               97, med.zone_id,
                                               md2.zone_id), -23453) customer_region_id,
                    decode(med.exception_type, 18, nvl(med.number1, -23453),
                                                17,nvl(med.number1, -23453),
                                                19, nvl(med.number4,nvl(ms.project_id,-23453)),
                                                nvl(md.project_id, nvl(ms.project_id,-23453))) project_id,
                    decode(med.exception_type, 18, nvl(med.number2, -23453),
                                                17, nvl(med.number2, -23453),
                                                19, decode(med.number4,null,nvl(ms.task_id,-23453),med.number1),
                                                nvl(md.task_id, nvl(ms.task_id,-23453)) ) task_id,

                    decode(sign(nvl(med.organization_id, -23453)),
                         -1, msc_hub_calendar.get_item_org(p_plan_id, med.inventory_item_id,
                            decode(sign(nvl(med.sr_instance_id, -23453)),
                                -1, l_sr_instance_id, med.sr_instance_id)),
                         med.organization_id) owning_org_id,

                    decode(sign(nvl(med.sr_instance_id, -23453)),
                        -1, l_sr_instance_id, med.sr_instance_id) owning_inst_id,

                    nvl(mtp.currency_code, l_owning_currency_code) currency_code,
                   DECODE ( med.exception_type,
                          55, ms.ship_method,
                          56, ms.ship_method,
                          57, ms.ship_method,
                          59, ms.ship_method,
                          40, ms.ship_method,
                          61, ms.ship_method,
                          38,msc_get_name.ship_method(med.plan_id,med.department_id,
                         med.sr_instance_id),
                          39, msc_get_name.ship_method(med.plan_id,med.department_id,med.sr_instance_id),
                          50,msc_get_name.ship_method(med.plan_id,med.department_id,med.sr_instance_id),
                          51,msc_get_name.ship_method(med.plan_id,med.department_id,med.sr_instance_id),
                          msc_get_name.department_code( decode (med.resource_id, -1, 1, 2),
                          med.department_id,
                          med.organization_id,
                          med.plan_id,
                          med.sr_instance_id)) ship_method,

                    trunc(nvl(med.date1, l_plan_start_date)) analysis_date,
                                med.exception_type,
                    count(*) exception_count,
                    sum(decode(med.exception_type,
                           2,abs(med.quantity) *msi.standard_cost,
                           3,med.quantity *msi.standard_cost,
                           6,(case when l_plan_type in (101,102,103,105) then med.number5
                            else med.quantity *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)) end),
                           7,(case when l_plan_type in (101,102,103,105) then med.number5
                            else med.quantity *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)) end),
                           8,med.quantity *nvl(msi.standard_cost,0),
                           9,med.quantity *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           10,med.quantity *nvl(msi.standard_cost,0),
                           11,abs(med.quantity) *nvl(msi.standard_cost,0),
                           13,abs(med.quantity) *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           14,abs(med.quantity) *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           15,med.quantity *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           16,med.quantity *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           17,abs(med.quantity) *nvl(msi.standard_cost,0),
                           18,med.quantity *nvl(msi.standard_cost,0),
                           23,md.using_requirement_quantity * msc_phub_util.get_list_price
                                  (med.plan_id,med.sr_instance_id,med.organization_id,md.inventory_item_id),
                           24,abs(med.quantity) *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           25,abs(med.quantity) *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           26,abs(med.quantity) *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           27,abs(med.quantity) *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           31,med.quantity *nvl(msi.standard_cost,0),
                           32,med.quantity *nvl(msi.standard_cost,0),
                           33,med.quantity *nvl(msi.standard_cost,0),
                           34,med.quantity *nvl(msi.standard_cost,0),
                           42,md.using_requirement_quantity*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           43,med.quantity*nvl(msi.standard_cost,0),
                           44,med.quantity*nvl(msi.standard_cost,0),
                           47,med.quantity *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           48,med.quantity *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           49,msc_get_name.demand_quantity(med.plan_id,med.sr_instance_id,
                                                med.supplier_id)*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           53,ms.new_order_quantity * msc_phub_util.get_list_price
                                (med.plan_id,med.sr_instance_id,med.organization_id,ms.inventory_item_id),
                           54,ms.new_order_quantity*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           55,ms.new_order_quantity*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           56,ms.new_order_quantity*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           57,ms.new_order_quantity*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           58,ms.new_order_quantity*msc_phub_util.get_list_price
                                (med.plan_id,med.sr_instance_id,med.organization_id,ms.inventory_item_id),
                           59,ms.new_order_quantity*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           60,ms.new_order_quantity*msc_phub_util.get_list_price
                                (med.plan_id,med.sr_instance_id,med.organization_id,ms.inventory_item_id),
                           62,ms.new_order_quantity*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           63,ms.new_order_quantity*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           64,ms.new_order_quantity*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           65,ms.new_order_quantity*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           66,ms.new_order_quantity*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           67,md.using_requirement_quantity*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           68,abs(med.quantity) *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           69,abs(med.quantity) *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           70,md.using_requirement_quantity*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           71,decode(med.number2, 2, ms.new_order_quantity,
                                            md.using_requirement_quantity)*nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           72,med.quantity *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           73, med.quantity *msi.standard_cost,
                           74, med.quantity *msi.standard_cost,
                           75, med.quantity *msi.standard_cost,
                           76,med.quantity *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           77,med.quantity *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           114,abs(med.quantity) *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                           to_number(null)) )exception_value,
                    sum(decode( med.exception_type,
                         2, (case when l_plan_type=8 then (med.date2 -med.date1)+1
                            when l_plan_type in (101,102,103,105) then med.number1
                            else med.date2 - med.date1 end),
                         3,decode(l_plan_type, 8,(med.date2 -med.date1)+1,
                                                    (med.date2 -med.date1)),
                         6,abs(ms.reschedule_days),                                                                        6,abs(ms.reschedule_days),
                         7,ms.reschedule_days,
                         10,l_plan_start_date - med.date1,
                         13,l_plan_start_date - md.old_demand_date,
                         14,l_plan_start_date - md.old_demand_date,
                         15,greatest( ms.new_schedule_date - med.date2, 0.01),
                         16,greatest( ms.new_schedule_date - med.date2, 0.01),
                         24,decode((md.dmd_satisfied_date - md.using_assembly_demand_date),0,0,
                                    greatest(md.dmd_satisfied_date - md.using_assembly_demand_date, 0.01)),
                         25,decode((md.using_assembly_demand_date - md.dmd_satisfied_date), 0,0,
                                    greatest(md.using_assembly_demand_date - md.dmd_satisfied_date, 0.01)),
                         26,decode((md.dmd_satisfied_date - md.using_assembly_demand_date),0,0,
                                    greatest(md.dmd_satisfied_date - md.using_assembly_demand_date, 0.01)),
                         27,decode((md.using_assembly_demand_date - md.dmd_satisfied_date), 0,0,
                                    greatest(md.using_assembly_demand_date - md.dmd_satisfied_date, 0.01)),
                         62,nvl(med.quantity,0),
                         63,med.quantity,
                         64,med.quantity,
                         65,med.quantity,
                         66,med.quantity,
                         to_number(null)--default
                         )) exception_days,
                   sum(decode( med.exception_type,
                           2,  abs(med.quantity),
                           3,  med.quantity,
                           8, med.quantity,
                           10, med.quantity,
                           11, abs(med.quantity),
                           17, abs(med.quantity),
                           18, med.quantity,
                           20, abs(med.quantity),
                           28, med.quantity,
                           31, med.quantity,
                           32, med.quantity,
                           33, med.quantity,
                           34, med.quantity,
                           36, med.quantity,
                           37, med.quantity,
                           42,0,
                           43, med.quantity,
                           44, med.quantity,
                           67, abs(med.quantity),
                           73, med.quantity,
                           74, med.quantity,
                           75, med.quantity,
                           85, med.quantity,
                           86, med.quantity,
                           113, med.quantity,
                           to_number(null)
                           )) exception_quantity,
                   sum(decode( med.exception_type,
                           9,(ms.schedule_compress_days/
                                (ms.schedule_compress_days +
                                (ms.new_schedule_date - ms.new_order_placement_date))),
                           21,med.quantity,
                           22,med.quantity,
                           23,med.quantity,
                           38,med.quantity,
                           39,med.quantity,
                           40,med.quantity,
                           45,med.quantity,
                           46,med.quantity,
                           48,abs(med.number3-med.number1),
                           50,abs(med.quantity),
                           51,abs(med.quantity),
                           53,med.quantity,
                           54,med.quantity,
                           55,med.quantity,
                           56,med.quantity,
                           57,(case when l_plan_type in (101,102,103,105) then
                           decode(nvl(med.number4,0),0,0,nvl(med.number6,0)/med.number4)
                           else decode(nvl(med.quantity,0),0,0,nvl(med.number5,0)/med.quantity)
                           end),
                           58,(decode(nvl(med.quantity,0),0,0,nvl(med.number5,0)/med.quantity)),
                           59,(decode(nvl(med.quantity,0),0,0,nvl(med.number5,0)/med.quantity)),
                           60,(decode(nvl(med.quantity,0),0,0,nvl(med.number5,0)/med.quantity)),
                           61,med.quantity,
                           79,med.quantity,
                           80,med.quantity,
                           to_number(null)
                           )) exception_ratio


               from
                    msc_exception_details med,
                    msc_supplies ms,
                    msc_demands md,
                    msc_demands md2,
                    msc_full_pegging mfp,
                    msc_system_items msi,
                    msc_trading_partners mtp
               where med.plan_id=p_plan_id
                    and l_plan_type <> 6
                    and msi.inventory_item_id(+) = med.inventory_item_id
                    and msi.organization_id(+) = med.organization_id
                    and msi.sr_instance_id(+) = med.sr_instance_id
                    and msi.plan_id(+) = med.plan_id
                    and ms.sr_instance_id(+) = med.sr_instance_id
                    and ms.transaction_id(+) = med.number1
                    and ms.plan_id(+) = med.plan_id
                    and md.sr_instance_id(+) = med.sr_instance_id
                    and md.demand_id(+) = med.number1
                    and md.plan_id(+) = med.plan_id
                    and mfp.pegging_id(+) = med.number2
                    and mfp.plan_id(+) = med.plan_id
                    and md2.demand_id(+) = mfp.demand_id
                    and md2.plan_id(+) = mfp.plan_id
                    and mtp.sr_instance_id(+) = med.sr_instance_id
                    and mtp.sr_tp_id(+) = med.organization_id
                    and mtp.partner_type(+) = 3
               group by
                    med.plan_id,
                    decode(sign(nvl(med.organization_id, -23453)),
                        -1, -23453, med.organization_id),
                    decode(sign(nvl(med.organization_id, -23453)),
                        -1, -23453, med.sr_instance_id),
                    nvl(decode(med.inventory_item_id,-1,
                                                 decode(med.exception_type,23,
                                                           md.inventory_item_id,
                                                           nvl(ms.inventory_item_id,md.inventory_item_id)),
                            med.inventory_item_id), -23453),
                    nvl(decode(med.department_id, -1, -23453, med.department_id), -23453),
                    nvl(decode(med.department_id, -1, -23453, med.resource_id), -23453),
                    nvl(decode(med.exception_type,48,decode(med.number2,1,-23453,
                                                                nvl(med.supplier_id, ms.supplier_id)),
                        49, -23453,
                                               nvl(med.supplier_id, ms.supplier_id)), -23453),
                    nvl(decode(med.exception_type,48,decode(med.number2,1,-23453,
                                                                   nvl(med.supplier_site_id, ms.supplier_site_id)),
                        49, -23453,
                                                                      nvl(med.supplier_site_id, ms.supplier_site_id)), -23453),
                    nvl(decode(med.exception_type,48,decode(med.number2,1,-23453,
                                                                   nvl(med.zone_id, ms.zone_id)),
                        49, -23453,
                                                                      nvl(med.zone_id, ms.zone_id)), -23453),
                    nvl(decode(med.exception_type, 24, md.customer_id,
                                               25, md.customer_id,
                                               26,md.customer_id,
                                               27, md.customer_id,
                                               52,md.customer_id,
                                               13,md.customer_id,
                                               67,md.customer_id,
                                               68,md.customer_id,
                                               70,md.customer_id,
                                               71,md.customer_id,
                                               97,med.customer_id,
                                               md2.customer_id), -23453),
                    nvl(decode(med.exception_type, 24, md.customer_site_id,
                                               25, md.customer_site_id,
                                               26,md.customer_site_id,
                                               27, md.customer_site_id,
                                               52, md.customer_site_id,
                                               13, md.customer_site_id,
                                               67, md.customer_site_id,
                                               68, md.ship_to_site_id,
                                               70, md.customer_site_id,
                                               71, md.customer_site_id,
                                               97, med.customer_site_id,
                                               md2.customer_site_id), -23453),
                    nvl(decode(med.exception_type, 24, md.zone_id,
                                               25, md.zone_id,
                                               26,md.zone_id,
                                               27, md.zone_id,
                                               52, md.zone_id,
                                               13, md.zone_id,
                                               67, md.zone_id,
                                               68, -23453,
                                               70, md.zone_id,
                                               71, md.zone_id,
                                               97, med.zone_id,
                                               md2.zone_id), -23453),
                   decode(med.exception_type, 18, nvl(med.number1, -23453),
                                                17,nvl(med.number1, -23453),
                                                19, nvl(med.number4,nvl(ms.project_id,-23453)),
                                                nvl(md.project_id, nvl(ms.project_id,-23453))),
                    decode(med.exception_type, 18, nvl(med.number2, -23453),
                                                17, nvl(med.number2, -23453),
                                                19, decode(med.number4,null,nvl(ms.task_id,-23453),med.number1),
                                                nvl(md.task_id, nvl(ms.task_id,-23453)) ),

                    decode(sign(nvl(med.organization_id, -23453)),
                         -1, msc_hub_calendar.get_item_org(p_plan_id, med.inventory_item_id,
                            decode(sign(nvl(med.sr_instance_id, -23453)),
                                -1, l_sr_instance_id, med.sr_instance_id)),
                         med.organization_id),

                    decode(sign(nvl(med.sr_instance_id, -23453)),
                        -1, l_sr_instance_id, med.sr_instance_id),

                    nvl(mtp.currency_code, l_owning_currency_code),
                    DECODE ( med.exception_type,
                          55, ms.ship_method,
                          56, ms.ship_method,
                          57, ms.ship_method,
                          59, ms.ship_method,
                          40, ms.ship_method,
                          61, ms.ship_method,
                          38,msc_get_name.ship_method(med.plan_id,med.department_id,
                         med.sr_instance_id),
                          39, msc_get_name.ship_method(med.plan_id,med.department_id,med.sr_instance_id),
                          50,msc_get_name.ship_method(med.plan_id,med.department_id,med.sr_instance_id),
                          51,msc_get_name.ship_method(med.plan_id,med.department_id,med.sr_instance_id),
                          msc_get_name.department_code( decode (med.resource_id, -1, 1, 2),
                          med.department_id,
                          med.organization_id,
                          med.plan_id,
                          med.sr_instance_id)),
                    med.exception_type,
              trunc(nvl(med.date1, l_plan_start_date))

                -- SNO
                union all
                select
                    t.plan_id,
                    t.organization_id,
                    t.sr_instance_id,
                    t.inventory_item_id,
                    t.department_id,
                    t.resource_id,
                    t.supplier_id,
                    t.supplier_site_id,
                    t.supplier_region_id,
                    t.customer_id,
                    t.customer_site_id,
                    t.customer_region_id,
                    -23453 project_id,
                    -23453 task_id,
                    t.owning_org_id,
                    t.owning_inst_id,
                    nvl(mtp.currency_code, l_owning_currency_code) currency_code,
                    null ship_method,
                    t.date1 analysis_date,
                    t.exception_type,
                    count(*) exception_count,
                    sum(decode(t.exception_type,
                        150, abs(t.quantity) *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                        151, t.quantity *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                        152, t.quantity *nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100)),
                        160, abs(t.quantity) *msi.standard_cost,
                        161, t.quantity *msi.standard_cost,
                        162, t.quantity *msi.standard_cost,
                        190, abs(t.quantity) *msi.standard_cost,
                        191, t.quantity *msi.standard_cost,
                        to_number(null)) )exception_value,
                    to_number(null) exception_days,
                    sum(decode( t.exception_type,
                        150, abs(t.quantity),
                        151, t.quantity,
                        152, t.quantity,
                        160, abs(t.quantity),
                        161, t.quantity,
                        162, t.quantity,
                        170, abs(t.quantity),
                        171, t.quantity,
                        172, abs(t.quantity),
                        173, t.quantity,
                        180, abs(t.quantity),
                        181, t.quantity,
                        190, abs(t.quantity),
                        191, t.quantity,
                        200, abs(t.quantity),
                        201, t.quantity,
                        to_number(null))) exception_quantity,
                    avg(t.number2) exception_ratio
                from
                    (select
                        med.plan_id,
                        nvl(decode(med.organization_id, -1, -23453, med.organization_id), -23453) organization_id,
                        nvl(decode(med.sr_instance_id, -1, -23453, med.sr_instance_id), -23453) sr_instance_id,
                        nvl(decode(med.inventory_item_id, -1, -23453, med.inventory_item_id), -23453) inventory_item_id,
                        nvl(decode(med.department_id, -1, -23453, med.department_id), -23453) department_id,
                        nvl(decode(med.department_id, -1, -23453, med.resource_id), -23453) resource_id,
                        nvl(med.supplier_id, -23453) supplier_id,
                        nvl(med.supplier_site_id, -23453) supplier_site_id,
                        nvl(med.zone_id, -23453) supplier_region_id,
                        nvl(med.customer_id, -23453) customer_id,
                        nvl(med.customer_site_id, -23453) customer_site_id,
                        nvl(med.zone_id, -23453) customer_region_id,

                        decode(sign(nvl(med.organization_id, -23453)),
                             -1, msc_hub_calendar.get_item_org(p_plan_id, med.inventory_item_id,
                                decode(sign(nvl(med.sr_instance_id, -23453)),
                                    -1, l_sr_instance_id, med.sr_instance_id)),
                             med.organization_id) owning_org_id,

                        decode(sign(nvl(med.sr_instance_id, -23453)),
                            -1, l_sr_instance_id, med.sr_instance_id) owning_inst_id,
                        med.exception_type,
                        med.quantity,
                        trunc(nvl(med.date1, l_plan_start_date)) date1,
                        med.number2
                    from
                        msc_exception_details med
                    where med.plan_id=p_plan_id
                        and l_plan_type = 6) t,
                    msc_system_items msi,
                    msc_trading_partners mtp
                where msi.plan_id(+) = t.plan_id
                    and msi.inventory_item_id(+) = t.inventory_item_id
                    and msi.organization_id(+) = t.owning_org_id
                    and msi.sr_instance_id(+) = t.owning_inst_id
                    and mtp.sr_instance_id(+) = t.sr_instance_id
                    and mtp.sr_tp_id(+) = t.organization_id
                    and mtp.partner_type(+) = 3
                group by
                    t.plan_id,
                    t.organization_id,
                    t.sr_instance_id,
                    t.inventory_item_id,
                    t.department_id,
                    t.resource_id,
                    t.supplier_id,
                    t.supplier_site_id,
                    t.supplier_region_id,
                    t.customer_id,
                    t.customer_site_id,
                    t.customer_region_id,
                    t.owning_org_id,
                    t.owning_inst_id,
                    nvl(mtp.currency_code, l_owning_currency_code),
                    t.date1,
                    t.exception_type
              ) exception_tbl,
            msc_currency_conv_mv mcc,
            msc_phub_customers_mv mpc,
            msc_phub_suppliers_mv mps
        where mcc.from_currency(+) = exception_tbl.currency_code
            and mcc.to_currency(+) = fnd_profile.value('MSC_HUB_CUR_CODE_RPT')
            and mcc.calendar_date(+) = exception_tbl.analysis_date
            and mpc.customer_id(+) = exception_tbl.customer_id
            and mpc.customer_site_id(+) = exception_tbl.customer_site_id
            and mpc.region_id(+) = decode(nvl(exception_tbl.customer_id, -23453),
                -23453, nvl(exception_tbl.customer_region_id, -23453), mpc.region_id(+))
            and mps.supplier_id(+) = exception_tbl.supplier_id
            and mps.supplier_site_id(+) = exception_tbl.supplier_site_id
            and mps.region_id(+) = decode(nvl(exception_tbl.supplier_id, -23453),
                -23453, nvl(exception_tbl.supplier_region_id, -23453), mps.region_id(+));

        msc_phub_util.log('msc_exceptions_f, insert='||sql%rowcount);
        COMMIT;

    summarize_exceptions_f(errbuf, retcode, p_plan_id, p_plan_run_id);

    EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
                errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_DUPLICATE_DATA')||SQLCODE||' -ERROR- '||sqlerrm;
            retcode := 2;
          WHEN OTHERS THEN
                errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_POPULATE_ERROR')||SQLCODE||' -ERROR- '||sqlerrm;
                retcode := 2;
    END populate_details;


    procedure summarize_exceptions_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_category_set_id1 number := fnd_profile.value('MSC_HUB_CAT_SET_ID_1');
    begin
        msc_phub_util.log('msc_exception_pkg.summarize_exceptions_f');
        retcode := 0;
        errbuf := '';

        delete from msc_exceptions_f
        where plan_id=p_plan_id and plan_run_id=p_plan_run_id and aggr_type>0;
        msc_phub_util.log('msc_exception_pkg.summarize_exceptions_f, delete='||sql%rowcount);
        commit;

        -- level 1
        insert into msc_exceptions_f (
            plan_id, plan_run_id,
            organization_id, sr_instance_id, inventory_item_id,
            department_id, resource_id,
            supplier_id, supplier_site_id, supplier_region_id,
            customer_id, customer_site_id, customer_region_id,
            project_id, task_id,
            owning_org_id, owning_inst_id,
            ship_method, analysis_date,
            aggr_type, category_set_id, sr_category_id,
            exception_type,
            exception_count,
            exception_value,
            exception_value2,
            exception_days,
            exception_quantity,
            exception_ratio,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category (42, 43, 44)
        select
            f.plan_id, f.plan_run_id,
            f.organization_id, f.sr_instance_id,
            to_number(-23453) inventory_item_id,
            f.department_id, f.resource_id,
            f.supplier_id, f.supplier_site_id, f.supplier_region_id,
            f.customer_id, f.customer_site_id, f.customer_region_id,
            f.project_id, f.task_id,
            f.owning_org_id, f.owning_inst_id,
            f.ship_method, f.analysis_date,
            to_number(42) aggr_type,
            l_category_set_id1 category_set_id,
            nvl(q.sr_category_id, -23453),
            f.exception_type,
            sum(f.exception_count),
            sum(f.exception_value),
            sum(f.exception_value2),
            sum(f.exception_days),
            sum(f.exception_quantity),
            sum(f.exception_ratio),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_exceptions_f f,
            msc_phub_item_categories_mv q
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type=0
            and f.owning_inst_id=q.sr_instance_id(+)
            and f.owning_org_id=q.organization_id(+)
            and f.inventory_item_id=q.inventory_item_id(+)
            and q.category_set_id(+)=l_category_set_id1
        group by
            f.plan_id, f.plan_run_id,
            f.organization_id, f.sr_instance_id,
            f.department_id, f.resource_id,
            f.supplier_id, f.supplier_site_id, f.supplier_region_id,
            f.customer_id, f.customer_site_id, f.customer_region_id,
            f.project_id, f.task_id,
            f.owning_org_id, f.owning_inst_id,
            f.ship_method, f.analysis_date,
            nvl(q.sr_category_id, -23453),
            f.exception_type;

        msc_phub_util.log('msc_exception_pkg.summarize_exceptions_f, level1='||sql%rowcount);
        commit;

        -- level 2
        insert into msc_exceptions_f (
            plan_id, plan_run_id,
            organization_id, sr_instance_id, inventory_item_id,
            department_id, resource_id,
            supplier_id, supplier_site_id, supplier_region_id,
            customer_id, customer_site_id, customer_region_id,
            project_id, task_id,
            owning_org_id, owning_inst_id,
            ship_method, analysis_date,
            aggr_type, category_set_id, sr_category_id,
            exception_type,
            exception_count,
            exception_value,
            exception_value2,
            exception_days,
            exception_quantity,
            exception_ratio,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category-mfg_period (1016, 1017, 1018)
        select
            f.plan_id, f.plan_run_id,
            f.organization_id, f.sr_instance_id, f.inventory_item_id,
            f.department_id, f.resource_id,
            f.supplier_id, f.supplier_site_id, f.supplier_region_id,
            f.customer_id, f.customer_site_id, f.customer_region_id,
            f.project_id, f.task_id,
            f.owning_org_id, f.owning_inst_id,
            f.ship_method,
            d.mfg_period_start_date analysis_date,
            decode(f.aggr_type, 42, 1016, 43, 1017, 1018) aggr_type,
            f.category_set_id,
            f.sr_category_id,
            f.exception_type,
            sum(f.exception_count),
            sum(f.exception_value),
            sum(f.exception_value2),
            sum(f.exception_days),
            sum(f.exception_quantity),
            sum(f.exception_ratio),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_exceptions_f f,
            msc_phub_dates_mv d
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type between 42 and 44
            and f.analysis_date = d.calendar_date
            and d.mfg_period_start_date is not null
        group by
            f.plan_id, f.plan_run_id,
            f.organization_id, f.sr_instance_id, f.inventory_item_id,
            f.department_id, f.resource_id,
            f.supplier_id, f.supplier_site_id, f.supplier_region_id,
            f.customer_id, f.customer_site_id, f.customer_region_id,
            f.project_id, f.task_id,
            f.owning_org_id, f.owning_inst_id,
            f.ship_method,
            d.mfg_period_start_date,
            decode(f.aggr_type, 42, 1016, 43, 1017, 1018),
            f.category_set_id,
            f.sr_category_id,
            f.exception_type;

        msc_phub_util.log('msc_exception_pkg.summarize_exceptions_f, level2='||sql%rowcount);
        commit;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_exception_pkg.summarize_exceptions_f: '||sqlerrm;
            raise;

    end summarize_exceptions_f;

    procedure export_exceptions_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_exception_pkg.export_exceptions_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_exceptions_f where st_transaction_id=p_st_transaction_id;
        commit;

        l_sql :=
            ' insert into msc_st_exceptions_f('||
            '     st_transaction_id,'||
            '     error_code,'||
            '     sr_instance_id,'||
            '     organization_id,'||
            '     owning_inst_id,'||
            '     owning_org_id,'||
            '     inventory_item_id,'||
            '     department_id,'||
            '     resource_id,'||
            '     customer_id,'||
            '     customer_site_id,'||
            '     customer_region_id,'||
            '     supplier_id,'||
            '     supplier_site_id,'||
            '     supplier_region_id,'||
            '     project_id,'||
            '     task_id,'||
            '     organization_code,'||
            '     owning_org_code,'||
            '     item_name,'||
            '     department_code,'||
            '     department_class,'||
            '     resource_code,'||
            '     resource_group_name,'||
            '     customer_name,'||
            '     customer_site_code,'||
            '     customer_zone,'||
            '     supplier_name,'||
            '     supplier_site_code,'||
            '     supplier_zone,'||
            '     project_number,'||
            '     task_number,'||
            '     ship_method,'||
            '     analysis_date,'||
            '     exception_type,'||
            '     exception_count,'||
            '     exception_value,'||
            '     exception_value2,'||
            '     exception_days,'||
            '     exception_quantity,'||
            '     exception_ratio,'||
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
            '     f.department_id,'||
            '     f.resource_id,'||
            '     f.customer_id,'||
            '     f.customer_site_id,'||
            '     f.customer_region_id,'||
            '     f.supplier_id,'||
            '     f.supplier_site_id,'||
            '     f.supplier_region_id,'||
            '     f.project_id,'||
            '     f.task_id,'||
            '     mtp.organization_code,'||
            '     mtp2.organization_code,'||
            '     mi.item_name,'||
            '     mdr.department_code,'||
            '     mdr.department_class,'||
            '     mdr.resource_code,'||
            '     mdr.resource_group_name,'||
            '     decode(f.customer_id, -23453, null, cmv.customer_name),'||
            '     decode(f.customer_site_id, -23453, null, cmv.customer_site),'||
            '     decode(f.customer_region_id, -23453, null, cmv.zone),'||
            '     decode(f.supplier_id, -23453, null, smv.supplier_name),'||
            '     decode(f.supplier_site_id, -23453, null, smv.supplier_site_code),'||
            '     decode(f.supplier_region_id, -23453, null, smv.zone),'||
            '     proj.project_number,'||
            '     proj.task_number,'||
            '     f.ship_method,'||
            '     f.analysis_date,'||
            '     f.exception_type,'||
            '     f.exception_count,'||
            '     f.exception_value,'||
            '     f.exception_value2,'||
            '     f.exception_days,'||
            '     f.exception_quantity,'||
            '     f.exception_ratio,'||
            '     fnd_global.user_id, sysdate,'||
            '     fnd_global.user_id, sysdate, fnd_global.login_id'||
            ' from'||
            '     '||l_apps_schema||'.msc_exceptions_f'||l_suffix||' f,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp2,'||
            '     '||l_apps_schema||'.msc_items'||l_suffix||' mi,'||
            '     '||l_apps_schema||'.msc_phub_customers_mv'||l_suffix||' cmv,'||
            '     '||l_apps_schema||'.msc_phub_suppliers_mv'||l_suffix||' smv,'||
            '     '||l_apps_schema||'.msc_department_resources'||l_suffix||' mdr,'||
            '     (select p.sr_instance_id, p.organization_id,'||
            '         p.project_id, t.task_id, p.project_number, t.task_number'||
            '     from '||l_apps_schema||'.msc_projects'||l_suffix||' p, '||l_apps_schema||'.msc_project_tasks'||l_suffix||' t'||
            '     where p.project_id=t.project_id'||
            '         and p.plan_id=t.plan_id'||
            '         and p.sr_instance_id=t.sr_instance_id'||
            '         and p.organization_id=t.organization_id'||
            '         and p.plan_id=-1) proj'||
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
            '     and mdr.plan_id(+)=-1'||
            '     and mdr.department_id(+)=f.department_id'||
            '     and mdr.resource_id(+)=f.resource_id'||
            '     and mdr.sr_instance_id(+)=f.sr_instance_id'||
            '     and mdr.organization_id(+)=f.organization_id'||
            '     and cmv.customer_id(+)=f.customer_id'||
            '     and cmv.customer_site_id(+)=f.customer_site_id'||
            '     and cmv.region_id(+)=f.customer_region_id'||
            '     and smv.supplier_id(+)=f.supplier_id'||
            '     and smv.supplier_site_id(+)=f.supplier_site_id'||
            '     and smv.region_id(+)=f.supplier_region_id'||
            '     and proj.project_id(+)=f.project_id'||
            '     and proj.task_id(+)=f.task_id'||
            '     and proj.sr_instance_id(+)=f.sr_instance_id'||
            '     and proj.organization_id(+)=f.organization_id';

        execute immediate l_sql using p_st_transaction_id, p_plan_id, p_plan_run_id;
        commit;
        msc_phub_util.log('msc_exception_pkg.export_exceptions_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_exception_pkg.export_exceptions_f: '||sqlerrm;
            msc_phub_util.log(errbuf);
    end export_exceptions_f;

    procedure import_exceptions_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_exceptions_f';
        l_fact_table varchar2(30) := 'msc_exceptions_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_exception_pkg.import_exceptions_f');
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

        l_result := l_result + msc_phub_util.decode_customer_key(
            l_staging_table, p_st_transaction_id,
            'customer_id', 'customer_site_id', 'customer_region_id',
            'customer_name', 'customer_site_code', 'customer_zone');

        l_result := l_result + msc_phub_util.decode_supplier_key(
            l_staging_table, p_st_transaction_id,
            'supplier_id', 'supplier_site_id', 'supplier_region_id',
            'supplier_name', 'supplier_site_code', 'supplier_zone');

        l_result := l_result + msc_phub_util.decode_resource_key(
            l_staging_table, p_st_transaction_id);

        l_result := l_result + msc_phub_util.decode_project_key(
            l_staging_table, p_st_transaction_id);

        msc_phub_util.log('msc_exception_pkg.import_exceptions_f: insert into msc_exceptions_f');
        insert into msc_exceptions_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            owning_inst_id,
            owning_org_id,
            inventory_item_id,
            department_id,
            resource_id,
            customer_id,
            customer_site_id,
            customer_region_id,
            supplier_id,
            supplier_site_id,
            supplier_region_id,
            project_id,
            task_id,
            ship_method,
            analysis_date,
            exception_type,
            exception_count,
            exception_value,
            exception_value2,
            exception_days,
            exception_quantity,
            exception_ratio,
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
            nvl(department_id, -23453),
            nvl(resource_id, -23453),
            nvl(customer_id, -23453),
            nvl(customer_site_id, -23453),
            nvl(customer_region_id, -23453),
            nvl(supplier_id, -23453),
            nvl(supplier_site_id, -23453),
            nvl(supplier_region_id, -23453),
            nvl(project_id, -23453),
            nvl(task_id, -23453),
            ship_method,
            analysis_date,
            exception_type,
            exception_count,
            exception_value,
            exception_value2,
            exception_days,
            exception_quantity,
            exception_ratio,
            0, -23453, -23453,
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_exceptions_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_exception_pkg.import_exceptions_f: inserted='||sql%rowcount);
        commit;

        summarize_exceptions_f(errbuf, retcode, p_plan_id, p_plan_run_id);

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_exception_pkg.import_exceptions_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_exception_pkg.import_exceptions_f: '||sqlerrm;
            msc_phub_util.log(errbuf);
    end import_exceptions_f;

end msc_exception_pkg;

/
