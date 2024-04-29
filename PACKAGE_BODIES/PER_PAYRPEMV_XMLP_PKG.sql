--------------------------------------------------------
--  DDL for Package Body PER_PAYRPEMV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PAYRPEMV_XMLP_PKG" AS
/* $Header: PAYRPEMVB.pls 120.1 2007/12/06 11:24:34 amakrish noship $ */

function BeforeReport return boolean is
begin

declare
  l_organization_structure_desc VARCHAR2(80);
  l_org_version_desc            NUMBER;
  l_version_start_date          DATE;
  l_version_end_date            DATE;
  l_organization_desc           VARCHAR2(240);
  l_organization_type           VARCHAR2(30);
  l_payroll_period              VARCHAR2(80);
  l_payroll_period_start_date   DATE;
  l_payroll_period_end_date     DATE;
  l_emp_det_param		VARCHAR2(80);


begin

 --null;

 --hr_standard.event('BEFORE REPORT');
P_DATE_FROM_T := to_char(P_DATE_FROM,'dd-mon-yyyy');
P_DATE_TO_T := to_char(P_DATE_TO,'dd-mon-yyyy');

 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);

if p_org_structure_version_id is not null then
 hr_reports.get_organization_hierarchy
  (null
  ,p_org_structure_version_id
  ,l_organization_structure_desc
  ,l_org_version_desc
  ,l_version_start_date
  ,l_version_end_date);

  c_org_structure_name := l_organization_structure_desc;
  c_version_number := l_org_version_desc;


end if;

if p_parent_organization_id is not null then

 hr_reports.get_organization
  (p_parent_organization_id
  ,l_organization_desc
  ,l_organization_type);

 c_parent_organization_name := l_organization_desc;


end if;

if p_payroll_id is not null then
 c_payroll_name :=
   hr_reports.get_payroll_name(p_session_date,p_payroll_id);

    p_payroll_matching :=
    ' and paf.payroll_id +0 = '|| to_char(p_payroll_id);

    p_payroll_matching2 :=
    ' and paf2.payroll_id +0 = '|| to_char(p_payroll_id);

    p_payroll_matching3 :=
    ' and paf3.payroll_id +0 = '|| to_char(p_payroll_id);

end if;

 if p_org_structure_version_id is not null
     and p_parent_organization_id is not null then


              p_org_matching :=
      ' and paf.organization_id in '||
      '(select to_char(pose.organization_id_child) '||
       'from per_org_structure_elements pose '||
       'connect by pose.organization_id_parent = '||
       'prior pose.organization_id_child '||
       'and pose.org_structure_version_id = '||
       to_char(p_org_structure_version_id) ||
      ' start with pose.organization_id_parent = '||
         to_char(p_parent_organization_id) ||
      ' and pose.org_structure_version_id = '||
       to_char(p_org_structure_version_id) ||
      ' union select ' ||''''||
       to_char(p_parent_organization_id) ||''''||
      ' from sys.dual) ';


     p_org_matching2 :=
      ' and paf2.organization_id in '||
      '(select to_char(pose.organization_id_child) '||
       'from per_org_structure_elements pose '||
       'connect by pose.organization_id_parent = '||
       'prior pose.organization_id_child '||
       'and pose.org_structure_version_id = '||
       to_char(p_org_structure_version_id) ||
      ' start with pose.organization_id_parent = '||
         to_char(p_parent_organization_id) ||
      ' and pose.org_structure_version_id = '||
       to_char(p_org_structure_version_id) ||
      ' union select ' ||''''||
       to_char(p_parent_organization_id) ||''''||
      ' from sys.dual) ';

     p_org_matching3 :=
      ' and paf3.organization_id in '||
      '(select to_char(pose.organization_id_child) '||
       'from per_org_structure_elements pose '||
       'connect by pose.organization_id_parent = '||
       'prior pose.organization_id_child '||
       'and pose.org_structure_version_id = '||
       to_char(p_org_structure_version_id) ||
      ' start with pose.organization_id_parent = '||
         to_char(p_parent_organization_id) ||
      ' and pose.org_structure_version_id = '||
       to_char(p_org_structure_version_id) ||
      ' union select ' ||''''||
       to_char(p_parent_organization_id) ||''''||
      ' from sys.dual) ';

 elsif
    p_parent_organization_id is not null then
       p_org_matching :=
        ' and paf.organization_id = ' ||
               to_char(p_parent_organization_id);

       p_org_matching2 :=
        ' and paf2.organization_id = ' ||
               to_char(p_parent_organization_id);

       p_org_matching3 :=
        ' and paf3.organization_id = ' ||
               to_char(p_parent_organization_id);

    elsif p_org_structure_version_id is not null then
	 p_org_matching :=
      ' and paf.organization_id in '||
 	'( select organization_id_child '||
	'from per_org_structure_elements '||
	'where org_structure_version_id = '||
	to_char(p_org_structure_version_id) ||
	' union '||
	'select distinct organization_id_parent '||
	'from per_org_structure_elements '||
	'where org_structure_version_id = '||
	to_char(p_org_structure_version_id) ||')';

	 p_org_matching2 :=
      ' and paf.organization_id in '||
 	'( select organization_id_child '||
	'from per_org_structure_elements '||
	'where org_structure_version_id = '||
	to_char(p_org_structure_version_id) ||
	' union '||
	'select distinct organization_id_parent '||
	'from per_org_structure_elements '||
	'where org_structure_version_id = '||
	to_char(p_org_structure_version_id) ||')';

	 p_org_matching3 :=
      ' and paf.organization_id in '||
 	'( select organization_id_child '||
	'from per_org_structure_elements '||
	'where org_structure_version_id = '||
	to_char(p_org_structure_version_id) ||
	' union '||
	'select distinct organization_id_parent '||
	'from per_org_structure_elements '||
	'where org_structure_version_id = '||
	to_char(p_org_structure_version_id) ||')';

 end if;

if p_payroll_period_id is not null then
 hr_reports.get_time_period(p_payroll_period_id,
                             l_payroll_period,
                             l_payroll_period_start_date,
                             l_payroll_period_end_date);

 c_payroll_period := l_payroll_period;









 p_dates_matching :=
	' and  to_date(''' || to_char(l_payroll_period_start_date, 'MMDDYYYY')  ||
        ''', ''MMDDYYYY'') between paf.effective_start_date and paf.effective_end_date ';

 p_dates_matching2 :=
        ' and to_date(''' || to_char(l_payroll_period_end_date, 'MMDDYYYY') ||
        ''', ''MMDDYYYY'') between paf.effective_start_date and paf.effective_end_date ';

 p_dates_matching3 :=
    	' between to_date(''' ||to_char(l_payroll_period_start_date, 'MMDDYYYY') ||
  	''', ''MMDDYYYY'') and to_date(''' || to_char(l_payroll_period_end_date, 'MMDDYYYY') || ''', ''MMDDYYYY'')';

 p_dates_matching4 :=
        'to_date(''' || to_char(l_payroll_period_start_date, 'MMDDYYYY') || ''', ''MMDDYYYY'')';

 p_dates_matching5 :=
        'to_date(''' || to_char(l_payroll_period_end_date, 'MMDDYYYY') || ''', ''MMDDYYYY'')';


	/*srw.message(1, 'String ->'||p_dates_matching);*/null;

	/*srw.message(2, 'String ->'||p_dates_matching2);*/null;

	/*srw.message(3, 'String ->'||p_dates_matching3);*/null;

	/*srw.message(4, 'String ->'||p_dates_matching4);*/null;

	/*srw.message(5, 'String ->'||p_dates_matching5);*/null;



elsif p_date_from is not null and p_date_to is not null then







 p_dates_matching :=
	' and to_date(''' || to_char(p_date_from, 'MMDDYYYY') ||
        ''', ''MMDDYYYY'') between paf.effective_start_date and paf.effective_end_date ';

 p_dates_matching2 :=
        ' and to_date(''' || to_char(p_date_to, 'MMDDYYYY') ||
        ''', ''MMDDYYYY'') between paf.effective_start_date and paf.effective_end_date ';

 p_dates_matching3:=
    	' between to_date(''' ||to_char(p_date_from, 'MMDDYYYY') ||
  	''', ''MMDDYYYY'') and to_date(''' || to_char(p_date_to, 'MMDDYYYY') || ''', ''MMDDYYYY'')';

 p_dates_matching4 :=
       'to_date(''' || to_char(p_date_from, 'MMDDYYYY') || ''', ''MMDDYYYY'')';

 p_dates_matching5 :=
       'to_date(''' || to_char(p_date_to, 'MMDDYYYY') || ''', ''MMDDYYYY'')';

	/*srw.message(11, 'String ->'||p_dates_matching);*/null;

	/*srw.message(22, 'String ->'||p_dates_matching2);*/null;

	/*srw.message(33, 'String ->'||p_dates_matching3);*/null;

	/*srw.message(44, 'String ->'||p_dates_matching4);*/null;

	/*srw.message(55, 'String ->'||p_dates_matching5);*/null;



elsif p_date_from is not null then

  p_dates_matching3 := ' >= to_date(''' ||to_char(p_date_from, 'MMDDYYYY') || ''', ''MMDDYYYY'')';

  p_dates_matching := 'and paf.effective_start_date >= to_date(''' ||to_char(p_date_from, 'MMDDYYYY') || ''', ''MMDDYYYY'')';


elsif p_date_to is not null then

  p_dates_matching2 :=
        'and paf.effective_start_date <= to_date(''' || to_char(p_date_to, 'MMDDYYYY') ||''', ''MMDDYYYY'')';


  p_dates_matching3 := ' <= to_date(''' ||to_char(p_date_to, 'MMDDYYYY') || ''', ''MMDDYYYY'')';

end if;

if upper(p_employee_detail) = 'S' then
  p_emp_ord_clause := null;
elsif upper(p_employee_detail) = 'A' then
    p_emp_ord_clause :='ORDER BY 1,3';

elsif upper(p_employee_detail) = 'E' then
  p_emp_ord_clause := 'ORDER BY 1,2';

end if;
	/*srw.message(77, 'Order clause: '||p_emp_ord_clause);*/null;


begin
select	hrl.meaning
into	l_emp_det_param
from	hr_lookups hrl
where	p_employee_detail = hrl.lookup_code
and	hrl.lookup_type = 'PAYRPEMV_EMP_DET';

exception
when no_data_found then return null;
end;

	c_emp_det_param_disp := l_emp_det_param ;
begin
   select	hrl.meaning
   into	CP_WORKER_TYPE_DESC
   from	hr_lookups hrl
   where	p_worker_type = hrl.lookup_code
   and	hrl.lookup_type = 'HR_HEADCOUNT_WORKER_TYPE';
exception
when no_data_found then return CP_WORKER_TYPE_DESC = 'N/A';
end;

---Added for DT Fixes---
if P_ORG_MATCHING is null
then P_ORG_MATCHING := ' ';
end if;

if P_PAYROLL_MATCHING is null
then P_PAYROLL_MATCHING := ' ';
end if;

if P_ORG_MATCHING3 is null
then P_ORG_MATCHING3 := ' ';
end if;

if P_PAYROLL_MATCHING3 is null
then P_PAYROLL_MATCHING3 := ' '
;
end if;

if P_DATES_MATCHING is null
then P_DATES_MATCHING := ' ';
end if;

if P_EMP_ORD_CLAUSE is null
then P_EMP_ORD_CLAUSE := ' ';
end if;

if P_DATES_MATCHING2 is null
then P_DATES_MATCHING2 :=' ';
end if;

---End of DT Fixes------

end;
  return (TRUE);
end;

function c_net_changeformula(c_new_hires_count in number, c_transfers_in in number, c_terminations_count in number, c_transfers_out in number) return varchar2 is
begin

 return (to_char(    (c_new_hires_count
             + c_transfers_in)
           - (c_terminations_count
              + c_transfers_out)   , 'FMS999990'));
end;

function C_sql_traceFormula return VARCHAR2 is
begin

/*srw.do_sql('Alter session set sql_trace=true');*/null;

RETURN NULL; end;

function TRACEFormula return VARCHAR2 is
begin

if p_trace='Y' then
  /*SRW.DO_SQL('ALTER SESSION SET SQL_TRACE=TRUE');*/null;

end if;
RETURN NULL; end;

function cf_control_total_newhireformul(new_hire_asg_type in varchar2, assignment_type in varchar2) return number is
begin
  if new_hire_asg_type = 'E' then
   cp_total_emp_newhire := cp_total_emp_newhire + 1;
   end if;
  if assignment_type = 'C' then
   cp_total_cwk_newhire := cp_total_cwk_newhire + 1;
   end if;
  return 1;
end;

function cf_control_total_termformula(term_asg_type in varchar2) return number is
begin
  if term_asg_type = 'E' then
   cp_total_emp_term := cp_total_emp_term + 1;
   end if;
  if term_asg_type = 'C' then
   cp_total_cwk_term := cp_total_cwk_term + 1;
   end if;
  return 1;
end;

function cf_control_total_transinformul(trans_ex_asg_type in varchar2) return number is
begin
  if trans_ex_asg_type = 'E' then
   cp_total_emp_transin := cp_total_emp_transin + 1;
   end if;
  if trans_ex_asg_type = 'C' then
   cp_total_cwk_transin := cp_total_cwk_transin + 1;
   end if;
  return 1;
end;

function cf_control_total_transoutformu(transout_ex_asg_type in varchar2) return number is
begin
  if transout_ex_asg_type = 'E' then
   cp_total_emp_transout := cp_total_emp_transout+ 1;
   end if;
  if transout_ex_asg_type = 'C' then
   cp_total_cwk_transout := cp_total_cwk_transout + 1;
   end if;
  return 1;
end;

function AfterReport return boolean is
begin
  --hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
 Function C_ORG_STRUCTURE_NAME_p return varchar2 is
	Begin
	 return C_ORG_STRUCTURE_NAME;
	 END;
 Function C_VERSION_NUMBER_p return number is
	Begin
	 return C_VERSION_NUMBER;
	 END;
 Function C_PARENT_ORGANIZATION_NAME_p return varchar2 is
	Begin
	 return C_PARENT_ORGANIZATION_NAME;
	 END;
 Function C_PAYROLL_NAME_p return varchar2 is
	Begin
	 return C_PAYROLL_NAME;
	 END;
 Function C_PAYROLL_PERIOD_p return varchar2 is
	Begin
	 return C_PAYROLL_PERIOD;
	 END;
 Function C_emp_det_param_disp_p return varchar2 is
	Begin
	 return C_emp_det_param_disp;
	 END;
 Function CP_worker_type_desc_p return varchar2 is
	Begin
	 return CP_worker_type_desc;
	 END;
 Function CP_total_emp_newhire_p return number is
	Begin
	 return CP_total_emp_newhire;
	 END;
 Function CP_total_cwk_newhire_p return number is
	Begin
	 return CP_total_cwk_newhire;
	 END;
 Function CP_total_emp_term_p return number is
	Begin
	 return CP_total_emp_term;
	 END;
 Function CP_total_cwk_term_p return number is
	Begin
	 return CP_total_cwk_term;
	 END;
 Function CP_total_emp_transin_p return number is
	Begin
	 return CP_total_emp_transin;
	 END;
 Function CP_total_cwk_transin_p return number is
	Begin
	 return CP_total_cwk_transin;
	 END;
 Function CP_total_emp_transout_p return number is
	Begin
	 return CP_total_emp_transout;
	 END;
 Function CP_total_cwk_transout_p return number is
	Begin
	 return CP_total_cwk_transout;
	 END;
END PER_PAYRPEMV_XMLP_PKG ;

/
