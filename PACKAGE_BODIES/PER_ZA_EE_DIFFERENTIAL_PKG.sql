--------------------------------------------------------
--  DDL for Package Body PER_ZA_EE_DIFFERENTIAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_EE_DIFFERENTIAL_PKG" as
/* $Header: perzaeid.pkb 120.0.12010000.1 2009/12/08 06:30:12 rbabla noship $ */
/*
==============================================================================
MODIFICATION HISTORY

Name           Date        Version Bug     Text
-------------- ----------- ------- ------- -----------------------------
R Babla        24-Nov-2009   115.0 9112237  Initial Version
==============================================================================
*/

function beforereport return boolean
is
begin
  --    hr_utility.trace_on(NULL,'PERZAEID');
      hr_utility.set_location('Entered beforereport',10);
      hr_utility.set_location('P_REPORT_DATE:'||P_REPORT_DATE,10);
      hr_utility.set_location('P_BUSINESS_GROUP_ID:'||P_BUSINESS_GROUP_ID,10);
      hr_utility.set_location('P_LEGAL_ENTITY_ID:'||P_LEGAL_ENTITY_ID,10);
      hr_utility.set_location('P_SALARY_METHOD:'||P_SALARY_METHOD,10);
      per_za_employment_equity_pkg.init_g_cat_lev_new_table(P_REPORT_DATE,P_BUSINESS_GROUP_ID,P_LEGAL_ENTITY_ID,P_SALARY_METHOD);
      return TRUE;
end;

function afterreport return boolean
is
begin
      --reset_tables;
      return TRUE;
end;

function get_seta_classification
(
   p_business_group_id      in per_all_assignments_f.business_group_id%type,
   p_legal_entity_id        in per_assignment_extra_info.aei_information7%type default null
) return varchar2
is
  cursor seta_class (p_org_id in number) is
   Select org_information4 Seta_Classification
   From   hr_organization_information hoi
   Where  hoi.organization_id = p_org_id
   And   hoi.org_information_context = 'ZA_NQF_SETA_INFO';
begin
   for seta_rec in seta_class (p_legal_entity_id)
   loop
       return (seta_rec.Seta_Classification);
   end loop;

   for seta_rec1 in seta_class (p_business_group_id)
   loop
       return(seta_rec1.Seta_Classification);
   end loop;

  return (null);
end get_seta_classification;


FUNCTION get_total(p_employment_type IN VARCHAR2
                  ,p_emp_type varchar2
                  ,p_report_id varchar2
                  ,p_legal_entity_id NUMBER) RETURN NUMBER
IS
l_cnt number:=0;
BEGIN
if p_report_id not in ('EDF','EDFI') then
    select nvl(sum(decode(p_emp_type,'FA',FA,'FC',FC,'FI',FI,'FW',FW,'MA',MA,'MC',MC,'MI',MI,'MW',MW)),0)
    into l_cnt
    from per_za_employment_equity
    where legal_entity_id = p_legal_entity_id
    and report_id = p_report_id
    and employment_type=p_employment_type;
elsif p_emp_type = 'FF' then
    select nvl(sum(FA)+sum(FC)+sum(FI)+sum(FW),0)
    into l_cnt
    from per_za_employment_equity
    where legal_entity_id = p_legal_entity_id
    and report_id = p_report_id
    and employment_type=p_employment_type;
elsif p_emp_type = 'MF' then
    select nvl(sum(MA)+sum(MC)+sum(MI)+sum(MW),0)
    into l_cnt
    from per_za_employment_equity
    where legal_entity_id = p_legal_entity_id
    and report_id = p_report_id
    and employment_type=p_employment_type;
end if;
return l_cnt;
exception
when no_data_found then
   return 0;
END GET_TOTAL;


FUNCTION get_row_total(p_employment_type IN VARCHAR2
                      ,p_inc_num varchar2
		      ,p_legal_entity_id NUMBER) RETURN NUMBER
IS
l_cnt number;
begin
if p_inc_num = 'NUM' then
--Calculate the count of employees
    select nvl(SUM(TOTAL),0)
    into l_cnt
    from per_za_employment_equity
    where legal_entity_id = p_legal_entity_id
    and   report_id in ('ED','EDF')
    and employment_type=p_employment_type;
else
--Calculate the sum of employee income
    select nvl(SUM(TOTAL),0)
    into l_cnt
    from per_za_employment_equity
    where legal_entity_id = p_legal_entity_id
    and   report_id in ('EDI','EDFI')
    and employment_type=p_employment_type;
end if;
RETURN l_cnt;
end get_row_total;


end per_za_ee_differential_pkg; -- package body

/
