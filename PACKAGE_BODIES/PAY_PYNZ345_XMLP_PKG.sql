--------------------------------------------------------
--  DDL for Package Body PAY_PYNZ345_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYNZ345_XMLP_PKG" AS
/* $Header: PYNZ345B.pls 120.0 2007/12/13 12:22:04 amakrish noship $ */

function BeforeReport return boolean is
 l_currency_code fnd_currencies.currency_code%TYPE;
 cursor c_currency_code is
   select currency_code
   from   fnd_currencies
   where  issuing_territory_code in
          (select i.org_information9
           from   hr_organization_information i
           where  i.organization_id  = p_registered_employer_id
           and    i.org_information_context = 'Business Group Information'
          );
begin
  /*srw.user_exit('FND SRWINIT');*/null;

  open  c_currency_code;
  fetch c_currency_code
  into  l_currency_code;
  if c_currency_code%found then
   cp_currency_code := '('||l_currency_code||')';
   cp_currency_format := fnd_currency.get_format_mask(l_currency_code, 15);
  end if;
  close c_currency_code;
  CP_PERIOD_END_DATE := pay_nz_tax.half_month_end(P_PERIOD_END_DATE);
  CP_PERIOD_START_DATE := pay_nz_tax.half_month_start(P_PERIOD_END_DATE);
  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function cf_total_deductionsformula(PAYE_DEDUCTIONS in number, CHILD_SUPPORT_DEDUCTIONS in number, STUDENT_LOAN_DEDUCTIONS in number, SSCWT_DEDUCTIONS in number) return number is
begin
 return
  nvl(PAYE_DEDUCTIONS,0)
 +nvl(CHILD_SUPPORT_DEDUCTIONS, 0)
 +nvl(STUDENT_LOAN_DEDUCTIONS, 0)
 +nvl(SSCWT_DEDUCTIONS, 0);
end;

function CF_business_groupFormula return Char is
begin
  return hr_reports.get_business_group(p_business_group_id);
end;

function CF_registered_employerFormula return VARCHAR2 is
 l_registered_employer hr_nz_tax_unit_v.name%type;
 cursor c_registered_employer is
   select name
   from   hr_nz_tax_unit_v
   where  business_group_id = p_business_group_id
   and    tax_unit_id = p_registered_employer_id;
begin
  open   c_registered_employer;
  fetch  c_registered_employer
  into   l_registered_employer;
  close  c_registered_employer;
  return l_registered_employer;
end;

--Functions to refer Oracle report placeholders--

 Function CP_CURRENCY_FORMAT_p return varchar2 is
	Begin
	 return CP_CURRENCY_FORMAT;
	 END;
 Function CP_CURRENCY_CODE_p return varchar2 is
	Begin
	 return CP_CURRENCY_CODE;
	 END;
 Function CP_PERIOD_START_DATE_p return date is
	Begin
	 return CP_PERIOD_START_DATE;
	 END;
 Function CP_PERIOD_END_DATE_p return date is
	Begin
	 return CP_PERIOD_END_DATE;
	 END;
END PAY_PYNZ345_XMLP_PKG ;

/
