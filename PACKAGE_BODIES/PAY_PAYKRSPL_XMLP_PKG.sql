--------------------------------------------------------
--  DDL for Package Body PAY_PAYKRSPL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYKRSPL_XMLP_PKG" AS
/* $Header: PAYKRSPLB.pls 120.0 2007/12/13 12:21:42 amakrish noship $ */

function BeforeReport return boolean is
begin
  /*srw.user_exit('FND SRWINIT');*/null;

  frame_counter  := 0;
  total          := 0;
  assignment_id  := 0;
  if p_sort_by = 'COST_CENTER' then
    p_selection_value := 'Cost_Center';
  elsif p_sort_by ='ESTABLISHMENT_ID' then
    p_selection_value := 'Establishment_name';
  elsif p_sort_by ='GRADE' then
    p_selection_value := 'Grade_Name';
  end if;
  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function CF_business_groupFormula return VARCHAR2 is
  v_business_group  hr_all_organization_units.name%type;

begin
  v_business_group := hr_reports.get_business_group(p_business_group_id);
  return v_business_group;
end;

function CF_legislation_codeFormula return VARCHAR2 is

  v_legislation_code    hr_organization_information.org_information9%type := null;

  cursor legislation_code
    (c_business_group_id hr_organization_information.organization_id%type) is

  select org_information9
  from   hr_organization_information
  where  organization_id  = c_business_group_id
  and    org_information9 is not null
  and    org_information_context = 'Business Group Information';
begin
  open legislation_code (p_business_group_id);
  fetch legislation_code into v_legislation_code;
  close legislation_code;

  return v_legislation_code;
end;

function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2 is

  v_currency_code    fnd_currencies.currency_code%type;
  v_format_mask      varchar2(100) := null;
  v_field_length     number(3)    := 14;

  cursor currency_format_mask
    (c_territory_code in fnd_currencies.issuing_territory_code%type) is
  select currency_code,name
  from   fnd_currencies_vl
  where  issuing_territory_code = c_territory_code;

begin
  open currency_format_mask (cf_legislation_code);
  fetch currency_format_mask into v_currency_code,cp_unit;
  close currency_format_mask;

  v_format_mask := fnd_currency.get_format_mask(v_currency_code, v_field_length);
  return v_format_mask;
end;

PROCEDURE set_currency_format_mask IS
BEGIN

  /*SRW.SET_FORMAT_MASK(CF_currency_format_mask);*/null;


END;

function P_BUSINESS_GROUP_IDValidTrigge return boolean is
begin
  return (TRUE);
end;

function CF_PERIOD_NAMEFormula return Char is
v_period_name varchar2(70);
begin
   select period_name
     into v_period_name
    from per_time_periods
   where time_period_id=p_selection_date;
return (v_period_name);
end;

function BetweenPage return boolean is
begin
  frame_counter:=0;
  total:=0;
  return (TRUE);
end;

function cf_average_salaryformula(average_salary_me in number, average_salary_ybon in number, average_salary_alr in number) return number is
begin
  return(average_salary_me + average_salary_ybon + average_salary_alr);
end;

function CF_DATE_FORMAT_MASKFormula return Char is
begin
  return('YYYY.MM.DD');
end;

function cf_page_totalformula(cs_total in number) return number is
begin
      return(cs_total - total);
end;

function cf_separation_payformula(separation_pay in number, liability_rate in varchar2) return number is
begin
    return(separation_pay * 100/liability_rate);
end;

function cf_format_working_periodformul(working_period in varchar2, proportion in number, assignment_id_1 in number) return char is
 l_working_period varchar2(10) := working_period;
 l_cost           number := proportion ;
 len              number :=0;
 l_year           number :=0;
 l_month          number :=0;
 p_month          varchar2(100);
 l_days           number :=0;
 invalid_format exception;
 begin
   len := length(l_working_period);
   if ( len = 4 and (working_period = to_char(to_date(working_period,'YYMM'),'YYMM')) ) then
     l_year   :=  to_number(substr(l_working_period,1,2)) * 12;
     l_month  :=  l_year + to_number(substr(l_working_period,3,2)) * 1;
     l_month  :=  round(l_month * l_cost);
     if l_month > 12 then
       l_year  :=   floor(l_month/12);
       l_month :=  mod(l_month,12);
       p_month := lpad(to_char(l_year),2,0)||lpad(to_char(l_month),2,0);
     else
       p_month := '00'||lpad(to_char(l_month),2,0);
     end if;
   elsif ( len = 6 and (working_period = to_char(to_date(working_period,'YYMMDD'),'YYMMDD')) ) then
     l_year   :=  to_number(substr(l_working_period,1,2)) * 365;
     l_month  :=  l_year + (to_number(substr(l_working_period,3,2)) * 30);
     l_days   :=  to_number(l_month) + to_number(substr(l_working_period,5,2));
     l_days   :=  round(l_days * l_cost);
       if (l_days < 365) then
         p_month := '00';
         l_month := round(l_days/365*12) ;
         l_days  := mod(l_days,30);
         p_month := p_month||(lpad(l_month,2,0))||(lpad(l_days,2,0));
       else
         l_year  := floor(l_days/365);
         l_month := floor(mod((l_days/365),l_year) * 12);
         l_days  := round(mod(mod((l_days/365),l_year) * 12,l_month) * 30);
         p_month := (lpad(l_year,2,0))||(lpad(l_month,2,0))||(lpad(l_days,2,0));
       end if;
  else
    return(null);
  end if;
  if proportion < 1 then
    return(p_month||'('||working_period||')');
  else
  	return(p_month);
  end if;
exception
  when others then
  if (assignment_id <> assignment_id_1) then
    /*srw.message(99999,'Invalid Working Period  '||working_period||' for assignment id '||assignment_id_1);*/null;

    assignment_id := assignment_id_1;
  end if;
    return(null);
end;

--Functions to refer Oracle report placeholders--

 Function CP_Unit_p return varchar2 is
	Begin
	 return CP_Unit;
	 END;
END PAY_PAYKRSPL_XMLP_PKG ;

/
