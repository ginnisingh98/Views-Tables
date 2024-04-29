--------------------------------------------------------
--  DDL for Package Body MSC_SCE_PUB_SUPPLY_COMMIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SCE_PUB_SUPPLY_COMMIT_PKG" AS
/* $Header: MSCXPSCB.pls 120.4 2008/01/07 07:09:45 dejoshi ship $ */

G_SHIP_CONTROL              VARCHAR2(30);
G_ARRIVE_CONTROL            VARCHAR2(30);
G_CUSTOMER                  VARCHAR2(30) := 'BUYER';
G_SUPPLIER                  VARCHAR2(30) := 'SUPPLIER';
G_SUPPLY_COMMIT		    Number := 3;

PROCEDURE publish_supply_commits (
  p_errbuf                  out nocopy varchar2,
  p_retcode                 out nocopy varchar2,
  p_plan_id                 in number,
  p_org_code                in varchar2 default null,
  p_planner_code            in varchar2 default null,
  p_abc_class               in varchar2 default null,
  p_item_id                 in number   default null,
  p_planning_gp             in varchar2 default null,
  p_project_id              in number   default null,
  p_task_id                 in number   default null,
  p_source_customer_id      in number   default null,
  p_source_customer_site_id in number   default null,
  p_horizon_start           in varchar2,
  p_horizon_end             in varchar2,
  p_auto_version            in number   default 1,
  p_version                 in number   default null,
  p_include_so_flag         in number   default 2,
  p_overwrite		    in number
) IS

p_org_id                    Number;
p_inst_code                 Varchar2(3);
p_sr_instance_id            Number;
p_designator                Varchar2(10);
l_version                   Number;
l_new_version               Number;
l_user_id                   NUMBER;
l_user_name                 varchar2(100);
l_item_name                 VARCHAR2(255);
l_log_message               VARCHAR2(1000);
l_cust_name                 VARCHAR2(100);
l_cust_site                 VARCHAR2(30);
l_records_exist             NUMBER;
l_cursor1                   NUMBER;
l_language                  VARCHAR2(30);
l_language_code             VARCHAR2(4);

l_horizon_start	 	    date;		--canonical date
l_horizon_end		    date;		--canonical date

t_pub                       companyNameList;
t_pub_id                    numberList;
t_pub_site                  companySiteList;
t_pub_site_id               numberList;
t_item_id                   numberList;
t_base_item_id		    numberList;
t_qty                       numberList;
t_pub_ot                    numberList;
t_cust                      companyNameList;
t_cust_id                   numberList;
t_cust_site                 companySiteList;
t_cust_site_id              numberList;
t_ship_from                 companyNameList;
t_ship_from_id              numberList;
t_ship_from_site            companySiteList;
t_ship_from_site_id         numberList;
t_ship_to                   companyNameList;
t_ship_to_id                numberList;
t_ship_to_site              companySiteList;
t_ship_to_site_id           numberList;
t_bkt_type                  numberList;
t_posting_party_id          numberList;
t_item_name                 itemNameList;
t_item_desc                 itemDescList;
t_base_item_name	    itemNameList;
t_base_item_desc	    itemDescList;
t_pub_ot_desc               fndMeaningList;
t_proj_number               numberList;
t_task_number               numberList;
t_planning_gp               planningGroupList;
t_bkt_type_desc             fndMeaningList;
t_posting_party_name        companyNameList;
t_uom_code                  itemUomList;
t_planner_code              plannerCodeList;
t_ship_date                 dateList;
t_receipt_date              dateList;
t_key_date                  dateList;
t_shipping_control          shippingControlList;
t_src_cust_id               numberList;
t_src_cust_site_id          numberList;
t_src_org_id                numberList;
t_src_instance_id           numberList;

t_tp_item_name              itemNameList := itemNameList();
t_tp_uom                    itemUomList := itemUomList();
t_tp_qty                    numberList := numberList();
t_tp_receipt_date           dateList := dateList();
t_master_item_name          itemNameList := itemNameList();
t_master_item_desc          itemDescList := itemDescList();
t_cust_item_name            itemNameList := itemNameList();
t_cust_item_desc            itemDescList := itemDescList();


CURSOR supply_commits_c2 (
  p_plan_id                 in number,
  p_org_id                  in number,
  p_sr_instance_id          in number,
  p_horizon_start           in date,
  p_horizon_end             in date,
  p_planner_code            in varchar2,
  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_planning_gp             in varchar2,
  p_project_id              in number,
  p_task_id                 in number,
  p_source_customer_id      in number,
  p_source_customer_site_id in number,
  p_include_so_flag         in number,
  p_language_code           in varchar2
) IS
select c.company_name,             --publisher
       c.company_id,               --publisher id
       cs.company_site_name,       --publisher site
       cs.company_site_id,         --publisher site id
       nvl(item.base_item_id,item.inventory_item_id),     --inventory item id
       sum(mfp.allocated_quantity),              --quantity
       3,                          --publisher order type
       c1.company_name,            --customer name
       c1.company_id,              --customer id
       cs1.company_site_name,      --customer site
       cs1.company_site_id,        --customer site id
       c.company_name,             --ship from
       c.company_id,               --ship from id
       cs.company_site_name,       --ship from site
       cs.company_site_id,         --ship from site id
       c1.company_name,            --ship to
       c1.company_id,              --ship to id
       cs1.company_site_name,      --ship to site
       cs1.company_site_id,        --ship to site id
       mpb.bucket_type,            -- bucket type
       c.company_id,               --posting party id
       null,		--fcst.item_name,             --publisher item name
       null,		--fcst.description,           --publisher item desc
       'Supply commit',            --publisher order type desc
       NULL, -- dem.project_id,            --project number
       NULL, -- dem.task_id,               --task number
       NULL, -- dem.planning_group,        --planning group
       flv.meaning,                          -- bucket type description
       c.company_name,             --posting supplier name [Owner]
      item.uom_code,              --primary uom
      item.planner_code,          --planner code
      trunc(sup.new_schedule_date) ship_date,--mfp.supply_date ,   --ship_date
      (trunc(sup.new_schedule_date) + nvl(dem.intransit_lead_time,0)) receipt_date,  --receipt_date
       decode(upper(nvl(mtps.shipping_control, G_CUSTOMER)),
                      G_CUSTOMER, trunc(sup.new_schedule_date),
                                  (trunc(sup.new_schedule_date) + nvl(dem.intransit_lead_time,0))) key_date,
       upper(nvl(mtps.shipping_control, G_CUSTOMER)) shipping_control,
       dem.customer_id,           --Partner Id
       dem.customer_site_id,      --Partner Site Id
       dem.organization_id,       --Partner Org Id
       dem.sr_instance_id         --Partner Instance Id
from
       msc_demands dem,
       msc_system_items item,
       msc_company_sites cs,
       msc_company_sites cs1,
       msc_companies c,
       msc_companies c1,
       msc_trading_partner_maps m,
       msc_trading_partner_maps m1,
       msc_trading_partner_maps m2,
       msc_trading_partners t,
       msc_trading_partners t1,
       msc_trading_partner_sites mtps, --- PO_SHIP_DATE
       msc_company_relationships r,
       msc_plan_buckets  mpb,
       msc_full_pegging mfp,
       msc_supplies sup,
       fnd_lookup_values flv
where
/* msc_system_items msi pk:
        SR_INSTANCE_ID
        PLAN_ID
        ORGANIZATION_ID
        INVENTORY_ITEM_ID

  msc_trading_partners pk:
                PARTNER_ID
      unique Key
               SR_INSTANCE_ID
               SR_TP_ID
               PARTNER_TYPE

  msc_trading_partners.partner_type
        1 - Suppliers
        2 - Customers
        3 - Org

  msc_trading_partner_maps.map_type
        1 - Trading Partners
        2 - Planning Org
        3 - Site

  MAP_TYPE + TP_KEY is unique for MAP_TYPE = 2

  msc_company_sites pk:
              COMPANY_ID
              COMPANY_SITE_ID

  msc_companies pk:
              COMPANY_ID

  msc_trading_partners pk:
              PARTNER_ID
      unique Key
              SR_INSTANCE_ID
              SR_TP_ID
              PARTNER_TYPE
*/
       t.sr_tp_id = dem.organization_id and
       t.sr_instance_id = dem.sr_instance_id and
       t.partner_type = 3 and
       m.tp_key = t.partner_id and
       m.map_type = 2 and
/* Join with Company Site PK....  */
       m.company_key = cs.company_site_id and
/* Join Company Site with Company PK... */
       c.company_id = cs.company_id and
/*  driving Company from Customer info */
       t1.partner_id = dem.customer_id and
       t1.partner_type = 2 and
/* Partner map: MAP_TYPE + TP_KEY is unique for MAP_TYPE = 1 */
       m1.tp_key = t1.partner_id and
       m1.map_type = 1 and
/* Customer Map -> Company */
/* Object is customer of Subject   */
       m1.company_key = r.relationship_id and
       r.subject_id = c.company_id and
       r.object_id = c1.company_id and
       r.relationship_type = 1 and
/*  driving Company info from Customer Site */
       m2.tp_key = dem.customer_site_id and
       m2.map_type = 3 and
       cs1.company_site_id = m2.company_key and
       cs1.company_id = c1.company_id and
       dem.customer_site_id = mtps.partner_site_id and
/*  Outer Join for Customer Site  */
/*
       m2.tp_key (+) = dem.customer_site_id and
       m2.map_type (+) = 3 and
       cs1.company_site_id (+) = m2.company_key and
       nvl(cs1.company_id, c1.company_id) = c1.company_id
*/
/*   Filter conditions */
       dem.customer_id is not null and
       dem.customer_site_id is not null and
       dem.plan_id = p_plan_id and
       dem.organization_id = NVL(p_org_id, dem.organization_id) and
       dem.sr_instance_id = NVL(p_sr_instance_id, dem.sr_instance_id) and
       dem.customer_id = NVL(p_source_customer_id, dem.customer_id) and
       dem.customer_site_id = NVL(p_source_customer_site_id, dem.customer_site_id) and
       dem.inventory_item_id = dem.using_assembly_item_id and
       dem.origination_type in(6,7,8,9,11,29,30,42) and
       NVL(item.base_item_id, item.inventory_item_id)
             IN  (select nvl(i1.base_item_id,i1.inventory_item_id)
             	  from msc_system_items i1
                  where i1.inventory_item_id = nvl(p_item_id, i1.inventory_item_id )
                  and i1.organization_id = item.organization_id
                  and i1.plan_id = item.plan_id
                  and i1.sr_instance_id = item.sr_instance_id) and
       item.plan_id = dem.plan_id and
       item.sr_instance_id = dem.sr_instance_id and
       item.organization_id = dem.organization_id and
       item.inventory_item_id = dem.inventory_item_id and
       NVL(item.planner_code,'-99') = NVL(p_planner_code, NVL(item.planner_code,'-99')) and
       NVL(item.abc_class_name,'-99') = NVL(p_abc_class,NVL(item.abc_class_name,'-99')) and
       nvl(dem.planning_group, '-99') = nvl(p_planning_gp, nvl(dem.planning_group, '-99')) and
       nvl(dem.project_id,-99) = nvl(p_project_id, nvl(dem.project_id,-99)) and
       nvl(dem.task_id, -99) = nvl(p_task_id, nvl(dem.task_id, -99)) and
       (nvl(dem.dmd_satisfied_date,dem.using_assembly_demand_date) between nvl(p_horizon_start, nvl(dem.dmd_satisfied_date,dem.using_assembly_demand_date)) and nvl(p_horizon_end,nvl(dem.dmd_satisfied_date,dem.using_assembly_demand_date)))
       and (nvl(dem.dmd_satisfied_date,dem.using_assembly_demand_date) between mpb.bkt_start_date and mpb.bkt_end_date)
       and dem.origination_type <> decode(p_include_so_flag, 2, 6, -1)
       and dem.origination_type <> decode(p_include_so_flag, 2, 30, -1)
       and mpb.plan_id = dem.plan_id
       and mpb.sr_instance_id = dem.sr_instance_id
       and mpb.curr_flag = 1
       and flv.language = p_language_code
       and flv.lookup_type = 'MSC_X_BUCKET_TYPE'
       and flv.lookup_code = mpb.bucket_type
       and dem.plan_id = mfp.plan_id
       and dem.demand_id = mfp.demand_id
       and dem.sr_instance_id = mfp.sr_instance_id
       and mfp.pegging_id = mfp.end_pegging_id
       and sup.sr_instance_id = mfp.sr_instance_id
       and sup.plan_id = mfp.plan_id
       and sup.transaction_id = mfp.transaction_id
       and sup.order_type in (1,2,3,4,5,7,8,11,12,14,15,16,17,18,27,28,29,30)
GROUP BY c.company_name,             --publisher
       c.company_id,               --publisher id
       cs.company_site_name,       --publisher site
       cs.company_site_id,         --publisher site id
       nvl(item.base_item_id,item.inventory_item_id),     --inventory item id
--       dem.quantity,              --quantity
       3,                          --publisher order type
       c1.company_name,            --customer name
       c1.company_id,              --customer id
       cs1.company_site_name,      --customer site
       cs1.company_site_id,        --customer site id
       c.company_name,             --ship from
       c.company_id,               --ship from id
       cs.company_site_name,       --ship from site
       cs.company_site_id,         --ship from site id
       c1.company_name,            --ship to
       c1.company_id,              --ship to id
       cs1.company_site_name,      --ship to site
       cs1.company_site_id,        --ship to site id
       mpb.bucket_type,            --bucket type
       c.company_id,               --posting party id
       null,		--fcst.item_name,             --publisher item name
       null,		--fcst.description,           --publisher item desc
       'Supply commit',            --publisher order type desc
       NULL, -- dem.project_id,            --project number
       NULL, -- dem.task_id,               --task number
       NULL, -- dem.planning_group,        --planning group
       flv.meaning,                --bucket type desc
       c.company_name,             --posting supplier name [Owner]
       item.uom_code,              --primary uom
       item.planner_code,          --planner code
       trunc(sup.new_schedule_date) ,   --ship_date
      (trunc(sup.new_schedule_date) + nvl(dem.intransit_lead_time,0)),  --receipt_date
       decode(upper(nvl(mtps.shipping_control, G_CUSTOMER)),
	                      G_CUSTOMER, trunc(sup.new_schedule_date),
                                   (trunc(sup.new_schedule_date) + nvl(dem.intransit_lead_time,0))), --key_date
       upper(nvl(mtps.shipping_control, G_CUSTOMER)),   -- shipping_control
       dem.customer_id,           --Partner Id
       dem.customer_site_id,      --Partner Site Id
       dem.organization_id,       --Partner Org Id
       dem.sr_instance_id         --Partner Instance Id
       ;

CURSOR supply_commits_c1 (
  p_plan_id                 in number,
  p_org_id                  in number,
  p_sr_instance_id          in number,
  p_horizon_start           in date,
  p_horizon_end             in date,
  p_planner_code            in varchar2,
  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_planning_gp             in varchar2,
  p_project_id              in number,
  p_task_id                 in number,
  p_source_customer_id      in number,
  p_source_customer_site_id in number,
  p_include_so_flag         in number,
  p_language_code           in varchar2
) IS
select c.company_name,             --publisher
       c.company_id,               --publisher id
       cs.company_site_name,       --publisher site
       cs.company_site_id,         --publisher site id
       nvl(item.base_item_id,item.inventory_item_id),     --inventory item id
       SUM(fcst.quantity),              --quantity
       3,                          --publisher order type
       c1.company_name,            --customer name
       c1.company_id,              --customer id
       cs1.company_site_name,      --customer site
       cs1.company_site_id,        --customer site id
       c.company_name,             --ship from
       c.company_id,               --ship from id
       cs.company_site_name,       --ship from site
       cs.company_site_id,         --ship from site id
       c1.company_name,            --ship to
       c1.company_id,              --ship to id
       cs1.company_site_name,      --ship to site
       cs1.company_site_id,        --ship to site id
       mpb.bucket_type,            -- bucket type
       c.company_id,               --posting party id
       null,		--fcst.item_name,             --publisher item name
       null,		--fcst.description,           --publisher item desc
       'Supply commit',            --publisher order type desc
       NULL, -- fcst.project_id,            --project number
       NULL, -- fcst.task_id,               --task number
       NULL, -- fcst.planning_group,        --planning group
       flv.meaning,                          -- bucket type description
       c.company_name,             --posting supplier name [Owner]
       fcst.uom_code,              --primary uom
       fcst.planner_code,          --planner code --Bug 4424426
       fcst.dmd_satisfied_date ,   --ship_date
       fcst.planned_arrival_date,  --receipt_date
       decode(upper(nvl(mtps.shipping_control, G_CUSTOMER)),
                      G_CUSTOMER, fcst.dmd_satisfied_date,
                                  fcst.planned_arrival_date) key_date,
       upper(nvl(mtps.shipping_control, G_CUSTOMER)) shipping_control,
       fcst.customer_id,           --Partner Id
       fcst.customer_site_id,      --Partner Site Id
       fcst.organization_id,       --Partner Org Id
       fcst.sr_instance_id         --Partner Instance Id
from
       msc_constrained_forecast_v fcst,
       msc_system_items item,
       msc_company_sites cs,
       msc_company_sites cs1,
       msc_companies c,
       msc_companies c1,
       msc_trading_partner_maps m,
       msc_trading_partner_maps m1,
       msc_trading_partner_maps m2,
       msc_trading_partners t,
       msc_trading_partners t1,
       msc_trading_partner_sites mtps, --- PO_SHIP_DATE
       msc_company_relationships r,
       msc_plan_buckets  mpb,
       fnd_lookup_values flv
where
/* msc_system_items msi pk:
        SR_INSTANCE_ID
        PLAN_ID
        ORGANIZATION_ID
        INVENTORY_ITEM_ID

  msc_trading_partners pk:
                PARTNER_ID
      unique Key
               SR_INSTANCE_ID
               SR_TP_ID
               PARTNER_TYPE

  msc_trading_partners.partner_type
        1 - Suppliers
        2 - Customers
        3 - Org

  msc_trading_partner_maps.map_type
        1 - Trading Partners
        2 - Planning Org
        3 - Site

  MAP_TYPE + TP_KEY is unique for MAP_TYPE = 2

  msc_company_sites pk:
              COMPANY_ID
              COMPANY_SITE_ID

  msc_companies pk:
              COMPANY_ID

  msc_trading_partners pk:
              PARTNER_ID
      unique Key
              SR_INSTANCE_ID
              SR_TP_ID
              PARTNER_TYPE
*/
       t.sr_tp_id = fcst.organization_id and
       t.sr_instance_id = fcst.sr_instance_id and
       t.partner_type = 3 and
       m.tp_key = t.partner_id and
       m.map_type = 2 and
/* Join with Company Site PK....  */
       m.company_key = cs.company_site_id and
/* Join Company Site with Company PK... */
       c.company_id = cs.company_id and
/*  driving Company from Customer info */
       t1.partner_id = fcst.customer_id and
       t1.partner_type = 2 and
/* Partner map: MAP_TYPE + TP_KEY is unique for MAP_TYPE = 1 */
       m1.tp_key = t1.partner_id and
       m1.map_type = 1 and
/* Customer Map -> Company */
/* Object is customer of Subject   */
       m1.company_key = r.relationship_id and
       r.subject_id = c.company_id and
       r.object_id = c1.company_id and
       r.relationship_type = 1 and
/*  driving Company info from Customer Site */
       m2.tp_key = fcst.customer_site_id and
       m2.map_type = 3 and
       cs1.company_site_id = m2.company_key and
       cs1.company_id = c1.company_id and
       fcst.customer_site_id = mtps.partner_site_id and
/*  Outer Join for Customer Site  */
/*
       m2.tp_key (+) = fcst.customer_site_id and
       m2.map_type (+) = 3 and
       cs1.company_site_id (+) = m2.company_key and
       nvl(cs1.company_id, c1.company_id) = c1.company_id
*/
/*   Filter conditions */
       fcst.customer_id is not null and
       fcst.customer_site_id is not null and
       fcst.plan_id = p_plan_id and
       fcst.organization_id = NVL(p_org_id, fcst.organization_id) and
       fcst.sr_instance_id = NVL(p_sr_instance_id, fcst.sr_instance_id) and
       fcst.customer_id = NVL(p_source_customer_id, fcst.customer_id) and
       fcst.customer_site_id = NVL(p_source_customer_site_id, fcst.customer_site_id) and
       NVL(item.base_item_id, item.inventory_item_id)
             IN  (select nvl(i1.base_item_id,i1.inventory_item_id)
             	  from msc_system_items i1
                  where i1.inventory_item_id = nvl(p_item_id, i1.inventory_item_id )
                  and i1.organization_id = item.organization_id
                  and i1.plan_id = item.plan_id
                  and i1.sr_instance_id = item.sr_instance_id) and
       item.plan_id = fcst.plan_id and
       item.sr_instance_id = fcst.sr_instance_id and
       item.organization_id = fcst.organization_id and
       item.inventory_item_id = fcst.inventory_item_id and
       NVL(fcst.planner_code,'-99') = NVL(p_planner_code, NVL(fcst.planner_code,'-99')) and
       NVL(fcst.abc_class_name,'-99') = NVL(p_abc_class,NVL(fcst.abc_class_name,'-99')) and
       nvl(fcst.planning_group, '-99') = nvl(p_planning_gp, nvl(fcst.planning_group, '-99')) and
       nvl(fcst.project_id,-99) = nvl(p_project_id, nvl(fcst.project_id,-99)) and
       nvl(fcst.task_id, -99) = nvl(p_task_id, nvl(fcst.task_id, -99)) and
       fcst.end_date between nvl(p_horizon_start, fcst.end_date) and nvl(p_horizon_end, fcst.end_date)
       and fcst.origination_type <> decode(p_include_so_flag, 2, 6, -1)
       and fcst.origination_type <> decode(p_include_so_flag, 2, 30, -1)
       and mpb.plan_id = fcst.plan_id
       and mpb.sr_instance_id = fcst.sr_instance_id
       and mpb.curr_flag = 1
       and fcst.end_date between mpb.bkt_start_date and mpb.bkt_end_date
       and flv.language = p_language_code
       and flv.lookup_type = 'MSC_X_BUCKET_TYPE'
       and flv.lookup_code = mpb.bucket_type
GROUP BY c.company_name,             --publisher
       c.company_id,               --publisher id
       cs.company_site_name,       --publisher site
       cs.company_site_id,         --publisher site id
       nvl(item.base_item_id,item.inventory_item_id),     --inventory item id
--       fcst.quantity,              --quantity
       3,                          --publisher order type
       c1.company_name,            --customer name
       c1.company_id,              --customer id
       cs1.company_site_name,      --customer site
       cs1.company_site_id,        --customer site id
       c.company_name,             --ship from
       c.company_id,               --ship from id
       cs.company_site_name,       --ship from site
       cs.company_site_id,         --ship from site id
       c1.company_name,            --ship to
       c1.company_id,              --ship to id
       cs1.company_site_name,      --ship to site
       cs1.company_site_id,        --ship to site id
       mpb.bucket_type,            --bucket type
       c.company_id,               --posting party id
       null,		--fcst.item_name,             --publisher item name
       null,		--fcst.description,           --publisher item desc
       'Supply commit',            --publisher order type desc
       NULL, -- fcst.project_id,            --project number
       NULL, -- fcst.task_id,               --task number
       NULL, -- fcst.planning_group,        --planning group
       flv.meaning,                --bucket type desc
       c.company_name,             --posting supplier name [Owner]
       fcst.uom_code,              --primary uom
       fcst.planner_code,          --planner code --Bug 4424426
       fcst.dmd_satisfied_date ,   --ship_date
       fcst.planned_arrival_date,  --receipt_date
       decode(upper(nvl(mtps.shipping_control, G_CUSTOMER)),
	                      G_CUSTOMER, fcst.dmd_satisfied_date,
	                      fcst.planned_arrival_date), --key_date
       upper(nvl(mtps.shipping_control, G_CUSTOMER)),   -- shipping_control
       fcst.customer_id,           --Partner Id
       fcst.customer_site_id,      --Partner Site Id
       fcst.organization_id,       --Partner Org Id
       fcst.sr_instance_id         --Partner Instance Id
       ;
BEGIN
   print_debug_info('Just entered publish_supply_commits:');

   if fnd_global.conc_request_id > 0 then
      select
        fnd_global.user_id ,
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

  select compile_designator
  into   p_designator
  from   msc_plans
  where  plan_id = p_plan_id;

  BEGIN
  select  MEANING
    into  G_SHIP_CONTROL
    from  fnd_lookup_values
   where  LOOKUP_TYPE = 'MSC_X_SHIPPING_CONTROL'
     and  LOOKUP_CODE =2
     and  language = l_language_code;

  select  MEANING
    into  G_ARRIVE_CONTROL
    from  fnd_lookup_values
   where  LOOKUP_TYPE = 'MSC_X_SHIPPING_CONTROL'
     and  LOOKUP_CODE =1
     and  language = l_language_code;
  EXCEPTION
    WHEN OTHERS THEN
      G_SHIP_CONTROL := 'Ship';
      G_ARRIVE_CONTROL := 'Arrival';
  END;

  if p_org_code is not null then
    p_inst_code := substr(p_org_code,1,instr(p_org_code,':')-1);
    print_debug_info('p_inst_code := ' || p_inst_code);

    begin
    select instance_id
    into   p_sr_instance_id
    from   msc_apps_instances
    where  instance_code = p_inst_code;
    print_debug_info('p_sr_instance_id := ' || p_sr_instance_id);

    select sr_tp_id
    into   p_org_id
    from   msc_trading_partners
    where  organization_code = p_org_code and
           sr_instance_id = p_sr_instance_id and
           partner_type = 3 and
           company_id is null;
    print_debug_info('p_org_id := ' || p_org_id);
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

  l_log_message := get_message('MSC','MSC_X_PUB_SC',l_language_code) || ' ' || fnd_global.local_chr(10) ||
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

  IF p_source_customer_id IS NOT NULL THEN
     SELECT partner_name
       INTO l_cust_name
       FROM msc_trading_partners
       WHERE partner_id = p_source_customer_id;
     l_log_message := l_log_message || get_message('MSC','MSC_X_PUB_CUSTOMER',l_language_code) || ': ' || l_cust_name || fnd_global.local_chr(10);
  END IF;

  IF p_source_customer_site_id IS NOT NULL THEN
     SELECT location
       INTO l_cust_site
       FROM msc_trading_partner_sites
       WHERE partner_id = p_source_customer_id
       AND partner_site_id = p_source_customer_site_id
       AND tp_site_code = 'SHIP_TO';
     l_log_message := l_log_message || get_message('MSC','MSC_X_PUB_CUST_SITE',l_language_code) || ': ' || l_cust_site || fnd_global.local_chr(10);
  END IF;

  --------------------------------------------------------------------------
  -- set the standard date as canonical date
  --------------------------------------------------------------------------
  l_horizon_start := fnd_date.canonical_to_date(p_horizon_start);
  l_horizon_end := fnd_date.canonical_to_date(p_horizon_end);


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

  l_log_message := get_message('MSC','MSC_X_PUB_DEL_SC',l_language_code) || fnd_global.local_chr(10);
  log_message(l_log_message);

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
    p_source_customer_id,
    p_source_customer_site_id,
    l_horizon_start,
    l_horizon_end,
    p_overwrite
  );


     print_debug_info('p_plan_id := ' || p_plan_id);
     print_debug_info('p_org_id := ' || p_org_id);
     print_debug_info('p_sr_instance_id := ' || p_sr_instance_id);
     print_debug_info('p_horizon_start := ' || p_horizon_start);
     print_debug_info('p_horizon_end := ' || p_horizon_end);
     print_debug_info('p_planner_code := ' || p_planner_code);
     print_debug_info('p_include_so_flag := ' || p_include_so_flag);
     print_debug_info('p_item_id := ' || p_item_id);
     print_debug_info('p_source_customer_id := ' || p_source_customer_id);
     print_debug_info('p_source_customer_site_id := ' || p_source_customer_site_id);

-- bug#6345381
-- dejoshi

IF (nvl(FND_PROFILE.VALUE('MSC_PUBLISH_SUPPLY_COMMIT'),'N') = 'N') THEN
  OPEN supply_commits_c1 (
    p_plan_id
    ,p_org_id
    ,p_sr_instance_id
    ,l_horizon_start
    ,l_horizon_end
    ,p_planner_code
    ,p_abc_class
    ,p_item_id
    ,p_planning_gp
    ,p_project_id
    ,p_task_id
    ,p_source_customer_id
    ,p_source_customer_site_id
    ,p_include_so_flag
    ,l_language_code
  );

  FETCH supply_commits_c1 BULK COLLECT INTO
    t_pub
    ,t_pub_id
    ,t_pub_site
    ,t_pub_site_id
    ,t_item_id
    ,t_qty
    ,t_pub_ot
    ,t_cust
    ,t_cust_id
    ,t_cust_site
    ,t_cust_site_id
    ,t_ship_from
    ,t_ship_from_id
    ,t_ship_from_site
    ,t_ship_from_site_id
    ,t_ship_to
    ,t_ship_to_id
    ,t_ship_to_site
    ,t_ship_to_site_id
    ,t_bkt_type
    ,t_posting_party_id
    ,t_item_name
    ,t_item_desc
    ,t_pub_ot_desc
    ,t_proj_number
    ,t_task_number
    ,t_planning_gp
    ,t_bkt_type_desc
    ,t_posting_party_name
    ,t_uom_code
    ,t_planner_code
    ,t_ship_date
    ,t_receipt_date
    ,t_key_date
    ,t_shipping_control
    ,t_src_cust_id
    ,t_src_cust_site_id
    ,t_src_org_id
    ,t_src_instance_id;
  CLOSE supply_commits_c1;

     print_debug_info('New Records fetched by cursor := ' || t_pub.COUNT);
ELSE


   OPEN supply_commits_c2 (
    p_plan_id
    ,p_org_id
    ,p_sr_instance_id
    ,l_horizon_start
    ,l_horizon_end
    ,p_planner_code
    ,p_abc_class
    ,p_item_id
    ,p_planning_gp
    ,p_project_id
    ,p_task_id
    ,p_source_customer_id
    ,p_source_customer_site_id
    ,p_include_so_flag
    ,l_language_code
  );

  FETCH supply_commits_c2 BULK COLLECT INTO
    t_pub
    ,t_pub_id
    ,t_pub_site
    ,t_pub_site_id
    ,t_item_id
    ,t_qty
    ,t_pub_ot
    ,t_cust
    ,t_cust_id
    ,t_cust_site
    ,t_cust_site_id
    ,t_ship_from
    ,t_ship_from_id
    ,t_ship_from_site
    ,t_ship_from_site_id
    ,t_ship_to
    ,t_ship_to_id
    ,t_ship_to_site
    ,t_ship_to_site_id
    ,t_bkt_type
    ,t_posting_party_id
    ,t_item_name
    ,t_item_desc
    ,t_pub_ot_desc
    ,t_proj_number
    ,t_task_number
    ,t_planning_gp
    ,t_bkt_type_desc
    ,t_posting_party_name
    ,t_uom_code
    ,t_planner_code
    ,t_ship_date
    ,t_receipt_date
    ,t_key_date
    ,t_shipping_control
    ,t_src_cust_id
    ,t_src_cust_site_id
    ,t_src_org_id
    ,t_src_instance_id;
  CLOSE supply_commits_c2;
  print_debug_info('Used Supply_commits_cursor2 as the value of the profile is ' || FND_PROFILE.VALUE('MSC_PUBLISH_SUPPLY_COMMIT'));
END IF;
-- End of bug#6345381 changes
  IF t_pub IS NOT NULL AND t_pub.COUNT > 0 THEN
     print_debug_info('Records fetched by cursor := ' || t_pub.COUNT);
     l_log_message := get_message('MSC','MSC_X_PUB_NUM_RECORDS',l_language_code) || ': ' || t_pub.COUNT || '.' || fnd_global.local_chr(10);
     log_message(l_log_message);

    get_optional_info(
      t_item_id,
      t_pub_id,
      t_cust_id,
      t_cust_site_id,
      t_src_cust_id,
      t_src_cust_site_id,
      t_src_org_id,
      t_src_instance_id,
      t_item_name,
      t_uom_code,
      t_qty,
      t_receipt_date,
      t_tp_receipt_date,
      --t_tp_item_name,
      t_master_item_name,
      t_master_item_desc,
      t_cust_item_name,
      t_cust_item_desc,
      t_tp_uom,
      t_tp_qty,
      t_item_desc
    );

    -- check for the latest version, in case if another user has updated it
    IF p_auto_version = 1 THEN
      SELECT nvl(publish_supply_commit_version,0)+1 INTO l_new_version
        FROM msc_plans
	  	WHERE plan_id = p_plan_id;
	  IF l_version <> l_new_version THEN
	   	print_debug_info('Warning: Someone has already published supply commit with the version '||l_version||'. The new version is ' ||l_new_version);
	   	l_version := l_new_version;
	  END IF;
	END IF;

    print_debug_info('before insert_into_sup_dem');
    insert_into_sup_dem(
      t_pub
      ,t_pub_id
      ,t_pub_site
      ,t_pub_site_id
      ,t_item_id
      ,t_qty
      ,t_pub_ot
      ,t_cust
      ,t_cust_id
      ,t_cust_site
      ,t_cust_site_id
      ,t_ship_from
      ,t_ship_from_id
      ,t_ship_from_site
      ,t_ship_from_site_id
      ,t_ship_to
      ,t_ship_to_id
      ,t_ship_to_site
      ,t_ship_to_site_id
      ,t_bkt_type
      ,t_posting_party_id
      ,t_item_name
      ,t_item_desc
      ,t_master_item_name
      ,t_master_item_desc
      ,t_cust_item_name
      ,t_cust_item_desc
      ,t_pub_ot_desc
      ,t_proj_number
      ,t_task_number
      ,t_planning_gp
      ,t_bkt_type_desc
      ,t_posting_party_name
      ,t_uom_code
      ,t_planner_code
      ,t_ship_date
      ,t_receipt_date
      ,t_tp_item_name
      ,t_tp_uom
      ,t_tp_qty
      ,l_version
      ,p_designator
      ,l_user_id
      ,t_shipping_control
      ,t_key_date
    );
   ELSE
     l_cursor1 := 0;
  end if;
  commit;


  IF l_cursor1 = 0 THEN
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
          AND publisher_order_type = 3
          AND publisher_id = 1
          AND designator = p_designator
          AND version = l_version);
     EXCEPTION
   WHEN OTHERS then
     l_records_exist := 0;
     END;
     IF l_records_exist = 1 then
   l_log_message := get_message('MSC','MSC_X_PUB_NEW_VERSION_SC',l_language_code) || ' ' || l_version || '.' || fnd_global.local_chr(10);
   log_message(l_log_message);

	--update version number in msc_plans

	UPDATE msc_plans
	  SET publish_supply_commit_version = l_version
	  WHERE plan_id = p_plan_id;

     END IF;
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
                  	null,		--p_supplier_id,
                        null,		--p_supplier_site_id,
                        p_source_customer_id,
                        p_source_customer_site_id,
  			p_planner_code,
  			p_abc_class,
  			p_planning_gp,
  			p_project_id,
  			p_task_id,
                        G_SUPPLY_COMMIT);



 -- launch SCEM engine
    IF ( ( FND_PROFILE.VALUE('MSC_X_AUTO_SCEM_MODE') = 2
           OR FND_PROFILE.VALUE('MSC_X_AUTO_SCEM_MODE') = 3
         ) -- PUBLISH or ALL
         AND ( FND_PROFILE.VALUE('MSC_X_CONFIGURATION') = 2
               OR FND_PROFILE.VALUE('MSC_X_CONFIGURATION') = 3
             ) -- APS+CP or CP
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

-- add exception handler
EXCEPTION
   WHEN OTHERS THEN
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in msc_sce_pub_supply_commit_pkg.publish_supply_commits');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);

END publish_supply_commits;


PROCEDURE get_optional_info(
  t_item_id          	IN numberList,
  t_pub_id           	IN numberList,
  t_cust_id             IN numberList,
  t_cust_site_id        IN numberList,
  t_src_cust_id         IN numberList,
  t_src_cust_site_id    IN numberList,
  t_src_org_id          IN numberList,
  t_src_instance_id     IN numberList,
  t_item_name        	IN OUT NOCOPY itemNameList,
  t_uom_code         	IN itemUomList,
  t_qty              	IN numberList,
  t_receipt_date     	IN dateList,
  t_tp_receipt_date  	IN OUT NOCOPY dateList,
  --t_tp_item_name      IN OUT NOCOPY itemNameList,
  t_master_item_name    IN OUT NOCOPY itemNameList,
  t_master_item_desc    IN OUT NOCOPY itemDescList,
  t_cust_item_name      IN OUT NOCOPY itemNameList,
  t_cust_item_desc      IN OUT NOCOPY itemDescList,
  t_tp_uom           	IN OUT NOCOPY itemUomList,
  t_tp_qty           	IN OUT NOCOPY numberList,
  t_item_desc		IN OUT NOCOPY itemDescList
) IS

  l_conversion_found boolean;
  l_conversion_rate  number;
  l_to_location_id   number;
  l_org_location_id  number;
  l_lead_time        number;
  l_tp_cust_id       number;
  l_tp_cust_site_id  number;
  l_session_id number;
  l_regions_return_status VARCHAR2(1);

BEGIN

    for j in t_item_id.FIRST..t_item_id.LAST loop
      t_tp_receipt_date.EXTEND;
      --t_tp_item_name.EXTEND;
      t_tp_uom.EXTEND;
      t_tp_qty.EXTEND;
      t_master_item_name.EXTEND;
      t_master_item_desc.EXTEND;
      t_cust_item_name.EXTEND;
      t_cust_item_desc.EXTEND;
     /*-------------------------------------------------------------------------------
     get the item_description -- this works for both standard item or base item
     ---------------------------------------------------------------------------------*/
     begin
     	select	item_name, description
     	into	t_item_name(j), t_item_desc(j)
     	from	msc_system_items
     	where	sr_instance_id = t_src_instance_id(j)
     	and	organization_id = t_src_org_id(j)
     	and 	plan_id = -1
     	and	inventory_item_id = t_item_id(j);

     exception
     	when others then
     		t_item_name(j) := null;
     		t_item_desc(j) := null;
     end;


      begin
        select item_name,
               description
        into   t_master_item_name(j),
               t_master_item_desc(j)
        from   msc_items
        where  inventory_item_id = t_item_id(j);
      exception
        when others then
          t_master_item_name(j) := t_item_name(j);
          t_master_item_desc(j) := null;
      end;

      begin
        select customer_item_name,
               uom_code
        into   t_cust_item_name(j),
               t_tp_uom(j)
        from   msc_item_customers mcf,
               msc_trading_partner_maps m,
               msc_trading_partner_maps m2,
               msc_company_relationships r
        where  mcf.inventory_item_id = t_item_id(j) and
               r.relationship_type = 1 and
               r.subject_id = t_pub_id(j) and
               r.object_id = t_cust_id(j) and
               m.map_type = 1 and
               m.company_key = r.relationship_id and
               mcf.customer_id = m.tp_key and
               m2.map_type = 3 and
               m2.company_key = t_cust_site_id(j) and
               mcf.customer_site_id = m2.tp_key;
       exception
         when NO_DATA_FOUND then
           t_cust_item_name(j) := null;
           t_tp_uom(j) := t_uom_code(j);
       end;

       msc_x_util.get_uom_conversion_rates( t_uom_code(j),
                                            t_tp_uom(j),
                                            t_item_id(j),
                                            l_conversion_found,
                                            l_conversion_rate);
       if l_conversion_found then
         t_tp_qty(j) := nvl(t_qty(j),0)* l_conversion_rate;
       else
         t_tp_qty(j) := t_qty(j);
       end if;

     print_debug_info('Item id' || t_item_id(j));
     --print_debug_info('receipt date ' || t_tp_receipt_date(j));

   end loop;

-- added exception handler
EXCEPTION WHEN OTHERS THEN
   MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in msc_sce_pub_supply_commit_pkg.get_optional_info');
   MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);

END get_optional_info;


PROCEDURE insert_into_sup_dem (
  t_pub                       IN companyNameList,
  t_pub_id                    IN numberList,
  t_pub_site                  IN companySiteList,
  t_pub_site_id               IN numberList,
  t_item_id                   IN numberList,
  t_qty                       IN numberList,
  t_pub_ot                    IN numberList,
  t_cust                      IN companyNameList,
  t_cust_id                   IN numberList,
  t_cust_site                 IN companySiteList,
  t_cust_site_id              IN numberList,
  t_ship_from                 IN companyNameList,
  t_ship_from_id              IN numberList,
  t_ship_from_site            IN companySiteList,
  t_ship_from_site_id         IN numberList,
  t_ship_to                   IN companyNameList,
  t_ship_to_id                IN numberList,
  t_ship_to_site              IN companySiteList,
  t_ship_to_site_id           IN numberList,
  t_bkt_type                  IN numberList,
  t_posting_party_id          IN numberList,
  t_item_name                 IN itemNameList,
  t_item_desc                 IN itemDescList,
  t_master_item_name          IN itemNameList,
  t_master_item_desc          IN itemDescList,
  t_cust_item_name            IN itemNameList,
  t_cust_item_desc            IN itemDescList,
  t_pub_ot_desc               IN fndMeaningList,
  t_proj_number               IN numberList,
  t_task_number               IN numberList,
  t_planning_gp               IN planningGroupList,
  t_bkt_type_desc             IN fndMeaningList,
  t_posting_party_name        IN companyNameList,
  t_uom_code                  IN itemUomList,
  t_planner_code              IN plannerCodeList,
  t_ship_date                 IN dateList,
  t_receipt_date              IN dateList,
  t_tp_item_name              IN itemNameList,
  t_tp_uom                    IN itemUomList,
  t_tp_qty                    IN numberList,
  p_version                   IN varchar2,
  p_designator                IN VARCHAR2,
  p_user_id                   IN number,
  t_shipping_control          IN shippingControlList,
  t_key_date                  IN dateList
) IS
  l_order_type_desc  varchar2(80);
BEGIN

  BEGIN
    select meaning
    into   l_order_type_desc
    from   mfg_lookups
    where  lookup_type = 'MSC_X_ORDER_TYPE'
    and    lookup_code = 3;
  EXCEPTION
    WHEN OTHERS THEN
      l_order_type_desc := 'Supply commit';
  END;

   FORALL j in t_pub.FIRST..t_pub.LAST
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
           --publisher_item_name,
           --trading_partner_item_name,
           item_name,
           item_description,
           owner_item_name,
           owner_item_description,
           supplier_item_name,
           supplier_item_description,
           customer_item_name,
           customer_item_description,
           inventory_item_id,
           --pub_item_description,
           primary_uom,
           uom_code,
           tp_uom_code,
      key_date,
           ship_date,
           receipt_date,
	   shipping_control,
	   shipping_control_code,
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
   t_cust(j),
   t_cust_id(j),
   t_cust_site(j),
   t_cust_site_id(j),
        t_pub(j),
        t_pub_id(j),
        t_pub_site(j),
   t_pub_site_id(j),
   t_ship_from(j),
        t_ship_from_id(j),
        t_ship_from_site(j),
        t_ship_from_site_id(j),
        t_ship_to(j),
        t_ship_to_id(j),
        t_ship_to_site(j),
        t_ship_to_site_id(j),
        t_pub_ot(j),
        --t_pub_ot_desc(j),
        l_order_type_desc,
        t_bkt_type_desc(j),
        t_bkt_type(j),
        --t_item_name(j),
        --t_tp_item_name(j),
        t_master_item_name(j),
        nvl(t_master_item_desc(j), t_item_desc(j)),
        t_item_name(j),
        t_item_desc(j),
        t_item_name(j),
        t_item_desc(j),
        t_cust_item_name(j),
        t_cust_item_desc(j),
        t_item_id(j),
        --t_item_desc(j),
        t_uom_code(j),
        t_uom_code(j),
        t_tp_uom(j),
	t_key_date(j),
        t_ship_date(j),
        t_receipt_date(j),
	decode(t_shipping_control(j),G_CUSTOMER,G_SHIP_CONTROL,
	                          G_ARRIVE_CONTROL),
	decode(t_shipping_control(j),G_CUSTOMER,2,
	                          1),
        t_qty(j),
        t_qty(j),
        t_tp_qty(j),
        msc_cl_refresh_s.nextval,
        t_posting_party_name(j),
        t_posting_party_id(j),
        p_user_id,
        sysdate,
        p_user_id,
        sysdate,
        t_proj_number(j),
        t_task_number(j),
        t_planning_gp(j),
        t_planner_code(j),
        p_version,
        p_designator
        );

EXCEPTION
  WHEN OTHERS THEN
      print_user_info('Error in msc_sce_pub_supply_commit_pkg.insert_into_sup_dem');
      print_user_info(SQLERRM);
END insert_into_sup_dem;


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
  p_source_customer_id      in number,
  p_source_customer_site_id in number,
  p_horizon_start           in date,
  p_horizon_end             in date,
  p_overwrite		    in number
) IS
  --t_publisher_site_id numberList;
  l_customer_id       number;
  l_customer_site_id  number;
  l_row 		number;

BEGIN
  --print_debug_info('In delete_old_forecast');

  if p_source_customer_id is not null then
   BEGIN
     select c.company_id
     into   l_customer_id
     from   msc_trading_partner_maps m,
            msc_company_relationships r,
            msc_companies c
     where  m.tp_key = p_source_customer_id and
            m.map_type = 1 and
            m.company_key = r.relationship_id and
            r.relationship_type = 1 and
            r.subject_id = 1 and    /*  Owner Company Id */
            c.company_id = r.object_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_customer_id := NULL;
     WHEN OTHERS THEN
       l_customer_id := NULL;
   END;
  else
    l_customer_id := null;
  end if;

  --print_debug_info('l_customer_id := ' || l_customer_id);
--Bug 4116657..
  if p_source_customer_site_id is not null then
   BEGIN
    select cs.company_site_id
    into   l_customer_site_id
    from   msc_trading_partner_maps m,
           msc_company_sites cs
    where  m.tp_key = p_source_customer_site_id and
           m.map_type = 3 and
           cs.company_site_id = m.company_key;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_customer_site_id := null;
     WHEN OTHERS THEN
       l_customer_site_id := null;
   END;
  else
    l_customer_site_id := null;
  end if;

  --print_debug_info('l_customer_site_id := ' || l_customer_site_id);

  IF (p_overwrite = 1) THEN			-- delete all
  	delete from msc_sup_dem_entries sd
  	where  sd.publisher_order_type = 3 and
         sd.plan_id = -1 and
         sd.publisher_id = 1 and
         sd.publisher_site_id IN (select cs.company_site_id
                                    from   msc_plan_organizations o,
                                           msc_company_sites cs,
                                           msc_trading_partner_maps m,
                                           msc_trading_partners p
                                    where  o.plan_id = p_plan_id and
                                           p.sr_tp_id = nvl(p_org_id, o.organization_id) and
                                           p.sr_instance_id = nvl(p_sr_instance_id, o.sr_instance_id) and
                                           p.partner_type = 3 and
                                           m.tp_key = p.partner_id and
                                           m.map_type = 2 and
                                           cs.company_site_id = m.company_key and
                                           cs.company_id = 1)  and
         sd.customer_id = nvl(l_customer_id, sd.customer_id) and
         sd.customer_site_id = nvl(l_customer_site_id, sd.customer_site_id) and
         NVL(sd.base_item_id, sd.inventory_item_id) IN (select nvl(i.base_item_id,i.inventory_item_id)
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
                                            i.inventory_item_id = nvl(p_item_id, i.inventory_item_id))
                                          and
         NVL(sd.planner_code,'-99') = nvl(p_planner_code, NVL(sd.planner_code, '-99')) ; --bug 4344713
         --NVL(sd.planning_group,'-99') = nvl(p_planning_gp, NVL(sd.planning_group, '-99')) and
         --NVL(sd.project_number,'-99') = nvl(p_project_id, NVL(sd.project_number, '-99')) and
         --NVL(sd.task_number, '-99') = nvl(p_task_id, NVL(sd.task_number, '-99'));

         l_row := SQL%ROWCOUNT;
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleted number records: ' || l_row);

   ELSIF p_overwrite = 2 THEN
     	delete from msc_sup_dem_entries sd
     	where  sd.publisher_order_type = 3 and
            sd.plan_id = -1 and
            sd.publisher_id = 1 and
            sd.publisher_site_id IN (select cs.company_site_id
                                       from   msc_plan_organizations o,
                                              msc_company_sites cs,
                                              msc_trading_partner_maps m,
                                              msc_trading_partners p
                                       where  o.plan_id = p_plan_id and
                                              p.sr_tp_id = nvl(p_org_id, o.organization_id) and
                                              p.sr_instance_id = nvl(p_sr_instance_id, o.sr_instance_id) and
                                              p.partner_type = 3 and
                                              m.tp_key = p.partner_id and
                                              m.map_type = 2 and
                                              cs.company_site_id = m.company_key and
                                              cs.company_id = 1)  and
            sd.customer_id = nvl(l_customer_id, sd.customer_id) and
            sd.customer_site_id = nvl(l_customer_site_id, sd.customer_site_id) and
            NVL(sd.base_item_id, sd.inventory_item_id) IN (select nvl(i.base_item_id,i.inventory_item_id)
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
                                            i.inventory_item_id = nvl(p_item_id, i.inventory_item_id))  and
            NVL(sd.planner_code,'-99') = nvl(p_planner_code, NVL(sd.planner_code, '-99')) and --bug 4344713
            --NVL(sd.planning_group,'-99') = nvl(p_planning_gp, NVL(sd.planning_group, '-99')) and
            --NVL(sd.project_number,'-99') = nvl(p_project_id, NVL(sd.project_number, '-99')) and
            --NVL(sd.task_number, '-99') = nvl(p_task_id, NVL(sd.task_number, '-99')) and
            sd.ship_date between NVL(p_horizon_start, sd.ship_date) and NVL(p_horizon_end, sd.ship_date);

            l_row := SQL%ROWCOUNT;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleted number records: ' || l_row);
   END IF;

EXCEPTION
  WHEN OTHERS THEN
      print_user_info('Error in msc_sce_pub_supply_commit_pkg.delete_old_forecast');
      print_user_info(SQLERRM);
END delete_old_forecast;

PROCEDURE LOG_MESSAGE(
    p_string IN VARCHAR2
) IS
BEGIN
  IF fnd_global.conc_request_id > 0 THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, p_string);
  ELSE
     --DBMS_OUTPUT.PUT_LINE( p_string);
    null;
  END IF;
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

  -- This procesure prints out debug information
  PROCEDURE print_debug_info(
    p_debug_info IN VARCHAR2
  )IS

  g_msc_cp_debug VARCHAR2(10) := NVL(FND_PROFILE.VALUE('MSC_CP_DEBUG'), '0');

  BEGIN
    IF ( g_msc_cp_debug= '1' OR g_msc_cp_debug = '2') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, p_debug_info);
    END IF;
     --dbms_output.put_line(p_debug_info); -- ut
  EXCEPTION
  WHEN OTHERS THEN
     RAISE;
  END print_debug_info;

  -- This procesure prints out message to user
  PROCEDURE print_user_info(
    p_user_info IN VARCHAR2
  )IS
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, p_user_info);
    -- dbms_output.put_line(p_user_info); -- ut
  EXCEPTION
  WHEN OTHERS THEN
     RAISE;
  END print_user_info;

END msc_sce_pub_supply_commit_pkg;

/
