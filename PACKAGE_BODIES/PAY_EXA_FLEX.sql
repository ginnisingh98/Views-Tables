--------------------------------------------------------
--  DDL for Package Body PAY_EXA_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EXA_FLEX" as
/* $Header: pyexafli.pkb 115.2 99/07/17 06:02:19 porting ship  $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_exa_flex.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_gb_segment1 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segment1 attribute for GB legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment1  -> Bank Name
--
-- Post Success:
--   If the p_segment1 is valid then processing continues.
--
-- Post Failure:
--   If any of the following cases are true then an application error will
--   be raised:
--   a) p_segment1 cannot be NULL.
--   b) p_segment1 cannot exceed 30 in length.
--   c) p_segment1 must be valid and exist within the GB_BANKS lookup_type.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_gb_segment1
            (p_segment1 in pay_external_accounts.segment1%type) is
--
  cursor hlsel is
    select null
    from   hr_lookups
    where  lookup_type = 'GB_BANKS'
    and    lookup_code = p_segment1;
--
  l_proc        varchar2(72) := g_package||'chk_gb_segment1';
  l_dummy	number;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that segment1 is mandatory
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'segment1',
     p_argument_value => p_segment1);
  --
  -- Ensure that the length does not exceed 30
  --
  if (length(p_segment1) > 30) then
    hr_utility.set_message(801, 'HR_51416_EXA_BANK_NAME_LONG');
    hr_utility.set_message_token('ARG_NAME', 'p_segment1');
    hr_utility.set_message_token('ARG_VALUE', p_segment1);
    hr_utility.raise_error;
  end if;
  --
  -- Ensure that the p_segment1 is valid and exists
  --
  open hlsel;
  fetch hlsel into l_dummy;
  if hlsel%notfound then
    close hlsel;
    hr_utility.set_message(801, 'HR_51417_EXA_BANK_NAME_UNKNOWN');
    hr_utility.set_message_token('ARG_NAME', 'p_segment1');
    hr_utility.set_message_token('ARG_VALUE', p_segment1);
    hr_utility.raise_error;
  end if;
  close hlsel;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_gb_segment1;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_gb_segment2 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segment2 attribute for GB legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment2  -> Bank Branch
--
-- Post Success:
--   If the p_segment2 is valid then processing continues.
--
-- Post Failure:
--   If any of the following cases are true then an application error will
--   be raised:
--   a) p_segment2 cannot exceed 35 in length.
--   b) p_segment2 must be valid and exist within the
--      'US_ACCOUNT_TYPE lookup_type.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_gb_segment2
            (p_segment2 in pay_external_accounts.segment2%type) is
--
  l_proc        varchar2(72) := g_package||'chk_gb_segment2';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the length does not exceed 35
  --
  if (length(p_segment2) > 35) then
    hr_utility.set_message(801, 'HR_51418_EXA_BANK_BRANCH_LONG');
    hr_utility.set_message_token('ARG_NAME', 'p_segment2');
    hr_utility.set_message_token('ARG_VALUE', p_segment2);
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_gb_segment2;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_gb_segment3 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segment3 attribute for GB legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment3  -> Sort Code
--
-- Post Success:
--   If the p_segment3 is valid then processing continues.
--
-- Post Failure:
--   If any of the following cases are true then an application error will
--   be raised:
--   a) p_segment3 cannot be NULL.
--   b) p_segment3 is not 6 in length.
--   c) p_segment3 must be in a numeric format.
--   d) p_segment3 is -ve
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_gb_segment3
            (p_segment3 in pay_external_accounts.segment3%type) is
--
  l_proc        varchar2(72) := g_package||'chk_gb_segment3';
  l_segment3    pay_external_accounts.segment3%type;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that segment3 is mandatory
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'segment3',
     p_argument_value => p_segment3);
  --
  -- Ensure that the length is 6
  --
  if (length(p_segment3) <> 6) then
    hr_utility.set_message(801, 'HR_51419_EXA_SORT_CODE_LENGTH');
    hr_utility.set_message_token('ARG_NAME', 'p_segment3');
    hr_utility.set_message_token('ARG_VALUE', p_segment3);
    hr_utility.raise_error;
  end if;
  --
  -- Ensure that the p_segment3 is in a number format
  --
  hr_utility.set_location(l_proc,7);
  l_segment3 := p_segment3;
  --
  hr_dbchkfmt.is_db_format
    (p_value    => l_segment3,
     p_arg_name => 'segment3',
     p_format   => 'I');
  --
  hr_utility.set_location(l_proc,8);
  --
  -- Ensure that p_segment3 is +ve
  --
  if (fnd_number.canonical_to_number(p_segment3) < 0) then
    hr_utility.set_message(801, 'HR_51420_EXA_SORT_CODE_POSITVE');
    hr_utility.set_message_token('ARG_NAME', 'p_segment3');
    hr_utility.set_message_token('ARG_VALUE', p_segment3);
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_gb_segment3;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_gb_segment4 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segment4 attribute for GB legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment4  -> Account Number
--
-- Post Success:
--   If the p_segment4 is valid then processing continues.
--
-- Post Failure:
--   If any of the following cases are true then an application error will
--   be raised:
--   a) p_segment4 cannot be NULL.
--   b) p_segment4 is not 8 in length.
--   c) p_segment4 must be in a numeric format.
--   d) p_segment4 is -ve
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_gb_segment4
            (p_segment4 in pay_external_accounts.segment4%type) is
--
  l_proc        varchar2(72) := g_package||'chk_gb_segment4';
  l_segment4    pay_external_accounts.segment4%type;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that segment4 is mandatory
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'segment4',
     p_argument_value => p_segment4);
  --
  -- Ensure that the length is 8
  --
  if (length(p_segment4) <> 8) then
    hr_utility.set_message(801, 'HR_51421_EXA_ACCOUNT_NO_LONG');
    hr_utility.set_message_token('ARG_NAME', 'p_segment4');
    hr_utility.set_message_token('ARG_VALUE', p_segment4);
    hr_utility.raise_error;
  end if;
  --
  -- Ensure that the p_segment4 is in a number format
  --
  l_segment4 := p_segment4;
  hr_dbchkfmt.is_db_format
    (p_value    => l_segment4,
     p_arg_name => 'segment4',
     p_format   => 'I');
  --
  -- Ensure that p_segment4 is +ve
  --
  if (fnd_number.canonical_to_number(p_segment4) < 0) then
    hr_utility.set_message(801, 'HR_51422_EXA_ACCT_NO_POSITIVE');
    hr_utility.set_message_token('ARG_NAME', 'p_segment4');
    hr_utility.set_message_token('ARG_VALUE', p_segment4);
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_gb_segment4;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_gb_segment5 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segment5 attribute for GB legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment5  -> Account Name
--
-- Post Success:
--   If the p_segment5 is valid then processing continues.
--
-- Post Failure:
--   If any of the following cases are true then an application error will
--   be raised:
--   a) p_segment5 cannot be NULL.
--   b) p_segment5 cannot exceed 18 in length.
--   c) p_segment5 must be in an uppercase format.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_gb_segment5
            (p_segment5 in pay_external_accounts.segment5%type) is
--
  l_proc        varchar2(72) := g_package||'chk_gb_segment5';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that segment5 is mandatory
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'segment5',
     p_argument_value => p_segment5);
  --
  -- Ensure that the length does not exceed 18
  --
  if (length(p_segment5) > 18) then
    hr_utility.set_message(801, 'HR_51423_EXA_ACCOUNT_NAME_LONG');
    hr_utility.set_message_token('ARG_NAME', 'p_segment5');
    hr_utility.set_message_token('ARG_VALUE', p_segment5);
    hr_utility.raise_error;
  end if;
  --
  -- Ensure that the p_segment5 is in an upperformat format
  --
  if (p_segment5 <> upper(p_segment5)) then
    hr_utility.set_message(801, 'HR_51424_EXA_ACCOUNT_NAME_CASE');
    hr_utility.set_message_token('ARG_NAME', 'p_segment5');
    hr_utility.set_message_token('ARG_VALUE', p_segment5);
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_gb_segment5;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_gb_segment6 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segment6 attribute for GB legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment6  -> Account Type
--
-- Post Success:
--   If the p_segment6 is valid then processing continues.
--
-- Post Failure:
--   If any of the following cases are true then an application error will
--   be raised:
--   a) p_segment6 cannot exceed 1 in length.
--   b) p_segment6 must be in a numeric format.
--   c) p_segment6 Min value: 0, Max value: 5
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_gb_segment6
            (p_segment6 in pay_external_accounts.segment6%type) is
--
  l_proc        varchar2(72) := g_package||'chk_gb_segment6';
  l_segment6	pay_external_accounts.segment6%type;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_segment6 is not null then
    --
    -- Ensure that the length does not exceed 1
    --
    if (length(p_segment6) > 1) then
      hr_utility.set_message(801, 'HR_51425_EXA_ACCOUNT_TYPE_LONG');
      hr_utility.set_message_token('ARG_NAME', 'p_segment6');
      hr_utility.set_message_token('ARG_VALUE', p_segment6);
      hr_utility.raise_error;
    end if;
    --
    -- Ensure that the p_segment6 is in a number format
    --
    l_segment6 := p_segment6;
    hr_dbchkfmt.is_db_format
      (p_value    => l_segment6,
       p_arg_name => 'segment6',
       p_format   => 'I');
    --
    -- Ensure that p_segment4 is in the range of:0 to 5
    --
    if (fnd_number.canonical_to_number(p_segment6) < 0 or fnd_number.canonical_to_number(p_segment6) > 5) then
      hr_utility.set_message(801, 'HR_51426_EXA_ACCT_TYPE_RANGE');
      hr_utility.set_message_token('ARG_NAME', 'p_segment6');
      hr_utility.set_message_token('ARG_VALUE', p_segment6);
      hr_utility.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_gb_segment6;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_gb_segment7 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segment7 attribute for GB legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment7  -> Building Society Account Number
--
-- Post Success:
--   If the p_segment7 is valid then processing continues.
--
-- Post Failure:
--   If any of the following cases are true then an application error will
--   be raised:
--   a) p_segment7 cannot exceed 18 in length.
--   b) p_segment7 must be in uppercase format.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_gb_segment7
            (p_segment7 in pay_external_accounts.segment7%type) is
--
  l_proc        varchar2(72) := g_package||'chk_gb_segment7';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_segment7 is not null then
    --
    -- Ensure that the length does not exceed 18
    --
    if (length(p_segment7) > 18) then
      hr_utility.set_message(801, 'HR_51427_EXA_BS_ACCT_NO_LONG');
      hr_utility.set_message_token('ARG_NAME', 'p_segment7');
      hr_utility.set_message_token('ARG_VALUE', p_segment7);
      hr_utility.raise_error;
    end if;
    --
    -- Ensure that the p_segment7 is in an uppercase format
    --
    if (p_segment7 <> upper(p_segment7)) then
      hr_utility.set_message(801, 'HR_51428_EXA_BS_ACCT_NO_CASE');
      hr_utility.set_message_token('ARG_NAME', 'p_segment7');
      hr_utility.set_message_token('ARG_VALUE', p_segment7);
      hr_utility.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_gb_segment7;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_gb_segment8 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segment8 attribute for GB legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment8  -> Bank Branch Location
--
-- Post Success:
--   If the p_segment8 is valid then processing continues.
--
-- Post Failure:
--   If any of the following cases are true then an application error will
--   be raised:
--   a) p_segment8 cannot exceed 20 in length.
--   b) p_segment8 must exist in hr_lookups where lookup_type =
--      'GB_COUNTRY'.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_gb_segment8
            (p_segment8 in pay_external_accounts.segment8%type) is
--
  l_proc        varchar2(72) := g_package||'chk_gb_segment8';
  l_exists      varchar2(80);
--
  cursor csr_chk_hr_lookups is
  select null
  from hr_lookups
  where LOOKUP_TYPE = 'GB_COUNTRY'
  and   lookup_code = p_segment8;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_segment8 is not null then
    --
    -- Ensure that the length does not exceed 20
    --
    if (length(p_segment8) > 20) then
      hr_utility.set_message(801, 'HR_51429_EXA_BANK_LOC_LONG');
      hr_utility.set_message_token('ARG_NAME', 'p_segment8');
      hr_utility.set_message_token('ARG_VALUE', p_segment8);
      hr_utility.raise_error;
    end if;
    --
    -- Ensure that the p_segment8 exists in hr_lookups where lookup_type =
    -- 'GB_COUNTRY'
    --
    open csr_chk_hr_lookups;
    fetch csr_chk_hr_lookups into l_exists;
    if csr_chk_hr_lookups%notfound then
      close csr_chk_hr_lookups;
      hr_utility.set_message(801, 'HR_51430_EXA_BANK_LOC_UNKNOWN');
      hr_utility.set_message_token('ARG_NAME', 'p_segment8');
      hr_utility.set_message_token('ARG_VALUE', p_segment8);
      hr_utility.raise_error;
    end if;
    close csr_chk_hr_lookups;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_gb_segment8;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_gb_segment9_30 >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segments 9..30 for GB legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment9..30
--
-- Post Success:
--   If the p_segment9..30 are NULL then processing continues.
--
-- Post Failure:
--   If any of segments9..30 are NOT NULL then an aplication error will be
--   raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_gb_segment9_30
            (p_segment9  in pay_external_accounts.segment9%type,
             p_segment10 in pay_external_accounts.segment10%type,
             p_segment11 in pay_external_accounts.segment11%type,
             p_segment12 in pay_external_accounts.segment12%type,
             p_segment13 in pay_external_accounts.segment13%type,
             p_segment14 in pay_external_accounts.segment14%type,
             p_segment15 in pay_external_accounts.segment15%type,
             p_segment16 in pay_external_accounts.segment16%type,
             p_segment17 in pay_external_accounts.segment17%type,
             p_segment18 in pay_external_accounts.segment18%type,
             p_segment19 in pay_external_accounts.segment19%type,
             p_segment20 in pay_external_accounts.segment20%type,
             p_segment21 in pay_external_accounts.segment21%type,
             p_segment22 in pay_external_accounts.segment22%type,
             p_segment23 in pay_external_accounts.segment23%type,
             p_segment24 in pay_external_accounts.segment24%type,
             p_segment25 in pay_external_accounts.segment25%type,
             p_segment26 in pay_external_accounts.segment26%type,
             p_segment27 in pay_external_accounts.segment27%type,
             p_segment28 in pay_external_accounts.segment28%type,
             p_segment29 in pay_external_accounts.segment29%type,
             p_segment30 in pay_external_accounts.segment30%type) is
--
  l_proc  varchar2(72) := g_package||'chk_gb_segment9_30';
  l_err   exception;                           -- local error exception
  l_n     number;                              -- arg in error number (9..30)
  l_v     pay_external_accounts.segment8%type; -- arg in error value (9..30)
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_segment9  is not null then l_n:=9; l_v:=p_segment9 ;raise l_err;end if;
  if p_segment10 is not null then l_n:=10;l_v:=p_segment10;raise l_err;end if;
  if p_segment11 is not null then l_n:=11;l_v:=p_segment11;raise l_err;end if;
  if p_segment12 is not null then l_n:=12;l_v:=p_segment12;raise l_err;end if;
  if p_segment13 is not null then l_n:=13;l_v:=p_segment13;raise l_err;end if;
  if p_segment14 is not null then l_n:=14;l_v:=p_segment14;raise l_err;end if;
  if p_segment15 is not null then l_n:=15;l_v:=p_segment15;raise l_err;end if;
  if p_segment16 is not null then l_n:=16;l_v:=p_segment16;raise l_err;end if;
  if p_segment17 is not null then l_n:=17;l_v:=p_segment17;raise l_err;end if;
  if p_segment18 is not null then l_n:=18;l_v:=p_segment18;raise l_err;end if;
  if p_segment19 is not null then l_n:=19;l_v:=p_segment19;raise l_err;end if;
  if p_segment20 is not null then l_n:=20;l_v:=p_segment20;raise l_err;end if;
  if p_segment21 is not null then l_n:=21;l_v:=p_segment21;raise l_err;end if;
  if p_segment22 is not null then l_n:=22;l_v:=p_segment22;raise l_err;end if;
  if p_segment23 is not null then l_n:=23;l_v:=p_segment23;raise l_err;end if;
  if p_segment24 is not null then l_n:=24;l_v:=p_segment24;raise l_err;end if;
  if p_segment25 is not null then l_n:=25;l_v:=p_segment25;raise l_err;end if;
  if p_segment26 is not null then l_n:=26;l_v:=p_segment26;raise l_err;end if;
  if p_segment27 is not null then l_n:=27;l_v:=p_segment27;raise l_err;end if;
  if p_segment28 is not null then l_n:=28;l_v:=p_segment28;raise l_err;end if;
  if p_segment29 is not null then l_n:=29;l_v:=p_segment29;raise l_err;end if;
  if p_segment30 is not null then l_n:=30;l_v:=p_segment30;raise l_err;end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
exception
  when l_err then
    hr_utility.set_message(801, 'HR_7296_API_ARG_NOT_SUP');
    hr_utility.set_message_token('ARG_NAME', 'p_segment'||to_char(l_n));
    hr_utility.set_message_token('ARG_VALUE', l_v);
    hr_utility.raise_error;
end chk_gb_segment9_30;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_us_segment1 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segment1 attribute for US legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment1  -> Account Name
--
-- Post Success:
--   If the p_segment1 is valid then processing continues.
--
-- Post Failure:
--   If any of the following cases are true then an application error will
--   be raised:
--   a) p_segment1 cannot be NULL.
--   b) p_segment1 cannot exceed 60 in length.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment1
            (p_segment1 in pay_external_accounts.segment1%type) is
--
  l_proc        varchar2(72) := g_package||'chk_us_segment1';
  l_dummy	number;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that segment1 is mandatory
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'segment1',
     p_argument_value => p_segment1);
  --
  -- Ensure that the length does not exceed 60
  --
  hr_utility.set_location(l_proc,7);
  if (length(p_segment1) > 60) then
    hr_utility.set_message(801, 'HR_51458_EXA_US_ACCT_NAME_LONG');
    hr_utility.set_message_token('ARG_NAME', 'p_segment1');
    hr_utility.set_message_token('ARG_VALUE', p_segment1);
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_us_segment1;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_us_segment2 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segment2 attribute for US legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment2  -> Account Type
--
-- Post Success:
--   If the p_segment2 is valid then processing continues.
--
-- Post Failure:
--   If any of the following cases are true then an application error will
--   be raised:
--   a) p_segment2 cannot be NULL.
--   b) p_segment2 cannot exceed 80 in length.
--   c) p_segment2 must be valid and exist within the
--      'US_ACCOUNT_TYPE' lookup_type.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment2
            (p_segment2 in pay_external_accounts.segment2%type) is
--
  cursor fnd_com_look is
    select null
    from   fnd_common_lookups
    where  lookup_type = 'US_ACCOUNT_TYPE'
    and    application_id = 800
    and    lookup_code = p_segment2;
--
  l_proc        varchar2(72) := g_package||'chk_us_segment2';
  l_dummy	number;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that segment2 is mandatory
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'segment2',
     p_argument_value => p_segment2);
  --
  -- Ensure that the length does not exceed 80
  --
  hr_utility.set_location(l_proc,6);
  if (length(p_segment2) > 80) then
    hr_utility.set_message(801, 'HR_51459_EXA_US_ACCT_TYPE_LONG');
    hr_utility.set_message_token('ARG_NAME', 'p_segment2');
    hr_utility.set_message_token('ARG_VALUE', p_segment2);
    hr_utility.raise_error;
  end if;
  --
  -- Ensure that the p_segment2 is valid and exists
  --
  hr_utility.set_location(l_proc,7);
  open fnd_com_look;
  fetch fnd_com_look into l_dummy;
  if fnd_com_look%notfound then
    close fnd_com_look;
    hr_utility.set_message(801, 'HR_51460_EXA_US_ACC_TYP_UNKNOW');
    hr_utility.set_message_token('ARG_NAME', 'p_segment2');
    hr_utility.set_message_token('ARG_VALUE', p_segment2);
    hr_utility.raise_error;
  end if;
  close fnd_com_look;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_us_segment2;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_us_segment3 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segment3 attribute for US legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment3  -> Account Number
--
-- Post Success:
--   If the p_segment3 is valid then processing continues.
--
-- Post Failure:
--   If any of the following cases are true then an application error will
--   be raised:
--   a) p_segment3 cannot be NULL.
--   b) p_segment3 cannot exceed 60 in length.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment3
            (p_segment3 in pay_external_accounts.segment3%type) is
--
  l_proc        varchar2(72) := g_package||'chk_us_segment3';
  l_dummy	number;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that segment3 is mandatory
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'segment3',
     p_argument_value => p_segment3);
  --
  -- Ensure that the length does not exceed 60
  --
  hr_utility.set_location(l_proc,7);
  if (length(p_segment3) > 60) then
    hr_utility.set_message(801, 'HR_51461_EXA_US_ACCT_NO_LONG');
    hr_utility.set_message_token('ARG_NAME', 'p_segment3');
    hr_utility.set_message_token('ARG_VALUE', p_segment3);
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_us_segment3;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_us_segment4 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segment4 attribute for US legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment4  -> Transit Code
--
-- Post Success:
--   If the p_segment4 is valid then processing continues.
--
-- Post Failure:
--   If any of the following cases are true then an application error will
--   be raised:
--   a) p_segment4 cannot be NULL.
--   b) p_segment4 cannot exceed 9 in length.
--   c) p_segment4 must be a number.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment4
            (p_segment4 in pay_external_accounts.segment4%type) is
--
  l_segment4    pay_external_accounts.segment4%type;
  l_proc        varchar2(72) := g_package||'chk_us_segment4';
  l_dummy	number;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that segment4 is mandatory
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'segment4',
     p_argument_value => p_segment4);
  --
  -- Ensure that the length does not exceed 9
  --
  hr_utility.set_location(l_proc,6);
  if (length(p_segment4) > 9) then
    hr_utility.set_message(801, 'HR_51462_EXA_US_TRAN_CODE_LONG');
    hr_utility.set_message_token('ARG_NAME', 'p_segment4');
    hr_utility.set_message_token('ARG_VALUE', p_segment4);
    hr_utility.raise_error;
  end if;
  --
  -- Ensure there is a number format
  --
  hr_utility.set_location(l_proc,7);
  l_segment4 := p_segment4;
  --
  hr_dbchkfmt.is_db_format
    (p_value    => l_segment4,
     p_arg_name => 'segment4',
     p_format   => 'I');
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_us_segment4;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_us_segment5 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segment5 attribute for US legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment5  -> Bank Name
--
-- Post Success:
--   If the p_segment5 is valid then processing continues.
--
-- Post Failure:
--   If any of the following cases are true then an application error will
--   be raised:
--   a) p_segment5 cannot be NULL.
--   b) p_segment5 cannot exceed 60 in length.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment5
            (p_segment5 in pay_external_accounts.segment5%type) is
--
  l_proc        varchar2(72) := g_package||'chk_us_segment5';
  l_dummy	number;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that segment5 is mandatory
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'segment5',
     p_argument_value => p_segment5);
  --
  -- Ensure that the length does not exceed 60
  --
  hr_utility.set_location(l_proc,7);
  if (length(p_segment5) > 60) then
    hr_utility.set_message(801, 'HR_51463_EXA_US_BANK_NAME_LONG');
    hr_utility.set_message_token('ARG_NAME', 'p_segment5');
    hr_utility.set_message_token('ARG_VALUE', p_segment5);
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_us_segment5;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_us_segment6 >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segment6 attribute for US legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment6  -> Bank Branch
--
-- Post Success:
--   If the p_segment6 is valid then processing continues.
--
-- Post Failure:
--   If any of the following cases are true then an application error will
--   be raised:
--   a) p_segment6 cannot be NULL.
--   b) p_segment6 cannot exceed 60 in length.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment6
            (p_segment6 in pay_external_accounts.segment6%type) is
--
  l_proc        varchar2(72) := g_package||'chk_us_segment6';
  l_dummy	number;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that segment6 is mandatory
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'segment6',
     p_argument_value => p_segment6);
  --
  -- Ensure that the length does not exceed 60
  --
  hr_utility.set_location(l_proc,7);
  if (length(p_segment6) > 60) then
    hr_utility.set_message(801, 'HR_51464_EXA_US_BANK_BRAN_LONG');
    hr_utility.set_message_token('ARG_NAME', 'p_segment6');
    hr_utility.set_message_token('ARG_VALUE', p_segment6);
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_us_segment6;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_us_segment7_30 >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the segments 7..30 for US legislation.
--
-- Pre-conditions:
--   None
--
-- In Arguments:
--   p_segment7..30
--
-- Post Success:
--   If the p_segment7..30 are NULL then processing continues.
--
-- Post Failure:
--   If any of segments7..30 are NOT NULL then an aplication error will be
--   raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_us_segment7_30
            (p_segment7  in pay_external_accounts.segment7%type,
             p_segment8  in pay_external_accounts.segment8%type,
             p_segment9  in pay_external_accounts.segment9%type,
             p_segment10 in pay_external_accounts.segment10%type,
             p_segment11 in pay_external_accounts.segment11%type,
             p_segment12 in pay_external_accounts.segment12%type,
             p_segment13 in pay_external_accounts.segment13%type,
             p_segment14 in pay_external_accounts.segment14%type,
             p_segment15 in pay_external_accounts.segment15%type,
             p_segment16 in pay_external_accounts.segment16%type,
             p_segment17 in pay_external_accounts.segment17%type,
             p_segment18 in pay_external_accounts.segment18%type,
             p_segment19 in pay_external_accounts.segment19%type,
             p_segment20 in pay_external_accounts.segment20%type,
             p_segment21 in pay_external_accounts.segment21%type,
             p_segment22 in pay_external_accounts.segment22%type,
             p_segment23 in pay_external_accounts.segment23%type,
             p_segment24 in pay_external_accounts.segment24%type,
             p_segment25 in pay_external_accounts.segment25%type,
             p_segment26 in pay_external_accounts.segment26%type,
             p_segment27 in pay_external_accounts.segment27%type,
             p_segment28 in pay_external_accounts.segment28%type,
             p_segment29 in pay_external_accounts.segment29%type,
             p_segment30 in pay_external_accounts.segment30%type) is
--
  l_proc  varchar2(72) := g_package||'chk_us_segment7_30';
  l_err   exception;                           -- local error exception
  l_n     number;                              -- arg in error number (9..30)
  l_v     pay_external_accounts.segment8%type; -- arg in error value (9..30)
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_segment7  is not null then l_n:=7; l_v:=p_segment7 ;raise l_err;end if;
  if p_segment8  is not null then l_n:=8; l_v:=p_segment8 ;raise l_err;end if;
  if p_segment9  is not null then l_n:=9; l_v:=p_segment9 ;raise l_err;end if;
  if p_segment10 is not null then l_n:=10;l_v:=p_segment10;raise l_err;end if;
  if p_segment11 is not null then l_n:=11;l_v:=p_segment11;raise l_err;end if;
  if p_segment12 is not null then l_n:=12;l_v:=p_segment12;raise l_err;end if;
  if p_segment13 is not null then l_n:=13;l_v:=p_segment13;raise l_err;end if;
  if p_segment14 is not null then l_n:=14;l_v:=p_segment14;raise l_err;end if;
  if p_segment15 is not null then l_n:=15;l_v:=p_segment15;raise l_err;end if;
  if p_segment16 is not null then l_n:=16;l_v:=p_segment16;raise l_err;end if;
  if p_segment17 is not null then l_n:=17;l_v:=p_segment17;raise l_err;end if;
  if p_segment18 is not null then l_n:=18;l_v:=p_segment18;raise l_err;end if;
  if p_segment19 is not null then l_n:=19;l_v:=p_segment19;raise l_err;end if;
  if p_segment20 is not null then l_n:=20;l_v:=p_segment20;raise l_err;end if;
  if p_segment21 is not null then l_n:=21;l_v:=p_segment21;raise l_err;end if;
  if p_segment22 is not null then l_n:=22;l_v:=p_segment22;raise l_err;end if;
  if p_segment23 is not null then l_n:=23;l_v:=p_segment23;raise l_err;end if;
  if p_segment24 is not null then l_n:=24;l_v:=p_segment24;raise l_err;end if;
  if p_segment25 is not null then l_n:=25;l_v:=p_segment25;raise l_err;end if;
  if p_segment26 is not null then l_n:=26;l_v:=p_segment26;raise l_err;end if;
  if p_segment27 is not null then l_n:=27;l_v:=p_segment27;raise l_err;end if;
  if p_segment28 is not null then l_n:=28;l_v:=p_segment28;raise l_err;end if;
  if p_segment29 is not null then l_n:=29;l_v:=p_segment29;raise l_err;end if;
  if p_segment30 is not null then l_n:=30;l_v:=p_segment30;raise l_err;end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
exception
  when l_err then
    hr_utility.set_message(801, 'HR_7296_API_ARG_NOT_SUP');
    hr_utility.set_message_token('ARG_NAME', 'p_segment'||to_char(l_n));
    hr_utility.set_message_token('ARG_VALUE', l_v);
    hr_utility.raise_error;
end chk_us_segment7_30;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< kf >-------------------------------------|
-- ----------------------------------------------------------------------------
procedure kf
        (p_rec               in pay_exa_shd.g_rec_type,
         p_business_group_id in number) is
--
  l_proc             varchar2(72) := g_package||'kf';
  l_legislation_code per_business_groups.legislation_code%type;
--
  --
  -- This cursor selects the legislation_code for the business group which
  -- will be used to switch the segment validation.
  -- We are using the legislation_code in preference to the id_flex_num as
  -- the legislation_code should be static whereas we cannot guarantee that
  -- the id_flex_num is static.
  --
  cursor lcsel is
    select  pbg.legislation_code
    from    pay_legislation_rules plr,
            per_business_groups   pbg
    where   plr.rule_type         = 'E'
    and     plr.legislation_code  = pbg.legislation_code
    and     pbg.business_group_id = p_business_group_id
    and     plr.rule_mode         = to_char(p_rec.id_flex_num);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that p_rec.id_flex_num and p_business_group_id are mandatory
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'id_flex_num',
     p_argument_value => p_rec.id_flex_num);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'business_group_id',
     p_argument_value => p_business_group_id);
  --
  open lcsel;
  fetch lcsel into l_legislation_code;
  if lcsel%notfound then
    close lcsel;
    -- *** TEMP error message ***
    hr_utility.set_message(801, 'HR_7296_API_ARG_NOT_SUP');
    hr_utility.set_message_token('ARG_NAME', 'id_flex_num');
    hr_utility.set_message_token('ARG_VALUE', to_char(p_rec.id_flex_num));
    hr_utility.raise_error;
  end if;
  close lcsel;
  --
  if (l_legislation_code = 'GB') then
    --
    -- GB Bank Details
    --
    chk_gb_segment1(p_segment1 => p_rec.segment1);
    chk_gb_segment2(p_segment2 => p_rec.segment2);
    chk_gb_segment3(p_segment3 => p_rec.segment3);
    chk_gb_segment4(p_segment4 => p_rec.segment4);
    chk_gb_segment5(p_segment5 => p_rec.segment5);
    chk_gb_segment6(p_segment6 => p_rec.segment6);
    chk_gb_segment7(p_segment7 => p_rec.segment7);
    chk_gb_segment8(p_segment8 => p_rec.segment8);
    chk_gb_segment9_30(p_segment9  => p_rec.segment9,
                       p_segment10 => p_rec.segment10,
                       p_segment11 => p_rec.segment11,
                       p_segment12 => p_rec.segment12,
                       p_segment13 => p_rec.segment13,
                       p_segment14 => p_rec.segment14,
                       p_segment15 => p_rec.segment15,
                       p_segment16 => p_rec.segment16,
                       p_segment17 => p_rec.segment17,
                       p_segment18 => p_rec.segment18,
                       p_segment19 => p_rec.segment19,
                       p_segment20 => p_rec.segment20,
                       p_segment21 => p_rec.segment21,
                       p_segment22 => p_rec.segment22,
                       p_segment23 => p_rec.segment23,
                       p_segment24 => p_rec.segment24,
                       p_segment25 => p_rec.segment25,
                       p_segment26 => p_rec.segment26,
                       p_segment27 => p_rec.segment27,
                       p_segment28 => p_rec.segment28,
                       p_segment29 => p_rec.segment29,
                       p_segment30 => p_rec.segment30);
  --
  elsif (l_legislation_code = 'US') then
    --
    -- US Bank Details
    --
    chk_us_segment1(p_segment1 => p_rec.segment1);
    chk_us_segment2(p_segment2 => p_rec.segment2);
    chk_us_segment3(p_segment3 => p_rec.segment3);
    chk_us_segment4(p_segment4 => p_rec.segment4);
    chk_us_segment5(p_segment5 => p_rec.segment5);
    chk_us_segment6(p_segment6 => p_rec.segment6);
    chk_us_segment7_30(p_segment7  => p_rec.segment7,
                       p_segment8  => p_rec.segment8,
                       p_segment9  => p_rec.segment9,
                       p_segment10 => p_rec.segment10,
                       p_segment11 => p_rec.segment11,
                       p_segment12 => p_rec.segment12,
                       p_segment13 => p_rec.segment13,
                       p_segment14 => p_rec.segment14,
                       p_segment15 => p_rec.segment15,
                       p_segment16 => p_rec.segment16,
                       p_segment17 => p_rec.segment17,
                       p_segment18 => p_rec.segment18,
                       p_segment19 => p_rec.segment19,
                       p_segment20 => p_rec.segment20,
                       p_segment21 => p_rec.segment21,
                       p_segment22 => p_rec.segment22,
                       p_segment23 => p_rec.segment23,
                       p_segment24 => p_rec.segment24,
                       p_segment25 => p_rec.segment25,
                       p_segment26 => p_rec.segment26,
                       p_segment27 => p_rec.segment27,
                       p_segment28 => p_rec.segment28,
                       p_segment29 => p_rec.segment29,
                       p_segment30 => p_rec.segment30);

  else
    -- *** TEMP error message ***
    hr_utility.set_message(801, 'HR_7296_API_ARG_NOT_SUP');
    hr_utility.set_message_token('ARG_NAME', 'id_flex_num');
    hr_utility.set_message_token('ARG_VALUE', to_char(p_rec.id_flex_num));
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end kf;
--
end pay_exa_flex;

/
