--------------------------------------------------------
--  DDL for Package Body PAY_GRR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GRR_BUS" as
/* $Header: pygrrrhi.pkb 115.4 2002/12/10 09:48:17 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_grr_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code  varchar2(150) default null;
g_grade_rule_id     number        default null;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_grade_or_spinal_point_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   Validates that a value for grade_or_spinal_point_id must be entered
--
--   Validates that if the grade rule is specific to a given grade, the
--   relevant grade exists and is date effective on per_grades
--
--   Validates that if the grade rule is specific to a given spinal point, the
--   relevant spinal point exists on per_spinal_points
--
--   Validates that the value for grade_or_spinal_point_id is unique for the
--   combination of business_group_id, rate_id, rate_type and
--   grade_or_spinal_point_id between the start and end effective dates for
--   the grade rule record
--
--   Validates that the business group of the grade rule is the same as the
--   business group of the spinal point.
--
--   Validates that the business group of the grade rule is the same as the
--   business group of the grade.
--
--
--  Pre-conditions:
--   A valid business group
--
--  In Arguments:
--   p_grade_rule_id
--   p_grade_or_spinal_point_id
--   p_effective_start_date
--   p_effective_end_date
--   p_effective_date
--   p_business_group_id
--   p_rate_type
--   p_rate_id
--
--  Post Success:
--   If the grade_or_spinal_point_id refers to a grade and the grade exists
--   and is date effective on per_grades then processing continues
--
--   If the grade_or_spinal_point_id refers to spinal point and the spinal
--   point exists on per_spinal_points then processing continues
--
--   If the combination of grade_or_spinal_point_id, business_group_id,
--   rate_id and rate_type is unique on pay_grade_rules_f between the start
--   and end effective dates then processing continues
--
--   If the business group of the grade rule is the same as the
--   business group of the spinal point.
--
--   If the business group of the grade rule is the same as the
--   business group of the grade.
--
--
--  Post Failure:
--   If the grade_or_spinal_point_id refers to a grade and the grade does
--   not exist or is not date effective on per_grades then an application
--   error is raised and processing is terminated
--
--   If the business group of the grade rule is not the same as the
--   business group of the spinal point.
--
--   If the business group of the grade rule is not the same as the
--   business group of the grade.
--
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_grade_or_spinal_point_id
  (p_grade_rule_id            in pay_grade_rules_f.grade_rule_id%TYPE
  ,p_grade_or_spinal_point_id in pay_grade_rules_f.grade_or_spinal_point_id%TYPE
  ,p_effective_start_date     in date
  ,p_effective_end_date       in date
  ,p_business_group_id        in pay_grade_rules_f.business_group_id%TYPE
  ,p_rate_type                in pay_grade_rules_f.rate_type%TYPE
  ,p_rate_id                  in pay_grade_rules_f.rate_id%TYPE
  ,p_effective_date           in date
  ) is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_grade_or_spinal_point_id';
   l_business_group_id  pay_grade_rules_f.business_group_id%type;
--
   cursor csr_valid_grade_id is
     select   business_group_id
     from     per_grades pg
     where    pg.grade_id = p_grade_or_spinal_point_id
     and      p_effective_start_date between pg.date_from
                                     and nvl(pg.date_to, hr_api.g_eot)
     and      p_effective_end_date <= nvl(pg.date_to, hr_api.g_eot);
--
   cursor csr_valid_spinal_point is
     select   business_group_id
     from     per_spinal_points psp
     where    psp.spinal_point_id = p_grade_or_spinal_point_id;
--
   cursor csr_unique_rate is
     select   null
     from     pay_grade_rules_f pgr
     where    pgr.rate_id = p_rate_id
     and      pgr.business_group_id = p_business_group_id
     and      pgr.rate_type = p_rate_type
     and      pgr.grade_or_spinal_point_id = p_grade_or_spinal_point_id
     and      p_effective_date between pgr.effective_start_date
                                   and pgr.effective_end_date;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'grade_or_spinal_point_id'
    ,p_argument_value => p_grade_or_spinal_point_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'rate_id'
    ,p_argument_value => p_rate_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'rate_type'
    ,p_argument_value => p_rate_type
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_start_date'
    ,p_argument_value => p_effective_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_end_date'
    ,p_argument_value => p_effective_end_date
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check that if the rule is for a grade, this grade
  -- is a valid grade on per_grades, otherwise the rule
  -- must be defined for a spinal point in which case
  -- the spinal point id should exist on per_spinal_points
  --
  if p_rate_type = 'G' then
    hr_utility.set_location(l_proc, 30);
    open csr_valid_grade_id;
    fetch csr_valid_grade_id into l_business_group_id;
    if csr_valid_grade_id%notfound then
      close csr_valid_grade_id;
      hr_utility.set_message(801, 'HR_7311_GRR_INVALID_GRADE');
      hr_utility.raise_error;
    end if;
    close csr_valid_grade_id;
    hr_utility.set_location(l_proc, 35);
      --
      -- Check that the grade is in the same business group as the
      -- grade rule
      --
      If p_business_group_id <> l_business_group_id then
        --
        hr_utility.set_message(801, 'HR_51299_GRR_INV_G_BG ');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 36);
  elsif p_rate_type = 'SP' then
    hr_utility.set_location(l_proc, 40);
    open csr_valid_spinal_point;
    fetch csr_valid_spinal_point into l_business_group_id;
    if csr_valid_spinal_point%notfound then
      close csr_valid_spinal_point;
      hr_utility.set_message(801, 'HR_7312_GRR_INVALID_SPNL_POINT');
      hr_utility.raise_error;
    end if;
    close csr_valid_spinal_point;
    hr_utility.set_location(l_proc, 50);
      --
      -- Check that the spinal point is in the same business group as the
      -- grade rule
      --
      If p_business_group_id <> l_business_group_id then
        --
        hr_utility.set_message(801, 'HR_51298_GRR_INV_SP_BG ');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 60);
  end if;
  --
  hr_utility.set_location(l_proc, 3);
  --
  -- Checks that the combination of p_grade_or_spinal_point_id,
  -- p_rate_id, p_rate_type, p_business_group_id is unique
  -- betwen effective_start_date and effective_end_date on
  -- per_valid_grades
  --
  open csr_unique_rate;
  fetch csr_unique_rate into l_exists;
  if csr_unique_rate%found then
    close csr_unique_rate;
    hr_utility.set_message(801, 'HR_7313_GRR_GRADE_RULE_COMB_EX');
    hr_utility.raise_error;
  end if;
  close csr_unique_rate;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
end chk_grade_or_spinal_point_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_rate_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   Validates that the rate id exists in the table pay_rates
--
--   Validates that the business group of the grade rule is the same as
--   the business group of the rate.
--
--  Pre-conditions:
--   A valid business group
--
--  In Arguments:
--   p_rate_id
--   p_business_group_id
--
--  Post Success:
--   If the rate_id refers to a valid rate on the table pay_rates
--   then processing continues
--
--   If the business group of the grade rule is the same as the
--   business group of the rate.
--
--  Post Failure:
--   If the rate_id does not exist on the table pay_rates then an
--   application error is raised and processing is terminated
--
--   If the business group of the grade rule is not the same as the
--   business group of the rate.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_rate_id
  (p_rate_id   in pay_grade_rules_f.rate_id%TYPE,
   p_business_group_id pay_grade_rules_f.business_group_id%TYPE
  )
  is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_rate_id';
   l_business_group_id  pay_grade_rules_f.business_group_id%TYPE;
--
  cursor csr_rate_exists is
    select   business_group_id
    from     pay_rates pr
    where    pr.rate_id = p_rate_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'rate_id'
    ,p_argument_value => p_rate_id
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check that p_rate_id exists on table
  -- pay_rates
  --
  open csr_rate_exists;
  fetch csr_rate_exists into l_business_group_id;
  if csr_rate_exists%notfound then
    close csr_rate_exists;
    hr_utility.set_message(801, 'HR_7314_GRR_NON_EXIST_PAY_RATE');
    hr_utility.raise_error;
  end if;
  close csr_rate_exists;
      hr_utility.set_location(l_proc, 25);
      --
      -- Check that the rate is in the same business group as the
      -- grade rule
      --
      If p_business_group_id <> l_business_group_id then
        --
        hr_utility.set_message(801, 'HR_51301_GRR_INV_RA_BG ');
        hr_utility.raise_error;
        --
      end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
end chk_rate_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_rate_type >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   Validates that the value entered for rate_type exists on
--   the table hr_lookups
--
--   Validates that the combination of the rate type and the
--   rate id exists on the table pay_rates
--
--  Pre-conditions:
--   A valid value for p_rate_id
--
--  In Arguments:
--   p_rate_id
--   p_rate_type
--
--  Post Success:
--   If the rate type exists on hr_lookups then processing
--   continues
--
--   If the combination of the rate type and the rate id exists
--   on the table pay_rates then processing continues
--
--  Post Failure:
--   If the rate type does not exist on hr_lookups, a constraint
--   error is raised and processing is terminated
--
--   If the combination of rate id and rate type does not exist
--   on the table pay_rates then an application error is raised
--   and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_rate_type
  (p_rate_id    in pay_grade_rules.rate_id%TYPE
  ,p_rate_type  in pay_grade_rules.rate_type%TYPE)
  is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72) :=  g_package||'chk_rate_type';
--
   cursor csr_valid_comb is
     select   null
     from     pay_rates pr
     where    pr.rate_id = p_rate_id
     and      pr.rate_type = p_rate_type;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_rate_id'
    ,p_argument_value => p_rate_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_rate_type'
    ,p_argument_value => p_rate_type
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Check rate type in 'G' or 'SP'
  --
  if p_rate_type not in ('G','SP') then
    pay_grr_shd.constraint_error(
                p_constraint_name => 'PAY_GRL_RATE_TYPE_CHK');
  end if;
  --
  hr_utility.set_location(l_proc, 3);
  --
  -- Check that the combination of rate id and
  -- rate_type is valid on the table pay_rates
  --
  open csr_valid_comb;
  fetch csr_valid_comb into l_exists;
  if csr_valid_comb%notfound then
    close csr_valid_comb;
    hr_utility.set_message(801, 'HR_7315_GRR_INVA_PAY_RATE_COMB');
    hr_utility.raise_error;
  end if;
  close csr_valid_comb;
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
end chk_rate_type;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_maximum >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   Validates that if the grade rule is defined for a grade, the value
--   entered for the column Maximum must be greater than or equal to the value
--   for Minimum (if not null) and greater than or equal to the value for
--   Value (if not null)
--
--  Pre-conditions:
--   The grade (grade_or_spinal_point_id) must be valid on per_grades
--
--  In Arguments:
--   p_grade_rule_id
--   p_rate_type
--   p_rate_id
--   p_maximum
--   p_minimum
--   p_value
--   p_effective_date
--   p_object_version_number
--
--  Post Success:
--   If the value for Maximum is >= Minimum and >= Value then
--   processing continues
--
--  Post Failure:
--
--   If the value for Maximum is < Minimum and/or < Value then an
--   application error is raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_maximum
  (p_grade_rule_id             in pay_grade_rules_f.grade_rule_id%TYPE
  ,p_rate_id                   in pay_grade_rules_f.rate_id%TYPE
  ,p_rate_type                 in pay_grade_rules_f.rate_type%TYPE
  ,p_maximum                   in pay_grade_rules_f.maximum%TYPE
  ,p_minimum                   in pay_grade_rules_f.minimum%TYPE
  ,p_value                     in pay_grade_rules_f.value%TYPE
  ,p_effective_date            in date
  ,p_object_version_number     in pay_grade_rules_f.object_version_number%TYPE)
  is
  --
   l_proc                varchar2(72)  :=  g_package||'chk_maximum';
   l_api_updating        boolean;
   l_value               pay_grade_rules_f.value%TYPE;
   l_maximum             pay_grade_rules_f.maximum%TYPE;
   l_dummy_return_value  pay_grade_rules_f.value%TYPE;
   l_min_max_status      varchar2(30);
   l_uom                 pay_rates.rate_uom%TYPE;
   l_currency_code       per_business_groups.currency_code%TYPE;
  --
  cursor csel1 is
    select pr.rate_uom
    ,      pbg.currency_code
    from   per_business_groups   pbg
    ,      pay_rates             pr
    where  pr.rate_id            = p_rate_id
    and    pbg.business_group_id = pr.business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- p_value and p_maximum reassigned to l_value
  -- and l_maximum for use within the checkformat
  -- procedure call as in/out arguments
  --
  l_value := p_value;
  l_maximum := p_maximum;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'rate_type'
    ,p_argument_value => p_rate_type
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'rate_id'
    ,p_argument_value => p_rate_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for address type has changed
  --
  l_api_updating := pay_grr_shd.api_updating
         (p_grade_rule_id          => p_grade_rule_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(pay_grr_shd.g_old_rec.maximum, hr_api.g_varchar2) <>
       nvl(l_maximum, hr_api.g_varchar2)) or
      (NOT l_api_updating)) then
   hr_utility.set_location(l_proc, 2);
   --
   if p_rate_type = 'G' then
     open csel1;
     fetch csel1 into l_uom, l_currency_code;
     if csel1%notfound then
       close csel1;
       --
       -- If no currency exists for a particular
       -- business group then flag an error
       --
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE', l_proc);
       hr_utility.set_message_token('STEP', '5');
     end if;
     close csel1;
     --
     -- Check 1 : maximum > minimum
     --
     hr_chkfmt.checkformat
       (value   => l_maximum,
        format  => l_uom,
        output  => l_dummy_return_value,
        minimum => p_minimum,
        maximum => l_maximum,
        nullok  => 'Y',
        rgeflg  => l_min_max_status,
        curcode => l_currency_code);
     --
     if (l_min_max_status = 'F') then
       hr_utility.set_message(801, 'HR_7316_GRR_INVALID_VALUE');
       hr_utility.raise_error;
     end if;
     --
     -- Check 2 : value < maximum
     --
     hr_chkfmt.checkformat
       (value   => l_value,
        format  => l_uom,
        output  => l_dummy_return_value,
        minimum => '',
        maximum => l_maximum,
        nullok  => 'Y',
        rgeflg  => l_min_max_status,
        curcode => l_currency_code);
     --
     if (l_min_max_status = 'F') then
       hr_utility.set_message(801, 'HR_7316_GRR_INVALID_VALUE');
       hr_utility.raise_error;
     end if;
   --
   -- 40.2 change start.
   --
   elsif p_rate_type = 'SP' then
     if l_maximum is not null then
       hr_utility.set_message(801, 'HR_7851_GRR_INVALID_SP_VAL');
       hr_utility.raise_error;
     end if;
   --
   -- 40.2 change end.
   --
   end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end ;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_mid_value >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   Validates that if the grade rule is defined for a grade, the value
--   entered for the column Mid Value must be greater or equal to the value
--   for Minimum (if not null) and less than or equal to the value for
--   Maximum (if not null).
--
--  Pre-conditions:
--   The grade (grade_or_spinal_point_id) must be valid on per_grades
--
--  In Arguments:
--   p_grade_rule_id
--   p_rate_type
--   p_rate_id
--   p_mid_value
--   p_maximum
--   p_minimum
--   p_effective_date
--   p_object_version_number
--
--  Post Success:
--   If the value for Mid Value is >= Minimum and <= Maximum then
--   processing continues
--
--  Post Failure:
--
--   If the value for Maximum is < Minimum and/or > Maximum then
--   an application error is raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_mid_value
  (p_grade_rule_id             in pay_grade_rules_f.grade_rule_id%TYPE
  ,p_rate_type                 in pay_grade_rules_f.rate_type%TYPE
  ,p_rate_id                   in pay_grade_rules_f.rate_id%TYPE
  ,p_mid_value                 in pay_grade_rules_f.mid_value%TYPE
  ,p_maximum                   in pay_grade_rules_f.maximum%TYPE
  ,p_minimum                   in pay_grade_rules_f.minimum%TYPE
  ,p_effective_date            in date
  ,p_object_version_number     in pay_grade_rules_f.object_version_number%TYPE)
  is
  --
   l_proc                varchar2(72)  :=  g_package||'chk_mid_value';
   l_api_updating        boolean;
   l_mid_value           pay_grade_rules_f.mid_value%TYPE;
   l_dummy_return_value  pay_grade_rules_f.value%TYPE;
   l_min_max_status      varchar2(30);
   l_uom                 pay_rates.rate_uom%TYPE;
   l_currency_code       per_business_groups.currency_code%TYPE;
  --
  cursor csel1 is
    select pr.rate_uom
    ,      pbg.currency_code
    from   per_business_groups   pbg
    ,      pay_rates             pr
    where  pr.rate_id            = p_rate_id
    and    pbg.business_group_id = pr.business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- p_mid_value reassigned to l_mid_value for use within
  -- the checkformat procedure call as in/out argument
  --
  l_mid_value := p_mid_value;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'rate_type'
    ,p_argument_value => p_rate_type
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'rate_id'
    ,p_argument_value => p_rate_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for address type has changed
  --
  l_api_updating := pay_grr_shd.api_updating
         (p_grade_rule_id          => p_grade_rule_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(pay_grr_shd.g_old_rec.mid_value, hr_api.g_varchar2) <>
       nvl(l_mid_value, hr_api.g_varchar2)) or
      (NOT l_api_updating)) then
   hr_utility.set_location(l_proc, 2);
   --
   if p_rate_type = 'G' then
      open csel1;
     fetch csel1 into l_uom, l_currency_code;
     if csel1%notfound then
       close csel1;
       hr_utility.set_message(801, 'HR_7316_GRR_INVALID_VALUE');
       hr_utility.raise_error;
     end if;
     close csel1;
     --
     -- Check 1 : minimum < mid_value
     --
     hr_chkfmt.checkformat
       (value   => l_mid_value,
        format  => l_uom,
        output  => l_dummy_return_value,
        minimum => p_minimum,
        maximum => '',
        nullok  => 'Y',
        rgeflg  => l_min_max_status,
        curcode => l_currency_code);
     --
     if (l_min_max_status = 'F') then
       hr_utility.set_message(801, 'HR_7316_GRR_INVALID_VALUE');
       hr_utility.raise_error;
     end if;
     --
     -- Check 2 : mid_value < maximum
     ---
     hr_chkfmt.checkformat
       (value   => l_mid_value,
        format  => l_uom,
        output  => l_dummy_return_value,
        minimum => '',
        maximum => p_maximum,
        nullok  => 'Y',
        rgeflg  => l_min_max_status,
        curcode => l_currency_code);
     --
     if (l_min_max_status = 'F') then
       hr_utility.set_message(801, 'HR_7316_GRR_INVALID_VALUE');
       hr_utility.raise_error;
     end if;
     --
     -- Added check for not null value of mid_value for rate type
     -- of SP - AForte 14/6/96
     elsif p_rate_type = 'SP' then
     if l_mid_value is not null then
       hr_utility.set_message(801, 'HR_7851_GRR_INVALID_SP_VAL');
       hr_utility.raise_error;
     end if;
   end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end ;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_minimum >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   Validates that if the grade rule is defined for a grade, the value
--   entered for the column Minimum must be less than or equal to the value
--   for Maximum (if not null) and less than or equal to the value for
--   Value (if not null)
--
--  Pre-conditions:
--   The grade (grade_or_spinal_point_id) must be valid on per_grades
--
--  In Arguments:
--   p_grade_rule_id
--   p_rate_type
--   p_rate_id
--   p_maximum
--   p_minimum
--   p_value
--   p_effective_date
--   p_object_version_number
--
--  Post Success:
--   If the value for Minimum is <= Maximum and Value then
--   processing continues
--
--  Post Failure:
--
--   If the value for Minimum is > Maximum and/or Value then an
--   an application error is raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_minimum
  (p_grade_rule_id             in pay_grade_rules_f.grade_rule_id%TYPE
  ,p_rate_type                 in pay_grade_rules_f.rate_type%TYPE
  ,p_rate_id                   in pay_grade_rules_f.rate_id%TYPE
  ,p_maximum                   in pay_grade_rules_f.maximum%TYPE
  ,p_minimum                   in pay_grade_rules_f.minimum%TYPE
  ,p_value                     in pay_grade_rules_f.value%TYPE
  ,p_effective_date            in date
  ,p_object_version_number     in pay_grade_rules_f.object_version_number%TYPE)
  is
  --
   l_proc                varchar2(72)  :=  g_package||'chk_minimum';
   l_api_updating        boolean;
   l_minimum             pay_grade_rules_f.minimum%TYPE;
   l_value               pay_grade_rules_f.value%TYPE;
   l_dummy_return_value  pay_grade_rules_f.value%TYPE;
   l_min_max_status      varchar2(30);
   l_uom                 pay_rates.rate_uom%TYPE;
   l_currency_code       per_business_groups.currency_code%TYPE;
  --
  cursor csel1 is
    select pr.rate_uom
    ,      pbg.currency_code
    from   per_business_groups   pbg
    ,      pay_rates             pr
    where  pr.rate_id            = p_rate_id
    and    pbg.business_group_id = pr.business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- p_minimum and p_value reassigned to l_minimum
  -- and l_value for use within the checkformat
  -- procedure call as in/out arguments
  --
  l_minimum := p_minimum;
  l_value   := p_value;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'rate_type'
    ,p_argument_value => p_rate_type
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'rate_id'
    ,p_argument_value => p_rate_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for address type has changed
  --
  l_api_updating := pay_grr_shd.api_updating
         (p_grade_rule_id          => p_grade_rule_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(pay_grr_shd.g_old_rec.minimum, hr_api.g_varchar2) <>
       nvl(l_minimum, hr_api.g_varchar2)) or
      (NOT l_api_updating)) then
   hr_utility.set_location(l_proc, 2);
   --
   if p_rate_type = 'G' then
     open csel1;
     fetch csel1 into l_uom, l_currency_code;
     if csel1%notfound then
       close csel1;
       --
       -- If no currency exists for a particular
       -- business group then flag an error
       --
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE', l_proc);
       hr_utility.set_message_token('STEP', '5');
     end if;
     close csel1;
     --
     -- Check 1 : minimum < maximum
     --
     hr_chkfmt.checkformat
       (value   => l_minimum,
        format  => l_uom,
        output  => l_dummy_return_value,
        minimum => '',
        maximum => p_maximum,
        nullok  => 'Y',
        rgeflg  => l_min_max_status,
        curcode => l_currency_code);
     --
     if (l_min_max_status = 'F') then
       hr_utility.set_message(801, 'HR_7316_GRR_INVALID_VALUE');
       hr_utility.raise_error;
     end if;
     --
     -- Check 2 : value > minimum
     --
     hr_chkfmt.checkformat
       (value   => l_value,
        format  => l_uom,
        output  => l_dummy_return_value,
        minimum => l_minimum,
        maximum => '',
        nullok  => 'Y',
        rgeflg  => l_min_max_status,
        curcode => l_currency_code);
     --
     if (l_min_max_status = 'F') then
       hr_utility.set_message(801, 'HR_7316_GRR_INVALID_VALUE');
       hr_utility.raise_error;
     end if;
     --
     -- Added check for not null value of minimum for rate type
     -- of SP - AForte 14/6/96

     elsif p_rate_type = 'SP' then
     if l_minimum is not null then
       hr_utility.set_message(801, 'HR_7851_GRR_INVALID_SP_VAL');
       hr_utility.raise_error;
     end if;
   end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end ;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_sequence >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   Validates that the value for Sequence is consistent with the Grade or
--   Spinal Point sequence for which the grade rule is defined
--
--  Pre-conditions:
--   None
--
--  In Arguments:
--   p_sequence
--   p_grade_or_spinal_point_id
--   p_business_group_id
--   p_rate_id
--   p_rate_type
--   p_effective_start_date
--   p_effective_end_date
--
--  Post Success:
--   If the value for sequence corresponds to the value defined for the
--   Grade or Spinal Point sequence on the table per_grades or
--   per_spinal_points then processing continues
--
--  Post Failure:
--   If the value for sequence does not correspond to the associated value
--   for Sequence for the Grade or Spinal Point defined on per_grades or
--   per_spinal_points then an application error is raised and
--   processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_sequence
  (p_grade_or_spinal_point_id in pay_grade_rules_f.grade_or_spinal_point_id%TYPE
  ,p_sequence                 in pay_grade_rules_f.sequence%TYPE
  ,p_business_group_id        in pay_grade_rules_f.business_group_id%TYPE
  ,p_rate_id                  in pay_grade_rules_f.rate_id%TYPE
  ,p_rate_type                in pay_grade_rules_f.rate_type%TYPE
  ,p_effective_start_date     in date
  ,p_effective_end_date       in date)
  is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_sequence';
--
   cursor csr_valid_grade_seq is
     select    null
     from      per_grades pg
     where     pg.grade_id = p_grade_or_spinal_point_id
     and       pg.sequence = p_sequence
     and       p_effective_start_date between pg.date_from
                                          and nvl(pg.date_to, hr_api.g_eot)
     and       p_effective_end_date <= nvl(pg.date_to, hr_api.g_eot);
--
   cursor csr_valid_sp_seq is
     select    null
     from      per_spinal_points psp
     where     psp.spinal_point_id = p_grade_or_spinal_point_id
     and       psp.sequence = p_sequence;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'grade_or_spinal_point_id'
    ,p_argument_value => p_grade_or_spinal_point_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'rate_id'
    ,p_argument_value => p_rate_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'rate_type'
    ,p_argument_value => p_rate_type
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_start_date'
    ,p_argument_value => p_effective_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_end_date'
    ,p_argument_value => p_effective_end_date
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that combination of Sequence, Business Group,
  -- Rate ID and Rate Type is unique on pay_grade_rules_f
  --
  if p_sequence is not null then
    --
    -- Check that value for Sequence is valid for the grade
    -- on per_grades
    --
    if p_rate_type = 'G' then
      open csr_valid_grade_seq;
      fetch csr_valid_grade_seq into l_exists;
      if csr_valid_grade_seq%notfound then
        close csr_valid_grade_seq;
        hr_utility.set_message(801, 'HR_7318_GRR_INV_GRADE_SEQUENCE');
        hr_utility.raise_error;
      end if;
      close csr_valid_grade_seq;
    elsif p_rate_type = 'SP' then
      open csr_valid_sp_seq;
      fetch csr_valid_sp_seq into l_exists;
      if csr_valid_sp_seq%notfound then
        close csr_valid_sp_seq;
        hr_utility.set_message(801, 'HR_7319_GRR_INV_SPIN_POINT_SEQ');
        hr_utility.raise_error;
      end if;
      close csr_valid_sp_seq;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end chk_sequence;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_value >---------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   Validates that if the grade rule is defined for a grade, the value
--   entered for the column Value must be greater than or equal to the value
--   for Minimum (if not null) and less than or equal to the value for
--   Maximum (if not null)
--
--  Pre-conditions:
--   The grade (grade_or_spinal_point_id) must be valid on per_grades
--
--  In Arguments:
--   p_grade_rule_id
--   p_rate_type
--   p_maximum
--   p_minimum
--   p_value
--   p_effective_date
--   p_object_version_number
--
--  Post Success:
--   If the value for Value is >= Minimum and <= Maximum then
--   processing continues
--
--  Post Failure:
--
--   If the value for Value is < Minimum and/or > Maximum then an
--   application error is raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_value
  (p_grade_rule_id             in pay_grade_rules_f.grade_rule_id%TYPE
  ,p_rate_type                 in pay_grade_rules_f.rate_type%TYPE
  ,p_rate_id                   in pay_grade_rules_f.rate_id%TYPE
  ,p_maximum                   in pay_grade_rules_f.maximum%TYPE
  ,p_minimum                   in pay_grade_rules_f.minimum%TYPE
  ,p_value                     in pay_grade_rules_f.value%TYPE
  ,p_effective_date            in date
  ,p_object_version_number     in pay_grade_rules_f.object_version_number%TYPE)
  is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_value';
   l_api_updating   boolean;
   l_value               pay_grade_rules_f.value%TYPE;
   l_dummy_return_value  pay_grade_rules_f.value%TYPE;
   l_min_max_status      varchar2(30);
   l_uom                 pay_rates.rate_uom%TYPE;
   l_currency_code       per_business_groups.currency_code%TYPE;
  --
  cursor csel1 is
    select pr.rate_uom
    ,      pbg.currency_code
    from   per_business_groups   pbg
    ,      pay_rates             pr
    where  pr.rate_id            = p_rate_id
    and    pbg.business_group_id = pr.business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- p_value reassigned to l_value for use within
  -- the checkformat procedure call as in/out argument
  --
  l_value := p_value;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'rate_type'
    ,p_argument_value => p_rate_type
    );
  --
   hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'rate_id'
    ,p_argument_value => p_rate_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for address type has changed
  --
  l_api_updating := pay_grr_shd.api_updating
         (p_grade_rule_id          => p_grade_rule_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(pay_grr_shd.g_old_rec.value, hr_api.g_varchar2) <>
       nvl(l_value, hr_api.g_varchar2)) or
      (NOT l_api_updating)) then
   hr_utility.set_location(l_proc, 2);
   --
   -- Check that value for Value is >= Minimum and <= Maximum
   -- (if Minimum, Maximum NOT NULL)
   --
   if p_rate_type = 'G' then
     open csel1;
     fetch csel1 into l_uom, l_currency_code;
     if csel1%notfound then
       close csel1;
       --
       -- If no currency exists for a particular
       -- business group then flag an error
       --
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE', l_proc);
       hr_utility.set_message_token('STEP', '5');
     end if;
     close csel1;
     --
     -- Check 1 : value > minimum
     --
     hr_chkfmt.checkformat
       (value   => l_value,
        format  => l_uom,
        output  => l_dummy_return_value,
        minimum => p_minimum,
        maximum => '',
        nullok  => 'Y',
        rgeflg  => l_min_max_status,
        curcode => l_currency_code);
     --
     if (l_min_max_status = 'F') then
       hr_utility.set_message(801, 'HR_7316_GRR_INVALID_VALUE');
       hr_utility.raise_error;
     end if;
     --
     -- Check 2 : value < maximum
     --
     hr_chkfmt.checkformat
       (value   => l_value,
        format  => l_uom,
        output  => l_dummy_return_value,
        minimum => '',
        maximum => p_maximum,
        nullok  => 'Y',
        rgeflg  => l_min_max_status,
        curcode => l_currency_code);
     --
     if (l_min_max_status = 'F') then
       hr_utility.set_message(801, 'HR_7316_GRR_INVALID_VALUE');
       hr_utility.raise_error;
     end if;
   end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end ;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updatetable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   (business_group_id, grade_or_spinal_point_id, rate_id, rate_type or
--   sequence) have been altered.
--
-- Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure check_non_updateable_args(p_rec in pay_grr_shd.g_rec_type
                                   ,p_effective_date in date) is
--
  l_proc     varchar2(72) := g_package||'check_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Only proceed with validation if a row exists for
-- the current record in the HR Schema
--
  if not pay_grr_shd.api_updating
                (p_grade_rule_id          => p_rec.grade_rule_id
                ,p_object_version_number  => p_rec.object_version_number
                ,p_effective_date         => p_effective_date
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_grr_shd.g_old_rec.business_group_id, hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 7);
  --
  if p_rec.grade_rule_id <> pay_grr_shd.g_old_rec.grade_rule_id then
     l_argument := 'grade_rule_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 8);
  --
  if nvl(p_rec.grade_or_spinal_point_id, hr_api.g_number) <>
     nvl(pay_grr_shd.g_old_rec.grade_or_spinal_point_id, hr_api.g_number) then
     l_argument := 'grade_or_spinal_point_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 9);
  --
  if nvl(p_rec.rate_id, hr_api.g_number) <>
     nvl(pay_grr_shd.g_old_rec.rate_id, hr_api.g_number) then
     l_argument := 'rate_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 10);
  --
  if nvl(p_rec.sequence, hr_api.g_number) <>
     nvl(pay_grr_shd.g_old_rec.sequence, hr_api.g_number) then
     l_argument := 'sequence';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 11);
  --
  if nvl(p_rec.rate_type, hr_api.g_varchar2) <>
     nvl(pay_grr_shd.g_old_rec.rate_type, hr_api.g_varchar2) then
     l_argument := 'rate_type';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 12);
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 12);
end check_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Pre Conditions:
--   This procedure is called from the update_validate.
--
-- In Arguments:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Table Handler USe Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
            (
	     p_datetrack_mode		     in varchar2,
             p_validation_start_date	     in date,
	     p_validation_end_date	     in date) Is
--
  l_proc	    varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name	    all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack update mode is valid
  --
  If (dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode)) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7216_DT_UPD_INTEGRITY_ERR');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Pre Conditions:
--   This procedure is called from the delete_validate.
--
-- In Arguments:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Table Handler USe Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
            (p_grade_rule_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'grade_rule_id',
       p_argument_value => p_grade_rule_id);
    --
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in pay_grr_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- Validate business group id
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_BUSINESS_GROUP_ID / a,c
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Validate grade or spinal point id
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_GRADE_OR_SPINAL_POINT_ID / a,b,c,d
  --
  chk_grade_or_spinal_point_id
    (p_grade_rule_id             => p_rec.grade_rule_id
    ,p_grade_or_spinal_point_id  => p_rec.grade_or_spinal_point_id
    ,p_effective_start_date      => p_validation_start_date
    ,p_effective_end_date        => p_validation_end_date
    ,p_effective_date            => p_effective_date
    ,p_business_group_id         => p_rec.business_group_id
    ,p_rate_type                 => p_rec.rate_type
    ,p_rate_id                   => p_rec.rate_id
    );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Validate rate id
  --
  chk_rate_id
    (p_rate_id  => p_rec.rate_id,
     p_business_group_id => p_rec.business_group_id
    );
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Validate rate type
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_RATE_TYPE / a,b,c
  --
  chk_rate_type
    (p_rate_id    => p_rec.rate_id
    ,p_rate_type  => p_rec.rate_type
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validate maximum
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_MAXIMUM / a,b
  --
  chk_maximum
    (p_grade_rule_id          => p_rec.grade_rule_id
    ,p_rate_type              => p_rec.rate_type
    ,p_rate_id                => p_rec.rate_id
    ,p_maximum                => p_rec.maximum
    ,p_minimum                => p_rec.minimum
    ,p_value                  => p_rec.value
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 11);
  --
  -- Validate mid value
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_MID_VALUE / a,b
  --
  chk_mid_value
    (p_grade_rule_id          => p_rec.grade_rule_id
    ,p_rate_type              => p_rec.rate_type
    ,p_rate_id                => p_rec.rate_id
    ,p_mid_value              => p_rec.mid_value
    ,p_maximum                => p_rec.maximum
    ,p_minimum                => p_rec.minimum
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 12);
  --
  -- Validate minimum
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_MINIMUM / a,b
  --
  chk_minimum
    (p_grade_rule_id          => p_rec.grade_rule_id
    ,p_rate_type              => p_rec.rate_type
    ,p_rate_id                => p_rec.rate_id
    ,p_maximum                => p_rec.maximum
    ,p_minimum                => p_rec.minimum
    ,p_value                  => p_rec.value
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 13);
  --
  -- Validate sequence
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_SEQUENCE / a,b,c
  --
  chk_sequence
    (p_sequence                  => p_rec.sequence
    ,p_grade_or_spinal_point_id  => p_rec.grade_or_spinal_point_id
    ,p_business_group_id         => p_rec.business_group_id
    ,p_rate_id                   => p_rec.rate_id
    ,p_rate_type                 => p_rec.rate_type
    ,p_effective_start_date      => p_validation_start_date
    ,p_effective_end_date        => p_validation_end_date
    );
  --
  hr_utility.set_location(l_proc, 14);
  --
  -- Validate value
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_VALUE / a,b
  --
  chk_value
    (p_grade_rule_id             => p_rec.grade_rule_id
    ,p_rate_type                 => p_rec.rate_type
    ,p_rate_id                   => p_rec.rate_id
    ,p_maximum                   => p_rec.maximum
    ,p_minimum                   => p_rec.minimum
    ,p_value                     => p_rec.value
    ,p_effective_date            => p_effective_date
    ,p_object_version_number     => p_rec.object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in pay_grr_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations. Mapping to the
  -- appropriate Business Rules in pergrr.bru is provided.
  --
  -- Check that the columns which cannot be updated
  -- have not changed
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_GRADE_RULE_ID / c
  -- CHK_BUSINESS_GROUP_ID / b
  -- CHK_GRADE_OR_SPINAL_POINT_ID / e
  -- CHK_RATE_ID / c
  -- CHK_RATE_TYPE / d
  --
  check_non_updateable_args(p_rec            => p_rec
                           ,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 6);
  -- Validate maximum
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_MAXIMUM / a,b
  --
  chk_maximum
    (p_grade_rule_id          => p_rec.grade_rule_id
    ,p_rate_type              => p_rec.rate_type
    ,p_rate_id                => p_rec.rate_id
    ,p_maximum                => p_rec.maximum
    ,p_minimum                => p_rec.minimum
    ,p_value                  => p_rec.value
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Validate mid value
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_MID_VALUE / a,b
  --
  chk_mid_value
    (p_grade_rule_id          => p_rec.grade_rule_id
    ,p_rate_type              => p_rec.rate_type
    ,p_rate_id                => p_rec.rate_id
    ,p_mid_value              => p_rec.mid_value
    ,p_maximum                => p_rec.maximum
    ,p_minimum                => p_rec.minimum
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Validate minimum
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_MINIMUM / a,b
  --
  chk_minimum
    (p_grade_rule_id          => p_rec.grade_rule_id
    ,p_rate_type              => p_rec.rate_type
    ,p_rate_id                => p_rec.rate_id
    ,p_maximum                => p_rec.maximum
    ,p_minimum                => p_rec.minimum
    ,p_value                  => p_rec.value
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Validate value
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_VALUE / a,b
  --
  chk_value
    (p_grade_rule_id             => p_rec.grade_rule_id
    ,p_rate_type                 => p_rec.rate_type
    ,p_rate_id                   => p_rec.rate_id
    ,p_maximum                   => p_rec.maximum
    ,p_minimum                   => p_rec.minimum
    ,p_value                     => p_rec.value
    ,p_effective_date            => p_effective_date
    ,p_object_version_number     => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in pay_grr_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_grade_rule_id		=> p_rec.grade_rule_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_grade_rule_id              in number
  ) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , pay_grade_rules_f    pgr
     where pgr.grade_rule_id         = p_grade_rule_id
       and pbg.business_group_id = pgr.business_group_id
  order by pgr.effective_start_date;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'grade_rule_id',
                             p_argument_value => p_grade_rule_id);
  --
  if nvl(g_grade_rule_id, hr_api.g_number) = p_grade_rule_id then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    if csr_leg_code%notfound then
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    end if;
    --
    -- Set the global variables so the values are
    -- available for the next call to this function
    --
    close csr_leg_code;
    g_grade_rule_id    := p_grade_rule_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
end return_legislation_code;
--
end pay_grr_bus;

/
