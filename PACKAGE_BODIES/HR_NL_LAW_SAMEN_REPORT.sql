--------------------------------------------------------
--  DDL for Package Body HR_NL_LAW_SAMEN_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NL_LAW_SAMEN_REPORT" AS
/* $Header: pernllsr.pkb 115.9 2002/08/24 14:16:48 gpadmasa noship $ */

--
function get_total(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).total);
exception
when others then
  return (0);
end;
--
function get_ls_total(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).ls_total);
exception
when others then
  return (0);
end;
--
function get_acht_total(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).acht_total);
exception
when others then
  return (0);
end;
--
function get_full_time(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).full_time);
exception
when others then
  return (0);
end;
--
function get_acht_full_time(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).acht_full_time);
exception
when others then
  return (0);
end;
--
function get_part_time(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).part_time);
exception
when others then
  return (0);
end;

--
function get_acht_part_time(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).acht_part_time);
exception
when others then
  return (0);
end;
--
function get_total_hired(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).total_hired);
exception
when others then
  return (0);
end;

--
function get_acht_hired(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).acht_hired);
exception
when others then
  return (0);
end;
--
function get_terminated(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).terminated);
exception
when others then
  return (0);
end;
--
function get_acht_terminated(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).acht_terminated);
exception
when others then
  return (0);
end;
--
function get_current_total(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).current_total);
exception
when others then
  return (0);
end;
--
function get_last_acht_total(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).last_acht_total);
exception
when others then
  return (0);
end;

--
function get_last_perc_acht(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).last_perc_acht);
exception
when others then
  return (0);
end;

--
function get_perc_acht(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).perc_acht);
exception
when others then
  return (0);
end;
--
function get_perc_full_time(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).perc_full_time);
exception
when others then
  return (0);
end;

--
function get_perc_acht_ftime(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).perc_acht_ftime);
exception
when others then
  return (0);
end;
--
function get_perc_part_time(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).perc_part_time);
exception
when others then
  return (0);
end;
--
function get_perc_acht_ptime(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).perc_acht_ptime);
exception
when others then
  return (0);
end;
--
function get_perc_acht_hired(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).perc_acht_hired);
exception
when others then
  return (0);
end;
--
function get_perc_acht_term(p_organization_id NUMBER) return NUMBER is
begin
return(HQOrgData(p_organization_id).perc_acht_term);
exception
when others then
  return (0);
end;


procedure populate_lawsamen_table
( P_BUSINESS_GROUP_ID         IN NUMBER
, P_TOP_ORGANIZATION_ID       IN NUMBER
, P_ORGANIZATION_STRUCTURE_ID IN NUMBER
, P_ROLL_UP              	  IN VARCHAR2
, P_REPORT_YEAR               IN NUMBER
, P_REGION                    IN VARCHAR2)

is

l_roll_up				varchar2(2);

cursor	get_org_structure_version
(P_ORGANIZATION_STRUCTURE_ID	NUMBER
,P_REPORT_YEAR			NUMBER)
is
select max(posv.org_structure_version_id) org_structure_version_id
from per_org_structure_versions posv
where posv.organization_structure_id = P_ORGANIZATION_STRUCTURE_ID
and     to_number(to_char(nvl(posv.date_from,sysdate),'YYYY')) <= P_REPORT_YEAR
and    	to_number(to_char(nvl(posv.date_to,sysdate),'YYYY')) >= P_REPORT_YEAR
order by   posv.org_structure_version_id;


cursor    get_org_structure_element
(P_ORG_STRUCTURE_VERSION_ID	NUMBER
,P_TOP_ORGANIZATION_ID	NUMBER
,P_ORG_STRUCTURE_ID NUMBER)
is
select    distinct ose.organization_id_child organization_id
from      per_org_structure_elements ose, per_org_structure_versions_v posv
where     ose.org_structure_version_id     = posv.ORG_STRUCTURE_VERSION_ID
and       ose.BUSINESS_GROUP_ID = posv.BUSINESS_GROUP_ID
and       posv.ORG_STRUCTURE_VERSION_ID =  P_ORG_STRUCTURE_VERSION_ID
and       posv.ORGANIZATION_STRUCTURE_ID = P_ORG_STRUCTURE_ID
and       ose.organization_id_parent         = P_TOP_ORGANIZATION_ID

UNION
select    P_TOP_ORGANIZATION_ID organization_id
from      dual
order by  organization_id;

cursor	get_organizations
( P_ORG_STRUCTURE_VERSION_ID  NUMBER
, P_ORGANIZATION_ID  		NUMBER
, P_ROLL_UP 				VARCHAR2)
is
select 	distinct ose.organization_id_child organization_id
from   	per_org_structure_elements ose
where  	ose.org_structure_version_id +0  	= P_ORG_STRUCTURE_VERSION_ID
and	  	P_ROLL_UP						= 'Y'
connect by prior ose.organization_id_child 	= ose.organization_id_parent
and    	ose.org_structure_version_id  	= P_ORG_STRUCTURE_VERSION_ID
start with ose.organization_id_parent 		= P_ORGANIZATION_ID
and    	ose.org_structure_version_id  	= P_ORG_STRUCTURE_VERSION_ID
UNION
select 	P_ORGANIZATION_ID organization_id
from		dual
where	P_ROLL_UP                          = 'Y'
UNION
select 	P_ORGANIZATION_ID organization_id
from		dual
where	P_ROLL_UP                          = 'N';

--Bug :2508617
--Ghanshyam
--Modified Cursor to remove the join to HR_ORGANIZATION_INFORMATION
--to return all Org from Org Hierarchy belonging to specified region
cursor get_region_organizations
( P_BUSINESS_GROUP_ID NUMBER
 ,P_REPORT_YEAR       NUMBER
 ,P_REGION            VARCHAR2)
is
SELECT distinct POU.ORGANIZATION_ID organization_id
FROM PER_ORGANIZATION_UNITS POU
WHERE POU.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
AND POU.ORGANIZATION_ID = HR_NL_ORG_INFO.Check_Org_In_Region(POU.ORGANIZATION_ID,P_REGION)
AND TO_NUMBER(TO_CHAR(POU.DATE_FROM,'YYYY'))<= P_REPORT_YEAR
AND TO_NUMBER(TO_CHAR(NVL(POU.DATE_TO,SYSDATE),'YYYY')) >= P_REPORT_YEAR;


BEGIN

IF P_REGION IS NULL THEN

for org_structure_version_rec in get_org_structure_version
(P_ORGANIZATION_STRUCTURE_ID
,P_REPORT_YEAR)
loop

	for org_structure_element_rec in get_org_structure_element
		(org_structure_version_rec.org_structure_version_id
		,P_TOP_ORGANIZATION_ID
		,P_ORGANIZATION_STRUCTURE_ID)
	loop


HQOrgData(org_structure_element_rec.organization_id).total		        := 0;
HQOrgData(org_structure_element_rec.organization_id).ls_total 		    := 0;
HQOrgData(org_structure_element_rec.organization_id).acht_total	        := 0;
HQOrgData(org_structure_element_rec.organization_id).full_time 	        := 0;
HQOrgData(org_structure_element_rec.organization_id).acht_full_time  	:= 0;
HQOrgData(org_structure_element_rec.organization_id).part_time  		:= 0;
HQOrgData(org_structure_element_rec.organization_id).acht_part_time	    := 0;
HQOrgData(org_structure_element_rec.organization_id).total_hired		:= 0;
HQOrgData(org_structure_element_rec.organization_id).acht_hired  		:= 0;
HQOrgData(org_structure_element_rec.organization_id).terminated		    := 0;
HQOrgData(org_structure_element_rec.organization_id).acht_terminated	:= 0;
HQOrgData(org_structure_element_rec.organization_id).current_total		:= 0;
HQOrgData(org_structure_element_rec.organization_id).last_acht_total	:= 0;
HQOrgData(org_structure_element_rec.organization_id).last_perc_acht	    := 0;
HQOrgData(org_structure_element_rec.organization_id).perc_acht			:= 0;
HQOrgData(org_structure_element_rec.organization_id).perc_full_time	    := 0;
HQOrgData(org_structure_element_rec.organization_id).perc_acht_ftime	:= 0;
HQOrgData(org_structure_element_rec.organization_id).perc_part_time	    := 0;
HQOrgData(org_structure_element_rec.organization_id).perc_acht_ptime	:= 0;
HQOrgData(org_structure_element_rec.organization_id).perc_acht_hired	:= 0;
HQOrgData(org_structure_element_rec.organization_id).perc_acht_term	    := 0;

if (org_structure_element_rec.organization_id = p_top_organization_id) then
l_roll_up := 'N';
else
l_roll_up := p_roll_up;
end if;

    for org_rec in get_organizations
	( org_structure_version_rec.org_structure_version_id -- P_ORG_STRUCTURE_VERSION_ID
	, org_structure_element_rec.organization_id -- P_ORGANIZATION_ID
	, l_roll_up)
	loop

calculate_values(P_REPORT_YEAR
		, org_rec.organization_id
		, P_BUSINESS_GROUP_ID
		, org_structure_element_rec.organization_id);


end loop; -- get_organizations

if(HQOrgData(org_structure_element_rec.organization_id).current_total > 0) then

HQOrgData(org_structure_element_rec.organization_id).perc_full_time	    := 100 * HQOrgData(org_structure_element_rec.organization_id).full_time	/HQOrgData(org_structure_element_rec.organization_id).current_total;
HQOrgData(org_structure_element_rec.organization_id).perc_part_time	    := 100 * HQOrgData(org_structure_element_rec.organization_id).part_time	/HQOrgData(org_structure_element_rec.organization_id).current_total;
HQOrgData(org_structure_element_rec.organization_id).perc_acht	        := 100 * HQOrgData(org_structure_element_rec.organization_id).acht_total	/HQOrgData(org_structure_element_rec.organization_id).current_total;
end if;
if(HQOrgData(org_structure_element_rec.organization_id).part_time > 0) then
HQOrgData(org_structure_element_rec.organization_id).perc_acht_ptime	:= 100 * HQOrgData(org_structure_element_rec.organization_id).acht_part_time	/HQOrgData(org_structure_element_rec.organization_id).part_time;
end if;
if(HQOrgData(org_structure_element_rec.organization_id).full_time > 0) then
HQOrgData(org_structure_element_rec.organization_id).perc_acht_ftime	:= 100 * HQOrgData(org_structure_element_rec.organization_id).acht_full_time	/HQOrgData(org_structure_element_rec.organization_id).full_time;
end if;
if(HQOrgData(org_structure_element_rec.organization_id).total_hired > 0) then
HQOrgData(org_structure_element_rec.organization_id).perc_acht_hired	:= 100 * HQOrgData(org_structure_element_rec.organization_id).acht_hired	/HQOrgData(org_structure_element_rec.organization_id).total_hired;
end if;
if(HQOrgData(org_structure_element_rec.organization_id).terminated > 0) then
HQOrgData(org_structure_element_rec.organization_id).perc_acht_term	    := 100 * HQOrgData(org_structure_element_rec.organization_id).acht_terminated	/HQOrgData(org_structure_element_rec.organization_id).terminated;
end if;


end loop; -- get_org_structure_element


end loop;  -- get_org_structure_version

ELSE

for org_region_rec in get_region_organizations
		(P_BUSINESS_GROUP_ID
		,P_REPORT_YEAR
		,P_REGION)
loop

HQOrgData(org_region_rec.organization_id).total		        := 0;
HQOrgData(org_region_rec.organization_id).ls_total 		    := 0;
HQOrgData(org_region_rec.organization_id).acht_total	        := 0;
HQOrgData(org_region_rec.organization_id).full_time 	        := 0;
HQOrgData(org_region_rec.organization_id).acht_full_time  	:= 0;
HQOrgData(org_region_rec.organization_id).part_time  		:= 0;
HQOrgData(org_region_rec.organization_id).acht_part_time	    := 0;
HQOrgData(org_region_rec.organization_id).total_hired		:= 0;
HQOrgData(org_region_rec.organization_id).acht_hired  		:= 0;
HQOrgData(org_region_rec.organization_id).terminated		    := 0;
HQOrgData(org_region_rec.organization_id).acht_terminated	:= 0;
HQOrgData(org_region_rec.organization_id).current_total		:= 0;
HQOrgData(org_region_rec.organization_id).last_acht_total	:= 0;
HQOrgData(org_region_rec.organization_id).last_perc_acht	    := 0;
HQOrgData(org_region_rec.organization_id).perc_acht			:= 0;
HQOrgData(org_region_rec.organization_id).perc_full_time	    := 0;
HQOrgData(org_region_rec.organization_id).perc_acht_ftime	:= 0;
HQOrgData(org_region_rec.organization_id).perc_part_time	    := 0;
HQOrgData(org_region_rec.organization_id).perc_acht_ptime	:= 0;
HQOrgData(org_region_rec.organization_id).perc_acht_hired	:= 0;
HQOrgData(org_region_rec.organization_id).perc_acht_term	    := 0;

calculate_values
(   P_REPORT_YEAR
  , org_region_rec.organization_id
  , P_BUSINESS_GROUP_ID
  , org_region_rec.organization_id
);


end loop;
end if;

end populate_lawsamen_table;






procedure calculate_values
(   P_REPORT_YEAR                 IN NUMBER
  , P_ORGANIZATION_ID             IN NUMBER
  , P_BUSINESS_GROUP_ID           IN NUMBER
  , P_TOPORG_ID                   IN NUMBER
)is


cursor	get_assignment
( P_REPORT_YEAR				NUMBER
, P_ORGANIZATION_ID_CHILD	NUMBER
, P_BUSINESS_GROUP_ID		NUMBER
)
is

select     distinct paf.assignment_id assignment_id
              ,paf.person_id
from       per_all_assignments_f paf

where      paf.organization_id     =     p_organization_id_child
and        paf.business_group_id   =     P_BUSINESS_GROUP_ID
and        paf.assignment_type     =       'E'
and        paf.primary_flag        =       'Y'
and        to_number(to_char(nvl(paf.effective_start_date,sysdate),'YYYY')) <= P_REPORT_YEAR
and to_number(to_char(nvl(paf.effective_end_date,sysdate),'YYYY')) >= P_REPORT_YEAR;

cursor	get_people
( P_REPORT_YEAR				NUMBER
, P_BUSINESS_GROUP_ID		NUMBER
,P_PERSON_ID				NUMBER
)
is
select   distinct hr_nl_calc_target_group.get_target_group(p_person_id,
                   to_date('31/12/' ||to_char(P_REPORT_YEAR),'DD/MM/YYYY'))
                  allochth
       ,ppf1.per_information7 objection
from     per_people_f ppf1
where      ppf1.business_group_id   =      P_BUSINESS_GROUP_ID
and        to_number(to_char(nvl(ppf1.effective_start_date,sysdate),'YYYY')) <= P_REPORT_YEAR
and to_number(to_char(nvl(ppf1.effective_end_date,sysdate),'YYYY')) >= P_REPORT_YEAR
and ppf1.person_id  = P_PERSON_ID
and     to_date('31/12/' ||to_char(P_REPORT_YEAR),'DD/MM/YYYY') between ppf1.effective_start_date and ppf1.effective_end_date;




cursor	get_cur_assignment
( P_REPORT_YEAR				NUMBER
, P_ORGANIZATION_ID_CHILD	NUMBER
, P_BUSINESS_GROUP_ID		NUMBER
)
is
select  distinct paf.assignment_id assignment_id
            ,paf.effective_start_date start_date
	   ,paf.employment_category per_type
	   ,hr_nl_calc_target_group.get_target_group(ppf.person_id,
           to_date('31/12/' ||to_char(P_REPORT_YEAR),'DD/MM/YYYY')) allochth
	   ,ppf.per_information7 objection

from 	per_all_assignments_f paf
      , per_people_f ppf

where 	paf.organization_id 	= 	p_organization_id_child
and	paf.business_group_id	=	P_BUSINESS_GROUP_ID
and	paf.assignment_type	= 	'E'
and	paf.primary_flag	=	'Y'
and	to_number(to_char(nvl(paf.effective_start_date,sysdate),'YYYY')) <= P_REPORT_YEAR
and nvl(paf.effective_end_date,sysdate) >= to_date('31/12/' ||to_char(P_REPORT_YEAR),'DD/MM/YYYY')
and paf.person_id  = ppf.person_id
and ppf.BUSINESS_GROUP_ID = paf.business_group_id
and to_date('31/12/' ||to_char(P_REPORT_YEAR),'DD/MM/YYYY') between ppf.effective_start_date and ppf.effective_end_date;


cursor	get_terminations
( P_REPORT_YEAR				NUMBER
, P_ORGANIZATION_ID_CHILD	NUMBER
, P_BUSINESS_GROUP_ID		NUMBER
)
is
select  distinct  pos.leaving_reason leaving_reason
       ,paf.job_id job
	   ,paf.person_id

from    per_periods_of_service pos
	  , per_assignments_f 	 paf

where   to_number(to_char(nvl(pos.date_start,sysdate),'YYYY'))                  <= P_REPORT_YEAR
and     to_number(to_char(nvl(pos.actual_termination_date,sysdate+50000),'YYYY')) = P_REPORT_YEAR
and     pos.period_of_service_id        = paf.period_of_service_id
and	   paf.business_group_id	= P_BUSINESS_GROUP_ID
and	   paf.assignment_type	= 'E'
and	   paf.primary_flag		= 'Y'
and    paf.organization_id  	= P_ORGANIZATION_ID_CHILD;




l_total 			    number := 0;
l_ls_total 	 			number := 0;
l_cur_total             number := 0;
l_acht_total 			number := 0;
l_last_acht_total       number := 0;
l_full_time  			number := 0;
l_acht_full_time  		number := 0;
l_part_time  			number := 0;
l_acht_part_time  		number := 0;
l_total_hired  			number := 0;
l_acht_hired  			number := 0;
l_terminated  			number := 0;
l_acht_terminated  		number := 0;
l_last_perc_acht   		number := 0;
l_perc_acht        		number := 0;
l_perc_full_time   		number := 0;
l_perc_acht_ftime  		number := 0;
l_perc_part_time   		number := 0;
l_perc_acht_ptime  		number := 0;
l_perc_acht_hired  		number := 0;
l_perc_acht_term   		number := 0;

l_acht                  varchar2(1);
l_pertype     	 		varchar2(10);
l_movement_category		varchar2(30);
l_start_date            date;
l_end_date              date;



begin

for assgt_rec in get_assignment
		( P_REPORT_YEAR
		, P_ORGANIZATION_ID
		, P_BUSINESS_GROUP_ID)

loop
for people_rec in get_people
		( P_REPORT_YEAR
		, P_BUSINESS_GROUP_ID
		, assgt_rec.person_id)
		loop



IF 	(people_rec.allochth = 'Y')
then
IF (people_rec.objection <> 'Y')
then l_ls_total := l_ls_total +1;
end if;
end if;


l_movement_category := NULL;
l_start_date := '01-JAN-'||P_REPORT_YEAR;
l_end_date   := '31-DEC-'||P_REPORT_YEAR;

HR_PERSON_FLEX_LOGIC.GetMovementCategory(
		 p_organization_id        =>   P_ORGANIZATION_ID
		,p_assignment_id          =>   assgt_rec.assignment_id
		,p_period_start_date      =>   l_start_date
		,p_period_end_date        =>   l_end_date
		,p_movement_type          =>   'IN'
		,p_movement_category 	 =>   l_movement_category
		);

if l_movement_category = 'NEW_HIRE'
then	l_total_hired := l_total_hired + 1;
IF 	(people_rec.allochth = 'Y')
then l_acht_hired := l_acht_hired +1;
end if;
end if;

end loop;
l_total := l_total + 1;
end loop;

for assgt_cur_rec in get_cur_assignment
		( P_REPORT_YEAR
		, P_ORGANIZATION_ID
		, P_BUSINESS_GROUP_ID)

loop

l_cur_total := l_cur_total +1;

IF 	(assgt_cur_rec.allochth = 'Y')
then
l_acht_total := l_acht_total + 1;
end if;

IF 	(assgt_cur_rec.per_type = 'FR' or assgt_cur_rec.per_type = 'FT')
then l_full_time := l_full_time + 1;
IF 	(assgt_cur_rec.allochth = 'Y')
then l_acht_full_time := l_acht_full_time +1;
end if;
end if;


IF 	(assgt_cur_rec.per_type = 'PR' or assgt_cur_rec.per_type = 'PT')
then l_part_time := l_part_time + 1;
IF 	(assgt_cur_rec.allochth = 'Y')
then l_acht_part_time := l_acht_part_time +1;
end if;
end if;


end loop;

select  count(1)
into    l_last_acht_total
from 	per_all_assignments_f paf
      , per_people_f ppf

where 	paf.organization_id 	= 	P_ORGANIZATION_ID
and	    paf.business_group_id	=	P_BUSINESS_GROUP_ID
and	    paf.assignment_type	= 	'E'
and	    paf.primary_flag	=	'Y'
and	    to_number(to_char(nvl(paf.effective_start_date,sysdate),'YYYY')) <= P_REPORT_YEAR - 1
and     nvl(paf.effective_end_date,sysdate) >= to_date('31/12/' ||to_char(P_REPORT_YEAR - 1),'DD/MM/YYYY')
and     paf.person_id  = ppf.person_id
and     ppf.BUSINESS_GROUP_ID = paf.business_group_id
and     hr_nl_calc_target_group.get_target_group(ppf.person_id,
        to_date('31/12/' ||to_char(P_REPORT_YEAR - 1),'DD/MM/YYYY')) = 'Y'
and     to_date('31/12/' ||to_char(P_REPORT_YEAR - 1),'DD/MM/YYYY') between ppf.effective_start_date and ppf.effective_end_date;



if (l_last_acht_total > 0) then
l_last_perc_acht  := 100 * (l_acht_total - l_last_acht_total) / l_last_acht_total;
end if;
if (l_cur_total > 0) then
l_perc_acht       := 100 * (l_acht_total/l_cur_total) ;
l_perc_full_time  := 100 * (l_full_time/l_cur_total);
l_perc_part_time  := 100 * (l_part_time/l_cur_total);
end if;
if (l_part_time > 0) then
l_perc_acht_ptime := 100 * (l_acht_part_time/l_part_time);
end if;
if (l_full_time > 0) then
l_perc_acht_ftime := 100 * (l_acht_full_time/l_full_time);
end if;
if (l_total_hired > 0) then
l_perc_acht_hired := 100 * (l_acht_hired/l_total_hired);
end if;



	HQOrgData(P_TOPORG_ID).full_time :=
	HQOrgData(P_TOPORG_ID).full_time + nvl(l_full_time,0);
	HQOrgData(P_TOPORG_ID).acht_full_time :=
	HQOrgData(P_TOPORG_ID).acht_full_time + nvl(l_acht_full_time,0);
	HQOrgData(P_TOPORG_ID).part_time :=
	HQOrgData(P_TOPORG_ID).part_time + nvl(l_part_time,0);
	HQOrgData(P_TOPORG_ID).acht_part_time :=
	HQOrgData(P_TOPORG_ID).acht_part_time + nvl(l_acht_part_time,0);
	HQOrgData(P_TOPORG_ID).ls_total :=
	HQOrgData(P_TOPORG_ID).ls_total + nvl(l_ls_total,0);
	HQOrgData(P_TOPORG_ID).acht_total :=
	HQOrgData(P_TOPORG_ID).acht_total + nvl(l_acht_total,0);
	HQOrgData(P_TOPORG_ID).total :=
	HQOrgData(P_TOPORG_ID).total + nvl(l_total,0);
	HQOrgData(P_TOPORG_ID).total_hired :=
	HQOrgData(P_TOPORG_ID).total_hired + nvl(l_total_hired,0);
	HQOrgData(P_TOPORG_ID).acht_hired :=
	HQOrgData(P_TOPORG_ID).acht_hired + nvl(l_acht_hired,0);
    HQOrgData(P_TOPORG_ID).current_total :=
	HQOrgData(P_TOPORG_ID).current_total + nvl(l_cur_total,0);
	HQOrgData(P_TOPORG_ID).last_acht_total :=
	HQOrgData(P_TOPORG_ID).last_acht_total + nvl(l_last_acht_total,0);
	HQOrgData(P_TOPORG_ID).last_perc_acht :=
	HQOrgData(P_TOPORG_ID).last_perc_acht + nvl(l_last_perc_acht,0);
	HQOrgData(P_TOPORG_ID).perc_acht			:=
	HQOrgData(P_TOPORG_ID).perc_acht + nvl(l_perc_acht,0);
	HQOrgData(P_TOPORG_ID).perc_full_time	:=
	HQOrgData(P_TOPORG_ID).perc_full_time + nvl(l_perc_full_time,0);
	HQOrgData(P_TOPORG_ID).perc_acht_ftime	:=
	HQOrgData(P_TOPORG_ID).perc_acht_ftime + nvl(l_perc_acht_ftime,0);
	HQOrgData(P_TOPORG_ID).perc_part_time	:=
	HQOrgData(P_TOPORG_ID).perc_part_time + nvl(l_perc_part_time,0);
	HQOrgData(P_TOPORG_ID).perc_acht_ptime	:=
	HQOrgData(P_TOPORG_ID).perc_acht_ptime + nvl(l_perc_acht_ptime,0);
	HQOrgData(P_TOPORG_ID).perc_acht_hired	:=
	HQOrgData(P_TOPORG_ID).perc_acht_hired +nvl(l_perc_acht_hired,0);





for term_rec in get_terminations
		( P_REPORT_YEAR
		, P_ORGANIZATION_ID
		, P_BUSINESS_GROUP_ID)

loop -- get_terminations

l_terminated := l_terminated + 1;

select hr_nl_calc_target_group.get_target_group(ppf.person_id,
       to_date('31/12/'||to_char(P_REPORT_YEAR),'DD/MM/YYYY')) allochth
into l_acht
from per_people_f ppf
where ppf.person_id = term_rec.person_id
and     to_date('31/12/' ||to_char(P_REPORT_YEAR),'DD/MM/YYYY') between ppf.effective_start_date and ppf.effective_end_date;



IF 	(l_acht = 'Y')
then l_acht_terminated := l_acht_terminated +1;
end if;

end loop;

if (l_terminated > 0) then
l_perc_acht_term  := 100 * (l_acht_terminated/l_terminated);
end if;

	HQOrgData(P_TOPORG_ID).terminated :=
	HQOrgData(P_TOPORG_ID).terminated + nvl(l_terminated,0);
    HQOrgData(P_TOPORG_ID).acht_terminated :=
	HQOrgData(P_TOPORG_ID).acht_terminated + nvl(l_acht_terminated,0);
	HQOrgData(P_TOPORG_ID).perc_acht_term	:=
	HQOrgData(P_TOPORG_ID).perc_acht_term + nvl(l_perc_acht_term,0);


end; -- end calculate_values


END HR_NL_LAW_SAMEN_REPORT;

/
