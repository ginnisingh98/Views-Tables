--------------------------------------------------------
--  DDL for Package Body MSC_SCE_PUBLISH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SCE_PUBLISH_PKG" AS
/* $Header: MSCXPUBB.pls 120.2.12010000.6 2008/10/07 15:21:00 hbinjola ship $ */


PROCEDURE publish_plan_orders (
  p_errbuf                  out nocopy varchar2,
  p_retcode                 out nocopy varchar2,
  p_plan_id                 in number,
  p_org_code                in varchar2 default null,
  p_planner_code            in varchar2 default null,
  p_abc_class               in varchar2 default null,
  p_item_id                 in number   default null,
  p_item_list		            in varchar2 default null,
  p_planning_gp             in varchar2 default null,
  p_project_id              in number   default null,
  p_task_id                 in number   default null,
  p_supplier_id             in number   default null,
  p_supplier_site_id        in number   default null,
  p_horizon_start           in varchar2,
  p_horizon_end             in varchar2,
  p_auto_version            in number   default 1,
  p_version                 in number   default null,
  p_purchase_order          in number   default 2,
  p_requisition             in number   default 2,
  p_overwrite		            in number   default 1,
  p_publish_dos             in number   default 1   -- bug#6893383 **SPP-Publish dos for defective supplier**
) IS

p_org_id                    Number;
p_inst_code                 Varchar2(3);
p_sr_instance_id            Number;
p_category_set_id           Number := null;
p_category_name             Varchar2(240) := null;
p_designator                Varchar2(10);
l_version                   Number;
l_user_id                   NUMBER;
l_user_name                 VARCHAR2(100);
l_resp_name                 VARCHAR2(30);
l_application_name          VARCHAR2(50);
l_item_name                 VARCHAR2(255);
l_log_message               VARCHAR2(1000);
l_supp_name                 VARCHAR2(100);
l_supp_site                 VARCHAR2(30);
l_records_exist             NUMBER;
l_cursor1                   NUMBER;
l_cursor2                   NUMBER;
l_language                  VARCHAR2(30);
l_language_code             VARCHAR2(4);
l_purchase_order 	    number;
l_requisition		    number;
l_external_repair_order number; --bug#6893383
l_plan_type         number; --bug#6893383

l_horizon_start	 	    date;		--canonical date
l_horizon_end		    date;		--canonical date

t_pub                       companyNameList := companyNameList();
t_pub_id                    numberList      := numberList();
t_pub_site                  companySiteList := companySiteList();
t_pub_site_id               numberList      := numberList();
t_org_id                    numberList;
t_sr_instance_id            numberList;
t_item_id                   numberList;
t_order_type		    numberList;
t_qty                       numberList;
t_planned_order_qty	    numberList;
t_released_qty	 	    numberList;
t_pub_ot                    numberList;
t_supp                      companyNameList := companyNameList();
t_supp_id                   numberList      := numberList();
t_supp_site                 companySiteList := companySiteList();
t_supp_site_id              numberList      := numberList();
t_ship_to                   companyNameList;
t_ship_to_id                numberList;
t_ship_to_site              companySiteList;
t_ship_to_site_id           numberList;
t_ship_from                 companyNameList;
t_ship_from_id              numberList;
t_ship_from_site            companySiteList;
t_ship_from_site_id         numberList;
t_bkt_type                  numberList;
t_posting_party_id          numberList;
t_owner_item_name           itemNameList;
t_owner_item_desc           itemDescList;
t_pub_ot_desc               fndMeaningList;
t_proj_number               numberList;
t_task_number               numberList;
t_planning_gp               planningGroupList;
t_bkt_type_desc             fndMeaningList;
t_posting_party_name        companyNameList;
t_uom_code                  itemUomList;
t_planner_code              plannerCodeList;
t_bucket_type               numberList;
t_key_date                  dateList;
t_ship_date                 dateList;
t_receipt_date              dateList;
t_source_supp_id            numberList;
t_source_supp_site_id       numberList;
t_order_num                 orderNumList; -- bug#7310179
t_line_num                  lineNumList;  -- bug#7310179
t_master_item_name          itemNameList := itemNameList();
t_master_item_desc          itemDescList := itemDescList();
t_supp_item_name            itemNameList := itemNameList();
t_supp_item_desc            itemDescList := itemDescList();
t_tp_uom                    itemUomList  := itemUomList();
t_tp_qty                    numberList   := numberList();
t_tp_planned_order_qty	    numberList   := numberList();
t_tp_released_qty	    numberList   := numberList();
t_base_item_type	    numberList	 := numberList();
t_base_item_id		    numberList	 := numberList();
t_base_item_name	    itemNameList := itemNameList();
t_base_item_desc	    itemDescList := itemDescList();

l_list_of_item	    	    varchar2(1000);
l_item_list		    varchar2(1000);
l_item_id		    number;
l_item_notification 	    varchar2(1000);

CURSOR planned_orders_c1 (
  p_plan_id                 in number,
  p_org_id                  in number,
  p_sr_instance_id          in number,
  p_horizon_start           in date,
  p_horizon_end             in date,
  p_category_set_id         in number,
  p_category_name           in varchar2,
  p_planner_code            in varchar2,
  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_item_list	    	    in varchar2,
  p_planning_gp             in varchar2,
  p_project_id              in number,
  p_task_id                 in number,
  p_supplier_id      in number,
  p_supplier_site_id in number,
  p_purchase_order	    in number,
  p_requisition		    in number
) IS


select sup.organization_id,           --org id
       sup.sr_instance_id,            --sr_instance_id
       sup.supplier_id,
       sup.supplier_site_id,
       i.base_item_id,
       sup.inventory_item_id,         --inventory item id
       sup.order_type,
       GREATEST ( SUM(decode(sup.firm_planned_type,
         		1,sup.firm_quantity,
         		sup.new_order_quantity)),
         	  SUM(nvl(sup.quantity_in_process,0)  +  nvl(sup.implemented_quantity,0))) quantity,     --quantity
       SUM(decode(sup.firm_planned_type, 1, sup.firm_quantity -
       		nvl(sup.quantity_in_process,0)  -  nvl(sup.implemented_quantity,0),
       		sup.new_order_quantity - nvl(sup.quantity_in_process,0) -
       		nvl(sup.implemented_quantity,0))) planned_order_quantity,
       SUM(nvl(sup.quantity_in_process,0)  +  nvl(sup.implemented_quantity,0)) released_quantity,
       i.item_name,                   --publisher item name
       i.description,                 --publisher item desc
       NULL, --sup.project_id,                --project number
       NULL, --sup.task_id,                   --task number
       NULL, --sup.planning_group,            --planning group
       i.uom_code,                    --primary uom
       i.planner_code,                --planner code
       mpb.bucket_type,
       decode(sup.firm_date,null,nvl(sup.new_dock_date,msc_calendar.DATE_OFFSET(sup.organization_id, sup.sr_instance_id, 1, sup.new_schedule_date, - nvl(i.postprocessing_lead_time,0))),
                            msc_calendar.DATE_OFFSET(sup.organization_id,sup.sr_instance_id, 1,sup.firm_date, - nvl(i.postprocessing_lead_time,0))
             ), --key_date
       decode(sup.firm_date, null, sup.new_ship_date , null), --ship_date
      decode(sup.firm_date,null,nvl(sup.new_dock_date,msc_calendar.DATE_OFFSET(sup.organization_id, sup.sr_instance_id, 1, sup.new_schedule_date, - nvl(i.postprocessing_lead_time,0))),
                            msc_calendar.DATE_OFFSET(sup.organization_id,sup.sr_instance_id, 1,sup.firm_date, - nvl(i.postprocessing_lead_time,0))
             ) --reciept_date
from   msc_plan_organizations_v ov,
       msc_system_items i,
       msc_supplies sup,
       msc_plan_buckets   mpb
where  ov.plan_id = p_plan_id and
       ov.planned_organization = NVL(p_org_id, ov.planned_organization) and
       ov.sr_instance_id = NVL(p_sr_instance_id, ov.sr_instance_id) and
       i.plan_id = ov.plan_id and
       i.organization_id = ov.planned_organization and
       i.sr_instance_id = ov.sr_instance_id and
       NVL(i.base_item_id, i.inventory_item_id)
             IN  (select nvl(i1.base_item_id,i1.inventory_item_id)
             	  from msc_system_items i1
                  where i1.inventory_item_id = nvl(p_item_id, i.inventory_item_id )
                  and i1.organization_id = i.organization_id
                  and i1.plan_id = i.plan_id
                  and i1.sr_instance_id = i.sr_instance_id) and
       i.item_name = nvl(p_item_list,i.item_name) and
       NVL(i.planner_code,'-99') = NVL(p_planner_code, NVL(i.planner_code,'-99')) and
       NVL(i.abc_class_name,'-99') = NVL(p_abc_class,NVL(i.abc_class_name,'-99')) and
       ((sup.order_type  IN (PLANNED_ORDER,PLANNED_NEW_BUY_ORDER) and
         sup.source_supplier_id is not null and
         sup.source_supplier_site_id is not null and
         sup.source_supplier_id = nvl(p_supplier_id, sup.source_supplier_id) and
         sup.source_supplier_site_id = nvl(p_supplier_site_id, sup.source_supplier_site_id)
         )
         OR
         (sup.order_type in (p_purchase_order, p_requisition) and
	  sup.supplier_id is not null and
	  sup.supplier_site_id is not null and
	  sup.supplier_id = nvl(p_supplier_id, sup.supplier_id) and
          sup.supplier_site_id = nvl(p_supplier_site_id, sup.supplier_site_id)
          )
       ) and
       sup.plan_id = i.plan_id and
       sup.organization_id = i.organization_id and
       sup.sr_instance_id = i.sr_instance_id and
       sup.inventory_item_id = i.inventory_item_id and
       nvl(sup.planning_group, '-99') = nvl(p_planning_gp, nvl(sup.planning_group, '-99')) and
       nvl(sup.project_id,-99) = nvl(p_project_id, nvl(sup.project_id,-99)) and
       nvl(sup.task_id, -99) = nvl(p_task_id, nvl(sup.task_id, -99)) and
       decode(sup.firm_date,null,nvl(sup.new_dock_date,msc_calendar.DATE_OFFSET(sup.organization_id,sup.sr_instance_id, 1,sup.new_schedule_date, - nvl(i.postprocessing_lead_time,0))),
                 		        msc_calendar.DATE_OFFSET(sup.organization_id,sup.sr_instance_id, 1,sup.firm_date, - nvl(i.postprocessing_lead_time,0))) --key_date between horizon
	   between NVL(p_horizon_start, sysdate - 36500)
	   		and NVL(p_horizon_end, sysdate + 36500)
         AND mpb.plan_id = sup.plan_id
	 and mpb.sr_instance_id = sup.sr_instance_id
	 and mpb.curr_flag = 1
	 and nvl(sup.firm_date,sup.new_schedule_date)
	                     between mpb.bkt_start_date and mpb.bkt_end_date
	 GROUP BY sup.organization_id,           --org id
	 sup.sr_instance_id,            --sr_instance_id
	 sup.supplier_id,
	 sup.supplier_site_id,
         i.base_item_id,
	 sup.inventory_item_id,         --inventory item id
	 sup.order_type,
	 i.item_name,                   --publisher item name
	 i.description,                 --publisher item desc
	 i.uom_code,                    --primary uom
	 i.planner_code,                --planner code
	 mpb.bucket_type,
 	 decode(sup.firm_date,null,nvl(sup.new_dock_date,msc_calendar.DATE_OFFSET(sup.organization_id, sup.sr_instance_id, 1, sup.new_schedule_date, - nvl(i.postprocessing_lead_time,0))),
                            msc_calendar.DATE_OFFSET(sup.organization_id,sup.sr_instance_id, 1,sup.firm_date, - nvl(i.postprocessing_lead_time,0))
             ), --key_date
   decode(sup.firm_date, null, sup.new_ship_date , null) --ship_date

UNION  --get modelled suppleirs

select sup.organization_id,           --org id
       sup.sr_instance_id,            --sr_instance_id
       t1.modeled_supplier_id,
       t1.modeled_supplier_site_id,
       i.base_item_id,
       sup.inventory_item_id,         --inventory item id
       sup.order_type,
       GREATEST ( SUM(decode(sup.firm_planned_type,
         		1,sup.firm_quantity,
         		sup.new_order_quantity)),
         	  SUM(nvl(sup.quantity_in_process,0)  +  nvl(sup.implemented_quantity,0))) quantity,     --quantity
       SUM(decode(sup.firm_planned_type, 1, sup.firm_quantity -
       		nvl(sup.quantity_in_process,0)  -  nvl(sup.implemented_quantity,0),
       		sup.new_order_quantity - nvl(sup.quantity_in_process,0) -
       		nvl(sup.implemented_quantity,0))) planned_order_quantity,
       SUM(nvl(sup.quantity_in_process,0)  +  nvl(sup.implemented_quantity,0)) released_quantity,
       i.item_name,                   --publisher item name
       i.description,                 --publisher item desc
       NULL, --sup.project_id,                --project number
       NULL, --sup.task_id,                   --task number
       NULL, --sup.planning_group,            --planning group
       i.uom_code,                    --primary uom
       i.planner_code,                --planner code
       mpb.bucket_type,
       decode(sup.firm_date,null,nvl(sup.new_dock_date,msc_calendar.DATE_OFFSET(sup.organization_id, sup.sr_instance_id, 1, sup.new_schedule_date, - nvl(i.postprocessing_lead_time,0))),
                            msc_calendar.DATE_OFFSET(sup.organization_id,sup.sr_instance_id, 1,sup.firm_date, - nvl(i.postprocessing_lead_time,0))
             ), --key_date
       decode(sup.firm_date, null, sup.new_ship_date , null), --ship_date
      decode(sup.firm_date,null,nvl(sup.new_dock_date,msc_calendar.DATE_OFFSET(sup.organization_id, sup.sr_instance_id, 1, sup.new_schedule_date, - nvl(i.postprocessing_lead_time,0))),
                            msc_calendar.DATE_OFFSET(sup.organization_id,sup.sr_instance_id, 1,sup.firm_date, - nvl(i.postprocessing_lead_time,0))
             ) --reciept_date
from   msc_plan_organizations_v ov,
       msc_system_items i,
       msc_supplies sup,
       msc_trading_partners t1,
       msc_plan_buckets   mpb
where  ov.plan_id = p_plan_id and
       ov.planned_organization = NVL(p_org_id, ov.planned_organization) and
       ov.sr_instance_id = NVL(p_sr_instance_id, ov.sr_instance_id) and
       i.plan_id = ov.plan_id and
       i.organization_id = ov.planned_organization and
       i.sr_instance_id = ov.sr_instance_id and
       NVL(i.base_item_id, i.inventory_item_id)
             IN  (select nvl(i1.base_item_id,i1.inventory_item_id)
             	  from msc_system_items i1
                  where i1.inventory_item_id = nvl(p_item_id, i.inventory_item_id )
                  and i1.organization_id = i.organization_id
                  and i1.plan_id = i.plan_id
                  and i1.sr_instance_id = i.sr_instance_id) and
       i.item_name = nvl(p_item_list,i.item_name) and
       NVL(i.planner_code,'-99') = NVL(p_planner_code, NVL(i.planner_code,'-99')) and
       NVL(i.abc_class_name,'-99') = NVL(p_abc_class,NVL(i.abc_class_name,'-99')) and
       -- bug#6893383 include planned_external_repair_order, external_repair_order
       -- used by SPP plan only when supp is modelled as org
       ((sup.order_type IN (PLANNED_ORDER,EXPECTED_INBOUND_SHIPMENT,
                            PLANNED_EXTERNAL_REPAIR_ORDER, l_external_repair_order) and
       /*order type EXPECTED_INBOUND_SHIPMENT is for DRP Plan Bug: 3951295*/
         --sup.source_supplier_id is null and
         -- ignore above two lines, no effect on commenting. Why-external_repair_order populate both supplier_id and source_org_id
         --sup.source_supplier_site_id is null and
         sup.source_organization_id is not null and
         sup.source_sr_instance_id is not null and
         sup.source_organization_id <> sup.organization_id and
         t1.sr_tp_id = sup.source_organization_id and
         t1.sr_instance_id = sup.source_sr_instance_id and
         t1.partner_type = 3
         )
        OR
        (sup.order_type in (p_purchase_order, p_requisition) and
         sup.source_supplier_id is null and
         sup.source_supplier_site_id is null and
         sup.source_organization_id is not null and -- bug#7446024
         sup.source_sr_instance_id is not null and
         t1.sr_tp_id = sup.source_organization_id and
         t1.sr_instance_id = sup.source_sr_instance_id and
         t1.partner_type = 3
        )
       ) and
       t1.modeled_supplier_id = nvl(p_supplier_id, t1.modeled_supplier_id) and
       t1.modeled_supplier_site_id = nvl(p_supplier_site_id, t1.modeled_supplier_site_id) and
       t1.modeled_supplier_id is not null and
       t1.modeled_supplier_site_id is not null and
       sup.plan_id = i.plan_id and
       sup.organization_id = i.organization_id and
       sup.sr_instance_id = i.sr_instance_id and
       sup.inventory_item_id = i.inventory_item_id and
       nvl(sup.planning_group, '-99') = nvl(p_planning_gp, nvl(sup.planning_group, '-99')) and
       nvl(sup.project_id,-99) = nvl(p_project_id, nvl(sup.project_id,-99)) and
       nvl(sup.task_id, -99) = nvl(p_task_id, nvl(sup.task_id, -99)) and
       decode(sup.firm_date,null,nvl(sup.new_dock_date, msc_calendar.DATE_OFFSET(sup.organization_id,sup.sr_instance_id, 1, sup.new_schedule_date, - nvl(i.postprocessing_lead_time,0))),
                            msc_calendar.DATE_OFFSET(sup.organization_id,sup.sr_instance_id, 1,sup.firm_date, - nvl(i.postprocessing_lead_time,0)))
	     between NVL(p_horizon_start, sysdate - 36500 )
	   		      and NVL(p_horizon_end, sysdate + 36500)
 	and mpb.plan_id = sup.plan_id
	and mpb.sr_instance_id = sup.sr_instance_id
	and mpb.curr_flag = 1
	and nvl(sup.firm_date,sup.new_schedule_date)
	                     between mpb.bkt_start_date and mpb.bkt_end_date
	 GROUP BY sup.organization_id,
	 sup.sr_instance_id,
	 t1.modeled_supplier_id,
	 t1.modeled_supplier_site_id,
         i.base_item_id,
	 sup.inventory_item_id,
	 sup.order_type,
	 i.item_name,
	 i.description,
	 i.uom_code,
         i.planner_code,                --planner code
	 mpb.bucket_type,
 	 decode(sup.firm_date,null,nvl(sup.new_dock_date,msc_calendar.DATE_OFFSET(sup.organization_id, sup.sr_instance_id, 1, sup.new_schedule_date, - nvl(i.postprocessing_lead_time,0))),
                            msc_calendar.DATE_OFFSET(sup.organization_id,sup.sr_instance_id, 1,sup.firm_date, - nvl(i.postprocessing_lead_time,0))
             ), --key_date
   decode(sup.firm_date, null, sup.new_ship_date , null) -- ship date
ORDER BY 1,2,3,4,5,6,7,11,12,16,18,19;

CURSOR defective_planned_orders_c1(
  p_plan_id                 in number,
  p_org_id                  in number,
  p_sr_instance_id          in number,
  p_horizon_start           in date,
  p_horizon_end             in date,
  p_category_set_id         in number,
  p_category_name           in varchar2,
  p_planner_code            in varchar2,
  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_item_list	    	        in varchar2,
  p_planning_gp             in varchar2,
  p_project_id              in number,
  p_task_id                 in number,
  p_supplier_id             in number,
  p_supplier_site_id        in number,
  p_purchase_order	        in number,
  p_requisition		          in number
) IS
select sup.source_organization_id,           --org id
       sup.source_sr_instance_id,            --sr_instance_id
       t1.modeled_supplier_id,
       t1.modeled_supplier_site_id,
       i.base_item_id,
       sup.inventory_item_id,         --inventory item id
       decode (sup.order_type,
			         EXPECTED_INBOUND_SHIPMENT, PLANNED_TRANSFER_DEF,
			         INTRANSIT_SHIPMENT, INTRANSIT_SHIPMENT_DEF,
			         INTRANSIT_RECEIPT , INTRANSIT_RECEIPT_DEF
			         ) order_type, --internal order_types local to this package
       GREATEST ( SUM(decode(sup.firm_planned_type,
         		1,sup.firm_quantity,
         		sup.new_order_quantity)),
         	  SUM(nvl(sup.quantity_in_process,0)  +  nvl(sup.implemented_quantity,0))) quantity,     --quantity
       SUM(decode(sup.firm_planned_type, 1, sup.firm_quantity -
       		nvl(sup.quantity_in_process,0)  -  nvl(sup.implemented_quantity,0),
       		sup.new_order_quantity - nvl(sup.quantity_in_process,0) -
       		nvl(sup.implemented_quantity,0))) planned_order_quantity,
       SUM(nvl(sup.quantity_in_process,0)  +  nvl(sup.implemented_quantity,0)) released_quantity,
       i.item_name,                   --publisher item name
       i.description,                 --publisher item desc
       NULL, --sup.project_id,                --project number
       NULL, --sup.task_id,                   --task number
       NULL, --sup.planning_group,            --planning group
       i.uom_code,                    --primary uom
       NULL,	--i.planner_code,                --planner code
       mpb.bucket_type,
       decode(sup.firm_date,null,nvl(sup.new_dock_date,msc_calendar.DATE_OFFSET(sup.source_organization_id, sup.source_sr_instance_id, 1, sup.new_schedule_date, - nvl(i.postprocessing_lead_time,0))),
                            msc_calendar.DATE_OFFSET(sup.source_organization_id,sup.source_sr_instance_id, 1,sup.firm_date, - nvl(i.postprocessing_lead_time,0))
             ), --key_date
       decode(sup.firm_date, null, sup.new_ship_date , null), --ship_date
      decode(sup.firm_date,null,nvl(sup.new_dock_date,msc_calendar.DATE_OFFSET(sup.source_organization_id, sup.source_sr_instance_id, 1, sup.new_schedule_date, - nvl(i.postprocessing_lead_time,0))),
                            msc_calendar.DATE_OFFSET(sup.source_organization_id,sup.source_sr_instance_id, 1,sup.firm_date, - nvl(i.postprocessing_lead_time,0))
             ),  --reciept_date
       -- order_number => order number for intransit shipment, NULL for Expected inbound shipment
       sup.order_number order_number, -- use only for intransit_shipment_def and intransit_receipt_def
       NULL line_number -- dummy type not to be used
from   msc_plan_organizations_v ov,
       msc_system_items i,
       msc_supplies sup,
       msc_trading_partners t1,
       msc_plan_buckets   mpb
where  ov.plan_id = p_plan_id and
       ov.planned_organization = NVL(p_org_id, ov.planned_organization) and
       ov.sr_instance_id = NVL(p_sr_instance_id, ov.sr_instance_id) and
       ov.plan_id = sup.plan_id and
       ov.planned_organization = sup.source_organization_id and
       ov.sr_instance_id = sup.source_sr_instance_id and
       /* Check for defective item type*/
       sup.item_type_value = 2 and -- for bad goods only
       NVL(i.base_item_id, i.inventory_item_id)
             IN  (select nvl(i1.base_item_id,i1.inventory_item_id)
             	  from msc_system_items i1
                  where i1.inventory_item_id = nvl(p_item_id, i.inventory_item_id )
                  and i1.organization_id = i.organization_id
                  and i1.plan_id = i.plan_id
                  and i1.sr_instance_id = i.sr_instance_id) and
       i.item_name = nvl(p_item_list,i.item_name) and
       NVL(i.planner_code,'-99') = NVL(p_planner_code, NVL(i.planner_code,'-99')) and
       NVL(i.abc_class_name,'-99') = NVL(p_abc_class,NVL(i.abc_class_name,'-99')) and
       (
         -- Planned Transfer : Planned Transfer created at supplier modelled org for defective warehouse
         sup.order_type in (EXPECTED_INBOUND_SHIPMENT, INTRANSIT_SHIPMENT, INTRANSIT_RECEIPT ) and
         sup.source_supplier_id is null and
         sup.source_supplier_site_id is null and
         sup.source_organization_id is not null and
         sup.source_sr_instance_id is not null and
         sup.source_organization_id <> sup.organization_id and
         t1.sr_tp_id = sup.organization_id and
         t1.sr_instance_id = sup.sr_instance_id and
         t1.partner_type = 3   and
         t1.modeled_supplier_id is not null and
         t1.modeled_supplier_site_id is not null
	     ) and
       t1.modeled_supplier_id = nvl(p_supplier_id, t1.modeled_supplier_id) and
       t1.modeled_supplier_site_id = nvl(p_supplier_site_id, t1.modeled_supplier_site_id) and
       t1.modeled_supplier_id is not null and
       t1.modeled_supplier_site_id is not null and
       sup.plan_id = i.plan_id and
       sup.source_organization_id = i.organization_id and
       sup.source_sr_instance_id = i.sr_instance_id and
       sup.inventory_item_id = i.inventory_item_id and
       nvl(sup.planning_group, '-99') = nvl(p_planning_gp, nvl(sup.planning_group, '-99')) and
       nvl(sup.project_id,-99) = nvl(p_project_id, nvl(sup.project_id,-99)) and
       nvl(sup.task_id, -99) = nvl(p_task_id, nvl(sup.task_id, -99)) and
       decode(sup.firm_date,null,nvl(sup.new_dock_date,     msc_calendar.DATE_OFFSET(sup.source_organization_id,sup.source_sr_instance_id, 1, sup.new_schedule_date, - nvl(i.postprocessing_lead_time,0))),
                            msc_calendar.DATE_OFFSET(sup.source_organization_id,sup.source_sr_instance_id, 1,sup.firm_date, - nvl(i.postprocessing_lead_time,0)))
        between NVL(p_horizon_start, sysdate - 36500 )
	   		and NVL(p_horizon_end, sysdate + 36500)
  and mpb.plan_id = sup.plan_id
	and mpb.sr_instance_id = sup.source_sr_instance_id
	and mpb.curr_flag = 1
	and nvl(sup.firm_date,sup.new_schedule_date)
	                     between mpb.bkt_start_date and mpb.bkt_end_date
	 GROUP BY sup.source_organization_id,           --org id
   sup.source_sr_instance_id,
	 t1.modeled_supplier_id,
	 t1.modeled_supplier_site_id,
   i.base_item_id,
	 sup.inventory_item_id,
	 decode (sup.order_type,EXPECTED_INBOUND_SHIPMENT, PLANNED_TRANSFER_DEF,
	                        INTRANSIT_SHIPMENT, INTRANSIT_SHIPMENT_DEF,
	                        INTRANSIT_RECEIPT , INTRANSIT_RECEIPT_DEF ),
	 i.item_name,
	 i.description,
	 i.uom_code,
   NULL,	--i.planner_code,                --planner code
	 mpb.bucket_type,
 	 decode(sup.firm_date,null,nvl(sup.new_dock_date,msc_calendar.DATE_OFFSET(sup.source_organization_id, sup.source_sr_instance_id, 1, sup.new_schedule_date, - nvl(i.postprocessing_lead_time,0))),
                            msc_calendar.DATE_OFFSET(sup.source_organization_id,sup.source_sr_instance_id, 1,sup.firm_date, - nvl(i.postprocessing_lead_time,0))
             ), --key_date
  decode(sup.firm_date, null, sup.new_ship_date , null), --ship_date
  sup.order_number
UNION
/* dmd_satisfied_date NOT NULL -> ISO that are unshipped will have dmd_satisfie_date ,
                          NULL -> Parially shipped or shipped and received ISO */
select dem.organization_id,           --org id
       dem.sr_instance_id,            --sr_instance_id
       t1.modeled_supplier_id,
       t1.modeled_supplier_site_id,
       i.base_item_id,
       dem.inventory_item_id,         --inventory item id
       decode (dem.origination_type,
			         SALES_ORDER ,ISO_DEF
			         ) order_type, --internal order_types local to this package
       SUM(NVL(dem.old_demand_quantity,0)) quantity,     --quantity
       0 planned_order_quantity,     -- planned_order_quantity
       0 released_quantity,          -- released_quantity
       i.item_name,                  --publisher item name
       i.description,                --publisher item desc
       NULL,                         --project number
       NULL,                         --task number
       NULL,                         --planning group
       i.uom_code,                   --primary uom
       NULL,	--i.planner_code,      --planner code
       mpb.bucket_type,              -- bucket_type
       dem.schedule_ship_date, --key_date
       dem.schedule_ship_date, --ship_date
       dem.schedule_arrival_date, --reciept_date
       -- Order_number => <order_number>.Order Only.ORDER ENTRY(<line_number>)
       decode(instr(dem.order_number,'.'), 0 , dem.order_number, substr(dem.order_number,1,instr(dem.order_number,'.')-1 )),--<order_number>
       TRIM(decode(instr(dem.order_number,'(',-1,1),0,null,substr(dem.order_number,instr(dem.order_number,'(',-1,1) + 1,instr(dem.order_number,')',-1,1) - instr(dem.order_number,'(',-1,1) -1 ))) --<line_number>
from   msc_plan_organizations_v ov,
       msc_system_items i,
       msc_demands dem,
       msc_trading_partners t1,
       msc_plan_buckets   mpb
where  ov.plan_id = p_plan_id and
       ov.planned_organization = NVL(p_org_id, ov.planned_organization) and
       ov.sr_instance_id = NVL(p_sr_instance_id, ov.sr_instance_id) and
       ov.plan_id = dem.plan_id and
       ov.planned_organization = dem.organization_id and
       ov.sr_instance_id = dem.sr_instance_id and
       ov.plan_id = i.plan_id  and
       ov.planned_organization = i.organization_id and
       ov.sr_instance_id = i.sr_instance_id  and
       /* Check for defective item type*/
       dem.item_type_value = 2 and -- for bad goods only
       NVL(i.base_item_id, i.inventory_item_id)
             IN  (select nvl(i1.base_item_id,i1.inventory_item_id)
             	  from msc_system_items i1
                  where i1.inventory_item_id = nvl(p_item_id, i.inventory_item_id )
                  and i1.organization_id = i.organization_id
                  and i1.plan_id = i.plan_id
                  and i1.sr_instance_id = i.sr_instance_id) and
       i.item_name = nvl(p_item_list,i.item_name) and
       NVL(i.planner_code,'-99') = NVL(p_planner_code, NVL(i.planner_code,'-99')) and
       NVL(i.abc_class_name,'-99') = NVL(p_abc_class,NVL(i.abc_class_name,'-99')) and
       (
         dem.origination_type in (SALES_ORDER) and
         dem.disposition_id is not null and -- verify if SO is internal (ISO)
         --dem.customer_id is null and
         --dem.customer_site_id is null and
         dem.source_organization_id is not null and -- supplier_modeled org
         dem.source_org_instance_id is not null and
         dem.source_organization_id <> dem.organization_id and
         t1.sr_tp_id = dem.source_organization_id and
         t1.sr_instance_id = dem.source_org_instance_id and
         t1.partner_type = 3   and
         t1.modeled_supplier_id is not null and
         t1.modeled_supplier_site_id is not null
	     ) and
       t1.modeled_supplier_id = nvl(p_supplier_id, t1.modeled_supplier_id) and
       t1.modeled_supplier_site_id = nvl(p_supplier_site_id, t1.modeled_supplier_site_id) and
       dem.plan_id = i.plan_id and
       dem.organization_id = i.organization_id and
       dem.sr_instance_id = i.sr_instance_id and
       dem.inventory_item_id = i.inventory_item_id and
       nvl(dem.planning_group, '-99') = nvl(p_planning_gp, nvl(dem.planning_group, '-99')) and
       nvl(dem.project_id,-99) = nvl(p_project_id, nvl(dem.project_id,-99)) and
       nvl(dem.task_id, -99) = nvl(p_task_id, nvl(dem.task_id, -99)) and
       dem.dmd_satisfied_date between nvl(p_horizon_start, dem.dmd_satisfied_date)
                                  and nvl(p_horizon_end, dem.dmd_satisfied_date)
      and exists ( select 'PICK_ONLY_UNSHIPPED_ISO'
                   from msc_sales_orders mso
                   where mso.demand_id = dem.demand_id
                   and mso.sr_instance_id = dem.sr_instance_id
                   and (mso.primary_uom_quantity - mso.completed_quantity) > 0 )
    and mpb.plan_id = dem.plan_id
	  and mpb.sr_instance_id = dem.sr_instance_id
	  and mpb.curr_flag = 1
	  and dem.dmd_satisfied_date  between mpb.bkt_start_date and mpb.bkt_end_date
	 GROUP BY dem.organization_id,
	 dem.sr_instance_id,
	 t1.modeled_supplier_id,
	 t1.modeled_supplier_site_id,
   i.base_item_id,
	 dem.inventory_item_id,
	 decode (dem.origination_type,SALES_ORDER , ISO_DEF),
	 i.item_name,
	 i.description,
	 i.uom_code,
   NULL,	--i.planner_code,                --planner code
	 mpb.bucket_type,
 	 dem.schedule_ship_date, --ship date or key date
   dem.schedule_arrival_date, --reciept_date
   decode(instr(dem.order_number,'.'), 0 , dem.order_number, substr(dem.order_number,1,instr(dem.order_number,'.')-1 )),--<order_number>
   TRIM(decode(instr(dem.order_number,'(',-1,1),0,null,substr(dem.order_number,instr(dem.order_number,'(',-1,1) + 1,instr(dem.order_number,')',-1,1) - instr(dem.order_number,'(',-1,1) -1 ))) --<line_number>
ORDER BY 1,2,3,4,5,6,7,11,12,16,18,19;



BEGIN

   if fnd_global.conc_request_id > 0 then
      select
	fnd_global.user_id,
	fnd_global.user_name --,
	--fnd_global.resp_name,
	--fnd_global.application_name
	into l_user_id,
        l_user_name --,
        --l_resp_name,
        --l_application_name
	from dual;
   end if;

  if l_user_id is null then
    l_language_code := 'US';
  else
    l_language := fnd_preference.get(UPPER(l_user_name),'WF','LANGUAGE');
    IF l_language IS NOT NULL THEN
      SELECT language_code
      INTO   l_language_code
      FROM   fnd_languages
      WHERE  nls_language = l_language;
    ELSE
      l_language_code := 'US';
    END IF;
  end if;


log_message('At 1');

-- bug#6893383

  select compile_designator,curr_plan_type
  into   p_designator,l_plan_type
  from   msc_plans
  where  plan_id = p_plan_id;

log_message('Designator/Plan Type : ' || p_designator || '/' || l_plan_type );

  if p_org_code is not null then
    p_inst_code := substr(p_org_code,1,instr(p_org_code,':')-1);
    log_message('p_inst_code := ' || p_inst_code);
    begin
    select instance_id
    into   p_sr_instance_id
    from   msc_apps_instances
    where  instance_code = p_inst_code;
    log_message('p_sr_instance_id := ' || p_sr_instance_id);

    select sr_tp_id
    into   p_org_id
    from   msc_trading_partners
    where  organization_code = p_org_code and
           sr_instance_id = p_sr_instance_id and
           partner_type = 3 and
           company_id is null;
    log_message('p_org_id := ' || p_org_id);
    exception
    	when others then
    		p_org_id := null;
    		p_sr_instance_id := null;
    end;
  else
    p_org_id := null;
    p_sr_instance_id := null;
  end if;

  if p_auto_version = 1 then
    l_version := nvl(p_version,0) + 1;
  else
    l_version := null;
  end if;

  l_log_message := get_message('MSC','MSC_X_PUB_OF',l_language_code) || ' ' || fnd_global.local_chr(10) ||
    get_message('MSC','MSC_X_PUB_PLAN',l_language_code) || ': ' || p_designator || fnd_global.local_chr(10);

  IF p_org_code IS NOT NULL THEN
     l_log_message := l_log_message || get_message('MSC','MSC_X_PUB_ORG',l_language_code) || ': ' || p_org_code || fnd_global.local_chr(10);
  END IF;

  IF p_item_id IS NOT NULL THEN
     SELECT item_name
       INTO l_item_name
       FROM msc_items
       WHERE inventory_item_id = p_item_id;
     l_log_message := l_log_message || get_message('MSC','MSC_X_PUB_ITEM',l_language_code) || ': ' || l_item_name || fnd_global.local_chr(10);
  END IF;

  IF p_supplier_id IS NOT NULL THEN
     SELECT partner_name
       INTO l_supp_name
       FROM msc_trading_partners
       WHERE partner_id = p_supplier_id;
     l_log_message := l_log_message || get_message('MSC','MSC_X_PUB_SUPPLIER',l_language_code) || ': ' || l_supp_name || fnd_global.local_chr(10);
  END IF;

  IF p_supplier_site_id IS NOT NULL THEN
     SELECT tp_site_code
       INTO l_supp_site
       FROM msc_trading_partner_sites
       WHERE partner_id = p_supplier_id
       AND partner_site_id = p_supplier_site_id;
     l_log_message := l_log_message || get_message('MSC','MSC_X_PUB_SUPP_SITE',l_language_code) || ': ' || l_supp_site || fnd_global.local_chr(10);
  END IF;

  IF p_planner_code IS NOT NULL THEN
     l_log_message := l_log_message || get_message('MSC','MSC_X_PUB_PLANNER',l_language_code) || ': ' || p_planner_code || fnd_global.local_chr(10);
  END IF;

  IF p_planning_gp IS NOT NULL THEN
     l_log_message := l_log_message || get_message('MSC','MSC_X_PUB_PLAN_GP',l_language_code) || ': ' || p_planning_gp || fnd_global.local_chr(10);
  END IF;

  IF p_project_id IS NOT NULL THEN
     l_log_message := l_log_message || get_message('MSC','MSC_X_PUB_PROJ_NUM',l_language_code) || ': ' || p_project_id || fnd_global.local_chr(10);
  END IF;

  IF p_task_id IS NOT NULL THEN
     l_log_message := l_log_message || get_message('MSC','MSC_X_PUB_TASK_NUM',l_language_code) || ': ' || p_task_id || fnd_global.local_chr(10);
  END IF;

  IF p_abc_class IS NOT NULL THEN
     l_log_message := l_log_message || get_message('MSC','MSC_X_PUB_ABC_CLASS',l_language_code) || ': ' || p_abc_class || fnd_global.local_chr(10);
  END IF;
  log_message(l_log_message);

  l_log_message := get_message('MSC','MSC_X_PUB_DELETE_OF',l_language_code) || fnd_global.local_chr(10);
  log_message(l_log_message);

  -- Option 1 -> YES , 2-> NO , bug#68938833
  log_message('Publish Defective Outbound Shipment : ' || p_publish_dos);

  IF p_purchase_order = 1 then
  	l_purchase_order := 1;
  	l_external_repair_order := EXTERNAL_REPAIR_ORDER ; --bug#6893383
  ELSE
  	l_purchase_order := null;
  	l_external_repair_order := null; --bug#6893383
  END IF;
  IF p_requisition = 1 then
  	l_requisition := 2;
  ELSE
  	l_requisition := null;
  END IF;

  --------------------------------------------------------------------------
  -- set the standard date as canonical date
  --------------------------------------------------------------------------
  l_horizon_start := fnd_date.canonical_to_date(p_horizon_start);
  l_horizon_end := fnd_date.canonical_to_date(p_horizon_end);

 ----------------------------------------------------------------------------
 -- get the input item list and parse it.
 ----------------------------------------------------------------------------
 l_list_of_item := p_item_list;


 WHILE l_list_of_item is not null
 LOOP

   IF (instr(l_list_of_item,',') <> 0 )  THEN
   		l_item_list :=
   		ltrim(rtrim(substr(l_list_of_item,1,instr(l_list_of_item,',')-1),' '),' ');

   		l_list_of_item := substr(l_list_of_item,instr(l_list_of_item,',')+1,length(l_list_of_item)) ;
   ELSIF (instr(l_list_of_item,',') = 0 ) THEN
    		l_item_list := ltrim(rtrim(substr(l_list_of_item,1,length (l_list_of_item)),' '),' ') ;
    		l_list_of_item := null;
   END IF;

	 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Item: ' || l_item_list);

   IF (l_item_list is not null) THEN
    	 begin
        	select inventory_item_id
        	into  l_item_id
        	from	msc_items
        	where	item_name = l_item_list;
     	exception
     	when no_data_found then
     		FND_FILE.PUT_LINE(FND_FILE.LOG,	'Item not found: ' || l_item_list);
     		l_item_id := null;
     	when others then
     		l_item_id := null;
     	end;
   END IF;
   IF (l_item_id is not null) THEN
    log_message('At 2');

   	delete_old_forecast(
   	  p_plan_id,
   	  p_org_id,
   	  p_sr_instance_id,
   	  p_planner_code,
   	  p_abc_class,
   	  l_item_id,
   	  p_planning_gp,
   	  p_project_id,
   	  p_task_id,
   	  p_supplier_id,
   	  p_supplier_site_id,
   	  l_horizon_start,
   	  l_horizon_end,
   	  p_overwrite
   	);

 	log_message('At 3');
   	OPEN planned_orders_c1 (
     	p_plan_id
     	,p_org_id
     	,p_sr_instance_id
     	,l_horizon_start
     	,l_horizon_end
     	,p_category_set_id
     	,p_category_name
     	,p_planner_code
     	,p_abc_class
     	,p_item_id
     	,l_item_list
     	,p_planning_gp
     	,p_project_id
     	,p_task_id
     	,p_supplier_id
     	,p_supplier_site_id
     	,l_purchase_order
     	,l_requisition
   	);

   	FETCH planned_orders_c1
   	BULK COLLECT INTO
     	t_org_id,
     	t_sr_instance_id,
     	t_source_supp_id,
     	t_source_supp_site_id,
     	t_base_item_id,
     	t_item_id,
     	t_order_type,
     	t_qty,
     	t_planned_order_qty,
     	t_released_qty,
     	t_owner_item_name,
     	t_owner_item_desc,
     	t_proj_number,
     	t_task_number,
     	t_planning_gp,
     	t_uom_code,
     	t_planner_code,
	    t_bucket_type,
     	t_key_date,
     	t_ship_date,
     	t_receipt_date;

   	CLOSE planned_orders_c1;

 	log_message('At 4');

   	IF t_org_id IS NOT NULL AND t_org_id.COUNT > 0 THEN
   		log_message ('Records fetched by cursor := ' || t_org_id.COUNT);
   		log_message('At 5');

     		------------------------------------------------------------------------
   		-- the following reintialize is required
   		-- if there are multiple items, the get_optional_info will accumulate the
   		-- output value from the previous item.  Therefore, individual item
   		-- should has a fresh output data
   		-----------------------------------------------------------------------
        	t_pub                        := companyNameList();
     		t_pub_id                     := numberList();
     		t_pub_site                   := companySiteList();
     		t_pub_site_id                := numberList();
          	t_supp                       := companyNameList();
          	t_supp_id                    := numberList();
          	t_supp_site                  := companySiteList();
     		t_supp_site_id               := numberList();
     		t_master_item_name           := itemNameList();
     		t_master_item_desc           := itemDescList();
     		t_supp_item_name             := itemNameList();
     		t_supp_item_desc             := itemDescList();
     		t_tp_uom                     := itemUomList();
     		t_tp_qty                     := numberList();
     		t_tp_planned_order_qty	     := numberList();
		t_tp_released_qty	     := numberList();

     		get_optional_info(
       		t_item_id
       		,t_org_id
       		,t_sr_instance_id
       		,t_source_supp_id
       		,t_source_supp_site_id
       		,t_uom_code
       		,t_qty
       		,t_planned_order_qty
       		,t_released_qty
       		,t_base_item_id
       		,t_base_item_name
       		,t_base_item_desc
       		,t_master_item_name
       		,t_master_item_desc
       		,t_supp_item_name
       		,t_supp_item_desc
       		,t_tp_uom
       		,t_tp_qty
       		,t_tp_planned_order_qty
       		,t_tp_released_qty
       		,t_ship_date
       		,t_receipt_date
       		,t_pub_id
       		,t_pub
       		,t_pub_site_id
      		,t_pub_site
       		,t_supp_id
       		,t_supp
       		,t_supp_site_id
       		,t_supp_site
     		);



   		log_message('At 6');

   		insert_into_sup_dem(
       		t_pub
       		,t_pub_id
       		,t_pub_site
       		,t_pub_site_id
       		,t_item_id
       		,t_order_type
       		,t_qty
       		,t_planned_order_qty
       		,t_released_qty
       		,t_supp
       		,t_supp_id
       		,t_supp_site
       		,t_supp_site_id
       		,t_owner_item_name
       		,t_owner_item_desc
       		,t_base_item_id
       		,t_base_item_name
       		,t_base_item_desc
       		,t_proj_number
       		,t_task_number
       		,t_planning_gp
       		,t_uom_code
       		,t_planner_code
		      ,t_bucket_type
       		,t_key_date
       		,t_ship_date
       		,t_receipt_date
       		,t_master_item_name
       		,t_master_item_desc
       		,t_supp_item_name
       		,t_supp_item_desc
       		,t_tp_uom
       		,t_tp_qty
       		,t_tp_planned_order_qty
       		,t_tp_released_qty
       		,l_version
       		,p_designator
       		,l_user_id
       		,l_language_code
       	 );
    	ELSE
      		l_log_message := 'Number of records published: ' || 0 || '.';
      		log_message(l_log_message);
      		l_cursor1 := 0;
  	END IF;


    END IF;
  /*--------------------------------------------------------------------------------
   Launch the notification here (where an item list is provided
   --------------------------------------------------------------------------------*/

   msc_x_wfnotify_pkg.Launch_Publish_WF (p_errbuf,
                       	p_retcode,
                       	p_designator,
                       	l_version,
                       	l_horizon_start,
                       	l_horizon_end,
                       	p_plan_id,
                       	p_sr_instance_id,
                       	p_org_id,
                     	l_item_id,
                  	p_supplier_id,
                        p_supplier_site_id,
                        null,		---p_customer_id,
                        null,		---p_customer_site_id,
  			p_planner_code,
  			p_abc_class,
  			p_planning_gp,
  			p_project_id,
  			p_task_id ,
                        ORDER_FORECAST);
END LOOP;
IF (p_item_list is null) THEN
	log_message('At 2');

  	delete_old_forecast(
  	  p_plan_id,
  	  p_org_id,
  	  p_sr_instance_id,
  	  p_planner_code,
  	  p_abc_class,
  	  p_item_id,
  	  p_planning_gp,
  	  p_project_id,
  	  p_task_id,
  	  p_supplier_id,
  	  p_supplier_site_id,
  	  l_horizon_start,
  	  l_horizon_end,
  	  p_overwrite
  	);

	log_message('At 3');
	log_message('p_plan_id : ' || p_plan_id);
	log_message('p_org_id : ' || p_org_id);
	log_message('p_sr_instance_id : ' || p_sr_instance_id);
	log_message('p_horizon_start : ' || p_horizon_start);
	log_message('p_horizon_end : ' || p_horizon_end);
	log_message('p_category_set_id : ' || p_category_set_id);
	log_message('p_category_name : ' || p_category_name);
	log_message('p_planner_code : ' || p_planner_code);
	log_message('p_abc_class : ' || p_abc_class);
	log_message('p_item_id : ' || p_item_id);
	log_message('l_item_list : ' || l_item_list);
	log_message('p_planning_gp : ' || p_planning_gp);
	log_message('p_project_id : ' || p_project_id);
	log_message('p_task_id : ' || p_task_id);
	log_message('p_supplier_id : ' || p_supplier_id);
	log_message('p_supplier_site_id : ' || p_supplier_site_id);
	log_message('l_purchase_order : ' || l_purchase_order);
	log_message('l_requisition : ' || l_requisition);
	-- External Repair Order is like converting PO from Planned Order in ASCP plan,
	-- Include only when user specify include purchase order - YES in conc program
	log_message('l_external_repair_order : ' || l_external_repair_order); --bug#6893383
	log_message('p_publish_dos : ' || p_publish_dos ); --bug#6893383

  	OPEN planned_orders_c1 (
    	p_plan_id
    	,p_org_id
    	,p_sr_instance_id
    	,l_horizon_start
    	,l_horizon_end
    	,p_category_set_id
    	,p_category_name
    	,p_planner_code
    	,p_abc_class
    	,p_item_id
    	,l_item_list
    	,p_planning_gp
    	,p_project_id
    	,p_task_id
    	,p_supplier_id
    	,p_supplier_site_id
    	,l_purchase_order
    	,l_requisition
  	);

  	FETCH planned_orders_c1
  	BULK COLLECT INTO
    	t_org_id,
    	t_sr_instance_id,
    	t_source_supp_id,
    	t_source_supp_site_id,
    	t_base_item_id,
    	t_item_id,
    	t_order_type,
    	t_qty,
    	t_planned_order_qty,
    	t_released_qty,
    	t_owner_item_name,
    	t_owner_item_desc,
    	t_proj_number,
    	t_task_number,
    	t_planning_gp,
    	t_uom_code,
    	t_planner_code,
	    t_bucket_type,
    	t_key_date,
    	t_ship_date,
    	t_receipt_date;

  	CLOSE planned_orders_c1;

	log_message('At 4');


  	IF t_org_id IS NOT NULL AND t_org_id.COUNT > 0 THEN
  		log_message ('Records fetched by cursor := ' || t_org_id.COUNT);
  	 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Records fetched by cursor := ' || t_org_id.COUNT);
  		log_message('At 5');

    		get_optional_info(
       		t_item_id
       		,t_org_id
       		,t_sr_instance_id
       		,t_source_supp_id
       		,t_source_supp_site_id
       		,t_uom_code
       		,t_qty
       		,t_planned_order_qty
       		,t_released_qty
       		,t_base_item_id
       		,t_base_item_name
       		,t_base_item_desc
       		,t_master_item_name
       		,t_master_item_desc
       		,t_supp_item_name
       		,t_supp_item_desc
       		,t_tp_uom
       		,t_tp_qty
       		,t_tp_planned_order_qty
       		,t_tp_released_qty
       		,t_ship_date
       		,t_receipt_date
       		,t_pub_id
       		,t_pub
       		,t_pub_site_id
      		,t_pub_site
       		,t_supp_id
       		,t_supp
       		,t_supp_site_id
       		,t_supp_site
     		);



  		log_message('At 6');
  		insert_into_sup_dem(
      		t_pub
      		,t_pub_id
      		,t_pub_site
      		,t_pub_site_id
      		,t_item_id
      		,t_order_type
      		,t_qty
      		,t_planned_order_qty
      		,t_released_qty
      		,t_supp
      		,t_supp_id
      		,t_supp_site
      		,t_supp_site_id
      		,t_owner_item_name
      		,t_owner_item_desc
      		,t_base_item_id
      		,t_base_item_name
      		,t_base_item_desc
      		,t_proj_number
      		,t_task_number
      		,t_planning_gp
      		,t_uom_code
      		,t_planner_code
		      ,t_bucket_type
      		,t_key_date
      		,t_ship_date
      		,t_receipt_date
      		,t_master_item_name
      		,t_master_item_desc
      		,t_supp_item_name
      		,t_supp_item_desc
      		,t_tp_uom
      		,t_tp_qty
      		,t_tp_planned_order_qty
      		,t_tp_released_qty
      		,l_version
      		,p_designator
      		,l_user_id
      		,l_language_code
      		);
   	ELSE
     		l_log_message := 'Number of records published: ' || 0 || '.';
     		log_message(l_log_message);
     		l_cursor1 := 0;
  	END IF;

   /*--------------------------------------------------------------------------------
   Launch the notification here
   --------------------------------------------------------------------------------*/

   msc_x_wfnotify_pkg.Launch_Publish_WF (p_errbuf,
                       	p_retcode,
                       	p_designator,
                       	l_version,
                       	l_horizon_start,
                       	l_horizon_end,
                       	p_plan_id,
                      	p_sr_instance_id,
                        p_org_id,
                     	p_item_id,
                  	p_supplier_id,
                        p_supplier_site_id,
                        null,		---p_customer_id,
                        null,		---p_customer_site_id,
  			p_planner_code,
  			p_abc_class,
  			p_planning_gp,
  			p_project_id,
  			p_task_id ,
                        ORDER_FORECAST);

-- SPP calculate Return Forecast, DOS and push it to msc_sup_dem_entries only when SPP plan is run
IF l_plan_type = SPP_PLAN THEN
  OPEN defective_planned_orders_c1 (
    	p_plan_id
    	,p_org_id
    	,p_sr_instance_id
    	,l_horizon_start
    	,l_horizon_end
    	,p_category_set_id
    	,p_category_name
    	,p_planner_code
    	,p_abc_class
    	,p_item_id
    	,l_item_list
    	,p_planning_gp
    	,p_project_id
    	,p_task_id
    	,p_supplier_id
    	,p_supplier_site_id
    	,l_purchase_order
    	,l_requisition
  	);

  	FETCH defective_planned_orders_c1
  	BULK COLLECT INTO
    	t_org_id,
    	t_sr_instance_id,
    	t_source_supp_id,
    	t_source_supp_site_id,
    	t_base_item_id,
    	t_item_id,
    	t_order_type,
    	t_qty,
    	t_planned_order_qty,
    	t_released_qty,
    	t_owner_item_name,
    	t_owner_item_desc,
    	t_proj_number,
    	t_task_number,
    	t_planning_gp,
    	t_uom_code,
    	t_planner_code,
	    t_bucket_type,
    	t_key_date,
    	t_ship_date,
    	t_receipt_date,
    	t_order_num, -- bug#7310179
    	t_line_num; -- bug#7310179

  CLOSE defective_planned_orders_c1;

  log_message('At 7');


  	IF t_org_id IS NOT NULL AND t_org_id.COUNT > 0 THEN
  		log_message ('Defective Planned Order fetched by cursor := ' || t_org_id.COUNT);
  	 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Defective Planned Order fetched by cursor := ' || t_org_id.COUNT);
  		log_message('At 8');

    		t_pub                        := companyNameList();
     		t_pub_id                     := numberList();
     		t_pub_site                   := companySiteList();
     		t_pub_site_id                := numberList();
        t_supp                       := companyNameList();
        t_supp_id                    := numberList();
        t_supp_site                  := companySiteList();
     		t_supp_site_id               := numberList();
     		t_master_item_name           := itemNameList();
     		t_master_item_desc           := itemDescList();
     		t_base_item_name             := itemNameList();
        t_base_item_desc             := itemDescList();
       	t_supp_item_name             := itemNameList();
     		t_supp_item_desc             := itemDescList();
     		t_tp_uom                     := itemUomList();
     		t_tp_qty                     := numberList();
     		t_tp_planned_order_qty	     := numberList();
		    t_tp_released_qty	           := numberList();

    		get_optional_info(
       		t_item_id
       		,t_org_id
       		,t_sr_instance_id
       		,t_source_supp_id
       		,t_source_supp_site_id
       		,t_uom_code
       		,t_qty
       		,t_planned_order_qty
       		,t_released_qty
       		,t_base_item_id
       		,t_base_item_name
       		,t_base_item_desc
       		,t_master_item_name
       		,t_master_item_desc
       		,t_supp_item_name
       		,t_supp_item_desc
       		,t_tp_uom
       		,t_tp_qty
       		,t_tp_planned_order_qty
       		,t_tp_released_qty
       		,t_ship_date
       		,t_receipt_date
       		,t_pub_id
       		,t_pub
       		,t_pub_site_id
      		,t_pub_site
       		,t_supp_id
       		,t_supp
       		,t_supp_site_id
       		,t_supp_site
     		);


  		log_message('At 9');
  		insert_into_sup_dem_rf_dos(
      		t_pub
      		,t_pub_id
      		,t_pub_site
      		,t_pub_site_id
      		,t_item_id
      		,t_order_type
      		,t_qty
      		,t_planned_order_qty
      		,t_released_qty
      		,t_supp
      		,t_supp_id
      		,t_supp_site
      		,t_supp_site_id
      		,t_owner_item_name
      		,t_owner_item_desc
      		,t_base_item_id
      		,t_base_item_name
      		,t_base_item_desc
      		,t_proj_number
      		,t_task_number
      		,t_planning_gp
      		,t_uom_code
      		,t_planner_code
		      ,t_bucket_type
      		,t_key_date
      		,t_ship_date
      		,t_receipt_date
      		,t_order_num -- bug#7310179
    	    ,t_line_num  -- bug#7310179
      		,t_master_item_name
      		,t_master_item_desc
      		,t_supp_item_name
      		,t_supp_item_desc
      		,t_tp_uom
      		,t_tp_qty
      		,t_tp_planned_order_qty
      		,t_tp_released_qty
      		,l_version
      		,p_designator
      		,l_user_id
      		,l_language_code
      		,p_publish_dos --bug#6893383
    		);

   	ELSE
     		l_log_message := 'Returns Forecast records published: ' || 0 || '.';
     		log_message(l_log_message);
     	--	l_cursor1 := 0;
  	END IF;

END IF; --IF l_plan_type = SPP_PLAN


END IF;


  commit;


  IF l_cursor1 = 0  THEN
     l_log_message := get_message('MSC','MSC_X_PUB_NUM_RECORDS',l_language_code) || ': ' || 0 || '.' || fnd_global.local_chr(10);
     log_message(l_log_message);
  END IF;

  IF l_version IS NOT NULL THEN
     BEGIN
	SELECT 1 INTO l_records_exist
	  FROM dual
	  WHERE exists ( SELECT 1
			 FROM msc_sup_dem_entries
			 WHERE plan_id = -1
			 AND publisher_order_type = 2
			 AND designator = p_designator
			 AND version = TO_CHAR(l_version));
     EXCEPTION
	WHEN OTHERS then
	  l_records_exist := 0;
     END;
     IF l_records_exist = 1 then
	l_log_message := get_message('MSC','MSC_X_PUB_NEW_VERSION',l_language_code) || ' ' || l_version || '.' || fnd_global.local_chr(10);
	log_message(l_log_message);

        --update version number in msc_plans

        UPDATE msc_plans
          SET publish_fcst_version = l_version
          WHERE plan_id = p_plan_id;

     END IF;
  END IF;


   /*--------------------------------------------------------------------------------
   	auto launch netting engine
   ----------------------------------------------------------------------------------*/
   IF ( ( FND_PROFILE.VALUE('MSC_X_AUTO_SCEM_MODE') = 2
           OR FND_PROFILE.VALUE('MSC_X_AUTO_SCEM_MODE') = 3
         ) -- PUBLISH or ALL
         AND ( FND_PROFILE.VALUE('MSC_X_CONFIGURATION') = 2
               OR FND_PROFILE.VALUE('MSC_X_CONFIGURATION') = 3
             ) -- APS+CP or CP only
       ) THEN
    BEGIN
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Launching SCEM engine');
      MSC_X_CP_FLOW.Start_SCEM_Engine_WF;
    EXCEPTION
      WHEN OTHERS THEN
        MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_CP_FLOW.Start_SCEM_Engine_WF');
        MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
    END;
  END IF;

EXCEPTION
 	when others then
 		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in publish plan order proc: ' ||sqlerrm);
END publish_plan_orders;


PROCEDURE get_optional_info(
  t_item_id             IN numberList,
  t_org_id              IN numberList,
  t_sr_instance_id      IN numberList,
  t_source_supp_id      IN numberList,
  t_source_supp_site_id IN numberList,
  t_uom_code            IN itemUomList,
  t_qty                 IN numberList,
  t_planned_order_qty   IN numberList,
  t_released_qty	      IN numberList,
  t_base_item_id	      IN numberList,
  t_base_item_name	    IN OUT NOCOPY itemNameList,
  t_base_item_desc	    IN OUT NOCOPY itemDescList,
  t_master_item_name 	  IN OUT NOCOPY itemNameList,
  t_master_item_desc 	  IN OUT NOCOPY itemDescList,
  t_supp_item_name   	  IN OUT NOCOPY itemNameList,
  t_supp_item_desc   	  IN OUT NOCOPY itemDescList,
  t_tp_uom           	  IN OUT NOCOPY itemUomList,
  t_tp_qty           	  IN OUT NOCOPY numberList,
  t_tp_planned_order_qty IN OUT NOCOPY numberList,
  t_tp_released_qty	     IN OUT NOCOPY numberList,
  t_ship_date        	  IN OUT NOCOPY dateList,
  t_receipt_date        IN dateList,
  t_pub_id           	  IN OUT NOCOPY numberList,
  t_pub              	  IN OUT NOCOPY companyNameList,
  t_pub_site_id      	  IN OUT NOCOPY numberList,
  t_pub_site         	  IN OUT NOCOPY companySiteList,
  t_supp_id          	  IN OUT NOCOPY numberList,
  t_supp             	  IN OUT NOCOPY companyNameList,
  t_supp_site_id     	  IN OUT NOCOPY numberList,
  t_supp_site        	  IN OUT NOCOPY companySiteList
) IS

  l_conversion_found boolean;
  l_conversion_rate  number;
  l_lead_time        number;
  l_using_org_id     number;

  CURSOR c_supplier_lead_time (
    p_item_id      in number,
    p_org_id       in number,
    p_inst_id      in number,
    p_supp_id      in number,
    p_supp_site_id in number
  ) IS
  select distinct mis.processing_lead_time,
         mis.using_organization_id
  from   msc_item_suppliers mis,
         msc_trading_partner_maps m,
         msc_trading_partner_maps m2,
         msc_company_relationships r
  where  mis.plan_id = -1 and
         mis.inventory_item_id = p_item_id and
         mis.organization_id = p_org_id and
         mis.sr_instance_id = p_inst_id and
         r.relationship_type = 2 and
         r.subject_id = 1 and
         r.object_id = p_supp_id and
         m.map_type = 1 and
         m.company_key = r.relationship_id and
         mis.supplier_id = m.tp_key and
         m2.map_type = 3 and
         m2.company_key = p_supp_site_id and
         nvl(mis.supplier_site_id, m2.tp_key) = m2.tp_key
  order by mis.using_organization_id desc;

BEGIN
  if t_item_id is not null and t_item_id.COUNT > 0 then
  log_message('In get_optional_info : ' || t_item_id.COUNT);
    for j in 1..t_item_id.COUNT loop
    --log_message('DEBUG : t_item_id('     || j ||')/t_org_id('        || j || ')/' ||
    --            't_sr_instance_id('      || j ||')/t_source_supp_id('|| j || ')/' ||
    --            't_source_supp_site_id(' || j ||')/t_qty('           || j || ')/' ||
    --            't_base_item_id('        || j ||')/t_order_type('    || j || ')  :  ' ||
    --            t_item_id(j) || '/' || t_org_id(j) || '/' || t_sr_instance_id(j) || '/' ||t_source_supp_id(j))|| '/' ||
    --            t_source_supp_site_id(j) || '/' || t_qty(j) || '/' || t_base_item_id(j) || '/' ||t_order_type(j));
      t_pub_id.EXTEND;
      t_pub.EXTEND;
      t_pub_site.EXTEND;
      t_pub_site_id.EXTEND;

      if (j = 1) or (t_org_id(j-1) <> t_org_id(j)) or (t_sr_instance_id(j-1) <> t_sr_instance_id(j)) then

        select c.company_id,
               c.company_name,
               s.company_site_id,
               s.company_site_name
        into   t_pub_id(j),
               t_pub(j),
               t_pub_site_id(j),
               t_pub_site(j)
        from   msc_companies c,
               msc_company_sites s,
               msc_trading_partner_maps m,
               msc_trading_partners t
        where  t.sr_tp_id = t_org_id(j) and
               t.sr_instance_id = t_sr_instance_id(j) and
               t.partner_type = 3 and
               m.tp_key = t.partner_id and
               m.map_type = 2 and
               s.company_site_id = m.company_key and
               c.company_id = s.company_id;

      else
        t_pub_id(j) := t_pub_id(j-1);
        t_pub(j) := t_pub(j-1);
        t_pub_site_id(j) := t_pub_site_id(j-1);
        t_pub_site(j) := t_pub_site(j-1);
      end if;

      --log_message('DEBUG : t_pub(' || j ||')/t_pub_site('||j|| ') : ' || t_pub(j) || '/' || t_pub_site(j));

      t_supp_id.EXTEND;
      t_supp.EXTEND;
      t_supp_site.EXTEND;
      t_supp_site_id.EXTEND;

      if (j = 1) or (t_source_supp_id(j-1) <> t_source_supp_id(j)) then
        BEGIN
          select distinct c.company_id,
                 c.company_name
          into   t_supp_id(j),
                 t_supp(j)
          from   msc_companies c,
                 msc_company_sites s,
                 msc_trading_partner_maps m,
                 msc_company_relationships r
          where  m.tp_key = t_source_supp_id(j) and
                 m.map_type = 1 and
                 r.relationship_id = m.company_key and
                 r.subject_id = t_pub_id(j) and
                 r.relationship_type = 2 and
                 c.company_id = r.object_id;
        EXCEPTION
          WHEN OTHERS THEN
            t_supp_id(j) := null;
            t_supp(j) := null;
            FND_FILE.PUT_LINE(FND_FILE.LOG, ' Error in 2nd query: ' || sqlerrm);
        END;
      else
        t_supp_id(j) := t_supp_id(j-1);
        t_supp(j) := t_supp(j-1);
      end if;

      if (j = 1) or (t_source_supp_site_id(j-1) <> t_source_supp_site_id(j)) then
        BEGIN
          select s.company_site_id,
                 s.company_site_name
          into   t_supp_site_id(j),
                 t_supp_site(j)
          from   msc_company_sites s,
                 msc_trading_partner_maps m
          where  m.tp_key = t_source_supp_site_id(j) and
                 m.map_type = 3 and
                 s.company_site_id = m.company_key and
                 s.company_id = t_supp_id(j);
        EXCEPTION
          WHEN OTHERS THEN
            t_supp_site_id(j) := null;
            t_supp_site(j) := null;
            FND_FILE.PUT_LINE(FND_FILE.LOG, ' Error in 3rd query: ' || sqlerrm);
        END;
      else
        t_supp_site_id(j) := t_supp_site_id(j-1);
        t_supp_site(j) := t_supp_site(j-1);
      end if;

      --log_message('DEBUG : t_supp_id(' || j ||')/t_supp('||j|| ') : ' || t_supp_id(j) || '/' || t_supp(j));

      t_master_item_name.EXTEND;
      t_master_item_desc.EXTEND;

      select item_name,
             description
      into   t_master_item_name(j),
             t_master_item_desc(j)
      from   msc_items
      where  inventory_item_id = t_item_id(j);

      t_supp_item_name.EXTEND;
      t_supp_item_desc.EXTEND;
      t_tp_uom.EXTEND;
      t_tp_qty.EXTEND;
      t_tp_planned_order_qty.EXTEND;
      t_tp_released_qty.EXTEND;

      begin
        select msi.item_name,
               msi.description,
               msi.uom_code
        into   t_supp_item_name(j),
               t_supp_item_desc(j),
               t_tp_uom(j)
        from   msc_system_items msi,
               msc_trading_partners part,
               msc_trading_partner_maps map
        where  msi.plan_id = -1 and
               msi.inventory_item_id = t_item_id(j) and
               msi.organization_id = part.sr_tp_id and
               msi.sr_instance_id = part.sr_instance_id and
               part.partner_id = map.tp_key and
               map.map_type = 2 and
               map.company_key = t_supp_site_id(j) and
               nvl(part.company_id,-1) = t_supp_id(j);
      exception
        when no_data_found then

          begin
            select distinct mis.supplier_item_name,
                   mis.description,
                   mis.uom_code
            into   t_supp_item_name(j),
                   t_supp_item_desc(j),
                   t_tp_uom(j)
            from   msc_item_suppliers mis,
                   msc_trading_partner_maps m,
                   msc_trading_partner_maps m2,
                   msc_company_relationships r
            where  mis.plan_id = -1 and
                   mis.inventory_item_id = t_item_id(j) and
                   mis.organization_id = t_org_id(j) and
                   mis.sr_instance_id = t_sr_instance_id(j) and
                   r.relationship_type = 2 and
                   r.subject_id = 1 and
                   r.object_id = t_supp_id(j) and
                   m.map_type = 1 and
                   m.company_key = r.relationship_id and
                   mis.supplier_id = m.tp_key and
                   m2.map_type = 3 and
                   m2.company_key = t_supp_site_id(j) and
                   nvl(mis.supplier_site_id, m2.tp_key) = m2.tp_key;

          exception
            when OTHERS then
              t_supp_item_name(j) := null;
              t_supp_item_desc(j) := null;
              t_tp_uom(j) := t_uom_code(j);
              FND_FILE.PUT_LINE(FND_FILE.LOG, ' Error in 4th query: ' || sqlerrm);
          end;
       end;

       IF (t_supp_item_desc(j) is null and t_supp_item_name(j) is not null ) THEN
       begin
            select description
            into   t_supp_item_desc(j)
            from   msc_system_items
            where  plan_id = -1 and
                   inventory_item_id = t_item_id(j) and
                   organization_id = t_org_id(j) and
                   sr_instance_id = t_sr_instance_id(j);
       exception
            when OTHERS then
              t_supp_item_desc(j) := null;
       end;
       END IF;

       /*--------------------------------------------------------------------
         get the base item name
         -------------------------------------------------------------------*/

      	t_base_item_name.EXTEND;
      	t_base_item_desc.EXTEND;
        BEGIN
         	select item_name, description
         	into 	t_base_item_name(j),
         		t_base_item_desc(j)
         	from	msc_items
         	where	inventory_item_id = t_base_item_id(j);
        EXCEPTION
         	WHEN OTHERS THEN
         		t_base_item_name(j) := null;
         		t_base_item_desc(j) :=  null;
        END;


       msc_x_util.get_uom_conversion_rates( t_uom_code(j),
                                            t_tp_uom(j),
                                            t_item_id(j),
                                            l_conversion_found,
                                            l_conversion_rate);
       if l_conversion_found then
         t_tp_qty(j)               := nvl(t_qty(j),0)* l_conversion_rate;
         t_tp_planned_order_qty(j) := nvl(t_planned_order_qty(j),0) * l_conversion_rate;
         t_tp_released_qty(j)      := nvl(t_released_qty(j),0) * l_conversion_rate;
       else
         t_tp_qty(j) := t_qty(j);
         t_tp_planned_order_qty(j) := t_planned_order_qty(j);
         t_tp_released_qty(j) := t_released_qty(j);
       end if;


       --Ship date = receipt date - ppt
       /*debug*/
      if (t_ship_date(j) is NULL) then
       open c_supplier_lead_time(
         t_item_id(j),
         t_org_id(j),
         t_sr_instance_id(j),
         t_supp_id(j),
         t_supp_site_id(j)
       );
       fetch c_supplier_lead_time into l_lead_time, l_using_org_id;
       close c_supplier_lead_time;


       t_ship_date(j) := t_receipt_date(j) - nvl(l_lead_time, 0);
      end if;

    end loop;
  end if;

EXCEPTION
	WHEN others then
	  FND_FILE.PUT_LINE(FND_FILE.LOG, ' Error in get option info proc: ' || sqlerrm);
END get_optional_info;


PROCEDURE insert_into_sup_dem (
  t_pub                       IN companyNameList,
  t_pub_id                    IN numberList,
  t_pub_site                  IN companySiteList,
  t_pub_site_id               IN numberList,
  t_item_id                   IN numberList,
  t_order_type	      	      IN numberList,
  t_qty                       IN numberList,
  t_planned_order_qty	        IN numberList,
  t_released_qty	            IN numberList,
  t_supp                      IN companyNameList,
  t_supp_id                   IN numberList,
  t_supp_site                 IN companySiteList,
  t_supp_site_id              IN numberList,
  t_owner_item_name           IN itemNameList,
  t_owner_item_desc           IN itemDescList,
  t_base_item_id	            IN numberList,
  t_base_item_name	          IN itemNameList,
  t_base_item_desc	          IN itemDescList,
  t_proj_number               IN numberList,
  t_task_number               IN numberList,
  t_planning_gp               IN planningGroupList,
  t_uom_code                  IN itemUomList,
  t_planner_code              IN plannerCodeList,
  t_bucket_type               IN numberList,
  t_key_date                  IN dateList,
  t_ship_date                 IN dateList,
  t_receipt_date              IN dateList,
  t_master_item_name          IN itemNameList,
  t_master_item_desc          IN itemDescList,
  t_supp_item_name            IN itemNameList,
  t_supp_item_desc            IN itemDescList,
  t_tp_uom                    IN itemUomList,
  t_tp_qty                    IN numberList,
  t_tp_planned_order_qty      IN numberList,
  t_tp_released_qty	          IN numberList,
  p_version                   IN varchar2,
  p_designator                IN varchar2,
  p_user_id                   IN number,
  p_language_code             IN varchar2
  ) IS


l_order_type_desc         varchar2(80);
l_log_message             VARCHAR2(1000);

l_bucket_type_desc        varchar2(80);
l_publish_item_id		      number;
l_prev_publish_item_id		number;
l_count				            number := 0;
l_planned_order_qty		    Number;
l_tp_planned_order_qty		Number;
l_released_qty			Number;
l_tp_released_qty		Number;
l_item_id	      		Number;
l_base_item_name		msc_sup_dem_entries.item_name%type;
l_base_item_desc		msc_sup_dem_entries.item_description%type;

BEGIN


log_message('In insert_into_sup_dem');
  if t_pub_id is not null and t_pub_id.COUNT > 0 then
  log_message('Records fetched := ' || t_pub_id.COUNT);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Records fetched := ' || t_pub_id.COUNT);
    if t_pub_id is not null and t_pub_id.COUNT > 0 THEN
       l_log_message := get_message('MSC','MSC_X_PUB_NUM_RECORDS',p_language_code) || ': ' || t_pub_id.COUNT || '.' || fnd_global.local_chr(10);
       log_message(l_log_message);
       log_message('Records to be inserted : ' || t_pub_id.COUNT);

     ------------------------------------------------------------------------------------------
     -- If the item has base model, will use the base model for the order forecast order type
     -- use the regular item for other order types
     ------------------------------------------------------------------------------------------
     FOR j in 1..t_pub_id.COUNT LOOP

      if (j > 1 and t_pub_id(j) = t_pub_id(j-1) and
           t_pub_site_id(j) = t_pub_site_id(j-1) and
           t_item_id(j) = t_item_id(j-1) and
           t_supp_id(j) = t_supp_id(j-1) and
           t_supp_site_id(j) = t_supp_site_id(j-1) and
           trunc(t_key_date(j)) = trunc(t_key_date(j-1)) and
           trunc(t_ship_date(j)) = trunc(t_ship_date(j-1)) and
           t_order_type(j) = t_order_type(j-1)) THEN

       IF (t_order_type(j) = PLANNED_EXTERNAL_REPAIR_ORDER) THEN
           l_order_type_desc:=MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',ORDER_FORECAST);
           l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));
 	          begin
 	          	IF (t_base_item_id(j) is not null) THEN
 	          		 update msc_sup_dem_entries
 	          		 set quantity = quantity + t_qty(j),
 	          		     primary_quantity = primary_quantity + t_qty(j),
 	          		     tp_quantity = tp_quantity + t_tp_qty(j)
           	     where publisher_id = t_pub_id(j)
           	     and   publisher_site_id = t_pub_site_id(j)
           	     and   supplier_id = t_supp_id(j)
           	     and   supplier_site_id = t_supp_site_id(j)
           	     and   inventory_item_id = t_base_item_id(j)
           	     and   trunc(key_date) = trunc(t_key_date(j))
           	     and   publisher_order_type = ORDER_FORECAST;
           	     IF (SQL%ROWCOUNT = 0) THEN
           	     insert into msc_sup_dem_entries (
			            transaction_id,
			            plan_id,
			            sr_instance_id,
			            publisher_name,
			            publisher_id,
			            publisher_site_name,
			            publisher_site_id,
			            customer_name,
			            customer_id,
			            customer_site_name,
			            customer_site_id,
			            supplier_name,
			            supplier_id,
			            supplier_site_name,
			            supplier_site_id,
			            ship_from_party_name,
			            ship_from_party_id,
			            ship_from_party_site_name,
			            ship_from_party_site_id,
			            ship_to_party_name,
			            ship_to_party_id,
			            ship_to_party_site_name,
			            ship_to_party_site_id,
			            publisher_order_type,
			            publisher_order_type_desc,
			            bucket_type_desc,
			            bucket_type,
			            inventory_item_id,
			            item_name,
			            owner_item_name,
			            customer_item_name,
			            supplier_item_name,
			            item_description,
			            owner_item_description,
			            customer_item_description,
			            supplier_item_description,
			            primary_uom,
			            uom_code,
			            tp_uom_code,
			            key_date,
			            ship_date,
			            receipt_date,
			            quantity,
			            primary_quantity,
			            tp_quantity,
			            last_refresh_number,
			            posting_party_name,
			            posting_party_id,
			            created_by,
			            creation_date,
			            last_updated_by,
			            last_update_date,
			            project_number,
			            task_number,
			            planning_group,
			            planner_code,
			            version,
			            designator
			            ) values (
			            msc_sup_dem_entries_s.nextval,
			            -1,
			            -1,
			            t_pub(j),
			            t_pub_id(j),
			            t_pub_site(j),
			            t_pub_site_id(j),
			            t_pub(j),
			            t_pub_id(j),
			            t_pub_site(j),
			            t_pub_site_id(j),
			            t_supp(j),
			            t_supp_id(j),
			            t_supp_site(j),
			            t_supp_site_id(j),
			            t_supp(j),
			            t_supp_id(j),
			            t_supp_site(j),
			            t_supp_site_id(j),
			            t_pub(j),
			            t_pub_id(j),
			            t_pub_site(j),
			            t_pub_site_id(j),
			            ORDER_FORECAST,
			            l_order_type_desc,
			 	          l_bucket_type_desc,
			            t_bucket_type(j),
			            t_base_item_id(j),
			            t_base_item_name(j),
			            t_base_item_name(j),
			            t_base_item_name(j),
			            t_supp_item_name(j),
			            nvl(t_base_item_desc(j), t_owner_item_desc(j)),
			            t_base_item_desc(j),
			            t_base_item_desc(j),
			            t_supp_item_desc(j),
			            t_uom_code(j),
			            t_uom_code(j),
			            t_tp_uom(j),
			            t_key_date(j),
			            t_ship_date(j),
			            t_receipt_date(j),
			            t_qty(j),
			            t_qty(j),
			            t_tp_qty(j),
			            msc_cl_refresh_s.nextval,
			            t_pub(j),
			            t_pub_id(j),
			            nvl(p_user_id,-1),
			            sysdate,
			            nvl(p_user_id,-1),
			            sysdate,
			            t_proj_number(j),
			            t_task_number(j),
			            t_planning_gp(j),
			            t_planner_code(j),
			            p_version,
         			    p_designator);
         		   END IF;   --rowcount
           	 ELSE
           	    	update msc_sup_dem_entries
           	    	set quantity = quantity + t_qty(j),
           	    	    primary_quantity = primary_quantity + t_qty(j),
           	    	    tp_quantity = tp_quantity + t_tp_qty(j)
           	    	where publisher_id = t_pub_id(j)
           	    	and 	publisher_site_id = t_pub_site_id(j)
           	    	and  	supplier_id = t_supp_id(j)
           	    	and  	supplier_site_id = t_supp_site_id(j)
           	    	and  	inventory_item_id = t_item_id(j)
           	    	and  	trunc(key_date) = trunc(t_key_date(j))
           	    	and  	publisher_order_type = ORDER_FORECAST;
     	      END IF;

            exception
           	  when others then
           	  	 null;
           end;
        ELSIF (t_order_type(j) = EXTERNAL_REPAIR_ORDER) THEN
           l_order_type_desc:=MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',ORDER_FORECAST);
           l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));
 	          begin
 	          	IF (t_base_item_id(j) is not null) THEN
 	          		 update msc_sup_dem_entries
 	          		 set quantity = quantity + t_qty(j),
 	          		     primary_quantity = primary_quantity + t_qty(j),
 	          		     tp_quantity = tp_quantity + t_tp_qty(j)
           	     where publisher_id = t_pub_id(j)
           	     and   publisher_site_id = t_pub_site_id(j)
           	     and   supplier_id = t_supp_id(j)
           	     and   supplier_site_id = t_supp_site_id(j)
           	     and   inventory_item_id = t_base_item_id(j)
           	     and   trunc(key_date) = trunc(t_key_date(j))
           	     and   publisher_order_type = ORDER_FORECAST;
           	     IF (SQL%ROWCOUNT = 0) THEN
           	     insert into msc_sup_dem_entries (
			            transaction_id,
			            plan_id,
			            sr_instance_id,
			            publisher_name,
			            publisher_id,
			            publisher_site_name,
			            publisher_site_id,
			            customer_name,
			            customer_id,
			            customer_site_name,
			            customer_site_id,
			            supplier_name,
			            supplier_id,
			            supplier_site_name,
			            supplier_site_id,
			            ship_from_party_name,
			            ship_from_party_id,
			            ship_from_party_site_name,
			            ship_from_party_site_id,
			            ship_to_party_name,
			            ship_to_party_id,
			            ship_to_party_site_name,
			            ship_to_party_site_id,
			            publisher_order_type,
			            publisher_order_type_desc,
			            bucket_type_desc,
			            bucket_type,
			            inventory_item_id,
			            item_name,
			            owner_item_name,
			            customer_item_name,
			            supplier_item_name,
			            item_description,
			            owner_item_description,
			            customer_item_description,
			            supplier_item_description,
			            primary_uom,
			            uom_code,
			            tp_uom_code,
			            key_date,
			            ship_date,
			            receipt_date,
			            quantity,
			            primary_quantity,
			            tp_quantity,
			            last_refresh_number,
			            posting_party_name,
			            posting_party_id,
			            created_by,
			            creation_date,
			            last_updated_by,
			            last_update_date,
			            project_number,
			            task_number,
			            planning_group,
			            planner_code,
			            version,
			            designator
			            ) values (
			            msc_sup_dem_entries_s.nextval,
			            -1,
			            -1,
			            t_pub(j),
			            t_pub_id(j),
			            t_pub_site(j),
			            t_pub_site_id(j),
			            t_pub(j),
			            t_pub_id(j),
			            t_pub_site(j),
			            t_pub_site_id(j),
			            t_supp(j),
			            t_supp_id(j),
			            t_supp_site(j),
			            t_supp_site_id(j),
			            t_supp(j),
			            t_supp_id(j),
			            t_supp_site(j),
			            t_supp_site_id(j),
			            t_pub(j),
			            t_pub_id(j),
			            t_pub_site(j),
			            t_pub_site_id(j),
			            ORDER_FORECAST,
			            l_order_type_desc,
			 	          l_bucket_type_desc,
			            t_bucket_type(j),
			            t_base_item_id(j),
			            t_base_item_name(j),
			            t_base_item_name(j),
			            t_base_item_name(j),
			            t_supp_item_name(j),
			            nvl(t_base_item_desc(j), t_owner_item_desc(j)),
			            t_base_item_desc(j),
			            t_base_item_desc(j),
			            t_supp_item_desc(j),
			            t_uom_code(j),
			            t_uom_code(j),
			            t_tp_uom(j),
			            t_key_date(j),
			            t_ship_date(j),
			            t_receipt_date(j),
			            t_qty(j),
			            t_qty(j),
			            t_tp_qty(j),
			            msc_cl_refresh_s.nextval,
			            t_pub(j),
			            t_pub_id(j),
			            nvl(p_user_id,-1),
			            sysdate,
			            nvl(p_user_id,-1),
			            sysdate,
			            t_proj_number(j),
			            t_task_number(j),
			            t_planning_gp(j),
			            t_planner_code(j),
			            p_version,
         			    p_designator);
         		   END IF;   --rowcount
           	 ELSE
           	    	update msc_sup_dem_entries
           	    	set quantity = quantity + t_qty(j),
           	    	    primary_quantity = primary_quantity + t_qty(j),
           	    	    tp_quantity = tp_quantity + t_tp_qty(j)
           	    	where publisher_id = t_pub_id(j)
           	    	and 	publisher_site_id = t_pub_site_id(j)
           	    	and  	supplier_id = t_supp_id(j)
           	    	and  	supplier_site_id = t_supp_site_id(j)
           	    	and  	inventory_item_id = t_item_id(j)
           	    	and  	trunc(key_date) = trunc(t_key_date(j))
           	    	and  	publisher_order_type = ORDER_FORECAST;
     	      END IF;

            exception
           	  when others then
           	  	 null;
           end;
        ELSIF (t_order_type(j) = PLANNED_NEW_BUY_ORDER) THEN
           l_order_type_desc:=MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',ORDER_FORECAST);
           l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));
 	          begin
 	          	IF (t_base_item_id(j) is not null) THEN
 	          		 update msc_sup_dem_entries
 	          		 set quantity = quantity + t_qty(j),
 	          		     primary_quantity = primary_quantity + t_qty(j),
 	          		     tp_quantity = tp_quantity + t_tp_qty(j)
           	     where publisher_id = t_pub_id(j)
           	     and   publisher_site_id = t_pub_site_id(j)
           	     and   supplier_id = t_supp_id(j)
           	     and   supplier_site_id = t_supp_site_id(j)
           	     and   inventory_item_id = t_base_item_id(j)
           	     and   trunc(key_date) = trunc(t_key_date(j))
           	     and   publisher_order_type = ORDER_FORECAST;
           	     IF (SQL%ROWCOUNT = 0) THEN
           	     insert into msc_sup_dem_entries (
			            transaction_id,
			            plan_id,
			            sr_instance_id,
			            publisher_name,
			            publisher_id,
			            publisher_site_name,
			            publisher_site_id,
			            customer_name,
			            customer_id,
			            customer_site_name,
			            customer_site_id,
			            supplier_name,
			            supplier_id,
			            supplier_site_name,
			            supplier_site_id,
			            ship_from_party_name,
			            ship_from_party_id,
			            ship_from_party_site_name,
			            ship_from_party_site_id,
			            ship_to_party_name,
			            ship_to_party_id,
			            ship_to_party_site_name,
			            ship_to_party_site_id,
			            publisher_order_type,
			            publisher_order_type_desc,
			            bucket_type_desc,
			            bucket_type,
			            inventory_item_id,
			            item_name,
			            owner_item_name,
			            customer_item_name,
			            supplier_item_name,
			            item_description,
			            owner_item_description,
			            customer_item_description,
			            supplier_item_description,
			            primary_uom,
			            uom_code,
			            tp_uom_code,
			            key_date,
			            ship_date,
			            receipt_date,
			            quantity,
			            primary_quantity,
			            tp_quantity,
			            last_refresh_number,
			            posting_party_name,
			            posting_party_id,
			            created_by,
			            creation_date,
			            last_updated_by,
			            last_update_date,
			            project_number,
			            task_number,
			            planning_group,
			            planner_code,
			            version,
			            designator
			            ) values (
			            msc_sup_dem_entries_s.nextval,
			            -1,
			            -1,
			            t_pub(j),
			            t_pub_id(j),
			            t_pub_site(j),
			            t_pub_site_id(j),
			            t_pub(j),
			            t_pub_id(j),
			            t_pub_site(j),
			            t_pub_site_id(j),
			            t_supp(j),
			            t_supp_id(j),
			            t_supp_site(j),
			            t_supp_site_id(j),
			            t_supp(j),
			            t_supp_id(j),
			            t_supp_site(j),
			            t_supp_site_id(j),
			            t_pub(j),
			            t_pub_id(j),
			            t_pub_site(j),
			            t_pub_site_id(j),
			            ORDER_FORECAST,
			            l_order_type_desc,
			 	          l_bucket_type_desc,
			            t_bucket_type(j),
			            t_base_item_id(j),
			            t_base_item_name(j),
			            t_base_item_name(j),
			            t_base_item_name(j),
			            t_supp_item_name(j),
			            nvl(t_base_item_desc(j), t_owner_item_desc(j)),
			            t_base_item_desc(j),
			            t_base_item_desc(j),
			            t_supp_item_desc(j),
			            t_uom_code(j),
			            t_uom_code(j),
			            t_tp_uom(j),
			            t_key_date(j),
			            t_ship_date(j),
			            t_receipt_date(j),
			            t_qty(j),
			            t_qty(j),
			            t_tp_qty(j),
			            msc_cl_refresh_s.nextval,
			            t_pub(j),
			            t_pub_id(j),
			            nvl(p_user_id,-1),
			            sysdate,
			            nvl(p_user_id,-1),
			            sysdate,
			            t_proj_number(j),
			            t_task_number(j),
			            t_planning_gp(j),
			            t_planner_code(j),
			            p_version,
         			    p_designator);
         		   END IF;   --rowcount
           	 ELSE
           	    	update msc_sup_dem_entries
           	    	set quantity = quantity + t_qty(j),
           	    	    primary_quantity = primary_quantity + t_qty(j),
           	    	    tp_quantity = tp_quantity + t_tp_qty(j)
           	    	where publisher_id = t_pub_id(j)
           	    	and 	publisher_site_id = t_pub_site_id(j)
           	    	and  	supplier_id = t_supp_id(j)
           	    	and  	supplier_site_id = t_supp_site_id(j)
           	    	and  	inventory_item_id = t_item_id(j)
           	    	and  	trunc(key_date) = trunc(t_key_date(j))
           	    	and  	publisher_order_type = ORDER_FORECAST;
     	      END IF;

            exception
           	  when others then
           	  	 null;
           end;
        ELSIF (t_order_type(j) = PLANNED_ORDER) THEN
 	          begin
 	            IF (t_base_item_id(j) is not null) THEN


                     		update msc_sup_dem_entries
                     		set quantity = quantity + t_qty(j),
                         		primary_quantity = primary_quantity + t_qty(j),
                         		tp_quantity = tp_quantity + t_tp_qty(j)
                     		where publisher_id = t_pub_id(j)
                     		and publisher_site_id = t_pub_site_id(j)
                     		and supplier_id = t_supp_id(j)
                     		and supplier_site_id = t_supp_site_id(j)
                     		and inventory_item_id = t_base_item_id(j)
                     		and trunc(key_date) = trunc(t_key_date(j))
                     		and publisher_order_type = ORDER_FORECAST;

                     		IF (SQL%ROWCOUNT = 0) THEN
	          		         insert into msc_sup_dem_entries (
	          		            transaction_id,
	          		            plan_id,
	          		            sr_instance_id,
	          		            publisher_name,
	          		            publisher_id,
	          		            publisher_site_name,
	          		            publisher_site_id,
	          		            customer_name,
	          		            customer_id,
	          		            customer_site_name,
	          		            customer_site_id,
	          		            supplier_name,
	          		            supplier_id,
	          		            supplier_site_name,
	          		            supplier_site_id,
	          		            ship_from_party_name,
	          		            ship_from_party_id,
	          		            ship_from_party_site_name,
	          		            ship_from_party_site_id,
	          		            ship_to_party_name,
	          		            ship_to_party_id,
	          		            ship_to_party_site_name,
	          		            ship_to_party_site_id,
	          		            publisher_order_type,
	          		            publisher_order_type_desc,
	          		            bucket_type_desc,
	          		            bucket_type,
	          		            inventory_item_id,
	          		            item_name,
	          		            owner_item_name,
	          		            customer_item_name,
	          		            supplier_item_name,
	          		            item_description,
	          		            owner_item_description,
	          		            customer_item_description,
	          		            supplier_item_description,
	          		            primary_uom,
	          		            uom_code,
	          		            tp_uom_code,
	          		            key_date,
	          		            ship_date,
	          		            receipt_date,
	          		            quantity,
	          		            primary_quantity,
	          		            tp_quantity,
	          		            last_refresh_number,
	          		            posting_party_name,
	          		            posting_party_id,
	          		            created_by,
	          		            creation_date,
	          		            last_updated_by,
	          		            last_update_date,
	          		            project_number,
	          		            task_number,
	          		            planning_group,
	          		            planner_code,
	          		            version,
	          		            designator
	          		         ) values (
	          		         msc_sup_dem_entries_s.nextval,
	          		         -1,
	          		         -1,
	          		         t_pub(j),
	          		         t_pub_id(j),
	          		         t_pub_site(j),
	          		         t_pub_site_id(j),
	          		         t_pub(j),
	          		         t_pub_id(j),
	          		         t_pub_site(j),
	          		         t_pub_site_id(j),
	          		         t_supp(j),
	          		         t_supp_id(j),
	          		         t_supp_site(j),
	          		         t_supp_site_id(j),
	          		         t_supp(j),
	          		         t_supp_id(j),
	          		         t_supp_site(j),
	          		         t_supp_site_id(j),
	          		         t_pub(j),
	          		         t_pub_id(j),
	          		         t_pub_site(j),
	          		         t_pub_site_id(j),
	          		         ORDER_FORECAST,
	          		         l_order_type_desc,
	          		 	       l_bucket_type_desc,
	          		         t_bucket_type(j),
	          		         t_base_item_id(j),
	          		         t_base_item_name(j),
	          		         t_base_item_name(j),
	          		         t_base_item_name(j),
	          		         t_supp_item_name(j),
	          		         nvl(t_base_item_desc(j), t_owner_item_desc(j)),
	          		         t_base_item_desc(j),
	          		         t_base_item_desc(j),
	          		         t_supp_item_desc(j),
	          		         t_uom_code(j),
	          		         t_uom_code(j),
	          		         t_tp_uom(j),
	          		         t_key_date(j),
	          		         t_ship_date(j),
	          		         t_receipt_date(j),
	          		         t_qty(j),
	          		         t_qty(j),
	          		         t_tp_qty(j),
	          		         msc_cl_refresh_s.nextval,
	          		         t_pub(j),
	          		         t_pub_id(j),
	          		         nvl(p_user_id,-1),
	          		         sysdate,
	          		         nvl(p_user_id,-1),
	          		         sysdate,
	          		         t_proj_number(j),
	          		         t_task_number(j),
	          		         t_planning_gp(j),
	          		         t_planner_code(j),
	          		         p_version,
                   			p_designator);
                   		END IF;   --rowcount
                 ELSE
                     		update msc_sup_dem_entries
                     		set quantity = quantity + t_qty(j),
                         		primary_quantity = primary_quantity + t_qty(j),
                         		tp_quantity = quantity + t_tp_qty(j)
                     		where publisher_id = t_pub_id(j)
                     		and publisher_site_id = t_pub_site_id(j)
                     		and supplier_id = t_supp_id(j)
                     		and supplier_site_id = t_supp_site_id(j)
                     		and inventory_item_id = t_item_id(j)
                     		and trunc(key_date) = trunc(t_key_date(j))
                     		and publisher_order_type = ORDER_FORECAST;

               		END IF;

                  update msc_sup_dem_entries
                  	set quantity = quantity + t_planned_order_qty(j),
                     		primary_quantity = primary_quantity + t_planned_order_qty(j) ,
                     		tp_quantity = tp_quantity + t_tp_planned_order_qty(j)
                  where publisher_id = t_pub_id(j)
                  and publisher_site_id = t_pub_site_id(j)
                  and supplier_id = t_supp_id(j)
                  and supplier_site_id = t_supp_site_id(j)
                  and inventory_item_id = t_item_id(j)
                  and trunc(key_date) = trunc(t_key_date(j))
                  and publisher_order_type = CP_PLANNED_ORDER;

                  update msc_sup_dem_entries
                  	set quantity = quantity + t_released_qty(j),
                     		primary_quantity = primary_quantity + t_released_qty(j),
                     		tp_quantity = tp_quantity + t_tp_released_qty(j)
                  where publisher_id = t_pub_id(j)
                  and publisher_site_id = t_pub_site_id(j)
                  and supplier_id = t_supp_id(j)
                  and supplier_site_id = t_supp_site_id(j)
                  and inventory_item_id = t_item_id(j)
                  and trunc(key_date) = trunc(t_key_date(j))
                  and publisher_order_type = CP_RELEASED_PLANNED_ORDER;

 	          exception
 	          when others then
 	          	null;
 	          end;
         ELSIF (t_order_type(j) = REQUISITION) THEN

          	IF (t_base_item_id(j) is not null) THEN

           		update msc_sup_dem_entries
           		set quantity = quantity + t_qty(j),
               		primary_quantity = primary_quantity + t_qty(j),
               		tp_quantity = tp_quantity + t_tp_qty(j)
           		where publisher_id = t_pub_id(j)
           		and publisher_site_id = t_pub_site_id(j)
           		and supplier_id = t_supp_id(j)
           		and supplier_site_id = t_supp_site_id(j)
           		and inventory_item_id = t_base_item_id(j)
           		and trunc(key_date) = trunc(t_key_date(j))
           		and publisher_order_type = ORDER_FORECAST;
           		IF (SQL%ROWCOUNT = 0) THEN
         			insert into msc_sup_dem_entries (
            				transaction_id,
            				plan_id,
            				sr_instance_id,
            				publisher_name,
            				publisher_id,
            				publisher_site_name,
            				publisher_site_id,
            				customer_name,
            				customer_id,
            				customer_site_name,
            				customer_site_id,
            				supplier_name,
            				supplier_id,
            				supplier_site_name,
            				supplier_site_id,
            				ship_from_party_name,
            				ship_from_party_id,
            				ship_from_party_site_name,
            				ship_from_party_site_id,
            				ship_to_party_name,
            				ship_to_party_id,
            				ship_to_party_site_name,
            				ship_to_party_site_id,
            				publisher_order_type,
            				publisher_order_type_desc,
            				bucket_type_desc,
            				bucket_type,
            				inventory_item_id,
            				item_name,
            				owner_item_name,
            				customer_item_name,
            				supplier_item_name,
            				item_description,
            				owner_item_description,
            				customer_item_description,
            				supplier_item_description,
            				primary_uom,
            				uom_code,
            				tp_uom_code,
            				key_date,
            				ship_date,
            				receipt_date,
            				quantity,
            				primary_quantity,
            				tp_quantity,
            				last_refresh_number,
            				posting_party_name,
            				posting_party_id,
            				created_by,
            				creation_date,
            				last_updated_by,
            				last_update_date,
            				project_number,
            				task_number,
            				planning_group,
            				planner_code,
            				version,
            				designator
         			) values (
         				msc_sup_dem_entries_s.nextval,
         				-1,
         				-1,
         				t_pub(j),
         				t_pub_id(j),
         				t_pub_site(j),
         				t_pub_site_id(j),
         				t_pub(j),
         				t_pub_id(j),
         				t_pub_site(j),
         				t_pub_site_id(j),
         				t_supp(j),
         				t_supp_id(j),
         				t_supp_site(j),
         				t_supp_site_id(j),
         				t_supp(j),
         				t_supp_id(j),
         				t_supp_site(j),
         				t_supp_site_id(j),
         				t_pub(j),
         				t_pub_id(j),
         				t_pub_site(j),
         				t_pub_site_id(j),
         				ORDER_FORECAST,
         				l_order_type_desc,
 					      l_bucket_type_desc,
         				t_bucket_type(j),
         				t_base_item_id(j),
         				t_base_item_name(j),
         				t_base_item_name(j),
         				t_base_item_name(j),
         				t_supp_item_name(j),
         				nvl(t_base_item_desc(j), t_owner_item_desc(j)),
         				t_base_item_desc(j),
         				t_base_item_desc(j),
         				t_supp_item_desc(j),
         				t_uom_code(j),
         				t_uom_code(j),
         				t_tp_uom(j),
         				t_key_date(j),
         				t_ship_date(j),
         				t_receipt_date(j),
         				t_qty(j),
         				t_qty(j),
         				t_tp_qty(j),
         				msc_cl_refresh_s.nextval,
         				t_pub(j),
         				t_pub_id(j),
         				nvl(p_user_id,-1),
         				sysdate,
         				nvl(p_user_id,-1),
         				sysdate,
         				t_proj_number(j),
         				t_task_number(j),
         				t_planning_gp(j),
         				t_planner_code(j),
         				p_version,
         				p_designator);
         		END IF;   --rowcount

           	ELSE
            		update msc_sup_dem_entries
           			set quantity = quantity + t_qty(j),
               			primary_quantity = primary_quantity + t_qty(j),
               			tp_quantity = tp_quantity + t_tp_qty(j)
           		where publisher_id = t_pub_id(j)
           		and publisher_site_id = t_pub_site_id(j)
           		and supplier_id = t_supp_id(j)
           		and supplier_site_id = t_supp_site_id(j)
           		and inventory_item_id = t_item_id(j)
           		and trunc(key_date) = trunc(t_key_date(j))
           		and publisher_order_type = ORDER_FORECAST;
           	END IF;

           ELSIF (t_order_type(j) = PURCHASE_ORDER) THEN


           	IF (t_base_item_id(j) is not null) THEN
           		update msc_sup_dem_entries
           			set quantity = quantity + t_qty(j),
               			primary_quantity = primary_quantity + t_qty(j),
               			tp_quantity = tp_quantity + t_tp_qty(j)
           		where publisher_id = t_pub_id(j)
           		and publisher_site_id = t_pub_site_id(j)
           		and supplier_id = t_supp_id(j)
           		and supplier_site_id = t_supp_site_id(j)
           		and inventory_item_id = t_base_item_id(j)
           		and trunc(key_date) = trunc(t_key_date(j))
           		and publisher_order_type = ORDER_FORECAST;
 		       ELSE
            		update msc_sup_dem_entries
            		set quantity = quantity + t_qty(j),
                  	primary_quantity = primary_quantity + t_qty(j),
                		tp_quantity = tp_quantity + t_tp_qty(j)
            		where publisher_id = t_pub_id(j)
            		and publisher_site_id = t_pub_site_id(j)
            		and supplier_id = t_supp_id(j)
            		and supplier_site_id = t_supp_site_id(j)
            		and inventory_item_id = t_item_id(j)
            		and trunc(key_date) = trunc(t_key_date(j))
           		and publisher_order_type = ORDER_FORECAST;
           	END IF;
           	update msc_sup_dem_entries
           	set quantity = quantity + t_qty(j),
              	primary_quantity = primary_quantity + t_qty(j) ,
              	tp_quantity = tp_quantity + t_tp_qty(j)
           	where publisher_id = t_pub_id(j)
           	and publisher_site_id = t_pub_site_id(j)
           	and supplier_id = t_supp_id(j)
           	and supplier_site_id = t_supp_site_id(j)
           	and inventory_item_id = t_item_id(j)
           	and trunc(key_date) = trunc(t_key_date(j))
           	and publisher_order_type = CP_PURCHASE_ORDER_FROM_PLAN;

      --- added to publish Planned Inbound Shipment PIS to CP as PIS

      ELSIF (t_order_type(j) = EXPECTED_INBOUND_SHIPMENT) THEN
 	   begin
 		IF (t_base_item_id(j) is not null) THEN


           		update msc_sup_dem_entries
           		set quantity = quantity + t_qty(j),
               		primary_quantity = primary_quantity + t_qty(j),
               		tp_quantity = tp_quantity + t_tp_qty(j)
           		where publisher_id = t_pub_id(j)
           		and publisher_site_id = t_pub_site_id(j)
           		and supplier_id = t_supp_id(j)
           		and supplier_site_id = t_supp_site_id(j)
           		and inventory_item_id = t_base_item_id(j)
           		and trunc(key_date) = trunc(t_key_date(j))
           		and publisher_order_type = ORDER_FORECAST;

           		IF (SQL%ROWCOUNT = 0) THEN
			         insert into msc_sup_dem_entries (
			            transaction_id,
			            plan_id,
			            sr_instance_id,
			            publisher_name,
			            publisher_id,
			            publisher_site_name,
			            publisher_site_id,
			            customer_name,
			            customer_id,
			            customer_site_name,
			            customer_site_id,
			            supplier_name,
			            supplier_id,
			            supplier_site_name,
			            supplier_site_id,
			            ship_from_party_name,
			            ship_from_party_id,
			            ship_from_party_site_name,
			            ship_from_party_site_id,
			            ship_to_party_name,
			            ship_to_party_id,
			            ship_to_party_site_name,
			            ship_to_party_site_id,
			            publisher_order_type,
			            publisher_order_type_desc,
			            bucket_type_desc,
			            bucket_type,
			            inventory_item_id,
			            item_name,
			            owner_item_name,
			            customer_item_name,
			            supplier_item_name,
			            item_description,
			            owner_item_description,
			            customer_item_description,
			            supplier_item_description,
			            primary_uom,
			            uom_code,
			            tp_uom_code,
			            key_date,
			            ship_date,
			            receipt_date,
			            quantity,
			            primary_quantity,
			            tp_quantity,
			            last_refresh_number,
			            posting_party_name,
			            posting_party_id,
			            created_by,
			            creation_date,
			            last_updated_by,
			            last_update_date,
			            project_number,
			            task_number,
			            planning_group,
			            planner_code,
			            version,
			            designator
			         ) values (
			         msc_sup_dem_entries_s.nextval,
			         -1,
			         -1,
			         t_pub(j),
			         t_pub_id(j),
			         t_pub_site(j),
			         t_pub_site_id(j),
			         t_pub(j),
			         t_pub_id(j),
			         t_pub_site(j),
			         t_pub_site_id(j),
			         t_supp(j),
			         t_supp_id(j),
			         t_supp_site(j),
			         t_supp_site_id(j),
			         t_supp(j),
			         t_supp_id(j),
			         t_supp_site(j),
			         t_supp_site_id(j),
			         t_pub(j),
			         t_pub_id(j),
			         t_pub_site(j),
			         t_pub_site_id(j),
			         ORDER_FORECAST,
			         l_order_type_desc,
			 	       l_bucket_type_desc,
			         t_bucket_type(j),
			         t_base_item_id(j),
			         t_base_item_name(j),
			         t_base_item_name(j),
			         t_base_item_name(j),
			         t_supp_item_name(j),
			         nvl(t_base_item_desc(j), t_owner_item_desc(j)),
			         t_base_item_desc(j),
			         t_base_item_desc(j),
			         t_supp_item_desc(j),
			         t_uom_code(j),
			         t_uom_code(j),
			         t_tp_uom(j),
			         t_key_date(j),
			         t_ship_date(j),
			         t_receipt_date(j),
			         t_qty(j),
			         t_qty(j),
			         t_tp_qty(j),
			         msc_cl_refresh_s.nextval,
			         t_pub(j),
			         t_pub_id(j),
			         nvl(p_user_id,-1),
			         sysdate,
			         nvl(p_user_id,-1),
			         sysdate,
			         t_proj_number(j),
			         t_task_number(j),
			         t_planning_gp(j),
			         t_planner_code(j),
			         p_version,
         			p_designator);
         		END IF;   --rowcount
           	ELSE
           		update msc_sup_dem_entries
           		set quantity = quantity + t_qty(j),
               		primary_quantity = primary_quantity + t_qty(j),
               		tp_quantity = quantity + t_tp_qty(j)
           		where publisher_id = t_pub_id(j)
           		and publisher_site_id = t_pub_site_id(j)
           		and supplier_id = t_supp_id(j)
           		and supplier_site_id = t_supp_site_id(j)
           		and inventory_item_id = t_item_id(j)
           		and trunc(key_date) = trunc(t_key_date(j))
           		and publisher_order_type = ORDER_FORECAST;

     		   END IF;

           	update msc_sup_dem_entries
           		set quantity = quantity + t_planned_order_qty(j),
               		primary_quantity = primary_quantity + t_planned_order_qty(j) ,
               		tp_quantity = tp_quantity + t_tp_planned_order_qty(j)
           	where publisher_id = t_pub_id(j)
           	and publisher_site_id = t_pub_site_id(j)
           	and supplier_id = t_supp_id(j)
           	and supplier_site_id = t_supp_site_id(j)
           	and inventory_item_id = t_item_id(j)
           	and trunc(key_date) = trunc(t_key_date(j))
           	and publisher_order_type = CP_PLANNED_INBOUND_SHIPMENT;

           	update msc_sup_dem_entries
           		set quantity = quantity + t_released_qty(j),
               		primary_quantity = primary_quantity + t_released_qty(j),
               		tp_quantity = tp_quantity + t_tp_released_qty(j)
           	where publisher_id = t_pub_id(j)
           	and publisher_site_id = t_pub_site_id(j)
           	and supplier_id = t_supp_id(j)
           	and supplier_site_id = t_supp_site_id(j)
           	and inventory_item_id = t_item_id(j)
           	and trunc(key_date) = trunc(t_key_date(j))
           	and publisher_order_type = CP_RELEASED_INBOUND_SHIPMENT;

         exception
 	        when others then
 		       null;
 	       end;

       END IF;

      /*-----------------------------------------------------
       Elsif j > 1
       -------------------------------------------------------*/
      ELSIF (j > 1 and t_pub_id(j) = t_pub_id(j-1) and
               t_pub_site_id(j) = t_pub_site_id(j-1) and
               t_item_id(j) = t_item_id(j-1) and
               t_supp_id(j) = t_supp_id(j-1) and
               t_supp_site_id(j) = t_supp_site_id(j-1) and
               trunc(t_key_date(j)) = trunc(t_key_date(j-1)) and
               trunc(t_ship_date(j)) = trunc(t_ship_date(j-1)) and
               t_order_type(j) <> t_order_type(j-1)) THEN

            IF (t_base_item_id(j) is not null) THEN
           		update msc_sup_dem_entries
           			set quantity = quantity + t_qty(j),
               			primary_quantity = primary_quantity +  t_qty(j) ,
               			tp_quantity = tp_quantity + t_tp_qty(j)
           		where publisher_id = t_pub_id(j)
           		and publisher_site_id = t_pub_site_id(j)
           		and supplier_id = t_supp_id(j)
           		and supplier_site_id = t_supp_site_id(j)
           		and inventory_item_id = t_base_item_id(j)
           		and trunc(key_date) = trunc(t_key_date(j))
           		and publisher_order_type = ORDER_FORECAST;
           		IF (SQL%ROWCOUNT = 0) THEN
         			insert into msc_sup_dem_entries (
            				transaction_id,
            				plan_id,
            				sr_instance_id,
            				publisher_name,
            				publisher_id,
            				publisher_site_name,
            				publisher_site_id,
            				customer_name,
            				customer_id,
            				customer_site_name,
            				customer_site_id,
            				supplier_name,
            				supplier_id,
            				supplier_site_name,
            				supplier_site_id,
            				ship_from_party_name,
            				ship_from_party_id,
            				ship_from_party_site_name,
            				ship_from_party_site_id,
            				ship_to_party_name,
            				ship_to_party_id,
            				ship_to_party_site_name,
            				ship_to_party_site_id,
            				publisher_order_type,
            				publisher_order_type_desc,
            				bucket_type_desc,
            				bucket_type,
            				inventory_item_id,
            				item_name,
            				owner_item_name,
            				customer_item_name,
            				supplier_item_name,
            				item_description,
            				owner_item_description,
            				customer_item_description,
            				supplier_item_description,
            				primary_uom,
            				uom_code,
            				tp_uom_code,
            				key_date,
            				ship_date,
            				receipt_date,
            				quantity,
            				primary_quantity,
            				tp_quantity,
            				last_refresh_number,
            				posting_party_name,
            				posting_party_id,
            				created_by,
            				creation_date,
            				last_updated_by,
            				last_update_date,
            				project_number,
            				task_number,
            				planning_group,
            				planner_code,
            				version,
            				designator
         			) values (
         				msc_sup_dem_entries_s.nextval,
         				-1,
         				-1,
         				t_pub(j),
         				t_pub_id(j),
         				t_pub_site(j),
         				t_pub_site_id(j),
         				t_pub(j),
         				t_pub_id(j),
         				t_pub_site(j),
         				t_pub_site_id(j),
         				t_supp(j),
         				t_supp_id(j),
         				t_supp_site(j),
         				t_supp_site_id(j),
         				t_supp(j),
         				t_supp_id(j),
         				t_supp_site(j),
         				t_supp_site_id(j),
         				t_pub(j),
         				t_pub_id(j),
         				t_pub_site(j),
         				t_pub_site_id(j),
         				ORDER_FORECAST,
         				l_order_type_desc,
 					      l_bucket_type_desc,
         				t_bucket_type(j),
         				t_base_item_id(j),
         				t_base_item_name(j),
         				t_base_item_name(j),
         				t_base_item_name(j),
         				t_supp_item_name(j),
         				nvl(t_base_item_desc(j), t_owner_item_desc(j)),
         				t_base_item_desc(j),
         				t_base_item_desc(j),
         				t_supp_item_desc(j),
         				t_uom_code(j),
         				t_uom_code(j),
         				t_tp_uom(j),
         				t_key_date(j),
         				t_ship_date(j),
         				t_receipt_date(j),
         				t_qty(j),
         				t_qty(j),
         				t_tp_qty(j),
         				msc_cl_refresh_s.nextval,
         				t_pub(j),
         				t_pub_id(j),
         				nvl(p_user_id,-1),
         				sysdate,
         				nvl(p_user_id,-1),
         				sysdate,
         				t_proj_number(j),
         				t_task_number(j),
         				t_planning_gp(j),
         				t_planner_code(j),
         				p_version,
         				p_designator);
         		END IF;   --rowcount

		      ELSE
           		update msc_sup_dem_entries
           			set quantity = quantity + t_qty(j),
               			primary_quantity = primary_quantity + t_qty(j) ,
               			tp_quantity = tp_quantity + t_tp_qty(j)
           		where publisher_id = t_pub_id(j)
           		and publisher_site_id = t_pub_site_id(j)
           		and supplier_id = t_supp_id(j)
           		and supplier_site_id = t_supp_site_id(j)
           		and inventory_item_id = t_item_id(j)
           		and trunc(key_date) = trunc(t_key_date(j))
           		and publisher_order_type = ORDER_FORECAST;
           	END IF;

  		IF (t_order_type(j) = PLANNED_ORDER) THEN
         	-------------------------------------------------------
         	-- PLANNED_ORDER
         	------------------------------------------------------
         	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'PLO' || t_planned_order_qty(j) || ' tp '
          --	|| t_tp_planned_order_qty(j) || 'date ' || t_key_date(j));
          log_message('PLO' || t_planned_order_qty(j) || ' tp ' || t_tp_planned_order_qty(j) || 'date ' || t_key_date(j));
  		    l_order_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',CP_PLANNED_ORDER);
  		    l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));

  	 	IF ( t_planned_order_qty(j) <> 0 ) THEN
  	 		l_planned_order_qty := t_planned_order_qty(j);
  	 		l_tp_planned_order_qty := t_planned_order_qty(j);
  	        	IF (t_planned_order_qty(j) < 0 ) THEN
 	        		l_planned_order_qty := 0;
 	        		l_tp_planned_order_qty := 0;
 	        	END IF;
 	           insert into msc_sup_dem_entries (
              		transaction_id,
              		plan_id,
              		sr_instance_id,
              		publisher_name,
              		publisher_id,
              		publisher_site_name,
              		publisher_site_id,
              		customer_name,
              		customer_id,
              		customer_site_name,
              		customer_site_id,
              		supplier_name,
              		supplier_id,
              		supplier_site_name,
              		supplier_site_id,
              		ship_from_party_name,
              		ship_from_party_id,
              		ship_from_party_site_name,
              		ship_from_party_site_id,
              		ship_to_party_name,
              		ship_to_party_id,
              		ship_to_party_site_name,
              		ship_to_party_site_id,
              		publisher_order_type,
              		publisher_order_type_desc,
              		bucket_type_desc,
              		bucket_type,
              		inventory_item_id,
              		item_name,
              		owner_item_name,
              		customer_item_name,
              		supplier_item_name,
              		item_description,
              		owner_item_description,
              		customer_item_description,
              		supplier_item_description,
              		primary_uom,
              		uom_code,
              		tp_uom_code,
              		key_date,
              		ship_date,
              		receipt_date,
              		quantity,
              		primary_quantity,
              		tp_quantity,
              		last_refresh_number,
              		posting_party_name,
              		posting_party_id,
              		created_by,
              		creation_date,
              		last_updated_by,
              		last_update_date,
              		project_number,
              		task_number,
              		planning_group,
              		planner_code,
              		version,
              		designator,
              		base_item_id,
              		base_item_name
           		) values (
           		msc_sup_dem_entries_s.nextval,
           		-1,
           		-1,
           		t_pub(j),
           		t_pub_id(j),
           		t_pub_site(j),
           		t_pub_site_id(j),
           		t_pub(j),
           		t_pub_id(j),
           		t_pub_site(j),
           		t_pub_site_id(j),
           		t_supp(j),
           		t_supp_id(j),
           		t_supp_site(j),
           		t_supp_site_id(j),
           		t_supp(j),
           		t_supp_id(j),
           		t_supp_site(j),
           		t_supp_site_id(j),
           		t_pub(j),
           		t_pub_id(j),
           		t_pub_site(j),
           		t_pub_site_id(j),
           		CP_PLANNED_ORDER,
           		l_order_type_desc,
 			        l_bucket_type_desc,
           		t_bucket_type(j),
           		t_item_id(j),
           		t_master_item_name(j),
           		t_owner_item_name(j),
           		t_owner_item_name(j),
           		t_supp_item_name(j),
           		nvl(t_master_item_desc(j), t_owner_item_desc(j)),
           		t_owner_item_desc(j),
           		t_owner_item_desc(j),
           		t_supp_item_desc(j),
           		t_uom_code(j),
           		t_uom_code(j),
           		t_tp_uom(j),
           		t_key_date(j),
           		t_ship_date(j),
           		t_receipt_date(j),
           		l_planned_order_qty,
           		l_planned_order_qty,
           		l_tp_planned_order_qty,
           		msc_cl_refresh_s.nextval,
           		t_pub(j),
           		t_pub_id(j),
           		nvl(p_user_id,-1),
           		sysdate,
           		nvl(p_user_id,-1),
           		sysdate,
           		t_proj_number(j),
           		t_task_number(j),
           		t_planning_gp(j),
           		t_planner_code(j),
           		p_version,
         		p_designator,
         		t_base_item_id(j),
         		t_base_item_name(j));
         	END IF;
         	----------------------------------------------------------
         	-- RELEASED_PLANNED_ORDER
         	----------------------------------------------------------

         	l_order_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',CP_RELEASED_PLANNED_ORDER);
  		    l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));
            IF (t_released_qty(j) <> 0 ) THEN
                l_released_qty := t_released_qty(j);
                l_tp_released_qty := t_tp_released_qty(j);
                IF (t_released_qty(j) < 0 ) THEN
                	l_released_qty := 0;
                	l_tp_released_qty := 0;
                END IF;
            	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'released qty ' || t_released_qty(j) || ' tp '
             	--	|| t_tp_released_qty(j) || 'date ' || t_key_date(j));
              log_message( 'released qty ' || t_released_qty(j) || ' tp ' || t_tp_released_qty(j) || 'date ' || t_key_date(j));
  		insert into msc_sup_dem_entries (
  	        transaction_id,
            	plan_id,
            	sr_instance_id,
            	publisher_name,
            	publisher_id,
            	publisher_site_name,
            	publisher_site_id,
            	customer_name,
            	customer_id,
            	customer_site_name,
            	customer_site_id,
            	supplier_name,
            	supplier_id,
            	supplier_site_name,
            	supplier_site_id,
            	ship_from_party_name,
            	ship_from_party_id,
            	ship_from_party_site_name,
            	ship_from_party_site_id,
            	ship_to_party_name,
            	ship_to_party_id,
            	ship_to_party_site_name,
            	ship_to_party_site_id,
            	publisher_order_type,
            	publisher_order_type_desc,
            	bucket_type_desc,
            	bucket_type,
            	inventory_item_id,
            	item_name,
            	owner_item_name,
            	customer_item_name,
            	supplier_item_name,
            	item_description,
            	owner_item_description,
            	customer_item_description,
            	supplier_item_description,
            	primary_uom,
            	uom_code,
            	tp_uom_code,
            	key_date,
            	ship_date,
            	receipt_date,
            	quantity,
            	primary_quantity,
            	tp_quantity,
            	last_refresh_number,
            	posting_party_name,
            	posting_party_id,
            	created_by,
            	creation_date,
            	last_updated_by,
            	last_update_date,
            	project_number,
            	task_number,
            	planning_group,
            	planner_code,
            	version,
            	designator,
            	base_item_id,
            	base_item_name
         	) values (
         	msc_sup_dem_entries_s.nextval,
         	-1,
         	-1,
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	t_supp(j),
         	t_supp_id(j),
         	t_supp_site(j),
         	t_supp_site_id(j),
         	t_supp(j),
         	t_supp_id(j),
         	t_supp_site(j),
         	t_supp_site_id(j),
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	CP_RELEASED_PLANNED_ORDER,
         	l_order_type_desc,
         	l_bucket_type_desc,
         	t_bucket_type(j),
         	t_item_id(j),
         	t_master_item_name(j),
         	t_owner_item_name(j),
         	t_owner_item_name(j),
         	t_supp_item_name(j),
         	nvl(t_master_item_desc(j), t_owner_item_desc(j)),
         	t_owner_item_desc(j),
         	t_owner_item_desc(j),
         	t_supp_item_desc(j),
         	t_uom_code(j),
         	t_uom_code(j),
         	t_tp_uom(j),
         	t_key_date(j),
         	t_ship_date(j),
         	t_receipt_date(j),
         	l_released_qty,
         	l_released_qty,
         	l_tp_released_qty,
         	msc_cl_refresh_s.nextval,
         	t_pub(j),
         	t_pub_id(j),
         	nvl(p_user_id,-1),
         	sysdate,
         	nvl(p_user_id,-1),
         	sysdate,
         	t_proj_number(j),
         	t_task_number(j),
         	t_planning_gp(j),
         	t_planner_code(j),
         	p_version,
         	p_designator,
         	t_base_item_id(j),
         	t_base_item_name(j));

          END IF;
       ELSIF (t_order_type(j) = PURCHASE_ORDER) THEN

         	------------------------------------------------------
         	-- PURCHASE_ORDER_FROM_PLAN
         	------------------------------------------------------
         	l_order_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',CP_PURCHASE_ORDER_FROM_PLAN);
  		    l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));

         --FND_FILE.PUT_LINE(FND_FILE.LOG, 'Po ' || t_qty(j) || ' tp ' || t_tp_qty(j)
         --|| 'date ' || t_key_date(j));
         log_message( 'Po ' || t_qty(j) || ' tp ' || t_tp_qty(j) || 'date ' || t_key_date(j));
 	   	insert into msc_sup_dem_entries (
            	transaction_id,
            	plan_id,
            	sr_instance_id,
            	publisher_name,
            	publisher_id,
            	publisher_site_name,
            	publisher_site_id,
            	customer_name,
            	customer_id,
            	customer_site_name,
            	customer_site_id,
            	supplier_name,
            	supplier_id,
            	supplier_site_name,
            	supplier_site_id,
            	ship_from_party_name,
            	ship_from_party_id,
            	ship_from_party_site_name,
            	ship_from_party_site_id,
            	ship_to_party_name,
            	ship_to_party_id,
            	ship_to_party_site_name,
            	ship_to_party_site_id,
            	publisher_order_type,
            	publisher_order_type_desc,
            	bucket_type_desc,
            	bucket_type,
            	inventory_item_id,
            	item_name,
            	owner_item_name,
            	customer_item_name,
            	supplier_item_name,
            	item_description,
            	owner_item_description,
            	customer_item_description,
            	supplier_item_description,
            	primary_uom,
            	uom_code,
            	tp_uom_code,
            	key_date,
            	ship_date,
            	receipt_date,
            	quantity,
            	primary_quantity,
            	tp_quantity,
            	last_refresh_number,
            	posting_party_name,
            	posting_party_id,
            	created_by,
            	creation_date,
            	last_updated_by,
            	last_update_date,
            	project_number,
            	task_number,
            	planning_group,
            	planner_code,
            	version,
            	designator,
            	base_item_id,
            	base_item_name
         	) values (
         	msc_sup_dem_entries_s.nextval,
         	-1,
         	-1,
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	t_supp(j),
         	t_supp_id(j),
         	t_supp_site(j),
         	t_supp_site_id(j),
         	t_supp(j),
         	t_supp_id(j),
         	t_supp_site(j),
         	t_supp_site_id(j),
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	CP_PURCHASE_ORDER_FROM_PLAN,
         	l_order_type_desc,
 		      l_bucket_type_desc,
          t_bucket_type(j),
         	t_item_id(j),
         	t_master_item_name(j),
         	t_owner_item_name(j),
         	t_owner_item_name(j),
         	t_supp_item_name(j),
         	nvl(t_master_item_desc(j), t_owner_item_desc(j)),
         	t_owner_item_desc(j),
         	t_owner_item_desc(j),
         	t_supp_item_desc(j),
         	t_uom_code(j),
         	t_uom_code(j),
         	t_tp_uom(j),
         	t_key_date(j),
         	t_ship_date(j),
         	t_receipt_date(j),
         	t_qty(j),
         	t_qty(j),
         	t_tp_qty(j),
         	msc_cl_refresh_s.nextval,
         	t_pub(j),
         	t_pub_id(j),
         	nvl(p_user_id,-1),
         	sysdate,
         	nvl(p_user_id,-1),
         	sysdate,
         	t_proj_number(j),
         	t_task_number(j),
         	t_planning_gp(j),
         	t_planner_code(j),
         	p_version,
         	p_designator,
         	t_base_item_id(j),
         	t_base_item_name(j));

       -- added to publish Planned Inbound Shipment (PIS) to CP as PIS

    ELSIF (t_order_type(j) = EXPECTED_INBOUND_SHIPMENT) THEN
         	---------------------------------------------------------
         	-- EXPECTED_INBOUND_SHIPMENT (PLANNED_INBOUND_SHIPMENT)
         	---------------------------------------------------------

  		l_order_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',CP_PLANNED_INBOUND_SHIPMENT);
  		l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));

  	 	IF ( t_planned_order_qty(j) <> 0 ) THEN
  	 		l_planned_order_qty := t_planned_order_qty(j);
  	 		l_tp_planned_order_qty := t_planned_order_qty(j);
  	        	IF (t_planned_order_qty(j) < 0 ) THEN
 	        		l_planned_order_qty := 0;
 	        		l_tp_planned_order_qty := 0;
 	        	END IF;
	   log_message(' PIS ' || t_planned_order_qty(j) || ' tp ' || t_tp_planned_order_qty(j) || ' date ' || t_key_date(j));

 	           insert into msc_sup_dem_entries (
              		transaction_id,
              		plan_id,
              		sr_instance_id,
              		publisher_name,
              		publisher_id,
              		publisher_site_name,
              		publisher_site_id,
              		customer_name,
              		customer_id,
              		customer_site_name,
              		customer_site_id,
              		supplier_name,
              		supplier_id,
              		supplier_site_name,
              		supplier_site_id,
              		ship_from_party_name,
              		ship_from_party_id,
              		ship_from_party_site_name,
              		ship_from_party_site_id,
              		ship_to_party_name,
              		ship_to_party_id,
              		ship_to_party_site_name,
              		ship_to_party_site_id,
              		publisher_order_type,
              		publisher_order_type_desc,
              		bucket_type_desc,
              		bucket_type,
              		inventory_item_id,
              		item_name,
              		owner_item_name,
              		customer_item_name,
              		supplier_item_name,
              		item_description,
              		owner_item_description,
              		customer_item_description,
              		supplier_item_description,
              		primary_uom,
              		uom_code,
              		tp_uom_code,
              		key_date,
              		ship_date,
              		receipt_date,
              		quantity,
              		primary_quantity,
              		tp_quantity,
              		last_refresh_number,
              		posting_party_name,
              		posting_party_id,
              		created_by,
              		creation_date,
              		last_updated_by,
              		last_update_date,
              		project_number,
              		task_number,
              		planning_group,
              		planner_code,
              		version,
              		designator,
              		base_item_id,
              		base_item_name
           		) values (
           		msc_sup_dem_entries_s.nextval,
           		-1,
           		-1,
           		t_pub(j),
           		t_pub_id(j),
           		t_pub_site(j),
           		t_pub_site_id(j),
           		t_pub(j),
           		t_pub_id(j),
           		t_pub_site(j),
           		t_pub_site_id(j),
           		t_supp(j),
           		t_supp_id(j),
           		t_supp_site(j),
           		t_supp_site_id(j),
           		t_supp(j),
           		t_supp_id(j),
           		t_supp_site(j),
           		t_supp_site_id(j),
           		t_pub(j),
           		t_pub_id(j),
           		t_pub_site(j),
           		t_pub_site_id(j),
           		CP_PLANNED_INBOUND_SHIPMENT,
           		l_order_type_desc,
 			        l_bucket_type_desc,
           		t_bucket_type(j),
           		t_item_id(j),
           		t_master_item_name(j),
           		t_owner_item_name(j),
           		t_owner_item_name(j),
           		t_supp_item_name(j),
           		nvl(t_master_item_desc(j), t_owner_item_desc(j)),
           		t_owner_item_desc(j),
           		t_owner_item_desc(j),
           		t_supp_item_desc(j),
           		t_uom_code(j),
           		t_uom_code(j),
           		t_tp_uom(j),
           		t_key_date(j),
           		t_ship_date(j),
           		t_receipt_date(j),
           		l_planned_order_qty,
           		l_planned_order_qty,
           		l_tp_planned_order_qty,
           		msc_cl_refresh_s.nextval,
           		t_pub(j),
           		t_pub_id(j),
           		nvl(p_user_id,-1),
           		sysdate,
           		nvl(p_user_id,-1),
           		sysdate,
           		t_proj_number(j),
           		t_task_number(j),
           		t_planning_gp(j),
           		t_planner_code(j),
           		p_version,
         		p_designator,
         		t_base_item_id(j),
         		t_base_item_name(j));
         	END IF;
         	----------------------------------------------------------
         	-- CP_RELEASED_INBOUND_SHIPMENT (qty released from PIS)
         	----------------------------------------------------------

         	l_order_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',CP_RELEASED_INBOUND_SHIPMENT);
  		l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));
            IF (t_released_qty(j) <> 0 ) THEN
                l_released_qty := t_released_qty(j);
                l_tp_released_qty := t_tp_released_qty(j);
                IF (t_released_qty(j) < 0 ) THEN
                	l_released_qty := 0;
                	l_tp_released_qty := 0;
                END IF;

                 log_message( 'released qty from PIS ' || t_released_qty(j) || ' tp ' || t_tp_released_qty(j) || ' date ' || t_key_date(j));
  		insert into msc_sup_dem_entries (
  	        transaction_id,
            	plan_id,
            	sr_instance_id,
            	publisher_name,
            	publisher_id,
            	publisher_site_name,
            	publisher_site_id,
            	customer_name,
            	customer_id,
            	customer_site_name,
            	customer_site_id,
            	supplier_name,
            	supplier_id,
            	supplier_site_name,
            	supplier_site_id,
            	ship_from_party_name,
            	ship_from_party_id,
            	ship_from_party_site_name,
            	ship_from_party_site_id,
            	ship_to_party_name,
            	ship_to_party_id,
            	ship_to_party_site_name,
            	ship_to_party_site_id,
            	publisher_order_type,
            	publisher_order_type_desc,
            	bucket_type_desc,
            	bucket_type,
            	inventory_item_id,
            	item_name,
            	owner_item_name,
            	customer_item_name,
            	supplier_item_name,
            	item_description,
            	owner_item_description,
            	customer_item_description,
            	supplier_item_description,
            	primary_uom,
            	uom_code,
            	tp_uom_code,
            	key_date,
            	ship_date,
            	receipt_date,
            	quantity,
            	primary_quantity,
            	tp_quantity,
            	last_refresh_number,
            	posting_party_name,
            	posting_party_id,
            	created_by,
            	creation_date,
            	last_updated_by,
            	last_update_date,
            	project_number,
            	task_number,
            	planning_group,
            	planner_code,
            	version,
            	designator,
            	base_item_id,
            	base_item_name
         	) values (
         	msc_sup_dem_entries_s.nextval,
         	-1,
         	-1,
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	t_supp(j),
         	t_supp_id(j),
         	t_supp_site(j),
         	t_supp_site_id(j),
         	t_supp(j),
         	t_supp_id(j),
         	t_supp_site(j),
         	t_supp_site_id(j),
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	CP_RELEASED_INBOUND_SHIPMENT,
         	l_order_type_desc,
           	l_bucket_type_desc,
           	t_bucket_type(j),
         	t_item_id(j),
         	t_master_item_name(j),
         	t_owner_item_name(j),
         	t_owner_item_name(j),
         	t_supp_item_name(j),
         	nvl(t_master_item_desc(j), t_owner_item_desc(j)),
         	t_owner_item_desc(j),
         	t_owner_item_desc(j),
         	t_supp_item_desc(j),
         	t_uom_code(j),
         	t_uom_code(j),
         	t_tp_uom(j),
         	t_key_date(j),
         	t_ship_date(j),
         	t_receipt_date(j),
         	l_released_qty,
         	l_released_qty,
         	l_tp_released_qty,
         	msc_cl_refresh_s.nextval,
         	t_pub(j),
         	t_pub_id(j),
         	nvl(p_user_id,-1),
         	sysdate,
         	nvl(p_user_id,-1),
         	sysdate,
         	t_proj_number(j),
         	t_task_number(j),
         	t_planning_gp(j),
         	t_planner_code(j),
         	p_version,
         	p_designator,
         	t_base_item_id(j),
         	t_base_item_name(j));
         END IF;

      END IF;

       /*----------------------------------------------------
         else
         ---------------------------------------------------*/
 ELSE

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'qty ' || t_qty(j) || ' tp ' || t_tp_qty(j)|| 'date ' || t_key_date(j) || ' Item ' || t_item_id(j) || ' base ' || t_base_item_id(j));
  	  l_order_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',ORDER_FORECAST);
  	  l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));

 	    IF (t_base_item_id(j) is null) THEN
 	    	l_item_id := t_item_id(j);
 	    	l_base_item_name := null;
 	    	l_base_item_desc := null;
 	    ELSE
 	    	l_item_id := t_base_item_id(j);
 	    	l_base_item_name := t_base_item_name(j);
 	    	l_base_item_desc := t_base_item_desc(j);
 	    END IF;

      l_count := 0;

       	SELECT count(*)
       	INTO	l_count
       	FROM	msc_sup_dem_entries
        where publisher_id = t_pub_id(j)
      	and publisher_site_id = t_pub_site_id(j)
       	and supplier_id = t_supp_id(j)
       	and supplier_site_id = t_supp_site_id(j)
      	and inventory_item_id = l_item_id
     	  and trunc(key_date) = trunc(t_key_date(j))
     	  and publisher_order_type = ORDER_FORECAST;

     	   IF l_count > 0 THEN

              	update msc_sup_dem_entries
              		set quantity = quantity + t_qty(j),
                  		primary_quantity = primary_quantity + t_qty(j) ,
                  		tp_quantity = tp_quantity + t_tp_qty(j)
              	where publisher_id = t_pub_id(j)
              	and publisher_site_id = t_pub_site_id(j)
              	and supplier_id = t_supp_id(j)
              	and supplier_site_id = t_supp_site_id(j)
              	and inventory_item_id = l_item_id
              	and trunc(key_date) = trunc(t_key_date(j))
              	and publisher_order_type = ORDER_FORECAST;
     	   ELSE

     	        begin
                 insert into msc_sup_dem_entries (
                    transaction_id,
                    plan_id,
                    sr_instance_id,
                    publisher_name,
                    publisher_id,
                    publisher_site_name,
                    publisher_site_id,
                    customer_name,
                    customer_id,
                    customer_site_name,
                    customer_site_id,
                    supplier_name,
                    supplier_id,
                    supplier_site_name,
                    supplier_site_id,
                    ship_from_party_name,
                    ship_from_party_id,
                    ship_from_party_site_name,
                    ship_from_party_site_id,
                    ship_to_party_name,
                    ship_to_party_id,
                    ship_to_party_site_name,
                    ship_to_party_site_id,
                    publisher_order_type,
                    publisher_order_type_desc,
                    bucket_type_desc,
                    bucket_type,
                    inventory_item_id,
                    item_name,
                    owner_item_name,
                    customer_item_name,
                    supplier_item_name,
                    item_description,
                    owner_item_description,
                    customer_item_description,
                    supplier_item_description,
                    primary_uom,
                    uom_code,
                    tp_uom_code,
                    key_date,
                    ship_date,
                    receipt_date,
                    quantity,
                    primary_quantity,
                    tp_quantity,
                    last_refresh_number,
                    posting_party_name,
                    posting_party_id,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    project_number,
                    task_number,
                    planning_group,
                    planner_code,
                    version,
                    designator
                 ) values (
                 msc_sup_dem_entries_s.nextval,
                 -1,
                 -1,
                 t_pub(j),
                 t_pub_id(j),
                 t_pub_site(j),
                 t_pub_site_id(j),
                 t_pub(j),
                 t_pub_id(j),
                 t_pub_site(j),
                 t_pub_site_id(j),
                 t_supp(j),
                 t_supp_id(j),
                 t_supp_site(j),
                 t_supp_site_id(j),
                 t_supp(j),
                 t_supp_id(j),
                 t_supp_site(j),
                 t_supp_site_id(j),
                 t_pub(j),
                 t_pub_id(j),
                 t_pub_site(j),
                 t_pub_site_id(j),
                 ORDER_FORECAST,
                 l_order_type_desc,
 	               l_bucket_type_desc,
                 t_bucket_type(j),
                 l_item_id,
                 nvl(l_base_item_name, t_master_item_name(j)),
                 nvl(l_base_item_name, t_owner_item_name(j)),
                 nvl(l_base_item_name, t_owner_item_name(j)),
                 t_supp_item_name(j),
                 nvl(l_base_item_desc, nvl(t_master_item_desc(j), t_owner_item_desc(j))),
                 nvl(l_base_item_desc, t_owner_item_desc(j)),
                 nvl(l_base_item_desc, t_owner_item_desc(j)),
                 t_supp_item_desc(j),
                 t_uom_code(j),
                 t_uom_code(j),
                 t_tp_uom(j),
                 t_key_date(j),
                 t_ship_date(j),
                 t_receipt_date(j),
                 t_qty(j),
                 t_qty(j),
                 t_tp_qty(j),
                 msc_cl_refresh_s.nextval,
                 t_pub(j),
                 t_pub_id(j),
                 nvl(p_user_id,-1),
                 sysdate,
                 nvl(p_user_id,-1),
                 sysdate,
                 t_proj_number(j),
                 t_task_number(j),
                 t_planning_gp(j),
                 t_planner_code(j),
                 p_version,
                 p_designator);
     	        exception
     	        	when others then
     	        	FND_FILE.PUT_LINE(FND_FILE.LOG, 'insert failed on else statement with base item ' || sqlerrm);
     	        end;
         END IF;
      -- Check in if-else ladder for type of order and insert accordingly
      -- Ladder 1 -> Planned Order - insert CP Planned Order, Released Planned Order
      -- Ladder 2 -> Purchase Order - insert CP Purchase Order from Plan
      -- Ladder 3 -> Expected Inbound Shipment - insert Planned Inbound Shipment
      IF (t_order_type(j) = PLANNED_ORDER) THEN

         	-------------------------------------------------------
         	-- PLANNED_ORDER
         	------------------------------------------------------
           	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'PLO' || t_planned_order_qty(j) || ' tp '
           	--	|| t_tp_planned_order_qty(j) || 'date ' || t_key_date(j));
           	log_message('PLO' || t_planned_order_qty(j) || ' tp ' || t_tp_planned_order_qty(j) || 'date ' || t_key_date(j));
  		      l_order_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',CP_PLANNED_ORDER);
  	        l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));
  	    IF ( t_planned_order_qty(j) <> 0 ) THEN
  	      	l_planned_order_qty := t_planned_order_qty(j);
  	      	l_tp_planned_order_qty := t_tp_planned_order_qty(j);

 	        IF (t_planned_order_qty(j) < 0 ) THEN
 	        	l_planned_order_qty := 0;
 	        	l_tp_planned_order_qty := 0;
 	        END IF;
   		insert into msc_sup_dem_entries (
              	transaction_id,
              	plan_id,
              	sr_instance_id,
              	publisher_name,
              	publisher_id,
              	publisher_site_name,
              	publisher_site_id,
              	customer_name,
              	customer_id,
              	customer_site_name,
              	customer_site_id,
              	supplier_name,
              	supplier_id,
              	supplier_site_name,
              	supplier_site_id,
              	ship_from_party_name,
              	ship_from_party_id,
              	ship_from_party_site_name,
              	ship_from_party_site_id,
              	ship_to_party_name,
              	ship_to_party_id,
              	ship_to_party_site_name,
              	ship_to_party_site_id,
              	publisher_order_type,
              	publisher_order_type_desc,
              	bucket_type_desc,
              	bucket_type,
              	inventory_item_id,
              	item_name,
              	owner_item_name,
              	customer_item_name,
              	supplier_item_name,
              	item_description,
              	owner_item_description,
              	customer_item_description,
              	supplier_item_description,
              	primary_uom,
              	uom_code,
              	tp_uom_code,
              	key_date,
              	ship_date,
              	receipt_date,
              	quantity,
              	primary_quantity,
              	tp_quantity,
              	last_refresh_number,
              	posting_party_name,
              	posting_party_id,
              	created_by,
              	creation_date,
              	last_updated_by,
              	last_update_date,
              	project_number,
              	task_number,
              	planning_group,
              	planner_code,
              	version,
              	designator,
              	base_item_id,
              	base_item_name
           	) values (
           	msc_sup_dem_entries_s.nextval,
           	-1,
           	-1,
           	t_pub(j),
           	t_pub_id(j),
           	t_pub_site(j),
           	t_pub_site_id(j),
           	t_pub(j),
           	t_pub_id(j),
           	t_pub_site(j),
           	t_pub_site_id(j),
           	t_supp(j),
           	t_supp_id(j),
           	t_supp_site(j),
           	t_supp_site_id(j),
           	t_supp(j),
           	t_supp_id(j),
           	t_supp_site(j),
           	t_supp_site_id(j),
           	t_pub(j),
           	t_pub_id(j),
           	t_pub_site(j),
           	t_pub_site_id(j),
           	CP_PLANNED_ORDER,
           	l_order_type_desc,
                 l_bucket_type_desc,
           	t_bucket_type(j),
           	t_item_id(j),
           	t_master_item_name(j),
           	t_owner_item_name(j),
           	t_owner_item_name(j),
           	t_supp_item_name(j),
           	nvl(t_master_item_desc(j), t_owner_item_desc(j)),
           	t_owner_item_desc(j),
           	t_owner_item_desc(j),
           	t_supp_item_desc(j),
           	t_uom_code(j),
           	t_uom_code(j),
           	t_tp_uom(j),
           	t_key_date(j),
           	t_ship_date(j),
           	t_receipt_date(j),
           	l_planned_order_qty,
           	l_planned_order_qty,
           	l_tp_planned_order_qty,
           	msc_cl_refresh_s.nextval,
           	t_pub(j),
           	t_pub_id(j),
           	nvl(p_user_id,-1),
           	sysdate,
           	nvl(p_user_id,-1),
           	sysdate,
           	t_proj_number(j),
           	t_task_number(j),
           	t_planning_gp(j),
           	t_planner_code(j),
           	p_version,
         	p_designator,
         	t_base_item_id(j),
         	t_base_item_name(j));
            END IF;
         	----------------------------------------------------------
         	-- RELEASED_PLANNED_ORDER
         	----------------------------------------------------------

         	l_order_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',CP_RELEASED_PLANNED_ORDER);
  	        l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));
            IF (t_released_qty(j) <> 0 ) THEN
            	l_released_qty := t_released_qty(j);
            	l_tp_released_qty := t_tp_released_qty(j);
                IF (t_released_qty(j) < 0 ) THEN
                	l_released_qty := 0;
                	l_tp_released_qty := 0;
                END IF;
         	      --FND_FILE.PUT_LINE(FND_FILE.LOG, 'released qty ' || t_released_qty(j) || ' tp '
               	--	|| t_tp_released_qty(j) || 'date ' || t_key_date(j));
                 log_message( 'released qty ' || t_released_qty(j) || ' tp ' || t_tp_released_qty(j) || 'date ' || t_key_date(j));
  		insert into msc_sup_dem_entries (
  	        transaction_id,
            	plan_id,
            	sr_instance_id,
            	publisher_name,
            	publisher_id,
            	publisher_site_name,
            	publisher_site_id,
            	customer_name,
            	customer_id,
            	customer_site_name,
            	customer_site_id,
            	supplier_name,
            	supplier_id,
            	supplier_site_name,
            	supplier_site_id,
            	ship_from_party_name,
            	ship_from_party_id,
            	ship_from_party_site_name,
            	ship_from_party_site_id,
            	ship_to_party_name,
            	ship_to_party_id,
            	ship_to_party_site_name,
            	ship_to_party_site_id,
            	publisher_order_type,
            	publisher_order_type_desc,
            	bucket_type_desc,
            	bucket_type,
            	inventory_item_id,
            	item_name,
            	owner_item_name,
            	customer_item_name,
            	supplier_item_name,
            	item_description,
            	owner_item_description,
            	customer_item_description,
            	supplier_item_description,
            	primary_uom,
            	uom_code,
            	tp_uom_code,
            	key_date,
            	ship_date,
            	receipt_date,
            	quantity,
            	primary_quantity,
            	tp_quantity,
            	last_refresh_number,
            	posting_party_name,
            	posting_party_id,
            	created_by,
            	creation_date,
            	last_updated_by,
            	last_update_date,
            	project_number,
            	task_number,
            	planning_group,
            	planner_code,
            	version,
            	designator,
            	base_item_id,
            	base_item_name
         	) values (
         	msc_sup_dem_entries_s.nextval,
         	-1,
         	-1,
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	t_supp(j),
         	t_supp_id(j),
         	t_supp_site(j),
         	t_supp_site_id(j),
         	t_supp(j),
         	t_supp_id(j),
         	t_supp_site(j),
         	t_supp_site_id(j),
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	CP_RELEASED_PLANNED_ORDER,
         	l_order_type_desc,
         	l_bucket_type_desc,
           	t_bucket_type(j),
         	t_item_id(j),
         	t_master_item_name(j),
         	t_owner_item_name(j),
         	t_owner_item_name(j),
         	t_supp_item_name(j),
         	nvl(t_master_item_desc(j), t_owner_item_desc(j)),
         	t_owner_item_desc(j),
         	t_owner_item_desc(j),
         	t_supp_item_desc(j),
         	t_uom_code(j),
         	t_uom_code(j),
         	t_tp_uom(j),
         	t_key_date(j),
         	t_ship_date(j),
         	t_receipt_date(j),
         	t_released_qty(j),
         	t_released_qty(j),
         	t_tp_released_qty(j),
         	msc_cl_refresh_s.nextval,
         	t_pub(j),
         	t_pub_id(j),
         	nvl(p_user_id,-1),
         	sysdate,
         	nvl(p_user_id,-1),
         	sysdate,
         	t_proj_number(j),
         	t_task_number(j),
         	t_planning_gp(j),
         	t_planner_code(j),
         	p_version,
         	p_designator,
         	t_base_item_id(j),
         	t_base_item_name(j));

            END IF;
         ELSIF (t_order_type(j) = PURCHASE_ORDER) THEN

         	------------------------------------------------------
         	-- PURCHASE_ORDER_FROM_PLAN
         	------------------------------------------------------
         	l_order_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',CP_PURCHASE_ORDER_FROM_PLAN);
  	        l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));
         --FND_FILE.PUT_LINE(FND_FILE.LOG, 'Po ' || t_qty(j) || ' tp ' || t_tp_qty(j)
         --|| 'date ' || t_key_date(j));
          log_message( 'Po ' || t_qty(j) || ' tp ' || t_tp_qty(j) || 'date ' || t_key_date(j));
 	   	insert into msc_sup_dem_entries (
            	transaction_id,
            	plan_id,
            	sr_instance_id,
            	publisher_name,
            	publisher_id,
            	publisher_site_name,
            	publisher_site_id,
            	customer_name,
            	customer_id,
            	customer_site_name,
            	customer_site_id,
            	supplier_name,
            	supplier_id,
            	supplier_site_name,
            	supplier_site_id,
            	ship_from_party_name,
            	ship_from_party_id,
            	ship_from_party_site_name,
            	ship_from_party_site_id,
            	ship_to_party_name,
            	ship_to_party_id,
            	ship_to_party_site_name,
            	ship_to_party_site_id,
            	publisher_order_type,
            	publisher_order_type_desc,
            	bucket_type_desc,
            	bucket_type,
            	inventory_item_id,
            	item_name,
            	owner_item_name,
            	customer_item_name,
            	supplier_item_name,
            	item_description,
            	owner_item_description,
            	customer_item_description,
            	supplier_item_description,
            	primary_uom,
            	uom_code,
            	tp_uom_code,
            	key_date,
            	ship_date,
            	receipt_date,
            	quantity,
            	primary_quantity,
            	tp_quantity,
            	last_refresh_number,
            	posting_party_name,
            	posting_party_id,
            	created_by,
            	creation_date,
            	last_updated_by,
            	last_update_date,
            	project_number,
            	task_number,
            	planning_group,
            	planner_code,
            	version,
            	designator,
            	base_item_id,
            	base_item_name
         	) values (
         	msc_sup_dem_entries_s.nextval,
         	-1,
         	-1,
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	t_supp(j),
         	t_supp_id(j),
         	t_supp_site(j),
         	t_supp_site_id(j),
         	t_supp(j),
         	t_supp_id(j),
         	t_supp_site(j),
         	t_supp_site_id(j),
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	CP_PURCHASE_ORDER_FROM_PLAN,
         	l_order_type_desc,
 		      l_bucket_type_desc,
          t_bucket_type(j),
         	t_item_id(j),
         	t_master_item_name(j),
         	t_owner_item_name(j),
         	t_owner_item_name(j),
         	t_supp_item_name(j),
         	nvl(t_master_item_desc(j), t_owner_item_desc(j)),
         	t_owner_item_desc(j),
         	t_owner_item_desc(j),
         	t_supp_item_desc(j),
         	t_uom_code(j),
         	t_uom_code(j),
         	t_tp_uom(j),
         	t_key_date(j),
         	t_ship_date(j),
         	t_receipt_date(j),
         	t_qty(j),
         	t_qty(j),
         	t_tp_qty(j),
         	msc_cl_refresh_s.nextval,
         	t_pub(j),
         	t_pub_id(j),
         	nvl(p_user_id,-1),
         	sysdate,
         	nvl(p_user_id,-1),
         	sysdate,
         	t_proj_number(j),
         	t_task_number(j),
         	t_planning_gp(j),
         	t_planner_code(j),
         	p_version,
         	p_designator,
         	t_base_item_id(j),
         	t_base_item_name(j));

           -- added to publish PIS to CP as PIS

       ELSIF (t_order_type(j) = EXPECTED_INBOUND_SHIPMENT) THEN

         	---------------------------------------------------------
         	-- EXPECTED_INBOUND_SHIPMENT (PLANNED_INBOUND_SHIPMENT)
         	---------------------------------------------------------

  		 l_order_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',CP_PLANNED_INBOUND_SHIPMENT);
  	        l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));
  	    IF ( t_planned_order_qty(j) <> 0 ) THEN
  	      	l_planned_order_qty := t_planned_order_qty(j);
  	      	l_tp_planned_order_qty := t_tp_planned_order_qty(j);

 	        IF (t_planned_order_qty(j) < 0 ) THEN
 	        	l_planned_order_qty := 0;
 	        	l_tp_planned_order_qty := 0;
 	        END IF;
            log_message('PIS ' || t_planned_order_qty(j) || ' tp ' || t_tp_planned_order_qty(j) || ' date  ' || t_key_date(j));

   		insert into msc_sup_dem_entries (
              	transaction_id,
              	plan_id,
              	sr_instance_id,
              	publisher_name,
              	publisher_id,
              	publisher_site_name,
              	publisher_site_id,
              	customer_name,
              	customer_id,
              	customer_site_name,
              	customer_site_id,
              	supplier_name,
              	supplier_id,
              	supplier_site_name,
              	supplier_site_id,
              	ship_from_party_name,
              	ship_from_party_id,
              	ship_from_party_site_name,
              	ship_from_party_site_id,
              	ship_to_party_name,
              	ship_to_party_id,
              	ship_to_party_site_name,
              	ship_to_party_site_id,
              	publisher_order_type,
              	publisher_order_type_desc,
              	bucket_type_desc,
              	bucket_type,
              	inventory_item_id,
              	item_name,
              	owner_item_name,
              	customer_item_name,
              	supplier_item_name,
              	item_description,
              	owner_item_description,
              	customer_item_description,
              	supplier_item_description,
              	primary_uom,
              	uom_code,
              	tp_uom_code,
              	key_date,
              	ship_date,
              	receipt_date,
              	quantity,
              	primary_quantity,
              	tp_quantity,
              	last_refresh_number,
              	posting_party_name,
              	posting_party_id,
              	created_by,
              	creation_date,
              	last_updated_by,
              	last_update_date,
              	project_number,
              	task_number,
              	planning_group,
              	planner_code,
              	version,
              	designator,
              	base_item_id,
              	base_item_name
           	) values (
           	msc_sup_dem_entries_s.nextval,
           	-1,
           	-1,
           	t_pub(j),
           	t_pub_id(j),
           	t_pub_site(j),
           	t_pub_site_id(j),
           	t_pub(j),
           	t_pub_id(j),
           	t_pub_site(j),
           	t_pub_site_id(j),
           	t_supp(j),
           	t_supp_id(j),
           	t_supp_site(j),
           	t_supp_site_id(j),
           	t_supp(j),
           	t_supp_id(j),
           	t_supp_site(j),
           	t_supp_site_id(j),
           	t_pub(j),
           	t_pub_id(j),
           	t_pub_site(j),
           	t_pub_site_id(j),
           	CP_PLANNED_INBOUND_SHIPMENT,
           	l_order_type_desc,
                 l_bucket_type_desc,
           	t_bucket_type(j),
           	t_item_id(j),
           	t_master_item_name(j),
           	t_owner_item_name(j),
           	t_owner_item_name(j),
           	t_supp_item_name(j),
           	nvl(t_master_item_desc(j), t_owner_item_desc(j)),
           	t_owner_item_desc(j),
           	t_owner_item_desc(j),
           	t_supp_item_desc(j),
           	t_uom_code(j),
           	t_uom_code(j),
           	t_tp_uom(j),
           	t_key_date(j),
           	t_ship_date(j),
           	t_receipt_date(j),
           	l_planned_order_qty,
           	l_planned_order_qty,
           	l_tp_planned_order_qty,
           	msc_cl_refresh_s.nextval,
           	t_pub(j),
           	t_pub_id(j),
           	nvl(p_user_id,-1),
           	sysdate,
           	nvl(p_user_id,-1),
           	sysdate,
           	t_proj_number(j),
           	t_task_number(j),
           	t_planning_gp(j),
           	t_planner_code(j),
           	p_version,
         	p_designator,
         	t_base_item_id(j),
         	t_base_item_name(j));
            END IF;
         	----------------------------------------------------------
         	-- CP_RELEASED_INBOUND_SHIPMENT (qty released from PIS)
         	----------------------------------------------------------

         	l_order_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',CP_RELEASED_INBOUND_SHIPMENT);
  	        l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));
            IF (t_released_qty(j) <> 0 ) THEN
            	l_released_qty := t_released_qty(j);
            	l_tp_released_qty := t_tp_released_qty(j);
                IF (t_released_qty(j) < 0 ) THEN
                	l_released_qty := 0;
                	l_tp_released_qty := 0;
                END IF;
         	 log_message( 'released qty from PIS ' || t_released_qty(j) || ' tp ' || t_tp_released_qty(j) || 'date  ' || t_key_date(j));

  		insert into msc_sup_dem_entries (
  	        transaction_id,
            	plan_id,
            	sr_instance_id,
            	publisher_name,
            	publisher_id,
            	publisher_site_name,
            	publisher_site_id,
            	customer_name,
            	customer_id,
            	customer_site_name,
            	customer_site_id,
            	supplier_name,
            	supplier_id,
            	supplier_site_name,
            	supplier_site_id,
            	ship_from_party_name,
            	ship_from_party_id,
            	ship_from_party_site_name,
            	ship_from_party_site_id,
            	ship_to_party_name,
            	ship_to_party_id,
            	ship_to_party_site_name,
            	ship_to_party_site_id,
            	publisher_order_type,
            	publisher_order_type_desc,
            	bucket_type_desc,
            	bucket_type,
            	inventory_item_id,
            	item_name,
            	owner_item_name,
            	customer_item_name,
            	supplier_item_name,
            	item_description,
            	owner_item_description,
            	customer_item_description,
            	supplier_item_description,
            	primary_uom,
            	uom_code,
            	tp_uom_code,
            	key_date,
            	ship_date,
            	receipt_date,
            	quantity,
            	primary_quantity,
            	tp_quantity,
            	last_refresh_number,
            	posting_party_name,
            	posting_party_id,
            	created_by,
            	creation_date,
            	last_updated_by,
            	last_update_date,
            	project_number,
            	task_number,
            	planning_group,
            	planner_code,
            	version,
            	designator,
            	base_item_id,
            	base_item_name
         	) values (
         	msc_sup_dem_entries_s.nextval,
         	-1,
         	-1,
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	t_supp(j),
         	t_supp_id(j),
         	t_supp_site(j),
         	t_supp_site_id(j),
         	t_supp(j),
         	t_supp_id(j),
         	t_supp_site(j),
         	t_supp_site_id(j),
         	t_pub(j),
         	t_pub_id(j),
         	t_pub_site(j),
         	t_pub_site_id(j),
         	CP_RELEASED_INBOUND_SHIPMENT,
         	l_order_type_desc,
         	l_bucket_type_desc,
           	t_bucket_type(j),
         	t_item_id(j),
         	t_master_item_name(j),
         	t_owner_item_name(j),
         	t_owner_item_name(j),
         	t_supp_item_name(j),
         	nvl(t_master_item_desc(j), t_owner_item_desc(j)),
         	t_owner_item_desc(j),
         	t_owner_item_desc(j),
         	t_supp_item_desc(j),
         	t_uom_code(j),
         	t_uom_code(j),
         	t_tp_uom(j),
         	t_key_date(j),
         	t_ship_date(j),
         	t_receipt_date(j),
         	t_released_qty(j),
         	t_released_qty(j),
         	t_tp_released_qty(j),
         	msc_cl_refresh_s.nextval,
         	t_pub(j),
         	t_pub_id(j),
         	nvl(p_user_id,-1),
         	sysdate,
         	nvl(p_user_id,-1),
         	sysdate,
         	t_proj_number(j),
         	t_task_number(j),
         	t_planning_gp(j),
         	t_planner_code(j),
         	p_version,
         	p_designator,
         	t_base_item_id(j),
         	t_base_item_name(j));
         END IF;

      END IF;


      end if;
 END LOOP;

	-- break into 2 queries for performance purpose
        FORALL j in t_pub_id.FIRST..t_pub_id.LAST
 		update msc_sup_dem_entries
 		set quantity = 0, tp_quantity = 0, primary_quantity = 0
 		where publisher_order_type = CP_PLANNED_ORDER
 		and publisher_id = t_pub_id(j)
 		and publisher_site_id = t_pub_site_id(j)
 		and supplier_id = t_supp_id(j)
 		and supplier_site_id = t_supp_site_id(j)
 		and inventory_item_id = t_item_id(j)
 		and quantity < 0;


       FORALL j in t_pub_id.FIRST..t_pub_id.LAST
   		update msc_sup_dem_entries
   		set quantity = 0, tp_quantity = 0, primary_quantity = 0
   		where publisher_order_type = CP_RELEASED_PLANNED_ORDER
   		and publisher_id = t_pub_id(j)
   		and publisher_site_id = t_pub_site_id(j)
   		and supplier_id = t_supp_id(j)
   		and supplier_site_id = t_supp_site_id(j)
   		and inventory_item_id = t_item_id(j)
   		and quantity < 0;

   		  -- added for PIS

	    FORALL j in t_pub_id.FIRST..t_pub_id.LAST
 		  update msc_sup_dem_entries
 		  set quantity = 0, tp_quantity = 0, primary_quantity = 0
 		  where publisher_order_type = CP_PLANNED_INBOUND_SHIPMENT
 		  and publisher_id = t_pub_id(j)
 		  and publisher_site_id = t_pub_site_id(j)
 		  and supplier_id = t_supp_id(j)
 		  and supplier_site_id = t_supp_site_id(j)
 		  and inventory_item_id = t_item_id(j)
 		  and quantity < 0;


       FORALL j in t_pub_id.FIRST..t_pub_id.LAST
   		update msc_sup_dem_entries
   		set quantity = 0, tp_quantity = 0, primary_quantity = 0
   		where publisher_order_type = CP_RELEASED_INBOUND_SHIPMENT
   		and publisher_id = t_pub_id(j)
   		and publisher_site_id = t_pub_site_id(j)
   		and supplier_id = t_supp_id(j)
   		and supplier_site_id = t_supp_site_id(j)
   		and inventory_item_id = t_item_id(j)
   		and quantity < 0;

    ELSE
        l_log_message := get_message('MSC','MSC_X_PUB_NUM_RECORDS',p_language_code) || ': ' || 0;
        log_message(l_log_message);
    end if;
   end if;
 EXCEPTION
 	when others then
 		   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in insert_sup_dem_entries: ' || sqlerrm);
 		   log_message('Error ' || sqlerrm);
 		   --dbms_output.put_line('error ' || sqlerrm);
END insert_into_sup_dem;

/*=====================================================================================
| CP-SPP Integration                                                                  |
| Planned External Repair Order will be published as Order Forecast                   |
| Planned_Order_Def + ISO_Def will be publish as Returns Forecast                     |
| If user specify Publish Defective Outbound Shipment = YES , only then publish DOS   |
| ISO_Def =  Publish As Defective Outbound Shipment                                   |
=====================================================================================*/

PROCEDURE insert_into_sup_dem_rf_dos (
  t_pub                       IN companyNameList,
  t_pub_id                    IN numberList,
  t_pub_site                  IN companySiteList,
  t_pub_site_id               IN numberList,
  t_item_id                   IN numberList,
  t_order_type	      	      IN numberList,
  t_qty                       IN numberList,
  t_planned_order_qty	        IN numberList,
  t_released_qty	            IN numberList,
  t_supp                      IN companyNameList,
  t_supp_id                   IN numberList,
  t_supp_site                 IN companySiteList,
  t_supp_site_id              IN numberList,
  t_owner_item_name           IN itemNameList,
  t_owner_item_desc           IN itemDescList,
  t_base_item_id	            IN numberList,
  t_base_item_name	          IN itemNameList,
  t_base_item_desc	          IN itemDescList,
  t_proj_number               IN numberList,
  t_task_number               IN numberList,
  t_planning_gp               IN planningGroupList,
  t_uom_code                  IN itemUomList,
  t_planner_code              IN plannerCodeList,
  t_bucket_type               IN numberList,
  t_key_date                  IN dateList,
  t_ship_date                 IN dateList,
  t_receipt_date              IN dateList,
  t_order_num                 IN orderNumList, -- bug#7310179
  t_line_num                  IN lineNumList,  -- bug#7310179
  t_master_item_name          IN itemNameList,
  t_master_item_desc          IN itemDescList,
  t_supp_item_name            IN itemNameList,
  t_supp_item_desc            IN itemDescList,
  t_tp_uom                    IN itemUomList,
  t_tp_qty                    IN numberList,
  t_tp_planned_order_qty      IN numberList,
  t_tp_released_qty	          IN numberList,
  p_version                   IN varchar2,
  p_designator                IN varchar2,
  p_user_id                   IN number,
  p_language_code             IN varchar2,
  p_publish_dos               IN number
  ) IS

l_qty      NUMBER;
l_tp_qty   NUMBER;
l_order_type_desc     varchar2(80);
l_bucket_type_desc    varchar2(80);

BEGIN
-- RETURNS FORECAST
-- Key_Date = Receipt_date for INTRANSIT_SHIPMENT,INTRANSIT RECEIPT AND PLANNER_TRANSFER_DEF
--            and Ship_Date for ISO_DEF
-- DEFECTIVE OUTBOUND SHIPMENT
-- Key_Date =  Receipt_Date for INTRANSIT_SHIPMENT, INTRANSIT_RECEIPT and ship_date for ISO_DEF
-- Note : Ship_Date is null for INTRANSIT_SHIPMENT and INTRANSIT_RECEIPT if order is firmed.

IF t_pub_id is not null and t_pub_id.COUNT > 0 THEN
  FOR j in 1..t_pub_id.COUNT LOOP

     FND_FILE.PUT_LINE(FND_FILE.LOG,'Order Type : ' ||t_order_type(j) || '/qty : ' || t_qty(j)
                        || '/date : ' || t_key_date(j)   || '/Item : ' || t_item_id(j)
                        || '/base :' || t_base_item_id(j));

      IF (t_order_type(j) IN (PLANNED_TRANSFER_DEF,  ISO_DEF, INTRANSIT_SHIPMENT_DEF, INTRANSIT_RECEIPT_DEF) ) THEN -- RETURNS FORECAST
          IF ( t_qty(j) <> 0 ) THEN
          	 l_qty := t_qty(j);
          	 l_tp_qty := t_tp_qty(j);
          	 --=============
          	 IF (t_qty(j) < 0 ) THEN
          	 	  l_qty := 0;
          	 	  l_tp_qty := 0;
          	 END IF;
    		     --=============
    		     update msc_sup_dem_entries
    		     set quantity = quantity + l_qty,
    		         primary_quantity = primary_quantity + l_qty,
    		         tp_quantity = tp_quantity + l_tp_qty
    		     where publisher_id = t_pub_id(j)
    		     and publisher_site_id = t_pub_site_id(j)
    		     and supplier_id = t_supp_id(j)
    		     and supplier_site_id = t_supp_site_id(j)
    		     and inventory_item_id = t_item_id(j)
    		     and trunc(key_date) = DECODE(t_order_type(j),ISO_DEF,trunc(t_receipt_date(j)),trunc(t_key_date(j)))
    		     and publisher_order_type = RETURNS_FORECAST ;

             IF SQL%NOTFOUND THEN
               l_order_type_desc:=MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',RETURNS_FORECAST);
               l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));
               INSERT INTO msc_sup_dem_entries
               (transaction_id,
                plan_id,
                sr_instance_id,
                publisher_name,
                publisher_id,
                publisher_site_name,
                publisher_site_id,
                customer_name,
                customer_id,
                customer_site_name,
                customer_site_id,
                supplier_name,
                supplier_id,
                supplier_site_name,
                supplier_site_id,
                ship_from_party_name,
                ship_from_party_id,
                ship_from_party_site_name,
                ship_from_party_site_id,
                ship_to_party_name,
                ship_to_party_id,
                ship_to_party_site_name,
                ship_to_party_site_id,
                publisher_order_type,
                publisher_order_type_desc,
                bucket_type_desc,
                bucket_type,
                inventory_item_id,
                item_name,
                owner_item_name,
                customer_item_name,
                supplier_item_name,
                item_description,
                owner_item_description,
                customer_item_description,
                supplier_item_description,
                primary_uom,
                uom_code,
                tp_uom_code,
                key_date,
                ship_date,
                receipt_date,
                quantity,
                primary_quantity,
                tp_quantity,
                last_refresh_number,
                posting_party_name,
                posting_party_id,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                project_number,
                task_number,
                planning_group,
                planner_code,
                version,
                designator,
                base_item_id,
                base_item_name)
             VALUES(
             msc_sup_dem_entries_s.nextval,
             -1,
             -1,
             t_pub(j),
             t_pub_id(j),
             t_pub_site(j),
             t_pub_site_id(j),
             t_pub(j),
             t_pub_id(j),
             t_pub_site(j),
             t_pub_site_id(j),
             t_supp(j),
             t_supp_id(j),
             t_supp_site(j),
             t_supp_site_id(j),
             t_supp(j),
             t_supp_id(j),
             t_supp_site(j),
             t_supp_site_id(j),
             t_pub(j),
             t_pub_id(j),
             t_pub_site(j),
             t_pub_site_id(j),
             RETURNS_FORECAST,
             l_order_type_desc,
             l_bucket_type_desc,
             t_bucket_type(j),
             t_item_id(j),
             t_master_item_name(j),
             t_owner_item_name(j),
             t_owner_item_name(j),
             t_supp_item_name(j),
             nvl(t_master_item_desc(j),
             t_owner_item_desc(j)),
             t_owner_item_desc(j),
             t_owner_item_desc(j),
             t_supp_item_desc(j),
             t_uom_code(j),
             t_uom_code(j),
             t_tp_uom(j),
             DECODE(t_order_type(j),ISO_DEF,trunc(t_receipt_date(j)),trunc(t_key_date(j))),
             t_ship_date(j),
             t_receipt_date(j),
             l_qty,
             l_qty,
             l_tp_qty,
             msc_cl_refresh_s.nextval,
             t_pub(j),
             t_pub_id(j),
             nvl(p_user_id,   -1),
             sysdate,
             nvl(p_user_id,   -1),
             sysdate,
             t_proj_number(j),
             t_task_number(j),
             t_planning_gp(j),
             t_planner_code(j),
             p_version,
             p_designator,
             t_base_item_id(j),
             t_base_item_name(j));
           END IF; -- IF SQL%NOTFOUND

       -- Publish DOS Start (only when Publish Defective Outbound Shipment = YES in MSCXPO)
       IF (p_publish_dos = 1 AND ( t_order_type(j) IN (ISO_DEF, INTRANSIT_SHIPMENT_DEF, INTRANSIT_RECEIPT_DEF))) THEN

    		    update msc_sup_dem_entries
    		    set quantity = quantity + l_qty,
    		         primary_quantity = primary_quantity + l_qty,
    		         tp_quantity = tp_quantity + l_tp_qty
    		     where publisher_id = t_pub_id(j)
    		     and publisher_site_id = t_pub_site_id(j)
    		     and supplier_id = t_supp_id(j)
    		     and supplier_site_id = t_supp_site_id(j)
    		     and inventory_item_id = t_item_id(j)
    		     and trunc(key_date) = trunc(t_key_date(j))
    		     and order_number = t_order_num(j) -- bug#7310179
             and NVL(line_number,G_NULL_STRING) = NVL(t_line_num(j),G_NULL_STRING) -- bug#7310179
             and publisher_order_type = DEFECTIVE_OUTBOUND_SHIPMENT;

             IF SQL%NOTFOUND THEN
              l_order_type_desc:=MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_ORDER_TYPE',DEFECTIVE_OUTBOUND_SHIPMENT);
              l_bucket_type_desc := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_BUCKET_TYPE',t_bucket_type(j));
              INSERT INTO msc_sup_dem_entries
               (transaction_id,
                plan_id,
                sr_instance_id,
                publisher_name,
                publisher_id,
                publisher_site_name,
                publisher_site_id,
                customer_name,
                customer_id,
                customer_site_name,
                customer_site_id,
                supplier_name,
                supplier_id,
                supplier_site_name,
                supplier_site_id,
                ship_from_party_name,
                ship_from_party_id,
                ship_from_party_site_name,
                ship_from_party_site_id,
                ship_to_party_name,
                ship_to_party_id,
                ship_to_party_site_name,
                ship_to_party_site_id,
                publisher_order_type,
                publisher_order_type_desc,
                bucket_type_desc,
                bucket_type,
                inventory_item_id,
                item_name,
                owner_item_name,
                customer_item_name,
                supplier_item_name,
                item_description,
                owner_item_description,
                customer_item_description,
                supplier_item_description,
                primary_uom,
                uom_code,
                tp_uom_code,
                key_date,
                ship_date,
                receipt_date,
                quantity,
                primary_quantity,
                tp_quantity,
                last_refresh_number,
                posting_party_name,
                posting_party_id,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                order_number, -- bug#7310179
                line_number,  -- bug#7310179
                project_number,
                task_number,
                planning_group,
                planner_code,
                version,
                designator,
                base_item_id,
                base_item_name)
             VALUES(
             msc_sup_dem_entries_s.nextval,
             -1,
             -1,
             t_pub(j),
             t_pub_id(j),
             t_pub_site(j),
             t_pub_site_id(j),
             t_pub(j),
             t_pub_id(j),
             t_pub_site(j),
             t_pub_site_id(j),
             t_supp(j),
             t_supp_id(j),
             t_supp_site(j),
             t_supp_site_id(j),
             t_supp(j),
             t_supp_id(j),
             t_supp_site(j),
             t_supp_site_id(j),
             t_pub(j),
             t_pub_id(j),
             t_pub_site(j),
             t_pub_site_id(j),
             DEFECTIVE_OUTBOUND_SHIPMENT,
             l_order_type_desc,
             l_bucket_type_desc,
             t_bucket_type(j),
             t_item_id(j),
             t_master_item_name(j),
             t_owner_item_name(j),
             t_owner_item_name(j),
             t_supp_item_name(j),
             nvl(t_master_item_desc(j),
             t_owner_item_desc(j)),
             t_owner_item_desc(j),
             t_owner_item_desc(j),
             t_supp_item_desc(j),
             t_uom_code(j),
             t_uom_code(j),
             t_tp_uom(j),
             t_key_date(j),
             t_ship_date(j),
             t_receipt_date(j),
             l_qty,
             l_qty,
             l_tp_qty,
             msc_cl_refresh_s.nextval,
             t_pub(j),
             t_pub_id(j),
             nvl(p_user_id,   -1),
             sysdate,
             nvl(p_user_id,   -1),
             sysdate,
             t_order_num(j), -- bug#7310179
             t_line_num(j),  -- bug#7310179
             t_proj_number(j),
             t_task_number(j),
             t_planning_gp(j),
             t_planner_code(j),
             p_version,
             p_designator,
             t_base_item_id(j),
             t_base_item_name(j));
           END IF; -- IF SQL%NOTFOUND
         END IF; -- IF p_publish_dos = 1
      --Publish DOS End
        END IF; -- IF t_qty <> 0
      END IF; -- RETURNS FORECAST

  END LOOP; -- end FOR LOOP
END IF ; --t_pub_id.COUNT > 0

END insert_into_sup_dem_rf_dos; -- end of procedure insert_into_sup_dem_rf_dos



PROCEDURE delete_old_forecast(
  p_plan_id                 in number,
  p_org_id                  in number,
  p_sr_instance_id          in number,
  p_planner_code            in varchar2,
  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_planning_gp             in varchar2,
  p_project_id              in number,
  p_task_id                 in number,
  p_supplier_id      	    in number,
  p_supplier_site_id 	    in number,
  p_horizon_start	    in date,
  p_horizon_end		    in date,
  p_overwrite		    in number
) IS
  --t_publisher_site_id numberList;
  l_supplier_id       number;
  l_supplier_site_id  number;
  l_row			number;

BEGIN
  log_message('In delete_old_forecast');

  if p_supplier_id is not null then
   BEGIN
     select c.company_id
     into   l_supplier_id
     from   msc_trading_partner_maps m,
            msc_company_relationships r,
            msc_companies c
     where  m.tp_key = p_supplier_id and
            m.map_type = 1 and
            m.company_key = r.relationship_id and
            r.relationship_type = 2 and
            r.subject_id = 1 and
            c.company_id = r.object_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_supplier_id := NULL;
     WHEN OTHERS THEN
       l_supplier_id := NULL;
   END;
  else
    l_supplier_id := null;
  end if;

  log_message('l_supplier_id := ' || l_supplier_id);

  if p_supplier_site_id is not null then
   BEGIN
    select cs.company_site_id
    into   l_supplier_site_id
    from   msc_trading_partner_maps m,
           msc_company_sites cs
    where  m.tp_key = p_supplier_site_id and
           m.map_type = 3 and
           cs.company_site_id = m.company_key;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_supplier_site_id := null;
     WHEN OTHERS THEN
       l_supplier_site_id := null;
   END;
  else
    l_supplier_site_id := null;
  end if;

  log_message('l_supplier_site_id := ' || l_supplier_site_id);

  IF ( p_overwrite = 1) THEN			--delete all
     delete from msc_sup_dem_entries sd
     where  sd.publisher_order_type in (ORDER_FORECAST,CP_PLANNED_ORDER,
     		CP_PURCHASE_ORDER_FROM_PLAN,CP_RELEASED_PLANNED_ORDER,
		    CP_PLANNED_INBOUND_SHIPMENT, CP_RELEASED_INBOUND_SHIPMENT,
		    RETURNS_FORECAST,DEFECTIVE_OUTBOUND_SHIPMENT) and -- bug#6893383
         sd.plan_id = -1 and
         sd.publisher_id = 1 and
         exists (select cs.company_site_id
                                    from   msc_plan_organizations o,
                                           msc_company_sites cs,
                                           msc_trading_partner_maps m,
                                           msc_trading_partners p
                                    where  o.plan_id = p_plan_id
					   AND O.ORGANIZATION_ID = NVL(p_org_id , O.ORGANIZATION_ID)
					   AND O.SR_INSTANCE_ID = NVL(p_sr_instance_id , O.SR_INSTANCE_ID)
					   AND P.SR_TP_ID = O.ORGANIZATION_ID
					   AND P.SR_INSTANCE_ID = O.SR_INSTANCE_ID
                                           and p.partner_type = 3 and
                                           m.tp_key = p.partner_id and
                                           m.map_type = 2 and
                                           cs.company_site_id = m.company_key and
                                           cs.company_id = 1 and
					   cs.company_site_id = sd.publisher_site_id and rownum=1)  and
         sd.supplier_id = nvl(l_supplier_id, sd.supplier_id) and
         sd.supplier_site_id = nvl(l_supplier_site_id, sd.supplier_site_id) and
         exists (select nvl(i.base_item_id,i.inventory_item_id)
                                      from   msc_system_items i,
                                             msc_plan_organizations o
                                      where  o.plan_id = p_plan_id and
                                             i.plan_id = o.plan_id and
					     O.ORGANIZATION_ID = NVL(p_org_id , O.ORGANIZATION_ID) AND
					     O.SR_INSTANCE_ID = NVL(p_sr_instance_id , O.SR_INSTANCE_ID) AND
					     I.ORGANIZATION_ID =  O.ORGANIZATION_ID AND
					     I.SR_INSTANCE_ID =  O.SR_INSTANCE_ID AND
                                             NVL(i.planner_code,'-99') = NVL(p_planner_code,
                                                                 NVL(i.planner_code,'-99')) and
                                             NVL(i.abc_class_name,'-99') = NVL(p_abc_class,
                                                                 NVL(i.abc_class_name,'-99')) and
                                            i.inventory_item_id = nvl(p_item_id, i.inventory_item_id)
					    and NVL(sd.base_item_id, sd.inventory_item_id) =nvl(i.base_item_id,i.inventory_item_id) and
					    rownum=1   ) ;

     l_row := SQL%ROWCOUNT;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleted number records: ' || l_row);

  ELSIF ( p_overwrite = 2) THEN			--delete by overwritten
       delete from msc_sup_dem_entries sd
       where  sd.publisher_order_type IN (ORDER_FORECAST, CP_PLANNED_ORDER,
       			CP_PURCHASE_ORDER_FROM_PLAN, CP_RELEASED_PLANNED_ORDER,
			CP_PLANNED_INBOUND_SHIPMENT, CP_RELEASED_INBOUND_SHIPMENT,
			RETURNS_FORECAST,DEFECTIVE_OUTBOUND_SHIPMENT) and -- bug#6893383
           sd.plan_id = -1 and
           sd.publisher_id = 1 and
           exists (select cs.company_site_id
                                      from   msc_plan_organizations o,
                                             msc_company_sites cs,
                                             msc_trading_partner_maps m,
                                             msc_trading_partners p
                                      where  o.plan_id = p_plan_id and
                                             p.sr_tp_id = nvl(p_org_id, o.organization_id) and
                                             p.sr_instance_id = nvl(p_sr_instance_id,
                                                                    o.sr_instance_id) and
                                             p.partner_type = 3 and
                                             m.tp_key = p.partner_id and
                                             m.map_type = 2 and
                                             cs.company_site_id = m.company_key and
                                             cs.company_id = 1 and
					     sd.publisher_site_id = cs.company_site_id and
					     rownum=1)  and
           sd.supplier_id = nvl(l_supplier_id, sd.supplier_id) and
           sd.supplier_site_id = nvl(l_supplier_site_id, sd.supplier_site_id) and
           exists (select nvl(i.base_item_id,i.inventory_item_id)
                                      from   msc_system_items i,
                                             msc_plan_organizations o
                                      where  o.plan_id = p_plan_id and
                                             i.plan_id = o.plan_id and
                                             i.organization_id = nvl(p_org_id,
                                                                 o.organization_id) and
                                             i.sr_instance_id = nvl(p_sr_instance_id,
                                                                 o.sr_instance_id) and
                                             NVL(i.planner_code,'-99') = NVL(p_planner_code,
                                                                 NVL(i.planner_code,'-99')) and
                                             NVL(i.abc_class_name,'-99') = NVL(p_abc_class,
                                                                 NVL(i.abc_class_name,'-99')) and
                                            i.inventory_item_id = nvl(p_item_id, i.inventory_item_id) and
					    NVL(sd.base_item_id, sd.inventory_item_id) =nvl(i.base_item_id,i.inventory_item_id) and
					    rownum=1)  and
                   key_date between nvl(p_horizon_start, sysdate - 36500) and
           	nvl(p_horizon_end, sysdate + 36500);

       l_row := SQL%ROWCOUNT;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleted number records: ' || l_row);
  END IF;
  commit;

END delete_old_forecast;

PROCEDURE LOG_MESSAGE(
    p_string IN VARCHAR2
) IS
BEGIN
  IF ( g_msc_cp_debug= '1' OR g_msc_cp_debug = '2') THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, p_string);
  END IF;

EXCEPTION
  WHEN OTHERS THEn
     NULL;

END LOG_MESSAGE;

FUNCTION get_message (
  p_app  IN VARCHAR2,
  p_name IN VARCHAR2,
  p_lang IN VARCHAR2
) RETURN VARCHAR2 IS
  msg VARCHAR2(2000) := NULL;
  CURSOR c1(app_name VARCHAR2, msg_name VARCHAR2, lang VARCHAR2) IS
  SELECT m.message_text
  FROM   fnd_new_messages m,
         fnd_application a
  WHERE  m.message_name = msg_name AND
         m.language_code = lang AND
         a.application_short_name = app_name AND
         m.application_id = a.application_id;
BEGIN
  OPEN c1(p_app, p_name, p_lang);
  FETCH c1 INTO msg;
  IF (c1%NOTFOUND) then
    msg := p_name;
  END IF;
  CLOSE c1;
  RETURN msg;
END get_message;

END msc_sce_publish_pkg;

/
