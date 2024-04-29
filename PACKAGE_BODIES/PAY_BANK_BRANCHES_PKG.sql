--------------------------------------------------------
--  DDL for Package Body PAY_BANK_BRANCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BANK_BRANCHES_PKG" as
/* $Header: pybbr01t.pkb 115.10 2004/08/20 10:50:23 arashid noship $ */
g_gb_sort_code_len number := 6;  -- GB sort code length.
g_gb_accno_len     number := 8;  -- GB account number length.
-------------------------< CHK_PRIMARY_KEY_ARGS  >--------------------------
--
--  Name
--    CHK_PRIMARY_KEY_ARGS
--
procedure chk_primary_key_args
(p_legislation_code in varchar2
,p_branch_code      in varchar2
) is
begin
  --
  -- p_branch_code and p_legislation_code must both be not NULL.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => 'chk_primary_key_args'
  ,p_argument       => 'P_BRANCH_CODE'
  ,p_argument_value => p_branch_code
  );
  --
  hr_api.mandatory_arg_error
  (p_api_name       => 'chk_primary_key_args'
  ,p_argument       => 'P_LEGISLATION_CODE'
  ,p_argument_value => p_legislation_code
  );
end chk_primary_key_args;
------------------------------< INSERT_ROW >--------------------------------
procedure insert_row
(p_branch_code           in     varchar2
,p_legislation_code      in     varchar2
,p_bank_code             in     varchar2
,p_branch                in     varchar2
,p_long_branch           in     varchar2 default null
,p_extra_information1    in     varchar2 default null
,p_extra_information2    in     varchar2 default null
,p_extra_information3    in     varchar2 default null
,p_extra_information4    in     varchar2 default null
,p_extra_information5    in     varchar2 default null
,p_enabled_flag          in     varchar2 default 'Y'
,p_start_date_active     in     date     default hr_api.g_sot
,p_end_date_active       in     date     default hr_api.g_eot
) is
l_dummy varchar2(32);
--
cursor csr_leg_code(p_legislation_code in varchar2) is
select null
from   fnd_territories
where  territory_code = p_legislation_code;
begin
  --
  -- Validate LEGISLATION_CODE.
  --
  open csr_leg_code(p_legislation_code => p_legislation_code);
  fetch csr_leg_code into l_dummy;
  if csr_leg_code%notfound then
    close csr_leg_code;
    fnd_message.set_name('PAY', 'PAY_50070_INVALID_LEG_CODE');
    fnd_message.raise_error;
  end if;
  close csr_leg_code;

  --
  -- ENABLED_FLAG must be a code for lookup type YES_NO.
  --
  if p_enabled_flag is not null and
     hr_api.not_exists_in_hr_lookups
     (p_effective_date => trunc(sysdate)
     ,p_lookup_type    => 'YES_NO'
     ,p_lookup_code    => p_enabled_flag
     )
  then
    fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
    fnd_message.set_token('LOOKUP_TYPE', 'YES_NO');
    fnd_message.set_token('COLUMN', 'P_ENABLED_FLAG');
    fnd_message.raise_error;
  end if;

  insert into pay_bank_branches
  (branch_code
  ,legislation_code
  ,bank_code
  ,branch
  ,long_branch
  ,extra_information1
  ,extra_information2
  ,extra_information3
  ,extra_information4
  ,extra_information5
  ,enabled_flag
  ,start_date_active
  ,end_date_active
  )
  values
  (p_branch_code
  ,p_legislation_code
  ,p_bank_code
  ,p_branch
  ,p_long_branch
  ,p_extra_information1
  ,p_extra_information2
  ,p_extra_information3
  ,p_extra_information4
  ,p_extra_information5
  ,p_enabled_flag
  ,p_start_date_active
  ,p_end_date_active
  );
end insert_row;
-------------------------------< LOCK_ROW >--------------------------------
procedure lock_row
(p_branch_code      in varchar2
,p_legislation_code in varchar2
) is
cursor c1 is
select *
from   pay_bank_branches
where  legislation_code = p_legislation_code
and    branch_code = p_branch_code
for    update nowait
;
--
row1    c1%rowtype;
l_debug boolean := hr_utility.debug_enabled;
begin
  if l_debug then
    hr_utility.set_location('Entering:pay_bank_branches.lock_row', 0);
  end if;
  --
  chk_primary_key_args
  (p_legislation_code => p_legislation_code
  ,p_branch_code      => p_branch_code
  );
  --
  open c1;
  fetch c1 into row1;
  if c1%notfound then
    if l_debug then
      hr_utility.set_location('Leaving:pay_bank_branches.lock_row', 10);
    end if;
    --
    close c1;
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;
  close c1;
  --
  if l_debug then
    hr_utility.set_location('Leaving:pay_bank_branches.lock_row', 20);
  end if;
end lock_row;
------------------------------< UPDATE_ROW >-------------------------------
procedure update_row
(p_branch_code        in varchar2
,p_legislation_code   in varchar2
,p_bank_code          in varchar2 default hr_api.g_varchar2
,p_branch             in varchar2 default hr_api.g_varchar2
,p_long_branch        in varchar2 default hr_api.g_varchar2
,p_extra_information1 in varchar2 default hr_api.g_varchar2
,p_extra_information2 in varchar2 default hr_api.g_varchar2
,p_extra_information3 in varchar2 default hr_api.g_varchar2
,p_extra_information4 in varchar2 default hr_api.g_varchar2
,p_extra_information5 in varchar2 default hr_api.g_varchar2
,p_enabled_flag       in varchar2 default hr_api.g_varchar2
,p_start_date_active  in date     default hr_api.g_date
,p_end_date_active    in date     default hr_api.g_date
) is
l_legislation_code   pay_bank_branches.legislation_code%type;
l_branch_code        pay_bank_branches.branch_code%type;
l_bank_code          pay_bank_branches.bank_code%type;
l_branch             pay_bank_branches.branch%type;
l_long_branch        pay_bank_branches.long_branch%type;
l_extra_information1 pay_bank_branches.extra_information1%type;
l_extra_information2 pay_bank_branches.extra_information2%type;
l_extra_information3 pay_bank_branches.extra_information3%type;
l_extra_information4 pay_bank_branches.extra_information4%type;
l_extra_information5 pay_bank_branches.extra_information5%type;
l_enabled_flag       pay_bank_branches.enabled_flag%type;
l_start_date_active  pay_bank_branches.start_date_active%type;
l_end_date_active    pay_bank_branches.end_date_active%type;
l_debug              boolean := hr_utility.debug_enabled;
cursor c1 is
select legislation_code
,      branch_code
,      bank_code
,      branch
,      long_branch
,      extra_information1
,      extra_information2
,      extra_information3
,      extra_information4
,      extra_information5
,      enabled_flag
,      start_date_active
,      end_date_active
from   pay_bank_branches
where  branch_code = p_branch_code
and    legislation_code = p_legislation_code
;
--
procedure conv(nval in varchar2, oval in out nocopy varchar2) is
begin
  if nval <> hr_api.g_varchar2 then
    oval := nval;
  end if;
end conv;
--
procedure conv(nval in date, oval in out nocopy date) is
begin
  if nval <> hr_api.g_date then
    oval := nval;
  end if;
end conv;
begin
  if l_debug then
    hr_utility.set_location('Entering:pay_bank_branches.update_row', 0);
  end if;
  --
  chk_primary_key_args
  (p_legislation_code => p_legislation_code
  ,p_branch_code      => p_branch_code
  );
  --
  open c1;
  fetch c1
  into  l_legislation_code
  ,     l_branch_code
  ,     l_bank_code
  ,     l_branch
  ,     l_long_branch
  ,     l_extra_information1
  ,     l_extra_information2
  ,     l_extra_information3
  ,     l_extra_information4
  ,     l_extra_information5
  ,     l_enabled_flag
  ,     l_start_date_active
  ,     l_end_date_active
  ;
  if c1%notfound then
    if l_debug then
      hr_utility.set_location('Leaving:pay_bank_branches.update_row', 10);
    end if;
    --
    close c1;
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;
  close c1;
  --
  conv(p_branch_code,        l_branch_code);
  conv(p_bank_code,          l_bank_code);
  conv(p_branch,             l_branch);
  conv(p_long_branch,        l_long_branch);
  conv(p_extra_information1, l_extra_information1);
  conv(p_extra_information2, l_extra_information2);
  conv(p_extra_information3, l_extra_information3);
  conv(p_extra_information4, l_extra_information4);
  conv(p_extra_information5, l_extra_information5);
  conv(p_enabled_flag,       l_enabled_flag);
  conv(p_start_date_active,  l_start_date_active);
  conv(p_end_date_active,    l_end_date_active);

  --
  -- ENABLED_FLAG must be a code for lookup type YES_NO.
  --
  if l_enabled_flag is not null and
     hr_api.not_exists_in_hr_lookups
     (p_effective_date => trunc(sysdate)
     ,p_lookup_type    => 'YES_NO'
     ,p_lookup_code    => l_enabled_flag
     )
  then
    fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
    fnd_message.set_token('LOOKUP_TYPE', 'YES_NO');
    fnd_message.set_token('COLUMN', 'P_ENABLED_FLAG');
    fnd_message.raise_error;
  end if;

  update pay_bank_branches
  set  bank_code          = l_bank_code
  ,    branch             = l_branch
  ,    long_branch        = l_long_branch
  ,    extra_information1 = l_extra_information1
  ,    extra_information2 = l_extra_information2
  ,    extra_information3 = l_extra_information3
  ,    extra_information4 = l_extra_information4
  ,    extra_information5 = l_extra_information5
  ,    enabled_flag       = l_enabled_flag
  ,    start_date_active  = l_start_date_active
  ,    end_date_active    = l_end_date_active
  where  branch_code      = l_branch_code
  and    legislation_code = l_legislation_code
  ;
  --
  if l_debug then
    hr_utility.set_location('Leaving:pay_bank_branches.update_row', 20);
  end if;
end update_row;
------------------------------< DELETE_ROW >-------------------------------
procedure delete_row
(p_branch_code      in varchar2
,p_legislation_code in varchar2
) is
l_debug boolean := hr_utility.debug_enabled;
begin
  if l_debug then
    hr_utility.set_location('Entering:pay_bank_branches.delete_row', 0);
  end if;
  --
  chk_primary_key_args
  (p_legislation_code => p_legislation_code
  ,p_branch_code      => p_branch_code
  );
  --
  if l_debug then
    hr_utility.set_location('pay_bank_branches.delete_row', 10);
  end if;
  --
  delete
  from   pay_bank_branches
  where  legislation_code = p_legislation_code
  and    branch_code = p_branch_code
  ;
  --
  if l_debug then
    hr_utility.set_location('Leaving:pay_bank_branches.delete_row', 20);
  end if;
end delete_row;
--------------------------< VALIDATE_GB_VALUES >--------------------------
--
-- Name
--   VALIDATE_GB_VALUES
--
-- Description
--   Carries out GB-specific validation of the bank values.
--   Only checks p_branch if p_insert is false.
--
procedure validate_gb_values
(p_sort_code in out nocopy varchar2
,p_branch    in            varchar2
,p_bank_code in            varchar2
,p_insert    in            boolean
) is
l_sort_code_len number := g_gb_sort_code_len;
l_branch_len    number := 35;
l_bs_acct_len   number := 18;
l_proc          varchar2(100) := 'pay_bank_branches_pkg.validate_gb_values';
l_temp_string   varchar2(100);
l_debug         boolean := hr_utility.debug_enabled;
begin
  if l_debug then
    hr_utility.set_location('Entering:' || l_proc, 0);
  end if;
  --
  -- SORT_CODE must be 6 byte number string, left-padded with zeroes if
  -- necessary. SORT_CODE is part of the primary key therefore only
  -- validate upon insert.
  --
  if p_insert then
    --
    -- Length check.
    --
    if length(p_sort_code) > l_sort_code_len then
      fnd_message.set_name('PAY', 'HR_51419_EXA_SORT_CODE_LENGTH');
      fnd_message.raise_error;
    end if;
    --
    -- The sort code must only contain digits (0-9).
    --
    l_temp_string := translate(p_sort_code, '0123456789','0000000000');
    if l_temp_string <> lpad('0', length(p_sort_code), '0') then
      fnd_message.set_name('PAY', 'PAY_51538_BAD_GB_SORT_CODE');
      fnd_message.raise_error;
    end if;
    --
    -- Left-pad with zeroes, if necessary.
    --
    if length(p_sort_code) < l_sort_code_len then
      if l_debug then
        hr_utility.set_location(l_proc, 10);
      end if;
      p_sort_code := lpad(p_sort_code, l_sort_code_len, 0);
    end if;
  end if;

  --
  -- BANK_CODE must be a code for lookup type GB_BANKS.
  --
  if p_insert and
     hr_api.not_exists_in_hr_lookups
     (p_effective_date => trunc(sysdate)
     ,p_lookup_type    => 'GB_BANKS'
     ,p_lookup_code    => p_bank_code
     )
  then
    fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
    fnd_message.set_token('LOOKUP_TYPE', 'GB_BANKS');
    fnd_message.set_token('COLUMN', 'P_BANK_CODE');
    fnd_message.raise_error;
  end if;

  --
  -- BRANCH must be <= 35 bytes in length.
  --
  if lengthb(p_branch) > l_branch_len then
    fnd_message.set_name('PAY', 'HR_51418_EXA_BANK_BRANCH_LONG');
    fnd_message.raise_error;
  end if;

  if l_debug then
    hr_utility.set_location('Leaving:' || l_proc, 40);
  end if;
end validate_gb_values;
----------------------------< INSERT_GB_ROW >------------------------------
procedure insert_gb_row
(p_sort_code             in out nocopy varchar2
,p_bank_code             in            varchar2
,p_branch                in            varchar2
,p_long_branch           in            varchar2 default null
,p_building_society_acct in out nocopy varchar2
,p_enabled_flag          in            varchar2 default 'Y'
,p_start_date_active     in            date     default hr_api.g_sot
,p_end_date_active       in            date     default hr_api.g_eot
) is
begin
  validate_gb_values
  (p_sort_code => p_sort_code
  ,p_branch    => p_branch
  ,p_bank_code => p_bank_code
  ,p_insert    => true
  );
  --
  insert_row
  (p_branch_code        => p_sort_code
  ,p_legislation_code   => 'GB'
  ,p_bank_code          => p_bank_code
  ,p_branch             => p_branch
  ,p_long_branch        => p_long_branch
  ,p_enabled_flag       => p_enabled_flag
  ,p_start_date_active  => p_start_date_active
  ,p_end_date_active    => p_end_date_active
  );
end insert_gb_row;
----------------------------< UPDATE_GB_ROW >------------------------------
procedure update_gb_row
(p_sort_code             in            varchar2
,p_branch                in            varchar2 default hr_api.g_varchar2
,p_long_branch           in            varchar2 default hr_api.g_varchar2
,p_building_society_acct in out nocopy varchar2
,p_enabled_flag          in            varchar2 default hr_api.g_varchar2
,p_start_date_active     in            date     default hr_api.g_date
,p_end_date_active       in            date     default hr_api.g_date
) is
l_sort_code varchar2(100);
-- Values to pass to VALIDATE_GB_VALUES.
l_branch    pay_bank_branches.branch%type;
--
cursor csr_existing_row(p_sort_code in varchar2) is
select branch
from   pay_bank_branches
where  branch_code = p_sort_code
and    legislation_code = 'GB'
;
begin
  --
  -- Get the existing values for branch and building society account to
  -- use in validation for the case where the passed in values are
  -- hr_api.g_varchar2.
  --
  l_sort_code := lpad(p_sort_code, g_gb_sort_code_len, '0');
  open csr_existing_row(p_sort_code => l_sort_code);
  fetch csr_existing_row
  into  l_branch
  ;
  if csr_existing_row%found then
    if p_branch <> hr_api.g_varchar2 then
      l_branch := p_branch;
    end if;
  --
  -- The existing row was not found. Allow the validation to succeed and
  -- let the error get raised by VALIDATE_GB_VALUES.
  --
  else
    l_branch := 'BRANCH';
  end if;
  close csr_existing_row;
  --
  validate_gb_values
  (p_sort_code => l_sort_code
  ,p_branch    => l_branch
  ,p_bank_code => null
  ,p_insert    => false
  );
  --
  update_row
  (p_branch_code        => l_sort_code
  ,p_legislation_code   => 'GB'
  ,p_branch             => p_branch
  ,p_long_branch        => p_long_branch
  ,p_enabled_flag       => p_enabled_flag
  ,p_start_date_active  => p_start_date_active
  ,p_end_date_active    => p_end_date_active
  );
end update_gb_row;
------------------------< DISPLAY_TO_GB_ACCOUNT >--------------------------
procedure display_to_gb_account
(p_external_account_id   in out nocopy number
,p_object_version_number in out nocopy number
,p_business_group_id     in            number
,p_effective_date        in            date
,p_account_name          in            varchar2
,p_account_number        in            varchar2
,p_sort_code             in            varchar2
,p_building_society_acct in            varchar2 default null
,p_multi_message         in            boolean  default false
,p_return_status            out nocopy varchar2
,p_msg_count                out nocopy number
,p_msg_data                 out nocopy varchar2
) is
cursor csr_account
(p_external_account_id   in number
,p_sort_code             in varchar2
,p_account_name          in varchar2
,p_account_number        in varchar2
,p_building_society_acct in varchar2
) is
select null
from   pay_external_accounts exa
where  exa.external_account_id = p_external_account_id
and    exa.segment3 = p_sort_code
and    exa.segment4 = p_account_number
and    exa.segment5 = p_account_name
and    ((exa.segment7 is null and
         p_building_society_acct is null) or
         (exa.segment7 = p_building_society_acct))
;
--
cursor csr_branch_info(p_sort_code in varchar2) is
select pbb.bank_code
,      pbb.branch
,      pbb.enabled_flag
,      pbb.start_date_active
,      pbb.end_date_active
from   pay_bank_branches pbb
where  pbb.legislation_code = 'GB'
and    pbb.branch_code = p_sort_code
;
--
l_debug       boolean := hr_utility.debug_enabled;
l_enabled     boolean;
l_changed     boolean;
l_exists      varchar2(1);
l_branch_info csr_branch_info%rowtype;
l_accno       varchar2(2000);
l_sort_code   varchar2(2000);
l_temp_string varchar2(2000);
l_proc        varchar2(64) := 'pay_bank_branches_pkg.display_to_gb_account';
begin
  if l_debug then
    hr_utility.set_location('Entering:' || l_proc, 0);
  end if;
  --
  -- Clear message table.
  --
  fnd_msg_pub.initialize;
  --
  -- Account number length check.
  --
  if length(p_account_number) > g_gb_accno_len then
    fnd_message.set_name('PAY', 'HR_51421_EXA_ACCOUNT_NO_LONG');
    fnd_message.raise_error;
  end if;
  --
  -- The account number must only contain digits (0-9).
  --
  l_temp_string := translate(p_account_number, '0123456789','0000000000');
  if l_temp_string <> lpad('0', length(p_account_number), '0') then
    fnd_message.set_name('PAY', 'HR_51422_EXA_ACCT_NO_POSITIVE');
    fnd_message.raise_error;
  end if;
  --
  -- Check whether or not the external account row has changed.
  --
  l_sort_code := lpad(p_sort_code, g_gb_sort_code_len, '0');
  l_accno := lpad(p_account_number, g_gb_accno_len, '0');
  open csr_account
  (p_external_account_id   => p_external_account_id
  ,p_sort_code             => l_sort_code
  ,p_account_name          => upper(p_account_name)
  ,p_account_number        => l_accno
  ,p_building_society_acct => upper(p_building_society_acct)
  );
  fetch csr_account into l_exists;
  l_changed := csr_account%notfound;
  close csr_account;
  --
  if l_debug then
    hr_utility.set_location(l_proc, 5);
  end if;
  --
  -- Fetch the branch information for this sort code if the external
  -- account row has changed.
  --
  if l_changed then
    if l_debug then
      hr_utility.set_location(l_proc, 10);
    end if;
    --
    open csr_branch_info(p_sort_code);
    fetch csr_branch_info into l_branch_info;
    --
    -- Find out whether the sort code exists and is enabled.
    --
    if csr_branch_info%found then
      l_enabled :=
      nvl(upper(l_branch_info.enabled_flag), 'Y') = 'Y' and
      p_effective_date between
        nvl(l_branch_info.start_date_active, hr_api.g_sot) and
        nvl(l_branch_info.end_date_active, hr_api.g_eot);
    else
      l_enabled := false;
    end if;
    close csr_branch_info;
    --
    if l_enabled then
      if l_debug then
        hr_utility.set_location(l_proc, 15);
      end if;
      --
      -- Create the new account.
      --
      pay_exa_ins.ins_or_sel
      (p_validate              => false
      ,p_territory_code        => 'GB'
      ,p_business_group_id     => p_business_group_id
      ,p_segment1              => l_branch_info.bank_code
      ,p_segment2              => l_branch_info.branch
      ,p_segment3              => p_sort_code
      ,p_segment4              => p_account_number
      ,p_segment5              => p_account_name
      ,p_segment7              => p_building_society_acct
      ,p_external_account_id   => p_external_account_id
      ,p_object_version_number => p_object_version_number
      );
    else
      if l_debug then
        hr_utility.set_location(l_proc, 20);
      end if;
      --
      fnd_message.set_name('PAY', 'PAY_33100_INVALID_SORT_CODE');
      fnd_message.set_token('SORT_CODE', p_sort_code);
      fnd_message.raise_error;
    end if;
  end if;
  --
  p_return_status := fnd_api.G_RET_STS_SUCCESS;
  --
  if l_debug then
    hr_utility.set_location('Leaving:' || l_proc, 25);
  end if;
exception
  when others then
    if csr_account%isopen then
      close csr_account;
    end if;
    --
    if csr_branch_info%isopen then
      close csr_branch_info;
    end if;
    --
    -- Handle errors according to the specified mechanism.
    --
    if p_multi_message then
      p_return_status := fnd_api.G_RET_STS_ERROR;
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get
      (p_count => p_msg_count
      ,p_data  => p_msg_data
      );
      --
      if l_debug then
        hr_utility.set_location('Leaving:' || l_proc, 35);
      end if;
    else
      --
      if l_debug then
        hr_utility.set_location('Leaving:' || l_proc, 40);
      end if;
      raise;
    end if;
end display_to_gb_account;
--
end pay_bank_branches_pkg;

/
