--------------------------------------------------------
--  DDL for Package Body HR_PRE_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PRE_PAY" as
/* $Header: pyprepyt.pkb 120.3.12010000.5 2009/09/24 05:16:48 abanand ship $ */
--
-- Payment details record type
--
type pay_method_type is record
  (category varchar2(16),
   currency varchar2(16),
   dbase_item varchar2(160),
   exchange_rate number,
   cash_rule varchar2(40),
   payment_method_id number(15)
  );
--
-- Cash analysis record type
--
type cash_type is record
  (cash_left number,
   pre_payment number(16),
   currency varchar2(8),
   precision number,
   cash_paid number,
   val_mode varchar2(20),
   a_action_id number
  );
--
type pre_pay_rec is record
  (pre_payment_id             pay_pre_payments.pre_payment_id%type,
   personal_payment_method_id pay_pre_payments.personal_payment_method_id%type,
   assignment_action_id       pay_pre_payments.assignment_action_id%type,
   org_payment_method_id      pay_pre_payments.org_payment_method_id%type,
   value                      pay_pre_payments.value%type,
   base_currency_value        pay_pre_payments.base_currency_value%type,
   source_action_id           pay_pre_payments.source_action_id%type,
   prepayment_action_id       pay_pre_payments.prepayment_action_id%type,
   organization_id            pay_pre_payments.organization_id%type,
   payees_org_payment_method_id pay_pre_payments.payees_org_payment_method_id%type,
   effective_date             pay_pre_payments.effective_date%type,
   category                   pay_payment_types.category%type,
   cash_rule                  varchar2(40),
   payment_currency           varchar2(16),
   base_currency              varchar2(16)
  );
--
type pre_pay_tab is table of pre_pay_rec index by binary_integer;
--
cursor g_third_party (p_assignment_action in number)  is
    select pet2.output_currency_code,
           pet2.element_type_id,
           prr2.run_result_id,
           paa.assignment_id
    from pay_action_interlocks  pai2,
         pay_run_results        prr2,
         pay_element_types_f    pet2,
         pay_payroll_actions    ppa,
         pay_assignment_actions paa
    where pai2.locking_action_id   = p_assignment_action
    and   pai2.locked_action_id    = prr2.assignment_action_id
    and   paa.assignment_action_id = pai2.locked_action_id
    and   ppa.payroll_action_id    = paa.payroll_action_id
    and   prr2.element_type_id     = pet2.element_type_id
    and   prr2.source_type         = 'E'
    and   pet2.third_party_pay_only_flag = 'Y'
    and   ppa.effective_date between
          pet2.effective_start_date and pet2.effective_end_date
    and   prr2.entry_type NOT IN ('R','A');

--
cursor g_pp_methods (p_assignment in number,
                     p_effective_date in varchar2,
                     p_def_balance in number)  is
    select ppt.category                             category,
           ppm.personal_payment_method_id           personal_method,
           pea.prenote_date                         prenote_date,
           ppt.validation_days                      valid_days,
           ppm.percentage                           percentage,
           ppm.amount                               amount,
           opm.org_payment_method_id                org_method,
           hr_pre_pay.set_cash_rule(ppt.category,
                         opm.pmeth_information1)    cash_rule,
           opm.currency_code                        payment_currency,
           ppt.pre_validation_required              validation_required,
           ppt.validation_value                     validation_value,
           opm.external_account_id                  external_account_id
--    from   hr_lookups hlu,
     from  pay_external_accounts pea,
           pay_payment_types ppt,
           pay_org_payment_methods_f opm,
           pay_personal_payment_methods_f ppm
    where  ppm.assignment_id = p_assignment
    and    ppm.run_type_id is null
    and    ppm.org_payment_method_id = opm.org_payment_method_id
    and    opm.payment_type_id = ppt.payment_type_id
    and    opm.defined_balance_id = p_def_balance
    and    ppm.external_account_id = pea.external_account_id (+)
--    and    opm.pmeth_information1 = hlu.lookup_code (+)
--    and    NVL(hlu.lookup_type, 'CASH_ANALYSIS') = 'CASH_ANALYSIS'
--    and    NVL(hlu.application_id, 800) = 800
    and    fnd_date.canonical_to_date(p_effective_date)  between
                  ppm.effective_start_date and ppm.effective_end_date
    and    fnd_date.canonical_to_date(p_effective_date) between
                  opm.effective_start_date and opm.effective_end_date
    order by ppm.person_id,ppm.priority;
--
-- Coinage cursor.  fetch all monetary units of a currency in order of value
--
cursor coin_cursor(currency in varchar2,
                   ass_act in number) is
       select pmu.monetary_unit_id,
                  pmu.relative_value
       from   pay_monetary_units pmu,
              per_business_groups_perf pbg,
                     pay_payroll_actions pac,
              pay_assignment_actions pas
       where  pmu.currency_code = currency
       and    pbg.business_group_id = pac.business_group_id
       and    pac.payroll_action_id = pas.payroll_action_id
       and    pas.assignment_action_id = ass_act
       and    (pmu.business_group_id = pbg.business_group_id
               or (pmu.business_group_id is null
                   and pmu.legislation_code = pbg.legislation_code)
               or (pmu.business_group_id is null
                   and pmu.legislation_code is null)
             )
       order by pmu.relative_value desc;
--
got_renumerate   boolean;
balance_currency varchar2(16);
payroll_action number(16);
payroll number(16);
negative_pay varchar2(30);
pre_payment_date date;
default_method pay_method_type;
cash_detail cash_type;
effective_date date;
override pay_method_type;
pay_currency_type varchar2(30);
g_adjust_ee_source varchar2(1);
g_pre_payments pre_pay_tab;
--
function set_cash_rule(p_type in varchar2, p_seg1 in varchar2)
   return varchar2 is
cash_rule hr_lookups.description%type;
begin
    if (p_type = 'CA') then
       select hlu.description
       into cash_rule
       from hr_lookups hlu
       where  p_seg1 = hlu.lookup_code
       and    hlu.lookup_type = 'CASH_ANALYSIS'
       and    NVL(hlu.application_id, 800) = 800 ;
--
       return cash_rule;
    else
       return null;
    end if;
--
exception
    when no_data_found then
       return null;
end set_cash_rule;
--
--
--                         PROCEDURES                                 --
--
--
--                         UTILITY ROUTINES                           --
--
--
--------------------------- ins_coin_el -----------------------------------
/*
NAME
  ins_coin_el
DESCRIPTION
  pay the given number of monetary units
NOTES
  This is the base unit for inserting coin anal elements for a payment.
  The monetary unit is supplied and the routine pays as specified.  When the
  user calls it, it is possible to leave monetary unit null, and the
  routine will determine the correct value.  NB all operations on the
  amount of cash left are protected from the user.
*/
procedure ins_coin_el(monetary_unit in number,
                      no_of_units in number,
                      factor in number) is
amount_to_pay number;
no_units number;
begin
  --
  -- Calculate the amount of cash to pay
  --
  amount_to_pay := factor * no_of_units;
  --
  -- See if there is enough to pay
  --
  if amount_to_pay <= cash_detail.cash_left then
    --
    no_units := no_of_units;
    cash_detail.cash_left := cash_detail.cash_left - amount_to_pay;
    cash_detail.cash_paid := cash_detail.cash_paid + amount_to_pay;
    --
  else
    --
    no_units := floor(cash_detail.cash_left/factor);
    cash_detail.cash_left := cash_detail.cash_left - (no_of_units * factor);
    cash_detail.cash_paid := cash_detail.cash_paid + (no_of_units * factor);
    --
  end if;
  --
  cash_detail.cash_left := round(cash_detail.cash_left, cash_detail.precision);
  --
  if (cash_detail.val_mode = 'TRANSFER') then
    --
    -- Now make the payment
    --
    hr_utility.set_location('HR_PRE_PAY.INS_COIN_EL',2);
    --
    insert into pay_coin_anal_elements(
    coin_anal_element_id,
    pre_payment_id,
    monetary_unit_id,
    number_of_monetary_units)
    values(
    pay_coin_anal_elements_s.nextval,
    cash_detail.pre_payment,
    monetary_unit,
    no_units);
  --
  end if;
  --
end ins_coin_el;
--
--------------------------- pay_coin -----------------------------------
/*
NAME
  pay_coin
DESCRIPTION
  pay the given number of monetary units
NOTES
  This is called from the user cash analysis routine.  It pays the number of
  monetary units specifed for the payment currency where the value of the unit
  is given relative to the base value (eg dollar, pound)
*/
procedure pay_coin(no_of_units in number, factor in number) is
monetary_unit number(16);
begin
  --
  -- Firstly get the monetary unit of the payment.
  --
  hr_utility.set_location('HR_PRE_PAY.PAY_COIN',1);
  --
  select pmu.monetary_unit_id
  into   monetary_unit
  from   pay_monetary_units pmu,
         pay_assignment_actions pas,
         pay_payroll_actions pac,
         per_business_groups_perf pbg
  where  cash_detail.a_action_id = pas.assignment_action_id
  and    pac.payroll_action_id = pas.payroll_action_id
  and    pbg.business_group_id = pac.business_group_id
  and    pmu.currency_code = cash_detail.currency
  and    (pmu.business_group_id = pbg.business_group_id
               or (pmu.business_group_id is null
                   and pmu.legislation_code = pbg.legislation_code)
               or (pmu.business_group_id is null
                   and pmu.legislation_code is null)
             )
  and    pmu.relative_value = factor;
  --
  -- Now calculate the amount of cash to pay
  --
  ins_coin_el(monetary_unit, no_of_units, factor);
  --
end pay_coin;
--
-------------------------- do_cash_analysis -----------------------------
/*
NAME
  do_cash_analysis
DESCRIPTION
  Perform cash analysis
NOTES
  Cash analysis is performed to divide a payment down into constituent
  monetary units.  The user may wish to specify certain payments, eg
  3 five dollar notes in each pay packet.  This can be accomplished in
  hr_cash_rules.user_rule which the user can alter.  This is called
  with the cash_rule parameter.  After it returns the rest of the payment
  (or all of it if no rule was specified) is paid using the default method
  (ie use the highest denomination note possible).  Note all inserts to
  pay_coin_anal_elements are made through pay_coin
*/
--
procedure do_cash_analysis(payment in number,
                           cash_rule in varchar2,
                           payment_id in number,
                           pay_currency in varchar2,
                           action_id in number,
                           val_mode in varchar2 default 'TRANSFER',
                           pay_left in out nocopy number) is
monetary_unit number(16);
no_units number(6);
factor number;
precision number;
begin
  --
  -- First set up the details of the payment in the cash record.  Note this
  -- is unavailable to the user cash_rule.
  --
  cash_detail.pre_payment := payment_id;
  cash_detail.cash_left := payment;
  cash_detail.cash_paid := 0;
  cash_detail.val_mode := val_mode;
  cash_detail.currency := pay_currency;
  cash_detail.a_action_id := action_id;
  --
  -- Get the number of decimal places used by the currency
  --
  hr_utility.set_location('HR_PRE_PAY.DO_CASH_ANALYSIS',1);
  --
  select cur.precision
  into   cash_detail.precision
  from   fnd_currencies cur
  where  cur.currency_code = pay_currency;
  --
  -- Call The user accessible cash rule function
  --
  if cash_rule is not null then
    --
    hr_cash_rules.user_rule(cash_rule);
    --
  end if;
  --
  -- At this point, if the user has impleneted any rules they will be
  -- represeneted in pay_coin_anal_elements already.  Cash_left will
  -- represent what hasn't been assigned a monetary unit.
  -- Now pay this remainder by default.
  --
  hr_utility.set_location('HR_PRE_PAY.DO_CASH_ANALYSIS',2);
  --
  open coin_cursor(pay_currency, action_id);
  --
  -- Cursor orders by value (hi-lo).  While there is cash left pay it.
  --
  while cash_detail.cash_left > 0 loop
    --
    hr_utility.set_location('HR_PRE_PAY.DO_CASH_ANALYSIS',3);
    --
    fetch coin_cursor into monetary_unit, factor;
    --
    if coin_cursor%notfound then
      --
      if (cash_detail.val_mode = 'TRANSFER') then
        close coin_cursor;
        hr_utility.set_message(801,'HR_6442_PAYM_MISSING_UNITS');
        hr_utility.raise_error;
      else
        close coin_cursor;
        --
        declare
         pp_ptr number;
        begin
        --
          pp_ptr := g_pre_payments.count;
          --
          -- We cant pay total amount by cash, check the currencies.
          if (g_pre_payments(pp_ptr).base_currency <>
              g_pre_payments(pp_ptr).payment_currency)
          then
            --
            -- Since the payment currency is not the same as base
            -- error out. Lets not get into exchange rate conversions.
            --
            hr_utility.set_message(801,'HR_6442_PAYM_MISSING_UNITS');
            hr_utility.raise_error;
            --
          end if;
          --
          -- Lets take money off the payment amount and put it back
          -- in the general payment pot.
          g_pre_payments(pp_ptr).value := cash_detail.cash_paid;
          g_pre_payments(pp_ptr).base_currency_value := cash_detail.cash_paid;
          pay_left := pay_left + cash_detail.cash_left;
          cash_detail.cash_left := 0;
          --
        end;
      end if;
      --
    else
      --
      no_units := floor(cash_detail.cash_left / factor);
      --
      -- insert the units if there are any
      --
      if no_units <> 0 then
        --
        ins_coin_el(monetary_unit,no_units,factor);
        --
      end if;
      --
    end if;
    --
  end loop;
  --
  hr_utility.set_location('HR_PRE_PAY.DO_CASH_ANALYSIS',4);
  --
   if (coin_cursor%ISOPEN) then
       hr_utility.set_location('HR_PRE_PAY.DO_CASH_ANALYSIS',5);
       close coin_cursor;
   end if;
  --
end do_cash_analysis;
--
-------------------------- flush_payments ------------------------------
/*
NAME
  flush_payments
DESCRIPTION
  Creates pre-payment records for the contents of the pre Payments
  buffer.
NOTES
  This procedure creates a new rows in the pre-payments table.  It does
  any currency conversion required and calls cash analysis if this is
  required.
*/
--
procedure flush_payments
is
cnt number;
pay_left number := 0;
payment_id number;
begin
--
  for cnt in 1..g_pre_payments.count loop
--
    if (g_pre_payments(cnt).value <> 0
       or g_pre_payments(cnt).category = 'MT') then
    --
      select pay_pre_payments_s.nextval
      into   payment_id
      from dual;
--
      g_pre_payments(cnt).pre_payment_id := payment_id;
--
      insert into pay_pre_payments
      (pre_payment_id,
       personal_payment_method_id,
       org_payment_method_id,
       value,
       base_currency_value,
       assignment_action_id,
       source_action_id,
       prepayment_action_id,
       organization_id,
       payees_org_payment_method_id,
       effective_date)
       values (g_pre_payments(cnt).pre_payment_id,
               g_pre_payments(cnt).personal_payment_method_id,
               g_pre_payments(cnt).org_payment_method_id,
               g_pre_payments(cnt).value,
               g_pre_payments(cnt).base_currency_value,
               g_pre_payments(cnt).assignment_action_id,
               g_pre_payments(cnt).source_action_id,
               g_pre_payments(cnt).prepayment_action_id,
               g_pre_payments(cnt).organization_id,
               g_pre_payments(cnt).payees_org_payment_method_id,
               g_pre_payments(cnt).effective_date);
      --
      -- If the category of the payment type is CASH, do cash analysis.
      --
      if g_pre_payments(cnt).category = 'CA'
         and g_pre_payments(cnt).value > 0 then
        --
        do_cash_analysis(g_pre_payments(cnt).value,
                         g_pre_payments(cnt).cash_rule,
                         g_pre_payments(cnt).pre_payment_id,
                         g_pre_payments(cnt).payment_currency,
                         g_pre_payments(cnt).assignment_action_id,
                         'TRANSFER',
                         pay_left);
        --
      end if;
    end if;
--
  end loop;
--
  g_pre_payments.delete;
--
end flush_payments;
--
------------------- override_mult_tax_unit_payment --------------------
/*
NAME
  override_mult_tax_unit_payment
DESCRIPTION
  For legislations that accumulate multi GRE payments, check the
  override at the business group level.
NOTES
  This procedure creates a new row in the pre-payments table.  It does
  any currency conversion required and calls cash analysis if this is
  required.
*/
procedure override_mult_tax_unit_payment(p_business_group_id      in            number,
                                         p_multi_tax_unit_payment in out nocopy varchar2)
is
leg_code per_business_groups_perf.legislation_code%type;
statem varchar2(2000);
sql_cursor           integer;
l_rows               integer;
begin
--
    select legislation_code
      into leg_code
      from per_business_groups_perf
     where business_group_id = p_business_group_id;
--
    statem := 'begin pay_'||leg_code||'_rules.get_multi_tax_unit_pay_flag(';
    statem := statem||':bus_grp, :mtup_flag); end;';
--
    sql_cursor := dbms_sql.open_cursor;
    --
    dbms_sql.parse(sql_cursor, statem, dbms_sql.v7);
    --
    --
    dbms_sql.bind_variable(sql_cursor, 'bus_grp', p_business_group_id);
    --
    dbms_sql.bind_variable(sql_cursor, 'mtup_flag', p_multi_tax_unit_payment);
    --
    l_rows := dbms_sql.execute (sql_cursor);
    --
    if (l_rows = 1) then
      dbms_sql.variable_value(sql_cursor, 'mtup_flag',
                              p_multi_tax_unit_payment);
      dbms_sql.close_cursor(sql_cursor);
--
    else
       p_multi_tax_unit_payment := 'Y';
       dbms_sql.close_cursor(sql_cursor);
    end if;
--
end override_mult_tax_unit_payment;
--
-------------------------- create_payment ------------------------------
/*
NAME
  create_payment
DESCRIPTION
  Create a pre-payment record for this assignment action and pay method.
NOTES
  This procedure creates a new row in the pre-payments table.  It does
  any currency conversion required and calls cash analysis if this is
  required.
*/
--
procedure create_payment (base_value in number,
                          base_currency in varchar2,
                          pay_currency in varchar2,
    --                      exchange_rate in number,
                          personal_method_id in number,
                          org_method_id in number,
                          action_id in number,
                          category in varchar2,
                          cash_rule in varchar2,
                          src_act_id in number default null,
                          prepayment_action_id in number default null,
                          pay_left in out nocopy number,
                          p_org_id in number default null,
                          p_payee_opm_id in number default null,
                          p_effective_date in date default null) is
payment_id number(16);
payment number;
lgcode  varchar2(30);
l_ext_acc number(16);
l_effective_date date;
l_org_method_id number(16);
--
begin
  --
  hr_utility.trace('Enter create_payment');
  if base_currency <> pay_currency then
    --
    begin
    if (pay_currency_type is NULL)
    then
      hr_utility.set_message(801,'HR_52349_NO_RATE_TYPE');
      hr_utility.raise_error;
    end if;
    payment:=hr_currency_pkg.convert_amount(base_currency,
                                          pay_currency,
                                          pre_payment_date,
                                          base_value,
                                          pay_currency_type);

    exception
    --
      when no_data_found then
        hr_utility.set_message(801,'HR_6405_PAYM_NO_EXCHANGE_RATE');
        hr_utility.set_message_token('RATE1', base_currency);
        hr_utility.set_message_token('RATE2', pay_currency);
        hr_utility.raise_error;

      when gl_currency_api.NO_RATE then
      --
        hr_utility.set_message(801,'HR_6405_PAYM_NO_EXCHANGE_RATE');
        hr_utility.set_message_token('RATE1', base_currency);
        hr_utility.set_message_token('RATE2', pay_currency);
        hr_utility.raise_error;

      when gl_currency_api.INVALID_CURRENCY then
        hr_utility.set_message(801,'HR_52350_INVALID_CURRENCY');
        hr_utility.set_message_token('RATE1', base_currency);
        hr_utility.set_message_token('RATE2', pay_currency);
        hr_utility.raise_error;

      --
    end;
    --
  else
    --
    payment := base_value;
    --
  end if;
  --
  -- Now derive override org payment method when external account id is null.
  --
  select opm.external_account_id
    into l_ext_acc
    from pay_org_payment_methods_f opm,
         pay_assignment_actions paa,
         pay_payroll_actions ppa
   where paa.assignment_action_id = action_id
     and ppa.payroll_action_id = paa.payroll_action_id
     and opm.org_payment_method_id = org_method_id
     and ppa.effective_date between
                    opm.effective_start_date and opm.effective_end_date;
  --
  if (l_ext_acc is null) then
     select pbg.legislation_code, ppa.effective_date
       into lgcode, l_effective_date
       from pay_assignment_actions asg,
            per_business_groups_perf pbg,
            pay_payroll_actions   ppa
      where ppa.payroll_action_id = asg.payroll_action_id
        and asg.assignment_action_id = action_id
        and ppa.business_group_id = pbg.business_group_id;
  --
     get_dynamic_org_method('pay_' || lgcode || '_rules.get_dynamic_org_meth',
                                   action_id,
                                   l_effective_date,
                                   org_method_id,
                                   l_org_method_id);
  --
  else l_org_method_id := org_method_id;
  --
  end if;
  --
  -- Now insert the pre-payment record.  NB Only if it is non-zero
  --
  if payment <> 0 then
    --
    -- Save the ID for cash analysis
    --
    hr_utility.set_location('HR_PRE_PAY.CREATE_PAYMENT',1);
    --
    payment_id := null;
   declare
    ins_cnt number;
   begin
--
      ins_cnt := g_pre_payments.count + 1;
      g_pre_payments(ins_cnt).pre_payment_id             := payment_id;
      g_pre_payments(ins_cnt).personal_payment_method_id := personal_method_id;
      g_pre_payments(ins_cnt).org_payment_method_id      := l_org_method_id;
      g_pre_payments(ins_cnt).value                      := payment;
      g_pre_payments(ins_cnt).base_currency_value        := base_value;
      g_pre_payments(ins_cnt).assignment_action_id       := action_id;
      g_pre_payments(ins_cnt).source_action_id           := src_act_id;
      g_pre_payments(ins_cnt).prepayment_action_id       := prepayment_action_id;
      g_pre_payments(ins_cnt).category                   := category;
      g_pre_payments(ins_cnt).cash_rule                  := cash_rule;
      g_pre_payments(ins_cnt).payment_currency           := pay_currency;
      g_pre_payments(ins_cnt).base_currency              := base_currency;
      g_pre_payments(ins_cnt).organization_id            := p_org_id;
      g_pre_payments(ins_cnt).payees_org_payment_method_id
                                                         := p_payee_opm_id;
      g_pre_payments(ins_cnt).effective_date             := p_effective_date;
    end;
--
    --
    -- If the category of the payment type is 'CASH', do cash analysis validation
    --
    if category = 'CA' and payment > 0 then
      --
      do_cash_analysis(payment, cash_rule, payment_id,
                       pay_currency,
                       action_id, 'VALIDATE', pay_left);
      hr_utility.trace('pay_left = '||pay_left);
      --
    end if;
  end if;
  --
  hr_utility.trace('Exit create_payment');
end create_payment;
--
-------------------------- pay_method ------------------------------
/*
NAME
  pay_method
DESCRIPTION
  Calculate the base amount for this payment.
NOTES
  If the PPM has a percentage calculate this, otherwise pay the amount
  specified.  Calculate the new pay left value.  If there is not enough to
  pay the required amount pay as much as possible.
*/
--
procedure pay_method(pay_left in out nocopy number,
                     total_pay in number,
                     base_pay out nocopy number,
                     percentage in number,
                     amount in number,
                     pay_currency in varchar2) is
value number;
--
begin
  --
  -- Get the percentage or amount to be paid
  --
  hr_utility.set_location('HR_PRE_PAY.PAY_METHOD',1);
  --
  select cur.precision
  into   cash_detail.precision
  from   fnd_currencies cur
  where  cur.currency_code = pay_currency;
  --
  if percentage >= 0 then
    --
    value := total_pay * (percentage / 100);
    value := ceil(value * to_number(rpad('1',
                    cash_detail.precision + 1, '0')));
    value := value /to_number(rpad('1',
                    cash_detail.precision + 1, '0'));
    --
    if value <= pay_left then
      --
      base_pay := value;
      pay_left := pay_left - value;
      --
    else
      --
      base_pay := pay_left;
      pay_left := 0;
      --
    end if;
    --
  else
    --
    -- percent not specified so there must be an amount
    --
    value := pay_left - amount;
    --
    if value >= 0 then
      --
      base_pay := amount;
      pay_left := value;
      --
    else
      --
      base_pay := pay_left;
      pay_left := 0;
      --
    end if;
    --
  end if;
  -- --
end pay_method;
--
-------------------------- validate_magnetic ------------------------------
/*
NAME
  validate_magnetic
DESCRIPTION
  Return true if this magnetic payment method is valid to be used, if it has
  been pre-validated (if required).
NOTES
  If this is a valid method return true.  Otherwise determine if a
  pre-validation record is required, and if so insert one into
  pre-payments.
*/
--
function validate_magnetic(personal_method in number,
                           valid_date in date,
                           prenote_date in date,
                           org_method in number,
                           action_id in number,
                           validation_value in number,
                           p_org_id in number default null,
                           p_payee_opm in number default null,
                           p_effdate in date default null) return boolean is
--
begin
  --
  hr_utility.set_location('HR_PRE_PAY.VALIDATE_MAGNETIC',1);
  --
  if prenote_date is null then
  --
  -- insert a prenote entry.
  --
    hr_utility.set_location('HR_PRE_PAY.VALIDATE_MAGNETIC',2);
    insert into pay_pre_payments
    (pre_payment_id,
     personal_payment_method_id,
     org_payment_method_id,
     value,
     base_currency_value,
     assignment_action_id,
     organization_id,
     payees_org_payment_method_id,
     effective_date)
     values (pay_pre_payments_s.nextval,
             personal_method,
             org_method,
             validation_value,
             0,
             action_id,
             p_org_id,
             p_payee_opm,
             p_effdate);
    --
    -- return false as method not yet valid.
    --
    return false;
    --
  end if;
  hr_utility.set_location('HR_PRE_PAY.VALIDATE_MAGNETIC',3);
  if valid_date >= prenote_date then
    --
    return true;
    --
  else
    --
    return false;
    --
  end if;
  --
end validate_magnetic;
--
--
--                         NORMAL PAYMENTS                        --
--
-------------------------- initialise ------------------------------
/*
NAME
  initialise
DESCRIPTION
  Initialise global data for normal payments
NOTES
  Return the database_item name for assignment remuneration payments balance.
  Save global data such as payroll action for future refernce
  Set up the default payment method in memory ready to be accessed.
*/
--
procedure initialise(action_id in out nocopy varchar2) is
  pay_bg_id number(16);
--
begin
  --
  hr_utility.set_location('HR_PRE_PAY.Initialise',1);
  --
  payroll_action := to_number(action_id);
  --
  begin
    --
       select ppt.category,
              UPPER(translate(pbt.balance_name,' ','_') ||
                                               pbd.database_item_suffix),
              pbt.currency_code,
              hr_pre_pay.set_cash_rule(ppt.category,
                         opm.pmeth_information1),
              opm.currency_code,
              pp.default_payment_method_id,
              ppa.effective_date,
              pp.negative_pay_allowed_flag,
              ppa.payroll_id,
	      ppa.business_group_id
       into   default_method.category,
              default_method.dbase_item,
              balance_currency,
              default_method.cash_rule,
              default_method.currency,
              default_method.payment_method_id,
              pre_payment_date,
              negative_pay,
              payroll,
	      pay_bg_id
       from   pay_balance_dimensions pbd,
              pay_balance_types pbt,
              pay_defined_balances pdb,
              pay_payment_types ppt,
              pay_all_payrolls_f pp,
              pay_org_payment_methods_f opm,
              pay_payroll_actions ppa
       where  ppa.payroll_action_id = payroll_action
       and    ppa.payroll_id = pp.payroll_id
       and    pp.default_payment_method_id = opm.org_payment_method_id
       and    opm.payment_type_id = ppt.payment_type_id
       and    opm.defined_balance_id = pdb.defined_balance_id
       and    pdb.balance_type_id = pbt.balance_type_id
       and    pdb.balance_dimension_id = pbd.balance_dimension_id
       and    pbd.payments_flag = 'Y'
       and    pbt.assignment_remuneration_flag = 'Y'
--       and    opm.pmeth_information1 = hlu.lookup_code (+)
--       and    NVL(hlu.lookup_type, 'CASH_ANALYSIS') =  'CASH_ANALYSIS'
--       and    NVL(hlu.application_id, 800) = 800
       and    ppa.effective_date between
              pp.effective_start_date and pp.effective_end_date
       and    ppa.effective_date between
              opm.effective_start_date and opm.effective_end_date;

  pay_currency_type:=hr_currency_pkg.get_rate_type(pay_bg_id,pre_payment_date,'P');
  exception
  --
  when others then
    --
    hr_utility.set_message(801,'HR_6238_PAYM_NO_DEFAULT');
    hr_utility.raise_error;
    --
  end;
  --
  --
  hr_utility.set_location('HR_PRE_PAY.Initialise',2);
  --
  begin
    select plr.rule_mode
      into g_adjust_ee_source
      from pay_legislation_rules plr,
           per_business_groups_perf pbg,
           pay_payroll_actions   ppa
     where ppa.payroll_action_id = payroll_action
       and ppa.business_group_id = pbg.business_group_id
       and pbg.legislation_code = plr.legislation_code
       and plr.rule_type = 'ADJUSTMENT_EE_SOURCE';
     --
   exception
       when no_data_found then
          g_adjust_ee_source := 'A';
  end;
  --
  hr_utility.set_location('HR_PRE_PAY.Initialise',3);
  --
end initialise;
--
--
--                         OVERRIDE PAYMENTS                        --
--
--
-------------------------- init_override ------------------------------
/*
NAME
  init_override
DESCRIPTION
  initialise for an override payment method.
NOTES
  Fetch details of the required override payment into memory.  Generate an
  error if this is not a valid method.  Return the name of the balance
  database item to 'C'
*/
--
procedure init_override(action_id in out nocopy varchar2,
                        override_method in out nocopy varchar2) is
--
pay_bg_id number(16);
begin
  --
  hr_utility.set_location('HR_PRE_PAY.INIT_OVERRIDE',1);
  --
  payroll_action := to_number(action_id);
  override.payment_method_id := to_number(override_method);
  --
  begin
    --
       select ppt.category,
              UPPER(translate(pbt.balance_name,' ','_') ||
                                               pbd.database_item_suffix),
              pbt.currency_code,
              hr_pre_pay.set_cash_rule(ppt.category,
                         opm.pmeth_information1),
              opm.currency_code,
              ppa.payroll_id,
              pp.negative_pay_allowed_flag,
              ppa.effective_date,
              ppa.business_group_id
       into   override.category,
              override.dbase_item,
              balance_currency,
              override.cash_rule,
              override.currency,
              payroll,
              negative_pay,
              pre_payment_date,
	      pay_bg_id
       from   pay_all_payrolls_f pp,
              pay_balance_dimensions pbd,
              pay_balance_types pbt,
              pay_defined_balances pdb,
              pay_payment_types ppt,
              pay_org_pay_method_usages_f pmu,
              pay_org_payment_methods_f opm,
              pay_payroll_actions ppa
       where  ppa.payroll_action_id = payroll_action
       and    ppa.payroll_id = pmu.payroll_id
       and    ppa.payroll_id = pp.payroll_id
       and    pmu.org_payment_method_id = override_method
       and    pmu.org_payment_method_id = opm.org_payment_method_id
       and    opm.payment_type_id = ppt.payment_type_id
       and    ppt.category <> 'MT'
       and    opm.defined_balance_id = pdb.defined_balance_id
       and    pdb.balance_type_id = pbt.balance_type_id
       and    pdb.balance_dimension_id = pbd.balance_dimension_id
       and    pbd.payments_flag = 'Y'
       and    pbt.assignment_remuneration_flag = 'Y'
--       and    opm.pmeth_information1 = hlu.lookup_code (+)
--       and    NVL(hlu.lookup_type ,'CASH_ANALYSIS') = 'CASH_ANALYSIS'
--       and    NVL(hlu.application_id, 800) = 800
       and    ppa.effective_date between
              pp.effective_start_date and pp.effective_end_date
       and    ppa.effective_date between
              pmu.effective_start_date and pmu.effective_end_date
       and    ppa.effective_date between
              opm.effective_start_date and opm.effective_end_date;
  --
  pay_currency_type:=hr_currency_pkg.get_rate_type(pay_bg_id,pre_payment_date,'P');
  exception
    --
    when others then
      --
      hr_utility.set_message(801,'HR_6239_PAYM_INVALID_OVERRIDE');
      hr_utility.raise_error;
    --
  end;
  --
  begin
    select plr.rule_mode
      into g_adjust_ee_source
      from pay_legislation_rules plr,
           per_business_groups_perf pbg,
           pay_payroll_actions   ppa
     where ppa.payroll_action_id = payroll_action
       and ppa.business_group_id = pbg.business_group_id
       and pbg.legislation_code = plr.legislation_code
       and plr.rule_type = 'ADJUSTMENT_EE_SOURCE';
     --
   exception
       when no_data_found then
          g_adjust_ee_source := 'A';
  end;
  --
  --
end init_override;
--
-------------------------- get_ren_balance ----------------------------------
/*
NAME
  get_ren_balance
DESCRIPTION
  Gets the renumeration balance details that have to be paid in this run.
*/
--
procedure get_ren_balance(p_bus_grp     in number,
                          p_def_bal_id  in out nocopy number) is
def_bal number;
bus_leg pay_balance_types.legislation_code%type;
bal_found boolean;
begin
--
    bal_found := FALSE;
    begin
      select distinct pdb.defined_balance_id,
                      pbt.currency_code
      into def_bal,
           balance_currency
      from pay_balance_types      pbt,
           pay_defined_balances   pdb,
           pay_balance_dimensions pbd
      where pbt.business_group_id = p_bus_grp
      and   pbt.assignment_remuneration_flag = 'Y'
      and   pbt.balance_type_id   = pdb.balance_type_id
      and   pdb.balance_dimension_id = pbd.balance_dimension_id
      and   pbd.payments_flag = 'Y';
--
      bal_found := TRUE;
    exception
        when NO_DATA_FOUND then
           bal_found := FALSE;
    end;
--
    if (bal_found = FALSE) then
       select distinct legislation_code
       into   bus_leg
       from   per_business_groups_perf
       where  business_group_id = p_bus_grp;
--
      select distinct pdb.defined_balance_id,
                      pbt.currency_code
      into def_bal,
           balance_currency
      from pay_balance_types      pbt,
           pay_defined_balances   pdb,
           pay_balance_dimensions pbd
      where pbt.business_group_id is null
      and   pbt.legislation_code = bus_leg
      and   pbt.assignment_remuneration_flag = 'Y'
      and   pbt.balance_type_id   = pdb.balance_type_id
      and   pdb.balance_dimension_id = pbd.balance_dimension_id
      and   pbd.payments_flag = 'Y';
    end if;
--
    p_def_bal_id := def_bal;
--
exception
    when NO_DATA_FOUND then
       hr_utility.set_message(801,'HR_XXXX_PAYM_NO_RENUMERATION');
       hr_utility.raise_error;
end get_ren_balance;
-------------------------- get_third_party_details --------------------------
/*
NAME
  get_third_party_details
DESCRIPTION
  Gets the third party details that have to be paid for a given assignment
  action.
NOTES
  This is called from a C procedure thus details are returned to the C
  process, however some are also  held in global variables to be used
  later in the run.
*/
--
procedure get_third_party_details (p_assignment_action in  number,
                                   p_effective_date    in  varchar2,
                                   p_element_id           out nocopy number,
                                   p_run_result           out nocopy number,
				   p_assignment_id        out nocopy number
                                  ) is
--
element_id number;
run_result number;
assignment_id number;
--
begin
    if (not g_third_party%ISOPEN) then
        open g_third_party(p_assignment_action);
    end if;
--
    fetch g_third_party into balance_currency, element_id, run_result,assignment_id;
--
    if (g_third_party%NOTFOUND) then
        close g_third_party;
        raise NO_DATA_FOUND;
    end if;
--
    p_element_id := element_id;
    p_run_result := run_result;
    p_assignment_id := assignment_id;
--
    return;
--
exception
   when NO_DATA_FOUND then
      if (g_third_party%ISOPEN) then
         close g_third_party;
      end if;
      raise;
   when others then
      if (g_third_party%ISOPEN) then
         close g_third_party;
      end if;
      raise;
end get_third_party_details;
--
-------------------------- get_balance_value ---------------------------------
/*
NAME
  get_balance_value
DESCRIPTION
  Gets the balance value to be paid for a specific assignment action
  assignment action.
NOTES
  The value is returned to the C process.
*/
procedure get_balance_value(p_def_balance         in number,
                            p_assignment_actions  in number,
                            p_balance_value       in out nocopy number,
                            p_org_id              in number default null) is
ass_act_id number;
begin
--
   if (p_org_id is not null) then
     pay_balance_pkg.set_context('ORGANIZATION_ID', p_org_id);
   end if;
--
   p_balance_value := pay_balance_pkg.get_value(p_def_balance,
                                                p_assignment_actions);
   return;
end get_balance_value;
--
-------------------------- adjust_payments ------------------------------
/*
NAME
  adjust_payments
DESCRIPTION
  This procedure is called if prepayments detects at the end of processing
  an amount that still hasn't been paid. This procedure searches the
  payments for a method that can pay it.
*/
procedure adjust_payments(pay_left in out nocopy number,
                          p_src_action_id in number)
--
is
pp_ptr number;
--
begin
--
  hr_utility.trace('Enter adjust_payments');
  pp_ptr := g_pre_payments.count;
  while (pp_ptr > 0) loop
--
    hr_utility.trace('Compare '||g_pre_payments(pp_ptr).category);
    hr_utility.trace('Compare '||
                     nvl(g_pre_payments(pp_ptr).payment_currency, 'NULL')||
                     ' with '||
                     nvl(g_pre_payments(pp_ptr).base_currency, 'NULL'));
    hr_utility.trace('Compare '||
                     nvl(g_pre_payments(pp_ptr).source_action_id, -999)||
                     ' with '||
                     nvl(p_src_action_id, -999));
--
    if (g_pre_payments(pp_ptr).category <> 'CA'
     and g_pre_payments(pp_ptr).payment_currency =
            g_pre_payments(pp_ptr).base_currency
     and nvl(g_pre_payments(pp_ptr).source_action_id, -999)
          = nvl(p_src_action_id, -999))
    then
--
      g_pre_payments(pp_ptr).base_currency_value :=
          g_pre_payments(pp_ptr).base_currency_value + pay_left ;
      g_pre_payments(pp_ptr).value :=
                 g_pre_payments(pp_ptr).base_currency_value;
      pay_left := 0;
--
    end if;
--
    pp_ptr := pp_ptr  - 1;
  end loop;
  hr_utility.trace('Exit adjust_payments');
--
end adjust_payments;
--
-------------------------- pay_per_payment_methods ------------------------------
/*
NAME
  pay_per_payment_methods
DESCRIPTION
  This distributes the payable amount over the personal payment methods
  as directed. If it is to be paid by magnetic tape do the required
  validation check. If there is not a payment method specified use the
  default method.
*/
procedure pay_per_payment_methods(p_assignment_action in number,
                                  p_assignment        in number,
                                  p_effective_date    in varchar2,
                                  p_def_balance       in number,
                                  p_total_pay         in number,
                                  p_pay_left      in out nocopy number,
                                  p_src_act_id        in number default null,
				  p_prepayment_action_id in number default null)
is
--
base_payment number;
payment boolean;
valid_date date;
valid_method boolean;
last_method g_pp_methods%rowtype;
exchange_rate number;
leg_code varchar2(150);
prenote_default varchar2(1);
found boolean;
l_org_method_id pay_org_payment_methods.org_payment_method_id%TYPE;
--
begin
--
    hr_utility.trace('Enter pay_per_payment_methods');
    payment := FALSE;

    -- check for legilsation rule
    select org.legislation_code
    into  leg_code
    from pay_assignment_Actions act,
         pay_payroll_actions pact,
         per_business_groups_perf org
    where act.assignment_action_id=p_assignment_action
    and pact.payroll_action_id=act.payroll_action_id
    and org.business_group_id=pact.business_group_id;

    pay_core_utils.get_legislation_rule(
        'PRENOTE_DEFAULT',
        leg_code,
        prenote_default,found);
--
    for payments in g_pp_methods(p_assignment, p_effective_date,
                                 p_def_balance) loop
       valid_date := (fnd_date.canonical_to_date(p_effective_date) -
                          payments.valid_days);
       --
       -- put code here to derive override org payment method
       -- when external account id is null
       --
       --
       if (payment = TRUE) then
         if valid_method = TRUE then
           create_payment(base_payment,
                      balance_currency,
                      last_method.payment_currency,
                      last_method.personal_method,
                      last_method.org_method,
                      p_assignment_action,
                      last_method.category,
                      last_method.cash_rule,
                      p_src_act_id,
                      p_prepayment_action_id,
                      p_pay_left);
         else
           create_payment(base_payment,
                      balance_currency,
                      default_method.currency,
                      null,
                      default_method.payment_method_id,
                      p_assignment_action,
                      default_method.category,
                      default_method.cash_rule,
                      p_src_act_id,
                      p_prepayment_action_id,
                      p_pay_left);
         end if;
         payment := FALSE;
       end if;
       --
       -- Pay this method.  Find out the amount of this payment and the
       -- pay left.
       --
       if p_pay_left > 0
          or (negative_pay = 'Y' and p_pay_left <> 0 and
              payments.category IN ('MT', 'CA'))  then
         --
         -- Check for magnetic tape payments.  Check they have been
         -- prenoted.
         --
         if payments.category = 'MT' and
            payments.validation_required = 'Y' then
           --
           valid_method := validate_magnetic(
                                      payments.personal_method,
                                      valid_date,
                                      payments.prenote_date,
                                      payments.org_method,
                                      p_assignment_action,
                                      payments.validation_value);

           --
         else
           --
           valid_method := true;
           --
         end if;
         --
         if valid_method = true then
           --
           pay_method(p_pay_left,
                      p_total_pay,
                      base_payment,
                      payments.percentage,
                      payments.amount,
                      payments.payment_currency);
           --
           -- Now if set up the correct exchange rate if required
           --
           --
           -- Now if there is anything to pay, create a payment record
           -- in the correct currency.  Also if required perform cash
           -- analysis.
           --
           if base_payment > 0
              or (negative_pay = 'Y' and
                  payments.category IN ('MT', 'CA'))  then
--
               payment := TRUE;
           end if;
           last_method := payments;
         else
            if (found=true and upper(prenote_default)='Y')
            then
              -- pay in default method
              pay_method(p_pay_left,
                        p_total_pay,
                        base_payment,
                        payments.percentage,
                        payments.amount,
                        payments.payment_currency);
              if base_payment > 0
                 or (negative_pay = 'Y' and
                 default_method.category IN ('MT', 'CA'))  then
                   payment := TRUE;
              end if;
            end if;
         end if;
      end if;
--
    end loop;
    if (payment = TRUE) then
       base_payment := base_payment + p_pay_left;
       p_pay_left := 0;
       if ( valid_method=TRUE)  then
        create_payment(base_payment,
                      balance_currency,
                      last_method.payment_currency,
       --               exchange_rate,
                      last_method.personal_method,
                      last_method.org_method,
                      p_assignment_action,
                      last_method.category,
                      last_method.cash_rule,
                      p_src_act_id,
                      p_prepayment_action_id,
                      p_pay_left);
       else
        create_payment(base_payment,
                      balance_currency,
                      default_method.currency,
                      null,
                      default_method.payment_method_id,
                      p_assignment_action,
                      default_method.category,
                      default_method.cash_rule,
                      p_src_act_id,
                      p_prepayment_action_id,
                      p_pay_left);
       end if;
      -- Check to see if there is any money left.
      -- If there is then the last payment must have been cash
      -- that could not be paid due to the denominations
      if (p_pay_left > 0) then
        adjust_payments(p_pay_left, p_src_act_id);
--
        if p_pay_left > 0 then
          hr_utility.set_message(801,'HR_6442_PAYM_MISSING_UNITS');
          hr_utility.raise_error;
        end if;
      end if;
--
    end if ;
--
    hr_utility.trace('Exit pay_per_payment_methods');
--
end pay_per_payment_methods;
--
-------------------------- pay_run_type_methods ----------------------------- -
/*
NAME
  pay_run_type_methods
DESCRIPTION
  This distributes the payable amount over the run type methods
  as directed. If it is to be paid by magnetic tape do the required
  validation check. If there is not a payment method specified use the
  default method.
*/
procedure pay_run_type_methods(p_assignment_action   in     number,
                               p_effective_date      in     varchar2,
                               p_def_balance         in     number,
                               p_pay_left            in out nocopy number,
                               p_master_aa_id        in     number) is
cursor chdact is
select paa_chd.assignment_action_id,
       paa_chd.run_type_id,
       prt.run_method,paa_chd.assignment_id
from pay_assignment_actions paa_par,
     pay_action_interlocks  pai,
     pay_assignment_actions paa_chd,
     pay_payroll_actions    ppa_chd,
     pay_run_types_f        prt
where paa_par.assignment_action_id = p_assignment_action
and   paa_par.assignment_action_id = pai.locking_action_id
and   pai.locked_action_id         = paa_chd.assignment_action_id
and   paa_chd.run_type_id is not null
and   paa_chd.run_type_id = prt.run_type_id
and   prt.run_method in ('N','S','P')
and   ppa_chd.payroll_action_id = paa_chd.payroll_action_id
and   ppa_chd.effective_date between prt.effective_start_date
                                 and prt.effective_end_date
order by paa_chd.action_sequence;
--
cursor rt_org_methods (p_run_type in number,
                       p_effective_date in varchar2,
                       p_def_balance in number,
                       p_assignment_action in number)  is
    select ppt.category                             category,
           null                                     personal_method,
           null                                     prenote_date,
           ppt.validation_days                      valid_days,
           rtom.percentage                           percentage,
           rtom.amount                               amount,
           opm.org_payment_method_id                org_method,
           hr_pre_pay.set_cash_rule(ppt.category,
                         opm.pmeth_information1)    cash_rule,
           opm.currency_code                        payment_currency,
           ppt.pre_validation_required              validation_required,
           ppt.validation_value                     validation_value,
           opm.external_account_id                  external_account_id
     from  pay_payment_types ppt,
           pay_org_payment_methods_f opm,
           pay_run_type_org_methods_f rtom,
           pay_org_pay_method_usages_f opmu,
           pay_payroll_actions         ppa,
           pay_assignment_actions      paa
    where  rtom.run_type_id = p_run_type
      and  rtom.org_payment_method_id = opm.org_payment_method_id
      and    opm.payment_type_id = ppt.payment_type_id
      and    opm.defined_balance_id = p_def_balance
      and    paa.assignment_action_id = p_assignment_action
      and    paa.payroll_action_id = ppa.payroll_action_id
      and    ppa.payroll_id = opmu.payroll_id
      and    opmu.org_payment_method_id = opm.org_payment_method_id
      and    fnd_date.canonical_to_date(p_effective_date)  between
                    opmu.effective_start_date and opmu.effective_end_date
      and    fnd_date.canonical_to_date(p_effective_date)  between
                    rtom.effective_start_date and rtom.effective_end_date
      and    fnd_date.canonical_to_date(p_effective_date) between
                    opm.effective_start_date and opm.effective_end_date
      order by rtom.priority;


cursor rt_personal_pay_methods ( p_run_type in number,
                       p_effective_date in varchar2,
                       p_def_balance in number,
                       p_assignment_action in number)  is
    select ppt.category                             category,
           ppm.personal_payment_method_id           personal_method,
           pea.prenote_date                         prenote_date,
           ppt.validation_days                      valid_days,
           ppm.percentage                           percentage,
           ppm.amount                               amount,
           opm.org_payment_method_id                org_method,
           hr_pre_pay.set_cash_rule(ppt.category,
                         opm.pmeth_information1)    cash_rule,
           opm.currency_code                        payment_currency,
           ppt.pre_validation_required              validation_required,
           ppt.validation_value                     validation_value,
           opm.external_account_id                  external_account_id
     from  pay_external_accounts pea,
           pay_payment_types ppt,
           pay_org_payment_methods_f opm,
           pay_personal_payment_methods_f ppm,
           pay_assignment_actions act
    where  act.assignment_action_id=p_assignment_action
    and	   ppm.assignment_id = act.assignment_id
    and    ppm.run_type_id = p_run_type
    and    ppm.org_payment_method_id = opm.org_payment_method_id
    and    opm.payment_type_id = ppt.payment_type_id
    and    opm.defined_balance_id = p_def_balance
    and    ppm.external_account_id = pea.external_account_id (+)
    and    fnd_date.canonical_to_date(p_effective_date)  between
                  ppm.effective_start_date and ppm.effective_end_date
    and    fnd_date.canonical_to_date(p_effective_date) between
                  opm.effective_start_date and opm.effective_end_date
    order by ppm.person_id,ppm.priority;
--
-- Coinage cursor.  fetch all monetary units of a currency in order of value

--
--
/*
pay_left number;
payment boolean;
ren_method_payment boolean;
last_method g_pp_methods%rowtype;
exchange_rate number;
*/
valid_date date;
base_payment number;
valid_method boolean;
total_pay number;
pay_left number;
master_action_id number;
child_action_id number;
assign_id number;
leg_code varchar2(150);
prenote_default varchar2(1);
found boolean;
l_org_method_id pay_org_payment_methods.org_payment_method_id%TYPE;
got_payment_amount boolean;
begin
--
    hr_utility.trace('Enter pay_run_type_methods');
    -- check for legilsation rule
    select org.legislation_code
    into  leg_code
    from pay_assignment_Actions act,
         pay_payroll_actions pact,
         per_business_groups_perf org
    where act.assignment_action_id=p_assignment_Action
    and pact.payroll_action_id=act.payroll_action_id
    and org.business_group_id=pact.business_group_id;

    pay_core_utils.get_legislation_rule(
	'PRENOTE_DEFAULT',
	leg_code,
        prenote_default,found);

    for chdrec in chdact loop
       got_payment_amount := FALSE;
       assign_id := chdrec.assignment_id;

       child_action_id := p_assignment_action;
       master_action_id := p_master_aa_id;

       for payments in rt_personal_pay_methods(chdrec.run_type_id, p_effective_date,
                                    p_def_balance, chdrec.assignment_action_id)
       loop
--
         if (got_payment_amount = FALSE) then
           get_balance_value(p_def_balance,
                             chdrec.assignment_action_id,
                             total_pay);
           pay_left := total_pay;
           got_payment_amount := TRUE;
         end if;
--
         valid_date := (fnd_date.canonical_to_date(p_effective_date) -
                            payments.valid_days);
         --
         -- Pay this method.  Find out the amount of this payment and the
         -- pay left.
         --
         if pay_left > 0
            or (negative_pay = 'Y' and pay_left <> 0 and
                payments.category IN ('MT', 'CA'))  then
           --
           -- Check for magnetic tape payments.  Check they have been
           -- prenoted.
           --
           if payments.category = 'MT' and
              payments.validation_required = 'Y' then
             --
             valid_method := validate_magnetic(
                                        payments.personal_method,
                                        valid_date,
                                        payments.prenote_date,
                                        payments.org_method,
                                        p_assignment_action,
                                        payments.validation_value);

             --
           else
             --
             valid_method := true;
             --
           end if;
           --
          if valid_method = true then
             --
             pay_method(pay_left,
                        total_pay,
                        base_payment,
                        payments.percentage,
                        payments.amount,
                        payments.payment_currency);
             --
             -- Now if set up the correct exchange rate if required
             --
             --
             -- Now if there is anything to pay, create a payment record
             -- in the correct currency.  Also if required perform cash
             -- analysis.
             --
             if base_payment > 0
                or (negative_pay = 'Y' and
                      payments.category IN ('MT', 'CA'))  then
--
                create_payment(base_payment,
                               balance_currency,
                               payments.payment_currency,
             --                  exchange_rate,
                               payments.personal_method,
                               payments.org_method,
                               child_action_id,
                               payments.category,
                               payments.cash_rule,
                               chdrec.assignment_action_id,
                               master_action_id,
                               pay_left);
                -- Subtract the amount that was actually taken.
                p_pay_left := p_pay_left -
                      g_pre_payments(g_pre_payments.count).base_currency_value;

		end if;
           else
                if (found=true and upper(prenote_default)='Y')
                then
                  -- pay in default method
             	 pay_method(pay_left,
                        total_pay,
                        base_payment,
                        payments.percentage,
                        payments.amount,
                        payments.payment_currency);
             	--
             	-- Now if there is anything to pay, create a payment record
             	-- in the correct currency.  Also if required perform cash
             	-- analysis.
             	--
             	  if base_payment > 0
              	  or (negative_pay = 'Y' and
                      default_method.category IN ('MT', 'CA'))  then
	                create_payment(base_payment,
                               balance_currency,
                               default_method.currency,
                               null,
                               default_method.payment_method_id,
                               child_action_id,
                               default_method.category,
                               default_method.cash_rule,
                               chdrec.assignment_action_id,
                               master_action_id,
                               pay_left);
                  -- Subtract the amount that was actually taken.
                  p_pay_left := p_pay_left -
                      g_pre_payments(g_pre_payments.count).base_currency_value;

                  end if;
                end if;
           end if;
        end if;
      end loop;




--
       for payments in rt_org_methods(chdrec.run_type_id, p_effective_date,
                                    p_def_balance, chdrec.assignment_action_id)
       loop
--
         if (got_payment_amount = FALSE) then
           get_balance_value(p_def_balance,
                             chdrec.assignment_action_id,
                             total_pay);
           pay_left := total_pay;
           got_payment_amount := TRUE;
         end if;
--
         valid_date := (fnd_date.canonical_to_date(p_effective_date) -
                            payments.valid_days);
         --
         -- Pay this method.  Find out the amount of this payment and the
         -- pay left.
         --
         if pay_left > 0
            or (negative_pay = 'Y' and pay_left <> 0 and
                payments.category IN ('MT', 'CA'))  then
           --
           -- Check for magnetic tape payments.  Check they have been
           -- prenoted.
           --
           if payments.category = 'MT' and
              payments.validation_required = 'Y' then
             --
             valid_method := validate_magnetic(
                                        payments.personal_method,
                                        valid_date,
                                        payments.prenote_date,
                                        payments.org_method,
                                        p_assignment_action,
                                        payments.validation_value);

             --
           else
             --
             valid_method := true;
             --
           end if;
           --
           if valid_method = true  then
             --
             pay_method(pay_left,
                        total_pay,
                        base_payment,
                        payments.percentage,
                        payments.amount,
                        payments.payment_currency);
             --
             -- Now if set up the correct exchange rate if required
             --
             --
             -- Now if there is anything to pay, create a payment record
             -- in the correct currency.  Also if required perform cash
             -- analysis.
             --
             if base_payment > 0
                or (negative_pay = 'Y' and
                      payments.category IN ('MT', 'CA'))  then
--
                create_payment(base_payment,
                               balance_currency,
                               payments.payment_currency,
             --                  exchange_rate,
                               payments.personal_method,
                               payments.org_method,
                               child_action_id,
                               payments.category,
                               payments.cash_rule,
                               chdrec.assignment_action_id,
                               master_action_id,
                               pay_left);
                -- Subtract the amount that was actually taken.
                p_pay_left := p_pay_left -
                      g_pre_payments(g_pre_payments.count).base_currency_value;
             end if;
           else
                if (found=true and upper(prenote_default)='Y')
                then
                  -- pay in default method
                 pay_method(pay_left,
                        total_pay,
                        base_payment,
                        payments.percentage,
                        payments.amount,
                        payments.payment_currency);
                --
                -- Now if there is anything to pay, create a payment record
                -- in the correct currency.  Also if required perform cash
                -- analysis.
                --
                  if base_payment > 0
                  or (negative_pay = 'Y' and
                      default_method.category IN ('MT', 'CA'))  then
                        create_payment(base_payment,
                               balance_currency,
                               default_method.currency,
                               null,
                               default_method.payment_method_id,
                               child_action_id,
                               default_method.category,
                               default_method.cash_rule,
                               chdrec.assignment_action_id,
                               master_action_id,
                               pay_left);
                  -- Subtract the amount that was actually taken.
                  p_pay_left := p_pay_left -
                      g_pre_payments(g_pre_payments.count).base_currency_value;

                  end if;
                end if;
           end if;
        end if;
      end loop;
--
      -- OK, we've checked the run type payment methods now
      -- if this is a separate payment run, and if there is
      -- money left to be paid then use either the personal
      -- payment methods or the default payment method.
      if chdrec.run_method = 'S' then
--
         if (got_payment_amount = FALSE) then
           get_balance_value(p_def_balance,
                             chdrec.assignment_action_id,
                             total_pay);
           pay_left := total_pay;
           got_payment_amount := TRUE;
         end if;
--
         if (pay_left > 0 or
              (negative_pay = 'Y' and default_method.category in ('CA', 'MT'))) then
--
         declare
--
           payment_amount number;
         begin
--
            payment_amount := pay_left;
            -- Process the personal payment methods that are left.
            pay_per_payment_methods(child_action_id,
				    assign_id,
                                    p_effective_date,
                                    p_def_balance,
                                    total_pay,
                                    pay_left,
                                    chdrec.assignment_action_id,
				    master_action_id);
--
            p_pay_left := p_pay_left - (payment_amount - pay_left);
--
            if pay_left > 0
              or (negative_pay = 'Y' and default_method.category = 'CA')  then
              --
              base_payment := pay_left;
              pay_left := 0;
              --
              create_payment(base_payment,
                             balance_currency,
                             default_method.currency,
              --               default_method.exchange_rate,
                             null,
                             default_method.payment_method_id,
                             child_action_id,
                             default_method.category,
                             default_method.cash_rule,
                             chdrec.assignment_action_id,
                             master_action_id,
                             pay_left);
--
              if pay_left > 0 then
                hr_utility.set_message(801,'HR_6442_PAYM_MISSING_UNITS');
                hr_utility.raise_error;
              end if;
--
              p_pay_left := p_pay_left - base_payment;
            end if;
         end;
        end if;
       end if;
--
    end loop;
    hr_utility.trace('Exit pay_run_type_methods');
end pay_run_type_methods;
--
procedure process_per_payment(p_assignment_action   in number,
                              p_assignment          in number,
                              p_effective_date      in varchar2,
                              p_def_balance         in number,
                              p_pay_left            in out nocopy number)
is
base_payment number;
total_pay number;
begin
    total_pay := p_pay_left;
    -- Process the personal payment methods that are left.
    pay_per_payment_methods(p_assignment_action,
                            p_assignment,
                            p_effective_date,
                            p_def_balance,
                            total_pay,
                            p_pay_left);
--
    if p_pay_left > 0
      or (negative_pay = 'Y' and default_method.category = 'CA')  then
      --
      base_payment := p_pay_left;
      p_pay_left := 0;
      --
      create_payment(base_payment,
                     balance_currency,
                     default_method.currency,
      --               default_method.exchange_rate,
                     null,
                     default_method.payment_method_id,
                     p_assignment_action,
                     default_method.category,
                     default_method.cash_rule,
                     null,
                     null,
                     p_pay_left);
--
      if p_pay_left > 0 then
        hr_utility.set_message(801,'HR_6442_PAYM_MISSING_UNITS');
        hr_utility.raise_error;
      end if;
--
    end if;
--
end process_per_payment;
--
-------------------------- pay_personal_methods ------------------------------
/*
NAME
  pay_personal_methods
DESCRIPTION
  This distributes the payable amount over the personal payment methods
  as directed. If it is to be paid by magnetic tape do the required
  validation check. If there is not a payment method specified use the
  default method. If the amount is for a third party then get the payment
  method required and pay the value.
*/
procedure pay_personal_methods(p_assignment_action   in number,
                      p_assignment          in number,
                      p_effective_date      in varchar2,
                      p_def_balance         in number,
                      p_balance_value       in varchar2,
                      p_master_aa_id        in     number) is

base_payment number;
total_pay number;
pay_left number;
begin
--
    hr_utility.trace('Enter pay_personal_methods');
    g_pre_payments.delete;
    total_pay := fnd_number.canonical_to_number(p_balance_value);
    pay_left := total_pay;
--
    -- Process any payment methods associated with the
    -- Run Types
    pay_run_type_methods(p_assignment_action,
                         p_effective_date,
                         p_def_balance,
                         pay_left,
			 p_master_aa_id);
--
    process_per_payment(p_assignment_action,
                        p_assignment,
                        p_effective_date,
                        p_def_balance,
                        pay_left);
--
    flush_payments;
--
    hr_utility.trace('Exit pay_personal_methods');
end pay_personal_methods;
--
-------------------------- pay_run_type_override ----------------------------- -
/*
NAME
  pay_run_type_override
DESCRIPTION
  This distributes the payable amount using the override method
  over the pay separately run types.
*/
procedure pay_run_type_override(p_assignment_action   in     number,
                               p_def_balance         in     number,
                               p_pay_left            in out nocopy number,
                               p_master_aa_id        in     number) is

cursor chdact is
select paa_chd.assignment_action_id, paa_chd.run_type_id, prt.run_method,paa_chd.assignment_id
from pay_assignment_actions paa_par,
     pay_action_interlocks  pai,
     pay_assignment_actions paa_chd,
     pay_payroll_actions    ppa_chd,
     pay_run_types_f        prt
where paa_par.assignment_action_id = p_assignment_action
and   paa_par.assignment_action_id = pai.locking_action_id
and   pai.locked_action_id         = paa_chd.assignment_action_id
and   paa_chd.run_type_id is not null
and   paa_chd.run_type_id = prt.run_type_id
and   ppa_chd.payroll_action_id = paa_chd.payroll_action_id
and   ppa_chd.effective_date between prt.effective_start_date
                                 and prt.effective_end_date
order by paa_chd.action_sequence;
--
total_pay number;
pay_left number;
master_action_id number;
child_action_id number;
assign_id number;
--
begin
--
    hr_utility.trace('Enter pay_run_type_override');
--
    for chdrec in chdact loop
--
     if chdrec.run_method = 'S' then
--
       get_balance_value(p_def_balance,
                         chdrec.assignment_action_id,
                         total_pay);
       pay_left := 0;
--
      hr_utility.trace('Found Child Type '||chdrec.run_method);
--
      -- OK, we've checked the run type payment methods now
      -- if this is a separate payment run, and if there is
      -- money left to be paid then use either the personal
      -- payment methods or the default payment method.
--
      if
         (total_pay > 0
          or (negative_pay = 'Y' and total_pay <> 0 and
              override.category  = 'CA'))  then
--
        hr_utility.trace('Paying Run Override of '||total_pay);
--
        child_action_id := p_assignment_action;
        master_action_id := p_master_aa_id;
--
        create_payment(total_pay,
                       balance_currency,
                       override.currency,
        --               override.exchange_rate,
                       null,
                       override.payment_method_id,
                       child_action_id,
                       override.category,
                       override.cash_rule,
                       chdrec.assignment_action_id,
                       master_action_id,
                       pay_left);
--
        if pay_left > 0 then
          hr_utility.set_message(801,'HR_6442_PAYM_MISSING_UNITS');
          hr_utility.raise_error;
        end if;
--
        p_pay_left := p_pay_left - total_pay;
--
      end if;
     end if;
--
    end loop;
    hr_utility.trace('Exit pay_run_type_override');
--
end pay_run_type_override;
--
procedure process_run_types(p_override_method   in number,
                            p_assignment_action in number,
                            p_def_balance       in number,
                            p_effective_date    in varchar2,
                            p_master_aa_id      in number,
                            p_pay_left          in out nocopy number)
is
begin
--
   g_pre_payments.delete;
--
   if (p_override_method is not null) then
      pay_run_type_override(p_assignment_action,
                           p_def_balance,
                           p_pay_left,
                           p_master_aa_id);
   else
      pay_run_type_methods(p_assignment_action,
                           p_effective_date,
                           p_def_balance,
                           p_pay_left,
                           p_master_aa_id);
   end if;
--
   flush_payments;
end process_run_types;
--
procedure process_ovr_payment(p_assignment_action in number,
                              p_pay_left in out nocopy number)
is
base_value number;
begin
  base_value := p_pay_left;
  p_pay_left := 0;
    --
    -- If the base_value is non-zero then insert a p  ayment record in the
    -- payment currency.  Also if the category is cash then perform cash
    -- analysis.
    --
    --
    if base_value > 0
        or (negative_pay = 'Y' and base_value <> 0 and
            override.category  = 'CA')  then
      create_payment(base_value,
                     balance_currency,
                     override.currency,
      --               override.exchange_rate,
                     null,
                     override.payment_method_id,
                     p_assignment_action,
                     override.category,
                     override.cash_rule,
                     null,
                     null,
                     p_pay_left);
--
      if p_pay_left > 0 then
        hr_utility.set_message(801,'HR_6442_PAYM_MISSING_UNITS');
        hr_utility.raise_error;
      end if;
    end if;
end process_ovr_payment;
--
procedure process_normal_payments(p_override_method   in number,
                                  p_assignment_action in number,
                                  p_assignment        in number,
                                  p_def_balance       in number,
                                  p_effective_date    in varchar2,
                                  p_pay_left          in out nocopy number)
is
begin
--
   hr_utility.trace('Enter process_normal_payments');
--
   g_pre_payments.delete;
   if (p_override_method is not null) then
      process_ovr_payment(p_assignment_action,
                          p_pay_left);
   else
      process_per_payment(p_assignment_action,
                          p_assignment,
                          p_effective_date,
                          p_def_balance,
                          p_pay_left);
   end if;
--
   flush_payments;
--
   hr_utility.trace('Exit process_normal_payments');
end process_normal_payments;
--
-------------------------- pay_override_method -------------------------------
/*
NAME
  pay_override_method
DESCRIPTION
  This uses the overiding payment method to pay the payment amount unless
  it is a third party payment, in which case it will pay by the personal
  payment method specified for the payment.
*/
procedure pay_override_method(p_assignment_action in number,
                              p_balance_value     in varchar2,
                              p_def_balance       in number,
                              p_master_aa_id      in     number) is

base_value number;
pay_left number;

begin
--
  g_pre_payments.delete;
--
  --
  -- First pay the pay separate runs to the override method
  --
  pay_left := fnd_number.canonical_to_number(p_balance_value);
  pay_run_type_override(p_assignment_action,
                        p_def_balance,
                        pay_left,
			p_master_aa_id);
  --
  -- The remaining amount should be paid by the override payment methods.
  --
  process_ovr_payment(p_assignment_action,
                      pay_left);
--
    flush_payments;
--
end pay_override_method;
--
-------------------------- get_run_result_value ------------------------------
/*
NAME
  get_run_result_value
DESCRIPTION
  This retrieves the value of a third party payment and the element entry
  id that it is based on.
*/
procedure get_run_result_value(p_run_result       in number,
                               p_effective_date   in varchar2,
                               p_run_result_value    out nocopy varchar2,
                               p_entry               out nocopy number) is
res_value number;
entry number;
status varchar2(2);
adj_value number;
assign_id number;
assign_action_id number;
pay_act_id number;
run_date_earned date;
begin
  --
  -- Bug 1849996. This code now assumes that a no data found
  -- means that a zero payment is to be made. Legislation
  -- teams have been warned that this may have to change
  -- in future. They should explicitly set the Pay Value
  -- to zero for a non pament.
  --
  begin
     select prr.source_id,
            fnd_number.canonical_to_number(rrv.result_value),
            prr.status,
            paa.assignment_id,
            prr.assignment_action_id,
            paa.payroll_action_id,
            ppa.date_earned
     into   entry,
            res_value,
            status,
            assign_id,
            assign_action_id,
            pay_act_id,
            run_date_earned
     from
            pay_input_values_f    piv,
            pay_element_types_f   pet,
            pay_run_result_values rrv,
            pay_run_results       prr2,
            pay_run_results       prr,
            pay_assignment_actions  paa,
            pay_payroll_actions   ppa
     where  prr.run_result_id        = p_run_result
     and    paa.assignment_action_id= prr.assignment_action_id
     and    ppa.payroll_action_id    = paa.payroll_action_id
     and    pet.element_type_id      = prr2.element_type_id
     and    pet.THIRD_PARTY_PAY_ONLY_FLAG = 'Y'
     and    prr.source_id            = prr2.source_id
     and    prr.assignment_action_id = prr2.assignment_action_id
     and    prr2.source_type        in ('E','I')
     and    prr2.entry_type     not in ('R','A')
     and    prr2.run_result_id       = rrv.run_result_id
     and    rrv.input_value_id       = piv.input_value_id
     and    rrv.result_value is not null
     and    piv.name                 = 'Pay Value'
     and    ppa.date_earned between piv.effective_start_date
                                and piv.effective_end_date
     and    ppa.date_earned between pet.effective_start_date
                                and pet.effective_end_date
     and    (( prr.source_type = prr2.source_type and
               decode (pet.proration_group_id, null, 1, prr.run_result_id) =
               decode (pet.proration_group_id, null, 1, prr2.run_result_id))
          or ( prr.source_type <> prr2.source_type)) ;
  exception
     when no_data_found then
       entry:= null;
       res_value := 0;
       status := null;
       assign_id := null;
       assign_action_id := null;
       pay_act_id := null;
  end;
--
if status in ('PA', 'R')
then
     --
     /* Does the RR source Id point to the target or the adjustment */
     if (g_adjust_ee_source = 'T') then
       select fnd_number.canonical_to_number(rrv.result_value)
       into   adj_value
       from
              pay_input_values_f    piv,
              pay_element_types_f   pet,
              pay_run_result_values rrv,
              pay_run_results       prr2,
              pay_run_results       prr
       where  prr.run_result_id        = p_run_result
       and    prr.assignment_action_id = assign_action_id
       and    pet.element_type_id      = prr2.element_type_id
       and    pet.THIRD_PARTY_PAY_ONLY_FLAG = 'Y'
       and    prr.source_id            = prr2.source_id
       and    prr.assignment_action_id = prr2.assignment_action_id
       and    prr2.source_type        in ('E','I')
       and    prr2.entry_type         in ('R','A')
       and    prr.entry_type      not in ('R','A')
       and    prr2.run_result_id       = rrv.run_result_id
       and    rrv.input_value_id       = piv.input_value_id
       and    rrv.result_value is not null
       and    piv.name                 = 'Pay Value'
       and    nvl(run_date_earned, fnd_date.canonical_to_date(p_effective_date)) between
              piv.effective_start_date and piv.effective_end_date
       and    nvl(run_date_earned, fnd_date.canonical_to_date(p_effective_date)) between
              pet.effective_start_date and pet.effective_end_date;
    else
     select fnd_number.canonical_to_number(rrv.result_value)
     into   adj_value
     from
            pay_element_entries_f pee,
            pay_input_values_f    piv,
            pay_element_types_f   pet,
            pay_run_result_values rrv,
            pay_run_results       prr2,
            pay_run_results       prr
     where  pee.target_entry_id=entry
     and    pee.assignment_id = assign_id
     and    prr.source_id=pee.element_entry_id
     and    prr.assignment_action_id = assign_action_id
     and    pet.element_type_id      = prr2.element_type_id
     and    pet.THIRD_PARTY_PAY_ONLY_FLAG = 'Y'
     and    prr.source_id            = prr2.source_id
     and    prr.assignment_action_id = prr2.assignment_action_id
     and    prr2.source_type        in ('E','I')
     and    prr2.run_result_id       = rrv.run_result_id
     and    rrv.input_value_id       = piv.input_value_id
     and    rrv.result_value is not null
     and    piv.name                 = 'Pay Value'
     and    nvl(run_date_earned, fnd_date.canonical_to_date(p_effective_date)) between
            piv.effective_start_date and piv.effective_end_date
     and    nvl(run_date_earned, fnd_date.canonical_to_date(p_effective_date)) between
            pet.effective_start_date and pet.effective_end_date
     and    nvl(run_date_earned, fnd_date.canonical_to_date(p_effective_date)) between
            pee.effective_start_date and pee.effective_end_date;
    end if;
end if;
--
     if (status = 'R')
     then
       p_run_result_value := fnd_number.number_to_canonical(adj_value);
     elsif (status =  'PA')
     then
     p_run_result_value := fnd_number.number_to_canonical(adj_value)+fnd_number.number_to_canonical(res_value);
     else
       p_run_result_value := fnd_number.number_to_canonical(res_value);
     end if;
     p_entry := entry;
end get_run_result_value;
--
-------------------------- pay_third_party -----------------------------------
/*
NAME
  pay_third_party
DESCRIPTION
  This retrieves a single payment method that is to be used for this third
  party payment and then pays the this method the full payable amount.
*/
procedure pay_third_party(p_run_results       in number,
                          p_assignment_action in number,
                          p_effective_date    in varchar2,
                          p_bal_value         in varchar2,
                          p_master_aa_id      in number
			  ) is

payment_details g_pp_methods%rowtype;
valid_method boolean;
exchange_rate number;
pay_left number;
valid_date date;
child_action_id number;
master_action_id number;
begin
--
    g_pre_payments.delete;
    pay_left := 0;
--
    select ppt.category                             category,
           ppm.personal_payment_method_id           personal_method,
           pea.prenote_date                         prenote_date,
           ppt.validation_days                      valid_days,
           ppm.percentage                           percentage,
           ppm.amount                               amount,
           opm.org_payment_method_id                org_method,
           hr_pre_pay.set_cash_rule(ppt.category,
                         opm.pmeth_information1)    cash_rule,
           opm.currency_code                        payment_currency,
           ppt.pre_validation_required              validation_required,
           ppt.validation_value                     validation_value,
           ppm.external_account_id                  external_account_id
    into   payment_details
    from   pay_run_results                prr,
           pay_element_entries_f          pee,
           pay_personal_payment_methods_f ppm,
           pay_external_accounts          pea,
           pay_org_payment_methods_f      opm,
           pay_payment_types              ppt,
           pay_assignment_actions         paa,
           pay_payroll_actions            ppa
    where  prr.run_result_id = p_run_results
    and    prr.source_id     = pee.element_entry_id
    and    paa.assignment_action_id = prr.assignment_action_id
    and    paa.payroll_action_id    = ppa.payroll_action_id
    and    pee.personal_payment_method_id = ppm.personal_payment_method_id
    and    ppm.org_payment_method_id = opm.org_payment_method_id
    and    opm.payment_type_id = ppt.payment_type_id
    and    ppm.external_account_id = pea.external_account_id (+)
--    and    opm.pmeth_information1 = hlu.lookup_code (+)
--    and    NVL(hlu.lookup_type, 'CASH_ANALYSIS') = 'CASH_ANALYSIS'
--    and    NVL(hlu.application_id, 800) = 800
    and    fnd_date.canonical_to_date(p_effective_date)  between
                  ppm.effective_start_date and ppm.effective_end_date
    and    fnd_date.canonical_to_date(p_effective_date) between
                  opm.effective_start_date and opm.effective_end_date
    and    ppa.date_earned between
                  pee.effective_start_date and pee.effective_end_date
    order by ppm.priority;
--
  if fnd_number.canonical_to_number(p_bal_value) <> 0  then
     valid_date := (fnd_date.canonical_to_date(p_effective_date) -
                        payment_details.valid_days);
  --
  -- Check magnetic tape payments for prenote.
  --
    if payment_details.category = 'MT' and
       payment_details.validation_required = 'Y' then
      --
      valid_method := validate_magnetic(payment_details.personal_method,
                                        valid_date,
                                        payment_details.prenote_date,
                                        payment_details.org_method,
                                        p_assignment_action,
                                        payment_details.validation_value);
      --
    else
      --
      valid_method := true;
      --
    end if;
    --
    if valid_method = true then
    --
       --
       if fnd_number.canonical_to_number(p_bal_value) > 0
           or (negative_pay = 'Y' and
               payment_details.category IN ('MT', 'CA'))  then
       --
         declare
           rt_method pay_run_types_f.run_method%type;
           sep_chq_aa_id pay_assignment_actions.assignment_action_id%type;
         begin
           --
           -- Get the run method
           select nvl(prt.run_method, 'N'), paa.assignment_action_id
             into rt_method,
                  sep_chq_aa_id
             from pay_run_types_f        prt,
                  pay_assignment_actions paa,
                  pay_run_results        prr,
                  pay_payroll_actions    ppa
           where prr.run_result_id = p_run_results
             and prr.assignment_action_id = paa.assignment_action_id
              and paa.payroll_action_id = ppa.payroll_action_id
              and nvl(paa.run_type_id, -999) = prt.run_type_id (+)
              and ppa.effective_date between nvl(prt.effective_start_date, ppa.effective_date)
                                         and nvl(prt.effective_end_date, ppa.effective_date);
           --
           if (rt_method <> 'S' ) then
              sep_chq_aa_id := null;
           end if;
--
            child_action_id := p_assignment_action;
            master_action_id := p_master_aa_id;
--
           create_payment(fnd_number.canonical_to_number(p_bal_value),
                          balance_currency,
                          payment_details.payment_currency,
           --               exchange_rate,
                          payment_details.personal_method,
                          payment_details.org_method,
                          child_action_id,
                          payment_details.category,
                          payment_details.cash_rule,
                          sep_chq_aa_id,
                          master_action_id,
                          pay_left);
--
            if pay_left > 0 then
              hr_utility.set_message(801,'HR_6442_PAYM_MISSING_UNITS');
              hr_utility.raise_error;
            end if;
--
         end;
       end if;
    else
       -- invalid pay method.
       hr_utility.set_message(801,'HR_7723_PAYM_NO_PAY_METHOD');
       hr_utility.raise_error;
       --
    end if;
    --
  end if;
--
  flush_payments;
  --
exception
  when NO_DATA_FOUND then
     hr_utility.set_message(801,'HR_7723_PAYM_NO_PAY_METHOD');
     hr_utility.raise_error;
end pay_third_party;
--
   ------------------- get_dynamic_org_method -------------------
   /*
      NAME
         get_dynamic_org_method
      DESCRIPTION
         Given a legislative procedure name and the assignment action,
         this procedure calculated the organisation method id when
         the external account is null.
   */
--
procedure get_dynamic_org_method (p_plsql_proc in varchar2,
                                    p_assignment_action in number,
                                    p_effective_date in date,
                                    p_org_meth in number,
                                    p_org_method_id out nocopy number )
is
l_def_rt_str        varchar2(2000);  -- used with dynamic pl/sql
sql_cursor           integer;
l_rows               integer;
l_org_method_id      number;
l_paytype            number;
l_ext_acc            number(16);
begin
   l_def_rt_str := 'begin '||p_plsql_proc||' (';
   l_def_rt_str := l_def_rt_str || ':p_assignment_action, ';
   l_def_rt_str := l_def_rt_str || ':p_effective_date, ';
   l_def_rt_str := l_def_rt_str || ':p_org_meth, ';
   l_def_rt_str := l_def_rt_str || ':l_org_method_id); end; ';
   --
   sql_cursor := dbms_sql.open_cursor;
   --
   dbms_sql.parse(sql_cursor, l_def_rt_str, dbms_sql.v7);
   --
   dbms_sql.bind_variable(sql_cursor, 'p_assignment_action', p_assignment_action);
   --
   dbms_sql.bind_variable(sql_cursor, 'p_effective_date', p_effective_date);
   --
   dbms_sql.bind_variable(sql_cursor, 'p_org_meth', p_org_meth);
   --
   dbms_sql.bind_variable(sql_cursor, 'l_org_method_id', l_org_method_id);
   --
   l_rows := dbms_sql.execute (sql_cursor);
   --
   if (l_rows = 1) then
      dbms_sql.variable_value(sql_cursor, 'l_org_method_id',
                              l_org_method_id);
      dbms_sql.close_cursor(sql_cursor);
--
--    Check that procedure returns a payment method with the same
--    payment type as the original payment method.
--    Also currency needs to be the same.
--
      select count(*)
        into l_paytype
        from pay_org_payment_methods_f opm1
            ,pay_org_payment_methods_f opm2
       where opm1.org_payment_method_id = p_org_meth
         and opm2.org_payment_method_id = l_org_method_id
         and opm1.payment_type_id = opm2.payment_type_id
         and opm1.currency_code   = opm2.currency_code
         and p_effective_date between opm1.effective_start_date
                                  and opm1.effective_end_date
         and p_effective_date between opm2.effective_start_date
                                  and opm2.effective_end_date;
--
--    Check that the new payment method does not have a null bank account
--
      select count(*)
         into l_ext_acc
         from pay_org_payment_methods_f opm
        where opm.org_payment_method_id = l_org_method_id
          and opm.external_account_id is not null
          and p_effective_date between opm.effective_start_date
                                   and opm.effective_end_date;

     if ((l_paytype = 0) or (l_ext_acc = 0)) then
        hr_utility.set_message(801,'HR_50412_INVALID_ORG_PAYMETH');
        hr_utility.raise_error;
     end if;
--
   else
        dbms_sql.close_cursor(sql_cursor);
        hr_utility.set_message(801,'HR_50412_INVALID_ORG_PAYMETH');
        hr_utility.raise_error;
   end if;
--
   p_org_method_id := l_org_method_id;
--
end get_dynamic_org_method;
--
--
procedure close_cursors is
begin
   if(g_third_party%ISOPEN) then
       close g_third_party;
   end if;
   if (coin_cursor%ISOPEN) then
       close coin_cursor;
   end if;
end close_cursors;
--
procedure process_org_third_party(p_asg_act       in number,
                                  p_eff_date      in varchar2,
                                  p_master_aa_id  in number)
is
--
cursor get_opms(p_asg_action in number,
                p_org_id     in number)
is
select
           ppt.category                             category,
           null                                     personal_method,
           pea.prenote_date                         prenote_date,
           ppt.validation_days                      valid_days,
           100                                      percentage,
           null                                     amount,
           popm_par.org_payment_method_id           org_method,
           hr_pre_pay.set_cash_rule(ppt.category,
                         popm_par.pmeth_information1)    cash_rule,
           popm_par.currency_code                   payment_currency,
           ppt.pre_validation_required              validation_required,
           ppt.validation_value                     validation_value,
           popm_par.external_account_id             external_account_id,
           popm.defined_balance_id                  defined_balance_id,
           popm.org_payment_method_id               payee_org_method,
           popm.time_definition_id                  time_def_id,
           decode(popm.time_definition_id,
                  null, null,
                  pay_core_dates.get_time_definition_date(
                              popm.time_definition_id,
                              ppa.effective_date,
                              ppa.business_group_id)) payment_date
      from
       pay_external_accounts              pea,
       pay_payment_types                  ppt,
       pay_org_payment_methods_f          popm,
       pay_org_payment_methods_f          popm_par,
       pay_org_pay_method_usages_f        popmu,
       pay_assignment_actions             paa,
       pay_payroll_actions                ppa
 where paa.assignment_action_id = p_asg_action
   and paa.payroll_action_id = ppa.payroll_action_id
   and popm.organization_id = p_org_id
   and popm.type = 'PAYEE'
   and popm.parent_org_payment_method_id = popm_par.org_payment_method_id
   and popm_par.org_payment_method_id = popmu.org_payment_method_id
   and ppa.payroll_id = popmu.payroll_id
   and popm.external_account_id = pea.external_account_id (+)
   and popm_par.payment_type_id = ppt.payment_type_id
   and ppa.effective_date between popmu.effective_start_date
                              and popmu.effective_end_date
   and ppa.effective_date between popm.effective_start_date
                              and popm.effective_end_date
   and ppa.effective_date between popm_par.effective_start_date
                              and popm_par.effective_end_date;
--
-- Bug 8262632
-- Removed optimizer hints from the cursor get_orgs for performance concern
--

cursor get_orgs (p_asg_action in number,
                 p_org_context_name in varchar2)
is
select distinct (prrv.result_value) organization_id
  from pay_run_result_values  prrv,
       pay_input_values_f     piv,
       pay_run_results        prr,
       pay_assignment_actions paa,
       pay_payroll_actions    ppa,
       pay_action_interlocks  pai
 where pai.locking_action_id = p_asg_action
   and pai.locked_action_id = paa.assignment_action_id
   and paa.assignment_action_id = prr.assignment_action_id
   and paa.payroll_action_id = ppa.payroll_action_id
   and prr.run_result_id = prrv.run_result_id
   and prrv.input_value_id = piv.input_value_id
   and ppa.effective_date between piv.effective_start_date
                              and piv.effective_end_date
   and piv.name = p_org_context_name;
--
valid_method boolean;
exchange_rate number;
pay_left number;
valid_date date;
child_action_id number;
master_action_id number;
l_bal_value number;
l_org_context_name pay_legislation_contexts.input_value_name%type;
--
begin
--
    hr_utility.trace('Enter process_org_third_party');
--
    g_pre_payments.delete;
    pay_left := 0;
--
    l_org_context_name := pay_core_utils.get_context_iv_name(p_asg_act,
                                              'ORGANIZATION_ID');
--
   for orgrec in get_orgs (p_asg_act, l_org_context_name) loop
--
      hr_utility.trace('Process Org '||orgrec.organization_id);
--
      for payments in get_opms(p_asg_act, orgrec.organization_id) loop
--
         get_balance_value(p_def_balance         => payments.defined_balance_id,
                           p_assignment_actions  => p_asg_act,
                           p_balance_value       => l_bal_value,
                           p_org_id              => orgrec.organization_id);
--
         hr_utility.trace('Amount to Pay '||l_bal_value);
         hr_utility.trace('Time Def '||payments.time_def_id);
         hr_utility.trace('Payment Date '||payments.payment_date);
--
         if fnd_number.canonical_to_number(l_bal_value) <> 0  then
            valid_date := (fnd_date.canonical_to_date(p_eff_date) -
                               payments.valid_days);
         --
         -- Check magnetic tape payments for prenote.
         --
           if payments.category = 'MT' and
              payments.validation_required = 'Y' then
             --
             valid_method := validate_magnetic(payments.personal_method,
                                               valid_date,
                                               payments.prenote_date,
                                               payments.org_method,
                                               p_asg_act,
                                               payments.validation_value,
                                               orgrec.organization_id,
                                               payments.payee_org_method);
             --
           else
             --
             valid_method := true;
             --
           end if;
           --
           --
           if valid_method = true then
           --
              --
              if fnd_number.canonical_to_number(l_bal_value) > 0
                  or (negative_pay = 'Y' and
                      payments.category IN ('MT', 'CA'))  then
              --
                  child_action_id := p_asg_act;
                  master_action_id := p_master_aa_id;
                  create_payment(fnd_number.canonical_to_number(l_bal_value),
                                 balance_currency,
                                 payments.payment_currency,
                  --               exchange_rate,
                                 payments.personal_method,
                                 payments.org_method,
                                 child_action_id,
                                 payments.category,
                                 payments.cash_rule,
                                 null,
                                 master_action_id,
                                 pay_left,
                                 orgrec.organization_id,
                                 payments.payee_org_method,
                                 payments.payment_date);
--
                   if pay_left > 0 then
                     hr_utility.set_message(801,'HR_6442_PAYM_MISSING_UNITS');
                     hr_utility.raise_error;
                   end if;
--
              end if;
           else
              -- invalid pay method.
              hr_utility.set_message(801,'HR_7723_PAYM_NO_PAY_METHOD');
              hr_utility.raise_error;
              --
           end if;
           --
         end if;
--
         flush_payments;
--
--
      end loop;
--
   end loop;
--
   hr_utility.trace('Exit process_org_third_party');
--
end process_org_third_party;
--
procedure process_third_party(p_asg_act       in number,
                              p_eff_date      in varchar2,
                              p_master_aa_id  in number)
is
do_process   boolean;
l_element_id number;
l_run_result number;
l_bal_value  varchar2(60);
l_entry      number;
l_assignment_id number;
begin
--
   hr_utility.trace('Enter process_third_party');
--
   do_process := TRUE;
   while (do_process = TRUE) loop
     begin
       get_third_party_details(p_asg_act,
                               p_eff_date,
                               l_element_id,
                               l_run_result,
                               l_assignment_id);
     exception
       when no_data_found then
          do_process := FALSE;
     end;
--
     if (do_process = TRUE) then
--
       get_run_result_value(l_run_result,
                            p_eff_date,
                            l_bal_value,
                            l_entry);
       pay_third_party(l_run_result,
                       p_asg_act,
                       p_eff_date,
                       l_bal_value,
                       p_master_aa_id
                       );
--
     end if;
   end loop;
--
   process_org_third_party(p_asg_act       => p_asg_act,
                           p_eff_date      => p_eff_date,
                           p_master_aa_id  => p_master_aa_id
                          );
--
   hr_utility.trace('Exit process_third_party');
--
end process_third_party;
--
procedure process_action(p_asg_act  in number,
                      p_eff_date in varchar2,
                      p_ma_flag  in number,
                      p_def_bal_id in number,
                      p_asg_id     in number,
                      p_override_meth in number,
                      p_master_aa_id in number,
                      p_pay_left in out nocopy number)
is
l_bal_value number;
begin
--
  process_third_party(p_asg_act,
                      p_eff_date,
                      p_master_aa_id);
--
  get_balance_value(p_def_bal_id,
                    p_asg_act,
                    l_bal_value);
--
  -- OK about to remove this amount from the pay left
  p_pay_left := p_pay_left - l_bal_value;
--
  if (p_override_meth is not null) then
    pay_override_method(p_asg_act,
                        l_bal_value,
                        p_def_bal_id,
                        p_master_aa_id);
  else
    pay_personal_methods(p_asg_act,
                         p_asg_id,
                         p_eff_date,
                         p_def_bal_id,
                         l_bal_value,
                         p_master_aa_id
                        );
  end if;
end process_action;
--
procedure create_child_interlocks(p_run_act_id    in number,
                                  p_pre_action_id in number
                                 )
is
  cursor get_child_actions(p_run_act_id number)
  is
  select chld.assignment_action_id
    from pay_assignment_actions chld,
         pay_assignment_actions mas
   where mas.assignment_action_id = p_run_act_id
     and mas.assignment_action_id = chld.source_action_id
     and mas.payroll_action_id = chld.payroll_action_id
     and mas.assignment_id = chld.assignment_id;
begin
   for chdrec in get_child_actions(p_run_act_id) loop
     hr_nonrun_asact.insint(p_pre_action_id,chdrec.assignment_action_id);
     create_child_interlocks(chdrec.assignment_action_id, p_pre_action_id);
   end loop;
end create_child_interlocks;
--
procedure create_child_actions(p_asg_act in number,
                               p_ma_flag in number,
                               p_multi_gre_payment in varchar2,
                               p_multi_gre out nocopy boolean)
is
--
/* Return all the tax unit assignment actions of the Run when there
   are more than one tax unit interlocked
*/
cursor get_tu_child (p_action in number) is
select paa.assignment_action_id,
       paa.assignment_id,
       paa_mas.payroll_action_id pre_payroll_action_id,
       paa.tax_unit_id run_tax_unit_id,
       paa_mas.chunk_number pre_chunk_number
from pay_action_interlocks pai,
     pay_assignment_actions paa,
     pay_assignment_actions paa_mas
where pai.locking_action_id = paa_mas.assignment_action_id
and   paa_mas.assignment_action_id = p_action
and   pai.locked_action_id = paa.assignment_action_id
and   exists (select ''
                from pay_action_interlocks pai2,
                     pay_assignment_actions paa2
               where pai2.locking_action_id = paa_mas.assignment_action_id
                 and pai2.locked_action_id = paa2.assignment_action_id
                 and paa2.tax_unit_id <> paa.tax_unit_id)
order by paa.tax_unit_id;
--
cursor get_mlt_asg (p_action in number) is
select paa.assignment_action_id,
       paa.assignment_id,
       paa_mas.payroll_action_id pre_payroll_action_id,
       paa.tax_unit_id run_tax_unit_id,
       paa_mas.chunk_number pre_chunk_number,
       paa.start_date start_date,
       paa.end_date end_date
from pay_action_interlocks pai,
     pay_assignment_actions paa,
     pay_assignment_actions paa_mas
where pai.locking_action_id = paa_mas.assignment_action_id
and   paa_mas.assignment_action_id = p_action
and   pai.locked_action_id = paa.assignment_action_id
--
-- North America can only handle child actions on
-- multiple assignment payrolls
--
--and   exists  (select ''
--                from pay_action_interlocks pai2,
--                     pay_assignment_actions paa2
--               where pai2.locking_action_id = paa_mas.assignment_action_id
--                 and pai2.locked_action_id = paa2.assignment_action_id
--                 and paa2.assignment_id <> paa.assignment_id)
order by paa.assignment_id;
--
prev_tu       number;
prev_asg_id   number;
found_tu      boolean;
pre_tu_actid  number;
pre_asg_actid number;
--
begin
--
   hr_utility.trace('Enter create_child_actions');
--
   prev_tu := -1;
--
   found_tu := FALSE;
--
   -- Does the legislation or payroll allow multi gre's
   -- to be paid together.
--
   if (p_multi_gre_payment = 'N') then
     for turec in get_tu_child(p_asg_act) loop
--
       hr_utility.trace('Found Pro Asg '||turec.assignment_id||' '||
                         'TU ='||turec.run_tax_unit_id);
--
       found_tu := TRUE;
--
       if (prev_tu <> turec.run_tax_unit_id) then
--
            select pay_assignment_actions_s.nextval
            into   pre_tu_actid
            from   dual;
            --
            hr_nonrun_asact.insact(pre_tu_actid,
                                   turec.assignment_id,
                                   turec.pre_payroll_action_id,
                                   turec.pre_chunk_number,
                                   turec.run_tax_unit_id,
                                   null,
                                   'C',
                                   p_asg_act,
                                   null,
                                   null,
                                   null,
                                   null);
--
            hr_nonrun_asact.insint(pre_tu_actid,turec.assignment_action_id);
--
            prev_tu := turec.run_tax_unit_id;
--
       else
          hr_nonrun_asact.insint(pre_tu_actid,turec.assignment_action_id);
       end if;
     end loop;
   end if;
--
   /* The code is not setup to handle multi tax units and multi assignments
   */
   if (found_tu = TRUE
       and p_ma_flag = 1) then
     hr_general.assert_condition(FALSE);
   end if;

   if (found_tu = FALSE
       and p_ma_flag = 1) then
--
      prev_asg_id := -1;
--
      for asgrec in get_mlt_asg(p_asg_act) loop
--
        hr_utility.trace('Found Non Pro Asg '||asgrec.assignment_id);
--
        if (prev_asg_id <> asgrec.assignment_id) then
          select pay_assignment_actions_s.nextval
          into   pre_asg_actid
          from   dual;
          --
          hr_nonrun_asact.insact(pre_asg_actid,
                                 asgrec.assignment_id,
                                 asgrec.pre_payroll_action_id,
                                 asgrec.pre_chunk_number,
                                 asgrec.run_tax_unit_id,
                                 null,
                                 'C',
                                 p_asg_act,
                                 null,
                                 null,
                                 null,
                                 null);
--
          hr_nonrun_asact.insint(pre_asg_actid,asgrec.assignment_action_id);
--
          prev_asg_id := asgrec.assignment_id;
        else
           hr_nonrun_asact.insint(pre_asg_actid,asgrec.assignment_action_id);
        end if;
      end loop;
--
   end if;
--
   p_multi_gre := found_tu;
--
   hr_utility.trace('Exit create_child_actions');
--
end create_child_actions;
--
procedure do_prepayment(p_asg_act in number,
                        p_effective_date varchar2,
                        p_ma_flag  in number,
                        p_def_bal_id in number,
                        p_asg_id in number,
                        p_override_meth in number,
                        p_multi_gre_payment in varchar2)
is
--
cursor get_pp_chld (p_asg_act number) is
select paa_chd.assignment_action_id,
       paa_chd.start_date
  from pay_assignment_actions paa_chd,
       pay_assignment_actions paa_mas
 where paa_mas.assignment_action_id = p_asg_act
   and paa_mas.assignment_action_id = paa_chd.source_action_id
   and paa_mas.payroll_action_id = paa_chd.payroll_action_id
   and paa_mas.chunk_number = paa_chd.chunk_number;
--
cursor get_legislation_rule is
select validation_name, rule_type
  from pay_legislative_field_info
 where field_name = 'MULTI_TAX_UNIT_PAYMENT'
   and validation_type = 'ITEM_PROPERTY'
   and target_location = 'PAYWSDOR'
   and rule_mode = 'Y'
   and legislation_code =
         (select hr_api.return_legislation_code(ppa.business_group_id)
            from pay_payroll_actions ppa, pay_assignment_actions paa
           where paa.payroll_action_id = ppa.payroll_action_id
             and paa.assignment_action_id = p_asg_act);
--
l_eff_date          date;
l_pay_left          number;
child_processed     boolean;
l_multi_gre         boolean;
--
begin
--
   hr_utility.trace('Enter do_prepayment');
   l_eff_date := fnd_date.canonical_to_date(p_effective_date);
   child_processed := FALSE;
--
   create_child_actions(p_asg_act,
                        p_ma_flag,
                        p_multi_gre_payment,
                        l_multi_gre);
--
   get_balance_value(p_def_bal_id,
                     p_asg_act,
                     l_pay_left);
--
   for chdrec in get_pp_chld(p_asg_act) loop
--
     child_processed := TRUE;
     if (l_multi_gre = TRUE) then
--
       -- OK it must be a prorate
       -- Process it completely separately
       process_action(chdrec.assignment_action_id,
                      p_effective_date,
                      p_ma_flag,
                      p_def_bal_id,
                      p_asg_id,
                      p_override_meth,
                      p_asg_act,
                      l_pay_left);
     else
       --
       -- OK This must be multiple assignments, hence
       -- just process the run type methods
       --
       process_third_party(chdrec.assignment_action_id,
                           p_effective_date,
                           p_asg_act);
       process_run_types(p_override_meth,
                         chdrec.assignment_action_id,
                         p_def_bal_id,
                         p_effective_date,
                         p_asg_act,
                         l_pay_left);
     end if;
--
   end loop;
--
   -- Each child action should have dealt with its own run types
   -- however, if there were no children we need to deal with them.
   if (child_processed = FALSE) then
      process_third_party(p_asg_act,
                          p_effective_date,
                          null);
      process_run_types(p_override_meth,
                        p_asg_act,
                        p_def_bal_id,
                        p_effective_date,
                        null,
                        l_pay_left);
   end if;
--
   process_normal_payments(p_override_meth,
                           p_asg_act,
                           p_asg_id,
                           p_def_bal_id,
                           p_effective_date,
                           l_pay_left);

   hr_utility.trace('Exit do_prepayment');
--
end do_prepayment;
--
   --------------------------------- get_trx_date ------------------------------
   /*
      NAME
         get_trx_date - derives the payment date.
      DESCRIPTION
         Returns the payment date (e.g. cheque date).
      NOTES
         <none>
   */
   function get_trx_date
   (
      p_business_group_id     in number,
      p_payroll_action_id     in number,
      p_assignment_action_id  in number   default null,
      p_payroll_id            in number   default null,
      p_consolidation_set_id  in number   default null,
      p_org_payment_method_id in number   default null,
      p_effective_date        in date     default null,
      p_date_earned           in date     default null,
      p_override_date         in date     default null,
      p_pre_payment_id        in number   default null
   ) return date is
     --
     l_trx_date      date;
     statem          varchar2(1000);
     rows_processed  integer;
     l_leg_code      per_business_groups_perf.legislation_code%type;
     l_cur_id        number;
     --
   begin
     --
     l_trx_date := to_date(null);
     --
     if (p_business_group_id = p_bg_id) then
        l_leg_code := p_leg_code;
        l_cur_id   := p_cur_id;
     else
        select legislation_code
        into   l_leg_code
        from   per_business_groups_perf
        where  business_group_id = p_business_group_id;
        --
        if l_leg_code = p_leg_code then
           --
           p_bg_id := p_business_group_id;
           l_cur_id := p_cur_id;
           --
        else
           --
           p_leg_code := l_leg_code;
           p_bg_id    := p_business_group_id;
           --
           if dbms_sql.is_open(p_cur_id) then
              dbms_sql.close_cursor(p_cur_id);
           end if;
           --
           begin
           --
           statem := 'BEGIN
                     :trx_date := pay_'||lower(l_leg_code)||'_payment_pkg.get_trx_date(
                                  :business_group_id,
                                  :payroll_action_id,
                                  :assignment_action_id,
                                  :payroll_id,
                                  :consolidation_set_id,
                                  :org_payment_method_id,
                                  :effective_date,
                                  :date_earned,
                                  :override_date,
                                  :pre_payment_id); END;';
             --
             l_cur_id := dbms_sql.open_cursor;
             --
             dbms_sql.parse(l_cur_id,
                            statem,
                            dbms_sql.v7);
             --
             -- First attempt to retrieve the value.
             --
             dbms_sql.bind_variable(l_cur_id, 'trx_date',              l_trx_date);
             dbms_sql.bind_variable(l_cur_id, 'business_group_id',     p_business_group_id);
             dbms_sql.bind_variable(l_cur_id, 'payroll_action_id',     p_payroll_action_id);
             dbms_sql.bind_variable(l_cur_id, 'assignment_action_id',  p_assignment_action_id);
             dbms_sql.bind_variable(l_cur_id, 'payroll_id',            p_payroll_id);
             dbms_sql.bind_variable(l_cur_id, 'consolidation_set_id',  p_consolidation_set_id);
             dbms_sql.bind_variable(l_cur_id, 'org_payment_method_id', p_org_payment_method_id);
             dbms_sql.bind_variable(l_cur_id, 'effective_date',        p_effective_date);
             dbms_sql.bind_variable(l_cur_id, 'date_earned',           p_date_earned);
             dbms_sql.bind_variable(l_cur_id, 'override_date',         p_override_date);
             dbms_sql.bind_variable(l_cur_id, 'pre_payment_id',        p_pre_payment_id);
             --
             rows_processed := dbms_sql.execute(l_cur_id);
             --
             dbms_sql.variable_value(l_cur_id, 'trx_date', l_trx_date);
             --
             --
           exception
             --
             when others then
               --
               if dbms_sql.is_open(l_cur_id) then
                  dbms_sql.close_cursor(l_cur_id);
               end if;
               --
               l_cur_id := NULL;
             --
           end;
           --
        end if;
        --
        p_cur_id := l_cur_id;
        --
     end if;
     --
     if l_trx_date is not null then
        return l_trx_date;
     end if;
     --
     if l_cur_id is not null then
        --
        dbms_sql.bind_variable(l_cur_id, 'trx_date',              l_trx_date);
        dbms_sql.bind_variable(l_cur_id, 'business_group_id',     p_business_group_id);
        dbms_sql.bind_variable(l_cur_id, 'payroll_action_id',     p_payroll_action_id);
        dbms_sql.bind_variable(l_cur_id, 'assignment_action_id',  p_assignment_action_id);
        dbms_sql.bind_variable(l_cur_id, 'payroll_id',            p_payroll_id);
        dbms_sql.bind_variable(l_cur_id, 'consolidation_set_id',  p_consolidation_set_id);
        dbms_sql.bind_variable(l_cur_id, 'org_payment_method_id', p_org_payment_method_id);
        dbms_sql.bind_variable(l_cur_id, 'effective_date',        p_effective_date);
        dbms_sql.bind_variable(l_cur_id, 'date_earned',           p_date_earned);
        dbms_sql.bind_variable(l_cur_id, 'override_date',         p_override_date);
        dbms_sql.bind_variable(l_cur_id, 'pre_payment_id',        p_pre_payment_id);
        --
        rows_processed := dbms_sql.execute(l_cur_id);
        --
        dbms_sql.variable_value(l_cur_id, 'trx_date', l_trx_date);
        --
     else
        --
        l_trx_date := nvl(nvl(p_override_date,p_date_earned),p_effective_date);
        --
     end if;
     --
     --
     return l_trx_date;
     --
   end get_trx_date;
--
procedure process_asg_rollup(p_assignment_action in number)
is
--
     type t_pre_payment_id is table of pay_pre_payments.pre_payment_id%type
     index by binary_integer;
     type t_assignment_action_id is table of pay_pre_payments.assignment_action_id%type
     index by binary_integer;
     type t_payroll_action_id is table of pay_payroll_actions.payroll_action_id%type
     index by binary_integer;
--
     f_pre_payment_id               t_pre_payment_id;
     f_assignment_action_id         t_assignment_action_id;
     f_payroll_action_id            t_payroll_action_id;
--
     cursor get_payment_details(p_asg_act number
                                )
     is
     select
            ppp.pre_payment_id,
            paa_pru.assignment_action_id,
            ppa_pru.payroll_action_id
      from  pay_payroll_actions        ppa_pru,
            pay_payroll_actions        ppa_pre,
            pay_assignment_actions     paa_pru,
            pay_assignment_actions     paa_pre,
            pay_action_interlocks      pai,
            pay_pre_payments           ppp
      where
            paa_pru.assignment_action_id = p_asg_act
        and ppa_pru.payroll_action_id    = paa_pru.payroll_action_id
        and paa_pru.assignment_action_id = pai.locking_action_id
        and pai.locked_action_id         = paa_pre.assignment_action_id
        and paa_pre.assignment_action_id = ppp.assignment_action_id
        and ppa_pre.payroll_action_id    = paa_pre.payroll_action_id
        and ppp.organization_id is not null
        and nvl(ppp.effective_date , ppa_pre.effective_date)
                                        <= ppa_pru.effective_date
        and not exists (select ''
                          from pay_contributing_payments pcp
                         where ppp.pre_payment_id = pcp.contributing_pre_payment_id)
      order by ppp.org_payment_method_id, ppp.payees_org_payment_method_id
        for update of ppp.pre_payment_id;
--
begin
--
      open get_payment_details(p_assignment_action);
      loop
          fetch get_payment_details
               bulk collect into f_pre_payment_id,
                                 f_assignment_action_id,
                                 f_payroll_action_id
               limit 1000;
--
          forall i in 1..f_pre_payment_id.count
              insert into pay_contributing_payments
                  (assignment_action_id,
                   payroll_action_id,
                   contributing_pre_payment_id
                  )
              values (
                      f_assignment_action_id(i),
                      f_payroll_action_id(i),
                      f_pre_payment_id(i)
                     );
--
          exit when get_payment_details%notfound;
--
      end loop;
--
      close get_payment_details;
--
end process_asg_rollup;
--
procedure process_pact_rollup(p_pactid in number)
is
--
cursor get_totals(p_pactid in number)
is
select ppp.org_payment_method_id,
       ppp.payees_org_payment_method_id,
       ppp.organization_id,
       sum(nvl(base_currency_value, 0)) base_currency_value,
       sum(nvl(value,0)) value
  from pay_contributing_payments pcp,
       pay_pre_payments          ppp
 where pcp.payroll_action_id = p_pactid
   and pcp.contributing_pre_payment_id = ppp.pre_payment_id
 group by ppp.org_payment_method_id,
          ppp.payees_org_payment_method_id,
          ppp.organization_id;
--
l_pre_pay_id pay_pre_payments.pre_payment_id%type;
--
begin
--
  for totrec in get_totals(p_pactid) loop
--
     select pay_pre_payments_s.nextval
       into l_pre_pay_id
       from dual;
--
     insert into pay_pre_payments
         (pre_payment_id,
          org_payment_method_id,
          value,
          base_currency_value,
          organization_id,
          payees_org_payment_method_id,
          payroll_action_id)
     values
         (l_pre_pay_id,
          totrec.org_payment_method_id,
          totrec.value,
          totrec.base_currency_value,
          totrec.organization_id,
          totrec.payees_org_payment_method_id,
          p_pactid);
--
     update pay_contributing_payments pcp
        set pre_payment_id = l_pre_pay_id
      where pcp.payroll_action_id = p_pactid
        and exists (select ''
                      from pay_pre_payments ppp
                     where ppp.pre_payment_id = pcp.contributing_pre_payment_id
                       and ppp.org_payment_method_id = totrec.org_payment_method_id
                       and ppp.payees_org_payment_method_id = totrec.payees_org_payment_method_id
                       and ppp.organization_id = totrec.organization_id
                    );
--
  end loop;
--
end process_pact_rollup;

--
end hr_pre_pay;

/
