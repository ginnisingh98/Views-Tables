--------------------------------------------------------
--  DDL for Package Body PAY_AIF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AIF_BUS" as
/* $Header: pyaifrhi.pkb 120.2.12000000.2 2007/03/30 05:34:36 ttagawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_aif_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_action_information_id       number         default null;
--
-- The following three global variables are only to be used by
-- the return_nonpk_leg_code function.
--
g_nonpk_leg_code              varchar2(150)  default null;
g_action_context_id           number         default null;
g_action_context_type         varchar2(15)   default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_action_information_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
    from   per_business_groups       pbg
    ,      pay_action_information    aif
    ,      pay_assignment_actions    act
    ,      pay_payroll_actions       pct
    where  aif.action_information_id = p_action_information_id
    and    pbg.business_group_id     = pct.business_group_id
    and    act.payroll_action_id     = pct.payroll_action_id
    and    act.assignment_action_id  = aif.action_context_id
    and    aif.action_context_type   in ('AAP', 'AAC')
    union all
    select pbg.security_group_id
    from   per_business_groups       pbg
    ,      pay_action_information    aif
    ,      pay_payroll_actions       pct
    where  aif.action_information_id = p_action_information_id
    and    pbg.business_group_id     = pct.business_group_id
    and    pct.payroll_action_id     = aif.action_context_id
    and    aif.action_context_type   = 'PA';
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'action_information_id'
    ,p_argument_value     => p_action_information_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_action_information_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
    from   per_business_groups       pbg
    ,      pay_action_information    aif
    ,      pay_assignment_actions    act
    ,      pay_payroll_actions       pct
    where  aif.action_information_id = p_action_information_id
    and    pbg.business_group_id     = pct.business_group_id
    and    act.payroll_action_id     = pct.payroll_action_id
    and    act.assignment_action_id  = aif.action_context_id
    and    aif.action_context_type   in ('AAP', 'AAC')
    union all
    select pbg.legislation_code
    from   per_business_groups       pbg
    ,      pay_action_information    aif
    ,      pay_payroll_actions       pct
    where  aif.action_information_id = p_action_information_id
    and    pbg.business_group_id     = pct.business_group_id
    and    pct.payroll_action_id     = aif.action_context_id
    and    aif.action_context_type   = 'PA';
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'action_information_id'
    ,p_argument_value     => p_action_information_id
    );
  --
  if ( nvl(pay_aif_bus.g_action_information_id, hr_api.g_number)
       = p_action_information_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_aif_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pay_aif_bus.g_action_information_id := p_action_information_id;
    pay_aif_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |----------------------<return_nonpk_leg_code >---------------------------|
--  ---------------------------------------------------------------------------
--
Function return_nonpk_leg_code
  (p_action_context_id            in     number
  ,p_action_context_type          in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_aa_leg_code is
    select pbg.legislation_code
    from   per_business_groups       pbg
    ,      pay_assignment_actions    act
    ,      pay_payroll_actions       pct
    where  act.assignment_action_id  = p_action_context_id
    and    act.payroll_action_id     = pct.payroll_action_id
    and    pct.business_group_id     = pbg.business_group_id;
  --
  cursor csr_pa_leg_code is
    select pbg.legislation_code
    from   per_business_groups     pbg
    ,      pay_payroll_actions     pct
    where  pct.payroll_action_id   = p_action_context_id
    and    pct.business_group_id   = pbg.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_nonpk_leg_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'action_context_id'
    ,p_argument_value     => p_action_context_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'action_context_type'
    ,p_argument_value     => p_action_context_type
    );
  --
  if ((nvl(pay_aif_bus.g_action_context_id,hr_api.g_number) = p_action_context_id)
  and (nvl(pay_aif_bus.g_action_context_type,hr_api.g_varchar2) = p_action_context_type)) then
  --
    --
    -- Legislation code is for same row as cached values therefore return
    -- cached legislation code
    --
    l_legislation_code := pay_aif_bus.g_nonpk_leg_code;
  --
  else
  --
    if (p_action_context_type = 'PA') then
    --
      open csr_pa_leg_code;
      fetch csr_pa_leg_code into l_legislation_code;
      --
      if csr_pa_leg_code%notfound then
      --
        --
        -- The payroll action is invalid therefore we must error
        --
        close csr_pa_leg_code;
        fnd_message.set_name('PAY','PAY_34985_INVALID_PAY_ACTION');
        fnd_message.raise_error;
      --
      else
      --
        close csr_pa_leg_code;
      --
      end if;
    --
    elsif (p_action_context_type in ('AAC','AAP')) then
    --
      open csr_aa_leg_code;
      fetch csr_aa_leg_code into l_legislation_code;
      --
      if csr_aa_leg_code%notfound then
      --
        --
        -- The assignment action is invalid therefore we must error
        --
        close csr_aa_leg_code;
        fnd_message.set_name('PAY','PAY_34987_INVALID_ASG_ACTION');
        fnd_message.raise_error;
      --
      else
      --
        close csr_aa_leg_code;
      --
      end if;
    --
    else
    --
      --
      -- The action context type is invalid therefore we must error
      --
      fnd_message.set_name('PAY','PAY_34986_INV_ACT_CONTEXT_TYPE');
      fnd_message.raise_error;
    --
    end if;
    --
    pay_aif_bus.g_action_context_id   := p_action_context_id;
    pay_aif_bus.g_action_context_type := p_action_context_type;
    pay_aif_bus.g_nonpk_leg_code      := l_legislation_code;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
--
end return_nonpk_leg_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in pay_aif_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.action_information_id is not null)  and (
    nvl(pay_aif_shd.g_old_rec.action_information_id, hr_api.g_number) <>
    nvl(p_rec.action_information_id, hr_api.g_number)  or
    nvl(pay_aif_shd.g_old_rec.effective_date, hr_api.g_date) <>
    nvl(p_rec.effective_date, hr_api.g_date)  or
    nvl(pay_aif_shd.g_old_rec.assignment_id, hr_api.g_number) <>
    nvl(p_rec.assignment_id, hr_api.g_number)  or
    nvl(pay_aif_shd.g_old_rec.action_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.action_information_category, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information1, hr_api.g_varchar2) <>
    nvl(p_rec.action_information1, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information2, hr_api.g_varchar2) <>
    nvl(p_rec.action_information2, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information3, hr_api.g_varchar2) <>
    nvl(p_rec.action_information3, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information4, hr_api.g_varchar2) <>
    nvl(p_rec.action_information4, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information5, hr_api.g_varchar2) <>
    nvl(p_rec.action_information5, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information6, hr_api.g_varchar2) <>
    nvl(p_rec.action_information6, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information7, hr_api.g_varchar2) <>
    nvl(p_rec.action_information7, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information8, hr_api.g_varchar2) <>
    nvl(p_rec.action_information8, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information9, hr_api.g_varchar2) <>
    nvl(p_rec.action_information9, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information10, hr_api.g_varchar2) <>
    nvl(p_rec.action_information10, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information11, hr_api.g_varchar2) <>
    nvl(p_rec.action_information11, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information12, hr_api.g_varchar2) <>
    nvl(p_rec.action_information12, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information13, hr_api.g_varchar2) <>
    nvl(p_rec.action_information13, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information14, hr_api.g_varchar2) <>
    nvl(p_rec.action_information14, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information15, hr_api.g_varchar2) <>
    nvl(p_rec.action_information15, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information16, hr_api.g_varchar2) <>
    nvl(p_rec.action_information16, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information17, hr_api.g_varchar2) <>
    nvl(p_rec.action_information17, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information18, hr_api.g_varchar2) <>
    nvl(p_rec.action_information18, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information19, hr_api.g_varchar2) <>
    nvl(p_rec.action_information19, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information20, hr_api.g_varchar2) <>
    nvl(p_rec.action_information20, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information21, hr_api.g_varchar2) <>
    nvl(p_rec.action_information21, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information22, hr_api.g_varchar2) <>
    nvl(p_rec.action_information22, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information23, hr_api.g_varchar2) <>
    nvl(p_rec.action_information23, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information24, hr_api.g_varchar2) <>
    nvl(p_rec.action_information24, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information25, hr_api.g_varchar2) <>
    nvl(p_rec.action_information25, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information26, hr_api.g_varchar2) <>
    nvl(p_rec.action_information26, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information27, hr_api.g_varchar2) <>
    nvl(p_rec.action_information27, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information28, hr_api.g_varchar2) <>
    nvl(p_rec.action_information28, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information29, hr_api.g_varchar2) <>
    nvl(p_rec.action_information29, hr_api.g_varchar2)  or
    nvl(pay_aif_shd.g_old_rec.action_information30, hr_api.g_varchar2) <>
    nvl(p_rec.action_information30, hr_api.g_varchar2) ))
    or (p_rec.action_information_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'Action Information DF'
      ,p_attribute_category              => p_rec.action_information_category
      ,p_attribute1_name                 => 'ACTION_INFORMATION1'
      ,p_attribute1_value                => p_rec.action_information1
      ,p_attribute2_name                 => 'ACTION_INFORMATION2'
      ,p_attribute2_value                => p_rec.action_information2
      ,p_attribute3_name                 => 'ACTION_INFORMATION3'
      ,p_attribute3_value                => p_rec.action_information3
      ,p_attribute4_name                 => 'ACTION_INFORMATION4'
      ,p_attribute4_value                => p_rec.action_information4
      ,p_attribute5_name                 => 'ACTION_INFORMATION5'
      ,p_attribute5_value                => p_rec.action_information5
      ,p_attribute6_name                 => 'ACTION_INFORMATION6'
      ,p_attribute6_value                => p_rec.action_information6
      ,p_attribute7_name                 => 'ACTION_INFORMATION7'
      ,p_attribute7_value                => p_rec.action_information7
      ,p_attribute8_name                 => 'ACTION_INFORMATION8'
      ,p_attribute8_value                => p_rec.action_information8
      ,p_attribute9_name                 => 'ACTION_INFORMATION9'
      ,p_attribute9_value                => p_rec.action_information9
      ,p_attribute10_name                => 'ACTION_INFORMATION10'
      ,p_attribute10_value               => p_rec.action_information10
      ,p_attribute11_name                => 'ACTION_INFORMATION11'
      ,p_attribute11_value               => p_rec.action_information11
      ,p_attribute12_name                => 'ACTION_INFORMATION12'
      ,p_attribute12_value               => p_rec.action_information12
      ,p_attribute13_name                => 'ACTION_INFORMATION13'
      ,p_attribute13_value               => p_rec.action_information13
      ,p_attribute14_name                => 'ACTION_INFORMATION14'
      ,p_attribute14_value               => p_rec.action_information14
      ,p_attribute15_name                => 'ACTION_INFORMATION15'
      ,p_attribute15_value               => p_rec.action_information15
      ,p_attribute16_name                => 'ACTION_INFORMATION16'
      ,p_attribute16_value               => p_rec.action_information16
      ,p_attribute17_name                => 'ACTION_INFORMATION17'
      ,p_attribute17_value               => p_rec.action_information17
      ,p_attribute18_name                => 'ACTION_INFORMATION18'
      ,p_attribute18_value               => p_rec.action_information18
      ,p_attribute19_name                => 'ACTION_INFORMATION19'
      ,p_attribute19_value               => p_rec.action_information19
      ,p_attribute20_name                => 'ACTION_INFORMATION20'
      ,p_attribute20_value               => p_rec.action_information20
      ,p_attribute21_name                => 'ACTION_INFORMATION21'
      ,p_attribute21_value               => p_rec.action_information21
      ,p_attribute22_name                => 'ACTION_INFORMATION22'
      ,p_attribute22_value               => p_rec.action_information22
      ,p_attribute23_name                => 'ACTION_INFORMATION23'
      ,p_attribute23_value               => p_rec.action_information23
      ,p_attribute24_name                => 'ACTION_INFORMATION24'
      ,p_attribute24_value               => p_rec.action_information24
      ,p_attribute25_name                => 'ACTION_INFORMATION25'
      ,p_attribute25_value               => p_rec.action_information25
      ,p_attribute26_name                => 'ACTION_INFORMATION26'
      ,p_attribute26_value               => p_rec.action_information26
      ,p_attribute27_name                => 'ACTION_INFORMATION27'
      ,p_attribute27_value               => p_rec.action_information27
      ,p_attribute28_name                => 'ACTION_INFORMATION28'
      ,p_attribute28_value               => p_rec.action_information28
      ,p_attribute29_name                => 'ACTION_INFORMATION29'
      ,p_attribute29_value               => p_rec.action_information29
      ,p_attribute30_name                => 'ACTION_INFORMATION30'
      ,p_attribute30_value               => p_rec.action_information30
      );
 end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_action_context_type >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates the action context type.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--   p_action_context_type
--
-- Post Success:
--   If the action context type is valid this procedure will end normally and
--   processing will continue.
--
-- Post Failure:
--   If the  action context type is invalid then an application error is
--   raised as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_action_context_type
  (p_action_context_type in varchar2
  ) is
  --
  l_proc     varchar2(72) := g_package || 'chk_action_context_type';
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if p_action_context_type not in ('PA','AAC','AAP') then
  --
    fnd_message.set_name('PAY','PAY_34986_INV_ACT_CONTEXT_TYPE');
    fnd_message.raise_error;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,20);
--
End chk_action_context_type;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_action_context_id >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates the action context.
--
-- Prerequisites:
--   Must have already validated action context type.
--
-- In Arguments:
--   p_action_context_id
--   p_action_context_type
--
-- Post Success:
--   If the action context is valid this procedure will end normally and
--   processing will continue.
--
-- Post Failure:
--   If the  action context is invalid then an application error is
--   raised as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_action_context_id
  (p_action_context_id   in number
  ,p_action_context_type in varchar2
  ) is
  --
  cursor csr_pact_exists is
    select 'X'
    from   pay_payroll_actions
    where  payroll_action_id = p_action_context_id;
  --
  cursor csr_aact_exists is
    select 'X'
    from   pay_assignment_actions
    where  assignment_action_id = p_action_context_id;
  --
  l_proc     varchar2(72) := g_package || 'chk_action_context_id';
  l_dummy    varchar2(1);
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if (p_action_context_type = 'PA') then
  --
    open csr_pact_exists;
    fetch csr_pact_exists into l_dummy;
    if csr_pact_exists%notfound then
    --
      fnd_message.set_name('PAY','PAY_34985_INVALID_PAY_ACTION');
      fnd_message.raise_error;
    --
    end if;
  --
  elsif (p_action_context_type in ('AAC','AAP')) then
  --
    open csr_aact_exists;
    fetch csr_aact_exists into l_dummy;
    if csr_aact_exists%notfound then
    --
      fnd_message.set_name('PAY','PAY_34985_INVALID_PAY_ACTION');
      fnd_message.raise_error;
    --
    end if;
  --
  else
  --
    fnd_message.set_name('PAY','PAY_34986_INV_ACT_CONTEXT_TYPE');
    fnd_message.raise_error;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,20);
--
End chk_action_context_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_assignment_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates the assignment.
--
-- Prerequisites:
--   None
--
-- In Arguments:
--   p_assignment_id
--
-- Post Success:
--   If the assignment is valid this procedure will end normally and
--   processing will continue.
--
-- Post Failure:
--   If the assignment is invalid then an application error is
--   raised as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_assignment_id
  (p_assignment_id   in number
  ) is
  --
  cursor csr_asg_exists is
    select 'X'
    from   per_all_assignments_f
    where  assignment_id = p_assignment_id;
  --
  l_proc     varchar2(72) := g_package || 'chk_assignment_id';
  l_dummy    varchar2(1);
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if (p_assignment_id is not null) then
  --
    open csr_asg_exists;
    fetch csr_asg_exists into l_dummy;
    if csr_asg_exists%notfound then
    --
      fnd_message.set_name('PAY','PAY_52099_ASG_INV_ASG_ID');
      fnd_message.raise_error;
    --
    end if;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,20);
--
End chk_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec in pay_aif_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_aif_shd.api_updating
      (p_action_information_id                => p_rec.action_information_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- action_context_id
  --
  if nvl(p_rec.action_context_id,hr_api.g_number) <>
     nvl(pay_aif_shd.g_old_rec.action_context_id,hr_api.g_number) then
  --
    l_argument := 'p_rec.action_context_id';
    raise l_error;
  --
  end if;
  --
  -- action_context_type
  --
  if nvl(p_rec.action_context_type,hr_api.g_varchar2) <>
     nvl(pay_aif_shd.g_old_rec.action_context_type,hr_api.g_varchar2) then
  --
    l_argument := 'p_rec.action_context_type';
    raise l_error;
  --
  end if;
  --
  -- effective_date
  --
  if nvl(p_rec.effective_date,hr_api.g_date) <>
     nvl(pay_aif_shd.g_old_rec.effective_date,hr_api.g_date) then
  --
    l_argument := 'p_rec.effective_date';
    raise l_error;
  --
  end if;
  --
  -- assignment_id
  --
  if nvl(p_rec.assignment_id,hr_api.g_number) <>
     nvl(pay_aif_shd.g_old_rec.assignment_id,hr_api.g_number) then
  --
    l_argument := 'p_rec.assignment_id';
    raise l_error;
  --
  end if;
  --
  -- action_information_category
  --
  if nvl(p_rec.action_information_category,hr_api.g_varchar2) <>
     nvl(pay_aif_shd.g_old_rec.action_information_category,hr_api.g_varchar2) then
  --
    l_argument := 'p_rec.action_information_category';
    raise l_error;
  --
  end if;
  --
  -- tax_unit_id
  --
  if nvl(p_rec.tax_unit_id,hr_api.g_number) <>
     nvl(pay_aif_shd.g_old_rec.tax_unit_id,hr_api.g_number) then
  --
    l_argument := 'p_rec.tax_unit_id';
    raise l_error;
  --
  end if;
  --
  -- jurisdiction_code
  --
  if nvl(p_rec.jurisdiction_code,hr_api.g_varchar2) <>
     nvl(pay_aif_shd.g_old_rec.jurisdiction_code,hr_api.g_varchar2) then
  --
    l_argument := 'p_rec.jurisdiction_code';
    raise l_error;
  --
  end if;
  --
  -- source_id
  --
  if nvl(p_rec.source_id,hr_api.g_number) <>
     nvl(pay_aif_shd.g_old_rec.source_id,hr_api.g_number) then
  --
    l_argument := 'p_rec.source_id';
    raise l_error;
  --
  end if;
  --
  -- source_text
  --
  if nvl(p_rec.source_text,hr_api.g_varchar2) <>
     nvl(pay_aif_shd.g_old_rec.source_text,hr_api.g_varchar2) then
  --
    l_argument := 'p_rec.source_text';
    raise l_error;
  --
  end if;
  --
  -- tax_group
  --
  if nvl(p_rec.tax_group,hr_api.g_varchar2) <>
     nvl(pay_aif_shd.g_old_rec.tax_group,hr_api.g_varchar2) then
  --
    l_argument := 'p_rec.tax_group';
    raise l_error;
  --
  end if;
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pay_aif_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  pay_aif_bus.chk_action_context_type(p_rec.action_context_type);
  --
  pay_aif_bus.chk_action_context_id(p_rec.action_context_id,p_rec.action_context_type);
  --
  pay_aif_bus.chk_assignment_id(p_rec.assignment_id);
  --
  -- Removed call - assume trusted source (performance implications
  --                in calling this for large volumes)
  --  pay_aif_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pay_aif_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  chk_non_updateable_args(p_rec);
  --
  -- Removed call - assume trusted source (performance implications
  --                in calling this for large volumes)
  --  pay_aif_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_aif_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_aif_bus;

/
