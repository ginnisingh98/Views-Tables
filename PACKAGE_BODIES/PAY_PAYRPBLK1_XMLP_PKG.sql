--------------------------------------------------------
--  DDL for Package Body PAY_PAYRPBLK1_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYRPBLK1_XMLP_PKG" AS
/* $Header: PAYRPBLK1B.pls 120.0 2008/01/11 07:06:48 srikrish noship $ */

function BeforeReport return boolean is

begin

  --hr_standard.event('BEFORE REPORT');


  if p_payroll_id is not null then
    cp_payroll_name := hr_reports.get_payroll_name(P_EFFECTIVE_DATE, P_PAYROLL_ID);
  end if;

    c_effective_date := fnd_date.date_to_displaydate(P_EFFECTIVE_DATE);
  LP_EFFECTIVE_DATE :=P_EFFECTIVE_DATE;
  return (TRUE);
end;

function AfterReport return boolean is
begin
    --hr_standard.event('AFTER REPORT');
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
  select currency_code
  from   fnd_currencies
  where  issuing_territory_code = c_territory_code;

begin
  open currency_format_mask (cf_legislation_code);
  fetch currency_format_mask into v_currency_code;
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

function CF_Q1_data_foundFormula return Number is
begin
  CP_Q1_NO_DATA_FOUND := 0;

  Return(1);
end;

function CF_Q2_data_foundFormula return Number is
begin
  CP_Q2_NO_DATA_FOUND := 0;
  Return(1);
end;

--Functions to refer Oracle report placeholders--

 Function CP_PAYROLL_NAME_p return varchar2 is
	Begin
	 return CP_PAYROLL_NAME;
	 END;
 Function CP_Q1_NO_DATA_FOUND_p return number is
	Begin
	 return CP_Q1_NO_DATA_FOUND;
	 END;
 Function CP_Q2_NO_DATA_FOUND_p return number is
	Begin
	 return CP_Q2_NO_DATA_FOUND;
	 END;
 Function C_EFFECTIVE_DATE_p return varchar2 is
	Begin
	 return C_EFFECTIVE_DATE;
	 END;
END PAY_PAYRPBLK1_XMLP_PKG ;

/
