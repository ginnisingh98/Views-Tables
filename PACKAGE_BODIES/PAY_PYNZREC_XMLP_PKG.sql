--------------------------------------------------------
--  DDL for Package Body PAY_PYNZREC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYNZREC_XMLP_PKG" AS
/* $Header: PYNZRECB.pls 120.0 2007/12/13 12:22:29 amakrish noship $ */

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

function CF_payroll_run_displayFormula return VARCHAR2 is

  v_lookup_type    fnd_lookups.lookup_type%type := 'ACTION_TYPE';
  v_display        varchar2(100) := null;

  cursor payroll_run
    (c_payroll_action_id in pay_payroll_actions.payroll_action_id%type) is
  select pap.payroll_name                || ' - ' ||
         ptp.period_name                 || ' ('  ||
         fcl.meaning                     || ' '   ||
         to_char(ppa.display_run_number) || ')'   display
  from   pay_all_payrolls_f  pap,
         per_time_periods    ptp,
         pay_payroll_actions ppa,
         hr_lookups  fcl
  where  ppa.payroll_action_id = c_payroll_action_id
  and    pap.payroll_id        = ppa.payroll_id
  and    ppa.payroll_id        = ptp.payroll_id
  and    ptp.end_date  = ppa.date_earned
  and    fcl.lookup_type       = v_lookup_type
  and    fcl.lookup_code       = ppa.action_type;

begin
  open payroll_run (p_payroll_action_id);
  fetch payroll_run into v_display;
  close payroll_run;

  return v_display;
end;

function CP_input_value_nameFormula return VARCHAR2 is
begin
  return 'Pay Value';
end;

function CP_UOMFormula return VARCHAR2 is
begin
  return 'M';
end;

function BeforeReport return boolean is
begin
  cp_input_value_name := 'Pay Value';
  cp_uom              := 'M';
  cp_report_name      := 'PAYNZREC';

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

function CF_sort_order_displayFormula return VARCHAR2 is

  v_lookup_type    hr_lookups.lookup_type%type := 'NZ_REC_REPORT_SORT_BY';
  v_meaning        hr_lookups.meaning%type     := '';

  cursor lookup_meaning
    (c_lookup_type hr_lookups.lookup_type%type,
     c_lookup_code hr_lookups.lookup_code%type) is
    select meaning
    from   hr_lookups
    where  lookup_type = c_lookup_type
    and    lookup_code = c_lookup_code;

begin
  open lookup_meaning (v_lookup_type, p_sort_order);
  fetch lookup_meaning into v_meaning;
  close lookup_meaning;


  return v_meaning;
end;

function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2 is

  v_currency_code    fnd_currencies.currency_code%type;
  v_format_mask      varchar2(100) := null;
  v_field_length     number(3)    := 15;

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

function CP_report_nameFormula return VARCHAR2 is
begin
  return ('PAYNZREC');
end;

--Functions to refer Oracle report placeholders--

 Function CP_input_value_name_p return varchar2 is
	Begin
	 return CP_input_value_name;
	 END;
 Function CP_UOM_p return varchar2 is
	Begin
	 return CP_UOM;
	 END;
 Function CP_report_name_p return varchar2 is
	Begin
	 return CP_report_name;
	 END;
END PAY_PYNZREC_XMLP_PKG ;

/
