--------------------------------------------------------
--  DDL for Package Body PAY_MAINTAIN_BANK_ACCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MAINTAIN_BANK_ACCT" as
/* $Header: pymntbnk.pkb 120.4 2006/08/31 12:21:34 pgongada noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  UPDATE_PAYROLL_BANK_ACCT.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< UPDATE_PAYROLL_BANK_ACCT >----------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure stamps the payroll_bank_account_id of ce_bank_uses_all in
-- Cash Management with the user specified payroll account id (p_external_account_id).
-- This stamping happens only if the cash management account is not already
-- stamped with other payroll account.
-- Below are the scenarios taken care in this procedure

-- 1) Scenario 1: If the Cash management A/C i.e,. p_bank_account_id is not
--    stamped then it stamps with the payroll account id
--
-- 2) Scenario 2: If the Cash Management A/C is stamped and the user is trying
--    to update with another payroll A/C, it raises the error PAY_34070_PAY_CE_MAP_ERR
--    when the given payroll A/C is already stamped with another Cash Management A/C.
--
-- 3) Scenario 3: If the user is trying to create/update an OPM with the bank details,
--    which are already used by another OPM, then it allows but without stamping.
--
-- 4) Scenario 4: Ensure that there is only one-to-one correspondence with the
--    Cash Management A/C and Payroll A/C.

Procedure update_payroll_bank_acct(
p_bank_account_id IN number,
p_external_account_id IN NUMBER,
p_org_payment_method_id IN number) IS

	cursor csr_chk_payroll_bank_acct is
	select cba.payroll_bank_account_id
	from   ce_bank_acct_uses_all cba
	where  cba.Bank_account_id = p_bank_account_id
	and    (-- Check Whether the given CE account is attached to another payroll account.
	        (cba.payroll_bank_account_id <> p_external_account_id and
                 cba.payroll_bank_account_id is not null)
		-- Check whether the given Payroll account is attached to more than one CE account.
	        or exists (select Bank_account_id
                           from (select distinct cbb.Bank_account_id
			         from   ce_bank_acct_uses_all cbb
                                 where  cbb.payroll_bank_account_id = p_external_account_id)
                           group by Bank_account_id
                           having count(*) >1));
                -- Need to check whether the payment is reconcilled.
		-- If so then we should not allow the change of the bank account.
		-- Following needs to be changed later.
		-- or EXISTS (SELECT 'X' FROM pay_org_payment_methods_f
	        --            WHERE ORG_PAYMENT_METHOD_ID = p_org_payment_method_id);

	CURSOR csr_chk_pre_payments_exists IS
	SELECT 'X'
	FROM SYS.DUAL
	WHERE 1=2;
	-- Need to change the following as well.
	-- FROM   pay_pre_payments
	-- WHERE  ORG_PAYMENT_METHOD_ID = p_org_payment_method_id;

	l_payroll_bank_account_id  pay_org_payment_methods_f.external_account_id%TYPE;
	l_dummy varchar2(2);
	l_proc varchar2(100) := g_package||'UPDATE_PAYROLL_BANK_ACCT';

begin

    --
    -- Only Update ce bank tables if both ce and pay are installed
    --
    hr_utility.set_location('Entering : '||l_proc, 10);
    if pay_ce_support_pkg.pay_and_ce_licensed then

       if p_bank_account_id is not null then

		open csr_chk_payroll_bank_acct;
		fetch csr_chk_payroll_bank_acct into l_payroll_bank_account_id;
		if (csr_chk_payroll_bank_acct% NOTFOUND) THEN

			hr_utility.set_location(l_proc||'Stamping has to be done', 20);
			hr_utility.set_location(l_proc||'Stamping ....',30);
			update ce_bank_acct_uses_all
			set    payroll_bank_account_id = p_external_account_id
			where  Bank_account_id = p_bank_account_id;
			close csr_chk_payroll_bank_acct;

			hr_utility.set_location(l_proc||'Nullifying earlier stamping ....',40);
			update ce_bank_acct_uses_all
			set    payroll_bank_account_id = null
			where  payroll_bank_account_id = p_external_account_id
			AND    Bank_account_id <> p_bank_account_id;

		else
			hr_utility.set_location(l_proc||'No need of stamping ....',50);
			close csr_chk_payroll_bank_acct;
			-- Raising error, if the requested updation is going to break the one-to-one relationship
			if (nvl(l_payroll_bank_account_id, -1) <> p_external_account_id) THEN
			        hr_utility.set_location(l_proc||'Raising an error ....',60);
				fnd_message.set_name('PAY', 'PAY_34070_PAY_CE_MAP_ERR');
				fnd_message.raise_error;
			end if;
		END if;
	ELSE
		OPEN csr_chk_pre_payments_exists;
		FETCH csr_chk_pre_payments_exists INTO l_dummy;
		IF (csr_chk_pre_payments_exists % NOTFOUND) THEN
			update ce_bank_acct_uses_all
			set    payroll_bank_account_id = null
			where  payroll_bank_account_id = p_external_account_id;
		ELSE
			fnd_message.set_name('PAY', 'HR_6226_PAYM_PPS_EXIST');
			fnd_message.raise_error;
		END IF;
		CLOSE csr_chk_pre_payments_exists;
	end if;

     end if;

exception
  when others then

    -- anything else, we want to know about.

    raise;
hr_utility.set_location('Leaving : '||l_proc, 10);
end;

procedure remove_redundant_bank_detail
is
begin
  null;
end;

procedure get_payment_details
(
p_payment_id          in               number,
p_voided_payment      in               boolean,
p_pay_currency_code   out nocopy       varchar2,
p_recon_currency_code out nocopy       varchar2,
p_value               out nocopy       varchar2,
p_base_currency_value out nocopy       number,
p_action_status       out nocopy       varchar2,
p_business_group_Id   out nocopy       number
)is

cursor c_payment_details is
    select
      popm.currency_code pay_currency_code,
      cba.currency_code  recon_currency_code,
      ppp.value,
      nvl(ppp.base_currency_value,ppp.value) base_currency_value,
      paa.action_status,
      popm.business_group_id
    from
      pay_org_payment_methods_f popm,
      ce_bank_accounts cba,
      ce_bank_acct_uses_all apb,
      pay_pre_payments ppp,
      pay_assignment_actions paa,
      pay_payroll_actions ppa
    where
          paa.assignment_action_id = p_payment_id
      and ppa.payroll_action_id = paa.payroll_action_id
      and ppa.action_type in ('H', 'M', 'E')
      and ppp.pre_payment_id = paa.pre_payment_id
      and ppp.org_payment_method_id = popm.org_payment_method_id
      and cba.bank_account_id = apb.bank_account_id
      and popm.external_account_id = apb.payroll_bank_account_id;


cursor c_voided_payment is
    select
      popm.currency_code pay_currency_code,
      cba.currency_code  recon_currency_code,
      ppp.value,
      nvl(ppp.base_currency_value,ppp.value) base_currency_value,
      paa.action_status,
      popm.business_group_id
    from
      pay_org_payment_methods_f popm,
      ce_bank_accounts cba,
      ce_bank_acct_uses_all apb,
      pay_pre_payments ppp,
      pay_assignment_actions paa,
      pay_assignment_actions paa1,
      pay_payroll_actions ppa,
      pay_action_interlocks pai
    where
          paa.assignment_action_id = p_payment_id
      and ppa.payroll_action_id = paa.payroll_action_id
      and ppa.action_type = 'D'
      and ppp.pre_payment_id = paa1.pre_payment_id
      and paa1.assignment_action_id = pai.locked_action_id
      and paa.assignment_action_id = pai.locking_action_id
      and ppp.org_payment_method_id = popm.org_payment_method_id
      and cba.bank_account_id = apb.bank_account_id
      and popm.external_account_id = apb.payroll_bank_account_id;

begin
  if p_voided_payment = false then
     open c_payment_details;
     fetch c_payment_details into p_pay_currency_code,p_recon_currency_code ,
           p_value,p_base_currency_value ,p_action_status,p_business_group_Id;
     close c_payment_details;
  else
    open c_voided_payment;
     fetch c_voided_payment into p_pay_currency_code,p_recon_currency_code ,
           p_value,p_base_currency_value ,p_action_status,p_business_group_Id;
     close c_voided_payment;
  end if;

end get_payment_details;



function chk_bank_row_exists
(
p_external_account_id      in     number
) return varchar2
is
l_exists varchar2(1);

cursor csr_row_exists(c_external_account_id number) is
  select 'Y'
  from ce_bank_accounts cba,
       ce_bank_acct_uses_all cbau
  where cba.bank_account_id = cbau.bank_account_id
    and cbau.payroll_bank_account_id = c_external_account_id
    and pay_use_allowed_flag = 'Y';
begin
  l_exists := 'N';
  open csr_row_exists(p_external_account_id);
  fetch csr_row_exists into l_exists;
  close csr_row_exists;

  return l_exists;

end chk_bank_row_exists;



procedure get_chart_of_accts_and_sob
(
p_external_account_id      in            number,
p_char_of_accounts_id      out nocopy    number,
p_set_of_books_id          out nocopy    number,
p_name                     out nocopy    varchar2,
p_asset_ccid               out nocopy    number
)is

begin

   select DISTINCT null,null,null,aba.asset_code_combination_id
   into p_char_of_accounts_id,p_set_of_books_id,p_name,p_asset_ccid
    from  ce_bank_accounts aba,
          ce_bank_acct_uses_all cbau
    where aba.bank_account_id = cbau.bank_account_id
      and cbau.payroll_bank_account_id = p_external_account_id;

end get_chart_of_accts_and_sob;


procedure update_asset_ccid
(
p_assest_ccid              in       number,
p_set_of_books_id          in       number,
p_external_account_id      in       number
)is
begin
-- for R11.5 bank_account_id field will be null
null;
end;


Function get_sob_id
(
p_org_payment_method_id    in       number
) return number is

begin
  return -1;
end get_sob_id;

function chk_account_exists
(
p_org_payment_method_id    in       number,
p_validation_start_date    in       date,
p_validation_end_date      in       date
)return boolean
is
l_exists  varchar2(1);
cursor csr_ap_details(c_org_payment_method_id number,
                      c_validation_start_date date,
                      c_validation_end_date date) is
     select null
    from   pay_org_payment_methods_f opm,
           ce_bank_accounts cba,
           ce_bank_acct_uses_all cbau
    where  cba.bank_account_id = cbau.bank_account_id
    and    opm.org_payment_method_id = c_org_payment_method_id
    and    opm.effective_start_date between c_validation_start_date and c_validation_end_date
    and    opm.effective_end_date between c_validation_start_date and c_validation_end_date
    and    pay_use_allowed_flag = 'Y'
    and    cbau.PAYROLL_BANK_ACCOUNT_ID = opm.external_account_id;

begin
  l_exists := 'N';
  open csr_ap_details(p_org_payment_method_id,
                      p_validation_start_date,
                      p_validation_end_date);
  fetch csr_ap_details into l_exists;
  close csr_ap_details;

  if l_exists = 'Y' then
  return true;
  else
  return false;
  end if;
end chk_account_exists;

procedure lock_row
(
p_external_account_id   in    number
)
is

cursor  ABA_CUR is
        select  *
        from    ce_bank_acct_uses_all aba
        where   payroll_bank_account_id = p_external_account_id
        FOR     UPDATE OF BANK_ACCOUNT_ID NOWAIT;
l_rec ABA_CUR%rowtype;
--
begin
--
if p_external_account_id is not null then

   open ABA_CUR;
   fetch ABA_CUR into l_rec;
   close ABA_CUR;

end if;
end lock_row;

-- ----------------------------------------------------------------------------
-- |---------------------------< GET_BANK_DETAILS >---------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is used to get the bank detials of the existing OPMs.
--
procedure get_bank_details
(
	p_external_account_id   in    number,
	p_bank_account_id       out nocopy number,
	p_bank_account_name     out nocopy varchar2
) is
--
cursor csr_get_bank_details is
select  DISTINCT bank_uses.bank_account_id,
        accounts.bank_account_name
from    ce_bank_acct_uses_all bank_uses,
        ce_bank_accounts accounts
where   bank_uses.payroll_bank_account_id = p_external_account_id
and     bank_uses.bank_account_id = accounts.bank_account_id
and     accounts.PAY_USE_ALLOWED_FLAG = 'Y';
--
begin
	open csr_get_bank_details;
	fetch csr_get_bank_details into p_bank_account_id, p_bank_account_name;
	if (csr_get_bank_details%notfound) then
		close csr_get_bank_details;
		p_bank_account_id := null;
		p_bank_account_name := null;
	end if;
	if (csr_get_bank_details%isopen) then
		close csr_get_bank_details;
	end if;

end get_bank_details;

end PAY_MAINTAIN_BANK_ACCT;

/
