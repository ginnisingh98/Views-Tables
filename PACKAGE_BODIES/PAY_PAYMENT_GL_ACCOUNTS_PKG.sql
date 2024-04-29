--------------------------------------------------------
--  DDL for Package Body PAY_PAYMENT_GL_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYMENT_GL_ACCOUNTS_PKG" as
/* $Header: pypga01t.pkb 120.0 2005/09/29 10:51 tvankayl noship $ */

procedure INSERT_ROW (
  P_PAY_GL_ACCOUNT_ID OUT NOCOPY NUMBER,
  P_EFFECTIVE_START_DATE in DATE,
  P_EFFECTIVE_END_DATE in DATE,
  P_SET_OF_BOOKS_ID in NUMBER,
  P_GL_CASH_AC_ID in NUMBER,
  P_GL_CASH_CLEARING_AC_ID in NUMBER,
  P_GL_CONTROL_AC_ID in NUMBER,
  P_GL_ERROR_AC_ID in NUMBER,
  P_EXTERNAL_ACCOUNT_ID in NUMBER,
  P_ORG_PAYMENT_METHOD_ID in NUMBER,
  P_DEFAULT_GL_ACCOUNT    in VARCHAR2
) is
--
  cursor C is select ROWID from PAY_PAYMENT_GL_ACCOUNTS_F
    where PAY_GL_ACCOUNT_ID = P_PAY_GL_ACCOUNT_ID
    ;
--
  l_def_gl_acct_id pay_payment_gl_accounts_f.pay_gl_account_id%type;
  l_external_account_id pay_org_payment_methods_f.external_account_id%type;
  l_org_payment_method_id pay_org_payment_methods_f.org_payment_method_id%type;
  l_effective_start_date date;
  l_effective_end_date   date;
  l_ovn number;
  l_esd_out date;
  l_eed_out date;
  l_proc   varchar2(100) := 'PAY_PAYMENT_GL_ACCOUNTS_PKG.INSERT_ROW';
--
begin
  --

  hr_utility.set_location('Entering: '|| l_proc, 10);
  hr_utility.set_location('Org Payment Method Id: ' || p_org_payment_method_id, 20);

  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'ORG_PAYMENT_METHOD_ID'
  ,p_argument_value =>  p_org_payment_method_id
  );

  if p_external_account_id is null and p_default_gl_account = 'Y' then

    fnd_message.set_name('PAY', 'PAY_33459_INV_DEF_BANK_COMB');
    fnd_message.raise_error;

  end if;

  hr_utility.set_location(l_proc, 30);

  l_external_account_id := p_external_account_id;
  l_org_payment_method_id := p_org_payment_method_id;
  l_effective_start_date := p_effective_start_date;
  l_effective_end_date   := p_effective_end_date;

  if p_default_gl_account = 'Y' then

     -- Check if default GL accounts for this bank already exist.

     -- If default flag is 'Y' then external_account_id must be passed.

     hr_utility.set_location(l_proc, 40);

     l_def_gl_acct_id := default_gl_accounts
                                     ( p_external_account_id => p_external_account_id );

     if l_def_gl_acct_id is not null then

         -- Default GL Accounts for the bank exist, validate the data passed in
         -- and update the default GL Accounts.

         hr_utility.set_location(l_proc, 50);

         pay_pga_bus.chk_set_of_books_id
         (p_set_of_books_id   => p_set_of_books_id
         );
         --
         pay_pga_bus.chk_gl_account_id
         (p_gl_account_id     => p_gl_cash_ac_id
         );
         --
         pay_pga_bus.chk_gl_account_id
         (p_gl_account_id     => p_gl_cash_clearing_ac_id
         );
         --
         pay_pga_bus.chk_gl_account_id
         (p_gl_account_id     => p_gl_control_ac_id
         );
         --
         pay_pga_bus.chk_gl_account_id
         (p_gl_account_id     => p_gl_error_ac_id
         );
         --

         update pay_payment_gl_accounts_f
         set
           set_of_books_id = p_set_of_books_id,
           gl_cash_ac_id = p_gl_cash_ac_id,
           gl_cash_clearing_ac_id = p_gl_cash_clearing_ac_id,
           gl_control_ac_id = p_gl_control_ac_id,
           gl_error_ac_id = p_gl_error_ac_id
         where
           pay_gl_account_id = l_def_gl_acct_id and
           external_account_id = p_external_account_id ;

         p_pay_gl_account_id := l_def_gl_acct_id;

         return;

     else

         -- Default GL Accounts for the bank do not exist
         -- Create the Default GL Accounts Now.

         hr_utility.set_location(l_proc, 60);

         l_org_payment_method_id := null;
         l_effective_start_date  := hr_general.start_of_time;
         l_effective_end_date    := hr_general.end_of_time;

     end if;

  else

    -- Default flag is 'N'.
    -- GL Accounts for the Org Payment method has to be created.

    hr_utility.set_location(l_proc, 70);

    l_external_account_id := null;

  end if;

  hr_utility.set_location(l_proc, 80);

  pay_pga_ins.ins
    (p_effective_date                 => trunc(l_effective_start_date)
    ,p_set_of_books_id                => p_set_of_books_id
    ,p_gl_cash_ac_id                  => p_gl_cash_ac_id
    ,p_gl_cash_clearing_ac_id         => p_gl_cash_clearing_ac_id
    ,p_gl_control_ac_id               => p_gl_control_ac_id
    ,p_gl_error_ac_id                 => p_gl_error_ac_id
    ,p_external_account_id            => l_external_account_id
    ,p_org_payment_method_id          => l_org_payment_method_id
    ,p_pay_gl_account_id              => p_pay_gl_account_id
    ,p_object_version_number          => l_ovn
    ,p_effective_start_date           => l_esd_out
    ,p_effective_end_date             => l_eed_out
    );

  hr_utility.set_location(l_proc, 90);

  if l_esd_out <> l_effective_start_date or
         l_eed_out <> l_effective_end_date then

     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','PAY_PAYMENT_GL_ACCOUNTS_PKG.INSERT_ROW');
     hr_utility.set_message_token('STEP','10');
     hr_utility.raise_error;

  end if;

  hr_utility.set_location('Leaving: '|| l_proc, 100);
  --
end INSERT_ROW;

procedure UPDATE_ROW (
  P_EFFECTIVE_START_DATE in DATE,
  P_EFFECTIVE_END_DATE in DATE,
  P_SET_OF_BOOKS_ID in NUMBER,
  P_GL_CASH_AC_ID in NUMBER,
  P_GL_CASH_CLEARING_AC_ID in NUMBER,
  P_GL_CONTROL_AC_ID in NUMBER,
  P_GL_ERROR_AC_ID in NUMBER,
  P_EXTERNAL_ACCOUNT_ID in NUMBER,
  P_ORG_PAYMENT_METHOD_ID in NUMBER,
  P_DT_UPDATE_MODE IN VARCHAR2,
  P_DEFAULT_GL_ACCOUNT    in VARCHAR2,
  P_PAY_GL_ACCOUNT_ID_OUT  out nocopy number
) is
--
l_ovn number;
l_ovn_seq number;
l_esd_out date;
l_eed_out date;
l_opm_gl_acct_id pay_payment_gl_accounts_f.pay_gl_account_id%type;
l_def_gl_acct_id pay_payment_gl_accounts_f.pay_gl_account_id%type;
l_pay_gl_account_id pay_payment_gl_accounts_f.pay_gl_account_id%type;
l_def_gl_set_of_books_id pay_payment_gl_accounts_f.set_of_books_id%type;
l_def_gl_cash_ac_id  pay_payment_gl_accounts_f.gl_cash_ac_id%type;
l_def_gl_cash_clearing_ac_id  pay_payment_gl_accounts_f.gl_cash_clearing_ac_id%type;
l_def_gl_control_ac_id  pay_payment_gl_accounts_f.gl_control_ac_id%type;
l_def_gl_error_ac_id  pay_payment_gl_accounts_f.gl_error_ac_id%type;
l_seq_id  pay_payment_gl_accounts_f.pay_gl_account_id%type;
l_proc   varchar2(100) := 'PAY_PAYMENT_GL_ACCOUNTS_PKG.UPDATE_ROW';
--
cursor csr_ovn (p_gl_acct_id number, p_effective_date date) is
select object_version_number
from   pay_payment_gl_accounts_f
where  pay_gl_account_id = p_gl_acct_id
and    p_effective_date between
          effective_start_date and effective_end_date;
--
cursor csr_def_gl_accounts (p_ext_gl_id number, p_effective_date date) is
select gl_cash_ac_id, gl_cash_clearing_ac_id, gl_control_ac_id, gl_error_ac_id, set_of_books_id
from   pay_payment_gl_accounts_f
where  external_account_id = p_ext_gl_id
and    p_effective_date between effective_start_date and effective_end_date;
--
cursor csr_next_seq is
select pay_payment_gl_accounts_s.nextval
from   dual;
--
cursor csr_opm_rows (p_org_payment_method_id number) is
select effective_start_date, effective_end_date, external_account_id
from   pay_org_payment_methods_f
where  org_payment_method_id = p_org_payment_method_id;
--
begin
  --

  hr_utility.set_location('Entering: '|| l_proc, 10);
  hr_utility.set_location('Org Payment Method Id: '|| p_org_payment_method_id, 20);

  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'ORG_PAYMENT_METHOD_ID'
  ,p_argument_value =>  p_org_payment_method_id
  );

  if p_external_account_id is null and p_default_gl_account = 'Y' then

    fnd_message.set_name('PAY', 'PAY_33459_INV_DEF_BANK_COMB');
    fnd_message.raise_error;

  end if;

  hr_utility.set_location(l_proc, 30);

  l_opm_gl_acct_id := opm_gl_accounts
                             ( p_org_payment_method_id => p_org_payment_method_id );

  l_def_gl_acct_id := default_gl_accounts
                                   ( p_external_account_id => p_external_account_id );

  hr_utility.set_location(l_proc || ' OPM GL ACCOUNT ID: ' || l_opm_gl_acct_id, 40);
  hr_utility.set_location(l_proc || ' DEFAULT GL ACCOUNT ID: ' || l_def_gl_acct_id, 50);

  if p_default_gl_account = 'Y' then

     -- When Default flag is 'Y', GL accounts for the OPM should not exist.

     hr_utility.set_location(l_proc, 60);

     if l_opm_gl_acct_id is not null then

      fnd_message.set_name('PAY', 'PAY_33460_OPM_GL_ACT_EXISTS');
      fnd_message.raise_error;

     end if;

     hr_utility.set_location(l_proc, 70);

     if l_def_gl_acct_id is not null then

         -- When the default GL Accounts for the bank already exists
         -- we need to only validate the data and update the record.

         hr_utility.set_location(l_proc, 80);

         pay_pga_bus.chk_set_of_books_id
         (p_set_of_books_id   => p_set_of_books_id
         );
         --
         pay_pga_bus.chk_gl_account_id
         (p_gl_account_id     => p_gl_cash_ac_id
         );
         --
         pay_pga_bus.chk_gl_account_id
         (p_gl_account_id     => p_gl_cash_clearing_ac_id
         );
         --
         pay_pga_bus.chk_gl_account_id
         (p_gl_account_id     => p_gl_control_ac_id
         );
         --
         pay_pga_bus.chk_gl_account_id
         (p_gl_account_id     => p_gl_error_ac_id
         );
         --

         update pay_payment_gl_accounts_f
         set
           set_of_books_id = p_set_of_books_id,
           gl_cash_ac_id = p_gl_cash_ac_id,
           gl_cash_clearing_ac_id = p_gl_cash_clearing_ac_id,
           gl_control_ac_id = p_gl_control_ac_id,
           gl_error_ac_id = p_gl_error_ac_id
         where
           pay_gl_account_id = l_def_gl_acct_id and
           external_account_id = p_external_account_id ;

         --
         p_pay_gl_account_id_out := l_def_gl_acct_id;

     else

         -- Default GL Accounts for the bank do not exist
         -- Create the Default GL Accounts Now.

         hr_utility.set_location(l_proc, 90);

         pay_pga_ins.ins
            (p_effective_date                 => trunc(hr_general.start_of_time)
            ,p_set_of_books_id                => p_set_of_books_id
            ,p_gl_cash_ac_id                  => p_gl_cash_ac_id
            ,p_gl_cash_clearing_ac_id         => p_gl_cash_clearing_ac_id
            ,p_gl_control_ac_id               => p_gl_control_ac_id
            ,p_gl_error_ac_id                 => p_gl_error_ac_id
            ,p_external_account_id            => p_external_account_id
            ,p_org_payment_method_id          => null
            ,p_pay_gl_account_id              => l_pay_gl_account_id
            ,p_object_version_number          => l_ovn
            ,p_effective_start_date           => l_esd_out
            ,p_effective_end_date             => l_eed_out
            );

            p_pay_gl_account_id_out := l_pay_gl_account_id;

         hr_utility.set_location(l_proc, 100);

         if l_esd_out <> hr_general.start_of_time and
               l_eed_out <> hr_general.end_of_time then

             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','PAY_PAYMENT_GL_ACCOUNTS_PKG.UPDATE_ROW');
             hr_utility.set_message_token('STEP','10');
             hr_utility.raise_error;

         end if;

     end if;

  else

    -- Default flag is 'N'. Check if the GL accounts for the OPM exist.

    hr_utility.set_location(l_proc, 110);

    if l_opm_gl_acct_id is not null then

      -- GL Accounts for the OPM exist. Update the record on the effective date.

      hr_utility.set_location(l_proc, 120);

      open csr_ovn (p_gl_acct_id => l_opm_gl_acct_id,
                    p_effective_date => p_effective_start_date);
      fetch csr_ovn into l_ovn;
      close csr_ovn;

      pay_pga_upd.upd
          (p_effective_date               => trunc(p_effective_start_date)
          ,p_datetrack_mode               => p_dt_update_mode
          ,p_pay_gl_account_id            => l_opm_gl_acct_id
          ,p_object_version_number        => l_ovn
          ,p_set_of_books_id              => p_set_of_books_id
          ,p_gl_cash_ac_id                => p_gl_cash_ac_id
          ,p_gl_cash_clearing_ac_id       => p_gl_cash_clearing_ac_id
          ,p_gl_control_ac_id             => p_gl_control_ac_id
          ,p_gl_error_ac_id               => p_gl_error_ac_id
          ,p_effective_start_date         => l_esd_out
          ,p_effective_end_date           => l_eed_out
          );

      p_pay_gl_account_id_out := l_opm_gl_acct_id;

      hr_utility.set_location(l_proc, 130);

      if l_esd_out <> p_effective_start_date or
            l_eed_out <> p_effective_end_date then

             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','PAY_PAYMENT_GL_ACCOUNTS_PKG.UPDATE_ROW');
             hr_utility.set_message_token('STEP','20');
             hr_utility.raise_error;

      end if;

    else

      -- Default flag is 'N' but the GL Accounts for the bank details do not exist
      -- The only when this can happen is the user has unchecked the default flag
      -- to have GL accounts specifically for this OPM instead of sharing the
      -- GL accounts of its bank.

      open csr_next_seq;
      fetch csr_next_seq into l_seq_id;
      close csr_next_seq;

      l_ovn_seq := 1;

      hr_utility.set_location(l_proc, 140);

      for l_rec in csr_opm_rows (p_org_payment_method_id => p_org_payment_method_id ) loop

         hr_utility.trace('Inserting Row for OPM: ' || p_org_payment_method_id || '  ' || l_rec.effective_start_date || '  ' || l_rec.effective_end_date  );

         l_def_gl_cash_ac_id := null;
         l_def_gl_cash_clearing_ac_id := null;
         l_def_gl_control_ac_id := null;
         l_def_gl_error_ac_id := null;
         l_def_gl_set_of_books_id := null;

         if l_rec.external_account_id is not null then

            -- The OPM shared the GL Accounts of its bank earlier, but now it is being
            -- updated to have specific GL Accounts for itself
            -- For the period with effective_date, the GL accounts used by the
            -- OPM will be the values passed to the UPDATE_ROW procedure
            -- For other periods, the GL Accounts of the bank the OPM used in that period
            -- will be populated.

            hr_utility.set_location(l_proc, 141);

            open csr_def_gl_accounts(p_ext_gl_id => l_rec.external_account_id,
                                     p_effective_date => l_rec.effective_start_date);
            fetch csr_def_gl_accounts into l_def_gl_cash_ac_id, l_def_gl_cash_clearing_ac_id,
                               l_def_gl_control_ac_id, l_def_gl_error_ac_id, l_def_gl_set_of_books_id;
            close csr_def_gl_accounts;

         end if;

         hr_utility.set_location(l_proc, 142);

         insert into PAY_PAYMENT_GL_ACCOUNTS_F
         (
            PAY_GL_ACCOUNT_ID,
            EFFECTIVE_START_DATE,
            EFFECTIVE_END_DATE,
            SET_OF_BOOKS_ID,
            GL_CASH_AC_ID,
            GL_CASH_CLEARING_AC_ID,
            GL_CONTROL_AC_ID,
            GL_ERROR_AC_ID,
            EXTERNAL_ACCOUNT_ID,
            ORG_PAYMENT_METHOD_ID,
            OBJECT_VERSION_NUMBER
         )
         values
         (
            l_seq_id,
            trunc(l_rec.effective_start_date),
            trunc(l_rec.effective_end_date),
            l_def_gl_set_of_books_id,
            l_def_gl_cash_ac_id,
            l_def_gl_cash_clearing_ac_id,
            l_def_gl_control_ac_id,
            l_def_gl_error_ac_id,
            null,
            p_org_payment_method_id,
            l_ovn_seq
         );

         l_ovn_seq := l_ovn_seq + 1;

         p_pay_gl_account_id_out := l_seq_id;

         hr_utility.set_location(l_proc, 143);

      end loop;

      hr_utility.set_location(l_proc, 150);

      open csr_ovn (p_gl_acct_id => l_seq_id,
                    p_effective_date => p_effective_start_date);
      fetch csr_ovn into l_ovn;
      close csr_ovn;

      pay_pga_upd.upd
          (p_effective_date               => trunc(p_effective_start_date)
          ,p_datetrack_mode               => 'CORRECTION'
          ,p_pay_gl_account_id            => l_seq_id
          ,p_object_version_number        => l_ovn
          ,p_set_of_books_id              => p_set_of_books_id
          ,p_gl_cash_ac_id                => p_gl_cash_ac_id
          ,p_gl_cash_clearing_ac_id       => p_gl_cash_clearing_ac_id
          ,p_gl_control_ac_id             => p_gl_control_ac_id
          ,p_gl_error_ac_id               => p_gl_error_ac_id
          ,p_effective_start_date         => l_esd_out
          ,p_effective_end_date           => l_eed_out
          );

      hr_utility.set_location(l_proc, 160);

      if l_esd_out <> p_effective_start_date or
            l_eed_out <> p_effective_end_date then

             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','PAY_PAYMENT_GL_ACCOUNTS_PKG.UPDATE_ROW');
             hr_utility.set_message_token('STEP','30');
             hr_utility.raise_error;

      end if;

    end if;

  end if;

  hr_utility.set_location('Leaving: '|| l_proc, 170);
  --
end UPDATE_ROW;

procedure DELETE_ROW (
  p_org_payment_method_id in NUMBER
 ,p_effective_date      in  DATE
 ,p_datetrack_mode      in  VARCHAR2
 ,p_org_eff_start_date  in  DATE
 ,p_org_eff_end_date    in  DATE )
is
--
cursor csr_opm_gl_rows is
select pay_gl_account_id, object_version_number
from   pay_payment_gl_accounts_f
where  org_payment_method_id = p_org_payment_method_id
and    p_effective_date between effective_start_date and effective_end_date ;
--
l_pay_gl_account_id pay_payment_gl_accounts_f.pay_gl_account_id%type;
l_ovn pay_payment_gl_accounts_f.object_version_number%type;
l_esd_out date;
l_eed_out date;
l_proc   varchar2(100) := 'PAY_PAYMENT_GL_ACCOUNTS_PKG.DELETE_ROW';
--
begin
  --
  hr_utility.set_location('Entering: '|| l_proc, 10);
  hr_utility.set_location('Org Payment Method Id: '|| p_org_payment_method_id, 20);

  open csr_opm_gl_rows;
  fetch csr_opm_gl_rows into l_pay_gl_account_id, l_ovn;

  if csr_opm_gl_rows%found then

     hr_utility.set_location(l_proc, 30);

     pay_pga_del.del
         (p_effective_date            => trunc(p_effective_date)
         ,p_datetrack_mode            => p_datetrack_mode
         ,p_pay_gl_account_id         => l_pay_gl_account_id
         ,p_object_version_number     => l_ovn
         ,p_effective_start_date      => l_esd_out
         ,p_effective_end_date        => l_eed_out
         );

     hr_utility.set_location(l_proc, 40);

  end if;

  close csr_opm_gl_rows;

  hr_utility.set_location('Leaving: '|| l_proc, 50);
  --
end DELETE_ROW;

function DEFAULT_GL_ACCOUNTS (
  P_EXTERNAL_ACCOUNT_ID in NUMBER)
RETURN NUMBER is
--
cursor csr_default_gl_accounts is
select pga.pay_gl_account_id
from   pay_payment_gl_accounts_f pga
where  pga.external_account_id = p_external_account_id;
--
l_def_gl_acct_id pay_payment_gl_accounts_f.pay_gl_account_id%type;
l_proc   varchar2(100) := 'PAY_PAYMENT_GL_ACCOUNTS_PKG.DEFAULT_GL_ACCOUNTS';
--
BEGIN
  --
  hr_utility.set_location('Entering: '|| l_proc, 10);
  hr_utility.set_location('External Account Id: '|| l_proc, 20);

  if p_external_account_id is not null then

     hr_utility.set_location(l_proc, 30);
     open csr_default_gl_accounts;
     fetch csr_default_gl_accounts into l_def_gl_acct_id;

     if csr_default_gl_accounts%ROWCOUNT > 1 then

       close csr_default_gl_accounts;

       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','PAY_PAYMENT_GL_ACCOUNTS_PKG.DEFAULT_GL_ACCOUNTS');
       hr_utility.set_message_token('STEP','10');
       hr_utility.raise_error;

     end if;

     close csr_default_gl_accounts;

  else
     hr_utility.set_location(l_proc, 40);
     l_def_gl_acct_id := null;
  end if;

  hr_utility.set_location('Leaving: '|| l_proc, 50);

  return l_def_gl_acct_id;
  --
END DEFAULT_GL_ACCOUNTS;

function OPM_GL_ACCOUNTS (
  P_ORG_PAYMENT_METHOD_ID in NUMBER)
RETURN NUMBER is
--
cursor csr_opm_gl_accounts is
select distinct pga.pay_gl_account_id
from   pay_payment_gl_accounts_f pga
where  pga.org_payment_method_id = p_org_payment_method_id;
--
l_opm_gl_acct_id pay_payment_gl_accounts_f.pay_gl_account_id%type;
l_proc   varchar2(100) := 'PAY_PAYMENT_GL_ACCOUNTS_PKG.OPM_GL_ACCOUNTS';
--
BEGIN
  --
  hr_utility.set_location('Entering: '|| l_proc, 10);
  hr_utility.set_location('Org Payment Method Id: '|| p_org_payment_method_id, 20);

  if p_org_payment_method_id is not null then

     hr_utility.set_location(l_proc, 30);
     open csr_opm_gl_accounts;
     fetch csr_opm_gl_accounts into l_opm_gl_acct_id;

     if csr_opm_gl_accounts%ROWCOUNT > 1 then

       close csr_opm_gl_accounts;

       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','PAY_PAYMENT_GL_ACCOUNTS_PKG.OPM_GL_ACCOUNTS');
       hr_utility.set_message_token('STEP','10');
       hr_utility.raise_error;

     end if;

     close csr_opm_gl_accounts;

  else
     hr_utility.set_location(l_proc, 40);
     l_opm_gl_acct_id := null;
  end if;

  hr_utility.set_location('Leaving: '|| l_proc, 50);
  return l_opm_gl_acct_id;
  --
END OPM_GL_ACCOUNTS;

procedure GET_GL_ACCOUNTS
    ( p_pay_gl_account_id in number,
      p_effective_date in date,
      p_set_of_books_id out nocopy number,
      p_set_of_books_name out nocopy varchar2,
      p_gl_account_flex_num out nocopy number,
      p_gl_cash_ac_id out nocopy number,
      p_gl_cash_clearing_ac_id out nocopy number,
      p_gl_control_ac_id out nocopy number,
      p_gl_error_ac_id out nocopy number
    ) is
--
cursor csr_gl_accounts is
select gl_cash_ac_id, gl_cash_clearing_ac_id, gl_control_ac_id, gl_error_ac_id, set_of_books_id
from   pay_payment_gl_accounts_f
where  pay_gl_account_id = p_pay_gl_account_id
and    p_effective_date between effective_start_date and effective_end_date;
--
cursor csr_set_of_books_name is
select name, chart_of_accounts_id
from   gl_sets_of_books
where  set_of_books_id = p_set_of_books_id;
--
l_proc   varchar2(100) := 'PAY_PAYMENT_GL_ACCOUNTS_PKG.GET_GL_ACCOUNTS';
--
BEGIN
  --
  hr_utility.set_location('Entering: '|| l_proc, 10);

  if p_pay_gl_account_id is not null then

     hr_utility.set_location(l_proc, 20);

     open csr_gl_accounts;
     fetch csr_gl_accounts into p_gl_cash_ac_id, p_gl_cash_clearing_ac_id, p_gl_control_ac_id,
                                p_gl_error_ac_id , p_set_of_books_id ;
     close csr_gl_accounts;

     if p_set_of_books_id is not null then

       hr_utility.set_location(l_proc, 30);

       open csr_set_of_books_name;
       fetch csr_set_of_books_name into p_set_of_books_name, p_gl_account_flex_num ;
       close csr_set_of_books_name;

     end if;

     hr_utility.set_location(l_proc, 40);

  end if;
  hr_utility.set_location('Leaving: '|| l_proc, 50);
  --
END GET_GL_ACCOUNTS;


end PAY_PAYMENT_GL_ACCOUNTS_PKG;


/
