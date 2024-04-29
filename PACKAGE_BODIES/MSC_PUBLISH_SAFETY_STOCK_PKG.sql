--------------------------------------------------------
--  DDL for Package Body MSC_PUBLISH_SAFETY_STOCK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_PUBLISH_SAFETY_STOCK_PKG" AS
/* $Header: MSCXPSSB.pls 120.4 2006/05/23 10:47:23 pragarwa noship $ */

PROCEDURE publish_safety_stocks (
  p_errbuf                  out nocopy varchar2,
  p_retcode                 out nocopy number,   -- Bug 4560452
  p_plan_id                 in number,
  p_org_code                in varchar2,
  p_planner_code            in varchar2,
  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_planning_gp             in varchar2,
  p_project_id              in number,
  p_task_id                 in number,
  p_supplier_id             in number,
  p_supplier_site_id        in number,
  p_horizon_start           in varchar2,
  p_horizon_end             in varchar2,
  p_overwrite		    in number
) IS

p_org_id                    Number;
p_inst_code                 Varchar2(3);
p_sr_instance_id            Number;
p_category_set_id           Number;
p_category_name             Varchar2(240);
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

l_horizon_start	 	    date;		--canonical date
l_horizon_end		    date;		--canonical date

t_pub                       companyNameList;
t_pub_id                    numberList;
t_pub_site                  companySiteList;
t_pub_site_id               numberList;
t_customer		    companyNameList;
t_customer_id		    numberList;
t_customer_site		    companySiteList;
t_customer_site_id	    numberList;
t_org_id                    numberList;
t_sr_instance_id            numberList;
t_item_id                   numberList;
t_base_item_id		    numberList;
t_qty                       numberList;
t_pub_ot                    numberList;
t_bkt_type                  numberList;
t_posting_party_id          numberList;
t_item_name           	    itemNameList;
t_item_desc           	    itemDescList;
t_base_item_name	    itemNameList;
t_pub_ot_desc               fndMeaningList;
t_proj_number               numberList;
t_task_number               numberList;
t_planning_gp               planningGroupList;
t_bkt_type_desc             fndMeaningList;
t_posting_party_name        companyNameList;
t_uom_code                  itemUomList;
t_planner_code              plannerCodeList;
t_key_date                  dateList;
t_ship_date                 dateList;
t_receipt_date              dateList;
t_supp                      companyNameList;
t_supp_id                   numberList;
t_supp_site                 companySiteList;
t_supp_site_id              numberList;
t_master_item_name          itemNameList;
t_master_item_desc          itemDescList;
t_supp_item_name            itemNameList;
t_supp_item_desc            itemDescList;
t_type			    numberList;

t_days_in_bkt		    numberList;
t_bucket_type		    numberList;
t_period_start_date	    dateList;
t_bucket_index		    numberList;
t_bucket_start		    dateList;
t_bucket_end		    dateList;


b_bkt_index		    numberList;
b_bkt_start_date	    dateList;
b_bkt_end_date		    dateList;
b_bkt_type		    numberList;

--================================================================
--pab variable
--================================================================
a_pub                       companyNameList;
a_pub_id                    numberList;
a_pub_site                  companySiteList;
a_pub_site_id               numberList;
a_customer		    companyNameList;
a_customer_id		    numberList;
a_customer_site		    companySiteList;
a_customer_site_id	    numberList;
a_org_id                    numberList;
a_sr_instance_id            numberList;
a_pab_type		    numberList;
a_item_id                   numberList;
a_base_item_id		    numberList;
a_qty                       numberList;
a_pub_ot                    numberList;
a_bkt_type                  numberList;
a_posting_party_id          numberList;
a_item_name                 itemNameList;
a_item_desc                 itemDescList;
a_base_item_name	    itemNameList;
a_pub_ot_desc               fndMeaningList;
a_proj_number               numberList;
a_task_number               numberList;
a_planning_gp               planningGroupList;
a_bkt_type_desc             fndMeaningList;
a_posting_party_name        companyNameList;
a_uom_code                  itemUomList;
a_planner_code              plannerCodeList;
a_period_start_date	    dateList;
a_key_date                  dateList;
a_ship_date                 dateList;
a_receipt_date              dateList;
a_supp                      companyNameList;
a_supp_id                   numberList;
a_supp_site                 companySiteList;
a_supp_site_id              numberList;
a_master_item_name          itemNameList;
a_master_item_desc          itemDescList;
a_supp_item_name            itemNameList;
a_supp_item_desc            itemDescList;
a_type			    numberList;
a_total_qty		    numberList;
a_temp_qty		    numberList;
a_days_in_bkt		    numberList;
a_bucket_type		    numberList;
a_bucket_index		    numberList;
a_bucket_start		    dateList;
a_bucket_end		    dateList;



i_bkt_index		    numberList;
i_bkt_start_date	    dateList;
i_bkt_end_date		    dateList;
i_bkt_type		    numberList;


i			    number;
l_bucket_end_date	    msc_plan_buckets.bkt_end_date%type;
l_bucket_type		    msc_plan_buckets.bucket_type%type;
l_supply		    number;
l_demand	  	    number;
l_scrap_demand		    number;
l_exp_lot		    number;
l_onhand		    number;
l_expired_qty		    number;
l_pab_total		    number;


CURSOR safety_stock_c (
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
  p_supplier_id      	    in number,
  p_supplier_site_id 	    in number,
  p_overwrite		    in number
) IS


SELECT 	distinct mst.sr_instance_id,
	mst.organization_id,
	item.base_item_id,
	item.inventory_item_id,
	mst.period_start_date,
	mpb.bkt_start_date,
	mpb.bkt_end_date,
	mpb.days_in_bkt,
	mpb.bucket_type,
	mpb.bucket_index,
	c.company_id,
	c.company_name,
	s.company_site_id,
	s.company_site_name,
	item.item_name,
	item.description,
	null,		--base_item_name
	item.uom_code,
	item.planner_code, --Bug 4424426
	NULL,	--mst.planning_group,
	NULL,	--mst.project_id,
	NULL,	--mst.task_id,
	sum(mst.safety_stock_quantity)
FROM 	msc_safety_stocks mst,
	msc_plan_buckets mpb,
	msc_plan_organizations_v ov,
	msc_system_items item,
	msc_companies c,
	msc_company_sites s,
	msc_trading_partners t,
	msc_trading_partner_maps m,
	msc_plans p
WHERE 	p.plan_id = mst.plan_id
and	mst.plan_id = p_plan_id
and mst.organization_id = nvl(p_org_id, mst.organization_id)
and mst.sr_instance_id = nvl(p_sr_instance_id, mst.sr_instance_id)
and item.inventory_item_id = nvl(p_item_id, item.inventory_item_id)
and mst.plan_id = item.plan_id
and mst.sr_instance_id = item.sr_instance_id
and mst.organization_id = item.organization_id
and mst.inventory_item_id = item.inventory_item_id
and t.sr_tp_id = mst.organization_id
and t.sr_instance_id = mst.sr_instance_id
and t.partner_type = 3
and m.tp_key = t.partner_id
and m.map_type = 2
and s.company_site_id = m.company_key
and c.company_id = s.company_id
--and mst.safety_stock_quantity > 0
and NVL(item.planner_code,'-99') = NVL(p_planner_code, NVL(item.planner_code,'-99'))
and NVL(item.abc_class_name,'-99') = NVL(p_abc_class, NVL(item.abc_class_name,'-99'))
and mst.plan_id = ov.plan_id                         -- Bug# 3913477
and mst.organization_id =ov.planned_organization
and mst.sr_instance_id = ov.sr_instance_id
and mst.plan_id = mpb.plan_id
--and mst.organization_id = mpb.organization_id
and mst.sr_instance_id = mpb.sr_instance_id
and ov.plan_id = mpb.plan_id
and mpb.curr_flag = 1
and trunc(mst.period_start_date) between trunc(mpb.bkt_start_date) and trunc(mpb.bkt_end_date)
and nvl(mst.planning_group, '-99') = nvl(p_planning_gp, nvl(mst.planning_group, '-99'))
and nvl(mst.project_id,-99) = nvl(p_project_id, nvl(mst.project_id,-99))
and nvl(mst.task_id, -99) = nvl(p_task_id, nvl(mst.task_id, -99))
and p.plan_completion_date is not null
and trunc(mst.period_start_date) between nvl(trunc(p.plan_start_date),trunc(mst.period_start_date)) and
	nvl(trunc(p_horizon_end),trunc(mst.period_start_date))
GROUP BY
	mst.sr_instance_id,
	mst.organization_id,
	item.base_item_id,
	item.inventory_item_id,
	mst.period_start_date,
	mpb.bkt_start_date,
	mpb.bkt_end_date,
	mpb.days_in_bkt,
	mpb.bucket_type,
	mpb.bucket_index,
 	c.company_id,
	c.company_name,
	s.company_site_id,
	s.company_site_name,
 	item.item_name,
	item.description,
	null,
	item.uom_code,
	item.planner_code,--Bug 4424426
	NULL,	--mst.planning_group,
	NULL,	--mst.project_id,
	NULL	--mst.task_id
ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14;


CURSOR get_bucket_date (p_plan_id in number,
			p_sr_instance_id in number,
			p_org_id in number,
			p_horizon_start_date in date,
			p_horizon_end_date in date) IS
SELECT mpb.bucket_index, mpb.bkt_start_date, mpb.bkt_end_date, mpb.bucket_type
FROM	 msc_plan_buckets mpb,
         msc_plan_organizations_v ov       -- Bug# 3913477
WHERE	ov.plan_id = p_plan_id
  AND	ov.sr_instance_id = p_sr_instance_id
  AND	ov.planned_organization = p_org_id
  and   mpb.plan_id = ov.plan_id
  and   mpb.curr_flag = 1
  AND   bkt_start_date between nvl(p_horizon_start_date,mpb.bkt_start_date)
 	and nvl(p_horizon_end_date, mpb.bkt_end_date)
ORDER BY bucket_index;


------------------------------------------------------------------------------------
-- for the projected available balance
-- note: pab will start with plan completion date.  If the choose the future horizon date
-- you also need to start with the plan completion date for calculation
--------------------------------------------------------------------------------------------
CURSOR projected_availabe_balance_c (
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
  p_supplier_id      	    in number,
  p_supplier_site_id 	    in number,
  p_overwrite		    in number
) IS

SELECT  rec.sr_instance_id,
        rec.organization_id,
        msi.base_item_id,
        msi.inventory_item_id,
        trunc(rec.new_schedule_date),
	mpb.bkt_start_date,
	mpb.bkt_end_date,
	mpb.days_in_bkt,
	mpb.bucket_type,
	mpb.bucket_index,
        DECODE(rec.order_type,
        PURCHASE_ORDER, 	PAB_SUPPLY,
        PURCH_REQ, 		PAB_SUPPLY,
        WORK_ORDER,  		PAB_SUPPLY,
        FLOW_SCHED,   		PAB_SUPPLY,
        REPETITIVE_SCHEDULE, 	PAB_SUPPLY,
        PLANNED_ORDER, 		PAB_SUPPLY,
        NONSTD_JOB,     	PAB_SUPPLY,
        RECEIPT_PURCH_ORDER, 	PAB_SUPPLY,
        SHIPMENT,     		PAB_SUPPLY,
        RECEIPT_SHIPMENT,   	PAB_SUPPLY,
        DIS_JOB_BY,     	PAB_DEMAND,
        NON_ST_JOB_BY,  	PAB_DEMAND,
        REP_SCHED_BY,   	PAB_DEMAND,
        PLANNED_BY,  		PAB_DEMAND,
	FLOW_SCHED_BY, 		PAB_DEMAND,
        PAYBACK_SUPPLY, 	PAB_SUPPLY,
        ON_HAND_QTY, 		PAB_ONHAND,
        PAB_SUPPLY),
	c.company_id,
	c.company_name,
	s.company_site_id,
	s.company_site_name,
 	msi.item_name,
	msi.description,
	null,			---base item name
	msi.uom_code,
	msi.planner_code,--Bug 4424426
	NULL,	--rec.planning_group,
	NULL,	--rec.project_id,
	NULL,	--rec.task_id,
        SUM(DECODE(msi.base_item_id,NULL,
        	DECODE(rec.disposition_status_type,
            		2, 0,
            		DECODE(rec.last_unit_completion_date,
                    		NULL, rec.new_order_quantity, rec.daily_rate) *
           		DECODE(rec.order_type, DIS_JOB_BY, -1,
           				NON_ST_JOB_BY,  -1,
            				REP_SCHED_BY,   -1,
            				PLANNED_BY, -1,
					FLOW_SCHED_BY, -1,
					1)),
		DECODE(rec.last_unit_completion_date,
			NULL, rec.new_order_quantity, rec.daily_rate) *
           		DECODE(rec.order_type, DIS_JOB_BY, -1, NON_ST_JOB_BY,  -1,
                		REP_SCHED_BY,   -1, PLANNED_BY, -1,
                		FLOW_SCHED_BY, -1, 1))) new_quantity
FROM    msc_plans p,
	msc_trading_partners param,
        msc_system_items msi,
        msc_supplies rec,
        msc_plan_buckets mpb,
	msc_plan_organizations_v ov,
	msc_companies c,
	msc_company_sites s,
	msc_trading_partners t,
	msc_trading_partner_maps m
WHERE   p.plan_id = p_plan_id
AND	p.plan_id = msi.plan_id
AND     msi.inventory_item_id = nvl(p_item_id, msi.inventory_item_id)
AND     msi.organization_id = nvl(p_org_id, msi.organization_id)
AND     msi.sr_instance_id = nvl(p_sr_instance_id, msi.sr_instance_id)
AND	NVL(msi.planner_code,'-99') = NVL(p_planner_code, NVL(msi.planner_code,'-99'))
AND 	NVL(msi.abc_class_name,'-99') = NVL(p_abc_class, NVL(msi.abc_class_name,'-99'))
AND     param.sr_tp_id = rec.organization_id
AND     param.sr_instance_id = rec.sr_instance_id
AND     param.partner_type = 3
AND	rec.plan_id = msi.plan_id
AND     rec.inventory_item_id = msi.inventory_item_id
AND     rec.organization_id = msi.organization_id
AND     rec.sr_instance_id = msi.sr_instance_id
AND 	t.sr_tp_id = rec.organization_id
AND 	t.sr_instance_id = rec.sr_instance_id
AND 	t.partner_type = 3
AND 	m.tp_key = t.partner_id
AND 	m.map_type = 2
AND 	s.company_site_id = m.company_key
AND 	c.company_id = s.company_id
AND 	nvl(rec.planning_group, '-99') = nvl(p_planning_gp, nvl(rec.planning_group, '-99'))
AND 	nvl(rec.project_id,-99) = nvl(p_project_id, nvl(rec.project_id,-99))
AND 	nvl(rec.task_id, -99) = nvl(p_task_id, nvl(rec.task_id, -99))
AND     rec.plan_id = ov.plan_id                --- bug# 4106955
AND     rec.organization_id =ov.planned_organization
AND     rec.sr_instance_id = ov.sr_instance_id
AND 	rec.plan_id = mpb.plan_id
AND	rec.plan_id = p.plan_id
--AND 	rec.organization_id = mpb.organization_id     --- bug# 4106955
AND 	rec.sr_instance_id = mpb.sr_instance_id
AND     ov.plan_id = mpb.plan_id
AND     mpb.curr_flag = 1
AND 	trunc(rec.new_schedule_date) between trunc(mpb.bkt_start_date) and trunc(mpb.bkt_end_date)
AND 	p.plan_completion_date is not null
AND     trunc(rec.new_schedule_date) BETWEEN nvl(trunc(p.plan_start_date), trunc(rec.new_schedule_date)) and
	nvl(trunc(p_horizon_end), trunc(rec.new_schedule_date))
GROUP BY
	rec.sr_instance_id,
        rec.organization_id ,
        msi.base_item_id,
        msi.inventory_item_id,
        rec.new_schedule_date,
	mpb.bkt_start_date,
	mpb.bkt_end_date,
	mpb.days_in_bkt,
	mpb.bucket_type,
	mpb.bucket_index,
       DECODE(rec.order_type,
        PURCHASE_ORDER, PAB_SUPPLY,
        PURCH_REQ, 	PAB_SUPPLY,
        WORK_ORDER,  	PAB_SUPPLY,
        FLOW_SCHED,  	PAB_SUPPLY,
        REPETITIVE_SCHEDULE, PAB_SUPPLY,
        PLANNED_ORDER,  PAB_SUPPLY,
        NONSTD_JOB,     PAB_SUPPLY,
        RECEIPT_PURCH_ORDER, PAB_SUPPLY,
        SHIPMENT,     	PAB_SUPPLY,
        RECEIPT_SHIPMENT,   PAB_SUPPLY,
        DIS_JOB_BY,     PAB_DEMAND,
        NON_ST_JOB_BY,  PAB_DEMAND,
        REP_SCHED_BY,   PAB_DEMAND,
        PLANNED_BY,  	PAB_DEMAND,
	FLOW_SCHED_BY, 	PAB_DEMAND,
        PAYBACK_SUPPLY, PAB_SUPPLY,
        ON_HAND_QTY, 	PAB_ONHAND,
        PAB_SUPPLY),
	c.company_id,
	c.company_name,
	s.company_site_id,
	s.company_site_name,
 	msi.item_name,
	msi.description,
	null,			--base item name
	msi.uom_code,
	msi.planner_code, --Bug 4424426
	NULL,	--rec.planning_group,
	NULL,	--rec.project_id,
	NULL	--rec.task_id

UNION ALL
SELECT
	mgr.sr_instance_id,
        mgr.organization_id,
        msi.base_item_id,
        msi.inventory_item_id,
        trunc(mgr.using_assembly_demand_date),
	mpb.bkt_start_date,
	mpb.bkt_end_date,
	mpb.days_in_bkt,
	mpb.bucket_type,
	mpb.bucket_index,
	decode (mgr.origination_type, 1, PAB_DEMAND,2,PAB_DEMAND,3,PAB_DEMAND,
	4,PAB_DEMAND,5,PAB_EXP_LOT,6,PAB_DEMAND,7,PAB_DEMAND,8,PAB_DEMAND,
	9,PAB_DEMAND,10,PAB_DEMAND,11,PAB_DEMAND,12,PAB_DEMAND,
  	15,PAB_DEMAND,16,PAB_SCRAP_DEMAND,17,PAB_SCRAP_DEMAND,18,PAB_SCRAP_DEMAND,
  	19,PAB_SCRAP_DEMAND,20,PAB_SCRAP_DEMAND,21,PAB_SCRAP_DEMAND,22,PAB_DEMAND,
  	23,PAB_SCRAP_DEMAND,24,PAB_DEMAND,25,PAB_DEMAND,26,PAB_SCRAP_DEMAND,
	29,PAB_DEMAND,30,PAB_DEMAND,DEMAND_PAYBACK,PAB_DEMAND,
  	PAB_DEMAND),
	c.company_id,
	c.company_name,
	s.company_site_id,
	s.company_site_name,
 	msi.item_name,
	msi.description,
	null,			---base item name
	msi.uom_code,
	msi.planner_code,--Bug 4424426
	NULL,	--mgr.planning_group,
	NULL,	--mgr.project_id,
	NULL,	--mgr.task_id,
	SUM(DECODE(mgr.assembly_demand_comp_date,
            NULL, DECODE(mgr.origination_type,
                        29,(nvl(mgr.probability,1)*using_requirement_quantity),
                        31, 0,
                        using_requirement_quantity),
            DECODE(mgr.origination_type,
                   29,(nvl(mgr.probability,1)*daily_demand_rate),
                   31, 0,
                   daily_demand_rate)))/
        DECODE(nvl(LEAST(SUM(DECODE(mgr.origination_type,
                                    29,nvl(mgr.probability,0),
                                    null)) ,1) ,1),
               0,1,
               nvl(LEAST(SUM(DECODE(mgr.origination_type,
                                    29,nvl(mgr.probability,0),
                                    null)) ,1) ,1)) new_quantity
FROM    msc_plans p,
	msc_trading_partners param,
	msc_system_items msi,
        msc_demands  mgr,
        msc_plan_buckets mpb,
	msc_plan_organizations_v ov,
	msc_companies c,
	msc_company_sites s,
	msc_trading_partners t,
	msc_trading_partner_maps m
WHERE   p.plan_id = p_plan_id
AND	p.plan_id = mgr.plan_id
AND     msi.inventory_item_id = nvl(p_item_id, msi.inventory_item_id )
AND     mgr.organization_id = nvl(p_org_id, mgr.organization_id)
AND     mgr.sr_instance_id = nvl(p_sr_instance_id, mgr.sr_instance_id)
AND	NVL(msi.planner_code,'-99') = NVL(p_planner_code, NVL(msi.planner_code,'-99'))
AND 	NVL(msi.abc_class_name,'-99') = NVL(p_abc_class, NVL(msi.abc_class_name,'-99'))
AND     param.sr_tp_id = mgr.organization_id
AND     param.sr_instance_id = mgr.sr_instance_id
AND     param.partner_type = 3
AND	mgr.plan_id = msi.plan_id
AND     mgr.inventory_item_id = msi.inventory_item_id
AND     mgr.organization_id = msi.organization_id
AND     mgr.sr_instance_id = msi.sr_instance_id
AND 	t.sr_tp_id = mgr.organization_id
AND 	t.sr_instance_id = mgr.sr_instance_id
AND 	t.partner_type = 3
AND 	m.tp_key = t.partner_id
AND 	m.map_type = 2
AND 	s.company_site_id = m.company_key
AND 	c.company_id = s.company_id
AND 	nvl(mgr.planning_group, '-99') = nvl(p_planning_gp, nvl(mgr.planning_group, '-99'))
AND 	nvl(mgr.project_id,-99) = nvl(p_project_id, nvl(mgr.project_id,-99))
AND 	nvl(mgr.task_id, -99) = nvl(p_task_id, nvl(mgr.task_id, -99))
AND     mgr.plan_id = ov.plan_id                  -- Bug# 3913477
AND     mgr.organization_id =ov.planned_organization
AND     mgr.sr_instance_id = ov.sr_instance_id
AND 	mgr.plan_id = mpb.plan_id
AND	mgr.plan_id = p.plan_id
--AND 	mgr.organization_id = mpb.organization_id
AND 	mgr.sr_instance_id = mpb.sr_instance_id
AND     ov.plan_id = mpb.plan_id
AND     mpb.curr_flag = 1
AND 	trunc(mgr.using_assembly_demand_date) between trunc(mpb.bkt_start_date) and trunc(mpb.bkt_end_date)
AND     p.plan_completion_date is not null
AND     trunc(mgr.using_assembly_demand_date) BETWEEN nvl(trunc(p.plan_start_date), trunc(mgr.using_assembly_demand_date))
AND	nvl(trunc(p_horizon_end), trunc(mgr.using_assembly_demand_date))
AND     not exists (
        select 'cancelled IR'
        from   msc_supplies mr
        where  mgr.origination_type in (30,6)
        and    mgr.disposition_id = mr.transaction_id
        and    mgr.plan_id = mr.plan_id
        and    mgr.sr_instance_id = mr.sr_instance_id
        and    mr.disposition_status_type = 2)
GROUP BY
        mgr.sr_instance_id,
        mgr.organization_id,
        msi.base_item_id,
        msi.inventory_item_id,
        mgr.using_assembly_demand_date,
	mpb.bkt_start_date,
	mpb.bkt_end_date,
	mpb.days_in_bkt,
	mpb.bucket_type,
	mpb.bucket_index,
	decode (mgr.origination_type, 1, PAB_DEMAND,2,PAB_DEMAND,3,PAB_DEMAND,
	4,PAB_DEMAND,5,PAB_EXP_LOT,6,PAB_DEMAND,7,PAB_DEMAND,8,PAB_DEMAND,
	9,PAB_DEMAND,10,PAB_DEMAND,11,PAB_DEMAND,12,PAB_DEMAND,
  	15,PAB_DEMAND,16,PAB_SCRAP_DEMAND,17,PAB_SCRAP_DEMAND,18,PAB_SCRAP_DEMAND,
  	19,PAB_SCRAP_DEMAND,20,PAB_SCRAP_DEMAND,21,PAB_SCRAP_DEMAND,22,PAB_DEMAND,
  	23,PAB_SCRAP_DEMAND,24,PAB_DEMAND, 25,PAB_DEMAND,26,PAB_SCRAP_DEMAND,
	29,PAB_DEMAND,30,PAB_DEMAND,DEMAND_PAYBACK,PAB_DEMAND,
  	PAB_DEMAND),
	c.company_id,
	c.company_name,
	s.company_site_id,
	s.company_site_name,
	msi.item_name,
	msi.description,
	null,
	msi.uom_code,
	msi.planner_code,--Bug 4424426
	NULL,	--mgr.planning_group,
	NULL,	--mgr.project_id,
	NULL	--mgr.task_id
UNION ALL
/*----------------------------------------------------------------------
  Bug# 3893860
  The following 2 select statement are added for the fix.  The
  fix will include the past due pab calculation
  That means will include all the data before the plan_start_date.
  There will be no join to msc_plan_buckets.
  ----------------------------------------------------------------------*/
SELECT  rec.sr_instance_id,
        rec.organization_id,
        msi.base_item_id,
        msi.inventory_item_id,
        trunc(rec.new_schedule_date),
	null,--mpb.bkt_start_date,
	null,--mpb.bkt_end_date,
	null,--mpb.days_in_bkt,
	null,--mpb.bucket_type,
	null,--mpb.bucket_index,
        DECODE(rec.order_type,
        PURCHASE_ORDER, 	PAB_SUPPLY,
        PURCH_REQ, 		PAB_SUPPLY,
        WORK_ORDER,  		PAB_SUPPLY,
        FLOW_SCHED,   		PAB_SUPPLY,
        REPETITIVE_SCHEDULE, 	PAB_SUPPLY,
        PLANNED_ORDER, 		PAB_SUPPLY,
        NONSTD_JOB,     	PAB_SUPPLY,
        RECEIPT_PURCH_ORDER, 	PAB_SUPPLY,
        SHIPMENT,     		PAB_SUPPLY,
        RECEIPT_SHIPMENT,   	PAB_SUPPLY,
        DIS_JOB_BY,     	PAB_DEMAND,
        NON_ST_JOB_BY,  	PAB_DEMAND,
        REP_SCHED_BY,   	PAB_DEMAND,
        PLANNED_BY,  		PAB_DEMAND,
	FLOW_SCHED_BY, 		PAB_DEMAND,
        PAYBACK_SUPPLY, 	PAB_SUPPLY,
        ON_HAND_QTY, 		PAB_ONHAND,
        PAB_SUPPLY),
	c.company_id,
	c.company_name,
	s.company_site_id,
	s.company_site_name,
 	msi.item_name,
	msi.description,
	null,			---base item name
	msi.uom_code,
	msi.planner_code,--Bug 4424426
	NULL,	--rec.planning_group,
	NULL,	--rec.project_id,
	NULL,	--rec.task_id,
        SUM(DECODE(msi.base_item_id,NULL,
        	DECODE(rec.disposition_status_type,
            		2, 0,
            		DECODE(rec.last_unit_completion_date,
                    		NULL, rec.new_order_quantity, rec.daily_rate) *
           		DECODE(rec.order_type, DIS_JOB_BY, -1,
           				NON_ST_JOB_BY,  -1,
            				REP_SCHED_BY,   -1,
            				PLANNED_BY, -1,
					FLOW_SCHED_BY, -1,
					1)),
		DECODE(rec.last_unit_completion_date,
			NULL, rec.new_order_quantity, rec.daily_rate) *
           		DECODE(rec.order_type, DIS_JOB_BY, -1, NON_ST_JOB_BY,  -1,
                		REP_SCHED_BY,   -1, PLANNED_BY, -1,
                		FLOW_SCHED_BY, -1, 1))) new_quantity
FROM    msc_plans p,
	msc_trading_partners param,
        msc_system_items msi,
        msc_supplies rec,
	msc_companies c,
	msc_company_sites s,
	msc_trading_partners t,
	msc_trading_partner_maps m
WHERE   p.plan_id = p_plan_id
AND	p.plan_id = msi.plan_id
AND     msi.inventory_item_id = nvl(p_item_id, msi.inventory_item_id)
AND     msi.organization_id = nvl(p_org_id, msi.organization_id)
AND     msi.sr_instance_id = nvl(p_sr_instance_id, msi.sr_instance_id)
AND	NVL(msi.planner_code,'-99') = NVL(p_planner_code, NVL(msi.planner_code,'-99'))
AND 	NVL(msi.abc_class_name,'-99') = NVL(p_abc_class, NVL(msi.abc_class_name,'-99'))
AND     param.sr_tp_id = rec.organization_id
AND     param.sr_instance_id = rec.sr_instance_id
AND     param.partner_type = 3
AND	rec.plan_id = msi.plan_id
AND     rec.inventory_item_id = msi.inventory_item_id
AND     rec.organization_id = msi.organization_id
AND     rec.sr_instance_id = msi.sr_instance_id
AND 	t.sr_tp_id = rec.organization_id
AND 	t.sr_instance_id = rec.sr_instance_id
AND 	t.partner_type = 3
AND 	m.tp_key = t.partner_id
AND 	m.map_type = 2
AND 	s.company_site_id = m.company_key
AND 	c.company_id = s.company_id
AND 	nvl(rec.planning_group, '-99') = nvl(p_planning_gp, nvl(rec.planning_group, '-99'))
AND 	nvl(rec.project_id,-99) = nvl(p_project_id, nvl(rec.project_id,-99))
AND 	nvl(rec.task_id, -99) = nvl(p_task_id, nvl(rec.task_id, -99))
AND	rec.plan_id = p.plan_id
AND 	p.plan_completion_date is not null
AND     trunc(rec.new_schedule_date) <= nvl(trunc(p_horizon_end), rec.new_schedule_date)
and trunc(rec.new_schedule_date ) < trunc( p.plan_start_date)
GROUP BY
	rec.sr_instance_id,
        rec.organization_id ,
        msi.base_item_id,
        msi.inventory_item_id,
        rec.new_schedule_date,
	null,--	mpb.bkt_start_date,
	null,--	mpb.bkt_end_date,
	null,--	mpb.days_in_bkt,
	null,--	mpb.bucket_type,
	null,--	mpb.bucket_index,
        DECODE(rec.order_type,
        PURCHASE_ORDER, 	PAB_SUPPLY,
        PURCH_REQ, 		PAB_SUPPLY,
        WORK_ORDER,  		PAB_SUPPLY,
        FLOW_SCHED,   		PAB_SUPPLY,
        REPETITIVE_SCHEDULE, 	PAB_SUPPLY,
        PLANNED_ORDER, 		PAB_SUPPLY,
        NONSTD_JOB,     	PAB_SUPPLY,
        RECEIPT_PURCH_ORDER, 	PAB_SUPPLY,
        SHIPMENT,     		PAB_SUPPLY,
        RECEIPT_SHIPMENT,   	PAB_SUPPLY,
        DIS_JOB_BY,     	PAB_DEMAND,
        NON_ST_JOB_BY,  	PAB_DEMAND,
        REP_SCHED_BY,   	PAB_DEMAND,
        PLANNED_BY,  		PAB_DEMAND,
	FLOW_SCHED_BY, 		PAB_DEMAND,
        PAYBACK_SUPPLY, 	PAB_SUPPLY,
        ON_HAND_QTY, 		PAB_ONHAND,
        PAB_SUPPLY),
	c.company_id,
	c.company_name,
	s.company_site_id,
	s.company_site_name,
 	msi.item_name,
	msi.description,
	null,			--base item name
	msi.uom_code,
	msi.planner_code,--Bug 4424426
	NULL,	--rec.planning_group,
	NULL,	--rec.project_id,
	NULL	--rec.task_id

UNION ALL
SELECT
	mgr.sr_instance_id,
        mgr.organization_id,
        msi.base_item_id,
        msi.inventory_item_id,
        trunc(mgr.using_assembly_demand_date),
	NULL,	--mpb.bkt_start_date,
	NULL,	--mpb.bkt_end_date,
	NULL,	--mpb.days_in_bkt,
	NULL,	--mpb.bucket_type,
	NULL,	--mpb.bucket_index,
	decode (mgr.origination_type, 1, PAB_DEMAND,2,PAB_DEMAND,3,PAB_DEMAND,
	4,PAB_DEMAND,5,PAB_EXP_LOT,6,PAB_DEMAND,7,PAB_DEMAND,8,PAB_DEMAND,
	9,PAB_DEMAND,10,PAB_DEMAND,11,PAB_DEMAND,12,PAB_DEMAND,
  	15,PAB_DEMAND,16,PAB_SCRAP_DEMAND,17,PAB_SCRAP_DEMAND,18,PAB_SCRAP_DEMAND,
  	19,PAB_SCRAP_DEMAND,20,PAB_SCRAP_DEMAND,21,PAB_SCRAP_DEMAND,22,PAB_DEMAND,
  	23,PAB_SCRAP_DEMAND,24,PAB_DEMAND,25,PAB_DEMAND,26,PAB_SCRAP_DEMAND,
	29,PAB_DEMAND,30,PAB_DEMAND,DEMAND_PAYBACK,PAB_DEMAND,
  	PAB_DEMAND),
	c.company_id,
	c.company_name,
	s.company_site_id,
	s.company_site_name,
 	msi.item_name,
	msi.description,
	null,			---base item name
	msi.uom_code,
	msi.planner_code,--Bug 4424426
	NULL,	--mgr.planning_group,
	NULL,	--mgr.project_id,
	NULL,	--mgr.task_id,
	SUM(DECODE(mgr.assembly_demand_comp_date,
            NULL, DECODE(mgr.origination_type,
                        29,(nvl(mgr.probability,1)*using_requirement_quantity),
                        31, 0,
                        using_requirement_quantity),
            DECODE(mgr.origination_type,
                   29,(nvl(mgr.probability,1)*daily_demand_rate),
                   31, 0,
                   daily_demand_rate)))/
        DECODE(nvl(LEAST(SUM(DECODE(mgr.origination_type,
                                    29,nvl(mgr.probability,0),
                                    null)) ,1) ,1),
               0,1,
               nvl(LEAST(SUM(DECODE(mgr.origination_type,
                                    29,nvl(mgr.probability,0),
                                    null)) ,1) ,1)) new_quantity
FROM    msc_plans p,
	msc_trading_partners param,
	msc_system_items msi,
        msc_demands  mgr,
	msc_companies c,
	msc_company_sites s,
	msc_trading_partners t,
	msc_trading_partner_maps m
WHERE   p.plan_id = p_plan_id
AND	p.plan_id = mgr.plan_id
AND     msi.inventory_item_id = nvl(p_item_id, msi.inventory_item_id )
AND     mgr.organization_id = nvl(p_org_id, mgr.organization_id)
AND     mgr.sr_instance_id = nvl(p_sr_instance_id, mgr.sr_instance_id)
AND	NVL(msi.planner_code,'-99') = NVL(p_planner_code, NVL(msi.planner_code,'-99'))
AND 	NVL(msi.abc_class_name,'-99') = NVL(p_abc_class, NVL(msi.abc_class_name,'-99'))
AND     param.sr_tp_id = mgr.organization_id
AND     param.sr_instance_id = mgr.sr_instance_id
AND     param.partner_type = 3
AND	mgr.plan_id = msi.plan_id
AND     mgr.inventory_item_id = msi.inventory_item_id
AND     mgr.organization_id = msi.organization_id
AND     mgr.sr_instance_id = msi.sr_instance_id
AND 	t.sr_tp_id = mgr.organization_id
AND 	t.sr_instance_id = mgr.sr_instance_id
AND 	t.partner_type = 3
AND 	m.tp_key = t.partner_id
AND 	m.map_type = 2
AND 	s.company_site_id = m.company_key
AND 	c.company_id = s.company_id
AND 	nvl(mgr.planning_group, '-99') = nvl(p_planning_gp, nvl(mgr.planning_group, '-99'))
AND 	nvl(mgr.project_id,-99) = nvl(p_project_id, nvl(mgr.project_id,-99))
AND 	nvl(mgr.task_id, -99) = nvl(p_task_id, nvl(mgr.task_id, -99))
AND	mgr.plan_id = p.plan_id
AND     p.plan_completion_date is not null
AND     trunc(mgr.using_assembly_demand_date) <= nvl(trunc(p_horizon_end), trunc(mgr.using_assembly_demand_date))
AND	trunc(mgr.using_assembly_demand_date) < trunc(p.plan_start_date)
AND     not exists (
        select 'cancelled IR'
        from   msc_supplies mr
        where  mgr.origination_type in (30,6)
        and    mgr.disposition_id = mr.transaction_id
        and    mgr.plan_id = mr.plan_id
        and    mgr.sr_instance_id = mr.sr_instance_id
        and    mr.disposition_status_type = 2)
GROUP BY
        mgr.sr_instance_id,
        mgr.organization_id,
        msi.base_item_id,
        msi.inventory_item_id,
        mgr.using_assembly_demand_date,
	NULL,	--mpb.bkt_start_date,
	NULL,	--mpb.bkt_end_date,
	NULL,	--mpb.days_in_bkt,
	NULL,	--mpb.bucket_type,
	NULL,	--mpb.bucket_index,
	decode (mgr.origination_type, 1, PAB_DEMAND,2,PAB_DEMAND,3,PAB_DEMAND,
	4,PAB_DEMAND,5,PAB_EXP_LOT,6,PAB_DEMAND,7,PAB_DEMAND,8,PAB_DEMAND,
	9,PAB_DEMAND,10,PAB_DEMAND,11,PAB_DEMAND,12,PAB_DEMAND,
  	15,PAB_DEMAND,16,PAB_SCRAP_DEMAND,17,PAB_SCRAP_DEMAND,18,PAB_SCRAP_DEMAND,
  	19,PAB_SCRAP_DEMAND,20,PAB_SCRAP_DEMAND,21,PAB_SCRAP_DEMAND,22,PAB_DEMAND,
  	23,PAB_SCRAP_DEMAND,24,PAB_DEMAND, 25,PAB_DEMAND,26,PAB_SCRAP_DEMAND,
	29,PAB_DEMAND,30,PAB_DEMAND,DEMAND_PAYBACK,PAB_DEMAND,
  	PAB_DEMAND),
	c.company_id,
	c.company_name,
	s.company_site_id,
	s.company_site_name,
	msi.item_name,
	msi.description,
	null,
	msi.uom_code,
	msi.planner_code,--Bug 4424426
	NULL,	--mgr.planning_group,
	NULL,	--mgr.project_id,
	NULL	--mgr.task_id

ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14;

/*********
t_pub                       companyNameList := companyNameList();
t_pub_id                    numberList      := numberList();
t_pub_site                  companySiteList := companySiteList();
t_pub_site_id               numberList      := numberList();
t_customer		    companyNameList := companyNameList();
t_customer_id		    numberList 	    := numberList();
t_customer_site		    companySiteList := companySiteList();
t_customer_site_id	    numberList      := numberList();
t_item_name           	    itemNameList := itemNameList();
t_item_desc           	    itemDescList := itemDescList();
t_base_item_name	    itemNameList := itemNamelist();
t_supp                      companyNameList := companyNameList();
t_supp_id                   numberList      := numberList();
t_supp_site                 companySiteList := companySiteList();
t_supp_site_id              numberList      := numberList();
t_master_item_name          itemNameList := itemNameList();
t_master_item_desc          itemDescList := itemDescList();
t_supp_item_name            itemNameList := itemNameList();
t_supp_item_desc            itemDescList := itemDescList();
t_type			    numberList   := numberList();

a_pub                       companyNameList := companyNameList();
a_pub_id                    numberList      := numberList();
a_pub_site                  companySiteList := companySiteList();
a_pub_site_id               numberList      := numberList();
a_customer		    companyNameList := companyNameList();
a_customer_id		    numberList 	    := numberList();
a_customer_site		    companySiteList := companySiteList();
a_customer_site_id	    numberList      := numberList();
a_item_name                 itemNameList := itemNameList();
a_item_desc                 itemDescList := itemDescList();
a_base_item_name	    itemNameList := itemNameList();
a_supp                      companyNameList := companyNameList();
a_supp_id                   numberList      := numberList();
a_supp_site                 companySiteList := companySiteList();
a_supp_site_id              numberList      := numberList();
a_master_item_name          itemNameList := itemNameList();
a_master_item_desc          itemDescList := itemDescList();
a_supp_item_name            itemNameList := itemNameList();
a_supp_item_desc            itemDescList := itemDescList();
a_type			    numberList   := numberList();
a_total_qty		    numberList := numberList();
a_temp_qty		    numberList := numberList();
a_days_in_bkt		    numberList := numberList();
a_bucket_type		    numberList := numberList();
***********/



----------------------------------------------------------------
-- begin
-----------------------------------------------------------------

BEGIN

t_pub                       := companyNameList();
t_pub_id                    := numberList();
t_pub_site                  := companySiteList();
t_pub_site_id               := numberList();
t_customer		    := companyNameList();
t_customer_id		    := numberList();
t_customer_site		    := companySiteList();
t_customer_site_id	    := numberList();
t_item_name           	    := itemNameList();
t_item_desc           	    := itemDescList();
t_base_item_name	    := itemNamelist();
t_supp                      := companyNameList();
t_supp_id                   := numberList();
t_supp_site                 := companySiteList();
t_supp_site_id              := numberList();
t_master_item_name          := itemNameList();
t_master_item_desc          := itemDescList();
t_supp_item_name            := itemNameList();
t_supp_item_desc            := itemDescList();
t_type			    := numberList();
b_bkt_index		    := numberList();
b_bkt_type		    := numberList();

a_pub                       := companyNameList();
a_pub_id                    := numberList();
a_pub_site                  := companySiteList();
a_pub_site_id               := numberList();
a_customer		    := companyNameList();
a_customer_id		    := numberList();
a_customer_site		    := companySiteList();
a_customer_site_id	    := numberList();
a_item_name                 := itemNameList();
a_item_desc                 := itemDescList();
a_base_item_name	    := itemNameList();
a_supp                      := companyNameList();
a_supp_id                   := numberList();
a_supp_site                 := companySiteList();
a_supp_site_id              := numberList();
a_master_item_name          := itemNameList();
a_master_item_desc          := itemDescList();
a_supp_item_name            := itemNameList();
a_supp_item_desc            := itemDescList();
a_type			    := numberList();
a_total_qty		    := numberList();
a_temp_qty		    := numberList();
a_days_in_bkt		    := numberList();
a_bucket_type		    := numberList();
i_bkt_index		    := numberList();
i_bkt_type		    := numberList();


if fnd_global.conc_request_id > 0 then

    p_retcode := 0 ;      -- Bug 4560452
    p_errbuf  := null ;

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


--dbms_output.put_line('At 1');
  select compile_designator
  into   p_designator
  from   msc_plans
  where  plan_id = p_plan_id;

--dbms_output.put_line('Designator : ' || p_designator);

  if p_org_code is not null then
    p_inst_code := substr(p_org_code,1,instr(p_org_code,':')-1);
    --dbms_output.put_line('p_inst_code := ' || p_inst_code);
    begin
    select instance_id
    into   p_sr_instance_id
    from   msc_apps_instances
    where  instance_code = p_inst_code;
    --dbms_output.put_line('p_sr_instance_id := ' || p_sr_instance_id);

    select sr_tp_id
    into   p_org_id
    from   msc_trading_partners
    where  organization_code = p_org_code and
           sr_instance_id = p_sr_instance_id and
           partner_type = 3 and
           company_id is null;
    --dbms_output.put_line('p_org_id := ' || p_org_id);
    exception
    	when others then
    		p_sr_instance_id := null;
    		p_org_id := null;
    end;
  else
    p_org_id := null;
    p_sr_instance_id := null;
  end if;

  --------------------------------------------------------------------------
  -- set the standard date as canonical date
  --------------------------------------------------------------------------
-- Bug 4549069
  if (p_horizon_start is null) then
	select sysdate
	into l_horizon_start
	from dual;
  else
	 l_horizon_start := fnd_date.canonical_to_date(p_horizon_start);
  end if;

   if (p_horizon_end is null) then
	select sysdate +365
	into l_horizon_end
	from dual;
   else
	 l_horizon_end := fnd_date.canonical_to_date(p_horizon_end);
  end if;


log_message('l_horizon_start: '||l_horizon_start);
log_message('l_horizon_end: '||l_horizon_end);



  l_log_message := get_message('MSC','MSC_PUB_SS',l_language_code) || ' ' || fnd_global.local_chr(10) ||
    get_message('MSC','MSC_X_PUB_PLAN',l_language_code) || ': ' || p_designator || fnd_global.local_chr(10);


  if (l_horizon_start > l_horizon_end) THEN
   l_log_message := l_log_message || get_message('MSC','MSC_X_PUB_START_DATE',l_language_code) || ' ' || l_horizon_start || fnd_global.local_chr(10);
   l_log_message := l_log_message || get_message('MSC','MSC_X_PUB_END_DATE',l_language_code) || ' ' || l_horizon_end || fnd_global.local_chr(10);
   l_log_message := l_log_message || get_message('MSC','MSC_X_PUB_DATE_MISMATCH',l_language_code) || ' ' || fnd_global.local_chr(10);
   log_message(l_log_message);
   RETURN;

  END IF;

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


  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleting old safety stock matching the filter criteria');

--dbms_output.put_line('At 2');
--dbms_output.put_line('Horizon date ' || p_horizon_start || ' ' || p_horizon_end);
   	delete_old_safety_stock(
   	  p_plan_id,
   	  p_org_id,
   	  p_sr_instance_id,
   	  p_planner_code,
   	  p_abc_class,
   	  p_item_id,
   	  p_planning_gp,
   	  p_project_id,
   	  p_task_id,
   	  l_horizon_start,
   	  l_horizon_end,
   	  p_overwrite
   	);


--dbms_output.put_line('At 3');
 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start');

Open  safety_stock_c (
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
 	,p_supplier_id
 	,p_supplier_site_id
 	,p_overwrite);

 FETCH safety_stock_c BULK COLLECT INTO
	t_sr_instance_id,
	t_org_id,
	t_base_item_id,
	t_item_id,
	t_period_start_date,
	t_bucket_start,
	t_bucket_end,
	t_days_in_bkt,
	t_bucket_type,
	t_bucket_index,
	t_pub_id,
	t_pub,
	t_pub_site_id,
	t_pub_site,
	t_item_name,
	t_item_desc,
	t_base_item_name,
	t_uom_code,
	t_planner_code,
	t_planning_gp,
	t_proj_number,
	t_task_number,
	t_qty;
 CLOSE safety_stock_c;

  --dbms_output.put_line('At 4');

 -------------------------------------------------------------------------------------

 --If it is the first record, then insert safety stock into MSC_SUP_DEM_ENTRIES OR
 --If the current record = the prev record (same plan_id, sr_instance_id, org_id and item_id)
 -- and no need to fill the gap between, then insert safety stock into MSC_SUP_DEM_ENTRIES OR
 --If it it a new record (the plan_id is different from the prev record plan_id or
 --		Sr_instance_id of the current is different from the previous sr_instance_id or
 --		Org_id of the current record is different from the previous org_id or
 --		Item_id of the current record is different from the previous item_id)
 --	then insert safety stocks into MSC_SUP_DEM_ENTRIES
 --------------------------------------------------------------------------------------

 IF t_org_id IS NOT NULL AND t_org_id.COUNT > 0 THEN


  		--dbms_output.put_line ('Records fetched by cursor ss := ' || t_org_id.COUNT);
    		FND_FILE.PUT_LINE(FND_FILE.LOG, 'Records fetched by safety stock cursor : ' || t_org_id.COUNT);
  		--dbms_output.put_line('At 5');
    		get_optional_info(
		p_errbuf
    		,p_retcode
		,p_plan_id
    		,p_supplier_id
    		,p_supplier_site_id
    		,t_base_item_id
      		,t_item_id
      		,t_org_id
      		,t_sr_instance_id
      		,t_uom_code
      		,t_qty
      		,t_master_item_name
      		,t_master_item_desc
      		,t_pub_id
      		,t_pub
      		,t_pub_site_id
     		,t_pub_site
       		,t_supp_id
      		,t_supp
      		,t_supp_site_id
      		,t_supp_site
      		,t_item_name
      		,t_item_desc
      		,t_base_item_name
      		,t_bucket_index
    		);

       		--dbms_output.put_line('At 6');


  		insert_into_sup_dem(
		p_errbuf
    		,p_retcode
  		,p_plan_id
  		,l_horizon_start
  		,l_horizon_end
  		,SAFETY_STOCK
  		,t_sr_instance_id
  		,t_org_id
      		,t_pub
      		,t_pub_id
      		,t_pub_site
      		,t_pub_site_id
      		,t_base_item_id
      		,t_item_id
      		,t_bucket_type
      		,t_bucket_start
      		,t_bucket_end
      		,t_bucket_index
      		,t_qty
      		,t_qty
      		,t_qty
      		,t_item_name
      		,t_item_desc
      		,t_base_item_name
      		,t_proj_number
      		,t_task_number
      		,t_planning_gp
      		,t_uom_code
      		,t_planner_code
      		,t_period_start_date
      		,t_master_item_name
      		,t_master_item_desc
      		,l_version
      		,p_designator
      		,l_user_id
      		,l_language_code
    		);

   --l_log_message := 'Number of records published: ' || 0 || '.';
   --log_message(l_log_message);
     		l_cursor1 := 0;
  END IF;

  ------------------------------------------------------------------------------
  --projected available balance
  ------------------------------------------------------------------------------
  OPEN projected_availabe_balance_c (
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
 			,p_supplier_id
 			,p_supplier_site_id
 			,p_overwrite);
  FETCH projected_availabe_balance_c BULK COLLECT INTO
			a_sr_instance_id,
			a_org_id,
			a_base_item_id,
			a_item_id,
			a_period_start_date,
			a_bucket_start,
			a_bucket_end,
			a_days_in_bkt,
			a_bucket_type,
			a_bucket_index,
			a_pab_type,
			a_pub_id,
			a_pub,
			a_pub_site_id,
			a_pub_site,
			a_item_name,
			a_item_desc,
			a_base_item_name,
			a_uom_code,
			a_planner_code,
			a_planning_gp,
			a_proj_number,
			a_task_number,
			a_qty;
  CLOSE projected_availabe_balance_c;

  IF a_org_id IS NOT NULL AND a_org_id.COUNT > 0 THEN
	--dbms_output.put_line ('Records fetched by cursor pab := ' || a_org_id.COUNT);
    	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Records fetched by pab cursor: ' || a_org_id.COUNT);

               get_total_qty (
	       p_errbuf
    		,p_retcode
    		,a_item_id
   		,a_org_id
    		,a_sr_instance_id
    		,a_pab_type
    		,a_period_start_date
    		,a_qty
    		,a_total_qty
   		,a_temp_qty
   		);

 	 	get_optional_info(
		p_errbuf
    		,p_retcode
 	  	,p_plan_id
 	  	,p_supplier_id
 	  	,p_supplier_site_id
 	  	,a_base_item_id
       		,a_item_id
       		,a_org_id
       		,a_sr_instance_id
       		,a_uom_code
       		,a_qty
       		,a_master_item_name
       		,a_master_item_desc
       		,a_pub_id
       		,a_pub
       		,a_pub_site_id
      		,a_pub_site
      		,a_supp_id
      		,a_supp
      		,a_supp_site_id
      		,a_supp_site
      		,a_item_name
      		,a_item_desc
      		,a_base_item_name
      		,a_bucket_index
    		);
		--dbms_output.put_line('At 6');
  		insert_into_sup_dem(
		p_errbuf
    		,p_retcode
  		,p_plan_id
  		,l_horizon_start
  		,l_horizon_end
  		,PROJECTED_AVAILABLE_BALANCE
  		,a_sr_instance_id
  		,a_org_id
      		,a_pub
      		,a_pub_id
      		,a_pub_site
      		,a_pub_site_id
      		,a_base_item_id
      		,a_item_id
      		,a_bucket_type
      		,a_bucket_start
      		,a_bucket_end
      		,a_bucket_index
      		,a_qty
      		,a_total_qty
      		,a_temp_qty
      		,a_item_name
      		,a_item_desc
      		,a_base_item_name
      		,a_proj_number
      		,a_task_number
      		,a_planning_gp
      		,a_uom_code
      		,a_planner_code
      		,a_period_start_date
      		,a_master_item_name
      		,a_master_item_desc
      		,l_version
      		,p_designator
      		,l_user_id
      		,l_language_code
    		);
  	--END IF;

  END IF;
  commit;

  IF l_cursor1 = 0  THEN
     --l_log_message := get_message('MSC','MSC_X_PUB_NUM_RECORDS',l_language_code) || ': ' || 0 || '.' || fnd_global.local_chr(10);
     --log_message(l_log_message);
       null;
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
			 AND version = l_version);
     EXCEPTION
	WHEN OTHERS then
	  l_records_exist := 0;
     END;
     IF l_records_exist = 1 then
	l_log_message := get_message('MSC','MSC_X_PUB_NEW_VERSION',l_language_code) || ' ' || l_version || '.' || fnd_global.local_chr(10);
	log_message(l_log_message);
     END IF;
  END IF;

EXCEPTION
 	when others then
 	--dbms_output.put_line('Error in publish safety stock proc: ' ||sqlerrm);
 	  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in publish safety stock procedure: ' ||sqlerrm);
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Publish Safety Stock data ');
	 p_retcode :=  1 ;    -- Bug 4560452
         p_errbuf  := sqlerrm ;

END publish_safety_stocks;

PROCEDURE get_total_qty (
  p_err               OUT nocopy varchar2,
  p_ret               OUT nocopy number,
  t_item_id             IN numberList,
  t_org_id              IN numberList,
  t_sr_instance_id      IN numberList,
  t_pab_type		IN numberList,
  t_key_date		IN dateList,
  t_qty			IN numberList,
  t_total_qty           IN OUT NOCOPY numberList,
  t_temp_qty		IN OUT NOCOPY numberList
  ) IS


BEGIN

	--------------------------------------------------------------------------------------
	--expiration lot qty := exp_lot - total_demand
	--
	--IF (l_exp_lot > l_demand and l_exp_lot > 0 ) THEN
	--	l_expired_qty := l_exp_lot - l_demand;
	--END IF;
	--l_pab_total:= l_pab_total + l_onhand + l_supply -  (l_demand + l_scrap_demand + l_expired_qty);
	-----------------------------------------------------------------------------------------

 ----FND_FILE.PUT_LINE(FND_FILE.LOG, 'in get total qty ' || t_item_id.COUNT);
  IF t_item_id is not null and t_item_id.COUNT > 0 then
  --dbms_output.put_line('get total: ' || t_item_id.COUNT);

    FOR j in 1..t_item_id.COUNT loop
      	t_total_qty.EXTEND;
      	t_temp_qty.EXTEND;
      	IF (j > 1 and t_sr_instance_id(j) = t_sr_instance_id(j-1) and
			t_org_id(j) = t_org_id(j-1) and
			t_item_id(j) = t_item_id(j-1)) THEN
		IF (t_pab_type(j) in (PAB_ONHAND, PAB_SUPPLY)) THEN
			t_total_qty(j) := nvl(t_total_qty(j),0) + t_total_qty(j-1) + nvl(t_qty(j),0);
			t_temp_qty(j) := 0;
		ELSIF (t_pab_type(j) = PAB_SCRAP_DEMAND ) THEN
			t_total_qty(j) := nvl(t_total_qty(j),0) + t_total_qty(j-1) - nvl(t_qty(j),0);
			t_temp_qty(j) := 0;
		ELSIF (t_pab_type(j) = PAB_DEMAND) THEN
			t_total_qty(j) := nvl(t_total_qty(j),0) + t_total_qty(j-1) -  nvl(t_qty(j),0);
			t_temp_qty(j) := nvl(t_temp_qty(j),0) - nvl(t_qty(j),0);
		ELSIF (t_pab_type(j) = PAB_EXP_LOT) THEN
			t_total_qty(j) := nvl(t_total_qty(j),0) + t_total_qty(j-1);
			t_temp_qty(j) := nvl(t_temp_qty(j),0) + nvl(t_qty(j),0);
		END IF;
----FND_FILE.PUT_LINE(FND_FILE.LOG, 'ELSE TOTAL QTY: ' || t_total_qty(j));
----FND_FILE.PUT_LINE(FND_FILE.LOG, 'ELSE TEMP QTY: ' || t_temp_qty(j));
--dbms_output.put_line('ELSE Total qty ' || t_total_qty(j) || ' date ' || t_key_date(j));
--dbms_output.put_line('ELSE Temp qty ' || t_temp_qty(j) || ' date ' || t_key_date(j));

	ELSIF (j = 1 or t_sr_instance_id(j) <> t_sr_instance_id(j-1) or
			t_org_id(j) <> t_org_id(j-1) or
			t_item_id(j) <> t_item_id(j-1) or
			t_key_date(j) <> t_key_date(j-1)) THEN

		IF (t_pab_type(j) = PAB_DEMAND) THEN
			t_total_qty(j) := nvl(- t_qty(j), 0);
			t_temp_qty(j) := nvl(- t_qty(j),0) ;
		ELSIF (t_pab_type(j) = PAB_SCRAP_DEMAND) THEN
			t_total_qty(j) := nvl(- t_qty(j), 0);
			t_temp_qty(j) := 0;
		ELSIF (t_pab_type(j) = PAB_EXP_LOT) THEN
			t_total_qty(j) := 0;
			t_temp_qty(j) := nvl(t_qty(j),0);
		ELSE
			t_total_qty(j) := nvl(t_qty(j), 0);
			t_temp_qty(j) := 0;
		END IF;
----FND_FILE.PUT_LINE(FND_FILE.LOG, 'IF TOTAL QTY: ' || t_total_qty(j));
----FND_FILE.PUT_LINE(FND_FILE.LOG, 'IF TEMP QTY: ' || t_temp_qty(j));
--dbms_output.put_line('IF Total qty ' || t_total_qty(j) || ' date ' || t_key_date(j));
--dbms_output.put_line('IF Temp qty ' || t_temp_qty(j) || ' date ' || t_key_date(j));

	END IF;
    END LOOP;
  END IF;
   p_ret := 0;
   p_err := null ;

EXCEPTION
	WHEN OTHERS THEN
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in get total quantity proc: ' ||sqlerrm);
	--dbms_output.put_line('Error in get total quantity proc: ' || sqlerrm);
         p_ret := 1;
	 p_err := sqlerrm ;
END get_total_qty;

PROCEDURE get_optional_info(
  p_err               OUT nocopy varchar2,
  p_ret               OUT nocopy number,
  p_plan_id		IN number,
  p_supp_id		IN number,
  p_supp_site_id	IN number,
  t_base_item_id	IN numberList,
  t_item_id             IN numberList,
  t_org_id              IN numberList,
  t_sr_instance_id      IN numberList,
  t_uom_code            IN itemUomList,
  t_qty                 IN numberList,
  t_master_item_name 	IN OUT NOCOPY itemNameList,
  t_master_item_desc 	IN OUT NOCOPY itemDescList,
  t_pub_id           	IN OUT NOCOPY numberList,
  t_pub              	IN OUT NOCOPY companyNameList,
  t_pub_site_id      	IN OUT NOCOPY numberList,
  t_pub_site         	IN OUT NOCOPY companySiteList,
  t_supp_id          	IN OUT NOCOPY numberList,
  t_supp             	IN OUT NOCOPY companyNameList,
  t_supp_site_id     	IN OUT NOCOPY numberList,
  t_supp_site        	IN OUT NOCOPY companySiteList,
  t_item_name		IN OUT NOCOPY itemNameList,
  t_item_desc		IN OUT NOCOPY itemDescList,
  t_base_item_name	IN OUT NOCOPY itemNameList,
  t_bucket_index	IN OUT NOCOPY numberList
) IS


  l_conversion_found boolean;
  l_conversion_rate  number;
  l_lead_time        number;
  l_using_org_id     number;
BEGIN

  if t_item_id is not null and t_item_id.COUNT > 0 then
  --dbms_output.put_line('In get_optional_info : ' || t_item_id.COUNT);
    for j in 1..t_item_id.COUNT loop
    /***
      t_pub_id.EXTEND;
      t_pub.EXTEND;
      t_pub_site.EXTEND;
      t_pub_site_id.EXTEND;

      if (j = 1) or (t_org_id(j-1) <> t_org_id(j)) or (t_sr_instance_id(j-1) <> t_sr_instance_id(j)) then
	BEGIN
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
         EXCEPTION
         	WHEN NO_DATA_FOUND THEN
         		t_pub_id(j) := null;
         		t_pub(j) := null;
         		t_pub_site_id(j) := null;
         		t_pub_site(j) := null;
         END;

      else
        t_pub_id(j) := t_pub_id(j-1);
        t_pub(j) := t_pub(j-1);
        t_pub_site_id(j) := t_pub_site_id(j-1);
        t_pub_site(j) := t_pub_site(j-1);
      end if;
***/


     /*-------------------------------------------------------------------------------
     get the item_description -- this works for both standard item
     ---------------------------------------------------------------------------------*/
     begin
     	select	item_name, description
     	into	t_item_name(j), t_item_desc(j)
     	from	msc_system_items
     	where	sr_instance_id = t_sr_instance_id(j)
     	and	organization_id = t_org_id(j)
     	and	inventory_item_id = t_item_id(j)
     	and 	plan_id = -1;

     exception
     	when others then
     		t_item_name(j) := null;
     		t_item_desc(j) := null;
     end;

     /*-------------------------------------------------------------------------------
     get the base item name
     ---------------------------------------------------------------------------------*/
     begin
     	select	item_name
     	into	t_base_item_name(j)
     	from	msc_system_items
     	where	sr_instance_id = t_sr_instance_id(j)
     	and	organization_id = t_org_id(j)
     	and	inventory_item_id = t_base_item_id(j)
     	and 	plan_id = -1;

     exception
     	when others then
     		t_base_item_name(j) := null;
     end;

     -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'pub id ' || t_pub_id(j) || ' site ' || t_pub_site_id(j));
      --dbms_output.put_line(' Get pub id ' || t_pub(j) || ': ' || t_pub_site(j));

      ----------------------------------------------------------------------
      -- getting the supplier info
      ----------------------------------------------------------------------
      t_supp_id.EXTEND;
      t_supp.EXTEND;
      t_supp_site.EXTEND;
      t_supp_site_id.EXTEND;

  --  FND_FILE.PUT_LINE(FND_FILE.LOG, 'sup id ' || p_supp_id || ' site ' || p_supp_site_id);
   -- FND_FILE.PUT_LINE(FND_FILE.LOG, 'item' || t_item_id(j) || ' org' || t_org_id(j) || 'sr ' || t_sr_instance_id(j));
      if (p_supp_id is not null ) THEN
        BEGIN
        --dbms_output.put_line('BEGIN');
          select distinct c.company_id,
                 c.company_name
          into   t_supp_id(j),
                 t_supp(j)
          from   msc_companies c,
                 msc_trading_partner_maps m,
                 msc_company_relationships r,
                 msc_item_suppliers mis
          where  m.tp_key = mis.supplier_id and
                 m.map_type = 1 and
                 r.relationship_id = m.company_key and
                 r.subject_id = t_pub_id(j) and
                 r.relationship_type = 2 and
                 c.company_id = r.object_id and
                 mis.plan_id = -1 and
                 mis.organization_id = t_org_id(j) and
                 mis.sr_instance_id = t_sr_instance_id(j) and
                 mis.inventory_item_id = t_item_id(j) and
                 mis.supplier_id = p_supp_id;


        EXCEPTION
          WHEN OTHERS THEN
            t_supp_id(j) := null;
            t_supp(j) := null;
            ---------------------------------------------------------------------------
            -- if the supplier or supplier site is not a valid one
            -- should not publish the record by setting the t_pub_id(j) to null
            ----------------------------------------------------------------------------
            t_pub_id(j) := null;	-- the data should not be populated.
            t_bucket_index(j) := null;
	 p_ret := 1;
	 p_err := sqlerrm ;
	 FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in getting Supplier info. Please check the ASL settings. Error: '||sqlerrm);
        END;


      	IF (p_supp_site_id is not null) then
        	BEGIN
          		select s.company_site_id,
                 	s.company_site_name
          		into   t_supp_site_id(j),
                 	t_supp_site(j)
          		from   msc_company_sites s,
                 		msc_trading_partner_maps m,
                 		msc_item_suppliers mis
          		where  m.tp_key = mis.supplier_site_id and
                 		m.map_type = 3 and
                 		s.company_site_id = m.company_key and
                 		s.company_id = t_supp_id(j) and
                 		m.tp_key = mis.supplier_site_id and
                 		mis.plan_id = -1 and
                 		mis.organization_id = t_org_id(j) and
                 		mis.sr_instance_id = t_sr_instance_id(j) and
                 		mis.inventory_item_id = t_item_id(j) and
                 		mis.supplier_id = p_supp_id and
                 		mis.supplier_site_id = p_supp_site_id
                 		;
        	EXCEPTION
          	WHEN OTHERS THEN

            		t_supp_site_id(j) := null;
            		t_supp_site(j) := null;
            	---------------------------------------------------------------------------
            	-- if the supplier or supplier site is not a valid one
            	-- should not publish the record by setting the t_pub_id(j) to null
            	----------------------------------------------------------------------------
            		t_pub_id(j) := null;	-- the data should not be populated.
            		t_bucket_index(j) := null;
	          p_ret := 1;
	          p_err := sqlerrm ;
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in getting Supplier Site. Please check the ASL settings. Error: '||sqlerrm);
        	END;
        END IF;

      end if;

    -- Bug 4560452
    -- Do not need to find supp_site_id as it is not used anywhere in the code.
     /* ELSE
	------------------------------------------------
	--   IF p_supp_site is not provided
	   -----------------------------------------------

       	 	BEGIN
          		select s.company_site_id,
                 		s.company_site_name
          		into   t_supp_site_id(j),
                 		t_supp_site(j)
          		from   msc_company_sites s,
                 		msc_trading_partner_maps m,
                 		msc_item_suppliers mis
          		where  m.map_type = 3 and
                 		s.company_site_id = m.company_key and
                 		s.company_id = t_supp_id(j) and
                 		m.tp_key = mis.supplier_site_id and
                 		mis.plan_id = -1 and
                 		mis.organization_id = t_org_id(j) and
                 		mis.sr_instance_id = t_sr_instance_id(j) and
                 		mis.inventory_item_id = t_item_id(j) and
                 		mis.supplier_id = p_supp_id
                 		;
        	EXCEPTION
          	WHEN OTHERS THEN

            		t_supp_site_id(j) := null;
            		t_supp_site(j) := null;
            	---------------------------------------------------------------------------
            	-- if the supplier or supplier site is not a valid one
            	-- should not publish the record by setting the t_pub_id(j) to null
            	----------------------------------------------------------------------------
            		t_pub_id(j) := null;	-- the data should not be populated.
            		t_bucket_index(j) := null;

	FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in sup_site : '||sqlerrm);
        	END;  */

--FND_FILE.PUT_LINE(FND_FILE.LOG, 'Item ' || t_item_name(j) || ' Supplier ' || t_supp(j) || ' Supplier site ' || t_supp_site(j));
      ------------------------------------------------------------------
      -- getting the master item name
      ------------------------------------------------------------------

      t_master_item_name.EXTEND;
      t_master_item_desc.EXTEND;

      select item_name,
             description
      into   t_master_item_name(j),
             t_master_item_desc(j)
      from   msc_items
      where  inventory_item_id = t_item_id(j);


    end loop;
   end if;
    p_ret := 0;
    p_err := null ;
EXCEPTION
	WHEN others then
	    null;
	    --dbms_output.put_line('Error in get option info proc: ' || sqlerrm);
	    FND_FILE.PUT_LINE(FND_FILE.LOG, ' Error in get option info proc: ' || sqlerrm);
	 p_ret := 1;
	 p_err := sqlerrm ;

END get_optional_info;


PROCEDURE insert_into_sup_dem (
  p_err               OUT nocopy varchar2,
  p_ret               OUT nocopy number,
  p_plan_id		      IN number,
  p_horizon_start	      IN date,
  p_horizon_end		      IN date,
  p_type		      IN number,
  t_sr_instance_id	      IN numberList,
  t_org_id		      IN numberList,
  t_pub                       IN companyNameList,
  t_pub_id                    IN numberList,
  t_pub_site                  IN companySiteList,
  t_pub_site_id               IN numberList,
  t_base_item_id	      IN numberList,
  t_item_id                   IN numberList,
  t_bucket_type		      IN numberList,
  t_bucket_start	      IN dateList,
  t_bucket_end		      IN dateList,
  t_bucket_index	      IN numberList,
  t_qty                       IN numberList,
  t_total_qty		      IN numberList,
  t_temp_qty  		      IN numberList,
  t_item_name                 IN itemNameList,
  t_item_desc                 IN itemDescList,
  t_base_item_name	      IN itemNameList,
  t_proj_number               IN numberList,
  t_task_number               IN numberList,
  t_planning_gp               IN planningGroupList,
  t_uom_code                  IN itemUomList,
  t_planner_code              IN plannerCodeList,
  t_key_date                  IN dateList,
  t_master_item_name          IN itemNameList,
  t_master_item_desc          IN itemDescList,
  p_version                   IN varchar2,
  p_designator                IN varchar2,
  p_user_id                   IN number,
  p_language_code             IN varchar2
  ) IS


CURSOR get_bucket_date (p_plan_id in number,
			p_sr_instance_id in number,
			p_org_id in number,
			p_start_date in date,
			p_end_date in date) IS
SELECT mpb.bucket_index, trunc(mpb.bkt_start_date), trunc(mpb.bkt_end_date), mpb.bucket_type
FROM	 msc_plan_buckets mpb ,
          msc_plan_organizations_v ov         -- Bug# 3913477
WHERE	ov.plan_id = p_plan_id
  AND	ov.sr_instance_id = p_sr_instance_id
  AND	ov.planned_organization = p_org_id
  AND   mpb.plan_id = ov.plan_id
  AND   mpb.curr_flag = 1
  AND   bkt_start_date between nvl(p_start_date, mpb.bkt_start_date)
 	and nvl(p_end_date, mpb.bkt_end_date)
ORDER BY bucket_index;


t_ins_pub                       companyNameList;
t_ins_pub_id                    numberList;
t_ins_pub_site                  companySiteList;
t_ins_pub_site_id               numberList;
t_ins_item_id                   numberList;
t_ins_order_type		numberList;
t_ins_qty			numberList;
t_ins_item_name           	itemNameList;
t_ins_item_desc           	itemDescList;
t_ins_proj_number               numberList;
t_ins_task_number               numberList;
t_ins_planning_gp               planningGroupList;
t_ins_uom_code                  itemUomList ;
t_ins_planner_code              plannerCodeList;
t_ins_key_date                  dateList;
t_ins_ship_date                 dateList;
t_ins_receipt_date              dateList;
t_ins_master_item_name          itemNameList;
t_ins_master_item_desc          itemDescList;

t_days_in_bkt		    	numberList;
t_period_start_date	    	dateList;
t_pab_type		    	numberList;

b_bkt_index		    	numberList;
b_bkt_start_date	    	dateList;
b_bkt_end_date		    	dateList;
b_bkt_type		    	numberList;

l_order_type_desc               mfg_lookups.meaning%type;
l_log_message                   VARCHAR2(1000);
l_rowcount			number;
l_qty				number;
l_exp_qty			number;
l_record_inserted		number;
l_next_work_date		msc_calendar_dates.calendar_date%type;
l_prev_work_date		date;
l_bucket_type_desc		mfg_lookups.meaning%type;
l_date 				date;
l_total				number;
l_plan_start_date		date;

BEGIN

l_rowcount := 0;
l_record_inserted := 0;
l_total := 0;
t_ins_pub                       := companyNameList();
t_ins_pub_id                    := numberList();
t_ins_pub_site                  := companySiteList();
t_ins_pub_site_id               := numberList();
t_ins_item_id                   := numberList();
t_ins_order_type		:= numberList();
t_ins_qty			:= numberList();
t_ins_item_name           	:= itemNameList();
t_ins_item_desc           	:= itemDescList();
t_ins_proj_number               := numberList();
t_ins_task_number               := numberList();
t_ins_planning_gp               := planningGroupList();
t_ins_uom_code                  := itemUomList();
t_ins_planner_code              := plannerCodeList();
t_ins_key_date                  := dateList();
t_ins_ship_date                 := dateList();
t_ins_receipt_date              := dateList();
t_ins_master_item_name          := itemNameList();
t_ins_master_item_desc          := itemDescList();

t_days_in_bkt		    	:= numberList();
t_pab_type		    	:= numberList();
b_bkt_index		    	:= numberList();
b_bkt_type		    	:= numberList();


--dbms_output.put_line('Type ' || p_type || ' and count ' || t_pub_id.COUNT);
  IF (t_pub_id is not null and t_pub_id.COUNT >0 and p_type = SAFETY_STOCK )  THEN
       --l_log_message := get_message('MSC','MSC_X_PUB_NUM_RECORDS',p_language_code) ||
       --': ' || t_pub_id.COUNT || '.' || fnd_global.local_chr(10);
       --log_message(l_log_message);
-----------------------------------------------------

     FOR j in 1..t_pub_id.COUNT LOOP

     IF (t_pub_id(j) is not null AND
     	(j=1 OR (
     		t_sr_instance_id(j) <> t_sr_instance_id(j-1) OR
     		t_pub_id(j) <> nvl(t_pub_id(j-1), -99999) OR
   		t_pub_site_id(J) <> t_pub_site_id(j-1) OR
   		t_item_id(j) <> t_item_id(j-1) OR
   		t_bucket_index(j) - nvl(t_bucket_index(j-1), t_bucket_index(j) -1) = 1 )))THEN

   		l_order_type_desc := get_order_type (SAFETY_STOCK);
   		l_bucket_type_desc := msc_x_util.get_lookup_meaning('MSC_X_BUCKET_TYPE',t_bucket_type(j));
--dbms_output.Put_line('HERE insert ' || t_qty(j) || ' DATE ' || t_key_date(j));
--FND_FILE.PUT_LINE(FND_FILE.LOG, 'safety stock: ' || t_qty(j) ||  ' date ' || t_key_date(j));
--dbms_output.put_line('Org ' || t_org_id(j) || 'SR ' || t_sr_instance_id(j) || 'Bucket ' ||t_bucket_type(j) || 'Key date ' || t_key_date(j));

               -- IF (l_next_work_date = t_key_date(j)) THEN
  		IF (t_key_date(j) >= p_horizon_start and t_key_date(j) <= p_horizon_end ) THEN

        		insert into msc_sup_dem_entries (
           		transaction_id,
           		plan_id,
           		sr_instance_id,
           		publisher_name,
           		publisher_id,
           		publisher_site_name,
           		publisher_site_id,
           		publisher_order_type,
           		publisher_order_type_desc,
           		bucket_type_desc,
           		bucket_type,
           		inventory_item_id,
           		item_name,
           		owner_item_name,
           		item_description,
           		owner_item_description,
           		base_item_id,
           		base_item_name,
           		primary_uom,
           		uom_code,
           		tp_uom_code,
           		key_date,
           		new_schedule_date,
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
		        SAFETY_STOCK,
		        l_order_type_desc,
		        l_bucket_type_desc,
		        t_bucket_type(j),
		        t_item_id(j),
		        t_master_item_name(j),
		        t_item_name(j),
		        nvl(t_master_item_desc(j), t_item_desc(j)),
		        t_item_desc(j),
		        t_base_item_id(j),
		        t_base_item_name(j),
		        t_uom_code(j),
		        t_uom_code(j),
		        null,
		        t_key_date(j),
		        t_key_date(j),
		        t_qty(j),
		        t_qty(j),
		        null,
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
                  	l_record_inserted := l_record_inserted + 1;
                 END IF;

    ELSIF  (j > 1 AND t_pub_id(j) is not null AND
    	t_pub_id(j-1) is not null  AND
    	t_pub_id(j) = t_pub_id(j-1) AND
   	t_pub_site_id(j) = t_pub_site_id(j-1) AND t_item_id(j) = t_item_id(j-1) AND
   	t_bucket_index(j) - nvl(t_bucket_index(j-1), t_bucket_index(j) -1)  > 1 ) THEN
	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'safety stock: ' || t_qty(j) ||  'date ' || t_key_date(j));

        ----------------------------------------------------------------------
	--if the current record = the previous record (same plan_id, org_id,
	--sr_instance_id, item_id) and current bucket index prev record
	--bucket index <> 1, need to fill up the gap (before the safety stock
	--is changed)
	-----------------------------------------------------------------------
	----FND_FILE.PUT_LINE(FND_FILE.LOG, 'bucket j-1 ' || t_bucket_start(j-1));
	----FND_FILE.PUT_LINE(FND_FILE.LOG, 'bucket j ' || t_bucket_start(j));

	Open get_bucket_date (p_plan_id,
				t_sr_instance_id(j),
				t_org_id(j),
				t_bucket_start(j-1),
				t_bucket_start(j));
   	FETCH get_bucket_date BULK COLLECT INTO
			b_bkt_index,
			b_bkt_start_date,
			b_bkt_end_date,
	  		b_bkt_type;
	CLOSE get_bucket_date;

	l_qty := t_qty(j);

	IF b_bkt_index IS NOT NULL AND b_bkt_index.COUNT > 0 THEN

    		FOR k in 1..b_bkt_index.COUNT LOOP

			IF (k > 1) THEN

       				IF (k = b_bkt_index.COUNT) THEN
				      ----FND_FILE.PUT_LINE(FND_FILE.LOG, 'k = b_bkt_index.COUNT ' || b_bkt_index.COUNT);
       					b_bkt_end_date(k) := t_key_date(j);
       					l_qty := t_qty(j);
       					----FND_FILE.PUT_LINE(FND_FILE.LOG, 'end_date ' || b_bkt_end_date(k));
       				ELSE
       					--FND_FILE.PUT_LINE(FND_FILE.LOG, 'At 7d , j:  ' || j);
					l_qty := t_qty(j-1);

       				END IF;

 				l_order_type_desc := msc_x_util.get_lookup_meaning ('MSC_X_ORDER_TYPE', SAFETY_STOCK);
 				l_bucket_type_desc := msc_x_util.get_lookup_meaning('MSC_X_BUCKET_TYPE',b_bkt_type(k));
				--dbms_output.Put_line('insert for the gap ' || t_qty(j));


  				/**l_prev_work_date := msc_calendar.prev_work_day(t_org_id(j),
		       			t_sr_instance_id(j),
                       			1,
                       			b_bkt_end_date(k));
                       		**/

--dbms_output.put_line('Start ' || b_bkt_start_date(k) || ' End '  || b_bkt_end_date(k) );
--dbms_output.put_line(' prev ' || l_prev_work_date );
  		IF (b_bkt_end_date(k) >= p_horizon_start and b_bkt_end_date(k) <= p_horizon_end ) THEN

					insert into msc_sup_dem_entries (
				           transaction_id,
				           plan_id,
				           sr_instance_id,
				           publisher_name,
				           publisher_id,
				           publisher_site_name,
				           publisher_site_id,
				           publisher_order_type,
				           publisher_order_type_desc,
				           bucket_type_desc,
				           bucket_type,
				           inventory_item_id,
				           item_name,
				           owner_item_name,
				           item_description,
				           owner_item_description,
				           base_item_id,
				           base_item_name,
				           primary_uom,
				           uom_code,
				           tp_uom_code,
				           key_date,
				           new_schedule_date,
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
				        SAFETY_STOCK,
				        l_order_type_desc,
				        l_bucket_type_desc,
				        b_bkt_type(k),
				        t_item_id(j),
				        t_master_item_name(j),
				        t_item_name(j),
				        nvl(t_master_item_desc(j), t_item_desc(j)),
				        t_item_desc(j),
				        t_base_item_id(j),
				        t_base_item_name(j),
				        t_uom_code(j),
				        t_uom_code(j),
				        null,
				        b_bkt_end_date(k),	--l_prev_work_date,
				        b_bkt_end_date(k),	--l_prev_work_date,
				        l_qty,
				        l_qty,
				        null,
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

       			                l_record_inserted := l_record_inserted + 1;
       			END IF;		--- end horizon date range
			END IF;

            END LOOP;	-- FOR K LOOP
	    END IF;
         END IF;      --the if loop directly inside the for loop for j.

   /*-------------------------------------------------------------------------------
	-- Bug# 3913477 : for levelling safety stock after last safety stock data
	available in msc_safety_stocks table till plan_end_date or horizon_end_date
	whichever ends first.  The loop inserts data for MULTIORG case or MULTI_ITEM
	case whenever pub_id or pub_site_id( ORG_ID) or item_id changes.
    -------------------------------------------------------------------------------*/
IF (j > 1 AND
    	(t_pub_id(j) <> t_pub_id(j-1) OR
   	t_pub_site_id(j) <> t_pub_site_id(j-1) OR
        t_item_id(j) <> t_item_id(j-1)  ))    THEN

Open get_bucket_date (p_plan_id,
				t_sr_instance_id(j-1),
				t_org_id(j-1),
				t_bucket_start(j-1),
				p_horizon_end);
   	FETCH get_bucket_date BULK COLLECT INTO
			b_bkt_index,
			b_bkt_start_date,
			b_bkt_end_date,
	  		b_bkt_type;
	CLOSE get_bucket_date;

	IF b_bkt_index IS NOT NULL AND b_bkt_index.COUNT > 0 THEN

		FOR k in 1..b_bkt_index.COUNT LOOP


			IF (k > 1) THEN
					l_qty := t_qty(j-1);

       			        l_order_type_desc := msc_x_util.get_lookup_meaning ('MSC_X_ORDER_TYPE', SAFETY_STOCK);
 				l_bucket_type_desc := msc_x_util.get_lookup_meaning('MSC_X_BUCKET_TYPE',b_bkt_type(k));

       	IF (b_bkt_end_date(k) >= p_horizon_start and b_bkt_end_date(k) <= p_horizon_end ) THEN
  					insert into msc_sup_dem_entries (
				           transaction_id,
				           plan_id,
				           sr_instance_id,
				           publisher_name,
				           publisher_id,
				           publisher_site_name,
				           publisher_site_id,
				           publisher_order_type,
				           publisher_order_type_desc,
				           bucket_type_desc,
				           bucket_type,
				           inventory_item_id,
				           item_name,
				           owner_item_name,
				           item_description,
				           owner_item_description,
				           base_item_id,
				           base_item_name,
				           primary_uom,
				           uom_code,
				           tp_uom_code,
				           key_date,
				           new_schedule_date,
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
				        t_pub(j-1),
				        t_pub_id(j-1),
				        t_pub_site(j-1),
				        t_pub_site_id(j-1),
				        SAFETY_STOCK,
				        l_order_type_desc,
				        l_bucket_type_desc,
				        b_bkt_type(k),
				        t_item_id(j-1),
				        t_master_item_name(j-1),
				        t_item_name(j-1),
				        nvl(t_master_item_desc(j-1), t_item_desc(j-1)),
				        t_item_desc(j-1),
				        t_base_item_id(j-1),
				        t_base_item_name(j-1),
				        t_uom_code(j-1),
				        t_uom_code(j-1),
				        null,
				        b_bkt_end_date(k),	--l_prev_work_date,
				        b_bkt_end_date(k),	--l_prev_work_date,
				        l_qty,
				        l_qty,
				        null,
				        msc_cl_refresh_s.nextval,
				        t_pub(j-1),
				        t_pub_id(j-1),
				        nvl(p_user_id,-1),
				        sysdate,
				        nvl(p_user_id,-1),
				        sysdate,
				        t_proj_number(j-1),
				        t_task_number(j-1),
				        t_planning_gp(j-1),
				        t_planner_code(j-1),
				        p_version,
				        p_designator);

       			                l_record_inserted := l_record_inserted + 1;
       		                END IF;		--- end horizon date range
                              END IF;

	        	END LOOP;	-- FOR K LOOP
	           END IF;
	   END IF ;

     /*---------------------------------------------------------------------
       for inserting trailors for last data i.e. for SINGLE ORG case or
       in case of multiorg for the last pub_site_id(ORG_ID) or last item_id
       data available in table msc_safety_stock.
     ------------------------------------------------------------------------*/

IF (j = t_pub_id.COUNT) then
Open get_bucket_date (p_plan_id,
				t_sr_instance_id(j),
				t_org_id(j),
				t_bucket_start(j),
				p_horizon_end);
   	FETCH get_bucket_date BULK COLLECT INTO
			b_bkt_index,
			b_bkt_start_date,
			b_bkt_end_date,
	  		b_bkt_type;
	CLOSE get_bucket_date;

	IF b_bkt_index IS NOT NULL AND b_bkt_index.COUNT > 0 THEN

		FOR k in 1..b_bkt_index.COUNT LOOP

	         	IF (k > 1) THEN
					l_qty := t_qty(j);

       			        l_order_type_desc := msc_x_util.get_lookup_meaning ('MSC_X_ORDER_TYPE', SAFETY_STOCK);
 				l_bucket_type_desc := msc_x_util.get_lookup_meaning('MSC_X_BUCKET_TYPE',b_bkt_type(k));

       	IF (b_bkt_end_date(k) >= p_horizon_start and b_bkt_end_date(k) <= p_horizon_end ) THEN
  					insert into msc_sup_dem_entries (
				           transaction_id,
				           plan_id,
				           sr_instance_id,
				           publisher_name,
				           publisher_id,
				           publisher_site_name,
				           publisher_site_id,
				           publisher_order_type,
				           publisher_order_type_desc,
				           bucket_type_desc,
				           bucket_type,
				           inventory_item_id,
				           item_name,
				           owner_item_name,
				           item_description,
				           owner_item_description,
				           base_item_id,
				           base_item_name,
				           primary_uom,
				           uom_code,
				           tp_uom_code,
				           key_date,
				           new_schedule_date,
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
				        SAFETY_STOCK,
				        l_order_type_desc,
				        l_bucket_type_desc,
				        b_bkt_type(k),
				        t_item_id(j),
				        t_master_item_name(j),
				        t_item_name(j),
				        nvl(t_master_item_desc(j), t_item_desc(j)),
				        t_item_desc(j),
				        t_base_item_id(j),
				        t_base_item_name(j),
				        t_uom_code(j),
				        t_uom_code(j),
				        null,
				        b_bkt_end_date(k),	--l_prev_work_date,
				        b_bkt_end_date(k),	--l_prev_work_date,
				        l_qty,
				        l_qty,
				        null,
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

       			                l_record_inserted := l_record_inserted + 1;
       		                END IF;		--- end horizon date range
                             END IF;

	        	 END LOOP;	-- FOR K LOOP
	          END IF;
	        END IF ;

           END LOOP;
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Records to be inserted for safety stock : ' || l_record_inserted);
        --dbms_output.put_line( 'Records to be inserted for safety stock : ' || l_record_inserted);
        END IF; 	-- for safety stock



 --------------------------------------------------------
 -- projected avaiable balance
 --------------------------------------------------------
 --dbms_output.put_line('Start projected available balance');
 l_record_inserted := 0;
 l_total := 0;
 l_order_type_desc := get_order_type (PROJECTED_AVAILABLE_BALANCE);
 IF (t_pub_id is not null and t_pub_id.COUNT >0 and p_type = PROJECTED_AVAILABLE_BALANCE)  THEN

    SELECT plan_start_date
    INTO	l_plan_start_date
    FROM	msc_plans
    WHERE	plan_id = p_plan_id;

    FOR j in 1..t_pub_id.COUNT LOOP

    	/*----------------------------------------------------------------
    	 bug# 3893860 - Taking care of the past due PAB
    	 ----------------------------------------------------------------*/
    	IF (trunc(t_key_date(j)) < trunc(l_plan_start_date) and (
    		j = 1 or t_pub_id(j) is not null and t_pub_id(j-1) is not null AND
    			t_pub_id(j) = t_pub_id(j-1) AND
   			t_pub_site_id(j) = t_pub_site_id(j-1) AND
   			t_item_id(j) = t_item_id(j-1))) THEN

   		FND_FILE.PUT_LINE(FND_FILE.LOG, 'Compute PAB past due with plan start date ' || l_plan_start_date);
	   	l_exp_qty := nvl(t_temp_qty(j),0);
   		IF (l_exp_qty < 0) THEN
   		  	l_exp_qty:= 0;
  		END IF;
  		l_total:= t_total_qty(j) - l_exp_qty;
   		FND_FILE.PUT_LINE(FND_FILE.LOG, 'total ' || l_total || ' item ' || t_item_id(j) || ' Key date ' || t_key_date(j));
		l_bucket_type_desc := msc_x_util.get_lookup_meaning('MSC_X_BUCKET_TYPE',1);

			  IF (trunc(t_key_date(j)) >= trunc(p_horizon_start)) THEN
  		  	  	update msc_sup_dem_entries
  		  	  		set quantity = l_total,
  		  	      		primary_quantity = l_total
  		  	  	where publisher_id = t_pub_id(j)
  		  	  	and publisher_site_id = t_pub_site_id(j)
  		  	  	and inventory_item_id = t_item_id(j)
  		  	  	and publisher_order_type = PROJECTED_AVAILABLE_BALANCE
  		  	  	and trunc(key_date) = trunc(l_plan_start_date) -1 ;


  		  	  	l_rowcount := sql%ROWCOUNT;

  	 		  	l_bucket_type_desc := msc_x_util.get_lookup_meaning('MSC_X_BUCKET_TYPE',t_bucket_type(j));
  		  	  	IF l_rowcount = 0 THEN
  		  	  FND_FILE.PUT_LINE(FND_FILE.LOG, 'row count = 0' || 'Pub ' || t_pub(j) || 'Pub id ' || t_pub_id(j));
  		  	  	--dbms_output.put_line('row count = 0'|| 'Pub ' || t_pub(j) || 'Pub id ' || t_pub_id(j));
        			insert into msc_sup_dem_entries (
           			transaction_id,
           			plan_id,
           			sr_instance_id,
           			publisher_name,
           			publisher_id,
           			publisher_site_name,
           			publisher_site_id,
           			publisher_order_type,
           			publisher_order_type_desc,
           			bucket_type_desc,
           			bucket_type,
           			inventory_item_id,
           			item_name,
           			owner_item_name,
           			item_description,
           			owner_item_description,
           			base_item_id,
           			base_item_name,
           			primary_uom,
           			uom_code,
           			tp_uom_code,
           			key_date,
           			new_schedule_date,
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
		        	PROJECTED_AVAILABLE_BALANCE,
		        	l_order_type_desc,
		        	l_bucket_type_desc,
		        	t_bucket_type(j),
		        	t_item_id(j),
		        	t_master_item_name(j),
		        	t_item_name(j),
		        	nvl(t_master_item_desc(j), t_item_desc(j)),
		        	t_item_desc(j),
		        	t_base_item_id(j),
		        	t_base_item_name(j),
		        	t_uom_code(j),
		        	t_uom_code(j),
		        	null,
		        	l_plan_start_date - 1,		--t_key_date(j),
		        	l_plan_start_date - 1,		--t_key_date(j),
		        	l_total,
		        	l_total,
		        	null,
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
		              END IF;		--rowcount
		           l_record_inserted := l_record_inserted + 1;
		        END IF;

   	ELSIF  (j > 1 and t_pub_id(j) is not null and t_pub_id(j-1) is not null AND
    			t_pub_id(j) = t_pub_id(j-1) AND
   			t_pub_site_id(j) = t_pub_site_id(j-1) AND
   			t_item_id(j) = t_item_id(j-1) AND
   			t_key_date(j) <> t_key_date(j-1) AND
   			t_bucket_index(j) - nvl(t_bucket_index(j-1), t_bucket_index(j) -1) > 1 ) THEN

	--FND_FILE.PUT_LINE(FND_FILE.LOG, '2');
	l_exp_qty := nvl(t_temp_qty(j),0);
   	IF (l_exp_qty < 0) THEN
   		  l_exp_qty:= 0;
  	END IF;

	/*--dbms_output.put_line('HELLO' || 'PUB 1 ' || t_pub_id(j) || ' PUB2 ' || t_pub_id(j-1) ||
	' PUB SITE1 ' || t_pub_site_id(j) || ' PUB SITE2 ' || t_pub_site_id(j-1) ||
	' ITM 1 ' || t_item_id(j) || ' ITM 2' || t_item_id(j-1) ||
	' KEY 1 ' || t_key_date(j) || ' KEY2 ' || t_key_date(j-1) ||
	' INDEX 1 ' || t_bucket_index(j) || ' INDEX2 ' || t_bucket_index(j-1));
	*/
 	----------------------------------------------------------------------
	--if the current record has the same plan_id, org_id, sr_instance_id, item_id
	-- as the previous record different key date
	--and current bucket index prev record
	--bucket index <> 1, need to fill up the gap (before the pab
	--is changed)
	-----------------------------------------------------------------------
        ----FND_FILE.PUT_LINE(FND_FILE.LOG, 'bucket j-1 ' || t_bucket_start(j-1));
	----FND_FILE.PUT_LINE(FND_FILE.LOG, 'bucket j ' || t_bucket_start(j));

	Open get_bucket_date (p_plan_id,
				t_sr_instance_id(j),
				t_org_id(j),
				t_bucket_start(j-1),
				t_bucket_start(j));
   	FETCH get_bucket_date BULK COLLECT INTO
			b_bkt_index,
			b_bkt_start_date,
			b_bkt_end_date,
	  		b_bkt_type;
	CLOSE get_bucket_date;

	--l_total:= l_total + t_total_qty(j-1) - l_exp_qty;

	IF b_bkt_index IS NOT NULL AND b_bkt_index.COUNT > 0 THEN
	     FOR k in 1..b_bkt_index.COUNT LOOP

	              IF (k > 1) THEN

       				IF (k = b_bkt_index.COUNT) THEN
					----FND_FILE.PUT_LINE(FND_FILE.LOG, 'k = b_bkt_index.COUNT ' || b_bkt_index.COUNT);
         				b_bkt_end_date(k) := t_key_date(j);
       					l_total := t_total_qty(j) - l_exp_qty;
       					--FND_FILE.PUT_LINE(FND_FILE.LOG, 'end_date ' || b_bkt_end_date(k));

       				ELSE
       				   	l_exp_qty := nvl(t_temp_qty(j-1),0);
				   	IF (l_exp_qty < 0) THEN
				   		  l_exp_qty:= 0;
  					END IF;
       					l_total:= t_total_qty(j-1) - l_exp_qty;
				END IF;

 				l_order_type_desc := msc_x_util.get_lookup_meaning ('MSC_X_ORDER_TYPE', PROJECTED_AVAILABLE_BALANCE);
 				l_bucket_type_desc := msc_x_util.get_lookup_meaning('MSC_X_BUCKET_TYPE',b_bkt_type(k));
				--dbms_output.Put_line('fill gap ' || t_qty(j));
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'pab: ' || t_qty(j) ||  'date ' || t_key_date(j));

				/*
  				l_prev_work_date := msc_calendar.prev_work_day(t_org_id(j),
		       			t_sr_instance_id(j),
                       			1,
                       			b_bkt_end_date(k));
       				*/

				--dbms_output.put_line(' End ' || b_bkt_end_date(k) || ' prev ' || l_prev_work_date);

				IF (b_bkt_end_date(k) >= p_horizon_start ) THEN

                                  insert into msc_sup_dem_entries (
				           transaction_id,
				           plan_id,
				           sr_instance_id,
				           publisher_name,
				           publisher_id,
				           publisher_site_name,
				           publisher_site_id,
				           publisher_order_type,
				           publisher_order_type_desc,
				           bucket_type_desc,
				           bucket_type,
				           inventory_item_id,
				           item_name,
				           owner_item_name,
				           item_description,
				           owner_item_description,
				           base_item_id,
				           base_item_name,
				           primary_uom,
				           uom_code,
				           tp_uom_code,
				           key_date,
				           new_schedule_date,
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
				        PROJECTED_AVAILABLE_BALANCE,
				        l_order_type_desc,
				        l_bucket_type_desc,
				        b_bkt_type(k),
				        t_item_id(j),
				        t_master_item_name(j),
				        t_item_name(j),
				        nvl(t_master_item_desc(j), t_item_desc(j)),
				        t_item_desc(j),
				        t_base_item_id(j),
				        t_base_item_name(j),
				        t_uom_code(j),
				        t_uom_code(j),
				        null,
				        b_bkt_end_date(k),		--l_prev_work_date,
				        b_bkt_end_date(k),		--l_prev_work_date,
				        l_total,
				        l_total,
				        null,
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

       			                l_record_inserted := l_record_inserted + 1;
       			          END IF;
                        END IF;

		  END LOOP;	-- FOR K LOOP

		 END IF;

        ELSIF (t_pub_id(j) is not null and
	  		( j = 1 or  t_pub_id(j-1) is not null and (
	  			t_sr_instance_id(j) <> t_sr_instance_id(j-1) or
	  			t_pub_id(j) <> t_pub_id(j-1) or
	  			t_pub_site_id(j) <> t_pub_site_id(j-1) or
	  			t_item_id(j) <> t_item_id(j-1) or
	  			t_key_date(j) <> t_key_date(j-1) OR
	  			t_bucket_index(j) - nvl(t_bucket_index(j-1), t_bucket_index(j) -1) = 1))) THEN

		--FND_FILE.PUT_LINE(FND_FILE.LOG, '3');
		l_exp_qty := nvl(t_temp_qty(j),0);
   		IF (l_exp_qty < 0) THEN
   		  	l_exp_qty:= 0;
  		END IF;

  		l_total := t_total_qty(j);

		l_bucket_type_desc := msc_x_util.get_lookup_meaning('MSC_X_BUCKET_TYPE',t_bucket_type(j));

  		IF ( t_key_date(j) >= p_horizon_start) THEN
        	insert into msc_sup_dem_entries (
           		transaction_id,
           		plan_id,
           		sr_instance_id,
           		publisher_name,
           		publisher_id,
           		publisher_site_name,
           		publisher_site_id,
           		publisher_order_type,
           		publisher_order_type_desc,
           		bucket_type_desc,
           		bucket_type,
           		inventory_item_id,
           		item_name,
           		owner_item_name,
           		item_description,
           		owner_item_description,
           		base_item_id,
           		base_item_name,
           		primary_uom,
           		uom_code,
           		tp_uom_code,
           		key_date,
           		new_schedule_date,
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
		        PROJECTED_AVAILABLE_BALANCE,
		        l_order_type_desc,
		        l_bucket_type_desc,
		        t_bucket_type(j),
		        t_item_id(j),
		        t_master_item_name(j),
		        t_item_name(j),
		        nvl(t_master_item_desc(j), t_item_desc(j)),
		        t_item_desc(j),
		        t_base_item_id(j),
		        t_base_item_name(j),
		        t_uom_code(j),
		        t_uom_code(j),
		        null,
		        t_key_date(j),
		        t_key_date(j),
		        l_total - l_exp_qty,
		        l_total - l_exp_qty,
		        null,
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

		        l_record_inserted := l_record_inserted + 1;
  		  END IF;

  	ELSIF (t_pub_id(j) is not null) THEN


--FND_FILE.PUT_LINE(FND_FILE.LOG, 'Here 4 : j: ' || j ||' t_pub_id.COUNT '||t_pub_id.COUNT );

--dbms_output.put_line('update date ' || t_key_date(j) || ' qty '  || l_total || ' t tol ' || t_total_qty(j) || ' ex ' || l_exp_qty);

  		  	  l_rowcount := 0;
  		  	  l_exp_qty := nvl(t_temp_qty(j),0);
  		  	  IF (l_exp_qty < 0) THEN
  		  	  	l_exp_qty:= 0;
  		  	  END IF;

  		  	  l_total :=  t_total_qty(j) - l_exp_qty;


 --dbms_output.put_line('update date ' || t_key_date(j) || ' qty '  || l_total || ' t tol ' || t_total_qty(j) || ' ex ' || l_exp_qty);
  		  	  --dbms_output.put_line('update');
  		  	  IF (t_key_date(j) >= p_horizon_start) THEN
  		  	  	update msc_sup_dem_entries
  		  	  		set quantity = l_total,
  		  	      		primary_quantity = l_total
  		  	  	where publisher_id = t_pub_id(j)
  		  	  	and publisher_site_id = t_pub_site_id(j)
  		  	  	and inventory_item_id = t_item_id(j)
  		  	  	and publisher_order_type = PROJECTED_AVAILABLE_BALANCE
  		  	  	and trunc(key_date) = trunc(t_key_date(j));


  		  	  	l_rowcount := sql%ROWCOUNT;

  	 		  	l_bucket_type_desc := msc_x_util.get_lookup_meaning('MSC_X_BUCKET_TYPE',t_bucket_type(j));
  		  	  	IF l_rowcount = 0 THEN
  		  	  	FND_FILE.PUT_LINE(FND_FILE.LOG, 'row count = 0' || 'Pub ' || t_pub(j) || 'Pub id ' || t_pub_id(j));
  		  	  	--dbms_output.put_line('row count = 0'|| 'Pub ' || t_pub(j) || 'Pub id ' || t_pub_id(j));
        			insert into msc_sup_dem_entries (
           			transaction_id,
           			plan_id,
           			sr_instance_id,
           			publisher_name,
           			publisher_id,
           			publisher_site_name,
           			publisher_site_id,
           			publisher_order_type,
           			publisher_order_type_desc,
           			bucket_type_desc,
           			bucket_type,
           			inventory_item_id,
           			item_name,
           			owner_item_name,
           			item_description,
           			owner_item_description,
           			base_item_id,
           			base_item_name,
           			primary_uom,
           			uom_code,
           			tp_uom_code,
           			key_date,
           			new_schedule_date,
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
		        	PROJECTED_AVAILABLE_BALANCE,
		        	l_order_type_desc,
		        	l_bucket_type_desc,
		        	t_bucket_type(j),
		        	t_item_id(j),
		        	t_master_item_name(j),
		        	t_item_name(j),
		        	nvl(t_master_item_desc(j), t_item_desc(j)),
		        	t_item_desc(j),
		        	t_base_item_id(j),
		        	t_base_item_name(j),
		        	t_uom_code(j),
		        	t_uom_code(j),
		        	null,
		        	t_key_date(j),
		        	t_key_date(j),
		        	l_total,
		        	l_total,
		        	null,
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
		              END IF;		--rowcount
		           l_record_inserted := l_record_inserted + 1;
		       END IF;			-- key_date >= p_horizon_start

          END IF ;  -----to end block
   /*-------------------------------------------------------------------------
	-- Bug# 3913477 : for levelling PAB after last PAB data available
	in msc_safety_stocks table till plan_end_date or horizon_end_date
	whichever ends first. The loop inserts data for MULTIORG , MULTI_ITEM case
	whenever pub_id or pub_site_id( ORG_ID) or item_id changes.
       -------------------------------------------------------------------------*/

IF (j > 1 AND
    	(t_pub_id(j) <> t_pub_id(j-1) OR
   	t_pub_site_id(j) <> t_pub_site_id(j-1) OR
        t_item_id(j) <> t_item_id(j-1)  ))    THEN

Open get_bucket_date (p_plan_id,
				t_sr_instance_id(j-1),
				t_org_id(j-1),
				t_bucket_start(j-1),
				p_horizon_end);
   	FETCH get_bucket_date BULK COLLECT INTO
			b_bkt_index,
			b_bkt_start_date,
			b_bkt_end_date,
	  		b_bkt_type;
	CLOSE get_bucket_date;

	IF b_bkt_index IS NOT NULL AND b_bkt_index.COUNT > 0 THEN

		FOR k in 1..b_bkt_index.COUNT LOOP


			IF (k > 1) THEN
					l_exp_qty := nvl(t_temp_qty(j-1),0);
				   	IF (l_exp_qty < 0) THEN
				   		  l_exp_qty:= 0;
  					END IF;
       					l_total := t_total_qty(j-1) - l_exp_qty;

                                l_order_type_desc := msc_x_util.get_lookup_meaning ('MSC_X_ORDER_TYPE', PROJECTED_AVAILABLE_BALANCE);
 				l_bucket_type_desc := msc_x_util.get_lookup_meaning('MSC_X_BUCKET_TYPE',b_bkt_type(k));

       	IF (b_bkt_end_date(k) >= p_horizon_start and b_bkt_end_date(k) <= p_horizon_end ) THEN

                                 insert into msc_sup_dem_entries (
				           transaction_id,
				           plan_id,
				           sr_instance_id,
				           publisher_name,
				           publisher_id,
				           publisher_site_name,
				           publisher_site_id,
				           publisher_order_type,
				           publisher_order_type_desc,
				           bucket_type_desc,
				           bucket_type,
				           inventory_item_id,
				           item_name,
				           owner_item_name,
				           item_description,
				           owner_item_description,
				           base_item_id,
				           base_item_name,
				           primary_uom,
				           uom_code,
				           tp_uom_code,
				           key_date,
				           new_schedule_date,
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
				        t_pub(j-1),
				        t_pub_id(j-1),
				        t_pub_site(j-1),
				        t_pub_site_id(j-1),
				        PROJECTED_AVAILABLE_BALANCE,
				        l_order_type_desc,
				        l_bucket_type_desc,
				        b_bkt_type(k),
				        t_item_id(j-1),
				        t_master_item_name(j-1),
				        t_item_name(j-1),
				        nvl(t_master_item_desc(j-1), t_item_desc(j-1)),
				        t_item_desc(j-1),
				        t_base_item_id(j-1),
				        t_base_item_name(j-1),
				        t_uom_code(j-1),
				        t_uom_code(j-1),
				        null,
				        b_bkt_end_date(k),		--l_prev_work_date,
				        b_bkt_end_date(k),		--l_prev_work_date,
				        l_total,
				        l_total,
				        null,
				        msc_cl_refresh_s.nextval,
				        t_pub(j-1),
				        t_pub_id(j-1),
				        nvl(p_user_id,-1),
				        sysdate,
				        nvl(p_user_id,-1),
				        sysdate,
				        t_proj_number(j-1),
				        t_task_number(j-1),
				        t_planning_gp(j-1),
				        t_planner_code(j-1),
				        p_version,
				        p_designator);

       			                l_record_inserted := l_record_inserted + 1;
                              END IF;		--- end horizon date range

	                   END IF;

	        	END LOOP;	-- FOR K LOOP
	        END IF;

	END IF ;

     /*--------------------------------------------------------------------
       for inserting trailors for last data i.e. for SINGLE ORG case or
       in case of multiorg for the last pub_site_id(ORG_ID) or last item_id
       data available in tables.
     -----------------------------------------------------------------------*/


IF (j = t_pub_id.COUNT ) THEN

Open get_bucket_date (p_plan_id,
				t_sr_instance_id(j),
				t_org_id(j),
				t_bucket_start(j),
				p_horizon_end);
   	FETCH get_bucket_date BULK COLLECT INTO
			b_bkt_index,
			b_bkt_start_date,
			b_bkt_end_date,
	  		b_bkt_type;
	CLOSE get_bucket_date;

IF b_bkt_index IS NOT NULL AND b_bkt_index.COUNT > 0 THEN

        FOR k in 1..b_bkt_index.COUNT LOOP

			IF (k > 1) THEN
			l_exp_qty := nvl(t_temp_qty(j),0);
		  IF (l_exp_qty < 0) THEN
			l_exp_qty:= 0;
  		  END IF;
       		  l_total:= t_total_qty(j) - l_exp_qty;

                  l_order_type_desc := msc_x_util.get_lookup_meaning ('MSC_X_ORDER_TYPE', PROJECTED_AVAILABLE_BALANCE);
 		  l_bucket_type_desc := msc_x_util.get_lookup_meaning('MSC_X_BUCKET_TYPE',b_bkt_type(k));

IF (b_bkt_end_date(k) >= p_horizon_start and b_bkt_end_date(k) <= p_horizon_end  ) THEN

				     insert into msc_sup_dem_entries (
				           transaction_id,
				           plan_id,
				           sr_instance_id,
				           publisher_name,
				           publisher_id,
				           publisher_site_name,
				           publisher_site_id,
				           publisher_order_type,
				           publisher_order_type_desc,
				           bucket_type_desc,
				           bucket_type,
				           inventory_item_id,
				           item_name,
				           owner_item_name,
				           item_description,
				           owner_item_description,
				           base_item_id,
				           base_item_name,
				           primary_uom,
				           uom_code,
				           tp_uom_code,
				           key_date,
				           new_schedule_date,
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
				        PROJECTED_AVAILABLE_BALANCE,
				        l_order_type_desc,
				        l_bucket_type_desc,
				        b_bkt_type(k),
				        t_item_id(j),
				        t_master_item_name(j),
				        t_item_name(j),
				        nvl(t_master_item_desc(j), t_item_desc(j)),
				        t_item_desc(j),
				        t_base_item_id(j),
				        t_base_item_name(j),
				        t_uom_code(j),
				        t_uom_code(j),
				        null,
				        b_bkt_end_date(k),		--l_prev_work_date,
				        b_bkt_end_date(k),		--l_prev_work_date,
				        l_total,
				        l_total,
				        null,
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

       			                l_record_inserted := l_record_inserted + 1;

       			          END IF;

   			        END IF;

		END LOOP;	-- FOR K LOOP
		END IF;
          END IF ;

	END LOOP;   ---for outermost j block

   --dbms_output.put_line('Records to be inserted/updated for pab based on horizon date: ' || l_record_inserted);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Records to be inserted/updated for pab based on horizon date: ' || l_record_inserted);

   END IF;        --------to end PAB calculations
   	 p_ret := 0;
	 p_err := null ;
EXCEPTION
	when others then
		   --dbms_output.put_line('Error in insert_sup_dem_entries: ' || sqlerrm);
		   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in insert_sup_dem_entries. PSS program will not publish data. Error: ' || sqlerrm);
	 p_ret := 1;
	 p_err := sqlerrm ;
END insert_into_sup_dem;


PROCEDURE delete_old_safety_stock(
  p_plan_id                 in number,
  p_org_id                  in number,
  p_sr_instance_id          in number,
  p_planner_code            in varchar2,
  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_planning_gp             in varchar2,
  p_project_id              in number,
  p_task_id                 in number,
  p_horizon_start	    in date,
  p_horizon_end		    in date,
  p_overwrite		    in number
) IS

  l_row			number;

BEGIN
  --dbms_output.put_line('In delete_old_safety stock');


  IF ( p_overwrite = 1) THEN			--delete all
     delete from msc_sup_dem_entries sd
     where  sd.publisher_order_type in (SAFETY_STOCK, PROJECTED_AVAILABLE_BALANCE) and
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
                                           cs.company_id = 1
					   and  cs.company_site_id=sd.publisher_site_id and rownum=1)  and
         sd.inventory_item_id = nvl(p_item_id, sd.inventory_item_id);
         --and
         --NVL(sd.planner_code,'-99') = nvl(p_planner_code, NVL(sd.planner_code, '-99')) and
         --NVL(sd.planning_group,'-99') = nvl(p_planning_gp, NVL(sd.planning_group, '-99')) and
         --NVL(sd.project_number,'-99') = nvl(p_project_id, NVL(sd.project_number, '-99')) and
         --NVL(sd.task_number, '-99') = nvl(p_task_id, NVL(sd.task_number, '-99'));

     l_row := SQL%ROWCOUNT;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleted number records: ' || l_row);
     --dbms_output.put_line('Deleted number records: ' || l_row);
  ELSIF ( p_overwrite = 2) THEN			--delete by overwritten
       delete from msc_sup_dem_entries sd
       where  sd.publisher_order_type in (SAFETY_STOCK, PROJECTED_AVAILABLE_BALANCE) and
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
                                             cs.company_id = 1
					     and sd.publisher_site_id =cs.company_site_id and rownum=1)  and
           sd.inventory_item_id= nvl(p_item_id, sd.inventory_item_id)  and
           --NVL(sd.planner_code,'-99') = nvl(p_planner_code, NVL(sd.planner_code, '-99')) and
           --NVL(sd.planning_group,'-99') = nvl(p_planning_gp, NVL(sd.planning_group, '-99')) and
           --NVL(sd.project_number,'-99') = nvl(p_project_id, NVL(sd.project_number, '-99')) and
           --NVL(sd.task_number, '-99') = nvl(p_task_id, NVL(sd.task_number, '-99')) and
           key_date between nvl(p_horizon_start, sysdate - 36500) and
           	nvl(p_horizon_end, sysdate + 36500);
       l_row := SQL%ROWCOUNT;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleted number records: ' || l_row);
       --dbms_output.put_line('Deleted number records: ' || l_row);
  END IF;
  commit;

END delete_old_safety_stock;

PROCEDURE LOG_MESSAGE(
    p_string IN VARCHAR2
) IS
BEGIN
  IF fnd_global.conc_request_id > 0 THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, p_string);
    NULL;
  ELSE
    --dbms_OUTPUT.PUT_LINE( p_string);
    null;
  END IF;
END LOG_MESSAGE;

FUNCTION get_message (
  p_app  IN VARCHAR2,
  p_name IN VARCHAR2,
  p_lang IN VARCHAR2
) RETURN VARCHAR2 IS
  msg VARCHAR2(2000);
  CURSOR c1(app_name VARCHAR2, msg_name VARCHAR2, lang VARCHAR2) IS
  SELECT m.message_text
  FROM   fnd_new_messages m,
         fnd_application a
  WHERE  m.message_name = msg_name AND
         m.language_code = lang AND
         a.application_short_name = app_name AND
         m.application_id = a.application_id;
BEGIN

  msg := null;

  OPEN c1(p_app, p_name, p_lang);
  FETCH c1 INTO msg;
  IF (c1%NOTFOUND) then
    msg := p_name;
  END IF;
  CLOSE c1;
  RETURN msg;
END get_message;



--------------------------------------------------------------------------
-- Function GET_ORDER_TYPE
----------------------------------------------------------------------
FUNCTION GET_ORDER_TYPE(p_order_type_code in Number) RETURN Varchar2 IS
    l_order_type_desc   Varchar2(240);
BEGIN
  --Get the order type desc. Takes care of order type renaming.
  BEGIN
    select meaning
    into   l_order_type_desc
    from   mfg_lookups
    where  lookup_type = 'MSC_X_ORDER_TYPE'
    and    lookup_code = p_order_type_code;

    return l_order_type_desc;
  EXCEPTION
    WHEN OTHERS THEN
      l_order_type_desc := null;
      return l_order_type_desc;
  END;

END get_order_type;



END msc_publish_safety_stock_pkg;

/
