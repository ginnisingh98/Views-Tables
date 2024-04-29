--------------------------------------------------------
--  DDL for Package Body PAY_PYKRSSEL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYKRSSEL_XMLP_PKG" AS
/* $Header: PYKRSSELB.pls 120.0 2007/12/13 12:21:53 amakrish noship $ */

function BeforeReport return boolean is
begin
  /*srw.user_exit('FND SRWINIT');*/null;

 if p_selection_criteria = 'COST_CENTER' then
  p_parameter_name:= 'Cost Center';
  p_parameter_value := 'Cost_Center';
 elsif p_selection_criteria ='ESTABLISHMENT_ID' then
p_parameter_name:= 'Organization';
p_parameter_value := 'Establishment_name';
elsif p_selection_criteria ='GRADE' then
p_parameter_name:= 'Grade';
p_parameter_value := 'Grade_Name';
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
  select currency_code, name
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

function cf_average_sep_payformula(cs_sep_pay in number, cs_no_of_emp in number) return number is
l_avg_sep_pay number;
begin

IF (cs_no_of_emp<>0) THEN
  l_avg_sep_pay := cs_sep_pay / cs_no_of_emp;
  return l_avg_sep_pay ;
ELSE
return (0);
END IF;
end;

function cf_average_working_periodformu(cs_work_period in number, cs_no_of_emp in number) return number is
l_avg_working_period number;
begin
IF (cs_no_of_emp<>0) THEN
 l_avg_working_period := cs_work_period / cs_no_of_emp;
return l_avg_working_period;
ELSE
return(0);
END IF;
end;

function cf_end_of_reportformula(cs_average_Salary in number) return char is
begin
  if cs_average_Salary >0 then
   return 'End Of Report';
  end if;

 return 'No Data Found';
end;

function cf_average_payment_daysformula(cs_pay_days in number, cs_no_of_emp in number) return number is
l_avg_payment_days number;
begin
IF (cs_no_of_emp<>0) THEN
 l_avg_payment_days := cs_pay_days / cs_no_of_emp;
return l_avg_payment_days;
ELSE
return(0);
END IF;

end;

function AfterPForm return boolean is

begin

  return (TRUE);
end;

function CF_PERIOD_NAMEFormula return Char is
begin
   select period_name
   into p_period_name
  from per_time_periods
  where time_period_id=p_selection_date;
return p_period_name;

end;

--Functions to refer Oracle report placeholders--

 Function CP_unit_p return varchar2 is
	Begin
	 return CP_unit;
	 END;
END PAY_PYKRSSEL_XMLP_PKG ;

/
