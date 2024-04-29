--------------------------------------------------------
--  DDL for Package Body FND_CONC_RELEASE_CLASS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_RELEASE_CLASS_UTILS" as
/* $Header: AFCPCRCB.pls 120.2.12010000.2 2009/11/24 22:04:12 jtoruno ship $ */




-- Name
--  calc_specific_startdate
-- Purpose
--  Given a requested start date and the class info for a Specific schedule,
--  return the next date that a request should run according to this schedule.
--  May return null if no valid date found.
--
function calc_specific_startdate(req_sdate in date,
                                 class_info in varchar2) return date is

  found        number;
  offset       number;
  temp_date    date;
  dow          number; -- day of week 1 for Sun, 7 for Sat
  dom          number; -- day of month between 1 to 31
  nextdom      number;
  weekno       number; -- no of week in month
  moy          number; -- month of year between 1 to 12
  datespec     boolean; -- true if some date is specified
  dayspec      boolean; -- true if some week day is specified
begin
    found := 0;
    offset := 0;

    /* find first schedule time after sysdate then subtract a day */

    temp_date := req_sdate + floor(trunc(sysdate - req_sdate));

      -- handle 56 bits code for advance scheduling
      if (LENGTH(class_info) = 56) then

          -- check if any of date is specified
          -- ie if either of bit from 1 to 32 is set
          if (SUBSTR(class_info, 1, 32) = 0) then
              datespec := false;
          else
              datespec := true;
          end if;

          -- check if any of the day is specified
          -- ie if either of bit from 33 to 39 is set
          if (SUBSTR(class_info, 33, 7) = 0) then
              dayspec := false;
          else
              dayspec := true;
          end if;
      end if;


    /* find next day where day of week or month is executable.
       Day of week complexity is to avoid problems with calendars
       where weekday numbering is different.  Nextdom is for finding
       if its the last day of the month.  Class info in this case is a
       bitfield: first 31 are for dom, 32 is last dom, 33-39 is dow */

   /* 8590269 - Advanced Sched for dates within a year of the current date were
      not properly getting calculated since loop only went for 31 days from
      current day.  offset is now avail for a full year from current date. */

    while (offset < 365) and (found = 0) loop
      offset := offset + 1;
      dow := MOD(trunc(TO_NUMBER(TO_CHAR(temp_date+1+offset,'J'))),7) + 1;
      dom := TO_NUMBER(TO_CHAR(temp_date+offset,'DD'));
      nextdom := TO_NUMBER(TO_CHAR(temp_date+1+offset,'DD'));

      -- handle 56 bits code
      if (LENGTH(class_info) = 56) then
      begin
          moy := TO_NUMBER(TO_CHAR(temp_date + offset,'MM'));
          weekno := TO_NUMBER(TO_CHAR(temp_date + offset,'W'));

          if (SUBSTR(class_info,44 + moy,1) = '1') /* if month is specified */ then
          begin
          -- see if there is some matching schedule
          -- either day of month is matched OR (its last day of month and week is current week
             if ( ((SUBSTR(class_info,dom,1) = '1') or ((SUBSTR(class_info,32,1) = '1') and (nextdom = 1)))
             or ( (SUBSTR(class_info,dow + 32,1) = '1') and (SUBSTR(class_info,weekno + 39,1) = '1')) ) then
                 found := 1;
             end if;
          end;
          end if;
      end;
      else
      -- handle 39 bits code as usual for backward compatibility
          if (SUBSTR(class_info,dom,1) = '1') or /* if date matches */
             ((SUBSTR(class_info,32,1) = '1') and (nextdom = 1)) or
             (SUBSTR(class_info,dow + 32,1) = '1') then
                  found := 1;
          end if;
      end if;
    end loop;

    /* the bitfield must be all zeros...we don't have to take this abuse */
    if found = 0 then return null;
    else return greatest(req_sdate, temp_date + offset);
    end if;

end calc_specific_startdate;


-- Name
--  parse_named_periodic_schedule
-- Purpose
--  Given an application name and a Periodic schedule name,
--  return the interval, interval unit, interval type, start_date and end date
--  for this schedule.
--  Values will be null if the schedule is not found or an error occurs.
--
procedure parse_named_periodic_schedule(p_application 	 in varchar2,
			                p_class_name 	 in varchar2,
                                        p_repeat_interval      out nocopy number,
                                        p_repeat_interval_unit out nocopy varchar2,
                                        p_repeat_interval_type out nocopy varchar2,
                                        p_start_date           out nocopy date,
                                        p_repeat_end           out nocopy date) is

   p_rel_class_app_id    number;
   p_rel_class_id        number;
begin
   p_repeat_interval      := null;
   p_repeat_interval_unit := null;
   p_repeat_interval_type := null;
   p_repeat_end           := null;
   p_start_date           := null;

   select a.application_id, c.release_class_id
   into   p_rel_class_app_id, p_rel_class_id
   from   fnd_conc_release_classes c, fnd_application a
   where  upper(release_class_name)       = upper(p_class_name)
   and    c.application_id                = a.application_id
   and    a.application_short_name = upper(p_application);

   parse_periodic_schedule(p_rel_class_app_id, p_rel_class_id,
                           p_repeat_interval,
                           p_repeat_interval_unit,
                           p_repeat_interval_type,
                           p_start_date,
                           p_repeat_end);


exception
   when no_data_found then
     return;

end parse_named_periodic_schedule;



-- Name
--  parse_periodic_schedule
-- Purpose
--  Given an application id and a Periodic schedule id,
--  return the interval, interval unit, interval type, start_date and end date
--  for this schedule.
--  Values will be null if the schedule is not found or an error occurs.
--
procedure parse_periodic_schedule(p_rel_class_app_id in number,
                                  p_rel_class_id     in number,
                                  p_repeat_interval      out nocopy number,
                                  p_repeat_interval_unit out nocopy varchar2,
                                  p_repeat_interval_type out nocopy varchar2,
                                  p_start_date           out nocopy date,
                                  p_repeat_end           out nocopy date) is

   c1            number;
   c2            number;
   sch_type      varchar2(1);
   curr_info     varchar2(64);
   req_date      date;
   tmp_interval  number;
begin
   p_repeat_interval      := null;
   p_repeat_interval_unit := null;
   p_repeat_interval_type := null;
   p_repeat_end           := null;
   p_start_date           := null;

   select class_info, class_type, date1, date2
     into curr_info, sch_type, req_date, p_repeat_end
     from fnd_conc_release_classes
     where application_id = p_rel_class_app_id
     and   release_class_id = p_rel_class_id;

   if sch_type <> 'P' then
      return;
   end if;

   c1 := instr(curr_info, ':', 1, 1);
   c2 := instr(curr_info, ':', 1, 2);

   -- interval is the first field
   p_repeat_interval := to_number(substr(curr_info, 1, (c1-1)));

   -- interval unit
   select decode(substr(curr_info, c1+1, 1),
                 'M', 'MONTHS', 'D', 'DAYS', 'H', 'HOURS', 'N', 'MINUTES')
     into p_repeat_interval_unit
     from dual;

   -- interval type
   select decode(substr(curr_info, (c2+1), 1), 'C', 'END', 'START')
     into p_repeat_interval_type
     from dual;


   -- now figure out the correct requested start date
   select floor((sysdate - req_date) / DECODE(p_repeat_interval_unit,
		 'MINUTES', GREATEST(p_repeat_interval,1) / 1440,
                 'HOURS', GREATEST(p_repeat_interval,1/60) / 24,
                 'DAYS', GREATEST(p_repeat_interval,1/1440),
                 'MONTHS', GREATEST(p_repeat_interval,1) * 31,1))
   into tmp_interval
   from dual;

   if (tmp_interval > 0)  then
     select req_date +
            DECODE(p_repeat_interval_unit,
		   'MINUTES', tmp_interval * GREATEST(p_repeat_interval,1) / 1440,
                   'HOURS', tmp_interval * GREATEST(p_repeat_interval,1/60) / 24,
                   'DAYS', tmp_interval * GREATEST(p_repeat_interval,1/1440),
                   'MONTHS', ADD_MONTHS(req_date, tmp_interval * p_repeat_interval)-req_date,
		   1)
     into req_date
     from dual;
   end if;

   while (req_date < sysdate) loop
       select req_date +
                DECODE(p_repeat_interval_unit,
		 'MINUTES', GREATEST(p_repeat_interval,1) / 1440,
                 'HOURS', GREATEST(p_repeat_interval,1/60) / 24,
                 'DAYS', GREATEST(p_repeat_interval,1/1440),
                 'MONTHS', ADD_MONTHS(req_date,p_repeat_interval)-req_date,
		 1)
       into req_date
       from dual;
     end loop;


   p_start_date := req_date;

exception
   when no_data_found then
      null;

end parse_periodic_schedule;

-- Name
--  assign_specific_sch
-- Purpose
--  this function assigns specific schedule to a request
--  return true if successful
--  May return false if unsuccessful
--
function assign_specific_sch (req_id in number,
                              class_info in varchar2,
                              start_date in date,
                              end_date in date) return boolean is

  relseqno              number;
  relclassname          varchar2(20);
  relclass_insert_error exception;
  dual_no_rows	        exception;
  dual_too_many_rows    exception;

begin

    begin
        Select Fnd_Conc_Release_Classes_S.nextval
        Into relseqno
        From Sys.Dual;

        exception
            when no_data_found then
                raise dual_no_rows;
            when too_many_rows then
                raise dual_too_many_rows;
            when others then
                raise;
    end;

    relclassname := 'RSRUN:0-' || TO_CHAR(relseqno);

    Insert Into fnd_conc_release_classes (application_id, release_class_id, release_class_name, owner_req_id, enabled_flag,
    creation_date, created_by, last_update_date, last_updated_by, last_update_login, updated_flag, date1, date2, class_type,
    class_info)
    Values (0 , relseqno, relclassname, req_id, 'Y', Sysdate, FND_GLOBAL.conc_login_id, Sysdate,
    FND_GLOBAL.conc_login_id, FND_GLOBAL.conc_login_id, 'N', start_date, end_date, 'S', class_info);

    if (sql%rowcount = 0) then
        raise relclass_insert_error;
    end if;

    INSERT INTO Fnd_Conc_Release_Classes_TL (application_id, release_class_id, language, source_lang,
    user_release_class_name,last_update_date, last_updated_by, last_update_login, creation_date, created_by)
    Select 0, relseqno, L.LANGUAGE_CODE, userenv('LANG'), relclassname,
    Sysdate, FND_GLOBAL.conc_login_id, FND_GLOBAL.conc_login_id, Sysdate, FND_GLOBAL.conc_login_id from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B');

    if (sql%rowcount = 0) then
        raise relclass_insert_error;
    end if;

    -- modify FND_CONCURRENT_REQUESTS to set the release class id for this request
    update Fnd_Concurrent_Requests set release_class_id=relseqno, release_class_app_id=0 where request_id=req_id;

    if (sql%rowcount = 0) then
        raise relclass_insert_error;
    end if;

    return (true);

    exception
    when relclass_insert_error then
        fnd_message.set_name ('FND', 'CONC-RelClass insert failed');
        fnd_message.set_token ('APPLICATION', 0, FALSE);
        fnd_message.set_token ('CLASS', relseqno, FALSE);
        return (false);
    when dual_no_rows then
        fnd_message.set_name ('FND', 'No Rows in Dual');
        return (false);
    when dual_too_many_rows then
        fnd_message.set_name ('FND', 'Too many rows in Dual');
        return (false);
    when others then
        fnd_message.set_name ('FND', 'SQL-Generic error');
        fnd_message.set_token ('ERRNO', sqlcode, FALSE);
        fnd_message.set_token ('REASON', sqlerrm, FALSE);
        fnd_message.set_token ('ROUTINE', 'assign_specific_sch: others', FALSE);
        return (false);

end assign_specific_sch;


end FND_CONC_RELEASE_CLASS_UTILS;

/
