--------------------------------------------------------
--  DDL for Package Body PER_PERHDCNT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERHDCNT_XMLP_PKG" AS
/* $Header: PERHDCNTB.pls 120.1 2007/12/06 11:27:00 amakrish noship $ */

function BeforeReport return boolean is

begin

--hr_standard.event('BEFORE REPORT');

insert into fnd_sessions
(session_id,effective_date)
values(userenv('SESSIONID'),sysdate);

/*srw.message('001','Start of Before Report Trigger');*/null;


    if P_WORKER_TYPE = 'C' then
     CP_TERM := 'PlacementEnd';
     CP_TERM1:= '            ';
     CP_NH   := 'PlacementStart';
     CP_NH1  := '              ';
     CP_WORKER_TYPE := 'Head/FTE Count Detail Report (Contingent Worker)';
  elsif P_WORKER_TYPE = 'E' then
     CP_TERM := 'Terminations';
     CP_TERM1:= '            ';
     CP_NH   := 'NewHires';
     CP_NH1  := '              ';
     CP_WORKER_TYPE := 'Head/FTE Count Detail Report (Employees)';
  elsif P_WORKER_TYPE = 'B' then
     CP_TERM := 'Termination/';
     CP_TERM1:= 'PlacementEnd';
     CP_NH   := 'NewHire/';
     CP_NH1  := 'PlacementStart';
     CP_WORKER_TYPE := 'Head/FTE Count Detail Report (All Workers)';
  end if;




cp_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);

/*srw.message('002','Business Group = '||cp_business_group_name);*/null;


cp_top_org_name := hr_person_flex_logic.GetOrgAliasName(p_top_organization_id,sysdate);

/*srw.message('003','Organization Name = '||cp_top_org_name);*/null;


select name
into   cp_organization_hierarchy_name
from   per_organization_structures
where  organization_structure_id = P_ORGANIZATION_STRUCTURE_ID;

/*srw.message('004','Organization Name = '||cp_top_org_name);*/null;


 hr_head_count.populate_headcount_table(
	 P_BUSINESS_GROUP_ID
	,P_TOP_ORGANIZATION_ID
	,P_ORGANIZATION_STRUCTURE_ID
	,P_BUDGET
	,P_ROLL_UP
	,P_REPORT_DATE_FROM
	,P_REPORT_DATE_TO
	,P_REPORT_DATE
        ,P_INCLUDE_ASG_TYPE
        ,P_INCLUDE_TOP_ORG
        ,P_WORKER_TYPE
        ,P_DAYS_PRIOR_TO_END_DATE
	,P_JOB_CATEGORY			=> 'RG');


  return (TRUE);
end;

function cf_rev_vol_termformula(cs_rev_vol_term in number, Sumrev_start_valPerorg_structu in number) return number is
begin
if (cs_rev_vol_term = 0 or Sumrev_start_valPerorg_structu = 0)
 then
return(0);
else
  return(round(((cs_rev_vol_term/Sumrev_start_valPerorg_structu)*100),2));
end if;
end;

function cf_nonrev_vol_termformula(cs_nonrev_vol_term in number, Sumnonrev_start_valPerorg_stru in number) return number is
begin
if (cs_nonrev_vol_term = 0 or Sumnonrev_start_valPerorg_stru = 0)
 then
return(0);
else
  return(round(((cs_nonrev_vol_term/Sumnonrev_start_valPerorg_stru)*100),2));
end if;
end;

function cf_rev_invol_termformula(cs_nonrev_invol_term in number, Sumnonrev_start_valPerorg_stru in number) return number is
begin
if (cs_nonrev_invol_term = 0 or Sumnonrev_start_valPerorg_stru = 0)
 then
return(0);
else
  return(round(((cs_nonrev_invol_term/Sumnonrev_start_valPerorg_stru)*100),2));
end if;

end;

function cf_rev_invol_termformula0017(cs_rev_invol_term in number, Sumrev_start_valPerorg_structu in number) return number is
begin
if (cs_rev_invol_term = 0 or Sumrev_start_valPerorg_structu = 0)
 then
return(0);
else
  return(round((cs_rev_invol_term/Sumrev_start_valPerorg_structu),2)*100);
end if;
end;

function cf_rev_cur_termformula(cs_rev_cur_term in number, Sumrev_start_valPerorg_structu in number) return number is
begin
if (cs_rev_cur_term = 0 or Sumrev_start_valPerorg_structu = 0)
 then
return(0);
else
  return(round(((cs_rev_cur_term/Sumrev_start_valPerorg_structu)*100),2));
end if;

end;

function cf_nonrev_cur_termformula(cs_nonrev_cur_term in number, Sumnonrev_start_valPerorg_stru in number) return number is
begin
if (cs_nonrev_cur_term = 0 or Sumnonrev_start_valPerorg_stru = 0)
 then
return(0);
else
  return(round(((cs_nonrev_cur_term/Sumnonrev_start_valPerorg_stru)*100),2));
end if;

end;

function cf_rev_pct_changeformula(Sumrev_start_valPerorg_structu in number, Sumrev_end_valPerorg_Structure in number) return number is
begin

if (Sumrev_start_valPerorg_structu = 0 or Sumrev_end_valPerorg_Structure = 0)
 then
return(0);
else
  return(round((((Sumrev_end_valPerorg_structure - Sumrev_start_valPerorg_structu)/
         Sumrev_start_valPerorg_structu)*100),2));
end if;

end;

function cf_nonrev_pct_changeformula(Sumnonrev_start_valPerorg_stru in number, Sumnonrev_end_valPerorg_Struct in number) return number is
begin

if (Sumnonrev_start_valPerorg_stru = 0 or Sumnonrev_end_valPerorg_Struct = 0)
 then
return(0);
else
  return(round((((Sumnonrev_end_valPerorg_struct - Sumnonrev_start_valPerorg_stru)/
         Sumnonrev_start_valPerorg_stru)*100),2));
end if;

end;

function cf_days_betweenformula(date_to in date, date_from in date) return number is
begin
  return(date_to-date_from);
end;

function AfterReport return boolean is
begin

 -- hr_standard.event('AFTER REPORT');

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return CP_BUSINESS_GROUP_NAME;
	 END;
 Function CP_TOP_ORG_NAME_p return varchar2 is
	Begin
	 return CP_TOP_ORG_NAME;
	 END;
 Function CP_ORGANIZATION_HIERARCHY_NAM return varchar2 is
	Begin
	 return CP_ORGANIZATION_HIERARCHY_NAME;
	 END;
 Function CP_NULL_p return number is
	Begin
	 return CP_NULL;
	 END;
 Function CP_TERM_p return varchar2 is
	Begin
	 return CP_TERM;
	 END;
 Function CP_NH_p return varchar2 is
	Begin
	 return CP_NH;
	 END;
 Function CP_NH1_p return varchar2 is
	Begin
	 return CP_NH1;
	 END;
 Function CP_TERM1_p return varchar2 is
	Begin
	 return CP_TERM1;
	 END;
 Function CP_WORKER_TYPE_p return varchar2 is
	Begin
	 return CP_WORKER_TYPE;
	 END;
END PER_PERHDCNT_XMLP_PKG ;

/
