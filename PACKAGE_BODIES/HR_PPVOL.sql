--------------------------------------------------------
--  DDL for Package Body HR_PPVOL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PPVOL" as
/* $Header: pyvpymnt.pkb 120.0 2006/03/06 04:29:38 pgongada noship $ */
--
/*
-- Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
/*
PRODUCT
    Oracle*Payroll
--
   NAME
      pyvpymnt.pkb
MODIFIED (DD-MON-YYYY)
    mwcallag   29-SEP-1993 - Cash analysis parameter removed, following change
                             to pay_org_payment_methods_f in CASE.
    amills     06-DEC-1995 - Changed all date referencing to DDMMYYYY format
                             so that it can be translated.
    WMcVeagh   19-MAR-1998 - Change create or replace 'as' not 'is'
    tbattoo    09-APR-1999 -  changed pay_exchange_rates to use gl_daily_rates
    alogue     04-JUN-2001 - amend reference to gl_daily_rates to
                             utilise an index.
    mreid      03-OCT-2002 - Ensured call to create_balance_type passed params
    pgongada   25-NOV-2005 - Changed the ins_pmu function. Added dbdrv lines.
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
--opm_id := ins_opm(to_date(start_date,'DD-MM-YYYY'),
--                  to_date(end_date,'DD-MM-YYYY'),
--                  bg_id,
--                  exa_id,
--                  currency,
--                  payment_type,
--                  name);
--
*/
--
function ins_opm(effective_start_date  in date,
                 effective_end_date    in date,
                 p_business_group_id   in number,
                 external_account_id   in number,
                 currency_code         in varchar2,
                 payment_type_id       in number,
                 name                  in varchar2) return number is
method_id number(16);
defined_balance number(16);
legislation_code varchar2(30);
begin
--
-- Get the legislation code for the business group
--
select bg.legislation_code
into legislation_code
from per_business_groups bg
where bg.business_group_id = p_business_group_id;
--
-- Get the defined balance for payments
--
defined_balance := hr_payments.gen_balance(leg_code => legislation_code);
--
if defined_balance = 0 then
  --
  hr_utility.set_message(801,'HR_6390_PAYM_ILLEGAL_BALANCE');
  return 0;
  --
end if;
--
-- Get the ID of the new method
--
hr_utility.set_location('HR_PPVOL.ins_opm',1);
--
select pay_org_payment_methods_s.nextval
into   method_id
from   dual;
--
-- Now do the insert
--
hr_utility.set_location('HR_PPVOL.ins_opm',2);
--
insert into pay_org_payment_methods_f
(ORG_PAYMENT_METHOD_ID,
 EFFECTIVE_START_DATE,
 EFFECTIVE_END_DATE,
 BUSINESS_GROUP_ID,
 EXTERNAL_ACCOUNT_ID,
 CURRENCY_CODE,
 PAYMENT_TYPE_ID,
 ORG_PAYMENT_METHOD_NAME,
 DEFINED_BALANCE_ID)
values
(method_id,
 effective_start_date,
 effective_end_date,
 p_business_group_id,
 external_account_id,
 currency_code,
 payment_type_id,
 name,
 defined_balance);
--
insert into pay_org_payment_methods_f_tl
(ORG_PAYMENT_METHOD_ID,
 ORG_PAYMENT_METHOD_NAME,
 LANGUAGE,
 SOURCE_LANG)
values
(method_id,
 name,
 userenv('LANG'),
 userenv('LANG'));
--
return method_id;
--
end ins_opm;
--
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
--
*/
--
function ins_exa(territory_code in varchar2) return number is
account_id number(16);
begin
--
-- First get the UID
--
select pay_external_accounts_s.nextval
into   account_id
from   dual;
--
-- Now insert the new row
--
insert into pay_external_accounts(
 external_account_id,
 territory_code,
 id_flex_num,
 summary_flag,
 enabled_flag)
values(
 account_id,
 territory_code,
 1,
 'N',
 'Y');
--
return account_id;
--
end ins_exa;
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
  pmu := ins_pmu(to_date(start,'DD-MM-YYYY'),
                 to_date(end,'DD-MM-YYYY'),
                 payroll_id,
                 opm_id);
  --
*/
--
function ins_pmu(start_date in date,
                 end_date in date,
                 payroll in number,
                 payment_method in number) return number is


cursor csr_payroll_opmu is
     select opmu.effective_start_date,
	    opmu.effective_end_date,
        org_pay_method_usage_id
     from   pay_org_pay_method_usages_f opmu
     where  opmu.payroll_id = payroll
       and  opmu.org_payment_method_id = payment_method
       and  opmu.effective_start_date <= end_date
       and  opmu.effective_end_date   >= start_date
     order by opmu.effective_start_date
     for update;

pmu_id number(16);
existing boolean;
v_insert_record boolean := TRUE;
begin
--
-- First check the pmu isn't already there.
--

existing := false;
--
--Commented the below code because it's not creating valid payment methods
--correctly.
/*begin
select org_pay_method_usage_id
  into   pmu_id
  from   pay_org_pay_method_usages_f
  where  payroll_id = payroll
  and    org_payment_method_id = payment_method
  and    effective_start_date  < end_date
  and    effective_end_date > start_date;
  --
exception
  --
  when no_data_found then
    --
    existing := true;
  --
end;
--
if existing = false then
  --
  select pay_org_pay_method_usages_s.nextval
  into   pmu_id
  from sys.dual;
  --
  insert into pay_org_pay_method_usages_f
  (org_pay_method_usage_id,
   effective_start_date,
   effective_end_date,
   org_payment_method_id,
   payroll_id)
  values
  (pmu_id,
   start_date,
   end_date,
   payment_method,
   payroll);
  --
end if;
--
return pmu_id;*/

--
--This code works fine for all the cases.
 for v_opmu_rec in csr_payroll_opmu loop
--
     -- An existing opmu already represents the default so do nothing.
     -- current opmu     |------------------------------------|
     -- required opmu       |----------------------------|
     if v_opmu_rec.effective_start_date <= start_date and
	v_opmu_rec.effective_end_date   >= end_date then
--
       v_insert_record := FALSE;
       pmu_id := v_opmu_rec.org_pay_method_usage_id;
--
     -- opmu overlaps with start of required opmu so need to shorten it ie.
     -- current opmu     |--------|
     -- required opmu    .   |----------------------------|
     --                  .   .                            .
     -- adjust opmu      |--|.                            .
     -- insert new opmu      |----------------------------| (see below)
     elsif v_opmu_rec.effective_start_date < start_date then
--
       update pay_org_pay_method_usages_f opmu
       set    opmu.effective_end_date = start_date - 1
       where  current of csr_payroll_opmu;
--
     -- opmu overlaps with end of required opmu so need to shorten it ie.
     -- current opmu                                   |--------|
     -- required opmu        |----------------------------|     .
     --                      .                            .     .
     -- adjust opmu          .                            .|----|
     -- insert new opmu      |----------------------------| (see below)
     elsif v_opmu_rec.effective_end_date > end_date then
--
       update pay_org_pay_method_usages_f opmu
       set    opmu.effective_start_date = end_date + 1
       where  current of csr_payroll_opmu;
--
     -- opmu overlaps within required opmu so need to remove it ie.
     -- current opmu            |----)
     -- required opmu        |----------------------------|
     --                      .                            .
     -- remove opmu          .                            .
     -- insert new opmu      |----------------------------| (see below)
     else
--
       delete from pay_org_pay_method_usages_f
       where  current of csr_payroll_opmu;
--
     end if;

   end loop;
--
   if v_insert_record then
--
    select pay_org_pay_method_usages_s.nextval into pmu_id from sys.dual;
     -- Create opmu to represent the default payment method selected for the
     -- payroll.
     insert into pay_org_pay_method_usages_f
     (org_pay_method_usage_id,
      effective_start_date,
      effective_end_date,
      payroll_id,
      org_payment_method_id,
      last_update_date,
      last_updated_by,
      last_update_login,
      created_by,
      creation_date)
     values
     (pmu_id,
      start_date,
     end_date,
      payroll,
      payment_method,
      trunc(sysdate),
      0,
      0,
      0,
      trunc(sysdate));
--
   end if;
return pmu_id;
end ins_pmu;
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
  ppm_id := ins_ppm(to_date(start,'DD-MM-YYYY'),
                    to_date(end,'DD-MM-YYYY'),
                    bg_id,
                    account,
                    assignment,
                    opm_id,
                    amount,
                    percentage,
                    priority);
    --
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
                 priority in number) return number is
ppm_id number(16);
begin
--
select pay_personal_payment_methods_s.nextval
into   ppm_id
from   dual;
--
insert into pay_personal_payment_methods_f(
 personal_payment_method_id,
 effective_start_date,
 effective_end_date,
 business_group_id,
 external_account_id,
 assignment_id,
 org_payment_method_id,
 amount,
 percentage,
 priority)
values(
 ppm_id,
 start_date,
 end_date,
 business_group_id,
 external_account,
 assignment_id,
 opm_id,
 amount,
 percentage,
 priority);
--
return ppm_id;
--
end ins_ppm;
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
                 inverse_rate in number) return number is
exchange_rate number(16);
begin

      insert into gl_daily_rates_interface
         (from_currency,
          to_currency,
          from_conversion_date,
          to_conversion_date,
          user_conversion_type,
          conversion_rate,
          inverse_conversion_rate,
          mode_flag)
      VALUES (
          base_currency,
          other_currency,
          start_date ,
          end_date,
          rate_type,
          rate,
          inverse_rate,
          'I');

  --
  return exchange_rate;
  --
end ins_exr;
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
                 parameters varchar2) return number is
action_id number(16);
begin
  --
  select pay_payroll_actions_s.nextval
  into   action_id
  from   dual;
  --
  -- Now do the insert
  --
  insert into pay_payroll_actions(
  payroll_action_id,
  action_type,
  business_group_id,
  consolidation_set_id,
  payroll_id,
  action_population_status,
  action_status,
  effective_date,
  legislative_parameters)
  values(
  action_id,
  action_type,
  business_group,
  consolidation_set,
  payroll,
  pop_status,
  action_status,
  action_date,
  parameters);
  --
  return action_id;
  --
end ins_ppa;
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
                 serial_no varchar2 default null) return number is
action_id number(16);
begin
  --
  select pay_assignment_actions_s.nextval
  into   action_id
  from   dual;
  --
  insert into pay_assignment_actions(
  assignment_action_id,
  assignment_id,
  payroll_action_id,
  action_status,
  chunk_number,
  action_sequence,
  pre_payment_id,
  serial_number)
  values(
  action_id,
  assignment,
  payroll_action,
  status,
  chunk,
  sequence,
  pre_payment,
  serial_no);
  --
  return action_id;
  --
end ins_paa;
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
			business_group             number)
							   RETURN number is

payroll_id number(16);
begin
  --
  hr_utility.set_location('HR_PPVOL.ins_payroll',1);
  --
  select pay_payrolls_s.nextval
  into   payroll_id
  from   dual;
  --
  hr_utility.set_location('HR_PPVOL.ins_payroll',2);
  --
  insert into pay_payrolls_f
   (PAYROLL_ID,
    EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE,
    DEFAULT_PAYMENT_METHOD_ID,
    BUSINESS_GROUP_ID,
    CONSOLIDATION_SET_ID,
    ORGANIZATION_ID,
    PERIOD_TYPE,
    CUT_OFF_DATE_OFFSET,
    DIRECT_DEPOSIT_DATE_OFFSET,
    FIRST_PERIOD_END_DATE,
    MIDPOINT_OFFSET,
    NEGATIVE_PAY_ALLOWED_FLAG,
    NUMBER_OF_YEARS,
    PAY_ADVICE_DATE_OFFSET,
    PAY_DATE_OFFSET,
    PAYROLL_NAME,
    WORKLOAD_SHIFTING_LEVEL)
   values
   (payroll_id,
    effective_start_date,
    effective_end_date,
    dflt_payment_method,
    business_group,
    consolidation_set,
    nvl(organization,business_group),
    period_type,
    cut_off_date_offset,
    direct_deposit_date_offset,
    first_period_end_date,
    midpoint_offset,
    negative_pay_allowed_flag,
    number_of_years,
    pay_advice_date_offset,
    pay_date_offset,
    payroll_name,
    workload_shifting_level);
  --
  return payroll_id;
  --
end ins_payroll;
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
--
procedure testpay(p_business_group in varchar2) is
--
new_bg boolean;
input_bg_name varchar2(80);
business_group number;
name_prefix varchar2(20);
--
account1 number;
account2 number;
--
cash_type number;
check_type number;
cheque_type number;
nacs_type number;
--
pay_type number;
pay_dimension varchar2(80);
--
cash_opm1 number;
cash_opm2 number;
check_opm1 number;
check_opm2 number;
cheque_opm number;   -- NB This is paid in UKL not NVS
nacs_opm1 number;
nacs_opm2 number;
--
cset     number;
payroll1 number;
payroll2 number;
exchange_rate number;
--
person      number;
assignment1 number;
assignment2 number;
assignment3 number;
assignment4 number;
assignment5 number;
assignment6 number;
--
ppm1 number;
ppm2 number;
ppm3 number;
--
payroll_action number;
action1 number;
action2 number;
action3 number;
action4 number;
action5 number;
action6 number;
--
err_msg varchar2(80);
--
dummy number;
column_id number;
row_id number;
table_id number;
rate_type_found boolean := TRUE;


begin
  --
  input_bg_name := p_business_group;
  --
  -- Set up external accounts.  Two will suffice.
  -- NB No flex info initially.  Only here to keep DB correct.
  --
  account1 := ins_exa('NV');
  --
  account2 := ins_exa('NV');
  --
  -- Create a new business group to test in if named one doesn't exist.
  --
  new_bg := false;
  --
  begin
    --
    select business_group_id
    into   business_group
    from   per_organization_units
    where  name = input_bg_name;
    --
  exception
    --
    when no_data_found then
      --
      new_bg := true;
    --
  end;
  --
  if new_bg = true then
    --
    business_group := per_db_per_setup.create_business_group(p_group => 'Y',
                                       p_name => input_bg_name,
                                       p_short_name => 'PAYM',
                                       p_date_from => to_date('01-01-1990',
                                       'DD-MM-YYYY'),
                                       p_date_to => to_date('31-12-4712',
                                       'DD-MM-YYYY'),
                                       p_legislation_code => 'NV',
                                       p_currency_code => 'NVS');
    --
  end if;
--
-- set up exchange rates in user tables for this business group
--

      select c.user_column_id,
             r.user_row_id,
             t.user_table_id
      into   column_id,row_id,table_id
      from    pay_user_columns  C
              ,pay_user_rows_f R
              ,pay_user_tables T
      where t.user_table_name='EXCHANGE_RATE_TYPES'
      and   t.USER_ROW_TITLE='Processing Type'
      and   r.user_table_id=t.user_table_id
      and   c.user_table_id=t.user_table_id
      and   c.user_column_name='Conversion Rate Type'
      and   r.row_low_range_or_name='PAY';
--
--
      insert into pay_user_column_instances_f (
          user_column_instance_id,
          effective_start_date,
          effective_end_date,
          user_row_id,
          user_column_id,
          business_group_id,
          value)
      values (pay_user_column_instances_s.nextval,
              to_date('01-01-1990', 'DD-MM-YYYY'),
              to_date('31/12/4712','DD/MM/YYYY'),
              row_id,
              column_id,
              business_group,
              'Payroll');

  --
  -- All names prefixed by BGID for uniquness
  --
  name_prefix := 'paym ' || to_char(business_group) || ' ';
  --
  -- Now generate some OPM's (two of each type)
  -- First set up the payments balance.  Firs get the dimension.
  --
  select dimension_name
  into   pay_dimension
  from   pay_balance_dimensions
  where  payments_flag = 'Y'
  and legislation_code is NULL;
  --
  -- Now set up a balance type
  --
  pay_type := pay_db_pay_setup.create_balance_type(
                  p_balance_name     => name_prefix || 'Payments',
                  p_uom              => 'Money',
                  p_currency_code    => 'NVS',
                  p_reporting_name   => 'Payments',
                  p_business_group_name => input_bg_name,
                  p_legislation_code => 'NV');
  --
  -- Now insert the defined balance
  --
  pay_db_pay_setup.create_defined_balance(
                  p_balance_name        => name_prefix || 'Payments',
                  p_balance_dimension   => pay_dimension,
                  p_frce_ltst_balance_flag => 'Y',
                  p_business_group_name => input_bg_name,
                  p_legislation_code    => 'NV');
  --
  -- First do cash methods
  --
  select payment_type_id
  into   cash_type
  from   pay_payment_types
  where  payment_type_name = 'Cash';
  --
  -- Now insert the methods
  --
  cash_opm1 := hr_ppvol.ins_opm(to_date('01-01-1990','DD-MM-YYYY'),
                              to_date('31-12-4712','DD_MM-YYYY'),
                              business_group,
                              account1,
                              'NVS',
                              cash_type,
                              name_prefix || 'Cash OPM 1');
  --
  cash_opm2 := hr_ppvol.ins_opm(to_date('01-01-1990','DD-MM-YYYY'),
                              to_date('31-12-4712','DD_MM-YYYY'),
                              business_group,
                              account2,
                              'NVS',
                              cash_type,
                              name_prefix || 'Cash OPM 2');
  --
  -- Now do check methods
  --
  select payment_type_id
  into   check_type
  from   pay_payment_types
  where  payment_type_name = 'Check';
  --
  -- Now insert the methods
  --
  check_opm1 := hr_ppvol.ins_opm(to_date('01-01-1990','DD-MM-YYYY'),
                              to_date('31-12-4712','DD_MM-YYYY'),
                              business_group,
                              account1,
                              'NVS',
                              check_type,
                              name_prefix || 'Check OPM 1');
  --
  check_opm2 := hr_ppvol.ins_opm(to_date('01-01-1990','DD-MM-YYYY'),
                              to_date('31-12-4712','DD_MM-YYYY'),
                              business_group,
                              account2,
                              'NVS',
                              check_type,
                              name_prefix || 'Check OPM 2');
  --
  -- Now do NACS methods
  --
  select payment_type_id
  into   nacs_type
  from   pay_payment_types
  where  payment_type_name = 'NACS';
  --
  -- Now insert the methods
  --
  nacs_opm1 := hr_ppvol.ins_opm(to_date('01-01-1990','DD-MM-YYYY'),
                              to_date('31-12-4712','DD_MM-YYYY'),
                              business_group,
                              account1,
                              'NVS',
                              nacs_type,
                              name_prefix || 'NACS OPM 1');
  --
  nacs_opm2 := hr_ppvol.ins_opm(to_date('01-01-1990','DD-MM-YYYY'),
                              to_date('31-12-4712','DD_MM-YYYY'),
                              business_group,
                              account2,
                              'NVS',
                              nacs_type,
                              name_prefix || 'NACS OPM 2');
  --
  -- Now put in a cheque method paid in GBP
  --
  select payment_type_id
  into   cheque_type
  from   pay_payment_types
  where  payment_type_name = 'Cheque';
  --
  -- Now insert the methods
  --
  cheque_opm := hr_ppvol.ins_opm(to_date('01-01-1990','DD-MM-YYYY'),
                               to_date('31-12-4712','DD_MM-YYYY'),
                               business_group,
                               account1,
                               'GBP',
                               cheque_type,
                               name_prefix || 'Cheque OPM 1');
  --
  -- Now a couple of payrolls. (First a consolidation set)
  --
  cset := pay_db_pay_setup.create_consolidation_set(
            p_consolidation_set_name => name_prefix || 'Payments set',
            p_business_group_name    => input_bg_name);
  --
  payroll1 := hr_ppvol.ins_payroll(
                            payroll_name=>name_prefix || 'Paym Test Payroll',
                            number_of_years=>5,
                            period_type=>'Calendar Month',
                            first_period_end_date=>to_date('31-01-1990',
                                                              'DD-MM-YYYY'),
                            dflt_payment_method=>cash_opm1,
                            consolidation_set=>cset,
                            effective_start_date=>to_date('01-01-1990',
                                                              'DD-MM-YYYY'),
                            effective_end_date=>to_date('31-12-4712',
                                                              'DD-MM-YYYY'),
                            business_group=>business_group);
  --
  payroll2 := hr_ppvol.ins_payroll(
                            payroll_name=>name_prefix || 'Paym Dummy Payroll',
                            number_of_years=>5,
                            period_type=>'Calendar Month',
                            first_period_end_date=>to_date('31-01-1990',
                                                              'DD-MM-YYYY'),
                            dflt_payment_method=>cash_opm2,
                            consolidation_set=>cset,
                            effective_start_date=>to_date('01-01-1990',
                                                              'DD-MM-YYYY'),
                            effective_end_date=>to_date('31-12-4712',
                                                              'DD-MM-YYYY'),
                            business_group=>business_group);
  --
  -- Insert some exchange rates
  --

  begin
         select count(*)
         into dummy
         from gl_daily_rates
         where conversion_type = 'Payroll'
         and   from_currency = 'NVS'
         and   to_currency   = 'GBP';

         exception
           when no_data_found then
            rate_type_found := FALSE;
  end;

  if (rate_type_found = FALSE) then
        insert into gl_daily_conversion_types
           (CONVERSION_TYPE,
            USER_CONVERSION_TYPE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY)
        values (
            'Payroll',
            'Payroll',
           to_date('01-01-1990','DD-MM-YYYY'),
            0);
  end if;

  exchange_rate := ins_exr(to_date('01-01-1990','DD-MM-YYYY'),
                           to_date('31-12-1990','DD-MM-YYYY'),
                           'NVS',
                           'GBP',
                           'Payroll',
                           2,
		           0.5);
  exchange_rate := ins_exr(to_date('01-01-1991','DD-MM-YYYY'),
                           to_date('31-12-1991','DD-MM-YYYY'),
                           'NVS',
                           'GBP',
                           'Payroll',
                           2,
                           0.5);
  exchange_rate := ins_exr(to_date('01-01-1992','DD-MM-YYYY'),
                           to_date('31-12-1992','DD-MM-YYYY'),
                           'NVS',
                           'GBP',
                           'Payroll',
                           2,
                           0.5);
  exchange_rate := ins_exr(to_date('01-01-1993','DD-MM-YYYY'),
                           to_date('31-12-1993','DD-MM-YYYY'),
                           'NVS',
                           'GBP',
                           'Payroll',
                           2,
                           0.5);
  exchange_rate := ins_exr(to_date('01-01-1994','DD-MM-YYYY'),
                           to_date('31-12-1994','DD-MM-YYYY'),
                           'NVS',
                           'GBP',
                           'Payroll',
                           2,
                           0.5);
  exchange_rate := ins_exr(to_date('01-01-1995','DD-MM-YYYY'),
                           to_date('31-12-1995','DD-MM-YYYY'),
                           'NVS',
                           'GBP',
                           'Payroll',
                           2,
                           0.5);

  --
  --
  -- Now add people... For each employee created, add in some personal
  -- payment methods.  NB Have to find assignment number via a select.
  --
  person := per_db_per_additional.create_employee(
                  p_effective_start_date=>to_date('01-01-1990','DD-MM-YYYY'),
                  p_effective_end_date=>to_date('31-12-4712','DD-MM-YYYY'),
                  p_business_group=>input_bg_name,
                  p_last_name=>'Payments 1',
                  p_national_identifier=>'XXXXXXX1',
                  p_employee_number=> name_prefix || '-1',
                  p_payroll=>name_prefix || 'Paym Test Payroll',
                  p_date_of_birth=>sysdate-8000);
  --
  select assignment_id
  into   assignment1
  from   per_all_assignments_f
  where  person_id = person;
  --
  -- Now add people with personal payment methods
  --
  person := per_db_per_additional.create_employee(
                  p_effective_start_date=>to_date('01-01-1990','DD-MM-YYYY'),
                  p_effective_end_date=>to_date('31-12-4712','DD-MM-YYYY'),
                  p_business_group=>input_bg_name,
                  p_last_name=>'Payments 2',
                  p_national_identifier=>'XXXXXXX2',
                  p_employee_number=> name_prefix || '-2',
                  p_payroll=>name_prefix || 'Paym Test Payroll',
                  p_date_of_birth=>sysdate-8000);
  --
  -- Get the employee's assignment_id
  --
  select assignment_id
  into   assignment2
  from   per_all_assignments_f
  where  person_id = person;
  --
  -- Now insert the PPMs
  --
  ppm1 := ins_ppm(to_date('01-01-1990','DD-MM-YYYY'),
                  to_date('31-12-4712','DD-MM-YYYY'),
                  business_group,
                  null,
                  assignment2,
                  cash_opm1,
                  100,
                  null,
                  1);
  --
  ppm2 := ins_ppm(to_date('01-01-1990','DD-MM-YYYY'),
                  to_date('31-12-4712','DD-MM-YYYY'),
                  business_group,
                  null,
                  assignment2,
                  check_opm1,
                  400,
                  null,
                  2);
  --
  -- Third assignment, one (forgein) PPM (100%)
  --
  person := per_db_per_additional.create_employee(
                  p_effective_start_date=>to_date('01-01-1990','DD-MM-YYYY'),
                  p_effective_end_date=>to_date('31-12-4712','DD-MM-YYYY'),
                  p_business_group=>input_bg_name,
                  p_last_name=>'Payments 3',
                  p_national_identifier=>'XXXXXXX3',
                  p_employee_number=> name_prefix || '-3',
                  p_payroll=>name_prefix || 'Paym Test Payroll',
                  p_date_of_birth=>sysdate-8000);
  --
  -- Get the employee's assignment_id
  --
  select assignment_id
  into   assignment3
  from   per_all_assignments_f
  where  person_id = person;
  --
  -- Now insert the PPMs
  --
  ppm1 := ins_ppm(to_date('01-01-1990','DD-MM-YYYY'),
                  to_date('31-12-4712','DD-MM-YYYY'),
                  business_group,
                  null,
                  assignment3,
                  cheque_opm,
                  null,
                  100,
                  1);
  --
  -- Fourth assignment, two x percent add to 100
  --
  person := per_db_per_additional.create_employee(
                  p_effective_start_date=>to_date('01-01-1990','DD-MM-YYYY'),
                  p_effective_end_date=>to_date('31-12-4712','DD-MM-YYYY'),
                  p_business_group=>input_bg_name,
                  p_last_name=>'Payments 4',
                  p_national_identifier=>'XXXXXXX4',
                  p_employee_number=> name_prefix || '-4',
                  p_payroll=>name_prefix || 'Paym Test Payroll',
                  p_date_of_birth=>sysdate-8000);
  --
  -- Get the employee's assignment_id
  --
  select assignment_id
  into   assignment4
  from   per_all_assignments_f
  where  person_id = person;
  --
  -- Now insert the PPMs
  --
  ppm1 := ins_ppm(to_date('01-01-1990','DD-MM-YYYY'),
                  to_date('31-12-4712','DD-MM-YYYY'),
                  business_group,
                  null,
                  assignment4,
                  cash_opm1,
                  null,
                  40,
                  1);
  --
  ppm2 := ins_ppm(to_date('01-01-1990','DD-MM-YYYY'),
                  to_date('31-12-4712','DD-MM-YYYY'),
                  business_group,
                  null,
                  assignment4,
                  check_opm2,
                  null,
                  60,
                  2);
  --
  -- Fifth assignment: one amount, two percent add to 100
  --
  person := per_db_per_additional.create_employee(
                  p_effective_start_date=>to_date('01-01-1990','DD-MM-YYYY'),
                  p_effective_end_date=>to_date('31-12-4712','DD-MM-YYYY'),
                  p_business_group=>input_bg_name,
                  p_last_name=>'Payments 5',
                  p_national_identifier=>'XXXXXXX5',
                  p_employee_number=> name_prefix || '-5',
                  p_payroll=>name_prefix || 'Paym Test Payroll',
                  p_date_of_birth=>sysdate-8000);
  --
  -- Get the employee's assignment_id
  --
  select assignment_id
  into   assignment5
  from   per_all_assignments_f
  where  person_id = person;
  --
  -- Now insert the PPMs
  --
  ppm1 := ins_ppm(to_date('01-01-1990','DD-MM-YYYY'),
                  to_date('31-12-4712','DD-MM-YYYY'),
                  business_group,
                  null,
                  assignment5,
                  cash_opm2,
                  50,
                  null,
                  1);
  --
  ppm2 := ins_ppm(to_date('01-01-1990','DD-MM-YYYY'),
                  to_date('31-12-4712','DD-MM-YYYY'),
                  business_group,
                  null,
                  assignment5,
                  check_opm1,
                  null,
                  50,
                  2);
  --
  -- NB This is a forgein payment
  --
  ppm3 := ins_ppm(to_date('01-01-1990','DD-MM-YYYY'),
                  to_date('31-12-4712','DD-MM-YYYY'),
                  business_group,
                  null,
                  assignment5,
                  cheque_opm,
                  null,
                  50,
                  3);
  --
  --
  -- Last assignment, one percentage payment
  --
  person := per_db_per_additional.create_employee(
                  p_effective_start_date=>to_date('01-01-1990','DD-MM-YYYY'),
                  p_effective_end_date=>to_date('31-12-4712','DD-MM-YYYY'),
                  p_business_group=>input_bg_name,
                  p_last_name=>'Payments 6',
                  p_national_identifier=>'XXXXXXX6',
                  p_employee_number=> name_prefix || '-6',
                  p_payroll=>name_prefix || 'Paym Test Payroll',
                  p_date_of_birth=>sysdate-8000);
  --
  -- Get the employee's assignment_id
  --
  select assignment_id
  into   assignment6
  from   per_all_assignments_f
  where  person_id = person;
  --
  -- Now insert the PPMs
  --
  ppm1 := ins_ppm(to_date('01-01-1990','DD-MM-YYYY'),
                  to_date('31-12-4712','DD-MM-YYYY'),
                  business_group,
                  null,
                  assignment6,
                  check_opm2,
                  null,
                  40,
                  1);
  --
  -- Now populate a payroll action and two chunks (three assignments each) of
  -- assignment actions for the payments process to run off.  Chunk 1 will
  -- have asg1-3, while chunk2 will have asg 4-6.
  --
  payroll_action := hr_ppvol.ins_ppa(action_type=>'P',
                                   business_group=>business_group,
                                   consolidation_set=>cset,
                                   payroll=>payroll1,
                                   pop_status=>'C',
                                   action_status=>'U',
                                   action_date=>to_date('31-01-1990',
                                                                'DD-MM-YYYY'),
                                   parameters=>null);
  --
  -- Insert the first chunk
  --
  action1 := hr_ppvol.ins_paa(assignment=>assignment1,
                            payroll_action=>payroll_action,
                            chunk=>1);
  --
  action2 := hr_ppvol.ins_paa(assignment=>assignment2,
                            payroll_action=>payroll_action,
                            chunk=>1);
  --
  action3 := hr_ppvol.ins_paa(assignment=>assignment3,
                            payroll_action=>payroll_action,
                            chunk=>1);
  --
  -- Insert the second chunk
  --
  action4 := hr_ppvol.ins_paa(assignment=>assignment4,
                            payroll_action=>payroll_action,
                            chunk=>2);
  --
  action5 := hr_ppvol.ins_paa(assignment=>assignment5,
                            payroll_action=>payroll_action,
                            chunk=>2);
  --
  action6 := hr_ppvol.ins_paa(assignment=>assignment6,
                            payroll_action=>payroll_action,
                            chunk=>2);
  --
  -- End loading of standars pre-payments test data
  --
end;
--
end hr_ppvol;

/
