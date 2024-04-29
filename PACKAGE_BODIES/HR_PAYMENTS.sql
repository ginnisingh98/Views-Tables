--------------------------------------------------------
--  DDL for Package Body HR_PAYMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PAYMENTS" as
/* $Header: pypaymnt.pkb 120.0 2005/05/29 07:16:45 appldev noship $ */
/*
 * ---------------------------------------------------------------------------
   Copyright (c) Oracle Corporation (UK) Ltd 1992.
   All Rights Reserved.
  --
  --
  PRODUCT
    Oracle*Payroll
  NAME
    hr_payments   (hrppm.pkb)
  NOTES
    per-payments procedures.  Used for validation of DDL on:
    PAY_PAYMENT_TYPES
    PAY_ORG_PAYMENT_METHODS
    PAY_ORG_PAY_METHOD_USAGES
    PAY_PERSONAL_PAYMENT_METHODS
  MODIFIED
    amcinnes          16-NOV-1992  Created with ppt_brui
    amcinnes          20-DEC-1992  Added all other payments procedures
    amcinnes          07-JAN-1993  GEN_BALANCE now called from forms
    amcinnes          11-JAN-1993  Corrected operation of gen balance
    amcinnes          21-JAN-1993  Changes for new standards
    amcinnes          14-JUN-1993  Changes for change to PPT that whoever
                                   changed it should have done.
                                   Removed all refs to formula/formula_id
    afrith            29-SEP-1993  Change gen-balance to use remuneration flag
    rneale	      20-JUN-1994  Added match_currency for use by PAYWSDPM.
    rfine	40.4  21-MAR-1995  Fixed fnd_message.set_name calls in
    rfine	40.5  22-MAR-1995  Changed check_pp so it now checks for
				   pre-payments after the date passed in only,
				   not 'on or after' that date. WWbug 264094.
    sdoshi     115.1  30-MAR-1999  Flexible Dates Conversion
    tbattoo    115.2  10-Jan-2001  Modified check_currency function.  Added
						     an nvl in the IF statement.
  --
 * ---------------------------------------------------------------------------
 */
--
/*--------------------------- validate_magnetic ------------------------------

NAME
  validate_magnetic
DESCRIPTION
  Validate business rules for pay_payment_types
NOTES
  Category is magnetic if this is called.
  Check pre-validation_requied flag is set.
  If pre-validation, check that the values and days are set.
*/
function validate_magnetic(validate in varchar2,
                           validation_days in number,
                           validation_value in varchar2) return boolean is
--
begin
  --
  hr_utility.set_location('HR_PAYMENTS.VALIDATE_MAGNETIC',1);
  --
  -- Check mand values for mag method are there.
  --
  if validate is null then
  --
    hr_utility.set_message(801,'HR_6227_PAYM_MAND_MAG_DETAILS');
    hr_utility.raise_error;
    return(false);
  --
  end if;
  --
  -- Check pre-validation flag is set
  --
  if validate = 'Y' then
    --
    -- Magnetic validation required. Days and values must be set
    --
    if validation_days is null or validation_value is null then
      --
      hr_utility.set_message(801,'HR_6228_PAYM_NO_VALIDATION');
      hr_utility.raise_error;
      return(false);
      --
    end if;
    --
  end if;
  --
  return(true);
  --
end validate_magnetic;
--
/*--------------------------- check_ok_default----------------------------------

NAME
  check_ok_default
DESCRIPTION
  Check the payment type is allowed as a default
NOTES
  CASH and CHECK allowed.
*/
function check_ok_default(category in varchar2) return boolean is
begin
  --
  hr_utility.set_location('HR_PAYMENTS.CHECK_DEFAULT',1);
  --
  if category = 'CA' or category = 'CH' then
    --
    return(true);
    --
  else
    --
    hr_utility.set_message(801,'HR_6229_PAYM_BAD_DEFAULT_TYPE');
    hr_utility.raise_error;
    return(false);
    --
  end if;
  --
end check_ok_default;
--
/*--------------------------- ppt_brui -----------------------------------
NAME
  ppt_brui
DESCRIPTION
  pay_payment_types trigger
NOTES
  Calls various validation routines on new/updated row
*/
procedure ppt_brui(allow_as_default in varchar2,
                   category in varchar2,
                   pre_validation_required in varchar2,
                   validation_days in number,
                   validation_value in varchar2) is
status boolean;
begin
  --
  if allow_as_default = 'Y' then
    --
    status := check_ok_default(category);
    --
  end if;
  --
  if category = 'MT' then
    --
    -- Mag Tape so do the required checks
    --
    status := validate_magnetic(pre_validation_required,
                                validation_days,
                                validation_value);
    --
  end if;
  --
end ppt_brui;
--------------------------- check_account -----------------------------------
/*
NAME
  Check_account
DESCRIPTION
  Checks that the OPM has an external account in the required territory.
NOTES
  If the payment type of the OPM requires an account in a certain terrritory
  then this must be checked.
  Returns true or false (with application error)
*/
function check_account(account in varchar2,
                       type in varchar2) return boolean is
required_territory varchar2(3);
actual_territory varchar2(3);
begin
  --
  -- One row each from EXA and PPT.
  --
  hr_utility.set_location('HR_PAYMENTS.CHECK_ACCOUNT',1);
  --
  select ppt.territory_code,
         exa.territory_code
  into   required_territory,
         actual_territory
  from   pay_payment_types ppt,
         pay_external_accounts exa
  where  exa.external_account_id = account
  and    ppt.payment_type_id = type;
  --
  -- Check that they are the same and generate an error if not
  --
  hr_utility.set_location('HR_PAYMENTS.CHECK_ACCOUNT',2);
  --
  if required_territory <> actual_territory then
    --
    hr_utility.set_message(801,'HR_6220_PAYM_INVALID_ACT');
    hr_utility.set_message_token('TERITORY',required_territory);
    hr_utility.raise_error;
    return(false);
    --
  else
    --
    return(true);
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    hr_utility.set_message(801,'HR_6230_PAYM_NO_ACCT_TYPE');
    hr_utility.raise_error;
    return(false);
    --
  --
end check_account;
--
--------------------------- check_currency -----------------------------------
/*
NAME
  Check_currency
DESCRIPTION
  Checks that the currency required by the type is met by the OPM
NOTES
  If the types of this OPM requires that payments be made in a specific
  currency, check that this is the case.
  Returns true or false (with application error)
*/
function check_currency(type in varchar2,
                        opm_currency in varchar2) return boolean is
required_currency varchar2(16);
begin
  --
  hr_utility.set_location('HR_PAYMENTS.CHECK_CURRENCY',1);
  --
  select ppt.currency_code
  into   required_currency
  from   pay_payment_types ppt
  where  ppt.payment_type_id = type;
  --
  -- Check that they are the same.  If not report the error
  --
  if nvl(required_currency,opm_currency) <> opm_currency then
    --
    hr_utility.set_message(801,'HR_6231_PAYM_INVALID_CURRENCY');
    hr_utility.set_message_token('CURRENCY',required_currency);
    hr_utility.raise_error;
    return(false);
    --
  else
    --
    return(true);
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    hr_utility.set_message(801,'HR_6232_PAYM_NO_TYPE');
    hr_utility.raise_error;
    return(false);
    --
  --
end check_currency;
--
---------------------------match_currency---------------------------------
/*
NAME
    match_currency
DESCRIPTION
    ensures the currency for the OPM matches that required by the balance
    type and the payment type.
NOTES
    Checks if the payment_type has a required currency and that the OPM's
    currency matches this via check_currency. Then ensures that the currency
    for the balance type matches this currency.
*/
procedure match_currency(type in varchar2,
                         opm_currency in varchar2,
                         def_balance in varchar2) is
bal_type varchar2(9);
bal_currency varchar2(16);
begin
 --
 hr_utility.set_location('HR_PAYMENTS.MATCH_CURRENCY',1);
 --
 if check_currency(type,opm_currency) then
 --
   select pdb.balance_type_id
   into bal_type
   from pay_defined_balances pdb
   where defined_balance_id = def_balance;
 --
   select pbt.currency_code
   into bal_currency
   from pay_balance_types pbt
   where balance_type_id = bal_type;
 --
   if opm_currency <> bal_currency then
     fnd_message.set_name('PAY','HR_7132_PAY_ORG_PAY_CURRENCY');
     fnd_message.raise_error;
   end if;
 --
 end if;
--
 exception
--
 when no_data_found then
   fnd_message.set_name('PAY','HR_7133_PAY_ORG_PAYM_NO_BAL');
   fnd_message.raise_error;
--
end match_currency;
--
--------------------------- gen_balance -----------------------------------
/*
NAME
  gen_balance
DESCRIPTION
  Generate the defined balance for pre-payments.
NOTES
  There will be one balance dimension which has the attribute payments_flag
  set to 'Y'. This is the 'payments dimesion.  There will be one defined
  balance with this balance dimension for each legislation.  This
  defined balance id must be inserted into the defined_balance_id column
  of the OPM.
  --
*/
function gen_balance(leg_code in varchar2) return number is
no_payments_balance exception;
defined_balance number(16);
begin
  --
  -- Get it then (if its there)
  --
  hr_utility.set_location('HR_PAYMENTS.GEN_BALANCE',1);
  --
  select pdb.defined_balance_id
  into   defined_balance
  from   pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
  where  pdb.legislation_code = leg_code
  and    pdb.business_group_id is null
  and    pdb.balance_dimension_id = pbd.balance_dimension_id
  and    pbt.balance_type_id = pdb.balance_type_id
  and    pbd.payments_flag = 'Y'
  and    pbt.assignment_remuneration_flag = 'Y';
  --
  -- Return the defined balance
  --
  return(defined_balance);
  --
exception
  --
  when no_data_found then
    --
    hr_utility.set_message(801,'HR_6233_PAYM_NO_PAY_BALANCE');
    hr_utility.raise_error;
    return(0);
    --
end gen_balance;
--
--------------------------- check_prepay -----------------------------------
/*
NAME
  check_prepay
DESCRIPTION
  Check there are no pre-payment records for this OPM.
NOTES
  The OPM may only be updated or deleted  if it has no pre-payments with an
  effective date after the validation start date.
*/
function check_prepay(opm_id in number,
                      val_start_date in varchar2) return boolean is
dummy varchar2(2);
begin
  --
  hr_utility.set_location('HR_PAYMENTS.CHECK_PREPAY',1);
  --
  select 1
  into   dummy
  from   dual
  where  not exists(
         select 1
         from   pay_pre_payments pp
         where  pp.org_payment_method_id = opm_id
         and    exists(
                select 1
                from   pay_assignment_actions aa,
                       pay_payroll_actions pa
                where  pp.assignment_action_id = aa.assignment_action_id
                and    aa.payroll_action_id = pa.payroll_action_id
                and    pa.effective_date >=
                                     fnd_date.canonical_to_date(val_start_date)));
  --
  -- A row returned means no pre-payments after the validation date...OK
  --
  return(true);
  --
exception
  --
  when no_data_found then
    --
    hr_utility.set_message(801,'HR_6234_PAYM_ENTRIES_EXIST');
    hr_utility.raise_error;
    return(false);
    --
end check_prepay;
--
--------------------------- check_ppm -----------------------------------
/*
NAME
  check_ppm
DESCRIPTION
  On delete check no PPMs depend on the OPM
NOTES
  An OPM may not be deleted when there is a PPM which is dependant upon it.
  Here DE deletes are what we are talking about.
  eg
     |-------------PPM-------------------|
     |-------------OPM---------|
                               ^
                               DE Del Invalid
  --
*/
function check_ppm(val_start_date in varchar2,
                   opm_id in varchar2) return boolean is
dummy number;
begin
  --
  -- If there is a ppm which finishes after the validation start date, then
  -- the (DE) delete is invalid.  This case is given if no rows are returned
  -- and is picked up in the error handler.
  --
  hr_utility.set_location('HR_PAYMENTS.CHECK_PPM',1);
  --
  select 1
  into   dummy
  from   dual
  where  not exists(
         select 1
         from   pay_personal_payment_methods_f ppm
         where  ppm.org_payment_method_id = opm_id
         and    ppm.effective_end_date > fnd_date.canonical_to_date(val_start_date));
  --
  if dummy = 1 then
    --
    return(true);
    --
  end if;
  --
  return(false);     -- Never should get here
  --
exception
  --
  when no_data_found then
    --
    hr_utility.set_message(801,'HR_6235_PAYM_EXISTING_PPMS');
    hr_utility.raise_error;
    return(false);
    --
end check_ppm;
--
--------------------------- check_default -----------------------------------
/*
NAME
  check_default
DESCRIPTION
  Check that on delete there are no payrolls using this method as default.
NOTES
  Each payroll must have a default payment method.  If this OPM is used as
  default by any payrolls (DE mode) then it cannot be deleted.
*/
function check_default(opm_id in varchar2,
                       val_start_date in varchar2) return boolean is
valid_del varchar2(2);
begin
  --
  -- Check if any payrolls use this OPM whichare valid after the delete date.
  --
  hr_utility.set_location('HR_PAYMENTS.CHECK_DEFAULT',1);
  --
  select 'Y'
  into   valid_del
  from   dual
  where  not exists(
         select 1
         from   pay_payrolls_f pp
         where  pp.default_payment_method_id = opm_id
         and    pp.effective_end_date > fnd_date.canonical_to_date(val_start_date));
  --
  if valid_del = 'Y' then
    --
    return(true);
    --
  end if;
  --
  return(false);    -- Should never be here
  --
exception
  --
  when no_data_found then
    --
    hr_utility.set_message(801,'HR_6236_PAYM_USED_AS_DEFAULT');
    hr_utility.raise_error;
    return(false);
    --
end check_default;
--
--------------------------- check_amt -----------------------------------
/*
NAME
  check_amt
DESCRIPTION
  Check the method is defined with a valid amount or percentage
NOTES
  The PPM must be paid as an amount or percentage of original pay.  Check that
  one (and only one) of these has been specified for the method.
*/
function check_amt(percent in varchar2, amount in varchar2) return boolean is
--
begin
  --
  if amount is null and percent is not null then
    --
    return(true);
    --
  elsif amount is not null and percent is null then
    --
    return(true);
    --
  else
    --
    hr_utility.set_message(801,'HR_6221_PAYM_INVALID_PPM');
    hr_utility.raise_error;
    return(false);
    --
  end if;
  --
end;
--
--------------------------- mt_checks -----------------------------------
/*
NAME
  mt_checks
DESCRIPTION
  Check if the PPT category is 'MT'. If so do relevant checks.
NOTES
  If MT then must have a valid external account to pay into.
*/
function mt_checks(opm_id in varchar2,
                   val_start_date in varchar2,
                   account_id in varchar2) return boolean is
required_territory varchar2(16);
actual_territory varchar2(16);
category varchar2(20);
begin
  --
  -- Check if an account is specified and if so get the territory
  --
  hr_utility.set_location('HR_PAYMENTS.MT_CHECKS',1);
  --
  if account_id is null then
    --
    actual_territory := 'NONE';
    --
  else
    --
    begin
      --
      -- Check the account is valid
      --
      select exa.territory_code
      into   actual_territory
      from   pay_external_accounts exa
      where  exa.external_account_id = account_id;
      --
    exception
      --
      when no_data_found then
        --
        hr_utility.set_message(801,'HR_6223_PAYM_BAD_ACCT');
        hr_utility.raise_error;
      --
    end;
    --
  end if;
  --
  -- Now make sure its in the right territory (if required)
  --
  hr_utility.set_location('HR_PAYMENTS.MT_CHECKS',2);
  --
  select nvl(ppt.territory_code, 'NONE'),
         ppt.category
  into   required_territory,
         category
  from   pay_payment_types ppt,
         pay_org_payment_methods_f opm
  where  opm.org_payment_method_id = opm_id
  and    opm.payment_type_id = ppt.payment_type_id
  and    fnd_date.canonical_to_date(val_start_date) between
         opm.effective_start_date and opm.effective_end_date;
  --
  -- Check the category.  If it is 'MT' do the checks...
  --
  hr_utility.set_location('HR_PAYMENTS.MT_CHECKS',3);
  --
  if category = 'MT' then
    --
    if actual_territory <> required_territory then
      --
      if required_territory <> 'NONE' then
        --
        hr_utility.set_message(801,'HR_6220_PAYM_INVALID_ACT');
        hr_utility.set_message_token('TERITORY',required_territory);
        hr_utility.raise_error;
        return(false);
        --
      end if;
    end if;
    --
  end if;
  --
  return(true);
  --
exception
  --
  when no_data_found then
    --
    hr_utility.set_message(801,'HR_6224_PAYM_NO_OPM');
    hr_utility.raise_error;
    return(false);
    --
end mt_checks;
--
--------------------------- unique_priority -----------------------------------
/*
NAME
  unique_priority
DESCRIPTION
  Check the priority is unique at all times fo the assignment.
NOTES
  Two PPMs for the same assignment must have different priorities, or the
  results of pre-payments will be unrepeatable.  This is called from the form
  and as an update/insert trigger.
*/
function unique_priority(in_priority in varchar2,
                         val_start_date in varchar2,
                         val_end_date in varchar2,
                         assignment in varchar2) return boolean is
duplicate varchar2(2);
begin
  --
  hr_utility.set_location('HR_PAYMENTS.UNIQUE_PRIORITY',1);
  --
  select 'N'
  into   duplicate
  from   sys.dual
  where  not exists(
         select 1
         from   pay_personal_payment_methods_f ppm
         where  ppm.assignment_id = assignment
         and    ppm.priority = in_priority
         and    fnd_date.canonical_to_date(val_start_date) < ppm.effective_end_date
         and    fnd_date.canonical_to_date(val_end_date) > ppm.effective_start_date);
  --
  -- See how we did
  --
  if duplicate = 'N' then
    --
    return true;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    hr_utility.set_message(801,'HR_6225_PAYM_DUP_PRIORITY');
    hr_utility.raise_error;
    return false;
    --
end unique_priority;
--
--------------------------- check_pp -----------------------------------
/*
NAME
  check_pp
DESCRIPTION
  Checks there are no outstanding pre-payments on delete
NOTES
  Before deleting the PPM must make sure there are no PPs which use it after
  val_start_date.
*/
function check_pp(ppm_id in varchar2,
                  val_start_date in varchar2) return boolean is
status varchar2(2);
begin
  --
  hr_utility.set_location('HR_PAYMENTS.CHECK_PP',1);
  --
  -- WWbug 264094. Changed below from effective_date >= val_start_date to
  -- effective_date > val_start_date. This has the effect of allowing the
  -- delete if there are pre-payments on the deleteion date, providing there
  -- aren't any after the date.
  --
  select 'Y'
  into   status
  from   sys.dual
  where  not exists(
         select 1
         from   pay_payroll_actions pa,
                pay_assignment_actions aa,
                pay_pre_payments pp
         where  pp.personal_payment_method_id = ppm_id
         and    pp.assignment_action_id = aa.assignment_action_id
         and    aa.payroll_action_id = pa.payroll_action_id
         and    pa.effective_date > fnd_date.canonical_to_date(val_start_date));
  --
  -- If there is a row, then all is cool, but check anyhow to be defensive.
  --
  hr_utility.set_location('HR_PAYMENTS.CHECK_PP',2);
  --
  if status = 'Y' then
    --
    return true;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    -- This means future PPs exist so flag it.
    --
    hr_utility.set_message(801,'HR_6226_PAYM_PPS_EXIST');
    hr_utility.raise_error;
    return false;
    --
end check_pp;
--
end hr_payments;

/
