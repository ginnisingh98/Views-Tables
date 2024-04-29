--------------------------------------------------------
--  DDL for Package Body PAY_CE_RECONCILIATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CE_RECONCILIATION_PKG" as
/* $Header: pycerecn.pkb 120.1 2005/09/30 12:42:32 adkumar noship $ */

procedure reconcile_payment(p_payment_id        number,
                            p_cleared_date      date,
                            p_trx_amount        number,
			    p_trx_type          varchar2,
                            p_last_updated_by   number,
                            p_last_update_login number,
                            p_created_by        number) is

  l_payment_base_value      number;
  l_rate_type               varchar2(30);

  e_payment_voided          exception;
  e_payment_amount_mismatch exception;
  e_no_matching_payment     exception;

  l_pay_currency_code    pay_org_payment_methods_f.currency_code%type;
  l_recon_currency_code  pay_org_payment_methods_f.currency_code%type;
  l_value                Pay_pre_payments.value%type;
  l_base_currency_value  pay_pre_payments.base_currency_value%type;
  l_action_status        pay_payroll_actions.action_status%type;
  l_business_group_id    number;

begin

  hr_utility.set_location('pay_ce_reconciliation_pkg.reconcile_payment', 10);

 --Bug No. 4644827
   pay_maintain_bank_acct.get_payment_details(
		p_payment_id          => p_payment_id,
		p_voided_payment      => false,
		p_pay_currency_code   => l_pay_currency_code,
		p_recon_currency_code => l_recon_currency_code,
		p_value               => l_value,
		p_base_currency_value => l_base_currency_value,
		p_action_status       => l_action_status,
		p_business_group_Id   => l_business_group_id
		);
    -- since currency code is mandatory, so i am supposing that it can not be null
    if (l_pay_currency_code is null) then

    -- we could be trying to reconcile a voided payment, which is fine
    -- as it will be reconciled against a stop pay line on the bank
    -- statement.  but we still want to keep it seperate as we may
    -- want to handle it differently in the future.

      pay_maintain_bank_acct.get_payment_details(
		p_payment_id          => p_payment_id,
		p_voided_payment      => true,
		p_pay_currency_code   => l_pay_currency_code,
		p_recon_currency_code => l_recon_currency_code,
		p_value               => l_value,
		p_base_currency_value => l_base_currency_value,
		p_action_status       => l_action_status,
		p_business_group_Id   => l_business_group_id
		);
      if ((l_pay_currency_code is not null) and not(payment_reconciled(p_payment_id))) then

      if l_pay_currency_code <> l_recon_currency_code then

        l_rate_type := hr_currency_pkg.get_rate_type(l_business_group_id,
                                                       p_cleared_date,
                                                       'P');

        l_payment_base_value := hr_currency_pkg.convert_amount(
                                  l_pay_currency_code,
                                  l_recon_currency_code,
                                  p_cleared_date,
                                  p_trx_amount,
                                  l_rate_type);


      else

        l_payment_base_value := p_trx_amount;

      end if;

        if l_value <> p_trx_amount then

        -- the amount on the statement and the amount being reconciled
	-- didn't match, so something's afoot.

        raise e_payment_amount_mismatch;

      else

        -- everything matches, so mark the payment as reconciled

        update_reconciled_payment(p_payment_id,
                                  p_trx_amount,
                                  l_payment_base_value,
                                  p_trx_type,
                                  p_cleared_date,
                                  'C');

      end if;

    else

      -- we couldn't find a payment that matches the line on the statement

      raise e_no_matching_payment;

    end if;

  elsif (not(payment_reconciled(p_payment_id))) then

    hr_utility.set_location('pay_ce_reconciliation_pkg.reconcile_payment', 20);

    if l_pay_currency_code <> l_recon_currency_code then

      l_rate_type := hr_currency_pkg.get_rate_type(l_business_group_id,
                                                     p_cleared_date,
                                                     'P');

      l_payment_base_value := hr_currency_pkg.convert_amount(
  			        l_pay_currency_code,
			        l_recon_currency_code,
			        p_cleared_date,
			        p_trx_amount,
			        l_rate_type);


    else

      l_payment_base_value := p_trx_amount;

    end if;

    if l_action_status = 'V' then

      raise e_payment_voided;

    elsif l_value <> p_trx_amount then

      raise e_payment_amount_mismatch;

    else

      update_reconciled_payment(p_payment_id,
                                p_trx_amount,
				l_payment_base_value,
				p_trx_type,
                                p_cleared_date,
                                'C');
    end if;

  else

      raise e_no_matching_payment;

  end if;

exception
  when e_payment_voided then

    -- we want to reconcile void payments because they will only be
    -- reconciled to a stopped payment line.  but kept it in an exception
    -- for now, because it is still an unusual condition.

    update_reconciled_payment(p_payment_id,
			      p_trx_amount,
			      l_payment_base_value,
			      p_trx_type,
			      p_cleared_date,
			      'C');

  when e_payment_amount_mismatch then

    update_reconciled_payment(p_payment_id,
			      null,
			      null,
			      p_trx_type,
			      null,
			      'E');

  when e_no_matching_payment then

    fnd_message.set_name('PAY', 'PAY_52789_NO_MATCHING_PAYMENT');
    app_exception.raise_exception;

  when others then

    raise;

end reconcile_payment;


procedure update_reconciled_payment(p_payment_id      number,
                                    p_trx_amount      number,
				    p_base_trx_amount number,
				    p_trx_type        varchar2,
                                    p_cleared_date    date,
                                    p_payment_status  varchar2) is

l_cleared_base_amount number;

begin

  hr_utility.set_location('pay_ce_reconciliation_pkg.update_reconciled_payment', 10);

  insert into pay_ce_reconciled_payments(
    reconciled_payment_id,
    assignment_action_id,
    trx_type,
    cleared_amount,
    cleared_date,
    status_code,
    cleared_base_amount)
  values(
    pay_ce_reconciled_payments_s.nextval,
    p_payment_id,
    p_trx_type,
    p_trx_amount,
    p_cleared_date,
    p_payment_status,
    p_base_trx_amount);


exception
  when others then
    app_exception.raise_exception;

end update_reconciled_payment;


procedure reverse_reconcile(p_payment_id number) is

l_reconciled_payment_id  number;
e_payment_not_reconciled exception;

cursor c_reconciled_payment is
  select
    reconciled_payment_id
  from
    pay_ce_reconciled_payments
  where
    assignment_action_id = p_payment_id;

begin

  hr_utility.set_location('pay_ce_reconciliation_pkg.reverse_reconcile', 10);

  open c_reconciled_payment;
  fetch c_reconciled_payment into l_reconciled_payment_id;
  if c_reconciled_payment%found then

    delete from pay_ce_reconciled_payments
    where reconciled_payment_id = l_reconciled_payment_id;

  else

    raise e_payment_not_reconciled;

  end if;

    close c_reconciled_payment;

exception
  when e_payment_not_reconciled then

    fnd_message.set_name('PAY', 'PAY_52790_PAYMENT_NOT_CLEARED');
    app_exception.raise_exception;

  when others then

    app_exception.raise_exception;

end reverse_reconcile;


function payment_reconciled(p_payment_id number) return boolean is

l_dummy varchar2(1);

cursor c_payment is
  select
    null
  from
    pay_ce_reconciled_payments
  where
      assignment_action_id = p_payment_id
  and status_code = 'C';

begin

  open c_payment;
  fetch c_payment into l_dummy;
  if c_payment%found then

    close c_payment;
    return true;

  else

    close c_payment;
    return false;

  end if;

end payment_reconciled;


function payinfo(p_identifier varchar2,
                                  p_assignment_action_id number)
return varchar2 is
--
  l_effective_date pay_payroll_actions.effective_date%type;
  l_payment_type_id pay_org_payment_methods_f.payment_type_id%type;
  l_org_payment_method_id pay_pre_payments.org_payment_method_id%type;
  l_personal_payment_method_id pay_pre_payments.personal_payment_method_id%type;
  l_pre_payment_id pay_pre_payments.pre_payment_id%type;
  l_payroll_action_id pay_assignment_actions.payroll_action_id%type;
  l_identifier_value varchar2(255);
--
begin
--
select PA.effective_date,
       OP.payment_type_id,
       PP.org_payment_method_id,
       PP.personal_payment_method_id,
       PP.PRE_PAYMENT_ID,
       AA.payroll_action_id
  into l_effective_date,
       l_payment_type_id,
       l_org_payment_method_id,
       l_personal_payment_method_id,
       l_pre_payment_id,
       l_payroll_action_id
  from pay_payroll_actions PA,
       pay_assignment_actions AA,
       -- pay_action_interlocks INT,
       pay_pre_payments PP,
       pay_org_payment_methods_f OP
 where PA.payroll_action_id = AA.payroll_action_id
   and AA.assignment_action_id = p_assignment_action_id
   -- and AA.assignment_action_id = INT.locking_action_id
   -- and PP.assignment_action_id = INT.locked_action_id
   and PP.pre_payment_id = AA.pre_payment_id
   and PP.org_payment_method_id = OP.org_payment_method_id
   and PA.effective_date between OP.effective_start_date
             and OP.effective_end_date ;
--
  l_identifier_value :=  payment_transaction_info(l_effective_date,
                                  p_identifier,
                                  l_payroll_action_id,
                                  l_payment_type_id,
                                  l_org_payment_method_id,
                                  l_personal_payment_method_id,
                                  p_assignment_action_id,
                                  l_pre_payment_id,
                                  '/');
 return l_identifier_value;
--
end payinfo;
--
function payment_transaction_info(p_effective_date   date,
                                  p_identifier_name   varchar2,
                                  p_payroll_action_id  number,
                                  p_payment_type_id   number,
                                  p_org_payment_method_id number,
                                  p_personal_payment_method_id  number,
                                  p_assignment_action_id number,
                                  p_pre_payment_id   number,
                                  p_delimiter_string  varchar2  default '/') return varchar2 is
  --
  l_function_name    pay_payment_types.reconciliation_function%TYPE;
  l_identifier_value varchar2(255);
  sql_curs           number;
  statem             varchar2(2000);
  rows_processed     number;
  --
  cursor csr_payment_function is
    select pyt.reconciliation_function
      from pay_payment_types pyt
     where pyt.payment_type_id = p_payment_type_id
       and pyt.reconciliation_function is not null;
  --
  cursor csr_payee_bank_details (p_info_type varchar2) is
    select pay_ce_support_pkg.bank_segment_value(
                                      ppm.external_account_id,
                                      p_info_type,
                                      nvl(ppt.TERRITORY_CODE,pbg.legislation_code))
      from per_business_groups_perf pbg,
           pay_payment_types ppt,
           pay_personal_payment_methods_f ppm
     where ppm.personal_payment_method_id = p_personal_payment_method_id
       and p_effective_date between ppm.effective_start_date
                                and ppm.effective_end_date
       and ppt.payment_type_id = p_payment_type_id
       and ppm.business_group_id = pbg.business_group_id;
  --
begin
  --
  open csr_payment_function;
  fetch csr_payment_function into l_function_name;
  if csr_payment_function%notfound then
     close csr_payment_function;
     --
     if p_identifier_name = 'PAYEE_BANK_ACCOUNT_NAME' then
        --
        open csr_payee_bank_details('BANK_ACCOUNT_NAME');
        fetch csr_payee_bank_details into l_identifier_value;
        close csr_payee_bank_details;
        return l_identifier_value;
        --
     elsif p_identifier_name = 'PAYEE_BANK_ACCOUNT_NUMBER' then
        --
        open csr_payee_bank_details('BANK_ACCOUNT_NUMBER');
        fetch csr_payee_bank_details into l_identifier_value;
        close csr_payee_bank_details;
        return l_identifier_value;
        --
     elsif p_identifier_name = 'PAYEE_BANK_BRANCH' then
        --
        open csr_payee_bank_details('BANK_BRANCH');
        fetch csr_payee_bank_details into l_identifier_value;
        close csr_payee_bank_details;
        return l_identifier_value;
        --
     elsif p_identifier_name = 'PAYEE_BANK_NAME' then
        --
        open csr_payee_bank_details('BANK_NAME');
        fetch csr_payee_bank_details into l_identifier_value;
        close csr_payee_bank_details;
        return l_identifier_value;
        --
     else
       return null;
     end if;
     --
  else
     close csr_payment_function;
     --
     if p_identifier_name = 'PAYEE_BANK_ACCOUNT_NAME' then
        --
        open csr_payee_bank_details('BANK_ACCOUNT_NAME');
        fetch csr_payee_bank_details into l_identifier_value;
        close csr_payee_bank_details;
        return l_identifier_value;
        --
     elsif p_identifier_name = 'PAYEE_BANK_ACCOUNT_NUMBER' then
        --
        open csr_payee_bank_details('BANK_ACCOUNT_NUMBER');
        fetch csr_payee_bank_details into l_identifier_value;
        close csr_payee_bank_details;
        return l_identifier_value;
        --
     elsif p_identifier_name = 'PAYEE_BANK_BRANCH' then
        --
        open csr_payee_bank_details('BANK_BRANCH');
        fetch csr_payee_bank_details into l_identifier_value;
        close csr_payee_bank_details;
        return l_identifier_value;
        --
     elsif p_identifier_name = 'PAYEE_BANK_NAME' then
        --
        open csr_payee_bank_details('BANK_NAME');
        fetch csr_payee_bank_details into l_identifier_value;
        close csr_payee_bank_details;
        return l_identifier_value;
        --
     end if;
     --
     begin
        statem := 'BEGIN
                      select substr('||l_function_name||'(:p_effective_date,
                                                          :p_identifier_name,
                                                          :p_payroll_action_id,
                                                          :p_payment_type_id,
                                                          :p_org_payment_method_id,
                                                          :p_personal_payment_method_id,
							  :p_assignment_action_id,
                                                          :p_pre_payment_id,
							  :p_delimiter_string),1,255)
                      into :identifier_value
                      from dual;
                   END;';
        --
        sql_curs := dbms_sql.open_cursor;
        --
        dbms_sql.parse(sql_curs,
                statem,
                dbms_sql.v7);
        --
        dbms_sql.bind_variable(sql_curs, 'p_effective_date', p_effective_date);
        dbms_sql.bind_variable(sql_curs, 'p_identifier_name', p_identifier_name);
        dbms_sql.bind_variable(sql_curs, 'p_payroll_action_id', p_payroll_action_id);
        dbms_sql.bind_variable(sql_curs, 'p_payment_type_id', p_payment_type_id);
        dbms_sql.bind_variable(sql_curs, 'p_org_payment_method_id', p_org_payment_method_id);
        dbms_sql.bind_variable(sql_curs, 'p_personal_payment_method_id', p_personal_payment_method_id);
	dbms_sql.bind_variable(sql_curs, 'p_assignment_action_id', p_assignment_action_id);
        dbms_sql.bind_variable(sql_curs, 'p_pre_payment_id', p_pre_payment_id);
        dbms_sql.bind_variable(sql_curs, 'p_delimiter_string', p_delimiter_string);
	dbms_sql.bind_variable(sql_curs, 'identifier_value', l_identifier_value,255);
        --
        rows_processed := dbms_sql.execute(sql_curs);
        --
        dbms_sql.variable_value(sql_curs, 'identifier_value', l_identifier_value);
        --
        dbms_sql.close_cursor(sql_curs);
        --
      exception
        when others then
          --
          if dbms_sql.is_open(sql_curs) then
             dbms_sql.close_cursor(sql_curs);
          end if;
          --
          l_identifier_value := null;
          --
     end;
     --
     return l_identifier_value;
     --
  end if;
  --
end payment_transaction_info;


end pay_ce_reconciliation_pkg;

/
