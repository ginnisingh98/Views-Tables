--------------------------------------------------------
--  DDL for Package Body MSD_SCE_RECEIVE_FORECAST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_SCE_RECEIVE_FORECAST_PKG" AS
/* $Header: msdxrcfb.pls 120.2.12010000.1 2008/05/15 08:48:14 vrepaka ship $ */

/** Bug 2488293 **/
Procedure delete_from_headers(
p_cs_definition_id        in number,
p_designator              in varchar2);

Procedure Insert_Data_Into_Headers(
p_cs_definition_id        in number,
p_designator              in varchar2,
p_refresh_num             in number);

/** End Bug 2488293 **/

PROCEDURE receive_customer_forecast(
  p_errbuf                  out NOCOPY varchar2,
  p_retcode                 out NOCOPY varchar2,
  p_designator              in varchar2,
  p_order_type              in number,
  p_org_code                in varchar2,
  p_planner_code            in varchar2,
  p_item_id                 in number,
  p_customer_id             in number,
  p_customer_site_id        in number default null,    -- Bug # 4710963
  p_horizon_start           in varchar2,
  p_horizon_days            in number
) IS


l_horizon_start             Date;           --canonical date
l_horizon_end               Date;
p_cs_definition_id          Number;
p_org_id                    Number;
p_sr_instance_id            Number;
p_name                      Varchar2(30);


l_new_refresh_num           NUMBER;


cursor get_cs_defn_id_c1(p_name IN Varchar2) IS
  select cs_definition_id
  from msd_cs_definitions
  where name = p_name;

BEGIN

  p_name := null;
  p_cs_definition_id := null;

  if p_horizon_start is null then

     select decode(p_order_type, 4, sysdate-365, sysdate)
     into l_horizon_start
     from dual;

  else

     l_horizon_start := fnd_date.canonical_to_date(p_horizon_start);

  end if;

  l_horizon_end := l_horizon_start + nvl(p_horizon_days, 365);

   -- dbms_output.put_line('l_horizon_start := ' || l_horizon_start);
   -- dbms_output.put_line('l_horizon_end := ' || l_horizon_end);

  /* Receive the net chanage sequence number */
  SELECT msd.msd_last_refresh_number_s.nextval into l_new_refresh_Num from dual;

  if p_org_code is not null then

    select sr_tp_id, sr_instance_id
    into   p_org_id, p_sr_instance_id
    from   msc_trading_partners
    where  organization_code = p_org_code and
           partner_type = 3 and
           company_id is null;
    --dbms_output.put_line('p_org_id := ' || p_org_id);
    --dbms_output.put_line('p_sr_instance_id := ' || p_sr_instance_id);
  else
    p_org_id := null;
    p_sr_instance_id := null;
  end if;

  If p_order_type = 1 then
        p_name := 'MSD_CUSTOMER_SALES_FORECAST';
  elsif p_order_type = 2 then
        p_name := 'MSD_CUSTOMER_ORDER_FORECAST';
  elsif p_order_type = 4 then
        p_name := 'MSD_CUSTOMER_HISTORICAL_SALES';
  end if;

  open get_cs_defn_id_c1(p_name);
  fetch get_cs_defn_id_c1 into p_cs_definition_id;
  close get_cs_defn_id_c1;

  if p_cs_definition_id is not null then

        delete_old_forecast(
         p_sr_instance_id
        ,p_cs_definition_id
        ,p_designator
        ,p_org_id
        ,p_item_id              -- Bug 4710963
        ,p_customer_id          -- Bug 4710963
        ,p_customer_site_id     -- Bug 4710963
        ,l_horizon_start
        ,l_horizon_end,
         l_new_refresh_Num
        );

    insert into msd_cs_data (
        cs_data_id,
        cs_definition_id,
        cs_name,
        attribute_1,
        attribute_2,
        attribute_3,
        attribute_4,
        attribute_5,
        attribute_6,
        attribute_7,
        attribute_8,
        attribute_9,
        attribute_10,
        attribute_11,
        attribute_12,
        attribute_13,
        attribute_34,
        attribute_41,
        attribute_43,
        attribute_45,
        attribute_50,       -- Bug 4710963
        attribute_51,       -- Bug 4710963
        attribute_52,       -- Bug 4710963
        attribute_53,       -- Bug 4710963
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        action_code,
        last_refresh_num,
        created_by_refresh_num
        )
	( SELECT
                msd_cs_data_s.nextval,
        	p_cs_definition_id,
        	p_designator,
                t1.sr_instance_id,           -- Bug 5729146
        	1,
        	lv4.sr_level_pk,
        	lv4.level_value,
        	lv4.level_pk,
        	11,
        	lv2.sr_level_pk,
        	lv2.level_value,
        	lv2.level_pk,
        	7,
        	lv3.sr_level_pk,
       	 	lv3.level_value,
        	lv3.level_pk,
        	9,                           -- bucket type 'Day'
        	MSD_COMMON_UTILITIES.msd_uom_convert(ilp.sr_item_pk, null, sd.tp_uom_code, ilp.base_uom) * sd.tp_quantity,
                to_char(decode(p_order_type, 4, sd.new_schedule_date, nvl(sd.ship_date, decode(nvl(ps.shipping_control, 'BUYER'), 'BUYER', sd.key_date, sd.key_date - get_intrasit_lead_time(t1.sr_instance_id, t1.sr_tp_id, s.location_id)))), 'YYYY/MM/DD'),
                to_char(decode(p_order_type, 4, to_date(null), nvl(sd.receipt_date, decode(nvl(ps.shipping_control, 'BUYER'), 'SUPPLIER', sd.key_date, sd.key_date + get_intrasit_lead_time(t1.sr_instance_id, t1.sr_tp_id, s.location_id)))), 'YYYY/MM/DD'),
                34,                          -- Bug 4710963
        	lv5.sr_level_pk,             -- Bug 4710963
        	lv5.level_value,             -- Bug 4710963
        	lv5.level_pk,                -- Bug 4710963
        	fnd_global.user_id,
        	sysdate,
        	fnd_global.user_id,
        	sysdate,
        	fnd_global.login_id,
                'I',
                l_new_refresh_Num,
                l_new_refresh_Num
	FROM    msc_sup_dem_entries sd,
       	 	msd_level_values lv2,
        	msd_level_values lv3,
        	msd_level_values lv4,
        	msd_level_values lv5,          -- Bug 4710963
        	msc_trading_partner_maps m2,
        	msc_trading_partners t1,
        	msc_item_id_lid item,
        	msc_tp_site_id_lid s,
        	msc_trading_partner_sites ps,
                msd_item_list_price ilp
WHERE   ilp.sr_item_pk(+) = lv4.sr_level_pk and
        ilp.instance(+) = lv4.instance and
        sd.inventory_item_id = item.inventory_item_id and
        item.sr_instance_id = t1.sr_instance_id and
        lv4.instance = t1.sr_instance_id and
        lv4.sr_level_pk = to_char(item.sr_inventory_item_id) and
        lv4.level_id = 1 and
--    Mapping for Customer Site
        lv2.instance = t1.sr_instance_id and
        lv2.sr_level_pk = to_char(s.sr_tp_site_id) and
        lv2.level_id = 11 and
        s.sr_tp_site_id = get_sr_tp_site_id(sd.customer_site_id, t1.sr_instance_id) and
        s.sr_instance_id = t1.sr_instance_id and
        s.partner_type = 2 and
        nvl(s.sr_company_id, -1) = -1 and
        --s.tp_site_id = sd.customer_site_id and
        ps.partner_site_id = s.tp_site_id and
--    Mapping for Demand Class                               -- Bug 4710963
        lv5.instance =  t1.sr_instance_id and
        lv5.sr_level_pk = nvl(sd.demand_class,'-777')  and   -- Bug 4710963
        lv5.level_id = 34 and                                -- Bug 4710963
--    Mapping for Supplier Org
        lv3.instance = t1.sr_instance_id and
        lv3.sr_level_pk = to_char(t1.sr_tp_id) and
        lv3.level_id = 7 and
        m2.company_key = sd.supplier_site_id and
        m2.map_type = 2 and
        t1.partner_id = m2.tp_key and
        t1.partner_type = 3 and
        ps.partner_id = NVL(p_customer_id, ps.partner_id) and
        s.tp_site_id = NVL(p_customer_site_id, s.tp_site_id) and
        t1.sr_tp_id = NVL(p_org_id, t1.sr_tp_id) and
        item.sr_instance_id = NVL(p_sr_instance_id, item.sr_instance_id) and
        item.inventory_item_id = nvl(p_item_id, item.inventory_item_id) and
        NVL(sd.planner_code,'-99') = NVL(p_planner_code, NVL(sd.planner_code,'-99')) and
        sd.publisher_order_type = p_order_type and
        sd.plan_id = -1 and
        sd.supplier_id = 1 and
        decode(p_order_type, 4, sd.new_schedule_date, sd.key_date) between l_horizon_start and l_horizon_end);

    if (sql%rowcount = 0) then

       p_errbuf := 'There were no rows fetched.';
       p_retcode := 1;

    else

    /* Bug 2488293. Insert data into headers table. */
       insert_data_into_Headers(p_cs_definition_id,p_designator,l_new_refresh_num);
    /* End Bug 2488293 */

    end if;

    commit;

  else
         p_retcode :=-1;
         p_errbuf := 'Error while getting p_cs_definition_id';

  end if;

        exception

          when others then

                p_errbuf := substr(SQLERRM,1,150);
                p_retcode := -1;
                rollback;

END receive_customer_forecast;


PROCEDURE delete_old_forecast(
  p_sr_instance_id          in number,
  p_cs_definition_id        in number,
  p_designator              in varchar2,
  p_org_id                  in number,
  p_item_id                 in number, -- Bug 4710963
  p_customer_id             in number, -- Bug 4710963
  p_customer_site_id        in number, -- Bug 4710963
  l_horizon_start           in date,
  l_horizon_end             in date,
  p_new_fresh_num           in number
) IS


errbuf       VARCHAR2(150);
retcode      VARCHAR2(150);

p_sr_item_pk number;    -- Bug 4710963
p_sr_ship_to_loc_pk number;    -- Bug 4710963

-- Bug 4710963
cursor c_sr_item_pk is
select sr_inventory_item_id
from msc_system_items
where plan_id = -1
and sr_instance_id = nvl(p_sr_instance_id,sr_instance_id)
and inventory_item_id = p_item_id
and organization_id = nvl(p_org_id,organization_id)
and rownum < 2;


cursor c_sr_ship_to_loc_pk is
select sr_tp_site_id
from msc_trading_partners tp, msc_trading_partner_sites tps
where tp.partner_id = p_customer_id
and tps.partner_site_id = p_customer_site_id
and tps.partner_id = tp.partner_id
and tps.partner_type = 2;


BEGIN
     /*
   	delete from msd_cs_data
   	where cs_name = p_designator
   	and cs_definition_id = p_cs_definition_id
   	and attribute_11 = nvl(to_char(p_org_id), attribute_11)
   	and attribute_1 = nvl(to_char(p_sr_instance_id), attribute_1)
        and attribute_43 between to_char(l_horizon_start, 'YYYY/MM/DD') and to_char(l_horizon_end, 'YYYY/MM/DD');
     */

     /* Enable Net-Change.  Instead of physically deleteing the forecast,
        update it with action_code = D */

         if p_item_id is not null then
     open c_sr_item_pk;
       fetch c_sr_item_pk INTO p_sr_item_pk;
     close c_sr_item_pk;
    else
       p_sr_item_pk := to_number(NULL);
    end if;

    if p_customer_site_id is not null then
      open c_sr_ship_to_loc_pk;
       fetch c_sr_ship_to_loc_pk INTO p_sr_ship_to_loc_pk;
     close c_sr_ship_to_loc_pk;
    else
       p_sr_ship_to_loc_pk :=to_number(NULL);
    end if;


     update msd_cs_data
     set action_code = 'D'
     where  cs_name = p_designator
   	and cs_definition_id = p_cs_definition_id
   	and attribute_11 =  nvl(to_char(p_org_id), attribute_11)
        and attribute_7 =   nvl(to_char(p_sr_ship_to_loc_pk), attribute_7)
   	and attribute_3 =   nvl(to_char(p_sr_item_pk), attribute_3)
   	and attribute_1 = nvl(to_char(p_sr_instance_id), attribute_1)
        and attribute_43 between to_char(l_horizon_start, 'YYYY/MM/DD')
                                 and to_char(l_horizon_end, 'YYYY/MM/DD');

     /* Delete rows that are not used by any demand plans */
     MSD_TRANSLATE_FACT_DATA.clean_fact_data( errbuf,
                                              retcode,
                                             'MSD_CS_DATA');


    /* Bug 2488293. Delets data from headers table. */
       delete_from_headers(p_cs_definition_id,p_designator);
    /* End Bug 2488293 */



END delete_old_forecast;

FUNCTION get_intrasit_lead_time(
                       p_from_instance_id in number,
                       p_from_organization_id in number,
                       p_to_location_id in number
                      ) return number is

cursor c2 is
    select intransit_time
    from msc_orgcustomer_ship_methods_v
    where from_sr_instance_id(+) = p_from_instance_id and
          from_organization_id(+) = p_from_organization_id and
          to_location_id (+) = p_to_location_id and
          default_flag(+) = 1;

    l_ret   number := null;

Begin

    open c2;
    fetch c2 into l_ret;
    close c2;
    return nvl(l_ret, 0);

End get_intrasit_lead_time;



FUNCTION get_sr_tp_site_id(
                             p_customer_site_id in number,
                             p_sr_instance_id in number
                           ) return number is

cursor c1 is
    select slid.sr_tp_site_id
    from
        msc_tp_site_id_lid slid,
        msc_trading_partner_maps map,
        msc_trading_partner_sites site,
        msd_level_values lvl
    where
        map.company_key = p_customer_site_id  and
        map.map_type = 3 and
        slid.tp_site_id = map.tp_key and
        slid.sr_instance_id = p_sr_instance_id and
        slid.partner_type = 2 and
        nvl(slid.sr_company_id, -1) = -1 and
        site.partner_site_id = slid.tp_site_id and
        site.tp_site_code = 'SHIP_TO' and
        lvl.instance = p_sr_instance_id and
        lvl.sr_level_pk = to_char(slid.sr_tp_site_id) and
        lvl.level_id = 11;

    l_ret   number := null;
Begin

    open c1;
    fetch c1 into l_ret;
    close c1;
    return l_ret;

End get_sr_tp_site_id;


/* This procedure will delete the data from the msd_cs_data_headers
 * table.
 *
 * Bug 2488293.
 */

Procedure delete_from_headers
 (p_cs_definition_id        in number,
  p_designator              in varchar2) IS

BEGIN

  DELETE from msd_cs_data_headers mcdh
  where
  cs_definition_id = p_cs_definition_id
  and cs_name =   p_designator
  and not exists
  (select 1
   from msd_cs_data mcd
   where mcd.cs_definition_id = mcdh.cs_definition_id
   and mcd.cs_name = mcdh.cs_name
   and mcd.attribute_1 = mcdh.instance
   and mcd.action_code = 'I'
   and rownum = 1);

Exception
  When others then
    fnd_file.put_line(fnd_file.log, 'Error in deleting from MSD_CS_DATA_HEADERS');
    fnd_file.put_line(fnd_file.log, sqlerrm);
    raise;

End delete_from_headers;


/* This procedure will insert cs_definition_id, cs_name, and instance into
 * msd_cs_data_headers table.
 * Bug 2488293.
 */
Procedure Insert_Data_Into_Headers
 (p_cs_definition_id        in number,
  p_designator              in varchar2,
  p_refresh_num             in number) IS

BEGIN

insert into msd_cs_data_headers
(
 cs_data_header_id,
 instance,
 cs_definition_id,
 cs_name,
 last_update_date,
 last_updated_by,
 creation_date,
 created_by,
 last_update_login,
 last_refresh_num
)
select  msd_cs_data_headers_s.nextval,
	mcd.instance,
	mcd.cs_definition_id,
	mcd.cs_name,
 	sysdate,
 	fnd_global.user_id,
	sysdate,
 	fnd_global.user_id,
 	fnd_global.login_id,
	p_refresh_num
from
(
select distinct attribute_1 instance, cs_definition_id, cs_name
from msd_cs_data
where cs_definition_id = p_cs_definition_id
and cs_name = p_designator
minus
select instance, cs_definition_id, cs_name
from msd_cs_data_headers
) mcd;

if (sql%rowcount = 0) then

    update msd_cs_data_headers
    set last_refresh_num = p_refresh_num,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
    where cs_definition_id = p_cs_definition_id
    and cs_name = p_designator;

end if;

Exception
  When others then
    fnd_file.put_line(fnd_file.log, 'Error in inserting into MSD_CS_DATA_HEADERS');
    fnd_file.put_line(fnd_file.log, sqlerrm);
    raise;

END Insert_Data_Into_Headers;




END MSD_SCE_RECEIVE_FORECAST_PKG;

/
