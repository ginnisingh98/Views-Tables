--------------------------------------------------------
--  DDL for Package Body MSD_SCE_PUBLISH_FORECAST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_SCE_PUBLISH_FORECAST_PKG" AS
/* $Header: msdxpcfb.pls 115.10 2004/07/15 22:26:59 esubrama ship $ */

PROCEDURE publish_customer_forecast (
  p_errbuf                  out NOCOPY varchar2,
  p_retcode                 out NOCOPY varchar2,
  p_designator              in varchar2,
  p_order_type              in number,
  p_demand_plan_id          in number,
  p_scenario_id             in number,
  p_forecast_date           in varchar2,
  p_org_code                in varchar2,
  p_planner_code            in varchar2,
--  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_customer_id             in number,
  p_customer_site_id        in number,
  p_horizon_start           in varchar2,
  p_horizon_days            in number,
  p_auto_version            in number,
  p_version                 in number
) IS

p_org_id                    Number;
p_sr_instance_id            Number;
p_horizon_end               date;
l_horizon_start             date;            --canonical date
l_version                   Number;
l_order_type                Varchar2(80);

t_pub                       companyNameList;
t_pub_id                    numberList;
t_pub_site                  companySiteList;
t_pub_site_id               numberList;
t_item_id                   numberList;
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
t_pub_ot_desc               fndMeaningList;
t_bkt_type_desc             fndMeaningList;
t_posting_party_name        companyNameList;
t_uom_code                  itemUomList;
t_planner_code              plannerCodeList;
t_end_date                  dateList;
t_ship_date                 dateList;
t_receipt_date              dateList;
-- t_src_cust_id               numberList;
t_tp_cust_id                numberList;
t_src_cust_site_id          numberList;
t_src_org_id                numberList;
t_src_instance_id           numberList;
t_shipping_control          shippingControlList;
t_lead_time                 numberList;

t_tp_uom                    itemUomList := itemUomList();
t_tp_qty                    numberList := numberList();
t_tp_ship_date              dateList := dateList();
t_tp_receipt_date           dateList := dateList();
t_master_item_name          itemNameList := itemNameList();
t_master_item_desc          itemDescList := itemDescList();
t_cust_item_name            itemNameList := itemNameList();
t_cust_item_desc            itemDescList := itemDescList();


CURSOR publish_cust_fcst_c1 (
  p_scenario_id             in number,
  p_org_id                  in number,
  p_sr_instance_id          in number,
  l_horizon_start           in date,
  p_horizon_end             in date,
  p_planner_code            in varchar2,
--  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_customer_id             in number,
  p_customer_site_id        in number
) IS
select c.company_name,             --publisher
       c.company_id,               --publisher id
       cs.company_site_name,       --publisher site
       cs.company_site_id,         --publisher site id
       item.inventory_item_id,     --inventory item id
       round(fcst.quantity, 6),    --quantity
       p_order_type,               --publisher order type
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
       fcst.bucket_type,           --bucket type
       c.company_id,               --posting party id
       item.item_name,             --publisher item name
       item.description,           --publisher item desc
       l_order_type,               --publisher order type desc
       fcst.bucket_type,           --bucket type desc
       c.company_name,             --posting supplier name [Owner]
       fcst.uom_code,              --primary uom
       item.planner_code,          --planner code
       fcst.end_date,              --end date
       fcst.start_date,            --ship date
       fcst.start_date,            --receipt date
--       ti1.sr_tp_id,               --Source Partner Id
       ts1.partner_id,             --Partner_id
       tsi1.sr_tp_site_id,         --Source Partner Site Id
       fcst.sr_organization_id,    --Source Partner Org Id
       fcst.sr_instance_id,         --Source Partner Instance Id,
       ts1.shipping_control,        --Shipping control method
       MSD_SCE_RECEIVE_FORECAST_PKG.get_intrasit_lead_time(t.sr_instance_id, t.sr_tp_id, tsi1.location_id)
from   msd_dp_sce_scn_entries_v fcst,
       msc_system_items item,
       msc_company_sites cs,
       msc_company_sites cs1,
       msc_companies c,
       msc_companies c1,
       msc_trading_partner_maps m,
       msc_trading_partner_maps m2,
       msc_trading_partners t,
       msc_tp_site_id_lid tsi1,
       msc_trading_partner_sites ts1
--       msc_tp_id_lid ti1
where  fcst.sr_instance_id = item.sr_instance_id and
       fcst.sr_organization_id = item.organization_id and
       fcst.sr_inventory_item_id = item.sr_inventory_item_id and
       item.plan_id = -1 and
/*  Mapping Organization  */
       t.sr_tp_id = fcst.sr_organization_id and
       t.sr_instance_id = fcst.sr_instance_id and
       t.partner_type = 3 and
       m.tp_key = t.partner_id and
       m.map_type = 2 and
       m.company_key = cs.company_site_id and
       c.company_id = cs.company_id and
/*  Mapping Customer Site */
       tsi1.sr_tp_site_id = fcst.sr_geography_id and
       tsi1.sr_instance_id = fcst.sr_instance_id and
       tsi1.partner_type = 2 and
       nvl(tsi1.sr_company_id, -1) = -1 and
       m2.tp_key = tsi1.tp_site_id and
       m2.map_type = 3 and
       cs1.company_site_id = m2.company_key and
       cs1.company_id = c1.company_id and
/*  Mapping Customer site - for source Customer Site Id  */
       ts1.partner_site_id = tsi1.tp_site_id and
/*  Mapping Customer - for source Customer Id  */
--       ti1.tp_id = ts1.partner_id and
--       ti1.sr_instance_id = fcst.sr_instance_id and
--       ti1.partner_type = 2 and
--       nvl(ti1.sr_company_id, -1) = -1 and
/*   Filter conditions */
       ts1.partner_id = NVL(p_customer_id, ts1.partner_id) and
       ts1.partner_site_id = NVL(p_customer_site_id, ts1.partner_site_id) and
    --   NVL(item.abc_class_name,'-99') = NVL(p_abc_class, NVL(item.abc_class_name,'-99')) and
       NVL(item.planner_code,'-99') = NVL(p_planner_code, NVL(item.planner_code,'-99')) and
       item.inventory_item_id = nvl(p_item_id, item.inventory_item_id ) and
       item.organization_id = NVL(p_org_id, item.organization_id) and
       item.sr_instance_id = NVL(p_sr_instance_id, item.sr_instance_id) and
       fcst.scenario_id = p_scenario_id and
       fcst.start_date between nvl(l_horizon_start, sysdate) and nvl(p_horizon_end, sysdate+365);


BEGIN
  l_horizon_start := fnd_date.canonical_to_date(p_horizon_start);
  p_horizon_end := nvl(l_horizon_start, sysdate)+nvl(p_horizon_days, 365);

  select meaning
  into l_order_type
  from fnd_lookup_values_vl
  where lookup_type = 'MSC_X_ORDER_TYPE'
  and lookup_code = p_order_type;

  if p_org_code is not null then

    select sr_tp_id, sr_instance_id
    into   p_org_id, p_sr_instance_id
    from   msc_trading_partners
    where  organization_code = p_org_code and
           partner_type = 3 and
           company_id is null;
    -- dbms_output.put_line('p_org_id := ' || p_org_id);
    -- dbms_output.put_line('p_sr_instance_id := ' || p_sr_instance_id);
  else
    p_org_id := null;
    p_sr_instance_id := null;
  end if;

  if nvl(p_auto_version, 1) = 1 then
    l_version := p_version + 1;
  else
    l_version := null;
  end if;

  delete_old_forecast(
    p_org_id,
    p_sr_instance_id,
    p_planner_code,
--    p_abc_class,
    p_item_id,
    p_customer_id,
    p_customer_site_id,
    l_horizon_start,
    p_horizon_end
  );


  OPEN publish_cust_fcst_c1 (
     p_scenario_id
    ,p_org_id
    ,p_sr_instance_id
    ,l_horizon_start
    ,p_horizon_end
    ,p_planner_code
--    ,p_abc_class
    ,p_item_id
    ,p_customer_id
    ,p_customer_site_id
  );

  FETCH publish_cust_fcst_c1 BULK COLLECT INTO
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
    ,t_bkt_type_desc
    ,t_posting_party_name
    ,t_uom_code
    ,t_planner_code
    ,t_end_date
    ,t_ship_date
    ,t_receipt_date
    ,t_tp_cust_id
    ,t_src_cust_site_id
    ,t_src_org_id
    ,t_src_instance_id
    ,t_shipping_control
    ,t_lead_time;
  CLOSE publish_cust_fcst_c1;


  IF t_pub IS NOT NULL AND t_pub.COUNT > 0 THEN
    -- dbms_output.put_line ('Records fetched by cursor := ' || t_pub.COUNT);

    get_optional_info(
      t_item_id,
      t_pub_id,
      t_cust_id,
      t_cust_site_id,
      t_tp_cust_id,
      t_src_cust_site_id,
      t_src_org_id,
      t_src_instance_id,
      t_item_name,
      t_uom_code,
      t_qty,
      t_ship_date,
      t_receipt_date,
      t_tp_ship_date,
      t_tp_receipt_date,
      t_master_item_name,
      t_master_item_desc,
      t_cust_item_name,
      t_cust_item_desc,
      t_tp_uom,
      t_tp_qty,
      t_lead_time,
      p_forecast_date
    );

  explode_dates (
    t_pub,
    t_pub_id,
    t_pub_site,
    t_pub_site_id,
    t_item_id,
    t_qty,
    t_pub_ot,
    t_cust,
    t_cust_id,
    t_cust_site,
    t_cust_site_id,
    t_ship_from,
    t_ship_from_id,
    t_ship_from_site,
    t_ship_from_site_id,
    t_ship_to,
    t_ship_to_id,
    t_ship_to_site,
    t_ship_to_site_id,
    t_bkt_type,
    t_posting_party_id,
    t_item_name,
    t_item_desc,
    t_pub_ot_desc,
    t_bkt_type_desc,
    t_posting_party_name,
    t_uom_code,
    t_planner_code,
    t_end_date,
    t_ship_date,
    t_tp_ship_date,
    t_receipt_date,
    t_tp_receipt_date,
    t_master_item_name,
    t_master_item_desc,
    t_cust_item_name,
    t_cust_item_desc,
    t_tp_uom,
    t_tp_qty
  );


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
      ,t_bkt_type_desc
      ,t_posting_party_name
      ,t_uom_code
      ,t_planner_code
      ,t_tp_ship_date
      ,t_tp_receipt_date
      ,t_tp_uom
      ,t_tp_qty
      ,l_version
      ,p_designator
      ,t_shipping_control
    );

    commit;
    p_errbuf := 'Total records processed := ' || t_pub.COUNT;

  else
       p_errbuf := 'There were no rows fetched.';
       p_retcode := 1;

  end if;

        exception

          when others then

                p_errbuf := substr(SQLERRM,1,150);
                p_retcode := -1;
                rollback;

END publish_customer_forecast;

PROCEDURE explode_dates (
  t_pub                       IN OUT NOCOPY companyNameList,
  t_pub_id                    IN OUT NOCOPY numberList,
  t_pub_site                  IN OUT NOCOPY companySiteList,
  t_pub_site_id               IN OUT NOCOPY numberList,
  t_item_id                   IN OUT NOCOPY numberList,
  t_qty                       IN OUT NOCOPY numberList,
  t_pub_ot                    IN OUT NOCOPY numberList,
  t_cust                      IN OUT NOCOPY companyNameList,
  t_cust_id                   IN OUT NOCOPY numberList,
  t_cust_site                 IN OUT NOCOPY companySiteList,
  t_cust_site_id              IN OUT NOCOPY numberList,
  t_ship_from                 IN OUT NOCOPY companyNameList,
  t_ship_from_id              IN OUT NOCOPY numberList,
  t_ship_from_site            IN OUT NOCOPY companySiteList,
  t_ship_from_site_id         IN OUT NOCOPY numberList,
  t_ship_to                   IN OUT NOCOPY companyNameList,
  t_ship_to_id                IN OUT NOCOPY numberList,
  t_ship_to_site              IN OUT NOCOPY companySiteList,
  t_ship_to_site_id           IN OUT NOCOPY numberList,
  t_bkt_type                  IN OUT NOCOPY numberList,
  t_posting_party_id          IN OUT NOCOPY numberList,
  t_item_name                 IN OUT NOCOPY itemNameList,
  t_item_desc                 IN OUT NOCOPY itemDescList,
  t_pub_ot_desc               IN OUT NOCOPY fndMeaningList,
  t_bkt_type_desc             IN OUT NOCOPY fndMeaningList,
  t_posting_party_name        IN OUT NOCOPY companyNameList,
  t_uom_code                  IN OUT NOCOPY itemUomList,
  t_planner_code              IN OUT NOCOPY plannerCodeList,
  t_end_date                  IN OUT NOCOPY dateList,
  t_ship_date                 IN OUT NOCOPY dateList,
  t_tp_ship_date              IN OUT NOCOPY dateList,
  t_receipt_date              IN OUT NOCOPY dateList,
  t_tp_receipt_date           IN OUT NOCOPY dateList,
  t_master_item_name          IN OUT NOCOPY itemNameList,
  t_master_item_desc          IN OUT NOCOPY itemDescList,
  t_cust_item_name            IN OUT NOCOPY itemNameList,
  t_cust_item_desc            IN OUT NOCOPY itemDescList,
  t_tp_uom                    IN OUT NOCOPY itemUomList,
  t_tp_qty                    IN OUT NOCOPY numberList
) IS

numFirst NUMBER := t_item_id.FIRST;
numLast NUMBER := t_item_id.LAST;
p_qty_per_day NUMBER;
p_curr_date   DATE;
p_curr_month_start_date DATE;
p_curr_month_end_date DATE;
new_qty NUMBER(15,6);
numInsertIndex NUMBER;
p_first_insert boolean;
p_done boolean := FALSE;
l_bkt_desc  varchar2(80);

begin

  for j in numFirst..numLast loop

    select meaning
    into l_bkt_desc
    from fnd_lookup_values_vl
    where lookup_type = 'MSC_X_BUCKET_TYPE' and
          lookup_code = decode(t_bkt_type(j), 9, 1, 1, 2, 3);

    t_bkt_type_desc(j) := l_bkt_desc;

    p_first_insert := TRUE;
    /* Day */
    if (t_bkt_type(j) = 9) then
      t_bkt_type(j) := 1;
    /* Fiscal Month, Manufacturing Period */
    elsif (t_bkt_type(j) in (2,3)) then
      t_bkt_type(j) := 3;
      t_ship_date(j) := TRUNC(t_ship_date(j), 'MONTH');

    /* Manufacturing Week */
    elsif (t_bkt_type(j) = 1) then
      t_bkt_type(j) := 2;
        t_ship_date(j) := next_day(t_ship_date(j),
                                   to_char(to_date('11/03/1997', 'DD/MM/RRRR'), 'DY')) - 7;

    else
      /* Rest move to Month */
      t_bkt_type(j) := 3;

      /* Quantity per day equals total quantity divided by number of days */
      p_qty_per_day := t_qty(j) / (t_end_date(j) - t_ship_date(j));
      p_curr_date   := t_ship_date(j);

      LOOP
        p_curr_month_start_date := TRUNC(p_curr_date, 'MONTH');
        p_curr_month_end_date   := LAST_DAY(p_curr_date);

        if (p_curr_month_start_date = p_curr_date
            AND
            p_curr_month_end_date < t_end_date(j)) then
          new_qty := p_qty_per_day * (p_curr_month_end_date - p_curr_month_start_date);
          p_curr_date := p_curr_month_end_date + 1;
        elsif (p_curr_month_start_date <> p_curr_date
            AND
            p_curr_month_end_date < t_end_date(j)) then
          new_qty := p_qty_per_day * (p_curr_month_end_date - p_curr_date);
          p_curr_date := p_curr_month_end_date + 1;
        else
          new_qty := p_qty_per_day * (t_end_date(j) - p_curr_month_start_date);
          p_done := TRUE;
        end if;

        if (p_first_insert) then
          numInsertIndex := j;
          p_first_insert := FALSE;
        else
          numInsertIndex := t_pub.LAST + 1;
        end if;
        if (numInsertIndex > t_pub.LAST) then
          t_pub.EXTEND;
          t_pub_id.EXTEND;
          t_pub_site.EXTEND;
          t_pub_site_id.EXTEND;
          t_item_id.EXTEND;
          t_qty.EXTEND;
          t_pub_ot.EXTEND;
          t_cust.EXTEND;
          t_cust_id.EXTEND;
          t_cust_site.EXTEND;
          t_cust_site_id.EXTEND;
          t_ship_from.EXTEND;
          t_ship_from_id.EXTEND;
          t_ship_from_site.EXTEND;
          t_ship_from_site_id.EXTEND;
          t_ship_to.EXTEND;
          t_ship_to_id.EXTEND;
          t_ship_to_site.EXTEND;
          t_ship_to_site_id.EXTEND;
          t_bkt_type.EXTEND;
          t_posting_party_id.EXTEND;
          t_item_name.EXTEND;
          t_item_desc.EXTEND;
          t_pub_ot_desc.EXTEND;
          t_bkt_type_desc.EXTEND;
          t_posting_party_name.EXTEND;
          t_uom_code.EXTEND;
          t_planner_code.EXTEND;
          t_ship_date.EXTEND;
          t_tp_ship_date.EXTEND;
          t_receipt_date.EXTEND;
          t_tp_receipt_date.EXTEND;
          t_tp_uom.EXTEND;
          t_tp_qty.EXTEND;
          t_master_item_name.EXTEND;
          t_master_item_desc.EXTEND;
          t_cust_item_name.EXTEND;
          t_cust_item_desc.EXTEND;

        end if;

        t_pub(numInsertIndex) := t_pub(j);
        t_pub_id(numInsertIndex) := t_pub_id(j);
        t_pub_site(numInsertIndex) := t_pub_site(j);
        t_pub_site_id(numInsertIndex) := t_pub_site_id(j);
        t_item_id(numInsertIndex) := t_item_id(j);
        t_qty(numInsertIndex) := new_qty;
        t_pub_ot(numInsertIndex) := t_pub_ot(j);
        t_cust(numInsertIndex) := t_cust(j);
        t_cust_id(numInsertIndex) := t_cust_id(j);
        t_cust_site(numInsertIndex) := t_cust_site(j);
        t_cust_site_id(numInsertIndex) := t_cust_site_id(j);
        t_ship_from(numInsertIndex) := t_ship_from(j);
        t_ship_from_id(numInsertIndex) := t_ship_from_id(j);
        t_ship_from_site(numInsertIndex) := t_ship_from_site(j);
        t_ship_from_site_id(numInsertIndex) := t_ship_from_site_id(j);
        t_ship_to(numInsertIndex) := t_ship_to(j);
        t_ship_to_id(numInsertIndex) := t_ship_to_id(j);
        t_ship_to_site(numInsertIndex) := t_ship_to_site(j);
        t_ship_to_site_id(numInsertIndex) := t_ship_to_site_id(j);
        t_bkt_type(numInsertIndex) := 3;
        t_posting_party_id(numInsertIndex) := t_posting_party_id(j);
        t_item_name(numInsertIndex) := t_item_name(j);
        t_item_desc(numInsertIndex) := t_item_desc(j);
        t_pub_ot_desc(numInsertIndex) := t_pub_ot_desc(j);
        t_bkt_type_desc(numInsertIndex) := l_bkt_desc;
        t_posting_party_name(numInsertIndex) := t_posting_party_name(j);
        t_uom_code(numInsertIndex) := t_uom_code(j);
        t_planner_code(numInsertIndex) := t_planner_code(j);
        t_ship_date(numInsertIndex) := p_curr_month_start_date;
        t_tp_ship_date(numInsertIndex) := p_curr_month_start_date;
        t_receipt_date(numInsertIndex) := t_receipt_date(j);
        t_tp_receipt_date(numInsertIndex) := t_tp_receipt_date(j);
        t_tp_uom(numInsertIndex) := t_tp_uom(j);
        t_tp_qty(numInsertIndex) := new_qty;
        t_master_item_name(numInsertIndex) := t_master_item_name(j);
        t_master_item_desc(numInsertIndex) := t_master_item_desc(j);
        t_cust_item_name(numInsertIndex) := t_cust_item_name(j);
        t_cust_item_desc(numInsertIndex) := t_cust_item_desc(j);


        if (p_done) then
          exit;
        end if;
       END LOOP;
     end if;
  end loop;
end explode_dates;


PROCEDURE get_optional_info(
  t_item_id         	IN numberList,
  t_pub_id          	IN numberList,
  t_cust_id             IN numberList,
  t_cust_site_id        IN numberList,
  t_tp_cust_id          IN numberList,
  t_src_cust_site_id    IN numberList,
  t_src_org_id          IN numberList,
  t_src_instance_id     IN numberList,
  t_item_name       	IN itemNameList,
  t_uom_code        	IN itemUomList,
  t_qty             	IN numberList,
  t_ship_date    	IN dateList,
  t_receipt_date    	IN dateList,
  t_tp_ship_date 	IN OUT NOCOPY dateList,
  t_tp_receipt_date 	IN OUT NOCOPY dateList,
  t_master_item_name    IN OUT NOCOPY itemNameList,
  t_master_item_desc    IN OUT NOCOPY itemDescList,
  t_cust_item_name      IN OUT NOCOPY itemNameList,
  t_cust_item_desc      IN OUT NOCOPY itemDescList,
  t_tp_uom          	IN OUT NOCOPY itemUomList,
  t_tp_qty          	IN OUT NOCOPY numberList,
  t_lead_time           IN numberList,
  p_forecast_date       IN varchar2
) IS

  l_conversion_found boolean;
  l_conversion_rate  number;
--  l_to_location_id   number;
--  l_org_location_id  number;
--  l_lead_time        number;
--  l_session_id       number;
--  l_src_cust_id      number;
--  l_regions_return_status varchar(1);

cursor get_src_cust_id_c1(t_tp_cust_id IN number,
                          t_src_instance_id IN number) IS
  SELECT sr_tp_id
  FROM msc_tp_id_lid
  WHERE tp_id = t_tp_cust_id
  AND sr_instance_id = t_src_instance_id
  AND nvl(sr_company_id, -1) = -1
  AND partner_type = 2;


BEGIN

    for j in t_item_id.FIRST..t_item_id.LAST loop
      t_tp_ship_date.EXTEND;
      t_tp_receipt_date.EXTEND;
      t_tp_uom.EXTEND;
      t_tp_qty.EXTEND;
      t_master_item_name.EXTEND;
      t_master_item_desc.EXTEND;
      t_cust_item_name.EXTEND;
      t_cust_item_desc.EXTEND;

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
        select mcf.customer_item_name,
               mcf.description,
               mcf.uom_code
        into   t_cust_item_name(j),
               t_cust_item_desc(j),
               t_tp_uom(j)
        from   msc_item_customers mcf,
               msc_trading_partner_maps m,
               msc_trading_partner_maps m2,
               msc_company_relationships r
        where  mcf.inventory_item_id = t_item_id(j) and
               mcf.plan_id = -1 and
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
          begin
               select mcf.customer_item_name,
                      mcf.description,
                      mcf.uom_code
               into   t_cust_item_name(j),
                      t_cust_item_desc(j),
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
                      mcf.customer_site_id is null;

               exception
                 when NO_DATA_FOUND then

                      t_cust_item_name(j) := null;
                      t_tp_uom(j) := t_uom_code(j);
               end;
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

/*
     --   Get source customer Id

       l_src_cust_id := null;

       open get_src_cust_id_c1(t_tp_cust_id(j),t_src_instance_id(j));
       fetch get_src_cust_id_c1 into l_src_cust_id;
       close get_src_cust_id_c1;

       if l_src_cust_id is null or t_src_cust_site_id(j) is null then
       		l_lead_time := 0;
       else
      		l_org_location_id := null;
      		l_to_location_id := null;
      		l_lead_time := null;

	        -- Call the ATP API's for regions setup

			select mrp_atp_schedule_temp_s.nextval
		    	into l_session_id
		    	from dual;

		    MSC_SATP_FUNC.GET_REGIONS(t_src_cust_site_id(j),
                                  724, -- Calling Module is 'MSC'
                                  t_src_instance_id(j),
                                  l_session_id,
                                  null,
                                  l_regions_return_status);



            --  Get the default ship to/deliver from location for the org

                l_org_location_id := msc_atp_func.get_location_id(
                         			t_src_instance_id(j),
                         			t_src_org_id(j),
                         			null,
                         			null,
                         			null,
                         			null);

      -- dbms_output.put_line('Org Location Id ' || l_org_location_id);

            -- Get the default ship to/deliver from location for the customer

       		l_to_location_id := msc_atp_func.get_location_id(
               		                        t_src_instance_id(j),
                                        	null,
                                        	l_src_cust_id,
                                        	t_src_cust_site_id(j),
                                        	null,
                                        	null);

      -- dbms_output.put_line('Location Id ' || l_to_location_id);

       		l_lead_time := MSC_SCATP_PUB.get_default_intransit_time (
      		                        	l_org_location_id,
                	                	t_src_instance_id(j),
               		                      	l_to_location_id,
                                        	t_src_instance_id(j),
						l_session_id,
						t_src_cust_site_id(j));

      -- dbms_output.put_line('Lead time ' || l_lead_time);

      		if l_lead_time is null then
          		l_lead_time := 0;
      		end if;

     end if;

     t_tp_receipt_date(j) := t_receipt_date(j) + l_lead_time;

     -- dbms_output.put_line('receipt date ' || t_tp_receipt_date(j));
*/

     if p_forecast_date = 'SHIP' then

        t_tp_ship_date(j) := t_ship_date(j);
        t_tp_receipt_date(j) := t_ship_date(j) + t_lead_time(j);

     elsif p_forecast_date = 'RECEIPT' then

        t_tp_ship_date(j) := t_ship_date(j) - t_lead_time(j);
        t_tp_receipt_date(j) := t_receipt_date(j);

     end if;


   end loop;

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
  t_bkt_type_desc             IN fndMeaningList,
  t_posting_party_name        IN companyNameList,
  t_uom_code                  IN itemUomList,
  t_planner_code              IN plannerCodeList,
  t_tp_ship_date              IN dateList,
  t_tp_receipt_date           IN dateList,
  t_tp_uom                    IN itemUomList,
  t_tp_qty                    IN numberList,
  p_version                   IN varchar2,
  p_designator                IN varchar2,
  t_shipping_control          IN shippingControlList
) IS

BEGIN

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
           item_name,
           item_description,
           owner_item_name,
           owner_item_description,
           supplier_item_name,
           supplier_item_description,
           customer_item_name,
           customer_item_description,
           inventory_item_id,
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
           planner_code,
           version,
           designator,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
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
        t_pub_ot_desc(j),
        t_bkt_type_desc(j),
        t_bkt_type(j),
        t_master_item_name(j),
        t_master_item_desc(j),
        t_item_name(j),
        t_item_desc(j),
        t_item_name(j),
        t_item_desc(j),
        t_cust_item_name(j),
        t_cust_item_desc(j),
        t_item_id(j),
        t_uom_code(j),
        t_uom_code(j),
        t_tp_uom(j),
        decode(t_pub_ot(j), 4, t_tp_receipt_date(j), decode(nvl(t_shipping_control(j), 'BUYER'), 'BUYER', t_tp_ship_date(j), t_tp_receipt_date(j))),
        t_tp_ship_date(j),
        t_tp_receipt_date(j),
	t_qty(j),
        t_qty(j),
        t_tp_qty(j),
        msc_cl_refresh_s.nextval,
        t_posting_party_name(j),
        t_posting_party_id(j),
        t_planner_code(j),
        p_version,
        p_designator,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id
        );
END insert_into_sup_dem;


PROCEDURE delete_old_forecast(
  p_org_id                  in number,
  p_sr_instance_id          in number,
  p_planner_code            in varchar2,
--  p_abc_class               in varchar2,
  p_item_id                 in number,
  p_customer_id             in number,
  p_customer_site_id        in number,
  l_horizon_start           in date,
  p_horizon_end             in date
) IS

  l_customer_id       number;
  l_customer_site_id  number;
  l_supplier_site_id  number;

BEGIN

  if p_customer_id is not null then
   BEGIN
     select c.company_id
     into   l_customer_id
     from   msc_trading_partner_maps m,
            msc_company_relationships r,
            msc_companies c
     where  m.tp_key = p_customer_id and
            m.map_type = 1 and
            m.company_key = r.relationship_id and
            r.relationship_type = 1 and
            r.subject_id = 1 and    /*  Owner Company Id */
            c.company_id = r.object_id;
   EXCEPTION
     WHEN OTHERS THEN
       l_customer_id := NULL;
   END;
  else
    l_customer_id := null;
  end if;

  -- dbms_output.put_line('l_customer_id := ' || l_customer_id);

  if p_customer_site_id is not null then
   BEGIN
    select cs.company_site_id
    into   l_customer_site_id
    from   msc_trading_partner_maps m,
           msc_company_sites cs
    where  m.tp_key = p_customer_site_id and
           m.map_type = 3 and
           cs.company_site_id = m.company_key;
   EXCEPTION
     WHEN OTHERS THEN
       l_customer_site_id := null;
   END;
  else
    l_customer_site_id := null;
  end if;

  -- dbms_output.put_line('l_customer_site_id := ' || l_customer_site_id);

  if p_org_id is not null and p_sr_instance_id is not null then
   BEGIN
      select distinct cs.company_site_id
      into  l_supplier_site_id
      from  msc_company_sites cs,
            msc_trading_partner_maps m,
            msc_trading_partners t
      where t.sr_tp_id = p_org_id and
            t.sr_instance_id = p_sr_instance_id and
            t.partner_type = 3 and
            m.tp_key = t.partner_id and
            m.map_type = 2 and
            cs.company_site_id = m.company_key and
            cs.company_id = 1;
   EXCEPTION
     WHEN OTHERS THEN
       l_supplier_site_id := NULL;
   END;
  else
    l_supplier_site_id := null;
  end if;

  -- dbms_output.put_line('l_supplier_site_id := ' || l_supplier_site_id);


  delete from msc_sup_dem_entries sd
  where sd.publisher_order_type = 1 and
        sd.plan_id = -1 and
        sd.publisher_id = 1 and
        sd.publisher_site_id = nvl(l_supplier_site_id, sd.publisher_site_id) and
        sd.customer_id = nvl(l_customer_id, sd.customer_id) and
        sd.customer_site_id = nvl(l_customer_site_id, sd.customer_site_id) and
        sd.inventory_item_id = nvl(p_item_id, sd.inventory_item_id) and
        NVL(sd.planner_code,'-99') = nvl(p_planner_code, NVL(sd.planner_code, '-99')) and
        sd.ship_date between nvl(l_horizon_start, sysdate) and nvl(p_horizon_end, sysdate+365);

END delete_old_forecast;

END MSD_SCE_PUBLISH_FORECAST_PKG;

/
