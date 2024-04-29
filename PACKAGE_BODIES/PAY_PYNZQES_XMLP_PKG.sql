--------------------------------------------------------
--  DDL for Package Body PAY_PYNZQES_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYNZQES_XMLP_PKG" AS
/* $Header: PYNZQESB.pls 120.0 2007/12/13 12:22:16 amakrish noship $ */

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

function BeforeReport return boolean is
begin
  cp_report_name             := 'PAYNZQES';
  cp_statistics_balance_name := 'Statistics NZ ';
  cp_balance_dimension       := '_ASG_PTD';
  cp_payout_balance_name     := 'Payout';
  cp_hours_balance_name      := 'Hours';
  cp_application_id          := 800;
  cp_week_hours              := 30;
  cp_week_frequency          := 'Week';

  /*srw.user_exit('FND SRWINIT');*/null;

  return (TRUE);
end;

function CF_legislation_codeFormula return VARCHAR2 is

  v_legislation_code    hr_organization_information.org_information9%type := null;

  cursor legislation_code
    (c_business_group_id hr_organization_information.organization_id%type) is

  select org_information9
  from   hr_organization_information
  where  organization_id  = c_business_group_id
  and    org_information9 is not null;
begin
  open legislation_code (p_business_group_id);
  fetch legislation_code into v_legislation_code;
  close legislation_code;

  return v_legislation_code;
end;

function CP_report_nameFormula return VARCHAR2 is
begin
  return ('PAYNZREC');
end;

function CP_statistics_balance_nameForm return VARCHAR2 is
begin
  return 'Statistics NZ ';
end;

function CP_balance_dimensionFormula return VARCHAR2 is
begin
  return '_ASG_PTD';
end;

function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2 is

  v_currency_code    fnd_currencies.currency_code%type;
  v_format_mask      varchar2(100) := null;
  v_field_length     number(3)     := 15;

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

function CP_hours_balance_nameFormula return VARCHAR2 is
begin
  return 'Hours';
end;

function CP_payout_balance_nameFormula return VARCHAR2 is
begin
  return 'Payout';
end;

function CP_application_idFormula return Number is
begin
  return 800;
end;

function CP_week_frequencyFormula return Char is
begin
  return 'Week';
end;

function CP_week_hoursFormula return Number is
begin
  return 30;
end;

--Functions to refer Oracle report placeholders--

 Function CP_report_name_p return varchar2 is
	Begin
	 return CP_report_name;
	 END;
 Function CP_statistics_balance_name_p return varchar2 is
	Begin
	 return CP_statistics_balance_name;
	 END;
 Function CP_balance_dimension_p return varchar2 is
	Begin
	 return CP_balance_dimension;
	 END;
 Function CP_hours_balance_name_p return varchar2 is
	Begin
	 return CP_hours_balance_name;
	 END;
 Function CP_payout_balance_name_p return varchar2 is
	Begin
	 return CP_payout_balance_name;
	 END;
 Function CP_application_id_p return number is
	Begin
	 return CP_application_id;
	 END;
 Function CP_week_hours_p return number is
	Begin
	 return CP_week_hours;
	 END;
 Function CP_week_frequency_p return varchar2 is
	Begin
	 return CP_week_frequency;
	 END;
END PAY_PYNZQES_XMLP_PKG ;

/
