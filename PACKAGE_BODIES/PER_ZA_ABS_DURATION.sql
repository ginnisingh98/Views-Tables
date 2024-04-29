--------------------------------------------------------
--  DDL for Package Body PER_ZA_ABS_DURATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_ABS_DURATION" as
/* $Header: perzaabd.pkb 120.8 2008/02/07 06:53:26 rbabla noship $ */
function za_daysoff  (p_DateFrom IN DATE,
                      p_DateTo   IN DATE)
                      return number
  is
------------------------- FUNCTION za_daysoff --------------------------
-- The following function returns the number of days off between parameters.
-- Function checks if the date is on a Sat/Sun and if not then checks if
-- it is a public holiday
------------------------------------------------------------------------
    v_DaysOff  number := 0;
    v_DateFrom date;
    v_index    number := 0;
    v_count    number := 0;
    l_count    number := 0;
    l_hol_date date;
    type date_table_type is table of date
      index by binary_integer;
    publichol_table date_table_type;
    cursor c1 is
           select  puci.value
                 , puci.user_column_instance_id
                 , puci.effective_start_date
                 , puci.effective_end_date
                 , puc.user_column_name
               from  pay_user_tables put, pay_user_columns puc, pay_user_column_instances_f puci
               where put.user_table_name = 'ZA_PUBLIC_HOLIDAY_CALENDAR'
               and   put.user_table_id   = puc.user_table_id
               and   puc.user_column_id  = puci.user_column_id
               and   puci.effective_start_date <= p_DateTo
               and   puci.effective_end_date   >= p_DateFrom;

  begin
    v_DateFrom := p_DateFrom;
--    open c1;
/* Retrieve all public holidays between parameter dates and load into PL/SQL table for
   subsequent search. Check if the day is a Sat/Sun then increment counter, if not
   then check the pl/sql public holiday table and if match found then increment */
--    loop
--       v_index := v_index + 1;
--       fetch c1 into publichol_table(v_index);
--       exit when c1%notfound or c1%notfound is null;
--    end loop;
--    close c1;
    for rec_hol_dt in c1
    loop
        begin
                l_hol_date := fnd_date.CANONICAL_TO_DATE(rec_hol_dt.value);
                if l_hol_date >= p_DateFrom and l_hol_date <= p_DateTo -- holiday falls within period
                   and l_hol_date >= rec_hol_dt.effective_start_date
                   and l_hol_date <=  rec_hol_dt.effective_end_date then
                         v_index := v_index + 1;
                         publichol_table(v_index):= l_hol_date;
                end if;
         exception
                when others then
                        l_count := l_count +1;
                      hr_utility.set_location('************************',9999);
                      hr_utility.trace(substr(SQLERRM,1,254));
                      hr_utility.trace('SQLCODE' || SQLCODE);
                                  hr_utility.set_location('Count of wrong record    ' || l_count,9999);
                                  hr_utility.set_location('rec_value.value          ' || rec_hol_dt.value,9999);
                      hr_utility.set_location('user_column_instance_id  ' || rec_hol_dt.user_column_instance_id,9999);
                                  hr_utility.set_location('Effective_End_date       ' || rec_hol_dt.effective_start_date,9999);
                                  hr_utility.set_location('Effective_End_date       ' || rec_hol_dt.effective_end_date,9999);
                                  hr_utility.set_location('user_column_name         ' || rec_hol_dt.user_column_name,9999);
                      hr_utility.set_location('************************',9999);
        end;

    end loop;
    v_count := publichol_table.count;
    v_index := 1;
    while v_DateFrom <= p_DateTo LOOP
        if  to_char(v_DateFrom, 'DY') IN ('SAT','SUN') THEN
            v_DaysOff := v_DaysOff + 1;
        else
            for v_index IN 1..(v_count) loop
              if  v_DateFrom = publichol_table (v_index) then
                  v_DaysOff := v_DaysOff + 1;
              end if;
            end loop;
        end if;
      v_DateFrom := v_DateFrom + 1;
    end loop;
   return v_DaysOff;
end ZA_DaysOff;

  function get_canonical_Dt_format
  return varchar2 is
  l_format varchar2(100);
  begin
        l_format := FND_DATE.canonical_DT_mask;

        return l_format;
  end get_canonical_Dt_format;

  function za_canonical_Dt_format (p_date varchar2)
  return varchar2 is
        l_status varchar2(4);
        l_date   date;
        l_year   number(4);
        l_month  number(2);
        l_date1   number(4);
	l_datewo_time varchar2(25);
	l_space   number(2);
        l_year_dlmt number(2);
        l_month_dlmt number(2);
        l_date_dlmt number(2);
        begin
      l_date   := fnd_date.canonical_to_date(p_date);
      l_space  := instr(p_date,' ',1,1);
      if l_space<>0 then
          l_datewo_time:=substr(p_date,1,l_space-1);
      else
          l_datewo_time:=p_date;
          l_space:=length(p_date)+1;
      end if;

      l_year_dlmt  := instr(p_date,'/',1,1);
      l_month_dlmt := instr(p_date,'/',1,2);

      if l_year_dlmt = 0 or l_month_dlmt = 0 then
         l_status := 'E';
	 return l_status;
      end if;

      l_year   := substr(l_datewo_time,1,l_year_dlmt-1);
      l_month  := substr(l_datewo_time,l_year_dlmt+1,(l_month_dlmt - l_year_dlmt)-1);
      l_date1   := substr(l_datewo_time,l_month_dlmt+1,(l_space-l_month_dlmt)-1);

      if l_year > 0 and l_month <= 12 and l_date1 <= 31 and l_year_dlmt=5 then
         l_status := 'S';
      else
         l_status := 'E';
      end if;
        return l_status;
     exception
        when others then
                l_status := 'E';
                return l_status;

   end za_canonical_Dt_format;

end per_za_abs_duration;

/
