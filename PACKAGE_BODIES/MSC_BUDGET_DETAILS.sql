--------------------------------------------------------
--  DDL for Package Body MSC_BUDGET_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_BUDGET_DETAILS" AS
/* $Header: MSCBDDTB.pls 115.7 2004/05/07 18:47:07 rvrao noship $  */
PROCEDURE populate_budget_details(
                     p_plan_id     IN number,
                     p_date        IN date,
                     p_item        in number,
                     p_query_id    in number,
                     p_organization_id in number,
                     p_sr_instance_id in number,
                     p_budget_value in number,
                     p_tot_inv      in number,
                     p_violation_level in number, -- 1 plan, 2 org, 3 cat
                     p_category_name    in varchar2 default null) is


cursor get_mbid_date_c(p_bucket_type number)is  -- get the date to use in msc_bis_inv_details
select max(detail_date)
from msc_bis_inv_detail
where detail_date <= p_date
and   plan_id = p_plan_id
and   nvl(period_type, -1)  = 1
and   organization_id = p_organization_id
and   sr_instance_id  = p_sr_instance_id
and   nvl(detail_level,3) = nvl(p_bucket_type, 3);

cursor get_bucket_dates is
select bkt_start_date, bkt_end_date, decode(bucket_type,2,1,3,3)
from msc_plan_buckets
where plan_id = p_plan_id
and   p_date between bkt_start_date and bkt_end_date;

cursor bis_inv_details_plan_c(l_tot_inv number,  -- get the values from mbid
                         l_date         date,
                         l_bucket_type  number) is
select bid.inventory_item_id,
       bid.inventory_value,
       bid.inventory_value/l_tot_inv
from  msc_bis_inv_detail bid ,
      msc_system_items   item
where nvl(bid.period_type,-1)=1
and   bid.detail_date = l_date
and   bid.plan_id = p_plan_id
and   nvl(bid.detail_level,3) = nvl(l_bucket_type,3)
and   bid.plan_id = item.plan_id
and   bid.sr_instance_id = item.sr_instance_id
and   bid.organization_id = item.organization_id
and   bid.inventory_item_id = item.inventory_item_id
and   item.budget_constrained =1;

cursor bis_inv_details_org_c(l_tot_inv number,
                             l_date    date,
                             l_bucket_type number,
                             l_organization_id number,
                             l_sr_instance_id number) is
select bid.inventory_item_id,
       bid.inventory_value,
       bid.inventory_value/l_tot_inv
from  msc_bis_inv_detail bid,
      msc_system_items item
where nvl(bid.period_type,-1)=1
and   bid.detail_date = l_date
and   bid.plan_id = p_plan_id
and   bid.organization_id=l_organization_id
and   bid.sr_instance_id =l_sr_instance_id
and   nvl(bid.detail_level,3) = nvl(l_bucket_type,3)
and   bid.plan_id = item.plan_id
and   bid.sr_instance_id = item.sr_instance_id
and   bid.organization_id = item.organization_id
and   bid.inventory_item_id = item.inventory_item_id
and   item.budget_constrained =1;


cursor bis_inv_details_cat_c(l_tot_inv number,
                             l_date    date,
                             l_bucket_type number,
                             l_cat_name varchar2) is
select bid.inventory_item_id,
       bid.inventory_value,
       bid.inventory_value/l_tot_inv
from  msc_bis_inv_detail bid,
      msc_item_categories mic,
      msc_system_items item
where nvl(bid.period_type,-1)=1
and   bid.detail_date = l_date
and   bid.plan_id = p_plan_id
and   nvl(bid.detail_level,3) = nvl(l_bucket_type,3)
and   mic.inventory_item_id= bid.inventory_item_id
and   mic.sr_instance_id = bid.sr_instance_id
and   mic.organization_id= bid.organization_id
and   mic.category_name = l_cat_name
and   bid.plan_id = item.plan_id
and   bid.sr_instance_id = item.sr_instance_id
and   bid.organization_id = item.organization_id
and   bid.inventory_item_id = item.inventory_item_id
and   item.budget_constrained =1;

cursor ss_date_c(l_inventory_item_id1 number,  -- get the date to use in msc_safety_stocks
                 l_organization_id1 number,
                 l_sr_instance_id1 number,
                 l_plan_id1 number,
                 l_detail_date1 date) is
select max(period_start_date)
from msc_safety_stocks
where period_start_date <= l_detail_date1
and   inventory_item_id  = l_inventory_item_id1
and   organization_id    = l_organization_id1
and   sr_instance_id     = l_sr_instance_id1
and   plan_id            = l_plan_id1;


cursor safety_stocks_c (l_inventory_item_id number,  -- get the values from msc_safety_stocks
                        l_organization_id number,
                        l_sr_instance_id number,
                        l_plan_id number,
                        l_period_start_date date) is
select target_safety_stock, safety_stock_quantity
from msc_safety_stocks
where inventory_item_id = l_inventory_item_id
and   organization_id= l_organization_id
and   sr_instance_id = l_sr_instance_id
and   plan_id = l_plan_id
and   period_start_date = l_period_start_date;


l_inv_item number;
l_achieved_sl number;
l_target_sl number;
l_target_ss number;
l_achieved_ss number;
l_ss_date date;
L_PERCENT_INV_VALUE number;
l_inv_value number;

l_detail_date date;
l_start_date date;
l_end_date date;
l_item_name varchar2(10);

l_bucket_type number; -- bucket type  plan_buckets   bis_inv_detail
                      --  week            2             1
                      --  period          3             null

plan_level number := 1;
org_level number  := 2;

begin

delete msc_form_query;

open get_bucket_dates;
fetch get_bucket_dates into l_start_date , l_end_date, l_bucket_type;
close get_bucket_dates;

open  get_mbid_date_c(l_bucket_type);
fetch get_mbid_date_c into l_detail_date;
close get_mbid_date_c;


dbms_output.put_line('date is ' || l_detail_date);
if p_violation_level = plan_level then
dbms_output.put_line('level is ' || p_violation_level || ' plan_level ');
open bis_inv_details_plan_c(p_tot_inv,
                       l_detail_date,
                       l_bucket_type);
elsif p_violation_level =  org_level  then
open bis_inv_details_org_c(p_tot_inv,
                       l_detail_date,
                       l_bucket_type,
                       p_organization_id,
                       p_sr_instance_id );

else
open bis_inv_details_cat_c(p_tot_inv,
                       l_detail_date,
                       l_bucket_type,
                       p_category_name);

end if;

loop
if p_violation_level = plan_level then
fetch bis_inv_details_plan_c into
      l_inv_item,
      l_inv_value,
      l_percent_inv_value;
      exit when bis_inv_details_plan_c%notfound;
elsif p_violation_level = org_level then
fetch bis_inv_details_org_c into
      l_inv_item,
      l_inv_value,
      l_percent_inv_value;
      exit when bis_inv_details_org_c%notfound;
else -- cat_level
fetch bis_inv_details_cat_c into
      l_inv_item,
      l_inv_value,
      l_percent_inv_value;
      exit when bis_inv_details_cat_c%notfound;
end if;
dbms_output.put_line('item is ' || l_inv_item ||
                     ' inv val ' || l_inv_value ||
                     ' percetn inv valu '  || l_percent_inv_value);
      -- get item name
      l_item_name := substr(msc_get_name.item_name(l_inv_item, null, null, null),1,10);
      -- get achieved service level
      l_achieved_sl :=  Msc_Get_Bis_Values.get_service_level(p_plan_id,
                     p_sr_instance_id,
                     p_organization_id,
                     l_inv_item,
                     l_start_date,
                     l_end_date);

      -- get target service level
      l_target_sl   := Msc_Get_Bis_Values.service_target(p_plan_id ,
                     p_sr_instance_id ,
                     p_organization_id ,
                     l_inv_item);

      open ss_date_c(l_inv_item,
                        p_organization_id,
                        p_sr_instance_id,
                        p_plan_id,
                        p_date);
      fetch ss_date_c into l_ss_date;
      close ss_date_c;
      -- get achieved and target safety stocks
      open safety_stocks_c(l_inv_item,
                        p_organization_id,
                        p_sr_instance_id,
                        p_plan_id,
                        l_ss_date);
      fetch safety_stocks_c into l_target_ss, l_achieved_ss;
      close safety_stocks_c;


      insert into msc_form_query
      (query_id,
       number1,  --item
       number2,  --budget value
       number3,  --inv value
       number4,  --%total value
       number5,  --target sl
       number6,  --achieved sl
       number7,  --target ss
       number8,  --achieved ss
       number9,  -- org
       number10,  -- inst
       date1 ,   --detail_date
       char1,    --item_name
       char2,    -- bucket type
       last_update_date,
       last_updated_by,
       creation_date,
       created_by)
       values
       (p_query_id,
        l_inv_item,
        p_budget_value,
        round(l_inv_value,0),
        round(l_percent_inv_value * 100,2),
        l_target_sl,
        l_achieved_sl,
        l_target_ss,
        l_achieved_ss,
        p_organization_id,
        p_sr_instance_id,
        l_detail_date,
        l_item_name,
        decode(l_bucket_type,1,'Week','Period'),
        sysdate,
        -1,
        sysdate,
        -1);

end loop;
if p_violation_level = plan_level then
close bis_inv_details_plan_c;
elsif p_violation_level = org_level then
close bis_inv_details_org_c;
else
close bis_inv_details_cat_c;
end if;
exception
    when no_data_found
      then null;
    when others then
      raise_application_error(-20000,sqlerrm);
END populate_budget_details;
end msc_budget_details;

/
