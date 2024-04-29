--------------------------------------------------------
--  DDL for Package Body MSC_GET_BIS_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_GET_BIS_VALUES" AS
/* $Header: MSCBISUB.pls 120.7.12010000.7 2010/04/21 18:36:46 pabram ship $  */

  g_plan_start_date DATE;
  g_period_zero_date date;
  g_plan_end_date DATE;
  j     binary_integer;
  g_param varchar2(3) :=':';

  g_use_old_demand_qty constant number := -1;

  INVENTORY_TURNS CONSTANT NUMBER :=1;
  ONTIME_DELIVERY CONSTANT NUMBER :=2;
  MARGIN_PERCENT CONSTANT NUMBER  :=3;
  UTILIZATION CONSTANT NUMBER     :=4;
  MARGIN_NUMBER CONSTANT NUMBER :=5;
  COST_BREAKDOWN CONSTANT NUMBER :=6;
  SERVICE_LEVEL CONSTANT NUMBER :=7;
  INVENTORY_VALUE CONSTANT NUMBER :=8;
  UTILIZATION2 CONSTANT NUMBER := 9;

  TYPE GlPeriodRecTyp IS RECORD (
         period_name VARCHAR2(15),
         start_date  DATE,
         end_date    DATE);

  TYPE GlPeriodTabTyp IS TABLE OF GlPeriodRecTyp INDEX BY BINARY_INTEGER;
  g_period_name   GlPeriodTabTyp;

  TYPE KPICurTyp IS REF CURSOR;
  g_org_id number;
  g_instance_id number;
  g_category_id number;
  g_category_name varchar2(250);
  g_category_set_id number;
  g_product_family_id number;
  g_item_id number;
  g_project_id number;
  g_task_id number;
  g_dept_id number;
  g_res_id number;
  g_res_instance_id number;  --ds Enhancement
  g_res_inst_serial_number varchar2(255);  --ds Enhancement
  g_dept_class varchar2(10);
  g_res_group varchar2(30);
  g_start_date date;
  g_end_date date;
  g_sup_id number;  --new
  g_sup_site_id number; -- new

  sql_statement varchar2(30000);

  CURSOR MARGIN_ORG_PF_CURSOR(l_plan_id number,
                           l_org_id number,
                           l_instance_id number,
                           l_product_family_id number) IS
  SELECT SUM(NVL(mds_price,0)), SUM(NVL(mds_cost,0)),
         sum(nvl(production_cost,0)),
         sum(nvl(purchasing_cost,0)),
         sum(nvl(demand_penalty_cost,0)+nvl(supplier_overcap_cost,0)),
         sum(nvl(carrying_cost,0))
  FROM msc_bis_inv_detail mbis
  WHERE mbis.organization_id = l_org_id
    AND mbis.sr_instance_id = l_instance_id
    AND mbis.plan_id = l_plan_id
    AND nvl(mbis.period_type,0) = 0  --mbis.mfg period changes
    and exists ( select 1
    from msc_bom_components mbc
    where mbc.organization_id = mbis.organization_id
    AND mbc.sr_instance_id = mbis.sr_instance_id
    AND mbc.plan_id = mbis.plan_id
    and mbc.inventory_item_id = mbis.inventory_item_id
    and mbc.using_assembly_id = l_product_family_id);

  CURSOR MARGIN_PF_CURSOR(l_plan_id number,
                           l_product_family_id number) IS
  SELECT SUM(NVL(mds_price,0)), SUM(NVL(mds_cost,0)),
         sum(nvl(production_cost,0)),
         sum(nvl(purchasing_cost,0)),
         sum(nvl(demand_penalty_cost,0)+nvl(supplier_overcap_cost,0)),
         sum(nvl(carrying_cost,0))
  FROM msc_bis_inv_detail mbis
  where mbis.plan_id = l_plan_id
    AND nvl(mbis.period_type,0) = 0  --mbis.mfg period changes
    and exists ( select 1
    from msc_bom_components mbc
    where mbc.organization_id = mbis.organization_id
    AND mbc.sr_instance_id = mbis.sr_instance_id
    AND mbc.plan_id = mbis.plan_id
    and mbc.inventory_item_id = mbis.inventory_item_id
    and mbc.using_assembly_id = l_product_family_id);

  CURSOR MARGIN_ORG_PF_DATE_CURSOR(l_plan_id number,
                           l_org_id number,
                           l_instance_id number,
                           l_product_family_id number,
                           v_start_date DATE ,
                           v_end_date DATE) IS
  SELECT SUM(NVL(mds_price,0)), SUM(NVL(mds_cost,0)),
         sum(nvl(production_cost,0)),
         sum(nvl(purchasing_cost,0)),
         sum(nvl(demand_penalty_cost,0)+nvl(supplier_overcap_cost,0)),
         sum(nvl(carrying_cost,0))
  FROM msc_bis_inv_detail mbis
  WHERE mbis.organization_id = l_org_id
    AND mbis.sr_instance_id = l_instance_id
    AND nvl(mbis.period_type,0) = 0  --mbis.mfg period changes
    and mbis.detail_date between v_start_date and v_end_date
    AND mbis.plan_id = l_plan_id
    and exists ( select 1
    from msc_bom_components mbc
    where mbc.organization_id = mbis.organization_id
    AND mbc.sr_instance_id = mbis.sr_instance_id
    AND mbc.plan_id = mbis.plan_id
    and mbc.inventory_item_id = mbis.inventory_item_id
    and mbc.using_assembly_id = l_product_family_id);

  CURSOR MARGIN_PF_DATE_CURSOR(l_plan_id number,
                           l_product_family_id number,
                           v_start_date DATE ,
                           v_end_date DATE) IS
  SELECT SUM(NVL(mds_price,0)), SUM(NVL(mds_cost,0)),
         sum(nvl(production_cost,0)),
         sum(nvl(purchasing_cost,0)),
         sum(nvl(demand_penalty_cost,0)+nvl(supplier_overcap_cost,0)),
         sum(nvl(carrying_cost,0))
  FROM msc_bis_inv_detail mbis
  where mbis.detail_date between v_start_date and v_end_date
    AND mbis.plan_id = l_plan_id
    AND nvl(mbis.period_type,0) = 0  --mbis.mfg period changes
    and exists ( select 1
    from msc_bom_components mbc
    where mbc.organization_id = mbis.organization_id
    AND mbc.sr_instance_id = mbis.sr_instance_id
    AND mbc.plan_id = mbis.plan_id
    and mbc.inventory_item_id = mbis.inventory_item_id
    and mbc.using_assembly_id = l_product_family_id);


  CURSOR MARGIN_ORG_CURSOR(l_plan_id number,
                           l_org_id number,
                           l_instance_id number) IS
  SELECT SUM(NVL(mds_price,0)), SUM(NVL(mds_cost,0)),
         sum(nvl(production_cost,0)),
         sum(nvl(purchasing_cost,0)),
         sum(nvl(demand_penalty_cost,0)),
         sum(nvl(carrying_cost,0))
  FROM msc_bis_inv_date_mv_tab
  WHERE organization_id = l_org_id
    AND sr_instance_id = l_instance_id
    AND plan_id = l_plan_id;

  CURSOR MARGIN_CURSOR(l_plan_id number) IS
  SELECT SUM(NVL(mds_price,0)), SUM(NVL(mds_cost,0)),
         sum(nvl(production_cost,0)),
         sum(nvl(purchasing_cost,0)),
         sum(nvl(demand_penalty_cost,0)),
         sum(nvl(carrying_cost,0))
  FROM msc_bis_inv_date_mv_tab
  WHERE plan_id = l_plan_id;

  CURSOR MARGIN_ORG_DATE_CURSOR(v_plan_id number,
                                v_org_id number,
                                v_instance_id number,
                                v_start_date DATE ,
                                v_end_date DATE) IS
  SELECT SUM(NVL(mds_price,0)), SUM(NVL(mds_cost,0)),
         sum(nvl(production_cost,0)),
         sum(nvl(purchasing_cost,0)),
         sum(nvl(demand_penalty_cost,0)),
         sum(nvl(carrying_cost,0))
  FROM msc_bis_inv_date_mv_tab
  WHERE organization_id = v_org_id
    AND sr_instance_id = v_instance_id
    and detail_date between v_start_date and v_end_date
    AND plan_id = v_plan_id;

  CURSOR MARGIN_DATE_CURSOR(v_plan_id number,
                                v_start_date DATE ,
                                v_end_date DATE) IS
  SELECT SUM(NVL(mds_price,0)), SUM(NVL(mds_cost,0)),
         sum(nvl(production_cost,0)),
         sum(nvl(purchasing_cost,0)),
         sum(nvl(demand_penalty_cost,0)),
         sum(nvl(carrying_cost,0))
  FROM msc_bis_inv_date_mv_tab
  WHERE detail_date between v_start_date and v_end_date
    AND plan_id = v_plan_id;

  CURSOR INV_VAL_CURSOR(v_plan_id number,
                        v_item_id number,
                                v_start_date DATE ,
                                v_end_date DATE) IS
  SELECT SUM(nvl(mbi.inventory_value,0)),
         SUM(NVL(mbi.mds_price,0)), SUM(NVL(mbi.mds_cost,0))
  FROM msc_bis_inv_detail mbi
  WHERE mbi.plan_id = v_plan_id
    AND nvl(mbi.period_type,0) = 0  --bis.mfg period changes
    and mbi.inventory_item_id = nvl(v_item_id,mbi.inventory_item_id)
    and mbi.detail_date between nvl(v_start_date, mbi.detail_date-1) and
                                nvl(v_end_date, mbi.detail_date+1)
;

  CURSOR INV_VAL_ORG_CURSOR(v_plan_id number,
                                v_org_id number,
                                v_instance_id number,
                                v_item_id number,
                                v_start_date DATE ,
                                v_end_date DATE) IS
  SELECT SUM(nvl(mbi.inventory_value,0)),
         SUM(NVL(mbi.mds_price,0)), SUM(NVL(mbi.mds_cost,0))
  FROM msc_bis_inv_detail mbi
  WHERE mbi.plan_id = v_plan_id
    AND mbi.organization_id = v_org_id
    AND mbi.sr_instance_id = v_instance_id
    AND nvl(mbi.period_type,0) = 0  --bis.mfg period changes
    and mbi.inventory_item_id = nvl(v_item_id, mbi.inventory_item_id)
    and mbi.detail_date between nvl(v_start_date, mbi.detail_date-1) and
                                nvl(v_end_date, mbi.detail_date+1)
;

  cursor c_plan_orgs (l_plan_id number) is
  select sr_instance_id, organization_id
  from msc_plan_organizations
  where plan_id = l_plan_id;



FUNCTION get_inventory_value(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER) return number IS
   p_out1 number;
   v_dummy number;
BEGIN
   if p_organization_id is not null then
      OPEN INV_VAL_ORG_CURSOR(p_plan_id, p_organization_id,
                            p_instance_id, p_item_id,null,null);
      FETCH INV_VAL_ORG_CURSOR into p_out1, v_dummy, v_dummy;
      CLOSE INV_VAL_ORG_CURSOR;
   else
      OPEN INV_VAL_CURSOR(p_plan_id,p_item_id,null,null);
      FETCH INV_VAL_CURSOR into p_out1, v_dummy, v_dummy;
      CLOSE INV_VAL_CURSOR;
   end if;

   return p_out1/g_period_name.LAST;
END get_inventory_value;

FUNCTION check_periods(p_plan_id IN NUMBER) RETURN NUMBER IS
v_period_count NUMBER;

CURSOR PERIOD_CURSOR IS
     SELECT mbp.period_name, mbp.start_date, mbp.end_date
     FROM   msc_bis_periods mbp,
            msc_plans mp
     WHERE  mbp.organization_id = mp.organization_id
     and    mbp.sr_instance_id = mp.sr_instance_id
     and ((mbp.start_date between nvl(mp.data_start_date, sysdate)
                            and mp.cutoff_date
         or mbp.end_date between nvl(mp.data_start_date,sysdate)
                            and mp.cutoff_date) or
  (mp.data_start_date between mbp.start_date and mbp.end_date))
     and mp.plan_id = p_plan_id
     and mbp.adjustment_period_flag ='N'
     order by mbp.start_date;

BEGIN

j:=1;

OPEN PERIOD_CURSOR;
   LOOP
   FETCH PERIOD_CURSOR into g_period_name(j);
   EXIT WHEN PERIOD_CURSOR%NOTFOUND;
 j := j+1;
   END LOOP;

   CLOSE PERIOD_CURSOR;
IF  j = 1 THEN
    v_period_count:=0;
ELSE
    v_period_count:=g_period_name.last;
END IF;

RETURN v_period_count;
END check_periods;



FUNCTION inventory_value_trend(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER
                     ) return VARCHAR2 IS
  p_out1 NUMBER;
  l_start_date DATE;
  l_end_date DATE;
  p_list varchar2(3000);
  v_dummy number;
BEGIN

FOR j in 1 .. g_period_name.LAST LOOP
     l_start_date := g_period_name(j).start_date;
     l_end_date := g_period_name(j).end_date;

   if p_organization_id is not null then
      OPEN INV_VAL_ORG_CURSOR(p_plan_id, p_organization_id,
                            p_instance_id, p_item_id,l_start_date,l_end_date);
      FETCH INV_VAL_ORG_CURSOR into p_out1, v_dummy, v_dummy;
      CLOSE INV_VAL_ORG_CURSOR;
   else
      OPEN INV_VAL_CURSOR(p_plan_id,p_item_id,l_start_date,l_end_date);
      FETCH INV_VAL_CURSOR into p_out1, v_dummy, v_dummy;
      CLOSE INV_VAL_CURSOR;
   end if;

   p_list := p_list ||g_param||
                     fnd_number.number_to_canonical(nvl(p_out1,0));

END LOOP;
   return p_list;
END inventory_value_trend;

PROCEDURE get_item_margin(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER,
                     p_out1 OUT NOCOPY NUMBER,
                     p_out2 OUT NOCOPY NUMBER,
                     p_out3 OUT NOCOPY NUMBER) IS
 v_revenue number;
 v_cost number;
 dummy number;
BEGIN
   if p_organization_id is not null then
        OPEN INV_VAL_ORG_CURSOR(p_plan_id, p_organization_id,
                            p_instance_id, p_item_id,null,null);
        FETCH INV_VAL_ORG_CURSOR into dummy, v_revenue, v_cost;
        CLOSE INV_VAL_ORG_CURSOR;
   else
        OPEN INV_VAL_CURSOR(p_plan_id,p_item_id,null,null);
        FETCH INV_VAL_CURSOR into dummy, v_revenue, v_cost;
        CLOSE INV_VAL_CURSOR;
   end if;
   p_out1 := v_revenue;
   p_out2 := v_cost;
   p_out3 := nvl(v_revenue,0) - nvl(v_cost,0);
END get_item_margin;

PROCEDURE get_item_margin_trend(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER,
                     p_out1 OUT NOCOPY VARCHAR2,
                     p_out2 OUT NOCOPY VARCHAR2,
                     p_out3 OUT NOCOPY VARCHAR2) IS
 v_revenue number;
 v_cost number;
 v_profit number;
 dummy number;
 l_start_date date;
 l_end_date date;
BEGIN
FOR j in 1 .. g_period_name.LAST LOOP
     l_start_date := g_period_name(j).start_date;
     l_end_date := g_period_name(j).end_date;
   if p_organization_id is not null then
        OPEN INV_VAL_ORG_CURSOR(p_plan_id, p_organization_id,
                            p_instance_id, p_item_id,l_start_date,l_end_date);
        FETCH INV_VAL_ORG_CURSOR into dummy, v_revenue, v_cost;
        CLOSE INV_VAL_ORG_CURSOR;
   else
        OPEN INV_VAL_CURSOR(p_plan_id,p_item_id,l_start_date,l_end_date);
        FETCH INV_VAL_CURSOR into dummy, v_revenue, v_cost;
        CLOSE INV_VAL_CURSOR;
   end if;

     v_revenue := nvl(v_revenue,0);
     v_cost := nvl(v_cost,0);
     v_profit := v_revenue - v_cost;
     p_out1 := p_out1 ||g_param||
                     fnd_number.number_to_canonical(v_revenue);
     p_out2 := p_out2 ||g_param||
                     fnd_number.number_to_canonical(v_cost);
     p_out3 := p_out3 ||g_param||
                     fnd_number.number_to_canonical(v_profit);

 END LOOP;
END get_item_margin_trend;

PROCEDURE get_margin(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_product_family_id IN NUMBER,
                     p_chart IN NUMBER,
                     p_out1 OUT NOCOPY NUMBER,
                     p_out2 OUT NOCOPY NUMBER,
                     p_out3 OUT NOCOPY NUMBER,
                     p_out4 OUT NOCOPY NUMBER,
                     p_out5 OUT NOCOPY NUMBER) IS

 v_revenue number;
 v_cost number;
 v_production number;
 v_purchasing number;
 v_service number;
 v_over_cost number;
 v_penalty number;
 v_inventory number;
 v_tp_cost number;
 v_exist boolean;

 CURSOR RES_ORG_CUR IS
  SELECT sum(nvl(overutilization_cost,0))
    FROM msc_bis_res_summary
   WHERE plan_id = p_plan_id
     AND nvl(period_type,0) = 0
     AND organization_id = p_organization_id;

 CURSOR RES_CUR IS
  SELECT sum(nvl(overutilization_cost,0))
    FROM msc_bis_res_summary
   WHERE plan_id = p_plan_id
     AND nvl(period_type,0) = 0;


  CURSOR CB_ORG_CURSOR(l_plan_id number,
                           l_org_id number,
                           l_instance_id number,
                           l_item_id number) IS

  SELECT sum(nvl(production_cost,0)),
         sum(nvl(purchasing_cost,0)),
         sum(nvl(carrying_cost,0))
  FROM msc_bis_inv_detail
  WHERE organization_id = l_org_id
    AND sr_instance_id = l_instance_id
    AND plan_id = l_plan_id
    AND nvl(period_type,0) = 0  --bis.mfg period changes
    and inventory_item_id = l_item_id;

  CURSOR CB_CURSOR(l_plan_id number,
                           l_item_id number) IS
  SELECT sum(nvl(production_cost,0)),
         sum(nvl(purchasing_cost,0)),
         sum(nvl(carrying_cost,0))
  FROM msc_bis_inv_detail
  where plan_id = l_plan_id
    AND nvl(period_type,0) = 0  --bis.mfg period changes
    and inventory_item_id = l_item_id;

BEGIN

if p_chart = SERVICE_LEVEL then
      v_service :=get_service_level(p_plan_id,
                     p_instance_id,
                     p_organization_id,
                     p_product_family_id, null, null, g_use_old_demand_qty);
else
if p_organization_id is not null then
  if p_product_family_id is not null then
    if p_chart = COST_BREAKDOWN then
       OPEN CB_ORG_CURSOR(p_plan_id, p_organization_id,
                            p_instance_id, p_product_family_id);
       FETCH CB_ORG_CURSOR into
                                  v_production,
                                  v_purchasing,
                                  v_inventory;
       CLOSE CB_ORG_CURSOR;
    else
       OPEN MARGIN_ORG_PF_CURSOR(p_plan_id, p_organization_id,
                            p_instance_id, p_product_family_id);
       FETCH MARGIN_ORG_PF_CURSOR into v_revenue, v_cost,
                                  v_production,
                                  v_purchasing,
                                  v_penalty,
                                  v_inventory;
       CLOSE MARGIN_ORG_PF_CURSOR;
     end if;
  else  -- org is not null, item is null
     OPEN MARGIN_ORG_CURSOR(p_plan_id, p_organization_id, p_instance_id);
     FETCH MARGIN_ORG_CURSOR into v_revenue, v_cost,
                                  v_production,
                                  v_purchasing,
                                  v_penalty,
                                  v_inventory;
     CLOSE MARGIN_ORG_CURSOR;
        if p_chart = COST_BREAKDOWN then
          OPEN RES_ORG_CUR;
          FETCH RES_ORG_CUR INTO v_over_cost;
          CLOSE RES_ORG_CUR;
        v_penalty := nvl(v_penalty,0) + nvl(v_over_cost,0);
     end if;
  end if;
else  -- org is null
  if p_product_family_id is not null then
     if p_chart = COST_BREAKDOWN then
       OPEN CB_CURSOR(p_plan_id, p_product_family_id);
       FETCH CB_CURSOR into
                                  v_production,
                                  v_purchasing,
                                  v_inventory;
       CLOSE CB_CURSOR;
     else
       OPEN MARGIN_PF_CURSOR(p_plan_id, p_product_family_id);
       FETCH MARGIN_PF_CURSOR into v_revenue, v_cost,
                                  v_production,
                                  v_purchasing,
                                  v_penalty,
                                  v_inventory;
       CLOSE MARGIN_PF_CURSOR;
     end if;
  else  -- org is null and item is null
     OPEN MARGIN_CURSOR(p_plan_id);
     FETCH MARGIN_CURSOR into v_revenue, v_cost,
                                  v_production,
                                  v_purchasing,
                                  v_penalty,
                                  v_inventory;
     CLOSE MARGIN_CURSOR;

     if p_chart = COST_BREAKDOWN then
        OPEN RES_CUR;
        FETCH RES_CUR INTO v_over_cost;
        CLOSE RES_CUR;
        v_penalty := nvl(v_penalty,0) + nvl(v_over_cost,0);
     end if;
  end if;
end if;
end if;
if p_chart = COST_BREAKDOWN then
   p_out1 := v_production;
   p_out2 := v_purchasing;
   p_out3 := v_penalty;
   p_out4 := v_inventory;
   v_tp_cost := msc_get_bis_values.get_tp_cost(p_plan_id,
	p_instance_id, p_organization_id, p_product_family_id, null, null);
   p_out5 := v_tp_cost;
elsif p_chart = SERVICE_LEVEL then
   p_out1 := v_service;

else
   p_out1 := v_revenue;
   p_out2 := v_cost;
   p_out3 := nvl(v_revenue,0) - nvl(v_cost,0);
end if;
END;

PROCEDURE get_margin_trend(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_product_family_id IN NUMBER,
                     p_chart IN NUMBER,
                     p_out1 OUT NOCOPY VARCHAR2,
                     p_out2 OUT NOCOPY VARCHAR2,
                     p_out3 OUT NOCOPY VARCHAR2,
                     p_out4 OUT NOCOPY VARCHAR2,
                     p_out5 OUT NOCOPY VARCHAR2
                     ) IS

  v_revenue NUMBER;
  v_cost    NUMBER;
  v_profit  NUMBER;
  v_production number;
  v_purchasing number;
  v_service number;
  v_over_cost number;
  v_tp_cost number;
  v_penalty number;
  v_inventory number;
  l_start_date DATE;
  l_end_date DATE;
  dummy number;
  v_exist boolean;

 CURSOR RES_ORG_DATE_CUR IS
  SELECT sum(nvl(overutilization_cost,0))
    FROM msc_bis_res_summary
   WHERE plan_id = p_plan_id
     AND organization_id = p_organization_id
     AND nvl(period_type,0) = 0
     AND resource_date between l_start_date and l_end_Date;

 CURSOR RES_DATE_CUR IS
  SELECT sum(nvl(overutilization_cost,0))
    FROM msc_bis_res_summary
   WHERE plan_id = p_plan_id
     AND nvl(period_type,0) = 0
     AND resource_date between l_start_date and l_end_Date;

  CURSOR CB_ORG_CURSOR(l_plan_id number,
                           l_org_id number,
                           l_instance_id number,
                           l_item_id number) IS

  SELECT sum(nvl(production_cost,0)),
         sum(nvl(purchasing_cost,0)),
         sum(nvl(carrying_cost,0))
  FROM msc_bis_inv_detail
  WHERE organization_id = l_org_id
    AND sr_instance_id = l_instance_id
    AND plan_id = l_plan_id
    AND nvl(period_type,0) = 0  --bis.mfg period changes
    and inventory_item_id = l_item_id
    and detail_date between l_start_date and l_end_date;

  CURSOR CB_CURSOR(l_plan_id number,
                           l_item_id number) IS
  SELECT sum(nvl(production_cost,0)),
         sum(nvl(purchasing_cost,0)),
         sum(nvl(carrying_cost,0))
  FROM msc_bis_inv_detail
  where plan_id = l_plan_id
    and inventory_item_id = l_item_id
    AND nvl(period_type,0) = 0  --bis.mfg period changes
    and detail_date between l_start_date and l_end_date;

BEGIN

FOR j in 1 .. g_period_name.LAST LOOP
     l_start_date := g_period_name(j).start_date;
     l_end_date := g_period_name(j).end_date;

if p_chart = SERVICE_LEVEL then
   v_service :=get_service_level(p_plan_id,
                     p_instance_id,
                     p_organization_id,
                     p_product_family_id,
                     l_start_date,
                     l_end_date, g_use_old_demand_qty);
else
 if p_chart = COST_BREAKDOWN then
      v_tp_cost := msc_get_bis_values.get_tp_cost(p_plan_id,
	p_instance_id, p_organization_id, p_product_family_id, l_start_date, l_end_date);
 end if;
 if p_organization_id is not null then
  if p_product_family_id is not null then
    if p_chart = COST_BREAKDOWN then
       OPEN CB_ORG_CURSOR(p_plan_id, p_organization_id,
                            p_instance_id, p_product_family_id);
       FETCH CB_ORG_CURSOR into
                                  v_production,
                                  v_purchasing,
                                  v_inventory;
       CLOSE CB_ORG_CURSOR;
    else
       OPEN MARGIN_ORG_PF_DATE_CURSOR(p_plan_id, p_organization_id,
                            p_instance_id, p_product_family_id,
                            l_start_date, l_end_date);
       FETCH MARGIN_ORG_PF_DATE_CURSOR into v_revenue, v_cost,
                                  v_production,
                                  v_purchasing,
                                  v_penalty,
                                  v_inventory;
        CLOSE MARGIN_ORG_PF_DATE_CURSOR;
    end if;
  else  -- org is not null, item is null
     OPEN MARGIN_ORG_DATE_CURSOR(p_plan_id,p_organization_id, p_instance_id,
                                 l_start_date, l_end_date);
     FETCH MARGIN_ORG_DATE_CURSOR into v_revenue, v_cost,
                                  v_production,
                                  v_purchasing,
                                  v_penalty,
                                  v_inventory;
     CLOSE MARGIN_ORG_DATE_CURSOR;

     if p_chart = COST_BREAKDOWN then
        OPEN RES_ORG_DATE_CUR;
        FETCH RES_ORG_DATE_CUR INTO v_over_cost;
        CLOSE RES_ORG_DATE_CUR;
        v_penalty := nvl(v_penalty,0) + nvl(v_over_cost,0);
     end if;
  end if;
 else -- org is null
  if p_product_family_id is not null then
     if p_chart = COST_BREAKDOWN then
       OPEN CB_CURSOR(p_plan_id, p_product_family_id);
       FETCH CB_CURSOR into
                                  v_production,
                                  v_purchasing,
                                  v_inventory;
       CLOSE CB_CURSOR;
     else
       OPEN MARGIN_PF_DATE_CURSOR(p_plan_id, p_product_family_id,
                            l_start_date, l_end_date);
       FETCH MARGIN_PF_DATE_CURSOR into v_revenue, v_cost,
                                  v_production,
                                  v_purchasing,
                                  v_penalty,
                                  v_inventory;
       CLOSE MARGIN_PF_DATE_CURSOR;
     end if;
  else -- org is null, item is null
     OPEN MARGIN_DATE_CURSOR(p_plan_id,l_start_date, l_end_date);
     FETCH MARGIN_DATE_CURSOR into v_revenue, v_cost,
                                  v_production,
                                  v_purchasing,
                                  v_penalty,
                                  v_inventory;
     CLOSE MARGIN_DATE_CURSOR;

     if p_chart = COST_BREAKDOWN then
        OPEN RES_DATE_CUR;
        FETCH RES_DATE_CUR INTO v_over_cost;
        CLOSE RES_DATE_CUR;
        v_penalty := nvl(v_penalty,0) + nvl(v_over_cost,0);
     end if;
   end if;
end if;
end if;
if p_chart = MARGIN_NUMBER then
     v_revenue := nvl(v_revenue,0);
     v_cost := nvl(v_cost,0);
     v_profit := v_revenue - v_cost;

     p_out1 := p_out1 ||g_param||
                     fnd_number.number_to_canonical(v_revenue);
     p_out2 := p_out2 ||g_param||
                     fnd_number.number_to_canonical(v_cost);
     p_out3 := p_out3 ||g_param||
                     fnd_number.number_to_canonical(v_profit);
elsif p_chart =COST_BREAKDOWN then
     p_out1 := p_out1 ||g_param||
                     fnd_number.number_to_canonical(nvl(v_production,0));
     p_out2 := p_out2 ||g_param||
                     fnd_number.number_to_canonical(nvl(v_purchasing,0));
     p_out3 := p_out3 ||g_param||
                     fnd_number.number_to_canonical(nvl(v_penalty,0));
     p_out4 := p_out4 ||g_param||
                     fnd_number.number_to_canonical(nvl(v_inventory,0));
     p_out5 := p_out5 ||g_param||
                     fnd_number.number_to_canonical(nvl(v_tp_cost,0));
elsif p_chart =SERVICE_LEVEL then
     p_out1 := p_out1 ||g_param||
                     fnd_number.number_to_canonical(nvl(v_service,0));
end if;
  END LOOP;

END;


PROCEDURE get_margin_by_org(p_plan_id IN NUMBER,
                            p_row_count OUT NOCOPY NUMBER,
                            p_org OUT NOCOPY VARCHAR2,
                            p_margin OUT NOCOPY VARCHAR2) IS

  CURSOR MARGIN_ORG_CURSOR IS
  SELECT  msc_get_name.org_code(profit.organization_id,
                               profit.sr_instance_id),
         SUM(NVL(profit.mds_price,0)),
         SUM(NVL(profit.mds_cost,0))
  FROM msc_bis_inv_detail profit
  WHERE profit.plan_id = p_plan_id
  AND nvl(profit.period_type,0) = 0  --bis.mfg period changes
  GROUP BY 1;

  revenue number;
  cost number;
  margin number;
  org varchar2(200);

BEGIN
  p_row_count :=0;
  OPEN MARGIN_ORG_CURSOR;
  LOOP
     FETCH MARGIN_ORG_CURSOR into org, revenue, cost;
     EXIT WHEN MARGIN_ORG_CURSOR%NOTFOUND;
     p_row_count := p_row_count+1;
     revenue := nvl(revenue,0);
     cost :=nvl(cost,0);
     if revenue = 0 Then
        margin :=0;
     else
        margin := (revenue-cost)/revenue;
     end if;
     p_margin := p_margin || g_param ||
                   fnd_number.number_to_canonical(margin);
     p_org := p_org ||g_param || org;

  END LOOP;
  CLOSE MARGIN_ORG_CURSOR;

END;

-- ==============================================================
--   Function to obtain number of sales orders
--    that are late for a plan
-- ==============================================================
FUNCTION late_orders(arg_plan_id IN NUMBER,
                       arg_instance_id IN NUMBER,
                       arg_organization_id    IN NUMBER,
                       arg_start_date           IN DATE,
			arg_end_date		IN DATE,
                        arg_inventory_item_Id   IN NUMBER DEFAULT NULL,
                        arg_project_id IN NUMBER DEFAULT NULL,
                        arg_task_id IN NUMBER DEFAULT NULL,
                        arg_category_id IN NUMBER DEFAULT NULL,
                        arg_category_name IN VARCHAR2 DEFAULT NULL,
                        arg_category_set_id IN NUMBER DEFAULT NULL,
                        arg_product_family_id IN NUMBER DEFAULT NULL)
RETURN NUMBER IS
  TYPE CurTyp IS REF CURSOR;
  late_order_cursor CurTyp;
  late_count    NUMBER;
  sql_statement varchar2(30000);

BEGIN

  if arg_start_date is null and
     arg_end_date is null and
     arg_inventory_item_id is null and
     arg_project_id is null and
     arg_task_id is null and
     arg_category_id is null and
     arg_category_name is null and
     arg_product_family_id is null then

       sql_statement := ' SELECT sum(mbis.late_order_count) ' ||
                      ' FROM msc_late_order_mv_tab mbis' ||
                      ' WHERE mbis.plan_id = :1 ';
   else
       sql_statement := ' SELECT count(distinct mbis.number1) ' ||
                      ' FROM msc_exception_details mbis' ||
                      ' WHERE mbis.plan_id = :1 '||
                        ' AND mbis.exception_type in (13,14,24,26) '||
                        ' AND mbis.number1 is not null ';
   end if;
     sql_statement := sql_statement ||
           construct_bis_where(true,arg_organization_id, arg_instance_id,
                               arg_inventory_item_id, arg_project_id,
                               arg_task_id, arg_category_id,arg_category_name,
                               arg_category_set_id, arg_product_family_id,
                               arg_start_date, arg_end_date);
  OPEN late_order_cursor FOR sql_statement USING arg_plan_id,
            g_org_id, g_instance_id, g_item_id,
            g_project_id,g_task_id, g_category_id,
            g_category_set_id, g_category_name,g_product_family_id,
            g_start_date,g_end_date;


  FETCH late_order_cursor INTO late_count;
  CLOSE late_order_cursor;

  if late_count is null then
     late_count :=0;
  end if;

  return late_count;
END late_orders;

Procedure populate_plan_date(p_plan_id IN NUMBER) IS

   CURSOR PERIOD_CURSOR IS
     SELECT mbp.period_name, mbp.start_date, mbp.end_date
     FROM   msc_bis_periods mbp,
            msc_plans mp
     WHERE  mbp.organization_id = mp.organization_id
     and    mbp.sr_instance_id = mp.sr_instance_id
     and ((mbp.start_date between nvl(mp.data_start_date, sysdate)
                            and mp.cutoff_date
         or mbp.end_date between nvl(mp.data_start_date,sysdate)
                            and mp.cutoff_date) or
           (mp.data_start_date between mbp.start_date and mbp.end_date))
     and mp.plan_id = p_plan_id
     and mbp.adjustment_period_flag ='N'
     order by mbp.start_date;

   CURSOR PERIOD_ZERO_CURSOR IS
     SELECT mbp.start_date
     FROM   msc_bis_periods mbp,
            msc_plans mp
     WHERE  mbp.organization_id = mp.organization_id
     and    mbp.sr_instance_id = mp.sr_instance_id
     and    mbp.start_date < g_plan_start_date
     and mp.plan_id = p_plan_id
     and mbp.adjustment_period_flag ='N'
     order by mbp.start_date desc;

BEGIN

if p_plan_id <> -1 then
   j :=1;

   OPEN PERIOD_CURSOR;
   LOOP
   FETCH PERIOD_CURSOR into g_period_name(j);
   EXIT WHEN PERIOD_CURSOR%NOTFOUND;
      j := j+1;
   END LOOP;
   CLOSE PERIOD_CURSOR;

   g_plan_start_date := g_period_name(1).start_date;
   g_plan_end_date := g_period_name(j-1).start_date;


else
   select nvl(mp.data_start_date,sysdate), mp.cutoff_date
   into g_plan_start_date, g_plan_end_date
   from msc_plans mp
   where plan_id =-1;

   g_period_name(1).start_date := g_plan_start_date;
   g_period_name(1).end_date := g_plan_end_date-1;
   g_period_name(1).period_name := to_char(g_plan_start_date,'MON-RR');

end if;

   OPEN PERIOD_ZERO_CURSOR;
   FETCH PERIOD_ZERO_CURSOR into g_period_zero_date;
   CLOSE PERIOD_ZERO_CURSOR;
END;

PROCEDURE get_period_name (p_period_list OUT NOCOPY VARCHAR2,
                           p_period_count OUT NOCOPY NUMBER) IS
BEGIN
   p_period_list :=null;


   For j in 1 .. g_period_name.last LOOP
      p_period_list := p_period_list || g_param ||
                       g_period_name(j).period_name;
   END LOOP;

   p_period_count := g_period_name.last;


END;

-- ======================================================================
-- Function to get actual plan values for the Enterprise Plan Performance
-- Summary and Organization reports.  If organization_id is passed in as
-- NULL then results for all orgs are returned
-- ======================================================================
FUNCTION get_actuals(p_plan_id IN NUMBER,
                        p_instance_id IN NUMBER,
			p_organization_id IN NUMBER,
			i IN NUMBER,
                        p_inventory_item_id IN NUMBER DEFAULT NULL,
                        p_project_id IN NUMBER DEFAULT NULL,
                        p_task_id IN NUMBER DEFAULT NULL,
                        p_dept_id IN NUMBER DEFAULT NULL,
                        p_res_id IN NUMBER DEFAULT NULL,
                        p_dept_class IN VARCHAR2 DEFAULT NULL,
                        p_res_group IN VARCHAR2 DEFAULT NULL,
                        p_category_id IN NUMBER DEFAULT NULL,
                        p_category_name IN VARCHAR2 DEFAULT NULL,
                        p_category_set_id IN NUMBER DEFAULT NULL,
                        p_product_family_id IN NUMBER DEFAULT NULL,
                        p_sup_id IN NUMBER DEFAULT NULL,
                        p_sup_site_id IN NUMBER DEFAULT NULL,
			p_res_instance_id IN NUMBER DEFAULT NULL ,
			p_res_inst_serial_number IN varchar2 DEFAULT NULL)  --ds enhancement
RETURN NUMBER IS

  kpi_cursor KPICurTyp;


  l_value1		NUMBER := 0;
  l_value2		NUMBER := 0;
  l_value3		NUMBER := 0;
  l_days number;
  dummy number;
  l_stat varchar2(255);
  v_cat_name varchar2(300);
BEGIN
  IF i=1 THEN
  if p_inventory_item_id is null and
     p_project_id is null and
     p_task_id is null and
     p_product_family_id is null then

    if p_category_id is null and p_category_name is null then
       sql_statement := ' SELECT '||
       ' SUM(nvl(mbis.mds_cost,0)) '||
       ' FROM msc_bis_inv_date_mv_tab mbis' ||
       ' WHERE mbis.plan_id = :1 ';
       sql_statement := sql_statement ||
        construct_bis_where(false,p_organization_id, p_instance_id,
                             p_inventory_item_id, p_project_id, p_task_id,
                             null, null, p_category_set_id,
                             p_product_family_id);
    else
         if p_category_name is not null then
            v_cat_name := '-1:'||p_category_name;
         else
            v_cat_name := null;
         end if;
       sql_statement := ' SELECT '||
       ' SUM(nvl(mbis.mds_cost,0)) '||
       ' FROM msc_bis_inv_cat_mv_tab mbis' ||
       ' WHERE mbis.plan_id = :1 ';
       sql_statement := sql_statement ||
        construct_bis_where(false,p_organization_id, p_instance_id,
                            p_inventory_item_id, p_project_id, p_task_id,
                            -1*p_category_id,v_cat_name,
                            p_category_set_id,p_product_family_id);
    end if;
   else

    sql_statement := ' SELECT '||
       ' SUM(nvl(mbis.mds_cost,0)) '||
       ' FROM msc_bis_inv_detail mbis' ||
       ' WHERE mbis.plan_id = :1 and nvl(mbis.period_type,0) = 0';
    sql_statement := sql_statement ||
         construct_bis_where(false,p_organization_id, p_instance_id,
                             p_inventory_item_id, p_project_id, p_task_id,
                             p_category_id, p_category_name,p_category_set_id,
                             p_product_family_id);
   end if;

  OPEN kpi_cursor FOR sql_statement USING
            p_plan_id,
            g_org_id, g_instance_id, g_item_id,
            g_project_id,g_task_id, g_category_id,
            g_category_set_id,g_category_name,g_product_family_id;

  FETCH kpi_cursor INTO l_value1;
  CLOSE kpi_cursor;

    IF l_value1 = 0 or l_value1 is null THEN
      RETURN 0;

    ELSE

  if p_inventory_item_id is null and
     p_project_id is null and
     p_task_id is null and
     p_product_family_id is null then

     if p_category_id is null and p_category_name is null then
        sql_statement := ' SELECT '||
         ' SUM(nvl(mbis.inventory_cost,0)) '||
         ' FROM msc_bis_inv_date_mv_tab mbis ' ||
         ' WHERE mbis.plan_id = :1 '||
         '   AND mbis.detail_date = :7 ';
       sql_statement := sql_statement ||
        construct_bis_where(false,p_organization_id, p_instance_id,
                             p_inventory_item_id, p_project_id, p_task_id,
                             null, null, p_category_set_id,
                             p_product_family_id);
     else
        sql_statement := ' SELECT '||
         ' SUM(nvl(mbis.inventory_cost,0)) '||
         ' FROM msc_bis_inv_cat_mv_tab mbis ' ||
         ' WHERE mbis.plan_id = :1 '||
         '   AND mbis.detail_date = :7 ';
         if p_category_name is not null then
            v_cat_name := '-1:'||p_category_name;
         else
            v_cat_name := null;
         end if;

       sql_statement := sql_statement ||
         construct_bis_where(false,p_organization_id, p_instance_id,
                             p_inventory_item_id, p_project_id, p_task_id,
                             -1*p_category_id, v_cat_name,
                             p_category_set_id,
                             p_product_family_id);
     end if;


  else
      sql_statement := ' SELECT '||
       ' SUM(nvl(mbis.inventory_cost,0)) '||
       ' FROM msc_bis_inv_detail mbis ' ||
       ' WHERE mbis.plan_id = :1 and nvl(mbis.period_type,0) = 0 '||
       '   AND mbis.detail_date = :7 ';

      sql_statement := sql_statement ||
         construct_bis_where(false,p_organization_id, p_instance_id,
                             p_inventory_item_id, p_project_id, p_task_id,
                             p_category_id, p_category_name,p_category_set_id,
                             p_product_family_id);
  end if;


      OPEN kpi_cursor FOR sql_statement USING
            p_plan_id, g_period_zero_date, -- g_plan_start_date,
            g_org_id, g_instance_id, g_item_id,
            g_project_id,g_task_id, g_category_id,
            g_category_set_id, g_category_name, g_product_family_id;
      FETCH kpi_cursor INTO l_value2;
      CLOSE kpi_cursor;

      IF l_value2 is null then
         l_value2 :=0;
      END IF;

      OPEN kpi_cursor FOR sql_statement USING
            p_plan_id, g_plan_end_date,
            g_org_id, g_instance_id, g_item_id,
            g_project_id,g_task_id, g_category_id,
            g_category_set_id, g_category_name, g_product_family_id;
      FETCH kpi_cursor INTO l_value3;
      CLOSE kpi_cursor;

      IF l_value3 is null then
         l_value3 :=0;
      END IF;

       IF (l_value2+l_value3)/2 = 0 THEN
         RETURN 999999;
       ELSE
          l_days := g_plan_end_date - g_plan_start_date +1;
          if l_days = 0 then
             l_days :=1;
          end if;
          RETURN round(l_value1/((l_value2+l_value3)/2)*
             365/l_days,6);
       END IF;
    END IF;

ELSIF i = 2 THEN

  if p_inventory_item_id is null and
     p_project_id is null and
     p_task_id is null and
     p_category_id is null and
     p_category_name is null and
     p_product_family_id is null then

    -- refer to the materialized view directly
    sql_statement := ' SELECT sum(demand_count) '||
                      ' FROM msc_demand_mv_tab mbis'||
                      ' WHERE mbis.plan_id = :1 ';
  else
    sql_statement := ' SELECT count(*) '||
                      ' FROM msc_demands_mv_v mbis'||
                      ' WHERE mbis.plan_id = :1 ';
  end if;
  sql_statement := sql_statement ||
           construct_bis_where(false,p_organization_id, p_instance_id,
                             p_inventory_item_id, p_project_id, p_task_id,
                             p_category_id, p_category_name, p_category_set_id,
                             p_product_family_id);

  OPEN kpi_cursor FOR sql_statement USING p_plan_id,
            g_org_id, g_instance_id, g_item_id,
            g_project_id,g_task_id,g_category_id,
            g_category_set_id , g_category_name, g_product_family_id;
  FETCH kpi_cursor INTO l_value2;
  CLOSE kpi_cursor;

    if l_value2 = 0 or l_value2 is null then

       return 100;
    else

       l_value1 := msc_get_bis_values.late_orders(p_plan_id,
		p_instance_id,p_organization_id,NULL,NULL,
                p_inventory_item_id, p_project_id, p_task_id,
                p_category_id,p_category_name,p_category_set_id,
                p_product_family_id);

       IF l_value1 = 0 or l_value1 is null THEN

          RETURN 100;
       ELSE

          return (l_value2-l_value1)/l_value2*100;
       END IF;

    end if;
  ELSIF i = 3 THEN
   if p_inventory_item_id is null then
    if p_organization_id is not null then
       if p_product_family_id is not null then
          OPEN MARGIN_ORG_PF_CURSOR(p_plan_id, p_organization_id,
                            p_instance_id, p_product_family_id);
          FETCH MARGIN_ORG_PF_CURSOR into l_value1, l_value2,
                                  dummy,dummy, dummy, dummy;
          CLOSE MARGIN_ORG_PF_CURSOR;
       else
          OPEN MARGIN_ORG_CURSOR(p_plan_id, p_organization_id, p_instance_id);
          FETCH MARGIN_ORG_CURSOR INTO l_value1, l_value2,
                                   dummy,dummy, dummy, dummy;
          CLOSE MARGIN_ORG_CURSOR;
       end if;
    else
       if p_product_family_id is not null then
          OPEN MARGIN_PF_CURSOR(p_plan_id, p_product_family_id);
          FETCH MARGIN_PF_CURSOR into l_value1, l_value2,
                                  dummy,dummy, dummy, dummy;
          CLOSE MARGIN_PF_CURSOR;
       else
          OPEN MARGIN_CURSOR(p_plan_id);
          FETCH MARGIN_CURSOR INTO l_value1, l_value2,
                                  dummy,dummy, dummy, dummy;
          CLOSE MARGIN_CURSOR;
       end if;
    end if;
  else  -- item_id is not null
      if p_organization_id is not null then
        OPEN INV_VAL_ORG_CURSOR(p_plan_id, p_organization_id,
                            p_instance_id, p_inventory_item_id,null,null);
        FETCH INV_VAL_ORG_CURSOR into dummy, l_value1, l_value2;
        CLOSE INV_VAL_ORG_CURSOR;
      else
        OPEN INV_VAL_CURSOR(p_plan_id,p_inventory_item_id,null,null);
        FETCH INV_VAL_CURSOR into dummy, l_value1, l_value2;
        CLOSE INV_VAL_CURSOR;
      end if;
  end if;
    IF l_value1 = 0 THEN
      RETURN 0;
    ELSE
      RETURN ((l_value1-l_value2)/l_value1)*100;
    END IF;

  ELSIF i = UTILIZATION or i = UTILIZATION2 THEN

  if p_res_instance_id  = -111 then
	    if p_sup_id is null then
	      if i = UTILIZATION then
		 sql_statement := ' SELECT avg(nvl(res.utilization,0)) ';
	      else
	 	 sql_statement := ' SELECT sum(nvl(res.UTIL_BY_WT_VOL,0)*nvl(res.batch_count,0)) /sum(nvl(res.batch_count,1))';
	      end if;
	      if p_dept_class is null and
		 p_res_group is null then
		 sql_statement := sql_statement ||
			     ' FROM msc_bis_res_summary res ' ||
			     ' WHERE res.plan_id = :1  AND nvl(res.period_type,0) = 0 ';
	      else
		 sql_statement := sql_statement ||
			     ' FROM msc_department_resources mdr, '||
			     ' msc_bis_res_summary res ' ||
			     ' WHERE res.plan_id = :1 AND nvl(res.period_type,0) = 0 ' ||
			     ' AND mdr.department_id = res.department_id ' ||
			     ' AND mdr.resource_id = res.resource_id ' ||
			     ' AND mdr.plan_id = res.plan_id ' ||
			     ' AND mdr.sr_instance_id  = res.sr_instance_id ' ||
			     ' AND mdr.organization_id = res.organization_id ';
	      end if;
	      if i = UTILIZATION2 then
		 sql_statement := sql_statement || 'AND nvl(res.UTIL_BY_WT_VOL,0) > 0 ';
	      end if;
	      sql_statement := sql_statement ||
		construct_res_where(p_organization_id, p_instance_id, p_dept_id,
				   p_res_id, p_res_group, p_dept_class);

	      OPEN kpi_cursor FOR sql_statement USING p_plan_id,
		    g_org_id, g_instance_id,
		    g_dept_id,g_res_id, g_dept_class, g_res_group ;

	      FETCH kpi_cursor INTO l_value1;
	      CLOSE kpi_cursor;

	      RETURN (l_value1*100);

	  else
	      sql_statement := ' SELECT avg(nvl(sup.utilization,0)) '||
			     ' FROM msc_bis_supplier_summary sup ' ||
			     ' WHERE sup.plan_id = :1 ';

	      sql_statement := sql_statement ||
			      construct_sup_where(p_organization_id,
						   p_instance_id,
						   p_inventory_item_id,
						   p_sup_id,
						   p_sup_site_id);
	 --  for i in 1..7 loop
	 --   dbms_output.put_line(' '|| substr(sql_statement,200*(i-1)+1,200*i));
	 --  end loop;

	      OPEN kpi_cursor FOR sql_statement USING p_plan_id,
		    -- g_org_id,
		    g_instance_id,
		    g_item_id,g_sup_id, g_sup_site_id;

	      FETCH kpi_cursor INTO l_value1;
	      CLOSE kpi_cursor;

	      RETURN (l_value1*100);
	    end if;
    elsif  p_res_instance_id  <> -111 then
	    if p_sup_id is null then
	      if i = UTILIZATION then
		 sql_statement := ' SELECT avg(nvl(res.utilization,0)) ';
	      else
	 --        sql_statement := ' SELECT avg(nvl(res.UTIL_BY_WT_VOL,0)) ';
		 sql_statement := ' SELECT sum(nvl(res.UTIL_BY_WT_VOL,0)*nvl(res.batch_count,0)) /sum(nvl(res.batch_count,1))';
	      end if;

	      if p_dept_class is null and
		 p_res_group is null then
		 sql_statement := sql_statement ||
			     ' FROM msc_bis_res_inst_summary res' ||
			     ' WHERE res.plan_id = :1  AND nvl(res.period_type,0) = 0 ';
	      else
		 sql_statement := sql_statement ||
			     ' FROM msc_dept_res_instances mdr, '||
				  ' msc_bis_res_inst_summary res ' ||
			     ' WHERE res.plan_id = :1 AND nvl(res.period_type,0) = 0 ' ||
			     ' AND mdr.department_id = res.department_id ' ||
			     ' AND mdr.resource_id = res.resource_id ' ||
			     ' AND mdr.plan_id = res.plan_id ' ||
			     ' AND mdr.sr_instance_id = res.sr_instance_id ' ||
			     ' AND nvl(mdr.serial_number , '||''''||'-111'||''''||') = nvl(res.serial_number ,'||''''||'-111'||''''||') '||
			     ' AND mdr.RES_INSTANCE_ID = res.RES_INSTANCE_ID '||
			     ' AND mdr.organization_id = res.organization_id ';
	      end if;
	      if i = UTILIZATION2 then
		 sql_statement := sql_statement || 'AND nvl(res.UTIL_BY_WT_VOL,0) > 0 ';
	      end if;
	      sql_statement := sql_statement ||
		construct_res_instance_where(p_organization_id, p_instance_id, p_dept_id,
						p_res_id, p_res_group, p_dept_class ,
						p_res_instance_id => p_res_instance_id ,
						p_res_inst_serial_number => p_res_inst_serial_number);

	      OPEN kpi_cursor FOR sql_statement USING p_plan_id,
		    g_org_id, g_instance_id,
		    g_dept_id,g_res_id, g_res_instance_id ,g_res_inst_serial_number ;

	      FETCH kpi_cursor INTO l_value1;
	      CLOSE kpi_cursor;

	      RETURN (l_value1*100);

	  else
	      sql_statement := ' SELECT avg(nvl(sup.utilization,0)) '||
			     ' FROM msc_bis_supplier_summary sup ' ||
			     ' WHERE sup.plan_id = :1 ';

	      sql_statement := sql_statement ||
			      construct_sup_where(p_organization_id,
						   p_instance_id,
						   p_inventory_item_id,
						   p_sup_id,
						   p_sup_site_id);
	 --  for i in 1..7 loop
	 --   dbms_output.put_line(' '|| substr(sql_statement,200*(i-1)+1,200*i));
	 --  end loop;

	      OPEN kpi_cursor FOR sql_statement USING p_plan_id,
		    -- g_org_id,
		    g_instance_id,
		    g_item_id,g_sup_id, g_sup_site_id;

	      FETCH kpi_cursor INTO l_value1;
	      CLOSE kpi_cursor;

	      RETURN (l_value1*100);
	    end if;
    end if;
  END IF;
END get_actuals;

-- ======================================================================
-- Function to get actual trend values for the Enterprise Plan Performance
-- Summary and Organization reports.  If organization_id is passed in as
-- NULL then results for all orgs are returned
-- ======================================================================
PROCEDURE get_trend_actuals(p_plan_id IN NUMBER,
                        p_instance_id IN NUMBER,
			p_org_id IN NUMBER,
			i IN NUMBER,
                        p_inventory_item_id IN NUMBER DEFAULT NULL,
                        p_project_id IN NUMBER DEFAULT NULL,
                        p_task_id IN NUMBER DEFAULT NULL,
                        p_dept_id IN NUMBER DEFAULT NULL,
                        p_res_id IN NUMBER DEFAULT NULL,
                        p_dept_class IN VARCHAR2 DEFAULT NULL,
                        p_res_group IN VARCHAR2 DEFAULT NULL,
                        p_category_id IN NUMBER DEFAULT NULL,
                        p_category_name IN VARCHAR2 DEFAULT NULL,
                        p_category_set_id IN NUMBER DEFAULT NULL,
                        p_product_family_id IN NUMBER DEFAULT NULL,
                        p_sup_id IN NUMBER DEFAULT NULL,
                        p_sup_site_id IN NUMBER DEFAULT NULL,
                        p_value_string OUT NOCOPY VARCHAR2 ,
			p_res_instance_id IN NUMBER DEFAULT NULL ,
			p_res_inst_serial_number IN varchar2 DEFAULT NULL   --ds enhancement
                        ) IS
  kpi_cursor KPICurTyp;

  l_value1		NUMBER := 0;
  l_value2		NUMBER := 0;
  l_value3		NUMBER := 0;
  dummy number;
  l_start_date          DATE;
  l_end_date            DATE;
  l_begin_inv_date DATE;

  l_value NUMBER;
  inv_statement varchar2(1000);

BEGIN

IF i = 1 THEN

    sql_statement := ' SELECT '||
       ' SUM(nvl(mds_cost,0)) '||
       ' FROM msc_bis_inv_detail mbis' ||
       ' WHERE mbis.plan_id = :1 '||
         ' AND mbis.detail_date between :7 AND :8 and nvl(mbis.period_type,0) = 0 ';

    sql_statement := sql_statement ||
         construct_bis_where(false,p_org_id, p_instance_id,
                             p_inventory_item_id, p_project_id, p_task_id,
                             p_category_id,p_category_name, p_category_set_id,
                             p_product_family_id);
ELSIF i =2 THEN
  sql_statement := ' SELECT count(*) ' ||
                   ' FROM msc_demands_mv_v mbis' ||
                   ' WHERE mbis.plan_id = :1 ' ||
                             ' AND mbis.using_assembly_demand_date '||
                         ' BETWEEN :7 AND :8 ';

  sql_statement := sql_statement ||
        construct_bis_where(false, p_org_id, p_instance_id,
                            p_inventory_item_id,
                            p_project_id, p_task_id,
                            p_category_id, p_category_name,p_category_set_id,
                            p_product_family_id);

ELSIF i= UTILIZATION or i = UTILIZATION2 THEN
if p_res_instance_id = -111 then
    if (p_sup_id is null ) then
      if i = UTILIZATION then
        sql_statement := ' SELECT avg(nvl(res.utilization,0)) ';
      else
        sql_statement :=  ' SELECT sum(nvl(res.UTIL_BY_WT_VOL,0)*nvl(res.batch_count,0)) /sum(nvl(res.batch_count,1))';
      end if;
      if p_dept_class is null and
         p_res_group is null then
         sql_statement := sql_statement ||
                     ' FROM msc_bis_res_summary res ' ||
                     ' WHERE res.plan_id = :1  AND nvl(res.period_type,0) = 0 '||
                     ' AND res.resource_date '||
                     ' between :8 and :9 ';
      else
         sql_statement := sql_statement ||
                     ' FROM msc_department_resources mdr, '||
                          ' msc_bis_res_summary res ' ||
                     ' WHERE res.plan_id = :1  AND nvl(res.period_type,0) = 0 ' ||
                     ' AND res.resource_date '||
                     ' between :8 and :9 ' ||
                     ' AND mdr.department_id = res.department_id ' ||
                     ' AND mdr.resource_id = res.resource_id ' ||
                     ' AND mdr.plan_id = res.plan_id ' ||
                     ' AND mdr.sr_instance_id = res.sr_instance_id ' ||
                     ' AND mdr.organization_id = res.organization_id ';
      end if;
      if i = UTILIZATION2 then
         sql_statement := sql_statement || 'AND nvl(res.UTIL_BY_WT_VOL,0) > 0 ';
      end if;
      sql_statement := sql_statement ||
       construct_res_where(p_org_id, p_instance_id, p_dept_id,
                           p_res_id, p_res_group, p_dept_class);

    else
    sql_statement := ' SELECT avg(nvl(sup.utilization,0)) '||
                     ' FROM msc_bis_supplier_summary sup ' ||
                     ' WHERE sup.plan_id = :1 ' ||
                     ' AND sup.detail_date ' ||
                     ' between :8 and :9 ' ;

   -- dbms_output.put_line(substr(sql_statement,1,200));
   -- dbms_output.put_line(substr(sql_statement,201,400));
    sql_statement := sql_statement ||
                      construct_sup_where(p_org_id,
                                           p_instance_id,
                                           p_inventory_item_id,
                                           p_sup_id,
                                           p_sup_site_id);
    end if;
elsif p_res_instance_id <> -111 then
    if (p_sup_id is null ) then
      if i = UTILIZATION then
        sql_statement := ' SELECT avg(nvl(res.utilization,0)) ';
      else
        sql_statement :=  ' SELECT sum(nvl(res.UTIL_BY_WT_VOL,0)*nvl(res.batch_count,0)) /sum(nvl(res.batch_count,1))';
      end if;
      if p_dept_class is null and
         p_res_group is null then
         sql_statement := sql_statement ||
                     ' FROM msc_bis_res_inst_summary res ' ||
                     ' WHERE res.plan_id = :1  AND nvl(res.period_type,0) = 0 '||
                     ' AND res.resource_inst_date '||
                     ' between :8 and :9 ';
      else
         sql_statement := sql_statement ||
                     ' msc_dept_res_instances mdr, '||
		     ' msc_bis_res_inst_summary res ' ||
                     ' WHERE res.plan_id = :1  AND nvl(res.period_type,0) = 0 ' ||
                     ' AND res.resource_inst_date '||
                     ' between :8 and :9 ' ||
                     ' AND mdr.department_id = res.department_id ' ||
                     ' AND mdr.resource_id = res.resource_id ' ||
                     ' AND mdr.plan_id = res.plan_id ' ||
                     ' AND mdr.sr_instance_id = res.sr_instance_id ' ||
		     ' AND nvl(mdr.serial_number , '||''''||'-111'||''''||') = nvl(res.serial_number ,'||''''||'-111'||''''||') '||
		     ' AND mdr.RES_INSTANCE_ID = res.RES_INSTANCE_ID ' ||
                     ' AND mdr.organization_id = res.organization_id ';
      end if;

      if i = UTILIZATION2 then
         sql_statement := sql_statement || 'AND nvl(res.UTIL_BY_WT_VOL,0) > 0 ';
      end if;
      sql_statement := sql_statement ||
      		construct_res_instance_where(p_org_id, p_instance_id, p_dept_id,
				   p_res_id, p_res_group, p_dept_class
				   ,p_res_instance_id => p_res_instance_id ,
				   p_res_inst_serial_number => p_res_inst_serial_number);

    else
    sql_statement := ' SELECT avg(nvl(sup.utilization,0)) '||
                     ' FROM msc_bis_supplier_summary sup ' ||
                     ' WHERE sup.plan_id = :1 ' ||
                     ' AND sup.detail_date ' ||
                     ' between :8 and :9 ' ;

   -- dbms_output.put_line(substr(sql_statement,1,200));
   -- dbms_output.put_line(substr(sql_statement,201,400));
    sql_statement := sql_statement ||
                      construct_sup_where(p_org_id,
                                           p_instance_id,
                                           p_inventory_item_id,
                                           p_sup_id,
                                           p_sup_site_id);

    end if;
end if;
END IF;

For j in 1..g_period_name.LAST LOOP
--dbms_output.put_line('in for loop');

  l_start_date := g_period_name(j).start_date;
  l_end_date   := g_period_name(j).end_date;
 --dbms_output.put_line(to_char(l_start_date));
 --dbms_output.put_line(to_char(l_end_date));
  IF i =1 THEN

  OPEN kpi_cursor FOR sql_statement USING
            p_plan_id, l_start_date, l_end_date,
            g_org_id, g_instance_id, g_item_id,
            g_project_id,g_task_id, g_category_id,
            g_category_set_id,g_category_name, g_product_family_id;

  FETCH kpi_cursor INTO l_value1;
  CLOSE kpi_cursor;

    IF l_value1 = 0 OR l_value1 is null THEN
      l_value := 0;

    ELSE


    inv_statement := ' SELECT '||
       ' SUM(nvl(mbis.inventory_cost,0)) '||
       ' FROM msc_bis_inv_detail mbis' ||
       ' WHERE mbis.plan_id = :1 '||
         ' AND mbis.detail_date =:7 and nvl(mbis.period_type,0) = 0 ';

    inv_statement := inv_statement ||
         construct_bis_where(false,p_org_id, p_instance_id,
                             p_inventory_item_id, p_project_id, p_task_id,
                             p_category_id, p_category_name,p_category_set_id,
                             p_product_family_id);
    if j=1 THEN
      l_begin_inv_date := g_period_zero_date;
    else
      l_begin_inv_date :=g_period_name(j-1).start_date;
    end if;

    OPEN kpi_cursor FOR inv_statement USING
            p_plan_id, l_begin_inv_date,
            g_org_id, g_instance_id, g_item_id,
            g_project_id,g_task_id,g_category_id,
            g_category_set_id, g_category_name,g_product_family_id;

    FETCH kpi_cursor INTO l_value2;
    CLOSE kpi_cursor;

    IF l_value2 is null THEN
       l_value2 :=0;
    END IF;

    OPEN kpi_cursor FOR inv_statement USING
            p_plan_id, l_start_date,
            g_org_id, g_instance_id, g_item_id,
            g_project_id,g_task_id,g_category_id,
            g_category_set_id, g_category_name, g_product_family_id;

    FETCH kpi_cursor INTO l_value3;
    CLOSE kpi_cursor;

    IF l_value3 is null THEN
       l_value3 :=0;
    END IF;

      IF ((l_value2+l_value3)/2) = 0 THEN
        l_value := 999999;
      ELSE
        l_value :=
        round(l_value1/((l_value2+l_value3)/2)
	*365/(l_end_date -l_start_date +1),6);
      END IF;
    END IF;


  ELSIF i = 2 THEN

    OPEN kpi_cursor FOR sql_statement USING p_plan_id,
            l_start_date, l_end_date,
            g_org_id, g_instance_id, g_item_id,
            g_project_id,g_task_id,g_category_id,
            g_category_set_id, g_category_name, g_product_family_id;

    FETCH kpi_cursor INTO l_value2;
    CLOSE kpi_cursor;

    if l_value2 = 0 or l_value2 is null then
       l_value :=100;

    else
      l_value1 :=msc_get_bis_values.late_orders(
                p_plan_id,p_instance_id,p_org_id,
		l_start_date,l_end_date,
                p_inventory_item_id, p_project_id, p_task_id,
                p_category_id,p_category_name,
                p_category_set_id,p_product_family_id);

       IF l_value1 = 0 THEN
         l_value := 100;
       ELSE
         l_value :=((l_value2-l_value1)/l_value2 * 100);
       END IF;
    end if;

ELSIF i = 3  THEN
if p_inventory_item_id is null then
if p_org_id is not null then
  if p_product_family_id is not null then
  OPEN MARGIN_ORG_PF_DATE_CURSOR(p_plan_id, p_org_id,
                            p_instance_id, p_product_family_id,
                            l_start_date, l_end_date);
  FETCH MARGIN_ORG_PF_DATE_CURSOR into l_value1, l_value2,
                                     dummy,dummy, dummy, dummy;
  CLOSE MARGIN_ORG_PF_DATE_CURSOR;
  else
    OPEN MARGIN_ORG_DATE_CURSOR(p_plan_id,p_org_id, p_instance_id,
                                l_start_date, l_end_date);
    FETCH MARGIN_ORG_DATE_CURSOR INTO l_value1, l_value2,
                                     dummy,dummy, dummy, dummy;
    CLOSE MARGIN_ORG_DATE_CURSOR;
  end if;
else
  if p_product_family_id is not null then
  OPEN MARGIN_PF_DATE_CURSOR(p_plan_id, p_product_family_id,
                             l_start_date, l_end_date);
  FETCH MARGIN_PF_DATE_CURSOR into l_value1, l_value2,
                                  dummy,dummy, dummy, dummy;
  CLOSE MARGIN_PF_DATE_CURSOR;
  else
    OPEN MARGIN_DATE_CURSOR(p_plan_id,l_start_date, l_end_date);
    FETCH MARGIN_DATE_CURSOR INTO l_value1, l_value2,
                                  dummy,dummy, dummy, dummy;
    CLOSE MARGIN_DATE_CURSOR;
  end if;
end if;
else -- item is not null
      if p_org_id is not null then
        OPEN INV_VAL_ORG_CURSOR(p_plan_id, p_org_id,
                            p_instance_id, p_inventory_item_id,
                            l_start_date, l_end_date);
        FETCH INV_VAL_ORG_CURSOR into dummy, l_value1, l_value2;
        CLOSE INV_VAL_ORG_CURSOR;
      else
        OPEN INV_VAL_CURSOR(p_plan_id,p_inventory_item_id,
                            l_start_date, l_end_date);
        FETCH INV_VAL_CURSOR into dummy, l_value1, l_value2;
        CLOSE INV_VAL_CURSOR;
      end if;
end if;
    l_value1 := nvl(l_value1,0);
    l_value2 := nvl(l_value2,0);
    IF l_value1 = 0 THEN
      l_value := 0;
    ELSE
      l_value := ((l_value1-l_value2)/l_value1)*100;
    END IF;

ELSIF i = 4 or i = 9 THEN

    if (p_sup_id is null) then
       OPEN kpi_cursor FOR sql_statement USING p_plan_id,
            l_start_date, l_end_date,g_org_id, g_instance_id,
            -- g_dept_id,g_res_id,  g_res_instance_id , g_res_inst_serial_number ;
            -- updated for bug  6046690
               g_dept_id,g_res_id,  g_dept_class , g_res_group ;
    else
      --dbms_output.put_line(g_item_id|| ' ' ||g_sup_id || ' ' ||g_sup_site_id);
      OPEN kpi_cursor FOR sql_statement USING p_plan_id,
            l_start_date, l_end_date, --g_org_id,
            g_instance_id,
            g_item_id,g_sup_id, g_sup_site_id;
      --dbms_output.put_line('after open');
    end if;

    FETCH kpi_cursor INTO l_value1;
    CLOSE kpi_cursor;

    IF l_value1 is null THEN
       l_value1 :=0;
    END IF;

    l_value := l_value1 * 100;

  END IF;

  l_value :=round(l_value,6);
  p_value_string := p_value_string ||g_param ||
                      fnd_number.number_to_canonical(l_value);

END LOOP;
--exception
 --when others then
  --dbms_output.put_line(sqlerrm);


END get_trend_actuals;

FUNCTION get_targets(p_chart_type IN NUMBER, p_instance_id IN NUMBER,
	p_org_id IN NUMBER,
        p_time_level varchar2 DEFAULT NULL) RETURN NUMBER IS

  l_target 	NUMBER;
  v_measure     varchar2(10);
  v_target_level varchar2(10);

  CURSOR C1 IS
  SELECT t.target
  FROM  msc_bis_targets t,
	msc_bis_target_levels tl,
        msc_bis_performance_measures m,
        msc_bis_business_plans mbp
  WHERE t.target_level_id = tl.target_level_id
    and t.sr_instance_id = p_instance_id
    and tl.sr_instance_id = p_instance_id
    and m.sr_instance_id = p_instance_id
    and mbp.sr_instance_id = p_instance_id
    AND m.measure_id = tl.measure_id
    AND m.measure_short_name = v_measure
    and mbp.short_name = 'STANDARD'
    AND t.business_plan_id = mbp.business_plan_id
    and tl.target_level_short_name = v_target_level
    AND t.org_level_value_id = decode(t.org_level_value_id,-1,-1,p_org_id)
    AND t.time_level_value_id = nvl(p_time_level, t.time_level_value_id);

BEGIN

  IF p_chart_type = INVENTORY_TURNS then
     v_measure := 'MRPEPPIT';
     IF p_org_id is null THEN
       v_target_level := 'MRPITALL';
     ELSE
       v_target_level := 'MRPITORG';
     END IF;
  ELSIF p_chart_type = ONTIME_DELIVERY then
     v_measure := 'MRPEPPOT';
     IF p_org_id is null THEN
       v_target_level := 'MRPOTALL';
     ELSE
       v_target_level := 'MRPOTORG';
     END IF;
  ELSIF p_chart_type = MARGIN_PERCENT then
     v_measure := 'MRPEPPGM';
     IF p_org_id is null THEN
       v_target_level := 'MRPGMALL';
     ELSE
       v_target_level := 'MRPGMORG';
     END IF;
  ELSIF p_chart_type = UTILIZATION or p_chart_type = UTILIZATION2 then
     v_measure := 'MRPEPPPU';
     IF p_org_id is null THEN
       v_target_level := 'MRPPUALL';
     ELSE
       v_target_level := 'MRPPUORG';
     END IF;
  END IF;

  OPEN C1;
  FETCH C1 INTO l_target;
  CLOSE C1;

  RETURN l_target;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    return 0;

END get_targets;

FUNCTION get_targets_trend(p_chart_type IN NUMBER, p_instance_id IN NUMBER,
	p_org_id IN NUMBER) RETURN VARCHAR2 IS

  l_target 	NUMBER;
  v_time_level  varchar2(30);
  l_target_list varchar2(500);

BEGIN

  FOR j in 1 .. g_period_name.LAST LOOP
     v_time_level := 'Accounting+'||g_period_name(j).period_name;
     l_target :=
           get_targets(p_chart_type, p_instance_id,p_org_id,v_time_level);

     l_target_list := l_target_list ||g_param||
                            fnd_number.number_to_canonical(nvl(l_target,0));
  END LOOP;

  return l_target_list;
EXCEPTION

  WHEN NO_DATA_FOUND THEN

    return 0;

END get_targets_trend;


FUNCTION construct_res_where(p_organization_id number,
                             p_instance_id number,
                             p_dept_id number,
                             p_res_id number,
                             p_res_group varchar2,
                             p_dept_class varchar2,
                             p_start_date date default null,
                             p_end_date date default null) RETURN varchar2 IS
  where_stat varchar2(1000);

BEGIN
  if p_organization_id is not null then
     where_stat :=
          ' AND res.organization_id = :2 ' ||
          ' AND res.sr_instance_id = :3 ';
     g_org_id := p_organization_id;
     g_instance_id := p_instance_id;
  else
     where_stat := where_stat ||
          ' AND :2 = :3 ';
        g_org_id := -1;
        g_instance_id := -1;
  end if;

  if p_dept_id is not null then
     where_stat := where_stat ||
          ' AND res.department_id = :4 ';
     g_dept_id := p_dept_id;
  else
     where_stat := where_stat ||
          ' AND :4 = -1 ';
        g_dept_id := -1;
  end if;

  if p_res_id is not null then
     where_stat := where_stat ||
          ' AND res.resource_id = :5 ';
     g_res_id := p_res_id;
  else
     where_stat := where_stat ||
          ' AND :5 = -1 ';
        g_res_id := -1;
  end if;

  if p_dept_class = '@@@' then
        where_stat := where_stat ||
          ' AND mdr.department_class is null '||
          ' AND res.resource_id <> -1' ||
          ' AND :a = ''-1'' ';
        g_dept_class := '-1';

  elsif p_dept_class is not null then
     where_stat := where_stat ||
          ' AND mdr.department_class = :a ';
     g_dept_class := p_dept_class;
  else

     where_stat := where_stat ||
          ' AND :a = ''-1'' ';
        g_dept_class := '-1';
  end if;

  if p_res_group = '@@@' then
     where_stat := where_stat ||
          ' AND mdr.resource_group_name is null '||
          ' AND res.resource_id <> -1 ' ||
          ' AND :b = ''-1'' ';
        g_res_group := '-1';
  elsif p_res_group is not null then
     where_stat := where_stat ||
          ' AND mdr.resource_group_name = :b ';
     g_res_group := p_res_group;
  else
     where_stat := where_stat ||
          ' AND :b = ''-1'' ';
        g_res_group := '-1';
  end if;
  return where_stat;

END;

/*satyagi ds enhancement :--------------------------------------------------------------------------------*/

FUNCTION construct_res_instance_where(p_organization_id number,
					     p_instance_id number,
					     p_dept_id number,
					     p_res_id number,
					     p_res_group varchar2 ,
					     p_dept_class varchar2 ,
					     p_start_date date default null,
					     p_end_date date default null ,
					     p_res_instance_id number ,
					     p_res_inst_serial_number varchar2) RETURN varchar2 IS
where_stat varchar2(1000);
BEGIN
  if p_organization_id is not null then
     where_stat :=
          ' AND res.organization_id = :2 ' ||
          ' AND res.sr_instance_id = :3 ';
     g_org_id := p_organization_id;
     g_instance_id := p_instance_id;
  else
     where_stat := where_stat ||
          ' AND :2 = :3 ';
        g_org_id := -1;
        g_instance_id := -1;
  end if;

  if p_dept_id is not null then
     where_stat := where_stat ||
          ' AND res.department_id = :4 ';
     g_dept_id := p_dept_id;
  else
     where_stat := where_stat ||
          ' AND :4 = -1 ';
        g_dept_id := -1;
  end if;

  if p_res_id is not null then
     where_stat := where_stat ||
          ' AND res.resource_id = :5 ';
     g_res_id := p_res_id;
  else
     where_stat := where_stat ||
          ' AND :5 = -1 ';
        g_res_id := -1;
  end if;

 if p_res_instance_id is not null then
     where_stat := where_stat ||
          ' AND res.res_instance_id = :8 ';
     g_res_instance_id := p_res_instance_id;
 else
     where_stat := where_stat ||
          ' AND :8 = -1 ';
        g_res_instance_id := -1;
 end if;

if p_res_inst_serial_number = '-111' then
     where_stat := where_stat ||
          ' AND nvl(res.serial_number ,'||''''||'-111'||''''||')'||'  = :9 ';
     g_res_inst_serial_number := p_res_inst_serial_number ;
 else
     where_stat := where_stat ||
          ' AND res.serial_number = :9 ';
     g_res_inst_serial_number := p_res_inst_serial_number ;
 end if;

  return where_stat;

END;

/*--------------------------------------------------------------------------------satyagi ds enhancement :*/

FUNCTION construct_bis_where(p_date boolean,
                             p_organization_id number,
                             p_instance_id number,
                             p_inventory_item_id number,
                             p_project_id number,
                             p_task_id number,
                             p_category_id number,
                             p_category_name varchar2,
                             p_category_set_id number,
                             p_product_family_id number,
                             p_start_date date default null,
                             p_end_date date default null)
RETURN varchar2 IS
  where_stat varchar2(2000);

BEGIN
  if p_organization_id is not null then
     where_stat :=
          ' AND mbis.organization_id = :2 ' ||
          ' AND mbis.sr_instance_id = :3 ';
     g_org_id := p_organization_id;
     g_instance_id := p_instance_id;
  else
     where_stat := where_stat ||
          ' AND :2 = :3 ';
        g_org_id := -1;
        g_instance_id := -1;
  end if;

  if p_inventory_item_id is not null then
     where_stat := where_stat ||
          ' AND mbis.inventory_item_id = :4 ';
     g_item_id := p_inventory_item_id;
  else
     where_stat := where_stat ||
          ' AND :4=-1 ';
     g_item_id :=-1;
  end if;

  if p_project_id is not null then
    if p_date then -- from late_orders
       if p_task_id is null then
          where_stat := where_stat ||
          ' AND exists (select 1 '||
          ' from msc_demands md '||
          ' where md.plan_id = mbis.plan_id '||
            ' and md.demand_id = mbis.number1 '||
            ' and md.project_id = :5)';
       end if;
    else
       where_stat := where_stat ||
          ' AND mbis.project_id = :5';
    end if;
    g_project_id := p_project_id;
  else
     where_stat := where_stat ||
          ' AND :5=-1 ';
     g_project_id :=-1;
  end if;

  if p_task_id is not null then
    if p_date then -- from late_orders
       where_stat := where_stat ||
          ' AND exists (select 1 '||
          ' from msc_demands md '||
          ' where md.plan_id = mbis.plan_id '||
            ' and md.demand_id = mbis.number1 '||
            ' and md.project_id = :5 '||
            ' and md.task_id = :6)';
    else
       where_stat := where_stat ||
          ' AND mbis.task_id = :6';
    end if;
    g_task_id := p_task_id;
  else
     where_stat := where_stat ||
          ' AND :6=-1 ';
     g_task_id :=-1;
  end if;

  if p_category_name is not null then
     if subStr(p_category_name,1,3) = '-1:' then
           -- come from msc_bis_inv_cat_mv_tab
       where_stat := where_stat ||
              ' and -1 = :9 '||
              ' and mbis.category_set_id = :10 ' ||
              ' and mbis.category_name = :11 ';
       g_category_id := -1;
       g_category_name := subStr(p_category_name,4);
     else
       where_stat := where_stat ||
          ' AND EXISTS '||
          ' (select 1 '||
            ' from msc_item_categories mit ' ||
            ' where mit.organization_id = mbis.organization_id '||
              ' and mit.sr_instance_id = mbis.sr_instance_id '||
              ' and mit.inventory_item_id = mbis.inventory_item_id '||
              ' and -1 = :9 '||
              ' and mit.category_set_id = :10 '||
              ' and mit.category_name = :11 )';
       g_category_id := -1;
       g_category_name := p_category_name;
     end if;
     g_category_set_id := p_category_set_id;

  elsif p_category_id is not null then
     if p_category_id < 0 then -- come from msc_bis_inv_cat_mv_tab
       where_stat := where_stat ||
              ' and mbis.sr_category_id = :9 '||
              ' and mbis.category_set_id = :10 '||
              ' and ''-1'' = :11 ';
       g_category_id := p_category_id*-1;
       g_category_name := '-1';
     else
       where_stat := where_stat ||
          ' AND EXISTS '||
          ' (select 1 '||
            ' from msc_item_categories mit ' ||
            ' where mit.organization_id = mbis.organization_id '||
              ' and mit.sr_instance_id = mbis.sr_instance_id '||
              ' and mit.inventory_item_id = mbis.inventory_item_id '||
              ' and mit.sr_category_id = :9 '||
              ' and mit.category_set_id = :10 ' ||
              ' and ''-1'' = :11 )';
       g_category_id := p_category_id;
       g_category_name := '-1';
     end if;
     g_category_set_id := p_category_set_id;
  else
     where_stat := where_stat ||
          ' AND :9=:10 '||
          ' and ''-1'' = :11 ';
     g_category_id :=-1;
     g_category_set_id :=-1;
     g_category_name := '-1';
  end if;

  if p_product_family_id is not null then
     where_stat := where_stat ||
          ' AND EXISTS '||
          ' (select 1 '||
            ' from msc_bom_components mbc ' ||
            ' where mbc.organization_id = mbis.organization_id '||
              ' and mbc.sr_instance_id = mbis.sr_instance_id '||
              ' and mbc.plan_id = mbis.plan_id ' ||
              ' and mbc.inventory_item_id = mbis.inventory_item_id '||
              ' and mbc.using_assembly_id = :11 )';
     g_product_family_id := p_product_family_id;
  else
     where_stat := where_stat ||
          ' AND :11=-1 ';
     g_product_family_id :=-1;
  end if;

if p_date then
  if p_start_date is not null then
     where_stat := where_stat ||
          ' AND exists '||
          ' (select 1 '||
           ' from msc_demands md '||
           ' where md.plan_id = mbis.plan_id '||
              ' and md.demand_id = mbis.number1 '||
              ' and trunc(nvl(md.assembly_demand_comp_date,md.using_assembly_demand_date)) between :7 and :8)';
     g_start_date := trunc(p_start_date);
     g_end_date := trunc(p_end_date);
  else
     where_stat := where_stat ||
          ' AND :7=:8 ';
     g_start_date := sysdate;
     g_end_date := sysdate;
  end if;
end if;


  return where_stat;
END;

FUNCTION get_service_level(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER,
                     p_start_date date default null,
                     p_end_date date default null,
		     p_use_old_demand_qty number default null) RETURN NUMBER IS
  the_cursor KPICurTyp;
  sql_stat varchar2(3000);
  where_stat varchar2(2000);
  v_org_id number;
  v_instance_id number;
  v_item_id number;
  v_start date;
  v_end date;
  v_qty number;
  v_qty2 number;
  v_service number;
  v_constraint number;
  v_plan_type number;

  l_category_set_id number;
  l_category_set_str varchar2(100);

  v_run_qty number;
  v_run_qty2 number;
  from_plan_node boolean := false;

BEGIN
   if ( p_instance_id is null and p_organization_id is null and p_item_id is null) then
     from_plan_node := true;
   end if;

   l_category_set_id := MSC_ANALYSIS_PKG.get_cat_set_id(p_plan_id);
   if (l_category_set_id is null) then
     l_category_set_str := '';
   else
     l_category_set_str := ' AND mic.category_set_id = '||l_category_set_id;
   end if;


    select nvl(DAILY_RESOURCE_CONSTRAINTS,0)+
           nvl(WEEKLY_RESOURCE_CONSTRAINTS,0)+
           nvl(PERIOD_RESOURCE_CONSTRAINTS,0),
           plan_type
     into v_constraint, v_plan_type
      from msc_plans
     where plan_id = p_plan_id;

  if v_plan_type <>4 and v_constraint = 0 then
 -- unconstrained plan is always 100%
     return 100;
  end if;

  where_stat := 'WHERE md.plan_id = :1 ' ||
                ' AND md.sr_instance_id = mic.sr_instance_id  '||
                ' AND md.organization_id = mic.organization_id '||
                ' AND md.inventory_item_id = mic.inventory_item_id '||
                l_category_set_str||
                ' AND md.origination_type in (6,7,8,9,11,15,22,29,30) ';
  if p_instance_id is not null or from_plan_node then
     where_stat := where_stat ||
              ' AND md.organization_id = :2 '||
              ' AND md.sr_instance_id = :3 ';
     v_org_id := p_organization_id;
     v_instance_id := p_instance_id;
  else
     where_stat := where_stat ||
              ' AND :2 = :3 ';
     v_org_id := -1;
     v_instance_id := -1;
  end if;

  if p_item_id is not null then
     where_stat := where_stat ||
              ' AND md.inventory_item_id = :4 ';
     v_item_id := p_item_id;
  else
     where_stat := where_stat ||
              ' AND -1 = :4 ';
     v_item_id := -1;
  end if;

  if p_start_date is not null then
         where_stat := where_stat ||
                 ' AND trunc(md.USING_ASSEMBLY_DEMAND_DATE) BETWEEN :5 AND :6 ';
         v_start := trunc(p_start_date);
         v_end := trunc(p_end_date);
   else
         where_stat := where_stat ||
                 ' AND :5 = :6 ';
         v_start := sysdate;
         v_end := sysdate;
   end if;

   --if (p_use_old_demand_qty is null) then
   if v_plan_type <> 4 then
   sql_stat := 'SELECT sum(nvl(md.quantity_by_due_date,0)*nvl(md.probability,1)), '||
                     ' sum(md.USING_REQUIREMENT_QUANTITY*nvl(md.probability,1)) ' ||
                   ' FROM msc_demands md, ' ||
                   ' msc_item_categories mic ' ||
                   where_stat;
   --elsif (p_use_old_demand_qty = -1) then
   elsif v_plan_type = 4 then
   sql_stat := 'SELECT sum(nvl(md.old_demand_quantity,0)*nvl(md.probability,1)), '||
                     ' sum(md.USING_REQUIREMENT_QUANTITY*nvl(md.probability,1)) ' ||
                   ' FROM msc_demands md, ' ||
                   ' msc_item_categories mic ' ||
                   where_stat;
   end if;

  if ( not(from_plan_node) ) then
   OPEN the_cursor FOR sql_stat USING p_plan_id,v_org_id,
                                     v_instance_id, v_item_id,
                                     v_start, v_end;
   FETCH the_cursor INTO v_qty, v_qty2;
   CLOSE the_cursor;
  else
     v_qty := 0;
     v_qty2 := 0;

     open c_plan_orgs(p_plan_id);
     loop
       fetch c_plan_orgs into v_instance_id, v_org_id;
       exit when c_plan_orgs%notfound;

       OPEN the_cursor FOR sql_stat USING p_plan_id,v_org_id,
         v_instance_id, v_item_id, v_start, v_end;
       FETCH the_cursor INTO v_run_qty, v_run_qty2;
       CLOSE the_cursor;

       v_qty := v_qty + nvl(v_run_qty,0);
       v_qty2 := v_qty2 + nvl(v_run_qty2,0);
     end loop;
     close c_plan_orgs;
  end if;

   if nvl(v_qty2,0) =0 then -- there is no demand, will show 100%
        v_service := 100;
   elsif nvl(v_qty,0)=0 then
         v_service := 0;
   else
         v_service := round(v_qty/v_qty2*100,6);
   end if;

  return v_service;

END get_service_level;

FUNCTION get_tp_cost(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER,
                     p_start_date date default null,
                     p_end_date date default null,
                     p_planner_code varchar2 default null) RETURN NUMBER IS
  the_cursor KPICurTyp;
  sql_stat varchar2(5000);
  where_stat varchar2(3000);
  v_org_id number;
  v_instance_id number;
  v_item_id number;
  v_start date;
  v_end date;
  v_cost number;
  v_planner_code varchar2(50);

  l_category_set_id number;
  l_category_set_str varchar2(100);

  v_run_qty number;
  from_plan_node boolean := false;

BEGIN
   if ( p_instance_id is null and p_organization_id is null and p_item_id is null) then
     from_plan_node := true;
   end if;

   l_category_set_id := MSC_ANALYSIS_PKG.get_cat_set_id(p_plan_id);
   if (l_category_set_id is null) then
     l_category_set_str := '';
   else
     l_category_set_str := ' AND mic.category_set_id = '||l_category_set_id;
   end if;

  where_stat := ' WHERE ms.plan_id = :1 ' ||
                ' AND ms.sr_instance_id = mic.sr_instance_id  '||
                ' AND ms.organization_id = mic.organization_id '||
                ' AND ms.inventory_item_id = mic.inventory_item_id '||
                l_category_set_str||
                ' and ms.organization_id != ms.source_organization_id '||
		' and ms.order_type in (5,11) '||
		' and ms.plan_id = msi.plan_id '||
		' and ms.organization_id = msi.organization_id '||
		' and ms.sr_instance_id = msi.sr_instance_id '||
		' and ms.inventory_item_id = msi.inventory_item_id '||
		' and ms.plan_id = mism.plan_id '||
		' and ms.organization_id = mism.to_organization_id '||
		' and ms.sr_instance_id = mism.sr_instance_id '||
		' and ms.source_organization_id = mism.from_organization_id '||
		' and ms.source_sr_instance_id = mism.sr_instance_id2'||
		' and ms.ship_method = mism.ship_method ';
  if p_instance_id is not null or from_plan_node then
     where_stat := where_stat ||
              ' AND ms.organization_id = :2 '||
              ' AND ms.sr_instance_id = :3 ';
     v_org_id := p_organization_id;
     v_instance_id := p_instance_id;
  else
     where_stat := where_stat ||' AND :2 = :3 ';
     v_org_id := -1;
     v_instance_id := -1;
  end if;

  if p_item_id is not null then
     where_stat := where_stat ||
              ' AND ms.inventory_item_id = :4 ';
     v_item_id := p_item_id;
  else
     where_stat := where_stat ||' AND -1 = :4 ';
     v_item_id := -1;
  end if;



  if p_start_date is not null then
         where_stat := where_stat ||
                 ' AND trunc(ms.new_dock_date) BETWEEN :5 AND :6 ';
         v_start := trunc(p_start_date);
         v_end := trunc(p_end_date);
   else
         where_stat := where_stat ||
                 ' AND :5 = :6 ';
         v_start := sysdate;
         v_end := sysdate;
   end if;

  if p_planner_code is not null then
     where_stat := where_stat ||
              ' AND msi.planner_code = :7 ';
     v_planner_code := p_planner_code;
  else
     where_stat := where_stat ||' AND ''-1'' = :4 ';
     v_planner_code := '''-1''';
  end if;

   sql_stat := 	' select round(sum(nvl(((ms.new_order_quantity * '||
		' msi.unit_weight) '||
		' * mism.cost_per_weight_unit),0)),6) '||
		' from msc_supplies ms,  '||
		' msc_system_items msi,  '||
		' msc_item_categories mic,  '||
		' msc_interorg_ship_methods mism '|| where_stat;
  if ( not(from_plan_node) ) then
   OPEN the_cursor FOR sql_stat USING p_plan_id,v_org_id,
                                     v_instance_id, v_item_id,
                                     v_start, v_end, p_planner_code;
   FETCH the_cursor INTO v_cost;
   CLOSE the_cursor;
  else
     v_cost := 0;
     open c_plan_orgs(p_plan_id);
     loop
       fetch c_plan_orgs into v_instance_id, v_org_id;
       exit when c_plan_orgs%notfound;

       OPEN the_cursor FOR sql_stat USING p_plan_id,v_org_id,
         v_instance_id, v_item_id, v_start, v_end, p_planner_code;
       FETCH the_cursor INTO v_run_qty;
       CLOSE the_cursor;

       v_cost := v_cost + nvl(v_run_qty,0);
     end loop;
     close c_plan_orgs;
  end if;


  return v_cost;

END get_tp_cost;

FUNCTION get_target_service_level(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER,
                     p_start_date date default null,
                     p_end_date date default null) RETURN NUMBER IS
  the_cursor KPICurTyp;
  sql_stat varchar2(3000);
  where_stat varchar2(2000);
  v_org_id number;
  v_instance_id number;
  v_item_id number;
  v_start date;
  v_end date;
  v_qty number;
  v_count number;

  l_category_set_id number;
  l_category_set_str varchar2(100);

  v_run_qty number;
  v_dmd_count number := 0;
  from_plan_node boolean := false;
BEGIN

   if ( p_instance_id is null and p_organization_id is null and p_item_id is null) then
     from_plan_node := true;
   end if;

   l_category_set_id := MSC_ANALYSIS_PKG.get_cat_set_id(p_plan_id);
   if (l_category_set_id is null) then
     l_category_set_str := '';
   else
     l_category_set_str := ' AND mic.category_set_id = '||l_category_set_id;
   end if;


  where_stat := 'WHERE md.plan_id = :1 ' ||
                ' AND md.sr_instance_id = mic.sr_instance_id  '||
                ' AND md.organization_id = mic.organization_id '||
                ' AND md.inventory_item_id = mic.inventory_item_id '||
                l_category_set_str||
                ' AND md.origination_type in (6,7,8,9,11,15,22,29,30) ';
  if p_instance_id is not null or from_plan_node then
     where_stat := where_stat ||
              ' AND md.organization_id = :2 '||
              ' AND md.sr_instance_id = :3 ';
     v_org_id := p_organization_id;
     v_instance_id := p_instance_id;
  else
     where_stat := where_stat ||
              ' AND :2 = :3 ';
     v_org_id := -1;
     v_instance_id := -1;
  end if;

  if p_item_id is not null then
     where_stat := where_stat ||
              ' AND md.inventory_item_id = :4 ';
     v_item_id := p_item_id;
  else
     where_stat := where_stat ||
              ' AND -1 = :4 ';
     v_item_id := -1;
  end if;

  if p_start_date is not null then
         where_stat := where_stat ||
                 ' AND trunc(md.USING_ASSEMBLY_DEMAND_DATE) BETWEEN :5 AND :6 ';
         v_start := trunc(p_start_date);
         v_end := trunc(p_end_date);
   else
         where_stat := where_stat ||
                 ' AND :5 = :6 ';
         v_start := sysdate;
         v_end := sysdate;
   end if;

   sql_stat := 'SELECT avg(md.service_level), count(*) '||
                   ' FROM msc_demands md, ' ||
                   ' msc_item_categories mic ' ||
                   where_stat;
  if ( not(from_plan_node) ) then
   OPEN the_cursor FOR sql_stat USING p_plan_id,v_org_id,
                                     v_instance_id, v_item_id,
                                     v_start, v_end;
   FETCH the_cursor INTO v_qty, v_count;
   CLOSE the_cursor;
  else
     v_qty := 0;
     open c_plan_orgs(p_plan_id);
     loop
       fetch c_plan_orgs into v_instance_id, v_org_id;
       exit when c_plan_orgs%notfound;
       OPEN the_cursor FOR sql_stat USING p_plan_id,v_org_id,
         v_instance_id, v_item_id, v_start, v_end;
       FETCH the_cursor INTO v_run_qty, v_count;
       CLOSE the_cursor;
       v_qty := v_qty + (nvl(v_run_qty, 0) * nvl(v_count,0));
       v_dmd_count := v_dmd_count + nvl(v_count,0);
     end loop;
     close c_plan_orgs;

     if ( nvl(v_dmd_count,0) = 0 ) then
       v_qty := 0;
     else
       v_qty := v_qty / v_dmd_count;
     end if;
  end if;

   return v_qty;

END get_target_service_level;


FUNCTION service_data_exist(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER) RETURN BOOLEAN IS
  the_cursor KPICurTyp;
  sql_stat varchar2(1000);
  where_stat varchar2(1000);
  v_org_id number;
  v_instance_id number;
  v_item_id number;
  v_temp number;
BEGIN

  sql_stat := ' SELECT 1 ' ||
                ' FROM msc_demands ';

  where_stat := 'WHERE plan_id = :1 '||
               ' AND origination_type in (29) ';
  if p_instance_id is not null then
     where_stat := where_stat ||
              ' AND organization_id = :2 '||
              ' AND sr_instance_id = :3 ';
     v_org_id := p_organization_id;
     v_instance_id := p_instance_id;
  else
     where_stat := where_stat ||
              ' AND :2 = :3 ';
     v_org_id := -1;
     v_instance_id := -1;
  end if;

  if p_item_id is not null then
     where_stat := where_stat ||
              ' AND inventory_item_id = :4 ';
     v_item_id := p_item_id;
  else
     where_stat := where_stat ||
              ' AND -1 = :4 ';
     v_item_id := -1;
  end if;

  sql_stat := sql_stat || where_stat||
              ' and quantity_by_due_date is not null ' ||
              ' and rownum = 1 ';

  OPEN the_cursor FOR sql_stat USING p_plan_id,v_org_id,
                                     v_instance_id, v_item_id;
  FETCH the_cursor INTO v_temp;
  CLOSE the_cursor;

  if v_temp = 1 then
     return true;
  else
     return false;
  end if;

END service_data_exist;

FUNCTION service_target(p_plan IN NUMBER, p_instance_id IN NUMBER,
	p_org_id IN NUMBER, p_item_id IN NUMBER) RETURN NUMBER IS
  l_target 	NUMBER;

  CURSOR plan_target IS
   SELECT service_level
     FROM msc_plans
    WHERE plan_id = p_plan;

  CURSOR org_target IS
   SELECT service_level
     FROM msc_trading_partners
    WHERE sr_instance_id = p_instance_id
      AND sr_tp_id=p_org_id;

  CURSOR item_target IS
   SELECT service_level
     FROM msc_system_items
    WHERE plan_id = p_plan
      AND sr_instance_id = p_instance_id
      AND organization_id= p_org_id
      AND inventory_item_id = p_item_id;


BEGIN
    if p_item_id is not null then
       OPEN item_target;
       FETCH item_target INTO l_target;
       CLOSE item_target;
       if l_target is null then
          if p_org_id is not null then
             OPEN org_target;
             FETCH org_target INTO l_target;
             CLOSE org_target;
             if l_target is null then
                OPEN plan_target;
                FETCH plan_target INTO l_target;
                CLOSE plan_target;
             end if;
          else
             OPEN plan_target;
             FETCH plan_target INTO l_target;
             CLOSE plan_target;
          end if;
       end if;
    elsif p_org_id is not null then
         OPEN org_target;
         FETCH org_target INTO l_target;
         CLOSE org_target;
         if l_target is null then
            OPEN plan_target;
            FETCH plan_target INTO l_target;
            CLOSE plan_target;
         end if;
    else
         OPEN plan_target;
         FETCH plan_target INTO l_target;
         CLOSE plan_target;
    end if;
    return nvl(l_target,0);
END service_target;

FUNCTION service_target_trend(p_plan_id IN NUMBER, p_instance_id IN NUMBER,
	p_org_id IN NUMBER, p_item_id IN NUMBER) RETURN VARCHAR2 IS
  l_target 	NUMBER;
  l_target_list varchar2(500);
BEGIN

  l_target := service_target(p_plan_id, p_instance_id, p_org_id, p_item_id);

  FOR j in 1 .. g_period_name.LAST LOOP

     l_target_list := l_target_list ||g_param||
                            fnd_number.number_to_canonical(nvl(l_target,0));
  END LOOP;


  return l_target_list;
END service_target_trend;

FUNCTION construct_sup_where(p_organization_id number,
                             p_instance_id number,
                             p_item_id number,
                             p_sup_id number,
                             p_sup_site_id number) RETURN varchar2 IS
  where_stat varchar2(1000);

BEGIN
  if p_instance_id is not null then
     where_stat :=
    --      ' AND sup.organization_id = :2 ' ||
          ' AND sup.sr_instance_id = :3 ';
     g_org_id := p_organization_id;
     g_instance_id := p_instance_id;
  else
     where_stat := where_stat ||
          ' AND :3 = -1 ';
        g_org_id := -1;
        g_instance_id := -1;
  end if;

  if p_item_id is not null then
     where_stat := where_stat ||
          ' AND sup.inventory_item_id = :4 ';
     g_item_id := p_item_id;
  else
     where_stat := where_stat ||
          ' AND :4 = -1 ';
        g_item_id := -1;
  end if;

  if p_sup_id is not null then
     where_stat := where_stat ||
          ' AND sup.supplier_id = :5 ';
     g_sup_id := p_sup_id;
  else
     where_stat := where_stat ||
          ' AND :5 = -1 ';
        g_sup_id := -1;
  end if;

  if p_sup_site_id is not null then
     where_stat := where_stat ||
          ' AND sup.supplier_site_id = :6';
     g_sup_site_id := p_sup_site_id;
  else
     where_stat := where_stat ||
          ' AND :6 = -1';
        g_sup_site_id:= -1;
  end if;

 --dbms_output.put_line(where_stat);
  return where_stat;

END;
--Procedure call_get_actuals IS
--l_var varchar2(2000);
--BEGIN
--get_trend_actuals(2157,201,207,4,14661,null,
 --                   null, null, null,null, null,null,
  --                  243, null, 12271, 7023,l_var);
--exception
 -- when others then
    --dbms_output.put_line(sqlerrm);
--END;

Procedure refresh_kpi_data(p_plan_id number) IS
       l_err_buf         VARCHAR2(4000);
       l_ret_code        NUMBER;

   cursor show_kpi is
      select display_kpi, curr_plan_type
        from msc_plans
      where plan_id = p_plan_id;

   v_show_kpi number;
   v_plan_type number;
BEGIN
   OPEN show_kpi;
   FETCH show_kpi INTO v_show_kpi,v_plan_type;
   CLOSE show_kpi;

   if nvl(v_show_kpi,1) = 1 then
       FND_FILE.PUT_LINE(FND_FILE.LOG,'--- refreshing summary data for kpi  ---');
       msc_get_bis_values.refresh_data(l_err_buf, l_ret_code,p_plan_id, v_plan_type);
   else -- set kpi status as not refresh
     msc_get_bis_values.set_kpi_refresh_status(p_plan_id,'NOT REFRESH');
   end if;
     exception when others then
       FND_FILE.PUT_LINE(FND_FILE.LOG,'refreshing kpi summary data fails');
END refresh_kpi_data;



Procedure refresh_data(errbuf OUT NOCOPY VARCHAR2,
                       retcode OUT NOCOPY NUMBER,
                       p_plan_id number) is
l_plan_type number;
cursor c_plan_type is
      select plan_type from msc_plans where plan_id =p_plan_id;


BEGIN

    open c_plan_type;
    fetch c_plan_type into l_plan_type;
    close c_plan_type;

    refresh_data(errbuf,retcode,p_plan_id,l_plan_type);

end;



Procedure refresh_data(errbuf OUT NOCOPY VARCHAR2,
                       retcode OUT NOCOPY NUMBER,
                       p_plan_id number,
                       p_plan_type number) IS
  p_request_id number;
BEGIN
FND_FILE.PUT_LINE(FND_FILE.LOG,'start refreshing');
  -- set kpi as refreshing
 set_kpi_refresh_status(p_plan_id,'REFRESHING');

    for a in 1..5 loop

         p_request_id := fnd_request.submit_request(
                         'MSC',
                         'MSCKPIREF',
                         null,
                         null,
                         false,
                         p_plan_id,
                         a,
                         p_plan_type);
         FND_FILE.PUT_LINE(FND_FILE.LOG,'request id is ='||p_request_id);
    end loop;

    commit;

exception when others then
   set_kpi_refresh_status(p_plan_id,'NOT REFRESH');
END refresh_data;

Function IsKPIAvail(p_plan_id number) return number is
   cursor check_kpi is
     select kpi_refresh
       from msc_plans
      where plan_id = p_plan_id;

   v_kpi_refresh number;
begin

   OPEN check_kpi;
   FETCH check_kpi INTO v_kpi_refresh;
   CLOSE check_kpi;

   if v_kpi_refresh = 0 then -- REFRESHING
      return 2;
   elsif v_kpi_refresh = 5 then -- REFRESHE DONE
      return 1;
   else
      return 0;  -- NOT REFRESH
   end if;

end IsKPIAvail;


PROCEDURE set_kpi_refresh_status(p_plan_id number,p_status varchar2) is
        v_kpi_refresh number;
        v_status number;
begin
        select kpi_refresh
          into v_kpi_refresh
          from msc_plans
        where plan_id = p_plan_id;

        if p_status = 'NOT REFRESH' then
           v_status := -1;
        elsif p_status = 'REFRESHING' then
           v_status :=0;
        elsif p_status = 'ONE_DONE' then
           v_status := v_kpi_refresh + 1;
        end if;

MSC_UTIL.MSC_DEBUG('v_status='||v_status);
        update msc_plans
        set kpi_refresh = decode(v_status,0,0,-1,-1,kpi_refresh+1)
        where plan_id = p_plan_id;

        commit;
end set_kpi_refresh_status;

Procedure refresh_one_table(errbuf OUT NOCOPY VARCHAR2,
                       retcode OUT NOCOPY NUMBER,
                       p_plan_id number,
                       p_kpi_table number,
                       p_plan_type number) IS
BEGIN
if p_kpi_table =1 then

MSC_UTIL.MSC_DEBUG('refreshing MSC_BIS_INV_DATE_MV_TAB table for plan id '||p_plan_id);

   delete from msc_bis_inv_date_mv_tab
       where plan_id = p_plan_id;
   if p_plan_type = 8 then -- should change to srp

      insert into msc_bis_inv_date_mv_tab(
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    mds_price,
                    mds_cost,
                    inventory_cost,
                    production_cost,
                    purchasing_cost,
                    demand_penalty_cost,
                    carrying_cost,
                    plan_id,
                    organization_id,
                    sr_instance_id,
                    detail_date,
                    inventory_value,
                    planner_code)
     select
                    sysdate,
                    -1,
                    sysdate,
                    -1,
                    -1,
                    sum(nvl(mbid.mds_price,0)),
                    sum(nvl(mbid.mds_cost,0)),
                    sum(nvl(mbid.inventory_cost,0)),
                    sum(nvl(mbid.production_cost,0)),
                    sum(nvl(mbid.purchasing_cost,0)),
                    sum(nvl(mbid.demand_penalty_cost,0)+
                        nvl(mbid.supplier_overcap_cost,0)),
                    sum(nvl(mbid.carrying_cost,0)),
                    mbid.plan_id,
                    mbid.organization_id,
                    mbid.sr_instance_id,
                    mbid.detail_date,
                    sum(nvl(mbid.inventory_value,0)),
                    msi.planner_code
      from msc_bis_inv_detail mbid,
           msc_system_items msi
      where mbid.plan_id = p_plan_id
      and nvl(mbid.period_type,0) = 0
      and mbid.organization_id = msi.organization_id
      and mbid.sr_instance_id = msi.sr_instance_id
      and mbid.plan_id = msi.plan_id
      and mbid.inventory_item_id = msi.inventory_item_id
      group by mbid.plan_id,
      mbid.organization_id,
      mbid.sr_instance_id,
      mbid.detail_date,
      msi.planner_code;

   else
      insert into msc_bis_inv_date_mv_tab(
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    mds_price,
                    mds_cost,
                    inventory_cost,
                    production_cost,
                    purchasing_cost,
                    demand_penalty_cost,
                    carrying_cost,
                    plan_id,
                    organization_id,
                    sr_instance_id,
                    detail_date)
     select
                    sysdate,
                    -1,
                    sysdate,
                    -1,
                    -1,
                    sum(nvl(mds_price,0)),
                    sum(nvl(mds_cost,0)),
                    sum(nvl(inventory_cost,0)),
                    sum(nvl(production_cost,0)),
                    sum(nvl(purchasing_cost,0)),
                    sum(nvl(demand_penalty_cost,0)+
                        nvl(supplier_overcap_cost,0)),
                    sum(nvl(carrying_cost,0)),
                    plan_id,
                    organization_id,
                    sr_instance_id,
                    detail_date
      from msc_bis_inv_detail
      where plan_id = p_plan_id
      and nvl(period_type,0) = 0
      group by plan_id,
      organization_id,
      sr_instance_id,
      detail_date;
   end if; -- if p_plan_type =
elsif p_kpi_table =2 then
MSC_UTIL.MSC_DEBUG('refreshing MSC_BIS_INV_CAT_MV_TAB table for plan id '||p_plan_id);
   delete from msc_bis_inv_cat_mv_tab
    where plan_id = p_plan_id;

   insert into msc_bis_inv_cat_mv_tab(
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    mds_price,
                    mds_cost,
                    inventory_cost,
                    production_cost,
                    purchasing_cost,
                    demand_penalty_cost,
                    carrying_cost,
                    plan_id,
                    organization_id,
                    sr_instance_id,
                    sr_category_id,
                    category_name,
                    category_set_id,
                    detail_date)
     select
                    sysdate,
                    -1,
                    sysdate,
                    -1,
                    -1,
                    sum(nvl(mbis.mds_price,0)),
                    sum(nvl(mbis.mds_cost,0)),
                    sum(nvl(mbis.inventory_cost,0)),
                    sum(nvl(mbis.production_cost,0)),
                    sum(nvl(mbis.purchasing_cost,0)),
                    sum(nvl(mbis.demand_penalty_cost,0)+
                        nvl(mbis.supplier_overcap_cost,0)),
                    sum(nvl(mbis.carrying_cost,0)),
                    mbis.plan_id,
                    mbis.organization_id,
                    mbis.sr_instance_id,
                    mit.sr_category_id,
                    mit.category_name,
                    mit.category_set_id,
                    mbis.detail_date
      from msc_bis_inv_detail mbis,
           msc_item_categories mit
      where mbis.plan_id = p_plan_id
        and mit.organization_id = mbis.organization_id
        and mit.sr_instance_id = mbis.sr_instance_id
        and mit.inventory_item_id = mbis.inventory_item_id
        and nvl(mbis.period_type,0) = 0
      group by mbis.plan_id,
      mbis.organization_id,
      mbis.sr_instance_id,
      mit.sr_category_id,
      mit.category_name,
      mit.category_set_id,
      mbis.detail_date;

elsif p_kpi_table = 3 then
MSC_UTIL.MSC_DEBUG('refreshing MSC_DEMAND_MV_TAB table for plan id '||p_plan_id);
   delete from msc_demand_mv_tab
    where plan_id = p_plan_id;

   insert into msc_demand_mv_tab(
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    plan_id,
                    organization_id,
                    sr_instance_id,
                    demand_count)
     select
                    sysdate,
                    -1,
                    sysdate,
                    -1,
                    -1,
                    plan_id,
                    organization_id,
                    sr_instance_id,
                    count(*)
      from msc_demands
      where origination_type in (6,7,8,9,10,11,12,15,22,24,27,29,30)
        and plan_id = p_plan_id
      group by plan_id,
      organization_id,
      sr_instance_id;

elsif p_kpi_table = 4 then
MSC_UTIL.MSC_DEBUG('refreshing MSC_LATE_ORDER_MV_TAB table for plan id '||p_plan_id);
   delete from msc_late_order_mv_tab
    where plan_id = p_plan_id;

   insert into msc_late_order_mv_tab(
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    plan_id,
                    organization_id,
                    sr_instance_id,
                    late_order_count)
     select
                    sysdate,
                    -1,
                    sysdate,
                    -1,
                    -1,
                    plan_id,
                    organization_id,
                    sr_instance_id,
                    count(distinct number1)
      from msc_exception_details
      where exception_type in (13,14,24,26)
        and plan_id = p_plan_id
      group by plan_id,
      organization_id,
      sr_instance_id;

elsif p_kpi_table = 5 then
MSC_UTIL.MSC_DEBUG('refreshing MSC_BIS_RES_DATE_MV_TAB table for plan id '||p_plan_id);
   delete from msc_bis_res_date_mv_tab
    where plan_id = p_plan_id;

   insert into msc_bis_res_date_mv_tab(
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    plan_id,
                    organization_id,
                    sr_instance_id,
                    resource_date,
                    utilization,
                    util_count,
                    util_sum)
     select
                    sysdate,
                    -1,
                    sysdate,
                    -1,
                    -1,
                    res.plan_id,
                    res.organization_id,
                    res.sr_instance_id,
                    res.resource_date,
                    avg(nvl(res.utilization,0)),
                    count(nvl(res.utilization,0)),
                    sum(nvl(res.utilization,0))
      from msc_department_resources mdr,
           msc_bis_res_summary res
      where mdr.department_id = res.department_id
        AND mdr.resource_id = res.resource_id
        AND mdr.plan_id = res.plan_id
        AND mdr.sr_instance_id = res.sr_instance_id
        AND mdr.organization_id = res.organization_id
        and mdr.plan_id = p_plan_id
        AND nvl(res.period_type,0) = 0
      group by res.plan_id,
      res.organization_id,
      res.sr_instance_id,
      res.resource_date;
end if;
      commit;
msc_get_bis_values.set_kpi_refresh_status(p_plan_id,'ONE_DONE');
exception when no_data_found then
      msc_get_bis_values.set_kpi_refresh_status(p_plan_id,'ONE_DONE');
END refresh_one_table;

Procedure ui_post_plan(errbuf OUT NOCOPY VARCHAR2,
                       retcode OUT NOCOPY NUMBER,
                       p_plan_id IN number) IS

   lv_msc_schema     VARCHAR2(30);
   v_tree_exist      number;

   Cursor msc_schema IS
    SELECT a.oracle_username
    FROM   FND_ORACLE_USERID a, FND_PRODUCT_INSTALLATIONS b
    WHERE  a.oracle_id = b.oracle_id
    AND    b.application_id= 724;

   Cursor tree_snap IS
    SELECT 1
    FROM   all_objects
    WHERE  object_name = 'MSC_SUPPLIER_TREE_MV'
    AND    owner = lv_msc_schema;

   Cursor plan_c is
    select display_kpi, plan_type
      from msc_plans
     where plan_id = p_plan_id;

   v_plan_type number;
   v_show_kpi number;

  cursor c_plan_archive is
  select nvl(archive_flag,2)
  from msc_plans
  where plan_id = p_plan_id;
  l_archive_flag number;
  l_req_id number;
Begin

  if v_tree_exist =1 then
    MSC_UTIL.msc_debug('---- refreshing tree mv----');
    DBMS_SNAPSHOT.REFRESH( lv_msc_schema||'.MSC_SUPPLIER_TREE_MV');
  end if;

   msc_get_bis_values.refresh_kpi_data(p_plan_id);

   msc_launch_plan_pk.purge_user_notes_data(p_plan_id);

   msc_netchange_pkg.compare_plan_need_refresh(p_plan_id);

   MSC_pers_queries.purge_plan(p_plan_id);

   --msd_liability.run_liability_flow_ascp(errbuf,retcode,p_plan_id);
   OPEN plan_c;
   FETCH plan_c INTO v_show_kpi, v_plan_type;
   CLOSE plan_c;

   if v_plan_type in (4,9) then
      MSC_ANALYSIS_SAFETY_STOCK_PERF.schedule_aggregate(p_plan_id);
   end if;
   if v_plan_type in (8,9) then -- srp plan
      msc_drp_util.retrieve_exp_version(p_plan_id);
   end if;
   if v_plan_type = 8 then -- srp plan
      MSC_PQ_UTILS.execute_plan_worklists(errbuf, retcode,
                                          p_plan_id);
   end if;

     --pabram..phub
     if (nvl(v_show_kpi, 1)=1 and v_plan_type not in (5)) then
       open c_plan_archive;
       fetch c_plan_archive into l_archive_flag;
       close c_plan_archive;
       l_req_id := fnd_request.submit_request('MSC','MSCHUBA',NULL, NULL, FALSE, p_plan_id, null, l_archive_flag);
       commit;
     else
       msc_util.msc_debug('MSCHUBA not invoked, v_show_kpi='||v_show_kpi||', v_plan_type='||v_plan_type);
     end if;
     --pabram..phub ends

End  ui_post_plan;


END Msc_Get_Bis_Values;

/
