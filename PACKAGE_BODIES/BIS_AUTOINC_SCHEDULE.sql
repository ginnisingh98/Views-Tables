--------------------------------------------------------
--  DDL for Package Body BIS_AUTOINC_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_AUTOINC_SCHEDULE" as
/* $Header: BISVAISB.pls 115.6 2003/11/20 15:24:05 nkishore noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile:~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      bis_autoinc_schedule                                    --
--                                                                        --
--  DESCRIPTION:  Auto increment dates for PM Viewer scheduled reports.   --
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification                                    --
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--  07/17/2001 dmarkman   Initial Creation                                --
--  08/06/2003 nkishore   BugFix 3006638                                  --
--                                                                        --
----------------------------------------------------------------------------



----------------------------------------------------------------------------
--  Procedure:    autoIncrementDates                                      --
--                                                                        --
--  Description:  auto increments time parameter for a scheduled report   --
--                                                                        --
--  Parameters:                                                           --
--                                                                        --
--  call from BISVIEWER.showReport:                                       --
--                                                                        --
--  bis_autoinc_schedule.autoIncrementDates(pRegionCode,                  --
--                         pFunctionName,                                 --
--                         vSessionId,                                    --
--                         vUserId,                                       --
--                         vResponsibilityId,                             --
--                         pScheduleId);                                  --
--                                                                        --
--  HISTORY                                                               --
--  Date          Developer  Modifications                                --
-- 07-05-2001     dmarkman   Initial Creation                             --
--                                                                        --
----------------------------------------------------------------------------
procedure autoIncrementDates(pRegionCode       in varchar2,
                             pFunctionName     in varchar2,
                             pSessionId        in varchar2,
                             pUserId           in varchar2,
                             pResponsibilityId in varchar2,
                             pScheduleId       in varchar2) is


v_increment_dates       varchar2(1);
type                    c1_cur_type is ref cursor;
c1                      c1_cur_type;

v_sql_stmnt             varchar2(4000);

v_dimn_level_value_from varchar2(120);
v_dimn_level_id_from    varchar2(120);

v_dimn_level_value_to   varchar2(120);
v_dimn_level_id_to      varchar2(120);

v_start_date            date;
v_end_date              date;
v_sys_date              date;
v_start_date_temp       date;

v_start_date_lov_from   date;
v_start_date_lov_to     date;
v_end_date_lov_from     date;
v_end_date_lov_to       date;

v_date_increment        number;

v_rowid_to              varchar2(60);
v_rowid_from            varchar2(60);

v_rowid                 varchar2(60);
v_session_value         bis_user_attributes.session_value%type;
v_session_description   bis_user_attributes.session_description%type;
v_period_date           bis_user_attributes.period_date%type;
v_attribute_name        bis_user_attributes.attribute_name%type;

v_parameter             varchar2(120);

v_org_param             varchar2(80);
v_org_value             varchar2(80);

v_from_flag             char(1) := 'N';
v_to_flag               char(1) := 'N';


cursor cStoredTimeParms(pScheduleId varchar2) is
select rowid, session_value, session_description, period_date, attribute_name
from bis_user_attributes
where dimension in('TIME','EDW_TIME_M')
and schedule_id = pScheduleId;


cursor cStoredOrgParms(pScheduleId varchar2) is
select attribute_name, session_description
from bis_user_attributes
where dimension in('ORGANIZATION','EDW_ORGANIZATION_M')
and schedule_id = pScheduleId;


cursor cIncrementFlag(pScheduleId varchar2) is
select increment_dates
from fnd_concurrent_requests
where request_id in(
      select concurrent_request_id
      from bis_scheduler
      where schedule_id = pScheduleId);


begin

--htp.br;
--htp.print('dmarkman - auto increment');
--htp.br;


if pScheduleId is not null then

   open  cIncrementFlag(pScheduleId);
   fetch cIncrementFlag into v_increment_dates;
   close cIncrementFlag;


   if v_increment_dates = 'Y' then

      select sysdate
      into v_sys_date
      from dual;

      open cStoredTimeParms(pScheduleId);
      loop
      fetch cStoredTimeParms into v_rowid, v_session_value, v_session_description,
            v_period_date, v_attribute_name;
      exit when cStoredTimeParms%notfound;

         if(instr(v_attribute_name, '_FROM') <> 0) then

            v_rowid_from := v_rowid;
            v_parameter  := replace(v_attribute_name, '_FROM');
            v_start_date := v_period_date;

         elsif  (instr(v_attribute_name, '_TO') <> 0) then

            v_rowid_to  := v_rowid;
            v_parameter := replace(v_attribute_name, '_TO');
            v_end_date  := v_period_date;

         end if;

      end loop;
      close cStoredTimeParms;


      if(v_sys_date - v_start_date > 0) and (v_sys_date - v_end_date > 0) and
        (v_start_date is not null) and (v_end_date is not null) then


          v_date_increment := v_end_date - v_start_date;

          open  cStoredOrgParms(pScheduleId);
          fetch cStoredOrgParms into v_org_param, v_org_value;
          close cStoredOrgParms;


          v_sql_stmnt :=  bis_parameter_validation.getTimeLOVSQL(v_parameter, '',
                  'LOV',pRegionCode, pResponsibilityId, v_org_param, v_org_value);

          -- htp.print(v_sql_stmnt);htp.br;

          open c1 for v_sql_stmnt;
          loop
          fetch c1 into v_dimn_level_id_to, v_dimn_level_value_to, v_start_date_lov_to, v_end_date_lov_to;

          exit when c1%notfound;

          if (trunc(v_sys_date - v_start_date_lov_to) >= 0) and (trunc(v_sys_date - v_end_date_lov_to) <= 0) then
              v_to_flag := 'Y';
              exit;

          end if;
          end loop;
          close c1;


          v_start_date_temp := v_end_date_lov_to - v_date_increment;


          open c1 for v_sql_stmnt;
          loop
          fetch c1 into v_dimn_level_id_from, v_dimn_level_value_from, v_start_date_lov_from, v_end_date_lov_from;

          exit when c1%notfound;


          if (trunc(v_start_date_temp - v_start_date_lov_from) >= 0) and (trunc(v_start_date_temp - v_end_date_lov_from) <= 0) then
              v_from_flag := 'Y';
              exit;

          end if;
          end loop;
          close c1;


          if(v_start_date_lov_from is not null) and (v_end_date_lov_to is not null)
             and(v_to_flag = 'Y' and v_from_flag = 'Y') then

          -- 'from' record:
            update bis_user_attributes set
                session_value = v_dimn_level_id_from,
                session_description = v_dimn_level_value_from,
                period_date = v_start_date_lov_from
                where rowid = v_rowid_from;

          -- 'to' record:
            update bis_user_attributes set
                session_value = v_dimn_level_id_to,
                session_description = v_dimn_level_value_to,
                period_date = v_end_date_lov_to
                where rowid = v_rowid_to;

          -- BugFix 3006638 'as of date'
            update bis_user_attributes set
                --session_value = to_char(v_sys_date, 'DD-MON-RRRR'),
                --session_description = to_char(v_sys_date, 'DD-MON-RRRR'),
                --As of Date 3094234--dd/mm/rrrr format
                session_value = to_char(v_sys_date, 'DD/MM/RRRR'),
                session_description = to_char(v_sys_date, 'DD/MM/RRRR'),
                period_date = v_sys_date
                where schedule_id= pScheduleId
                and attribute_name='AS_OF_DATE';

             commit;

          end if;

          --htp.print(' v_start_date_lov_from: ' || to_char(v_start_date_lov_from));htp.br;
          --htp.print(' v_end_date_lov_to: ' || to_char(v_end_date_lov_to));htp.br;

      end if;

    end if;
end if;
exception when others then
null;
end autoIncrementDates;

end bis_autoinc_schedule;


/
