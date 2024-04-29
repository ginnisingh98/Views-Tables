--------------------------------------------------------
--  DDL for Package Body PER_PERRPRMS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERRPRMS_XMLP_PKG" AS
/* $Header: PERRPRMSB.pls 120.1 2007/12/06 11:32:43 amakrish noship $ */

function BeforeReport return boolean is
begin

c_end_of_time := hr_general.end_of_time;
declare l_legislation_code VARCHAR2(2);
begin
P_SESSION_DATE1:=TO_CHAR(P_SESSION_DATE,'DD-MON-YYYY');
--hr_standard.event('BEFORE REPORT');

 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);

 select legislation_code
 into   l_legislation_code
 from   per_business_groups
 where  business_group_id = p_business_group_id;

 p_legislation_code := l_legislation_code ;
 IF p_position_id is not null then
        c_job_position_id := p_position_id;
        p_job_position := 'POSITION_ID';
        c_job_position_name :=
            hr_reports.get_position(p_position_id);
 ELSIF
    p_job_id is not null then
        c_job_position_id := p_job_id;
         p_job_position := 'JOB_ID';
        c_job_position_name :=
            hr_reports.get_job(p_job_id);
 END IF;


 c_person_type_desc :=
       hr_reports.get_lookup_meaning('EMP_OR_APL',p_person_type);



 null;
end;  return (TRUE);
end;

function C_SPECIAL_INFO_SEGSFormula return Number is
begin


return(0);
end;

function g_people_matchinggroupfilter(c_special_info_count in number, person_id1 in number, C_COUNT_ESSENTIAL in number, C_COUNT_DESIRABLE in number) return boolean is
begin

if c_special_info_count = 0 then return(false);
else
return(
hr_reports.person_matching_skills
(person_id1
,C_JOB_POSITION_ID
,substr(P_JOB_POSITION,1,1)
,P_MATCHING_LEVEL
,C_COUNT_ESSENTIAL
,C_COUNT_DESIRABLE)
);
end if;  return (TRUE);
end;

function c_date_toformula(date_to in date) return varchar2 is
begin

if date_to = c_end_of_time then
   return('');
   else
   return(to_char(date_to,'DD-MON-YYYY'));
end if;

RETURN NULL; end;

function C_REQUIREMENT_HEADINGFormula return VARCHAR2 is
begin

return(rpad('-',NVL(length(c_requirement_desc), 0),'-'));
end;

function c_essential_decodeformula(essential in varchar2) return varchar2 is
begin

return(hr_reports.get_lookup_meaning
                  ('YES_NO',essential));
end;

function AfterReport return boolean is
begin

--hr_standard.event('AFTER REPORT');

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_REQ_VAL_p return varchar2 is
	Begin
	 return C_REQ_VAL;
	 END;
 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
 Function C_JOB_POSITION_ID_p return number is
	Begin
	 return C_JOB_POSITION_ID;
	 END;
 Function C_JOB_POSITION_NAME_p return varchar2 is
	Begin
	 return C_JOB_POSITION_NAME;
	 END;
 Function C_PERSON_TYPE_DESC_p return varchar2 is
	Begin
	 return C_PERSON_TYPE_DESC;
	 END;
 Function C_REQUIREMENT_DESC_p return varchar2 is
	Begin
	 return C_REQUIREMENT_DESC;
	 END;
 Function C_REQUIREMENT_VALUE_p return varchar2 is
	Begin
	 return C_REQUIREMENT_VALUE;
	 END;
 Function C_END_OF_TIME_p return date is
	Begin
	 return C_END_OF_TIME;
	 END;
END PER_PERRPRMS_XMLP_PKG ;

/
