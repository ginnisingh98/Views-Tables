--------------------------------------------------------
--  DDL for Package Body POA_DBI_CALENDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_CALENDAR_PKG" AS
/* $Header: poadbicalb.pls 115.3 2002/10/01 21:25:12 mangupta noship $ */

Function current_report_start_date(as_of_date date,
                              period_type varchar2,
                              comparison_type varchar2)
         return date is

 l_date date;
 l_curr_year number;
 l_curr_qtr number;
 l_curr_period number;
 l_week_start_date date;
 l_curr_p445 number;

begin

 if(period_type = 'YTD') then

   select sequence
   into l_curr_year
   from fii_time_ent_year
   where as_of_date between start_date and end_date;

   select min(start_date)
   into l_date
   from fii_time_ent_year
   where sequence>=l_curr_year-3;

  end if;

 if(period_type = 'QTD') then

   select sequence, ent_year_id
   into l_curr_qtr, l_curr_year
   from fii_time_ent_qtr
   where as_of_date between start_date and end_date;

   if(comparison_type = 'Y') then
     select start_date
     into l_date
     from (select start_date
        from fii_time_ent_qtr
        where ((sequence>=l_curr_qtr+1 and ent_year_id=l_curr_year-1)
               or (sequence>=1 and ent_year_id=l_curr_year))
        order by start_date)
     where rownum <= 1;
   else
     select start_date
     into l_date
     from (select start_date
        from fii_time_ent_qtr
        where ((sequence>=l_curr_qtr+1 and ent_year_id=l_curr_year-2)
               or (sequence>=1 and ent_year_id=l_curr_year-1))
        order by start_date)
     where rownum <= 1;
   end if;

  end if;

 if(period_type = 'MTD') then

   select p.sequence, q.ent_year_id
   into l_curr_period, l_curr_year
   from fii_time_ent_period p, fii_time_ent_qtr q
   where p.ent_qtr_id=q.ent_qtr_id
   and as_of_date between p.start_date and p.end_date;

   select start_date
   into l_date
   from (select p.start_date
         from fii_time_ent_period p, fii_time_ent_qtr q
         where p.ent_qtr_id=q.ent_qtr_id
         and ((p.sequence>=l_curr_period+1 and q.ent_year_id=l_curr_year-1)
           or (p.sequence>=1 and q.ent_year_id=l_curr_year))
         order by p.start_date)
   where rownum <= 1;

 end if;

 if(period_type = 'WTD') then

   select start_date
   into l_week_start_date
   from fii_time_week
   where as_of_date between start_date and end_date;

   select min(start_date)
   into l_date
   from fii_time_week
   where start_date>=l_week_start_date-7*12;

  end if;

 return l_date;

 exception
   when others then
     return bis_common_parameters.get_global_start_date;

end;

Function previous_report_start_date(as_of_date date,
                              period_type varchar2,
                              comparison_type varchar2)
         return date is

  l_prev_date date;
  l_date date;

begin

  l_prev_date := previous_period_asof_date(as_of_date, period_type, comparison_type);

  l_date := current_report_start_date(l_prev_date, period_type, comparison_type);

  return l_date;

end;

Function current_period_start_date(as_of_date date,
                                   period_type varchar2)
         return date is

l_date date;

begin

  if(period_type='YTD') then
    l_date := fii_time_api.ent_cyr_start(as_of_date);

  elsif(period_type='QTD') then
    l_date := fii_time_api.ent_cqtr_start(as_of_date);

  elsif(period_type='MTD') then
    l_date := fii_time_api.ent_cper_start(as_of_date);

  elsif(period_type = 'WTD') then
    l_date := fii_time_api.cwk_start(as_of_date);

  end if;

  return l_date;

  exception
   when others then
     return bis_common_parameters.get_global_start_date;

end;

Function previous_period_start_date(as_of_date date,
                              period_type varchar2,
                              comparison_type varchar2)
         return date is

  l_prev_date date;
  l_date date;

begin

  l_prev_date := previous_period_asof_date(as_of_date, period_type, comparison_type);

  l_date := current_period_start_date(l_prev_date, period_type);

  return l_date;
 exception
   when others then
     return bis_common_parameters.get_global_start_date;
end;

Function previous_period_asof_date(as_of_date date,
                                   period_type varchar2,
                                   comparison_type varchar2)
         return date is

l_date date;

begin

  if(period_type='YTD') then

    l_date := fii_time_api.ent_sd_lyr_end(as_of_date);

  elsif(period_type='QTD') then

    if(comparison_type = 'Y') then
      l_date := fii_time_api.ent_sd_lysqtr_end(as_of_date);
    else
      l_date := fii_time_api.ent_sd_pqtr_end(as_of_date);
    end if;

  elsif(period_type='MTD') then

    if(comparison_type = 'Y') then
      l_date := fii_time_api.ent_sd_lysper_end(as_of_date);
    else
      l_date := fii_time_api.ent_sd_pper_end(as_of_date);
    end if;

  elsif(period_type='WTD') then

    if(comparison_type = 'Y') then
      l_date := fii_time_api.sd_lyswk(as_of_date);
    else
      l_date := fii_time_api.sd_pwk(as_of_date);
    end if;

  end if;

  return l_date;
 exception
   when others then
     return bis_common_parameters.get_global_start_date - 1; /* making sure it's b4 the min_date of current_report_date */
end;

end;

/
