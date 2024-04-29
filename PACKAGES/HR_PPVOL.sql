--------------------------------------------------------
--  DDL for Package HR_PPVOL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PPVOL" AUTHID CURRENT_USER as
/* $Header: pyvpymnt.pkh 120.0 2006/03/06 04:27:55 pgongada noship $ */
--
/*
-- Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
/*
PRODUCT
    Oracle*Payroll
--
   NAME
      pyvpymnt.pkh
MODIFIED (DD-MON-YYYY)
    mwcallag   29-SEP-1993 - Cash analysis parameter removed, following change
                             to pay_org_payment_methods_f in CASE.
     WMcVeagh  19-mar-98    Change create or replace 'as' not 'is'
*/

--
--------------------------- ins_opm -----------------------------------
/*
NAME
  ins_opm
DESCRIPTION
  Function to insert an Org_payment_method.
NOTES
Called using...
--
opm_id := ins_opm(to_date(start,'DD-MON-YYYY'),
                  to_date(end,'DD-MON-YYYY'),
                  bg_id,
                  exa_id,
                  currency,
                  payment_type,
                  name);
--
if opm_id = 0 then
  --
  err_msg := 'Cannot insert OPM ' || name;
  hr_utility.raise_error(err_msg);
  --
end if;
*/
function ins_opm(effective_start_date  in date,
                 effective_end_date    in date,
                 p_business_group_id   in number,
                 external_account_id   in number,
                 currency_code         in varchar2,
                 payment_type_id       in number,
                 name                  in varchar2) return number;
--
--------------------------- ins_exa -----------------------------------
/*
NAME
  ins_exa
DESCRIPTION
  insert an external account
NOTES
  Called as...
  --
  account_id := ins_exa(territory);
  --
  if account_id = 0 then
    --
    err_msg := 'Error inserting account in territory ' || territory;
    hr_utility.raise_error(err_msg);
    --
  end if;
--
*/
--
function ins_exa(territory_code in varchar2) return number;
--
--------------------------- ins_pmu -----------------------------------
/*
NAME
  ins_pmu
DESCRIPTION
  Insert pay_method_usages
NOTES
  Called as
  --
  pmu := ins_pmu(to_date(start,'DD-MON-YYYY'),
                 to_date(end,'DD-MON-YYYY'),
                 payroll_id,
                 opm_id);
  --
  if pmu = 0 then
    --
    err_msg := 'Failed to insert PMU for payroll ' || payroll;
    err_msg := err_msg || ' and method ' ||method;
    hr_utility.raise_error(err_msg);
  --
  end if;
*/
--
function ins_pmu(start_date in date,
                 end_date in date,
                 payroll in number,
                 payment_method in number) return number;
--
--------------------------- ins_ppm -----------------------------------
/*
NAME
  ins_ppm
DESCRIPTION
  insert personal payment method
NOTES
  Call as...
  --
  ppm_id := ins_ppm(to_date(start,'DD-MON-YYYY'),
                    to_date(end,'DD-MON-YYYY'),
                    bg_id,
                    account,
                    assignment,
                    opm_id,
                    amount,
                    percentage,
                    priority);
  --
  if ppm_id = 0 then
    --
    err_msg := failed to insert PPM for OPM ' || opm_id;
    err_msg := err_msg || ' and Assignment ' || assignment;
    err_msg := err_msg || ' priority ' || priority;
    hr_utility.raise_error(err_msg);
*/
--
function ins_ppm(start_date in date,
                 end_date in date,
                 business_group_id in number,
                 external_account in number,
                 assignment_id in number,
                 opm_id in number,
                 amount in number,
                 percentage in number,
                 priority in number) return number;
--
--------------------------- ins_exr -----------------------------------
/*
NAME
  ins_exr
DESCRIPTION
  insert exchaneg rates to and from  two currencies
NOTES
  --
*/
--
function ins_exr(start_date in date,
                 end_date in date,
                 base_currency in varchar2,
                 other_currency in varchar2,
                 rate_type in varchar2 default 'Payroll',
                 rate in number,
                 inverse_rate in number) return number;
--
--------------------------- ins_ppa -----------------------------------
/*
NAME
  ins_ppa
DESCRIPTION
  insert payroll action
NOTES
  Fill in other params as required, but do not default!
*/
function ins_ppa(action_type varchar2,
                 business_group number,
                 consolidation_set number,
                 payroll number,
                 pop_status varchar2,
                 action_status varchar2,
                 action_date date,
                 parameters varchar2) return number;
--
--------------------------- ins_paa -----------------------------------
/*
NAME
  ins_paa
DESCRIPTION
  insert assignment_actions
NOTES
  --
*/
--
function ins_paa(assignment number,
                 payroll_action number,
                 status varchar2 default 'U',
                 chunk number default null,
                 sequence number default null,
                 pre_payment number default null,
                 serial_no varchar2 default null) return number;
--
--------------------------- ins_payroll -----------------------------------
/*
NAME
  ins_payroll
DESCRIPTION
  insert a payroll
NOTES
  Note that pay_db_pay_setup.create_payroll should be used.  This is just a
  temporary measure
*/
FUNCTION    ins_payroll(payroll_name               varchar2,
			number_of_years            number,
			period_type                varchar2,
			first_period_end_date      date,
			dflt_payment_method        number,
			pay_date_offset            number   default 0,
			direct_deposit_date_offset number   default 0,
			pay_advice_date_offset     number   default 0,
			cut_off_date_offset        number   default 0,
			consolidation_set          number,
			negative_pay_allowed_flag  varchar2 default 'N',
			organization               number default NULL,
			midpoint_offset            number   default 0,
			workload_shifting_level    varchar2 default 'N',
			effective_start_date       date,
			effective_end_date         date,
			business_group             number) RETURN number;
--
--------------------------- testpay -----------------------------------
/*
NAME
  testpay
DESCRIPTION
  Set up data for payments testing.
NOTES
  --
*/
procedure testpay(p_business_group in varchar2);
--
end hr_ppvol;

 

/
