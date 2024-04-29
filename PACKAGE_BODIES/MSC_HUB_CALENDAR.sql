--------------------------------------------------------
--  DDL for Package Body MSC_HUB_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_HUB_CALENDAR" as
/* $Header: MSCHBCAB.pls 120.9.12010000.2 2010/03/03 23:47:27 wexia ship $ */

function first_work_date(p_calendar_code in varchar2,
             p_sr_instance_id in number,
             p_bkt_type in number,
             p_bkt_start_date date) return date is
x_date date;
l_seq_num number;
begin
   if (p_bkt_type =1 ) then
    -- this is the day bucket
    -- check whether this day is the working date
    select mcd.calendar_date into x_date
    from msc_calendar_dates mcd,msc_calendars mc
    where mc.calendar_code = p_calendar_code
    and mc.sr_instance_id = p_sr_instance_id
    and mc.calendar_code=mcd.calendar_code
    and mc.sr_instance_id=mcd.sr_instance_id
 --   and mc.exception_set_id = mcd.exception_set_id
    and mcd.calendar_date = p_bkt_start_date
    and mcd.seq_num is not null;

    return x_date;

  elsif (p_bkt_type = 2) then

     select min(mcd.calendar_date) into x_date
     from msc_calendar_dates mcd, msc_calendars mc,msc_cal_week_start_dates mcwsd
     where mc.calendar_code = p_calendar_code
     and mc.sr_instance_id = p_sr_instance_id
     and   mc.calendar_code =  mcd.calendar_code
     and   mc.sr_instance_id = mcd.sr_instance_id
     -- and   mc.exception_set_id = mcd.exception_set_id
     and   mcd.seq_num is not null
     and   mcd.calendar_code = mcwsd.calendar_code
     and   mcd.sr_instance_id = mcwsd.sr_instance_id
     and   mcd.exception_set_id =mcwsd.exception_set_id
     and   mcwsd.WEEK_START_DATE = p_bkt_start_date
     and   mcd.calendar_date >=mcwsd.WEEK_START_DATE
     and   mcd.calendar_date<mcwsd.next_date;

     return x_date;
  elsif (p_bkt_type=3) then

     select min(mcd.calendar_date) into x_date
     from msc_calendar_dates mcd, msc_calendars mc,msc_period_start_dates mpsd
     where mc.calendar_code = p_calendar_code
     and   mc.sr_instance_id = p_sr_instance_id
     and   mc.calendar_code =  mcd.calendar_code
     and   mc.sr_instance_id = mcd.sr_instance_id
     -- and   mc.exception_set_id = mcd.exception_set_id
     and   mcd.seq_num is not null
     and   mcd.calendar_code = mpsd.calendar_code
     and   mcd.sr_instance_id = mpsd.sr_instance_id
     and   mcd.exception_set_id =mpsd.exception_set_id
     and   mpsd.PERIOD_START_DATE = p_bkt_start_date
     and   mcd.calendar_date >=mpsd.PERIOD_START_DATE
     and   mcd.calendar_date<mpsd.next_date;

     return x_date;
 end if;
exception

   when no_data_found then
      return null;
end first_work_date;




-- last_work_date 1
function last_work_date(p_plan_id in number,
            p_sr_instance_id in number,
            p_bkt_type in number,
            p_bkt_start_date in date,
            p_bkt_end_date in date) return date is


x_date date;
l_seq_num number;
l_calendar_code varchar2(20);
l_plan_type number;
begin

    select plan_type into l_plan_type
    from msc_plans where plan_id=p_plan_id;

    if (l_plan_type = 6) then -- SNO
        return trunc(p_bkt_end_date);
    end if;

   -- here, we follow the same logic used in mbp
   -- first check whether profile MSC_BKT_REFERENCE_CALENDAR is set
   -- if it set, l_calendar_code = MSC_BKT_REFERENCE_CALENDAR
   -- otherwise, l_calendar_code = owning org's calendar


   l_calendar_code := fnd_profile.value('MSC_BKT_REFERENCE_CALENDAR');
   if (l_calendar_code is null) then
      select mtp.calendar_code into l_calendar_code
      from msc_trading_partners mtp,       msc_plans mp
      where mtp.sr_tp_id = mp.organization_id
      and mtp.sr_instance_id = mp.sr_instance_id
      and mp.plan_id =p_plan_id and mtp.PARTNER_TYPE =3;

   end if;


--  dbms_output.put_line('calendar_code=' || l_calendar_code);

 if (p_bkt_type =1 ) then
    -- this is the day bucket
    -- check whether this day is the working date
    --- for daily bucket, it is the work day
    --- engine sometime put s/d on day bucket even if
    --- it is not working day
    select mcd.calendar_date into x_date
    from msc_calendar_dates mcd,msc_calendars mc
    where mc.calendar_code = l_calendar_code
    and mc.sr_instance_id = p_sr_instance_id
    and mc.calendar_code=mcd.calendar_code
    and mc.sr_instance_id=mcd.sr_instance_id

    and mcd.calendar_date = p_bkt_start_date
    and mcd.seq_num is not null;

    return p_bkt_start_date;

  elsif (p_bkt_type = 2) then

     select max(mcd.calendar_date) into x_date
     from msc_calendar_dates mcd, msc_calendars mc,msc_cal_week_start_dates mcwsd
     where mc.calendar_code = l_calendar_code
     and mc.sr_instance_id = p_sr_instance_id
     and   mc.calendar_code =  mcd.calendar_code
     and   mc.sr_instance_id = mcd.sr_instance_id

     and   mcd.seq_num is not null
     and   mcd.calendar_code = mcwsd.calendar_code
     and   mcd.sr_instance_id = mcwsd.sr_instance_id
     and   mcd.exception_set_id =mcwsd.exception_set_id
     and   mcwsd.WEEK_START_DATE >= p_bkt_start_date
     and   mcwsd.WEEK_START_DATE <= p_bkt_end_date
     and   mcd.calendar_date >=mcwsd.WEEK_START_DATE
     and   mcd.calendar_date<mcwsd.next_date;

     return x_date;
  elsif (p_bkt_type=3) then

     select max(mcd.calendar_date) into x_date
     from msc_calendar_dates mcd, msc_calendars mc,msc_period_start_dates mpsd
     where mc.calendar_code = l_calendar_code
     and   mc.sr_instance_id = p_sr_instance_id
     and   mc.calendar_code =  mcd.calendar_code
     and   mc.sr_instance_id = mcd.sr_instance_id

     and   mcd.seq_num is not null
     and   mcd.calendar_code = mpsd.calendar_code
     and   mcd.sr_instance_id = mpsd.sr_instance_id
     and   mcd.exception_set_id =mpsd.exception_set_id
     and   mpsd.PERIOD_START_DATE >= p_bkt_start_date
     and   mpsd.PERIOD_START_DATE <= p_bkt_end_date
     and   mcd.calendar_date >=mpsd.PERIOD_START_DATE
     and   mcd.calendar_date<mpsd.next_date;

     return x_date;
  end if;
exception

   when no_data_found then
    -- dbms_output.put_line('no data:calendar_code=' || l_calendar_code);
     if (p_bkt_type =1) then return p_bkt_start_date;
     else return null;
     end if;
end last_work_date;


-- last_work_date 2
function last_work_date(p_calendar_code in varchar2,
             p_sr_instance_id in number,
             p_bkt_type in number,
             p_bkt_start_date date) return date is
x_date date;
l_seq_num number;
begin
   if (p_bkt_type =1 ) then
    -- this is the day bucket
    -- check whether this day is the working date
    select mcd.calendar_date into x_date
    from msc_calendar_dates mcd,msc_calendars mc
    where mc.calendar_code = p_calendar_code
    and mc.sr_instance_id = p_sr_instance_id
    and mc.calendar_code=mcd.calendar_code
    and mc.sr_instance_id=mcd.sr_instance_id

    and mcd.calendar_date = p_bkt_start_date
    and mcd.seq_num is not null;

    return x_date;

  elsif (p_bkt_type = 2) then

     select max(mcd.calendar_date) into x_date
     from msc_calendar_dates mcd, msc_calendars mc,msc_cal_week_start_dates mcwsd
     where mc.calendar_code = p_calendar_code
     and mc.sr_instance_id = p_sr_instance_id
     and   mc.calendar_code =  mcd.calendar_code
     and   mc.sr_instance_id = mcd.sr_instance_id

     and   mcd.seq_num is not null
     and   mcd.calendar_code = mcwsd.calendar_code
     and   mcd.sr_instance_id = mcwsd.sr_instance_id
     and   mcd.exception_set_id =mcwsd.exception_set_id
     and   mcwsd.WEEK_START_DATE = p_bkt_start_date
     and   mcd.calendar_date >=mcwsd.WEEK_START_DATE
     and   mcd.calendar_date<mcwsd.next_date;

     return x_date;
  elsif (p_bkt_type=3) then

     select max(mcd.calendar_date) into x_date
     from msc_calendar_dates mcd, msc_calendars mc,msc_period_start_dates mpsd
     where mc.calendar_code = p_calendar_code
     and   mc.sr_instance_id = p_sr_instance_id
     and   mc.calendar_code =  mcd.calendar_code
     and   mc.sr_instance_id = mcd.sr_instance_id

     and   mcd.seq_num is not null
     and   mcd.calendar_code = mpsd.calendar_code
     and   mcd.sr_instance_id = mpsd.sr_instance_id
     and   mcd.exception_set_id =mpsd.exception_set_id
     and   mpsd.PERIOD_START_DATE = p_bkt_start_date
     and   mcd.calendar_date >=mpsd.PERIOD_START_DATE
     and   mcd.calendar_date<mpsd.next_date;

     return x_date;
  end if;
exception

   when no_data_found then
      return null;
end last_work_date;


-----------------------------------------------------------------
--- this function is called in msc_demand_pkg and msc_supply_pkg
--- to put the supply/demands in them last working day of the first
--- bucket
------------------------------------------------------------------

-- last_work_date 3
function last_work_date(p_plan_id in number,
             p_date in date ) return date is
x_date date;
l_seq_num number;
l_bkt_start_date date;
l_bkt_end_date date;
l_bkt_type number;
l_sr_instance_id number;
begin

select bkt_start_date,bkt_end_date,bucket_type
into l_bkt_start_date,l_bkt_end_date,l_bkt_type
from msc_plan_buckets
where plan_id = p_plan_id
and p_date between bkt_start_date and bkt_end_date;


select sr_instance_id into l_sr_instance_id
from msc_plans where plan_id=p_plan_id;


return msc_hub_calendar.last_work_date(p_plan_id,l_sr_instance_id,
                l_bkt_type,l_bkt_start_date,
               l_bkt_end_date);
exception

   when no_data_found then  -- if the date is not in any bucket, return the plan start date
   select curr_start_date into x_date
   from msc_plans where plan_id = p_plan_id;

   return x_date;
end last_work_date;


function ss_date(p_plan_id  in number,p_bkt_start_date in date,p_bkt_end_date in date) return date is
x_date date;


begin
     select max(period_start_date) into x_date
     from msc_safety_Stocks
     where period_start_date <=p_bkt_end_date
     and plan_id=p_plan_id;

     if (x_date is null) then
       x_date :=p_bkt_start_date;
     end if;

     return x_date;




end ss_date;


function working_day_bkt_start_date(p_plan_id in number,
            p_sr_instance_id in number,
            p_bkt_type in number,
            p_bkt_start_date in date,
            p_bkt_end_date in date) return date is


x_date date;
l_seq_num number;
l_calendar_code varchar2(20);

begin
   -- here, we follow the same logic used in mbp
   -- first check whether profile MSC_BKT_REFERENCE_CALENDAR is set
   -- if it set, l_calendar_code = MSC_BKT_REFERENCE_CALENDAR
   -- otherwise, l_calendar_code = owning org's calendar


   l_calendar_code := fnd_profile.value('MSC_BKT_REFERENCE_CALENDAR');
   if (l_calendar_code is null) then
      select mtp.calendar_code into l_calendar_code
      from msc_trading_partners mtp,       msc_plans mp
      where mtp.sr_tp_id = mp.organization_id
      and mtp.sr_instance_id = mp.sr_instance_id
      and mp.plan_id =p_plan_id and mtp.PARTNER_TYPE =3;

   end if;


 -- dbms_output.put_line('calendar_code=' || l_calendar_code);

 if (p_bkt_type =1 ) then

    select max(mcd.calendar_date)  into x_date
    from msc_calendar_dates mcd,msc_calendars mc
    where mc.calendar_code = l_calendar_code
    and mc.sr_instance_id = p_sr_instance_id
    and mc.calendar_code=mcd.calendar_code
    and mc.sr_instance_id=mcd.sr_instance_id

    and mcd.calendar_date <= p_bkt_start_date
    and mcd.calendar_date >= p_bkt_start_date -7
    and mcd.seq_num is not null;

    return x_date;
  else
    return p_bkt_start_date;
  end if;

  exception

   when no_data_found then
      return null;

end working_day_bkt_start_date;

function get_item_org(p_plan_id in number,p_item_id in number,
                      p_sr_inst_id in number) return number is
x_org_id number;
begin
   select min(organization_id) into x_org_id
   from msc_system_items
   where plan_id=p_plan_id
   and inventory_item_id = p_item_id
   and sr_instance_id = p_sr_inst_id
   and organization_id>0;
   return x_org_id;
 end get_item_org;

end msc_hub_calendar;

/
